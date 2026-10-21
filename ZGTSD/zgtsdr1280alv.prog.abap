*&---------------------------------------------------------------------*
*& Include          ZGTSDR1280ALV
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form INIT_CONTROLS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM INIT_CONTROLS_0100 .
  IF GO_GRID IS NOT INITIAL.
    CALL METHOD GO_GRID->FREE.
  ENDIF.

  IF GO_CCON IS NOT INITIAL.
    CALL METHOD GO_CCON->FREE.
  ENDIF.
  CLEAR: GO_GRID,GO_CCON.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form REFRESH_ALV
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GC_ALV_GRID
*&---------------------------------------------------------------------*
FORM REFRESH_ALV  USING   PC_GRID
                         TYPE REF TO CL_GUI_ALV_GRID.
  DATA: LS_STABLE TYPE LVC_S_STBL.
  LS_STABLE-ROW = 'X'.
  LS_STABLE-COL = 'X'.
  IF PC_GRID IS NOT INITIAL.
    CALL METHOD PC_GRID->REFRESH_TABLE_DISPLAY
      EXPORTING
        IS_STABLE = LS_STABLE.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_CHANGED_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CHECK_CHANGED_DATA USING PC_GRID
                         TYPE REF TO CL_GUI_ALV_GRID.
  DATA LV_VALID TYPE CHAR01.

  CALL METHOD PC_GRID->CHECK_CHANGED_DATA
    IMPORTING
      E_VALID = LV_VALID.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form ALV_CONTROLS_0100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM ALV_CONTROLS_0100 .
  IF GO_CCON IS INITIAL.
    PERFORM CREATE_CONTAINER USING GO_CCON 'CONT0100'.

*    PERFORM SET_ALV_HEADER_0100.

    PERFORM CREATE_ALV_0100 USING GO_CCON
                                  GO_GRID.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form CREATE_CONTAINER
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GO_CCON
*&      --> P_
*&---------------------------------------------------------------------*
FORM CREATE_CONTAINER  USING    PO_CCON TYPE REF TO
                                 CL_GUI_CUSTOM_CONTAINER
                                P_CONT.

  CREATE OBJECT PO_CCON
    EXPORTING
      CONTAINER_NAME = P_CONT.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CREATE_ALV_0100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GO_CCON
*&      --> GO_GRID
*&---------------------------------------------------------------------*
FORM CREATE_ALV_0100  USING    PO_CCON TYPE REF TO
                                 CL_GUI_CUSTOM_CONTAINER
                               PO_GRID TYPE REF TO
                                 CL_GUI_ALV_GRID.

  CREATE OBJECT PO_GRID
    EXPORTING
      I_PARENT = PO_CCON.
*      I_APPL_EVENTS = 'X'.

* Set Variant
  PERFORM SET_VARIANT_0100.

* SET LAYOUT
  PERFORM SET_LAYOUT_0100.

* SET SORT
  PERFORM SET_SORT_0100.

* SET FIELDCAT
  PERFORM SET_FIELDCAT_0100.

* Set Event Handler
  PERFORM SET_EVENT_HANDLER_0100 USING GO_GRID.

* EXCLUDING TOOLBAR
  CLEAR: GT_EXCLUDE[].
  PERFORM EXCLUDE_TB_FUNCTIONS_0100 USING 'GT_EXCLUDE'.

* CELL ATTRIBUTES
  PERFORM CELL_ATTRIBUTES_0100.

* ALV GRID
  PERFORM DISPLAY_ALV_0100.

* F4
  PERFORM SET_F4_0100.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_VARIANT_0100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_VARIANT_0100 .
  CLEAR : GS_VARIANT.

  GS_VARIANT-REPORT   = SY-REPID.
  GS_VARIANT-USERNAME = SY-UNAME.
  GS_VARIANT-HANDLE   = SY-DYNNR.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_LAYOUT_0100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_LAYOUT_0100 .
  CLEAR: GS_LAYOUT.
  GS_LAYOUT-ZEBRA        = GC_X.
*  GS_LAYOUT-EDIT         = GC_X.
*  GS_LAYOUT-CWIDTH_OPT   = GC_X.
  GS_LAYOUT-SEL_MODE     = 'D'.      "선택모드
*  GS_LAYOUT-SMALLTITLE   = GC_X.
*  GS_LAYOUT-GRID_TITLE   = GV_GRID_TITLE.

*  GS_LAYOUT-NO_ROWMARK   = GC_X.      "선택버튼제거.
  GS_LAYOUT-STYLEFNAME   = 'CELLTAB'.
  GS_LAYOUT-CTAB_FNAME   = 'COLOR'.
*  GS_LAYOUT-INFO_FNAME = 'LINECOL'.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_SORT_0100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_SORT_0100 .
  DATA: LV_SPOS  TYPE SLIS_SPOS.
  CLEAR: GT_SORT[].

*  CLEAR GS_SORT.
*  LV_SPOS = LV_SPOS + 1.
*  GS_SORT-SPOS = LV_SPOS.
*  GS_SORT-FIELDNAME = 'CRDAT'.
*  GS_SORT-DOWN = GC_X.
*  APPEND GS_SORT TO GT_SORT.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_FIELDCAT_0100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_FIELDCAT_0100 .
  CLEAR: GT_FIELDCAT[].

  PERFORM CREATE_FIELDCAT USING 'GT_0100'
                                GT_FIELDCAT.

  PERFORM MODIFY_FIELDCAT_0100 USING GT_FIELDCAT.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form CREATE_FIELDCAT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> GT_FIELDCAT
*&---------------------------------------------------------------------*
FORM CREATE_FIELDCAT  USING    P_TABNAME
                               PT_FIELDCAT TYPE LVC_T_FCAT.
  DATA : LT_FCAT TYPE SLIS_T_FIELDCAT_ALV WITH HEADER LINE.
  DATA : LV_INTERNAL_TABNAME TYPE  SLIS_TABNAME,
         LV_STRUCTURE_NAME   LIKE  DD02L-TABNAME,
         LV_INCLNAME         LIKE  TRDIR-NAME.

  DATA : LV_TABLE TYPE FELD-NAME.
  FIELD-SYMBOLS <FS_TABLE> TYPE STANDARD TABLE.

  CONCATENATE P_TABNAME '[]' INTO LV_TABLE.
  ASSIGN (LV_TABLE) TO <FS_TABLE>.

  CLEAR : LV_INTERNAL_TABNAME, LV_INCLNAME.
  LV_INTERNAL_TABNAME = P_TABNAME.      " 인터널 데이블
  LV_INCLNAME         = |{ SY-REPID }TOP|.

  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      I_PROGRAM_NAME     = SY-REPID
      I_INTERNAL_TABNAME = LV_INTERNAL_TABNAME
      I_INCLNAME         = LV_INCLNAME
      I_BYPASSING_BUFFER = 'X'
*     I_STRUCTURE_NAME   = I_INTERNAL_TABNAME
    CHANGING
      CT_FIELDCAT        = LT_FCAT[].

  CALL FUNCTION 'LVC_TRANSFER_FROM_SLIS'
    EXPORTING
      IT_FIELDCAT_ALV = LT_FCAT[]
    IMPORTING
      ET_FIELDCAT_LVC = PT_FIELDCAT[]
    TABLES
      IT_DATA         = <FS_TABLE>.

  CALL FUNCTION 'LVC_FIELDCAT_COMPLETE'
    EXPORTING
      I_REFRESH_BUFFER = 'X'
    CHANGING
      CT_FIELDCAT      = PT_FIELDCAT.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form MODIFY_FIELDCAT_0100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_FIELDCAT
*&---------------------------------------------------------------------*
FORM MODIFY_FIELDCAT_0100  USING   PT_FIELDCAT TYPE LVC_T_FCAT.

  LOOP AT PT_FIELDCAT INTO GS_FIELDCAT.
    CASE GS_FIELDCAT-FIELDNAME.
      WHEN 'SEL'.
        GS_FIELDCAT-KEY = GC_X.
        GS_FIELDCAT-CHECKBOX = GC_X.
        GS_FIELDCAT-JUST = GC_C.
        GS_FIELDCAT-OUTPUTLEN = 3.
        PERFORM SET_TEXT USING TEXT-H01.
      WHEN 'STAT'.
        GS_FIELDCAT-KEY = GC_X.
        GS_FIELDCAT-ICON = GC_X.
        GS_FIELDCAT-JUST = GC_C.
        GS_FIELDCAT-OUTPUTLEN = 3.
        PERFORM SET_TEXT USING TEXT-H02.

      WHEN 'LIFNR'.
        GS_FIELDCAT-KEY = GC_X.
        GS_FIELDCAT-EMPHASIZE = 'C310'.
        GS_FIELDCAT-OUTPUTLEN = 10.
        PERFORM SET_TEXT USING TEXT-H10.
      WHEN 'TYPE'.
        GS_FIELDCAT-KEY = GC_X.
        GS_FIELDCAT-OUTPUTLEN = 6.
        PERFORM SET_TEXT USING TEXT-H11.
      WHEN 'BU_GROUP'.
        GS_FIELDCAT-KEY = GC_X.
        GS_FIELDCAT-OUTPUTLEN = 5.
        PERFORM SET_TEXT USING TEXT-H12.
      WHEN 'RLTYP'.
        GS_FIELDCAT-KEY = GC_X.
        GS_FIELDCAT-OUTPUTLEN = 4.
        PERFORM SET_TEXT USING TEXT-H13.
      WHEN 'BUKRS'.
        GS_FIELDCAT-KEY = GC_X.
        GS_FIELDCAT-OUTPUTLEN = 5.
        PERFORM SET_TEXT USING TEXT-H14.
      WHEN 'KUNNR'.
        GS_FIELDCAT-KEY = GC_X.
        GS_FIELDCAT-EMPHASIZE = 'C310'.
        GS_FIELDCAT-OUTPUTLEN = 10.
        PERFORM SET_TEXT USING TEXT-H15.
      WHEN 'NAME1'.
        GS_FIELDCAT-OUTPUTLEN = 15.
        PERFORM SET_TEXT USING TEXT-H16.
      WHEN 'NAME2'.
        GS_FIELDCAT-OUTPUTLEN = 15.
        PERFORM SET_TEXT USING TEXT-H17.
      WHEN 'SORT1'.
        GS_FIELDCAT-OUTPUTLEN = 10.
        PERFORM SET_TEXT USING TEXT-H18.
      WHEN 'POST_CODE1'.
        GS_FIELDCAT-OUTPUTLEN = 10.
        PERFORM SET_TEXT USING TEXT-H19.
      WHEN 'CITY1'.
        GS_FIELDCAT-OUTPUTLEN = 15.
        PERFORM SET_TEXT USING TEXT-H20.
      WHEN 'STREET'.
        GS_FIELDCAT-OUTPUTLEN = 15.
        PERFORM SET_TEXT USING TEXT-H21.
      WHEN 'COUNTRY'.
        GS_FIELDCAT-OUTPUTLEN = 15.
        PERFORM SET_TEXT USING TEXT-H22.
      WHEN 'REGION'.
        GS_FIELDCAT-OUTPUTLEN = 4.
        PERFORM SET_TEXT USING TEXT-H23.
      WHEN 'LANGU'.
        GS_FIELDCAT-OUTPUTLEN = 4.
        PERFORM SET_TEXT USING TEXT-H24.
      WHEN 'TEL_NUMBER'.
        GS_FIELDCAT-OUTPUTLEN = 15.
        PERFORM SET_TEXT USING TEXT-H25.
      WHEN 'SMTP_ADDR'.
        GS_FIELDCAT-OUTPUTLEN = 20.
        PERFORM SET_TEXT USING TEXT-H26.
      WHEN 'EXTENSION1'.
        GS_FIELDCAT-OUTPUTLEN = 15.
        PERFORM SET_TEXT USING TEXT-H27.
      WHEN 'AKONT'.
        GS_FIELDCAT-OUTPUTLEN = 10.
        PERFORM SET_TEXT USING TEXT-H28.
      WHEN 'RISK_CLASS'.
        GS_FIELDCAT-OUTPUTLEN = 5.
        PERFORM SET_TEXT USING TEXT-H29.
      WHEN 'MESSAGE'.
        GS_FIELDCAT-OUTPUTLEN = 50.
        PERFORM SET_TEXT USING TEXT-H30.


      WHEN OTHERS.
        GS_FIELDCAT-NO_OUT = GC_X.
    ENDCASE.
    MODIFY PT_FIELDCAT FROM GS_FIELDCAT.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_TEXT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> TEXT_H00
*&---------------------------------------------------------------------*
FORM SET_TEXT  USING    P_TEXT.
  GS_FIELDCAT-SCRTEXT_S =
  GS_FIELDCAT-SCRTEXT_M =
  GS_FIELDCAT-SCRTEXT_L =
  GS_FIELDCAT-COLTEXT   =
  GS_FIELDCAT-SELTEXT   =
  GS_FIELDCAT-TOOLTIP   = P_TEXT.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_EVENT_HANDLER_0100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GO_GRID
*&---------------------------------------------------------------------*
FORM SET_EVENT_HANDLER_0100  USING  PO_GRID TYPE REF TO CL_GUI_ALV_GRID.

  CREATE OBJECT GO_EVENT_RECEIVER.

  CALL METHOD PO_GRID->REGISTER_EDIT_EVENT
    EXPORTING
      I_EVENT_ID = CL_GUI_ALV_GRID=>MC_EVT_ENTER.

  CALL METHOD PO_GRID->REGISTER_EDIT_EVENT
    EXPORTING
      I_EVENT_ID = CL_GUI_ALV_GRID=>MC_EVT_MODIFIED.


  SET HANDLER GO_EVENT_RECEIVER->HANDLE_DATA_CHANGED     FOR PO_GRID .
*  SET HANDLER GO_EVENT_RECEIVER->HANDLE_CHANGED_FINISHED FOR PO_GRID.
*  SET HANDLER GO_EVENT_RECEIVER->HANDLE_SUBTOTAL_TEXT    FOR PO_GRID.
  SET HANDLER GO_EVENT_RECEIVER->HANDLE_DOUBLE_CLICK     FOR PO_GRID.
*  SET HANDLER GO_EVENT_RECEIVER->HANDLE_HOTSPOT_CLICK    FOR PO_GRID.
  SET HANDLER GO_EVENT_RECEIVER->HANDLE_TOOLBAR          FOR PO_GRID.
  SET HANDLER GO_EVENT_RECEIVER->HANDLE_USER_COMMAND     FOR PO_GRID.
*  SET HANDLER GO_EVENT_RECEIVER->HANDLE_ONF4             FOR PO_GRID.
*  SET HANDLER GO_EVENT_RECEIVER->HANDLE_TOP_OF_PAGE   FOR PA_GRID.

  IF GV_EDIT IS NOT INITIAL.
    CALL METHOD PO_GRID->SET_READY_FOR_INPUT
      EXPORTING
        I_READY_FOR_INPUT = 1.

  ELSE.
    CALL METHOD PO_GRID->SET_READY_FOR_INPUT
      EXPORTING
        I_READY_FOR_INPUT = 0.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form EXCLUDE_TB_FUNCTIONS_0100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&---------------------------------------------------------------------*
FORM EXCLUDE_TB_FUNCTIONS_0100  USING    P_TABNAME.
*  툴바의 버튼중 나타내지 않을 버튼을 지정한다.
  FIELD-SYMBOLS : <TABLE> TYPE UI_FUNCTIONS.

  DATA : LS_EXCLUDE   TYPE UI_FUNC.
  DATA : L_TABLE_NAME LIKE FELD-NAME.

  CONCATENATE P_TABNAME '[]' INTO  L_TABLE_NAME.
  ASSIGN     (L_TABLE_NAME)    TO <TABLE>.

  PERFORM APPEND_EXCLUDE_FUNCTIONS
        TABLES <TABLE>
*        USING : cl_gui_alv_grid=>mc_fc_excl_all. " ** 툴바 모두제거 **
         USING : CL_GUI_ALV_GRID=>MC_FC_LOC_UNDO, " 실행취소 &LOCAL&UNDO
*                cl_gui_alv_grid=>mc_fc_auf,      " 소계확장 &AUF
*                cl_gui_alv_grid=>mc_fc_average,  " &AVERAGE
*                cl_gui_alv_grid=>mc_fc_back_classic,
*                cl_gui_alv_grid=>mc_fc_call_abc, " &ABC
*                cl_gui_alv_grid=>mc_fc_call_chain,
*                cl_gui_alv_grid=>mc_fc_call_crbatch,
*                cl_gui_alv_grid=>mc_fc_call_crweb,
*                cl_gui_alv_grid=>mc_fc_call_lineitems,
*                cl_gui_alv_grid=>mc_fc_call_master_data,
*                cl_gui_alv_grid=>mc_fc_call_more,
*                cl_gui_alv_grid=>mc_fc_call_report,
*                cl_gui_alv_grid=>mc_fc_call_xint,
*                cl_gui_alv_grid=>mc_fc_call_xxl,
*                cl_gui_alv_grid=>mc_fc_col_invisible,
*                cl_gui_alv_grid=>mc_fc_col_optimize,
*                cl_gui_alv_grid=>mc_fc_current_variant,
*                cl_gui_alv_grid=>mc_fc_data_save,
*                cl_gui_alv_grid=>mc_fc_delete_filter,
*                cl_gui_alv_grid=>mc_fc_deselect_all,
*                cl_gui_alv_grid=>mc_fc_detail,
*                cl_gui_alv_grid=>mc_fc_expcrdata,
*                cl_gui_alv_grid=>mc_fc_expcrdesig,
*                cl_gui_alv_grid=>mc_fc_expcrtempl,
*                cl_gui_alv_grid=>mc_fc_expmdb,
*                cl_gui_alv_grid=>mc_fc_extend,
*                cl_gui_alv_grid=>mc_fc_f4,
*                cl_gui_alv_grid=>mc_fc_filter,
*                cl_gui_alv_grid=>mc_fc_find,
*                cl_gui_alv_grid=>mc_fc_fix_columns,
*                cl_gui_alv_grid=>mc_fc_graph,
*                cl_gui_alv_grid=>mc_fc_help,
*                cl_gui_alv_grid=>mc_fc_info,
*                cl_gui_alv_grid=>mc_fc_load_variant,
                CL_GUI_ALV_GRID=>MC_FC_LOC_COPY,          " 행 카피.
                CL_GUI_ALV_GRID=>MC_FC_HTML,
                CL_GUI_ALV_GRID=>MC_FC_LOC_COPY_ROW,      " 행 카피.
                CL_GUI_ALV_GRID=>MC_FC_LOC_CUT,           " 가위.
                CL_GUI_ALV_GRID=>MC_FC_LOC_DELETE_ROW,    " 행삭제.
                CL_GUI_ALV_GRID=>MC_FC_LOC_INSERT_ROW,    " 행삽입.
                CL_GUI_ALV_GRID=>MC_FC_LOC_MOVE_ROW,
                CL_GUI_ALV_GRID=>MC_FC_LOC_APPEND_ROW,    " 라인생성.
                CL_GUI_ALV_GRID=>MC_FC_LOC_PASTE,         " 겹쳐쓰기.
                CL_GUI_ALV_GRID=>MC_FC_LOC_PASTE_NEW_ROW, " 겹쳐쓰기.
*                cl_gui_alv_grid=>mc_fc_maintain_variant,
*                cl_gui_alv_grid=>mc_fc_maximum,
*                cl_gui_alv_grid=>mc_fc_minimum,
*                cl_gui_alv_grid=>mc_fc_pc_file,
*                cl_gui_alv_grid=>mc_fc_print,
*                cl_gui_alv_grid=>mc_fc_print_back,
*                cl_gui_alv_grid=>mc_fc_print_prev,
                CL_GUI_ALV_GRID=>MC_FC_REFRESH.
*                cl_gui_alv_grid=>mc_fc_reprep,
*                cl_gui_alv_grid=>mc_fc_save_variant,
*                cl_gui_alv_grid=>mc_fc_select_all,
*                cl_gui_alv_grid=>mc_fc_send,
*                cl_gui_alv_grid=>mc_fc_separator,
*                CL_GUI_ALV_GRID=>MC_FC_SORT,
*                CL_GUI_ALV_GRID=>MC_FC_SORT_ASC,
*                CL_GUI_ALV_GRID=>MC_FC_SORT_DSC.
*                CL_GUI_ALV_GRID=>MC_FC_SUBTOT,
*                CL_GUI_ALV_GRID=>MC_FC_SUM
*                cl_gui_alv_grid=>mc_fc_to_office,
*                cl_gui_alv_grid=>mc_fc_to_rep_tree,
*                cl_gui_alv_grid=>mc_fc_unfix_columns,
*                cl_gui_alv_grid=>mc_fc_views,
*                cl_gui_alv_grid=>mc_fc_view_crystal,
*                cl_gui_alv_grid=>mc_fc_view_excel,
*                cl_gui_alv_grid=>mc_fc_view_grid,
*                cl_gui_alv_grid=>mc_fc_word_processor.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form APPEND_EXCLUDE_FUNCTIONS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> <TABLE>
*&      --> CL_GUI_ALV_GRID=>MC_FC_LOC_UND
*&---------------------------------------------------------------------*
FORM APPEND_EXCLUDE_FUNCTIONS  TABLES P_TABLE
                                USING P_VALUE.
  DATA : LS_EXCLUDE TYPE UI_FUNC.
  LS_EXCLUDE = P_VALUE.
  APPEND LS_EXCLUDE TO P_TABLE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form DISPLAY_ALV_0100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM DISPLAY_ALV_0100 .
  CALL METHOD GO_GRID->SET_TABLE_FOR_FIRST_DISPLAY
    EXPORTING
      IS_LAYOUT            = GS_LAYOUT
      IS_VARIANT           = GS_VARIANT
      I_SAVE               = 'A'
      IT_TOOLBAR_EXCLUDING = GT_EXCLUDE[]
      I_BYPASSING_BUFFER   = 'X'
    CHANGING
      IT_OUTTAB            = GT_0100[]
      IT_FIELDCATALOG      = GT_FIELDCAT[]
      IT_SORT              = GT_SORT[].
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_F4_0100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_F4_0100 .
* F4 FIELD 등록.
* 주의할점-필드명을 ABC순으로 기술하여야 함
  CLEAR:GT_F4[].

*  CLEAR GS_F4.
*  GS_F4-FIELDNAME = 'ZTERM'.
*  GS_F4-REGISTER  = GC_X.
*  APPEND GS_F4 TO GT_F4.
*
*  CALL METHOD GO_GRID->REGISTER_F4_FOR_FIELDS
*    EXPORTING
*      IT_F4 = GT_F4.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CELL_ATTRIBUTES_0100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CELL_ATTRIBUTES_0100 .
  LOOP AT GT_0100 ASSIGNING FIELD-SYMBOL(<FS_0100>).
    PERFORM SET_ATTRIBUTES_LINE_0100 CHANGING <FS_0100>.
    PERFORM SET_COLOR_LINE_0100      CHANGING <FS_0100>.
  ENDLOOP.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_ATTRIBUTES_LINE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- <FS_LIST>
*&---------------------------------------------------------------------*
FORM SET_ATTRIBUTES_LINE_0100  CHANGING PS_0100 LIKE GT_0100.
  DATA : LT_CELLTAB TYPE LVC_T_STYL.
  DATA : WA_CELLTAB TYPE LVC_S_STYL.

  CLEAR PS_0100-CELLTAB[].

  LOOP AT GT_FIELDCAT INTO DATA(LS_FCAT).
    CLEAR:WA_CELLTAB.
    WA_CELLTAB-FIELDNAME = LS_FCAT-FIELDNAME.
    CASE LS_FCAT-FIELDNAME.
      WHEN 'SEL'.
        IF PS_0100-RSLT EQ GC_S.
          WA_CELLTAB-STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED.
        ELSE.
          WA_CELLTAB-STYLE = CL_GUI_ALV_GRID=>MC_STYLE_ENABLED.
        ENDIF.

      WHEN OTHERS.
        WA_CELLTAB-STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED.

    ENDCASE.
    INSERT WA_CELLTAB INTO TABLE LT_CELLTAB.
  ENDLOOP.
  INSERT LINES OF LT_CELLTAB INTO TABLE PS_0100-CELLTAB.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form ALV_CONTROLS_0200
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM ALV_CONTROLS_0200 .
  IF GO_CCON IS INITIAL.
    PERFORM CREATE_CONTAINER USING GO_CCON 'CONT0200'.

*    PERFORM SET_ALV_HEADER_0100.

    PERFORM CREATE_ALV_0200 USING GO_CCON
                                  GO_GRID.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form CREATE_ALV_0200
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GO_CCON
*&      --> GO_GRID
*&---------------------------------------------------------------------*
FORM CREATE_ALV_0200  USING    PO_CCON TYPE REF TO
                                 CL_GUI_CUSTOM_CONTAINER
                               PO_GRID TYPE REF TO
                                 CL_GUI_ALV_GRID.

  CREATE OBJECT PO_GRID
    EXPORTING
      I_PARENT = PO_CCON.
*      I_APPL_EVENTS = 'X'.

* Set Variant
  PERFORM SET_VARIANT_0200.

* SET LAYOUT
  PERFORM SET_LAYOUT_0200.

* SET SORT
  PERFORM SET_SORT_0200.

* SET FIELDCAT
  PERFORM SET_FIELDCAT_0200.

* Set Event Handler
  PERFORM SET_EVENT_HANDLER_0100 USING GO_GRID.

* EXCLUDING TOOLBAR
  CLEAR: GT_EXCLUDE[].
  PERFORM EXCLUDE_TB_FUNCTIONS_0100 USING 'GT_EXCLUDE'.

* CELL ATTRIBUTES
  PERFORM CELL_ATTRIBUTES_0200.

* ALV GRID
  PERFORM DISPLAY_ALV_0200.

* F4
  PERFORM SET_F4_0200.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_VARIANT_0200
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_VARIANT_0200 .
  CLEAR : GS_VARIANT.

  GS_VARIANT-REPORT   = SY-REPID.
  GS_VARIANT-USERNAME = SY-UNAME.
  GS_VARIANT-HANDLE   = SY-DYNNR.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_LAYOUT_0200
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_LAYOUT_0200 .
  CLEAR: GS_LAYOUT.
  GS_LAYOUT-ZEBRA        = GC_X.
*  GS_LAYOUT-EDIT         = GC_X.
*  GS_LAYOUT-CWIDTH_OPT   = GC_X.
  GS_LAYOUT-SEL_MODE     = 'D'.      "선택모드
*  GS_LAYOUT-SMALLTITLE   = GC_X.
*  GS_LAYOUT-GRID_TITLE   = GV_GRID_TITLE.

*  GS_LAYOUT-NO_ROWMARK   = GC_X.      "선택버튼제거.
  GS_LAYOUT-STYLEFNAME   = 'CELLTAB'.
  GS_LAYOUT-CTAB_FNAME   = 'COLOR'.
*  GS_LAYOUT-INFO_FNAME = 'LINECOL'.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_SORT_0200
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_SORT_0200 .
  DATA: LV_SPOS  TYPE SLIS_SPOS.
  CLEAR: GT_SORT[].

*  CLEAR GS_SORT.
*  LV_SPOS = LV_SPOS + 1.
*  GS_SORT-SPOS = LV_SPOS.
*  GS_SORT-FIELDNAME = 'CRDAT'.
*  GS_SORT-DOWN = GC_X.
*  APPEND GS_SORT TO GT_SORT.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_FIELDCAT_0200
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_FIELDCAT_0200 .
  CLEAR: GT_FIELDCAT[].

  PERFORM CREATE_FIELDCAT USING 'GT_0200'
                                GT_FIELDCAT.

  PERFORM MODIFY_FIELDCAT_0200 USING GT_FIELDCAT.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form MODIFY_FIELDCAT_0200
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_FIELDCAT
*&---------------------------------------------------------------------*
FORM MODIFY_FIELDCAT_0200  USING    PT_FIELDCAT TYPE LVC_T_FCAT.

  LOOP AT PT_FIELDCAT INTO GS_FIELDCAT.
    CASE GS_FIELDCAT-FIELDNAME.
      WHEN 'SEL'.
        GS_FIELDCAT-KEY = GC_X.
        GS_FIELDCAT-CHECKBOX = GC_X.
        GS_FIELDCAT-JUST = GC_C.
        GS_FIELDCAT-OUTPUTLEN = 3.
        PERFORM SET_TEXT USING TEXT-H01.
      WHEN 'STAT'.
        GS_FIELDCAT-KEY = GC_X.
        GS_FIELDCAT-ICON = GC_X.
        GS_FIELDCAT-JUST = GC_C.
        GS_FIELDCAT-OUTPUTLEN = 3.
        PERFORM SET_TEXT USING TEXT-H02.
      WHEN 'LIFNR'.
        GS_FIELDCAT-KEY = GC_X.
        GS_FIELDCAT-OUTPUTLEN = 10.
        GS_FIELDCAT-EMPHASIZE = 'C300'.
        PERFORM SET_TEXT USING TEXT-H50.
      WHEN 'RLTYP'.
        GS_FIELDCAT-KEY = GC_X.
        GS_FIELDCAT-OUTPUTLEN = 7.
        PERFORM SET_TEXT USING TEXT-H51.
      WHEN 'VKORG'.
        GS_FIELDCAT-KEY = GC_X.
        GS_FIELDCAT-OUTPUTLEN = 5.
        PERFORM SET_TEXT USING TEXT-H52.
      WHEN 'VTWEG'.
        GS_FIELDCAT-OUTPUTLEN = 5.
        PERFORM SET_TEXT USING TEXT-H53.
      WHEN 'SPART'.
        GS_FIELDCAT-OUTPUTLEN = 4.
        PERFORM SET_TEXT USING TEXT-H54.
      WHEN 'KUNNR'.
        GS_FIELDCAT-OUTPUTLEN = 10.
        GS_FIELDCAT-EMPHASIZE = 'C300'.
        PERFORM SET_TEXT USING TEXT-H55.
      WHEN 'NAME1'.
        GS_FIELDCAT-OUTPUTLEN = 15.
        PERFORM SET_TEXT USING TEXT-H56.
      WHEN 'KALKS'.
        GS_FIELDCAT-OUTPUTLEN = 10.
        PERFORM SET_TEXT USING TEXT-H57.
      WHEN 'BOKRE'.
        GS_FIELDCAT-OUTPUTLEN = 6.
        PERFORM SET_TEXT USING TEXT-H58.
      WHEN 'PRFRE'.
        GS_FIELDCAT-OUTPUTLEN = 6.
        PERFORM SET_TEXT USING TEXT-H59.

      WHEN 'MESSAGE'.
        GS_FIELDCAT-OUTPUTLEN = 50.
        PERFORM SET_TEXT USING TEXT-H30.


      WHEN OTHERS.
        GS_FIELDCAT-NO_OUT = GC_X.
    ENDCASE.
    MODIFY PT_FIELDCAT FROM GS_FIELDCAT.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CELL_ATTRIBUTES_0200
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CELL_ATTRIBUTES_0200 .
  LOOP AT GT_0200 ASSIGNING FIELD-SYMBOL(<FS_0200>).
    PERFORM SET_ATTRIBUTES_LINE_0200 CHANGING <FS_0200>.
    PERFORM SET_COLOR_LINE_0200      CHANGING <FS_0200>.
  ENDLOOP.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form DISPLAY_ALV_0200
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM DISPLAY_ALV_0200 .
  CALL METHOD GO_GRID->SET_TABLE_FOR_FIRST_DISPLAY
    EXPORTING
      IS_LAYOUT            = GS_LAYOUT
      IS_VARIANT           = GS_VARIANT
      I_SAVE               = 'A'
      IT_TOOLBAR_EXCLUDING = GT_EXCLUDE[]
      I_BYPASSING_BUFFER   = 'X'
    CHANGING
      IT_OUTTAB            = GT_0200[]
      IT_FIELDCATALOG      = GT_FIELDCAT[]
      IT_SORT              = GT_SORT[].
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_F4_0200
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_F4_0200 .
* F4 FIELD 등록.
* 주의할점-필드명을 ABC순으로 기술하여야 함
  CLEAR:GT_F4[].

*  CLEAR GS_F4.
*  GS_F4-FIELDNAME = 'ZTERM'.
*  GS_F4-REGISTER  = GC_X.
*  APPEND GS_F4 TO GT_F4.
*
*  CALL METHOD GO_GRID->REGISTER_F4_FOR_FIELDS
*    EXPORTING
*      IT_F4 = GT_F4.
ENDFORM.
