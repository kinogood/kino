@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '구매 오더 접수/반려 정보 수신'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZGTMM_CV_ACKN_IF_LOG_R 
as
select from zgtmmt9000 as A inner join zgtmmt9240 as B on A.zifkey = B.zifkey
                          
                             
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
        B.ekorg,
        B.ebeln,
        B.zconfirm
} where A.zifno = 'MM00025'
