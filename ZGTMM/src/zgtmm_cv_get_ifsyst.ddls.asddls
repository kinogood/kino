@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Interface 대상 시스템 조회'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_GET_IFSYST 
as 
select from zgtppt1010
{    
  key fld_01 as SYST,
      fld_02 as SYST_N

} 
where module_kind = 'PP' and codegrp = '0010'
group by fld_01, fld_02
