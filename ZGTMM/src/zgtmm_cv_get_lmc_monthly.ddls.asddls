@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '월별 비철 금속가 조회(원화 환산)'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_GET_LMC_MONTHLY 
as select from zgtmmt1100 as A inner join ZGTMM_CV_GET_LME_MONTHLY as S1 on  A.nes = S1.METAL and A.mjahr = S1.MJAHR
{
  key A.bukrs,
  key A.mjahr,
  key A.nes,
      @Semantics.amount.currencyCode: 'waers'     
      A.premium,
      A.waers,
      A.crate,
      @Semantics.amount.currencyCode: 'Mwaers'     
      A.mcost,
      A.per,
      A.munit,      
      A.mwaers,
      A.kurst,
      S1.METAL,
      S1.PERIOD,
      @Semantics.amount.currencyCode: 'CURRENCY'   
      S1.price,
      S1.CURRENCY,
 //     @Semantics.quantity.unitOfMeasure: 'meins'    
      S1.PER as LMEPER,
      S1.MEINS
} 
