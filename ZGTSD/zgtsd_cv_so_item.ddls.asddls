@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '[GT] 판매오더 Item 정보'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZGTSD_CV_SO_ITEM
  as select from           ZGTSD_I_SO_ITEM_BASIC          as _Basic 

    left outer to one join ZGTSD_CV_GET_VCOFSO            as _CharSet   on  _Basic.vbeln = _CharSet.vbeln
                                                                        and _Basic.posnr = _CharSet.posnr

    left outer to one join ZGTSD_CV_SUM_SO_ITEM_NF_QTY    as _NfDo      on  _Basic.vbeln = _NfDo.vbeln
                                                                        and _Basic.posnr = _NfDo.posnr

    left outer to one join ZGTSD_CV_SUM_SO_BL_ITEM_NF_QTY as _NfBL      on  _Basic.vbeln = _NfBL.vbeln
                                                                        and _Basic.posnr = _NfBL.posnr

    left outer to one join ZGTSD_CV_GET_SUM_LINK_STOCK    as _Lstock    on  _Basic.vbeln = _Lstock.vbeln
                                                                        and _Basic.posnr = _Lstock.posnr

    left outer to one join ZGTSD_CV_SUM_SO_STOCK_BY_LEN   as _Estock    on  _Basic.vbeln = _Estock.vbeln
                                                                        and _Basic.posnr = _Estock.posnr                                                                        

    left outer to one join ZGTSD_I_SO_ITEM_DFRD_QTY       as _DfrQty    on  _Basic.vbeln = _DfrQty.vbeln
                                                                        and _Basic.posnr = _DfrQty.posnr

    left outer to one join ZGTSD_I_MaterialCharacteristic as _MatnrChar on  _Basic.matnr     = _MatnrChar.matnr
                                                                        and _MatnrChar.atnam = 'MS-AUSP-ZSPART'
    
    left outer to one join ZGTSD_I_MaterialCharacteristic as _MatnrColor on _Basic.matnr = _MatnrColor.matnr
                                                                         and _MatnrColor.atnam = 'PD_CA_COLOR_BASE'

    left outer to one join ZGTSD_I_MaterialCharacteristic as _MatnrStripeClr on _Basic.matnr = _MatnrStripeClr.matnr
                                                                         and _MatnrStripeClr.atnam = 'PD_CA_COLOR_STRIPE'

    left outer to one join ZGTSD_I_MaterialCharacteristic as _MatnrStripeNo on _Basic.matnr = _MatnrStripeNo.matnr
                                                                         and _MatnrStripeNo.atnam = 'PD_CA_COLOR_STRIPE_NO'


{
      -- =======================================================================
      -- [1] Key & Document Basic (키 및 문서 기본 정보)
      -- =======================================================================
  key _Basic.vbeln,                                                                          -- 판매오더 번호
  key _Basic.posnr,                                                                          -- 판매오더 품목 번호
      _Basic.auart,                                                                          -- 판매오더 유형 (문서 타입)
      _Basic.vbtyp,                                                                          -- SD 문서 범주 (예: C=오더)
      _Basic.zpjno,                                                                          -- 프로젝트 번호 (Custom)
      _Basic.zptxt,                                                                          -- 프로젝트명
      _Basic.country,                                                                        -- 프로젝트 국가코드
      _Basic.zqtno,                                                                          -- 견적번호
      _Basic.ztver,                                                                          -- 견적버전
      _Basic.zexno,                                                                          -- 실행번호
      _Basic.zexver,                                                                         -- 실행구분
      _Basic.bstkd_e,                                                                        -- ASIS작번
      _Basic.augru,                                                                          -- Order Reason

      -- =======================================================================
      -- [2] Partner Information (파트너 정보)
      -- =======================================================================
      _Basic.kunag,                                                                          -- 판매처 (Sold-to party)
      _Basic.customername,                                                                   -- 판매처명
      _Basic.kunwe,                                                                          -- 인도처 (Ship-to party)
      _Basic.shipto_name,                                                                    -- 인도처명
      _Basic.kunrg,                                                                          -- 지급처 (Payer)
      _Basic.payer_name,                                                                     -- 지급처명
      _Basic.sales_empl,                                                                     -- 영업 사원 (Sales Employee)
      _Basic.empl_name,                                                                      -- 영업 사원명 (Sales Employee Name)

      -- =======================================================================
      -- [3] Organizational & Logistics (조직 및 물류 정보)
      -- =======================================================================
      _Basic.vkorg,                                                                          -- 영업 조직
      _Basic.vtweg,                                                                          -- 유통 경로
      _Basic.vkbur,                                                                          -- 영업소
      _Basic.vkgrp,                                                                          -- 영업 그룹
      _Basic.spart,                                                                          -- 헤더 제품군 (Division)
      _Basic.item_spart,                                                                     -- 품목 제품군
      _Basic.bstnk,                                                                          -- 고객 구매오더 번호 (PO Number)
      _Basic.werks,                                                                          -- 플랜트
      _Basic.vstel,                                                                          -- 출하 지점 (Shipping Point)

      -- =======================================================================
      -- [4] Material & Characteristics (자재 및 특성값)
      -- =======================================================================
      cast(_Basic.fixmg as zgtemfgenv preserving type )                            as mfgenv,-- OM/SM 구분 (Fixed Qty and date)
      cast(_Basic.mvgr3 as zgtestdlen preserving type )                            as stdlen,-- 정조장 여부 (자재그룹 3)
      _Basic.prodh,                                                                          -- 제품 계층구조 (Product Hierarchy)
      _Basic.matnr,                                                                          -- 자재 번호
      _Basic.arktx,                                                                          -- 자재 내역 (품목 텍스트)
      cast( case when _CharSet.ZSPART is not initial 
                    then cast(_CharSet.ZSPART as abap.char(4))
                 when _MatnrChar.atwrt is not initial 
                    then cast(_MatnrChar.atwrt as abap.char(4))
                 else null end as zgtespart_go preserving type )
                                                                                   as spart_gaon,  -- 가온전선 제품분류
      _CharSet.SPECNO,                                                                             -- 규격 번호 (배치 특성값)
      _MatnrColor.atwrt                                                            as COLOR,       -- 색상 (Class 001 Value)
      _MatnrStripeClr.atwrt                                                        as STRIPE_COLOR,-- 띠줄 색상 (Class 001 Value)
      _MatnrStripeNo.atwrt                                                         as STRIPE_CNT,  -- 띠줄 수 (Class 001 Value)
      @Semantics.quantity.unitOfMeasure: 'vrkme'
      cast( cast( case when _Basic.shkzg is not initial
                       then _CharSet.LENGTH * -1
                       else _CharSet.LENGTH end
                  as abap.quan(13,3) )
            as zgteweleng preserving type )                                        as length,-- 길이

      case when _Basic.shkzg is not initial
           then _CharSet.FACTOR * -1
           else _CharSet.FACTOR end                                                as factor,-- 팩터/조장 수

      -- =======================================================================
      -- [5] Quantities & UoM (수량 및 단위 정보)
      -- =======================================================================
      @Semantics.quantity.unitOfMeasure: 'vrkme'
      cast( cast( case when _Basic.shkzg is not initial
                       then _Basic.kwmeng * -1
                       else _Basic.kwmeng end
                  as abap.quan(15,3) )
            as kwmeng preserving type )                                            as kwmeng,-- 주문 수량 (누적)
      _Basic.vrkme,                                                                          -- 판매 단위 (UoM)
      @Semantics.quantity.unitOfMeasure: 'vrkme'
      cast( cast( case when _Basic.shkzg is not initial
                       then _NfDo.sum_lfimg * -1
                       else _NfDo.sum_lfimg end
                  as abap.quan(13,3) )
            as lfimg preserving type )                                             as lfimg, -- 총 납품 수량
      @Semantics.quantity.unitOfMeasure: 'vrkme'
      cast( cast( case when _Basic.shkzg is not initial
                       then _NfBL.sum_fkimg * -1
                       else _NfBL.sum_fkimg end
                  as abap.quan(13,3) )
            as fkimg preserving type )                                             as fkimg, -- 총 청구 수량
      @Semantics.quantity.unitOfMeasure: 'vrkme'
      _DfrQty.dfimg_a,                                                                       -- 적송 진행 중 수량 (Deferred Qty - Active)
      @Semantics.quantity.unitOfMeasure: 'vrkme'
      _DfrQty.dfimg_c,                                                                       -- 적송 완료 수량 (Deferred Qty - Completed)

      -- =======================================================================
      -- [6] Stock Information (재고 정보)
      -- =======================================================================
      @Semantics.quantity.unitOfMeasure: 'vrkme'
      cast(_Lstock.length as zgtelength_l preserving type )                       as l_length,
      @Semantics.quantity.unitOfMeasure: 'vrkme'
      _Lstock.LStock,                                                                        -- 링크 재고 (할당된 재고량)
      @Semantics.quantity.unitOfMeasure: 'vrkme'
      cast( 
        cast(_Estock.length as abap.quan(13,3)) 
        as zgtelength_e preserving type )                                         as e_length, -- 가용 재고 길이
      @Semantics.quantity.unitOfMeasure: 'vrkme'                      
      _Estock.Estock,                                                                        -- 가용 재고 (길이별 잔여 재고량)

      -- =======================================================================
      -- [7] Non-Ferrous Quantities (비철 수량 정보)
      -- =======================================================================
      -- [7-1] Copper (구리 함량)
      _NfDo.nes_cu,                                                                          -- 비철 식별키: CU
      @Semantics.quantity.unitOfMeasure: 'cu_unit'
      cast( cast( case when _Basic.shkzg is not initial
                       then _NfDo.so_cu * -1
                       else _NfDo.so_cu end
                  as abap.quan(15,4) )
            as zgtenf_so_cu preserving type )                                      as so_cu, -- 오더 기준 비철 수량 (CU)
      @Semantics.quantity.unitOfMeasure: 'cu_unit'
      cast( cast( case when _Basic.shkzg is not initial
                       then _NfDo.sum_do_cu * -1
                       else _NfDo.sum_do_cu end
                  as abap.quan(15,4) )
            as zgtenf_do_cu preserving type )                                      as do_cu, -- 납품 기준 비철 수량 (CU)
      @Semantics.quantity.unitOfMeasure: 'cu_unit'
      cast( cast( case when _Basic.shkzg is not initial
                       then _NfBL.sum_bl_cu * -1
                       else _NfBL.sum_bl_cu end
                  as abap.quan(15,4) )
            as zgtenf_bl_cu preserving type )                                      as bl_cu, -- 청구 기준 비철 수량 (CU)
      _NfDo.cu_unit,                                                                         -- 비철 수량 단위: CU

      -- [7-2] Aluminium (알루미늄 함량)
      _NfDo.nes_al,                                                                          -- 비철 식별키: AL
      @Semantics.quantity.unitOfMeasure: 'al_unit'
      cast( cast( case when _Basic.shkzg is not initial
                       then _NfDo.so_al * -1
                       else _NfDo.so_al end
                  as abap.quan(15,4) )
            as zgtenf_so_al preserving type )                                      as so_al, -- 오더 기준 비철 수량 (AL)
      @Semantics.quantity.unitOfMeasure: 'al_unit'
      cast( cast( case when _Basic.shkzg is not initial
                       then _NfDo.sum_do_al * -1
                       else _NfDo.sum_do_al end
                  as abap.quan(15,4) )
            as zgtenf_do_al preserving type )                                      as do_al, -- 납품 기준 비철 수량 (AL)
      @Semantics.quantity.unitOfMeasure: 'al_unit'
      cast( cast( case when _Basic.shkzg is not initial
                       then _NfBL.sum_bl_al * -1
                       else _NfBL.sum_bl_al end
                  as abap.quan(15,4) )
            as zgtenf_bl_al preserving type )                                      as bl_al, -- 청구 기준 비철 수량 (AL)
      _NfDo.al_unit,                                                                         -- 비철 수량 단위: AL

      -- [7-3] Fiber (광섬유 함량)
      _NfDo.nes_fi,                                                                          -- 비철 식별키: FI
      @Semantics.quantity.unitOfMeasure: 'fi_unit'
      cast( cast( case when _Basic.shkzg is not initial
                       then _NfDo.so_fi * -1
                       else _NfDo.so_fi end
                  as abap.quan(15,4) )
            as zgtenf_so_fi preserving type )                                      as so_fi, -- 오더 기준 비철 수량 (FI)
      @Semantics.quantity.unitOfMeasure: 'fi_unit'
      cast( cast( case when _Basic.shkzg is not initial
                       then _NfDo.sum_do_fi * -1
                       else _NfDo.sum_do_fi end
                  as abap.quan(15,4) )
            as zgtenf_do_fi preserving type )                                      as do_fi, -- 납품 기준 비철 수량 (FI)
      @Semantics.quantity.unitOfMeasure: 'fi_unit'
      cast( cast( case when _Basic.shkzg is not initial
                       then _NfBL.sum_bl_fi * -1
                       else _NfBL.sum_bl_fi end
                  as abap.quan(15,4) )
            as zgtenf_bl_fi preserving type )                                      as bl_fi, -- 청구 기준 비철 수량 (FI)
      _NfDo.fi_unit,                                                                         -- 비철 수량 단위: FI

      -- =======================================================================
      -- [8] Pricing, Amounts & Currency (금액 및 통화 정보)
      -- =======================================================================
      @Semantics.amount.currencyCode: 'waerk'
      cast( cast( case when _Basic.shkzg is not initial
                       then _Basic.netpr * -1
                       else _Basic.netpr end
                  as abap.curr(11,2) )
            as netpr preserving type )                                             as netpr, -- 단가 (Net Price)
                  
      _Basic.kmein,
      _Basic.kpein,
      
      @Semantics.amount.currencyCode: 'waerk'
      cast( cast( case when _Basic.shkzg is not initial
                       then _Basic.netwr * -1
                       else _Basic.netwr end
                  as abap.curr(15,2) )
            as netwr preserving type )                                             as netwr, -- 순가치 금액 (Net Value)
      _Basic.mwsk1,                                                                          -- 세금 코드
      @Semantics.amount.currencyCode: 'waerk'
      cast( cast( case when _Basic.shkzg is not initial
                       then _Basic.mwsbp * -1
                       else _Basic.mwsbp end
                  as abap.curr(13,2) )
            as mwsbp preserving type )                                             as mwsbp, -- 세금 금액 (Tax Amount)
      _Basic.waerk,                                                                          -- 문서 통화 (Document Currency)
      _Basic.prsdt,                                                                          -- 가격 결정일 (Pricing Date)
      _Basic.kursk,                                                                          -- 환율 (Exchange Rate)

      -- [8-1] Currency Conversion (외화 금액 원화 환산)
      @Semantics.amount.currencyCode: 'waerk_krw'
      cast( cast( case when _Basic.shkzg is not initial
                       then _Basic.netwr_krw * -1
                       else _Basic.netwr_krw end
                  as abap.curr(15,2) )
            as zgtekrwamt preserving type )                                        as netwr_krw, -- 원화 환산 순가치
      _Basic.waerk_krw,                                                                      -- 원화 통화 키

      _Basic.commission_rate,                                                                -- 수수료율
      _Basic.commission_amt,                                                                 -- 수수료 금액
      _Basic.commission_rate2,                                                               -- 수수료율2
      _Basic.commission_amt2,                                                                -- 수수료 금액2

      -- =======================================================================
      -- [9] Schedule & Status (납품 일정 및 상태 정보)
      -- =======================================================================
      _Basic.edatu,                                                                          -- 납품 일정일 (Schedule Line Date)
      _Basic.lifsp,                                                                          -- 납품 보류 사유 (Delivery Block)
      _Basic.abgru,                                                                          -- 거부 사유 (Reason for Rejection)
      cast( case when _Basic.absta = 'C' then 'N'
                 when _Basic.grsta is not initial and _Basic.oemrel = 'Y' then 'Y'
                 else 'N' end
            as zgteoemrel preserving type )                                        as oemrel,-- OEM 여부

      _Basic.vgbel                                                                 as precede_vbeln, -- 참조 문서의 문서 번호
      _Basic.vgpos                                                                 as precede_posnr, -- 참조 문서의 품목 번호

      _Basic.absta,                                                                          -- 거부 상태 (Rejection Status)
      _Basic.drsta,                                                                          -- 출하 요청 상태 (Custom Status)
      _Basic.lfsta,                                                                          -- 납품 문서 생성 상태 (Delivery Status)
      _Basic.wbsta,                                                                          -- 출고 상태 (Goods Issue Status)
      _Basic.kpsta,                                                                          -- 보관품 입고 상태 (Custom Status)
      _Basic.ivsta,                                                                          -- 거래명세서 발행 상태 (Custom Status)
      _Basic.gosta,                                                                          -- 통문 처리 상태 (Custom Status)
      _Basic.fksta,                                                                          -- 청구 상태 (Billing Status)
      _Basic.dfsta,                                                                          -- 적송 상태 (Deferred Status)
      cast( case when (_Basic.grsta is initial or _Basic.grsta is null) and _Basic.oemrel = 'Y'
                 then 'A'
                 else _Basic.grsta end
            as zgtegrsta preserving type )                                         as grsta, -- 구매 입고 상태 (Goods Receipt Status)
      _Basic.gbsta,                                                                          -- 전체 처리 상태 (Overall Processing Status)

      -- =======================================================================
      -- [10] Administrative Data (시스템 관리 일자)
      -- =======================================================================
      _Basic.erdat,                                                                          -- 레코드 생성일 (Creation Date)
      _Basic.ernam,                                                                          -- 생성자 SAP ID
      _Basic.created_by,                                                                     -- 생성자 이름 (Created By) 
      _Basic.erzet                                                                           -- 입력 시간 (Creation Time)
}
