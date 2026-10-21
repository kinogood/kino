@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '[GT] 판매오더 변경 및 생성 내역 통합 조회'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZGTSD_CV_GET_SO_HISTORY_UNION 
  with parameters
    p_date_from : abap.dats,
    p_date_to   : abap.dats
as 
// ----------------------------------------------------------------------
// 1. 변경 이력 존재 건 (CTE 대체)
// ----------------------------------------------------------------------
select distinct from ZGTSD_CV_GET_CHANGE_HISTORY( p_date_from : $parameters.p_date_from, 
                                                  p_date_to   : $parameters.p_date_to ) as Chg
    inner join vbak as Head on Chg.vbeln    = Head.vbeln
    inner join vbap as Item on Head.vbeln   = Item.vbeln
{
    key Head.vbeln,
    Head.vkorg,
    Head.vtweg,
    Head.spart,
    Head.auart,
    Item.werks
}

union

// ----------------------------------------------------------------------
// 2. 신규 생성 건 (AEDAT IS NULL) - CDHDR 이력 없음
// ----------------------------------------------------------------------
select distinct from vbak as Head
    inner join vbap as Item on Head.vbeln = Item.vbeln
{
    key Head.vbeln,
    Head.vkorg,
    Head.vtweg,
    Head.spart,
    Head.auart,
    Item.werks
}
where Head.erdat between $parameters.p_date_from and $parameters.p_date_to
  and ( Head.aedat is null or Head.aedat = Head.erdat )

union

// ----------------------------------------------------------------------
// 3. CDHDR 변경이력 남지 않는 건 (ERDAT <> AEDAT)
// ----------------------------------------------------------------------
select distinct from vbak as Head
    inner join vbap as Item on Head.vbeln = Item.vbeln
{
    key Head.vbeln,
    Head.vkorg,
    Head.vtweg,
    Head.spart,
    Head.auart,
    Item.werks
}
where Head.erdat between $parameters.p_date_from and $parameters.p_date_to
  and Head.erdat <> Head.aedat
  and Head.erzet <> cast(substring(cast(Head.upd_tmstmp as abap.char(30)),9,6) as abap.tims)
