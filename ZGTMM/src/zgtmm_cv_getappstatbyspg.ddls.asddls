@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'GT 기능 적용 상태 조회'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_GETAPPSTATBYSPG 
as 
select from zgtmmt1000

association [1..1] to t001 as Company on $projection.bukrs = Company.bukrs  
association [1..1] to t001w as T001W on $projection.werks = T001W.werks
association [1..1] to dd07t as TYPE on $projection.ztype = TYPE.domvalue_l and TYPE.domname = 'ZGTDMMTYPE' and TYPE.ddlanguage = $session.system_language
{
 key bukrs, 
 key werks,
 key ztype,
     Company.butxt,
     t001w.name1 as PLANTNAME,
     TYPE.ddtext as TYPENAME,
     zuse,
     erdat,
     erdat_local,
     ertim,
     ertim_local,
     ernam,
     aedat,
     aedat_local,
     aetim,
     aetim_local,
     aenam
} 
