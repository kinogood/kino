@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '통관 정보 전송 최종 I/F Log-MM00004'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_CU_IF_LOG_S 
as 
select from ZGTMM_CV_CU_IF_LOG
{
   key  zifno,
   key  iccno,
   key  iccsq, 
   key  bukrs, 
   key  system_id,     
   max(zifkey) as zifkey   
} where zifno = 'MM00004'
group by zifno,iccno,iccsq,bukrs,system_id
