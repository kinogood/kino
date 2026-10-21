*&---------------------------------------------------------------------*
*& INCLUDE          ZGTMMR3000F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& FORM CREATE_ALV
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
FORM CREATE_ALV .

  PERFORM :
            SET_ALV_GRID USING '',
            SET_ALV_FIELDCAT USING 'IH',
            SET_ALV_FIELDCAT USING 'IB',
            SET_ALV_LAYOUT USING 'INV' GCL_GRID_HD,
            SET_ALV_LAYOUT USING 'INV' GCL_GRID_IT,
            SET_ALV_TOOLBAR,
            SET_ALV_SORT,
            SET_CELL_COLOR,
            SET_EVENT        CHANGING GCL_EVENT GCL_GRID_HD,
            SET_EVENT        CHANGING GCL_EVENT GCL_GRID_IT.

  PERFORM DISPLAY_ALV TABLES GT_LIST GT_FCAT
                                          USING GCL_GRID_HD GS_LAYOUT.
  PERFORM DISPLAY_ALV TABLES GT_ITEM GT_FCAT_IT
                                         USING GCL_GRID_IT GS_LAYOIT.

ENDFORM.
*&---------------------------------------------------------------------*
*& FORM CREATE_ALV_300
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
FORM CREATE_ALV_300.

  PERFORM :
            SET_ALV_GRID USING '',
            SET_ALV_FIELDCAT USING 'DH',
            SET_ALV_FIELDCAT USING 'DB',
            SET_ALV_LAYOUT USING 'DISP' GCL_GRID_HD,
            SET_ALV_LAYOUT USING 'DISP' GCL_GRID_IT,
            SET_ALV_TOOLBAR,
            SET_ALV_SORT,
            SET_CELL_COLOR_300 ,
            SET_EVENT        CHANGING GCL_EVENT GCL_GRID_HD,
            SET_EVENT        CHANGING GCL_EVENT GCL_GRID_IT.

  PERFORM DISPLAY_ALV TABLES GT_DISP GT_FCAT_DISP
                                         USING GCL_GRID_HD GS_LAYOUT.
  PERFORM DISPLAY_ALV TABLES GT_DISP_IT GT_FCAT_DIT
                                         USING GCL_GRID_IT GS_LAYOIT.

ENDFORM.
*&---------------------------------------------------------------------*
*& FORM CREATE_ALV_300
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
FORM CREATE_ALV_400.

  PERFORM :
            SET_ALV_GRID USING 'TAX',
            SET_ALV_FIELDCAT USING 'TAX',
            SET_ALV_LAYOUT USING 'TAX' GCL_GRID_TAX,
            SET_ALV_TOOLBAR,
            SET_ALV_SORT,
            SET_CELL_COLOR_400 ,
            SET_EVENT        CHANGING GCL_EVENT GCL_GRID_TAX,
            DISPLAY_ALV_400 .

ENDFORM.
*&---------------------------------------------------------------------*
*& FORM SET_ALV_GRID
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
FORM SET_ALV_GRID USING PV_GB.

  DATA:
    LO_SPLIT TYPE REF TO CL_GUI_SPLITTER_CONTAINER,
    LO_HCNTR TYPE REF TO CL_GUI_CONTAINER,
    LO_ICNTR TYPE REF TO CL_GUI_CONTAINER.

  IF PV_GB = 'TAX'.
    GCL_CUSTOM2 = NEW #( CONTAINER_NAME = 'CON400' ).
    GCL_GRID_TAX = NEW #( I_PARENT = GCL_CUSTOM2 ).

  ELSE.
*    CASE SY-DYNNR.
*      WHEN '0100'.
*        GCL_DOCK_IT = NEW #( REPID = SY-REPID
*                                              DYNNR   = SY-DYNNR
*                                              SIDE       = CL_GUI_DOCKING_CONTAINER=>DOCK_AT_BOTTOM
*                                              EXTENSION = 100 ).
*
*        GCL_DOCK_HD = NEW #( REPID = SY-REPID
*                                              DYNNR   = SY-DYNNR
*                                              SIDE       = CL_GUI_DOCKING_CONTAINER=>DOCK_AT_TOP
*                                              EXTENSION = 100 ).
*        "ALV OBJ.
*        GCL_GRID_HD = NEW #( I_PARENT = GCL_DOCK_HD ).
*        GCL_GRID_IT = NEW #( I_PARENT = GCL_DOCK_IT ).
*
*      WHEN '0300'.
        GCL_CUSTOM = NEW #( CONTAINER_NAME = 'CON100' ).

    "SPLIT CONTAINER
        LO_SPLIT = NEW #( PARENT  = GCL_CUSTOM
                                      ROWS    = 2
                                      COLUMNS = 1 ).

        LO_HCNTR = LO_SPLIT->GET_CONTAINER( ROW = 1 COLUMN = 1 ).
        LO_ICNTR = LO_SPLIT->GET_CONTAINER( ROW = 2 COLUMN = 1 ).

        "ALV OBJ.
        GCL_GRID_HD = NEW #( I_PARENT = LO_HCNTR ).
        GCL_GRID_IT = NEW #( I_PARENT = LO_ICNTR ).

*      WHEN OTHERS.
*    ENDCASE.

*    "ALV OBJ.
*    GCL_GRID_HD = NEW #( I_PARENT = GCL_DOCK_HD ). "LO_HCNTR ).
*    GCL_GRID_IT = NEW #( I_PARENT = GCL_DOCK_IT ). "LO_ICNTR ).
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*& FORM ADJUST_FLDCATS
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
FORM ADJUST_FLDCATS  TABLES PT_FCAT TYPE LVC_T_FCAT .

  DEFINE _FCAT.
    <FS_S_FCT>-SCRTEXT_S  =
    <FS_S_FCT>-SCRTEXT_M  =
    <FS_S_FCT>-SCRTEXT_L  =
    <FS_S_FCT>-COLTEXT    =
    <FS_S_FCT>-REPTEXT    = &1.
  END-OF-DEFINITION.

  DATA LV_COL TYPE I.
  CLEAR : GT_FCAT[].

  LOOP AT PT_FCAT ASSIGNING FIELD-SYMBOL(<FS_S_FCT>).
    CLEAR : <FS_S_FCT>-COL_POS.

    CASE <FS_S_FCT>-FIELDNAME.
      WHEN 'CHECK'.
        _FCAT TEXT-F35. "선택
        <FS_S_FCT>-CHECKBOX = GC_X.
        <FS_S_FCT>-EDIT = GC_X.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'STATUS'. "상태
        _FCAT TEXT-F01.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'WERKS'.       "플랜트
        _FCAT TEXT-F02.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'WERKS_N'.  "플랜트명
        _FCAT TEXT-F03.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'LIFNR'.   "공급업체
        _FCAT TEXT-F16.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'LIFNR_N'.   "업체명
        _FCAT TEXT-F17.
        <FS_S_FCT>-JUST = 'C'.
        <FS_S_FCT>-EMPHASIZE = 'C410'.
      WHEN 'BUKRS'.       "회사코드
        _FCAT TEXT-F30.
        <FS_S_FCT>-NO_OUT = GC_X.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'BUKRS_N'.  "회사명
        _FCAT TEXT-F55.
        <FS_S_FCT>-NO_OUT = GC_X.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'EKORG'.       "구매조직
        _FCAT TEXT-F10.
        <FS_S_FCT>-NO_OUT = GC_X.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'EKORG_N'.  "구매조직명
        _FCAT TEXT-F75.
        <FS_S_FCT>-NO_OUT = GC_X.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'SPMON'.        "입고연월
        _FCAT TEXT-F24.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'EKGRP'.      "구매그룹 "P_EKG(구매그룹별조회)일 경우에만 노출
        _FCAT TEXT-F08.
        <FS_S_FCT>-NO_OUT = COND #( WHEN P_LIF = GC_X THEN GC_X ELSE SPACE ).
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'EKNAM'.     "구매그룹명 "P_EKG(구매그룹별조회)일 경우에만 노출
        _FCAT TEXT-F09.
        <FS_S_FCT>-NO_OUT = COND #( WHEN P_LIF = GC_X THEN GC_X ELSE SPACE ).
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'XRECH'.     "반품정산대상
        _FCAT TEXT-FA0.
        <FS_S_FCT>-NO_OUT = GC_X.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'XRECH_N'.     "반품정산대상
        _FCAT TEXT-FA1.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'TARGET_PRICE'.     "공급가액
        _FCAT TEXT-F29.
        <FS_S_FCT>-CFIELDNAME = 'ETIV_WAERS'.
        <FS_S_FCT>-JUST = 'R'.
        <FS_S_FCT>-EMPHASIZE = 'C300'.
      WHEN 'TAXPRICE'.        "세액
        _FCAT TEXT-F33.
        <FS_S_FCT>-CFIELDNAME = 'ETIV_WAERS'.
        <FS_S_FCT>-JUST = 'R'.
        <FS_S_FCT>-EMPHASIZE = 'C500'.
      WHEN 'ETIV_WAERS'.        "통화
        _FCAT TEXT-F34.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'WRBTR'.        "합계금액
        _FCAT TEXT-F37.
        <FS_S_FCT>-CFIELDNAME = 'ETIV_WAERS'.
        <FS_S_FCT>-EMPHASIZE = 'C310'. "C:색 3:노랑 1:진하게 0:반전없음
        <FS_S_FCT>-JUST = 'R'.
        <FS_S_FCT>-EMPHASIZE = 'C700'.
      WHEN 'EXRATE'.        "환율
        _FCAT TEXT-F42.
        <FS_S_FCT>-EDIT = GC_X.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'MESSAGE'.   "메시지
        _FCAT TEXT-F68.
        <FS_S_FCT>-JUST = 'C'.

      WHEN OTHERS.
        <FS_S_FCT>-NO_OUT = GC_X.

    ENDCASE.

    APPEND <FS_S_FCT> TO GT_FCAT.
  ENDLOOP.

ENDFORM.

*&---------------------------------------------------------------------*
*& FORM ADJUST_FLDCATS_DISP
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
FORM ADJUST_FLDCATS_DISP  TABLES PT_FCAT TYPE LVC_T_FCAT  USING PV_GB.

  DEFINE _FCAT.
    <FS_S_FCT>-SCRTEXT_S  =
    <FS_S_FCT>-SCRTEXT_M  =
    <FS_S_FCT>-SCRTEXT_L  =
    <FS_S_FCT>-COLTEXT    =
    <FS_S_FCT>-REPTEXT    = &1.
  END-OF-DEFINITION.

  DATA LV_COL TYPE I.
  IF PV_GB = 'HD'.
    CLEAR  GT_FCAT_DISP[].
  ELSE.
    CLEAR GT_FCAT_DIT[].
  ENDIF.

  LOOP AT PT_FCAT ASSIGNING FIELD-SYMBOL(<FS_S_FCT>).
    CLEAR : <FS_S_FCT>-COL_POS.

    CASE <FS_S_FCT>-FIELDNAME.
      WHEN 'CHECK'.
        _FCAT TEXT-F35. "선택
        <FS_S_FCT>-CHECKBOX = GC_X.
        <FS_S_FCT>-EDIT = GC_X.
        <FS_S_FCT>-NO_OUT = COND  #( WHEN PV_GB = 'IT' THEN GC_X ELSE '' ).
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'STATUS'. "상태
        _FCAT TEXT-F01.
        <FS_S_FCT>-NO_OUT = COND  #( WHEN PV_GB = 'IT' THEN GC_X ELSE '' ).
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'TIMESTAMP'.
        _FCAT TEXT-FA2.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'REQ'. "지급요청
        _FCAT TEXT-F04.
        <FS_S_FCT>-NO_OUT = COND  #( WHEN PV_GB = 'IT' THEN GC_X ELSE '' ).
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'AP_STATUS_N'. "승인상태명
        _FCAT TEXT-F05.
        <FS_S_FCT>-NO_OUT = COND  #( WHEN PV_GB = 'IT' THEN GC_X ELSE '' ).
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'BUKRS'. "회사코드
        _FCAT TEXT-F30.
        <FS_S_FCT>-NO_OUT =  GC_X .
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'BUTXT'. "회사명
        _FCAT TEXT-F55.
        <FS_S_FCT>-NO_OUT =  GC_X .
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'BELNR'. "송장번호
        _FCAT TEXT-F07.
        <FS_S_FCT>-NO_OUT = COND  #( WHEN PV_GB = 'HD' THEN GC_X ELSE '' ).
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'BLART'. "전표유형
        _FCAT TEXT-F95.
        <FS_S_FCT>-NO_OUT =  GC_X .
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'GJAHR'. "회계연도
        _FCAT TEXT-F11.
        <FS_S_FCT>-NO_OUT = COND  #( WHEN PV_GB = 'HD' THEN GC_X ELSE '' ).
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'BUZEI'. "송장항번
        _FCAT TEXT-F13.
        <FS_S_FCT>-NO_OUT = COND  #( WHEN PV_GB = 'HD' THEN GC_X ELSE '' ).
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'EBELN'.     "구매오더
        _FCAT TEXT-F22.
        <FS_S_FCT>-NO_OUT = COND  #( WHEN PV_GB = 'HD' THEN GC_X ELSE '' ).
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'EBELP'.    "항번
        _FCAT TEXT-F13.
        <FS_S_FCT>-NO_OUT = COND  #( WHEN PV_GB = 'HD' THEN GC_X ELSE '' ).
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'XRECH'.     "반품정산대상
        _FCAT TEXT-FA0.
        <FS_S_FCT>-NO_OUT = GC_X.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'XRECH_N'.     "반품정산대상
        _FCAT TEXT-FA1.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'BUDAT'. "전기일
        _FCAT TEXT-F12.
        <FS_S_FCT>-NO_OUT = COND  #( WHEN PV_GB = 'IT' THEN GC_X ELSE '' ).
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'CPUDT'. "입력일
        _FCAT TEXT-F38.
        <FS_S_FCT>-NO_OUT = COND  #( WHEN PV_GB = 'IT' THEN GC_X ELSE '' ).
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'USNAM'. "송장생성자
        _FCAT TEXT-F39.
        <FS_S_FCT>-NO_OUT = COND  #( WHEN PV_GB = 'IT' THEN GC_X ELSE '' ).
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'VGART'. "트랜잭션유형
        _FCAT TEXT-F96.
        <FS_S_FCT>-NO_OUT = GC_X.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'MATNR'.        "자재코드
        _FCAT TEXT-F20.
        <FS_S_FCT>-NO_OUT = COND  #( WHEN PV_GB = 'HD' THEN GC_X ELSE '' ).
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'TXZ01'.        "자재명
        _FCAT TEXT-F21.
        <FS_S_FCT>-NO_OUT = COND  #( WHEN PV_GB = 'HD' THEN GC_X ELSE '' ).
        <FS_S_FCT>-JUST = 'C'.
        <FS_S_FCT>-EMPHASIZE = 'C210'.
      WHEN 'BUKRS'.       "회사코드
        _FCAT TEXT-F30.
        <FS_S_FCT>-NO_OUT = COND  #( WHEN PV_GB = 'HD' THEN GC_X ELSE '' ).
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'WERKS'.       "플랜트
        _FCAT TEXT-F02.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'WERKS_N'.  "플랜트명
        _FCAT TEXT-F03.
        <FS_S_FCT>-NO_OUT = COND  #( WHEN PV_GB = 'IT' THEN GC_X ELSE '' ).
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'LIFNR'.   "공급업체
        _FCAT TEXT-F16.
        <FS_S_FCT>-NO_OUT = COND  #( WHEN PV_GB = 'IT' THEN GC_X ELSE '' ).
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'LIFNR_N'.   "업체명
        _FCAT TEXT-F17.
        <FS_S_FCT>-NO_OUT = COND  #( WHEN PV_GB = 'IT' THEN GC_X ELSE '' ).
        <FS_S_FCT>-JUST = 'C'.
        <FS_S_FCT>-EMPHASIZE = 'C410'.
      WHEN 'WRBTR'.        "입고금액(전표통화)
        _FCAT TEXT-F65.
        <FS_S_FCT>-CFIELDNAME = 'WAERS'.
        <FS_S_FCT>-NO_OUT = COND  #( WHEN PV_GB = 'HD' THEN GC_X ELSE '' ).
        <FS_S_FCT>-JUST = 'R'.
        <FS_S_FCT>-EMPHASIZE = 'C300'.
      WHEN 'WAERS'.        "통화
        _FCAT TEXT-F34.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'KURSF'.        "환율
        _FCAT TEXT-F42.
        <FS_S_FCT>-NO_OUT = GC_X.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'SHKZG'.        "차변/대변
        _FCAT TEXT-F50.
        <FS_S_FCT>-NO_OUT = COND  #( WHEN PV_GB = 'HD' THEN GC_X ELSE '' ).
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'MWSKZ'.     "TAX코드
        _FCAT TEXT-F52.
        <FS_S_FCT>-NO_OUT = COND  #( WHEN PV_GB = 'HD' THEN GC_X ELSE '' ).
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'MENGE'.     " 수량
        _FCAT TEXT-F44.
        <FS_S_FCT>-QFIELDNAME = 'BSTME'.
        <FS_S_FCT>-NO_OUT = COND  #( WHEN PV_GB = 'HD' THEN GC_X ELSE '' ).
        <FS_S_FCT>-JUST = 'R'.
        <FS_S_FCT>-EMPHASIZE = 'C400'.
      WHEN 'BSTME'.     "구매오더단위
        _FCAT TEXT-F46.
        <FS_S_FCT>-NO_OUT = COND  #( WHEN PV_GB = 'HD' THEN GC_X ELSE '' ).
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'RMWWR'.        "합계금액
        _FCAT TEXT-F37.
        <FS_S_FCT>-CFIELDNAME = 'WAERS'.
        <FS_S_FCT>-NO_OUT = COND  #( WHEN PV_GB = 'IT' THEN GC_X ELSE '' ).
        <FS_S_FCT>-JUST = 'R'.
        <FS_S_FCT>-EMPHASIZE = 'C700'.
      WHEN 'SPRICE'.        "공급가액
        _FCAT TEXT-F99.
        <FS_S_FCT>-CFIELDNAME = 'WAERS'.
        <FS_S_FCT>-NO_OUT = COND  #( WHEN PV_GB = 'IT' THEN GC_X ELSE '' ).
        <FS_S_FCT>-JUST = 'R'.
        <FS_S_FCT>-EMPHASIZE = 'C300'.
      WHEN 'WMWST1'.  "부가세
        _FCAT TEXT-F83.
        <FS_S_FCT>-CFIELDNAME = 'WAERS'.
        <FS_S_FCT>-NO_OUT = COND  #( WHEN PV_GB = 'IT' THEN GC_X ELSE '' ).
        <FS_S_FCT>-JUST = 'R'.
        <FS_S_FCT>-EMPHASIZE = 'C500'.
      WHEN 'MWSKZ1'.     "TAX코드
        _FCAT TEXT-F52.
        <FS_S_FCT>-NO_OUT = COND  #( WHEN PV_GB = 'IT' THEN GC_X ELSE '' ).
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'SGTXT'.     "세금계산서일련번호
        _FCAT '세금계산서일련번호'.
        <FS_S_FCT>-F4AVAILABL = GC_X.
        <FS_S_FCT>-EDIT = GC_X.
        <FS_S_FCT>-NO_OUT = COND  #( WHEN PV_GB = 'IT' THEN GC_X ELSE '' ).
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'BKTXT'.     "적요
        _FCAT '적요'.
        <FS_S_FCT>-NO_OUT = COND  #( WHEN PV_GB = 'IT' THEN GC_X ELSE '' ).
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'ZFBDT'.     "지급기준일
        _FCAT TEXT-F47.
        <FS_S_FCT>-NO_OUT = COND  #( WHEN PV_GB = 'IT' THEN GC_X ELSE '' ).
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'ZBD1T'.     "지급일수
        _FCAT TEXT-F48.
        <FS_S_FCT>-NO_OUT = COND  #( WHEN PV_GB = 'IT' THEN GC_X ELSE '' ).
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'EXPDATE'.        "만기일
        _FCAT TEXT-F49.
        <FS_S_FCT>-NO_OUT = COND  #( WHEN PV_GB = 'IT' THEN GC_X ELSE '' ).
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'GJAHR_BKPF'.        "회계연도
        _FCAT TEXT-F11.
        <FS_S_FCT>-NO_OUT = GC_X.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'BELNR_BKPF'.        "회계전표번호
        _FCAT '회계전표번호'.
        <FS_S_FCT>-NO_OUT = GC_X.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'ZTERM'.        "지급조건
        _FCAT '지급조건'.
        <FS_S_FCT>-NO_OUT = GC_X.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'ZLSPR'.        "지급보류
        _FCAT '지급보류'.
        <FS_S_FCT>-NO_OUT = GC_X.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'AP_BELNR'.        "지급요청전표번호
        _FCAT '지급요청전표번호'.
        <FS_S_FCT>-NO_OUT = GC_X.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'APPID'.        "지급요청품의ID
        _FCAT '지급요청품의ID'.
        <FS_S_FCT>-NO_OUT = GC_X.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'LEGACYID'.        "SAP DATA의 KEY 정보
        _FCAT 'SAP DATA의 KEY 정보'.
        <FS_S_FCT>-NO_OUT = GC_X.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'AP_STATUS'.        "지급요청승인상태
        _FCAT '지급요청승인상태'.
        <FS_S_FCT>-NO_OUT = GC_X.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'REQPAY'.        "지급요청여부
        _FCAT TEXT-F84.
        <FS_S_FCT>-NO_OUT = COND  #( WHEN PV_GB = 'IT' THEN GC_X ELSE '' ).
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'CL_BUDAT'.        "지급전기일
        _FCAT TEXT-F85.
        <FS_S_FCT>-NO_OUT = COND  #( WHEN PV_GB = 'IT' THEN GC_X ELSE '' ).
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'CL_BLDAT'.        "지급증빙일
        _FCAT '지급증빙일'.
        <FS_S_FCT>-NO_OUT = GC_X .
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'CL_CPUDT'.        "지급전표입력일
        _FCAT TEXT-F86.
        <FS_S_FCT>-NO_OUT = COND  #( WHEN PV_GB = 'IT' THEN GC_X ELSE '' ).
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'CL_AUGDT'.        "반제일
        _FCAT TEXT-F87.
        <FS_S_FCT>-NO_OUT = COND  #( WHEN PV_GB = 'IT' THEN GC_X ELSE '' ).
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'CL_AUGBL'.        "지급전표
        _FCAT TEXT-F88.
        <FS_S_FCT>-NO_OUT = COND  #( WHEN PV_GB = 'IT' THEN GC_X ELSE '' ).
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'CLEARING'.        "지급여부
        _FCAT TEXT-F89.
        <FS_S_FCT>-NO_OUT = COND  #( WHEN PV_GB = 'IT' THEN GC_X ELSE '' ).
        <FS_S_FCT>-JUST = 'C'.
        WHEN 'VBELN'.        "판매오더
        _FCAT TEXT-FA3.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'VBELP'.        "항번
        _FCAT TEXT-FA4.
        <FS_S_FCT>-JUST = 'C'.

      WHEN 'NETPR'.        "항번
        _FCAT TEXT-FA5.
        <FS_S_FCT>-CFIELDNAME = 'PWAERS'.
        <FS_S_FCT>-NO_OUT = COND  #( WHEN PV_GB = 'IT' THEN '' ELSE GC_X  ).
        <FS_S_FCT>-JUST = 'R'.

      WHEN 'PWAERS'.        "항번
        _FCAT TEXT-F34.
        <FS_S_FCT>-NO_OUT = COND  #( WHEN PV_GB = 'IT' THEN '' ELSE GC_X  ).
        <FS_S_FCT>-JUST = 'C'.

      WHEN 'MESSAGE'.   "메시지
        _FCAT TEXT-F68.
        <FS_S_FCT>-JUST = 'C'.
      WHEN OTHERS.
        <FS_S_FCT>-NO_OUT = GC_X.

    ENDCASE.

    IF PV_GB = 'HD'.
      APPEND <FS_S_FCT> TO GT_FCAT_DISP.
    ELSE.
      APPEND <FS_S_FCT> TO GT_FCAT_DIT.
    ENDIF.
  ENDLOOP.

ENDFORM.

*&---------------------------------------------------------------------*
*& FORM ADJUST_FLDCATS_DISP
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
FORM ADJUST_FLDCATS_ITEM  TABLES PT_FCAT TYPE LVC_T_FCAT.

  DEFINE _FCAT.
    <FS_S_FCT>-SCRTEXT_S  =
    <FS_S_FCT>-SCRTEXT_M  =
    <FS_S_FCT>-SCRTEXT_L  =
    <FS_S_FCT>-COLTEXT    =
    <FS_S_FCT>-REPTEXT    = &1.
  END-OF-DEFINITION.

  DATA LV_COL TYPE I.
  CLEAR : GT_FCAT_IT[].

  LOOP AT PT_FCAT ASSIGNING FIELD-SYMBOL(<FS_S_FCT>).
    CLEAR : <FS_S_FCT>-COL_POS.

    CASE <FS_S_FCT>-FIELDNAME.
      WHEN 'CHECK'. "선택
        _FCAT TEXT-F35.
        <FS_S_FCT>-EDIT = GC_X.
        <FS_S_FCT>-CHECKBOX = GC_X.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'BUKRS'.   "회사코드
        _FCAT TEXT-F30.
        <FS_S_FCT>-NO_OUT = GC_X.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'EKORG'.   "구매조직
        _FCAT TEXT-F10.
        <FS_S_FCT>-NO_OUT = GC_X.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'WERKS'.       "플랜트
        _FCAT TEXT-F02.
        <FS_S_FCT>-NO_OUT = GC_X.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'LIFNR'.   "공급업체
        _FCAT TEXT-F16.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'NAME1'.   "업체명
        _FCAT TEXT-F17.
        <FS_S_FCT>-JUST = 'C'.
        <FS_S_FCT>-EMPHASIZE = 'C410'.
      WHEN 'EKGRP'.      "구매그룹
        _FCAT TEXT-F08.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'EKNAM'.     "구매그룹명
        _FCAT TEXT-F09.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'EBELN'.     "구매오더
        _FCAT TEXT-F22.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'EBELP'.    "항번
        _FCAT TEXT-F13.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'XRECH'.     "반품정산대상
        _FCAT TEXT-FA0.
        <FS_S_FCT>-NO_OUT = GC_X.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'MJAHR'.    "입고연도
        _FCAT TEXT-F56.
        <FS_S_FCT>-NO_OUT = GC_X.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'SPMON	'.    "입고연월
        _FCAT TEXT-F24.
        <FS_S_FCT>-NO_OUT = GC_X.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'BUDAT'.        "전기일
        _FCAT TEXT-F12.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'MBLNR'.        "자재문서
        _FCAT TEXT-F23.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'ZEILE'.     "항번
        _FCAT TEXT-F13.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'MATNR'.        "자재코드
        _FCAT TEXT-F20.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'TXZ01'.        "자재명
        _FCAT TEXT-F21.
        <FS_S_FCT>-JUST = 'C'.
        <FS_S_FCT>-EMPHASIZE = 'C210'.
      WHEN 'COLOR	'.    "색상
        _FCAT TEXT-F57.
        <FS_S_FCT>-NO_OUT = GC_X.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'LENGTH'.    "조장
        _FCAT TEXT-F59.
        <FS_S_FCT>-NO_OUT = GC_X.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'LENUNIT'.    "단위
        _FCAT TEXT-F54.
        <FS_S_FCT>-NO_OUT = GC_X.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'PSTYP'.    "품목범주
        _FCAT TEXT-F60.
        <FS_S_FCT>-NO_OUT = GC_X.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'MENGE'.        "입고수량
        _FCAT TEXT-F27.
        <FS_S_FCT>-QFIELDNAME = 'MEINS'.
        <FS_S_FCT>-JUST = 'R'.
        <FS_S_FCT>-EMPHASIZE = 'C300'.
      WHEN 'MEINS'.        "입고단위
        _FCAT TEXT-F28.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'MENGE_IV'.        "정산완료수량
        _FCAT TEXT-F25.
        <FS_S_FCT>-QFIELDNAME = 'MEINS'.
        <FS_S_FCT>-JUST = 'R'.
        <FS_S_FCT>-EMPHASIZE = 'C300'.
      WHEN 'BSTME_IV'.        "정산단위
        _FCAT TEXT-F26.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'IV_QTY'.        "정산대상수량
        _FCAT TEXT-F36.
        <FS_S_FCT>-EDIT = GC_X.
        <FS_S_FCT>-QFIELDNAME = 'IV_UNIT'.
        <FS_S_FCT>-JUST = 'R'.
      WHEN 'BPUMN'.        "정산단위
        _FCAT TEXT-F98.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'IV_OQTY'.        "정산단위 대상 수량
        _FCAT TEXT-F97.
        <FS_S_FCT>-QFIELDNAME = 'IV_UNIT'.
        <FS_S_FCT>-JUST = 'R'.
        <FS_S_FCT>-EMPHASIZE = 'C700'.

      WHEN 'IV_UNIT'.        "정산단위
        _FCAT TEXT-F26.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'NETPR'.        "구매오더단가
        _FCAT TEXT-F31.
        <FS_S_FCT>-CFIELDNAME = 'WAERS'.
        <FS_S_FCT>-JUST = 'R'.
        <FS_S_FCT>-EMPHASIZE = 'C300'.
      WHEN 'PEINH'.        "PER
        _FCAT TEXT-F32.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'ETIV_PRICE'.        "정산유효단가
        _FCAT TEXT-F41.
        <FS_S_FCT>-EDIT = GC_X.
        <FS_S_FCT>-CFIELDNAME = 'WAERS'.
        <FS_S_FCT>-JUST = 'R'.
      WHEN 'ETIV_PEINH'.        "PER
        _FCAT TEXT-F32.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'ETIV_MEINS'.        "단가단위
        _FCAT TEXT-F40.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'MWSKZ'.        "TAX코드
        _FCAT TEXT-F52.
        <FS_S_FCT>-EDIT = GC_X.
        <FS_S_FCT>-F4AVAILABL = GC_X.
*        <FS_S_FCT>-REF_TABLE = 'T007A'.
*        <FS_S_FCT>-REF_FIELD  = 'MWSKZ'.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'RATE'.        "세율
        _FCAT TEXT-F43.
        <FS_S_FCT>-JUST = 'R'.
      WHEN 'TARGET_PRICE'.     "정산대상금액
        _FCAT TEXT-F45.
        <FS_S_FCT>-EDIT = GC_X.
        <FS_S_FCT>-CFIELDNAME = 'WAERS'.
        <FS_S_FCT>-JUST = 'R'.
      WHEN 'TAXPRICE'.       "정산대상TAX
        _FCAT TEXT-F53.
        <FS_S_FCT>-EDIT = GC_X.
        <FS_S_FCT>-CFIELDNAME = 'WAERS'.
        <FS_S_FCT>-JUST = 'R'.
      WHEN 'WAERS'.        "전표통화
        _FCAT TEXT-F63.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'HSWAE'.       "현지통화
        _FCAT TEXT-F64.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'DMBTR'.        "입고금액(현지통화)
        _FCAT TEXT-F66.
        <FS_S_FCT>-CFIELDNAME = 'WAERS'.
        <FS_S_FCT>-JUST = 'R'.
        <FS_S_FCT>-EMPHASIZE = 'C300'.
      WHEN 'WRBTR'.        "입고금액(전표통화)
        _FCAT TEXT-F65.
        <FS_S_FCT>-CFIELDNAME = 'WAERS'.
        <FS_S_FCT>-JUST = 'R'.
        <FS_S_FCT>-EMPHASIZE = 'C300'.
      WHEN 'WRBTR_IV'.        "송장처리완료금액
        _FCAT TEXT-F67.
        <FS_S_FCT>-CFIELDNAME = 'WAERS'.
        <FS_S_FCT>-JUST = 'R'.
        <FS_S_FCT>-EMPHASIZE = 'C700'.
      WHEN 'WAERS_IV'.        "송장처리완료통화
        _FCAT TEXT-F71.
        <FS_S_FCT>-CFIELDNAME = 'WAERS'.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'MEPRF'.   "가격결정일제어
        _FCAT TEXT-F70.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'CPUDT	'.   "입고입력일
        _FCAT TEXT-F90.
        <FS_S_FCT>-NO_OUT = GC_X.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'CPUTM	'.   "입고입력시간
        _FCAT TEXT-F91.
        <FS_S_FCT>-NO_OUT = GC_X.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'EINDT'.   "납품요청일
        _FCAT TEXT-F76.
        <FS_S_FCT>-NO_OUT = GC_X.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'WEBRE'.   "GR기준IV
        _FCAT TEXT-F92.
        <FS_S_FCT>-NO_OUT = GC_X.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'PRDAT'.   "가격결정일
        _FCAT TEXT-F93.
        <FS_S_FCT>-NO_OUT = GC_X.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'BEDAT'.   "구매오더증빙일
        _FCAT TEXT-F94.
        <FS_S_FCT>-NO_OUT = GC_X.
        <FS_S_FCT>-JUST = 'C'.
        WHEN 'VBELN'.        "판매오더
        _FCAT TEXT-FA3.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'VBELP'.        "항번
        _FCAT TEXT-FA4.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'MESSAGE'.   "메시지
        _FCAT TEXT-F69.
        <FS_S_FCT>-JUST = 'C'.
      WHEN OTHERS.
        <FS_S_FCT>-NO_OUT = GC_X.

    ENDCASE.

    APPEND <FS_S_FCT> TO GT_FCAT_IT.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& FORM ADJUST_FLDCATS_TAX
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
FORM ADJUST_FLDCATS_TAX  TABLES PT_FCAT TYPE LVC_T_FCAT .

  DEFINE _FCAT.
    <FS_S_FCT>-SCRTEXT_S  =
    <FS_S_FCT>-SCRTEXT_M  =
    <FS_S_FCT>-SCRTEXT_L  =
    <FS_S_FCT>-COLTEXT    =
    <FS_S_FCT>-REPTEXT    = &1.
  END-OF-DEFINITION.

  DATA LV_COL TYPE I.
  CLEAR : GT_FCAT_TAX[].

  LOOP AT PT_FCAT ASSIGNING FIELD-SYMBOL(<FS_S_FCT>).
    CLEAR : <FS_S_FCT>-COL_POS.

    CASE <FS_S_FCT>-FIELDNAME.
      WHEN 'CHECK'.
        _FCAT TEXT-F35. "선택
        <FS_S_FCT>-EDIT = GC_X.
        <FS_S_FCT>-CHECKBOX = GC_X.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'ISSUE_DATE'. "
        _FCAT '작성일자'.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'ISSUE_DT'.
        _FCAT '발행일자'.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'SU_ID'.  "
        _FCAT '사업자번호'.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'LIFNR'.
        _FCAT '업체코드'.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'NAME1'. "업체명
        _FCAT TEXT-F17.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'INV_SEQ'.
        _FCAT '일련번호'.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'CHARGETOTAL'.  "
        _FCAT '공급가액'.
        <FS_S_FCT>-CFIELDNAME = 'WAERS'.
        <FS_S_FCT>-JUST = 'R'.
        <FS_S_FCT>-EMPHASIZE = 'C300'.
      WHEN 'TAXTOTAL'.
        _FCAT '세액'.
        <FS_S_FCT>-CFIELDNAME = 'WAERS'.
        <FS_S_FCT>-JUST = 'R'.
        <FS_S_FCT>-EMPHASIZE = 'C500'.
      WHEN 'GRANDTOTAL'.  "
        _FCAT '합계금액'.
        <FS_S_FCT>-CFIELDNAME = 'WAERS'.
        <FS_S_FCT>-JUST = 'R'.
        <FS_S_FCT>-EMPHASIZE = 'C700'.
      WHEN 'WAERS'.  "통화
        _FCAT TEXT-F34.
        <FS_S_FCT>-JUST = 'C'.
      WHEN OTHERS.
        <FS_S_FCT>-NO_OUT = GC_X.
    ENDCASE.

    APPEND <FS_S_FCT> TO GT_FCAT_TAX.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& FORM SET_ALV_LAYOUT
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
FORM SET_ALV_LAYOUT USING PV_GB
                                                 PCL_GRID  TYPE REF TO CL_GUI_ALV_GRID.

  DATA LV_STT TYPE LVC_TITLE.

  CASE PCL_GRID.
    WHEN GCL_GRID_HD.                                    "송장처리대상금액  /  헤더DATA
      LV_STT = COND #( WHEN PV_GB = 'INV' THEN TEXT-T07 ELSE TEXT-T05 ).

      CLEAR GS_LAYOUT.
      GS_LAYOUT = VALUE #(
                      NO_ROWMARK = GC_X
*                       NO_ROWINS  = GC_X
                      ZEBRA  = GC_X
                      SEL_MODE   = GC_D"GC_A
                      CWIDTH_OPT  = GC_A
                      SMALLTITLE = GC_X
                      GRID_TITLE  = LV_STT
                      STYLEFNAME =  'STYLE'
                      CTAB_FNAME = 'F_COL'
                      ).

    WHEN GCL_GRID_IT.                                          " 입고 내역  /품목 DATA
      LV_STT = COND #( WHEN PV_GB = 'INV' THEN TEXT-T08 ELSE TEXT-T06 ).

      CLEAR GS_LAYOIT.
      GS_LAYOIT = VALUE #(
*                      NO_ROWMARK = GC_X
*                       NO_ROWINS  = ZGTFI_X
                      ZEBRA  = GC_X
                      SEL_MODE   = GC_D "GC_A
                      CWIDTH_OPT  = GC_A"GC_A
                      SMALLTITLE = GC_X
                      GRID_TITLE  = LV_STT
                      STYLEFNAME =  'STYLE'
                      CTAB_FNAME = 'F_COL'
                      ).

    WHEN GCL_GRID_TAX.
      CLEAR GS_LAYOUT.
      GS_LAYOUT = VALUE #(
                      NO_ROWMARK = GC_X
                      NO_ROWINS  = GC_X
                      ZEBRA  = GC_X
                      SEL_MODE   = GC_A
                      CWIDTH_OPT  = GC_A
                      CTAB_FNAME = 'F_COL'
*                      STYLEFNAME =  'STYLE'
                      ).

    WHEN OTHERS.
  ENDCASE.

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

  CASE PCL_GRID.
    WHEN GCL_GRID_HD.
      PERFORM SET_CELL_STYLE USING 'HD'.
    WHEN GCL_GRID_IT.
      PERFORM SET_CELL_STYLE USING 'IT'.
    WHEN OTHERS.
  ENDCASE.

*  DATA: LT_F4 TYPE LVC_T_F4,
*            LS_F4 TYPE LVC_S_F4.
*
*  IF PCL_GRID NE GCL_GRID_TAX.
*    LS_F4-FIELDNAME  = 'MWSKZ'. " 세금코드
*    LS_F4-REGISTER     = 'X'.
*    LS_F4-GETBEFORE  = 'X'.
*    LS_F4-CHNGEAFTER = 'X'.
*    APPEND LS_F4 TO LT_F4.
*
*    IF P_DIS = GC_X.
*      LS_F4-FIELDNAME  = 'SGTXT'. " 세금계산서일련번호
*      LS_F4-REGISTER     = 'X'.
*      LS_F4-GETBEFORE  = 'X'.
*      LS_F4-CHNGEAFTER = 'X'.
*      APPEND LS_F4 TO LT_F4.
*    ENDIF.
*  ENDIF.
*
*  CALL METHOD PCL_GRID->REGISTER_F4_FOR_FIELDS
*    EXPORTING
*      IT_F4 = LT_F4.

  CREATE OBJECT PO_EVENT.

  IF PCL_GRID = GCL_GRID_TAX.
    SET HANDLER PO_EVENT->HANDLE_DATA_CHANGED FOR PCL_GRID.
  ELSE.
    SET HANDLER :
     PO_EVENT->HANDLE_DATA_CHANGED                 FOR PCL_GRID,
     PO_EVENT->HANDLE_DATA_CHANGED_FINISHED  FOR PCL_GRID,
     PO_EVENT->HANDLE_HOTSPOT_CLICK                FOR PCL_GRID,
     PO_EVENT->HANDLE_TOOLBAR                           FOR PCL_GRID,
     PO_EVENT->HANDLE_USER_COMMAND               FOR PCL_GRID,
     PO_EVENT->HANDLE_ON_F4                               FOR PCL_GRID.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*& FORM DISPLAY_ALV
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
FORM DISPLAY_ALV TABLES PT_LIST PT_FCAT
                                  USING PCL_GRID TYPE REF TO CL_GUI_ALV_GRID
                                            PS_LAYOUT TYPE LVC_S_LAYO.

  DATA(LS_VARIANT) = VALUE DISVARIANT( REPORT  = SY-CPROG
                                             HANDLE  =
                                             COND #( WHEN P_INV = GC_X AND PCL_GRID = GCL_GRID_HD
                                                            THEN '0001'
                                                            WHEN P_INV = GC_X AND PCL_GRID = GCL_GRID_IT
                                                            THEN '0002'
                                                            WHEN P_DIS = GC_X AND PCL_GRID = GCL_GRID_HD
                                                            THEN '0003'
                                                            WHEN P_DIS = GC_X AND PCL_GRID = GCL_GRID_IT
                                                            THEN '0004' ) ).
*  GS_VARIANT-REPORT = SY-REPID.

" 4. F4 대상 필드 등록
DATA: LT_F4 TYPE LVC_T_F4,
          LS_F4 TYPE LVC_S_F4.

  LS_F4-FIELDNAME = 'MWSKZ'.
  LS_F4-REGISTER   = 'X'.
  APPEND LS_F4 TO LT_F4.

  LS_F4-FIELDNAME = 'SGTXT'.
  LS_F4-REGISTER   = 'X'.
  APPEND LS_F4 TO LT_F4.

  CALL METHOD PCL_GRID->REGISTER_F4_FOR_FIELDS
    EXPORTING
      IT_F4 = LT_F4.

  CALL METHOD PCL_GRID->SET_TABLE_FOR_FIRST_DISPLAY
    EXPORTING
      IS_LAYOUT            = PS_LAYOUT
      IT_TOOLBAR_EXCLUDING = GT_EXCLUD[]
      IS_VARIANT           = LS_VARIANT
      I_SAVE                  = ZGTFI_A
    CHANGING
      IT_OUTTAB            = PT_LIST[] "GT_LIST[]
      IT_FIELDCATALOG  = PT_FCAT[]
      IT_SORT                 = GT_SORT[]
    EXCEPTIONS
      OTHERS               = 4.

  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
          WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& FORM DISPLAY_ALV_400
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
FORM DISPLAY_ALV_400 .

  DATA(LS_VARINT) = VALUE DISVARIANT( REPORT  = SY-CPROG
                                           HANDLE  = '0005' ).

  CALL METHOD GCL_GRID_TAX->SET_TABLE_FOR_FIRST_DISPLAY
    EXPORTING
      IS_LAYOUT            = GS_LAYOUT
      IT_TOOLBAR_EXCLUDING = GT_EXCLUD[]
     IS_VARIANT           = LS_VARINT
      I_SAVE               = ZGTFI_A
    CHANGING
      IT_OUTTAB            = GT_TAX[]
      IT_FIELDCATALOG  = GT_FCAT_TAX[]
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

  IF GCL_GRID_HD IS BOUND.
    GCL_GRID_HD->FREE( ).
    GCL_GRID_IT->FREE( ).
    CLEAR : GCL_GRID_HD, GCL_GRID_IT.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*& FORM INITIALIZATION
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
FORM INITIALIZATION .
DATA: lt_values TYPE TABLE OF USVALUES,
      ls_values TYPE USVALUES.

  CLEAR : S_MONTH[]. "생성일
  S_MONTH[] = VALUE #( ( SIGN   = GC_I
                                        OPTION = GC_BT
                                        LOW    = SY-DATLO(6) - 2
                                        HIGH   = SY-DATLO(6) ) ).

  S_USNAM[] = VALUE #( ( SIGN = GC_I
                                       OPTION = GC_EQ
                                       LOW = SY-UNAME
                                       HIGH = '' ) ).


    CALL FUNCTION 'SUSR_USER_AUTH_FOR_OBJ_GET'
      EXPORTING
        MANDANT = SY-MANDT
        SEL_OBJECT     = 'ZCBO_MM001' " 조회할 권한 오브젝트명
        user_name         = sy-uname
      TABLES
        values          = lt_values
      EXCEPTIONS
        user_name_invalid = 1
        object_not_found  = 2
        internal_error    = 3
        OTHERS            = 4.

      DELETE  LT_VALUES WHERE VON = '*'.

    IF LT_VALUES[] IS NOT INITIAL.

      READ TABLE LT_VALUES INTO LS_VALUES WITH KEY FIELD = 'BUKRS'.
      IF SY-SUBRC EQ 0. P_BUKRS = LS_VALUES-VON. ENDIF.

      READ TABLE LT_VALUES INTO LS_VALUES WITH KEY FIELD = 'EKORG'.
      IF SY-SUBRC EQ 0. P_EKORG = LS_VALUES-VON. ENDIF.

      READ TABLE LT_VALUES INTO LS_VALUES WITH KEY FIELD = 'WERKS'.
      IF SY-SUBRC EQ 0. P_WERKS = LS_VALUES-VON.   ENDIF.

    ENDIF.


ENDFORM.

*&---------------------------------------------------------------------*
*& FORM INPUT_VALIDATION
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
FORM INPUT_VALIDATION.

  CLEAR : GT_LIST, GV_ERR.

*  IF P_CRE NE GC_X AND S_ERDAT[] IS INITIAL AND S_EINDT[] IS INITIAL.
*    MESSAGE S000 WITH TEXT-M13 DISPLAY LIKE GC_E.
*    GV_ERR = GC_X. STOP. "생성일과 납품예정일 중 최소 하나는 입력 해야 합니다.
*  ENDIF.

*  IF P_PR = GC_X AND P_VOL IS INITIAL AND P_PRD IS INITIAL.
*    MESSAGE S000 WITH TEXT-M16 DISPLAY LIKE GC_E.
*    GV_ERR = GC_X. STOP.
*    "청구량 정보 조회와 구매요청 정보 조회 중 최소 하나는 체크해야 합니다.
*  ENDIF.

  IF  P_WERKS IS NOT INITIAL.
*    LOOP AT S_WERKS INTO DATA(LS_WERKS).

    SELECT SINGLE 1
     FROM T001W
     WHERE WERKS EQ @P_WERKS
      INTO @DATA(LV_EXST).

    IF SY-SUBRC <> 0.
      MESSAGE S000 WITH TEXT-M01 DISPLAY LIKE GC_E.
      GV_ERR = GC_X. STOP. "유효하지 않은 플랜트 입니다.
    ENDIF.

*    ENDLOOP.
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

*  IF S_VBELN[] IS NOT INITIAL.
*    LOOP AT S_VBELN INTO DATA(LS_VBELN).
*
*      SELECT SINGLE 1
*      FROM VBAK
*      WHERE VBELN EQ @LS_VBELN-LOW
*      INTO @LV_EXST.
*
*      IF SY-SUBRC <> 0.
*        MESSAGE S000 WITH TEXT-M11 DISPLAY LIKE GC_E.
*        GV_ERR = GC_X. STOP. "유효하지 않은 판매오더 입니다.
*      ENDIF.
*    ENDLOOP.
*  ENDIF.

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
        MESSAGE E172 WITH P_BUKRS. "회사코드 [&] 작업권한을 확인하세요.

        AUTHORITY-CHECK OBJECT 'ZCBO_MM001'
                     ID 'EKORG' FIELD P_EKORG.

        CHECK SY-SUBRC <> 0.

        SET CURSOR FIELD 'P_EKORG'.
        MESSAGE E170 WITH P_EKORG. "구매조직 [&] 작업권한을 확인하세요.

        AUTHORITY-CHECK OBJECT 'ZCBO_MM001'
                     ID 'WERKS' FIELD P_WERKS.

        CHECK SY-SUBRC <> 0.

        SET CURSOR FIELD 'P_WERKS'.
        MESSAGE E106 WITH P_WERKS. "플랜트 [&] 작업권한을 확인하세요.


ENDFORM.
*&---------------------------------------------------------------------*
*& FORM SELECTION_SCREEN_OUTPUT
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
FORM SELECTION_SCREEN_OUTPUT .

  LOOP AT SCREEN.

    IF SCREEN-NAME = '%B004017_BLOCK_1000'." 입고내역조회옵션 프레임(블럭)제어
      SCREEN-ACTIVE = COND #( WHEN P_DIS = GC_X THEN 0 ELSE 1 ).
    ENDIF.

    IF SCREEN-GROUP1 = 'DIS'.
      SCREEN-ACTIVE = COND #( WHEN P_DIS = GC_X THEN 0 ELSE 1 ).
    ENDIF.

    IF SCREEN-GROUP1 = 'EXD'.
      SCREEN-ACTIVE = COND #( WHEN P_DIS = GC_X THEN 1 ELSE 0 ).
    ENDIF.

    MODIFY SCREEN.
  ENDLOOP.

ENDFORM.

*&---------------------------------------------------------------------*
*& FORM GET_DATA
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
FORM  GET_DATA .

  CLEAR : GV_LIFNR, GV_WAERS, GV_TWAERS, GV_XWAERS, GV_EXRATE,
               GV_TARGET_PRICE, GV_TAXPRICE, GV_WRBTR, GV_ERR.

  CLEAR : GT_LIST, GT_ITEM, GT_ITEM_BASE,
               GT_DISP, GT_DISP_IT, GT_DISP_BASE.

  CASE GC_X.
*송장처리
    WHEN P_INV.
      IF P_LIF = GC_X.   "업체 별 조회
        SELECT FROM ZGTMM_CV_GET_TARGET_IV_H2
        FIELDS *
        WHERE BUKRS = @P_BUKRS
             AND EKORG = @P_EKORG
             AND WERKS = @P_WERKS
             AND LIFNR IN @S_LIFNR
             AND SPMON IN @S_MONTH
        INTO CORRESPONDING FIELDS OF TABLE @GT_LIST.
        SORT GT_LIST BY BUKRS EKORG LIFNR SPMON WERKS ASCENDING.

        IF GT_LIST[] IS INITIAL.
          GV_ERR = GC_X."조회 조건에 일치하는 정보가 없습니다.
          MESSAGE S000 WITH TEXT-E01. EXIT.
        ELSE.
          SELECT FROM ZGTMM_CV_GET_TARGET_IV
          FIELDS *
          FOR ALL ENTRIES IN @GT_LIST
          WHERE LIFNR = @GT_LIST-LIFNR
             AND BUKRS = @GT_LIST-BUKRS
             AND EKORG = @GT_LIST-EKORG
             AND WERKS = @GT_LIST-WERKS
             AND SPMON = @GT_LIST-SPMON
             AND IV_COMPLETE IS INITIAL
          INTO CORRESPONDING FIELDS OF TABLE @GT_ITEM_BASE.
          SORT GT_ITEM_BASE BY LIFNR BUKRS EKORG WERKS SPMON XRECH.

        ENDIF.

      ELSEIF P_EKG = GC_X. "구매그룹 별 조회
        SELECT FROM ZGTMM_CV_GET_TARGET_IV_H
        FIELDS *
        WHERE BUKRS = @P_BUKRS
             AND EKORG = @P_EKORG
             AND WERKS = @P_WERKS
             AND LIFNR IN @S_LIFNR
             AND EKGRP IN @S_EKGRP
             AND SPMON IN @S_MONTH
        INTO CORRESPONDING FIELDS OF TABLE @GT_LIST.
        SORT GT_LIST BY BUKRS EKORG EKGRP LIFNR SPMON WERKS ASCENDING.

        IF GT_LIST[] IS INITIAL.
          GV_ERR = GC_X."조회 조건에 일치하는 정보가 없습니다.
          MESSAGE S000 WITH TEXT-E01. EXIT.
        ELSE.
          SELECT FROM ZGTMM_CV_GET_TARGET_IV
          FIELDS *
          FOR ALL ENTRIES IN @GT_LIST
          WHERE LIFNR = @GT_LIST-LIFNR
             AND BUKRS = @GT_LIST-BUKRS
             AND EKORG = @GT_LIST-EKORG
             AND WERKS = @GT_LIST-WERKS
             AND EKGRP = @GT_LIST-EKGRP
             AND SPMON = @GT_LIST-SPMON
          INTO CORRESPONDING FIELDS OF TABLE @GT_ITEM_BASE.
          SORT GT_ITEM_BASE BY LIFNR BUKRS EKORG WERKS EKGRP SPMON XRECH.
        ENDIF.
      ENDIF.

*처리 결과 조회 및 지급 요청
    WHEN P_DIS.
      IF P_EXD = GC_X. "지급요청 건 제외
        SELECT FROM ZGTMM_CV_GET_AP_CLEARING
        FIELDS *
        WHERE BUKRS = @P_BUKRS
           AND WERKS = @P_WERKS
           AND LIFNR IN @S_LIFNR
           AND USNAM IN @S_USNAM
           AND SPMON IN @S_MONTH
           AND REQPAY IS INITIAL
        INTO CORRESPONDING FIELDS OF TABLE @GT_DISP.

      ELSE.
        SELECT FROM ZGTMM_CV_GET_AP_CLEARING
        FIELDS *
        WHERE BUKRS = @P_BUKRS
           AND WERKS = @P_WERKS
           AND LIFNR IN @S_LIFNR
           AND USNAM IN @S_USNAM
           AND SPMON IN @S_MONTH
        INTO CORRESPONDING FIELDS OF TABLE @GT_DISP.
      ENDIF.

      SORT GT_DISP BY BUKRS WERKS LIFNR ASCENDING.

      IF GT_DISP[] IS INITIAL.
        GV_ERR = GC_X."조회 조건에 일치하는 정보가 없습니다.
        MESSAGE S000 WITH TEXT-E01. EXIT.
      ELSE.
         LOOP AT GT_DISP ASSIGNING FIELD-SYMBOL(<FS>).
           IF <FS>-AP_STATUS = GC_T or <FS>-AP_STATUS = GC_P.
                <FS>-REQ   = ICON_MAIL.
           ELSEif <FS>-AP_STATUS = GC_C.
                <FS>-REQ   = ICON_LED_GREEN.
           ELSE.
              CLEAR  <FS>-REQ.
           ENDIF.
         ENDLOOP.


        SELECT FROM ZGTMM_CV_GET_AP_RSEG
        FIELDS *
        FOR ALL ENTRIES IN @GT_DISP
        WHERE BUKRS = @GT_DISP-BUKRS
           AND GJAHR = @GT_DISP-GJAHR
           AND BELNR = @GT_DISP-BELNR
        INTO CORRESPONDING FIELDS OF TABLE @GT_DISP_BASE.
        SORT GT_DISP_BASE BY BUKRS GJAHR BELNR.
      ENDIF.

    WHEN OTHERS.
  ENDCASE.



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

  CHECK PV_MODIFIED IS NOT INITIAL.
*  CHECK P_LIF = GC_X. "업체 별 조회 인 경우에만.
  CHECK GT_ITEM[] IS NOT INITIAL.

  DATA(LT_LIST) = GT_LIST[].

  SORT LT_LIST BY CHECK LIFNR BUKRS EKORG WERKS SPMON.
  CLEAR : GV_TARGET_PRICE, GV_TAXPRICE, GV_WRBTR, GV_XRECH.

  IF  LINE_EXISTS( GT_ITEM[ CHECK = GC_X ] ).
*총 공급가액,세액,합계금액 변경 반영_상단 스크린 필드.
    LOOP AT GT_ITEM ASSIGNING FIELD-SYMBOL(<FSI>).

      READ TABLE LT_LIST TRANSPORTING NO FIELDS
      WITH KEY CHECK = GC_X
                   LIFNR = <FSI>-LIFNR
                   BUKRS = <FSI>-BUKRS
                   EKORG = <FSI>-EKORG
                   WERKS = <FSI>-WERKS
                   SPMON = <FSI>-SPMON
                   XRECH = <FSI>-XRECH BINARY SEARCH.

      IF SY-SUBRC = 0 AND <FSI>-CHECK = GC_X.
        GV_TARGET_PRICE = GV_TARGET_PRICE + <FSI>-TARGET_PRICE.
        GV_TAXPRICE = GV_TAXPRICE + <FSI>-TAXPRICE.
      ENDIF.

    ENDLOOP.
*총 합계금액 = 총 공급가액 + 총 세액
    GV_WRBTR = GV_TARGET_PRICE + GV_TAXPRICE.

    READ TABLE LT_LIST INTO DATA(LS2) WITH KEY CHECK = GC_X BINARY SEARCH.
    GV_XRECH = COND #( WHEN LS2 IS INITIAL THEN '' ELSE LS2-XRECH ).

  ELSE.
*ITEM 체크된 데이터 없으면 스크린 상단 필드 업데이트 위해 HEADER 추가 체크
    READ TABLE LT_LIST INTO DATA(LS) WITH KEY CHECK = GC_X BINARY SEARCH.

    IF SY-SUBRC = 0.
      GV_LIFNR     = LS-LIFNR.
      GV_EXRATE = LS-EXRATE.
    ELSE.
      CLEAR : GV_LIFNR, GV_LIFNR_N, GV_EXRATE,
                   GV_WAERS, GV_TWAERS, GV_XWAERS, GV_XRECH.
    ENDIF.

  ENDIF.

*합계필드 화면 표시용 처리.(단위참조)
  WRITE GV_WRBTR TO GV_WRBTR_DISP CURRENCY GV_WAERS LEFT-JUSTIFIED.
  WRITE GV_TARGET_PRICE TO GV_TPRICE_DISP CURRENCY GV_WAERS LEFT-JUSTIFIED.
  WRITE GV_TAXPRICE TO GV_XPRICE_DISP CURRENCY GV_WAERS LEFT-JUSTIFIED.

  PERFORM REFRESH_TABLE USING GCL_GRID_HD SPACE.
  PERFORM REFRESH_TABLE USING GCL_GRID_IT SPACE.

*상단 스크린 필드 업데이트_강제 PBO 실행
  CALL METHOD CL_GUI_CFW=>SET_NEW_OK_CODE
    EXPORTING
      NEW_CODE = 'ENTER'.

ENDFORM.

*&---------------------------------------------------------------------*
*& FORM SET_CELL_STYLE
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
FORM SET_CELL_STYLE USING PV_GB.

  DATA : LS_STYLE TYPE LVC_S_STYL.

  DEFINE _SET_STYLE.

    LS_STYLE-FIELDNAME = &2.
    CASE &1.
      WHEN 'E'.
        LS_STYLE-STYLE = CL_GUI_ALV_GRID=>MC_STYLE_ENABLED.
      WHEN 'D'.
        LS_STYLE-STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED.
    ENDCASE.
    INSERT LS_STYLE INTO TABLE &3.

  END-OF-DEFINITION.


  GCL_GRID_HD->SET_READY_FOR_INPUT( 1 ). "입력가능
  GCL_GRID_IT->SET_READY_FOR_INPUT( 1 ). "입력가능

  CASE PV_GB.
    WHEN 'HD'.
*HEADER
      IF P_INV = GC_X.
        LOOP AT GT_LIST ASSIGNING FIELD-SYMBOL(<LS_LIST>).
          CLEAR : <LS_LIST>-STYLE[].

          _SET_STYLE : GC_E 'CHECK' <LS_LIST>-STYLE. "ENABLED

          IF <LS_LIST>-ETIV_WAERS = GC_KRW.
            _SET_STYLE GC_D 'EXRATE' <LS_LIST>-STYLE."DISABLED
          ELSE.
            _SET_STYLE GC_E 'EXRATE' <LS_LIST>-STYLE."ENABLED
          ENDIF.

        ENDLOOP.
      ENDIF.

      IF P_DIS = GC_X.
        LOOP AT GT_DISP ASSIGNING FIELD-SYMBOL(<LS_DISP>).
          CLEAR : <LS_DISP>-STYLE[].

          _SET_STYLE : GC_E 'CHECK' <LS_DISP>-STYLE. "ENABLED
**세금계산서일련번호
          IF <LS_DISP>-SGTXT IS INITIAL.
            _SET_STYLE GC_E 'SGTXT' <LS_DISP>-STYLE."ENABLED
          ELSE.
            _SET_STYLE GC_D 'SGTXT' <LS_DISP>-STYLE."DISABLED
          ENDIF.
        ENDLOOP.
      ENDIF.


    WHEN 'IT'.
**ITEM
      LOOP AT GT_ITEM ASSIGNING FIELD-SYMBOL(<FS>).
        CLEAR : <FS>-STYLE[].

        _SET_STYLE : GC_E 'CHECK' <FS>-STYLE, "ENABLED
                              GC_E 'ETIV_PRICE' <FS>-STYLE, "ENABLED
                              GC_E 'TARGET_PRICE' <FS>-STYLE,
                              GC_E 'IV_QTY' <FS>-STYLE,
                              GC_E 'MWSKZ' <FS>-STYLE.
      ENDLOOP.

    WHEN OTHERS.
  ENDCASE.

ENDFORM.

**&---------------------------------------------------------------------*
**& FORM SET_CELL_COLOR
**&---------------------------------------------------------------------*
**& TEXT
**&---------------------------------------------------------------------*
*FORM SET_CELL_COLOR .
*
*  DATA : LS_COLOR TYPE    LVC_S_SCOL.
*
**  DEFINE _SET_COLOR.
**
**    LS_COLOR-FNAME = &1.
**    LS_COLOR-COLOR-COL = &2.
**    LS_COLOR-COLOR-INT  = &3
**    INSERT LS_STYLE INTO TABLE &4.
**
**  END-OF-DEFINITION.
*
*  LOOP AT GT_LIST ASSIGNING FIELD-SYMBOL(<LS_LIST>).
*
*    CLEAR : <LS_LIST>-COLO[].
*
**입고상태
*    LS_COLOR-FNAME = GC_ZGRSTATUS.
*    LS_COLOR-COLOR-COL = COND #( WHEN <LS_LIST>-ZGRSTATUS_C = GC_C
*                                                           THEN '6'
*                                                           WHEN <LS_LIST>-ZGRSTATUS_C = GC_D
*                                                           THEN '7' ELSE '0' ).
*    LS_COLOR-COLOR-INT   = '1'.
*    INSERT LS_COLOR INTO TABLE <LS_LIST>-COLO.
*
**정산상태
*    CLEAR LS_COLOR.
*
*    CASE <LS_LIST>-ZIVSTATUS_C.
*      WHEN GC_A OR GC_E.
*        LS_COLOR-FNAME = GC_ZIVSTATUS.
*        LS_COLOR-COLOR-COL = '6'.
*        LS_COLOR-COLOR-INT   = '1'.
*        INSERT LS_COLOR INTO TABLE <LS_LIST>-COLO.
*
*      WHEN GC_C OR GC_D.
*        LS_COLOR-FNAME = GC_ZIVSTATUS.
*        LS_COLOR-COLOR-COL = '7'.
*        LS_COLOR-COLOR-INT   = '1'.
*        INSERT LS_COLOR INTO TABLE <LS_LIST>-COLO.
*      WHEN OTHERS.
*    ENDCASE.
*
*  ENDLOOP.
*
*ENDFORM.

*&---------------------------------------------------------------------*
*& FORM SET_ALV_FIELDCAT
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
FORM SET_ALV_FIELDCAT USING PV_GB.

  DATA :
    LR_TABDESCR TYPE REF TO CL_ABAP_STRUCTDESCR,
    LT_DFIES    TYPE DDFIELDS,
    LS_DFIES    TYPE DFIES,
    LT_FCAT     TYPE LVC_T_FCAT,
    LS_FCAT     TYPE LVC_S_FCAT.

  DATA : GR_DREF  TYPE REF TO DATA.
  CLEAR GR_DREF.

  CASE PV_GB.
    WHEN 'IH'. "P_INV AND HEADER  송장처리
      CREATE DATA GR_DREF LIKE GS_LIST.
    WHEN 'DH'. "P_DIS AND HEADER  현황조회/지급요청
      CREATE DATA GR_DREF LIKE GS_DISP.
    WHEN 'IB'.  "P_INV AND ITEM
      CREATE DATA GR_DREF LIKE GS_ITEM.
    WHEN 'DB'. "P_DIS AND ITEM
      CREATE DATA GR_DREF LIKE GS_DISP_IT.
    WHEN OTHERS.
      CREATE DATA GR_DREF LIKE GS_TAX.
  ENDCASE.

  LR_TABDESCR ?= CL_ABAP_STRUCTDESCR=>DESCRIBE_BY_DATA_REF( GR_DREF ).
  LT_DFIES = CL_SALV_DATA_DESCR=>READ_STRUCTDESCR( LR_TABDESCR ) .

  REFRESH : LT_FCAT.

  LOOP AT LT_DFIES INTO LS_DFIES.
    CLEAR : LS_FCAT.
    MOVE-CORRESPONDING LS_DFIES TO LS_FCAT.
    APPEND LS_FCAT TO LT_FCAT.
  ENDLOOP.

*  " 필드 카탈로그 변경사항 적용
  CASE PV_GB.
    WHEN 'IH'. "P_INV AND HEADER  송장처리
      PERFORM ADJUST_FLDCATS TABLES LT_FCAT.
    WHEN 'DH'. "P_DIS AND HEADER  현황조회/지급요청
      PERFORM ADJUST_FLDCATS_DISP TABLES LT_FCAT USING 'HD'.
    WHEN 'IB'.  "P_INV AND ITEM
      PERFORM ADJUST_FLDCATS_ITEM TABLES LT_FCAT.
    WHEN 'DB'. "P_DIS AND ITEM
      PERFORM ADJUST_FLDCATS_DISP TABLES LT_FCAT  USING 'IT'.
    WHEN OTHERS. "세금계산서 조회 팝업 ALV
      PERFORM ADJUST_FLDCATS_TAX TABLES LT_FCAT.
  ENDCASE.

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
    CLEAR : LS_TBAR.

    LS_TBAR-BUTN_TYPE = &1.
    LS_TBAR-FUNCTION   = &2.
    LS_TBAR-ICON           = &3.
    LS_TBAR-TEXT          = &4.
    LS_TBAR-QUICKINFO = &4.

    APPEND LS_TBAR TO PR_OBJ->MT_TOOLBAR.
  END-OF-DEFINITION.


  CASE PO_SENDER.

    WHEN GCL_GRID_HD.
      IF P_DIS = GC_X. "현황조회->HEAD GRID에 필요.
        _SET_TBAR 3 '    ' '              ' '    '.
*        _SET_TBAR 0 'REFRESH' '' 'REFRESH'(B01).
        _SET_TBAR 0 'ASEL'  '' '전체선택'(B02).
        _SET_TBAR 0 'DSEL' '' '전체선택해제'(B03).
      ENDIF.

    WHEN GCL_GRID_IT.
      IF P_INV = GC_X . "송장처리->ITEM GRID에 필요.
        _SET_TBAR 3 '    ' '              ' '    '.
*        _SET_TBAR 0 'ASEL'  '' '전체선택'(B02).
*        _SET_TBAR 0 'DSEL' '' '전체선택해제'(B03).
        _SET_TBAR 0 'CHOICE'  '' '선택'(B13).
        _SET_TBAR 0 'DCHOICE' '' '선택해제'(B14).
        _SET_TBAR 0 'TAX' '' 'TAX조정'(B15).
      ENDIF.

    WHEN OTHERS.
  ENDCASE.

ENDFORM.

*&---------------------------------------------------------------------*
*& FORM USER_COMMAND
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
FORM USER_COMMAND  USING PV_UCOMM LIKE SY-UCOMM.

  CASE PV_UCOMM.
*    WHEN 'REFRESH'.
*      PERFORM GET_DATA.

    WHEN 'ASEL'.
      PERFORM SELECT_ROW_ADSEL USING GC_A.

    WHEN 'DSEL' .
      PERFORM SELECT_ROW_ADSEL USING GC_D.

    WHEN 'CHOICE'.
      PERFORM SELECT_ROW_CHOICE USING GC_A.

    WHEN 'DCHOICE'.
      PERFORM SELECT_ROW_CHOICE USING GC_D.

    WHEN 'TAX'.
      PERFORM SET_TAX_ADJUST .

    WHEN OTHERS.
  ENDCASE.

  PERFORM REFRESH_TABLE USING GCL_GRID_HD SPACE.
  PERFORM REFRESH_TABLE USING GCL_GRID_IT SPACE.

*상단 스크린 필드 업데이트_강제 PBO 실행
  CALL METHOD CL_GUI_CFW=>SET_NEW_OK_CODE
    EXPORTING
      NEW_CODE = 'ENTER'.

ENDFORM.

*&---------------------------------------------------------------------*
*& FORM DATA_CHANGED
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
FORM DATA_CHANGED  USING  PO_DATA_CHANGED
                                     TYPE REF TO CL_ALV_CHANGED_DATA_PROTOCOL
                                               PO_ONF4_AFTER
                                                PO_SENDER.

  CASE PO_SENDER.

    WHEN GCL_GRID_HD.
      PERFORM DATA_CHANGED_1 USING PO_DATA_CHANGED.

    WHEN GCL_GRID_IT.
      PERFORM DATA_CHANGED_2 USING PO_DATA_CHANGED.

    WHEN GCL_GRID_TAX.
      PERFORM DATA_CHANGED_3 USING PO_DATA_CHANGED.

    WHEN OTHERS.
      EXIT.
  ENDCASE.

  PERFORM REFRESH_TABLE USING GCL_GRID_HD SPACE.
  PERFORM REFRESH_TABLE USING GCL_GRID_IT SPACE.

  CALL METHOD CL_GUI_CFW=>SET_NEW_OK_CODE
    EXPORTING
      NEW_CODE = 'ENTER'.

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

  DATA : LT_ITEM LIKE TABLE OF GS_ITEM.

  CLEAR : GV_ERR.
  IF GT_DISP_IT[] IS NOT INITIAL.
    SORT GT_DISP_IT BY BUKRS GJAHR BELNR.
  ENDIF.

  LOOP AT PO_DATA_CHANGED->MT_GOOD_CELLS INTO DATA(LS_MOD_CELLS).
    IF SY-TABIX = 1.
      DATA(LV_TABIX) = SY-TABIX.
    ENDIF.

    IF P_INV = GC_X. "송장처리
      READ TABLE GT_LIST  INTO DATA(LS_LIST) INDEX LS_MOD_CELLS-ROW_ID.

    ELSEIF P_DIS = GC_X. "현황조회
      READ TABLE GT_DISP  INTO DATA(LS_DISP) INDEX LS_MOD_CELLS-ROW_ID.
    ENDIF.

    CHECK SY-SUBRC EQ 0.

    CASE LS_MOD_CELLS-FIELDNAME.

      WHEN 'CHECK'. "선택
        IF P_INV = GC_X.
          LS_LIST-CHECK = LS_MOD_CELLS-VALUE.
        ELSEIF P_DIS = GC_X.
          LS_DISP-CHECK = LS_MOD_CELLS-VALUE.
        ENDIF.

        PERFORM MODIFY_CELL USING PO_DATA_CHANGED 'CHECK'
                                              LS_MOD_CELLS-VALUE LS_MOD_CELLS-ROW_ID.

        IF LS_MOD_CELLS-VALUE IS INITIAL. "체크해제
          IF P_INV = GC_X AND P_LIF = GC_X.
            DELETE GT_ITEM WHERE LIFNR = LS_LIST-LIFNR AND BUKRS = LS_LIST-BUKRS
                                            AND EKORG = LS_LIST-EKORG AND WERKS = LS_LIST-WERKS
                                            AND SPMON = LS_LIST-SPMON.
          ENDIF.
          IF P_INV = GC_X AND P_EKG = GC_X.
            DELETE GT_ITEM WHERE LIFNR = LS_LIST-LIFNR AND BUKRS = LS_LIST-BUKRS
                                           AND EKORG = LS_LIST-EKORG AND WERKS = LS_LIST-WERKS
                                           AND EKGRP = LS_LIST-EKGRP AND SPMON = LS_LIST-SPMON.
          ENDIF.
          IF P_DIS = GC_X . "현황조회
            DELETE GT_DISP_IT WHERE BUKRS = LS_DISP-BUKRS AND GJAHR = LS_DISP-GJAHR
                                               AND BELNR = LS_DISP-BELNR.
          ENDIF.

          IF GT_ITEM[] IS INITIAL.
             CLEAR : GV_LIFNR, GV_LIFNR_N, GV_WAERS, GV_EXRATE, GV_TARGET_PRICE,
                          GV_TPRICE_DISP, GV_TAXPRICE, GV_XPRICE_DISP, GV_WRBTR, GV_WRBTR_DISP, GV_RETURN.
             CLEAR : GV_TAXNO, GV_WAERS2, GV_TARGET_PRICE2, GV_DATE, GV_PDATE,
                          GV_TPRICE_DISP2, GV_TAXPRICE2, GV_XPRICE_DISP2, GV_WRBTR2, GV_WRBTR_DISP2.
          ENDIF.

        ELSE.  "CHECK
          CASE GC_X.
            WHEN P_INV. "송장처리
*동일 업체, 통화코드, 환율인지 체크&헤더 스크린 필드 설정
              IF LV_TABIX = 1 .
                GV_RETURN  = COND #( WHEN GV_LIFNR IS INITIAL THEN LS_LIST-XRECH ELSE GV_RETURN ).
                GV_LIFNR = COND #( WHEN GV_LIFNR IS INITIAL THEN LS_LIST-LIFNR ELSE GV_LIFNR ).
                GV_LIFNR_N = COND #( WHEN GV_LIFNR_N IS INITIAL THEN LS_LIST-LIFNR_N ELSE GV_LIFNR_N ).
                GV_WAERS  = COND #( WHEN GV_WAERS IS INITIAL THEN LS_LIST-ETIV_WAERS ELSE GV_WAERS ).
                GV_TWAERS = GV_XWAERS = GV_WAERS.
                GV_EXRATE = COND #( WHEN GV_EXRATE IS INITIAL THEN LS_LIST-EXRATE ELSE GV_EXRATE ).


                CLEAR LV_TABIX.
              ENDIF.

              IF GV_LIFNR = LS_LIST-LIFNR AND GV_WAERS = LS_LIST-ETIV_WAERS
                AND GV_EXRATE = LS_LIST-EXRATE AND GV_RETURN = LS_LIST-XRECH.
                "통과
                GV_TARGET_PRICE = GV_TARGET_PRICE + LS_LIST-TARGET_PRICE.
                GV_TAXPRICE = GV_TAXPRICE + LS_LIST-TAXPRICE.
                GV_WRBTR = GV_WRBTR + LS_LIST-WRBTR.
              ELSE.
                CLEAR LS_MOD_CELLS-VALUE.
                PERFORM MODIFY_CELL USING PO_DATA_CHANGED 'CHECK'
                                              LS_MOD_CELLS-VALUE LS_MOD_CELLS-ROW_ID.
                GV_ERR = GC_X."에러
                MESSAGE S000 WITH TEXT-E03 DISPLAY LIKE GC_E.  EXIT.
*            "정산은 동일 업체, 통화코드, 환율 별로 가능합니다.
              ENDIF.

              CHECK GV_ERR IS INITIAL.
*LIFNR,BUKRS,EKORG,WERKS(EKGRP)SPMON 기준으로 ITEM구성
              IF P_LIF = GC_X. "업체기준조회

                READ TABLE GT_ITEM_BASE TRANSPORTING NO FIELDS
                WITH KEY LIFNR = LS_LIST-LIFNR
                               BUKRS = LS_LIST-BUKRS
                               EKORG = LS_LIST-EKORG
                               WERKS = LS_LIST-WERKS
                               SPMON = LS_LIST-SPMON
                               XRECH = LS_LIST-XRECH  BINARY SEARCH.
                IF SY-SUBRC = 0.
                  LV_TABIX = SY-TABIX.
                  LOOP AT GT_ITEM_BASE INTO DATA(LS_IT) FROM LV_TABIX.

                    IF LS_LIST-LIFNR = LS_IT-LIFNR AND LS_LIST-BUKRS = LS_IT-BUKRS
                      AND LS_LIST-EKORG = LS_IT-EKORG AND LS_LIST-WERKS = LS_IT-WERKS
                      AND LS_LIST-SPMON = LS_IT-SPMON AND LS_LIST-XRECH = LS_IT-XRECH.

                      LS_IT-CHECK = GC_X.
                      APPEND LS_IT TO GT_ITEM.  CLEAR LS_IT.

*                    ELSE.
*                      EXIT.
                    ENDIF.
                  ENDLOOP.
                ENDIF.
              ENDIF.

              IF P_EKG = GC_X. "구매그룹 별 조회
                READ TABLE GT_ITEM_BASE TRANSPORTING NO FIELDS
                WITH KEY LIFNR = LS_LIST-LIFNR
                               BUKRS = LS_LIST-BUKRS
                               EKORG = LS_LIST-EKORG
                               WERKS = LS_LIST-WERKS
                               EKGRP = LS_LIST-EKGRP
                               SPMON = LS_LIST-SPMON
                               XRECH = LS_LIST-XRECH BINARY SEARCH.
                IF SY-SUBRC = 0.
                  CLEAR : LV_TABIX, LS_IT.
                  LV_TABIX = SY-TABIX.

                  LOOP AT GT_ITEM_BASE INTO LS_IT FROM LV_TABIX.

                    IF LS_LIST-LIFNR = LS_IT-LIFNR AND LS_LIST-BUKRS = LS_IT-BUKRS AND
                     LS_LIST-EKORG = LS_IT-EKORG AND LS_LIST-WERKS = LS_IT-WERKS
                     AND LS_LIST-EKGRP = LS_IT-EKGRP AND LS_LIST-SPMON = LS_IT-SPMON AND LS_LIST-XRECH = LS_IT-XRECH.

                      LS_IT-CHECK = GC_X.
                      APPEND LS_IT TO GT_ITEM.  CLEAR LS_IT.
*
*                    ELSE.
*                      EXIT.
                    ENDIF.
                  ENDLOOP.
                ENDIF.
              ENDIF.


            WHEN P_DIS. "현황조회
              IF GT_DISP_IT[] IS NOT INITIAL.
                 READ TABLE GT_DISP_IT TRANSPORTING NO FIELDS
                 WITH KEY BUKRS = LS_DISP-BUKRS
                                GJAHR = LS_DISP-GJAHR
                                BELNR = LS_DISP-BELNR
                                XRECH = LS_DISP-XRECH BINARY SEARCH.
                 IF SY-SUBRC NE 0.
                   LOOP AT GT_DISP_BASE INTO DATA(LS_BS).
                     IF LS_BS-BUKRS = LS_DISP-BUKRS AND LS_BS-GJAHR = LS_DISP-GJAHR
                       AND LS_BS-BELNR = LS_DISP-BELNR AND LS_BS-XRECH = LS_DISP-XRECH.
                             APPEND LS_BS TO GT_DISP_IT. CLEAR LS_BS.
                     ENDIF.
                   ENDLOOP.
                 ENDIF.

              ELSE.
                 LOOP AT GT_DISP_BASE INTO LS_BS.
                   IF LS_BS-BUKRS = LS_DISP-BUKRS AND LS_BS-GJAHR = LS_DISP-GJAHR
                       AND LS_BS-BELNR = LS_DISP-BELNR .
                             APPEND LS_BS TO GT_DISP_IT. CLEAR LS_BS.
                   ENDIF.
                 ENDLOOP.
              ENDIF.

            WHEN OTHERS.
          ENDCASE.
        ENDIF.

      WHEN 'EXRATE'. "환율
        PERFORM MODIFY_CELL USING PO_DATA_CHANGED 'EXRATE'
                                              LS_MOD_CELLS-VALUE LS_MOD_CELLS-ROW_ID.
        IF LS_LIST-CHECK = GC_X.
          GV_EXRATE = LS_MOD_CELLS-VALUE.
        ENDIF.

      WHEN 'SGTXT'. "세금계산서일련번호

        IF LS_MOD_CELLS-VALUE IS INITIAL.
          CLEAR LS_DISP-SGTXT.
        ELSE.
          SELECT SINGLE FROM ZGTMM_CV_GET_TAX_INVOICE
          FIELDS INV_SEQ
          WHERE BUKRS EQ @P_BUKRS
               AND LIFNR   EQ @LS_DISP-LIFNR
               AND INV_SEQ EQ @LS_MOD_CELLS-VALUE
               AND TAXINV IS INITIAL
          INTO @DATA(LV_SEQ).

          IF SY-SUBRC = 0.
            PERFORM MODIFY_CELL USING PO_DATA_CHANGED 'SGTXT'
                            LV_SEQ LS_MOD_CELLS-ROW_ID.
          ENDIF.
        ENDIF.

      WHEN OTHERS.
    ENDCASE.

    IF P_INV = GC_X.
      MODIFY GT_LIST FROM LS_LIST INDEX LS_MOD_CELLS-ROW_ID.
      CLEAR LS_LIST.
    ENDIF.
    IF P_DIS = GC_X.
      MODIFY GT_DISP FROM LS_DISP INDEX LS_MOD_CELLS-ROW_ID.
      CLEAR LS_DISP.
    ENDIF.
  ENDLOOP.

*  GV_LIFNR = |{ GV_LIFNR ALPHA = OUT }|.

*  IF LV_ERR IS NOT INITIAL.
*    CALL METHOD PO_DATA_CHANGED->DISPLAY_PROTOCOL.
*  ENDIF.

ENDFORM. " DATA_CHANGED_1
*&---------------------------------------------------------------------*
*&      FORM  DATA_CHANGED_2
*&---------------------------------------------------------------------*
*       TEXT
*----------------------------------------------------------------------*
*      -->P_PO_DATA_CHANGED  TEXT
*----------------------------------------------------------------------*
FORM DATA_CHANGED_2 USING PO_DATA_CHANGED
                                       TYPE REF TO CL_ALV_CHANGED_DATA_PROTOCOL.

  DATA : LV_ERR   TYPE CHAR1.
  DATA :
         LV_TPRICE TYPE ZGTMM_CV_GET_TARGET_IV-TARGET_PRICE,
         LV_XPRICE TYPE ZGTMM_CV_GET_TARGET_IV-TAXPRICE,
         LV_RATE   TYPE ZGTMM_CV_GET_TARGET_IV-RATE,
         LV_MWSKZ TYPE ZGTMM_CV_GET_TARGET_IV-MWSKZ,
         LT_MWDAT LIKE TABLE OF RTAX1U15,
         LV_WRBTR TYPE BSEG-WRBTR.

  LOOP AT PO_DATA_CHANGED->MT_GOOD_CELLS INTO DATA(LS_MOD_CELLS).

    READ TABLE GT_ITEM  INTO DATA(LS_LIST) INDEX LS_MOD_CELLS-ROW_ID.
    CHECK SY-SUBRC EQ 0.

    CASE LS_MOD_CELLS-FIELDNAME.

      WHEN 'CHECK'.
        PERFORM MODIFY_CELL USING PO_DATA_CHANGED 'CHECK'
                                                        LS_MOD_CELLS-VALUE LS_MOD_CELLS-ROW_ID.

      WHEN 'IV_QTY'. "정산대상수량
        PERFORM MODIFY_CELL USING PO_DATA_CHANGED 'IV_QTY'
                                                        LS_MOD_CELLS-VALUE LS_MOD_CELLS-ROW_ID.
*-정산대상 수량 변경 시 자동변경(계산)_(정산대상수량/PER*정산유효단가)
        PERFORM CALCULATE_PRICE USING 'Q' CHANGING LS_LIST LS_MOD_CELLS-VALUE.
*-정산대상 금액 변경 시 TAX 자동 재계산_변경된 정산대상금액*세율
        PERFORM CALCULATE_TAX  CHANGING LS_LIST.


      WHEN 'ETIV_PRICE'. "정산유효단가
        PERFORM MODIFY_CELL USING PO_DATA_CHANGED 'ETIV_PRICE'
                                                        LS_MOD_CELLS-VALUE LS_MOD_CELLS-ROW_ID.
*-정산유효단가 변경 시 정산대상 금액 자동변경(계산)
        PERFORM CALCULATE_PRICE USING  'P' CHANGING LS_LIST LS_MOD_CELLS-VALUE.
*-정산대상 금액 변경 시 TAX 자동 재계산_변경된 정산대상금액*세율
        PERFORM CALCULATE_TAX  CHANGING LS_LIST.

      WHEN 'MWSKZ'. "세금코드
        SELECT SINGLE 1
          FROM T007A
          WHERE MWSKZ = @LS_MOD_CELLS-VALUE
          INTO @DATA(LV_EXSIT).

        IF SY-SUBRC = 0.
          PERFORM MODIFY_CELL USING PO_DATA_CHANGED 'MWSKZ'
                                                LS_MOD_CELLS-VALUE LS_MOD_CELLS-ROW_ID.
          LS_LIST-MWSKZ = LS_MOD_CELLS-VALUE.
*-세금코드 변경 시 세율 재조회
          CLEAR LS_LIST-RATE.
          SELECT SINGLE FROM ZGTMM_CV_GET_TAX_RATE
          FIELDS RATE
          WHERE MWSKZ = @LS_MOD_CELLS-VALUE INTO @LS_LIST-RATE.
*-세율 재조회 후 정산대상TAX 재계산
          PERFORM CALCULATE_TAX  CHANGING LS_LIST.
        ELSE.
* 세금코드 맞지않거나, 빈 값 입력 시->세율 클리어.
          CLEAR LS_LIST-RATE.
        ENDIF.

      WHEN 'TARGET_PRICE'. "정산대상금액
        PERFORM MODIFY_CELL USING PO_DATA_CHANGED 'TARGET_PRICE'
                                                        LS_MOD_CELLS-VALUE LS_MOD_CELLS-ROW_ID.
        LS_LIST-TARGET_PRICE = LS_MOD_CELLS-VALUE.
*-정산대상금액 변경 시 정산대상TAX 자동 재계산
        PERFORM CALCULATE_TAX  CHANGING LS_LIST.

      WHEN 'TAXPRICE'. "정산TAX금액
        PERFORM MODIFY_CELL USING PO_DATA_CHANGED 'TAXPRICE'
                                                        LS_MOD_CELLS-VALUE LS_MOD_CELLS-ROW_ID.
        LS_LIST-TAXPRICE = LS_MOD_CELLS-VALUE.

      WHEN OTHERS.
    ENDCASE.

    MODIFY GT_ITEM FROM LS_LIST INDEX LS_MOD_CELLS-ROW_ID.
  ENDLOOP.

*  IF LV_ERR IS NOT INITIAL.
*    CALL METHOD PO_DATA_CHANGED->DISPLAY_PROTOCOL.
*  ENDIF.

ENDFORM. " DATA_CHANGED_2
*&---------------------------------------------------------------------*
*&      FORM  DATA_CHANGED_3
*&---------------------------------------------------------------------*
*       TEXT
*----------------------------------------------------------------------*
*      -->P_PO_DATA_CHANGED  TEXT
*----------------------------------------------------------------------*
FORM DATA_CHANGED_3 USING PO_DATA_CHANGED
                                       TYPE REF TO CL_ALV_CHANGED_DATA_PROTOCOL.

  DATA : LV_ERR   TYPE CHAR1.

  LOOP AT PO_DATA_CHANGED->MT_GOOD_CELLS INTO DATA(LS_MOD_CELLS).

    CASE LS_MOD_CELLS-FIELDNAME.

      WHEN 'CHECK'.
        READ TABLE GT_TAX  INTO DATA(LS_TAX) INDEX LS_MOD_CELLS-ROW_ID.
        CHECK SY-SUBRC EQ 0.

        IF LS_MOD_CELLS-VALUE IS INITIAL.
        ELSE.
*기존 체크된 데이터 있는지 체크후 클리어.
          READ TABLE GT_TAX ASSIGNING FIELD-SYMBOL(<CHK>)
          WITH KEY CHECK = GC_X.

          IF SY-SUBRC = 0.
            DATA(LV_TABIX) = SY-TABIX.
            CLEAR <CHK>-CHECK.
            MODIFY GT_TAX FROM <CHK> INDEX LV_TABIX.
          ENDIF.
        ENDIF.

        LS_TAX-CHECK = LS_MOD_CELLS-VALUE.
        PERFORM MODIFY_CELL USING PO_DATA_CHANGED 'CHECK'
                                                        LS_MOD_CELLS-VALUE LS_MOD_CELLS-ROW_ID.

      WHEN OTHERS.
    ENDCASE.

  ENDLOOP.

ENDFORM.

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

    WHEN GCL_GRID_HD.
      IF P_INV = GC_X.

        READ TABLE GT_LIST INTO DATA(LS_LIST) INDEX PS_ROW_NO-INDEX.
        CHECK SY-SUBRC = 0.

*        IF PS_COLUMN-FIELDNAME = 'EBELN'.
*          CHECK LS_LIST-EBELN IS NOT INITIAL.
*
*          SET PARAMETER ID 'BES' FIELD LS_LIST-EBELN.
*          CALL TRANSACTION 'ME23N' AND SKIP FIRST SCREEN.
*
*        ELSEIF PS_COLUMN-FIELDNAME = 'BANFN'.
*          CHECK LS_LIST-BANFN IS NOT INITIAL.
*
*          SET PARAMETER ID 'BAN' FIELD LS_LIST-BANFN.
*          CALL TRANSACTION 'ME53N' AND SKIP FIRST SCREEN.
*
*        ELSEIF PS_COLUMN-FIELDNAME = 'BANFN_N'.
*          CHECK LS_LIST-BANFN_N IS NOT INITIAL.
*
*          SET PARAMETER ID 'BAN' FIELD LS_LIST-BANFN_N.
*          CALL TRANSACTION 'ME53N' AND SKIP FIRST SCREEN.

*      ELSEIF PS_COLUMN-FIELDNAME = 'CHECK'.
*        IF <LS_LIST_1>-CHECK IS INITIAL.
*          <LS_LIST_1>-CHECK = ABAP_TRUE.
*        ELSE.
*          CLEAR <LS_LIST_1>-CHECK.
*        ENDIF.
*
*        PERFORM REFRESH_TABLE USING GCL_GRID SPACE.
*        CALL METHOD CL_GUI_CFW=>SET_NEW_OK_CODE
*          EXPORTING
*            NEW_CODE = 'ENTER'.
*
*        ELSE.
*          EXIT.
*        ENDIF.

      ELSE.

*        READ TABLE GT_CREATE INTO DATA(LS_CRE) INDEX PS_ROW_NO-INDEX.
*        CHECK SY-SUBRC = 0.
*
*        IF PS_COLUMN-FIELDNAME = 'EBELN'.
*          CHECK LS_CRE-EBELN IS NOT INITIAL.
*
*          SET PARAMETER ID 'BES' FIELD LS_CRE-EBELN.
*          CALL TRANSACTION 'ME23N' AND SKIP FIRST SCREEN.

*      ELSEIF PS_COLUMN-FIELDNAME = 'BANFN'.
*        CHECK LS_CRE-EBELN IS NOT INITIAL.
*
*        SET PARAMETER ID 'BES' FIELD LS_CRE-EBELN.
*        CALL TRANSACTION 'ME23N' AND SKIP FIRST SCREEN.


*      ELSEIF PS_COLUMN-FIELDNAME = 'CHECK'.
*        IF <LS_LIST_1>-CHECK IS INITIAL.
*          <LS_LIST_1>-CHECK = ABAP_TRUE.
*        ELSE.
*          CLEAR <LS_LIST_1>-CHECK.
*        ENDIF.
*
*        PERFORM REFRESH_TABLE USING GCL_GRID SPACE.
*        CALL METHOD CL_GUI_CFW=>SET_NEW_OK_CODE
*          EXPORTING
*            NEW_CODE = 'ENTER'.
*
*        ELSE.
*          EXIT.
*        ENDIF.

      ENDIF.


    WHEN GCL_GRID_IT.
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

  DATA : LT_RETURN TYPE TABLE OF DDSHRETVAL,
             LS_RETURN TYPE DDSHRETVAL.
  FIELD-SYMBOLS : <LT_MODI> TYPE LVC_T_MODI.
  DATA : LS_MODI TYPE LVC_S_MODI.

* TO AVOID STANDARD F4-HELP.
  ER_EVENT_DATA->M_EVENT_HANDLED = 'X'.

*세금코드
  IF E_FIELDNAME = 'MWSKZ'.
*"데이터 추출 (KALSM = 'TAXKR' 필터 및 텍스트 조인)
  SELECT A~KALSM, A~MWSKZ, S~TEXT1
    FROM T007A AS A
    LEFT JOIN T007S AS S ON A~KALSM  = S~KALSM
                                    AND A~MWSKZ = S~MWSKZ
                                    AND S~SPRAS  = @SY-LANGU
    WHERE A~KALSM = @GC_TAXKR
    INTO TABLE @DATA(LT_TEMP).

*F4 HELP 호출
  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      RETFIELD          = 'MWSKZ'         " 내부 테이블에서 가져올 필드명
      WINDOW_TITLE  = '세금 코드 선택'
      VALUE_ORG       = 'S'
    TABLES
      VALUE_TAB       = LT_TEMP       " 데이터가 담긴 ITAB
      RETURN_TAB     = LT_RETURN   " 사용자가 선택한 행의 정보가 담김
    EXCEPTIONS
      PARAMETER_ERROR = 1
      NO_VALUES_FOUND = 2
      OTHERS          = 3.

    IF SY-SUBRC <> 0.
      MESSAGE S000 WITH 'POSSIBLE ENTRY DATA가 없습니다 !!!'.
    ENDIF.

    IF SY-SUBRC = 0 AND LT_RETURN IS NOT INITIAL.
*선택된 값 추출 (F0001=KALSM, F0002=MWSKZ, F0003=TEXT1)
      READ TABLE LT_RETURN INTO LS_RETURN WITH KEY FIELDNAME = 'F0002'.

      ASSIGN ER_EVENT_DATA->M_DATA->* TO <LT_MODI>.

      CLEAR : LS_MODI.
      LS_MODI-ROW_ID      = ES_ROW_NO-ROW_ID.
      LS_MODI-FIELDNAME = E_FIELDNAME.
      LS_MODI-VALUE        = LS_RETURN-FIELDVAL.
      APPEND LS_MODI TO <LT_MODI>.
   ENDIF.

*세금계산서일련번호
  ELSEIF E_FIELDNAME = 'SGTXT'.
    CLEAR GT_TAX.

    READ TABLE GT_DISP ASSIGNING FIELD-SYMBOL(<DSP>)
    INDEX ES_ROW_NO-ROW_ID.

    IF SY-SUBRC = 0.
      SELECT FROM ZGTMM_CV_GET_TAX_INVOICE
      FIELDS *
      WHERE BUKRS EQ @P_BUKRS
           AND LIFNR   EQ @<DSP>-LIFNR
           AND TAXINV IS INITIAL
      INTO CORRESPONDING FIELDS OF TABLE @GT_TAX.
    ENDIF.

    IF GT_TAX IS INITIAL.
      CLEAR GV_TAXNO. MESSAGE S000 WITH TEXT-E01.
    ELSE.
      CALL SCREEN 400 STARTING AT 10 5.
    ENDIF.

    IF GV_TAXNO IS NOT INITIAL.
      READ TABLE GT_DISP ASSIGNING FIELD-SYMBOL(<DSP2>)
      INDEX ES_ROW_NO-ROW_ID.

      IF SY-SUBRC = 0.
*>S.2026.08.04_금액 일치여부 조건 체크 해제.
**선택한 데이터의 합계금액/공급가액/(부가)세액 금액이 일치하지 않으면, 미설정
*        IF <DSP2>-RMWWR NE GV_TOTAL OR <DSP2>-SPRICE NE GV_SPRICE
*            OR <DSP2>-WMWST1 NE GV_WMWST.
*
*            CLEAR : <DSP2>-SGTXT, GV_TOTAL, GV_SPRICE, GV_WMWST, GV_TAXNO.
*
*        ELSE.
         <DSP2>-SGTXT = GV_TAXNO.  "세금계산서일련번호
         <DSP2>-RMWWR = GV_TOTAL. "합계금액
         <DSP2>-SPRICE = GV_SPRICE.  "공급가액
         <DSP2>-WMWST1 = GV_WMWST. "세액

         CLEAR : GV_TAXNO, GV_TOTAL, GV_SPRICE, GV_WMWST.
*        ENDIF.
*<E.2026.08.04_ZGODEV04
      ENDIF.
    ENDIF.

*CL_GUI_ALV_GRID=>SET_DELTA_VALUES( )

  ENDIF.



*셀렉션스크린 파라메터나 스크린필드 바로 적용일때...
*  DATA : LT_DYNP TYPE TABLE OF DYNPREAD,
*             LS_DYNP TYPE DYNPREAD.
*    IF SY-SUBRC = 0 AND LT_RETURN IS NOT INITIAL.
**선택된 행에서 필요한 값들을 추출하여 화면 필드와 매핑
*       READ TABLE LT_RETURN INTO LS_RETURN WITH KEY FIELDNAME = 'F0002'. " MWSKZ (두번째 필드)
*       IF SY-SUBRC = 0.
*          LS_DYNP-FIELDNAME = 'MWSKZ'.   " 화면의 코드 필드명
*          LS_DYNP-FIELDVALUE = LS_RETURN-FIELDVAL.
*          APPEND LS_DYNP TO LT_DYNP.
*       ENDIF.
*
*      READ TABLE LT_RETURN INTO LS_RETURN WITH KEY FIELDNAME = 'F0003'. " TEXT1 (세번째 필드)
*      IF SY-SUBRC = 0.
*         LS_DYNP-FIELDNAME = 'MWSKZ_N'. " 화면의 텍스트 필드명
*         LS_DYNP-FIELDVALUE = LS_RETURN-FIELDVAL.
*         APPEND LS_DYNP TO LT_DYNP.
*      ENDIF.
*
**화면(Dynpro) 필드 값 일괄 업데이트
*      CALL FUNCTION 'DYNP_VALUES_UPDATE'
*        EXPORTING
*         DYNAME     = SY-REPID
*         DYNUMB     = SY-DYNNR
*       TABLES
*         DYNPFIELDS = LT_DYNP.
*    ENDIF.


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

  DATA LV_MSG TYPE BAPI_MSG.

  CLEAR : GT_ROWS, GS_ROW, GV_ERR.

  CALL METHOD PR_GRID->GET_SELECTED_ROWS
    IMPORTING
      ET_INDEX_ROWS = GT_ROWS.

  DESCRIBE TABLE GT_ROWS.

  IF SY-TFILL = 0.
    GV_ERR = GC_X.

    CASE GV_OKCODE_SAVE . "SY-UCOMM.
      WHEN 'INVOICE'.
        LV_MSG = '송장 처리할 대상을 선택하세요.'(E06).
      WHEN 'REVERS'.
        LV_MSG = '역분개할 송장 문서를 선택하세요.'(E07).
      WHEN 'REQ_PAY'.
        LV_MSG = '지급 요청할 대상을 선택하세요.'(E05).
      WHEN OTHERS.
    ENDCASE.

    MESSAGE S000 WITH LV_MSG DISPLAY LIKE GC_E.
  ENDIF.

  IF SY-TFILL > 1 AND GV_OKCODE_SAVE = 'REVERS'.
    GV_ERR = GC_X.
    LV_MSG = '역분개 처리는 송장 건 별로 처리하세요.'(E09).
    MESSAGE S000 WITH LV_MSG DISPLAY LIKE GC_E.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& FORM SELECT_ROW_ADSEL
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
*& -->  P1        TEXT
*& <--  P2        TEXT
*&---------------------------------------------------------------------*
FORM SELECT_ROW_ADSEL USING PV_GB.

  DATA(LT_LIST) = GT_LIST[].
  SORT LT_LIST BY CHECK LIFNR BUKRS EKORG WERKS SPMON XRECH.

  CASE PV_GB.
*전체선택
    WHEN GC_A.
      IF P_INV = GC_X. "송장처리 옵션은 ITEM GRID에 버튼 존재
        CHECK GT_ITEM[] IS NOT INITIAL.
*헤더 선택 시마다,조건에 맞는 ITEM이 자동 구성된 상태이므로, 아이템그리드의 전체선택 버튼 클릭시,
*별도 로직 없이 모두 체크해주면 됨. 헤더에는 해당 버튼 없으므로(개별선택임).
        LOOP AT GT_ITEM ASSIGNING FIELD-SYMBOL(<ASEL>).
           <ASEL>-CHECK = GC_X.

*총 공급가액,세액,합계금액 변경 반영_상단 스크린 필드.
          READ TABLE LT_LIST TRANSPORTING NO FIELDS
          WITH KEY CHECK = GC_X
                   LIFNR = <ASEL>-LIFNR
                   BUKRS = <ASEL>-BUKRS
                   EKORG = <ASEL>-EKORG
                   WERKS = <ASEL>-WERKS
                   SPMON = <ASEL>-SPMON
                   XRECH = <ASEL>-XRECH BINARY SEARCH.

          IF SY-SUBRC = 0 .
            GV_TARGET_PRICE = GV_TARGET_PRICE + <ASEL>-TARGET_PRICE.
            GV_TAXPRICE = GV_TAXPRICE + <ASEL>-TAXPRICE.
          ENDIF.
        ENDLOOP.
*총 합계금액 = 총 공급가액 + 총 세액
        GV_WRBTR = GV_TARGET_PRICE + GV_TAXPRICE.

        READ TABLE LT_LIST INTO DATA(LS2) WITH KEY CHECK = GC_X BINARY SEARCH.
        GV_XRECH = COND #( WHEN LS2 IS INITIAL THEN '' ELSE LS2-XRECH ).

*합계필드 화면 표시용 변환(단위참조)
        WRITE GV_WRBTR TO GV_WRBTR_DISP CURRENCY GV_WAERS LEFT-JUSTIFIED.
        WRITE GV_TARGET_PRICE TO GV_TPRICE_DISP CURRENCY GV_WAERS LEFT-JUSTIFIED.
        WRITE GV_TAXPRICE TO GV_XPRICE_DISP CURRENCY GV_WAERS LEFT-JUSTIFIED.
      ENDIF.

      IF P_DIS = GC_X.  "조회 옵션은 HEADER GRID에 버튼 존재
         MODIFY GT_DISP FROM VALUE #( CHECK = 'X' ) TRANSPORTING
                     CHECK WHERE CHECK <> 'X'.

        GT_DISP_IT[] = GT_DISP_BASE[].
      ENDIF.

*전체선택해제
    WHEN GC_D.
      IF P_INV = GC_X.
        MODIFY GT_ITEM FROM VALUE #( CHECK = SPACE ) TRANSPORTING
                     CHECK WHERE CHECK EQ 'X'.

        CLEAR :  GV_TARGET_PRICE, GV_TAXPRICE, GV_WRBTR, GV_XRECH,
                      GV_WRBTR_DISP, GV_TPRICE_DISP, GV_XPRICE_DISP.
      ENDIF.

      IF P_DIS = GC_X.
         MODIFY GT_DISP FROM VALUE #( CHECK = SPACE ) TRANSPORTING
                     CHECK WHERE CHECK EQ 'X'.
      ENDIF.

    WHEN OTHERS.
  ENDCASE.


ENDFORM.
*&---------------------------------------------------------------------*
*& FORM SELECT_ROW_CHOICE
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
*& -->  P1        TEXT
*& <--  P2        TEXT
*&---------------------------------------------------------------------*
FORM SELECT_ROW_CHOICE USING PV_GB.

*  DATA(LT_LIST) = GT_LIST[].
*  SORT LT_LIST BY CHECK LIFNR BUKRS EKORG WERKS SPMON XRECH.

  CLEAR : GV_ERR.

  PERFORM GET_SELECTED_ROWS USING GCL_GRID_IT.
  CHECK GV_ERR IS INITIAL.

  CASE PV_GB.
*전체선택
    WHEN GC_A.
      IF P_INV = GC_X. "송장처리 옵션은 ITEM GRID에 버튼 존재
        CHECK GT_ITEM[] IS NOT INITIAL.
*선택된 블럭의 모든 라인 체크박스 표기(선택)
        LOOP AT GT_ROWS INTO DATA(LS_ROW).
          READ TABLE GT_ITEM ASSIGNING FIELD-SYMBOL(<ASEL>) INDEX LS_ROW-INDEX.
          IF SY-SUBRC = 0.
            <ASEL>-CHECK = GC_X.
          ENDIF.
        ENDLOOP.
      ENDIF.

*선택해제
    WHEN GC_D.
      CLEAR LS_ROW.
      IF P_INV = GC_X.
*선택된 블럭의 모든 라인 체크박스 표기(선택)
        LOOP AT GT_ROWS INTO LS_ROW.
          READ TABLE GT_ITEM ASSIGNING FIELD-SYMBOL(<DSEL>) INDEX LS_ROW-INDEX.
          IF SY-SUBRC = 0.
            <DSEL>-CHECK = ''.
          ENDIF.
        ENDLOOP.
      ENDIF.

    WHEN OTHERS.
  ENDCASE.

***총 공급가액,세액,합계금액 변경 반영_헤더 스크린 필드.
  PERFORM SET_CHECK_AMT.

ENDFORM.
*&---------------------------------------------------------------------*
*& FORM SET_CHECK_AMT
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
*& -->  P1        TEXT
*& <--  P2        TEXT
*&---------------------------------------------------------------------*
FORM SET_CHECK_AMT .

  CLEAR :  GV_TARGET_PRICE, GV_TAXPRICE, GV_WRBTR, GV_XRECH,
                GV_WRBTR_DISP, GV_TPRICE_DISP, GV_XPRICE_DISP.

  LOOP AT GT_ITEM ASSIGNING FIELD-SYMBOL(<ITEM>) WHERE CHECK = GC_X.
*총 공급가액,세액,합계금액 변경 반영_상단 스크린 필드.
    GV_TARGET_PRICE = GV_TARGET_PRICE + <ITEM>-TARGET_PRICE.
    GV_TAXPRICE = GV_TAXPRICE + <ITEM>-TAXPRICE.
  ENDLOOP.

*총 합계금액 = 총 공급가액 + 총 세액
  GV_WRBTR = GV_TARGET_PRICE + GV_TAXPRICE.

  READ TABLE GT_LIST INTO DATA(LS) WITH KEY CHECK = GC_X .
  GV_XRECH = COND #( WHEN LS IS INITIAL THEN '' ELSE LS-XRECH ).

*합계필드 화면 표시용 변환(단위참조)
  WRITE GV_WRBTR TO GV_WRBTR_DISP CURRENCY GV_WAERS LEFT-JUSTIFIED.
  WRITE GV_TARGET_PRICE TO GV_TPRICE_DISP CURRENCY GV_WAERS LEFT-JUSTIFIED.
  WRITE GV_TAXPRICE TO GV_XPRICE_DISP CURRENCY GV_WAERS LEFT-JUSTIFIED.

ENDFORM.
*&---------------------------------------------------------------------*
*& FORM CHECK_REVERSAL_DATA
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
*& -->  P1        TEXT
*& <--  P2        TEXT
*&---------------------------------------------------------------------*
FORM CHECK_REVERSAL_DATA .

  CLEAR : GV_ERR.
  DATA LV_TABIX TYPE SY-TABIX.

  DESCRIBE TABLE GT_DISP.
  IF SY-TFILL = 0.
    GV_ERR = GC_X.
    MESSAGE S000 WITH '역분개할 송장 문서를 선택하세요.'(E07) DISPLAY LIKE GC_E.
    EXIT.
  ENDIF.

  IF LINE_EXISTS( GT_DISP[ CHECK = GC_X ] ).
    CLEAR LV_TABIX.

    LOOP AT GT_DISP ASSIGNING FIELD-SYMBOL(<FS>) WHERE CHECK = GC_X.
      LV_TABIX = LV_TABIX + 1.

      IF LV_TABIX > 1.
        GV_ERR = GC_X.
        MESSAGE S000 WITH '역분개 처리는 송장 건 별로 처리하세요.'(E09)
        DISPLAY LIKE GC_E.  EXIT.
      ENDIF.

      CHECK GV_ERR IS INITIAL.

      IF <FS>-CHECK = GC_X AND <FS>-REQPAY = GC_X.
        GV_ERR = GC_X. "지급 요청 진행 중인 송장은 역분개 할 수 없습니다.
        MESSAGE S000 WITH TEXT-E10 DISPLAY LIKE GC_E. EXIT.
      ENDIF.

      IF <FS>-CHECK = GC_X AND <FS>-CLEARING = GC_X.
        GV_ERR = GC_X. "지급 진행된 송장은 역분개 할 수 없습니다.
        MESSAGE S000 WITH TEXT-E11 DISPLAY LIKE GC_E. EXIT.
      ENDIF.

    ENDLOOP.

  ELSE.
    GV_ERR = GC_X.
    MESSAGE S000 WITH '역분개할 송장 문서를 선택하세요.'(E07) DISPLAY LIKE GC_E.
    EXIT.
  ENDIF.

  CHECK GV_ERR IS INITIAL.

  CLEAR : GV_BUDAT, GV_REASON, GV_BDATE, GV_ZTERM.
  GV_QUES = TEXT-M04. "선택된 송장을 역분개 하시겠습니까?
  GV_INFO   = TEXT-M05.  "(전기일 미입력 시, 생성 시 전기일로 역분개 됩니다.)

  CALL SCREEN 0200 STARTING AT 5 10.


ENDFORM.
*&---------------------------------------------------------------------*
*& FORM REQUEST_PAY
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
*& -->  P1        TEXT
*& <--  P2        TEXT
*&---------------------------------------------------------------------*
FORM REQUEST_PAY.
    DATA:
    LV_REQXML   TYPE string,
    LV_TYPE    TYPE BAPI_MTYPE,
    LV_MSG        TYPE BAPI_MSG,
    LV_APPID    TYPE CHAR32,
    LV_LEGACY TYPE CHAR32,
    LV_URL      TYPE STRING,
    LV_PERNR    TYPE CHAR10,
    LV_TCODE    TYPE CHAR20.

  CLEAR : GV_ANSWER, GV_ERR.

  IF LINE_EXISTS( GT_DISP[ CHECK = GC_X ] ).
    PERFORM POPUP_TO_CONFIRM_STEP USING GC_N TEXT-M07 '' TEXT-T04. "확인
*  "선택한 송장에 대해 지급 요청을 하시겠습니까?
  ELSE.
    GV_ERR = GC_X. "지급 요청할 대상을 선택하세요.
    MESSAGE S000 WITH TEXT-E05 DISPLAY LIKE GC_E. EXIT.
  ENDIF.

  CHECK GV_ERR IS INITIAL.
  CHECK GV_ANSWER = GC_J. "YES

  LOOP AT GT_DISP ASSIGNING FIELD-SYMBOL(<FS>) WHERE CHECK = GC_X.

    IF <FS>-REQPAY = GC_X.
      GV_ERR = GC_X. "이미 지급 요청한 송장입니다.
      MESSAGE S000 WITH TEXT-E13 DISPLAY LIKE GC_E. EXIT.
    ENDIF.

    IF <FS>-CLEARING = GC_X.
      GV_ERR = GC_X. "지급 진행된 송장은 지급 요청할 수 없습니다.
      MESSAGE S000 WITH TEXT-E15 DISPLAY LIKE GC_E. EXIT.
    ENDIF.

  ENDLOOP.

  CHECK GV_ERR IS INITIAL.

*  DATA : LV_TYPE       TYPE BAPI_MTYPE,
*         LV_MSG        TYPE BAPI_MSG,
*         LV_LEGACY(32),
*         LV_APPID(32),
*         LV_URL        TYPE STRING,
*         LV_XML        TYPE STRING.

  DATA : LT_5010 LIKE TABLE OF ZGTMMT5010.

  "XML 생성
  PERFORM F_SET_GW_XML USING SY-UNAME CHANGING LV_REQXML.

  LV_PERNR = SY-UNAME.
  LV_TCODE = sy-tcode.

*WELS 결재요청//HTML 구성....추후 정의 되면..
  CALL FUNCTION 'ZGTMM_APP_TO_WELS'
    EXPORTING
      I_BUKRS  = P_BUKRS
      I_PERNR  = LV_PERNR
      I_TCODE  = LV_TCODE
      I_REQXML = LV_REQXML
    IMPORTING
      MTYPE    = LV_TYPE
      MESSAGE  = LV_MSG
      LEGACYID = LV_LEGACY
      APPID    = LV_APPID
      URL      = LV_URL.

  IF  LV_TYPE = GC_E.
    MESSAGE S000 WITH LV_MSG DISPLAY LIKE GC_E.

  ELSE.
*ZGTMMT5010 LOG UPDATE
    LT_5010[] = VALUE #( BASE LT_5010 FOR LS IN GT_DISP WHERE ( CHECK = GC_X )
                                    ( VALUE #( BASE CORRESPONDING #( LS )
                                         LEGACYID = LV_LEGACY
                                         APPID = LV_APPID
                                         ERDAT = SY-DATUM
                                         ERDAT_LOCAL = SY-DATLO
                                         ERTIM = SY-UZEIT
                                         ERTIM_LOCAL = SY-TIMLO
                                         ERNAM = SY-UNAME
                                         AEDAT = SY-DATUM
                                         AEDAT_LOCAL = SY-DATLO
                                         AETIM = SY-UZEIT
                                         AETIM_LOCAL =  SY-TIMLO
                                         AENAM = SY-UNAME ) ) ).
    IF LT_5010[] IS NOT INITIAL.
      MODIFY ZGTMMT5010 FROM TABLE LT_5010.
      IF SY-SUBRC = 0.
        COMMIT WORK AND WAIT.
      ENDIF.
    ENDIF.

    MESSAGE S036 WITH '지급 요청'. "& 성공했습니다.
  ENDIF.


ENDFORM.
*&---------------------------------------------------------------------*
*& FORM SET_BAPI_DATA
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
*& -->  P1        TEXT
*& <--  P2        TEXT
*&---------------------------------------------------------------------*
FORM SET_BAPI_DATA .
  DATA : LV_SET_ERR TYPE CHAR1.
  DATA :
    LT_ITEM TYPE TABLE OF BAPI_INCINV_CREATE_ITEM,
    LT_TAX  TYPE TABLE OF BAPI_INCINV_CREATE_TAX.
  DATA : BEGIN OF LS_TAX,
           TAX_CODE   TYPE  BAPI_INCINV_CREATE_TAX-TAX_CODE,
           TAX_AMOUNT TYPE BAPI_INCINV_CREATE_TAX-TAX_AMOUNT,
         END OF LS_TAX,
         LT_TAX_COL LIKE TABLE OF LS_TAX WITH HEADER LINE.

  DATA :
    LS_HEAD   TYPE BAPI_INCINV_CREATE_HEADER,
    LV_ITEM   TYPE EBELP,
    LV_INVNO  TYPE RE_BELNR,
    LV_IVYEAR TYPE GJAHR,
    LV_TPRICE TYPE ZGTMM_CV_GET_TARGET_IV_H2-WRBTR,
    LV_TIME(14),
    LV_C_AMT(35).

  CLEAR : GV_ERR.

DEFINE _IDOC.

  IF &3 = 'D'.
 " 1. SAP 내부(100.00) -> 외부/IDOC(100) 변환
   CALL FUNCTION 'CURRENCY_AMOUNT_SAP_TO_IDOC'
     EXPORTING
      CURRENCY      = &1
      SAP_AMOUNT  = &2
     IMPORTING
      IDOC_AMOUNT = &2. " 결과: 100

  ELSE. "A
" 2. 화면 입력(100) -> SAP 내부(100.00) 변환
  CALL FUNCTION 'CURRENCY_AMOUNT_DISPLAY_TO_SAP'
    EXPORTING
      CURRENCY               = &1
      AMOUNT_DISPLAY    = &2
    IMPORTING
      AMOUNT_INTERNAL  = &2. " 결과: 100.00

  ENDIF.
END-OF-DEFINITION.

*BAPI HEAER
  LV_C_AMT = GV_WRBTR.
  _IDOC GV_WAERS LV_C_AMT 'D'.
  GV_WRBTR = LV_C_AMT.

*>S.2026.08.13_송장생성시 구분내역이 필요하여 추가/구매오더 여러개이므로..
  LV_TIME = |{ SY-DATUM }{ SY-UZEIT }|. "(YYYYMMDDHHMMSS)
*<E.2026.08.13_ZGODEV04

  LS_HEAD = VALUE #( INVOICE_IND          = GV_XRECH
                                  DOC_DATE              = GV_BUDAT "SY-DATLO "2026.08.11 변경
                                  PSTNG_DATE           = GV_BUDAT
                                  COMP_CODE            = P_BUKRS
                                  CURRENCY               = GV_WAERS
                                  EXCH_RATE              = GV_EXRATE
                                  GROSS_AMOUNT       = GV_WRBTR
                                  PMNTTRMS                = GV_ZTERM "지급조건
                                  REF_DOC_NO_LONG  = P_WERKS
                                  ITEM_TEXT                = GV_TAXNO  "세금계산서일련번호
                                  BLINE_DATE              = GV_BUDAT "GV_BDATE  ). "지급기산일->전기일자와 동일하게_260803
                                  ALLOC_NMBR           = LV_TIME ). "2026.08.13추가(YYYYMMDDHHMMSS)
*BAPI_ITEM
  CLEAR : LV_ITEM, LT_ITEM, LT_TAX, GT_RETURN.
  LOOP AT GT_ITEM ASSIGNING FIELD-SYMBOL(<FS>) WHERE CHECK = GC_X.

    LV_ITEM = LV_ITEM + 1.

    CLEAR : LV_TPRICE, LV_C_AMT.
    LV_C_AMT = <FS>-TARGET_PRICE.
    _IDOC GV_WAERS LV_C_AMT 'D'.
    LV_TPRICE = LV_C_AMT.

    APPEND VALUE #( INVOICE_DOC_ITEM  = LV_ITEM
                                 PO_NUMBER        = <FS>-EBELN
                                 PO_ITEM              = <FS>-EBELP
                                 REF_DOC             = <FS>-MBLNR
                                 REF_DOC_YEAR   = <FS>-MJAHR
                                 REF_DOC_IT        = <FS>-ZEILE
                                 TAX_CODE          = <FS>-MWSKZ
                                 ITEM_AMOUNT    = LV_TPRICE
                                 QUANTITY           = <FS>-IV_QTY
                                 PO_UNIT             = <FS>-MEINS
                                 PO_PR_QNT       = <FS>-IV_OQTY
                                 PO_PR_UOM      = <FS>-ETIV_MEINS
                                 ) TO LT_ITEM.

    LT_TAX_COL-TAX_CODE      = <FS>-MWSKZ.
    CLEAR LV_C_AMT.
    LV_C_AMT = <FS>-TAXPRICE.
    _IDOC GV_WAERS LV_C_AMT 'D'.
    LT_TAX_COL-TAX_AMOUNT = LV_C_AMT.
    COLLECT LT_TAX_COL .

  ENDLOOP.

  LT_TAX[] = CORRESPONDING #( LT_TAX_COL[] ).
*BAPI
  CALL FUNCTION 'BAPI_INCOMINGINVOICE_CREATE'
    EXPORTING
      HEADERDATA       = LS_HEAD
    IMPORTING
      INVOICEDOCNUMBER = LV_INVNO
      FISCALYEAR       = LV_IVYEAR
    TABLES
      ITEMDATA         = LT_ITEM
      TAXDATA          = LT_TAX
      RETURN           = GT_RETURN.

  LOOP AT GT_LIST ASSIGNING FIELD-SYMBOL(<FSHD>) WHERE CHECK = GC_X.
    IF LINE_EXISTS( GT_RETURN[ TYPE = GC_E ] ).
      CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

      READ TABLE GT_RETURN INTO DATA(LS_RT) INDEX 1.
      <FSHD>-STATUS    = ICON_LED_RED.
      <FSHD>-MESSAGE = LS_RT-MESSAGE.
      LV_SET_ERR  = GC_X.

    ELSE.
      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
        EXPORTING
          WAIT = GC_X.

      <FSHD>-STATUS    = ICON_LED_GREEN.
      MESSAGE S165 WITH LV_INVNO INTO <FSHD>-MESSAGE.
*      "송장 &1 가 생성 되었습니다.
    ENDIF.
  ENDLOOP.

  IF LINES( GT_RETURN ) > 1.
    CALL FUNCTION 'C14ALD_BAPIRET2_SHOW'
      TABLES
        I_BAPIRET2_TAB = GT_RETURN .
  ENDIF.

  IF LV_SET_ERR NE GC_X.
    PERFORM GET_DATA.
    MESSAGE S000 WITH TEXT-M19 DISPLAY LIKE GC_S.
  ENDIF.


ENDFORM.
*&---------------------------------------------------------------------*
*& FORM SET_REVERSAL_INVOICE.
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
*& -->  P1        TEXT
*& <--  P2        TEXT
*&---------------------------------------------------------------------*
FORM SET_REVERSAL_INVOICE.
  DATA : LV_REV_ERR TYPE CHAR1.
  DATA : LV_MSG    TYPE BAPI_MSG,
         LV_RBELNR TYPE BAPI_INCINV_FLD-INV_DOC_NO,
         LV_RGJAHR TYPE BAPI_INCINV_FLD-FISC_YEAR,
         LT_RETURN TYPE BAPIRET2_T.

  LOOP AT GT_DISP ASSIGNING FIELD-SYMBOL(<FS>) WHERE CHECK = GC_X.
    CLEAR GT_RETURN.

    GV_BUDAT = COND #( WHEN GV_BUDAT IS INITIAL THEN <FS>-BUDAT ELSE GV_BUDAT ).

    TRY.
        CALL FUNCTION 'BAPI_INCOMINGINVOICE_CANCEL'
          EXPORTING
            INVOICEDOCNUMBER          = <FS>-BELNR
            FISCALYEAR                = <FS>-GJAHR
            REASONREVERSAL            = GV_REASON
            POSTINGDATE               = GV_BUDAT
          IMPORTING
            INVOICEDOCNUMBER_REVERSAL = LV_RBELNR
            FISCALYEAR_REVERSAL       = LV_RGJAHR
          TABLES
            RETURN                    = GT_RETURN.
      CATCH CX_ROOT INTO DATA(LV_ERR).
        LV_MSG = LV_ERR->GET_TEXT( ).
        MESSAGE S000 WITH LV_MSG DISPLAY LIKE GC_E. EXIT.
    ENDTRY.

    IF LINE_EXISTS( GT_RETURN[ TYPE = GC_E ] ).
      CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

      IF LINES( GT_RETURN ) > 1.
        INSERT LINES OF CORRESPONDING BAPIRET2_T( GT_RETURN ) INTO TABLE LT_RETURN.
      ENDIF.

      READ TABLE GT_RETURN INTO DATA(LS_RT) INDEX 1.

      <FS>-STATUS    = ICON_LED_RED.
      <FS>-MESSAGE = LS_RT-MESSAGE.

      LV_REV_ERR = GC_X.

    ELSE.
      IF LV_RBELNR IS NOT INITIAL.
        CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
          EXPORTING
            WAIT = GC_X.

        <FS>-STATUS    = ICON_LED_GREEN.
        MESSAGE S164 WITH LV_RBELNR INTO <FS>-MESSAGE.
*      "송장이 &1 로 역분개 되었습니다.
      ENDIF.
    ENDIF.

  ENDLOOP.

  IF LT_RETURN[] IS NOT INITIAL.
     CALL FUNCTION 'C14ALD_BAPIRET2_SHOW'
       TABLES
          I_BAPIRET2_TAB = LT_RETURN .
  ENDIF.

  IF LV_REV_ERR NE GC_X.
    PERFORM GET_DATA.
    MESSAGE S000 WITH TEXT-M20 DISPLAY LIKE GC_S.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& FORM SET_INVOICE
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
*& -->  P1        TEXT
*& <--  P2        TEXT
*&---------------------------------------------------------------------*
FORM SET_INVOICE .

  CLEAR : GV_ERR. "GT_ROWS, GS_ROW, GV_ERR.

*  PERFORM GET_SELECTED_ROWS USING GCL_GRID_HD.
*  CHECK GV_ERR IS INITIAL.

* 세금계산서 수신 지연으로 해당 로직 제외*
*  SELECT FROM ZGTPPT1010
*    FIELDS *
*    WHERE MODULE_KIND = @GC_MM
*         AND CODEGRP = @GC_0820
*         AND FLD_01 = @P_BUKRS
*    INTO TABLE @DATA(LT_1010).
*    SORT LT_1010 BY FLD_02 FLD_03.

  SORT GT_LIST BY CHECK LIFNR BUKRS EKORG WERKS SPMON ASCENDING.

  LOOP AT GT_ITEM ASSIGNING FIELD-SYMBOL(<FS>) .
    IF <FS>-CHECK = GC_X.

      READ TABLE GT_LIST ASSIGNING FIELD-SYMBOL(<HEAD>)
      WITH KEY CHECK  = GC_X
                     LIFNR = <FS>-LIFNR
                     BUKRS = <FS>-BUKRS
                     EKORG = <FS>-EKORG
                     WERKS = <FS>-WERKS
                     SPMON = <FS>-SPMON BINARY SEARCH.

      IF SY-SUBRC = 0 AND <HEAD>-STATUS = ICON_LED_GREEN.
        GV_ERR = GC_X. "이미 생성된 송장입니다.
        MESSAGE S000 WITH TEXT-M18 DISPLAY LIKE GC_E. EXIT.
      ENDIF.

      IF  GV_TARGET_PRICE = 0 OR GV_WRBTR = 0 .
        GV_ERR = GC_X. "송장 처리할 금액을 확인하세요.
        MESSAGE S000 WITH TEXT-M15 DISPLAY LIKE GC_E. EXIT.
      ENDIF.

      IF <FS>-ETIV_WAERS IS INITIAL.
        GV_ERR = GC_X. "외화 송장 처리는 환율을 필수 입력하세요.
        MESSAGE S000 WITH TEXT-M14 DISPLAY LIKE GC_E. EXIT.
      ENDIF.

*공통코드로 관리되는 업체가 아닌 경우, 세금계산서 금액 체크
      CHECK <HEAD> IS ASSIGNED.
*      READ TABLE LT_1010 TRANSPORTING NO FIELDS
*      WITH KEY FLD_02 = <HEAD>-WERKS
*                     FLD_03 = <HEAD>-LIFNR BINARY SEARCH.
*      IF SY-SUBRC <> 0.
*        IF GV_TARGET_PRICE NE GV_TARGET_PRICE2 OR  "공급가액
*           GV_TAXPRICE NE GV_TAXPRICE2 OR "세액
*           GV_WRBTR  NE GV_WRBTR2 . "합계금액
*
*         GV_ERR = GC_X. "세금계산서와 처리 금액이 다릅니다. 점검하세요.
*         MESSAGE S000 WITH TEXT-E16 DISPLAY LIKE GC_E. EXIT.
*        ENDIF.
*      ENDIF.

    ENDIF.
  ENDLOOP.

  SORT GT_LIST BY BUKRS EKORG EKGRP LIFNR SPMON WERKS ASCENDING.
  CHECK GV_ERR IS INITIAL.

  CLEAR : GV_BUDAT, GV_REASON, GV_BDATE, GV_ZTERM.
  GV_QUES = TEXT-M08. "선택된 업체에 대해 송장 처리를 하시겠습니까?
  GV_INFO   = TEXT-M09.  "(마감 월을 확인하고 전기 일자를 입력하세요.)
  GV_BDATE = GV_BUDAT."SY-DATUM. "지급기산일

  CALL SCREEN 0200 STARTING AT 5 10.

ENDFORM.
*&---------------------------------------------------------------------*
*& FORM GET_DATA_ASEL
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
*&      --> LV_GB
*&      <-- GT_ITEM
*&---------------------------------------------------------------------*
FORM GET_DATA_ASEL  USING    PV_GB.

  LOOP AT GT_LIST ASSIGNING FIELD-SYMBOL(<FS>).

    CASE PV_GB.
      WHEN GC_L. "업체 별
        SORT GT_ITEM_BASE BY LIFNR BUKRS EKORG WERKS SPMON .
*LIFNR,BUKRS,EKORG,WERKS(EKGRP)SPMON 기준으로 ITEM구성
        READ TABLE GT_ITEM_BASE TRANSPORTING NO FIELDS
        WITH KEY LIFNR = <FS>-LIFNR
                       BUKRS = <FS>-BUKRS
                       EKORG = <FS>-EKORG
                       WERKS = <FS>-WERKS
                       SPMON = <FS>-SPMON BINARY SEARCH.

        IF SY-SUBRC = 0.
          DATA(LV_TABIX) = SY-TABIX.
          LOOP AT GT_ITEM_BASE INTO DATA(LS_IT) FROM LV_TABIX.

            IF <FS>-LIFNR = LS_IT-LIFNR AND <FS>-BUKRS = LS_IT-BUKRS AND
                <FS>-EKORG = LS_IT-EKORG AND <FS>-WERKS = LS_IT-WERKS
                AND <FS>-SPMON = LS_IT-SPMON.

              LS_IT-CHECK = GC_X.
              APPEND LS_IT TO GT_ITEM.  CLEAR LS_IT.

            ELSE.
              EXIT.
            ENDIF.

          ENDLOOP.
        ENDIF.


      WHEN GC_E."구매그룹 별
        SORT GT_ITEM_BASE BY LIFNR BUKRS EKORG WERKS EKGRP SPMON .
*LIFNR,BUKRS,EKORG,WERKS EKGRP SPMON 기준으로 ITEM구성
        READ TABLE GT_ITEM_BASE TRANSPORTING NO FIELDS
        WITH KEY LIFNR = <FS>-LIFNR
                       BUKRS = <FS>-BUKRS
                       EKORG = <FS>-EKORG
                       WERKS = <FS>-WERKS
                       EKGRP = <FS>-EKGRP
                       SPMON = <FS>-SPMON BINARY SEARCH.

        IF SY-SUBRC = 0.
          LV_TABIX = SY-TABIX.
          LOOP AT GT_ITEM_BASE INTO DATA(LS_ITM) FROM LV_TABIX.

            IF <FS>-LIFNR = LS_IT-LIFNR AND <FS>-BUKRS = LS_IT-BUKRS AND
                <FS>-EKORG = LS_IT-EKORG AND <FS>-WERKS = LS_IT-WERKS
                AND <FS>-EKGRP = LS_IT-EKGRP AND <FS>-SPMON = LS_IT-SPMON.

              LS_ITM-CHECK = GC_X.
              APPEND LS_ITM TO GT_ITEM.  CLEAR LS_ITM.

            ELSE.
              EXIT.
            ENDIF.

          ENDLOOP.
        ENDIF.

      WHEN OTHERS.
    ENDCASE.

  ENDLOOP.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form CALCULATE_TAX
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- LS_LIST
*&---------------------------------------------------------------------*
FORM CALCULATE_TAX   CHANGING PS_LIST LIKE GS_ITEM.

   DATA : LV_WRBTR TYPE BSEG-WRBTR,
              LT_MWDAT LIKE TABLE OF RTAX1U15.

*정산대상 금액
   LV_WRBTR = PS_LIST-TARGET_PRICE.

   IF PS_LIST-RATE = 0.
     CLEAR PS_LIST-TAXPRICE.

   ELSE.
*-정산대상 금액 변경 시 TAX 자동 재계산_변경된 정산대상금액*세율
   CALL FUNCTION 'CALCULATE_TAX_FROM_NET_AMOUNT'
          EXPORTING
            I_BUKRS      = PS_LIST-BUKRS
            I_MWSKZ     = PS_LIST-MWSKZ
            I_WAERS      = PS_LIST-WAERS
            I_WRBTR      = LV_WRBTR
          TABLES
            T_MWDAT    = LT_MWDAT
                  .
   IF LT_MWDAT IS NOT INITIAL.
*금액/세율 계산된 세액
    READ TABLE LT_MWDAT INTO DATA(LS_MW) INDEX 1.
      IF SY-SUBRC = 0.
         PS_LIST-TAXPRICE = LS_MW-WMWST.
         PS_LIST-RATE = LS_MW-MSATZ.
      ENDIF.
   ENDIF.

   ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CALCULATE_PRICE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LS_MOD_CELLS_VALUE
*&      <-- LS_LIST
*&---------------------------------------------------------------------*
FORM CALCULATE_PRICE  USING  PV_GB
                                   CHANGING PS_LIST STRUCTURE GS_ITEM
                                                    PV_VALUE.

DATA : LV_QTY TYPE ZGTMM_CV_GET_TARGET_IV-IV_QTY,
           LV_TPRICE TYPE ZGTMM_CV_GET_TARGET_IV-TARGET_PRICE,
           LV_C_PRICE LIKE  WMTO_S-AMOUNT,
           LV_ETIV TYPE ZGTMM_CV_GET_TARGET_IV-ETIV_PRICE.

 IF PV_GB = GC_Q. "Q-> IV_QTY
*-정산대상 수량 변경 시 정산대상금액 자동계산/변경_(정산대상수량/PER*정산유효단가)
    LV_QTY = PV_VALUE. "입력한 수량
    IF PS_LIST-ETIV_MEINS EQ PS_LIST-IV_UNIT.
      LV_TPRICE = LV_QTY * PS_LIST-ETIV_PRICE .
   ELSE.
      IF PS_LIST-ETIV_MEINS = 'KM' OR PS_LIST-ETIV_MEINS = 'KG'.
             LV_TPRICE = LV_QTY * PS_LIST-ETIV_PRICE  / 1000.
     ELSEIF PS_LIST-ETIV_MEINS = 'M' OR PS_LIST-ETIV_MEINS = 'G'.
            LV_TPRICE = LV_QTY * PS_LIST-ETIV_PRICE  * 1000.
     ENDIF.
   ENDIF.

    PS_LIST-TARGET_PRICE = LV_TPRICE. "정산대상금액
    PS_LIST-IV_OQTY = PV_VALUE / PS_LIST-BPUMN.

 ELSE. "P -> ETIV_PRICE
*-정산유효단가 변경 시 정산대상금액 자동계산/변경_(정산대상수량/PER*정산유효단가)
   CONDENSE PV_VALUE.
 " 1. SAP 내부(100.00) -> 외부/IDOC(100) 변환
   CALL FUNCTION 'CURRENCY_AMOUNT_SAP_TO_IDOC'
     EXPORTING
      CURRENCY      = PS_LIST-WAERS
      SAP_AMOUNT  = PV_VALUE
     IMPORTING
      IDOC_AMOUNT = PV_VALUE. " 결과: 100

   LV_ETIV = PV_VALUE.

   IF PS_LIST-ETIV_MEINS EQ PS_LIST-IV_UNIT.
      LV_TPRICE = PS_LIST-IV_QTY * LV_ETIV .
   ELSE.
      IF PS_LIST-ETIV_MEINS = 'KM' OR PS_LIST-ETIV_MEINS = 'KG'.
         LV_TPRICE = PS_LIST-IV_QTY * LV_ETIV  / 1000.
     ELSEIF PS_LIST-ETIV_MEINS = 'M' OR PS_LIST-ETIV_MEINS = 'G'.
         LV_TPRICE = PS_LIST-IV_QTY * LV_ETIV  * 1000.
     ENDIF.
   ENDIF.

   LV_C_PRICE = LV_TPRICE.

   CALL FUNCTION 'CURRENCY_AMOUNT_DISPLAY_TO_SAP'
     EXPORTING
       CURRENCY               = PS_LIST-WAERS
       AMOUNT_DISPLAY    = LV_C_PRICE
    IMPORTING
       AMOUNT_INTERNAL  = LV_C_PRICE
             .
   IF sy-subrc <> 0.
* Implement suitable error handling here
   ENDIF.

   PS_LIST-TARGET_PRICE = LV_C_PRICE.  "정산대상금액
 ENDIF.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form F4_FOR_VARIANT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_VARI
*&---------------------------------------------------------------------*
FORM F4_FOR_VARIANT  USING    P_VARI.

  CLEAR : GV_EXIT, GS_VARIANT.

  GS_VARIANT-REPORT = SY-REPID.

  CALL FUNCTION 'REUSE_ALV_VARIANT_F4'
    EXPORTING
      IS_VARIANT    = GS_VARIANT
      I_SAVE           = 'A'
    IMPORTING
      E_EXIT           = GV_EXIT
      ES_VARIANT   = GS_VARIANT
    EXCEPTIONS
      NOT_FOUND          = 1
      PROGRAM_ERROR = 2
      OTHERS                = 3.

  IF SY-SUBRC EQ 0 AND GV_EXIT IS INITIAL.
    P_VARI = GS_VARIANT-VARIANT.
  ELSE.
    MESSAGE ID SY-MSGID TYPE 'S' NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form F_SET_GW_XML
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> SY_UNAME
*&      <-- LV_REQXML
*&---------------------------------------------------------------------*
FORM f_set_gw_xml  USING    PV_PERNR  CHANGING CV_REQXML.
  CV_REQXML = |<Root>|.
  CV_REQXML = |{ CV_REQXML }<DOCINFO>|.


  CV_REQXML = |{ CV_REQXML }<DOCTITLE>지급요청  품의</DOCTITLE>|.
  CV_REQXML = |{ CV_REQXML }<TITLE>물대 송장 승인 요청</TITLE>|.
  CV_REQXML = |{ CV_REQXML }<CONTENTSTYPE>HTML</CONTENTSTYPE>|.
  CV_REQXML = |{ CV_REQXML }<CONTENTS></CONTENTS>|.
  CV_REQXML = |{ CV_REQXML }<APPTYPE>OPEN</APPTYPE>|.
  CV_REQXML = |{ CV_REQXML }</DOCINFO>|.


  SELECT SINGLE
    FLD_02
    FROM ZGTPPT1010
    WHERE MODULE_KIND EQ 'MM'
    AND CODEGRP EQ '0021'
    AND FLD_01 EQ @P_BUKRS
    INTO @DATA(LV_FLD02).

  CV_REQXML = |{ CV_REQXML }<MEMBERS><MEMBER>|.
  CV_REQXML = |{ CV_REQXML }<ID>{ LV_FLD02 }{ PV_PERNR }</ID>|.
  CV_REQXML = |{ CV_REQXML }<APPCODE>C101</APPCODE>|.
  CV_REQXML = |{ CV_REQXML }<APPTYPE>AT_C101</APPTYPE>|.
  CV_REQXML = |{ CV_REQXML }</MEMBER></MEMBERS>|.
  CV_REQXML = |{ CV_REQXML }</Root>|.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_TAX_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_TAX_DATA .

  CLEAR : GV_ERR.
  DATA : LR_LIFNR TYPE RANGE OF LFA1-LIFNR.

  IF LINE_EXISTS( GT_LIST[ CHECK = GC_X ] ).
    LOOP AT GT_LIST ASSIGNING FIELD-SYMBOL(<LIST>) WHERE CHECK = GC_X.
*조회조건 설정(선택한 공급업체)
      APPEND VALUE #( SIGN = GC_I OPTION = GC_EQ
                                   LOW = <LIST>-LIFNR ) TO LR_LIFNR.
    ENDLOOP.

    SELECT FROM ZGTMM_CV_GET_TAX_INVOICE
      FIELDS *
      WHERE BUKRS EQ @P_BUKRS
           AND LIFNR   IN @LR_LIFNR
           AND TAXINV IS INITIAL
      INTO CORRESPONDING FIELDS OF TABLE @GT_TAX.

  ELSE.
    GV_ERR = GC_X.  "송장 처리할 대상을 선택하세요.
    MESSAGE S000 WITH TEXT-E06 DISPLAY LIKE GC_E. EXIT.
  ENDIF.

  IF GT_TAX[] IS INITIAL.
    GV_ERR = GC_X.
    MESSAGE S002 DISPLAY LIKE GC_E.
  ENDIF.

  CHECK GV_ERR IS INITIAL.
  CALL SCREEN 0400 STARTING AT 10 5  ENDING AT 130 25.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_CELL_COLOR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_CELL_COLOR.

  DATA:
    LS_COLOR   TYPE  LVC_S_SCOL.

  LOOP AT GT_LIST ASSIGNING FIELD-SYMBOL(<LIST>).
    CLEAR: <LIST>-F_COL, LS_COLOR.
*상태
    LS_COLOR = VALUE #( FNAME = 'STATUS'
                                       COLOR-COL = COND  #( WHEN  <LIST>-STATUS IS INITIAL
                                                                             THEN '3'  ELSE '0' )"흰색(기본)0 / 노랑 3
                                       COLOR-INT = '0'     "색 연하게( 1 : 진하게 )
                                       COLOR-INV = '0' ). "배경색/글자색 반전여부 ( 1: 반전 )
    INSERT LS_COLOR INTO TABLE <LIST>-F_COL.

*    CLEAR LS_COLOR. "여기부터 필요하면 위와 동일하게 추가 구성..필드명만 변경..조건은 주기 나름..
  ENDLOOP.

  LOOP AT GT_ITEM ASSIGNING FIELD-SYMBOL(<ITEM>).
    CLEAR: <ITEM>-F_COL, LS_COLOR.
*입고상태
    LS_COLOR = VALUE #( FNAME = 'TARGET_PRICE'
                                       COLOR-COL = COND  #( WHEN <ITEM>-TARGET_PRICE IS INITIAL
                                                                             THEN '3'  ELSE '5' )"
                                       COLOR-INT = '0'
                                       COLOR-INV = '0' ).
    INSERT LS_COLOR INTO TABLE <ITEM>-F_COL.

*    CLEAR LS_COLOR. "여기부터 필요하면 위와 동일하게 추가 구성..필드명만 변경..조건은 주기 나름..
  ENDLOOP.


**COL 값 표준 색상
**0 : 기본 배경색 (우유색/회색)  COL_BACKGROUND (일반 배경)
**1 : 진한 파란색 / 청회색  COL_HEADING (헤더/타이틀)
**2 : 연한 회색  COL_NORMAL (일반 셀 강조)
**3 : 노란색  COL_TOTAL (합계 / 요약 라인)
**4 : 청록색 / 하늘색  COL_KEY (Key 필드 고정 색상)
**5 : 녹색  COL_POSITIVE (양수 / 성공 / 안전 데이터)
**6 : 빨간색  COL_NEGATIVE (음수 / 에러 / 경고 데이터)
**7 : 주황색 / 자주색  COL_GROUP (제어 레벨 / 그룹화 라인)
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_CELL_COLOR_300
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_CELL_COLOR_300.

  DATA:
    LS_COLOR   TYPE  LVC_S_SCOL.

  LOOP AT GT_DISP ASSIGNING FIELD-SYMBOL(<HEAD>).
    CLEAR: <HEAD>-F_COL, LS_COLOR.
*지급요청_완료 이면, 녹색 아니면 노랑으로 설정 해 봄..
    LS_COLOR = VALUE #( FNAME = 'REQ'
                                       COLOR-COL = COND  #( WHEN  <HEAD>-REQ = ICON_MAIL
                                                                             THEN '5'  ELSE '3' )"녹색 5/노랑 3
                                       COLOR-INT = '0'     "색 연하게( 1 : 진하게 )
                                       COLOR-INV = '0' ). "배경색/글자색 반전여부 ( 1: 반전 )
    INSERT LS_COLOR INTO TABLE <HEAD>-F_COL.

*    CLEAR LS_COLOR. "여기부터 필요하면 위와 동일하게 추가 구성..필드명만 변경..조건은 주기 나름..
  ENDLOOP.

*  LOOP AT GT_DISP_IT ASSIGNING FIELD-SYMBOL(<ITEM>).
*    CLEAR: <ITEM>-F_COL, LS_COLOR.
**입고상태
*    LS_COLOR = VALUE #( FNAME = ''
*                                       COLOR-COL = COND  #( WHEN <ITEM>-
*                                                                             THEN '5'  ELSE '3' )"녹색 5/노랑 3
*                                       COLOR-INT = '0'     "색 연하게( 1 : 진하게 )
*                                       COLOR-INV = '0' ). "배경색/글자색 반전여부 ( 1: 반전 )
*    INSERT LS_COLOR INTO TABLE <ITEM>-F_COL.
*
**    CLEAR LS_COLOR. "여기부터 필요하면 위와 동일하게 추가 구성..필드명만 변경..조건은 주기 나름..
*
*  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_CELL_COLOR_400
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_CELL_COLOR_400.

  DATA:
    LS_COLOR   TYPE  LVC_S_SCOL.

  LOOP AT GT_TAX ASSIGNING FIELD-SYMBOL(<HEAD>).
    CLEAR: <HEAD>-F_COL, LS_COLOR.
*입고상태_완료 이면, 녹색 아니면 노랑으로 설정 해 봄..
    LS_COLOR = VALUE #( FNAME = 'TAXTOTAL'
                                       COLOR-COL = COND  #( WHEN  <HEAD>-TAXTOTAL IS INITIAL
                                                                             THEN '3'  ELSE '0' )"기본(하얀색) 0/노랑 3
                                       COLOR-INT = '0'     "색 연하게( 1 : 진하게 )
                                       COLOR-INV = '0' ). "배경색/글자색 반전여부 ( 1: 반전 )
    INSERT LS_COLOR INTO TABLE <HEAD>-F_COL.

*    CLEAR LS_COLOR. "여기부터 필요하면 위와 동일하게 추가 구성..필드명만 변경..조건은 주기 나름..
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_DE_MAPPING_SGTXT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_DE_MAPPING_SGTXT USING PV_GB.

  CLEAR : GV_ERR.
  DATA : LT_DISP LIKE TABLE OF GS_DISP,
             LV_TYPE TYPE BAPI_MTYPE,
             LV_MSG TYPE BAPI_MSG,
             LV_MESSAGE TYPE BAPI_MSG.

  IF LINE_EXISTS( GT_DISP[ CHECK = GC_X ] ).

    LOOP AT GT_DISP ASSIGNING FIELD-SYMBOL(<DISP>) WHERE CHECK = GC_X.
*세금계산서 매핑 번호 유무 체크
      IF <DISP>-SGTXT IS INITIAL.
         GV_ERR = GC_X.
         LV_MESSAGE = COND #( WHEN PV_GB = GC_M THEN TEXT-E18 ELSE TEXT-E21 ).
         "세금계산서 번호는 필수 입력입니다. PV_GB = 'M'  "매핑
         "세금계산서 번호 매핑되지 않은 정보는 해제 대상이 아닙니다. "매핑해제
         MESSAGE S000 WITH LV_MESSAGE DISPLAY LIKE GC_E. EXIT.
      ELSE.
        <DISP>-SGTXT = COND #( WHEN PV_GB = GC_M THEN <DISP>-SGTXT
                                                 ELSE SPACE ).
      ENDIF.

      IF <DISP>-REQPAY = GC_X .
         GV_ERR = GC_X.  "결재 진행 중인 데이터는 변경 불가합니다.
         MESSAGE S000 WITH TEXT-E19 DISPLAY LIKE GC_E. EXIT.
      ENDIF.
    ENDLOOP.

    IF GV_ERR IS INITIAL.
      APPEND <DISP> TO LT_DISP.
    ENDIF.

  ELSE.
    GV_ERR = GC_X.  "처리 대상을 선택하세요.
    MESSAGE S000 WITH TEXT-E17 DISPLAY LIKE GC_E. EXIT.
  ENDIF.

  CHECK GV_ERR IS INITIAL.
  CHECK LT_DISP[] IS NOT INITIAL.

  LOOP AT LT_DISP ASSIGNING FIELD-SYMBOL(<LDISP>).

    CHECK GV_ERR IS INITIAL.
    CHECK <LDISP> IS ASSIGNED.

    CALL FUNCTION 'ZGTFI_CHANGE_DOC_TEXT'
      EXPORTING
        I_BUKRS        = P_BUKRS
        I_BELNR        = <LDISP>-BELNR_BKPF
        I_GJAHR         = <LDISP>-GJAHR_BKPF
        I_SGTXT        = <LDISP>-SGTXT
      IMPORTING
        E_RESULT     = LV_TYPE
        E_MESSAGE  = LV_MSG
              .
    IF LV_TYPE IS INITIAL OR LV_TYPE NE GC_S.
      DATA(LV_SGTXT) = <LDISP>-SGTXT.
      GV_ERR = GC_X. EXIT.
    ENDIF.

  ENDLOOP.

  WAIT UP TO 1 SECONDS.
  CLEAR LV_MESSAGE.

  IF GV_ERR IS INITIAL.
    PERFORM GET_DATA.
*    세금계산서 매핑/매핑해제 완료.
    LV_MESSAGE = COND #( WHEN PV_GB = GC_M THEN TEXT-E23 ELSE TEXT-E24 ).
    MESSAGE S000 WITH LV_MESSAGE.

  ELSE.
"세금계산서 매핑/매핑해제에 실패하였습니다. - &1
    LV_MESSAGE = COND #( WHEN PV_GB = GC_M THEN TEXT-E22 ELSE TEXT-E20 ).
    MESSAGE S000 WITH LV_MESSAGE LV_SGTXT DISPLAY LIKE GC_E. EXIT.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_TAX_ADJUST
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_TAX_ADJUST .

  CLEAR : GV_ERR.

  PERFORM GET_SELECTED_ROWS USING GCL_GRID_IT.
  CHECK GV_ERR IS INITIAL.
  CHECK GT_ITEM[] IS NOT INITIAL.

  LOOP AT GT_ROWS INTO DATA(LS_ROW).
*선택된 블럭의 모든 라인 '정산대상TAX(TAXPRICE)'필드에 +1원 씩 조정
    READ TABLE GT_ITEM ASSIGNING FIELD-SYMBOL(<TAX>) INDEX LS_ROW-INDEX.
    IF SY-SUBRC = 0.
      <TAX>-CHECK = GC_X.
      CHECK <TAX>-WAERS = 'KRW'.
      <TAX>-TAXPRICE = <TAX>-TAXPRICE + '0.01'.
    ENDIF.
  ENDLOOP.

***총 공급가액,세액,합계금액 변경 반영_헤더 스크린 필드.
  PERFORM SET_CHECK_AMT.

ENDFORM.
