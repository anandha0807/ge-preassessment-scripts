#!/bin/bash

PATH=/usr/bin:/sbin:/usr/sbin:/opt/mssql-tools/bin:/usr/local/bin


sqlcmd -S PRD-DB-02.ics.com -U sa -P 'SQL h@$ N0 =' -d ge -h-1 -i highlevelsummary.sql -s "," -W -k1 > Output/highleveloutput.csv

sed -e 's/-,//g;s/-//g;s/,,//g;/^$/d' Output/highleveloutput.csv  > Final_CSV_Test/highleveloutput.csv