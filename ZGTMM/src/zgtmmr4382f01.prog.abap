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
            SET_EVENT        CHANGING GCL_EVENT GCL_GRID.

  IF P_SCRP = GC_X.
    PERFORM  DISPLAY_ALV TABLES GT_LIST GT_FCAT.
  ELSEIF P_DISP = GC_X.
    PERFORM  DISPLAY_ALV TABLES GT_DISP GT_FCAT_DISP.
  ENDIF.

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

      WHEN 'WERKS'.       "플랜트
        _FCAT TEXT-F02.

      WHEN 'NAME1'.  "플랜트명
        _FCAT TEXT-F03.

      WHEN 'LGORT'.     "저장위치
        _FCAT TEXT-F04.

      WHEN 'LGOBE'.    "저장위치명
        _FCAT TEXT-F05.

      WHEN 'BWART'.     "이동유형
        _FCAT TEXT-F18.

      WHEN 'BTEXT'.    "이동유형명
        _FCAT TEXT-F19.

      WHEN 'MATNR'.        "자재코드
        _FCAT TEXT-F06.

      WHEN 'MAKTX'.        "자재명
        _FCAT TEXT-F07.

      WHEN 'CHARG'.       "배치번호
        _FCAT TEXT-F08.

      WHEN 'TAGNR'.  "꼬리표번호
        _FCAT TEXT-F09.

      WHEN 'LABST'.       "재고수량
        _FCAT TEXT-F10.
        <FS_S_FCT>-QFIELDNAME = 'MEINS'.

      WHEN 'MEINS'.        "단위
        _FCAT TEXT-F11.

      WHEN 'MENGE'.     "처리수량
        _FCAT TEXT-F12.
        <FS_S_FCT>-EDIT =  GC_X .
        <FS_S_FCT>-QFIELDNAME = 'MEINS'.

      WHEN 'KOSTL'.   "코스트센터
        _FCAT TEXT-F23.
        <FS_S_FCT>-EDIT =  GC_X .
        <FS_S_FCT>-F4AVAILABL = GC_X.
        <FS_S_FCT>-REF_TABLE = 'CSKS'.
        <FS_S_FCT>-REF_FIELD  = 'KOSTL'.
        <FS_S_FCT>-CHECKTABLE = '!'.

      WHEN 'KTEXT'.   "코스트센터명
        _FCAT TEXT-F24.

      WHEN 'SAKTO'.   "G/L 계정
        _FCAT TEXT-F25.
        <FS_S_FCT>-EDIT =  GC_X .
        <FS_S_FCT>-F4AVAILABL = GC_X.
        <FS_S_FCT>-REF_TABLE = 'EBKN'.
        <FS_S_FCT>-REF_FIELD = 'SAKTO'.
        <FS_S_FCT>-CHECKTABLE = '!'.

      WHEN 'TXT20'.   "G/L 계정 내역
        _FCAT TEXT-F26.

      WHEN 'AUFNR'.   "오더번호
        _FCAT TEXT-F27.
        <FS_S_FCT>-EDIT =  GC_X .
*        <FS_S_FCT>-F4AVAILABL = GC_X.
        <FS_S_FCT>-REF_TABLE = 'AUFK'.
        <FS_S_FCT>-REF_FIELD  = 'AUFNR'.
        <FS_S_FCT>-CHECKTABLE = '!'.

      WHEN 'AUFNR_N'.   "오더명
        _FCAT TEXT-F28.

      WHEN 'MBLNR'.   "자재문서
        _FCAT TEXT-F13.
        <FS_S_FCT>-HOTSPOT = GC_X.

      WHEN 'MESSAGE'.   "처리메시지
        _FCAT TEXT-F14.

      WHEN OTHERS.
        <FS_S_FCT>-NO_OUT  = GC_X.

    ENDCASE.

    APPEND <FS_S_FCT> TO GT_FCAT.
  ENDLOOP.

ENDFORM.

*&---------------------------------------------------------------------*
*& FORM ADJUST_FLDCATS_DISP
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
FORM ADJUST_FLDCATS_DISP  TABLES PT_FCAT TYPE LVC_T_FCAT.

  DEFINE _FCAT.
    <FS_S_FCT>-SCRTEXT_S  =
    <FS_S_FCT>-SCRTEXT_M  =
    <FS_S_FCT>-SCRTEXT_L  =
    <FS_S_FCT>-COLTEXT    =
    <FS_S_FCT>-REPTEXT    = &1.
  END-OF-DEFINITION.

  DATA LV_COL TYPE I.
  CLEAR : GT_FCAT_DISP[].

  LOOP AT PT_FCAT ASSIGNING FIELD-SYMBOL(<FS_S_FCT>).
    CLEAR : <FS_S_FCT>-COL_POS.

    CASE <FS_S_FCT>-FIELDNAME.
      WHEN 'STATUS'. "상태
        _FCAT TEXT-F01.

      WHEN 'SMBLN'.       "취소자재문서
        _FCAT TEXT-F15.
        <FS_S_FCT>-HOTSPOT = GC_X.

      WHEN 'MBLNR'.   "자재문서
        _FCAT TEXT-F13.
        <FS_S_FCT>-HOTSPOT = GC_X.

      WHEN 'ZEILE'.   "품목
        _FCAT TEXT-F16.

      WHEN 'BUDAT'.   "
        _FCAT TEXT-F17.

      WHEN 'BWART'.   "
        _FCAT TEXT-F18.

      WHEN 'BTEXT'.   "
        _FCAT TEXT-F19.

      WHEN 'WERKS'.       "플랜트
        _FCAT TEXT-F02.

      WHEN 'LGORT'.     "저장위치
        _FCAT TEXT-F04.

      WHEN 'MATNR'.        "자재코드
        _FCAT TEXT-F06.

      WHEN 'MAKTX'.        "자재명
        _FCAT TEXT-F07.

      WHEN 'ERFMG'.       "수량
        _FCAT TEXT-F20.
        <FS_S_FCT>-QFIELDNAME = 'ERFME'.

      WHEN 'ERFME'.        "단위
        _FCAT TEXT-F11.

      WHEN 'BKTXT'.     "폐기사유
        _FCAT TEXT-F21.

      WHEN 'KOSTL'.   "코스트센터
        _FCAT TEXT-F23.

      WHEN 'KTEXT'.   "코스트센터명
        _FCAT TEXT-F24.

      WHEN 'SAKTO'.   "G/L 계정
        _FCAT TEXT-F25.

      WHEN 'TXT20'.   "G/L 계정 내역
        _FCAT TEXT-F26.

      WHEN 'AUFNR'.   "오더번호
        _FCAT TEXT-F27.

      WHEN 'AUFNR_N'.   "오더명
        _FCAT TEXT-F28.

      WHEN 'USNAM'.   "생성자
        _FCAT TEXT-F22.

      WHEN OTHERS.
        <FS_S_FCT>-NO_OUT  = GC_X.

    ENDCASE.

    APPEND <FS_S_FCT> TO GT_FCAT_DISP.
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
*& FORM SET_EVENT
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
FORM SET_EVENT  CHANGING PO_EVENT TYPE REF TO LCL_EVT_RECEIVER
                                               PCL_GRID  TYPE REF TO CL_GUI_ALV_GRID.

  PCL_GRID->REGISTER_EDIT_EVENT( CL_GUI_ALV_GRID=>MC_EVT_MODIFIED ).
  PCL_GRID->REGISTER_EDIT_EVENT( CL_GUI_ALV_GRID=>MC_EVT_ENTER ).

  IF P_SCRP = GC_X.
    PERFORM SET_CELL_STYLE.
  ENDIF.

  CREATE OBJECT PO_EVENT.

  SET HANDLER :
  PO_EVENT->HANDLE_DATA_CHANGED                 FOR PCL_GRID,
*  PO_EVENT->HANDLE_DATA_CHANGED_FINISHED  FOR PCL_GRID,
  PO_EVENT->HANDLE_HOTSPOT_CLICK                FOR PCL_GRID,
*  PO_EVENT->HANDLE_TOOLBAR                           FOR PCL_GRID,
*  PO_EVENT->HANDLE_USER_COMMAND               FOR PCL_GRID,
  PO_EVENT->HANDLE_ON_F4                               FOR PCL_GRID.


ENDFORM.

*&---------------------------------------------------------------------*
*& FORM DISPLAY_ALV
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
FORM DISPLAY_ALV TABLES PT_LIST PT_FCAT.

  DATA(LS_VARINT) = VALUE DISVARIANT( REPORT  = SY-CPROG
                                           HANDLE  = COND #( WHEN P_DISP = GC_X THEN '0001'
                                                                          WHEN P_SCRP = GC_X THEN '0002' ELSE '0003' ) ).
*  F4 대상 필드 등록
  DATA: LT_F4 TYPE LVC_T_F4.
  LT_F4 = VALUE #(
               ( FIELDNAME = 'KOSTL' REGISTER   = 'X' )
               ( FIELDNAME = 'SAKTO' REGISTER   = 'X' )
               ( FIELDNAME = 'AUFNR'  REGISTER   = 'X' ) ).

  CALL METHOD GCL_GRID->REGISTER_F4_FOR_FIELDS
    EXPORTING
      IT_F4 = LT_F4.

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

  CLEAR : S_BUDAT[]. "생성일
  APPEND VALUE #( SIGN = GC_I OPTION = GC_BT
                                      LOW = SY-DATUM - 30
                                      HIGH = SY-DATUM ) TO S_BUDAT.

  CLEAR:
    GT_T001W[],
    GT_T001L[],
    GT_T024E[],
    GT_T024[].

  SELECT
    WERKS,
    NAME1
    FROM T001W
    INTO TABLE @GT_T001W.

  SELECT
    WERKS,
    LGORT,
    LGOBE
    FROM T001L
    INTO TABLE @GT_T001L.

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

*  SELECT
*    C~KOSTL,
*    T~KTEXT
*    FROM CSKS AS C
*    LEFT OUTER JOIN CSKT AS T
*    ON C~KOSTL EQ T~KOSTL
*    WHERE C~DATBI >= @SY-DATLO
*         AND C~DATAB <= @SY-DATLO
*    INTO TABLE @GT_CSKS.
*    SORT GT_CSKS BY KOSTL.
*
*  SELECT
*    S~SAKNR AS SAKTO,
*    T~TXT20
*    FROM SKA1 AS S
*    LEFT OUTER JOIN SKAT AS T
*    ON S~KTOPL EQ T~KTOPL
*    AND S~SAKNR EQ T~SAKNR
*    WHERE ( S~KTOPL = @P_BUKRS OR
*                S~KTOPL = '1000' )
*         AND T~SPRAS = @SY-LANGU
*    INTO TABLE @GT_SKA1.
*    SORT GT_SKA1 BY SAKTO.
*
*  SELECT
*    AUFNR,
*    KTEXT AS AUFNR_N
*    FROM AUFK
*    INTO TABLE @GT_AUFK.
*    SORT GT_AUFK BY AUFNR.


ENDFORM.

*&---------------------------------------------------------------------*
*& FORM CHECK_AUTH
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
FORM CHECK_AUTH .

  AUTHORITY-CHECK OBJECT 'ZCBO_MM001'
               ID 'BUKRS' FIELD P_BUKRS.

  CHECK SY-SUBRC <> 0.

  SET CURSOR FIELD 'P_BUKRS'.
  MESSAGE E172 WITH P_BUKRS. "회사코드[&] 작업권한을 확인하세요.

  AUTHORITY-CHECK OBJECT 'ZCBO_MM001'
               ID 'WERKS' FIELD P_WERKS.

  CHECK SY-SUBRC <> 0.

  SET CURSOR FIELD 'P_WERKS'.
  MESSAGE E106 WITH P_WERKS. "플랜트[&] 작업권한을 확인하세요.

ENDFORM.

*&---------------------------------------------------------------------*
*& FORM INPUT_VALIDATION
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
FORM INPUT_VALIDATION.

  CLEAR : GT_LIST, GT_DISP, GV_ERR.

  IF P_DISP EQ GC_X AND S_BUDAT[] IS INITIAL.
    MESSAGE S000 WITH TEXT-E03 DISPLAY LIKE GC_E.
    GV_ERR = GC_X. STOP. "전기일자는 필수 입력입니다.
  ENDIF.

  IF P_BUKRS IS INITIAL.
     MESSAGE S000 WITH TEXT-E04 DISPLAY LIKE GC_E.
     GV_ERR = GC_X. STOP. " 회사코드는 필수 입력입니다.
  ELSE.
    SELECT SINGLE 1
      FROM T001
      WHERE BUKRS = @P_BUKRS
      INTO @DATA(LV_EXST).

    IF SY-SUBRC <> 0.
      MESSAGE S000 WITH TEXT-M02 DISPLAY LIKE GC_E.
      GV_ERR = GC_X. STOP. "유효하지 않은 회사코드 입니다.
    ENDIF.
  ENDIF.

  IF P_WERKS IS INITIAL.
     MESSAGE S000 WITH TEXT-E05 DISPLAY LIKE GC_E.
     GV_ERR = GC_X. STOP. " 플랜트는 필수 입력입니다.
  ELSE.
    READ TABLE GT_T001W TRANSPORTING NO FIELDS
    WITH TABLE KEY WERKS = P_WERKS.

    IF SY-SUBRC <> 0.
      MESSAGE S000 WITH TEXT-M01 DISPLAY LIKE GC_E.
      GV_ERR = GC_X. STOP. "유효하지 않은 플랜트 입니다.
    ENDIF.
  ENDIF.

  IF P_BWART IS INITIAL.
     MESSAGE S000 WITH TEXT-E06 DISPLAY LIKE GC_E.
     GV_ERR = GC_X. STOP. " 이동유형은 필수 입력입니다.
  ELSE.
    SELECT SINGLE 1
     FROM T156
     WHERE BWART EQ @P_BWART
      INTO @LV_EXST.

    IF SY-SUBRC <> 0.
      MESSAGE S000 WITH TEXT-M03 DISPLAY LIKE GC_E.
      GV_ERR = GC_X.  STOP. "유효하지 않은 이동유형 입니다.
    ENDIF.
  ENDIF.

  IF S_MATNR[] IS NOT INITIAL.
    LOOP AT S_MATNR INTO DATA(LS_MATNR).

      SELECT SINGLE 1
      FROM MARA
      WHERE MATNR EQ @LS_MATNR-LOW
      INTO @LV_EXST.

      IF SY-SUBRC <> 0.
        MESSAGE S000 WITH TEXT-M04 DISPLAY LIKE GC_E.
        GV_ERR = GC_X. STOP. "유효하지 않은 자재코드 입니다.
      ENDIF.
    ENDLOOP.
  ENDIF.


ENDFORM.

*&---------------------------------------------------------------------*
*& FORM SELECTION_SCREEN_OUTPUT
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
FORM SELECTION_SCREEN_OUTPUT .

  LOOP AT SCREEN.

    IF  SCREEN-GROUP1 = 'DIS'. "처리결과조회일 경우 활성
      SCREEN-ACTIVE = COND #( WHEN P_DISP = GC_X THEN 1 ELSE 0 ).
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

  CLEAR : GV_ERR, GT_LIST, GT_DISP.

**데이터 가져오기
  CASE GC_X.
    WHEN P_SCRP. "폐기처리
      SELECT DISTINCT
                 ZZ~MATNR, ZZ~WERKS, ZZ~LGORT,
                 ZZ~CHARG, ZZ~MEINS, ZZ~LABST,
                 PP~TAGNR,
                 W~NAME1,
                 L~LGOBE,
                 T~MAKTX

        FROM ZGTMM_CV_GET_STOCKLIST AS ZZ
*        INNER JOIN ZPPT0001 AS PP
        LEFT OUTER JOIN ZPPT0001 AS PP
         ON PP~WERKS EQ ZZ~WERKS
        AND PP~CHARG EQ ZZ~CHARG
        AND PP~MATNR EQ ZZ~MATNR

        LEFT OUTER JOIN T001W AS W
        ON W~WERKS EQ ZZ~WERKS
        LEFT OUTER JOIN T001L AS L
        ON L~WERKS EQ ZZ~WERKS
        AND L~LGORT EQ ZZ~LGORT
        LEFT OUTER JOIN MAKT AS T
        ON T~MATNR EQ ZZ~MATNR
        AND T~SPRAS EQ @SY-LANGU

      WHERE ZZ~WERKS EQ @P_WERKS
          AND ZZ~LGORT IN @S_LGORT
          AND ZZ~MATNR IN @S_MATNR
          AND ZZ~LABST IS NOT INITIAL
          AND ZZ~SOBKZ IS INITIAL
          INTO CORRESPONDING FIELDS OF TABLE @GT_LIST.

      IF GT_LIST[] IS INITIAL.
        GV_ERR = GC_X. "조회 조건에 일치하는 정보가 없습니다.
        MESSAGE S000 WITH TEXT-E01. EXIT.
      ENDIF.

      PERFORM SET_TEXT CHANGING GT_LIST.
      SORT GT_LIST BY MATNR WERKS LGORT CHARG.

    WHEN P_DISP. "처리결과조회
      SELECT DISTINCT
                   MD~SMBLN, MD~MBLNR, MD~ZEILE, MD~BUDAT,
                   MD~BWART, MD~WERKS,
                   MD~LGORT_SID AS LGORT, MD~MATNR,
                   MD~ERFMG, MD~ERFME, MD~BKTXT, MD~USNAM,
                   MD~KOSTL, MD~AUFNR, MD~SAKTO,
                   T~MAKTX,
                   TT~BTEXT,
                   CS~KTEXT,
                   SK~TXT20,
                   AU~KTEXT AS AUFNR_N,

                   CASE WHEN MD~SMBLN IS INITIAL THEN @ABAP_FALSE
                             ELSE '@5B@'  END AS STATUS  "ICON_LED_GREEN.

        FROM MATDOC AS MD
        LEFT OUTER JOIN MAKT AS T
        ON T~MATNR EQ MD~MATNR
        AND T~SPRAS EQ @SY-LANGU
        LEFT OUTER JOIN T156T AS TT
        ON TT~BWART EQ MD~BWART
        AND TT~SPRAS EQ @SY-LANGU
        LEFT OUTER JOIN CSKT AS CS
        ON CS~KOSTL EQ MD~KOSTL
        AND CS~SPRAS EQ @SY-LANGU
        LEFT OUTER JOIN SKAT AS SK
        ON SK~SAKNR EQ MD~SAKTO
        AND SK~SPRAS EQ @SY-LANGU
        LEFT OUTER JOIN AUFK AS AU
        ON AU~AUFNR EQ MD~AUFNR

        WHERE MD~WERKS EQ @P_WERKS
             AND MD~LGORT IN @S_LGORT
             AND MD~BUDAT IN @S_BUDAT
             AND MD~BWART EQ @P_BWART
             AND MD~CANCELLED IS INITIAL
        INTO CORRESPONDING FIELDS OF TABLE @GT_DISP.

      IF GT_DISP[] IS INITIAL.
        GV_ERR = GC_X. "조회 조건에 일치하는 정보가 없습니다.
        MESSAGE S000 WITH TEXT-E01. EXIT.
      ENDIF.

      SORT GT_DISP BY MBLNR ZEILE.

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

*  CALL METHOD CL_GUI_CFW=>SET_NEW_OK_CODE
*    EXPORTING
*      NEW_CODE = 'ENTER'.

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
FORM SET_CELL_STYLE .

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

    IF GV_BAPI = GC_X.
      _SET_STYLE : GC_D 'KOSTL' <LS_LIST>-STYLE,  "DISABLED
                            GC_D 'SAKTO' <LS_LIST>-STYLE,  "
                            GC_D 'AUFNR' <LS_LIST>-STYLE,
                            GC_D 'MENGE' <LS_LIST>-STYLE.
    ELSE.
      _SET_STYLE : GC_E 'KOSTL' <LS_LIST>-STYLE,  "ENABLED
                            GC_E 'SAKTO' <LS_LIST>-STYLE,  "
                            GC_E 'AUFNR' <LS_LIST>-STYLE,
                            GC_E 'MENGE' <LS_LIST>-STYLE.
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

  CASE GC_X.
    WHEN P_SCRP.
      CREATE DATA GR_DREF LIKE GS_LIST.

    WHEN P_DISP.
      CREATE DATA GR_DREF LIKE GS_DISP.

    WHEN OTHERS.
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
  CASE GC_X.
    WHEN P_SCRP.
    PERFORM ADJUST_FLDCATS TABLES LT_FCAT.

    WHEN P_DISP.
    PERFORM ADJUST_FLDCATS_DISP TABLES LT_FCAT.

    WHEN OTHERS.
  ENDCASE.


ENDFORM.

*&---------------------------------------------------------------------*
*& FORM TOOLBAR
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
FORM TOOLBAR  USING PR_OBJ TYPE REF TO CL_ALV_EVENT_TOOLBAR_SET
                                     PO_SENDER.

*  DATA : LS_TBAR TYPE STB_BUTTON.
*
*  DEFINE _SET_TBAR.
*    CLEAR : LS_TBAR.
*
*    LS_TBAR-BUTN_TYPE = &1.
*    LS_TBAR-FUNCTION   = &2.
*    LS_TBAR-ICON           = &3.
*    LS_TBAR-TEXT          = &4.
*    LS_TBAR-QUICKINFO = &4.
*
*    APPEND LS_TBAR TO PR_OBJ->MT_TOOLBAR.
*  END-OF-DEFINITION.
*
*
*  CASE PO_SENDER.
*
*    WHEN GCL_GRID.
*      IF P_DISP = GC_X.
*
*        _SET_TBAR 3 '    ' '              ' '    '.
*        _SET_TBAR 0 'REFRESH' '' 'REFRESH'(B01).
*        _SET_TBAR 0 'CHANGE' ''  '변경'(B02).
*
*      ELSEIF P_SCRP = GC_X.
*
*        _SET_TBAR 3 '    ' '              ' '    '.
*        _SET_TBAR 0 'REFRESH' '' 'REFRESH'(B01).
*        _SET_TBAR 0 'TEMP'  ''   'TEMPLATE'(B03).
*        _SET_TBAR 0 'UPLOAD' ''  'EXCEL UPLOAD'(B04).
*        _SET_TBAR 0 'ME11' ''  'ME11'(B05).
*        _SET_TBAR 0 'SAVE' ''  '저장'(B06).
*
*      ELSE.
*        CLEAR PR_OBJ.
*
*      ENDIF.
*
*    WHEN OTHERS.
*
*  ENDCASE.

ENDFORM.

*&---------------------------------------------------------------------*
*& FORM USER_COMMAND
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
FORM USER_COMMAND  USING PV_UCOMM LIKE SY-UCOMM.

*  CLEAR : GV_ANSWER, GV_UCOMM.
*  GV_UCOMM = PV_UCOMM.
*
*  CASE PV_UCOMM.
*    WHEN 'REFRESH'.
*      IF P_DISP = GC_X.
*        PERFORM POPUP_TO_CONFIRM_STEP USING GC_N
*                                                              TEXT-M04 "작업 중인 정보가 초기화 됩니다.
*                                                              TEXT-M05 "REFRESH 하시겠습니까?
*                                                              TEXT-T04. " 확인
*        CHECK GV_ANSWER = GC_J.
*        PERFORM GET_DATA.
*      ELSE.
*        PERFORM GET_DATA.
*      ENDIF.
*
*    WHEN 'CHANGE' .
*      PERFORM CHANGE_INFORECORD.
*      PERFORM REFRESH_TABLE USING GCL_GRID SPACE.
*
*    WHEN 'TEMP' .
**UPLOAD TEMPLATE: EXEL 업로드 양식 다운로드
*      PERFORM TEMPLATE_DOWNLOAD USING GC_ZGTMMR1050 .
*
*    WHEN 'UPLOAD'  .
*      PERFORM EXCEL_UPLOAD.
*      PERFORM REFRESH_TABLE USING GCL_GRID SPACE.
*
*    WHEN 'ME11'  .
*      PERFORM CALL_TRANSACTION USING 'ME11'.
*
*    WHEN 'SAVE'  .
*      PERFORM SAVE_DATA.
*
*    WHEN OTHERS.
*  ENDCASE.
*
**  PERFORM REFRESH_TABLE USING GCL_GRID SPACE.

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
      PERFORM REFRESH_TABLE USING GCL_GRID SPACE.
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

      WHEN 'MENGE'.
        LS_LIST-MENGE = LS_MOD_CELLS-VALUE.
        LS_LIST-STATUS = COND #( WHEN LS_MOD_CELLS-VALUE IS INITIAL THEN ICON_LED_RED
                                                   ELSE LS_LIST-STATUS ).
        IF LS_MOD_CELLS-VALUE IS INITIAL.
          LV_ERR = GC_X.
          MESSAGE I015 WITH TEXT-F20. "수량을 입력하세요.
        ENDIF.

      WHEN 'KOSTL'.
        LS_LIST-KOSTL  = LS_MOD_CELLS-VALUE.

        IF LS_MOD_CELLS-VALUE IS INITIAL.
           CLEAR LS_LIST-KTEXT.
        ELSE.
           READ TABLE GT_CSKS ASSIGNING FIELD-SYMBOL(<CS>)
           WITH KEY KOSTL = LS_LIST-KOSTL BINARY SEARCH.
           IF SY-SUBRC = 0.
             LS_LIST-KTEXT = <CS>-KTEXT.
           ELSE.
             SELECT SINGLE T~KTEXT
                FROM CSKS AS C
                LEFT OUTER JOIN CSKT AS T
                ON C~KOSTL EQ T~KOSTL
                WHERE C~KOSTL = @LS_LIST-KOSTL
                AND C~DATBI >= @SY-DATLO
                AND C~DATAB <= @SY-DATLO
                INTO @DATA(LV_KTEXT).

             IF SY-SUBRC = 0.
                LS_LIST-KTEXT = LV_KTEXT.
             ELSE.
               CLEAR : LS_LIST-KOSTL, LS_LIST-KTEXT.
             ENDIF.
           ENDIF.
        ENDIF.

      WHEN 'SAKTO'.
        LS_LIST-SAKTO  = LS_MOD_CELLS-VALUE.

        IF LS_MOD_CELLS-VALUE IS INITIAL.
           CLEAR LS_LIST-TXT20.
        ELSE.
           READ TABLE GT_SKA1 ASSIGNING FIELD-SYMBOL(<SK>)
           WITH KEY SAKTO = LS_LIST-SAKTO BINARY SEARCH.
           IF SY-SUBRC = 0.
             LS_LIST-TXT20 = <SK>-TXT20.
           ELSE.
             SELECT SINGLE S~TXT20
               FROM SKAT AS S
               INNER JOIN T001 AS T
               ON  T~KTOPL = S~KTOPL
               WHERE S~SAKNR = @LS_LIST-SAKTO
               AND T~BUKRS = @P_BUKRS
               AND S~SPRAS = @SY-LANGU
               INTO @DATA(LV_TXT20).

             IF SY-SUBRC = 0.
                LS_LIST-TXT20 = LV_TXT20.
             ELSE.
               CLEAR : LS_LIST-SAKTO, LS_LIST-TXT20.
             ENDIF.
           ENDIF.
        ENDIF.

      WHEN 'AUFNR'.
        LS_LIST-AUFNR  = LS_MOD_CELLS-VALUE.

        IF LS_MOD_CELLS-VALUE IS INITIAL.
           CLEAR LS_LIST-AUFNR_N.
        ELSE.
           READ TABLE GT_AUFK ASSIGNING FIELD-SYMBOL(<AU>)
           WITH KEY AUFNR = LS_LIST-AUFNR BINARY SEARCH.
           IF SY-SUBRC = 0.
             LS_LIST-AUFNR_N = <AU>-AUFNR_N.
           ELSE.
             SELECT SINGLE KTEXT AS AUFNR_N
               FROM AUFK
               WHERE AUFNR = @LS_LIST-AUFNR
               INTO @DATA(LV_AUFNR_N).

             IF SY-SUBRC = 0.
                LS_LIST-AUFNR_N = LV_AUFNR_N.
             ELSE.
               CLEAR : LS_LIST-AUFNR, LS_LIST-AUFNR_N.
             ENDIF.
           ENDIF.
        ENDIF.

      WHEN OTHERS.
    ENDCASE.

    MODIFY GT_LIST FROM LS_LIST INDEX LS_MOD_CELLS-ROW_ID.
  ENDLOOP.

*  IF LV_ERR IS NOT INITIAL.
*    CALL METHOD PO_DATA_CHANGED->DISPLAY_PROTOCOL.
*  ENDIF.

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

  DATA LV_MBLNR TYPE MBLNR.

  CASE PO_SENDER.

    WHEN GCL_GRID.
      IF P_SCRP = GC_X.
        READ TABLE GT_LIST INTO DATA(LS_LIST) INDEX PS_ROW_NO-INDEX.
        IF SY-SUBRC = 0.
           LV_MBLNR = LS_LIST-MBLNR .
        ENDIF.

      ELSEIF P_DISP = GC_X.
        READ TABLE GT_DISP INTO DATA(LS_DISP) INDEX PS_ROW_NO-INDEX.
        IF SY-SUBRC = 0.
           LV_MBLNR = COND #( WHEN PS_COLUMN-FIELDNAME = 'MBLNR'
                                             THEN LS_DISP-MBLNR ELSE LS_DISP-SMBLN ).
        ENDIF.
      ENDIF.

      IF PS_COLUMN-FIELDNAME = 'MBLNR' OR PS_COLUMN-FIELDNAME = 'SMBLN'.
          CHECK LV_MBLNR IS NOT INITIAL.

          CALL FUNCTION 'MIGO_DIALOG'
             EXPORTING
                I_MBLNR            = LV_MBLNR
                I_MJAHR             = SY-DATUM(4)
             EXCEPTIONS
                ILLEGAL_COMBINATION = 1
                OTHERS              = 2.

      ELSE.
        EXIT.
      ENDIF.

      WHEN OTHERS.
  ENDCASE.

*        PERFORM REFRESH_TABLE USING GCL_GRID SPACE.
*        CALL METHOD CL_GUI_CFW=>SET_NEW_OK_CODE
*          EXPORTING
*            NEW_CODE = 'ENTER'.

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
         LS_RETURN TYPE DDSHRETVAL,
         LS_MODI   TYPE LVC_S_MODI.
  DATA : LV_MWSKZ TYPE MWSKZ.

  FIELD-SYMBOLS : <F4TAB> TYPE LVC_T_MODI.
  ASSIGN ER_EVENT_DATA->M_DATA->* TO <F4TAB>.

  CLEAR : LS_RETURN, LT_RETURN.

** TO AVOID STANDARD F4-HELP.
*  ER_EVENT_DATA->M_EVENT_HANDLED = 'X'.
*
*  IF E_FIELDNAME = 'SAKTO'.
**"데이터 추출*계정과목표&G/L계정 데이터
*    CLEAR GT_SKA1.
*    SELECT S~SAKNR AS SAKTO, S~TXT20
*      FROM SKAT AS S
*      INNER JOIN T001 AS T
*      ON  T~KTOPL = S~KTOPL
*      WHERE T~BUKRS = @P_BUKRS
*      AND      S~SPRAS = @SY-LANGU
*      INTO CORRESPONDING FIELDS OF TABLE @GT_SKA1.
*      SORT GT_SKA1 BY SAKTO.
*
**F4 HELP 호출
*    CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
*      EXPORTING
*        RETFIELD        = 'SAKTO'         " 내부 테이블에서 가져올 필드명
*        WINDOW_TITLE    = 'G/L Account'
*        VALUE_ORG       = 'S'
*      TABLES
*        VALUE_TAB       = GT_SKA1       " 데이터가 담긴 ITAB
*        RETURN_TAB     = LT_RETURN   " 사용자가 선택한 행의 정보가 담김
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
*      READ TABLE LT_RETURN INTO LS_RETURN INDEX 1.
*
*      CLEAR : LS_MODI.
*      LS_MODI-ROW_ID      = ES_ROW_NO-ROW_ID.
*      LS_MODI-FIELDNAME =  'SAKTO' .
*      LS_MODI-VALUE        = LS_RETURN-FIELDVAL.
*      APPEND LS_MODI TO <F4TAB>.
*    ENDIF.
*
*  ELSEIF E_FIELDNAME = 'KOSTL'.
**"데이터 추출_코스트센터
*    CLEAR GT_CSKS.
*    SELECT
*      C~KOSTL,
*      T~KTEXT
*    FROM CSKS AS C
*    LEFT OUTER JOIN CSKT AS T
*    ON C~KOSTL EQ T~KOSTL
*    WHERE C~DATBI >= @SY-DATLO
*         AND C~DATAB <= @SY-DATLO
*    INTO TABLE @GT_CSKS.
*    SORT GT_CSKS BY KOSTL.
*
**F4 HELP 호출
*    CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
*      EXPORTING
*        RETFIELD           = 'KOSTL'         " 내부 테이블에서 가져올 필드명
*        WINDOW_TITLE   = '코스트센터'
*        VALUE_ORG       = 'S'
*      TABLES
*        VALUE_TAB       = GT_CSKS       " 데이터가 담긴 ITAB
*        RETURN_TAB     = LT_RETURN   " 사용자가 선택한 행의 정보가 담김
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
*      READ TABLE LT_RETURN INTO LS_RETURN INDEX 1.
*
*      CLEAR : LS_MODI.
*      LS_MODI-ROW_ID      = ES_ROW_NO-ROW_ID.
*      LS_MODI-FIELDNAME =  'KOSTL' .
*      LS_MODI-VALUE        = LS_RETURN-FIELDVAL.
*      APPEND LS_MODI TO <F4TAB>.
*    ENDIF.
*
*  ELSEIF E_FIELDNAME = 'AUFNR'.
**"데이터 추출_오더번호
*    CLEAR GT_AUFK.
*    SELECT
*      AUFNR,
*      KTEXT AS AUFNR_N
*    FROM AUFK
*    INTO TABLE @GT_AUFK.
*    SORT GT_AUFK BY AUFNR.
*
**F4 HELP 호출
*    CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
*      EXPORTING
*        RETFIELD           = 'AUFNR'         " 내부 테이블에서 가져올 필드명
*        WINDOW_TITLE   = '오더번호'
*        VALUE_ORG       = 'S'
*      TABLES
*        VALUE_TAB       = GT_AUFK       " 데이터가 담긴 ITAB
*        RETURN_TAB     = LT_RETURN   " 사용자가 선택한 행의 정보가 담김
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
*      READ TABLE LT_RETURN INTO LS_RETURN INDEX 1.
*
*      CLEAR : LS_MODI.
*      LS_MODI-ROW_ID      = ES_ROW_NO-ROW_ID.
*      LS_MODI-FIELDNAME =  'AUFNR' .
*      LS_MODI-VALUE        = LS_RETURN-FIELDVAL.
*      APPEND LS_MODI TO <F4TAB>.
*    ENDIF.
*
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
*& FORM GET_SELECTED_ROWS
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
*&      --> GR_GRID
*&      --> P_
*&      --> P_
*&      --> P_
*&---------------------------------------------------------------------*
FORM GET_SELECTED_ROWS USING PR_GRID TYPE REF TO CL_GUI_ALV_GRID
                                                         PV_GB.

  CLEAR : GT_ROWS, GS_ROW, GV_ERR.

  CALL METHOD PR_GRID->GET_SELECTED_ROWS
    IMPORTING
      ET_INDEX_ROWS = GT_ROWS.

  DESCRIBE TABLE GT_ROWS.

  IF SY-TFILL = 0.
    GV_ERR = GC_X.
    MESSAGE S050 DISPLAY LIKE GC_E."선택된 데이터가 없습니다.
  ENDIF.

  IF SY-TFILL > 1.
    CHECK PV_GB = GC_C. "폐기취소의 경우에만 에러체크.
    GV_ERR = GC_X. "자재문서 건 별 처리 가능합니다.
    MESSAGE S000 WITH TEXT-E08 DISPLAY LIKE GC_E.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form EXCUTE_SCRAP
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&---------------------------------------------------------------------*
FORM EXCUTE_SCRAP  USING  PV_GB.

  CLEAR : GV_ANSWER, GV_QUES.
  DATA LV_MSG TYPE BAPI_MSG.

  PERFORM GET_SELECTED_ROWS USING GCL_GRID PV_GB.
  CHECK GV_ERR IS INITIAL.
  CLEAR GV_QUES.

  LOOP AT GT_ROWS INTO GS_ROW.

    CASE PV_GB.
    "폐기처리
      WHEN SPACE.
        READ TABLE GT_LIST ASSIGNING FIELD-SYMBOL(<FS>) INDEX GS_ROW-INDEX.
        CHECK <FS> IS ASSIGNED.

          IF <FS>-MENGE IS INITIAL.
            GV_ERR = GC_X.
            MESSAGE S000 WITH '수량 정보는 필수입니다. 입력 수량을 확인하세요.'(E07)
            DISPLAY LIKE GC_E .  EXIT.
          ENDIF.

          CHECK GV_ERR IS INITIAL.
          CLEAR : GV_REASON, GV_BUDAT.
          GV_QUES = TEXT-M08. "재고 폐기 처리 하시겠습니까?

    "C_폐기취소
      WHEN GC_C.
        READ TABLE GT_DISP ASSIGNING FIELD-SYMBOL(<CANC>) INDEX GS_ROW-INDEX.
        CHECK <CANC> IS ASSIGNED.

        GV_BUDAT = <CANC>-BUDAT.
        GV_QUES = TEXT-M09. "재고 폐기 취소 하시겠습니까?

      WHEN OTHERS.
    ENDCASE.

  ENDLOOP.

  CHECK GV_ERR IS INITIAL..
  CALL SCREEN 0200 STARTING AT 5 15.

  IF GV_ERR = GC_X. "BAPI 실패 메시지
    LV_MSG = COND #( WHEN PV_GB = GC_C THEN TEXT-E10 ELSE TEXT-E09 ).
    MESSAGE S000 WITH LV_MSG DISPLAY LIKE GC_E. "재고 조정 취소/폐기 처리 실패 하였습니다.

  ELSE. "BAPI 성공 메시지
    LV_MSG = COND #( WHEN PV_GB = GC_C THEN TEXT-M07 ELSE TEXT-M06 ).
    MESSAGE S000 WITH LV_MSG. "재고 조정 취소/폐기 처리 완료하였습니다.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form SET_BAPI_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&---------------------------------------------------------------------*
FORM SET_BAPI_DATA .

  DATA :
    LS_HEAD TYPE BAPI2017_GM_HEAD_01,
    LS_ITEM  TYPE BAPI2017_GM_ITEM_CREATE,
    LT_ITEM  TYPE TABLE OF BAPI2017_GM_ITEM_CREATE,
    LV_CODE TYPE BAPI2017_GM_CODE-GM_CODE,
    LV_DOC   TYPE BAPI2017_GM_HEAD_RET-MAT_DOC,
    LV_YEAR   TYPE BAPI2017_GM_HEAD_RET-DOC_YEAR.


  CLEAR : GV_BAPI , GV_ERR.

*GMCODE
  LV_CODE = '03'.
  CLEAR GT_RETURN.

*BAPI HEADER
  CLEAR : LS_HEAD, LT_ITEM.
  LS_HEAD = VALUE #( PSTNG_DATE  = GV_BUDAT
                                   DOC_DATE     = GV_BUDAT
                                   HEADER_TXT  = GV_REASON ).

*BAPI ITEM
  LOOP AT GT_ROWS INTO DATA(LS_ROW).

    READ TABLE GT_LIST ASSIGNING FIELD-SYMBOL(<FS>) INDEX LS_ROW-INDEX.
    CHECK <FS> IS ASSIGNED.

    CLEAR LS_ITEM.
    LS_ITEM-MOVE_TYPE = P_BWART.
    LS_ITEM-MATERIAL = <FS>-MATNR.
    LS_ITEM-PLANT = <FS>-WERKS.
    LS_ITEM-STGE_LOC = <FS>-LGORT.
    LS_ITEM-ENTRY_QNT = <FS>-MENGE.
    LS_ITEM-ENTRY_UOM = <FS>-MEINS.
    LS_ITEM-COSTCENTER = <FS>-KOSTL.
    LS_ITEM-GL_ACCOUNT = <FS>-SAKTO.
    LS_ITEM-ORDERID = <FS>-AUFNR.
    LS_ITEM-BATCH    = <FS>-CHARG.

    LT_ITEM = VALUE #( BASE LT_ITEM ( LS_ITEM ) ).
  ENDLOOP.

*BAPI 실행
  CALL FUNCTION 'BAPI_GOODSMVT_CREATE'
    EXPORTING
      GOODSMVT_HEADER  = LS_HEAD
      GOODSMVT_CODE     = LV_CODE
    IMPORTING
      MATERIALDOCUMENT = LV_DOC
      MATDOCUMENTYEAR = LV_YEAR
    TABLES
      GOODSMVT_ITEM    = LT_ITEM
      RETURN           = GT_RETURN.

*BAPI 결과
  READ TABLE GT_RETURN ASSIGNING FIELD-SYMBOL(<LS_RT>) WITH KEY TYPE = GC_E.
  IF SY-SUBRC EQ 0.
*오류
    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

    LOOP AT GT_ROWS INTO LS_ROW.
        READ TABLE GT_LIST ASSIGNING FIELD-SYMBOL(<ERR>) INDEX LS_ROW-INDEX.
        CHECK <ERR> IS ASSIGNED.

        <ERR>-MBLNR = LV_DOC.
        <ERR>-STATUS = ICON_LED_RED.
        <ERR>-MESSAGE = <LS_RT>-MESSAGE."BAPI ERR MSG
    ENDLOOP.

    GV_ERR = GC_X.

  ELSE.
*성공
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
        EXPORTING
          WAIT = ABAP_TRUE.

    LOOP AT GT_ROWS INTO LS_ROW.
        READ TABLE GT_LIST ASSIGNING FIELD-SYMBOL(<MAIN>) INDEX LS_ROW-INDEX.
        CHECK <MAIN> IS ASSIGNED.

*        <MAIN>-MJAHR =  LV_YEAR.
        <MAIN>-MBLNR = LV_DOC.
        <MAIN>-STATUS = ICON_LED_GREEN.
        <MAIN>-MESSAGE = TEXT-M06."재고 폐기 처리 완료하였습니다.
    ENDLOOP.

    CLEAR GV_ERR.
    GV_BAPI = GC_X.
  ENDIF.


ENDFORM.

*&---------------------------------------------------------------------*
*& Form SET_CANC_BAPI_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&---------------------------------------------------------------------*
FORM SET_CANC_BAPI_DATA.

  DATA :
    LS_HEAD   TYPE BAPI2017_GM_HEAD_RET,
    LV_MJAHR TYPE BAPI2017_GM_HEAD_RET-DOC_YEAR,
    LV_MSG    TYPE BAPI_MSG.

  CLEAR : GV_ERR, GT_RETURN, GV_BAPI.

  LOOP AT GT_ROWS INTO DATA(LS_ROW).

    READ TABLE GT_DISP ASSIGNING FIELD-SYMBOL(<FS>) INDEX LS_ROW-INDEX.
    CHECK <FS> IS ASSIGNED.

    LV_MJAHR = GV_BUDAT(4).

*CALL BAPI
    TRY.
      CALL FUNCTION 'BAPI_GOODSMVT_CANCEL'
          EXPORTING
            MATERIALDOCUMENT       = <FS>-MBLNR
            MATDOCUMENTYEAR        = LV_MJAHR
            GOODSMVT_PSTNG_DATE = GV_BUDAT
          IMPORTING
            GOODSMVT_HEADRET    = LS_HEAD
          TABLES
            RETURN              = GT_RETURN.

      CATCH CX_ROOT INTO DATA(LV_ERR).
        LV_MSG = LV_ERR->GET_TEXT( ).
        MESSAGE E000 WITH LV_MSG.
    ENDTRY.

*BAPI 결과
    READ TABLE GT_RETURN ASSIGNING FIELD-SYMBOL(<LS_RT>) WITH KEY TYPE = GC_E.
    IF SY-SUBRC EQ 0.
*오류
      CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
      GV_ERR = GC_X.
      MESSAGE S000 WITH TEXT-E10 DISPLAY LIKE GC_E. "재고 조정 취소 실패 하였습니다.

    ELSE.
*성공
      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
        EXPORTING
          WAIT = ABAP_TRUE.

      LOOP AT GT_ROWS INTO LS_ROW.

        READ TABLE GT_DISP ASSIGNING FIELD-SYMBOL(<MAIN>) INDEX LS_ROW-INDEX.
        CHECK <MAIN> IS ASSIGNED.

        <MAIN>-SMBLN = LS_HEAD-MAT_DOC.
        <MAIN>-STATUS = ICON_LED_GREEN.
      ENDLOOP.

      GV_BAPI = GC_X.
      MESSAGE S000 WITH TEXT-M07. "재고 폐기 취소 완료하였습니다.
    ENDIF.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SELECT_BWART
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_WERKS
*&---------------------------------------------------------------------*
FORM SELECT_BWART USING PV_WERKS ."TYPE MATDOC-WERKS.

  IF PV_WERKS IS  INITIAL..
    CLEAR GT_BWART.

  ELSE.
    SELECT * FROM ZGTPPT1010
    WHERE MODULE_KIND = @GC_MM
         AND CODEGRP = @GC_0850
         AND FLD_01 = @PV_WERKS
    INTO CORRESPONDING FIELDS OF TABLE @GT_ZGTPPT1010.
##OPERATOR[KEY]
    GT_BWART = VALUE #( FOR WA IN GT_ZGTPPT1010
                                     ( KEY  = CONV #( WA-FLD_02 )
                                       TEXT = CONV #( WA-FLD_03 ) ) ) .

    SORT GT_BWART BY KEY.
    DELETE ADJACENT DUPLICATES FROM GT_BWART COMPARING KEY.

    CALL FUNCTION 'VRM_SET_VALUES'
      EXPORTING
        ID     = 'P_BWART'
        VALUES = GT_BWART
      EXCEPTIONS
        OTHERS = 1.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_TEXT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- GT_LIST
*&---------------------------------------------------------------------*
FORM SET_TEXT  CHANGING PT_LIST TYPE TY_T_LIST.

 LOOP AT PT_LIST ASSIGNING FIELD-SYMBOL(<LIST>).
*이동유형
  READ TABLE GT_BWART ASSIGNING FIELD-SYMBOL(<BW>)
  WITH KEY KEY = P_BWART BINARY SEARCH.
  IF SY-SUBRC = 0.
    <LIST>-BWART = P_BWART.
    <LIST>-BTEXT = <BW>-TEXT.
  ENDIF.

*코스트센터
  READ TABLE GT_CSKS ASSIGNING FIELD-SYMBOL(<CS>)
  WITH KEY KOSTL = <LIST>-KOSTL BINARY SEARCH.
  IF SY-SUBRC = 0.
     <LIST>-KTEXT = <CS>-KTEXT.
  ENDIF.

*G/L계정
  READ TABLE GT_SKA1 ASSIGNING FIELD-SYMBOL(<SK>)
  WITH KEY SAKTO = <LIST>-SAKTO BINARY SEARCH.
  IF SY-SUBRC = 0.
     <LIST>-TXT20 = <SK>-TXT20.
  ENDIF.

*오더번호
  READ TABLE GT_AUFK ASSIGNING FIELD-SYMBOL(<AU>)
  WITH KEY AUFNR = <LIST>-AUFNR BINARY SEARCH.
  IF SY-SUBRC = 0.
     <LIST>-AUFNR_N = <AU>-AUFNR_N.
  ENDIF.
 ENDLOOP.

ENDFORM.
