@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '일별 LMC 금액 계산'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_GET_LMC_DAILY_CAL 
as select from ZGTMM_CV_GET_LMC_DAILY as A
association [1..1] to zgtmmt1100 as b on  $projection.BUKRS = b.bukrs and $projection.CYEAR = b.mjahr and  b.nes = 'CU'
association [1..1] to zgtmmt1100 as C on  $projection.BUKRS = C.bukrs and $projection.CYEAR = C.mjahr and  C.nes = 'AL'
{
  key A.BUKRS,
  key A.CYEAR,
  key A.CMON,
  key A.CDATE,
      A.EXRATE_TTS,
      A.EXRATE_TTM,  
      
      @Semantics.amount.currencyCode: 'CU_WAERS'    
      A.CU_CASH,
      A.CU_WAERS,
      @Semantics.amount.currencyCode: 'CU_WAERS'           
      A.CU_3M,
      
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
      case when b.nes is not null then
             cast( cast(cast( DIV(  ( cast(CU_CASH as abap.dec(13,2)) + cast(b.premium as abap.dec(13,2)) ) * A.EXRATE_TTS , 1000 ) as abap.dec(13,2)) / 100 as abap.dec(13,2))   as abap.curr(13,2))   
             else
             cast(0 as abap.curr(13,2))
           end as CU_LMC,
      cast('KRW' as waers) as CU_KWAERS,        
      @Semantics.amount.currencyCode: 'AL_WAERS'    
      A.AL_CASH,
      A.AL_WAERS,
      @Semantics.amount.currencyCode: 'AL_WAERS'    
      A.AL_3M,                  
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
      case when C.nes is not null then
             cast(cast(cast( DIV(  ( cast(AL_CASH as abap.dec(13,2)) + cast(C.premium as abap.dec(13,2)) ) * A.EXRATE_TTS * C.crate , 1000 ) as abap.dec(13,2)) / 100 as abap.dec(13,2))  as abap.curr(13,2))   
           else
             cast(0 as abap.curr(13,2))
      end as AL_LMC,
      cast('KRW' as waers) as AL_KWAERS,         
      @Semantics.amount.currencyCode: 'PB_WAERS'    
      A.PB_CASH,
      A.PB_WAERS,
      @Semantics.amount.currencyCode: 'PB_WAERS'           
      A.PB_3M      

}
