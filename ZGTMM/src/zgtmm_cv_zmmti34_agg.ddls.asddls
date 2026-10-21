@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '외주가공 납품서 품목 별 상태 집계'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_ZMMTI34_AGG 
as select from ZGTMM_CV_ZMMTI35_SUM 
{
  key vbeln,
  key posnr,
  status      
} group by vbeln, posnr,status
