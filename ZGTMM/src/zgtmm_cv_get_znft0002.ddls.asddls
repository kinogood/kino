@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '월간 LMC 확정 정보 조회'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_GET_ZNFT0002 
as select from znft0002 as A inner join znft0002 as B on A.inmon = B.inmon
                             inner join znft0002 as C on B.inmon = C.inmon
                             inner join znft0002 as d on C.inmon = d.inmon
                             inner join znft0002 as e on d.inmon = e.inmon
association [0..*] to ZGTMM_CV_GET_EXRATE_MONTHLY as E1 on E1.PERIOD = $projection.CMON and E1.TYPE = 'TTS' and E1.currency = 'USD'
association [0..*] to ZGTMM_CV_GET_EXRATE_MONTHLY as E2 on E2.PERIOD = $projection.CMON and E2.TYPE = 'TTM' and E2.currency = 'USD'
association [0..*] to ZGTMM_CV_GET_LME_INFO_MONTHLY2  as E3 on E3.INMON = $projection.CMON 
                             
{
  key cast('6000' as bukrs) as BUKRS,
  key LEFT(A.inmon,4) as CYEAR,
  key A.inmon as CMON,
 
      @Semantics.amount.currencyCode: 'CU_WAERS'    
      cast(A.o_cash as abap.curr(13,2)) as CU_CASH,
      @Semantics.amount.currencyCode: 'CU_WAERS'          
      E3.CU_3M as CU_3M,         
      @Semantics.amount.currencyCode: 'CU_KWAERS'    
      cast(cast(cast(d.o_cash as abap.dec(13,2)) / 1000 as abap.dec(13,2)) as abap.curr(13,2)) as CU_lmc,     
      A.o_cash_waers as CU_WAERS,
      d.o_cash_waers as CU_KWAERS,
            
      @Semantics.amount.currencyCode: 'AL_WAERS'    
      cast(B.o_cash as abap.curr(13,2)) as AL_CASH,
      @Semantics.amount.currencyCode: 'AL_WAERS'        
      E3.AL_3M as AL_3M,        
      @Semantics.amount.currencyCode: 'AL_KWAERS'    
      cast(cast(cast(e.o_cash as abap.dec(13,2)) / 1000 as abap.dec(13,2)) as abap.curr(13,2)) as al_lmc,        
      B.o_cash_waers as AL_WAERS,
      e.o_cash_waers as AL_KWAERS,

      
      @Semantics.amount.currencyCode: 'PB_WAERS'    
      cast(C.o_cash as abap.curr(13,2)) as PB_CASH,
      @Semantics.amount.currencyCode: 'PB_WAERS'        
      E3.PB_3M as PB_3M,              
      C.o_cash_waers as PB_WAERS,
      
      case when E1.EXRATE is not null then E1.EXRATE else cast(0 as ztr_ttbuy_dec) end as EXRATE_TTS,
      case when E2.EXRATE is not null then E2.EXRATE else cast(0 as ztr_ttsell_dec) end as EXRATE_TTM    
    
} where A.nfkey = 'CU1' and B.nfkey = 'AL1' and C.nfkey = 'PB1' and d.nfkey = 'CU3' and e.nfkey = 'AL2'
