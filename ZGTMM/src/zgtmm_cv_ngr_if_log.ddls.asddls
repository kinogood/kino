@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '내자입고 정보 전송 I/F Log-MM00009'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_NGR_IF_LOG 
as 
select from zgtmmt9000 as A inner join zgtmmt9090 as B on A.zifkey = B.zifkey
                            inner join zgtmmt9092 as C on B.zifkey = C.zifkey and B.vbeln = C.vbeln
association [0..1] to lfa1 as lfa1 on $projection.lifnr = lfa1.lifnr
association [1..1] to zgtppt1010 as CM on $projection.zifno = CM.fld_01 and CM.module_kind = 'MM' and CM.codegrp = '0010'
association [1..1] to ZGTMM_CV_GET_IFSYST as SYST on $projection.system_id = SYST.SYST 
{
   key  A.zifno,
   key  A.zifkey,
   key  A.system_id,       
        SYST.SYST_N as ZTARGET_N,
        A.zstat,
        A.message,
        A.ifdat,
        A.iftim,
        A.ifnam,
        B.vbeln,
        B.lifnr,
        lfa1.name1 as LIFNR_N,
        B.lfdat,
        C.mblnr,
        C.mjahr,
        C.zresult,
        C.message as CMSG,
        CM.fld_02 as ZIFNO_N

} where A.zifno = 'MM00009'
