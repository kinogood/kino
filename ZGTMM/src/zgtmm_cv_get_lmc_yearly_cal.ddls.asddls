@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '연별 LMC 금액 계산'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_GET_LMC_YEARLY_CAL 
as select from ZGTMM_CV_GET_LMC_YEARLY as A
association [1..1] to zgtmmt1100 as b on  $projection.BUKRS = b.bukrs and $projection.CYEAR = b.mjahr and  b.nes = 'CU'
association [1..1] to zgtmmt1100 as C on  $projection.BUKRS = C.bukrs and $projection.CYEAR = C.mjahr and  C.nes = 'AL'
association [1..1] to ZGTMM_CV_GET_EXRATE_RAW_YEAR as D on $projection.CYEAR = D.CYEAR and  D.currency = 'USD' and D.TYPE = 'TTS'
association [1..1] to ZGTMM_CV_GET_EXRATE_RAW_YEAR as E on $projection.CYEAR = E.CYEAR and  E.currency = 'USD' and E.TYPE = 'TTM' 

{
  key A.BUKRS,
  key A.CYEAR,
      D.EXRATE as EXRATE_TTS,
      E.EXRATE as EXRATE_TTM,  
      
      @Semantics.amount.currencyCode: 'CU_WAERS'    
      A.CU_CASH,
      @Semantics.amount.currencyCode: 'CU_WAERS'    
      A.CU_3M, 

      A.CU_WAERS,
      
      @Semantics.amount.currencyCode: 'CU_PRWAERS'        
      b.premium as CU_PREMIUM,
      b.waers as CU_PRWAERS,
      b.crate as CU_CRATE,
      @Semantics.amount.currencyCode: 'CU_MWAERS'          
      b.mcost as CU_MCOST,
      b.per as CU_MPER,
      b.munit as CU_MUNIT,
      b.mwaers as CU_MWAERS,
      b.kurst as CU_KURST,            
      @Semantics.amount.currencyCode: 'CU_KWAERS'     
       
      A.CU_LMC,      
      A.CU_KWAERS,
      @Semantics.amount.currencyCode: 'AL_WAERS'    
      A.AL_CASH,
      @Semantics.amount.currencyCode: 'AL_WAERS'    
      A.AL_3M,      
      A.AL_WAERS,        
      @Semantics.amount.currencyCode: 'AL_PRWAERS'        
      C.premium as AL_PREMIUM,
      C.waers as AL_PRWAERS,
      C.crate as AL_CRATE,
      @Semantics.amount.currencyCode: 'AL_MWAERS'          
      C.mcost as AL_MCOST,
      C.per as AL_MPER ,
      C.munit as AL_MUNIT,
      C.mwaers as AL_MWAERS,
      C.kurst as AL_KURST,        
      @Semantics.amount.currencyCode: 'AL_KWAERS'            
      A.AL_LMC,
      A.AL_KWAERS,
      @Semantics.amount.currencyCode: 'PB_WAERS'    
      A.PB_CASH,
      @Semantics.amount.currencyCode: 'PB_WAERS'    
      A.PB_3M,      
      A.PB_WAERS

}
