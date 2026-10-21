@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '내자입고 정보 전송 최종 I/F Log-MM00009'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_NGR_IF_LOG_R 
as 


select from zgtmmt9000 as A inner join zgtmmt9090 as B on A.zifkey = B.zifkey
                            inner join zgtmmt9092 as C on B.zifkey = C.zifkey and B.vbeln = C.vbeln 
                            inner join zgtmmt9091 as d on B.zifkey = d.zifkey and B.vbeln = d.vbeln
                          
                             
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
        B.vbeln,
        B.lifnr,
        B.lfdat,
        
        d.posnr,
        d.ebeln,
        d.ebelp,
        d.matnr,
        d.seqno,
        d.werks,        
        @Semantics.quantity.unitOfMeasure: 'MEINS'  
        d.lfimg,
        d.meins,
        d.lgort,
        d.charg,
        d.lotno,
        d.tagnr,
        d.hsdat,
        
        C.mblnr,
        C.mjahr,
        C.zresult,
        C.message as CMSG 

} where A.zifno = 'MM00009'
