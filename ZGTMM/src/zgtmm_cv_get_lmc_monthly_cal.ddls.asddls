@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '월별 LMC 금액 계산'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_GET_LMC_MONTHLY_CAL 
as select from ZGTMM_CV_GET_LMC_MONTHLY3 as A
{
  key A.BUKRS,
  key A.CYEAR,
  key cast(A.CMON as abap.char(6)) as CMON,
      A.MCHECK,
      A.EXRATE_TTS,
      A.EXRATE_TTM,  
      
      @Semantics.amount.currencyCode: 'CU_WAERS'    
      A.CU_CASH,
      @Semantics.amount.currencyCode: 'CU_WAERS'         
      A.CU_3M,
      A.CU_WAERS,
      
      @Semantics.amount.currencyCode: 'CU_PRWAERS'        
      A.CU_PREMIUM,
      A.CU_PRWAERS,
      A.CU_CRATE,
      @Semantics.amount.currencyCode: 'CU_MWAERS'          
      A.CU_MCOST,
      A.CU_MPER,
      A.CU_MUNIT,
      A.CU_MWAERS,
      A.CU_KURST,       
      @Semantics.amount.currencyCode: 'CU_KWAERS'         
      A.CU_lmc,   
      A.CU_KWAERS,       
      @Semantics.amount.currencyCode: 'AL_WAERS'    
      A.AL_CASH,
      @Semantics.amount.currencyCode: 'AL_WAERS'    
      A.AL_3M,      
      A.AL_WAERS,        
      @Semantics.amount.currencyCode: 'AL_PRWAERS'        
      A.AL_PREMIUM,
      A.AL_PRWAERS,
      A.AL_CRATE,
      @Semantics.amount.currencyCode: 'AL_MWAERS'          
      A.AL_MCOST,
      A.AL_MPER ,
      A.AL_MUNIT,
      A.AL_MWAERS,
      A.AL_KURST,      
      @Semantics.amount.currencyCode: 'AL_KWAERS'          
      A.AL_lmc,
      A.AL_KWAERS,        
      @Semantics.amount.currencyCode: 'PB_WAERS'    
      A.PB_CASH,
      @Semantics.amount.currencyCode: 'PB_WAERS'    
      A.PB_3M,      
      A.PB_WAERS

} where A.DUP = ''

