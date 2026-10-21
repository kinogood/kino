@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '가온전선 구매 납품서 정보(자재문서 XBLNR)'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_GET_XBLNRNO 
as 
select from ZGTMM_CV_GET_MATDOC
{
    key xblnr
} where xblnr <> ''
group by xblnr
