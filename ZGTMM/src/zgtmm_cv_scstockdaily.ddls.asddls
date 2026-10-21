@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '일자 별 외주 재고 현황(업체 Summary Temp)'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_SCSTOCKDAILY 
with parameters 
    @Consumption.hidden: true
    @Environment.systemField: #SYSTEM_DATE
    p_startdate : vdm_v_start_date,
    p_enddate : vdm_v_end_date,
    p_periodtype : nsdm_period_type
as 
select from ZGTMM_CV_SCSTOCKLIST3(p_startdate: $parameters.p_startdate,
                                  p_enddate : $parameters.p_enddate,
                                  p_periodtype :$parameters.p_periodtype) as A
       left outer join ZGTMM_CV_DEPOSITAMT as B 
       on A.Supplier = B.lifnr and A.zdate >= B.datab and A.zdate <= B.datai
{ 
   key A.BUKRS,
   key A.zdate,  
   key A.Supplier,
   A.bpname,
   @Semantics.amount.currencyCode: 'waers'
   sum(B.PREIS) as preis,       
   B.waers,
   @Semantics.amount.currencyCode: 'waers'
   cast(A.TSTOCKVAL as abap.curr(23,2)) as tstockval
     
} group by A.BUKRS, A.zdate, A.Supplier, A.bpname, B.waers, A.TSTOCKVAL
