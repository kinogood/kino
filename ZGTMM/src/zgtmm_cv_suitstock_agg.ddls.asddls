@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '일자 별 적정재고 MAX TIMESTAMP'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_SUITSTOCK_AGG 
as select from zgtmmt4220
{
    key max(timestamp) as timestamp,
    key bukrs,
    key werks,
    key matnr
    
} group by bukrs, werks, matnr, erdat
