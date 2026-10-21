@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '기타 수불 정보 전송 최종 I/F Log-MM00011'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_EMVT_IF_LOG_S 
as 
select from ZGTMM_CV_EMVT_IF_LOG
{
   key  zifno,
   key  ifnum, 
   key  system_id,
   max(zifkey) as zifkey  
} where zifno = 'MM00011'
group by zifno,ifnum,system_id


