@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '적정재고 예상 소요량_WEEKLY'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_RESB_WEEKLY
as select from ZGTMM_CV_RESB_ADD
{
   key  bukrs,
   key  werks,
   key  matnr,
        @Semantics.quantity.unitOfMeasure: 'MEINS'
        sum(REQQTY) as REQQTY, 
        meins,
        WEEKDIFF,
        PLANWEEK
} where CHECKPERIOD = 'I' and WEEKDIFF >= 0
group by bukrs, werks, matnr, meins,WEEKDIFF, PLANWEEK
