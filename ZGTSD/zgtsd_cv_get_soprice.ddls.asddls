@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '[GT] 판매오더 단가 및 금액 조회'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTSD_CV_GET_SOPRICE
  as select from    vbap          as A
    inner join      prcd_elements as C on  A.knumv_ana = C.knumv
                                       and A.posnr     = C.kposn
    inner join      vbkd          as B on  A.vbeln = B.vbeln
                                       and B.posnr = '000000'
    left outer join tvarct        as D on  C.varcond = D.varcond
                                       and D.spras   = $session.system_language
{
  key A.vbeln,
  key A.posnr,

      A.vkorg_ana,
      A.vtweg_ana,
      A.spart_ana,
      A.vkbur_ana,
      A.vkgrp_ana,
      A.kunnr_ana,
      A.kunwe_ana,
      A.auart_ana,
      A.abgru,

      C.varcond,
      D.vctext,

      A.matnr,
      A.arktx,
      @Semantics.quantity.unitOfMeasure: 'VRKME'
      A.kwmeng,
      A.vrkme,

      C.kschl,
      @Semantics.amount.currencyCode: 'WAERS'
      C.kbetr,
      C.waers,
      @Semantics.amount.currencyCode: 'WAERK'
      C.kwert,
      C.waerk,

      C.kkurs,

      @Semantics.amount.currencyCode: 'waerk_krw'
      cast(
      currency_conversion(
          amount => C.kwert,
          source_currency => C.waerk,
          target_currency => cast( 'KRW' as abap.cuky ),
          exchange_rate_date => B.prsdt,
          exchange_rate_type => 'M',
          client => $session.client
          ) as abap.curr(15,2)
      )                          as netwr_krw,

      cast( 'KRW' as abap.cuky ) as waerk_krw,

      A.erdat,
      A.erzet,
      A.ernam

}
