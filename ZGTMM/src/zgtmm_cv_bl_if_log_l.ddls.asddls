@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'BL 정보 전송 최종 I/F Log-MM00003'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_BL_IF_LOG_L 
as 
select from ZGTMM_CV_BL_IF_LOG as A left outer join ZGTMM_CV_BL_IF_LOG_S as B 
       on A.zifno = B.zifno and A.zifkey = B.zifkey and A.system_id = B.system_id 
       and A.iblno = B.iblno      
       and A.bukrs = B.bukrs
       and A.blnum = B.blnum  
        
       
{
   key  A.zifno,
   key  A.zifkey,
   key  A.system_id,    
        cast(A.ZTARGET_N as zgteifsyst)  as ZTARGET_N, 
        A.zstat,
        A.message,
        A.ifdat,
        A.iftim,
        A.ifnam,
        A.changenr,
        A.bukrs,
        A.BUKRS_N,
        A.iblno,
        A.blnum,
        cast(A.ZIFNO_N as zgteifname) as ZIFNO_N,  
        A.iblit,
        A.ebeln,
        A.ebelp,
        A.matnr,
        A.txz01,
        @Semantics.quantity.unitOfMeasure: 'MEINS'
        A.blmng,
        A.meins,
        A.rptty,        
        case when B.zifkey is not null then cast('X' as zgtemm_lastck)
             else cast('' as zgtemm_lastck) end as lastdata  
} where A.zifno = 'MM00003'

