@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '구매 입고 내역 조회 합계(비철 중량 포함)'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_GET_GTQTY_SWEIGHT 
as select from ZGTMM_CV_GET_GTQTY_MWEIGHT 
{
  key PERIOD,
  key lifnr,
  key werks,
      @Semantics.quantity.unitOfMeasure: 'BPRME'
      sum(BPMNG) as GRQTY,
      bprme,
      mtart,
      @Semantics.quantity.unitOfMeasure: 'BME'  
      sum(METAL_TAX0) as TAX0_KG,
      cast('KG' as unit) as BME,
      @Semantics.quantity.unitOfMeasure: 'BME'  
      sum(METAL_TAX10) as TAX10_KG  
} group by PERIOD, lifnr, werks, bprme, mtart
