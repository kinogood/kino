@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '가온 납품서 수량2'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_GET_GODELIVERY_SUM2 
as select from ZGTMM_CV_GET_GODELIVERY_DATA 
{
  key ebeln,
  key ebelp, 
      delno,
      delitem,
      @Semantics.quantity.unitOfMeasure: 'MEINS'        
      menge,
      meins,
      @Semantics.quantity.unitOfMeasure: 'ERFME'        
      sum(ERFMG) as ERFMG,
      ERFME,
      max(MBUDAT) as BUDAT           
} where cancelled = '' and reversal_movement = '' and MBLNR <> '' and status = ''
group by ebeln,ebelp,delno,delitem,menge,meins, ERFME
