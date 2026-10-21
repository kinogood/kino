@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '마감 기간 확인'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_GET_MARV_CLOSING 
as  select from marv
{
  key bukrs,
  CONCAT(lfgja,lfmon) as PERIOD

}

union all

select from marv
{
  key bukrs,  
  CONCAT(vmgja,vmmon) as PERIOD
} where xruem = 'X'
