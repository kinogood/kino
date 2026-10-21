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
      I_READY_FOR_INPUT = 0.

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

  PERFORM SORT_FIELD TABLES GT_SORT USING :
    1  'ICCNO'         'X' ' ' 'X'.
*    2  'CDRDT'         'X' ' ' 'X'.
*    3  'ICCIT'         'X' ' ' 'X'.
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
*  GS_LAYOUT-INFO_FNAME = 'INFO'.       " ROW COLOR.
*  GS_LAYOUT-CTAB_FNAME = 'COLINFO'.    " COLUMN COLOR.
*  GS_LAYOUT-STYLEFNAME = 'STYLE'.
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
         LV_COL_CNT3 TYPE SY-TABIX.
  CLEAR: GT_FIELDCAT, GT_FIELDCAT[], GT_FIELD, GT_FIELD[].

* 선언된 인터럴 테이블 값을 가지고 옴
  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      I_PROGRAM_NAME     = SY-REPID
      I_INTERNAL_TABNAME = 'GT_TEMP'
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
      IT_DATA         = GT_TEMP
    EXCEPTIONS
      IT_DATA_MISSING = 1
      OTHERS          = 2.


  LOOP AT GT_FIELDCAT.
    CLEAR GT_FIELDCAT-KEY.
    CASE GT_FIELDCAT-FIELDNAME.
        GT_FIELDCAT-COL_OPT = C_X.

      WHEN 'ICCIT'.
        GT_FIELDCAT-COLTEXT = '품목'.

      WHEN 'ICCSQ'.
        GT_FIELDCAT-COLTEXT = '통관차수'.

      WHEN 'NAME1'.
        GT_FIELDCAT-COLTEXT = '해외공급자상호'.

      WHEN 'MAKTX'.
        GT_FIELDCAT-COLTEXT = '거래품명'.

      WHEN 'KEY'.
        GT_FIELDCAT-COLTEXT = 'KEY(수입신고번호/자재번호)'.

     WHEN 'CDRDT_T'.
        GT_FIELDCAT-COLTEXT = '신고수리일'.

      WHEN 'CDCNO'.
        GT_FIELDCAT-COLTEXT = '수입신고번호'.
        GT_FIELDCAT-HOTSPOT = C_X.

      WHEN 'RQMNG'.
        GT_FIELDCAT-COLTEXT = '개설수량'.

      WHEN 'MENGE'.
        GT_FIELDCAT-COLTEXT = '발주수량'.

      WHEN 'MENGE_GR'.
        GT_FIELDCAT-COLTEXT = '입고수량(누적)'.

      WHEN 'LIFNR2'.
        GT_FIELDCAT-COLTEXT = '수신공급업체'.

      WHEN 'NAME2'.
        GT_FIELDCAT-COLTEXT = '대금수취인'.


      WHEN 'VTEXT'.
        GT_FIELDCAT-COLTEXT = '제품군명'.


      WHEN 'REFWR'.
        GT_FIELDCAT-COLTEXT = '외화송장금액'.


      WHEN 'OPAMT' OR 'OPAMT_N'.
        IF GT_FIELDCAT-FIELDNAME EQ 'OPAMT_N'.
          GT_FIELDCAT-COLTEXT = '개설금액(건별)'.
        ENDIF.
        GT_FIELDCAT-CFIELDNAME    = 'WAERS2'.

      WHEN 'NETPR'.
        GT_FIELDCAT-CFIELDNAME    = 'WAERS'.

      WHEN 'CDUTX' OR 'CADTX' OR 'CLTTX'.
        GT_FIELDCAT-CFIELDNAME    = 'CCUAKC'.

      WHEN 'EBELN' OR 'EBELP' OR 'ICCNO' OR 'ICCSQ' OR
           'REQNO' OR 'LIFNR' OR 'IBLNO' OR 'CDCNO' .
        GT_FIELDCAT-HOTSPOT = C_X.

      WHEN 'CDRDT' OR 'NAMET' OR 'STATE' .
        GT_FIELDCAT-TECH = C_X.

      WHEN 'CPYRT'.
        GT_FIELDCAT-COLTEXT = '통관환율'.


      WHEN 'CCUAK'.
        GT_FIELDCAT-COLTEXT = '원화총과세가격'.
        GT_FIELDCAT-CFIELDNAME    = 'CCUAKC'.


      WHEN 'REFWK'.
        GT_FIELDCAT-COLTEXT         = '원화송장금액'.
        GT_FIELDCAT-CFIELDNAME    = 'CPYATC'.


      WHEN 'CSSID'.
        GT_FIELDCAT-COLTEXT = '란세번부호'.

      WHEN 'CSSEQ'.
        GT_FIELDCAT-COLTEXT = '란번호'.


      WHEN 'CMSEQ'.
        GT_FIELDCAT-COLTEXT = '행번호'.

      WHEN 'CSDRT'.
        GT_FIELDCAT-COLTEXT = '란관세율'.


      WHEN 'CSDUYT'.
        GT_FIELDCAT-COLTEXT = '란관세구분'.

    ENDCASE.


    IF GT_FIELDCAT-COLTEXT IS NOT INITIAL.
      GT_FIELDCAT-SCRTEXT_L = GT_FIELDCAT-SCRTEXT_M =
      GT_FIELDCAT-SCRTEXT_S = GT_FIELDCAT-COLTEXT .
    ENDIF.

    MODIFY GT_FIELDCAT.
  ENDLOOP.

  LOOP AT GT_FIELDCAT.
    IF SY-TABIX < 9.
      GT_FIELDCAT-EMPHASIZE = C_COL_BLUE1.
    ELSEIF SY-TABIX < 27.
      GT_FIELDCAT-EMPHASIZE = C_COL_GREEN.
    ELSE.
      GT_FIELDCAT-EMPHASIZE = C_COL_YELLOW.
    ENDIF.
    MODIFY GT_FIELDCAT.
  ENDLOOP.


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
      IT_OUTTAB            = GT_TEMP[]
      IT_FIELDCATALOG      = GT_FIELDCAT[]
      IT_SORT              = GT_SORT[].

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
*  SET HANDLER
*     GS_EVENT_RECEIVER->HANDLE_DOUBLE_CLICK FOR GS_ALV_GRID.

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
*&      Form  GET_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_DATA .

  CLEAR : GT_TEMP, GT_TEMP[],
          GT_LIST, GT_LIST[].


  IF S_OPNNO[] IS INITIAL AND S_REQNO[] IS INITIAL.
    PERFORM GET_DATA_CC. "통관부터 추출
  ELSE.
    PERFORM GET_DATA_REQ. "수입개설부터 추출
  ENDIF.

"[CHM2302-00202]  수입신고 란.행 데이터 추출
  IF GT_TEMP[] IS NOT INITIAL.
    PERFORM GET_DATA_CC12.
  ENDIF.

  IF S_WERKS[] IS NOT INITIAL.
    DELETE GT_TEMP WHERE WERKS NOT IN S_WERKS[].
  ENDIF.

  CHECK GT_TEMP[] IS NOT INITIAL.


*- 기타데이터
  SELECT * INTO CORRESPONDING FIELDS OF TABLE GT_LFA1
     FROM  LFA1 FOR ALL ENTRIES IN GT_TEMP
    WHERE LIFNR EQ GT_TEMP-LIFNR.


  SELECT * INTO CORRESPONDING FIELDS OF TABLE GT_MAKT
     FROM  MAKT FOR ALL ENTRIES IN GT_TEMP
    WHERE  MATNR EQ GT_TEMP-MATNR
      AND  SPRAS EQ SY-LANGU.


   SELECT * INTO CORRESPONDING FIELDS OF TABLE GT_MARA
     FROM  MARA LEFT OUTER JOIN TSPAT
                             ON MARA~SPART  EQ TSPAT~SPART
                            AND TSPAT~SPRAS EQ SY-LANGU
     FOR ALL ENTRIES IN GT_TEMP
    WHERE  MATNR EQ GT_TEMP-MATNR .



  SORT GT_LFA1 BY LIFNR .
  SORT GT_MAKT BY MATNR.
  SORT GT_MARA BY MATNR.


  IF GT_RQS[] IS NOT INITIAL.
    SELECT * APPENDING CORRESPONDING FIELDS OF TABLE GT_LFA1
      FROM  LFA1 FOR ALL ENTRIES IN GT_RQS
     WHERE LIFNR EQ GT_RQS-LIFNR.
  ENDIF.


*- 입고 수량 추출
  LOOP AT GT_TEMP WHERE EBELN IS NOT INITIAL.
    MOVE-CORRESPONDING GT_TEMP TO GT_EKPO.
    APPEND GT_EKPO.
  ENDLOOP.
  SORT GT_EKPO BY EBELN EBELP.
  DELETE ADJACENT DUPLICATES FROM GT_EKPO COMPARING EBELN EBELP.

  IF GT_EKPO[] IS NOT INITIAL.

    SELECT * INTO CORRESPONDING FIELDS OF TABLE GT_EKBE
      FROM EKBE FOR ALL ENTRIES IN GT_EKPO
     WHERE EBELN  EQ GT_EKPO-EBELN
      AND  EBELP  EQ GT_EKPO-EBELP
      AND  VGABE  EQ '1'
      AND  BWART IN ('101', '102')  .

    LOOP AT GT_EKBE.
      MOVE-CORRESPONDING GT_EKBE TO GT_EKPO_GR.
      IF GT_EKBE-SHKZG EQ 'H'.
        GT_EKPO_GR-MENGE =  GT_EKPO_GR-MENGE * -1.
      ENDIF.
      COLLECT GT_EKPO_GR.
    ENDLOOP.

    SORT GT_EKPO_GR BY EBELN EBELP.
  ENDIF.


ENDFORM.                    "GET_DATA
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
    MESSAGE S001 WITH '자료가 선택되지 않았습니다.' .
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
*
** data 핸들 변경하는 부분
*  IF P_SENDER = GS_ALV_GRID99.
*     LOOP AT PR_DATA_CHANGED->MT_GOOD_CELLS INTO LS_GOOD.
*        CASE LS_GOOD-FIELDNAME.
*          WHEN 'LIFNR'.
*            SELECT SINGLE NAME1 INTO LV_TEXT
*                     FROM LFA1 WHERE LIFNR EQ LS_GOOD-VALUE.
*            CALL METHOD PR_DATA_CHANGED->MODIFY_CELL
*                  EXPORTING
*                    I_ROW_ID    = LS_GOOD-ROW_ID
*                    I_FIELDNAME = 'NAME1'
*                    I_VALUE     =  LV_TEXT.
*
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
*         ENDCASE.
*     ENDLOOP.
*  ENDIF.


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

  CASE P_SENDER.
      "상단리스트(헤더)
    WHEN GS_ALV_GRID.

      READ TABLE GT_TEMP INDEX P_ROW.
      CHECK SY-SUBRC = 0.

      CASE P_COLUMN.
        WHEN 'EBELN' OR  'EBELP' .
          PERFORM  DISPLAY_PURCHASE_ORDER(ZTIR0000)
                                       USING GT_TEMP-EBELN
                                             GT_TEMP-EBELP.

        WHEN 'REQNO'.
          PERFORM  DISPLAY_IMPORT_DOCUMENT(ZTIR0000)
                                          USING GT_TEMP-REQNO
                                                SPACE
                                                SPACE.
        WHEN 'LIFNR'.
          PERFORM DISPLAY_VENDOR_MASTER(ZTIR0000)
                                          USING GT_TEMP-LIFNR
                                                GT_TEMP-EKORG.
        WHEN 'IBLNO'.
          PERFORM  DISPLAY_BL_DOCUMENT(ZTIR0000)
                                          USING GT_TEMP-IBLNO
                                                '00000'.
        WHEN 'ICCNO' OR 'ICCSQ' OR 'CDCNO'.
          PERFORM  DISPLAY_CC_DOCUMENT(ZTIR0000)
                                          USING GT_TEMP-ICCNO
                                                GT_TEMP-ICCSQ.

      ENDCASE.
  ENDCASE.

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
**&---------------------------------------------------------------------
**
**&      Form  CHECK_MESSAGE
**&---------------------------------------------------------------------
**
**       text
**----------------------------------------------------------------------
**
*FORM CHECK_MESSAGE  USING  P_TYPE .
*
*  DATA : LV_TITLE(20), LV_MESSAGE(100).
*
*  CASE P_TYPE.
*    WHEN 'CREATE'.
*      LV_TITLE =   '전표생성 메시지'.
*
*      LV_MESSAGE   =  '구매오더[' && GT_LIST-EBELN && ']의 분리' &&
*                      '전표를 생성 하시겠습니까?'.
*
*    WHEN 'CANCEL'.
*      LV_TITLE =   '전표취소 메시지'.
*      LV_MESSAGE   =  '구매오더[' && GT_LIST-EBELN && ']의 분리' &&
*                      '전표를 취소 하시겠습니까?'.
*
*   ENDCASE.
*
*   PERFORM POPUP_CONFIRM USING LV_TITLE
*                               LV_MESSAGE
*                              CHANGING GV_ANSWER.
*
*   CHECK  GV_ANSWER EQ '1'.
*
* "작업중 메세지
*   PERFORM PROGRESS_INDICATOR USING '처리중입니다.'
*                                    '1'.
*
*
*ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  SET_DATE_INIT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SET_DATE_INIT .

  S_CDRDT-LOW  = SY-DATUM - 100.
  S_CDRDT-HIGH = SY-DATUM.
  APPEND S_CDRDT.

ENDFORM.                    " SET_DATE_INIT

*&---------------------------------------------------------------------*
*&      Form  CHECK_SELECTED_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CHECK_SELECTED_DATA .

  CLEAR GV_CHK .

  IF GT_LIST[] IS INITIAL.
    GV_CHK  = C_X.
    MESSAGE S001 WITH '미처리내역이 없습니다' .
    EXIT.
  ENDIF.

  PERFORM GET_SELECT_ROWS TABLES   GT_ROWS
                          USING    GS_ALV_GRID
                          CHANGING GV_CHK.


  CHECK GV_CHK IS INITIAL .

  LOOP AT GT_ROWS .
    READ TABLE GT_LIST INDEX GT_ROWS-INDEX.
  ENDLOOP.





ENDFORM.                    " CHECK_SELECTED_DATA
*&---------------------------------------------------------------------*
*&      Form  SET_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SET_DATA .

*  CLEAR : GT_LIST ,  GT_LIST[].


  LOOP AT GT_TEMP.
    READ TABLE GT_LFA1 WITH KEY LIFNR = GT_TEMP-LIFNR
                                   BINARY SEARCH.
    IF SY-SUBRC EQ 0.
      GT_TEMP-NAME1  = GT_LFA1-NAME1.
    ENDIF.

    READ TABLE GT_MAKT WITH KEY MATNR = GT_TEMP-MATNR
                                   BINARY SEARCH.
    IF SY-SUBRC EQ 0.
      GT_TEMP-MAKTX  = GT_MAKT-MAKTX.
    ENDIF.


    "제품군
    READ TABLE GT_MARA WITH KEY MATNR = GT_TEMP-MATNR
                                   BINARY SEARCH.
    IF SY-SUBRC EQ 0.
      GT_TEMP-SPART  = GT_MARA-SPART.
      GT_TEMP-VTEXT  = GT_MARA-VTEXT.
    ENDIF.


    IF GT_TEMP-REQNO IS NOT INITIAL."사전개설(BL관리번호없음)
      READ TABLE GT_RQS_R  WITH KEY REQNO  = GT_TEMP-REQNO
                                    EBELN  = GT_TEMP-EBELN
                                    EBELP  = GT_TEMP-EBELP
                                    BINARY SEARCH.
      IF SY-SUBRC EQ 0.
        GT_TEMP-REQNO   = GT_RQS_R-REQNO.
        GT_TEMP-REQDT   = GT_RQS_R-REQDT .
        GT_TEMP-OPNNO   = GT_RQS_R-OPNNO .
        GT_TEMP-OPAMT   = GT_RQS_R-OPAMT .
        GT_TEMP-WAERS2  = GT_RQS_R-WAERS .
        GT_TEMP-LIFNR   = GT_RQS_R-LIFNR .
        GT_TEMP-RQMNG   = GT_RQS_R-RQMNG.

        GT_TEMP-OPAMT_N =  GT_TEMP-NETPR * GT_TEMP-RQMNG .

        GT_TEMP-LIFNR2  = GT_RQS_R-LIFNR.
        GT_TEMP-OPNDT   = GT_RQS_R-OPNDT.
        GT_TEMP-USAMT   = GT_RQS_R-USAMT.
      ENDIF.
    ELSE. "사후개설
      READ TABLE GT_RQS  WITH KEY EBELN  = GT_TEMP-EBELN
                                  EBELP  = GT_TEMP-EBELP
                                  IBLNO  = GT_TEMP-IBLNO
                                  BINARY SEARCH.
      IF SY-SUBRC EQ 0.
        GT_TEMP-REQNO   = GT_RQS-REQNO.
        GT_TEMP-REQDT   = GT_RQS-REQDT .
        GT_TEMP-OPNNO   = GT_RQS-OPNNO .
        GT_TEMP-OPAMT   = GT_RQS-OPAMT .
        GT_TEMP-WAERS2  = GT_RQS-WAERS .
        GT_TEMP-LIFNR   = GT_RQS-LIFNR .
        GT_TEMP-RQMNG   = GT_RQS-RQMNG.

        GT_TEMP-OPAMT_N =   GT_TEMP-NETPR * GT_TEMP-RQMNG .

        GT_TEMP-LIFNR2  = GT_RQS-LIFNR.
        GT_TEMP-OPNDT   = GT_RQS-OPNDT.
        GT_TEMP-USAMT   = GT_RQS-USAMT.
      ENDIF.
    ENDIF.


    READ TABLE GT_LFA1 WITH KEY LIFNR = GT_TEMP-LIFNR2
                                   BINARY SEARCH.
    IF SY-SUBRC EQ 0.
      GT_TEMP-NAME2  = GT_LFA1-NAME1.
    ENDIF.


    CALL FUNCTION 'CONVERSION_EXIT_MATN1_OUTPUT'
      EXPORTING
        INPUT  = GT_TEMP-MATNR
      IMPORTING
        OUTPUT = GT_TEMP-MATNR.

    "입고누적수량
    READ TABLE GT_EKPO_GR WITH KEY EBELN = GT_TEMP-EBELN
                                   EBELP = GT_TEMP-EBELP
                                   BINARY SEARCH.
    IF SY-SUBRC EQ 0.
      GT_TEMP-MENGE_GR = GT_EKPO_GR-MENGE.
    ENDIF.



   "신고자(관세사) 상호가 비었을 경우 요청한 관세사 상호로 대체
   IF GT_TEMP-CDAPN IS INITIAL.
     CONCATENATE '[의뢰]' GT_TEMP-NAMET INTO GT_TEMP-CDAPN.
   ENDIF.


   "수리일이 비었을 경우 생성일로
   IF GT_TEMP-CDRDT IS NOT INITIAL.
     WRITE GT_TEMP-CDRDT TO GT_TEMP-CDRDT_T
                         USING EDIT MASK '____.__.__'.
   ELSE.

     WRITE GT_TEMP-CDAT TO GT_TEMP-CDRDT_T
                         USING EDIT MASK '____.__.__'.

    CONCATENATE '[의뢰]' GT_TEMP-CDRDT_T INTO  GT_TEMP-CDRDT_T.
   ENDIF.


*    PERFORM CURRENCY_EXTERNAL : USING  GT_TEMP-WAERS2
*                                     GT_TEMP-OPAMT
*                              CHANGING GT_TEMP-OPAMT,
*
*                                USING  GT_TEMP-WAERS2
*                                     GT_TEMP-OPAMT_N
*                              CHANGING GT_TEMP-OPAMT_N  ,
*
*                                USING  GT_TEMP-WAERS
*                                     GT_TEMP-NETPR
*                              CHANGING GT_TEMP-NETPR,
*
*                                USING  GT_TEMP-CCUAKC
*                                     GT_TEMP-CDUTX
*                              CHANGING GT_TEMP-CDUTX ,
*
*                                USING  GT_TEMP-CCUAKC
*                                     GT_TEMP-CADTX
*                              CHANGING GT_TEMP-CADTX ,
*
*                                USING  GT_TEMP-CCUAKC
*                                     GT_TEMP-CLTTX
*                              CHANGING GT_TEMP-CLTTX .


    "PER단가반영
    GT_TEMP-OPAMT_N  = GT_TEMP-OPAMT_N  / GT_TEMP-PEINH .

    CONCATENATE GT_TEMP-CDCNO '/' GT_TEMP-MATNR INTO GT_TEMP-KEY .


    "[CHM2302-00202] 수인신고 세번부호, 란. 행번호
    READ TABLE GT_CC12 WITH KEY ICCNO = GT_TEMP-ICCNO
                                ICCSQ = GT_TEMP-ICCSQ
                                CMRS1 = GT_TEMP-MATNR
                                BINARY SEARCH.
    IF SY-SUBRC EQ 0 .
       GT_TEMP-CSSEQ   = GT_CC12-CSSEQ.
       GT_TEMP-CMSEQ   = GT_CC12-CMSEQ.
       GT_TEMP-CSSID   = GT_CC12-CSSID. "세번부호
       GT_TEMP-CSDRT   = GT_CC12-CSDRT.  "관세율
       GT_TEMP-CSDUYT  = GT_CC12-CSDUYT. "관세구분
    ENDIF.

    MODIFY GT_TEMP  .
  ENDLOOP.


  IF S_SPART[] IS NOT INITIAL.
     DELETE GT_TEMP WHERE SPART NOT IN S_SPART[].
  ENDIF.

  SORT GT_TEMP BY CDRDT ICCNO ICCIT.


ENDFORM.                    " SET_DATA
*&---------------------------------------------------------------------*
*&      Form  CURRENCY_EXTERNAL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM CURRENCY_EXTERNAL  USING    P_WAERS
                                 P_AMT
                        CHANGING P_EXT_AMT.

  DATA : LV_AMT LIKE BAPICURR-BAPICURR.
  CALL FUNCTION 'BAPI_CURRENCY_CONV_TO_EXTERNAL'
    EXPORTING
      CURRENCY        = P_WAERS
      AMOUNT_INTERNAL = P_AMT
    IMPORTING
      AMOUNT_EXTERNAL = LV_AMT.

  P_EXT_AMT = LV_AMT .


ENDFORM.                    " CURRENCY_EXTERNAL


*&---------------------------------------------------------------------*
*&      Form  SET_SCREEN_OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SET_SCREEN_OUTPUT .
  LOOP AT SCREEN .

    MODIFY SCREEN.
  ENDLOOP.
ENDFORM.                    " SET_SCREEN_OUTPUT

*&---------------------------------------------------------------------*
*&      Form  alv_variant_f4
*&---------------------------------------------------------------------*
*  조회 레이아웃 설정
*----------------------------------------------------------------------*
*      <--P_PA_VARI  text
*----------------------------------------------------------------------*
FORM ALV_VARIANT_F4  CHANGING P_VARI.

  DATA LS_VARIANT TYPE DISVARIANT.

  LS_VARIANT  = GS_VARIANT.
  CLEAR LS_VARIANT-USERNAME.

  CALL FUNCTION 'LVC_VARIANT_F4'
    EXPORTING
      IS_VARIANT = GS_VARIANT
      I_SAVE     = GV_SAVE
    IMPORTING
      E_EXIT     = GV_EXIT
      ES_VARIANT = LS_VARIANT
    EXCEPTIONS
      NOT_FOUND  = 1
      OTHERS     = 2.

  IF SY-SUBRC NE 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ELSE.
    IF GV_EXIT NE C_X.
      GS_VARIANT-VARIANT = P_VARI = LS_VARIANT-VARIANT.
      CLEAR GS_VARIANT-USERNAME.
    ENDIF.
  ENDIF.

ENDFORM.                    " alv_variant_f4
*&---------------------------------------------------------------------*
*&      Form  GET_DATA_CC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_DATA_CC .

*- 통관데이터
  SELECT A~ICCNO  A~CDCNO A~CDRDT A~CDUTX  A~CPYME
         A~CPYATC A~CSDRT A~CDAT A~CDAPN   A~STATE
         A~CDUTX A~CADTX A~CLTTX A~CCUAKC  A~CPYRT A~CCUAK
         A~CFRAT A~CIPAT  A~CPLAT A~CFEAT
         B~STAWN B~CCMNG B~MEINS B~ICCIT B~REQNO B~REQIT
         B~EBELN B~EBELP B~IBLNO B~REFWR
         C~BLNUM
         D~LIFNR D~EKORG D~WAERS D~BSART
         E~WERKS E~NETPR E~MATNR
         E~PEINH E~MENGE
         F~NAMET
    INTO CORRESPONDING FIELDS OF TABLE GT_TEMP
    FROM ZTITCCK AS A INNER JOIN ZTITCCP AS B
                             ON  A~ICCNO  EQ B~ICCNO
                            AND  A~ICCSQ  EQ B~ICCSQ
                LEFT OUTER JOIN ZTITBLK AS C
                             ON  B~IBLNO EQ C~IBLNO
                LEFT OUTER JOIN EKKO AS D
                             ON B~EBELN EQ D~EBELN
                LEFT OUTER JOIN EKPO AS E
                             ON B~EBELN EQ E~EBELN
                            AND B~EBELP EQ E~EBELP
                LEFT OUTER JOIN ZTSTIG3 AS F
                             ON A~STATE EQ F~EPART
                            AND F~BUKRS EQ S_BUKRS-LOW
   WHERE ( ( A~CDRDT IN S_CDRDT ) OR
            (  A~CDAT IN S_CDRDT  AND
            ( A~CDRDT EQ '00000000' OR A~CDRDT EQ SPACE  ) ) )

     AND A~BUKRS IN S_BUKRS
     AND A~ICCNO IN S_ICCNO
     AND A~CDCNO IN S_CDCNO
     AND B~EBELN IN S_EBELN.


  CHECK GT_TEMP[]  IS NOT INITIAL.


  SORT GT_TEMP BY ICCNO ICCIT ICCSQ DESCENDING.
  DELETE ADJACENT DUPLICATES FROM GT_TEMP
          COMPARING ICCNO ICCIT .


  LOOP AT GT_TEMP.
     GT_TEMP-REFWK = GT_TEMP-REFWR * GT_TEMP-CPYRT .

    IF GT_TEMP-REQNO IS NOT INITIAL.
      MOVE-CORRESPONDING GT_TEMP TO GT_CC_1.
      APPEND GT_CC_1.
    ELSE.
      MOVE-CORRESPONDING GT_TEMP TO GT_CC_2.
      APPEND GT_CC_2.
    ENDIF.

    MODIFY GT_TEMP TRANSPORTING REFWK .

  ENDLOOP.

*- 수입개설데이터
  IF GT_CC_1[] IS NOT INITIAL.
    SELECT A~REQNO A~AMDSQ  A~REQDT  A~OPNNO A~OPAMT A~WAERS
           A~USAMT A~OPNDT
           B~LIFNR
           C~EBELN C~EBELP C~IBLNO C~RQMNG
      INTO CORRESPONDING FIELDS OF TABLE GT_RQS
      FROM ZTITRQS AS A INNER JOIN ZTITRQK AS B
                               ON A~REQNO EQ B~REQNO
                        INNER JOIN ZTITRQP AS C
                               ON B~REQNO EQ C~REQNO
      FOR ALL ENTRIES IN GT_CC_1
     WHERE A~REQNO  EQ GT_CC_1-REQNO.

  ENDIF.



  IF GT_CC_2[] IS NOT INITIAL.
    SELECT A~REQNO A~AMDSQ  A~REQDT  A~OPNNO A~OPAMT A~WAERS
           A~USAMT A~OPNDT
           B~LIFNR
           C~EBELN C~EBELP C~IBLNO C~RQMNG
      APPENDING CORRESPONDING FIELDS OF TABLE GT_RQS
      FROM ZTITRQS AS A INNER JOIN ZTITRQK AS B
                               ON A~REQNO EQ B~REQNO
                         INNER JOIN ZTITRQP AS C
                                ON B~REQNO EQ C~REQNO
      FOR ALL ENTRIES IN GT_CC_2
     WHERE C~EBELN  EQ GT_CC_2-EBELN
       AND C~EBELP  EQ GT_CC_2-EBELP.
  ENDIF.


  SORT GT_RQS BY EBELN EBELP IBLNO REQNO AMDSQ DESCENDING.
  DELETE ADJACENT DUPLICATES FROM GT_RQS
         COMPARING EBELN EBELP IBLNO REQNO .
  MOVE GT_RQS[] TO GT_RQS_R[].
  SORT GT_RQS_R BY REQNO EBELN EBELP. "IBLNO가 없는 경우



ENDFORM.                    " GET_DATA_CC
*&---------------------------------------------------------------------*
*&      Form  GET_DATA_REQ
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_DATA_REQ .


  SELECT A~REQNO A~AMDSQ  A~REQDT  A~OPNNO A~OPAMT A~WAERS
         A~USAMT A~OPNDT
         B~LIFNR
         C~EBELN C~EBELP C~IBLNO C~RQMNG
    INTO CORRESPONDING FIELDS OF TABLE GT_RQS
    FROM ZTITRQS AS A INNER JOIN ZTITRQK AS B
                             ON A~REQNO EQ B~REQNO
                      INNER JOIN ZTITRQP AS C
                             ON B~REQNO EQ C~REQNO
   WHERE  A~REQNO IN S_REQNO
     AND  A~OPNNO IN S_OPNNO.


  CHECK GT_RQS[] IS NOT INITIAL.

  SORT GT_RQS BY EBELN EBELP IBLNO REQNO AMDSQ DESCENDING.
  DELETE ADJACENT DUPLICATES FROM GT_RQS
         COMPARING EBELN EBELP IBLNO REQNO .
  MOVE GT_RQS[] TO GT_RQS_R[].
  SORT GT_RQS_R BY REQNO EBELN EBELP. "IBLNO가 없는 경우


*- 통관데이터
  SELECT A~ICCNO  A~CDCNO A~CDRDT A~CDUTX  A~CPYME
         A~CPYATC A~CSDRT A~CDAT  A~CDAPN  A~STATE
         A~CDUTX  A~CADTX A~CLTTX A~CCUAK  A~CPYRT
         A~CFRAT A~CIPAT  A~CPLAT A~CFEAT
         B~STAWN B~CCMNG B~MEINS B~ICCIT B~REQNO B~REQIT
         B~EBELN B~EBELP B~IBLNO B~REFWR
         C~BLNUM
         D~LIFNR D~EKORG D~WAERS D~BSART
         E~WERKS E~NETPR E~MATNR
         E~PEINH E~MENGE
         F~NAMET
    INTO CORRESPONDING FIELDS OF TABLE GT_TEMP
    FROM ZTITCCK AS A INNER JOIN ZTITCCP AS B
                             ON  A~ICCNO  EQ B~ICCNO
                            AND  A~ICCSQ  EQ B~ICCSQ
                LEFT OUTER JOIN ZTITBLK AS C
                             ON  B~IBLNO EQ C~IBLNO
                LEFT OUTER JOIN EKKO AS D
                             ON B~EBELN EQ D~EBELN
                LEFT OUTER JOIN EKPO AS E
                             ON B~EBELN EQ E~EBELN
                            AND B~EBELP EQ E~EBELP
                LEFT OUTER JOIN ZTSTIG3 AS F
                             ON A~STATE EQ F~EPART
                            AND F~BUKRS EQ S_BUKRS-LOW

    FOR ALL ENTRIES IN GT_RQS
   WHERE ( ( A~CDRDT IN S_CDRDT ) OR
           (  A~CDAT IN S_CDRDT  AND
           ( A~CDRDT EQ '00000000' OR A~CDRDT EQ SPACE  ) ) )
     AND ( B~EBELN EQ GT_RQS-EBELN AND B~EBELP EQ GT_RQS-EBELP )
     AND A~BUKRS IN S_BUKRS
     AND A~ICCNO IN S_ICCNO
     AND A~CDCNO IN S_CDCNO
     AND B~EBELN IN S_EBELN.


  SORT GT_TEMP BY ICCNO ICCIT ICCSQ DESCENDING.
  DELETE ADJACENT DUPLICATES FROM GT_TEMP
          COMPARING ICCNO ICCIT .


  LOOP AT GT_TEMP .
    IF GT_TEMP-REQNO IS NOT INITIAL."사전개설(BL관리번호없음)
      READ TABLE GT_RQS_R  WITH KEY REQNO  = GT_TEMP-REQNO
                                    EBELN  = GT_TEMP-EBELN
                                    EBELP  = GT_TEMP-EBELP
                                    BINARY SEARCH.
      IF SY-SUBRC EQ 0.
        GT_TEMP-REQNO   = GT_RQS_R-REQNO.
        GT_TEMP-REQDT   = GT_RQS_R-REQDT .
        GT_TEMP-OPNNO   = GT_RQS_R-OPNNO .
        GT_TEMP-OPAMT   = GT_RQS_R-OPAMT .
        GT_TEMP-WAERS2  = GT_RQS_R-WAERS .
        GT_TEMP-LIFNR   = GT_RQS_R-LIFNR .
        GT_TEMP-RQMNG   = GT_RQS_R-RQMNG.

        GT_TEMP-OPAMT_N =  GT_TEMP-NETPR * GT_TEMP-RQMNG .

        GT_TEMP-LIFNR2  = GT_RQS_R-LIFNR.
        GT_TEMP-OPNDT   = GT_RQS_R-OPNDT.
        GT_TEMP-USAMT   = GT_RQS_R-USAMT.
      ELSE.
        DELETE GT_TEMP.
      ENDIF.
    ELSE. "사후개설
      READ TABLE GT_RQS  WITH KEY EBELN  = GT_TEMP-EBELN
                                  EBELP  = GT_TEMP-EBELP
                                  IBLNO  = GT_TEMP-IBLNO
                                  BINARY SEARCH.
      IF SY-SUBRC EQ 0.
        GT_TEMP-REQNO   = GT_RQS-REQNO.
        GT_TEMP-REQDT   = GT_RQS-REQDT .
        GT_TEMP-OPNNO   = GT_RQS-OPNNO .
        GT_TEMP-OPAMT   = GT_RQS-OPAMT .
        GT_TEMP-WAERS2  = GT_RQS-WAERS .
        GT_TEMP-LIFNR   = GT_RQS-LIFNR .
        GT_TEMP-RQMNG   = GT_RQS-RQMNG.

        GT_TEMP-OPAMT_N =   GT_TEMP-NETPR * GT_TEMP-RQMNG .

        GT_TEMP-LIFNR2  = GT_RQS-LIFNR.
        GT_TEMP-OPNDT   = GT_RQS-OPNDT.
        GT_TEMP-USAMT   = GT_RQS-USAMT.
      ELSE.
        DELETE GT_TEMP.
      ENDIF.
    ENDIF.


     GT_TEMP-REFWK = GT_TEMP-REFWR * GT_TEMP-CPYRT .
     MODIFY GT_TEMP TRANSPORTING REFWK .
  ENDLOOP.


ENDFORM.                    " GET_DATA_REQ
*&---------------------------------------------------------------------*
*&      Form  HANDLE_HOTSPOT_CLICK
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_SENDER  text
*      -->P_E_ROW_ID  text
*      -->P_E_COLUMN_ID  text
*----------------------------------------------------------------------*
FORM HANDLE_HOTSPOT_CLICK  USING    P_SENDER
                                    P_ROW
                                    P_COLUMN.


 CHECK NOT P_ROW IS INITIAL.

  CASE P_SENDER.
      "상단리스트(헤더)
    WHEN GS_ALV_GRID.

      READ TABLE GT_TEMP INDEX P_ROW.
      CHECK SY-SUBRC = 0.

      CASE P_COLUMN.
        WHEN 'EBELN' OR  'EBELP' .
          PERFORM  DISPLAY_PURCHASE_ORDER(ZTIR0000)
                                       USING GT_TEMP-EBELN
                                             GT_TEMP-EBELP.

        WHEN 'REQNO'.
          PERFORM  DISPLAY_IMPORT_DOCUMENT(ZTIR0000)
                                          USING GT_TEMP-REQNO
                                                SPACE
                                                SPACE.
        WHEN 'LIFNR'.
          PERFORM DISPLAY_VENDOR_MASTER(ZTIR0000)
                                          USING GT_TEMP-LIFNR
                                                GT_TEMP-EKORG.
        WHEN 'IBLNO'.
          PERFORM  DISPLAY_BL_DOCUMENT(ZTIR0000)
                                          USING GT_TEMP-IBLNO
                                                '00000'.
        WHEN 'ICCNO' OR 'ICCSQ' OR 'CDCNO'.
          PERFORM  DISPLAY_CC_DOCUMENT(ZTIR0000)
                                          USING GT_TEMP-ICCNO
                                                GT_TEMP-ICCSQ.

      ENDCASE.
  ENDCASE.


ENDFORM.                    " HANDLE_HOTSPOT_CLICK
*&---------------------------------------------------------------------*
*&      Form  GET_DATA_CC12
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_DATA_CC12 .

  DATA : LT_DD07T LIKE TABLE OF DD07T WITH HEADER LINE.


   SELECT * INTO CORRESPONDING FIELDS OF TABLE GT_CC12
     FROM  ZTITCC1 AS A INNER JOIN ZTITCC2 AS B
                           ON  A~ICCNO EQ B~ICCNO
                          AND  A~ICCSQ EQ B~ICCSQ
                          AND  A~CSSEQ EQ B~CSSEQ
     FOR ALL ENTRIES IN GT_TEMP
   WHERE B~ICCNO EQ GT_TEMP-ICCNO
     AND B~ICCSQ EQ GT_TEMP-ICCSQ .


    SELECT * INTO CORRESPONDING FIELDS OF TABLE LT_DD07T
      FROM DD07T
     WHERE DOMNAME EQ 'ZTICSDUY'
       AND DDLANGUAGE EQ '3'
  ORDER BY DOMVALUE_L.

   LOOP AT GT_CC12.
       READ TABLE LT_DD07T WITH KEY DOMVALUE_L = GT_CC12-CSDUY
                                                 BINARY SEARCH.

       IF SY-SUBRC EQ 0.
          GT_CC12-CSDUYT = LT_DD07T-DDTEXT.
       ENDIF.

       MODIFY GT_CC12 TRANSPORTING CSDUYT.

   ENDLOOP.

   SORT GT_CC12 BY ICCNO ICCSQ CMRS1.

ENDFORM.                    " GET_DATA_CC12
