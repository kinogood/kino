************************************************************************
*                                                                      *
* Title         : ZTIR9210                                             *
*                                                                      *
* Description   : [Report] 계산서(FINBIL) 수신데이타 현황(수입)        *
*                                                                      *
* Creation Date : 2004/02/07                                           *
*                                                                      *
* Author        : SeogBong, Kang                                       *
*                 Copyright ⓒ ASEG Co., LTD. All rights reserved.     *
************************************************************************
*                                                                      *
* Inputs        :                                                      *
*                                                                      *
* Outputs       :                                                      *
*                                                                      *
************************************************************************
*                                                                      *
* Processing Steps:                                                    *
*   1.                                                                 *
*                                                                      *
************************************************************************
*----------------------------------------------------------------------*
*                M O D I F I C A T I O N   L O G                       *
*----------------------------------------------------------------------*
* Date         Programmer       Transport#  Description                *
*----------------------------------------------------------------------*
*                                                                      *
*                                                                      *
************************************************************************
PROGRAM   ztir9210
          MESSAGE-ID zmti00
          NO STANDARD PAGE HEADING.

************************************************************************
* TYPES and TYPE-POOLS                                                 *
************************************************************************
TYPE-POOLS: slis,   "> Globale Type(ALV)
            kkblo.  "> Generic list types

TYPES:  BEGIN OF ty_list.
        INCLUDE STRUCTURE ztssfb00.
TYPES : celltab TYPE lvc_t_styl.            " Cell단위 수정 스타일
TYPES:  END   OF ty_list.

************************************************************************
* User Included                                                        *
************************************************************************
INCLUDE : <icon>,
          <symbol>,
          zts_reuse_bdc_subroutine_f00.
** JS전선 회사코드 2007/04 KSH --------------------------------------
DATA: l_yn    type c.
INCLUDE zts_authorization_check. "AUTHORIZATION_CHECK
** JS전선 회사코드 2007/04 KSH --------------------------------------

*---------------------------------------------------------------------*
*> Message dialog box용                                               *
*---------------------------------------------------------------------*
DATA: BEGIN OF it_msg  OCCURS 0.
        INCLUDE STRUCTURE ztismessage.
DATA: END   OF it_msg.

************************************************************************
* SAP Tables                                                           *
************************************************************************
TABLES: t001,      ">Company Codes
        t005  ,    ">국가.
        ztitrqs,   ">
        ztitrqk,   ">
        ztitig00,  ">
        ztitig07,  ">[TraSys] 제비용 일괄전기 Default Value관리.
        ztstfbk,   ">[TraSys] 계산서(FINBIL) Header
        ztstfbp,   ">[TraSys] 계산서(FINBIL) Items Table
        ztivcs00,  ">비용 Views
        ztitcsk,   ">비용 Header
        ztisscrcom, ">
        vf_kred,    ">
        skat.       ">G/L 계정 마스터레코드 (계정과목표: 내역)

TABLES: bapi1093_0,   ">BAPI 환율테이블.
        bapicurx,     ">BAPI에 대한 외화환산모듈구조.
        bapiret1.     ">리턴매개변수.

************************************************************************
* CONSTANTS                                                            *
************************************************************************
CONSTANTS:
** JS전선 회사코드 2007/04 BY-MH.LEE -----------------
*    c_bukrs     LIKE t001-bukrs     VALUE '1000',   ">Company code
** JS전선 회사코드 2007/04 ---------------------------
    c_tcode     LIKE sy-tcode       VALUE 'ZTIR913'.
************************************************************************
* Internal Tables                                                      *
************************************************************************
*> Select용.
DATA: it_disp  TYPE STANDARD TABLE OF ty_list,
      it_seld  TYPE STANDARD TABLE OF ty_list,
      it_temp  TYPE STANDARD TABLE OF ty_list,
      gs_disp  TYPE ty_list.

DATA: BEGIN OF it_vendor  OCCURS 2,
      lifnr    TYPE lifnr,
      END   OF it_vendor.

DATA: BEGIN OF it_mwskz  OCCURS 2,
      mwskz    TYPE mwskz,
      END   OF it_mwskz.

DATA: BEGIN OF it_bupla  OCCURS 2,
      bupla    TYPE bupla,
      END   OF it_bupla.

DATA: BEGIN OF lt_collect  OCCURS 2,
      lifnr    TYPE lifnr,
      bupla    TYPE bupla,
      mwskz    TYPE mwskz,
      END   OF lt_collect.

DATA: BEGIN OF it_cstcl  OCCURS 2,
      cstcl    TYPE zticstcl,
      END   OF it_cstcl.

DATA: BEGIN OF it_finno  OCCURS 2,
      finno    TYPE ztsfinno,
      END   OF it_finno.

*> 비용코드.
DATA: BEGIN OF it_ztitig06  OCCURS 2.
        INCLUDE STRUCTURE ztisig06.
DATA: END   OF it_ztitig06.

*> 수취인 HELP용.
DATA : dynprog  LIKE sy-repid,
       dynnr    LIKE sy-dynnr,
       g_window_title(60),
       g_display.

DATA : BEGIN OF xlfza OCCURS 0,
       lifnr   LIKE lfza-lifnr,
       bukrs   LIKE lfza-bukrs,
       empfk   LIKE lfza-empfk,
       name1   LIKE lfa1-name1.
DATA : END   OF xlfza.

DATA: BEGIN OF it_ztstfbk  OCCURS 2.
        INCLUDE STRUCTURE   ztstfbk.
DATA: END   OF it_ztstfbk.

*> 비용항목.
DATA : BEGIN OF it_ztstfbc OCCURS 0.
        INCLUDE STRUCTURE ztstfbc.
DATA : END   OF it_ztstfbc.

*> 거래상대방(은행)
DATA: BEGIN OF it_ztstig3  OCCURS 2.
        INCLUDE STRUCTURE ztstig3.
DATA: END   OF it_ztstig3.

DATA: BEGIN OF it_ztsvfb00  OCCURS 2.
        INCLUDE STRUCTURE   ztsvfb00.
DATA: END   OF it_ztsvfb00.

DATA : g_bukrs TYPE bukrs.

************************************************************************
* DATA Declarations                                                    *
************************************************************************
* Fieldcatalog Grid
DATA: it_fieldcat_g TYPE lvc_t_fcat,
      gs_fieldcat_g LIKE LINE OF it_fieldcat_g.

*icon
DATA: g_lights_name TYPE lvc_cifnm VALUE 'ICON'.

* Button exclude.
DATA : it_exclude   TYPE ui_functions.

* Layout GRID.
DATA: gs_layout_g   TYPE lvc_s_layo.
DATA: gs_stable     TYPE lvc_s_stbl.

* PRINT GRID.
DATA:  gs_print_g   TYPE lvc_s_prnt.
DATA : gs_sort_g    TYPE lvc_s_sort.
DATA : it_sort_g    TYPE lvc_t_sort.
DATA : gs_filter_g  TYPE lvc_s_filt.
DATA : it_filter_g  TYPE lvc_t_filt.
DATA:  gs_f4        TYPE lvc_s_f4.      " F4 필드 관련
DATA:  it_f4        TYPE lvc_t_f4.
DATA:  ws_f4        TYPE ddshretval.

************************************************************************
* DATA Declarations                                                    *
************************************************************************
DATA: g_splitter            TYPE REF TO cl_gui_splitter_container,
      g_custom_container    TYPE REF TO cl_gui_custom_container,
      g_custom_container_1  TYPE REF TO cl_gui_container,
      g_grid                TYPE REF TO cl_gui_alv_grid,
* Docking Container
      g_docking             TYPE REF TO cl_gui_docking_container.

DATA: g_repid             LIKE sy-repid.

DATA: gs_variante         LIKE disvariant,
      gs_def_variante     LIKE disvariant,
      g_variant_exit(1)   TYPE c,
      g_variant_save(1)   TYPE c,
      g_variant_def(1)    TYPE c.

DATA: g_tabix             LIKE sy-tabix,
      g_index             LIKE sy-index,
      g_subrc             LIKE sy-subrc,
      g_answer            TYPE c,
      g_process           TYPE c,
      g_count             TYPE i,
      g_cnt               TYPE i,
      g_wrbtr             TYPE wrbtr,
      g_wmwst             TYPE wmwst,
      g_fwbas             TYPE fwbas,
      ok_code             LIKE sy-ucomm,
      g_success           TYPE i,
      g_error             TYPE i,
      g_line              TYPE i,
      g_linen(3)          TYPE n,
      g_out_text(70)      TYPE c.
DATA: ok-code             LIKE sy-datum.

* Possible Entry
DATA : it_values TYPE TABLE OF seahlpres,
       it_fields TYPE TABLE OF dfies,
       gs_value  TYPE seahlpres,
       gs_field  TYPE dfies,

*       ls_f4     TYPE ddshretval,
       gs_modi   TYPE lvc_s_modi.

* define fields and field-symbols for data-update
FIELD-SYMBOLS : <f4tab> TYPE lvc_t_modi.

* POSSIBLE ENTRY HEADER TEXT
DATA : BEGIN OF it_field_tab OCCURS 0.
        INCLUDE STRUCTURE dfies.
DATA : END OF it_field_tab.

*>----------------------------------------------------------------------
*> ZTIR9110 [Report] 수입요청 관련비용 관리.
*>----------------------------------------------------------------------
INCLUDE zti_reuse_forms_for_fi_posting.


************************************************************************
* SELECT-OPTIONS / PARAMETERS                                          *
************************************************************************
SELECTION-SCREEN BEGIN OF BLOCK box1 WITH FRAME TITLE text-001.
SELECT-OPTIONS:
       s_bukrs  FOR ztstfbk-bukrs   "회사코드
                    MEMORY ID  buk ,
       s_finno  FOR ztstfbk-finno,  "계산서 문서번호.
       s_refno  FOR ztstfbk-refno,  "참조문서 번호.
       s_epart  FOR ztstfbk-epart,  "EDI 파트너.
       s_bilgb  FOR ztstfbk-bilgb,  "계산서 구분.
       s_tradt  FOR ztstfbk-tradt,  "계좌입금일.
       s_recdt  FOR ztstfbk-recdt,  "접수일자.
       s_cnam   FOR ztstfbk-cnam,   "작성인
       s_cdat   FOR ztstfbk-cdat,   "생성일
       s_ctme   FOR ztstfbk-ctme.   "작성시간.

SELECTION-SCREEN ULINE.
PARAMETERS: p_step1 RADIOBUTTON GROUP ab1 DEFAULT 'X',
            p_step2 RADIOBUTTON GROUP ab1,
            p_step3 RADIOBUTTON GROUP ab1.
SELECTION-SCREEN ULINE.
PARAMETERS: p_nmatch AS CHECKBOX DEFAULT space.
SELECTION-SCREEN END OF BLOCK box1.

*> Report variant
SELECTION-SCREEN: BEGIN OF BLOCK alv WITH FRAME TITLE text-003.
PARAMETERS: p_vari LIKE disvariant-variant.
SELECTION-SCREEN: END OF BLOCK alv.

************************************************************************
*                                                                      *
* INITIALIZATION Event                                                 *
*                                                                      *
************************************************************************
INITIALIZATION.
*> Read default layout (description only, w/o field catalog)
  PERFORM p1000_alv_fields_initial.
*> Initializaton By Program
  PERFORM p1001_initialization.

************************************************************************
*                                                                      *
* AT SELECTION-SCREEN Events                                           *
*                                                                      *
************************************************************************
AT SELECTION-SCREEN.
*> 사용자 Input values Check
  PERFORM p1101_check_input_value.
*> 사용자 레이아웃 Input values Check
  PERFORM p1101_check_variant_value.
** JS전선 회사코드 2007/04 KSH --------------------------------------
*> AUTHORIZATION_CHECK
  PERFORM p1102_authorization_check USING s_bukrs-low.
** JS전선 회사코드 2007/04 KSH --------------------------------------

*> 레이아웃 HELP
AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_vari.
  PERFORM p1102_f4_for_variant.

************************************************************************
*                                                                      *
* START-OF-SELECTION Event                                             *
*                                                                      *
************************************************************************
START-OF-SELECTION.
  CHECK g_answer EQ 'Y'.
*> 검색조건에 해당하는 데이타를 Select.
  PERFORM p2000_data_selections.

************************************************************************
*                                                                      *
* END-OF-SELECTION Event                                               *
*                                                                      *
************************************************************************
END-OF-SELECTION.

  CHECK g_answer EQ 'Y'.
  CHECK g_line NE 0.
*> PROGRESS Display.
  g_linen    = 90.
  g_out_text = '리스트를 구성 중입니다 %99999%%'(p03).
  REPLACE '%99999%'(p99) WITH g_linen INTO g_out_text.
  PERFORM show_progress_bar(ztir0000) USING g_out_text g_linen.

*> Dynamic Data Table build
  PERFORM p3000_field_category_build.
  PERFORM p3210_exclude_table_build   USING 'IT_EXCLUDE'.
  PERFORM p3500_sort_table_build .
  PERFORM p3700_layout_build.
  PERFORM p3800_field_attribute_change.
*> Screen Called
  CALL SCREEN 0100.
*
************************************************************************
*                                                                      *
* TOP-OF-PAGE Event                                                    *
*                                                                      *
************************************************************************
TOP-OF-PAGE.

************************************************************************
*                                                                      *
* END-OF-PAGE Event                                                    *
*                                                                      *
************************************************************************
END-OF-PAGE.


************************************************************************
*                                                                      *
* TOP-OF-PAGE DURING LINE-SELECTION Event                              *
*                                                                      *
************************************************************************
TOP-OF-PAGE DURING LINE-SELECTION.


************************************************************************
*                                                                      *
* AT LINE-SELECTION Event                                              *
*                                                                      *
************************************************************************
AT LINE-SELECTION.


************************************************************************
*                                                                      *
* AT USER-COMMAND Event                                                *
*                                                                      *
************************************************************************
AT USER-COMMAND.


*eject
************************************************************************
*                                                                      *
* S U B R O U T I N E S                                                *
*                                                                      *
************************************************************************

*&---------------------------------------------------------------------*
*&      Form  SET_FINBIL_LOCK_OBJECT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM set_finbil_lock_object  USING    p_mode
                                      p_finno
                                      p_msgty
                                      p_subrc.
  CLEAR: p_subrc.

  IF p_mode EQ 'L'.
    CALL FUNCTION 'ENQUEUE_EZ_TS_ZTSTFBK'
      EXPORTING
        mandt          = sy-mandt
        finno          = p_finno
      EXCEPTIONS
        foreign_lock   = 1
        system_failure = 2
        OTHERS         = 3.
    IF sy-subrc <> 0.
      p_subrc = 8.
      MESSAGE ID sy-msgid TYPE p_msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.
  ELSE.
    CALL FUNCTION 'DEQUEUE_EZ_TS_ZTSTFBK'
      EXPORTING
        mandt = sy-mandt
        finno = p_finno.
  ENDIF.

ENDFORM.                    " SET_FINBIL_LOCK_OBJECT
*&---------------------------------------------------------------------*
*&      Form  finbil_data_delete
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM finbil_data_delete  USING p_count.

  DATA: l_count   TYPE i.
  DATA: l_subrc   TYPE subrc.
  DATA: l_tabix   TYPE sy-tabix.

  CLEAR: p_count.
  REFRESH: it_msg.

  CALL FUNCTION 'POPUP_TO_CONFIRM_LOSS_OF_DATA'
    EXPORTING
     textline1           = '선택한 계산서 전체 내역들을 삭제합니다.'
     textline2           = '정말로 삭제하시겠습니까?'
      titel              = '삭제확인'
*         DEFAULTOPTION       = 'N'
   IMPORTING
     answer              = g_answer .

  CHECK g_answer EQ 'J'.

  CLEAR: l_count.

  it_temp[] = it_disp[].

  LOOP AT it_finno.
    l_tabix = sy-tabix.
*> Lock Object.
    CLEAR: l_subrc.
    PERFORM  set_finbil_lock_object USING 'L'
                                          it_finno-finno
                                          'S'
                                          l_subrc.
    IF l_subrc NE 0.
      PERFORM set_return_message_fill USING 'E'.
      DELETE it_finno INDEX l_tabix.
    ENDIF.
  ENDLOOP.

  LOOP AT it_finno.
    l_tabix = sy-tabix.
*>> FINBIL 문서 검증.
    SELECT SINGLE *
      FROM ztstfbk
     WHERE finno  EQ  it_finno-finno.
    IF sy-subrc NE 0.
      MESSAGE s890 WITH it_finno-finno.
      PERFORM set_return_message_fill USING 'E'.
      DELETE it_finno INDEX l_tabix.
      CONTINUE.
    ENDIF.

*> 기반영분 데이타 오류.
    IF ztstfbk-acept EQ 'Y'.
      MESSAGE s707 WITH '계산서' it_finno-finno.
      PERFORM set_return_message_fill USING 'E'.
      DELETE it_finno INDEX l_tabix.
      CONTINUE.
    ENDIF.

*>> 업무구분 검증.
    IF gs_disp-imexi NE 'I'.
      MESSAGE s879(zmti00) WITH it_finno-finno.
      PERFORM set_return_message_fill USING 'E'.
      DELETE it_finno INDEX l_tabix.
      CONTINUE.
    ENDIF.

    CLEAR: l_count.
    SELECT COUNT( * )
      INTO l_count
      FROM ztstfbc
     WHERE finno EQ it_finno-finno
       AND sysyn EQ 'Y'.
    IF l_count GT 0.
      MESSAGE s707 WITH '계산서' it_finno-finno.
      PERFORM set_return_message_fill USING 'E'.
      DELETE it_finno INDEX l_tabix.
      CONTINUE.
    ENDIF.

*> Begin transaction.
    SET UPDATE TASK LOCAL.
    DELETE FROM ztstfbk WHERE finno EQ it_finno-finno.
    DELETE FROM ztstfbp WHERE finno EQ it_finno-finno.
    DELETE FROM ztstfbc WHERE finno EQ it_finno-finno.
    COMMIT WORK.
    MESSAGE s715 WITH it_finno-finno.
    PERFORM set_return_message_fill USING 'I'.
    ADD 1 TO l_count.
*> 검색조건에 해당하는 데이타를 Select.
  ENDLOOP.

  PERFORM display_error_message.

  it_disp[] = it_temp[].

  LOOP AT it_finno.
*> Lock Object.
    CLEAR: l_subrc.
    PERFORM  set_finbil_lock_object USING 'U'
                                          it_finno-finno
                                          'S'
                                          l_subrc.
  ENDLOOP.

  p_count = l_count.
*
ENDFORM.                    " finbil_data_delete

*&--------------------------------------------------------------------*
*&      Form  handle_data_changed
*&--------------------------------------------------------------------*
*       text
*---------------------------------------------------------------------*
*      -->ER_DATA_CHAtext
*---------------------------------------------------------------------*
FORM  handle_data_changed  USING er_data_changed
                           TYPE REF TO cl_alv_changed_data_protocol.

  DATA : ls_mod_cells TYPE lvc_s_modi,
         ls_cells     TYPE lvc_s_modi.

  DATA : l_wrbtr      TYPE wrbtr,
         l_wmwst      TYPE wmwst,
         l_fwbas      TYPE fwbas,
         l_mwskz      TYPE hwaer,
         l_box        TYPE c,
         l_hwaer      TYPE hwaer.

  LOOP AT er_data_changed->mt_good_cells INTO ls_mod_cells.
    CASE ls_mod_cells-fieldname.
      WHEN 'WRBTR'.     ">금액.
* 금액이 있는경우 Check Box Marking
        READ TABLE it_disp INTO gs_disp
                     INDEX ls_mod_cells-row_id .

        IF sy-subrc NE 0.
          CONTINUE.
        ENDIF.
*> 금액.
        CALL METHOD er_data_changed->get_cell_value
          EXPORTING
            i_row_id    = ls_mod_cells-row_id
            i_fieldname = 'WRBTR'
          IMPORTING
            e_value     = l_wrbtr.
*> Checkbox Update
        IF l_wrbtr = 0.
          CLEAR l_box.
        ELSE.
          l_box = 'X'.
        ENDIF.

        CALL METHOD er_data_changed->modify_cell
          EXPORTING
            i_row_id    = ls_mod_cells-row_id
            i_fieldname = 'BOX'
            i_value     = l_box.

    ENDCASE.
  ENDLOOP.

ENDFORM.                    "handle_data_changed
*&---------------------------------------------------------------------*
*&      Form  handle_data_changed_finished
*&---------------------------------------------------------------------*
FORM  handle_data_changed_finished   USING p_modified
                                           p_sender.

*  DATA lt_rows     TYPE lvc_t_row.
*  DATA l_row_id    TYPE lvc_s_row.
*  DATA l_col_id    TYPE lvc_s_col.
*  DATA ls_stable   TYPE lvc_s_stbl.
*  DATA l_control   TYPE REF TO cl_gui_control.
*  DATA l_row_no    TYPE lvc_s_roid.
*  DATA lt_roid     TYPE lvc_t_roid.
*  DATA l_row       TYPE i.
*  DATA l_col       TYPE i.
*  DATA l_end_pos   TYPE i.
*  DATA l_start_pos TYPE i.
*
*  EXIT.
*
*  CHECK NOT p_modified IS INITIAL.
*
** keep in mind selected rows
*  REFRESH lt_rows.
*  CALL METHOD g_grid->get_selected_rows
*    IMPORTING
*      et_index_rows = lt_rows.
*
*  IF lt_rows[] IS INITIAL.
*    CALL METHOD g_grid->get_focus
*      IMPORTING
*        control           = l_control
*      EXCEPTIONS
*        cntl_error        = 1
*        cntl_system_error = 2
*        OTHERS            = 3.
** Flush now to avoid a system_pointer_pending dump.
*    CALL METHOD cl_gui_cfw=>flush.
*    IF sy-subrc = 0 AND
*       l_control = g_grid.
*      CALL METHOD g_grid->get_current_cell
*        IMPORTING
*          es_row_no = l_row_no
*          es_row_id = l_row_id
*          es_col_id = l_col_id
*          e_row     = l_row
*          e_col     = l_col.
*
** Flush now to avoid a system_pointer_pending dump.
*      CALL METHOD cl_gui_cfw=>flush.
*    ENDIF.
*  ENDIF.
*
*  CALL METHOD g_grid->refresh_table_display
*    EXPORTING
*      is_stable = ls_stable.
*
*  IF lt_rows[] IS INITIAL.
*    CALL METHOD g_grid->set_focus
*      EXPORTING
*        control = l_control.
** Flush now to avoid a system_pointer_pending dump.
*    CALL METHOD cl_gui_cfw=>flush.
*
*    IF sy-subrc  = 0       AND
*       l_control = g_grid.
*
*      l_start_pos = 1.
*      l_end_pos   = 1.
*
*      APPEND l_row_no TO lt_roid.
*
*      CALL METHOD g_grid->set_selected_rows
*        EXPORTING
**          IT_INDEX_ROWS            =
*          it_row_no                = lt_roid
**          IS_KEEP_OTHER_SELECTIONS =
*          .
*
** Flush now to avoid a system_pointer_pending dump.
*      CALL METHOD cl_gui_cfw=>flush.
*    ENDIF.
*  ELSE.
** reset selected rows
*    CALL METHOD g_grid->set_selected_rows
*      EXPORTING
*        it_index_rows = lt_rows.
*  ENDIF.
**   flush
*  CALL METHOD cl_gui_cfw=>flush.
*
ENDFORM.                    "handle_data_changed_finished

*&---------------------------------------------------------------------*
*&      Form  handle_double_click
*&---------------------------------------------------------------------*
FORM handle_double_click  USING  p_row p_column.

  DATA: l_datatype    LIKE dd01v-datatype.

  CALL FUNCTION 'Z_TI_NUMBER_CHECK'
    EXPORTING
      string_in  = p_row
    IMPORTING
      string_out = p_row
      htype      = l_datatype.

  CHECK l_datatype EQ 'NUMC'.

  READ TABLE it_disp INTO gs_disp INDEX p_row.
  IF sy-subrc EQ 0.

    CASE p_column.
      WHEN 'ICSNO' OR 'ICSSQ'.
        PERFORM display_cs_document(ztir0000)
                                           USING gs_disp-icsno
                                                 gs_disp-bukrs.
      WHEN 'BELNR'.
        PERFORM display_liv_document(ztir9000)
                                             USING gs_disp-belnr
                                                   gs_disp-gjahr
                                                   gs_disp-bukrs.
      WHEN OTHERS.
        PERFORM display_import_document(ztir0000)
                                           USING gs_disp-refno
                                                 gs_disp-amdsq
                                                 '00000'.
    ENDCASE.
  ELSE.
    MESSAGE s903.
  ENDIF.

ENDFORM.                    "handle_double_click
*&---------------------------------------------------------------------*
*&      Form  handle_hotspot_click
*&---------------------------------------------------------------------*
FORM handle_hotspot_click  USING e_row_id    TYPE lvc_s_row
                                 e_column_id TYPE lvc_s_col.

  READ TABLE it_disp INTO gs_disp INDEX e_row_id-index.
  IF sy-subrc NE 0.
    MESSAGE s903.   EXIT.
  ENDIF.

  CASE e_column_id-fieldname.
    WHEN 'REQNO' OR 'OPNNO'.
      PERFORM  display_import_document(ztir0000)
                                      USING gs_disp-refno
                                            gs_disp-amdsq
                                            space.
*    WHEN 'PSPNR'.
*      PERFORM  display_project_master(ztir0000)
*                                      USING gs_disp-pspnr.
    WHEN OTHERS.
  ENDCASE.

ENDFORM.                    "_hotspot_click
*&---------------------------------------------------------------------*
*&      Form  handle_user_command_grid
*&---------------------------------------------------------------------*
FORM handle_user_command_grid USING r_ucomm.

  CALL METHOD cl_gui_cfw=>set_new_ok_code
    EXPORTING
      new_code = r_ucomm.

  IF r_ucomm EQ 'SELECT'.
    PERFORM  set_selected_row USING 'X'.
    EXIT.
  ELSEIF r_ucomm EQ 'DESELECT'.
    PERFORM  set_selected_row USING ' '.
    EXIT.
  ELSEIF r_ucomm EQ 'REFRESH'.
    PERFORM refresh_confirm USING g_answer.
    CHECK g_answer = 'J'.
    PERFORM p2000_data_selections.
    PERFORM p3000_field_category_build.
    PERFORM p3800_field_attribute_change.
    PERFORM p9000_refresh_display.
  ENDIF.

*  DATA: l_valid TYPE c,
*        lt_row_no TYPE lvc_t_roid WITH HEADER LINE.
*  DATA: l_subrc   LIKE sy-subrc,
*        l_text_amout(20),
*        l_mark    TYPE c.
*
*  REFRESH: bdcdata, it_msg.
*  CLEAR: session.
*  ctu_params-dismode  = 'E'. ">처리모드
*  ctu_params-updmode  = 'S'. ">갱신모드
*  ctu_params-cattmode = ' '. ">CATT 모드...
*  ctu_params-defsize  = ' '. ">기본화면 크기
*  ctu_params-racommit = 'X'.
*  ctu_params-nobinpt  = ' ' .
*  ctu_params-nobiend  = ' '.
*
*  CLEAR g_count.
*
*  IF r_ucomm EQ 'ZTIT105' OR
*     r_ucomm EQ 'ZTIT901' OR
*     r_ucomm EQ 'ZTIT901S'.
*    PERFORM  get_selected_row  TABLES lt_row_no.
*  ELSEIF r_ucomm EQ 'SELECT'.
*    l_mark = ' '.
*    PERFORM  set_selected_row USING l_mark.
*    EXIT.
*  ELSEIF r_ucomm EQ 'DESELECT'.
*    l_mark = 'X'.
*    PERFORM  set_selected_row USING l_mark.
*    EXIT.
*  ENDIF.
*
*  CHECK g_count GT 0.
*
*  CASE r_ucomm.
**>---------------------------------------------------------------------
**> Term Charge 계산.
**>---------------------------------------------------------------------
*    WHEN 'ZTIT901S'.
*      CASE g_count.
*        WHEN 0.
*          MESSAGE s906.     EXIT.
*        WHEN 1.
*          READ TABLE IT_DISP INTO GS_DISP WITH KEY box = 'X'.
*          g_tabix = sy-tabix.
*          IF sy-subrc EQ 0.
*            IF GS_DISP-cstcl EQ 'T'.
*              MOVE-CORRESPONDING GS_DISP       TO ztislccs.
*              MOVE               GS_DISP-wrbtr TO ztislccs-tmchg.
*               *ztislccs = ztislccs.
**> 확인 대화상자 Call
*              CLEAR: ok_code.
*              CALL SCREEN '0300' STARTING AT 1 1.
*              IF ok_code EQ 'BU'.
*                PERFORM p3000_field_category_build.
*                PERFORM p3800_field_attribute_change.
*                PERFORM p9000_refresh_display.
*                EXIT.
*              ENDIF.
*            ELSE.
*              MESSAGE s024. EXIT.
*            ENDIF.
*          ENDIF.
*        WHEN OTHERS.
*          MESSAGE s929.     EXIT.
*      ENDCASE.
**>---------------------------------------------------------------------
**> 비용전기.
**>---------------------------------------------------------------------
*    WHEN 'ZTIT901'.
**> 전표전기 종류 선택 함수(월합계산서 or 개별전표)
*      IF g_count EQ 1.
*        ztisscrcom-monsc = 'S'.
*      ELSE.
*        CALL FUNCTION 'Z_TI_COST_DOCUMENT_TYPE_POPUP'
*          IMPORTING
*            p_answer = g_answer
*            p_monsc  = ztisscrcom-monsc.
*
*        CHECK g_answer EQ 'Y'.
*      ENDIF.
*      CLEAR: g_count, g_wrbtr, g_wmwst.
*      REFRESH: it_vendor.
*
**> 데이타 체크.
*      LOOP AT IT_DISP INTO GS_DISP WHERE box = 'X'.
*        CLEAR: GS_DISP-errmd.
*
*        MOVE: GS_DISP-lifnr  TO  it_vendor-lifnr.
*        COLLECT it_vendor.
*
*        IF NOT GS_DISP-icsno IS INITIAL.
*          GS_DISP-errmd = 'X'.
*          IF NOT GS_DISP-belnr IS INITIAL.
*            MESSAGE s132 WITH GS_DISP-reqno GS_DISP-amdsq '전기'.
*          ELSE.
*            MESSAGE s132 WITH GS_DISP-reqno GS_DISP-amdsq '생성'.
*          ENDIF.
*          PERFORM set_return_message_fill USING 'E'.
*        ENDIF.
*
*        IF GS_DISP-lifnr IS INITIAL.
*          GS_DISP-errmd = 'X'.
*          MESSAGE s129 WITH GS_DISP-reqno GS_DISP-amdsq '은행코드'.
*          PERFORM set_return_message_fill USING 'E'.
*        ENDIF.
*
*        IF GS_DISP-hwaer  IS INITIAL AND
*           GS_DISP-errmd  IS INITIAL.
*          GS_DISP-errmd = 'X'.
*          MESSAGE s129 WITH GS_DISP-reqno GS_DISP-amdsq '통화단위'.
*          PERFORM set_return_message_fill USING 'E'.
*        ENDIF.
*
*        IF GS_DISP-wrbtr  IS INITIAL AND
*           GS_DISP-errmd  IS INITIAL.
*          GS_DISP-errmd = 'X'.
*          MESSAGE s129 WITH GS_DISP-reqno GS_DISP-amdsq '비용금액'.
*          PERFORM set_return_message_fill USING 'E'.
*        ENDIF.
**
*        ADD GS_DISP-wrbtr TO g_wrbtr.
*        ADD 0             TO g_wmwst.
*        MODIFY IT_DISP FROM GS_DISP.
*      ENDLOOP.
*
**> 합계전표일 경우 Vendor 등을 체크함.
*      IF ztisscrcom-monsc EQ 'S'.
*        DESCRIBE TABLE it_vendor LINES g_line.
*        CASE g_line.
*          WHEN 0.
*            MESSAGE s022.
*            PERFORM set_return_message_fill USING 'E'.
*          WHEN 1.
*          WHEN OTHERS.
*            MESSAGE s023.
*            PERFORM set_return_message_fill USING 'E'.
*        ENDCASE.
**> Error Message Display.
*        PERFORM display_error_message.
*        DESCRIBE TABLE it_msg LINES g_line.
*        CHECK g_line EQ 0.
*      ENDIF.
*
**> 전기확인용 대화화면 Call
*      CLEAR: ok_code.
**> 전기용 HEADER DATA Fill
*      PERFORM   fill_default_header_data.
**> 확인 대화상자 Call
*      CLEAR: ok_code.
*      CALL SCREEN '0200' STARTING AT 1 8.
*      IF ok_code EQ 'ABBR'.
*        MESSAGE s900.
*        EXIT.
*      ELSEIF ok_code EQ 'SIMU'.
*        ctu_params-dismode  = 'E'. ">처리모드
*      ENDIF.
*      CLEAR: g_success, g_error.
*
*      IF ztisscrcom-monsc EQ 'S'.
*        PERFORM execute_collective_posting.
*      ELSE.
*        PERFORM execute_individual_posting.
*      ENDIF.
*  ENDCASE.
*
**> Error Message Display.
*  PERFORM display_error_message.
**> 검색조건에 해당하는 데이타를 Select.
*  CHECK g_success GT 0.
*  PERFORM p2000_data_selections.
*  PERFORM p3000_field_category_build.
*  PERFORM p3800_field_attribute_change.
*  PERFORM p9000_refresh_display.

ENDFORM.                    "handle_user_command_grid

*&--------------------------------------------------------------------*
*&      Form  alv_data_changed
*&--------------------------------------------------------------------*
*       text
*---------------------------------------------------------------------*
FORM data_changed USING rr_data_changed
                        TYPE REF TO cl_alv_changed_data_protocol.

  DATA : ls_mod_cells TYPE lvc_s_modi,
         ls_cells     TYPE lvc_s_modi,
         l_matnr      LIKE mara-matnr.

  LOOP AT rr_data_changed->mt_good_cells INTO ls_mod_cells.

  ENDLOOP.

ENDFORM.                    "alv_data_changed
*&---------------------------------------------------------------------*
*&      Form  p1000_alv_fields_initial
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM p1000_alv_fields_initial .

  CLEAR: gs_variante, gs_def_variante.

  MOVE sy-repid TO : g_repid ,
                     gs_variante-report,
                     gs_def_variante-report.

  CALL FUNCTION 'LVC_VARIANT_DEFAULT_GET'
    EXPORTING
      i_save     = g_variant_save
    CHANGING
      cs_variant = gs_def_variante
    EXCEPTIONS
      not_found  = 2.

  IF sy-subrc = 0 .
    p_vari = gs_def_variante-variant.
  ENDIF.

ENDFORM.                    " p1000_alv_fields_initial
*&---------------------------------------------------------------------*
*&      Form  p1001_initialization
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM p1001_initialization .

  SET TITLEBAR  'T1000' WITH '검색조건'.

  CLEAR: g_answer.

ENDFORM.                    " p1001_initialization
*&---------------------------------------------------------------------*
*&      Form  p1101_check_variant_value
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM p1101_check_variant_value .

  CHECK g_answer EQ 'Y'.

  IF NOT p_vari IS INITIAL.
    MOVE gs_variante TO gs_def_variante.
    MOVE p_vari TO gs_def_variante-variant.
    CALL FUNCTION 'LVC_VARIANT_EXISTENCE_CHECK'
      EXPORTING
        i_save        = g_variant_save
      CHANGING
        cs_variant    = gs_def_variante
      EXCEPTIONS
        wrong_input   = 1
        not_found     = 2
        program_error = 3
        OTHERS        = 4.
    IF sy-subrc <> 0 AND NOT p_vari IS INITIAL.
      MESSAGE ID sy-msgid TYPE 'E' NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.

    IF p_vari IS INITIAL.
      CLEAR gs_variante-variant.
    ELSE.
      gs_variante-variant = p_vari.
    ENDIF.

  ELSE.
    CLEAR gs_variante.
    gs_variante-report = g_repid.
  ENDIF.

ENDFORM.                    " p1101_check_variant_value
*&---------------------------------------------------------------------*
*&      Form  p1102_f4_for_variant
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM p1102_f4_for_variant .

  CLEAR gs_variante.
  MOVE g_repid TO gs_variante-report.

  CALL FUNCTION 'LVC_VARIANT_F4'
    EXPORTING
      is_variant = gs_variante
      i_save     = g_variant_save
    IMPORTING
      e_exit     = g_variant_exit
      es_variant = gs_def_variante
    EXCEPTIONS
      not_found  = 1
      OTHERS     = 2.

  IF sy-subrc NE 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ELSE.
    IF g_variant_exit = space.
      p_vari = gs_def_variante-variant.
    ENDIF.
  ENDIF.

ENDFORM.                    " p1102_f4_for_variant
*&---------------------------------------------------------------------*
*&      Form  p1101_check_input_value
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM p1101_check_input_value .

  DATA: l_xauto TYPE c.

  CLEAR: g_process.

  READ TABLE s_bukrs INDEX 1.

  SELECT SINGLE *
    FROM t001
   WHERE bukrs IN s_bukrs.
  IF sy-subrc NE 0.
    MESSAGE e011 WITH s_bukrs-low.
  ENDIF.

  SELECT SINGLE *
    FROM ztitig00
   WHERE bukrs EQ t001-bukrs.
  IF sy-subrc NE 0.
    MESSAGE e035 WITH t001-bukrs.
  ENDIF.

  SELECT SINGLE *
    FROM ztitig07
   WHERE bukrs EQ t001-bukrs
     AND cstct EQ 'B'.

  SELECT SINGLE *
    FROM t005
   WHERE land1 EQ t001-land1.

*  IF sy-tcode EQ c_tcode.
*    l_xauto = space.
*  ELSE.
  l_xauto = 'X'.
*  ENDIF.

  IF g_answer IS INITIAL.
    CALL FUNCTION 'Z_TI_EXPENCES_CODE_BY_GROUP'
      EXPORTING
        xbukrs    = t001-bukrs
        xexpgr    = 'L'
        xauto     = l_xauto
      IMPORTING
        p_answer  = g_answer
      TABLES
        xztitig06 = it_ztitig06
      EXCEPTIONS
        not_found = 1
        OTHERS    = 2.

    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.
  ENDIF.

  CHECK g_answer EQ 'Y'.

ENDFORM.                    " p1101_check_input_value
*&---------------------------------------------------------------------*
*&      Form  p2000_data_selections
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM p2000_data_selections .


  REFRESH: it_disp.

*> PROGRESS Display.
  g_linen    = 30.
  g_out_text = '데이타를 검색 중입니다 %99999%%'(p01).
  REPLACE '%99999%' WITH g_linen INTO g_out_text.
  PERFORM show_progress_bar(ztir0000) USING g_out_text g_linen.


*> 계산서 데이타 select.
  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE it_ztstfbk
    FROM ztstfbk
   WHERE finno IN s_finno
     AND bukrs IN s_bukrs
     AND epart IN s_epart
*     AND NOT bilgb IN ('2BA', '2BB', 'ZZZ')
     AND imexi EQ 'I'
     AND tradt IN s_tradt
     AND recdt IN s_recdt
     AND refno IN s_refno
     AND cnam  IN s_cnam
     AND cdat  IN s_cdat
     AND ctme  IN s_ctme.

  IF sy-subrc NE 0.
    MESSAGE s902.
  ENDIF.

*> 거래상대방 테이블.
  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE it_ztstig3
    FROM ztstig3
     FOR ALL ENTRIES IN it_ztstfbk
   WHERE parti  EQ  'B'
     AND BUKRS  EQ  s_bukrs-low
     AND epart  EQ  it_ztstfbk-epart.

  LOOP AT it_ztstfbk.
    g_tabix = sy-tabix.
    MOVE-CORRESPONDING  it_ztstfbk TO gs_disp.

    SELECT *
       INTO CORRESPONDING FIELDS OF TABLE it_ztstfbc
       FROM ztstfbc
      WHERE finno EQ it_ztstfbk-finno.

    CHECK sy-subrc EQ 0.

    CLEAR: ztitrqs, ztitrqk.
    IF gs_disp-refno IS INITIAL.
      IF it_ztstfbk-rfeno = 'NONREF'.
        SELECT *
          FROM ztitrqs UP TO 1 ROWS
         WHERE opnno EQ it_ztstfbk-rffno
         ORDER BY reqno DESCENDING amdsq DESCENDING.
        ENDSELECT.
      ELSE.
        SELECT SINGLE *
          FROM ztitrqs
         WHERE reqno EQ ( SELECT MAX( reqno )
                            FROM ztitrqs
                           WHERE recno EQ it_ztstfbk-rfeno )
           AND recno EQ it_ztstfbk-rfeno.
      ENDIF.
    ELSE.
      SELECT SINGLE *
        FROM ztitrqs
       WHERE reqno EQ gs_disp-refno
         AND amdsq EQ gs_disp-amdsq.
    ENDIF.

    IF sy-subrc EQ 0.
      SELECT SINGLE *
        FROM ztitrqk
       WHERE reqno EQ ztitrqs-reqno.

      MOVE: ztitrqk-reqty TO gs_disp-reqty,
            ztitrqs-ebeln TO gs_disp-ebeln,
            ztitrqs-opnno TO gs_disp-docnm,
            ztitrqs-bupla TO gs_disp-bupla,
            ztitrqs-reqno TO gs_disp-refno,
            ztitrqs-amdsq TO gs_disp-paysq,
            gs_disp-amdsq TO gs_disp-amdsq.
    ELSE.
      CLEAR: gs_disp-reqty, gs_disp-ebeln, gs_disp-amdsq,
             gs_disp-docnm, gs_disp-bupla,
             gs_disp-paysq, gs_disp-refno,
             gs_disp-zfbdt.
      IF p_nmatch EQ space.
        CONTINUE.
      ENDIF.
    ENDIF.

*> 통화단위.
    MOVE : t001-waers       TO gs_disp-hwaer,
           it_ztstfbk-tradt TO gs_disp-zfbdt.

    LOOP AT it_ztstfbc.
      IF p_step1 = 'X'.        " 미 전기내역 선택시
        IF it_ztstfbc-sysyn = ' ' OR
           it_ztstfbc-sysyn = 'N'.
        ELSE.
          DELETE it_ztstfbc.
          CONTINUE.
        ENDIF.
      ENDIF.

      IF p_step2 = 'X'.         " 기 전기내역 선택시
        IF it_ztstfbc-sysyn <> 'Y'.
          DELETE it_ztstfbc.
          CONTINUE.
        ENDIF.
      ENDIF.

*> 거래상대방 .
      READ TABLE it_ztstig3 WITH KEY epart  = gs_disp-epart.
      IF sy-subrc EQ 0.
        MOVE: it_ztstig3-lifnr  TO  gs_disp-lifnr,
              it_ztstig3-namet  TO  gs_disp-name1.
      ENDIF.

*> 문서 종류.
      CASE gs_disp-reqty.
        WHEN 'LC'.
          gs_disp-reqtx = '수입신용장'.
        WHEN 'TT'.
          gs_disp-reqtx = '전신환송금'.
        WHEN 'LO'.
          gs_disp-reqtx = '내국신용장'.
        WHEN 'PU'.
          gs_disp-reqtx = '구매확인서'.
        WHEN 'DA'.
          gs_disp-reqtx = 'D/A'.
        WHEN 'DP'.
          gs_disp-reqtx = 'D/P'.
      ENDCASE.

      MOVE: it_ztstfbc-alcty         TO gs_disp-expcd,
            it_ztstfbc-fbseq         TO gs_disp-fbseq,
            it_ztstfbc-pcdra         TO gs_disp-pcdra,
            it_ztstfbc-moacg         TO gs_disp-moacg,
            it_ztstfbc-waers         TO gs_disp-ccuky,
            it_ztstfbc-moaca         TO gs_disp-moaca,
            it_ztstfbc-moaca         TO gs_disp-wrbtr,
            it_ztstfbc-moaca         TO gs_disp-dmbtr,
            0                        TO gs_disp-wmwst,
            0                        TO gs_disp-fwbas,
            it_ztstfbc-hwaer         TO gs_disp-hwaer,
            it_ztstfbc-hwaer         TO gs_disp-waers,
            it_ztstfbc-kursf         TO gs_disp-kursf,
            it_ztstfbc-apday         TO gs_disp-apday,
            it_ztstfbc-apfrd         TO gs_disp-apfrd,
            it_ztstfbc-apend         TO gs_disp-apend,
            it_ztstfbc-sysyn         TO gs_disp-sysyn,
            it_ztstfbc-bukrs         TO gs_disp-bukrs,
            it_ztstfbc-gjahr         TO gs_disp-gjahr,
            it_ztstfbc-icsno         TO gs_disp-icsno,
            it_ztstfbc-belnr         TO gs_disp-belnr.

      PERFORM  get_domain_value_text(ztir0000) USING 'ZTSALCTY'
                                                     gs_disp-expcd
                                                     gs_disp-exptx.

      READ TABLE it_ztitig06 WITH KEY expcd = gs_disp-expcd.
      IF sy-subrc EQ 0.
        MOVE: it_ztitig06-expcd  TO  gs_disp-expcd,
              it_ztitig06-exptx  TO  gs_disp-exptx,
              it_ztitig06-blart  TO  gs_disp-blart,
              '1'                TO  gs_disp-vorgang,
              'P'                TO  gs_disp-cstyp,
*              t001-waers         TO  gs_disp-waers,
              it_ztitig06-mwskz  TO  gs_disp-mwskz,
              it_ztitig06-kschl  TO  gs_disp-kschl,
              it_ztitig06-cscty  TO  gs_disp-cscty,
              it_ztitig06-cstcl  TO  gs_disp-cstcl.
      ENDIF.

      MOVE t001-waers  TO  gs_disp-hwaer.
      MOVE t005-kalsm  TO  gs_disp-kalsm.

      IF gs_disp-waers IS INITIAL.
        MOVE t001-waers  TO  gs_disp-waers.
      ENDIF.

      IF gs_disp-sysyn EQ 'Y'.
        gs_disp-icon = icon_green_light.
      ELSE.
        gs_disp-icon = icon_red_light.
      ENDIF.
      CLEAR gs_disp-box.
      APPEND  gs_disp TO it_disp.
    ENDLOOP.
  ENDLOOP.

  DESCRIBE TABLE it_disp LINES g_line.
  IF g_line EQ 0.
    MESSAGE s902.
  ENDIF.

ENDFORM.                    " p2000_data_selections
*&---------------------------------------------------------------------*
*&      Form  p3000_field_category_build
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM p3000_field_category_build .

  DATA ls_fcat TYPE lvc_s_fcat.

  CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
    EXPORTING
      i_structure_name       = 'ZTSSFB00'
      i_internal_tabname     = 'IT_DISP'
*      i_client_never_display = 'X'
    CHANGING
      ct_fieldcat            = it_fieldcat_g[].

  LOOP AT it_fieldcat_g INTO gs_fieldcat_g.
    CLEAR: gs_fieldcat_g-key.
    CASE gs_fieldcat_g-fieldname.
      WHEN 'BOX'.
        gs_fieldcat_g-coltext   = '선택'.
        gs_fieldcat_g-col_opt   = 'X'.
        gs_fieldcat_g-checkbox  = 'X'.
        gs_fieldcat_g-col_pos   = 1.
        gs_fieldcat_g-key       = 'X'.
      WHEN 'ICON'.
        gs_fieldcat_g-key       = 'X'.
        gs_fieldcat_g-coltext   = '상태'.
        gs_fieldcat_g-col_pos   = 2.
      WHEN 'FINNO'.
        gs_fieldcat_g-key       = 'X'.
        gs_fieldcat_g-col_opt   = 'X'.
        gs_fieldcat_g-col_pos   = 3.
      WHEN 'FBSEQ'.
        gs_fieldcat_g-key       = 'X'.
        gs_fieldcat_g-col_opt   = 'X'.
        gs_fieldcat_g-col_pos   = 3.
      WHEN 'REFNO'.
        gs_fieldcat_g-key       = 'X'.
        gs_fieldcat_g-col_opt   = 'X'.
        gs_fieldcat_g-col_pos   = 3.
      WHEN 'PAYSQ'.
        gs_fieldcat_g-key       = 'X'.
        gs_fieldcat_g-col_opt   = 'X'.
        gs_fieldcat_g-col_pos   = 4.
      WHEN 'RFFNO'.
        gs_fieldcat_g-key       = 'X'.
        gs_fieldcat_g-col_opt   = 'X'.
        gs_fieldcat_g-col_pos   = 5.
      WHEN 'EXPCD'.
        gs_fieldcat_g-col_pos   = 6.
        gs_fieldcat_g-col_opt   = 'X'.
      WHEN 'EXPTX'.
        gs_fieldcat_g-col_pos   = 7.
        gs_fieldcat_g-col_opt   = 'X'.
      WHEN 'EBELN'.
        gs_fieldcat_g-col_pos   = 8.
        gs_fieldcat_g-col_opt   = 'X'.
      WHEN 'NAME1'.
        gs_fieldcat_g-col_pos   = 9.
        gs_fieldcat_g-coltext   = '공급업체명'.
        gs_fieldcat_g-col_opt    = 'X'.
      WHEN 'HWAER'.
        gs_fieldcat_g-col_pos   = 10.
*        gs_fieldcat_g-outputlen = 10.
        gs_fieldcat_g-col_opt    = 'X'.
      WHEN 'WRBTR'.
        gs_fieldcat_g-coltext   = '공급가액'.
        gs_fieldcat_g-do_sum     = 'X'.
        gs_fieldcat_g-edit       = 'X'.
        gs_fieldcat_g-col_pos   = 11.
        gs_fieldcat_g-col_opt    = 'X'.
      WHEN 'PCDRA'.
        gs_fieldcat_g-col_pos   = 12.
        gs_fieldcat_g-col_opt    = 'X'.
      WHEN 'CCUKY'.
        gs_fieldcat_g-col_pos   = 13.
        gs_fieldcat_g-col_opt    = 'X'.
      WHEN 'MOACG'.
        gs_fieldcat_g-cfieldname = 'CCUKY'.
        gs_fieldcat_g-col_opt    = 'X'.
        gs_fieldcat_g-col_pos   = 14.
      WHEN 'MOACA'.
        gs_fieldcat_g-col_pos   = 15.
        gs_fieldcat_g-col_opt    = 'X'.
      WHEN 'KURSF'.
        gs_fieldcat_g-col_pos   = 16.
        gs_fieldcat_g-col_opt    = 'X'.
      WHEN 'APFRD'.
        gs_fieldcat_g-col_pos   = 17.
        gs_fieldcat_g-col_opt    = 'X'.
      WHEN 'APEND'.
        gs_fieldcat_g-col_pos   = 18.
        gs_fieldcat_g-col_opt    = 'X'.
      WHEN 'APDAY'.
        gs_fieldcat_g-col_pos   = 19.
        gs_fieldcat_g-col_opt    = 'X'.
      WHEN 'BUPLA'.
        gs_fieldcat_g-col_pos   = 20.
        gs_fieldcat_g-outputlen  = 8.
*        gs_fieldcat_g-no_out    = 'X'.
      WHEN 'MWSKZ'.
*        gs_fieldcat_g-checktable = '!'.
        gs_fieldcat_g-col_pos   = 21.
        gs_fieldcat_g-edit       = 'X'.
        gs_fieldcat_g-col_opt    = 'X'.
        gs_fieldcat_g-f4availabl = 'X'.
      WHEN 'BLART'.
        gs_fieldcat_g-col_pos    = 22.
*      WHEN 'LIFNR'.
*        gs_fieldcat_g-checktable = '!'.
*        gs_fieldcat_g-edit       = 'X'.
*        gs_fieldcat_g-f4availabl = 'X'.
      WHEN 'ICSNO'  OR 'BELNR'.
        gs_fieldcat_g-col_opt   = 'X'.
      WHEN OTHERS.
        gs_fieldcat_g-no_out = 'X'.
    ENDCASE.
    MODIFY it_fieldcat_g FROM gs_fieldcat_g.
  ENDLOOP.

ENDFORM.                    " p3000_field_category_build
*&--------------------------------------------------------------------*
*&      Form  p3210_exclude_table_build
*&--------------------------------------------------------------------*
*       text
*---------------------------------------------------------------------*
*      -->P_TABNAME  text
*---------------------------------------------------------------------*
FORM p3210_exclude_table_build USING p_tabname.

*  툴바의 버튼중 나타내지 않을 버튼을 지정한다.
  FIELD-SYMBOLS : <table> TYPE ui_functions.

  DATA : ls_exclude   TYPE ui_func.
  DATA : l_table_name LIKE feld-name.

  CONCATENATE p_tabname '[]' INTO  l_table_name.
  ASSIGN     (l_table_name)    TO <table>.

  PERFORM append_exclude_functions
        TABLES <table>
*        USING : cl_gui_alv_grid=>mc_fc_excl_all. " ** 툴바 모두제거 **
         USING : cl_gui_alv_grid=>mc_fc_loc_undo, " 실행취소 &LOCAL&UNDO
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
                cl_gui_alv_grid=>mc_fc_loc_copy,          " 행 카피.
*                cl_gui_alv_grid=>mc_fc_html,
                cl_gui_alv_grid=>mc_fc_loc_copy_row,      " 행 카피.
                cl_gui_alv_grid=>mc_fc_loc_cut,           " 가위.
                cl_gui_alv_grid=>mc_fc_loc_delete_row,    " 행삭제.
                cl_gui_alv_grid=>mc_fc_loc_insert_row,    " 행삽입.
                cl_gui_alv_grid=>mc_fc_loc_move_row,
                cl_gui_alv_grid=>mc_fc_loc_append_row,    " 라인생성.
                cl_gui_alv_grid=>mc_fc_loc_paste,         " 겹쳐쓰기.
                cl_gui_alv_grid=>mc_fc_loc_paste_new_row. " 겹쳐쓰기.
*                cl_gui_alv_grid=>mc_fc_refresh.           " Rrefresh

*                cl_gui_alv_grid=>mc_fc_maintain_variant,
*                cl_gui_alv_grid=>mc_fc_maximum,
*                cl_gui_alv_grid=>mc_fc_minimum,
*                cl_gui_alv_grid=>mc_fc_pc_file,
*                cl_gui_alv_grid=>mc_fc_print,
*                cl_gui_alv_grid=>mc_fc_print_back,
*                cl_gui_alv_grid=>mc_fc_print_prev,
*                cl_gui_alv_grid=>mc_fc_reprep,
*                cl_gui_alv_grid=>mc_fc_save_variant,
*                cl_gui_alv_grid=>mc_fc_select_all,
*                cl_gui_alv_grid=>mc_fc_send,
*                cl_gui_alv_grid=>mc_fc_separator,
*                cl_gui_alv_grid=>mc_fc_sort,
*                cl_gui_alv_grid=>mc_fc_sort_asc,
*                cl_gui_alv_grid=>mc_fc_sort_dsc,
*                cl_gui_alv_grid=>mc_fc_subtot,
*                cl_gui_alv_grid=>mc_fc_sum,
*                cl_gui_alv_grid=>mc_fc_to_office,
*                cl_gui_alv_grid=>mc_fc_to_rep_tree,
*                cl_gui_alv_grid=>mc_fc_unfix_columns,
*                cl_gui_alv_grid=>mc_fc_views,
*                cl_gui_alv_grid=>mc_fc_view_crystal,
*                cl_gui_alv_grid=>mc_fc_view_excel,
*                cl_gui_alv_grid=>mc_fc_view_grid,
*                cl_gui_alv_grid=>mc_fc_word_processor.

ENDFORM.                    " P3210_exclude_table_build
*&---------------------------------------------------------------------*
*&      Form  p3500_sort_table_build
*&---------------------------------------------------------------------*
FORM p3500_sort_table_build .

  CLEAR gs_sort_g.
  gs_sort_g-spos      = '00'.
  gs_sort_g-fieldname = 'BOX'.
  gs_sort_g-down      = 'X'.
  gs_sort_g-subtot    = 'X'.
*  gs_sort_g-LEVEL     =  1.
*  gs_sort_g-GROUP     = 'X'.
  APPEND gs_sort_g TO it_sort_g.

ENDFORM.                    " p3500_sort_table_build
*&---------------------------------------------------------------------*
*&      Form  p3700_layout_build
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM p3700_layout_build .

** General display options
*  gs_layout_g-cwidth_opt = 'X'.
  gs_layout_g-smalltitle = 'X'.
*  gs_layout_g-box_fname  = 'BOX'.
* ICON.
*      gs_layout_g-excp_fname = g_lights_name.

** Grid customizing
* Title between grid control and toolbar(70자 이내)
* GS_LAYOUT_G-grid_title = '프로그램 LIST'.

** Column headers are hidden
* GS_LAYOUT_G-no_headers = 'X'.

** Columns are displayed without horizontal grid lines
* GS_LAYOUT_G-no_hgridln = 'X'.
*
** Cells are not merged when a column is sorted
* GS_LAYOUT_G-no_merging = ' '.

* the button at the beginning of a row is hidden in selection modes
* cell selection ( SEL_MODE = 'D' ) and column/row selection
* ( SEL_MODE = 'A' ).
  gs_layout_g-no_rowmark = 'A'. "(or 'X')

* Selection modes for SEL_MODE
* 'A' : Column and row selection
* 'B' : Simple selection, list box
* 'C' : Multiple selection, list box
* 'D' : Cell selection
*  gs_layout_g-sel_mode = 'C'.
* If this field is set, the toolbar is hidden.
* GS_LAYOUT_G-no_toolbar = 'X'.

* columns are displayed without vertical grid lines
* GS_LAYOUT_G-no_vgridln = 'X'.

* In case of PRINT_END_OF_PAGE, you must set 'reservelns' to
* the number of reserved lines at the end of a page.
* reserve two lines for the PRINT_END_OF_PAGE event
* p_print-reservelns = 2.

* Standard(BCALV_EDIT_01)에서는 다음과 같이 했다.
* Set status of all cells to editable using the layout structure.
* 옵션에 안보이던데... 어째껀 수정모드로 바꾸는 중요한 옵션이다.
*  IF g_mode = c_display.
*    GS_LAYOUT_G-edit = ' '.
*  ELSEIF g_mode = c_edit.
*    GS_LAYOUT_G-edit = 'X'.
*  ENDIF.

* Provide the fieldname of the celltab field by using field
* STYLEFNAME of the layout structure.

  gs_layout_g-stylefname = 'CELLTAB'.

* 합을 제일 윗라인에 DISPLAY
*  gs_layout_g-totals_bef = 'X'.

ENDFORM.                    " p3700_layout_build
*&---------------------------------------------------------------------*
*&      Form  p3800_field_attribute_change
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM p3800_field_attribute_change .

* 각 셀의 특성 제어
  DATA : lt_celltab TYPE lvc_t_styl,
         l_index    TYPE i,
         p_mode(01).

  LOOP AT it_disp INTO gs_disp.
    l_index = sy-tabix.
*> 전표가 입력되었을 경우 입력 불가능
    IF gs_disp-icsno IS INITIAL.
      p_mode = 'W'.
    ELSE.
      p_mode = 'O'.
    ENDIF.

    REFRESH lt_celltab.

    PERFORM p3810_fill_celltab USING    p_mode
                               CHANGING lt_celltab.

    CLEAR gs_disp-celltab.
    INSERT LINES OF lt_celltab  INTO TABLE gs_disp-celltab.
    MODIFY it_disp FROM gs_disp INDEX l_index.
  ENDLOOP.

ENDFORM.                    " p3800_field_attribute_change
*&---------------------------------------------------------------------*
*&      Form  p3810_fill_celltab
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM p3810_fill_celltab  USING    p_mode
                        CHANGING pt_celltab TYPE lvc_t_styl.

  DATA : ls_celltab TYPE lvc_s_styl,
         l_mode     TYPE raw4.

  DATA : BEGIN OF l_fieldcat,
           row_pos(04),
           col_pos(04),
           fieldname(30),
         END OF l_fieldcat.

  LOOP AT it_fieldcat_g INTO gs_fieldcat_g.
    ls_celltab-fieldname = gs_fieldcat_g-fieldname.

*    IF gs_fieldcat_g-fieldname = 'WRBTR' OR
*       gs_fieldcat_g-fieldname = 'HWAER' OR
*       gs_fieldcat_g-fieldname = 'MWSKZ' OR
*       gs_fieldcat_g-fieldname = 'WMWST' OR
*       gs_fieldcat_g-fieldname = 'FWBAS' OR
*       gs_fieldcat_g-fieldname = 'BOX'   OR
*       gs_fieldcat_g-fieldname = 'LIFNR' OR
*       gs_fieldcat_g-fieldname = 'WAERS'.

    IF gs_fieldcat_g-fieldname = 'BOX'.
      IF gs_disp-icsno IS INITIAL.
        ls_celltab-style = cl_gui_alv_grid=>mc_style_enabled.
        INSERT ls_celltab INTO TABLE pt_celltab.
      ELSE.
        ls_celltab-style = cl_gui_alv_grid=>mc_style_disabled.
        INSERT ls_celltab INTO TABLE pt_celltab.
      ENDIF.
    ELSE.
      ls_celltab-style = cl_gui_alv_grid=>mc_style_disabled.
      INSERT ls_celltab INTO TABLE pt_celltab.
    ENDIF.
  ENDLOOP.

ENDFORM.                    " p3810_fill_celltab
*&---------------------------------------------------------------------*
*&      Form  append_exclude_functions
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM append_exclude_functions  TABLES p_table
                               USING  p_value.

  DATA : ls_exclude TYPE ui_func.
  ls_exclude = p_value.
  APPEND ls_exclude TO p_table.

ENDFORM.                    " append_exclude_functions
*&---------------------------------------------------------------------*
*&      Module  pbo_scr0100  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE pbo_scr0100 OUTPUT.

  SET PF-STATUS 'STATUS100'.
  CASE 'X'.
    WHEN p_step1.
      SET TITLEBAR  'T1000' WITH '반영대상 현황'.
    WHEN p_step2.
      SET TITLEBAR  'T1000' WITH '기반영대상 현황'.
    WHEN p_step3.
      SET TITLEBAR  'T1000' WITH '전체현황'.
  ENDCASE.

  PERFORM create_and_init_controls_0100.

ENDMODULE.                 " pbo_scr0100  OUTPUT
*&---------------------------------------------------------------------*
*&      Form  create_and_init_controls_0100
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM create_and_init_controls_0100 .

*  IF g_custom_container IS INITIAL.

**   create a custom container control for our alv control
*    CREATE OBJECT g_custom_container
*        EXPORTING
*            container_name = 'CUSTOMER_CONTAINER_0100'.
*
*    CREATE OBJECT g_splitter
*                  EXPORTING parent = g_custom_container
*                            rows    = 1
*                            columns = 1.
*
*    CALL METHOD g_splitter->get_container
*                      EXPORTING row      = 1
*                                column   = 1
*                      RECEIVING container = g_custom_container_1.

  IF g_grid IS INITIAL.
* create the docking container
    CREATE OBJECT g_docking
                  EXPORTING repid     = sy-repid
                            dynnr     = sy-dynnr
                            side      = g_docking->dock_at_left
                            extension = 9999.

*   Create an Instance of ALV Control
    CREATE OBJECT g_grid
          EXPORTING i_parent      = g_docking.

    CALL METHOD g_grid->set_table_for_first_display
      EXPORTING
        is_layout            = gs_layout_g
        is_variant           = gs_variante
        it_toolbar_excluding = it_exclude
        is_print             = gs_print_g
        i_save               = 'A'   " 전체가능유형.
*                                       'U'   " 특정사용자전용.
*                                       'X'   " 광역 전용.
*                                       ' '   " 저장안함.
*                 i_default            = 'X'   " 레이아웃 사전셋팅 허용.
*  LAYOUT   Standard   BCALV_GRID_09  참조.
*  is_variant 레이아웃선택/변경/저장/관리 enable
      CHANGING
        it_sort             = it_sort_g
        it_filter           = it_filter_g
        it_fieldcatalog     = it_fieldcat_g[]
        it_outtab           = it_disp.

    CALL METHOD cl_gui_control=>set_focus
      EXPORTING
        control = g_grid.

* set editable cells to ready for input
    CALL METHOD g_grid->set_ready_for_input
      EXPORTING
        i_ready_for_input = 1.

*?.Optionally register ENTER to raise event DATA_CHANGED.
*   (Per default the user may check data by using the check icon).
    CALL METHOD g_grid->register_edit_event
      EXPORTING
        i_event_id = cl_gui_alv_grid=>mc_evt_enter.

    CREATE OBJECT event_receiver.

    SET HANDLER :
          event_receiver->handle_toolbar               FOR g_grid,
          event_receiver->handle_double_click          FOR g_grid,
          event_receiver->handle_hotspot_click         FOR g_grid,
          event_receiver->handle_user_command          FOR g_grid,
          event_receiver->handle_data_changed_finished FOR g_grid,
          event_receiver->handle_data_changed          FOR g_grid.

*    PERFORM p3201_f4_field_build.

*>.Call method 'set_toolbar_interactive' to raise event TOOLBAR.
    CALL METHOD g_grid->set_toolbar_interactive.

** JS전선 회사코드 2007/04 KSH --------------------------------------
*// TITLE 지정
    PERFORM p3800_set_title_text.
** JS전선 회사코드 2007/04 KSH --------------------------------------
  ENDIF.

ENDFORM.                    " create_and_init_controls_0100
*&---------------------------------------------------------------------*
*&      Module  pai_scr0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE pai_scr0100 INPUT.

  CASE sy-ucomm.
    WHEN 'EXIT' OR 'CANC' OR 'BACK'.
      IF g_grid IS INITIAL.
        CALL METHOD g_grid->free.
      ENDIF.

      SET SCREEN 0.
      LEAVE SCREEN.
*>----------------------------------------------------------------------
*> EDI DATA DELETE
*>----------------------------------------------------------------------
    WHEN 'ZTIDELETE'.           ">EDI DATA Delete.
      PERFORM  get_selected_row  TABLES gt_row_no.
      CHECK g_count GT 0.

      PERFORM finbil_data_delete  USING g_count.
      CHECK g_answer EQ 'J'.
      IF g_count GT 0.
*> 검색조건에 해당하는 데이타를 Select.
        PERFORM p2000_data_selections.
        PERFORM p3000_field_category_build.
        PERFORM p3800_field_attribute_change.
        PERFORM p9000_refresh_display.
        MESSAGE s716 WITH g_count.
      ENDIF.

*>---------------------------------------------------------------------
*> 비용전기.
*>---------------------------------------------------------------------
    WHEN 'ZTIT901'.
      PERFORM  get_selected_row  TABLES gt_row_no.

      CHECK g_count GT 0.
*> Clearing
      PERFORM  set_posting_data_initial.

*> 전기유형 선택.
      PERFORM  get_posting_type   USING g_count
                                        ztisscrcom-monsc  g_answer.
      CHECK g_answer EQ 'Y'.

*> 전기용 데이타 Collect.
      PERFORM build_posting_data.
*> Error Message Display.
      PERFORM display_error_message.
      IF g_line GT 0.
        LOOP AT it_finno.
          CLEAR: g_subrc.
          PERFORM  set_finbil_lock_object USING 'U'
                                                it_finno-finno
                                                'S'
                                                g_subrc.
        ENDLOOP.
      ENDIF.
      CHECK g_line EQ 0.

*> 전기확인용 대화화면 Call
      CLEAR: ok_code.
*> 전기용 HEADER DATA Fill
      PERFORM   fill_posting_data.

*> 비용전기용 공통 함수.
      PERFORM   build_fi_document USING 'L'
                                        ztisscrcom-monsc.

      LOOP AT it_finno.
        CLEAR: g_subrc.
        PERFORM  set_finbil_lock_object USING 'U'
                                              it_finno-finno
                                              'S'
                                              g_subrc.
      ENDLOOP.

      CHECK g_success GT 0.
*> 검색조건에 해당하는 데이타를 Select.
      PERFORM p2000_data_selections.
      PERFORM p3000_field_category_build.
      PERFORM p3800_field_attribute_change.
      PERFORM p9000_refresh_display.
  ENDCASE.

ENDMODULE.                 " pai_scr0100  INPUT
*&---------------------------------------------------------------------*
*&      Form  p9000_refresh_display
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM p9000_refresh_display .

  CALL METHOD g_grid->refresh_table_display.

ENDFORM.                    " p9000_refresh_display
*&--------------------------------------------------------------------*
*&      Form  refresh_confirm
*&--------------------------------------------------------------------*
*       text
*---------------------------------------------------------------------*
*      -->P_ANS      text
*---------------------------------------------------------------------*
FORM refresh_confirm USING p_ans.
  DATA: l_cancel_display.

  DATA: BEGIN OF pop,
        titel      LIKE spop-titel,
        diagnose1  LIKE spop-diagnose1,
        diagnose2  LIKE spop-diagnose2,
        diagnose3  LIKE spop-diagnose3,
        textline1  LIKE spop-textline1,
        textline2  LIKE spop-textline2,
        textline3  LIKE spop-textline3,
        option1    LIKE spop-varoption1,
        option2    LIKE spop-varoption2,
        default,             "defaultoption fuer Confirm_step
        answer,
  END OF pop.

  CLEAR : pop, l_cancel_display.

  MOVE: '입력된 데이타가 손실됩니다.'     TO pop-diagnose1,
        '진행하시겠습니까?'               TO pop-textline1,
        '확인'                            TO pop-titel.

  CALL FUNCTION 'POPUP_TO_CONFIRM_WITH_MESSAGE'
         EXPORTING
              diagnosetext1 = pop-diagnose1
*             diagnosetext2 = pop-diagnose2
*             DIAGNOSETEXT3 = ' '
              textline1      = pop-textline1
              textline2      = pop-textline2
              titel          = pop-titel
*             START_COLUMN   = 25
*             START_ROW      = 6
              cancel_display = l_cancel_display
         IMPORTING
              answer        = pop-answer
         EXCEPTIONS
              OTHERS        = 1.

  p_ans = pop-answer.

ENDFORM.                    " refresh_confirm
*&---------------------------------------------------------------------*
*&      Form  build_posting_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM build_posting_data .

  DATA: l_subrc LIKE sy-subrc.

  REFRESH: it_finno.

*> 데이타 체크.
  LOOP AT it_disp INTO gs_disp WHERE box = 'X'.

    g_tabix  =  sy-tabix.

    CLEAR: gs_disp-errmd.

*> 전기여부체크.
    IF NOT gs_disp-icsno IS INITIAL.
      gs_disp-errmd = 'X'.
      IF NOT gs_disp-belnr IS INITIAL.
        MESSAGE s132 WITH gs_disp-refno gs_disp-paysq '전기'.
      ELSE.
        MESSAGE s132 WITH gs_disp-refno gs_disp-paysq '생성'.
      ENDIF.
      PERFORM set_return_message_fill USING 'E'.
    ENDIF.

*> 전표유형.
    IF gs_disp-blart IS INITIAL.
      gs_disp-errmd = 'X'.
      MESSAGE s129 WITH gs_disp-refno gs_disp-paysq '전표유형'.
      PERFORM set_return_message_fill USING 'E'.
    ENDIF.

*> 공급업체.
    IF gs_disp-lifnr IS INITIAL.
      gs_disp-errmd = 'X'.
      MESSAGE s129 WITH gs_disp-refno gs_disp-paysq '공급업체'.
      PERFORM set_return_message_fill USING 'E'.
    ENDIF.

*> 사업장.
    IF gs_disp-bupla IS INITIAL.
      gs_disp-errmd = 'X'.
      MESSAGE s129 WITH gs_disp-refno gs_disp-paysq '사업장'.
      PERFORM set_return_message_fill USING 'E'.
    ENDIF.

*> 트랜잭션유형.
    IF gs_disp-mwskz IS INITIAL.
      gs_disp-errmd = 'X'.
      MESSAGE s129 WITH gs_disp-refno gs_disp-paysq '세금코드'.
      PERFORM set_return_message_fill USING 'E'.
    ENDIF.

*> 전기유형.
    IF gs_disp-cstyp IS INITIAL.
      gs_disp-errmd = 'X'.
      MESSAGE s129 WITH gs_disp-refno gs_disp-paysq '전기 유형'.
      PERFORM set_return_message_fill USING 'E'.
    ENDIF.

*> 트랜잭션유형.
    IF gs_disp-vorgang IS INITIAL.
      gs_disp-errmd = 'X'.
      MESSAGE s129 WITH gs_disp-refno gs_disp-paysq '트랜잭션유형'.
      PERFORM set_return_message_fill USING 'E'.
    ENDIF.

*> 금액.
    IF gs_disp-wrbtr IS INITIAL AND
       gs_disp-wmwst IS INITIAL.
      gs_disp-errmd = 'X'.
      MESSAGE s129 WITH gs_disp-refno gs_disp-paysq  '비용'.
      PERFORM set_return_message_fill USING 'E'.
    ENDIF.

*> 과세표준액.
    IF NOT gs_disp-wmwst IS INITIAL AND
           gs_disp-fwbas IS INITIAL.
      gs_disp-errmd = 'X'.
      MESSAGE s129 WITH gs_disp-refno gs_disp-paysq '과세표준액'.
      PERFORM set_return_message_fill USING 'E'.
    ENDIF.

*> 통화금액.
    IF gs_disp-waers IS INITIAL.
      gs_disp-errmd = 'X'.
      MESSAGE s129 WITH gs_disp-refno gs_disp-paysq '통화'.
      PERFORM set_return_message_fill USING 'E'.
    ENDIF.

    READ TABLE it_finno WITH KEY finno = gs_disp-finno.
    IF sy-subrc EQ 0.

    ELSE.
*> Lock Object.
      CLEAR: l_subrc.
      PERFORM  set_finbil_lock_object USING 'L'
                                            gs_disp-finno
                                            'S'
                                            l_subrc.
      IF l_subrc EQ 0.
        it_finno-finno = gs_disp-finno.
        COLLECT it_finno.
      ELSE.
        gs_disp-errmd = 'X'.
        PERFORM set_return_message_fill USING 'E'.
        CONTINUE.
      ENDIF.
    ENDIF.

    IF gs_disp-errmd IS INITIAL.

*> 음수일 경우.
      IF gs_disp-wrbtr LE 0.
        gs_disp-wrbtr = gs_disp-wrbtr * -1.
        IF gs_disp-dmbtr LE 0.
          gs_disp-dmbtr = gs_disp-dmbtr * -1.
        ENDIF.
        IF gs_disp-wmwst LE 0.
          gs_disp-wmwst = gs_disp-wmwst * -1.
        ENDIF.
        IF gs_disp-fwbas LE 0.
          gs_disp-fwbas = gs_disp-fwbas * -1.
        ENDIF.
        CASE gs_disp-vorgang.
          WHEN '1'.  gs_disp-vorgang = '3'.
          WHEN '2'.  gs_disp-vorgang = '4'.
          WHEN '3'.  gs_disp-vorgang = '1'.
          WHEN '4'.  gs_disp-vorgang = '2'.
        ENDCASE.
      ENDIF.

      ADD 1 TO ztisscrcom-itcnt.
      CLEAR: it_collect.
*> 공급업체+세금코드+사업장별 Collect.
      MOVE: gs_disp-lifnr   TO  it_collect-lifnr.
      MOVE: gs_disp-blart   TO  it_collect-blart.
      MOVE: gs_disp-mwskz   TO  it_collect-mwskz.
      MOVE: gs_disp-bupla   TO  it_collect-bupla.
      MOVE: gs_disp-wrbtr   TO  it_collect-wrbtr.
      MOVE: gs_disp-dmbtr   TO  it_collect-dmbtr.
      MOVE: gs_disp-wmwst   TO  it_collect-wmwst.
      MOVE: gs_disp-fwbas   TO  it_collect-fwbas.
      MOVE: gs_disp-hwaer   TO  it_collect-hwaer.
      MOVE: gs_disp-waers   TO  it_collect-waers.
      MOVE: gs_disp-cstyp   TO  it_collect-cstyp.
      MOVE: gs_disp-vorgang TO  it_collect-vorgang.
      MOVE: gs_disp-zfbdt   TO  it_collect-zfbdt.

      COLLECT it_collect.
    ENDIF.

    MODIFY it_disp FROM gs_disp INDEX g_tabix.
  ENDLOOP.

ENDFORM.                    " build_posting_data
*&---------------------------------------------------------------------*
*&      Form  fill_posting_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM fill_posting_data .

  DATA: l_icsno(5)     TYPE n,
        l_icssq        TYPE ztiicssq.

  CLEAR: l_icsno.
************************************************************************
*> 일괄전기일 경우...
************************************************************************
  IF ztisscrcom-monsc EQ 'S'.
    LOOP AT it_collect.
      ADD 1 TO l_icsno.
*> Header data Move
      PERFORM set_header_data_by_collect USING l_icsno  'L'.

*---> Item data Move
      CLEAR: l_icssq.
      LOOP AT it_disp INTO gs_disp
                       WHERE lifnr   EQ it_collect-lifnr
                         AND bupla   EQ it_collect-bupla
                         AND mwskz   EQ it_collect-mwskz
                         AND waers   EQ it_collect-waers
                         AND hwaer   EQ it_collect-hwaer
                         AND blart   EQ it_collect-blart
                         AND cstyp   EQ it_collect-cstyp
                         AND vorgang EQ it_collect-vorgang
                         AND zfbdt   EQ it_collect-zfbdt
                         AND box   EQ 'X'
                         AND errmd EQ space.

        CLEAR: it_ztitcsp.
        ADD 1 TO l_icssq.

        PERFORM set_item_data   USING l_icsno  l_icssq  'L'.
      ENDLOOP.
    ENDLOOP.
  ELSE.
************************************************************************
*> 개별전기일 경우...
************************************************************************
    LOOP AT it_disp INTO gs_disp WHERE box   EQ 'X'
                                   AND errmd EQ space.
      ADD 1 TO l_icsno.
*> Header data Move
      PERFORM set_header_data_by_individual USING l_icsno  'L'.
*---> Item data Move
      CLEAR: l_icssq.
      ADD 1 TO l_icssq.
      PERFORM set_item_data   USING l_icsno  l_icssq  'L'.
    ENDLOOP.
  ENDIF.

ENDFORM.                    " fill_posting_data
*&---------------------------------------------------------------------*
*&      Form  get_selected_row
*&---------------------------------------------------------------------*
FORM get_selected_row  TABLES   pt_row_no TYPE lvc_t_roid.

  CLEAR: g_count.
  REFRESH: it_finno.
  LOOP AT it_disp INTO gs_disp WHERE box = 'X'.
    it_finno-finno = gs_disp-finno.
    COLLECT it_finno.
    ADD 1 TO g_count.
  ENDLOOP.
  IF g_count EQ 0.
    MESSAGE s909.
  ENDIF.

ENDFORM.                    " get_selected_row
*&---------------------------------------------------------------------*
*&      Form  set_selected_row
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM set_selected_row  USING    p_mark.

  CLEAR: g_count.

  LOOP AT it_disp INTO gs_disp.
    gs_disp-box = p_mark.
    MODIFY it_disp FROM gs_disp.

    IF p_mark = 'X'.
      g_count = g_count + 1.
    ENDIF.
  ENDLOOP.

  IF g_count <> 0.
    MESSAGE s883 WITH g_count.
  ENDIF.


  IF g_count <> 0.
    MESSAGE s883 WITH g_count.
  ENDIF.

  CALL METHOD g_grid->refresh_table_display.

ENDFORM.                    " set_selected_row
*&---------------------------------------------------------------------*
*&      Form  handle_toolbar
*&---------------------------------------------------------------------*
FORM handle_toolbar USING r_object TYPE REF TO cl_alv_event_toolbar_set
                          r_interactive.
*0    Button (normal)
*1    Menu and default button
*2    Menu
*3    Separator
*4    Radio button
*5    Checkbox
*6    Menu entry

  DATA: ls_toolbar  TYPE stb_button.

* append a separator to normal toolbar
  CLEAR  ls_toolbar.
  MOVE 3                    TO ls_toolbar-butn_type.
  APPEND ls_toolbar         TO r_object->mt_toolbar.
*
* append an icon to refresh
  CLEAR ls_toolbar.
  MOVE 0                    TO ls_toolbar-butn_type.
  MOVE 'REFRESH'            TO ls_toolbar-function.
  MOVE icon_refresh         TO ls_toolbar-icon.
  MOVE 'REFRESH'(120)    TO ls_toolbar-quickinfo.
  MOVE space                TO ls_toolbar-disabled.
  APPEND ls_toolbar         TO r_object->mt_toolbar.

* append an icon to select all
  CLEAR ls_toolbar.
  MOVE 0                    TO ls_toolbar-butn_type.
  MOVE 'SELECT'             TO ls_toolbar-function.
  MOVE icon_select_all      TO ls_toolbar-icon.
  MOVE '모두 선택'(121)    TO ls_toolbar-quickinfo.
  MOVE space                TO ls_toolbar-disabled.
  APPEND ls_toolbar         TO r_object->mt_toolbar.

* append an icon to deselect all
  CLEAR ls_toolbar.
  MOVE 0                    TO ls_toolbar-butn_type.
  MOVE 'DESELECT'           TO ls_toolbar-function.
  MOVE icon_deselect_all    TO ls_toolbar-icon.
  MOVE '선택 해제'(122)    TO ls_toolbar-quickinfo.
  MOVE space                TO ls_toolbar-disabled.
  APPEND ls_toolbar         TO r_object->mt_toolbar.

* append a separator to normal toolbar
  CLEAR  ls_toolbar.
  MOVE 3                    TO ls_toolbar-butn_type.
  APPEND ls_toolbar         TO r_object->mt_toolbar.

* append an icon to posting 비용문서.
  CLEAR ls_toolbar.
  MOVE 0                    TO ls_toolbar-butn_type.
  MOVE 'ZTIT901'            TO ls_toolbar-function.
  MOVE icon_financing       TO ls_toolbar-icon.
  MOVE ' 비용 전기'(113)   TO ls_toolbar-quickinfo.
  MOVE ' 비용 전기'(113)    TO ls_toolbar-text.
  MOVE space                TO ls_toolbar-disabled.
  APPEND ls_toolbar         TO r_object->mt_toolbar.

* append an icon to Term Charge 계산.
  CLEAR ls_toolbar.
  MOVE 0                    TO ls_toolbar-butn_type.
  MOVE 'ZTIDELETE'          TO ls_toolbar-function.
  MOVE icon_delete          TO ls_toolbar-icon.
  MOVE 'EDI 데이타 삭제'(115)    TO ls_toolbar-quickinfo.
  MOVE 'EDI 데이타 삭제'(114)   TO ls_toolbar-text.
  MOVE space                TO ls_toolbar-disabled.
  APPEND ls_toolbar         TO r_object->mt_toolbar.

ENDFORM.                    " handle_toolbar
*&---------------------------------------------------------------------*
*&      Form  p3800_set_title_text
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form p3800_set_title_text .

** JS전선 회사코드 2007/04 KSH --------------------------------------
  DATA: l_butxt LIKE t001-butxt,
        l_title TYPE lvc_title.
  CLEAR: l_butxt, l_title.
  SELECT SINGLE butxt FROM t001
                      INTO l_butxt
                     WHERE bukrs EQ s_bukrs-low.

  CONCATENATE '회사코드:' s_bukrs-low l_butxt
         INTO l_title SEPARATED BY space.

  CALL METHOD g_grid->set_gridtitle
    EXPORTING
      i_gridtitle = l_title.
** JS전선 회사코드 2007/04 KSH --------------------------------------

endform.                    " p3800_set_title_text
