@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '외주 업체/기간 별 보증 보험 금액'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_DEPOSITAMT 
as 
select from zmmt0860
association [0..1] to lfa1 as VENDOR on $projection.lifnr = VENDOR.lifnr
association [0..1] to t001 as company on $projection.bukrs = company.bukrs
{
    key bukrs,
    key lifnr, 
    key datab,
    key datai,
    VENDOR.name1 as vendorname,
    company.butxt as butxt,
    @Semantics.amount.currencyCode: 'waers'
    sum(preis) as PREIS,
    waers
} group by bukrs, lifnr, datab, datai, waers, VENDOR.name1, company.butxt
