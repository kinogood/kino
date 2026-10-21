@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '일자 별 외주 재고 현황(금액 포함)'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_SCSTOCKLIST 
with parameters 
    @Consumption.hidden: true
    @Environment.systemField: #SYSTEM_DATE
    p_startdate : vdm_v_start_date,
    p_enddate : vdm_v_end_date,
    p_periodtype : nsdm_period_type
as 
select from ZGTMM_CV_GETSCSTOCK(p_startdate: $parameters.p_startdate,
                                p_enddate : $parameters.p_enddate,
                                p_periodtype :$parameters.p_periodtype) as A
//       left outer join ZGTMM_CV_GETSTPRICE as B
       left outer join ZGTMM_CV_GETSTPRICE as B 
       on A.matnr = B.matnr and A.werks = B.WERKS and A.period = B.PERIOD            
{
  key A.BUKRS,
  key A.CompanyCodeName,
  key A.zdate,
  key A.period,
  key A.werks,
  key A.PlantName,
  key A.matnr,
  key A.MaterialName,
  key A.Batch,
  key A.Supplier,
  key A.MEINS,
  

  @Semantics.amount.currencyCode: 'waers'
  case when B.STPRS is null then cast(0 as abap.curr(20,2)) else B.STPRS end as STPRS,
  case when B.peinh is null then cast(1 as abap.dec(5)) else B.peinh end as PEINH,  
  case when B.waers is null then cast('KRW' as abap.cuky(5)) else B.waers end as WAERS,

  @Semantics.amount.currencyCode: 'waers'
//  cast(GET_NUMERIC_VALUE(B.stprs) * GET_NUMERIC_VALUE(A.stockqty) as abap.dec(21,2)) as STPRSBASE, 
//  cast( cast( cast(B.stprs as abap.dec(13,2)) * A.stockqty / B.peinh as abap.dec(13,2)) as abap.curr(13,2)) as STPRSBASE,
  case when B.STPRS is not null then
       cast( cast( cast(B.STPRS as abap.dec(20,2)) * A.stockqty as abap.dec(20,2)) as abap.curr(20,2)) 
  else cast(0 as abap.curr(20,2)) 
  end as STPRSBASE,
  @Semantics.quantity.unitOfMeasure: 'MEINS'
  A.stockqty,
  A._UnitOfMeasure,
  A._Supplier.OrganizationBPName1 as bpname,
  A._Material,
  A._CompanyCode,
  A._Plant,
  A._Supplier,
  A.ekgrp,
  A.eknam,
  A.dispo,
  A.dsnam,
  A.matkl          
      
} where A.stockqty > 0
/*
union


select from ZGTMM_CV_GETSCSTOCK(p_startdate: $parameters.p_startdate,
                                p_enddate : $parameters.p_enddate,
                                p_periodtype :$parameters.p_periodtype) as A
       inner join mbew as B 
       on A.matnr = B.matnr and A.werks = B.bwkey and A.period >= CONCAT(B.lfgja,B.lfmon)  
       inner join t001k as C on B.bwkey = C.bwkey 
       inner join t001 as D on C.bukrs = D.bukrs    
{
  key A.BUKRS,
  key A.CompanyCodeName,
  key A.zdate,
  key A.period,
  key A.werks,
  key A.PlantName,
  key A.matnr,
  key A.MaterialName,
  key A.Batch,
  key A.Supplier,
  key A.MEINS,

  case when B.stprs is null then cast(0 as abap.curr(11,2)) else B.stprs end as STPRS,
  case when B.peinh is null then cast(1 as abap.dec(5)) else B.peinh end as PEINH,  
  case when D.waers is null then cast('KRW' as abap.cuky(5)) else D.waers end as WAERS,

//  cast(GET_NUMERIC_VALUE(B.stprs) * GET_NUMERIC_VALUE(A.stockqty) as abap.dec(21,2)) as STPRSBASE, 
//  cast( cast( cast(B.stprs as abap.dec(13,2)) * A.stockqty / B.peinh as abap.dec(13,2)) as abap.curr(13,2)) as STPRSBASE,
  cast( cast( cast(B.stprs as abap.dec(13,2)) * A.stockqty as abap.dec(13,2)) as abap.curr(13,2)) as STPRSBASE,
  A.stockqty,
  A._UnitOfMeasure,
  A._Supplier.OrganizationBPName1 as bpname,
  A._Material,
  A._CompanyCode,
  A._Plant,
  A._Supplier,
  A.ekgrp,
  A.eknam,
  A.dispo,
  A.dsnam,
  A.matkl          
      
} 
*/
