*&---------------------------------------------------------------------*
*& Include          ZGTPPR2180F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form SET_BUTTON
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_BUTTON .

  CLEAR GV_DYNTXT.
  GV_DYNTXT-ICON_ID = ICON_TABLE_SETTINGS.
  GV_DYNTXT-TEXT = '이메일 수신자 관리'.
  GV_DYNTXT-QUICKINFO = '이메일 수신자 관리'.
  SSCRFIELDS-FUNCTXT_01 = GV_DYNTXT.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form CALL_MAINTAIN_VIEW
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CALL_MAINTAIN_VIEW .

  PERFORM GET_INIT_DATA.

  REFRESH GT_MAINTAIN.
  CLEAR GV_CHK_EDIT_200.

  SELECT * FROM ZGTPPT3460
    INTO TABLE GT_3460
   WHERE CPROG = 'ZGTPPR2180'
     AND WERKS = P_WERKS
     AND SPGCD = P_SPGCD.

  SORT GT_3460 BY SEQNO.
  LOOP AT GT_3460 INTO DATA(LS_3460).
    CLEAR GS_MAINTAIN.
    MOVE-CORRESPONDING LS_3460 TO GS_MAINTAIN.
* 플랜트명
    GS_MAINTAIN-NAME1 = GV_NAME1.
* spg명
    GS_MAINTAIN-DESCR = GV_DESCR.

    APPEND GS_MAINTAIN TO GT_MAINTAIN.

  ENDLOOP.

  CALL SCREEN '0200'.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_INIT_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_INIT_DATA .

* 플랜트명
  CLEAR GV_NAME1.
  GV_NAME1 = ZGTPP_CL_COMMON=>GET_PLANT_NAME( IV_WERKS = P_WERKS ).

* SPG명
  CLEAR GV_DESCR.
  SELECT SINGLE DESCR INTO GV_DESCR
         FROM ZPPT0107
        WHERE SPGCD EQ P_SPGCD.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_OBJECT_GRID_0200
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_OBJECT_GRID_0200 .

  CREATE OBJECT GO_CONTAIN_0200
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

  CREATE OBJECT GO_GRID_0200
    EXPORTING
      I_PARENT      = GO_CONTAIN_0200
      I_APPL_EVENTS = ABAP_TRUE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form EVENT_HANDLER_REGISTER
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GO_GRID_0200
*&---------------------------------------------------------------------*
FORM EVENT_HANDLER_REGISTER  USING    PO_GRID TYPE REF TO CL_GUI_ALV_GRID.

  IF GO_EVENT_HANDLER IS NOT BOUND.
    CREATE OBJECT GO_EVENT_HANDLER.
  ENDIF.

  CASE PO_GRID.
    WHEN GO_GRID_0100.
      SET HANDLER GO_EVENT_HANDLER->HANDLE_TOOLBAR               FOR PO_GRID.
      SET HANDLER GO_EVENT_HANDLER->HANDLE_USER_COMMAND          FOR PO_GRID.
      SET HANDLER GO_EVENT_HANDLER->HANDLE_DATA_CHANGED          FOR PO_GRID.
      SET HANDLER GO_EVENT_HANDLER->HANDLE_HOTSPOT          FOR PO_GRID.
    WHEN GO_GRID_0200.
      SET HANDLER GO_EVENT_HANDLER->HANDLE_TOOLBAR               FOR PO_GRID.
      SET HANDLER GO_EVENT_HANDLER->HANDLE_USER_COMMAND          FOR PO_GRID.
      SET HANDLER GO_EVENT_HANDLER->HANDLE_DATA_CHANGED          FOR PO_GRID.
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_LAYOUT_GRID_0200
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_LAYOUT_GRID_0200 .

  DATA : LV_TEXT1 TYPE CHAR100.
  DATA : LV_TEXT2 TYPE CHAR100.

  CLEAR GS_LAYOUT_0200.
  GS_LAYOUT_0200-CWIDTH_OPT = ABAP_TRUE.
  GS_LAYOUT_0200-NO_ROWINS = ABAP_TRUE.
  GS_LAYOUT_0200-SEL_MODE   = 'D'.
  GS_LAYOUT_0200-STYLEFNAME   = 'CELLTAB'.
  GS_LAYOUT_0200-SMALLTITLE = 'X'.
  CLEAR LV_TEXT1.
  CONCATENATE '플랜트 :' P_WERKS GV_NAME1 INTO LV_TEXT1 SEPARATED BY SPACE.
  LV_TEXT1 = LV_TEXT1 && ','.

  CLEAR LV_TEXT2.
  CONCATENATE 'SPG :' P_SPGCD GV_DESCR INTO LV_TEXT2 SEPARATED BY SPACE.

  CONCATENATE LV_TEXT1 LV_TEXT2 INTO GS_LAYOUT_0200-GRID_TITLE SEPARATED BY SPACE.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_FIELDCAT_GRID_0200
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_FIELDCAT_GRID_0200 .

  DATA : LT_FCAT_SLIS TYPE SLIS_T_FIELDCAT_ALV.
  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      I_PROGRAM_NAME         = SY-REPID
      I_INCLNAME             = 'ZGTPPR2180TOP'
      I_INTERNAL_TABNAME     = 'GS_MAINTAIN'
    CHANGING
      CT_FIELDCAT            = LT_FCAT_SLIS
    EXCEPTIONS
      INCONSISTENT_INTERFACE = 1
      PROGRAM_ERROR          = 2
      OTHERS                 = 3.

  REFRESH GT_FIELDCAT_0200.

*-- lt_fieldcat의 구조체를 pt_fcat의 구조체로 변경
  CALL FUNCTION 'LVC_TRANSFER_FROM_SLIS'
    EXPORTING
      IT_FIELDCAT_ALV = LT_FCAT_SLIS
    IMPORTING
      ET_FIELDCAT_LVC = GT_FIELDCAT_0200[]
    TABLES
      IT_DATA         = GT_MAINTAIN
    EXCEPTIONS
      OTHERS          = 1.

  READ TABLE GT_FIELDCAT_0200 ASSIGNING FIELD-SYMBOL(<LS_FCAT>) WITH KEY FIELDNAME = 'STATUS'.
  IF SY-SUBRC NE 0.
    APPEND INITIAL LINE TO GT_FIELDCAT_0200 ASSIGNING <LS_FCAT>.

    <LS_FCAT>-FIELDNAME = 'STATUS'.
    <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = <LS_FCAT>-FIELDNAME.
    <LS_FCAT>-COL_POS = 12.
    <LS_FCAT>-DATATYPE = 'CHAR'.
    <LS_FCAT>-DD_OUTLEN = '1'.
    <LS_FCAT>-NO_OUT = ABAP_TRUE.

  ENDIF.


  LOOP AT GT_FIELDCAT_0200 ASSIGNING <LS_FCAT>.
    CASE   <LS_FCAT>-FIELDNAME.
      WHEN 'CPROG' OR 'SEQNO'.
        <LS_FCAT>-NO_OUT = ABAP_TRUE.
      WHEN 'WERKS'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '플랜트'(F01).
        <LS_FCAT>-JUST = 'C'.
      WHEN 'NAME1'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '플랜트 내역'(F02).
        <LS_FCAT>-JUST = 'L'.
      WHEN 'SPGCD'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = 'SPG'(F03).
        <LS_FCAT>-JUST = 'C'.
      WHEN 'DESCR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = 'SPG 내역'(F04).
        <LS_FCAT>-JUST = 'L'.
      WHEN 'MAIL_TYPE'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '수신 구분'(F05).
        <LS_FCAT>-JUST = 'C'.
        <LS_FCAT>-DRDN_HNDL = '1'.
        <LS_FCAT>-EDIT = ABAP_TRUE.
      WHEN 'NAME'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '성명'(F06).
        <LS_FCAT>-JUST = 'L'.
        <LS_FCAT>-EDIT = ABAP_TRUE.
      WHEN 'DEPT'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '부서'(F07).
        <LS_FCAT>-JUST = 'L'.
        <LS_FCAT>-EDIT = ABAP_TRUE.
      WHEN 'MAIL_ADDR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '이메일 주소'(F08).
        <LS_FCAT>-JUST = 'L'.
        <LS_FCAT>-EDIT = ABAP_TRUE.
      WHEN 'ACTIVE'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '활성여부'(F09).
        <LS_FCAT>-JUST = 'C'.
        <LS_FCAT>-CHECKBOX = 'X'.
        <LS_FCAT>-EDIT = ABAP_TRUE.
    ENDCASE.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form EXCLUDE_OF_TOOLBAR_GRID_0200
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM EXCLUDE_OF_TOOLBAR_GRID_0200 .

  REFRESH GT_EXCLUDE_0200.

  PERFORM ADD_EXCLUDE_TOOLBAR_BUTTON TABLES GT_EXCLUDE_0200
        USING : CL_GUI_ALV_GRID=>MC_FC_EXCL_ALL.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  add_exclude_toolbar_button
*&---------------------------------------------------------------------*
*       text
*-----------------------------------------------------------------------
**
FORM ADD_EXCLUDE_TOOLBAR_BUTTON  TABLES   P_TABLE
                                 USING    P_VALUE.
  DATA: L_EXCLUDE TYPE UI_FUNC.
  L_EXCLUDE = P_VALUE.
  APPEND L_EXCLUDE TO P_TABLE.
ENDFORM.                    " add_exclude_toolbar_button
*&---------------------------------------------------------------------*
*& Form CALL_GRID_0200_DISPLAY
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CALL_GRID_0200_DISPLAY .

  CALL METHOD GO_GRID_0200->SET_TABLE_FOR_FIRST_DISPLAY
    EXPORTING
      IS_LAYOUT            = GS_LAYOUT_0200
      IT_TOOLBAR_EXCLUDING = GT_EXCLUDE_0200
    CHANGING
      IT_OUTTAB            = GT_MAINTAIN
      IT_FIELDCATALOG      = GT_FIELDCAT_0200.

* 인풋이벤트 추가
  CALL METHOD GO_GRID_0200->REGISTER_EDIT_EVENT
    EXPORTING
      I_EVENT_ID = CL_GUI_ALV_GRID=>MC_EVT_ENTER.

  CALL METHOD GO_GRID_0200->REGISTER_EDIT_EVENT
    EXPORTING
      I_EVENT_ID = CL_GUI_ALV_GRID=>MC_EVT_MODIFIED.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_DROPDOWN_GRID_0200
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_DROPDOWN_GRID_0200 .

  DATA: LT_DRAL TYPE LVC_T_DRAL,                            "#EC NEEDED
        LS_DRAL TYPE LVC_S_DRAL.                            "#EC NEEDED

  LS_DRAL-HANDLE = '1'.
  LS_DRAL-INT_VALUE = '수신'.
  LS_DRAL-VALUE = 'TO'.

  APPEND LS_DRAL TO LT_DRAL.

  LS_DRAL-HANDLE = '1'.
  LS_DRAL-INT_VALUE = '참조'.
  LS_DRAL-VALUE = 'CC'.
  APPEND LS_DRAL TO LT_DRAL.

  GO_GRID_0200->SET_DROP_DOWN_TABLE(
    IT_DROP_DOWN_ALIAS = LT_DRAL ).


ENDFORM.
*&---------------------------------------------------------------------*
*& Form TOOLBAR_PROS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> SENDER
*&      --> E_OBJECT
*&      --> E_INTERACTIVE
*&---------------------------------------------------------------------*
FORM TOOLBAR_PROS  USING    PO_SENDER
                          PO_OBJECT TYPE REF TO CL_ALV_EVENT_TOOLBAR_SET
                          R_INTERACTIVE.

  CASE PO_SENDER.
    WHEN GO_GRID_0100.
      PERFORM SET_TOOLBAR TABLES PO_OBJECT->MT_TOOLBAR
                                 USING : 'SAVE' ICON_SAVE_AS_TEMPLATE '저장' '저장' 0,
                                            'CHG_ZINHOUSE' '' '"자체생산" 일괄변경' '"자체생산" 일괄변경' 0,
                                            'CHG_ZBILLING' '' '"청구구분" 일괄변경' '"청구구분" 일괄변경' 0.
    WHEN GO_GRID_0200.

      PERFORM SET_TOOLBAR TABLES PO_OBJECT->MT_TOOLBAR
                                 USING : 'ADDLINE' ICON_INSERT_ROW '라인추가' '라인추가' 0,
                                            'DELLINE' ICON_DELETE_ROW	 '라인삭제' '라인삭제' 0,
                                             '' '' '' '' 3,
                                            'SAVE' ICON_SAVE_AS_TEMPLATE '저장' '저장' 0.

  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_toolbar
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> P_
*&      --> P_
*&      --> P_
*&      --> P_
*&      --> PO_OBJECT_>MT_TOOLBAR
*&---------------------------------------------------------------------*
FORM SET_TOOLBAR  TABLES  PT_TOOLBAR STRUCTURE STB_BUTTON
               USING    PV_FUNCTION
                           PV_ICON
                           PV_TEXT
                           PV_QUICKINFO
                           PV_BUTN_TYPE.

  DATA : LS_TOOLBAR  TYPE STB_BUTTON.

  CLEAR LS_TOOLBAR.
  LS_TOOLBAR-FUNCTION  = PV_FUNCTION.
  LS_TOOLBAR-ICON      = PV_ICON.
  IF PV_TEXT IS NOT INITIAL.
    CONCATENATE ' '  PV_TEXT ' '  INTO LS_TOOLBAR-TEXT SEPARATED BY SPACE.
  ENDIF.
  LS_TOOLBAR-QUICKINFO = PV_QUICKINFO.
  LS_TOOLBAR-BUTN_TYPE = PV_BUTN_TYPE.
  APPEND LS_TOOLBAR TO PT_TOOLBAR.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form USER_COMMAND_PROS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> SENDER
*&      --> E_UCOMM
*&---------------------------------------------------------------------*
FORM USER_COMMAND_PROS  USING     PO_SENDER  TYPE REF TO CL_GUI_ALV_GRID
                                 PV_UCOMM.

  CASE PO_SENDER.
    WHEN GO_GRID_0100.
      CASE PV_UCOMM.
        WHEN 'SAVE'.
          PERFORM PROC_SAVE_0100.
        WHEN 'CHG_ZINHOUSE'.
          PERFORM PROC_CHG_ZINHOUSE.
        WHEN 'CHG_ZBILLING'.
          PERFORM PROC_CHG_ZBILLING.
      ENDCASE.
    WHEN GO_GRID_0200.
      CASE PV_UCOMM.
        WHEN 'ADDLINE'.
          PERFORM PROC_ADDLINE_0200.
        WHEN 'DELLINE'.
          PERFORM PROC_DELLINE_0200.
        WHEN 'SAVE'.
          PERFORM PROC_SAVE_0200.

      ENDCASE.
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form DATA_CHANGED
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> SENDER
*&      --> ER_DATA_CHANGED
*&      --> E_ONF4
*&      --> E_UCOMM
*&---------------------------------------------------------------------*
FORM DATA_CHANGED  USING    P_SENDER  TYPE REF TO CL_GUI_ALV_GRID
                                PO_DATA_CHANGED TYPE REF TO
                                          CL_ALV_CHANGED_DATA_PROTOCOL
                                PE_ONF4
                                PE_UCOMM.

  DATA: LS_MOD_CELLS TYPE LVC_S_MODI.

  DEFINE __MODI_CELL.
    PO_DATA_CHANGED->MODIFY_CELL(
      I_ROW_ID     = &1                 " Row ID
      I_FIELDNAME = &2                 " Field Name
      I_VALUE       = &3 ).               " Value
  END-OF-DEFINITION.

  CASE P_SENDER.
    WHEN GO_GRID_0100.
      LOOP AT PO_DATA_CHANGED->MT_GOOD_CELLS INTO LS_MOD_CELLS.
        CASE LS_MOD_CELLS-FIELDNAME.
          WHEN 'ZBILLING_T'.
            CASE LS_MOD_CELLS-VALUE.
              WHEN '청구'.
                __MODI_CELL LS_MOD_CELLS-ROW_ID 'ZBILLING' 'Y'.
              WHEN '미청구'.
                __MODI_CELL LS_MOD_CELLS-ROW_ID 'ZBILLING' 'N'.
              WHEN OTHERS.
                __MODI_CELL LS_MOD_CELLS-ROW_ID 'ZBILLING' ''.
            ENDCASE.
        ENDCASE.
      ENDLOOP.

    WHEN GO_GRID_0200.
      GV_CHK_EDIT_200 = ABAP_TRUE.
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROC_ADDLINE_0200
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PROC_ADDLINE_0200 .

  DATA : LV_SEQNO(4) TYPE N.
  DATA : LS_MAIN LIKE GS_MAINTAIN.

  DATA(LT_MAIN) = GT_MAINTAIN.
  SORT LT_MAIN BY SEQNO DESCENDING.
  READ TABLE LT_MAIN INTO DATA(LS_MAIN_TMP) INDEX 1.
  IF SY-SUBRC EQ 0.
    LV_SEQNO = LS_MAIN_TMP-SEQNO + 1.
  ELSE.
    LV_SEQNO = 1.
  ENDIF.

  LS_MAIN-CPROG = 'ZGTPPR2180'.
  LS_MAIN-WERKS = P_WERKS.
  LS_MAIN-NAME1 = GV_NAME1.
  LS_MAIN-SPGCD = P_SPGCD.
  LS_MAIN-DESCR = GV_DESCR.
  LS_MAIN-SEQNO = LV_SEQNO.
  LS_MAIN-STATUS = 'N'.

  APPEND LS_MAIN TO GT_MAINTAIN.

  PERFORM REFRESH_GRID USING GO_GRID_0200.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form REFRESH_GRID
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GO_GRID_0200
*&---------------------------------------------------------------------*
FORM REFRESH_GRID  USING    PO_GRID TYPE REF TO CL_GUI_ALV_GRID.

  DATA: LS_SCROLL   TYPE LVC_S_STBL.

  LS_SCROLL-ROW = 'X'.
  LS_SCROLL-COL = 'X'.

  CASE PO_GRID.
    WHEN GO_GRID_0100.
      PERFORM SET_CELL_ATTRIBUTE_GRID_0100.
      GO_GRID_0100->SET_FRONTEND_LAYOUT( IS_LAYOUT = GS_LAYOUT_0100 ).
    WHEN GO_GRID_0200.
      GO_GRID_0200->SET_FRONTEND_LAYOUT( IS_LAYOUT = GS_LAYOUT_0200 ).
  ENDCASE.


  CALL METHOD PO_GRID->REFRESH_TABLE_DISPLAY
    EXPORTING
*     I_SOFT_REFRESH = 'X'
      IS_STABLE = LS_SCROLL.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROC_DELLINE_0200
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PROC_DELLINE_0200 .

  DATA : LT_ROWS TYPE LVC_T_ROW.

  GO_GRID_0200->GET_SELECTED_ROWS(
    IMPORTING
      ET_INDEX_ROWS = LT_ROWS ).                " Indexes of Selected Rows
*      ET_ROW_NO     =                  " Numeric IDs of Selected Rows

  DELETE LT_ROWS WHERE INDEX = 0.

  IF LT_ROWS[] IS INITIAL.
    MESSAGE S006 DISPLAY LIKE 'E' WITH '선택된 라인이 없습니다.'(E01).
    RETURN.
  ENDIF.

* 딜리트는 인덱스 역순으로 처리
  SORT   LT_ROWS BY INDEX DESCENDING.

  LOOP AT LT_ROWS INTO DATA(LS_ROWS).
    DELETE GT_MAINTAIN INDEX LS_ROWS-INDEX.
  ENDLOOP.

  GV_CHK_EDIT_200 = ABAP_TRUE.
  PERFORM REFRESH_GRID USING GO_GRID_0200.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROC_SAVE_0200
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PROC_SAVE_0200 .

  DATA : LV_CHK_ERR.
  DATA : LT_CHG_3460 TYPE TABLE OF ZGTPPT3460.
  DATA : LV_SEQNO(4) TYPE N.

  PERFORM CHK_BEFORE_SAVE_0200 CHANGING LV_CHK_ERR.

  IF LV_CHK_ERR = ABAP_TRUE.
    RETURN.
  ENDIF.

  LOOP AT GT_MAINTAIN INTO DATA(LS_MAIN).
    APPEND INITIAL LINE TO LT_CHG_3460 ASSIGNING FIELD-SYMBOL(<LS_3460>).
    MOVE-CORRESPONDING LS_MAIN TO <LS_3460>.

    IF LS_MAIN-STATUS = 'N'. " 신규 입력 라인
      MOVE : SY-DATUM TO <LS_3460>-CRDAT,
                SY-UZEIT TO <LS_3460>-CRTIM,
                SY-UNAME TO <LS_3460>-CRNAM,
                SY-DATUM TO <LS_3460>-CHDAT,
                SY-UZEIT TO <LS_3460>-CHTIM,
                SY-UNAME TO <LS_3460>-CHNAM.
    ELSE.
      READ TABLE GT_3460 INTO DATA(LS_3460) WITH KEY SEQNO = LS_MAIN-SEQNO.
      IF SY-SUBRC EQ 0.
        MOVE : LS_3460-CRDAT TO <LS_3460>-CRDAT,
                LS_3460-CRTIM TO <LS_3460>-CRTIM,
                LS_3460-CRNAM TO <LS_3460>-CRNAM,
                SY-DATUM TO <LS_3460>-CHDAT,
                SY-UZEIT TO <LS_3460>-CHTIM,
                SY-UNAME TO <LS_3460>-CHNAM.
      ENDIF.
    ENDIF.
  ENDLOOP.

  SORT LT_CHG_3460 BY SEQNO.
  LOOP AT LT_CHG_3460 ASSIGNING <LS_3460>.
    ADD 1 TO LV_SEQNO.
    <LS_3460>-SEQNO = LV_SEQNO.
  ENDLOOP.

  IF GT_3460[] IS NOT INITIAL.
    DELETE ZGTPPT3460 FROM TABLE GT_3460.
    IF SY-SUBRC NE 0.
      MESSAGE S006 DISPLAY LIKE 'E' WITH '수신자 관리 테이블 저장중 오류 발생하였습니다.'(e07).
      ROLLBACK WORK.
      RETURN.
    ENDIF.
  ENDIF.

  IF LT_CHG_3460 IS NOT INITIAL.
    MODIFY ZGTPPT3460 FROM TABLE LT_CHG_3460.
    IF SY-SUBRC NE 0.
      MESSAGE S006 DISPLAY LIKE 'E' WITH '수신자 관리 테이블 저장중 오류 발생하였습니다.'(e07).
      ROLLBACK WORK.
      RETURN.
    ENDIF.
  ENDIF.

  COMMIT WORK AND WAIT.

  PERFORM REFRESH_GRID USING GO_GRID_0200.
  CLEAR GV_CHK_EDIT_200.
  MESSAGE S006 WITH '데이터 저장 완료 되었습니다.'(e08).


ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHK_BEFORE_SAVE_0200
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- LV_CHK_ERR
*&---------------------------------------------------------------------*
FORM CHK_BEFORE_SAVE_0200  CHANGING PV_CHK_ERR.

  IF GT_MAINTAIN[] IS INITIAL AND GT_3460 IS INITIAL.
    PV_CHK_ERR = ABAP_TRUE.
    MESSAGE S006 DISPLAY LIKE 'E' WITH '저장할 수 있는 데이터가 없습니다'(e02).
    RETURN.
  ENDIF.

  LOOP AT GT_MAINTAIN INTO DATA(LS_MAIN).
    IF LS_MAIN-ACTIVE = ABAP_TRUE.
      IF LS_MAIN-NAME IS INITIAL.
        PV_CHK_ERR = ABAP_TRUE.
        MESSAGE S006 DISPLAY LIKE 'E' WITH '활성 체크된 라인에 성명이 비어있습니다.'(e03).
        RETURN.
      ENDIF.

      IF LS_MAIN-MAIL_TYPE IS INITIAL.
        PV_CHK_ERR = ABAP_TRUE.
        MESSAGE S006 DISPLAY LIKE 'E' WITH '활성 체크된 라인에 수신 구분이 비어있습니다.'(e04).
        RETURN.
      ENDIF.

      IF LS_MAIN-DEPT IS INITIAL.
        PV_CHK_ERR = ABAP_TRUE.
        MESSAGE S006 DISPLAY LIKE 'E' WITH '활성 체크된 라인에 부서가 비어있습니다.'(e05).
        RETURN.
      ENDIF.

      IF LS_MAIN-MAIL_ADDR IS INITIAL.
        PV_CHK_ERR = ABAP_TRUE.
        MESSAGE S006 DISPLAY LIKE 'E' WITH '활성 체크된 라인에 이메일 주소가 비어있습니다.'(e06).
        RETURN.
      ENDIF.

    ENDIF.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form AUTHORITY_CHECKING_PROC
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM AUTHORITY_CHECKING_PROC .

*& MRP관리자에 대한 권한체크
  AUTHORITY-CHECK OBJECT 'ZPP_SPGCD'
  ID 'WERKS'  FIELD P_WERKS
  ID 'SPGCD'  FIELD P_SPGCD.

  IF SY-SUBRC <> 0.
    MESSAGE E006 WITH 'SPG[' P_SPGCD
                      '] 작업권한을 확인하세요.'.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_PROC
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_PROC .

  DATA : LV_DISPO TYPE MARC-DISPO.
  DATA : LT_ABGRU TYPE RANGE OF VBAP-ABGRU.
  DATA : LV_CHK_DATE TYPE SY-DATUM.
  DATA : LV_CHK_EXCEPT.

  PERFORM GET_INIT_DATA.
  REFRESH GT_MAIN_DISP.

  IF SY-BATCH = ABAP_TRUE.
    LV_DISPO = P_SPGCD && '%'. "
* 판매오더 기준
    SELECT DISTINCT P~VBELN, P~POSNR, P~MATNR
      FROM VBAK AS K
      INNER JOIN VBAP AS P
                             ON P~VBELN = K~VBELN
      INNER JOIN MARC AS C
                             ON C~MATNR = P~MATNR
                            AND C~WERKS = P~WERKS
   WHERE K~ERDAT IN @S_ERDAT
     AND P~VBELN IN @S_VBELN
     AND P~POSNR IN @S_POSNR
     AND CONCAT( P~VBELN, P~POSNR ) NOT IN
         ( SELECT  CONCAT( VBELN, VBELP )
              FROM EBKN
            WHERE VBELN = P~VBELN
                AND VBELP = P~POSNR
                AND LOEKZ = ' ' )
          AND P~ABGRU = ''
          AND P~MATNR IN @S_MATNR
          AND C~WERKS = @P_WERKS
          AND C~DISPO LIKE @LV_DISPO
          INTO  TABLE @DATA(LT_MOSU).
    LOOP AT LT_MOSU INTO DATA(LS_MOSU).
      CLEAR GS_MAIN_DISP.
      GS_MAIN_DISP-WERKS = P_WERKS.
      GS_MAIN_DISP-NAME1 = GV_NAME1.
      GS_MAIN_DISP-SPGCD = P_SPGCD.
      GS_MAIN_DISP-DESCR = GV_DESCR.
      GS_MAIN_DISP-VBELN = LS_MOSU-VBELN.
      GS_MAIN_DISP-POSNR = LS_MOSU-POSNR.
      GS_MAIN_DISP-MATNR = LS_MOSU-MATNR.
      GS_MAIN_DISP-MAKTX = ZGTPP_CL_COMMON=>GET_MAKTX( IV_MATNR = LS_MOSU-MATNR ).

      CLEAR LV_CHK_EXCEPT.
      PERFORM GET_PRINT_DESC USING LS_MOSU-VBELN LS_MOSU-POSNR LS_MOSU-MATNR CHANGING GS_MAIN_DISP-ZPRINT_DESC LV_CHK_EXCEPT.
      IF LV_CHK_EXCEPT IS NOT INITIAL.
        CONTINUE.
      ENDIF.

      APPEND GS_MAIN_DISP TO GT_MAIN_DISP.
    ENDLOOP.

  ELSE.
    LV_DISPO = P_SPGCD && '%'. "

* 판매오더 기준
    SELECT DISTINCT P~VBELN, P~POSNR, P~MATNR,
               A~EDATU, P~CUOBJ
      FROM VBAK AS K
      INNER JOIN VBEP AS A ON A~VBELN = K~VBELN
      INNER JOIN VBAP AS P
                             ON P~VBELN = A~VBELN
                            AND P~POSNR = A~POSNR
      INNER JOIN MARC AS C
                             ON C~MATNR = P~MATNR
                            AND C~WERKS = P~WERKS
   WHERE  K~ERDAT IN @S_ERDAT
        AND A~EDATU IN @S_EDATU
        AND A~VBELN IN @S_VBELN
        AND A~POSNR IN @S_POSNR
        AND CONCAT( CONCAT( A~VBELN, A~POSNR ), A~ETENR ) IN
                              ( SELECT CONCAT( CONCAT( VBELN, POSNR ), MAX( ETENR ) )
                                  FROM VBEP
                                WHERE VBELN  = A~VBELN
                                   AND POSNR   = A~POSNR
                                   AND LIFSP = ' '
                                   AND WMENG    NE 0
                          GROUP BY VBELN, POSNR )
        AND CONCAT( P~VBELN, P~POSNR ) NOT IN
         ( SELECT  CONCAT( VBELN, POSNR )
              FROM VBEP
            WHERE VBELN = A~VBELN
                AND POSNR   = A~POSNR
                AND  ETTYP = 'CN'
                AND EDATU  = ( SELECT MAX( EDATU ) AS EDATU
                                  FROM VBEP
                              WHERE VBELN = A~VBELN
                                  AND POSNR   = A~POSNR
                         GROUP BY VBELN, POSNR ) )
*       AND CONCAT( CONCAT( P~VBELN, P~POSNR ), P~MATNR ) NOT IN
*         ( SELECT  CONCAT( CONCAT( M~VBELN, M~VBELP ), N~MATNR )
*              FROM EBKN AS M
*              INNER JOIN EBAN AS N ON N~BANFN = M~BANFN
*                        AND  N~BNFPO = M~BNFPO
*            WHERE M~VBELN = A~VBELN
*                AND M~VBELP = A~POSNR
*                AND N~LOEKZ = ' ' )
          AND P~ABGRU = ''
          AND P~MATNR IN @S_MATNR
          AND C~WERKS = @P_WERKS
          AND C~DISPO LIKE @LV_DISPO
          INTO  TABLE @DATA(LT_MAIN).

    DATA(LT_CHK_VBAP) = LT_MAIN.
    SORT LT_CHK_VBAP BY VBELN POSNR MATNR.
    IF LT_CHK_VBAP IS NOT INITIAL.
      DELETE ADJACENT DUPLICATES FROM LT_CHK_VBAP COMPARING VBELN POSNR MATNR.
      SELECT  M~VBELN, M~VBELP
        FROM EBKN AS M
        INNER JOIN EBAN AS N ON N~BANFN = M~BANFN
                            AND  N~BNFPO = M~BNFPO
        FOR ALL ENTRIES IN @LT_CHK_VBAP
       WHERE M~VBELN = @LT_CHK_VBAP-VBELN
         AND M~VBELP = @LT_CHK_VBAP-POSNR
         AND N~MATNR = @LT_CHK_VBAP-MATNR
         AND N~LOEKZ = ' '
        INTO TABLE @DATA(LT_EBKN).

      LOOP AT LT_EBKN INTO DATA(LS_EBKN).
        DELETE LT_MAIN WHERE VBELN = LS_EBKN-VBELN
                         AND POSNR = LS_EBKN-VBELP.
      ENDLOOP.

    ENDIF.

    SELECT DISTINCT B~*
      FROM @LT_MAIN AS A
      INNER JOIN ZGTPPT2230 AS B ON B~WERKS = @P_WERKS
                                          AND B~SPGCD = @P_SPGCD
                                          AND B~VBELN = A~VBELN
                                          AND B~POSNR = A~POSNR
      INTO TABLE @DATA(GT_2230).

    LOOP AT LT_MAIN INTO DATA(LS_MAIN).
      CLEAR GS_MAIN_DISP.
      GS_MAIN_DISP-WERKS = P_WERKS.
      GS_MAIN_DISP-NAME1 = GV_NAME1.
      GS_MAIN_DISP-SPGCD = P_SPGCD.
      GS_MAIN_DISP-DESCR = GV_DESCR.
      GS_MAIN_DISP-VBELN = LS_MAIN-VBELN.
      GS_MAIN_DISP-POSNR = LS_MAIN-POSNR.
      GS_MAIN_DISP-MATNR = LS_MAIN-MATNR.
      GS_MAIN_DISP-MAKTX = ZGTPP_CL_COMMON=>GET_MAKTX( IV_MATNR = LS_MAIN-MATNR ).
      GS_MAIN_DISP-EDATU = LS_MAIN-EDATU.

      CLEAR LV_CHK_EXCEPT.
      PERFORM GET_PRINT_DESC USING LS_MAIN-VBELN LS_MAIN-POSNR LS_MAIN-MATNR CHANGING GS_MAIN_DISP-ZPRINT_DESC_SO LV_CHK_EXCEPT.
      IF LV_CHK_EXCEPT IS NOT INITIAL.
        CONTINUE.
      ENDIF.

      READ TABLE GT_2230 INTO DATA(LS_2230) WITH KEY VBELN = LS_MAIN-VBELN
                                                                POSNR = LS_MAIN-POSNR.
      IF SY-SUBRC EQ 0.

        GS_MAIN_DISP-ZPRINT_DESC = LS_2230-ZPRINT_DESC.
        GS_MAIN_DISP-ZINHOUSE = LS_2230-ZINHOUSE.
        GS_MAIN_DISP-ZBILLING = LS_2230-ZBILLING.
        CASE GS_MAIN_DISP-ZBILLING.
          WHEN 'Y'.
            GS_MAIN_DISP-ZBILLING_T = '청구'.
          WHEN 'N'.
            GS_MAIN_DISP-ZBILLING_T = '미청구'.
        ENDCASE.
        GS_MAIN_DISP-ZPRINT_TYPE = LS_2230-ZPRINT_TYPE.

        IF GS_MAIN_DISP-ZPRINT_DESC NE GS_MAIN_DISP-ZPRINT_DESC_SO.
          GS_MAIN_DISP-ZPRINT_CHK = ICON_CHECKIN_REQUESTED.
        ENDIF.

      ELSE.
        GS_MAIN_DISP-ZPRINT_TYPE = 'EMBOSSING'.
        GS_MAIN_DISP-ZPRINT_DESC = GS_MAIN_DISP-ZPRINT_DESC_SO.
      ENDIF.


      APPEND GS_MAIN_DISP TO GT_MAIN_DISP.
    ENDLOOP.

    CASE ABAP_TRUE.
      WHEN P_RAD21. " 청구
        DELETE GT_MAIN_DISP WHERE ZBILLING NE 'Y'.
      WHEN P_RAD22. " 미청구
        DELETE GT_MAIN_DISP WHERE ZBILLING = 'Y'.
      WHEN P_RAD23. " 전체
    ENDCASE.


  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROC_DISP
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PROC_DISP .

  IF GT_MAIN_DISP[] IS INITIAL.
    MESSAGE S006 DISPLAY LIKE 'E' WITH '조회 결과가 없습니다.'.
  ELSE.
    IF SY-BATCH = ABAP_TRUE.
      PERFORM SEND_MAIL.
    ELSE.
      CALL SCREEN '0100'.
    ENDIF.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_INIT_SELECTION_PERIOD
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_INIT_SELECTION_PERIOD .

  IF S_EDATU[] IS NOT INITIAL.
    READ TABLE S_EDATU INDEX 1.
  ENDIF.

  REFRESH S_EDATU[].
  S_EDATU-SIGN = 'I'.
  S_EDATU-OPTION = 'BT'.
  S_EDATU-LOW = SY-DATUM+0(6) && '01'.
  S_EDATU-HIGH = S_EDATU-LOW.
  PERFORM GET_LAST_DAY_OF_MONTH CHANGING S_EDATU-HIGH.
  APPEND S_EDATU.

  REFRESH S_ERDAT[].
  S_ERDAT-SIGN = 'I'.
  S_ERDAT-OPTION = 'BT'.
  S_ERDAT-LOW = SY-DATUM - 1.
  S_ERDAT-HIGH = SY-DATUM.
  APPEND S_ERDAT.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_LAST_DAY_OF_MONTH
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- LV_LASTDATE
*&---------------------------------------------------------------------*
FORM GET_LAST_DAY_OF_MONTH  CHANGING PV_DATE TYPE SY-DATUM.

  CALL FUNCTION 'LAST_DAY_OF_MONTHS'
    EXPORTING
      DAY_IN            = PV_DATE
    IMPORTING
      LAST_DAY_OF_MONTH = PV_DATE
    EXCEPTIONS
      DAY_IN_NO_DATE    = 1
      OTHERS            = 2.
  .
  IF SY-SUBRC <> 0.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SEND_MAIL
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SEND_MAIL .

  DEFINE MAIL_MSG.
    CLEAR gs_msg.
    gs_msg = &1.
    APPEND gs_msg TO gtt_message.
  END-OF-DEFINITION.

  SELECT * FROM ZGTPPT3460
    INTO TABLE GT_3460
   WHERE CPROG = 'ZGTPPR2180'
     AND WERKS = P_WERKS
     AND SPGCD = P_SPGCD
     AND ACTIVE = 'X'.

  SORT GT_3460 BY MAIL_TYPE DESCENDING.

* 메일 제목 생성
  GV_SUBJECT = '[인쇄 롤라 관리] 자체 생산 등록 건 공유'.

* 메일본문
  MAIL_MSG : '<HTML>',
                    '<BODY>'.
  MAIL_MSG '당일 자체 생산 건으로 등록 건 오더 목록입니다.(메일 발송된 일자 기준) <BR>'.

  CLEAR GS_MSG.
  GS_MSG = |상세한 정보는 SAP 시스템 내 '인쇄 롤라 관리(ZGTPPR2180)' 기능을 확인 바랍니다. <BR><BR>|.
  APPEND GS_MSG TO GTT_MESSAGE.

* 테이블 헤더
  MAIL_MSG : '<TABLE STYLE="BORDER-COLLAPSE: COLLAPSE; TABLE-LAYOUT: FIXED; FONT-SIZE: 10PX;">',
                  '<THEAD>',
                  '<TR STYLE="BACKGROUND-COLOR: #F2F2F2; FONT-WEIGHT: BOLD;">',
                  '<TH STYLE="BORDER: 1PX SOLID #CCC; PADDING: 7PX; TEXT-ALIGN: CENTER;">플랜트</TH>',
                  '<TH STYLE="BORDER: 1PX SOLID #CCC; PADDING: 7PX; TEXT-ALIGN: CENTER;">플랜트내역</TH>',
                  '<TH STYLE="BORDER: 1PX SOLID #CCC; PADDING: 7PX; TEXT-ALIGN: CENTER;">SPG</TH>',
                  '<TH STYLE="BORDER: 1PX SOLID #CCC; PADDING: 7PX; TEXT-ALIGN: CENTER;">SPG 내역</TH>',
                  '<TH STYLE="BORDER: 1PX SOLID #CCC; PADDING: 7PX; TEXT-ALIGN: CENTER;">판매오더번호</TH>',
                  '<TH STYLE="BORDER: 1PX SOLID #CCC; PADDING: 7PX; TEXT-ALIGN: CENTER;">판매오더품목</TH>',
                  '<TH STYLE="BORDER: 1PX SOLID #CCC; PADDING: 7PX; TEXT-ALIGN: CENTER;">품목코드</TH>',
                  '<TH STYLE="BORDER: 1PX SOLID #CCC; PADDING: 7PX; TEXT-ALIGN: CENTER;">품목내역</TH>',
                  '</TR>',
                  '</THEAD>',
                  '<TBODY>'.

  LOOP AT GT_MAIN_DISP INTO DATA(LS_MAIN).
    MAIL_MSG : '<TR STYLE="BACKGROUND-COLOR: #FFFFFF;">'.
    PERFORM APPEND_HTML_FOR_LIST USING LS_MAIN-WERKS 'C'. "Plant
    PERFORM APPEND_HTML_FOR_LIST USING LS_MAIN-NAME1 'C'. "Production Order
    PERFORM APPEND_HTML_FOR_LIST USING LS_MAIN-SPGCD 'C'. "Reason
    PERFORM APPEND_HTML_FOR_LIST USING LS_MAIN-DESCR 'L'. "Material
    PERFORM APPEND_HTML_FOR_LIST USING LS_MAIN-VBELN 'C'. "Material Desc.
    PERFORM APPEND_HTML_FOR_LIST USING LS_MAIN-POSNR 'C'. "Order Qty
    PERFORM APPEND_HTML_FOR_LIST USING LS_MAIN-MATNR 'C'. "GR Qty
    PERFORM APPEND_HTML_FOR_LIST USING LS_MAIN-MAKTX 'L'. "GR Date
    MAIL_MSG : '</TR>'.
  ENDLOOP.

  MAIL_MSG: '</TBODY>',
                   '</TABLE>',
                   '</BODY>',
                   '</HTML>'.


  TRY.
      G_EMAIL = CL_BCS=>CREATE_PERSISTENT( ).

      G_EMAIL_BODY = CL_DOCUMENT_BCS=>CREATE_DOCUMENT(
                      I_TYPE    = 'HTM'
                      I_TEXT    = GTT_MESSAGE
                      I_SUBJECT = GV_SUBJECT ).

      G_EMAIL->SET_DOCUMENT( G_EMAIL_BODY ).



      LOOP AT GT_3460 INTO DATA(LS_3460).
        CLEAR G_RECEIVER.
        CLEAR GV_ADDRESS.

        GV_ADDRESS = LS_3460-MAIL_ADDR.

        G_RECEIVER =
        CL_CAM_ADDRESS_BCS=>CREATE_INTERNET_ADDRESS( GV_ADDRESS ).

        CASE LS_3460-MAIL_TYPE.
          WHEN 'TO'.
            G_EMAIL->ADD_RECIPIENT( I_RECIPIENT = G_RECEIVER
                                    I_EXPRESS   = 'X' ).
          WHEN 'CC'.
            G_EMAIL->ADD_RECIPIENT( I_RECIPIENT = G_RECEIVER
                                    I_COPY   = 'X' ).
        ENDCASE.
      ENDLOOP.
      G_EMAIL->SET_SEND_IMMEDIATELY( 'X' ).

      G_EMAIL->SEND( EXPORTING I_WITH_ERROR_SCREEN = 'X'
                     RECEIVING RESULT              = GV_SEND_RESULT ).

      COMMIT WORK.

    CATCH CX_BCS INTO G_EXCEPTION.

  ENDTRY.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_OBJECT_GRID_0100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_OBJECT_GRID_0100 .

  CREATE OBJECT GO_CONTAIN_0100
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

  CREATE OBJECT GO_GRID_0100
    EXPORTING
      I_PARENT      = GO_CONTAIN_0100
      I_APPL_EVENTS = ABAP_TRUE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_LAYOUT_GRID_0100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_LAYOUT_GRID_0100 .

  CLEAR GS_LAYOUT_0100.
  GS_LAYOUT_0100-CWIDTH_OPT = ABAP_TRUE.
  GS_LAYOUT_0100-NO_ROWINS = ABAP_TRUE.
  GS_LAYOUT_0100-SEL_MODE   = 'D'.
  GS_LAYOUT_0100-STYLEFNAME   = 'CELLTAB'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_FIELDCAT_GRID_0100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_FIELDCAT_GRID_0100 .

  DATA : LT_FCAT_SLIS TYPE SLIS_T_FIELDCAT_ALV.
  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      I_PROGRAM_NAME         = SY-REPID
      I_INCLNAME             = 'ZGTPPR2180TOP'
      I_INTERNAL_TABNAME     = 'GS_MAIN_DISP'
    CHANGING
      CT_FIELDCAT            = LT_FCAT_SLIS
    EXCEPTIONS
      INCONSISTENT_INTERFACE = 1
      PROGRAM_ERROR          = 2
      OTHERS                 = 3.

  REFRESH GT_FIELDCAT_0100.

*-- lt_fieldcat의 구조체를 pt_fcat의 구조체로 변경
  CALL FUNCTION 'LVC_TRANSFER_FROM_SLIS'
    EXPORTING
      IT_FIELDCAT_ALV = LT_FCAT_SLIS
    IMPORTING
      ET_FIELDCAT_LVC = GT_FIELDCAT_0100[]
    TABLES
      IT_DATA         = GT_MAIN_DISP
    EXCEPTIONS
      OTHERS          = 1.

  READ TABLE GT_FIELDCAT_0100 ASSIGNING FIELD-SYMBOL(<LS_FCAT>) WITH KEY FIELDNAME = 'ZBILLING_T'.
  IF SY-SUBRC NE 0.
    APPEND INITIAL LINE TO GT_FIELDCAT_0100 ASSIGNING <LS_FCAT>.

    <LS_FCAT>-FIELDNAME = 'ZBILLING_T'.
    <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '청구구분'(F10).
    <LS_FCAT>-COL_POS = 13.
    <LS_FCAT>-DATATYPE = 'CHAR'.
    <LS_FCAT>-DD_OUTLEN = '10'.
    <LS_FCAT>-JUST = 'C'.
    <LS_FCAT>-DRDN_HNDL = '2'.
    <LS_FCAT>-EDIT = ABAP_TRUE.

  ENDIF.


  LOOP AT GT_FIELDCAT_0100 ASSIGNING <LS_FCAT>.
    CLEAR <LS_FCAT>-KEY.
    CASE   <LS_FCAT>-FIELDNAME.
      WHEN 'ZBILLING'.
        <LS_FCAT>-NO_OUT = ABAP_TRUE.
      WHEN 'WERKS'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '플랜트'(F01).
        <LS_FCAT>-JUST = 'C'.
      WHEN 'NAME1'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '플랜트 내역'(F02).
        <LS_FCAT>-JUST = 'L'.
      WHEN 'SPGCD'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = 'SPG'(F03).
        <LS_FCAT>-JUST = 'C'.
      WHEN 'DESCR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = 'SPG 내역'(F04).
        <LS_FCAT>-JUST = 'L'.
      WHEN 'VBELN'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '판매오더번호'(F11).
        <LS_FCAT>-JUST = 'C'.
      WHEN 'POSNR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '판매오더품목'(F12).
        <LS_FCAT>-JUST = 'C'.
      WHEN 'MATNR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '품목코드'(F13).
        <LS_FCAT>-JUST = 'C'.
      WHEN 'MAKTX'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '품목내역'(F14).
        <LS_FCAT>-JUST = 'L'.
      WHEN 'EDATU'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '납품요청일자'(F15).
        <LS_FCAT>-JUST = 'C'.
      WHEN 'ZINHOUSE'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '자체생산'(F16).
        <LS_FCAT>-JUST = 'C'.
        <LS_FCAT>-DRDN_HNDL = '1'.
        <LS_FCAT>-EDIT = ABAP_TRUE.
      WHEN 'ZPRINT_DESC'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '인쇄내역'(F17).
        <LS_FCAT>-JUST = 'L'.
        <LS_FCAT>-LOWERCASE = ABAP_TRUE.
        <LS_FCAT>-EDIT = ABAP_TRUE.
      WHEN 'ZPRINT_CHK'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '인쇄내역변경'(F19).
        <LS_FCAT>-JUST = 'C'.
        <LS_FCAT>-ICON = ABAP_TRUE.
        <LS_FCAT>-HOTSPOT = ABAP_TRUE.
      WHEN 'ZPRINT_TYPE'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '인쇄방법'(F18).
        <LS_FCAT>-JUST = 'L'.
        <LS_FCAT>-EDIT = ABAP_TRUE.
      WHEN 'ZPRINT_DESC_SO'.
        <LS_FCAT>-NO_OUT = ABAP_TRUE.
    ENDCASE.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_DROPDOWN_GRID_0100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_DROPDOWN_GRID_0100 .

  DATA: LT_DRAL TYPE LVC_T_DRAL,                            "#EC NEEDED
        LS_DRAL TYPE LVC_S_DRAL.                            "#EC NEEDED

  LS_DRAL-HANDLE = '1'.
  LS_DRAL-INT_VALUE = ''.
  LS_DRAL-VALUE = 'Y'.
  APPEND LS_DRAL TO LT_DRAL.

  LS_DRAL-HANDLE = '1'.
  LS_DRAL-INT_VALUE = ''.
  LS_DRAL-VALUE = 'N'.
  APPEND LS_DRAL TO LT_DRAL.

  LS_DRAL-HANDLE = '1'.
  LS_DRAL-INT_VALUE = ' '.
  LS_DRAL-VALUE = ' '.
  APPEND LS_DRAL TO LT_DRAL.


  LS_DRAL-HANDLE = '2'.
  LS_DRAL-INT_VALUE = ''.
  LS_DRAL-VALUE = '청구'.
  APPEND LS_DRAL TO LT_DRAL.

  LS_DRAL-HANDLE = '2'.
  LS_DRAL-INT_VALUE = ''.
  LS_DRAL-VALUE = '미청구'.
  APPEND LS_DRAL TO LT_DRAL.

  LS_DRAL-HANDLE = '2'.
  LS_DRAL-INT_VALUE = ''.
  LS_DRAL-VALUE = ''.
  APPEND LS_DRAL TO LT_DRAL.

  GO_GRID_0100->SET_DROP_DOWN_TABLE(
    IT_DROP_DOWN_ALIAS = LT_DRAL ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form EXCLUDE_OF_TOOLBAR_GRID_0100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM EXCLUDE_OF_TOOLBAR_GRID_0100 .

  PERFORM ADD_EXCLUDE_TOOLBAR_BUTTON TABLES GT_EXCLUDE_0100
        USING : CL_GUI_ALV_GRID=>MC_FC_LOC_UNDO,
                CL_GUI_ALV_GRID=>MC_FC_AUF,
                CL_GUI_ALV_GRID=>MC_FC_CHECK,
                CL_GUI_ALV_GRID=>MC_FC_LOC_PASTE,
                CL_GUI_ALV_GRID=>MC_FC_LOC_COPY,
                CL_GUI_ALV_GRID=>MC_FC_AVERAGE,
                CL_GUI_ALV_GRID=>MC_FC_GRAPH,
                CL_GUI_ALV_GRID=>MC_FC_INFO,
                CL_GUI_ALV_GRID=>MC_FC_LOC_COPY_ROW,
                CL_GUI_ALV_GRID=>MC_FC_LOC_CUT,
                CL_GUI_ALV_GRID=>MC_FC_LOC_DELETE_ROW,
                CL_GUI_ALV_GRID=>MC_FC_LOC_INSERT_ROW,
                CL_GUI_ALV_GRID=>MC_FC_LOC_APPEND_ROW,
                CL_GUI_ALV_GRID=>MC_FC_LOC_PASTE,
                CL_GUI_ALV_GRID=>MC_FC_LOC_PASTE_NEW_ROW,
                CL_GUI_ALV_GRID=>MC_FC_REFRESH.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CALL_GRID_0100_DISPLAY
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CALL_GRID_0100_DISPLAY .

  CALL METHOD GO_GRID_0100->SET_TABLE_FOR_FIRST_DISPLAY
    EXPORTING
      IS_LAYOUT            = GS_LAYOUT_0100
      IT_TOOLBAR_EXCLUDING = GT_EXCLUDE_0100
    CHANGING
      IT_OUTTAB            = GT_MAIN_DISP
      IT_FIELDCATALOG      = GT_FIELDCAT_0100.

* 인풋이벤트 추가
  CALL METHOD GO_GRID_0100->REGISTER_EDIT_EVENT
    EXPORTING
      I_EVENT_ID = CL_GUI_ALV_GRID=>MC_EVT_ENTER.

  CALL METHOD GO_GRID_0100->REGISTER_EDIT_EVENT
    EXPORTING
      I_EVENT_ID = CL_GUI_ALV_GRID=>MC_EVT_MODIFIED.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROC_SAVE_0100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PROC_SAVE_0100 .

  DATA : LT_ROWS TYPE LVC_T_ROW.
  DATA : LT_MODI_2230 TYPE TABLE OF ZGTPPT2230.

  GO_GRID_0100->GET_SELECTED_ROWS(
    IMPORTING
      ET_INDEX_ROWS = LT_ROWS ).                " Indexes of Selected Rows
*      ET_ROW_NO     =                  " Numeric IDs of Selected Rows

  DELETE LT_ROWS WHERE INDEX = 0.

  IF LT_ROWS[] IS INITIAL.
    MESSAGE S006 DISPLAY LIKE 'E' WITH '저장할 레코드를 선택하세요.'(E09).
    RETURN.
  ENDIF.

  LOOP AT LT_ROWS INTO DATA(LS_ROWS).
    READ TABLE GT_MAIN_DISP INTO DATA(LS_MAIN) INDEX LS_ROWS-INDEX.
    IF SY-SUBRC EQ 0.
      APPEND INITIAL LINE TO LT_MODI_2230 ASSIGNING FIELD-SYMBOL(<LS_MODI_2230>).
      MOVE-CORRESPONDING LS_MAIN TO <LS_MODI_2230>.
      READ TABLE GT_2230 INTO DATA(LS_2230) WITH KEY VBELN = <LS_MODI_2230>-VBELN
                                                                  POSNR = <LS_MODI_2230>-POSNR.
      IF SY-SUBRC EQ 0.
        MOVE : LS_2230-CRDAT TO <LS_MODI_2230>-CRDAT,
                LS_2230-CRTIM TO <LS_MODI_2230>-CRTIM,
                LS_2230-CRNAM TO <LS_MODI_2230>-CRNAM,
                SY-DATUM TO <LS_MODI_2230>-CHDAT,
                SY-UZEIT TO <LS_MODI_2230>-CHTIM,
                SY-UNAME TO <LS_MODI_2230>-CHNAM.
      ELSE.
        MOVE : SY-DATUM TO <LS_MODI_2230>-CRDAT,
                  SY-UZEIT TO <LS_MODI_2230>-CRTIM,
                  SY-UNAME TO <LS_MODI_2230>-CRNAM,
                  SY-DATUM TO <LS_MODI_2230>-CHDAT,
                  SY-UZEIT TO <LS_MODI_2230>-CHTIM,
                  SY-UNAME TO <LS_MODI_2230>-CHNAM.
      ENDIF.
    ENDIF.
  ENDLOOP.


  CLEAR GV_ANSWER.
  PERFORM POPUP_TO_CONFIRM_STEP USING 'N'
    ' '
    '데이터 저장을 진행하시겠습니까?'
    '저장확인'.
  IF GV_ANSWER NE 'J'.
    MESSAGE S003 DISPLAY LIKE 'E' WITH '작업이 취소 되었습니다.'.
    RETURN.
  ENDIF.

  IF LT_MODI_2230[] IS NOT INITIAL.
    MODIFY ZGTPPT2230 FROM TABLE LT_MODI_2230.
    COMMIT WORK AND WAIT.
  ENDIF.

  MESSAGE S003  WITH '데이터 저장되었습니다.'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form APPEND_HTML_FOR_LIST
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_AFKO3_WERKS
*&      --> P_
*&---------------------------------------------------------------------*
FORM APPEND_HTML_FOR_LIST  USING   PV_VALUE PV_SIGN.

  DATA : LV_MAIN(30),
         LV_LEFT(16),
         LV_RIGHT(6),
         LV_LEFT2(16),
         LV_RIGHT2(6).
  DATA : LV_MENGE TYPE STRING.

  IF PV_SIGN = 'C'.
    CONCATENATE
    '<TD STYLE="BORDER: 1PX SOLID #CCC; PADDING: 7PX; TEXT-ALIGN: CENTER;">'
    PV_VALUE '</TD>' INTO GS_MSG SEPARATED BY SPACE.
  ELSEIF PV_SIGN = 'L'.
    CONCATENATE
    '<TD STYLE="BORDER: 1PX SOLID #CCC; PADDING: 7PX; TEXT-ALIGN: LEFT;">'
    PV_VALUE '</TD>' INTO GS_MSG SEPARATED BY SPACE.
  ELSEIF PV_SIGN = 'R'.
    CLEAR : LV_MAIN, LV_LEFT, LV_RIGHT, LV_LEFT2, LV_RIGHT2, LV_MENGE.
    LV_MENGE = PV_VALUE.
    CALL FUNCTION 'BUX_DECIMAL_START'
      EXPORTING
        I_VALUE_DB   = LV_MENGE
      IMPORTING
        E_VALUE_DYNP = LV_MAIN.
    SPLIT LV_MAIN AT '.' INTO LV_LEFT LV_RIGHT.
    IF LV_RIGHT IS INITIAL.
      SPLIT LV_MENGE AT '.' INTO LV_LEFT2 LV_RIGHT2.
      CONCATENATE LV_LEFT '.' LV_RIGHT2 INTO GV_TEXT2.
    ELSE.
      GV_TEXT2 = LV_MAIN.
    ENDIF.
    CONDENSE GV_TEXT2 NO-GAPS.
    CONCATENATE
    '<TD STYLE="BORDER: 1PX SOLID #CCC; PADDING: 7PX; TEXT-ALIGN: RIGHT;">'
    GV_TEXT2 '</TD>' INTO GS_MSG SEPARATED BY SPACE.
  ENDIF.

  APPEND GS_MSG TO GTT_MESSAGE.
  CLEAR : GS_MSG, GV_TEXT2.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_PRINT_DESC
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LS_MAIN_VBELN
*&      --> LS_MAIN_POSNR
*&      --> LS_MAIN_MATNR
*&      <-- GS_MAIN_DISP_ZPRINT_DESC
*&---------------------------------------------------------------------*
FORM GET_PRINT_DESC  USING    PV_VBELN TYPE VBAP-VBELN
                              PV_POSNR TYPE VBAP-POSNR
                              PV_MATNR TYPE MARA-MATNR
                     CHANGING PV_ZPRINT_DESC TYPE ZGTPPT2230-ZPRINT_DESC
                       PV_CHK_EXCEPT.

  DATA : LV_COUBJ TYPE CUOBJ_VA.
  DATA : LV_BCOS_TSTMP TYPE BCOS_TSTMP.
  DATA : LV_VALUE TYPE CHAR30.
  DATA : LV_IDX TYPE I.
  DATA : BEGIN OF LS_CONV_CHARNAME,
           ATNAM TYPE CABN-ATNAM,
           ATINN TYPE CABN-ATINN,
         END OF LS_CONV_CHARNAME.
  STATICS : LT_CONV_CHARNAME LIKE TABLE OF LS_CONV_CHARNAME.
  DATA : LV_TABIX TYPE I.
  DATA : LV_ATINN TYPE ATINN.

  DEFINE __GET_ATINN.
    CLEAR LS_CONV_CHARNAME.
    READ TABLE LT_CONV_CHARNAME INTO LS_CONV_CHARNAME WITH KEY ATNAM = CONV #( &1 ) BINARY SEARCH.
    IF SY-SUBRC EQ 0.
      &2 = LS_CONV_CHARNAME-ATINN.
    ELSE.
      LV_TABIX = SY-TABIX.
      LS_CONV_CHARNAME-ATNAM = &1.
      CALL FUNCTION 'CONVERSION_EXIT_ATINN_INPUT'
        EXPORTING
          INPUT  = LS_CONV_CHARNAME-ATNAM
        IMPORTING
          OUTPUT = LS_CONV_CHARNAME-ATINN.

      INSERT LS_CONV_CHARNAME INTO  LT_CONV_CHARNAME INDEX LV_TABIX.
      &2 = LS_CONV_CHARNAME-ATINN.
    ENDIF.
  END-OF-DEFINITION.


  GET TIME STAMP FIELD LV_BCOS_TSTMP.


* 1)   판매주문의 "마킹내용(1)~마킹내용(10)" 속성 발췌
  SELECT SINGLE CUOBJ
   INTO LV_COUBJ
   FROM VBAP
 WHERE VBELN = PV_VBELN
    AND POSNR = PV_POSNR.

  IF LV_COUBJ IS INITIAL.
    PV_CHK_EXCEPT = ABAP_TRUE.
    RETURN.
  ENDIF.

* 판매오더로 특성정보 가져오기
  REFRESH GT_CHART.
  SELECT B~*
    INTO  TABLE @GT_CHART
    FROM IBIN AS A
    INNER JOIN V_IBIN_SYVAL AS B ON B~IN_RECNO = A~IN_RECNO
   WHERE A~INSTANCE = @LV_COUBJ
     AND A~VALFR <= @LV_BCOS_TSTMP
     AND A~VALTO > @LV_BCOS_TSTMP .

  __GET_ATINN 'PD_GA_PRINT_METHOD' LV_ATINN.
  READ TABLE GT_CHART INTO DATA(LS_CHAR) WITH KEY ATINN = LV_ATINN.
  IF SY-SUBRC EQ 0 AND LS_CHAR-ATWRT = 'EMBOSSING'.
  ELSE.
    PV_CHK_EXCEPT = ABAP_TRUE.
    RETURN.
  ENDIF.

*  PERFORM GET_CHART_VALUE_CONTENTS USING '1ST' CHANGING PV_ZPRINT_DESC.
  PERFORM GET_CHART_VALUE_CONTENTS USING '1ST' CHANGING PV_ZPRINT_DESC.
  PERFORM GET_CHART_VALUE_CONTENTS USING '2ND' CHANGING PV_ZPRINT_DESC.
  PERFORM GET_CHART_VALUE_CONTENTS USING '3RD' CHANGING PV_ZPRINT_DESC.
  PERFORM GET_CHART_VALUE_CONTENTS USING '4TH' CHANGING PV_ZPRINT_DESC.
  PERFORM GET_CHART_VALUE_CONTENTS USING '5TH' CHANGING PV_ZPRINT_DESC.
  PERFORM GET_CHART_VALUE_CONTENTS USING '6TH' CHANGING PV_ZPRINT_DESC.
  PERFORM GET_CHART_VALUE_CONTENTS USING '7TH' CHANGING PV_ZPRINT_DESC.
  PERFORM GET_CHART_VALUE_CONTENTS USING '8TH' CHANGING PV_ZPRINT_DESC.
  PERFORM GET_CHART_VALUE_CONTENTS USING '9TH' CHANGING PV_ZPRINT_DESC.
  PERFORM GET_CHART_VALUE_CONTENTS USING '10TH' CHANGING PV_ZPRINT_DESC.

  IF PV_ZPRINT_DESC IS NOT INITIAL.
    RETURN.
  ENDIF.

* 2) 위 주문에  마킹내용 정보가 비어 있을 경우 설계서의 마킹 내용을 추가 추출
  SELECT SINGLE * FROM ZGTCVMSTVAL
    INTO @DATA(LS_MATVAL)
   WHERE WERKS = @P_WERKS
     AND MATNR = @PV_MATNR.

  SELECT DISTINCT * FROM ZEDT1030
    INTO TABLE @DATA(LT_1030)
   WHERE SUL_NO = @LS_MATVAL-PDCADESIGNNO
      AND REV_SEQ = @LS_MATVAL-PDCADESIGNREVNO
      AND ATTRIBUTE LIKE '%COCTENTS%'.

  SORT LT_1030 BY ATTRIBUTE.

  LOOP AT LT_1030 INTO DATA(LS_1030).
    PV_ZPRINT_DESC = PV_ZPRINT_DESC && LS_1030-DATA_CHAR.
  ENDLOOP.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_CHART_VALUE_CONTENTS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      <-- PV_ZPRINT_DESC
*&---------------------------------------------------------------------*
FORM GET_CHART_VALUE_CONTENTS  USING    PV_TAIL
                               CHANGING  PV_ZPRINT_DESC TYPE ZGTPPT2230-ZPRINT_DESC.

  DATA : LV_ATNAM(30).
  DATA : LV_ATINN TYPE ATINN.
  DATA : BEGIN OF LS_CONV_CHARNAME,
           ATNAM TYPE CABN-ATNAM,
           ATINN TYPE CABN-ATINN,
         END OF LS_CONV_CHARNAME.
  STATICS : LT_CONV_CHARNAME LIKE TABLE OF LS_CONV_CHARNAME.
  DATA : LV_TABIX TYPE I.
  CONSTANTS : LC_CONTENTS(30) VALUE 'PD_CA_MARK_CONTENTS_'.

  DEFINE __GET_ATINN.
    CLEAR LS_CONV_CHARNAME.
    READ TABLE LT_CONV_CHARNAME INTO LS_CONV_CHARNAME WITH KEY ATNAM = CONV #( &1 ) BINARY SEARCH.
    IF SY-SUBRC EQ 0.
      &2 = LS_CONV_CHARNAME-ATINN.
    ELSE.
      LV_TABIX = SY-TABIX.
      LS_CONV_CHARNAME-ATNAM = &1.
      CALL FUNCTION 'CONVERSION_EXIT_ATINN_INPUT'
        EXPORTING
          INPUT  = LS_CONV_CHARNAME-ATNAM
        IMPORTING
          OUTPUT = LS_CONV_CHARNAME-ATINN.

      INSERT LS_CONV_CHARNAME INTO  LT_CONV_CHARNAME INDEX LV_TABIX.
      &2 = LS_CONV_CHARNAME-ATINN.
    ENDIF.
  END-OF-DEFINITION.

  LV_ATNAM = LC_CONTENTS && PV_TAIL.

  __GET_ATINN LV_ATNAM LV_ATINN.

  CHECK LV_ATINN IS NOT INITIAL.

  READ TABLE GT_CHART INTO DATA(LS_CHAR) WITH KEY ATINN = LV_ATINN.
  IF SY-SUBRC EQ 0.
    IF PV_ZPRINT_DESC IS INITIAL.
      PV_ZPRINT_DESC = LS_CHAR-ATWRT.
    ELSE.
      CONCATENATE PV_ZPRINT_DESC LS_CHAR-ATWRT INTO PV_ZPRINT_DESC. " SEPARATED BY '  '.
    ENDIF.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROC_CHG_ZINHOUSE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PROC_CHG_ZINHOUSE .

  DATA : LT_ROWS TYPE LVC_T_ROW.

  GO_GRID_0100->GET_SELECTED_ROWS(
    IMPORTING
      ET_INDEX_ROWS = LT_ROWS ).                " Indexes of Selected Rows
*      ET_ROW_NO     =                  " Numeric IDs of Selected Rows

  DELETE LT_ROWS WHERE INDEX = 0.

  IF LT_ROWS[] IS INITIAL.
    MESSAGE S006 DISPLAY LIKE 'E' WITH '일괄 변경할 레코드를 선택하세요.'(E10).
    RETURN.
  ENDIF.

  CLEAR GV_ZINHOUSE.
*  자체 생산
  GV_ZINHOUSE = '자체 생산'.
  CALL SCREEN '0300' STARTING AT 5 5 ENDING AT 60 8.

  LOOP AT LT_ROWS INTO DATA(LS_ROW).
    READ TABLE GT_MAIN_DISP ASSIGNING FIELD-SYMBOL(<LS_MAIN>) INDEX LS_ROW-INDEX.
    CASE GV_ZINHOUSE.
      WHEN '자체 생산'.
        <LS_MAIN>-ZINHOUSE = 'Y'.
*        <LS_MAIN>-ZPRINT_DESC = GV_ZINHOUSE.
      WHEN '외주 생산'.
        <LS_MAIN>-ZINHOUSE = 'N'.
      WHEN OTHERS.
        CLEAR <LS_MAIN>-ZINHOUSE.
    ENDCASE.
  ENDLOOP.

  PERFORM REFRESH_GRID USING GO_GRID_0100.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROC_CHG_ZBILLING
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PROC_CHG_ZBILLING .

  DATA : LT_ROWS TYPE LVC_T_ROW.

  GO_GRID_0100->GET_SELECTED_ROWS(
    IMPORTING
      ET_INDEX_ROWS = LT_ROWS ).                " Indexes of Selected Rows
*      ET_ROW_NO     =                  " Numeric IDs of Selected Rows

  DELETE LT_ROWS WHERE INDEX = 0.

  IF LT_ROWS[] IS INITIAL.
    MESSAGE S006 DISPLAY LIKE 'E' WITH '일괄 변경할 레코드를 선택하세요.'(E10).
    RETURN.
  ENDIF.

  CLEAR GV_ZBILLING.
*  청구
  GV_ZBILLING = '청구'.
  CALL SCREEN '0400' STARTING AT 5 5 ENDING AT 60 8.

  LOOP AT LT_ROWS INTO DATA(LS_ROW).
    READ TABLE GT_MAIN_DISP ASSIGNING FIELD-SYMBOL(<LS_MAIN>) INDEX LS_ROW-INDEX.
    CASE GV_ZBILLING.
      WHEN '청구'.
        <LS_MAIN>-ZBILLING = 'Y'.
        <LS_MAIN>-ZBILLING_T = GV_ZBILLING.
      WHEN '미청구'.
        <LS_MAIN>-ZBILLING = 'N'.
        <LS_MAIN>-ZBILLING_T = GV_ZBILLING.
      WHEN OTHERS.
        CLEAR <LS_MAIN>-ZBILLING .
        CLEAR <LS_MAIN>-ZBILLING_T .
    ENDCASE.
  ENDLOOP.

  PERFORM REFRESH_GRID USING GO_GRID_0100.

ENDFORM.
*&---------------------------------------------------------------------*
*& Module STATUS_0300 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE STATUS_0300 OUTPUT.
  SET PF-STATUS '0300'.
  SET TITLEBAR '0300'.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module INIT_0300 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE INIT_0300 OUTPUT.
  PERFORM SET_DROP_DOWN_ZINHOUSE.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Form SET_DROP_DOWN_ZINHOUSE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_DROP_DOWN_ZINHOUSE .

  DATA: LT_LIST TYPE VRM_VALUES,
        LS_LIST TYPE VRM_VALUE.

  REFRESH LT_LIST.

  LS_LIST-KEY = '자체 생산'.
  APPEND LS_LIST TO LT_LIST.
  LS_LIST-KEY = '외주 생산'.
  APPEND LS_LIST TO LT_LIST.

  CALL FUNCTION 'VRM_SET_VALUES'
    EXPORTING
      ID     = 'GV_ZINHOUSE'
      VALUES = LT_LIST.


ENDFORM.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0300  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0300 INPUT.

  CLEAR GV_OK_CODE3.
  GV_OK_CODE3 = SY-UCOMM.

  CASE GV_OK_CODE3.
    WHEN 'BACK' OR 'EXIT' OR 'CANC'.
      CLEAR GV_ZINHOUSE.
      LEAVE TO SCREEN 0.
    WHEN 'CONFIRM'.
      LEAVE TO SCREEN 0.

  ENDCASE.

ENDMODULE.
*&---------------------------------------------------------------------*
*& Form SET_DROP_DOWN_ZBILLING
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_DROP_DOWN_ZBILLING .

  DATA: LT_LIST TYPE VRM_VALUES,
        LS_LIST TYPE VRM_VALUE.

  REFRESH LT_LIST.

  LS_LIST-KEY = '청구'.
  APPEND LS_LIST TO LT_LIST.
  LS_LIST-KEY = '미청구'.
  APPEND LS_LIST TO LT_LIST.

  CALL FUNCTION 'VRM_SET_VALUES'
    EXPORTING
      ID     = 'GV_ZBILLING'
      VALUES = LT_LIST.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_CELL_ATTRIBUTE_GRID_0100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_CELL_ATTRIBUTE_GRID_0100 .

  DATA : LT_CELLTAB TYPE LVC_T_STYL.
  DATA : LS_CELLTAB TYPE LVC_S_STYL.

  LOOP AT GT_MAIN_DISP ASSIGNING FIELD-SYMBOL(<LS_MAIN>).
    REFRESH LT_CELLTAB.
    IF <LS_MAIN>-ZPRINT_CHK IS NOT INITIAL.
      CLEAR LS_CELLTAB.
      LS_CELLTAB-FIELDNAME = 'ZPRINT_CHK'.
      LS_CELLTAB-STYLE = CL_GUI_ALV_GRID=>MC_STYLE_HOTSPOT.
      INSERT LS_CELLTAB INTO TABLE LT_CELLTAB.
    ENDIF.

    REFRESH <LS_MAIN>-CELLTAB.
    IF LT_CELLTAB IS NOT INITIAL.
      MOVE-CORRESPONDING LT_CELLTAB TO <LS_MAIN>-CELLTAB.
    ENDIF.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form HOTSPOT_CLICK
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> SENDER
*&      --> E_ROW_ID
*&      --> E_COLUMN_ID
*&---------------------------------------------------------------------*
FORM HOTSPOT_CLICK  USING    PO_SENDER TYPE REF TO CL_GUI_ALV_GRID
                             PS_ROW TYPE LVC_S_ROW
                             PS_COLUMN TYPE LVC_S_COL.

  CASE PO_SENDER.
    WHEN GO_GRID_0100.
      CASE PS_COLUMN-FIELDNAME.
        WHEN 'ZPRINT_CHK'.
          READ TABLE GT_MAIN_DISP ASSIGNING FIELD-SYMBOL(<LS_MAIN>) INDEX PS_ROW-INDEX.
          IF <LS_MAIN>-ZPRINT_CHK IS NOT INITIAL.
            CLEAR GV_ZPRINT_DESC.
            GV_ZPRINT_DESC = <LS_MAIN>-ZPRINT_DESC_SO.
            CALL SCREEN '0500' STARTING AT 5 5.
            IF GV_ZPRINT_DESC IS NOT INITIAL.
              CLEAR <LS_MAIN>-ZPRINT_CHK.
              <LS_MAIN>-ZPRINT_DESC = <LS_MAIN>-ZPRINT_DESC_SO.

              PERFORM REFRESH_GRID USING GO_GRID_0100.

            ENDIF.
          ENDIF.
      ENDCASE.
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0500  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0500 INPUT.

  CLEAR GV_OK_CODE5.
  GV_OK_CODE5 = SY-UCOMM.

  CASE GV_OK_CODE5.
    WHEN 'BACK' OR 'EXIT' OR 'CANC' OR 'CLOSE'.
      CLEAR GV_ZPRINT_DESC.
      LEAVE TO SCREEN 0.
    WHEN 'SET'.
      LEAVE TO SCREEN 0.
  ENDCASE.

ENDMODULE.
