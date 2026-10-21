@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'PO 정보 전송 최종 I/F Log-MM00002'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_PO_IF_LOG_L 
as 
select from ZGTMM_CV_PO_IF_LOG as A left outer join ZGTMM_CV_PO_IF_LOG_S as B 
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
        A.bukrs,
        A.BUKRS_N,
        A.ekorg,
        A.EKORG_N,
        A.bsart,
        A.BSART_N,
        A.lifnr,
        A.LIFNR_N,
        A.ekgrp,
        A.EKGRP_N,
        A.zship,
        A.loekz,
        A.statu,
        A.cre_nam,
        A.reswk,
        A.RESWK_N,
        cast(A.ZIFNO_N as zgteifname) as ZIFNO_N,  
        case when B.ZIFKEY is not null then cast('X' as zgtemm_lastck)
             else cast('' as zgtemm_lastck) end as lastdata               
} where A.zifno = 'MM00002'
