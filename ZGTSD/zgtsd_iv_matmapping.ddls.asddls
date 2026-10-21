@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '[GT] 소재 자재 통합  ASIS vs. TOBE 정보'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTSD_IV_MATMAPPING
  as select from zgtppt1010
{
  key fld_01 as SOURCEMATERIAL,
  key fld_03 as TARGETMATERIAL,
  key fld_05 as GRADE
}
where module_kind = 'SD'
  and codegrp = '1002'
