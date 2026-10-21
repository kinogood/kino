@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '소모 기준 적정 재고 산출 기초 데이터(Daily)'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_GI_BASE 
with parameters 
    @Consumption.hidden: true
    @Environment.systemField: #SYSTEM_DATE
    p_startdate : vdm_v_start_date,
    p_enddate : vdm_v_end_date
as 
select from ZGTMM_CV_GETGICOL_DAILY(p_startdate: $parameters.p_startdate,
                                    p_enddate : $parameters.p_enddate) as a             
            inner join scal_tt_date as B on B.calendardate >= $session.user_date and B.calendardate <= dats_add_days($session.user_date,150,'INITIAL')
            inner join zgtmmt4203 as c on a.werks = c.werks and a.matnr = c.matnr        
{
    key a.bukrs,
    key a.werks,
    key a.matnr,
    
    @Semantics.quantity.unitOfMeasure: 'MEINS'        
    a.AVERAGE as REMAINQTY,
    a.meins,
    B.calendardate as BDTER, 
    B.calendaryear as bdteryear,
    case when c.week is not null and cast(c.week as abap.dec(2)) <> 0 then cast(c.week as abap.dec(2))
         else cast('15' as abap.dec(2)) end as PLANWEEK
}



