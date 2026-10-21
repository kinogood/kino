@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'BOM Multi Level 조회'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_GET_BOM_ML 

  with parameters
    p_datum : datum
  as select from ZGTMM_CV_GET_BOM_PRDVER( p_datum: $parameters.p_datum ) as _ProdVersion
    inner join   I_ProductionVersion                                         as _ProductionVersion on  _ProductionVersion.Material          = _ProdVersion.Material
                                                                                                   and _ProductionVersion.Plant             = _ProdVersion.Plant
                                                                                                   and _ProductionVersion.ProductionVersion = _ProdVersion.ProductionVersion
    inner join   I_Mast                                                      as _MaterialBOM       on  _MaterialBOM.Material                   = _ProductionVersion.Material
                                                                                                   and _MaterialBOM.Plant                      = _ProductionVersion.Plant
                                                                                                   and _MaterialBOM.BillOfMaterialVariantUsage = '1'
                                                                                                   and _MaterialBOM.BillOfMaterialVariant      = _ProductionVersion.BillOfMaterialVariant
    inner join   I_BOMSelectionEAM                                           as _BOMItems          on  _BOMItems.BillOfMaterialCategory = 'M'
                                                                                                   and _BOMItems.BillOfMaterial         = _MaterialBOM.BillOfMaterial
                                                                                                   and _BOMItems.BillOfMaterialVariant  = _MaterialBOM.BillOfMaterialVariant
    inner join   I_BillOfMaterial                                            as _BOMHeader         on  _BOMHeader.BillOfMaterialCategory = 'M'
                                                                                                   and _BOMHeader.BillOfMaterial         = _MaterialBOM.BillOfMaterial
                                                                                                   and _BOMHeader.BillOfMaterialVariant  = _MaterialBOM.BillOfMaterialVariant
    inner join   I_BillOfMaterialItem                                        as _BOMItem           on  _BOMItem.BillOfMaterialCategory       = 'M'
                                                                                                   and _BOMItem.BillOfMaterial               = _BOMItems.BillOfMaterial
                                                                                                   and _BOMItem.BillOfMaterialItemNodeNumber = _BOMItems.BillOfMaterialItemNodeNumber
    inner join   I_Product                                                   as _Product           on  _Product.Product             = _BOMItem.BillOfMaterialComponent
                                                                                                   and _Product.IsMarkedForDeletion = ''
{
  key _ProductionVersion.Material                                             as Material,
  key _ProductionVersion.Plant                                                as Plant,
      _ProductionVersion.ProductionVersion                                    as ProductionVersion,
      _ProductionVersion.ValidityStartDate                                    as ValidityStartDate,
      _ProductionVersion.ValidityEndDate                                      as ValidityEndDate,
      @Semantics.quantity.unitOfMeasure: 'BOMHeaderQtyUnit'
      cast( _BOMHeader.BOMHeaderQuantityInBaseUnit as bstmg preserving type ) as BOMHeaderQty,
      _BOMHeader.BOMHeaderBaseUnit                                            as BOMHeaderQtyUnit,
      _BOMItem.BillOfMaterialComponent                                        as Component,
      @Semantics.quantity.unitOfMeasure: 'BOMItemQtyUnit'
      _BOMItem.BillOfMaterialItemQuantity                                     as BOMItemQty,
      _BOMItem.BillOfMaterialItemUnit                                         as BOMItemQtyUnit,
      _BOMItem.ComponentScrapInPercent                                        as ComponentScrapInPercent,
      _BOMItem.ValidityStartDate                                              as BOMValidityStartDate,
      _BOMItem.ValidityEndDate                                                as BOMValidityEndDate,
      _Product.BaseUnit                                                       as BaseUnit,
      _BOMItem.MaterialIsCoProduct                                            as CoProduct
}
where
      _BOMItem.ValidityStartDate <= $parameters.p_datum
  and _BOMItem.ValidityEndDate   >= $parameters.p_datum
