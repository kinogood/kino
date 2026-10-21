@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '[GT] 판매오더 Item 및 빌링문서 비철 수량 합계'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZGTSD_CV_SUM_SO_BL_ITEM_NF_QTY
  //as select from vbap
  //{key vbeln}
  as select from ZGTSD_I_SO_BL_ITEM_NF_QTY
{
  -- =======================================================================
  -- [1] Key Information (키 정보)
  -- =======================================================================
  key vbeln,                                                                    -- 판매오더 번호
  key posnr,                                                                    -- 판매오더 품목

  -- =======================================================================
  -- [2] Material & Quantities (자재, 주문 및 청구 수량 정보)
  -- =======================================================================
      matnr,                                                                    -- 자재 번호
      
      vrkme,                                                                    -- 판매 단위
      @Semantics.quantity.unitOfMeasure: 'vrkme'
      kwmeng,                                                                   -- 주문 수량
      
      @Semantics.quantity.unitOfMeasure: 'vrkme'
      cast( sum( fkimg ) as fkimg preserving type )                  as sum_fkimg,      -- 청구 수량 합계

  -- =======================================================================
  -- [3] Copper (구리 특성값 및 수량)
  -- =======================================================================
      cast( nes_cu as zgtenf_key_cu preserving type )                as nes_cu,         -- 비철 식별키: CU
      
      @Semantics.quantity.unitOfMeasure: 'cu_unit'
      cast( 
        cast( so_cu as abap.quan(15,4) ) 
        as zgtenf_so_cu preserving type 
      )                                                              as so_cu,          -- 오더 기준 비철 수량 (CU)
      
      @Semantics.quantity.unitOfMeasure: 'cu_unit'
      cast( 
        cast( sum( bl_cu ) as abap.quan(15,4) ) 
        as zgtenf_bl_cu preserving type 
      )                                                              as sum_bl_cu,      -- 청구 기준 비철 수량 (CU)
      
      cast( cu_unit as zgtenf_cu_uom preserving type )               as cu_unit,        -- 비철 수량 단위: CU

  -- =======================================================================
  -- [4] Aluminium (알루미늄 특성값 및 수량)
  -- =======================================================================
      cast( nes_al as zgtenf_key_al preserving type )                as nes_al,         -- 비철 식별키: AL
      
      @Semantics.quantity.unitOfMeasure: 'al_unit'
      cast( 
        cast( so_al as abap.quan(15,4) ) 
        as zgtenf_so_al preserving type 
      )                                                              as so_al,          -- 오더 기준 비철 수량 (AL)
      
      @Semantics.quantity.unitOfMeasure: 'al_unit'
      cast( 
        cast( sum( bl_al )  as abap.quan(15,4) ) 
        as zgtenf_bl_al preserving type 
      )                                                              as sum_bl_al,      -- 청구 기준 비철 수량 (AL)
      
      cast( al_unit as zgtenf_al_uom preserving type )               as al_unit,        -- 비철 수량 단위: AL

  -- =======================================================================
  -- [5] Fiber (광섬유 특성값 및 수량)
  -- =======================================================================
      cast( nes_fi as zgtenf_key_fi preserving type )                as nes_fi,         -- 비철 식별키: FI
      
      @Semantics.quantity.unitOfMeasure: 'fi_unit'
      cast( 
        cast( so_fi as abap.quan(15,4) ) 
        as zgtenf_so_fi preserving type 
      )                                                              as so_fi,          -- 오더 기준 비철 수량 (FI)
      
      @Semantics.quantity.unitOfMeasure: 'fi_unit'
      cast( 
        cast( sum( bl_fi ) as abap.quan(15,4) ) 
        as zgtenf_bl_fi preserving type 
      )                                                              as sum_bl_fi,      -- 청구 기준 비철 수량 (FI)
      
      cast( fi_unit as zgtenf_fi_uom preserving type )               as fi_unit         -- 비철 수량 단위: FI
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
