@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '최종 배치 조회(꼬리표 테이블)'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_TAG_AGG 
as select from zppt0001
{
   key werks,
   key matnr,
   max(tagnr) as TAGNR,
   charg,
   max(CONCAT(grindat,grintim)) as TIMECHECK 
} group by werks, matnr, charg
