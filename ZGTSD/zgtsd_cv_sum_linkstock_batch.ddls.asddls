@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '[GT] 가온 Link 재고 배치 단위 합계'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZGTSD_CV_SUM_LINKSTOCK_BATCH
  as select from    ZGTSD_CV_LINKSTOCK_BATCH_BASE as _Base
//    left outer join ZGTSD_CV_SUM_MVT413_BATCH_QTY as _Qty413 on  _Base.matnr = _Qty413.matnr
//                                                             and _Base.werks = _Qty413.werks
//                                                             and _Base.lgort = _Qty413.lgort
//                                                             and _Base.charg = _Qty413.charg

{
  key _Base.matnr,
  key _Base.werks,
  key _Base.charg,
  key _Base.lgort,

      @Semantics.quantity.unitOfMeasure: 'vrkme'
//      cast( coalesce(_Base.linked_qty,0) - coalesce(_Qty413.targeted_qty,0) as abap.quan(13,3) 
//          ) as Linked_qty,
      cast( coalesce(_Base.linked_qty,0) as abap.quan(13,3) 
          ) as Linked_qty,

      _Base.vrkme
}
