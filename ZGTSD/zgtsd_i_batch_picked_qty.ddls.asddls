@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '[GT] 배치별 피킹 수량 집계'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZGTSD_I_BATCH_PICKED_QTY
  as select from lips as _Dlv
//    inner join   vbfa as _Flow on  _Dlv.vbeln    = _Flow.vbelv
//                              and  _Dlv.posnr    = _Flow.posnv
//                              and  _Flow.vbtyp_n = 'Q' -- 피킹 문서
{
  key _Dlv.matnr,
  key _Dlv.werks,
  key _Dlv.lgort,
  key _Dlv.charg,

      @Semantics.quantity.unitOfMeasure: 'meins'
      sum( _Dlv.lfimg ) as Total_Picked_qty,
//      sum( _Flow.rfmng ) as Total_Picked_Qty,

      _Dlv.meins
}
where _Dlv.wbsta <> 'C'
  and _Dlv.kosta = 'C'
  and _Dlv.lfimg > 0
  and _Dlv.sobkz <> 'E'
//_Flow.rfmng > 0
//  and _Dlv.charg <> ''
//  and _Dlv.wbsta <> 'C'
group by
  _Dlv.matnr,
  _Dlv.werks,
  _Dlv.lgort,
  _Dlv.charg,
  _Dlv.meins 
