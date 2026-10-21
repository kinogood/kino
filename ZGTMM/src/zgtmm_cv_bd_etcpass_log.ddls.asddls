@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '[BD] 기타통문 요청 로그'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_BD_ETCPASS_LOG as 
    select from zgtmmt9000 as a inner join zgtmmt6050 as b
                                        on a.zifno = b.zifno
                                       and a.zifkey = b.zifkey
                                       and a.system_id = b.system_id
                           left outer join zlet0005 as c
                                        on b.iv_no = c.iv_no
{
    key a.zifno,
    key a.zifkey,
    key a.system_id,
        a.zstat,
        a.message,
        a.ifdat,
        a.iftim,
        a.ifnam,
        
        b.zgrcd, //E:기타통문, C:취소  
        b.sort_seq,
        b.ifnum,
        b.iv_type, //통문유형
        b.iv_no,
        b.iv_seq,
        
        b.matnr,
        b.maktx,
        @Semantics.quantity.unitOfMeasure: 'mtr_unit'
        b.lfimg,
        b.mtr_unit,        
        b.waers,
        @Semantics.amount.currencyCode: 'waers'
        b.dmbtr,
        
        b.return_chk, //반입여부
        b.werks,
        b.kunnr,
        b.zregp, //등록자
        b.pernr, //사원번호
        b.truck_no,
        b.driver_nm,
        b.driver_telno,
        b.return_due_date,
        b.etc_nm,
        
        c.out_yn,  //통문여부
        c.out_date, //통문일자
        c.cancel_date //통문취소일자
        
} where a.zifno = 'MM00066'
