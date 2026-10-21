@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'B/L 수량 집계'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_GET_BLQTY 
as select from ztitblk as a inner join ztitblp as b on a.iblno = b.iblno
       inner join mara as D on b.matnr = D.matnr
       inner join scal_tt_date as e on a.bleta = e.calendardate
       inner join ekpo as P on b.ebeln = P.ebeln and b.ebelp = P.ebelp
       left outer join ztitgrp as c on b.iblno = c.iblno and b.iblit = c.iblit
       left outer join ZGTMM_CV_UNIT_FACTOR as UNIT on b.meins = UNIT.UNIT  
       left outer join zgtmmt4203 as f on b.werks = f.werks and b.matnr = f.matnr    
association [1..1] to scal_tt_date as SYST on  SYST.calendardate = $session.user_date         
{

    key a.iblno,
    key a.werks,
    key b.matnr,
    key b.ebeln,
    key b.ebelp,
    @Semantics.quantity.unitOfMeasure: 'MEINS'
    case when b.meins = D.meins then b.blmng
         else
             cast(b.blmng * UNIT.zaehl / UNIT.nennr as abap.quan(13,3))
         end as BLMNG,
    case when b.meins = D.meins then b.meins
         else UNIT.SIUNIT
         end as MEINS,
    a.bleta,
    case when c.igrno is null then cast('' as ztiigrno)
         else c.igrno end  as igrno,
    a.rptty,
    e.calendaryear,
    e.calendarweek,
    SYST.calendaryear as YEARTODAY,
    SYST.calendarweek as WEEKTODAY,  
    DATS_DAYS_BETWEEN($session.user_date,a.bleta) as DAYDIFF,      
    case when SYST.calendaryear < e.calendaryear
         then 
           ((cast(e.calendaryear as abap.dec(4)) - cast(SYST.calendaryear as abap.dec(4))) * 52 )
             + cast(e.calendarweek as abap.dec(2)) - cast(SYST.calendarweek as abap.dec(2))
         else cast(e.calendarweek as abap.dec(2)) - cast(SYST.calendarweek as abap.dec(2))
         end as WEEKDIFF,  
    case when f.week is not null then cast(f.week as abap.dec(2))
         else cast('15' as abap.dec(2)) end as PLANWEEK,       
    case when f.week is not null then
        case when SYST.calendaryear < e.calendaryear
             then 
               case when 
                cast(e.calendaryear as abap.dec(4)) * 52 - cast(SYST.calendaryear as abap.dec(4)) * 52  + cast(e.calendarweek as abap.dec(2)) - cast(SYST.calendarweek as abap.dec(2))  > cast(f.week as abap.dec(2))
               then cast('E' as abap.char(1)) 
               else cast('I' as abap.char(1)) end
             
             else 
               case when cast(e.calendarweek as abap.dec(2)) - cast(SYST.calendarweek as abap.dec(2)) >cast(f.week as abap.dec(2))
               then cast('E' as abap.char(1)) 
                    else cast('I' as abap.char(1)) end
             
             end  
  
       else
        case when SYST.calendaryear < e.calendaryear
             then 
               case when 
                cast(e.calendaryear as abap.dec(4)) * 52 - cast(SYST.calendaryear as abap.dec(4)) * 52  + cast(e.calendarweek as abap.dec(2)) - cast(SYST.calendarweek as abap.dec(2))  > cast(15 as abap.dec(2))
               then cast('E' as abap.char(1)) 
               else cast('I' as abap.char(1)) end
             
             else 
               case when cast(e.calendarweek as abap.dec(2)) - cast(SYST.calendarweek as abap.dec(2)) > cast(15 as abap.dec(2))
               then cast('E' as abap.char(1)) 
                    else cast('I' as abap.char(1)) end
             
             end         
       
       end as CHECKPERIOD      
} where  b.matnr <> '' and a.bleta > $session.user_date and P.elikz = '' and P.loekz = ''
