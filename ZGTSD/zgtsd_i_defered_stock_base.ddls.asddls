@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '[GT] 가온 적송 재고 정보(Base)'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZGTSD_I_DEFERED_STOCK_BASE
  as select from           nsdm_e_mska         as _Estock
    inner join             vbap                as _Item   on  _Estock.vbeln = _Item.vbeln
                                                          and _Estock.posnr = _Item.posnr
    inner join             vbak                as _Header on _Item.vbeln = _Header.vbeln
    left outer to one join ZGTSD_CV_GET_VCOFSO as _Char   on  _Item.vbeln = _Char.vbeln
                                                          and _Item.posnr = _Char.posnr
    left outer to one join mch1                as _Batch  on  _Estock.charg = _Batch.charg
                                                          and _Estock.matnr = _Batch.matnr
{
  key _Estock.matnr,
  key _Estock.werks,
  key _Estock.lgort,
  key _Estock.charg,
  key _Estock.sobkz,
  key _Estock.vbeln,
  key _Estock.posnr,

      cast(_Header.zpjno as zpjno preserving type )        as zpjno,
      _Header.vkbur,
      _Header.vkgrp,
      _Header.bstnk,
      _Item.kunnr_ana                                      as kunag,
      _Char.COLOR,
      _Char.SPECNO,
      _Item.arktx,
      @Semantics.quantity.unitOfMeasure: 'vrkme'
      _Char.LENGTH,

      cast(
          cast(
              case when _Batch.xpcbt = 'X' then 1
                   else case when _Char.LENGTH is not null and _Char.LENGTH <> 0
                             then division( cast(_Estock.kalab as abap.dec(13,3)),
                                            cast(_Char.LENGTH as abap.dec(13,3)),3)
                             else 0
                        end
               end
          as int4)
      as zgtewecnt preserving type )                       as factor,

      _Item.vrkme,
      @Semantics.quantity.unitOfMeasure: 'vrkme'
      cast(_Estock.kalab as labst preserving type )        as kalab,

      @Semantics.amount.currencyCode: 'waerk'
      _Item.netpr,
      @Semantics.amount.currencyCode: 'waerk'
      _Item.netwr,
      _Item.waerk,
      _Estock.ersda,
      dats_days_between(_Estock.ersda, $session.user_date) as dfdays
}
where
      _Estock.lgort like '%99'
  and _Estock.kalab >    0 
