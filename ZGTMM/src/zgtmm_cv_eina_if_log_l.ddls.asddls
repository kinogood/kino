@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '자재-업체 매핑 정보 전송 최종 I/F Log-mm00013'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_EINA_IF_LOG_L 
as 
select from ZGTMM_CV_EINA_IF_LOG as A left outer join ZGTMM_CV_EINA_IF_LOG_S as B 
       on A.zifno = B.zifno and A.zifkey = B.zifkey and A.system_id = B.system_id 
       and A.ekorg = B.ekorg and A.werks = B.werks and A.lifnr = B.lifnr and A.matnr = B.matnr 
{
   key  A.zifno,
   key  A.zifkey,
   key  A.system_id,     
        cast(A.ZTARGET_N as zgtesystname) as ztarget_n,
        A.zstat,
        A.message,
        A.ifdat,
        A.iftim, 
        A.ifnam,
        A.ekorg,
        A.werks,
        A.lifnr,
        A.matnr,
        cast(A.loekz as eloek) as loekz,
        A.message as CMSG,
        cast(A.ZIFNO_N as zgteifname) as zifno_n,  
        case when B.zifkey is not null then cast('X' as zgtelastdata)
             else cast('' as zgtelastdata) end as lastdata
} where A.zifno = 'MM00013'
