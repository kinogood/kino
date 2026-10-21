@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'BL 변경 정보 조회-MM00003'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_CHANGEDBL 
with parameters 
    @Consumption.hidden: true
    @Environment.systemField: #SYSTEM_DATE
    p_startdate : vdm_v_start_date,
    p_enddate : vdm_v_end_date   
 as 
         
 select from  ZGTMM_CV_CHANGEDBL_T(p_startdate: $parameters.p_startdate ,
                                 p_enddate : $parameters.p_enddate)  
                                     
{
 key  iblno,      //   " B/L 관리번호
      iblit,      //   " B/L 품목번호
      blnum,      //  " B/L 번호
      lifnr,
      werks,
      ebeln,      //   " 구매 문서 번호
      ebelp,      //   " 구매 문서 품목 번호
      bukrs,      //   " 회사 코드
      ekorg,
      matnr,      //   " 자재 번호
      txz01,      //   " 내역
      @Semantics.quantity.unitOfMeasure: 'MEINS'      
      blmng,      //   " B/L 수량
      meins,      //   " 기본 단위
      rptty,      //   " 수입신고 구분
      changenr,
      udate,
      utime,
      username, 
      dup,
      @Semantics.quantity.unitOfMeasure: 'MEINS'         
      QTY 
      
} where GRCHECK = ''

