@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '최종 이력 CHANGENO 조회'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_MAXCDHDR 
with parameters 
    @Consumption.hidden: true
    @Environment.systemField: #SYSTEM_DATE
    p_startdate : vdm_v_start_date,
    p_enddate : vdm_v_end_date
as select from cdhdr
{
    key objectclas,
    key objectid,
    max(changenr) as CHANGENR
} where udate >= $parameters.p_startdate and udate <= $parameters.p_enddate 
group by objectclas, objectid
