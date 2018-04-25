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

WITH
hist AS (
SELECT /*+ &&sq_fact_hints. &&ds_hint. &&ash_hints1. &&ash_hints2. &&ash_hints3. */ 
       /* &&section_id..&&report_sequence. */
       sql_id,
       ROW_NUMBER () OVER (ORDER BY COUNT(*) DESC NULLS LAST) rn,
       COUNT(*) samples
  FROM &&awr_object_prefix.active_sess_history h
 WHERE &&filter_predicate.
   AND sql_id IS NOT NULL
   AND snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.
   AND dbid = &&edb360_dbid.
 GROUP BY
       sql_id
)
SELECT NVL(MIN(CASE rn WHEN 01 THEN sql_id END), 'sql_id_01') tit_02,
       NVL(MIN(CASE rn WHEN 02 THEN sql_id END), 'sql_id_02') tit_03,
       NVL(MIN(CASE rn WHEN 03 THEN sql_id END), 'sql_id_03') tit_04,
       NVL(MIN(CASE rn WHEN 04 THEN sql_id END), 'sql_id_04') tit_05,
       NVL(MIN(CASE rn WHEN 05 THEN sql_id END), 'sql_id_05') tit_06,
       NVL(MIN(CASE rn WHEN 06 THEN sql_id END), 'sql_id_06') tit_07,
       NVL(MIN(CASE rn WHEN 07 THEN sql_id END), 'sql_id_07') tit_08,
       NVL(MIN(CASE rn WHEN 08 THEN sql_id END), 'sql_id_08') tit_09,
       NVL(MIN(CASE rn WHEN 09 THEN sql_id END), 'sql_id_09') tit_10,
       NVL(MIN(CASE rn WHEN 10 THEN sql_id END), 'sql_id_10') tit_11,
       NVL(MIN(CASE rn WHEN 11 THEN sql_id END), 'sql_id_11') tit_12,
       NVL(MIN(CASE rn WHEN 12 THEN sql_id END), 'sql_id_12') tit_13,
       NVL(MIN(CASE rn WHEN 13 THEN sql_id END), 'sql_id_13') tit_14,
       NVL(MIN(CASE rn WHEN 14 THEN sql_id END), 'sql_id_14') tit_15
  FROM hist
 WHERE rn < 15
/

EXEC :sql_text := REPLACE(:sql_text, '@sql_id_01@', '&&tit_02.');
EXEC :sql_text := REPLACE(:sql_text, '@sql_id_02@', '&&tit_03.');
EXEC :sql_text := REPLACE(:sql_text, '@sql_id_03@', '&&tit_04.');
EXEC :sql_text := REPLACE(:sql_text, '@sql_id_04@', '&&tit_05.');
EXEC :sql_text := REPLACE(:sql_text, '@sql_id_05@', '&&tit_06.');
EXEC :sql_text := REPLACE(:sql_text, '@sql_id_06@', '&&tit_07.');
EXEC :sql_text := REPLACE(:sql_text, '@sql_id_07@', '&&tit_08.');
EXEC :sql_text := REPLACE(:sql_text, '@sql_id_08@', '&&tit_09.');
EXEC :sql_text := REPLACE(:sql_text, '@sql_id_09@', '&&tit_10.');
EXEC :sql_text := REPLACE(:sql_text, '@sql_id_10@', '&&tit_11.');
EXEC :sql_text := REPLACE(:sql_text, '@sql_id_11@', '&&tit_12.');
EXEC :sql_text := REPLACE(:sql_text, '@sql_id_12@', '&&tit_13.');
EXEC :sql_text := REPLACE(:sql_text, '@sql_id_13@', '&&tit_14.');
EXEC :sql_text := REPLACE(:sql_text, '@sql_id_14@', '&&tit_15.');
