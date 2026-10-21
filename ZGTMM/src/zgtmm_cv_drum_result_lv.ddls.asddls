@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '목드럼 실적 집계(드럼 레벨)'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZGTMM_CV_DRUM_RESULT_LV
  as select from zgtmmt4272           as A
    inner join   zgtmmt4271           as B on  A.ekorg = B.ekorg
                                           and A.werks = B.werks
                                           and A.lifnr = B.lifnr
                                           and A.zdate = B.zdate
    inner join   zgtmmt4270           as C on  B.bukrs = C.bukrs
                                           and A.werks = C.werks
                                           and A.lifnr = C.lifnr
                                           and B.spmon = C.spmon
    inner join   makt                 as D on  A.matnr = D.matnr
                                           and D.spras = '3'
    inner join   lfa1                 as E on A.lifnr = E.lifnr
{
  key C.bukrs,
  key A.ekorg,
  key A.werks,
  key A.lifnr,
  key C.spmon,

  key A.drm_type,
  key A.drm_lv,
  key A.drm_sg_type,
  key A.matnr,
  key D.maktx,


      /* 드럼 */
      @Semantics.quantity.unitOfMeasure:'Meins'
      sum( A.drm_count )    as drm_count,
      @Semantics.amount.currencyCode: 'Waers'
      sum( A.drm_price )    as drm_price,

      @Semantics.amount.currencyCode: 'Waers'
      case
        when sum( A.drm_count ) = 0
          then cast( 0 as abap.dec(11,2) )
        else cast(
               cast( sum( A.drm_price ) as abap.dec(23,5) )
             / cast( sum( A.drm_count ) as abap.dec(23,5) )
             as abap.dec(11,2)
             )
      end                   as drm_netpr,


      /* 골판지 */
      @Semantics.quantity.unitOfMeasure:'Meins'
      sum( A.board_count )  as board_count,
      @Semantics.amount.currencyCode: 'Waers'
      sum( A.board_price )  as board_price,

      @Semantics.amount.currencyCode: 'Waers'
      case
        when sum( A.board_count ) = 0
          then cast( 0 as abap.dec(11,2) )
        else cast(
               cast( sum( A.board_price ) as abap.dec(23,5) )
             / cast( sum( A.board_count ) as abap.dec(23,5) )
             as abap.dec(11,2)
             )
      end                   as board_netpr,


      /* 일반 마킹 */
      @Semantics.quantity.unitOfMeasure:'Meins'
      sum( A.mark_n_count ) as mark_n_count,
      @Semantics.amount.currencyCode: 'Waers'
      sum( A.mark_n_price ) as mark_n_price,

      @Semantics.amount.currencyCode: 'Waers'
      case
        when sum( A.mark_n_count ) = 0
          then cast( 0 as abap.dec(11,2) )
        else cast(
               cast( sum( A.mark_n_price ) as abap.dec(23,5) )
             / cast( sum( A.mark_n_count ) as abap.dec(23,5) )
             as abap.dec(11,2)
             )
      end                   as mark_n_netpr,

      /* 한전 마킹 */
      @Semantics.quantity.unitOfMeasure:'Meins'
      sum( A.mark_h_count ) as mark_h_count,
      @Semantics.amount.currencyCode: 'Waers'
      sum( A.mark_h_price ) as mark_h_price,

      @Semantics.amount.currencyCode: 'Waers'
      case
        when sum( A.mark_h_count ) = 0
          then cast( 0 as abap.dec(11,2) )
        else cast(
               cast( sum( A.mark_h_price ) as abap.dec(23,5) )
             / cast( sum( A.mark_h_count ) as abap.dec(23,5) )
             as abap.dec(11,2)
             )
      end                   as mark_h_netpr,


      @Semantics.quantity.unitOfMeasure:'Meins'
      sum( A.dis_count )    as dis_count,
      @Semantics.amount.currencyCode: 'Waers'
      sum( A.dis_price )    as dis_price,

      /* 고드럼 해체 */
      @Semantics.amount.currencyCode: 'Waers'
      case
        when sum( A.dis_count ) = 0
          then cast( 0 as abap.dec(11,2) )
        else cast(
               cast( sum( A.dis_price ) as abap.dec(23,5) )
             / cast( sum( A.dis_count ) as abap.dec(23,5) )
             as abap.dec(11,2)
             )
      end                   as dis_netpr,


      A.meins,
      A.waers
}
group by
  C.bukrs,
  A.ekorg,
  A.werks,
  A.lifnr,
  C.spmon,
  A.drm_type,
  A.drm_lv,
  A.drm_sg_type,
  A.matnr,
  D.maktx,
  A.meins,
  A.waers
