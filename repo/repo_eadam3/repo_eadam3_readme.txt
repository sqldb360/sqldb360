This eadam3 repository is only to be used when the state of the awr data is such that
awr_ash_pre_check.sql has determined edb360 would take much longer than 24hrs.

This method uses external tables to host the eadam3 repository.

The eadam3 is intended to be generated on a source database and consumed on a different
target database, possibly on a lower environment on premises, or on a remote location.

If you intend to consume the repository on the same system and database where it is 
created, use instead the edb360 repository.

****************************************************************************************
                                Repo Create (on source)
****************************************************************************************

1. Logged as oracle, manually create a directory on database server to host the eadam3 
   repository. This method uses external tables to materialize the content of several
   views. Owner must be oracle.
   
   # cd ../..
   # cd acfs
   # mkdir eadam3

2. Create database directory eadam3_dir that points to server directory created on prior 
   step. Be sure the referenced server directory exists on the host system and that it   
   contains at least 10GB of free space.

   # sqlplus / as sysdba
   SQL> create directory eadam3_dir as '/acfs/eadam3'; <<< make name eadam3_dir

3. Manually create a user to own the eadam3 repository. This user needs no additional 
   grants and it can be locked. For example, create user eadam3 (any name is valid but 
   sys)
   
   # sqlplus / as sysdba
   SQL> create user eadam3 identified by <some_unique_pwd>;

4. Execute repo_eadam3_create.sql connecting as SYS or DBA. When asked, pass as parameter 
   the eadam3 repository's owner (user created on prior step).
   
   # cd edb360-master/repo/repo_eadam3/source
   # sqlplus / as sysdba
   SQL> @repo_eadam3_create.sql
   tool repository user (i.e. eadam3): eadam3 <<< repository owner

****************************************************************************************
                                Repo Restore (on target)
****************************************************************************************

1. Transfer the eadam3 repository from source to target system. For this you need to move
   two files: the compressed entire server directory behind eadam3_dir, and the 
   repo_eadam3_logs.zip from the repo creation. To compress the server directory behind 
   eadam3_dir you may want to use zip or tar utilities, then sftp the binary files.

2. Create on target system a server directory and a database directory following steps 1
   and 2 from Repo Create section above. Uncompress both files into the eadam3_dir.
   
3. Similarly, create the user that will own the eadam3 repository. Follow step 3 on Repo
   Create section above.
   
4. Review and execute repo_eadam3_ddl.sql contained on repo_eadam3_logs.zip. This script
   creates the definition of the set of external tables for which the dmp files reside 
   now on the eadam3_dir directory.
   
   Optional steps:
   ~~~~~~~~~~~~~~

5. Create an edb360. This step 5 and following step 6 are optional but highly recommended, 
   else you may get ORA-600 documented on bug 25802477.

   Manually create a user to own the edb360 repository. This user needs no additional 
   grants and it can be locked. Be sure default tablespace for this user has at least 
   10GB of spare space. For example, create user edb360 (any name is valid but sys).
   
   # sqlplus / as sysdba
   SQL> create user edb360 identified by <some_unique_pwd>;
   SQL> alter user edb360 default tablespace <tablespace> quota unlimited on <tablespace>; 

6. Clone the eadam3 repository (external tables) into an edb360 repository (heap tables).
   Execute repo/repo_eadam3/target/repo_eadam3_clone.sql connecting as SYS or DBA. After 
   this step you will have two usable repositories: eadam3 and edb360.

****************************************************************************************
                                Repo Consume (on target)
****************************************************************************************

1. Configure edb360 to access edb360 (or eadam3) repository instead of base views: either 
   modify edb360-master/sql/edb360_00_config.sql or edb360-master/sql/custom_config_01.sql 
   and set tool_repo_user.
   
   DEF tool_repo_user = 'eadam3'; 
   or
   DEF tool_repo_user = 'edb360'; 

2. Execute edb360 as usual. If tool_repo_user was set on edb360_00_config.sql then  
   pass nothing (or NULL) on second edb360 parameter. If tool_repo_user was set on 
   custom_config_01.sql then pass custom_config_01.sql as second parameter.

   SQL> @edb360.sql T NULL <<< if tool_repo_user was set on edb360_00_config.sql
   or
   SQL> @edb360.sql T custom_config_01.sql  <<< if set on custom_config_01.sql

****************************************************************************************
                                    Repo Drop (on both)
****************************************************************************************

1. Once edb360 completes (on target) you can drop the eadam3 repository, and reset 
   tool_repo_user on edb360_00_config.sql or custom_config_01.sql.

   # cd edb360-master/repo/repo_eadam3/source
   # sqlplus / as sysdba
   SQL> @repo_eadam3_drop.sql
   tool repository user: eadam3 <<< repository owner

2. Drop database directory eadam3_dir which points to server directory containing the
   repository.
   
   # sqlplus / as sysdba
   SQL> select directory_path from dba_directories where directory_name = 'EADAM3_DIR';
   SQL> drop directory eadam3_dir; 

3. Remove the directory path and content from database server identified by EADAM3_DIR 
   directory.

   # cd ../..
   # cd acfs
   # rm -r eadam3

4. Drop the user who owns the repository.

   # sqlplus / as sysdba
   SQL> drop user eadam3 cascade; <<< repository owner

****************************************************************************************
