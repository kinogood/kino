@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '예약 정보 전송 I/F Log-MM00006'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_RES_IF_LOG 
as
select from zgtmmt9000 as A inner join zgtmmt9060 as B on A.zifkey = B.zifkey

association [0..1] to t001w as T001W on $projection.werks = T001W.werks
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
        B.rsnum,
        B.werks,
        t001w.name1 as WERKS_N,
        B.bwart,
        CM.fld_02 as ZIFNO_N,
        B.rspos,

        B.rsdat,
        B.bdart,
        B.wempf,
        
        B.xwaok,
        B.kzear,
        B.xloek,
        B.matnr,
        
        B.lgort,
        B.umwrk,
        B.umlgo,
        B.erfme,
        @Semantics.quantity.unitOfMeasure: 'ERFME'
        B.bdmng,
        @Semantics.quantity.unitOfMeasure: 'ERFME'
        B.enmng

} where A.zifno = 'MM00006'
