@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '변경이력 Objectid 조회'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_GETCDHDRID 
with parameters 
    @Consumption.hidden: true
    @Environment.systemField: #SYSTEM_DATE
    p_startdate : vdm_v_start_date,
    p_enddate : vdm_v_end_date,    
    p_diGit : abap.int2,
    P_CLASS : abap.char(15)
as select from cdhdr as A inner join ZGTMM_CV_MAXCDHDR(p_startdate: $parameters.p_startdate ,
                                                       p_enddate : $parameters.p_enddate) as B
                           on A.objectclas = B.objectclas and A.objectid = B.objectid and A.changenr = B.CHANGENR                            
{
    key A.objectclas,
    key left(A.objectid,$parameters.p_diGit) as ID,
    A.changenr,
    A.username, 
    A.udate,
    A.utime
} 
where A.objectclas = $parameters.P_CLASS
