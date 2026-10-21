@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '[GT] 납품 문서 기준 (거래명세서/출고/통문/빌링) 수량'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZGTSD_I_DELIVERY_STATUS
  as select from    lips                as _Item
    inner join      likp                as _Header on _Item.vbeln = _Header.vbeln

    left outer join ZGTSD_CV_ZGTSDT9120 as _DfItem on  _Item.vbeln = _DfItem.vbeln
                                                   and _Item.posnr = _DfItem.posnr

  //    left outer join zgtsdt1106 as _OutExp on  _Header.vkorg = _OutExp.vkorg
  //                                          and _Item.vtweg   = _OutExp.vtweg
  //                                          and _Item.spart   = _OutExp.spart
  //                                          and _Item.lgort   = _OutExp.lgort
  //                                          and _OutExp.loevm is initial
{
  key _Item.vgbel as vbeln,
  key _Item.vgpos as posnr,
      _Header.vkorg,
      _Item.werks,
//      _Header.vstel,
      _Item.vrkme,


      -- 0. 납품문서 수량 집계
      @Semantics.quantity.unitOfMeasure: 'vrkme'
      sum( case when _Item.lfimg > 0
                then _Item.lfimg
                else cast(cast(0 as abap.quan(13,3) ) as lfimg preserving type )
           end )  as dlv_qty,

      -- 2. 출고완료 수량 집계
      @Semantics.quantity.unitOfMeasure: 'vrkme'
      sum(
           case when _Item.wbsta = 'C' and _Item.lfimg > 0 and
                      ( substring(_Header.lfart, 1, 2) = 'LF' or _Header.lfart = 'ZLFS' )
                then _Item.lfimg
                else cast(cast(0 as abap.quan(13,3) ) as lfimg preserving type )
           end
           +
           case when _DfItem.wbsta = 'C' and _DfItem.lfimg > 0
                then _DfItem.lfimg
                else cast(cast(0 as abap.quan(13,3) ) as lfimg preserving type )
           end
         )        as gi_qty,



      @Semantics.quantity.unitOfMeasure: 'vrkme'
      sum(
           case when _Item.wbsta = 'C' and _Item.lfimg > 0 and 
                     ( substring(_Header.lfart, 1, 2) = 'LF' or _Header.lfart = 'ZLFS' )
                then _Item.lfimg
                else cast(cast(0 as abap.quan(13,3) ) as lfimg preserving type )
           end)   as gi_lf_qty,

      @Semantics.quantity.unitOfMeasure: 'vrkme'
      sum(           case when _DfItem.wbsta = 'C' and _DfItem.lfimg > 0
                then _DfItem.lfimg
                else cast(cast(0 as abap.quan(13,3) ) as lfimg preserving type )
           end)   as gi_9120_qty,

      -- 3. 통문완료 수량 집계
      //      @Semantics.quantity.unitOfMeasure: 'vrkme'
      //      sum( case when _Header.zout = 'Y'
      //                then _Item.lfimg
      //                else cast(cast(0 as abap.quan(13,3) ) as lfimg preserving type )
      //           end )  as out_y_qty,

      -- 4. 통문미대상 수량 집계
      @Semantics.quantity.unitOfMeasure: 'vrkme'
      sum( case when _Header.zout = 'X' and _Item.lgort = '3498'
                then _Item.lfimg
                else cast(cast(0 as abap.quan(13,3) ) as lfimg preserving type )
           end )  as out_x_qty

      //      -- 6. 적송 출고완료 수량 집계 (수정됨)
      //      @Semantics.quantity.unitOfMeasure: 'vrkme'
      //      sum( case when _Header.lfart = 'ZLF3' and _Item.uecha > '000000'
      //                then _Item.lfimg
      //                when _Header.lfart = 'ZLF3' and ( _Item.uecha is null or _Item.uecha = '000000' ) and _Item.fksta = 'C'
      //                then _Item.lfimg
      //                else cast(cast(0 as abap.quan(13,3) ) as lfimg preserving type )
      //           end )  as zlf3_qty

}
where
       _Item.vgbel   is not initial
  and(
       _Header.vbtyp = 'J'
    or _Header.vbtyp = 'T'
  )
group by
  _Item.vgbel,
  _Item.vgpos,
  _Header.vkorg,
  _Item.werks,
//  _Header.vstel,
  _Item.vrkme
