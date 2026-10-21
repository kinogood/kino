@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '판매계획 최종 수립일'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTPP_CV_SALESPLAN_MAXWEEK as select from zsdt_d365_021
{
    key cycltype,
    key vkbur,
    key itemname,
    key zpjno,
    key spart,
    
    --판매계획 Key에 대한 최종 판매수립일
    max(week) as maxw
}
group by cycltype, vkbur, itemname, zpjno, spart
