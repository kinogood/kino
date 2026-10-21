@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '수입입고 정보 Raw data -MM00007'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_IMGR_IF_LOG_R 
as 
select from zgtmmt9000 as A inner join zgtmmt9070 as B on A.zifkey = B.zifkey
                            inner join zgtmmt9072 as C on B.zifkey = C.zifkey and B.iccno = C.iccno 
                            inner join zgtmmt9071 as d on B.zifkey = d.zifkey and B.iccno = d.iccno
                          
                             
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
        B.iccno,
        B.iccsq,
        B.budat,
        
        cast(B.type as zgtegrtype) as TYPE,
        d.iccit,
        d.seqno,
        @Semantics.quantity.unitOfMeasure: 'MEINS'            
        d.grmng,
        d.meins,
        d.lgort,
        d.licnh,
        d.tagnr,
        d.lotno,
        d.charg,
        d.hsdat,
        C.mblnr,
        C.mjahr,
        C.zresult,
        C.message as CMSG 

} where A.zifno = 'MM00007'
