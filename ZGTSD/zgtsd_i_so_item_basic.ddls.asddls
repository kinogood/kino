@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '[GT] 판매오더 Item 기초 정보'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZGTSD_I_SO_ITEM_BASIC
  as select from           vbap                      as _Item

    inner join             vbak                      as _Header   on _Item.vbeln = _Header.vbeln

    inner join             usr21                     as _Usr      on _Item.ernam = _Usr.bname

    inner join             adrp                      as _UsrAdr   on _Usr.persnumber = _UsrAdr.persnumber

    inner join             ZGTSD_CV_SO_ITEM_STATUS   as _ItemStat on  _Item.vbeln = _ItemStat.vbeln
                                                                  and _Item.posnr = _ItemStat.posnr

    inner join             ZGTSD_I_SALESDOC_UPD_DATE as _Log      on _Item.vbeln = _Log.vbeln

    inner join             mara                      as _Mat      on _Item.matnr = _Mat.matnr

    left outer to one join vbep                      as _Sch      on  _Item.vbeln = _Sch.vbeln
                                                                  and _Item.posnr = _Sch.posnr
                                                                  and _Sch.etenr  = '0001'

    left outer to one join vbkd                      as _Business on  _Item.vbeln     = _Business.vbeln
                                                                  and _Business.posnr = '000000'

    left outer to one join vbkd                      as _BusiItm  on  _Item.vbeln = _BusiItm.vbeln
                                                                  and _Item.posnr = _BusiItm.posnr

    left outer to one join prcd_elements             as _Prcd     on  _Header.knumv = _Prcd.knumv
                                                                  and _Item.posnr   = _Prcd.kposn
                                                                  and _Prcd.kschl   = 'ZBO5'

    left outer to one join prcd_elements             as _Prcd2    on  _Header.knumv = _Prcd2.knumv
                                                                  and _Item.posnr   = _Prcd2.kposn
                                                                  and _Prcd2.kschl  = 'ZBO8'

    left outer to one join prcd_elements             as _Tax      on  _Header.knumv = _Tax.knumv
                                                                  and _Item.posnr   = _Tax.kposn
                                                                  and _Tax.kvsl1    = 'MWS'

    left outer to one join vbpa                      as _Partner  on  _Item.vbeln    = _Partner.vbeln
                                                                  and _Partner.posnr = '000000'
                                                                  and _Partner.parvw = 'VE'

    left outer to one join zsd0106t                  as _Pjt      on  _Header.zpjno = _Pjt.zpjno
                                                                  and _Header.kunnr = _Pjt.kunnr

  --    left outer join        ZGTSD_I_DELIVERY_REQUEST as _Dlvrq    on  _Item.vbeln = _Dlvrq.vbeln
  --                                                                 and _Item.posnr = _Dlvrq.posnr

  association [1..1] to kna1 as _Cust     on $projection.kunag = _Cust.kunnr
  association [0..1] to lfa1 as _SalesEmp on $projection.sales_empl = _SalesEmp.lifnr
  association [1..1] to kna1 as _ShipTo   on $projection.kunwe = _ShipTo.kunnr
  association [1..1] to kna1 as _Payer    on $projection.kunrg = _Payer.kunnr

{
      -- =======================================================================
      -- [1] Key Information (키 정보)
      -- =======================================================================
  key _Item.vbeln,                                                                             -- 판매오더 번호
  key cast(_Item.posnr as posnr_va preserving type )                            as posnr,      -- 판매오더 품목 번호

      -- =======================================================================
      -- [2] Document References & Types (문서 참조 및 유형 정보)
      -- =======================================================================
      _Header.auart,                                                                           -- 판매오더 유형
      _Header.vbtyp,                                                                           -- SD 문서 범주
      _Header.augru,                                                                           -- Order Reason
      _Item.shkzg,                                                                             -- 반품 관련 지시자
      _Item.vgbel,                                                                             -- 선행 참조 문서
      _Item.vgpos,                                                                             -- 선행 참조 품목
      cast( _Header.zpjno as zpjno preserving type )                            as zpjno,      -- 프로젝트 번호
      cast(_Pjt.zptxt as zptxt preserving type)                                 as zptxt,      -- 프로젝트명
      _Pjt.land1                                                                as country,    -- 프로젝트 국가코드

      -- =======================================================================
      -- [3] Partner Information (파트너 정보)
      -- =======================================================================
      _Item.kunnr_ana                                                           as kunag, -- 판매처
      cast(_Cust.name1 as zgteagname preserving type )                          as customername, -- 판매처명
      _Item.kunwe_ana                                                           as kunwe, -- 인도처
      cast(_ShipTo.name1 as zgtewename preserving type )                        as shipto_name, -- 인도처명
      _Item.kunrg_ana                                                           as kunrg, -- 지급처
      cast(_Payer.name1 as zgtergname preserving type )                         as payer_name, -- 지급처명
      cast(_Partner.lifnr as zgtesempl preserving type )                        as sales_empl, -- 영업 사원 (VE)
      cast(_SalesEmp.name1 as zgtesemplname preserving type )                   as empl_name, -- 영업 사원명

      -- =======================================================================
      -- [4] Organizational & Logistics (조직 및 물류 정보)
      -- =======================================================================
      _Header.vkorg,                                                                           -- 영업 조직
      _Header.vtweg,                                                                           -- 유통 경로
      _Header.vkbur,                                                                           -- 영업소
      _Header.vkgrp,                                                                           -- 영업 그룹
      _Header.spart,                                                                           -- 헤더 제품군
      cast(_Item.spart as zgtespart_i preserving type )                         as item_spart, -- 품목 제품군
      _Header.bstnk,                                                                           -- 고객 구매오더 번호
      _BusiItm.bstkd_e,                                                                        -- ASIS작번
      _Item.werks,                                                                             -- 플랜트
      _Item.vstel,                                                                             -- 출하 지점

      -- =======================================================================
      -- [5] Material & Characteristics (자재 및 특성 정보)
      -- =======================================================================
      _Item.fixmg,                                                                             -- OM/SM 구분
      _Item.mvgr3,                                                                             -- 정조장 여부
      _Item.prodh,                                                                             -- 제품 계층구조
      _Item.matnr,                                                                             -- 자재 번호
      case when _Mat.zzmaktx80 is not initial
           then _Mat.zzmaktx80 else _Item.arktx
      end                                                                       as arktx,      -- 자재 내역

      -- =======================================================================
      -- [6] Quantities & Units (수량 및 단위 정보)
      -- =======================================================================
      @Semantics.quantity.unitOfMeasure: 'vrkme'
      cast(case when _Item.kwmeng is initial then _Item.zmeng
                else _Item.kwmeng end
           as kwmeng preserving type )                                          as kwmeng, -- 주문 수량
      cast(coalesce(_Item.vrkme, _Item.zieme) as vrkme preserving type )        as vrkme, -- 판매 단위

      -- =======================================================================
      -- [7] Pricing, Amounts & Currency (단가, 금액 및 통화 정보)
      -- =======================================================================
      _Item.kondm,                                                                             -- 소재 가공비 유형
      @Semantics.amount.currencyCode: 'waerk'
      _Item.netpr,                                                                             -- 단가
      _Item.kmein,                                                                             -- Condition Unit
      _Item.kpein,                                                                             -- Condition Pricing Unit
      @Semantics.amount.currencyCode: 'waerk'
      _Item.netwr,                                                                             -- 순가치 금액
      @Semantics.amount.currencyCode: 'waerk'
      _Item.mwsbp,                                                                             -- 세금 금액
      _Tax.mwsk1,                                                                              -- 세금 코드
      _Item.waerk,                                                                             -- 문서 통화
      _Business.prsdt,                                                                         -- 가격 결정일
      _Business.kursk,
      -- 환율
      @Semantics.amount.currencyCode: 'waerk_krw'
      cast(
          case when _Item.waerk <> 'KRW'
               then currency_conversion( amount             => _Item.netwr,
                                         source_currency    => _Item.waerk,
                                         target_currency    => cast( 'KRW' as abap.cuky ),
                                         exchange_rate_date => _Business.prsdt,
                                         exchange_rate_type => 'M',
                                         client             => $session.client )
               else _Item.netwr
          end
      as zgtekrwamt preserving type )                                           as netwr_krw, -- 원화 환산 순가치 금액
      cast( cast( 'KRW' as abap.cuky ) as zgtekrwcur preserving type)           as waerk_krw, -- 원화 통화 키 ('KRW')

      cast(cast(_Prcd.kbetr as abap.char(30)) as zgtecmsnrte preserving type )  as commission_rate, -- 수수료율
      cast(cast(_Prcd.kwert as abap.char(30)) as zgtecmsnamt preserving type )  as commission_amt,  -- 수수료 금액

      cast(cast(_Prcd2.kbetr as abap.char(30)) as zgtecmsnrte preserving type ) as commission_rate2, -- 수수료율
      cast(cast(_Prcd2.kwert as abap.char(30)) as zgtecmsnamt preserving type ) as commission_amt2,  -- 수수료 금액

      -- =======================================================================
      -- [8] Schedule & Delivery (일정 및 납품 정보)
      -- =======================================================================
      cast(_Sch.edatu as edatu preserving type )                                as edatu, -- 최대 납품 일정일
      _Sch.lifsp, -- 납품 보류 사유
      case when _Sch.banfn is not initial
           then 'Y' end                                                         as oemrel, -- 구매요청 생성 여부
      _Item.abgru, -- 거부 사유

      -- =======================================================================
      -- [9] Contract (수주/실행 정보)
      -- =======================================================================
      _Header.zqtno,                                                                           -- 견적번호
      _Header.ztver,                                                                           -- 견적버전
      _Header.zexno,                                                                           -- 실행번호
      _Header.zexver,                                                                          -- 실행버전

      -- =======================================================================
      -- [10] Status (상태 정보)
      -- =======================================================================
      _ItemStat.absta,                                                                         -- 거부 상태
      _ItemStat.drsta,                                                                         -- 출하 요청 상태
      _ItemStat.lfsta,                                                                         -- 납품 문서 생성 상태
      _ItemStat.wbsta,                                                                         -- 출고 상태
      _ItemStat.kpsta,                                                                         -- 보관품 입고 상태
      _ItemStat.ivsta,                                                                         -- 거래명세서 발행 상태
      _ItemStat.gosta,                                                                         -- 통문 처리 상태
      _ItemStat.fksta,                                                                         -- 청구 상태
      _ItemStat.dfsta,                                                                         -- 적송 상태
      _ItemStat.grsta,                                                                         -- 구매 입고 상태
      _ItemStat.gbsta,                                                                         -- 전체 처리 상태

      -- =======================================================================
      -- [11] Administrative Data (시스템 관리 정보)
      -- =======================================================================
      _Item.erdat,                                                                             -- 레코드 생성일
      _Item.erzet,                                                                             -- 입력 시간
      _Item.ernam,                                                                             -- 생성자 SAP ID
      _UsrAdr.name_last                                                         as created_by, -- 생성자 이름
      _Log.upd_dat                                                                             -- 판매오더 변경일
}
where
      _Header.augru <> '150'
  //  and _Header.augru <> '600'
  and _Header.faksk <> 'G1' -- 소재 매출정산 완료
//  and _Item.pstyv   <> 'ZADP'
