@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '단가 정보 수신 LOG-MM00024 IF LOG'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZGTMM_CV_INFO_IF_LOG_R 
as 
select from zgtmmt9000 as A inner join zgtmmt9230 as B on A.zifkey = B.zifkey
                            inner join zgtmmt9231 as C on B.zifkey = C.zifkey 
                            inner join zgtmmt9232 as d on B.zifkey = d.zifkey and C.werks = d.werks
                            inner join mara as E on B.matnr = E.matnr
                          
                             
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
        B.matnr,
        B.lifnr,
        B.ekorg,
        B.esokz,
        B.waers,
        B.datab,
        B.datbi,
        @Semantics.amount.currencyCode: 'WAERS'   
        B.netpr,
        B.peinh,
        B.bprme,
        B.ekgrp,
        C.werks,
        C.aplfz,
        C.uebto,
        C.untto,
        C.uebtk,
        C.kzabs,
        C.bstae,
        C.webre,
        @Semantics.quantity.unitOfMeasure: 'MEINS' 
        C.norbm,
        @Semantics.quantity.unitOfMeasure: 'MEINS' 
        C.minbm,
        E.meins,
        C.mwskz,
        C.meprf,
        C.inco1,
        @Semantics.amount.currencyCode: 'WAERS'
        d.rq_raw_sum,
        @Semantics.amount.currencyCode: 'WAERS'        
        d.mat_cost,
        @Semantics.amount.currencyCode: 'WAERS'
        d.pak_cost,
        @Semantics.amount.currencyCode: 'WAERS'
        d.mfg_cost,
        @Semantics.amount.currencyCode: 'WAERS'
        d.pre_fee,
        @Semantics.amount.currencyCode: 'WAERS'
        d.others
} where A.zifno = 'MM00024'
