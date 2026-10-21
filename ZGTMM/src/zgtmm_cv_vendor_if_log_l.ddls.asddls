@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '벤더 정보 전송 최종 I/F Log-MM00001'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_VENDOR_IF_LOG_L 
as 
select from ZGTMM_CV_VENDOR_IF_LOG as A 
       left outer join ZGTMM_CV_VENDOR_IF_LOG_S as B 
       on A.zifno = B.zifno and A.zifkey = B.zifkey and A.system_id = B.system_id and A.lifnr = B.lifnr        
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
        A.lifnr,
        A.lifnr_n,
        cast(A.ZIFNO_N as zgteifname) as ZIFNO_N,    
        A.ktokk,
        A.anred,
        A.name1,
        A.name2,
        A.sortl,
        A.ort01,
        A.stras,
        A.pstlz,
        A.land1,
        A.telf1,
        A.smtp_addr,
        A.stcd2,
        A.stcd3,
        A.j_1kfrepre,
        A.j_1kftbus,
        A.j_1kftind,
        A.erdat,          
        case when B.zifkey is not null then cast('X' as zgtemm_lastck)
             else cast('' as zgtemm_lastck) end as lastdata  
} where A.zifno = 'MM00001' 
