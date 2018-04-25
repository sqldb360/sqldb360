SPO &&one_spool_filename..html APP;
PRO </head>
@sql/sqld360_0d_html_header.sql
PRO <body>
PRO <h1><em>&&sqld360_conf_tool_page.SQLd360</a></em> &&sqld360_vYYNN.: SQL 360-degree view - &&section_id.. Plans Details Page &&sqld360_conf_all_pages_logo.</h1>
PRO
PRO <pre>
PRO sqlid:&&sqld360_sqlid. dbname:&&database_name_short. version:&&db_version. host:&&host_hash. license:&&license_pack. days:&&history_days. today:&&sqld360_time_stamp.
PRO </pre>
PRO

PRO <table><tr class="main">


SET ECHO OFF FEEDBACK OFF TIMING OFF 
SET SERVEROUT ON SIZE 1000000;
SET SERVEROUT ON SIZE UNLIMITED;

EXEC :repo_seq := 1;


-- The following code sucks but it's the only "easy" (aka not spending too much time computing it) workaround for those 
--  systems where the same SQL ID has hundreds of PHV, we only provide deeper info for the top sqld360_num_plan_details by amount of data
--  Each row in GV$SQL, DBA_HIST counts 1 towards the total, each row in ASH counts 0.5 (so this approach still favors ASH a bit over GV$SQL / DBA_HIST)
DELETE plan_table WHERE statement_id = 'SQLD360_PLANS' AND remarks = '&&sqld360_sqlid.';
INSERT INTO plan_table (statement_id, remarks, /*cost*/ bytes, cardinality) 
SELECT 'SQLD360_PLANS', '&&sqld360_sqlid.', plan_hash_value, num_plans
  FROM (SELECT plan_hash_value, ROWNUM num_plans
          FROM (SELECT SUM(num_rows) rows_per_phv, plan_hash_value
                  FROM (SELECT COUNT(*) num_rows, plan_hash_value
                          FROM gv$sql
                         WHERE sql_id = '&&sqld360_sqlid.'
                         GROUP BY plan_hash_value
                        UNION ALL
                        SELECT COUNT(*) num_rows, plan_hash_value
                          FROM dba_hist_sqlstat
                         WHERE sql_id = '&&sqld360_sqlid.'
                           AND '&&diagnostics_pack.' = 'Y'
                         GROUP BY plan_hash_value
                        UNION ALL
                        SELECT SUM(0.5) num_rows, /*cost*/ bytes plan_hash_value
                          FROM plan_table
                         WHERE statement_id LIKE 'SQLD360_ASH_DATA%'
                           AND '&&diagnostics_pack.' = 'Y'
                           AND remarks = '&&sqld360_sqlid.'
                         GROUP BY /*cost*/ bytes) 
                 GROUP BY plan_hash_value
                 ORDER BY 1 DESC)
         --WHERE ('&&sqld360_is_insert.' IS NULL AND plan_hash_value <> 0) OR ('&&sqld360_is_insert.' = 'Y')
        )
 WHERE num_plans <= &&sqld360_num_plan_details.;

BEGIN
  FOR i IN (SELECT /*cost*/ bytes plan_hash_value
              FROM plan_table
             WHERE statement_id = 'SQLD360_PLANS'
               AND remarks = '&&sqld360_sqlid.'
             ORDER BY cardinality)
  LOOP
    DBMS_OUTPUT.PUT_LINE('<td class="c">PHV '||i.plan_hash_value||'</td>');
  END LOOP;
END;
/

PRO </tr><tr class="main">
SPO OFF

-- this is to trick sqld360_9a_pre
DEF sqld360_main_report_bck = &&sqld360_main_report.
DEF sqld360_main_report = &&one_spool_filename.

-- reset the sequence since this is a different page
EXEC :repo_seq := 1;
SELECT TO_CHAR(:repo_seq) report_sequence FROM DUAL;

SET SERVEROUT ON SIZE 1000000;
SET SERVEROUT ON SIZE UNLIMITED;
SPO sqld360_plans_analysis_&&sqld360_sqlid._driver.sql

DECLARE
  PROCEDURE put (p_line IN VARCHAR2)
  IS
  BEGIN
    DBMS_OUTPUT.PUT_LINE(p_line);
  END put;
BEGIN

-- this is intentional, showing all the tables including the ones with no histograms
-- so it's easier to spot the ones with no histograms too
  FOR i IN (SELECT /*cost*/ bytes plan_hash_value
              FROM plan_table
             WHERE statement_id = 'SQLD360_PLANS'
               AND remarks = '&&sqld360_sqlid.'
             ORDER BY cardinality)
  LOOP
    put('SET PAGES 50000                     ');
    put('SPO &&sqld360_main_report..html APP;');
    put('PRO <td>                            ');
    put('SPO OFF                             ');

    put('SPO &&one_spool_filename..html APP;');
    put('PRO <h2>Execution Plan</h2>        ');
    put('SET DEF @                          ');
    put('PRO <ol start="@report_sequence."> ');
    put('SET DEF &                          ');
    put('SPO OFF                            ');

    put(q'[DEF bubbleMaxValue = ''                                                            ]');
    put(q'[COL bubbleMaxValue NEW_V bubbleMaxValue                                            ]');
    -- this is to make the chart a little larger
    put(q'[SELECT NVL2(MAX(id), 'maxValue:'||TO_CHAR(MAX(id)+2)||',' , '') bubbleMaxValue     ]');
    put(q'[  FROM (SELECT MAX(id) id                                                          ]');
    put(q'[          FROM gv$sql_plan                                                         ]');
    put(q'[         WHERE sql_id = '&&sqld360_sqlid.'                                         ]');
    put(q'[           AND plan_hash_value =]'||i.plan_hash_value                                );
    put(q'[        UNION ALL                                                                  ]');
    put(q'[        SELECT MAX(id) id                                                          ]');
    put(q'[          FROM dba_hist_sql_plan                                                   ]');
    put(q'[         WHERE sql_id = '&&sqld360_sqlid.'                                         ]');
    put(q'[           AND plan_hash_value = ]'||i.plan_hash_value                               );
    put(q'[           AND '&&diagnostics_pack.' = 'Y');                                       ]');

    put('----------------------------');

    -- there is a slim risk of counting a sample twice (one more memory and one from history), ok for now
    put('COL treeColor NEW_V treeColor');
    
    -- not the most elegant soluton but SQL*Plus variable cannot store long string (aka long exec plans)
    put('DELETE plan_table WHERE statement_id = ''SQLD360_TREECOLOR'' AND operation = ''&&sqld360_sqlid.''; ');
    put(q'[INSERT ALL                                                                                                                                                                           ]');
    put(q'[  WHEN 1 = 1 THEN INTO plan_table (statement_id, OPERATION, OPTIONS) VALUES ('SQLD360_TREECOLOR', '&&sqld360_sqlid.', node_color)                                                    ]');
    put(q'[  WHEN 1 = 1 THEN INTO plan_table (statement_id, OPERATION, OPTIONS) VALUES ('SQLD360_TREECOLOR', '&&sqld360_sqlid.', expanded_node_color)                                           ]');
    put(q'[  WHEN 1 = 1 THEN INTO plan_table (statement_id, OPERATION, OPTIONS) VALUES ('SQLD360_TREECOLOR', '&&sqld360_sqlid.', collapsed_node_color)                                          ]');
    put(q'[WITH ashdata AS (-- count the number of samples in ASH for each step                                                                                                                 ]');
    put(q'[                 -- goal is to compute RATIO_TO_REPORT                                                                                                                               ]');
    put(q'[                 SELECT NVL(id,0) id,                                                                                                                                                ]');
    put(q'[                        COUNT(*) num_samples,                                                                                                                                        ]');
    put(q'[                        ROUND(100*NVL(RATIO_TO_REPORT(COUNT(*)) OVER (),0),2) perc_impact                                                                                            ]');
    put(q'[                   FROM plan_table                                                                                                                                                   ]');
    put(q'[                  WHERE statement_id LIKE 'SQLD360_ASH_DATA%'                                                                                                                        ]');
    put(q'[                    AND /*cost*/ bytes =]'|| i.plan_hash_value                                                                                                                         );   
    put(q'[                    AND remarks = '&&sqld360_sqlid.'                                                                                                                                 ]'); 
    put(q'[                  GROUP BY NVL(id,0)),                                                                                                                                               ]');
    put(q'[     orig_plan AS (-- extract the plan steps "as is", just replace to single quote in the filter predicates                                                                          ]');
    put(q'[                   -- precedence is given to plan from memory since it has filters                                                                                                   ]');
    put(q'[                   -- using RANK since there could be more than one entry but with different predicate ordering                                                                      ]');
    put(q'[                   SELECT sql_id, plan_hash_value, id, parent_id, operation, options, object_name, access_predicates, filter_predicates, other_xml                                   ]');
    put(q'[                     FROM (SELECT sql_id, plan_hash_value, id, parent_id, operation, options, object_name,                                                                           ]');
    put(q'[                                  REPLACE(SUBSTR(access_predicates,1,1500), CHR(39) , CHR(92)||CHR(39)) access_predicates,                                                           ]');
    put(q'[                                  REPLACE(SUBSTR(filter_predicates,1,1500), CHR(39) , CHR(92)||CHR(39)) filter_predicates,                                                           ]');
    put(q'[                                  other_xml,                                                                                                                                         ]');
    put(q'[                                  RANK() OVER (ORDER BY inst_id, child_number) rnk                                                                                                   ]');
    put(q'[                             FROM gv$sql_plan_statistics_all                                                                                                                         ]');
    put(q'[                            WHERE sql_id = '&&sqld360_sqlid.'                                                                                                                        ]');            
    put(q'[                              AND plan_hash_value =]'||i.plan_hash_value||q'[)                                                                                                       ]');                                                             
    put(q'[                    WHERE rnk = 1                                                                                                                                                    ]');
    put(q'[                   UNION ALL                                                                                                                                                         ]');
    put(q'[                   SELECT sql_id, plan_hash_value, id, parent_id, operation, options, object_name,                                                                                   ]');
    put(q'[                          REPLACE(access_predicates, CHR(39), CHR(92)||CHR(39)) access_predicates,                                                                                   ]');
    put(q'[                          REPLACE(filter_predicates, CHR(39), CHR(92)||CHR(39)) filter_predicates,                                                                                   ]');
    put(q'[                          other_xml                                                                                                                                                  ]');
    put(q'[                     FROM dba_hist_sql_plan                                                                                                                                          ]');
    put(q'[                    WHERE sql_id = '&&sqld360_sqlid.'                                                                                                                                ]');
    put(q'[                      AND plan_hash_value =]'||i.plan_hash_value                                                                                                                       );
    put(q'[                      AND NOT EXISTS (SELECT 1                                                                                                                                       ]');  
    put(q'[                                        FROM gv$sql_plan_statistics_all                                                                                                              ]');
    put(q'[                                       WHERE plan_hash_value =]'||i.plan_hash_value                                                                                                    );
    put(q'[                                         AND sql_id = '&&sqld360_sqlid.'                                                                                                             ]');
    put(q'[                                         AND '&&diagnostics_pack.' = 'Y')),                                                                                                          ]');
    put(q'[     skip_steps AS (-- extract the display_map for the plan, to identify why steps are "skipped" because of adaptive                                                                 ]');
    put(q'[                    SELECT sql_id, plan_hash_value, EXTRACTVALUE(VALUE(b),'/row/@op') stepid, EXTRACTVALUE(VALUE(b),'/row/@skp') skp, EXTRACTVALUE(VALUE(b),'/row/@dep') dep         ]');
    put(q'[                      FROM orig_plan a,                                                                                                                                              ]');
    put(q'[                           TABLE(XMLSEQUENCE(EXTRACT(XMLTYPE(a.other_xml),'/*/display_map/row'))) b                                                                                  ]');
    put(q'[                     WHERE sql_id = '&&sqld360_sqlid.'                                                                                                                               ]'); 
    put(q'[                       AND other_xml IS NOT NULL),                                                                                                                                   ]');
    put(q'[     adapt_plan_no_parent AS (-- generate adaptive_id (aka step_id) once the adaptive steps are excluded                                                                             ]');
    put(q'[                              SELECT a.sql_id, a.plan_hash_value, a.id, a.parent_id, b.dep,                                                                                          ]');
    put(q'[                                     (ROW_NUMBER() OVER (ORDER BY a.id))-1 adapt_id, a.operation, a.options, a.object_name, a.access_predicates, a.filter_predicates, b.skp          ]');
    put(q'[                                FROM orig_plan a,                                                                                                                                    ]');
    put(q'[                                     skip_steps b                                                                                                                                    ]');
    put(q'[                               WHERE a.id = b.stepid(+)                                                                                                                              ]');
    put(q'[                                 AND (b.skp = 0 OR b.skp IS NULL)),                                                                                                                  ]');
    put(q'[     full_adaptive_plan AS (-- generate the parent adaptive step id                                                                                                                  ]');
    put(q'[                            SELECT id, adapt_id, NVL(adapt_parent_id, parent_id) parent_id, operation, options, object_name, access_predicates, filter_predicates                    ]');
    put(q'[                              FROM (SELECT dep, adapt_id, id, (SELECT MAX(adapt_id) FROM adapt_plan_no_parent b WHERE a.dep-1 = NVL(b.dep,0) AND b.adapt_id < a.adapt_id ) adapt_parent_id, ]');
    put(q'[                                           parent_id, a.operation operation, a.options, a.object_name, a.access_predicates, a.filter_predicates                                      ]');
    put(q'[                                      FROM adapt_plan_no_parent a)),                                                                                                                 ]');
    put(q'[     plan_with_ash AS (SELECT full_adaptive_plan.*, NVL(ashdata.num_samples,0) num_samples, NVL(ashdata.perc_impact,0) perc_impact                                                   ]');
    put(q'[                              FROM full_adaptive_plan,                                                                                                                               ]');
    put(q'[                                   ashdata                                                                                                                                           ]');
    put(q'[                             WHERE ashdata.id(+) = full_adaptive_plan.id),                                                                                                           ]');
    put(q'[     plan_with_rec_impact AS (-- compute recursive impact (substree impact)                                                                                                          ]');
    put(q'[                              SELECT a.*, (SELECT sum(b.perc_impact)                                                                                                                 ]');
    put(q'[                                             FROM plan_with_ash b                                                                                                                    ]');
    put(q'[                                            START WITH b.adapt_id = a.adapt_id                                                                                                                   ]');
    put(q'[                                           CONNECT BY prior b.adapt_id = b.parent_id) sum_perc_impact                                                                                      ]');
    put(q'[                                FROM plan_with_ash a)                                                                                                                                ]');                                                                                  
    put(q'[SELECT adapt_id id,                                                                                                                                                                  ]');
    put(q'[       'data.setRowProperty('||adapt_id||', ''style'',          ''background:#FF'||LPAD(LTRIM(TO_CHAR(255-(255*perc_impact    /100),'XXXX')),2,'0')||CASE WHEN perc_impact = 0 THEN 'FF' ELSE '00' END||''');' node_color,               ]');
    put(q'[       'data.setRowProperty('||adapt_id||', ''expandedStyle'',  ''background:#FF'||LPAD(LTRIM(TO_CHAR(255-(255*perc_impact    /100),'XXXX')),2,'0')||CASE WHEN perc_impact = 0 THEN 'FF' ELSE '00' END||''');' expanded_node_color,      ]');
    put(q'[       'data.setRowProperty('||adapt_id||', ''collapsedStyle'', ''background:#FF'||LPAD(LTRIM(TO_CHAR(255-(255*sum_perc_impact/100),'XXXX')),2,'0')||CASE WHEN sum_perc_impact = 0 THEN 'FF' ELSE '00' END||''');' collapsed_node_color  ]');  
    put(q'[  FROM plan_with_rec_impact                                                                                                                                                          ]');
    put(q'[ ORDER BY adapt_id;                                                                                                                                                                  ]'); 

    -- new in 1703
    put(q'[DEF title='Plan Tree for PHV ]'||i.plan_hash_value||q'[ with subtree']');
    put(q'[DEF main_table = 'DBA_HIST_SQL_PLAN']');
    put(q'[DEF skip_html='Y' ]');
    put(q'[DEF skip_text='Y' ]');
    put(q'[DEF skip_csv='Y'  ]');
    put(q'[DEF skip_tch=''   ]');

    put( 'BEGIN');
    put(q'[ :sql_text := ' ]');
    put(q'[WITH ashdata AS (-- count the number of samples in ASH for each step                                                                                                                 ]');
    put(q'[                 -- goal is to compute RATIO_TO_REPORT                                                                                                                               ]');
    put(q'[                 SELECT NVL(id,0) id,                                                                                                                                                ]');
    put(q'[                        COUNT(*) num_samples,                                                                                                                                        ]');
    put(q'[                        ROUND(100*NVL(RATIO_TO_REPORT(COUNT(*)) OVER (),0),2) perc_impact                                                                                            ]');
    put(q'[                   FROM plan_table                                                                                                                                                   ]');
    put(q'[                  WHERE statement_id LIKE ''SQLD360_ASH_DATA%''                                                                                                                      ]');
    put(q'[                    AND /*cost*/ bytes =]'|| i.plan_hash_value                                                                                                                         );   
    put(q'[                    AND remarks = ''&&sqld360_sqlid.''                                                                                                                               ]'); 
    put(q'[                  GROUP BY NVL(id,0)),                                                                                                                                               ]');
    put(q'[     orig_plan AS (-- extract the plan steps "as is", just replace to single quote in the filter predicates                                                                          ]');
    put(q'[                   -- precedence is given to plan from memory since it has filters                                                                                                   ]');
    put(q'[                   -- using RANK since there could be more than one entry but with different predicate ordering                                                                      ]');
    put(q'[                   SELECT sql_id, plan_hash_value, id, parent_id, operation, options, object_name, access_predicates, filter_predicates, other_xml                                   ]');
    put(q'[                     FROM (SELECT sql_id, plan_hash_value, id, parent_id, operation, options, object_name,                                                                           ]');
    put(q'[                                  REPLACE(SUBSTR(access_predicates,1,1500), CHR(39) , CHR(92)||CHR(39)) access_predicates,                                                           ]');
    put(q'[                                  REPLACE(SUBSTR(filter_predicates,1,1500), CHR(39) , CHR(92)||CHR(39)) filter_predicates,                                                           ]');
    put(q'[                                  other_xml,                                                                                                                                         ]');
    put(q'[                                  RANK() OVER (ORDER BY inst_id, child_number) rnk                                                                                                   ]');
    put(q'[                             FROM gv$sql_plan_statistics_all                                                                                                                         ]');
    put(q'[                            WHERE sql_id = ''&&sqld360_sqlid.''                                                                                                                      ]');            
    put(q'[                              AND plan_hash_value =]'||i.plan_hash_value||q'[)                                                                                                       ]');                                                             
    put(q'[                    WHERE rnk = 1                                                                                                                                                    ]');
    put(q'[                   UNION ALL                                                                                                                                                         ]');
    put(q'[                   SELECT sql_id, plan_hash_value, id, parent_id, operation, options, object_name,                                                                                   ]');
    put(q'[                          REPLACE(access_predicates, CHR(39), CHR(92)||CHR(39)) access_predicates,                                                                                   ]');
    put(q'[                          REPLACE(filter_predicates, CHR(39), CHR(92)||CHR(39)) filter_predicates,                                                                                   ]');
    put(q'[                          other_xml                                                                                                                                                  ]');
    put(q'[                     FROM dba_hist_sql_plan                                                                                                                                          ]');
    put(q'[                    WHERE sql_id = ''&&sqld360_sqlid.''                                                                                                                              ]');
    put(q'[                      AND plan_hash_value =]'||i.plan_hash_value                                                                                                                       );
    put(q'[                      AND NOT EXISTS (SELECT 1                                                                                                                                       ]');  
    put(q'[                                        FROM gv$sql_plan_statistics_all                                                                                                              ]');
    put(q'[                                       WHERE plan_hash_value =]'||i.plan_hash_value                                                                                                    );
    put(q'[                                         AND sql_id = ''&&sqld360_sqlid.''                                                                                                           ]');
    put(q'[                                         AND ''&&diagnostics_pack.'' = ''Y'')),                                                                                                      ]');
    put(q'[     skip_steps AS (-- extract the display_map for the plan, to identify why steps are "skipped" because of adaptive                                                                 ]');
    put(q'[                    SELECT sql_id, plan_hash_value, EXTRACTVALUE(VALUE(b),''/row/@op'') stepid, EXTRACTVALUE(VALUE(b),''/row/@skp'') skp, EXTRACTVALUE(VALUE(b),''/row/@dep'') dep   ]');
    put(q'[                      FROM orig_plan a,                                                                                                                                              ]');
    put(q'[                           TABLE(XMLSEQUENCE(EXTRACT(XMLTYPE(a.other_xml),''/*/display_map/row''))) b                                                                                ]');
    put(q'[                     WHERE sql_id = ''&&sqld360_sqlid.''                                                                                                                             ]'); 
    put(q'[                       AND other_xml IS NOT NULL),                                                                                                                                   ]');
    put(q'[     adapt_plan_no_parent AS (-- generate adaptive_id (aka step_id) once the adaptive steps are excluded                                                                             ]');
    put(q'[                              SELECT a.sql_id, a.plan_hash_value, a.id, a.parent_id, b.dep,                                                                                          ]');
    put(q'[                                     (ROW_NUMBER() OVER (ORDER BY a.id))-1 adapt_id, a.operation, a.options, a.object_name, a.access_predicates, a.filter_predicates, b.skp          ]');
    put(q'[                                FROM orig_plan a,                                                                                                                                    ]');
    put(q'[                                     skip_steps b                                                                                                                                    ]');
    put(q'[                               WHERE a.id = b.stepid(+)                                                                                                                              ]');
    put(q'[                                 AND (b.skp = 0 OR b.skp IS NULL)),                                                                                                                  ]');
    put(q'[     full_adaptive_plan AS (-- generate the parent adaptive step id                                                                                                                  ]');
    put(q'[                            SELECT id, adapt_id, NVL(adapt_parent_id, parent_id) parent_id, operation, options, object_name, access_predicates, filter_predicates                    ]');
    put(q'[                              FROM (SELECT dep, adapt_id, id, (SELECT MAX(adapt_id) FROM adapt_plan_no_parent b WHERE a.dep-1 = NVL(b.dep,0) AND b.adapt_id < a.adapt_id ) adapt_parent_id, ]');
    put(q'[                                           parent_id, a.operation operation, a.options, a.object_name, a.access_predicates, a.filter_predicates                                      ]');
    put(q'[                                      FROM adapt_plan_no_parent a)),                                                                                                                 ]');
    put(q'[     plan_with_ash AS (SELECT full_adaptive_plan.*, NVL(ashdata.num_samples,0) num_samples, NVL(ashdata.perc_impact,0) perc_impact                                                   ]');
    put(q'[                              FROM full_adaptive_plan,                                                                                                                               ]');
    put(q'[                                   ashdata                                                                                                                                           ]');
    put(q'[                             WHERE ashdata.id(+) = full_adaptive_plan.id),                                                                                                           ]');
    put(q'[     plan_with_rec_impact AS (-- compute recursive impact (substree impact)                                                                                                          ]');
    put(q'[                              SELECT a.*, (SELECT sum(b.perc_impact)                                                                                                                 ]');
    put(q'[                                             FROM plan_with_ash b                                                                                                                    ]');
    put(q'[                                            START WITH b.adapt_id = a.adapt_id                                                                                                                   ]');
    put(q'[                                           CONNECT BY prior b.adapt_id = b.parent_id) sum_perc_impact                                                                                      ]');
    put(q'[                                FROM plan_with_ash a)                                                                                                                                ]');                                                                                  
    put(q'[SELECT ''{v: ''''''||adapt_id||'''''',f: ''''''||adapt_id||'' - ''||operation||'' ''||options||NVL2(object_name,''<br>'','' '')||object_name||''''''}'' id,                          ]'); 
    put(q'[       parent_id,                                                                                                                                                                    ]');
    put(q'[       SUBSTR(''Step ID: ''||adapt_id||'' (ASH Step ID: ''||id||'')\nASH Samples: ''||num_samples||'' (''||perc_impact||''%)''||                                                     ]');
    put(q'[       ''\nSubstree Impact ''||sum_perc_impact||''%''||                                                                                                                              ]');
    put(q'[       NVL2(access_predicates,''\n\nAccess Predicates: ''||access_predicates,'''')||NVL2(filter_predicates,''\n\nFilter Predicates: ''||filter_predicates,''''),1,4000) message,     ]');
    put(q'[       adapt_id id3                                                                                                                                                                  ]');
    put(q'[  FROM plan_with_rec_impact                                                                                                                                                          ]');
    put(q'[ ORDER BY id3                                                                                                                                                                        ]'); 
    put(''';');
    put('END;');
    put('/ ');
    put('@sql/sqld360_9a_pre_one.sql');

    put('----------------------------');

    put(q'[DEF title = 'Plan from Memory for PHV ]'||i.plan_hash_value||q'[' ]');
    put(q'[DEF main_table = 'GV$SQL_PLAN_STATISTICS_ALL'                     ]');
    put(q'[@sql/sqld360_0s_pre_nondef                                        ]');
    put(q'[SET DEF @                                                         ]');
    put(q'[SPO @@one_spool_filename..txt;                                    ]');
    put(q'[PRO @@title.@@title_suffix. (@@main_table.)                       ]');
    put(q'[PRO @@abstract.                                                   ]');
    put(q'[PRO @@abstract2.                                                  ]');

    put(q'[COL inst_child FOR A21;                                           ]');
    put(q'[BREAK ON inst_child SKIP 2;                                       ]');
    put(q'[SET PAGES 0;                                                      ]');

    put('WITH v AS (                                                          ');
    put('SELECT /*+ MATERIALIZE */                                            ');
    put('       DISTINCT sql_id, inst_id, child_number, child_address         ');
    put('  FROM gv$sql                                                        ');
    put(' WHERE sql_id = ''&&sqld360_sqlid.''                                 ');
    put('   AND plan_hash_value = '||i.plan_hash_value                         );
    put('   AND loaded_versions > 0                                           ');
    put('   AND is_obsolete = ''N''                                           ');
    put(' ORDER BY 1, 2, 3 )                                                  ');
    put('SELECT /*+ ORDERED USE_NL(t) */                                      ');
    put('       RPAD(''Inst: ''||v.inst_id, 9)||'' ''||RPAD(''Child: ''||v.child_number, 11) inst_child,'); 
    put('       t.plan_table_output                                           ');
    put('  FROM v, TABLE(DBMS_XPLAN.DISPLAY(''gv$sql_plan_statistics_all'', NULL, ''ADVANCED ALLSTATS LAST'','); 
    put('       ''inst_id=''||v.inst_id||'' AND sql_id=''''''||v.sql_id||'''''' AND plan_hash_value='|| i.plan_hash_value||' AND child_number=''||v.child_number||'' AND child_address=''''''||v.child_address||'''''''')) t ');
    put('/');

    put('SET TERM ON                                                                         ');
    put('-- get current time                                                                 ');
    put('SPO &&sqld360_log..txt APP;                                                         ');
    put('COL current_time NEW_V current_time FOR A15;                                        ');
    put('SELECT ''Completed: '' x, TO_CHAR(SYSDATE, ''HH24:MI:SS'') current_time FROM DUAL;  ');
    put('SET TERM OFF                                                                        ');
    put('HOS zip -q &&sqld360_main_filename._&&sqld360_file_time. &&sqld360_log..txt         ');

    put('-- update main report                                                               ');
    put('SPO &&sqld360_main_report..html APP;                                                ');
    put('PRO <li title="@@main_table.">@@title.                                              ');
    put('PRO <a href="@@one_spool_filename..txt">text</a>                                    ');
    put('SPO OFF;                                                                            ');
    put('HOS zip -mq &&sqld360_main_filename._&&sqld360_file_time. @@one_spool_filename..txt ');
    put('HOS zip -q &&sqld360_main_filename._&&sqld360_file_time. &&sqld360_main_report..html');
    put('-- update main report                                                               ');
    put('SPO &&sqld360_main_report..html APP;                                                ');
    put('PRO </li>                                                                           ');
    put('SPO OFF;                                                                            ');
    put('HOS zip -q &&sqld360_main_filename._&&sqld360_file_time. &&sqld360_main_report..html');
    put('SET DEF &                                                                           ');

    put('----------------------------');

    put(q'[DEF title = 'Plan from History for PHV ]'||i.plan_hash_value||q'[' ]');
    put(q'[DEF main_table = 'DBA_HIST_SQL_PLAN'                               ]');
    put(q'[@sql/sqld360_0s_pre_nondef                                         ]');
    put(q'[SET DEF @                                                          ]');
    put(q'[SPO @@one_spool_filename..txt;                                     ]');
    put(q'[PRO @@title.@@title_suffix. (@@main_table.)                        ]');
    put(q'[PRO @@abstract.                                                    ]');
    put(q'[PRO @@abstract2.                                                   ]');

    put('COL inst_child FOR A21;                                               ');
    put('BREAK ON inst_child SKIP 2;                                           ');
    put('SET PAGES 0;                                                          ');

    put('WITH v AS (                                                           ');
    put('SELECT /*+ MATERIALIZE */                                             ');
    put('       DISTINCT sql_id, plan_hash_value, dbid                         ');
    put('  FROM dba_hist_sql_plan                                              ');
    put(' WHERE ''&&diagnostics_pack.'' = ''Y''                                ');
    put('   AND dbid = ''&&sqld360_dbid.''                                     ');
    put('   AND sql_id = ''&&sqld360_sqlid.''                                  ');
    put('   AND plan_hash_value = '||i.plan_hash_value                          );
    put(' ORDER BY 1, 2, 3 )                                                   ');
    put('SELECT /*+ ORDERED USE_NL(t) */ t.plan_table_output                   ');
    put('  FROM v, TABLE(DBMS_XPLAN.DISPLAY_AWR(v.sql_id, v.plan_hash_value, v.dbid, ''ADVANCED'')) t;');

    put('SET TERM ON                                                           ');
    put('-- get current time                                                   ');
    put('SPO &&sqld360_log..txt APP;                                           ');
    put('COL current_time NEW_V current_time FOR A15;                          ');
    put('SELECT ''Completed: '' x, TO_CHAR(SYSDATE, ''HH24:MI:SS'') current_time FROM DUAL;');
    put('SET TERM OFF                                                          ');
    put('HOS zip -q &&sqld360_main_filename._&&sqld360_file_time. &&sqld360_log..txt       ');

    put('-- update main report                                                               ');
    put('SPO &&sqld360_main_report..html APP;                                                ');
    put('PRO <li title="@@main_table.">@@title.                                              ');
    put('PRO <a href="@@one_spool_filename..txt">text</a>                                    ');
    put('SPO OFF;                                                                            ');
    put('HOS zip -mq &&sqld360_main_filename._&&sqld360_file_time. @@one_spool_filename..txt ');
    put('HOS zip -q &&sqld360_main_filename._&&sqld360_file_time. &&sqld360_main_report..html');
    put('-- update main report                                                               ');
    put('SPO &&sqld360_main_report..html APP;                                                ');
    put('PRO </li>                                                                           ');
    put('SPO OFF;                                                                            ');
    put('HOS zip -q &&sqld360_main_filename._&&sqld360_file_time. &&sqld360_main_report..html');  
    put('SET DEF &                                                                           ');

    put('----------------------------');

    -- this is to take care of the sequencing for the file after calling raw text spooling
    put('EXEC repo_seq := repo_seq + 2;');
    put('SELECT TO_CHAR(:repo_seq) report_sequence FROM DUAL;');

    put('----------------------------');

    put('SPO &&one_spool_filename..html APP;');
    put('PRO </ol>                          ');
    put('PRO <h2>Elapsed Time</h2>          ');
    put('SET DEF @                          ');
    put('PRO <ol start="@report_sequence."> ');
    put('SET DEF &                          ');
    put('SPO OFF                            ');
    put('SET PAGES &&def_max_rows.          ');

    put(q'[DEF title='Avg et/exec for recent execs for PHV ]'||i.plan_hash_value||q'[' ]');
    put(q'[DEF main_table = 'GV$ACTIVE_SESSION_HISTORY'                                ]');
    put(q'[DEF skip_lch=''                                                             ]');
    put(q'[DEF chartype = 'LineChart'                                                  ]');
    put(q'[DEF stacked = ''                                                            ]');
    put(q'[DEF vaxis = 'Elapsed Time in secs'                                          ]');
    put(q'[DEF tit_01 = 'Average Elapsed Time/exec'                                    ]');
    put(q'[DEF tit_02 = 'Average Time on CPU/exec'                                     ]');
    put(q'[DEF tit_03 = 'Average DB Time/exec'                                         ]');
    put(q'[DEF tit_04 = 'Min Elapsed Time/exec'                                        ]');
    put(q'[DEF tit_05 = 'Max Elapsed Time/exec'                                        ]');
    put(q'[DEF tit_06 = 'Average Elapsed Time/exec Trend'                              ]');
    put(q'[DEF tit_07 = ''                                                             ]');
    put(q'[DEF tit_08 = ''                                                             ]');
    put(q'[DEF tit_09 = ''                                                             ]');
    put(q'[DEF tit_10 = ''                                                             ]');
    put(q'[DEF tit_11 = ''                                                             ]');
    put(q'[DEF tit_12 = ''                                                             ]');
    put(q'[DEF tit_13 = ''                                                             ]');
    put(q'[DEF tit_14 = ''                                                             ]');
    put(q'[DEF tit_15 = ''                                                             ]');
    put(q'[BEGIN                                                                       ]');
    put(q'[ :sql_text := '                                                             ]');
    put(q'[SELECT 0 snap_id,                                                                                            ]');
    put(q'[       TO_CHAR(start_time, ''YYYY-MM-DD HH24:MI'') begin_time,                                               ]'); 
    put(q'[       TO_CHAR(start_time, ''YYYY-MM-DD HH24:MI'') end_time,                                                 ]');
    put(q'[       avg_et,                                                                                               ]');
    put(q'[       avg_cpu_time,                                                                                         ]');
    put(q'[       avg_db_time,                                                                                          ]');
    put(q'[       min_et,                                                                                               ]');
    put(q'[       max_et,                                                                                               ]');
    put(q'[       AVG(avg_et) OVER (ORDER BY start_time ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) avg_et_trend, ]');
    put(q'[       0 dummy_07,                                                                                           ]');
    put(q'[       0 dummy_08,                                                                                           ]');
    put(q'[       0 dummy_09,                                                                                           ]');
    put(q'[       0 dummy_10,                                                                                           ]');
    put(q'[       0 dummy_11,                                                                                           ]');
    put(q'[       0 dummy_12,                                                                                           ]');
    put(q'[       0 dummy_13,                                                                                           ]');
    put(q'[       0 dummy_14,                                                                                           ]');
    put(q'[       0 dummy_15                                                                                            ]');
    put(q'[  FROM (SELECT start_time,                                                                                   ]');
    put(q'[               TRUNC(AVG(et),2) avg_et,                                                                      ]');
    put(q'[               TRUNC(AVG(cpu_time),2) avg_cpu_time,                                                          ]');
    put(q'[               TRUNC(AVG(db_time),2) avg_db_time,                                                            ]');
    put(q'[               TRUNC(MIN(et),2) min_et,                                                                      ]');
    put(q'[               TRUNC(MAX(et),2) max_et                                                                       ]');
    put(q'[          FROM (SELECT TO_DATE(SUBSTR(distribution,1,12),''YYYYMMDDHH24MI'') start_time,                     ]');
    put(q'[                       NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'','',1,3)+1,INSTR(partition_stop,'','',1,4)-INSTR(partition_stop,'','',1,3)-1)),position)||''-''||  ]'); 
    put(q'[                        NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'','',1,4)+1,INSTR(partition_stop,'','',1,5)-INSTR(partition_stop,'','',1,4)-1)),cpu_cost)||''-''|| ]'); 
    put(q'[                        NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'','',1,5)+1,INSTR(partition_stop,'','',1,6)-INSTR(partition_stop,'','',1,5)-1)),io_cost)||''-''||  ]');
    put(q'[                        NVL(partition_id,0)||''-''||NVL(distribution,''x'') uniq_exec,                       ]'); 
    put(q'[                       &&sqld360_ashsample.+86400*(MAX(timestamp)-MIN(timestamp)) et,                        ]'); 
    put(q'[                       SUM(CASE WHEN object_node = ''ON CPU'' THEN &&sqld360_ashsample. ELSE 0 END) cpu_time,]'); 
    put(q'[                       COUNT(*) db_time                                                                      ]'); 
    put(q'[                  FROM plan_table                                                                            ]');
    put(q'[                 WHERE statement_id = ''SQLD360_ASH_DATA_MEM''                                               ]');
    put(q'[                   AND /*cost*/ bytes =  ]'||i.plan_hash_value                                                 );
    put(q'[                   AND remarks = ''&&sqld360_sqlid.''                                                        ]'); 
    put(q'[                   AND partition_id IS NOT NULL                                                              ]');
    put(q'[                   AND ''&&diagnostics_pack.'' = ''Y''                                                       ]');
    put(q'[                 GROUP BY TO_DATE(SUBSTR(distribution,1,12),''YYYYMMDDHH24MI''),                             ]');
    put(q'[                          NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'','',1,3)+1,INSTR(partition_stop,'','',1,4)-INSTR(partition_stop,'','',1,3)-1)),position)||''-''||  ]'); 
    put(q'[                           NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'','',1,4)+1,INSTR(partition_stop,'','',1,5)-INSTR(partition_stop,'','',1,4)-1)),cpu_cost)||''-''|| ]'); 
    put(q'[                           NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'','',1,5)+1,INSTR(partition_stop,'','',1,6)-INSTR(partition_stop,'','',1,5)-1)),io_cost)||''-''||  ]');
    put(q'[                           NVL(partition_id,0)||''-''||NVL(distribution,''x''))                              ]');
    put(q'[          GROUP BY start_time)                                                                               ]');
    put(q'[ ORDER BY 3                                                                                                  ]');
    put(''';');
    put('END;');
    put('/ ');
    put('@sql/sqld360_9a_pre_one.sql');

    put('----------------------------');

    put(q'[DEF title='Avg et/exec for historical execs for PHV ]'||i.plan_hash_value||q'[' ]');
    put(q'[DEF main_table = 'DBA_HIST_ACTIVE_SESS_HISTORY'                                 ]');
    put(q'[DEF skip_lch=''                                                                 ]');
    put(q'[DEF chartype = 'LineChart'                                                      ]');
    put(q'[DEF stacked = ''                                                                ]');
    put(q'[DEF vaxis = 'Elapsed Time in secs'                                              ]');
    put(q'[DEF tit_01 = 'Average Elapsed Time/exec'                                        ]');
    put(q'[DEF tit_02 = 'Average Time on CPU/exec'                                         ]');
    put(q'[DEF tit_03 = 'Average DB Time/exec'                                             ]');
    put(q'[DEF tit_04 = 'Min Elapsed Time/exec'                                            ]');
    put(q'[DEF tit_05 = 'Max Elapsed Time/exec'                                            ]');
    put(q'[DEF tit_06 = 'Average Elapsed Time/exec Trend'                                  ]');
    put(q'[DEF tit_07 = ''                                                                 ]');
    put(q'[DEF tit_08 = ''                                                                 ]');
    put(q'[DEF tit_09 = ''                                                                 ]');
    put(q'[DEF tit_10 = ''                                                                 ]');
    put(q'[DEF tit_11 = ''                                                                 ]');
    put(q'[DEF tit_12 = ''                                                                 ]');
    put(q'[DEF tit_13 = ''                                                                 ]');
    put(q'[DEF tit_14 = ''                                                                 ]');
    put(q'[DEF tit_15 = ''                                                                 ]');
    put(q'[BEGIN                                                                           ]');
    put(q'[ :sql_text := '                                                                 ]');
    put(q'[SELECT b.snap_id snap_id,                                                                                                    ]');
    put(q'[       TO_CHAR(b.begin_interval_time, ''YYYY-MM-DD HH24:MI'') begin_time,                                                    ]'); 
    put(q'[       TO_CHAR(b.end_interval_time, ''YYYY-MM-DD HH24:MI'') end_time,                                                        ]');
    put(q'[       NVL(avg_et,0) avg_et,                                                                                                 ]');
    put(q'[       NVL(avg_cpu_time,0) avg_cpu_time,                                                                                     ]');
    put(q'[       NVL(avg_db_time,0) avg_db_time,                                                                                       ]');
    put(q'[       NVL(min_et,0) min_et,                                                                                                 ]');
    put(q'[       NVL(max_et,0) max_et,                                                                                                 ]');
    put(q'[       NVL(AVG(avg_et) OVER (ORDER BY b.snap_id ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW),0) avg_et_trend,           ]');
    put(q'[       0 dummy_07,                                                                                                           ]');
    put(q'[       0 dummy_08,                                                                                                           ]');
    put(q'[       0 dummy_09,                                                                                                           ]');
    put(q'[       0 dummy_10,                                                                                                           ]');
    put(q'[       0 dummy_11,                                                                                                           ]');
    put(q'[       0 dummy_12,                                                                                                           ]');
    put(q'[       0 dummy_13,                                                                                                           ]');
    put(q'[       0 dummy_14,                                                                                                           ]');
    put(q'[       0 dummy_15                                                                                                            ]');
    put(q'[  FROM (SELECT snap_id,                                                                                                      ]');
    put(q'[               TRUNC(MAX(avg_et),2) avg_et,                                                                                  ]');
    put(q'[               TRUNC(MAX(avg_cpu_time),2) avg_cpu_time,                                                                      ]');
    put(q'[               TRUNC(MAX(avg_db_time),2) avg_db_time,                                                                        ]');
    put(q'[               TRUNC(MAX(min_et),2) min_et,                                                                                  ]');
    put(q'[               TRUNC(MAX(max_et),2) max_et                                                                                   ]');
    put(q'[          FROM (SELECT start_time,                                                                                           ]');
    put(q'[                       MIN(start_snap_id) snap_id,                                                                           ]');
    put(q'[                       AVG(et) avg_et,                                                                                       ]');
    put(q'[                       AVG(cpu_time) avg_cpu_time,                                                                           ]');
    put(q'[                       AVG(db_time) avg_db_time,                                                                             ]');
    put(q'[                       MIN(et) min_et,                                                                                       ]');
    put(q'[                       MAX(et) max_et                                                                                        ]');
    put(q'[                  FROM (SELECT TO_DATE(SUBSTR(distribution,1,12),''YYYYMMDDHH24MI'') start_time,                             ]');
    put(q'[                               NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'','',1,3)+1,INSTR(partition_stop,'','',1,4)-INSTR(partition_stop,'','',1,3)-1)),position)||''-''||   ]'); 
    put(q'[                                NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'','',1,4)+1,INSTR(partition_stop,'','',1,5)-INSTR(partition_stop,'','',1,4)-1)),cpu_cost)||''-''||  ]'); 
    put(q'[                                NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'','',1,5)+1,INSTR(partition_stop,'','',1,6)-INSTR(partition_stop,'','',1,5)-1)),io_cost)||''-''||   ]');
    put(q'[                                NVL(partition_id,0)||''-''||NVL(distribution,''x'') uniq_exec,                               ]'); 
    put(q'[                               MIN(cardinality) start_snap_id,                                                               ]');
    --put('                               10+86400*(MAX(timestamp)-MIN(timestamp)) et, ');
    put(q'[                               &&sqld360_ashtimevalue.+86400*(MAX(timestamp)-MIN(timestamp)) et,                             ]');
    --put('                               SUM(CASE WHEN object_node = ''''ON CPU'''' THEN 10 ELSE 0 END) cpu_time,'); 
    put(q'[                               SUM(CASE WHEN object_node = ''ON CPU'' THEN &&sqld360_ashtimevalue. ELSE 0 END) cpu_time,     ]');
    --put('                               SUM(10) db_time');
    put(q'[                               SUM(&&sqld360_ashtimevalue.) db_time                                                          ]');  
    put(q'[                          FROM plan_table                                                                                    ]');
    put(q'[                         WHERE statement_id = ''SQLD360_ASH_DATA_HIST''                                                      ]');
    put(q'[                           AND partition_id IS NOT NULL                                                                      ]');
    put(q'[                           AND /*cost*/ bytes = ]'||i.plan_hash_value                                                          );
    put(q'[                           AND remarks = ''&&sqld360_sqlid.''                                                                ]');
    put(q'[                           AND ''&&diagnostics_pack.'' = ''Y''                                                               ]');
    put(q'[                         GROUP BY TO_DATE(SUBSTR(distribution,1,12),''YYYYMMDDHH24MI''),                                     ]');
    put(q'[                                  NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'','',1,3)+1,INSTR(partition_stop,'','',1,4)-INSTR(partition_stop,'','',1,3)-1)),position)||''-''||  ]'); 
    put(q'[                                   NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'','',1,4)+1,INSTR(partition_stop,'','',1,5)-INSTR(partition_stop,'','',1,4)-1)),cpu_cost)||''-''|| ]'); 
    put(q'[                                   NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'','',1,5)+1,INSTR(partition_stop,'','',1,6)-INSTR(partition_stop,'','',1,5)-1)),io_cost)||''-''||  ]');
    put(q'[                                   NVL(partition_id,0)||''-''||NVL(distribution,''x''))                                      ]');
    put(q'[                 GROUP BY start_time)                                                                                        ]');
    put(q'[         GROUP BY snap_id) ash,                                                                                              ]');
    put(q'[       (SELECT snap_id, begin_interval_time, end_interval_time                                                               ]');
    put(q'[          FROM (SELECT snap_id, begin_interval_time, end_interval_time,                                                      ]');
    put(q'[                       ROW_NUMBER() OVER (PARTITION BY snap_id ORDER BY instance_number) rn                                  ]');    
    put(q'[                  FROM dba_hist_snapshot)                                                                                    ]');
    put(q'[         WHERE rn = 1) b                                                                                                     ]');
    put(q'[ WHERE ash.snap_id(+) = b.snap_id                                                                                            ]');
    put(q'[   AND b.snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.                                                           ]');
    put(q'[ ORDER BY 3                                                                                                                  ]');
    put(''';');
    put('END;');
    put('/ ');
    put('@sql/sqld360_9a_pre_one.sql');

    put('----------------------------');

    put('SPO &&one_spool_filename..html APP;');
    put('PRO </ol>                          ');
    put('PRO <h2>Resource Consumption</h2>  ');
    put('SET DEF @                          ');
    put('PRO <ol start="@report_sequence."> ');
    put('SET DEF &                          ');
    put('SPO OFF                            ');

    put(q'[DEF title='Peak PGA and TEMP usage for recent execs for PHV ]'||i.plan_hash_value||q'[' ]');
    put(q'[DEF main_table = 'V$ACTIVE_SESSION_HISTORY'                                             ]');
    put(q'[DEF skip_lch=''                                                                         ]');
    put(q'[DEF chartype = 'LineChart'                                                              ]');
    put(q'[DEF stacked = ''                                                                        ]');
    put(q'[DEF vaxis = 'Bytes'                                                                     ]');
    put(q'[DEF tit_01 = 'PGA Usage'                                                                ]');
    put(q'[DEF tit_02 = 'TEMP Usage'                                                               ]');
    put(q'[DEF tit_03 = ''                                                                         ]');
    put(q'[DEF tit_04 = ''                                                                         ]');
    put(q'[DEF tit_05 = ''                                                                         ]');
    put(q'[DEF tit_06 = ''                                                                         ]');
    put(q'[DEF tit_07 = ''                                                                         ]');
    put(q'[DEF tit_08 = ''                                                                         ]');
    put(q'[DEF tit_09 = ''                                                                         ]');
    put(q'[DEF tit_10 = ''                                                                         ]');
    put(q'[DEF tit_11 = ''                                                                         ]');
    put(q'[DEF tit_12 = ''                                                                         ]');
    put(q'[DEF tit_13 = ''                                                                         ]');
    put(q'[DEF tit_14 = ''                                                                         ]');
    put(q'[DEF tit_15 = ''                                                                         ]');
    put(q'[BEGIN                                                                                   ]');
    put(q'[ :sql_text := '                                                                         ]');
    put(q'[SELECT 0 snap_id,                                                    ]');
    put(q'[       TO_CHAR(end_time, ''YYYY-MM-DD HH24:MI'') begin_time,         ]'); 
    put(q'[       TO_CHAR(end_time, ''YYYY-MM-DD HH24:MI'') end_time,           ]');
    put(q'[       pga_allocated_min,                                            ]');
    put(q'[       temp_space_allocated_min,                                     ]');
    put(q'[       0 dummy_03,                                                   ]');
    put(q'[       0 dummy_04,                                                   ]');
    put(q'[       0 dummy_05,                                                   ]');
    put(q'[       0 dummy_06,                                                   ]');
    put(q'[       0 dummy_07,                                                   ]');
    put(q'[       0 dummy_08,                                                   ]');
    put(q'[       0 dummy_09,                                                   ]');
    put(q'[       0 dummy_10,                                                   ]');
    put(q'[       0 dummy_11,                                                   ]');
    put(q'[       0 dummy_12,                                                   ]');
    put(q'[       0 dummy_13,                                                   ]');
    put(q'[       0 dummy_14,                                                   ]');
    put(q'[       0 dummy_15                                                    ]');
    put(q'[  FROM (SELECT TRUNC(end_time,''mi'') end_time,                      ]');
    put(q'[               MAX(pga_allocated) pga_allocated_min,                 ]');
    put(q'[               MAX(temp_space_allocated) temp_space_allocated_min    ]');
    put(q'[          FROM (SELECT timestamp end_time,                           ]');
    put(q'[                       SUM(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'','',1,11)+1,INSTR(partition_stop,'','',1,12)-INSTR(partition_stop,'','',1,11)-1))) pga_allocated,       ]'); 
    put(q'[                       SUM(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'','',1,12)+1,INSTR(partition_stop,'','',1,13)-INSTR(partition_stop,'','',1,12)-1))) temp_space_allocated ]'); 
    put(q'[                  FROM plan_table                                    ]');
    put(q'[                 WHERE statement_id = ''SQLD360_ASH_DATA_MEM''       ]');
    put(q'[                   AND /*cost*/ bytes =  ]'||i.plan_hash_value         );
    put(q'[                   AND remarks = ''&&sqld360_sqlid.''                ]'); 
    put(q'[                   AND partition_id IS NOT NULL                      ]');
    put(q'[                   AND ''&&diagnostics_pack.'' = ''Y''               ]');
    put(q'[                 GROUP BY timestamp)                                 ]');
    put(q'[          GROUP BY TRUNC(end_time,''mi''))                           ]');
    put(q'[ ORDER BY 3                                                          ]');
    put(''';');
    put('END;');
    put('/ ');
    put('@sql/sqld360_9a_pre_one.sql');

    put('----------------------------');

    put(q'[DEF title='Peak PGA and TEMP usage for historical execs for PHV ]'||i.plan_hash_value||q'[' ]');
    put(q'[DEF main_table = 'DBA_HIST_ACTIVE_SESS_HISTORY'                                             ]');
    put(q'[DEF skip_lch=''                                                                             ]');
    put(q'[DEF chartype = 'LineChart'                                                                  ]');
    put(q'[DEF stacked = ''                                                                            ]');
    put(q'[DEF vaxis = 'Bytes'                                                                         ]');
    put(q'[DEF tit_01 = 'PGA Usage'                                                                    ]');
    put(q'[DEF tit_02 = 'TEMP Usage'                                                                   ]');
    put(q'[DEF tit_03 = ''                                                                             ]');
    put(q'[DEF tit_04 = ''                                                                             ]');
    put(q'[DEF tit_05 = ''                                                                             ]');
    put(q'[DEF tit_06 = ''                                                                             ]');
    put(q'[DEF tit_07 = ''                                                                             ]');
    put(q'[DEF tit_08 = ''                                                                             ]');
    put(q'[DEF tit_09 = ''                                                                             ]');
    put(q'[DEF tit_10 = ''                                                                             ]');
    put(q'[DEF tit_11 = ''                                                                             ]');
    put(q'[DEF tit_12 = ''                                                                             ]');
    put(q'[DEF tit_13 = ''                                                                             ]');
    put(q'[DEF tit_14 = ''                                                                             ]');
    put(q'[DEF tit_15 = ''                                                                             ]');
    put(q'[BEGIN                                                                                       ]');
    put(q'[ :sql_text := '                                                                             ]');
    put(q'[SELECT b.snap_id snap_id,                                                                  ]');
    put(q'[       TO_CHAR(b.begin_interval_time, ''YYYY-MM-DD HH24:MI'') begin_time,                  ]'); 
    put(q'[       TO_CHAR(b.end_interval_time, ''YYYY-MM-DD HH24:MI'') end_time,                      ]');
    put(q'[       NVL(pga_allocated_hour,0) pga_allocated_hour,                                       ]');
    put(q'[       NVL(temp_space_allocated_hour,0) temp_space_allocated_hour,                         ]');
    put(q'[       0 dummy_03,                                                                         ]');
    put(q'[       0 dummy_04,                                                                         ]');
    put(q'[       0 dummy_05,                                                                         ]');
    put(q'[       0 dummy_06,                                                                         ]');
    put(q'[       0 dummy_07,                                                                         ]');
    put(q'[       0 dummy_08,                                                                         ]');
    put(q'[       0 dummy_09,                                                                         ]');
    put(q'[       0 dummy_10,                                                                         ]');
    put(q'[       0 dummy_11,                                                                         ]');
    put(q'[       0 dummy_12,                                                                         ]');
    put(q'[       0 dummy_13,                                                                         ]');
    put(q'[       0 dummy_14,                                                                         ]');
    put(q'[       0 dummy_15                                                                          ]');
    put(q'[  FROM (SELECT snap_id,                                                                    ]');
    put(q'[               MAX(pga_allocated) pga_allocated_hour,                                      ]');
    put(q'[               MAX(temp_space_allocated) temp_space_allocated_hour                         ]');
    put(q'[          FROM (SELECT cardinality snap_id,                                                ]');
    put(q'[                       timestamp end_time,                                                 ]'); 
    put(q'[                       SUM(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'','',1,11)+1,INSTR(partition_stop,'','',1,12)-INSTR(partition_stop,'','',1,11)-1))) pga_allocated,       ]');
    put(q'[                       SUM(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'','',1,12)+1,INSTR(partition_stop,'','',1,13)-INSTR(partition_stop,'','',1,12)-1))) temp_space_allocated ]');
    put(q'[                  FROM plan_table                                                          ]');
    put(q'[                 WHERE statement_id = ''SQLD360_ASH_DATA_HIST''                            ]');
    put(q'[                   AND /*cost*/ bytes = ]'||i.plan_hash_value                                );
    put(q'[                   AND remarks = ''&&sqld360_sqlid.''                                      ]');
    put(q'[                   AND ''&&diagnostics_pack.'' = ''Y''                                     ]');
    put(q'[                 GROUP BY cardinality, timestamp)                                          ]');
    put(q'[         GROUP BY snap_id) ash,                                                            ]');
    put(q'[       (SELECT snap_id, begin_interval_time, end_interval_time                             ]');
    put(q'[          FROM (SELECT snap_id, begin_interval_time, end_interval_time,                    ]');
    put(q'[                       ROW_NUMBER() OVER (PARTITION BY snap_id ORDER BY instance_number) rn]');    
    put(q'[                  FROM dba_hist_snapshot)                                                  ]');
    put(q'[         WHERE rn = 1) b                                                                   ]');
    put(q'[ WHERE ash.snap_id(+) = b.snap_id                                                          ]');
    put(q'[   AND b.snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.                         ]');
    put(q'[ ORDER BY 3                                                                                ]');
    put(''';');
    put('END;');
    put('/ ');
    put('@sql/sqld360_9a_pre_one.sql');

    put('----------------------------');

-- the result in case of PX might be a little misleading because some slaves could be not sampled
-- for few secs and then show up with a delta_time > 1 sec so the metrics should be split "backwards" in time
-- but that would be too expensive to compute and likely to provide little benefit
-- there should be no issue for serial execs

    put(q'[DEF title='Peak Read and Write I/O requests for recent execs for PHV ]'||i.plan_hash_value||q'[']');
    put(q'[DEF main_table = 'V$ACTIVE_SESSION_HISTORY']');
    put(q'[DEF skip_lch=''                            ]');
    put(q'[DEF chartype = 'LineChart'                 ]');
    put(q'[DEF stacked = ''                           ]');
    put(q'[DEF vaxis = 'Number of I/O requests'       ]');
    put(q'[DEF tit_01 = 'Read I/O Request'            ]');
    put(q'[DEF tit_02 = 'Write I/O Request'           ]');
    put(q'[DEF tit_03 = ''                            ]');
    put(q'[DEF tit_04 = ''                            ]');
    put(q'[DEF tit_05 = ''                            ]');
    put(q'[DEF tit_06 = ''                            ]');
    put(q'[DEF tit_07 = ''                            ]');
    put(q'[DEF tit_08 = ''                            ]');
    put(q'[DEF tit_09 = ''                            ]');
    put(q'[DEF tit_10 = ''                            ]');
    put(q'[DEF tit_11 = ''                            ]');
    put(q'[DEF tit_12 = ''                            ]');
    put(q'[DEF tit_13 = ''                            ]');
    put(q'[DEF tit_14 = ''                            ]');
    put(q'[DEF tit_15 = ''                            ]');
    put( 'BEGIN                                        ');
    put(q'[ :sql_text := '                            ]');
    put(q'[SELECT 0 snap_id,                                                       ]');
    put(q'[       TO_CHAR(end_time, ''YYYY-MM-DD HH24:MI'') begin_time,            ]'); 
    put(q'[       TO_CHAR(end_time, ''YYYY-MM-DD HH24:MI'') end_time,              ]');
    put(q'[       read_io_requests_min,                                            ]');
    put(q'[       write_io_requests_min,                                           ]');
    put(q'[       0 dummy_03,                                                      ]');
    put(q'[       0 dummy_04,                                                      ]');
    put(q'[       0 dummy_05,                                                      ]');
    put(q'[       0 dummy_06,                                                      ]');
    put(q'[       0 dummy_07,                                                      ]');
    put(q'[       0 dummy_08,                                                      ]');
    put(q'[       0 dummy_09,                                                      ]');
    put(q'[       0 dummy_10,                                                      ]');
    put(q'[       0 dummy_11,                                                      ]');
    put(q'[       0 dummy_12,                                                      ]');
    put(q'[       0 dummy_13,                                                      ]');
    put(q'[       0 dummy_14,                                                      ]');
    put(q'[       0 dummy_15                                                       ]');
    put(q'[  FROM (SELECT TRUNC(end_time,''mi'') end_time,                         ]');
    put(q'[               TRUNC(MAX(read_io_requests),2) read_io_requests_min,     ]');
    put(q'[               TRUNC(MAX(write_io_requests),2) write_io_requests_min    ]');
    put(q'[          FROM (SELECT timestamp end_time,                              ]');
    put(q'[                       SUM(NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'','',1,14)+1,INSTR(partition_stop,'','',1,15)-INSTR(partition_stop,'','',1,14)-1)),0)/                                    ]');
    put(q'[                           ROUND(GREATEST(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'','',1,13)+1,INSTR(partition_stop,'','',1,14)-INSTR(partition_stop,'','',1,13)-1))/1e6,1))) read_io_requests,  ]'); 
    put(q'[                       SUM(NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'','',1,15)+1,INSTR(partition_stop,'','',1,16)-INSTR(partition_stop,'','',1,15)-1)),0)/                                    ]');
    put(q'[                           ROUND(GREATEST(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'','',1,13)+1,INSTR(partition_stop,'','',1,14)-INSTR(partition_stop,'','',1,13)-1))/1e6,1))) write_io_requests  ]'); 
    put(q'[                  FROM plan_table                                       ]');
    put(q'[                 WHERE statement_id = ''SQLD360_ASH_DATA_MEM''          ]');
    put(q'[                   AND /*cost*/ bytes =  ]'||i.plan_hash_value            );
    put(q'[                   AND remarks = ''&&sqld360_sqlid.''                   ]'); 
    put(q'[                   AND partition_id IS NOT NULL                         ]');
    put(q'[                   AND ''&&diagnostics_pack.'' = ''Y''                  ]');
    put(q'[                 GROUP BY timestamp)                                    ]');
    put(q'[          GROUP BY TRUNC(end_time,''mi''))                              ]');
    put(q'[ ORDER BY 3                                                             ]');
    put(''';');
    put('END;');
    put('/ ');
    put('@sql/sqld360_9a_pre_one.sql');

    put('----------------------------');

    put(q'[DEF title='Peak Read and Write I/O requests for historical execs for PHV ]'||i.plan_hash_value||q'[']');
    put(q'[DEF main_table = 'DBA_HIST_ACTIVE_SESS_HISTORY' ]');
    put(q'[DEF skip_lch=''                                 ]');
    put(q'[DEF chartype = 'LineChart'                      ]');
    put(q'[DEF stacked = ''                                ]');
    put(q'[DEF vaxis = 'Number of I/O requests'            ]');
    put(q'[DEF tit_01 = 'Read I/O Request'                 ]');
    put(q'[DEF tit_02 = 'Write I/O Request'                ]');
    put(q'[DEF tit_03 = ''                                 ]');
    put(q'[DEF tit_04 = ''                                 ]');
    put(q'[DEF tit_05 = ''                                 ]');
    put(q'[DEF tit_06 = ''                                 ]');
    put(q'[DEF tit_07 = ''                                 ]');
    put(q'[DEF tit_08 = ''                                 ]');
    put(q'[DEF tit_09 = ''                                 ]');
    put(q'[DEF tit_10 = ''                                 ]');
    put(q'[DEF tit_11 = ''                                 ]');
    put(q'[DEF tit_12 = ''                                 ]');
    put(q'[DEF tit_13 = ''                                 ]');
    put(q'[DEF tit_14 = ''                                 ]');
    put(q'[DEF tit_15 = ''                                 ]');
    put( 'BEGIN                                             ');
    put(q'[ :sql_text := '                                 ]');
    put(q'[SELECT b.snap_id snap_id,                       ]');
    put(q'[       TO_CHAR(b.begin_interval_time, ''YYYY-MM-DD HH24:MI'') begin_time,  ]'); 
    put(q'[       TO_CHAR(b.end_interval_time, ''YYYY-MM-DD HH24:MI'') end_time,      ]');
    put(q'[       NVL(read_io_requests_hour,0) read_io_requests_hour,                 ]');
    put(q'[       NVL(write_io_requests_hour,0) write_io_requests_hour,               ]');
    put(q'[       0 dummy_03,                                                         ]');
    put(q'[       0 dummy_04,                                                         ]');
    put(q'[       0 dummy_05,                                                         ]');
    put(q'[       0 dummy_06,                                                         ]');
    put(q'[       0 dummy_07,                                                         ]');
    put(q'[       0 dummy_08,                                                         ]');
    put(q'[       0 dummy_09,                                                         ]');
    put(q'[       0 dummy_10,                                                         ]');
    put(q'[       0 dummy_11,                                                         ]');
    put(q'[       0 dummy_12,                                                         ]');
    put(q'[       0 dummy_13,                                                         ]');
    put(q'[       0 dummy_14,                                                         ]');
    put(q'[       0 dummy_15                                                          ]');
    put(q'[  FROM (SELECT snap_id,                                                    ]');
    put(q'[               TRUNC(MAX(read_io_requests),2) read_io_requests_hour,       ]');
    put(q'[               TRUNC(MAX(write_io_requests),2) write_io_requests_hour      ]');
    put(q'[          FROM (SELECT cardinality snap_id,                                ]');
    put(q'[                       timestamp end_time,                                 ]'); 
    put(q'[                       SUM(NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'','',1,14)+1,INSTR(partition_stop,'','',1,15)-INSTR(partition_stop,'','',1,14)-1)),0)/                                        ]');
    put(q'[                               ROUND(GREATEST(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'','',1,13)+1,INSTR(partition_stop,'','',1,14)-INSTR(partition_stop,'','',1,13)-1))/1e6,1))) read_io_requests,  ]'); 
    put(q'[                       SUM(NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'','',1,15)+1,INSTR(partition_stop,'','',1,16)-INSTR(partition_stop,'','',1,15)-1)),0)/                                        ]');
    put(q'[                               ROUND(GREATEST(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'','',1,13)+1,INSTR(partition_stop,'','',1,14)-INSTR(partition_stop,'','',1,13)-1))/1e6,1))) write_io_requests  ]'); 
    put(q'[                  FROM plan_table                                          ]');
    put(q'[                 WHERE statement_id = ''SQLD360_ASH_DATA_HIST''            ]');
    put(q'[                   AND /*cost*/ bytes = ]'||i.plan_hash_value                );
    put(q'[                   AND remarks = ''&&sqld360_sqlid.''                      ]');
    put(q'[                   AND ''&&diagnostics_pack.'' = ''Y''                     ]');
    put(q'[                 GROUP BY cardinality, timestamp)                          ]');
    put(q'[         GROUP BY snap_id) ash,                                            ]');
    put(q'[       (SELECT snap_id, begin_interval_time, end_interval_time             ]');
    put(q'[          FROM (SELECT snap_id, begin_interval_time, end_interval_time,    ]');
    put(q'[                       ROW_NUMBER() OVER (PARTITION BY snap_id ORDER BY instance_number) rn ]');    
    put(q'[                  FROM dba_hist_snapshot)                                  ]');
    put(q'[         WHERE rn = 1) b                                                   ]');
    put(q'[ WHERE ash.snap_id(+) = b.snap_id                                          ]');
    put(q'[   AND b.snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.         ]');
    put(q'[ ORDER BY 3                                                                ]');
    put(''';');
    put('END;');
    put('/ ');
    put('@sql/sqld360_9a_pre_one.sql');

    put('----------------------------');

    put(q'[DEF title='Peak Read, Write and Interconnect I/O bytes for recent execs for PHV ]'||i.plan_hash_value||q'[']');
    put(q'[DEF main_table = 'V$ACTIVE_SESSION_HISTORY' ]');
    put(q'[DEF skip_lch=''                             ]');
    put(q'[DEF chartype = 'LineChart'                  ]');
    put(q'[DEF stacked = ''                            ]');
    put(q'[DEF vaxis = 'I/O bytes'                     ]');
    put(q'[DEF tit_01 = 'Read I/O Bytes'               ]');
    put(q'[DEF tit_02 = 'Write I/O Bytes'              ]');
    put(q'[DEF tit_03 = 'Interconnect I/O Bytes'       ]');
    put(q'[DEF tit_04 = ''                             ]');
    put(q'[DEF tit_05 = ''                             ]');
    put(q'[DEF tit_06 = ''                             ]');
    put(q'[DEF tit_07 = ''                             ]');
    put(q'[DEF tit_08 = ''                             ]');
    put(q'[DEF tit_09 = ''                             ]');
    put(q'[DEF tit_10 = ''                             ]');
    put(q'[DEF tit_11 = ''                             ]');
    put(q'[DEF tit_12 = ''                             ]');
    put(q'[DEF tit_13 = ''                             ]');
    put(q'[DEF tit_14 = ''                             ]');
    put(q'[DEF tit_15 = ''                             ]');
    put( ' BEGIN');
    put(q'[ :sql_text := '                             ]');
    put(q'[SELECT 0 snap_id,                           ]');
    put(q'[       TO_CHAR(end_time, ''YYYY-MM-DD HH24:MI'') begin_time,                 ]'); 
    put(q'[       TO_CHAR(end_time, ''YYYY-MM-DD HH24:MI'') end_time,                   ]');
    put(q'[       read_io_bytes_min,                                                    ]');
    put(q'[       write_io_bytes_min,                                                   ]');
    put(q'[       interconnect_io_bytes_min,                                            ]');
    put(q'[       0 dummy_04,                                                           ]');
    put(q'[       0 dummy_05,                                                           ]');
    put(q'[       0 dummy_06,                                                           ]');
    put(q'[       0 dummy_07,                                                           ]');
    put(q'[       0 dummy_08,                                                           ]');
    put(q'[       0 dummy_09,                                                           ]');
    put(q'[       0 dummy_10,                                                           ]');
    put(q'[       0 dummy_11,                                                           ]');
    put(q'[       0 dummy_12,                                                           ]');
    put(q'[       0 dummy_13,                                                           ]');
    put(q'[       0 dummy_14,                                                           ]');
    put(q'[       0 dummy_15                                                            ]');
    put(q'[  FROM (SELECT TRUNC(end_time,''mi'') end_time,                              ]');
    put(q'[               TRUNC(MAX(read_io_bytes),2) read_io_bytes_min,                ]');
    put(q'[               TRUNC(MAX(write_io_bytes),2) write_io_bytes_min,              ]');
    put(q'[               TRUNC(MAX(interconnect_io_bytes),2) interconnect_io_bytes_min ]');
    put(q'[          FROM (SELECT timestamp end_time,                                   ]');
    put(q'[                       SUM(NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'','',1,16)+1,INSTR(partition_stop,'','',1,17)-INSTR(partition_stop,'','',1,16)-1)),0)/                                       ]');
    put(q'[                           ROUND(GREATEST(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'','',1,13)+1,INSTR(partition_stop,'','',1,14)-INSTR(partition_stop,'','',1,13)-1))/1e6,1))) read_io_bytes,        ]'); 
    put(q'[                       SUM(NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'','',1,17)+1,INSTR(partition_stop,'','',1,18)-INSTR(partition_stop,'','',1,17)-1)),0)/                                       ]');
    put(q'[                           ROUND(GREATEST(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'','',1,13)+1,INSTR(partition_stop,'','',1,14)-INSTR(partition_stop,'','',1,13)-1))/1e6,1))) write_io_bytes,       ]'); 
    put(q'[                       SUM(NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'','',1,18)+1,INSTR(partition_stop,'','',1,19)-INSTR(partition_stop,'','',1,18)-1)),0)/                                       ]');
    put(q'[                           ROUND(GREATEST(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'','',1,13)+1,INSTR(partition_stop,'','',1,14)-INSTR(partition_stop,'','',1,13)-1))/1e6,1))) interconnect_io_bytes ]'); 
    put(q'[                  FROM plan_table                                            ]');
    put(q'[                 WHERE statement_id = ''SQLD360_ASH_DATA_MEM''               ]');
    put(q'[                   AND /*cost*/ bytes =  ]'||i.plan_hash_value                 );
    put(q'[                   AND remarks = ''&&sqld360_sqlid.''                        ]'); 
    put(q'[                   AND partition_id IS NOT NULL                              ]');
    put(q'[                   AND ''&&diagnostics_pack.'' = ''Y''                       ]');
    put(q'[                 GROUP BY timestamp)                                         ]');
    put(q'[          GROUP BY TRUNC(end_time,''mi''))                                   ]');
    put(q'[ ORDER BY 3                                                                  ]');
    put(''';');
    put('END;');
    put('/ ');
    put('@sql/sqld360_9a_pre_one.sql');

    put('----------------------------');

    put(q'[DEF title='Peak Read, Write and Interconnect I/O bytes for historical execs for PHV ]'||i.plan_hash_value||q'[']');
    put(q'[DEF main_table = 'DBA_HIST_ACTIVE_SESS_HISTORY' ]');
    put(q'[DEF skip_lch=''                                 ]');
    put(q'[DEF chartype = 'LineChart'                      ]');
    put(q'[DEF stacked = ''                                ]');
    put(q'[DEF vaxis = 'I/O bytes'                         ]');
    put(q'[DEF tit_01 = 'Read I/O Bytes'                   ]');
    put(q'[DEF tit_02 = 'Write I/O Bytes'                  ]');
    put(q'[DEF tit_03 = 'Interconnect I/O Bytes'           ]');
    put(q'[DEF tit_04 = ''                                 ]');
    put(q'[DEF tit_05 = ''                                 ]');
    put(q'[DEF tit_06 = ''                                 ]');
    put(q'[DEF tit_07 = ''                                 ]');
    put(q'[DEF tit_08 = ''                                 ]');
    put(q'[DEF tit_09 = ''                                 ]');
    put(q'[DEF tit_10 = ''                                 ]');
    put(q'[DEF tit_11 = ''                                 ]');
    put(q'[DEF tit_12 = ''                                 ]');
    put(q'[DEF tit_13 = ''                                 ]');
    put(q'[DEF tit_14 = ''                                 ]');
    put(q'[DEF tit_15 = ''                                 ]');
    put( 'BEGIN');
    put(q'[ :sql_text := '                                                                 ]');
    put(q'[SELECT b.snap_id snap_id,                                                       ]');
    put(q'[       TO_CHAR(b.begin_interval_time, ''YYYY-MM-DD HH24:MI'') begin_time,       ]'); 
    put(q'[       TO_CHAR(b.end_interval_time, ''YYYY-MM-DD HH24:MI'') end_time,           ]');
    put(q'[       NVL(read_io_bytes_hour,0) read_io_requests_hour,                         ]');
    put(q'[       NVL(write_io_bytes_hour,0) write_io_bytes_hour,                          ]');
    put(q'[       NVL(interconnect_io_bytes_hour,0) interconnect_io_bytes_hour,            ]');
    put(q'[       0 dummy_04,                                                              ]');
    put(q'[       0 dummy_05,                                                              ]');
    put(q'[       0 dummy_06,                                                              ]');
    put(q'[       0 dummy_07,                                                              ]');
    put(q'[       0 dummy_08,                                                              ]');
    put(q'[       0 dummy_09,                                                              ]');
    put(q'[       0 dummy_10,                                                              ]');
    put(q'[       0 dummy_11,                                                              ]');
    put(q'[       0 dummy_12,                                                              ]');
    put(q'[       0 dummy_13,                                                              ]');
    put(q'[       0 dummy_14,                                                              ]');
    put(q'[       0 dummy_15                                                               ]');
    put(q'[  FROM (SELECT snap_id,                                                         ]');
    put(q'[               TRUNC(MAX(read_io_bytes),2) read_io_bytes_hour,                  ]');
    put(q'[               TRUNC(MAX(write_io_bytes),2) write_io_bytes_hour,                ]');
    put(q'[               TRUNC(MAX(interconnect_io_bytes),2) interconnect_io_bytes_hour   ]');
    put(q'[          FROM (SELECT cardinality snap_id,                                     ]');
    put(q'[                       timestamp end_time,                                      ]'); 
    put(q'[                       SUM(NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'','',1,16)+1,INSTR(partition_stop,'','',1,17)-INSTR(partition_stop,'','',1,16)-1)),0)/                                           ]');
    put(q'[                               ROUND(GREATEST(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'','',1,13)+1,INSTR(partition_stop,'','',1,14)-INSTR(partition_stop,'','',1,13)-1))/1e6,1))) read_io_bytes,        ]'); 
    put(q'[                       SUM(NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'','',1,17)+1,INSTR(partition_stop,'','',1,18)-INSTR(partition_stop,'','',1,17)-1)),0)/                                           ]');
    put(q'[                               ROUND(GREATEST(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'','',1,13)+1,INSTR(partition_stop,'','',1,14)-INSTR(partition_stop,'','',1,13)-1))/1e6,1))) write_io_bytes,       ]'); 
    put(q'[                       SUM(NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'','',1,18)+1,INSTR(partition_stop,'','',1,19)-INSTR(partition_stop,'','',1,18)-1)),0)/                                           ]');
    put(q'[                               ROUND(GREATEST(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'','',1,13)+1,INSTR(partition_stop,'','',1,14)-INSTR(partition_stop,'','',1,13)-1))/1e6,1))) interconnect_io_bytes ]'); 
    put(q'[                  FROM plan_table                                               ]');
    put(q'[                 WHERE statement_id = ''SQLD360_ASH_DATA_HIST''                 ]');
    put(q'[                   AND /*cost*/ bytes = ]'||i.plan_hash_value                     );
    put(q'[                   AND remarks = ''&&sqld360_sqlid.''                           ]');
    put(q'[                   AND ''&&diagnostics_pack.'' = ''Y''                          ]');
    put(q'[                 GROUP BY cardinality, timestamp)                               ]');
    put(q'[         GROUP BY snap_id) ash,                                                 ]');
    put(q'[       (SELECT snap_id, begin_interval_time, end_interval_time                  ]');
    put(q'[          FROM (SELECT snap_id, begin_interval_time, end_interval_time,         ]');
    put(q'[                       ROW_NUMBER() OVER (PARTITION BY snap_id ORDER BY instance_number) rn ]');    
    put(q'[                  FROM dba_hist_snapshot)                                       ]');
    put(q'[         WHERE rn = 1) b                                                        ]');
    put(q'[ WHERE ash.snap_id(+) = b.snap_id                                               ]');
    put(q'[   AND b.snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.              ]');
    put(q'[ ORDER BY 3                                                                     ]');
    put(''';');
    put('END;');
    put('/ ');
    put('@sql/sqld360_9a_pre_one.sql');

    put('----------------------------');

    put('SPO &&one_spool_filename..html APP;');
    put('PRO </ol>                          ');
    put('PRO <h2>Top N</h2>                 ');
    put('SET DEF @                          ');
    put('PRO <ol start="@report_sequence."> ');
    put('SET DEF &                          ');
    put('SPO OFF                            ');

    put(q'[DEF title='Top Wait events for PHV ]'||i.plan_hash_value||q'[' ]');
    put(q'[DEF main_table = 'DBA_HIST_ACTIVE_SESS_HISTORY'                ]');
    put(q'[DEF skip_bch=''                                                ]');
    put(q'[BEGIN                                                          ]');
    put(q'[ :sql_text := '                                                ]');
    put(q'[SELECT cpu_or_event,                                                                                                                               ]');
    put(q'[       num_samples,                                                                                                                                ]');
    put(q'[       &&wait_class_colors.&&wait_class_colors2.&&wait_class_colors3.&&wait_class_colors4. style,                                                  ]');
    put(q'[       cpu_or_event||'' - Number of samples: ''||num_samples||'' (''||TRUNC(100*RATIO_TO_REPORT(num_samples) OVER (),2)||''% of DB Time)'' tooltip ]');
    put(q'[  FROM (SELECT object_node cpu_or_event, other_tag wait_class,                                                                                     ]');
    put(q'[               count(*) num_samples                                                                                                                ]');
    put(q'[          FROM plan_table                                                                                                                          ]');
    put(q'[         WHERE /*cost*/ bytes =  ]'||i.plan_hash_value                                                                                               );
    put(q'[           AND remarks = ''&&sqld360_sqlid.''                                                                                                      ]'); 
    put(q'[           AND ''&&diagnostics_pack.'' = ''Y''                                                                                                     ]');
    put(q'[           AND statement_id LIKE ''SQLD360_ASH_DATA%''                                                                                             ]');
    put(q'[         GROUP BY object_node, other_tag                                                                                                           ]'); 
    put(q'[         ORDER BY 3 DESC)                                                                                                                          ]');
    put(q'[ ORDER BY 2 DESC                                                                                                                                   ]');
    put(''';');
    put('END;');
    put('/ ');
    put('@sql/sqld360_9a_pre_one.sql');

    put('----------------------------');

    put(q'[DEF title='Top Objects accessed by PHV ]'||i.plan_hash_value||q'[' ]');
    put(q'[DEF main_table = 'DBA_HIST_ACTIVE_SESS_HISTORY'                    ]');
    put(q'[DEF skip_bch=''                                                    ]');
    put(q'[BEGIN                                                              ]');
    put(q'[ :sql_text := '                                                    ]');
    put(q'[SELECT data_object,                                                                                                                                                              ]');
    put(q'[       num_samples,                                                                                                                                                              ]');
    put(q'[       NULL style,                                                                                                                                                               ]');
    put(q'[       data_object||'' - Number of samples: ''||num_samples||'' (''||TRUNC(100*RATIO_TO_REPORT(num_samples) OVER (),2)||''% of DB Time)'' tooltip                                ]');
    put(q'[  FROM (SELECT data.obj#||                                                                                                                                                       ]');
    put(q'[               CASE WHEN data.obj# = 0 THEN ''UNDO''                                                                                                                             ]');
    put(q'[                    ELSE (SELECT TRIM(''.'' FROM '' ''||o.owner||''.''||o.object_name||''.''||o.subobject_name) FROM dba_objects o WHERE o.object_id = data.obj# AND ROWNUM = 1) ]'); 
    put(q'[               END data_object,                                                                                                                                                  ]');
    put(q'[               num_samples                                                                                                                                                       ]');
    put(q'[          FROM (SELECT a.object_instance obj#,                                                                                                                                   ]');
    put(q'[                       count(*) num_samples                                                                                                                                      ]');
    put(q'[                  FROM plan_table a                                                                                                                                              ]');
    put(q'[                 WHERE /*cost*/ a.bytes =  ]'||i.plan_hash_value                                                                                                                   );
    put(q'[                   AND a.remarks = ''&&sqld360_sqlid.''                                                                                                                          ]'); 
    put(q'[                   AND statement_id LIKE ''SQLD360_ASH_DATA%''                                                                                                                   ]');    
    put(q'[                   AND ''&&diagnostics_pack.'' = ''Y''                                                                                                                           ]');
    put(q'[                   AND a.other_tag IN (''Application'',''Cluster'', ''Concurrency'', ''User I/O'', ''System I/O'')                                                               ]');
    put(q'[                 GROUP BY a.object_instance                                                                                                                                      ]'); 
    put(q'[                 ORDER BY 2 DESC) data)                                                                                                                                          ]');
    put(q'[ ORDER BY 2 DESC                                                                                                                                                                 ]');
    put(''';');
    put('END;');
    put('/ ');
    put('@sql/sqld360_9a_pre_one.sql');

    put('----------------------------');

    put(q'[DEF title='Top Plan Steps for PHV ]'||i.plan_hash_value||q'['    ]');
    put(q'[DEF main_table = 'DBA_HIST_ACTIVE_SESS_HISTORY'                  ]');
    put(q'[DEF skip_bch=''                                                  ]');
    put(q'[BEGIN                                                            ]');
    put(q'[ :sql_text := '                                                  ]');
    put(q'[SELECT operation,                                                                                                                               ]');
    put(q'[       num_samples,                                                                                                                             ]');
    put(q'[       NULL style,                                                                                                                              ]');
    put(q'[       operation||'' - Number of samples: ''||num_samples||'' (''||TRUNC(100*RATIO_TO_REPORT(num_samples) OVER (),2)||''% of DB Time)'' tooltip ]');
    put(q'[  FROM (SELECT id||'' - ''||operation||'' ''||options operation,                                                                                ]');
    put(q'[               count(*) num_samples                                                                                                             ]');
    put(q'[          FROM plan_table                                                                                                                       ]');
    put(q'[         WHERE /*cost*/ bytes =  ]'||i.plan_hash_value                                                                                            );
    put(q'[           AND remarks = ''&&sqld360_sqlid.''                                                                                                   ]'); 
    put(q'[           AND statement_id LIKE ''SQLD360_ASH_DATA%''                                                                                          ]');  
    put(q'[           AND ''&&diagnostics_pack.'' = ''Y''                                                                                                  ]');
    put(q'[         GROUP BY id||'' - ''||operation||'' ''||options                                                                                        ]'); 
    put(q'[         ORDER BY 2 DESC)                                                                                                                       ]');
    put(q'[ ORDER BY 2 DESC                                                                                                                                ]');
    put(''';');
    put('END;');
    put('/ ');
    put('@sql/sqld360_9a_pre_one.sql');

    put('----------------------------');

    put(q'[DEF title='Top Step/Event/Obj for PHV ]'||i.plan_hash_value||q'[' ]');
    put(q'[DEF main_table = 'DBA_HIST_ACTIVE_SESS_HISTORY'                   ]');
    put(q'[DEF skip_bch=''                                                   ]');
    put(q'[BEGIN                                                             ]');
    put(q'[ :sql_text := '                                                   ]');
    put(q'[SELECT step_event,                                                                                                                                                            ]');
    put(q'[       num_samples,                                                                                                                                                           ]');
    put(q'[       &&wait_class_colors.&&wait_class_colors2.&&wait_class_colors3.&&wait_class_colors4. style,                                                                             ]');
    put(q'[       step_event||'' - Number of samples: ''||num_samples||'' (''||TRUNC(100*RATIO_TO_REPORT(num_samples) OVER (),2)||''% of DB Time)'' tooltip                              ]');
    put(q'[  FROM (SELECT data.step||'' ''||CASE WHEN data.obj# = 0 THEN ''UNDO''                                                                                                        ]');
    put(q'[                 ELSE (SELECT TRIM(''.'' FROM '' ''||o.owner||''.''||o.object_name||''.''||o.subobject_name) FROM dba_objects o WHERE o.object_id = data.obj# AND ROWNUM = 1) ]'); 
    put(q'[               END||'' / ''||data.event  step_event,                                                                                                                          ]');
    put(q'[               data.num_samples, data.wait_class                                                                                                                              ]');
    put(q'[          FROM (SELECT id||'' - ''||operation||'' ''||options step, object_instance obj#, object_node event, other_tag wait_class,                                            ]');    
    put(q'[                       count(*) num_samples                                                                                                                                   ]');
    put(q'[                  FROM plan_table                                                                                                                                             ]');
    put(q'[                 WHERE /*cost*/ bytes =  ]'||i.plan_hash_value                                                                                                                  );
    put(q'[                   AND remarks = ''&&sqld360_sqlid.''                                                                                                                         ]'); 
    put(q'[                   AND ''&&diagnostics_pack.'' = ''Y''                                                                                                                        ]');
    put(q'[                   AND statement_id LIKE ''SQLD360_ASH_DATA%''                                                                                                                ]'); 
    put(q'[                 GROUP BY id||'' - ''||operation||'' ''||options, object_instance, object_node, other_tag                                                                     ]'); 
    put(q'[                 ORDER BY 5 DESC) data)                                                                                                                                       ]');
    put(q'[ ORDER BY 2 DESC                                                                                                                                                              ]');
    put(''';');
    put('END;');
    put('/ ');
    put('@sql/sqld360_9a_pre_one.sql');

    put('----------------------------');

    put('DEF title=''Top 15 Wait events over recent time for PHV '||i.plan_hash_value||'''');
    put('DEF main_table = ''GV$ACTIVE_SESSION_HISTORY''');
    put('DEF skip_lch=''''');
    put('DEF chartype = ''AreaChart''');
    put('DEF stacked = ''isStacked: true,''');
    put('DEF abstract = ''AAS (stacked) per top 15 wait events over time''');
    put('DEF vaxis = ''Average Active Sessions - AAS (stacked)''');

    -- this looks confusing but it actually has a reason :-)
    -- tit_n is used to show / hide the column in the chart (in case of nulls)
    -- evt_n is used as filter value (populated dynamically)
    -- eN  is used to show / hide the column in the resultset (in case of nulls)

    put('COL evt_01 NEW_V evt_01'); 
    put('COL evt_02 NEW_V evt_02'); 
    put('COL evt_03 NEW_V evt_03'); 
    put('COL evt_04 NEW_V evt_04'); 
    put('COL evt_05 NEW_V evt_05'); 
    put('COL evt_06 NEW_V evt_06'); 
    put('COL evt_07 NEW_V evt_07'); 
    put('COL evt_08 NEW_V evt_08'); 
    put('COL evt_09 NEW_V evt_09'); 
    put('COL evt_10 NEW_V evt_10'); 
    put('COL evt_11 NEW_V evt_11'); 
    put('COL evt_12 NEW_V evt_12'); 
    put('COL evt_13 NEW_V evt_13'); 
    put('COL evt_14 NEW_V evt_14'); 
    put('COL evt_15 NEW_V evt_15');
    put('COL tit_01 NEW_V tit_01'); 
    put('COL tit_02 NEW_V tit_02'); 
    put('COL tit_03 NEW_V tit_03'); 
    put('COL tit_04 NEW_V tit_04'); 
    put('COL tit_05 NEW_V tit_05'); 
    put('COL tit_06 NEW_V tit_06'); 
    put('COL tit_07 NEW_V tit_07'); 
    put('COL tit_08 NEW_V tit_08'); 
    put('COL tit_09 NEW_V tit_09'); 
    put('COL tit_10 NEW_V tit_10'); 
    put('COL tit_11 NEW_V tit_11'); 
    put('COL tit_12 NEW_V tit_12'); 
    put('COL tit_13 NEW_V tit_13'); 
    put('COL tit_14 NEW_V tit_14'); 
    put('COL tit_15 NEW_V tit_15');

    -- this is to determine series color
    put('COL series_01 NEW_V series_01'); 
    put('COL series_02 NEW_V series_02'); 
    put('COL series_03 NEW_V series_03'); 
    put('COL series_04 NEW_V series_04'); 
    put('COL series_05 NEW_V series_05'); 
    put('COL series_06 NEW_V series_06'); 
    put('COL series_07 NEW_V series_07'); 
    put('COL series_08 NEW_V series_08'); 
    put('COL series_09 NEW_V series_09'); 
    put('COL series_10 NEW_V series_10'); 
    put('COL series_11 NEW_V series_11'); 
    put('COL series_12 NEW_V series_12'); 
    put('COL series_13 NEW_V series_13'); 
    put('COL series_14 NEW_V series_14'); 
    put('COL series_15 NEW_V series_15'); 

    put('SELECT MAX(CASE WHEN ranking = 1  THEN cpu_or_event ELSE '''' END) evt_01,');
    put('       MAX(CASE WHEN ranking = 2  THEN cpu_or_event ELSE '''' END) evt_02,');              
    put('       MAX(CASE WHEN ranking = 3  THEN cpu_or_event ELSE '''' END) evt_03,'); 
    put('       MAX(CASE WHEN ranking = 4  THEN cpu_or_event ELSE '''' END) evt_04,'); 
    put('       MAX(CASE WHEN ranking = 5  THEN cpu_or_event ELSE '''' END) evt_05,'); 
    put('       MAX(CASE WHEN ranking = 6  THEN cpu_or_event ELSE '''' END) evt_06,'); 
    put('       MAX(CASE WHEN ranking = 7  THEN cpu_or_event ELSE '''' END) evt_07,'); 
    put('       MAX(CASE WHEN ranking = 8  THEN cpu_or_event ELSE '''' END) evt_08,'); 
    put('       MAX(CASE WHEN ranking = 9  THEN cpu_or_event ELSE '''' END) evt_09,'); 
    put('       MAX(CASE WHEN ranking = 10 THEN cpu_or_event ELSE '''' END) evt_10,');
    put('       MAX(CASE WHEN ranking = 11 THEN cpu_or_event ELSE '''' END) evt_11,');
    put('       MAX(CASE WHEN ranking = 12 THEN cpu_or_event ELSE '''' END) evt_12,');
    put('       MAX(CASE WHEN ranking = 13 THEN cpu_or_event ELSE '''' END) evt_13,');
    put('       MAX(CASE WHEN ranking = 14 THEN cpu_or_event ELSE '''' END) evt_14,');
    put('       MAX(CASE WHEN ranking = 15 THEN cpu_or_event ELSE '''' END) evt_15,');  -- added coma here
    -- this is to determine series color
    put('       MAX(CASE WHEN ranking = 1  THEN &&wait_class_colors_s.&&wait_class_colors2_s.&&wait_class_colors3_s.&&wait_class_colors4_s. END) series_01,');
    put('       MAX(CASE WHEN ranking = 2  THEN &&wait_class_colors_s.&&wait_class_colors2_s.&&wait_class_colors3_s.&&wait_class_colors4_s. END) series_02,');              
    put('       MAX(CASE WHEN ranking = 3  THEN &&wait_class_colors_s.&&wait_class_colors2_s.&&wait_class_colors3_s.&&wait_class_colors4_s. END) series_03,'); 
    put('       MAX(CASE WHEN ranking = 4  THEN &&wait_class_colors_s.&&wait_class_colors2_s.&&wait_class_colors3_s.&&wait_class_colors4_s. END) series_04,'); 
    put('       MAX(CASE WHEN ranking = 5  THEN &&wait_class_colors_s.&&wait_class_colors2_s.&&wait_class_colors3_s.&&wait_class_colors4_s. END) series_05,'); 
    put('       MAX(CASE WHEN ranking = 6  THEN &&wait_class_colors_s.&&wait_class_colors2_s.&&wait_class_colors3_s.&&wait_class_colors4_s. END) series_06,'); 
    put('       MAX(CASE WHEN ranking = 7  THEN &&wait_class_colors_s.&&wait_class_colors2_s.&&wait_class_colors3_s.&&wait_class_colors4_s. END) series_07,'); 
    put('       MAX(CASE WHEN ranking = 8  THEN &&wait_class_colors_s.&&wait_class_colors2_s.&&wait_class_colors3_s.&&wait_class_colors4_s. END) series_08,'); 
    put('       MAX(CASE WHEN ranking = 9  THEN &&wait_class_colors_s.&&wait_class_colors2_s.&&wait_class_colors3_s.&&wait_class_colors4_s. END) series_09,'); 
    put('       MAX(CASE WHEN ranking = 10 THEN &&wait_class_colors_s.&&wait_class_colors2_s.&&wait_class_colors3_s.&&wait_class_colors4_s. END) series_10,');
    put('       MAX(CASE WHEN ranking = 11 THEN &&wait_class_colors_s.&&wait_class_colors2_s.&&wait_class_colors3_s.&&wait_class_colors4_s. END) series_11,');
    put('       MAX(CASE WHEN ranking = 12 THEN &&wait_class_colors_s.&&wait_class_colors2_s.&&wait_class_colors3_s.&&wait_class_colors4_s. END) series_12,');
    put('       MAX(CASE WHEN ranking = 13 THEN &&wait_class_colors_s.&&wait_class_colors2_s.&&wait_class_colors3_s.&&wait_class_colors4_s. END) series_13,');
    put('       MAX(CASE WHEN ranking = 14 THEN &&wait_class_colors_s.&&wait_class_colors2_s.&&wait_class_colors3_s.&&wait_class_colors4_s. END) series_14,');
    put('       MAX(CASE WHEN ranking = 15 THEN &&wait_class_colors_s.&&wait_class_colors2_s.&&wait_class_colors3_s.&&wait_class_colors4_s. END) series_15 ');
    --
    put('  FROM (SELECT 1 fake, object_node cpu_or_event, other_tag wait_class,');  -- added wait_class
    put('               ROW_NUMBER() OVER (ORDER BY COUNT(*) DESC) ranking');
    put('          FROM plan_table'); 
    put('         WHERE statement_id = ''SQLD360_ASH_DATA_MEM''');
    put('           AND /*cost*/ bytes = '||i.plan_hash_value);
    put('           AND remarks = ''&&sqld360_sqlid.''');
    put('         GROUP BY object_node, other_tag) ash,');  -- added other_tag
    put('       (SELECT 1 fake FROM dual) b'); -- this is in case there is no row in ASH
    put(' WHERE ash.fake(+) = b.fake');
    put('   AND ranking <= 15');
    put('/');

    put('SET DEF @');

    put('SELECT SUBSTR(''@evt_01.'',1,27) tit_01,'); 
    put('       SUBSTR(''@evt_02.'',1,27) tit_02,');
    put('       SUBSTR(''@evt_03.'',1,27) tit_03,');
    put('       SUBSTR(''@evt_04.'',1,27) tit_04,');
    put('       SUBSTR(''@evt_05.'',1,27) tit_05,');
    put('       SUBSTR(''@evt_06.'',1,27) tit_06,');
    put('       SUBSTR(''@evt_07.'',1,27) tit_07,');
    put('       SUBSTR(''@evt_08.'',1,27) tit_08,');
    put('       SUBSTR(''@evt_09.'',1,27) tit_09,');
    put('       SUBSTR(''@evt_10.'',1,27) tit_10,'); 
    put('       SUBSTR(''@evt_11.'',1,27) tit_11,');
    put('       SUBSTR(''@evt_12.'',1,27) tit_12,');
    put('       SUBSTR(''@evt_13.'',1,27) tit_13,');
    put('       SUBSTR(''@evt_14.'',1,27) tit_14,');
    put('       SUBSTR(''@evt_15.'',1,27) tit_15');
    put('  FROM DUAL');
    put('/');

    put('COL e01 NOPRI');
    put('COL e02 NOPRI');
    put('COL e03 NOPRI');
    put('COL e04 NOPRI');
    put('COL e05 NOPRI');
    put('COL e06 NOPRI');
    put('COL e07 NOPRI');
    put('COL e08 NOPRI');
    put('COL e09 NOPRI');
    put('COL e10 NOPRI');
    put('COL e11 NOPRI');
    put('COL e12 NOPRI');
    put('COL e13 NOPRI');
    put('COL e14 NOPRI');
    put('COL e15 NOPRI');

    put('BEGIN');
    put(' :sql_text := ''');
    put('SELECT 0 snap_id,');
    put('       TO_CHAR(sample_time, ''''YYYY-MM-DD HH24:MI'''') begin_time,'); 
    put('       TO_CHAR(sample_time, ''''YYYY-MM-DD HH24:MI'''') end_time,');
    put('       NVL(aas_01,0) "e01@tit_01." ,');
    put('       NVL(aas_02,0) "e02@tit_02." ,');
    put('       NVL(aas_03,0) "e03@tit_03." ,');
    put('       NVL(aas_04,0) "e04@tit_04." ,');
    put('       NVL(aas_05,0) "e05@tit_05." ,');
    put('       NVL(aas_06,0) "e06@tit_06." ,');
    put('       NVL(aas_07,0) "e07@tit_07." ,');
    put('       NVL(aas_08,0) "e08@tit_08." ,');
    put('       NVL(aas_09,0) "e09@tit_09." ,');
    put('       NVL(aas_10,0) "e10@tit_10." ,');
    put('       NVL(aas_11,0) "e11@tit_11." ,');
    put('       NVL(aas_12,0) "e12@tit_12." ,');
    put('       NVL(aas_13,0) "e13@tit_13." ,');
    put('       NVL(aas_14,0) "e14@tit_14." ,');
    put('       NVL(aas_15,0) "e15@tit_15." ');
    put('  FROM (SELECT sample_time,');
    put('               MAX(CASE WHEN cpu_or_event  = ''''@evt_01.'''' THEN aas ELSE NULL END) aas_01,'); 
    put('               MAX(CASE WHEN cpu_or_event  = ''''@evt_02.'''' THEN aas ELSE NULL END) aas_02,'); 
    put('               MAX(CASE WHEN cpu_or_event  = ''''@evt_03.'''' THEN aas ELSE NULL END) aas_03,'); 
    put('               MAX(CASE WHEN cpu_or_event  = ''''@evt_04.'''' THEN aas ELSE NULL END) aas_04,'); 
    put('               MAX(CASE WHEN cpu_or_event  = ''''@evt_05.'''' THEN aas ELSE NULL END) aas_05,'); 
    put('               MAX(CASE WHEN cpu_or_event  = ''''@evt_06.'''' THEN aas ELSE NULL END) aas_06,'); 
    put('               MAX(CASE WHEN cpu_or_event  = ''''@evt_07.'''' THEN aas ELSE NULL END) aas_07,'); 
    put('               MAX(CASE WHEN cpu_or_event  = ''''@evt_08.'''' THEN aas ELSE NULL END) aas_08,'); 
    put('               MAX(CASE WHEN cpu_or_event  = ''''@evt_09.'''' THEN aas ELSE NULL END) aas_09,'); 
    put('               MAX(CASE WHEN cpu_or_event  = ''''@evt_10.'''' THEN aas ELSE NULL END) aas_10,'); 
    put('               MAX(CASE WHEN cpu_or_event  = ''''@evt_11.'''' THEN aas ELSE NULL END) aas_11,');  
    put('               MAX(CASE WHEN cpu_or_event  = ''''@evt_12.'''' THEN aas ELSE NULL END) aas_12,');  
    put('               MAX(CASE WHEN cpu_or_event  = ''''@evt_13.'''' THEN aas ELSE NULL END) aas_13,');  
    put('               MAX(CASE WHEN cpu_or_event  = ''''@evt_14.'''' THEN aas ELSE NULL END) aas_14,');  
    put('               MAX(CASE WHEN cpu_or_event  = ''''@evt_15.'''' THEN aas ELSE NULL END) aas_15'); 
    put('          FROM (SELECT TRUNC(sample_time, ''''mi'''') sample_time,');
    put('                       cpu_or_event,');
    put('                       ROUND(SUM(num_sess)/60,3) aas');
    put('                  FROM (SELECT timestamp sample_time,');
    put('                               object_node cpu_or_event,'); 
    put('                               count(*) num_sess');
    put('                          FROM plan_table');
    put('                         WHERE statement_id = ''''SQLD360_ASH_DATA_MEM''''');
    put('                           AND remarks = ''''&&sqld360_sqlid.''''');
    put('                           AND ''''&&diagnostics_pack.'''' = ''''Y''''');
    put('                           AND /*cost*/ bytes = '||i.plan_hash_value);
    put('                           AND object_node IN (''''@evt_01.'''',''''@evt_02.'''',''''@evt_03.'''',''''@evt_04.'''',''''@evt_05.'''',''''@evt_06.'''',');
    put('                                               ''''@evt_07.'''',''''@evt_08.'''',''''@evt_09.'''',''''@evt_10.'''',''''@evt_11.'''',''''@evt_12.'''',');
    put('                                               ''''@evt_13.'''',''''@evt_14.'''',''''@evt_15.'''')');
    put('                         GROUP BY timestamp, object_node)');
    put('                 GROUP BY TRUNC(sample_time, ''''mi''''), cpu_or_event)');
    put('         GROUP BY sample_time)');
    put(' ORDER BY 3 ');
    put(''';');
    put('END;');
    put('/ ');

    put('SET DEF &');
    put('@sql/sqld360_9a_pre_one.sql');

    put('COL evt01_ PRI');
    put('COL evt02_ PRI');
    put('COL evt03_ PRI');
    put('COL evt04_ PRI');
    put('COL evt05_ PRI');
    put('COL evt06_ PRI');
    put('COL evt07_ PRI');
    put('COL evt08_ PRI');
    put('COL evt09_ PRI');
    put('COL evt10_ PRI');
    put('COL evt11_ PRI');
    put('COL evt12_ PRI');
    put('COL evt13_ PRI');
    put('COL evt14_ PRI');
    put('COL evt15_ PRI');

    put('UNDEF evt_01'); 
    put('UNDEF evt_02'); 
    put('UNDEF evt_03'); 
    put('UNDEF evt_04'); 
    put('UNDEF evt_05'); 
    put('UNDEF evt_06'); 
    put('UNDEF evt_07'); 
    put('UNDEF evt_08'); 
    put('UNDEF evt_09'); 
    put('UNDEF evt_10'); 
    put('UNDEF evt_11'); 
    put('UNDEF evt_12'); 
    put('UNDEF evt_13'); 
    put('UNDEF evt_14'); 
    put('UNDEF evt_15');    

    -- to play with colors
    put('DEF series_01 = '''' '); 
    put('DEF series_02 = '''' '); 
    put('DEF series_03 = '''' '); 
    put('DEF series_04 = '''' '); 
    put('DEF series_05 = '''' '); 
    put('DEF series_06 = '''' '); 
    put('DEF series_07 = '''' '); 
    put('DEF series_08 = '''' '); 
    put('DEF series_09 = '''' '); 
    put('DEF series_10 = '''' '); 
    put('DEF series_11 = '''' '); 
    put('DEF series_12 = '''' '); 
    put('DEF series_13 = '''' '); 
    put('DEF series_14 = '''' '); 
    put('DEF series_15 = '''' ');


    put('----------------------------');

    put('DEF title=''Top 15 Wait events over historical time for PHV '||i.plan_hash_value||'''');
    put('DEF main_table = ''DBA_HIST_ACTIVE_SESS_HISTORY''');
    put('DEF skip_lch=''''');
    put('DEF chartype = ''AreaChart''');
    put('DEF stacked = ''isStacked: true,''');
    put('DEF abstract = ''AAS (stacked) per top 15 wait events over time''');
    put('DEF vaxis = ''Average Active Sessions - AAS (stacked)''');

    -- this looks confusing but it actually has a reason :-)
    -- tit_n is used to show / hide the column in the chart (in case of nulls)
    -- evt_n is used as filter value (populated dynamically)
    -- eN  is used to hosw / hide the column in the resultset (in case of nulls)

    put('COL evt_01 NEW_V evt_01'); 
    put('COL evt_02 NEW_V evt_02'); 
    put('COL evt_03 NEW_V evt_03'); 
    put('COL evt_04 NEW_V evt_04'); 
    put('COL evt_05 NEW_V evt_05'); 
    put('COL evt_06 NEW_V evt_06'); 
    put('COL evt_07 NEW_V evt_07'); 
    put('COL evt_08 NEW_V evt_08'); 
    put('COL evt_09 NEW_V evt_09'); 
    put('COL evt_10 NEW_V evt_10'); 
    put('COL evt_11 NEW_V evt_11'); 
    put('COL evt_12 NEW_V evt_12'); 
    put('COL evt_13 NEW_V evt_13'); 
    put('COL evt_14 NEW_V evt_14'); 
    put('COL evt_15 NEW_V evt_15');
    put('COL tit_01 NEW_V tit_01'); 
    put('COL tit_02 NEW_V tit_02'); 
    put('COL tit_03 NEW_V tit_03'); 
    put('COL tit_04 NEW_V tit_04'); 
    put('COL tit_05 NEW_V tit_05'); 
    put('COL tit_06 NEW_V tit_06'); 
    put('COL tit_07 NEW_V tit_07'); 
    put('COL tit_08 NEW_V tit_08'); 
    put('COL tit_09 NEW_V tit_09'); 
    put('COL tit_10 NEW_V tit_10'); 
    put('COL tit_11 NEW_V tit_11'); 
    put('COL tit_12 NEW_V tit_12'); 
    put('COL tit_13 NEW_V tit_13'); 
    put('COL tit_14 NEW_V tit_14'); 
    put('COL tit_15 NEW_V tit_15'); 

    -- this is to determine series color
    put('COL series_01 NEW_V series_01'); 
    put('COL series_02 NEW_V series_02'); 
    put('COL series_03 NEW_V series_03'); 
    put('COL series_04 NEW_V series_04'); 
    put('COL series_05 NEW_V series_05'); 
    put('COL series_06 NEW_V series_06'); 
    put('COL series_07 NEW_V series_07'); 
    put('COL series_08 NEW_V series_08'); 
    put('COL series_09 NEW_V series_09'); 
    put('COL series_10 NEW_V series_10'); 
    put('COL series_11 NEW_V series_11'); 
    put('COL series_12 NEW_V series_12'); 
    put('COL series_13 NEW_V series_13'); 
    put('COL series_14 NEW_V series_14'); 
    put('COL series_15 NEW_V series_15');     

    put('SELECT MAX(CASE WHEN ranking = 1  THEN cpu_or_event ELSE '''' END) evt_01,');
    put('       MAX(CASE WHEN ranking = 2  THEN cpu_or_event ELSE '''' END) evt_02,');              
    put('       MAX(CASE WHEN ranking = 3  THEN cpu_or_event ELSE '''' END) evt_03,'); 
    put('       MAX(CASE WHEN ranking = 4  THEN cpu_or_event ELSE '''' END) evt_04,'); 
    put('       MAX(CASE WHEN ranking = 5  THEN cpu_or_event ELSE '''' END) evt_05,'); 
    put('       MAX(CASE WHEN ranking = 6  THEN cpu_or_event ELSE '''' END) evt_06,'); 
    put('       MAX(CASE WHEN ranking = 7  THEN cpu_or_event ELSE '''' END) evt_07,'); 
    put('       MAX(CASE WHEN ranking = 8  THEN cpu_or_event ELSE '''' END) evt_08,'); 
    put('       MAX(CASE WHEN ranking = 9  THEN cpu_or_event ELSE '''' END) evt_09,'); 
    put('       MAX(CASE WHEN ranking = 10 THEN cpu_or_event ELSE '''' END) evt_10,');
    put('       MAX(CASE WHEN ranking = 11 THEN cpu_or_event ELSE '''' END) evt_11,');
    put('       MAX(CASE WHEN ranking = 12 THEN cpu_or_event ELSE '''' END) evt_12,');
    put('       MAX(CASE WHEN ranking = 13 THEN cpu_or_event ELSE '''' END) evt_13,');
    put('       MAX(CASE WHEN ranking = 14 THEN cpu_or_event ELSE '''' END) evt_14,');
    put('       MAX(CASE WHEN ranking = 15 THEN cpu_or_event ELSE '''' END) evt_15,');
    -- this is to determine series color
    put('       MAX(CASE WHEN ranking = 1  THEN &&wait_class_colors_s.&&wait_class_colors2_s.&&wait_class_colors3_s.&&wait_class_colors4_s. END) series_01,');
    put('       MAX(CASE WHEN ranking = 2  THEN &&wait_class_colors_s.&&wait_class_colors2_s.&&wait_class_colors3_s.&&wait_class_colors4_s. END) series_02,');              
    put('       MAX(CASE WHEN ranking = 3  THEN &&wait_class_colors_s.&&wait_class_colors2_s.&&wait_class_colors3_s.&&wait_class_colors4_s. END) series_03,'); 
    put('       MAX(CASE WHEN ranking = 4  THEN &&wait_class_colors_s.&&wait_class_colors2_s.&&wait_class_colors3_s.&&wait_class_colors4_s. END) series_04,'); 
    put('       MAX(CASE WHEN ranking = 5  THEN &&wait_class_colors_s.&&wait_class_colors2_s.&&wait_class_colors3_s.&&wait_class_colors4_s. END) series_05,'); 
    put('       MAX(CASE WHEN ranking = 6  THEN &&wait_class_colors_s.&&wait_class_colors2_s.&&wait_class_colors3_s.&&wait_class_colors4_s. END) series_06,'); 
    put('       MAX(CASE WHEN ranking = 7  THEN &&wait_class_colors_s.&&wait_class_colors2_s.&&wait_class_colors3_s.&&wait_class_colors4_s. END) series_07,'); 
    put('       MAX(CASE WHEN ranking = 8  THEN &&wait_class_colors_s.&&wait_class_colors2_s.&&wait_class_colors3_s.&&wait_class_colors4_s. END) series_08,'); 
    put('       MAX(CASE WHEN ranking = 9  THEN &&wait_class_colors_s.&&wait_class_colors2_s.&&wait_class_colors3_s.&&wait_class_colors4_s. END) series_09,'); 
    put('       MAX(CASE WHEN ranking = 10 THEN &&wait_class_colors_s.&&wait_class_colors2_s.&&wait_class_colors3_s.&&wait_class_colors4_s. END) series_10,');
    put('       MAX(CASE WHEN ranking = 11 THEN &&wait_class_colors_s.&&wait_class_colors2_s.&&wait_class_colors3_s.&&wait_class_colors4_s. END) series_11,');
    put('       MAX(CASE WHEN ranking = 12 THEN &&wait_class_colors_s.&&wait_class_colors2_s.&&wait_class_colors3_s.&&wait_class_colors4_s. END) series_12,');
    put('       MAX(CASE WHEN ranking = 13 THEN &&wait_class_colors_s.&&wait_class_colors2_s.&&wait_class_colors3_s.&&wait_class_colors4_s. END) series_13,');
    put('       MAX(CASE WHEN ranking = 14 THEN &&wait_class_colors_s.&&wait_class_colors2_s.&&wait_class_colors3_s.&&wait_class_colors4_s. END) series_14,');
    put('       MAX(CASE WHEN ranking = 15 THEN &&wait_class_colors_s.&&wait_class_colors2_s.&&wait_class_colors3_s.&&wait_class_colors4_s. END) series_15 ');
    --
    put('  FROM (SELECT 1 fake, object_node cpu_or_event, other_tag wait_class,');
    put('               ROW_NUMBER() OVER (ORDER BY COUNT(*) DESC) ranking');
    put('          FROM plan_table'); 
    put('         WHERE statement_id = ''SQLD360_ASH_DATA_HIST''');
    put('           AND /*cost*/ bytes = '||i.plan_hash_value);
    put('           AND remarks = ''&&sqld360_sqlid.''');
    put('         GROUP BY object_node, other_tag) ash,');
    put('       (SELECT 1 fake FROM dual) b'); -- this is in case there is no row in ASH
    put(' WHERE ash.fake(+) = b.fake');
    put('   AND ranking <= 15');
    put('/');

    put('SET DEF @');

    put('SELECT SUBSTR(''@evt_01.'',1,27) tit_01,'); 
    put('       SUBSTR(''@evt_02.'',1,27) tit_02,');
    put('       SUBSTR(''@evt_03.'',1,27) tit_03,');
    put('       SUBSTR(''@evt_04.'',1,27) tit_04,');
    put('       SUBSTR(''@evt_05.'',1,27) tit_05,');
    put('       SUBSTR(''@evt_06.'',1,27) tit_06,');
    put('       SUBSTR(''@evt_07.'',1,27) tit_07,');
    put('       SUBSTR(''@evt_08.'',1,27) tit_08,');
    put('       SUBSTR(''@evt_09.'',1,27) tit_09,');
    put('       SUBSTR(''@evt_10.'',1,27) tit_10,'); 
    put('       SUBSTR(''@evt_11.'',1,27) tit_11,');
    put('       SUBSTR(''@evt_12.'',1,27) tit_12,');
    put('       SUBSTR(''@evt_13.'',1,27) tit_13,');
    put('       SUBSTR(''@evt_14.'',1,27) tit_14,');
    put('       SUBSTR(''@evt_15.'',1,27) tit_15');
    put('  FROM DUAL');
    put('/');

    put('COL e01 NOPRI');
    put('COL e02 NOPRI');
    put('COL e03 NOPRI');
    put('COL e04 NOPRI');
    put('COL e05 NOPRI');
    put('COL e06 NOPRI');
    put('COL e07 NOPRI');
    put('COL e08 NOPRI');
    put('COL e09 NOPRI');
    put('COL e10 NOPRI');
    put('COL e11 NOPRI');
    put('COL e12 NOPRI');
    put('COL e13 NOPRI');
    put('COL e14 NOPRI');
    put('COL e15 NOPRI');

    put('BEGIN');
    put(' :sql_text := ''');
    put('SELECT 0 snap_id,');
    put('       TO_CHAR(sample_time, ''''YYYY-MM-DD HH24:MI'''') begin_time,'); 
    put('       TO_CHAR(sample_time, ''''YYYY-MM-DD HH24:MI'''') end_time,');
    put('       NVL(aas_01,0) "e01@tit_01." ,');
    put('       NVL(aas_02,0) "e02@tit_02." ,');
    put('       NVL(aas_03,0) "e03@tit_03." ,');
    put('       NVL(aas_04,0) "e04@tit_04." ,');
    put('       NVL(aas_05,0) "e05@tit_05." ,');
    put('       NVL(aas_06,0) "e06@tit_06." ,');
    put('       NVL(aas_07,0) "e07@tit_07." ,');
    put('       NVL(aas_08,0) "e08@tit_08." ,');
    put('       NVL(aas_09,0) "e09@tit_09." ,');
    put('       NVL(aas_10,0) "e10@tit_10." ,');
    put('       NVL(aas_11,0) "e11@tit_11." ,');
    put('       NVL(aas_12,0) "e12@tit_12." ,');
    put('       NVL(aas_13,0) "e13@tit_13." ,');
    put('       NVL(aas_14,0) "e14@tit_14." ,');
    put('       NVL(aas_15,0) "e15@tit_15." ');
    put('  FROM (SELECT sample_time,');
    put('               MAX(CASE WHEN cpu_or_event  = ''''@evt_01.'''' THEN aas ELSE NULL END) aas_01,'); 
    put('               MAX(CASE WHEN cpu_or_event  = ''''@evt_02.'''' THEN aas ELSE NULL END) aas_02,'); 
    put('               MAX(CASE WHEN cpu_or_event  = ''''@evt_03.'''' THEN aas ELSE NULL END) aas_03,'); 
    put('               MAX(CASE WHEN cpu_or_event  = ''''@evt_04.'''' THEN aas ELSE NULL END) aas_04,'); 
    put('               MAX(CASE WHEN cpu_or_event  = ''''@evt_05.'''' THEN aas ELSE NULL END) aas_05,'); 
    put('               MAX(CASE WHEN cpu_or_event  = ''''@evt_06.'''' THEN aas ELSE NULL END) aas_06,'); 
    put('               MAX(CASE WHEN cpu_or_event  = ''''@evt_07.'''' THEN aas ELSE NULL END) aas_07,'); 
    put('               MAX(CASE WHEN cpu_or_event  = ''''@evt_08.'''' THEN aas ELSE NULL END) aas_08,'); 
    put('               MAX(CASE WHEN cpu_or_event  = ''''@evt_09.'''' THEN aas ELSE NULL END) aas_09,'); 
    put('               MAX(CASE WHEN cpu_or_event  = ''''@evt_10.'''' THEN aas ELSE NULL END) aas_10,'); 
    put('               MAX(CASE WHEN cpu_or_event  = ''''@evt_11.'''' THEN aas ELSE NULL END) aas_11,');  
    put('               MAX(CASE WHEN cpu_or_event  = ''''@evt_12.'''' THEN aas ELSE NULL END) aas_12,');  
    put('               MAX(CASE WHEN cpu_or_event  = ''''@evt_13.'''' THEN aas ELSE NULL END) aas_13,');  
    put('               MAX(CASE WHEN cpu_or_event  = ''''@evt_14.'''' THEN aas ELSE NULL END) aas_14,');  
    put('               MAX(CASE WHEN cpu_or_event  = ''''@evt_15.'''' THEN aas ELSE NULL END) aas_15'); 
    put('          FROM (SELECT TRUNC(sample_time, ''''hh24'''') sample_time,');
    put('                       cpu_or_event,');
    put('                       ROUND(SUM(num_sess)*&&sqld360_ashtimevalue./3600,3) aas');  -- *10 because the best we can do is assume the session spent the whole 10 secs on that event
    put('                  FROM (SELECT timestamp sample_time,');
    put('                               object_node cpu_or_event,'); 
    put('                               count(*) num_sess');
    put('                          FROM plan_table');
    put('                         WHERE statement_id = ''''SQLD360_ASH_DATA_HIST''''');
    put('                           AND remarks = ''''&&sqld360_sqlid.''''');
    put('                           AND ''''&&diagnostics_pack.'''' = ''''Y''''');
    put('                           AND /*cost*/ bytes = '||i.plan_hash_value);
    put('                           AND object_node IN (''''@evt_01.'''',''''@evt_02.'''',''''@evt_03.'''',''''@evt_04.'''',''''@evt_05.'''',''''@evt_06.'''',');
    put('                                               ''''@evt_07.'''',''''@evt_08.'''',''''@evt_09.'''',''''@evt_10.'''',''''@evt_11.'''',''''@evt_12.'''',');
    put('                                               ''''@evt_13.'''',''''@evt_14.'''',''''@evt_15.'''')');
    put('                         GROUP BY timestamp, object_node)');
    put('                 GROUP BY TRUNC(sample_time, ''''hh24''''), cpu_or_event)');
    put('         GROUP BY sample_time)');
    put(' ORDER BY 3 ');
    put(''';');
    put('END;');
    put('/ ');

    put('SET DEF &');
    put('@sql/sqld360_9a_pre_one.sql');

    put('COL evt01_ PRI');
    put('COL evt02_ PRI');
    put('COL evt03_ PRI');
    put('COL evt04_ PRI');
    put('COL evt05_ PRI');
    put('COL evt06_ PRI');
    put('COL evt07_ PRI');
    put('COL evt08_ PRI');
    put('COL evt09_ PRI');
    put('COL evt10_ PRI');
    put('COL evt11_ PRI');
    put('COL evt12_ PRI');
    put('COL evt13_ PRI');
    put('COL evt14_ PRI');
    put('COL evt15_ PRI');

    put('SET TERM ON');

    put('UNDEF evt_01'); 
    put('UNDEF evt_02'); 
    put('UNDEF evt_03'); 
    put('UNDEF evt_04'); 
    put('UNDEF evt_05'); 
    put('UNDEF evt_06'); 
    put('UNDEF evt_07'); 
    put('UNDEF evt_08'); 
    put('UNDEF evt_09'); 
    put('UNDEF evt_10'); 
    put('UNDEF evt_11'); 
    put('UNDEF evt_12'); 
    put('UNDEF evt_13'); 
    put('UNDEF evt_14'); 
    put('UNDEF evt_15'); 

    -- to play with colors
    put('DEF series_01 = '''' '); 
    put('DEF series_02 = '''' '); 
    put('DEF series_03 = '''' '); 
    put('DEF series_04 = '''' '); 
    put('DEF series_05 = '''' '); 
    put('DEF series_06 = '''' '); 
    put('DEF series_07 = '''' '); 
    put('DEF series_08 = '''' '); 
    put('DEF series_09 = '''' '); 
    put('DEF series_10 = '''' '); 
    put('DEF series_11 = '''' '); 
    put('DEF series_12 = '''' '); 
    put('DEF series_13 = '''' '); 
    put('DEF series_14 = '''' '); 
    put('DEF series_15 = '''' ');


    put('----------------------------');

    -- v1601, top SQL_EXEC_ID

    put('SPO &&one_spool_filename..html APP;     ');
    put('PRO </ol>                               ');
    put('PRO <h2>Top Executions from memory</h2> ');
    put('SET DEF @                               ');
    put('PRO <ol start="@report_sequence.">      ');
    put('SET DEF &                               ');
    put('SPO OFF                                 ');

    FOR j IN (SELECT inst_id, session_id, session_serial#, sql_exec_id, sql_exec_start, TO_CHAR(min_sample_time, 'YYYYMMDDHH24MISS') min_sample_time, TO_CHAR(max_sample_time, 'YYYYMMDDHH24MISS') max_sample_time
                FROM (SELECT inst_id, session_id, session_serial#, sql_exec_id, sql_exec_start,  MIN(sample_time) min_sample_time, MAX(sample_time) max_sample_time, COUNT(*) num_samples
                        FROM (SELECT NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,',',1,3)+1,INSTR(partition_stop,',',1,4)-INSTR(partition_stop,',',1,3)-1)),position) inst_id,  
                                     NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,',',1,4)+1,INSTR(partition_stop,',',1,5)-INSTR(partition_stop,',',1,4)-1)),cpu_cost) session_id,  
                                     NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,',',1,5)+1,INSTR(partition_stop,',',1,6)-INSTR(partition_stop,',',1,5)-1)),io_cost) session_serial#, 
                                     timestamp sample_time, 
                                     NVL(partition_id, FIRST_VALUE(partition_id IGNORE NULLS) OVER (PARTITION BY NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,',',1,3)+1,INSTR(partition_stop,',',1,4)-INSTR(partition_stop,',',1,3)-1)),position), 
                                                                                                                 NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,',',1,4)+1,INSTR(partition_stop,',',1,5)-INSTR(partition_stop,',',1,4)-1)),cpu_cost), 
                                                                                                                 NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,',',1,5)+1,INSTR(partition_stop,',',1,6)-INSTR(partition_stop,',',1,5)-1)),io_cost) 
                                                                                                    ORDER BY timestamp ROWS BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING)) sql_exec_id, 
                                     NVL(distribution, FIRST_VALUE(distribution IGNORE NULLS) OVER (PARTITION BY NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,',',1,3)+1,INSTR(partition_stop,',',1,4)-INSTR(partition_stop,',',1,3)-1)),position), 
                                                                                                                 NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,',',1,4)+1,INSTR(partition_stop,',',1,5)-INSTR(partition_stop,',',1,4)-1)),cpu_cost), 
                                                                                                                 NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,',',1,5)+1,INSTR(partition_stop,',',1,6)-INSTR(partition_stop,',',1,5)-1)),io_cost)
                                                                                                    ORDER BY timestamp ROWS BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING)) sql_exec_start 
                                FROM plan_table 
                               WHERE statement_id = 'SQLD360_ASH_DATA_MEM'
                                 AND /*cost*/ bytes =  i.plan_hash_value
                                 AND '&&diagnostics_pack.' = 'Y'
                                 AND remarks = '&&sqld360_sqlid.')
                      WHERE sql_exec_id IS NOT NULL
                      GROUP BY inst_id, session_id, session_serial#, sql_exec_id, sql_exec_start
                      ORDER BY num_samples DESC)
             WHERE ROWNUM <= &&sqld360_conf_num_top_execs.) LOOP

       put('SPO &&one_spool_filename..html APP;');
       put('PRO SQL_EXEC_ID '||j.sql_exec_id||' from inst:'||j.inst_id||' sess:'||j.session_id||' serial#:'||j.session_serial#||' between '||TO_DATE(j.min_sample_time,'YYYYMMDDHH24MISS')||' and '||TO_DATE(j.max_sample_time,'YYYYMMDDHH24MISS')||' ');
       put('SPO OFF');

       put('----------------------------');

       put('COL treeColor NEW_V treeColor');
    
       -- not the most elegant soluton but SQL*Plus variable cannot store long string (aka long exec plans)
       put('DELETE plan_table WHERE statement_id = ''SQLD360_TREECOLOR'' AND operation = ''&&sqld360_sqlid.''; ');
       put(q'[INSERT ALL                                                                                                                                                                                  ]');
       put(q'[  WHEN 1 = 1 THEN INTO plan_table (statement_id, OPERATION, OPTIONS) VALUES ('SQLD360_TREECOLOR', '&&sqld360_sqlid.', node_color)                                                           ]');
       put(q'[  WHEN 1 = 1 THEN INTO plan_table (statement_id, OPERATION, OPTIONS) VALUES ('SQLD360_TREECOLOR', '&&sqld360_sqlid.', expanded_node_color)                                                  ]');
       put(q'[  WHEN 1 = 1 THEN INTO plan_table (statement_id, OPERATION, OPTIONS) VALUES ('SQLD360_TREECOLOR', '&&sqld360_sqlid.', collapsed_node_color)                                                 ]');
       put(q'[WITH ashdata AS (-- count the number of samples in ASH for each step                                                                                                                        ]');
       put(q'[                 -- goal is to compute RATIO_TO_REPORT                                                                                                                                      ]');
       put(q'[                 SELECT NVL(id,0) id,                                                                                                                                                       ]');
       put(q'[                        COUNT(*) num_samples,                                                                                                                                               ]');
       put(q'[                        ROUND(100*NVL(RATIO_TO_REPORT(COUNT(*)) OVER (),0),2) perc_impact                                                                                                   ]');
       put(q'[                   FROM plan_table                                                                                                                                                          ]');
       put(q'[                  WHERE statement_id = 'SQLD360_ASH_DATA_MEM'                                                                                                                               ]');
       -- skipping the filter on PHV to include also rows with SQL_PLAN_HASH_VALUE = 0 
       put(q'[                    AND /*cost*/ bytes =]'|| i.plan_hash_value                                                                                                                                );   
       put(q'[                    AND NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,',',1,3)+1,INSTR(partition_stop,',',1,4)-INSTR(partition_stop,',',1,3)-1)),position) = ]'||j.inst_id         );
       put(q'[                    AND NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,',',1,4)+1,INSTR(partition_stop,',',1,5)-INSTR(partition_stop,',',1,4)-1)),cpu_cost) = ]'||j.session_id      );
       put(q'[                    AND NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,',',1,5)+1,INSTR(partition_stop,',',1,6)-INSTR(partition_stop,',',1,5)-1)),io_cost) = ]' ||j.session_serial# );
       put(q'[                    AND timestamp BETWEEN TO_DATE(']'||j.min_sample_time||q'[', 'YYYYMMDDHH24MISS') AND TO_DATE(']'||j.max_sample_time||q'[', 'YYYYMMDDHH24MISS')                           ]');
       put(q'[                    AND remarks = '&&sqld360_sqlid.'                                                                                                                                        ]');
       -- this is to differentiate data from partial exec of overlapping executions (case from my German friend)
       put(q'[                    AND NVL(partition_id, ]'||j.sql_exec_id||q'[) = ]'||j.sql_exec_id                                                                                                         ); 
       put(q'[                    AND NVL(distribution, TO_DATE(']'||j.sql_exec_start||q'[', 'YYYYMMDDHH24MISS')) = TO_DATE(]'||j.sql_exec_start||q'[, 'YYYYMMDDHH24MISS')                                ]');
       --
       put(q'[                  GROUP BY NVL(id,0)),                                                                                                                                                      ]');
       put(q'[     orig_plan AS (-- extract the plan steps "as is", just replace to single quote in the filter predicates                                                                                 ]');
       put(q'[                   -- precedence is given to plan from memory since it has filters                                                                                                          ]');
       put(q'[                   -- using RANK since there could be more than one entry but with different predicate ordering                                                                             ]');
       put(q'[                   SELECT sql_id, plan_hash_value, id, parent_id, operation, options, object_name, access_predicates, filter_predicates, other_xml                                          ]');
       put(q'[                     FROM (SELECT sql_id, plan_hash_value, id, parent_id, operation, options, object_name,                                                                                  ]');
       put(q'[                                  REPLACE(SUBSTR(access_predicates,1,1500), CHR(39) , CHR(92)||CHR(39)) access_predicates,                                                                  ]');
       put(q'[                                  REPLACE(SUBSTR(filter_predicates,1,1500), CHR(39) , CHR(92)||CHR(39)) filter_predicates,                                                                  ]');
       put(q'[                                  other_xml,                                                                                                                                                ]');
       put(q'[                                  RANK() OVER (ORDER BY inst_id, child_number) rnk                                                                                                          ]');
       put(q'[                             FROM gv$sql_plan_statistics_all                                                                                                                                ]');
       put(q'[                            WHERE sql_id = '&&sqld360_sqlid.'                                                                                                                               ]');            
       put(q'[                              AND plan_hash_value =]'||i.plan_hash_value||q'[)                                                                                                              ]');                                                             
       put(q'[                    WHERE rnk = 1                                                                                                                                                           ]');
       put(q'[                   UNION ALL                                                                                                                                                                ]');
       put(q'[                   SELECT sql_id, plan_hash_value, id, parent_id, operation, options, object_name,                                                                                          ]');
       put(q'[                          REPLACE(access_predicates, CHR(39), CHR(92)||CHR(39)) access_predicates,                                                                                          ]');
       put(q'[                          REPLACE(filter_predicates, CHR(39), CHR(92)||CHR(39)) filter_predicates,                                                                                          ]');
       put(q'[                          other_xml                                                                                                                                                         ]');
       put(q'[                     FROM dba_hist_sql_plan                                                                                                                                                 ]');
       put(q'[                    WHERE sql_id = '&&sqld360_sqlid.'                                                                                                                                       ]');
       put(q'[                      AND plan_hash_value =]'||i.plan_hash_value                                                                                                                              );
       put(q'[                      AND NOT EXISTS (SELECT 1                                                                                                                                              ]');  
       put(q'[                                        FROM gv$sql_plan_statistics_all                                                                                                                     ]');
       put(q'[                                       WHERE plan_hash_value =]'||i.plan_hash_value                                                                                                           );
       put(q'[                                         AND sql_id = '&&sqld360_sqlid.'                                                                                                                    ]');
       put(q'[                                         AND '&&diagnostics_pack.' = 'Y')),                                                                                                                 ]');
       put(q'[     skip_steps AS (-- extract the display_map for the plan, to identify why steps are "skipped" because of adaptive                                                                        ]');
       put(q'[                    SELECT sql_id, plan_hash_value, EXTRACTVALUE(VALUE(b),'/row/@op') stepid, EXTRACTVALUE(VALUE(b),'/row/@skp') skp, EXTRACTVALUE(VALUE(b),'/row/@dep') dep                ]');
       put(q'[                      FROM orig_plan a,                                                                                                                                                     ]');
       put(q'[                           TABLE(XMLSEQUENCE(EXTRACT(XMLTYPE(a.other_xml),'/*/display_map/row'))) b                                                                                         ]');
       put(q'[                     WHERE sql_id = '&&sqld360_sqlid.'                                                                                                                                      ]'); 
       put(q'[                       AND other_xml IS NOT NULL),                                                                                                                                          ]');
       put(q'[     adapt_plan_no_parent AS (-- generate adaptive_id (aka step_id) once the adaptive steps are excluded                                                                                    ]');
       put(q'[                              SELECT a.sql_id, a.plan_hash_value, a.id, a.parent_id, b.dep,                                                                                                 ]');
       put(q'[                                     (ROW_NUMBER() OVER (ORDER BY a.id))-1 adapt_id, a.operation, a.options, a.object_name, a.access_predicates, a.filter_predicates, b.skp                 ]');
       put(q'[                                FROM orig_plan a,                                                                                                                                           ]');
       put(q'[                                     skip_steps b                                                                                                                                           ]');
       put(q'[                               WHERE a.id = b.stepid(+)                                                                                                                                     ]');
       put(q'[                                 AND (b.skp = 0 OR b.skp IS NULL)),                                                                                                                         ]');
       put(q'[     full_adaptive_plan AS (-- generate the parent adaptive step id                                                                                                                         ]');
       put(q'[                            SELECT id, adapt_id, NVL(adapt_parent_id, parent_id) parent_id, operation, options, object_name, access_predicates, filter_predicates                           ]');
       put(q'[                              FROM (SELECT dep, adapt_id, id, (SELECT MAX(adapt_id) FROM adapt_plan_no_parent b WHERE a.dep-1 = NVL(b.dep,0) AND b.adapt_id < a.adapt_id ) adapt_parent_id,        ]');
       put(q'[                                           parent_id, a.operation operation, a.options, a.object_name, a.access_predicates, a.filter_predicates                                             ]');
       put(q'[                                      FROM adapt_plan_no_parent a)),                                                                                                                        ]');
       put(q'[     plan_with_ash AS (SELECT full_adaptive_plan.*, NVL(ashdata.num_samples,0) num_samples, NVL(ashdata.perc_impact,0) perc_impact                                                          ]');
       put(q'[                              FROM full_adaptive_plan,                                                                                                                                      ]');
       put(q'[                                   ashdata                                                                                                                                                  ]');
       put(q'[                             WHERE ashdata.id(+) = full_adaptive_plan.id),                                                                                                                  ]');
       put(q'[     plan_with_rec_impact AS (-- compute recursive impact (substree impact)                                                                                                                 ]');
       put(q'[                              SELECT a.*, (SELECT sum(b.perc_impact)                                                                                                                        ]');
       put(q'[                                             FROM plan_with_ash b                                                                                                                           ]');
       put(q'[                                            START WITH b.adapt_id = a.adapt_id                                                                                                                          ]');
       put(q'[                                           CONNECT BY prior b.adapt_id = b.parent_id) sum_perc_impact                                                                                             ]');
       put(q'[                                FROM plan_with_ash a)                                                                                                                                       ]');                                                                                  
       put(q'[SELECT adapt_id id,                                                                                                                                                                         ]');
       put(q'[       'data.setRowProperty('||adapt_id||', ''style'',          ''background:#FF'||LPAD(LTRIM(TO_CHAR(255-(255*perc_impact    /100),'XXXX')),2,'0')||CASE WHEN perc_impact = 0 THEN 'FF' ELSE '00' END||''');' node_color,               ]');
       put(q'[       'data.setRowProperty('||adapt_id||', ''expandedStyle'',  ''background:#FF'||LPAD(LTRIM(TO_CHAR(255-(255*perc_impact    /100),'XXXX')),2,'0')||CASE WHEN perc_impact = 0 THEN 'FF' ELSE '00' END||''');' expanded_node_color,      ]');
       put(q'[       'data.setRowProperty('||adapt_id||', ''collapsedStyle'', ''background:#FF'||LPAD(LTRIM(TO_CHAR(255-(255*sum_perc_impact/100),'XXXX')),2,'0')||CASE WHEN sum_perc_impact = 0 THEN 'FF' ELSE '00' END||''');' collapsed_node_color  ]');  
       put(q'[  FROM plan_with_rec_impact                                                                                                                                                                 ]');
       put(q'[ ORDER BY adapt_id;                                                                                                                                                                         ]'); 

       -- new in 1705
       put('DEF title=''Plan Tree with subtree for SQL_EXEC_ID '||j.sql_exec_id||' of PHV '||i.plan_hash_value||'''');
       put(q'[DEF main_table = 'GV$ACTIVE_SESSION_HISTORY']');
       put(q'[DEF skip_html='Y' ]');
       put(q'[DEF skip_text='Y' ]');
       put(q'[DEF skip_csv='Y'  ]');
       put(q'[DEF skip_tch=''   ]');

       put( 'BEGIN');
       put(q'[ :sql_text := ' ]');
       put(q'[WITH ashdata AS (-- count the number of samples in ASH for each step                                                                                                                 ]');
       put(q'[                 -- goal is to compute RATIO_TO_REPORT                                                                                                                               ]');
       put(q'[                 SELECT NVL(id,0) id,                                                                                                                                                ]');
       put(q'[                        COUNT(*) num_samples,                                                                                                                                        ]');
       put(q'[                        ROUND(100*NVL(RATIO_TO_REPORT(COUNT(*)) OVER (),0),2) perc_impact                                                                                            ]');
       put(q'[                   FROM plan_table                                                                                                                                                   ]');
       put(q'[                  WHERE statement_id LIKE ''SQLD360_ASH_DATA_MEM''                                                                                                                   ]');
       -- skipping the filter on PHV to include also rows with SQL_PLAN_HASH_VALUE = 0        
       put(q'[                    AND /*cost*/ bytes =]'|| i.plan_hash_value                                                                                                                         ); 
       put(q'[                    AND NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'','',1,3)+1,INSTR(partition_stop,'','',1,4)-INSTR(partition_stop,'','',1,3)-1)),position) = ]'||j.inst_id         );
       put(q'[                    AND NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'','',1,4)+1,INSTR(partition_stop,'','',1,5)-INSTR(partition_stop,'','',1,4)-1)),cpu_cost) = ]'||j.session_id      );
       put(q'[                    AND NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'','',1,5)+1,INSTR(partition_stop,'','',1,6)-INSTR(partition_stop,'','',1,5)-1)),io_cost) = ]' ||j.session_serial# );
       put(q'[                    AND timestamp BETWEEN TO_DATE('']'||j.min_sample_time||q'['', ''YYYYMMDDHH24MISS'') AND TO_DATE('']'||j.max_sample_time||q'['', ''YYYYMMDDHH24MISS'')                           ]');  
       put(q'[                    AND remarks = ''&&sqld360_sqlid.''                                                                                                                               ]');
       -- this is to differentiate data from partial exec of overlapping executions (case from my German friend)
       put(q'[                    AND NVL(partition_id, ]'||j.sql_exec_id||q'[) = ]'||j.sql_exec_id                                                                                                  ); 
       put(q'[                    AND NVL(distribution, TO_DATE('']'||j.sql_exec_start||q'['', ''YYYYMMDDHH24MISS'')) = TO_DATE('']'||j.sql_exec_start||q'['', ''YYYYMMDDHH24MISS'')               ]');
       -- 
       put(q'[                  GROUP BY NVL(id,0)),                                                                                                                                               ]');
       put(q'[     orig_plan AS (-- extract the plan steps "as is", just replace to single quote in the filter predicates                                                                          ]');
       put(q'[                   -- precedence is given to plan from memory since it has filters                                                                                                   ]');
       put(q'[                   -- using RANK since there could be more than one entry but with different predicate ordering                                                                      ]');
       put(q'[                   SELECT sql_id, plan_hash_value, id, parent_id, operation, options, object_name, access_predicates, filter_predicates, other_xml                                   ]');
       put(q'[                     FROM (SELECT sql_id, plan_hash_value, id, parent_id, operation, options, object_name,                                                                           ]');
       put(q'[                                  REPLACE(SUBSTR(access_predicates,1,1500), CHR(39) , CHR(92)||CHR(39)) access_predicates,                                                           ]');
       put(q'[                                  REPLACE(SUBSTR(filter_predicates,1,1500), CHR(39) , CHR(92)||CHR(39)) filter_predicates,                                                           ]');
       put(q'[                                  other_xml,                                                                                                                                         ]');
       put(q'[                                  RANK() OVER (ORDER BY inst_id, child_number) rnk                                                                                                   ]');
       put(q'[                             FROM gv$sql_plan_statistics_all                                                                                                                         ]');
       put(q'[                            WHERE sql_id = ''&&sqld360_sqlid.''                                                                                                                      ]');            
       put(q'[                              AND plan_hash_value =]'||i.plan_hash_value||q'[)                                                                                                       ]');                                                             
       put(q'[                    WHERE rnk = 1                                                                                                                                                    ]');
       put(q'[                   UNION ALL                                                                                                                                                         ]');
       put(q'[                   SELECT sql_id, plan_hash_value, id, parent_id, operation, options, object_name,                                                                                   ]');
       put(q'[                          REPLACE(access_predicates, CHR(39), CHR(92)||CHR(39)) access_predicates,                                                                                   ]');
       put(q'[                          REPLACE(filter_predicates, CHR(39), CHR(92)||CHR(39)) filter_predicates,                                                                                   ]');
       put(q'[                          other_xml                                                                                                                                                  ]');
       put(q'[                     FROM dba_hist_sql_plan                                                                                                                                          ]');
       put(q'[                    WHERE sql_id = ''&&sqld360_sqlid.''                                                                                                                              ]');
       put(q'[                      AND plan_hash_value =]'||i.plan_hash_value                                                                                                                       );
       put(q'[                      AND NOT EXISTS (SELECT 1                                                                                                                                       ]');  
       put(q'[                                        FROM gv$sql_plan_statistics_all                                                                                                              ]');
       put(q'[                                       WHERE plan_hash_value =]'||i.plan_hash_value                                                                                                    );
       put(q'[                                         AND sql_id = ''&&sqld360_sqlid.''                                                                                                           ]');
       put(q'[                                         AND ''&&diagnostics_pack.'' = ''Y'')),                                                                                                      ]');
       put(q'[     skip_steps AS (-- extract the display_map for the plan, to identify why steps are "skipped" because of adaptive                                                                 ]');
       put(q'[                    SELECT sql_id, plan_hash_value, EXTRACTVALUE(VALUE(b),''/row/@op'') stepid, EXTRACTVALUE(VALUE(b),''/row/@skp'') skp, EXTRACTVALUE(VALUE(b),''/row/@dep'') dep   ]');
       put(q'[                      FROM orig_plan a,                                                                                                                                              ]');
       put(q'[                           TABLE(XMLSEQUENCE(EXTRACT(XMLTYPE(a.other_xml),''/*/display_map/row''))) b                                                                                ]');
       put(q'[                     WHERE sql_id = ''&&sqld360_sqlid.''                                                                                                                             ]'); 
       put(q'[                       AND other_xml IS NOT NULL),                                                                                                                                   ]');
       put(q'[     adapt_plan_no_parent AS (-- generate adaptive_id (aka step_id) once the adaptive steps are excluded                                                                             ]');
       put(q'[                              SELECT a.sql_id, a.plan_hash_value, a.id, a.parent_id, b.dep,                                                                                          ]');
       put(q'[                                     (ROW_NUMBER() OVER (ORDER BY a.id))-1 adapt_id, a.operation, a.options, a.object_name, a.access_predicates, a.filter_predicates, b.skp          ]');
       put(q'[                                FROM orig_plan a,                                                                                                                                    ]');
       put(q'[                                     skip_steps b                                                                                                                                    ]');
       put(q'[                               WHERE a.id = b.stepid(+)                                                                                                                              ]');
       put(q'[                                 AND (b.skp = 0 OR b.skp IS NULL)),                                                                                                                  ]');
       put(q'[     full_adaptive_plan AS (-- generate the parent adaptive step id                                                                                                                  ]');
       put(q'[                            SELECT id, adapt_id, NVL(adapt_parent_id, parent_id) parent_id, operation, options, object_name, access_predicates, filter_predicates                    ]');
       put(q'[                              FROM (SELECT dep, adapt_id, id, (SELECT MAX(adapt_id) FROM adapt_plan_no_parent b WHERE a.dep-1 = NVL(b.dep,0) AND b.adapt_id < a.adapt_id ) adapt_parent_id, ]');
       put(q'[                                           parent_id, a.operation operation, a.options, a.object_name, a.access_predicates, a.filter_predicates                                      ]');
       put(q'[                                      FROM adapt_plan_no_parent a)),                                                                                                                 ]');
       put(q'[     plan_with_ash AS (SELECT full_adaptive_plan.*, NVL(ashdata.num_samples,0) num_samples, NVL(ashdata.perc_impact,0) perc_impact                                                   ]');
       put(q'[                              FROM full_adaptive_plan,                                                                                                                               ]');
       put(q'[                                   ashdata                                                                                                                                           ]');
       put(q'[                             WHERE ashdata.id(+) = full_adaptive_plan.id),                                                                                                           ]');
       put(q'[     plan_with_rec_impact AS (-- compute recursive impact (substree impact)                                                                                                          ]');
       put(q'[                              SELECT a.*, (SELECT sum(b.perc_impact)                                                                                                                 ]');
       put(q'[                                             FROM plan_with_ash b                                                                                                                    ]');
       put(q'[                                            START WITH b.adapt_id = a.adapt_id                                                                                                                   ]');
       put(q'[                                           CONNECT BY prior b.adapt_id = b.parent_id) sum_perc_impact                                                                                      ]');
       put(q'[                                FROM plan_with_ash a)                                                                                                                                ]');                                                                                  
       put(q'[SELECT ''{v: ''''''||adapt_id||'''''',f: ''''''||adapt_id||'' - ''||operation||'' ''||options||NVL2(object_name,''<br>'','' '')||object_name||''''''}'' id,                          ]'); 
       put(q'[       parent_id,                                                                                                                                                                    ]');
       put(q'[       SUBSTR(''Step ID: ''||adapt_id||'' (ASH Step ID: ''||id||'')\nASH Samples: ''||num_samples||'' (''||perc_impact||''%)''||                                                     ]');
       put(q'[       ''\nSubstree Impact ''||sum_perc_impact||''%''||                                                                                                                              ]');
       put(q'[       NVL2(access_predicates,''\n\nAccess Predicates: ''||access_predicates,'''')||NVL2(filter_predicates,''\n\nFilter Predicates: ''||filter_predicates,''''),1,4000) message,     ]');
       put(q'[       adapt_id id3                                                                                                                                                                  ]');
       put(q'[  FROM plan_with_rec_impact                                                                                                                                                          ]');
       put(q'[ ORDER BY id3                                                                                                                                                                        ]'); 
       put(''';');
       put('END;');
       put('/ ');
       put('@sql/sqld360_9a_pre_one.sql');

       put('----------------------------');

       put(q'[DEF title='Plan with rowsource statistics SQL_EXEC_ID ]'||j.sql_exec_id||' of PHV '||i.plan_hash_value||q'[']');
       put(q'[DEF main_table = 'GV$SQL_PLAN_MONITOR']');
       put(q'[DEF abstract = 'Execution plan with rowsource (coming from SQL Monitoring info)']');

       put( 'BEGIN');
       put(q'[ :sql_text := ' ]');

       put(q'[SELECT plan_line_id,                                                                 ]');
       put(q'[       LPAD(''.'',MAX(plan_depth),''.'')||plan_operation||'' ''||plan_options||'' ''||MAX(plan_object_owner)||NVL2(MAX(plan_object_name),''.'','''')||MAX(plan_object_name) step, ]');
       put(q'[       SUM(starts) starts,                                                           ]');
       put(q'[       MAX(plan_cardinality) e_rows,                                                 ]');
       put(q'[       SUM(output_rows) a_rows,                                                      ]');
       put(q'[       MAX(plan_cost) cost,                                                          ]');
       put(q'[       MAX(plan_bytes) e_bytes,                                                      ]');
       put(q'[       MAX(plan_time) e_time,                                                        ]');
       put(q'[       MAX(plan_partition_start) pstart,                                             ]');
       put(q'[       MAX(plan_partition_stop) pstop,                                               ]');
       put(q'[       SUM(physical_read_requests) io_read_req,                                      ]');
       put(q'[       SUM(physical_read_bytes) io_read_bytes,                                       ]');
       put(q'[       SUM(physical_write_requests) io_write_req,                                    ]');
       put(q'[       SUM(physical_write_bytes) io_write_bytes,                                     ]');
       put(q'[       SUM(workarea_mem) workarea_mem,                                               ]');
       put(q'[       SUM(workarea_max_mem) workarea_max_mem,                                       ]');
       put(q'[       SUM(workarea_tempseg) workarea_tempseg,                                       ]');
       put(q'[       SUM(workarea_max_tempseg) workarea_max_tempseg                                ]');
       put(q'[  FROM gv$sql_plan_monitor                                                           ]');
       put(q'[ WHERE sql_id = ''&&sqld360_sqlid.''                                                 ]');
       -- Taking out the filter on PHV since ASH might not have evidence of the final plan resolved while SQL Mon does
       --put(q'[   AND sql_plan_hash_value = ]'|| i.plan_hash_value                                    );
       -- Cannot use INST and SID because of PX execution
       --put(q'[   AND inst_id = ]'||j.inst_id                                                         );
       --put(q'[   AND sid = ]'||j.session_id                                                          );
       put(q'[   AND sql_exec_id = ]'||j.sql_exec_id                                                 );
       put(q'[   AND sql_exec_start = TO_DATE('']'||j.sql_exec_start||q'['', ''YYYYMMDDHH24MISS'') ]');
       put(q'[ GROUP BY plan_line_id, plan_operation, plan_options                                 ]');
       put(q'[ ORDER BY plan_line_id                                                               ]');
       put(''';');
       put('END;');
       put('/ ');
       put('@sql/sqld360_9a_pre_one.sql');       

       put('----------------------------');

       put(q'[DEF title='Plan Step IDs timeline for SQL_EXEC_ID ]'||j.sql_exec_id||q'[ of PHV ]'||i.plan_hash_value||q'[']');
       put(q'[DEF main_table = 'GV$ACTIVE_SESSION_HISTORY'                                                               ]');
       put(q'[DEF skip_uch=''                                                                                            ]');
       put(q'[DEF abstract = 'Top SQL Plan Steps'                                                                        ]');
       put(q'[DEF vaxis = 'SQL Plan Step ID'                                                                             ]');
       put(q'[DEF foot = 'Data is not aggregated, extracted directly from V$ASH, Y-axis report plan steps, size of the bubble is number of samples, color is major contributor (>50%) for bubble' ]');

       put(q'[COL bubblesDetails NEW_V bubblesDetails                                                                                                         ]');
       put(q'[SELECT '<br>Step Details<br>'||LISTAGG(step_details,'<br>') WITHIN GROUP (ORDER BY id) bubblesDetails                                           ]');
       put(q'[          FROM (SELECT DISTINCT NVL(id,0) id, NVL(id,0)||' - '||operation||' '||options||' (obj#:'||object_instance||')' step_details           ]');
       put(q'[                  FROM plan_table a                                                                                                             ]');
       put(q'[                 WHERE statement_id = 'SQLD360_ASH_DATA_MEM'                                                                                    ]');
       -- skipping the filter on PHV to include also rows with SQL_PLAN_HASH_VALUE = 0 
       put(q'[                   AND /*cost*/ bytes = ]'||i.plan_hash_value                                                                                               );
       put(q'[                   AND NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,',',1,3)+1,INSTR(partition_stop,',',1,4)-INSTR(partition_stop,',',1,3)-1)),position) = ]'||j.inst_id);
       put(q'[                   AND NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,',',1,4)+1,INSTR(partition_stop,',',1,5)-INSTR(partition_stop,',',1,4)-1)),cpu_cost) = ]'||j.session_id);
       put(q'[                   AND NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,',',1,5)+1,INSTR(partition_stop,',',1,6)-INSTR(partition_stop,',',1,5)-1)),io_cost) =  ]'||j.session_serial#);
       put(q'[                   AND a.timestamp BETWEEN TO_DATE(']'||j.min_sample_time||q'[', 'YYYYMMDDHH24MISS') AND TO_DATE(']'||j.max_sample_time||q'[', 'YYYYMMDDHH24MISS')     ]');
       put(q'[                   AND remarks = '&&sqld360_sqlid.'                                                                                                             ]');
       -- this is to differentiate data from partial exec of overlapping executions (case from my German friend)
       put(q'[                   AND NVL(partition_id, ]'||j.sql_exec_id||q'[) = ]'||j.sql_exec_id                                                                              ); 
       put(q'[                   AND NVL(distribution, TO_DATE(']'||j.sql_exec_start||q'[', 'YYYYMMDDHH24MISS')) = TO_DATE(']'||j.sql_exec_start||q'[', 'YYYYMMDDHH24MISS')   ]');
       --
       put(q'[               );                                                                                                                                               ]');

       put(q'[BEGIN                                                                                                                                                                                                                  ]');
       put(q'[ :sql_text := '                                                                                                                                                                                                        ]');
       put(q'[SELECT TO_CHAR(end_time, ''YYYY-MM-DD HH24:MI:SS'') end_time,                                                                                                                                                          ]');
       put(q'[       null,                                                                                                                                                                                                           ]');
       put(q'[       plan_line_id,                                                                                                                                                                                                   ]');
       put(q'[       CASE WHEN rtr_category > .5 THEN category ELSE ''Multiple'' END,                                                                                                                                                ]');
       put(q'[       num_samples                                                                                                                                                                                                     ]');
       put(q'[  FROM (SELECT end_time, plan_line_id, category, num_samples, rtr_category, ROW_NUMBER() OVER (PARTITION BY end_time, plan_line_id ORDER BY rtr_category DESC) rn_category                                             ]');
       put(q'[          FROM (SELECT end_time, plan_line_id, category, SUM(num_samples) OVER (PARTITION BY end_time, plan_line_id) num_samples, RATIO_TO_REPORT(num_samples) OVER (PARTITION BY end_time, plan_line_id) rtr_category ]');
       put(q'[                  FROM (SELECT timestamp end_time, NVL(id,0) plan_line_id,                                                                                                                                             ]');
       put(q'[                               CASE WHEN other_tag = ''CPU'' THEN ''CPU'' WHEN other_tag LIKE ''%I/O'' THEN ''I/O'' WHEN other_tag = ''Concurrency'' THEN ''Concurrency'' WHEN other_tag = ''Cluster'' THEN ''Cluster'' ELSE ''Other'' END category, ]'); 
       put(q'[                               COUNT(*) num_samples                                                                                                                                                                    ]'); 
       put(q'[                          FROM plan_table                                                                                                                                                                              ]');
       put(q'[                         WHERE statement_id = ''SQLD360_ASH_DATA_MEM''                                                                                                                                                 ]');
       -- skipping the filter on PHV to include also rows with SQL_PLAN_HASH_VALUE = 0        
       put(q'[                           AND /*cost*/ bytes =  ]'||i.plan_hash_value                                                                                                                                                   );
       put(q'[                           AND NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'','',1,3)+1,INSTR(partition_stop,'','',1,4)-INSTR(partition_stop,'','',1,3)-1)),position) =                        ]'||j.inst_id);
       put(q'[                           AND NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'','',1,4)+1,INSTR(partition_stop,'','',1,5)-INSTR(partition_stop,'','',1,4)-1)),cpu_cost) =                     ]'||j.session_id);
       put(q'[                           AND NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'','',1,5)+1,INSTR(partition_stop,'','',1,6)-INSTR(partition_stop,'','',1,5)-1)),io_cost) =                 ]'||j.session_serial#);
       put(q'[                           AND timestamp BETWEEN TO_DATE('']'||j.min_sample_time||q'['', ''YYYYMMDDHH24MISS'') AND TO_DATE('']'||j.max_sample_time||q'['', ''YYYYMMDDHH24MISS'')                                       ]');
       put(q'[                           AND remarks = ''&&sqld360_sqlid.''                                                                                                                                                          ]'); 
       --put(q'[                           AND partition_id IS NOT NULL                                                                                                                                                                ]');
       -- this is to differentiate data from partial exec of overlapping executions (case from my German friend)
       put(q'[                           AND NVL(partition_id, ]'||j.sql_exec_id||q'[) = ]'||j.sql_exec_id                                                                                                                             ); 
       put(q'[                           AND NVL(distribution, TO_DATE('']'||j.sql_exec_start||q'['', ''YYYYMMDDHH24MISS'')) = TO_DATE('']'||j.sql_exec_start||q'['', ''YYYYMMDDHH24MISS'')                                          ]');
       --
       put(q'[                           AND ''&&diagnostics_pack.'' = ''Y''                                                                                                                                                         ]');
       put(q'[                         GROUP BY timestamp, NVL(id,0), CASE WHEN other_tag = ''CPU'' THEN ''CPU'' WHEN other_tag LIKE ''%I/O'' THEN ''I/O'' WHEN other_tag = ''Concurrency'' THEN ''Concurrency'' WHEN other_tag = ''Cluster'' THEN ''Cluster'' ELSE ''Other'' END ]');
       put(q'[                       )   ]');
       put(q'[               )           ]');
       put(q'[         )                 ]');
       put(q'[ WHERE rn_category = 1     ]');
       put(q'[ ORDER BY end_time         ]'); 
       put(''';');
       put('END;');
       put('/ ');
       put('@sql/sqld360_9a_pre_one.sql');

       put('----------------------------');

       put(q'[DEF title='Top Step/Event/Obj for SQL_EXEC_ID ]'||j.sql_exec_id||q'[ of PHV ]'||i.plan_hash_value||q'[' ]');
       put(q'[DEF main_table = 'GV$ACTIVE_SESSION_HISTORY'                                                            ]');
       put(q'[DEF skip_bch=''                                                                                         ]');
       put(q'[BEGIN                                                                                                   ]');
       put(q'[ :sql_text := '                                                                                         ]');
       put(q'[SELECT step_event,                                                                                                                               ]');
       put(q'[       num_samples,                                                                                                                              ]');
       put(q'[       &&wait_class_colors.&&wait_class_colors2.&&wait_class_colors3.&&wait_class_colors4. style,                                                ]');
       put(q'[       step_event||'' - Number of samples: ''||num_samples||'' (''||TRUNC(100*RATIO_TO_REPORT(num_samples) OVER (),2)||''% of DB Time)'' tooltip ]');
       put(q'[  FROM (SELECT data.step||'' ''||CASE WHEN data.obj# = 0 THEN ''UNDO''                                                                           ]');
       put(q'[                    ELSE (SELECT TRIM(''.'' FROM '' ''||o.owner||''.''||o.object_name||''.''||o.subobject_name) FROM dba_objects o WHERE o.object_id = data.obj# AND ROWNUM = 1) ]'); 
       put(q'[               END||'' / ''||data.event  step_event,                                                                                             ]');
       put(q'[               data.num_samples, data.wait_class                                                                                                 ]');
       put(q'[          FROM (SELECT id||'' - ''||operation||'' ''||options step, object_instance obj#, object_node event, other_tag wait_class,               ]'); 
       put(q'[                       count(*) num_samples                                                                                                      ]');
       put(q'[                  FROM plan_table                                                                                                                ]');
       put(q'[                 WHERE statement_id = ''SQLD360_ASH_DATA_MEM''                                                                                   ]');
       -- skipping the filter on PHV to include also rows with SQL_PLAN_HASH_VALUE = 0 
       put(q'[                   AND /*cost*/ bytes =  ]'||i.plan_hash_value                                                                                     );
       put(q'[                   AND NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'','',1,3)+1,INSTR(partition_stop,'','',1,4)-INSTR(partition_stop,'','',1,3)-1)),position) = ]'||j.inst_id        );
       put(q'[                   AND NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'','',1,4)+1,INSTR(partition_stop,'','',1,5)-INSTR(partition_stop,'','',1,4)-1)),cpu_cost) = ]'||j.session_id     );
       put(q'[                   AND NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'','',1,5)+1,INSTR(partition_stop,'','',1,6)-INSTR(partition_stop,'','',1,5)-1)),io_cost) =  ]'||j.session_serial#);
       put(q'[                   AND timestamp BETWEEN TO_DATE('']'||j.min_sample_time||q'['', ''YYYYMMDDHH24MISS'') AND TO_DATE('']'||j.max_sample_time||q'['', ''YYYYMMDDHH24MISS'')                        ]');
       put(q'[                   AND remarks = ''&&sqld360_sqlid.''                                                                                             ]'); 
       -- this is to differentiate data from partial exec of overlapping executions (case from my German friend)
       put(q'[                 AND NVL(partition_id, ]'||j.sql_exec_id||q'[) = ]'||j.sql_exec_id                                                                                                                 ); 
       put(q'[                 AND NVL(distribution, TO_DATE('']'||j.sql_exec_start||q'['', ''YYYYMMDDHH24MISS'')) = TO_DATE('']'||j.sql_exec_start||q'['', ''YYYYMMDDHH24MISS'')                              ]');
       --
       put(q'[                   AND ''&&diagnostics_pack.'' = ''Y''                                                                                            ]');
       put(q'[                 GROUP BY id||'' - ''||operation||'' ''||options, object_instance, object_node, other_tag                                         ]');  
       put(q'[                 ORDER BY 5 DESC) data)                                                                                                           ]');
       put(q'[ ORDER BY 2 DESC                                                                                                                                  ]');
       put(''';');
       put('END;');
       put('/ ');
       put('@sql/sqld360_9a_pre_one.sql');    
    
       put('----------------------------');   

       put('DEF title=''Top 15 Wait events timeline for SQL_EXEC_ID '||j.sql_exec_id||' of PHV '||i.plan_hash_value||'''');
       put('DEF main_table = ''GV$ACTIVE_SESSION_HISTORY''');
       put('DEF skip_lch=''''');
       put('DEF chartype = ''AreaChart''');
       put('DEF stacked = ''isStacked: true,''');
       put('DEF abstract = ''AS (stacked) per top 15 wait events''');
       put('DEF vaxis = ''Active Sessions - AS (stacked)''');
       put('DEF foot = ''Data is not aggregated, extracted directly from V$ASH, Y-axis report Active Sessions at any time, not Average Active Sessions''');

       put('COL evt_01 NEW_V evt_01'); 
       put('COL evt_02 NEW_V evt_02'); 
       put('COL evt_03 NEW_V evt_03'); 
       put('COL evt_04 NEW_V evt_04'); 
       put('COL evt_05 NEW_V evt_05'); 
       put('COL evt_06 NEW_V evt_06'); 
       put('COL evt_07 NEW_V evt_07'); 
       put('COL evt_08 NEW_V evt_08'); 
       put('COL evt_09 NEW_V evt_09'); 
       put('COL evt_10 NEW_V evt_10'); 
       put('COL evt_11 NEW_V evt_11'); 
       put('COL evt_12 NEW_V evt_12'); 
       put('COL evt_13 NEW_V evt_13'); 
       put('COL evt_14 NEW_V evt_14'); 
       put('COL evt_15 NEW_V evt_15');
       put('COL tit_01 NEW_V tit_01'); 
       put('COL tit_02 NEW_V tit_02'); 
       put('COL tit_03 NEW_V tit_03'); 
       put('COL tit_04 NEW_V tit_04'); 
       put('COL tit_05 NEW_V tit_05'); 
       put('COL tit_06 NEW_V tit_06'); 
       put('COL tit_07 NEW_V tit_07'); 
       put('COL tit_08 NEW_V tit_08'); 
       put('COL tit_09 NEW_V tit_09'); 
       put('COL tit_10 NEW_V tit_10'); 
       put('COL tit_11 NEW_V tit_11'); 
       put('COL tit_12 NEW_V tit_12'); 
       put('COL tit_13 NEW_V tit_13'); 
       put('COL tit_14 NEW_V tit_14'); 
       put('COL tit_15 NEW_V tit_15'); 

       -- this is to determine series color
       put('COL series_01 NEW_V series_01'); 
       put('COL series_02 NEW_V series_02'); 
       put('COL series_03 NEW_V series_03'); 
       put('COL series_04 NEW_V series_04'); 
       put('COL series_05 NEW_V series_05'); 
       put('COL series_06 NEW_V series_06'); 
       put('COL series_07 NEW_V series_07'); 
       put('COL series_08 NEW_V series_08'); 
       put('COL series_09 NEW_V series_09'); 
       put('COL series_10 NEW_V series_10'); 
       put('COL series_11 NEW_V series_11'); 
       put('COL series_12 NEW_V series_12'); 
       put('COL series_13 NEW_V series_13'); 
       put('COL series_14 NEW_V series_14'); 
       put('COL series_15 NEW_V series_15');

       put('SELECT MAX(CASE WHEN ranking = 1  THEN cpu_or_event ELSE '''' END) evt_01,');
       put('       MAX(CASE WHEN ranking = 2  THEN cpu_or_event ELSE '''' END) evt_02,');              
       put('       MAX(CASE WHEN ranking = 3  THEN cpu_or_event ELSE '''' END) evt_03,'); 
       put('       MAX(CASE WHEN ranking = 4  THEN cpu_or_event ELSE '''' END) evt_04,'); 
       put('       MAX(CASE WHEN ranking = 5  THEN cpu_or_event ELSE '''' END) evt_05,'); 
       put('       MAX(CASE WHEN ranking = 6  THEN cpu_or_event ELSE '''' END) evt_06,'); 
       put('       MAX(CASE WHEN ranking = 7  THEN cpu_or_event ELSE '''' END) evt_07,'); 
       put('       MAX(CASE WHEN ranking = 8  THEN cpu_or_event ELSE '''' END) evt_08,'); 
       put('       MAX(CASE WHEN ranking = 9  THEN cpu_or_event ELSE '''' END) evt_09,'); 
       put('       MAX(CASE WHEN ranking = 10 THEN cpu_or_event ELSE '''' END) evt_10,');
       put('       MAX(CASE WHEN ranking = 11 THEN cpu_or_event ELSE '''' END) evt_11,');
       put('       MAX(CASE WHEN ranking = 12 THEN cpu_or_event ELSE '''' END) evt_12,');
       put('       MAX(CASE WHEN ranking = 13 THEN cpu_or_event ELSE '''' END) evt_13,');
       put('       MAX(CASE WHEN ranking = 14 THEN cpu_or_event ELSE '''' END) evt_14,');
       put('       MAX(CASE WHEN ranking = 15 THEN cpu_or_event ELSE '''' END) evt_15,');
       -- this is to determine series color
       put('       MAX(CASE WHEN ranking = 1  THEN &&wait_class_colors_s.&&wait_class_colors2_s.&&wait_class_colors3_s.&&wait_class_colors4_s. END) series_01,');
       put('       MAX(CASE WHEN ranking = 2  THEN &&wait_class_colors_s.&&wait_class_colors2_s.&&wait_class_colors3_s.&&wait_class_colors4_s. END) series_02,');              
       put('       MAX(CASE WHEN ranking = 3  THEN &&wait_class_colors_s.&&wait_class_colors2_s.&&wait_class_colors3_s.&&wait_class_colors4_s. END) series_03,'); 
       put('       MAX(CASE WHEN ranking = 4  THEN &&wait_class_colors_s.&&wait_class_colors2_s.&&wait_class_colors3_s.&&wait_class_colors4_s. END) series_04,'); 
       put('       MAX(CASE WHEN ranking = 5  THEN &&wait_class_colors_s.&&wait_class_colors2_s.&&wait_class_colors3_s.&&wait_class_colors4_s. END) series_05,'); 
       put('       MAX(CASE WHEN ranking = 6  THEN &&wait_class_colors_s.&&wait_class_colors2_s.&&wait_class_colors3_s.&&wait_class_colors4_s. END) series_06,'); 
       put('       MAX(CASE WHEN ranking = 7  THEN &&wait_class_colors_s.&&wait_class_colors2_s.&&wait_class_colors3_s.&&wait_class_colors4_s. END) series_07,'); 
       put('       MAX(CASE WHEN ranking = 8  THEN &&wait_class_colors_s.&&wait_class_colors2_s.&&wait_class_colors3_s.&&wait_class_colors4_s. END) series_08,'); 
       put('       MAX(CASE WHEN ranking = 9  THEN &&wait_class_colors_s.&&wait_class_colors2_s.&&wait_class_colors3_s.&&wait_class_colors4_s. END) series_09,'); 
       put('       MAX(CASE WHEN ranking = 10 THEN &&wait_class_colors_s.&&wait_class_colors2_s.&&wait_class_colors3_s.&&wait_class_colors4_s. END) series_10,');
       put('       MAX(CASE WHEN ranking = 11 THEN &&wait_class_colors_s.&&wait_class_colors2_s.&&wait_class_colors3_s.&&wait_class_colors4_s. END) series_11,');
       put('       MAX(CASE WHEN ranking = 12 THEN &&wait_class_colors_s.&&wait_class_colors2_s.&&wait_class_colors3_s.&&wait_class_colors4_s. END) series_12,');
       put('       MAX(CASE WHEN ranking = 13 THEN &&wait_class_colors_s.&&wait_class_colors2_s.&&wait_class_colors3_s.&&wait_class_colors4_s. END) series_13,');
       put('       MAX(CASE WHEN ranking = 14 THEN &&wait_class_colors_s.&&wait_class_colors2_s.&&wait_class_colors3_s.&&wait_class_colors4_s. END) series_14,');
       put('       MAX(CASE WHEN ranking = 15 THEN &&wait_class_colors_s.&&wait_class_colors2_s.&&wait_class_colors3_s.&&wait_class_colors4_s. END) series_15 ');
       --
       put('  FROM (SELECT 1 fake, object_node cpu_or_event, other_tag wait_class,');
       put('               ROW_NUMBER() OVER (ORDER BY COUNT(*) DESC) ranking');
       put('          FROM plan_table'); 
       put('         WHERE statement_id = ''SQLD360_ASH_DATA_MEM''');
       -- skipping the filter on PHV to include also rows with SQL_PLAN_HASH_VALUE = 0        
       put('           AND /*cost*/ bytes = '||i.plan_hash_value);
       put('           AND NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'','',1,3)+1,INSTR(partition_stop,'','',1,4)-INSTR(partition_stop,'','',1,3)-1)),position) = '||j.inst_id||'');
       put('           AND NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'','',1,4)+1,INSTR(partition_stop,'','',1,5)-INSTR(partition_stop,'','',1,4)-1)),cpu_cost) = '||j.session_id||'');
       put('           AND NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'','',1,5)+1,INSTR(partition_stop,'','',1,6)-INSTR(partition_stop,'','',1,5)-1)),io_cost) = '||j.session_serial#||'');
       put('           AND timestamp BETWEEN TO_DATE('''||j.min_sample_time||''', ''YYYYMMDDHH24MISS'') AND TO_DATE('''||j.max_sample_time||''', ''YYYYMMDDHH24MISS'') ');
       put('           AND remarks = ''&&sqld360_sqlid.''');
       -- this is to differentiate data from partial exec of overlapping executions (case from my German friend)
       put(q'[         AND NVL(partition_id, ]'||j.sql_exec_id||q'[) = ]'||j.sql_exec_id                                                                                                                       ); 
       put(q'[         AND NVL(distribution, TO_DATE(']'||j.sql_exec_start||q'[', 'YYYYMMDDHH24MISS')) = TO_DATE(']'||j.sql_exec_start||q'[', 'YYYYMMDDHH24MISS')                                            ]');
       --
       put('         GROUP BY object_node, other_tag) ash,');
       put('       (SELECT 1 fake FROM dual) b'); -- this is in case there is no row in ASH
       put(' WHERE ash.fake(+) = b.fake');
       put('   AND ranking <= 15');
       put('/');    

       put('SET DEF @');

       put('SELECT SUBSTR(''@evt_01.'',1,27) tit_01,'); 
       put('       SUBSTR(''@evt_02.'',1,27) tit_02,');
       put('       SUBSTR(''@evt_03.'',1,27) tit_03,');
       put('       SUBSTR(''@evt_04.'',1,27) tit_04,');
       put('       SUBSTR(''@evt_05.'',1,27) tit_05,');
       put('       SUBSTR(''@evt_06.'',1,27) tit_06,');
       put('       SUBSTR(''@evt_07.'',1,27) tit_07,');
       put('       SUBSTR(''@evt_08.'',1,27) tit_08,');
       put('       SUBSTR(''@evt_09.'',1,27) tit_09,');
       put('       SUBSTR(''@evt_10.'',1,27) tit_10,'); 
       put('       SUBSTR(''@evt_11.'',1,27) tit_11,');
       put('       SUBSTR(''@evt_12.'',1,27) tit_12,');
       put('       SUBSTR(''@evt_13.'',1,27) tit_13,');
       put('       SUBSTR(''@evt_14.'',1,27) tit_14,');
       put('       SUBSTR(''@evt_15.'',1,27) tit_15');
       put('  FROM DUAL');
       put('/');

       put('COL e01 NOPRI');
       put('COL e02 NOPRI');
       put('COL e03 NOPRI');
       put('COL e04 NOPRI');
       put('COL e05 NOPRI');
       put('COL e06 NOPRI');
       put('COL e07 NOPRI');
       put('COL e08 NOPRI');
       put('COL e09 NOPRI');
       put('COL e10 NOPRI');
       put('COL e11 NOPRI');
       put('COL e12 NOPRI');
       put('COL e13 NOPRI');
       put('COL e14 NOPRI');
       put('COL e15 NOPRI');

       put('BEGIN');
       put(' :sql_text := ''');
       put('SELECT 0 snap_id,');
       put('       TO_CHAR(sample_time, ''''YYYY-MM-DD HH24:MI:SS'''') begin_time,'); 
       put('       TO_CHAR(sample_time, ''''YYYY-MM-DD HH24:MI:SS'''') end_time,');
       put('       NVL(num_sess_01,0) "e01@tit_01." ,');
       put('       NVL(num_sess_02,0) "e02@tit_02." ,');
       put('       NVL(num_sess_03,0) "e03@tit_03." ,');
       put('       NVL(num_sess_04,0) "e04@tit_04." ,');
       put('       NVL(num_sess_05,0) "e05@tit_05." ,');
       put('       NVL(num_sess_06,0) "e06@tit_06." ,');
       put('       NVL(num_sess_07,0) "e07@tit_07." ,');
       put('       NVL(num_sess_08,0) "e08@tit_08." ,');
       put('       NVL(num_sess_09,0) "e09@tit_09." ,');
       put('       NVL(num_sess_10,0) "e10@tit_10." ,');
       put('       NVL(num_sess_11,0) "e11@tit_11." ,');
       put('       NVL(num_sess_12,0) "e12@tit_12." ,');
       put('       NVL(num_sess_13,0) "e13@tit_13." ,');
       put('       NVL(num_sess_14,0) "e14@tit_14." ,');
       put('       NVL(num_sess_15,0) "e15@tit_15." ');
       put('  FROM (SELECT sample_time,');
       put('               MAX(CASE WHEN cpu_or_event  = ''''@evt_01.'''' THEN num_sess ELSE NULL END) num_sess_01,'); 
       put('               MAX(CASE WHEN cpu_or_event  = ''''@evt_02.'''' THEN num_sess ELSE NULL END) num_sess_02,'); 
       put('               MAX(CASE WHEN cpu_or_event  = ''''@evt_03.'''' THEN num_sess ELSE NULL END) num_sess_03,'); 
       put('               MAX(CASE WHEN cpu_or_event  = ''''@evt_04.'''' THEN num_sess ELSE NULL END) num_sess_04,'); 
       put('               MAX(CASE WHEN cpu_or_event  = ''''@evt_05.'''' THEN num_sess ELSE NULL END) num_sess_05,'); 
       put('               MAX(CASE WHEN cpu_or_event  = ''''@evt_06.'''' THEN num_sess ELSE NULL END) num_sess_06,'); 
       put('               MAX(CASE WHEN cpu_or_event  = ''''@evt_07.'''' THEN num_sess ELSE NULL END) num_sess_07,'); 
       put('               MAX(CASE WHEN cpu_or_event  = ''''@evt_08.'''' THEN num_sess ELSE NULL END) num_sess_08,'); 
       put('               MAX(CASE WHEN cpu_or_event  = ''''@evt_09.'''' THEN num_sess ELSE NULL END) num_sess_09,'); 
       put('               MAX(CASE WHEN cpu_or_event  = ''''@evt_10.'''' THEN num_sess ELSE NULL END) num_sess_10,'); 
       put('               MAX(CASE WHEN cpu_or_event  = ''''@evt_11.'''' THEN num_sess ELSE NULL END) num_sess_11,');  
       put('               MAX(CASE WHEN cpu_or_event  = ''''@evt_12.'''' THEN num_sess ELSE NULL END) num_sess_12,');  
       put('               MAX(CASE WHEN cpu_or_event  = ''''@evt_13.'''' THEN num_sess ELSE NULL END) num_sess_13,');  
       put('               MAX(CASE WHEN cpu_or_event  = ''''@evt_14.'''' THEN num_sess ELSE NULL END) num_sess_14,');  
       put('               MAX(CASE WHEN cpu_or_event  = ''''@evt_15.'''' THEN num_sess ELSE NULL END) num_sess_15'); 
       put('          FROM (SELECT timestamp sample_time,');
       put('                       object_node cpu_or_event,'); 
       put('                       count(*) num_sess');
       put('                  FROM plan_table');
       put('                 WHERE statement_id = ''''SQLD360_ASH_DATA_MEM''''');
       put('                   AND remarks = ''''&&sqld360_sqlid.''''');
       put('                   AND ''''&&diagnostics_pack.'''' = ''''Y''''');
       -- skipping the filter on PHV to include also rows with SQL_PLAN_HASH_VALUE = 0        
       put('                   AND /*cost*/ bytes = '||i.plan_hash_value);
       put('                   AND NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'''','''',1,3)+1,INSTR(partition_stop,'''','''',1,4)-INSTR(partition_stop,'''','''',1,3)-1)),position) = '||j.inst_id||'');
       put('                   AND NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'''','''',1,4)+1,INSTR(partition_stop,'''','''',1,5)-INSTR(partition_stop,'''','''',1,4)-1)),cpu_cost) = '||j.session_id||'');
       put('                   AND NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'''','''',1,5)+1,INSTR(partition_stop,'''','''',1,6)-INSTR(partition_stop,'''','''',1,5)-1)),io_cost) = '||j.session_serial#||'');
       put('                   AND timestamp BETWEEN TO_DATE('''''||j.min_sample_time||''''', ''''YYYYMMDDHH24MISS'''') AND TO_DATE('''''||j.max_sample_time||''''', ''''YYYYMMDDHH24MISS'''') ');
       -- this is to differentiate data from partial exec of overlapping executions (case from my German friend)
       put(q'[                 AND NVL(partition_id, ]'||j.sql_exec_id||q'[) = ]'||j.sql_exec_id                                                                                                                             ); 
       put(q'[                 AND NVL(distribution, TO_DATE('']'||j.sql_exec_start||q'['', ''YYYYMMDDHH24MISS'')) = TO_DATE('']'||j.sql_exec_start||q'['', ''YYYYMMDDHH24MISS'')                                          ]');
       --
       put('                   AND object_node IN (''''@evt_01.'''',''''@evt_02.'''',''''@evt_03.'''',''''@evt_04.'''',''''@evt_05.'''',''''@evt_06.'''',');
       put('                                       ''''@evt_07.'''',''''@evt_08.'''',''''@evt_09.'''',''''@evt_10.'''',''''@evt_11.'''',''''@evt_12.'''',');
       put('                                       ''''@evt_13.'''',''''@evt_14.'''',''''@evt_15.'''')');
       put('                 GROUP BY timestamp, object_node)');
       put('         GROUP BY sample_time)');
       put(' ORDER BY 3 ');
       put(''';');
       put('END;');
       put('/ ');

       put('SET DEF &');
       put('@sql/sqld360_9a_pre_one.sql');

       put('COL evt01_ PRI');
       put('COL evt02_ PRI');
       put('COL evt03_ PRI');
       put('COL evt04_ PRI');
       put('COL evt05_ PRI');
       put('COL evt06_ PRI');
       put('COL evt07_ PRI');
       put('COL evt08_ PRI');
       put('COL evt09_ PRI');
       put('COL evt10_ PRI');
       put('COL evt11_ PRI');
       put('COL evt12_ PRI');
       put('COL evt13_ PRI');
       put('COL evt14_ PRI');
       put('COL evt15_ PRI');     

       put('UNDEF evt_01'); 
       put('UNDEF evt_02'); 
       put('UNDEF evt_03'); 
       put('UNDEF evt_04'); 
       put('UNDEF evt_05'); 
       put('UNDEF evt_06'); 
       put('UNDEF evt_07'); 
       put('UNDEF evt_08'); 
       put('UNDEF evt_09'); 
       put('UNDEF evt_10'); 
       put('UNDEF evt_11'); 
       put('UNDEF evt_12'); 
       put('UNDEF evt_13'); 
       put('UNDEF evt_14'); 
       put('UNDEF evt_15'); 

       -- to play with colors
       put('DEF series_01 = '''' '); 
       put('DEF series_02 = '''' '); 
       put('DEF series_03 = '''' '); 
       put('DEF series_04 = '''' '); 
       put('DEF series_05 = '''' '); 
       put('DEF series_06 = '''' '); 
       put('DEF series_07 = '''' '); 
       put('DEF series_08 = '''' '); 
       put('DEF series_09 = '''' '); 
       put('DEF series_10 = '''' '); 
       put('DEF series_11 = '''' '); 
       put('DEF series_12 = '''' '); 
       put('DEF series_13 = '''' '); 
       put('DEF series_14 = '''' '); 
       put('DEF series_15 = '''' ');

       put('----------------------------');

       put('DEF title=''DB Time by PX process for SQL_EXEC_ID '||j.sql_exec_id||' of PHV '||i.plan_hash_value||'''');
       put('DEF main_table = ''GV$ACTIVE_SESSION_HISTORY''');
       put('DEF skip_bch=''''');
       --put('DEF slices = ''64''');
       put('BEGIN');
       put(' :sql_text := ''');
       put('SELECT data.qcpx_process,');
       put('       data.num_samples,');
       put('       NULL style,');
       put('       data.qcpx_process||'''' - Number of samples: ''''||data.num_samples||'''' (''''||TRUNC(100*RATIO_TO_REPORT(data.num_samples) OVER (),2)||''''%)'''' tooltip ');
       put('  FROM (SELECT NVL2(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'''','''',1,3)+1,INSTR(partition_stop,'''','''',1,4)-INSTR(partition_stop,'''','''',1,3)-1)), ''''PX Proc - '''', ''''QC - '''')||position||''''.''''||cpu_cost||''''.''''||io_cost  qcpx_process, ');   
       put('               count(*) num_samples');
       put('          FROM plan_table');
       put('         WHERE statement_id = ''''SQLD360_ASH_DATA_MEM''''');
       -- skipping the filter on PHV to include also rows with SQL_PLAN_HASH_VALUE = 0        
       put('           AND /*cost*/ bytes =  '||i.plan_hash_value||'');
       put('           AND NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'''','''',1,3)+1,INSTR(partition_stop,'''','''',1,4)-INSTR(partition_stop,'''','''',1,3)-1)),position) = '||j.inst_id||'');
       put('           AND NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'''','''',1,4)+1,INSTR(partition_stop,'''','''',1,5)-INSTR(partition_stop,'''','''',1,4)-1)),cpu_cost) = '||j.session_id||'');
       put('           AND NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'''','''',1,5)+1,INSTR(partition_stop,'''','''',1,6)-INSTR(partition_stop,'''','''',1,5)-1)),io_cost) = '||j.session_serial#||'');
       put('           AND timestamp BETWEEN TO_DATE('''''||j.min_sample_time||''''', ''''YYYYMMDDHH24MISS'''') AND TO_DATE('''''||j.max_sample_time||''''', ''''YYYYMMDDHH24MISS'''') ');
       put('           AND remarks = ''''&&sqld360_sqlid.'''''); 
       put('           AND ''''&&diagnostics_pack.'''' = ''''Y''''');
       -- this is to differentiate data from partial exec of overlapping executions (case from my German friend)
       put(q'[         AND NVL(partition_id, ]'||j.sql_exec_id||q'[) = ]'||j.sql_exec_id                                                                                                                             ); 
       put(q'[         AND NVL(distribution, TO_DATE('']'||j.sql_exec_start||q'['', ''YYYYMMDDHH24MISS'')) = TO_DATE('']'||j.sql_exec_start||q'['', ''YYYYMMDDHH24MISS'')                                          ]');
       --
       put('         GROUP BY NVL2(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'''','''',1,3)+1,INSTR(partition_stop,'''','''',1,4)-INSTR(partition_stop,'''','''',1,3)-1)), ''''PX Proc - '''', ''''QC - '''')||position||''''.''''||cpu_cost||''''.''''||io_cost   ');  
       put('         ORDER BY 2 DESC) data');
       --put(' WHERE rownum <= 64');
       put(' ORDER BY 2 DESC');
       put(''';');
       put('END;');
       put('/ ');
       put('@sql/sqld360_9a_pre_one.sql');          

       put('----------------------------');

       put('DEF title=''PGA and TEMP usage for SQL_EXEC_ID '||j.sql_exec_id||' of PHV '||i.plan_hash_value||'''');
       put('DEF main_table = ''V$ACTIVE_SESSION_HISTORY''');
       put('DEF skip_lch=''''');
       put('DEF chartype = ''LineChart''');
       put('DEF stacked = ''''');
       put('DEF vaxis = ''Bytes''');
       put('DEF tit_01 = ''PGA Usage''');
       put('DEF tit_02 = ''TEMP Usage''');
       put('DEF tit_03 = ''''');
       put('DEF tit_04 = ''''');
       put('DEF tit_05 = ''''');
       put('DEF tit_06 = ''''');
       put('DEF tit_07 = ''''');
       put('DEF tit_08 = ''''');
       put('DEF tit_09 = ''''');
       put('DEF tit_10 = ''''');
       put('DEF tit_11 = ''''');
       put('DEF tit_12 = ''''');
       put('DEF tit_13 = ''''');
       put('DEF tit_14 = ''''');
       put('DEF tit_15 = ''''');
       put('DEF foot = ''Data is not aggregated, extracted directly from V$ASH''');
       put('BEGIN');
       put(' :sql_text := ''');
       put('SELECT 0 snap_id,');
       put('       TO_CHAR(end_time, ''''YYYY-MM-DD HH24:MI:SS'''') begin_time,'); 
       put('       TO_CHAR(end_time, ''''YYYY-MM-DD HH24:MI:SS'''') end_time,');
       put('       pga_allocated,');
       put('       temp_space_allocated,');
       put('       0 dummy_03,');
       put('       0 dummy_04,');
       put('       0 dummy_05,');
       put('       0 dummy_06,');
       put('       0 dummy_07,');
       put('       0 dummy_08,');
       put('       0 dummy_09,');
       put('       0 dummy_10,');
       put('       0 dummy_11,');
       put('       0 dummy_12,');
       put('       0 dummy_13,');
       put('       0 dummy_14,');
       put('       0 dummy_15');
       put('  FROM (SELECT timestamp end_time,');
       put('               SUM(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'''','''',1,11)+1,INSTR(partition_stop,'''','''',1,12)-INSTR(partition_stop,'''','''',1,11)-1))) pga_allocated,'); 
       put('               SUM(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'''','''',1,12)+1,INSTR(partition_stop,'''','''',1,13)-INSTR(partition_stop,'''','''',1,12)-1))) temp_space_allocated'); 
       put('          FROM plan_table');
       put('         WHERE statement_id = ''''SQLD360_ASH_DATA_MEM''''');
       -- skipping the filter on PHV to include also rows with SQL_PLAN_HASH_VALUE = 0        
       put('           AND /*cost*/ bytes =  '||i.plan_hash_value||'');
       put('           AND NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'''','''',1,3)+1,INSTR(partition_stop,'''','''',1,4)-INSTR(partition_stop,'''','''',1,3)-1)),position) = '||j.inst_id||'');
       put('           AND NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'''','''',1,4)+1,INSTR(partition_stop,'''','''',1,5)-INSTR(partition_stop,'''','''',1,4)-1)),cpu_cost) = '||j.session_id||'');
       put('           AND NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'''','''',1,5)+1,INSTR(partition_stop,'''','''',1,6)-INSTR(partition_stop,'''','''',1,5)-1)),io_cost) = '||j.session_serial#||'');
       put('           AND timestamp BETWEEN TO_DATE('''''||j.min_sample_time||''''', ''''YYYYMMDDHH24MISS'''') AND TO_DATE('''''||j.max_sample_time||''''', ''''YYYYMMDDHH24MISS'''') ');
       put('           AND remarks = ''''&&sqld360_sqlid.'''''); 
       -- this is to differentiate data from partial exec of overlapping executions (case from my German friend)
       put(q'[         AND NVL(partition_id, ]'||j.sql_exec_id||q'[) = ]'||j.sql_exec_id                                                                                                                             ); 
       put(q'[         AND NVL(distribution, TO_DATE('']'||j.sql_exec_start||q'['', ''YYYYMMDDHH24MISS'')) = TO_DATE('']'||j.sql_exec_start||q'['', ''YYYYMMDDHH24MISS'')                                          ]');
       --
       --put('           AND partition_id IS NOT NULL');
       put('           AND ''''&&diagnostics_pack.'''' = ''''Y''''');
       put('         GROUP BY timestamp)');
       put(' ORDER BY 3');
       put(''';');
       put('END;');
       put('/ ');
       put('@sql/sqld360_9a_pre_one.sql');    

       put('----------------------------');       

       put('DEF title=''Read and Write I/O requests for SQL_EXEC_ID '||j.sql_exec_id||' of PHV '||i.plan_hash_value||'''');
       put('DEF main_table = ''V$ACTIVE_SESSION_HISTORY''');
       put('DEF skip_lch=''''');
       put('DEF chartype = ''LineChart''');
       put('DEF stacked = ''''');
       put('DEF vaxis = ''Number of I/O requests''');
       put('DEF tit_01 = ''Read I/O Request''');
       put('DEF tit_02 = ''Write I/O Request''');
       put('DEF tit_03 = ''''');
       put('DEF tit_04 = ''''');
       put('DEF tit_05 = ''''');
       put('DEF tit_06 = ''''');
       put('DEF tit_07 = ''''');
       put('DEF tit_08 = ''''');
       put('DEF tit_09 = ''''');
       put('DEF tit_10 = ''''');
       put('DEF tit_11 = ''''');
       put('DEF tit_12 = ''''');
       put('DEF tit_13 = ''''');
       put('DEF tit_14 = ''''');
       put('DEF tit_15 = ''''');
       put('DEF foot = ''Data is not aggregated, extracted directly from V$ASH''');
       put('BEGIN');
       put(' :sql_text := ''');
       put('SELECT 0 snap_id,');
       put('       TO_CHAR(end_time, ''''YYYY-MM-DD HH24:MI:SS'''') begin_time,'); 
       put('       TO_CHAR(end_time, ''''YYYY-MM-DD HH24:MI:SS'''') end_time,');
       put('       read_io_requests,');
       put('       write_io_requests,');
       put('       0 dummy_03,');
       put('       0 dummy_04,');
       put('       0 dummy_05,');
       put('       0 dummy_06,');
       put('       0 dummy_07,');
       put('       0 dummy_08,');
       put('       0 dummy_09,');
       put('       0 dummy_10,');
       put('       0 dummy_11,');
       put('       0 dummy_12,');
       put('       0 dummy_13,');
       put('       0 dummy_14,');
       put('       0 dummy_15');
       put('  FROM (SELECT timestamp end_time,');
       put('               SUM(NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'''','''',1,14)+1,INSTR(partition_stop,'''','''',1,15)-INSTR(partition_stop,'''','''',1,14)-1)),0)/ ');
       put('                   ROUND(GREATEST(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'''','''',1,13)+1,INSTR(partition_stop,'''','''',1,14)-INSTR(partition_stop,'''','''',1,13)-1))/1e6,1))) read_io_requests,'); 
       put('               SUM(NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'''','''',1,15)+1,INSTR(partition_stop,'''','''',1,16)-INSTR(partition_stop,'''','''',1,15)-1)),0)/ ');
       put('                   ROUND(GREATEST(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'''','''',1,13)+1,INSTR(partition_stop,'''','''',1,14)-INSTR(partition_stop,'''','''',1,13)-1))/1e6,1))) write_io_requests'); 
       put('          FROM plan_table');
       put('         WHERE statement_id = ''''SQLD360_ASH_DATA_MEM''''');
       -- skipping the filter on PHV to include also rows with SQL_PLAN_HASH_VALUE = 0        
       put('           AND /*cost*/ bytes =  '||i.plan_hash_value||'');
       put('           AND NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'''','''',1,3)+1,INSTR(partition_stop,'''','''',1,4)-INSTR(partition_stop,'''','''',1,3)-1)),position) = '||j.inst_id||'');
       put('           AND NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'''','''',1,4)+1,INSTR(partition_stop,'''','''',1,5)-INSTR(partition_stop,'''','''',1,4)-1)),cpu_cost) = '||j.session_id||'');
       put('           AND NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'''','''',1,5)+1,INSTR(partition_stop,'''','''',1,6)-INSTR(partition_stop,'''','''',1,5)-1)),io_cost) = '||j.session_serial#||'');
       put('           AND timestamp BETWEEN TO_DATE('''''||j.min_sample_time||''''', ''''YYYYMMDDHH24MISS'''') AND TO_DATE('''''||j.max_sample_time||''''', ''''YYYYMMDDHH24MISS'''') ');
       put('           AND remarks = ''''&&sqld360_sqlid.'''''); 
       -- this is to differentiate data from partial exec of overlapping executions (case from my German friend)
       put(q'[         AND NVL(partition_id, ]'||j.sql_exec_id||q'[) = ]'||j.sql_exec_id                                                                                                                             ); 
       put(q'[         AND NVL(distribution, TO_DATE('']'||j.sql_exec_start||q'['', ''YYYYMMDDHH24MISS'')) = TO_DATE('']'||j.sql_exec_start||q'['', ''YYYYMMDDHH24MISS'')                                          ]');
       --
       --put('           AND partition_id IS NOT NULL');
       put('           AND ''''&&diagnostics_pack.'''' = ''''Y''''');
       put('         GROUP BY timestamp)');
       put(' ORDER BY 3');
       put(''';');
       put('END;');
       put('/ ');
       put('@sql/sqld360_9a_pre_one.sql');   

       put('----------------------------');

       put('DEF title=''Read, Write and Interconnect I/O bytes for SQL_EXEC_ID '||j.sql_exec_id||' of PHV '||i.plan_hash_value||'''');
       put('DEF main_table = ''V$ACTIVE_SESSION_HISTORY''');
       put('DEF skip_lch=''''');
       put('DEF chartype = ''LineChart''');
       put('DEF stacked = ''''');
       put('DEF vaxis = ''I/O bytes''');
       put('DEF tit_01 = ''Read I/O Bytes''');
       put('DEF tit_02 = ''Write I/O Bytes''');
       put('DEF tit_03 = ''Interconnect I/O Bytes''');
       put('DEF tit_04 = ''''');
       put('DEF tit_05 = ''''');
       put('DEF tit_06 = ''''');
       put('DEF tit_07 = ''''');
       put('DEF tit_08 = ''''');
       put('DEF tit_09 = ''''');
       put('DEF tit_10 = ''''');
       put('DEF tit_11 = ''''');
       put('DEF tit_12 = ''''');
       put('DEF tit_13 = ''''');
       put('DEF tit_14 = ''''');
       put('DEF tit_15 = ''''');
       put('DEF foot = ''Data is not aggregated, extracted directly from V$ASH''');
       put('BEGIN');
       put(' :sql_text := ''');
       put('SELECT 0 snap_id,');
       put('       TO_CHAR(end_time, ''''YYYY-MM-DD HH24:MI:SS'''') begin_time,'); 
       put('       TO_CHAR(end_time, ''''YYYY-MM-DD HH24:MI:SS'''') end_time,');
       put('       read_io_bytes,');
       put('       write_io_bytes,');
       put('       interconnect_io_bytes,');
       put('       0 dummy_04,');
       put('       0 dummy_05,');
       put('       0 dummy_06,');
       put('       0 dummy_07,');
       put('       0 dummy_08,');
       put('       0 dummy_09,');
       put('       0 dummy_10,');
       put('       0 dummy_11,');
       put('       0 dummy_12,');
       put('       0 dummy_13,');
       put('       0 dummy_14,');
       put('       0 dummy_15');
       put('  FROM (SELECT timestamp end_time,');
       put('               SUM(NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'''','''',1,16)+1,INSTR(partition_stop,'''','''',1,17)-INSTR(partition_stop,'''','''',1,16)-1)),0)/ ');
       put('                   ROUND(GREATEST(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'''','''',1,13)+1,INSTR(partition_stop,'''','''',1,14)-INSTR(partition_stop,'''','''',1,13)-1))/1e6,1))) read_io_bytes,'); 
       put('               SUM(NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'''','''',1,17)+1,INSTR(partition_stop,'''','''',1,18)-INSTR(partition_stop,'''','''',1,17)-1)),0)/ ');
       put('                   ROUND(GREATEST(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'''','''',1,13)+1,INSTR(partition_stop,'''','''',1,14)-INSTR(partition_stop,'''','''',1,13)-1))/1e6,1))) write_io_bytes,'); 
       put('               SUM(NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'''','''',1,18)+1,INSTR(partition_stop,'''','''',1,19)-INSTR(partition_stop,'''','''',1,18)-1)),0)/ ');
       put('                   ROUND(GREATEST(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'''','''',1,13)+1,INSTR(partition_stop,'''','''',1,14)-INSTR(partition_stop,'''','''',1,13)-1))/1e6,1))) interconnect_io_bytes'); 
       put('          FROM plan_table');
       put('         WHERE statement_id = ''''SQLD360_ASH_DATA_MEM''''');
       -- skipping the filter on PHV to include also rows with SQL_PLAN_HASH_VALUE = 0        
       put('           AND /*cost*/ bytes =  '||i.plan_hash_value||'');
       put('           AND NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'''','''',1,3)+1,INSTR(partition_stop,'''','''',1,4)-INSTR(partition_stop,'''','''',1,3)-1)),position) = '||j.inst_id||'');
       put('           AND NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'''','''',1,4)+1,INSTR(partition_stop,'''','''',1,5)-INSTR(partition_stop,'''','''',1,4)-1)),cpu_cost) = '||j.session_id||'');
       put('           AND NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'''','''',1,5)+1,INSTR(partition_stop,'''','''',1,6)-INSTR(partition_stop,'''','''',1,5)-1)),io_cost) = '||j.session_serial#||'');
       put('           AND timestamp BETWEEN TO_DATE('''''||j.min_sample_time||''''', ''''YYYYMMDDHH24MISS'''') AND TO_DATE('''''||j.max_sample_time||''''', ''''YYYYMMDDHH24MISS'''') ');
       put('           AND remarks = ''''&&sqld360_sqlid.'''''); 
       -- this is to differentiate data from partial exec of overlapping executions (case from my German friend)
       put(q'[         AND NVL(partition_id, ]'||j.sql_exec_id||q'[) = ]'||j.sql_exec_id                                                                                                                             ); 
       put(q'[         AND NVL(distribution, TO_DATE('']'||j.sql_exec_start||q'['', ''YYYYMMDDHH24MISS'')) = TO_DATE('']'||j.sql_exec_start||q'['', ''YYYYMMDDHH24MISS'')                                          ]');
       --
       --put('           AND partition_id IS NOT NULL');
       put('           AND ''''&&diagnostics_pack.'''' = ''''Y''''');
       put('         GROUP BY timestamp)');
       put(' ORDER BY 3');
       put(''';');
       put('END;');
       put('/ ');
       put('@sql/sqld360_9a_pre_one.sql');

       put('----------------------------');      

       put('DEF title = ''Raw Data for SQL_EXEC_ID '||j.sql_exec_id||' of PHV '||i.plan_hash_value||'''');
       put('DEF main_table = ''GV$ACTIVE_SESSION_HISTORY''');
       put('BEGIN ');
       put('  :sql_text := ''');
       put('SELECT /*+ &&top_level_hints. */ ');
       put('       statement_id     source,  ');
       put('       search_columns   dbid,    ');
       put('       cardinality      snap_id, ');
       put('       position         instance_number,  ');
       put('       parent_id        sample_id,        ');
       put('       TO_CHAR(timestamp, ''''YYYY-MM-DD/HH24:MI:SS'''')        sample_time, ');
       put('       partition_id     sql_exec_id, ');
       put('       TO_CHAR(TO_DATE(distribution,''''YYYYMMDDHH24MISS''''), ''''YYYY-MM-DD/HH24:MI:SS'''')  sql_exec_start, ');
       put('       cpu_cost         session_id,        ');
       put('       io_cost          session_serial#,   ');
       put('       TO_NUMBER(SUBSTR(partition_start,INSTR(partition_start,'''','''',1,13)+1))            user_id,           ');
       put('       remarks          sql_id,            ');
       put('       cost             plan_hash_value,   ');
       put('       TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'''','''',1,19)+1)) sql_full_plan_hash_value, ');
       put('       id               sql_plan_line_id,  ');
       put('       operation        sql_plan_operation,');  
       put('       options          sql_plan_options,  '); 
       put('       object_node      cpu_or_event,      ');
       put('       other_tag        wait_class,        ');
       put('       TO_NUMBER(SUBSTR(partition_start,1,INSTR(partition_start,'''','''',1,1)-1)) seq#, ');
       put('       SUBSTR(partition_start,INSTR(partition_start,'''','''',1,1)+1,INSTR(partition_start,'''','''',1,2)-INSTR(partition_start,'''','''',1,1)-1) p1text, ');  
       put('       TO_NUMBER(SUBSTR(partition_start,INSTR(partition_start,'''','''',1,2)+1,INSTR(partition_start,'''','''',1,3)-INSTR(partition_start,'''','''',1,2)-1)) p1, ');
       put('       SUBSTR(partition_start,INSTR(partition_start,'''','''',1,3)+1,INSTR(partition_start,'''','''',1,4)-INSTR(partition_start,'''','''',1,3)-1) p2text,  ');
       put('       TO_NUMBER(SUBSTR(partition_start,INSTR(partition_start,'''','''',1,4)+1,INSTR(partition_start,'''','''',1,5)-INSTR(partition_start,'''','''',1,4)-1)) p2, ');
       put('       SUBSTR(partition_start,INSTR(partition_start,'''','''',1,5)+1,INSTR(partition_start,'''','''',1,6)-INSTR(partition_start,'''','''',1,5)-1) p3text,  ');
       put('       TO_NUMBER(SUBSTR(partition_start,INSTR(partition_start,'''','''',1,6)+1,INSTR(partition_start,'''','''',1,7)-INSTR(partition_start,'''','''',1,6)-1)) p3, ');
       put('       object_instance  current_obj#, ');
       put('       TO_NUMBER(SUBSTR(partition_start,INSTR(partition_start,'''','''',1,7)+1,INSTR(partition_start,'''','''',1,8)-INSTR(partition_start,'''','''',1,7)-1)) current_file#,  ');
       put('       TO_NUMBER(SUBSTR(partition_start,INSTR(partition_start,'''','''',1,8)+1,INSTR(partition_start,'''','''',1,9)-INSTR(partition_start,'''','''',1,8)-1)) current_block#, ');
       put('       TO_NUMBER(SUBSTR(partition_start,INSTR(partition_start,'''','''',1,9)+1,INSTR(partition_start,'''','''',1,10)-INSTR(partition_start,'''','''',1,9)-1)) current_row#,  ');
       put('       SUBSTR(partition_stop,1,INSTR(partition_stop,'''','''',1,1)-1) in_parse, ');
       put('       SUBSTR(partition_stop,INSTR(partition_stop,'''','''',1,1)+1,INSTR(partition_stop,'''','''',1,2)-INSTR(partition_stop,'''','''',1,1)-1) in_hard_parse, ');
       put('       SUBSTR(partition_stop,INSTR(partition_stop,'''','''',1,2)+1,INSTR(partition_stop,'''','''',1,3)-INSTR(partition_stop,'''','''',1,2)-1) in_sql_execution, ');
       put('       TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'''','''',1,3)+1,INSTR(partition_stop,'''','''',1,4)-INSTR(partition_stop,'''','''',1,3)-1)) qc_instance_id, ');
       put('       TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'''','''',1,4)+1,INSTR(partition_stop,'''','''',1,5)-INSTR(partition_stop,'''','''',1,4)-1)) qc_session_id,  ');
       put('       TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'''','''',1,5)+1,INSTR(partition_stop,'''','''',1,6)-INSTR(partition_stop,'''','''',1,5)-1)) qc_session_serial#, ');
       put('       SUBSTR(partition_stop,INSTR(partition_stop,'''','''',1,6)+1,INSTR(partition_stop,'''','''',1,7)-INSTR(partition_stop,'''','''',1,6)-1) blocking_session_status, ');
       put('       TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'''','''',1,7)+1,INSTR(partition_stop,'''','''',1,8)-INSTR(partition_stop,'''','''',1,7)-1)) blocking_session, ');
       put('       TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'''','''',1,8)+1,INSTR(partition_stop,'''','''',1,9)-INSTR(partition_stop,'''','''',1,8)-1)) blocking_session_serial#, ');
       put('       TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'''','''',1,9)+1,INSTR(partition_stop,'''','''',1,10)-INSTR(partition_stop,'''','''',1,9)-1)) blocking_inst_id, ');
       put('       TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'''','''',1,10)+1,INSTR(partition_stop,'''','''',1,11)-INSTR(partition_stop,'''','''',1,10)-1)) px_flags, ');
       put('       TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'''','''',1,11)+1,INSTR(partition_stop,'''','''',1,12)-INSTR(partition_stop,'''','''',1,11)-1)) pga_allocated, ');
       put('       TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'''','''',1,12)+1,INSTR(partition_stop,'''','''',1,13)-INSTR(partition_stop,'''','''',1,12)-1)) temp_space_allocated, ');
       put('       TO_NUMBER(SUBSTR(partition_start,INSTR(partition_start,'''','''',1,10)+1,INSTR(partition_start,'''','''',1,11)-INSTR(partition_start,'''','''',1,10)-1)) tm_delta_time, ');
       put('       TO_NUMBER(SUBSTR(partition_start,INSTR(partition_start,'''','''',1,11)+1,INSTR(partition_start,'''','''',1,12)-INSTR(partition_start,'''','''',1,11)-1)) tm_delta_cpu_time, ');
       put('       TO_NUMBER(SUBSTR(partition_start,INSTR(partition_start,'''','''',1,12)+1,INSTR(partition_start,'''','''',1,13)-INSTR(partition_start,'''','''',1,12)-1)) tm_delta_db_time, ');
       put('       TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'''','''',1,13)+1,INSTR(partition_stop,'''','''',1,14)-INSTR(partition_stop,'''','''',1,13)-1)) delta_time, ');
       put('       TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'''','''',1,14)+1,INSTR(partition_stop,'''','''',1,15)-INSTR(partition_stop,'''','''',1,14)-1)) delta_read_io_requests, ');
       put('       TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'''','''',1,15)+1,INSTR(partition_stop,'''','''',1,16)-INSTR(partition_stop,'''','''',1,15)-1)) delta_write_io_requests, ');
       put('       TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'''','''',1,16)+1,INSTR(partition_stop,'''','''',1,17)-INSTR(partition_stop,'''','''',1,16)-1)) delta_read_io_bytes, ');
       put('       TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'''','''',1,17)+1,INSTR(partition_stop,'''','''',1,18)-INSTR(partition_stop,'''','''',1,17)-1)) delta_write_io_bytes, ');
       put('       TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'''','''',1,18)+1,INSTR(partition_stop,'''','''',1,19)-INSTR(partition_stop,'''','''',1,18)-1)) delta_interconnect_io_bytes ');
       put('  FROM plan_table '); 
       put(' WHERE remarks = ''''&&sqld360_sqlid.'''' ');
       put('   AND statement_id = ''''SQLD360_ASH_DATA_MEM'''' ');
       -- The comment on the PHV is intentional, the goal is to extract even rows for a different PHV (adaptive, not resolved yet) for the specific execution
       put('   AND /*cost*/ bytes =  '||i.plan_hash_value||'');
       put('   AND NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'''','''',1,3)+1,INSTR(partition_stop,'''','''',1,4)-INSTR(partition_stop,'''','''',1,3)-1)),position) = '||j.inst_id||'');
       put('   AND NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'''','''',1,4)+1,INSTR(partition_stop,'''','''',1,5)-INSTR(partition_stop,'''','''',1,4)-1)),cpu_cost) = '||j.session_id||'');
       put('   AND NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'''','''',1,5)+1,INSTR(partition_stop,'''','''',1,6)-INSTR(partition_stop,'''','''',1,5)-1)),io_cost) = '||j.session_serial#||'');
       put('   AND timestamp BETWEEN TO_DATE('''''||j.min_sample_time||''''', ''''YYYYMMDDHH24MISS'''') AND TO_DATE('''''||j.max_sample_time||''''', ''''YYYYMMDDHH24MISS'''') ');
       -- this is to differentiate data from partial exec of overlapping executions (case from my German friend)
       put(q'[ AND NVL(partition_id, ]'||j.sql_exec_id||q'[) = ]'||j.sql_exec_id                                                                                                                             ); 
       put(q'[ AND NVL(distribution, TO_DATE('']'||j.sql_exec_start||q'['', ''YYYYMMDDHH24MISS'')) = TO_DATE('']'||j.sql_exec_start||q'['', ''YYYYMMDDHH24MISS'')                                          ]');
       --
       put('   AND ''''&&diagnostics_pack.'''' = ''''Y''''');
       put(' ORDER BY timestamp,position ');
       put(''';');
       put('END;');
       put('/');
       put('@&&sqld360_skip_rawash.sql/sqld360_9a_pre_one.sql');

       put('----------------------------');  

       put('SPO &&one_spool_filename..html APP;');
       put('PRO <br>                           ');
       put('SPO OFF                            ');

      
    END LOOP;

    put('SPO &&one_spool_filename..html APP;      ');
    put('PRO </ol>                                ');
    put('PRO <h2>Top Executions from history</h2> ');
    put('SET DEF @                                ');
    put('PRO <ol start="@report_sequence.">       ');
    put('SET DEF &                                ');
    put('SPO OFF                                  ');  

    FOR j IN (SELECT inst_id, session_id, session_serial#, sql_exec_id, sql_exec_start, TO_CHAR(min_sample_time, 'YYYYMMDDHH24MISS') min_sample_time, TO_CHAR(max_sample_time, 'YYYYMMDDHH24MISS') max_sample_time
                FROM (SELECT inst_id, session_id, session_serial#, sql_exec_id, sql_exec_start,  MIN(sample_time) min_sample_time, MAX(sample_time) max_sample_time, COUNT(*) num_samples
                        FROM (SELECT NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,',',1,3)+1,INSTR(partition_stop,',',1,4)-INSTR(partition_stop,',',1,3)-1)),position) inst_id,  
                                     NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,',',1,4)+1,INSTR(partition_stop,',',1,5)-INSTR(partition_stop,',',1,4)-1)),cpu_cost) session_id,  
                                     NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,',',1,5)+1,INSTR(partition_stop,',',1,6)-INSTR(partition_stop,',',1,5)-1)),io_cost) session_serial#,  
                                     timestamp sample_time, 
                                     NVL(partition_id, FIRST_VALUE(partition_id IGNORE NULLS) OVER (PARTITION BY NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,',',1,3)+1,INSTR(partition_stop,',',1,4)-INSTR(partition_stop,',',1,3)-1)),position), 
                                                                                                                 NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,',',1,4)+1,INSTR(partition_stop,',',1,5)-INSTR(partition_stop,',',1,4)-1)),cpu_cost), 
                                                                                                                 NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,',',1,5)+1,INSTR(partition_stop,',',1,6)-INSTR(partition_stop,',',1,5)-1)),io_cost) 
                                                                                                    ORDER BY timestamp ROWS BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING)) sql_exec_id, 
                                     NVL(distribution, FIRST_VALUE(distribution IGNORE NULLS) OVER (PARTITION BY NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,',',1,3)+1,INSTR(partition_stop,',',1,4)-INSTR(partition_stop,',',1,3)-1)),position), 
                                                                                                                 NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,',',1,4)+1,INSTR(partition_stop,',',1,5)-INSTR(partition_stop,',',1,4)-1)),cpu_cost), 
                                                                                                                 NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,',',1,5)+1,INSTR(partition_stop,',',1,6)-INSTR(partition_stop,',',1,5)-1)),io_cost) 
                                                                                                    ORDER BY timestamp ROWS BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING)) sql_exec_start 
                                FROM plan_table 
                               WHERE statement_id = 'SQLD360_ASH_DATA_HIST'
                                 AND /*cost*/ bytes =  i.plan_hash_value
                                 AND '&&diagnostics_pack.' = 'Y'
                                 AND remarks = '&&sqld360_sqlid.')
                      WHERE sql_exec_id IS NOT NULL
                      GROUP BY inst_id, session_id, session_serial#, sql_exec_id, sql_exec_start
                      ORDER BY num_samples DESC)
             WHERE ROWNUM <= &&sqld360_conf_num_top_execs.) LOOP

       put('SPO &&one_spool_filename..html APP;');
       put('PRO SQL_EXEC_ID '||j.sql_exec_id||' from inst:'||j.inst_id||' sess:'||j.session_id||' serial#:'||j.session_serial#||' between '||TO_DATE(j.min_sample_time,'YYYYMMDDHH24MISS')||' and '||TO_DATE(j.max_sample_time,'YYYYMMDDHH24MISS')||' ');
       put('SPO OFF');

       put('----------------------------');

       put('COL treeColor NEW_V treeColor');    
    
       -- not the most elegant soluton but SQL*Plus variable cannot store long string (aka long exec plans)
       put('DELETE plan_table WHERE statement_id = ''SQLD360_TREECOLOR'' AND operation = ''&&sqld360_sqlid.''; ');
       put(q'[INSERT ALL                                                                                                                                                                                  ]');
       put(q'[  WHEN 1 = 1 THEN INTO plan_table (statement_id, OPERATION, OPTIONS) VALUES ('SQLD360_TREECOLOR', '&&sqld360_sqlid.', node_color)                                                           ]');
       put(q'[  WHEN 1 = 1 THEN INTO plan_table (statement_id, OPERATION, OPTIONS) VALUES ('SQLD360_TREECOLOR', '&&sqld360_sqlid.', expanded_node_color)                                                  ]');
       put(q'[  WHEN 1 = 1 THEN INTO plan_table (statement_id, OPERATION, OPTIONS) VALUES ('SQLD360_TREECOLOR', '&&sqld360_sqlid.', collapsed_node_color)                                                 ]');
       put(q'[WITH ashdata AS (-- count the number of samples in ASH for each step                                                                                                                        ]');
       put(q'[                 -- goal is to compute RATIO_TO_REPORT                                                                                                                                      ]');
       put(q'[                 SELECT NVL(id,0) id,                                                                                                                                                       ]');
       put(q'[                        COUNT(*) num_samples,                                                                                                                                               ]');
       put(q'[                        ROUND(100*NVL(RATIO_TO_REPORT(COUNT(*)) OVER (),0),2) perc_impact                                                                                                   ]');
       put(q'[                   FROM plan_table                                                                                                                                                          ]');
       put(q'[                  WHERE statement_id = 'SQLD360_ASH_DATA_HIST'                                                                                                                              ]');
       put(q'[                    AND /*cost*/ bytes =]'|| i.plan_hash_value                                                                                                                                          );   
       put(q'[                    AND NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,',',1,3)+1,INSTR(partition_stop,',',1,4)-INSTR(partition_stop,',',1,3)-1)),position) = ]'||j.inst_id         );
       put(q'[                    AND NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,',',1,4)+1,INSTR(partition_stop,',',1,5)-INSTR(partition_stop,',',1,4)-1)),cpu_cost) = ]'||j.session_id      );
       put(q'[                    AND NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,',',1,5)+1,INSTR(partition_stop,',',1,6)-INSTR(partition_stop,',',1,5)-1)),io_cost) = ]' ||j.session_serial# );
       put(q'[                    AND timestamp BETWEEN TO_DATE(']'||j.min_sample_time||q'[', 'YYYYMMDDHH24MISS') AND TO_DATE(']'||j.max_sample_time||q'[', 'YYYYMMDDHH24MISS')                           ]');
       put(q'[                    AND remarks = '&&sqld360_sqlid.'                                                                                                                                        ]'); 
       -- this is to differentiate data from partial exec of overlapping executions (case from my German friend)
       put(q'[                    AND NVL(partition_id, ]'||j.sql_exec_id||q'[) = ]'||j.sql_exec_id                                                                                                         ); 
       put(q'[                    AND NVL(distribution, TO_DATE(']'||j.sql_exec_start||q'[', 'YYYYMMDDHH24MISS')) = TO_DATE(']'||j.sql_exec_start||q'[', 'YYYYMMDDHH24MISS')                              ]');
       --
       put(q'[                  GROUP BY NVL(id,0)),                                                                                                                                                      ]');
       put(q'[     orig_plan AS (-- extract the plan steps "as is", just replace to single quote in the filter predicates                                                                                 ]');
       put(q'[                   -- precedence is given to plan from memory since it has filters                                                                                                          ]');
       put(q'[                   -- using RANK since there could be more than one entry but with different predicate ordering                                                                             ]');
       put(q'[                   SELECT sql_id, plan_hash_value, id, parent_id, operation, options, object_name, access_predicates, filter_predicates, other_xml                                          ]');
       put(q'[                     FROM (SELECT sql_id, plan_hash_value, id, parent_id, operation, options, object_name,                                                                                  ]');
       put(q'[                                  REPLACE(SUBSTR(access_predicates,1,1500), CHR(39) , CHR(92)||CHR(39)) access_predicates,                                                                  ]');
       put(q'[                                  REPLACE(SUBSTR(filter_predicates,1,1500), CHR(39) , CHR(92)||CHR(39)) filter_predicates,                                                                  ]');
       put(q'[                                  other_xml,                                                                                                                                                ]');
       put(q'[                                  RANK() OVER (ORDER BY inst_id, child_number) rnk                                                                                                          ]');
       put(q'[                             FROM gv$sql_plan_statistics_all                                                                                                                                ]');
       put(q'[                            WHERE sql_id = '&&sqld360_sqlid.'                                                                                                                               ]');            
       put(q'[                              AND plan_hash_value =]'||i.plan_hash_value||q'[)                                                                                                              ]');                                                             
       put(q'[                    WHERE rnk = 1                                                                                                                                                           ]');
       put(q'[                   UNION ALL                                                                                                                                                                ]');
       put(q'[                   SELECT sql_id, plan_hash_value, id, parent_id, operation, options, object_name,                                                                                          ]');
       put(q'[                          REPLACE(access_predicates, CHR(39), CHR(92)||CHR(39)) access_predicates,                                                                                          ]');
       put(q'[                          REPLACE(filter_predicates, CHR(39), CHR(92)||CHR(39)) filter_predicates,                                                                                          ]');
       put(q'[                          other_xml                                                                                                                                                         ]');
       put(q'[                     FROM dba_hist_sql_plan                                                                                                                                                 ]');
       put(q'[                    WHERE sql_id = '&&sqld360_sqlid.'                                                                                                                                       ]');
       put(q'[                      AND plan_hash_value =]'||i.plan_hash_value                                                                                                                              );
       put(q'[                      AND NOT EXISTS (SELECT 1                                                                                                                                              ]');  
       put(q'[                                        FROM gv$sql_plan_statistics_all                                                                                                                     ]');
       put(q'[                                       WHERE plan_hash_value =]'||i.plan_hash_value                                                                                                           );
       put(q'[                                         AND sql_id = '&&sqld360_sqlid.'                                                                                                                    ]');
       put(q'[                                         AND '&&diagnostics_pack.' = 'Y')),                                                                                                                 ]');
       put(q'[     skip_steps AS (-- extract the display_map for the plan, to identify why steps are "skipped" because of adaptive                                                                        ]');
       put(q'[                    SELECT sql_id, plan_hash_value, EXTRACTVALUE(VALUE(b),'/row/@op') stepid, EXTRACTVALUE(VALUE(b),'/row/@skp') skp, EXTRACTVALUE(VALUE(b),'/row/@dep') dep                ]');
       put(q'[                      FROM orig_plan a,                                                                                                                                                     ]');
       put(q'[                           TABLE(XMLSEQUENCE(EXTRACT(XMLTYPE(a.other_xml),'/*/display_map/row'))) b                                                                                         ]');
       put(q'[                     WHERE sql_id = '&&sqld360_sqlid.'                                                                                                                                      ]'); 
       put(q'[                       AND other_xml IS NOT NULL),                                                                                                                                          ]');
       put(q'[     adapt_plan_no_parent AS (-- generate adaptive_id (aka step_id) once the adaptive steps are excluded                                                                                    ]');
       put(q'[                              SELECT a.sql_id, a.plan_hash_value, a.id, a.parent_id, b.dep,                                                                                                 ]');
       put(q'[                                     (ROW_NUMBER() OVER (ORDER BY a.id))-1 adapt_id, a.operation, a.options, a.object_name, a.access_predicates, a.filter_predicates, b.skp                 ]');
       put(q'[                                FROM orig_plan a,                                                                                                                                           ]');
       put(q'[                                     skip_steps b                                                                                                                                           ]');
       put(q'[                               WHERE a.id = b.stepid(+)                                                                                                                                     ]');
       put(q'[                                 AND (b.skp = 0 OR b.skp IS NULL)),                                                                                                                         ]');
       put(q'[     full_adaptive_plan AS (-- generate the parent adaptive step id                                                                                                                         ]');
       put(q'[                            SELECT id, adapt_id, NVL(adapt_parent_id, parent_id) parent_id, operation, options, object_name, access_predicates, filter_predicates                           ]');
       put(q'[                              FROM (SELECT dep, adapt_id, id, (SELECT MAX(adapt_id) FROM adapt_plan_no_parent b WHERE a.dep-1 = NVL(b.dep,0) AND b.adapt_id < a.adapt_id ) adapt_parent_id,        ]');
       put(q'[                                           parent_id, a.operation operation, a.options, a.object_name, a.access_predicates, a.filter_predicates                                             ]');
       put(q'[                                      FROM adapt_plan_no_parent a)),                                                                                                                        ]');
       put(q'[     plan_with_ash AS (SELECT full_adaptive_plan.*, NVL(ashdata.num_samples,0) num_samples, NVL(ashdata.perc_impact,0) perc_impact                                                          ]');
       put(q'[                              FROM full_adaptive_plan,                                                                                                                                      ]');
       put(q'[                                   ashdata                                                                                                                                                  ]');
       put(q'[                             WHERE ashdata.id(+) = full_adaptive_plan.id),                                                                                                                  ]');
       put(q'[     plan_with_rec_impact AS (-- compute recursive impact (substree impact)                                                                                                                 ]');
       put(q'[                              SELECT a.*, (SELECT sum(b.perc_impact)                                                                                                                        ]');
       put(q'[                                             FROM plan_with_ash b                                                                                                                           ]');
       put(q'[                                            START WITH b.adapt_id = a.adapt_id                                                                                                                          ]');
       put(q'[                                           CONNECT BY prior b.adapt_id = b.parent_id) sum_perc_impact                                                                                             ]');
       put(q'[                                FROM plan_with_ash a)                                                                                                                                       ]');                                                                                  
       put(q'[SELECT adapt_id id,                                                                                                                                                                         ]');
       put(q'[       'data.setRowProperty('||adapt_id||', ''style'',          ''background:#FF'||LPAD(LTRIM(TO_CHAR(255-(255*perc_impact    /100),'XXXX')),2,'0')||CASE WHEN perc_impact = 0 THEN 'FF' ELSE '00' END||''');' node_color,               ]');
       put(q'[       'data.setRowProperty('||adapt_id||', ''expandedStyle'',  ''background:#FF'||LPAD(LTRIM(TO_CHAR(255-(255*perc_impact    /100),'XXXX')),2,'0')||CASE WHEN perc_impact = 0 THEN 'FF' ELSE '00' END||''');' expanded_node_color,      ]');
       put(q'[       'data.setRowProperty('||adapt_id||', ''collapsedStyle'', ''background:#FF'||LPAD(LTRIM(TO_CHAR(255-(255*sum_perc_impact/100),'XXXX')),2,'0')||CASE WHEN sum_perc_impact = 0 THEN 'FF' ELSE '00' END||''');' collapsed_node_color  ]');  
       put(q'[  FROM plan_with_rec_impact                                                                                                                                                                 ]');
       put(q'[ ORDER BY adapt_id;                                                                                                                                                                         ]');

       -- new in 1705
       put('DEF title=''Plan Tree with subtree for SQL_EXEC_ID '||j.sql_exec_id||' of PHV '||i.plan_hash_value||'''');
       put(q'[DEF main_table = 'DBA_HIST_SQL_PLAN']');
       put(q'[DEF skip_html='Y' ]');
       put(q'[DEF skip_text='Y' ]');
       put(q'[DEF skip_csv='Y'  ]');
       put(q'[DEF skip_tch=''   ]');

       put( 'BEGIN');
       put(q'[ :sql_text := ' ]');
       put(q'[WITH ashdata AS (-- count the number of samples in ASH for each step                                                                                                                 ]');
       put(q'[                 -- goal is to compute RATIO_TO_REPORT                                                                                                                               ]');
       put(q'[                 SELECT NVL(id,0) id,                                                                                                                                                ]');
       put(q'[                        COUNT(*) num_samples,                                                                                                                                        ]');
       put(q'[                        ROUND(100*NVL(RATIO_TO_REPORT(COUNT(*)) OVER (),0),2) perc_impact                                                                                            ]');
       put(q'[                   FROM plan_table                                                                                                                                                   ]');
       put(q'[                  WHERE statement_id LIKE ''SQLD360_ASH_DATA_HIST''                                                                                                                  ]');
       put(q'[                    AND /*cost*/ bytes =]'|| i.plan_hash_value                                                                                                                                   ); 
       put(q'[                    AND NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'','',1,3)+1,INSTR(partition_stop,'','',1,4)-INSTR(partition_stop,'','',1,3)-1)),position) = ]'||j.inst_id         );
       put(q'[                    AND NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'','',1,4)+1,INSTR(partition_stop,'','',1,5)-INSTR(partition_stop,'','',1,4)-1)),cpu_cost) = ]'||j.session_id      );
       put(q'[                    AND NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'','',1,5)+1,INSTR(partition_stop,'','',1,6)-INSTR(partition_stop,'','',1,5)-1)),io_cost) = ]' ||j.session_serial# );
       put(q'[                    AND timestamp BETWEEN TO_DATE('']'||j.min_sample_time||q'['', ''YYYYMMDDHH24MISS'') AND TO_DATE('']'||j.max_sample_time||q'['', ''YYYYMMDDHH24MISS'')                           ]');  
       put(q'[                    AND remarks = ''&&sqld360_sqlid.''                                                                                                                               ]'); 
       -- this is to differentiate data from partial exec of overlapping executions (case from my German friend)
       put(q'[                    AND NVL(partition_id, ]'||j.sql_exec_id||q'[) = ]'||j.sql_exec_id                                                                                                  ); 
       put(q'[                    AND NVL(distribution, TO_DATE('']'||j.sql_exec_start||q'['', ''YYYYMMDDHH24MISS'')) = TO_DATE('']'||j.sql_exec_start||q'['', ''YYYYMMDDHH24MISS'')               ]');
       --
       put(q'[                  GROUP BY NVL(id,0)),                                                                                                                                               ]');
       put(q'[     orig_plan AS (-- extract the plan steps "as is", just replace to single quote in the filter predicates                                                                          ]');
       put(q'[                   -- precedence is given to plan from memory since it has filters                                                                                                   ]');
       put(q'[                   -- using RANK since there could be more than one entry but with different predicate ordering                                                                      ]');
       put(q'[                   SELECT sql_id, plan_hash_value, id, parent_id, operation, options, object_name, access_predicates, filter_predicates, other_xml                                   ]');
       put(q'[                     FROM (SELECT sql_id, plan_hash_value, id, parent_id, operation, options, object_name,                                                                           ]');
       put(q'[                                  REPLACE(SUBSTR(access_predicates,1,1500), CHR(39) , CHR(92)||CHR(39)) access_predicates,                                                           ]');
       put(q'[                                  REPLACE(SUBSTR(filter_predicates,1,1500), CHR(39) , CHR(92)||CHR(39)) filter_predicates,                                                           ]');
       put(q'[                                  other_xml,                                                                                                                                         ]');
       put(q'[                                  RANK() OVER (ORDER BY inst_id, child_number) rnk                                                                                                   ]');
       put(q'[                             FROM gv$sql_plan_statistics_all                                                                                                                         ]');
       put(q'[                            WHERE sql_id = ''&&sqld360_sqlid.''                                                                                                                      ]');            
       put(q'[                              AND plan_hash_value =]'||i.plan_hash_value||q'[)                                                                                                       ]');                                                             
       put(q'[                    WHERE rnk = 1                                                                                                                                                    ]');
       put(q'[                   UNION ALL                                                                                                                                                         ]');
       put(q'[                   SELECT sql_id, plan_hash_value, id, parent_id, operation, options, object_name,                                                                                   ]');
       put(q'[                          REPLACE(access_predicates, CHR(39), CHR(92)||CHR(39)) access_predicates,                                                                                   ]');
       put(q'[                          REPLACE(filter_predicates, CHR(39), CHR(92)||CHR(39)) filter_predicates,                                                                                   ]');
       put(q'[                          other_xml                                                                                                                                                  ]');
       put(q'[                     FROM dba_hist_sql_plan                                                                                                                                          ]');
       put(q'[                    WHERE sql_id = ''&&sqld360_sqlid.''                                                                                                                              ]');
       put(q'[                      AND plan_hash_value =]'||i.plan_hash_value                                                                                                                       );
       put(q'[                      AND NOT EXISTS (SELECT 1                                                                                                                                       ]');  
       put(q'[                                        FROM gv$sql_plan_statistics_all                                                                                                              ]');
       put(q'[                                       WHERE plan_hash_value =]'||i.plan_hash_value                                                                                                    );
       put(q'[                                         AND sql_id = ''&&sqld360_sqlid.''                                                                                                           ]');
       put(q'[                                         AND ''&&diagnostics_pack.'' = ''Y'')),                                                                                                      ]');
       put(q'[     skip_steps AS (-- extract the display_map for the plan, to identify why steps are "skipped" because of adaptive                                                                 ]');
       put(q'[                    SELECT sql_id, plan_hash_value, EXTRACTVALUE(VALUE(b),''/row/@op'') stepid, EXTRACTVALUE(VALUE(b),''/row/@skp'') skp, EXTRACTVALUE(VALUE(b),''/row/@dep'') dep   ]');
       put(q'[                      FROM orig_plan a,                                                                                                                                              ]');
       put(q'[                           TABLE(XMLSEQUENCE(EXTRACT(XMLTYPE(a.other_xml),''/*/display_map/row''))) b                                                                                ]');
       put(q'[                     WHERE sql_id = ''&&sqld360_sqlid.''                                                                                                                             ]'); 
       put(q'[                       AND other_xml IS NOT NULL),                                                                                                                                   ]');
       put(q'[     adapt_plan_no_parent AS (-- generate adaptive_id (aka step_id) once the adaptive steps are excluded                                                                             ]');
       put(q'[                              SELECT a.sql_id, a.plan_hash_value, a.id, a.parent_id, b.dep,                                                                                          ]');
       put(q'[                                     (ROW_NUMBER() OVER (ORDER BY a.id))-1 adapt_id, a.operation, a.options, a.object_name, a.access_predicates, a.filter_predicates, b.skp          ]');
       put(q'[                                FROM orig_plan a,                                                                                                                                    ]');
       put(q'[                                     skip_steps b                                                                                                                                    ]');
       put(q'[                               WHERE a.id = b.stepid(+)                                                                                                                              ]');
       put(q'[                                 AND (b.skp = 0 OR b.skp IS NULL)),                                                                                                                  ]');
       put(q'[     full_adaptive_plan AS (-- generate the parent adaptive step id                                                                                                                  ]');
       put(q'[                            SELECT id, adapt_id, NVL(adapt_parent_id, parent_id) parent_id, operation, options, object_name, access_predicates, filter_predicates                    ]');
       put(q'[                              FROM (SELECT dep, adapt_id, id, (SELECT MAX(adapt_id) FROM adapt_plan_no_parent b WHERE a.dep-1 = NVL(b.dep,0) AND b.adapt_id < a.adapt_id ) adapt_parent_id, ]');
       put(q'[                                           parent_id, a.operation operation, a.options, a.object_name, a.access_predicates, a.filter_predicates                                      ]');
       put(q'[                                      FROM adapt_plan_no_parent a)),                                                                                                                 ]');
       put(q'[     plan_with_ash AS (SELECT full_adaptive_plan.*, NVL(ashdata.num_samples,0) num_samples, NVL(ashdata.perc_impact,0) perc_impact                                                   ]');
       put(q'[                              FROM full_adaptive_plan,                                                                                                                               ]');
       put(q'[                                   ashdata                                                                                                                                           ]');
       put(q'[                             WHERE ashdata.id(+) = full_adaptive_plan.id),                                                                                                           ]');
       put(q'[     plan_with_rec_impact AS (-- compute recursive impact (substree impact)                                                                                                          ]');
       put(q'[                              SELECT a.*, (SELECT sum(b.perc_impact)                                                                                                                 ]');
       put(q'[                                             FROM plan_with_ash b                                                                                                                    ]');
       put(q'[                                            START WITH b.adapt_id = a.adapt_id                                                                                                                   ]');
       put(q'[                                           CONNECT BY prior b.adapt_id = b.parent_id) sum_perc_impact                                                                                      ]');
       put(q'[                                FROM plan_with_ash a)                                                                                                                                ]');                                                                                  
       put(q'[SELECT ''{v: ''''''||adapt_id||'''''',f: ''''''||adapt_id||'' - ''||operation||'' ''||options||NVL2(object_name,''<br>'','' '')||object_name||''''''}'' id,                          ]'); 
       put(q'[       parent_id,                                                                                                                                                                    ]');
       put(q'[       SUBSTR(''Step ID: ''||adapt_id||'' (ASH Step ID: ''||id||'')\nASH Samples: ''||num_samples||'' (''||perc_impact||''%)''||                                                     ]');
       put(q'[       ''\nSubstree Impact ''||sum_perc_impact||''%''||                                                                                                                              ]');
       put(q'[       NVL2(access_predicates,''\n\nAccess Predicates: ''||access_predicates,'''')||NVL2(filter_predicates,''\n\nFilter Predicates: ''||filter_predicates,''''),1,4000) message,     ]');
       put(q'[       adapt_id id3                                                                                                                                                                  ]');
       put(q'[  FROM plan_with_rec_impact                                                                                                                                                          ]');
       put(q'[ ORDER BY id3                                                                                                                                                                        ]'); 
       put(''';');
       put('END;');
       put('/ ');
       put('@sql/sqld360_9a_pre_one.sql');

       put('----------------------------');

       put('DEF title=''Plan Step IDs timeline for SQL_EXEC_ID '||j.sql_exec_id||' of PHV '||i.plan_hash_value||'''');
       put('DEF main_table = ''DBA_HIST_ACTIVE_SESS_HISTORY''');
       put('DEF skip_uch=''''');
       put('DEF abstract = ''Top SQL Plan Steps''');
       put('DEF vaxis = ''SQL Plan Step ID''');
       put('DEF foot = ''Data is not aggregated, extracted directly from V$ASH, Y-axis report plan steps, size of the bubble is number of samples, color is major contributor (>50%) for bubble''');

       put('COL bubblesDetails NEW_V bubblesDetails');
       put('SELECT ''<br>Step Details<br>''||LISTAGG(step_details,''<br>'') WITHIN GROUP (ORDER BY id) bubblesDetails');
       put('          FROM (SELECT DISTINCT NVL(id,0) id, NVL(id,0)||'' - ''||operation||'' ''||options||'' (obj#:''||object_instance||'')'' step_details');
       put('                  FROM plan_table a');
       put('                 WHERE statement_id = ''SQLD360_ASH_DATA_HIST''');
       put('                   AND /*cost*/ bytes = '||i.plan_hash_value);
       put('                   AND NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'','',1,3)+1,INSTR(partition_stop,'','',1,4)-INSTR(partition_stop,'','',1,3)-1)),position) = '||j.inst_id||'');
       put('                   AND NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'','',1,4)+1,INSTR(partition_stop,'','',1,5)-INSTR(partition_stop,'','',1,4)-1)),cpu_cost) = '||j.session_id||'');
       put('                   AND NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'','',1,5)+1,INSTR(partition_stop,'','',1,6)-INSTR(partition_stop,'','',1,5)-1)),io_cost) = '||j.session_serial#||'');
       put('                   AND a.timestamp BETWEEN TO_DATE('''||j.min_sample_time||''', ''YYYYMMDDHH24MISS'') AND TO_DATE('''||j.max_sample_time||''', ''YYYYMMDDHH24MISS'') ');
       -- this is to differentiate data from partial exec of overlapping executions (case from my German friend)
       put(q'[                 AND NVL(partition_id, ]'||j.sql_exec_id||q'[) = ]'||j.sql_exec_id                                                                                                        ); 
       put(q'[                 AND NVL(distribution, TO_DATE(']'||j.sql_exec_start||q'[', 'YYYYMMDDHH24MISS')) = TO_DATE(']'||j.sql_exec_start||q'[', 'YYYYMMDDHH24MISS')                              ]');
       --
       put('                   AND remarks = ''&&sqld360_sqlid.''');
       put('               );');

       put('BEGIN');
       put(' :sql_text := ''');
       put('SELECT TO_CHAR(end_time, ''''YYYY-MM-DD HH24:MI:SS'''') end_time,');
       put('       null,');
       put('       plan_line_id,');
       put('       CASE WHEN rtr_category > .5 THEN category ELSE ''''Multiple'''' END,');
       put('       num_samples');
       put('  FROM (SELECT end_time, plan_line_id, category, num_samples, rtr_category, ROW_NUMBER() OVER (PARTITION BY end_time, plan_line_id ORDER BY rtr_category DESC) rn_category');
       put('          FROM (SELECT end_time, plan_line_id, category, SUM(num_samples) OVER (PARTITION BY end_time, plan_line_id) num_samples, RATIO_TO_REPORT(num_samples) OVER (PARTITION BY end_time, plan_line_id) rtr_category');
       put('                  FROM (SELECT timestamp end_time, NVL(id,0) plan_line_id, ');
       put('                               CASE WHEN other_tag = ''''CPU'''' THEN ''''CPU'''' WHEN other_tag LIKE ''''%I/O'''' THEN ''''I/O'''' WHEN other_tag = ''''Concurrency'''' THEN ''''Concurrency'''' WHEN other_tag = ''''Cluster'''' THEN ''''Cluster'''' ELSE ''''Other'''' END category,'); 
       put('                               COUNT(*) num_samples'); 
       put('                          FROM plan_table');
       put('                         WHERE statement_id = ''''SQLD360_ASH_DATA_HIST''''');
       put('                           AND /*cost*/ bytes =  '||i.plan_hash_value||'');
       put('                           AND NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'''','''',1,3)+1,INSTR(partition_stop,'''','''',1,4)-INSTR(partition_stop,'''','''',1,3)-1)),position) = '||j.inst_id||'');
       put('                           AND NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'''','''',1,4)+1,INSTR(partition_stop,'''','''',1,5)-INSTR(partition_stop,'''','''',1,4)-1)),cpu_cost) = '||j.session_id||'');
       put('                           AND NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'''','''',1,5)+1,INSTR(partition_stop,'''','''',1,6)-INSTR(partition_stop,'''','''',1,5)-1)),io_cost) = '||j.session_serial#||'');
       put('                           AND timestamp BETWEEN TO_DATE('''''||j.min_sample_time||''''', ''''YYYYMMDDHH24MISS'''') AND TO_DATE('''''||j.max_sample_time||''''', ''''YYYYMMDDHH24MISS'''') ');
       put('                           AND remarks = ''''&&sqld360_sqlid.'''''); 
       --put('                           AND partition_id IS NOT NULL');
       -- this is to differentiate data from partial exec of overlapping executions (case from my German friend)
       put(q'[                         AND NVL(partition_id, ]'||j.sql_exec_id||q'[) = ]'||j.sql_exec_id                                                                                                                             ); 
       put(q'[                         AND NVL(distribution, TO_DATE('']'||j.sql_exec_start||q'['', ''YYYYMMDDHH24MISS'')) = TO_DATE('']'||j.sql_exec_start||q'['', ''YYYYMMDDHH24MISS'')                                           ]');
       --
       put('                           AND ''''&&diagnostics_pack.'''' = ''''Y''''');
       put('                         GROUP BY timestamp, NVL(id,0), CASE WHEN other_tag = ''''CPU'''' THEN ''''CPU'''' WHEN other_tag LIKE ''''%I/O'''' THEN ''''I/O'''' WHEN other_tag = ''''Concurrency'''' THEN ''''Concurrency'''' WHEN other_tag = ''''Cluster'''' THEN ''''Cluster'''' ELSE ''''Other'''' END)');
       put('                 )');
       put('        )');
       put(' WHERE rn_category = 1');
       put(' ORDER BY end_time'); 
       put(''';');
       put('END;');
       put('/ ');
       put('@sql/sqld360_9a_pre_one.sql');

       put('----------------------------');

       put(q'[DEF title='Top Step/Event/Obj for SQL_EXEC_ID ]'||j.sql_exec_id||q'[ of PHV ]'||i.plan_hash_value||q'[' ]');
       put(q'[DEF main_table = 'DBA_HIST_ACTIVE_SESS_HISTORY'                                                         ]');
       put(q'[DEF skip_bch=''                                                                                         ]');
       put(q'[BEGIN                                                                                                   ]');
       put(q'[ :sql_text := '                                                                                         ]');
       put(q'[SELECT step_event,                                                                                                                               ]');
       put(q'[       num_samples,                                                                                                                              ]');
       put(q'[       &&wait_class_colors.&&wait_class_colors2.&&wait_class_colors3.&&wait_class_colors4. style,                                                ]');
       put(q'[       step_event||'' - Number of samples: ''||num_samples||'' (''||TRUNC(100*RATIO_TO_REPORT(num_samples) OVER (),2)||''% of DB Time)'' tooltip ]');
       put(q'[  FROM (SELECT data.step||'' ''||CASE WHEN data.obj# = 0 THEN ''UNDO''                                                                           ]');
       put(q'[                    ELSE (SELECT TRIM(''.'' FROM '' ''||o.owner||''.''||o.object_name||''.''||o.subobject_name) FROM dba_objects o WHERE o.object_id = data.obj# AND ROWNUM = 1) ]'); 
       put(q'[               END||'' / ''||data.event  step_event,                                                                                             ]');
       put(q'[               data.num_samples, data.wait_class                                                                                                 ]');
       put(q'[          FROM (SELECT id||'' - ''||operation||'' ''||options step, object_instance obj#, object_node event, other_tag wait_class,               ]'); 
       put(q'[                       count(*) num_samples                                                                                                      ]');
       put(q'[                  FROM plan_table                                                                                                                ]');
       put(q'[                 WHERE statement_id = ''SQLD360_ASH_DATA_HIST''                                                                                  ]');
       put(q'[                   AND /*cost*/ bytes =  ]'||i.plan_hash_value                                                                                               );
       put(q'[                   AND NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'','',1,3)+1,INSTR(partition_stop,'','',1,4)-INSTR(partition_stop,'','',1,3)-1)),position) = ]'||j.inst_id        );
       put(q'[                   AND NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'','',1,4)+1,INSTR(partition_stop,'','',1,5)-INSTR(partition_stop,'','',1,4)-1)),cpu_cost) = ]'||j.session_id     );
       put(q'[                   AND NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'','',1,5)+1,INSTR(partition_stop,'','',1,6)-INSTR(partition_stop,'','',1,5)-1)),io_cost) =  ]'||j.session_serial#);
       put(q'[                   AND timestamp BETWEEN TO_DATE('']'||j.min_sample_time||q'['', ''YYYYMMDDHH24MISS'') AND TO_DATE('']'||j.max_sample_time||q'['', ''YYYYMMDDHH24MISS'') ]');
       put(q'[                   AND remarks = ''&&sqld360_sqlid.''                                                                                            ]'); 
       -- this is to differentiate data from partial exec of overlapping executions (case from my German friend)
       put(q'[                   AND NVL(partition_id, ]'||j.sql_exec_id||q'[) = ]'||j.sql_exec_id                                                                                                                ); 
       put(q'[                   AND NVL(distribution, TO_DATE('']'||j.sql_exec_start||q'['', ''YYYYMMDDHH24MISS'')) = TO_DATE('']'||j.sql_exec_start||q'['', ''YYYYMMDDHH24MISS'')                             ]');
       --
       put(q'[                   AND ''&&diagnostics_pack.'' = ''Y''                                                                                           ]');
       put(q'[                 GROUP BY id||'' - ''||operation||'' ''||options, object_instance, object_node, other_tag                                        ]'); 
       put(q'[                 ORDER BY 5 DESC) data)                                                                                                          ]');
       put(q'[ ORDER BY 2 DESC                                                                                                                                 ]');
       put(''';');
       put('END;');
       put('/ ');
       put('@sql/sqld360_9a_pre_one.sql');        

       put('----------------------------');

       put('DEF title=''Top 15 Wait events timeline SQL_EXEC_ID '||j.sql_exec_id||' of PHV '||i.plan_hash_value||'''');
       put('DEF main_table = ''DBA_HIST_ACTIVE_SESS_HISTORY''');
       put('DEF skip_lch=''''');
       put('DEF chartype = ''AreaChart''');
       put('DEF stacked = ''isStacked: true,''');
       put('DEF abstract = ''AS (stacked) per top 15 wait events''');
       put('DEF vaxis = ''Active Sessions - AS (stacked)''');
       put('DEF foot = ''Data is not aggregated, extracted directly from DBA_HIST_ASH, Y-axis report Active Sessions at any time, not Average Active Sessions''');

       put('COL evt_01 NEW_V evt_01'); 
       put('COL evt_02 NEW_V evt_02'); 
       put('COL evt_03 NEW_V evt_03'); 
       put('COL evt_04 NEW_V evt_04'); 
       put('COL evt_05 NEW_V evt_05'); 
       put('COL evt_06 NEW_V evt_06'); 
       put('COL evt_07 NEW_V evt_07'); 
       put('COL evt_08 NEW_V evt_08'); 
       put('COL evt_09 NEW_V evt_09'); 
       put('COL evt_10 NEW_V evt_10'); 
       put('COL evt_11 NEW_V evt_11'); 
       put('COL evt_12 NEW_V evt_12'); 
       put('COL evt_13 NEW_V evt_13'); 
       put('COL evt_14 NEW_V evt_14'); 
       put('COL evt_15 NEW_V evt_15');
       put('COL tit_01 NEW_V tit_01'); 
       put('COL tit_02 NEW_V tit_02'); 
       put('COL tit_03 NEW_V tit_03'); 
       put('COL tit_04 NEW_V tit_04'); 
       put('COL tit_05 NEW_V tit_05'); 
       put('COL tit_06 NEW_V tit_06'); 
       put('COL tit_07 NEW_V tit_07'); 
       put('COL tit_08 NEW_V tit_08'); 
       put('COL tit_09 NEW_V tit_09'); 
       put('COL tit_10 NEW_V tit_10'); 
       put('COL tit_11 NEW_V tit_11'); 
       put('COL tit_12 NEW_V tit_12'); 
       put('COL tit_13 NEW_V tit_13'); 
       put('COL tit_14 NEW_V tit_14'); 
       put('COL tit_15 NEW_V tit_15'); 

       -- this is to determine series color
       put('COL series_01 NEW_V series_01'); 
       put('COL series_02 NEW_V series_02'); 
       put('COL series_03 NEW_V series_03'); 
       put('COL series_04 NEW_V series_04'); 
       put('COL series_05 NEW_V series_05'); 
       put('COL series_06 NEW_V series_06'); 
       put('COL series_07 NEW_V series_07'); 
       put('COL series_08 NEW_V series_08'); 
       put('COL series_09 NEW_V series_09'); 
       put('COL series_10 NEW_V series_10'); 
       put('COL series_11 NEW_V series_11'); 
       put('COL series_12 NEW_V series_12'); 
       put('COL series_13 NEW_V series_13'); 
       put('COL series_14 NEW_V series_14'); 
       put('COL series_15 NEW_V series_15');

       put('SELECT MAX(CASE WHEN ranking = 1  THEN cpu_or_event ELSE '''' END) evt_01,');
       put('       MAX(CASE WHEN ranking = 2  THEN cpu_or_event ELSE '''' END) evt_02,');              
       put('       MAX(CASE WHEN ranking = 3  THEN cpu_or_event ELSE '''' END) evt_03,'); 
       put('       MAX(CASE WHEN ranking = 4  THEN cpu_or_event ELSE '''' END) evt_04,'); 
       put('       MAX(CASE WHEN ranking = 5  THEN cpu_or_event ELSE '''' END) evt_05,'); 
       put('       MAX(CASE WHEN ranking = 6  THEN cpu_or_event ELSE '''' END) evt_06,'); 
       put('       MAX(CASE WHEN ranking = 7  THEN cpu_or_event ELSE '''' END) evt_07,'); 
       put('       MAX(CASE WHEN ranking = 8  THEN cpu_or_event ELSE '''' END) evt_08,'); 
       put('       MAX(CASE WHEN ranking = 9  THEN cpu_or_event ELSE '''' END) evt_09,'); 
       put('       MAX(CASE WHEN ranking = 10 THEN cpu_or_event ELSE '''' END) evt_10,');
       put('       MAX(CASE WHEN ranking = 11 THEN cpu_or_event ELSE '''' END) evt_11,');
       put('       MAX(CASE WHEN ranking = 12 THEN cpu_or_event ELSE '''' END) evt_12,');
       put('       MAX(CASE WHEN ranking = 13 THEN cpu_or_event ELSE '''' END) evt_13,');
       put('       MAX(CASE WHEN ranking = 14 THEN cpu_or_event ELSE '''' END) evt_14,');
       put('       MAX(CASE WHEN ranking = 15 THEN cpu_or_event ELSE '''' END) evt_15,');
       -- this is to determine series color
       put('       MAX(CASE WHEN ranking = 1  THEN &&wait_class_colors_s.&&wait_class_colors2_s.&&wait_class_colors3_s.&&wait_class_colors4_s. END) series_01,');
       put('       MAX(CASE WHEN ranking = 2  THEN &&wait_class_colors_s.&&wait_class_colors2_s.&&wait_class_colors3_s.&&wait_class_colors4_s. END) series_02,');              
       put('       MAX(CASE WHEN ranking = 3  THEN &&wait_class_colors_s.&&wait_class_colors2_s.&&wait_class_colors3_s.&&wait_class_colors4_s. END) series_03,'); 
       put('       MAX(CASE WHEN ranking = 4  THEN &&wait_class_colors_s.&&wait_class_colors2_s.&&wait_class_colors3_s.&&wait_class_colors4_s. END) series_04,'); 
       put('       MAX(CASE WHEN ranking = 5  THEN &&wait_class_colors_s.&&wait_class_colors2_s.&&wait_class_colors3_s.&&wait_class_colors4_s. END) series_05,'); 
       put('       MAX(CASE WHEN ranking = 6  THEN &&wait_class_colors_s.&&wait_class_colors2_s.&&wait_class_colors3_s.&&wait_class_colors4_s. END) series_06,'); 
       put('       MAX(CASE WHEN ranking = 7  THEN &&wait_class_colors_s.&&wait_class_colors2_s.&&wait_class_colors3_s.&&wait_class_colors4_s. END) series_07,'); 
       put('       MAX(CASE WHEN ranking = 8  THEN &&wait_class_colors_s.&&wait_class_colors2_s.&&wait_class_colors3_s.&&wait_class_colors4_s. END) series_08,'); 
       put('       MAX(CASE WHEN ranking = 9  THEN &&wait_class_colors_s.&&wait_class_colors2_s.&&wait_class_colors3_s.&&wait_class_colors4_s. END) series_09,'); 
       put('       MAX(CASE WHEN ranking = 10 THEN &&wait_class_colors_s.&&wait_class_colors2_s.&&wait_class_colors3_s.&&wait_class_colors4_s. END) series_10,');
       put('       MAX(CASE WHEN ranking = 11 THEN &&wait_class_colors_s.&&wait_class_colors2_s.&&wait_class_colors3_s.&&wait_class_colors4_s. END) series_11,');
       put('       MAX(CASE WHEN ranking = 12 THEN &&wait_class_colors_s.&&wait_class_colors2_s.&&wait_class_colors3_s.&&wait_class_colors4_s. END) series_12,');
       put('       MAX(CASE WHEN ranking = 13 THEN &&wait_class_colors_s.&&wait_class_colors2_s.&&wait_class_colors3_s.&&wait_class_colors4_s. END) series_13,');
       put('       MAX(CASE WHEN ranking = 14 THEN &&wait_class_colors_s.&&wait_class_colors2_s.&&wait_class_colors3_s.&&wait_class_colors4_s. END) series_14,');
       put('       MAX(CASE WHEN ranking = 15 THEN &&wait_class_colors_s.&&wait_class_colors2_s.&&wait_class_colors3_s.&&wait_class_colors4_s. END) series_15 ');
       --
       put('  FROM (SELECT 1 fake, object_node cpu_or_event, other_tag wait_class,');
       put('               ROW_NUMBER() OVER (ORDER BY COUNT(*) DESC) ranking');
       put('          FROM plan_table'); 
       put('         WHERE statement_id = ''SQLD360_ASH_DATA_HIST''');
       put('           AND /*cost*/ bytes = '||i.plan_hash_value);
       put('           AND NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'','',1,3)+1,INSTR(partition_stop,'','',1,4)-INSTR(partition_stop,'','',1,3)-1)),position) = '||j.inst_id||'');
       put('           AND NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'','',1,4)+1,INSTR(partition_stop,'','',1,5)-INSTR(partition_stop,'','',1,4)-1)),cpu_cost) = '||j.session_id||'');
       put('           AND NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'','',1,5)+1,INSTR(partition_stop,'','',1,6)-INSTR(partition_stop,'','',1,5)-1)),io_cost) = '||j.session_serial#||'');
       put('           AND timestamp BETWEEN TO_DATE('''||j.min_sample_time||''', ''YYYYMMDDHH24MISS'') AND TO_DATE('''||j.max_sample_time||''', ''YYYYMMDDHH24MISS'') ');
       put('           AND remarks = ''&&sqld360_sqlid.''');
       -- this is to differentiate data from partial exec of overlapping executions (case from my German friend)
       put(q'[         AND NVL(partition_id, ]'||j.sql_exec_id||q'[) = ]'||j.sql_exec_id                                                                                                                     ); 
       put(q'[         AND NVL(distribution, TO_DATE(']'||j.sql_exec_start||q'[', 'YYYYMMDDHH24MISS')) = TO_DATE(']'||j.sql_exec_start||q'[', 'YYYYMMDDHH24MISS')                                           ]');
       --
       put('         GROUP BY object_node, other_tag) ash,');
       put('       (SELECT 1 fake FROM dual) b'); -- this is in case there is no row in ASH
       put(' WHERE ash.fake(+) = b.fake');
       put('   AND ranking <= 15');
       put('/');    

       put('SET DEF @');

       put('SELECT SUBSTR(''@evt_01.'',1,27) tit_01,'); 
       put('       SUBSTR(''@evt_02.'',1,27) tit_02,');
       put('       SUBSTR(''@evt_03.'',1,27) tit_03,');
       put('       SUBSTR(''@evt_04.'',1,27) tit_04,');
       put('       SUBSTR(''@evt_05.'',1,27) tit_05,');
       put('       SUBSTR(''@evt_06.'',1,27) tit_06,');
       put('       SUBSTR(''@evt_07.'',1,27) tit_07,');
       put('       SUBSTR(''@evt_08.'',1,27) tit_08,');
       put('       SUBSTR(''@evt_09.'',1,27) tit_09,');
       put('       SUBSTR(''@evt_10.'',1,27) tit_10,'); 
       put('       SUBSTR(''@evt_11.'',1,27) tit_11,');
       put('       SUBSTR(''@evt_12.'',1,27) tit_12,');
       put('       SUBSTR(''@evt_13.'',1,27) tit_13,');
       put('       SUBSTR(''@evt_14.'',1,27) tit_14,');
       put('       SUBSTR(''@evt_15.'',1,27) tit_15');
       put('  FROM DUAL');
       put('/');

       put('COL e01 NOPRI');
       put('COL e02 NOPRI');
       put('COL e03 NOPRI');
       put('COL e04 NOPRI');
       put('COL e05 NOPRI');
       put('COL e06 NOPRI');
       put('COL e07 NOPRI');
       put('COL e08 NOPRI');
       put('COL e09 NOPRI');
       put('COL e10 NOPRI');
       put('COL e11 NOPRI');
       put('COL e12 NOPRI');
       put('COL e13 NOPRI');
       put('COL e14 NOPRI');
       put('COL e15 NOPRI');

       put('BEGIN');
       put(' :sql_text := ''');
       put('SELECT 0 snap_id,');
       put('       TO_CHAR(sample_time, ''''YYYY-MM-DD HH24:MI:SS'''') begin_time,'); 
       put('       TO_CHAR(sample_time, ''''YYYY-MM-DD HH24:MI:SS'''') end_time,');
       put('       NVL(num_sess_01,0) "e01@tit_01." ,');
       put('       NVL(num_sess_02,0) "e02@tit_02." ,');
       put('       NVL(num_sess_03,0) "e03@tit_03." ,');
       put('       NVL(num_sess_04,0) "e04@tit_04." ,');
       put('       NVL(num_sess_05,0) "e05@tit_05." ,');
       put('       NVL(num_sess_06,0) "e06@tit_06." ,');
       put('       NVL(num_sess_07,0) "e07@tit_07." ,');
       put('       NVL(num_sess_08,0) "e08@tit_08." ,');
       put('       NVL(num_sess_09,0) "e09@tit_09." ,');
       put('       NVL(num_sess_10,0) "e10@tit_10." ,');
       put('       NVL(num_sess_11,0) "e11@tit_11." ,');
       put('       NVL(num_sess_12,0) "e12@tit_12." ,');
       put('       NVL(num_sess_13,0) "e13@tit_13." ,');
       put('       NVL(num_sess_14,0) "e14@tit_14." ,');
       put('       NVL(num_sess_15,0) "e15@tit_15." ');
       put('  FROM (SELECT sample_time,');
       put('               MAX(CASE WHEN cpu_or_event  = ''''@evt_01.'''' THEN num_sess ELSE NULL END) num_sess_01,'); 
       put('               MAX(CASE WHEN cpu_or_event  = ''''@evt_02.'''' THEN num_sess ELSE NULL END) num_sess_02,'); 
       put('               MAX(CASE WHEN cpu_or_event  = ''''@evt_03.'''' THEN num_sess ELSE NULL END) num_sess_03,'); 
       put('               MAX(CASE WHEN cpu_or_event  = ''''@evt_04.'''' THEN num_sess ELSE NULL END) num_sess_04,'); 
       put('               MAX(CASE WHEN cpu_or_event  = ''''@evt_05.'''' THEN num_sess ELSE NULL END) num_sess_05,'); 
       put('               MAX(CASE WHEN cpu_or_event  = ''''@evt_06.'''' THEN num_sess ELSE NULL END) num_sess_06,'); 
       put('               MAX(CASE WHEN cpu_or_event  = ''''@evt_07.'''' THEN num_sess ELSE NULL END) num_sess_07,'); 
       put('               MAX(CASE WHEN cpu_or_event  = ''''@evt_08.'''' THEN num_sess ELSE NULL END) num_sess_08,'); 
       put('               MAX(CASE WHEN cpu_or_event  = ''''@evt_09.'''' THEN num_sess ELSE NULL END) num_sess_09,'); 
       put('               MAX(CASE WHEN cpu_or_event  = ''''@evt_10.'''' THEN num_sess ELSE NULL END) num_sess_10,'); 
       put('               MAX(CASE WHEN cpu_or_event  = ''''@evt_11.'''' THEN num_sess ELSE NULL END) num_sess_11,');  
       put('               MAX(CASE WHEN cpu_or_event  = ''''@evt_12.'''' THEN num_sess ELSE NULL END) num_sess_12,');  
       put('               MAX(CASE WHEN cpu_or_event  = ''''@evt_13.'''' THEN num_sess ELSE NULL END) num_sess_13,');  
       put('               MAX(CASE WHEN cpu_or_event  = ''''@evt_14.'''' THEN num_sess ELSE NULL END) num_sess_14,');  
       put('               MAX(CASE WHEN cpu_or_event  = ''''@evt_15.'''' THEN num_sess ELSE NULL END) num_sess_15'); 
       put('          FROM (SELECT timestamp sample_time,');
       put('                       object_node cpu_or_event,'); 
       put('                       count(*) num_sess');
       put('                  FROM plan_table');
       put('                 WHERE statement_id = ''''SQLD360_ASH_DATA_HIST''''');
       put('                   AND remarks = ''''&&sqld360_sqlid.''''');
       put('                   AND ''''&&diagnostics_pack.'''' = ''''Y''''');
       put('                   AND /*cost*/ bytes = '||i.plan_hash_value);
       put('                   AND NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'''','''',1,3)+1,INSTR(partition_stop,'''','''',1,4)-INSTR(partition_stop,'''','''',1,3)-1)),position) = '||j.inst_id||'');
       put('                   AND NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'''','''',1,4)+1,INSTR(partition_stop,'''','''',1,5)-INSTR(partition_stop,'''','''',1,4)-1)),cpu_cost) = '||j.session_id||'');
       put('                   AND NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'''','''',1,5)+1,INSTR(partition_stop,'''','''',1,6)-INSTR(partition_stop,'''','''',1,5)-1)),io_cost) = '||j.session_serial#||'');
       put('                   AND timestamp BETWEEN TO_DATE('''''||j.min_sample_time||''''', ''''YYYYMMDDHH24MISS'''') AND TO_DATE('''''||j.max_sample_time||''''', ''''YYYYMMDDHH24MISS'''') ');
       -- this is to differentiate data from partial exec of overlapping executions (case from my German friend)
       put(q'[                 AND NVL(partition_id, ]'||j.sql_exec_id||q'[) = ]'||j.sql_exec_id                                                                                                                             ); 
       put(q'[                 AND NVL(distribution, TO_DATE('']'||j.sql_exec_start||q'['', ''YYYYMMDDHH24MISS'')) = TO_DATE('']'||j.sql_exec_start||q'['', ''YYYYMMDDHH24MISS'')                                           ]');
       --
       put('                   AND object_node IN (''''@evt_01.'''',''''@evt_02.'''',''''@evt_03.'''',''''@evt_04.'''',''''@evt_05.'''',''''@evt_06.'''',');
       put('                                       ''''@evt_07.'''',''''@evt_08.'''',''''@evt_09.'''',''''@evt_10.'''',''''@evt_11.'''',''''@evt_12.'''',');
       put('                                       ''''@evt_13.'''',''''@evt_14.'''',''''@evt_15.'''')');
       put('                 GROUP BY timestamp, object_node)');
       put('         GROUP BY sample_time)');
       put(' ORDER BY 3 ');
       put(''';');
       put('END;');
       put('/ ');

       put('SET DEF &');
       put('@sql/sqld360_9a_pre_one.sql');

       put('COL evt01_ PRI');
       put('COL evt02_ PRI');
       put('COL evt03_ PRI');
       put('COL evt04_ PRI');
       put('COL evt05_ PRI');
       put('COL evt06_ PRI');
       put('COL evt07_ PRI');
       put('COL evt08_ PRI');
       put('COL evt09_ PRI');
       put('COL evt10_ PRI');
       put('COL evt11_ PRI');
       put('COL evt12_ PRI');
       put('COL evt13_ PRI');
       put('COL evt14_ PRI');
       put('COL evt15_ PRI');     

       put('UNDEF evt_01'); 
       put('UNDEF evt_02'); 
       put('UNDEF evt_03'); 
       put('UNDEF evt_04'); 
       put('UNDEF evt_05'); 
       put('UNDEF evt_06'); 
       put('UNDEF evt_07'); 
       put('UNDEF evt_08'); 
       put('UNDEF evt_09'); 
       put('UNDEF evt_10'); 
       put('UNDEF evt_11'); 
       put('UNDEF evt_12'); 
       put('UNDEF evt_13'); 
       put('UNDEF evt_14'); 
       put('UNDEF evt_15'); 

       -- to play with colors
       put('DEF series_01 = '''' '); 
       put('DEF series_02 = '''' '); 
       put('DEF series_03 = '''' '); 
       put('DEF series_04 = '''' '); 
       put('DEF series_05 = '''' '); 
       put('DEF series_06 = '''' '); 
       put('DEF series_07 = '''' '); 
       put('DEF series_08 = '''' '); 
       put('DEF series_09 = '''' '); 
       put('DEF series_10 = '''' '); 
       put('DEF series_11 = '''' '); 
       put('DEF series_12 = '''' '); 
       put('DEF series_13 = '''' '); 
       put('DEF series_14 = '''' '); 
       put('DEF series_15 = '''' ');

       put('----------------------------');       

       put('DEF title=''DB Time by PX process for SQL_EXEC_ID '||j.sql_exec_id||' of PHV '||i.plan_hash_value||'''');
       put('DEF main_table = ''DBA_HIST_ACTIVE_SESS_HISTORY''');
       put('DEF skip_bch=''''');
       --put('DEF slices = ''64''');
       put('BEGIN');
       put(' :sql_text := ''');
       put('SELECT data.qcpx_process,');
       put('       data.num_samples,');
       put('       NULL style,');
       put('       data.qcpx_process||'''' - Number of samples: ''''||data.num_samples||'''' (''''||TRUNC(100*RATIO_TO_REPORT(data.num_samples) OVER (),2)||''''%)'''' tooltip ');
       put('  FROM (SELECT NVL2(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'''','''',1,3)+1,INSTR(partition_stop,'''','''',1,4)-INSTR(partition_stop,'''','''',1,3)-1)), ''''PX Proc - '''', ''''QC - '''')||position||''''.''''||cpu_cost||''''.''''||io_cost  qcpx_process, ');   
       put('               count(*) num_samples');
       put('          FROM plan_table');
       put('         WHERE statement_id = ''''SQLD360_ASH_DATA_HIST''''');
       put('           AND /*cost*/ bytes =  '||i.plan_hash_value||'');
       put('           AND NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'''','''',1,3)+1,INSTR(partition_stop,'''','''',1,4)-INSTR(partition_stop,'''','''',1,3)-1)),position) = '||j.inst_id||'');
       put('           AND NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'''','''',1,4)+1,INSTR(partition_stop,'''','''',1,5)-INSTR(partition_stop,'''','''',1,4)-1)),cpu_cost) = '||j.session_id||'');
       put('           AND NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'''','''',1,5)+1,INSTR(partition_stop,'''','''',1,6)-INSTR(partition_stop,'''','''',1,5)-1)),io_cost) = '||j.session_serial#||'');
       put('           AND timestamp BETWEEN TO_DATE('''''||j.min_sample_time||''''', ''''YYYYMMDDHH24MISS'''') AND TO_DATE('''''||j.max_sample_time||''''', ''''YYYYMMDDHH24MISS'''') ');
       put('           AND remarks = ''''&&sqld360_sqlid.''''');
       -- this is to differentiate data from partial exec of overlapping executions (case from my German friend)
       put(q'[         AND NVL(partition_id, ]'||j.sql_exec_id||q'[) = ]'||j.sql_exec_id                                                                                                                             ); 
       put(q'[         AND NVL(distribution, TO_DATE('']'||j.sql_exec_start||q'['', ''YYYYMMDDHH24MISS'')) = TO_DATE('']'||j.sql_exec_start||q'['', ''YYYYMMDDHH24MISS'')                                           ]');
       -- 
       put('           AND ''''&&diagnostics_pack.'''' = ''''Y''''');
       put('         GROUP BY NVL2(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'''','''',1,3)+1,INSTR(partition_stop,'''','''',1,4)-INSTR(partition_stop,'''','''',1,3)-1)), ''''PX Proc - '''', ''''QC - '''')||position||''''.''''||cpu_cost||''''.''''||io_cost   ');  
       put('         ORDER BY 2 DESC) data');
       --put(' WHERE rownum <= 64');
       put(' ORDER BY 2 DESC');
       put(''';');
       put('END;');
       put('/ ');
       put('@sql/sqld360_9a_pre_one.sql'); 

       put('----------------------------');

       put('DEF title=''PGA and TEMP usage for SQL_EXEC_ID '||j.sql_exec_id||' of PHV '||i.plan_hash_value||'''');
       put('DEF main_table = ''DBA_HIST_ACTIVE_SESS_HISTORY''');
       put('DEF skip_lch=''''');
       put('DEF chartype = ''LineChart''');
       put('DEF stacked = ''''');
       put('DEF vaxis = ''Bytes''');
       put('DEF tit_01 = ''PGA Usage''');
       put('DEF tit_02 = ''TEMP Usage''');
       put('DEF tit_03 = ''''');
       put('DEF tit_04 = ''''');
       put('DEF tit_05 = ''''');
       put('DEF tit_06 = ''''');
       put('DEF tit_07 = ''''');
       put('DEF tit_08 = ''''');
       put('DEF tit_09 = ''''');
       put('DEF tit_10 = ''''');
       put('DEF tit_11 = ''''');
       put('DEF tit_12 = ''''');
       put('DEF tit_13 = ''''');
       put('DEF tit_14 = ''''');
       put('DEF tit_15 = ''''');
       put('DEF foot = ''Data is not aggregated, extracted directly from DBA_HIST_ASH''');
       put('BEGIN');
       put(' :sql_text := ''');
       put('SELECT 0 snap_id,');
       put('       TO_CHAR(end_time, ''''YYYY-MM-DD HH24:MI:SS'''') begin_time,'); 
       put('       TO_CHAR(end_time, ''''YYYY-MM-DD HH24:MI:SS'''') end_time,');
       put('       pga_allocated,');
       put('       temp_space_allocated,');
       put('       0 dummy_03,');
       put('       0 dummy_04,');
       put('       0 dummy_05,');
       put('       0 dummy_06,');
       put('       0 dummy_07,');
       put('       0 dummy_08,');
       put('       0 dummy_09,');
       put('       0 dummy_10,');
       put('       0 dummy_11,');
       put('       0 dummy_12,');
       put('       0 dummy_13,');
       put('       0 dummy_14,');
       put('       0 dummy_15');
       put('  FROM (SELECT timestamp end_time,');
       put('               SUM(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'''','''',1,11)+1,INSTR(partition_stop,'''','''',1,12)-INSTR(partition_stop,'''','''',1,11)-1))) pga_allocated,'); 
       put('               SUM(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'''','''',1,12)+1,INSTR(partition_stop,'''','''',1,13)-INSTR(partition_stop,'''','''',1,12)-1))) temp_space_allocated'); 
       put('          FROM plan_table');
       put('         WHERE statement_id = ''''SQLD360_ASH_DATA_HIST''''');
       put('           AND /*cost*/ bytes =  '||i.plan_hash_value||'');
       put('           AND NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'''','''',1,3)+1,INSTR(partition_stop,'''','''',1,4)-INSTR(partition_stop,'''','''',1,3)-1)),position) = '||j.inst_id||'');
       put('           AND NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'''','''',1,4)+1,INSTR(partition_stop,'''','''',1,5)-INSTR(partition_stop,'''','''',1,4)-1)),cpu_cost) = '||j.session_id||'');
       put('           AND NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'''','''',1,5)+1,INSTR(partition_stop,'''','''',1,6)-INSTR(partition_stop,'''','''',1,5)-1)),io_cost) = '||j.session_serial#||'');
       put('           AND timestamp BETWEEN TO_DATE('''''||j.min_sample_time||''''', ''''YYYYMMDDHH24MISS'''') AND TO_DATE('''''||j.max_sample_time||''''', ''''YYYYMMDDHH24MISS'''') ');
       put('           AND remarks = ''''&&sqld360_sqlid.'''''); 
       -- this is to differentiate data from partial exec of overlapping executions (case from my German friend)
       put(q'[         AND NVL(partition_id, ]'||j.sql_exec_id||q'[) = ]'||j.sql_exec_id                                                                                                                             ); 
       put(q'[         AND NVL(distribution, TO_DATE('']'||j.sql_exec_start||q'['', ''YYYYMMDDHH24MISS'')) = TO_DATE('']'||j.sql_exec_start||q'['', ''YYYYMMDDHH24MISS'')                                           ]');
       --
       --put('           AND partition_id IS NOT NULL');
       put('           AND ''''&&diagnostics_pack.'''' = ''''Y''''');
       put('         GROUP BY timestamp)');
       put(' ORDER BY 3');
       put(''';');
       put('END;');
       put('/ ');
       put('@sql/sqld360_9a_pre_one.sql');   

       put('----------------------------');           

       put('DEF title=''Read and Write I/O requests for SQL_EXEC_ID '||j.sql_exec_id||' of PHV '||i.plan_hash_value||'''');
       put('DEF main_table = ''DBA_HIST_ACTIVE_SESS_HISTORY''');
       put('DEF skip_lch=''''');
       put('DEF chartype = ''LineChart''');
       put('DEF stacked = ''''');
       put('DEF vaxis = ''Number of I/O requests''');
       put('DEF tit_01 = ''Read I/O Request''');
       put('DEF tit_02 = ''Write I/O Request''');
       put('DEF tit_03 = ''''');
       put('DEF tit_04 = ''''');
       put('DEF tit_05 = ''''');
       put('DEF tit_06 = ''''');
       put('DEF tit_07 = ''''');
       put('DEF tit_08 = ''''');
       put('DEF tit_09 = ''''');
       put('DEF tit_10 = ''''');
       put('DEF tit_11 = ''''');
       put('DEF tit_12 = ''''');
       put('DEF tit_13 = ''''');
       put('DEF tit_14 = ''''');
       put('DEF tit_15 = ''''');
       put('DEF foot = ''Data is not aggregated, extracted directly from DBA_HIST_ASH''');
       put('BEGIN');
       put(' :sql_text := ''');
       put('SELECT 0 snap_id,');
       put('       TO_CHAR(end_time, ''''YYYY-MM-DD HH24:MI:SS'''') begin_time,'); 
       put('       TO_CHAR(end_time, ''''YYYY-MM-DD HH24:MI:SS'''') end_time,');
       put('       read_io_requests,');
       put('       write_io_requests,');
       put('       0 dummy_03,');
       put('       0 dummy_04,');
       put('       0 dummy_05,');
       put('       0 dummy_06,');
       put('       0 dummy_07,');
       put('       0 dummy_08,');
       put('       0 dummy_09,');
       put('       0 dummy_10,');
       put('       0 dummy_11,');
       put('       0 dummy_12,');
       put('       0 dummy_13,');
       put('       0 dummy_14,');
       put('       0 dummy_15');
       put('  FROM (SELECT timestamp end_time,');
       put('               SUM(NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'''','''',1,14)+1,INSTR(partition_stop,'''','''',1,15)-INSTR(partition_stop,'''','''',1,14)-1)),0)/ ');
       put('                   ROUND(GREATEST(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'''','''',1,13)+1,INSTR(partition_stop,'''','''',1,14)-INSTR(partition_stop,'''','''',1,13)-1))/1e6,1))) read_io_requests,'); 
       put('               SUM(NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'''','''',1,15)+1,INSTR(partition_stop,'''','''',1,16)-INSTR(partition_stop,'''','''',1,15)-1)),0)/ ');
       put('                   ROUND(GREATEST(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'''','''',1,13)+1,INSTR(partition_stop,'''','''',1,14)-INSTR(partition_stop,'''','''',1,13)-1))/1e6,1))) write_io_requests'); 
       put('          FROM plan_table');
       put('         WHERE statement_id = ''''SQLD360_ASH_DATA_HIST''''');
       put('           AND /*cost*/ bytes =  '||i.plan_hash_value||'');
       put('           AND NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'''','''',1,3)+1,INSTR(partition_stop,'''','''',1,4)-INSTR(partition_stop,'''','''',1,3)-1)),position) = '||j.inst_id||'');
       put('           AND NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'''','''',1,4)+1,INSTR(partition_stop,'''','''',1,5)-INSTR(partition_stop,'''','''',1,4)-1)),cpu_cost) = '||j.session_id||'');
       put('           AND NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'''','''',1,5)+1,INSTR(partition_stop,'''','''',1,6)-INSTR(partition_stop,'''','''',1,5)-1)),io_cost) = '||j.session_serial#||'');
       put('           AND timestamp BETWEEN TO_DATE('''''||j.min_sample_time||''''', ''''YYYYMMDDHH24MISS'''') AND TO_DATE('''''||j.max_sample_time||''''', ''''YYYYMMDDHH24MISS'''') ');
       put('           AND remarks = ''''&&sqld360_sqlid.'''''); 
       -- this is to differentiate data from partial exec of overlapping executions (case from my German friend)
       put(q'[         AND NVL(partition_id, ]'||j.sql_exec_id||q'[) = ]'||j.sql_exec_id                                                                                                                             ); 
       put(q'[         AND NVL(distribution, TO_DATE('']'||j.sql_exec_start||q'['', ''YYYYMMDDHH24MISS'')) = TO_DATE('']'||j.sql_exec_start||q'['', ''YYYYMMDDHH24MISS'')                                           ]');
       --
       --put('           AND partition_id IS NOT NULL');
       put('           AND ''''&&diagnostics_pack.'''' = ''''Y''''');
       put('         GROUP BY timestamp)');
       put(' ORDER BY 3');
       put(''';');
       put('END;');
       put('/ ');
       put('@sql/sqld360_9a_pre_one.sql');  

       put('----------------------------');       

       put('DEF title=''Read, Write and Interconnect I/O bytes for SQL_EXEC_ID '||j.sql_exec_id||' of PHV '||i.plan_hash_value||'''');
       put('DEF main_table = ''DBA_HIST_ACTIVE_SESS_HISTORY''');
       put('DEF skip_lch=''''');
       put('DEF chartype = ''LineChart''');
       put('DEF stacked = ''''');
       put('DEF vaxis = ''I/O bytes''');
       put('DEF tit_01 = ''Read I/O Bytes''');
       put('DEF tit_02 = ''Write I/O Bytes''');
       put('DEF tit_03 = ''Interconnect I/O Bytes''');
       put('DEF tit_04 = ''''');
       put('DEF tit_05 = ''''');
       put('DEF tit_06 = ''''');
       put('DEF tit_07 = ''''');
       put('DEF tit_08 = ''''');
       put('DEF tit_09 = ''''');
       put('DEF tit_10 = ''''');
       put('DEF tit_11 = ''''');
       put('DEF tit_12 = ''''');
       put('DEF tit_13 = ''''');
       put('DEF tit_14 = ''''');
       put('DEF tit_15 = ''''');
       put('DEF foot = ''Data is not aggregated, extracted directly from DBA_HIST_ASH''');
       put('BEGIN');
       put(' :sql_text := ''');
       put('SELECT 0 snap_id,');
       put('       TO_CHAR(end_time, ''''YYYY-MM-DD HH24:MI:SS'''') begin_time,'); 
       put('       TO_CHAR(end_time, ''''YYYY-MM-DD HH24:MI:SS'''') end_time,');
       put('       read_io_bytes,');
       put('       write_io_bytes,');
       put('       interconnect_io_bytes,');
       put('       0 dummy_04,');
       put('       0 dummy_05,');
       put('       0 dummy_06,');
       put('       0 dummy_07,');
       put('       0 dummy_08,');
       put('       0 dummy_09,');
       put('       0 dummy_10,');
       put('       0 dummy_11,');
       put('       0 dummy_12,');
       put('       0 dummy_13,');
       put('       0 dummy_14,');
       put('       0 dummy_15');
       put('  FROM (SELECT timestamp end_time,');
       put('               SUM(NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'''','''',1,16)+1,INSTR(partition_stop,'''','''',1,17)-INSTR(partition_stop,'''','''',1,16)-1)),0)/ ');
       put('                   ROUND(GREATEST(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'''','''',1,13)+1,INSTR(partition_stop,'''','''',1,14)-INSTR(partition_stop,'''','''',1,13)-1))/1e6,1))) read_io_bytes,'); 
       put('               SUM(NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'''','''',1,17)+1,INSTR(partition_stop,'''','''',1,18)-INSTR(partition_stop,'''','''',1,17)-1)),0)/ ');
       put('                   ROUND(GREATEST(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'''','''',1,13)+1,INSTR(partition_stop,'''','''',1,14)-INSTR(partition_stop,'''','''',1,13)-1))/1e6,1))) write_io_bytes,'); 
       put('               SUM(NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'''','''',1,18)+1,INSTR(partition_stop,'''','''',1,19)-INSTR(partition_stop,'''','''',1,18)-1)),0)/ ');
       put('                   ROUND(GREATEST(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'''','''',1,13)+1,INSTR(partition_stop,'''','''',1,14)-INSTR(partition_stop,'''','''',1,13)-1))/1e6,1))) interconnect_io_bytes'); 
       put('          FROM plan_table');
       put('         WHERE statement_id = ''''SQLD360_ASH_DATA_HIST''''');
       put('           AND /*cost*/ bytes =  '||i.plan_hash_value||'');
       put('           AND NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'''','''',1,3)+1,INSTR(partition_stop,'''','''',1,4)-INSTR(partition_stop,'''','''',1,3)-1)),position) = '||j.inst_id||'');
       put('           AND NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'''','''',1,4)+1,INSTR(partition_stop,'''','''',1,5)-INSTR(partition_stop,'''','''',1,4)-1)),cpu_cost) = '||j.session_id||'');
       put('           AND NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'''','''',1,5)+1,INSTR(partition_stop,'''','''',1,6)-INSTR(partition_stop,'''','''',1,5)-1)),io_cost) = '||j.session_serial#||'');
       put('           AND timestamp BETWEEN TO_DATE('''''||j.min_sample_time||''''', ''''YYYYMMDDHH24MISS'''') AND TO_DATE('''''||j.max_sample_time||''''', ''''YYYYMMDDHH24MISS'''') ');
       put('           AND remarks = ''''&&sqld360_sqlid.'''''); 
       --put('           AND partition_id IS NOT NULL');
       -- this is to differentiate data from partial exec of overlapping executions (case from my German friend)
       put(q'[         AND NVL(partition_id, ]'||j.sql_exec_id||q'[) = ]'||j.sql_exec_id                                                                                                                             ); 
       put(q'[         AND NVL(distribution, TO_DATE('']'||j.sql_exec_start||q'['', ''YYYYMMDDHH24MISS'')) = TO_DATE('']'||j.sql_exec_start||q'['', ''YYYYMMDDHH24MISS'')                                           ]');
       --
       put('           AND ''''&&diagnostics_pack.'''' = ''''Y''''');
       put('         GROUP BY timestamp)');
       put(' ORDER BY 3');
       put(''';');
       put('END;');
       put('/ ');
       put('@sql/sqld360_9a_pre_one.sql');

       put('----------------------------');      

       put('DEF title = ''Raw Data for SQL_EXEC_ID '||j.sql_exec_id||' of PHV '||i.plan_hash_value||'''');
       put('DEF main_table = ''DBA_HIST_ACTIVE_SESS_HISTORY''');
       put('BEGIN ');
       put('  :sql_text := ''');
       put('SELECT /*+ &&top_level_hints. */ ');
       put('       statement_id     source,  ');
       put('       search_columns   dbid,    ');
       put('       cardinality      snap_id, ');
       put('       position         instance_number,  ');
       put('       parent_id        sample_id,        ');
       put('       TO_CHAR(timestamp, ''''YYYY-MM-DD/HH24:MI:SS'''')        sample_time, ');
       put('       partition_id     sql_exec_id, ');
       put('       TO_CHAR(TO_DATE(distribution,''''YYYYMMDDHH24MISS''''), ''''YYYY-MM-DD/HH24:MI:SS'''')  sql_exec_start, ');
       put('       cpu_cost         session_id,        ');
       put('       io_cost          session_serial#,   ');
       put('       TO_NUMBER(SUBSTR(partition_start,INSTR(partition_start,'''','''',1,13)+1))            user_id,           ');
       put('       remarks          sql_id,            ');
       put('       cost             plan_hash_value,   ');
       put('       TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'''','''',1,19)+1)) sql_full_plan_hash_value, ');
       put('       id               sql_plan_line_id,  ');
       put('       operation        sql_plan_operation,');  
       put('       options          sql_plan_options,  '); 
       put('       object_node      cpu_or_event,      ');
       put('       other_tag        wait_class,        ');
       put('       TO_NUMBER(SUBSTR(partition_start,1,INSTR(partition_start,'''','''',1,1)-1)) seq#, ');
       put('       SUBSTR(partition_start,INSTR(partition_start,'''','''',1,1)+1,INSTR(partition_start,'''','''',1,2)-INSTR(partition_start,'''','''',1,1)-1) p1text, ');  
       put('       TO_NUMBER(SUBSTR(partition_start,INSTR(partition_start,'''','''',1,2)+1,INSTR(partition_start,'''','''',1,3)-INSTR(partition_start,'''','''',1,2)-1)) p1, ');
       put('       SUBSTR(partition_start,INSTR(partition_start,'''','''',1,3)+1,INSTR(partition_start,'''','''',1,4)-INSTR(partition_start,'''','''',1,3)-1) p2text,  ');
       put('       TO_NUMBER(SUBSTR(partition_start,INSTR(partition_start,'''','''',1,4)+1,INSTR(partition_start,'''','''',1,5)-INSTR(partition_start,'''','''',1,4)-1)) p2, ');
       put('       SUBSTR(partition_start,INSTR(partition_start,'''','''',1,5)+1,INSTR(partition_start,'''','''',1,6)-INSTR(partition_start,'''','''',1,5)-1) p3text,  ');
       put('       TO_NUMBER(SUBSTR(partition_start,INSTR(partition_start,'''','''',1,6)+1,INSTR(partition_start,'''','''',1,7)-INSTR(partition_start,'''','''',1,6)-1)) p3, ');
       put('       object_instance  current_obj#, ');
       put('       TO_NUMBER(SUBSTR(partition_start,INSTR(partition_start,'''','''',1,7)+1,INSTR(partition_start,'''','''',1,8)-INSTR(partition_start,'''','''',1,7)-1)) current_file#,  ');
       put('       TO_NUMBER(SUBSTR(partition_start,INSTR(partition_start,'''','''',1,8)+1,INSTR(partition_start,'''','''',1,9)-INSTR(partition_start,'''','''',1,8)-1)) current_block#, ');
       put('       TO_NUMBER(SUBSTR(partition_start,INSTR(partition_start,'''','''',1,9)+1,INSTR(partition_start,'''','''',1,10)-INSTR(partition_start,'''','''',1,9)-1)) current_row#,  ');
       put('       SUBSTR(partition_stop,1,INSTR(partition_stop,'''','''',1,1)-1) in_parse, ');
       put('       SUBSTR(partition_stop,INSTR(partition_stop,'''','''',1,1)+1,INSTR(partition_stop,'''','''',1,2)-INSTR(partition_stop,'''','''',1,1)-1) in_hard_parse, ');
       put('       SUBSTR(partition_stop,INSTR(partition_stop,'''','''',1,2)+1,INSTR(partition_stop,'''','''',1,3)-INSTR(partition_stop,'''','''',1,2)-1) in_sql_execution, ');
       put('       TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'''','''',1,3)+1,INSTR(partition_stop,'''','''',1,4)-INSTR(partition_stop,'''','''',1,3)-1)) qc_instance_id, ');
       put('       TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'''','''',1,4)+1,INSTR(partition_stop,'''','''',1,5)-INSTR(partition_stop,'''','''',1,4)-1)) qc_session_id,  ');
       put('       TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'''','''',1,5)+1,INSTR(partition_stop,'''','''',1,6)-INSTR(partition_stop,'''','''',1,5)-1)) qc_session_serial#, ');
       put('       SUBSTR(partition_stop,INSTR(partition_stop,'''','''',1,6)+1,INSTR(partition_stop,'''','''',1,7)-INSTR(partition_stop,'''','''',1,6)-1) blocking_session_status, ');
       put('       TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'''','''',1,7)+1,INSTR(partition_stop,'''','''',1,8)-INSTR(partition_stop,'''','''',1,7)-1)) blocking_session, ');
       put('       TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'''','''',1,8)+1,INSTR(partition_stop,'''','''',1,9)-INSTR(partition_stop,'''','''',1,8)-1)) blocking_session_serial#, ');
       put('       TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'''','''',1,9)+1,INSTR(partition_stop,'''','''',1,10)-INSTR(partition_stop,'''','''',1,9)-1)) blocking_inst_id, ');
       put('       TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'''','''',1,10)+1,INSTR(partition_stop,'''','''',1,11)-INSTR(partition_stop,'''','''',1,10)-1)) px_flags, ');
       put('       TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'''','''',1,11)+1,INSTR(partition_stop,'''','''',1,12)-INSTR(partition_stop,'''','''',1,11)-1)) pga_allocated, ');
       put('       TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'''','''',1,12)+1,INSTR(partition_stop,'''','''',1,13)-INSTR(partition_stop,'''','''',1,12)-1)) temp_space_allocated, ');
       put('       TO_NUMBER(SUBSTR(partition_start,INSTR(partition_start,'''','''',1,10)+1,INSTR(partition_start,'''','''',1,11)-INSTR(partition_start,'''','''',1,10)-1)) tm_delta_time, ');
       put('       TO_NUMBER(SUBSTR(partition_start,INSTR(partition_start,'''','''',1,11)+1,INSTR(partition_start,'''','''',1,12)-INSTR(partition_start,'''','''',1,11)-1)) tm_delta_cpu_time, ');
       put('       TO_NUMBER(SUBSTR(partition_start,INSTR(partition_start,'''','''',1,12)+1,INSTR(partition_start,'''','''',1,13)-INSTR(partition_start,'''','''',1,12)-1)) tm_delta_db_time, ');
       put('       TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'''','''',1,13)+1,INSTR(partition_stop,'''','''',1,14)-INSTR(partition_stop,'''','''',1,13)-1)) delta_time, ');
       put('       TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'''','''',1,14)+1,INSTR(partition_stop,'''','''',1,15)-INSTR(partition_stop,'''','''',1,14)-1)) delta_read_io_requests, ');
       put('       TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'''','''',1,15)+1,INSTR(partition_stop,'''','''',1,16)-INSTR(partition_stop,'''','''',1,15)-1)) delta_write_io_requests, ');
       put('       TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'''','''',1,16)+1,INSTR(partition_stop,'''','''',1,17)-INSTR(partition_stop,'''','''',1,16)-1)) delta_read_io_bytes, ');
       put('       TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'''','''',1,17)+1,INSTR(partition_stop,'''','''',1,18)-INSTR(partition_stop,'''','''',1,17)-1)) delta_write_io_bytes, ');
       put('       TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'''','''',1,18)+1,INSTR(partition_stop,'''','''',1,19)-INSTR(partition_stop,'''','''',1,18)-1)) delta_interconnect_io_bytes ');
       put('  FROM plan_table '); 
       put(' WHERE remarks = ''''&&sqld360_sqlid.'''' ');
       put('   AND statement_id = ''''SQLD360_ASH_DATA_HIST'''' ');
       -- The comment on the PHV is intentional, the goal is to extract even rows for a different PHV (adaptive, not resolved yet) for the specific execution       
       put('   AND /*cost*/ bytes =  '||i.plan_hash_value||'');
       put('   AND NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'''','''',1,3)+1,INSTR(partition_stop,'''','''',1,4)-INSTR(partition_stop,'''','''',1,3)-1)),position) = '||j.inst_id||'');
       put('   AND NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'''','''',1,4)+1,INSTR(partition_stop,'''','''',1,5)-INSTR(partition_stop,'''','''',1,4)-1)),cpu_cost) = '||j.session_id||'');
       put('   AND NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'''','''',1,5)+1,INSTR(partition_stop,'''','''',1,6)-INSTR(partition_stop,'''','''',1,5)-1)),io_cost) = '||j.session_serial#||'');
       put('   AND timestamp BETWEEN TO_DATE('''''||j.min_sample_time||''''', ''''YYYYMMDDHH24MISS'''') AND TO_DATE('''''||j.max_sample_time||''''', ''''YYYYMMDDHH24MISS'''') ');
       -- this is to differentiate data from partial exec of overlapping executions (case from my German friend)
       put(q'[ AND NVL(partition_id, ]'||j.sql_exec_id||q'[) = ]'||j.sql_exec_id                                                                                                                             ); 
       put(q'[ AND NVL(distribution, TO_DATE('']'||j.sql_exec_start||q'['', ''YYYYMMDDHH24MISS'')) = TO_DATE('']'||j.sql_exec_start||q'['', ''YYYYMMDDHH24MISS'')                                           ]');
       --
       put('   AND ''''&&diagnostics_pack.'''' = ''''Y''''');
       put(' ORDER BY sample_time,instance_number ');
       put(''';');
       put('END;');
       put('/');
       put('@&&sqld360_skip_rawash.sql/sqld360_9a_pre_one.sql');

       put('----------------------------');       

       put('SPO &&one_spool_filename..html APP;');
       put('PRO <br>');
       put('SPO OFF');
      
    END LOOP;

    -- end of v1601
    put('PRO </ol>');
    put('SPO &&sqld360_main_report..html APP;');
    put('PRO </td>');
  END LOOP;
END;
/
SPO &&sqld360_main_report..html APP;
@sqld360_plans_analysis_&&sqld360_sqlid._driver.sql

SPO &&sqld360_main_report..html APP;
PRO </tr></table>
@@sqld360_0e_html_footer.sql
SPO OFF
SET PAGES 50000

HOS zip -mq &&sqld360_main_filename._&&sqld360_file_time. &&sqld360_main_report..html
HOS zip -jmq 99999_sqld360_&&sqld360_sqlid._drivers sqld360_plans_analysis_&&sqld360_sqlid._driver.sql

DEF sqld360_main_report = &&sqld360_main_report_bck.