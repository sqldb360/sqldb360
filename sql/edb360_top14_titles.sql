DEF skip_lch = '';
DEF chartype = 'AreaChart';
DEF stacked = 'isStacked: true,';
--DEF vaxis = 'Average Active Sessions AAS (stacked)';
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

/*
SELECT sql_id title_name,
       ROW_NUMBER () OVER (ORDER BY COUNT(*) DESC NULLS LAST) rn,
       COUNT(*) samples
  FROM &&cdb_awr_hist_prefix.active_sess_history h
 WHERE &&filter_predicate.
   AND sql_id IS NOT NULL
   AND snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.
   AND dbid = &&edb360_dbid.
 GROUP BY
       sql_id
*/

SELECT MIN(CASE rn WHEN 01 THEN title_name END) tit_02,
       MIN(CASE rn WHEN 02 THEN title_name END) tit_03,
       MIN(CASE rn WHEN 03 THEN title_name END) tit_04,
       MIN(CASE rn WHEN 04 THEN title_name END) tit_05,
       MIN(CASE rn WHEN 05 THEN title_name END) tit_06,
       MIN(CASE rn WHEN 06 THEN title_name END) tit_07,
       MIN(CASE rn WHEN 07 THEN title_name END) tit_08,
       MIN(CASE rn WHEN 08 THEN title_name END) tit_09,
       MIN(CASE rn WHEN 09 THEN title_name END) tit_10,
       MIN(CASE rn WHEN 10 THEN title_name END) tit_11,
       MIN(CASE rn WHEN 11 THEN title_name END) tit_12,
       MIN(CASE rn WHEN 12 THEN title_name END) tit_13,
       MIN(CASE rn WHEN 13 THEN title_name END) tit_14,
       MIN(CASE rn WHEN 14 THEN title_name END) tit_15
  FROM (&&top14_query.)   
 WHERE rn < 15
/

BEGIN
 :sql_text := REPLACE(REPLACE(:sql_text, '@item_01@', '&&tit_02.'),'@title_01@',NVL(substr('&&tit_02.',1,30),'dummy_02' ));
 :sql_text := REPLACE(REPLACE(:sql_text, '@item_02@', '&&tit_03.'),'@title_02@',NVL(substr('&&tit_03.',1,30),'dummy_03' ));
 :sql_text := REPLACE(REPLACE(:sql_text, '@item_03@', '&&tit_04.'),'@title_03@',NVL(substr('&&tit_04.',1,30),'dummy_04' ));
 :sql_text := REPLACE(REPLACE(:sql_text, '@item_04@', '&&tit_05.'),'@title_04@',NVL(substr('&&tit_05.',1,30),'dummy_05' ));
 :sql_text := REPLACE(REPLACE(:sql_text, '@item_05@', '&&tit_06.'),'@title_05@',NVL(substr('&&tit_06.',1,30),'dummy_06' ));
 :sql_text := REPLACE(REPLACE(:sql_text, '@item_06@', '&&tit_07.'),'@title_06@',NVL(substr('&&tit_07.',1,30),'dummy_07' ));
 :sql_text := REPLACE(REPLACE(:sql_text, '@item_07@', '&&tit_08.'),'@title_07@',NVL(substr('&&tit_08.',1,30),'dummy_08' ));
 :sql_text := REPLACE(REPLACE(:sql_text, '@item_08@', '&&tit_09.'),'@title_08@',NVL(substr('&&tit_09.',1,30),'dummy_09' ));
 :sql_text := REPLACE(REPLACE(:sql_text, '@item_09@', '&&tit_10.'),'@title_09@',NVL(substr('&&tit_10.',1,30),'dummy_10' ));
 :sql_text := REPLACE(REPLACE(:sql_text, '@item_10@', '&&tit_11.'),'@title_10@',NVL(substr('&&tit_11.',1,30),'dummy_11' ));
 :sql_text := REPLACE(REPLACE(:sql_text, '@item_11@', '&&tit_12.'),'@title_11@',NVL(substr('&&tit_12.',1,30),'dummy_12' ));
 :sql_text := REPLACE(REPLACE(:sql_text, '@item_12@', '&&tit_13.'),'@title_12@',NVL(substr('&&tit_13.',1,30),'dummy_13' ));
 :sql_text := REPLACE(REPLACE(:sql_text, '@item_13@', '&&tit_14.'),'@title_13@',NVL(substr('&&tit_14.',1,30),'dummy_14' ));
 :sql_text := REPLACE(REPLACE(:sql_text, '@item_14@', '&&tit_15.'),'@title_14@',NVL(substr('&&tit_15.',1,30),'dummy_15' ));
END;
/

SELECT substr('&&tit_02.',1,30) tit_02,
       substr('&&tit_03.',1,30) tit_03,
       substr('&&tit_04.',1,30) tit_04,
       substr('&&tit_05.',1,30) tit_05,
       substr('&&tit_06.',1,30) tit_06,
       substr('&&tit_07.',1,30) tit_07,
       substr('&&tit_08.',1,30) tit_08,
       substr('&&tit_09.',1,30) tit_09,
       substr('&&tit_10.',1,30) tit_10,
       substr('&&tit_11.',1,30) tit_11,
       substr('&&tit_12.',1,30) tit_12,
       substr('&&tit_13.',1,30) tit_13,
       substr('&&tit_14.',1,30) tit_14,
       substr('&&tit_15.',1,30) tit_15
  FROM DUAL
/


