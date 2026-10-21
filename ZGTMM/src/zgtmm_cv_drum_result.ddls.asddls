@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '목드럼 실적 집계'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZGTMM_CV_DRUM_RESULT
  as select from zgtmmt4272           as A
    inner join   zgtmmt4271           as B on  A.ekorg = B.ekorg
                                           and A.werks = B.werks
                                           and A.lifnr = B.lifnr
                                           and A.zdate = B.zdate
    inner join   zgtmmt4270           as C on  B.bukrs = C.bukrs
                                           and A.werks = C.werks
                                           and A.lifnr = C.lifnr
                                           and B.spmon = C.spmon
    inner join   lfa1                 as E on A.lifnr = E.lifnr
{
  key C.bukrs,
  key A.ekorg,
  key A.werks,
  key A.lifnr,
  key E.name1,
  key C.spmon,

  key A.drm_type,
  key A.drm_lv,

      /* 신드럼 실적 수량 + 총액 + 단가(계산) */
      @Semantics.quantity.unitOfMeasure:'Meins'
      sum(
        case
          when A.drm_sg_type = 'S'
            then A.drm_count
          else cast( 0 as abap.quan(13,3) )
        end
      )                     as sdr_count,

      @Semantics.amount.currencyCode: 'Waers'
      sum(
        case
          when A.drm_sg_type = 'S'
            then cast( A.drm_price as abap.dec(13,2) )
          else cast( 0 as abap.dec(13,2) )
        end
      )                     as sdr_price,

      @Semantics.amount.currencyCode: 'Waers'
      case
        when sum( case when A.drm_sg_type = 'S' then A.drm_count else 0 end ) = 0
          then cast( 0 as abap.dec(11,2) )
        else cast(
               sum(
                 case
                   when A.drm_sg_type = 'S'
                     then cast( A.drm_price as abap.dec(23,5) )
                   else cast( 0 as abap.dec(23,5) )
                 end
               )
             / cast(
                 sum( case when A.drm_sg_type = 'S' then A.drm_count else 0 end )
                 as abap.dec(23,5)
               )
             as abap.dec(11,2)
             )
      end                   as sdr_netpr,


      /* 고드럼 실적 수량 + 총액 + 단가(계산) */
      @Semantics.quantity.unitOfMeasure:'Meins'
      sum(
        case
          when A.drm_sg_type = 'G'
            then A.drm_count
          else cast( 0 as abap.quan(13,3) )
        end
      )                     as gdr_count,

      @Semantics.amount.currencyCode: 'Waers'
      sum(
        case
          when A.drm_sg_type = 'G'
            then cast( A.drm_price as abap.dec(13,2) )
          else cast( 0 as abap.dec(13,2) )
        end
      )                     as gdr_price,

      @Semantics.amount.currencyCode: 'Waers'
      case
        when sum(
               case
                 when A.drm_sg_type = 'G'
                   then A.drm_count
                 else cast( 0 as abap.quan(13,3) )
               end
             ) = 0
          then cast( 0 as abap.dec(11,2) )
        else cast(
               sum(
                 case
                   when A.drm_sg_type = 'G'
                     then cast( A.drm_price as abap.dec(23,5) )
                   else cast( 0 as abap.dec(23,5) )
                 end
               )
             / cast(
                 sum(
                   case
                     when A.drm_sg_type = 'G'
                       then A.drm_count
                     else cast( 0 as abap.quan(13,3) )
                   end
                 ) as abap.dec(23,5)
               )
             as abap.dec(11,2)
             )
      end                   as gdr_netpr,

      /* 골판지 조립 실적 수량 + 총액 + 단가(계산) */
      @Semantics.quantity.unitOfMeasure:'Meins'
      sum( A.board_count )  as board_count,

      @Semantics.amount.currencyCode: 'Waers'
      sum( A.board_price )  as board_price,

      @Semantics.amount.currencyCode: 'Waers'
      case
        when sum( A.board_count ) = 0
          then cast( 0 as abap.dec(13,3) )
        else cast(
               cast( sum( A.board_price ) as abap.dec(23,5) )
             / cast( sum( A.board_count ) as abap.dec(23,5) )
             as abap.dec(11,2)
             )
      end                   as board_netpr,

      /* 마킹(합계) 실적 수량 + 총액 + 단가(계산) */
      @Semantics.quantity.unitOfMeasure:'Meins'
      sum( A.mark_count )   as mark_count,

      @Semantics.amount.currencyCode: 'Waers'
      sum( A.mark_price )   as mark_price,

      @Semantics.amount.currencyCode: 'Waers'
      case
        when sum( A.mark_count ) = 0
          then cast( 0 as abap.dec(13,3) )
        else cast(
               cast( sum( A.mark_price ) as abap.dec(23,5) )
             / cast( sum( A.mark_count ) as abap.dec(23,5) )
             as abap.dec(11,2)
             )
      end                   as mark_netpr,

      /* 일반 마킹 실적 수량 + 총액 + 단가(계산) */
      @Semantics.quantity.unitOfMeasure:'Meins'
      sum( A.mark_n_count ) as mark_n_count,

      @Semantics.amount.currencyCode: 'Waers'
      sum( A.mark_n_price ) as mark_n_price,

      @Semantics.amount.currencyCode: 'Waers'
      case
        when sum( A.mark_n_count ) = 0
          then cast( 0 as abap.dec(13,3) )
        else cast(
               cast( sum( A.mark_n_price ) as abap.dec(23,5) )
             / cast( sum( A.mark_n_count ) as abap.dec(23,5) )
             as abap.dec(11,2)
             )
      end                   as mark_n_netpr,

      /* 한전 마킹 실적 수량 + 총액 + 단가(계산) */
      @Semantics.quantity.unitOfMeasure:'Meins'
      sum( A.mark_h_count ) as mark_h_count,

      @Semantics.amount.currencyCode: 'Waers'
      sum( A.mark_h_price ) as mark_h_price,

      @Semantics.amount.currencyCode: 'Waers'
      case
        when sum( A.mark_h_count ) = 0
          then cast( 0 as abap.dec(13,3) )
        else cast(
               cast( sum( A.mark_h_price ) as abap.dec(23,5) )
             / cast( sum( A.mark_h_count ) as abap.dec(23,5) )
             as abap.dec(11,2)
             )
      end                   as mark_h_netpr,

      /* 고드럼 해체 실적 수량 + 총액 + 단가(계산) */
      @Semantics.quantity.unitOfMeasure:'Meins'
      sum( A.dis_count )    as dis_count,

      @Semantics.amount.currencyCode: 'Waers'
      sum( A.dis_price )    as dis_price,

      @Semantics.amount.currencyCode: 'Waers'
      case
        when sum( A.dis_count ) = 0
          then cast( 0 as abap.dec(13,3) )
        else cast(
               cast( sum( A.dis_price ) as abap.dec(23,5) )
             / cast( sum( A.dis_count ) as abap.dec(23,5) )
             as abap.dec(11,2)
             )
      end                   as dis_netpr,

      /* 단위 */
      A.meins,
      A.waers
}
group by
  C.bukrs,
  A.ekorg,
  A.werks,
  A.lifnr,
  E.name1,
  C.spmon,
  A.drm_type,
  A.drm_lv,
  A.meins,
  A.waers
