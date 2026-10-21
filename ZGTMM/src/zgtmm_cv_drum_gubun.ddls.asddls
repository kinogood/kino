@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '목드럼 구분(가온) List'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZGTMM_CV_DRUM_GUBUN
  as select from cabn as A
    inner join   cawn as B on A.atinn = B.atinn

{
      /* RL_GA_DRUM_GUBUN 가온 드럼 기호*/
  key A.atinn as Atinn,
  key A.adzhl as Adzhl,
  key A.atnam as atnam,
  key B.atzhl as Atzhl,
      B.atwrt as DRM_GUBUN

}
where
  A.atnam = 'RL_GA_DRUM_GUBUN'
