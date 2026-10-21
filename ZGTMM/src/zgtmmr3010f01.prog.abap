*&---------------------------------------------------------------------*
*& INCLUDE          ZGTMMR3010F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& FORM CREATE_ALV
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
FORM CREATE_ALV .

  PERFORM :
            SET_CONTAINER,
            SET_ALV_GRID,
            SET_ALV_FIELDCAT,
            SET_ALV_LAYOUT,
            SET_ALV_TOOLBAR,
            SET_ALV_SORT,
            SET_EVENT        CHANGING GCL_EVENT GCL_GRID,
            DISPLAY_ALV.

ENDFORM.

*&---------------------------------------------------------------------*
*& FORM SET_CONTAINER
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
FORM SET_CONTAINER .

  IF GCL_DOCKING IS NOT BOUND.

    CREATE OBJECT GCL_DOCKING
      EXPORTING
        REPID     = SY-REPID
        DYNNR     = SY-DYNNR
        SIDE      = CL_GUI_DOCKING_CONTAINER=>DOCK_AT_LEFT
        EXTENSION = 2500.

  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*& FORM SET_ALV_GRID
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
FORM SET_ALV_GRID .

  IF GCL_GRID IS NOT BOUND.
    CREATE OBJECT GCL_GRID
      EXPORTING
        I_PARENT          = GCL_DOCKING
      EXCEPTIONS
        ERROR_CNTL_CREATE = 1
        ERROR_CNTL_INIT   = 2
        ERROR_CNTL_LINK   = 3
        ERROR_DP_CREATE   = 4
        OTHERS            = 5.

    IF SY-SUBRC <> 0.
      "COULD NOT CREATE ALV GRID (SY-SUBRC = &)
      MESSAGE E725(BT) WITH SY-SUBRC.
    ENDIF.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*& FORM ADJUST_FLDCATS
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
FORM ADJUST_FLDCATS  TABLES PT_FCAT TYPE LVC_T_FCAT.

  DEFINE _FCAT.
    <fs_s_fct>-scrtext_s  =
    <fs_s_fct>-scrtext_m  =
    <fs_s_fct>-scrtext_l  =
    <fs_s_fct>-coltext    =
    <fs_s_fct>-reptext    = &1.
  END-OF-DEFINITION.

  DATA LV_COL TYPE I.
  CLEAR : GT_FCAT[].

  LOOP AT PT_FCAT ASSIGNING FIELD-SYMBOL(<FS_S_FCT>).
    CLEAR : <FS_S_FCT>-COL_POS.

    CASE <FS_S_FCT>-FIELDNAME.
      WHEN 'STATUS'. "상태
        _FCAT TEXT-F01.
        <FS_S_FCT>-JUST = 'C'.

      WHEN 'BUKRS' .    "회사코드
        _FCAT TEXT-F04.
        <FS_S_FCT>-NO_OUT = GC_X.
        <FS_S_FCT>-JUST = 'C'.

      WHEN 'EKORG'.	"구매조직
        _FCAT TEXT-F10.
        <FS_S_FCT>-NO_OUT = GC_X.
        <FS_S_FCT>-JUST = 'C'.

      WHEN 'EKOTX'.	"구매조직내역
        _FCAT TEXT-F05.
        <FS_S_FCT>-NO_OUT = GC_X.
        <FS_S_FCT>-JUST = 'C'.

      WHEN 'WERKS'.     " 플랜트
        _FCAT TEXT-F02.
*        <FS_S_FCT>-KEY = ABAP_TRUE.
        <FS_S_FCT>-JUST = 'C'.

      WHEN 'WERKS_N'.  "플랜트명
        _FCAT TEXT-F03.
*        <FS_S_FCT>-KEY = ABAP_TRUE.
        <FS_S_FCT>-JUST = 'C'.

      WHEN 'EKGRP'.      "구매그룹
        _FCAT TEXT-F08.
*        <FS_S_FCT>-F4AVAILABL = ZGTFI_X.
*        <FS_S_FCT>-REF_TABLE = 'MARC'.
*        <FS_S_FCT>-REF_FIELD  = 'EKGRP'.
        <FS_S_FCT>-JUST = 'C'.

      WHEN 'EKNAM'.     "구매그룹명
        _FCAT TEXT-F09.
        <FS_S_FCT>-JUST = 'C'.

      WHEN 'BSART'.	"PO유형
        _FCAT TEXT-F06.
        <FS_S_FCT>-NO_OUT = GC_X.
        <FS_S_FCT>-JUST = 'C'.

      WHEN 'BATXT '.  "PO유형명
        _FCAT TEXT-F07.
        <FS_S_FCT>-NO_OUT = GC_X.
        <FS_S_FCT>-JUST = 'C'.

      WHEN 'AEDAT_H '.  "최종변경일
        _FCAT TEXT-F73.
        <FS_S_FCT>-NO_OUT = GC_X.
        <FS_S_FCT>-JUST = 'C'.

      WHEN 'CREATIONDATE'.  "생성일
        _FCAT TEXT-F11.
        <FS_S_FCT>-NO_OUT = GC_X.
        <FS_S_FCT>-JUST = 'C'.

      WHEN 'CREATIONTIME'.  "생성시간
        _FCAT TEXT-F74.
        <FS_S_FCT>-NO_OUT = GC_X.
        <FS_S_FCT>-JUST = 'C'.

      WHEN 'AEDAT'.     "생성일
        _FCAT TEXT-F11.
        <FS_S_FCT>-JUST = 'C'.

      WHEN 'AETIM'.  "생성시간
        _FCAT TEXT-F74.
        <FS_S_FCT>-NO_OUT = GC_X.
        <FS_S_FCT>-JUST = 'C'.

      WHEN 'ERNAM'.       "생성자
        _FCAT TEXT-F15.
        <FS_S_FCT>-JUST = 'C'.

      WHEN 'LIFNR'.   "공급업체
        _FCAT TEXT-F16.
        <FS_S_FCT>-JUST = 'C'.

      WHEN 'NAME1'.   "업체명
        _FCAT TEXT-F17.
        <FS_S_FCT>-EMPHASIZE = 'C300'. "색/노랑/진하게/반전없음
        <FS_S_FCT>-JUST = 'C'.

      WHEN 'EBELN'.     "PO번호
        _FCAT TEXT-F12.
        <FS_S_FCT>-HOTSPOT = GC_X.
        <FS_S_FCT>-JUST = 'C'.

      WHEN 'EBELP'.    "항번
        _FCAT TEXT-F13.
        <FS_S_FCT>-JUST = 'C'.

      WHEN 'REQ_A'.     "승인요청현황
        _FCAT TEXT-F69.
        <FS_S_FCT>-NO_OUT = GC_X.
        <FS_S_FCT>-JUST = 'C'.

      WHEN 'REQ_ICON'.     "승인요청
        _FCAT TEXT-F70.
        <FS_S_FCT>-JUST = 'C'.

      WHEN 'REL_STAT'.     "승인상태
        _FCAT TEXT-F71.
        <FS_S_FCT>-NO_OUT = GC_X.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'REL_STAT_ICON'.     "승인여부
        _FCAT TEXT-F72.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'ANAME'.     "승인자사번
        _FCAT '승인자사번'.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'NAME_LAST'. "승인자이름
        _FCAT '승인자이름'.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'LOEKZ'.     "삭제
        _FCAT TEXT-F14.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'ELIKZ'.        "납품완료
        _FCAT TEXT-F18.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'RETPO'.        "반품
        _FCAT TEXT-F19.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'MATNR'.        "자재코드
        _FCAT TEXT-F20.
        <FS_S_FCT>-JUST = 'C'.
        <FS_S_FCT>-HOTSPOT = GC_X.
      WHEN 'TXZ01'.        "자재명
        _FCAT TEXT-F21.
        <FS_S_FCT>-EMPHASIZE = 'C410'.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'COLOR'.        "색상
        _FCAT TEXT-F22.
        <FS_S_FCT>-JUST = 'C'.
        <FS_S_FCT>-EMPHASIZE = 'C410'.
      WHEN 'LENGTH'.        "조장
        _FCAT TEXT-F23.
        <FS_S_FCT>-JUST = 'R'.
        <FS_S_FCT>-EMPHASIZE = 'C410'.
      WHEN 'IDNLF'.        "업체자재명칭
        _FCAT TEXT-F24.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'LGORT'.        "저장위치
        _FCAT TEXT-F25.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'LGOBE'.        "저장위치명
        _FCAT TEXT-F26.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'MENGE'.        "PO수량
        _FCAT TEXT-F27.
        <FS_S_FCT>-QFIELDNAME = 'LMEIN'.
        <FS_S_FCT>-JUST = 'R'.
        <FS_S_FCT>-EMPHASIZE = 'C700'.
      WHEN 'UMREZ'.        "분자
        _FCAT TEXT-F75.
        <FS_S_FCT>-NO_OUT = GC_X.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'UMREN'.        "분모
        _FCAT TEXT-F76.
        <FS_S_FCT>-NO_OUT = GC_X.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'LMEIN'.        "PO단위
        _FCAT TEXT-F28.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'PO_DRQTY'.        "드럼수
        _FCAT TEXT-F77.
        <FS_S_FCT>-NO_OUT = GC_X.
        <FS_S_FCT>-JUST = 'R'.
        <FS_S_FCT>-EMPHASIZE = 'C700'.
      WHEN 'DR_MEINS'.        "드럼단위
        _FCAT TEXT-F78.
        <FS_S_FCT>-NO_OUT = GC_X.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'UEBTO'.        "초과납품%
        _FCAT TEXT-F29.
        <FS_S_FCT>-JUST = 'R'.
      WHEN 'UEBTO'.        "무제한납품
        _FCAT TEXT-F79.
        <FS_S_FCT>-NO_OUT = GC_X.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'UEBTO'.        "미달납품%
        _FCAT TEXT-F80.
        <FS_S_FCT>-NO_OUT = GC_X.
        <FS_S_FCT>-JUST = 'R'.
      WHEN 'EINDT'.        "납품요청일
        _FCAT TEXT-F30.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'NETPR'.        "PO단가
        _FCAT TEXT-F31.
        <FS_S_FCT>-CFIELDNAME = 'WAERS'.
        <FS_S_FCT>-JUST = 'R'.
        <FS_S_FCT>-EMPHASIZE = 'C700'.
      WHEN 'PEINH'.        "PER
        _FCAT TEXT-F32.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'BPRME'.        "PO 가격단위
        _FCAT TEXT-F33.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'BPUMZ'.        "분자
        _FCAT TEXT-F75.
        <FS_S_FCT>-NO_OUT = GC_X.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'BPUMN'.        "분모
        _FCAT TEXT-F76.
        <FS_S_FCT>-NO_OUT = GC_X.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'WAERS'.        "PO 통화
        _FCAT TEXT-F34.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'NETWR'.        "오더금액
        _FCAT TEXT-F81.
        <FS_S_FCT>-NO_OUT = GC_X.
        <FS_S_FCT>-CFIELDNAME = 'WAERS'.
        <FS_S_FCT>-JUST = 'R'.
        <FS_S_FCT>-EMPHASIZE = 'C300'.
      WHEN 'BRTWR'.        "오더총액
        _FCAT TEXT-F35.
        <FS_S_FCT>-CFIELDNAME = 'WAERS'.
        <FS_S_FCT>-JUST = 'R'.
        <FS_S_FCT>-EMPHASIZE = 'C300'.
      WHEN 'MWSKZ'.        "TAX
        _FCAT TEXT-F36.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'ZGRSTATUS_C'.        "입고상태코드
        _FCAT TEXT-F82.
        <FS_S_FCT>-NO_OUT = GC_X.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'ZGRSTATUS'.        "입고상태   "컬러설정
        _FCAT TEXT-F37.
        <FS_S_FCT>-EMPHASIZE = 'C300'. "색/노랑/진하게/반전없음
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'GR_MENGE'.        "입고수량
        _FCAT TEXT-F38.
        <FS_S_FCT>-QFIELDNAME = 'GR_MEINS'.
        <FS_S_FCT>-JUST = 'R'.
        <FS_S_FCT>-EMPHASIZE = 'C700'.
      WHEN 'GR_MEINS'.        "입고단위
        _FCAT TEXT-F39.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'GR_DRQTY'.        "입고드럼수
        _FCAT TEXT-F83.
        <FS_S_FCT>-NO_OUT = GC_X.
        <FS_S_FCT>-JUST = 'R'.
        <FS_S_FCT>-EMPHASIZE = 'C700'.

      WHEN 'KBETR'.        "조건 금액
        _FCAT TEXT-F84.
        <FS_S_FCT>-NO_OUT = GC_X.
        <FS_S_FCT>-JUST = 'R'.

      WHEN 'KONWA'.        "입고단가
        _FCAT TEXT-F85.
        <FS_S_FCT>-NO_OUT = GC_X.
        <FS_S_FCT>-CFIELDNAME = 'WAERS'.
        <FS_S_FCT>-JUST = 'R'.
        <FS_S_FCT>-EMPHASIZE = 'C700'.

      WHEN 'KPEIN'.        "PER
        _FCAT TEXT-F32.
        <FS_S_FCT>-NO_OUT = GC_X.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'KMEIN'.        "단위
        _FCAT TEXT-F86.
        <FS_S_FCT>-NO_OUT = GC_X.
        <FS_S_FCT>-JUST = 'C'.

      WHEN 'PRICESUM'.        "입고총액
        _FCAT TEXT-F87.
        <FS_S_FCT>-NO_OUT = GC_X.
        <FS_S_FCT>-CFIELDNAME = 'WAERS'.
        <FS_S_FCT>-JUST = 'R'.
        <FS_S_FCT>-EMPHASIZE = 'C700'.

      WHEN 'INFOWAERS'.        "입고통화
        _FCAT TEXT-F88.
        <FS_S_FCT>-NO_OUT = GC_X.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'PRICE_TYPE'.     "가격결정유형
        _FCAT TEXT-F40.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'ZIVSTAUS_C'.     "정산상태코드 "컬러설정
        _FCAT TEXT-F41.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'ZIVSTAUS'.     "정산상태
        _FCAT TEXT-F42.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'IV1_QTY'.     "정산수량
        _FCAT TEXT-F43.
        <FS_S_FCT>-QFIELDNAME = 'IV1_BPRME'.
        <FS_S_FCT>-JUST = 'R'.
        <FS_S_FCT>-EMPHASIZE = 'C500'.

      WHEN 'IV1_BPRME'.     "정산수량단위
        _FCAT TEXT-F44.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'IV_DRQTY'.     "정산드럼수
        _FCAT TEXT-F89.
        <FS_S_FCT>-NO_OUT = GC_X.
        <FS_S_FCT>-JUST = 'R'.
        <FS_S_FCT>-EMPHASIZE = 'C500'.

      WHEN 'IV1_AMOUNTY'.     "정산총액
        _FCAT TEXT-F45.
        <FS_S_FCT>-CFIELDNAME = 'IV1_WAERS'.
        <FS_S_FCT>-JUST = 'R'.
        <FS_S_FCT>-EMPHASIZE = 'C500'.
      WHEN 'IV1_WAERS'.     "정산통화
        _FCAT TEXT-F46.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'IV1_AMOUNTY_KRW'.     "정산총액(KRW)
        _FCAT TEXT-F47.
        <FS_S_FCT>-CFIELDNAME = 'IV1_LC_WAERS'.
        <FS_S_FCT>-JUST = 'R'.
        <FS_S_FCT>-EMPHASIZE = 'C500'.
      WHEN 'IV1_LC_WAERS'.     "LC정산통화
        _FCAT TEXT-F48.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'IV2_QTY'.     "차후정산수량
        _FCAT TEXT-F90.
        <FS_S_FCT>-NO_OUT = GC_X.
        <FS_S_FCT>-JUST = 'R'.
      WHEN 'IV2_BPRME'.     "차후정산단위
        _FCAT TEXT-F91.
        <FS_S_FCT>-NO_OUT = GC_X.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'IV2_AMOUNTY'.     "차후정산총액
        _FCAT TEXT-F92.
        <FS_S_FCT>-NO_OUT = GC_X.
        <FS_S_FCT>-CFIELDNAME = 'IV1_WAERS'.
        <FS_S_FCT>-JUST = 'R'.
      WHEN 'IV2_AMOUNT_KRW '.     "차후정산총액(KRW)
        _FCAT TEXT-F93.
        <FS_S_FCT>-NO_OUT = GC_X.
        <FS_S_FCT>-CFIELDNAME = 'IV1_LC_WAERS'.
        <FS_S_FCT>-JUST = 'R'.
      WHEN 'IV2_LC_WAERS'.     "LC 정산 통화
        _FCAT TEXT-F48.
        <FS_S_FCT>-NO_OUT = GC_X.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'INFNR'.     "INFOREC.
        _FCAT TEXT-F49.
        <FS_S_FCT>-HOTSPOT = GC_X.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'BANFN'.     "구매요청
        _FCAT TEXT-F50.
        <FS_S_FCT>-HOTSPOT = GC_X.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'BNFPO'.     "항번
        _FCAT TEXT-F13.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'AFNAM'.     "요청자
        _FCAT TEXT-F51.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'EMLIF'.     "직납업체
        _FCAT TEXT-F52.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'NAME_V'.     "직납업체명
        _FCAT TEXT-F53.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'LBLKZ'.     "외주공급여부
        _FCAT TEXT-F95.
        <FS_S_FCT>-NO_OUT = GC_X.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'PSTYP'.     "IC
        _FCAT TEXT-F54.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'PTEXT'.     "IC명
        _FCAT TEXT-F55.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'KNTTP'.     "AAC
        _FCAT TEXT-F56.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'KNTTX'.     "AAC명
        _FCAT TEXT-F57.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'VBELN'.     "판매오더
        _FCAT TEXT-F58.
        <FS_S_FCT>-HOTSPOT = GC_X.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'POSNR'.     "항번
        _FCAT TEXT-F13.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'VKORG'.    "영업조직
        _FCAT TEXT-F96.
        <FS_S_FCT>-NO_OUT = GC_X.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'VTWEG'.    "유통경로
        _FCAT TEXT-F97.
        <FS_S_FCT>-NO_OUT = GC_X.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'VKBUR'.    "영업팀
        _FCAT TEXT-F98.
        <FS_S_FCT>-NO_OUT = GC_X.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'VKBUR_N'.    "영업팀명
        _FCAT TEXT-F59.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'VKGRP'.     "영업그룹
        _FCAT TEXT-F99.
        <FS_S_FCT>-NO_OUT = GC_X.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'VKGRP_N'.     "영업그룹명
        _FCAT TEXT-F60.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'NAME'.     "고객
        _FCAT TEXT-100.
        <FS_S_FCT>-NO_OUT = GC_X.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'NAME_K'.     "고객명
        _FCAT TEXT-F61.
        <FS_S_FCT>-JUST = 'C'.



      WHEN 'NES'.           " NF키
        _FCAT TEXT-F62.
        <FS_S_FCT>-NO_OUT = GC_X.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'VGW'.           "NF량
        _FCAT TEXT-F63.
        <FS_S_FCT>-NO_OUT = GC_X.
        <FS_S_FCT>-QFIELDNAME = 'BME'.
        <FS_S_FCT>-JUST = 'R'.
      WHEN 'BME'.         " NF단위
        _FCAT TEXT-F64.
        <FS_S_FCT>-NO_OUT = GC_X.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'VGE'.        	"NF PER
        _FCAT TEXT-F65.
        <FS_S_FCT>-NO_OUT = GC_X.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'MEINS_B'.   "재고단위
        _FCAT TEXT-F66.
        <FS_S_FCT>-NO_OUT = GC_X.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'VGW_T'.    	 "총 NF 량
        _FCAT TEXT-F67.
        <FS_S_FCT>-NO_OUT = GC_X.
        <FS_S_FCT>-QFIELDNAME = 'MEINS_B'.
        <FS_S_FCT>-JUST = 'R'.

      WHEN 'VGW_CU'.           "NF량
        _FCAT '단위량(CU)'.
        <FS_S_FCT>-QFIELDNAME = 'BME_CU'.
        <FS_S_FCT>-JUST = 'R'.
      WHEN 'BME_CU'.         " NF단위
        _FCAT 'CU단위'.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'VGE_CU'.          "NF PER
        _FCAT 'PER'.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'MEINS_B_CU'.   "재고단위
        _FCAT '재고단위'.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'VGW_T_CU'.       "총 NF 량
        _FCAT 'CU총량(발주량대비)'.
        <FS_S_FCT>-QFIELDNAME = 'MEINS_B_CU'.
        <FS_S_FCT>-JUST = 'R'.

      WHEN 'VGW_AL'.           "NF량
        _FCAT '단위량(AL)'.
        <FS_S_FCT>-QFIELDNAME = 'BME_AL'.
        <FS_S_FCT>-JUST = 'R'.
      WHEN 'BME_AL'.         " NF단위
        _FCAT 'AL단위'.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'VGE_AL'.          "NF PER
        _FCAT 'PER'.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'MEINS_B_AL'.   "재고단위
        _FCAT '재고단위'.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'VGW_T_AL'.       "총 NF 량
        _FCAT 'AL총량(발주량대비)'.
        <FS_S_FCT>-QFIELDNAME = 'MEINS_B_AL'.
        <FS_S_FCT>-JUST = 'R'.

      WHEN 'VGW_FI'.           "NF량
        _FCAT '단위량(FI)'.
        <FS_S_FCT>-QFIELDNAME = 'BME_FI'.
        <FS_S_FCT>-JUST = 'R'.
      WHEN 'BME_FI'.         " NF단위
        _FCAT 'FI단위'.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'VGE_FI'.          "NF PER
        _FCAT 'PER'.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'MEINS_B_FI'.   "재고단위
        _FCAT '재고단위'.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'VGW_T_FI'.       "총 NF 량
        _FCAT 'FI총량(발주량대비)'.
        <FS_S_FCT>-QFIELDNAME = 'MEINS_B_FI'.
        <FS_S_FCT>-JUST = 'R'.



      WHEN 'NTGEW'.     "순중량
        _FCAT TEXT-101.
        <FS_S_FCT>-NO_OUT = GC_X.
        <FS_S_FCT>-JUST = 'R'.
      WHEN 'BRGEW'.     "총중량
        _FCAT TEXT-101.
        <FS_S_FCT>-NO_OUT = GC_X.
        <FS_S_FCT>-JUST = 'R'.
      WHEN 'GEWEI'.     "중량단위
        _FCAT '총중량'.
        <FS_S_FCT>-NO_OUT = GC_X.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'VOLUM'.     "볼륨
        _FCAT '볼륨'.
        <FS_S_FCT>-NO_OUT = GC_X.
        <FS_S_FCT>-JUST = 'R'.
      WHEN 'VOLEH'.     "부피단위
        _FCAT '부피단위'.
        <FS_S_FCT>-NO_OUT = GC_X.
        <FS_S_FCT>-JUST = 'R'.
      WHEN 'ZTERM'.     "지급조건
        _FCAT '지급조건'.
        <FS_S_FCT>-NO_OUT = GC_X.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'TEXT1'.     "지급조건명
        _FCAT '지급조건명'.
        <FS_S_FCT>-NO_OUT = GC_X.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'ZBD1T'.     "지급기간1
        _FCAT '지급기간1'.
        <FS_S_FCT>-NO_OUT = GC_X.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'ZBD2T'.     "지급기간2
        _FCAT '지급기간2'.
        <FS_S_FCT>-NO_OUT = GC_X.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'ZBD3T'.     "지급기간3
        _FCAT '지급기간3'.
        <FS_S_FCT>-NO_OUT = GC_X.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'PO_WAERS'.     "PO통화
        _FCAT 'PO통화'.
        <FS_S_FCT>-NO_OUT = GC_X.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'WKURS'.     "PO환율
        _FCAT 'PO환율'.
        <FS_S_FCT>-NO_OUT = GC_X.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'BEDAT'.     "증빙일
        _FCAT '증빙일'.
        <FS_S_FCT>-NO_OUT = GC_X.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'INCO1'.     "INCOT
        _FCAT 'INCOT'.
        <FS_S_FCT>-NO_OUT = GC_X.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'INCO_N'.     "INCOTERMS 내역
        _FCAT 'INCOTERMS 내역'.
        <FS_S_FCT>-NO_OUT = GC_X.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'LANDS'.     "국가
        _FCAT '국가'.
        <FS_S_FCT>-NO_OUT = GC_X.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'STATU'.     "출처
        _FCAT '출처'.
        <FS_S_FCT>-NO_OUT = GC_X.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'MAPKEY'.     "MAPKEY
        _FCAT 'MAPKEY'.
        <FS_S_FCT>-NO_OUT = GC_X.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'MENGE_O'.     "기존PO수량
        _FCAT '기존PO수량'.
        <FS_S_FCT>-NO_OUT = GC_X.
        <FS_S_FCT>-JUST = 'R'.
      WHEN 'MEINS'.     "PO단위
        _FCAT 'PO단위'.
        <FS_S_FCT>-NO_OUT = GC_X.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'BEDNR'.     "요청 추적 번호
        _FCAT '요청 추적 번호'.
        <FS_S_FCT>-NO_OUT = GC_X.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'MATKL'.     "자재그룹
        _FCAT '자재그룹'.
        <FS_S_FCT>-NO_OUT = GC_X.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'WGBEZ60'.     "자재그룹명
        _FCAT '자재그룹명'.
        <FS_S_FCT>-NO_OUT = GC_X.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'MTBEZ'.     "자재유형
        _FCAT '지급기간3'.
        <FS_S_FCT>-NO_OUT = GC_X.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'MTBEZ'.     "자재유형명
        _FCAT '자재유형명'.
        <FS_S_FCT>-NO_OUT = GC_X.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'MFRNR'.     "제조업체
        _FCAT '제조업체'.
        <FS_S_FCT>-NO_OUT = GC_X.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'MFRPN'.     "제조업체부품번호
        _FCAT '제조업체부품번호'.
        <FS_S_FCT>-NO_OUT = GC_X.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'BWTAR'.     "평가유형
        _FCAT '평가유형'.
        <FS_S_FCT>-NO_OUT = GC_X.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'BWTTY'.     "VALCAT
        _FCAT 'VALCAT'.
        <FS_S_FCT>-NO_OUT = GC_X.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'EREKZ'.     "최종 송장
        _FCAT '최종 송장'.
        <FS_S_FCT>-NO_OUT = GC_X.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'WEPOS'.     "입고
        _FCAT '입고'.
        <FS_S_FCT>-NO_OUT = GC_X.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'WEUNB'.     "비평가 입고
        _FCAT '비평가 입고'.
        <FS_S_FCT>-NO_OUT = GC_X.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'REPOS'.     "송장수령
        _FCAT '송장수령'.
        <FS_S_FCT>-NO_OUT = GC_X.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'WEBRE'.     "입고 기준 송장 검증
        _FCAT '입고 기준 송장 검증'.
        <FS_S_FCT>-NO_OUT = GC_X.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'XERSY'.     "입고 기준 자동 정산
        _FCAT '입고 기준 자동 정산'.
        <FS_S_FCT>-NO_OUT = GC_X.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'EILDT'.     "GR 기준 정산 시작일
        _FCAT 'GR 기준 정산 시작일'.
        <FS_S_FCT>-NO_OUT = GC_X.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'MHDRZ'.     "최소 잔존 셸프라이프
        _FCAT '최소 잔존 셸프라이프'.
        <FS_S_FCT>-NO_OUT = GC_X.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'EGLKZ '.     "최종 납품
        _FCAT '최종 납품'.
        <FS_S_FCT>-NO_OUT = GC_X.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'KZTLF'.     "분할 납품/품목
        _FCAT '분할 납품/품목'.
        <FS_S_FCT>-NO_OUT = GC_X.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'KZABS'.     "확인 요청
        _FCAT '확인 요청'.
        <FS_S_FCT>-NO_OUT = GC_X.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'LABNR'.     "발주 확인
        _FCAT '발주 확인'.
        <FS_S_FCT>-NO_OUT = GC_X.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'ABSKZ'.     "거부 지시자
        _FCAT '거부 지시자'.
        <FS_S_FCT>-NO_OUT = GC_X.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'PRDAT'.     "가격결정일
        _FCAT '가격결정일'.
        <FS_S_FCT>-NO_OUT = GC_X.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'BSTYP'.     "구매 문서 범주
        _FCAT '구매 문서 범주'.
        <FS_S_FCT>-NO_OUT = GC_X.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'WEBAZ'.     "입고 처리 시간
        _FCAT '입고 처리 시간'.
        <FS_S_FCT>-NO_OUT = GC_X.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'PLIFZ'.     "계획 납품 소요 시간
        _FCAT '계획 납품 소요 시간'.
        <FS_S_FCT>-NO_OUT = GC_X.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'ADRNR'.     "주소
        _FCAT '주소'.
        <FS_S_FCT>-NO_OUT = GC_X.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'DNAME1'.     "이름
        _FCAT '이름'.
        <FS_S_FCT>-NO_OUT = GC_X.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'DNAME2'.     "이름2
        _FCAT '이름2'.
        <FS_S_FCT>-NO_OUT = GC_X.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'STREET'.     "도로주소
        _FCAT '도로주소'.
        <FS_S_FCT>-NO_OUT = GC_X.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'HOUSE_NUM1'.     "번지
        _FCAT '번지'.
        <FS_S_FCT>-NO_OUT = GC_X.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'POST_CODE1'.     "우편번호
        _FCAT '우편번호'.
        <FS_S_FCT>-NO_OUT = GC_X.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'CITY1'.     "도시
        _FCAT '도시'.
        <FS_S_FCT>-NO_OUT = GC_X.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'REGION'.     "지역
        _FCAT '지역'.
        <FS_S_FCT>-NO_OUT = GC_X.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'BEZEI'.     "내역
        _FCAT '내역'.
        <FS_S_FCT>-NO_OUT = GC_X.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'COUNTRY'.     "국가/지역 키
        _FCAT '국가/지역 키'.
        <FS_S_FCT>-NO_OUT = GC_X.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'BSTAE'.     "확인관리
        _FCAT '확인관리'.
        <FS_S_FCT>-NO_OUT = GC_X.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'MEPRF'.     "PrDateCntr
        _FCAT 'PrDateCntr'.
        <FS_S_FCT>-NO_OUT = GC_X.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'UEBPO'.     "상위 레벨 품목
        _FCAT '상위레벨품목'.
        <FS_S_FCT>-NO_OUT = GC_X.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'CHG_SRV'.     "구성변경
        _FCAT '구성변경'.
        <FS_S_FCT>-NO_OUT = GC_X.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'BERID'.     "MRP 영역
        _FCAT 'MRP 영역'.
        <FS_S_FCT>-NO_OUT = GC_X.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'MEMI_I'.     "MEMI_I
        _FCAT 'MRP 영역'.
        <FS_S_FCT>-NO_OUT = GC_X.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'IHREZ'.     "IHREZ
        _FCAT '업체접수상태'.
        <FS_S_FCT>-NO_OUT = GC_X.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'IHREZ_N'.     "IHREZ_N
        _FCAT '업체접수상태'.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'MESSAGE'.   "처리결과
        _FCAT TEXT-F68.
        <FS_S_FCT>-JUST = 'C'.
      WHEN OTHERS.
        <FS_S_FCT>-NO_OUT = ZGTFI_X.

    ENDCASE.

    APPEND <FS_S_FCT> TO GT_FCAT.
  ENDLOOP.

ENDFORM.

*&---------------------------------------------------------------------*
*& FORM SET_ALV_LAYOUT
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
FORM SET_ALV_LAYOUT.

  CLEAR GS_LAYOUT.
  GS_LAYOUT = VALUE #(
*                       NO_ROWINS  = ZGTFI_X
                       ZEBRA  = ZGTFI_X
                       SEL_MODE   = ZGTFI_A
                       CWIDTH_OPT  = ZGTFI_A
*                       STYLEFNAME = 'STYLE'
                       CTAB_FNAME = 'COLO'
  ).

ENDFORM.

*&---------------------------------------------------------------------*
*& FORM SET_ALV_TOOLBAR
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
FORM SET_ALV_TOOLBAR.

  REFRESH GT_EXCLUD.

  GT_EXCLUD[] = VALUE #(
*                         ( CL_GUI_ALV_GRID=>MC_MB_VIEW              )
                         ( CL_GUI_ALV_GRID=>MC_FC_LOC_UNDO          )
                         ( CL_GUI_ALV_GRID=>MC_FC_AUF               )
                         ( CL_GUI_ALV_GRID=>MC_FC_DETAIL            )
                         ( CL_GUI_ALV_GRID=>MC_FC_GRAPH             )
                         ( CL_GUI_ALV_GRID=>MC_FC_INFO              )
                         ( CL_GUI_ALV_GRID=>MC_FC_LOC_COPY          )
                         ( CL_GUI_ALV_GRID=>MC_FC_LOC_COPY_ROW      )
                         ( CL_GUI_ALV_GRID=>MC_FC_LOC_CUT           )
                         ( CL_GUI_ALV_GRID=>MC_FC_LOC_DELETE_ROW    )
                         ( CL_GUI_ALV_GRID=>MC_FC_LOC_INSERT_ROW    )
                         ( CL_GUI_ALV_GRID=>MC_FC_LOC_MOVE_ROW      )
                         ( CL_GUI_ALV_GRID=>MC_FC_LOC_APPEND_ROW    )
                         ( CL_GUI_ALV_GRID=>MC_FC_LOC_PASTE         )
                         ( CL_GUI_ALV_GRID=>MC_FC_LOC_PASTE_NEW_ROW )
*                         ( CL_GUI_ALV_GRID=>MC_FC_PRINT             )
                         ( CL_GUI_ALV_GRID=>MC_FC_REFRESH           )
                         ).

ENDFORM.
*&---------------------------------------------------------------------*
*& FORM SET_ALV_SORT
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
FORM SET_ALV_SORT.

*  GT_SORT[] = VALUE LVC_T_SORT(
*    ( SPOS = '1' FIELDNAME = 'WERKS'       UP = ZGTFI_X )
*    ( SPOS = '2' FIELDNAME = 'WERKS_TX' UP = ZGTFI_X SUBTOT = ZGTFI_X )
*    ( SPOS = '3' FIELDNAME = 'MTART'    UP = ZGTFI_X )
*    ( SPOS = '4' FIELDNAME = 'MATNR'    UP = ZGTFI_X )
*                                ).

ENDFORM.
*&---------------------------------------------------------------------*
*& FORM SET_EVENT
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
FORM SET_EVENT  CHANGING PO_EVENT TYPE REF TO LCL_EVT_RECEIVER
                                               PCL_GRID  TYPE REF TO CL_GUI_ALV_GRID.

  PCL_GRID->REGISTER_EDIT_EVENT( CL_GUI_ALV_GRID=>MC_EVT_MODIFIED ).
  PCL_GRID->REGISTER_EDIT_EVENT( CL_GUI_ALV_GRID=>MC_EVT_ENTER ).

  PERFORM SET_CELL_COLOR.

  CREATE OBJECT PO_EVENT.

  SET HANDLER :
  PO_EVENT->HANDLE_DATA_CHANGED                 FOR PCL_GRID,
  PO_EVENT->HANDLE_DATA_CHANGED_FINISHED  FOR PCL_GRID,
  PO_EVENT->HANDLE_HOTSPOT_CLICK                FOR PCL_GRID,
  PO_EVENT->HANDLE_TOOLBAR                           FOR PCL_GRID,
  PO_EVENT->HANDLE_USER_COMMAND               FOR PCL_GRID,
  PO_EVENT->HANDLE_ON_F4                               FOR PCL_GRID.


ENDFORM.

*&---------------------------------------------------------------------*
*& FORM DISPLAY_ALV
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
FORM DISPLAY_ALV .

  DATA(LS_VARINT) = VALUE DISVARIANT( REPORT  = SY-CPROG
                                           HANDLE  = '0001' ).

  CALL METHOD GCL_GRID->SET_TABLE_FOR_FIRST_DISPLAY
    EXPORTING
      IS_LAYOUT            = GS_LAYOUT
      IT_TOOLBAR_EXCLUDING = GT_EXCLUD[]
      IS_VARIANT           = LS_VARINT
      I_SAVE               = ZGTFI_A
    CHANGING
      IT_OUTTAB            = GT_LIST[]
      IT_FIELDCATALOG      = GT_FCAT[]
      IT_SORT              = GT_SORT[]
    EXCEPTIONS
      OTHERS               = 4.

  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
          WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*& FORM RELEASE_ALV
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
FORM RELEASE_ALV .

  IF GCL_GRID IS BOUND.
    GCL_GRID->FREE( ).
    CLEAR GCL_GRID.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*& FORM INITIALIZATION
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
FORM INITIALIZATION .
  DATA: LT_VALUES TYPE TABLE OF USVALUES,
        LS_VALUES TYPE USVALUES.

  CLEAR : S_ERDAT[]. "생성일
  S_ERDAT[] = VALUE #( ( SIGN   = GC_I
                                        OPTION = GC_BT
                                        LOW    = SY-DATLO - 30
                                        HIGH   = SY-DATLO ) ).

  CALL FUNCTION 'SUSR_USER_AUTH_FOR_OBJ_GET'
    EXPORTING
      MANDANT           = SY-MANDT
      SEL_OBJECT        = 'ZCBO_MM001' " 조회할 권한 오브젝트명
      USER_NAME         = SY-UNAME
    TABLES
      VALUES            = LT_VALUES
    EXCEPTIONS
      USER_NAME_INVALID = 1
      OBJECT_NOT_FOUND  = 2
      INTERNAL_ERROR    = 3
      OTHERS            = 4.

  DELETE  LT_VALUES WHERE VON = '*'.

  IF LT_VALUES[] IS NOT INITIAL.

    READ TABLE LT_VALUES INTO LS_VALUES WITH KEY FIELD = 'BUKRS'.
    IF SY-SUBRC EQ 0. P_BUKRS = LS_VALUES-VON. ENDIF.

    READ TABLE LT_VALUES INTO LS_VALUES WITH KEY FIELD = 'EKORG'.
    IF SY-SUBRC EQ 0. P_EKORG = LS_VALUES-VON. ENDIF.

    READ TABLE LT_VALUES INTO LS_VALUES WITH KEY FIELD = 'WERKS'.
    IF SY-SUBRC EQ 0. S_WERKS-LOW = LS_VALUES-VON.     ENDIF.

    READ TABLE LT_VALUES INTO LS_VALUES WITH KEY FIELD = 'EKGRP'.
    IF SY-SUBRC EQ 0.   S_EKGRP-LOW = LS_VALUES-VON. ENDIF.


  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*& FORM INPUT_VALIDATION
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
FORM INPUT_VALIDATION.

  CLEAR : GT_LIST, GV_ERR.

  IF S_ERDAT[] IS INITIAL AND S_EINDT[] IS INITIAL.
    MESSAGE S000 WITH TEXT-M13 DISPLAY LIKE GC_E.
    GV_ERR = GC_X. STOP. "생성일과 납품예정일 중 최소 하나는 입력 해야 합니다.
  ENDIF.

  IF  S_WERKS-LOW IS NOT INITIAL.
    LOOP AT S_WERKS INTO DATA(LS_WERKS).

      SELECT SINGLE 1
       FROM T001W
       WHERE WERKS EQ @LS_WERKS-LOW
        INTO @DATA(LV_EXST).

      IF SY-SUBRC <> 0.
        MESSAGE S000 WITH TEXT-M01 DISPLAY LIKE GC_E.
        GV_ERR = GC_X. STOP. "유효하지 않은 플랜트 입니다.
      ENDIF.

    ENDLOOP.
  ENDIF.

  IF  S_EKGRP-LOW IS NOT INITIAL.
    LOOP AT S_EKGRP INTO DATA(LS_EKGRP).

      SELECT SINGLE 1
       FROM T024
       WHERE EKGRP EQ @LS_EKGRP-LOW
        INTO @LV_EXST.

      IF SY-SUBRC <> 0.
        MESSAGE S000 WITH TEXT-M02 DISPLAY LIKE GC_E.
        GV_ERR = GC_X.  STOP. "유효하지 않은 구매그룹 입니다.
      ENDIF.

    ENDLOOP.
  ENDIF.

  IF S_EBELN[] IS NOT INITIAL.
    LOOP AT S_EBELN INTO DATA(LS_LOW).

      SELECT SINGLE 1
      FROM EKKO
      WHERE EBELN EQ @LS_LOW-LOW
      INTO @LV_EXST.

      IF SY-SUBRC <> 0.
        MESSAGE S000 WITH TEXT-M12 DISPLAY LIKE GC_E.
        GV_ERR = GC_X. STOP. "유효하지 않은 구매오더 입니다.
      ENDIF.
    ENDLOOP.
  ENDIF.

  IF S_LIFNR[] IS NOT INITIAL.
    LOOP AT S_LIFNR INTO DATA(LS_LIFNR).

      SELECT SINGLE 1
      FROM LFA1
      WHERE LIFNR EQ @LS_LIFNR-LOW
      INTO @LV_EXST.

      IF SY-SUBRC <> 0.
        MESSAGE S000 WITH TEXT-M03 DISPLAY LIKE GC_E.
        GV_ERR = GC_X. STOP. "유효하지 않은 공급업체 입니다.
      ENDIF.
    ENDLOOP.
  ENDIF.

  IF S_MATNR[] IS NOT INITIAL.
    LOOP AT S_MATNR INTO DATA(LS_MATNR).

      SELECT SINGLE 1
      FROM MARA
      WHERE MATNR EQ @LS_MATNR-LOW
      INTO @LV_EXST.

      IF SY-SUBRC <> 0.
        MESSAGE S000 WITH TEXT-M10 DISPLAY LIKE GC_E.
        GV_ERR = GC_X. STOP. "유효하지 않은 자재코드 입니다.
      ENDIF.
    ENDLOOP.
  ENDIF.

  IF S_VBELN[] IS NOT INITIAL.
    LOOP AT S_VBELN INTO DATA(LS_VBELN).

      SELECT SINGLE 1
      FROM VBAK
      WHERE VBELN EQ @LS_VBELN-LOW
      INTO @LV_EXST.

      IF SY-SUBRC <> 0.
        MESSAGE S000 WITH TEXT-M11 DISPLAY LIKE GC_E.
        GV_ERR = GC_X. STOP. "유효하지 않은 판매오더 입니다.
      ENDIF.
    ENDLOOP.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*& FORM CHECK_AUTH
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
FORM CHECK_AUTH.

  AUTHORITY-CHECK OBJECT 'ZCBO_MM001'
               ID 'BUKRS' FIELD P_BUKRS.

  CHECK SY-SUBRC <> 0.

  SET CURSOR FIELD 'P_BUKRS'.
  MESSAGE E172 WITH P_BUKRS. "구매조직 [&] 작업권한을 확인하세요.

  AUTHORITY-CHECK OBJECT 'ZCBO_MM001'
               ID 'EKORG' FIELD P_EKORG.

  CHECK SY-SUBRC <> 0.

  SET CURSOR FIELD 'P_EKORG'.
  MESSAGE E170 WITH P_EKORG. "구매조직 [&] 작업권한을 확인하세요.

  LOOP AT S_WERKS INTO DATA(LS_WERKS2).
    AUTHORITY-CHECK OBJECT 'ZCBO_MM001'
                 ID 'WERKS' FIELD LS_WERKS2-LOW.

    CHECK SY-SUBRC <> 0.

    SET CURSOR FIELD 'S_WERKS-LOW'.
    MESSAGE E106 WITH S_WERKS-LOW. "플랜트 [&] 작업권한을 확인하세요.
  ENDLOOP.

  LOOP AT S_EKGRP INTO DATA(LS_EKGRP2).
    AUTHORITY-CHECK OBJECT 'ZCBO_MM001'
                 ID 'EKGRP' FIELD LS_EKGRP2-LOW.

    CHECK SY-SUBRC <> 0.

    SET CURSOR FIELD 'S_EKGRP-LOW'.
    MESSAGE E171 WITH S_EKGRP-LOW. "구매그룹 [&] 작업권한을 확인하세요.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& FORM SELECTION_SCREEN_OUTPUT
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
FORM SELECTION_SCREEN_OUTPUT .

*  LOOP AT SCREEN.
*    IF R_1_2 IS INITIAL AND SCREEN-GROUP1 = 001.
*      SCREEN-ACTIVE = 0.
*    ENDIF.
*    MODIFY SCREEN.
*  ENDLOOP.

ENDFORM.

*&---------------------------------------------------------------------*
*& FORM GET_DATA
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
FORM GET_DATA .

  CLEAR : GV_ERR, GT_LIST.
  DATA LV_COND TYPE STRING.

  LV_COND = | BUKRS = @P_BUKRS AND EKORG = @P_EKORG |.
  LV_COND &&= | AND WERKS IN @S_WERKS AND EKGRP IN  @S_EKGRP AND EBELN IN @S_EBELN |.
  LV_COND &&= | AND LIFNR IN @S_LIFNR AND MATNR IN @S_MATNR AND VBELN IN @S_VBELN |.
  LV_COND &&= | AND AEDAT_H IN @S_ERDAT AND EINDT IN @S_EINDT |.

**--> 26.09 *판매문서 & 품목 추가
  LV_COND &&= | AND CONCAT( VBELN , POSNR ) IN @S_SOPO |.

  IF P_DPO = GC_X. "삭제 PO 제외
    LV_COND &&= | AND LOEKZ IS INITIAL |.
  ENDIF.
  IF P_FIN = GC_X.  "납품완료 PO 제외
    LV_COND &&= | AND ELIKZ IS INITIAL |.
  ENDIF.
  IF P_RPO = GC_X. "반품 PO 제외
    LV_COND &&= | AND RETPO IS INITIAL |.
  ENDIF.

  SELECT FROM ZGTMM_CV_GET_PO_DATA_GRL
    FIELDS *
    WHERE (LV_COND)
        INTO CORRESPONDING FIELDS OF TABLE @GT_LIST.

*테스트용 주석
  IF GT_LIST[] IS INITIAL.
*     GV_ERR = ZGTFI_X. "조회 조건에 일치하는 정보가 없습니다.
    MESSAGE S000 WITH TEXT-E01.

  ELSE.
    LOOP AT GT_LIST ASSIGNING FIELD-SYMBOL(<FS>).
      IF <FS>-LOEKZ = GC_L.
        <FS>-REQ_ICON =  ICON_DELETE.
        <FS>-REL_STAT_ICON =  ICON_DELETE.
      ELSE  .

        <FS>-REQ_ICON = COND #(
                                     WHEN <FS>-REQ_A = GC_X
                                     THEN ICON_LED_GREEN ELSE ICON_LED_RED ).

        <FS>-REL_STAT_ICON = COND #(
                                              WHEN <FS>-REL_STAT = GC_X
                                              THEN ICON_LED_GREEN ELSE ICON_LED_RED ).
      ENDIF.
    ENDLOOP.
  ENDIF.

  SORT GT_LIST BY EBELN DESCENDING EBELP BUKRS EKORG WERKS EKGRP LIFNR ASCENDING.

ENDFORM.

*&---------------------------------------------------------------------*
*&      FORM  POPUP_TO_CONFIRM_STEP
*&---------------------------------------------------------------------*
*       TEXT
*----------------------------------------------------------------------*
FORM POPUP_TO_CONFIRM_STEP  USING PV_OPT
                                                                PV_TEXT1
                                                                PV_TEXT2
                                                                PV_TITLE.
  CLEAR GV_ANSWER.
  CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
    EXPORTING
      DEFAULTOPTION  = PV_OPT
      TEXTLINE1      = PV_TEXT1
      TEXTLINE2      = PV_TEXT2
      TITEL          = PV_TITLE
      CANCEL_DISPLAY = ''
    IMPORTING
      ANSWER         = GV_ANSWER.

ENDFORM.                    " POPUP_TO_CONFIRM_STEP

*&---------------------------------------------------------------------*
*& FORM REFRESH_TABLE
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
FORM REFRESH_TABLE USING PO_GRID TYPE REF TO CL_GUI_ALV_GRID
                                               PV_SOFT_REFRESH.

  DATA : LS_STABLE TYPE LVC_S_STBL.

*  CHECK PO_GRID IS BOUND.

  LS_STABLE-ROW = ABAP_TRUE.
  LS_STABLE-COL = ABAP_TRUE.

  CALL METHOD PO_GRID->REFRESH_TABLE_DISPLAY
    EXPORTING
      IS_STABLE = LS_STABLE
*     I_SOFT_REFRESH = PV_SOFT_REFRESH
    EXCEPTIONS
      FINISHED  = 1
      OTHERS    = 2.

ENDFORM.

*&---------------------------------------------------------------------*
*& FORM DATA_CHANGED_FINISHED
*&---------------------------------------------------------------------*
*& TEXT4
*&---------------------------------------------------------------------*
FORM DATA_CHANGED_FINISHED  USING    PV_MODIFIED TYPE CHAR01
                                     PT_GOOD_CELLS TYPE LVC_T_MODI
                                     PO_SENDER.

*  CHECK PV_MODIFIED IS NOT INITIAL.
*  CHECK PO_SENDER <> GCL_GRID.
*
*  CASE PO_SENDER.
*    WHEN GCL_GRID_3.
*      LOOP AT PT_GOOD_CELLS INTO DATA(LS_MOD_CELLS).
*        READ TABLE GT_LIST_3 ASSIGNING FIELD-SYMBOL(<LS_LIST_3>)
*                                     INDEX LS_MOD_CELLS-ROW_ID..
*        CASE LS_MOD_CELLS-FIELDNAME.
*          WHEN 'HKONT'.
*            IF GV_300GB = 1.
*              <LS_LIST_3>-LIMIT_CUR = <LS_LIST_3>-LIMIT / 100.
*
*            ELSE.
*              <LS_LIST_3>-LIMIT_CUR = <LS_LIST_3>-LIMIT / 100.
*              SELECT SINGLE SUM( A~CLAMT )
*                FROM @GT_LIST_2 AS A
*               WHERE A~CHECK IS NOT INITIAL
*                INTO @DATA(LV_CLAMT).
*              IF LV_CLAMT <> 0.
*                LV_CLAMT = LV_CLAMT * <LS_LIST_3>-LIMIT2.
*              ENDIF.
*              <LS_LIST_3>-LIMIT_CUR += LV_CLAMT.
*            ENDIF.
*
*            READ TABLE GT_DD07T INTO DATA(LS_DD07T)
*                                WITH KEY DOMNAME = 'SHKZG'
*                                         DOMVALUE_L = <LS_LIST_3>-SHKZG
*                                         BINARY SEARCH.
*            IF SY-SUBRC = 0.
*              <LS_LIST_3>-SHKZG_TX = LS_DD07T-DDTEXT.
*            ENDIF.
*        ENDCASE.
*      ENDLOOP.
*
*    WHEN OTHERS.
*  ENDCASE.
*
*  PERFORM RECALCULATE_DATA.
*  PERFORM REFRESH_TABLE USING PO_SENDER SPACE.
*
*  CALL METHOD CL_GUI_CFW=>SET_NEW_OK_CODE
*    EXPORTING
*      NEW_CODE = 'ENTER'.


ENDFORM.

*&---------------------------------------------------------------------*
*& FORM SET_CELL_COLOR
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
FORM SET_CELL_COLOR .

  DATA : LS_COLOR TYPE    LVC_S_SCOL.

*  DEFINE _SET_COLOR.
*
*    LS_COLOR-FNAME = &1.
*    LS_COLOR-COLOR-COL = &2.
*    LS_COLOR-COLOR-INT  = &3
*    INSERT LS_STYLE INTO TABLE &4.
*
*  END-OF-DEFINITION.

  LOOP AT GT_LIST ASSIGNING FIELD-SYMBOL(<LS_LIST>).

    CLEAR : <LS_LIST>-COLO[].

*입고상태
    LS_COLOR-FNAME = GC_ZGRSTATUS.
    LS_COLOR-COLOR-COL = COND #( WHEN <LS_LIST>-ZGRSTATUS_C = GC_C
                                                           THEN '6'
                                                           WHEN <LS_LIST>-ZGRSTATUS_C = GC_D
                                                           THEN '7' ELSE '0' ).
    LS_COLOR-COLOR-INT   = '1'.
    INSERT LS_COLOR INTO TABLE <LS_LIST>-COLO.

*정산상태
    CLEAR LS_COLOR.

    CASE <LS_LIST>-ZIVSTATUS_C.
      WHEN GC_A OR GC_E.
        LS_COLOR-FNAME = GC_ZIVSTATUS.
        LS_COLOR-COLOR-COL = '6'.
        LS_COLOR-COLOR-INT   = '1'.
        INSERT LS_COLOR INTO TABLE <LS_LIST>-COLO.

      WHEN GC_C OR GC_D.
        LS_COLOR-FNAME = GC_ZIVSTATUS.
        LS_COLOR-COLOR-COL = '7'.
        LS_COLOR-COLOR-INT   = '1'.
        INSERT LS_COLOR INTO TABLE <LS_LIST>-COLO.
      WHEN OTHERS.
    ENDCASE.

  ENDLOOP.

ENDFORM.

*&---------------------------------------------------------------------*
*& FORM SET_ALV_FIELDCAT
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
FORM SET_ALV_FIELDCAT.

  DATA :
    LR_TABDESCR TYPE REF TO CL_ABAP_STRUCTDESCR,
    LT_DFIES    TYPE DDFIELDS,
    LS_DFIES    TYPE DFIES,
    LT_FCAT     TYPE LVC_T_FCAT,
    LS_FCAT     TYPE LVC_S_FCAT.

  DATA : GR_DREF  TYPE REF TO DATA.

  CLEAR GR_DREF.
  CREATE DATA GR_DREF LIKE GS_LIST.

  LR_TABDESCR ?= CL_ABAP_STRUCTDESCR=>DESCRIBE_BY_DATA_REF( GR_DREF ).
  LT_DFIES = CL_SALV_DATA_DESCR=>READ_STRUCTDESCR( LR_TABDESCR ) .

  REFRESH : LT_FCAT.

  LOOP AT LT_DFIES INTO LS_DFIES.
    CLEAR : LS_FCAT.
    MOVE-CORRESPONDING LS_DFIES TO LS_FCAT.
    APPEND LS_FCAT TO LT_FCAT.
  ENDLOOP.

  " 필드 카탈로그 변경사항 적용
  PERFORM ADJUST_FLDCATS TABLES LT_FCAT.

ENDFORM.

*&---------------------------------------------------------------------*
*& FORM SET_TOP_OF_PAGE
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
FORM SET_TOP_OF_PAGE .

*  DATA :
*         LV_TXT   TYPE C LENGTH 10,
*         LV_TXT2  TYPE C LENGTH 10,
*         LV_FROM TYPE C LENGTH 5,
*         LV_TO      TYPE C LENGTH 5.
*
*
*  CALL METHOD GCL_CL_DD->INITIALIZE_DOCUMENT
*    EXPORTING
*      BACKGROUND_COLOR = CL_DD_AREA=>COL_TEXTAREA.

  " ADD TEXT
*  GCL_CL_DD->ADD_TEXT( TEXT = |플랜트　:　{ P_WERKS }({ GV_LINE })|
*                       SAP_EMPHASIS = CL_DD_AREA=>HEADING ).

*  IF S_BUDAT[] IS NOT INITIAL.
*    READ TABLE S_BUDAT INDEX 1.
*    WRITE S_BUDAT-LOW TO LV_TXT.
*    WRITE S_BUDAT-HIGH TO LV_TXT2.
*
*    " ADD NEW-LINE
*    GCL_CL_DD->NEW_LINE( ).
*    " ADD TEXT
*    IF S_BUDAT-HIGH IS INITIAL.
*      GCL_CL_DD->ADD_TEXT( TEXT = |입금일자　:　{ LV_TXT }|
*                           SAP_EMPHASIS = CL_DD_AREA=>HEADING ).
*    ELSE.
*      GCL_CL_DD->ADD_TEXT( TEXT = |입금일자　:　{ LV_TXT } ~ { LV_TXT2 }|
*                           SAP_EMPHASIS = CL_DD_AREA=>HEADING ).
*    ENDIF.
*  ENDIF.

*  GCL_CL_DD->DISPLAY_DOCUMENT( EXPORTING  REUSE_CONTROL = ZGTFI_X
*                                          PARENT        = GCL_CON_TOP
*                               EXCEPTIONS HTML_DISPLAY_ERROR = 1 ).


ENDFORM.

*&---------------------------------------------------------------------*
*& FORM TOOLBAR
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
FORM TOOLBAR  USING PR_OBJ TYPE REF TO CL_ALV_EVENT_TOOLBAR_SET
                                     PO_SENDER.

  DATA : LS_TBAR TYPE STB_BUTTON.

  DEFINE _SET_TBAR.
    CLEAR : ls_tbar.

    ls_tbar-butn_type = &1.
    ls_tbar-function   = &2.
    ls_tbar-icon           = &3.
    ls_tbar-text          = &4.
    ls_tbar-quickinfo = &4.

    APPEND ls_tbar TO pr_obj->mt_toolbar.
  END-OF-DEFINITION.


  CASE PO_SENDER.

    WHEN GCL_GRID.
      _SET_TBAR 3 '    ' '              ' '    '.
      _SET_TBAR 0 'REFRESH' ICON_REFRESH 'REFRESH'(b01).
      _SET_TBAR 0 'DELETE' ICON_DELETE 'PO삭제'(b05).
      _SET_TBAR 0 'FINISH'  ICON_CLOSE   '발주종료'(b02).
      _SET_TBAR 0 'UNFIN' ICON_SYSTEM_UNDO  '발주종료해제'(b03).
      _SET_TBAR 0 'REQUEST' ICON_MAIL '승인요청'(b04).

    WHEN OTHERS.

  ENDCASE.

ENDFORM.

*&---------------------------------------------------------------------*
*& FORM USER_COMMAND
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
FORM USER_COMMAND  USING PV_UCOMM LIKE SY-UCOMM.

*  CLEAR : GV_REF.

  CASE PV_UCOMM.
    WHEN 'REFRESH'.
      PERFORM GET_DATA.

    WHEN 'FINISH'.
      PERFORM ORDER_FINISH_DATA USING 'F'.
*      PERFORM GET_DATA.

    WHEN 'UNFIN'.
      PERFORM ORDER_FINISH_DATA USING 'R'.
*      PERFORM GET_DATA.

    WHEN 'REQUEST'.
      PERFORM REQUEST_DATA.

    WHEN 'DELETE'.
      PERFORM  PO_DELETE_DATA.
  ENDCASE.

  PERFORM REFRESH_TABLE USING GCL_GRID SPACE.

ENDFORM.

*&---------------------------------------------------------------------*
*& FORM DATA_CHANGED
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
FORM DATA_CHANGED  USING  PO_DATA_CHANGED
                                     TYPE REF TO CL_ALV_CHANGED_DATA_PROTOCOL
                                                PO_SENDER.

  CASE PO_SENDER.

    WHEN GCL_GRID.
      PERFORM DATA_CHANGED_1 USING PO_DATA_CHANGED.

    WHEN OTHERS.
      EXIT.
  ENDCASE.

ENDFORM.

*&---------------------------------------------------------------------*
*&      FORM  DATA_CHANGED_1
*&---------------------------------------------------------------------*
*       TEXT
*----------------------------------------------------------------------*
*      -->P_PO_DATA_CHANGED  TEXT
*----------------------------------------------------------------------*
FORM DATA_CHANGED_1 USING PO_DATA_CHANGED
                                       TYPE REF TO CL_ALV_CHANGED_DATA_PROTOCOL.

  DATA : LV_ERR   TYPE CHAR1.

  LOOP AT PO_DATA_CHANGED->MT_GOOD_CELLS INTO DATA(LS_MOD_CELLS).

    READ TABLE GT_LIST  INTO DATA(LS_LIST) INDEX LS_MOD_CELLS-ROW_ID.
    CHECK SY-SUBRC EQ 0.

    CASE LS_MOD_CELLS-FIELDNAME.

      WHEN 'EKGRP'.

        SELECT SINGLE EKGRP, EKNAM
           FROM  T024
           WHERE EKGRP = @LS_MOD_CELLS-VALUE
               INTO @DATA(LS_EKGRP).

        IF LS_EKGRP IS  INITIAL.
          PERFORM ADD_ENTRY USING PO_DATA_CHANGED 'EKGRP'
                                                       LS_MOD_CELLS-ROW_ID.
        ELSE.
          PERFORM MODIFY_CELL USING PO_DATA_CHANGED 'EKGRP'
                                                          LS_MOD_CELLS-VALUE LS_MOD_CELLS-ROW_ID.
          PERFORM MODIFY_CELL USING PO_DATA_CHANGED 'EKNAM'
                                                          LS_EKGRP-EKNAM LS_MOD_CELLS-ROW_ID.
        ENDIF.

      WHEN 'BNAME'.

        SELECT SINGLE BNAME
           FROM USR21
           WHERE BNAME = @LS_MOD_CELLS-VALUE
               INTO @DATA(LV_EXST).

        IF LV_EXST IS  INITIAL.
          PERFORM ADD_ENTRY USING PO_DATA_CHANGED 'BNAME'
                                                       LS_MOD_CELLS-ROW_ID.
        ELSE.
          PERFORM MODIFY_CELL USING PO_DATA_CHANGED 'BNAME'
                                                          LS_MOD_CELLS-VALUE LS_MOD_CELLS-ROW_ID.
        ENDIF.

    ENDCASE.


    MODIFY GT_LIST FROM LS_LIST INDEX LS_MOD_CELLS-ROW_ID.
  ENDLOOP.

  IF LV_ERR IS NOT INITIAL.
    CALL METHOD PO_DATA_CHANGED->DISPLAY_PROTOCOL.
  ENDIF.

ENDFORM. " DATA_CHANGED_1

*&---------------------------------------------------------------------*
*& FORM MODIFY_CELL
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
*&      --> PR_CHNG
*&      --> P_
*&      --> P_
*&---------------------------------------------------------------------*
FORM MODIFY_CELL USING PR_CHNG TYPE REF TO CL_ALV_CHANGED_DATA_PROTOCOL
                                           PV_FNAME
                                           PV_FVAL
                                           PV_INDEX.

  CALL METHOD PR_CHNG->MODIFY_CELL
    EXPORTING
      I_ROW_ID    = PV_INDEX
      I_FIELDNAME = PV_FNAME
      I_VALUE     = PV_FVAL.

ENDFORM.

*&---------------------------------------------------------------------*
*& FORM ADD_ENTRY
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
*&      --> PR_CHNG
*&      --> P_
*&      --> P_
*&---------------------------------------------------------------------*
FORM ADD_ENTRY     USING PR_CHNG TYPE REF TO CL_ALV_CHANGED_DATA_PROTOCOL
                                           PV_FNAME
                                           PV_INDEX.

  CALL METHOD PR_CHNG->ADD_PROTOCOL_ENTRY
    EXPORTING
      I_MSGID     = 'ZGTMM01'
      I_MSGNO     = '013'
      I_MSGV1     = PV_FNAME
      I_MSGTY     = ZGTFI_E
      I_FIELDNAME = PV_FNAME
      I_ROW_ID    = PV_INDEX.

ENDFORM.

*&---------------------------------------------------------------------*
*& FORM HOTSPOT_CLICK
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
FORM HOTSPOT_CLICK USING PS_ROW_NO TYPE LVC_S_ROW
                                               PS_COLUMN TYPE LVC_S_COL
                                               PO_SENDER.

  CHECK PO_SENDER = GCL_GRID .
  CHECK PS_ROW_NO-ROWTYPE IS INITIAL.

  CASE PO_SENDER.

    WHEN GCL_GRID.
      READ TABLE GT_LIST INTO DATA(LS_LIST) INDEX PS_ROW_NO-INDEX.
      CHECK SY-SUBRC = 0.

      IF PS_COLUMN-FIELDNAME = 'EBELN'.
        CHECK LS_LIST-EBELN IS NOT INITIAL.

        SET PARAMETER ID 'BES' FIELD LS_LIST-EBELN.
        CALL TRANSACTION 'ME23N' AND SKIP FIRST SCREEN.

      ELSEIF PS_COLUMN-FIELDNAME = 'VBELN'.
        CHECK LS_LIST-VBELN IS NOT INITIAL.
        SET PARAMETER ID 'AUN' FIELD LS_LIST-VBELN.
        CALL TRANSACTION 'VA03' AND SKIP FIRST SCREEN.

      ELSEIF PS_COLUMN-FIELDNAME = 'MATNR'.
        CHECK LS_LIST-MATNR IS NOT INITIAL.
        SET PARAMETER ID 'MAT' FIELD LS_LIST-MATNR.
        CALL TRANSACTION 'MM03' AND SKIP FIRST SCREEN.

      ELSEIF PS_COLUMN-FIELDNAME = 'INFNR'.
        CHECK LS_LIST-MATNR IS NOT INITIAL AND  LS_LIST-LIFNR IS NOT INITIAL.
        SET PARAMETER ID 'LIF' FIELD LS_LIST-LIFNR. " VENDOR NUMBER
        SET PARAMETER ID 'MAT' FIELD LS_LIST-MATNR. " MATERIAL NUMBER
        SET PARAMETER ID 'EKO' FIELD LS_LIST-EKORG. " PURCHASING ORGANIZATION
        SET PARAMETER ID 'WRK' FIELD LS_LIST-WERKS.
        CALL TRANSACTION 'ME13' AND SKIP FIRST SCREEN.

      ELSEIF PS_COLUMN-FIELDNAME = 'BANFN'.
        CHECK LS_LIST-BANFN IS NOT INITIAL.
        SET PARAMETER ID 'BAN' FIELD LS_LIST-BANFN.
        CALL TRANSACTION 'ME53N' AND SKIP FIRST SCREEN .

      ELSE.
        EXIT.
      ENDIF.


  ENDCASE.

ENDFORM.

**&---------------------------------------------------------------------*
**&      FORM  ON_F4
**&---------------------------------------------------------------------*
FORM ON_F4  USING E_FIELDNAME    TYPE LVC_FNAME
                  E_FIELDVALUE   TYPE LVC_VALUE
                  ES_ROW_NO      TYPE LVC_S_ROID
                  ER_EVENT_DATA  TYPE REF TO CL_ALV_EVENT_DATA
                  ET_BAD_CELLS   TYPE LVC_T_MODI
                  E_DISPLAY      TYPE CHAR01.
*
*  DATA : SELECTFIELD  LIKE HELP_INFO-FIELDNAME,
*         IT_FIELDS    LIKE HELP_VALUE OCCURS 1 WITH HEADER LINE,
*         LS_HEADING   TYPE F4TYP_HEAD_STRUC,
*         LT_HEADING   TYPE F4TYP_HEADING_TAB,
*         SELECT_VALUE LIKE HELP_INFO-FLDVALUE,
*         LV_TABIX     LIKE SY-TABIX,
*         LS_MODI      TYPE LVC_S_MODI,
*         F_DATE       LIKE SY-DATUM.
*
*  FIELD-SYMBOLS : <F4TAB> TYPE LVC_T_MODI.
*
**  CASE E_FIELDNAME.
**    WHEN .
**    WHEN .
**    WHEN OTHERS.
**  ENDCASE.
*
*  IF E_FIELDNAME = 'HKONT'.
*    "수금유형이 CA 인 경우 환차손/환차익 계정 제외.
*    DATA(LT_TEMP) = GT_ACCT[].
**    IF GS_200-BLART = 'CA'.
**      DELETE LT_TEMP WHERE SAKNR = GC_7140101
**                        OR SAKNR = GC_7330101.
**    ENDIF.
*
*    IT_FIELDS-TABNAME    = 'ZTRTF271'.
*    IT_FIELDS-FIELDNAME  = 'SAKNR'.
*    IT_FIELDS-SELECTFLAG = 'X'.
*    APPEND IT_FIELDS.
*
*    IT_FIELDS-TABNAME    = 'ZTRTF271'.
*    IT_FIELDS-FIELDNAME  = 'TXT50'.
*    IT_FIELDS-SELECTFLAG = ' '.
*    APPEND IT_FIELDS.
*
*    IT_FIELDS-TABNAME    = 'ZTRTF271'.
*    IT_FIELDS-FIELDNAME  = 'SHKZG'.
*    IT_FIELDS-SELECTFLAG = ' '.
*    APPEND IT_FIELDS.
*
**    IT_FIELDS-TABNAME    = 'ZTRTF271'.
**    IT_FIELDS-FIELDNAME  = 'LIMIT'.
**    IT_FIELDS-SELECTFLAG = ' '.
**    APPEND IT_FIELDS.
*
*    CLEAR LS_HEADING.
*    LS_HEADING-TABNAME = 'ZTRTF271'.
*    LS_HEADING-FIELDNAME = 'SAKNR'.
*    LS_HEADING-HEAD_TEXT = TEXT-F38.
*    APPEND LS_HEADING TO LT_HEADING.
*
*    CLEAR LS_HEADING.
*    LS_HEADING-TABNAME = 'ZTRTF271'.
*    LS_HEADING-FIELDNAME = 'TXT50'.
*    LS_HEADING-HEAD_TEXT = TEXT-F39.
*    APPEND LS_HEADING TO LT_HEADING.
*
*    CLEAR LS_HEADING.
*    LS_HEADING-TABNAME = 'ZTRTF271'.
*    LS_HEADING-FIELDNAME = 'SHKZG'.
*    LS_HEADING-HEAD_TEXT = TEXT-F37.
*    APPEND LS_HEADING TO LT_HEADING.
*
**    CLEAR LS_HEADING.
**    LS_HEADING-TABNAME = 'ZTRTF271'.
**    LS_HEADING-FIELDNAME = 'LIMIT'.
**    LS_HEADING-HEAD_TEXT = TEXT-F46.
**    APPEND LS_HEADING TO LT_HEADING.
*
*
*    CALL FUNCTION 'HELP_VALUES_GET_NO_DD_NAME'
*      EXPORTING
*        SELECTFIELD                  = SELECTFIELD
*      IMPORTING
*        IND                          = LV_TABIX
*        SELECT_VALUE                 = SELECT_VALUE
*      TABLES
*        FIELDS                       = IT_FIELDS
*        FULL_TABLE                   = LT_TEMP[]
*        HEADING_TABLE                = LT_HEADING
*      EXCEPTIONS
*        FULL_TABLE_EMPTY             = 1
*        NO_TABLESTRUCTURE_GIVEN      = 2
*        NO_TABLEFIELDS_IN_DICTIONARY = 3
*        MORE_THEN_ONE_SELECTFIELD    = 4
*        NO_SELECTFIELD               = 5
*        OTHERS                       = 6.
*
*    IF SY-SUBRC <> 0.
*      MESSAGE S002 WITH 'POSSIBLE ENTRY DATA가 없습니다 !!!'.
*    ENDIF.
*
*    READ TABLE LT_TEMP INTO DATA(LS_TEMP) INDEX LV_TABIX.
*
*    ASSIGN ER_EVENT_DATA->M_DATA->* TO <F4TAB>.
*
*    LS_MODI-ROW_ID    = ES_ROW_NO-ROW_ID.
*    LS_MODI-FIELDNAME = 'HKONT'.
*    LS_MODI-VALUE     = SELECT_VALUE.
*    APPEND LS_MODI TO <F4TAB>.
*
*    LS_MODI-FIELDNAME = 'HKONT_TX'.
*    LS_MODI-VALUE     = LS_TEMP-TXT50.
*    APPEND LS_MODI TO <F4TAB>.
*
*  ELSEIF E_FIELDNAME = 'MWSKZ'.
*    IT_FIELDS-TABNAME    = 'T007S'.
*    IT_FIELDS-FIELDNAME  = 'MWSKZ'.
*    IT_FIELDS-SELECTFLAG = 'X'.
*    APPEND IT_FIELDS.
*
*    IT_FIELDS-TABNAME    = 'T007S'.
*    IT_FIELDS-FIELDNAME  = 'TEXT1'.
*    IT_FIELDS-SELECTFLAG = ' '.
*    APPEND IT_FIELDS.
*
*    CLEAR LS_HEADING.
*    LS_HEADING-TABNAME = 'T007S'.
*    LS_HEADING-FIELDNAME = 'MWSKZ'.
*    LS_HEADING-HEAD_TEXT = TEXT-F54.
*    APPEND LS_HEADING TO LT_HEADING.
*
*    CLEAR LS_HEADING.
*    LS_HEADING-TABNAME = 'T007S'.
*    LS_HEADING-FIELDNAME = 'TEXT1'.
*    LS_HEADING-HEAD_TEXT = TEXT-F60.
*    APPEND LS_HEADING TO LT_HEADING.
*
*    CALL FUNCTION 'HELP_VALUES_GET_NO_DD_NAME'
*      EXPORTING
*        SELECTFIELD                  = SELECTFIELD
*      IMPORTING
*        IND                          = LV_TABIX
*        SELECT_VALUE                 = SELECT_VALUE
*      TABLES
*        FIELDS                       = IT_FIELDS
*        FULL_TABLE                   = GT_007S
*        HEADING_TABLE                = LT_HEADING
*      EXCEPTIONS
*        FULL_TABLE_EMPTY             = 1
*        NO_TABLESTRUCTURE_GIVEN      = 2
*        NO_TABLEFIELDS_IN_DICTIONARY = 3
*        MORE_THEN_ONE_SELECTFIELD    = 4
*        NO_SELECTFIELD               = 5
*        OTHERS                       = 6.
*
*    IF SY-SUBRC <> 0.
*      MESSAGE S002 WITH 'POSSIBLE ENTRY DATA가 없습니다 !!!'.
*    ENDIF.
*
*    READ TABLE GT_007S INDEX LV_TABIX.
*
*    ASSIGN ER_EVENT_DATA->M_DATA->* TO <F4TAB>.
*
*    LS_MODI-ROW_ID    = ES_ROW_NO-ROW_ID.
*    LS_MODI-FIELDNAME = 'MWSKZ'.
*    LS_MODI-VALUE     = SELECT_VALUE.
*    APPEND LS_MODI TO <F4TAB>.
*
*    LS_MODI-FIELDNAME = 'MWSKZ_TX'.
*    LS_MODI-VALUE     = GT_007S-TEXT1.
*    APPEND LS_MODI TO <F4TAB>.
*  ENDIF.
*
** TO AVOID STANDARD F4-HELP.
*  IF LS_MODI-VALUE <> ' ' .
*    ER_EVENT_DATA->M_EVENT_HANDLED = 'X'.
*  ENDIF.

ENDFORM.                                                    " ON_F41

*&---------------------------------------------------------------------*
*& FORM SET_F4_FIELD
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
FORM SET_F4_FIELD .

*  CLEAR : GT_F4_3, GT_F4_4.
*
*  IF GV_300GB = 1.
*    GS_F4_4-FIELDNAME  = 'MWSKZ'.
*    GS_F4_4-REGISTER   = 'X'.
*    APPEND GS_F4_4 TO GT_F4_4.
*
*    CALL METHOD GCL_GRID_4->REGISTER_F4_FOR_FIELDS
*      EXPORTING
*        IT_F4 = GT_F4_4.
*  ENDIF.
*
*  GS_F4_3-FIELDNAME  = 'HKONT'.
*  GS_F4_3-REGISTER   = 'X'.
*  APPEND GS_F4_3 TO GT_F4_3.
*
*  CALL METHOD GCL_GRID_3->REGISTER_F4_FOR_FIELDS
*    EXPORTING
*      IT_F4 = GT_F4_3.

ENDFORM.

*&---------------------------------------------------------------------*
*& FORM SET_CHANGE_SAVE
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
*& -->  P1        TEXT
*& <--  P2        TEXT
*&---------------------------------------------------------------------*
FORM SET_CHANGE_SAVE .

*  IF LINE_EXISTS( GT_LIST[ STATUS = ICON_LED_RED ] ) OR
*    LINE_EXISTS( GT_LIST[ STATUS = ICON_CHANGE ] ).
*
*    PERFORM POPUP_TO_CONFIRM_STEP USING ZGTFI_N
*                                                               TEXT-M06  "자재마스터 정보가 변경됩니다.
*                                                               TEXT-M07  "저장 하시겠습니까?
*                                                               TEXT-T04. "확인
*    CHECK GV_ANSWER = ZGTFI_J. "YES
*    PERFORM SAVE_DATA.
*
*  ELSE.
*    MESSAGE S017 DISPLAY LIKE ZGTFI_E.
*    "변경된 내역이 없습니다.
*  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& FORM REQUEST_DATA
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
*& -->  P1        TEXT
*& <--  P2        TEXT
*&---------------------------------------------------------------------*
FORM REQUEST_DATA .

  DATA : LT_LIST    LIKE TABLE OF GS_LIST,
         LT_3000    LIKE TABLE OF ZGTMMT3000,
         LV_MESSAGE TYPE CHAR100,
         LV_MSG     TYPE STRING,
         LV_CHK.

  DATA:
    LV_CHECK       TYPE C LENGTH 1,
    LO_RECEIVER    TYPE REF TO IF_RECIPIENT_BCS,
    LO_EMAIL       TYPE REF TO CL_BCS,
    LO_EMAIL_BODY  TYPE REF TO CL_DOCUMENT_BCS,
    LX_EXCEPTION   TYPE REF TO CX_BCS,
    LV_SEND_RESULT TYPE C.

  DATA:
    LV_EMAIL     TYPE AD_SMTPADR,
    LV_HEAD_TEXT TYPE SO_OBJ_DES.

  CLEAR : GV_TEXT, GV_ANSWER, GV_ERR, LT_3000.

  PERFORM GET_SELECTED_ROWS USING GCL_GRID.
  CHECK GV_ERR IS INITIAL.

  LOOP AT GT_ROWS INTO GS_ROW.

    READ TABLE GT_LIST  INTO DATA(LS_LIST) INDEX GS_ROW-INDEX.
    IF SY-SUBRC = 0.
      IF LS_LIST-REQ_A IS INITIAL.
        APPEND LS_LIST TO LT_LIST.

*구매오더 승인 요청 현황_ZGTMMT3000 LOG UPDATE
        APPEND VALUE #( EBELN = LS_LIST-EBELN
                                     ERDAT = SY-DATUM
                                     ERDAT_LOCAL = SY-DATLO
                                     ERTIM = SY-UZEIT
                                     ERTIM_LOCAL = SY-TIMLO
                                     ERNAM = SY-UNAME ) TO LT_3000.

      ELSE.
        CLEAR LT_LIST[]. EXIT.
      ENDIF.
    ENDIF.
  ENDLOOP.

  IF LT_LIST[] IS INITIAL.
    MESSAGE S000 WITH TEXT-E05 DISPLAY LIKE GC_E. "승인된 구매오더는 승인 요청을 할 수 없습니다.
    GV_ERR = GC_X. EXIT.

  ELSE.
    PERFORM POPUP_TO_CONFIRM_STEP USING GC_N
                                                               TEXT-M08 "선택된 정보의 구매오더 번호를 기준으로
                                                               TEXT-M09 "모든 항번의 승인 요청을 진행하시겠습니까?
                                                               TEXT-T04. " 확인
  ENDIF.

  CHECK GV_ANSWER = ZGTFI_J. "YES
  CHECK GV_ERR IS INITIAL.

  SORT LT_LIST BY EKGRP LIFNR NAME1.
  DELETE ADJACENT DUPLICATES FROM LT_LIST COMPARING EKGRP LIFNR.

*승인자정보 조회
  SELECT FROM ZGTMMT1020 FIELDS *
    FOR ALL ENTRIES IN @LT_LIST
    WHERE WERKS = @LT_LIST-WERKS
         AND EKGRP = @LT_LIST-EKGRP
    INTO TABLE @DATA(LT_1020).
  SORT LT_1020 BY EKGRP.

  IF SY-SUBRC EQ 0.

    LV_HEAD_TEXT = '[승인요청]구매오더 생성 건에 대한 승인요청 드립니다.'(m16).


    SORT LT_LIST BY EKGRP EBELN EBELP.

    DATA:
      LV_LINE TYPE SO_TEXT255,
      LT_BODY TYPE BCSY_TEXT.


    LOOP AT LT_LIST INTO LS_LIST.
      AT NEW EKGRP.

        LV_LINE = |<html><body style="font-size:14">|.
        LT_BODY = VALUE #( BASE LT_BODY ( LINE = LV_LINE ) ).
        LV_LINE = |<p>{ TEXT-EM1 }</p>|.

        LT_BODY = VALUE #( BASE LT_BODY ( LINE = LV_LINE ) ).
        LV_LINE = |<p>SAP T-code <strong>ZGTMMR3020</strong>에서 확인 부탁드립니다. </p>|.
        LT_BODY = VALUE #( BASE LT_BODY ( LINE = LV_LINE ) ).

        LV_LINE = |<table border=1 STYLE="border-collapse: collapse;border-color: #000000;font-size:11:width:600px" >|.
        LT_BODY = VALUE #( BASE LT_BODY ( LINE = LV_LINE ) ).

        LV_LINE = |<tr align="center" style="background-color: #B3B1B1" ><td width="200px"><strong>공급업체코드</strong></td>|.
        LT_BODY = VALUE #( BASE LT_BODY ( LINE = LV_LINE ) ).
        LV_LINE = |<td width="400px" ><strong>공급업체명</strong></td>|.
        LT_BODY = VALUE #( BASE LT_BODY ( LINE = LV_LINE ) ).
      ENDAT.

      LV_LINE = |<tr><td align="center" >{ LS_LIST-LIFNR  ALPHA = OUT }</td>|.
      LT_BODY = VALUE #( BASE LT_BODY ( LINE = LV_LINE ) ).
      LV_LINE = |<td align="center" >{ LS_LIST-NAME1 ALPHA = OUT }</td>|.
      LT_BODY = VALUE #( BASE LT_BODY ( LINE = LV_LINE ) ).


      AT END OF EKGRP.

        LV_LINE = |</table></body></html>|.
        LT_BODY = VALUE #( BASE LT_BODY ( LINE = LV_LINE ) ).

        READ TABLE LT_1020 INTO DATA(LS_1020) WITH KEY EKGRP = LS_LIST-EKGRP.

        SELECT SINGLE EMAIL AS USRID
         FROM ZGTMM_CV_GETUSERNAME_G
         WHERE USERID = @LS_1020-ANAME
           AND   SUBTY = '0007'
         INTO @DATA(LV_EMAIL_T).

        LV_EMAIL =  LV_EMAIL_T.

        TRY.
            LO_EMAIL = CL_BCS=>CREATE_PERSISTENT( ).

            LO_EMAIL_BODY = CL_DOCUMENT_BCS=>CREATE_DOCUMENT(
                            I_TYPE    = 'HTM'
                            I_TEXT    = LT_BODY
                            I_SUBJECT = LV_HEAD_TEXT ).

            LO_EMAIL->SET_DOCUMENT( LO_EMAIL_BODY ).

            LO_RECEIVER =
            CL_CAM_ADDRESS_BCS=>CREATE_INTERNET_ADDRESS( LV_EMAIL ).

            LO_EMAIL->ADD_RECIPIENT( I_RECIPIENT = LO_RECEIVER
                                     I_EXPRESS = 'X' ).

            LO_EMAIL->SET_SEND_IMMEDIATELY( 'X' ).

            LO_EMAIL->SEND( EXPORTING I_WITH_ERROR_SCREEN = 'X'
                            RECEIVING RESULT = LV_SEND_RESULT ).
          CATCH CX_BCS INTO LX_EXCEPTION.
            LV_CHECK = GC_E.
        ENDTRY.

        CLEAR : LV_CHECK,    LO_RECEIVER ,  LO_EMAIL ,  LO_EMAIL_BODY ,  LX_EXCEPTION  ,    LV_SEND_RESULT.

        CLEAR  : GT_MTXT , LV_MSG , LT_BODY[], LT_BODY, LV_EMAIL.
      ENDAT.

    ENDLOOP.


    IF LT_3000[] IS NOT INITIAL.
      SORT LT_3000 BY EBELN.
      DELETE ADJACENT DUPLICATES FROM LT_3000 COMPARING EBELN.

      MODIFY ZGTMMT3000 FROM TABLE LT_3000.
      IF SY-SUBRC = 0.
        COMMIT WORK AND WAIT.
      ENDIF.
    ENDIF.


    PERFORM GET_DATA.

  ELSE.

    MESSAGE S000 WITH '승인자 정보가 없습니다.' DISPLAY LIKE GC_E.
  ENDIF.




ENDFORM.
*&---------------------------------------------------------------------*
*& FORM GET_SELECTED_ROWS
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
*&      --> GR_GRID
*&      --> P_
*&      --> P_
*&      --> P_
*&---------------------------------------------------------------------*
FORM GET_SELECTED_ROWS USING PR_GRID TYPE REF TO CL_GUI_ALV_GRID.

  CLEAR : GT_ROWS, GS_ROW, GV_ERR.

  CALL METHOD PR_GRID->GET_SELECTED_ROWS
    IMPORTING
      ET_INDEX_ROWS = GT_ROWS.

  DESCRIBE TABLE GT_ROWS.

  IF SY-TFILL = 0.
    GV_ERR = GC_X.
    MESSAGE S004 DISPLAY LIKE GC_E. "라인을 선택하세요.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& FORM ORDER_FINISH_DATA
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
*& -->  P1        TEXT
*& <--  P2        TEXT
*&---------------------------------------------------------------------*
FORM ORDER_FINISH_DATA  USING PV_GB.

  DATA : LT_LIST  LIKE TABLE OF GS_LIST,
         LT_ITEM  TYPE TABLE OF BAPIMEPOITEM,
         LT_ITEMX TYPE TABLE OF BAPIMEPOITEMX.
  DATA : LV_ERR TYPE CHAR1.

  CLEAR : GV_ANSWER, GV_ERR.

  PERFORM GET_SELECTED_ROWS USING GCL_GRID.
  CHECK GV_ERR IS INITIAL.

*  SORT gt_list BY ebeln ebelp.

  LOOP AT GT_ROWS INTO GS_ROW.

    READ TABLE GT_LIST  INTO DATA(LS_LIST) INDEX GS_ROW-INDEX.
    IF SY-SUBRC = 0.

      CASE PV_GB.
        WHEN GC_F. "발주종료
          IF LS_LIST-ELIKZ IS INITIAL.
            APPEND LS_LIST TO LT_LIST.
          ENDIF.

        WHEN GC_R. "발주종료해제
          IF LS_LIST-ELIKZ = GC_X.
            APPEND LS_LIST TO LT_LIST.
          ENDIF.
        WHEN OTHERS.
      ENDCASE.

    ENDIF.
  ENDLOOP.

  IF LT_LIST[] IS INITIAL.
    IF PV_GB = GC_F.
      MESSAGE S000 WITH TEXT-E03 DISPLAY LIKE GC_E. "종료할 발주 정보가 없습니다.
    ELSE.
      MESSAGE S000 WITH TEXT-E04 DISPLAY LIKE GC_E. "종료해제할 발주 정보가 없습니다.
    ENDIF.
    GV_ERR = GC_X. EXIT.

  ELSE.
    DATA(LV_MSG)  = COND BAPIRET2-MESSAGE( WHEN PV_GB = GC_F THEN TEXT-M04 ELSE TEXT-M06 ).
    DATA(LV_MSG2) = COND BAPIRET2-MESSAGE( WHEN PV_GB = GC_F THEN TEXT-M05 ELSE TEXT-M07 ).

    PERFORM POPUP_TO_CONFIRM_STEP USING GC_N
                                                              LV_MSG   "이미 종료 처리(해제)된 PO는 처리에서 제외됩니다.
                                                              LV_MSG2  "PO 발주 종료 처리(해제) 하시겠습니까?
                                                              TEXT-T04. " 확인
  ENDIF.

  CHECK GV_ANSWER = ZGTFI_J. "YES
  CHECK GV_ERR IS INITIAL.
  SORT LT_LIST BY EBELN EBELP.

*BAPI SET
  LOOP AT LT_LIST INTO DATA(LS_LIST2) GROUP BY LS_LIST2-EBELN
    INTO DATA(LT_GRP).

    DATA(LV_TABIX) = SY-TABIX.
    CLEAR : LT_ITEM, LT_ITEMX, GT_RETURN.

    LOOP AT GROUP LT_GRP ASSIGNING FIELD-SYMBOL(<GRP>).
      DATA(LV_EBELN) = <GRP>-EBELN.
      APPEND VALUE #( PO_ITEM = <GRP>-EBELP
                                   NO_MORE_GR = COND #( WHEN PV_GB = GC_F THEN GC_X ELSE '' ) ) TO LT_ITEM.

      APPEND VALUE #( PO_ITEM = <GRP>-EBELP
                                   PO_ITEMX = GC_X
                                   NO_MORE_GR = GC_X  ) TO LT_ITEMX.
    ENDLOOP.

*BAPI_EBELN 기준 PO 변경
    CALL FUNCTION 'BAPI_PO_CHANGE'
      EXPORTING
        PURCHASEORDER = LV_EBELN
      TABLES
        RETURN        = GT_RETURN
        POITEM        = LT_ITEM
        POITEMX       = LT_ITEMX.

    IF LINE_EXISTS( GT_RETURN[ TYPE = GC_E ] ).
      CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
      READ TABLE GT_RETURN INTO DATA(LS_RT) INDEX 1.

      LOOP AT GROUP LT_GRP ASSIGNING FIELD-SYMBOL(<GRP2>).
        CLEAR <GRP2>-ELIKZ.
        <GRP2>-STATUS    = ICON_LED_RED.
        <GRP2>-MESSAGE = LV_MSG = LS_RT-MESSAGE.
      ENDLOOP.
      LV_ERR = GC_X.
    ELSE.
      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
        EXPORTING
          WAIT = GC_X.

      LOOP AT GROUP LT_GRP ASSIGNING FIELD-SYMBOL(<GRP3>).
        <GRP3>-ELIKZ       = GC_X.
        <GRP3>-STATUS    = ICON_LED_GREEN.
        <GRP3>-MESSAGE = COND #( WHEN PV_GB = GC_F THEN '구매오더 종결 완료'(m14)
                                                       ELSE '구매오더 종결 해제 완료'(m15) ).
        LV_MSG = <GRP3>-MESSAGE.
      ENDLOOP.
    ENDIF.

  ENDLOOP.

*ALV UPDATE
  SORT GT_LIST BY EBELN EBELP.

  LOOP AT LT_LIST ASSIGNING FIELD-SYMBOL(<FS_G>).

    READ TABLE GT_LIST ASSIGNING FIELD-SYMBOL(<FS_MAIN>)
    WITH KEY EBELN = <FS_G>-EBELN BINARY SEARCH.
    IF SY-SUBRC = 0.
      LV_TABIX = SY-TABIX.
      <FS_MAIN>-ELIKZ       = <FS_G>-ELIKZ.
      <FS_MAIN>-STATUS    = <FS_G>-STATUS.
      <FS_MAIN>-MESSAGE = <FS_G>-MESSAGE.
    ENDIF.
  ENDLOOP.

  IF LV_ERR <> GC_X.
    PERFORM GET_DATA.
  ENDIF.

  MESSAGE S000 WITH LV_MSG.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PO_DELETE_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PO_DELETE_DATA .

  DATA : LT_LIST  LIKE TABLE OF GS_LIST,
         LT_ITEM  TYPE TABLE OF BAPIMEPOITEM,
         LT_ITEMX TYPE TABLE OF BAPIMEPOITEMX.
  DATA : LV_ERR2 TYPE CHAR1.

  CLEAR : GV_ANSWER, GV_ERR.

  PERFORM GET_SELECTED_ROWS USING GCL_GRID.
  CHECK GV_ERR IS INITIAL.

  PERFORM POPUP_TO_CONFIRM_STEP USING GC_N
                                                            TEXT-M17 "PO 삭제 처리 하시겠습니까?
                                                            ''
                                                            TEXT-T04. " 확인
  CHECK GV_ANSWER = ZGTFI_J. "YES
*  SORT GT_LIST BY EBELN EBELP.

  LOOP AT GT_ROWS INTO GS_ROW.

    READ TABLE GT_LIST  INTO DATA(LS_LIST) INDEX GS_ROW-INDEX.
    IF SY-SUBRC = 0.

      IF LS_LIST-EBELN IS INITIAL .
        LS_LIST-STATUS    = ICON_LED_RED.
        LS_LIST-MESSAGE = '삭제할 PO가 없습니다.'(m18).
        LV_ERR2 = GC_X.
        MODIFY GT_LIST FROM LS_LIST INDEX GS_ROW-INDEX.
        CLEAR : LS_LIST.
        CONTINUE.
      ENDIF.

      IF  LS_LIST-LOEKZ <> ''.
        LS_LIST-STATUS    = ICON_LED_RED.
        LS_LIST-MESSAGE = '이미 삭제된 PO 입니다.'(m18).
        LV_ERR2 = GC_X.
        MODIFY GT_LIST FROM LS_LIST INDEX GS_ROW-INDEX.
        CLEAR : LS_LIST.
        CONTINUE.
      ENDIF.

      IF  LS_LIST-GR_MENGE > 0.
        LS_LIST-STATUS    = ICON_LED_RED.
        LS_LIST-MESSAGE = '입고 진행된 PO는 삭제할 수 없습니다.'(m18).
        LV_ERR2 = GC_X.
        MODIFY GT_LIST FROM LS_LIST INDEX GS_ROW-INDEX.
        CLEAR : LS_LIST.
        CONTINUE.
      ENDIF.


      APPEND VALUE #( PO_ITEM = LS_LIST-EBELP
                                   DELETE_IND = 'L' ) TO LT_ITEM.

      APPEND VALUE #( PO_ITEM     = LS_LIST-EBELP
                                   PO_ITEMX   = GC_X
                                   DELETE_IND = GC_X  ) TO LT_ITEMX.

*BAPI_EBELN 기준 PO 변경
      CALL FUNCTION 'BAPI_PO_CHANGE'
        EXPORTING
          PURCHASEORDER = LS_LIST-EBELN
        TABLES
          RETURN        = GT_RETURN
          POITEM        = LT_ITEM
          POITEMX       = LT_ITEMX.
      IF LINE_EXISTS( GT_RETURN[ TYPE = GC_E ] ).
        CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
        READ TABLE GT_RETURN INTO DATA(LS_RT) INDEX 1.

        IF SY-SUBRC = 0.
          LS_LIST-STATUS    = ICON_LED_RED.
          LS_LIST-MESSAGE = LS_RT-MESSAGE.
        ENDIF.

        LV_ERR2 = GC_X.
      ELSE.
        CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
          EXPORTING
            WAIT = GC_X.
        READ TABLE GT_RETURN INTO LS_RT INDEX 1.
        IF SY-SUBRC = 0.
          LS_LIST-STATUS    = ICON_LED_GREEN.
          LS_LIST-MESSAGE = LS_RT-MESSAGE.
        ENDIF.

*PP CBO TABLE DELETE CHECK
        SELECT  FROM ZGTPPT2340
          FIELDS *
          WHERE WERKS = @LS_LIST-WERKS
               AND MATNR = @LS_LIST-MATNR
               AND ORDNR = @LS_LIST-EBELN
               AND POSNR = @LS_LIST-EBELP
               AND ORDTY = @GC_PO
          INTO TABLE @DATA(LT_2340).
*데이터가 있을 경우에는 삭제한다.
        IF LT_2340[] IS NOT INITIAL.
          DELETE ZGTPPT2340 FROM TABLE LT_2340.
        ENDIF.

      ENDIF.

    ENDIF.

    MODIFY GT_LIST FROM LS_LIST INDEX GS_ROW-INDEX.
    CLEAR : LT_ITEM, LT_ITEMX, LS_LIST.
  ENDLOOP.

  IF LV_ERR2 <> GC_X.

    PERFORM GET_DATA.
  ENDIF.


ENDFORM.
