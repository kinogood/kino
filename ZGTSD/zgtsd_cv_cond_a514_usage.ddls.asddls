@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '[GT] 영업조직/유통경로/제품군/고객/자재/변형키 (A514) 사용여부'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTSD_CV_COND_A514_USAGE 
with parameters
    @Consumption.hidden: true
    @Environment.systemField: #SYSTEM_DATE
    p_spart : spart,
    p_date  : abap.dats
    
as 

select from ZGTSD_IV_COND_A514 (p_spart : $parameters.p_spart,
                                p_date  : $parameters.p_date ) as A
{
  key A.vkorg,
  key A.vtweg,
  key A.spart,
  key A.kunnr,
  key A.matnr,
      A.maktx,
      A.varcond,
      A.kappl,
      A.kschl,
      A.knumh,
      @Semantics.amount.currencyCode : 'konwa'
      A.kbetr,
      A.konwa,
      A.kpein,
      A.kmein,
      A.datab,
      A.datbi,

      case
         when A._PricingExist.item_count is null
           or A._PricingExist.item_count = 0
         then 'N'
         else 'Y'
      end as YN
}
