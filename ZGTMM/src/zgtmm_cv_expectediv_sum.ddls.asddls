@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '당월 송장 처리 예상 금액(SUM)'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_EXPECTEDIV_SUM 
as select from ZGTMM_CV_EXPECTEDIV 
{
  key bukrs,
  key lifnr, 
      @Semantics.amount.currencyCode: 'waers'         
      sum(DMBTR) as EXPECTEDIV,
      waers
} group by bukrs, lifnr, waers
