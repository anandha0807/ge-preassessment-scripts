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
sqlcmd -S PRD-DB-02.ics.com -U sa -P 'SQL h@$ N0 =' -d ge -Q "set nocount on;
select distinct a.AssetID, am.AssetMetadataID,acc.AccountID  from AccountGroup ag
inner join Account acc on acc.AccountGroupID = ag.AccountGroupID
inner join Job j on j.OwnerAccountID = acc.AccountID
inner join Asset a on a.JobID = j.JobiD
inner join AssetMetadata am on am.AssetID = a.AssetID
where ag.AccountGroupID = '$acc' and a.DeletetedOn is null and j.DeletedOn is null
AND am.MetadataPropertyID  NOT IN (60,62,63,64,65,78,79,80,81,82,83,84,85,86,87,88,89,90,91,92,93,94,95,96,97,98,99,100,13043,13046,13047)" -s , -W -k1 > Output/ge-"$name"_asset_metadataid_mapped.csv

sed -e 's/-,//g;s/-//g;s/,,//g;/^$/d' Output/ge-"$name"_asset_metadataid_mapped.csv > Final_CSV/ge-"$name"_asset_metadataid_mapped.csv

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