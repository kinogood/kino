@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '자재마스터 비철 중량 정보 조회'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_GET_NFWEIGHT_MATERIAL 
as select from /nfm/tkgw as A inner join mara as B on A.matnr = B.matnr
                              inner join t001w as C on A.werks = C.werks
                              inner join t001k as D on C.bwkey = D.bwkey
{
  key D.bukrs,
  key A.werks,
  key A.matnr,
  key A.nes,
      @Semantics.quantity.unitOfMeasure: 'BME' 
      A.kgw,
      A.bme, 
      @Semantics.quantity.unitOfMeasure: 'MEINS'       
      A.kgu,
      B.meins
}
