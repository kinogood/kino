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

      WHEN 'LIFNR'.     "공급업체
        _FCAT TEXT-F16.

      WHEN 'LIFNR_N'.    "업체명
        _FCAT TEXT-F17.

      WHEN 'MATNR'.        "자재코드
        _FCAT TEXT-F20.

      WHEN 'MATNR_N'.        "자재명
        _FCAT TEXT-F21.

      WHEN 'EKORG'.       "구매조직
        _FCAT TEXT-F10.

      WHEN 'EKORG_N'.  "구매조직명
        _FCAT TEXT-F11.

      WHEN 'WERKS'.       "플랜트
        _FCAT TEXT-F02.

      WHEN 'WERKS_N'.  "플랜트명
        _FCAT TEXT-F03.

      WHEN 'ESOKZ'.     "인포유형/특별지시자(구매)
        _FCAT TEXT-F18.

      WHEN 'ESOKZ_N'.   "유형명
        _FCAT TEXT-F19.

      WHEN 'EKGRP'.      "구매그룹
        _FCAT TEXT-F08.

      WHEN 'EKGRP_N'.     "구매그룹명
        _FCAT TEXT-F09.

      WHEN 'APLFZ'.        "계획납품일
        _FCAT TEXT-F04.

      WHEN 'NORBM'.     " 표준PO수량
        _FCAT TEXT-F05.

      WHEN 'MEINS'.        "단위
        _FCAT TEXT-F28.

      WHEN 'UEBTO'.  "초과허용%
        _FCAT TEXT-F22.

      WHEN 'UNTTO'.     "미달허용%
        _FCAT TEXT-F23.

      WHEN 'UEBTK'.     "무제한납품
        _FCAT TEXT-F24.

      WHEN 'VERID'.        "임가공버전
        _FCAT TEXT-F25.

      WHEN 'WEBRE'.        "GR기준IV
        _FCAT TEXT-F26.

      WHEN 'XERSN'.        "NO ERS
        _FCAT TEXT-F29.

      WHEN 'BSTAE'.        "확정관리
        _FCAT TEXT-F33.

*      WHEN 'BSTAE_N'.        "확정관리명
*        _FCAT TEXT-F35.

      WHEN 'DATAB'.        "단가 FROM
        _FCAT TEXT-F37.

      WHEN 'DATBI'.        "단가 TO
        _FCAT TEXT-F38.

      WHEN 'KBETR'.        "단가
        <FS_S_FCT>-CFIELDNAME = 'KONWA'.
        _FCAT TEXT-F31.

      WHEN 'KONWA'.        "통화
        _FCAT TEXT-F34.

      WHEN 'KPEIN'.        "PER
        _FCAT TEXT-F32.

      WHEN 'KMEIN'.        "단위
        _FCAT TEXT-F28.

      WHEN 'ZFR1'.        "단위
        _FCAT TEXT-F78.

      WHEN 'ZFR1_UNIT'.        "단위
        _FCAT TEXT-F79.

      WHEN 'ZFR2'.        "단위
        _FCAT TEXT-F80.

      WHEN 'ZFR1_UNIT'.        "단위
        _FCAT TEXT-F79.

      WHEN 'ZFR1_I'.        "단위
        _FCAT TEXT-F78.

      WHEN 'ZFR1_UNIT_I'.        "단위
        _FCAT TEXT-F79.

      WHEN 'ZFR2_I'.        "단위
        _FCAT TEXT-F80.

      WHEN 'ZFR1_UNIT_I'.        "단위
        _FCAT TEXT-F79.


      WHEN 'MEPRF'.     "가격결정일
        _FCAT TEXT-F40.

      WHEN 'MEPRF_N'.     "가격결정일명
        _FCAT TEXT-F43.

      WHEN 'INCO1'.        " 인도조건
        _FCAT TEXT-F41.

      WHEN 'INCO1_N'.        " 조건명
        _FCAT TEXT-F42.

      WHEN 'MWSKZ'.        "TAX
        _FCAT TEXT-F36.

      WHEN 'MWSKZ_N'.     "TAX명
        _FCAT TEXT-F39.

      WHEN 'ERDAT'.        " 생성일
        _FCAT TEXT-F44.

      WHEN 'ERDAT_LOCAL'.        " 생성일
        _FCAT TEXT-F49.

      WHEN 'ERTIM'.        " 생성시간
        _FCAT TEXT-F45.

      WHEN 'ERTIM_LOCAL'.        " 생성시간(LOCAL)
        _FCAT TEXT-F50.

      WHEN 'ERNAM'.        " 생성자
        _FCAT TEXT-F46.

      WHEN 'AEDAT'.        " 변경일
        _FCAT TEXT-F47.

      WHEN 'AEDAT_LOCAL'.        "변경일(LOCAL)
        _FCAT TEXT-F48.

      WHEN 'AETIM'.        " 변경시간
        _FCAT TEXT-F52.

      WHEN 'AETIM_LOCAL'.        "변경시간(LOCAL)
        _FCAT TEXT-F53.

      WHEN 'AENAM'.        " 변경자
        _FCAT TEXT-F51.

      WHEN 'MESSAGE'.   "메시지
        _FCAT TEXT-F68.

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
*                       STYLEFNAME = 'STYLE'
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

  CREATE OBJECT PO_EVENT.

  SET HANDLER :
  PO_EVENT->HANDLE_HOTSPOT_CLICK                FOR PCL_GRID,
  PO_EVENT->HANDLE_TOOLBAR                           FOR PCL_GRID,
  PO_EVENT->HANDLE_USER_COMMAND               FOR PCL_GRID.

ENDFORM.

*&---------------------------------------------------------------------*
*& FORM DISPLAY_ALV
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
FORM DISPLAY_ALV TABLES PT_LIST PT_FCAT.

  DATA(LS_VARINT) = VALUE DISVARIANT( REPORT  = SY-CPROG
                                           HANDLE  = '0001' ).

  CALL METHOD GCL_GRID->SET_TABLE_FOR_FIRST_DISPLAY
    EXPORTING
      IS_LAYOUT            = GS_LAYOUT
      IT_TOOLBAR_EXCLUDING = GT_EXCLUD[]
      IS_VARIANT           = LS_VARINT
      I_SAVE               = ZGTFI_A
    CHANGING
      IT_OUTTAB            = PT_LIST[] "GT_LIST[]
      IT_FIELDCATALOG      = PT_FCAT[]
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

DATA: lt_values TYPE TABLE OF USVALUES,
      ls_values TYPE USVALUES.

  CLEAR : S_ERDAT, S_ERDAT[]. "생성일
  S_ERDAT[] = VALUE #( ( SIGN     = GC_I
                                        OPTION = GC_BT
                                        LOW     = SY-DATLO - 30
                                        HIGH     = SY-DATLO ) ).

  CLEAR:
    GT_T001W[],
    GT_T024E[],
    GT_T024[].

  SELECT
    WERKS,
    NAME1
    FROM T001W
    INTO TABLE @GT_T001W.

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
      IF SY-SUBRC EQ 0. S_EKGRP-LOW = LS_VALUES-VON. ENDIF.


    ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*& FORM INPUT_VALIDATION
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
FORM INPUT_VALIDATION.

  CLEAR : GT_LIST, GV_ERR.

  IF S_ERDAT[] IS INITIAL.
    MESSAGE S000 WITH TEXT-E02 DISPLAY LIKE GC_E.
    GV_ERR = GC_X. STOP. "생성일은 필수 입력입니다.
  ENDIF.

*  IF  S_WERKS-LOW IS NOT INITIAL.
*    LOOP AT S_WERKS INTO DATA(LS_WERKS).
*
*      READ TABLE GT_T001W TRANSPORTING NO FIELDS
*      WITH TABLE KEY WERKS = LS_WERKS-LOW.
*
*      IF SY-SUBRC <> 0.
*        MESSAGE S000 WITH TEXT-M01 DISPLAY LIKE GC_E.
*        GV_ERR = GC_X. STOP. "유효하지 않은 플랜트 입니다.
*      ENDIF.
*
*    ENDLOOP.
*  ENDIF.

  IF P_WERKS IS NOT INITIAL.

    READ TABLE GT_T001W TRANSPORTING NO FIELDS
    WITH TABLE KEY WERKS = P_WERKS.

    IF SY-SUBRC <> 0.
      MESSAGE S000 WITH TEXT-M01 DISPLAY LIKE GC_E.
      GV_ERR = GC_X. STOP. "유효하지 않은 플랜트 입니다.
    ENDIF.

  ENDIF.

  IF  S_EKGRP-LOW IS NOT INITIAL.
    LOOP AT S_EKGRP INTO DATA(LS_EKGRP).

      READ TABLE GT_T024 TRANSPORTING NO FIELDS
      WITH TABLE KEY EKGRP = LS_EKGRP-LOW.

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

 LOOP AT S_EKGRP INTO DATA(LS_EKGRP).
  AUTHORITY-CHECK OBJECT 'ZCBO_MM001'
               ID 'EKGRP' FIELD LS_EKGRP-LOW.

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
*
*    IF  SCREEN-GROUP1 = 'CDP'. "조회및 변경OR단가변경이력조회일 경우 활성
*      SCREEN-ACTIVE = COND #( WHEN P_CRE = GC_X THEN 0 ELSE 1 ).
*    ENDIF.
*
*    IF  SCREEN-GROUP1 = 'CRE'. "생성일 경우 활성
*      SCREEN-ACTIVE = COND #( WHEN P_CRE = GC_X THEN 1 ELSE 0 ).
*    ENDIF.
*
*    IF  SCREEN-GROUP1 = 'DIS'. "조회및변경일 경우 활성
*      SCREEN-ACTIVE = COND #( WHEN P_DIS = GC_X THEN 1 ELSE 0 ).
*    ENDIF.
*
*    MODIFY SCREEN.

*  ENDLOOP.

ENDFORM.

*&---------------------------------------------------------------------*
*& FORM GET_DATA
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
FORM GET_DATA .

  CLEAR : GV_ERR, GT_LIST, GT_LIST[].

**데이터 가져오기
  SELECT FROM ZGTMM_CV_GET_INFO_APPROVE
      FIELDS *
      WHERE EKORG = @P_EKORG
         AND WERKS = @P_WERKS
         AND EKGRP IN @S_EKGRP
         AND LIFNR IN @S_LIFNR
         AND MATNR IN @S_MATNR
         AND ERDAT GE @S_ERDAT-LOW
         AND ERDAT LE @S_ERDAT-HIGH
        INTO CORRESPONDING FIELDS OF TABLE @GT_LIST.

      SORT GT_LIST BY EKORG WERKS MATNR LIFNR ESOKZ.

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
*& FORM SET_CELL_STYLE
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
FORM SET_CELL_STYLE USING PV_GB.

*  DATA : LS_STYLE TYPE LVC_S_STYL.
*
*  DEFINE _SET_STYLE.
*
*    LS_STYLE-FIELDNAME = &2.
*    CASE &1.
*      WHEN 'E'.
*        LS_STYLE-STYLE = CL_GUI_ALV_GRID=>MC_STYLE_ENABLED.
*      WHEN 'D'.
*        LS_STYLE-STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED.
*    ENDCASE.
*    INSERT LS_STYLE INTO TABLE &3.
*
*  END-OF-DEFINITION.
*
*  GCL_GRID->SET_READY_FOR_INPUT( 1 ). "입력가능
*
*  LOOP AT GT_LIST ASSIGNING FIELD-SYMBOL(<LS_LIST>).
*    CLEAR : <LS_LIST>-STYLE[].
*
*    IF P_DIS = GC_X.
*      _SET_STYLE : GC_E 'EKGRP' <LS_LIST>-STYLE,"ENABLED
*                            GC_D 'LIFNR' <LS_LIST>-STYLE,   "DISABLED
*                            GC_D 'MATNR' <LS_LIST>-STYLE,
*                            GC_D 'EKORG' <LS_LIST>-STYLE,
*                            GC_D 'WERKS' <LS_LIST>-STYLE,
*                            GC_D 'ESOKZ' <LS_LIST>-STYLE,
*                            GC_D 'DATAB' <LS_LIST>-STYLE,
*                            GC_D 'DATBI'  <LS_LIST>-STYLE,
*                            GC_D 'KBETR' <LS_LIST>-STYLE,
*                            GC_D 'KPEIN' <LS_LIST>-STYLE,
*                            GC_D 'KMEIN' <LS_LIST>-STYLE,
*                            GC_D 'KONWA' <LS_LIST>-STYLE.
*
*    ELSEIF P_CRE = GC_X.
*      _SET_STYLE : GC_D 'EKGRP' <LS_LIST>-STYLE,"DISABLED
*                            GC_E 'LIFNR' <LS_LIST>-STYLE,  "ENABLED
*                            GC_E 'MATNR' <LS_LIST>-STYLE,
*                            GC_E 'EKORG' <LS_LIST>-STYLE,
*                            GC_E 'WERKS' <LS_LIST>-STYLE,
*                            GC_E 'ESOKZ' <LS_LIST>-STYLE.
*    ENDIF.
*
*    "조회/생성 공통 편집가능 필드
*    _SET_STYLE : GC_E 'APLFZ' <LS_LIST>-STYLE,  "ENABLED
*                          GC_E 'NORBM' <LS_LIST>-STYLE,  "
*                          GC_E 'UEBTO' <LS_LIST>-STYLE,
*                          GC_E 'UNTTO' <LS_LIST>-STYLE,
*                          GC_E 'UEBTK' <LS_LIST>-STYLE,
*                          GC_E 'WEBRE' <LS_LIST>-STYLE,
*                          GC_E 'XERSN' <LS_LIST>-STYLE,
*                          GC_E 'BSTAE' <LS_LIST>-STYLE,
*                          GC_E 'MWSKZ' <LS_LIST>-STYLE,
*                          GC_E 'MEPRF' <LS_LIST>-STYLE,
*                          GC_E 'INCO1' <LS_LIST>-STYLE.
*
*    IF <LS_LIST>-ESOKZ = GC_3.
*      _SET_STYLE : GC_E 'VERID' <LS_LIST>-STYLE.
*    ELSE.
*      _SET_STYLE : GC_D 'VERID' <LS_LIST>-STYLE.
*    ENDIF.
*
*    IF <LS_LIST>-APPROVED IS INITIAL.
*      IF P_DIS = GC_X.
*        _SET_STYLE : GC_E 'DATAB_I' <LS_LIST>-STYLE,
*                              GC_E 'DATBI_I' <LS_LIST>-STYLE,
*                              GC_E 'KBETR_I' <LS_LIST>-STYLE,
*                              GC_E 'KPEIN_I' <LS_LIST>-STYLE,
*                              GC_E 'KMEIN_I' <LS_LIST>-STYLE.
*      ELSEIF P_CRE = GC_X.
*        _SET_STYLE : GC_E 'DATAB' <LS_LIST>-STYLE,
*                              GC_E 'DATBI' <LS_LIST>-STYLE,
*                              GC_E 'KBETR' <LS_LIST>-STYLE,
*                              GC_E 'KPEIN' <LS_LIST>-STYLE,
*                              GC_E 'KMEIN' <LS_LIST>-STYLE,
*                              GC_E 'KONWA' <LS_LIST>-STYLE.
*      ENDIF.
*
*    ELSE. "해당필드 값 있으면 DISPLAY
*      IF P_DIS = GC_X.
*        _SET_STYLE : GC_D 'DATAB_I' <LS_LIST>-STYLE,
*                              GC_D 'DATBI_I' <LS_LIST>-STYLE,
*                              GC_D 'KBETR_I' <LS_LIST>-STYLE,
*                              GC_D 'KPEIN_I' <LS_LIST>-STYLE,
*                              GC_D 'KMEIN_I' <LS_LIST>-STYLE.
*
*      ELSEIF P_CRE = GC_X.
*        _SET_STYLE : GC_D 'DATAB' <LS_LIST>-STYLE,
*                              GC_D 'DATBI' <LS_LIST>-STYLE,
*                              GC_D 'KBETR' <LS_LIST>-STYLE,
*                              GC_D 'KPEIN' <LS_LIST>-STYLE,
*                              GC_D 'KMEIN' <LS_LIST>-STYLE,
*                              GC_D 'KONWA' <LS_LIST>-STYLE.
*      ENDIF.
*    ENDIF.
*
*  ENDLOOP.

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

        _SET_TBAR 3 '    ' '              ' '    '.
        _SET_TBAR 0 'REFRESH' '' 'REFRESH'(B01).
        _SET_TBAR 0 'APPROVE' ''  '승인'(B02).

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
*      PERFORM REFRESH_TABLE USING GCL_GRID SPACE.
      PERFORM GET_DATA.
      PERFORM REFRESH_TABLE USING GCL_GRID SPACE.

    WHEN 'APPROVE' .
      PERFORM CHANGE_INFORECORD.
      PERFORM REFRESH_TABLE USING GCL_GRID SPACE.

    WHEN OTHERS.
  ENDCASE.


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
  DATA : LV_LIFNR TYPE LIFNR,
         LV_MATNR TYPE MATNR,
         LV_MWSKZ TYPE MWSKZ.

  LOOP AT PO_DATA_CHANGED->MT_GOOD_CELLS INTO DATA(LS_MOD_CELLS).

    READ TABLE GT_LIST  INTO DATA(LS_LIST) INDEX LS_MOD_CELLS-ROW_ID.
    CHECK SY-SUBRC EQ 0.

    CASE LS_MOD_CELLS-FIELDNAME.

      WHEN 'LIFNR'.
*        LV_LIFNR = LS_MOD_CELLS-VALUE.
*        SELECT SINGLE NAME1 FROM LFA1
*            WHERE LIFNR = @LV_LIFNR INTO @DATA(LV_NAME).
*
*        IF LV_NAME IS INITIAL.
*          CLEAR LS_MOD_CELLS-VALUE.
*          LV_ERR = GC_X.
*          PERFORM ADD_ENTRY USING PO_DATA_CHANGED LS_MOD_CELLS-FIELDNAME
*                                                       LS_MOD_CELLS-ROW_ID.
*        ENDIF.
*
*        CLEAR LS_LIST-STATUS.
*        LS_LIST-STATUS = COND #( WHEN LS_MOD_CELLS-VALUE IS INITIAL THEN ICON_LED_RED
*                                                   WHEN LV_NAME IS INITIAL THEN ICON_LED_RED
*                                                   ELSE ICON_CHANGE ).
*        LS_LIST-LIFNR_N = COND #( WHEN LS_MOD_CELLS-VALUE IS INITIAL THEN SPACE
*                                                    ELSE LV_NAME ).
*
*        PERFORM MODIFY_CELL USING PO_DATA_CHANGED 'LIFNR'
*                                              LS_MOD_CELLS-VALUE LS_MOD_CELLS-ROW_ID.

      WHEN 'MATNR'.
*        LV_MATNR = LS_MOD_CELLS-VALUE.
*        SELECT SINGLE ZZMAKTX80 FROM MARA
*           WHERE MATNR = @LV_MATNR INTO @DATA(LV_MKTX).
*
*        IF LV_MKTX IS INITIAL.
*          SELECT SINGLE MAKTX FROM MAKT
*          WHERE MATNR = @LV_MATNR
*               AND SPRAS = @SY-LANGU INTO @LV_MKTX.
*        ENDIF.
*
*        IF LV_MKTX IS INITIAL.
*          CLEAR LS_MOD_CELLS-VALUE.
*          LV_ERR = GC_X.
*          PERFORM ADD_ENTRY USING PO_DATA_CHANGED LS_MOD_CELLS-FIELDNAME
*                                                       LS_MOD_CELLS-ROW_ID.
*        ENDIF.
*
*        CLEAR LS_LIST-STATUS.
*        LS_LIST-STATUS = COND #( WHEN LS_MOD_CELLS-VALUE IS INITIAL THEN ICON_LED_RED
*                                                   WHEN LV_MKTX IS INITIAL THEN ICON_LED_RED
*                                                   ELSE ICON_CHANGE ).
*        LS_LIST-MATNR_N = COND #( WHEN LS_MOD_CELLS-VALUE IS INITIAL THEN SPACE
*                                                      ELSE LV_MKTX ).
*
*        PERFORM MODIFY_CELL USING PO_DATA_CHANGED 'MATNR'
*                                              LS_MOD_CELLS-VALUE LS_MOD_CELLS-ROW_ID.
**단위_자재 변경 시마다 체크
*        SELECT SINGLE MEINS FROM MARA
*          WHERE MATNR = @LS_MOD_CELLS-VALUE
*          INTO @DATA(LV_MEINS).
*
*        LS_LIST-MEINS = COND #( WHEN LV_MEINS IS INITIAL THEN SPACE ELSE LV_MEINS ).

      WHEN OTHERS.
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

*  CHECK PO_SENDER = GCL_GRID .
*  CHECK PS_ROW_NO-ROWTYPE IS INITIAL.
*
*  CASE PO_SENDER.
*
*    WHEN GCL_GRID.
*      IF P_PR = GC_X.
*
*        READ TABLE GT_LIST INTO DATA(LS_LIST) INDEX PS_ROW_NO-INDEX.
*        CHECK SY-SUBRC = 0.
*
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
*
**      ELSEIF PS_COLUMN-FIELDNAME = 'CHECK'.
**        IF <LS_LIST_1>-CHECK IS INITIAL.
**          <LS_LIST_1>-CHECK = ABAP_TRUE.
**        ELSE.
**          CLEAR <LS_LIST_1>-CHECK.
**        ENDIF.
**
**        PERFORM REFRESH_TABLE USING GCL_GRID SPACE.
**        CALL METHOD CL_GUI_CFW=>SET_NEW_OK_CODE
**          EXPORTING
**            NEW_CODE = 'ENTER'.
*
*        ELSE.
*          EXIT.
*        ENDIF.
*
*      ELSE.
*
*        READ TABLE GT_CREATE INTO DATA(LS_CRE) INDEX PS_ROW_NO-INDEX.
*        CHECK SY-SUBRC = 0.
*
*        IF PS_COLUMN-FIELDNAME = 'EBELN'.
*          CHECK LS_CRE-EBELN IS NOT INITIAL.
*
*          SET PARAMETER ID 'BES' FIELD LS_CRE-EBELN.
*          CALL TRANSACTION 'ME23N' AND SKIP FIRST SCREEN.
*
*        ELSE.
*          EXIT.
*        ENDIF.
*
*      ENDIF.
*  ENDCASE.

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

*  DATA : LT_RETURN TYPE TABLE OF DDSHRETVAL,
*             LS_RETURN TYPE DDSHRETVAL,
*             LS_MODI      TYPE LVC_S_MODI.
*
*   FIELD-SYMBOLS : <F4TAB> TYPE LVC_T_MODI.
*   ASSIGN ER_EVENT_DATA->M_DATA->* TO <F4TAB>.
*
**  CASE E_FIELDNAME.
**    WHEN .
**    WHEN .
**    WHEN OTHERS.
**  ENDCASE.
*
*  CLEAR : LS_RETURN, LT_RETURN.
*
*  IF E_FIELDNAME = 'MWSKZ'.
**"데이터 추출 (KALSM = 'TAXKR' 필터 및 텍스트 조인)
*    SELECT A~KALSM, A~MWSKZ, S~TEXT1
*      FROM T007A AS A
*      LEFT JOIN T007S AS S ON A~KALSM  = S~KALSM
*                                      AND A~MWSKZ = S~MWSKZ
*                                      AND S~SPRAS  = @SY-LANGU
*      WHERE A~KALSM = @GC_TAXKR
*      INTO TABLE @DATA(LT_TEMP).
*
**F4 HELP 호출
*    CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
*      EXPORTING
*        RETFIELD        = 'MWSKZ'         " 내부 테이블에서 가져올 필드명
*        WINDOW_TITLE    = '세금 코드 선택'
*        VALUE_ORG       = 'S'
*      TABLES
*        VALUE_TAB       = LT_TEMP       " 데이터가 담긴 ITAB
*        RETURN_TAB      = LT_RETURN   " 사용자가 선택한 행의 정보가 담김
*      EXCEPTIONS
*        PARAMETER_ERROR = 1
*        NO_VALUES_FOUND = 2
*        OTHERS          = 3.
*
*    IF SY-SUBRC <> 0.
*      MESSAGE S000 WITH 'POSSIBLE ENTRY DATA가 없습니다 !!!'.
*    ENDIF.
*
*    IF SY-SUBRC = 0 AND LT_RETURN IS NOT INITIAL.
*        READ TABLE LT_RETURN INTO LS_RETURN INDEX 1.
*
*        CLEAR : LS_MODI.
*        LS_MODI-ROW_ID      = ES_ROW_NO-ROW_ID.
*        LS_MODI-FIELDNAME =  'MWSKZ' .
*        LS_MODI-VALUE        = LS_RETURN-FIELDVAL.
*        APPEND LS_MODI TO <F4TAB>.
*    ENDIF.
*
*  ENDIF.
*
** TO AVOID STANDARD F4-HELP.
*ER_EVENT_DATA->M_EVENT_HANDLED = 'X'.

ENDFORM.                                                    " ON_F4
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
      WHEN 'APPROVE'.
        LV_MSG = '승인 대상을 선택하세요.'(E03).
      WHEN OTHERS.
        LV_MSG = '변경 대상을 선택하세요.'(E07).
    ENDCASE.

    MESSAGE S000 WITH LV_MSG DISPLAY LIKE GC_E.
  ENDIF.

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
    LS_RETURN TYPE BAPIRET2,
    LT_RETURN LIKE TABLE OF BAPIRET2,
    LT_RTN    LIKE TABLE OF BAPIRETURN.

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
    LV_AMT_EXT TYPE BAPICURR-BAPICURR,
    LV_AMT_INT  TYPE MATDOC-DMBTR.

   DATA : LV_KBETR TYPE KBETR_KOND.

  CLEAR : GV_ANSWER, GV_ERR.

  PERFORM GET_SELECTED_ROWS USING GCL_GRID.
  CHECK GV_ERR IS INITIAL.

  PERFORM POPUP_TO_CONFIRM_STEP USING GC_N
                                                            TEXT-M04 "승인된 정보는 인포레코드 단가 정보를 변경합니다.
                                                            TEXT-M05 "단가 변경을 승인 하시겠습니까?
                                                            TEXT-T04. " 확인
  CHECK GV_ANSWER = GC_J.

  LOOP AT GT_ROWS INTO GS_ROW.

      READ TABLE GT_LIST ASSIGNING FIELD-SYMBOL(<FS>) INDEX GS_ROW-INDEX.
      IF SY-SUBRC = 0 AND <FS>-STATUS <> ICON_LED_GREEN.
*인포레코드 변경용 데이터 구성
        CLEAR: LS_EINA, LS_EINAX, LS_EINE, LS_EINEX, COND_VALIDITY, CONDITION, LT_RTN, LV_KBETR.

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

        IF <FS>-ZFR1_I IS NOT INITIAL.
        APPEND VALUE #( COND_COUNT = '02'
                                COND_TYPE  =  'ZFR1'
                                COND_VALUE = <FS>-ZFR1
                                CURRENCY     = <FS>-ZFR1_UNIT ) TO CONDITION.

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


        CALL FUNCTION 'ME_INFORECORD_MAINTAIN'
            EXPORTING
              I_EINA        = LS_EINA
              I_EINAX     = LS_EINAX
              I_EINE        = LS_EINE
              I_EINEX       = LS_EINEX
            IMPORTING
              E_EINA        = LS_EEINA
              E_EINE        = LS_EEINE
            TABLES
              COND_VALIDITY = COND_VALIDITY
              CONDITION       = CONDITION
              RETURN          = LT_RTN.

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

*ZGTMMT1061 UPDATE_인포레코드 변경 및 생성 승인 상태 관리
            UPDATE ZGTMMT1061
                  SET APPROVED = SPACE
                         AEDAT = SY-DATUM
                         AEDAT_LOCAL = SY-DATLO
                         AETIM = SY-UZEIT
                         AETIM_LOCAL = SY-TIMLO
                         AENAM = SY-UNAME
             WHERE MATNR = <FS>-MATNR
                  AND LIFNR = <FS>-LIFNR
                  AND EKORG = <FS>-EKORG
                  AND WERKS = <FS>-WERKS
                  AND ESOKZ = <FS>-ESOKZ.
          ENDIF.

      ENDIF.
    ENDLOOP.

    IF LT_RETURN[] IS NOT INITIAL.
        CALL FUNCTION 'C14ALD_BAPIRET2_SHOW'
          TABLES
            I_BAPIRET2_TAB = LT_RETURN .
    ENDIF.

ENDFORM.
