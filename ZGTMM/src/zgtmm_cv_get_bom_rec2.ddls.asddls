@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'BOM 다중 조회 DATA2'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_GET_BOM_REC2 
with parameters 
    p_matnr : matnr,
    p_werks : werks_d,
    p_datum : datum
as select from ZGTMM_CV_GET_BOM_REC1(p_matnr:  $parameters.p_matnr ,p_werks: $parameters.p_werks, p_datum: $parameters.p_datum) as A
      
{
 key  A.Material ,
      A.Plant,            
      A.ProductionVersion,
      A.ValidityStartDate,
      A.ValidityEndDate,
      @Semantics.quantity.unitOfMeasure: 'BOMHeaderQtyUnit'       
      A.BOMHeaderQty,           
      A.BOMHeaderQtyUnit,
      A.BOMLevel - 1 as BOMLevel,
      A.Parent
} group by A.Material, A.Plant, A.ProductionVersion, A.ValidityStartDate, A.ValidityEndDate,
           A.BOMHeaderQty, A.BOMHeaderQtyUnit, A.BOMLevel, A.Parent
