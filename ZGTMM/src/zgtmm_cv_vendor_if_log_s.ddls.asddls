@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '벤더 정보 전송 최종 I/F Log-MM00001'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_VENDOR_IF_LOG_S 
as 
select from ZGTMM_CV_VENDOR_IF_LOG
{
   key  zifno,
   key  lifnr,
   key  system_id,
   max(zifkey) as zifkey
} where zifno = 'MM00001'
group by zifno,lifnr,system_id
