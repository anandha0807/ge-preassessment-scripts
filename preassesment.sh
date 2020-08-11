echo Enter account groupid:
read acc
#echo Enter the Accountid for getting Unsupported Files:
#read accid
echo Enter the CSV Firstname:
read name
#ge-{AccountGroupName}-organizationID 
sqlcmd -S PRD-DB-02.ics.com -U sa -P 'SQL h@$ N0 =' -d ge -Q "set nocount on;Select a.AccountGroupID, a.AccountID, a.AccountName, j.JobID, J.JobName from Job j
inner join Account a on a.AccountID = j.OwnerAccountID
where a.AccountGroupID = '$acc' and j.DeletedOn is null"  -s , -W -k1 > Output/"$name"_org.csv

#ge-{AccountGroupName}-userID
sqlcmd -S PRD-DB-02.ics.com -U sa -P 'SQL h@$ N0 =' -d ge -Q "set nocount on;Select a.AccountID, u.UserID from [dbo].[User] u
inner join Account a on a.AccountID = u.AccountID
where a.AccountGroupID = '$acc'  AND u.DeletedOn is NULL" -s , -W -k1 > Output/"$name"_userid.csv

#ge-{AccountGroupName}-user-savedsearchID
sqlcmd -S PRD-DB-02.ics.com -U sa -P 'SQL h@$ N0 =' -d ge -Q "set nocount on;select acc.AccountID,ss.OwnerID, ss.SavedSearchID, count(ssi.SavedSearchQueryItemID) as NoOfSavedSearchQueryItem from Account acc
inner join [dbo].[User] u on u.AccountID = acc.AccountID
inner join SavedSearch ss on ss.OwnerID = u.UserID
inner join SavedSearchQueryItem ssi on ssi.SavedSearchID = ss.SavedSearchID
where acc.AccountGroupID = '$acc'  and  u.DeletedOn is null 
group by ss.SavedSearchID, ss.OwnerID, acc.AccountID" -s , -W -k1 > Output/"$name"_user_saved_searchid.csv

#ge-{AccountGroupName}-jobfolderID
sqlcmd -S PRD-DB-02.ics.com -U sa -P 'SQL h@$ N0 =' -d ge -Q "set nocount on;select acc.AccountId, j.JobID, jf.JobFolderId, jf.ParentID from Account acc
inner join Job j on j.OwnerAccountId = acc.AccountId
inner join JobFolder jf on jf.JobId = j.JobId
where acc.AccountGroupID = '$acc' and j.DeletedOn is null and jf.DeletedOn is null" -s , -W -k1 > Output/"$name"_Jobfolderid.csv

#ge-{AccountGroupName}-assetID
sqlcmd -S PRD-DB-02.ics.com -U sa -P 'SQL h@$ N0 =' -d ge -Q "set nocount on;select distinct a.JobID, acc.AccountID, a.AssetID, '\"\"\"'"' + a.Filename + '"'\"\"\"' as Filename from AccountGroup ag
inner join Account acc on acc.AccountGroupID = ag.AccountGroupID
inner join Job j on j.OwnerAccountID = acc.AccountID
inner join Asset a on a.JobID = j.JobiD
where ag.AccountGroupID = '$acc'  and a.DeletetedOn is null and j.DeletedOn is null" -s , -W -k1  > Output/"$name"_assetid.csv


#ge-{AccountGroupName}-asset-derivativeID
sqlcmd -S PRD-DB-02.ics.com -U sa -P 'SQL h@$ N0 =' -d ge -Q "set nocount on;select distinct a.AssetID, acc.AccountID, ad.AssetDerivativeID, ad.AssetTypeCd from Account acc
inner join Job j on j.OwnerAccountID = acc.AccountID
inner join Asset a on a.JobID = j.JobID
inner join AssetDerivative ad on ad.AssetID = a.AssetID
where acc.AccountGroupID = '$acc' and j.DeletedOn is null and a.DeletetedOn is null and ad.AssetTypeCd NOT IN ('SM_THUMB','LG_THUMB','MED_RES','SCR_RES','PVIEW','PVIEW_VID','PVIEW_VID_MED','PVIEW_VID_HIGH','PVIEW_VID_THUMB','PVIEW_HR', 'PDF_SWF')
group by acc.AccountID,a.AssetID, ad.AssetDerivativeID, ad.AssetTypeCd" -s , -W -k1 > Output/"$name"_Asset_derivative_id.csv

#ge-{AccountGroupName}-asset-metadataID
sqlcmd -S PRD-DB-02.ics.com -U sa -P 'SQL h@$ N0 =' -d ge -Q "set nocount on;select distinct a.AssetID, am.AssetMetadataID,acc.AccountID from AccountGroup ag
inner join Account acc on acc.AccountGroupID = ag.AccountGroupID
inner join Job j on j.OwnerAccountID = acc.AccountID
inner join Asset a on a.JobID = j.JobiD
inner join AssetMetadata am on am.AssetID = a.AssetID
where ag.AccountGroupID = '$acc' and a.DeletetedOn is null and j.DeletedOn is null order by a.AssetID asc" -s , -W -k1 > Output/"$name"_asset_metadataid.csv

#ge-{AccountGroupName}-asset-markupID
sqlcmd -S PRD-DB-02.ics.com -U sa -P 'SQL h@$ N0 =' -d ge -Q "set nocount on;select distinct a.AssetID, acc.AccountID,am.AssetMarkupId, count(ami.AssetMarkupItemID) as MarkupItems from Account acc
inner join job j on j.OwnerAccountID = acc.AccountID
inner join Asset a on a.JobID = j.JobID
inner join AssetMarkup am on am.AssetID = a.AssetID
left join AssetMarkupItem ami on ami.AssetMarkupID = am.AssetMarkupID
where acc.AccountGroupID = '$acc' AND a.DeletetedOn is NULL AND j.DeletedOn is null
group by acc.AccountID,am.AssetMarkupId, a.AssetID order by a.AssetID asc" -s , -W -k1 > Output/"$name"_asset_markupid.csv

#ge-{AccountGroupName}-asset-ratingID
sqlcmd -S PRD-DB-02.ics.com -U sa -P 'SQL h@$ N0 =' -d ge -Q "set nocount on;select aa.AssetID,
iif(aa.SelectDate is not null, 1, 0) as Selected,
iif(aa.ApprovedDate is not null, 1, 0) as Approved,
iif(aa.AltDate is not null, 1, 0) as Alted,
iif(aa.KilledDate is not null, 1, 0) as Killed,
iif(aa.ratingdate is null, 0, aa.ratingid) as StartRating,
iif(ac.Name is not null, aa.color, 0) as Colored, a.AccountID
from Account a
inner join Job j on j.OwnerAccountID = a.AccountID
inner join Asset aa on aa.JobID = j.JobID
left join assetcolor ac on ac.assetcolorid = aa.color
where a.AccountGroupID = '$acc' AND j.DeletedOn is null and aa.DeletetedOn is null" -s , -W -k1 > Output/"$name"_asset_ratingid.csv

#ge-{AccountGroupName}-asset-notehistoryID
sqlcmd -S PRD-DB-02.ics.com -U sa -P 'SQL h@$ N0 =' -d ge -Q "set nocount on;select distinct a.AssetID, acc.AccountID,nh.NotesHistoryID, nh.CreatedBy from AccountGroup ag
inner join Account acc on acc.AccountGroupID = ag.AccountGroupID
inner join Job j on j.OwnerAccountID = acc.AccountID
inner join Asset a on a.JobID = j.JobiD
inner join NoteHistory nh on nh.AssetID = a.AssetID
where ag.AccountGroupID = '$acc' and a.DeletetedOn is null and j.DeletedOn is null and nh.ApprovalGalleryUserID is NULL" -s , -W -k1 > Output/"$name"_asset_note_historyid.csv

#ge-{AccountGroupName}-lightboxID
sqlcmd -S PRD-DB-02.ics.com -U sa -P 'SQL h@$ N0 =' -d ge -Q "set nocount on;
select distinct l.LightboxID, acc.AccountID,count(la.lightboxassetid) as LightboxAssetCount from AccountGroup ag
inner join Account acc on acc.AccountGroupID = ag.AccountGroupID
inner join [dbo].[User] u on u.AccountID = acc.AccountID
inner join Lightbox l on l.OwnerID = u.UserID
left join lightboxasset la on la.lightboxid = l.lightboxid
where ag.AccountGroupID = '$acc'
AND acc.DeletedOn is null  --Excluding deleted accounts
AND l.DeletedOn is null --Excluding deleted Lightboxes
group by l.lightboxid,acc.AccountID" -s , -W -k1 > Output/"$name"_lightbox_id.csv




#ge-{AccountGroupName}-lightboxgroupID
sqlcmd -S PRD-DB-02.ics.com -U sa -P 'SQL h@$ N0 =' -d ge -Q "set nocount on;select distinct lg.LightboxGroupId, acc.AccountID,count(l.lightboxid) NoOfLightboxes from AccountGroup ag
inner join Account acc on acc.AccountGroupID = ag.AccountGroupID
inner join [dbo].[User] u on u.AccountID = acc.AccountID
inner join LightboxGroup lg on lg.userid = u.userid
left join lightbox l on l.lightboxid = lg.lightboxid
where ag.AccountGroupID = '$acc' and acc.DeletedOn is null and u.DeletedOn is null and lg.Name is not null
group by lg.lightboxgroupid,acc.AccountID" -s , -W -k1 > Output/"$name"_lightbox_groupid.csv

#ge-{AccountGroupName}-lightbox-commentID
sqlcmd -S PRD-DB-02.ics.com -U sa -P 'SQL h@$ N0 =' -d ge -Q "set nocount on;
select acc.AccountID,l.LightboxID, l.OwnerID as LB_OwnerID, ln.LightboxNoteID,ln.UserID as LB_Notes_CreaterID from AccountGroup ag
inner join Account acc on acc.AccountGroupID = ag.AccountGroupID
inner join [dbo].[User] u on u.AccountID = acc.AccountID
inner join Lightbox l on l.OwnerID = u.UserID
inner join lightboxnote ln on ln.lightboxid = l.lightboxid
where ag.AccountGroupID = '$acc'
AND acc.DeletedOn is null
AND l.DeletedOn is null" -s , -W -k1 > Output/"$name"_lightbox_commentid.csv

#ge-{AccountGroupName}-lightbox-invitationID
sqlcmd -S PRD-DB-02.ics.com -U sa -P 'SQL h@$ N0 =' -d ge -Q "set nocount on;
select distinct i.InvitationID, i.SharedObjectID, i.InviterID, i.GuestID,acc.AccountID from AccountGroup ag
inner join Account acc on acc.AccountGroupID = ag.AccountGroupID
inner join [dbo].[User] u on u.AccountID = acc.AccountID
inner join Lightbox l on l.OwnerID = u.UserID
inner join Invitation i on i.SharedObjectID = l.LightboxID
inner join [dbo].[User] gu on i.GuestID=gu.UserID
where ag.AccountGroupID = '$acc' and acc.DeletedOn is null AND l.DeletedOn is null 
AND gu.Guest= 0 AND i.ExpiredOn is NULL 
order by i.InvitationID" -s , -W -k1 > Output/"$name"_lightbox_invitationid.csv

#ge-{AccountGroupName}-AssetHistory-ItemTypeID
sqlcmd -S PRD-DB-02.ics.com -U sa -P 'SQL h@$ N0 =' -d ge -Q "set nocount on;declare @assetstable as table(assetid bigint);
insert into @assetstable select distinct a.AssetID from AccountGroup ag
inner join Account acc on acc.AccountGroupID = ag.AccountGroupID
inner join Job j on j.OwnerAccountID = acc.AccountID
inner join Asset a on a.JobID = j.JobiD
where ag.AccountGroupID = '$acc' and a.DeletetedOn is null and j.DeletedOn is null
order by a.AssetID
select distinct a.AssetID, ah.AssetHistoryID, ah.AssetHistoryItemTypeID, hit.ItemTypeName, j.OwnerAccountID as AccountID from AssetHistory ah
inner join @assetstable a on a.assetid = ah.assetid
inner join Asset ass on ass.AssetID= a.assetid
inner join Job j on ass.JobID=j.JobID
inner join AssetHistoryItemType hit on hit.AssetHistoryItemTypeID = ah.AssetHistoryItemTypeID
where ah.AssetHistoryItemTypeID NOT IN ('9','10')
order by a.assetid" -s , -W -k1 > Output/"$name"_assetHistory_item_TypeID.csv


#ge-{AccountGroupName}-asset_metadataid_mapped
sqlcmd -S PRD-DB-02.ics.com -U sa -P 'SQL h@$ N0 =' -d ge -Q "set nocount on;
select distinct a.AssetID, am.AssetMetadataID,acc.AccountID  from AccountGroup ag
inner join Account acc on acc.AccountGroupID = ag.AccountGroupID
inner join Job j on j.OwnerAccountID = acc.AccountID
inner join Asset a on a.JobID = j.JobiD
inner join AssetMetadata am on am.AssetID = a.AssetID
where ag.AccountGroupID = '$acc' and a.DeletetedOn is null and j.DeletedOn is null
AND am.MetadataPropertyID  NOT IN (60,62,63,64,65,78,79,80,81,82,83,84,85,86,87,88,89,90,91,92,93,94,95,96,97,98,99,100,13043,13046,13047)" -s , -W -k1 > Output/"$name"_asset_metadataid_mapped.csv

#ge-{AccountGroupName}-asset_metadataid_unmapped
sqlcmd -S PRD-DB-02.ics.com -U sa -P 'SQL h@$ N0 =' -d ge -Q "set nocount on;
select distinct a.AssetID, am.AssetMetadataID,acc.AccountID  from AccountGroup ag
inner join Account acc on acc.AccountGroupID = ag.AccountGroupID
inner join Job j on j.OwnerAccountID = acc.AccountID
inner join Asset a on a.JobID = j.JobiD
inner join AssetMetadata am on am.AssetID = a.AssetID
where ag.AccountGroupID = '$acc' and a.DeletetedOn is null and j.DeletedOn is null
AND am.MetadataPropertyID  IN (60,62,63,64,65,78,79,80,81,82,83,84,85,86,87,88,89,90,91,92,93,94,95,96,97,98,99,100,13043,13046,13047)" -s , -W -k1 > Output/"$name"_asset_metadataid_unmapped.csv

#ge-{unsupported-files)

sqlcmd -S PRD-DB-02.ics.com -U sa -P 'SQL h@$ N0 =' -d ge -Q "set nocount on;
select distinct a.AssetID as 'Asset ID', acc.AccountID,a.Filename as 'Asset Filename', a.FileByteCount as 'Asset Size in Bytes', a.StorageFolderPath as 'Asset Storage Path in Isilon',
IIF(
	a.jobfolderid is not null,
 concat(j.jobname, ' \ ', [dbo].[udf_GetFolderPath] (a.jobfolderid)),
 j.jobname
	) as 'Asset Path in GEL UI'
 from job j
inner join asset a on a.jobid = j.jobid
inner join Account acc on j.OwnerAccountID=acc.AccountID
where acc.AccountGroupID= '$acc' and j.deletedon is null and a.DeletetedOn is null and RIGHT(a.filename, 3) in ('.db', '(1)', '019', 'cof', 'cos', 'cot', 'eip', 'MOV', 'mp4', 'pdf')" -s , -W -k1 > Output/"$name"_unsupported_files.csv 





sed -e 's/-,//g;s/-//g;s/,,//g;/^$/d' Output/"$name"_org.csv > Final_CSV/"$name"_org.csv
sed -e 's/-,//g;s/-//g;s/,,//g;/^$/d' Output/"$name"_userid.csv > Final_CSV/"$name"_userid.csv
sed -e 's/-,//g;s/-//g;s/,,//g;/^$/d' Output/"$name"_user_saved_searchid.csv > Final_CSV/"$name"_user_saved_searchid.csv
sed -e 's/-,//g;s/-//g;s/,,//g;/^$/d' Output/"$name"_Jobfolderid.csv > Final_CSV/"$name"_Jobfolderid.csv
sed -e 's/-,//g;s/-//g;s/,,//g;/^$/d' Output/"$name"_assetid.csv > Final_CSV/"$name"_assetid.csv
sed -e 's/-,//g;s/-//g;s/,,//g;/^$/d' Output/"$name"_Asset_derivative_id.csv > Final_CSV/"$name"_Asset_derivative_id.csv
sed -e 's/-,//g;s/-//g;s/,,//g;/^$/d' Output/"$name"_asset_metadataid.csv > Final_CSV/"$name"_asset_metadataid.csv
sed -e 's/-,//g;s/-//g;s/,,//g;/^$/d' Output/"$name"_asset_markupid.csv > Final_CSV/"$name"_asset_markupid.csv
sed -e 's/-,//g;s/-//g;s/,,//g;/^$/d' Output/"$name"_asset_ratingid.csv > Final_CSV/"$name"_asset_ratingid.csv
sed -e 's/-,//g;s/-//g;s/,,//g;/^$/d' Output/"$name"_asset_note_historyid.csv > Final_CSV/"$name"_asset_note_historyid.csv
sed -e 's/-,//g;s/-//g;s/,,//g;/^$/d' Output/"$name"_lightbox_id.csv > Final_CSV/"$name"_lightbox_id.csv
sed -e 's/-,//g;s/-//g;s/,,//g;/^$/d' Output/"$name"_lightbox_groupid.csv > Final_CSV/"$name"_lightbox_groupid.csv
sed -e 's/-,//g;s/-//g;s/,,//g;/^$/d' Output/"$name"_lightbox_commentid.csv > Final_CSV/"$name"_lightbox_commentid.csv
sed -e 's/-,//g;s/-//g;s/,,//g;/^$/d' Output/"$name"_lightbox_invitationid.csv > Final_CSV/"$name"_lightbox_invitationid.csv
sed -e 's/-,//g;s/-//g;s/,,//g;/^$/d' Output/"$name"_assetHistory_item_TypeID.csv > Final_CSV/"$name"_assetHistory_item_TypeID.csv
sed -e 's/-,//g;s/-//g;s/,,//g;/^$/d' Output/"$name"_asset_metadataid_mapped.csv > Final_CSV/"$name"_asset_metadataid_mapped.csv
sed -e 's/-,//g;s/-//g;s/,,//g;/^$/d' Output/"$name"_asset_metadataid_unmapped.csv > Final_CSV/"$name"_asset_metadataid_unmapped.csv
sed -e 's/-,//g;s/-//g;s/,,//g;/^$/d' Output/"$name"_unsupported_files.csv > Final_CSV/"$name"_unsupported_files.csv


rm -rf Output/*

