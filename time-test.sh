#!/bin/bash
echo Enter accountid:
read acc
#echo Enter the Accountid for getting Unsupported Files:
#read accid
echo Enter the CSV Firstname:
read name

echo "**************Generating Reports********************"

sleep 1s

echo "Processing ge-"$name"_org.csv file"
#ge-{AccountGroupName}-organizationID 
res1=$(date +%s.%N)
res11=$(date +%s.%N)
sqlcmd -S PRD-DB-02.ics.com -U sa -P 'SQL h@$ N0 =' -d ge -Q "set nocount on;Select a.AccountGroupID, a.AccountID, '\"'"' + a.AccountName + '"'\"' as [AccountName], j.JobID, J.JobName from Job j
inner join Account a on a.AccountID = j.OwnerAccountID
where a.AccountGroupID = '$acc' and j.DeletedOn is null"  -s , -W -k1 > Output/ge-"$name"_org.csv

sed -e 's/-,//g;s/-//g;s/,,//g;/^$/d' Output/ge-ge-"$name"_org.csv > Final_CSV/ge-"$name"_org.csv

res2=$(date +%s.%N)
dt=$(echo "$res2 - $res1" | bc)
dd=$(echo "$dt/86400" | bc)
dt2=$(echo "$dt-86400*$dd" | bc)
dh=$(echo "$dt2/3600" | bc)
dt3=$(echo "$dt2-3600*$dh" | bc)
dm=$(echo "$dt3/60" | bc)
ds=$(echo "$dt3-60*$dm" | bc)
timetaken=$(LC_NUMERIC=C printf "%d:%02d:%02d:%02d \n" $dd $dh $dm $ds)
timetaken1=$(LC_NUMERIC=C printf "%d:%02d:%02d:%02.4f\n" $dd $dh $dm $ds)

echo "TimeTaken: $timetaken"
echo "TimeTaken1: $timetaken"