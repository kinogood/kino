@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '확정된 PR 입고 예정 정보'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_RESERVED_PR 
as 
select from eban as A 
  inner join scal_tt_date as B on A.lfdat = B.calendardate
  left outer join ZGTMM_CV_POQTY_PR as C on A.banfn = C.banfn and A.bnfpo = C.bnfpo
        left outer join zgtmmt4203 as D on A.werks = D.werks and A.matnr = D.matnr  
  association [1..1] to scal_tt_date as SYST on  SYST.calendardate = $session.user_date
{
   key A.werks,
   key A.matnr,
   key A.banfn,
   key A.bnfpo,
       A.lfdat as REQDATE,   
       B.calendaryear,
       B.calendarweek,
       SYST.calendaryear as YEARTODAY,
       SYST.calendarweek as WEEKTODAY,  
       DATS_DAYS_BETWEEN($session.user_date,A.lfdat) as DAYDIFF,   
       case when SYST.calendaryear < B.calendaryear
           then 
           ((cast(B.calendaryear as abap.dec(4)) - cast(SYST.calendaryear as abap.dec(4))) * 52 )
             + cast(B.calendarweek as abap.dec(2)) - cast(SYST.calendarweek as abap.dec(2))
           else cast(B.calendarweek as abap.dec(2)) - cast(SYST.calendarweek as abap.dec(2))
           end as WEEKDIFF,  
       case when D.week is not null then cast(D.week as abap.dec(2))
             else cast('15' as abap.dec(2)) end as PLANWEEK,  
     
       @Semantics.quantity.unitOfMeasure: 'MEINS'
       case when C.matnr is not null 
            then A.menge - C.MENGE 
            else A.menge
            end as REQTY,
       A.meins,
       case when D.week is not null then
            case when SYST.calendaryear < B.calendaryear
                 then 
                   case when 
                    cast(B.calendaryear as abap.dec(4)) * 52 - cast(SYST.calendaryear as abap.dec(4)) * 52  + cast(B.calendarweek as abap.dec(2)) - cast(SYST.calendarweek as abap.dec(2))  > cast(D.week as abap.dec(2))
                   then cast('E' as abap.char(1)) 
                   else cast('I' as abap.char(1)) end
                 
                 else 
                   case when cast(B.calendarweek as abap.dec(2)) - cast(SYST.calendarweek as abap.dec(2)) >cast(D.week as abap.dec(2))
                   then cast('E' as abap.char(1)) 
                        else cast('I' as abap.char(1)) end
                 
                 end  
      
         else
            case when SYST.calendaryear < B.calendaryear
                 then 
                   case when 
                    cast(B.calendaryear as abap.dec(4)) * 52 - cast(SYST.calendaryear as abap.dec(4)) * 52  + cast(B.calendarweek as abap.dec(2)) - cast(SYST.calendarweek as abap.dec(2))  > cast(15 as abap.dec(2))
                   then cast('E' as abap.char(1)) 
                   else cast('I' as abap.char(1)) end
                 
                 else 
                   case when cast(B.calendarweek as abap.dec(2)) - cast(SYST.calendarweek as abap.dec(2)) > cast(15 as abap.dec(2))
                   then cast('E' as abap.char(1)) 
                        else cast('I' as abap.char(1)) end
                 
                 end         
           
           end as CHECKPERIOD        
} where A.ebakz = '' and A.loekz = '' and (A.banpr = '02' or A.banpr = '05') and A.matnr <> '' and A.lfdat >= $session.user_date
