@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'MM Interface List 조회'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_GET_IFLIST 
as select from zgtppt1000 as A inner join zgtppt1010 as B 
             on A.module_kind = B.module_kind and A.codegrp = B.codegrp
{
  key A.module_kind,
  key A.codegrp,
  A.grpdesc,
  B.codeid,
  B.fld_01,
  B.fld_02,
  B.fld_03,
  B.fld_04,
  B.fld_05,
  B.fld_06,
  B.fld_07,
  B.fld_08,
  B.fld_09,
  B.fld_10  
} 
