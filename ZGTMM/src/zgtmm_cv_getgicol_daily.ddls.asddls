@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '플랜트/자재 합계/.평균'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_GETGICOL_DAILY
with parameters 
    @Consumption.hidden: true
    @Environment.systemField: #SYSTEM_DATE
    p_startdate : vdm_v_start_date,
    p_enddate : vdm_v_end_date
as 
select from ZGTMM_CV_GETGISUM_DAILY(p_startdate: $parameters.p_startdate,
                                    p_enddate : $parameters.p_enddate)
{
    key bukrs,
    key werks, 
    key matnr,
    
    @Semantics.quantity.unitOfMeasure: 'MEINS'        
    sum(MENGE) as QTY,
    @Semantics.quantity.unitOfMeasure: 'MEINS'  
 //   cast(avg(MENGE as abap.fltp) as abap.quan(13,3)) as AVERAGE,
    cast(sum(MENGE) / DAYC as abap.quan(13,3)) as AVERAGE,
 //   DATS_DAYS_BETWEEN($parameters.p_startdate,$parameters.p_enddate)  as DAYC,
    DAYC,
    meins
} group by bukrs, werks, matnr, meins, DAYC
