@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'PO 정보 전송 최종 I/F Log-MM00002'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_PO_IF_LOG_S 
as 
select from ZGTMM_CV_PO_IF_LOG
{
   key  zifno,
   key  ebeln,
   key system_id,  
   max(zifkey) as ZIFKEY
} where zifno = 'MM00002'
group by zifno,ebeln,system_id
