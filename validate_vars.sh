#!/bin/bash
scriptlist=$1
if [ ! -f "$scriptlist" ]; then
        echo "your file $scriptlist is not present"
        exit
fi



for script in $(cat $scriptlist | sort); do
        script=".${script}"
        work_copy="${script}.work_copy"

found=0
        MAIL_SUBJECT_SUCCESS=$(grep 'mail -s' $script | grep -v '#' | cut -d'"' -f2 | grep -i succ)
        lookfor=$(grep ^MAIL_SUBJECT_SUCCESS= $work_copy | cut -d'"' -f2)
        if [ "$MAIL_SUBJECT_SUCCESS" == "$lookfor" ]; then
                #echo "Found MAIL_SUBJECT_SUCCESS=\"$MAIL_SUBJECT_SUCCESS\""
                let found=$found+1
        else
                #echo "MAIL_SUBJECT_SUCCESS=\"$MAIL_SUBJECT_SUCCESS\" not found in the script"
                failmsg="MAIL_SUBJECT_SUCCESS=\"$MAIL_SUBJECT_SUCCESS\" not found in the script"
        fi

        MAIL_SUBJECT_FAILURE=$(grep 'mail -s' $script | grep -v '#' | cut -d'"' -f2 | grep -i fail)
        lookfor=$(grep ^MAIL_SUBJECT_FAILURE= $work_copy | cut -d'"' -f2)
        if [ "$MAIL_SUBJECT_FAILURE" == "$lookfor" ]; then
                #echo "Found MAIL_SUBJECT_FAILURE=\"$MAIL_SUBJECT_FAILURE\""
                let found=$found+1
        else
                #echo "MAIL_SUBJECT_FAILURE=\"$MAIL_SUBJECT_FAILURE\" not found in the script"
                failmsg="$failmsg,MAIL_SUBJECT_FAILURE=\"$MAIL_SUBJECT_FAILURE\" not found in the script"
        fi

ARCHIVE_KEEP_DAYS=$(grep 'mtime' $script | grep -v '#' | grep -i 'arch' | tr ' ' '\n' | grep -E '[+-][0-9]*' | sed -E 's/[+-]//' | grep '^[0-9]')
        lookfor=$(grep ^ARCHIVE_KEEP_DAYS= $work_copy | cut -d'"' -f2)
        if [ "$ARCHIVE_KEEP_DAYS" == "$lookfor" ]; then
                #echo "Found ARCHIVE_KEEP_DAYS=\"$ARCHIVE_KEEP_DAYS\""
                let found=$found+1
        else
                #echo "ARCHIVE_KEEP_DAYS=\"$ARCHIVE_KEEP_DAYS\" not found in the script"
                failmsg="$failmsg,ARCHIVE_KEEP_DAYS=\"$ARCHIVE_KEEP_DAYS\" not found in the script"
        fi

        LOGS_KEEP_DAYS=$(grep 'mtime' $script | grep -v '#' | grep -i 'log' | tr ' ' '\n' | grep -E '[+-][0-9]*' | sed -E 's/[+-]//' | grep '^[0-9]')
        lookfor=$(grep ^LOGS_KEEP_DAYS= $work_copy | cut -d'"' -f2)
        if [ "$LOGS_KEEP_DAYS" == "$lookfor" ]; then
                #echo "Found LOGS_KEEP_DAYS=\"$LOGS_KEEP_DAYS\""
                let found=$found+1
        else
                #echo "LOGS_KEEP_DAYS=\"$LOGS_KEEP_DAYS\" not found in the script"
                failmsg="$failmsg,LOGS_KEEP_DAYS=\"$LOGS_KEEP_DAYS\" not found in the script"
        fi

        FILE_DEST=$(grep -Ei 'to\s*([A-Za-z0-9]*)\s*server' $script | grep -v '#' | sed 's/^.*to\s*//i; s/\s*server.*$//i' | tr -d '\n'  )
        lookfor=$(grep ^FILE_DEST= $work_copy | cut -d'"' -f2)
        if [ "$FILE_DEST" == "$lookfor" ]; then
                #echo "Found FILE_DEST=\"$FILE_DEST\""
                let found=$found+1
        else
                #echo "FILE_DEST=\"$FILE_DEST\" not found in the script"
                failmsg="$failmsg,FILE_DEST=\"$FILE_DEST\" not found in the script"
        fi
        script=$(echo $script | sed 's/^.//')
        editm="$script,$(grep -A1 chlottman ./${work_copy} | tail -1)"
        if [ "$found" -eq 5 ]; then
                echo "SUCC,$editm: All 5 variables set correctly"
        else
                echo -e "FAIL,$editm,$failmsg" | sed 's/^$//'
                echo
        fi
        echo
done

#rm -rf $scriptlist
