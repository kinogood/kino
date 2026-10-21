@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '적정재고 예상 소요량 기초 데이터 생성'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_RESB_ADD 
as 
select from ZGTMM_CV_RESB_SUM as A inner join scal_tt_date as B on A.bdter = B.calendardate
association [1..1] to scal_tt_date as SYST on  SYST.calendardate = $session.user_date

{
   key  A.bukrs,
   key  A.werks,
   key  A.matnr,
        @Semantics.quantity.unitOfMeasure: 'MEINS'
        A.REQQTY, 

        A.meins,
        A.bdter,  
        A.BDTERYEAR,
        A.PLANWEEK,

        B.calendaryear,
        B.calendarweek,
        SYST.calendaryear as YEARTODAY,
        SYST.calendarweek as WEEKTODAY,  
        case when SYST.calendaryear < B.calendaryear
             then 
             ((cast(B.calendaryear as abap.dec(4)) - cast(SYST.calendaryear as abap.dec(4))) * 52 )
               + cast(B.calendarweek as abap.dec(2)) - cast(SYST.calendarweek as abap.dec(2))
             else cast(B.calendarweek as abap.dec(2)) - cast(SYST.calendarweek as abap.dec(2))
             end as WEEKDIFF,
        DATS_DAYS_BETWEEN($session.user_date,A.bdter) as DAYDIFF, 
        case when SYST.calendaryear < B.calendaryear
             then 
               case when 
                cast(B.calendaryear as abap.dec(4)) * 52 - cast(SYST.calendaryear as abap.dec(4)) * 52  + cast(B.calendarweek as abap.dec(2)) - cast(SYST.calendarweek as abap.dec(2))  > A.PLANWEEK
               then cast('E' as abap.char(1)) 
               else cast('I' as abap.char(1)) end
             
             else 
               case when cast(B.calendarweek as abap.dec(2)) - cast(SYST.calendarweek as abap.dec(2)) > A.PLANWEEK
               then cast('E' as abap.char(1)) 
                    else cast('I' as abap.char(1)) end
             
             end as CHECKPERIOD       

}

