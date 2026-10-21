@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '적정재고 예상 소요량_DAILY 2차 계산'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_RESB_DAILY_CAL2 
as 
select from ZGTMM_CV_RESB_DAILY_CAL1 
{

   key  bukrs,
   key  werks,
   key  matnr,
        @Semantics.quantity.unitOfMeasure: 'MEINS'
        sum(REQQTY) as REQQTY,      
        @Semantics.quantity.unitOfMeasure: 'MEINS'
        avg(cast(CALQTY as abap.dec(13,2)) as abap.quan(13,2)) as AVGQTY ,        
        meins,
        PLANWEEK   
} group by bukrs, werks, matnr, meins, PLANWEEK
