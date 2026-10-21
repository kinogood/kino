@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '수입입고 정보 전송 최종 I/F Log-MM00007'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_IMGR_IF_LOG_S 
as
select from ZGTMM_CV_IMGR_IF_LOG
{
   key  zifno,
   key  iccno,
   key  iccsq,
   key  system_id,    
   max(zifkey) as zifkey   
} where zifno = 'MM00007'
group by zifno,iccno,iccsq, system_id
