@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '[GT] 가온 가용재고 조회 Base_MARD'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZGTSD_I_AVAILABLE_STOCK_MARD
  as select from    nsdm_e_mard                    as _Base

  -- 1. 자재 마스터 (INNER JOIN)
    inner join      marc                    as _Product on  _Base.matnr = _Product.matnr
                                                        and _Base.werks = _Product.werks

    inner join      mara                    as _Master  on _Base.matnr = _Master.matnr

    inner join      mvke                    as _Sales   on  _Base.matnr  = _Sales.matnr
                                                        and _Sales.vkorg = '6000'
                                                        and _Sales.vtweg = '10'

  -- 2. 저장위치 기준 피킹 수량 집계 뷰 (Helper JOIN)
    left outer join ZGTSD_I_SLOC_PICKED_QTY as _Pick    on  _Base.matnr = _Pick.matnr
                                                        and _Base.werks = _Pick.werks
                                                        and _Base.lgort = _Pick.lgort

  -- 3. 자재 내역 (Association - Cardinality [0..1] 필수)
  association [0..1] to makt as _ProductText on  $projection.matnr  = _ProductText.matnr
                                             and _ProductText.spras = $session.system_language
{
      -- [1] 키 정보
  key _Base.matnr,                                                             -- 자재번호
  key _Base.werks,                                                             -- 플랜트
  key _Base.lgort,                                                             -- 저장위치

      -- [2] 기준 정보
      _Master.meins,                                                           -- 기본단위
      _Product.xchpf,                                                          -- 배치관리 대상 여부
      _ProductText.maktx,                                                      -- 자재내역

      -- [3] 수량 정보
      @Semantics.quantity.unitOfMeasure: 'meins'
      _Base.labst                                              as Stock_Qty,   -- 저장위치 가용재고 (MARD 원본)

      @Semantics.quantity.unitOfMeasure: 'meins'
      cast( coalesce(_Pick.picked_qty, 0) as abap.quan(13,3) ) as picked_qty,  -- 피킹 수량 총합

      @Semantics.quantity.unitOfMeasure: 'meins'
      cast( _Base.labst - coalesce(_Pick.picked_qty, 0)
            as abap.quan(13,3) )                               as unpicked_qty -- 가용재고 (원본 - 피킹)
}
where
      _Base.labst    > 0
  and _Base.lvorm    is initial
  and _Product.xchpf is initial
