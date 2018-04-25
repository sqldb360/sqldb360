SET SERVEROUTPUT OFF

-- try to identify a suitable dir to dump TCB files
VAR tcb_dir VARCHAR2(30)
VAR tcb_path VARCHAR2(4000)
DEF file_name = 'sqld360_file.txt'
DEF fallback_dir = 'DATA_PUMP_DIR';
-- next line is just for standadlone test, need to remove later
DEF default_dir = 'SQLD360_DIR'

-- The idea is to evaluate (in order)
--  1. the default SQLD360 dir -> SQLD360_DIR 
--  2. any dir coming from SQLT -> SQLT$%
--  3. if utl_file_dir is set
--    3a. the first 3 directories for which there is an entry in utl_file_dir 
--    3b. DATA_PUMP_DIR that is created by default by DBCA
DECLARE
  rdbms_release    NUMBER;
  l_temporary_dir  VARCHAR2(30);
  l_temporary_path VARCHAR2(4000);
  l_working_dir    VARCHAR2(1); 
  l_utlfiledir_v   VARCHAR2(4000);
  l_utlfiledir_set VARCHAR2(1);
  l_open_mode      VARCHAR2(2); 
  l_cutfrom        NUMBER;
  l_cutto          NUMBER;
  ------------------------------------

  PROCEDURE open_write_close (
    p2_location IN VARCHAR2,
    p2_filename IN VARCHAR2 )
  IS
    out_file_type UTL_FILE.file_type;
  BEGIN
    SYS.DBMS_OUTPUT.PUT_LINE('Test WRITING into file "'||p2_filename||'" in directory "'||p2_location||'" started.');
    out_file_type :=
    SYS.UTL_FILE.FOPEN (
       location     => p2_location,
       filename     => p2_filename,
       open_mode    => l_open_mode,
       max_linesize => 32767 );

    IF rdbms_release < 10 THEN
      SYS.UTL_FILE.PUT_LINE (
        file   => out_file_type,
        buffer => 'Hello World!');
    ELSE
      SYS.UTL_FILE.PUT_RAW (
        file   => out_file_type,
        buffer => SYS.UTL_RAW.CAST_TO_RAW('Hello World!'||CHR(10)));
    END IF;

    SYS.UTL_FILE.FCLOSE(file => out_file_type);
    SYS.DBMS_OUTPUT.PUT_LINE('Test WRITING into file "'||p2_filename||'" in directory "'||p2_location||'" completed.');
  END open_write_close;

  ------------------------------------

  PROCEDURE open_read_close (
    p2_directory_alias IN VARCHAR2,
    p2_file_name IN VARCHAR2 )
  IS
    l_file BFILE;
    l_file_len INTEGER := NULL;
    l_file_offset INTEGER;
    l_chunk_raw RAW(32767);
    l_chunk VARCHAR2(32767);
  BEGIN
    SYS.DBMS_OUTPUT.PUT_LINE('Test READING file "'||p2_file_name||'" from directory "'||p2_directory_alias||'" started.');
    l_file := BFILENAME(p2_directory_alias, p2_file_name);
    SYS.DBMS_LOB.FILEOPEN (file_loc => l_file);
    l_file_len := SYS.DBMS_LOB.GETLENGTH(file_loc => l_file);
    l_file_offset := 1;

    SYS.DBMS_LOB.READ (
      file_loc => l_file,
      amount   => l_file_len,
      offset   => l_file_offset,
      buffer   => l_chunk_raw );

    l_chunk := SYS.UTL_RAW.CAST_TO_VARCHAR2 (r => l_chunk_raw);
    SYS.DBMS_LOB.FILECLOSE (file_loc => l_file);
    SYS.DBMS_OUTPUT.PUT_LINE('Test READING file "'||p2_file_name||'" from directory "'||p2_directory_alias||'" completed.');
  END open_read_close;

  -------------------------------------

  PROCEDURE read_attributes (
    p2_directory_alias IN VARCHAR2,
    p2_file_name IN VARCHAR2 )
  IS
    l_file_exists     BOOLEAN;
    l_file_length     NUMBER;
    l_file_block_size NUMBER;
  BEGIN
    SYS.UTL_FILE.FGETATTR (
      location     => p2_directory_alias,
      filename     => p2_file_name,
      fexists      => l_file_exists,
      file_length  => l_file_length,
      block_size   => l_file_block_size );

    IF l_file_exists THEN
      SYS.DBMS_OUTPUT.PUT_LINE('File "'||p2_file_name||'" exists in directory "'||p2_directory_alias||'".');
    ELSE
      SYS.DBMS_OUTPUT.PUT_LINE('File "'||p2_file_name||'" does not exists in directory "'||p2_directory_alias||'".');
      RAISE_APPLICATION_ERROR(-20100, 'Install failed - UTL_FILE.FGETATTR not capable of reading file attributes.');
    END IF;
  END read_attributes;

 -----------------------------------------

  FUNCTION test_dir(
    dir_name VARCHAR2) RETURN VARCHAR2 
  IS
   file_name VARCHAR2(30) := '&&file_name.';
  BEGIN

    SELECT TO_NUMBER(SUBSTR(version, 1, INSTR(version, '.', 1, 2) - 1))
      INTO rdbms_release
      FROM v$instance;

    IF rdbms_release < 10 THEN
      l_open_mode := 'W';
    ELSE
      l_open_mode := 'WB';
    END IF;

   open_write_close(dir_name,file_name);
   open_read_close(dir_name,file_name);
   read_attributes(dir_name,file_name);

   RETURN 'Y';

  EXCEPTION WHEN OTHERS THEN 
    DBMS_OUTPUT.PUT_LINE(SQLERRM);
    RETURN 'N';
  END;
 
BEGIN

   SELECT '&&default_dir.'
     INTO l_temporary_dir
     FROM DUAL;
   
   -- testing option #1
   l_working_dir := test_dir(l_temporary_dir);
   IF l_working_dir = 'Y' THEN
     :tcb_dir := l_temporary_dir;
     SELECT directory_path
       INTO :tcb_path
       FROM dba_directories
      WHERE UPPER(directory_name) = UPPER(:tcb_dir);
   ELSE

     -- option #2, looking for a SQLT dir, doesn't matter which one
     BEGIN
       SELECT directory_name
         INTO l_temporary_dir
         FROM dba_directories
        WHERE directory_name like 'SQLT$%'
          AND rownum = 1;
     EXCEPTION WHEN NO_DATA_FOUND THEN
     -- it will fail for sure like it did before, just a safety net
       l_temporary_dir := '&&default_dir.';
     END;

     -- testing option #2
     l_working_dir := test_dir(l_temporary_dir);
     IF l_working_dir = 'Y' THEN
       :tcb_dir := l_temporary_dir;
       SELECT directory_path
         INTO :tcb_path
         FROM dba_directories
        WHERE UPPER(directory_name) = UPPER(:tcb_dir);
     ELSE
       -- select the content of utl_file_dir
       -- if not null then go for option #3 else #4
       BEGIN
         SELECT value
           INTO l_utlfiledir_v
           FROM gv$parameter
          WHERE UPPER(name) = 'UTL_FILE_DIR'
            AND value IS NOT NULL
            AND rownum = 1;

         l_utlfiledir_set := 'Y';

       EXCEPTION WHEN NO_DATA_FOUND THEN
         l_utlfiledir_set := 'N';
       END;

      IF l_utlfiledir_set = 'Y' THEN
         --option #3, loop over the first 3 dirs in utl_file_dir
         FOR i IN 1..3 LOOP

         -- the first dir is from the first char to the first comma
           IF i = 1 THEN
             l_cutfrom := 1;
             l_cutto := instr(l_utlfiledir_v,',',1,i)-1;
           ELSE
             l_cutfrom := instr(l_utlfiledir_v,',',1,i-1)+1;
             l_cutto := instr(l_utlfiledir_v,',',1,i)-instr(l_utlfiledir_v,',',1,i-1)-1;
           END IF;

           -- the last dir goes all the way to the end of the string
           IF instr(l_utlfiledir_v,',',1,i) = 0 THEN
             l_cutto := length(l_utlfiledir_v)+1;
           END IF;
          
           -- identify the Ith directory
           l_temporary_path := substr(l_utlfiledir_v,l_cutfrom,l_cutto);

           BEGIN
             SELECT directory_name
               INTO l_temporary_dir
               FROM dba_directories
              WHERE UPPER(directory_path) = UPPER(l_temporary_path);
           EXCEPTION WHEN NO_DATA_FOUND THEN
             l_temporary_dir := '&&default_dir.';
           END;

           l_working_dir := test_dir(l_temporary_dir);
           IF l_working_dir = 'Y' THEN
             :tcb_dir := l_temporary_dir;
             SELECT directory_path
               INTO :tcb_path
               FROM dba_directories
              WHERE UPPER(directory_name) = UPPER(:tcb_dir);
             EXIT;
           END IF;

         END LOOP;
      ELSE
       -- option #4, test DATA_PUMP_DIR
         l_temporary_dir := '&&fallback_dir.';
         l_working_dir := test_dir(l_temporary_dir);
         IF l_working_dir = 'Y' THEN
           :tcb_dir := l_temporary_dir; 
           SELECT directory_path
             INTO :tcb_path
             FROM dba_directories
            WHERE UPPER(directory_name) = UPPER(:tcb_dir);
         END IF;

      END IF; -- option #3/#4
     END IF;  -- option #2 
   END IF; -- option #1
   

END;
/

COL tcb_dir NEW_V tcb_dir
SELECT :tcb_dir tcb_dir FROM DUAL;

COL tcb_path NEW_V tcb_path
SELECT :tcb_path tcb_path FROM DUAL;
