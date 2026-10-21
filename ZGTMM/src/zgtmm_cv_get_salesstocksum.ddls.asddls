@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '매입 보관 MTO 재고 SUMMARY'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_GET_SALESSTOCKSUM 
as select from ZGTMM_CV_GET_SALESSTOCK
{
   key vbeln,
   key posnr,
   key matnr,
       @Semantics.quantity.unitOfMeasure: 'MEINS'
       sum(kalab) as KALAB,      
       meins    
} group by vbeln, posnr, matnr, meins 
