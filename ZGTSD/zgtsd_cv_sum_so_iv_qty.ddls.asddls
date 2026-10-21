@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '[GT] 판매오더 Item 거래명세서 수량 집계'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZGTSD_CV_SUM_SO_IV_QTY
  as select from ZGTSD_I_VALID_INV_ITEM as _IvQty
    inner join   lips                   as _Dlv on  _IvQty.vbeln = _Dlv.vbeln
                                                and _IvQty.posnr = _Dlv.posnr
{
  key cast(_Dlv.vgbel as vbeln_va preserving type ) as vbeln,
  key cast(_Dlv.vgpos as posnr_va preserving type ) as posnr,

      _IvQty.iv_print_yn,
      @Semantics.quantity.unitOfMeasure: 'vrkme'
      sum(_IvQty.lfimg)                             as lfimg,
      _Dlv.vrkme

}
where
      _IvQty.lfimg       > 0
  and _IvQty.iv_print_yn = 'X'
  and _IvQty.iv_type = 'A01'
group by
  _Dlv.vgbel,
  _Dlv.vgpos,
  _IvQty.iv_print_yn,
  _Dlv.vrkme 
