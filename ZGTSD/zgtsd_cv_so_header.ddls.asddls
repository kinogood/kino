@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '[GT] 판매오더 Header 정보'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZGTSD_CV_SO_HEADER
  as select from           vbak                   as _Header
    inner join             ZGTSD_CV_SO_HDR_STATUS as _HdrStat  on _Header.vbeln = _HdrStat.vbeln

    left outer to one join vbpa                   as _Shipto   on  _Header.vbeln = _Shipto.vbeln 
                                                               and _Shipto.posnr = '000000'
                                                               and _Shipto.parvw = 'WE'
    left outer join        vbpa                   as _Semp     on  _Header.vbeln = _Semp.vbeln
                                                               and _Semp.posnr   = '000000'
                                                               and _Semp.parvw   = 'VE'
    left outer join        vbpa                   as _Agent    on  _Header.vbeln = _Agent.vbeln
                                                               and _Agent.posnr  = '000000'
                                                               and _Agent.parvw  = 'ZG'
    left outer join        vbpa                   as _Agent2   on  _Header.vbeln = _Agent2.vbeln
                                                               and _Agent2.posnr = '000000'
                                                               and _Agent2.parvw = 'ZH'
    left outer join        vbpa                   as _Payer    on  _Header.vbeln = _Payer.vbeln
                                                               and _Payer.posnr  = '000000'
                                                               and _Payer.parvw  = 'RG'
  //    left outer join vbfa                   as _Docflow  on  _Header.vbeln    = _Docflow.vbelv
  //                                                        and _Docflow.vbtyp_v = _Header.vbtyp
  //                                                        and _Docflow.vbtyp_n = 'C'
  //                                                        and _Docflow.posnv   is initial
  //                                                        and _Docflow.posnn   is initial

  -- 비즈니스 데이터: 헤더 기준 1:1이나 조회 안정성을 위해 LEFT OUTER JOIN 처리
    left outer to one join vbkd                   as _Business on  _Header.vbeln   = _Business.vbeln
                                                               and _Business.posnr = '000000'

  association [1..1] to zsd0106t as _Pjt        on $projection.zpjno = _Pjt.zpjno
  association [1..1] to kna1     as _Cust       on $projection.kunag = _Cust.kunnr
  association [0..1] to lfa1     as _SalesEmp   on $projection.sales_empl = _SalesEmp.lifnr
  association [0..1] to kna1     as _ShipToName on $projection.kunwe = _ShipToName.kunnr
  association [1..1] to kna1     as _PayerName  on $projection.kunrg = _PayerName.kunnr
  association [0..1] to lfa1     as _AgentName  on $projection.kunzg = _AgentName.kunnr
  association [0..1] to lfa1     as _AgentName2 on $projection.kunzh = _AgentName2.kunnr

{
      -- =======================================================================
      -- [1. Key & Basic Information] 문서 기본 정보
      -- =======================================================================
  key cast(_Header.vbeln as vbeln_va preserving type )                as vbeln,
      _Header.auart,
      _Header.vbtyp,
      _Header.vdatu,

      -- =======================================================================
      -- [2. Organizational Information] 조직 데이터
      -- =======================================================================
      cast(_Header.zpjno as zpjno preserving type )                   as zpjno,
      cast(_Pjt.zptxt as zptxt preserving type)                       as zptxt,
      _Pjt.land1                                                      as country,
      _Header.vkorg,
      _Header.vtweg,
      _Header.spart,
      _Header.vkbur,
      _Header.vkgrp,

      -- =======================================================================
      -- [3. Partner Functions] 파트너 데이터
      -- =======================================================================
      cast(_Header.kunnr as kunag preserving type )                   as kunag,
      cast(_Cust.name1 as zgteagname preserving type )                as customername,
      cast(_Shipto.kunnr as kunwe preserving type )                   as kunwe,
      _ShipToName.name1                                               as shipto_name,
      cast(_Payer.kunnr as kunrg preserving type )                    as kunrg,
      cast(_PayerName.name1 as zgtergname preserving type)            as payer_name,
      cast(_Semp.lifnr as zgtesempl preserving type )                 as sales_empl,
      cast(_SalesEmp.name1 as zgtesemplname preserving type )         as empl_name,
      cast(_Agent.lifnr as zgtekunzg preserving type )                as kunzg,
      cast(_AgentName.name1 as zgtezgname preserving type )           as agent1_name,
      cast(_Agent2.lifnr as zgtekunzh preserving type )               as kunzh,
      cast(_AgentName2.name1 as zgtezhname preserving type )          as agent2_name,

      -- =======================================================================
      -- [4. Business & Conditions] 비즈니스 및 조건 데이터
      -- =======================================================================
      cast( _Business.inco1 as inco1 preserving type )                as inco1,
      _Business.zterm,
      _Business.prsdt,
      _Business.kursk,

      -- =======================================================================
      -- [5. Financials & Currency] 금액 및 통화 데이터
      -- =======================================================================
      @Semantics.amount.currencyCode: 'waerk'
      _Header.netwr,
      _Header.waerk,

      -- [5-1] Currency Conversion (외화 금액 원화 환산)
      @Semantics.amount.currencyCode: 'waerk_krw'
      cast(
          case when _Header.waerk <> 'KRW'
               then currency_conversion( amount             => _Header.netwr,
                                         source_currency    => _Header.waerk,
                                         target_currency    => cast( 'KRW' as abap.cuky ),
                                         exchange_rate_date => _Business.prsdt,
                                         exchange_rate_type => 'M',
                                         client             => $session.client )
               else _Header.netwr
          end
      as zgtekrwamt preserving type )                                 as netwr_krw,
      cast( cast( 'KRW' as abap.cuky ) as zgtekrwcur preserving type) as waerk_krw,

      -- =======================================================================
      -- [6. Reference & Tracking] 참조 및 개별 추적 데이터
      -- =======================================================================
      _Header.augru,
      _Header.bstnk,
      _Header.ps_psp_pnr,
      _Header.conno,
      _Header.ztver,
      cast(_Header.zqtno as zgteqtno preserving type )                as zqtno,
      _Header.zexver,
      _Header.zexno,
      _Header.lifsk,
      _Header.vgbel                                                   as precede_vbeln,
      //      _Docflow.vbeln                                   as subsquent_vbeln,

      -- =======================================================================
      -- [7. Header Status] 문서 상태 관리
      -- =======================================================================
      _HdrStat.abstk,
      _HdrStat.drstk,
      _HdrStat.lfstk,
      _HdrStat.wbstk,
      _HdrStat.kpstk,
      _HdrStat.ivstk,
      _HdrStat.gostk,
      _HdrStat.fkstk,
      _HdrStat.dfstk,
      _HdrStat.grstk,

      -- =======================================================================
      -- [8. Administrative Data] (시스템 관리 일자)
      -- =======================================================================
      _Header.erdat,
      _Header.erzet,
      _Header.ernam
}
where
      _Header.augru <> '150' -- 선수금처리용 주문
//  and _Header.augru <> '600'
  and _Header.faksk <> 'G1' -- 소재 매출정산완료
