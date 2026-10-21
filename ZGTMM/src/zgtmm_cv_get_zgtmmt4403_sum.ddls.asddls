@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '직송 입고 처리 수량 합계'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_GET_ZGTMMT4403_SUM 
as select from zgtmmt4403
{
  key bukrs,
  key vbeln,
  key posnr,
  key ebeln,
  key ebelp,
  @Semantics.quantity.unitOfMeasure: 'DR_MEINS' 
  sum(loadqty) as LOADQTY,
  dr_meins  
} where mblnr <> ''
group by bukrs, vbeln,posnr,ebeln,ebelp,dr_meins
