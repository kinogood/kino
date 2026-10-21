@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '플랜트/자재/주차 별 투입 계산'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_GETGICAL_WEEK 

with parameters 
    @Consumption.hidden: true
    @Environment.systemField: #SYSTEM_DATE
    p_startdate : vdm_v_start_date,
    p_enddate : vdm_v_end_date
as select from ZGTMM_CV_GETGICOL_DAILY(p_startdate: $parameters.p_startdate,
                                         p_enddate : $parameters.p_enddate) as A
   inner join ZGTMM_CV_GETGISUM_WEEK3 (p_startdate: $parameters.p_startdate,
                                         p_enddate : $parameters.p_enddate) as B on A.bukrs = B.bukrs and A.werks = B.werks and A.matnr = B.matnr
   inner join ZGTMM_CV_GETMAXLTIME as C on A.bukrs = C.bukrs and A.werks = C.werks and A.matnr = C.matnr
   left outer join ZGTMM_CV_GETPLANTSTOCKVAL as D on A.werks = D.werks and A.matnr = D.matnr  
   association [1..1] to t001 as t001 on $projection.bukrs = t001.bukrs
   association [1..1] to makt as MAKT on $projection.matnr = MAKT.matnr and MAKT.spras = $session.system_language   
   association [1..1] to t001w as T001W on $projection.werks = T001W.werks       
   association [1..1] to zgtmmt4202 as ZGTMMT4202 on // $projection.bukrs = ZGTMMT4202.bukrs and             
   ZGTMMT4202.zuse = 'X'     
{
    key A.bukrs,
    key A.werks,
    key A.matnr,
    t001.butxt as bukrs_n,
    t001w.name1 as werks_n,
    makt.maktx as matnr_n,
    @Semantics.quantity.unitOfMeasure: 'MEINS'     
    case when A.QTY < 0 then cast(0 as abap.quan(13,3))
         else A.QTY  end as GIQTY,
         
    A.meins,         
    C.APLFZ,
    cast(C.APLFZ / 7 as abap.dec(6,3)) as F1,
    A.DAYC,
    A.DAYC / 7  as WEEKC, 
    //cast(0 as abap.dec(4,0)) as WEEKC,
    //cast(A.DAYC / 7 as abap.dec(6,3)) as WEEKC,  
    @Semantics.quantity.unitOfMeasure: 'MEINS' 
    case when A.QTY < 0 then cast(0 as abap.quan(13,3))
         else 
         cast(A.QTY / DATS_DAYS_BETWEEN($parameters.p_startdate,$parameters.p_enddate) as abap.quan(13,3)) 
    end as REQ_DAILY,

    
    @Semantics.quantity.unitOfMeasure: 'MEINS' 
    case when D.UNQTY is null then cast(0 as abap.quan(13,3))
         else D.UNQTY end as UNQTY,                                         // 창고가용재고
    
    @Semantics.quantity.unitOfMeasure: 'MEINS'
    case when D.BDQTY is null then cast(0 as abap.quan(13,3))
         else D.BDQTY end as BONDEDQTY,                // 보세창고재고
    
    @Semantics.quantity.unitOfMeasure: 'MEINS' 
    case when A.QTY < 0 then cast(0 as abap.quan(13,3))
         else 
           cast(A.QTY / DATS_DAYS_BETWEEN($parameters.p_startdate,$parameters.p_enddate) as abap.quan(13,3))  * C.APLFZ
    end as SUQTY,       
    
    @Semantics.amount.currencyCode: 'waers'
    case when D.STOCKVAL is null then cast(0 as salk3)
         else D.STOCKVAL end as STOCKVAL,                  // 현 재고 금액
    D.waers,

    zgtmmt4202.factor,
    @Semantics.quantity.unitOfMeasure: 'MEINS'      
    B.LASTAVG

}
