@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '[GT] 판매오더 Item 적송 수량'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZGTSD_I_SO_ITEM_DFRD_QTY
  as select from    vbap                      as _Item
  //    inner join      vbak                  as _Hdr     on  _Item.vbeln = _Hdr.vbeln
  //                                                      and _Item.abgru is initial

  //    inner join      lips                      as _DlvItem on  _Item.vbeln = _DlvItem.vgbel
  //                                                          and _Item.posnr = _DlvItem.vgpos
  //
  //    inner join      likp                      as _DlvHdr  on  _DlvItem.vbeln = _DlvHdr.vbeln
  //                                                          and _DlvHdr.lfart  = 'ZLF3'

    inner join      ZGTSD_I_DELIVERY_BASE_SUM as _Dlv     on  _Item.vbeln = _Dlv.vbeln_so
                                                          and _Item.posnr = _Dlv.posnr_so
                                                          and _Dlv.lfart  = 'ZLF3'

    left outer join ZGTSD_I_VALID_BILLING     as _ValidBl on  _Dlv.vbeln = _ValidBl.vbeln_do
                                                          and _Dlv.posnr = _ValidBl.posnr_do
                                                          and _Dlv.fksta = 'C'
{
  key _Item.vbeln,
  key cast(_Item.posnr as posnr_va preserving type )  as posnr, 

      _Item.matnr,
      _Item.arktx,
      @Semantics.quantity.unitOfMeasure: 'vrkme'
      _Item.kwmeng,
      _Item.vrkme,

      @Semantics.quantity.unitOfMeasure: 'vrkme'

      sum( case when _Dlv.Lfimg > 0
                then _Dlv.Lfimg
                else cast(0 as abap.quan(13,3)) end ) as dfimg_total,

      @Semantics.quantity.unitOfMeasure: 'vrkme'
      cast(
          sum( case when _Dlv.fksta <> 'C'
                    then _Dlv.Lfimg
                    else cast(0 as abap.quan(13,3)) end )
      as zgtedfimga preserving type )                 as dfimg_a,

      @Semantics.quantity.unitOfMeasure: 'vrkme'
      cast(
      sum( case when _Dlv.fksta = 'C'
                then _ValidBl.fkimg
                else cast(0 as abap.quan(13,3)) end )
      as zgtedfimga preserving type )                 as dfimg_c

}
where
  _Item.abgru is initial
group by
  _Item.vbeln,
  _Item.posnr,
  _Item.matnr,
  _Item.arktx,
  _Item.kwmeng,
  _Item.vrkme
