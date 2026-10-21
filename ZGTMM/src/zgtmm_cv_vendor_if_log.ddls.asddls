@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '벤더 정보 전송 I/F Log-MM00001'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_VENDOR_IF_LOG 
as 
select from zgtmmt9000 as A inner join zgtmmt9010 as B on A.zifkey = B.zifkey 
association [1..1] to zgtppt1010 as CM on $projection.zifno = CM.fld_01 and CM.module_kind = 'MM' and CM.codegrp = '0010'
association [1..1] to ZGTMM_CV_GET_IFSYST as SYST on $projection.system_id = SYST.SYST 
{
   key  A.zifno,
   key  A.zifkey,
   key  A.system_id,  
        @EndUserText.label: 'ddd'
        SYST.SYST_N  as ZTARGET_N,    
        A.zstat,
        A.message,
        A.ifdat,
        A.iftim,
        A.ifnam,
        B.changenr,
        B.lifnr,
        B.name1 as lifnr_n,
        CM.fld_02 as ZIFNO_N,
        B.ktokk,
        B.anred,
        B.name1,
        B.name2,
        B.sortl,
        B.ort01,
        B.stras,
        B.pstlz,
        B.land1,
        B.telf1,
        B.smtp_addr,
        B.stcd2,
        B.stcd3,
        B.j_1kfrepre,
        B.j_1kftbus,
        B.j_1kftind,
        B.erdat
    
} where A.zifno = 'MM00001'
