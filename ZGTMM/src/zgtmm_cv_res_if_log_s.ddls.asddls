@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '예약 정보 전송 최종 I/F Log-MM00006'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_RES_IF_LOG_S 
as 
select from ZGTMM_CV_RES_IF_LOG
{
   key  zifno,
   key  rsnum,
   key  rspos,
   key  werks,
   key  bwart,
   key  system_id,
   max(zifkey) as zifkey  
} where zifno = 'MM00006'
group by zifno,rsnum,rspos, werks, bwart, system_id
