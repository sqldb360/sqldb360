This edb360 repository is only to be used when the state of the awr data is such that
awr_ash_pre_check.sql has determined edb360 would take much longer than 24hrs.

This method uses regular heap tables to host the edb360 repository.

The edb360 repository is intended to be created and consumed within same database. 

If you need to consume the repository on a different system, use instead the eadam3 
repository.

****************************************************************************************
                                Repo Create (on source)
****************************************************************************************

1. Manually create a user to own the edb360 repository. This user needs no additional 
   grants and it can be locked. Be sure default tablespace for this user has at least 
   10GB of spare space. For example, create user edb360 (any name is valid but sys).
   
   # sqlplus / as sysdba
   SQL> create user edb360 identified by <some_unique_pwd>;
   SQL> alter user edb360 default tablespace <tablespace> quota unlimited on <tablespace>; 

2. Execute repo_edb360_create.sql connecting as SYS or DBA. When asked, pass as parameter 
   the edb360 repository's owner (user created on prior step).
   
   # cd edb360-master/repo/repo_edb360/source
   # sqlplus / as sysdba
   SQL> @repo_edb360_create.sql
   tool repository user (i.e. edb360): edb360 <<< repository owner

****************************************************************************************
                                Repo Consume (on source)
****************************************************************************************

1. Configure edb360 to access the edb360 repository instead of base views: either modify
   edb360-master/sql/edb360_00_config.sql or edb360-master/sql/custom_config_01.sql and 
   set tool_repo_user.
   
   DEF tool_repo_user = 'edb360'; <<< must match schema owner from prior steps

2. Execute edb360 as usual. If tool_repo_user was set on edb360_00_config.sql then pass 
   nothing (or NULL) on second edb360 parameter. If tool_repo_user was set on 
   custom_config_01.sql then pass custom_config_01.sql as second parameter.

   SQL> @edb360.sql T NULL <<< if tool_repo_user was set on edb360_00_config.sql
   or
   SQL> @edb360.sql T custom_config_01.sql <<< if set on custom_config_01.sql

****************************************************************************************
                                    Repo Drop (on source)
****************************************************************************************

1. Once edb360 completes you can drop the edb360 repository, and reset tool_repo_user on
   edb360_00_config.sql or custom_config_01.sql.

   # cd edb360-master/repo/repo_edb360/source
   # sqlplus / as sysdba
   SQL> @repo_edb360_drop.sql
   tool repository user: edb360 <<< repository owner

2. Drop the user who owns the repository.

   # sqlplus / as sysdba
   SQL> drop user edb360 cascade; <<< repository owner

****************************************************************************************
