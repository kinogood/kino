@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '전자세금계산서 접수 정보 조회'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_GET_TAX_INVOICE 
as select from zdtv3t_ap_head as A inner join lfa1 as B on A.su_id = B.stcd2
                                   inner join lfb1 as C on B.lifnr = C.lifnr and A.bukrs = C.bukrs
                                   
association [0..1] to ZGTMM_CV_GET_AP_CLEARING as iv on $projection.bukrs = iv.bukrs and $projection.inv_seq = iv.sgtxt                                     
{
    key A.bukrs,
    key A.issue_date,
    key A.bupla,
    key A.issue_id as inv_seq,
     LEFT(A.issue_date,6) as PERIOD,
     B.lifnr,
     B.name1,
     A.inter_no,
     A.inv_sign,
     A.asp_code,
     A.type_code,
     A.purp_code,
     A.amend_code,
     A.desc_text1,
     A.desc_text2,
     A.desc_text3,
     A.su_id,
     A.su_min,
     A.su_name,
     A.su_repres,
     A.su_addr,
     A.su_bustype,
     A.su_indtype,
     A.su_deptname,
     A.su_persname,
     A.su_telno,
     A.su_hpno,
     A.su_email,
     A.ip_typecode,
     A.ip_id,
     A.ip_min,
     A.ip_name,
     A.ip_repres,
     A.ip_addr,
     A.ip_bustype,
     A.ip_indtype,
     A.ip_deptname1,
     A.ip_persname1,
     A.ip_telno1,
     A.ip_hpno1,
     A.ip_email1,
     A.ip_deptname2,
     A.ip_persname2,
     A.ip_telno2,
     A.ip_hpno2,
     A.ip_email2,
     A.bp_id,
     A.bp_min,
     A.bp_name,
     A.bp_repres,
     A.bp_addr,
     A.bp_bustype,
     A.bp_indtype,
     A.bp_deptname,
     A.bp_persname,
     A.bp_telno,
     A.bp_hpno,
     A.bp_email,
     @Semantics.amount.currencyCode: 'waers'       
     A.chargetotal,
     @Semantics.amount.currencyCode: 'waers'
     A.taxtotal,
     @Semantics.amount.currencyCode: 'waers'
     A.grandtotal,
     cast('KRW' as abap.cuky) as WAERS,
     A.issue_dt,
     A.issue_id,
     A.status,
     A.proc_step,
     A.aspid,
     A.asppw,
     A.nts_send_flag,
     A.open_flag,
     A.interface_no,
     A.aedat,
     A.aezei,
     A.aeusn,
     A.erdat,
     A.erzet,
     A.ernam,
     case when iv.sgtxt is null then cast('' as abap.char(1) ) 
           else cast('X' as abap.char(1)) end as TAXINV
} where A.status <> '2777' and A.status <> '2999'
