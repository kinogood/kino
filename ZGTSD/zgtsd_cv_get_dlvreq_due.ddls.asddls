@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '[GT] 출하요청 대상 리스트 조회'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTSD_CV_GET_DLVREQ_DUE
  as select from    vbap                         as _Item

    inner join      vbak                         as _Header    on _Item.vbeln = _Header.vbeln

  // 1. 핵심 비즈니스 데이터 Join
    inner join      vbep                         as _SchedLine on  _Item.vbeln      = _SchedLine.vbeln
                                                               and _Item.posnr      = _SchedLine.posnr
                                                               and _SchedLine.etenr = '0001'
    inner join      vbkd                         as _Buisness  on  _Item.vbeln     = _Buisness.vbeln
                                                               and _Buisness.posnr = '000000'

  // 2. 파트너 및 주소 정보
    inner join      vbpa                         as _Partner   on  _Item.vbeln    = _Partner.vbeln
                                                               and _Partner.parvw = 'VE' // Sales Employee
    inner join      kna1                         as _CustAddr  on _Item.kunwe_ana = _CustAddr.kunnr
    inner join      adrc                         as _Address   on _CustAddr.adrnr = _Address.addrnumber

  // 3. 수량 집계 View (Aggregations)
    left outer join ZGTSD_CV_SUM_DLVQTY_FACTOR   as _SumFactor on  _Item.vbeln = _SumFactor.vbeln
                                                               and _Item.posnr = _SumFactor.posnr
    left outer join ZGTSD_CV_SUM_ZLET0401        as _Sum0401   on  _Item.vbeln = _Sum0401.vbeln
                                                               and _Item.posnr = _Sum0401.posnr
    left outer join ZGTSD_CV_SUM_ZLET0402        as _Sum0402   on  _Item.vbeln = _Sum0402.vbeln
                                                               and _Item.posnr = _Sum0402.posnr

  // 4. 특성값 (Characteristics)
    left outer join ZGTSD_CV_GET_VCOFSO          as _CharSet   on  _Item.vbeln = _CharSet.vbeln
                                                               and _Item.posnr = _CharSet.posnr

  // 5. Link재고 조회
    left outer join ZGTSD_CV_GET_SUM_LINK_STOCK  as _LStock    on  _Item.vbeln = _LStock.vbeln
                                                               and _Item.posnr = _LStock.posnr

  // 6. 판매오더 재고 조회
    left outer join ZGTSD_CV_SUM_SO_STOCK_BY_LEN as _EStock    on  _Item.vbeln = _EStock.vbeln
                                                               and _Item.posnr = _EStock.posnr
                                                               and _Item.werks = _EStock.werks

  // 7. Picking 후 Goods Issue 되지 않은 판매오더 재고
    left outer join ZGTSD_CV_SUM_OPEN_PICKED_QTY as _PickQty   on  _Item.vbeln = _PickQty.vbeln
                                                               and _Item.posnr = _PickQty.posnr

    left outer join zsd0106t                     as _Pjt       on _Header.zpjno = _Pjt.zpjno

    left outer join vbkd                         as _CS        on  _Item.vbeln = _CS.vbeln
                                                               and _Item.posnr = _CS.posnr

  // 7. Associations 정의
  association [0..1] to kna1  as _SoldToParty   on  $projection.kunag = _SoldToParty.kunnr
  association [0..1] to kna1  as _ShipToParty   on  $projection.kunwe = _ShipToParty.kunnr
  association [1..1] to tvlst as _DlvBlockText  on  $projection.lifsp   = _DlvBlockText.lifsp
                                                and _DlvBlockText.spras = $session.system_language
  association [1..1] to tvstt as _ShipPointText on  $projection.vstel    = _ShipPointText.vstel
                                                and _ShipPointText.spras = $session.system_language
  association [1..1] to t001w as _PlantText     on  $projection.werks = _PlantText.werks
  association [1..1] to lfa1  as _Vendor        on  $projection.sales_empl = _Vendor.lifnr
  association [1..1] to tzont as _TransZoneText on  $projection.lzone    = _TransZoneText.zone1
                                                and $projection.land1    = _TransZoneText.land1
                                                and _TransZoneText.spras = $session.system_language
  association [0..1] to t006  as _UOM           on  $projection.vrkme = _UOM.msehi
  association [1..1] to makt  as _MaterialText  on  $projection.matnr   = _MaterialText.matnr
                                                and _MaterialText.spras = $session.system_language

{
      // Key Fields
  key cast(_Item.vbeln as vbeln_va preserving type )         as vbeln,
  key cast(_Item.posnr as posnr_va preserving type )         as posnr,


      // Sales Order Data
      _Item.auart_ana                                        as auart,

      // Org Data
      _Item.vkorg_ana                                        as vkorg,
      _Item.vtweg_ana                                        as vtweg,
      _Item.spart_ana                                        as spart,
      _Item.vkbur_ana                                        as vkbur,
      _Item.vkgrp_ana                                        as vkgrp,

      // Business Data
      _Buisness.kdkg4,
      _CS.bstdk_e,

      // Partner Info
      _Item.kunnr_ana                                        as kunag,
      _SoldToParty.name1                                     as knuag_name,
      _Item.kunwe_ana                                        as kunwe,
      _ShipToParty.name1                                     as shipto_name,

      // Scheduling
      _SchedLine.lifsp,
      _DlvBlockText.vtext                                    as lifsp_t,
      _SchedLine.edatu                                       as edatu,

      // Material & Characteristics
      _Item.sobkz,
      _Item.matnr,
      _MaterialText.maktx,
      _Item.arktx,
      _Item.mvgr3,
      _CharSet.COLOR,
      _CharSet.STRIPE_COLOR,
      _CharSet.STRIPE_CNT,
      _CharSet.SPECNO,

      // Quantities
      @Semantics.quantity.unitOfMeasure: 'vrkme'
      _CharSet.LENGTH,
      _CharSet.FACTOR,

      @Semantics.quantity.unitOfMeasure: 'vrkme'
      _Item.kwmeng,

      _Item.vrkme,

      @Semantics.quantity.unitOfMeasure: 'vrkme'
      _SchedLine.bmeng,
     @Semantics.quantity.unitOfMeasure: 'vrkme'
     cast( coalesce( _SumFactor.sum_factor, 0 ) as abap.dec(13,3) ) as total_delivered_qty,
     @Semantics.quantity.unitOfMeasure: 'vrkme'
     cast( coalesce( _Sum0401.req_qty, 0 )      as abap.dec(13,3) ) as requested_qty,
     @Semantics.quantity.unitOfMeasure: 'vrkme'
     cast( coalesce( _Sum0402.reqdo_qty, 0 )    as abap.dec(13,3) ) as requested_dlvqty,
     
      @Semantics.quantity.unitOfMeasure: 'vrkme'
      case
        when _UOM.dimid = 'LENGTH' and _CharSet.FACTOR is not initial
        then         cast( coalesce(_CharSet.FACTOR, 0 ) as abap.dec(13,3) )
                   - cast( coalesce( _SumFactor.sum_factor, 0 ) as abap.dec(13,3) )
                   - cast( coalesce( _Sum0401.req_qty, 0 )      as abap.dec(13,3) )
                   + cast( coalesce( _Sum0402.reqdo_qty, 0 )    as abap.dec(13,3) )

        else         cast( coalesce( _Item.kwmeng, 0 )          as abap.dec(13,3) )
                   - cast( coalesce( _SumFactor.sum_qty, 0 )    as abap.dec(13,3) )
                   - cast( coalesce( _Sum0401.req_qty, 0 )      as abap.dec(13,3) )
                   + cast( coalesce( _Sum0402.reqdo_qty, 0 )    as abap.dec(13,3) )

      end                                                    as rmqty,

      @Semantics.quantity.unitOfMeasure: 'vrkme'
      cast( coalesce(_EStock.Estock, 0) as abap.dec(13,3) )
      +
      cast( coalesce(_LStock.LStock, 0)  as abap.dec(13,3) ) as linked_stock,      
      
      @Semantics.quantity.unitOfMeasure: 'vrkme'
      cast(cast( coalesce(_LStock.LStock, 0) as abap.quan(13,3) )
           as zgtelstock preserving type )                   as lstock,

      @Semantics.quantity.unitOfMeasure: 'vrkme'
      cast(cast( coalesce(_EStock.Estock, 0)  as abap.quan(13,3) )
           as zgteestock preserving type )                   as estock,

      @Semantics.quantity.unitOfMeasure: 'vrkme'
      _PickQty.picked_qty,

      // Logistics Data
      _Item.vstel,
      _ShipPointText.vtext                                   as vstel_t,
      _Item.werks,
      _PlantText.name1                                       as plant_t,
      _Item.lgort,

      // Sales Employee
      _Partner.lifnr                                         as sales_empl,
      _Vendor.name1                                          as empl_name,

      cast(_Header.zpjno as zpjno preserving type )          as zpjno,
      cast(_Pjt.zptxt as zptxt preserving type )             as zptxt,

      // Address Info (From KNA1 & ADRC)
      _CustAddr.land1,
      _Address.city1,
      _Address.post_code1,
      _Address.transpzone                                    as lzone,
      _TransZoneText.vtext                                   as transpzone_t,
      _Address.country,
      _Address.tel_number,
      _Address.extension1,

      _Item.erdat,

      _Item.lfsta

}
where
       _SchedLine.lfrel =  'X' // Delivery Relevance
  and  _Item.abgru      is initial
  --  and  _SchedLine.lifsp is initial
  and  _Header.faksk    <> 'G1' -- 소재 매출정산완료
  and  _Header.augru    <> '150' -- 선수금 전용
  and(
       _Item.vbtyp_ana  =  'C' // Order
    or _Item.vbtyp_ana  =  'I' // Return Order
  )
  and  _Item.pstyv      <> 'ZADP' -- 선수금 Item Category
