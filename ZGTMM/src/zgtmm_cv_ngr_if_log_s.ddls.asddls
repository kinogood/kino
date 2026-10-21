@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '내자입고 정보 전송 최종 I/F Log-MM00009'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_NGR_IF_LOG_S 
as 
select from ZGTMM_CV_NGR_IF_LOG
{
   key  zifno,
   key  vbeln,
   key  lifnr,
   key  system_id,   
   
   max(zifkey) as zifkey   
} where zifno = 'MM00009'
group by zifno,vbeln,lifnr,system_id
