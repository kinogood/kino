@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '소모 기준 적정 재고 산출 기초 데이터2(Daily)'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_GI_BASE2 
with parameters 
    @Consumption.hidden: true
    @Environment.systemField: #SYSTEM_DATE
    p_startdate : vdm_v_start_date,
    p_enddate : vdm_v_end_date
as 
select from ZGTMM_CV_GI_BASE(p_startdate: $parameters.p_startdate,
                             p_enddate : $parameters.p_enddate)
{
  key bukrs,
  key werks,
  key matnr,
      @Semantics.quantity.unitOfMeasure: 'MEINS'
      REMAINQTY, 
      meins,
      BDTER,  
      bdteryear,
      PLANWEEK    
}
