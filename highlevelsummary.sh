#!/bin/bash
echo Enter accountid:
read acc
#echo Enter the Accountid for getting Unsupported Files:
#read accid
echo Enter the CSV Firstname:
read name


#HighLevelSummary-query

sqlcmd -S PRD-DB-02.ics.com -U sa -P 'SQL h@$ N0 =' -d ge -Q "set nocount on;

use GE;

--Variable declaration
declare @AccountID bigint = 3490;
declare @NoOfLightBoxGroup int, @NoOfJobs int, @NoOfAccounts int, @NoOfSavedSearch int, @NoOfTotalUsers int, @NoOfAssetNotes int,@NoOfMarkUps int,@NoOfTalentUsers int;
declare @NoOfLightBoxComments bigint, @NoOfLightbox bigint, @NoOfFolders bigint, @NoOfLightBoxinvitation int,@NoOfLightBoxinvitation1 int, @NoOfDerivatives bigint;
declare @NoOfAssets bigint, @NoOfRatings bigint, @NoOfMetadata bigint, @NoOfAssetHistory bigint,@NoOfMetadatamapped bigint,@NoOfMetadataunmapped bigint;
declare @NoOfApprovalGalleryAssetHistory bigint, @NoOfApprovalGalleryAssetNotes bigint, @NoOfWatermarkID bigint,@NoOfProjectAssignments bigint ;
--Temp table declaration and inserting values
declare @assetstable as table(assetid bigint);
declare @output_table as table (HighLevelSummary nvarchar(max), Globaledit_Legacy bigint, SortOrder int);
declare @dummyValue int =-9999;
insert into @assetstable select distinct a.AssetID from AccountGroup ag
inner join Account acc on acc.AccountGroupID = ag.AccountGroupID
inner join Job j on j.OwnerAccountID = acc.AccountID
inner join Asset a on a.JobID = j.JobiD
where 
acc.AccountID = @AccountID
and a.DeletetedOn is null 
and j.DeletedOn is null 
and (a.Archived=0 or a.Archived is NULL)

---region -----
Select @NoOfJobs = COUNT(distinct j.JobID),@NoOfAccounts=count(distinct a.accountid)  from Job j
inner join Account a on a.AccountID = j.OwnerAccountID
where 
a.AccountID=@AccountID
and j.DeletedOn is null

---end-region----
--Accounts_and_Jobs total records
--@NoOfAccountandJobs int
--Select @NoOfAccountandJobs = COUNT(distinct j.JobID) from Job j
--inner join Account a on a.AccountID = j.OwnerAccountID
--where a.AccountGroupID = @AccountGroupID and j.DeletedOn is null

--Users total records
--Select @NoOfTotalUsers = COUNT(distinct u.UserID) from [dbo].[User] u
--inner join Account a on a.AccountID = u.AccountID
--where a.AccountGroupID = @AccountGroupID  AND u.DeletedOn is NULL
select @NoOfTotalUsers=count(UserId) from 
(
        select u.UserId from [User] u
        join Account a on a.AccountID = u.AccountID
        where a.AccountID = @AccountID
        and a.DeletedOn is null
        union
        select u.UserId from [User] u
        join Dropbox d on d.RecipientID = u.UserId
        join Account a on a.AccountID = d.AccountID
        where a.AccountID = @AccountID
        and u.Guest = 1
        and u.AccountID is null
        union
        select u.UserId from [User] u
        join Invitation i on i.GuestID = u.UserId
        join Lightbox l on l.LightboxID = i.SharedObjectID
        join [User] o on o.UserID = l.OwnerID
        join Account a on a.AccountID = o.AccountID
        where a.AccountID = @AccountID
        and u.Guest = 1
        and u.AccountID is null
) a

-- Talent Users records
Select @NoOfTalentUsers = COUNT(distinct u.UserID) from [dbo].[User] u
inner join Account a on a.AccountID = u.AccountID
where a.AccountID = @AccountID  AND u.DeletedOn is NULL and u.IsTalent=1

--Saved_Searches total records ( excluding IsHidden condition)
select @NoOfSavedSearch = Count(distinct ss.SavedSearchID)  from Account acc
inner join [dbo].[User] u on u.AccountID = acc.AccountID
inner join SavedSearch ss on ss.OwnerID = u.UserID
inner join SavedSearchQueryItem ssi on ssi.SavedSearchID = ss.SavedSearchID
where acc.AccountID = @AccountID  and  u.DeletedOn is null 

--Folders total records
select @NoOfFolders = COUNT(distinct jf.JobFolderId) from Account acc
inner join Job j on j.OwnerAccountId = acc.AccountId
inner join JobFolder jf on jf.JobId = j.JobId
where acc.AccountID = @AccountID and j.DeletedOn is null and jf.DeletedOn is null


--Assets total records
select @NoOfAssets = COUNT(*) from @assetstable

--Derivatives_Attachments total records
select @NoOfDerivatives = COUNT(ad.AssetDerivativeID) from AssetDerivative ad 
where ad.DeletedOn is NULL and ad.AssetTypeCd NOT IN ('SM_THUMB','LG_THUMB','MED_RES','SCR_RES','PVIEW','PVIEW_VID','PVIEW_VID_MED','PVIEW_VID_HIGH','PVIEW_VID_THUMB','PVIEW_HR', 'PDF_SWF')
and ad.AssetID in (select a.AssetID from Asset a inner join @assetstable at on at.assetid=a.AssetID where a.DeletetedOn is NULL 
and a.JobID in (select j.JobID from Job j where j.DeletedOn is NULL and j.OwnerAccountID in 
(select a.AccountID from Account a where a.AccountID= @AccountID)))

--Metadata total records
--select @NoOfMetadata = COUNT(distinct am.AssetMetadataID) from AccountGroup ag
--inner join Account acc on acc.AccountGroupID = ag.AccountGroupID
--inner join Job j on j.OwnerAccountID = acc.AccountID
--inner join Asset a on a.JobID = j.JobiD
--inner join AssetMetadata am on am.AssetID = a.AssetID
--where ag.AccountGroupID = @AccountGroupID and a.DeletetedOn is null and j.DeletedOn is null 

--Markup total records
select @NoOfMarkUps = COUNT(distinct am.AssetMarkupId) from Account acc
inner join job j on j.OwnerAccountID = acc.AccountID
inner join Asset a on a.JobID = j.JobID
inner join @assetstable at on at.assetid=a.AssetID
inner join AssetMarkup am on am.AssetID = a.AssetID
left join AssetMarkupItem ami on ami.AssetMarkupID = am.AssetMarkupID
where acc.AccountID = @AccountID AND a.DeletetedOn is NULL AND j.DeletedOn is null

--Ratings total records
select @NoOfRatings = count(distinct aa.AssetID)
from Account a
inner join Job j on j.OwnerAccountID = a.AccountID
inner join Asset aa on aa.JobID = j.JobID
left join assetcolor ac on ac.assetcolorid = aa.color
where a.AccountID = @AccountID AND j.DeletedOn is null and aa.DeletetedOn is null
and (aa.SelectDate is not null or aa.ApprovedDate is not null or aa.AltDate is not null or aa.KilledDate is not null or aa.ratingdate is null or ac.Name is not null)

--Assets_Notes total records
select @NoOfAssetNotes = COUNT(distinct nh.NotesHistoryID) from AccountGroup ag
inner join Account acc on acc.AccountGroupID = ag.AccountGroupID
inner join Job j on j.OwnerAccountID = acc.AccountID
inner join Asset a on a.JobID = j.JobiD
inner join NoteHistory nh on nh.AssetID = a.AssetID
where acc.AccountID = @AccountID 
and a.DeletetedOn is null 
and j.DeletedOn is null 
and nh.ApprovalGalleryUserID is NULL --Excluding AG notes since quark not support for now.

--Lightbox total records (excluded u.DeletedOn is NULL)
select @NoOfLightbox= COUNT(distinct l.LightboxID) from AccountGroup ag
inner join Account acc on acc.AccountGroupID = ag.AccountGroupID
inner join [dbo].[User] u on u.AccountID = acc.AccountID
inner join Lightbox l on l.OwnerID = u.UserID
left join lightboxasset la on la.lightboxid = l.lightboxid
where acc.AccountID = @AccountID  and acc.DeletedOn is null and l.DeletedOn is null

--Lightbox_Groups total records
select @NoOfLightBoxGroup = COUNT(distinct lg.LightboxGroupId) from AccountGroup ag
inner join Account acc on acc.AccountGroupID = ag.AccountGroupID
inner join [dbo].[User] u on u.AccountID = acc.AccountID
inner join LightboxGroup lg on lg.userid = u.userid
left join lightbox l on l.lightboxid = lg.lightboxid
where acc.AccountID = @AccountID and acc.DeletedOn is null and u.DeletedOn is null and lg.Name is not null

--Lightbox_Comments total records (excluded u.DeletedOn is NULL)
select @NoOfLightBoxComments = COUNT(distinct ln.LightboxNoteID) from AccountGroup ag
inner join Account acc on acc.AccountGroupID = ag.AccountGroupID
inner join [dbo].[User] u on u.AccountID = acc.AccountID
inner join Lightbox l on l.OwnerID = u.UserID
inner join lightboxnote ln on ln.lightboxid = l.lightboxid
where acc.AccountID = @AccountID and acc.DeletedOn is null and l.DeletedOn is null

--Lightbox_Invitations-mapped total records -- Sent to GE users
select @NoOfLightBoxinvitation = COUNT (distinct i.InvitationID)  from AccountGroup ag
inner join Account acc on acc.AccountGroupID = ag.AccountGroupID
inner join [dbo].[User] u on u.AccountID = acc.AccountID
inner join Lightbox l on l.OwnerID = u.UserID
inner join Invitation i on i.SharedObjectID = l.LightboxID
inner join [dbo].[User] gu on i.GuestID=gu.UserID
where acc.AccountID = @AccountID and acc.DeletedOn is null AND l.DeletedOn is null
AND gu.Guest= 0 --Excluded shared Lightbox to Guest users
AND i.ExpiredOn is NULL --Excluded Expired Light box

----Lightbox_Invitations-unmapped total records -- Sent to Guest users
select @NoOfLightBoxinvitation1 = COUNT (distinct i.InvitationID)  from AccountGroup ag
inner join Account acc on acc.AccountGroupID = ag.AccountGroupID
inner join [dbo].[User] u on u.AccountID = acc.AccountID
inner join Lightbox l on l.OwnerID = u.UserID
inner join Invitation i on i.SharedObjectID = l.LightboxID
inner join [dbo].[User] gu on i.GuestID=gu.UserID
where acc.AccountID = @AccountID and acc.DeletedOn is null AND l.DeletedOn is null
AND gu.Guest= 1 --Excluded shared Lightbox to Guest users
AND i.ExpiredOn is NULL --Excluded Expired Light box

--Asset History total records
select @NoOfAssetHistory = COUNT(distinct ah.AssetHistoryID) from AssetHistory ah
inner join @assetstable a on a.assetid = ah.assetid
inner join Asset ass on ass.AssetID= a.assetid
inner join Job j on ass.JobID=j.JobID
inner join AssetHistoryItemType hit on hit.AssetHistoryItemTypeID = ah.AssetHistoryItemTypeID
where ah.AssetHistoryItemTypeID NOT IN ('9','10') --Quark not supports Approval Gallery and AssetRightsRestriction so excluding the two values

--Metadata total records (mapped id's)
select @NoOfMetadatamapped = COUNT (distinct am.AssetMetadataID) from AccountGroup ag
inner join Account acc on acc.AccountGroupID = ag.AccountGroupID
inner join Job j on j.OwnerAccountID = acc.AccountID
inner join Asset a on a.JobID = j.JobiD
inner join @assetstable at on at.assetid=a.AssetID
inner join AssetMetadata am on am.AssetID = a.AssetID
where acc.AccountID = @AccountID and a.DeletetedOn is null and j.DeletedOn is null
AND am.MetadataPropertyID  NOT IN (60,62,63,64,65,78,79,80,81,82,83,84,85,86,87,88,89,90,91,92,93,94,95,96,97,98,99,100,13043,13046,13047) --excluded MetadataPropertyID's

--Metadata total records (unmapped)
select @NoOfMetadataunmapped = COUNT (distinct am.AssetMetadataID) from AccountGroup ag
inner join Account acc on acc.AccountGroupID = ag.AccountGroupID
inner join Job j on j.OwnerAccountID = acc.AccountID
inner join Asset a on a.JobID = j.JobiD
inner join @assetstable at on at.assetid=a.AssetID
inner join AssetMetadata am on am.AssetID = a.AssetID
where acc.AccountID = @AccountID and a.DeletetedOn is null and j.DeletedOn is null
AND am.MetadataPropertyID  IN (60,62,63,64,65,78,79,80,81,82,83,84,85,86,87,88,89,90,91,92,93,94,95,96,97,98,99,100,13043,13046,13047)

select @NoOfApprovalGalleryAssetHistory = COUNT(distinct ah.AssetHistoryID) from AssetHistory ah
inner join Asset ass on ass.AssetID= ah.assetid
inner join Job j on ass.JobID=j.JobID
inner join Account a on j.OwnerAccountID=a.AccountID
inner join AccountGroup ag on a.AccountGroupID=ag.AccountGroupID
inner join AssetHistoryItemType hit on hit.AssetHistoryItemTypeID = ah.AssetHistoryItemTypeID
where a.AccountID = @AccountID and ah.ApprovalGalleryID is not null;

WITH CTE as (
select nh.NotesHistoryID, ag.ApprovalGalleryID, '""""'+nh.Text+'""""' as [Notes], nh.AssetID From NoteHistory nh 
inner join ApprovalGalleryUser agu on nh.ApprovalGalleryUserID=agu.ApprovalGalleryUserID
inner join ApprovalGallery ag on agu.ApprovalGalleryID=ag.ApprovalGalleryID
inner join ApprovalGalleryCollection agc on ag.ApprovalGalleryID=agc.ApprovalGalleryID 
inner join Account a on ag.AccountID=a.AccountID
inner join AccountGroup acg on a.AccountGroupID=acg.AccountGroupID
where a.AccountID = @AccountID and a.DeletedOn is null and a.DeletedBy is null and ag.DeleteDate is null and ag.DeletedBy is null
 and (ag.ExpirationDate <= GETDATE() or ag.DoneDate is not null) and (agc.JobFolderID is not null or agc.JobID is not null or agc.LightboxID is not null)
--and (
--(ag.DoneDate is not null and ag.ExpirationDate is not null) or (ag.DoneDate is not null and ag.ExpirationDate is null) or (ag.DoneDate is null and ag.ExpirationDate is not null)
--)
)

select @NoOfApprovalGalleryAssetNotes = count(distinct c.NotesHistoryID) From AccountGroup acg
inner join Account a on acg.AccountGroupID=a.AccountGroupID
inner join ApprovalGallery apg on a.AccountID=apg.AccountID
inner join ApprovalGalleryCollection agc on apg.ApprovalGalleryID=agc.ApprovalGalleryID 
left  join CTE c on apg.ApprovalGalleryID=c.ApprovalGalleryID
where a.AccountID = @AccountID and c.NotesHistoryID is not null 
and a.DeletedOn is null and a.DeletedBy is null and apg.DeleteDate is null and apg.DeletedBy is null
 and (apg.ExpirationDate <= GETDATE() or apg.DoneDate is not null) and (agc.JobFolderID is not null or agc.JobID is not null or agc.LightboxID is not null)
--and (
--(apg.DoneDate is not null and apg.ExpirationDate is not null) or (apg.DoneDate is not null and apg.ExpirationDate is null) or (apg.DoneDate is null and apg.ExpirationDate is not null)
--) 

select @NoOfWatermarkID = count(distinct arw.WatermarkID) from AccountGroup ag
inner join Account a on ag.AccountGroupID=a.AccountGroupID
inner join AssetRightsWatermark arw on a.AccountID=arw.AccountID
where a.AccountID = @AccountID and a.DeletedOn is null

select @NoOfProjectAssignments = count (distinct uj.UserJobID) 
From AccountGroup ag
inner join Account a on ag.AccountGroupID=a.AccountGroupID
inner join [User] u on a.AccountID=u.AccountID 
inner join UserJob uj on u.UserID=uj.UserID
inner join Job j on uj.JobID=j.JobID
left join JobFolder jf on uj.JobFolderID=jf.JobFolderID
where 
a.DeletedOn is null 
and u.DeletedOn is null
and a.AccountID = @AccountID
and j.DeletedOn is null
and jf.DeletedOn is null
 
--Selecting data



--select        

--                @NoOfAccountandJobs as 'Accounts_and_Jobs_total_records',
--                @NoOfAssetHistory as 'Asset_History_total_records',
--                @NoOfAssets as 'Assets_total_records',
--                @NoOfAssetNotes as 'Assets_Notes_total_records',
--                @NoOfDerivatives as 'Derivatives_Attachments_total_records',
--                @NoOfFolders as 'Folders_total_records',
--                @NoOfLightbox as 'Lightbox_total_records(Include_Deleted_Users)',
--                @NoOfLightBoxComments as 'Lightbox_Comments total records (deleted User Included)',
--                @NoOfLightBoxGroup as 'Lightbox_Groups total records',
--                @NoOfLightBoxinvitation as 'Lightbox_Invitations total records',
--                @NoOfLightBoxinvitation1 as 'LightBoxInvitation-GuestUsers',
--                @NoOfMarkUps as 'Markup total records',
--                @NoOfMetadata as 'Metadata total records',
--                @NoOfRatings as 'Ratings total records',
--                @NoOfSavedSearch as 'Saved_Searches total records',
--                @NoOfTotalUsers as 'Users total records'
                
                
declare @TestTable as table ([history assets id-mappings] bigint,[assets id-mappings] bigint,[comment assets id-mappings] bigint,
[attachments assets id-mappings] bigint,[folder id-mappings] bigint,[collection id-mappings] bigint,[collection-note id-mappings] bigint,
[collection-group id-mappings] bigint,[collection-invitation id-mappings] bigint,LightBoxInvitation_GuestUsers bigint,[markup assets id-mappings] bigint,[metadata assets id-mappings] bigint,
Metadata_total_records_unmapped bigint,Ratings_total_records bigint, [saved-searches id-mappings] bigint,[users id-mappings] bigint, Talent_Users_Total_records bigint,
Accounts_total_records bigint,[organization id-mappings] bigint, [approval-gallery-history id-mappings] bigint,[approval-gallery-asset-note id-mappings] bigint,
[organization info] bigint,[collections info] bigint, [assets upload-verification] bigint, [approval-gallery-user id-mappings] bigint,[collection-groups info] bigint, [approvalGallery history info] bigint, [saved-searches info] bigint,
[assets history info] bigint, [assets watermarked-incomplete-by-account] bigint, [user-scope-policies id-mappings] bigint, [assets watermarked-incomplete] bigint, [metadata stage info] bigint, [assets info] bigint,
[watermarks id-mappings] bigint, [project-assignments-id-mappings] bigint
)


insert into @TestTable select @NoOfAssetHistory,@NoOfAssets ,@NoOfAssetNotes ,@NoOfDerivatives,@NoOfFolders ,@NoOfLightbox ,@NoOfLightBoxComments,@NoOfLightBoxGroup ,
                                                        @NoOfLightBoxinvitation ,@NoOfLightBoxinvitation1 ,@NoOfMarkUps , @NoOfMetadatamapped,@NoOfMetadataunmapped,@NoOfRatings ,@NoOfSavedSearch ,@NoOfTotalUsers, 
                                                        @NoOfTalentUsers, @NoOfAccounts, @NoOfJobs,@NoOfApprovalGalleryAssetHistory,@NoOfApprovalGalleryAssetNotes, 
						@dummyValue,@dummyValue,@dummyValue,@dummyValue,@dummyValue,@dummyValue,@dummyValue,@dummyValue,@dummyValue,@dummyValue,@dummyValue,@dummyValue,@dummyValue,
						@NoOfWatermarkID, @NoOfProjectAssignments



--Unpivot transposing data                
insert into @output_table(HighLevelSummary,Globaledit_Legacy)
select HighLevelSummary, Globaledit_Legacy
from  @TestTable
UNPIVOT(
                  Globaledit_Legacy
                 FOR HighLevelSummary IN (Accounts_total_records,
                                 [organization id-mappings], 
                                 [history assets id-mappings],
                                 [comment assets id-mappings],
                                 [assets id-mappings],
                                 [attachments assets id-mappings],
                                 [folder id-mappings],
                                 [collection-note id-mappings],
                                 [collection-group id-mappings],
                                 [collection-invitation id-mappings],
                                 [collection id-mappings],
                                 [markup assets id-mappings],
                                 [metadata assets id-mappings],
                                 Ratings_total_records,
                                 [saved-searches id-mappings],
                                 [users id-mappings],                               
								 Talent_Users_Total_records,
                                 [approval-gallery-asset-note id-mappings],
                                 [approval-gallery-history id-mappings],

                                                                 [organization info],[collections info],[assets upload-verification],[approval-gallery-user id-mappings],[collection-groups info],
																 [approvalGallery history info],[saved-searches info],[assets history info],
                                                                 [assets watermarked-incomplete-by-account],[user-scope-policies id-mappings],[assets watermarked-incomplete],[metadata stage info],[assets info],
																 [watermarks id-mappings],
																 [project-assignments-id-mappings]
                                                                 )
                 ) AS UnPivotExample
UNION 
select HighLevelSummary,Globaledit_Legacy from (
select 
ISNULL(sum(case when ExpirationDate is not null or DoneDate is not null then 1 else 0 end),0) as [approval-gallery id-mappings],
ISNULL(sum(case when (ExpirationDate is not null or DoneDate is not null) and (ApprovalGalleryWatermarkTypeID <> 1)  then 1 else 0 end),0) [Completed and/or Expired approval galleries with watermarks],
ISNULL(sum(case when (ExpirationDate is not null or DoneDate is not null) and (ApprovalGalleryWatermarkTypeID = 1)  then 1 else 0 end),0) [Completed and/or Expired approval galleries without watermarks]
 from ( select agl.ApprovalGalleryID,ExpirationDate,ApprovalGalleryWatermarkTypeID, Donedate  From AccountGroup ag
 inner join Account a on ag.AccountGroupID=a.AccountGroupID
 inner join approvalgallery agl on a.AccountID=agl.AccountID 
 inner join ApprovalGalleryCollection agc on agl.ApprovalGalleryID=agc.ApprovalGalleryID 
 where a.AccountID = @AccountID and a.DeletedOn is null and a.DeletedBy is null and agl.DeleteDate is null and agl.DeletedBy is null
 and (ExpirationDate <= GETDATE() or DoneDate is not null) and (agc.JobFolderID is not null or agc.JobID is not null or agc.LightboxID is not null)
 )  a )as t
 UNPIVOT(
                  Globaledit_Legacy
                 FOR HighLevelSummary IN ([approval-gallery id-mappings],
                                 [Completed and/or Expired approval galleries with watermarks],[Completed and/or Expired approval galleries without watermarks])
                 ) AS RESULT;

update @output_table set SortOrder=1 where HighLevelSummary='approval-gallery id-mappings'
update @output_table set SortOrder=2 where HighLevelSummary='approval-gallery-asset-note id-mappings'
update @output_table set SortOrder=3 where HighLevelSummary='approval-gallery-history id-mappings'
update @output_table set SortOrder=4 where HighLevelSummary='approval-gallery-user id-mappings'
update @output_table set SortOrder=5 where HighLevelSummary='assets id-mappings'
update @output_table set SortOrder=6 where HighLevelSummary='assets watermarked-incomplete'
update @output_table set SortOrder=7 where HighLevelSummary='assets watermarked-incomplete-by-account'
update @output_table set SortOrder=8 where HighLevelSummary='attachments assets id-mappings'
update @output_table set SortOrder=9 where HighLevelSummary='collection id-mappings'
update @output_table set SortOrder=10 where HighLevelSummary='collection-group id-mappings'
update @output_table set SortOrder=11 where HighLevelSummary='collection-invitation id-mappings'
update @output_table set SortOrder=12 where HighLevelSummary='collection-note id-mappings'
update @output_table set SortOrder=13 where HighLevelSummary='comment assets id-mappings'
update @output_table set SortOrder=14 where HighLevelSummary='folder id-mappings'
update @output_table set SortOrder=15 where HighLevelSummary='history assets id-mappings'
update @output_table set SortOrder=16 where HighLevelSummary='markup assets id-mappings'
update @output_table set SortOrder=17 where HighLevelSummary='metadata assets id-mappings'
update @output_table set SortOrder=18 where HighLevelSummary='organization id-mappings'
update @output_table set SortOrder=19 where HighLevelSummary='saved-searches id-mappings'
update @output_table set SortOrder=20 where HighLevelSummary='user-scope-policies id-mappings'
update @output_table set SortOrder=21 where HighLevelSummary='users id-mappings'
update @output_table set SortOrder=22 where HighLevelSummary='watermarks id-mappings'
update @output_table set SortOrder=23 where HighLevelSummary='project-assignments-id-mappings'

update @output_table set SortOrder=NULL where HighLevelSummary='organization info'
update @output_table set SortOrder=NULL where HighLevelSummary='collections info'
update @output_table set SortOrder=NULL where HighLevelSummary='assets upload-verification'
update @output_table set SortOrder=NULL where HighLevelSummary='collection-groups info'
update @output_table set SortOrder=NULL where HighLevelSummary='approvalGallery history info'
update @output_table set SortOrder=NULL where HighLevelSummary='saved-searches info'
update @output_table set SortOrder=NULL where HighLevelSummary='assets history info'
update @output_table set SortOrder=NULL where HighLevelSummary='metadata stage info'
update @output_table set SortOrder=NULL where HighLevelSummary='assets info'
--update @output_table set SortOrder=NULL where HighLevelSummary=''
update @output_table set SortOrder=NULL where HighLevelSummary='Accounts_total_records'
update @output_table set SortOrder=NULL where HighLevelSummary='Completed and/or Expired approval galleries with watermarks'
update @output_table set SortOrder=NULL where HighLevelSummary='Completed and/or Expired approval galleries without watermarks'

update @output_table set SortOrder=NULL where HighLevelSummary='Ratings_total_records'
update @output_table set SortOrder=NULL where HighLevelSummary='Talent_Users_Total_records'



select HighLevelSummary, CASE Globaledit_Legacy WHEN -9999 THEN 0 ELSE Globaledit_Legacy END AS Globaledit_Legacy From @output_table where SortOrder is not null order by SortOrder" -s , -W -k1 > Output/"$name"_GEL_HighLevelSummary.csv

sed -e 's/-,//g;s/-//g;s///g;/^$/d' Output/"$name"_GEL_HighLevelSummary.csv > Final_CSV/"$name"_GEL_HighLevelSummary.csv