@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '자재문서 취소 정보 전송 최종 I/F Log-MM00014'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_MVC_IF_LOG_S
 as  
select from ZGTMM_CV_MVC_IF_LOG
{
   key  zifno,
   key  mblnr,
   key  mjahr,
   key  system_id,         
   max(zifkey) as zifkey
} where zifno = 'MM00014'
group by zifno,mblnr,mjahr,system_id
