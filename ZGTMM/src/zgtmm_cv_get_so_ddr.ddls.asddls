@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '직송의뢰 대표 판매오더 조회'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_GET_SO_DDR as 
select from zgtmmt4411
{
  key bukrs,
  key dlvrq,
  max(vbeln) as VBELN  
} group by bukrs, dlvrq

union all

select from zgtmmt4412
{
  key bukrs,
  key dlvrq,
  max(vbeln) as VBELN  
} group by bukrs, dlvrq
