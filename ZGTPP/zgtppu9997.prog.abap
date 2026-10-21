*&---------------------------------------------------------------------*
*& 모듈           : PP
*& 프로그램 ID : ZGTPPU9997
*& 프로그램 명 : [GT] 생산 업데이트 테이블
*& 개요   :
*& 생성일 : 2025.03.28
*& 생성자 : ZGSIPP01
*&---------------------------------------------------------------------*
*& 외부 호출 프로그램 개요   : N/A
*& 타 시스템 인터페이스 개요 : N/A
*&---------------------------------------------------------------------*
*& 프로그램 수정이력
*&---------------------------------------------------------------------*
*& 수정일  :
*& 수정자  :
*& 수정개요 :
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*

REPORT  ZGTPPU9997 MESSAGE-ID ZFI1 NO STANDARD PAGE HEADING
                                          LINE-SIZE  142.
INCLUDE ZGTPPU9997TOP.
INCLUDE ZGTPPU9997SEL.
INCLUDE ZGTPPU9997CLASS.


INITIALIZATION.

START-OF-SELECTION.

  CLEAR G_SUBRC.

  IF P_TABLE(1) NE 'Z'.
    MESSAGE S001 WITH 'CBO 테이블만 제어 가능합니다.'.
    G_SUBRC = 1.
  ENDIF.

  CHECK G_SUBRC IS INITIAL.


*유지보수 table 필드를 위한 Dynamic Selection Screen을 생성함
  CLEAR: G_SELOPT_BUKRS, G_SUBRC.
  PERFORM CREATE_DYNAMIC_SELSCREEN.

* 권한작업
*  PERFORM INIT_CHECK.

  CHECK G_SUBRC IS INITIAL.

* 입력받은 테이블 명으로 데이터를 구한다
  PERFORM READ_DATA.

*  check <dyn_table> is not initial.
  CALL SCREEN '0100'.


*----------------------------------------------------------------------*
END-OF-SELECTION.
*----------------------------------------------------------------------*



*&---------------------------------------------------------------------*
*&      Module  STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE STATUS_0100 OUTPUT.
  SET PF-STATUS '0100'.
*  set titlebar '0100' with p_table .
  SET TITLEBAR '0100' WITH G_TITLE .
ENDMODULE.                 " STATUS_0100  OUTPUT


*&---------------------------------------------------------------------*
*&      Form  READ_DATA
*&---------------------------------------------------------------------*
* 입력받은 테이블 명으로 데이터를 구한다
*----------------------------------------------------------------------*
FORM READ_DATA .
  PERFORM GET_STRUCTURE.
  PERFORM CREATE_DYNAMIC_ITAB.
  PERFORM GET_DATA.
ENDFORM.                    " READ_DATA
*&---------------------------------------------------------------------*
*&      Form  get_structure
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM GET_STRUCTURE.
  DATA : DYNTAB LIKE DNTAB OCCURS 0 WITH HEADER LINE.

  CALL FUNCTION 'NAMETAB_GET'
    EXPORTING
      LANGU   = SY-LANGU
      TABNAME = P_TABLE
    TABLES
      NAMETAB = DYNTAB. "dntab now contains the field names


  LOOP AT DYNTAB.
    CLEAR XFC.
    XFC-FIELDNAME = DYNTAB-FIELDNAME.
    XFC-KEY       = DYNTAB-KEYFLAG.

    IF XFC-KEY = 'X'.
*      xfc-emphasize = 'X'.
      XFC-EMPHASIZE = 'C511'.
    ENDIF.

    XFC-COLTEXT   = DYNTAB-FIELDTEXT.   "2011.08.24 by 서문집
    XFC-REF_FIELD = DYNTAB-FIELDNAME.
    XFC-REF_TABLE = DYNTAB-TABNAME.
    APPEND XFC TO IFC .
  ENDLOOP.
ENDFORM.                    "get_structure



*&---------------------------------------------------------------------*
*&      Form  CREATE_DYNAMIC_ITAB
*&---------------------------------------------------------------------*
* 동적 테이블 구조 생성
*----------------------------------------------------------------------*
FORM CREATE_DYNAMIC_ITAB .
* Create dynamic internal table and assign to FS
  CALL METHOD CL_ALV_TABLE_CREATE=>CREATE_DYNAMIC_TABLE
    EXPORTING
      IT_FIELDCATALOG = IFC
    IMPORTING
      EP_TABLE        = DY_TABLE.

  CALL METHOD CL_ALV_TABLE_CREATE=>CREATE_DYNAMIC_TABLE
    EXPORTING
      IT_FIELDCATALOG = IFC
    IMPORTING
      EP_TABLE        = DY_TABLE_OLD.

*출력 테이블 타입 생성
  ASSIGN DY_TABLE->*     TO <DYN_TABLE>.
  ASSIGN DY_TABLE_OLD->* TO <DYN_TABLE_OLD>.

* Create dynamic work area and assign to FS
  CREATE DATA DY_LINE LIKE LINE OF <DYN_TABLE>.
  ASSIGN DY_LINE->* TO <DYN_WA>.



ENDFORM.                    " CREATE_DYNAMIC_ITAB
*&---------------------------------------------------------------------*
*&      Form  GET_DATA
*&---------------------------------------------------------------------*
* 입력받은 테이블의 데이터를 구한다
*----------------------------------------------------------------------*
FORM GET_DATA .

  SELECT * INTO TABLE <DYN_TABLE>
    FROM (P_TABLE)
    WHERE (G_RSDS_WHERE-WHERE_TAB).


  IF SY-SUBRC NE 0.
    MESSAGE S003 WITH '테이블' P_TABLE
                      '에 해당 회사코드 데이터가 없습니다.'.
  ENDIF.

  <DYN_TABLE_OLD>[] = <DYN_TABLE>[].
  SORT <DYN_TABLE>.
ENDFORM.                    " GET_DATA
*&---------------------------------------------------------------------*
*&      Module  PBO_0100  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE PBO_0100 OUTPUT.
  G_REPID = SY-REPID.
  GS_GSTABLE-ROW = 'X'.
  GS_GSTABLE-COL = 'X'.

  IF G_CUSTOM_CONTAINER IS INITIAL.
*   create a custom container control for our ALV Control
    CREATE OBJECT G_CUSTOM_CONTAINER
      EXPORTING
        CONTAINER_NAME              = G_CONTAINER
      EXCEPTIONS
        CNTL_ERROR                  = 1
        CNTL_SYSTEM_ERROR           = 2
        CREATE_ERROR                = 3
        LIFETIME_ERROR              = 4
        LIFETIME_DYNPRO_DYNPRO_LINK = 5.
    IF SY-SUBRC <> 0.
*     add your handling.
      CALL FUNCTION 'POPUP_TO_INFORM'
        EXPORTING
          TITEL = G_REPID
          TXT2  = SY-SUBRC
          TXT1  = 'The control could not be created'(510).
    ENDIF.
* create an instance of alv control
    CREATE OBJECT GRID1
      EXPORTING
        I_PARENT = G_CUSTOM_CONTAINER.

* make layout
    PERFORM BUILD_LAYOUT.
*필드설정
    PERFORM BUILD_FIELDCAT.
*버튼 제외
    PERFORM ALV_DIALOG_EXECLUDE.

    L_WRK_VARIANT-REPORT   = SY-REPID.
    L_WRK_VARIANT-USERNAME = SY-UNAME.
*    l_wrk_variant-variant  = pm_dis.
    CALL METHOD GRID1->SET_TABLE_FOR_FIRST_DISPLAY
      EXPORTING
        I_STRUCTURE_NAME     = P_TABLE
        IS_LAYOUT            = GS_LAYOUT
        IS_VARIANT           = L_WRK_VARIANT
        IT_TOOLBAR_EXCLUDING = GT_GEXCLUDE[]
        I_SAVE               = 'A'
      CHANGING
        IT_FIELDCATALOG      = IFC
        IT_OUTTAB            = <DYN_TABLE>.
    CREATE OBJECT EVENT_RECEIVER.
    SET HANDLER EVENT_RECEIVER->HANDLE_USER_COMMAND FOR GRID1.
    SET HANDLER EVENT_RECEIVER->HANDLE_TOOLBAR      FOR GRID1.
    CALL METHOD GRID1->SET_TOOLBAR_INTERACTIVE.
* Edit event 설정
    CALL METHOD GRID1->REGISTER_EDIT_EVENT
      EXPORTING
        I_EVENT_ID = CL_GUI_ALV_GRID=>MC_EVT_ENTER.
  ELSE.
    CALL METHOD GRID1->REFRESH_TABLE_DISPLAY
      EXPORTING
        IS_STABLE = GS_GSTABLE.
  ENDIF.

  CALL METHOD CL_GUI_CFW=>FLUSH.
ENDMODULE.                 " PBO_0100  OUTPUT
*&---------------------------------------------------------------------*
*&      Form  BUILD_LAYOUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM BUILD_LAYOUT .
  GS_LAYOUT-GRID_TITLE = P_TABLE.
  GS_LAYOUT-ZEBRA      = 'X'.
  GS_LAYOUT-SMALLTITLE = 'X'.
  GS_LAYOUT-CWIDTH_OPT = 'X'.
  GS_LAYOUT-SEL_MODE   = 'D'.
ENDFORM.                    " BUILD_LAYOUT
*&---------------------------------------------------------------------*
*&      Form  BUILD_FIELDCAT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM BUILD_FIELDCAT .
  LOOP AT IFC INTO GS_GFDCAT.

    GS_GFDCAT-EDIT = 'X'.

    IF GS_GFDCAT-FIELDNAME = 'MANDT'.
      GS_GFDCAT-NO_OUT = 'X'.
    ENDIF.


    MODIFY IFC FROM GS_GFDCAT.
  ENDLOOP.
ENDFORM.                    " BUILD_FIELDCAT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0100 INPUT.
  CASE OK_CODE.
    WHEN 'EXIT'.
      CLEAR OK_CODE.
      LEAVE TO SCREEN 0.
    WHEN 'SAVE'.
      PERFORM SAVE_DATA.
  ENDCASE.
ENDMODULE.                 " USER_COMMAND_0100  INPUT

*&---------------------------------------------------------------------*
*&      Form  SAVE_DATA
*&---------------------------------------------------------------------*
* 데이터 저장
*----------------------------------------------------------------------*
FORM SAVE_DATA .
  CLEAR G_SUBRC.
  DATA L_ANSWER.
  DATA L_VALID.
*  엔터 입력 안해도 변경된 데이터 구할수 있게 함
  CALL METHOD GRID1->CHECK_CHANGED_DATA
    IMPORTING
      E_VALID = L_VALID.


  CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
    EXPORTING
      DEFAULTOPTION  = 'Y'
      TEXTLINE1      = '데이터를 저장 하시겠습니까?'
      TEXTLINE2      = ' '
      TITEL          = '저장'
      START_COLUMN   = 25
      START_ROW      = 6
      CANCEL_DISPLAY = ''
    IMPORTING
      ANSWER         = L_ANSWER.
  CHECK L_ANSWER EQ 'J'.

  DELETE FROM (P_TABLE) WHERE (G_RSDS_WHERE-WHERE_TAB).

  DATA ERROR_TEXT TYPE STRING.
  DATA: EX TYPE REF TO CX_SY_OPEN_SQL_ERROR.
  CLEAR G_SUBRC.
  TRY.

      INSERT (P_TABLE) FROM TABLE <DYN_TABLE>.

    CATCH CX_SY_OPEN_SQL_ERROR INTO EX.
      ERROR_TEXT = EX->GET_TEXT( ).
      MESSAGE ERROR_TEXT TYPE 'S'.
      G_SUBRC = 1.
  ENDTRY.

  IF G_SUBRC IS INITIAL.
    COMMIT WORK.
    MESSAGE S001 WITH '성공적으로 데이터를 저장 했습니다.'.
    SORT <DYN_TABLE>.
*    <dyn_table_old>[]  = <dyn_table>[].
  ELSE.
    ROLLBACK WORK.
  ENDIF.
ENDFORM.                    " SAVE_DATA
*&---------------------------------------------------------------------*
*&      Form  ALV_DIALOG_EXECLUDE
*&---------------------------------------------------------------------*
* alv버튼 제외
*----------------------------------------------------------------------*
FORM ALV_DIALOG_EXECLUDE .
  CLEAR: GS_GEXCLUDE, GT_GEXCLUDE[].
  GS_GEXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_APPEND_ROW.
  APPEND GS_GEXCLUDE TO GT_GEXCLUDE.
  GS_GEXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_INSERT_ROW.
  APPEND GS_GEXCLUDE TO GT_GEXCLUDE.
  GS_GEXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_DELETE_ROW.
  APPEND GS_GEXCLUDE TO GT_GEXCLUDE.
*  gs_gexclude = cl_gui_alv_grid=>mc_fc_loc_copy_row.
*  append gs_gexclude to gt_gexclude.
  GS_GEXCLUDE = CL_GUI_ALV_GRID=>MC_FC_REFRESH.
  APPEND GS_GEXCLUDE TO GT_GEXCLUDE.
  GS_GEXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_PASTE.
  APPEND GS_GEXCLUDE TO GT_GEXCLUDE.
  GS_GEXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_PASTE_NEW_ROW.
  APPEND GS_GEXCLUDE TO GT_GEXCLUDE.
  GS_GEXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_PASTE.
  APPEND GS_GEXCLUDE TO GT_GEXCLUDE.
  GS_GEXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_PASTE_NEW_ROW.
  APPEND GS_GEXCLUDE TO GT_GEXCLUDE.
  GS_GEXCLUDE = CL_GUI_ALV_GRID=>MC_FC_VIEWS.
  APPEND GS_GEXCLUDE TO GT_GEXCLUDE.
  GS_GEXCLUDE = CL_GUI_ALV_GRID=>MC_FC_CHECK.
  APPEND GS_GEXCLUDE TO GT_GEXCLUDE.
  GS_GEXCLUDE = CL_GUI_ALV_GRID=>MC_FC_GRAPH.
  APPEND GS_GEXCLUDE TO GT_GEXCLUDE.
ENDFORM.                    " ALV_DIALOG_EXECLUDE
*&---------------------------------------------------------------------*
*&      Form  ADD_DATA_LINE
*&---------------------------------------------------------------------*
* 라인추가
*----------------------------------------------------------------------*
FORM ADD_DATA_LINE .

  INSERT  <DYN_WA> INTO <DYN_TABLE> INDEX 1.
*  append <dyn_wa> to <dyn_table> .
ENDFORM.                    " ADD_DATA_LINE
*&---------------------------------------------------------------------*
*&      Form  DELETE_DATA_LINE
*&---------------------------------------------------------------------*
* 선택한 라인 삭제
*----------------------------------------------------------------------*
FORM DELETE_DATA_LINE .
  DATA: LT_ROWS TYPE LVC_T_ROW,
        LS_ROWS TYPE LVC_S_ROW,
        L_ROW   TYPE I.
  CALL METHOD GRID1->GET_SELECTED_ROWS
    IMPORTING
      ET_INDEX_ROWS = LT_ROWS.
  DESCRIBE TABLE LT_ROWS LINES L_ROW.
  IF L_ROW EQ 0.
    MESSAGE S001 WITH '데이터를 선택하십시오.'.
    EXIT.
  ENDIF.
  SORT LT_ROWS BY INDEX DESCENDING.
  LOOP AT LT_ROWS INTO LS_ROWS.
    DELETE <DYN_TABLE> INDEX LS_ROWS-INDEX.
  ENDLOOP.
ENDFORM.                    " DELETE_DATA_LINE
*&---------------------------------------------------------------------*
*&      Module  STATUS_0200  OUTPUT
*&---------------------------------------------------------------------*
* STATUS 200
*----------------------------------------------------------------------*
MODULE STATUS_0200 OUTPUT.
  SET PF-STATUS '0200'.
*  set titlebar '0200' with p_table .
  SET TITLEBAR '0200' WITH G_TITLE .
ENDMODULE.                 " STATUS_0200  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  PBO_0200  OUTPUT
*&---------------------------------------------------------------------*
* PBO 200
*----------------------------------------------------------------------*
MODULE PBO_0200 OUTPUT.
  G_REPID = SY-REPID.
  PERFORM GET_DATA_200.
  IF G_INIT_200 IS INITIAL.
*   create a custom container control for our ALV Control
    CREATE OBJECT G_CUSTOM_CONTAINER2
      EXPORTING
        CONTAINER_NAME              = G_CONTAINER2
      EXCEPTIONS
        CNTL_ERROR                  = 1
        CNTL_SYSTEM_ERROR           = 2
        CREATE_ERROR                = 3
        LIFETIME_ERROR              = 4
        LIFETIME_DYNPRO_DYNPRO_LINK = 5.
    IF SY-SUBRC <> 0.
*     add your handling.
      CALL FUNCTION 'POPUP_TO_INFORM'
        EXPORTING
          TITEL = G_REPID
          TXT2  = SY-SUBRC
          TXT1  = 'The control could not be created'(510).
    ENDIF.
* create an instance of alv control
    CREATE OBJECT GRID2
      EXPORTING
        I_PARENT = G_CUSTOM_CONTAINER2.
    L_WRK_VARIANT-REPORT   = SY-REPID.
    L_WRK_VARIANT-USERNAME = SY-UNAME.
*    l_wrk_variant-variant  = pm_dis.
    CALL METHOD GRID2->SET_TABLE_FOR_FIRST_DISPLAY
      EXPORTING
        I_STRUCTURE_NAME     = P_TABLE
        IS_LAYOUT            = GS_LAYOUT
        IS_VARIANT           = L_WRK_VARIANT
        IT_TOOLBAR_EXCLUDING = GT_GEXCLUDE[]
        I_SAVE               = 'A'
      CHANGING
        IT_FIELDCATALOG      = IFC
        IT_OUTTAB            = <DYN_TABLE2>.
*    create object event_receiver.
*    set handler event_receiver->handle_user_command for grid2.
*  set handler event_receiver->handle_toolbar      for grid2.
*  call method grid2->set_toolbar_interactive.

* Edit event 설정
    CALL METHOD GRID2->REGISTER_EDIT_EVENT
      EXPORTING
        I_EVENT_ID = CL_GUI_ALV_GRID=>MC_EVT_ENTER.
    G_INIT_200 = '1'.
  ENDIF.
  CALL METHOD CL_GUI_CFW=>FLUSH.
ENDMODULE.                 " PBO_0200  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0200  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0200 INPUT.
  CASE OK_CODE.
    WHEN 'EXIT'.
      CLEAR OK_CODE.
      CLEAR G_INIT_200.
      CALL METHOD G_CUSTOM_CONTAINER2->FREE.
      LEAVE TO SCREEN 0.

    WHEN 'SAVE2'. "카피한 라인 데이터만 저장
      PERFORM SAVE_DATA_200.
  ENDCASE.
ENDMODULE.                 " USER_COMMAND_0200  INPUT
*&---------------------------------------------------------------------*
*&      Form  COPY_DATA_LINE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM COPY_DATA_LINE .
  CALL SCREEN '0200' STARTING AT 2 10 ENDING AT 120 25.
ENDFORM.                    " COPY_DATA_LINE
*&---------------------------------------------------------------------*
*&      Form  SAVE_DATA_200
*&---------------------------------------------------------------------*
* 카피한 라인 데이터만 저장
*----------------------------------------------------------------------*
FORM SAVE_DATA_200 .
  CLEAR G_SUBRC.
  DATA L_ANSWER.
  DATA L_VALID.
*  엔터 입력 안해도 변경된 데이터 구할수 있게 함
  CALL METHOD GRID2->CHECK_CHANGED_DATA
    IMPORTING
      E_VALID = L_VALID.

  CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
    EXPORTING
      DEFAULTOPTION  = 'Y'
      TEXTLINE1      = '데이터를 저장 하시겠습니까?'
      TEXTLINE2      = ' '
      TITEL          = '저장'
      START_COLUMN   = 25
      START_ROW      = 6
      CANCEL_DISPLAY = ''
    IMPORTING
      ANSWER         = L_ANSWER.
  CHECK L_ANSWER EQ 'J'.



*  데이터 저장시 덤프 발생할때 메세지 처리
  DATA ERROR_TEXT TYPE STRING.
  DATA: EX TYPE REF TO CX_SY_OPEN_SQL_ERROR.
  CLEAR G_SUBRC.

  TRY.

      INSERT (P_TABLE) FROM TABLE <DYN_TABLE2>.
    CATCH CX_SY_OPEN_SQL_ERROR INTO EX.
      ERROR_TEXT = EX->GET_TEXT( ).
      MESSAGE ERROR_TEXT TYPE 'I'.
      G_SUBRC = 1.
  ENDTRY.


  IF G_SUBRC IS INITIAL.
    COMMIT WORK.
    MESSAGE I001 WITH '성공적으로 데이터를 저장 했습니다.'.
    CLEAR <DYN_TABLE>.
    PERFORM GET_DATA.
  ELSE.
    ROLLBACK WORK.
  ENDIF.
ENDFORM.                    " SAVE_DATA_200
*&---------------------------------------------------------------------*
*&      Form  GET_DATA_200
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_DATA_200 .
  DATA: LT_ROWS TYPE LVC_T_ROW,
        LS_ROWS TYPE LVC_S_ROW,
        L_ROW   TYPE I.
  CALL METHOD GRID1->GET_SELECTED_ROWS
    IMPORTING
      ET_INDEX_ROWS = LT_ROWS.
  DESCRIBE TABLE LT_ROWS LINES L_ROW.
  IF L_ROW EQ 0.
    MESSAGE S001 WITH '데이터를 선택하십시오.'.
    LEAVE TO SCREEN 0.
  ENDIF.
*복사 버튼 클릭시 세로운 팝업창에 데이터를 담는 테이블 타입 생성
* Create dynamic internal table and assign to FS
  CALL METHOD CL_ALV_TABLE_CREATE=>CREATE_DYNAMIC_TABLE
    EXPORTING
      IT_FIELDCATALOG = IFC
    IMPORTING
      EP_TABLE        = DY_TABLE.
*팝업 테이블 생성
  ASSIGN DY_TABLE->* TO <DYN_TABLE2>.
  LOOP AT LT_ROWS INTO LS_ROWS.
    READ TABLE <DYN_TABLE> INTO <DYN_WA> INDEX LS_ROWS-INDEX.
    APPEND <DYN_WA> TO <DYN_TABLE2>.
  ENDLOOP.
ENDFORM.                    " GET_DATA_200

*&---------------------------------------------------------------------*
*&      Form  CREATE_DYNAMIC_SELSCREEN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CREATE_DYNAMIC_SELSCREEN.

  DATA TEXPR TYPE RSDS_TEXPR.
  DATA TWHERE TYPE RSDS_TWHERE.
  DATA TRANGE TYPE RSDS_TRANGE.

  DATA BEGIN OF QCAT. "Selections View for
  INCLUDE STRUCTURE RSDSQCAT. "Free Selectoptions
  DATA END OF QCAT.

  DATA BEGIN OF TABS OCCURS 10.
  INCLUDE STRUCTURE RSDSTABS.
  DATA END OF TABS.

  DATA BEGIN OF FIELDS OCCURS 10.
  INCLUDE STRUCTURE RSDSFIELDS.
  DATA END OF FIELDS.

  DATA BEGIN OF EFIELDS OCCURS 10.
  INCLUDE STRUCTURE RSDSFIELDS.
  DATA END OF EFIELDS.

  DATA SELID LIKE RSDYNSEL-SELID.
  DATA ACTNUM LIKE SY-TFILL.
  DATA TITLE LIKE SY-TITLE VALUE 'Selection Screen'.

  DATA: MAXNUM LIKE SY-SUBRC VALUE '69'.

  CLEAR TABS.
  TABS-PRIM_TAB = P_TABLE.
  COLLECT TABS.

  DATA: POSITION LIKE DD03L-POSITION.
  DATA: KEYFLAG LIKE DD03L-KEYFLAG.

  CLEAR FIELDS.

  FIELDS-TABLENAME = P_TABLE.
  FIELDS-SIGN = 'I'.

  DATA: STEP LIKE SY-SUBRC.

  CLEAR G_BUKRS_EXIST.

  SELECT FIELDNAME KEYFLAG POSITION
  INTO (FIELDS-FIELDNAME, KEYFLAG, POSITION)
  FROM DD03L
  WHERE TABNAME = P_TABLE
  AND FIELDNAME NOT LIKE '.INCLU%'
  AND DATATYPE NE 'CLNT'
  ORDER BY POSITION.
    ADD 1 TO STEP.
    CHECK STEP LE MAXNUM.

*    IF keyflag = 'X'.
*      efields = fields.
*      APPEND efields.
*    ENDIF.

*    "회사코드 필드가 존재하는 여부
*    IF fields-fieldname = 'BUKRS'.
*      g_bukrs_exist = 'X'.
*    ENDIF.

    APPEND FIELDS.
  ENDSELECT.


* Table별 Selection Screen 생성을 위한 초기화작업
  CLEAR G_SUBRC.

  "기존 Selection Screen에 입력된것들을 초기화 해야하는지 여부
  CALL FUNCTION 'FREE_SELECTIONS_INIT'
    EXPORTING
      EXPRESSIONS              = TEXPR
      KIND                     = 'F'
    IMPORTING
      SELECTION_ID             = SELID
      EXPRESSIONS              = TEXPR
      WHERE_CLAUSES            = TWHERE
      FIELD_RANGES             = TRANGE
      NUMBER_OF_ACTIVE_FIELDS  = ACTNUM
    TABLES
      TABLES_TAB               = TABS
      FIELDS_TAB               = FIELDS
      FIELDS_NOT_SELECTED      = EFIELDS
    EXCEPTIONS
      FIELDS_INCOMPLETE        = 01
      FIELDS_NO_JOIN           = 02
      FIELD_NOT_FOUND          = 03
      NO_TABLES                = 04
      TABLE_NOT_FOUND          = 05
      EXPRESSION_NOT_SUPPORTED = 06
      INCORRECT_EXPRESSION     = 07
      ILLEGAL_KIND             = 08
      AREA_NOT_FOUND           = 09
      INCONSISTENT_AREA        = 10
      KIND_F_NO_FIELDS_LEFT    = 11
      KIND_F_NO_FIELDS         = 12
      TOO_MANY_FIELDS          = 13.

* 유지보수 Table에 대한 selection Screen을 화면상에 출력
  IF SY-SUBRC = 0.
    CALL FUNCTION 'FREE_SELECTIONS_DIALOG'
      EXPORTING
        SELECTION_ID            = SELID
        TITLE                   = TITLE
        STATUS                  = 1
      IMPORTING
        WHERE_CLAUSES           = TWHERE
        EXPRESSIONS             = TEXPR
        FIELD_RANGES            = TRANGE
        NUMBER_OF_ACTIVE_FIELDS = ACTNUM
      TABLES
        FIELDS_TAB              = FIELDS
      EXCEPTIONS
        INTERNAL_ERROR          = 01
        NO_ACTION               = 02
        NO_FIELDS_SELECTED      = 03
        NO_TABLES_SELECTED      = 04
        SELID_NOT_FOUND         = 05.

    IF SY-SUBRC = 0.

      "Selection Screen에 입력된 값들을 기준으로해서
      "System이 생성해준 Where절을 가져옴

      CLEAR G_RSDS_WHERE.
      MOVE P_TABLE TO G_RSDS_WHERE-TABLENAME.
      READ TABLE TWHERE WITH KEY G_RSDS_WHERE-TABLENAME
        INTO G_RSDS_WHERE.

      "회사코드 필드가 테이블에 존재한다면 반드시 조회조건에
      "회사코드가 들어가야 함. 그리고 회사코드는 단일값만 들어가야함.
    ELSE.
      G_SUBRC = 99.
    ENDIF.


  ENDIF.

ENDFORM.                    " CREATE_DYNAMIC_SELSCREEN



*&---------------------------------------------------------------------*
*&      Form  CHECK_SINGLE_BUKRS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_TRANGE  text
*      -->P_G_SUBRC  text
*----------------------------------------------------------------------*
FORM CHECK_SINGLE_BUKRS  TABLES   PT_TRANGE TYPE RSDS_TRANGE
                         USING    PA_SUBRC
                                  PA_BUKRS.

  DATA: L_CNT TYPE I.
  DATA: LS_RSDS_RANGE  TYPE  RSDS_RANGE,
        LS_RSDS_FRANGE TYPE RSDS_FRANGE,
        LS_RSDS_SELOPT TYPE RSDSSELOPT.

  READ TABLE PT_TRANGE INTO LS_RSDS_RANGE
    WITH KEY TABLENAME = P_TABLE.

  IF SY-SUBRC <> 0.
    PA_SUBRC = 9.
    MESSAGE S001 WITH '조회조건에 회사코드를 넣어주십시요'.
    EXIT.
  ENDIF.

  READ TABLE  LS_RSDS_RANGE-FRANGE_T INTO LS_RSDS_FRANGE
  WITH KEY FIELDNAME = 'BUKRS'.

  IF SY-SUBRC <> 0.
    PA_SUBRC = 9.
    MESSAGE S001 WITH '조회조건에 회사코드를 넣어주십시요'.
    EXIT.
  ENDIF.


  DESCRIBE TABLE LS_RSDS_FRANGE-SELOPT_T LINES L_CNT.

  IF L_CNT = 0.
    PA_SUBRC = 9.
    MESSAGE S001 WITH '회사코드는 반드시 입력이 되어야 합니다'.
    EXIT.

  ELSEIF L_CNT > 1.

    PA_SUBRC = 9.
    MESSAGE S001 WITH '회사코드는 하나만 입력되어야합니다'.
    EXIT.
  ENDIF.


  READ TABLE LS_RSDS_FRANGE-SELOPT_T
    INTO LS_RSDS_SELOPT WITH KEY OPTION = 'EQ'.

  IF SY-SUBRC <> 0 .
    PA_SUBRC = 9.
    MESSAGE S001 WITH '회사코드는 하나만 입력되어야합니다'.
    EXIT.
  ENDIF.

  PA_BUKRS = LS_RSDS_SELOPT-LOW.
ENDFORM.                    " CHECK_SINGLE_BUKRS
