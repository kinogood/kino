@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '[GT] 판매오더 Item 기준 Billing 정보'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZGTSD_CV_BILLING
  as select from           vbap                           as _SalesItem
    inner join             vbak                           as _SalesHdr  on _SalesItem.vbeln = _SalesHdr.vbeln

  //    inner join             vbrp                      as _Billitem  on  _SalesItem.vbeln       =  _Billitem.aubel
  //                                                                   and _SalesItem.posnr       =  _Billitem.aupos
  //                                                                   and _Billitem.sfakn_ana    is initial
  //                                                                   and (
  //                                                                      _Billitem.vbtyp_ana     <> 'N'
  //                                                                      and _Billitem.vbtyp_ana <> 'S'
  //                                                                    )
  //    inner join             vbrk                      as _BillHdr   on  _Billitem.vbeln =  _BillHdr.vbeln
  //                                                                   and _BillHdr.fksto  <> 'X'

    inner join             ZGTSD_I_VALID_BILLING          as _ValidBill on  _SalesItem.vbeln = _ValidBill.vbeln_so
                                                                        and _SalesItem.posnr = _ValidBill.posnr_so 

    left outer to one join vbpa                           as _Agent     on  _SalesItem.vbeln = _Agent.vbeln
                                                                        and _Agent.posnr     = '000000'
                                                                        and _Agent.parvw     = 'ZG'

    left outer to one join vbpa                           as _Semp      on  _SalesItem.vbeln = _Semp.vbeln
                                                                        and _Semp.posnr      = '000000'
                                                                        and _Semp.parvw      = 'VE'

    left outer to one join ZGTSD_CV_GET_VCOFSO            as _Char      on  _SalesItem.vbeln = _Char.vbeln
                                                                        and _SalesItem.posnr = _Char.posnr

    left outer to one join ZGTSD_I_SO_BL_ITEM_NF_QTY      as _NfQty     on  _SalesItem.vbeln    = _NfQty.vbeln
                                                                        and _SalesItem.posnr    = _NfQty.posnr
                                                                        and _ValidBill.vbeln_bl = _NfQty.bl_vbeln
                                                                        and _ValidBill.posnr_bl = _NfQty.bl_posnr

    left outer to one join ZGTSD_I_MaterialCharacteristic as _MatnrChar on  _SalesItem.matnr = _MatnrChar.matnr
                                                                        and _MatnrChar.atnam = 'MS-AUSP-ZSPART'

  association [1..1] to zsd0106t as _Pjt        on $projection.zpjno = _Pjt.zpjno
  association [1..1] to kna1     as _Cust       on $projection.kunag = _Cust.kunnr
  association [0..1] to kna1     as _ShipToName on $projection.kunwe = _ShipToName.kunnr
  association [0..1] to lfa1     as _SalesEmp   on $projection.sales_empl = _SalesEmp.lifnr
  association [1..1] to kna1     as _Payer      on $projection.kunrg = _Payer.kunnr
{
         -- =======================================================================
         -- [1] Key Information (키 정보)
         -- =======================================================================
  key    _SalesItem.vbeln,                                                                        -- 판매오더 번호
  key    cast(_SalesItem.posnr as posnr_va preserving type )                            as posnr, -- 판매오더 품목 번호
  key    cast(_ValidBill.vbeln_do  as vbeln_vl preserving type )                        as do_vbeln, -- 납품문서 번호
  key    cast(_ValidBill.posnr_do  as posnr_vl preserving type )                        as do_posnr, -- 납품문서 품목

         -- =======================================================================
         -- [2] Document References (문서 참조 정보)
         -- =======================================================================
         cast(_ValidBill.vbeln_bl  as vbeln_vf preserving type )                        as bl_vbeln,   -- 청구문서 번호
         cast(_ValidBill.posnr_bl  as posnr_vf preserving type )                        as bl_posnr,   -- 청구문서 품목
         cast(_SalesHdr.zpjno  as zpjno    preserving type )                            as zpjno,   -- 프로젝트 번호
         cast(_Pjt.zptxt as zptxt preserving type )                                     as zptxt,   -- 프로젝트명
         _Pjt.land1                                                                     as country, -- 프로젝트 국가코드
         _SalesHdr.bstnk,                                                                           -- 고객 구매오더 번호

         -- =======================================================================
         -- [3] Document Types & Classification (문서 유형 및 분류)
         -- =======================================================================
         _ValidBill.fkdat,                                                                          -- 청구일
         _ValidBill.fkart,                                                                          -- 청구 유형
         _SalesItem.auart_ana                                                           as auart,   -- 판매오더 유형
         _SalesItem.vbtyp_ana                                                           as vbtyp,   -- SD 문서 범주
         _SalesItem.spart_ana                                                           as spart,   -- 헤더 제품군
         cast(_SalesItem.spart as zgtespart_i preserving type )                         as item_spart, -- 품목 제품군
         _SalesHdr.zqtno,                                                                              -- 견적번호
         _SalesHdr.ztver,                                                                              -- 견적버전
         _SalesHdr.zexno,                                                                              -- 실행번호
         _SalesHdr.zexver,                                                                             -- 실행구분
         _SalesHdr.augru,                                                                              -- Order Reason

         -- =======================================================================
         -- [4] Organizational Data (조직 정보)
         -- =======================================================================
         _SalesItem.vkorg_ana                                                           as vkorg,   -- 영업 조직
         _SalesItem.vtweg_ana                                                           as vtweg,   -- 유통 경로
         _SalesItem.vkbur_ana                                                           as vkbur,   -- 영업소
         _SalesItem.vkgrp_ana                                                           as vkgrp,   -- 영업그룹
         _ValidBill.werks, -- 플랜트
         _ValidBill.lgort, -- 저장 위치
         _ValidBill.vstel, -- 출하 지점

         -- =======================================================================
         -- [5] Partner Information (파트너 정보)
         -- =======================================================================
         _SalesItem.kunnr_ana                                                           as kunag, -- 판매처
         cast(_Cust.name1 as zgteagname preserving type )                               as customername, -- 판매처명
         _SalesItem.kunwe_ana                                                           as kunwe, -- 인도처
         cast(_ShipToName.name1 as zgtewename preserving type )                         as shipto_name, -- 인도처명
         _SalesItem.kunrg_ana                                                           as kunrg, -- 지급처
         cast(_Payer.name1 as zgtergname preserving type )                              as payer_name, -- 지급처명
         cast(_Semp.lifnr as zgtesempl preserving type )                                as sales_empl, -- 영업 사원 (VE)
         cast(_SalesEmp.name1 as zgtesemplname preserving type )                        as empl_name, -- 영업 사원명
         cast(_Agent.lifnr as zgtekunzg preserving type )                               as agent, -- 수출 Agent (ZG)

         -- =======================================================================
         -- [6] Material & Characteristics (자재 및 특성 정보)
         -- =======================================================================
         cast(_SalesItem.fixmg as zgtemfgenv preserving type )                          as mfgenv,     -- OM/SM
         cast(_SalesItem.mvgr3 as zgtestdlen preserving type )                          as stdlen,     -- 정조장 여부
         _SalesItem.prodh,                                                                             -- 제품계층구조
         _ValidBill.matnr, -- 자재 번호
         _ValidBill.arktx, -- 자재 내역 (품목 텍스트)
         _MatnrChar.atwrt                                                               as spart_gaon, -- 가온전선 제품분류

         cast(_Char.SPECNO  as zespecno preserving type )                               as specno,     -- 규격 번호 (특성값)
         cast(cast(_Char.COLOR as abap.char(6)) as zzcolor_base preserving type )       as color,      -- 색상 (특성값)
         _Char.STRIPE_COLOR,                                                                           -- 띄줄색상
         _Char.STRIPE_CNT,                                                                             -- 띄줄 수
         @Semantics.quantity.unitOfMeasure: 'vrkme'
         cast( cast(_Char.LENGTH as abap.quan(13,3)) as zgteweleng preserving type )    as length,     -- 길이 (특성값)
         cast(cast(_Char.FACTOR as int4 )  as zgtewecnt preserving type )               as factor,     -- 팩터/계수 (특성값)

         -- =======================================================================
         -- [7] Quantities & Units (수량 및 단위 정보)
         -- =======================================================================
         @Semantics.quantity.unitOfMeasure: 'vrkme'
         _ValidBill.fkimg, -- 청구 수량
         _ValidBill.vrkme, -- 판매 단위
         cast(_NfQty.nes_cu as zgtenf_key_cu preserving type )                          as nes_cu,  -- 비철: CU
         @Semantics.quantity.unitOfMeasure: 'cu_unit'
         cast(cast(_NfQty.bl_cu as abap.quan(15,4)) as zgtenf_bl_cu preserving type )   as bl_cu,   -- 비철: 청구 비철 수량 - CU
         cast(_NfQty.cu_unit as zgtenf_cu_uom preserving type )                         as cu_unit, -- 비철: 수량 단위 - CU

         cast(_NfQty.nes_al as zgtenf_key_al preserving type )                          as nes_al,  -- 비철: AL
         @Semantics.quantity.unitOfMeasure: 'al_unit'
         cast(cast(_NfQty.bl_al as abap.quan(15,4)) as zgtenf_bl_al preserving type )   as bl_al,   -- 비철: 청구 비철 수량 - AL
         cast(_NfQty.al_unit as zgtenf_al_uom preserving type )                         as al_unit, -- 비철: 수량 단위 - AL


         cast(_NfQty.nes_fi as zgtenf_key_fi preserving type )                          as nes_fi,  -- 비철: FI
         @Semantics.quantity.unitOfMeasure: 'fi_unit'
         cast(cast(_NfQty.bl_fi   as abap.quan(15,4)) as zgtenf_bl_fi preserving type ) as bl_fi,   -- 비철: 청구 비철 수량 - FI
         cast(_NfQty.fi_unit as zgtenf_fi_uom preserving type )                         as fi_unit, -- 비철: 수량 단위 -FI

         -- =======================================================================
         -- [8] Pricing, Amounts & Currency (단가, 금액 및 통화 정보)
         -- =======================================================================
         @Semantics.amount.currencyCode: 'waerk'
         _ValidBill.netwr, -- 청구 순가치 금액
         @Semantics.amount.currencyCode: 'waerk'
         _ValidBill.mwsbp, -- 세금 금액
         _ValidBill.waerk, -- 문서 통화
         _ValidBill.prsdt, -- 가격결정일
         _ValidBill.kursk, -- 환율

         -- [8-1] Currency Conversion (원화 환산 금액)
         @Semantics.amount.currencyCode: 'waerk_krw'
         cast(
             case when _ValidBill.waerk <> 'KRW'
                  then currency_conversion( amount             => _ValidBill.netwr,
                                            source_currency    => _ValidBill.waerk,
                                            target_currency    => cast( 'KRW' as abap.cuky ),
                                            exchange_rate_date => _ValidBill.prsdt,
                                            exchange_rate_type => 'M',
                                            client             => $session.client )
                  else _ValidBill.netwr
             end
         as zgtekrwamt preserving type )                                                as bl_netwr_krw, -- 원화 환산 청구 순가치
         cast( cast( 'KRW' as abap.cuky ) as zgtekrwcur preserving type)                as waerk_krw,

         -- =======================================================================
         -- [9] Status & Dates (상태 및 일자 정보)
         -- =======================================================================
         _ValidBill.zzbilnr, -- 세금계산서 발행번호
         _ValidBill.vf_status_ana, -- 청구 상태 (분석용)
         _ValidBill.zzwadat_ist                                                         as wadat_ist, -- 실제 출고일 (Custom)
         _SalesItem.erdat, -- 레코드 생성일
         _SalesItem.erzet, -- 입력 시간
         _SalesItem.ernam  -- 생성자 이름
}
where
      _SalesHdr.augru  <> '150'
//  and _SalesHdr.augru  <> '600'
  and _SalesHdr.faksk  <> 'G1'
//  and _SalesItem.pstyv <> 'ZADP'
