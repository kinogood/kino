@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '일자 별 외주 재고 현황(Merge)'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_SCSTOCKLIST3
with parameters 
    @Consumption.hidden: true
    @Environment.systemField: #SYSTEM_DATE
    p_startdate : vdm_v_start_date,
    p_enddate : vdm_v_end_date,
    p_periodtype : nsdm_period_type 
as select from ZGTMM_CV_SCSTOCKLIST2(p_startdate: $parameters.p_startdate,
                                 p_enddate : $parameters.p_enddate,
                                 p_periodtype :$parameters.p_periodtype)
{
  key BUKRS,
  key CompanyCodeName,
  key zdate,
  key Supplier,
  bpname,
  WAERS,  
  @Semantics.amount.currencyCode: 'waers'  
  sum(TSTOCKVAL) as TSTOCKVAL

         
} group by BUKRS, CompanyCodeName, zdate, Supplier, bpname, WAERS
