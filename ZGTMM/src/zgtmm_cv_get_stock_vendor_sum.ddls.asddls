@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '업체 보관품 재고 현황 조회_VIEW'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_GET_STOCK_VENDOR_SUM
  as select from ZGTMM_CV_GET_STOCK_VENDOR as A
  //association [0..*] to ZGTMM_CV_GET_PODATA_BYSO_LAST  as Z on $projection.vbeln = Z.vbeln and $projection.posnr = Z.posnr

{
  key A.lifnr,
  key A.matnr,
  key A.bukrs,
  key A.werks,
      A.vbeln,
      A.posnr,
      A.TEAM2DGIT,
      A.txz01,
      A.LENGTH,
      @Semantics.quantity.unitOfMeasure: 'meins'
      sum(STOCK) as STOCK,
      A.meins,
      A.VGW,
      A.color,
      A.STRIPE,
      A.stripe_no,
      @Semantics.quantity.unitOfMeasure: 'meins'
      A.REQQTY,
      @Semantics.quantity.unitOfMeasure: 'meins'
      A.DLVQTY,
      A.EBELN,
      A.EBELP,

      // 26.09 저장위치 추가
            A.lgort,
            A.lgobe,


      A.VBELN_OR,
      A.POSNR_OR

}
group by
  A.lifnr,
  A.matnr,
  A.bukrs,
  A.werks,
  A.vbeln,
  A.posnr,
  A.TEAM2DGIT,
  A.txz01,
  A.LENGTH,
  A.meins,
  A.VGW,
  A.color,
  A.STRIPE,
  A.stripe_no,
  A.REQQTY,
  A.DLVQTY,
  A.EBELN,
  A.EBELP,
  A.VBELN_OR,
  A.POSNR_OR,
  // 26.09 저장위치 추가
  A.lgort,
  A.lgobe

