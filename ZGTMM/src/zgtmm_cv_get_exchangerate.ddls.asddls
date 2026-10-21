@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '기준 일자 별 최신 환율 조회'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_GET_EXCHANGERATE 
as 
 select from ZGTMM_CV_GET_TCURR as A 
        inner join ZGTMM_CV_GET_TCURR_MAXDATE as B on A.fcurr = B.fcurr and A.tcurr = B.tcurr and A.CDATE = B.CDATE
{
  key A.fcurr,
  key A.tcurr,
  A.CDATE,
  A.ukurs  
} 

