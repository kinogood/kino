@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '플랜트/자재/주차 별 투입 집계'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_GETGILIST_WEEK 
with parameters 
    @Consumption.hidden: true
    @Environment.systemField: #SYSTEM_DATE
    p_startdate : vdm_v_start_date,
    p_enddate : vdm_v_end_date
as 


select from matdoc as A 
       inner join zgtmmt4200 as B on  A.werks = B.werks and A.bwart = B.bwart and A.shkzg = B.shkzg
       inner join marc as C on A.werks = C.werks and A.matnr = C.matnr  
       inner join ZGTMM_CV_INFOMAT as D on C.matnr = D.matnr and C.werks = D.werks
{
    key A.bukrs,
    key A.werks,
    key A.matnr,
    key A.yearweek_budat as WEEK,
    
    @Semantics.quantity.unitOfMeasure: 'MEINS'        
    sum(A.stock_qty * -1) as MENGE,
    A.meins
    //DATS_DAYS_BETWEEN($parameters.p_startdate,$parameters.p_enddate) as DCOUNT
} where A.budat between $parameters.p_startdate and $parameters.p_enddate and A.lgort_sid <> '' and C.beskz <> 'E' 
group by A.bukrs, A.werks, A.matnr, A.meins,A.year_budat, A.yearweek_budat

union

select from matdoc as A 
       inner join zgtmmt4200 as B on  A.werks = B.werks and A.bwart = B.bwart and A.shkzg = B.shkzg
       inner join ZGTMM_CV_GETWEEKCODE as c on A.year_budat = c.calendaryear
       inner join marc as D on A.werks = D.werks and A.matnr = D.matnr  
       inner join ZGTMM_CV_INFOMAT as e on D.matnr = e.matnr and D.werks = e.werks
{
    key A.bukrs,
    key A.werks,
    key A.matnr,
    key c.WEEKCODE as WEEK,
    
    0 as MENGE,
    A.meins
    //DATS_DAYS_BETWEEN($parameters.p_startdate,$parameters.p_enddate) as DCOUNT
} where A.budat between $parameters.p_startdate and $parameters.p_enddate and A.lgort_sid <> '' and D.beskz <> 'E' 
group by A.bukrs, A.werks, A.matnr, A.meins, c.WEEKCODE 

