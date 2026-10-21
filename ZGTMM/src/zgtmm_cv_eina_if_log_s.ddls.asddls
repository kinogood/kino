@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '자재-업체 매핑 정보 전송 최종 I/F Log-mm00013'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_EINA_IF_LOG_S 
as 
select from ZGTMM_CV_EINA_IF_LOG
{
   key  zifno,
   key  ekorg,
   key  werks,
   key  lifnr,       
   key  matnr,
   key  system_id,
   max(zifkey) as zifkey  
} where zifno = 'MM00013'
group by zifno,ekorg,werks,lifnr,matnr,system_id

