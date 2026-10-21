@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '구매오더 기준 입고 수량 합계'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_GET_GRQTY_BYPO_SUM 
as select from ZGTMM_CV_GET_GRQTY_BYPO as a
{
  key a.ebeln,
  key a.ebelp,
      a.spmon,
      @Semantics.quantity.unitOfMeasure: 'ERFME'
      sum(a.erfmg) as ERFMG,
      a.erfme,
      @Semantics.quantity.unitOfMeasure: 'ERFME' 
      sum(a.WH3410) as WH3410,
      @Semantics.quantity.unitOfMeasure: 'ERFME' 
      sum(a.WH3420) as WH3420,       
      @Semantics.quantity.unitOfMeasure: 'ERFME' 
      sum(a.WH3498) as WH3498,       
      @Semantics.quantity.unitOfMeasure: 'ERFME' 
      sum(a.WH3497) as WH3497,       
      @Semantics.quantity.unitOfMeasure: 'ERFME' 
      sum(a.WHETC) as WHETC
} group by a.ebeln, a.ebelp, a.spmon, a.erfme
