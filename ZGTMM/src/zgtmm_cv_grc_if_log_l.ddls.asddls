@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '입고 취소 정보 전송 최종 I/F Log-MM00010'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_GRC_IF_LOG_L 
as 
select from ZGTMM_CV_GRC_IF_LOG as A left outer join ZGTMM_CV_GRC_IF_LOG_S as B 
         on A.zifno = B.zifno and A.zifkey = B.zifkey and A.system_id = B.system_id 
       and A.mblnr_i = B.mblnr_i      
       and A.mjahr_i = B.mjahr_i  
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
        A.mblnr_i,
        A.mjahr_i,
        A.mblnr_c,
        A.mjahr_c,        
        cast(A.ZIFNO_N as zgteifname) as ZIFNO_N,  
        case when B.zifkey is not null then cast('X' as zgtemm_lastck)
             else cast('' as zgtemm_lastck) end as lastdata  
} where A.zifno = 'MM00010'
