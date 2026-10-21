@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '[GT} 판매오더 Item 기준 납품오더 정보'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZGTSD_CV_DELIVERYORDER
  as select from           vbap                           as _Item

    inner join             ZGTSD_CV_GET_DLVQTY_FACTOR     as _DelivBase on  _Item.vbeln = _DelivBase.vgbel
                                                                        and _Item.posnr = _DelivBase.vgpos

    inner join             lips                           as _DelivItem on  _DelivBase.vbeln = _DelivItem.vbeln
                                                                        and _DelivBase.posnr = _DelivItem.posnr

    inner join             likp                           as _DelivHdr  on _DelivBase.vbeln  = _DelivHdr.vbeln
                                                                        and(
                                                                          _DelivHdr.vbtyp    = 'J'
                                                                          or _DelivHdr.vbtyp = 'T'
                                                                        )
 
    inner join             vbak                           as _Header    on _Item.vbeln = _Header.vbeln
    
    inner join             vbpa                           as _Shipto    on  _DelivHdr.vbeln = _Shipto.vbeln
                                                                        and _Shipto.posnr = '000000'
                                                                        and _Shipto.parvw = 'WE'
                                                                        and _DelivHdr.kunnr = _Shipto.kunnr
    
    inner join             adrc                           as _DelivAdr   on _Shipto.adrnr = _DelivAdr.addrnumber
    
    left outer to one join ZGTSD_I_VALID_INV_ITEM         as _ValidIv   on  _DelivBase.vbeln = _ValidIv.vbeln
                                                                        and _DelivBase.posnr = _ValidIv.posnr
                                                                        and _ValidIv.iv_type = 'A01'

    left outer to one join ZGTSD_I_SO_ITEM_NF_QTY         as _Nf        on  _DelivBase.vbeln = _Nf.do_vbeln
                                                                        and _DelivBase.posnr = _Nf.do_posnr

    left outer to one join vbkd                           as _Business  on  _Item.vbeln     = _Business.vbeln
                                                                        and _Business.posnr = '000000'

    left outer to one join vbkd                           as _BusiItm   on  _Item.vbeln     = _BusiItm.vbeln
                                                                        and _Item.posnr     = _BusiItm.posnr
                                                                        
    left outer to one join ZGTSD_CV_GET_VCOFSO           as _Char       on _Item.vbeln  = _Char.vbeln
                                                                        and _Item.posnr = _Char.posnr

//    left outer to one join ZGTSD_I_MaterialCharacteristic as _CharColor on  _Item.matnr      = _CharColor.matnr
//                                                                        and _CharColor.atnam = 'PD_CA_COLOR_BASE'
//
//    left outer to one join ZGTSD_I_MaterialCharacteristic as _CharSpec  on  _Item.matnr     = _CharSpec.matnr
//                                                                        and _CharSpec.atnam = 'PD_CA_SPEC_NO'
//
//    left outer to one join ZGTSD_I_MaterialCharacteristic as _MatnrChar on  _Item.matnr      = _MatnrChar.matnr
//                                                                        and _MatnrChar.atnam = 'MS-AUSP-ZSPART'

    left outer to one join vbpa                           as _Partner   on  _Item.vbeln    = _Partner.vbeln
                                                                        and _Partner.posnr = '000000'
                                                                        and _Partner.parvw = 'VE'

  association [1..1] to zsd0106t as _Pjt        on $projection.zpjno = _Pjt.zpjno
  association [1..1] to kna1     as _Cust       on $projection.kunag = _Cust.kunnr
  association [0..1] to kna1     as _ShipToName on $projection.kunwe = _ShipToName.kunnr
  association [0..1] to lfa1     as _SalesEmp   on $projection.sales_empl = _SalesEmp.lifnr
  association [1..1] to kna1     as _Payer      on $projection.kunrg = _Payer.kunnr

{
      -- =======================================================================
      -- [1] Sales Order Key (판매오더 키 정보)
      -- =======================================================================
  key cast(_Item.vbeln as vbeln_va preserving type )                                as vbeln,      -- 판매오더 번호
  key cast(_Item.posnr as posnr_va preserving type )                                as posnr,      -- 판매오더 품목 번호

      -- =======================================================================
      -- [2] Delivery Key (납품문서 키 정보)
      -- =======================================================================
  key cast(_DelivBase.vbeln as vbeln_vl preserving type )                           as do_vbeln,   -- 납품문서 번호
  key cast(_DelivBase.posnr as posnr_vl preserving type )                           as do_posnr,   -- 납품문서 품목 번호

      -- =======================================================================
      -- [3] Organizational & Partner (조직 및 파트너 정보)
      -- =======================================================================
      _DelivHdr.lfart,                                                                             -- 납품 유형 (Delivery Type)
      _Item.auart_ana                                                               as auart,      -- 판매오더 유형 (Sales Document Type)
      _Item.vbtyp_ana                                                               as vbtyp,      -- SD 문서 범주 (SD Document Category)
      cast(_Header.zpjno as zpjno preserving type )                                 as zpjno,      -- 프로젝트 번호 (Custom Project No)
      cast(_Pjt.zptxt as zptxt preserving type )                                    as zptxt,      -- 프로젝트명 (Project Name)
      _Pjt.land1                                                                    as country,    -- 프로젝트 국가코드 (Country Code)
      _Item.vkorg_ana                                                               as vkorg,      -- 영업 조직 (Sales Organization)
      _Item.vtweg_ana                                                               as vtweg,      -- 유통 경로 (Distribution Channel)
      _Item.spart_ana                                                               as spart,      -- 헤더 제품군 (Division at Header)
      _Item.spart                                                                   as item_spart, -- 품목 제품군 (Division at Item)
      _Header.bstnk,                                                                               -- 고객 구매오더 번호 (Customer PO Number)
      _Header.augru,                                                                               -- 오더 사유 (Order Reason)
      _Item.vkbur_ana                                                               as vkbur,      -- 영업소 (Sales Office)
      _Item.vkgrp_ana                                                               as vkgrp,      -- 영업 그룹 (Sales Group)
      _Item.kunnr_ana                                                               as kunag,      -- 판매처 (Sold-to Party)
      cast(_Cust.name1 as zgteagname preserving type )                              as customername, -- 판매처명 (Customer Name)
      cast(_Item.kunwe_ana as kunwe preserving type )                               as kunwe,        -- 인도처 (Ship-to Party)
      cast(_ShipToName.name1 as zgtewename preserving type )                        as shipto_name,  -- 인도처명 (Ship-to Party Name)
      cast(_DelivAdr.city1 as zgteadrwe preserving type )                           as shipto_addr,  -- 납품처 주소
      _DelivAdr.street                                                              as shipto_addr2,  -- 납품처 주소
      cast(_Item.kunrg_ana as kunrg preserving type )                               as kunrg,        -- 지급처 (Payer)
      cast(_Payer.name1 as zgtergname preserving type )                             as payer_name,   -- 지급처명 (Payer Name)
      cast(_Partner.lifnr as zgtesempl preserving type )                            as sales_empl,   -- 영업 사원 번호 (Sales Employee)
      cast(_SalesEmp.name1 as zgtesemplname preserving type )                       as empl_name,    -- 영업 사원명 (Employee Name)

      -- =======================================================================
      -- [4] Logistics Data (물류 및 일정 정보)
      -- =======================================================================
      _DelivItem.werks,                                                                            -- 플랜트 (Plant)
      _DelivItem.lgort,                                                                            -- 저장 위치 (Storage Location)
      _DelivHdr.vstel,                                                                             -- 출하 지점 (Shipping Point)
      _DelivHdr.route,                                                                             -- 경로 (Route)
      _DelivHdr.lifsk,                                                                             -- 납품 보류 사유 (Delivery Block)
      _DelivHdr.wadat,                                                                             -- 계획 출고일 (Planned Goods Issue Date)

      -- 적송('ZLF3')이면 'LF' 혹은 'ZLF'에서 출고일자(wadat_ist)를 가져옴
      _DelivHdr.wadat_ist,
      //      case when _DelivHdr.wadat_ist is initial
      //           then _Wbsta.wadat_ist
      //           else _DelivHdr.wadat_ist end                               as wadat_ist, -- 실제 출고일 (Actual Goods Issue Date)

      -- =======================================================================
      -- [5] Quantities & Characteristics (수량 및 특성값 정보)
      -- =======================================================================
      cast(_Item.fixmg as zgtemfgenv preserving type )                              as mfgenv,     -- OM/SM 구분 여부
      cast(_Item.mvgr3 as zgtestdlen preserving type )                              as stdlen,     -- 정조장 여부 (자재그룹 3)
      _Item.prodh,                                                                                 -- 제품 계층구조 (Product Hierarchy)
      _DelivBase.matnr,                                                                            -- 자재 번호 (Material Number)
      _DelivBase.arktx,                                                                            -- 자재 내역 (Material Description)
      cast(
            cast(_Char.ZSPART as abap.char(4)) 
      as zgtespart_go preserving type )                                            as spart_gaon, -- 가온전선 제품분류 
      _Char.SPECNO,
      _Char.COLOR,
      _Char.STRIPE_COLOR,
      _Char.STRIPE_CNT,

      @Semantics.quantity.unitOfMeasure: 'vrkme'
      case when _Item.shkzg is not initial
           then  _DelivBase.LENGTH * -1
           else _DelivBase.LENGTH
      end                                                                           as length, -- 길이 (납품 배치 특성값)
      case when _Item.shkzg is not initial
           then _DelivBase.factor * -1
           else _DelivBase.factor
      end                                                                           as factor, -- 조장 수/팩터 (납품 배치 특성값)
      @Semantics.quantity.unitOfMeasure: 'vrkme'
      case when _Item.shkzg is not initial
           then _DelivBase.lfimg * -1
           else _DelivBase.lfimg
      end                                                                           as lfimg,  -- 납품 수량 (Delivery Quantity)
      _DelivItem.vrkme, -- 판매/납품 단위 (Sales Unit)

      -- =======================================================================
      -- [6] Pricing & Amounts (단가, 금액 및 통화 정보)
      -- =======================================================================
      @Semantics.amount.currencyCode: 'waerk'
      case when _Item.shkzg is not initial
           then _Item.netpr*-1
           else _Item.netpr end                                                     as netpr, -- 순단가 (Net Price)
      @Semantics.amount.currencyCode: 'waerk'
      case when _Item.shkzg is not initial
           then
              cast(
                cast( _Item.netpr as abap.dec(15,2) ) * cast( _DelivBase.lfimg as abap.dec(13,3) ) * -1
              as abap.curr(15,2) )
           else

              cast(
                cast( _Item.netpr as abap.dec(15,2) ) * cast( _DelivBase.lfimg as abap.dec(13,3) )
              as abap.curr(15,2) )
      end                                                                           as do_netwr, -- 납품 수량 기준 순가치 금액 (Net Value = Price * Qty)
      _Item.waerk, -- 문서 통화 (Document Currency)

      -- =======================================================================
      -- [7] Currency Conversion (원화 금액 환산 정보)
      -- =======================================================================
      _Business.prsdt,                                                                             -- 가격 결정일 (Pricing Date)
      _Business.kursk,                                                                             -- 환율 (Exchange Rate)
      _BusiItm.bstkd_e,                                                                            -- ASIS작번

      @Semantics.amount.currencyCode: 'waerk_krw'
      cast(
          cast(
              case when _Item.waerk <> 'KRW'
                   then currency_conversion(
                         amount             => case when _Item.shkzg is not initial
                                                    then _Item.netpr*-1
                                                    else _Item.netpr end,
                         source_currency    => _Item.waerk,
                         target_currency    => cast( 'KRW' as abap.cuky ),
                         exchange_rate_date => _Business.prsdt,
                         exchange_rate_type => 'M',
                         client             => $session.client
                       )
                   else cast( case when _Item.shkzg is not initial
                                   then _Item.netpr*-1
                                   else _Item.netpr end
                        as abap.curr( 15, 2 ) )
              end
          as abap.curr(15,2))
      as zgtekrwprice preserving type )                                             as do_netpr_krw,


      @Semantics.amount.currencyCode: 'waerk_krw'
      cast(
        cast(
          cast(
            case when _Item.waerk <> 'KRW'
                 then currency_conversion(
                        amount             => case when _Item.shkzg is not initial
                                                   then _Item.netpr*-1
                                                   else _Item.netpr end,
                        source_currency    => _Item.waerk,
                        target_currency    => cast( 'KRW' as abap.cuky ),
                        exchange_rate_date => _Business.prsdt,
                        exchange_rate_type => 'M',
                        client             => $session.client
                      )
                 else case when _Item.shkzg is not initial
                           then _Item.netpr*-1
                           else _Item.netpr end
            end
            as abap.dec( 15, 2 ) )
          * cast( case when _Item.shkzg is not initial
                       then _DelivBase.lfimg*-1
                       else _DelivBase.lfimg end
            as abap.dec( 13, 3 ) )
          as abap.curr( 15, 2 ) )
        as zgtekrwamt preserving type )                                             as do_netwr_krw, -- 원화 환산 납품 순가치 금액

      cast( cast( 'KRW' as abap.cuky ) as zgtekrwcur preserving type)               as waerk_krw, -- 원화 통화 키 ('KRW')

      -- =======================================================================
      -- [8] Non-Ferrous Quantities (비철 함량 수량 정보)
      -- =======================================================================
      _Nf.nes_cu, -- 비철 식별키: CU
      @Semantics.quantity.unitOfMeasure: 'cu_unit'
      case when _Item.shkzg is not initial
           then _Nf.do_cu*-1
           else _Nf.do_cu end                                                       as do_cu, -- 납품 기준 비철 수량 (CU)
      _Nf.cu_unit,                                                                                 -- 비철 수량 단위: CU

      _Nf.nes_al,                                                                                  -- 비철 식별키: AL
      @Semantics.quantity.unitOfMeasure: 'al_unit'
      case when _Item.shkzg is not initial
           then _Nf.do_al*-1
           else _Nf.do_al end                                                       as do_al,      -- 납품 기준 비철 수량 (AL)
      _Nf.al_unit,                                                                                 -- 비철 수량 단위: AL

      _Nf.nes_fi,                                                                                  -- 비철 식별키: FI
      @Semantics.quantity.unitOfMeasure: 'fi_unit'
      case when _Item.shkzg is not initial
           then _Nf.do_fi*-1
           else _Nf.do_fi end                                                       as do_fi, -- 납품 기준 비철 수량 (FI)
      _Nf.fi_unit, -- 비철 수량 단위: FI

      -- =======================================================================
      -- [9] Status (상태 정보)
      -- =======================================================================
      _Item.absta, -- 거부 상태 (Rejection Status)
      //      _Wbsta.wbsta                                                    as wbsta,      -- 출고 상태 (Goods Issue Status)
      _DelivItem.kosta,                                                                      -- Picking 상태 (Picking Status)
      _DelivItem.wbsta,
      //      _Fksta.fksta                                                    as fksta,      -- 청구 상태 (Billing Status)
      _DelivItem.fksta,

      -- =======================================================================
      -- [10] Invoice & Gate Out Info (명세서 및 통문 정보 - Custom)
      -- =======================================================================
      _ValidIv.iv_print_yn, -- 명세서 출력 여부 (Invoice Print Indicator)
      _ValidIv.iv_no,       -- 명세서 번호 (Invoice Number)
      _ValidIv.iv_date,     -- 명세서 발행일자 (Invoice Date)
      _ValidIv.out_yn,      -- 통문 처리(반출) 여부 (Gate-Out Indicator)
      _ValidIv.out_date,    -- 반출 일자 (Gate-Out Date)
      _ValidIv.out_time,    -- 반출 시간 (Gate-Out Time)

      -- =======================================================================
      -- [11] Administrative Data (시스템 관리 정보)
      -- =======================================================================
      _Header.zqtno,
      _Header.ztver,
      _Header.zexno,
      _Header.zexver,
      _Item.erdat,                                                                                 -- 레코드 생성일 (Creation Date)
      _Item.erzet,                                                                                 -- 입력 시간 (Creation Time)
      _Item.ernam
      -- 생성자 이름 (Created By)
}
where
      _Header.augru <> '150'
//  and _Header.augru <> '600'   
  and _Header.faksk <> 'G1' -- 소재 매출정산 완료
//  and _Item.pstyv   <> 'ZADP'
