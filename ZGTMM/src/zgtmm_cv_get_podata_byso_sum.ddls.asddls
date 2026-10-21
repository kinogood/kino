@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'MTO 구매오더 정보 조회(MAX)'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_GET_PODATA_BYSO_SUM 
as select from ZGTMM_CV_GET_PODATA_BYSO
{
  key vbeln,
  key posnr,
  key werks,
      max(CHECKPO) as CHECKPO    
} group by vbeln,posnr, werks
