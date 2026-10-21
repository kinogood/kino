@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '외주 사급 재고 현황_자재별'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_SCSTOCKITEM_TOT 
as select from ZGTMM_CV_SCSTOCKITEM_SUM
{
    key bukrs,
    key werks,    
    key lifnr,
    key matnr,
  
        @Semantics.quantity.unitOfMeasure: 'MEINS'
        sum(lblab) as lblab,
        meins,
    
        @Semantics.amount.currencyCode: 'waers'  
        sum(totalscvalue) as totalscvalue,
        waers  
} group by bukrs,werks,lifnr,matnr,meins,waers
