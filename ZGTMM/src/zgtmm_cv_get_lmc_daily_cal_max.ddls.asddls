@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '일별 LMC DATA(최근일)'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_GET_LMC_DAILY_CAL_MAX 
as select from ZGTMM_CV_GET_LMC_DAILY_CAL as A inner join  ZGTMM_CV_GET_LMC_MAX_DATE as B on A.BUKRS = B.BUKRS and A.CDATE = B.CDATE
{
  key A.BUKRS,
  key A.CDATE,
      A.EXRATE_TTS as TTS,
      A.EXRATE_TTM as TTM,  
      
      @Semantics.amount.currencyCode: 'UWAERS_CU'    
      A.CU_CASH as LME_CU,
      A.CU_WAERS as UWAERS_CU,
      @Semantics.amount.currencyCode: 'KWAERS_CU'              
      A.CU_LMC as LMC_CU,
      A.CU_KWAERS as KWAERS_CU,        
      @Semantics.amount.currencyCode: 'UWAERS_AL'    
      A.AL_CASH as LME_AL,
      A.AL_WAERS as UWAERS_AL,     
      @Semantics.amount.currencyCode: 'KWAERS_AL'                 
      A.AL_LMC as LMC_AL,
      A.AL_KWAERS as KWAERS_AL,         
      @Semantics.amount.currencyCode: 'UWAERS_PB'    
      A.PB_CASH as LME_PB,
      A.PB_WAERS as UWAERS_PB
}
