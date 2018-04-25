PRO configuration

-- toolname, used on zip filenames
DEF _md_tool           = 'META360';

-- script get_top_N_schemas.sql executes get_schema.sql on top N application schemas according to number of rows
DEF _md_top_schemas    = '10';

-- these parameters restrict metadata extracted to object types below (Y/N)
DEF _md_get_tables     = 'Y';
DEF _md_get_indexes    = 'Y';
DEF _md_get_views      = 'Y';
DEF _md_get_synonyms   = 'Y';
DEF _md_get_types      = 'Y';
DEF _md_get_packages   = 'Y';
DEF _md_get_triggers   = 'Y';
DEF _md_get_sequences  = 'Y';
DEF _md_get_procedures = 'Y';
DEF _md_get_libraries  = 'Y';
DEF _md_get_functions  = 'Y';
DEF _md_get_mat_views  = 'Y';

-- these parameters affect metadata transformations for tables and indexes
DEF _md_segment_attr   = 'FALSE';
DEF _md_storage        = 'TRUE';
DEF _md_tablespace     = 'TRUE';
DEF _md_const_as_alter = 'FALSE';

-- this parameter adds a forward slash "/" or semi-colon ";" at the end of DDL SQL commands
DEF _md_sql_terminator = 'TRUE';

/*************************************************************************************/

PRO To customize this configuration file enter below your modified values

--DEF _md_segment_attr   = 'TRUE';
--DEF _md_sql_terminator = 'FALSE';
