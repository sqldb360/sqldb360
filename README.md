# SQLdb360

SQLdb360 is a "free to use toolset" to perform an initial assessment of an entire Oracle database or a particular SQL statement.
SQLdb360 is made of two independent tools, eDB360 (database-wide analysis) and SQLd360 (individual SQL analysis).

## Download
Remember to download the lastest *stable* release under "Releases". If you just use the download link you'll get the unstable version, newest features and fixes, but unstable

## Steps

1. Download the tool into target database server
2. Navigate to master directory and connect into SQLPlus as DBA or user with access to data dictionary
3. Execute edb360.sql (database view) or sqld360.sql (one SQL focus)
   - Both tools will prompt for the license available on the target database.
     - [T | D | N] For Tuning, Diagnostics or None
   - Both tools accept an optimal configuration file
   - SQLd360 requires the SQL ID of interest to be provided
4. Copy output zip to client (PC or Mac), unzip and open in browser file 00001_*_index.html

## Notes

1. eDB360 and SQLd360 run transparently on and support RAC, Exadata and In-Memory. In a multitenant environment, connect to PDB of interest.
2. No application data is collected, only metadata is accessed.
3. Both tools work in a "no evidence left behind" fashion, meaning there is no post execution step that needs to be executed, the tools clean after themselves.
4. It is recommended to download the latest version of the tool before using it, this is to minimize the impact of known bugs and benefit from latest features.

## Troubleshooting

edb360 takes up to 24 hours to execute on a large database. On smaller ones or on Exadata it may take a few hours or less. In rare cases it may require even more than 24 hrs.
By default, eDB360 executes a pre-check and asks for confirmation in case the execution is estimated to take more than 8 hours.
Multiple options are available to speed up large executions, for details refer to https://carlos-sierra.net/2017/04/10/edb360-meets-eadam-3-0-when-two-heads-are-better-than-one/

SQLd360 is generally faster, given the reduced scope, and as such no pre-check is executed.

## Contacts

For questions, feedbacks or issues please contact sqldb360@gmail.com

## License

  SQLdb360 - An open-source tool to diagnose Oracle Databases and SQL
  statements - originally developed by Carlos Sierra and Mauro Pagano.

  This program is free software: you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation, either version 3 of the License, or
  (at your option) any later version.

  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with this program.  If not, see <http://www.gnu.org/licenses/>.
