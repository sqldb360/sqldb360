/*
 * PLNFND script example
 * Name of the script must be script.sql
 */

/* Example DDL
 * create table t1 as select rownum id, mod(rownum, 100) n1, mod(rownum, 2000) n2 from dual connect by rownum <= 100000;
 * create index t1_id on t1(id);
 * create index t1_n1 on t1(n1);
 * create index t1_n2 on t1(n2);
 * exec dbms_stats.gather_table_stats(user, 'T1');
 * 
 * create table t2 as select rownum id, mod(rownum, 100) n1, mod(rownum, 2000) n2 from dual connect by rownum <= 100000;
 * create index t2_id on t2(id);
 * create index t2_n1 on t2(n1);
 * create index t2_n2 on t2(n2);
 * exec dbms_stats.gather_table_stats(user, 'T2');
 * 
 * insert into t1 select * from t1;
 * insert into t1 select * from t1;
 * insert into t2 select * from t2;
 * commit;
 */

/*
 * Add here the ALTER SESSIONS
 */
alter session set "_optimizer_dsdir_usage_control"=0;

/*
 * Add here the SQL text, remember the mandatory
 * comment  ^^pathfinder_testid 
 */

select /* ^^pathfinder_testid */ t1.n1, t1.n2, t2.n1, t2.n2
  from t1, t2
 where t1.n1 = 0
   and t1.n2 = 1000
   and t2.id = t1.id
   and t2.n1 = 0
   and t2.n2 = 400; 
