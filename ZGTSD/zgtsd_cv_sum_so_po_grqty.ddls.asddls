@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '[GT] 판매오더 기준 구매 입고량 합계'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZGTSD_CV_SUM_SO_PO_GRQTY
  as select from ZGTMM_CV_GET_GRLIST_SUM as _Base
    inner join   ekkn                    as _Acct   on  _Base.ebeln = _Acct.ebeln
                                                    and _Base.ebelp = _Acct.ebelp
                                                    and _Acct.zekkn = '01'
                                                    and _Acct.vbeln is not initial
    inner join   ekpo                    as _Po     on  _Acct.ebeln   = _Po.ebeln
                                                    and _Acct.ebelp   = _Po.ebelp
    inner join   vbap                    as _SoItem on  _Acct.vbeln   = _SoItem.vbeln
                                                    and _Acct.vbelp   = _SoItem.posnr
                                                    and _Po.matnr     = _SoItem.matnr
                                                    and _SoItem.vrkme = _Base.GR_MEINS
{
  key cast(_Acct.vbeln as vbeln_va preserving type)  as vbeln,
  key cast(_Acct.vbelp as posnr_va preserving type ) as posnr,
      
      _Po.matnr, 
      @Semantics.quantity.unitOfMeasure: 'gr_meins'
      sum(_Base.MENGE)                               as gr_qty,
      _Base.GR_MEINS
}
group by
  _Acct.vbeln,
  _Acct.vbelp,
  _Po.matnr,
  _Base.GR_MEINS 
