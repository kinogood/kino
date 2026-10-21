@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '연별 LMC 금액 조회'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_GET_LMC_YEARLY 
as select from ZGTMM_CV_GET_LMC_MONTHLY3 
{ 
  key BUKRS,
  key CYEAR,

      @Semantics.amount.currencyCode: 'CU_WAERS'    
      avg(cast(CU_CASH as abap.dec(13,2)) as abap.curr(13,2)) as CU_CASH,
      @Semantics.amount.currencyCode: 'CU_WAERS'          
      avg(cast(CU_3M as abap.dec(13,2)) as abap.curr(13,2)) as CU_3M,        
      
      CU_WAERS,
      @Semantics.amount.currencyCode: 'CU_KWAERS'
      avg(cast(CU_lmc as abap.dec(13,2)) as abap.curr(13,2)) as CU_LMC,     
      CU_KWAERS,
      @Semantics.amount.currencyCode: 'AL_WAERS'    
      avg(cast(AL_CASH as abap.dec(13,2)) as abap.curr(13,2)) as AL_CASH,
      @Semantics.amount.currencyCode: 'AL_WAERS'        
      avg(cast(AL_3M as abap.dec(13,2)) as abap.curr(13,2)) as AL_3M,     
      @Semantics.amount.currencyCode: 'AL_KWAERS'
      avg(cast(AL_lmc as abap.dec(13,2)) as abap.curr(13,2)) as AL_LMC,  
      AL_WAERS,
      AL_KWAERS,      
      @Semantics.amount.currencyCode: 'PB_WAERS'    
      avg(cast(PB_CASH as abap.dec(13,2)) as abap.curr(13,2)) as  PB_CASH,   
      @Semantics.amount.currencyCode: 'PB_WAERS'       
      avg(cast(PB_3M as abap.dec(13,2)) as abap.curr(13,2)) as  PB_3M,         
      PB_WAERS ,
      avg(EXRATE_TTS as ztr_ttsell_dec) as EXRATE_TTS,
      avg(EXRATE_TTM as ztr_ttsell_dec) as EXRATE_TTM
} where DUP = ''
group by BUKRS, CYEAR,CU_WAERS,AL_WAERS,PB_WAERS, CU_KWAERS, AL_KWAERS
