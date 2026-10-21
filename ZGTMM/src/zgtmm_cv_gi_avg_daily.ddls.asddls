@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '소모기준 적정 재고 예상 소요량 1차평균(DAILY)'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_GI_AVG_DAILY 
with parameters 
    @Consumption.hidden: true
    @Environment.systemField: #SYSTEM_DATE
    p_startdate : vdm_v_start_date,
    p_enddate : vdm_v_end_date
as 
select from ZGTMM_CV_GI_ADD(p_startdate: $parameters.p_startdate,
                               p_enddate : $parameters.p_enddate)
{
   key  bukrs,
   key  werks,
   key  matnr,
        @Semantics.quantity.unitOfMeasure: 'MEINS'
        avg(cast(REQQTY as abap.dec(13,2)) as abap.quan(13,2)) as AVGQTY ,
        meins
} where WEEKDIFF > 0 and CHECKPERIOD = 'I'
group by bukrs, werks, matnr, meins

