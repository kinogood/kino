@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '[GT] 판매오더 기준 구매 입고 상태'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZGTSD_CV_SO_PO_STATUS
  as select from    ZGTSD_CV_SUM_SO_PO_QTY   as _PoQty
    left outer join ZGTSD_CV_SUM_SO_PO_GRQTY as _GrQty on  _PoQty.vbeln = _GrQty.vbeln
                                                       and _PoQty.posnr = _GrQty.posnr
                                                       and _PoQty.matnr = _GrQty.matnr
{
  key _PoQty.vbeln,
  key _PoQty.posnr,
      
      _PoQty.matnr,
      @Semantics.quantity.unitOfMeasure: 'meins'
      _PoQty.po_qty,
      _PoQty.meins,
      @Semantics.quantity.unitOfMeasure: 'gr_meins'
      coalesce(_GrQty.gr_qty,cast(0 as abap.quan(13,3))) as gr_qty, 
      _GrQty.GR_MEINS

}
