@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '적정재고 예상 소요량_DAILY 1차 계산'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_RESB_DAILY_CAL1 
as 
select from ZGTMM_CV_RESB_ADD as A inner join ZGTMM_CV_RESB_AVG_DAILY as B 
       on A.werks = B.werks and A.matnr = B.matnr

{ 
   key  A.bukrs,
   key  A.werks,
   key  A.matnr,
        @Semantics.quantity.unitOfMeasure: 'MEINS'
        A.REQQTY,
     
        A.bdter, 
        A.DAYDIFF,
        @Semantics.quantity.unitOfMeasure: 'MEINS'
        cast((A.REQQTY - B.AVGQTY) * (A.REQQTY - B.AVGQTY) as abap.quan(13,2)) as CALQTY, 
        A.meins,
        A.PLANWEEK
   
} where A.CHECKPERIOD = 'I' and A.WEEKDIFF > 0
