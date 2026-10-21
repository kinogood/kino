@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '적정재고 예상 소요량 합계'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_RESB_SUM 
as 
select from ZGTMM_CV_RESB_BASE2
{ 
   key bukrs,
   key werks,
   key matnr,
      @Semantics.quantity.unitOfMeasure: 'MEINS'
      sum(REMAINQTY) as REQQTY, 
      @Semantics.quantity.unitOfMeasure: 'MEINS'      
      sum(REMAINQTY) as REMAINQTY,
      meins,
      bdter,  
      BDTERYEAR,
      PLANWEEK   
} group by bukrs,werks, matnr, meins, bdter, BDTERYEAR, PLANWEEK
