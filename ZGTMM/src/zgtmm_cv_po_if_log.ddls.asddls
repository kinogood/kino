@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'PO 정보 전송 I/F Log-MM00002'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_PO_IF_LOG 
as
select from zgtmmt9000 as A inner join zgtmmt9020 as B on A.zifkey = B.zifkey
association [1..1] to t001 as T001 on $projection.bukrs = T001.bukrs
association [0..1] to t001w as T001W on $projection.reswk = T001W.werks
association [1..1] to t024e as T024E on $projection.ekorg = T024E.ekorg  
association [1..1] to t024 as T024 on $projection.ekgrp = T024.ekgrp  
association [1..1] to t161t as T161T on $projection.bsart = T161T.bsart and T161T.bstyp = 'F' and T161T.spras = $session.system_language
association [1..1] to lfa1 as LFA1 on $projection.lifnr = LFA1.lifnr    
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
        B.bukrs,
        t001.butxt as BUKRS_N,
        B.ekorg,
        t024e.ekotx as EKORG_N,
        B.bsart,
        t161t.batxt as BSART_N,
        B.lifnr,
        lfa1.name1 as LIFNR_N,
        B.ekgrp,
        t024.eknam as EKGRP_N,
        B.zship,
        B.loekz,
        B.statu,
        B.cre_nam,
        B.reswk,
        t001w.name1 as RESWK_N,
        CM.fld_02 as ZIFNO_N

} where A.zifno = 'MM00002'
