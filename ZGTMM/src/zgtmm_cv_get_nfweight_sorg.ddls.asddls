@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '영업조직 별 NF WEIGHT 조회'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_GET_NFWEIGHT_SORG 
as select from /nfm/tvgw as A inner join /nfm/tnes as B on A.nes = B.nes
                              inner join mara as C on A.matnr = C.matnr
{
  key A.nes,
  key A.matnr,
  key A.org,    
  key A.vtweg,
      @Semantics.quantity.unitOfMeasure: 'BME' 
      A.vgw,
      B.bme,
      A.vge,
      C.meins   
} where A.kappl = 'V' and A.parnr = ''
