@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '목드럼 규격 별 단가 Mapping'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZGTMM_CV_DRUM_NETPR
  as select from    ZGTMM_CV_DRUM_STATUS as A
    left outer join zgtmmt1041           as B on  A.DRM_GUBUN = B.drm_gubun
                                              and A.DRM_SIZE  = B.drm_size
{
  key B.bukrs,
  key B.ekorg,
  key B.werks,
  key B.lifnr,
  key B.zyear,
  key A.matnr,
      B.drm_gubun,
      A.DRM_SIZE,
      A.DRM_SG_TYPE,
      A.CA_NO,
      A.meins,
      B.waers as Waers,

      /* 신드럼, 고드럼에 따라 단가 분기*/
      @Semantics.amount.currencyCode: 'Waers'
      case
        when A.DRM_SG_TYPE = 'S' then B.sdr_netpr
        when A.DRM_SG_TYPE = 'G' then B.gdr_netpr
      end     as DRM_NETPR,

      @Semantics.amount.currencyCode: 'Waers'
      B.board_netpr,

      @Semantics.amount.currencyCode: 'Waers'
      case
        when A.DRM_SG_TYPE = 'S' then B.mark_netpr
        when A.DRM_SG_TYPE = 'G' then cast( 0 as abap.curr(15,2) )
      end     as MARK_NETPR,

      @Semantics.amount.currencyCode: 'Waers'
      case
        when A.DRM_SG_TYPE = 'S' then cast( 0 as abap.curr(15,2) )
        when A.DRM_SG_TYPE = 'G' then B.dis_netpr
      end     as DIS_NETPR

}
