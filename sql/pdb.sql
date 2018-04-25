SET PAGES 100 LIN 80;
CL COL BRE
ALTER SESSION SET container = CDB$ROOT;
SELECT name, con_id, open_mode FROM v$pdbs ORDER BY name;
ALTER SESSION SET container = &pdb.;