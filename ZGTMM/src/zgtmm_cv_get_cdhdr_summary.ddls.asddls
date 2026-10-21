@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '구매오더 변경 내역 조회(SUMMARY)'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_GET_CDHDR_SUMMARY 
as select from ZGTMM_CV_GET_CDHDR_EINKBELEG
{
   key objectclas,
   key objectid,
   key max(changenr) as CHANGENR,
       username,
       udate,
       utime,
       tcode     
} group by objectclas,objectid,username,udate,utime,tcode
