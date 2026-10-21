@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '입고 취소 정보 전송 최종 I/F Log-MM00010'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_GRC_IF_LOG_R 
as 
select from zgtmmt9000 as A inner join zgtmmt9100 as B on A.zifkey = B.zifkey
                          
                             
association [1..1] to zgtppt1010 as CM on $projection.zifno = CM.fld_01 and CM.module_kind = 'MM' and CM.codegrp = '0010'
association [1..1] to ZGTMM_CV_GET_IFSYST as SYST on $projection.system_id = SYST.SYST 
{
   key  A.zifno,
   key  cast(CM.fld_02 as zgteifname) as ZIFNO_N,       
   key  A.zifkey,
   key  A.system_id,  
        cast(SYST.SYST_N as zgteifsyst) as ZTARGET_N,
        A.zstat,
        A.message,
        A.ifdat,
        A.iftim,
        A.ifnam,
        B.mblnr_i,
        B.mjahr_i,
        B.mblnr_c,
        B.mjahr_c,
        B.zresult,
        B.message as CMSG 
} where A.zifno = 'MM00010'
