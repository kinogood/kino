@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '적정재고 예상 소요량_WEEKLY 1차 계산'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_RESB_WEEKLY_CAL1 
as select from ZGTMM_CV_RESB_WEEKLY as A inner join ZGTMM_CV_RESB_AVG_WEEKLY as B 
 on A.werks = B.werks and A.matnr = B.matnr
{ 
   key  A.bukrs,
   key  A.werks,
   key  A.matnr,
        @Semantics.quantity.unitOfMeasure: 'MEINS'
        A.REQQTY,
        A.WEEKDIFF, 
        @Semantics.quantity.unitOfMeasure: 'MEINS'
        cast((A.REQQTY - B.AVGQTY) * (A.REQQTY - B.AVGQTY) as abap.quan(21,2)) as CALQTY, 
        A.meins,
        A.PLANWEEK
} 
