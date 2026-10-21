@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '[GT] 판매오더 Item 기준 납품문서 비철수량 합계'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZGTSD_CV_SUM_SO_ITEM_NF_QTY
  as select from ZGTSD_I_SO_ITEM_NF_QTY
{
  key vbeln,
  key posnr,

      matnr,
      @Semantics.quantity.unitOfMeasure: 'vrkme'
      kwmeng,
      vrkme,
      @Semantics.quantity.unitOfMeasure: 'vrkme'
      cast(sum(lfimg) as lfimg preserving type )         as sum_lfimg,

      nes_cu,
      @Semantics.quantity.unitOfMeasure: 'cu_unit'
      so_cu, -- 오더 기준 비철 수량 (CU)
      @Semantics.quantity.unitOfMeasure: 'cu_unit'
      cast(sum(do_cu) as zgtenf_do_cu preserving type )  as sum_do_cu, -- 납품 기준 비철 수량 (CU)
      cu_unit, -- 비철 수량 단위: CU

      nes_al, -- 비철 식별키: AL
      @Semantics.quantity.unitOfMeasure: 'al_unit'
      so_al, -- 오더 기준 비철 수량 (AL)
      @Semantics.quantity.unitOfMeasure: 'al_unit'
      cast(sum(do_al)  as zgtenf_do_al preserving type ) as sum_do_al, -- 납품 기준 비철 수량 (AL)
      al_unit, -- 비철 수량 단위: AL

      nes_fi, -- 비철 식별키: FI
      @Semantics.quantity.unitOfMeasure: 'fi_unit'
      so_fi, -- 오더 기준 비철 수량 (FI)
      @Semantics.quantity.unitOfMeasure: 'fi_unit'
      cast(sum(do_fi) as zgtenf_do_fi preserving type )  as sum_do_fi, -- 납품 기준 비철 수량 (FI)
      fi_unit -- 비철 수량 단위: FI
}
group by
  vbeln,
  posnr,
  matnr,
  kwmeng,
  vrkme,
  nes_cu,
  so_cu,
  cu_unit,
  nes_al,
  so_al,
  al_unit,
  nes_fi,
  so_fi,
  fi_unit 
