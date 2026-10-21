*&---------------------------------------------------------------------*
*& Include          ZGTPPI2020F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form MODIFY_FIRST_SCREEN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM MODIFY_FIRST_SCREEN .

  IF RA_REDO EQ ABAP_TRUE.
    LOOP AT SCREEN.
      IF SCREEN-GROUP1 = 'EXC'.
        SCREEN-ACTIVE = 0.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.
  ELSE.
    LOOP AT SCREEN.
      IF SCREEN-GROUP1 = 'RED'.
        SCREEN-ACTIVE = 0.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.
  ENDIF.

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

  DATA: LT_DYNPFIELDS TYPE TABLE OF DYNPREAD WITH HEADER LINE.

  IF PA_FLD01 IS NOT INITIAL.
    SELECT SINGLE FLD_02 INTO GV_SYTXT
      FROM ZGTPPT1010
      WHERE MODULE_KIND = 'PP'
      AND FLD_01 = PA_FLD01
      AND CODEGRP = '0010'.

    LT_DYNPFIELDS-FIELDNAME = 'GV_SYTXT'.
    LT_DYNPFIELDS-FIELDVALUE = GV_SYTXT.
    APPEND LT_DYNPFIELDS.

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
        UNDEFIND_ERROR       = 7.
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
  CLEAR: GT_DISP.
  IF RA_SEND EQ ABAP_TRUE.
    GV_FLD01 = PA_FLD01.
    GV_FLDTXT = GV_SYTXT.
  ELSE.
    GV_FLD01 = PA_FLD02.
    GV_FLDTXT = GV_SYTX2.
  ENDIF.

  IF RA_SEND EQ ABAP_TRUE.
    PERFORM SELECT_SEND_DATA.
  ELSE."REDO
    PERFORM SELECT_LOG_DATA.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form data_changed
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
  DATA : LV_CALL_FUNC.
*  CLEAR  : gv_chk_line, gv_chk_value.

*  CASE p_sender.
*    WHEN go_grid_0100 OR go_grid_0230.
*      LOOP AT po_data_changed->mt_good_cells INTO ls_mod_cells.
*        CASE ls_mod_cells-fieldname.
*          WHEN 'CHECK'.
*            gv_chk_line = ls_mod_cells-row_id.
*            gv_chk_value = ls_mod_cells-value.
*            lv_call_func = abap_true.
*        ENDCASE.
*      ENDLOOP.
*  ENDCASE.
*
*  IF lv_call_func IS NOT INITIAL.
*    CALL FUNCTION 'SAPGUI_SET_FUNCTIONCODE'
*      EXPORTING
*        functioncode           = 'SETCHECK'              " Function code
*      EXCEPTIONS
*        function_not_supported = 1                " Not supported on this front end platform
*        OTHERS                 = 2.
*    IF sy-subrc <> 0.
*    ENDIF.
*  ENDIF.

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
  GS_LAYOUT_0100-ZEBRA = ABAP_TRUE.
*  GS_LAYOUT_0100-NO_ROWMARK   = 'X'.
  GS_LAYOUT_0100-SEL_MODE   = 'A'.
  GS_LAYOUT_0100-STYLEFNAME = 'CELLTAB'.
  GS_LAYOUT_0100-CTAB_FNAME   = 'CELLCOL'.

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

  FIELD-SYMBOLS <LFS_FCAT> LIKE LINE OF GT_FIELDCAT_0100.


  DATA: TABLE TYPE REF TO DATA.
  CREATE DATA TABLE LIKE GT_DISP.
  ASSIGN TABLE->* TO FIELD-SYMBOL(<TABLE>).

  TRY.
      CL_SALV_TABLE=>FACTORY(
        IMPORTING
          R_SALV_TABLE = DATA(SALV_TABLE)
        CHANGING
          T_TABLE      = <TABLE> ).

      GT_FIELDCAT_0100 = CL_SALV_CONTROLLER_METADATA=>GET_LVC_FIELDCATALOG(
        R_COLUMNS      = SALV_TABLE->GET_COLUMNS( )
        R_AGGREGATIONS = SALV_TABLE->GET_AGGREGATIONS( )
      ).
    CATCH CX_SALV_MSG.
  ENDTRY.

  LOOP AT GT_FIELDCAT_0100 ASSIGNING <LFS_FCAT>.
    <LFS_FCAT>-KEY = ABAP_FALSE.
    CASE <LFS_FCAT>-DATATYPE.
      WHEN 'CHAR'
        OR 'DATS'
        OR 'TIMS'.
        <LFS_FCAT>-JUST = 'C'.
    ENDCASE.

    CASE <LFS_FCAT>-FIELDNAME.
      WHEN 'ZIFKEY'.
        <LFS_FCAT>-REPTEXT = TEXT-F06.
      WHEN 'ZSTAT'.
        <LFS_FCAT>-ICON   = ABAP_TRUE.
        <LFS_FCAT>-REPTEXT = TEXT-F01.
      WHEN 'ZMESSAGE'.
        <LFS_FCAT>-REPTEXT = TEXT-F02.
      WHEN 'ZSYSTEM_ID'.
        <LFS_FCAT>-REPTEXT = TEXT-F03.
      WHEN 'ZSYSTEM_DESC'.
        <LFS_FCAT>-REPTEXT = TEXT-F05.
      WHEN 'LINNO'.
        <LFS_FCAT>-REPTEXT = TEXT-F04.
      WHEN 'IFDAT'.
        <LFS_FCAT>-REPTEXT = TEXT-F07.
      WHEN 'IFTIM'.
        <LFS_FCAT>-REPTEXT = TEXT-F08.
      WHEN 'IFNAM'.
        <LFS_FCAT>-REPTEXT = TEXT-F09.
      WHEN OTHERS.
*        <LFS_FCAT>-NO_OUT = ABAP_TRUE.
    ENDCASE.

    IF RA_SEND EQ ABAP_TRUE.
      CASE <LFS_FCAT>-FIELDNAME.
        WHEN 'ZIFKEY' OR 'IFDAT' OR 'IFTIM' OR 'IFNAM'.
          <LFS_FCAT>-NO_OUT = ABAP_TRUE.
        WHEN OTHERS.
      ENDCASE.
    ELSE.

    ENDIF.

    <LFS_FCAT>-SCRTEXT_S = <LFS_FCAT>-REPTEXT.
    <LFS_FCAT>-SCRTEXT_M = <LFS_FCAT>-REPTEXT.
    <LFS_FCAT>-SCRTEXT_L = <LFS_FCAT>-REPTEXT.
    <LFS_FCAT>-F4AVAILABL = ABAP_FALSE.
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

  GS_VARIANT-REPORT = SY-REPID.

  "*-- Build field catalog for the alv control
  CALL METHOD GO_GRID_0100->SET_TABLE_FOR_FIRST_DISPLAY
    EXPORTING
      I_DEFAULT                     = ABAP_TRUE
      IS_LAYOUT                     = GS_LAYOUT_0100
      IS_VARIANT                    = GS_VARIANT
      I_SAVE                        = 'A'
      IT_TOOLBAR_EXCLUDING          = GT_EXCLUDE_0100
    CHANGING
      IT_FIELDCATALOG               = GT_FIELDCAT_0100
*     IT_SORT                       = GT_SORT
      IT_OUTTAB                     = GT_DISP[]
    EXCEPTIONS
      INVALID_PARAMETER_COMBINATION = 1
      PROGRAM_ERROR                 = 2
      TOO_MANY_LINES                = 3.

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
* 셀 컬러부여
  DATA : LT_COLTAB TYPE LVC_T_SCOL.
  DATA : LS_COLTAB TYPE LVC_S_SCOL.

  DATA : LT_CELLTAB TYPE LVC_T_STYL.
  DATA : LS_CELLTAB TYPE LVC_S_STYL.

*  LOOP AT GT_DISP ASSIGNING FIELD-SYMBOL(<GS_DISP>).
*    REFRESH LT_COLTAB.
*    REFRESH LT_CELLTAB.
*
*    LOOP AT GT_FIELDCAT_0100 INTO DATA(LS_FIELDCAT).
*      CASE LS_FIELDCAT-FIELDNAME.
*        WHEN 'STATUS'.
*          CASE <GS_DISP>-STATUS.
*            WHEN '삭제'.
**        바탕 빨강
*              CLEAR LS_CELLTAB.
*              LS_CELLTAB-FIELDNAME = 'STATUS'.
*              LS_CELLTAB-STYLE = ALV_STYLE_COLOR_INT_NEGATIVE.
**              LS_CELLTAB-STYLE2 = ALV_STYLE_COLOR_INV_BACKGROUND.
*              INSERT LS_CELLTAB INTO TABLE LT_CELLTAB.
**            체크박스 수정금지
*              CLEAR LS_CELLTAB.
*              LS_CELLTAB-FIELDNAME = 'CHECK'.
*              LS_CELLTAB-STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED.
*              INSERT LS_CELLTAB INTO TABLE LT_CELLTAB.
*            WHEN '완료'.
**        바탕 연한그린
*              CLEAR LS_COLTAB.
*              LS_CELLTAB-FIELDNAME = 'CHECK'.
*              LS_CELLTAB-STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED.
*              INSERT LS_CELLTAB INTO TABLE LT_CELLTAB.
**            체크박스 수정금지
*            WHEN OTHERS.
*              CLEAR LS_COLTAB.
*              LS_CELLTAB-FIELDNAME = LS_FIELDCAT-FIELDNAME.
*              LS_CELLTAB-STYLE = ALV_STYLE_COLOR_INT_KEY.
*              INSERT LS_CELLTAB INTO TABLE LT_CELLTAB.
*          ENDCASE.
*        WHEN 'GRPNR' OR 'ERDAT' OR 'ORDNO_C' OR 'GCATG' OR 'MATNR'.
**       key 색깔지정
*          CLEAR LS_COLTAB.
*          LS_CELLTAB-FIELDNAME = LS_FIELDCAT-FIELDNAME.
*          LS_CELLTAB-STYLE = ALV_STYLE_COLOR_INT_KEY.
*          INSERT LS_CELLTAB INTO TABLE LT_CELLTAB.
*      ENDCASE.
*    ENDLOOP.
*    <GS_DISP>-CELLCOL = LT_COLTAB.
*    <GS_DISP>-CELLTAB = LT_CELLTAB.
*  ENDLOOP.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form REFRESH_GRID
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GO_GRID_0100
*&---------------------------------------------------------------------*
FORM REFRESH_GRID  USING    PO_GRID TYPE REF TO CL_GUI_ALV_GRID..

  DATA: LS_SCROLL   TYPE LVC_S_STBL.

  LS_SCROLL-ROW = 'X'.
  LS_SCROLL-COL = 'X'.

  CASE PO_GRID.
    WHEN GO_GRID_0100.
      PERFORM SET_CELL_ATTRIBUTE_GRID_0100.
  ENDCASE.

  CALL METHOD PO_GRID->REFRESH_TABLE_DISPLAY
    EXPORTING
      I_SOFT_REFRESH = 'X'
      IS_STABLE      = LS_SCROLL.

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

*  CASE PO_GRID.
*    WHEN GO_GRID_0100.
**// Event Handler ##
*      SET HANDLER GO_EVENT_HANDLER->HANDLE_DATA_CHANGED               FOR PO_GRID.
*  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form toolbar_pros
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

*  CASE po_sender.
*    WHEN go_grid_0201.
**      IF GT_ITEM_DISP[] IS INITIAL.
*      PERFORM set_toolbar TABLES po_object->mt_toolbar
*                           USING : 'DELE' icon_delete '오더삭제' '오더삭제' 0,
*                                      'CHG_PRD' icon_set_state '오더전환' '오더전환' 0 ,
*                                      'RELEASE' icon_release '생산오더릴리즈' '생산오더릴리즈' 0 ,
*                                      '' '' '' '' 3,
*                                       'EDIT_NUM' icon_unlink '여장편집' '여장편집' 0 ,
*                                      'CHG_BATCH' icon_tools '설비변경' '설비변경' 0 ,
*                                      'CHG_PEGGING' icon_ps_relationship 'Pegging변경' 'Pegging변경' 0 ,
*                                      'SET_MULTY' icon_interval_include_green '복조장구성' '복조장구성' 0 ,
*                                      'SEPERATE' icon_interval_exclude '개별오더전환' '개별오더전환' 0 .
*  ENDCASE.

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
*& Form user_command_pros
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> SENDER
*&      --> E_UCOMM
*&---------------------------------------------------------------------*
FORM USER_COMMAND_PROS  USING   PO_SENDER  TYPE REF TO CL_GUI_ALV_GRID
                                 PV_UCOMM.

*  CASE po_sender.
*    WHEN go_grid_0201.
*      CASE pv_ucomm.
*        WHEN 'DELE'. " 오더삭제
*          PERFORM delete_order.
*        WHEN 'CHG_PRD'.  " 오더전환
*          PERFORM conversion_prod_order.
*        WHEN 'EDIT_NUM'.  " 여장편집
*          PERFORM edit_adlength.
*        WHEN 'RELEASE'.   " 생산오더 릴리즈
*          PERFORM release_prd_order.
*        WHEN 'CHG_BATCH'.  " 설비변경
*          PERFORM change_batch.
*        WHEN 'CHG_PEGGING'. " Pegging변경
*          PERFORM process_pegging.
*      ENDCASE.
*  ENDCASE.

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
*& Form double_click
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> SENDER
*&      --> E_ROW
*&      --> E_COLUMN
*&---------------------------------------------------------------------*
FORM DOUBLE_CLICK  USING    P_SENDER TYPE REF TO CL_GUI_ALV_GRID
                            P_ROW TYPE LVC_S_ROW
                            P_COLUMN TYPE LVC_S_COL.

  DATA : LV_FNAME01 TYPE FIELDNAME. "오더넘버
  DATA : LV_FNAME02 TYPE FIELDNAME. " 품목번호
  DATA : LV_FNAME03 TYPE FIELDNAME. " 오더타입
  DATA : LV_NUM(2) TYPE N.

*  FIELD-SYMBOLS <lv_line_seq> TYPE any.
*  FIELD-SYMBOLS <lv_line> TYPE any.
*  FIELD-SYMBOLS <lv_ordnr> TYPE any.
*  FIELD-SYMBOLS <lv_posnr> TYPE any.
*  FIELD-SYMBOLS <lv_ordty> TYPE any.
*
*  DEFINE __get_index_of_table.
*    IF <lv_line_seq> IS ASSIGNED. UNASSIGN <lv_line_seq>. ENDIF.
*    ASSIGN COMPONENT 'LINE_SEQ' OF STRUCTURE <ls_main_201> TO <lv_line_seq>.
*  END-OF-DEFINITION.
*
*  DEFINE __get_line_of_table.
*    IF <lv_line> IS ASSIGNED. UNASSIGN <lv_line>. ENDIF.
*    ASSIGN COMPONENT 'LINE' OF STRUCTURE <ls_main_201> TO <lv_line>.
*  END-OF-DEFINITION.
*
*  DEFINE __set_field_name.
*    CLEAR : lv_fname01, lv_fname02, lv_fname03.
*    lv_fname01 = &1 && '_ORDNR'.
*    lv_fname02 = &1 && '_POSNR'.
*    lv_fname03 = &1 && '_ORDTY'.
*  END-OF-DEFINITION.
*
*  DEFINE __assign_field.
*    IF <lv_ordnr> IS ASSIGNED. UNASSIGN <lv_ordnr>. ENDIF.
*    ASSIGN COMPONENT lv_fname01 OF STRUCTURE <ls_routing> TO <lv_ordnr>.
*    IF <lv_posnr> IS ASSIGNED. UNASSIGN <lv_posnr>. ENDIF.
*    ASSIGN COMPONENT lv_fname02 OF STRUCTURE <ls_routing> TO <lv_posnr>.
*    IF <lv_ordty> IS ASSIGNED. UNASSIGN <lv_ordty>. ENDIF.
*    ASSIGN COMPONENT lv_fname03 OF STRUCTURE <ls_routing> TO <lv_ordty>.
*  END-OF-DEFINITION.
*
*  CHECK p_row-index > 0.
*
*  CASE p_sender.
*    WHEN go_grid_0201.
*      IF p_column-fieldname = 'ORDNO_C'.
*        READ TABLE <gt_main_201> ASSIGNING FIELD-SYMBOL(<ls_main_201>) INDEX p_row-index.
*        __get_index_of_table.
*        CLEAR lv_num.
*        READ TABLE <gt_routing> ASSIGNING FIELD-SYMBOL(<ls_routing>) INDEX <lv_line_seq>.
*        __set_field_name lv_num.
*        __assign_field.
*        SET PARAMETER ID 'AUN' FIELD <lv_ordnr>.
*        CALL TRANSACTION 'VA03' AND SKIP FIRST SCREEN.
*
*        EXIT.
*      ENDIF.
*
*      IF NOT line_exists( gt_seq_routing[ chart = p_column-fieldname ] ).
*        RETURN.
*      ENDIF.
*
*      READ TABLE <gt_main_201> ASSIGNING <ls_main_201> INDEX p_row-index.
*      __get_line_of_table.
*      IF <lv_line> = 1. " 첫번째 열은 오더정보
*        __get_index_of_table.
*        CLEAR lv_num.
*        READ TABLE <gt_routing> ASSIGNING <ls_routing> INDEX <lv_line_seq>.
*
*        DO.
*          ADD 1 TO lv_num.
*          __set_field_name lv_num.
*          __assign_field.
*          IF <lv_ordty> = p_column-fieldname.
*            READ TABLE gt_2010 INTO DATA(ls_2010) WITH KEY gong_cd = p_column-fieldname
*                                                                            ordnr = <lv_ordnr>
*                                                                            posnr = <lv_posnr>.
*
*            CASE ls_2010-ordty.
*              WHEN 'PLN'.
*                SET PARAMETER ID 'PAF' FIELD <lv_ordnr>.
*                CALL TRANSACTION 'MD13' AND SKIP FIRST SCREEN.
*
*              WHEN 'PRD'.
*                SET PARAMETER ID 'ANR' FIELD <lv_ordnr>.
*                CALL TRANSACTION 'CO03' AND SKIP FIRST SCREEN.
*            ENDCASE.
*            EXIT.
*          ENDIF.
*
*          IF lv_num >= gv_line_jojang.
*            EXIT.
*          ENDIF.
*        ENDDO.
*
*
*      ELSE. " 두번째 열은 자재정보
*        READ TABLE gt_seq_routing INTO DATA(ls_seq_routing) WITH KEY chart = p_column-fieldname.
*        SET PARAMETER ID 'WRK' FIELD p_werks.
*        SET PARAMETER ID 'MXX' FIELD 'K'.
*        SET PARAMETER ID 'MAT' FIELD ls_seq_routing-matnr..
*        CALL TRANSACTION 'MM03' AND SKIP FIRST SCREEN.
*
*      ENDIF.
*
*    WHEN go_grid_0220.
*      READ TABLE gt_del_disp INTO gs_del_disp INDEX p_row-index.
*      CASE gs_del_disp-ordty.
*        WHEN 'PLN'.
*          SET PARAMETER ID 'PAF' FIELD gs_del_disp-ordnr.
*          CALL TRANSACTION 'MD13' AND SKIP FIRST SCREEN.
*        WHEN 'PRD'.
*          SET PARAMETER ID 'ANR' FIELD gs_del_disp-ordnr.
*          CALL TRANSACTION 'CO03' AND SKIP FIRST SCREEN.
*      ENDCASE.
*
*  ENDCASE.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_SYSTEM_LIST
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_SYSTEM_LIST USING PV_FIELD.
*
  DATA: LT_RETURN     TYPE TABLE OF DDSHRETVAL WITH HEADER LINE,
        LT_DYNPFIELDS TYPE TABLE OF DYNPREAD WITH HEADER LINE.
  IF GT_SYS[] IS INITIAL.

    SELECT DISTINCT CODEID, FLD_01, FLD_02 INTO TABLE @DATA(LT_1010)
      FROM ZGTPPT1010
      WHERE MODULE_KIND = 'PP'
      AND CODEGRP = '0010' ORDER BY CODEID.

    LOOP AT LT_1010 INTO DATA(LS_1010).
      CLEAR GT_SYS.
      MOVE-CORRESPONDING LS_1010 TO GT_SYS.
      APPEND GT_SYS.
    ENDLOOP.

    DELETE ADJACENT DUPLICATES FROM GT_SYS COMPARING ALL FIELDS.

  ENDIF.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      RETFIELD        = 'FLD_01'
      DYNPPROG        = SY-CPROG
      DYNPNR          = SY-DYNNR
      DYNPROFIELD     = PV_FIELD
      VALUE_ORG       = 'S'
    TABLES
      VALUE_TAB       = GT_SYS
      RETURN_TAB      = LT_RETURN
    EXCEPTIONS
      PARAMETER_ERROR = 1
      NO_VALUES_FOUND = 2
      OTHERS          = 3.

  READ TABLE LT_RETURN INDEX 1.

  READ TABLE GT_SYS WITH KEY FLD_01 = LT_RETURN-FIELDVAL.

  IF SY-SUBRC IS INITIAL AND PV_FIELD EQ 'PA_FLD01'.
    CLEAR: LT_DYNPFIELDS, LT_DYNPFIELDS[].
    LT_DYNPFIELDS-FIELDNAME = 'GV_SYTXT'.
    LT_DYNPFIELDS-FIELDVALUE = GT_SYS-FLD_02.
    APPEND LT_DYNPFIELDS.
    LT_DYNPFIELDS-FIELDNAME = 'PA_FLD01'.
    LT_DYNPFIELDS-FIELDVALUE = LT_RETURN-FIELDVAL.
    APPEND LT_DYNPFIELDS.
  ELSE.
    CLEAR: LT_DYNPFIELDS, LT_DYNPFIELDS[].
    LT_DYNPFIELDS-FIELDNAME = 'GV_SYTX2'.
    LT_DYNPFIELDS-FIELDVALUE = GT_SYS-FLD_02.
    APPEND LT_DYNPFIELDS.
    LT_DYNPFIELDS-FIELDNAME = 'PA_FLD02'.
    LT_DYNPFIELDS-FIELDVALUE = LT_RETURN-FIELDVAL.
    APPEND LT_DYNPFIELDS.

  ENDIF.
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
      UNDEFIND_ERROR       = 7.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SELECT_SEND_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SELECT_SEND_DATA .

  SELECT DISTINCT ZT01~*
    INTO CORRESPONDING FIELDS OF TABLE @GT_DISP
    FROM ZGTPPT2000 AS ZT01
    JOIN ZGTPPT2010 AS ZT02
      ON ZT01~GRPNR EQ ZT02~GRPNR
    WHERE ZT01~SPGCD   IN @SO_SPGCD
      AND ZT01~WERKS   IN @SO_WERKS
      AND ZT01~GRPNR   IN @SO_GRPNR
      AND ZT01~ERDAT   IN @SO_DATE.
*      AND zt01~zstatus NE 'D'.

  SORT GT_DISP.

  LOOP AT GT_DISP ASSIGNING FIELD-SYMBOL(<FS>).
    <FS>-ZSTAT = ICON_LED_INACTIVE.
    <FS>-ZSYSTEM_ID = GV_FLD01.
    <FS>-ZSYSTEM_DESC = GV_FLDTXT.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SELECT_LOG_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SELECT_LOG_DATA .

  SELECT * INTO CORRESPONDING FIELDS OF TABLE GT_DISP
    FROM ZGTPPT2030
    WHERE ZSYSTEM_ID = GV_FLD01
      AND SPGCD IN SO_SPGCD
      AND WERKS IN SO_WERKS
      AND GRPNR IN SO_GRPNR
      AND IFDAT IN SO_IFDAT.

  SELECT *
    INTO TABLE @DATA(LT_IMG)
    FROM ZGTPPT1010
    WHERE MODULE_KIND = 'PP'
    AND CODEGRP = '0010'.

  LOOP AT GT_DISP ASSIGNING FIELD-SYMBOL(<FS>).

    IF <FS>-ZSTAT EQ '00' OR  <FS>-ZSTAT EQ '0'.
      <FS>-ZSTAT  = ICON_LED_GREEN.
    ELSE.
      <FS>-ZSTAT  = ICON_LED_RED.
    ENDIF.

    READ TABLE LT_IMG INTO DATA(LS_IMG) WITH KEY FLD_01 = <FS>-ZSYSTEM_ID.
    IF SY-SUBRC IS INITIAL.
      <FS>-ZSYSTEM_DESC = LS_IMG-FLD_02.
      CLEAR LS_IMG.
    ENDIF.
  ENDLOOP.

  CASE ABAP_TRUE.
    WHEN RA_GRN. " 성공
      DELETE GT_DISP WHERE ZSTAT = ICON_LED_RED.
    WHEN RA_RED. " 오류
      DELETE GT_DISP WHERE ZSTAT = ICON_LED_GREEN.
    WHEN OTHERS.
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SEND_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM SEND_DATA .

  DATA: LT_EXEC  LIKE TABLE OF GS_DISP WITH HEADER LINE.

  CLEAR: GT_HEADER[], GT_ITEM[], LT_EXEC[].

  PERFORM GET_SELECTED_ROWS TABLES LT_EXEC.
  PERFORM MAKE_SEND_DATA TABLES LT_EXEC.
  IF GT_ITEM[] IS NOT INITIAL.
    PERFORM EXECUTE_RFC.
  ELSE.
    IF PA_BATCH NE ABAP_TRUE.
      MESSAGE S000 DISPLAY LIKE 'E' WITH TEXT-E01." '전송 데이터가 없습니다.' .
    ENDIF.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_SELECTED_ROWS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LT_EXEC
*&---------------------------------------------------------------------*
FORM GET_SELECTED_ROWS  TABLES   PT_EXEC STRUCTURE GS_DISP.

  DATA: LT_INDEX TYPE LVC_T_ROW WITH HEADER LINE.

  IF PA_BATCH IS INITIAL.
    CALL METHOD GO_GRID_0100->GET_SELECTED_ROWS
      IMPORTING
        ET_INDEX_ROWS = LT_INDEX[].
    LOOP AT LT_INDEX.
      READ TABLE GT_DISP INTO GS_DISP INDEX LT_INDEX-INDEX.
*      IF GS_DISP-ZSTAT EQ ICON_LED_GREEN AND ."NE ICON_LED_INACTIVE.
*        MESSAGE E000 WITH '전송된 건이 포함되어 있습니다.'.
*      ENDIF.
      MOVE-CORRESPONDING GS_DISP TO PT_EXEC.
      APPEND PT_EXEC.
      CLEAR PT_EXEC.
    ENDLOOP.
  ELSE.
    PT_EXEC[]  = GT_DISP[].
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form MAKE_SEND_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM MAKE_SEND_DATA TABLES   PT_EXEC STRUCTURE GS_DISP.

  DATA: LV_FLD_03 TYPE ZGTE_FLDVAL,
        LV_FLD_04 TYPE ZGTE_FLDVAL.

  DATA: LV_TABIX TYPE SY-TABIX.

  SELECT *
    FROM ZGTPPT1010
    WHERE MODULE_KIND = 'PP'
    AND CODEGRP = '0010'
    AND FLD_01 = @GV_FLD01
    INTO TABLE @DATA(LT_IMG).

  LOOP AT PT_EXEC INTO DATA(PS_EXEC).
    CLEAR : LV_FLD_03, LV_FLD_04.
    LV_FLD_03 = PS_EXEC-WERKS.
    LV_FLD_04 = PS_EXEC-SPGCD.

    READ TABLE LT_IMG INTO DATA(LS_IMG)
                WITH KEY FLD_03 = LV_FLD_03 FLD_04 = LV_FLD_04.
    IF SY-SUBRC IS NOT INITIAL.
      DELETE TABLE PT_EXEC FROM PS_EXEC.
    ENDIF.
  ENDLOOP.

  IF PT_EXEC[] IS NOT INITIAL.
    SELECT *
      INTO CORRESPONDING FIELDS OF TABLE GT_HEADER
      FROM ZGTPPT2000
       FOR ALL ENTRIES IN PT_EXEC
     WHERE GRPNR = PT_EXEC-GRPNR
*       AND ordno = pt_exec-ordno
*       AND posnr = pt_exec-posnr
*       AND linno = pt_exec-linno
       AND ZSTATUS NE 'D'.
  ENDIF.

  DATA(LT_CHK_HEADER) = GT_HEADER.
  SORT LT_CHK_HEADER BY GRPNR.
  DELETE ADJACENT DUPLICATES FROM LT_CHK_HEADER COMPARING GRPNR.

  IF LT_CHK_HEADER IS NOT INITIAL.
    SELECT *
      FROM ZGTPPT2010
      INTO CORRESPONDING FIELDS OF TABLE GT_ITEM
      FOR ALL ENTRIES IN LT_CHK_HEADER
     WHERE GRPNR = LT_CHK_HEADER-GRPNR .

    IF NOT ( '6500' NOT IN SO_WERKS AND '6600' NOT IN SO_WERKS ).
      SELECT *
        FROM ZGTPPT2010
        INTO TABLE @DATA(LT_2010)
        FOR ALL ENTRIES IN @LT_CHK_HEADER
       WHERE GRPNR = @LT_CHK_HEADER-GRPNR .
    ENDIF.

  ENDIF.

  LOOP AT GT_HEADER INTO DATA(LT_HEADER).
    LV_TABIX = SY-TABIX.

    CALL FUNCTION 'CONVERSION_EXIT_MATN1_OUTPUT'
      EXPORTING
        INPUT  = LT_HEADER-MATNR
      IMPORTING
        OUTPUT = LT_HEADER-MATNR.

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
      EXPORTING
        INPUT  = LT_HEADER-ORDNO
      IMPORTING
        OUTPUT = LT_HEADER-ORDNO.

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
      EXPORTING
        INPUT  = LT_HEADER-POSNR
      IMPORTING
        OUTPUT = LT_HEADER-POSNR.

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
      EXPORTING
        INPUT  = LT_HEADER-KUNNR
      IMPORTING
        OUTPUT = LT_HEADER-KUNNR.

    MODIFY GT_HEADER FROM LT_HEADER INDEX LV_TABIX.
  ENDLOOP.

  LOOP AT GT_ITEM INTO DATA(LT_ITEM).
    LV_TABIX = SY-TABIX.

*   탄뎀설정시 탄뎀참조오더 오더타입 X로 전송
    IF NOT ( '6500' NOT IN SO_WERKS AND '6600' NOT IN SO_WERKS ).
      READ TABLE LT_2010 INTO DATA(LS_2010) WITH KEY GONG_SEQ = LT_ITEM-GONG_SEQ
                                                           ORDNR = LT_ITEM-ORDNR
                                                           POSNR = LT_ITEM-POSNR
                                                           ORDTY = LT_ITEM-ORDTY
                                                           REF_TANDEM = 'X'.
      IF SY-SUBRC EQ 0.
        LT_ITEM-ORDTY = 'X'.
      ENDIF.
    ENDIF.

    LT_ITEM-DMORD = COND #( WHEN LT_ITEM-DMORD IS INITIAL
                            THEN '0' ELSE LT_ITEM-DMORD ).
    LT_ITEM-DMLINE = COND #( WHEN LT_ITEM-DMLINE IS INITIAL
                            THEN '0' ELSE LT_ITEM-DMLINE ).

    LT_ITEM-REORD = COND #( WHEN LT_ITEM-REORD IS INITIAL
                            THEN '0' ELSE LT_ITEM-REORD ).
    LT_ITEM-RELINE = COND #( WHEN LT_ITEM-RELINE IS INITIAL
                            THEN '0' ELSE LT_ITEM-RELINE ).

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
      EXPORTING
        INPUT  = LT_ITEM-ORDNR
      IMPORTING
        OUTPUT = LT_ITEM-ORDNR.

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
      EXPORTING
        INPUT  = LT_ITEM-POSNR
      IMPORTING
        OUTPUT = LT_ITEM-POSNR.

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
      EXPORTING
        INPUT  = LT_ITEM-DMORD
      IMPORTING
        OUTPUT = LT_ITEM-DMORD.

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
      EXPORTING
        INPUT  = LT_ITEM-DMLINE
      IMPORTING
        OUTPUT = LT_ITEM-DMLINE.

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
      EXPORTING
        INPUT  = LT_ITEM-REORD
      IMPORTING
        OUTPUT = LT_ITEM-REORD.

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
      EXPORTING
        INPUT  = LT_ITEM-RELINE
      IMPORTING
        OUTPUT = LT_ITEM-RELINE.

    MODIFY GT_ITEM FROM LT_ITEM INDEX LV_TABIX.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form EXECUTE_RFC
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM EXECUTE_RFC .
  DATA LT_HEADER TYPE TABLE OF ZGTPPSIF0018.
  DATA LT_ITEM   TYPE TABLE OF ZGTPPSIF0019.
  DATA LT_ZGTPPT2030 TYPE TABLE OF ZGTPPT2030.
  DATA: LV_TS      TYPE TIMESTAMPL,
        LV_RESULT  TYPE ZO_RESULT,
        LV_MESSAGE TYPE ZO_MESSAGE,
        LV_ICON    TYPE ICON_D,
        LV_DEST    TYPE ZIFDEST-DEST,
        LV_TOTAL   TYPE I,
        LV_SUCCESS TYPE I,
        LV_ERROR   TYPE I.

  IF GT_HEADER[] IS NOT INITIAL AND GT_ITEM[] IS NOT INITIAL.
    CALL FUNCTION 'Z_IF_DESTINATION'
      EXPORTING
        GUBUN                 = 'P1'
      IMPORTING
        DEST_NAME             = LV_DEST
      EXCEPTIONS
        DESTINATION_NOT_FOUND = 1
        OTHERS                = 2.

    LOOP AT GT_HEADER INTO DATA(LS_KEY)
                      GROUP BY ( GRPNR = LS_KEY-GRPNR )
                      INTO DATA(LT_GROUP).
      LV_TOTAL += 1.

      CLEAR: LT_HEADER, LT_ZGTPPT2030.

      LOOP AT GROUP LT_GROUP INTO DATA(LS_HEADER).
        GET TIME STAMP FIELD LV_TS.

        APPEND INITIAL LINE TO LT_ZGTPPT2030 REFERENCE INTO DATA(LR_ZGTPPT2030).
        LR_ZGTPPT2030->* = CORRESPONDING #( LS_HEADER ).
        LR_ZGTPPT2030->* = VALUE #( BASE LR_ZGTPPT2030->* ZIFKEY     = LV_TS
                                                          IFDAT      = SY-DATUM
                                                          IFTIM      = SY-TIMLO
                                                          IFNAM      = SY-UNAME
                                                          ZSYSTEM_ID = GV_FLD01 ).
        LS_HEADER-ZDATETIME = SY-DATUM && SY-UZEIT. " 20260401 추가
        APPEND LS_HEADER TO LT_HEADER.
      ENDLOOP.

      LT_ITEM = FILTER #( GT_ITEM USING KEY SKEY WHERE GRPNR EQ LT_GROUP-GRPNR ).

      TRY.
          CLEAR: LV_RESULT, LV_MESSAGE.

          CALL FUNCTION 'ZGTPP_IF_O_PEG' DESTINATION LV_DEST
            EXPORTING
              SYSTEM_ID  = GV_FLD01
            IMPORTING
              ZO_RESULT  = LV_RESULT
              ZO_MESSAGE = LV_MESSAGE
            TABLES
              ET_GRP     = LT_HEADER
              ET_PEG     = LT_ITEM.

        CATCH CX_ROOT INTO DATA(LO_ROOT). " 전송 실패시 덤프방지

      ENDTRY.

      IF LV_RESULT EQ '00' OR LV_RESULT EQ '0'.
        LV_ICON = ICON_LED_GREEN.
        LV_SUCCESS += 1.
      ELSE.
        LV_ICON = ICON_LED_RED.
        LV_ERROR += 1.

        IF PA_BATCH IS NOT INITIAL AND SY-BATCH IS NOT INITIAL.
          WRITE:/ LT_GROUP-GRPNR, LV_MESSAGE.
        ENDIF.
      ENDIF.

      MODIFY LT_ZGTPPT2030 FROM VALUE #( ZSTAT    = LV_RESULT
                                         ZMESSAGE = LV_MESSAGE )
                           TRANSPORTING ZSTAT ZMESSAGE
                           WHERE GRPNR EQ LT_GROUP-GRPNR.

      MODIFY GT_DISP FROM VALUE #( ZSTAT    = LV_ICON
                                   ZMESSAGE = LV_MESSAGE )
                           TRANSPORTING ZSTAT ZMESSAGE
                           WHERE GRPNR EQ LT_GROUP-GRPNR.

      MODIFY ZGTPPT2030 FROM TABLE LT_ZGTPPT2030.
      COMMIT WORK.
    ENDLOOP.

    IF PA_BATCH IS INITIAL.
      PERFORM REFRESH_GRID USING GO_GRID_0100.
    ENDIF.

    MESSAGE S009 WITH LV_TOTAL LV_SUCCESS LV_ERROR.
  ELSE.
    MESSAGE E000 WITH TEXT-E01." '전송 데이터가 없습니다.' .
  ENDIF.

*  DATA: lt_index TYPE lvc_t_row WITH HEADER LINE.
*
*  DATA: ls_log        TYPE zgtppt2030,
*        lv_ts         TYPE timestampl,
*        lv_result     TYPE zo_result,
*        lv_message    TYPE zo_message,
*        lv_icon       TYPE icon_d,
*        lv_dest       TYPE zifdest-dest,
*        lv_zsystem_id TYPE zgtppt3060-zsystem_id.
*
*  IF gt_header[] IS NOT INITIAL AND gt_item[] IS NOT INITIAL.
*    CLEAR: lv_result, lv_message, lv_dest, lv_icon.
*
*    CALL FUNCTION 'Z_IF_DESTINATION'
*      EXPORTING
*        gubun                 = 'P1'
*      IMPORTING
*        dest_name             = lv_dest
*      EXCEPTIONS
*        destination_not_found = 1
*        OTHERS                = 2.
*
*    "call rfc
*    DATA(lt_header) = gt_header[].
*    TRY.
*        CALL FUNCTION 'ZGTPP_IF_O_PEG' DESTINATION lv_dest
*          EXPORTING
*            system_id  = gv_fld01
*          IMPORTING
*            zo_result  = lv_result
*            zo_message = lv_message
*          TABLES
*            et_grp     = gt_header
*            et_peg     = gt_item.
*      CATCH cx_root INTO DATA(lo_root). " 전송 실패시 덤프방지
*
*
*    ENDTRY.
*
*
*    IF lv_result EQ '00' OR lv_result EQ '0'.
*      lv_icon = icon_led_green.
*    ELSE.
*      lv_icon = icon_led_red.
*    ENDIF.
*
*    LOOP AT lt_header ASSIGNING FIELD-SYMBOL(<fs_header>).
*      CLEAR ls_log.
*      GET TIME STAMP FIELD lv_ts.
*      MOVE-CORRESPONDING <fs_header> TO ls_log.
*
*      ls_log-zifkey = lv_ts.
*      ls_log-ifdat = sy-datum.
*      ls_log-iftim = sy-timlo.
*      ls_log-ifnam = sy-uname.
*
*      ls_log-zstat = lv_result.
*      ls_log-zmessage = lv_message.
*      ls_log-zsystem_id = gv_fld01.
*      INSERT zgtppt2030 FROM ls_log.
*    ENDLOOP.
*
*    IF sy-subrc IS INITIAL.
*      COMMIT WORK.
*      IF pa_batch IS INITIAL.
*        CALL METHOD go_grid_0100->get_selected_rows
*          IMPORTING
*            et_index_rows = lt_index[].
*        LOOP AT lt_index.
*          CLEAR gs_disp.
*          READ TABLE gt_disp INTO gs_disp INDEX lt_index-index.
*          gs_disp-zstat = lv_icon.
*          gs_disp-zmessage = lv_message.
*          MODIFY gt_disp FROM gs_disp INDEX lt_index-index.
*        ENDLOOP.
*
*        PERFORM refresh_grid USING go_grid_0100.
*
*      ENDIF.
*      IF pa_batch IS INITIAL.
*        MESSAGE s000 WITH TEXT-s01. "'패깅 정보 전송 성공.'
*      ENDIF.
*    ELSE.
*      MESSAGE e000 WITH TEXT-e02. "'처리 중 오류가 발생했습니다.' .
*    ENDIF.
*  ELSE.
*    MESSAGE e000 WITH TEXT-e01." '전송 데이터가 없습니다.' .
*  ENDIF.

ENDFORM.
