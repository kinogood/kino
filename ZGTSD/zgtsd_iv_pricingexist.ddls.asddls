@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '[GT] Pricing Element Existence by Condition Record'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTSD_IV_PRICINGEXIST  
    as select from I_PricingElement as PE
{
  key PE.ConditionRecord         as knumh,
      count( distinct PE.PricingDocument ) as item_count
}
group by PE.ConditionRecord
