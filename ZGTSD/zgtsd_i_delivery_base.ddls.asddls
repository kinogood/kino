@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '[GT] Delivery Order Item(Batch라인 합산Base)'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZGTSD_I_DELIVERY_BASE
  as select from lips as _Item
    inner join   likp as _Header on _Item.vbeln = _Header.vbeln
{
  key _Item.vbeln,

      // 1. 원본 POSNR을 Key로 유지하여 LIPS 테이블과의 Key 정합성 확보 및 고유성 보장
  key cast(_Item.posnr as posnr_vl preserving type )              as original_posnr,

      cast(_Item.vgbel as vbeln_va preserving type )              as vbeln_so,
      cast(_Item.vgpos as posnr_va preserving type)               as posnr_so,
      
      _Header.wadat_ist,
      _Header.lfart,
      _Item.werks,
      _Item.lgort,
      _Header.vstel,
      // 2. Batch Split(9000xx)인 경우 Main Item(UECHA)으로 치환 (상위 View에서 합산 시 기준 Key로 사용)
      cast(case when _Item.uecha is null or _Item.uecha = '000000'
               then _Item.posnr
               else _Item.uecha end as posnr_vl preserving type ) as main_posnr,

      // (참고) 배치 분할 여부 플래그나 기타 필드 추가 가능
      _Item.uecha,
      cast(_Item.matnr as matnr preserving type )                 as matnr,
      @Semantics.quantity.unitOfMeasure: 'vrkme'
      _Item.lfimg,
      _Item.vrkme,
      _Item.wbsta,
      _Item.fksta 
}
