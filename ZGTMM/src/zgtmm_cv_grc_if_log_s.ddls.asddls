@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '입고 취소 정보 전송 최종 I/F Log-MM00010'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_GRC_IF_LOG_S 
as 
select from ZGTMM_CV_GRC_IF_LOG
{
   key  zifno,
   key  mblnr_i,
   key  mjahr_i,
   key  system_id,         
   max(zifkey) as zifkey
} where zifno = 'MM00010'
group by zifno,mblnr_i,mjahr_i,system_id
