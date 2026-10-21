@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '일자 별 외주 재고 현황(금액 포함_최종)'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_SCSTOCKLIST2 
with parameters 
    @Consumption.hidden: true
    @Environment.systemField: #SYSTEM_DATE
    p_startdate : vdm_v_start_date,
    p_enddate : vdm_v_end_date,
    p_periodtype : nsdm_period_type
as 

select from ZGTMM_CV_SCSTOCKLIST(p_startdate: $parameters.p_startdate,
                                 p_enddate : $parameters.p_enddate,
                                 p_periodtype :$parameters.p_periodtype) as A 
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
  A.STPRS,
  A.PEINH,
  A.WAERS,
  @Semantics.amount.currencyCode: 'waers'
  A.STPRSBASE,
  
  @Semantics.amount.currencyCode: 'waers'  
  case when A.PEINH <> 0 and A.PEINH is not null then
   cast( cast( cast(A.STPRSBASE as abap.dec(20,2)) / A.PEINH as abap.dec(13,2)) as abap.curr(22,2)) 
  else
   A.STPRSBASE 
  end
  as TSTOCKVAL, 

  @Semantics.quantity.unitOfMeasure: 'MEINS'
  A.stockqty,
  A._UnitOfMeasure,
  A.bpname,
  A._Material,
  A._CompanyCode,
  A._Plant,
  A._Supplier,
  A.ekgrp,
  A.eknam,
  A.dispo,
  A.dsnam,
  A.matkl           
} where A.STPRS <> 0

union

select from ZGTMM_CV_SCSTOCKLIST(p_startdate: $parameters.p_startdate,
                                 p_enddate : $parameters.p_enddate,
                                 p_periodtype :$parameters.p_periodtype) as A 
       inner join mbew as B on A.werks = B.bwkey and A.matnr = B.matnr
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

  case when B.stprs is null then cast(0 as abap.curr(20,2)) else B.stprs end as STPRS,
  case when B.peinh is null then cast(1 as abap.dec(5)) else B.peinh end as PEINH,  
  A.WAERS,
  A.STPRSBASE,
   
  case when B.peinh <> 0 and B.peinh is not null then
 //  cast( cast( cast(A.STPRSBASE as abap.dec(13,2)) / A.PEINH as abap.dec(13,2)) as abap.curr(13,2)) 

      cast(cast(cast( cast(B.stprs as abap.dec(20,2)) * A.stockqty as abap.dec(20,2)) / B.peinh as abap.dec(13,2)) as abap.curr(22,2)) 
  else
      case when B.stprs is not null then
           cast( cast( cast(B.stprs as abap.dec(20,2)) * A.stockqty as abap.dec(20,2)) as abap.curr(22,2)) 
      else cast(0 as abap.curr(22,2)) 
      end 
  end
  as TSTOCKVAL, 

  A.stockqty,
  A._UnitOfMeasure,
  A.bpname,
  A._Material,
  A._CompanyCode,
  A._Plant,
  A._Supplier,
  A.ekgrp,
  A.eknam,
  A.dispo,
  A.dsnam,
  A.matkl           
} where A.STPRS = 0

//where A.WAERS <> '' 

/*
union 

select from ZGTMM_CV_SCSTOCKLIST(p_startdate: $parameters.p_startdate,
                                 p_enddate : $parameters.p_enddate,
                                 p_periodtype :$parameters.p_periodtype) as A
//       inner join ZGTMM_CV_GETSTPRICEPA as B 
       inner join mbew as B on  A.matnr = B.matnr and A.werks = B.bwkey
       inner join t001k as c on B.bwkey = c.bwkey 
       inner join t001 as d on c.bukrs = d.bukrs
{
  key A.BUKRS,
  key A.CompanyCodeName,
  key A.PeriodType,
  key A.YearPeriod,
  key A.zdate,
  key A.period,
  key A.werks,
  key A.PlantName,
  key A.LGORT,
  key A.StorageLocationName,
  key A.matnr,
  key A.MaterialName,
  key A.Batch,
  key A.Supplier,
  key A.Customer,
  key A.stocktype,
  key A.InventorySpecialStockType,
  key A.FiscalYearVariant,   
  key A.MEINS,
  @Semantics.amount.currencyCode: 'waers'
  B.stprs,
  d.waers,
  @Semantics.amount.currencyCode: 'waers' 
  cast( cast( cast(B.stprs as abap.dec(13,2)) * A.stockqty as abap.dec(13,2)) as abap.curr(13,2)) as STPRSBASE, 
  //A.STPRSBASE,
  @Semantics.amount.currencyCode: 'waers' 
  case when B.peinh <> 0 and B.peinh is not null then
    cast( cast( cast(B.stprs as abap.dec(13,2)) * A.stockqty / B.peinh as abap.dec(13,2)) as abap.curr(13,2))
  else
   cast( cast( cast(B.stprs as abap.dec(13,2)) * A.stockqty as abap.dec(13,2)) as abap.curr(13,2))
  end
  as TSTOCKVAL,
  @Semantics.quantity.unitOfMeasure: 'MEINS'                                  
  A.stockqty,
  A._UnitOfMeasure,
  A.bpname,
  A._Material,
  A._CompanyCode,
  A._Plant,
  A._StorageLocation,
  A._Supplier,
  A._Customer,
  A._InventoryStockType,
  A._InventorySpecialStockType,
  A.ekgrp,
  A.eknam,
  A.dispo,
  A.dsnam,
  A.matkl           
}where A.WAERS = ''  */
