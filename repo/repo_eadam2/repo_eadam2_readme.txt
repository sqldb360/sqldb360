This eadam2 repository is only to be used when the state of the awr data is such that
awr_ash_pre_check.sql has determined edb360 would take much longer than 24hrs.

The eadam2 is intended to be generated on a source database and consumed on a different
target database, possibly on a lower environment on premises, or on a remote location.

This method uses external flat text files to host the eadam2 repository. It installs 
nothing on the source database. It requires large space on disk on both source and target
databases.

If you intend to consume the repository on the same system and database where it is 
created, use instead the edb360 repository.

Method eadam3 is preferred over eadam2.

****************************************************************************************
                                Repo Create (on source)
****************************************************************************************

1. Manually create or allocate a directory on source database server to stage the eadam2 
   repository. This method uses flat text files to materialize the content of several
   views. Designated directory must have at least 20G of free space.
   
   # cd ../..
   # cd acfs
   # mkdir eadam2

2. Copy into the designated directory scripts repo_eadam2_create.sql and 
   repo_eadam2_create_one.sql out of edb360-master/repo/repo_eadam2/source

3. Execute repo_eadam2_create.sql connecting as SYS or DBA. 
   
   # cd acfs/eadam2
   # sqlplus / as sysdba
   SQL> @repo_eadam2_create.sql

4. Provide repo_eadam2_<dbname>.zip to requestor. This is a binary file.

****************************************************************************************
                                Repo Restore (on target)
****************************************************************************************

1. On target system and connected as oracle, manually create a directory to host the 
   eadam2 repository. This directory must have at least 20G of free space. Owner must be
   oracle. 

   # cd ../..
   # cd acfs
   # mkdir eadam2

2. Transfer the eadam2 repository from source system into designated directory on the 
   target system. Use sftp on binary mode to transfer this large repo_eadam2_<dbname>.zip.

3. Copy also into the designated directory scripts repo_eadam2_restore.sql and 
   repo_eadam2_restore_one.sql out of edb360-master/repo/repo_eadam2/target

4. Create database directory eadam2_dir that points to server directory created on step 1.
   Be sure the referenced server directory exists on the host system and that it contains 
   at least 20GB of free space.

   # sqlplus / as sysdba
   SQL> create directory eadam2_dir as '/acfs/eadam2'; <<< make name eadam2_dir

5. Manually create a user to own the eadam2 repository. This user needs no additional 
   grants and it can be locked. Be sure default tablespace for this user has at least 10GB 
   of free space. For example, create user eadam2 (any name is valid but sys).
   
   # sqlplus / as sysdba
   SQL> create user eadam2 identified by <some_unique_pwd>;
   SQL> alter user eadam2 default tablespace <tablespace> quota unlimited on <tablespace>; 
   
6. Execute repo_eadam2_restore.sql connecting as SYS or DBA. When asked, pass as parameter 
   the name of the source database (which is part of the filename) and the eadam2 
   repository owner (user created on prior step). You need to be connected to server as 
   oracle.
   
   # cd acfs/eadam2
   # sqlplus / as sysdba
   SQL> @repo_eadam2_restore.sql
   source database name: <dbname> <<< as per repo_eadam2_<dbname>.zip
   tool repository user (i.e. eadam2): eadam2 <<< repository owner

****************************************************************************************
                                Repo Consume (on target)
****************************************************************************************

1. Configure edb360 to access the eadam2 repository instead of base views: either modify
   edb360-master/sql/edb360_00_config.sql or edb360-master/sql/custom_config_01.sql and 
   set tool_repo_user.
   
   DEF tool_repo_user = 'eadam2'; 

2. Execute edb360 as usual. If tool_repo_user was set on edb360_00_config.sql then
   pass nothing (or NULL) on second edb360 parameter. If tool_repo_user was set on 
   custom_config_01.sql then pass custom_config_01.sql as second parameter.

   # cd edb360-master
   # sqlplus / as sysdba
   SQL> @edb360.sql T NULL <<< if tool_repo_user was set on sql/edb360_00_config.sql
   or
   SQL> @edb360.sql T custom_config_01.sql  <<< if set on sql/custom_config_01.sql

****************************************************************************************
                                    Repo Drop (on target)
****************************************************************************************

1. Once edb360 completes you can drop the eadam2 repository, and reset tool_repo_user on
   edb360_00_config.sql or custom_config_01.sql.

   # cd edb360-master/repo/repo_eadam2/target
   # sqlplus / as sysdba
   SQL> @repo_eadam2_drop.sql
   tool repository user: eadam2 <<< repository owner

2. Drop database directory eadam2_dir which points to server directory containing the
   repository.
   
   # sqlplus / as sysdba
   SQL> select directory_path from dba_directories where directory_name = 'EADAM2_DIR';
   SQL> drop directory eadam2_dir; 

3. Remove the directory path and content from database server identified by EADAM2_DIR 
   directory.

   # cd ../..
   # cd acfs
   # rm -r eadam2

4. Drop the user who owns the repository.

   # sqlplus / as sysdba
   SQL> drop user eadam2 cascade; <<< repository owner

****************************************************************************************
