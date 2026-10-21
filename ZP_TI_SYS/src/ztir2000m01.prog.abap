*&---------------------------------------------------------------------*
*&  Include           ZTIR2000M01
*&---------------------------------------------------------------------*
TABLES : SSCRFIELDS.

*&---------------------------------------------------------------------*
*&      CLASS DEFINITIAL
*&---------------------------------------------------------------------*
CLASS LCL_EVENT_RECEIVER DEFINITION.
  PUBLIC SECTION.
    METHODS:
      HANDLE_DATA_CHANGED
                    FOR EVENT DATA_CHANGED OF CL_GUI_ALV_GRID
        IMPORTING SENDER ER_DATA_CHANGED,
      HANDLE_HOTSPOT_CLICK
                    FOR EVENT HOTSPOT_CLICK OF CL_GUI_ALV_GRID
        IMPORTING SENDER E_ROW_ID E_COLUMN_ID,
      HANDLE_DOUBLE_CLICK
                    FOR EVENT DOUBLE_CLICK OF CL_GUI_ALV_GRID
        IMPORTING SENDER E_ROW E_COLUMN,
      HANDLE_ONF4
                    FOR EVENT ONF4 OF CL_GUI_ALV_GRID
        IMPORTING SENDER E_FIELDNAME E_FIELDVALUE
                    ES_ROW_NO ER_EVENT_DATA
                    ET_BAD_CELLS E_DISPLAY,
      HANDLE_TOOLBAR
                    FOR EVENT TOOLBAR OF CL_GUI_ALV_GRID
        IMPORTING SENDER E_OBJECT E_INTERACTIVE,
      HANDLE_USER_COMMAND
                    FOR EVENT USER_COMMAND OF CL_GUI_ALV_GRID
        IMPORTING SENDER E_UCOMM.

ENDCLASS.                    "LCL_EVENT_RECEIVER DEFINITION
*----------------------------------------------------------------------*
*       CLASS LCL_EVENT_RECEIVER IMPLEMENTATION
*----------------------------------------------------------------------*
CLASS LCL_EVENT_RECEIVER IMPLEMENTATION.
  METHOD HANDLE_DATA_CHANGED.
*    PERFORM HANDLE_DATA_CHANGED USING SENDER
*                                      ER_DATA_CHANGED.
  ENDMETHOD.                    "HANDLE_DATA_CHANGED

  METHOD HANDLE_HOTSPOT_CLICK.

  ENDMETHOD.                    "HANDLE_HOTSPOT_CLICK

  METHOD HANDLE_DOUBLE_CLICK.
*    PERFORM HANDLE_DOUBLE_CLICK USING SENDER
*                                      E_ROW-INDEX
*                                      E_COLUMN-FIELDNAME.
  ENDMETHOD.                    "HANDLE_DOUBLE_CLICK
  METHOD HANDLE_ONF4.
*    PERFORM GET_ON_F4 USING SENDER
*                            E_FIELDNAME
*                            E_FIELDVALUE
*                            ES_ROW_NO
*                            ER_EVENT_DATA
*                            ET_BAD_CELLS
*                            E_DISPLAY.
*    ER_EVENT_DATA->M_EVENT_HANDLED = 'X'.
  ENDMETHOD.                    "HANDLE_ONF4
  METHOD HANDLE_TOOLBAR.
*    PERFORM TOOLBAR_PART USING SENDER
*                               E_OBJECT
*                               E_INTERACTIVE.
  ENDMETHOD.                    "HANDLE_TOOLBAR
  METHOD HANDLE_USER_COMMAND.
*    PERFORM USER_COMMAND_PART USING SENDER
*                                    E_UCOMM.
  ENDMETHOD.                    "HANDLE_USER_COMMAND
ENDCLASS.                    "LCL_EVENT_RECEIVER IMPLEMENTATION



*--[엠트론] 업로드 매핑 관련
DATA : BEGIN OF GT_LIST99  OCCURS 0,

        BLNUM LIKE ZTITBLH-BLNUM , "B/L 번호
        BLDAT LIKE ZTITBLH-BLDAT , "B/L발행일
        LIFNR LIKE ZTITBLH-LIFNR , "공급업체 계정 번호
        NAME1 LIKE LFA1-NAME1 , "업체명
        FWDCD LIKE ZTITBLH-FWDCD , "포워더
        FWDTY LIKE ZTITBLH-FWDTY , "운송 방법
        FWDFM LIKE ZTITBLH-FWDFM , "운송형태
        CTNQ2 LIKE ZTITBLH-CTNQ2 , "20FT 컨테이너 수
        CTNQ4 LIKE ZTITBLH-CTNQ4 , "40FT 컨테이너 수

        CTNTY LIKE ZTITBLH-CTNTY , "컨테이너 종류
        BIPKG LIKE ZTITBLH-BIPKG , "포장개수
*        BPKTY LIKE ZTITBLH-BPKTY , "포장종류

        BRGEW LIKE ZTITBLH-BRGEW , "총중량


        VOLUM LIKE ZTITBLH-VOLUM , "볼륨

        IVSLN LIKE ZTITBLH-IVSLN , "선기명(주운송수단)
        BLETD LIKE ZTITBLH-BLETD , "ETD(출발 예정 시각)
        BLETA LIKE ZTITBLH-BLETA , "ETA(도착 예정 시각)

        FLAND LIKE ZTITBLH-FLAND , "선적국
        FPORT LIKE ZTITBLH-FPORT , "선적항

        INFO(4) TYPE C,            "ALV ROW COLOR
        COLINFO TYPE LVC_T_SCOL,   "ALV COLUMN COLOR
        STYLE   TYPE LVC_T_STYL,   "ALV CONTROL
        END OF GT_LIST99,

        GF_RQIV_CHK.



*----------------------------------------------------------------------*
*  ALV
*----------------------------------------------------------------------*
*메인
DATA : GS_CUSTOM_CONTAINER99 TYPE REF TO CL_GUI_CUSTOM_CONTAINER,
       GS_SPLITTER99         TYPE REF TO CL_GUI_SPLITTER_CONTAINER,
       GS_CONTAINER_TOP99    TYPE REF TO CL_GUI_CONTAINER,
         "alv grid
       GS_ALV_GRID99         TYPE REF TO CL_GUI_ALV_GRID,
        " Layout (External Use)
       GS_VARIANT99          TYPE DISVARIANT,

       GS_LAYOUT99          TYPE LVC_S_LAYO,

       GT_FIELDCAT99       TYPE LVC_T_FCAT WITH HEADER LINE,
       GT_FIELD99          TYPE SLIS_T_FIELDCAT_ALV,
        "Field sort
       GT_SORT99           TYPE TABLE OF LVC_S_SORT,
       "ALV Toolbar dim
       GT_EXCLUDE99          TYPE UI_FUNCTIONS,
       "ALV color
       GT_COLOR99          TYPE LVC_T_SCOL WITH HEADER LINE,
       "ALV Event
       GS_EVENT_RECEIVER99   TYPE REF TO LCL_EVENT_RECEIVER,
        "최신표시 안정성
       GS_STBL99           TYPE LVC_S_STBL.

DATA : GV_EMRO_LINK LIKE ZTITBLH-URL.

CONSTANTS : C_X VALUE 'X',
            C_D VALUE 'D',
            C_S VALUE 'S',

            C_3000 LIKE ZTITBLK-BUKRS VALUE '3000'.


*&---------------------------------------------------------------------*
*&      Form  CHECK_INVOICE_SCREEN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CHECK_INVOICE_SCREEN .


  DATA : LV_ANSWER,
         LV_LINE(100).

  CLEAR : LV_ANSWER .


  SELECT SINGLE *  FROM ZTITIVP WHERE IBLNO EQ ZTITBLK-IBLNO.
  CHECK SY-SUBRC NE 0.

  CONCATENATE '생성된 BL(' ZTITBLK-IBLNO ')을 송장등록 하시겠습니까?'
         INTO LV_LINE.

  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      TITLEBAR              = '송장등록'
      TEXT_QUESTION         = LV_LINE
      TEXT_BUTTON_1         = '확인'
      ICON_BUTTON_1         = 'ICON_OKAY'
      TEXT_BUTTON_2         = '취소'
      ICON_BUTTON_2         = 'ICON_CANCEL'
      DEFAULT_BUTTON        = '2'             "Default Button: 취소
      DISPLAY_CANCEL_BUTTON = ' '
      POPUP_TYPE            = 'ICON_MESSAGE_QUESTION'
    IMPORTING
      ANSWER                = LV_ANSWER
    EXCEPTIONS
      TEXT_NOT_FOUND        = 1
      OTHERS                = 2.

  IF LV_ANSWER = '1'.
    SET PARAMETER ID 'ZTIIBLNO' FIELD ZTITBLK-IBLNO.
    SET PARAMETER ID 'ZTIREQNO' FIELD SPACE.
    SET PARAMETER ID 'BES'      FIELD SPACE.
    CALL TRANSACTION 'ZTIT301' AND SKIP FIRST SCREEN .

  ENDIF.


ENDFORM.                    " CHECK_INVOICE_SCREEN
*&---------------------------------------------------------------------*
*&      Form  SET_UPLAOD_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SET_MAPPING_DATA .


  DATA : LT_LFA1 LIKE TABLE OF LFA1 WITH HEADER LINE.

  LOOP AT IT_LIST WHERE BOX EQ 'X'.
    SELECT * INTO CORRESPONDING FIELDS OF TABLE GT_LIST99
     FROM ZTITBLH
     WHERE
       LIFNR EQ IT_LIST-LIFNR AND
       IBLNO EQ SPACE.
  ENDLOOP.

  IF GT_LIST99[] IS NOT INITIAL.

    SELECT * INTO CORRESPONDING FIELDS OF TABLE LT_LFA1
      FROM LFA1 FOR ALL ENTRIES IN GT_LIST99
     WHERE LIFNR EQ GT_LIST99-LIFNR.

    SORT LT_LFA1 BY LIFNR .

    LOOP AT GT_LIST99 .
      READ TABLE LT_LFA1 WITH KEY LIFNR = GT_LIST99-LIFNR
                                         BINARY SEARCH.
      IF SY-SUBRC EQ 0.
        GT_LIST99-NAME1 = LT_LFA1-NAME1.
        MODIFY GT_LIST99 TRANSPORTING NAME1.
      ENDIF.

    ENDLOOP.
    CALL SCREEN 7050 STARTING AT 10 5.
  ELSE.

    MESSAGE S999 WITH '매핑대상이 없습니다'.

  ENDIF.


ENDFORM.                    " SET_UPLAOD_DATA
*&---------------------------------------------------------------------*
*&      Form  SET_UPLAOD_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SET_MAPPING_DATA_2010.


  DATA : LT_LFA1 LIKE TABLE OF LFA1 WITH HEADER LINE.

  LOOP AT IT_HEADER WHERE BOX EQ 'X'.
    SELECT * INTO CORRESPONDING FIELDS OF TABLE GT_LIST99
     FROM ZTITBLH
     WHERE LIFNR EQ IT_HEADER-LIFNR
       AND IBLNO EQ SPACE.
  ENDLOOP.

  IF GT_LIST99[] IS NOT INITIAL.

    SELECT * INTO CORRESPONDING FIELDS OF TABLE LT_LFA1
      FROM LFA1 FOR ALL ENTRIES IN GT_LIST99
     WHERE LIFNR EQ GT_LIST99-LIFNR.

    SORT LT_LFA1 BY LIFNR .

    LOOP AT GT_LIST99 .
      READ TABLE LT_LFA1 WITH KEY LIFNR = GT_LIST99-LIFNR
                                         BINARY SEARCH.
      IF SY-SUBRC EQ 0.
        GT_LIST99-NAME1 = LT_LFA1-NAME1.
        MODIFY GT_LIST99 TRANSPORTING NAME1.
      ENDIF.

    ENDLOOP.
    CALL SCREEN 7050 STARTING AT 10 5.
  ELSE.

    MESSAGE S999 WITH '매핑대상이 없습니다'.

  ENDIF.


ENDFORM.                    " SET_UPLAOD_DATA


*&---------------------------------------------------------------------*
*&      Form  DISPLAY_STATUS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->PV_MSGTXT1 text
*      -->PV_MSGTXT2 text
*      -->PV_MSGTXT3 text
*      -->PV_MSGTXT4 text
*----------------------------------------------------------------------*
FORM DISPLAY_STATUS USING PV_MSGTXT1
                          PV_MSGTXT2
                          PV_MSGTXT3
                          PV_MSGTXT4.


  DATA: LV_MSGTXT(1024).

  CONCATENATE PV_MSGTXT1 PV_MSGTXT2 PV_MSGTXT3 PV_MSGTXT4
              INTO LV_MSGTXT
              SEPARATED BY SPACE.

  IF SY-BATCH IS INITIAL.
    CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
      EXPORTING
        PERCENTAGE = 0
        TEXT       = LV_MSGTXT
      EXCEPTIONS
        OTHERS     = 1.
  ELSE.
    MESSAGE ID '00' TYPE 'I' NUMBER 398 WITH LV_MSGTXT.
  ENDIF.

ENDFORM.                    "display_status
*&---------------------------------------------------------------------*
*&      Module  ALV_DISPLAY_7050  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE ALV_DISPLAY_7050 OUTPUT.


  IF GS_CUSTOM_CONTAINER99  IS INITIAL.

    CREATE OBJECT GS_CUSTOM_CONTAINER99
      EXPORTING
        CONTAINER_NAME = 'CUSTOM99'.

    CREATE OBJECT GS_ALV_GRID99
      EXPORTING
        I_PARENT = GS_CUSTOM_CONTAINER99.


    PERFORM MAKE_MAIN_LIST_7050.  "MAIN LIST

  ELSE.
*---// ALV Refresh - Column & line fix
    PERFORM REFRESH_TABLE_DISPLAY USING GS_ALV_GRID99.
  ENDIF.



ENDMODULE.                 " ALV_DISPLAY_7050  OUTPUT
*&---------------------------------------------------------------------*
*&      FORM  MAKE_MAIN_LIST
*&---------------------------------------------------------------------*
*       TEXT
*----------------------------------------------------------------------*
*  -->  P1        TEXT
*  <--  P2        TEXT
*----------------------------------------------------------------------*
FORM MAKE_MAIN_LIST_7050 .

  PERFORM ALV_VARIANT99.         " ALV VARIANT
  PERFORM ALV_SORT99.            " SORT1
  PERFORM ALV_LAYOUT99.          " GENERAL LAYOUT
  PERFORM ALV_FIELDCATALOG99.    " FIELD ATTRIBUTE
  PERFORM ALV_TOOLBAR_EXCLUDE. " TOOLBAR DIM
  PERFORM ALV_DISPLAY99.         " DISPLAY
  PERFORM ALV_EVENT99.           " EVENT

*--//EDIT (0: EIDT 불가, 1: EDIT 가능)
  CALL METHOD GS_ALV_GRID99->SET_READY_FOR_INPUT
    EXPORTING
      I_READY_FOR_INPUT = 0.

ENDFORM.                    "MAKE_MAIN_LIST
*&---------------------------------------------------------------------*
*&      FORM  REFRESH_TABLE_DISPLAY
*&---------------------------------------------------------------------*
FORM REFRESH_TABLE_DISPLAY USING PV_GRID TYPE REF TO CL_GUI_ALV_GRID.

  DATA : LS_LAYOUT TYPE LVC_S_LAYO,
         LS_STBL   TYPE LVC_S_STBL.

  IF PV_GRID = GS_ALV_GRID99.
    LS_LAYOUT = GS_LAYOUT99.
    LS_STBL   = GS_STBL99.
  ELSEIF PV_GRID = GS_ALV_GRID99.
    LS_LAYOUT = GS_LAYOUT99.
    LS_STBL   = GS_STBL99.
  ENDIF.

  CALL METHOD PV_GRID->SET_FRONTEND_LAYOUT
    EXPORTING
      IS_LAYOUT = LS_LAYOUT.

  LS_STBL-ROW = 'X'.  "행기준 안정적 최신표시
  LS_STBL-COL = 'X'.  "열기준 정적 최신표시
  CALL METHOD PV_GRID->REFRESH_TABLE_DISPLAY
    EXPORTING
      IS_STABLE = LS_STBL.

  CALL METHOD CL_GUI_CFW=>FLUSH.

ENDFORM.                    " REFRESH_TABLE_DISPLAY

*&---------------------------------------------------------------------*
*&      FORM  ALV_VARIANT
*&---------------------------------------------------------------------*
FORM ALV_VARIANT99 .
  CLEAR GS_VARIANT99.
  GS_VARIANT99-REPORT    = SY-REPID.     "프로그램명
  GS_VARIANT99-USERNAME  = SY-UNAME.     "사용자
  GS_VARIANT99-HANDLE    = 1.
ENDFORM.                    " ALV_VARIANT

*&---------------------------------------------------------------------*
*&      FORM  ALV_SORT
*&---------------------------------------------------------------------*
FORM ALV_SORT99.
  CLEAR : GT_SORT99, GT_SORT99[].
*  PERFORM SORT_FIELD TABLES GT_SORT USING :
*    1  'EBELN'         'X' ' ' 'X'.
**    2  'EBELP'         'X' ' ' 'X',
**    3  'ETENR'         'X' ' ' 'X'.


ENDFORM.                                                    " ALV_SORT

*&---------------------------------------------------------------------*
*&      FORM  SORT_FIELD
*&---------------------------------------------------------------------*
FORM SORT_FIELD  TABLES PT_SORT TYPE LVC_T_SORT
                 USING    P_SPOS
                          P_FIELDNAME
                          P_UP
                          P_DOWN
                          P_SUBTOT.
  PT_SORT-SPOS      = P_SPOS.
  PT_SORT-FIELDNAME = P_FIELDNAME.
  PT_SORT-UP        = P_UP.
  PT_SORT-DOWN      = P_DOWN.
  PT_SORT-SUBTOT    = P_SUBTOT.

  APPEND PT_SORT.
ENDFORM.                    " SORT_FIELD

*&---------------------------------------------------------------------*
*&      FORM  ALV_LAYOUT
*&---------------------------------------------------------------------*
FORM ALV_LAYOUT99 .
  CLEAR GS_LAYOUT.
  GS_LAYOUT99-ZEBRA      = 'X'.          " LINE COLOR
*  GS_LAYOUT-CWIDTH_OPT = 'X'.          " ALV 제어: 열너비최적화
  GS_LAYOUT99-INFO_FNAME = 'INFO'.       " ROW COLOR.
  GS_LAYOUT99-CTAB_FNAME = 'COLINFO'.    " COLUMN COLOR.
  GS_LAYOUT99-STYLEFNAME = 'STYLE'.
  GS_LAYOUT99-SEL_MODE   = 'D'.
*  GS_LAYOUT-NO_ROWMARK = 'X'.
*  GS_LAYOUT-GRID_TITLE = SY-TITLE.

ENDFORM.                    " ALV_LAYOUT

*&---------------------------------------------------------------------*
*&      FORM  ALV_FIELDCATALOG
*&---------------------------------------------------------------------*
FORM ALV_FIELDCATALOG99 .
  DATA : LV_COL_CNT1 TYPE SY-TABIX,
         LV_COL_CNT2 TYPE SY-TABIX,
         LV_COL_CNT3 TYPE SY-TABIX,

         LT_DD03T LIKE TABLE OF DD03T WITH HEADER LINE  .


  SELECT * INTO CORRESPONDING FIELDS OF TABLE LT_DD03T
     FROM  DD03T
    WHERE  TABNAME EQ 'ZTITBLH'
  ORDER BY FIELDNAME DDLANGUAGE.


  CLEAR: GT_FIELDCAT99, GT_FIELDCAT99[], GT_FIELD99, GT_FIELD99[].

* 선언된 인터럴 테이블 값을 가지고 옴
  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      I_PROGRAM_NAME     = SY-REPID
      I_INTERNAL_TABNAME = 'GT_LIST99'
*      I_STRUCTURE_NAME   = 'ZTITBLH'
      I_INCLNAME         = SY-REPID
    CHANGING
      CT_FIELDCAT        = GT_FIELD99[].

* 펑션구조로된 FIELDcat99을 클래스 FIELDcat99으로 변환
  CALL FUNCTION 'LVC_TRANSFER_FROM_SLIS'
    EXPORTING
      IT_FIELDCAT_ALV = GT_FIELD99
    IMPORTING
      ET_FIELDCAT_LVC = GT_FIELDCAT99[]
    TABLES
      IT_DATA         = GT_LIST99
    EXCEPTIONS
      IT_DATA_MISSING = 1
      OTHERS          = 2.


  LOOP AT GT_FIELDCAT99.

    GT_FIELDCAT99-COL_OPT = C_X.

*-  필드명 정의
    READ TABLE LT_DD03T WITH KEY FIELDNAME = GT_FIELDCAT99-FIELDNAME
                                 DDLANGUAGE = SY-LANGU
                                 BINARY SEARCH.
    IF SY-SUBRC EQ 0.
      GT_FIELDCAT99-COLTEXT = LT_DD03T-DDTEXT.
    ELSE.
      READ TABLE LT_DD03T WITH KEY FIELDNAME = GT_FIELDCAT99-FIELDNAME
                                   DDLANGUAGE = SY-LANGU
                                   BINARY SEARCH.
      IF SY-SUBRC EQ 0.
        GT_FIELDCAT99-COLTEXT = LT_DD03T-DDTEXT.
      ENDIF.
    ENDIF.


    CASE GT_FIELDCAT99-FIELDNAME.
      WHEN 'BLNUM' OR 'BLDAT' OR 'LIFNR' .
        GT_FIELDCAT99-KEY = C_X.

      WHEN 'NAME1'.
        GT_FIELDCAT99-COLTEXT  = '업체명'.
      WHEN 'CTNQ2'.
        GT_FIELDCAT99-COLTEXT  = '20FT'.
      WHEN 'CTNQ4'.
        GT_FIELDCAT99-COLTEXT   = '40FT'.


    ENDCASE.

    IF GT_FIELDCAT99-COLTEXT IS NOT INITIAL.
      GT_FIELDCAT99-SCRTEXT_L = GT_FIELDCAT99-SCRTEXT_M =
      GT_FIELDCAT99-SCRTEXT_S = GT_FIELDCAT99-COLTEXT .
    ENDIF.


    MODIFY GT_FIELDCAT99.
  ENDLOOP.
*
*  LOOP AT GT_FIELDCAT99.
*    IF SY-TABIX < 6.
*      GT_FIELDCAT99-EMPHASIZE = C_COL_LGREY.
*    ELSEIF SY-TABIX < 25.
*      GT_FIELDCAT99-EMPHASIZE = C_COL_GREEN.
*    ELSEIF SY-TABIX < 44.
*      GT_FIELDCAT99-EMPHASIZE = C_COL_YELLOW.
*    ELSE.
*      GT_FIELDCAT99-EMPHASIZE = C_COL_GREEN.
*    ENDIF.
*    MODIFY GT_FIELDCAT99.
*  ENDLOOP.


ENDFORM.                    " ALV_FIELDCATALOG

*&---------------------------------------------------------------------*
*&      FORM  ALV_TOOLBAR_EXCLUDE
*&---------------------------------------------------------------------*
FORM ALV_TOOLBAR_EXCLUDE.

  PERFORM ALV_TOOLBAR_EXCLUDE_SET USING :
*          CL_GUI_ALV_GRID=>MC_FC_EXCL_ALL,    " ** 툴바 모두제거 **
          CL_GUI_ALV_GRID=>MC_FC_LOC_UNDO,     " 실행취소 &LOCAL&UNDO
*          CL_GUI_ALV_GRID=>MC_FC_AUF,         " 소계확장 &AUF
*          CL_GUI_ALV_GRID=>MC_FC_AVERAGE,     " &AVERAGE
*          CL_GUI_ALV_GRID=>MC_FC_BACK_CLASSIC,
*          CL_GUI_ALV_GRID=>MC_FC_CALL_ABC,    " &ABC
*          CL_GUI_ALV_GRID=>MC_FC_CALL_CHAIN,
*          CL_GUI_ALV_GRID=>MC_FC_CALL_CRBATCH,
*          CL_GUI_ALV_GRID=>MC_FC_CALL_CRWEB,
*          CL_GUI_ALV_GRID=>MC_FC_CALL_LINEITEMS,
*          CL_GUI_ALV_GRID=>MC_FC_CALL_MASTER_DATA,
*          CL_GUI_ALV_GRID=>MC_FC_CALL_MORE,
*          CL_GUI_ALV_GRID=>MC_FC_CALL_REPORT,
*          CL_GUI_ALV_GRID=>MC_FC_CALL_XINT,
*          CL_GUI_ALV_GRID=>MC_FC_CALL_XXL,
*          CL_GUI_ALV_GRID=>MC_FC_COL_INVISIBLE,
*          CL_GUI_ALV_GRID=>MC_FC_COL_OPTIMIZE,
*          CL_GUI_ALV_GRID=>MC_FC_CURRENT_VARIANT,
*          CL_GUI_ALV_GRID=>MC_FC_DATA_SAVE,
*          CL_GUI_ALV_GRID=>MC_FC_DELETE_FILTER,
*          CL_GUI_ALV_GRID=>MC_FC_DESELECT_ALL,
*          CL_GUI_ALV_GRID=>MC_FC_DETAIL,
*          CL_GUI_ALV_GRID=>MC_FC_EXPCRDATA,
*          CL_GUI_ALV_GRID=>MC_FC_EXPCRDESIG,
*          CL_GUI_ALV_GRID=>MC_FC_EXPCRTEMPL,
*          CL_GUI_ALV_GRID=>MC_FC_EXPMDB,
*          CL_GUI_ALV_GRID=>MC_FC_EXTEND,
*          CL_GUI_ALV_GRID=>MC_FC_F4,
*          CL_GUI_ALV_GRID=>MC_FC_FILTER,
*          CL_GUI_ALV_GRID=>MC_FC_FIND,
*          CL_GUI_ALV_GRID=>MC_FC_FIX_COLUMNS,
*          CL_GUI_ALV_GRID=>MC_FC_GRAPH,
*          CL_GUI_ALV_GRID=>MC_FC_HELP,
*          CL_GUI_ALV_GRID=>MC_FC_INFO,
*          CL_GUI_ALV_GRID=>MC_FC_LOAD_VARIANT,
          CL_GUI_ALV_GRID=>MC_FC_LOC_COPY,          " 행 카피.
*          CL_GUI_ALV_GRID=>MC_FC_HTML,
          CL_GUI_ALV_GRID=>MC_FC_LOC_COPY_ROW,      " 행 카피.
          CL_GUI_ALV_GRID=>MC_FC_LOC_CUT,           " 가위.
          CL_GUI_ALV_GRID=>MC_FC_LOC_DELETE_ROW,    " 행삭제.
          CL_GUI_ALV_GRID=>MC_FC_LOC_INSERT_ROW,    " 행삽입.
*          CL_GUI_ALV_GRID=>MC_FC_LOC_MOVE_ROW,
          CL_GUI_ALV_GRID=>MC_FC_LOC_APPEND_ROW,    " 라인생성.
          CL_GUI_ALV_GRID=>MC_FC_LOC_PASTE,         " 겹쳐쓰기.
          CL_GUI_ALV_GRID=>MC_FC_LOC_PASTE_NEW_ROW, " 겹쳐쓰기.
*          CL_GUI_ALV_GRID=>MC_FC_MAINTAIN_VARIANT,
*          CL_GUI_ALV_GRID=>MC_FC_MAXIMUM,
*          CL_GUI_ALV_GRID=>MC_FC_MINIMUM,
*          CL_GUI_ALV_GRID=>MC_FC_PC_FILE,
*          CL_GUI_ALV_GRID=>MC_FC_PRINT,
*          CL_GUI_ALV_GRID=>MC_FC_PRINT_BACK,
*          CL_GUI_ALV_GRID=>MC_FC_PRINT_PREV,
          CL_GUI_ALV_GRID=>MC_FC_REFRESH.           " 새로고침.
*          CL_GUI_ALV_GRID=>MC_FC_REPREP,
*          CL_GUI_ALV_GRID=>MC_FC_SAVE_VARIANT,
*          CL_GUI_ALV_GRID=>MC_FC_SELECT_ALL,
*          CL_GUI_ALV_GRID=>MC_FC_SEND,
*          CL_GUI_ALV_GRID=>MC_FC_SEPARATOR,
*          CL_GUI_ALV_GRID=>MC_FC_SORT,
*          CL_GUI_ALV_GRID=>MC_FC_SORT_ASC,
*          CL_GUI_ALV_GRID=>MC_FC_SORT_DSC,
*          CL_GUI_ALV_GRID=>MC_FC_SUBTOT,
*          CL_GUI_ALV_GRID=>MC_FC_SUM,
*          CL_GUI_ALV_GRID=>MC_FC_TO_OFFICE,
*          CL_GUI_ALV_GRID=>MC_FC_TO_REP_TREE,
*          CL_GUI_ALV_GRID=>MC_FC_UNFIX_COLUMNS,
*          CL_GUI_ALV_GRID=>MC_FC_VIEWS,
*          CL_GUI_ALV_GRID=>MC_FC_VIEW_CRYSTAL,
*          CL_GUI_ALV_GRID=>MC_FC_VIEW_EXCEL,
*          CL_GUI_ALV_GRID=>MC_FC_VIEW_GRID,
*          CL_GUI_ALV_GRID=>MC_FC_WORD_PROCESSOR.

ENDFORM.                    " ALV_TOOLBAR_EXCLUDE

*&---------------------------------------------------------------------*
*&      FORM  ALV_TOOLBAR_EXCLUDE_SET
*&---------------------------------------------------------------------*
*       툴바 설정
*----------------------------------------------------------------------*
FORM ALV_TOOLBAR_EXCLUDE_SET  USING    VALUE(P_TEXT).

  DATA LS_EXCLUDE TYPE UI_FUNC.

  LS_EXCLUDE = P_TEXT.
  APPEND LS_EXCLUDE TO GT_EXCLUDE99.

ENDFORM.                    " ALV_TOOLBAR_EXCLUDE_SET

*&---------------------------------------------------------------------*
*&      FORM  ALV_DISPLAY
*&---------------------------------------------------------------------*
*       ALV DISPLAY
*----------------------------------------------------------------------*
FORM ALV_DISPLAY99 .

  CALL METHOD GS_ALV_GRID99->SET_TABLE_FOR_FIRST_DISPLAY
    EXPORTING
      I_DEFAULT            = 'X'
      IS_LAYOUT            = GS_LAYOUT99
      IS_VARIANT           = GS_VARIANT99
      IT_TOOLBAR_EXCLUDING = GT_EXCLUDE99
      I_SAVE               = 'A'
    CHANGING
      IT_OUTTAB            = GT_LIST99[]
      IT_FIELDCATALOG      = GT_FIELDCAT99[]
      IT_SORT              = GT_SORT99.

ENDFORM.                    " ALV_DISPLAY

*&---------------------------------------------------------------------*
*&      FORM  ALV_EVENT
*&---------------------------------------------------------------------*
*       EVENT
*----------------------------------------------------------------------*
FORM ALV_EVENT99 .

  CREATE OBJECT GS_EVENT_RECEIVER99.

*--// ALV 변경사항 관리
  SET HANDLER
     GS_EVENT_RECEIVER99->HANDLE_DATA_CHANGED  FOR GS_ALV_GRID99.

* EDIT후 CHANGE EVENT
  CALL METHOD GS_ALV_GRID99->REGISTER_EDIT_EVENT
    EXPORTING
      I_EVENT_ID = CL_GUI_ALV_GRID=>MC_EVT_MODIFIED.

*--// HOTSPOT CLICK EVENT
  SET HANDLER
     GS_EVENT_RECEIVER99->HANDLE_HOTSPOT_CLICK FOR GS_ALV_GRID99.

*--// DOUBLE CLICK EVENT
  SET HANDLER
     GS_EVENT_RECEIVER99->HANDLE_DOUBLE_CLICK FOR GS_ALV_GRID99.

*--// TOOLBAR EVENT
  SET HANDLER
     GS_EVENT_RECEIVER99->HANDLE_TOOLBAR      FOR GS_ALV_GRID99.

*--// USER COMMAND EVENT
  SET HANDLER
     GS_EVENT_RECEIVER99->HANDLE_USER_COMMAND FOR GS_ALV_GRID99.

*--// F4 EVENT
  SET HANDLER
     GS_EVENT_RECEIVER99->HANDLE_ONF4         FOR GS_ALV_GRID99.

ENDFORM.                    "ALV_EVENT
*&---------------------------------------------------------------------*
*&      Form  SET_SSCRFIELDS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SET_SSCRFIELDS .

  IF SY-UCOMM = 'FC01'. "양식 다운로드
    CALL TRANSACTION 'ZTIR210'.
  ENDIF.

ENDFORM.                    " SET_SSCRFIELDS
*&---------------------------------------------------------------------*
*&      Form  SET_SCREEN_FIELD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SET_SCREEN_FIELD .

  GET PARAMETER ID 'BUK' FIELD S_BUKRS-LOW .
  LOOP AT SCREEN .
    IF SCREEN-GROUP1 EQ 'INB'.
      IF S_BUKRS-LOW EQ '3000'.
        SCREEN-INVISIBLE = 0.
        SCREEN-INPUT     = 1.
      ELSE.
        SCREEN-INVISIBLE = 1.
        SCREEN-INPUT     = 0.
      ENDIF.
      MODIFY SCREEN.
    ENDIF.
  ENDLOOP.

  IF S_BUKRS-LOW EQ '3000' AND
     ( SY-TCODE EQ 'ZTIT200' OR  SY-TCODE EQ 'ZTIR201' ).
    CONCATENATE ICON_XLS 'B/L 업로드'
                INTO  SSCRFIELDS-FUNCTXT_01.
  ELSE.
    CLEAR SSCRFIELDS-FUNCTXT_01.
  ENDIF.


ENDFORM.                    " SET_SCREEN_FIELD
*&---------------------------------------------------------------------*
*&      Form  EMTRON_BL_AFTER_EXEC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM EMTRON_BL_AFTER_EXEC .

  IF NOT ZTITBLK-IBLNO IS INITIAL AND
     ZTITBLK-BUKRS EQ '3000'.

    IF GT_LIST99-BLNUM IS NOT INITIAL AND
        ( ZTITBLK-BLNUM  EQ GT_LIST99-BLNUM ).

      UPDATE ZTITBLH  SET IBLNO = ZTITBLK-IBLNO
                          AENAM = SY-UNAME
                          AEDAT = SY-DATUM
                          AEZET = SY-UZEIT
        WHERE  BLNUM    EQ  ZTITBLK-BLNUM .

      CLEAR GT_LIST99 .

      "엠로에 매핑전송
      PERFORM SEND_RFC_EMRO_BL_MAPPING USING 'U'.

    ENDIF.
    IF ZTITBLK-BUKRS EQ '3000'.
      PERFORM CHECK_INVOICE_SCREEN.
    ENDIF.
  ENDIF.

ENDFORM.                    " EMTRON_BL_AFTER_EXEC
*&---------------------------------------------------------------------*
*&      Module  STATUS_7050  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE STATUS_7050 OUTPUT.

  SET PF-STATUS '7050'.
  SET TITLEBAR '7050' WITH GT_LIST99-NAME1.

ENDMODULE.                 " STATUS_7050  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_7050  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_7050 INPUT.

  CASE OK_CODE.
    WHEN 'BACK' OR 'EXIT' OR 'CANC' .
      IF SY-DYNNR EQ '0200'.
*        CALL METHOD GC_ALV_GRID_2->FREE.
*        CLEAR GC_ALV_GIRD.
      ENDIF.
      LEAVE TO SCREEN 0.


    WHEN 'CANCEL'.
      SET SCREEN 0.

    WHEN 'BL_UP'.

      DATA : LT_ROWS TYPE LVC_T_ROW WITH HEADER LINE.
      CALL METHOD GS_ALV_GRID99->GET_SELECTED_ROWS
        IMPORTING
          ET_INDEX_ROWS = LT_ROWS[].

      IF LT_ROWS[] IS NOT INITIAL.

        DESCRIBE TABLE LT_ROWS LINES SY-TFILL.
        IF SY-TFILL > 1.
          MESSAGE S999 WITH '하나의 라인만 선택해주십시오'.
          EXIT.
        ELSE.
          READ TABLE LT_ROWS INDEX 1.
          READ TABLE GT_LIST99 INDEX LT_ROWS-INDEX.
        ENDIF.


        PERFORM USER_COMMAND USING 'BL_UP'
                               GS_SELFIELD.
        CLEAR GT_LIST99.
        LEAVE TO SCREEN 0.
      ELSE.
        MESSAGE S999 WITH '선택된 라인이 없습니다'.
      ENDIF.

  ENDCASE.

ENDMODULE.                 " USER_COMMAND_7050  INPUT
*&---------------------------------------------------------------------*
*&      Form  SET_BL_MAP_EMTRON
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SET_BL_MAP_EMTRON .


  IF SY-TCODE EQ 'ZTIR201' AND ZTITBLK-BUKRS EQ '3000'.
    DATA : LT_LIST99 LIKE GT_LIST99 .

    IMPORT BL_UP_MAP TO LT_LIST99  FROM MEMORY ID 'GT_LIST99'.
    IF LT_LIST99  IS NOT INITIAL.
      MOVE-CORRESPONDING LT_LIST99  TO ZTITBLK.
    ENDIF.
    FREE MEMORY ID 'GT_LIST99'.
  ENDIF.



ENDFORM.                    " SET_BL_MAP_EMTRON
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  SEND_RFC_EMRO_BL_MAPPING
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_2633   text
*      -->P_ENDIF  text
*----------------------------------------------------------------------*
FORM SEND_RFC_EMRO_BL_MAPPING  USING   P_TYPE.

  DATA : LS_SEND LIKE ZMMS281 ,
         LV_DEST      LIKE ZIFDEST-DEST VALUE 'SAPPIPRD',
         LV_MESSAGE   TYPE CHAR100.



  LS_SEND-BLNUM = ZTITBLK-BLNUM.
  LS_SEND-IBLNO = ZTITBLK-IBLNO.
  LS_SEND-UNAM  = SY-UNAME.
  LS_SEND-FLAG  = P_TYPE .

  IF SY-SYSID NE 'R3P'.
    LV_DEST =  'SAPPIDEV'.
  ENDIF.

  CALL FUNCTION 'Z_MM_RFC_EMRO_SND_R01'
    DESTINATION LV_DEST
    EXPORTING
      PS_DATA               = LS_SEND
    EXCEPTIONS
      SYSTEM_FAILURE        = 1  MESSAGE LV_MESSAGE
      COMMUNICATION_FAILURE = 2  MESSAGE LV_MESSAGE
      OTHERS                = 3.

  MESSAGE S999 WITH LV_MESSAGE.

ENDFORM.                    " SEND_RFC_EMRO_BL_MAPPING

*&---------------------------------------------------------------------*
*&      Form  DISLPAY_URL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM DISLPAY_URL .

  DATA : H_HTML_CTRL TYPE CNTL_HANDLE.


  CALL FUNCTION 'CONTROL_INIT' .
  IF SY-SUBRC <> 0.
    EXIT.
  ENDIF.
  CALL FUNCTION 'HTMLCNTL_CREATE'
    EXPORTING
      OWNER_REPID           = SY-REPID
      LINK_REPID            = SY-REPID
      DYNNR                 = '0100'
    CHANGING
      HANDLE                = H_HTML_CTRL
    EXCEPTIONS
      CONTROL_INSTALL_ERROR = 1
      CREATE_ERROR          = 2
      OTHERS                = 3.
  IF SY-SUBRC <> 0.
    EXIT.
  ENDIF.
  CALL FUNCTION 'HTMLCNTL_INIT'
    EXPORTING
      H_CONTROL                  = H_HTML_CTRL
      LEFT                       = 1
      TOP                        = 2
      WIDTH                      = 143
      HEIGHT                     = 37
      REGISTER_EVENT_ON_NAVIGATE = 'X'
      CB_FORM_NAVIGATE_COMPLETE  = 'ON_CONTROL_EVENT'
    EXCEPTIONS
      CNTL_SYSTEM_ERROR          = 1
      CNTL_ERROR                 = 2
      DP_CREATE_ERROR            = 3
      DP_INSTALL_ERROR           = 4
      DP_ERROR                   = 5
      CREATE_BROWSER_ERROR       = 6
      INIT_ERROR                 = 7
      OTHERS                     = 8.
  IF SY-SUBRC <> 0.
    EXIT.
  ENDIF.

 CALL FUNCTION 'CONTROL_FLUSH'.

  CALL FUNCTION 'HTMLCNTL_SHOW_URL'
    EXPORTING
      H_CONTROL = H_HTML_CTRL
      URL       = GV_EMRO_LINK
      FRAME     = C_X.

  IF SY-SUBRC <> 0.
    EXIT.
  ENDIF.

 CALL FUNCTION 'CONTROL_FLUSH'.

*  CALL SCREEN 7060 STARTING AT 10 10.

ENDFORM.                    " DISLPAY_URL
*&---------------------------------------------------------------------*
*&      Module  HTMLCNTL_URL  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE HTMLCNTL_URL OUTPUT.


  DATA : H_HTML_CTRL TYPE CNTL_HANDLE.


  CALL FUNCTION 'CONTROL_INIT' .
  IF SY-SUBRC <> 0.
    EXIT.
  ENDIF.
  CALL FUNCTION 'HTMLCNTL_CREATE'
    EXPORTING
      OWNER_REPID           = SY-REPID
      LINK_REPID            = SY-REPID
      DYNNR                 = '0100'
    CHANGING
      HANDLE                = H_HTML_CTRL
    EXCEPTIONS
      CONTROL_INSTALL_ERROR = 1
      CREATE_ERROR          = 2
      OTHERS                = 3.
  IF SY-SUBRC <> 0.
    EXIT.
  ENDIF.
  CALL FUNCTION 'HTMLCNTL_INIT'
    EXPORTING
      H_CONTROL                  = H_HTML_CTRL
      LEFT                       = 1
      TOP                        = 2
      WIDTH                      = 143
      HEIGHT                     = 37
      REGISTER_EVENT_ON_NAVIGATE = 'X'
      CB_FORM_NAVIGATE_COMPLETE  = 'ON_CONTROL_EVENT'
    EXCEPTIONS
      CNTL_SYSTEM_ERROR          = 1
      CNTL_ERROR                 = 2
      DP_CREATE_ERROR            = 3
      DP_INSTALL_ERROR           = 4
      DP_ERROR                   = 5
      CREATE_BROWSER_ERROR       = 6
      INIT_ERROR                 = 7
      OTHERS                     = 8.
  IF SY-SUBRC <> 0.
    EXIT.
  ENDIF.

 CALL FUNCTION 'CONTROL_FLUSH'.

  CALL FUNCTION 'HTMLCNTL_SHOW_URL'
    EXPORTING
      H_CONTROL = H_HTML_CTRL
      URL       = GV_EMRO_LINK
      FRAME     = C_X.

  IF SY-SUBRC <> 0.
    EXIT.
  ENDIF.

 CALL FUNCTION 'CONTROL_FLUSH'.


ENDMODULE.                 " HTMLCNTL_URL  OUTPUT
