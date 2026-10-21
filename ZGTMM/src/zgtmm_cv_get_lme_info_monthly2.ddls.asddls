@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'LME 단기 평균 조회(월별)'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_GET_LME_INFO_MONTHLY2 
as select from ZGTMM_CV_GET_LME_INFO_MONTHLY
{
    key INMON,
       @Semantics.amount.currencyCode: 'CU_WAERS'    
       avg(cast(CU_CASH as abap.dec(13,2)) as abap.curr(13,2)) as CU_CASH,
       CU_WAERS,
       @Semantics.amount.currencyCode: 'CU_WAERS'           
       avg(cast(CU_3M as abap.dec(13,2)) as abap.curr(13,2)) as CU_3M,
       @Semantics.amount.currencyCode: 'AL_WAERS'    
       avg(cast(AL_CASH as abap.dec(13,2)) as abap.curr(13,2)) as AL_CASH,
       AL_WAERS,
       @Semantics.amount.currencyCode: 'AL_WAERS'    
       avg(cast(AL_3M as abap.dec(13,2)) as abap.curr(13,2)) as AL_3M,            
       @Semantics.amount.currencyCode: 'PB_WAERS'    
       avg(cast(PB_CASH as abap.dec(13,2)) as abap.curr(13,2)) as PB_CASH,
       PB_WAERS,
       @Semantics.amount.currencyCode: 'PB_WAERS'    
       avg(cast(PB_3M as abap.dec(13,2)) as abap.curr(13,2)) as PB_3M                   
} group by INMON, CU_WAERS,AL_WAERS,PB_WAERS
