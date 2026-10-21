@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '기타 수불 정보 전송 최종 I/F Log-MM00011'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_EMVT_IF_LOG_R 
as 
select from zgtmmt9000 as A inner join zgtmmt9110 as B on A.zifkey = B.zifkey
                            inner join zgtmmt9111 as C on B.zifkey = C.zifkey and B.ifnum = C.ifnum
                             
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
        B.ifnum,
        B.mblnr,
        B.mjahr,
        B.bldat,
        B.budat,
        B.bktxt,
        B.flag,
        B.matnr,
        B.ummat,
        @Semantics.quantity.unitOfMeasure: 'ERFME'  
        B.erfmg,
        B.erfme,
        B.charg,
        B.umcha,
        B.werks,
        B.lgort,
        B.r_werks,
        B.r_lgort,
        B.bwart,
        B.kostl,
        B.aufnr,
        B.ps_posid,
        B.kdauf,
        B.kdpos,
        B.lifnr, 
        B.kunnr,
        B.sgtxt,

        C.mblnr as MBLNR_N,
        C.mjahr as MJAHR_N,
        C.mblnr_c,
        C.mjahr_c,
        C.zresult,
        C.message as CMSG ,
        C.tagnr

} where A.zifno = 'MM00011'
