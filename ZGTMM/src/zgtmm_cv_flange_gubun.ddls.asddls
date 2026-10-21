@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '플랜지 특성(GA_DRUM_GUBUN)'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZGTMM_CV_FLANGE_GUBUN
  as select from mara as A
    inner join   makt as B on  A.matnr = B.matnr
                           and B.spras = '3'
    inner join   kssk as C on A.matnr = C.objek
    inner join   klah as D on C.clint = D.clint
    inner join   ksml as E on D.clint = E.clint
    inner join   cabn as F on E.imerk = F.atinn
    inner join   ausp as G on  C.objek = G.objek
                           and F.atinn = G.atinn
                           and D.klart = G.klart
{
  key A.matnr,
      A.matkl,
      B.maktx,
      G.atwrt as DRM_GUBUN
}

where
      C.klart = '001'
  and F.atnam = 'RL_GA_DRUM_GUBUN'
  
group by
  A.matnr,
  A.matkl,
  B.maktx,
  G.atwrt
