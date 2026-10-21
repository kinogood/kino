@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '[GT] ZCS 오더 대상 복사 수량 합계'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZGTSD_I_ZCS_ORDER_QTY
  as select from vbap
{
  key vgbel,
  key vgpos,

      -- 원본 오더에서 ZCS로 복사된 수량 총합
      @Semantics.quantity.unitOfMeasure: 'vrkme'
      sum( kwmeng ) as zcs_qty,

      vrkme
}
where
      auart_ana = 'ZCS'
  and vgbel     is not initial
group by
  vgbel,
  vgpos, 
  vrkme
