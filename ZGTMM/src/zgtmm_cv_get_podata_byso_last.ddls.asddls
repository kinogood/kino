@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'MTO 구매오더 정보 조회 최종'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_GET_PODATA_BYSO_LAST 
as select from ZGTMM_CV_GET_PODATA_BYSO as A inner join ZGTMM_CV_GET_PODATA_BYSO_SUM as B on A.vbeln = B.vbeln and A.posnr = B.posnr and A.CHECKPO = B.CHECKPO

// 26.09 LGORT, LGOBE 추가 
    left outer join ekpo as L
                             on A.ebeln = L.ebeln
                            and A.ebelp = L.ebelp
    left outer join t001l as LT
                             on L.lgort = LT.lgort
                            and L.werks = LT.werks

{
  key A.vbeln,
  key A.posnr,
      A.ebeln,
      A.ebelp,

// 26.09 LGORT, LGOBE 추가
      max( L.lgort  ) as lgort,
      max( LT.lgobe ) as lgobe       

} 

group by 
    A.vbeln,
    A.posnr,
    A.ebeln,
    A.ebelp

