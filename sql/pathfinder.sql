/*

  Pathfinder v1501 (2015-10-26) by Mauro Pagano
  USE AT YOUR OWN RISK!!

  Usage

  1. Unzip pathfinder-master.zip, navigate to the root pathfinder directory, and connect as SYS:
  
     $ unzip pathfinder-master.zip
     $ cd pathfinder-master
     $ sqlplus / as sysdba
  
  2. Open SQL script file script.sql and add your SQL in there. Make sure to add the mandatory
     comment ^^pathfinder_testid 
  
  3. Execute pathfinder.sql, the single input parameter is the connect string to the user
     that is supposed to execute the SQL. Assume the user is scott with pwd tiger in database
     ORCL then the connect string will be scott/tiger@orcl
  
     SQL> @pathfinder.sql 
     
  4. Unzip output pathfinder_<dbname>_<date>.zip into a directory on your PC
  
  5. Review main html file 00001_pathfinder_<dbname>_<date>_index.html
  
    Author: Mauro Pagano
    Email: mauro.pagano@gmail.com

*/


--WHENEVER SQLERROR EXIT SQL.SQLCODE;
SET TERM ON; 
SET VER OFF; 
SET FEED OFF; 
SET ECHO OFF;
SET TIM OFF;
SET TIMI OFF;
CL COL;
SET LIN 32767 PAGES 0 LONG 32767000 LONGC 32767 TRIMS ON AUTOT OFF;

-- version
DEF pathfinder_vYYNN = 'v1601';
DEF pathfinder_vrsn = '&&pathfinder_vYYNN. (2016-01-03)';
DEF pathfinder_prefix = 'pathfinder';
DEF pathfinder_script = 'script.sql'

-- connect string
PRO
PRO Parameter 1: 
PRO Full connect string of the database to run the SQL into
PRO If the database is remote or a PDB then you must include 
PRO the TNS alias i.e. scott/tiger@orcl
PRO
COL pathfinder_conn new_V pathfinder_conn FOR A100;
SELECT TRIM('&1.') pathfinder_conn FROM DUAL;

SET TERM OFF

-- timestamp on filename
COL pathfinder_file_time NEW_V pathfinder_file_time FOR A20;
SELECT TO_CHAR(SYSDATE, 'YYYYMMDD_HH24MI') pathfinder_file_time FROM DUAL;

-- get database name (up to 10, stop before first '.', no special characters)
COL database_name_short NEW_V database_name_short FOR A10;
SELECT LOWER(SUBSTR(SYS_CONTEXT('USERENV', 'DB_NAME'), 1, 10)) database_name_short FROM DUAL;
SELECT SUBSTR('&&database_name_short.', 1, INSTR('&&database_name_short..', '.') - 1) database_name_short FROM DUAL;
SELECT TRANSLATE('&&database_name_short.',
'abcdefghijklmnopqrstuvwxyz0123456789-_ ''`~!@#$%&*()=+[]{}\|;:",.<>/?'||CHR(0)||CHR(9)||CHR(10)||CHR(13)||CHR(38),
'abcdefghijklmnopqrstuvwxyz0123456789-_') database_name_short FROM DUAL;

-- get database version
COL db_version NEW_V db_version;
SELECT version db_version FROM v$instance;

COL plnfdn_start_time NEW_V plnfdn_start_time
SELECT TO_CHAR(SYSDATE, 'YYYY/MM/DD HH24:MI:SS') plnfdn_start_time FROM DUAL;

-- setup
DEF title = 'Pathfinder';
DEF common_pathfinder_prefix = '&&pathfinder_prefix._&&database_name_short._&&pathfinder_file_time.';
DEF pathfinder_main_report = '00001_&&common_pathfinder_prefix._index';
DEF pathfinder_log = '00002_&&common_pathfinder_prefix._log';

SPO &&pathfinder_main_report..html APP;
PRO <html>
PRO <!-- $Header: &&pathfinder_main_report. &&pathfinder_vrsn. mauro.pagano $ -->
PRO <!-- Copyrightpathfinder_copyright., All rights reserved. -->
PRO <!-- Author: mauro.pagano@gmail.com -->
PRO
PRO <head>
PRO <link rel="icon" href="pathfinder_favicon.ico">
PRO <title>&&title.</title>
PRO
PRO <style type="text/css">
PRO body          {font:10pt Arial,Helvetica,Geneva,sans-serif; color:black; background:white;}
PRO h1            {font-size:16pt; font-weight:bold; color:#336699; border-bottom:1px solid #cccc99; margin-top:0pt; margin-bottom:0pt; padding:0px 0px 0px 0px;}
PRO h2            {font-size:14pt; font-weight:bold; color:#336699; margin-top:4pt; margin-bottom:0pt;}
PRO h3            {font-size:12pt; font-weight:bold; color:#336699; margin-top:4pt; margin-bottom:0pt;}
PRO pre           {font:8pt monospace,Monaco,"Courier New",Courier;}
PRO a             {color:#663300;}
PRO table         {font-size:8pt; border-collapse:collapse; empty-cells:show; white-space:nowrap; border:1px solid #cccc99;}
PRO li            {font-size:8pt; color:black; padding-left:4px; padding-right:4px; padding-bottom:2px;}
PRO th            {font-weight:bold; color:white; background:#0066CC; padding-left:4px; padding-right:4px; padding-bottom:2px;}
PRO tr            {color:black; background:#fcfcf0;}
PRO tr.main       {color:black; background:#fcfcf0;}
PRO td            {vertical-align:top; border:1px solid #cccc99;}
PRO td.c          {text-align:center;}
PRO tr.main:hover { background:#0066CC; color:white;}
PRO font.n        {font-size:8pt; font-style:italic; color:#336699;}
PRO font.f        {font-size:8pt; color:#999999; border-top:1px solid #cccc99; margin-top:30pt;}
PRO </style>
PRO <script src="sorttable.js"></script>
PRO </head>
PRO <body>
PRO <h1><em>Pathfinder</em> &&pathfinder_vrsn.: Plan Finder</h1>
PRO <pre>dbname:&&database_name_short. version:&&db_version. connect string:&&pathfinder_conn. startime:&&plnfdn_start_time.</pre>
PRO
PRO <table class=sortable><tr class="main">
PRO <th class="c">Test#</td>
PRO <th class="c">CFB<br>Reparse#</td>
PRO <th class="c">Setting</td>
PRO <th class="c">Plan<br>Hash Value</td>
PRO <th class="c">Elapsed<br>Time</td>
PRO <th class="c">CPU<br>Time</td>
PRO <th class="c">Buffer<br>Gets</td>
PRO <th class="c">Rows<br>Processed</td>
PRO <th class="c">Execution<br>Plan</td>
PRO <th class="c">V$SQL<br>Details</td>
PRO </tr>
PRO
SPO OFF;

SET TERM ON
SET SERVEROUT ON SIZE UNLIMITED;
PRO Building Pathfinder driver scripts
SET TERM OFF

SET DEF OFF
-- sorttablejs
SPO sorttable.js
PRO /*
PRO   SortTable
PRO   version 2
PRO   7th April 2007
PRO   Stuart Langridge, http://www.kryogenix.org/code/browser/sorttable/
PRO 
PRO   Instructions:
PRO   Download this file
PRO   Add <script src="sorttable.js"></script> to your HTML
PRO  Add class="sortable" to any table you'd like to make sortable
PRO  Click on the headers to sort
PRO
PRO  Thanks to many, many people for contributions and suggestions.
PRO  Licenced as X11: http://www.kryogenix.org/code/browser/licence.html
PRO  This basically means: do what you want with it.
PRO */
PRO
PRO
PRO var stIsIE = /*@cc_on!@*/false;
PRO
PRO sorttable = {
PRO  init: function() {
PRO    // quit if this function has already been called
PRO    if (arguments.callee.done) return;
PRO    // flag this function so we don't do the same thing twice
PRO    arguments.callee.done = true;
PRO    // kill the timer
PRO    if (_timer) clearInterval(_timer);
PRO
PRO    if (!document.createElement || !document.getElementsByTagName) return;
PRO
PRO    sorttable.DATE_RE = /^(\d\d?)[\/\.-](\d\d?)[\/\.-]((\d\d)?\d\d)$/;
PRO
PRO    forEach(document.getElementsByTagName('table'), function(table) {
PRO      if (table.className.search(/\bsortable\b/) != -1) {
PRO        sorttable.makeSortable(table);
PRO      }
PRO    });
PRO
PRO  },
PRO
PRO  makeSortable: function(table) {
PRO    if (table.getElementsByTagName('thead').length == 0) {
PRO      // table doesn't have a tHead. Since it should have, create one and
PRO      // put the first table row in it.
PRO      the = document.createElement('thead');
PRO      the.appendChild(table.rows[0]);
PRO      table.insertBefore(the,table.firstChild);
PRO    }
PRO    // Safari doesn't support table.tHead, sigh
PRO    if (table.tHead == null) table.tHead = table.getElementsByTagName('thead')[0];
PRO
PRO    if (table.tHead.rows.length != 1) return; // can't cope with two header rows
PRO
PRO    // Sorttable v1 put rows with a class of "sortbottom" at the bottom (as
PRO    // "total" rows, for example). This is B&R, since what you're supposed
PRO    // to do is put them in a tfoot. So, if there are sortbottom rows,
PRO    // for backwards compatibility, move them to tfoot (creating it if needed).
PRO    sortbottomrows = [];
PRO    for (var i=0; i<table.rows.length; i++) {
PRO      if (table.rows[i].className.search(/\bsortbottom\b/) != -1) {
PRO        sortbottomrows[sortbottomrows.length] = table.rows[i];
PRO      }
PRO    }
PRO    if (sortbottomrows) {
PRO      if (table.tFoot == null) {
PRO        // table doesn't have a tfoot. Create one.
PRO        tfo = document.createElement('tfoot');
PRO        table.appendChild(tfo);
PRO      }
PRO      for (var i=0; i<sortbottomrows.length; i++) {
PRO        tfo.appendChild(sortbottomrows[i]);
PRO      }
PRO      delete sortbottomrows;
PRO    }
PRO
PRO    // work through each column and calculate its type
PRO    headrow = table.tHead.rows[0].cells;
PRO    for (var i=0; i<headrow.length; i++) {
PRO      // manually override the type with a sorttable_type attribute
PRO      if (!headrow[i].className.match(/\bsorttable_nosort\b/)) { // skip this col
PRO        mtch = headrow[i].className.match(/\bsorttable_([a-z0-9]+)\b/);
PRO        if (mtch) { override = mtch[1]; }
PRO        if (mtch && typeof sorttable["sort_"+override] == 'function') {
PRO          headrow[i].sorttable_sortfunction = sorttable["sort_"+override];
PRO        } else {
PRO          headrow[i].sorttable_sortfunction = sorttable.guessType(table,i);
PRO        }
PRO        // make it clickable to sort
PRO        headrow[i].sorttable_columnindex = i;
PRO        headrow[i].sorttable_tbody = table.tBodies[0];
PRO        dean_addEvent(headrow[i],"click", sorttable.innerSortFunction = function(e) {
PRO
PRO          if (this.className.search(/\bsorttable_sorted\b/) != -1) {
PRO            // if we're already sorted by this column, just
PRO            // reverse the table, which is quicker
PRO            sorttable.reverse(this.sorttable_tbody);
PRO            this.className = this.className.replace('sorttable_sorted',
PRO                                                    'sorttable_sorted_reverse');
PRO            this.removeChild(document.getElementById('sorttable_sortfwdind'));
PRO            sortrevind = document.createElement('span');
PRO            sortrevind.id = "sorttable_sortrevind";
PRO            sortrevind.innerHTML = stIsIE ? '&nbsp<font face="webdings">5</font>' : '&nbsp;&#x25B4;';
PRO            this.appendChild(sortrevind);
PRO            return;
PRO          }
PRO          if (this.className.search(/\bsorttable_sorted_reverse\b/) != -1) {
PRO            // if we're already sorted by this column in reverse, just
PRO            // re-reverse the table, which is quicker
PRO            sorttable.reverse(this.sorttable_tbody);
PRO            this.className = this.className.replace('sorttable_sorted_reverse',
PRO                                                    'sorttable_sorted');
PRO            this.removeChild(document.getElementById('sorttable_sortrevind'));
PRO            sortfwdind = document.createElement('span');
PRO            sortfwdind.id = "sorttable_sortfwdind";
PRO            sortfwdind.innerHTML = stIsIE ? '&nbsp<font face="webdings">6</font>' : '&nbsp;&#x25BE;';
PRO            this.appendChild(sortfwdind);
PRO            return;
PRO          }
PRO
PRO          // remove sorttable_sorted classes
PRO          theadrow = this.parentNode;
PRO          forEach(theadrow.childNodes, function(cell) {
PRO            if (cell.nodeType == 1) { // an element
PRO              cell.className = cell.className.replace('sorttable_sorted_reverse','');
PRO              cell.className = cell.className.replace('sorttable_sorted','');
PRO            }
PRO          });
PRO          sortfwdind = document.getElementById('sorttable_sortfwdind');
PRO          if (sortfwdind) { sortfwdind.parentNode.removeChild(sortfwdind); }
PRO          sortrevind = document.getElementById('sorttable_sortrevind');
PRO          if (sortrevind) { sortrevind.parentNode.removeChild(sortrevind); }
PRO
PRO          this.className += ' sorttable_sorted';
PRO          sortfwdind = document.createElement('span');
PRO          sortfwdind.id = "sorttable_sortfwdind";
PRO          sortfwdind.innerHTML = stIsIE ? '&nbsp<font face="webdings">6</font>' : '&nbsp;&#x25BE;';
PRO          this.appendChild(sortfwdind);
PRO
PRO          // build an array to sort. This is a Schwartzian transform thing,
PRO          // i.e., we "decorate" each row with the actual sort key,
PRO          // sort based on the sort keys, and then put the rows back in order
PRO          // which is a lot faster because you only do getInnerText once per row
PRO          row_array = [];
PRO          col = this.sorttable_columnindex;
PRO          rows = this.sorttable_tbody.rows;
PRO          for (var j=0; j<rows.length; j++) {
PRO            row_array[row_array.length] = [sorttable.getInnerText(rows[j].cells[col]), rows[j]];
PRO          }
PRO          /* If you want a stable sort, uncomment the following line */
PRO          //sorttable.shaker_sort(row_array, this.sorttable_sortfunction);
PRO          /* and comment out this one */
PRO          row_array.sort(this.sorttable_sortfunction);
PRO
PRO          tb = this.sorttable_tbody;
PRO          for (var j=0; j<row_array.length; j++) {
PRO            tb.appendChild(row_array[j][1]);
PRO          }
PRO
PRO          delete row_array;
PRO        });
PRO      }
PRO    }
PRO  },
PRO
PRO  guessType: function(table, column) {
PRO    // guess the type of a column based on its first non-blank row
PRO    sortfn = sorttable.sort_alpha;
PRO    for (var i=0; i<table.tBodies[0].rows.length; i++) {
PRO      text = sorttable.getInnerText(table.tBodies[0].rows[i].cells[column]);
PRO      if (text != '') {
PRO        if (text.match(/^-?[£$¤]?[\d,.]+%?$/)) {
PRO          return sorttable.sort_numeric;
PRO        }
PRO        // check for a date: dd/mm/yyyy or dd/mm/yy
PRO        // can have / or . or - as separator
PRO        // can be mm/dd as well
PRO        possdate = text.match(sorttable.DATE_RE)
PRO        if (possdate) {
PRO          // looks like a date
PRO          first = parseInt(possdate[1]);
PRO          second = parseInt(possdate[2]);
PRO          if (first > 12) {
PRO            // definitely dd/mm
PRO            return sorttable.sort_ddmm;
PRO          } else if (second > 12) {
PRO            return sorttable.sort_mmdd;
PRO          } else {
PRO            // looks like a date, but we can't tell which, so assume
PRO            // that it's dd/mm (English imperialism!) and keep looking
PRO            sortfn = sorttable.sort_ddmm;
PRO          }
PRO        }
PRO      }
PRO    }
PRO    return sortfn;
PRO  },
PRO
PRO  getInnerText: function(node) {
PRO    // gets the text we want to use for sorting for a cell.
PRO    // strips leading and trailing whitespace.
PRO    // this is *not* a generic getInnerText function; it's special to sorttable.
PRO    // for example, you can override the cell text with a customkey attribute.
PRO    // it also gets .value for <input> fields.
PRO
PRO    if (!node) return "";
PRO
PRO    hasInputs = (typeof node.getElementsByTagName == 'function') &&
PRO                 node.getElementsByTagName('input').length;
PRO
PRO    if (node.getAttribute("sorttable_customkey") != null) {
PRO      return node.getAttribute("sorttable_customkey");
PRO    }
PRO    else if (typeof node.textContent != 'undefined' && !hasInputs) {
PRO      return node.textContent.replace(/^\s+|\s+$/g, '');
PRO    }
PRO    else if (typeof node.innerText != 'undefined' && !hasInputs) {
PRO      return node.innerText.replace(/^\s+|\s+$/g, '');
PRO    }
PRO    else if (typeof node.text != 'undefined' && !hasInputs) {
PRO      return node.text.replace(/^\s+|\s+$/g, '');
PRO    }
PRO    else {
PRO      switch (node.nodeType) {
PRO        case 3:
PRO          if (node.nodeName.toLowerCase() == 'input') {
PRO            return node.value.replace(/^\s+|\s+$/g, '');
PRO          }
PRO        case 4:
PRO          return node.nodeValue.replace(/^\s+|\s+$/g, '');
PRO          break;
PRO        case 1:
PRO        case 11:
PRO          var innerText = '';
PRO          for (var i = 0; i < node.childNodes.length; i++) {
PRO            innerText += sorttable.getInnerText(node.childNodes[i]);
PRO          }
PRO          return innerText.replace(/^\s+|\s+$/g, '');
PRO          break;
PRO        default:
PRO          return '';
PRO      }
PRO    }
PRO  },
PRO
PRO  reverse: function(tbody) {
PRO    // reverse the rows in a tbody
PRO    newrows = [];
PRO    for (var i=0; i<tbody.rows.length; i++) {
PRO      newrows[newrows.length] = tbody.rows[i];
PRO    }
PRO    for (var i=newrows.length-1; i>=0; i--) {
PRO       tbody.appendChild(newrows[i]);
PRO    }
PRO    delete newrows;
PRO  },
PRO
PRO  /* sort functions
PRO     each sort function takes two parameters, a and b
PRO     you are comparing a[0] and b[0] */
PRO  sort_numeric: function(a,b) {
PRO    aa = parseFloat(a[0].replace(/[^0-9.-]/g,''));
PRO    if (isNaN(aa)) aa = 0;
PRO    bb = parseFloat(b[0].replace(/[^0-9.-]/g,''));
PRO    if (isNaN(bb)) bb = 0;
PRO    return aa-bb;
PRO  },
PRO  sort_alpha: function(a,b) {
PRO    if (a[0]==b[0]) return 0;
PRO    if (a[0]<b[0]) return -1;
PRO    return 1;
PRO  },
PRO  sort_ddmm: function(a,b) {
PRO    mtch = a[0].match(sorttable.DATE_RE);
PRO    y = mtch[3]; m = mtch[2]; d = mtch[1];
PRO    if (m.length == 1) m = '0'+m;
PRO    if (d.length == 1) d = '0'+d;
PRO    dt1 = y+m+d;
PRO    mtch = b[0].match(sorttable.DATE_RE);
PRO    y = mtch[3]; m = mtch[2]; d = mtch[1];
PRO    if (m.length == 1) m = '0'+m;
PRO    if (d.length == 1) d = '0'+d;
PRO    dt2 = y+m+d;
PRO    if (dt1==dt2) return 0;
PRO    if (dt1<dt2) return -1;
PRO    return 1;
PRO  },
PRO  sort_mmdd: function(a,b) {
PRO    mtch = a[0].match(sorttable.DATE_RE);
PRO    y = mtch[3]; d = mtch[2]; m = mtch[1];
PRO    if (m.length == 1) m = '0'+m;
PRO    if (d.length == 1) d = '0'+d;
PRO    dt1 = y+m+d;
PRO    mtch = b[0].match(sorttable.DATE_RE);
PRO    y = mtch[3]; d = mtch[2]; m = mtch[1];
PRO    if (m.length == 1) m = '0'+m;
PRO    if (d.length == 1) d = '0'+d;
PRO    dt2 = y+m+d;
PRO    if (dt1==dt2) return 0;
PRO    if (dt1<dt2) return -1;
PRO    return 1;
PRO   },
PRO 
PRO   shaker_sort: function(list, comp_func) {
PRO     // A stable sort function to allow multi-level sorting of data
PRO     // see: http://en.wikipedia.org/wiki/Cocktail_sort
PRO     // thanks to Joseph Nahmias
PRO     var b = 0;
PRO     var t = list.length - 1;
PRO     var swap = true;
PRO 
PRO     while(swap) {
PRO         swap = false;
PRO         for(var i = b; i < t; ++i) {
PRO             if ( comp_func(list[i], list[i+1]) > 0 ) {
PRO                 var q = list[i]; list[i] = list[i+1]; list[i+1] = q;
PRO                 swap = true;
PRO             }
PRO         } // for
PRO         t--;
PRO 
PRO         if (!swap) break;
PRO 
PRO         for(var i = t; i > b; --i) {
PRO             if ( comp_func(list[i], list[i-1]) < 0 ) {
PRO                 var q = list[i]; list[i] = list[i-1]; list[i-1] = q;
PRO                 swap = true;
PRO             }
PRO         } // for
PRO         b++;
PRO 
PRO     } // while(swap)
PRO   }
PRO }
PRO 
PRO /* ******************************************************************
PRO    Supporting functions: bundled here to avoid depending on a library
PRO    ****************************************************************** */
PRO 
PRO // Dean Edwards/Matthias Miller/John Resig
PRO 
PRO /* for Mozilla/Opera9 */
PRO if (document.addEventListener) {
PRO     document.addEventListener("DOMContentLoaded", sorttable.init, false);
PRO }
PRO 
PRO /* for Internet Explorer */
PRO /*@cc_on @*/
PRO /*@if (@_win32)
PRO     document.write("<script id=__ie_onload defer src=javascript:void(0)><\/script>");
PRO     var script = document.getElementById("__ie_onload");
PRO     script.onreadystatechange = function() {
PRO         if (this.readyState == "complete") {
PRO             sorttable.init(); // call the onload handler
PRO         }
PRO     };
PRO /*@end @*/
PRO 
PRO /* for Safari */
PRO if (/WebKit/i.test(navigator.userAgent)) { // sniff
PRO     var _timer = setInterval(function() {
PRO         if (/loaded|complete/.test(document.readyState)) {
PRO             sorttable.init(); // call the onload handler
PRO         }
PRO     }, 10);
PRO }
PRO 
PRO /* for other browsers */
PRO window.onload = sorttable.init;
PRO 
PRO // written by Dean Edwards, 2005
PRO // with input from Tino Zijdel, Matthias Miller, Diego Perini
PRO 
PRO // http://dean.edwards.name/weblog/2005/10/add-event/
PRO 
PRO function dean_addEvent(element, type, handler) {
PRO   if (element.addEventListener) {
PRO     element.addEventListener(type, handler, false);
PRO   } else {
PRO     // assign each event handler a unique ID
PRO     if (!handler.$$guid) handler.$$guid = dean_addEvent.guid++;
PRO     // create a hash table of event types for the element
PRO     if (!element.events) element.events = {};
PRO     // create a hash table of event handlers for each element/event pair
PRO     var handlers = element.events[type];
PRO     if (!handlers) {
PRO       handlers = element.events[type] = {};
PRO       // store the existing event handler (if there is one)
PRO       if (element["on" + type]) {
PRO         handlers[0] = element["on" + type];
PRO       }
PRO     }
PRO     // store the event handler in the hash table
PRO     handlers[handler.$$guid] = handler;
PRO     // assign a global event handler to do all the work
PRO     element["on" + type] = handleEvent;
PRO   }
PRO };
PRO // a counter used to create unique IDs
PRO dean_addEvent.guid = 1;
PRO 
PRO function removeEvent(element, type, handler) {
PRO   if (element.removeEventListener) {
PRO     element.removeEventListener(type, handler, false);
PRO   } else {
PRO     // delete the event handler from the hash table
PRO     if (element.events && element.events[type]) {
PRO       delete element.events[type][handler.$$guid];
PRO     }
PRO   }
PRO };
PRO 
PRO function handleEvent(event) {
PRO   var returnValue = true;
PRO   // grab the event object (IE uses a global event object)
PRO   event = event || fixEvent(((this.ownerDocument || this.document || this).parentWindow || window).event);
PRO   // get a reference to the hash table of event handlers
PRO   var handlers = this.events[event.type];
PRO   // execute each event handler
PRO   for (var i in handlers) {
PRO     this.$$handleEvent = handlers[i];
PRO     if (this.$$handleEvent(event) === false) {
PRO       returnValue = false;
PRO     }
PRO   }
PRO   return returnValue;
PRO };
PRO 
PRO function fixEvent(event) {
PRO   // add W3C standard event methods
PRO   event.preventDefault = fixEvent.preventDefault;
PRO   event.stopPropagation = fixEvent.stopPropagation;
PRO   return event;
PRO };
PRO fixEvent.preventDefault = function() {
PRO   this.returnValue = false;
PRO };
PRO fixEvent.stopPropagation = function() {
PRO   this.cancelBubble = true;
PRO }
PRO 
PRO // Dean's forEach: http://dean.edwards.name/base/forEach.js
PRO /*
PRO   forEach, version 1.0
PRO   Copyright 2006, Dean Edwards
PRO   License: http://www.opensource.org/licenses/mit-license.php
PRO */
PRO 
PRO // array-like enumeration
PRO if (!Array.forEach) { // mozilla already supports this
PRO   Array.forEach = function(array, block, context) {
PRO     for (var i = 0; i < array.length; i++) {
PRO       block.call(context, array[i], i, array);
PRO     }
PRO   };
PRO }
PRO 
PRO // generic enumeration
PRO Function.prototype.forEach = function(object, block, context) {
PRO   for (var key in object) {
PRO     if (typeof this.prototype[key] == "undefined") {
PRO       block.call(context, object[key], key, object);
PRO     }
PRO   }
PRO };
PRO 
PRO // character enumeration
PRO String.forEach = function(string, block, context) {
PRO   Array.forEach(string.split(""), function(chr, index) {
PRO     block.call(context, chr, index, string);
PRO   });
PRO };
PRO 
PRO // globally resolve forEach enumeration
PRO var forEach = function(object, block, context) {
PRO   if (object) {
PRO     var resolve = Object; // default
PRO     if (object instanceof Function) {
PRO       // functions have a "length" property
PRO       resolve = Function;
PRO     } else if (object.forEach instanceof Function) {
PRO       // the object implements a custom forEach method so use that
PRO       object.forEach(block, context);
PRO       return;
PRO     } else if (typeof object == "string") {
PRO       // the object is a string
PRO       resolve = String;
PRO     } else if (typeof object.length == "number") {
PRO       // the object is array-like
PRO       resolve = Array;
PRO     }
PRO     resolve.forEach(object, block, context);
PRO   }
PRO };
SPO OFF
SET DEF ON

--v$sql driver
SPO pathfinder_&&pathfinder_file_time._vsql.sql
PRO PRO <html>
PRO PRO <head>
PRO PRO <link rel="icon" href="pathfinder_favicon.ico">
PRO PRO <title>&&title.</title>
PRO PRO
PRO PRO <style type="text/css">
PRO PRO body          {font:10pt Arial,Helvetica,Geneva,sans-serif; color:black; background:white;}
PRO PRO h1            {font-size:16pt; font-weight:bold; color:#336699; border-bottom:1px solid #cccc99; margin-top:0pt; margin-bottom:0pt; padding:0px 0px 0px 0px;}
PRO PRO h2            {font-size:14pt; font-weight:bold; color:#336699; margin-top:4pt; margin-bottom:0pt;}
PRO PRO h3            {font-size:12pt; font-weight:bold; color:#336699; margin-top:4pt; margin-bottom:0pt;}
PRO PRO pre           {font:8pt monospace,Monaco,"Courier New",Courier;}
PRO PRO a             {color:#663300;}
PRO PRO table         {font-size:8pt; border-collapse:collapse; empty-cells:show; white-space:nowrap; border:1px solid #cccc99;}
PRO PRO li            {font-size:8pt; color:black; padding-left:4px; padding-right:4px; padding-bottom:2px;}
PRO PRO th            {font-weight:bold; color:white; background:#0066CC; padding-left:4px; padding-right:4px; padding-bottom:2px;}
PRO PRO tr            {color:black; background:#fcfcf0;}
PRO PRO tr.main       {color:black; background:#fcfcf0;}
PRO PRO td            {vertical-align:top; border:1px solid #cccc99;}
PRO PRO td.c          {text-align:center;}
PRO PRO tr.main:hover { background:#0066CC; color:white;}
PRO PRO font.n        {font-size:8pt; font-style:italic; color:#336699;}
PRO PRO font.f        {font-size:8pt; color:#999999; border-top:1px solid #cccc99; margin-top:30pt;}
PRO PRO </style>
PRO PRO <script src="sorttable.js"></script>
PRO PRO </head>
PRO PRO <body>
PRO PRO <h1><em>Pathfinder</em> &&pathfinder_vrsn.: Plan Finder - V$SQL Details</h1>
PRO PRO <pre>dbname:&&database_name_short. connect string:&&pathfinder_conn. startime:&&plnfdn_start_time.</pre>
PRO SET LIN 32767 PAGES 100 LONG 32767000 LONGC 32767 TRIMS ON AUTOT OFF MARKUP HTML ON TABLE "class=sortable"
PRO COL SQL_TEXT NOPRI
PRO COL SQL_FULLTEXT NOPRI
PRO COL OPTIMIZER_ENV NOPRI
PRO SELECT *
PRO   FROM gv$sql
PRO  WHERE sql_text like '%^1%' AND sql_text NOT LIKE '%not me%'
PRO    ^2
PRO  ORDER BY sql_id, child_number
PRO /
PRO SET MARKUP HTML OFF
PRO COL SQL_TEXT PRI
PRO COL SQL_FULLTEXT PRI
PRO COL OPTIMIZER_ENV PRI
PRO PRO </table>
PRO PRO </body>
PRO PRO </html>
PRO SPO OFF
SPO OFF

-- xplan driver
SPO pathfinder_&&pathfinder_file_time._xplan.sql
PRO COL inst_child FOR A21
PRO BREAK ON inst_child SKIP 2
PRO SET LIN 32767 PAGES 0 LONG 32767000 LONGC 32767 TRIMS ON AUTOT OFF;
PRO WITH v AS (
PRO SELECT /*+ MATERIALIZE */ DISTINCT sql_id, inst_id, child_number
PRO   FROM gv$sql
PRO  WHERE sql_text like '%^1%' AND sql_text NOT LIKE '%not me%'
PRO    ^2
PRO    AND loaded_versions > 0
PRO  ORDER BY 1, 2, 3 )
PRO SELECT /*+ ORDERED USE_NL(t) */
PRO        RPAD('Inst: '||v.inst_id, 9)||' '||RPAD('Child: '||v.child_number, 11) inst_child, 
PRO        t.plan_table_output
PRO   FROM v, TABLE(DBMS_XPLAN.DISPLAY('gv$sql_plan_statistics_all', NULL, 'ADVANCED ALLSTATS LAST', 
PRO        'inst_id = '||v.inst_id||' AND sql_id = '''||v.sql_id||''' AND child_number = '||v.child_number)) t
PRO /
PRO SPO OFF
SPO OFF

-- driver
SPO pathfinder_&&pathfinder_file_time._driver.sql
DECLARE
  l_unique_id              VARCHAR2(200);
  l_test_id                NUMBER := 0;
  l_test_id_rp_i           NUMBER := 0;
  l_spoolfile_name_p       VARCHAR2(100);
  l_spoolfile_name_vs      VARCHAR2(100); 
  l_spoolfile_name_rp_i_p  VARCHAR2(100);
  l_spoolfile_name_rp_i_vs VARCHAR2(100); 
  l_alter_session          VARCHAR2(4000);
  l_alter_session_bck      VARCHAR2(4000);
  l_skip_string_script     VARCHAR2(4000);
  l_skip_string_driver     VARCHAR2(4000);
  l_child_list             VARCHAR2(4000);

  PROCEDURE put (p_line IN VARCHAR2)
  IS
  BEGIN
    DBMS_OUTPUT.PUT_LINE(p_line);
  END put;

  PROCEDURE print_test (p_alter_session IN VARCHAR2)
  IS
  BEGIN

    l_test_id :=  l_test_id + 1;
    l_unique_id := 'pathfinder_{ &&pathfinder_file_time ('||LPAD(l_test_id, 5, '0')||')'; 
    l_spoolfile_name_p := LPAD(l_test_id, 5, '0')||'_&&common_pathfinder_prefix._plan.txt';  
    l_spoolfile_name_vs := LPAD(l_test_id, 5, '0')||'_&&common_pathfinder_prefix._vsql.html'; 

    put('--');
    put('CONN &&pathfinder_conn.');
    put('ALTER SESSION SET STATISTICS_LEVEL = ALL;');
    put('SET TERM OFF');
    put('SELECT TO_CHAR(sysdate,''hh24:mi:ss'') current_time FROM DUAL;');
    put('SET TERM ON');
    put('PRO '||l_test_id||') "'||l_unique_id||'" ^^current_time. '||replace(p_alter_session,'ALTER SESSION SET',''));
    put('SET TERM OFF FEED OFF TIMI OFF');
    put('DEF pathfinder_testid = "'||l_unique_id||'"');

    IF (p_alter_session != 'BASELINE') THEN
    	put(p_alter_session);  
    END IF;

    put('@&&pathfinder_script.');             
    -- used to avoid running a SQL multiple times if the first plan generated is the same as the baseline
    put('SELECT NULL skip_cfb FROM DUAL;');
    IF (p_alter_session = 'BASELINE') THEN
      put('SELECT /* not me */ plan_hash_value baseline_phv FROM v$sql WHERE sql_text like ''%'||l_unique_id||'%'' AND sql_text NOT LIKE ''%not me%'';');
      put('SELECT /* not me */ child_number child_number_, plan_hash_value, ''<tr class="main"><td align=right>'||l_test_id||'</td><td align=right></td><td>'||replace(p_alter_session,chr(39),chr(39)||chr(39))||'</td><td align=right>''||plan_hash_value||''</td><td align=right>''||ROUND(elapsed_time/1e6,6)||''</td><td align=right>''||ROUND(cpu_time/1e6,6)||''</td><td align=right>''||buffer_gets||''</td><td align=right>''||rows_processed||''</td><td><a href="'||l_spoolfile_name_p||'">plan</a></td><td><a href="'||l_spoolfile_name_vs||'">details</a></td></tr>'' html_row FROM v$sql WHERE sql_text like ''%'||l_unique_id||'%'' AND sql_text NOT LIKE ''%not me%'';');
    ELSE
      put('SELECT /* not me */ child_number child_number_, plan_hash_value, CASE WHEN plan_hash_value = ^^baseline_phv. THEN ''--'' ELSE NULL END skip_cfb, ''<tr class="main"><td align=right>'||l_test_id||'</td><td align=right></td><td>'||replace(p_alter_session,chr(39),chr(39)||chr(39))||'</td><td align=right>''||plan_hash_value||''</td><td align=right>''||ROUND(elapsed_time/1e6,6)||''</td><td align=right>''||ROUND(cpu_time/1e6,6)||''</td><td align=right>''||buffer_gets||''</td><td align=right>''||rows_processed||''</td><td><a href="'||l_spoolfile_name_p||'">plan</a></td><td><a href="'||l_spoolfile_name_vs||'">details</a></td></tr>'' html_row FROM v$sql WHERE sql_text like ''%'||l_unique_id||'%'' AND sql_text NOT LIKE ''%not me%'';'); 
    END IF;
    put('SPO &&pathfinder_main_report..html APP;');
    put('PRO ^^html_row.');
    put('SPO OFF');
    put('SPO '||l_spoolfile_name_p);
    put('@pathfinder_&&pathfinder_file_time._xplan.sql "'||l_unique_id||'" "AND 1=1"');
    put('SPO OFF');
    put('SPO '||l_spoolfile_name_vs);
    put('@pathfinder_&&pathfinder_file_time._vsql.sql "'||l_unique_id||'" "AND 1=1"');
    put('SPO OFF');


    FOR i IN 1..4 LOOP
      l_test_id_rp_i := l_test_id + (i/10);
      l_spoolfile_name_rp_i_p    := LPAD(l_test_id_rp_i, 5, '0')||'_&&common_pathfinder_prefix._plan.txt'; 
      l_spoolfile_name_rp_i_vs := LPAD(l_test_id_rp_i, 5, '0')||'_&&common_pathfinder_prefix._vsql.html'; 
      l_skip_string_script     := '^^skip_cfb.';
      l_skip_string_driver     := '^^skip_cfb.';
      FOR j IN 1..i LOOP
        IF (i > 1) THEN
          l_skip_string_script := l_skip_string_script||'^^skip_execution_rp'||(i-1)||'.';
        END IF;
        l_skip_string_driver := l_skip_string_driver||'^^skip_execution_rp'||j||'.';
      END LOOP;
      put('@'||l_skip_string_script||'&&pathfinder_script.'); 
      put('SELECT ''--'' skip_execution_rp'||i||', 0 plan_hash_value_rp'||i||', 0 elapsed_time_rp'||i||', 0 cpu_time_rp'||i||', 0 buffer_gets_rp'||i||', 0 child_number_rp'||i||', 0 rows_processed_rp'||i||' FROM dual;'); 
      put('SELECT /* not me */ CASE WHEN (plan_hash_value <> ^^plan_hash_value'||CASE i WHEN 1 THEN NULL ELSE '_rp'||(i-1) END||'. AND ''^^skip_cfb'' IS NULL) THEN NULL ELSE ''--'' END skip_execution_rp'||i||', child_number child_number_rp'||i||', plan_hash_value plan_hash_value_rp'||i||', ''<tr class="main"><td align=right>'||l_test_id||'</td><td align=right>'||l_test_id_rp_i||'</td><td>'||replace(p_alter_session,chr(39),chr(39)||chr(39))||'</td><td align=right>''||plan_hash_value||''</td><td align=right>''||ROUND(elapsed_time/1e6,6)||''</td><td align=right>''||ROUND(cpu_time/1e6,6)||''</td><td align=right>''||buffer_gets||''</td><td align=right>''||rows_processed||''</td><td><a href="'||l_spoolfile_name_rp_i_p||'">plan</a></td><td><a href="'||l_spoolfile_name_rp_i_vs||'">details</a></td></tr>'' html_row ');
      put('  FROM v$sql WHERE child_number NOT IN (^^child_number_. ');
      CASE i WHEN 1 THEN NULL;
             WHEN 2 THEN put(', ^^child_number_rp1. '); 
             WHEN 3 THEN put(', ^^child_number_rp1., ^^child_number_rp2.');
             WHEN 4 THEN put(', ^^child_number_rp1., ^^child_number_rp2., ^^child_number_rp3.');
      END CASE;
      put(' )  ');
      put('  AND sql_text like ''%'||l_unique_id||'%'' AND sql_text NOT LIKE ''%not me%'';');
      put('SPO s'||l_test_id_rp_i||'_driver.sql');
      put('SET SERVEROUT ON SIZE 1000000;');
      put('SET SERVEROUT ON SIZE UNL;');
      put('PRO SPO &&pathfinder_main_report..html APP;');
      put('PRO PRO ^^html_row.');
      put('PRO SPO OFF;');
      put('SET SERVEROUT OFF');
      put('SPO OFF');
      put('@'||l_skip_string_driver||'s'||l_test_id_rp_i||'_driver.sql');    
      put('HOS rm s'||l_test_id_rp_i||'_driver.sql');
      put('SPO s'||l_test_id_rp_i||'_p_driver.sql');  
      put('PRO SPO '||l_spoolfile_name_rp_i_p);  
 
      l_child_list := 'AND child_number NOT IN ( ^^child_number_. '||CASE i WHEN 1 THEN NULL
                                           WHEN 2 THEN ', ^^child_number_rp1. ' 
                                           WHEN 3 THEN ', ^^child_number_rp1., ^^child_number_rp2. '
                                           WHEN 4 THEN ', ^^child_number_rp1., ^^child_number_rp2., ^^child_number_rp3.'
                                    END||' )';    

      put('PRO @pathfinder_&&pathfinder_file_time._xplan.sql "'||l_unique_id||'" "'||l_child_list||'"'); 
   
      put('SPO OFF');  
      put('@'||l_skip_string_driver||'s'||l_test_id_rp_i||'_p_driver.sql');    
      put('HOS rm s'||l_test_id_rp_i||'_p_driver.sql'); 

      put('SPO s'||l_test_id_rp_i||'_vs_driver.sql');  
      put('PRO SPO '||l_spoolfile_name_rp_i_vs);  
 
      l_child_list := 'AND child_number NOT IN ( ^^child_number_. '||CASE i WHEN 1 THEN NULL
                                           WHEN 2 THEN ', ^^child_number_rp1. ' 
                                           WHEN 3 THEN ', ^^child_number_rp1., ^^child_number_rp2. '
                                           WHEN 4 THEN ', ^^child_number_rp1., ^^child_number_rp2., ^^child_number_rp3.'
                                    END||' )';    

      put('PRO @pathfinder_&&pathfinder_file_time._vsql.sql "'||l_unique_id||'" "'||l_child_list||'"'); 
   
      put('SPO OFF');  
      put('@'||l_skip_string_driver||'s'||l_test_id_rp_i||'_vs_driver.sql');    
      put('HOS rm s'||l_test_id_rp_i||'_vs_driver.sql'); 

      
    END LOOP;

    put('HOS zip -mq &&common_pathfinder_prefix..zip *&&common_pathfinder_prefix.*txt');  
    put('HOS zip -mq &&common_pathfinder_prefix..zip *&&common_pathfinder_prefix.*vsql.html');  
    put('HOS zip -q &&common_pathfinder_prefix..zip *&&common_pathfinder_prefix.*html'); 
 

  END print_test;


BEGIN          

      put('SET DEF ^');
      put('COL plan_hash_value NEW_V plan_hash_value');      
      put('COL child_number_ NEW_V child_number_');  
      put('--');  
      put('COL skip_execution_rp1 NEW_V skip_execution_rp1');      
      put('COL plan_hash_value_rp1 NEW_V plan_hash_value_rp1');       
      put('COL child_number_rp1 NEW_V child_number_rp1'); 
      put('--');
      put('COL skip_execution_rp2 NEW_V skip_execution_rp2');      
      put('COL plan_hash_value_rp2 NEW_V plan_hash_value_rp2');        
      put('COL child_number_rp2 NEW_V child_number_rp2'); 
      put('--');
      put('COL skip_execution_rp3 NEW_V skip_execution_rp3');      
      put('COL plan_hash_value_rp3 NEW_V plan_hash_value_rp3');        
      put('COL child_number_rp3 NEW_V child_number_rp3'); 
      put('--');
      put('COL skip_execution_rp4 NEW_V skip_execution_rp4');      
      put('COL plan_hash_value_rp4 NEW_V plan_hash_value_rp4');        
      put('COL child_number_rp4 NEW_V child_number_rp4');    
      put('--');
      put('COL skip_cfb NEW_V skip_cfb');
      put('COL html_row NEW_V html_row'); 
      put('COL current_time NEW_V current_time');
      put('COL baseline_phv NEW_V baseline_phv'); 

      print_test('BASELINE');

      FOR i IN (WITH cbo_param AS (
                SELECT /*+ materialize */ pname_qksceserow name
                  FROM x$qksceses
                 WHERE sid_qksceserow = SYS_CONTEXT('USERENV', 'SID')
                )
                SELECT x.indx+1 num,
                       x.ksppinm name,
                       x.ksppity type,
                       y.ksppstvl value,
                       y.ksppstdvl display_value,
                       y.ksppstdf isdefault,
                       x.ksppdesc description,
                       y.ksppstcmnt update_comment,
                       x.ksppihash hash
                  FROM x$ksppi x,
                       x$ksppcv y,
                       cbo_param
                 WHERE x.indx = y.indx
                   AND BITAND(x.ksppiflg, 268435456) = 0
                   AND TRANSLATE(x.ksppinm, '_', '#') NOT LIKE '##%'
                   AND x.ksppinm = cbo_param.name
                   AND x.inst_id = USERENV('Instance')
                   AND DECODE(BITAND(x.ksppiflg/256, 1), 1, 'TRUE', 'FALSE') = 'TRUE'
                   AND x.ksppity IN (1, 2, 3)
                 ORDER BY x.ksppinm) LOOP

          IF SUBSTR(i.name, 1, 1) = CHR(95) THEN -- "_"
            l_alter_session := 'ALTER SESSION SET "'||i.name||'" = ';
          ELSE
            l_alter_session := 'ALTER SESSION SET '||i.name||' = ';
          END IF;

          IF i.type = 1 THEN -- Boolean

            IF LOWER(i.value) = 'true' THEN
              l_alter_session := l_alter_session||' FALSE;';
            ELSIF LOWER(i.value) = 'false' THEN
              l_alter_session := l_alter_session||' TRUE;';
            ELSE
              put('--');
              put('-- skip test on '||i.name||'. baseline value: '||i.value);
            END IF;

            print_test(l_alter_session);

          ELSIF i.type = 2 THEN -- String

            -- this is used as base ALTER SESSION for the LOV
            l_alter_session_bck := l_alter_session;

            FOR j IN (SELECT value_kspvld_values value
                        FROM x$kspvld_values
                       WHERE LOWER(name_kspvld_values) = i.name
                         AND LOWER(value_kspvld_values) <> i.value
                       ORDER BY value_kspvld_values)
            LOOP
              l_alter_session := l_alter_session_bck||' '''||j.value||''';';
              print_test(l_alter_session);
            END LOOP;
        
          ELSIF i.type = 3 THEN -- Integer

            l_alter_session_bck := l_alter_session;

            IF i.name = 'optimizer_index_cost_adj' THEN
              l_alter_session := l_alter_session_bck||'1;';
              print_test(l_alter_session);
              l_alter_session := l_alter_session_bck||'10;';
              print_test(l_alter_session);
              l_alter_session := l_alter_session_bck||'25;';
              print_test(l_alter_session);
              l_alter_session := l_alter_session_bck||'50;';
              print_test(l_alter_session);
              l_alter_session := l_alter_session_bck||'100;';
              print_test(l_alter_session);
              l_alter_session := l_alter_session_bck||'200;';
              print_test(l_alter_session);
              l_alter_session := l_alter_session_bck||'400;';
              print_test(l_alter_session);
              l_alter_session := l_alter_session_bck||'1000;';
              print_test(l_alter_session);
              l_alter_session := l_alter_session_bck||'10000;';
              print_test(l_alter_session);
            ELSIF i.name = 'optimizer_index_caching' THEN
              l_alter_session := l_alter_session_bck||'0;';
              print_test(l_alter_session);
              l_alter_session := l_alter_session_bck||'12;';
              print_test(l_alter_session);
              l_alter_session := l_alter_session_bck||'25;';
              print_test(l_alter_session);
              l_alter_session := l_alter_session_bck||'50;';
              print_test(l_alter_session);
              l_alter_session := l_alter_session_bck||'100;';
              print_test(l_alter_session);
            ELSIF i.name = 'optimizer_dynamic_sampling' THEN
              l_alter_session := l_alter_session_bck|| '0;';
              print_test(l_alter_session);
              l_alter_session := l_alter_session_bck|| '2;';
              print_test(l_alter_session);
              l_alter_session := l_alter_session_bck|| '4;';
              print_test(l_alter_session);
              l_alter_session := l_alter_session_bck|| '6;';
              print_test(l_alter_session);
              l_alter_session := l_alter_session_bck|| '8;';
              print_test(l_alter_session);
              l_alter_session := l_alter_session_bck|| '10;';
              print_test(l_alter_session);
            ELSIF i.name IN ('hash_area_size', 'sort_area_size') THEN
              l_alter_session := l_alter_session_bck|| i.value * 2 ||';';
              print_test(l_alter_session);
              l_alter_session := l_alter_session_bck|| i.value * 8 ||';';
              print_test(l_alter_session);
              l_alter_session := l_alter_session_bck|| i.value * 32||';';
              print_test(l_alter_session);
            ELSIF i.name IN ('db_file_multiblock_read_count', '_db_file_optimizer_read_count') THEN
              l_alter_session := l_alter_session_bck|| '4;';
              print_test(l_alter_session);
              l_alter_session := l_alter_session_bck|| '8;';
              print_test(l_alter_session);
              l_alter_session := l_alter_session_bck|| '16;';
              print_test(l_alter_session);
              l_alter_session := l_alter_session_bck|| '32;';
              print_test(l_alter_session);
              l_alter_session := l_alter_session_bck|| '64;';
              print_test(l_alter_session);
              l_alter_session := l_alter_session_bck|| '128;';
              print_test(l_alter_session);
            ELSIF i.name = '_optimizer_max_permutations' THEN
              l_alter_session := l_alter_session_bck|| '100;';
              print_test(l_alter_session);
              l_alter_session := l_alter_session_bck|| '2000;';
              print_test(l_alter_session);
              l_alter_session := l_alter_session_bck|| '40000;';
              print_test(l_alter_session);
              l_alter_session := l_alter_session_bck|| '79999;';
              print_test(l_alter_session);
              l_alter_session := l_alter_session_bck|| '80000;';
              print_test(l_alter_session);
            ELSIF i.name = '_sort_elimination_cost_ratio' THEN
              l_alter_session := l_alter_session_bck|| '0;';
              print_test(l_alter_session);
              l_alter_session := l_alter_session_bck|| '3;';
              print_test(l_alter_session);
              l_alter_session := l_alter_session_bck|| '6;';
              print_test(l_alter_session);
              l_alter_session := l_alter_session_bck|| '12;';
              print_test(l_alter_session);
              l_alter_session := l_alter_session_bck|| '25;';
              print_test(l_alter_session);
              l_alter_session := l_alter_session_bck|| '50;';
              print_test(l_alter_session);
              l_alter_session := l_alter_session_bck|| '100;';
              print_test(l_alter_session);
              l_alter_session := l_alter_session_bck|| '1000;';
              print_test(l_alter_session);
            ELSIF i.name = '_optimizer_extended_stats_usage_control' THEN
              l_alter_session := l_alter_session_bck|| '255;'; -- FF through 10g
              print_test(l_alter_session);
              l_alter_session := l_alter_session_bck|| '240;'; -- F0 in 11.1.0.6
              print_test(l_alter_session);
              l_alter_session := l_alter_session_bck|| '224;'; -- E0 in 11.1.0.7-11.2.0.1
              print_test(l_alter_session);
              l_alter_session := l_alter_session_bck|| '192;'; -- C0 in 11.2.0.2+
              print_test(l_alter_session);
            ELSIF i.name = '_optimizer_fkr_index_cost_bias' THEN
              l_alter_session := l_alter_session_bck|| '2;';
              print_test(l_alter_session);
              l_alter_session := l_alter_session_bck|| '5;';
              print_test(l_alter_session);
              l_alter_session := l_alter_session_bck|| '10;';
              print_test(l_alter_session);
              l_alter_session := l_alter_session_bck|| '20;';
              print_test(l_alter_session);
            ELSE
              put('--');
              put('-- skip test on '||i.name||'. baseline value: '||i.value);
            END IF;



          END IF;


      END LOOP;

      FOR i IN (SELECT * FROM v$session_fix_control WHERE session_id = SYS_CONTEXT('USERENV', 'SID') ORDER BY bugno) LOOP

          IF i.value = 0 THEN
            l_alter_session := 'ALTER SESSION SET "_fix_control" = '''||i.bugno||':1'';';
          ELSIF i.value = 1 THEN
            l_alter_session := 'ALTER SESSION SET "_fix_control" = '''||i.bugno||':0'';';
          ELSE
            l_alter_session := 'ALTER SESSION SET "_fix_control" = '''||i.bugno||':0'';';
          END IF;

          print_test(l_alter_session);         

      END LOOP;

      put('SET DEF &');

END;
/
SPO OFF;
SET TERM ON
@pathfinder_&&pathfinder_file_time._driver.sql

COL plnfdn_end_time NEW_V plnfdn_end_time
SELECT TO_CHAR(SYSDATE, 'YYYY/MM/DD HH24:MI:SS') plnfdn_end_time FROM DUAL;

SPO &&pathfinder_main_report..html APP;  
PRO
PRO </table>
PRO <br>
PRO <pre>endtime:&&plnfdn_end_time.</pre>
PRO </body>
PRO </html>
SPO OFF

HOS zip -mq &&common_pathfinder_prefix..zip pathfinder_&&pathfinder_file_time._vsql.sql
HOS zip -mq &&common_pathfinder_prefix..zip pathfinder_&&pathfinder_file_time._xplan.sql
HOS zip -mq &&common_pathfinder_prefix..zip pathfinder_&&pathfinder_file_time._driver.sql 
HOS zip -q &&common_pathfinder_prefix..zip &&pathfinder_script.
HOS zip -mq &&common_pathfinder_prefix..zip sorttable.js
HOS zip -mq &&common_pathfinder_prefix..zip *&&common_pathfinder_prefix.*

SET TERM ON
PRO File &&common_pathfinder_prefix..zip created.
