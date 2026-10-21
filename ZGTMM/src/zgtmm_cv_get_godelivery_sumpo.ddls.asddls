@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '가온 납품서 수량(PO 기준)'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_GET_GODELIVERY_SUMPO 
as select from ZGTMM_CV_GET_GODELIVERY_DATA
{
  key ebeln,
  key ebelp, 
  key delno,
  key delitem,
      @Semantics.quantity.unitOfMeasure: 'MEINS'        
      menge,
      meins,
      @Semantics.quantity.unitOfMeasure: 'ERFME'        
      sum(ERFMG) as ERFMG,
      ERFME       
} group by ebeln,ebelp,delno, delitem, menge, meins, ERFME
