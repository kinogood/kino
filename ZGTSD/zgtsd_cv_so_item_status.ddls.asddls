@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '[GT] 판매오더 품목 기준 상태 조회'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZGTSD_CV_SO_ITEM_STATUS
  as select from           vbap                          as _Item

    inner join             tvap                          as _Itcgry  on _Item.pstyv = _Itcgry.pstyv 

    left outer join        ZGTSD_I_DELIVERY_STATUS       as _dlv     on  _Item.vbeln = _dlv.vbeln
                                                                     and _Item.posnr = _dlv.posnr

    left outer join        ZGTSD_CV_GET_DLVREQ_DUE_LIGHT as _dlvrq   on  _Item.vbeln = _dlvrq.vbeln
                                                                     and _Item.posnr = _dlvrq.posnr

    left outer join        ZGTSD_CV_SO_ITEM_MVT_901_STAT as _Keep    on  _Item.vbeln = _Keep.vbeln
                                                                     and _Item.posnr = _Keep.posnr

    left outer join        ZGTSD_CV_SO_PO_STATUS         as _Po      on  _Item.vbeln = _Po.vbeln
                                                                     and _Item.posnr = _Po.posnr
                                                                     and _Item.matnr = _Po.matnr
                                                                     and _Item.vrkme = _Po.meins

    left outer join        ZGTSD_I_SO_ITEM_DFRD_QTY      as _DfQty   on  _Item.vbeln = _DfQty.vbeln
                                                                     and _Item.posnr = _DfQty.posnr

    left outer to one join ZGTSD_CV_VBEP_MAX             as _VbepMax on  _Item.vbeln = _VbepMax.vbeln
                                                                     and _Item.posnr = _VbepMax.posnr

    left outer to one join vbep                          as _Schl    on  _VbepMax.vbeln     = _Schl.vbeln
                                                                     and _VbepMax.posnr     = _Schl.posnr
                                                                     and _VbepMax.max_etenr = _Schl.etenr

    left outer to one join ZGTSD_I_OEM_IV_QTY            as _PivQty  on  _Item.vbeln = _PivQty.vbeln
                                                                     and _Item.posnr = _PivQty.posnr

    left outer to one join ZGTSD_CV_SUM_SO_IV_QTY        as _IvQty   on  _Item.vbeln = _IvQty.vbeln
                                                                     and _Item.posnr = _IvQty.posnr

    left outer to one join ZGTSD_CV_SUM_SO_OUT_QTY       as _OutQty  on  _Item.vbeln = _OutQty.vbeln
                                                                     and _Item.posnr = _OutQty.posnr

    left outer to one join ZGTSD_CV_SUM_SO_BILLING_QTY   as _BlQty   on  _Item.vbeln = _BlQty.vbeln
                                                                     and _Item.posnr = _BlQty.posnr

{
      -- ======================================================================
      -- Sales Order Key
      -- ======================================================================
  key _Item.vbeln,
  key cast(_Item.posnr as posnr_va preserving type ) as posnr,

      -- ======================================================================
      -- Organizational Info.
      -- ======================================================================
      _Item.vbtyp_ana                                as vbtyp,
      _Item.auart_ana                                as auart,
      _Item.vkorg_ana                                as vkorg,
      _Item.vtweg_ana                                as vtweg,
      _Item.spart_ana                                as spart,
      _Item.vkbur_ana                                as vkbur,
      _Item.vkgrp_ana                                as vkgrp,
      _Item.werks,

      -- Aggr 뷰로 넘겨줄 품목 범주 필드 추가
      _Item.pstyv,

      -- 거부 상태
      _Item.absta,

      -- ======================================================================
      -- 0. 출하요청 상태
      -- ======================================================================
      cast(
          case
            when _Schl.lfrel <> 'X' or _Schl.lfrel is null then ''
            when _dlvrq.vbeln is not null then
              case
                when _dlvrq.rmqty <= 0 then 'C' -- 출하요청 잔량 <= 0
                when _dlvrq.rmqty is null then 'A'
                when cast( _dlvrq.rmqty as abap.dec(15,3) ) = cast( coalesce (_dlvrq.FACTOR, _dlvrq.kwmeng) as abap.dec(15,3) ) then 'A' -- 판매오더 주문 수량 = 출하요청 잔량
                else 'B'
              end
            else ''
          end
      as zgtedrsta preserving type )                 as drsta,

      -- ======================================================================
      -- 1. 납품문서 생성상태
      -- ======================================================================
      cast(
          case
            when _Schl.lfrel <> 'X' or _Schl.lfrel is null then ''
            when _Item.absta = 'C' then ''
            else _Item.lfsta
          end
      as lfsta preserving type )                     as lfsta,

      -- ======================================================================
      -- 2. 출고 상태
      -- ======================================================================
      cast(
          case
            when _Schl.lfrel <> 'X' or _Schl.lfrel is null then ''
            when _Item.absta = 'C' then ''
            when _dlv.vbeln is not null then
              case
                when _dlv.gi_qty = 0 then 'A'
                when _Item.kwmeng = _dlv.gi_qty then 'C'
                else 'B'
              end
            else 'A'
          end
      as wbsta preserving type )                     as wbsta,

      -- ======================================================================
      -- 3. 보관품 입고 상태
      -- ======================================================================
      cast(
          case
            when _Item.absta = 'C' then ''
            else _Keep.kpsta
          end
      as zgtekpsta preserving type )                 as kpsta,

      -- ======================================================================
      -- 4. 거래명세서 발행 상태 (_PivQty.drqty: OEM 거래명세서 발행수량, _IvQty.lfimg: 공장 거래명세서 발행수량)
      -- ======================================================================
      cast(
          case
            when _Schl.lfrel <> 'X' or _Schl.lfrel is null then ''
            when _Item.absta = 'C' then ''
            else
              case
                when coalesce(_PivQty.loadqty,0) 
                    + cast(coalesce(_IvQty.lfimg,0) as abap.dec(15,3)) = 0 then 'A'
                
                when _PivQty.loadqty is null and _IvQty.lfimg is null then 'A'
                
                when coalesce(_PivQty.loadqty,0) 
                    + cast(coalesce(_IvQty.lfimg,0) as abap.dec(15,3)) = _Item.kwmeng then 'C'
                else 'B'
              end
          end
      as zgteivsta preserving type )                 as ivsta,

      -- ======================================================================
      -- 5. 통문처리 상태
      -- ======================================================================
      cast(
          case
            when _Schl.lfrel <> 'X' or _Schl.lfrel is null then ''
            when _Item.absta = 'C' then ''
      -- 5-0. Delivery Order 생성
            when _dlv.vbeln is not null then
              case
      -- 5-0-1. 통문 미대상 수량 존재 시
                when _dlv.out_x_qty > 0 then
                  case
      -- 5-0-1-1. 주문수량 = 통문 미대상 수량 -> space
                    when _Item.kwmeng = _dlv.out_x_qty then ''
      -- 5-0-1-2. (주문수량-통문 미대상 수량) = 통문 수량 -> 'C'
                    when _OutQty.lfimg is null or _OutQty.lfimg = 0 then 'A'
                    when _Item.kwmeng - coalesce(_dlv.out_x_qty,0) = _OutQty.lfimg then 'C'
                    else 'B'
                  end
      -- 5-0-2. 통문 미대상 수량 없을 시
                else
                  case
      -- 5-0-2-1. 주문수량 = 통문 확정 수량 -> 'C'
                    when _Item.kwmeng = _OutQty.lfimg then 'C'
                    when _OutQty.lfimg is null or _OutQty.lfimg = 0 then 'A'
                    else 'B'
                  end
              end
      -- 5-2. Delivery Order 생성 전
            else 'A'
          end
      as zgtegosta preserving type )                 as gosta,

      -- ======================================================================
      -- 6. 빌링 상태
      -- ======================================================================
      cast(
          case
            when _Item.absta = 'C' then ''
            else
              case
                when _Schl.lfrel is initial then _Item.fksaa -- Order relevant Billing
                else
                  case
                    when _Itcgry.fkrel is null then '' -- Not relevant to Billing
                    when _BlQty.vbeln is null then 'A'
                    when _Item.kwmeng = _BlQty.fkimg then 'C'
                    when _Item.zmeng  = _BlQty.fkimg then 'C'
                    else 'B'
                  end
              end
          end
      as fksta preserving type )                     as fksta,

      -- ======================================================================
      -- 7. 적송 상태
      -- ======================================================================
      cast(
          case
            when _Schl.lfrel <> 'X' or _Schl.lfrel is null then ''
            when _DfQty.vbeln is not null then
              case
                when _DfQty.dfimg_total= _DfQty.dfimg_c then 'C'
                when _DfQty.dfimg_c is initial or _DfQty.dfimg_c = 0 then 'A'
                else 'B'
              end
            else ''
          end
      as zgtedfsta preserving type )                 as dfsta,

      -- ======================================================================
      -- 8. 구매 입고 상태
      -- ======================================================================
      cast(
          case
            when _Schl.lfrel <> 'X' or _Schl.lfrel is null then ''
            when _Po.vbeln is not null then
              case
                when _Po.po_qty is not initial and _Po.gr_qty is initial or _Po.gr_qty = 0 then 'A'
                when _Item.kwmeng > _Po.gr_qty then 'B'
                when _Item.kwmeng = _Po.gr_qty then 'C'
                else ''
              end
            else ''
          end
      as zgtegrsta preserving type )                 as grsta,

      _Item.gbsta
}
