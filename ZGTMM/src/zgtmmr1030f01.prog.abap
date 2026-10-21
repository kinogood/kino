*&---------------------------------------------------------------------*
*& INCLUDE          ZGTMMR1030F01
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
*            SET_TOP_OF_PAGE,
            SET_ALV_FIELDCAT USING ZGTFI_0,
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
        DYNNR   = SY-DYNNR
        SIDE       = CL_GUI_DOCKING_CONTAINER=>DOCK_AT_LEFT
        EXTENSION = 2500.

*    " CREATE SPLITTER
*    CREATE OBJECT GCL_SPLIT
*      EXPORTING
*        PARENT    = GCL_DOCKING
*        ROWS       = 2
*        COLUMNS = 1.
*
*    GCL_SPLIT->SET_ROW_HEIGHT( ID = 1 HEIGHT = 10 ). "위아래 넓이..
*    GCL_SPLIT->SET_BORDER( BORDER = ZGTFI_X ). "테두리...
*    GCL_SPLIT->GET_CONTAINER( : EXPORTING ROW      = 1
*                                         COLUMN    = 1
*                               RECEIVING CONTAINER = GCL_CON_TOP ),
*
*                               EXPORTING ROW       = 2
*                                         COLUMN    = 1
*                               RECEIVING CONTAINER = GCL_CON_BODY ).

  ENDIF.

*  IF GCL_CL_DD IS NOT BOUND.
*    CREATE OBJECT GCL_CL_DD
*      EXPORTING
*        STYLE = 'ALV_GRID'.
*  ENDIF.

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
        I_PARENT          = GCL_DOCKING "GCL_CON_BODY
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

      WHEN 'WERKS'.     " 플랜트
        _FCAT TEXT-F02.
        <FS_S_FCT>-KEY = ABAP_TRUE.

      WHEN 'NAME1'.  "플랜트명
        _FCAT TEXT-F03.
        <FS_S_FCT>-KEY = ABAP_TRUE.

      WHEN 'EKGRP'.      "구매그룹
        _FCAT TEXT-F08.
        <FS_S_FCT>-F4AVAILABL = ZGTFI_X.
        <FS_S_FCT>-REF_TABLE = 'MARC'.
        <FS_S_FCT>-REF_FIELD  = 'EKGRP'.

      WHEN 'EKNAM'.     "구매그룹명
        _FCAT TEXT-F09.

      WHEN 'BNAME'.     "SAP ID->담당자사번 변경
        _FCAT TEXT-F10.
        <FS_S_FCT>-EDIT            = ZGTFI_X.
        <FS_S_FCT>-F4AVAILABL = ZGTFI_X.
        <FS_S_FCT>-REF_TABLE = 'USR21'.
        <FS_S_FCT>-REF_FIELD  = 'BNAME'.

      WHEN 'ANAME'.     "승인자사번
        _FCAT TEXT-F04.
        <FS_S_FCT>-EDIT            = ZGTFI_X.
        <FS_S_FCT>-F4AVAILABL = ZGTFI_X.
        <FS_S_FCT>-REF_TABLE = 'USR21'.
        <FS_S_FCT>-REF_FIELD  = 'BNAME'.

      WHEN 'ERDAT'.                 "생성일
        _FCAT TEXT-F11.

      WHEN 'ERDAT_LOCAL'.     "생성일(LOCAL)
        _FCAT TEXT-F12.

      WHEN 'ERTIM'.                 "생성시간
        _FCAT TEXT-F13.

      WHEN 'ERTIM_LOCAL'.     "생성시간(LOCAL)
        _FCAT TEXT-F14.

      WHEN 'ERNAM'.               "생성자
        _FCAT TEXT-F15.

      WHEN OTHERS.
        <FS_S_FCT>-TECH = ZGTFI_X.

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
                       NO_ROWINS  = ZGTFI_X
                       ZEBRA  = ZGTFI_X
                       SEL_MODE   = ZGTFI_A
                       CWIDTH_OPT  = ZGTFI_A
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

  PERFORM SET_CELL_STYLE.

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
      IS_LAYOUT                      = GS_LAYOUT
      IT_TOOLBAR_EXCLUDING = GT_EXCLUD[]
      IS_VARIANT                      = LS_VARINT
      I_SAVE                             = ZGTFI_A
    CHANGING
      IT_OUTTAB                       = GT_LIST[]
      IT_FIELDCATALOG             = GT_FCAT[]
      IT_SORT                            = GT_SORT[]
    EXCEPTIONS
      OTHERS                            = 4.

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

  IF P_WERKS IS INITIAL.
    MESSAGE S008 WITH TEXT-T11 DISPLAY LIKE ZGTFI_E.
    GV_ERR = ZGTFI_X. STOP. "필수 값이 누락되었습니다. &
  ENDIF.

  SELECT SINGLE 1
    FROM T001W
    WHERE WERKS = @P_WERKS
    INTO @DATA(LV_EXST).

  IF SY-SUBRC <> 0.
    MESSAGE S000 WITH TEXT-M01 DISPLAY LIKE ZGTFI_E.
    GV_ERR = ZGTFI_X. STOP. "유효하지 않은 플랜트 입니다.
  ENDIF.

  IF  S_EKGRP-LOW IS NOT INITIAL.
    LOOP AT S_EKGRP INTO DATA(LS_EKGRP).

     SELECT SINGLE 1
      FROM T024
      WHERE EKGRP EQ @LS_EKGRP-LOW
       INTO @LV_EXST.

      IF SY-SUBRC <> 0.
        MESSAGE S000 WITH TEXT-M02 DISPLAY LIKE ZGTFI_E.
        GV_ERR = ZGTFI_X. STOP. "유효하지 않은 구매그룹 입니다.
      ENDIF.

     ENDLOOP.
  ENDIF.

  IF S_BNAME[] IS NOT INITIAL.
    LOOP AT S_BNAME INTO DATA(LS_LOW).

      SELECT SINGLE 1
      FROM USR21
      WHERE BNAME EQ @LS_LOW-LOW
      INTO @LV_EXST.

      IF SY-SUBRC <> 0.
        MESSAGE S000 WITH TEXT-M03 DISPLAY LIKE ZGTFI_E.
        GV_ERR = ZGTFI_X. STOP. "유효하지 않은 사용자 ID 입니다.
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

 SELECT FROM ZGTMMT1020 AS A
   JOIN T001W AS W  ON A~WERKS EQ W~WERKS
   JOIN T024    AS T   ON A~EKGRP EQ T~EKGRP
   FIELDS A~*, W~NAME1, T~EKNAM
   WHERE A~WERKS EQ @P_WERKS
        AND A~EKGRP IN  @S_EKGRP
        AND A~BNAME IN @S_BNAME
       INTO CORRESPONDING FIELDS OF TABLE @GT_LIST.

   IF GT_LIST[] IS INITIAL.
*     GV_ERR = ZGTFI_X. "없더라도 신규등록 할 수 있도록..에러체크제외.
     CLEAR GV_FIRST.
     MESSAGE S000 WITH TEXT-E01."조회 조건에 일치하는 정보가 없습니다.

   ELSE.
     GV_FIRST = GC_X. "담당자/승인자 변경 가능하도록..필드제어용
   ENDIF.

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
      DEFAULTOPTION   = PV_OPT
      TEXTLINE1            = PV_TEXT1
      TEXTLINE2            = PV_TEXT2
      TITEL                    = PV_TITLE
      CANCEL_DISPLAY  = ''
    IMPORTING
      ANSWER               = GV_ANSWER.

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

*  PERFORM SET_CELL_STYLE.

  CALL METHOD PO_GRID->REFRESH_TABLE_DISPLAY
    EXPORTING
      IS_STABLE           = LS_STABLE
*      I_SOFT_REFRESH = PV_SOFT_REFRESH
    EXCEPTIONS
      FINISHED       = 1
      OTHERS        = 2.

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


    IF GV_EDIT IS INITIAL.
       GCL_GRID->SET_READY_FOR_INPUT( 0 ).
    ELSE.
       GCL_GRID->SET_READY_FOR_INPUT( 1 ). "입력가능
    ENDIF.

    LOOP AT GT_LIST ASSIGNING FIELD-SYMBOL(<LS_LIST>).
      CLEAR : <LS_LIST>-STYLE[].

        IF GV_EDIT = ZGTFI_X. "변경
         _SET_STYLE : ZGTFI_E 'EKGRP' <LS_LIST>-STYLE,"ENABLED
                               ZGTFI_E 'BNAME' <LS_LIST>-STYLE,
                               ZGTFI_E 'ANAME' <LS_LIST>-STYLE.
        ELSE."조회
          IF GV_FIRST = GC_X.
             GCL_GRID->SET_READY_FOR_INPUT( 1 ). "입력가능
             _SET_STYLE : ZGTFI_D 'EKGRP' <LS_LIST>-STYLE, "DISABLED
                                   ZGTFI_E 'BNAME' <LS_LIST>-STYLE, "ENABLED
                                   ZGTFI_E 'ANAME' <LS_LIST>-STYLE.
          ELSE.
             _SET_STYLE : ZGTFI_D 'EKGRP' <LS_LIST>-STYLE, "DISABLED
                                   ZGTFI_D 'BNAME' <LS_LIST>-STYLE,
                                   ZGTFI_D 'ANAME' <LS_LIST>-STYLE.
          ENDIF.

        ENDIF.

    ENDLOOP.

ENDFORM.

*&---------------------------------------------------------------------*
*& FORM SET_ALV_FIELDCAT
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
FORM SET_ALV_FIELDCAT  USING PV_GUBUN TYPE CHAR1.

  DATA :
         LR_TABDESCR TYPE REF TO CL_ABAP_STRUCTDESCR,
         LT_DFIES         TYPE DDFIELDS,
         LS_DFIES         TYPE DFIES,
         LT_FCAT          TYPE LVC_T_FCAT,
         LS_FCAT          TYPE LVC_S_FCAT.

  DATA : GR_DREF  TYPE REF TO DATA.

  CLEAR GR_DREF.
  CASE PV_GUBUN.
    WHEN ZGTFI_0.
      CREATE DATA GR_DREF LIKE GS_LIST.

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

  " 필드 카탈로그 변경사항 적용
  CASE PV_GUBUN.
    WHEN ZGTFI_0.
      PERFORM ADJUST_FLDCATS TABLES LT_FCAT.

     WHEN OTHERS.
  ENDCASE.
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
      _SET_TBAR 0 'SAVE' ICON_SYSTEM_SAVE 'Save'(B01).
      _SET_TBAR 0 'INSR'  ICON_INSERT_ROW   '신규'(B02).
      _SET_TBAR 0 'DELE' ICON_DELETE_ROW  '삭제'(B03).

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
    WHEN 'SAVE'.
      PERFORM SAVE_DATA .
      CLEAR GV_OKCODE_SAVE2 .

    WHEN 'INSR'.
      PERFORM INSERT_DATA.
      GV_OKCODE_SAVE2  = PV_UCOMM.

    WHEN 'DELE'.
      PERFORM DELETE_DATA.
      CLEAR GV_OKCODE_SAVE2 .

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

      WHEN 'BNAME'  OR 'ANAME'.

          SELECT SINGLE BNAME
             FROM USR21
             WHERE BNAME = @LS_MOD_CELLS-VALUE
                 INTO @DATA(LV_EXST).

             IF LV_EXST IS  INITIAL.
                 PERFORM ADD_ENTRY USING PO_DATA_CHANGED LS_MOD_CELLS-FIELDNAME
                                                              LS_MOD_CELLS-ROW_ID.
             ELSE.
                 PERFORM MODIFY_CELL USING PO_DATA_CHANGED LS_MOD_CELLS-FIELDNAME
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
*& Form MODIFY_CELL
*&---------------------------------------------------------------------*
*& text
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
      I_ROW_ID      = PV_INDEX
      I_FIELDNAME = PV_FNAME
      I_VALUE        = PV_FVAL.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form ADD_ENTRY
*&---------------------------------------------------------------------*
*& text
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
                I_MSGNO   = '013'
                I_MSGV1    = PV_FNAME
                I_MSGTY    = ZGTFI_E
                I_FIELDNAME = PV_FNAME
                I_ROW_ID       = PV_INDEX.

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

      IF PS_COLUMN-FIELDNAME = 'BELNR'.
*        CHECK LS_LIST-BELNR IS NOT INITIAL.

*        SET PARAMETER ID 'BUK' FIELD P_BUKRS.
*        SET PARAMETER ID 'BLN' FIELD LS_LIST-BELNR.
*        SET PARAMETER ID 'GJR' FIELD LS_LIST-GJAHR.
*
*        CALL TRANSACTION 'FB03' AND SKIP FIRST SCREEN.

      ELSE.
        EXIT.
      ENDIF.

      IF PS_COLUMN-FIELDNAME = 'BELNR'.
*        CHECK <LS_LIST_1>-BELNR IS NOT INITIAL.

*        SET PARAMETER ID 'BUK' FIELD P_BUKRS.
*        SET PARAMETER ID 'BLN' FIELD <LS_LIST_1>-BELNR.
*        SET PARAMETER ID 'GJR' FIELD <LS_LIST_1>-GJAHR.

*        CALL TRANSACTION 'FB03' AND SKIP FIRST SCREEN.

      ELSEIF PS_COLUMN-FIELDNAME = 'CHECK'.
*        IF <LS_LIST_1>-CHECK IS INITIAL.
*          <LS_LIST_1>-CHECK = ABAP_TRUE.
*        ELSE.
*          CLEAR <LS_LIST_1>-CHECK.
*        ENDIF.

        PERFORM REFRESH_TABLE USING GCL_GRID SPACE.
        CALL METHOD CL_GUI_CFW=>SET_NEW_OK_CODE
          EXPORTING
            NEW_CODE = 'ENTER'.

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
*& Form SET_CHANGE_SAVE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
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
*& Form SAVE_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SAVE_DATA .

  DATA : LS_1020 TYPE ZGTMMT1020,
             LT_1020 TYPE TABLE OF ZGTMMT1020.
  CLEAR GV_ERR.

  PERFORM GET_SELECTED_ROWS USING GCL_GRID.
  CHECK GV_ERR IS INITIAL.

*입력 필드 둘 중 하나만 있으면 필수값이 충족되지 않으므로 에러 메시지 처리(저장불가)
  LOOP AT GT_ROWS INTO GS_ROW.

     READ TABLE GT_LIST INTO DATA(LS_LIST) INDEX GS_ROW-INDEX.
     IF SY-SUBRC = 0.
*입력필드 두 개 모두 없는 라인은 빈 값이므로, 저장 대상 제외.
       IF LS_LIST-EKGRP IS INITIAL AND LS_LIST-BNAME IS INITIAL.
         CONTINUE.
       ENDIF.
*입력 필드  중 하나만 있으면 필수값이 충족되지 않으므로 에러 메시지 처리(저장불가)
       IF  LS_LIST-EKGRP = '' OR  LS_LIST-BNAME = '' OR LS_LIST-ANAME = '' .
         GV_ERR = GC_X.
         MESSAGE S000 WITH TEXT-E02 DISPLAY LIKE GC_E."입력되지 않은 정보가 있습니다.
         EXIT.

       ELSE.
         LS_1020 = VALUE #( BASE CORRESPONDING #( LS_LIST )
                                      ERDAT = SY-DATUM
                                      ERDAT_LOCAL = SY-DATLO
                                      ERTIM = SY-UZEIT
                                      ERTIM_LOCAL = SY-TIMLO
                                      ERNAM = SY-UNAME ).
         APPEND LS_1020 TO LT_1020.
       ENDIF.
     ENDIF.
  ENDLOOP.

  IF LT_1020 IS NOT INITIAL.

    MODIFY ZGTMMT1020 FROM TABLE LT_1020.

    IF SY-SUBRC = 0.
       COMMIT WORK AND WAIT.
       PERFORM GET_DATA.
       CLEAR GV_EDIT.
    ENDIF.

    PERFORM REFRESH_TABLE USING GCL_GRID SPACE.
    MESSAGE S080."저장성공

  ENDIF.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form DELETE_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM DELETE_DATA .

  DATA : LT_1020 LIKE TABLE OF ZGTMMT1020,
             LS_1020 LIKE ZGTMMT1020.

  PERFORM GET_SELECTED_ROWS USING GCL_GRID.
  CHECK GV_ERR IS INITIAL.

  PERFORM POPUP_TO_CONFIRM_STEP USING ZGTFI_N
                                                            TEXT-M04  "선택된 데이터가 삭제됩니다.
                                                            TEXT-M05  "삭제 하시겠습니까?
                                                            TEXT-T04. " 확인

  CHECK GV_ANSWER = ZGTFI_J. "YES
  SORT GT_ROWS BY INDEX DESCENDING.

  LOOP AT GT_ROWS INTO GS_ROW.

    READ TABLE GT_LIST INTO DATA(LS_LIST) INDEX GS_ROW-INDEX.

    IF SY-SUBRC = 0.

      IF GV_EDIT IS INITIAL.
        "등록된 기존 담당자 데이터 삭제
        LS_1020 = CORRESPONDING #( LS_LIST ).
        APPEND LS_1020 TO LT_1020.

      ELSE.
        "신규 작성 중인 데이터 라인 삭제
         DELETE GT_LIST INDEX GS_ROW-INDEX.
      ENDIF.

    ENDIF.

  ENDLOOP.

  IF LT_1020[] IS NOT INITIAL.

      TRY.
          DELETE ZGTMMT1020 FROM TABLE LT_1020.

          IF SY-SUBRC = 0.
             COMMIT WORK AND WAIT.
             PERFORM GET_DATA.  "삭제 후 재조회->REFRESH
             CLEAR GV_EDIT.          "입력가능필드 비활성
          ENDIF.

       CATCH CX_ROOT INTO DATA(LV_ERROR).
           MESSAGE LV_ERROR->GET_TEXT( ) TYPE GC_E .
      ENDTRY.

  ENDIF.

  IF SY-SUBRC = 0.
    PERFORM REFRESH_TABLE USING GCL_GRID SPACE.
    MESSAGE S000 WITH TEXT-M09. "선택된 데이터가 삭제되었습니다.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_SELECTED_ROWS
*&---------------------------------------------------------------------*
*& text
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
*& Form INSERT_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM INSERT_DATA .

* IF GV_NEW IS INITIAL.
*    CLEAR GT_LIST.
*    GV_NEW = GC_X. "신규 구분자(저장 로직 기능 구분용)
* ENDIF.

 SELECT SINGLE NAME1
   FROM T001W
   WHERE WERKS = @P_WERKS
   INTO @DATA(LV_NAME).

  DESCRIBE TABLE GT_LIST.

  GT_LIST = VALUE #( FOR I = SY-TFILL UNTIL I > 20
                               ( WERKS = P_WERKS
                                  NAME1 = LV_NAME ) ).

  GV_EDIT = GC_X. "입력팔드 활/비활성 제어용
  PERFORM SET_CELL_STYLE.
  PERFORM REFRESH_TABLE USING GCL_GRID SPACE.

ENDFORM.
