@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'UNIT 환산 계수 리스트'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_UNIT_FACTOR 
as 
select from t006 as A left outer join t006d as B on A.dimid = B.dimid 
{
    key A.dimid,
    key A.msehi as UNIT,
    A.zaehl,
    A.nennr,
    B.mssie as SIUNIT
}
