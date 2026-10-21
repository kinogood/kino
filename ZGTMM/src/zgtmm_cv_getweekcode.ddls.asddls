@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '연도 별 주차 조회'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_GETWEEKCODE 
as 
select from scal_tt_week
{
    key CONCAT(calendaryear,calendarweek) as WEEKCODE,
    calendaryear,
    calendarweek,
    calendarquarter,
    calendarmonth
}
