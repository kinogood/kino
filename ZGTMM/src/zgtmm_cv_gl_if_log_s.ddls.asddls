@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'G/L계정 리스트 정보 전송-최종 MM00021'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_GL_IF_LOG_S 
as 
select from ZGTMM_CV_GL_IF_LOG
{
   key  zifno,
   key  bukrs,
   key  saknr,
   key  system_id,      
   max(zifkey) as zifkey,
   txt50,
   xloeb 
   
} where zifno = 'MM00021'
group by zifno,bukrs,saknr,txt50,xloeb,system_id
