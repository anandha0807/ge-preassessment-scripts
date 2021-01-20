#!/bin/bash
echo Enter account groupid:
read acc
#echo Enter the Accountid for getting Unsupported Files:
#read accid
echo Enter the CSV Firstname:
read name

echo "**************Generating Reports********************"

sleep 1s

echo "Processing "$name"_org.csv file"
#ge-{AccountGroupName}-organizationID 
res1=$(date +%s.%N)
res11=$(date +%s.%N)
sqlcmd -S PRD-DB-02.ics.com -U sa -P 'SQL h@$ N0 =' -d ge -Q "set nocount on;Select a.AccountGroupID, a.AccountID, '\"'"' + a.AccountName + '"'\"' as [AccountName], j.JobID, J.JobName from Job j
inner join Account a on a.AccountID = j.OwnerAccountID
where a.AccountGroupID = '$acc' and j.DeletedOn is null"  -s , -W -k1 > Output/"$name"_org.csv

sed -e 's/-,//g;s/-//g;s/,,//g;/^$/d' Output/"$name"_org.csv > Final_CSV/"$name"_org.csv

res2=$(date +%s.%N)
dt=$(echo "$res2 - $res1" | bc)
dd=$(echo "$dt/86400" | bc)
dt2=$(echo "$dt-86400*$dd" | bc)
dh=$(echo "$dt2/3600" | bc)
dt3=$(echo "$dt2-3600*$dh" | bc)
dm=$(echo "$dt3/60" | bc)
ds=$(echo "$dt3-60*$dm" | bc)
timetaken=$(LC_NUMERIC=C printf "%d:%02d:%02d:%02.4f\n" $dd $dh $dm $ds)

echo "Report-1 "$name"_org.csv -> done TimeTaken: $timetaken"

sleep 1s

echo "Processing "$name"_userid.csv file"

res1=$(date +%s.%N)

#ge-{AccountGroupName}-userID
sqlcmd -S PRD-DB-02.ics.com -U sa -P 'SQL h@$ N0 =' -d ge -Q "set nocount on;
select AccountID, UserID from 
(
	select u.UserId,a.AccountID from [User] u
	join Account a on a.AccountID = u.AccountID
	where a.AccountGroupID =  '$acc'
	and a.DeletedOn is null
	union
	select u.UserId,a.AccountID from [User] u
	join Dropbox d on d.RecipientID = u.UserId
	join Account a on a.AccountID = d.AccountID
	where a.AccountGroupID =  '$acc'
	and u.Guest = 1
	and u.AccountID is null
	union
	select u.UserId,a.AccountID from [User] u
	join Invitation i on i.GuestID = u.UserId
	join Lightbox l on l.LightboxID = i.SharedObjectID
	join [User] o on o.UserID = l.OwnerID
	join Account a on a.AccountID = o.AccountID
	where a.AccountGroupID =  '$acc'
	and u.Guest = 1
	and u.AccountID is null
) a;" -s , -W -k1 > Output/"$name"_userid.csv

sed -e 's/-,//g;s/-//g;s/,,//g;/^$/d' Output/"$name"_userid.csv > Final_CSV/"$name"_userid.csv

res2=$(date +%s.%N)
dt=$(echo "$res2 - $res1" | bc)
dd=$(echo "$dt/86400" | bc)
dt2=$(echo "$dt-86400*$dd" | bc)
dh=$(echo "$dt2/3600" | bc)
dt3=$(echo "$dt2-3600*$dh" | bc)
dm=$(echo "$dt3/60" | bc)
ds=$(echo "$dt3-60*$dm" | bc)
timetaken=$(LC_NUMERIC=C printf "%d:%02d:%02d:%02.4f\n" $dd $dh $dm $ds)

echo "Report-2 "$name"_userid.csv -> done TimeTaken: $timetaken"

sleep 1s

echo "Processing "$name"_user_saved_searchid.csv file"

res1=$(date +%s.%N)

#ge-{AccountGroupName}-user-savedsearchID
sqlcmd -S PRD-DB-02.ics.com -U sa -P 'SQL h@$ N0 =' -d ge -Q "set nocount on;select acc.AccountID,ss.OwnerID, ss.SavedSearchID, count(ssi.SavedSearchQueryItemID) as NoOfSavedSearchQueryItem from Account acc
inner join [dbo].[User] u on u.AccountID = acc.AccountID
inner join SavedSearch ss on ss.OwnerID = u.UserID
inner join SavedSearchQueryItem ssi on ssi.SavedSearchID = ss.SavedSearchID
where acc.AccountGroupID = '$acc'  and  u.DeletedOn is null 
group by ss.SavedSearchID, ss.OwnerID, acc.AccountID" -s , -W -k1 > Output/"$name"_user_saved_searchid.csv

sed -e 's/-,//g;s/-//g;s/,,//g;/^$/d' Output/"$name"_user_saved_searchid.csv > Final_CSV/"$name"_user_saved_searchid.csv

res2=$(date +%s.%N)
dt=$(echo "$res2 - $res1" | bc)
dd=$(echo "$dt/86400" | bc)
dt2=$(echo "$dt-86400*$dd" | bc)
dh=$(echo "$dt2/3600" | bc)
dt3=$(echo "$dt2-3600*$dh" | bc)
dm=$(echo "$dt3/60" | bc)
ds=$(echo "$dt3-60*$dm" | bc)
timetaken=$(LC_NUMERIC=C printf "%d:%02d:%02d:%02.4f\n" $dd $dh $dm $ds)

echo "Report-3 "$name"_user_saved_searchid.csv -> done TimeTaken: $timetaken"

sleep 1s

echo "Processing "$name"_Jobfolderid.csv file"

res1=$(date +%s.%N)

#ge-{AccountGroupName}-jobfolderID
sqlcmd -S PRD-DB-02.ics.com -U sa -P 'SQL h@$ N0 =' -d ge -Q "set nocount on;select acc.AccountId, j.JobID, jf.JobFolderId, jf.ParentID from Account acc
inner join Job j on j.OwnerAccountId = acc.AccountId
inner join JobFolder jf on jf.JobId = j.JobId
where acc.AccountGroupID = '$acc' and j.DeletedOn is null and jf.DeletedOn is null" -s , -W -k1 > Output/"$name"_Jobfolderid.csv

sed -e 's/-,//g;s/-//g;s/,,//g;/^$/d' Output/"$name"_Jobfolderid.csv > Final_CSV/"$name"_Jobfolderid.csv

res2=$(date +%s.%N)
dt=$(echo "$res2 - $res1" | bc)
dd=$(echo "$dt/86400" | bc)
dt2=$(echo "$dt-86400*$dd" | bc)
dh=$(echo "$dt2/3600" | bc)
dt3=$(echo "$dt2-3600*$dh" | bc)
dm=$(echo "$dt3/60" | bc)
ds=$(echo "$dt3-60*$dm" | bc)
timetaken=$(LC_NUMERIC=C printf "%d:%02d:%02d:%02.4f\n" $dd $dh $dm $ds)

echo "Report-4 "$name"_Jobfolderid.csv -> done TimeTaken: $timetaken"

sleep 1s

echo "Processing "$name"_assetid.csv file"

res1=$(date +%s.%N)

#ge-{AccountGroupName}-assetID
sqlcmd -S PRD-DB-02.ics.com -U sa -P 'SQL h@$ N0 =' -d ge -Q "set nocount on;select distinct a.JobID, acc.AccountID, a.AssetID, '\"\"\"'"' + a.Filename + '"'\"\"\"' as Filename from AccountGroup ag
inner join Account acc on acc.AccountGroupID = ag.AccountGroupID
inner join Job j on j.OwnerAccountID = acc.AccountID
inner join Asset a on a.JobID = j.JobiD
where ag.AccountGroupID = '$acc'  and a.DeletetedOn is null and j.DeletedOn is null" -s , -W -k1  > Output/"$name"_assetid.csv

sed -e 's/-,//g;s/-//g;s/,,//g;/^$/d' Output/"$name"_assetid.csv > Final_CSV/"$name"_assetid.csv

res2=$(date +%s.%N)
dt=$(echo "$res2 - $res1" | bc)
dd=$(echo "$dt/86400" | bc)
dt2=$(echo "$dt-86400*$dd" | bc)
dh=$(echo "$dt2/3600" | bc)
dt3=$(echo "$dt2-3600*$dh" | bc)
dm=$(echo "$dt3/60" | bc)
ds=$(echo "$dt3-60*$dm" | bc)
timetaken=$(LC_NUMERIC=C printf "%d:%02d:%02d:%02.4f\n" $dd $dh $dm $ds)

echo "Report-5 "$name"_assetid.csv -> done TimeTaken: $timetaken"

sleep 1s

echo "Processing "$name"_Asset_derivative_id.csv file"

res1=$(date +%s.%N)

#ge-{AccountGroupName}-asset-derivativeID
sqlcmd -S PRD-DB-02.ics.com -U sa -P 'SQL h@$ N0 =' -d ge -Q "set nocount on;select distinct a.AssetID, acc.AccountID, ad.AssetDerivativeID, ad.AssetTypeCd from Account acc
inner join Job j on j.OwnerAccountID = acc.AccountID
inner join Asset a on a.JobID = j.JobID
inner join AssetDerivative ad on ad.AssetID = a.AssetID
where acc.AccountGroupID = '$acc' and j.DeletedOn is null and a.DeletetedOn is null and ad.AssetTypeCd NOT IN ('SM_THUMB','LG_THUMB','MED_RES','SCR_RES','PVIEW','PVIEW_VID','PVIEW_VID_MED','PVIEW_VID_HIGH','PVIEW_VID_THUMB','PVIEW_HR', 'PDF_SWF')
group by acc.AccountID,a.AssetID, ad.AssetDerivativeID, ad.AssetTypeCd" -s , -W -k1 > Output/"$name"_Asset_derivative_id.csv

sed -e 's/-,//g;s/-//g;s/,,//g;/^$/d' Output/"$name"_Asset_derivative_id.csv > Final_CSV/"$name"_Asset_derivative_id.csv

res2=$(date +%s.%N)
dt=$(echo "$res2 - $res1" | bc)
dd=$(echo "$dt/86400" | bc)
dt2=$(echo "$dt-86400*$dd" | bc)
dh=$(echo "$dt2/3600" | bc)
dt3=$(echo "$dt2-3600*$dh" | bc)
dm=$(echo "$dt3/60" | bc)
ds=$(echo "$dt3-60*$dm" | bc)
timetaken=$(LC_NUMERIC=C printf "%d:%02d:%02d:%02.4f\n" $dd $dh $dm $ds)

echo "Report-6 "$name"_Asset_derivative_id.csv -> done TimeTaken: $timetaken"

sleep 1s

echo "Processing "$name"_asset_metadataid.csv file"

res1=$(date +%s.%N)

#ge-{AccountGroupName}-asset-metadataID
sqlcmd -S PRD-DB-02.ics.com -U sa -P 'SQL h@$ N0 =' -d ge -Q "set nocount on;select distinct a.AssetID, am.AssetMetadataID,acc.AccountID from AccountGroup ag
inner join Account acc on acc.AccountGroupID = ag.AccountGroupID
inner join Job j on j.OwnerAccountID = acc.AccountID
inner join Asset a on a.JobID = j.JobiD
inner join AssetMetadata am on am.AssetID = a.AssetID
where ag.AccountGroupID = '$acc' and a.DeletetedOn is null and j.DeletedOn is null order by a.AssetID asc" -s , -W -k1 > Output/"$name"_asset_metadataid.csv

sed -e 's/-,//g;s/-//g;s/,,//g;/^$/d' Output/"$name"_asset_metadataid.csv > Final_CSV/"$name"_asset_metadataid.csv

res2=$(date +%s.%N)
dt=$(echo "$res2 - $res1" | bc)
dd=$(echo "$dt/86400" | bc)
dt2=$(echo "$dt-86400*$dd" | bc)
dh=$(echo "$dt2/3600" | bc)
dt3=$(echo "$dt2-3600*$dh" | bc)
dm=$(echo "$dt3/60" | bc)
ds=$(echo "$dt3-60*$dm" | bc)
timetaken=$(LC_NUMERIC=C printf "%d:%02d:%02d:%02.4f\n" $dd $dh $dm $ds)

echo "Report-7 "$name"_asset_metadataid.csv -> done TimeTaken: $timetaken"

sleep 1s

echo "Processing "$name"_asset_markupid.csv file"

res1=$(date +%s.%N)

#ge-{AccountGroupName}-asset-markupID
sqlcmd -S PRD-DB-02.ics.com -U sa -P 'SQL h@$ N0 =' -d ge -Q "set nocount on;select distinct a.AssetID, acc.AccountID,am.AssetMarkupId, count(ami.AssetMarkupItemID) as MarkupItems from Account acc
inner join job j on j.OwnerAccountID = acc.AccountID
inner join Asset a on a.JobID = j.JobID
inner join AssetMarkup am on am.AssetID = a.AssetID
left join AssetMarkupItem ami on ami.AssetMarkupID = am.AssetMarkupID
where acc.AccountGroupID = '$acc' AND a.DeletetedOn is NULL AND j.DeletedOn is null
group by acc.AccountID,am.AssetMarkupId, a.AssetID order by a.AssetID asc" -s , -W -k1 > Output/"$name"_asset_markupid.csv

sed -e 's/-,//g;s/-//g;s/,,//g;/^$/d' Output/"$name"_asset_markupid.csv > Final_CSV/"$name"_asset_markupid.csv

res2=$(date +%s.%N)
dt=$(echo "$res2 - $res1" | bc)
dd=$(echo "$dt/86400" | bc)
dt2=$(echo "$dt-86400*$dd" | bc)
dh=$(echo "$dt2/3600" | bc)
dt3=$(echo "$dt2-3600*$dh" | bc)
dm=$(echo "$dt3/60" | bc)
ds=$(echo "$dt3-60*$dm" | bc)
timetaken=$(LC_NUMERIC=C printf "%d:%02d:%02d:%02.4f\n" $dd $dh $dm $ds)

echo "Report-8 "$name"_asset_markupid.csv -> done TimeTaken: $timetaken"

sleep 1s

echo "Processing "$name"_asset_ratingid.csv file"

res1=$(date +%s.%N)

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

sed -e 's/-,//g;s/-//g;s/,,//g;/^$/d' Output/"$name"_asset_ratingid.csv > Final_CSV/"$name"_asset_ratingid.csv

res2=$(date +%s.%N)
dt=$(echo "$res2 - $res1" | bc)
dd=$(echo "$dt/86400" | bc)
dt2=$(echo "$dt-86400*$dd" | bc)
dh=$(echo "$dt2/3600" | bc)
dt3=$(echo "$dt2-3600*$dh" | bc)
dm=$(echo "$dt3/60" | bc)
ds=$(echo "$dt3-60*$dm" | bc)
timetaken=$(LC_NUMERIC=C printf "%d:%02d:%02d:%02.4f\n" $dd $dh $dm $ds)

echo "Report-9 "$name"_asset_ratingid.csv -> done TimeTaken: $timetaken"

sleep 1s

echo "Processing "$name"_asset_note_historyid.csv file"

res1=$(date +%s.%N)

#ge-{AccountGroupName}-asset-notehistoryID
sqlcmd -S PRD-DB-02.ics.com -U sa -P 'SQL h@$ N0 =' -d ge -Q "set nocount on;select distinct a.AssetID, acc.AccountID,nh.NotesHistoryID, nh.CreatedBy from AccountGroup ag
inner join Account acc on acc.AccountGroupID = ag.AccountGroupID
inner join Job j on j.OwnerAccountID = acc.AccountID
inner join Asset a on a.JobID = j.JobiD
inner join NoteHistory nh on nh.AssetID = a.AssetID
where ag.AccountGroupID = '$acc' and a.DeletetedOn is null and j.DeletedOn is null and nh.ApprovalGalleryUserID is NULL" -s , -W -k1 > Output/"$name"_asset_note_historyid.csv

sed -e 's/-,//g;s/-//g;s/,,//g;/^$/d' Output/"$name"_asset_note_historyid.csv > Final_CSV/"$name"_asset_note_historyid.csv

res2=$(date +%s.%N)
dt=$(echo "$res2 - $res1" | bc)
dd=$(echo "$dt/86400" | bc)
dt2=$(echo "$dt-86400*$dd" | bc)
dh=$(echo "$dt2/3600" | bc)
dt3=$(echo "$dt2-3600*$dh" | bc)
dm=$(echo "$dt3/60" | bc)
ds=$(echo "$dt3-60*$dm" | bc)
timetaken=$(LC_NUMERIC=C printf "%d:%02d:%02d:%02.4f\n" $dd $dh $dm $ds)

echo "Report-10 "$name"_asset_note_historyid.csv -> done TimeTaken: $timetaken"

sleep 1s

echo "Processing "$name"_lightbox_id.csvfile"

res1=$(date +%s.%N)

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

sed -e 's/-,//g;s/-//g;s/,,//g;/^$/d' Output/"$name"_lightbox_id.csv > Final_CSV/"$name"_lightbox_id.csv

res2=$(date +%s.%N)
dt=$(echo "$res2 - $res1" | bc)
dd=$(echo "$dt/86400" | bc)
dt2=$(echo "$dt-86400*$dd" | bc)
dh=$(echo "$dt2/3600" | bc)
dt3=$(echo "$dt2-3600*$dh" | bc)
dm=$(echo "$dt3/60" | bc)
ds=$(echo "$dt3-60*$dm" | bc)
timetaken=$(LC_NUMERIC=C printf "%d:%02d:%02d:%02.4f\n" $dd $dh $dm $ds)

echo "Report-11 "$name"_lightbox_id.csv -> done TimeTaken: $timetaken"

sleep 1s

echo "Processing "$name"_lightbox_groupid.csv file"

res1=$(date +%s.%N)

#ge-{AccountGroupName}-lightboxgroupID
sqlcmd -S PRD-DB-02.ics.com -U sa -P 'SQL h@$ N0 =' -d ge -Q "set nocount on;select distinct lg.LightboxGroupId, acc.AccountID,count(l.lightboxid) NoOfLightboxes from AccountGroup ag
inner join Account acc on acc.AccountGroupID = ag.AccountGroupID
inner join [dbo].[User] u on u.AccountID = acc.AccountID
inner join LightboxGroup lg on lg.userid = u.userid
left join lightbox l on l.lightboxid = lg.lightboxid
where ag.AccountGroupID = '$acc' and acc.DeletedOn is null and u.DeletedOn is null and lg.Name is not null
group by lg.lightboxgroupid,acc.AccountID" -s , -W -k1 > Output/"$name"_lightbox_groupid.csv

sed -e 's/-,//g;s/-//g;s/,,//g;/^$/d' Output/"$name"_lightbox_groupid.csv > Final_CSV/"$name"_lightbox_groupid.csv

res2=$(date +%s.%N)
dt=$(echo "$res2 - $res1" | bc)
dd=$(echo "$dt/86400" | bc)
dt2=$(echo "$dt-86400*$dd" | bc)
dh=$(echo "$dt2/3600" | bc)
dt3=$(echo "$dt2-3600*$dh" | bc)
dm=$(echo "$dt3/60" | bc)
ds=$(echo "$dt3-60*$dm" | bc)
timetaken=$(LC_NUMERIC=C printf "%d:%02d:%02d:%02.4f\n" $dd $dh $dm $ds)

echo "Report-12 "$name"_lightbox_groupid.csv -> done TimeTaken: $timetaken"

sleep 1s

echo "Processing "$name"_lightbox_commentid.csv"

res1=$(date +%s.%N)

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

sed -e 's/-,//g;s/-//g;s/,,//g;/^$/d' Output/"$name"_lightbox_commentid.csv > Final_CSV/"$name"_lightbox_commentid.csv

res2=$(date +%s.%N)
dt=$(echo "$res2 - $res1" | bc)
dd=$(echo "$dt/86400" | bc)
dt2=$(echo "$dt-86400*$dd" | bc)
dh=$(echo "$dt2/3600" | bc)
dt3=$(echo "$dt2-3600*$dh" | bc)
dm=$(echo "$dt3/60" | bc)
ds=$(echo "$dt3-60*$dm" | bc)
timetaken=$(LC_NUMERIC=C printf "%d:%02d:%02d:%02.4f\n" $dd $dh $dm $ds)

echo "Report-13 "$name"_lightbox_commentid.csv -> done TimeTaken: $timetaken"

sleep 1s

echo "Processing "$name"_lightbox_invitationid.csv file"

res1=$(date +%s.%N)

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

sed -e 's/-,//g;s/-//g;s/,,//g;/^$/d' Output/"$name"_lightbox_invitationid.csv > Final_CSV/"$name"_lightbox_invitationid.csv

res2=$(date +%s.%N)
dt=$(echo "$res2 - $res1" | bc)
dd=$(echo "$dt/86400" | bc)
dt2=$(echo "$dt-86400*$dd" | bc)
dh=$(echo "$dt2/3600" | bc)
dt3=$(echo "$dt2-3600*$dh" | bc)
dm=$(echo "$dt3/60" | bc)
ds=$(echo "$dt3-60*$dm" | bc)
timetaken=$(LC_NUMERIC=C printf "%d:%02d:%02d:%02.4f\n" $dd $dh $dm $ds)

echo "Report-14 "$name"_lightbox_invitationid.csv-> done TimeTaken: $timetaken"

sleep 1s

echo "Processing "$name"_assetHistory_item_TypeID.csv file"

res1=$(date +%s.%N)

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

sed -e 's/-,//g;s/-//g;s/,,//g;/^$/d' Output/"$name"_assetHistory_item_TypeID.csv > Final_CSV/"$name"_assetHistory_item_TypeID.csv

res2=$(date +%s.%N)
dt=$(echo "$res2 - $res1" | bc)
dd=$(echo "$dt/86400" | bc)
dt2=$(echo "$dt-86400*$dd" | bc)
dh=$(echo "$dt2/3600" | bc)
dt3=$(echo "$dt2-3600*$dh" | bc)
dm=$(echo "$dt3/60" | bc)
ds=$(echo "$dt3-60*$dm" | bc)
timetaken=$(LC_NUMERIC=C printf "%d:%02d:%02d:%02.4f\n" $dd $dh $dm $ds)

echo "Report-15 "$name"_assetHistory_item_TypeID.csv-> done TimeTaken: $timetaken"

sleep 1s

echo "Processing "$name"_asset_metadataid_mapped.csv file"

res1=$(date +%s.%N)

#ge-{AccountGroupName}-asset_metadataid_mapped
sqlcmd -S PRD-DB-02.ics.com -U sa -P 'SQL h@$ N0 =' -d ge -Q "set nocount on;
select distinct a.AssetID, am.AssetMetadataID,acc.AccountID  from AccountGroup ag
inner join Account acc on acc.AccountGroupID = ag.AccountGroupID
inner join Job j on j.OwnerAccountID = acc.AccountID
inner join Asset a on a.JobID = j.JobiD
inner join AssetMetadata am on am.AssetID = a.AssetID
where ag.AccountGroupID = '$acc' and a.DeletetedOn is null and j.DeletedOn is null
AND am.MetadataPropertyID  NOT IN (60,62,63,64,65,78,79,80,81,82,83,84,85,86,87,88,89,90,91,92,93,94,95,96,97,98,99,100,13043,13046,13047)" -s , -W -k1 > Output/"$name"_asset_metadataid_mapped.csv

sed -e 's/-,//g;s/-//g;s/,,//g;/^$/d' Output/"$name"_asset_metadataid_mapped.csv > Final_CSV/"$name"_asset_metadataid_mapped.csv

res2=$(date +%s.%N)
dt=$(echo "$res2 - $res1" | bc)
dd=$(echo "$dt/86400" | bc)
dt2=$(echo "$dt-86400*$dd" | bc)
dh=$(echo "$dt2/3600" | bc)
dt3=$(echo "$dt2-3600*$dh" | bc)
dm=$(echo "$dt3/60" | bc)
ds=$(echo "$dt3-60*$dm" | bc)
timetaken=$(LC_NUMERIC=C printf "%d:%02d:%02d:%02.4f\n" $dd $dh $dm $ds)

echo "Report-16 "$name"_asset_metadataid_mapped.csv -> done TimeTaken: $timetaken"

sleep 1s

echo "Skipping "$name"_asset_metadataid_unmapped.csv file"

#ge-{AccountGroupName}-asset_metadataid_unmapped
#sqlcmd -S PRD-DB-02.ics.com -U sa -P 'SQL h@$ N0 =' -d ge -Q "set nocount on;
#select distinct a.AssetID, am.AssetMetadataID,acc.AccountID  from AccountGroup ag
#inner join Account acc on acc.AccountGroupID = ag.AccountGroupID
#inner join Job j on j.OwnerAccountID = acc.AccountID
#inner join Asset a on a.JobID = j.JobiD
#inner join AssetMetadata am on am.AssetID = a.AssetID
#where ag.AccountGroupID = '$acc' and a.DeletetedOn is null and j.DeletedOn is null
#AND am.MetadataPropertyID  IN (60,62,63,64,65,78,79,80,81,82,83,84,85,86,87,88,89,90,91,92,93,94,95,96,97,98,99,100,13043,13046,13047)" -s , -W -k1 > Output/"$name"_asset_metadataid_unmapped.csv

#sed -e 's/-,//g;s/-//g;s/,,//g;/^$/d' Output/"$name"_asset_metadataid_unmapped.csv > Final_CSV/"$name"_asset_metadataid_unmapped.csv

echo "Report-17 "$name"_asset_metadataid_unmapped.csv -> Skipped (Not Needed)"

sleep 1s

echo "Processing "$name"_unsupported_files.csv file"

res1=$(date +%s.%N)

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

sed -e 's/-,//g;s/-//g;s/,,//g;/^$/d' Output/"$name"_unsupported_files.csv > Final_CSV/"$name"_unsupported_files.csv

res2=$(date +%s.%N)
dt=$(echo "$res2 - $res1" | bc)
dd=$(echo "$dt/86400" | bc)
dt2=$(echo "$dt-86400*$dd" | bc)
dh=$(echo "$dt2/3600" | bc)
dt3=$(echo "$dt2-3600*$dh" | bc)
dm=$(echo "$dt3/60" | bc)
ds=$(echo "$dt3-60*$dm" | bc)
timetaken=$(LC_NUMERIC=C printf "%d:%02d:%02d:%02.4f\n" $dd $dh $dm $ds)

echo "Report-18 "$name"_unsupported_files.csv -> done TimeTaken: $timetaken"

sleep 1s

echo "Processing "$name"_Watermarks.csv file"

res1=$(date +%s.%N)

#ge-{org_name}_Watermarks.csv
sqlcmd -S PRD-DB-02.ics.com -U sa -P 'SQL h@$ N0 =' -d ge -Q "set nocount on;
select ag.AccountGroupID, ag.Name as [AccountGroupName], a.AccountID,a.AccountName, count(distinct WatermarkID) as [WatermarkCount] from AccountGroup ag
inner join Account a on ag.AccountGroupID=a.AccountGroupID
inner join AssetRightsWatermark arw on a.AccountID=arw.AccountID
left join ApprovalGalleryWatermarkType agwt on arw.WatermarkType=agwt.ApprovalGalleryWatermarkTypeID
where ag.AccountGroupID= '$acc'
group by ag.AccountGroupID, ag.Name,
a.AccountID,a.AccountName
order by ag.AccountGroupID,a.AccountID" -s , -W -k1 > Output/"$name"_Watermarks.csv

sed -e 's/-,//g;s/-//g;s/,,//g;/^$/d' Output/"$name"_Watermarks.csv > Final_CSV/"$name"_Watermarks.csv

res2=$(date +%s.%N)
dt=$(echo "$res2 - $res1" | bc)
dd=$(echo "$dt/86400" | bc)
dt2=$(echo "$dt-86400*$dd" | bc)
dh=$(echo "$dt2/3600" | bc)
dt3=$(echo "$dt2-3600*$dh" | bc)
dm=$(echo "$dt3/60" | bc)
ds=$(echo "$dt3-60*$dm" | bc)
timetaken=$(LC_NUMERIC=C printf "%d:%02d:%02d:%02.4f\n" $dd $dh $dm $ds)

echo "Report-19 "$name"_Watermarks.csv -> done TimeTaken: $timetaken"

sleep 1s

echo "Processing "$name"_WatermarkAssets.csvfile"

res1=$(date +%s.%N)

#ge-{org_name}_WatermarkAssets.csv
sqlcmd -S PRD-DB-02.ics.com -U sa -P 'SQL h@$ N0 =' -d ge -Q "set nocount on;
select ag.AccountGroupID,ag.Name as [AccountGroupName], a.AccountID,a.AccountName,count(distinct arr.AssetID) as [AssetCount]  From AccountGroup ag
inner join Account a on ag.AccountGroupID=a.AccountGroupID
inner join job j on a.AccountID=j.OwnerAccountID
inner join JobFolder jf on j.JobID=jf.JobID
inner join Asset at on j.JobID=at.JobID
left join AssetRightsRestriction arr on at.AssetID=arr.AssetID and arr.AccessLevelID in(1,3,6)
where at.DeletetedOn is null and j.DeletedOn is null and jf.DeletedOn is null and ag.AccountGroupID= '$acc' 
group by ag.AccountGroupID,ag.Name,a.AccountID,a.AccountName
order by ag.AccountGroupID,ag.Name,a.AccountID,a.AccountName" -s , -W -k1 > Output/"$name"_WatermarkAssets.csv

sed -e 's/-,//g;s/-//g;s/,,//g;/^$/d' Output/"$name"_WatermarkAssets.csv > Final_CSV/"$name"_WatermarkAssets.csv

res2=$(date +%s.%N)
dt=$(echo "$res2 - $res1" | bc)
dd=$(echo "$dt/86400" | bc)
dt2=$(echo "$dt-86400*$dd" | bc)
dh=$(echo "$dt2/3600" | bc)
dt3=$(echo "$dt2-3600*$dh" | bc)
dm=$(echo "$dt3/60" | bc)
ds=$(echo "$dt3-60*$dm" | bc)
timetaken=$(LC_NUMERIC=C printf "%d:%02d:%02d:%02.4f\n" $dd $dh $dm $ds)

echo "Report-20 "$name"_WatermarkAssets.csv -> done TimeTaken: $timetaken"

sleep 1s

echo "Processing "$name"_Watermark_Detail.csv file"

res1=$(date +%s.%N)

#ge-{org_name}_Watermark_Detail.csv
sqlcmd -S PRD-DB-02.ics.com -U sa -P 'SQL h@$ N0 =' -d ge -Q "set nocount on;
select ag.AccountGroupID, ag.Name as [AccountGroupName], a.AccountID,a.AccountName, arw.WatermarkID,agwt.ApprovalGalleryWatermarkTypeID as [WatermarkTypeID], agwt.Name as WatermarkType, 
arw.ImageWatermark,  '\"'"' +arw.TextWatermark+ '"'\"' as [TextWatermark], '\"'"' +arw.FileName+ '"'\"' as [FileName],arw.ModifiedBy,cast(arw.ModifiedDate as date) as [ModifiedDate],
arw.FontName,arw.FontSize,arw.TextColor,arw.TextAngle,arw.TextStyle,arw.TextOpacity,arw.Position from AccountGroup ag
inner join Account a on ag.AccountGroupID=a.AccountGroupID
inner join AssetRightsWatermark arw on a.AccountID=arw.AccountID
inner join ApprovalGalleryWatermarkType agwt on arw.WatermarkType=agwt.ApprovalGalleryWatermarkTypeID
where ag.AccountGroupID='$acc'" -s , -W -k1 > Output/"$name"_Watermark_Detail.csv

sed -e 's/-,//g;s/-//g;s/,,//g;/^$/d' Output/"$name"_Watermark_Detail.csv > Final_CSV/"$name"_Watermark_Detail.csv

res2=$(date +%s.%N)
dt=$(echo "$res2 - $res1" | bc)
dd=$(echo "$dt/86400" | bc)
dt2=$(echo "$dt-86400*$dd" | bc)
dh=$(echo "$dt2/3600" | bc)
dt3=$(echo "$dt2-3600*$dh" | bc)
dm=$(echo "$dt3/60" | bc)
ds=$(echo "$dt3-60*$dm" | bc)
timetaken=$(LC_NUMERIC=C printf "%d:%02d:%02d:%02.4f\n" $dd $dh $dm $ds)

echo "Report-21 "$name"_Watermark_Detail.csv -> done TimeTaken: $timetaken"

sleep 1s

echo "Processing "$name"_LightBox_Details.csv file"

res1=$(date +%s.%N)

#ge-{org_name}_LightBox_Details.csv

sqlcmd -S PRD-DB-02.ics.com -U sa -P 'SQL h@$ N0 =' -d ge -Q "set nocount on;
WITH CTE as(
select distinct ag.AccountGroupID, ag.name as [AccountGroupName],
a.AccountID, a.AccountName,lb.lightboxid,
lb.Name as [LightboxName],
lb.ownerid as[CreatorID],
concat(isnull(u.FirstName,''),' ' ,isnull(u.LastName,'')) as CreatedBy,
CASE WHEN u.IsCasual = 1 THEN 'Casual'
        when u.IsTalent = 1 then 'Talent'
        when u.Guest =1 then 'Guest'
        when u.AccountAdmin=1 then 'Admin'
        else 'NoRole'
end [Role of created by user],
cast(i.ExpiredOn as date) as ExpirationDate,
  (select count(distinct guestid)   
           FROM 
                        Lightbox l 
                        INNER JOIN Invitation i on l.LightboxID=i.SharedObjectID and InvitationTypeCd='LightboxInvitation' 
                        INNER JOIN [User] u on i.Guestid=u.userid
                        where l.lightboxid=lb.lightboxid
          ) as [Number of recipients],
  REPLACE(REPLACE(STUFF((SELECT ' | ' + (
  rtrim(ltrim(u.UserID)+ ' - '+concat(isnull(u.FirstName,''),' ' ,isnull(u.LastName,'')))
  +' - '+
  CASE WHEN u.IsCasual = 1 THEN 'Casual'
        when u.IsTalent = 1 then 'Talent'
        when u.Guest =1 then 'Guest'
        when u.AccountAdmin=1 then 'Admin'
        else 'NoRole'
  end
  )
           FROM 
                        Lightbox l 
                        INNER JOIN Invitation i on l.LightboxID=i.SharedObjectID and InvitationTypeCd='LightboxInvitation' 
                        INNER JOIN [User] u on i.Guestid=u.userid
                        where l.lightboxid=lb.lightboxid
          FOR XML PATH('')), 1, 2, ''), CHAR(13), ''), CHAR(10), '') as [Recipient Users Details],                  
                  case when (agwt.name is null or agwt.Name='None') then '0' else'1' end as [IsWatermarkEnabled],
agwt.Name as [WatermarkType]
--case when arw.FileName is not null then 'Image' else agwt.Name end as [WatermarkType]
  from
AccountGroup ag 
inner join Account a on ag.AccountGroupId=a.AccountGroupID
inner join [User] u on a.AccountID=u.AccountID
inner join Lightbox lb on u.UserID=lb.OwnerID
inner join Invitation i on lb.LightboxID=i.SharedObjectID and InvitationTypeCd='LightboxInvitation' 
left join approvalgallerywatermarktype agwt on i.WatermarkType=agwt.ApprovalGalleryWatermarkTypeID

where ag.AccountGroupID='$acc' 
)

select AccountGroupID,AccountGroupName,AccountID,AccountName,
a.LightboxID,LightboxName,ExpirationDate,CreatorID,a.CreatedBy,[Role of created by user],[Number of recipients],[Recipient Users Details],
IsWatermarkEnabled,WatermarkType,
count(at.AssetID) as Asset_Count

From CTE a
left join lightboxasset lba on a.lightboxid=lba.lightboxid
LEFT JOIN ASSET at on lba.assetid=at.assetid and at.DeletetedOn is null
group by AccountGroupID,AccountGroupName,AccountID,AccountName,
a.LightboxID,LightboxName,ExpirationDate,CreatorID,a.CreatedBy,[Role of created by user],[Number of recipients],[Recipient Users Details],
IsWatermarkEnabled,WatermarkType                                        
order by LightboxID" -s , -W -k1 > Output/"$name"_LightBox_Details.csv

sed -e 's/-,//g;s/-//g;s/,,//g;/^$/d' Output/"$name"_LightBox_Details.csv > Final_CSV/"$name"_LightBox_Details.csv

res2=$(date +%s.%N)
dt=$(echo "$res2 - $res1" | bc)
dd=$(echo "$dt/86400" | bc)
dt2=$(echo "$dt-86400*$dd" | bc)
dh=$(echo "$dt2/3600" | bc)
dt3=$(echo "$dt2-3600*$dh" | bc)
dm=$(echo "$dt3/60" | bc)
ds=$(echo "$dt3-60*$dm" | bc)
timetaken=$(LC_NUMERIC=C printf "%d:%02d:%02d:%02.4f\n" $dd $dh $dm $ds)

echo "Report-22 "$name"_LightBox_Details.csv -> done TimeTaken: $timetaken"

sleep 1s

echo "Processing "$name"_ApprovalGallery.csv file"

res1=$(date +%s.%N)

#ge-{org_name}_ApprovalGallery_Detail.csv

sqlcmd -S PRD-DB-02.ics.com -U sa -P 'SQL h@$ N0 =' -d ge -Q "set nocount on;
with CTE as(
select distinct
ag.AccountGroupID,
ag.Name as [AccountGroupName],
a.AccountID,
a.AccountName,
g.ApprovalGalleryID,
'\"'"' +g.Name+ '"'\"' as ApprovalGalleryName,
cast(g.ExpirationDate as date)  as [ExpirationDate],
g.CreatorUserID as CreatorID,
concat(isnull(ug.FirstName,''),' ' ,isnull(ug.LastName,'')) as CreatedBy,
CASE WHEN ug.IsCasual = 1 THEN 'Casual'
        when ug.IsTalent = 1 then 'Talent'
        when ug.Guest =1 then 'Guest'
        when ug.AccountAdmin=1 then 'Admin'
        else 'NoRole'
end [Role of created by user],
  (select count(*)   
           FROM 
                        ApprovalGallery ag 
                        INNER JOIN ApprovalGalleryUser agu on ag.ApprovalGalleryID=agu.ApprovalGalleryID
                        INNER JOIN [User] u on agu.UserID=u.UserID
                        where ag.ApprovalGalleryID=g.ApprovalGalleryID
          ) as [Number of recipients],
  REPLACE(REPLACE(STUFF((SELECT ' | ' + (
  rtrim(ltrim(u.UserID)+ ' - '+concat(isnull(u.FirstName,''),' ' ,isnull(u.LastName,'')))
  +' - '+
  CASE WHEN u.IsCasual = 1 THEN 'Casual'
        when u.IsTalent = 1 then 'Talent'
        when u.Guest =1 then 'Guest'
        when u.AccountAdmin=1 then 'Admin'
        else 'NoRole'
  end
  )
           FROM 
                        ApprovalGallery ag 
                        INNER JOIN ApprovalGalleryUser agu on ag.ApprovalGalleryID=agu.ApprovalGalleryID
                        INNER JOIN [User] u on agu.UserID=u.UserID
                        where ag.ApprovalGalleryID=g.ApprovalGalleryID
          FOR XML PATH('')), 1, 2, ''), CHAR(13), ''), CHAR(10), '') as [Recipient Users Details],
case when agwt.Name='None' then '0' else'1' end as [IsWatermarkEnabled],
--agwt.Name as [WatermarkType],
case when arw.FileName is not null then 'Image' else agwt.Name end as [WatermarkType]
from
AccountGroup ag 
inner join Account a on ag.AccountGroupId=a.AccountGroupID
inner join ApprovalGallery g on g.AccountID=a.AccountID
inner join ApprovalGalleryCollection agc on g.ApprovalGalleryID=agc.ApprovalGalleryID
inner join [User] ug on g.CreatorUserID=ug.UserID
inner join ApprovalGalleryWatermarkType agwt on g.ApprovalGalleryWatermarkTypeID=agwt.ApprovalGalleryWatermarkTypeID
left join AssetRightsWatermark arw on a.AccountID=arw.AccountID and agwt.ApprovalGalleryWatermarkTypeID=arw.WatermarkType
left JOIN ApprovalGalleryUser agu on g.ApprovalGalleryID=agu.ApprovalGalleryID
left JOIN [User] u on agu.UserID=u.UserID 
where ag.AccountGroupId = '$acc'
and a.DeletedOn is null  and g.DeleteDate is null and g.DeletedBy is null and a.DeletedBy is null
and (
--(g.DoneDate is not null and g.ExpirationDate is not null) or (g.DoneDate is not null and g.ExpirationDate is null) or (g.DoneDate is null and g.ExpirationDate is not null)
g.ExpirationDate <=Getdate() or g.DoneDate is not null
)
and 
( -- should has asset source
        agc.JobFolderID is not null
        or
        agc.JobID is not  null
        or 
        agc.LightboxID is not null
)
)



select 
AccountGroupID,AccountGroupName,AccountID,AccountName,a.ApprovalGalleryID,ApprovalGalleryName,ExpirationDate,CreatorID,a.CreatedBy,[Role of created by user],[Number of recipients],[Recipient Users Details],
IsWatermarkEnabled,WatermarkType, count(at.AssetID) as [Asset_Count]

from CTE a
left join ApprovalGalleryAsset aga on a.ApprovalGalleryID=aga.ApprovalGalleryID
left join asset at on aga.AssetID=at.AssetID and at.DeletetedOn is null
group by 
AccountGroupID,AccountGroupName,AccountID,AccountName,a.ApprovalGalleryID,ApprovalGalleryName,ExpirationDate,CreatorID,a.CreatedBy,[Role of created by user],[Number of recipients],[Recipient Users Details],
IsWatermarkEnabled,WatermarkType;" -s , -W -k1 > Output/"$name"_ApprovalGallery.csv

sed -e 's/-,//g;s/-//g;s/,,//g;/^$/d' Output/"$name"_ApprovalGallery.csv > Final_CSV/"$name"_ApprovalGallery.csv

res2=$(date +%s.%N)
dt=$(echo "$res2 - $res1" | bc)
dd=$(echo "$dt/86400" | bc)
dt2=$(echo "$dt-86400*$dd" | bc)
dh=$(echo "$dt2/3600" | bc)
dt3=$(echo "$dt2-3600*$dh" | bc)
dm=$(echo "$dt3/60" | bc)
ds=$(echo "$dt3-60*$dm" | bc)
timetaken=$(LC_NUMERIC=C printf "%d:%02d:%02d:%02.4f\n" $dd $dh $dm $ds)

echo "Report-23 "$name"_ApprovalGallery.csv -> done TimeTaken: $timetaken"

sleep 1s

echo "Processing "$name"_ApprovalGallery_HashNotes_1.csv file"

res1=$(date +%s.%N)

#ge-{org_name}_ApprovalGallery_HashNotes_1.csv

sqlcmd -S PRD-DB-02.ics.com -U sa -P 'SQL h@$ N0 =' -d ge -Q "set nocount on;
WITH CTE as (
select nh.NotesHistoryID, ag.ApprovalGalleryID, '\"'"' +nh.Text+ '"'\"' as [Notes], nh.AssetID From NoteHistory nh 
inner join ApprovalGalleryUser agu on nh.ApprovalGalleryUserID=agu.ApprovalGalleryUserID
inner join ApprovalGallery ag on agu.ApprovalGalleryID=ag.ApprovalGalleryID
inner join ApprovalGalleryCollection agc on ag.ApprovalGalleryID=agc.ApprovalGalleryID
inner join Account a on ag.AccountID=a.AccountID
inner join AccountGroup acg on a.AccountGroupID=acg.AccountGroupID
where acg.AccountGroupID= '$acc' and a.DeletedOn is null and a.DeletedBy is null and ag.DeleteDate is null and ag.DeletedBy is null
and (
ag.ExpirationDate <=Getdate() or ag.DoneDate is not null
)
and 
( -- should has asset source
        agc.JobFolderID is not null
        or
        agc.JobID is not null
        or 
        agc.LightboxID is not null
)
)

select acg.AccountGroupID, a.AccountID, apg.ApprovalGalleryID, c.NotesHistoryID, c.Notes, 
case when c.NotesHistoryID is null then '0' else '1' end as [HasNotes], c.AssetID From AccountGroup acg
inner join Account a on acg.AccountGroupID=a.AccountGroupID
inner join ApprovalGallery apg on a.AccountID=apg.AccountID
inner join ApprovalGalleryCollection agc on apg.ApprovalGalleryID=agc.ApprovalGalleryID
left  join CTE c on apg.ApprovalGalleryID=c.ApprovalGalleryID
where acg.AccountGroupID= '$acc' and c.NotesHistoryID is not null and 
 a.DeletedOn is null and a.DeletedBy is null and apg.DeleteDate is null and apg.DeletedBy is null
and (
apg.ExpirationDate <=Getdate() or apg.DoneDate is not null
)
and 
( -- should has asset source
        agc.JobFolderID is not null
        or
        agc.JobID is not null
        or 
        agc.LightboxID is not null
)
--(
--(apg.DoneDate is not null and apg.ExpirationDate is not null) or (apg.DoneDate is not null and apg.ExpirationDate is null) or (apg.DoneDate is null and apg.ExpirationDate is not null)
--)" -s , -W -k1 > Output/"$name"_ApprovalGallery_HashNotes_1.csv

sed -e 's/-,//g;s/-//g;s/,,//g;/^$/d' Output/"$name"_ApprovalGallery_HashNotes_1.csv > Final_CSV/"$name"_ApprovalGallery_HashNotes_1.csv

res2=$(date +%s.%N)
dt=$(echo "$res2 - $res1" | bc)
dd=$(echo "$dt/86400" | bc)
dt2=$(echo "$dt-86400*$dd" | bc)
dh=$(echo "$dt2/3600" | bc)
dt3=$(echo "$dt2-3600*$dh" | bc)
dm=$(echo "$dt3/60" | bc)
ds=$(echo "$dt3-60*$dm" | bc)
timetaken=$(LC_NUMERIC=C printf "%d:%02d:%02d:%02.4f\n" $dd $dh $dm $ds)

echo "Report-24 "$name"_ApprovalGallery_HashNotes_1.csv -> done TimeTaken: $timetaken"

sleep 1s

echo "Processing "$name"_ApprovalGallery_HashNotes_0.csv file"

res1=$(date +%s.%N)

#ge-{org_name}_ApprovalGallery_HashNotes_0.csv
sqlcmd -S PRD-DB-02.ics.com -U sa -P 'SQL h@$ N0 =' -d ge -Q "set nocount on;
WITH CTE as (
select nh.NotesHistoryID, ag.ApprovalGalleryID, '\"'"' +nh.Text+ '"'\"' as [Notes], nh.AssetID From NoteHistory nh 
inner join ApprovalGalleryUser agu on nh.ApprovalGalleryUserID=agu.ApprovalGalleryUserID
inner join ApprovalGallery ag on agu.ApprovalGalleryID=ag.ApprovalGalleryID
inner join ApprovalGalleryCollection agc on ag.ApprovalGalleryID=agc.ApprovalGalleryID
inner join Account a on ag.AccountID=a.AccountID
inner join AccountGroup acg on a.AccountGroupID=acg.AccountGroupID
where acg.AccountGroupID= '$acc'
and a.DeletedOn is null  and ag.DeleteDate is null and ag.DeletedBy is null and a.DeletedBy is null
and (
ag.ExpirationDate <=Getdate() or ag.DoneDate is not null
)
and 
( -- should has asset source
        agc.JobFolderID is not null
        or
        agc.JobID is not null
        or 
        agc.LightboxID is not null
)
)


select acg.AccountGroupID, a.AccountID, apg.ApprovalGalleryID, c.NotesHistoryID, c.Notes, 
case when c.NotesHistoryID is null then '0' else '1' end as [HasNotes], c.AssetID From AccountGroup acg
inner join Account a on acg.AccountGroupID=a.AccountGroupID
inner join ApprovalGallery apg on a.AccountID=apg.AccountID
inner join ApprovalGalleryCollection agc on apg.ApprovalGalleryID=agc.ApprovalGalleryID
left  join CTE c on apg.ApprovalGalleryID=c.ApprovalGalleryID
where acg.AccountGroupID= '$acc' and c.NotesHistoryID is  null
and a.DeletedOn is null  and apg.DeleteDate is null and apg.DeletedBy is null and a.DeletedBy is null and (
apg.ExpirationDate <=Getdate() or apg.DoneDate is not null
)
and 
( -- should has asset source
        agc.JobFolderID is not null
        or
        agc.JobID is not null
        or 
        agc.LightboxID is not null
)
--and (
--(apg.DoneDate is not null and apg.ExpirationDate is not null) or (apg.DoneDate is not null and apg.ExpirationDate is null) or (apg.DoneDate is null and apg.ExpirationDate is not null)
--)" -s , -W -k1 > Output/"$name"_ApprovalGallery_HashNotes_0.csv

sed -e 's/-,//g;s/-//g;s/,,//g;/^$/d' Output/"$name"_ApprovalGallery_HashNotes_0.csv > Final_CSV/"$name"_ApprovalGallery_HashNotes_0.csv

res2=$(date +%s.%N)
dt=$(echo "$res2 - $res1" | bc)
dd=$(echo "$dt/86400" | bc)
dt2=$(echo "$dt-86400*$dd" | bc)
dh=$(echo "$dt2/3600" | bc)
dt3=$(echo "$dt2-3600*$dh" | bc)
dm=$(echo "$dt3/60" | bc)
ds=$(echo "$dt3-60*$dm" | bc)
timetaken=$(LC_NUMERIC=C printf "%d:%02d:%02d:%02.4f\n" $dd $dh $dm $ds)

echo "Report-25 "$name"_ApprovalGallery_HashNotes_0.csv-> done TimeTaken: $timetaken"

sleep 1s

echo "Processing "$name"_FolderAssignmentsid.csv file"

res1=$(date +%s.%N)

#ge-{org_name}_FolderAssignmentsid.csv
sqlcmd -S PRD-DB-02.ics.com -U sa -P 'SQL h@$ N0 =' -d ge -Q "set nocount on;

select 
ag.AccountGroupID,
ag.Name as AccountGroupName,
a.AccountID,
a.AccountName,
u.UserID,
concat(u.FirstName,' ',u.LastName) as UserName,
u.Email,
u.LoginName,
uj.UserJobID,
cast(uj.expirationdate as date) as UserJobExpirationDate,
uj.JobID,
j.JobName,
uj.JobFolderID,
dbo.udf_GetFolderPath(uj.JobFolderID) as FolderPath,
ar.AccountRoleID,
ar.RoleName
From AccountGroup ag
inner join Account a on ag.AccountGroupID=a.AccountGroupID
inner join [User] u on a.AccountID=u.AccountID 
inner join UserJob uj on u.UserID=uj.UserID
inner join Job j on uj.JobID=j.JobID
left join JobFolder jf on uj.JobFolderID=jf.JobFolderID
left join AccountRole ar on uj.AccountRoleID=ar.AccountRoleID
where a.DeletedOn is null and u.DeletedOn is null
and ag.AccountGroupID='$acc'
and j.DeletedOn is null
and jf.DeletedOn is null" -s , -W -k1 > Output/"$name"_FolderAssignmentsid.csv

sed -e 's/-,//g;s/-//g;s/,,//g;/^$/d' Output/"$name"_FolderAssignmentsid.csv > Final_CSV/"$name"_FolderAssignmentsid.csv

res2=$(date +%s.%N)
dt=$(echo "$res2 - $res1" | bc)
dd=$(echo "$dt/86400" | bc)
dt2=$(echo "$dt-86400*$dd" | bc)
dh=$(echo "$dt2/3600" | bc)
dt3=$(echo "$dt2-3600*$dh" | bc)
dm=$(echo "$dt3/60" | bc)
ds=$(echo "$dt3-60*$dm" | bc)
timetaken=$(LC_NUMERIC=C printf "%d:%02d:%02d:%02.4f\n" $dd $dh $dm $ds)

echo "Report-26 "$name"_FolderAssignmentsid.csv -> done TimeTaken: $timetaken"

sleep 1s

echo "Processing "$name"_comments_assetsid.csv file"

res1=$(date +%s.%N)

#ge-{org_name}_comment_assetsid.csv

sqlcmd -S PRD-DB-02.ics.com -U sa -P 'SQL h@$ N0 =' -d ge -Q "set nocount on;

declare @temp table(
AssetID int,
Notehistoryid int,
NoOfUsersMentions int,
MentionedUsers nvarchar(max),
NHUserID int
)
declare @mention varchar(20)='data-mention=""',@delim varchar(1)='""'
​
DECLARE @NotesHistoryID int, @AssetID int, @Text varchar(max), @NHUserID int;   
​
​
DECLARE note_cursor CURSOR FOR     
SELECT nh.NotesHistoryID,at.AssetID, nh.[Text], nh.CreatedBy as NHUserID 
FROM AccountGroup ag
inner join Account a on ag.AccountGroupID=a.AccountGroupID
inner join Job j on a.AccountID=j.OwnerAccountID
inner join Asset at on j.JobID=at.JobID
inner join NoteHistory nh on at.AssetID=nh.AssetID
where a.DeletedOn is null and j.DeletedOn is null
and at.DeletetedOn is null
and ag.AccountGroupID='$acc'
--and [Text] like '%data-mention%'
--and a.AccountID=3389
  
OPEN note_cursor
​
FETCH NEXT FROM note_cursor     
INTO @NotesHistoryID,@AssetID,@Text,@NHUserID
​
WHILE @@FETCH_STATUS = 0    
BEGIN    
​
IF(@Text LIKE '%'+@mention+'%')
BEGIN
​
DECLARE @StartPos INT, @EndPos int
declare @count int =0;
declare @users nvarchar(max)=''
declare @user nvarchar(10)
        set @StartPos =CASE WHEN CHARINDEX(@mention, @Text) > 0 THEN  CHARINDEX(@mention, @Text) +  LEN(@mention) ELSE CHARINDEX(@mention, @Text) END
        set @EndPos = CHARINDEX(@delim, @Text,@StartPos)
​
    WHILE @StartPos > 0 and @EndPos > 0
    BEGIN
​
        set @users = @users + SUBSTRING(@Text, (@StartPos),@EndPos - @StartPos) +','
​
        set @count = @count + 1;
​
        SET @Text = RIGHT(@Text, LEN(@Text) - @EndPos)
​
        set @StartPos =CASE WHEN CHARINDEX(@mention, @Text) > 0 THEN  CHARINDEX(@mention, @Text) +  LEN(@mention) ELSE CHARINDEX(@mention, @Text) END
        set @EndPos = CHARINDEX(@delim, @Text,@StartPos)
​
        END
​
INSERT INTO @temp
        SELECT @AssetID, @NotesHistoryID,@count,CASE WHEN @users <> '' THEN LEFT(@users,LEN(@users) - 1) ELSE @users END, @NHUserID
​
END
ELSE
BEGIN
INSERT INTO @temp
        SELECT @AssetID, @NotesHistoryID,0,'', @NHUserID
END
​
​
​
FETCH NEXT FROM note_cursor     
INTO @NotesHistoryID,@AssetID,@Text,@NHUserID
   
END     
CLOSE note_cursor;    
DEALLOCATE note_cursor;   
​
​
----- Final Result -------
select 
ag.AccountGroupID as GEL_AccountGroupID,
a.AccountID as GEL_AccountID,
t.NHUserID as GEL_UserId,
t.AssetID as GEL_AssetId,
t.Notehistoryid as GEL_AssetNoteId,
t.MentionedUsers as GEL_MentionedUsersIds,
t.NoOfUsersMentions as GEL_MentionedUsersCount
from @temp t
inner join Asset at on t.AssetID=at.AssetID
inner join Job j on at.JobID=j.JobID
inner join Account a on j.OwnerAccountID=a.AccountID
inner join AccountGroup ag on a.AccountGroupID=ag.AccountGroupID" -s , -W -k1 > Output/"$name"_comments_assetsid.csv

sed -e 's/-,//g;s/-//g;s/,,//g;/^$/d' Output/"$name"_comments_assetsid.csv > Final_CSV/"$name"_comments_assetsid.csv

res2=$(date +%s.%N)
dt=$(echo "$res2 - $res1" | bc)
dd=$(echo "$dt/86400" | bc)
dt2=$(echo "$dt-86400*$dd" | bc)
dh=$(echo "$dt2/3600" | bc)
dt3=$(echo "$dt2-3600*$dh" | bc)
dm=$(echo "$dt3/60" | bc)
ds=$(echo "$dt3-60*$dm" | bc)
timetaken=$(LC_NUMERIC=C printf "%d:%02d:%02d:%02.4f\n" $dd $dh $dm $ds)

echo "Report-27 "$name"_comments_assetsid.csv -> done TimeTaken: $timetaken"

sleep 1s

res21=$(date +%s.%N)
dt=$(echo "$res21 - $res11" | bc)
dd=$(echo "$dt/86400" | bc)
dt2=$(echo "$dt-86400*$dd" | bc)
dh=$(echo "$dt2/3600" | bc)
dt3=$(echo "$dt2-3600*$dh" | bc)
dm=$(echo "$dt3/60" | bc)
ds=$(echo "$dt3-60*$dm" | bc)
timetaken=$(LC_NUMERIC=C printf "%d:%02d:%02d:%02.4f\n" $dd $dh $dm $ds)

echo "Total TimeTaken for all reports: $timetaken"

echo "**************All reports has been generated!!!******************"





