@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '플랜트/자재/주차 별 합계/.평균'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_GETGICOL_WEEK 
with parameters 
    @Consumption.hidden: true
    @Environment.systemField: #SYSTEM_DATE
    p_startdate : vdm_v_start_date,
    p_enddate : vdm_v_end_date
as 
select from ZGTMM_CV_GETGISUM_WEEK(p_startdate: $parameters.p_startdate,
                                    p_enddate : $parameters.p_enddate)
{
    key bukrs,
    key werks, 
    key matnr,
    
    @Semantics.quantity.unitOfMeasure: 'MEINS'        
    sum(MENGE) as QTY,
    @Semantics.quantity.unitOfMeasure: 'MEINS'      
    cast(avg(MENGE as abap.fltp) as abap.quan(13,3)) as AVERAGE,
//    @Semantics.quantity.unitOfMeasure: 'MEINS'  
//    cast(sum(MENGE) / DCOUNT as abap.quan(13,3)) as AVERAGE,
    DATS_DAYS_BETWEEN($parameters.p_startdate,$parameters.p_enddate)  as DAYC,
    
    meins
} group by bukrs, werks, matnr, meins
