@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '반품 처리 정보 최종 I/F LOG-MM00019'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_RET_IF_LOG_R 
as 
select from zgtmmt9000 as A inner join zgtmmt9170 as B on A.zifkey = B.zifkey
                             
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
        B.mjahr,        
        B.mblnr,
        B.zeile,
        B.matnr,
        @Semantics.quantity.unitOfMeasure: 'MEINS' 
        B.menge,
        B.meins,
        B.werks,
        B.lgort,
        B.charg,
        B.grund,
        B.mjahr_r,
        B.mblnr_r,
        A.zstat as zresult,
        A.message as CMSG 
} where A.zifno = 'MM00019'
