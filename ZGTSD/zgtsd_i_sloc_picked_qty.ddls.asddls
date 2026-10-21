@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '[GT] 저장위치별 피킹 수량 집계'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZGTSD_I_SLOC_PICKED_QTY
  as select from ZGTSD_I_BATCH_PICKED_QTY
{
      -- [1] 키 정보
  key matnr,                               -- 자재번호
  key werks,                               -- 플랜트
  key lgort,                               -- 저장위치

      -- [2] 수량 및 단위
      @Semantics.quantity.unitOfMeasure: 'meins'
      sum(Total_Picked_qty) as picked_qty, -- Sloc별 피킹 총합
      meins                                -- 기본단위
}
group by
  matnr,
  werks,
  lgort,
  meins
