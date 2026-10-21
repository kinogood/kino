@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '매입 보관 MTO 재고 조회'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_GET_SALESSTOCK 
as
select from nsdm_e_mska as a inner join mara as B on a.matnr = B.matnr
{
   key a.vbeln,
   key a.posnr,
   key a.matnr,
   key a.werks,
   key a.lgort,
   key a.charg,
       @Semantics.quantity.unitOfMeasure: 'MEINS'
       a.kalab,      
       B.meins
} where  a.kalab >0  
