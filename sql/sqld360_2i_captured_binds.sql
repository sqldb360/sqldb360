SPO &&one_spool_filename..html APP;
PRO </head>
@sql/sqld360_0d_html_header.sql
PRO <body>
PRO <h1><em>&&sqld360_conf_tool_page.SQLd360</a></em> &&sqld360_vYYNN.: SQL 360-degree view - &&section_id.. Captured Binds Page &&sqld360_conf_all_pages_logo.</h1>
PRO
PRO <pre>
PRO sqlid:&&sqld360_sqlid. dbname:&&database_name_short. version:&&db_version. host:&&host_hash. license:&&license_pack. days:&&history_days. today:&&sqld360_time_stamp.
PRO </pre>
PRO

PRO <table><tr class="main">

SET SERVEROUT ON ECHO OFF FEEDBACK OFF TIMING OFF 
SET SERVEROUT ON SIZE 1000000;
SET SERVEROUT ON SIZE UNL;

BEGIN
  FOR i IN (SELECT name, datatype_string
              FROM gv$sql_bind_capture
             WHERE sql_id = '&&sqld360_sqlid.'
            --   AND (datatype_string LIKE 'NUMBER%' OR datatype_string = 'DATE')
            UNION
            SELECT name, datatype_string
              FROM dba_hist_sqlbind
             WHERE sql_id = '&&sqld360_sqlid.'
             --  AND (datatype_string LIKE 'NUMBER%' OR datatype_string = 'DATE')
               AND snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id. 
               AND '&&diagnostics_pack.' = 'Y'
             ORDER BY name) 
  LOOP
    DBMS_OUTPUT.PUT_LINE('<td class="c">'||REPLACE(i.name,':','')||' ('||i.datatype_string||')</td>');
  END LOOP;
END;
/

PRO </tr><tr class="main">
SPO OFF

-- this is to trick sqld360_9a_pre
DEF sqld360_main_report_bck = &&sqld360_main_report.
DEF sqld360_main_report = &&one_spool_filename.

SPO sqld360_captured_binds_&&sqld360_sqlid._driver.sql
SET SERVEROUT ON SIZE 1000000;
SET SERVEROUT ON SIZE UNL;

DECLARE
  PROCEDURE put (p_line IN VARCHAR2)
  IS
  BEGIN
    DBMS_OUTPUT.PUT_LINE(p_line);
  END put;
BEGIN

  FOR i IN (SELECT name, datatype_string
              FROM gv$sql_bind_capture
             WHERE sql_id = '&&sqld360_sqlid.'
            --   AND (datatype_string LIKE 'NUMBER%' OR datatype_string = 'DATE')
            UNION
            SELECT name, datatype_string
              FROM dba_hist_sqlbind
             WHERE sql_id = '&&sqld360_sqlid.'
             --  AND (datatype_string LIKE 'NUMBER%' OR datatype_string = 'DATE')
               AND snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id. 
               AND '&&diagnostics_pack.' = 'Y'
             ORDER BY name) 
  LOOP
    put(q'[SET PAGES 50000                           ]');
    put(q'[SPO &&sqld360_main_report..html APP;      ]');
    put(q'[PRO <td>                                  ]');
    put(q'[SPO OFF                                   ]');
    --
    IF i.datatype_string LIKE 'NUMBER%' OR i.datatype_string = 'DATE' THEN
        put(q'[DEF title= 'Bind ]'||i.name||q'[ values over time from memory'            ]');
        put(q'[DEF vAxis = 'Bind Value'                                 ]');
        put(q'[DEF main_table = 'GV$SQL_BIND_CAPTURE'                   ]');
        put(q'[DEF skip_sch=''                                          ]');
        put(q'[COL tooltip NOPRI                                        ]');
        put(q'[BEGIN                                                    ]');
        put(q'[ :sql_text := q'[                                        ]');
        -- the DISTINCT is because we don't care about how many binds had a value
        -- we just case about the value (1 or N times)
        put(q'[SELECT /*+ &&top_level_hints. */ DISTINCT                                                                      ]');
        put(q'[        TO_CHAR(last_captured, 'YYYY-MM-DD HH24:MI:SS') last_captured,                                         ]');
        put(q'[        value_string,                                                                                          ]');
        put(q'[        datatype_string,                                                                                       ]');
        put(q'[        'Captured: '||TO_CHAR(last_captured, 'YYYY-MM-DD HH24:MI:SS')||', Value: '||value_string tooltip       ]');
        put(q'[  FROM gv$sql_bind_capture                                                                                     ]');
        put(q'[ WHERE name = ']'||i.name||q'['                                                                                ]');
        put(q'[   AND datatype_string = ']'||i.datatype_string||q'['                                                          ]');
        put(q'[   AND sql_id = '&&sqld360_sqlid.'                                                                             ]');
        put(q'[   AND last_captured IS NOT NULL                                                                               ]');
        put(q'[ ORDER BY last_captured                                                                                        ]');
        put(']'';');
        put('END;');
        put('/ ');
        put('@sql/sqld360_9a_pre_one.sql');
        put(q'[COL tooltip PRI                                            ]');
        --
        put(q'[DEF title = 'Bind ]'||i.name||q'[ values over time from history'                  ]');
        put(q'[DEF vAxis = 'Bind Value'                                         ]');
        put(q'[DEF main_table = 'DBA_HIST_SQLBIND'                              ]');
        put(q'[DEF skip_sch=''                                                  ]');
        put(q'[COL tooltip NOPRI                                                ]');
        put(q'[BEGIN                                                            ]');
        put(q'[ :sql_text := q'[                                                ]');
        -- the DISTINCT is because we don't care about how many binds had a value
        -- we just case about the value (1 or N times)
        put(q'[SELECT /*+ &&top_level_hints. */ DISTINCT                                                                      ]');
        put(q'[        TO_CHAR(last_captured, 'YYYY-MM-DD HH24:MI:SS') last_captured,                                         ]');
        put(q'[        value_string,                                                                                          ]');
        put(q'[        datatype_string,                                                                                       ]');
        put(q'[        'Captured: '||TO_CHAR(last_captured, 'YYYY-MM-DD HH24:MI:SS')||', Value: '||value_string tooltip       ]');
        put(q'[  FROM dba_hist_sqlbind                                                                                        ]');
        put(q'[ WHERE name = ']'||i.name||q'['                                                                                ]');
        put(q'[   AND datatype_string = ']'||i.datatype_string||q'['                                                          ]');
        put(q'[   AND sql_id = '&&sqld360_sqlid.'                                                                             ]');
        put(q'[   AND snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.                                               ]');
        put(q'[   AND last_captured IS NOT NULL                                                                               ]');
        put(q'[   AND '&&diagnostics_pack.' = 'Y'                                                                             ]');
        put(q'[ ORDER BY last_captured                                                                                        ]');
        put(']'';');
        put('END;');
        put('/ ');
        put('@sql/sqld360_9a_pre_one.sql');
        put(q'[COL tooltip PRI                                                  ]');
    END IF;

    put(q'[DEF title= 'Top 15 bind ]'||i.name||q'[ values used'     ]');
    --put(q'[DEF vAxis = 'Bind Value'                                 ]');
    put(q'[DEF main_table = 'GV$SQL_BIND_CAPTURE'                   ]');
    put(q'[DEF skip_bch=''                                          ]');
    put(q'[COL tooltip NOPRI                                        ]');
    put(q'[BEGIN                                                    ]');
    put(q'[ :sql_text := q'[                                        ]');
    put(q'[SELECT value_string,                                                                                                                                             ]');
    put(q'[       num_captures,                                                                                                                                             ]');
    put(q'[       null,                                                                                                                                                     ]');
    put(q'[       'Value: '||value_string||' - Number of times captured: '||num_captures||' ('||TRUNC(100*RATIO_TO_REPORT(num_captures) OVER (),2)||'% of total)' tooltip   ]'); 
    put(q'[  FROM (SELECT value_string,                                                                                                                                     ]');
    put(q'[               COUNT(*) num_captures                                                                                                                             ]');
    put(q'[          FROM (SELECT value_string                                                                                                                              ]');
    put(q'[                  FROM gv$sql_bind_capture                                                                                                                       ]');
    put(q'[                 WHERE name = ']'||i.name||q'['                                                                                                                  ]');
    put(q'[                   AND datatype_string = ']'||i.datatype_string||q'['                                                                                            ]');
    put(q'[                   AND sql_id = '&&sqld360_sqlid.'                                                                                                               ]');
    put(q'[                   AND last_captured IS NOT NULL                                                                                                                 ]');
    put(q'[                UNION                                                                                                                                            ]');
    put(q'[                SELECT value_string                                                                                                                              ]');
    put(q'[                  FROM dba_hist_sqlbind                                                                                                                          ]');
    put(q'[                 WHERE name = ']'||i.name||q'['                                                                                                                  ]');
    put(q'[                   AND datatype_string = ']'||i.datatype_string||q'['                                                                                            ]');
    put(q'[                   AND sql_id = '&&sqld360_sqlid.'                                                                                                               ]');
    put(q'[                   AND last_captured IS NOT NULL                                                                                                                 ]');
    put(q'[                   AND snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.                                                                                 ]');
    put(q'[                   AND '&&diagnostics_pack.' = 'Y')                                                                                                              ]');
    put(q'[        GROUP BY value_string                                                                                                                                    ]');
    put(q'[        ORDER BY 2 DESC)                                                                                                                                         ]');
    put(q'[ WHERE rownum <= 15                                                                                                                                              ]');
    put(']'';');
    put('END;');
    put('/ ');
    put('@sql/sqld360_9a_pre_one.sql');
    put(q'[COL tooltip PRI                                            ]');


    put('SPO &&sqld360_main_report..html APP;');
    put('PRO </td>');
  END LOOP;
END;
/
SPO &&sqld360_main_report..html APP;
@sqld360_captured_binds_&&sqld360_sqlid._driver.sql

SPO &&sqld360_main_report..html APP;
PRO </tr></table>
@@sqld360_0e_html_footer.sql
SPO OFF
SET PAGES 50000

HOS zip -mq &&sqld360_main_filename._&&sqld360_file_time. &&sqld360_main_report..html
HOS zip -jmq 99999_sqld360_&&sqld360_sqlid._drivers sqld360_captured_binds_&&sqld360_sqlid._driver.sql

DEF sqld360_main_report = &&sqld360_main_report_bck.
