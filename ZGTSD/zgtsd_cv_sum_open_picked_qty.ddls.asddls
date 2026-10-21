@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '[GT] G/I 미완료 납품문서 Picking 수량 합계'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZGTSD_CV_SUM_OPEN_PICKED_QTY 
    as select from ZGTSD_I_OPEN_PICKED_QTY as _Pick
{
    key _Pick.vbeln,
    key _Pick.posnr,
    key _Pick.matnr,
    key _Pick.werks,
//    key _Pick.lgort,
    
    @Semantics.quantity.unitOfMeasure: 'vrkme'
    sum(_Pick.picked_qty) as picked_qty,
    
    _Pick.vrkme
}
group by
_Pick.vbeln,
_Pick.posnr,
_Pick.matnr,
_Pick.werks,
//_Pick.lgort,
_Pick.vrkme
