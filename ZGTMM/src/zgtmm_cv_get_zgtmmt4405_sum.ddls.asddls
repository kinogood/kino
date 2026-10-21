@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '보관품 직송 거래명세서 합계'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_GET_ZGTMMT4405_SUM 
as select from zgtmmt4405
{
   key bukrs,
   key dlvrq,
   key vbeln,
   key posnr, 
  @Semantics.quantity.unitOfMeasure: 'DR_MEINS'   
   sum(loadqty) as LOADQTY,
   dr_meins
} where zdoc_no <> ''

group by bukrs, dlvrq, vbeln, posnr, dr_meins
