*&---------------------------------------------------------------------*
*& Include          ZGTSDR1015ALV
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form INIT_CONTROLS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM INIT_CONTROLS .
  IF GO_GRID IS NOT INITIAL.
    CALL METHOD GO_GRID->FREE.
  ENDIF.
  IF GO_GCON1 IS NOT INITIAL.
    CALL METHOD GO_GCON1->FREE.
  ENDIF.
  IF GO_GCON2 IS NOT INITIAL.
    CALL METHOD GO_GCON2->FREE.
  ENDIF.
  IF GO_CCON IS NOT INITIAL.
    CALL METHOD GO_CCON->FREE.
  ENDIF.
  CLEAR: GO_GRID,GO_CCON,GO_GCON1,GO_GCON2.
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
*& Form CREATE_CONTROLS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CREATE_CONTROLS .
  IF GO_CCON IS INITIAL.

    PERFORM CREATE_CONTAINER USING GO_CCON 'CONT0100'.

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
FORM CREATE_ALV_0100  USING  PO_CCON TYPE REF TO
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
  GS_LAYOUT-EDIT         = GC_X.
*  GS_LAYOUT-CWIDTH_OPT   = GC_X.
  GS_LAYOUT-SEL_MODE     = 'D'.      "선택모드
  GS_LAYOUT-SMALLTITLE   = GC_X.
*  GS_LAYOUT-GRID_TITLE   = GV_GRID_TITLE.

  GS_LAYOUT-NO_ROWMARK   = GC_X.      "선택버튼제거.
  GS_LAYOUT-STYLEFNAME   = 'CELLTAB'.
*  GS_LAYOUT-CTAB_FNAME   = 'CELLCOL'.
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

  PERFORM CREATE_FIELDCAT USING 'GT_LIST'
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
      WHEN 'STAT1'.
        GS_FIELDCAT-ICON = GC_X.
        GS_FIELDCAT-JUST = GC_C.
        GS_FIELDCAT-OUTPUTLEN = 3.
        PERFORM SET_TEXT USING TEXT-H01.
      WHEN 'STAT2'.
        GS_FIELDCAT-ICON = GC_X.
        GS_FIELDCAT-JUST = GC_C.
        GS_FIELDCAT-OUTPUTLEN = 3.
        PERFORM SET_TEXT USING TEXT-H02.
      WHEN 'SEL'.
        GS_FIELDCAT-CHECKBOX = GC_X.
        GS_FIELDCAT-JUST = GC_C.
        GS_FIELDCAT-OUTPUTLEN = 3.
        PERFORM SET_TEXT USING TEXT-H03.
      WHEN 'VKORG'.
        GS_FIELDCAT-OUTPUTLEN = 5.
        PERFORM SET_TEXT USING TEXT-H04.
      WHEN 'VTWEG'.
        GS_FIELDCAT-OUTPUTLEN = 5.
        PERFORM SET_TEXT USING TEXT-H05.
      WHEN 'SPART'.
        GS_FIELDCAT-OUTPUTLEN = 4.
        PERFORM SET_TEXT USING TEXT-H06.
      WHEN 'VKGRP'.
        GS_FIELDCAT-OUTPUTLEN = 5.
        PERFORM SET_TEXT USING TEXT-H07.
      WHEN 'VKGRP_TX'.
        GS_FIELDCAT-OUTPUTLEN = 12.
        PERFORM SET_TEXT USING TEXT-H08.
      WHEN 'ZTERM'.
        GS_FIELDCAT-OUTPUTLEN = 7.
        GS_FIELDCAT-F4AVAILABL = GC_X.
        PERFORM SET_TEXT USING TEXT-H09.
      WHEN 'ZTERM_TX'.
        GS_FIELDCAT-OUTPUTLEN = 25.
        PERFORM SET_TEXT USING TEXT-H10.
      WHEN 'ZZDEFAULT'.
        GS_FIELDCAT-CHECKBOX = GC_X.
        GS_FIELDCAT-JUST = GC_C.
        GS_FIELDCAT-OUTPUTLEN = 5.
        PERFORM SET_TEXT USING TEXT-H11.
      WHEN 'LOEVM'.
        GS_FIELDCAT-CHECKBOX = GC_X.
        GS_FIELDCAT-JUST = GC_C.
        GS_FIELDCAT-OUTPUTLEN = 4.
        PERFORM SET_TEXT USING TEXT-H12.
      WHEN 'MSG'.
        GS_FIELDCAT-OUTPUTLEN = 40.
        PERFORM SET_TEXT USING TEXT-H13.
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
  SET HANDLER GO_EVENT_RECEIVER->HANDLE_CHANGED_FINISHED FOR PO_GRID.
*  SET HANDLER GO_EVENT_RECEIVER->HANDLE_SUBTOTAL_TEXT    FOR PO_GRID.
  SET HANDLER GO_EVENT_RECEIVER->HANDLE_DOUBLE_CLICK     FOR PO_GRID.
  SET HANDLER GO_EVENT_RECEIVER->HANDLE_HOTSPOT_CLICK    FOR PO_GRID.
  SET HANDLER GO_EVENT_RECEIVER->HANDLE_TOOLBAR          FOR PO_GRID.
  SET HANDLER GO_EVENT_RECEIVER->HANDLE_USER_COMMAND     FOR PO_GRID.
  SET HANDLER GO_EVENT_RECEIVER->HANDLE_ONF4             FOR PO_GRID.
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
      IT_OUTTAB            = GT_LIST[]
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

  CLEAR GS_F4.
  GS_F4-FIELDNAME = 'ZTERM'.
  GS_F4-REGISTER  = GC_X.
  APPEND GS_F4 TO GT_F4.

  CALL METHOD GO_GRID->REGISTER_F4_FOR_FIELDS
    EXPORTING
      IT_F4 = GT_F4.

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
  LOOP AT GT_LIST ASSIGNING FIELD-SYMBOL(<FS_LIST>).
    PERFORM SET_ATTRIBUTES_LINE CHANGING <FS_LIST>.
  ENDLOOP.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_ATTRIBUTES_LINE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- <FS_LIST>
*&---------------------------------------------------------------------*
FORM SET_ATTRIBUTES_LINE  CHANGING PS_LIST LIKE GS_LIST.
  DATA : LT_CELLTAB TYPE LVC_T_STYL.
  DATA : WA_CELLTAB TYPE LVC_S_STYL.

  CLEAR PS_LIST-CELLTAB[].

  LOOP AT GT_FIELDCAT INTO DATA(LS_FCAT).
    CLEAR:WA_CELLTAB.
    WA_CELLTAB-FIELDNAME = LS_FCAT-FIELDNAME.
    CASE LS_FCAT-FIELDNAME.
      WHEN 'SEL'.
*        IF PS_LIST-FLAG2 IS NOT INITIAL.
        WA_CELLTAB-STYLE = CL_GUI_ALV_GRID=>MC_STYLE_ENABLED.
*        ELSE.
*          WA_CELLTAB-STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED.
*        ENDIF.


      WHEN 'VKORG' OR 'VTWEG' OR 'SPART' OR 'VKGRP'.
*        IF PS_LIST-FLAG1 EQ GC_X.
        WA_CELLTAB-STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED.
*        ELSE.
*          WA_CELLTAB-STYLE = CL_GUI_ALV_GRID=>MC_STYLE_ENABLED.
*        ENDIF.
      WHEN 'ZTERM'.
        IF PS_LIST-FLAG1 EQ GC_X.
          WA_CELLTAB-STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED.
        ELSE.
          WA_CELLTAB-STYLE = CL_GUI_ALV_GRID=>MC_STYLE_ENABLED.
        ENDIF.


      WHEN 'ZZDEFAULT' OR 'LOEVM'.
        WA_CELLTAB-STYLE = CL_GUI_ALV_GRID=>MC_STYLE_ENABLED.

      WHEN OTHERS.
        WA_CELLTAB-STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED.

    ENDCASE.
    INSERT WA_CELLTAB INTO TABLE LT_CELLTAB.
  ENDLOOP.
  INSERT LINES OF LT_CELLTAB INTO TABLE PS_LIST-CELLTAB.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form ALV_DATA_CHANGED
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> ER_DATA_CHANGED
*&      --> E_ONF4_AFTER
*&      --> SENDER
*&---------------------------------------------------------------------*
FORM ALV_DATA_CHANGED  USING    PO_DATA_CHANGED TYPE REF TO
                                          CL_ALV_CHANGED_DATA_PROTOCOL
                                PE_ONF4_AFTER
                                PV_SENDER.

  FIELD-SYMBOLS:<FS_VALUE> TYPE ANY.

*---------------------------------------------------
*-신규라인
*---------------------------------------------------
  LOOP AT PO_DATA_CHANGED->MT_INSERTED_ROWS INTO DATA(LS_INS_ROW).
    LOOP AT GT_FIELDCAT INTO DATA(LS_FCAT).
      IF LS_FCAT-FIELDNAME NE 'STAT1' AND
         LS_FCAT-FIELDNAME NE 'STAT2' AND
         LS_FCAT-FIELDNAME NE 'VKGRP_TX' AND
         LS_FCAT-FIELDNAME NE 'ZTERM_TX' AND
         LS_FCAT-FIELDNAME NE 'MSG'.

        IF LS_FCAT-FIELDNAME EQ 'SEL' OR
           LS_FCAT-FIELDNAME EQ 'ZTERM' OR
           LS_FCAT-FIELDNAME EQ 'ZZDEFAULT' OR
           LS_FCAT-FIELDNAME EQ 'LOEVM'.
          CALL METHOD PO_DATA_CHANGED->MODIFY_STYLE
            EXPORTING
              I_ROW_ID    = LS_INS_ROW-ROW_ID
              I_FIELDNAME = LS_FCAT-FIELDNAME
              I_STYLE     = CL_GUI_ALV_GRID=>MC_STYLE_ENABLED.
        ELSE.
          CALL METHOD PO_DATA_CHANGED->MODIFY_STYLE
            EXPORTING
              I_ROW_ID    = LS_INS_ROW-ROW_ID
              I_FIELDNAME = LS_FCAT-FIELDNAME
              I_STYLE     = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED.
        ENDIF.



      ELSE.
        CALL METHOD PO_DATA_CHANGED->MODIFY_STYLE
          EXPORTING
            I_ROW_ID    = LS_INS_ROW-ROW_ID
            I_FIELDNAME = LS_FCAT-FIELDNAME
            I_STYLE     = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED.

      ENDIF.



    ENDLOOP.

    CALL METHOD PO_DATA_CHANGED->MODIFY_CELL
      EXPORTING
        I_ROW_ID    = LS_INS_ROW-ROW_ID
        I_FIELDNAME = 'FLAG2'
        I_VALUE     = GC_I. "ICON_CREATE.

    CALL METHOD PO_DATA_CHANGED->MODIFY_CELL
      EXPORTING
        I_ROW_ID    = LS_INS_ROW-ROW_ID
        I_FIELDNAME = 'VKORG'
        I_VALUE     = CONV VKORG( VALUE #( S_VKORG[ 1 ]-LOW OPTIONAL ) ).

    CALL METHOD PO_DATA_CHANGED->MODIFY_CELL
      EXPORTING
        I_ROW_ID    = LS_INS_ROW-ROW_ID
        I_FIELDNAME = 'VTWEG'
        I_VALUE     = CONV VTWEG( VALUE #( S_VTWEG[ 1 ]-LOW OPTIONAL ) ).

    CALL METHOD PO_DATA_CHANGED->MODIFY_CELL
      EXPORTING
        I_ROW_ID    = LS_INS_ROW-ROW_ID
        I_FIELDNAME = 'SPART'
        I_VALUE     = CONV SPART( VALUE #( S_SPART[ 1 ]-LOW OPTIONAL ) ).

    CALL METHOD PO_DATA_CHANGED->MODIFY_CELL
      EXPORTING
        I_ROW_ID    = LS_INS_ROW-ROW_ID
        I_FIELDNAME = 'VKGRP'
        I_VALUE     = CONV VKGRP( VALUE #( S_VKGRP[ 1 ]-LOW OPTIONAL ) ).

  ENDLOOP.

*---------------------------------------------------
*-변경라인
*---------------------------------------------------
  LOOP AT PO_DATA_CHANGED->MT_MOD_CELLS INTO DATA(LS_MOD_CELLS).
    IF <FS_VALUE> IS ASSIGNED. UNASSIGN <FS_VALUE>.ENDIF.
    ASSIGN COMPONENT LS_MOD_CELLS-FIELDNAME OF STRUCTURE GS_LIST TO <FS_VALUE>.
    CHECK SY-SUBRC EQ 0.

    CALL METHOD PO_DATA_CHANGED->GET_CELL_VALUE
      EXPORTING
        I_ROW_ID    = LS_MOD_CELLS-ROW_ID
        I_FIELDNAME = LS_MOD_CELLS-FIELDNAME
      IMPORTING
        E_VALUE     = <FS_VALUE>.

    CALL METHOD PO_DATA_CHANGED->MODIFY_CELL
      EXPORTING
        I_ROW_ID    = LS_MOD_CELLS-ROW_ID
        I_FIELDNAME = LS_MOD_CELLS-FIELDNAME
        I_VALUE     = <FS_VALUE>.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form ALV_CHANGED_FINISHED
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> E_MODIFIED
*&      --> ET_GOOD_CELLS
*&      --> SENDER
*&---------------------------------------------------------------------*
FORM ALV_CHANGED_FINISHED  USING    PV_MODIFIED TYPE CHAR01
                                    PT_GOOD_CELLS TYPE LVC_T_MODI
                                    PV_SENDER.

  DATA: LT_MODI TYPE LVC_T_MODI.
  DATA: WA_MODI TYPE LVC_S_MODI.

  CHECK PV_MODIFIED IS NOT INITIAL.

  LT_MODI[] = CORRESPONDING #( PT_GOOD_CELLS[] ).
  SORT LT_MODI BY ROW_ID.
  DELETE ADJACENT DUPLICATES FROM LT_MODI COMPARING ROW_ID.

  LOOP AT LT_MODI INTO WA_MODI.
    CLEAR GS_LIST.
    READ TABLE GT_LIST ASSIGNING FIELD-SYMBOL(<FS_LIST>) INDEX WA_MODI-ROW_ID.
    CHECK SY-SUBRC EQ 0.
    CLEAR:<FS_LIST>-STAT1,<FS_LIST>-RSLT,<FS_LIST>-MSG.

    "CHECK
    PERFORM CHECK_INPUT_LINE CHANGING <FS_LIST>.


    "변경 체크
    PERFORM SET_CHANGE_DATA CHANGING <FS_LIST>.

    "ICON
    PERFORM SET_LED CHANGING <FS_LIST>.

    PERFORM SET_ATTRIBUTES_LINE CHANGING <FS_LIST>.
  ENDLOOP.

*  "KEY 중복체크
*  PERFORM CHECK_KEY_DUPLICATE.

  PERFORM REFRESH_ALV USING GO_GRID.

  CALL METHOD CL_GUI_CFW=>FLUSH.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form ALV_TOOLBAR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> E_OBJECT
*&      --> E_INTERACTIVE
*&      --> SENDER
*&---------------------------------------------------------------------*
FORM ALV_TOOLBAR  USING    PE_OBJECT
                                TYPE REF TO CL_ALV_EVENT_TOOLBAR_SET
                           PE_INTERACTIVE
                           PV_SENDER.
  DATA: LS_TOOLBAR TYPE STB_BUTTON.

  CLEAR LS_TOOLBAR.
  LS_TOOLBAR-BUTN_TYPE = '3'.
  LS_TOOLBAR-DISABLED = SPACE.
  APPEND LS_TOOLBAR TO PE_OBJECT->MT_TOOLBAR.

  CLEAR LS_TOOLBAR.
  LS_TOOLBAR-FUNCTION = 'ZINSRT'.
  LS_TOOLBAR-ICON     = ICON_INSERT_ROW.
  LS_TOOLBAR-BUTN_TYPE = '0'.
  LS_TOOLBAR-DISABLED = SPACE.
* LS TOOLBAR-TEXT  = TEXT-B10.
  LS_TOOLBAR-QUICKINFO = SPACE.
  LS_TOOLBAR-CHECKED   = SPACE.
  APPEND LS_TOOLBAR TO PE_OBJECT->MT_TOOLBAR.

*  CLEAR LS_TOOLBAR.
*  LS_TOOLBAR-FUNCTION = 'ZDELET'.
*  LS_TOOLBAR-ICON     = ICON_DELETE_ROW.
*  LS_TOOLBAR-BUTN_TYPE = '0'.
*  LS_TOOLBAR-DISABLED = SPACE.
** LS TOOLBAR-TEXT  = TEXT-B10.
*  LS_TOOLBAR-QUICKINFO = SPACE.
*  LS_TOOLBAR-CHECKED   = SPACE.
*  APPEND LS_TOOLBAR TO PE_OBJECT->MT_TOOLBAR.

  CLEAR LS_TOOLBAR.
  LS_TOOLBAR-BUTN_TYPE = '3'.
  LS_TOOLBAR-DISABLED = SPACE.
  APPEND LS_TOOLBAR TO PE_OBJECT->MT_TOOLBAR.

  CLEAR LS_TOOLBAR.
  LS_TOOLBAR-FUNCTION = 'ZSELA'.
  LS_TOOLBAR-ICON     = ICON_SELECT_ALL.
  LS_TOOLBAR-BUTN_TYPE = '0'.
  LS_TOOLBAR-DISABLED = SPACE.
* LS TOOLBAR-TEXT  = TEXT-B10.
  LS_TOOLBAR-QUICKINFO = SPACE.
  LS_TOOLBAR-CHECKED   = SPACE.
  APPEND LS_TOOLBAR TO PE_OBJECT->MT_TOOLBAR.

  CLEAR LS_TOOLBAR.
  LS_TOOLBAR-FUNCTION = 'ZDALL'.
  LS_TOOLBAR-ICON     = ICON_DESELECT_ALL.
  LS_TOOLBAR-BUTN_TYPE = '0'.
  LS_TOOLBAR-DISABLED = SPACE.
* LS TOOLBAR-TEXT  = TEXT-B10.
  LS_TOOLBAR-QUICKINFO = SPACE.
  LS_TOOLBAR-CHECKED   = SPACE.
  APPEND LS_TOOLBAR TO PE_OBJECT->MT_TOOLBAR.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form ALV_USER_COMMAND
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> E_UCOMM
*&      --> SENDER
*&---------------------------------------------------------------------*
FORM ALV_USER_COMMAND  USING    PV_UCOMM
                                PV_SENDER.

  CASE PV_UCOMM.
    WHEN 'ZINSRT'."라인추가
      PERFORM INSERT_ROW.

    WHEN 'ZDELET'."라인삭제
      PERFORM DELETE_ROW.

    WHEN 'ZSELA'."전체선택
      PERFORM SELECT_ALL.

    WHEN 'ZDALL'."전체해제
      PERFORM DESELECT_ALL.

    WHEN OTHERS.

  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form ALV_ONF4
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> E_FIELDNAME
*&      --> E_FIELDVALUE
*&      --> ES_ROW_NO
*&      --> ER_EVENT_DATA
*&      --> ET_BAD_CELLS
*&      --> E_DISPLAY
*&      --> SENDER
*&---------------------------------------------------------------------*
FORM ALV_ONF4  USING    PV_FIELDNAME
                        PV_FIELDVALUE
                        PS_ROW_NO     TYPE LVC_S_ROID
                        PO_EVENT_DATA TYPE REF TO CL_ALV_EVENT_DATA
                        PT_BAD_CELLS  TYPE LVC_T_MODI
                        PV_DISPLAY
                        PV_SENDER.

  FIELD-SYMBOLS <FS_MODI> TYPE LVC_T_MODI.

  DATA : LT_RETURN TYPE TABLE OF DDSHRETVAL,
         LS_RETURN TYPE DDSHRETVAL.


  CASE PV_FIELDNAME.
    WHEN 'ZTERM'.
      PERFORM F4_ALV_ZTERM CHANGING PV_FIELDVALUE.


  ENDCASE.

  PO_EVENT_DATA->M_EVENT_HANDLED = 'X'. " Data Changed Event 를 수행한다.

  CHECK PV_DISPLAY IS INITIAL.
  CHECK PV_FIELDVALUE IS NOT INITIAL.

  ASSIGN PO_EVENT_DATA->M_DATA->* TO <FS_MODI>.
  DATA(WA_MODI) = VALUE LVC_S_MODI( ROW_ID    = PS_ROW_NO-ROW_ID
                                    FIELDNAME = PV_FIELDNAME
                                    VALUE     = PV_FIELDVALUE ).

  APPEND WA_MODI TO <FS_MODI>.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form F4_ALV_ZTERM
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- LS_RETURN
*&---------------------------------------------------------------------*
FORM F4_ALV_ZTERM  CHANGING PV_FIELDVALUE.

  DATA: LV_VALUE           LIKE VBKD-ZTERM.

  CALL FUNCTION 'FI_F4_ZTERM'
    EXPORTING
      I_KOART       = 'D'
*     I_ZTERM       = ' '
*     I_XSHOW       = ' '
*     I_ZTYPE       = ' '
*     I_NO_POPUP    = ' '
    IMPORTING
      E_ZTERM       = LV_VALUE
*     ET_ZTERM      =
    EXCEPTIONS
      NOTHING_FOUND = 1
      OTHERS        = 2.
  IF SY-SUBRC <> 0.
    EXIT.
  ENDIF.

  PV_FIELDVALUE = LV_VALUE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form INSERT_ROW
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM INSERT_ROW .

  CLEAR GS_LIST.
  GS_LIST-STAT2 = ICON_CREATE.
  GS_LIST-FLAG2 = GC_I.
  GS_LIST-VKORG = VALUE #( S_VKORG[ 1 ]-LOW OPTIONAL ).
  GS_LIST-VTWEG = VALUE #( S_VTWEG[ 1 ]-LOW OPTIONAL ).
  GS_LIST-SPART = VALUE #( S_SPART[ 1 ]-LOW OPTIONAL ).
  GS_LIST-VKGRP = VALUE #( S_VKGRP[ 1 ]-LOW OPTIONAL ).

  "CHECK
  PERFORM CHECK_INPUT_LINE CHANGING GS_LIST.

  "변경 체크
  PERFORM SET_CHANGE_DATA CHANGING GS_LIST.

  "ICON
  PERFORM SET_LED CHANGING GS_LIST.

  PERFORM SET_ATTRIBUTES_LINE CHANGING GS_LIST.
*  GS_LIST-VKGRP_TX = ZGTSD_CL_COMMON2=>GET_VKGRP_TEXT( IV_VKGRP = GS_LIST-VKGRP
*                                                       IV_SPRAS = SY-LANGU     ).
*  PERFORM SET_ATTRIBUTES_LINE CHANGING GS_LIST.
*  APPEND GS_LIST TO GT_LIST.
  INSERT GS_LIST INTO GT_LIST INDEX 1.

  PERFORM REFRESH_ALV USING GO_GRID.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form DELETE_ROW
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM DELETE_ROW .

  IF LINE_EXISTS( GT_LIST[ SEL = GC_X ] ).
  ELSE.
    MESSAGE I000 WITH TEXT-M02 DISPLAY LIKE GC_E.
    EXIT.
  ENDIF.

  LOOP AT GT_LIST ASSIGNING FIELD-SYMBOL(<FS_LIST>) WHERE SEL = GC_X.
    GV_INDEX = SY-TABIX.
    IF <FS_LIST>-FLAG1 IS NOT INITIAL. "DB 존재
      <FS_LIST>-STAT2 = ICON_DELETE.
    ELSE.
      DELETE GT_LIST INDEX GV_INDEX.
    ENDIF.
  ENDLOOP.

  PERFORM REFRESH_ALV USING GO_GRID.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SELECT_ALL
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SELECT_ALL .
  CLEAR GS_LIST.
  GS_LIST-SEL = GC_X.
  MODIFY GT_LIST FROM GS_LIST TRANSPORTING SEL
                              WHERE ( SEL = SPACE   AND
                                      FLAG1 = GC_X  AND
                                      FLAG2 NE SPACE    ) OR
                                    ( SEL = SPACE   AND
                                      FLAG1 = SPACE AND
                                      FLAG2 NE SPACE    ).




  PERFORM REFRESH_ALV USING GO_GRID.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form DESELECT_ALL
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM DESELECT_ALL .
  CLEAR GS_LIST.
  MODIFY GT_LIST FROM GS_LIST TRANSPORTING SEL WHERE SEL = GC_X.

  PERFORM REFRESH_ALV USING GO_GRID.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_CHANGED_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CHECK_CHANGED_DATA .
  DATA LV_VALID TYPE CHAR01.

  CALL METHOD GO_GRID->CHECK_CHANGED_DATA
    IMPORTING
      E_VALID = LV_VALID.

ENDFORM.
