PRO from MOS 1551288.1

--SPO ck_free.txt

SET SERVEROUTPUT ON;
--SET LINES 155
--SET PAGES 0
--SET TRIMSPOOL ON

DECLARE
   v_space_reserve_factor NUMBER := 0.15;
   v_num_disks    NUMBER;
   v_group_number   NUMBER;
   v_max_total_mb   NUMBER;
   v_max_used_mb  NUMBER;
   v_fg_count   NUMBER;

   v_required_free_mb   NUMBER;
   v_usable_mb      NUMBER;
   v_cell_usable_mb   NUMBER;
   v_one_cell_usable_mb   NUMBER;
   v_enuf_free      BOOLEAN := FALSE;
   v_enuf_free_cell   BOOLEAN := FALSE;

   v_req_mirror_free_adj_factor   NUMBER := 1.10;
   v_req_mirror_free_adj         NUMBER := 0;
   v_one_cell_req_mir_free_mb     NUMBER  := 0;

   v_disk_desc      VARCHAR(10) := 'SINGLE';
   v_offset      NUMBER := 50;

   v_db_version   VARCHAR2(8);
   v_inst_name    VARCHAR2(1);

   v_dg_pct_msg   VARCHAR2(500);
   v_cfc_fail_msg VARCHAR2(500);

BEGIN

   SELECT substr(version,1,8), substr(instance_name,1,1)    INTO v_db_version, v_inst_name    FROM v$instance;
/*
   IF v_inst_name <> '+' THEN
      DBMS_OUTPUT.PUT_LINE('ERROR: THIS IS NOT AN ASM INSTANCE!  PLEASE LOG ON TO AN ASM INSTANCE AND RE-RUN THIS SCRIPT.');
      GOTO the_end;
   END IF;
*/
    DBMS_OUTPUT.PUT_LINE('------ DISK and CELL Failure Diskgroup Space Reserve Requirements  ------');
    DBMS_OUTPUT.PUT_LINE(' This procedure determines how much space you need to survive a DISK or CELL failure. It also shows the usable space ');
    DBMS_OUTPUT.PUT_LINE(' available when reserving space for disk or cell failure (loss of cell is rare and not usually a concern).  ');
    DBMS_OUTPUT.PUT_LINE(' These required mirror and usable space assume space utilized to full capacity - a worst case condition.');
    DBMS_OUTPUT.PUT_LINE(' Please see MOS note 1551288.1 for more information.  ');
    DBMS_OUTPUT.PUT_LINE('.  .  .');
    DBMS_OUTPUT.PUT_LINE(' Description of Derived Values:');
    DBMS_OUTPUT.PUT_LINE(' Recommended Reserve MB           : Space needed to rebalance after loss of single or double disk failure (for normal or high redundancy)');
    DBMS_OUTPUT.PUT_LINE(' Disk Usable File MB              : Usable space available after reserving space for disk failure and accounting for mirroring');
    DBMS_OUTPUT.PUT_LINE(' PCT Util                         : Percent of Total Diskgroup Space Utilized');
    DBMS_OUTPUT.PUT_LINE(' DFC                              : Disk Failure Coverage Check (PASS = able to rebalance after loss of single disk)');
   
   DBMS_OUTPUT.PUT_LINE('.  .  .');

   DBMS_OUTPUT.PUT_LINE('ASM Version is '||v_db_version);


-- Set up headings
      DBMS_OUTPUT.PUT_LINE('-------------------------------------------------------------------------------------------------------------------------------------------------');
      DBMS_OUTPUT.PUT('|          ');
      DBMS_OUTPUT.PUT('|         ');
      DBMS_OUTPUT.PUT('|     ');
      DBMS_OUTPUT.PUT('|     ');
      DBMS_OUTPUT.PUT('|            ');
      DBMS_OUTPUT.PUT('|                ');
      DBMS_OUTPUT.PUT('|                ');
      DBMS_OUTPUT.PUT('|                ');
      DBMS_OUTPUT.PUT('|Recommended     ');
      DBMS_OUTPUT.PUT('|                ');
      DBMS_OUTPUT.PUT('|       |');    
      DBMS_OUTPUT.PUT_LINE('    |');
      -- next row
      DBMS_OUTPUT.PUT('|          ');
      DBMS_OUTPUT.PUT('|DG       ');
      DBMS_OUTPUT.PUT('|Num  ');
      DBMS_OUTPUT.PUT('|Num  ');     
      DBMS_OUTPUT.PUT('|Disk Size   ');
      DBMS_OUTPUT.PUT('|DG Total        ');
      DBMS_OUTPUT.PUT('|DG Used         ');
      DBMS_OUTPUT.PUT('|DG Free         ');
      DBMS_OUTPUT.PUT('|Reserve         ');
      DBMS_OUTPUT.PUT('|Disk Usable     ');
      DBMS_OUTPUT.PUT('|PCT    |');
      DBMS_OUTPUT.PUT_LINE('    |');
      -- next row
      DBMS_OUTPUT.PUT('|DG Name   ');
      DBMS_OUTPUT.PUT('|Type     ');
      DBMS_OUTPUT.PUT('|FGs  ');
      DBMS_OUTPUT.PUT('|Disks');
      DBMS_OUTPUT.PUT('|MB          ');
      DBMS_OUTPUT.PUT('|MB              ');
      DBMS_OUTPUT.PUT('|MB              ');
      DBMS_OUTPUT.PUT('|MB              ');
      DBMS_OUTPUT.PUT('|MB              ');
      DBMS_OUTPUT.PUT('|File MB         ');
      DBMS_OUTPUT.PUT('|Util   ');
      DBMS_OUTPUT.PUT_LINE('|DFC |');
      DBMS_OUTPUT.PUT_LINE('-------------------------------------------------------------------------------------------------------------------------------------------------');

   FOR dg IN (SELECT name, type, group_number, total_mb, free_mb, required_mirror_free_mb FROM v$asm_diskgroup ORDER BY name) LOOP

      v_enuf_free := FALSE;

      -- Find largest amount of space allocated to a cell
      SELECT sum(disk_cnt), max(max_total_mb), max(sum_used_mb), count(distinct failgroup)
     INTO v_num_disks,v_max_total_mb, v_max_used_mb, v_fg_count
      FROM (SELECT failgroup, count(1) disk_cnt, max(total_mb) max_total_mb, sum(total_mb - free_mb) sum_used_mb
      FROM v$asm_disk
     WHERE group_number = dg.group_number and failgroup_type = 'REGULAR'
     GROUP BY failgroup);

   -- Amount to reserve depends on version and number of FGs
   IF  ((v_db_version like '12.2%') or (v_db_version like '18%') or  (v_db_version like '19%')) THEN
     IF v_fg_count < 5 THEN
        v_space_reserve_factor := 0.15 ;
        v_dg_pct_msg := v_dg_pct_msg||'Diskgroup '||dg.name||' using reserve factor of 15% '||chr(10);
     ELSE 
       v_space_reserve_factor := 0.09 ;
       v_dg_pct_msg := v_dg_pct_msg||'Diskgroup '||dg.name||' using reserve factor of 9% '||chr(10);
     END IF;
   ELSIF ( (v_db_version like '12.1%' ) or (v_db_version like '11.2.0.4%') ) THEN
       v_space_reserve_factor := 0.15 ;     
       v_dg_pct_msg := v_dg_pct_msg||'Diskgroup '||dg.name||' using reserve factor of 15% '||chr(10);
   ELSE 
       v_space_reserve_factor := 0.15 ;
       v_dg_pct_msg := v_dg_pct_msg||'Diskgroup '||dg.name||' using reserve factor of 15% '||chr(10);
   END IF;

   v_required_free_mb := v_space_reserve_factor * dg.total_mb;
   IF dg.free_mb > v_required_free_mb THEN v_enuf_free := TRUE; END IF;

   IF dg.type = 'NORMAL' THEN

       -- DISK usable file MB
       v_usable_mb := ROUND((dg.free_mb - v_required_free_mb)/2);

   ELSIF dg.type = 'HIGH' THEN
       -- HIGH redundancy
       -- DISK usable file MB
       v_usable_mb := ROUND((dg.free_mb - v_required_free_mb)/3);
       
   ELSIF dg.type = 'EXTEND' THEN
       -- EXTENDED redundancy for stretch clusters

       -- DISK usable file MB
       v_usable_mb := ROUND((dg.free_mb - v_required_free_mb)/4);

    ELSE
      -- We don't know this type...maybe FLEX DG - not enough info to say 
      v_usable_mb := NULL;

   END IF;
     
      DBMS_OUTPUT.PUT('|'||RPAD(dg.name,v_offset-40));
      DBMS_OUTPUT.PUT('|'||RPAD(nvl(dg.type,'  '),v_offset-41));
      DBMS_OUTPUT.PUT('|'||LPAD(TO_CHAR(v_fg_count),v_offset-45));
      DBMS_OUTPUT.PUT('|'||LPAD(TO_CHAR(v_num_disks),v_offset-45));
      DBMS_OUTPUT.PUT('|'||TO_CHAR(v_max_total_mb,'999,999,999'));
      DBMS_OUTPUT.PUT('|'||TO_CHAR(dg.total_mb,'999,999,999,999'));
      DBMS_OUTPUT.PUT('|'||TO_CHAR(dg.total_mb - dg.free_mb,'999,999,999,999'));
      DBMS_OUTPUT.PUT('|'||TO_CHAR(dg.free_mb,'999,999,999,999'));
      DBMS_OUTPUT.PUT('|'||TO_CHAR(ROUND(v_required_free_mb),'999,999,999,999'));
      DBMS_OUTPUT.PUT('|'||TO_CHAR(ROUND(v_usable_mb),'999,999,999,999'));

     -- Calc Disk Utilization Percentage
      IF dg.total_mb > 0 THEN
         DBMS_OUTPUT.PUT('|'||TO_CHAR((((dg.total_mb - dg.free_mb)/dg.total_mb)*100),'999.9')||CHR(37));
      ELSE
         DBMS_OUTPUT.PUT('|       ');
      END IF;

      IF v_enuf_free THEN
         DBMS_OUTPUT.PUT_LINE('|'||'PASS|');
      ELSE
         DBMS_OUTPUT.PUT_LINE('|'||'FAIL|');
      END IF;


   END LOOP;

     DBMS_OUTPUT.PUT_LINE('-------------------------------------------------------------------------------------------------------------------------------------------------');
   <<the_end>>

   DBMS_OUTPUT.PUT_LINE(v_dg_pct_msg);

   IF v_cfc_fail_msg is not null THEN
      DBMS_OUTPUT.PUT_LINE('Cell Failure Coverage Freespace Failures Detected. Warning Message Follows.');
      DBMS_OUTPUT.PUT_LINE(v_cfc_fail_msg);
   END IF;

   DBMS_OUTPUT.PUT_LINE('.  .  .');
   DBMS_OUTPUT.PUT_LINE('Script completed.');

END;
/

--WHENEVER SQLERROR EXIT FAILURE;
SET SERVEROUTPUT OFF;

--SPO OFF;
