@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '일별 LMC 금액 조회'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_GET_LMC_DAILY 
as select from ZGTMM_CV_GET_LME_INFO_DAILY as B  inner join scal_tt_date as A  on A.calendardate = B.indat
association [1..1] to ztrtf13 as EX on  $projection.CDATE = EX.qdate and EX.ttbuy > 0 and EX.currency = 'USD'

{ 
  key cast('6000' as bukrs) as BUKRS,
  key A.calendaryear as CYEAR,
  key CONCAT(A.calendaryear,A.calendarmonth) as CMON,
  key A.calendardate as CDATE,

      @Semantics.amount.currencyCode: 'CU_WAERS'    
      cast(B.CU_CASH as abap.curr(13,2)) as CU_CASH,
      B.CU_WAERS,
      @Semantics.amount.currencyCode: 'CU_WAERS'           
      cast(B.CU_3M as abap.curr(13,2)) as CU_3M,
      @Semantics.amount.currencyCode: 'AL_WAERS'    
      cast(B.AL_CASH as abap.curr(13,2)) as AL_CASH,
      B.AL_WAERS,
      @Semantics.amount.currencyCode: 'AL_WAERS'    
      cast(B.AL_3M as abap.curr(13,2)) as AL_3M,          
      @Semantics.amount.currencyCode: 'PB_WAERS'    
      cast(B.PB_CASH as abap.curr(13,2)) as PB_CASH,   
      B.PB_WAERS,
      @Semantics.amount.currencyCode: 'PB_WAERS'        
      cast(B.PB_3M as abap.curr(13,2)) as PB_3M,                    
      case when EX.qdate is not null then EX.qdate else cast('' as ztr_qdate) end as QDATE,
      case when EX.currency is not null then EX.currency else cast('' as waers) end as EXCURRENCY,
      case when EX.sdate is not null then EX.sdate else cast('' as ztr_sdate) end as SDAT,
      case when EX.ttbuy is not null then EX.ttbuy else cast(0 as ztr_ttbuy_dec) end as EXRATE_TTS,
      case when EX.ttsell is not null then EX.ttsell else cast(0 as ztr_ttsell_dec) end as EXRATE_TTM
}
