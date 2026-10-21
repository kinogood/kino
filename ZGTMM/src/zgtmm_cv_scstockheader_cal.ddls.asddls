@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '외주 사급 재고 현황(업체 별 가격 SUM)'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_SCSTOCKHEADER_CAL 
as 
select from ZGTMM_CV_SCSTOCKITEM_SUM
{
    key bukrs,
    key lifnr,
        butxt,
        VENDORNAME,
        waers,
        @Semantics.amount.currencyCode: 'waers'  
//      sum(GET_NUMERIC_VALUE(totalscvalue)) as totalscvalue       
        sum(totalscvalue) as totalscvalue
} group by bukrs,lifnr,butxt,VENDORNAME,waers
