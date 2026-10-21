@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'BOM 다중 조회 DATA3'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_GET_BOM_REC3 
with parameters 
    p_matnr : matnr,
    p_werks : werks_d,
    p_datum : datum
as select from ZGTMM_CV_GET_BOM_REC1(p_matnr:  $parameters.p_matnr ,p_werks: $parameters.p_werks, p_datum: $parameters.p_datum) as A
   left outer join ZGTMM_CV_GET_BOM_REC2(p_matnr:  $parameters.p_matnr ,p_werks: $parameters.p_werks, p_datum: $parameters.p_datum) as B
   on  A.Material = B.Material and A.Plant = B.Plant and A.BaseUnit = B.BOMHeaderQtyUnit
   and A.BOMLevel = B.BOMLevel and A.Component = B.Parent and A.ValidityStartDate <= $parameters.p_datum and A.ValidityEndDate >= $parameters.p_datum
   and B.ValidityStartDate <= $parameters.p_datum and B.ValidityEndDate >= $parameters.p_datum
association [0..1] to makt as MAKT on $projection.Component = MAKT.matnr and MAKT.spras = $session.system_language

{
 key  A.Material ,
      A.Plant,            
      A.ProductionVersion,
      A.ValidityStartDate,
      A.ValidityEndDate,
      @Semantics.quantity.unitOfMeasure: 'BOMHeaderQtyUnit'       
      A.BOMHeaderQty,           
      A.BOMHeaderQtyUnit,
      A.BOMLevel,
      A.Parent,
      A.Component, 
      makt.maktx,
      @Semantics.quantity.unitOfMeasure: 'BOMItemQtyUnit'       
      A.BOMItemQty,
      A.BOMItemQtyUnit,
      A.ComponentScrapInPercent,
      A.BOMValidityStartDate,
      A.BOMValidityEndDate,
      A.BaseUnit,
      A.CoProduct,
      A.hrktx,
      A.atwrt,
      case when B.Material is not null then cast('X' as abap.char(1)) else cast('' as abap.char(1)) end as ASM      
} 
