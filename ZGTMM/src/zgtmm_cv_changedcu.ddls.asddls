@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '통관 변경 정보 조회-MM00004'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_CHANGEDCU 
with parameters 
    @Consumption.hidden: true
    @Environment.systemField: #SYSTEM_DATE
    p_startdate : vdm_v_start_date,
    p_enddate : vdm_v_end_date   
 as 

 select from  ZGTMM_CV_CHANGEDCU_T(p_startdate: $parameters.p_startdate ,
                                 p_enddate : $parameters.p_enddate)                                        
{
 key  iccno,//                " 통관 관리 번호
      iccsq,//                " 수입신고 차수
      iccit,//                " 수입신고 Items No.
      ebeln,//                " 구매 문서
      ebelp,//                " 구매 문서 품목
      cdcno,//                " 수입신고필증
      bukrs,//                " 회사코드
      werks,
      ekorg,
      lifnr,
      matnr,//                " 자재 번호
      txz01,//                " 자재 내역
      @Semantics.quantity.unitOfMeasure: 'MEINS'      
      ccmng,//                " 통관 수량
      meins,//                " 기본 단위
      blnum,//                " B/L 번호
      iblno,//                " B/L 관리번호
      iblit,//                " B/L 품목번호
      cdrdt,//             "신고일
      
      changenr, 
      udate, 
      utime,
      username,
      dup,
      @Semantics.quantity.unitOfMeasure: 'MEINS'        
      QTY          
} where GRCHECK  = ''
