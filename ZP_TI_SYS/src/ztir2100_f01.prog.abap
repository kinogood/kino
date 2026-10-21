*&---------------------------------------------------------------------*
*&  Include           ZMMR1360_F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      FORM  MAKE_MAIN_LIST
*&---------------------------------------------------------------------*
*       TEXT
*----------------------------------------------------------------------*
*  -->  P1        TEXT
*  <--  P2        TEXT
*----------------------------------------------------------------------*
FORM MAKE_MAIN_LIST .

  PERFORM ALV_VARIANT.         " ALV VARIANT
  PERFORM ALV_SORT.            " SORT1
  PERFORM ALV_LAYOUT.          " GENERAL LAYOUT
  PERFORM ALV_FIELDCATALOG.    " FIELD ATTRIBUTE
  PERFORM ALV_TOOLBAR_EXCLUDE. " TOOLBAR DIM
  PERFORM ALV_DISPLAY.         " DISPLAY
  PERFORM ALV_EVENT.           " EVENT

*--//EDIT (0: EIDT 불가, 1: EDIT 가능)
  CALL METHOD GS_ALV_GRID->SET_READY_FOR_INPUT
    EXPORTING
      I_READY_FOR_INPUT = 1.

ENDFORM.                    "MAKE_MAIN_LIST

*&---------------------------------------------------------------------*
*&      FORM  ALV_VARIANT
*&---------------------------------------------------------------------*
FORM ALV_VARIANT .
  CLEAR GS_VARIANT.
  GS_VARIANT-REPORT    = SY-REPID.     "프로그램명
  GS_VARIANT-USERNAME  = SY-UNAME.     "사용자
  GS_VARIANT-HANDLE    = 1.
ENDFORM.                    " ALV_VARIANT

*&---------------------------------------------------------------------*
*&      FORM  ALV_SORT
*&---------------------------------------------------------------------*
FORM ALV_SORT.
  CLEAR : GT_SORT, GT_SORT[].
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
FORM ALV_LAYOUT .
  CLEAR GS_LAYOUT.
  GS_LAYOUT-ZEBRA      = 'X'.          " LINE COLOR
*  GS_LAYOUT-CWIDTH_OPT = 'X'.          " ALV 제어: 열너비최적화
  GS_LAYOUT-INFO_FNAME = 'INFO'.       " ROW COLOR.
  GS_LAYOUT-CTAB_FNAME = 'COLINFO'.    " COLUMN COLOR.
  GS_LAYOUT-STYLEFNAME = 'STYLE'.
  GS_LAYOUT-SEL_MODE   = 'D'.
*  GS_LAYOUT-NO_ROWMARK = 'X'.
*  GS_LAYOUT-GRID_TITLE = SY-TITLE.

ENDFORM.                    " ALV_LAYOUT

*&---------------------------------------------------------------------*
*&      FORM  ALV_FIELDCATALOG
*&---------------------------------------------------------------------*
FORM ALV_FIELDCATALOG .
  DATA : LV_COL_CNT1 TYPE SY-TABIX,
         LV_COL_CNT2 TYPE SY-TABIX,
         LV_COL_CNT3 TYPE SY-TABIX,

         LT_DD03T LIKE TABLE OF DD03T WITH HEADER LINE  .


  SELECT * INTO CORRESPONDING FIELDS OF TABLE LT_DD03T
     FROM  DD03T
    WHERE  TABNAME EQ 'ZTITBLH'
  ORDER BY FIELDNAME DDLANGUAGE.


  CLEAR: GT_FIELDCAT, GT_FIELDCAT[], GT_FIELD, GT_FIELD[].

* 선언된 인터럴 테이블 값을 가지고 옴
  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      I_PROGRAM_NAME     = SY-REPID
      I_INTERNAL_TABNAME = 'GT_LIST'
*      I_STRUCTURE_NAME   = 'ZTITBLH'
      I_INCLNAME         = SY-REPID
    CHANGING
      CT_FIELDCAT        = GT_FIELD[].

* 펑션구조로된 FIELDCAT을 클래스 FIELDCAT으로 변환
  CALL FUNCTION 'LVC_TRANSFER_FROM_SLIS'
    EXPORTING
      IT_FIELDCAT_ALV = GT_FIELD
    IMPORTING
      ET_FIELDCAT_LVC = GT_FIELDCAT[]
    TABLES
      IT_DATA         = GT_LIST
    EXCEPTIONS
      IT_DATA_MISSING = 1
      OTHERS          = 2.


  LOOP AT GT_FIELDCAT.

    GT_FIELDCAT-COL_OPT = C_X.
    GT_FIELDCAT-EDIT = 'X'.


*-  필드명 정의
    READ TABLE LT_DD03T WITH KEY FIELDNAME = GT_FIELDCAT-FIELDNAME
                                 DDLANGUAGE = SY-LANGU
                                 BINARY SEARCH.
    IF SY-SUBRC EQ 0.
      GT_FIELDCAT-COLTEXT = LT_DD03T-DDTEXT.
    ELSE.
      READ TABLE LT_DD03T WITH KEY FIELDNAME = GT_FIELDCAT-FIELDNAME
                                   DDLANGUAGE = SY-LANGU
                                   BINARY SEARCH.
      IF SY-SUBRC EQ 0.
        GT_FIELDCAT-COLTEXT = LT_DD03T-DDTEXT.
      ENDIF.
    ENDIF.


    CASE GT_FIELDCAT-FIELDNAME.
     WHEN 'BLNUM' OR 'BLDAT' OR 'LIFNR' .
        GT_FIELDCAT-KEY = C_X.
     WHEN 'NAME1'.
        GT_FIELDCAT-COLTEXT  = '업체명'.
      WHEN 'CTNQ2'.
        GT_FIELDCAT-COLTEXT  = '20FT'.
      WHEN 'CTNQ4'.
        GT_FIELDCAT-COLTEXT   = '40FT'.
      WHEN 'FWDTX'.
        GT_FIELDCAT-COLTEXT   = '포더업체명'.
     WHEN 'VOLUM'.
         GT_FIELDCAT-QUANTITY = 'M3'.
     WHEN 'BRGEW'.
         GT_FIELDCAT-QUANTITY = 'KG'.
     WHEN 'BIPKG'.
         GT_FIELDCAT-QUANTITY = 'GT'.
     WHEN 'FPORT'.
         GT_FIELDCAT-F4AVAILABL = C_X.

    WHEN 'IBLNO'.
         CLEAR GT_FIELDCAT-EDIT.

    ENDCASE.

    IF GT_FIELDCAT-COLTEXT IS NOT INITIAL.
      GT_FIELDCAT-SCRTEXT_L = GT_FIELDCAT-SCRTEXT_M =
      GT_FIELDCAT-SCRTEXT_S = GT_FIELDCAT-COLTEXT .
    ENDIF.



    MODIFY GT_FIELDCAT.
  ENDLOOP.

*  LOOP AT GT_FIELDCAT.
*    IF SY-TABIX < 6.
*      GT_FIELDCAT-EMPHASIZE = C_COL_LGREY.
*    ELSEIF SY-TABIX < 25.
*      GT_FIELDCAT-EMPHASIZE = C_COL_GREEN.
*    ELSEIF SY-TABIX < 44.
*      GT_FIELDCAT-EMPHASIZE = C_COL_YELLOW.
*    ELSE.
*      GT_FIELDCAT-EMPHASIZE = C_COL_GREEN.
*    ENDIF.
*    MODIFY GT_FIELDCAT.
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
  APPEND LS_EXCLUDE TO GT_EXCLUDE.

ENDFORM.                    " ALV_TOOLBAR_EXCLUDE_SET

*&---------------------------------------------------------------------*
*&      FORM  ALV_DISPLAY
*&---------------------------------------------------------------------*
*       ALV DISPLAY
*----------------------------------------------------------------------*
FORM ALV_DISPLAY .

  CALL METHOD GS_ALV_GRID->SET_TABLE_FOR_FIRST_DISPLAY
    EXPORTING
      I_DEFAULT            = 'X'
      IS_LAYOUT            = GS_LAYOUT
      IS_VARIANT           = GS_VARIANT
      IT_TOOLBAR_EXCLUDING = GT_EXCLUDE
      I_SAVE               = 'A'
    CHANGING
      IT_OUTTAB            = GT_LIST[]
      IT_FIELDCATALOG      = GT_FIELDCAT[]
      IT_SORT              = GT_SORT.

ENDFORM.                    " ALV_DISPLAY

*&---------------------------------------------------------------------*
*&      FORM  ALV_EVENT
*&---------------------------------------------------------------------*
*       EVENT
*----------------------------------------------------------------------*
FORM ALV_EVENT .

  CREATE OBJECT GS_EVENT_RECEIVER.

*--// ALV 변경사항 관리
  SET HANDLER
     GS_EVENT_RECEIVER->HANDLE_DATA_CHANGED  FOR GS_ALV_GRID.

* EDIT후 CHANGE EVENT
  CALL METHOD GS_ALV_GRID->REGISTER_EDIT_EVENT
    EXPORTING
      I_EVENT_ID = CL_GUI_ALV_GRID=>MC_EVT_MODIFIED.

*--// HOTSPOT CLICK EVENT
  SET HANDLER
     GS_EVENT_RECEIVER->HANDLE_HOTSPOT_CLICK FOR GS_ALV_GRID.

*--// DOUBLE CLICK EVENT
  SET HANDLER
     GS_EVENT_RECEIVER->HANDLE_DOUBLE_CLICK FOR GS_ALV_GRID.

*--// TOOLBAR EVENT
  SET HANDLER
     GS_EVENT_RECEIVER->HANDLE_TOOLBAR      FOR GS_ALV_GRID.

*--// USER COMMAND EVENT
  SET HANDLER
     GS_EVENT_RECEIVER->HANDLE_USER_COMMAND FOR GS_ALV_GRID.

*--// F4 EVENT
  SET HANDLER
     GS_EVENT_RECEIVER->HANDLE_ONF4         FOR GS_ALV_GRID.

ENDFORM.                    "ALV_EVENT
*&---------------------------------------------------------------------*
*&      FORM  ALV_VARIANT99
*&---------------------------------------------------------------------*
FORM ALV_VARIANT99 .
  CLEAR GS_VARIANT99.
  GS_VARIANT99-REPORT    = SY-REPID.     "프로그램명
  GS_VARIANT99-USERNAME  = SY-UNAME.     "사용자
  GS_VARIANT99-HANDLE    = 2.
ENDFORM.                    " ALV_VARIANT99

*&---------------------------------------------------------------------*
*&      FORM  ALV_LAYOUT99
*&---------------------------------------------------------------------*
FORM ALV_LAYOUT99 .
  CLEAR GS_LAYOUT99.
  GS_LAYOUT99-ZEBRA      = 'X'.          " LINE COLOR
*  GS_LAYOUT99-CWIDTH_OPT = 'X'.          " ALV 제어: 열너비최적화
  GS_LAYOUT99-INFO_FNAME = 'INFO'.       " ROW COLOR.
  GS_LAYOUT99-CTAB_FNAME = 'COLINFO'.    " COLUMN COLOR.
  GS_LAYOUT99-STYLEFNAME = 'STYLE'.
  GS_LAYOUT99-SEL_MODE   = 'D'.
*  GS_LAYOUT99-NO_ROWMARK = 'X'.
*  GS_LAYOUT99-GRID_TITLE = SY-TITLE.

ENDFORM.                    " ALV_LAYOUT99
*&---------------------------------------------------------------------*
*&      FORM  REFRESH_TABLE_DISPLAY
*&---------------------------------------------------------------------*
FORM REFRESH_TABLE_DISPLAY USING PV_GRID TYPE REF TO CL_GUI_ALV_GRID.

  DATA : LS_LAYOUT TYPE LVC_S_LAYO,
         LS_STBL   TYPE LVC_S_STBL.

  IF PV_GRID = GS_ALV_GRID.
    LS_LAYOUT = GS_LAYOUT.
    LS_STBL   = GS_STBL.
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
*&      Form  TOOLBAR_PART
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_SENDER  text
*      -->P_E_OBJECT  text
*      -->P_E_INTERACTIVE  text
*----------------------------------------------------------------------*
FORM TOOLBAR_PART  USING P_SENDER TYPE REF TO CL_GUI_ALV_GRID
                         R_OBJECT TYPE REF TO CL_ALV_EVENT_TOOLBAR_SET
                         R_INTERACTIVE.

  DATA : LS_TOOLBAR  TYPE STB_BUTTON.

  CASE P_SENDER .
    WHEN GS_ALV_GRID.
*-- 분리 구분자
*      CLEAR LS_TOOLBAR.
*      MOVE 3                  TO LS_TOOLBAR-BUTN_TYPE.
*      APPEND LS_TOOLBAR       TO R_OBJECT->MT_TOOLBAR.
*
*      CLEAR LS_TOOLBAR.
*      MOVE 'ZSELE'            TO LS_TOOLBAR-FUNCTION.
*      MOVE TEXT-B01           TO LS_TOOLBAR-QUICKINFO.  " 대상선정
*      MOVE TEXT-B01           TO LS_TOOLBAR-TEXT.
*      APPEND LS_TOOLBAR       TO R_OBJECT->MT_TOOLBAR.
*
*      CLEAR LS_TOOLBAR.
*      MOVE 3                  TO LS_TOOLBAR-BUTN_TYPE.
*      APPEND LS_TOOLBAR       TO R_OBJECT->MT_TOOLBAR.
*
*     CHECK SY-TCODE EQ C_TCODE.
*     IF RB_CR IS NOT INITIAL.
*      CLEAR LS_TOOLBAR.
*      MOVE 'ZCREATE'            TO LS_TOOLBAR-FUNCTION.
*      MOVE TEXT-B02           TO LS_TOOLBAR-QUICKINFO.  " 대상선정
*      MOVE TEXT-B02           TO LS_TOOLBAR-TEXT.
*      APPEND LS_TOOLBAR       TO R_OBJECT->MT_TOOLBAR.
*
*      CLEAR LS_TOOLBAR.
*      MOVE 3                  TO LS_TOOLBAR-BUTN_TYPE.
*      APPEND LS_TOOLBAR       TO R_OBJECT->MT_TOOLBAR.
*     ENDIF.
*
*     IF RB_CN IS NOT INITIAL.
*      CLEAR LS_TOOLBAR.
*      MOVE 'ZCANCEL'          TO LS_TOOLBAR-FUNCTION.
*      MOVE TEXT-B03           TO LS_TOOLBAR-QUICKINFO.  " 대상선정
*      MOVE TEXT-B03           TO LS_TOOLBAR-TEXT.
*      APPEND LS_TOOLBAR       TO R_OBJECT->MT_TOOLBAR.
*     ENDIF.

    WHEN GS_ALV_GRID99.


  ENDCASE.

ENDFORM.                    "TOOLBAR_PART
*&---------------------------------------------------------------------*
*&      Form  USER_COMMAND_PART
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_SENDER  text
*      -->P_E_UCOMM  text
*----------------------------------------------------------------------*
FORM USER_COMMAND_PART  USING P_SENDER TYPE REF TO CL_GUI_ALV_GRID
                              P_UCOMM.

  CASE P_SENDER.
    WHEN GS_ALV_GRID.

      CASE P_UCOMM.

      ENDCASE.

    WHEN GS_ALV_GRID99.

  ENDCASE.

*---// ALV Refresh - Column & line fix
  PERFORM REFRESH_TABLE_DISPLAY USING GS_ALV_GRID.


ENDFORM.                    "USER_COMMAND_PART
*&---------------------------------------------------------------------*
*&      Form  GET_SELECT_ROWS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GT_ROWS  text
*      -->P_GS_ALV_GRID  text
*      <--P_GV_CHK  text
*----------------------------------------------------------------------*
FORM GET_SELECT_ROWS  TABLES PT_ROWS TYPE LVC_T_ROW
                        USING PV_GRID TYPE REF TO CL_GUI_ALV_GRID
                      CHANGING PV_CHK.

  DATA : LV_LINE TYPE I.
  CLEAR : PV_CHK, PT_ROWS, PT_ROWS[].

*--화면상 선택한 라인을 불러옴
  CALL METHOD PV_GRID->GET_SELECTED_ROWS
    IMPORTING
      ET_INDEX_ROWS = PT_ROWS[].

  READ TABLE PT_ROWS TRANSPORTING NO FIELDS INDEX 1.
  DESCRIBE TABLE PT_ROWS LINES LV_LINE.

  IF LV_LINE = 0.
    PV_CHK = C_X.
    MESSAGE S005 WITH '자료가 선택되지 않았습니다.' .
    EXIT.
  ELSEIF LV_LINE > 1 AND PV_GRID EQ GS_ALV_GRID.
    PV_CHK = C_X.
    MESSAGE S005 WITH '라인별 처리 가능합니다' .
    EXIT.
  ENDIF.

ENDFORM.                    "GET_SELECT_ROWS
*&---------------------------------------------------------------------*
*&      Form  HANDLE_DATA_CHANGED
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_SENDER  text
*      -->P_ER_DATA_CHANGED  text
*----------------------------------------------------------------------*
FORM HANDLE_DATA_CHANGED  USING    P_SENDER TYPE REF TO CL_GUI_ALV_GRID
                                   PR_DATA_CHANGED  TYPE REF TO
                                   CL_ALV_CHANGED_DATA_PROTOCOL.

  DATA :   LT_GOOD_CELLS TYPE LVC_T_MODI,
           LS_GOOD       TYPE LVC_S_MODI,
           LV_LIFNR      LIKE LFA1-LIFNR,
           LV_TEXT       LIKE LFA1-NAME1,

           BEGIN OF LT_TEMP OCCURS 0,
             BANKS  LIKE LFBK-BANKS,
             BANKL LIKE LFBK-BANKL,
             BANKN LIKE LFBK-BANKN,
             BANKA LIKE BNKA-BANKA,
             KOINH LIKE LFBK-KOINH,
             BVTYP LIKE LFBK-BVTYP,
             HBKID LIKE T012-HBKID,
           END OF LT_TEMP.

  CLEAR : LT_GOOD_CELLS, LT_GOOD_CELLS[], LS_GOOD,
          LV_TEXT(20),LT_TEMP[].


  SORT PR_DATA_CHANGED->MT_GOOD_CELLS BY ROW_ID.

* data 핸들 변경하는 부분
  IF P_SENDER = GS_ALV_GRID.
     LOOP AT PR_DATA_CHANGED->MT_GOOD_CELLS INTO LS_GOOD.
        CASE LS_GOOD-FIELDNAME.
          WHEN 'LIFNR'.
            SELECT SINGLE NAME1 INTO LV_TEXT
                     FROM LFA1 WHERE LIFNR EQ LS_GOOD-VALUE.
            CALL METHOD PR_DATA_CHANGED->MODIFY_CELL
                  EXPORTING
                    I_ROW_ID    = LS_GOOD-ROW_ID
                    I_FIELDNAME = 'NAME1'
                    I_VALUE     =  LV_TEXT.

          WHEN 'FWDCD'.
            SELECT SINGLE NAME1 INTO LV_TEXT
                     FROM LFA1 WHERE LIFNR EQ LS_GOOD-VALUE.
            CALL METHOD PR_DATA_CHANGED->MODIFY_CELL
                  EXPORTING
                    I_ROW_ID    = LS_GOOD-ROW_ID
                    I_FIELDNAME = 'FWDTX'
                    I_VALUE     =  LV_TEXT.


*          WHEN 'BANKN'.
*              READ TABLE GT_DISP99 INDEX LS_GOOD-ROW_ID.
*              SELECT A~BANKS, A~BANKL,  A~BANKN, A~BVTYP, A~KOINH,
*                      B~BANKA , C~HBKID
*                INTO CORRESPONDING FIELDS OF TABLE @LT_TEMP
*               FROM LFBK AS A INNER JOIN BNKA AS B
*                                      ON A~BANKS EQ B~BANKS
*                                     AND A~BANKL EQ B~BANKL
*                              INNER JOIN T012 AS C
*                                      ON A~BANKS EQ C~BANKS
*                                     AND A~BANKL EQ C~BANKL
*               WHERE A~LIFNR EQ @GT_DISP99-LIFNR
*                AND  A~BANKN EQ @GT_DISP99-BANKN
*                AND  C~BUKRS EQ @GT_LIST-BUKRS .
*                IF SY-SUBRC NE 0.
*                 CALL METHOD PR_DATA_CHANGED->MODIFY_CELL
*                   EXPORTING
*                    I_ROW_ID    = LS_GOOD-ROW_ID
*                    I_FIELDNAME = 'BANKN'
*                    I_VALUE     =  ''.
*MESSAGE S001 WITH '공급업체에 허용하지 않는 계좌번호입니다'.
*                ENDIF.
         ENDCASE.
     ENDLOOP.
  ENDIF.


ENDFORM.                    "HANDLE_DATA_CHANGED
*&---------------------------------------------------------------------*
*&      Form  GET_F4_FIELD_ENTRY99
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_F4_FIELD_ENTRY99 .

  CLEAR : GT_F4, GT_F4[].

  GS_F4-FIELDNAME  = 'BANKN'.
  GS_F4-REGISTER   = 'X'.
  APPEND GS_F4 TO GT_F4.

  "검사특성 팝업
  CALL METHOD GS_ALV_GRID99->REGISTER_F4_FOR_FIELDS
    EXPORTING
      IT_F4 = GT_F4.

ENDFORM.                    "GET_F4_FIELD_ENTRY99
*&---------------------------------------------------------------------*
*&      Form  GET_ON_F4
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM GET_ON_F4  USING  P_SENDER
                        E_FIELDNAME TYPE LVC_FNAME
                        E_FIELDVALUE   TYPE LVC_VALUE
                        ES_ROW_NO      TYPE LVC_S_ROID
                        ER_EVENT_DATA  TYPE REF TO CL_ALV_EVENT_DATA
                        ET_BAD_CELLS   TYPE LVC_T_MODI
                        E_DISPLAY      TYPE CHAR01.

  CASE P_SENDER.
      "검사특성 팝업
    WHEN GS_ALV_GRID99.

      CASE E_FIELDNAME.
        WHEN 'BANKN'.
      ENDCASE.

  ENDCASE.

  PERFORM REFRESH_TABLE_DISPLAY USING GS_ALV_GRID99.

ENDFORM.                    "GET_ON_F4
*&---------------------------------------------------------------------*
*&      Form  HANDLE_DOUBLE_CLICK
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM HANDLE_DOUBLE_CLICK  USING  P_SENDER
                                 P_ROW    TYPE LVC_S_ROW-INDEX
                                 P_COLUMN TYPE LVC_S_COL-FIELDNAME.

  CHECK NOT P_ROW IS INITIAL.

*  CASE P_SENDER.
*      "상단리스트(헤더)
*    WHEN GS_ALV_GRID.
*      READ TABLE GT_LIST INDEX P_ROW.
*      CHECK SY-SUBRC = 0.
*
*      CASE P_COLUMN.
*        WHEN 'EBELN' OR 'EBELP'.
*          CHECK GT_LIST-EBELN IS NOT INITIAL .
*          PERFORM DISPLAY_PURCHASE_ORDER USING GT_LIST-EBELN
*                                               GT_LIST-EBELP.
*
*        WHEN 'MATNR'.
*          CHECK GT_LIST-MATNR IS NOT INITIAL .
*          CALL FUNCTION 'BAPI_MATERIAL_DISPLAY'
*            EXPORTING
*              MATERIAL = GT_LIST-MATNR.
*      ENDCASE.
*  ENDCASE.

ENDFORM.                    "HANDLE_DOUBLE_CLICK

*&---------------------------------------------------------------------*
*&      Form  display_LIV_DOCUMENT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM DISPLAY_LIV_DOCUMENT  USING    P_BELNR
                                    P_GJAHR
                                    P_BUKRS
                                    P_FI_CHK.

  CHECK NOT P_BELNR IS INITIAL.
  IF P_FI_CHK IS INITIAL.
    SET PARAMETER ID 'RBN' FIELD P_BELNR.
    SET PARAMETER ID 'GJR' FIELD P_GJAHR.
    CALL TRANSACTION 'MIR4' AND SKIP FIRST SCREEN.
  ELSE.
    SET PARAMETER ID 'BLN' FIELD P_BELNR.
    SET PARAMETER ID 'GJR' FIELD P_GJAHR.
    SET PARAMETER ID 'BUK' FIELD P_BUKRS.
    CALL TRANSACTION 'FB03' AND SKIP FIRST SCREEN.

  ENDIF.

ENDFORM .                    "DISPLAY_LIV_DOCUMENT

*&---------------------------------------------------------------------*
*&      Form  display_purchase_order
*&---------------------------------------------------------------------*
FORM DISPLAY_PURCHASE_ORDER  USING    P_EBELN  LIKE EKPO-EBELN
                                      P_EBELP.
  DATA: L_EBELP  LIKE EKPO-EBELP.
  L_EBELP = P_EBELP.
  CHECK NOT P_EBELN IS INITIAL.
  IF SY-BINPT IS INITIAL.
    SET PARAMETER ID 'ENJ_CALL_ME23N' FIELD 'X'.
  ELSE.
    SET PARAMETER ID 'ENJ_CALL_ME23N' FIELD SPACE.
  ENDIF.
  CLEAR: SY-BINPT .

  CALL FUNCTION 'ME_DISPLAY_PURCHASE_DOCUMENT'
    EXPORTING
      I_EBELN              = P_EBELN
      I_EBELP              = L_EBELP
      I_ENJOY              = 'X'
*     I_PREVIEW            =
*     I_DATA_FROM_BUFFER   =
*     I_BSTYP              =
*     I_DISPLAY_ONLY       = ' '
*     I_EDIT               = ' '
*     I_ETENR              =
*     I_DOC_INITIATOR      =
    EXCEPTIONS
      NOT_FOUND            = 1
      NO_AUTHORITY         = 2
      INVALID_CALL         = 3
      PREVIEW_NOT_POSSIBLE = 4
      OTHERS               = 5.
  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

ENDFORM.                    " display_purchase_order
**&---------------------------------------------------------------------
**
**&      Form  SET_TITLE_SUB
**&---------------------------------------------------------------------
**
**       text
**----------------------------------------------------------------------
**
*FORM SET_TITLE_SUB .
*
* DATA : LV_TITLE_SUB(40).
*
* CONCATENATE '-' GV_TITLE_SUB '[구매오더' GT_LIST-EBELN ']'
*        INTO LV_TITLE_SUB SEPARATED BY SPACE .
* SET TITLEBAR  '0100' WITH LV_TITLE_SUB.
*
*ENDFORM.
**&---------------------------------------------------------------------
**
**&      Form  GRID_CHECK_CHANGED_DATA
**&---------------------------------------------------------------------
**
**       text
**----------------------------------------------------------------------
**
**      -->P_GS_ALV_GRID99  text
**----------------------------------------------------------------------
**
*FORM GRID_CHECK_CHANGED_DATA  USING PV_GRID  TYPE REF TO
*CL_GUI_ALV_GRID.
*
*  DATA : LV_VALID.
*
*  "ALV최신화
*  CALL METHOD PV_GRID->CHECK_CHANGED_DATA
*    IMPORTING
*      E_VALID = LV_VALID.
*
*ENDFORM.
**&---------------------------------------------------------------------
**
**&      Form  SET_CBO_DATE_SINGLE
**&---------------------------------------------------------------------
**
**       text
**----------------------------------------------------------------------
**
*FORM SET_CBO_DATE_SINGLE  USING PS_INPUT .
*
*  CALL FUNCTION 'ZMME_SET_CBO_DATE_SINGLE'
*   EXPORTING
*     P_CLEAR        = SPACE
*    CHANGING
*      PS_DATA       = PS_INPUT .
*
*ENDFORM.
**&---------------------------------------------------------------------
**
**&      Form  START_BAL_LOG
**&---------------------------------------------------------------------
**
**       text
**----------------------------------------------------------------------
**
*FORM OPEN_BAL_LOG .
*
** log Open
*      GS_LOG-EXTNUMBER  = 'Log'.
*
*      CALL FUNCTION 'BAL_LOG_CREATE'
*        EXPORTING
*          I_S_LOG      = GS_LOG
*        IMPORTING
*          E_LOG_HANDLE = GV_LOG_HANDLE
*        EXCEPTIONS
*          OTHERS       = 1.
*
** get display profile
*      CALL FUNCTION 'BAL_DSP_PROFILE_POPUP_GET'
*        IMPORTING
*          E_S_DISPLAY_PROFILE = GS_DISPLAY_PROFILE
*        EXCEPTIONS
*          OTHERS              = 1.
*
*
*ENDFORM.
**&---------------------------------------------------------------------
**
**&      Form  CLOSE_BAL_LOG
**&---------------------------------------------------------------------
**
**       text
**----------------------------------------------------------------------
**
*FORM CLOSE_BAL_LOG .
*
** use grid for display if wanted
**  gs_display_profile-use_grid = 'X'.
*      GS_DISPLAY_PROFILE-DISVARIANT-REPORT = SY-REPID.
*      GS_DISPLAY_PROFILE-DISVARIANT-HANDLE = 'LOG'.
*      GS_DISPLAY_PROFILE-NO_TOOLBAR        = 'X'.
*      GS_DISPLAY_PROFILE-TITLE             = 'Log Display'.
*
*      CALL FUNCTION 'BAL_DSP_LOG_DISPLAY'
*        EXPORTING
*          I_S_DISPLAY_PROFILE = GS_DISPLAY_PROFILE
*        EXCEPTIONS
*          OTHERS              = 1.
*
*      CALL FUNCTION 'BAL_LOG_REFRESH'
*        EXPORTING
*          I_LOG_HANDLE = GV_LOG_HANDLE
*        EXCEPTIONS
*          OTHERS       = 1.
*
*ENDFORM.
*
**&---------------------------------------------------------------------
**
**&      Form  p4000_add_log
**&---------------------------------------------------------------------
**
*FORM P4000_ADD_LOG  USING    P_MSGID
*                             P_MSGNO
*                             P_MSGTY
*                             P_MSGV1
*                             P_MSGV2
*                             P_MSGV3
*                             P_MSGV4  .
*
*  GS_MSG-MSGID       =  P_MSGID.
*  GS_MSG-MSGNO       =  P_MSGNO.
*  GS_MSG-MSGTY       =  P_MSGTY.
*  GS_MSG-MSGV1       =  P_MSGV1.
*  GS_MSG-MSGV2       =  P_MSGV2.
*  GS_MSG-MSGV3       =  P_MSGV3.
*  GS_MSG-MSGV4       =  P_MSGV3.
*
*  IF P_MSGTY = 'S'.
*    GS_MSG-PROBCLASS   =  '2'.
*  ELSE.
*    GS_MSG-PROBCLASS   =  '1'.
*  ENDIF.
*
** Save
*  CALL FUNCTION 'BAL_LOG_MSG_ADD'
*    EXPORTING
*      I_LOG_HANDLE = GV_LOG_HANDLE
*      I_S_MSG      = GS_MSG
*    EXCEPTIONS
*      OTHERS       = 1.
*
*ENDFORM.                    " p4000_add_log
*&---------------------------------------------------------------------
*
*&      Form  CHECK_MESSAGE
*&---------------------------------------------------------------------
*
*       text
*----------------------------------------------------------------------
*
FORM CHECK_MESSAGE  USING  P_TYPE .

  DATA : LV_TITLE(20), LV_MESSAGE(100).

  CASE P_TYPE.
    WHEN 'SAVE'.
      LV_TITLE =   '저장 메시지'.

      LV_MESSAGE   =  '조회된 업로드 내역을 저장하시겠습니까?'.

*    WHEN 'CANCEL'.
*      LV_TITLE =   '전표취소 메시지'.
*      LV_MESSAGE   =  '구매오더[' && GT_LIST-EBELN && ']의 분리' &&
*                      '전표를 취소 하시겠습니까?'.

  ENDCASE.

  PERFORM POPUP_CONFIRM USING LV_TITLE
                              LV_MESSAGE
                             CHANGING GV_ANSWER.

  CHECK  GV_ANSWER EQ '1'.

  "작업중 메세지
  PERFORM PROGRESS_INDICATOR USING '처리중입니다.'
                                   '1'.


ENDFORM.                    "CHECK_MESSAGE
*&---------------------------------------------------------------------*
*&      Form  SET_DATE_INIT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SET_INIT .



ENDFORM.                    " SET_DATE_INIT
*&---------------------------------------------------------------------*
*&      Form  EXCEL_UPLOAD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM EXCEL_UPLOAD .

  DATA : LV_INDEX      TYPE  I,
         LV_YEAR(4)    ,
         LV_DATUM      LIKE  SY-DATUM  ,
         LV_UZEIT      LIKE  SY-UZEIT  .

  DATA: LV_FNAME            TYPE RLGRAP-FILENAME,"string,
        LV_FILENAME         LIKE RLGRAP-FILENAME.


  DATA : BEGIN OF LT_UPLOAD OCCURS 0,
            BLNUM TYPE CHAR100, "B/L 번호
            BLDAT TYPE CHAR100, "B/L발행일
            NAME1 TYPE CHAR100, "업체명
            LIFNR TYPE CHAR100, "공급업체 계정 번호
            FWDCD TYPE CHAR100, "포워더
            FWDTY TYPE CHAR100, "운송 방법
            FWDFM TYPE CHAR100, "운송형태

            CTNQ2 TYPE CHAR100, "20FT 컨테이너 수
            CTNQ4 TYPE CHAR100, "40FT 컨테이너 수


            CTNTY TYPE CHAR100, "컨테이너 종류
            BIPKG TYPE CHAR100, "포장개수

            BRGEW TYPE CHAR100, "총중량


            VOLUM TYPE CHAR100, "볼륨


            IVSLN TYPE CHAR100, "선기명(주운송수단)
            BLETD TYPE CHAR100, "ETD(출발 예정 시각)
            BLETA TYPE CHAR100, "ETA(도착 예정 시각)

            FLAND TYPE CHAR100, "선적국
            FPORT TYPE CHAR100, "선적항

         END OF LT_UPLOAD.

  DATA : LT_LFA1 LIKE TABLE OF LFA1 WITH HEADER LINE.

  FIELD-SYMBOLS : <FS_FIELD> TYPE ANY.



  DEFINE READ_EXCEL.
    CALL FUNCTION 'ZMM_ALSMEX_EXCEL_TO_TABLE'
      EXPORTING
        FILENAME                = P_FNAME
        I_WORKSHEET_NAME        = &1
        I_BEGIN_COL             = &2
        I_BEGIN_ROW             = &3
        I_END_COL               = 100
        I_END_ROW               = 2000
      TABLES
        INTERN                  = GT_EXCEL
      EXCEPTIONS
        INCONSISTENT_PARAMETERS = 1
        UPLOAD_OLE              = 2
        OTHERS                  = 3.
  END-OF-DEFINITION.


  PERFORM DISPLAY_STATUS  USING
          'B/L 정보를 업로드 중입니다...' '' '' ''.

  READ_EXCEL '' 1 2.

  LOOP AT GT_EXCEL .

    LV_INDEX = GT_EXCEL-COL .

    ASSIGN COMPONENT LV_INDEX OF STRUCTURE LT_UPLOAD TO <FS_FIELD>.
    <FS_FIELD> = GT_EXCEL-VALUE.
    CONDENSE <FS_FIELD>.

    AT END OF ROW.
      APPEND LT_UPLOAD.
      CLEAR LT_UPLOAD.
    ENDAT.
  ENDLOOP.


  CLEAR GV_CHK.

  LOOP AT LT_UPLOAD.

    REPLACE ALL OCCURRENCES OF '.'  IN  : LT_UPLOAD-BLDAT WITH SPACE,
                                          LT_UPLOAD-BLETD WITH SPACE,
                                          LT_UPLOAD-BLETA WITH SPACE.

    REPLACE ALL OCCURRENCES OF '-'  IN  : LT_UPLOAD-BLDAT WITH SPACE,
                                          LT_UPLOAD-BLETD WITH SPACE,
                                          LT_UPLOAD-BLETA WITH SPACE.

    CONDENSE : LT_UPLOAD-BLDAT  NO-GAPS,
               LT_UPLOAD-BLETD  NO-GAPS,
               LT_UPLOAD-BLETA  NO-GAPS,
               LT_UPLOAD-LIFNR  NO-GAPS,
               LT_UPLOAD-FWDCD  NO-GAPS.



    MOVE-CORRESPONDING LT_UPLOAD TO GT_LIST.



    IF GT_LIST-LIFNR IS INITIAL.
      MESSAGE S001 WITH '업체코드는 필수 입력입니다. '.
      GV_CHK = C_X.
    ELSE.
      PERFORM CONVERSION_EXIT_ALPHA_INPUT USING GT_LIST-LIFNR .

      SELECT SINGLE * FROM LFA1 WHERE LIFNR EQ GT_LIST-LIFNR.
      IF SY-SUBRC NE 0.
        MESSAGE S002 WITH GT_LIST-LIFNR
                           '는 존재하지 않는 업체코드입니다.'.
        GV_CHK = C_X.
        EXIT.
      ENDIF.

      PERFORM CONVERSION_EXIT_ALPHA_INPUT USING GT_LIST-FWDCD.
      SELECT SINGLE * FROM LFA1 WHERE LIFNR EQ GT_LIST-FWDCD.
      IF SY-SUBRC NE 0.
        MESSAGE S002 WITH GT_LIST-FWDCD
                           '는 존재하지 않는 업체코드입니다.'.
        GV_CHK = C_X.
        EXIT.
      ENDIF.
    ENDIF.

    APPEND GT_LIST.
  ENDLOOP.

  CHECK GV_CHK IS INITIAL.

  IF GT_LIST[] IS NOT INITIAL.

    SELECT * INTO CORRESPONDING FIELDS OF TABLE LT_LFA1
      FROM LFA1 FOR ALL ENTRIES IN GT_LIST
     WHERE ( LIFNR EQ GT_LIST-LIFNR OR LIFNR EQ GT_LIST-FWDCD ).


    LOOP AT GT_LIST .
        READ TABLE LT_LFA1 WITH KEY LIFNR = GT_LIST-LIFNR.
        IF SY-SUBRC EQ 0.
           GT_LIST-NAME1 = LT_LFA1-NAME1.
        ENDIF.

        READ TABLE LT_LFA1 WITH KEY LIFNR = GT_LIST-FWDCD.
         IF SY-SUBRC EQ 0.
            GT_LIST-FWDTX = LT_LFA1-NAME1.
         ENDIF.

        MODIFY GT_LIST TRANSPORTING NAME1 FWDTX.
    ENDLOOP.

  ENDIF.


ENDFORM.                    " EXCEL_UPLOAD
*&---------------------------------------------------------------------*
*&      Form  display_status
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
*&      Form  EXCEL_FORMAT_DOWNLOAD
*&---------------------------------------------------------------------*
FORM EXCEL_FORMAT_DOWNLOAD .


  DATA: LV_FILENAME   TYPE STRING VALUE 'BL업로드양식.xlsx',
        LV_PATH       TYPE STRING,
        LV_PULLPATH   TYPE STRING,
        LV_FNAME      LIKE RLGRAP-FILENAME.

  DATA: LS_WWWDATATAB TYPE WWWDATATAB,
        LV_RTN_MSG    TYPE CHAR100.

  CLEAR : LV_PATH, LV_PULLPATH.

  CALL METHOD CL_GUI_FRONTEND_SERVICES=>FILE_SAVE_DIALOG
    EXPORTING
      WINDOW_TITLE        = '다운로드 경로 설정'
      DEFAULT_FILE_NAME   = LV_FILENAME
      INITIAL_DIRECTORY   = LV_PATH
      PROMPT_ON_OVERWRITE = 'X'
    CHANGING
      FILENAME            = LV_FILENAME
      PATH                = LV_PATH
      FULLPATH            = LV_PULLPATH.

  CHECK LV_PULLPATH IS NOT INITIAL.

  LV_FNAME = LV_PULLPATH.

  SELECT SINGLE *
    INTO CORRESPONDING FIELDS OF LS_WWWDATATAB
    FROM WWWDATA
   WHERE OBJID = 'ZTIR2000'.

  IF SY-SUBRC EQ 0.
    CALL FUNCTION 'DOWNLOAD_WEB_OBJECT'
      EXPORTING
        KEY         = LS_WWWDATATAB
        DESTINATION = LV_FNAME.

    IF SY-SUBRC EQ 0.
      MESSAGE S398(00) WITH '양식을 다운로드 하였습니다.'.
    ENDIF.
  ELSE.
    MESSAGE S398(00) WITH '등록된 양식이 없습니다.'
    DISPLAY LIKE 'E'.
  ENDIF.



ENDFORM.                    " EXCEL_FORMAT_DOWNLOAD

*&---------------------------------------------------------------------*
*&      Form  SET_SCREEN_OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SET_SCREEN_OUTPUT .

  LOOP AT SCREEN.
    IF R_UPD IS NOT INITIAL.
      IF SCREEN-GROUP1 EQ 'DSP'.
        SCREEN-INPUT = 0.
        SCREEN-INVISIBLE = 1.
        MODIFY SCREEN.
      ENDIF.

    ELSE.
      IF SCREEN-GROUP1 EQ 'UPD'.
        SCREEN-INPUT = 0.
        SCREEN-INVISIBLE = 1.
        MODIFY SCREEN.
      ENDIF.
    ENDIF.


  ENDLOOP.

ENDFORM.                    " SET_SCREEN_OUTPUT
*&---------------------------------------------------------------------*
*&      Form  GET_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_DATA .

  DATA : LT_LFA1 LIKE TABLE OF LFA1 WITH HEADER LINE.

  SELECT * INTO CORRESPONDING FIELDS OF TABLE GT_LIST
    FROM ZTITBLH
    WHERE LIFNR IN  S_LIFNR
     AND BLDAT  IN  S_BLDAT .


  IF GT_LIST[] IS NOT INITIAL.

    SELECT * INTO CORRESPONDING FIELDS OF TABLE LT_LFA1
      FROM LFA1 FOR ALL ENTRIES IN GT_LIST
     WHERE ( LIFNR EQ GT_LIST-LIFNR OR LIFNR EQ GT_LIST-FWDCD ).


    LOOP AT GT_LIST .
        READ TABLE LT_LFA1 WITH KEY LIFNR = GT_LIST-LIFNR.
        IF SY-SUBRC EQ 0.
           GT_LIST-NAME1 = LT_LFA1-NAME1.
        ENDIF.

        READ TABLE LT_LFA1 WITH KEY LIFNR = GT_LIST-FWDCD.
         IF SY-SUBRC EQ 0.
            GT_LIST-FWDTX = LT_LFA1-NAME1.
         ENDIF.

        MODIFY GT_LIST TRANSPORTING NAME1 FWDTX.
    ENDLOOP.

  ENDIF.
ENDFORM.                    " GET_DATA

*&---------------------------------------------------------------------*
*&      Form  GRID_CHECK_CHANGED_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GS_ALV_GRID99  text
*----------------------------------------------------------------------*
FORM GRID_CHECK_CHANGED_DATA  USING PV_GRID  TYPE REF TO CL_GUI_ALV_GRID
.

  DATA : LV_VALID.

*  CALL FUNCTION 'SAPGUI_SET_FUNCTIONCODE'
*    EXPORTING
*      FUNCTIONCODE           = 'ENTER'
*    EXCEPTIONS
*      FUNCTION_NOT_SUPPORTED = 1
*      OTHERS                 = 2.

  "ALV최신화
  CALL METHOD PV_GRID->CHECK_CHANGED_DATA
    IMPORTING
      E_VALID = LV_VALID.

ENDFORM.                    "GRID_CHECK_CHANGED_DATA
