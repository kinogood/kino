@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'BL 정보 전송 I/F Log-MM00003'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_BL_IF_LOG 
as 
select from zgtmmt9000 as A inner join zgtmmt9030 as B on A.zifkey = B.zifkey

association [1..1] to t001 as T001 on $projection.bukrs = T001.bukrs
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
        B.bukrs, 
        t001.butxt as BUKRS_N,
        B.iblno,
        B.iblit,
        B.blnum,
        B.ebeln, 
        B.ebelp,
        B.matnr,
        B.txz01,
        @Semantics.quantity.unitOfMeasure: 'MEINS'
        B.blmng,
        B.meins,
        B.rptty,
        CM.fld_02 as ZIFNO_N

} where A.zifno = 'MM00003'
