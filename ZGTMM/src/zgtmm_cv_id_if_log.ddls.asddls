@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '납품 정보 전송 I/F Log-MM00005'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_ID_IF_LOG 
as 
select from zgtmmt9000 as A inner join zgtmmt9050 as B on A.zifkey = B.zifkey
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
        B.vbeln,
        B.lifnr,
        lfa1.name1 as LIFNR_N,
        B.erdat,
        B.werks,
        B.lfdat,
        B.zdflg,
        CM.fld_02 as ZIFNO_N
        

} where A.zifno = 'MM00005'
