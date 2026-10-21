@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'LMC 산출 최종 데이터 조회'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_GET_LMC_MAX_DATE 
as select from ZGTMM_CV_GET_LMC_DAILY_CAL
{
  key BUKRS,
  max(CDATE) as CDATE  
} group by BUKRS
