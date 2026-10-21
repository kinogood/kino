@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '외주 업체 보증 보험 총액_현재일자'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_DEPOSITAMT_SUM 
as select from ZGTMM_CV_DEPOSITAMT
{
    key bukrs,
    key lifnr,
    @Semantics.amount.currencyCode: 'waers'
    sum(PREIS) as PREIS, 
    butxt,
    vendorname,
    waers    
} where datab<= $session.user_date and datai>= $session.user_date
group by bukrs,lifnr, waers , butxt, vendorname
