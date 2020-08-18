#!/bin/bash

echo Enter account groupid:
read acc
#echo Enter the Accountid for getting Unsupported Files:
#read accid
echo Enter the CSV Firstname:
read name


sqlcmd -S PRD-DB-02.ics.com -U sa -P 'SQL h@$ N0 =' -d ge -Q "set nocount on;
WITH CTE as (
select nh.NotesHistoryID, ag.ApprovalGalleryID, '\"'"' + nh.Text + '"'\"' as [Notes], nh.AssetID From NoteHistory nh 
inner join ApprovalGalleryUser agu on nh.ApprovalGalleryUserID=agu.ApprovalGalleryUserID
inner join ApprovalGallery ag on agu.ApprovalGalleryID=ag.ApprovalGalleryID
inner join Account a on ag.AccountID=a.AccountID
inner join AccountGroup acg on a.AccountGroupID=acg.AccountGroupID
where acg.AccountGroupID='$acc'
and (
(ag.DoneDate is not null and ag.ExpirationDate is not null) or (ag.DoneDate is not null and ag.ExpirationDate is null) or (ag.DoneDate is null and ag.ExpirationDate is not null)
))

select acg.AccountGroupID, a.AccountID, apg.ApprovalGalleryID, c.NotesHistoryID, c.Notes, 
case when c.NotesHistoryID is null then '0' else '1' end as [HasNotes], c.AssetID From AccountGroup acg
inner join Account a on acg.AccountGroupID=a.AccountGroupID
inner join ApprovalGallery apg on a.AccountID=apg.AccountID
left  join CTE c on apg.ApprovalGalleryID=c.ApprovalGalleryID
where acg.AccountGroupID='$acc' and c.NotesHistoryID is not null and (
(apg.DoneDate is not null and apg.ExpirationDate is not null) or (apg.DoneDate is not null and apg.ExpirationDate is null) or (apg.DoneDate is null and apg.ExpirationDate is not null)
)" -s , -W -k1 > Output/"$name"_ApprovalGallery_HashNotes_1.csv


sed -e 's/-,//g;s/-//g;s/,,//g;/^$/d' Output/"$name"_ApprovalGallery_HashNotes_1.csv > Final_CSV_Test/"$name"_ApprovalGallery_HashNotes_1.csv