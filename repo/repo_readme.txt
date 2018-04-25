edb360 provides 3 repositories to address different scenarios:

1. Performance improvement on the execution of edb360.

   Use the repo_edb360 repository. It creates a repository of accessed DBA and GV$ views
   into a designated staging schema on the same database that is being analyzed.
   
   This method is simple and fast.

2. Execute edb360 report on a database other then the source.

   Use repo_eadam3, which creates external tables on source database, out of required DBA 
   and GV$ views.
   
   Then restore these staging external tables into a target system. 
   
   This method creates some objects on the source database.

3. Execute edb360 report on a database other then the source, without creating any objects 
   on the source database.
   
   Use repo_eadam2. This method is similar to repo_eadam3, but uses text files instead of
   external tables. 
   
   This method requires more space on disk, is slower and some metadata is lost.
   
   Use repo_eadam3 instead of repo_eadam2 if possible. 
   
   Use this repo_eadam2 only when creating some objects on the source database is not 
   allowed at all.

Each of the 3 methods has its own readme. 