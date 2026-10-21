*&---------------------------------------------------------------------*
*& Include          ZGTSDR2020ALV
*&---------------------------------------------------------------------*
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
*& Form INIT_CONTROLS_0100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM INIT_CONTROLS_0100 .
  IF GO_GRID1 IS NOT INITIAL.
    CALL METHOD GO_GRID1->FREE.
  ENDIF.
  IF GO_GRID2 IS NOT INITIAL.
    CALL METHOD GO_GRID2->FREE.
  ENDIF.

  IF GO_CCON1 IS NOT INITIAL.
    CALL METHOD GO_CCON1->FREE.
  ENDIF.
  IF GO_CCON2 IS NOT INITIAL.
    CALL METHOD GO_CCON2->FREE.
  ENDIF.


  CLEAR: GO_GRID1,GO_GRID2,GO_CCON1,GO_CCON2.

*  IF GO_GCON1 IS NOT INITIAL.
*    CALL METHOD GO_GCON1->FREE.
*  ENDIF.
*  IF GO_GCON2 IS NOT INITIAL.
*    CALL METHOD GO_GCON2->FREE.
*  ENDIF.
*
*  IF GO_CCON IS NOT INITIAL.
*    CALL METHOD GO_CCON->FREE.
*  ENDIF.
*
*
*  CLEAR: GO_GRID1,GO_CCON,GO_GRID2,GO_GCON1,GO_GCON2.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form INIT_CONTROLS_0200
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM INIT_CONTROLS_0200 .
  IF GO_GRID3 IS NOT INITIAL.
    CALL METHOD GO_GRID3->FREE.
  ENDIF.

  IF GO_CCON3 IS NOT INITIAL.
    CALL METHOD GO_CCON3->FREE.
  ENDIF.

  CLEAR: GO_GRID3,GO_CCON3.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_CUSTOM_CONTAINER
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> P_2
*&      --> P_1
*&      --> P_2000
*&      <-- GO_CCON
*&      <-- GO_SPLITTER
*&---------------------------------------------------------------------*
FORM SET_CUSTOM_CONTAINER  USING P_CON_NAME
                                P_ROWS
                                P_COLUMNS
                                P_EXTENSION
                          CHANGING P_CUSTOM TYPE REF TO CL_GUI_CUSTOM_CONTAINER
                                   PC_SPLITTER TYPE REF TO CL_GUI_SPLITTER_CONTAINER.
  CHECK P_CUSTOM IS INITIAL.
  CREATE OBJECT P_CUSTOM
    EXPORTING
      CONTAINER_NAME = P_CON_NAME.

  CREATE OBJECT PC_SPLITTER
    EXPORTING
      PARENT            = P_CUSTOM
      ROWS              = P_ROWS
      COLUMNS           = P_COLUMNS
    EXCEPTIONS
      CNTL_ERROR        = 1
      CNTL_SYSTEM_ERROR = 2.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_ALV_CONTAINER
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GO_SPLITTER
*&      --> P_1
*&      --> P_1
*&      <-- GO_GCON1
*&---------------------------------------------------------------------*
FORM SET_ALV_CONTAINER  USING    PC_SPLITTER TYPE REF TO CL_GUI_SPLITTER_CONTAINER
                                 P_ROWS
                                 P_COLUMNS
                            CHANGING PC_CONTAINER TYPE REF TO CL_GUI_CONTAINER.
  CALL METHOD PC_SPLITTER->GET_CONTAINER
    EXPORTING
      ROW       = P_ROWS
      COLUMN    = P_COLUMNS
    RECEIVING
      CONTAINER = PC_CONTAINER.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_ALV_0100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GO_SPLITTER
*&      --> P_1
*&      --> P_1
*&      --> P_50
*&      --> GO_GCON1
*&      <-- GO_GRID1
*&---------------------------------------------------------------------*
FORM SET_ALV_0100  USING    PC_SPLITTER TYPE REF TO CL_GUI_SPLITTER_CONTAINER
                     P_ROWS
                     P_COLUMNS
                     P_HEIGHT

                     PC_CONTAINER TYPE REF TO CL_GUI_CONTAINER
              CHANGING PC_GRID TYPE REF TO CL_GUI_ALV_GRID.

  CALL METHOD PC_SPLITTER->SET_ROW_SASH
    EXPORTING
      ID    = P_ROWS
      TYPE  = 1
      VALUE = 1.

  CALL METHOD PC_SPLITTER->SET_ROW_HEIGHT
    EXPORTING
      ID     = P_ROWS
      HEIGHT = P_HEIGHT.
  "## ##
*  CALL METHOD PC_SPLITTER->SET_COLUMN_WIDTH
*    EXPORTING
*      ID    = P_ROWS
*      WIDTH = P_WIDTH.

  CREATE OBJECT PC_GRID
    EXPORTING
      I_PARENT = PC_CONTAINER.
*     i_shellstyle  = ws_dlgframe
*      I_APPL_EVENTS = GC_X.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form DISPLAY_ALV_GRID_0100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM DISPLAY_ALV_GRID_0100 .
*-GRID1
  PERFORM DISPLAY_ALV_GRID_0100_TOP USING GO_GRID1.
*-GRID2
  PERFORM DISPLAY_ALV_GRID_0100_BOT USING GO_GRID2.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form DISPLAY_ALV_GRID_0100_H
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GO_GRID1
*&---------------------------------------------------------------------*
FORM DISPLAY_ALV_GRID_0100_TOP  USING PO_GRID TYPE REF TO
                                       CL_GUI_ALV_GRID.

* Set Variant
  PERFORM SET_VARIANT_0100_TOP.

* SET LAYOUT
  PERFORM SET_LAYOUT_0100_TOP.

* SET SORT
  PERFORM SET_SORT_0100_TOP.

* SET FIELDCAT
  PERFORM SET_FIELDCAT_0100_TOP.

* Set Event Handler
  PERFORM SET_EVENT_HANDLER_0100 USING PO_GRID.

* EXCLUDING TOOLBAR
  CLEAR: GT_EXCLUDE1[].
  PERFORM EXCLUDE_TB_FUNCTIONS_0100 USING 'GT_EXCLUDE1'.

* CELL ATTRIBUTES
  PERFORM CELL_ATTRIBUTES_0100_TOP.

* ALV GRID
  PERFORM DISPLAY_ALV_0100_TOP.

* F4
  PERFORM SET_F4_0100_TOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_VARIANT_0100_H
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_VARIANT_0100_TOP .
  CLEAR : GS_VARIANT1.

  GS_VARIANT1-REPORT   = SY-REPID.
  GS_VARIANT1-HANDLE   = 1.
  GS_VARIANT1-USERNAME = SY-UNAME.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_LAYOUT_0100_H
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_LAYOUT_0100_TOP .
  CLEAR: GS_LAYOUT1.
  GS_LAYOUT1-ZEBRA        = GC_X.
*  GS_LAYOUT1-EDIT         = GC_X.
*  GS_LAYOUT1-CWIDTH_OPT   = GC_X.
  GS_LAYOUT1-SEL_MODE     = 'D'.      "선택모드
  GS_LAYOUT1-SMALLTITLE   = GC_X.
*  GS_LAYOUT1-GRID_TITLE   = GV_GRID_TITLE.

*  GS_LAYOUT1-NO_ROWMARK   = GC_X.      "선택버튼제거.
  GS_LAYOUT1-STYLEFNAME   = 'CELLTAB'.
*  GS_LAYOUT1-CTAB_FNAME   = 'CELLCOL'.
*  GS_LAYOUT1-INFO_FNAME = 'LINECOL'.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_SORT_0100_H
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_SORT_0100_TOP .
  DATA: LV_SPOS  TYPE SLIS_SPOS.
  CLEAR: GT_SORT1[].

*  CLEAR GS_SORT.
*  LV_SPOS = LV_SPOS + 1.
*  GS_SORT-SPOS = LV_SPOS.
*  GS_SORT-FIELDNAME = 'CRDAT'.
*  GS_SORT-DOWN = GC_X.
*  APPEND GS_SORT3 TO GT_SORT1.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_FIELDCAT_0100_H
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_FIELDCAT_0100_TOP .
  CLEAR: GT_FIELDCAT1[].

  PERFORM CREATE_FIELDCAT USING 'GT_LIST'
                                GT_FIELDCAT1.

  PERFORM MODIFY_FIELDCAT_0100_TOP USING GT_FIELDCAT1.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form CREATE_FIELDCAT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> GT_FIELDCAT1
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
*& Form MODIFY_FIELDCAT_0100_H
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_FIELDCAT1
*&---------------------------------------------------------------------*
FORM MODIFY_FIELDCAT_0100_TOP  USING  PT_FIELDCAT TYPE LVC_T_FCAT.

  LOOP AT PT_FIELDCAT INTO GS_FIELDCAT.
    CASE GS_FIELDCAT-FIELDNAME.

      WHEN 'SEL'.
        GS_FIELDCAT-KEY      = GC_X.
        GS_FIELDCAT-CHECKBOX = GC_X.
        GS_FIELDCAT-EDIT     = GC_X.
        GS_FIELDCAT-JUST = GC_C.
        GS_FIELDCAT-OUTPUTLEN = 5.
        PERFORM SET_TEXT USING TEXT-H02.
      WHEN 'ST_FINSH'.
        GS_FIELDCAT-KEY      = GC_X.
        GS_FIELDCAT-ICON = GC_X.
        GS_FIELDCAT-JUST = GC_C.
        GS_FIELDCAT-OUTPUTLEN = 3.
        PERFORM SET_TEXT USING TEXT-H03.
*      WHEN 'ST_SPLIT'.
*        GS_FIELDCAT-KEY      = GC_X.
*        GS_FIELDCAT-ICON = GC_X.
*        GS_FIELDCAT-JUST = GC_C.
*        GS_FIELDCAT-OUTPUTLEN = 5.
*        PERFORM SET_TEXT USING TEXT-H04.
      WHEN 'ST_PICK'.
        GS_FIELDCAT-KEY      = GC_X.
        GS_FIELDCAT-ICON = GC_X.
        GS_FIELDCAT-JUST = GC_C.
        GS_FIELDCAT-OUTPUTLEN = 3.
        PERFORM SET_TEXT USING TEXT-H05.
      WHEN 'ST_PGI'.
        GS_FIELDCAT-KEY      = GC_X.
        GS_FIELDCAT-ICON = GC_X.
        GS_FIELDCAT-JUST = GC_C.
        GS_FIELDCAT-OUTPUTLEN = 5.
        PERFORM SET_TEXT USING TEXT-H06.
      WHEN 'ST_BILL'.
        GS_FIELDCAT-KEY      = GC_X.
        GS_FIELDCAT-ICON = GC_X.
        GS_FIELDCAT-JUST = GC_C.
        GS_FIELDCAT-OUTPUTLEN = 5.
        PERFORM SET_TEXT USING TEXT-H07.
      WHEN 'VBELN_VA'.
        GS_FIELDCAT-KEY      = GC_X.
*        GS_FIELDCAT-ICON = GC_X.
*        GS_FIELDCAT-JUST = GC_C.
        GS_FIELDCAT-OUTPUTLEN = 10.
        PERFORM SET_TEXT USING TEXT-H08.
      WHEN 'VBELN_VL'.
        GS_FIELDCAT-KEY      = GC_X.
*        GS_FIELDCAT-ICON = GC_X.
*        GS_FIELDCAT-JUST = GC_C.
        GS_FIELDCAT-OUTPUTLEN = 10.
        PERFORM SET_TEXT USING TEXT-H09.
      WHEN 'ZDOSPLIT'.
        GS_FIELDCAT-OUTPUTLEN = 6.
        GS_FIELDCAT-JUST = GC_C.
        PERFORM SET_TEXT USING TEXT-H34.
*      WHEN 'VBELN_VLSP'.
*        GS_FIELDCAT-OUTPUTLEN = 10.
*        PERFORM SET_TEXT USING TEXT-H10.
*      WHEN 'ST_VLSP'.
*        GS_FIELDCAT-ICON = GC_X.
*        GS_FIELDCAT-JUST = GC_C.
*        GS_FIELDCAT-OUTPUTLEN = 8.
*        PERFORM SET_TEXT USING TEXT-H11.
      WHEN 'KUNAG'.
        GS_FIELDCAT-OUTPUTLEN = 8.
        PERFORM SET_TEXT USING TEXT-H12.
      WHEN 'KUNAG_TX'.
        GS_FIELDCAT-OUTPUTLEN = 15.
        PERFORM SET_TEXT USING TEXT-H13.
      WHEN 'ERDAT'.
        GS_FIELDCAT-OUTPUTLEN = 11.
        PERFORM SET_TEXT USING TEXT-H14.
*      WHEN 'WADAT_IST'.
*        GS_FIELDCAT-OUTPUTLEN = 11.
*        PERFORM SET_TEXT USING TEXT-H15.
      WHEN 'FKDAT'.
        GS_FIELDCAT-OUTPUTLEN = 11.
        PERFORM SET_TEXT USING TEXT-H35.
      WHEN 'NETWR_VF'.
        GS_FIELDCAT-OUTPUTLEN = 12.
        GS_FIELDCAT-CFIELDNAME = 'WAERK_VF'.
        PERFORM SET_TEXT USING TEXT-H36.
*      WHEN 'NETWR_INI'.
*        PERFORM SET_TEXT USING TEXT-H16.
      WHEN 'NETWR_JSJA'.
        GS_FIELDCAT-OUTPUTLEN = 12.
        GS_FIELDCAT-CFIELDNAME = 'WAERK'.
        PERFORM SET_TEXT USING TEXT-H17.
      WHEN 'WAERK'.
        GS_FIELDCAT-OUTPUTLEN = 4.
        PERFORM SET_TEXT USING TEXT-H18.
      WHEN 'KUNNR'.
        GS_FIELDCAT-OUTPUTLEN = 8.
        PERFORM SET_TEXT USING TEXT-H19.
      WHEN 'KUNNR_TX'.
        GS_FIELDCAT-OUTPUTLEN = 15.
        PERFORM SET_TEXT USING TEXT-H20.
      WHEN 'LFART'.
        GS_FIELDCAT-OUTPUTLEN = 7.
        PERFORM SET_TEXT USING TEXT-H21.
      WHEN 'AUART'.
        GS_FIELDCAT-OUTPUTLEN = 5.
        PERFORM SET_TEXT USING TEXT-H22.
      WHEN 'BSTNK'.
        GS_FIELDCAT-OUTPUTLEN = 12.
        PERFORM SET_TEXT USING TEXT-H23.
      WHEN 'VSTEL'.
        GS_FIELDCAT-OUTPUTLEN = 5.
        PERFORM SET_TEXT USING TEXT-H24.
      WHEN 'VSTEL_TX'.
        GS_FIELDCAT-OUTPUTLEN = 12.
        PERFORM SET_TEXT USING TEXT-H25.
      WHEN 'VKORG'.
        GS_FIELDCAT-OUTPUTLEN = 5.
        PERFORM SET_TEXT USING TEXT-H26.
      WHEN 'VTWEG'.
        GS_FIELDCAT-OUTPUTLEN = 4.
        PERFORM SET_TEXT USING TEXT-H27.
      WHEN 'SPART'.
        GS_FIELDCAT-OUTPUTLEN = 4.
        PERFORM SET_TEXT USING TEXT-H28.
      WHEN 'VKBUR'.
        GS_FIELDCAT-OUTPUTLEN = 5.
        PERFORM SET_TEXT USING TEXT-H29.
      WHEN 'VKBUR_TX'.
        GS_FIELDCAT-OUTPUTLEN = 10.
        PERFORM SET_TEXT USING TEXT-H30.
      WHEN 'VKGRP'.
        GS_FIELDCAT-OUTPUTLEN = 5.
        PERFORM SET_TEXT USING TEXT-H31.
      WHEN 'VKGRP_TX'.
        GS_FIELDCAT-OUTPUTLEN = 10.
        PERFORM SET_TEXT USING TEXT-H32.
      WHEN 'MESSAGE'.
        GS_FIELDCAT-OUTPUTLEN = 50.
        IF GV_DISP EQ GC_X.
          GS_FIELDCAT-NO_OUT = GC_X.
        ELSE.
          CLEAR GS_FIELDCAT-NO_OUT.
        ENDIF.
        PERFORM SET_TEXT USING TEXT-H33.

      WHEN OTHERS.
        GS_FIELDCAT-NO_OUT = GC_X.
    ENDCASE.
    MODIFY PT_FIELDCAT FROM GS_FIELDCAT.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_EVENT_HANDLER_0100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PO_GRID
*&---------------------------------------------------------------------*
FORM SET_EVENT_HANDLER_0100  USING  PO_GRID TYPE REF TO CL_GUI_ALV_GRID.

  IF GO_EVENT_RECEIVER IS INITIAL.
    CREATE OBJECT GO_EVENT_RECEIVER.
  ENDIF.

  CALL METHOD PO_GRID->REGISTER_EDIT_EVENT
    EXPORTING
      I_EVENT_ID = CL_GUI_ALV_GRID=>MC_EVT_ENTER.

  CALL METHOD PO_GRID->REGISTER_EDIT_EVENT
    EXPORTING
      I_EVENT_ID = CL_GUI_ALV_GRID=>MC_EVT_MODIFIED.


  SET HANDLER GO_EVENT_RECEIVER->HANDLE_DATA_CHANGED     FOR PO_GRID .
  SET HANDLER GO_EVENT_RECEIVER->HANDLE_CHANGED_FINISHED FOR PO_GRID.
*  SET HANDLER GO_EVENT_RECEIVER->HANDLE_SUBTOTAL_TEXT    FOR PO_GRID.
  SET HANDLER GO_EVENT_RECEIVER->HANDLE_DOUBLE_CLICK     FOR PO_GRID.
  SET HANDLER GO_EVENT_RECEIVER->HANDLE_HOTSPOT_CLICK    FOR PO_GRID.
  SET HANDLER GO_EVENT_RECEIVER->HANDLE_TOOLBAR          FOR PO_GRID.
  SET HANDLER GO_EVENT_RECEIVER->HANDLE_USER_COMMAND     FOR PO_GRID.
  SET HANDLER GO_EVENT_RECEIVER->HANDLE_ONF4             FOR PO_GRID.
*  SET HANDLER GO_EVENT_RECEIVER->HANDLE_BUTTON_CLICK     FOR PO_GRID.
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
                CL_GUI_ALV_GRID=>MC_FC_GRAPH,
                CL_GUI_ALV_GRID=>MC_FC_HELP,
                CL_GUI_ALV_GRID=>MC_FC_INFO,
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
FORM APPEND_EXCLUDE_FUNCTIONS  TABLES   P_TABLE
                                USING P_VALUE.
  DATA : LS_EXCLUDE TYPE UI_FUNC.
  LS_EXCLUDE = P_VALUE.
  APPEND LS_EXCLUDE TO P_TABLE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CELL_ATTRIBUTES_0100_H
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CELL_ATTRIBUTES_0100_TOP .
  LOOP AT GT_LIST ASSIGNING FIELD-SYMBOL(<FS_LIST>).
    PERFORM SET_ATTRIBUTES_LINE_TOP CHANGING <FS_LIST>.
  ENDLOOP.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form DISPLAY_ALV_0100_H
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM DISPLAY_ALV_0100_TOP .
  CALL METHOD GO_GRID1->SET_TABLE_FOR_FIRST_DISPLAY
    EXPORTING
      IS_LAYOUT            = GS_LAYOUT1
      IS_VARIANT           = GS_VARIANT1
      I_SAVE               = 'A'
      IT_TOOLBAR_EXCLUDING = GT_EXCLUDE1[]
      I_BYPASSING_BUFFER   = 'X'
    CHANGING
      IT_OUTTAB            = GT_LIST[]
      IT_FIELDCATALOG      = GT_FIELDCAT1[]
      IT_SORT              = GT_SORT1[].
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_F4_0100_H
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_F4_0100_TOP .

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_TEXT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> TEXT_H01
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
*& Form DISPLAY_ALV_GRID_0100_I
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GO_GRID2
*&---------------------------------------------------------------------*
FORM DISPLAY_ALV_GRID_0100_BOT  USING  PO_GRID TYPE REF TO
                                       CL_GUI_ALV_GRID.

* Set Variant
  PERFORM SET_VARIANT_0100_BOT.

* SET LAYOUT
  PERFORM SET_LAYOUT_0100_BOT.

* SET SORT
  PERFORM SET_SORT_0100_BOT.

* SET FIELDCAT
  PERFORM SET_FIELDCAT_0100_BOT.

* Set Event Handler
*  PERFORM SET_EVENT_HANDLER_0100 USING PO_GRID.
  PERFORM SET_EVENT_HANDLER_0100 USING PO_GRID.

* EXCLUDING TOOLBAR
  CLEAR: GT_EXCLUDE2[].
  PERFORM EXCLUDE_TB_FUNCTIONS_0100 USING 'GT_EXCLUDE2'.

* CELL ATTRIBUTES
  PERFORM CELL_ATTRIBUTES_0100_BOT.

* ALV GRID
  PERFORM DISPLAY_ALV_0100_BOT.

* F4
  PERFORM SET_F4_0100_BOT.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_VARIANT_0100_BOT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_VARIANT_0100_BOT .
  CLEAR : GS_VARIANT2.

  GS_VARIANT2-REPORT   = SY-REPID.
  GS_VARIANT2-HANDLE   = 2.
  GS_VARIANT2-USERNAME = SY-UNAME.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_LAYOUT_0100_BOT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_LAYOUT_0100_BOT .
  CLEAR: GS_LAYOUT2.
  GS_LAYOUT2-ZEBRA        = GC_X.
*  GS_LAYOUT2-EDIT         = GC_X.
*  GS_LAYOUT2-CWIDTH_OPT   = GC_X.
  GS_LAYOUT2-SEL_MODE     = 'D'.      "선택모드
  GS_LAYOUT2-SMALLTITLE   = GC_X.
*  GS_LAYOUT2-GRID_TITLE   = GV_GRID_TITLE.

*  GS_LAYOUT2-NO_ROWMARK   = GC_X.      "선택버튼제거.
  GS_LAYOUT2-STYLEFNAME   = 'CELLTAB'.
*  GS_LAYOUT2-CTAB_FNAME   = 'CELLCOL'.
*  GS_LAYOUT2-INFO_FNAME = 'LINECOL'.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_SORT_0100_BOT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_SORT_0100_BOT .
  DATA: LV_SPOS  TYPE SLIS_SPOS.
  CLEAR: GT_SORT2[].

*  CLEAR GS_SORT.
*  LV_SPOS = LV_SPOS + 1.
*  GS_SOR2-SPOS = LV_SPOS.
*  GS_SOR2-FIELDNAME = 'CRDAT'.
*  GS_SOR2-DOWN = GC_X.
*  APPEND GS_SORT3 TO GT_SORT2.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form MODIFY_FIELDCAT_0100_BOT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_FIELDCAT2
*&---------------------------------------------------------------------*
FORM MODIFY_FIELDCAT_0100_BOT  USING   PT_FIELDCAT TYPE LVC_T_FCAT.

  LOOP AT PT_FIELDCAT INTO GS_FIELDCAT.
    CASE GS_FIELDCAT-FIELDNAME.

      WHEN 'SEL'.
        GS_FIELDCAT-KEY      = GC_X.
        GS_FIELDCAT-CHECKBOX = GC_X.

        GS_FIELDCAT-JUST = GC_C.
        GS_FIELDCAT-OUTPUTLEN = 5.
        IF GV_DISP EQ GC_X.
          GS_FIELDCAT-NO_OUT = GC_X.
          CLEAR GS_FIELDCAT-EDIT.
        ELSE.
          CLEAR GS_FIELDCAT-NO_OUT.
          GS_FIELDCAT-EDIT     = GC_X.
        ENDIF.
        PERFORM SET_TEXT USING TEXT-H02.
      WHEN 'ST_FINSH'.
        GS_FIELDCAT-KEY      = GC_X.
        GS_FIELDCAT-ICON = GC_X.
        GS_FIELDCAT-JUST = GC_C.
        GS_FIELDCAT-OUTPUTLEN = 3.
        PERFORM SET_TEXT USING TEXT-H03.
*      WHEN 'ST_SPLIT'.
*        GS_FIELDCAT-KEY      = GC_X.
*        GS_FIELDCAT-ICON = GC_X.
*        GS_FIELDCAT-JUST = GC_C.
*        GS_FIELDCAT-OUTPUTLEN = 5.
*        PERFORM SET_TEXT USING TEXT-H04.
      WHEN 'ST_PICK'.
        GS_FIELDCAT-KEY      = GC_X.
        GS_FIELDCAT-ICON = GC_X.
        GS_FIELDCAT-JUST = GC_C.
        GS_FIELDCAT-OUTPUTLEN = 3.
        PERFORM SET_TEXT USING TEXT-H05.
      WHEN 'ST_PGI'.
        GS_FIELDCAT-KEY      = GC_X.
        GS_FIELDCAT-ICON = GC_X.
        GS_FIELDCAT-JUST = GC_C.
        GS_FIELDCAT-OUTPUTLEN = 5.
        PERFORM SET_TEXT USING TEXT-H06.
      WHEN 'ST_BILL'.
        GS_FIELDCAT-KEY      = GC_X.
        GS_FIELDCAT-ICON = GC_X.
        GS_FIELDCAT-JUST = GC_C.
        GS_FIELDCAT-OUTPUTLEN = 5.
        PERFORM SET_TEXT USING TEXT-H07.
      WHEN 'VBELN_VA'.
        GS_FIELDCAT-KEY      = GC_X.
        GS_FIELDCAT-OUTPUTLEN = 10.
        PERFORM SET_TEXT USING TEXT-H08.
      WHEN 'VBELN_VLSP'.
        GS_FIELDCAT-KEY      = GC_X.
        GS_FIELDCAT-OUTPUTLEN = 10.
        PERFORM SET_TEXT USING TEXT-H10.

      WHEN 'ST_VLSP'.
*        GS_FIELDCAT-ICON = GC_X.
*        GS_FIELDCAT-JUST = GC_C.
        GS_FIELDCAT-OUTPUTLEN = 10.
        PERFORM SET_TEXT USING TEXT-H11.
      WHEN 'VBELN_VL'.
        GS_FIELDCAT-KEY      = GC_X.
        GS_FIELDCAT-OUTPUTLEN = 10.
        PERFORM SET_TEXT USING TEXT-H09.
      WHEN 'KUNAG'.
        GS_FIELDCAT-OUTPUTLEN = 8.
        PERFORM SET_TEXT USING TEXT-H12.
      WHEN 'KUNAG_TX'.
        GS_FIELDCAT-OUTPUTLEN = 15.
        PERFORM SET_TEXT USING TEXT-H13.
      WHEN 'ERDAT'.
        GS_FIELDCAT-OUTPUTLEN = 11.
        PERFORM SET_TEXT USING TEXT-H14.
*      WHEN 'WADAT_IST'.
*        GS_FIELDCAT-OUTPUTLEN = 11.
*        PERFORM SET_TEXT USING TEXT-H15.
      WHEN 'FKDAT'.
        GS_FIELDCAT-OUTPUTLEN = 11.
        PERFORM SET_TEXT USING TEXT-H35.
      WHEN 'NETWR_VF'.
        GS_FIELDCAT-OUTPUTLEN = 12.
        GS_FIELDCAT-CFIELDNAME = 'WAERK_VF'.
        PERFORM SET_TEXT USING TEXT-H36.
*      WHEN 'NETWR_INI'.
*        PERFORM SET_TEXT USING TEXT-H16.
*      WHEN 'NETWR_JSJA'.
*        GS_FIELDCAT-OUTPUTLEN = 12.
*        GS_FIELDCAT-CFIELDNAME = 'WAERK'.
*        PERFORM SET_TEXT USING TEXT-H17.
      WHEN 'WAERK_VF'.
        GS_FIELDCAT-OUTPUTLEN = 4.
        PERFORM SET_TEXT USING TEXT-H18.
      WHEN 'KUNNR'.
        GS_FIELDCAT-OUTPUTLEN = 8.
        PERFORM SET_TEXT USING TEXT-H19.
      WHEN 'KUNNR_TX'.
        GS_FIELDCAT-OUTPUTLEN = 15.
        PERFORM SET_TEXT USING TEXT-H20.
      WHEN 'LFART'.
        GS_FIELDCAT-OUTPUTLEN = 7.
        PERFORM SET_TEXT USING TEXT-H21.
      WHEN 'AUART'.
        GS_FIELDCAT-OUTPUTLEN = 5.
        PERFORM SET_TEXT USING TEXT-H22.
      WHEN 'BSTNK'.
        GS_FIELDCAT-OUTPUTLEN = 12.
        PERFORM SET_TEXT USING TEXT-H23.
      WHEN 'VSTEL'.
        GS_FIELDCAT-OUTPUTLEN = 5.
        PERFORM SET_TEXT USING TEXT-H24.
      WHEN 'VSTEL_TX'.
        GS_FIELDCAT-OUTPUTLEN = 12.
        PERFORM SET_TEXT USING TEXT-H25.
      WHEN 'VKORG'.
        GS_FIELDCAT-OUTPUTLEN = 5.
        PERFORM SET_TEXT USING TEXT-H26.
      WHEN 'VTWEG'.
        GS_FIELDCAT-OUTPUTLEN = 4.
        PERFORM SET_TEXT USING TEXT-H27.
      WHEN 'SPART'.
        GS_FIELDCAT-OUTPUTLEN = 4.
        PERFORM SET_TEXT USING TEXT-H28.
      WHEN 'VKBUR'.
        GS_FIELDCAT-OUTPUTLEN = 5.
        PERFORM SET_TEXT USING TEXT-H29.
      WHEN 'VKBUR_TX'.
        GS_FIELDCAT-OUTPUTLEN = 10.
        PERFORM SET_TEXT USING TEXT-H30.
      WHEN 'VKGRP'.
        GS_FIELDCAT-OUTPUTLEN = 5.
        PERFORM SET_TEXT USING TEXT-H31.
      WHEN 'VKGRP_TX'.
        GS_FIELDCAT-OUTPUTLEN = 10.
        PERFORM SET_TEXT USING TEXT-H32.
      WHEN 'MESSAGE'.
        GS_FIELDCAT-OUTPUTLEN = 50.
        IF GV_DISP EQ GC_X.
          GS_FIELDCAT-NO_OUT = GC_X.
        ELSE.
          CLEAR GS_FIELDCAT-NO_OUT.
        ENDIF.
        PERFORM SET_TEXT USING TEXT-H33.

      WHEN OTHERS.
        GS_FIELDCAT-NO_OUT = GC_X.
    ENDCASE.
    MODIFY PT_FIELDCAT FROM GS_FIELDCAT.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CELL_ATTRIBUTES_0100_BOT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CELL_ATTRIBUTES_0100_BOT .
  LOOP AT GT_SPLIT ASSIGNING FIELD-SYMBOL(<FS_SPLIT>).
    PERFORM SET_ATTRIBUTES_LINE_BOT CHANGING <FS_SPLIT>.
  ENDLOOP.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form DISPLAY_ALV_0100_BOT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM DISPLAY_ALV_0100_BOT .
  CALL METHOD GO_GRID2->SET_TABLE_FOR_FIRST_DISPLAY
    EXPORTING
      IS_LAYOUT            = GS_LAYOUT2
      IS_VARIANT           = GS_VARIANT2
      I_SAVE               = 'A'
      IT_TOOLBAR_EXCLUDING = GT_EXCLUDE2[]
      I_BYPASSING_BUFFER   = 'X'
    CHANGING
      IT_OUTTAB            = GT_SPLIT[]
      IT_FIELDCATALOG      = GT_FIELDCAT2[]
      IT_SORT              = GT_SORT2[].
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_F4_0100_BOT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_F4_0100_BOT .

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
  IF GO_CCON3 IS INITIAL.
    PERFORM CREATE_CONTAINER_0200 USING GO_CCON3 'CONT0200'.

    PERFORM CREATE_ALV_0200 USING GO_CCON3
                                  GO_GRID3.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form CREATE_CONTAINER_0200
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GO_CCON3
*&      --> P_
*&---------------------------------------------------------------------*
FORM CREATE_CONTAINER_0200  USING   PO_CCON TYPE REF TO
                                         CL_GUI_CUSTOM_CONTAINER
                                    P_CONT.

  CREATE OBJECT PO_CCON
    EXPORTING
      CONTAINER_NAME = P_CONT.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CREATE_ALV_0200
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GO_CCON3
*&      --> GO_GRID3
*&---------------------------------------------------------------------*
FORM CREATE_ALV_0200  USING    PO_CCON TYPE REF TO
                                 CL_GUI_CUSTOM_CONTAINER
                               PO_GRID TYPE REF TO
                                 CL_GUI_ALV_GRID.


  CREATE OBJECT PO_GRID
    EXPORTING
      I_PARENT      = PO_CCON
      I_APPL_EVENTS = 'X'.

* Set Variant
  PERFORM SET_VARIANT_0200.

* SET LAYOUT
  PERFORM SET_LAYOUT_0200.

* SET SORT
  PERFORM SET_SORT_0200.

* SET FIELDCAT
  PERFORM SET_FIELDCAT_0200.

* Set Event Handler
  PERFORM SET_EVENT_HANDLER_0100 USING PO_GRID.

* EXCLUDING TOOLBAR
  CLEAR: GT_EXCLUDE3[].
  PERFORM EXCLUDE_TB_FUNCTIONS_0100 USING 'GT_EXCLUDE3'.

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
  CLEAR : GS_VARIANT3.

  GS_VARIANT3-REPORT   = SY-REPID.
  GS_VARIANT3-HANDLE   = 3.
  GS_VARIANT3-USERNAME = SY-UNAME.
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
  CLEAR: GS_LAYOUT3.
  GS_LAYOUT3-ZEBRA        = GC_X.
*  GS_LAYOUT3-EDIT         = GC_X.
*  GS_LAYOUT3-CWIDTH_OPT   = GC_X.
  GS_LAYOUT3-SEL_MODE     = 'D'.      "선택모드
  GS_LAYOUT3-SMALLTITLE   = GC_X.
*  GS_LAYOUT3-GRID_TITLE   = GV_GRID_TITLE.

*  GS_LAYOUT3-NO_ROWMARK   = GC_X.      "선택버튼제거.
  GS_LAYOUT3-STYLEFNAME   = 'CELLTAB'.
*  GS_LAYOUT3-CTAB_FNAME   = 'CELLCOL'.
*  GS_LAYOUT3-INFO_FNAME = 'LINECOL'.
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
  CLEAR: GT_SORT3[].

*  CLEAR GS_SORT.
*  LV_SPOS = LV_SPOS + 1.
*  GS_SORT-SPOS = LV_SPOS.
*  GS_SORT-FIELDNAME = 'CRDAT'.
*  GS_SORT-DOWN = GC_X.
*  APPEND GS_SORT3 TO GT_SORT3.
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
  CLEAR: GT_FIELDCAT3[].

  PERFORM CREATE_FIELDCAT USING 'GT_ITEM'
                                GT_FIELDCAT3.

  PERFORM MODIFY_FIELDCAT_0200 USING GT_FIELDCAT3.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form MODIFY_FIELDCAT_0200
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_FIELDCAT3
*&---------------------------------------------------------------------*
FORM MODIFY_FIELDCAT_0200  USING    PT_FIELDCAT TYPE LVC_T_FCAT.

  LOOP AT PT_FIELDCAT INTO GS_FIELDCAT.
    CASE GS_FIELDCAT-FIELDNAME.
      WHEN 'VBELN_VL'.
        GS_FIELDCAT-KEY = GC_X.
        GS_FIELDCAT-OUTPUTLEN = 11.
        PERFORM SET_TEXT USING TEXT-H51.
      WHEN 'UECHA'.
        GS_FIELDCAT-KEY = GC_X.
        GS_FIELDCAT-OUTPUTLEN = 8.
        PERFORM SET_TEXT USING TEXT-H52.
      WHEN 'POSNR_VL'.
        GS_FIELDCAT-KEY = GC_X.
        GS_FIELDCAT-OUTPUTLEN = 8.
        PERFORM SET_TEXT USING TEXT-H53.
      WHEN 'MATNR'.
        GS_FIELDCAT-OUTPUTLEN = 10.
        PERFORM SET_TEXT USING TEXT-H54.
      WHEN 'CHARG'.
        GS_FIELDCAT-OUTPUTLEN = 11.
        PERFORM SET_TEXT USING TEXT-H55.
      WHEN 'VRKME'.
        GS_FIELDCAT-OUTPUTLEN = 3.
        PERFORM SET_TEXT USING TEXT-H56.
      WHEN 'LFIMG'.
        GS_FIELDCAT-OUTPUTLEN = 12.
        PERFORM SET_TEXT USING TEXT-H57.
      WHEN 'LENGTH_JS'.
        GS_FIELDCAT-OUTPUTLEN = 6.
        PERFORM SET_TEXT USING TEXT-H58.
      WHEN 'FACTOR_I'.
        GS_FIELDCAT-OUTPUTLEN = 7.
        PERFORM SET_TEXT USING TEXT-H59.
      WHEN 'FACTOR_B'.
        GS_FIELDCAT-OUTPUTLEN = 7.
        PERFORM SET_TEXT USING TEXT-H60.
      WHEN 'LFIMG_B'.
        GS_FIELDCAT-OUTPUTLEN = 12.
        PERFORM SET_TEXT USING TEXT-H61.
      WHEN 'NETPR'.
        GS_FIELDCAT-CFIELDNAME = 'WAERK'.
        GS_FIELDCAT-OUTPUTLEN = 8.
        PERFORM SET_TEXT USING TEXT-H62.
      WHEN 'NETWR_BL_I'.
        GS_FIELDCAT-CFIELDNAME = 'WAERK'.
        GS_FIELDCAT-OUTPUTLEN = 12.
        PERFORM SET_TEXT USING TEXT-H63.
      WHEN 'FACTOR_JS'.
        GS_FIELDCAT-OUTPUTLEN = 6.
        PERFORM SET_TEXT USING TEXT-H64.
      WHEN 'LFIMG_JS'.
        GS_FIELDCAT-OUTPUTLEN = 10.
        PERFORM SET_TEXT USING TEXT-H65.
      WHEN 'NETWR_JS_I'.
        GS_FIELDCAT-CFIELDNAME = 'WAERK'.
        GS_FIELDCAT-OUTPUTLEN = 12.
        PERFORM SET_TEXT USING TEXT-H66.
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
  LOOP AT GT_ITEM ASSIGNING FIELD-SYMBOL(<FS_ITEM>).
    PERFORM SET_ATTRIBUTES_LINE_ITEM CHANGING <FS_ITEM>.
  ENDLOOP.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_ATTRIBUTES_LINE_ITEM
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- <FS_ITEM>
*&---------------------------------------------------------------------*
FORM SET_ATTRIBUTES_LINE_ITEM  CHANGING PS_ITEM LIKE GT_ITEM.
  DATA : LT_CELLTAB TYPE LVC_T_STYL.
  DATA : LS_CELLTAB TYPE LVC_S_STYL.

  CLEAR PS_ITEM-CELLTAB[].

  LOOP AT GT_FIELDCAT3 INTO DATA(LS_FCAT).
    CLEAR:LS_CELLTAB.
    LS_CELLTAB-FIELDNAME = LS_FCAT-FIELDNAME.
    CASE LS_FCAT-FIELDNAME.
      WHEN 'FACTOR_B'."매출조장수
        IF ZGTSDS1100-LOCK EQ GC_X.
          IF ZGTSDS1100-VBELN_VLSP IS NOT INITIAL.
            IF ZGTSDS1100-SPLIT EQ GC_C.
              LS_CELLTAB-STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED.
            ELSE.
              LS_CELLTAB-STYLE = CL_GUI_ALV_GRID=>MC_STYLE_ENABLED.
            ENDIF.
          ELSE.
            IF ZGTSDS1100-KOSTK EQ GC_C.
              LS_CELLTAB-STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED.
            ELSE.
              LS_CELLTAB-STYLE = CL_GUI_ALV_GRID=>MC_STYLE_ENABLED.
            ENDIF.
          ENDIF.
        ELSE.
          LS_CELLTAB-STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED.
        ENDIF.

      WHEN OTHERS.
        LS_CELLTAB-STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED.

    ENDCASE.
    INSERT LS_CELLTAB INTO TABLE LT_CELLTAB.
  ENDLOOP.
  INSERT LINES OF LT_CELLTAB INTO TABLE PS_ITEM-CELLTAB.

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
  CALL METHOD GO_GRID3->SET_TABLE_FOR_FIRST_DISPLAY
    EXPORTING
      IS_LAYOUT            = GS_LAYOUT3
      IS_VARIANT           = GS_VARIANT3
      I_SAVE               = 'A'
      IT_TOOLBAR_EXCLUDING = GT_EXCLUDE3[]
      I_BYPASSING_BUFFER   = 'X'
    CHANGING
      IT_OUTTAB            = GT_ITEM[]
      IT_FIELDCATALOG      = GT_FIELDCAT3[]
      IT_SORT              = GT_SORT3[].
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

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_ATTRIBUTES_LINE_TOP
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- <FS_HEAD>
*&---------------------------------------------------------------------*
FORM SET_ATTRIBUTES_LINE_TOP  CHANGING PS_LIST LIKE GT_LIST.
  DATA : LT_CELLTAB TYPE LVC_T_STYL.
  DATA : LS_CELLTAB TYPE LVC_S_STYL.

  CLEAR PS_LIST-CELLTAB[].

  LOOP AT GT_FIELDCAT2 INTO DATA(LS_FCAT).
    CLEAR:LS_CELLTAB.
    LS_CELLTAB-FIELDNAME = LS_FCAT-FIELDNAME.
    CASE LS_FCAT-FIELDNAME.
      WHEN 'SEL'.
        IF PS_LIST-FI_CLOSE EQ GC_X.
          LS_CELLTAB-STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED.

        ELSE.
          LS_CELLTAB-STYLE = CL_GUI_ALV_GRID=>MC_STYLE_ENABLED.
        ENDIF.

      WHEN OTHERS.
        LS_CELLTAB-STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED.

    ENDCASE.
    INSERT LS_CELLTAB INTO TABLE LT_CELLTAB.
  ENDLOOP.
  INSERT LINES OF LT_CELLTAB INTO TABLE PS_LIST-CELLTAB.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_ATTRIBUTES_LINE_BOT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- <FS_SPLIT>
*&---------------------------------------------------------------------*
FORM SET_ATTRIBUTES_LINE_BOT  CHANGING PS_SPLIT LIKE GT_SPLIT.
  DATA : LT_CELLTAB TYPE LVC_T_STYL.
  DATA : LS_CELLTAB TYPE LVC_S_STYL.

  CLEAR PS_SPLIT-CELLTAB[].

  LOOP AT GT_FIELDCAT2 INTO DATA(LS_FCAT).
    CLEAR:LS_CELLTAB.
    LS_CELLTAB-FIELDNAME = LS_FCAT-FIELDNAME.
    CASE LS_FCAT-FIELDNAME.
      WHEN 'SEL'.
        IF GV_DISP EQ GC_X.
          LS_CELLTAB-STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED.
        ELSE.
          IF PS_SPLIT-NO_CANC EQ GC_X.
            LS_CELLTAB-STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED.
          ELSE.
            LS_CELLTAB-STYLE = CL_GUI_ALV_GRID=>MC_STYLE_ENABLED.
          ENDIF.
        ENDIF.

      WHEN OTHERS.
        LS_CELLTAB-STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED.

    ENDCASE.
    INSERT LS_CELLTAB INTO TABLE LT_CELLTAB.
  ENDLOOP.
  INSERT LINES OF LT_CELLTAB INTO TABLE PS_SPLIT-CELLTAB.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form ALV_CHANGE_FINISHED_ITEM
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PT_GOOD_CELLS
*&---------------------------------------------------------------------*
FORM ALV_CHANGE_FINISHED_0200_ITEM  USING   PT_GOOD_CELLS TYPE LVC_T_MODI.
  DATA: LT_MODI TYPE LVC_T_MODI.
  DATA: LS_MODI TYPE LVC_S_MODI.
  DATA: LS_ITEM LIKE GT_ITEM.

  LT_MODI[] = PT_GOOD_CELLS[].
  SORT LT_MODI BY ROW_ID.
  DELETE ADJACENT DUPLICATES FROM LT_MODI COMPARING ROW_ID.
  LS_MODI = VALUE #( LT_MODI[ 1 ] OPTIONAL ).
  CHECK LS_MODI IS NOT INITIAL.

  LOOP AT LT_MODI INTO LS_MODI.
    READ TABLE GT_ITEM ASSIGNING FIELD-SYMBOL(<FS_ITEM>) INDEX LS_MODI-ROW_ID.
    CHECK SY-SUBRC EQ 0.

    "ITEM 수량/금액 재계산
    PERFORM SET_QTY_AMT_VALUES     USING SPACE
                                CHANGING <FS_ITEM>.

    "실매출금액 = 매출금액 SUM - 유보금액
    PERFORM SET_REAL_NETWR USING <FS_ITEM>-VBELN_VL.
  ENDLOOP.

*  READ TABLE GT_ITEM ASSIGNING FIELD-SYMBOL(<FS_ITEM>) INDEX LS_MODI-ROW_ID.
*  CHECK SY-SUBRC EQ 0.
*
*  "ITEM 수량/금액 재계산
*  PERFORM SET_QTY_AMT_VALUES     USING SPACE
*                              CHANGING <FS_ITEM>.
*
*  "실매출금액 = 매출금액 SUM - 유보금액
*  PERFORM SET_REAL_NETWR USING <FS_ITEM>-VBELN_VL.

  PERFORM REFRESH_ALV USING GO_GRID3.

  CALL METHOD CL_GUI_CFW=>FLUSH.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form ALV_CHANGE_FINISHED_0100_TOP
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PT_GOOD_CELLS
*&---------------------------------------------------------------------*
FORM ALV_CHANGE_FINISHED_0100_TOP  USING    PT_GOOD_CELLS TYPE LVC_T_MODI.
  DATA: LT_MODI TYPE LVC_T_MODI.
  DATA: LS_MODI TYPE LVC_S_MODI.


  LT_MODI[] = PT_GOOD_CELLS[].
  SORT LT_MODI BY ROW_ID.
  DELETE ADJACENT DUPLICATES FROM LT_MODI COMPARING ROW_ID.
  LS_MODI = VALUE #( LT_MODI[ 1 ] OPTIONAL ).
  CHECK LS_MODI IS NOT INITIAL.
  IF LS_MODI-FIELDNAME EQ 'SEL'.

    READ TABLE GT_LIST INTO DATA(LS_LIST) INDEX LS_MODI-ROW_ID.
    CHECK SY-SUBRC EQ 0.

    IF LS_LIST-SEL EQ GC_X.
      CLEAR GS_LIST.
      MODIFY GT_LIST FROM GS_LIST TRANSPORTING SEL WHERE SEL = GC_X
                                                     AND VBELN_VL NE LS_LIST-VBELN_VL.


      "DO SPLIT 리스트 구성
      PERFORM GET_SPLIT_DO_LIST USING LS_LIST.

    ELSE.
      CLEAR GT_SPLIT[].
    ENDIF.

  ENDIF.

  PERFORM REFRESH_ALV USING: GO_GRID1,
                             GO_GRID2.

  CALL METHOD CL_GUI_CFW=>FLUSH.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_EVENT_HANDLER_0100_I
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PO_GRID
*&---------------------------------------------------------------------*
FORM SET_EVENT_HANDLER_0100_I  USING    PO_GRID TYPE REF TO CL_GUI_ALV_GRID.

*  IF GO_EVENT_RECEIVER2 IS INITIAL.
*    CREATE OBJECT GO_EVENT_RECEIVER2.
*  ENDIF.
*
*  CALL METHOD PO_GRID->REGISTER_EDIT_EVENT
*    EXPORTING
*      I_EVENT_ID = CL_GUI_ALV_GRID=>MC_EVT_ENTER.
*
*  CALL METHOD PO_GRID->REGISTER_EDIT_EVENT
*    EXPORTING
*      I_EVENT_ID = CL_GUI_ALV_GRID=>MC_EVT_MODIFIED.
*
*
*  SET HANDLER GO_EVENT_RECEIVER2->HANDLE_DATA_CHANGED     FOR PO_GRID .
*  SET HANDLER GO_EVENT_RECEIVER2->HANDLE_CHANGED_FINISHED FOR PO_GRID.
**  SET HANDLER GO_EVENT_RECEIVER->HANDLE_SUBTOTAL_TEXT    FOR PO_GRID.
*  SET HANDLER GO_EVENT_RECEIVER2->HANDLE_DOUBLE_CLICK     FOR PO_GRID.
*  SET HANDLER GO_EVENT_RECEIVER2->HANDLE_HOTSPOT_CLICK    FOR PO_GRID.
*  SET HANDLER GO_EVENT_RECEIVER2->HANDLE_TOOLBAR          FOR PO_GRID.
*  SET HANDLER GO_EVENT_RECEIVER2->HANDLE_USER_COMMAND     FOR PO_GRID.
*  SET HANDLER GO_EVENT_RECEIVER2->HANDLE_ONF4             FOR PO_GRID.
**  SET HANDLER GO_EVENT_RECEIVER->HANDLE_BUTTON_CLICK     FOR PO_GRID.
**  SET HANDLER GO_EVENT_RECEIVER->HANDLE_TOP_OF_PAGE   FOR PA_GRID.
*
*  IF GV_EDIT IS NOT INITIAL.
*    CALL METHOD PO_GRID->SET_READY_FOR_INPUT
*      EXPORTING
*        I_READY_FOR_INPUT = 1.
*
*  ELSE.
*    CALL METHOD PO_GRID->SET_READY_FOR_INPUT
*      EXPORTING
*        I_READY_FOR_INPUT = 0.
*  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form CREATE_ALV_0100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GO_CCON1
*&      --> GO_GRID1
*&---------------------------------------------------------------------*
FORM CREATE_ALV_0100_TOP  USING    PO_CCON TYPE REF TO
                                 CL_GUI_CUSTOM_CONTAINER
                               PO_GRID TYPE REF TO
                                 CL_GUI_ALV_GRID.


  CREATE OBJECT PO_GRID
    EXPORTING
      I_PARENT      = PO_CCON
      I_APPL_EVENTS = 'X'.

* Set Variant
  PERFORM SET_VARIANT_0100_TOP.

* SET LAYOUT
  PERFORM SET_LAYOUT_0100_TOP.

* SET SORT
  PERFORM SET_SORT_0100_TOP.

* SET FIELDCAT
  PERFORM SET_FIELDCAT_0100_TOP.

* Set Event Handler
  PERFORM SET_EVENT_HANDLER_0100 USING PO_GRID.

* EXCLUDING TOOLBAR
  CLEAR: GT_EXCLUDE1[].
  PERFORM EXCLUDE_TB_FUNCTIONS_0100 USING 'GT_EXCLUDE1'.

* CELL ATTRIBUTES
  PERFORM CELL_ATTRIBUTES_0100_TOP.

* ALV GRID
  PERFORM DISPLAY_ALV_0100_TOP.

* F4
  PERFORM SET_F4_0100_TOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CREATE_ALV_0100_BOT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GO_CCON2
*&      --> GO_GRID2
*&---------------------------------------------------------------------*
FORM CREATE_ALV_0100_BOT  USING    PO_CCON TYPE REF TO
                                 CL_GUI_CUSTOM_CONTAINER
                               PO_GRID TYPE REF TO
                                 CL_GUI_ALV_GRID.


  CREATE OBJECT PO_GRID
    EXPORTING
      I_PARENT      = PO_CCON
      I_APPL_EVENTS = 'X'.

* Set Variant
  PERFORM SET_VARIANT_0100_BOT.

* SET LAYOUT
  PERFORM SET_LAYOUT_0100_BOT.

* SET SORT
  PERFORM SET_SORT_0100_BOT.

* SET FIELDCAT
  PERFORM SET_FIELDCAT_0100_BOT.

* Set Event Handler
  PERFORM SET_EVENT_HANDLER_0100 USING PO_GRID.
*  PERFORM SET_EVENT_HANDLER_0100_I USING PO_GRID.

* EXCLUDING TOOLBAR
  CLEAR: GT_EXCLUDE2[].
  PERFORM EXCLUDE_TB_FUNCTIONS_0100 USING 'GT_EXCLUDE2'.

* CELL ATTRIBUTES
  PERFORM CELL_ATTRIBUTES_0100_BOT.

* ALV GRID
  PERFORM DISPLAY_ALV_0100_BOT.

* F4
  PERFORM SET_F4_0100_BOT.

ENDFORM.
