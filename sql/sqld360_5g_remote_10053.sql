VAR c10053 CLOB;

DECLARE
  l_file_location VARCHAR2(4000);
  l_dir_name      VARCHAR2(100);
  l_bfile         BFILE;
  l_dest          INTEGER := 1;
  l_src           INTEGER := 1;
  l_csid          INTEGER := 0;
  l_lng           INTEGER := 0;
  l_warn          INTEGER := 0;
BEGIN

   SELECT value 
     INTO l_file_location
     FROM v$diag_info
    WHERE name = 'Diag Trace'; 

  BEGIN
   SELECT directory_name
     INTO l_dir_name
     FROM dba_directories
    WHERE directory_path = l_file_location
      AND ROWNUM = 1;
  EXCEPTION 
   WHEN NO_DATA_FOUND THEN raise_application_error( -20001, 'No directory matches with Diag Trace' );   
   WHEN OTHERS THEN RAISE;
  END;

  -- file name is &&connect_instance_name._ora_&&sqld360_spid._sqld360_10053_&&sqld360_sqlid..trc
  l_bfile := BFILENAME(l_dir_name, '&&connect_instance_name._ora_&&sqld360_spid._sqld360_10053_&&sqld360_sqlid..trc' );
  DBMS_LOB.CREATETEMPORARY(:c10053, TRUE, DBMS_LOB.SESSION);
  DBMS_LOB.FILEOPEN(l_bfile);
  DBMS_LOB.LOADCLOBFROMFILE(:c10053, l_bfile, DBMS_LOB.LOBMAXSIZE, l_dest, l_src, l_csid, l_lng, l_warn);
  DBMS_LOB.FILECLOSE(l_bfile);
END;
/ 

-- we get here only for remote exec so should be safe
SET PAGES 0 HEAD OFF LONG 200000000 LONGCHUNKSIZE 200000000 LINE 300
SPO &&one_spool_filename..trc
PRINT :c10053
SPO OFF
