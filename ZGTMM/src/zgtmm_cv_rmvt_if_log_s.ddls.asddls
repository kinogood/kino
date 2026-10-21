@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '예약 수불 정보 전송 최종 I/F Log-MM00012'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_RMVT_IF_LOG_S
as 
select from ZGTMM_CV_RMVT_IF_LOG
{
   key  zifno,
   key  rsnum,
   key  rspos,
   key  charg,
   key  system_id,
   max(zifkey) as zifkey   
} where zifno = 'MM00012'
group by zifno,rsnum, rspos,charg,system_id

