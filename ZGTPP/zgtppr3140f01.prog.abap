*&---------------------------------------------------------------------*
*& Include          ZGTPPR3140F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form INITIALIZATION
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM INITIALIZATION .



ENDFORM.
*&---------------------------------------------------------------------*
*& Form MODIFY_FIRST_SCREEN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM MODIFY_FIRST_SCREEN .

  LOOP AT SCREEN.

    IF SCREEN-GROUP1 = 'A1'.
      SCREEN-INPUT = 0.
*      SCREEN-INTENSIFIED = 1.
      MODIFY SCREEN.
    ENDIF.

    IF SCREEN-GROUP1 = 'A2'.
      SCREEN-INTENSIFIED = 1.
      MODIFY SCREEN.
    ENDIF.

    CASE SCREEN-NAME.
      WHEN 'P_DESC' OR 'P_DAY'.
        SCREEN-INTENSIFIED = 1.
        MODIFY SCREEN.
    ENDCASE.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_PARAMETER_DESCRIPTION
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_PARAMETER_DESCRIPTION .

  CLEAR P_DESC.
  CLEAR P_DAY.
  IF S_IFLIST-LOW IS NOT INITIAL.
    IF GT_IFLIST_ITEM[] IS INITIAL.
      SELECT FLD_01,
                 FLD_02,
                 FLD_13
          FROM ZGTPPT1010
        WHERE MODULE_KIND = @P_KIND
          AND CODEGRP = @P_CODE_G
         INTO CORRESPONDING FIELDS OF TABLE @GT_IFLIST_ITEM.
    ENDIF.
    CLEAR GS_IFLIST_ITEM.
    READ TABLE GT_IFLIST_ITEM INTO GS_IFLIST_ITEM WITH KEY FLD_01 = S_IFLIST-LOW.
    IF SY-SUBRC EQ 0.
      P_DESC = GS_IFLIST_ITEM-FLD_02.
      P_DAY = GS_IFLIST_ITEM-FLD_13.
    ENDIF.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form F4_MODULE_KIND
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&---------------------------------------------------------------------*
FORM F4_MODULE_KIND  USING  PV_DYNPROFLD TYPE HELP_INFO-DYNPROFLD .

  DATA : LV_NUM(3) TYPE N.
  DATA : LT_RETURN_TAB TYPE TABLE OF DDSHRETVAL,
         LS_RETURN_TAB LIKE LINE OF LT_RETURN_TAB.

  DATA : LO_FLIEF TYPE REF TO DATA.
  DATA : LV_OFFSET(6) TYPE N.

  DATA : LT_FIELD_TAB TYPE TABLE OF DFIES.
  DATA : LO_STRUCTDESCR TYPE REF TO CL_ABAP_STRUCTDESCR.

  DATA : LV_LINE       LIKE SY-STEPL,
         LT_DYNPFIELDS LIKE TABLE OF DYNPREAD.

  DATA : LV_WINDOW_TITLE(100).

  REFRESH GT_IFLIST_MASTER.

  SELECT FLD_01 AS MODULE_KIND,
             FLD_02 AS CODEGRP,
             FLD_03 AS DESC
    INTO CORRESPONDING FIELDS OF TABLE @GT_IFLIST_MASTER
    FROM ZGTPPT1010
    WHERE MODULE_KIND = 'CM'
      AND CODEGRP = '0010'.

* 속성필드 정의
  FREE LO_FLIEF.
  CREATE DATA LO_FLIEF LIKE GS_IFLIST_MASTER.

  LO_STRUCTDESCR ?= CL_ABAP_STRUCTDESCR=>DESCRIBE_BY_DATA_REF( LO_FLIEF ).
  LT_FIELD_TAB = CL_SALV_DATA_DESCR=>READ_STRUCTDESCR( LO_STRUCTDESCR ).

  LOOP AT LT_FIELD_TAB  ASSIGNING FIELD-SYMBOL(<LS_FIELD_TAB>).
    CASE <LS_FIELD_TAB>-FIELDNAME.
      WHEN 'SEQNO'.
*        <LS_FIELD_TAB>-REPTEXT  = '시뮬레이션명'.
      WHEN 'MODULE_KIND'.
        <LS_FIELD_TAB>-REPTEXT  = '모듈 코드'.
      WHEN 'CODEGRP'.
        <LS_FIELD_TAB>-REPTEXT  = '코드 그룹'.
      WHEN 'DESC'.
        <LS_FIELD_TAB>-REPTEXT  = '내역'.
    ENDCASE.

    <LS_FIELD_TAB>-OFFSET = LV_OFFSET.
    LV_OFFSET = LV_OFFSET + <LS_FIELD_TAB>-INTLEN.

  ENDLOOP.

  CASE PV_DYNPROFLD.
    WHEN 'P_KIND'.
      LV_WINDOW_TITLE = '모듈 코드'.
    WHEN 'P_CODE_G'.
      LV_WINDOW_TITLE = '코드 그룹'.
      PERFORM GET_DYNP_VALUE USING 'P_KIND'.
      IF P_KIND IS NOT INITIAL.
        DELETE GT_IFLIST_MASTER WHERE MODULE_KIND NE P_KIND.
      ENDIF.
  ENDCASE.

  SORT GT_IFLIST_MASTER BY MODULE_KIND CODEGRP.
  CLEAR LV_NUM.
  LOOP AT GT_IFLIST_MASTER ASSIGNING FIELD-SYMBOL(<LS_DATA>).
    ADD 1 TO LV_NUM.
    <LS_DATA>-SEQNO = LV_NUM.
  ENDLOOP.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'  "F4 창 띄움
    EXPORTING
      RETFIELD        = 'SEQNO'
      DYNPROFIELD     = PV_DYNPROFLD           "F4누른 필드->DEPT_CD
      VALUE_ORG       = 'S'                      "가져오는 엔트리가 다수일 경우인 것 같음. 다수일 경우 C로 하면 F4 안뜸
      WINDOW_TITLE    = LV_WINDOW_TITLE   "Search Help 타이틀
      DISPLAY         = 'F'
    TABLES
      FIELD_TAB       = LT_FIELD_TAB
      VALUE_TAB       = GT_IFLIST_MASTER                  "부서코드, 부서명 가져온 인터널 테이블
      RETURN_TAB      = LT_RETURN_TAB            "F4에서 선택한 값이 들어옴
    EXCEPTIONS
      PARAMETER_ERROR = 1
      NO_VALUES_FOUND = 2
      OTHERS          = 3.

  READ TABLE LT_RETURN_TAB INTO LS_RETURN_TAB INDEX 1.
  IF SY-SUBRC EQ 0.
    CLEAR GS_IFLIST_MASTER.
    READ TABLE GT_IFLIST_MASTER INTO GS_IFLIST_MASTER WITH KEY SEQNO = LS_RETURN_TAB-FIELDVAL.
    IF SY-SUBRC EQ 0.

      REFRESH LT_DYNPFIELDS.
      PERFORM GET_STEPL USING LV_LINE.
*     모듈코드
      APPEND INITIAL LINE TO LT_DYNPFIELDS ASSIGNING FIELD-SYMBOL(<LS_DYNPFIELDS>).
      <LS_DYNPFIELDS>-FIELDNAME = 'P_KIND'.
      <LS_DYNPFIELDS>-STEPL = LV_LINE.
      <LS_DYNPFIELDS>-FIELDVALUE = GS_IFLIST_MASTER-MODULE_KIND.
*     코드그룹
      APPEND INITIAL LINE TO LT_DYNPFIELDS ASSIGNING <LS_DYNPFIELDS>.
      <LS_DYNPFIELDS>-FIELDNAME = 'P_CODE_G'.
      <LS_DYNPFIELDS>-STEPL = LV_LINE.
      <LS_DYNPFIELDS>-FIELDVALUE = GS_IFLIST_MASTER-CODEGRP.

      CALL FUNCTION 'DYNP_VALUES_UPDATE'
        EXPORTING
          DYNAME               = SY-CPROG
          DYNUMB               = SY-DYNNR
        TABLES
          DYNPFIELDS           = LT_DYNPFIELDS
        EXCEPTIONS
          INVALID_ABAPWORKAREA = 1
          INVALID_DYNPROFIELD  = 2
          INVALID_DYNPRONAME   = 3
          INVALID_DYNPRONUMMER = 4
          INVALID_REQUEST      = 5
          NO_FIELDDESCRIPTION  = 6
          UNDEFIND_ERROR       = 7
          OTHERS               = 8.
      IF SY-SUBRC <> 0.
      ENDIF.

    ENDIF.
  ENDIF.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_DYNP_VALUE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&---------------------------------------------------------------------*
FORM GET_DYNP_VALUE  USING    PV_FIELDNAME TYPE DYNPREAD-FIELDNAME.

  ASSIGN (PV_FIELDNAME) TO FIELD-SYMBOL(<LV_VALUE>).

  CALL FUNCTION 'GET_DYNP_VALUE'
    EXPORTING
      I_FIELD = PV_FIELDNAME
      I_REPID = SY-CPROG
      I_DYNNR = SY-DYNNR
    CHANGING
      O_VALUE = <LV_VALUE>.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_STEPL
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LV_LINE
*&---------------------------------------------------------------------*
FORM GET_STEPL  USING   PV_LINE LIKE SY-STEPL.

  CALL FUNCTION 'DYNP_GET_STEPL'
    IMPORTING
      POVSTEPL        = PV_LINE
    EXCEPTIONS
      STEPL_NOT_FOUND = 01.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form F4_IF_LIST
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&---------------------------------------------------------------------*
FORM F4_IF_LIST  USING  PV_DYNPROFLD TYPE HELP_INFO-DYNPROFLD .

  DATA : LT_RETURN_TAB TYPE TABLE OF DDSHRETVAL,
         LS_RETURN_TAB LIKE LINE OF LT_RETURN_TAB.

  DATA : LO_FLIEF TYPE REF TO DATA.
  DATA : LV_OFFSET(6) TYPE N.

  DATA : LT_FIELD_TAB TYPE TABLE OF DFIES.
  DATA : LO_STRUCTDESCR TYPE REF TO CL_ABAP_STRUCTDESCR.

  DATA : LV_LINE       LIKE SY-STEPL,
         LT_DYNPFIELDS LIKE TABLE OF DYNPREAD.

  PERFORM GET_DYNP_VALUE USING 'P_KIND'.
  PERFORM GET_DYNP_VALUE USING 'P_CODE_G'.
  IF P_KIND IS INITIAL.
    SET CURSOR FIELD 'P_KIND'.
    MESSAGE S006 WITH '모듈은 필수 필드 입니다.' DISPLAY LIKE 'E'.
    EXIT.
  ENDIF.

  IF P_CODE_G IS INITIAL.
    SET CURSOR FIELD 'P_CODE_G'.
    MESSAGE S006 WITH '코드그룹은 필수 필드 입니다.' DISPLAY LIKE 'E'.
    EXIT.
  ENDIF.

  REFRESH GT_IFLIST_ITEM.

  SELECT FLD_01,
             FLD_02,
             FLD_13
      FROM ZGTPPT1010
    WHERE MODULE_KIND = @P_KIND
      AND CODEGRP = @P_CODE_G
     INTO CORRESPONDING FIELDS OF TABLE @GT_IFLIST_ITEM.

* 속성필드 정의
  FREE LO_FLIEF.
  CREATE DATA LO_FLIEF LIKE GS_IFLIST_ITEM.

  LO_STRUCTDESCR ?= CL_ABAP_STRUCTDESCR=>DESCRIBE_BY_DATA_REF( LO_FLIEF ).
  LT_FIELD_TAB = CL_SALV_DATA_DESCR=>READ_STRUCTDESCR( LO_STRUCTDESCR ).

  LOOP AT LT_FIELD_TAB  ASSIGNING FIELD-SYMBOL(<LS_FIELD_TAB>).
    CASE <LS_FIELD_TAB>-FIELDNAME.
      WHEN 'FLD_01'.
        <LS_FIELD_TAB>-REPTEXT  = 'IF 항목'.
      WHEN 'FLD_02'.
        <LS_FIELD_TAB>-REPTEXT  = '내역'.
      WHEN 'FLD_13'.
        <LS_FIELD_TAB>-REPTEXT  = '보관기간'.
    ENDCASE.

    <LS_FIELD_TAB>-OFFSET = LV_OFFSET.
    LV_OFFSET = LV_OFFSET + <LS_FIELD_TAB>-INTLEN.

  ENDLOOP.


  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'  "F4 창 띄움
    EXPORTING
      RETFIELD        = 'FLD_01'
      DYNPROFIELD     = PV_DYNPROFLD           "F4누른 필드
      VALUE_ORG       = 'S'                      "가져오는 엔트리가 다수일 경우인 것 같음. 다수일 경우 C로 하면 F4 안뜸
      WINDOW_TITLE    = 'IF 항목'     "Search Help 타이틀
      DISPLAY         = 'F'
    TABLES
      FIELD_TAB       = LT_FIELD_TAB
      VALUE_TAB       = GT_IFLIST_ITEM                  "가져온 인터널 테이블
      RETURN_TAB      = LT_RETURN_TAB            "F4에서 선택한 값이 들어옴
    EXCEPTIONS
      PARAMETER_ERROR = 1
      NO_VALUES_FOUND = 2
      OTHERS          = 3.

  READ TABLE LT_RETURN_TAB INTO LS_RETURN_TAB INDEX 1.
  IF SY-SUBRC EQ 0.
    CLEAR GS_IFLIST_MASTER.
    READ TABLE GT_IFLIST_ITEM INTO GS_IFLIST_ITEM WITH KEY FLD_01 = LS_RETURN_TAB-FIELDVAL.
    IF SY-SUBRC EQ 0.
      ASSIGN (PV_DYNPROFLD) TO FIELD-SYMBOL(<LV_FIELD>).
      <LV_FIELD> = GS_IFLIST_ITEM-FLD_01.

*      P_DESC = GS_IFLIST_ITEM-FLD_02.
*      P_DAY = GS_IFLIST_ITEM-FLD_13.

    ENDIF.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form MAIN_PROC
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM MAIN_PROC .

  PERFORM GET_PROC.

  IF SY-BATCH IS INITIAL. " 온라인 실행시
    PERFORM DISP_PROC.
  ELSE. " 백그라운드 실행시

    IF GT_MAIN_DISP[] IS NOT INITIAL.
      PERFORM BACH_PROC_DELE_TABLE.
    ELSE.
      MESSAGE S006 WITH 'I/F Log 조회대상 없습니다.' DISPLAY LIKE 'E'.
    ENDIF.
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

  REFRESH GT_MAIN_DISP.
  SELECT * FROM ZGTPPT1010
    INTO CORRESPONDING FIELDS OF TABLE GT_MAIN_DISP
    WHERE MODULE_KIND = P_KIND
      AND CODEGRP = P_CODE_G
      AND FLD_01 IN S_IFLIST.

  LOOP AT GT_MAIN_DISP ASSIGNING FIELD-SYMBOL(<LS_MAIN>).
    <LS_MAIN>-STAT = ICON_LED_YELLOW.
    <LS_MAIN>-MSG = '처리이전'.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form DISP_PROC
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM DISP_PROC .

  IF GT_MAIN_DISP[] IS NOT INITIAL.
    CALL SCREEN '0100'.
  ELSE.
    MESSAGE S006 WITH '조회 결과가 없습니다.' DISPLAY LIKE 'E'.
  ENDIF.

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
                           USING : 'ALLSEL' ICON_SELECT_ALL '전체선택' '전체선택' 0,
                                      'DESEL' ICON_DESELECT_ALL '선택해제' '선택해제' 0,
                                       '' '' '' '' 3,
                                      'DELE' ICON_DELETE 'I/F Log 삭제' 'I/F Log 삭제' 0.

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
FORM USER_COMMAND_PROS  USING   PO_SENDER  TYPE REF TO CL_GUI_ALV_GRID
                                 PV_UCOMM.

  CASE PO_SENDER.
    WHEN GO_GRID_0100.
      CASE PV_UCOMM.
        WHEN 'ALLSEL'.
          PERFORM PROCESS_ALLSELECT.

        WHEN 'DESEL'.
          PERFORM PROCESS_DESELECT.

        WHEN 'DELE'.
          PERFORM PROCESS_DELETE_TABLES USING PO_SENDER.

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
FORM DATA_CHANGED  USING   P_SENDER  TYPE REF TO CL_GUI_ALV_GRID
                                PO_DATA_CHANGED TYPE REF TO
                                          CL_ALV_CHANGED_DATA_PROTOCOL
                                PE_ONF4
                                PE_UCOMM.

  DATA: LS_MOD_CELLS TYPE LVC_S_MODI.
  DATA : LV_VALUE TYPE I.
  DATA : LV_VALUE_C TYPE LVC_S_MODI-VALUE.
  DATA : LV_CHK_ERR.

  DEFINE __SET_ERR_MSG.
    lv_chk_err = abap_true.
    po_data_changed->add_protocol_entry(
        i_msgid     = 'ZGTPP00'                 " Message ID
        i_msgty     = 'E'                 " Message Type
        i_msgno     =  '03'                " Message No.
        i_msgv1     =  &1                " Message Variable1
        i_fieldname =  &2                " Field Name
        i_row_id    =  ls_mod_cells-row_id ).                " RowID
  END-OF-DEFINITION.

  CASE P_SENDER.
    WHEN GO_GRID_0100.
      LOOP AT PO_DATA_CHANGED->MT_GOOD_CELLS INTO LS_MOD_CELLS.
        CASE LS_MOD_CELLS-FIELDNAME.
          WHEN 'FLD_13'.
            IF LS_MOD_CELLS-VALUE IS NOT INITIAL.
              TRY.
                  LV_VALUE = LS_MOD_CELLS-VALUE.
                CATCH CX_ROOT.
                  __SET_ERR_MSG '문자는 입력 불가능 합니다.' LS_MOD_CELLS-FIELDNAME.
                  LV_CHK_ERR = ABAP_TRUE.
              ENDTRY.

              IF SY-SUBRC NE 0.
                CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
                  EXPORTING
                    INPUT  = LS_MOD_CELLS-VALUE
                  IMPORTING
                    OUTPUT = LS_MOD_CELLS-VALUE.
                LV_VALUE = LS_MOD_CELLS-VALUE.
                LV_VALUE_C = LV_VALUE.
                CONDENSE LV_VALUE_C.
                IF NOT LV_VALUE_C = LS_MOD_CELLS-VALUE.

                  __SET_ERR_MSG '문자는 입력 불가능 합니다.' LS_MOD_CELLS-FIELDNAME.
                  LV_CHK_ERR = ABAP_TRUE.
                ENDIF.

                IF LV_VALUE = 0.
                  __SET_ERR_MSG '당일 로그는 삭제 불가능합니다.' LS_MOD_CELLS-FIELDNAME.
                  LV_CHK_ERR = ABAP_TRUE.
                ENDIF.

              ENDIF.
            ENDIF.
        ENDCASE.
      ENDLOOP.
  ENDCASE.

  IF LV_CHK_ERR IS NOT INITIAL.
    PO_DATA_CHANGED->DISPLAY_PROTOCOL( ).
  ENDIF.

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
*& Form EVENT_HANDLER_REGISTER
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GO_GRID_0100
*&---------------------------------------------------------------------*
FORM EVENT_HANDLER_REGISTER  USING   PO_GRID TYPE REF TO CL_GUI_ALV_GRID.

  IF GO_EVENT_HANDLER IS NOT BOUND.
    CREATE OBJECT GO_EVENT_HANDLER.
  ENDIF.

  CASE PO_GRID.
    WHEN GO_GRID_0100.
*// Event Handler ##
      SET HANDLER GO_EVENT_HANDLER->HANDLE_TOOLBAR               FOR PO_GRID.
      SET HANDLER GO_EVENT_HANDLER->HANDLE_USER_COMMAND      FOR PO_GRID.
      SET HANDLER GO_EVENT_HANDLER->HANDLE_DATA_CHANGED       FOR PO_GRID.
  ENDCASE.

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
  GS_LAYOUT_0100-NO_ROWINS = ABAP_TRUE.
  GS_LAYOUT_0100-SEL_MODE   = 'D'.

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
      I_INCLNAME             = 'ZGTPPR3140TOP'
      I_INTERNAL_TABNAME     = 'GS_MAIN_DISP'
    CHANGING
      CT_FIELDCAT            = LT_FCAT_SLIS
    EXCEPTIONS
      INCONSISTENT_INTERFACE = 1
      PROGRAM_ERROR          = 2
      OTHERS                 = 3.

  REFRESH GT_FIELDCAT_0100.
  FREE GT_FIELDCAT_0100.

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

  LOOP AT GT_FIELDCAT_0100 ASSIGNING FIELD-SYMBOL(<LS_FCAT>).
    CLEAR <LS_FCAT>-KEY.
    CASE   <LS_FCAT>-FIELDNAME.
      WHEN 'MODULE_KIND'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '모듈'.
        <LS_FCAT>-JUST = 'C'.
        <LS_FCAT>-COL_OPT = ABAP_TRUE.
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
      WHEN 'CODEGRP'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '코드그룹'.
        <LS_FCAT>-JUST = 'C'.
        <LS_FCAT>-COL_OPT = ABAP_TRUE.
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
      WHEN 'FLD_01'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = 'I/F 항목(No)'.
        <LS_FCAT>-JUST = 'C'.
        <LS_FCAT>-COL_OPT = ABAP_TRUE.
        <LS_FCAT>-EMPHASIZE = 'C410'.
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
      WHEN 'FLD_02'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = 'I/F 명'.
        <LS_FCAT>-JUST = 'L'.
        <LS_FCAT>-COL_OPT = ABAP_TRUE.
        <LS_FCAT>-EMPHASIZE = 'C410'.
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
      WHEN 'FLD_03'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '송수신구분'.
        <LS_FCAT>-JUST = 'C'.
        <LS_FCAT>-COL_OPT = ABAP_TRUE.
      WHEN 'FLD_04'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '호출T-code'.
        <LS_FCAT>-JUST = 'L'.
        <LS_FCAT>-COL_OPT = ABAP_TRUE.
      WHEN 'FLD_05'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '사용 Function'.
        <LS_FCAT>-JUST = 'L'.
        <LS_FCAT>-COL_OPT = ABAP_TRUE.
      WHEN 'FLD_06'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = 'IF Log Table(H)'.
        <LS_FCAT>-JUST = 'L'.
        <LS_FCAT>-COL_OPT = ABAP_TRUE.
      WHEN 'FLD_07'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = 'IF Log Table(I)'.
        <LS_FCAT>-JUST = 'L'.
        <LS_FCAT>-COL_OPT = ABAP_TRUE.
      WHEN 'FLD_08'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = 'IF Log Table(DETAIL 1)'.
        <LS_FCAT>-JUST = 'L'.
        <LS_FCAT>-COL_OPT = ABAP_TRUE.
      WHEN 'FLD_09'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = 'IF Log Table(DETAIL 2)'.
        <LS_FCAT>-JUST = 'L'.
        <LS_FCAT>-COL_OPT = ABAP_TRUE.
      WHEN 'FLD_10'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = 'IF Log Table(DETAIL 3)'.
        <LS_FCAT>-JUST = 'L'.
        <LS_FCAT>-COL_OPT = ABAP_TRUE.
      WHEN 'FLD_11'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = 'IF Log Table(DETAIL 4)'.
        <LS_FCAT>-JUST = 'L'.
        <LS_FCAT>-COL_OPT = ABAP_TRUE.
      WHEN 'FLD_12'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = 'IF Log Table(DETAIL 5)'.
        <LS_FCAT>-JUST = 'L'.
        <LS_FCAT>-COL_OPT = ABAP_TRUE.
      WHEN 'FLD_13'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '보관기간(DAY)'.
        <LS_FCAT>-JUST = 'R'.
        <LS_FCAT>-EDIT = ABAP_TRUE.
        <LS_FCAT>-COL_OPT = ABAP_TRUE.
        <LS_FCAT>-DD_OUTLEN = 3.
      WHEN 'STAT'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '삭제성공여부'.
        <LS_FCAT>-JUST = 'C'.
        <LS_FCAT>-ICON = ABAP_TRUE.
        <LS_FCAT>-COL_OPT = ABAP_TRUE.
        <LS_FCAT>-EMPHASIZE = 'C410'.
      WHEN 'MSG'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '처리메세지'.
        <LS_FCAT>-JUST = 'L'.
        <LS_FCAT>-COL_OPT = ABAP_TRUE.
        <LS_FCAT>-EMPHASIZE = 'C410'.
    ENDCASE.

  ENDLOOP.

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
                CL_GUI_ALV_GRID=>MC_FC_SORT,
                CL_GUI_ALV_GRID=>MC_FC_SORT_ASC,
                CL_GUI_ALV_GRID=>MC_FC_SORT_DSC,
                CL_GUI_ALV_GRID=>MC_FC_SUBTOT,
                CL_GUI_ALV_GRID=>MC_FC_SUM,
                CL_GUI_ALV_GRID=>MC_MB_SUBTOT,
                CL_GUI_ALV_GRID=>MC_MB_SUM,
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
*&      Form  add_exclude_toolbar_button
*&---------------------------------------------------------------------*
*       text
*-----------------------------------------------------------------------
FORM ADD_EXCLUDE_TOOLBAR_BUTTON  TABLES   P_TABLE
                                 USING    P_VALUE.
  DATA: L_EXCLUDE TYPE UI_FUNC.
  L_EXCLUDE = P_VALUE.
  APPEND L_EXCLUDE TO P_TABLE.
ENDFORM.                    " add_exclude_toolbar_button
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
*& Form PROCESS_ALLSELECT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PROCESS_ALLSELECT .

  DATA : LT_ROWS TYPE LVC_T_ROW.
  DATA : LV_INDEX TYPE I.

  CLEAR LV_INDEX.
  DO LINES( GT_MAIN_DISP ) TIMES.
    ADD 1 TO LV_INDEX.
    APPEND INITIAL LINE TO LT_ROWS ASSIGNING FIELD-SYMBOL(<LS_ROW>).
    <LS_ROW>-INDEX = LV_INDEX.
  ENDDO.

  GO_GRID_0100->SET_SELECTED_ROWS(
    IT_INDEX_ROWS            =  LT_ROWS                " Indexes of Selected Rows
  ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROCESS_DESELECT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PROCESS_DESELECT .

  DATA : LT_ROWS TYPE LVC_T_ROW.

  GO_GRID_0100->SET_SELECTED_ROWS(
    IT_INDEX_ROWS            =  LT_ROWS                " Indexes of Selected Rows
  ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROCESS_DELETE_TABLES
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PO_SENDER
*&---------------------------------------------------------------------*
FORM PROCESS_DELETE_TABLES  USING    PO_SENDER.

  DATA : LT_ROWS TYPE LVC_T_ROW.
  DATA : LV_NUM TYPE I.
  DATA : LV_INDICATER(2) TYPE N.

  GO_GRID_0100->GET_SELECTED_ROWS(
    IMPORTING
      ET_INDEX_ROWS = LT_ROWS                 " Indexes of Selected Rows
  ).
*  서브토탈라인제거
  DELETE LT_ROWS WHERE INDEX = 0.

* 정합성 체크 - 해당 라인의 보관일자가 존재해야 가능.
  LOOP AT LT_ROWS INTO DATA(LS_ROWS).
    READ TABLE GT_MAIN_DISP INTO DATA(LS_MAIN) INDEX LS_ROWS-INDEX.
    CLEAR LV_NUM.
    LV_NUM = LS_MAIN-FLD_13.
    IF LV_NUM > 0.
      CONTINUE.
    ELSE.
      MESSAGE S006 WITH '보관 기간(DAY) 가 미지정되었습니다.' DISPLAY LIKE 'E'.
      RETURN.
    ENDIF.
  ENDLOOP.

  CLEAR GV_ANSWER.
  PERFORM POPUP_TO_CONFIRM_STEP USING 'N'
    ' '
    '선택된 I/F Log 삭제합니다. 계속 진행 하시겠습니까?'
    '삭제확인'.
  IF GV_ANSWER NE 'J'.
    MESSAGE S003 DISPLAY LIKE 'E' WITH '작업이 취소되었습니다.'.
    RETURN.
  ENDIF.

  REFRESH GT_SAVELOG.
  FREE GT_SAVELOG.

  LV_INDICATER = 10.

  LOOP AT LT_ROWS INTO LS_ROWS.
    READ TABLE GT_MAIN_DISP ASSIGNING FIELD-SYMBOL(<LS_MAIN>) INDEX LS_ROWS-INDEX.
    PERFORM SET_INDICATOR USING LV_INDICATER '삭제 진행중...'.
    IF LV_INDICATER < 80. " 80 까지 5씩 증가
      ADD 5 TO LV_INDICATER.
    ENDIF.

    PERFORM DELETE_IFLIST CHANGING <LS_MAIN>.

  ENDLOOP.

  PERFORM SET_INDICATOR USING 90 'Log 저장중.. '.

  IF GT_SAVELOG IS NOT INITIAL.
    MODIFY ZGTPPT3310 FROM TABLE GT_SAVELOG.
    IF SY-SUBRC EQ 0.
      COMMIT WORK AND WAIT.
    ELSE.
      ROLLBACK WORK.
    ENDIF.
  ENDIF.

  PERFORM SET_INDICATOR USING 99 '삭제 작업 완료'.

  PERFORM REFRESH_0100.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form popup_to_confirm_step
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> P_
*&      --> P_
*&      --> P_
*&---------------------------------------------------------------------*
FORM POPUP_TO_CONFIRM_STEP  USING LP_OPT
                                  LP_TEXT1
                                  LP_TEXT2
                                  LP_TITLE.
  CLEAR GV_ANSWER.
  CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
    EXPORTING
      DEFAULTOPTION  = LP_OPT
      TEXTLINE1      = LP_TEXT1
      TEXTLINE2      = LP_TEXT2
      TITEL          = LP_TITLE
      CANCEL_DISPLAY = ''
    IMPORTING
      ANSWER         = GV_ANSWER.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form DELETE_IFLIST
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- <LS_MAIN>
*&---------------------------------------------------------------------*
FORM DELETE_IFLIST  CHANGING PS_MAIN LIKE GS_MAIN_DISP.

  DATA : LT_TABNAME TYPE RANGE OF DD02L-TABNAME.
  DATA : LV_FIELDNAME TYPE FIELDNAME.
  DATA : LV_NUM(2) TYPE N.
  FIELD-SYMBOLS : <LV_VALUE> TYPE ANY.
  DATA : LS_3310 TYPE ZGTPPT3310.
  DATA : LV_DATE TYPE SY-DATUM.
  DATA : LV_TIME TYPE SY-UZEIT.
  DATA : LV_ZIFKEY TYPE TIMESTAMPL.
  DATA : LV_STRING TYPE STRING.
  DATA : LV_CHK_ERR.
  DATA : LV_CHK_ERR_CNT TYPE I..

* 삭제이력 테이블 구조로 데이터 이관
  APPEND INITIAL LINE TO GT_SAVELOG ASSIGNING FIELD-SYMBOL(<LS_SAVE>).
  <LS_SAVE>-MODULE_KIND = PS_MAIN-MODULE_KIND.
  <LS_SAVE>-CODEGRP = PS_MAIN-CODEGRP.
  <LS_SAVE>-IFLIST = PS_MAIN-FLD_01.
  GET TIME STAMP FIELD <LS_SAVE>-TIMESTAMP.
*  CONVERT DATE SY-DATE TIME SY-UZEIT INTO TIME STAMP <LS_SAVE>-TIMESTAMP TIME ZONE SY-ZONLO.
  <LS_SAVE>-LOGHEADER = PS_MAIN-FLD_06.
  <LS_SAVE>-LOGITEM = PS_MAIN-FLD_07.
  <LS_SAVE>-LOGDET1 = PS_MAIN-FLD_08.
  <LS_SAVE>-LOGDET2 = PS_MAIN-FLD_09.
  <LS_SAVE>-LOGDET3 = PS_MAIN-FLD_10.
  <LS_SAVE>-LOGDET4 = PS_MAIN-FLD_11.
  <LS_SAVE>-LOGDET5 = PS_MAIN-FLD_12.
  <LS_SAVE>-LOGDAY = PS_MAIN-FLD_13.
* 삭제 적용 보관일자 세팅
  LV_DATE = SY-DATUM - PS_MAIN-FLD_13 + 1.
  CONVERT DATE LV_DATE TIME LV_TIME INTO TIME STAMP LV_ZIFKEY TIME ZONE SY-ZONLO.

*  <LS_SAVE>-STAT
*  <LS_SAVE>-MSG
  <LS_SAVE>-CRDAT = SY-DATUM.
  <LS_SAVE>-CRTIM = SY-UZEIT.
  <LS_SAVE>-CRNAM = SY-UNAME.
  <LS_SAVE>-CHDAT = SY-DATUM.
  <LS_SAVE>-CHTIM = SY-UZEIT.
  <LS_SAVE>-CHNAM = SY-UNAME.

* 로그용 테이블 추출
  LV_NUM = '06'.
  DO.
    IF LV_NUM = '13'.
      EXIT.
    ENDIF.

    CLEAR LV_FIELDNAME.
    LV_FIELDNAME = 'FLD_' && LV_NUM.
    IF <LV_VALUE> IS ASSIGNED. UNASSIGN <LV_VALUE>. ENDIF.
    ASSIGN COMPONENT LV_FIELDNAME OF STRUCTURE PS_MAIN TO <LV_VALUE>.
    IF <LV_VALUE> IS ASSIGNED AND <LV_VALUE> IS NOT INITIAL.
      APPEND INITIAL LINE TO LT_TABNAME ASSIGNING FIELD-SYMBOL(<LS_TABNAME>).
      <LS_TABNAME>-SIGN = 'I'.
      <LS_TABNAME>-OPTION = 'EQ'.
      <LS_TABNAME>-LOW = <LV_VALUE>.
    ENDIF.

    ADD 1 TO LV_NUM.
  ENDDO.

  IF LT_TABNAME[] IS NOT INITIAL.
    SELECT TABNAME FROM DD02L
      INTO TABLE @DATA(LT_CHK_TABNAME)
     WHERE TABNAME IN @LT_TABNAME.
  ENDIF.

  IF SY-BATCH = ABAP_TRUE AND PS_MAIN-FLD_13 IS INITIAL.
    GV_BACK_STATUS = <LS_SAVE>-STAT = 'S'.
    <LS_SAVE>-MSG = '보관기간 미정의로 삭제 Skip.코드마스터 참고.'.
    RETURN.
  ENDIF.

  IF LT_CHK_TABNAME IS INITIAL.  " 테이블 미존재시 오류처리
    GV_BACK_STATUS = <LS_SAVE>-STAT = 'E'.
    PS_MAIN-MSG = <LS_SAVE>-MSG = '등록된 Log 테이블이 없습니다.'.
    PS_MAIN-STAT = ICON_LED_RED.
    RETURN.
  ENDIF.

  CLEAR LV_CHK_ERR.
  CLEAR LV_CHK_ERR_CNT.
* 데이터 삭제
  LOOP AT LT_CHK_TABNAME INTO DATA(LS_CHK_TABNAME).
    CLEAR LV_FIELDNAME.
    SELECT SINGLE FIELDNAME FROM DD03L
      INTO LV_FIELDNAME
     WHERE TABNAME = LS_CHK_TABNAME-TABNAME
        AND ROLLNAME = 'TIMESTAMPL'
        AND KEYFLAG = 'X'.
    IF SY-SUBRC EQ 0.
      CLEAR LV_STRING.
      LV_STRING = |{ LV_FIELDNAME } < LV_ZIFKEY |.
    ELSE.
      GV_BACK_STATUS = <LS_SAVE>-STAT = 'E'.
      PS_MAIN-MSG = <LS_SAVE>-MSG = LS_CHK_TABNAME-TABNAME && '테이블 Key값을 참조할 수 없습니다.'.
      PS_MAIN-STAT = ICON_LED_RED.
      RETURN.
    ENDIF.

    TRY.
        DELETE FROM (LS_CHK_TABNAME-TABNAME) WHERE (LV_STRING).
        IF SY-SUBRC EQ 0.
          COMMIT WORK AND WAIT.
          IF LV_CHK_ERR NE 'E'.
            LV_CHK_ERR = 'S'.
          ENDIF.

        ELSE.
          ROLLBACK WORK.
          CASE LV_CHK_ERR.
            WHEN 'S' OR 'E'.
            WHEN OTHERS.
              LV_CHK_ERR = 'W'.
          ENDCASE.

        ENDIF.
      CATCH CX_ROOT.
        ADD 1 TO LV_CHK_ERR_CNT.
        LV_CHK_ERR = 'E'.
        IF <LS_SAVE>-MSG IS INITIAL.
          CONCATENATE '일부 삭제 오류 -' LS_CHK_TABNAME-TABNAME INTO PS_MAIN-MSG SEPARATED BY SPACE.
        ELSE.
          PS_MAIN-MSG = PS_MAIN-MSG && ','.
          CONCATENATE PS_MAIN-MSG LS_CHK_TABNAME-TABNAME INTO PS_MAIN-MSG SEPARATED BY SPACE.
        ENDIF.
    ENDTRY.

  ENDLOOP.

* 결과 메시지 처리
  CASE   LV_CHK_ERR.
    WHEN 'W'.
      GV_BACK_STATUS = <LS_SAVE>-STAT = 'S'.
      PS_MAIN-MSG = <LS_SAVE>-MSG = '삭제 대상 없음'.
      PS_MAIN-STAT = ICON_LED_GREEN.
    WHEN 'S'.
      GV_BACK_STATUS = <LS_SAVE>-STAT = 'S'.
      PS_MAIN-MSG = <LS_SAVE>-MSG = '전체 삭제 성공'.
      PS_MAIN-STAT = ICON_LED_GREEN.
    WHEN 'E'.
      IF LV_CHK_ERR_CNT = LINES( LT_CHK_TABNAME ).
        PS_MAIN-MSG = <LS_SAVE>-MSG = '전체 삭제 오류'.
      ELSE.
        PS_MAIN-MSG = <LS_SAVE>-MSG.
        IF SY-BATCH = ABAP_TRUE.
          <LS_SAVE>-STAT = 'S'.
          GV_BACK_STATUS = 'W'.
          <LS_SAVE>-MSG = '일부 삭제 성공'.
          RETURN.
        ENDIF.
      ENDIF.
      GV_BACK_STATUS = <LS_SAVE>-STAT = 'E'.
      PS_MAIN-STAT = ICON_LED_RED.
  ENDCASE.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_INDICATOR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LV_INDICATER
*&      --> P_
*&---------------------------------------------------------------------*
FORM SET_INDICATOR  USING    PV_INDICATER
                                           PV_TEXT.

  CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
    EXPORTING
      PERCENTAGE = PV_INDICATER                 "indicator에 진행률(%)
      TEXT       = PV_TEXT.  "텍스트 표시

ENDFORM.
*&---------------------------------------------------------------------*
*& Form REFRESH_0100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM REFRESH_0100 .
  DATA: LS_SCROLL   TYPE LVC_S_STBL.

  LS_SCROLL-ROW = 'X'.
  LS_SCROLL-COL = 'X'.

  CALL METHOD GO_GRID_0100->REFRESH_TABLE_DISPLAY
    EXPORTING
      IS_STABLE = LS_SCROLL.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form BACH_PROC_DELE_TABLE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM BACH_PROC_DELE_TABLE .

  DATA : LV_STATUS TYPE C.

  LOOP AT GT_MAIN_DISP INTO GS_MAIN_DISP.
    CLEAR GV_BACK_STATUS.
    PERFORM DELETE_IFLIST CHANGING GS_MAIN_DISP.

    CASE GV_BACK_STATUS.
      WHEN 'S'.
        CASE LV_STATUS.
          WHEN 'W' OR 'E'.
          WHEN OTHERS.
            LV_STATUS = 'S'.
        ENDCASE.
      WHEN 'W'.
        IF LV_STATUS NE 'E'.
          LV_STATUS = 'W'.
        ENDIF.

      WHEN 'E'.
        LV_STATUS = 'E'.
    ENDCASE.

  ENDLOOP.
  IF GT_SAVELOG IS NOT INITIAL.
    MODIFY ZGTPPT3310 FROM TABLE GT_SAVELOG.
    IF SY-SUBRC EQ 0.
      COMMIT WORK AND WAIT.
    ELSE.
      ROLLBACK WORK.
    ENDIF.
  ENDIF.

  CASE LV_STATUS.
    WHEN 'S'.
      MESSAGE S006 WITH '전체 삭제 성공'.
    WHEN 'W'.
      MESSAGE S006 WITH '일부 삭제 성공, 일부는 보관기간 미정의로 삭제 Skip. 코드마스터 참고.'.
    WHEN 'E'.
      MESSAGE S006 WITH '전체 삭제 실패. 보관기간 미정의 혹은' '데이터 구조가 맞지 않음. 코드마스터 확인 필요' DISPLAY LIKE 'E'.
  ENDCASE.



ENDFORM.
