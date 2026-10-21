@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '소모 기준 적정재고 예상 소요량 합계'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_GI_SUM 
with parameters 
    @Consumption.hidden: true
    @Environment.systemField: #SYSTEM_DATE
    p_startdate : vdm_v_start_date,
    p_enddate : vdm_v_end_date
as select from ZGTMM_CV_GI_BASE2(p_startdate: $parameters.p_startdate,
                                 p_enddate : $parameters.p_enddate)

{ 
   key bukrs,
   key werks,
   key matnr,
      @Semantics.quantity.unitOfMeasure: 'MEINS'
      sum(REMAINQTY) as REQQTY, 

      meins,
      BDTER,  
      bdteryear,
      PLANWEEK   
} group by bukrs,werks, matnr, meins, BDTER, bdteryear, PLANWEEK
