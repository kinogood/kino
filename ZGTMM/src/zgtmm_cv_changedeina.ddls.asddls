@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'INFO 변경 정보 조회-MM00013'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_CHANGEDEINA
with parameters 
    @Consumption.hidden: true
    @Environment.systemField: #SYSTEM_DATE
    p_startdate : vdm_v_start_date,
    p_enddate : vdm_v_end_date   
 as 

 select from eine as B 
        inner join eina as C on B.infnr = C.infnr
        inner join ekpo as D on B.werks = D.werks and B.esokz = D.pstyp and B.infnr = D.infnr and C.matnr = D.matnr
        inner join ekko as E on D.ebeln = E.ebeln and B.ekorg = E.ekorg and C.lifnr = E.lifnr         
{
 key  B.ekorg,
      B.werks,
      C.matnr,
      C.lifnr, 
      case when B.loekz <> '' or C.loekz <> '' then cast('X' as eloek) 
           else cast('' as eloek) end as LOEKZ,
      cast('' as cdchangenr) as changenr, 
      cast(substring(cast(C.lastchangedatetime as abap.char(32)),1,8) as abap.dats) as udate,
      cast(substring(cast(C.lastchangedatetime as abap.char(32)),9,15) as abap.tims) as utime,
      C.ernam as username
} where cast(substring(cast(C.lastchangedatetime as abap.char(32)),1,8) as abap.dats) >= $parameters.p_startdate
  and cast(substring(cast(C.lastchangedatetime as abap.char(32)),1,8) as abap.dats) <= $parameters.p_enddate

group by B.ekorg, B.werks,C.matnr, C.lifnr, B.loekz, C.loekz, C.ernam, C.lastchangedatetime
