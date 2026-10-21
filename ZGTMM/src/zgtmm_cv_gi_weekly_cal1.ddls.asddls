@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '소모기준 적정재고 예상 소요량_WEEKLY 1차 계산'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_GI_WEEKLY_CAL1 
with parameters 
    @Consumption.hidden: true
    @Environment.systemField: #SYSTEM_DATE
    p_startdate : vdm_v_start_date,
    p_enddate : vdm_v_end_date
as    
select from ZGTMM_CV_GI_WEEKLY(p_startdate: $parameters.p_startdate,p_enddate : $parameters.p_enddate) as A 
  inner join ZGTMM_CV_GI_AVG_WEEKLY(p_startdate: $parameters.p_startdate,p_enddate : $parameters.p_enddate) as B 
  on A.werks = B.werks and A.matnr = B.matnr
{ 
   key  A.bukrs,
   key  A.werks,
   key  A.matnr,
        @Semantics.quantity.unitOfMeasure: 'MEINS'
        A.REQQTY,
        A.WEEKDIFF, 
        @Semantics.quantity.unitOfMeasure: 'MEINS'
        cast((A.REQQTY - B.AVGQTY) * (A.REQQTY - B.AVGQTY) as abap.quan(13,2)) as CALQTY, 
        A.meins,
        A.PLANWEEK
} 
