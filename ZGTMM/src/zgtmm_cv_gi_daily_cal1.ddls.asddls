@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '소모기준 적정재고 예상 소요량_DAILY 1차 계산'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_GI_DAILY_CAL1
with parameters 
    @Consumption.hidden: true
    @Environment.systemField: #SYSTEM_DATE
    p_startdate : vdm_v_start_date,
    p_enddate : vdm_v_end_date
as 
select from ZGTMM_CV_GI_ADD(p_startdate: $parameters.p_startdate,p_enddate : $parameters.p_enddate) as A
       inner join ZGTMM_CV_GI_AVG_DAILY(p_startdate: $parameters.p_startdate,p_enddate : $parameters.p_enddate) as b
       on A.werks = b.werks and A.matnr = b.matnr
{ 
   key  A.bukrs,
   key  A.werks,
   key  A.matnr,
        @Semantics.quantity.unitOfMeasure: 'MEINS'
        A.REQQTY,
        A.BDTER, 
        A.DAYDIFF,
        @Semantics.quantity.unitOfMeasure: 'MEINS'
        cast((A.REQQTY - b.AVGQTY) * (A.REQQTY - b.AVGQTY) as abap.quan(13,2)) as CALQTY, 
        A.meins,
        A.PLANWEEK
   
} where A.CHECKPERIOD = 'I' and A.WEEKDIFF > 0
