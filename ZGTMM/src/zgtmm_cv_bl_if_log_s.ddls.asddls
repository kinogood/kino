@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'BL 정보 전송 최종 I/F Log-MM00003'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_BL_IF_LOG_S 
as 
select from ZGTMM_CV_BL_IF_LOG
{
   key  zifno,
   key  iblno,
   key  bukrs,
   key  blnum,
   key  system_id,      
   max(zifkey) as zifkey 
   
} where zifno = 'MM00003'
group by zifno,iblno,bukrs,blnum,system_id


 