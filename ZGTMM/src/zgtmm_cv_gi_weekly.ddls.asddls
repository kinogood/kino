@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '소모기준 적정재고 예상 소요량_WEEKLY'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_GI_WEEKLY 
with parameters 
    @Consumption.hidden: true
    @Environment.systemField: #SYSTEM_DATE
    p_startdate : vdm_v_start_date,
    p_enddate : vdm_v_end_date
as select from ZGTMM_CV_GI_ADD(p_startdate: $parameters.p_startdate,p_enddate : $parameters.p_enddate)
{
   key  bukrs,
   key  werks,
   key  matnr,
        @Semantics.quantity.unitOfMeasure: 'MEINS'
        sum(REQQTY) as REQQTY, 
        meins,
        WEEKDIFF,
        PLANWEEK
} where CHECKPERIOD = 'I' and WEEKDIFF >= 0
group by bukrs, werks, matnr, meins,WEEKDIFF, PLANWEEK
