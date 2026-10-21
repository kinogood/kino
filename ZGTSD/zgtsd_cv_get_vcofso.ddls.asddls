@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '[GT] 판매오더 특성 값 조회'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZGTSD_CV_GET_VCOFSO
  as select from    vbap       as a
    left outer join ibin       as b  on  a.cuobj = b.instance
                                     and b.valto = 99991231235959
    left outer join ibinvalues as cv on b.in_recno = cv.in_recno
    left outer join ibsymbol   as cs on cv.symbol_id = cs.symbol_id
    left outer join cabn       as d  on cs.atinn = d.atinn
    left outer join vbkd       as e  on  a.vbeln = e.vbeln
                                     and a.posnr = e.posnr

{
      -- =======================================================================
      -- [1] Key Information (키 정보)
      -- =======================================================================
  key a.vbeln, -- 판매오더 번호
  key cast(a.posnr as posnr_va preserving type )                                         as posnr, -- 판매오더 품목 번호

      -- =======================================================================
      -- [2] Organizational Data (조직 정보)
      -- =======================================================================
      a.auart_ana                                                                        as auart,  -- 주문유형
      a.vkorg_ana                                                                        as vkorg,  -- 영업 조직
      a.vtweg_ana                                                                        as vtweg,  -- 유통 경로
      a.spart_ana                                                                        as spart,  -- 제품군
      a.werks,                                                                                      -- 플랜트
      e.bstkd_e,                                                                                    -- PO번호(ASIS 가온 작번)
      cast( a.kunnr_ana as kunag preserving type )                                       as kunag,  -- 판매처
      cast( a.kunwe_ana as kunwe preserving type )                                       as kunwe,  -- 납품처

      -- =======================================================================
      -- [3] Material & Unit (자재 및 단위 정보)
      -- =======================================================================
      a.matnr, -- 자재코드
      a.arktx, -- 자재내역
      @Semantics.quantity.unitOfMeasure: 'vrkme'
      a.kwmeng, -- 주문 수량
      a.vrkme, -- 판매 단위

      -- =======================================================================
      -- [4] Characteristics Values (복합 특성값 변환 및 추출)
      -- =======================================================================
      @Semantics.quantity.unitOfMeasure: 'vrkme'
      cast( coalesce(cast( max( case when d.atnam = 'SAP_LENGTH_VKRME'
                            then fltp_to_dec( cs.atflv as abap.dec(13,3) )
                            else null end )
                  as abap.quan(13,3) ), cast(0 as abap.quan(13,3)))
            as zgteweleng preserving type )                                              as LENGTH,         -- 조장

      @Semantics.quantity.unitOfMeasure: 'vrkme'
      cast( coalesce(cast( max( case when d.atnam = 'SAP_MILLCA_LENGTH'
                            then fltp_to_dec( cs.atflv as abap.dec(13,3) )
                            else null end )
                  as abap.quan(13,3) ), cast(0 as abap.quan(13,3)))
            as zgteweleng preserving type )                                              as MILL_LENGTH,    -- 조장

      cast( coalesce(cast( max( case when d.atnam = 'SAP_MILLCA_FACTOR'
                            then fltp_to_dec( cs.atflv as abap.dec(13,3) )
                            else null end )
                  as int4 ), cast(0 as int4))
            as zgtewecnt  preserving type )                                              as FACTOR,         -- 조장 수

      cast( cast( max( case when d.atnam = 'PD_CA_COLOR_BASE'
                            then cs.atwrt
                            else null end )
                  as abap.char(6) )
            as zzcolor_base preserving type )                                            as COLOR,          -- 색상

      max( case when d.atnam = 'PD_CA_COLOR_STRIPE'       then cs.atwrt else null end )  as STRIPE_COLOR,   -- 띠줄 색상
      max( case when d.atnam = 'PD_CA_COLOR_STRIPE_NO'    then cs.atwrt else null end )  as STRIPE_CNT,     -- 띠줄 갯수

      cast( max( case when d.atnam = 'PD_CA_SPEC_NO'      then cs.atwrt else null end )
            as zespecno preserving type )                                                as SPECNO,         -- Spec

      -- =======================================================================
      -- [5] Characteristics Values (일반 문자열 특성값 추출)
      -- =======================================================================
      max( case when d.atnam = 'MS-AUSP-ZSPART'           then cs.atwrt else null end )  as ZSPART,         -- 가온전선 제품분류
      max( case when d.atnam = 'PD_GA_DRUM_GUBUN'         then cs.atwrt else null end )  as DRTYP,          -- 드럼 구분
      max( case when d.atnam = 'MS-DRUMTITLEMARK'         then cs.atwrt else null end )  as DRPRNT_YN,      -- 드럼자판인쇄여부
      max( case when d.atnam = 'PD_GA_KEYHOLD_DOUBLE_YN'  then cs.atwrt else null end )  as DBL_KEYHOLE_YN, -- 키홀 2개 여부
      max( case when d.atnam = 'PD_CA_SKID_YN'            then cs.atwrt else null end )  as SKID_YN,        -- SKID 사용 여부
      max( case when d.atnam = 'PD_GA_HAWA_GUBUN'         then cs.atwrt else null end )  as hawa_type,      -- 상품구분
      max( case when d.atnam = 'PD_GA_FLANGE_PROT_YN'     then cs.atwrt else null end )  as FLNG_PRT_YN,    -- 악판골판지 사용여부
      max( case when d.atnam = 'PD_GA_PACKAGE_METHOD'     then cs.atwrt else null end )  as PKGTYP,         -- 포장 방법
      max( case when d.atnam = 'PD_GA_WRAP_PACKING_YN'    then cs.atwrt else null end )  as WRPKG_YN,       -- 랩포장 여부
      max( case when d.atnam = 'PD_AA_WITNESS_INSPECTION' then cs.atwrt else null end )  as INSPEC_YN,      -- 입회검사 유무
      max( case when d.atnam = 'PD_AA_WITNESS_INSPECTOR'  then cs.atwrt else null end )  as INSPECTOR,      -- 입회검사 기관
      max( case when d.atnam = 'PD_GA_NEW_DRUM_YN'        then cs.atwrt else null end )  as NEWDRUM,        -- 신(New)드럼 사용여부
      max( case when d.atnam = 'PD_GA_PRINT_METHOD'       then cs.atwrt else null end )  as PRNTYP,         -- 시스(Sheath) 인쇄 방법
      max( case when d.atnam = 'PD_CA_MARK_CONTENTS_1ST'  then cs.atwrt else null end )  as SHTH_MARK1,     -- 시스(Sheath) 마킹내용1
      max( case when d.atnam = 'PD_CA_MARK_CONTENTS_2ND'  then cs.atwrt else null end )  as SHTH_MARK2,     -- 시스(Sheath) 마킹내용2
      max( case when d.atnam = 'PD_CA_MARK_CONTENTS_3RD'  then cs.atwrt else null end )  as SHTH_MARK3,     -- 시스(Sheath) 마킹내용3
      max( case when d.atnam = 'PD_CA_MARK_CONTENTS_4TH'  then cs.atwrt else null end )  as SHTH_MARK4,     -- 시스(Sheath) 마킹내용4
      max( case when d.atnam = 'PD_CA_MARK_CONTENTS_5TH'  then cs.atwrt else null end )  as SHTH_MARK5,     -- 시스(Sheath) 마킹내용5
      max( case when d.atnam = 'PD_CA_MARK_CONTENTS_6TH'  then cs.atwrt else null end )  as SHTH_MARK6,     -- 시스(Sheath) 마킹내용6
      max( case when d.atnam = 'PD_CA_MARK_CONTENTS_7TH'  then cs.atwrt else null end )  as SHTH_MARK7,     -- 시스(Sheath) 마킹내용7
      max( case when d.atnam = 'PD_CA_MARK_CONTENTS_8TH'  then cs.atwrt else null end )  as SHTH_MARK8,     -- 시스(Sheath) 마킹내용8
      max( case when d.atnam = 'PD_CA_MARK_CONTENTS_9TH'  then cs.atwrt else null end )  as SHTH_MARK9,     -- 시스(Sheath) 마킹내용9
      max( case when d.atnam = 'PD_CA_MARK_CONTENTS_10TH'  then cs.atwrt else null end ) as SHTH_MARK10,    -- 시스(Sheath) 마킹내용10

      max( case when d.atnam = 'SAP_MILLCA_PACKAGING_CAT' then cs.atwrt else null end )  as PKGCAT,         -- 포장재유형
      max( case when d.atnam = 'SAP_MILLCA_PACKAGING'     then cs.atwrt else null end )  as PKGMATNR,       -- 포장재코드(일반)
      max( case when d.atnam = 'PD_CA_PACKING_DM'         then cs.atwrt else null end )  as PKG_DRUM,       -- 포장재(드럼)
      max( case when d.atnam = 'PD_CA_PACKING_BX'         then cs.atwrt else null end )  as PKG_BOX,        -- 포장재(BOX)
      max( case when d.atnam = 'PD_CA_PACKING_PA'         then cs.atwrt else null end )  as PKG_PALLET,     -- 포장재(PALLET)
      max( case when d.atnam = 'PD_CA_PACKING_SK'         then cs.atwrt else null end )  as PKG_SKID,       -- 포장재(드럼)
      max( case when d.atnam = 'PD_CA_PACKING_PW'         then cs.atwrt else null end )  as PKG_PW,         -- 포장재(포장목)
      max( case when d.atnam = 'PD_CA_PROC_NAME'          then cs.atwrt else null end )  as PRCSSNM,        -- 공정명
      max( case when d.atnam = 'PD_CA_PACKMARK_STATUS'    then cs.atwrt else null end )  as CMSTA           -- 포장재/마킹지정상태표시
}
group by
  a.vbeln,
  a.posnr,
  a.auart_ana,
  a.vkorg_ana,
  a.vtweg_ana,
  a.spart_ana,
  a.werks,
  e.bstkd_e,
  a.kunnr_ana,
  a.kunwe_ana,
  a.matnr,
  a.arktx,
  a.kwmeng,
  a.vrkme
