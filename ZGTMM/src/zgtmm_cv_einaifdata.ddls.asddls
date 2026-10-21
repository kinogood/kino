@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'INFO 전송 대상 데이터'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_EINAIFDATA 
with parameters 
    @Consumption.hidden: true
    @Environment.systemField: #SYSTEM_DATE
    p_startdate : vdm_v_start_date,
    p_enddate : vdm_v_end_date   
 as  
select from ZGTMM_CV_CHANGEDEINA(p_startdate: $parameters.p_startdate ,
                                 p_enddate : $parameters.p_enddate) as A   //기간 중 변경데이터
       left outer join ZGTMM_CV_EINA_IF_LOG_L as B                         //최종 전송 성공 데이터
                       on A.ekorg = B.ekorg and A.werks = B.werks and A.matnr = B.matnr and A.lifnr = B.lifnr
                       and B.lastdata = 'X' and B.zstat ='S'
{
    key A.ekorg,
    key A.werks,
    key A.matnr,
    key A.lifnr,
        A.LOEKZ,
    case when A.ekorg = B.ekorg and A.werks = B.werks and A.lifnr = B.lifnr and A.matnr = B.matnr and A.LOEKZ = B.loekz
         then cast('O' as abap.char(1))
         else cast('X' as abap.char(1))
         end as IFDATA,
      A.changenr,   
      A.udate,
      A.utime, 
      A.username         
}         
