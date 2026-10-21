@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '벤더 변경 정보 조회-MM00001'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_CHANGEDVD
with parameters 
    @Consumption.hidden: true
    @Environment.systemField: #SYSTEM_DATE
    p_startdate : vdm_v_start_date,
    p_enddate : vdm_v_end_date   
 as 
 select from ZGTMM_CV_GETCDHDRID(p_startdate: $parameters.p_startdate ,
                                 p_enddate : $parameters.p_enddate,
                                 p_diGit: 10,
                                 P_CLASS : 'KRED')  as A
        inner join lfa1 as B on A.ID = B.lifnr
        inner join lfm1 as C on B.lifnr = C.lifnr
 //       left outer join adr6 as d on B.adrnr = d.addrnumber
{
  key     C.erdat,
  key     B.lifnr,
          C.ekorg,
          C.loevm,
          B.sperm,
          B.ktokk,
          B.anred,
          B.adrnr,
          B.name1,
          B.name2,
          B.sortl,
          B.ort01,
          B.stras,
          B.pstlz,
          B.land1,
          B.telf1,
          cast('' as abap.char(241)) as smtp_addr,
          B.stcd2,
          B.stcd3,
          B.j_1kfrepre,
          B.j_1kftbus,
          B.j_1kftind,
  /*        A.changenr,
          A.udate,
          A.utime,
          A.username   */
          cast('' as cdchangenr) as changenr,          
          //A.changenr,
          B.erdat as udate,
          B.uptim as utime,
          B.ernam as username             
} 

union

 select from  lfa1 as B 
        inner join lfm1 as C on B.lifnr = C.lifnr
 //       left outer join adr6 as d on B.adrnr = d.addrnumber
{
  key     C.erdat,
  key     B.lifnr,
          C.ekorg,
          C.loevm,
          B.sperm,
          B.ktokk,
          B.anred,
          B.adrnr,
          B.name1,
          B.name2,
          B.sortl,
          B.ort01,
          B.stras, 
          B.pstlz,
          B.land1,
          B.telf1,
          cast('' as abap.char(241)) as smtp_addr,
          B.stcd2,
          B.stcd3,
          B.j_1kfrepre,
          B.j_1kftbus,
          B.j_1kftind,
          cast('' as cdchangenr) as changenr,           
          //A.changenr,
          B.erdat as udate,
          B.uptim as utime,
          B.ernam as username   
} where B.erdat >= $parameters.p_startdate and B.erdat <= $parameters.p_enddate
