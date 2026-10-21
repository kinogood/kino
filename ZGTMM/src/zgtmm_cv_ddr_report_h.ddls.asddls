@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '직송의뢰 현황 조회 헤더'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_DDR_REPORT_H 
as select from zgtmmt4410 as A inner join ZGTMM_CV_GET_SO_DDR as b on A.bukrs = b.bukrs and A.dlvrq = b.dlvrq
association [0..1] to tvkbt as TVKBT on $projection.vkbur = TVKBT.vkbur and TVKBT.spras = $session.system_language
association [0..1] to tvgrt as TVGRT on $projection.vkgrp = TVGRT.vkgrp and TVGRT.spras = $session.system_language
association [0..1] to kna1 as kna1 on $projection.kunnr = kna1.kunnr
association [0..1] to ZGTMM_CV_DDR_QTY_SUM1 as Q1 on $projection.bukrs = Q1.bukrs and $projection.dlvrq = Q1.dlvrq
association [0..1] to ZGTMM_CV_DDR_QTY_SUM2 as Q2 on $projection.bukrs = Q2.bukrs and $projection.dlvrq = Q2.dlvrq
association [0..1] to ZGTMM_CV_DDR_QTY_SUM3 as Q3 on $projection.bukrs = Q3.bukrs and $projection.dlvrq = Q3.dlvrq
association [0..1] to ZGTMM_CV_DDR_QTY_TRUCK  as Q9 on $projection.bukrs = Q9.bukrs and $projection.dlvrq = Q9.dlvrq
association [0..1] to ZGTMM_CV_DDR_SUM_TRUCK2  as Q10 on $projection.bukrs = Q10.bukrs and $projection.dlvrq = Q10.dlvrq
association [0..1] to ZGTMM_CV_DDR_QTY_SUM6 as Q6 on $projection.bukrs = Q6.bukrs and $projection.dlvrq = Q6.dlvrq
association [0..1] to ZGTMM_CV_DDR_QTY_QI1  as QI1 on $projection.bukrs = QI1.bukrs and $projection.dlvrq = QI1.dlvrq
association [0..1] to ZGTMM_CV_DDR_QTY_QI2  as QI2 on $projection.bukrs = QI2.bukrs and $projection.dlvrq = QI2.dlvrq  
association [0..1] to ZGTMM_CV_DDR_QTY_SUM4  as Q11 on $projection.bukrs = Q11.bukrs and $projection.dlvrq = Q11.dlvrq 
association [0..1] to ZGTMM_CV_DDR_QTY_SUM5  as Q12 on $projection.bukrs = Q12.bukrs and $projection.dlvrq = Q12.dlvrq   
  
association [0..1] to dd07t as DD1 on $projection.zreq_type = DD1.domvalue_l and DD1.domname = 'ZGTD_REQTYPE' and DD1.ddlanguage = $session.system_language
association [0..1] to t005u as T005U on $projection.bland = T005U.bland and T005U.spras = $session.system_language and T005U.land1 = 'KR'
{
 key    A.bukrs,
 key    A.zreq_type,
        DD1.ddtext as zreq_name,
        A.dlvrq,
        b.VBELN,
        A.werks,
        A.vkbur,
        tvkbt.bezei as vkbur_n,        
        A.vkgrp,
        tvgrt.bezei as vkgrp_n,        
        A.kunnr,
        kna1.name1 as cname,        
        A.reqdate,
        A.ar_date,
        A.ar_time,
        Q1.REQ_COUNT as Q1,   //직송의뢰수량
        Q2.REQ_COUNT as Q2,   //직송접수량(구매)
        Q3.REQ_COUNT as Q3,   //직송접수량(업체)    
        QI1.QI_REQ_QTY as Q4, //품질접수건수
        QI2.QI_REQ_QTY as Q5, //품질검사건수        
        cast( '' as iconname ) as q7,
     
        Q6.REQ_COUNT as Q6, //반려
        Q9.LOADQTY as  Q9, //배차수량
        Q10.LOADQTY as Q10, //거래명세서발행

        cast( '' as iconname ) as q8,          
        Q11.REQ_COUNT as Q11, //구매확인
        Q12.REQ_COUNT as Q12, //입고처리       
        case when Q10.LOADQTY is not null then 
          case when Q11.REQ_COUNT is not null then
                 case when (Q10.LOADQTY <= Q11.REQ_COUNT) or Q10.LOADQTY = 0 then cast('X' as abap.char(1))
                 else cast('' as abap.char(1)) end 
               else cast('' as abap.char(1)) end
          else cast('X' as abap.char(1)) end as checkmm,
        A.bland,
        t005u.bezei as BLAND_N,        
        A.city1,
        A.dest1,
        A.site_name,
        A.site_tel,
        A.cust_name,
        A.cust_tel,
        A.dest2,
        A.sp_note,
        A.zsd_stat,
        A.zdesc,
        A.pernr,
        A.name,
        A.email,
        A.erdat,
        A.erdat_local,
        A.ertim,
        A.ertim_local,
        A.ernam,
        case when Q10.LOADQTY is not null then
             case when Q12.REQ_COUNT is not null then
               case when Q10.LOADQTY > Q12.REQ_COUNT then cast('X' as abap.char(1))
                    else cast('' as abap.char(1)) end
               else cast('X' as abap.char(1)) end
            else cast('' as abap.char(1))
            end as grqty   
} where A.zsd_stat = 'R'
