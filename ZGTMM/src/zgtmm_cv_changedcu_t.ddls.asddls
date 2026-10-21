@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '통관 변경 정보집계-rP-MM00004'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_CHANGEDCU_T 
with parameters 
    @Consumption.hidden: true
    @Environment.systemField: #SYSTEM_DATE
    p_startdate : vdm_v_start_date,
    p_enddate : vdm_v_end_date   
 as 
       
 select from  ztitccp as B  
       inner join ztitcck as C on B.iccno = C.iccno and B.iccsq  = C.iccsq
       inner join ztitblp as D on B.iblno = D.iblno and B.iblit = D.iblit
       inner join ztitblk as E on D.iblno = E.iblno             
       left outer join ZGTMM_CV_CU_IF_LOG_L as f 
              on  f.iccno = B.iccno
              and f.iccsq = B.iccsq
              and f.iccit = B.iccit
              and f.ebeln = B.ebeln
              and f.ebelp = B.ebelp
              and f.cdcno = C.cdcno
              and f.bukrs = C.bukrs
              and f.matnr = D.matnr
              and f.ccmng = B.ccmng
              and f.meins = B.meins
              and f.blnum = E.blnum
              and f.iblno = B.iblno
              and f.iblit = B.iblit
              and f.cdrdt = C.cdrdt
              and  f.lastdata = 'X'
              and  f.zstat = 'S'            
              left outer join ZGTMM_CV_CUGRQTY_SUM as G 
              on B.iccno = G.iccno and B.iccit = G.iccit                                        
{
 key  B.iccno,//                " 통관 관리 번호
      cast(B.iccsq as abap.char(2)) as iccsq,//                " 수입신고 차수
      B.iccit,//                " 수입신고 Items No.
      B.ebeln,//                " 구매 문서
      B.ebelp,//                " 구매 문서 품목
      C.cdcno,//                " 수입신고필증
      C.bukrs,//                " 회사코드
      C.werks, 
      C.ekorg,
      C.lifnr,
      D.matnr,//                " 자재 번호
      D.txz01,//                " 자재 내역
      @Semantics.quantity.unitOfMeasure: 'MEINS'      
      B.ccmng,//                " 통관 수량
      B.meins,//                " 기본 단위
      E.blnum,//                " B/L 번호
      B.iblno,//                " B/L 관리번호
      B.iblit,//                " B/L 품목번호
      C.cdrdt,//             "신고일
      cast('' as cdchangenr) as changenr,
      B.cdat as udate,
      B.ctme as utime,
      B.unam as username,
      case when f.iblno is not null then cast('X' as zgtedupchk)
      else cast('' as zgtedupchk)  end as dup, 
      @Semantics.quantity.unitOfMeasure: 'MEINS'        
      G.QTY,
      case when G.iccno is not null then
                case when B.ccmng <= G.QTY then cast('X' as abap.char(1))
                     else cast('' as abap.char(1)) end
           else cast('' as abap.char(1))         
           end as GRCHECK            
} where (B.cdat >= $parameters.p_startdate and B.cdat <= $parameters.p_enddate) or (C.cdat >= $parameters.p_startdate and C.cdat <= $parameters.p_enddate)
