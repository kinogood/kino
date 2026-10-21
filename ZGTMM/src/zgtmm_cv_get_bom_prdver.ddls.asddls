@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'BOM 생산 버전 조회'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_GET_BOM_PRDVER 
  with parameters
    p_datum : datum
  as select from I_ProductionVersion
{
  key Material,
  key Plant,
      min(ProductionVersion) as ProductionVersion
}
where
      ProductionVersionIsLocked = ' '
  and ValidityStartDate         <= $parameters.p_datum
  and ValidityEndDate           >= $parameters.p_datum
group by
  Material,
  Plant
