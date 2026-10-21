@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '플랜트 별 NF WEIGHT 조회'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_GET_NFWEIGHT_PLANT 
as select from /nfm/tkgw as A inner join /nfm/tnes as B on A.nes = B.nes
                              inner join mara as C on A.matnr = C.matnr
{
  key A.nes,
  key A.matnr,
  key A.werks,    
      @Semantics.quantity.unitOfMeasure: 'BME' 
      A.kgw as Vgw,
      B.bme,
       
      cast(A.kgu as /nfm/vge) as vge,
      C.meins   
} where A.werks = '6500' or A.werks = '6600' 
