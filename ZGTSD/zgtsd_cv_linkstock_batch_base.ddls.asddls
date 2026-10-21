@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '[GT] Link재고 Batch단위 집계 Base'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZGTSD_CV_LINKSTOCK_BATCH_BASE
  as select from ZGTSD_I_GET_SO_LINK_STOCK as _Lstock
    inner join   t006                      as _Mst    on _Lstock.vrkme = _Mst.msehi
    inner join   marc                      as _MstPlt on  _Lstock.matnr = _MstPlt.matnr
                                                      and _Lstock.werks = _MstPlt.werks
{
  key _Lstock.matnr,
  key _Lstock.werks,
  key _Lstock.lgort,
  key _Lstock.charg,

      @Semantics.quantity.unitOfMeasure: 'vrkme'
      cast(
              sum(
                case when _Mst.dimid = 'LENGTH' and (_MstPlt.dpcbt = 'A' or
                                                     _MstPlt.dpcbt = 'C')
                        then _Lstock.length * _Lstock.LStock
                     else _Lstock.LStock
                end
              )
      as abap.quan(13,3)                                                    ) as linked_qty,

      _Lstock.vrkme
}
where _Lstock.loekz is initial
group by
  _Lstock.matnr,
  _Lstock.werks,
  _Lstock.lgort,
  _Lstock.charg,
  _Lstock.vrkme
