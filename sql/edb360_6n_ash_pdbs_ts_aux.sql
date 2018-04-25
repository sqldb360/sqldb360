DEF skip_lch = '';
DEF chartype = 'AreaChart';
DEF stacked = 'isStacked: true,';
DEF vaxis = 'Average Active Sessions AAS (stacked)';
DEF vbaseline = '';
DEF tit_01 = 'Others';
DEF tit_02 = '';
DEF tit_03 = '';
DEF tit_04 = '';
DEF tit_05 = '';
DEF tit_06 = '';
DEF tit_07 = '';
DEF tit_08 = '';
DEF tit_09 = '';
DEF tit_10 = '';
DEF tit_11 = '';
DEF tit_12 = '';
DEF tit_13 = '';
DEF tit_14 = '';
DEF tit_15 = '';
DEF title_suffix = '&&between_times.';
DEF cont_01 = '-1';
DEF cont_02 = '-1';
DEF cont_03 = '-1';
DEF cont_04 = '-1';
DEF cont_05 = '-1';
DEF cont_06 = '-1';
DEF cont_07 = '-1';
DEF cont_08 = '-1';
DEF cont_09 = '-1';
DEF cont_10 = '-1';
DEF cont_11 = '-1';
DEF cont_12 = '-1';
DEF cont_13 = '-1';
DEF cont_14 = '-1';
DEF cont_15 = '-1';

WITH
hist AS (
SELECT /*+ &&sq_fact_hints. &&ds_hint. &&ash_hints1. &&ash_hints2. &&ash_hints3. */ 
       /* &&section_id..&&report_sequence. */
       con_id,
       ROW_NUMBER () OVER (ORDER BY COUNT(*) DESC NULLS LAST) rn,
       COUNT(*) samples
  FROM &&awr_object_prefix.active_sess_history h
 WHERE &&filter_predicate.
   AND &&edb360_con_id. < 2
   AND con_id > 1
   AND snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.
   AND dbid = &&edb360_dbid.
 GROUP BY
       con_id
),
hist_agg AS (
SELECT h.rn,
       h.con_id,
       NVL(p.pdb_name, h.con_id) pdb_name,
       h.samples
  FROM hist h,
       &&dva_object_prefix.pdbs p
 WHERE h.rn <= 14
   AND p.pdb_id(+) = h.con_id
)
SELECT NVL(MIN(CASE rn WHEN 01 THEN con_id END), -1) cont_02,
       NVL(MIN(CASE rn WHEN 02 THEN con_id END), -1) cont_03,
       NVL(MIN(CASE rn WHEN 03 THEN con_id END), -1) cont_04,
       NVL(MIN(CASE rn WHEN 04 THEN con_id END), -1) cont_05,
       NVL(MIN(CASE rn WHEN 05 THEN con_id END), -1) cont_06,
       NVL(MIN(CASE rn WHEN 06 THEN con_id END), -1) cont_07,
       NVL(MIN(CASE rn WHEN 07 THEN con_id END), -1) cont_08,
       NVL(MIN(CASE rn WHEN 08 THEN con_id END), -1) cont_09,
       NVL(MIN(CASE rn WHEN 09 THEN con_id END), -1) cont_10,
       NVL(MIN(CASE rn WHEN 10 THEN con_id END), -1) cont_11,
       NVL(MIN(CASE rn WHEN 11 THEN con_id END), -1) cont_12,
       NVL(MIN(CASE rn WHEN 12 THEN con_id END), -1) cont_13,
       NVL(MIN(CASE rn WHEN 13 THEN con_id END), -1) cont_14,
       NVL(MIN(CASE rn WHEN 14 THEN con_id END), -1) cont_15,
       NVL(MIN(CASE rn WHEN 01 THEN pdb_name END), 'PDB_NAME_01') tit_02,
       NVL(MIN(CASE rn WHEN 02 THEN pdb_name END), 'PDB_NAME_02') tit_03,
       NVL(MIN(CASE rn WHEN 03 THEN pdb_name END), 'PDB_NAME_03') tit_04,
       NVL(MIN(CASE rn WHEN 04 THEN pdb_name END), 'PDB_NAME_04') tit_05,
       NVL(MIN(CASE rn WHEN 05 THEN pdb_name END), 'PDB_NAME_05') tit_06,
       NVL(MIN(CASE rn WHEN 06 THEN pdb_name END), 'PDB_NAME_06') tit_07,
       NVL(MIN(CASE rn WHEN 07 THEN pdb_name END), 'PDB_NAME_07') tit_08,
       NVL(MIN(CASE rn WHEN 08 THEN pdb_name END), 'PDB_NAME_08') tit_09,
       NVL(MIN(CASE rn WHEN 09 THEN pdb_name END), 'PDB_NAME_09') tit_10,
       NVL(MIN(CASE rn WHEN 10 THEN pdb_name END), 'PDB_NAME_10') tit_11,
       NVL(MIN(CASE rn WHEN 11 THEN pdb_name END), 'PDB_NAME_11') tit_12,
       NVL(MIN(CASE rn WHEN 12 THEN pdb_name END), 'PDB_NAME_12') tit_13,
       NVL(MIN(CASE rn WHEN 13 THEN pdb_name END), 'PDB_NAME_13') tit_14,
       NVL(MIN(CASE rn WHEN 14 THEN pdb_name END), 'PDB_NAME_14') tit_15
  FROM hist_agg
/

EXEC :sql_text := REPLACE(:sql_text, '@con_id_01@', TRIM('&&cont_02.'));
EXEC :sql_text := REPLACE(:sql_text, '@con_id_02@', TRIM('&&cont_03.'));
EXEC :sql_text := REPLACE(:sql_text, '@con_id_03@', TRIM('&&cont_04.'));
EXEC :sql_text := REPLACE(:sql_text, '@con_id_04@', TRIM('&&cont_05.'));
EXEC :sql_text := REPLACE(:sql_text, '@con_id_05@', TRIM('&&cont_06.'));
EXEC :sql_text := REPLACE(:sql_text, '@con_id_06@', TRIM('&&cont_07.'));
EXEC :sql_text := REPLACE(:sql_text, '@con_id_07@', TRIM('&&cont_08.'));
EXEC :sql_text := REPLACE(:sql_text, '@con_id_08@', TRIM('&&cont_09.'));
EXEC :sql_text := REPLACE(:sql_text, '@con_id_09@', TRIM('&&cont_10.'));
EXEC :sql_text := REPLACE(:sql_text, '@con_id_10@', TRIM('&&cont_11.'));
EXEC :sql_text := REPLACE(:sql_text, '@con_id_11@', TRIM('&&cont_12.'));
EXEC :sql_text := REPLACE(:sql_text, '@con_id_12@', TRIM('&&cont_13.'));
EXEC :sql_text := REPLACE(:sql_text, '@con_id_13@', TRIM('&&cont_14.'));
EXEC :sql_text := REPLACE(:sql_text, '@con_id_14@', TRIM('&&cont_15.'));
--
EXEC :sql_text := REPLACE(:sql_text, '@pdb_name_01@', '&&tit_02.');
EXEC :sql_text := REPLACE(:sql_text, '@pdb_name_02@', '&&tit_03.');
EXEC :sql_text := REPLACE(:sql_text, '@pdb_name_03@', '&&tit_04.');
EXEC :sql_text := REPLACE(:sql_text, '@pdb_name_04@', '&&tit_05.');
EXEC :sql_text := REPLACE(:sql_text, '@pdb_name_05@', '&&tit_06.');
EXEC :sql_text := REPLACE(:sql_text, '@pdb_name_06@', '&&tit_07.');
EXEC :sql_text := REPLACE(:sql_text, '@pdb_name_07@', '&&tit_08.');
EXEC :sql_text := REPLACE(:sql_text, '@pdb_name_08@', '&&tit_09.');
EXEC :sql_text := REPLACE(:sql_text, '@pdb_name_09@', '&&tit_10.');
EXEC :sql_text := REPLACE(:sql_text, '@pdb_name_10@', '&&tit_11.');
EXEC :sql_text := REPLACE(:sql_text, '@pdb_name_11@', '&&tit_12.');
EXEC :sql_text := REPLACE(:sql_text, '@pdb_name_12@', '&&tit_13.');
EXEC :sql_text := REPLACE(:sql_text, '@pdb_name_13@', '&&tit_14.');
EXEC :sql_text := REPLACE(:sql_text, '@pdb_name_14@', '&&tit_15.');
