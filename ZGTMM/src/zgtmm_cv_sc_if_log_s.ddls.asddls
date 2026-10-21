@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '사급자재 불출 정보 전송 최종 LOG-MM00018'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_SC_IF_LOG_S 
as 
select from ZGTMM_CV_SC_IF_LOG
{
   key  zifno,
   key  mjahr,
   key  mblnr,
   key  system_id,      
   max(zifkey) as zifkey 
   
} where zifno = 'MM00018'
group by zifno,mjahr,mblnr,system_id
