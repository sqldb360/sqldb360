-- Set version variables. Value will be 'Y' or 'N'
COL is_ver_le_9_1  new_v is_ver_le_9_1  nopri
COL is_ver_le_9_2  new_v is_ver_le_9_2  nopri
COL is_ver_le_9    new_v is_ver_le_9    nopri
COL is_ver_le_10_1 new_v is_ver_le_10_1 nopri
COL is_ver_le_10_2 new_v is_ver_le_10_2 nopri
COL is_ver_le_10   new_v is_ver_le_10   nopri
COL is_ver_le_11_1 new_v is_ver_le_11_1 nopri
COL is_ver_le_11_2 new_v is_ver_le_11_2 nopri
COL is_ver_le_11   new_v is_ver_le_11   nopri
COL is_ver_le_12_1 new_v is_ver_le_12_1 nopri
COL is_ver_le_12_2 new_v is_ver_le_12_2 nopri
COL is_ver_le_12   new_v is_ver_le_12   nopri
COL is_ver_le_18   new_v is_ver_le_18   nopri
COL is_ver_le_19   new_v is_ver_le_19   nopri
COL is_ver_le_20   new_v is_ver_le_20   nopri
--
COL is_ver_ge_9_1  new_v is_ver_ge_9_1  nopri
COL is_ver_ge_9_2  new_v is_ver_ge_9_2  nopri
COL is_ver_ge_9    new_v is_ver_ge_9    nopri
COL is_ver_ge_10_1 new_v is_ver_ge_10_1 nopri
COL is_ver_ge_10_2 new_v is_ver_ge_10_2 nopri
COL is_ver_ge_10   new_v is_ver_ge_10   nopri
COL is_ver_ge_11_1 new_v is_ver_ge_11_1 nopri
COL is_ver_ge_11_2 new_v is_ver_ge_11_2 nopri
COL is_ver_ge_11   new_v is_ver_ge_11   nopri
COL is_ver_ge_12_1 new_v is_ver_ge_12_1 nopri
COL is_ver_ge_12_2 new_v is_ver_ge_12_2 nopri
COL is_ver_ge_12   new_v is_ver_ge_12   nopri
COL is_ver_ge_18   new_v is_ver_ge_18   nopri
COL is_ver_ge_19   new_v is_ver_ge_19   nopri
COL is_ver_ge_20   new_v is_ver_ge_20   nopri

-- Set skip version variables. Value will be '--' when version is the corresponding.
COL skip_ver_le_9_1  new_v skip_ver_le_9_1  nopri
COL skip_ver_le_9_2  new_v skip_ver_le_9_2  nopri
COL skip_ver_le_9    new_v skip_ver_le_9    nopri
COL skip_ver_le_10_1 new_v skip_ver_le_10_1 nopri
COL skip_ver_le_10_2 new_v skip_ver_le_10_2 nopri
COL skip_ver_le_10   new_v skip_ver_le_10   nopri
COL skip_ver_le_11_1 new_v skip_ver_le_11_1 nopri
COL skip_ver_le_11_2 new_v skip_ver_le_11_2 nopri
COL skip_ver_le_11   new_v skip_ver_le_11   nopri
COL skip_ver_le_12_1 new_v skip_ver_le_12_1 nopri
COL skip_ver_le_12_2 new_v skip_ver_le_12_2 nopri
COL skip_ver_le_12   new_v skip_ver_le_12   nopri
COL skip_ver_le_18   new_v skip_ver_le_18   nopri
COL skip_ver_le_19   new_v skip_ver_le_19   nopri
COL skip_ver_le_20   new_v skip_ver_le_20   nopri
--
COL skip_ver_ge_9_1  new_v skip_ver_ge_9_1  nopri
COL skip_ver_ge_9_2  new_v skip_ver_ge_9_2  nopri
COL skip_ver_ge_9    new_v skip_ver_ge_9    nopri
COL skip_ver_ge_10_1 new_v skip_ver_ge_10_1 nopri
COL skip_ver_ge_10_2 new_v skip_ver_ge_10_2 nopri
COL skip_ver_ge_10   new_v skip_ver_ge_10   nopri
COL skip_ver_ge_11_1 new_v skip_ver_ge_11_1 nopri
COL skip_ver_ge_11_2 new_v skip_ver_ge_11_2 nopri
COL skip_ver_ge_11   new_v skip_ver_ge_11   nopri
COL skip_ver_ge_12_1 new_v skip_ver_ge_12_1 nopri
COL skip_ver_ge_12_2 new_v skip_ver_ge_12_2 nopri
COL skip_ver_ge_12   new_v skip_ver_ge_12   nopri
COL skip_ver_ge_18   new_v skip_ver_ge_18   nopri
COL skip_ver_ge_19   new_v skip_ver_ge_19   nopri
COL skip_ver_ge_20   new_v skip_ver_ge_20   nopri

select -- Lower or Equal
       case when version <  9  or (version = 9 and release = 1)  then 'Y' else 'N' end is_ver_le_9_1,
       case when version <= 9                                    then 'Y' else 'N' end is_ver_le_9_2,
       case when version <= 9                                    then 'Y' else 'N' end is_ver_le_9,
       case when version <  10 or (version = 10 and release = 1) then 'Y' else 'N' end is_ver_le_10_1,
       case when version <= 10                                   then 'Y' else 'N' end is_ver_le_10_2,
       case when version <= 10                                   then 'Y' else 'N' end is_ver_le_10,
       case when version <  11 or (version = 11 and release = 1) then 'Y' else 'N' end is_ver_le_11_1,
       case when version <= 11                                   then 'Y' else 'N' end is_ver_le_11_2,
       case when version <= 11                                   then 'Y' else 'N' end is_ver_le_11,
       case when version <  12 or (version = 12 and release = 1) then 'Y' else 'N' end is_ver_le_12_1,
       case when version <= 12                                   then 'Y' else 'N' end is_ver_le_12_2,
       case when version <= 12                                   then 'Y' else 'N' end is_ver_le_12,
       case when version <= 18                                   then 'Y' else 'N' end is_ver_le_18,
       case when version <= 19                                   then 'Y' else 'N' end is_ver_le_19,
       case when version <= 20                                   then 'Y' else 'N' end is_ver_le_20,
       -- Greater or Equal
       case when version >= 9                                    then 'Y' else 'N' end is_ver_ge_9_1,
       case when version >  9  or (version = 9 and release = 2)  then 'Y' else 'N' end is_ver_ge_9_2,
       case when version >= 9                                    then 'Y' else 'N' end is_ver_ge_9,
       case when version >= 10                                   then 'Y' else 'N' end is_ver_ge_10_1,
       case when version >  10 or (version = 10 and release = 2) then 'Y' else 'N' end is_ver_ge_10_2,
       case when version >= 10                                   then 'Y' else 'N' end is_ver_ge_10,
       case when version >= 11                                   then 'Y' else 'N' end is_ver_ge_11_1,
       case when version >  11 or (version = 11 and release = 2) then 'Y' else 'N' end is_ver_ge_11_2,
       case when version >= 11                                   then 'Y' else 'N' end is_ver_ge_11,
       case when version >= 12                                   then 'Y' else 'N' end is_ver_ge_12_1,
       case when version >  12 or (version = 12 and release = 2) then 'Y' else 'N' end is_ver_ge_12_2,
       case when version >= 12                                   then 'Y' else 'N' end is_ver_ge_12,
       case when version >= 18                                   then 'Y' else 'N' end is_ver_ge_18
       case when version >= 19                                   then 'Y' else 'N' end is_ver_ge_19
       case when version >= 20                                   then 'Y' else 'N' end is_ver_ge_20
from  (select to_number(substr(version,1,instr(version,'.')-1)) version,
              to_number(substr(version,instr(version,'.')+1, instr(version,'.',1,2)-instr(version,'.')-1)) release
         from v$instance);

select -- Lower or Equal
       decode('&&is_ver_le_9_1.'  ,'Y','--','N','') skip_ver_le_9_1,
       decode('&&is_ver_le_9_2.'  ,'Y','--','N','') skip_ver_le_9_2,
       decode('&&is_ver_le_9.'    ,'Y','--','N','') skip_ver_le_9,
       decode('&&is_ver_le_10_1.' ,'Y','--','N','') skip_ver_le_10_1,
       decode('&&is_ver_le_10_2.' ,'Y','--','N','') skip_ver_le_10_2,
       decode('&&is_ver_le_10.'   ,'Y','--','N','') skip_ver_le_10,
       decode('&&is_ver_le_11_1.' ,'Y','--','N','') skip_ver_le_11_1,
       decode('&&is_ver_le_11_2.' ,'Y','--','N','') skip_ver_le_11_2,
       decode('&&is_ver_le_11.'   ,'Y','--','N','') skip_ver_le_11,
       decode('&&is_ver_le_12_1.' ,'Y','--','N','') skip_ver_le_12_1,
       decode('&&is_ver_le_12_2.' ,'Y','--','N','') skip_ver_le_12_2,
       decode('&&is_ver_le_12.'   ,'Y','--','N','') skip_ver_le_12,
       decode('&&is_ver_le_18.'   ,'Y','--','N','') skip_ver_le_18,
       decode('&&is_ver_le_19.'   ,'Y','--','N','') skip_ver_le_19,
       decode('&&is_ver_le_20.'   ,'Y','--','N','') skip_ver_le_20,
       -- Greater or Equal
       decode('&&is_ver_ge_9_1.'  ,'Y','--','N','') skip_ver_ge_9_1,
       decode('&&is_ver_ge_9_2.'  ,'Y','--','N','') skip_ver_ge_9_2,
       decode('&&is_ver_ge_9.'    ,'Y','--','N','') skip_ver_ge_9,
       decode('&&is_ver_ge_10_1.' ,'Y','--','N','') skip_ver_ge_10_1,
       decode('&&is_ver_ge_10_2.' ,'Y','--','N','') skip_ver_ge_10_2,
       decode('&&is_ver_ge_10.'   ,'Y','--','N','') skip_ver_ge_10,
       decode('&&is_ver_ge_11_1.' ,'Y','--','N','') skip_ver_ge_11_1,
       decode('&&is_ver_ge_11_2.' ,'Y','--','N','') skip_ver_ge_11_2,
       decode('&&is_ver_ge_11.'   ,'Y','--','N','') skip_ver_ge_11,
       decode('&&is_ver_ge_12_1.' ,'Y','--','N','') skip_ver_ge_12_1,
       decode('&&is_ver_ge_12_2.' ,'Y','--','N','') skip_ver_ge_12_2,
       decode('&&is_ver_ge_12.'   ,'Y','--','N','') skip_ver_ge_12,
       decode('&&is_ver_ge_18.'   ,'Y','--','N','') skip_ver_ge_18
       decode('&&is_ver_ge_19.'   ,'Y','--','N','') skip_ver_ge_19
       decode('&&is_ver_ge_20.'   ,'Y','--','N','') skip_ver_ge_20
from   dual;

COL is_ver_le_9_1  clear
COL is_ver_le_9_2  clear
COL is_ver_le_9    clear
COL is_ver_le_10_1 clear
COL is_ver_le_10_2 clear
COL is_ver_le_10   clear
COL is_ver_le_11_1 clear
COL is_ver_le_11_2 clear
COL is_ver_le_11   clear
COL is_ver_le_12_1 clear
COL is_ver_le_12_2 clear
COL is_ver_le_12   clear
COL is_ver_le_18   clear
COL is_ver_le_19   clear
COL is_ver_le_20   clear
--
COL is_ver_ge_9_1  clear
COL is_ver_ge_9_2  clear
COL is_ver_ge_9    clear
COL is_ver_ge_10_1 clear
COL is_ver_ge_10_2 clear
COL is_ver_ge_10   clear
COL is_ver_ge_11_1 clear
COL is_ver_ge_11_2 clear
COL is_ver_ge_11   clear
COL is_ver_ge_12_1 clear
COL is_ver_ge_12_2 clear
COL is_ver_ge_12   clear
COL is_ver_ge_18   clear
COL is_ver_ge_19   clear
COL is_ver_ge_20   clear

COL skip_ver_le_9_1  clear
COL skip_ver_le_9_2  clear
COL skip_ver_le_9    clear
COL skip_ver_le_10_1 clear
COL skip_ver_le_10_2 clear
COL skip_ver_le_10   clear
COL skip_ver_le_11_1 clear
COL skip_ver_le_11_2 clear
COL skip_ver_le_11   clear
COL skip_ver_le_12_1 clear
COL skip_ver_le_12_2 clear
COL skip_ver_le_12   clear
COL skip_ver_le_18   clear
COL skip_ver_le_19   clear
COL skip_ver_le_20   clear
--
COL skip_ver_ge_9_1  clear
COL skip_ver_ge_9_2  clear
COL skip_ver_ge_9    clear
COL skip_ver_ge_10_1 clear
COL skip_ver_ge_10_2 clear
COL skip_ver_ge_10   clear
COL skip_ver_ge_11_1 clear
COL skip_ver_ge_11_2 clear
COL skip_ver_ge_11   clear
COL skip_ver_ge_12_1 clear
COL skip_ver_ge_12_2 clear
COL skip_ver_ge_12   clear
COL skip_ver_ge_18   clear
COL skip_ver_ge_19   clear
COL skip_ver_ge_20   clear

-------------------------------
-- Set is_cdb variable. Result will be 'Y' or 'N'.

COL is_cdb_temp_col new_v is_cdb_temp_col nopri
select DECODE('&&is_ver_ge_12.','Y','CDB','''N''') is_cdb_temp_col from dual;
COL is_cdb_temp_col clear

COL is_cdb new_v is_cdb nopri
select substr(&&is_cdb_temp_col.,1,1) is_cdb from v$database;
COL is_cdb new_v clear

UNDEF is_cdb_temp_col

-------------------------------

COL skip_cdb     new_v skip_cdb     nopri
COL skip_noncdb  new_v skip_noncdb  nopri

select
decode('&&is_cdb.','Y','','N','--') skip_cdb,
decode('&&is_cdb.','Y','--','N','') skip_noncdb
from dual;

COL skip_cdb    clear
COL skip_noncdb clear

-------------------------------