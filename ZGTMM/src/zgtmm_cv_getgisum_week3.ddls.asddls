@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '플랜트/자재/주차 별 표준편차 용 평균'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_GETGISUM_WEEK3 

with parameters 
    @Consumption.hidden: true
    @Environment.systemField: #SYSTEM_DATE
    p_startdate : vdm_v_start_date,
    p_enddate : vdm_v_end_date
as 
select from ZGTMM_CV_GETGISUM_WEEK2(p_startdate: $parameters.p_startdate,
                                    p_enddate : $parameters.p_enddate)                    
{
    key $session.client as CLNT, 
    key bukrs,
    key werks,
    key matnr,

    @Semantics.quantity.unitOfMeasure: 'MEINS' 
    fltp_to_dec(avg(STEP2 as abap.fltp) as abap.dec(26,3)) as LASTAVG,
    meins
} group by bukrs, werks, matnr, meins
