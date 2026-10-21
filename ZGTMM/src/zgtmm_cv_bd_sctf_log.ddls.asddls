@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '[BD] 사급자재 출고 수신 로그 - MM00065'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_BD_SCTF_LOG as 
  select from zgtmmt9000 as a inner join zgtmmt6040 as b
                                      on a.zifno = b.zifno
                                     and a.zifkey = b.zifkey
                                     and a.system_id = b.system_id
                         left outer join makt as m
                                      on b.matnr = m.matnr
                                    and m.spras = $session.system_language
                         left outer join lfa1 as l
                                      on b.lifnr = l.lifnr
{
    key a.zifno,
    key a.zifkey,
    key a.system_id,
        a.zstat,
        a.message,
        a.ifdat,
        a.iftim,
        a.ifnam,
        
        b.zgrcd, //T:이전전기, C:취소
        b.lifnr, //공급업체
        l.name1, //이름
        b.budat, //전기일자
        
        b.matnr,
        m.maktx,
        @Semantics.quantity.unitOfMeasure: 'meins'
        b.lfimg,
        b.meins,
        b.vbeln,
        b.vbelp,
        b.pschk, //통문증 발행대상
        b.werks,
        b.lgort,
        b.charg,
        
        b.bldat, //증빙일자
        b.lfsnr, //외부납품서번호
        b.bktxt, //문서 헤더 텍스트
        b.smbln,
        b.sjahr,
        
        b.reqst, //통문처리 요청
        b.iv_no, //통문번호
        b.pernr,
        b.etc_nm,
        b.driver_nm,
        b.driver_telno,
        b.truck_no,        
        
        b.mblnr, //자재문서
        b.mjahr //자재문서 연도  
        
} where a.zifno = 'MM00065'
