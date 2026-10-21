*&---------------------------------------------------------------------*
*& INCLUDE          ZGTMMR3000F01
*&---------------------------------------------------------------------*
TYPES:
  TY_T_ALSMEX_LINE TYPE STANDARD TABLE OF ALSMEX_TABLINE.

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
            DISPLAY_ALV TABLES GT_LIST GT_FCAT.


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
      WHEN 'STATUS'. "상태
        _FCAT TEXT-F01.
        <FS_S_FCT>-JUST = 'C'.

      WHEN 'LIFNR'.     "공급업체
        _FCAT TEXT-F16.
        <FS_S_FCT>-EDIT = COND  #( WHEN P_CRE = GC_X THEN GC_X ELSE '' ).
        <FS_S_FCT>-JUST = 'C'.
        <FS_S_FCT>-F4AVAILABL  = GC_X.
        <FS_S_FCT>-REF_TABLE   = 'LFA1'.
        <FS_S_FCT>-REF_FIELD   = 'LIFNR'.

      WHEN 'LIFNR_N'.    "업체명
        _FCAT TEXT-F17.
        <FS_S_FCT>-JUST = 'C'.
        <FS_S_FCT>-EMPHASIZE = 'C310'.

      WHEN 'MATNR'.        "자재코드
        _FCAT TEXT-F20.
        <FS_S_FCT>-EDIT = COND  #( WHEN P_CRE = GC_X THEN GC_X ELSE '' ).
        <FS_S_FCT>-JUST = 'C'.
        <FS_S_FCT>-F4AVAILABL  = GC_X.
        <FS_S_FCT>-REF_TABLE   = 'MARA'.
        <FS_S_FCT>-REF_FIELD   = 'MATNR'.


      WHEN 'MATNR_N'.        "자재명
        _FCAT TEXT-F21.
        <FS_S_FCT>-JUST = 'C'.
        <FS_S_FCT>-EMPHASIZE = 'C410'.

      WHEN 'EKORG'.       "구매조직
        _FCAT TEXT-F10.
        <FS_S_FCT>-EDIT = COND  #( WHEN P_CRE = GC_X THEN GC_X ELSE '' ).
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'EKORG_N'.  "구매조직명
        _FCAT TEXT-F11.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'WERKS'.       "플랜트
        _FCAT TEXT-F02.
        <FS_S_FCT>-EDIT = COND  #( WHEN P_CRE = GC_X THEN GC_X ELSE '' ).
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'WERKS_N'.  "플랜트명
        _FCAT TEXT-F03.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'ESOKZ'.     "인포유형/특별지시자(구매)
        _FCAT TEXT-F18.
        <FS_S_FCT>-EDIT = COND  #( WHEN P_CRE = GC_X THEN GC_X ELSE '' ).
        <FS_S_FCT>-F4AVAILABL = GC_X.
        <FS_S_FCT>-REF_TABLE = 'EINE'.
        <FS_S_FCT>-REF_FIELD  = 'ESOKZ'.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'ESOKZ_N'.   "유형명
        _FCAT TEXT-F19.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'EINE_LOEKZ'.
        _FCAT '삭제'.
        <FS_S_FCT>-EDIT = COND #( WHEN P_DIS = GC_X THEN GC_X ELSE '' ).
        <FS_S_FCT>-NO_OUT = COND #( WHEN P_CRE = GC_X THEN GC_X ELSE '' ).
        <FS_S_FCT>-CHECKBOX = GC_X.
      WHEN 'EKGRP'.      "구매그룹
        _FCAT TEXT-F08.
        <FS_S_FCT>-EDIT = COND #( WHEN P_CHG = GC_X THEN '' ELSE GC_X ).
        <FS_S_FCT>-F4AVAILABL = GC_X.
        <FS_S_FCT>-REF_TABLE = 'T024'.
        <FS_S_FCT>-REF_FIELD  = 'EKGRP'.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'EKGRP_N'.     "구매그룹명
        _FCAT TEXT-F09.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'APLFZ'.        "계획납품일
        _FCAT TEXT-F04.
        <FS_S_FCT>-EDIT = COND #( WHEN P_CHG = GC_X THEN '' ELSE GC_X ).
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'NORBM'.     " 표준PO수량
        _FCAT TEXT-F05.
        <FS_S_FCT>-EDIT = COND #( WHEN P_CHG = GC_X THEN '' ELSE GC_X ).
        <FS_S_FCT>-JUST = 'R'.
      WHEN 'MEINS'.        "단위
        _FCAT TEXT-F28.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'UEBTO'.  "초과허용%
        _FCAT TEXT-F22.
        <FS_S_FCT>-EDIT = COND #( WHEN P_CHG = GC_X THEN '' ELSE GC_X ).
        <FS_S_FCT>-JUST = 'R'.
      WHEN 'UNTTO'.     "미달허용%
        _FCAT TEXT-F23.
        <FS_S_FCT>-EDIT = COND #( WHEN P_CHG = GC_X THEN '' ELSE GC_X ).
        <FS_S_FCT>-JUST = 'R'.
      WHEN 'UEBTK'.     "무제한납품
        _FCAT TEXT-F24.
        <FS_S_FCT>-EDIT = COND #( WHEN P_CHG = GC_X THEN '' ELSE GC_X ).
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'VERID'.        "임가공버전
        _FCAT TEXT-F25.
        <FS_S_FCT>-EDIT = COND #( WHEN P_CHG = GC_X THEN '' ELSE GC_X ).
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'WEBRE'.        "GR기준IV
        _FCAT TEXT-F26.
        <FS_S_FCT>-EDIT = COND #( WHEN P_CHG = GC_X THEN '' ELSE GC_X ).
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'XERSN'.        "NO ERS
        _FCAT TEXT-F29.
        <FS_S_FCT>-EDIT = COND #( WHEN P_CHG = GC_X THEN '' ELSE GC_X ).
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'BSTAE'.        "확정관리
        _FCAT TEXT-F33.
        <FS_S_FCT>-EDIT = COND #( WHEN P_CHG = GC_X THEN '' ELSE GC_X ).
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'BSTAE_N'.        "확정관리명
        _FCAT TEXT-F35.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'DATAB'.        "단가 FROM
        _FCAT TEXT-F37.
        <FS_S_FCT>-EDIT = COND  #( WHEN P_CRE = GC_X THEN GC_X ELSE '' ).
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'DATBI'.        "단가 TO
        _FCAT TEXT-F38.
        <FS_S_FCT>-EDIT = COND  #( WHEN P_CRE = GC_X THEN GC_X ELSE '' ).
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'KBETR'.        "단가
        _FCAT TEXT-F31.
        <FS_S_FCT>-CFIELDNAME = 'KONWA'.
        <FS_S_FCT>-EDIT = COND  #( WHEN P_CRE = GC_X THEN GC_X ELSE '' ).
        <FS_S_FCT>-JUST = 'R'.
        <FS_S_FCT>-EMPHASIZE = 'C300'.
      WHEN 'KPEIN'.        "PER
        _FCAT TEXT-F32.
        <FS_S_FCT>-EDIT = COND  #( WHEN P_CRE = GC_X THEN GC_X ELSE '' ).
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'KMEIN'.        "단가단위
        _FCAT TEXT-F87.
        <FS_S_FCT>-EDIT = COND  #( WHEN P_CRE = GC_X THEN GC_X ELSE '' ).
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'KONWA'.        "통화
        _FCAT TEXT-F34.
        <FS_S_FCT>-EDIT = COND  #( WHEN P_CRE = GC_X THEN GC_X ELSE '' ).
        <FS_S_FCT>-JUST = 'C'.
        <FS_S_FCT>-EMPHASIZE = 'C300'.
      WHEN 'ZFR1'.        "수입운임
        _FCAT TEXT-F83.
        <FS_S_FCT>-CFIELDNAME = 'ZFR1_UNIT'.
        <FS_S_FCT>-EDIT = COND  #( WHEN P_CRE = GC_X THEN GC_X ELSE '' ).
        <FS_S_FCT>-JUST = 'R'.
      WHEN 'ZFR1_UNIT'.        "단위
        _FCAT TEXT-F84.
        <FS_S_FCT>-NO_OUT  = GC_X.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'ZFR2'.        "수입제비용
        _FCAT TEXT-F85.
        <FS_S_FCT>-CFIELDNAME = 'ZFR2_UNIT'.
        <FS_S_FCT>-EDIT = COND  #( WHEN P_CRE = GC_X THEN GC_X ELSE '' ).
        <FS_S_FCT>-JUST = 'R'.
      WHEN 'ZFR2_UNIT'.        "통화
        _FCAT TEXT-F84.
        <FS_S_FCT>-NO_OUT  = GC_X.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'DATAB_I'.        "단가 FROM "P_DIS일 경우에만 노출_단가변경
        _FCAT TEXT-F37.
        <FS_S_FCT>-EDIT = GC_X.
        <FS_S_FCT>-TECH = COND #( WHEN P_DIS = GC_X THEN '' ELSE GC_X ).
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'DATBI_I'.        "단가 TO  "P_DIS일 경우에만 노출
        _FCAT TEXT-F38.
        <FS_S_FCT>-EDIT = GC_X.
        <FS_S_FCT>-TECH = COND #( WHEN P_DIS = GC_X THEN '' ELSE GC_X ).
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'KBETR_I'.        " 단가 "P_DIS일 경우에만 노출_단가변경
        _FCAT TEXT-F31.
        <FS_S_FCT>-CFIELDNAME = 'KONWA'.
        <FS_S_FCT>-EDIT = GC_X.
        <FS_S_FCT>-TECH = COND #( WHEN P_DIS = GC_X THEN '' ELSE GC_X ).
        <FS_S_FCT>-JUST = 'R'.
      WHEN 'KPEIN_I'.        "PER "P_DIS일 경우에만 노출
        _FCAT TEXT-F32.
        <FS_S_FCT>-EDIT = GC_X.
        <FS_S_FCT>-TECH = COND #( WHEN P_DIS = GC_X THEN '' ELSE GC_X ).
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'KMEIN_I'.    "단위"P_DIS일 경우에만 노출
        _FCAT TEXT-F28.
        <FS_S_FCT>-EDIT = GC_X.
        <FS_S_FCT>-TECH = COND #( WHEN P_DIS = GC_X THEN '' ELSE GC_X ).
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'ZFR1_I'.        "수입운임
        _FCAT TEXT-F83.
        <FS_S_FCT>-CFIELDNAME = 'ZFR1_UNIT_I'.
        <FS_S_FCT>-EDIT = GC_X.
        <FS_S_FCT>-TECH = COND #( WHEN P_DIS = GC_X THEN '' ELSE GC_X ).
        <FS_S_FCT>-JUST = 'R'.
      WHEN 'ZFR1_UNIT_I'.        "단위
        _FCAT TEXT-F84.
        <FS_S_FCT>-EDIT = GC_X.
        <FS_S_FCT>-TECH = COND #( WHEN P_DIS = GC_X THEN '' ELSE GC_X ).
        <FS_S_FCT>-NO_OUT  = GC_X.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'ZFR2_I'.        "수입제비용
        _FCAT TEXT-F85.
        <FS_S_FCT>-CFIELDNAME = 'ZFR2_UNIT_I'.
        <FS_S_FCT>-EDIT = GC_X.
        <FS_S_FCT>-TECH = COND #( WHEN P_DIS = GC_X THEN '' ELSE GC_X ).
        <FS_S_FCT>-JUST = 'R'.
      WHEN 'ZFR2_UNIT_I'.        "통화
        _FCAT TEXT-F84.
        <FS_S_FCT>-EDIT = GC_X.
        <FS_S_FCT>-TECH = COND #( WHEN P_DIS = GC_X THEN '' ELSE GC_X ).
        <FS_S_FCT>-NO_OUT  = GC_X.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'MWSKZ'.        "TAX
        _FCAT TEXT-F36.
        <FS_S_FCT>-EDIT = COND #( WHEN P_CHG = GC_X THEN '' ELSE GC_X ).
        <FS_S_FCT>-F4AVAILABL = GC_X.
        <FS_S_FCT>-REF_TABLE = 'EKPO'.
        <FS_S_FCT>-REF_FIELD  = 'MWSKZ'.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'MWSKZ_N'.     "TAX명
        _FCAT TEXT-F39.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'MEPRF'.     "가격결정일
        _FCAT TEXT-F40.
        <FS_S_FCT>-EDIT = COND  #( WHEN P_CRE = GC_X THEN GC_X ELSE '' ).
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'INCO1'.        " 인도조건
        _FCAT TEXT-F41.
        <FS_S_FCT>-EDIT = COND  #( WHEN P_CRE = GC_X THEN GC_X ELSE '' ).
        <FS_S_FCT>-F4AVAILABL = GC_X.
        <FS_S_FCT>-REF_TABLE = 'TINC'.
        <FS_S_FCT>-REF_FIELD  = 'INCO1'.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'INCO1_N'.        " 조건명
        _FCAT TEXT-F42.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'KALSK'.   "승인대상
        _FCAT TEXT-F86.
        <FS_S_FCT>-NO_OUT = GC_X.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'ZYN'.     "승인대상
        _FCAT TEXT-F45.
        <FS_S_FCT>-NO_OUT = GC_X.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'S1'.     "
        _FCAT TEXT-F43.   "승인대상(RELEASE)
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'APPROVED'.     "승인상태
        _FCAT TEXT-F46.
        <FS_S_FCT>-NO_OUT = GC_X.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'S2'.            "승인대상(EMAIL)
        _FCAT TEXT-F44.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'MESSAGE'.   "메시지
        _FCAT TEXT-F68.
        <FS_S_FCT>-JUST = 'C'.
      WHEN OTHERS.
        <FS_S_FCT>-NO_OUT  = GC_X.

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
                       ZEBRA  = GC_X
                       SEL_MODE    = GC_A
                       CWIDTH_OPT  = GC_A
                       STYLEFNAME = 'STYLE'
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

  IF P_DIS = GC_X.
    PERFORM SET_CELL_STYLE USING 'DIS'.
  ELSEIF P_CRE = GC_X.
    PERFORM SET_CELL_STYLE USING 'CRE'.
  ENDIF.

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
FORM DISPLAY_ALV TABLES PT_LIST PT_FCAT.

  DATA(LS_VARINT) = VALUE DISVARIANT( REPORT  = SY-CPROG
                                           HANDLE  = COND #( WHEN P_DIS = GC_X THEN '0001'
                                                                          WHEN P_CRE = GC_X THEN '0002'
                                                                          WHEN P_CHG = GC_X THEN '0003' ELSE '0004' ) ).

  CALL METHOD GCL_GRID->SET_TABLE_FOR_FIRST_DISPLAY
    EXPORTING
      IS_LAYOUT            = GS_LAYOUT
      IT_TOOLBAR_EXCLUDING = GT_EXCLUD[]
      IS_VARIANT           = LS_VARINT
      I_SAVE                  = ZGTFI_A
    CHANGING
      IT_OUTTAB            = PT_LIST[] "GT_LIST[]
      IT_FIELDCATALOG  = PT_FCAT[]
      IT_SORT                = GT_SORT[]
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

DATA: lt_values TYPE TABLE OF USVALUES,
      ls_values TYPE USVALUES.

  CLEAR : P_DATS. "생성일
  P_DATS = SY-DATLO.

  CLEAR:
    GT_T001W[],
*    GT_T001L[],
    GT_T024E[],
    GT_T024[].

*  SELECT
*    MATKL,
*    WGBEZ
*    FROM T023T
*    WHERE SPRAS EQ @SY-LANGU
*    INTO TABLE @GT_T023T.

  SELECT
    WERKS,
    NAME1
    FROM T001W
    INTO TABLE @GT_T001W.

*  SELECT
*    WERKS,
*    LGORT,
*    LGOBE
*    FROM T001L
*    INTO TABLE @GT_T001L.

  SELECT
    EKORG,
    EKOTX
    FROM T024E
    INTO TABLE @GT_T024E.

  SELECT
    EKGRP,
    EKNAM
    FROM T024
    INTO TABLE @GT_T024.

*DOMAIN VALUE
  CALL FUNCTION 'GET_DOMAIN_VALUES'
    EXPORTING
      DOMNAME    = 'ESOKZ'
    TABLES
      VALUES_TAB = GT_ESOKZ.
  SORT GT_ESOKZ BY DOMVALUE_L DDTEXT.


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
      " 2. 권한 필드(예: WERKS)의 값을 추출하여 Select-options에 매핑
      READ TABLE LT_VALUES INTO LS_VALUES WITH KEY FIELD = 'EKORG'.
      IF SY-SUBRC EQ 0. P_EKORG = LS_VALUES-VON. ENDIF.

      READ TABLE LT_VALUES INTO LS_VALUES WITH KEY FIELD = 'WERKS'.
      IF SY-SUBRC EQ 0. P_WERKS = LS_VALUES-VON. ENDIF.

      READ TABLE LT_VALUES INTO LS_VALUES WITH KEY FIELD = 'EKGRP'.
      IF SY-SUBRC EQ 0. P_EKGRP = LS_VALUES-VON. ENDIF.


    ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*& FORM INPUT_VALIDATION
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
FORM INPUT_VALIDATION.

  CLEAR : GT_LIST, GV_ERR.

  IF P_DIS EQ GC_X AND P_DATS IS INITIAL.
    MESSAGE S000 WITH TEXT-E03 DISPLAY LIKE GC_E.
    GV_ERR = GC_X. STOP. "가격기준일은 필수 입력입니다.
  ENDIF.

  IF P_CHG = GC_X AND S_WERKS-LOW IS INITIAL.
    MESSAGE S000 WITH TEXT-E06 DISPLAY LIKE GC_E.
    GV_ERR = GC_X. STOP.
    "플랜트는 필수 입력입니다.
  ENDIF.

  IF  S_WERKS-LOW IS NOT INITIAL.
    LOOP AT S_WERKS INTO DATA(LS_WERKS).

      READ TABLE GT_T001W TRANSPORTING NO FIELDS
      WITH TABLE KEY WERKS = LS_WERKS-LOW.

*      SELECT SINGLE 1
*       FROM T001W
*       WHERE WERKS EQ @LS_WERKS-LOW
*        INTO @DATA(LV_EXST).

      IF SY-SUBRC <> 0.
        MESSAGE S000 WITH TEXT-M01 DISPLAY LIKE GC_E.
        GV_ERR = GC_X. STOP. "유효하지 않은 플랜트 입니다.
      ENDIF.

    ENDLOOP.
  ENDIF.

  IF P_WERKS IS NOT INITIAL.

    READ TABLE GT_T001W TRANSPORTING NO FIELDS
    WITH TABLE KEY WERKS = P_WERKS.

    IF SY-SUBRC <> 0.
      MESSAGE S000 WITH TEXT-M01 DISPLAY LIKE GC_E.
      GV_ERR = GC_X. STOP. "유효하지 않은 플랜트 입니다.
    ENDIF.

  ENDIF.

  IF  S_EKGRP-LOW IS INITIAL.
*    IF P_DIS = GC_X.
*      MESSAGE S000 WITH TEXT-E08 DISPLAY LIKE GC_E.
*      GV_ERR = GC_X. STOP. "구매그룹은 필수 입력입니다.
*    ENDIF.

  ELSE.
    LOOP AT S_EKGRP INTO DATA(LS_EKGRP).

      READ TABLE GT_T024 TRANSPORTING NO FIELDS
      WITH TABLE KEY EKGRP = LS_EKGRP-LOW.
*      SELECT SINGLE 1
*       FROM T024
*       WHERE EKGRP EQ @LS_EKGRP-LOW
*        INTO @LV_EXST.

      IF SY-SUBRC <> 0.
        MESSAGE S000 WITH TEXT-M02 DISPLAY LIKE GC_E.
        GV_ERR = GC_X.  STOP. "유효하지 않은 구매그룹 입니다.
      ENDIF.

    ENDLOOP.
  ENDIF.

  IF P_EKGRP IS NOT INITIAL.

    READ TABLE GT_T024 TRANSPORTING NO FIELDS
    WITH TABLE KEY EKGRP = P_EKGRP.
*    SELECT SINGLE 1
*     FROM T024
*     WHERE EKGRP EQ @P_EKGRP
*      INTO @LV_EXST.

    IF SY-SUBRC <> 0.
      MESSAGE S000 WITH TEXT-M02 DISPLAY LIKE GC_E.
      GV_ERR = GC_X.  STOP. "유효하지 않은 구매그룹 입니다.
    ENDIF.
  ENDIF.

  IF S_LIFNR[] IS NOT INITIAL.
    LOOP AT S_LIFNR INTO DATA(LS_LIFNR).

      SELECT SINGLE 1
      FROM LFA1
      WHERE LIFNR EQ @LS_LIFNR-LOW
      INTO @DATA(LV_EXST).

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


ENDFORM.

*&---------------------------------------------------------------------*
*& FORM CHECK_AUTH
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
FORM CHECK_AUTH .

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

  AUTHORITY-CHECK OBJECT 'ZCBO_MM001'
               ID 'EKGRP' FIELD P_WERKS.

  CHECK SY-SUBRC <> 0.

  SET CURSOR FIELD 'P_EKGRP'.
  MESSAGE E171 WITH P_EKGRP. "구매그룹 [&] 작업권한을 확인하세요.

ENDFORM.
*&---------------------------------------------------------------------*
*& FORM SELECTION_SCREEN_OUTPUT
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
FORM SELECTION_SCREEN_OUTPUT .

  LOOP AT SCREEN.

    IF  SCREEN-NAME = '%B003021_BLOCK_1000'. "삭제정보조회 옵션 블럭제어
      "조회및 변경/단가변경이력조회일 경우 활성
      SCREEN-ACTIVE = COND #( WHEN P_CRE = GC_X THEN 0 ELSE 1 ).
    ENDIF.

    IF  SCREEN-GROUP1 = 'CDP'. "조회및 변경/단가변경이력조회일 경우 활성
      SCREEN-ACTIVE = COND #( WHEN P_CRE = GC_X THEN 0 ELSE 1 ).
    ENDIF.

    IF  SCREEN-GROUP1 = 'CRA'. "조회및변경일 경우 활성
      SCREEN-ACTIVE = COND #( WHEN P_DIS = GC_X THEN 1 ELSE 0 ).
    ENDIF.

    IF  SCREEN-GROUP1 = 'CRE'. "조회및변경/생성일 경우 활성
      SCREEN-ACTIVE = COND #( WHEN P_DIS = GC_X  OR P_CRE = GC_X THEN 1 ELSE 0 ).
    ENDIF.

    IF  SCREEN-GROUP1 = 'DIS'.
      SCREEN-ACTIVE = COND #( WHEN P_CHG = GC_X THEN 1 ELSE 0 ).
    ENDIF.

    MODIFY SCREEN.

  ENDLOOP.



ENDFORM.

*&---------------------------------------------------------------------*
*& FORM GET_DATA
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
FORM GET_DATA .

  CLEAR : GV_ERR, GT_LIST,  GT_LIST[].

**데이터 가져오기
  CASE GC_X.
    WHEN P_DIS.
      IF P_DEL = GC_X.
        SELECT FROM ZGTMM_CV_GET_INFOPRICE
        FIELDS *
        WHERE EKORG = @P_EKORG
         AND WERKS =  @P_WERKS
         AND EKGRP = @P_EKGRP
         AND ESOKZ IN @S_ESOKZ
         AND LIFNR IN @S_LIFNR
         AND MATNR IN @S_MATNR
         AND DATAB <= @P_DATS
         AND DATBI >= @P_DATS
         AND EINE_LOEKZ IS INITIAL
        INTO CORRESPONDING FIELDS OF TABLE @GT_LIST.

      ELSE.
        SELECT FROM ZGTMM_CV_GET_INFOPRICE
        FIELDS *
        WHERE EKORG = @P_EKORG
         AND WERKS =  @P_WERKS
         AND EKGRP = @P_EKGRP
         AND ESOKZ IN @S_ESOKZ
         AND LIFNR IN @S_LIFNR
         AND MATNR IN @S_MATNR
         AND DATAB <= @P_DATS
         AND DATBI >= @P_DATS
        INTO CORRESPONDING FIELDS OF TABLE @GT_LIST.
      ENDIF.

      SORT GT_LIST BY EKORG WERKS MATNR LIFNR ESOKZ.

    WHEN P_CRE. "생성
      READ TABLE GT_T024E INTO DATA(LS_E) WITH TABLE KEY EKORG = P_EKORG.
      READ TABLE GT_T001W INTO DATA(LS_W) WITH TABLE KEY WERKS = P_WERKS.
      READ TABLE GT_T024 INTO DATA(LS_G) WITH TABLE KEY EKGRP = P_EKGRP.

      DO 100 TIMES.
        APPEND VALUE #( EKORG = P_EKORG
                                     EKORG_N = LS_E-EKOTX
                                     WERKS = P_WERKS
                                     WERKS_N = LS_W-NAME1
                                     EKGRP = P_EKGRP
                                     EKGRP_N = LS_G-EKNAM ) TO GT_LIST.
      ENDDO.

    WHEN P_CHG. "단가변경이력조회
      SELECT FROM ZGTMM_CV_GET_INFOPRICE
      FIELDS *
      WHERE EKORG = @P_EKORG
         AND WERKS IN @S_WERKS
         AND EKGRP IN @S_EKGRP
         AND ESOKZ IN @S_ESOKZ
         AND LIFNR IN @S_LIFNR
         AND MATNR IN @S_MATNR
        INTO CORRESPONDING FIELDS OF TABLE @GT_LIST.

      SORT GT_LIST BY EKORG WERKS MATNR LIFNR ESOKZ DATAB.

    WHEN OTHERS.
  ENDCASE.

  IF GT_LIST[] IS INITIAL.
    GV_ERR = GC_X. "조회 조건에 일치하는 정보가 없습니다.
    MESSAGE S000 WITH TEXT-E01. EXIT.
  ENDIF.

  CHECK GV_ERR IS INITIAL.

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
*      I_SOFT_REFRESH = PV_SOFT_REFRESH
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

  IF P_DIS = GC_X.
    PERFORM SET_CELL_STYLE USING 'DIS'.
  ELSEIF P_CRE = GC_X.
    PERFORM SET_CELL_STYLE USING 'CRE'.
  ENDIF.

  CALL METHOD CL_GUI_CFW=>SET_NEW_OK_CODE
    EXPORTING
      NEW_CODE = 'ENTER'.

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

*  PERFORM REFRESH_TABLE USING PO_SENDER SPACE.
*
*  CALL METHOD CL_GUI_CFW=>SET_NEW_OK_CODE
*    EXPORTING
*      NEW_CODE = 'ENTER'.


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

  GCL_GRID->SET_READY_FOR_INPUT( 1 ). "입력가능

  LOOP AT GT_LIST ASSIGNING FIELD-SYMBOL(<LS_LIST>).
    CLEAR : <LS_LIST>-STYLE[].

    IF P_DIS = GC_X.
      _SET_STYLE : GC_E 'EKGRP' <LS_LIST>-STYLE, "ENABLE
                            GC_E 'EINE_LOEKZ' <LS_LIST>-STYLE, "ENABLE
                            GC_D 'LIFNR' <LS_LIST>-STYLE,    "DISABLED
                            GC_D 'MATNR' <LS_LIST>-STYLE,
                            GC_D 'EKORG' <LS_LIST>-STYLE,
                            GC_D 'WERKS' <LS_LIST>-STYLE,
                            GC_D 'ESOKZ' <LS_LIST>-STYLE,
                            GC_D 'DATAB' <LS_LIST>-STYLE,
                            GC_D 'DATBI'  <LS_LIST>-STYLE,
                            GC_D 'KBETR' <LS_LIST>-STYLE,
                            GC_D 'KPEIN' <LS_LIST>-STYLE,
                            GC_D 'KMEIN' <LS_LIST>-STYLE,
                            GC_D 'KONWA' <LS_LIST>-STYLE.

    ELSEIF P_CRE = GC_X.
      _SET_STYLE : GC_D 'EKGRP' <LS_LIST>-STYLE,"DISABLED
                            GC_E 'LIFNR' <LS_LIST>-STYLE,  "ENABLED
                            GC_E 'MATNR' <LS_LIST>-STYLE,
                            GC_E 'EKORG' <LS_LIST>-STYLE,
                            GC_E 'WERKS' <LS_LIST>-STYLE,
                            GC_E 'ESOKZ' <LS_LIST>-STYLE.
    ENDIF.

    "조회/생성 공통 편집가능 필드
    _SET_STYLE : GC_E 'APLFZ' <LS_LIST>-STYLE,  "ENABLED
                          GC_E 'NORBM' <LS_LIST>-STYLE,  "
                          GC_E 'UEBTO' <LS_LIST>-STYLE,
                          GC_E 'UNTTO' <LS_LIST>-STYLE,
                          GC_E 'UEBTK' <LS_LIST>-STYLE,
                          GC_E 'WEBRE' <LS_LIST>-STYLE,
                          GC_E 'XERSN' <LS_LIST>-STYLE,
                          GC_E 'BSTAE' <LS_LIST>-STYLE,
                          GC_E 'MWSKZ' <LS_LIST>-STYLE,
                          GC_E 'MEPRF' <LS_LIST>-STYLE,
                          GC_E 'INCO1' <LS_LIST>-STYLE,
                          GC_E 'VERID' <LS_LIST>-STYLE.
*
*    IF <LS_LIST>-ESOKZ = GC_3.
*      _SET_STYLE : GC_E 'VERID' <LS_LIST>-STYLE.
*    ELSE.
*      _SET_STYLE : GC_D 'VERID' <LS_LIST>-STYLE.
*    ENDIF.

    IF <LS_LIST>-KALSK = 'FT'.
*수입운임(%)/수입제비용(%) 필드 입력가능.
      _SET_STYLE : GC_E 'ZFR1' <LS_LIST>-STYLE,  "ENABLED
                            GC_E 'ZFR1_UNIT' <LS_LIST>-STYLE,
                            GC_E 'ZFR2' <LS_LIST>-STYLE,
                            GC_E 'ZFR2_UNIT' <LS_LIST>-STYLE.
    ELSE.
      _SET_STYLE : GC_D 'ZFR1' <LS_LIST>-STYLE,  "ENABLED
                            GC_D 'ZFR1_UNIT' <LS_LIST>-STYLE,
                            GC_D 'ZFR2' <LS_LIST>-STYLE,
                            GC_D 'ZFR2_UNIT' <LS_LIST>-STYLE.
    ENDIF.

    IF <LS_LIST>-APPROVED IS INITIAL.
      IF P_DIS = GC_X.
        _SET_STYLE : GC_E 'DATAB_I' <LS_LIST>-STYLE,
                              GC_E 'DATBI_I' <LS_LIST>-STYLE,
                              GC_E 'KBETR_I' <LS_LIST>-STYLE,
                              GC_E 'KPEIN_I' <LS_LIST>-STYLE,
                              GC_E 'KMEIN_I' <LS_LIST>-STYLE.
      ELSEIF P_CRE = GC_X.
        _SET_STYLE : GC_E 'DATAB' <LS_LIST>-STYLE,
                              GC_E 'DATBI' <LS_LIST>-STYLE,
                              GC_E 'KBETR' <LS_LIST>-STYLE,
                              GC_E 'KPEIN' <LS_LIST>-STYLE,
                              GC_E 'KMEIN' <LS_LIST>-STYLE,
                              GC_E 'KONWA' <LS_LIST>-STYLE.
      ENDIF.

    ELSE. "해당필드 값 있으면 DISPLAY
      IF P_DIS = GC_X.
        _SET_STYLE : GC_D 'DATAB_I' <LS_LIST>-STYLE,
                              GC_D 'DATBI_I' <LS_LIST>-STYLE,
                              GC_D 'KBETR_I' <LS_LIST>-STYLE,
                              GC_D 'KPEIN_I' <LS_LIST>-STYLE,
                              GC_D 'KMEIN_I' <LS_LIST>-STYLE.

      ELSEIF P_CRE = GC_X.
        _SET_STYLE : GC_D 'DATAB' <LS_LIST>-STYLE,
                              GC_D 'DATBI' <LS_LIST>-STYLE,
                              GC_D 'KBETR' <LS_LIST>-STYLE,
                              GC_D 'KPEIN' <LS_LIST>-STYLE,
                              GC_D 'KMEIN' <LS_LIST>-STYLE,
                              GC_D 'KONWA' <LS_LIST>-STYLE.
      ENDIF.
    ENDIF.

  ENDLOOP.

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

*  " 필드 카탈로그 변경사항 적용
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
    CLEAR : LS_TBAR.

    LS_TBAR-BUTN_TYPE = &1.
    LS_TBAR-FUNCTION   = &2.
    LS_TBAR-ICON           = &3.
    LS_TBAR-TEXT          = &4.
    LS_TBAR-QUICKINFO = &4.

    APPEND LS_TBAR TO PR_OBJ->MT_TOOLBAR.
  END-OF-DEFINITION.


  CASE PO_SENDER.

    WHEN GCL_GRID.
      IF P_DIS = GC_X.

        _SET_TBAR 3 '    ' '              ' '    '.
        _SET_TBAR 0 'REFRESH' ICON_REFRESH 'REFRESH'(B01).
        _SET_TBAR 0 'CHANGE' ICON_SYSTEM_SAVE  '변경'(B02).

      ELSEIF P_CRE = GC_X.

        _SET_TBAR 3 '    ' '              ' '    '.
        _SET_TBAR 0 'REFRESH' ICON_REFRESH 'REFRESH'(B01).
        _SET_TBAR 0 'TEMP'  ICON_TREND_DOWN  'TEMPLATE'(B03).
        _SET_TBAR 0 'UPLOAD' ICON_TREND_UP 'EXCEL UPLOAD'(B04).
        _SET_TBAR 0 'ME11' ICON_CREATE 'ME11'(B05).
        _SET_TBAR 0 'SAVE' ICON_SYSTEM_SAVE '저장'(B06).

      ELSE.
        CLEAR PR_OBJ.

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

  CLEAR : GV_ANSWER, GV_UCOMM.
  GV_UCOMM = PV_UCOMM.

  CASE PV_UCOMM.
    WHEN 'REFRESH'.
      IF P_DIS = GC_X.
        PERFORM POPUP_TO_CONFIRM_STEP USING GC_N
                                                              TEXT-M04 "작업 중인 정보가 초기화 됩니다.
                                                              TEXT-M05 "REFRESH 하시겠습니까?
                                                              TEXT-T04. " 확인
        CHECK GV_ANSWER = GC_J.
        PERFORM GET_DATA.
      ELSE.
        PERFORM GET_DATA.
      ENDIF.

    WHEN 'CHANGE' .
      PERFORM CHANGE_INFORECORD.
      PERFORM REFRESH_TABLE USING GCL_GRID SPACE.

    WHEN 'TEMP' .
*UPLOAD TEMPLATE: EXEL 업로드 양식 다운로드
      PERFORM TEMPLATE_DOWNLOAD USING GC_ZGTMMR1050 .

    WHEN 'UPLOAD'  .
      PERFORM EXCEL_UPLOAD.
      PERFORM REFRESH_TABLE USING GCL_GRID SPACE.

    WHEN 'ME11'  .
      PERFORM CALL_TRANSACTION USING 'ME11'.

    WHEN 'SAVE'  .
      PERFORM SAVE_DATA.

    WHEN OTHERS.
  ENDCASE.

*  PERFORM REFRESH_TABLE USING GCL_GRID SPACE.

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
*      PERFORM REFRESH_TABLE USING GCL_GRID SPACE.
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
  DATA : LV_LIFNR TYPE LIFNR,
         LV_MATNR TYPE MATNR,
         LV_MWSKZ TYPE MWSKZ.

  LOOP AT PO_DATA_CHANGED->MT_GOOD_CELLS INTO DATA(LS_MOD_CELLS).

    READ TABLE GT_LIST  INTO DATA(LS_LIST) INDEX LS_MOD_CELLS-ROW_ID.
    CHECK SY-SUBRC EQ 0.

    CASE LS_MOD_CELLS-FIELDNAME.

      WHEN 'LIFNR'.
        CHECK P_CRE = GC_X. "생성일 경우에만 체크 및 변경
        LS_LIST-LIFNR = LS_MOD_CELLS-VALUE.
        SELECT SINGLE NAME1 FROM LFA1
            WHERE LIFNR = @LS_LIST-LIFNR INTO @DATA(LV_NAME).

        IF LV_NAME IS INITIAL.
          CLEAR LS_MOD_CELLS-VALUE.
          LV_ERR = GC_X.
          PERFORM ADD_ENTRY USING PO_DATA_CHANGED LS_MOD_CELLS-FIELDNAME
                                                       LS_MOD_CELLS-ROW_ID.
        ENDIF.

        CLEAR LS_LIST-STATUS.
        LS_LIST-STATUS = COND #( WHEN LS_MOD_CELLS-VALUE IS INITIAL THEN ICON_LED_RED
                                                   WHEN LV_NAME IS INITIAL THEN ICON_LED_RED
                                                   ELSE ICON_CHANGE ).
        LS_LIST-LIFNR_N = LV_NAME .

        IF LS_LIST-LIFNR IS INITIAL.
          CLEAR : LS_LIST-APPROVED, LS_LIST-S2 , LS_LIST-KALSK.
        ELSE.
*승인상태
          SELECT SINGLE APPROVED FROM ZGTMMT1061
              WHERE LIFNR  = @LS_LIST-LIFNR
                  AND MATNR = @LS_LIST-MATNR
                  AND EKORG = @P_EKORG
                  AND WERKS = @P_WERKS
                  AND ESOKZ = @LS_LIST-ESOKZ
                  INTO @DATA(LV_APP).
          LS_LIST-APPROVED = COND #( WHEN LV_APP IS INITIAL THEN SPACE ELSE LV_APP ).
          LS_LIST-S2 = COND #( WHEN LV_APP IS INITIAL THEN SPACE ELSE ICON_MAIL ).
          CLEAR LV_APP.
*계산 스키마 그룹(공급업체) 확인 후 데이터 별 수입관련 필드 제어
          SELECT SINGLE KALSK FROM LFM1
            WHERE LIFNR = @LS_LIST-LIFNR
                 AND EKORG = @P_EKORG
            INTO @DATA(LV_KALSK).
            LS_LIST-KALSK = LV_KALSK.
        ENDIF.

      WHEN 'MATNR'.
        CHECK P_CRE = GC_X. "생성일 경우에만 체크 및 변경
        LV_MATNR = LS_MOD_CELLS-VALUE.
        SELECT SINGLE ZZMAKTX80 FROM MARA
           WHERE MATNR = @LV_MATNR INTO @DATA(LV_MKTX).

        IF LV_MKTX IS INITIAL.
          SELECT SINGLE MAKTX FROM MAKT
          WHERE MATNR = @LV_MATNR
               AND SPRAS = @SY-LANGU INTO @LV_MKTX.
        ENDIF.

        IF LV_MKTX IS INITIAL.
          CLEAR LS_MOD_CELLS-VALUE.
          LV_ERR = GC_X.
        ENDIF.

        CLEAR LS_LIST-STATUS.
        LS_LIST-STATUS = COND #( WHEN LS_MOD_CELLS-VALUE IS INITIAL THEN ICON_LED_RED
                                                   WHEN LV_MKTX IS INITIAL THEN ICON_LED_RED
                                                   ELSE ICON_CHANGE ).
        LS_LIST-MATNR_N = COND #( WHEN LS_MOD_CELLS-VALUE IS INITIAL THEN SPACE
                                                      ELSE LV_MKTX ).

        PERFORM MODIFY_CELL USING PO_DATA_CHANGED 'MATNR'
                                              LS_MOD_CELLS-VALUE LS_MOD_CELLS-ROW_ID.
*단위_자재 변경 시마다 체크
        SELECT SINGLE MEINS FROM MARA
          WHERE MATNR = @LS_MOD_CELLS-VALUE
          INTO @DATA(LV_MEINS).

        LS_LIST-MEINS = COND #( WHEN LV_MEINS IS INITIAL THEN SPACE ELSE LV_MEINS ).
*승인대상
        SELECT SINGLE B~ZMANYN
        FROM MARA AS A JOIN ZGTMMT1060 AS B
        ON   A~MTART = B~MTART
        WHERE  B~EKORG = @P_EKORG
             AND A~MATNR = @LV_MATNR
        INTO @DATA(LV_YN).
        LS_LIST-ZYN = COND #( WHEN LV_YN IS INITIAL THEN SPACE ELSE LV_YN ).
*승인대상아이콘_ZYN 값에 따라 설정.
        LS_LIST-S1 = COND #( WHEN LS_LIST-ZYN IS INITIAL THEN SPACE ELSE ICON_RELEASE ).
*승인상태
        CLEAR : LV_YN, LV_APP.
        SELECT SINGLE APPROVED FROM ZGTMMT1061
          WHERE LIFNR = @LS_LIST-LIFNR
              AND MATNR = @LV_MATNR
              AND EKORG = @P_EKORG
              AND WERKS = @P_WERKS
              AND ESOKZ = @LS_LIST-ESOKZ
          INTO @LV_APP.
        LS_LIST-APPROVED = COND #( WHEN LV_APP IS INITIAL THEN SPACE ELSE LV_APP ).
*승인상태아이콘_APPROVED 값에 따라 설정.
        LS_LIST-S2 = COND #( WHEN LV_APP IS INITIAL THEN SPACE ELSE ICON_MAIL ).

      WHEN 'EKORG'.
        CHECK P_CRE = GC_X.  "'생성' 일 경우에만 체크 및 변경
        READ TABLE GT_T024E INTO DATA(LS_E) WITH TABLE KEY EKORG = P_EKORG.
        LS_LIST-EKORG_N = COND #( WHEN LS_MOD_CELLS-VALUE IS INITIAL THEN SPACE
                                                      WHEN LS_E IS INITIAL THEN SPACE
                                                      ELSE LS_E-EKOTX ).
        CLEAR LS_LIST-STATUS.
        LS_LIST-STATUS = COND #( WHEN LS_MOD_CELLS-VALUE IS INITIAL THEN ICON_LED_RED
                                                   WHEN LS_MOD_CELLS-VALUE NE P_EKORG THEN ICON_LED_RED
                                                   WHEN LS_E IS INITIAL THEN  ICON_LED_RED
                                                   ELSE ICON_CHANGE ).

        PERFORM MODIFY_CELL USING PO_DATA_CHANGED 'EKORG'
                                              LS_MOD_CELLS-VALUE LS_MOD_CELLS-ROW_ID.

      WHEN 'WERKS'.
        CHECK P_CRE = GC_X.  "'생성' 일 경우에만 체크 및 변경

        READ TABLE GT_T001W INTO DATA(LS_W) WITH TABLE KEY WERKS = P_WERKS.
        LS_LIST-WERKS_N = COND #( WHEN LS_MOD_CELLS-VALUE IS INITIAL THEN SPACE
                                                      WHEN LS_W IS INITIAL THEN SPACE
                                                      ELSE LS_W-NAME1 ).
        CLEAR LS_LIST-STATUS.
        LS_LIST-STATUS = COND #( WHEN LS_MOD_CELLS-VALUE IS INITIAL THEN ICON_LED_RED
                                                   WHEN LS_MOD_CELLS-VALUE NE P_WERKS THEN ICON_LED_RED
                                                   WHEN LS_W IS INITIAL THEN  ICON_LED_RED
                                                   ELSE ICON_CHANGE ).

        PERFORM MODIFY_CELL USING PO_DATA_CHANGED 'WERKS'
                                              LS_MOD_CELLS-VALUE LS_MOD_CELLS-ROW_ID.

      WHEN 'ESOKZ'. "인포유형
        CHECK P_CRE = GC_X.  "생성' 일 경우에만 체크 및 변경
        PERFORM MODIFY_CELL USING PO_DATA_CHANGED 'ESOKZ'
                                              LS_MOD_CELLS-VALUE LS_MOD_CELLS-ROW_ID.
        READ TABLE GT_ESOKZ INTO DATA(LS_ESOKZ)
        WITH KEY DOMVALUE_L = LS_MOD_CELLS-VALUE  BINARY SEARCH.
        IF SY-SUBRC = 0.
          LS_LIST-ESOKZ_N = LS_ESOKZ-DDTEXT.
          LS_LIST-STATUS = ICON_CHANGE.

        ELSE.
          CLEAR : LS_LIST-ESOKZ, LS_LIST-ESOKZ_N.
          LS_LIST-STATUS = ICON_LED_RED.
        ENDIF.

*승인상태
        CLEAR LV_APP.
        SELECT SINGLE APPROVED FROM ZGTMMT1061
             WHERE LIFNR = @LS_LIST-LIFNR
                 AND MATNR = @LS_LIST-MATNR
                 AND EKORG = @P_EKORG
                 AND WERKS = @P_WERKS
                 AND ESOKZ = @LS_MOD_CELLS-VALUE
                 INTO @LV_APP.
        LS_LIST-APPROVED = COND #( WHEN LV_APP IS INITIAL THEN SPACE ELSE LV_APP ).
        LS_LIST-S2 = COND #( WHEN LV_APP IS INITIAL THEN SPACE ELSE ICON_MAIL ).

      WHEN 'UEBTO'.
        IF LS_MOD_CELLS-VALUE IS NOT INITIAL.
          CLEAR LS_LIST-UEBTK.
        ENDIF.
        LS_LIST-STATUS = ICON_CHANGE.
        PERFORM MODIFY_CELL USING PO_DATA_CHANGED 'UEBTO'
                                              LS_MOD_CELLS-VALUE LS_MOD_CELLS-ROW_ID.

      WHEN 'UNTTO'.
        LS_LIST-STATUS = ICON_CHANGE.
        PERFORM MODIFY_CELL USING PO_DATA_CHANGED 'UNTTO'
                                              LS_MOD_CELLS-VALUE LS_MOD_CELLS-ROW_ID.
      WHEN 'UEBTK'. "
        TRANSLATE LS_MOD_CELLS-VALUE TO UPPER CASE.
        IF LS_MOD_CELLS-VALUE IS NOT INITIAL.
          CLEAR LS_LIST-UEBTO.
        ENDIF.
        LS_LIST-STATUS = ICON_CHANGE.
        PERFORM MODIFY_CELL USING PO_DATA_CHANGED 'UEBTK'
                                              LS_MOD_CELLS-VALUE LS_MOD_CELLS-ROW_ID.

      WHEN 'VERID'. "
        IF P_DIS = GC_X. "조회 일 경우, 추가 체크.
          LS_LIST-STATUS = COND #( WHEN ( LS_LIST-EKGRP IS INITIAL OR
            LS_LIST-APLFZ IS INITIAL OR LS_LIST-NORBM IS INITIAL OR LS_LIST-DATAB_I IS INITIAL OR
            LS_LIST-DATBI_I IS INITIAL OR LS_LIST-KBETR_I IS INITIAL OR LS_LIST-KPEIN_I IS INITIAL OR
            LS_LIST-KMEIN_I IS INITIAL OR LS_MOD_CELLS-VALUE IS INITIAL )
            THEN ICON_LED_RED ELSE ICON_CHANGE ).
        ELSE.
          LS_LIST-STATUS = ICON_CHANGE.
        ENDIF.

        PERFORM MODIFY_CELL USING PO_DATA_CHANGED 'VERID'
                                              LS_MOD_CELLS-VALUE LS_MOD_CELLS-ROW_ID.

      WHEN 'WEBRE'. "
        TRANSLATE LS_MOD_CELLS-VALUE TO UPPER CASE.
        LS_LIST-STATUS = ICON_CHANGE.
        PERFORM MODIFY_CELL USING PO_DATA_CHANGED 'WEBRE'
                                              LS_MOD_CELLS-VALUE LS_MOD_CELLS-ROW_ID.
      WHEN 'XERSN'. "
        TRANSLATE LS_MOD_CELLS-VALUE TO UPPER CASE.
        LS_LIST-STATUS = ICON_CHANGE.
        PERFORM MODIFY_CELL USING PO_DATA_CHANGED 'XERSN'
                                              LS_MOD_CELLS-VALUE LS_MOD_CELLS-ROW_ID.
      WHEN 'BSTAE'. "
        LS_LIST-STATUS = ICON_CHANGE.
        PERFORM MODIFY_CELL USING PO_DATA_CHANGED 'BSTAE'
                                              LS_MOD_CELLS-VALUE LS_MOD_CELLS-ROW_ID.
      WHEN 'MWSKZ'. "
        IF LS_MOD_CELLS-VALUE IS INITIAL.
          CLEAR LS_LIST-MWSKZ_N.
          LS_LIST-STATUS = ICON_LED_RED.

        ELSE.
          CLEAR LS_LIST-STATUS.
          LV_MWSKZ = LS_MOD_CELLS-VALUE.

          SELECT SINGLE FROM T007S
            FIELDS TEXT1 WHERE KALSM = @GC_TAXKR
                                       AND MWSKZ = @LV_MWSKZ
                                       AND SPRAS  = @SY-LANGU
            INTO @DATA(LV_TXT).

          IF SY-SUBRC =  0.
            LS_LIST-STATUS = ICON_CHANGE.
            PERFORM MODIFY_CELL USING PO_DATA_CHANGED 'MWSKZ_N'
                                                         LV_TXT  LS_MOD_CELLS-ROW_ID.
          ELSE.
            LS_LIST-STATUS = ICON_LED_RED.
          ENDIF.
        ENDIF.

        PERFORM MODIFY_CELL USING PO_DATA_CHANGED 'MWSKZ'
                                              LS_MOD_CELLS-VALUE LS_MOD_CELLS-ROW_ID.

      WHEN 'MEPRF'. "
        LS_LIST-STATUS = ICON_CHANGE.
        PERFORM MODIFY_CELL USING PO_DATA_CHANGED 'MEPRF'
                                              LS_MOD_CELLS-VALUE LS_MOD_CELLS-ROW_ID.
      WHEN 'INCO1'. "
        IF LS_MOD_CELLS-VALUE IS INITIAL.
          CLEAR LS_LIST-INCO1_N.
        ELSE.
          SELECT SINGLE BEZEI FROM TINCT
            WHERE INCO1 = @LS_MOD_CELLS-VALUE
                 AND SPRAS = @SY-LANGU
            INTO @DATA(LV_BEZEI).
          IF SY-SUBRC = 0.
            LS_LIST-INCO1_N = LV_BEZEI.
          ELSE.
            CLEAR :  LS_MOD_CELLS-VALUE,   LS_LIST-INCO1_N.
          ENDIF.
          CLEAR LV_BEZEI.
        ENDIF.
        LS_LIST-STATUS = ICON_CHANGE.
        PERFORM MODIFY_CELL USING PO_DATA_CHANGED 'INCO1'
                                              LS_MOD_CELLS-VALUE LS_MOD_CELLS-ROW_ID.

      WHEN 'EINE_LOEKZ'.
        LS_LIST-STATUS = ICON_CHANGE.
        PERFORM MODIFY_CELL USING PO_DATA_CHANGED 'EINE_LOEKZ'
                                              LS_MOD_CELLS-VALUE LS_MOD_CELLS-ROW_ID.

      WHEN 'EKGRP' OR 'APLFZ' OR 'NORBM' OR 'DATAB_I' OR 'DATBI_I' OR  'KBETR_I'
                  OR  'KPEIN_I' OR 'KMEIN_I' OR 'ZFR1_I' OR 'ZFR1_UINT_I' OR 'ZFR2_I' OR 'ZFR2_UINT_I'.

        IF LS_MOD_CELLS-VALUE IS INITIAL.
          LS_LIST-STATUS =  ICON_LED_RED .

        ELSE.
          IF P_DIS = GC_X. "조회 및 변경
            IF LS_LIST-ESOKZ = GC_0.
              LS_LIST-STATUS = COND #( WHEN (
                LS_LIST-EKGRP IS INITIAL OR LS_LIST-NORBM IS INITIAL OR LS_LIST-DATAB_I IS INITIAL OR
                LS_LIST-DATBI_I IS INITIAL OR LS_LIST-KBETR_I IS INITIAL OR LS_LIST-KPEIN_I IS INITIAL OR
                LS_LIST-KMEIN_I IS INITIAL ) THEN ICON_LED_RED ELSE ICON_CHANGE ).
            ELSE.
              LS_LIST-STATUS = COND #( WHEN (
                LS_LIST-EKGRP IS INITIAL OR LS_LIST-NORBM IS INITIAL OR LS_LIST-DATAB_I IS INITIAL OR
                LS_LIST-DATBI_I IS INITIAL OR LS_LIST-KBETR_I IS INITIAL OR LS_LIST-KPEIN_I IS INITIAL OR
                LS_LIST-KMEIN_I IS INITIAL OR LS_LIST-VERID IS INITIAL ) THEN ICON_LED_RED ELSE ICON_CHANGE ).
            ENDIF.
          ELSE.
            LS_LIST-STATUS = ICON_CHANGE.
          ENDIF.
        ENDIF.

        IF LS_MOD_CELLS-FIELDNAME =  'EKGRP' AND LS_MOD_CELLS-VALUE IS NOT INITIAL.
          READ TABLE GT_T024 INTO DATA(LS_EKGRP)
          WITH TABLE KEY EKGRP = LS_MOD_CELLS-VALUE.

          IF SY-SUBRC = 0.
            LS_LIST-EKGRP_N = LS_EKGRP-EKNAM.

          ELSE.
            CLEAR : LS_MOD_CELLS-VALUE, LS_LIST-EKGRP_N.
            LS_LIST-STATUS = ICON_LED_RED.
            LV_ERR = GC_X.
            PERFORM ADD_ENTRY USING PO_DATA_CHANGED LS_MOD_CELLS-FIELDNAME
                                                         LS_MOD_CELLS-ROW_ID.
          ENDIF.
        ENDIF.

        PERFORM MODIFY_CELL USING PO_DATA_CHANGED LS_MOD_CELLS-FIELDNAME
                                                        LS_MOD_CELLS-VALUE LS_MOD_CELLS-ROW_ID.

      WHEN   'DATAB' OR 'DATBI' OR  'KBETR'  OR  'KPEIN' OR 'KMEIN' OR 'KONWA' ."OR 'ZFR1' OR 'ZFR1_UINT' OR 'ZFR2' OR 'ZFR2_UINT'.
        CHECK P_CRE = GC_X AND LS_LIST-APPROVED = '0'. "'생성'&승인대상일 경우에만..
        IF LS_MOD_CELLS-VALUE IS INITIAL.
          LS_LIST-STATUS =  ICON_LED_RED .
        ELSE.
          LS_LIST-STATUS = ICON_CHANGE.
          PERFORM MODIFY_CELL USING PO_DATA_CHANGED LS_MOD_CELLS-FIELDNAME
                                                          LS_MOD_CELLS-VALUE LS_MOD_CELLS-ROW_ID.
        ENDIF.

      WHEN 'ZFR1' OR 'ZFR1_UINT' OR 'ZFR2' OR 'ZFR2_UINT'.
        CHECK P_CRE = GC_X AND LS_LIST-APPROVED = '0'. "'생성'&승인대상일 경우에만..
        LS_LIST-STATUS = ICON_CHANGE.
        PERFORM MODIFY_CELL USING PO_DATA_CHANGED LS_MOD_CELLS-FIELDNAME
                                                        LS_MOD_CELLS-VALUE LS_MOD_CELLS-ROW_ID.

      WHEN OTHERS.
    ENDCASE.

    IF  LS_LIST-STATUS = ICON_LED_RED.
      LS_LIST-MESSAGE = '필수 값을 점검하세요'.
    ELSE.
      CLEAR : LS_LIST-MESSAGE.
    ENDIF.

    MODIFY GT_LIST FROM LS_LIST INDEX LS_MOD_CELLS-ROW_ID.
  ENDLOOP.

  IF LV_ERR IS NOT INITIAL.
    IF P_CRE = GC_X.
      PERFORM SET_CELL_STYLE USING 'CRE'.
    ENDIF.
    PERFORM REFRESH_TABLE USING GCL_GRID SPACE.
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
*
  CASE PO_SENDER.

    WHEN GCL_GRID.

        READ TABLE GT_LIST INTO DATA(LS_LIST) INDEX PS_ROW_NO-INDEX.
        CHECK SY-SUBRC = 0.

        IF PS_COLUMN-FIELDNAME = 'MATNR'.
           CHECK ls_list-MATNR IS NOT INITIAL.
           SET PARAMETER ID 'MAT' FIELD ls_list-MATNR.
           CALL TRANSACTION 'MM03' AND SKIP FIRST SCREEN.

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

    CASE GV_UCOMM . "SY-UCOMM.
      WHEN 'SAVE'.
        LV_MSG = 'INFORECORD 생성 대상을 선택하세요'(E06).
      WHEN OTHERS.
        LV_MSG = '변경 대상을 선택하세요.'(E07).
    ENDCASE.

    MESSAGE S000 WITH LV_MSG DISPLAY LIKE GC_E.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& FORM SET_CREATE_DATA
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
*& -->  P1        TEXT
*& <--  P2        TEXT
*&---------------------------------------------------------------------*
FORM SET_CREATE_DATA .

*  CLEAR : GT_CREATE[], GV_ERR.
*
*  SELECT SINGLE BUTXT
*    FROM T001
*    WHERE BUKRS = @P_BUKRS
*    INTO @DATA(LV_TXT).
*
*  READ TABLE GT_T001W INTO DATA(LS_W) WITH TABLE KEY WERKS = P_WERKS.
*  READ TABLE GT_T024E INTO DATA(LS_E) WITH TABLE KEY EKORG = P_EKORG.
*  READ TABLE GT_T024  INTO DATA(LS_T) WITH TABLE KEY EKGRP = P_EKGRP.
*
*  DO 30 TIMES.
*    APPEND VALUE #( BUKRS = P_BUKRS
*                                 BUTXT = LV_TXT
*                                 WERKS = P_WERKS
*                                 WERKS_N = LS_W-NAME1
*                                 EKORG = P_EKORG
*                                 EKOTX = LS_E-EKOTX
*                                 EKGRP = P_EKGRP
*                                 EKNAM = LS_T-EKNAM ) TO GT_CREATE.
*  ENDDO.

ENDFORM.
*&---------------------------------------------------------------------*
*& FORM CHANGE_INFORECORD
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
*& -->  P1        TEXT
*& <--  P2        TEXT
*&---------------------------------------------------------------------*
FORM CHANGE_INFORECORD .

  DEFINE _BAPI_CURR.
  CLEAR:
       LV_AMT_EXT,
       LV_AMT_INT.

  LV_AMT_INT = &2.
  CALL FUNCTION 'BAPI_CURRENCY_CONV_TO_EXTERNAL'
    EXPORTING
      CURRENCY                 = &1
      AMOUNT_INTERNAL    = LV_AMT_INT
   IMPORTING
     AMOUNT_EXTERNAL    = LV_AMT_EXT
            .
   &2 = LV_AMT_EXT.
END-OF-DEFINITION.

  DATA :
    LS_EINA  TYPE MEWIEINA,
    LS_EEINA TYPE  MEWIEINA,
    LS_EINAX TYPE  MEWIEINAX,
    LS_EINE  TYPE  MEWIEINE,
    LS_EEINE TYPE	MEWIEINE,
    LS_EINEX TYPE  MEWIEINEX.

  DATA:
    COND_VALIDITY TYPE TABLE OF MEWIVALIDITY,
    CONDITION     TYPE TABLE OF MEWICONDITION.

  DATA:
    LT_PRITEM  TYPE TABLE OF BAPIMEREQITEMIMP,
    LT_PRITEMX TYPE TABLE OF BAPIMEREQITEMX.

  DATA:
    LV_CHECK       TYPE C LENGTH 1,
    LO_RECEIVER    TYPE REF TO IF_RECIPIENT_BCS,
    LO_EMAIL       TYPE REF TO CL_BCS,
    LO_EMAIL_BODY  TYPE REF TO CL_DOCUMENT_BCS,
    LX_EXCEPTION   TYPE REF TO CX_BCS,
    LV_SEND_RESULT TYPE C.

  DATA:
    LV_LINE TYPE SO_TEXT255,
    LT_BODY TYPE BCSY_TEXT.

  DATA:
    LV_EMAIL     TYPE AD_SMTPADR,
    LV_HEAD_TEXT TYPE SO_OBJ_DES.

  DATA:
    LS_RETURN TYPE BAPIRET2,
    LT_RETURN LIKE TABLE OF BAPIRET2,
    LT_RTN    LIKE TABLE OF BAPIRETURN.

  CLEAR : GV_TEXT, GV_ANSWER, GV_ERR.

  DATA : LT_MAIL LIKE TABLE OF GS_LIST,
         LT_1061 LIKE TABLE OF ZGTMMT1061,
         LS_1061 LIKE ZGTMMT1061.

  CLEAR : GV_ANSWER, GV_ERR, GT_LIST_C.

  DATA :
    LV_AMT_EXT TYPE BAPICURR-BAPICURR,
    LV_AMT_INT  TYPE MATDOC-DMBTR.
  DATA : LV_KBETR TYPE KBETR_KOND.

  PERFORM GET_SELECTED_ROWS USING GCL_GRID.
  CHECK GV_ERR IS INITIAL.

  IF LINE_EXISTS( GT_LIST[ STATUS = ICON_CHANGE ] ).
    PERFORM POPUP_TO_CONFIRM_STEP USING GC_N
                                                            TEXT-M07 "INFORECORD 변경하시겠습니까?
                                                            TEXT-M08 "단가 변경 건은 팀장 승인 후 반영됩니다.
                                                            TEXT-T04. " 확인
    CHECK GV_ANSWER = GC_J.

    LV_HEAD_TEXT = '[승인요청]InfoRecord 변경에 대한 승인요청 드립니다.'(m16).


        LV_LINE = |<html><body style="font-size:14">|.
        LT_BODY = VALUE #( BASE LT_BODY ( LINE = LV_LINE ) ).
        LV_LINE = |<p>{ TEXT-EM1 }</p>|.

        LT_BODY = VALUE #( BASE LT_BODY ( LINE = LV_LINE ) ).
        LV_LINE = |<p>SAP T-code <strong>ZGTMMR1051</strong>에서 확인 부탁드립니다. </p>|.
        LT_BODY = VALUE #( BASE LT_BODY ( LINE = LV_LINE ) ).

        LV_LINE = |<table border=1 STYLE="border-collapse: collapse;border-color: #000000;font-size:11:width:700px" >|.
        LT_BODY = VALUE #( BASE LT_BODY ( LINE = LV_LINE ) ).

        LV_LINE = |<tr align="center" style="background-color: #B3B1B1" ><td width="200px"><strong>공급업체명</strong></td>|.
        LT_BODY = VALUE #( BASE LT_BODY ( LINE = LV_LINE ) ).
        LV_LINE = |<td width="200px" ><strong>자재명</strong></td>|.
        LT_BODY = VALUE #( BASE LT_BODY ( LINE = LV_LINE ) ).
        LV_LINE = |<td width="50px" ><strong>FROM</strong></td>|.
        LT_BODY = VALUE #( BASE LT_BODY ( LINE = LV_LINE ) ).
        LV_LINE = |<td width="50px" ><strong>TO</strong></td>|.
        LT_BODY = VALUE #( BASE LT_BODY ( LINE = LV_LINE ) ).
        LV_LINE = |<td width="100px" ><strong>단가</strong></td>|.
        LT_BODY = VALUE #( BASE LT_BODY ( LINE = LV_LINE ) ).
        LV_LINE = |<td width="100px" ><strong>통화</strong></td>|.
        LT_BODY = VALUE #( BASE LT_BODY ( LINE = LV_LINE ) ).


    LOOP AT GT_ROWS INTO GS_ROW.

      READ TABLE GT_LIST ASSIGNING FIELD-SYMBOL(<FS>) INDEX GS_ROW-INDEX.
      IF SY-SUBRC = 0.
*인포레코드 변경용 데이터 구성 후 ->아래 조건에 따라 처리 구분
        CLEAR: LS_EINA, LS_EINAX, LS_EINE, LS_EINEX, COND_VALIDITY, CONDITION, LT_RTN.

        LS_EINA = VALUE #( MATERIAL = <FS>-MATNR
                                       VENDOR    = <FS>-LIFNR ).

        LS_EINAX = VALUE #( MATERIAL = GC_X
                                               VENDOR   = GC_X ).

        LS_EINE = VALUE #( PURCH_ORG = <FS>-EKORG
                                   PLANT         = <FS>-WERKS
                                   INFO_TYPE  = <FS>-ESOKZ
                                   CURRENCY  = <FS>-KONWA
                                   PUR_GROUP = <FS>-EKGRP
                                   PLND_DELRY = <FS>-APLFZ
                                   OVERDELTOL = <FS>-UEBTO
                                   UNDER_TOL   = <FS>-UNTTO
                                   UNLIMITED     = <FS>-UEBTK
                                   CONF_CTRL   = <FS>-BSTAE
                                   NRM_PO_QTY = <FS>-NORBM
                                   TAX_CODE     = <FS>-MWSKZ
                                   PRICEDATE    = <FS>-MEPRF
                                   INCOTERMS1 = <FS>-INCO1
                                   GR_BASEDIV  = <FS>-WEBRE
                                   VERSION       = <FS>-VERID
                                   DELETE_IND  = <FS>-EINE_LOEKZ
                                   NO_AUT_GR  = <FS>-XERSN ).

        LS_EINEX = VALUE #( PURCH_ORG  = COND #( WHEN <FS>-EKORG IS INITIAL THEN SPACE ELSE GC_X )
                                    PLANT            = COND #( WHEN <FS>-WERKS IS INITIAL THEN SPACE ELSE GC_X )
                                    INFO_TYPE     = COND #( WHEN <FS>-ESOKZ IS INITIAL THEN SPACE ELSE GC_X )
                                    CURRENCY     = COND #( WHEN <FS>-KONWA IS INITIAL THEN SPACE ELSE GC_X )
                                    PUR_GROUP   = COND #( WHEN <FS>-EKGRP IS INITIAL THEN SPACE ELSE GC_X )
                                    PLND_DELRY  = COND #( WHEN <FS>-APLFZ IS INITIAL THEN SPACE ELSE GC_X )
                                    OVERDELTOL  = COND #( WHEN <FS>-UEBTO IS INITIAL THEN SPACE ELSE GC_X )
                                    UNDER_TOL    = COND #( WHEN <FS>-UNTTO IS INITIAL THEN SPACE ELSE GC_X )
                                    UNLIMITED      = COND #( WHEN <FS>-UEBTK IS INITIAL THEN SPACE ELSE GC_X )
                                    CONF_CTRL    = COND #( WHEN <FS>-BSTAE IS INITIAL THEN SPACE ELSE GC_X )
                                    NRM_PO_QTY = COND #( WHEN <FS>-NORBM IS INITIAL THEN SPACE ELSE GC_X )
                                    TAX_CODE     = COND #( WHEN <FS>-MWSKZ IS INITIAL THEN SPACE ELSE GC_X )
                                    PRICEDATE     = COND #( WHEN <FS>-MEPRF IS INITIAL THEN SPACE ELSE GC_X )
                                    INCOTERMS1  = COND #( WHEN <FS>-INCO1 IS INITIAL THEN SPACE ELSE GC_X )
                                    GR_BASEDIV   = COND #( WHEN <FS>-WEBRE IS INITIAL THEN SPACE ELSE GC_X )
                                    VERSION        = COND #( WHEN <FS>-VERID IS INITIAL THEN SPACE ELSE GC_X )
                                    DELETE_IND   = GC_X
                                    NO_AUT_GR   = COND #( WHEN <FS>-XERSN IS INITIAL THEN SPACE ELSE GC_X ) ).

        APPEND VALUE #( VALID_FROM = <FS>-DATAB_I
                                          VALID_TO     = <FS>-DATBI_I ) TO COND_VALIDITY.

        LV_KBETR = <FS>-KBETR_I.

       _BAPI_CURR <FS>-KONWA LV_KBETR.

        APPEND VALUE #( COND_COUNT = '01'
                                COND_TYPE  =  'PB00'
                                COND_VALUE = LV_KBETR
                                CURRENCY     = <FS>-KONWA
                                COND_P_UNT = <FS>-KPEIN_I
                                COND_UNIT    = <FS>-KMEIN_I ) TO CONDITION.

        IF <FS>-ZFR1_I IS NOT INITIAL.
        APPEND VALUE #( COND_COUNT = '02'
                                COND_TYPE  =  'ZFR1'
                                COND_VALUE = <FS>-ZFR1_I
                                CURRENCY     = <FS>-ZFR1_UNIT_I ) TO CONDITION.

        ELSE.
            IF <FS>-ZFR1 IS NOT INITIAL.
              APPEND VALUE #( COND_COUNT = '02'
                                DELETION_IND = GC_X
                                COND_TYPE  =  'ZFR1'
                                COND_VALUE = <FS>-ZFR1
                                CURRENCY     = <FS>-ZFR1_UNIT ) TO CONDITION.

           ENDIF.
       ENDIF.

        IF <FS>-ZFR2_I IS NOT INITIAL.
        APPEND VALUE #( COND_COUNT = '03'
                                COND_TYPE  =  'ZFR2'
                                COND_VALUE = <FS>-ZFR2_I
                                CURRENCY     = <FS>-ZFR2_UNIT_I ) TO CONDITION.

       ELSE.
            IF <FS>-ZFR2 IS NOT INITIAL.
              APPEND VALUE #( COND_COUNT = '03'
                                DELETION_IND = GC_X
                                COND_TYPE  =  'ZFR2'
                                COND_VALUE = <FS>-ZFR2
                                CURRENCY     = <FS>-ZFR2_UNIT  ) TO CONDITION.

           ENDIF.
       ENDIF.

*인포 정보와 모두 동일하거나,승인대상 데이터 빈 값(승인미대상)인 경우->승인 요청 없이 INFORECORD변경.
        IF ( <FS>-DATAB = <FS>-DATAB_I AND <FS>-DATBI = <FS>-DATBI_I AND
           <FS>-KBETR = <FS>-KBETR_I AND <FS>-KPEIN = <FS>-KPEIN_I AND
           <FS>-KMEIN = <FS>-KMEIN_I  AND <FS>-ZFR1 = <FS>-ZFR1_I AND <FS>-ZFR1_UNIT = <FS>-ZFR1_UNIT_I AND
          <FS>-ZFR2 = <FS>-ZFR2_I AND <FS>-ZFR2_UNIT = <FS>-ZFR2_UNIT_I )
            OR <FS>-ZYN IS INITIAL.

*-> 26.09.27 플랜트 구매조직 데이터 없는 인포레코드 처리 포함 공통 호출
          PERFORM MAINTAIN_INFORECORD TABLES COND_VALIDITY CONDITION LT_RTN
                                      CHANGING LS_EINA LS_EINAX LS_EINE LS_EINEX
                                               LS_EEINA LS_EEINE.

          IF LINE_EXISTS( LT_RTN[ TYPE = GC_E ] ) .
            CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
            READ TABLE LT_RTN INTO DATA(LS_RTN) WITH KEY TYPE = GC_E.

            <FS>-STATUS = ICON_LED_RED.
            <FS>-MESSAGE = LS_RTN-MESSAGE.

            IF LINES( LT_RTN ) > 1.
              LOOP AT LT_RTN INTO DATA(LS_RETN).
                CLEAR : LS_RETURN.
                CALL FUNCTION 'BALW_RETURN_TO_RET2'
                  EXPORTING
                    RETURN_IN       = LS_RETN
                  IMPORTING
                   RETURN_OU       = LS_RETURN                          .

                APPEND LS_RETURN TO LT_RETURN.
              ENDLOOP.
            ENDIF.

            CONTINUE.

          ELSE.
            CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
              EXPORTING
                WAIT = 'X'.

            <FS>-STATUS = ICON_LED_GREEN.
            <FS>-MESSAGE = '업데이트 성공'(M15).
          ENDIF.

*하나라도 다르면, 승인 요청
        ELSE.
*-승인대상->ZGTMMT1061 저장 후 승인자에 메일 전송.
          APPEND <FS> TO LT_MAIL. "메일 전송용

          CLEAR : LT_1061, LS_1061.
          LS_1061 = CORRESPONDING #( <FS>
                          MAPPING DATAB = DATAB_I
                                         DATBI = DATBI_I
                                         KBETR = KBETR_I
                                         KONWA = KONWA_I
                                         KPEIN = KPEIN_I
                                         KMEIN = KMEIN_I
                                         ) .
          LS_1061-APPROVED = GC_O.
          LS_1061-ERDAT = SY-DATUM.
          LS_1061-ERDAT_LOCAL = SY-DATLO.
          LS_1061-ERTIM = SY-UZEIT.
          LS_1061-ERTIM_LOCAL = SY-TIMLO.
          LS_1061-ERNAM = SY-UNAME.
          LS_1061-AEDAT = SY-DATLO.
          LS_1061-AEDAT_LOCAL = SY-DATLO.
          LS_1061-AETIM = SY-UZEIT.
          LS_1061-AETIM_LOCAL = SY-TIMLO.
          LS_1061-AENAM = SY-UNAME .

          APPEND LS_1061 TO  LT_1061.


         LV_LINE = |<tr><td align="center" >{ <FS>-LIFNR_N }</td>|.
         LT_BODY = VALUE #( BASE LT_BODY ( LINE = LV_LINE ) ).
         LV_LINE = |<td align="center" >{ <FS>-MATNR_N }</td>|.
         LT_BODY = VALUE #( BASE LT_BODY ( LINE = LV_LINE ) ).
         LV_LINE = |<td align="center" >{ <FS>-DATAB_I }</td>|.
         LT_BODY = VALUE #( BASE LT_BODY ( LINE = LV_LINE ) ).
         LV_LINE = |<td align="center" >{ <FS>-DATBI_I }</td>|.
         LT_BODY = VALUE #( BASE LT_BODY ( LINE = LV_LINE ) ).
         LV_LINE = |<td align="right" >{ LV_KBETR }</td>|.
         LT_BODY = VALUE #( BASE LT_BODY ( LINE = LV_LINE ) ).
         LV_LINE = |<td align="center" >{ <FS>-KONWA_I }</td>|.
         LT_BODY = VALUE #( BASE LT_BODY ( LINE = LV_LINE ) ).


          IF LT_1061[] IS NOT INITIAL.
            MODIFY ZGTMMT1061 FROM TABLE LT_1061.
            IF SY-SUBRC = 0.
              COMMIT WORK AND WAIT.
              <FS>-STATUS = ICON_LED_GREEN.
              <FS>-MESSAGE = '단가 변경 승인 요청 완료'(M14).
            ENDIF.
          ENDIF.

        ENDIF.

      ENDIF.
    ENDLOOP.

*ALV에서 정보 변경된 라인이 없는 경우.
  ELSE.
    GV_ERR = GC_X. "변경된 정보가 없습니다.
    MESSAGE S000 WITH TEXT-E05 DISPLAY LIKE GC_E. EXIT.
  ENDIF.

*승인권자에 메일 전송(승인 요청 건 있을 시)
  IF LT_MAIL[] IS NOT INITIAL.
    DATA : LV_MESSAGE TYPE CHAR100,
           LV_MSG     TYPE STRING,
           LV_CHK.

        LV_LINE = |</table></body></html>|.
        LT_BODY = VALUE #( BASE LT_BODY ( LINE = LV_LINE ) ).

        SELECT FROM ZGTMMT1020 FIELDS *
          WHERE WERKS = @P_WERKS
               AND EKGRP = @P_EKGRP
          INTO TABLE @DATA(LT_1020).
        SORT LT_1020 BY EKGRP.

        READ TABLE LT_1020 INTO DATA(LS_1020) WITH KEY EKGRP = P_EKGRP.

        SELECT SINGLE EMAIL AS USRID
         FROM ZGTMM_CV_GETUSERNAME_G
         WHERE USERID = @LS_1020-ANAME
            AND  SUBTY = '0007'
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

        IF LV_SEND_RESULT = GC_X.
            COMMIT WORK.
        ENDIF.


        CLEAR : LV_CHECK,    LO_RECEIVER ,  LO_EMAIL ,  LO_EMAIL_BODY ,  LX_EXCEPTION  ,    LV_SEND_RESULT.
        CLEAR  : GT_MTXT , LV_MSG , LT_BODY[], LT_BODY, LV_EMAIL , LT_MAIL[] , LT_MAIL.

 ENDIF.

 IF LT_RETURN[] IS NOT INITIAL.
   CALL FUNCTION 'C14ALD_BAPIRET2_SHOW'
     TABLES
       I_BAPIRET2_TAB = LT_RETURN .
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
  DATA :
    LT_ITEM  TYPE TABLE OF BAPIMEREQITEMIMP,
    LT_ITEMX TYPE TABLE OF BAPIMEREQITEMX.

  DATA :
    LS_HEAD   TYPE BAPIMATHEAD,
    LS_PLANT  TYPE BAPI_MARC,
    LS_PLANTX TYPE BAPI_MARCX.

*  CLEAR : GV_ERR, GT_PR, GT_CL.
*
*  LOOP AT GT_ROWS INTO GS_ROW.
*    READ TABLE GT_LIST  INTO DATA(LS_LIST) INDEX GS_ROW-INDEX.
*    IF SY-SUBRC = 0.
*      IF LS_LIST-ZTYPE = GC_PR.
*        APPEND VALUE #( BANFN = LS_LIST-BANFN
*                                     BNFPO = LS_LIST-BNFPO
*                                     EKGRP = GV_EKGRP ) TO GT_PR.
*      ENDIF.
*
*      IF LS_LIST-ZTYPE = GC_CL.
*        APPEND VALUE #( MATNR = LS_LIST-MATNR
*                                     WERKS = LS_LIST-WERKS
*                                     EKGRP = GV_EKGRP ) TO GT_CL.
*      ENDIF.
*    ENDIF.
*  ENDLOOP.
*
*  SORT GT_CL BY WERKS MATNR.
*  DELETE ADJACENT DUPLICATES FROM GT_CL COMPARING WERKS MATNR.
*
*  CHECK GV_ERR IS INITIAL.
*  SORT GT_PR BY BANFN BNFPO.
*  SORT GT_LIST BY BANFN BNFPO.
*
*  LOOP AT GT_PR ASSIGNING FIELD-SYMBOL(<FS>).
*    CLEAR : LT_ITEM, LT_ITEMX, GT_RETURN.
*
*    APPEND VALUE #( PREQ_ITEM   = <FS>-BNFPO
*                                 PUR_GROUP = <FS>-EKGRP ) TO LT_ITEM.
*
*    APPEND VALUE #( PREQ_ITEM   = <FS>-BNFPO
*                                 PREQ_ITEMX = GC_X
*                                 PUR_GROUP  = GC_X  ) TO LT_ITEMX.
*
**BAPI_BNFPO 기준 구매그룹 변경 적용
*    CALL FUNCTION 'BAPI_PR_CHANGE'
*      EXPORTING
*        NUMBER  = <FS>-BANFN
*      TABLES
*        RETURN  = GT_RETURN
*        PRITEM   = LT_ITEM
*        PRITEMX = LT_ITEMX.
*
*      IF LINE_EXISTS( GT_RETURN[ TYPE = GC_E ] ).
*        CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
*        READ TABLE GT_RETURN INTO DATA(LS_RT) INDEX 1.
*
*        CLEAR LS_LIST.
*        READ TABLE GT_LIST INTO LS_LIST WITH KEY BANFN = <FS>-BANFN
*                                                                             BNFPO = <FS>-BNFPO BINARY SEARCH.
*       IF SY-SUBRC = 0.
*          DATA(LV_TABIX) = SY-TABIX.
*
*          LS_LIST-STATUS    = ICON_LED_RED.
*          LS_LIST-TYPE        = GC_E.
*          LS_LIST-MESSAGE = LS_RT-MESSAGE.
*       ENDIF.
*
*      ELSE.
*        CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
*          EXPORTING
*            WAIT = GC_X.
*
*        CLEAR : LV_TABIX, LS_LIST.
*        READ TABLE GT_LIST INTO LS_LIST WITH KEY BANFN = <FS>-BANFN
*                                                                             BNFPO = <FS>-BNFPO BINARY SEARCH.
*        IF SY-SUBRC = 0.
*          LV_TABIX = SY-TABIX.
*
*          LS_LIST-EKGRP     = GV_EKGRP.
*          LS_LIST-STATUS    = ICON_LED_GREEN.
*          LS_LIST-TYPE        = GC_S.
*          LS_LIST-MESSAGE = '구매그룹을 변경했습니다.'(M06).
*        ENDIF.
*      ENDIF.
*
*      MODIFY GT_LIST FROM LS_LIST INDEX LV_TABIX
*      TRANSPORTING EKGRP STATUS TYPE MESSAGE.
*  ENDLOOP.
*
**BAPI_플랜트/자재 기준 구매그룹 변경 적용
*  LOOP AT GT_CL ASSIGNING FIELD-SYMBOL(<FSC>).
*    CLEAR : LS_HEAD, LS_PLANT, LS_PLANTX, GT_RETURN.
*
*    LS_HEAD   = VALUE #( MATERIAL = <FSC>-MATNR ).
*    LS_PLANT = VALUE #( PLANT = <FSC>-WERKS
*                                      PUR_GROUP = <FSC>-EKGRP ).
*    LS_PLANTX = VALUE #( PLANT = GC_X
*                                         PUR_GROUP = GC_X ).
*
*    CALL FUNCTION 'BAPI_MATERIAL_SAVEDATA'
*      EXPORTING
*        HEADDATA   = LS_HEAD
*        PLANTDATA  = LS_PLANT
*        PLANTDATAX = LS_PLANTX
*      IMPORTING
*        RETURN     = GT_RETURN.
*
*    IF LINE_EXISTS( GT_RETURN[ TYPE = GC_E ] ).
*       CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
*       READ TABLE GT_RETURN INTO DATA(LS_RT2) INDEX 1.
*       CLEAR : LV_TABIX, LS_LIST.
*       READ TABLE GT_LIST INTO LS_LIST WITH KEY MATNR = <FSC>-MATNR
*                                                                            WERKS = <FSC>-WERKS BINARY SEARCH.
*       IF SY-SUBRC = 0.
*          LV_TABIX = SY-TABIX.
*
*          LS_LIST-STATUS    = ICON_LED_RED.
*          LS_LIST-TYPE        = GC_E.
*          LS_LIST-MESSAGE = LS_RT2-MESSAGE.
*
*       ENDIF.
*
*    ELSE.
*       CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
*          EXPORTING
*            WAIT = GC_X.
*
*       CLEAR : LV_TABIX, LS_LIST.
*       READ TABLE GT_LIST INTO LS_LIST WITH KEY MATNR = <FSC>-MATNR
*                                                                           WERKS = <FSC>-WERKS BINARY SEARCH.
*       IF SY-SUBRC = 0.
*          LV_TABIX = SY-TABIX.
*
*          LS_LIST-EKGRP     = GV_EKGRP.
*          LS_LIST-STATUS   = ICON_LED_GREEN.
*          LS_LIST-TYPE       = GC_S.
*          LS_LIST-MESSAGE = '구매그룹을 변경했습니다.'(M06).
*       ENDIF.
*    ENDIF.
*
*    MODIFY GT_LIST FROM LS_LIST INDEX LV_TABIX
*    TRANSPORTING EKGRP STATUS TYPE MESSAGE.
*  ENDLOOP.


ENDFORM.
*&---------------------------------------------------------------------*
*& FORM TEMPLATE_DOWNLOAD
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
*&      --> GC_ZGTMMR3000_OPT1
*&---------------------------------------------------------------------*
FORM TEMPLATE_DOWNLOAD  USING  PV_OBJID TYPE W3OBJID.

  DATA:
    LS_WWWDATA           TYPE WWWDATATAB,
    LV_DEFAULT_FILE_NAME TYPE STRING,
    LV_FILENAME          TYPE STRING,
    LV_PATH              TYPE STRING,
    LV_FULLPATH          TYPE STRING,
    LV_RC                TYPE SY-SUBRC.

  CONSTANTS
    LC_FILE_EXT          TYPE W3_NAME VALUE 'FILEEXTENSION'.

  "SMW0 조회
  SELECT SINGLE *
    FROM WWWDATA
   WHERE OBJID EQ @PV_OBJID
    INTO CORRESPONDING FIELDS OF @LS_WWWDATA.

  IF SY-SUBRC NE 0.
    EXIT.
  ENDIF.

  SELECT SINGLE
    VALUE
    FROM WWWPARAMS
    WHERE RELID EQ @LS_WWWDATA-RELID
    AND OBJID EQ @LS_WWWDATA-OBJID
    AND NAME EQ @LC_FILE_EXT
    INTO @DATA(LV_FILE_EXT).

  LV_FILE_EXT = COND #( WHEN LV_FILE_EXT IS INITIAL
                                        THEN 'Excel Files (*.xlsx)|*.xlsx' ELSE LV_FILE_EXT ).
  LV_DEFAULT_FILE_NAME = LS_WWWDATA-TEXT." && LV_FILE_EXT.

  CL_GUI_FRONTEND_SERVICES=>FILE_SAVE_DIALOG(
    EXPORTING
      DEFAULT_EXTENSION         =   CONV STRING( LV_FILE_EXT )
      DEFAULT_FILE_NAME         =   LV_DEFAULT_FILE_NAME
      FILE_FILTER                       =  CONV STRING( LV_FILE_EXT )
    CHANGING
         FILENAME                  =   LV_FILENAME
         PATH                          =   LV_PATH
         FULLPATH                  =   LV_FULLPATH
       EXCEPTIONS
         CNTL_ERROR                =   1
         ERROR_NO_GUI              =   2
         NOT_SUPPORTED_BY_GUI      =   3
         INVALID_DEFAULT_FILE_NAME =   4
         OTHERS                    =   5
     ).

  IF SY-SUBRC NE 0.
    MESSAGE ID SY-MSGID TYPE GC_S NUMBER SY-MSGNO
      WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4
      DISPLAY LIKE GC_E.
    EXIT.
  ENDIF.

  CHECK LV_FULLPATH IS NOT INITIAL.
  CALL FUNCTION 'DOWNLOAD_WEB_OBJECT'
    EXPORTING
      KEY         = LS_WWWDATA
      DESTINATION = CONV LOCALFILE( LV_FULLPATH )
    IMPORTING
      RC          = LV_RC.

  CHECK LV_RC EQ 0.

  CL_GUI_FRONTEND_SERVICES=>EXECUTE(
          EXPORTING
            DOCUMENT               = LV_FULLPATH
          EXCEPTIONS
            CNTL_ERROR             = 1
            ERROR_NO_GUI           = 2
            BAD_PARAMETER          = 3
            FILE_NOT_FOUND         = 4
            PATH_NOT_FOUND         = 5
            FILE_EXTENSION_UNKNOWN = 6
            ERROR_EXECUTE_FAILED   = 7
            SYNCHRONOUS_FAILED     = 8
            NOT_SUPPORTED_BY_GUI   = 9
            OTHERS                 = 10
        ).

  IF SY-SUBRC NE 0.
    MESSAGE ID SY-MSGID TYPE GC_S NUMBER SY-MSGNO
      WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4
      DISPLAY LIKE GC_E.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& FORM EXCEL_UPLOAD_OPT1
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
*& -->  P1        TEXT
*& <--  P2        TEXT
*&---------------------------------------------------------------------*
FORM EXCEL_UPLOAD.

*2-1) 1의 대상별 UPLOAD 파일 업로드 하여 ALV LIST 데이터로 반영
*2-2) EXCEL 업로드 시 ALV 에 데이터가 존재하면 데이터 CLEAR 후 엑셀 입력 데이터로 반영
*   TEXT 성 필드및 반영조건은 직접 입력하는 경우와 동일함
  DATA LV_CHECK TYPE C LENGTH 1.

  CALL METHOD GCL_GRID->CHECK_CHANGED_DATA
    IMPORTING
      E_VALID = LV_CHECK.

  CHECK LV_CHECK EQ ABAP_TRUE.

  DATA:
    LV_FILE TYPE RLGRAP-FILENAME,
    LT_XLS  TYPE STANDARD TABLE OF TY_OPT1_XLS.

  "파일명 선택
  PERFORM GET_FILE_NAME CHANGING LV_FILE.

  "EXCEL 조회
  CHECK LV_FILE IS NOT INITIAL.
  PERFORM GET_EXCEL_DATA USING 1 2 33 60000 LV_FILE 'TY_OPT1_XLS' CHANGING LT_XLS.

  "데이터 설정
  PERFORM SET_ALV_DATA_OPT1 USING LT_XLS CHANGING GT_LIST LV_CHECK.

ENDFORM.
*&---------------------------------------------------------------------*
*& FORM F_GET_FILE_NAME
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
*&      <-- LV_FILE
*&---------------------------------------------------------------------*
FORM GET_FILE_NAME  CHANGING CV_FILE.

  CLEAR CV_FILE.

  DATA:
    LT_FILE_TABLE TYPE FILETABLE,
    LV_SUBRC      TYPE SY-SUBRC,
    LV_ACTION     TYPE I.

  CALL METHOD CL_GUI_FRONTEND_SERVICES=>FILE_OPEN_DIALOG
    EXPORTING
*     WINDOW_TITLE            = ''
      DEFAULT_EXTENSION       = CL_GUI_FRONTEND_SERVICES=>FILETYPE_EXCEL
*     DEFAULT_FILENAME        = ''
      FILE_FILTER             = CL_GUI_FRONTEND_SERVICES=>FILETYPE_EXCEL
*     WITH_ENCODING           = ''
*     INITIAL_DIRECTORY       = 'C:\'
*     MULTISELECTION          = ' '
    CHANGING
      FILE_TABLE              = LT_FILE_TABLE
      RC                      = LV_SUBRC
      USER_ACTION             = LV_ACTION
    EXCEPTIONS
      FILE_OPEN_DIALOG_FAILED = 1
      CNTL_ERROR              = 2
      ERROR_NO_GUI            = 3
      NOT_SUPPORTED_BY_GUI    = 4
      OTHERS                  = 5.
  IF SY-SUBRC EQ 0 AND LT_FILE_TABLE[] IS NOT INITIAL.
    READ TABLE LT_FILE_TABLE ASSIGNING FIELD-SYMBOL(<LS_FILE>) INDEX 1.
    CHECK SY-SUBRC EQ 0.
    CV_FILE = <LS_FILE>-FILENAME.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& FORM GET_EXCEL_DATA
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
*&      --> P_1
*&      --> P_4
*&      --> P_1
*&      --> P_6000
*&      <-- LT_XLS
*&---------------------------------------------------------------------*
FORM GET_EXCEL_DATA  USING PV_BEGIN_COL
                                                      PV_BEGIN_ROW
                                                      PV_END_COL
                                                      PV_END_ROW
                                                      PV_FILE
                                                      PV_T_TYPE
                       CHANGING CT_XLS TYPE STANDARD TABLE.
  CLEAR:
     CT_XLS[].

  DATA LT_ITAB TYPE STANDARD TABLE OF ALSMEX_TABLINE.
  CALL FUNCTION 'ALSM_EXCEL_TO_INTERNAL_TABLE'
    EXPORTING
      FILENAME                = PV_FILE
      I_BEGIN_COL             = PV_BEGIN_COL
      I_BEGIN_ROW             = PV_BEGIN_ROW
      I_END_COL               = PV_END_COL
      I_END_ROW               = PV_END_ROW
    TABLES
      INTERN                  = LT_ITAB
    EXCEPTIONS
      INCONSISTENT_PARAMETERS = 1
      UPLOAD_OLE              = 2
      OTHERS                  = 3.

  CHECK SY-SUBRC EQ 0.

  DATA:
    LO_DATA    TYPE REF TO DATA,
    LV_COL_IDX TYPE INT4.

  FIELD-SYMBOLS <LS_STRU> TYPE ANY.

  "엑셀 셀 값이 따옴표(") 로 인해 옆 셀로 쪼개져 들어온 경우 병합/컬럼 재정렬
  PERFORM REPAIR_SPLIT_QUOTE_CELLS CHANGING LT_ITAB.

  CREATE DATA LO_DATA TYPE (PV_T_TYPE).
  ASSIGN LO_DATA->* TO <LS_STRU>.

  LOOP AT LT_ITAB ASSIGNING FIELD-SYMBOL(<LS_G>) GROUP BY ( ROW = <LS_G>-ROW )
                                                                             ASSIGNING FIELD-SYMBOL(<LS_GROUP>).

    "값 설정
    CLEAR <LS_STRU>.
    LOOP AT GROUP <LS_GROUP> ASSIGNING FIELD-SYMBOL(<LS_XLS>).
      LV_COL_IDX = <LS_XLS>-COL.
      ASSIGN COMPONENT LV_COL_IDX OF STRUCTURE <LS_STRU> TO FIELD-SYMBOL(<LV_VAL>).
      CHECK <LV_VAL> IS ASSIGNED.
      <LV_VAL> = <LS_XLS>-VALUE.
    ENDLOOP.

    "라인추가
    APPEND <LS_STRU> TO CT_XLS.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& FORM REPAIR_SPLIT_QUOTE_CELLS
*&---------------------------------------------------------------------*
*& TEXT : 엑셀 셀 값이 여는 따옴표(") 로 시작하고 닫는 따옴표 없이 끝나는 경우,
*&              바로 다음 컬럼 셀이(공백을 사이에 두고) 닫는 따옴표로 시작하면 두 셀을 하나로 병합하고
*&              같은 행의 이후 컬럼 번호를 1씩 당겨 재정렬한다.
*&              (엑셀/CSV 변환 시 텍스트서식 숫자 값의 따옴표가 옆 셀로 분리되어 들어와
*&               후속 컬럼 전체가 밀려 들어가는 것을 방지)
*&---------------------------------------------------------------------*
*&      <-> CT_ITAB
*&---------------------------------------------------------------------*
FORM REPAIR_SPLIT_QUOTE_CELLS CHANGING CT_ITAB TYPE TY_T_ALSMEX_LINE.

  DATA:
    LT_RESULT    TYPE TY_T_ALSMEX_LINE,
    LS_CUR       TYPE ALSMEX_TABLINE,
    LS_NEXT      TYPE ALSMEX_TABLINE,
    LV_CUR_VAL   TYPE STRING,
    LV_NEXT_VAL  TYPE STRING,
    LV_IDX       TYPE I,
    LV_LINES     TYPE I,
    LV_COL_SHIFT TYPE I,
    LV_ROW_NOW   TYPE I,
    LV_CUR_ROW   TYPE I,
    LV_CUR_COL   TYPE I,
    LV_NEXT_ROW  TYPE I,
    LV_NEXT_COL  TYPE I.

  CHECK CT_ITAB[] IS NOT INITIAL.
  SORT CT_ITAB BY ROW COL.

  LV_LINES = LINES( CT_ITAB ).
  LV_IDX   = 1.

  WHILE LV_IDX <= LV_LINES.
    READ TABLE CT_ITAB INDEX LV_IDX INTO LS_CUR.
    LV_ROW_NOW = LS_CUR-ROW.
    LV_CUR_COL = LS_CUR-COL.

    "행이 바뀌면 컬럼 보정값 초기화
    IF LV_ROW_NOW <> LV_CUR_ROW.
      LV_CUR_ROW   = LV_ROW_NOW.
      LV_COL_SHIFT = 0.
    ENDIF.

    LV_CUR_COL = LV_CUR_COL - LV_COL_SHIFT.
    LS_CUR-COL = LV_CUR_COL.

    "금액 뒤에 공백이 섞여 들어오는 경우까지 방어하기 위해, 공백 제거한 값으로 패턴 판단
    LV_CUR_VAL = LS_CUR-VALUE.
    CONDENSE LV_CUR_VAL.

    "여는 따옴표로 시작 + (공백 제거 후) 값 안에 닫는 따옴표가 없고, 바로 다음 원본 컬럼 셀이 있으면 후보로 판단
    IF LV_CUR_VAL IS NOT INITIAL AND LV_CUR_VAL(1) = '"'
       AND LV_CUR_VAL+1 NA '"'
       AND LV_IDX < LV_LINES.

      READ TABLE CT_ITAB INDEX LV_IDX + 1 INTO LS_NEXT.
      IF SY-SUBRC = 0.
        LV_NEXT_ROW = LS_NEXT-ROW.
        LV_NEXT_COL = LS_NEXT-COL.
      ENDIF.

      IF SY-SUBRC = 0
        AND LV_NEXT_ROW = LV_CUR_ROW
        AND LV_NEXT_COL = LV_CUR_COL + LV_COL_SHIFT + 1.

        "다음 셀도 앞뒤 공백을 제거한 뒤 닫는 따옴표로 시작하는지 판단(공백+따옴표 형태 방어)
        LV_NEXT_VAL = LS_NEXT-VALUE.
        CONDENSE LV_NEXT_VAL.

        IF LV_NEXT_VAL CP '"*'.
          LS_CUR-VALUE = LV_CUR_VAL+1 && LV_NEXT_VAL.
          REPLACE ALL OCCURRENCES OF '"' IN LS_CUR-VALUE WITH SPACE.
          CONDENSE LS_CUR-VALUE NO-GAPS.

          LV_COL_SHIFT = LV_COL_SHIFT + 1.       "이후 같은 행 셀들 컬럼 1씩 당김
          LV_IDX = LV_IDX + 1.                        "병합된 다음 셀은 건너뜀
        ENDIF.
      ENDIF.
    ENDIF.

    APPEND LS_CUR TO LT_RESULT.
    LV_IDX = LV_IDX + 1.
  ENDWHILE.

  CT_ITAB = LT_RESULT.

ENDFORM.
*&---------------------------------------------------------------------*
*& FORM SET_ALV_DATA_OPT1
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
*&      --> LT_XLS
*&      <-- GT_OPT1
*&      <-- LV_CHECK
*&---------------------------------------------------------------------*
FORM SET_ALV_DATA_OPT1  USING  PT_XLS TYPE TY_T_OPT1_XLS
                          CHANGING CT_OPT1 LIKE GT_LIST
                                          CV_CHECK.

  "초기화
  CLEAR:
    GV_ERR,
    CT_OPT1[],
    CV_CHECK.

  DATA:
    LT_FNAME   TYPE TY_T_FNAME,
    LS_OPT1    LIKE GS_LIST,
    LV_MSG TYPE BAPI_MSG,
    LV_AMT_EXT TYPE BAPICURR-BAPICURR,
    LV_AMT_INT TYPE MATDOC-DMBTR.

  LT_FNAME = VALUE #( ( FNAME =  'LIFNR' )
                                     ( FNAME =  'MATNR' )
                                     ( FNAME =  'EKORG' )
                                     ( FNAME =  'WERKS' )
                                     ( FNAME =  'ESOKZ' )
                                     ( FNAME =  'APLFZ' )
                                     ( FNAME =  'EKGRP' )
                                     ( FNAME =  'NORBM' )
                                     ( FNAME =  'UEBTO' )
                                     ( FNAME =  'UNTTO' )
                                     ( FNAME =  'UEBTK' )
                                     ( FNAME =  'VERID' )
                                     ( FNAME =  'WEBRE' )
                                     ( FNAME =  'XERSN' )
                                     ( FNAME =  'BATAE' )
                                     ( FNAME =  'DATAB' )
                                     ( FNAME =  'DATBI' )
                                     ( FNAME =  'KBETR' )
                                     ( FNAME =  'KPEIN' )
                                     ( FNAME =  'KMEIN' )
                                     ( FNAME =  'MWSKZ' )
                                     ( FNAME =  'KONWA' )
                                     ( FNAME =  'ZFR1' )
                                     ( FNAME =  'ZFR2' )
                                     ( FNAME =  'MEPRF' )
                                     ( FNAME =  'INCO1' ) ).

  LOOP AT PT_XLS ASSIGNING FIELD-SYMBOL(<LS_XLS>).
    CLEAR LS_OPT1.
    "대문자 변경
    TRANSLATE:
      <LS_XLS>-MATNR TO UPPER CASE,
      <LS_XLS>-WERKS TO UPPER CASE,
      <LS_XLS>-EKORG TO UPPER CASE,
      <LS_XLS>-LIFNR TO UPPER CASE,
      <LS_XLS>-WEBRE TO UPPER CASE,
      <LS_XLS>-XERSN TO UPPER CASE,
      <LS_XLS>-UEBTK TO UPPER CASE.

    "콤마 제거
    REPLACE ALL OCCURRENCES OF ',' IN <LS_XLS>-KBETR WITH SPACE.
    REPLACE ALL OCCURRENCES OF ',' IN <LS_XLS>-NORBM WITH SPACE.

    "숫자(0~9)/소수점(.)/부호(-) 외 문자 제거
    "    -> 엑셀 텍스트서식 셀에서 유입되는 큰따옴표(") 등 잡문자로 인한 CONVT_NO_NUMBER 덤프 방지
    ##REGEX_POSIX
    REPLACE ALL OCCURRENCES OF REGEX '[^0-9.\-]' IN <LS_XLS>-KBETR WITH SPACE.
    ##REGEX_POSIX
    REPLACE ALL OCCURRENCES OF REGEX '[^0-9.\-]' IN <LS_XLS>-NORBM WITH SPACE.

    "숫자만 남기고 제거)
    ##REGEX_POSIX
    REPLACE ALL OCCURRENCES OF REGEX '\D' IN <LS_XLS>-DATAB WITH SPACE.
    ##REGEX_POSIX
    REPLACE ALL OCCURRENCES OF REGEX '\D' IN <LS_XLS>-DATBI WITH SPACE.
    ##REGEX_POSIX
    REPLACE ALL OCCURRENCES OF REGEX '\D' IN <LS_XLS>-KPEIN  WITH SPACE.


    "공백 제거 (내부 공백까지 완전 제거)
    CONDENSE:
      <LS_XLS>-KBETR NO-GAPS,
      <LS_XLS>-NORBM NO-GAPS,
      <LS_XLS>-DATAB NO-GAPS,
      <LS_XLS>-DATBI NO-GAPS,
      <LS_XLS>-KPEIN NO-GAPS.


    "값 설정 - 숫자 변환 실패 시 덤프 대신 행 단위 오류로 처리
    TRY.
        LS_OPT1 = CORRESPONDING #( BASE ( LS_OPT1 )  <LS_XLS> ).
      CATCH CX_SY_CONVERSION_NO_NUMBER INTO DATA(LX_CONV_ERR).
        LS_OPT1-LIFNR   = <LS_XLS>-LIFNR.
        LS_OPT1-MATNR   = <LS_XLS>-MATNR.
        LS_OPT1-STATUS  = ICON_LED_RED.
        LS_OPT1-MESSAGE = |엑셀 데이터 형식 오류(숫자 항목 확인 필요): { LX_CONV_ERR->GET_TEXT( ) }|.
        APPEND LS_OPT1 TO CT_OPT1.
        CONTINUE.
    ENDTRY.

**INPUT VALIDATION.

    "ALPHA CONVERSION
    LS_OPT1-LIFNR = |{ LS_OPT1-LIFNR ALPHA = IN }|.

    "단위
    CALL FUNCTION 'CONVERSION_EXIT_CUNIT_INPUT'
      EXPORTING
        INPUT  = LS_OPT1-KMEIN
      IMPORTING
        OUTPUT = LS_OPT1-KMEIN.

    "자재코드
    CALL FUNCTION 'CONVERSION_EXIT_MATN1_INPUT'
      EXPORTING
        INPUT  = LS_OPT1-MATNR
      IMPORTING
        OUTPUT = LS_OPT1-MATNR.

    IF LS_OPT1-KBETR IS NOT INITIAL AND LS_OPT1-KONWA IS NOT INITIAL.
      CLEAR:
       LV_AMT_EXT,
       LV_AMT_INT.

      "금액 변환(EXT - > INT)
      LV_AMT_EXT = LS_OPT1-KBETR.
      CALL FUNCTION 'BAPI_CURRENCY_CONV_TO_INTERNAL'
        EXPORTING
          CURRENCY             = LS_OPT1-KONWA
          AMOUNT_EXTERNAL      = LV_AMT_EXT
          MAX_NUMBER_OF_DIGITS = 23
        IMPORTING
          AMOUNT_INTERNAL      = LV_AMT_INT.

      LS_OPT1-KBETR = LV_AMT_INT.
    ENDIF.

    APPEND LS_OPT1 TO CT_OPT1.

  ENDLOOP.

  CHECK CT_OPT1[] IS NOT INITIAL. "데이터가 있으면 진행
*자재_텍스트/단위/승인대상 데이터
  SELECT
    MR~MATNR,
    MR~MEINS,
    MR~MATKL,
    MR~ZZMAKTX80,
    MT~MAKTX,
    G~ZMANYN AS ZYN
    FROM MARA AS MR
    LEFT OUTER JOIN ZGTMMT1060 AS G "승인대상자재
    ON MR~MTART = G~MTART
    AND G~EKORG = @P_EKORG
    LEFT OUTER JOIN  MAKT AS MT
    ON MR~MATNR EQ MT~MATNR
    AND MT~SPRAS EQ @SY-LANGU
##ITAB_KEY_IN_SELECT
    WHERE EXISTS (
      SELECT ZZ~MATNR
        FROM @CT_OPT1 AS ZZ
        WHERE ZZ~MATNR EQ MR~MATNR
    )
    ORDER BY MR~MATNR
    INTO TABLE @DATA(LT_MARA).
*업체/업체명 데이터
  SELECT L~LIFNR, L~NAME1
    FROM LFA1 AS L
##ITAB_KEY_IN_SELECT
    WHERE EXISTS ( SELECT C~LIFNR
                                FROM @CT_OPT1 AS C
                                WHERE C~LIFNR EQ L~LIFNR )
    ORDER BY L~LIFNR INTO TABLE @DATA(LT_LFA1).
*승인상태 데이터
  SELECT
    GT~LIFNR, GT~MATNR, GT~EKORG,
    GT~WERKS,GT~ESOKZ,
    GT~APPROVED
    FROM ZGTMMT1061 AS GT
##ITAB_KEY_IN_SELECT
    WHERE EXISTS (
      SELECT ZZ~MATNR
        FROM @CT_OPT1 AS ZZ
        WHERE ZZ~MATNR EQ GT~MATNR
             AND ZZ~ESOKZ EQ GT~ESOKZ
             AND GT~EKORG EQ @P_EKORG
             AND GT~WERKS EQ @P_WERKS
    )
    ORDER BY GT~LIFNR, GT~MATNR, GT~ESOKZ
    INTO TABLE @DATA(LT_1061).
*인도조건(명) 데이터
  SELECT
     INCO1, BEZEI FROM TINCT AS T
##ITAB_KEY_IN_SELECT
     WHERE EXISTS (
         SELECT ZZ~INCO1
             FROM @CT_OPT1 AS ZZ
             WHERE  ZZ~INCO1 EQ T~INCO1
                  AND T~SPRAS = @SY-LANGU )
      ORDER BY T~INCO1
      INTO TABLE @DATA(LT_INCO).

*INPUT VALIDATION & TEXT SETTING
  LOOP AT CT_OPT1 ASSIGNING FIELD-SYMBOL(<LS_OPT1>).

    IF <LS_OPT1>-LIFNR IS INITIAL.
      <LS_OPT1>-STATUS = ICON_LED_RED.
      <LS_OPT1>-MESSAGE = '공급업체는 필수입력입니다.'.
    ELSE.
      READ TABLE LT_LFA1 ASSIGNING FIELD-SYMBOL(<LS_L>)
      WITH KEY LIFNR = <LS_OPT1>-LIFNR BINARY SEARCH.
      IF SY-SUBRC EQ 0.
        <LS_OPT1>-LIFNR_N = <LS_L>-NAME1.
      ELSE.
        <LS_OPT1>-STATUS = ICON_LED_RED.
        <LS_OPT1>-MESSAGE = '공급업체를 확인하세요.'.
        CLEAR : <LS_OPT1>-LIFNR, <LS_OPT1>-LIFNR_N.
      ENDIF.
    ENDIF.

    IF <LS_OPT1>-MATNR IS INITIAL.
      <LS_OPT1>-MESSAGE = '자재코드는 필수입력입니다.'.
      <LS_OPT1>-STATUS = ICON_LED_RED.
    ELSE.
      READ TABLE LT_MARA ASSIGNING FIELD-SYMBOL(<LS_MARA>)
      WITH KEY MATNR = <LS_OPT1>-MATNR BINARY SEARCH.
      IF SY-SUBRC EQ 0.
        <LS_OPT1>-MATNR_N = COND #( WHEN <LS_MARA>-ZZMAKTX80 IS INITIAL THEN <LS_MARA>-MAKTX
                                                            ELSE <LS_MARA>-ZZMAKTX80 ).

        <LS_OPT1>-MEINS =  <LS_MARA>-MEINS.
        <LS_OPT1>-ZYN = <LS_MARA>-ZYN.  "승인대상'
        <LS_OPT1>-S1 = COND #( WHEN <LS_OPT1>-ZYN IS INITIAL THEN SPACE
                                                  ELSE ICON_RELEASE ).      ""승인대상'ICON
      ELSE.
        <LS_OPT1>-STATUS = ICON_LED_RED.
        <LS_OPT1>-MESSAGE = '자재코드를 확인하세요.'.
        CLEAR : <LS_OPT1>-MATNR, <LS_OPT1>-MATNR_N, <LS_OPT1>-MEINS,
                     <LS_OPT1>-ZYN, <LS_OPT1>-S1.
      ENDIF.
*승인상태
      READ TABLE LT_1061 INTO DATA(LS_APP)
      WITH KEY LIFNR = <LS_OPT1>-LIFNR
                     MATNR = <LS_OPT1>-MATNR
                     ESOKZ = <LS_OPT1>-ESOKZ BINARY SEARCH.
      IF SY-SUBRC = 0.
        "승인상태&승인상태 아이콘
        <LS_OPT1>-APPROVED = LS_APP-APPROVED.
        <LS_OPT1>-S2 = COND #( WHEN <LS_OPT1>-APPROVED IS INITIAL THEN SPACE
                                                 ELSE ICON_MAIL ).
        CLEAR  LS_APP.
      ENDIF.
    ENDIF.

    <LS_OPT1>-WERKS = COND #( WHEN <LS_OPT1>-WERKS IS INITIAL THEN P_WERKS
                                                    WHEN <LS_OPT1>-WERKS NE P_WERKS THEN P_WERKS
                                                    ELSE <LS_OPT1>-WERKS ).

    <LS_OPT1>-EKORG = COND #( WHEN <LS_OPT1>-EKORG IS INITIAL THEN P_EKORG
                                                    WHEN <LS_OPT1>-EKORG NE P_WERKS THEN P_EKORG
                                                    ELSE <LS_OPT1>-EKORG ).

    <LS_OPT1>-EKGRP = COND #( WHEN <LS_OPT1>-EKGRP IS INITIAL THEN P_EKGRP
                                                    WHEN <LS_OPT1>-EKGRP NE P_EKGRP THEN P_EKGRP
                                                    ELSE <LS_OPT1>-EKGRP ).

*텍스트 설정
    PERFORM SET_CODE_TEXT_OPT1 USING LT_FNAME CHANGING <LS_OPT1>.

    IF <LS_OPT1>-ESOKZ IS NOT INITIAL.
      READ TABLE GT_ESOKZ ASSIGNING FIELD-SYMBOL(<ESOKZ>)
      WITH KEY DOMVALUE_L = <LS_OPT1>-ESOKZ BINARY SEARCH.
      IF SY-SUBRC EQ 0.
        <LS_OPT1>-ESOKZ_N = <ESOKZ>-DDTEXT.
      ELSE.
        CLEAR : <LS_OPT1>-ESOKZ, <LS_OPT1>-ESOKZ_N.
      ENDIF.
    ENDIF.

*필수입력 필드 빈 값 존재시, ICON RED
*>S.필드 별 구분하여 어느 필드 누락인지 상세표기 위해 로직 분리
" 텍스트 설정
    DATA(LV_FIELD_NAME) =
      COND STRING( WHEN <LS_OPT1>-DATAB  IS INITIAL THEN '단가 FROM'
                             WHEN <LS_OPT1>-DATBI   IS INITIAL THEN '단가 TO'
                             WHEN <LS_OPT1>-KBETR  IS INITIAL THEN '단가'
                             WHEN <LS_OPT1>-KPEIN   IS INITIAL THEN 'PER'
                             WHEN <LS_OPT1>-KMEIN   IS INITIAL THEN '단가단위'
                             WHEN <LS_OPT1>-KONWA IS INITIAL THEN '통화'
                             WHEN <LS_OPT1>-MWSKZ  IS INITIAL THEN 'TAX'
                           ).
    IF LV_FIELD_NAME IS NOT INITIAL.
      <LS_OPT1>-STATUS  = ICON_LED_RED.
      LV_MSG = |{ LV_FIELD_NAME }는 필수 입력입니다.|.
      <LS_OPT1>-MESSAGE = COND  #( WHEN <LS_OPT1>-MESSAGE IS INITIAL
                                                           THEN LV_MSG  ELSE <LS_OPT1>-MESSAGE && '/' && LV_MSG ).
    ENDIF.
*    IF <LS_OPT1>-DATAB IS INITIAL OR <LS_OPT1>-DATBI IS INITIAL OR
*      <LS_OPT1>-KBETR IS INITIAL OR <LS_OPT1>-KPEIN IS INITIAL OR
*      <LS_OPT1>-KMEIN IS INITIAL OR <LS_OPT1>-KONWA IS INITIAL OR
*      <LS_OPT1>-MWSKZ IS INITIAL.
*
*      <LS_OPT1>-STATUS = ICON_LED_RED.
*    ENDIF.
*<E.2026.08.06_ZGODEV04.

    IF <LS_OPT1>-MWSKZ IS NOT INITIAL.
      SELECT SINGLE TEXT1 FROM T007S
        WHERE KALSM = @GC_TAXKR
             AND SPRAS = @SY-LANGU
             AND MWSKZ = @<LS_OPT1>-MWSKZ
        INTO @DATA(LV_TEXT).

      IF SY-SUBRC = 0.
        <LS_OPT1>-MWSKZ_N = LV_TEXT.
      ELSE.
        <LS_OPT1>-STATUS = ICON_LED_RED.
        LV_MSG = '세금코드를 확인하세요'.
        <LS_OPT1>-MESSAGE = COND  #( WHEN <LS_OPT1>-MESSAGE IS INITIAL
                                              THEN LV_MSG  ELSE <LS_OPT1>-MESSAGE && '/' && LV_MSG ).
        CLEAR : <LS_OPT1>-MWSKZ, <LS_OPT1>-MWSKZ_N.
      ENDIF.
    ENDIF.

    IF <LS_OPT1>-INCO1 IS NOT INITIAL.
*       SELECT SINGLE BEZEI FROM TINCT
*         WHERE INCO1 = @<LS_OPT1>-INCO1
*              AND SPRAS = @SY-LANGU
*         INTO @DATA(LV_BEZEI).
      READ TABLE LT_INCO INTO DATA(LS_INCO)
      WITH KEY INCO1 = <LS_OPT1>-INCO1 BINARY SEARCH.
      IF SY-SUBRC = 0.
        <LS_OPT1>-INCO1_N = LS_INCO-BEZEI. "LV_BEZEI.
      ELSE.
        CLEAR : <LS_OPT1>-INCO1, <LS_OPT1>-INCO1_N.
      ENDIF.
    ENDIF.

    IF <LS_OPT1>-UEBTO IS NOT INITIAL.
      CLEAR : <LS_OPT1>-UEBTK.
    ENDIF.

    IF <LS_OPT1>-UEBTK = GC_X.
      CLEAR : <LS_OPT1>-UEBTO.
    ENDIF.

*입력 가능 필드 설정
    <LS_OPT1>-STYLE = VALUE #( BASE <LS_OPT1>-STYLE
        ( FIELDNAME = 'LIFNR' STYLE = CL_GUI_ALV_GRID=>MC_STYLE_ENABLED )
        ( FIELDNAME = 'MATNR' STYLE = CL_GUI_ALV_GRID=>MC_STYLE_ENABLED )
        ( FIELDNAME = 'EKORG' STYLE = CL_GUI_ALV_GRID=>MC_STYLE_ENABLED )
        ( FIELDNAME = 'WERKS' STYLE = CL_GUI_ALV_GRID=>MC_STYLE_ENABLED )
        ( FIELDNAME = 'EKGRP' STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED )
        ( FIELDNAME = 'ESOKZ' STYLE = CL_GUI_ALV_GRID=>MC_STYLE_ENABLED )
        ( FIELDNAME = 'APLFZ' STYLE = CL_GUI_ALV_GRID=>MC_STYLE_ENABLED )
        ( FIELDNAME = 'NORBM' STYLE = CL_GUI_ALV_GRID=>MC_STYLE_ENABLED )
        ( FIELDNAME = 'UEBTO' STYLE = CL_GUI_ALV_GRID=>MC_STYLE_ENABLED )
        ( FIELDNAME = 'UNTTO' STYLE = CL_GUI_ALV_GRID=>MC_STYLE_ENABLED )
        ( FIELDNAME = 'UEBTK' STYLE = CL_GUI_ALV_GRID=>MC_STYLE_ENABLED )
        ( FIELDNAME = 'WEBRE' STYLE = CL_GUI_ALV_GRID=>MC_STYLE_ENABLED )
        ( FIELDNAME = 'XERSN' STYLE = CL_GUI_ALV_GRID=>MC_STYLE_ENABLED )
        ( FIELDNAME = 'BSTAE' STYLE = CL_GUI_ALV_GRID=>MC_STYLE_ENABLED )
        ( FIELDNAME = 'DATAB' STYLE = CL_GUI_ALV_GRID=>MC_STYLE_ENABLED )
        ( FIELDNAME = 'DATBI' STYLE = CL_GUI_ALV_GRID=>MC_STYLE_ENABLED )
        ( FIELDNAME = 'KBETR' STYLE = CL_GUI_ALV_GRID=>MC_STYLE_ENABLED )
        ( FIELDNAME = 'KPEIN' STYLE = CL_GUI_ALV_GRID=>MC_STYLE_ENABLED )
        ( FIELDNAME = 'KMEIN' STYLE = CL_GUI_ALV_GRID=>MC_STYLE_ENABLED )
        ( FIELDNAME = 'KONWA' STYLE = CL_GUI_ALV_GRID=>MC_STYLE_ENABLED )
        ( FIELDNAME = 'MWSKZ' STYLE = CL_GUI_ALV_GRID=>MC_STYLE_ENABLED )
        ( FIELDNAME = 'MEPRF' STYLE = CL_GUI_ALV_GRID=>MC_STYLE_ENABLED )
        ( FIELDNAME = 'INCO1' STYLE = CL_GUI_ALV_GRID=>MC_STYLE_ENABLED ) ).

*인포유형에 따른 필드 제어
    IF <LS_OPT1>-ESOKZ = GC_3. "3일 경우, 편집 가능.
      <LS_OPT1>-STYLE = VALUE #( BASE <LS_OPT1>-STYLE
        ( FIELDNAME = 'VERID' STYLE = CL_GUI_ALV_GRID=>MC_STYLE_ENABLED )  ).

    ELSE."아니면, 편집 불가능
      <LS_OPT1>-STYLE = VALUE #( BASE <LS_OPT1>-STYLE
        ( FIELDNAME = 'VERID' STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED )  ).
    ENDIF.

  ENDLOOP.

 SORT GT_LIST BY EKORG WERKS MATNR LIFNR ESOKZ.

ENDFORM.
*&---------------------------------------------------------------------*
*& FORM SET_CODE_TEXT_OPT1
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
*&      --> LT_FNAME
*&      <-- <LS_OPT1>
*&---------------------------------------------------------------------*
FORM SET_CODE_TEXT_OPT1  USING  PT_FNAME TYPE TY_T_FNAME
                           CHANGING CS_OPT1 LIKE GS_LIST.

  "플랜트
  READ TABLE PT_FNAME WITH TABLE KEY FNAME = 'WERKS' TRANSPORTING NO FIELDS.
  IF SY-SUBRC EQ 0.
    CLEAR CS_OPT1-WERKS_N. "초기화
    READ TABLE GT_T001W ASSIGNING FIELD-SYMBOL(<LS_T001W>) WITH TABLE KEY WERKS = CS_OPT1-WERKS.
    IF SY-SUBRC EQ 0.
      CS_OPT1-WERKS_N = <LS_T001W>-NAME1.
    ENDIF.
  ENDIF.

  "구매조직
  READ TABLE PT_FNAME WITH TABLE KEY FNAME = 'EKORG' TRANSPORTING NO FIELDS.
  IF SY-SUBRC EQ 0.
    CLEAR CS_OPT1-EKORG_N. "초기화
    READ TABLE GT_T024E ASSIGNING FIELD-SYMBOL(<LS_T024E>) WITH TABLE KEY EKORG = CS_OPT1-EKORG.
    IF SY-SUBRC EQ 0.
      CS_OPT1-EKORG_N = <LS_T024E>-EKOTX.
    ENDIF.
  ENDIF.

  "구매그룹
  READ TABLE PT_FNAME WITH TABLE KEY FNAME = 'EKGRP' TRANSPORTING NO FIELDS.
  IF SY-SUBRC EQ 0.
    CLEAR CS_OPT1-EKGRP_N. "초기화
    READ TABLE GT_T024 ASSIGNING FIELD-SYMBOL(<LS_T024>) WITH TABLE KEY EKGRP = CS_OPT1-EKGRP.
    IF SY-SUBRC EQ 0.
      CS_OPT1-EKGRP_N = <LS_T024>-EKNAM.
    ENDIF.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& FORM SAVE_DATA
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
*& -->  P1        TEXT
*& <--  P2        TEXT
*&---------------------------------------------------------------------*
FORM SAVE_DATA.

  DATA :
    LS_EINA  TYPE MEWIEINA,
    LS_EEINA TYPE  MEWIEINA,
    LS_EINAX TYPE  MEWIEINAX,
    LS_EINE  TYPE  MEWIEINE,
    LS_EEINE TYPE	MEWIEINE,
    LS_EINEX TYPE  MEWIEINEX.

  DATA:
    lv_check       TYPE c LENGTH 1,
    lo_receiver    TYPE REF TO if_recipient_bcs,
    lo_email       TYPE REF TO cl_bcs,
    lo_email_body  TYPE REF TO cl_document_bcs,
    lx_exception   TYPE REF TO cx_bcs,
    lv_send_result TYPE c.

  DATA:
    COND_VALIDITY TYPE TABLE OF MEWIVALIDITY,
    CONDITION     TYPE TABLE OF MEWICONDITION.

  DATA:
    LS_RETURN TYPE BAPIRET2,
    LT_RETURN LIKE TABLE OF BAPIRET2,
    LT_RTN    LIKE TABLE OF BAPIRETURN.

  DATA : LT_LIST LIKE TABLE OF GS_LIST,
         LS_1020 TYPE ZGTMMT1020.

  DATA : LT_MAIL LIKE TABLE OF GS_LIST,
         LT_1061 LIKE TABLE OF ZGTMMT1061,
         LS_1061 LIKE ZGTMMT1061.

  DATA : LV_MESSAGE TYPE CHAR100,
         LV_MSG     TYPE STRING,
         LV_CHK.

  DATA :
    LV_AMT_EXT TYPE BAPICURR-BAPICURR,
    LV_AMT_INT  TYPE MATDOC-DMBTR.
  DATA : LV_KBETR TYPE KBETR_KOND.

  DATA:
    LV_EMAIL     TYPE AD_SMTPADR,
    LV_HEAD_TEXT TYPE SO_OBJ_DES.
  DATA:
    LV_LINE TYPE SO_TEXT255,
    LT_BODY TYPE BCSY_TEXT.

  DEFINE _BAPI_CURR.
  CLEAR:
       LV_AMT_EXT,
       LV_AMT_INT.

  LV_AMT_INT = &2.
  CALL FUNCTION 'BAPI_CURRENCY_CONV_TO_EXTERNAL'
    EXPORTING
      CURRENCY                 = &1
      AMOUNT_INTERNAL    = LV_AMT_INT
   IMPORTING
     AMOUNT_EXTERNAL    = LV_AMT_EXT
            .
   &2 = LV_AMT_EXT.
END-OF-DEFINITION.

  CLEAR : GV_ANSWER, GV_ERR, LT_LIST, LT_MAIL.

  PERFORM GET_SELECTED_ROWS USING GCL_GRID.
  CHECK GV_ERR IS INITIAL.

  LOOP AT GT_ROWS INTO GS_ROW.
    READ TABLE GT_LIST  INTO DATA(LS_LIST) INDEX GS_ROW-INDEX.
    IF SY-SUBRC = 0 .

      IF LS_LIST-STATUS = ICON_LED_RED.
        GV_ERR = GC_X.
        MESSAGE S000 WITH '오류 발생 건은 등록할 수 없습니다.'(E31)
        DISPLAY LIKE GC_E. EXIT.

      ELSEIF LS_LIST-APPROVED IS NOT INITIAL.
        GV_ERR = GC_X.
        MESSAGE S000 WITH '이미 승인 요청 중인 건은 추가 등록할 수 없습니다.'(E29)
        DISPLAY LIKE GC_E. EXIT.

      ELSE.
        APPEND LS_LIST TO LT_LIST. CLEAR LS_LIST.
      ENDIF.

    ENDIF.
  ENDLOOP.

  CHECK GV_ERR IS INITIAL.
  PERFORM POPUP_TO_CONFIRM_STEP  USING GC_N
                                                                 TEXT-M18 "INFORECORD 생성하시겠습니까?
                                                                 TEXT-M19 "승인 필요 건은 팀장 승인 후 반영됩니다.
                                                                 TEXT-T04.
  CHECK GV_ANSWER = GC_J.

    LV_HEAD_TEXT = '[승인요청]InfoRecord 변경에 대한 승인요청 드립니다.'(m16).


        LV_LINE = |<html><body style="font-size:14">|.
        LT_BODY = VALUE #( BASE LT_BODY ( LINE = LV_LINE ) ).
        LV_LINE = |<p>{ TEXT-EM1 }</p>|.

        LT_BODY = VALUE #( BASE LT_BODY ( LINE = LV_LINE ) ).
        LV_LINE = |<p>SAP T-code <strong>ZGTMMR1051</strong>에서 확인 부탁드립니다. </p>|.
        LT_BODY = VALUE #( BASE LT_BODY ( LINE = LV_LINE ) ).

        LV_LINE = |<table border=1 STYLE="border-collapse: collapse;border-color: #000000;font-size:11:width:700px" >|.
        LT_BODY = VALUE #( BASE LT_BODY ( LINE = LV_LINE ) ).

        LV_LINE = |<tr align="center" style="background-color: #B3B1B1" ><td width="200px"><strong>공급업체명</strong></td>|.
        LT_BODY = VALUE #( BASE LT_BODY ( LINE = LV_LINE ) ).
        LV_LINE = |<td width="200px" ><strong>자재명</strong></td>|.
        LT_BODY = VALUE #( BASE LT_BODY ( LINE = LV_LINE ) ).
        LV_LINE = |<td width="50px" ><strong>FROM</strong></td>|.
        LT_BODY = VALUE #( BASE LT_BODY ( LINE = LV_LINE ) ).
        LV_LINE = |<td width="50px" ><strong>TO</strong></td>|.
        LT_BODY = VALUE #( BASE LT_BODY ( LINE = LV_LINE ) ).
        LV_LINE = |<td width="100px" ><strong>단가</strong></td>|.
        LT_BODY = VALUE #( BASE LT_BODY ( LINE = LV_LINE ) ).
        LV_LINE = |<td width="100px" ><strong>통화</strong></td>|.
        LT_BODY = VALUE #( BASE LT_BODY ( LINE = LV_LINE ) ).

  LOOP AT LT_LIST ASSIGNING FIELD-SYMBOL(<FS>).
*승인대상 데이터 빈 값(승인미대상)인 경우->승인 요청 없이 INFORECORD변경.
    IF <FS>-ZYN IS INITIAL.
      CLEAR: LS_EINA, LS_EINAX, LS_EINE, LS_EINEX, COND_VALIDITY, CONDITION, LT_RTN.

      LS_EINA = VALUE #( MATERIAL = <FS>-MATNR
                                     VENDOR    = <FS>-LIFNR ).

      LS_EINAX = VALUE #( MATERIAL = GC_X
                                        VENDOR   = GC_X ).

      LS_EINE = VALUE #( PURCH_ORG = <FS>-EKORG
                                 PLANT         = <FS>-WERKS
                                 INFO_TYPE  = <FS>-ESOKZ
                                 CURRENCY  = <FS>-KONWA
                                 PUR_GROUP = <FS>-EKGRP
                                 PLND_DELRY = <FS>-APLFZ
                                 OVERDELTOL = <FS>-UEBTO
                                 UNDER_TOL   = <FS>-UNTTO
                                 UNLIMITED     = <FS>-UEBTK
                                 CONF_CTRL   = <FS>-BSTAE
                                 NRM_PO_QTY = <FS>-NORBM
                                 TAX_CODE     = <FS>-MWSKZ
                                 PRICEDATE    = <FS>-MEPRF
                                 INCOTERMS1 = <FS>-INCO1
                                 GR_BASEDIV  = <FS>-WEBRE
                                 VERSION       = <FS>-VERID
                                 NO_AUT_GR  = <FS>-XERSN ).

      LS_EINEX = VALUE #( PURCH_ORG  = COND #( WHEN <FS>-EKORG IS INITIAL THEN SPACE ELSE GC_X )
                                  PLANT            = COND #( WHEN <FS>-WERKS IS INITIAL THEN SPACE ELSE GC_X )
                                  INFO_TYPE     = COND #( WHEN <FS>-ESOKZ IS INITIAL THEN SPACE ELSE GC_X )
                                  CURRENCY     = COND #( WHEN <FS>-KONWA IS INITIAL THEN SPACE ELSE GC_X )
                                  PUR_GROUP   = COND #( WHEN <FS>-EKGRP IS INITIAL THEN SPACE ELSE GC_X )
                                  PLND_DELRY  = COND #( WHEN <FS>-APLFZ IS INITIAL THEN SPACE ELSE GC_X )
                                  OVERDELTOL  = COND #( WHEN <FS>-UEBTO IS INITIAL THEN SPACE ELSE GC_X )
                                  UNDER_TOL    = COND #( WHEN <FS>-UNTTO IS INITIAL THEN SPACE ELSE GC_X )
                                  UNLIMITED      = COND #( WHEN <FS>-UEBTK IS INITIAL THEN SPACE ELSE GC_X )
                                  CONF_CTRL    = COND #( WHEN <FS>-BSTAE IS INITIAL THEN SPACE ELSE GC_X )
                                  NRM_PO_QTY = COND #( WHEN <FS>-NORBM IS INITIAL THEN SPACE ELSE GC_X )
                                  TAX_CODE     = COND #( WHEN <FS>-MWSKZ IS INITIAL THEN SPACE ELSE GC_X )
                                  PRICEDATE     = COND #( WHEN <FS>-MEPRF IS INITIAL THEN SPACE ELSE GC_X )
                                  INCOTERMS1  = COND #( WHEN <FS>-INCO1 IS INITIAL THEN SPACE ELSE GC_X )
                                  GR_BASEDIV   = COND #( WHEN <FS>-WEBRE IS INITIAL THEN SPACE ELSE GC_X )
                                  VERSION        = COND #( WHEN <FS>-VERID IS INITIAL THEN SPACE ELSE GC_X )
                                  NO_AUT_GR   = COND #( WHEN <FS>-XERSN IS INITIAL THEN SPACE ELSE GC_X ) ).

      APPEND VALUE #( VALID_FROM = <FS>-DATAB
                                        VALID_TO     = <FS>-DATBI ) TO COND_VALIDITY.

        LV_KBETR = <FS>-KBETR.

       _BAPI_CURR <FS>-KONWA LV_KBETR.


      APPEND VALUE #( COND_COUNT = '01'
                              COND_TYPE  =  'PB00'
                              COND_VALUE = LV_KBETR
                              CURRENCY     = <FS>-KONWA
                              COND_P_UNT = <FS>-KPEIN
                              COND_UNIT    = <FS>-KMEIN ) TO CONDITION.

        IF <FS>-ZFR1 <> 0.
        APPEND VALUE #( COND_COUNT = '02'
                                COND_TYPE  =  'ZFR1'
                                COND_VALUE = <FS>-ZFR1
                                CURRENCY     = <FS>-ZFR1_UNIT ) TO CONDITION.

       ENDIF.

        IF <FS>-ZFR2 <> 0.
        APPEND VALUE #( COND_COUNT = '03'
                                COND_TYPE  =  'ZFR2'
                                COND_VALUE = <FS>-ZFR2
                                CURRENCY     = <FS>-ZFR1_UNIT ) TO CONDITION.

       ENDIF.


*-> 26.09.27 플랜트 구매조직 데이터 없는 인포레코드 처리 포함 공통 호출
      PERFORM MAINTAIN_INFORECORD TABLES COND_VALIDITY CONDITION LT_RTN
                                  CHANGING LS_EINA LS_EINAX LS_EINE LS_EINEX
                                           LS_EEINA LS_EEINE.

      IF LINE_EXISTS( LT_RTN[ TYPE = GC_E ] ) .
        CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
        READ TABLE LT_RTN INTO DATA(LS_RTN) WITH KEY TYPE = GC_E.

        READ TABLE GT_LIST ASSIGNING FIELD-SYMBOL(<RB>)
        WITH KEY EKORG = <FS>-EKORG
                       WERKS = <FS>-WERKS
                       MATNR = <FS>-MATNR
                       LIFNR   = <FS>-LIFNR
                       ESOKZ = <FS>-ESOKZ BINARY SEARCH.
        IF SY-SUBRC = 0.
          <RB>-STATUS    = ICON_LED_RED.
          <RB>-MESSAGE = LS_RTN-MESSAGE.
        ENDIF.

        IF LINES( LT_RTN ) > 1.
          LOOP AT LT_RTN INTO DATA(LS_RETN).
            CLEAR : LS_RETURN.
            CALL FUNCTION 'BALW_RETURN_TO_RET2'
                EXPORTING
                    RETURN_IN       = LS_RETN
                IMPORTING
                   RETURN_OU       = LS_RETURN                          .

            APPEND LS_RETURN TO LT_RETURN.
          ENDLOOP.
        ENDIF.

        <FS>-STATUS    = ICON_LED_RED.
        <FS>-MESSAGE = LS_RTN-MESSAGE.
        CONTINUE.

      ELSE.
        CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
          EXPORTING
            WAIT = 'X'.

        READ TABLE GT_LIST ASSIGNING FIELD-SYMBOL(<COM>)
        WITH KEY EKORG = <FS>-EKORG
                       WERKS = <FS>-WERKS
                       MATNR = <FS>-MATNR
                       LIFNR   = <FS>-LIFNR
                       ESOKZ = <FS>-ESOKZ BINARY SEARCH.
        IF SY-SUBRC = 0.
          <COM>-STATUS    = ICON_LED_GREEN.
          <COM>-MESSAGE = '업데이트 성공'(M15).
        ENDIF.
        <FS>-STATUS    = ICON_LED_GREEN.
        <FS>-MESSAGE = '업데이트 성공'(M15).
      ENDIF.

*-승인대상->ZGTMMT1061 저장 후 승인자에 메일 전송.
    ELSE.
      APPEND <FS> TO LT_MAIL. "메일 전송용

      CLEAR : LT_1061, LS_1061.
      LS_1061 = CORRESPONDING #( <FS>
                      MAPPING DATAB = DATAB
                                     DATBI = DATBI
                                     KBETR = KBETR
                                     KONWA = KONWA
                                     KPEIN = KPEIN
                                     KMEIN = KMEIN ) .
      LS_1061-APPROVED = GC_O.
      LS_1061-ERDAT = SY-DATUM.
      LS_1061-ERDAT_LOCAL = SY-DATLO.
      LS_1061-ERTIM = SY-UZEIT.
      LS_1061-ERTIM_LOCAL = SY-TIMLO.
      LS_1061-ERNAM = SY-UNAME.
      LS_1061-AEDAT = SY-DATLO.
      LS_1061-AEDAT_LOCAL = SY-DATLO.
      LS_1061-AETIM = SY-UZEIT.
      LS_1061-AETIM_LOCAL = SY-TIMLO.
      LS_1061-AENAM = SY-UNAME .

      APPEND LS_1061 TO  LT_1061.

       LV_LINE = |<tr><td align="center" >{ <FS>-LIFNR_N }</td>|.
       LT_BODY = VALUE #( BASE LT_BODY ( LINE = LV_LINE ) ).
       LV_LINE = |<td align="center" >{ <FS>-MATNR_N }</td>|.
       LT_BODY = VALUE #( BASE LT_BODY ( LINE = LV_LINE ) ).
       LV_LINE = |<td align="center" >{ <FS>-DATAB_I }</td>|.
       LT_BODY = VALUE #( BASE LT_BODY ( LINE = LV_LINE ) ).
       LV_LINE = |<td align="center" >{ <FS>-DATBI_I }</td>|.
       LT_BODY = VALUE #( BASE LT_BODY ( LINE = LV_LINE ) ).
       LV_LINE = |<td align="right" >{ LV_KBETR }</td>|.
       LT_BODY = VALUE #( BASE LT_BODY ( LINE = LV_LINE ) ).
       LV_LINE = |<td align="center" >{ <FS>-KONWA }</td>|.
       LT_BODY = VALUE #( BASE LT_BODY ( LINE = LV_LINE ) ).


      IF LT_1061[] IS NOT INITIAL.
        MODIFY ZGTMMT1061 FROM TABLE LT_1061.
        IF SY-SUBRC = 0.
          COMMIT WORK AND WAIT.

          READ TABLE GT_LIST ASSIGNING FIELD-SYMBOL(<CHRQ>)
          WITH KEY EKORG = <FS>-EKORG
                         WERKS = <FS>-WERKS
                         MATNR = <FS>-MATNR
                         LIFNR   = <FS>-LIFNR
                         ESOKZ = <FS>-ESOKZ BINARY SEARCH.
          IF SY-SUBRC = 0.
            <CHRQ>-STATUS    = ICON_LED_GREEN.
            <CHRQ>-MESSAGE =  '단가 변경 승인 요청 완료'(M14).
          ENDIF.
          <FS>-STATUS = ICON_LED_GREEN.
          <FS>-MESSAGE = '단가 변경 승인 요청 완료'(M14).
        ENDIF.
      ENDIF.

    ENDIF.

   ENDLOOP.

*승인권자에 메일 전송(승인 요청 건 있을 시)
   IF LT_MAIL[] IS NOT INITIAL.

        LV_LINE = |</table></body></html>|.
        LT_BODY = VALUE #( BASE LT_BODY ( LINE = LV_LINE ) ).

    SORT LT_LIST BY EKGRP LIFNR.
    DELETE ADJACENT DUPLICATES FROM LT_LIST COMPARING EKGRP LIFNR.
*EMAIL 전송대상 데이터 가져오기.
    SELECT FROM ZGTMMT1020
    FIELDS *
    WHERE WERKS = @P_WERKS
         AND EKGRP = @P_EKGRP
    INTO TABLE @DATA(LT_1020).
    SORT LT_1020 BY WERKS EKGRP.

        READ TABLE LT_1020 INTO DATA(LS_1020_T) WITH KEY EKGRP = P_EKGRP.

        SELECT SINGLE EMAIL AS USRID
         FROM ZGTMM_CV_GETUSERNAME_G
         WHERE USERID = @LS_1020_T-ANAME
           AND  SUBTY = '0007'
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

        IF LV_SEND_RESULT = GC_X.
            COMMIT WORK.
        ENDIF.


        CLEAR : LV_CHECK,    LO_RECEIVER ,  LO_EMAIL ,  LO_EMAIL_BODY ,  LX_EXCEPTION  ,    LV_SEND_RESULT.
        CLEAR  : GT_MTXT , LV_MSG , LT_BODY[], LT_BODY, LV_EMAIL , LT_MAIL[] , LT_MAIL.
   ENDIF.

   IF LT_RETURN[] IS NOT INITIAL.
      CALL FUNCTION 'C14ALD_BAPIRET2_SHOW'
          TABLES
            I_BAPIRET2_TAB = LT_RETURN .
   ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& FORM CALL_TRANSACTION
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
*&      --> P_
*&---------------------------------------------------------------------*
FORM CALL_TRANSACTION  USING   PV_CODE.

  DATA: LV_LIFNR TYPE LIFNR,
        LV_MATNR TYPE MATNR,
        LV_EKORG TYPE EKORG,
        LV_WERKS TYPE WERKS_D.

  CASE PV_CODE.
    WHEN 'ME11'.
      LV_EKORG = P_EKORG.
      LV_WERKS = P_WERKS.

      SET PARAMETER ID 'EKO' FIELD LV_EKORG.
      SET PARAMETER ID 'WRK' FIELD LV_WERKS.

      CALL TRANSACTION 'ME11' AND SKIP FIRST SCREEN.

    WHEN OTHERS.
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& FORM MAINTAIN_INFORECORD
*&---------------------------------------------------------------------*
*& 26.09.27 ME_INFORECORD_MAINTAIN 공통 호출 (CHANGE_INFORECORD / SAVE_DATA)
*& PO '정보레코드 갱신'으로 구매조직 단위(플랜트 공백)로만 생긴 인포레코드에
*& 플랜트 구매조직 데이터와 조건을 한 번에 넣으면 ME816(06725)로 실패
*&  → ① 조건 없이 플랜트 구매조직 데이터만 먼저 생성·COMMIT
*&    ② 같은 세션은 BAPI 버퍼로 새 플랜트 데이터를 못 보므로 조건은
*&       ZGTMM_IF_I_INFODATA_MAINTAIN을 새 세션(DESTINATION 'NONE')으로 호출
*&  → BAPI가 06725를 S로 돌려주고 아무것도 만들지 않으면 오류로 처리
*& (FG10 SET_INFORECORD와 동일 로직)
*&---------------------------------------------------------------------*
FORM MAINTAIN_INFORECORD TABLES PT_VALIDITY  STRUCTURE MEWIVALIDITY
                                PT_CONDITION STRUCTURE MEWICONDITION
                                PT_RTN       STRUCTURE BAPIRETURN
                         CHANGING PS_EINA  TYPE MEWIEINA
                                  PS_EINAX TYPE MEWIEINAX
                                  PS_EINE  TYPE MEWIEINE
                                  PS_EINEX TYPE MEWIEINEX
                                  PS_EEINA TYPE MEWIEINA
                                  PS_EEINE TYPE MEWIEINE.

  DATA : LT_EMPTY_VAL TYPE TABLE OF MEWIVALIDITY,
         LT_EMPTY_CON TYPE TABLE OF MEWICONDITION,
         LV_NEW_PLANT TYPE ABAP_BOOL,
         LV_RFC_MSG   TYPE C LENGTH 200.

  CLEAR PT_RTN[].

*기존 인포레코드가 있으면 번호 지정
  SELECT SINGLE INFNR FROM EINA
    WHERE MATNR = @PS_EINA-MATERIAL
      AND LIFNR = @PS_EINA-VENDOR
    INTO @DATA(LV_INFNR).
  IF SY-SUBRC = 0.
    PS_EINA-INFO_REC  = LV_INFNR.
    PS_EINAX-INFO_REC = GC_X.
  ENDIF.

*① 플랜트 구매조직 데이터가 없으면 조건 없이 먼저 생성·COMMIT
  IF LV_INFNR IS NOT INITIAL AND PS_EINE-PLANT IS NOT INITIAL.
    SELECT SINGLE @ABAP_TRUE FROM EINE
      WHERE INFNR = @LV_INFNR
        AND EKORG = @PS_EINE-PURCH_ORG
        AND WERKS = @PS_EINE-PLANT
        AND ESOKZ = @PS_EINE-INFO_TYPE
      INTO @DATA(LV_EINE_EXIST).
    IF SY-SUBRC <> 0.
      CALL FUNCTION 'ME_INFORECORD_MAINTAIN'
        EXPORTING
          I_EINA        = PS_EINA
          I_EINAX       = PS_EINAX
          I_EINE        = PS_EINE
          I_EINEX       = PS_EINEX
        TABLES
          COND_VALIDITY = LT_EMPTY_VAL
          CONDITION     = LT_EMPTY_CON
          RETURN        = PT_RTN.

      IF LINE_EXISTS( PT_RTN[ TYPE = GC_E ] ).
        CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
        LOOP AT PT_RTN ASSIGNING FIELD-SYMBOL(<LS_RTN>) WHERE TYPE = GC_E.
          <LS_RTN>-MESSAGE = |플랜트 { PS_EINE-PLANT } 구매조직 데이터 생성 실패: { <LS_RTN>-MESSAGE }|.
          EXIT.
        ENDLOOP.
        RETURN.
      ENDIF.

      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
        EXPORTING
          WAIT = 'X'.
      CLEAR PT_RTN[].
      LV_NEW_PLANT = ABAP_TRUE.
    ENDIF.
  ENDIF.

*② 조건 생성 — 방금 플랜트 데이터를 만든 경우 새 세션(래퍼가 COMMIT/ROLLBACK)
  IF LV_NEW_PLANT = ABAP_TRUE.
    CALL FUNCTION 'ZGTMM_IF_I_INFODATA_MAINTAIN' DESTINATION 'NONE'
      EXPORTING
        I_EINA                = PS_EINA
        I_EINAX               = PS_EINAX
        I_EINE                = PS_EINE
        I_EINEX               = PS_EINEX
        I_TEST                = SPACE
      IMPORTING
        E_EINA                = PS_EEINA
        E_EINE                = PS_EEINE
      TABLES
        COND_VALIDITY         = PT_VALIDITY
        CONDITION             = PT_CONDITION
        RETURN                = PT_RTN
      EXCEPTIONS
        SYSTEM_FAILURE        = 1 MESSAGE LV_RFC_MSG
        COMMUNICATION_FAILURE = 2 MESSAGE LV_RFC_MSG
        OTHERS                = 3.
    IF SY-SUBRC <> 0.
      APPEND VALUE #( TYPE = GC_E MESSAGE = |조건 생성(새 세션) 호출 실패: { LV_RFC_MSG }| ) TO PT_RTN.
    ENDIF.
    CALL FUNCTION 'RFC_CONNECTION_CLOSE'
      EXPORTING
        DESTINATION = 'NONE'
      EXCEPTIONS
        OTHERS      = 1.
  ELSE.
    CALL FUNCTION 'ME_INFORECORD_MAINTAIN'
      EXPORTING
        I_EINA        = PS_EINA
        I_EINAX       = PS_EINAX
        I_EINE        = PS_EINE
        I_EINEX       = PS_EINEX
      IMPORTING
        E_EINA        = PS_EEINA
        E_EINE        = PS_EEINE
      TABLES
        COND_VALIDITY = PT_VALIDITY
        CONDITION     = PT_CONDITION
        RETURN        = PT_RTN.
  ENDIF.

*06725(플랜트 구매조직 데이터 없음)는 S로 오고 아무것도 만들어지지 않으므로 오류로 처리
  IF LINE_EXISTS( PT_RTN[ CODE = '06725' ] ) AND NOT LINE_EXISTS( PT_RTN[ TYPE = GC_E ] ).
    APPEND VALUE #( TYPE    = GC_E
                    CODE    = '06725'
                    MESSAGE = |플랜트 { PS_EINE-PLANT } 구매조직 데이터가 없어 단가가 생성되지 않았습니다| ) TO PT_RTN.
  ENDIF.

ENDFORM.
