*----------------------------------------------------------------------*
***INCLUDE LZGOPPU1F01.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form READ_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM READ_DATA .

  PERFORM GET_STRUCTURE.
  PERFORM CREATE_DYNAMIC_ITAB.
  PERFORM GET_DATA.

ENDFORM.
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
      TABNAME = IV_TABNAME
    TABLES
      NAMETAB = DYNTAB. "dntab now contains the field names

  REFRESH : IFC.

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
  FREE : DY_TABLE, DY_TABLE_OLD.


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
    FROM (IV_TABNAME).


  <DYN_TABLE_OLD>[] = <DYN_TABLE>[].
  SORT <DYN_TABLE>.

ENDFORM.                    " GET_DATA
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0100 INPUT.

  CLEAR OK_CODE.
  OK_CODE = SY-UCOMM.

  CASE OK_CODE.
    WHEN 'BACK' OR 'EXIT' OR 'CANC'.
      CLEAR OK_CODE.

*     종료
      CALL METHOD G_DOCKING_0100->FREE.

      FREE : G_DOCKING_0100.
      FREE : GRID1.
      FREE EVENT_RECEIVER.

      CALL METHOD CL_GUI_CFW=>FLUSH.

      LEAVE TO SCREEN 0.
    WHEN 'SAVE'.
      PERFORM SAVE_DATA.
  ENDCASE.

ENDMODULE.
*&---------------------------------------------------------------------*
*& Module PBO_0100 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE PBO_0100 OUTPUT.
  G_REPID = SY-REPID.
  GS_GSTABLE-ROW = 'X'.
  GS_GSTABLE-COL = 'X'.

  IF G_DOCKING_0100 IS INITIAL.
*   create a custom container control for our ALV Control
    CREATE OBJECT G_DOCKING_0100
      EXPORTING
        REPID                       = SY-REPID
        DYNNR                       = SY-DYNNR
        EXTENSION                   = 10000
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
        I_PARENT = G_DOCKING_0100.

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
        I_STRUCTURE_NAME     = IV_TABNAME
        IS_LAYOUT            = GS_LAYOUT
        IS_VARIANT           = L_WRK_VARIANT
        IT_TOOLBAR_EXCLUDING = GT_GEXCLUDE[]
        I_SAVE               = 'A'
        I_BYPASSING_BUFFER   = ABAP_TRUE
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
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module STATUS_0100 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE STATUS_0100 OUTPUT.
  SET PF-STATUS '0100'.
  SET TITLEBAR '0100' WITH IV_TITLE.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Form SAVE_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
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

  DELETE FROM (IV_TABNAME).

  DATA ERROR_TEXT TYPE STRING.
  DATA: EX TYPE REF TO CX_SY_OPEN_SQL_ERROR.
  CLEAR G_SUBRC.
  TRY.

      INSERT (IV_TABNAME) FROM TABLE <DYN_TABLE>.

    CATCH CX_SY_OPEN_SQL_ERROR INTO EX.
      ERROR_TEXT = EX->GET_TEXT( ).
      MESSAGE ERROR_TEXT TYPE 'S' DISPLAY LIKE 'E'.
      G_SUBRC = 1.
  ENDTRY.

  IF G_SUBRC IS INITIAL.
    COMMIT WORK.
    MESSAGE S004.
    SORT <DYN_TABLE>.
*    <dyn_table_old>[]  = <dyn_table>[].
  ELSE.
    ROLLBACK WORK.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  BUILD_LAYOUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM BUILD_LAYOUT .

  CLEAR GS_LAYOUT.
  GS_LAYOUT-GRID_TITLE = IV_TABNAME.
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
*& Form add_data_line
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM ADD_DATA_LINE .

  INSERT  <DYN_WA> INTO <DYN_TABLE> INDEX 1.
*  append <dyn_wa> to <dyn_table> .

ENDFORM.
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
*& Module STATUS_0200 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE STATUS_0200 OUTPUT.
  SET PF-STATUS '0200'.
  SET TITLEBAR '0200' WITH GV_TITLE.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0200  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0200 INPUT.

  CLEAR OK_CODE2.
  OK_CODE2 = SY-UCOMM.
  CASE OK_CODE2.
    WHEN 'BACK' OR 'EXIT' OR 'CANC'.
      GO_CONTAINER_200->FREE( ).
      GO_TEXT_200->FREE( ).
      FREE : GO_CONTAINER_200, GO_TEXT_200.
      LEAVE TO SCREEN 0.
    WHEN 'CONFIRM'.
      PERFORM CHECK_AND_CREATE.
      GO_CONTAINER_200->FREE( ).
      GO_TEXT_200->FREE( ).
      FREE : GO_CONTAINER_200, GO_TEXT_200.
      LEAVE TO SCREEN 0.

  ENDCASE.

ENDMODULE.
*&---------------------------------------------------------------------*
*& Form CHECK_AND_CREATE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CHECK_AND_CREATE .

  IF GV_MODE = '2'.
    CALL METHOD GO_TEXT_200->GET_TEXT_AS_R3TABLE(
      EXPORTING
        ONLY_WHEN_MODIFIED = ' '
      IMPORTING
        TABLE              = GT_TEXT ).
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Module SET_TEXT_EDIT OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE SET_TEXT_EDIT OUTPUT.
  IF GO_TEXT_200 IS NOT BOUND.
    PERFORM SET_OBJECT_GO_TEXT_200.
    PERFORM SET_GO_TEXT_200.
  ENDIF.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Form SET_OBJECT_GO_TEXT_200
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_OBJECT_GO_TEXT_200 .

  CREATE OBJECT GO_CONTAINER_200
    EXPORTING
      REPID                       = SY-REPID
      DYNNR                       = SY-DYNNR
      EXTENSION                   = 10000
    EXCEPTIONS
      CNTL_ERROR                  = 1
      CNTL_SYSTEM_ERROR           = 2
      CREATE_ERROR                = 3
      LIFETIME_ERROR              = 4
      LIFETIME_DYNPRO_DYNPRO_LINK = 5.

  CREATE OBJECT GO_TEXT_200
    EXPORTING
      WORDWRAP_MODE          = 2
*      MAX_NUMBER_CHARS       = 255                         " maximum number of characters insertable into editor control
      PARENT                 = GO_CONTAINER_200                        " Parent Container
    EXCEPTIONS
      ERROR_CNTL_CREATE      = 1                        " Error while performing creation of TextEdit control!
      ERROR_CNTL_INIT        = 2                        " Error while initializing TextEdit control!
      ERROR_CNTL_LINK        = 3                        " Error while linking TextEdit control!
      ERROR_DP_CREATE        = 4                        " Error while creating DataProvider control!
      GUI_TYPE_NOT_SUPPORTED = 5                        " This type of GUI is not supported!
      OTHERS                 = 6.
  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
      WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_GO_TEXT_200
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_GO_TEXT_200 .


  GO_TEXT_200->SET_TOOLBAR_MODE( EXPORTING TOOLBAR_MODE = 0 ).

  GO_TEXT_200->SET_STATUSBAR_MODE( EXPORTING STATUSBAR_MODE = 0 ).

  IF GV_MODE = '1'.
    GO_TEXT_200->SET_READONLY_MODE( EXPORTING READONLY_MODE = 1 ).
  ELSE.
    GO_TEXT_200->SET_READONLY_MODE( EXPORTING READONLY_MODE = 0 ).
  ENDIF.

  GO_TEXT_200->SET_TEXT_AS_R3TABLE( EXPORTING TABLE = GT_TEXT ).

  CALL METHOD CL_GUI_CFW=>FLUSH
    EXCEPTIONS
      OTHERS = 1.

ENDFORM.
