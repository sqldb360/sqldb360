# edb360 collector
#!/bin/sh
echo "Start edb360."
type nawk 1>/dev/null 2>&1 && AWK=nawk || AWK=awk
for INST in $(ps axo cmd | $AWK '$0~/^ora_pmon_/ {gsub(/^ora_pmon_/,"",$0); print $0}'); do
        if [ -n "$( $AWK -F: -v inst=$INST '$1==inst {print $1}' /etc/oratab )" ]; then
                echo "$INST: instance name = db_unique_name (single instance database)"
                export ORACLE_SID=$INST; export ORAENV_ASK=NO; . oraenv
        else
                # remove last char (instance nr) and look for name again
                LAST_REMOVED="$( $AWK -F: -v inst=$INST '$1==substr(inst,0,length(inst)-1) {print $1}' /etc/oratab )"
                if [ -n "$LAST_REMOVED" ]; then
                        echo "$INST: instance name with last char removed = db_unique_name (RAC: instance number added)"
                        export ORACLE_SID=$LAST_REMOVED; export ORAENV_ASK=NO; . oraenv; export ORACLE_SID=$INST
                elif [ -n "$( echo $INST | $AWK '$0~/_[12]$/' )" ]; then
                        # remove last two chars (rac one node addition) and look for name again
                        LAST_TWO_REMOVED="$( $AWK -F: -v inst=$INST '$1==substr(inst,0,length(inst)-2) {print $1}' /etc/oratab )"
                        if [ -n "$LAST_TWO_REMOVED" ]; then
                                echo "$INST: instance name with either _1 or _2 removed = db_unique_name (RAC one node)"
                                export ORACLE_SID=$LAST_TWO_REMOVED; export ORAENV_ASK=NO; . oraenv; export ORACLE_SID=$INST
                        fi
                else
                        echo "couldn't find instance $INST in oratab"
                        continue
                fi
        fi

sqlplus -s /nolog <<EOF
connect / as sysdba

DEF ash_validation = '--skip--';
@sql/edb360_0a_main.sql T NULL
EOF

done

zip -m edb360_output.zip edb360_*.zip
zip -r osw_output.zip $(ps -ef | $AWK -F 'OSW' '$0~/OSW/ && $0~/FM/ {split($2,x," "); print x[3]}')
zip -m edb360_output.zip osw_output.zip

echo "End edb360 collector. Output: edb360_output.zip"
