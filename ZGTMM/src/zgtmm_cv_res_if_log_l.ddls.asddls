@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '예약 정보 전송 최종 I/F Log-MM00006'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_RES_IF_LOG_L 
as 
select from ZGTMM_CV_RES_IF_LOG as A left outer join ZGTMM_CV_RES_IF_LOG_S as B 
       on A.zifno = B.zifno and A.zifkey = B.zifkey and A.system_id = B.system_id 
       and A.rsnum = B.rsnum and A.werks = B.werks and A.bwart = B.bwart and A.rspos = B.rspos
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
        A.rsnum,
        A.werks,
        A.WERKS_N,
        A.bwart,
        cast(A.ZIFNO_N as zgteifname) as ZIFNO_N,  
        A.rspos,

        A.rsdat,
        A.bdart,
        A.wempf,
        
        A.xwaok,
        A.kzear,
        A.xloek,
        A.matnr,
        
        A.lgort,
        A.umwrk,
        A.umlgo,
        A.erfme,
        @Semantics.quantity.unitOfMeasure: 'ERFME'
        A.bdmng,
        @Semantics.quantity.unitOfMeasure: 'ERFME'
        A.enmng,        
        case when B.zifkey is not null then cast('X' as zgtemm_lastck)
             else cast('' as zgtemm_lastck) end as lastdata  
             
} where A.zifno = 'MM00006'
