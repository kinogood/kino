@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'ID 별 사용자 이름 조회'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_GETUSERNAME 
as select from usr21 as A inner join zpa0539 as B on A.bname = B.pernr and B.endda >= $session.user_date
          left outer join zpa0105 as C on B.pernr = C.pernr and C.endda >= $session.user_date and C.subty = '0007'
          
{
    key A.bname as USERID,
    CONCAT(B.lnmhg,B.fnmhg) as NAME,
    case when C.usrid is not null then cast(C.usrid as sysid) 
         else cast('' as sysid) end as EMAIL
} 
