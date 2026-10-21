@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '판매오더 재고 SUMMARY'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_GET_MTO_STOCK 
as select from nsdm_e_mska as A inner join mara as B on A.matnr = B.matnr
{
   key A.matnr,
   key A.werks,
   key A.lgort,
   key A.vbeln,
   key A.posnr,
   @Semantics.quantity.unitOfMeasure: 'meins'
   sum(A.kalab) as KALAB,
   B.meins
} group by A.matnr, A.werks, A.lgort, A.vbeln, A.posnr, B.meins
