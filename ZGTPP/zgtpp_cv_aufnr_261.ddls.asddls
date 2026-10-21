@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '[GT_PP] 생산오더 261 단건 추출 취소 고려'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTPP_CV_AUFNR_261
  as select from matdoc
{
  aufnr,
  min(mblnr) as mblnr
}
where
      bwart     = '261'
  and cancelled = ''
group by
  aufnr
