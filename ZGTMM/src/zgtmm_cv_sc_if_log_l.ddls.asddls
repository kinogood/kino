@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '사급자재 불출 정보 전송 최종 LOG-MM00018'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_SC_IF_LOG_L 
as 
select from ZGTMM_CV_SC_IF_LOG as A left outer join ZGTMM_CV_SC_IF_LOG_S as B 
       on A.zifno = B.zifno and A.zifkey = B.zifkey and A.system_id = B.system_id 
       and A.mjahr = B.mjahr      
       and A.mblnr = B.mblnr
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
        A.mjahr,
        A.mblnr,
        A.zeile,
        A.ztype,
        A.werks,
        A.lgort,
        A.lifnr,
        A.name1,
        cast(A.ZIFNO_N as zgteifname) as ZIFNO_N,  
        A.matnr,
        A.maktx,
        A.charg,
        @Semantics.quantity.unitOfMeasure: 'MEINS'
        A.menge,
        A.meins,        
        case when B.zifkey is not null then cast('X' as zgtemm_lastck)
             else cast('' as zgtemm_lastck) end as lastdata  
} where A.zifno = 'MM00018'
