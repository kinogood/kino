@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '[GT] 판매오더 Item 및 납품문서 비철 수량'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZGTSD_I_SO_ITEM_NF_QTY
  as select from ZGTSD_I_SO_ITEM_NF_QTY_BASE as _Base
//    inner join   ZGTSD_CV_GET_VCOFSO         as _Char on  _Base.vbeln = _Char.vbeln
//                                                      and _Base.posnr = _Char.posnr
//
//    inner join   mara                        as _Mast on _Base.matnr = _Mast.matnr
{
  -- =======================================================================
  -- [1] Key Information (키 정보)
  -- =======================================================================
  key _Base.vbeln,                                                              -- 판매오더 번호
  key _Base.posnr,                                                              -- 판매오더 품목
  key _Base.do_vbeln,                                                           -- 납품문서 번호
  key _Base.do_posnr,                                                           -- 납품문서 품목 (메인, 하위 뷰에서 CASE 연산됨)

  -- =======================================================================
  -- [2] Organizational & Material Data (조직 및 자재 정보)
  -- =======================================================================
      _Base.auart,                                                              -- 판매오더 유형
      _Base.vkorg,                                                              -- 영업 조직
      _Base.vtweg,                                                              -- 유통 경로
      _Base.vkbur,                                                              -- 영업소
      _Base.vkgrp,                                                              -- 영업그룹
      
      _Base.matnr,                                                              -- 자재 번호
      _Base.spart,                                                              -- 헤더 제품군
      _Base.item_spart,                                                         -- 품목 제품군

  -- =======================================================================
  -- [3] Quantities & Units (수량 및 단위 정보)
  -- =======================================================================
      _Base.vrkme,                                                              -- 판매 단위
      @Semantics.quantity.unitOfMeasure: 'vrkme'
      _Base.kwmeng,                                                             -- 주문 수량

      _Base.do_unit,                                                            -- 납품 단위
      @Semantics.quantity.unitOfMeasure: 'do_unit'
      sum( _Base.lfimg )                                        as lfimg,       -- 납품 수량 합계

  -- =======================================================================
  -- [4] Copper (구리 특성값 및 수량)
  -- =======================================================================
      cast( _Base.nes_cu as zgtenf_key_cu preserving type )     as nes_cu,      -- 비철 식별키: CU
      _Base.bme_cu,                                                             -- 구리 기준 단위
      @Semantics.quantity.unitOfMeasure: 'vrkme'
      _Base.vge_cu,                                                             -- 구리 기준 수량
      
      @Semantics.quantity.unitOfMeasure: 'bme_cu'
      _Base.vgw_cu,                                                             -- 기준 단위당 구리 중량
      
      cast( _Base.bme_cu as zgtenf_cu_uom preserving type )     as cu_unit,     -- 비철 수량 단위: CU

      @Semantics.quantity.unitOfMeasure: 'cu_unit'
      cast( 
        max( 
          cast( 
            case when _Base.vge_cu is not null and _Base.vge_cu <> 0
                 then division( 
                        ( cast( _Base.vgw_cu as abap.dec(15,4) ) * 
                          division( cast( ( _Base.kwmeng * _Base.umvkz ) as abap.dec(15,4) ), 
                                    _Base.umvkn, 
                                    4 ) 
                        ), 
                        cast( _Base.vge_cu as abap.dec(15,4) ), 
                        4 
                      )
                 else cast( 0 as abap.dec(15,4) ) 
            end as abap.quan(15,4) 
          ) 
        ) as zgtenf_so_cu preserving type 
      )                                                         as so_cu,       -- SO 기준 구리 수량 (MAX 처리)

      @Semantics.quantity.unitOfMeasure: 'cu_unit'
      cast( 
        sum( 
          cast( 
            case when _Base.vge_cu is not null and _Base.vge_cu <> 0 and _Base.lfimg > 0
                 then division( 
                        ( cast( _Base.vgw_cu as abap.dec(15,4) ) * 
                          division( cast( ( _Base.lfimg * _Base.do_umvkz ) as abap.dec(15,4) ), 
                                    _Base.do_umvkn, 
                                    4 ) 
                        ), 
                        cast( _Base.vge_cu as abap.dec(15,4) ), 
                        4 
                      )
                 else cast( 0 as abap.dec(15,4) ) 
            end as abap.quan(15,4) 
          ) 
        ) as zgtenf_do_cu preserving type 
      )                                                         as do_cu,       -- DO 기준 구리 수량 합계

  -- =======================================================================
  -- [5] Aluminium (알루미늄 특성값 및 수량)
  -- =======================================================================
      cast( _Base.nes_al as zgtenf_key_al preserving type )     as nes_al,      -- 비철 식별키: AL
      _Base.bme_al,                                                             -- 알루미늄 기준 단위
      @Semantics.quantity.unitOfMeasure: 'vrkme'      
      _Base.vge_al,                                                             -- 알루미늄 기준 수량
      
      @Semantics.quantity.unitOfMeasure: 'bme_al'
      _Base.vgw_al,                                                             -- 기준 단위당 알루미늄 중량
      
      cast( _Base.bme_al as zgtenf_al_uom preserving type )     as al_unit,     -- 비철 수량 단위: AL

      @Semantics.quantity.unitOfMeasure: 'al_unit'
      cast( 
        max( 
          cast( 
            case when _Base.vge_al is not null and _Base.vge_al <> 0
                 then division( 
                        ( cast( _Base.vgw_al as abap.dec(15,4) ) * 
                          division( cast( ( _Base.kwmeng * _Base.umvkz ) as abap.dec(15,4) ), 
                                    _Base.umvkn, 
                                    4 ) 
                        ), 
                        cast( _Base.vge_al as abap.dec(15,4) ), 
                        4 
                      )
                 else cast( 0 as abap.dec(15,4) ) 
            end as abap.quan(15,4) 
          ) 
        ) as zgtenf_so_al preserving type 
      )                                                         as so_al,       -- SO 기준 알루미늄 수량 (MAX 처리)

      @Semantics.quantity.unitOfMeasure: 'al_unit'
      cast( 
        sum( 
          cast( 
            case when _Base.vge_al is not null and _Base.vge_al <> 0 and _Base.lfimg > 0
                 then division( 
                        ( cast( _Base.vgw_al as abap.dec(15,4) ) * 
                          division( cast( ( _Base.lfimg * _Base.do_umvkz ) as abap.dec(15,4) ), 
                                    _Base.do_umvkn, 
                                    4 ) 
                        ), 
                        cast( _Base.vge_al as abap.dec(15,4) ), 
                        4 
                      )
                 else cast( 0 as abap.dec(15,4) ) 
            end as abap.quan(15,4) 
          ) 
        ) as zgtenf_do_al preserving type 
      )                                                         as do_al,       -- DO 기준 알루미늄 수량 합계

  -- =======================================================================
  -- [6] Fiber (광섬유 특성값 및 수량)
  -- =======================================================================
      cast( _Base.nes_fi as zgtenf_key_fi preserving type )     as nes_fi,      -- 비철 식별키: FI
      _Base.bme_fi,                                                             -- 광섬유 기준 단위
      @Semantics.quantity.unitOfMeasure: 'vrkme'
      _Base.vge_fi,                                                             -- 광섬유 기준 수량
      
      @Semantics.quantity.unitOfMeasure: 'bme_fi'
      _Base.vgw_fi,                                                             -- 기준 단위당 광섬유 중량
      
      cast( _Base.bme_fi as zgtenf_fi_uom preserving type )     as fi_unit,     -- 비철 수량 단위: FI

      @Semantics.quantity.unitOfMeasure: 'fi_unit'
      cast( 
        max( 
          cast( 
            case when _Base.vge_fi is not null and _Base.vge_fi <> 0
                 then division( 
                        ( cast( _Base.vgw_fi as abap.dec(15,4) ) * 
                          division( cast( ( _Base.kwmeng * _Base.umvkz ) as abap.dec(15,4) ), 
                                    _Base.umvkn, 
                                    4 ) 
                        ), 
                        cast( _Base.vge_fi as abap.dec(15,4) ), 
                        4 
                      )
                 else cast( 0 as abap.dec(15,4) ) 
            end as abap.quan(15,4) 
          ) 
        ) as zgtenf_so_fi preserving type 
      )                                                         as so_fi,       -- SO 기준 광섬유 수량 (MAX 처리)

      @Semantics.quantity.unitOfMeasure: 'fi_unit'
      cast( 
        sum( 
          cast( 
            case when _Base.vge_fi is not null and _Base.vge_fi <> 0 and _Base.lfimg > 0
                 then division( 
                        ( cast( _Base.vgw_fi as abap.dec(15,4) ) * 
                          division( cast( ( _Base.lfimg * _Base.do_umvkz ) as abap.dec(15,4) ), 
                                    _Base.do_umvkn, 
                                    4 ) 
                        ), 
                        cast( _Base.vge_fi as abap.dec(15,4) ), 
                        4 
                      )
                 else cast( 0 as abap.dec(15,4) ) 
            end as abap.quan(15,4) 
          ) 
        ) as zgtenf_do_fi preserving type 
      )                                                         as do_fi        -- DO 기준 광섬유 수량 합계
}
group by
  _Base.vbeln,
  _Base.posnr,
  _Base.do_vbeln,
  _Base.do_posnr,
  _Base.auart,
  _Base.vkorg,
  _Base.vtweg,
  _Base.vkbur,
  _Base.vkgrp,
  _Base.matnr,
  _Base.spart,
  _Base.item_spart,
  _Base.vrkme,
  _Base.kwmeng,
  _Base.do_unit,
  _Base.nes_cu,
  _Base.bme_cu,
  _Base.vge_cu,
  _Base.vgw_cu,
  _Base.nes_al,
  _Base.bme_al,
  _Base.vge_al,
  _Base.vgw_al,
  _Base.nes_fi,
  _Base.bme_fi,
  _Base.vge_fi,
  _Base.vgw_fi
