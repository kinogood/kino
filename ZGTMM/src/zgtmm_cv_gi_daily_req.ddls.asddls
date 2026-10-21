@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Daily 소요량 계산(소모 기준)'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_GI_DAILY_REQ 
with parameters 
    @Consumption.hidden: true
    @Environment.systemField: #SYSTEM_DATE
    p_startdate : vdm_v_start_date,
    p_enddate : vdm_v_end_date
as 
select from ZGTMM_CV_GI_ADD(p_startdate: $parameters.p_startdate,
                            p_enddate : $parameters.p_enddate)
{
   key  werks,
   key  matnr,
        PLANWEEK,
        @Semantics.quantity.unitOfMeasure: 'MEINS'
        cast(sum(REQQTY) / (PLANWEEK * 7 ) as abap.quan(13,3)) as DREQ,
        meins
 } where CHECKPERIOD = 'I' and WEEKDIFF > 0 
 group by werks, matnr, meins, PLANWEEK
