*&---------------------------------------------------------------------*
*& Include          ZGTPPR9994F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form GET_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_DATA .

  DATA : LT_CSCMAT TYPE TABLE OF CSCMAT.
  DATA : LV_NAME1 TYPE T001W-NAME1.
  DATA : LT_STB TYPE TABLE OF STPOX.

  LV_NAME1 = ZGTPP_CL_COMMON=>GET_PLANT_NAME( IV_WERKS = P_WERKS ).

  SELECT DISTINCT A~MATNR AS MATNR_O, A~MTART AS MTART_O, A~MATKL AS MATKL_O, B~WERKS
    FROM MARA AS A
    INNER JOIN MARC AS B ON B~MATNR = A~MATNR
    INTO TABLE @DATA(LT_MOSU)
   WHERE A~MATNR IN @S_MATNR
     AND A~MTART IN @S_MTART
     AND A~MATKL IN @S_MATKL
     AND B~WERKS = @P_WERKS.

  LOOP AT LT_MOSU INTO DATA(LS_MOSU).
* BOM 하위전개
    CALL FUNCTION 'CS_BOM_EXPL_MAT_V2'
      EXPORTING
        CAPID                 = 'PP01'
        DATUV                 = SY-DATUM
        EMENG                 = '1'
        MEHRS                 = ABAP_ON
        MMORY                 = '1'
        MTNRV                 = LS_MOSU-MATNR_O
        WERKS                 = P_WERKS
      TABLES
        STB                   = LT_STB
        MATCAT                = LT_CSCMAT
      EXCEPTIONS
        ALT_NOT_FOUND         = 1
        CALL_INVALID          = 2
        MATERIAL_NOT_FOUND    = 3
        MISSING_AUTHORIZATION = 4
        NO_BOM_FOUND          = 5
        NO_PLANT_DATA         = 6
        NO_SUITABLE_BOM_FOUND = 7
        CONVERSION_ERROR      = 8
        OTHERS                = 9.

    SELECT DISTINCT B~MATNR AS IDNRK, B~MTART, B~MATKL, C~STLAN, C~STLAL, C~ANDAT
      FROM @LT_CSCMAT AS A
      INNER JOIN MARA AS B ON B~MATNR = A~MATNR
      INNER JOIN MAST AS C ON C~MATNR = A~MATNR
     WHERE C~WERKS = @P_WERKS
       AND C~STLAN IN @S_STLAN
       AND C~STLAL IN @S_STLAL
       AND C~ANDAT IN @S_ANDAT
      INTO TABLE @DATA(LT_MOSU_ITEM).

    IF LT_MOSU_ITEM[] IS NOT INITIAL.
      LOOP AT LT_MOSU_ITEM INTO DATA(LS_MOSU_ITEM).
        CLEAR GS_MAIN_DISP.
        GS_MAIN_DISP-STATUS = ICON_LED_INACTIVE.
        MOVE-CORRESPONDING LS_MOSU TO GS_MAIN_DISP.
        MOVE-CORRESPONDING LS_MOSU_ITEM TO GS_MAIN_DISP.
        GS_MAIN_DISP-WERKS = P_WERKS.
        GS_MAIN_DISP-NAME1 = LV_NAME1.
        GS_MAIN_DISP-MAKTX_O = ZGTPP_CL_COMMON=>GET_MAKTX( IV_MATNR = GS_MAIN_DISP-MATNR_O ).
        GS_MAIN_DISP-MAKTX = ZGTPP_CL_COMMON=>GET_MAKTX( IV_MATNR = GS_MAIN_DISP-IDNRK ).
        APPEND GS_MAIN_DISP TO GT_MAIN_DISP.
      ENDLOOP.
    ENDIF.
  ENDLOOP.

  SORT GT_MAIN_DISP BY WERKS NAME1 MATNR_O IDNRK STLAN STLAL.

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
    CALL SCREEN '0100'.
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
FORM EVENT_HANDLER_REGISTER  USING    PO_GRID TYPE REF TO CL_GUI_ALV_GRID.

  IF GO_EVENT_HANDLER IS NOT BOUND.
    CREATE OBJECT GO_EVENT_HANDLER.
  ENDIF.

  CASE PO_GRID.
    WHEN GO_GRID_0100.
      SET HANDLER GO_EVENT_HANDLER->HANDLE_TOOLBAR               FOR PO_GRID.
      SET HANDLER GO_EVENT_HANDLER->HANDLE_USER_COMMAND          FOR PO_GRID.
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
      I_INCLNAME             = 'ZGTPPR9994TOP'
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


  LOOP AT GT_FIELDCAT_0100 ASSIGNING FIELD-SYMBOL(<LS_FCAT>).
    CLEAR <LS_FCAT>-KEY.
    CASE   <LS_FCAT>-FIELDNAME.
      WHEN 'STATUS'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '처리 상태'(F01).
        <LS_FCAT>-JUST = 'C'.
        <LS_FCAT>-ICON = ABAP_TRUE.
      WHEN 'MESSAGE'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '처리 메세지'(F02).
        <LS_FCAT>-JUST = 'L'.
      WHEN 'WERKS'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '플랜트'(F03).
        <LS_FCAT>-JUST = 'C'.
      WHEN 'NAME1'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '플랜트내역'(F04).
        <LS_FCAT>-JUST = 'L'.
      WHEN 'MATNR_O'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '기준 품목코드'(F05).
        <LS_FCAT>-JUST = 'C'.
      WHEN 'MAKTX_O'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '기준 품목내역'(F06).
        <LS_FCAT>-JUST = 'L'.
      WHEN 'MTART_O'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '기준 자재유형'(F07).
        <LS_FCAT>-JUST = 'C'.
      WHEN 'MATKL_O'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '기준 자재그룹'(F08).
        <LS_FCAT>-JUST = 'C'.
      WHEN 'IDNRK'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '하위 품목코드'(F09).
        <LS_FCAT>-JUST = 'C'.
      WHEN 'MAKTX'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '하위 품목내역'(F10).
        <LS_FCAT>-JUST = 'L'.
      WHEN 'MTART'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '하위 자재그룹'(F11).
        <LS_FCAT>-JUST = 'C'.
      WHEN 'MATKL'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '하위 자재그룹'(F12).
        <LS_FCAT>-JUST = 'C'.
      WHEN 'STLAN'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = 'BOM 용도'(F13).
        <LS_FCAT>-JUST = 'C'.
      WHEN 'STLAL'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '대체 BOM'(F14).
        <LS_FCAT>-JUST = 'C'.
      WHEN 'ANDAT'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '생성일자'(F15).
        <LS_FCAT>-JUST = 'C'.
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
**
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
      IT_SORT              = GT_SORT_0100
      IT_FIELDCATALOG      = GT_FIELDCAT_0100.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_SORTTAB_GRID_0100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_SORTTAB_GRID_0100 .

  REFRESH GT_SORT_0100.

  PERFORM SET_SORT_TAB TABLES GT_SORT_0100
                          USING : 1 'WERKS' '' 'X' '',
                                     2 'NAME1'  'X' '' '',
                                     3 'MATNR_O'  'X' '' '',
                                     4 'MAKTX_O'  'X' '' '',
                                     5 'MTART_O'  'X' '' '',
                                     6 'MATKL_O'  'X' '' '',
                                     7 'IDNRK'  'X' '' '',
                                     8 'MAKTX'  'X' '' '',
                                     9 'MTART'  'X' '' '',
                                     10 'MATKL'  'X' '' '',
                                     11'STLAN'  'X' '' '',
                                     12 'STLAL'  'X' '' ''.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_SORT_TAB
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_SORT_0100
*&      --> P_1
*&      --> P_
*&      --> P_
*&      --> P_
*&      --> P_
*&---------------------------------------------------------------------*
FORM SET_SORT_TAB  TABLES   PT_SORTTAB STRUCTURE LVC_S_SORT
                   USING    PV_POS
                               PV_FIELDNAME
                               PV_UP
                               PV_DOWN
                               PV_SUBTOT.

  DATA : LS_SORT TYPE LVC_S_SORT.
  LS_SORT-SPOS = PV_POS.
  LS_SORT-FIELDNAME = PV_FIELDNAME.
  LS_SORT-UP = PV_UP.
  LS_SORT-DOWN = PV_DOWN.
  LS_SORT-SUBTOT =  PV_SUBTOT.
  APPEND LS_SORT TO PT_SORTTAB.

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

* Macro
  DEFINE __SET_CELL_ATTRIBUTE.
    CLEAR LS_CELLTAB.
    LS_CELLTAB-FIELDNAME = &1.
    LS_CELLTAB-STYLE = &2.
    INSERT LS_CELLTAB INTO TABLE LT_CELLTAB.
  END-OF-DEFINITION.

  LOOP AT GT_MAIN_DISP ASSIGNING FIELD-SYMBOL(<LS_MAIN>).
    CLEAR LT_CELLTAB.
    LOOP AT GT_FIELDCAT_0100 INTO DATA(LS_FCAT).
      CASE LS_FCAT-FIELDNAME.
        WHEN 'WERKS' OR 'NAME1'. " 색지정 키
          __SET_CELL_ATTRIBUTE LS_FCAT-FIELDNAME ALV_STYLE_COLOR_INT_KEY.
        WHEN 'MATNR_O' OR 'MAKTX_O' OR 'MTART_O' OR 'MATKL_O'. " 색지정 파란
          __SET_CELL_ATTRIBUTE LS_FCAT-FIELDNAME ALV_STYLE_COLOR_HEADING.
        WHEN 'IDNRK' OR 'MAKTX' OR 'MTART' OR 'MATKL' OR 'STLAL' OR 'STLAN' OR 'ANDAT'. " 색지정 주황
          __SET_CELL_ATTRIBUTE LS_FCAT-FIELDNAME ALV_STYLE_COLOR_GROUP.
      ENDCASE.
    ENDLOOP.

    IF LT_CELLTAB IS NOT INITIAL.
      <LS_MAIN>-CELLTAB = LT_CELLTAB.
    ENDIF.

  ENDLOOP.

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
                                 USING : 'DELETE' ICON_DELETE 'BOM 삭제' 'BOM 삭제' 0.
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
FORM USER_COMMAND_PROS  USING    PO_SENDER  TYPE REF TO CL_GUI_ALV_GRID
                                 PV_UCOMM.

  CASE PO_SENDER.
    WHEN GO_GRID_0100.
      CASE PV_UCOMM.
        WHEN 'DELETE'.
          PERFORM PROC_DELETE.
      ENDCASE.
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROC_DELETE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PROC_DELETE .

  DATA : LT_ROWS TYPE LVC_T_ROW.
  DATA : LT_MOSU LIKE GT_MAIN_DISP.

  GO_GRID_0100->GET_SELECTED_ROWS(
      IMPORTING
        ET_INDEX_ROWS = LT_ROWS ).                " Indexes of Selected Rows
*      ET_ROW_NO     =                  " Numeric IDs of Selected Rows

  DELETE LT_ROWS WHERE INDEX = 0.

  IF LT_ROWS[] IS INITIAL.
    MESSAGE S006 DISPLAY LIKE 'E' WITH '삭제할 레코드를 선택하세요.'(E01).
    RETURN.
  ENDIF.

  LOOP AT LT_ROWS INTO DATA(LS_ROWS).
    READ TABLE GT_MAIN_DISP ASSIGNING FIELD-SYMBOL(<LS_MAIN>) INDEX LS_ROWS-INDEX.
    IF SY-SUBRC EQ 0.
      IF <LS_MAIN>-STATUS = ICON_LED_GREEN.
        <LS_MAIN>-MESSAGE = '이미 삭제된 레코드 입니다.'.
        CONTINUE.
      ENDIF.

      APPEND <LS_MAIN> TO LT_MOSU.
    ENDIF.
  ENDLOOP.

  IF LT_MOSU IS INITIAL.
    PERFORM REFRESH_GRID USING GO_GRID_0100.
    MESSAGE S006 DISPLAY LIKE 'E' WITH '삭제할 레코드를 선택하세요.'(E01).
    RETURN.
  ENDIF.

  CLEAR GV_ANSWER.
  PERFORM POPUP_TO_CONFIRM_STEP USING 'N'
    ' '
    'BOM 삭제를 진행하시겠습니까?'
    '삭제확인'.
  IF GV_ANSWER NE 'J'.
    MESSAGE S003 DISPLAY LIKE 'E' WITH '작업이 취소 되었습니다.'.
    RETURN.
  ENDIF.

  SORT LT_MOSU BY IDNRK STLAN STLAL.
  DELETE ADJACENT DUPLICATES FROM LT_MOSU COMPARING IDNRK STLAN STLAL.

  LOOP AT LT_MOSU ASSIGNING FIELD-SYMBOL(<LS_MOSU>).
    PERFORM PROC_DEL_BOM_BY_BDC CHANGING <LS_MOSU>.

    LOOP AT GT_MAIN_DISP ASSIGNING <LS_MAIN> WHERE IDNRK = <LS_MOSU>-IDNRK
                                                                   AND STLAN = <LS_MOSU>-STLAN
                                                                   AND STLAL = <LS_MOSU>-STLAL.

      MOVE : <LS_MOSU>-STATUS TO <LS_MAIN>-STATUS,
                 <LS_MOSU>-MESSAGE TO <LS_MAIN>-MESSAGE.

    ENDLOOP.
  ENDLOOP.

  PERFORM REFRESH_GRID USING GO_GRID_0100.
  MESSAGE S006 WITH 'BOM 삭제 작업 완료 되었습니다.'.

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
*& Form REFRESH_GRID
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GO_GRID_0100
*&---------------------------------------------------------------------*
FORM REFRESH_GRID  USING    PO_GRID TYPE REF TO CL_GUI_ALV_GRID.

  DATA: LS_SCROLL   TYPE LVC_S_STBL.

  LS_SCROLL-ROW = 'X'.
  LS_SCROLL-COL = 'X'.

  CASE PO_GRID.
    WHEN GO_GRID_0100.
      GO_GRID_0100->SET_FRONTEND_LAYOUT( IS_LAYOUT = GS_LAYOUT_0100 ).
  ENDCASE.


  CALL METHOD PO_GRID->REFRESH_TABLE_DISPLAY
    EXPORTING
*     I_SOFT_REFRESH = 'X'
      IS_STABLE = LS_SCROLL.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROC_DEL_BOM_BY_BDC
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- <LS_MOSU>
*&---------------------------------------------------------------------*
FORM PROC_DEL_BOM_BY_BDC  CHANGING PS_MOSU LIKE GS_MAIN_DISP.

  REFRESH : GT_BDCDATA, GT_MESSTAB.

  __SETTING_BDC_PARAMS.

  __BDC_DYNPRO 'SAPLCSDI' '0100'.
  __BDC_FIELD : 'BDC_OKCODE' '/00',
                      'RC29N-MATNR'  PS_MOSU-IDNRK,
                      'RC29N-WERKS'  P_WERKS,
                      'RC29N-STLAN'  PS_MOSU-STLAN,
                      'RC29N-STLAL'  PS_MOSU-STLAL.

  __BDC_DYNPRO 'SAPLCSDI' '2150'.
  __BDC_FIELD : 'BDC_OKCODE' '=FCLO'.

  __BDC_DYNPRO 'SAPLSPO1' '0100'.
  __BDC_FIELD : 'BDC_OKCODE' '=YES'.

  __BDC_TRANSACTION 'CS02'.

  READ TABLE GT_MESSTAB INTO DATA(LS_MESSTAB) WITH KEY MSGTYP = 'E'.
  IF SY-SUBRC EQ 0.
    PS_MOSU-STATUS = ICON_LED_RED.
    MESSAGE ID LS_MESSTAB-MSGID TYPE 'S' NUMBER LS_MESSTAB-MSGNR
        WITH LS_MESSTAB-MSGV1 LS_MESSTAB-MSGV2 LS_MESSTAB-MSGV3 LS_MESSTAB-MSGV4
        INTO  PS_MOSU-MESSAGE.
  ELSE.
    PS_MOSU-STATUS = ICON_LED_GREEN.
    PS_MOSU-MESSAGE = 'BOM을 성공적으로 삭제하였습니다.'.
    COMMIT WORK AND  WAIT.
  ENDIF.

ENDFORM.
