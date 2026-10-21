@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '자재 마스터 구매 정보 조회'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZGTMM_CV_PUR_MARC 
as 
select from mara as A inner join marc as B
on A.matnr = B.matnr
association [1..1] to t001w as T001W on $projection.werks = T001W.werks
association [1..1] to t134t as T134T on $projection.mtart = T134T.mtart and T134T.spras = $session.system_language 
association [1..1] to makt as MAKT on $projection.matnr = MAKT.matnr and MAKT.spras = $session.system_language
association [1..1] to t024 as T024 on $projection.ekgrp = T024.ekgrp
association [1..1] to t438t as T438T on $projection.dismm = T438T.dismm and T438T.spras = $session.system_language 
association [1..1] to t439t as T439T on $projection.disls = T439T.disls and T439T.spras = $session.system_language 
association [1..1] to t001l as t001l on $projection.werks = t001l.werks and $projection.lgfsb =  t001l.lgort 
association [1..1] to t024d as t024d on $projection.werks = t024d.werks and $projection.dispo =  t024d.dispo 
{
  key B.werks,
  key t001w.name1,
  key A.mtart,
  key t134t.mtbez,
  key A.matnr,
  key makt.maktx,
  B.ekgrp,
  t024.eknam,
  A.ekwsl,
  B.webaz,
  B.kordb,
  B.insmk,
  B.dismm,
  t438t.dibez,
  B.lgfsb,
  t001l.lgobe,
  @Semantics.quantity.unitOfMeasure: 'MEINS'
  B.minbe,
  B.disls,
  t439t.loslt,
  B.dispo,
  t024d.dsnam,
  @Semantics.quantity.unitOfMeasure: 'MEINS'
  B.bstfe,
  B.plifz,
  @Semantics.quantity.unitOfMeasure: 'MEINS'
  B.eisbe,
  A.meins,
  B.sbdkz,
  B.pstat,
  @EndUserText.label: 'Status'
  cast('E' as pstat_d) as STAT  
} where B.pstat like '%E%' and A.lvorm = '' and B.lvorm = ''


union all

select from mara as A inner join marc as B
on A.matnr = B.matnr
association [1..1] to t001w as T001W on $projection.werks = T001W.werks
association [1..1] to t134t as T134T on $projection.mtart = T134T.mtart and T134T.spras = $session.system_language 
association [1..1] to makt as MAKT on $projection.matnr = MAKT.matnr and MAKT.spras = $session.system_language
association [1..1] to t024 as T024 on $projection.ekgrp = T024.ekgrp
association [1..1] to t438t as T438T on $projection.dismm = T438T.dismm and T438T.spras = $session.system_language 
association [1..1] to t439t as T439T on $projection.disls = T439T.disls and T439T.spras = $session.system_language 
association [1..1] to t001l as t001l on $projection.werks = t001l.werks and $projection.lgfsb =  t001l.lgort 
association [1..1] to t024d as t024d on $projection.werks = t024d.werks and $projection.dispo =  t024d.dispo 
{
  key B.werks,
  key t001w.name1,
  key A.mtart,
  key t134t.mtbez,
  key A.matnr,
  key makt.maktx,
  B.ekgrp,
  t024.eknam,
  A.ekwsl,
  B.webaz,
  B.kordb,
  B.insmk,
  B.dismm,
  t438t.dibez,
  B.lgfsb,
  t001l.lgobe,  
  B.minbe,
  B.disls,
  t439t.loslt,
  B.dispo,
  t024d.dsnam,
  B.bstfe,
  B.plifz,
  B.eisbe,
  A.meins,
  B.sbdkz,
  B.pstat,
  cast('D' as pstat_d) as STAT  
} where B.pstat like '%D%' and A.lvorm = '' and B.lvorm = ''
