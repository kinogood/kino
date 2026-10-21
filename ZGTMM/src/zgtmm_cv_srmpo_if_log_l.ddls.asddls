@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'SRM PO 전송 공통 INTERFACE LOG 최종'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_SRMPO_IF_LOG_L 
as
select from ZGTMM_CV_SRMPO_IF_LOG as A left outer join ZGTMM_CV_SRMPO_IF_LOG_S as B 
       on A.zifno = B.zifno and A.zifkey = B.ZIFKEY and A.system_id = B.system_id and A.ebeln = B.ebeln
{
   key  A.zifno,
   key  A.zifkey,
   key  A.system_id,   
        cast(A.ZTARGET_N as zgteifsyst)  as ZTARGET_N, 
   //     A.SYSTEM_ID_N,
        A.zstat,
        A.message,
        A.ifdat,
        A.iftim,
        A.ifnam,
        A.changenr,
        A.ebeln,
        A.ekorg,
        A.ekotx,
        A.ekgrp,
        A.eknam,
        A.bsart,
        A.batxt,
        A.statu,
        A.aedat,
        A.ernam,
        A.fullname,
        A.tel_number,
        A.e_mail,
        A.udate,
        A.utime,
        A.lponr,
        A.lifnr,
        A.name1,
        A.reswk,
        A.reswk_n,
        A.zterm,
        A.text1,
        A.zbd1t,
        A.zbd2t,
        A.zbd3t,
        A.waers,
        A.wkurs,
        A.bedat,
        A.inco1,
        A.bezei,
        A.lands,
        A.memo_h,
        cast(A.ZIFNO_N as zgteifname) as ZIFNO_N,  
        case when B.ZIFKEY is not null then cast('X' as zgtemm_lastck)
             else cast('' as zgtemm_lastck) end as lastdata               
} where A.zifno = 'MM00029'
