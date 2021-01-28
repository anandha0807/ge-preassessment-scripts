#!/bin/bash

echo "Enter the AccountGroupID: "
read agid

echo Enter the CSV Firstname without ge-:
read name

mkdir -p -v Output/"$agid"

mkdir -p -v Final_CSV/"$agid"

cat /dev/null > ge-"$name"_accountid.csv

echo "Getting AccountID list for AgID=$agid "

sleep 1s


sqlcmd -S PRD-DB-02.ics.com -U sa -P 'SQL h@$ N0 =' -h-1 -d ge -Q "set nocount on;

select a.AccountID from Account a where a.AccountGroupID= '$agid'
AND a.AccountTypeID=1 AND a.IsBillable=1 AND a.DeletedOn is NULL" -s , -W -k1 > Output/"$agid"/ge-"$name"_accountid.csv

sed -e 's/-,//g;s/-//g;s///g;/^$/d' Output/"$agid"/ge-"$name"_accountid.csv > Final_CSV/"$agid"/ge-"$name"_accountid.csv


ac=$(cat Final_CSV/"$agid"/ge-"$name"_accountid.csv | wc -l)

echo "Total No Of Accounts: $ac"

cat Final_CSV/"$agid"/ge-"$name"_accountid.csv > ge-"$name"_accountid.csv

file=ge-"$name"_accountid.csv

f=1
        function asset()

        {   
        arr=("$@")
        for acc in "${arr[@]}";
        do

echo "Creating Account dir $acc"

sleep 1s

mkdir -p -v Output/"$agid"/"$acc"
mkdir -p -v Final_CSV/"$agid"/"$acc"

echo "**************Generating Reports for AccountID: $acc********************"

sleep 1s

echo "Processing ge-"$name"_org.csv file"

res1=$(date +%s.%N)

sqlcmd -S PRD-DB-02.ics.com -U sa -P 'SQL h@$ N0 =' -d ge -Q "set nocount on;

Select a.AccountGroupID, a.AccountID, a.AccountName, j.JobID, J.JobName from Job j
inner join Account a on a.AccountID = j.OwnerAccountID
where a.AccountID = '$acc' and j.DeletedOn is null"  -s , -W -k1 > Output/"$agid"/"$acc"/ge-"$name"_org.csv

sed -e 's/-,//g;s/-//g;s///g;/^$/d' Output/"$agid"/"$acc"/ge-"$name"_org.csv > Final_CSV/"$agid"/"$acc"/ge-"$name"_org.csv

res2=$(date +%s.%N)
dt=$(echo "$res2 - $res1" | bc)
dd=$(echo "$dt/86400" | bc)
dt2=$(echo "$dt-86400*$dd" | bc)
dh=$(echo "$dt2/3600" | bc)
dt3=$(echo "$dt2-3600*$dh" | bc)
dm=$(echo "$dt3/60" | bc)
ds=$(echo "$dt3-60*$dm" | bc)
timetaken=$(LC_NUMERIC=C printf "%d:%02d:%02d:%02.4f\n" $dd $dh $dm $ds)
sleep 1s

echo "Report-1 ge-"$name"_org.csv -> done TimeTaken: $timetaken"

sleep 1s

echo "Completed..."

REWRITE="\e[25D\e[1A\e[K"
            echo -e "${REWRITE}$f done"
            ((f++))

        done
        }
        array=( $(cut -d ',' -f1 $file ) )
        asset "${array[@]}"

totalrun=$($f-1)
echo "Done for all $totalrun accounts"