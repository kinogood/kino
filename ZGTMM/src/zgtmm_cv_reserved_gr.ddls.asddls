@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '입고 예정 정보'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}

// 일자 별 구매 잔량
define view entity ZGTMM_CV_RESERVED_GR 
as 
select from ZGTMM_CV_GETEKPODATA as A inner join scal_tt_date as B on A.eindt = B.calendardate
        left outer join zgtmmt4203 as C on A.werks = C.werks and A.matnr = C.matnr
        left outer join ZGTMM_CV_GET_BLQTYSUM as e on A.ebeln = e.ebeln and A.ebelp = e.ebelp
association [1..1] to scal_tt_date as SYST on  SYST.calendardate = $session.user_date
{
  key A.werks,
  key A.matnr,
  key A.ebeln,
  key A.ebelp,
  key A.eindt as REQDATE,
  
      B.calendaryear,
      B.calendarweek,
      SYST.calendaryear as YEARTODAY,
      SYST.calendarweek as WEEKTODAY,  
      DATS_DAYS_BETWEEN($session.user_date,A.eindt) as DAYDIFF,    
      case when SYST.calendaryear < B.calendaryear
           then 
           ((cast(B.calendaryear as abap.dec(4)) - cast(SYST.calendaryear as abap.dec(4))) * 52 )
             + cast(B.calendarweek as abap.dec(2)) - cast(SYST.calendarweek as abap.dec(2))
           else cast(B.calendarweek as abap.dec(2)) - cast(SYST.calendarweek as abap.dec(2))
           end as WEEKDIFF,  
      case when C.week is not null then cast(C.week as abap.dec(2))
             else cast('15' as abap.dec(2)) end as PLANWEEK,  
      
      @Semantics.quantity.unitOfMeasure: 'MEINS'
      case when e.BLMNG is not null then 
          case when  A.MENGE - A.GRQTY  < e.BLMNG then cast(0 as abap.quan(13,3))
               else  A.MENGE - A.GRQTY - e.BLMNG end
           else A.MENGE - A.GRQTY end as REQTY,
      A.meins,
      case when C.week is not null then
            case when SYST.calendaryear < B.calendaryear
                 then 
                   case when 
                    cast(B.calendaryear as abap.dec(4)) * 52 - cast(SYST.calendaryear as abap.dec(4)) * 52  + cast(B.calendarweek as abap.dec(2)) - cast(SYST.calendarweek as abap.dec(2))  > cast(C.week as abap.dec(2))
                   then cast('E' as abap.char(1)) 
                   else cast('I' as abap.char(1)) end
                 
                 else 
                   case when cast(B.calendarweek as abap.dec(2)) - cast(SYST.calendarweek as abap.dec(2)) >cast(C.week as abap.dec(2))
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
    
} where A.elikz = '' and A.eindt >= $session.system_date 

union all

select from ZGTMM_CV_GET_BLQTY as A
{
  key A.werks,
  key A.matnr,
  key A.ebeln,
  key A.ebelp,
  key A.bleta as REQDATE,
  
      A.calendaryear,
      A.calendarweek,
      A.YEARTODAY,
      A.WEEKTODAY,  
      A.DAYDIFF,    
      A.WEEKDIFF,  
      A.PLANWEEK,  
    
      A.BLMNG as  REQTY,
      A.MEINS,
      A.CHECKPERIOD 
    
} where A.igrno = '' 



