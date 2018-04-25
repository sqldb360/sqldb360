-- tkprof for trace from execution of tool in case someone reports slow performance in tool
HOS ls -lat &&edb360_udump_path.*ora_&&edb360_spid._&&edb360_tracefile_identifier..trc >> &&edb360_log3..txt
HOS tkprof &&edb360_udump_path.*ora_&&edb360_spid._&&edb360_tracefile_identifier..trc &&edb360_tkprof._sort.txt sort=prsela exeela fchela >> &&edb360_log3..txt
HOS zip -j &&edb360_zip_filename. &&edb360_tkprof._sort.txt >> &&edb360_log3..txt
