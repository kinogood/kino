@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '포장(SAP_MILLCA_PACKAGING) 드럼 자재의 드럼 구분'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZGTMM_CV_PACK_DRUM_GUBUN
  as select from ZGTMM_CV_DRUM_STATUS
{
  key right( matnr, 7 ) as PACKCODE,
      DRM_GUBUN
}
where
  lvorm = ''
