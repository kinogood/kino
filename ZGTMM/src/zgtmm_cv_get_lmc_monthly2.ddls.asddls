@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '월별 LMC 금액 조회'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_GET_LMC_MONTHLY2 
as select from ZGTMM_CV_GET_LME_INFO_MONTHLY2 as A
association [0..*] to ZGTMM_CV_GET_EXRATE_MONTHLY as E1 on E1.PERIOD = $projection.CMON and E1.TYPE = 'TTS' and E1.currency = 'USD'
association [0..*] to ZGTMM_CV_GET_EXRATE_MONTHLY as E2 on E2.PERIOD = $projection.CMON and E2.TYPE = 'TTM' and E2.currency = 'USD'

{ 
  key cast('6000' as bukrs) as BUKRS,
  key LEFT(A.INMON,4) as CYEAR,
  key A.INMON as CMON,

      @Semantics.amount.currencyCode: 'CU_WAERS'    
      cast(A.CU_CASH as abap.curr(13,2)) as CU_CASH,
      @Semantics.amount.currencyCode: 'CU_WAERS'         
      cast(A.CU_3M as abap.curr(13,2)) as CU_3M,      
      A.CU_WAERS,

      @Semantics.amount.currencyCode: 'AL_WAERS'    
      cast(A.AL_CASH as abap.curr(13,2)) as AL_CASH,
      @Semantics.amount.currencyCode: 'AL_WAERS'          
      cast(A.AL_3M as abap.curr(13,2)) as AL_3M,      
      A.AL_WAERS,
      @Semantics.amount.currencyCode: 'PB_WAERS'    
      cast(A.PB_CASH as abap.curr(13,2)) as PB_CASH,   
      @Semantics.amount.currencyCode: 'PB_WAERS'       
      cast(A.PB_3M as abap.curr(13,2)) as PB_3M,         
      A.PB_WAERS,
      case when E1.EXRATE is not null then E1.EXRATE else cast(0 as ztr_ttbuy_dec) end as EXRATE_TTS,
      case when E2.EXRATE is not null then E2.EXRATE else cast(0 as ztr_ttsell_dec) end as EXRATE_TTM
}
