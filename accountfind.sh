#!/bin/bash

echo "Enter the AccountGroupID: "
read agid

mkdir -p -v Output/"$agid"

mkdir -p -v Final_CSV/"$agid"

sqlcmd -S PRD-DB-02.ics.com -U sa -P 'SQL h@$ N0 =' -h-1 -d ge -Q "set nocount on;

select a.AccountID from Account a where a.AccountGroupID= '$agid'
AND a.AccountTypeID=1 AND a.IsBillable=1 AND a.DeletedOn is NULL" -s , -W -k1 > Output/"$agid"/ge-"$agid"_accountid.csv

sed -e 's/-,//g;s/-//g;s///g;/^$/d' Output/"$agid"/ge-"$agid"_accountid.csv > Final_CSV/"$agid"/ge-"$agid"_accountid.csv


