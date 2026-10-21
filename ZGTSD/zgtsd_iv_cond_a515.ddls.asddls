@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '[GT] 영업조직/유통경로/제품군/고객/자재 (A515) 가격'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTSD_IV_COND_A515
with parameters
    @Environment.systemField: #SYSTEM_DATE
    p_spart : spart,
    p_date  : abap.dats
  as select from a515 as A inner join konp as K
                               on A.knumh = K.knumh
                              and A.kappl = K.kappl
                              and A.kschl = K.kschl
                              and K.loevm_ko <> 'X'
                    association [1..1] to I_ProductText as _Text
                                                        on  A.matnr = _Text.Product
                                                       and _Text.Language = $session.system_language      
                    association [0..1] to ZGTSD_IV_PRICINGEXIST as _PricingExist
                                                                on A.knumh = _PricingExist.knumh
                                          
{
  key A.vkorg,
  key A.vtweg,
  key A.spart,
  key A.kunnr,
  key A.matnr,

      _Text.ProductName as maktx,

      A.kappl,
      A.kschl,
      A.knumh,
      @Semantics.amount.currencyCode: 'konwa'
      K.kbetr,
      K.konwa,
      K.kpein,
      K.kmein,
      A.datab,
      A.datbi,

      _PricingExist
}
where
      A.kappl = 'V'
  and A.spart = $parameters.p_spart
  and A.datab <= $parameters.p_date
  and A.datbi >= $parameters.p_date
