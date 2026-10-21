@AbapCatalog.sqlViewName: 'ZGTPP_CV_MRP_DAY'
@AbapCatalog.compiler.compareFilter:true
@AbapCatalog.preserveKey:true
@AccessControl.authorizationCheck:#NOT_REQUIRED
@EndUserText.label:'일자별 MRP 수요 현황'
@Metadata.ignorePropagatedAnnotations:true
 /* 1. 'D1~D5' 생산 소요, 외주구매 소요 */
define view ZGTPP_CV_MRP_DAILY 
  as select from mdrs as MRP
  inner join mara as M
    on MRP.matnr = M.matnr
  inner join marc as MC
    on MRP.matnr = MC.matnr
    and MRP.werks = MC.werks
  inner join t023t
    on M.matkl = t023t.matkl
  inner join t024
    on MC.ekgrp = t024.ekgrp
        
{
  /* 기본 키 */
  key MRP.werks       as Plant,
  key MRP.matnr       as Material,
  key MRP.bdter       as ReqDate,
  
  MRP.rsnum       as ResrvationNo,
  MRP.rspos       as ResrvationItem,
  MRP.aufnr       as AUFNR,

  /* 자재 마스터 정보 */
  M.spart           as division,           // 제품군
  M.matkl           as MaterialGroup,      // 자재그룹
  @Semantics.language: true
  t023t.wgbez       as MatGroupText,       // 언어 Key 참조한 텍스트
  M.mtart           as MaterialType,       // 자재유형

  /* 플랜트별 자재 정보 */
  MC.dispo          as MRPController,      // MRP 관리자
  MC.ekgrp          as PurchasingGroup,    // 구매그룹
  t024.eknam       as PurchaGrpText,      // 구매그룹 내역

  /* MRP 기본 정보   */
  MRP.xloek         as DeleteFlag,
  MRP.xwaok         as MoveAllow,
  MRP.kzear         as Completed,
  MRP.banfn         as PurReqNo,
  MRP.bnfpo         as PurReqItem,
  MRP.ebeln         as PurOrdNo,
  MRP.ebelp         as PurOrdItem,
  MRP.plnum         as PldOrdNo,
//  MRP.bdart         as RequirementType,    // 소요량 유형
  case
    when MRP.bdart = 'AR' then 'D1'
    when MRP.bdart = 'SB' then 'D2'
    when MRP.bdart = 'BB' and MRP.banfn = '' and MRP.plnum = '' then 'D3'
    when MRP.bdart = 'BB' and MRP.banfn <> '' then 'D4'
    when MRP.bdart = 'BB' and MRP.plnum <> '' then 'D5'
    else MRP.bdart
    end as RequirementType,
  
  case
   when MRP.bdart = 'AR' then '생산오더소요'
   when MRP.bdart = 'SB' then '생산계획소요'
   when MRP.bdart = 'BB' and MRP.banfn = '' and MRP.plnum = '' then '외주구매오더소요'
   when MRP.bdart = 'BB' and MRP.banfn <> '' then '외주구매요청소요'
   when MRP.bdart = 'BB' and MRP.plnum <> '' then '외주구매계획소요'
   else '기타소요'
   end as BDTXT,
   
  /* MRP 기본 수요(소요량) */
  MRP.meins         as MRPUnit,
     @Semantics.quantity.unitOfMeasure: 'MRPUnit'
  sum( MRP.bdmng )         as DemandQty,
     @Semantics.quantity.unitOfMeasure: 'MRPUnit'
  sum( MRP.enmng )         as GIQty,              // 출고 수량
     @Semantics.quantity.unitOfMeasure: 'MRPUnit'
  sum( MRP.bdmng ) - sum( MRP.enmng ) as RemainQty // 잔여 수량
}
 where MRP.xloek = ''
   and MRP.kzear = ''
 group by MRP.rsnum, MRP.rspos, MRP.aufnr, MRP.werks, MRP.matnr, MRP.bdter, M.matkl, M.mtart, MC.dispo,
          MC.ekgrp, MRP.xloek, MRP.xwaok, MRP.kzear, MRP.banfn, MRP.bnfpo, MRP.ebeln, MRP.ebelp,
          MRP.plnum, MRP.bdart, MRP.meins, t023t.wgbez, M.spart, t024.eknam

union

 /* 2. 'R1' 구매요청공급 */
select from ZGTMM_CV_RESERVED_PR as A
inner join mara as M
  on A.matnr = M.matnr
inner join marc as MC
  on A.matnr = MC.matnr
  and A.werks = MC.werks
inner join t023t
  on M.matkl = t023t.matkl
inner join t024
  on MC.ekgrp = t024.ekgrp
{
  key A.werks as Plant,
  key A.matnr as Material,
  key cast( A.REQDATE as bdter ) as ReqDate,// 납품요청일

  cast('' as rsnum)       as ResrvationNo,
  cast('' as rspos)       as ResrvationItem,
  cast('' as aufnr)       as AUFNR,

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
  cast('' as abap.char(1)) as DeleteFlag,
  cast('' as abap.char(1)) as MoveAllow,
  cast('' as abap.char(1)) as Completed,
  A.banfn                  as PurReqNo,
  A.bnfpo                  as PurReqItem,
  cast('' as abap.char(10)) as PurOrdNo,
  cast('' as abap.char(10)) as PurOrdItem,
  cast('' as abap.char(10)) as PldOrdNo,
  cast('R1' as abap.char(2)) as RequirementType, // 소요량 유형
  cast('구매요청공급' as abap.char(20)) as BDTXT, // 구매요청 공급

  cast(A.meins as meins) as MRPUnit,
  @Semantics.quantity.unitOfMeasure: 'MRPUnit'
  cast(0 as abap.quan(13,3)) as DemandQty,
  @Semantics.quantity.unitOfMeasure: 'MRPUnit'
  cast(0 as abap.quan(13,3)) as GIQty,
  @Semantics.quantity.unitOfMeasure: 'MRPUnit'
  cast(sum(A.REQTY) as abap.quan(13,3)) as RemainQty // 납품 예정 수량
}
group by 
  A.werks, A.matnr, A.REQDATE, M.spart, M.matkl, t023t.wgbez, M.mtart, A.banfn, A.bnfpo,
  MC.dispo, MC.ekgrp, t024.eknam, A.meins
  
  union

 /* 2. 'R2' 구매오더공급 */
select from ZGTMM_CV_RESERVED_GR as A
inner join mara as M
  on A.matnr = M.matnr
inner join marc as MC
  on A.matnr = MC.matnr
  and A.werks = MC.werks
inner join t023t
  on M.matkl = t023t.matkl
inner join t024
  on MC.ekgrp = t024.ekgrp
{
  key A.werks as Plant,
  key A.matnr as Material,
  key cast(A.REQDATE as abap.dats) as ReqDate,  // 납품요청일

  cast('' as rsnum)       as ResrvationNo,
  cast('' as rspos)       as ResrvationItem,
  cast('' as aufnr)       as AUFNR,
  
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
  cast('' as abap.char(1)) as DeleteFlag,
  cast('' as abap.char(1)) as MoveAllow,
  cast('' as abap.char(1)) as Completed,
  cast('' as abap.char(10)) as PurReqNo,
  cast('' as abap.char(10)) as PurReqItem,
  A.ebeln                   as PurOrdNo,
  A.ebelp                   as PurOrdItem,
  cast('' as abap.char(10)) as PldOrdNo,
  cast('R2' as abap.char(2)) as RequirementType, // 소요량 유형
  cast('구매오더공급' as abap.char(20)) as BDTXT, // 구매오더 공급

  cast(A.meins as meins) as MRPUnit,
  @Semantics.quantity.unitOfMeasure: 'MRPUnit'
  cast(0 as abap.quan(13,3)) as DemandQty,
  @Semantics.quantity.unitOfMeasure: 'MRPUnit'
  cast(0 as abap.quan(13,3)) as GIQty,
  @Semantics.quantity.unitOfMeasure: 'MRPUnit'
  cast(sum(A.REQTY) as abap.quan(13,3)) as RemainQty // 납품 예정 수량
}
group by 
  A.werks, A.matnr, A.REQDATE, M.spart, M.matkl, t023t.wgbez, M.mtart, 
  MC.dispo, MC.ekgrp, t024.eknam, A.ebeln, A.ebelp, A.meins

;

