@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '적정재고 예상 소요량 집계_BASE2'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_RESB_BASE2 as 

select from ZGTMM_CV_RESB_BASE 
{ key rsnum,
  key bukrs,
  key werks,
  key matnr,
      @Semantics.quantity.unitOfMeasure: 'MEINS'
      REMAINQTY, 
      meins,
      bdter,  
      BDTERYEAR,
      PLANWEEK
  } 

union

select from ZGTMM_CV_RESB_BASE as A inner join scal_tt_date as B on B.calendardate >= $session.user_date and B.calendardate <= dats_add_days($session.user_date,112,'INITIAL')
{
  key A.rsnum,
  key A.bukrs,
  key A.werks,
  key A.matnr,
      cast(0 as bdmng) as REMAINQTY, 
      A.meins,
      B.calendardate as BDTER,  
      A.BDTERYEAR,
      A.PLANWEEK
  } 

/*


select from ZGTMM_CV_RESB_BASE
{
    key rsnum,
    key rspos,
        bdart,
        werks,
        matnr,

        @Semantics.quantity.unitOfMeasure: 'MEINS'
        REMAINQTY,
        meins,
        bdter,    
        calendaryear,
        calendarweek,
        YEARTODAY,
        WEEKTODAY,
        WEEKDIFF,
        DATEDIFF,
        WEEK,
        case when WEEK > WEEKDIFF
             then cast('X' as abap.char(1))
             else cast('' as abap.char(1)) end as CHECKWEEK
            
} where WEEKDIFF > 0
*/
