@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '일자 별 외주 재고 현황'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_GETSCSTOCK 
with parameters 
    @Consumption.hidden: true
    @Environment.systemField: #SYSTEM_DATE
    p_startdate : vdm_v_start_date,
    p_enddate : vdm_v_end_date,
    p_periodtype : nsdm_period_type
as
select from mara as A 
       inner join I_MaterialStockTimeSeries(P_StartDate: $parameters.p_startdate,
                                            P_EndDate : $parameters.p_enddate,
                                            P_PeriodType :$parameters.p_periodtype) as B on A.matnr = B.Material
       inner join marc as c on B.Material = c.matnr and B.Plant = c.werks
         
       association [1]   to t024 as t024  on $projection.ekgrp = t024.ekgrp     
       association [1]   to t024d as t024d  on $projection.werks = t024d.werks and $projection.dispo = t024d.dispo            
{
  key B.CompanyCode as BUKRS,
  key B._CompanyCode.CompanyCodeName,
  key B.PeriodType,
  key B.YearPeriod,
  key B.EndDate as zdate,
  key cast(left(B.EndDate,6) as abap.numc(6)) as period,
  key B.Plant as werks,
  key B._Plant.PlantName,
  key B.StorageLocation as LGORT,
  key B._StorageLocation.StorageLocationName,
  key B.Material as matnr,
  key B._Material._Text[1: Language= $session.system_language].MaterialName,
  key B.Batch,
  key B.Supplier,
  key B.Customer,
  key B.InventoryStockType as stocktype,
  key B.InventorySpecialStockType,
  key B.FiscalYearVariant,   
  key B.MaterialBaseUnit as MEINS,

  @Semantics.quantity.unitOfMeasure: 'MEINS'
  cast( B.MatlWrhsStkQtyInMatlBaseUnit as abap.quan( 13, 3 ))  as stockqty,
  B._UnitOfMeasure,
  B._Material,
  B._CompanyCode,
  B._Plant,
  B._StorageLocation,
  B._Supplier,
  B._Customer,
  B._InventoryStockType,
  B._InventorySpecialStockType,
  c.ekgrp,
  t024.eknam,
  c.dispo,
  t024d.dsnam,
  A.matkl      
} where B.InventorySpecialStockType = 'O'
