-- David Mann
-- http://ba6.us

-- Archived Log Redo in GB Heat Map for past 31 Days
-- Requires access to v$archived_log, v$database

-- Usage (3 possiblities):
-- o Spool output to file and view with browser 
-- o Use SQL Developer PL/SQL DBMS_OUTPUT report type
-- o Paste code into Apex PL/SQL output type and change DBMS_OUTPUT to HTP.P

-- I tried to use a scripted stylesheet but SQL Dev wouldn't cooperate so
-- that is my excuse for all of the ugly inline CSS. For now :) 

-- Date         Change
-- -----------  ---------------------------------------------------------------
-- 24-JUL-2012  Initial version
-- 25-OCT-2012  Only print max value number, trying to reduce visual complexity
-- 08-MAR-2016  Changed report to Redo in GB, updated calulations, added Total col

--SET SERVEROUTPUT ON
DECLARE
  myMaxDay NUMBER;
  myMaxHour NUMBER;
  myDBName VARCHAR2(16);

  -- dec2hex Function from http://www.orafaq.com/wiki/Hexadecimal
  FUNCTION dec2hex (N in number) RETURN varchar2 IS
    hexval varchar2(64);
    N2     number := N;
    digit  number;
    hexdigit  char;
  BEGIN
    while ( N2 > 0 ) loop
       digit := mod(N2, 16);
       if digit > 9 then 
         hexdigit := chr(ascii('A') + digit - 10);
       else
         hexdigit := to_char(digit);
       end if;
       hexval := hexdigit || hexval;
       N2 := trunc( N2 / 16 );
    end loop;
    return hexval;
  END dec2hex;

  FUNCTION DataCell ( P_Value NUMBER, P_Max NUMBER) RETURN VARCHAR2 IS
   myReturn VARCHAR2(256);
   myColorVal NUMBER;
   myColorHex VARCHAR2(16);
  BEGIN

    -- Determine shade of red the P_Value should be compared to Solid Red for P_Max
    -- Higher HEX values for G,B render as lighter colors
    myColorVal := ROUND( 255-FLOOR(255 * (P_VALUE / P_MAX)));
    myColorHex := LPAD(TRIM(dec2hex(myColorVal)) ,2,'0');
    IF P_Value >= P_Max THEN
      myColorHex := '00';
    END IF;

    myReturn := '<TD STYLE="background-color: #FF'||
                myColorHex||
                myColorHex||
                '; font-family: monospace; text-align: right; border-left: 1px solid black; border-top: 1px solid black">';
    myReturn := myReturn ||TO_CHAR(P_Value,'9999.9');
    myReturn := myReturn ||'</TD>';

    RETURN myReturn;
  END DataCell;

BEGIN

  DBMS_OUTPUT.ENABLE(1000000);

  SELECT ROUND(MAX(ROUND(SUM(blocks*block_size)/1024/1024/1024)),1)
    INTO myMaxDay
    FROM v$archived_log
    WHERE trunc(FIRST_TIME) >= trunc(sysdate - 31)
  GROUP BY TO_CHAR(first_time,'YYYY-MM-DD');

  SELECT ROUND(MAX(ROUND(SUM(blocks*block_size)/1024/1024/1024)),1)
    INTO myMaxHour
    FROM v$archived_log
    WHERE trunc(FIRST_TIME) >= trunc(sysdate - 31)
  GROUP BY TO_CHAR(first_time,'YYYY-MM-DD HH24');
  
  SELECT NAME INTO myDBName FROM V$DATABASE;

  DBMS_OUTPUT.PUT_LINE('<HTML>');
  DBMS_OUTPUT.PUT_LINE('<H1>Archived Log Heat Map by Hourly and Daily Redo GB - '||myDBName||'  - Past 31 days</H1>');
  DBMS_OUTPUT.PUT_LINE('<TABLE STYLE="border: 1px solid black">');
  DBMS_OUTPUT.PUT_LINE('<TR>');
  DBMS_OUTPUT.PUT_LINE('<TD STYLE="font-family: monospace; font-weight: bold; background-color:#DEDEDE">Date / Hour</TD>');
  DBMS_OUTPUT.PUT_LINE('<TD STYLE="font-family: monospace; font-weight: bold; background-color:#DEDEDE">00</TD>');
  DBMS_OUTPUT.PUT_LINE('<TD STYLE="font-family: monospace; font-weight: bold; background-color:#DEDEDE">01</TD>');
  DBMS_OUTPUT.PUT_LINE('<TD STYLE="font-family: monospace; font-weight: bold; background-color:#DEDEDE">02</TD>');
  DBMS_OUTPUT.PUT_LINE('<TD STYLE="font-family: monospace; font-weight: bold; background-color:#DEDEDE">03</TD>');
  DBMS_OUTPUT.PUT_LINE('<TD STYLE="font-family: monospace; font-weight: bold; background-color:#DEDEDE">04</TD>');
  DBMS_OUTPUT.PUT_LINE('<TD STYLE="font-family: monospace; font-weight: bold; background-color:#DEDEDE">05</TD>');
  DBMS_OUTPUT.PUT_LINE('<TD STYLE="font-family: monospace; font-weight: bold; background-color:#DEDEDE">06</TD>');
  DBMS_OUTPUT.PUT_LINE('<TD STYLE="font-family: monospace; font-weight: bold; background-color:#DEDEDE">07</TD>');
  DBMS_OUTPUT.PUT_LINE('<TD STYLE="font-family: monospace; font-weight: bold; background-color:#DEDEDE">08</TD>');
  DBMS_OUTPUT.PUT_LINE('<TD STYLE="font-family: monospace; font-weight: bold; background-color:#DEDEDE">09</TD>');
  DBMS_OUTPUT.PUT_LINE('<TD STYLE="font-family: monospace; font-weight: bold; background-color:#DEDEDE">10</TD>');
  DBMS_OUTPUT.PUT_LINE('<TD STYLE="font-family: monospace; font-weight: bold; background-color:#DEDEDE">11</TD>');
  DBMS_OUTPUT.PUT_LINE('<TD STYLE="font-family: monospace; font-weight: bold; background-color:#DEDEDE">12</TD>');
  DBMS_OUTPUT.PUT_LINE('<TD STYLE="font-family: monospace; font-weight: bold; background-color:#DEDEDE">13</TD>');
  DBMS_OUTPUT.PUT_LINE('<TD STYLE="font-family: monospace; font-weight: bold; background-color:#DEDEDE">14</TD>');
  DBMS_OUTPUT.PUT_LINE('<TD STYLE="font-family: monospace; font-weight: bold; background-color:#DEDEDE">15</TD>');
  DBMS_OUTPUT.PUT_LINE('<TD STYLE="font-family: monospace; font-weight: bold; background-color:#DEDEDE">16</TD>');
  DBMS_OUTPUT.PUT_LINE('<TD STYLE="font-family: monospace; font-weight: bold; background-color:#DEDEDE">17</TD>');
  DBMS_OUTPUT.PUT_LINE('<TD STYLE="font-family: monospace; font-weight: bold; background-color:#DEDEDE">18</TD>');
  DBMS_OUTPUT.PUT_LINE('<TD STYLE="font-family: monospace; font-weight: bold; background-color:#DEDEDE">19</TD>');
  DBMS_OUTPUT.PUT_LINE('<TD STYLE="font-family: monospace; font-weight: bold; background-color:#DEDEDE">20</TD>');
  DBMS_OUTPUT.PUT_LINE('<TD STYLE="font-family: monospace; font-weight: bold; background-color:#DEDEDE">21</TD>');
  DBMS_OUTPUT.PUT_LINE('<TD STYLE="font-family: monospace; font-weight: bold; background-color:#DEDEDE">22</TD>');
  DBMS_OUTPUT.PUT_LINE('<TD STYLE="font-family: monospace; font-weight: bold; background-color:#DEDEDE">23</TD>');
  DBMS_OUTPUT.PUT_LINE('<TD STYLE="font-family: monospace; font-weight: bold; background-color:#DEDEDE">Total</TD>');
  DBMS_OUTPUT.PUT_LINE('<TR>');

  FOR cur IN (
    select trunc(first_time) AS Day,
    sum(DECODE(to_char(first_time, 'HH24'), '00', blocks*block_size/1024/1024/1024, 0)) AS "00",
    sum(DECODE(to_char(first_time, 'HH24'), '01', blocks*block_size/1024/1024/1024, 0)) AS "01",
    sum(DECODE(to_char(first_time, 'HH24'), '02', blocks*block_size/1024/1024/1024, 0)) AS "02",
    sum(DECODE(to_char(first_time, 'HH24'), '03', blocks*block_size/1024/1024/1024, 0)) AS "03",
    sum(DECODE(to_char(first_time, 'HH24'), '04', blocks*block_size/1024/1024/1024, 0)) AS "04",
    sum(DECODE(to_char(first_time, 'HH24'), '05', blocks*block_size/1024/1024/1024, 0)) AS "05",
    sum(DECODE(to_char(first_time, 'HH24'), '06', blocks*block_size/1024/1024/1024, 0)) AS "06",
    sum(DECODE(to_char(first_time, 'HH24'), '07', blocks*block_size/1024/1024/1024, 0)) AS "07",
    sum(DECODE(to_char(first_time, 'HH24'), '08', blocks*block_size/1024/1024/1024, 0)) AS "08",
    sum(DECODE(to_char(first_time, 'HH24'), '09', blocks*block_size/1024/1024/1024, 0)) AS "09",
    sum(DECODE(to_char(first_time, 'HH24'), '10', blocks*block_size/1024/1024/1024, 0)) AS "10",
    sum(DECODE(to_char(first_time, 'HH24'), '11', blocks*block_size/1024/1024/1024, 0)) AS "11",
    sum(DECODE(to_char(first_time, 'HH24'), '12', blocks*block_size/1024/1024/1024, 0)) AS "12",
    sum(DECODE(to_char(first_time, 'HH24'), '13', blocks*block_size/1024/1024/1024, 0)) AS "13",
    sum(DECODE(to_char(first_time, 'HH24'), '14', blocks*block_size/1024/1024/1024, 0)) AS "14",
    sum(DECODE(to_char(first_time, 'HH24'), '15', blocks*block_size/1024/1024/1024, 0)) AS "15",
    sum(DECODE(to_char(first_time, 'HH24'), '16', blocks*block_size/1024/1024/1024, 0)) AS "16",
    sum(DECODE(to_char(first_time, 'HH24'), '17', blocks*block_size/1024/1024/1024, 0)) AS "17",
    sum(DECODE(to_char(first_time, 'HH24'), '18', blocks*block_size/1024/1024/1024, 0)) AS "18",
    sum(DECODE(to_char(first_time, 'HH24'), '19', blocks*block_size/1024/1024/1024, 0)) AS "19",
    sum(DECODE(to_char(first_time, 'HH24'), '20', blocks*block_size/1024/1024/1024, 0)) AS "20",
    sum(DECODE(to_char(first_time, 'HH24'), '21', blocks*block_size/1024/1024/1024, 0)) AS "21",
    sum(DECODE(to_char(first_time, 'HH24'), '22', blocks*block_size/1024/1024/1024, 0)) AS "22",
    sum(DECODE(to_char(first_time, 'HH24'), '23', blocks*block_size/1024/1024/1024, 0)) AS "23",
    sum(blocks*block_size/1024/1024/1024) as "Total"
    FROM v$archived_log
    WHERE trunc(FIRST_TIME) >= trunc(sysdate - 31)
    GROUP BY trunc(first_time)
    ORDER BY TRUNC(FIRST_TIME) DESC
  )
  LOOP
    DBMS_OUTPUT.PUT_LINE('<TR>');
    DBMS_OUTPUT.PUT_LINE('<TD style="font-family: monospace; font-weight: bold; background-color:#DEDEDE">'||
                         TO_CHAR(cur.Day,'DD-MON-YYYY')||'<EM></TD>');
    DBMS_OUTPUT.PUT_LINE( DataCell(cur."00", myMaxHour) );
    DBMS_OUTPUT.PUT_LINE( DataCell(cur."01", myMaxHour) );
    DBMS_OUTPUT.PUT_LINE( DataCell(cur."02", myMaxHour) );
    DBMS_OUTPUT.PUT_LINE( DataCell(cur."03", myMaxHour) );
    DBMS_OUTPUT.PUT_LINE( DataCell(cur."04", myMaxHour) );
    DBMS_OUTPUT.PUT_LINE( DataCell(cur."05", myMaxHour) );
    DBMS_OUTPUT.PUT_LINE( DataCell(cur."06", myMaxHour) );
    DBMS_OUTPUT.PUT_LINE( DataCell(cur."07", myMaxHour) );
    DBMS_OUTPUT.PUT_LINE( DataCell(cur."08", myMaxHour) );
    DBMS_OUTPUT.PUT_LINE( DataCell(cur."09", myMaxHour) );
    DBMS_OUTPUT.PUT_LINE( DataCell(cur."10", myMaxHour) );
    DBMS_OUTPUT.PUT_LINE( DataCell(cur."11", myMaxHour) );
    DBMS_OUTPUT.PUT_LINE( DataCell(cur."12", myMaxHour) );
    DBMS_OUTPUT.PUT_LINE( DataCell(cur."13", myMaxHour) );
    DBMS_OUTPUT.PUT_LINE( DataCell(cur."14", myMaxHour) );
    DBMS_OUTPUT.PUT_LINE( DataCell(cur."15", myMaxHour) );
    DBMS_OUTPUT.PUT_LINE( DataCell(cur."16", myMaxHour) );
    DBMS_OUTPUT.PUT_LINE( DataCell(cur."17", myMaxHour) );
    DBMS_OUTPUT.PUT_LINE( DataCell(cur."18", myMaxHour) );
    DBMS_OUTPUT.PUT_LINE( DataCell(cur."19", myMaxHour) );
    DBMS_OUTPUT.PUT_LINE( DataCell(cur."20", myMaxHour) );
    DBMS_OUTPUT.PUT_LINE( DataCell(cur."21", myMaxHour) );
    DBMS_OUTPUT.PUT_LINE( DataCell(cur."22", myMaxHour) );
    DBMS_OUTPUT.PUT_LINE( DataCell(cur."23", myMaxHour) );
    DBMS_OUTPUT.PUT_LINE( DataCell(cur."Total", myMaxDay) );
    DBMS_OUTPUT.PUT_LINE('</TR>');
  END LOOP;

  DBMS_OUTPUT.PUT_LINE('</TABLE>');
  DBMS_OUTPUT.PUT_LINE('</HTML>');

END;
/
