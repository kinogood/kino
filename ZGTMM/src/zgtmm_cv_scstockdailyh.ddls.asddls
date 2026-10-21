@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '일자 별 외주 재고 현황(업체 SUMMARY HEADER)'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_SCSTOCKDAILYH 
with parameters 
    @Consumption.hidden: true
    @Environment.systemField: #SYSTEM_DATE
    p_startdate : vdm_v_start_date,
    p_enddate : vdm_v_end_date,
    p_periodtype : nsdm_period_type
as 
select from ZGTMM_CV_SCSTOCKDAILY(p_startdate: $parameters.p_startdate,
                                  p_enddate : $parameters.p_enddate,
                                  p_periodtype :$parameters.p_periodtype)
{ 
   key BUKRS,
   key zdate,  
   key Supplier,
   bpname,
   @Semantics.amount.currencyCode: 'waers'
   preis,       
   waers,
   @Semantics.amount.currencyCode: 'waers'
   cast(tstockval as abap.curr(23,2)) as tstockval,
   @Semantics.amount.currencyCode: 'waers'   
   cast(preis - tstockval as abap.curr(23,2)) as REMAINVAL       
/*   case when B.PREIS is null 
        then GET_NUMERIC_VALUE(A.TSTOCKVAL) * -1 
        else GET_NUMERIC_VALUE(B.PREIS) - GET_NUMERIC_VALUE(A.TSTOCKVAL) 
   end as REMAINVAL */
     
}
