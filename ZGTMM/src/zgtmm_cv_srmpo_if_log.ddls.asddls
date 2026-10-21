@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'SRM PO 전송 공통 INTERFACE LOG BASE'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_SRMPO_IF_LOG 
as 
select from zgtmmt9000 as A inner join zgtmmt9430 as B on A.zifkey = B.zifkey
association [1..1] to zgtppt1010 as CM on $projection.zifno = CM.fld_01 and CM.module_kind = 'MM' and CM.codegrp = '0010'
association [1..1] to ZGTMM_CV_GET_IFSYST as SYST on $projection.system_id = SYST.SYST   
{
   key  A.zifno,
   key  A.zifkey,
   key  A.system_id,   
        SYST.SYST_N as ZTARGET_N,
        SYST.SYST_N as SYSTEM_ID_N,
        A.zstat,
        A.message,
        A.ifdat,
        A.iftim,
        A.ifnam,
        B.changenr,
        B.ebeln,
        B.ekorg,
        B.ekotx,
        B.ekgrp,
        B.eknam,
        B.bsart,
        B.batxt,
        B.statu,
        B.aedat,
        B.ernam,
        B.fullname,
        B.tel_number,
        B.e_mail,
        B.udate,
        B.utime,
        B.lponr,
        B.lifnr,
        B.name1,
        B.reswk,
        B.reswk_n,
        B.zterm,
        B.text1,
        B.zbd1t,
        B.zbd2t,
        B.zbd3t,
        B.waers,
        B.wkurs,
        B.bedat,
        B.inco1,
        B.bezei,
        B.lands,
        B.memo_h,        
        CM.fld_02 as ZIFNO_N

}
