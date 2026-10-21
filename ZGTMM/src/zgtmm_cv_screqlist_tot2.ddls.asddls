@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '외주 재고 별 소요량 리스트'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_SCREQLIST_TOT2 
as 

select from ZGTMM_CV_SCSTOCKITEM_TOT
{
    key bukrs,          
    key lifnr,
    key werks,
    key matnr as cmatnr
}

except

select from ZGTMM_CV_SCREQLIST
{
    key bukrs,          
    key lifnr,
    key werks,
    key CMATNR
} where elikz = ''

except

select from ZGTMM_CV_GETSCBOM2
{
    key bukrs,          
    key lifnr,
    key werks,
    key CMATNR
} 


