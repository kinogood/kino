@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '플랜트/자재/일자 별 총계/평균'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_GETGISUM_DAILY 
with parameters 
    @Consumption.hidden: true
    @Environment.systemField: #SYSTEM_DATE
    p_startdate : vdm_v_start_date,
    p_enddate : vdm_v_end_date
as 
select from ZGTMM_CV_GETGILIST_DAILY(p_startdate: $parameters.p_startdate,
                                    p_enddate : $parameters.p_enddate)
{
    key bukrs,
    key werks,
    key matnr,
    key budat,
    
    @Semantics.quantity.unitOfMeasure: 'MEINS'        
    sum(MENGE) as MENGE,
    meins,
    DAYC
    
} group by bukrs, werks, matnr, meins, budat, DAYC

/*


select from ZGTMM_CV_GETGILIST_DAILY(p_startdate: $parameters.p_startdate,
                                    p_enddate : $parameters.p_enddate) as A
            LEFT outer join scal_tt_date as B   on a.year_budat = b.calendaryear AND B.calendardate >= $parameters.p_startdate and B.calendardate <= $parameters.p_enddate
{
    key A.bukrs,
    key A.werks,
    key b.matnr,
    
    @Semantics.quantity.unitOfMeasure: 'MEINS'        
    sum(b.MENGE) as MENGE_TOT,
 //   cast(sum(MENGE) / DATS_DAYS_BETWEEN($parameters.p_startdate,$parameters.p_enddate) as abap.decfloat16) as  MENGE_AVG,
    b.meins
} where a.calendardate >= $parameters.p_startdate and a.calendardate <= $parameters.p_enddate
group by a.calendardate,b.bukrs, b.werks, b.matnr, b.meins
*/
