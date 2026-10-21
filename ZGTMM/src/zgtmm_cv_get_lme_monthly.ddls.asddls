@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '월별 비철 금속가 조회'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_GET_LME_MONTHLY 
as 
/*select from oicqp
{
  key LEFT(quotno,2) as METAL,
  key LEFT(quotdate,4) as MJAHR,
  key LEFT(quotdate,6) as PERIOD,
  key right(quotdate,2) as day2digit,
  @Semantics.amount.currencyCode: 'CURRENCY'   
  price,
  defcurr as CURRENCY,
//  @Semantics.quantity.unitOfMeasure: 'meins'    
  defper as PER,
  defuom as MEINS
    
} where quosrc = 'NF' and quotyp = 'M1LME' and price > 0

UNION*/

select from znft0002
{
  key LEFT(nfkey,2) as METAL,
  key LEFT(inmon,4) as MJAHR,
  key inmon as PERIOD,
  @Semantics.amount.currencyCode: 'CURRENCY'   
  o_cash as price,
  o_cash_waers as CURRENCY,
//  @Semantics.quantity.unitOfMeasure: 'meins'    
  cast(1000 as oic_defper) as PER,
  cast('KG' as oic_defuom) as MEINS
    
} where nfkey = 'AL1' or nfkey = 'CU1' or nfkey = 'PB1'
