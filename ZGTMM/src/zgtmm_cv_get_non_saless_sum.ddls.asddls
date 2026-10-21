@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'MTS 재고 현황 조회 합계(공장 내)'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_GET_NON_SALESS_SUM 
as select from ZGTMM_CV_GET_NON_SALESSTOCK 
{
   key matnr,
   key werks,
   @Semantics.quantity.unitOfMeasure: 'MEINS'  
   sum(clabs) as CLABS,
   meins,
   sum(DRQTY) as DRQTY
} group by matnr, werks, meins
