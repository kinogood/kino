@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Daily 소요량 계산(예상 소요량 기준)'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_RESB_DAILY_REQ 
as select from ZGTMM_CV_RESB_ADD
{
   key  werks,
   key  matnr,
        PLANWEEK,
        @Semantics.quantity.unitOfMeasure: 'MEINS'
        cast(sum(REQQTY) / (PLANWEEK * 7 ) as abap.quan(13,3)) as DREQ,
        meins
 } where CHECKPERIOD = 'I' and WEEKDIFF > 0 
 group by werks, matnr, meins, PLANWEEK
  
