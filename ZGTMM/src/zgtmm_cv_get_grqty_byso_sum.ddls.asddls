@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '판매오더 기준 입고 수량 합계'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_GET_GRQTY_BYSO_SUM 
as select from ZGTMM_CV_GET_GRQTY_BYSO as A
{
  key A.vbeln,
  key A.POSNR,
      A.spmon,
      @Semantics.quantity.unitOfMeasure: 'ERFME'
      sum(A.erfmg) as ERFMG,
      A.erfme,
      @Semantics.quantity.unitOfMeasure: 'ERFME' 
      sum(A.WH3410) as WH3410,
      @Semantics.quantity.unitOfMeasure: 'ERFME' 
      sum(A.WH3420) as WH3420,       
      @Semantics.quantity.unitOfMeasure: 'ERFME' 
      sum(A.WH3498) as WH3498,       
      @Semantics.quantity.unitOfMeasure: 'ERFME' 
      sum(A.WH3497) as WH3497,       
      @Semantics.quantity.unitOfMeasure: 'ERFME' 
      sum(A.WHETC) as WHETC    
} group by A.vbeln, A.POSNR,A.spmon,  A.erfme
