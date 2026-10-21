@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '플랜트/자재/주차 별 총계./평균'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_GETGISUM_WEEK 
with parameters 
    @Consumption.hidden: true
    @Environment.systemField: #SYSTEM_DATE
    p_startdate : vdm_v_start_date,
    p_enddate : vdm_v_end_date
as 
select from ZGTMM_CV_GETGILIST_WEEK(p_startdate: $parameters.p_startdate,
                                    p_enddate : $parameters.p_enddate)
{
    key bukrs,
    key werks,
    key matnr,
    key WEEK,
    
    @Semantics.quantity.unitOfMeasure: 'MEINS'        
    sum(MENGE) as MENGE,
    meins
    
} group by bukrs, werks, matnr, meins, WEEK
