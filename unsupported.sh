echo Enter the Accountid for getting Unsupported Files:
read accid
echo Enter the CSV Firstname:
read name





#ge-{unsupported-files)

sqlcmd -S PRD-DB-02.ics.com -U sa -P 'SQL h@$ N0 =' -d ge -Q "set nocount on; select distinct a.AssetID as 'Asset ID', a.Filename as 'Asset Filename', a.FileByteCount as 'Asset Size in Bytes', a.StorageFolderPath as 'Asset Storage Path in Isilon',
IIF(
        a.jobfolderid is not null,
 concat(j.jobname, ' \ ', [dbo].[udf_GetFolderPath] (a.jobfolderid)),
 j.jobname
        ) as 'Asset Path in GEL UI'
 from job j
inner join asset a on a.jobid = j.jobid
where j.owneraccountid = $accid and j.deletedon is null and a.DeletetedOn is null and RIGHT(a.filename, 3) in ('.db', '(1)', '019', 'cof', 'cos', 'cot', 'eip', 'MOV', 'mp4', 'pdf')" -s , -W -k1 > Output/"$name"_unsupported_files.csv

sed -e 's/-,//g;s/-//g;s/,,//g;/^$/d' Output/"$name"_unsupported_files.csv > Final_CSV/"$name"_unsupported_files.csv
