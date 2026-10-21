@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '[GT] 보관입고 완료 납품 수량 합계'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZGTSD_I_ZCS_MVT_901_QTY
  as select from lips
{
  key vgbel,
  key vgpos,

      -- ZMIGO가 'X'인 경우에만 수량을 합산
      @Semantics.quantity.unitOfMeasure: 'vrkme'
      sum( cast( case when zmigo = 'X' then lfimg else 0 end as abap.quan(15,3) ) ) as migo_x_qty,

      vrkme
}
where
      lfimg > 0
  and vgbel is not initial
group by
  vgbel,
  vgpos,
  vrkme 
