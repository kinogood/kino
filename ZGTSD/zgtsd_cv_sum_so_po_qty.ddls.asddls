@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '[GT] 판매오더 기준 구매 발주량 합계'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZGTSD_CV_SUM_SO_PO_QTY
  as select from ZGTMM_CV_GET_PODATA_I as _PoItem
    inner join   vbap                  as _SoItem on  _PoItem.VBELN = _SoItem.vbeln
                                                  and _PoItem.posnr = _SoItem.posnr
                                                  and _PoItem.meins = _SoItem.vrkme
                                                  and _PoItem.matnr = _SoItem.matnr
{
  key cast(_PoItem.VBELN as vbeln_va preserving type)  as vbeln,
  key cast(_PoItem.posnr as posnr_va preserving type ) as posnr,
       
      _PoItem.matnr,
      @Semantics.quantity.unitOfMeasure: 'meins'
      sum(_PoItem.menge)                               as po_qty,
      _PoItem.meins
}
where
      _PoItem.VBELN is not initial
  and _PoItem.loekz is initial

group by
  _PoItem.VBELN,
  _PoItem.posnr,
  _PoItem.matnr,
  _PoItem.meins 
