@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '적정재고 최종 버전'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_SUITABLE_LASTSIM 
as 
select from zgtmmt4220
{
   key cast('W' as abap.char(1)) as TYPE,
   key bukrs,
   key werks,
   max(timestamp) as TIMESTAMP,
   erdat 
} group by bukrs, werks, erdat

union all
select from zgtmmt4222
{
   key cast('D' as abap.char(1)) as TYPE,
   key bukrs,
   key werks,
   max(timestamp) as TIMESTAMP,
   erdat 
} group by bukrs, werks, erdat
