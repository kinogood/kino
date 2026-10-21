@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '[GT] 판매오더 Item 청구 수량 집계'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZGTSD_CV_SUM_SO_BILLING_QTY
  as select from vbrp as _Bl
    inner join   vbrk as _BlHdr on _Bl.vbeln = _BlHdr.vbeln
    inner join   vbap as _Item  on  _Bl.aubel = _Item.vbeln
                                and _Bl.aupos = _Item.posnr
{
  key _Item.vbeln,
  key cast(_Item.posnr as posnr_va preserving type ) as posnr,

      @Semantics.quantity.unitOfMeasure: 'vrkme'
      sum(_Bl.fkimg)                                 as fkimg,
      _Bl.vrkme
}
where
      _Bl.vbtyp_ana <> 'N'
  and _Bl.vbtyp_ana <> 'S'
  and _Bl.sfakn_ana is initial
  and _BlHdr.fksto  is initial

group by
  _Item.vbeln,
  _Item.posnr,
  _Bl.vrkme 
