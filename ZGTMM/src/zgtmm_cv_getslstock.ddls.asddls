@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '저장위치 별 재고 현황'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_GETSLSTOCK 
as select from nsdm_e_mard as A inner join mara as B on A.matnr = B.matnr
{
  key A.matnr,
  key A.werks,
  key A.lgort,  
  @Semantics.quantity.unitOfMeasure: 'meins'
  sum(A.labst) as LABST,
  @Semantics.quantity.unitOfMeasure: 'meins'
  sum(A.insme) as INSME,
  B.meins
} group by A.matnr, A.werks, A.lgort, B.meins
