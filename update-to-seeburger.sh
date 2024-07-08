#!/bin/bash
# this script will make a copy in /interfaces/backup/<script-path>
# then update the script to point to the seeburger server


script=$1
mode=$2

if [ ! "$script" ] || [ ! -f "$script" ]; then
        echo -e "You must give a script name. Ex. /interfaces/HQE/HCE/CrewOutfitters/script/HCEU166I"
        echo -e "Usage:\n $0 <full script path> <update|restore>"
        exit 1
fi

if [ "$mode" == "update" ] || [ "$mode" == "restore" ]; then
        echo "Performing '$mode' action on $script"
else
        echo "Mode must be one of 'update' or 'restore'"
        echo -e "Usage:\n $0 <full script path> <update|restore>"
        exit 2
fi

sdir=$(dirname $script)
sname=$(basename $script)
budir="/interfaces/backup/$sdir"
mkdir -p $budir
buname="${budir}/$sname"

backup_script(){
        if [ -f "$buname" ]; then
                echo "!!! $buname already present. Not overwriting!"
        else
                echo "Backing up script: cp -p $script $buname"
                cp -p $script $buname
                if [ "$?" -eq 0 ]; then
                        echo "$mode completed."
                        exit 0
                else
                        echo "!!!!!!!!!! Backup Failed !!!!!!!!"
                        exit 3
                fi

        fi
}

backup_script

if [ "$mode" == "update" ]; then
        chmod 777 /interfaces/updated_scripts/${script}
        cp -p /interfaces/updated_scripts/${script} $script
        env=$(echo $script | cut -d/ -f3)
        if [ "$env" == "HPE" ]; then
                sed -i 's/^SERVERNAME=.*$/SERVERNAME="mftihr-prod.delta.com"/' $script
        else
                sed -i 's/^SERVERNAME=.*$/SERVERNAME="mftihr-si.delta.com"/' $script
        fi



elif [ "$mode" == "restore" ]; then
        echo "Restoring script: cp -p $buname $script"
        cp -p $buname $script
        if [ "$?" -eq 0 ]; then
                  echo "$mode completed."
                exit 0
          else
                  echo "!!!!!!!!!! Restore Failed !!!!!!!!"
                  exit 4
          fi
fi

