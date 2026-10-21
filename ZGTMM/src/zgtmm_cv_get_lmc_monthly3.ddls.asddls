@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '월별 LMC 금액 조회3'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_GET_LMC_MONTHLY3 
as
select from ZGTMM_CV_GET_ZNFT0002 as a
association [1..1] to zgtmmt1100 as b on  $projection.BUKRS = b.bukrs and $projection.CYEAR = b.mjahr and  b.nes = 'CU'
association [1..1] to zgtmmt1100 as C on  $projection.BUKRS = C.bukrs and $projection.CYEAR = C.mjahr and  C.nes = 'AL'
                             
{
  key a.BUKRS,
  key a.CYEAR,
  key a.CMON,
      cast('O' as abap.char(1)) as MCHECK,
      a.EXRATE_TTS,
      a.EXRATE_TTM,  

      @Semantics.amount.currencyCode: 'CU_WAERS'           
      a.CU_CASH,
      @Semantics.amount.currencyCode: 'CU_WAERS'        
      a.CU_3M,         
      a.CU_WAERS,

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
      a.CU_lmc,     
      a.CU_KWAERS,  

      @Semantics.amount.currencyCode: 'AL_WAERS'                
      a.AL_CASH,
      @Semantics.amount.currencyCode: 'AL_WAERS'          
      a.AL_3M as AL_3M,        
      a.AL_WAERS,

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
      a.al_lmc,  
      a.AL_KWAERS,        
      @Semantics.amount.currencyCode: 'PB_WAERS'          
      a.PB_CASH,
      @Semantics.amount.currencyCode: 'PB_WAERS'         
      a.PB_3M as PB_3M,              
      a.PB_WAERS,
      cast('' as abap.char(1)) as DUP    
    
} 

union all

select from ZGTMM_CV_GET_LMC_MONTHLY2 as A
association [1..1] to zgtmmt1100 as b on  $projection.BUKRS = b.bukrs and $projection.CYEAR = b.mjahr and  b.nes = 'CU'
association [1..1] to zgtmmt1100 as C on  $projection.BUKRS = C.bukrs and $projection.CYEAR = C.mjahr and  C.nes = 'AL'
association [1..1] to ZGTMM_CV_GET_ZNFT0002 as D on  $projection.BUKRS = D.BUKRS and $projection.CYEAR = D.CYEAR and  $projection.CMON = D.CMON
{
  key A.BUKRS,
  key A.CYEAR,
  key A.CMON,
      cast('' as abap.char(1)) as MCHECK,
      A.EXRATE_TTS,
      A.EXRATE_TTM,  
      
      A.CU_CASH,
       
      A.CU_3M,
      A.CU_WAERS,
      
    
      b.premium as CU_PREMIUM,
      b.waers as CU_PRWAERS,
      b.crate as CU_CRATE,
        
      b.mcost as CU_MCOST,
      b.per as CU_MPER,
      b.munit as CU_MUNIT,
      b.mwaers as CU_MWAERS,
      b.kurst as CU_KURST,  
               
     
      case when b.nes is not null then
              cast( cast(cast( DIV(  ( cast(CU_CASH as abap.dec(13,2)) + cast(b.premium as abap.dec(13,2)) ) * A.EXRATE_TTS , 1000 ) as abap.dec(13,2)) / 100 as abap.dec(13,2))   as abap.curr(13,2))   
            else
             cast(0 as abap.curr(13,2))
           end as CU_LMC,
      cast('KRW' as waers) as CU_KWAERS,     
      
 
      A.AL_CASH,

      A.AL_3M,      
      A.AL_WAERS,        
     
      C.premium as AL_PREMIUM,
      C.waers as AL_PRWAERS,
      C.crate as AL_CRATE,
        
      C.mcost as AL_MCOST,
      C.per as AL_MPER ,
      C.munit as AL_MUNIT,
      C.mwaers as AL_MWAERS,
      C.kurst as AL_KURST,            

      case when C.nes is not null then
            cast(cast(cast( DIV(  ( cast(AL_CASH as abap.dec(13,2)) + cast(C.premium as abap.dec(13,2)) ) * A.EXRATE_TTM , 1000 ) as abap.dec(13,2)) / 100 as abap.dec(13,2))  as abap.curr(13,2))   
            else
             cast(0 as abap.curr(13,2))
      end as AL_LMC,
      cast('KRW' as waers) as AL_KWAERS, 
      A.PB_CASH,   
      A.PB_3M,      
      A.PB_WAERS,
      case when D.BUKRS is not null then 
           cast('X' as abap.char(1))
           else cast('' as abap.char(1)) end as DUP
} 





