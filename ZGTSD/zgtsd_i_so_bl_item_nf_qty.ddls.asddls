@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '[GT] 판매오더 Item 및 빌링문서 비철 수량'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZGTSD_I_SO_BL_ITEM_NF_QTY
  as select from vbap as a

    inner join      ZGTSD_I_VALID_BILLING as _ValidBill on  a.vbeln = _ValidBill.vbeln_so
                                                        and a.posnr = _ValidBill.posnr_so

//  left outer join /nfm/torderpos        as cu         on  a.vbeln = cu.belnr
//                                                      and a.posnr = cu.posnr
//                                                      and cu.nes  = 'CU'
//
//  left outer join /nfm/torderpos        as al         on  a.vbeln = al.belnr
//                                                      and a.posnr = al.posnr
//                                                      and al.nes  = 'AL'
//
//  left outer join /nfm/torderpos        as fi         on  a.vbeln = fi.belnr
//                                                      and a.posnr = fi.posnr
//                                                      and fi.nes  = 'FI'
                                                        
    left outer join /nfm/tkgw             as cu         on  a.matnr = cu.matnr
                                                        and a.werks = cu.werks
                                                        and cu.nes  = 'CU'                        

    left outer join /nfm/tkgw             as al         on  a.matnr = al.matnr
                                                        and a.werks = al.werks
                                                        and al.nes  = 'AL'
                                                        
    left outer join /nfm/tkgw             as fi         on  a.matnr = fi.matnr
                                                        and a.werks = fi.werks
                                                        and fi.nes  = 'FI'

{
  -- =======================================================================
  -- [1] Key Information (키 정보)
  -- =======================================================================
  key a.vbeln,                                                                  -- 판매오더 번호
  key cast( a.posnr             as posnr_va preserving type )        as posnr,  -- 판매오더 품목
  key cast( _ValidBill.vbeln_bl as vbeln_vf preserving type )        as bl_vbeln,-- 청구문서 번호
  key cast( _ValidBill.posnr_bl as posnr_vf preserving type )        as bl_posnr,-- 청구문서 품목

  -- =======================================================================
  -- [2] Material & Quantities (자재, 주문 및 청구 수량 정보)
  -- =======================================================================
      a.matnr,                                                                  -- 자재 번호
      
      a.vrkme,                                                                  -- 판매 단위
      @Semantics.quantity.unitOfMeasure: 'vrkme'
      a.kwmeng,                                                                 -- 주문 수량
      
      @Semantics.quantity.unitOfMeasure: 'vrkme'
      _ValidBill.fkimg,                                                         -- 청구 수량
      
      a.umvkz,                                                                  -- 판매수량 분자 환산계수
      a.umvkn,                                                                  -- 판매수량 분모 환산계수

  -- =======================================================================
  -- [3] Copper (구리 특성값 및 수량)
  -- =======================================================================
      cast( cu.nes as zgtenf_key_cu preserving type )                as nes_cu, -- 비철 식별키: CU
      
      cu.bme                                                         as bme_cu, -- 구리 기준 단위
      
//    cu.vge                                                         as vge_cu, -- 구리 기준 수량
      @Semantics.quantity.unitOfMeasure: 'vrkme'      
      cu.kgu                                                         as vge_cu, -- 구리 기준 수량
      
      @Semantics.quantity.unitOfMeasure: 'bme_cu'
//    cu.vgw                                                         as vgw_cu, -- 기준 단위당 구리 중량
      cu.kgw                                                         as vgw_cu, -- 기준 단위당 구리 중량
      
      cast( cu.bme as zgtenf_cu_uom preserving type )                as cu_unit,-- 비철 수량 단위: CU

      @Semantics.quantity.unitOfMeasure: 'cu_unit'
      cast( 
        cast( 
//        case when cu.vge is not null and cu.vge <> 0
          case when cu.kgu is not null and cu.kgu <> 0
               then division( 
                      ( 
//                      cast( cu.vgw as abap.dec(15,4) ) * 
                        cast( cu.kgw as abap.dec(15,4) ) *
                        division( cast( ( a.kwmeng * a.umvkz ) as abap.dec(15,4) ), 
                                  a.umvkn, 
                                  4 ) 
                      ), 
//                    cu.vge, 
                      cast( cu.kgu as abap.dec(15,4) ), 
                      4 
                    )
               else cast( 0 as abap.dec(15,4) ) 
          end as abap.quan(15,4) 
        ) as zgtenf_so_cu preserving type 
      )                                                              as so_cu,  -- SO 기준 구리 수량

      @Semantics.quantity.unitOfMeasure: 'cu_unit'
      cast( 
        cast( 
//        case when cu.vge is not null and cu.vge <> 0
          case when cu.kgu is not null and cu.kgu <> 0
               then division( 
                      ( 
//                      cast( cu.vgw as abap.dec(15,4) ) * 
                        cast( cu.kgw as abap.dec(15,4) ) *
                        division( cast( ( _ValidBill.fkimg * _ValidBill.umvkz ) as abap.dec(15,4) ), 
                                  _ValidBill.umvkn, 
                                  4 ) 
                      ), 
//                    cu.vge, 
                      cast( cu.kgu as abap.dec(15,4) ),                      
                      4 
                    )
               else cast( 0 as abap.dec(15,4) ) 
          end as abap.quan(15,4) 
        ) as zgtenf_bl_cu preserving type 
      )                                                              as bl_cu,  -- 청구 기준 구리 수량

  -- =======================================================================
  -- [4] Aluminium (알루미늄 특성값 및 수량)
  -- =======================================================================
      cast( al.nes as zgtenf_key_al preserving type )                as nes_al, -- 비철 식별키: AL
      
      al.bme                                                         as bme_al, -- 알루미늄 기준 단위
      
//    al.vge                                                         as vge_al, -- 알루미늄 기준 수량
      @Semantics.quantity.unitOfMeasure: 'vrkme'
      al.kgu                                                         as vge_al, -- 알루미늄 기준 수량
      
      @Semantics.quantity.unitOfMeasure: 'bme_al'
//    al.vgw                                                         as vgw_al, -- 기준 단위당 알루미늄 중량
      al.kgw                                                         as vgw_al, -- 기준 단위당 알루미늄 중량
      
      cast( al.bme as zgtenf_al_uom preserving type )                as al_unit,-- 비철 수량 단위: AL

      @Semantics.quantity.unitOfMeasure: 'al_unit'
      cast( 
        cast( 
//        case when al.vge is not null and al.vge <> 0
          case when al.kgu is not null and al.kgu <> 0
               then division( 
                      ( 
//                      cast( al.vgw as abap.dec(15,4) ) * 
                        cast( al.kgw as abap.dec(15,4) ) * 
                        division( cast( ( a.kwmeng * a.umvkz ) as abap.dec(15,4) ), 
                                  a.umvkn, 
                                  4 ) 
                      ), 
//                    al.vge, 
                      cast( al.kgu as abap.dec(15,4) ),
                      4 
                    )
               else cast( 0 as abap.dec(15,4) ) 
          end as abap.quan(15,4) 
        ) as zgtenf_so_al preserving type 
      )                                                              as so_al,  -- SO 기준 알루미늄 수량

      @Semantics.quantity.unitOfMeasure: 'al_unit'
      cast( 
        cast( 
//        case when al.vge is not null and al.vge <> 0
          case when al.kgu is not null and al.kgu <> 0
               then division( 
                      ( 
//                      cast( al.vgw as abap.dec(15,4) ) * 
                        cast( al.kgw as abap.dec(15,4) ) *
                        division( cast( ( _ValidBill.fkimg * _ValidBill.umvkz ) as abap.dec(15,4) ), 
                                  _ValidBill.umvkn, 
                                  4 ) 
                      ), 
//                    al.vge, 
                      cast( al.kgu as abap.dec(15,4) ),
                      4 
                    )
               else cast( 0 as abap.dec(15,4) ) 
          end as abap.quan(15,4) 
        ) as zgtenf_bl_al preserving type 
      )                                                              as bl_al,  -- 청구 기준 알루미늄 수량

  -- =======================================================================
  -- [5] Fiber (광섬유 특성값 및 수량)
  -- =======================================================================
      cast( fi.nes as zgtenf_key_fi preserving type )                as nes_fi, -- 비철 식별키: FI
      
      fi.bme                                                         as bme_fi, -- 광섬유 기준 단위
      
//    fi.vge                                                         as vge_fi, -- 광섬유 기준 수량
      @Semantics.quantity.unitOfMeasure: 'vrkme'
      fi.kgu                                                         as vge_fi, -- 광섬유 기준 수량
      
      @Semantics.quantity.unitOfMeasure: 'bme_fi'
//    fi.vgw                                                         as vgw_fi, -- 기준 단위당 광섬유 중량
      fi.kgw                                                         as vgw_fi, -- 기준 단위당 광섬유 중량
      
      cast( fi.bme as zgtenf_fi_uom preserving type )                as fi_unit,-- 비철 수량 단위: FI

      @Semantics.quantity.unitOfMeasure: 'fi_unit'
      cast( 
        cast( 
//        case when fi.vge is not null and fi.vge <> 0
          case when fi.kgu is not null and fi.kgu <> 0
               then division( 
                      ( 
//                      cast( fi.vgw as abap.dec(15,4) ) * 
                        cast( fi.kgw as abap.dec(15,4) ) *
                        division( cast( ( a.kwmeng * a.umvkz ) as abap.dec(15,4) ), 
                                  a.umvkn, 
                                  4 ) 
                      ), 
//                    fi.vge, 
                      cast( fi.kgu as abap.dec(15,4) ),
                      4 
                    )
               else cast( 0 as abap.dec(15,4) ) 
          end as abap.quan(15,4) 
        ) as zgtenf_so_fi preserving type 
      )                                                              as so_fi,  -- SO 기준 광섬유 수량

      @Semantics.quantity.unitOfMeasure: 'fi_unit'
      cast( 
        cast( 
//        case when fi.vge is not null and fi.vge <> 0
          case when fi.kgu is not null and fi.kgu <> 0
               then division( 
                      ( 
//                      cast( fi.vgw as abap.dec(15,4) ) * 
                        cast( fi.kgw as abap.dec(15,4) ) *
                        division( cast( ( _ValidBill.fkimg * _ValidBill.umvkz ) as abap.dec(15,4) ), 
                                  _ValidBill.umvkn, 
                                  4 ) 
                      ), 
//                    fi.vge, 
                      cast( fi.kgu as abap.dec(15,4) ),
                      4 
                    )
               else cast( 0 as abap.dec(15,4) ) 
          end as abap.quan(15,4) 
        ) as zgtenf_bl_fi preserving type 
      )                                                              as bl_fi   -- 청구 기준 광섬유 수량
}
where
  a.abgru is initial
