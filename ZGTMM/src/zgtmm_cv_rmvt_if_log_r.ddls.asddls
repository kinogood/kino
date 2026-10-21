@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '예약 수불 정보 전송 최종 I/F Log-MM00012'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_RMVT_IF_LOG_R 
as
select from zgtmmt9000 as A inner join zgtmmt9120 as B on A.zifkey = B.zifkey
                            inner join zgtmmt9121 as C on B.zifkey = C.zifkey and B.rsnum = C.rsnum and B.rspos = C.rspos                          
                             
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
        B.rsnum,
        B.rspos,
        B.charg,
        B.budat,
        
        @Semantics.quantity.unitOfMeasure: 'MEINS'  
        B.erfmg,
        B.meins,
        B.kzear,
        B.sgtxt,
        
        C.mblnr,
        C.mjahr,
        C.zresult,
        C.message as CMSG 
} where A.zifno = 'MM00012'
