@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '코스트센터 전송 LOG-최종전송 MM00020'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_CC_IF_LOG_S 
as 
select from ZGTMM_CV_CC_IF_LOG
{
   key  zifno,
   key  bukrs,
   key  kostl,
   key  datbi,
   key  system_id,      
   max(zifkey) as zifkey 
   
} where zifno = 'MM00020'
group by zifno,bukrs,kostl,datbi,system_id
