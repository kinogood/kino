@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '일자별 STO 소요 정보 추출'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
 /* 1. 'D6' STO 구매요청 */
define view entity ZGTPP_CV_STO_DEMAND 
as select from eban as STR
  inner join mara as M
    on STR.matnr = M.matnr
  inner join marc as MC
    on STR.matnr = MC.matnr
    and STR.reswk = MC.werks
  inner join t023t
    on M.matkl = t023t.matkl
  inner join t024
    on MC.ekgrp = t024.ekgrp
{
    key STR.reswk         as Plant,
    key STR.matnr         as Material,
    key cast( STR.lfdat as lfdat ) as ReqDate,// 입고예정일
  
 /* 자재 마스터 정보 */
  M.spart as Division,           // 제품군
  M.matkl as MaterialGroup,      // 자재그룹
  @Semantics.language: true
  t023t.wgbez as MatGroupText,   // 언어 Key 참조한 텍스트
  M.mtart as MaterialType,       // 자재유형

  /* 플랜트별 자재 정보 */
  MC.dispo as MRPController,     // MRP 관리자
  MC.ekgrp as PurchasingGroup,   // 구매그룹
  t024.eknam as PurchaGrpText,   // 구매그룹 내역

  /* MRP 기본 정보 */
  STR.banfn                  as PurReqNo,
  STR.bnfpo                  as PurReqItem,
  cast('' as ebeln) as PurOrdNo,
  cast('' as ebelp) as PurOrdItem,
  cast('D6' as abap.char(2)) as RequirementType, // 소요량 유형
  cast('사내이체요청소요' as abap.char(20)) as BDTXT, // 사내이체요청소요

  STR.meins   as MRPUnit,
  @Semantics.quantity.unitOfMeasure: 'MRPUnit'
  sum( STR.menge )  as DemandQty,
  @Semantics.quantity.unitOfMeasure: 'MRPUnit'
  sum( STR.bsmng )  as GIQty,
  @Semantics.quantity.unitOfMeasure: 'MRPUnit'
  sum( STR.menge ) - sum( STR.bsmng )as RemainQty // 납품 예정 수량
}
where STR.pstyp = '7'
  and STR.loekz = ''
  and STR.ebakz = ''
group by 
  STR.reswk, STR.matnr, STR.lfdat, M.spart, M.matkl, t023t.wgbez, M.mtart, STR.banfn, STR.bnfpo,
  MC.dispo, MC.ekgrp, t024.eknam, STR.meins
//
  
  union 

//
 /* 2. '76' STO 구매오더 */
select from ekko as a
  inner join ekpo as STO
    on a.ebeln = STO.ebeln
  inner join eket as LINE
    on STO.ebeln = LINE.ebeln
   and STO.ebelp = LINE.ebelp
  inner join mara as M
    on STO.matnr = M.matnr
  inner join marc as MC
    on STO.matnr = MC.matnr
    and a.reswk = MC.werks
  inner join t023t
    on M.matkl = t023t.matkl
  inner join t024
    on MC.ekgrp = t024.ekgrp
{
    key a.reswk           as Plant,
    key STO.matnr         as Material,
    key cast( LINE.eindt as eindt ) as ReqDate,// 입고예정일

 /* 자재 마스터 정보 */
  M.spart as Division,           // 제품군
  M.matkl as MaterialGroup,      // 자재그룹
  t023t.wgbez as MatGroupText,   // 언어 Key 참조한 텍스트
  M.mtart as MaterialType,       // 자재유형

  /* 플랜트별 자재 정보 */
  MC.dispo as MRPController,     // MRP 관리자
  MC.ekgrp as PurchasingGroup,   // 구매그룹
  t024.eknam as PurchaGrpText,   // 구매그룹 내역

  /* MRP 기본 정보 */
  cast('' as abap.char(10)) as PurReqNo,
  cast('' as abap.char(10)) as PurReqItem,
  STO.ebeln                   as PurOrdNo,
  STO.ebelp                   as PurOrdItem,
  cast('D7' as abap.char(2)) as RequirementType, // 소요량 유형
  cast('사내이체오더소요' as abap.char(20)) as BDTXT, // 사내이체요청소요

  STO.meins    as MRPUnit,
  //@Semantics.quantity.unitOfMeasure: 'MRPUnit'
  sum( LINE.menge )  as DemandQty,
  //@Semantics.quantity.unitOfMeasure: 'MRPUnit'
  sum( LINE.wamng )  as GIQty,
  //@Semantics.quantity.unitOfMeasure: 'MRPUnit'
  sum( LINE.menge ) - sum( LINE.wamng )as RemainQty // 납품 예정 수량
}
where STO.pstyp = '7'
  and STO.loekz = ''
  and STO.elikz = ''
group by 
  a.reswk, STO.matnr, LINE.eindt, M.spart, M.matkl, t023t.wgbez, M.mtart, STO.ebeln, STO.ebelp,
  MC.dispo, MC.ekgrp, t024.eknam, STO.meins
