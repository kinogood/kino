@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'PR 입고 예정 정보(일자별 집계)'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_RESERVED_PR_DAILY 
as select from ZGTMM_CV_RESERVED_PR
{
  key werks,
  key matnr,
  key REQDATE,
      DAYDIFF,
  
      @Semantics.quantity.unitOfMeasure: 'MEINS'
      sum(REQTY) as REQTY,
      meins     
} where CHECKPERIOD ='I' and DAYDIFF > 0
group by werks, matnr, REQDATE , DAYDIFF, meins  

