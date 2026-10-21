@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '환율 최신 일자 조회'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_GET_TCURR_MAXDATE 
as select from ZGTMM_CV_GET_TCURR
{
  key fcurr,
  key tcurr,
  max(CDATE) as CDATE
} where CDATE <= $session.user_date
group by fcurr,tcurr
