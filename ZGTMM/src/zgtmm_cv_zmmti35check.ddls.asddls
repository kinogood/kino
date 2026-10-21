@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '외주가공 꼬리표 상태 체크'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_ZMMTI35CHECK 
as 
select from zmmti35
{
  key vbeln,
  key posnr,
  key matnr,
  key tagnr,
  status
} 
group by vbeln, posnr, matnr, tagnr, status
