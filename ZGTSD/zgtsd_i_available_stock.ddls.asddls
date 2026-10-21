@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '[GT] 가온 가용재고 조회 Base'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZGTSD_I_AVAILABLE_STOCK
  as select from    nsdm_e_mchb                  as _Base

  -- 1. 할당 재고 (JOIN)
    left outer join ZGTSD_CV_SUM_LINKSTOCK_BATCH as _LStock  on  _Base.matnr = _LStock.matnr
                                                             and _Base.werks = _LStock.werks
                                                             and _Base.lgort = _LStock.lgort
                                                             and _Base.charg = _LStock.charg
                                                             and _LStock.Linked_qty > 0

  -- 2. 피킹 수량 집계 뷰 (JOIN)
    left outer join ZGTSD_I_BATCH_PICKED_QTY     as _Pick    on  _Base.matnr = _Pick.matnr
                                                             and _Base.werks = _Pick.werks
                                                             and _Base.lgort = _Pick.lgort
                                                             and _Base.charg = _Pick.charg
                                                             and _Pick.Total_Picked_qty > 0

  -- 3. 자재 마스터 (Association)
    inner join      mara                         as _Product on _Base.matnr = _Product.matnr

    inner join      marc                         as _SuBatch on  _Base.matnr = _SuBatch.matnr
                                                             and _Base.werks = _SuBatch.werks

  -- 4. 배치 특성 (Association)
    left outer join ZGTSD_I_GET_BATCH_CHAR       as _Char    on  _Base.matnr = _Char.matnr
                                                             and _Base.charg = _Char.charg
  //  association [0..1] to ZGTSD_CV_GET_VCOFBATCH as _Char        on  $projection.matnr = _Char.matnr
  //                                                               and $projection.werks = _Char.werks
  //                                                               and $projection.charg = _Char.charg
  //                                                               and $projection.lgort = _Char.lgort
  //                                                               and _Char.atnam       = 'SAP_MILLCA_LENGTH'

  association [1..1] to makt as _ProductText on  $projection.matnr  = _ProductText.matnr
                                             and _ProductText.spras = $session.system_language

  association [0..1] to t006 as _Uom         on  $projection.meins = _Uom.msehi

{
  key _Base.matnr,
  key _Base.werks,
  key _Base.lgort,
  key _Base.charg,

      -- 0. Material Master Info
      _ProductText.maktx,

      -- 1. Batch Stock Info
      @Semantics.quantity.unitOfMeasure: 'meins'
      case when _Uom.dimid = 'LENGTH' and _Char.MILL_LENGTH is not initial
           then cast(_Char.MILL_LENGTH as abap.dec(13,3))
           else 0
      end                                                           as mchb_length,
      //      case when _Uom.dimid = 'LENGTH' then
      //           case when _Char.factor = 0 or _Char.factor is null then 1
      //                else _Char.factor
      //           end
      //      end                                                           as mchb_factor,

      case when _Uom.dimid = 'LENGTH' and (_SuBatch.dpcbt = 'A' or
                                           _SuBatch.dpcbt = 'C')
           then 1
           else 0
      end                                                           as mchb_factor,


      @Semantics.quantity.unitOfMeasure: 'meins'
      _Base.clabs                                                   as Stock_Qty,
      _Product.meins                                                as meins,

      -- 2. Picking Info (sobkz <> 'E' 대상 집계)
      @Semantics.quantity.unitOfMeasure: 'meins'
      cast( coalesce(_Pick.Total_Picked_qty, 0) as abap.quan(13,3)) as picked_qty,

      @Semantics.quantity.unitOfMeasure: 'meins'
      cast( _Base.clabs - coalesce(_Pick.Total_Picked_qty, 0)
            as abap.quan(13,3) )                                    as unpicked_qty,

      -- 3. Stocks Linked to SalesOrder
      @Semantics.quantity.unitOfMeasure: 'meins'
      cast( coalesce(_LStock.Linked_qty, 0) as abap.quan(13,3) )    as linked_length,

      -- 4. Unlinked Stocks (미할당 재고 수량)
      @Semantics.quantity.unitOfMeasure: 'meins'
      //      case when _SuBatch.dpcbt = 'A' and _Uom.dimid = 'LENGTH'
      //           -- 4.1 Factor Batch는 조장 고정
      //           then cast( coalesce(_Char.atflv, 0) as abap.quan(13,3) ) -- NULL 방어 추가
      //
      //           else
      //              cast(
      //           -- 4.2.0 (재고수량 - Picked수량 - Linked수량)/
      //                  division(
      //           -- 4.2.1 재고수량 - Picked수량 - Linked수량
      //                      cast( _Base.clabs - coalesce(_Pick.Total_Picked_qty, 0)
      //                            - coalesce(_LStock.linked_qty,0) as abap.dec(13,3)),
      //           -- 4.2.1
      //                      case when _Uom.dimid = 'LENGTH'
      //                           then case when _Char.factor = 0 or _Char.factor is null
      //                                     then cast( 1 as abap.dec(13,3))
      //                                     else cast(_Char.factor as abap.dec(13,3))
      //                                     end
      //                           else cast (1 as abap.dec(13,3))
      //                           end,
      //                      0
      //                  )
      //              as abap.quan(13,3) )
      //      end                                                           as unlinked_length,
      cast(
      -- 4.1 Factor Batch는 조장 고정
          case when _SuBatch.dpcbt = 'A' and _Uom.dimid = 'LENGTH'
                   then coalesce( cast(_Char.MILL_LENGTH as abap.quan(13,3)), 0)
      -- 4.2 그외 :재고수량 - Picked수량 합계 - Link수량(조장*조장수) 합계
               else
                   cast(coalesce(_Base.clabs - coalesce(_Pick.Total_Picked_qty, 0)
                                             - coalesce(_LStock.Linked_qty,0)
                                , 0)
                        as abap.dec(13,3))
               end
      as abap.quan(13,3) )                                          as unlinked_length,

      -- 5. Unlinked Factor (미할당 존재 여부 플래그)
      case when _SuBatch.dpcbt = 'A' and _Uom.dimid = 'LENGTH'
           then case when cast(_Char.MILL_LENGTH as abap.dec(13,3)) > 0
                     then division(  cast(_Base.clabs - coalesce(_Pick.Total_Picked_qty, 0)
                                                      - coalesce(_LStock.Linked_qty, 0)
                                          as abap.dec(13,3) )
                                    , cast( _Char.MILL_LENGTH as abap.dec(13,3) )
                                    , 0 )
                     else 0
                end
           else
               case when _LStock.Linked_qty > 0
                    then 1 else 0 end
      end                                                           as unlinked_factor,

      _SuBatch.dpcbt,
      _Uom.dimid
}
where
          _Base.clabs    >  0
  and     _Base.lvorm    <> 'X'
  and(
    (
          _Product.mtart =  'MCFE'
      or  _Product.mtart =  'MCHA'
      or  _Product.mtart =  'HAWA'
    )
    or(
          _Product.spart =  '10'
      and _Product.mtart =  'MCHF'
    )
  )
