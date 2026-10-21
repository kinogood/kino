@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '[GT] 판매오더 Item 보관입고 상태'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZGTSD_CV_SO_ITEM_MVT_901_STAT
  as select from    vbap                    as a
    inner join      ZGTSD_I_ZCS_ORDER_QTY   as b on  a.vbeln = b.vgbel
                                                 and a.posnr = b.vgpos
    left outer join ZGTSD_I_ZCS_MVT_901_QTY as c on  a.vbeln = c.vgbel
                                                 and a.posnr = c.vgpos
{
  key a.vbeln,
  key a.posnr,

      @Semantics.quantity.unitOfMeasure: 'vrkme'  
      b.zcs_qty,
      a.vrkme,

      @Semantics.quantity.unitOfMeasure: 'vrkme'
      cast( coalesce( c.migo_x_qty, 0 ) as abap.quan(15,3) ) as migo_x_qty,

      -- 수량 기반 보관입고 상태 결정 로직
      case
        when coalesce( c.migo_x_qty, 0 ) <= 0 then 'A'         -- MIGO 수량 없음 (미완료)
        when coalesce( c.migo_x_qty, 0 ) >= b.zcs_qty then 'C' -- MIGO 수량이 ZCS 타겟 수량과 같거나 큼 (완료)
        else 'B'                                               -- MIGO 수량이 0보다 크지만 ZCS 타겟보다 작음 (부분완료)
      end                                                    as kpsta
}
