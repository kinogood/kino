@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'BL 변경 정보 집계-MM00003'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_CHANGEDBL_T 
with parameters 
    @Consumption.hidden: true
    @Environment.systemField: #SYSTEM_DATE
    p_startdate : vdm_v_start_date,
    p_enddate : vdm_v_end_date   
 as 

 select from  ztitblk as B 
        inner join ztitblp as C on B.iblno = C.iblno   
        left outer join ZGTMM_CV_BL_IF_LOG_L as d 
               on d.iblno = C.iblno and d.iblit = C.iblit
             and  d.blnum = B.blnum
             and  d.ebeln = C.ebeln
             and  d.ebelp = C.ebelp
             and  d.bukrs = B.bukrs
             and  d.matnr = C.matnr
             and  d.blmng = C.blmng
             and  d.meins = C.meins
             and  d.rptty = B.rptty
             and  d.lastdata = 'X'
             and  d.zstat = 'S'     
        left outer join ZGTMM_CV_BLGRQTY_SUM as E 
             on C.iblno = E.iblno and C.iblit = E.iblit      
                                     
{
 key  C.iblno,      //   " B/L 관리번호
      C.iblit,      //   " B/L 품목번호
      B.blnum,      //  " B/L 번호
      B.lifnr,
      B.werks,
      C.ebeln,      //   " 구매 문서 번호
      C.ebelp,      //   " 구매 문서 품목 번호
      B.bukrs,      //   " 회사 코드
      B.ekorg,
      C.matnr,      //   " 자재 번호
      C.txz01,      //   " 내역
      @Semantics.quantity.unitOfMeasure: 'MEINS'      
      C.blmng,      //   " B/L 수량
      C.meins,      //   " 기본 단위
      B.rptty,      //   " 수입신고 구분
    /*  A.changenr,   
      A.udate,
      A.utime,
      A.username  */
      cast('' as cdchangenr) as changenr,
      B.udat as udate,
      B.utme as utime,
      B.unam as username,
      case when d.iblno is not null then cast('X' as zgtedupchk)
      else cast('' as zgtedupchk)  end as dup,
      @Semantics.quantity.unitOfMeasure: 'MEINS'         
      E.QTY,
      case when E.iblno is not null then
                case when C.blmng <= E.QTY then cast('X' as abap.char(1))
                     else cast('' as abap.char(1)) end
           else cast('' as abap.char(1))         
           end as GRCHECK 
       
} where (B.cdat >= $parameters.p_startdate and B.cdat <= $parameters.p_enddate) or (B.udat >= $parameters.p_startdate and B.udat <= $parameters.p_enddate)

