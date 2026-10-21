@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '직납 납품서 합산 금액'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_GETINB_VALUE_SUM 
as select from ZGTMM_CV_GETINBDIRECT_I
{
   key vbeln,
   @Semantics.amount.currencyCode: 'waers'  
   cast(sum(stockvalue) as abap.curr(22,2)) as stockvalSUM,
   waers 
} group by vbeln, waers
