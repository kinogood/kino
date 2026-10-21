@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '플랜트/자재/주차 별 표준편차 용 평균'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_GETGISUM_WEEK2 
with parameters 
    @Consumption.hidden: true
    @Environment.systemField: #SYSTEM_DATE
    p_startdate : vdm_v_start_date,
    p_enddate : vdm_v_end_date
as 
select from ZGTMM_CV_GETGISUM_WEEK(p_startdate: $parameters.p_startdate,
                                    p_enddate : $parameters.p_enddate) as A
       inner join ZGTMM_CV_GETGICOL_WEEK(p_startdate: $parameters.p_startdate,
                                    p_enddate : $parameters.p_enddate) as B
       on A.bukrs = B.bukrs and A.werks = B.werks and A.matnr = B.matnr                         
{
    key A.bukrs,
    key A.werks,
    key A.matnr,
    key A.WEEK,
    @Semantics.quantity.unitOfMeasure: 'MEINS' 
    A.MENGE,
    @Semantics.quantity.unitOfMeasure: 'MEINS'
    B.AVERAGE,
    @Semantics.quantity.unitOfMeasure: 'MEINS'        
    (A.MENGE - B.AVERAGE) as STEP1,
    @Semantics.quantity.unitOfMeasure: 'MEINS'
    cast(A.MENGE - B.AVERAGE as abap.fltp) * cast(A.MENGE - B.AVERAGE as abap.fltp)  as STEP2,
    
    A.meins
} group by A.bukrs, A.werks, A.matnr, A.meins, A.MENGE, B.AVERAGE, A.WEEK
