*&---------------------------------------------------------------------*
*&  Include           ZGTSDR1080_FRM                                   *
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  mark_changed
*&---------------------------------------------------------------------*
FORM mark_changed  USING rr_data_changed TYPE REF TO
                         cl_alv_changed_data_protocol
                         rs_mod_cells TYPE lvc_s_modi.

  DATA : ls_cells      TYPE lvc_s_modi,
         lt_good_cells TYPE lvc_t_modi,
         ls_good       TYPE lvc_s_modi.


  LOOP AT rr_data_changed->mt_good_cells INTO ls_good.
    READ TABLE gt_display INDEX ls_good-row_id.

*      case ls_good-fieldname.
*        when 'CHK'.
*          clear : lv_netwr.
*          call method rr_data_changed->get_cell_value
*            exporting
*              i_row_id    = ls_good-row_id
*              i_fieldname = ls_good-fieldname
*            importing
*              e_value     = lv_netwr.
*
*
*            call method rr_data_changed->add_protocol_entry
*              exporting
*                i_msgid     = '0K'
*                i_msgno     = '000'
*                i_msgty     = 'E'
*                i_msgv1     = text-m03
*                i_fieldname = ls_good-fieldname
*                i_row_id    = ls_good-row_id.
*            exit.
*          endif.

    gt_display-chk = 'X'.
    MODIFY gt_display INDEX ls_good-row_id.
  ENDLOOP.

ENDFORM.                    " mark_changed
*&---------------------------------------------------------------------*
*&      Form  get_data
*&---------------------------------------------------------------------*
FORM select_lclist_data .

  DATA : lt_ztevfd03 LIKE ztevfd03 OCCURS 0 WITH HEADER LINE.

  DATA : lv_bstnk   LIKE vbak-bstnk,
         lv_bstkd_m LIKE vbkd-bstkd_m,
         lv_error.

  CLEAR:     gt_temp, gt_header, gt_items, lv_error.
  REFRESH:   gt_temp, gt_header, gt_items.

  LOOP AT gt_display WHERE chk EQ 'X'.

    IF gt_display-kdkg4 EQ '4D'.
      lv_error = 'X'.
      EXIT.
    ENDIF.

    IF gt_display-compl = 'Y'.
      MESSAGE e001 WITH '마감 확정된 데이터 입니다..'.
      EXIT.
    ENDIF.

* 납품관련
    LOOP AT gt_deldata WHERE branch = gt_display-branch
                        AND  vkbur  = gt_display-vkbur
                        AND  vkgrp  = gt_display-vkgrp
                        AND  vtweg  = gt_display-vtweg
                        AND  kdkg4  = gt_display-kdkg4
                        AND  kunnr  = gt_display-kunnr.

      MOVE-CORRESPONDING gt_deldata TO gt_temp.

      IF gt_display-kdkg4 NE '4L'.
        SELECT SINGLE * FROM ztevbl00
                  WHERE vbeln  = gt_deldata-vbeln
                   AND  posnr  = gt_deldata-posnr.
        IF sy-subrc EQ 0.
          gt_temp-zuonr = ztevbl00-hblno.
        ELSE.
          CLEAR : gt_temp-zuonr.
        ENDIF.
      ELSE.
        CLEAR : gt_temp-zuonr.
      ENDIF.

      gt_temp-name1 = gt_display-name1.

      CLEAR : lt_ztevfd03, lt_ztevfd03[], ztevbl00.
      SELECT  * INTO CORRESPONDING FIELDS OF TABLE lt_ztevfd03
                 FROM ztevfd03
                  WHERE vbeln  = gt_deldata-vbeln
                   AND  posnr  = gt_deldata-posnr
                   AND  billno = ' '.

** Add by SDC06 : 2005-04-25 Request by 윤방희위원
** FIDTY : 'PC'일 경우는 B/L NO = 'GUMAE'
**         'LO'일 경우는 B/L NO = 'LOCALLC'
      IF sy-subrc EQ 0.
        LOOP AT lt_ztevfd03.
          gt_temp-zlcno = lt_ztevfd03-baanr.
          gt_temp-netwr_a = gt_temp-netwr_a + lt_ztevfd03-adtwr.
          gt_temp-kurrf = lt_ztevfd03-kursf.
          gt_temp-waerk = lt_ztevfd03-fidwk.

          IF  lt_ztevfd03-fidty  =  'PC'.
            gt_temp-zuonr  =  'GUMAE'.
          ELSEIF  lt_ztevfd03-fidty  =  'LO'.
            gt_temp-zuonr  =  'LOCALLC'.
          ENDIF.

        ENDLOOP.

        APPEND gt_temp.

** Changed by SDC06 : 2005-04-11
** L/C미지정 금액에 대한 것도 보여주기 위함.
        gt_temp-netwr_a  =  gt_deldata-netwr - gt_temp-netwr_a.

        IF  gt_temp-netwr_a  >  0.
          gt_temp-zlcno = space.
          APPEND gt_temp.
        ENDIF.

      ELSE.
** Changed by SDC06 : 2005-04-11
*        gt_temp-netwr_a = gt_deldata-netwr.
        gt_temp-netwr_a = gt_deldata-r_netwr.
        APPEND gt_temp.
      ENDIF.

*      if gt_display-kdkg4 ne '4L'.
*        select single * from ztevbl00
*                  where vbeln  = gt_deldata-vbeln
*                   and  posnr  = gt_deldata-posnr.
*        if sy-subrc eq 0.
*          gt_temp-zuonr = ztevbl00-hblno.
*        else.
*          clear : gt_temp-zuonr.
*        endif.
*      else.
*        clear : gt_temp-zuonr.
*      endif.
*
*      gt_temp-name1 = gt_display-name1.

*      append gt_temp.

      CLEAR gt_temp.

    ENDLOOP.

*오더관련
    LOOP AT gt_billdata  WHERE branch = gt_display-branch
                          AND  vkbur  = gt_display-vkbur
                          AND  vkgrp  = gt_display-vkgrp
                          AND  vtweg  = gt_display-vtweg
                          AND  kdkg4  = gt_display-kdkg4
                          AND  kunnr  = gt_display-kunnr.

      MOVE-CORRESPONDING gt_billdata TO gt_temp.

      gt_temp-netwr_a = gt_billdata-netwr.
      CLEAR : lv_bstnk.
      SELECT SINGLE bstnk INTO lv_bstnk
               FROM vbak
               WHERE vbeln = gt_billdata-vbeln.

      IF sy-subrc EQ 0.
        gt_temp-zlcno = lv_bstnk.
      ENDIF.

      IF gt_display-kdkg4 NE '4L'.
        CLEAR : lv_bstkd_m.
*        select single bstkd_m into lv_bstkd_m
        SELECT SINGLE bstkd_e INTO lv_bstkd_m
                   FROM vbkd
                   WHERE vbeln = gt_billdata-vbeln
                     AND posnr = '000000'.

        IF sy-subrc EQ 0.
          gt_temp-zuonr = lv_bstkd_m.
        ENDIF.
      ENDIF.

      gt_temp-name1 = gt_display-name1.

      IF  gt_billdata-vbtyp  =  'K'.
        gt_temp-netwr_a  =  gt_temp-netwr_a  *  -1.
      ENDIF.

      APPEND gt_temp. CLEAR gt_temp.
    ENDLOOP.

    LOOP AT gt_noslip   WHERE branch = gt_display-branch
                              AND  vkbur  = gt_display-vkbur
                              AND  vkgrp  = gt_display-vkgrp
                              AND  vtweg  = gt_display-vtweg
                              AND  kdkg4  = gt_display-kdkg4
                              AND  kunnr  = gt_display-kunnr
                              AND  fkart  NE 'ZF2'.

      MOVE-CORRESPONDING gt_noslip TO gt_temp.

      gt_temp-zlcno = gt_noslip-zzlcno.
* 1. 전표 미생성
      IF gt_noslip-rfbsk IN lr_rfbsk AND gt_noslip-fkart NE 'ZF2'.
        gt_temp-netwr_b = gt_noslip-netwr.
      ELSE.
        gt_temp-netwr_c = gt_noslip-netwr.
      ENDIF.

      gt_temp-name1 = gt_display-name1.

** Billing Type : 'O'일경우 -1를 곱한다.
      IF  gt_noslip-vbtyp  =  'O'.
        gt_temp-netwr_b  =  gt_temp-netwr_b  *  -1.
        gt_temp-netwr_c  =  gt_temp-netwr_c  *  -1.
        gt_temp-netwr_d  =  gt_temp-netwr_d  *  -1.
        gt_temp-netwr_f  =  gt_temp-netwr_f  *  -1.
      ENDIF.

      APPEND gt_temp. CLEAR gt_temp.
    ENDLOOP.
  ENDLOOP.

  IF lv_error EQ 'X'.
    MESSAGE e001 WITH '내수는 대상에서 제외됩니다'.
  ENDIF.

  SORT gt_temp.


*  delete adjacent duplicates from gt_temp.
*                             comparing vbeln p.

  DELETE gt_temp WHERE netwr_a IS INITIAL
                  AND  netwr_b IS INITIAL
                  AND  netwr_c IS INITIAL.

  LOOP AT gt_temp.
    g_index = sy-tabix.
    IF  gt_temp-netwr_a  =  0.
      gt_temp-netwr_d  =  0.
    ELSE.
      IF  gt_temp-waerk  =  'KRW'.
        gt_temp-netwr_d =  gt_temp-netwr_a.
      ELSE.
        gt_temp-netwr_d = ( gt_temp-netwr_a * gt_temp-kurrf ) / 100.
      ENDIF.
    ENDIF.
    IF  gt_temp-netwr_b  =  0.
      gt_temp-netwr_e  =  0.
    ELSE.
      IF  gt_temp-waerk  =  'KRW'.
        gt_temp-netwr_e =  gt_temp-netwr_b.
      ELSE.
        gt_temp-netwr_e = ( gt_temp-netwr_b * gt_temp-kurrf ) / 100.
      ENDIF.
    ENDIF.
    IF  gt_temp-netwr_c  =  0.
      gt_temp-netwr_f  =  0.
    ELSE.
      IF  gt_temp-waerk  =  'KRW'.
        gt_temp-netwr_f =  gt_temp-netwr_c.
      ELSE.
        gt_temp-netwr_f = ( gt_temp-netwr_c * gt_temp-kurrf ) / 100.
      ENDIF.
    ENDIF.
    gt_temp-waers = 'KRW'.
    MODIFY gt_temp INDEX g_index.
  ENDLOOP.


*  perform export_global_data.


ENDFORM.                    " get_data

*&---------------------------------------------------------------------*
*&      Form  export_global_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM export_global_data .
  EXPORT gt_temp TO MEMORY ID 'ZSD1'.
  SUBMIT zsdr1081 AND RETURN.
ENDFORM.                    " export_global_data

*---------------------------------------------------------------------*
*       FORM f4help_layout                                            *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  CS_LAYOUT                                                     *
*---------------------------------------------------------------------*
FORM f4help_layout CHANGING cs_layout LIKE disvariant-variant.

  DATA: ls_variant LIKE disvariant.

  ls_variant-report      = sy-repid.
  ls_variant-handle      = space.
  ls_variant-log_group   = space.
  ls_variant-username    = space.
  ls_variant-variant     = cs_layout.
  ls_variant-text        = space.
  ls_variant-dependvars  = space.

  DATA: lt_dynpfields LIKE dynpread OCCURS 0 WITH HEADER LINE.

  CLEAR lt_dynpfields.
  lt_dynpfields-fieldname = 'P_LAYOUT'.
  APPEND lt_dynpfields.

  READ TABLE lt_dynpfields WITH KEY fieldname = 'P_LAYOUT'.
  IF sy-subrc EQ 0.
    IF NOT lt_dynpfields-fieldvalue(1) CA '0123456789/' AND
       NOT lt_dynpfields-fieldvalue IS INITIAL.
      ls_variant-username = sy-uname.
    ENDIF.
    ls_variant-variant = lt_dynpfields-fieldvalue.
  ENDIF.

  DATA: lt_fcat TYPE lvc_t_fcat.
  CALL FUNCTION 'LVC_VARIANT_SAVE_LOAD'
    EXPORTING
      i_save_load = 'F'
      i_tabname   = '1'
    CHANGING
      cs_variant  = ls_variant
      ct_fieldcat = lt_fcat[].

  cs_layout = ls_variant-variant.

ENDFORM.                    "f4help_layout

*&---------------------------------------------------------------------*
*&      Form  toolbar_pros
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM toolbar_pros  USING    r_object
                                TYPE REF TO
cl_alv_event_toolbar_set
                            r_interactive.

  DATA : ls_toolbar  TYPE stb_button.


*// 전체선택버튼
  CLEAR ls_toolbar.
  MOVE 'REFR'               TO  ls_toolbar-function.
  MOVE icon_refresh         TO  ls_toolbar-icon.
  MOVE 'Refresh'            TO  ls_toolbar-quickinfo.
  MOVE 'Refresh'            TO  ls_toolbar-text.
  MOVE ' '                  TO  ls_toolbar-disabled.
  APPEND ls_toolbar         TO  r_object->mt_toolbar.

  CHECK sy-tcode NE 'ZGTSDR1085'.
*// 가로줄
  MOVE   3                  TO   ls_toolbar-butn_type.
  APPEND ls_toolbar         TO   r_object->mt_toolbar.

  PERFORM toobar_pros_tab01 USING r_object
                                  r_interactive
                                  ls_toolbar.

*// 가로줄
  MOVE   3                  TO   ls_toolbar-butn_type.
  APPEND ls_toolbar         TO   r_object->mt_toolbar.

  PERFORM toobar_pros_tab08 USING r_object            "내수 로컬 LINK
                                  r_interactive
                                  ls_toolbar.

*// 가로줄
  MOVE   3                  TO   ls_toolbar-butn_type.
  APPEND ls_toolbar         TO   r_object->mt_toolbar.

*//
  PERFORM toobar_pros_tab02 USING r_object
                                  r_interactive
                                  ls_toolbar.

*// 가로줄
*  MOVE   3                  TO   LS_TOOLBAR-BUTN_TYPE.
*  APPEND LS_TOOLBAR         TO   R_OBJECT->MT_TOOLBAR.
*
**//
*  PERFORM TOOBAR_PROS_TAB03 USING R_OBJECT
*                                  R_INTERACTIVE
*                                  LS_TOOLBAR.

*// 가로줄
  MOVE   3                  TO   ls_toolbar-butn_type.
  APPEND ls_toolbar         TO   r_object->mt_toolbar.

  PERFORM toobar_pros_tab04 USING r_object
                                  r_interactive
                                  ls_toolbar.

*// 가로줄
  MOVE   3                  TO   ls_toolbar-butn_type.
  APPEND ls_toolbar         TO   r_object->mt_toolbar.

  PERFORM toobar_pros_tab05 USING r_object
                                  r_interactive
                                  ls_toolbar.
*// 가로줄
  MOVE   3                  TO   ls_toolbar-butn_type.
  APPEND ls_toolbar         TO   r_object->mt_toolbar.

  PERFORM toobar_pros_tab06 USING r_object
                                  r_interactive
                                  ls_toolbar.

*// 가로줄 : Add By SDC06 : 2005-05-19
  MOVE   3                  TO   ls_toolbar-butn_type.
  APPEND ls_toolbar         TO   r_object->mt_toolbar.

  PERFORM toobar_pros_tab07 USING r_object
                                  r_interactive
                                  ls_toolbar.

*마감확정/ 취소 버튼
  MOVE   3                  TO   ls_toolbar-butn_type.
  APPEND ls_toolbar         TO   r_object->mt_toolbar.

  CLEAR ls_toolbar.
  MOVE 'ZF08'               TO  ls_toolbar-function.
  MOVE icon_system_okay     TO  ls_toolbar-icon.
  MOVE '마감확정'           TO  ls_toolbar-quickinfo.
  MOVE '마감확정'           TO  ls_toolbar-text.
  MOVE ' '                  TO  ls_toolbar-disabled.
  APPEND ls_toolbar         TO  r_object->mt_toolbar.

  CLEAR ls_toolbar.
  MOVE 'ZF09'               TO  ls_toolbar-function.
  MOVE icon_system_cancel   TO  ls_toolbar-icon.
  MOVE '마감확정취소'       TO  ls_toolbar-quickinfo.
  MOVE '마감확정취소'       TO  ls_toolbar-text.
  MOVE ' '                  TO  ls_toolbar-disabled.
  APPEND ls_toolbar         TO  r_object->mt_toolbar.

ENDFORM.                    " toolbar_pros


*&---------------------------------------------------------------------*
*&      Form  user_command_pros
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM user_command_pros  USING    r_ucomm.
  DATA: l_quest(50).
  CLEAR: l_quest, gs_fb01.
  g_err = 'N'.   "default

  CASE r_ucomm.
    WHEN 'SALL'.   "전체선택
*      perform select_all_item.
*      perform set_cell_attribute .

    WHEN 'ZF01'.   "내수로컬Billing
      PERFORM call_billing_screen.
    WHEN 'ZFL01'.
      PERFORM call_4l_screen.
    WHEN 'ZF02'.   "계산서
      PERFORM call_computer_screen.
    WHEN 'ZF03'.   "적송
      PERFORM call_delivery_screen USING ''.
    WHEN 'ZF04'.   "보류해제
      PERFORM call_block_screen.
    WHEN 'ZF05'.   "외화금액변화
      PERFORM convert_foreign_amt.
    WHEN 'ZF06'.   "L/C별리스트
      PERFORM display_detail_list.
    WHEN 'ZF07'.   "상세리스트
      PERFORM display_detail_list2.
    WHEN 'REFR'.  "refresh
      PERFORM p1000_initial_data.
      PERFORM p1000_select_data.
      PERFORM p2000_process_data USING ' '.
      MESSAGE s009(zgtsd01) WITH |{ lines( gt_display ) NUMBER = USER }|. "& 건 검색되었습니다.
    WHEN 'ZF08'.   "마감확정
      PERFORM sales_closing_confirm.
    WHEN 'ZF09'.   "마감확정취소
      PERFORM sales_closing_confirm_canc.
  ENDCASE.



ENDFORM.                    " user_command_pros

*&---------------------------------------------------------------------*
*&      Form  after_user_command
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM after_user_command  USING    e_ucomm.

  CASE lcl_alv_grid=>f_alv.
    WHEN '1'.   "개요화면의 경우
      gt_display-chk = ''.
      MODIFY gt_display TRANSPORTING chk WHERE flag = 'X'.

      PERFORM set_cell_attribute.

      l_scroll-row = 'X'.
      l_scroll-col = 'X'.

      CALL METHOD g_grid->refresh_table_display
        EXPORTING
          i_soft_refresh = 'X'
          is_stable      = l_scroll.     "현재 그대로입력한 refresh

      CALL METHOD g_grid->set_optimizer.




  ENDCASE.

ENDFORM.                    " after_user_command


*&---------------------------------------------------------------------*
*&      Form  data_changed
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM data_changed  USING    rr_data_changed
                            TYPE REF TO
cl_alv_changed_data_protocol
                            e_onf4         TYPE char1
                            e_ucomm        TYPE sy-ucomm
                            po_sender.

  DATA : ls_mod_cells TYPE lvc_s_modi,
         ls_cells     TYPE lvc_s_modi.
  CASE po_sender.
    WHEN g_grid.
      gt_display-chk = ' '.
      MODIFY gt_display TRANSPORTING chk WHERE flag = ' '.
    WHEN go_grid.

  ENDCASE.

  LOOP AT rr_data_changed->mt_good_cells INTO ls_mod_cells.
    CASE  ls_mod_cells-fieldname.
      WHEN  'CHK'.
        PERFORM mark_changed USING rr_data_changed ls_mod_cells.
    ENDCASE.
  ENDLOOP.



ENDFORM.                    " data_changed


*&---------------------------------------------------------------------*
*&      Form  data_changed_finished
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM data_changed_finished  USING    e_modified TYPE char01
                                     et_good_cells TYPE lvc_t_modi
                                     po_sender.
  DATA: ls_mod_cells TYPE lvc_s_modi.
  DATA: l_dis LIKE gt_display OCCURS 0 WITH HEADER LINE.

  CASE po_sender.
    WHEN g_grid.



*// 개요화면 조회시
      CHECK lcl_alv_grid=>f_alv EQ '1'.
      IF e_modified = 'X'.

*   선택시 gt_display-flag = 'X' 완료건이 있으면 해당 chk를 clear함
        gt_display-chk = ''.
        MODIFY gt_display TRANSPORTING chk WHERE flag = 'X'.


*    g_title = text-000.
*    CONCATENATE g_title '( Total : ' g_cnt '건 )' INTO g_title.

        PERFORM set_cell_attribute.

        l_scroll-row = 'X'.
        l_scroll-col = 'X'.


        CALL METHOD g_grid->refresh_table_display
          EXPORTING
            i_soft_refresh = 'X'
            is_stable      = l_scroll.     "현재 그대로 입력한 refresh

        CALL METHOD g_grid->set_optimizer.

      ENDIF.
    WHEN go_grid.

  ENDCASE.
ENDFORM.                    " data_changed_finished


*&---------------------------------------------------------------------*
*&      Form  hotspot_click
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM hotspot_click  USING    e_row_id
                             e_column_id.
* 합계/소개행의 더블클릭이벤트 제어->숫자값이 들어올때만 실행
  DATA: l_htype(4).
  CLEAR: l_htype.
  PERFORM p0000_check_chracter USING e_row_id l_htype.
  CHECK l_htype EQ 'NUMC'.

*// 개요화면

  IF e_column_id = 'ZUONR'.      "적송가매출

    READ TABLE gt_display INDEX e_row_id.

    IF sy-subrc = 0.
*      set parameter id 'VF' field gt_display-zuonr.
*      call transaction 'VF03' and skip first screen.
    ENDIF.

  ELSEIF e_column_id = 'VBELN'.      "적송매출
    READ TABLE gt_display INDEX e_row_id.

    IF sy-subrc = 0.
*      set parameter id 'VF' field gt_display-vbeln.
*      call transaction 'VF03' and skip first screen.
    ENDIF.

  ENDIF.

ENDFORM.                    " hotspot_click


*&---------------------------------------------------------------------*
*&      Form  double_click
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM double_click  USING    e_row
                            e_column.
** 합계/소개행의 더블클릭이벤트 제어->숫자값이 들어올때만 실행
*  DATA: l_htype(4).
*  CLEAR: l_htype.
*  PERFORM p0000_check_chracter USING e_row l_htype.
*  CHECK l_htype EQ 'NUMC'.
*

ENDFORM.                    " double_click


*&---------------------------------------------------------------------*
*&      Form  on_f4
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM on_f4  USING sender         TYPE REF TO cl_gui_alv_grid
                  e_fieldname    TYPE lvc_fname
                  e_fieldvalue   TYPE lvc_value
                  es_row_no      TYPE lvc_s_roid
                  er_event_data  TYPE REF TO cl_alv_event_data
                  et_bad_cells   TYPE lvc_t_modi
                  e_display      TYPE char01.

  DATA : selectfield  LIKE  help_info-fieldname,
         it_fields    LIKE  help_value OCCURS 1 WITH HEADER LINE,
         select_value LIKE  help_info-fldvalue,
         ld_tabix     LIKE  sy-tabix,
         ls_modi      TYPE  lvc_s_modi,
         f_date       LIKE sy-datum.

  FIELD-SYMBOLS : <f4tab> TYPE lvc_t_modi.

*//기산일->달력
*  if  e_fieldname = 'VALUT'.    "기산일
*
*    call function 'F4_DATE'
*      exporting
*        date_for_first_month = sy-datum
*        factory_calendar_id  = 'LG'
*      importing
*        select_date          = f_date.
*
*    assign er_event_data->m_data->* to <f4tab>.
*
*    ls_modi-row_id    = es_row_no-row_id.
*    ls_modi-fieldname =  e_fieldname.
*    ls_modi-value     = f_date.
*    ls_modi-error     = 'X'.
*    append ls_modi to <f4tab>.
*
**    IF g_activetab NE 'PUSH2'.
*** TO AVOID STANDARD F4-HELP...선택한 데이터로 필드값변경시...
**      IF ls_modi-value <> ' ' .
**        er_event_data->m_event_handled = 'X'.
**      ENDIF.
**    ENDIF.
*  endif.


ENDFORM.                                                    " on_f4


*&---------------------------------------------------------------------*
*&      Form  p0000_check_chracter
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM p0000_check_chracter USING e_row p_htype .
  DATA: l_string(50).

  CLEAR: l_string, p_htype.
  WRITE e_row           TO l_string.

  CALL FUNCTION 'NUMERIC_CHECK'
    EXPORTING
      string_in = l_string
    IMPORTING
*     STRING_OUT       =
      htype     = p_htype.

ENDFORM.                    " p0000_check_chracter


*&---------------------------------------------------------------------*
*&      Form  create_and_init_controls
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM create_and_init_controls .

*  CHECK g_docking_container IS INITIAL.

*// Create an Instance Of Container
*  CREATE OBJECT g_docking_container
*    EXPORTING
*      dynnr     =  '0100'
*      repid     =  sy-repid
*      side      =  g_docking_container->dock_at_top
*      extension =  2000
*    EXCEPTIONS
*      cntl_error = 1
*      cntl_system_error = 2
*      create_error = 3
*      lifetime_error = 4
*      lifetime_dynpro_dynpro_link = 5.


  CHECK custom_container IS INITIAL.

  CREATE OBJECT custom_container
    EXPORTING
      container_name              = 'CUSTOMER'
    EXCEPTIONS
      cntl_error                  = 1
      cntl_system_error           = 2
      create_error                = 3
      lifetime_error              = 4
      lifetime_dynpro_dynpro_link = 5.

  IF sy-subrc <> 0.
    MESSAGE a003.
  ENDIF.

*// Create an Instance of ALV Control
  CREATE OBJECT g_grid
    EXPORTING
      i_parent      = custom_container
*     i_shellstyle  = ws_thickframe  "테두리두껍게
      i_appl_events = 'X'.


*// Tool Bar 버튼 제거
  PERFORM exclude_of_toolbar_button USING 'GT_EXCLUDE'.

*// 출력할 필드 속성을 정의
  PERFORM set_field_catalogs.

*// CELL의 특성 제어(Color등)
  PERFORM set_cell_attribute.

*// GRID 속성 지정(Display): Display시 옵션 지정
  PERFORM display_layout_attribute USING gs_layocat.

*// Edit Event 및  Event Handler 등록
  PERFORM event_handler_register.

*// Sorting
  PERFORM build_sort_field.

*// F4 FIELD 등록
  PERFORM set_f4_field.

*// TITLE 지정
  DESCRIBE TABLE gt_display LINES g_cnt.
  CONCATENATE '⊙ ' TEXT-t01 '(' g_cnt '건 )' INTO g_title
                                        SEPARATED BY space.
  CONDENSE g_title.

*// ALV Grid Display
  PERFORM alv_grid_display.

  CALL METHOD g_grid->set_gridtitle
    EXPORTING
      i_gridtitle = g_title.

*// DETAIL LIST를 위한 설정
*  lcl_alv_grid=>f_alv = '1'.

ENDFORM.                    " create_and_init_controls


*&---------------------------------------------------------------------*
*&      Form  exclude_of_toolbar_button
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_0756   text
*----------------------------------------------------------------------*
FORM exclude_of_toolbar_button  USING    p_tabname..
  DATA : l_tab_name LIKE feld-name.

  FIELD-SYMBOLS : <table> TYPE ui_functions.

  CONCATENATE p_tabname '[]' INTO  l_tab_name.
  ASSIGN     (l_tab_name)    TO <table>.

*// 제거할 버튼 지정
  PERFORM add_exclude_toolbar_button
         TABLES <table>
*        USING : cl_gui_alv_grid=>mc_fc_excl_all. " **툴바 모두제거 **
        USING : cl_gui_alv_grid=>mc_fc_loc_undo, " 실행취소&LOCAL&UNDO
                cl_gui_alv_grid=>mc_fc_auf,      " 소계확장 &AUF
                cl_gui_alv_grid=>mc_fc_average,  "&AVERAGE
*                cl_gui_alv_grid=>mc_fc_back_classic,
*                cl_gui_alv_grid=>mc_fc_call_abc, "&ABC
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
                cl_gui_alv_grid=>mc_fc_graph,
*                cl_gui_alv_grid=>mc_fc_help,
                cl_gui_alv_grid=>mc_fc_info,
*                cl_gui_alv_grid=>mc_fc_load_variant,
*                cl_gui_alv_grid=>mc_fc_loc_copy,      " 행 카피.
*                cl_gui_alv_grid=>mc_fc_html,
                cl_gui_alv_grid=>mc_fc_loc_copy_row,  " 행 카피.
                cl_gui_alv_grid=>mc_fc_loc_cut,       " 가위.
                cl_gui_alv_grid=>mc_fc_loc_delete_row," 행삭제.
                cl_gui_alv_grid=>mc_fc_loc_insert_row," 행삽입.
*                cl_gui_alv_grid=>mc_fc_loc_move_row,
                cl_gui_alv_grid=>mc_fc_loc_append_row," 라인생성.
                cl_gui_alv_grid=>mc_fc_loc_paste,     " 겹쳐쓰기.
                cl_gui_alv_grid=>mc_fc_loc_paste_new_row, " 겹쳐쓰기.
*                cl_gui_alv_grid=>mc_fc_maintain_variant,
*                cl_gui_alv_grid=>mc_fc_maximum,
*                cl_gui_alv_grid=>mc_fc_minimum,
*                cl_gui_alv_grid=>mc_fc_pc_file,
*                cl_gui_alv_grid=>mc_fc_print,
*                cl_gui_alv_grid=>mc_fc_print_back,
*                cl_gui_alv_grid=>mc_fc_print_prev,
                cl_gui_alv_grid=>mc_fc_refresh.
*                cl_gui_alv_grid=>mc_fc_reprep,
*                cl_gui_alv_grid=>mc_fc_save_variant,
*                cl_gui_alv_grid=>mc_fc_select_all,
*                cl_gui_alv_grid=>mc_fc_send,
*                cl_gui_alv_grid=>mc_fc_separator,
*                cl_gui_alv_grid=>mc_fc_sort,
*                cl_gui_alv_grid=>mc_fc_sort_asc,
*                cl_gui_alv_grid=>mc_fc_sort_dsc,
*                cl_gui_alv_grid=>mc_fc_subtot,
*                cl_gui_alv_grid=>mc_mb_sum,
*                cl_gui_alv_grid=>mc_fc_sum.
*                cl_gui_alv_grid=>mc_fc_to_office,
*                cl_gui_alv_grid=>mc_fc_to_rep_tree,
*                cl_gui_alv_grid=>mc_fc_unfix_columns,
*                cl_gui_alv_grid=>mc_fc_views,
*                cl_gui_alv_grid=>mc_fc_view_crystal,
*                cl_gui_alv_grid=>mc_fc_view_excel,
*                cl_gui_alv_grid=>mc_fc_view_grid,
*                cl_gui_alv_grid=>mc_fc_word_processor.

ENDFORM.                    "exclude_of_toolbar_button


*&---------------------------------------------------------------------*
*&      Form  add_exclude_toolbar_button
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM add_exclude_toolbar_button  TABLES   p_table
                                 USING    p_value.

  DATA: l_exclude TYPE ui_func.

  l_exclude = p_value.
  APPEND l_exclude TO p_table. "결과적으로 GT_EXCLUDE에 제거할 버튼 저장

ENDFORM.                    "add_exclude_toolbar_button


*&---------------------------------------------------------------------*
*&      Form  set_field_catalogs
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM set_field_catalogs .
  CLEAR:   gt_fieldcat, gt_fieldcat[].

  PERFORM set_field-cat_tab01.

ENDFORM.                    " set_field_catalogs
*&---------------------------------------------------------------------*
*&      Form  fill_field_catalogs
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM fill_field_catalogs  USING  p_gub  p_fname p_value.

*// 'S' -> Structure에 필드 속성 값 Setting을 Start 시점
*// 'E' -> Structure의 내용을 필드 카타로그 테이블에 저장 시점

  IF p_gub = 'S'.

    CLEAR gs_fieldcat.

  ENDIF.

*// 출력될 Field 속성을 정의해서 필드 카타로그 테이블에 저장
  DATA l_fname(40).
  FIELD-SYMBOLS <fs> TYPE any.
  CONCATENATE 'GS_FIELDCAT-' p_fname INTO l_fname.

  ASSIGN (l_fname) TO <fs>.
  <fs> = p_value.

  IF p_gub = 'E'.

    APPEND gs_fieldcat TO gt_fieldcat.

  ENDIF.

ENDFORM.                    " fill_field_catalogs


*&---------------------------------------------------------------------*
*&      Form  set_cell_attribute
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM set_cell_attribute .
* 각 Cell의 특성 제어
  DATA : lt_celltab TYPE lvc_t_styl,
         lt_color   TYPE lvc_t_scol.

  DATA: l_ebeln         LIKE bseg-ebeln.

  LOOP AT gt_display.
    g_index = sy-tabix.

    CLEAR: lt_celltab[], lt_color[].

    PERFORM fill_celltab CHANGING lt_celltab.
    PERFORM fill_color   CHANGING lt_color.

    CLEAR: gt_display-celltab[], gt_display-f_col[].

    INSERT LINES OF lt_celltab INTO TABLE gt_display-celltab.
    INSERT LINES OF lt_color   INTO TABLE gt_display-f_col.

    MODIFY gt_display INDEX g_index.
    CLEAR  gt_display.

  ENDLOOP.

ENDFORM.                    " set_cell_attribute


*&---------------------------------------------------------------------*
*&      Form  fill_celltab
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM fill_celltab  CHANGING pt_celltab  TYPE lvc_t_styl.
  DATA : ls_celltab TYPE lvc_s_styl,
         l_mode     TYPE raw4.

  DATA : l_fieldcat TYPE lvc_s_fcat.

  LOOP AT gt_fieldcat INTO l_fieldcat.

    ls_celltab-fieldname = l_fieldcat-fieldname.
*// Display 필드 전부 입력

*    if  (  ls_celltab-fieldname  = 'MATNR'  or
*           ls_celltab-fieldname  = 'ICON'   or
*           ls_celltab-fieldname  = 'ARKTX'  or
*           ls_celltab-fieldname  = 'KDKG4'  or
*           ls_celltab-fieldname  = 'VTEXT'  or
*           ls_celltab-fieldname  = 'SPART'  or
*           ls_celltab-fieldname  = 'VKBUR'  or
*           ls_celltab-fieldname  = 'VKGRP'  or
*           ls_celltab-fieldname  = 'POSNR'  or
*           ls_celltab-fieldname  = 'FKIMG'  or
*           ls_celltab-fieldname  = 'VRKME'  or
*           ls_celltab-fieldname  = 'WAERK'  or
*           ls_celltab-fieldname  = 'NETWR'  or
*           ls_celltab-fieldname  = 'ZUONR'  or
*           ls_celltab-fieldname  = 'VBELN'  ).
*
*      ls_celltab-style = cl_gui_alv_grid=>mc_style_disabled +
*                         cl_gui_alv_grid=>mc_style_f4_no.
*      insert ls_celltab into table pt_celltab.
*
*
    IF ls_celltab-fieldname  = 'CHK'.

      ls_celltab-style = cl_gui_alv_grid=>mc_style_enabled.
      INSERT ls_celltab INTO TABLE pt_celltab.

    ELSE.

      ls_celltab-style = cl_gui_alv_grid=>mc_style_disabled +
                         cl_gui_alv_grid=>mc_style_f4_no.
      INSERT ls_celltab INTO TABLE pt_celltab.

    ENDIF.

  ENDLOOP.

ENDFORM.                    " fill_celltab


*&---------------------------------------------------------------------*
*&      Form  fill_color
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM fill_color  CHANGING pt_color  TYPE lvc_t_scol.

  DATA : ls_celltab TYPE lvc_s_styl,
         ls_color   TYPE lvc_s_scol,
         l_mode     TYPE raw4.

  DATA : l_fieldcat TYPE lvc_s_fcat.

  LOOP AT gt_fieldcat INTO l_fieldcat.

    ls_color-fname = l_fieldcat-fieldname.
*// 개요의 체크필드가 비었으면...
    IF gt_display-chk = ''.
*      if   ls_color-fname  = 'MATNR'  or
*           ls_color-fname  = 'ICON'   or
*           ls_color-fname  = 'ARKTX'  or
*           ls_color-fname  = 'KDKG4'  or
*           ls_color-fname  = 'VTEXT'  or
*           ls_color-fname  = 'SPART'  or
*           ls_color-fname  = 'VKBUR'  or
*           ls_color-fname  = 'VKGRP'  or
*           ls_color-fname  = 'POSNR'  or
*           ls_color-fname  = 'FKIMG'  or
*           ls_color-fname  = 'VRKME'  or
*           ls_color-fname  = 'WAERK'  or
*           ls_color-fname  = 'NETWR'  or
*           ls_color-fname  = 'ZUONR'  or
*           ls_color-fname  = 'VBELN'.

      IF ls_color-fname  = 'CHK'.
        ls_color-color-col = 0.
        ls_color-color-int = 0.
        INSERT ls_color INTO TABLE pt_color.
      ELSE.
        ls_color-color-col = 4.
        ls_color-color-int = 1.
        INSERT ls_color INTO TABLE pt_color.
      ENDIF.

*
*      else.
*        ls_color-color-col = 2.
*        ls_color-color-int = 0.
*        insert ls_color into table pt_color.
*
*      endif.

*// 체크되었으면
    ELSEIF gt_display-chk NE ''.
*      if   ls_color-fname  = 'MATNR'  or
*           ls_color-fname  = 'ICON'   or
*           ls_color-fname  = 'ARKTX'  or
*           ls_color-fname  = 'KDKG4'  or
*           ls_color-fname  = 'VTEXT'  or
*           ls_color-fname  = 'SPART'  or
*           ls_color-fname  = 'VKBUR'  or
*           ls_color-fname  = 'VKGRP'  or
*           ls_color-fname  = 'POSNR'  or
*           ls_color-fname  = 'FKIMG'  or
*           ls_color-fname  = 'VRKME'  or
*           ls_color-fname  = 'WAERK'  or
*           ls_color-fname  = 'NETWR'  or
*           ls_color-fname  = 'ZUONR'  or
*           ls_color-fname  = 'VBELN'.
*
      ls_color-color-col = 3.
      ls_color-color-int = 1.
      INSERT ls_color INTO TABLE pt_color.
*
*      elseif ls_color-fname  = 'CHK'.
*
*        ls_color-color-col = 0.
*        ls_color-color-int = 0.
*        insert ls_color into table pt_color.
*      else.
*        ls_color-color-col = 0.
*        ls_color-color-int = 1.
*        insert ls_color into table pt_color.
*      endif.
    ENDIF.

  ENDLOOP.

ENDFORM.                    " fill_color


*&---------------------------------------------------------------------*
*&      Form  display_layout_attribute
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM display_layout_attribute  USING  p_layocat TYPE lvc_s_layo.

*// General display options
  p_layocat-cwidth_opt = 'X'.
  p_layocat-smalltitle = 'X'.
  p_layocat-sel_mode   = 'D'.   "A or D ???
*  p_layocat-edit       = 'E'.
  p_layocat-stylefname = 'CELLTAB'.
  p_layocat-ctab_fname = 'F_COL'.
*   p_layocat-zebra = 'X'.

ENDFORM.                    " display_layout_attribute


*&---------------------------------------------------------------------*
*&      Form  event_handler_register
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM event_handler_register .

  CALL METHOD g_grid->register_edit_event
    EXPORTING
      i_event_id = cl_gui_alv_grid=>mc_evt_modified.

*  CALL METHOD g_grid->register_edit_event
*    EXPORTING
*      i_event_id = cl_gui_alv_grid=>mc_evt_enter.

*// Event Handler 등록
  CREATE OBJECT g_event_handler.

  SET HANDLER g_event_handler->handle_toolbar            FOR g_grid.
  SET HANDLER g_event_handler->handle_user_command       FOR g_grid.
  SET HANDLER g_event_handler->handle_data_changed       FOR g_grid.
  SET HANDLER g_event_handler->handle_data_changed_finished FOR g_grid.
  SET HANDLER g_event_handler->handle_onf4               FOR g_grid.
  SET HANDLER g_event_handler->handle_double_click       FOR g_grid.
  SET HANDLER g_event_handler->handle_hotspot_click      FOR g_grid.
  SET HANDLER g_event_handler->handle_after_user_command FOR g_grid.

ENDFORM.                    " event_handler_register


*&---------------------------------------------------------------------*
*&      Form  build_sort_field
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM build_sort_field .
*// Sort 필드 설정

*  gs_sort-fieldname = 'CHECK'.
*  gs_sort-spos      = '1'.
*  gs_sort-up        = 'X'.
*  gs_sort-subtot    = 'X'.   "SUBTOTAL 집계
*  APPEND gs_sort TO gt_sort.

ENDFORM.                    " build_sort_field


*&---------------------------------------------------------------------*
*&      Form  set_f4_field
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM set_f4_field .
*-- F4 FIELD 등록.
*-- [Caution]필드명을 ABC순으로 등록
**//기산일
*  gs_f4-fieldname  = 'VALUT'.
*  gs_f4-register   = 'X'.
*  APPEND gs_f4 TO gt_f4.
**//만기일
*  gs_f4-fieldname  = 'ZFBDT'.
*  gs_f4-register   = 'X'.
*  APPEND gs_f4 TO gt_f4.
*
*  CALL METHOD g_grid->register_f4_for_fields
*    EXPORTING
*      it_f4 = gt_f4.


ENDFORM.                    " set_f4_field
*&---------------------------------------------------------------------*
*&      Form  alv_grid_display
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM alv_grid_display .
**// 'gs_layout' must at least contain the report-id to allow
*  g_repid = sy-repid.
**// 2.At least field REPORT of this structure has to be filled!
*  alv_variant-report = g_repid.

*// 개요화면을 위한 설정
  lcl_alv_grid=>f_alv = '1'.

  IF gs_variant IS INITIAL.
    gs_variant-report = g_repid.
  ENDIF.

  MOVE-CORRESPONDING gs_variant TO alv_variant.

*// Display
  CALL METHOD g_grid->set_table_for_first_display
    EXPORTING
      is_layout            = gs_layocat
      it_toolbar_excluding = gt_exclude
      i_save               = g_save
      is_variant           = gs_variant
*     i_save               = 'A'   " 전체가능유형.
**                                       'U'   " 특정사용자전용.
**                                       'X'   " 광역전용.
**                                       ' '   " 저장안함.
      i_default            = 'X'   " 레이아웃 사전셋팅 허용.
*
**  LAYOUT   Standard   BCALV_GRID_09  참조.
**  is_variant 레이아웃선택/변경/저장/관리 enable
*     is_variant           = alv_variant
      " 선택 메뉴 display
    CHANGING
      it_outtab            = gt_display[]
      it_sort              = gt_sort
      it_fieldcatalog      = gt_fieldcat[].

ENDFORM.                    " alv_grid_display


*&---------------------------------------------------------------------*
*&      Form  p1000_initial_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM p1000_initial_data .

*//
  CLEAR : gs_header, gv_flag.

  gs_header-spart = p_spart.
  gs_header-uname = sy-uname.
  gs_header-exdat = sy-datum.

*제품군명
  CLEAR : tspat.
  SELECT SINGLE * FROM tspat WHERE spart = p_spart
                              AND  spras = sy-langu.
  IF sy-subrc EQ 0.
    gs_header-vtext = tspat-vtext.
  ENDIF.

  SELECT SINGLE name_text
         FROM  usr21 AS a INNER JOIN adrp AS b
*                          ON A~MANDT = B~CLIENT
                          ON a~persnumber = b~persnumber
         INTO  gs_header-untxt
        WHERE  bname  EQ  gs_header-uname.
  IF sy-subrc  EQ  0.
  ENDIF.

*//현재년/월을 만들어둔다...향후 계속 사용
  CONCATENATE sy-datum+0(4) '0' sy-datum+4(2) INTO g_curyrs.
  CONDENSE g_curyrs.

*//BDC log table clear
  CLEAR: bdc_msg, bdc_msg[].

ENDFORM.                    " p1000_initial_data
*&---------------------------------------------------------------------*
*&      Form  p1000_select_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM p1000_select_data .

  CHECK gv_flag NE 'X'.

  r_fkdat-sign  =  'I'.
  r_fkdat-option  =  'BT'.
  CONCATENATE  p_spmon  '01'  INTO  r_fkdat-low.

  CALL FUNCTION 'RP_LAST_DAY_OF_MONTHS'
    EXPORTING
      day_in            = r_fkdat-low
    IMPORTING
      last_day_of_month = r_fkdat-high
    EXCEPTIONS
      day_in_no_date    = 1
      OTHERS            = 2.

  gv_fkdat = r_fkdat-high.
  APPEND  r_fkdat.

  CLEAR: gt_display, gt_display[].

  PERFORM select_order_billing_data.

  PERFORM select_delivery_data.

  PERFORM select_noslip_data.

  PERFORM collect_data_sum  USING ' '.

** 상세내역은 문서Currency로 Display되기때문에 변화없이 한다.
  PERFORM collect_data_sum_copy USING 'X'.

ENDFORM.                    " p1000_select_data

*&---------------------------------------------------------------------*
*&      Form  p2000_process_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM p2000_process_data USING p_conv.

  DATA : lv_flag,
         lv_flag2,
         lv_chk,
         lv_chk2.
  DATA : ls_cbilltax(1).
  CHECK gv_flag NE 'X'.   "에러아님

  CLEAR : gt_itab, gt_itab[],
          gt_display, gt_display[].

  SORT : lt_display,
         gt_billdata,
         gt_deldata,
         gt_noslip,
         gt_sum.

*-- 납품 POD 정보기준 POD 확정여부 정보 구성 2025.02.13 - Start
*  DATA : LT_POD_CHK TYPE GTY_T_POD_CHK.

*  PERFORM CHK_POD_FROM_DO           TABLES   LT_DISPLAY2
*                                    CHANGING LT_POD_CHK.

*-- 납품 POD 정보기준 POD 확정여부 정보 구성 2025.02.13 - End

  LOOP AT lt_display.
    MOVE-CORRESPONDING lt_display TO gt_itab.
    IF p_conv NE 'X'.
      gt_itab-waerk = 'KRW'.
    ENDIF.
    CLEAR :  gt_itab-ctxt,
             gt_itab-cstop,
             gt_itab-compl,
             gt_itab-vbeln_a,
             gt_itab-zflag1,
             gt_itab-werks,
             gt_itab-zflag2,
             gt_itab-billseq,
             gt_itab-billstat,
             gt_itab-cbilltax.


    gt_itab-netwr_e = gt_itab-netwr_a + gt_itab-netwr_b +
    gt_itab-netwr_c + gt_itab-netwr_d.
    gt_itab-mwsbk_e = gt_itab-mwsbk_a + gt_itab-mwsbk_b +
    gt_itab-mwsbk_c + gt_itab-mwsbk_d.
    gt_itab-sumamt_e = gt_itab-sumamt_a + gt_itab-sumamt_b +
    gt_itab-sumamt_c + gt_itab-sumamt_d.

    COLLECT gt_itab. CLEAR gt_itab.
  ENDLOOP.

  LOOP AT gt_itab.
    g_index = sy-tabix.

    LOOP AT lt_display WHERE   branch = gt_itab-branch
                        AND    vkbur  = gt_itab-vkbur
                        AND    vkgrp  = gt_itab-vkgrp
                        AND    kdkg4  = gt_itab-kdkg4
                        AND    kunnr  = gt_itab-kunnr
                        AND    ctxt   NE space.
      gt_itab-ctxt = lt_display-ctxt.
      EXIT.
    ENDLOOP.

    LOOP AT lt_display WHERE   branch = gt_itab-branch
                        AND    vkbur  = gt_itab-vkbur
                        AND    vkgrp  = gt_itab-vkgrp
                        AND    kdkg4  = gt_itab-kdkg4
                        AND    kunnr  = gt_itab-kunnr
                        AND    cstop  NE space.

      gt_itab-vbeln_a = lt_display-vbeln_a.
      gt_itab-cstop = lt_display-cstop.
      EXIT.
    ENDLOOP.

** Add
    LOOP AT lt_display WHERE   branch = gt_itab-branch
                        AND    vkbur  = gt_itab-vkbur
                        AND    vkgrp  = gt_itab-vkgrp
                        AND    kdkg4  = gt_itab-kdkg4
                        AND    kunnr  = gt_itab-kunnr
                        AND    zflag1 NE space
                        AND    vbeln_a NE space.

      gt_itab-vbeln_a = lt_display-vbeln_a.
      gt_itab-zflag1 = lt_display-zflag1.
      EXIT.
    ENDLOOP.

** Add
    LOOP AT lt_display WHERE   branch = gt_itab-branch
                        AND    vkbur  = gt_itab-vkbur
                        AND    vkgrp  = gt_itab-vkgrp
                        AND    kdkg4  = gt_itab-kdkg4
                        AND    kunnr  = gt_itab-kunnr
                        AND    zflag2 NE space
                        AND    vbeln_a NE space.

      gt_itab-vbeln_a = lt_display-vbeln_a.
      gt_itab-zflag2 = lt_display-zflag2.
      EXIT.
    ENDLOOP.

** 전자세금계산서 상태
    CLEAR: ls_cbilltax.
    LOOP AT lt_display WHERE   branch = gt_itab-branch
                        AND    vkbur  = gt_itab-vkbur
                        AND    vkgrp  = gt_itab-vkgrp
                        AND    kdkg4  = gt_itab-kdkg4
                        AND    kunnr  = gt_itab-kunnr
                        AND    cbilltax  NE space.

      IF lt_display-cbilltax = 'Y'
      AND ls_cbilltax NE 'N'.
        ls_cbilltax = 'Y'.
      ELSE.
        ls_cbilltax = 'N'.
      ENDIF.

    ENDLOOP.

    IF ls_cbilltax IS NOT INITIAL.
      gt_itab-cbilltax = ls_cbilltax.
    ENDIF.

    MODIFY gt_itab INDEX g_index.

  ENDLOOP.

  IF p_spmon => '202507'.
    SELECT * INTO TABLE @DATA(lt_1080)
      FROM zgtsdt1080
     WHERE spmon EQ @p_spmon
       AND bupla IN @s_branch
       AND vtweg IN @s_vtweg
       AND vkgrp IN @s_vkgrp
       AND kdkg4 IN @s_kdkg4
       AND kunnr IN @s_kunnr
       AND vkbur IN @s_vkbur.
  ENDIF.

  LOOP AT gt_itab.
    g_index = sy-tabix.

    CLEAR : lv_chk, lv_chk2.
    MOVE-CORRESPONDING  gt_itab TO gt_display.

    SELECT SINGLE name INTO gt_display-text01 FROM j_1bbranch
                               WHERE branch = gt_itab-branch
                                AND  bukrs = p_vkorg.

    SELECT SINGLE bezei INTO gt_display-text02 FROM tvkbt
                               WHERE vkbur = gt_itab-vkbur
                                AND  spras = sy-langu.

    SELECT SINGLE bezei INTO gt_display-text03 FROM tvgrt
                               WHERE vkgrp = gt_itab-vkgrp
                                AND  spras = sy-langu.

    SELECT SINGLE vtext INTO gt_display-text04 FROM tvtwt
                               WHERE vtweg = gt_itab-vtweg
                                AND  spras = sy-langu.

    SELECT SINGLE vtext INTO gt_display-text05 FROM tvkggt
                               WHERE kdkgr = gt_itab-kdkg4
                                AND  spras = sy-langu.
    IF p_spmon => '202507'.
**********************************************************************
      READ TABLE lt_1080 INTO DATA(ls_1080) WITH KEY
                                            bupla = gt_itab-branch
                                            vkbur = gt_itab-vkbur
                                            vtweg = gt_itab-vtweg
                                            vkgrp = gt_itab-vkgrp
                                            kdkg4 = gt_itab-kdkg4
                                            kunnr = gt_itab-kunnr.
      IF sy-subrc = 0.
        gt_display-compl = ls_1080-sales_closing.
      ELSE.
        gt_display-compl = 'N'.
      ENDIF.
**********************************************************************
    ELSE.

      IF gt_display-ctxt EQ space AND gt_display-cstop EQ space.

        READ TABLE gt_billdata WITH KEY branch = gt_itab-branch
                                  vkbur  = gt_itab-vkbur
                                  vkgrp  = gt_itab-vkgrp
                                  kdkg4  = gt_itab-kdkg4
                                  kunnr  = gt_itab-kunnr
                                  BINARY SEARCH.
        IF sy-subrc NE 0.
          lv_chk = 'X'.
        ENDIF.

        READ TABLE gt_deldata WITH KEY     branch = gt_itab-branch
                                           vkbur  = gt_itab-vkbur
                                           vkgrp  = gt_itab-vkgrp
                                           kdkg4  = gt_itab-kdkg4
                                           kunnr  = gt_itab-kunnr.
*                                         binary search.
        IF sy-subrc NE 0.
          lv_chk2 = 'X'.
        ENDIF.

** 전표미생성금액(netwr_b)/계산서미발행금액(netwr_c) 조건에 Add
        IF lv_chk = 'X' AND lv_chk2 = 'X' AND
           gt_itab-netwr_b = 0 AND gt_itab-netwr_c = 0 AND
           gt_itab-zflag1 IS INITIAL AND   " 무상빌링미처리
           gt_itab-zflag2 IS INITIAL.      " 대금청구계획보류
          gt_display-compl = 'Y'.

          LOOP AT lt_display WHERE   branch = gt_itab-branch
                             AND vkbur  = gt_itab-vkbur
                             AND vkgrp  = gt_itab-vkgrp
                             AND kdkg4  = gt_itab-kdkg4
                             AND kunnr  = gt_itab-kunnr
                             AND netwr_b <> 0.

            gt_display-compl = 'N'.

          ENDLOOP.

          LOOP AT lt_display WHERE   branch = gt_itab-branch
                             AND vkbur  = gt_itab-vkbur
                             AND vkgrp  = gt_itab-vkgrp
                             AND kdkg4  = gt_itab-kdkg4
                             AND kunnr  = gt_itab-kunnr
                             AND netwr_c <> 0.

            gt_display-compl = 'N'.

          ENDLOOP.

        ELSE.
          gt_display-compl = 'N'.
        ENDIF.

      ELSE.
        gt_display-compl = 'N'.
      ENDIF.

    ENDIF.

    IF gt_display-compl = 'Y'.
      gt_display-pod_stat = icon_led_green.
    ELSE.
      gt_display-pod_stat = icon_led_yellow.
    ENDIF.

    CLEAR : kna1.
    SELECT SINGLE * FROM kna1 WHERE kunnr = gt_display-kunnr.
    IF sy-subrc EQ 0.
      gt_display-name1 = kna1-name1.
    ENDIF.

    APPEND : gt_display.
    CLEAR : gt_display, gt_itab.

  ENDLOOP.

  IF p_compl EQ 'Y'.
    DELETE gt_display WHERE compl = 'N'.
  ELSEIF  p_compl EQ 'N'.
    DELETE gt_display WHERE compl = 'Y'.
  ENDIF.

  IF p_cbill EQ 'Y'.
    DELETE gt_display WHERE cbilltax NE 'Y'.
  ELSEIF  p_cbill EQ 'N'.
    DELETE gt_display WHERE cbilltax EQ 'Y'.
  ENDIF.

  SORT gt_display.


  DATA: lv_compl(1).
  CLEAR: lv_compl.


  DATA : lt_0201 TYPE TABLE OF zlet0201 WITH HEADER LINE.

  SELECT SINGLE mandt
    INTO sy-mandt
    FROM zlet0201
    WHERE zcodh = 'CL01'
    AND      zcodi = p_spmon.
  IF sy-subrc = 0.
    SELECT *
     INTO CORRESPONDING FIELDS OF TABLE lt_0201
     FROM zlet0201
     WHERE zcodh = 'CL02'.

    LOOP AT lt_0201.
      CLEAR : lv_compl.
      LOOP AT lt_display2 WHERE vbeln = lt_0201-zcodi.
        lv_compl = 'X'.
        EXIT.
      ENDLOOP.

      CHECK lv_compl = 'X'.
      LOOP AT gt_display WHERE branch = lt_display2-branch
                                            AND vkbur  = lt_display2-vkbur
                                            AND vkgrp  = lt_display2-vkgrp
                                            AND vtweg  = lt_display2-vtweg
                                            AND kdkg4  = lt_display2-kdkg4
                                            AND kunnr  = lt_display2-kunnr.
        gt_display-compl = 'Y'.
        MODIFY gt_display.
      ENDLOOP.
    ENDLOOP.
  ENDIF.

ENDFORM.                    " p2000_process_data
*&---------------------------------------------------------------------*
*&      Form  select_all_item
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM select_all_item .

  IF g_check       = 'X'.

    g_check        = ''.
    gt_display-chk = ''.

    MODIFY gt_display TRANSPORTING chk WHERE chk  EQ 'X'
                                         AND flag NE 'X'.

  ELSE.

    gt_display-chk = 'X'.
    g_check        = 'X'.

    MODIFY gt_display TRANSPORTING chk WHERE chk  EQ ''
                                         AND flag NE 'X'.

  ENDIF.

ENDFORM.                    " select_all_item


*&---------------------------------------------------------------------*
*&      Form  set_field-cat_tab01
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM set_field-cat_tab01 .


** billing 미처리
*  netwr_a like vbak-netwr,
*  mwsbk_a like vbrk-mwsbk,  "tax
*  sumamt_a like vbak-netwr,
** 전표 미생성
*  netwr_b like vbak-netwr,
*  mwsbk_b like vbrk-mwsbk,  "tax
*  sumamt_b like vbak-netwr,
** 계산서미발행
*  netwr_c like vbak-netwr,
*  mwsbk_c like vbrk-mwsbk,  "tax
*  sumamt_c like vbak-netwr,
** 계산서발행
*  netwr_d like vbak-netwr,
*  mwsbk_d like vbrk-mwsbk,  "tax
*  sumamt_d like vbak-netwr,
** 총합
*  netwr_e like vbak-netwr,
*  mwsbk_e like vbrk-mwsbk,  "tax
*  sumamt_e like vbak-netwr,
** 적송
*  netwr_f like vbak-netwr,
*  mwsbk_f like vbrk-mwsbk,  "tax
*  sumamt_f like vbak-netwr,
** 적송 미완료
*  cflag(1),
**보류문서
*  cstop(1),

  PERFORM fill_field_catalogs
      USING:
*-- POD 확정여부 Icon 필드 추가 2025.02.13 - Start
      'S' 'FIELDNAME'   'POD_STAT',
      ' ' 'COLTEXT'     'POD',
      ' ' 'JUST'        'C',
      ' ' 'ICON'        abap_true,
      'E' 'KEY'         'X',
*-- POD 확정여부 Icon 필드 추가 2025.02.13 - End

      'S' 'FIELDNAME'   'CHK',
      ' ' 'COLTEXT'     '선택',
      ' ' 'JUST'        'C',
      ' ' 'CHECKBOX'    'X',
      ' ' 'EDIT'        'X',
      'E' 'KEY'         'X',

*      'S' 'FIELDNAME'   'POD',
*      ' ' 'COLTEXT'     'POD',
*      ' ' 'JUST'        'C',
*      ' ' 'CHECKBOX'    'X',
*      'E' 'KEY'         'X',
*      'E' 'OUTPUTLEN'   '4',

      'S' 'FIELDNAME'   'BRANCH',
      ' ' 'COLTEXT'     '사업장',
      ' ' 'JUST'        'L',
      ' ' 'NO_ZERO'     'X',
      'E' 'KEY'         'X',
*      'E' 'OUTPUTLEN'   '06',

      'S' 'FIELDNAME'   'TEXT01',
      ' ' 'COLTEXT'     '사업장명',
      ' ' 'JUST'        'L',
      'E' 'NO_OUT'      'X',
*      'E' 'OUTPUTLEN'   '20',

      'S' 'FIELDNAME'   'VKBUR',
      ' ' 'COLTEXT'     '영업팀',
      ' ' 'JUST'        'L',
      ' ' 'NO_ZERO'     'X',
      'E' 'KEY'         'X',
*      'E' 'OUTPUTLEN'   '06',

      'S' 'FIELDNAME'   'TEXT02',
      ' ' 'COLTEXT'     '영업팀명',
      ' ' 'JUST'        'L',
      'E' 'NO_OUT'      'X',
*      'E' 'OUTPUTLEN'   '20',

      'S' 'FIELDNAME'   'VKGRP',
      ' ' 'COLTEXT'     '영업그룹',
      ' ' 'JUST'        'L',
      ' ' 'NO_ZERO'     'X',
      'E' 'KEY'         'X',
*      'E' 'OUTPUTLEN'   '04',

      'S' 'FIELDNAME'   'TEXT03',
      ' ' 'COLTEXT'     '영업그룹명',
      ' ' 'JUST'        'L',
      'E' 'NO_OUT'      'X',
*      'E' 'OUTPUTLEN'   '20',


      'S' 'FIELDNAME'   'KDKG4',
      ' ' 'COLTEXT'     '수출구분',
      ' ' 'JUST'        'L',
      'E' 'KEY'         'X',
*      'E' 'OUTPUTLEN'   '02',

      'S' 'FIELDNAME'   'TEXT05',
      ' ' 'COLTEXT'     '수출구분명',
      ' ' 'JUST'        'L',
      'E' 'NO_OUT'      'X',
*      'E' 'OUTPUTLEN'   '20',

      'S' 'FIELDNAME'   'KUNNR',
      ' ' 'COLTEXT'     '고객',
      ' ' 'JUST'        'L',
      ' ' 'NO_ZERO'     'X',
      'E' 'KEY'         'X',
*      'E' 'OUTPUTLEN'   '10',

      'S' 'FIELDNAME'   'NAME1',
      ' ' 'COLTEXT'     '고객명',
      ' ' 'JUST'        'L',
      ' ' 'NO_ZERO'     'X',
      'E' 'KEY'         'X',
*      'E' 'OUTPUTLEN'   '30',

      'S' 'FIELDNAME'   'COMPL',
      ' ' 'COLTEXT'     '마감완료',
      ' ' 'JUST'        'C',
      ' ' 'NO_ZERO'     'X',
*          ' ' 'HOTSPOT'     'X',
      ' ' 'KEY'         'X',
      'E' 'OUTPUTLEN'   '02',

      'S' 'FIELDNAME'   'WAERK',
      ' ' 'COLTEXT'     '통화단위',
      ' ' 'JUST'        'L',
      ' ' 'NO_ZERO'     'X',
*          ' ' 'HOTSPOT'     'X',
*          ' ' 'KEY'         'X',
      'E' 'OUTPUTLEN'   '04',

*      'S' 'FIELDNAME'   'NETWR_POD',
*      ' ' 'COLTEXT'     '운송중재고금액',
*      ' ' 'JUST'        'R',
*      ' ' 'NO_ZERO'     'X',
*      ' ' 'CFIELDNAME'  'WAERK',
*      'E' 'OUTPUTLEN'   '15',


      'S' 'FIELDNAME'   'NETWR_A',
      ' ' 'COLTEXT'     '금액(Billing 미처리)',
      ' ' 'JUST'        'R',
      ' ' 'NO_ZERO'     'X',
      ' ' 'CFIELDNAME'  'WAERK',
      'E' 'OUTPUTLEN'   '15',

      'S' 'FIELDNAME'   'MWSBK_A',
      ' ' 'COLTEXT'     'Tax(Billing 미처리)',
      ' ' 'JUST'        'R',
      ' ' 'NO_ZERO'     'X',
      ' ' 'CFIELDNAME'  'WAERK',
      'E' 'OUTPUTLEN'   '15',

      'S' 'FIELDNAME'   'SUMAMT_A',
      ' ' 'COLTEXT'     '합계(Billing 미처리)',
      ' ' 'JUST'        'R',
      ' ' 'NO_ZERO'     'X',
      ' ' 'CFIELDNAME'  'WAERK',
      'E' 'OUTPUTLEN'   '15',

      'S' 'FIELDNAME'   'ZFLAG1',
      ' ' 'COLTEXT'     '무상빌링처리',
      ' ' 'JUST'        'C',
      'E' 'OUTPUTLEN'   '12',

      'S' 'FIELDNAME'   'NETWR_B',
      ' ' 'COLTEXT'     '금액(전표미생성)',
      ' ' 'JUST'        'R',
      ' ' 'NO_ZERO'     'X',
      ' ' 'CFIELDNAME'  'WAERK',
      'E' 'OUTPUTLEN'   '15',

      'S' 'FIELDNAME'   'MWSBK_B',
      ' ' 'COLTEXT'     'Tax(전표미생성)',
      ' ' 'JUST'        'R',
      ' ' 'NO_ZERO'     'X',
      ' ' 'CFIELDNAME'  'WAERK',
      'E' 'OUTPUTLEN'   '15',

      'S' 'FIELDNAME'   'SUMAMT_B',
      ' ' 'COLTEXT'     '합계(전표미생성)',
      ' ' 'JUST'        'R',
      ' ' 'NO_ZERO'     'X',
      ' ' 'CFIELDNAME'  'WAERK',
      'E' 'OUTPUTLEN'   '15',

      'S' 'FIELDNAME'   'NETWR_C',
      ' ' 'COLTEXT'     '금액(계산서미발행)',
      ' ' 'JUST'        'R',
      ' ' 'NO_ZERO'     'X',
      ' ' 'CFIELDNAME'  'WAERK',
      'E' 'OUTPUTLEN'   '15',

      'S' 'FIELDNAME'   'MWSBK_C',
      ' ' 'COLTEXT'     'Tax(계산서미발행)',
      ' ' 'JUST'        'R',
      ' ' 'NO_ZERO'     'X',
      ' ' 'CFIELDNAME'  'WAERK',
      'E' 'OUTPUTLEN'   '15',

      'S' 'FIELDNAME'   'SUMAMT_C',
      ' ' 'COLTEXT'     '합계(계산서미발행)',
      ' ' 'JUST'        'R',
      ' ' 'NO_ZERO'     'X',
      ' ' 'CFIELDNAME'  'WAERK',
      'E' 'OUTPUTLEN'   '15',

      'S' 'FIELDNAME'   'NETWR_D',
      ' ' 'COLTEXT'     '금액(계산서발행)',
      ' ' 'JUST'        'R',
      ' ' 'NO_ZERO'     'X',
      ' ' 'CFIELDNAME'  'WAERK',
      'E' 'OUTPUTLEN'   '15',

      'S' 'FIELDNAME'   'MWSBK_D',
      ' ' 'COLTEXT'     'Tax(계산서발행)',
      ' ' 'JUST'        'R',
      ' ' 'NO_ZERO'     'X',
      ' ' 'CFIELDNAME'  'WAERK',
      'E' 'OUTPUTLEN'   '15',

      'S' 'FIELDNAME'   'SUMAMT_D',
      ' ' 'COLTEXT'     '합계(계산서발행)',
      ' ' 'JUST'        'R',
      ' ' 'NO_ZERO'     'X',
      ' ' 'CFIELDNAME'  'WAERK',
      'E' 'OUTPUTLEN'   '15',

      'S' 'FIELDNAME'   'NETWR_E',
      ' ' 'COLTEXT'     '금액(총합)',
      ' ' 'JUST'        'R',
      ' ' 'NO_ZERO'     'X',
      ' ' 'CFIELDNAME'  'WAERK',
      'E' 'OUTPUTLEN'   '15',

      'S' 'FIELDNAME'   'MWSBK_E',
      ' ' 'COLTEXT'     'Tax(총합)',
      ' ' 'JUST'        'R',
      ' ' 'NO_ZERO'     'X',
      ' ' 'CFIELDNAME'  'WAERK',
      'E' 'OUTPUTLEN'   '15',

      'S' 'FIELDNAME'   'SUMAMT_E',
      ' ' 'COLTEXT'     '합계(총합)',
      ' ' 'JUST'        'R',
      ' ' 'NO_ZERO'     'X',
      ' ' 'CFIELDNAME'  'WAERK',
      'E' 'OUTPUTLEN'   '15',

*      'S' 'FIELDNAME'   'NETWR_F',
*      ' ' 'COLTEXT'     '금액(적송)',
*      ' ' 'JUST'        'R',
*      ' ' 'NO_ZERO'     'X',
*      ' ' 'CFIELDNAME'  'WAERK',
*      'E' 'OUTPUTLEN'   '15',
*
*      'S' 'FIELDNAME'   'MWSBK_F',
*      ' ' 'COLTEXT'     'Tax(적송)',
*      ' ' 'JUST'        'R',
*      ' ' 'NO_ZERO'     'X',
*      ' ' 'CFIELDNAME'  'WAERK',
*      'E' 'OUTPUTLEN'   '15',
*
*      'S' 'FIELDNAME'   'SUMAMT_F',
*      ' ' 'COLTEXT'     '합계(적송)',
*      ' ' 'JUST'        'R',
*      ' ' 'NO_ZERO'     'X',
*      ' ' 'CFIELDNAME'  'WAERK',
*      'E' 'OUTPUTLEN'   '15',
*
*      'S' 'FIELDNAME'   'CTXT',
*      ' ' 'COLTEXT'     '적송미완료',
*      ' ' 'JUST'        'L',
*      'E' 'OUTPUTLEN'   '06',

      'S' 'FIELDNAME'   'ZFLAG2',
      ' ' 'COLTEXT'     '대금청구계획보류',
      ' ' 'JUST'        'C',
      'E' 'OUTPUTLEN'   '12',

      'S' 'FIELDNAME'   'NETWR_G',
      ' ' 'COLTEXT'     '금액(전자세금)',
      ' ' 'JUST'        'R',
      ' ' 'NO_ZERO'     'X',
      ' ' 'CFIELDNAME'  'WAERK',
      'E' 'OUTPUTLEN'   '15',

      'S' 'FIELDNAME'   'MWSBK_G',
      ' ' 'COLTEXT'     'Tax(전자세금)',
      ' ' 'JUST'        'R',
      ' ' 'NO_ZERO'     'X',
      ' ' 'CFIELDNAME'  'WAERK',
      'E' 'OUTPUTLEN'   '15',

      'S' 'FIELDNAME'   'SUMAMT_G',
      ' ' 'COLTEXT'     '합계(전자세금)',
      ' ' 'JUST'        'R',
      ' ' 'NO_ZERO'     'X',
      ' ' 'CFIELDNAME'  'WAERK',
      'E' 'OUTPUTLEN'   '15',

      'S' 'FIELDNAME'   'CBILLTAX',
      ' ' 'COLTEXT'     '전송상태',
      ' ' 'JUST'        'L',
      'E' 'OUTPUTLEN'   '04',

      'S' 'FIELDNAME'   'CSTOP',
      ' ' 'COLTEXT'     '보류문서',
      ' ' 'JUST'        'L',
      'E' 'OUTPUTLEN'   '04',

      'S' 'FIELDNAME'   'FBUDA',
      ' ' 'COLTEXT'     '서비스제공일',
      ' ' 'JUST'        'L',
      'E' 'OUTPUTLEN'   '08'.

ENDFORM.                    " set_field-cat_tab01

*&---------------------------------------------------------------------*
*&      Form  toobar_pros_tab01
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM toobar_pros_tab01  USING   r_object
                                TYPE REF TO cl_alv_event_toolbar_set
                                r_interactive
                                ls_toolbar TYPE stb_button.
*// 내수/로칼 Billing
  CLEAR ls_toolbar.
  MOVE 'ZF01'               TO  ls_toolbar-function.
  MOVE icon_display_note  TO  ls_toolbar-icon.
  MOVE '내수 Billing'           TO  ls_toolbar-quickinfo.
  MOVE '내수 Billing'          TO  ls_toolbar-text.
  MOVE ' '                  TO  ls_toolbar-disabled.
  APPEND ls_toolbar         TO  r_object->mt_toolbar.

ENDFORM.                    " toobar_pros_tab01

*&---------------------------------------------------------------------*
*&      Form  toobar_pros_tab02
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM toobar_pros_tab02  USING   r_object
                                TYPE REF TO cl_alv_event_toolbar_set
                                r_interactive
                                ls_toolbar TYPE stb_button.

*// 계산서
  CLEAR ls_toolbar.
  MOVE 'ZF02'               TO  ls_toolbar-function.
  MOVE icon_calculation  TO  ls_toolbar-icon.
  MOVE '계산서'             TO  ls_toolbar-quickinfo.
  MOVE '계산서'             TO  ls_toolbar-text.
  MOVE ' '                  TO  ls_toolbar-disabled.
  APPEND ls_toolbar         TO  r_object->mt_toolbar.

ENDFORM.                    " toobar_pros_tab01
*&---------------------------------------------------------------------*
*&      Form  toobar_pros_tab03
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM toobar_pros_tab03  USING   r_object
                                TYPE REF TO cl_alv_event_toolbar_set
                                r_interactive
                                ls_toolbar TYPE stb_button.
*// 적송
  CLEAR ls_toolbar.
  MOVE 'ZF03'               TO  ls_toolbar-function.
  MOVE icon_transport  TO  ls_toolbar-icon.
  MOVE '운송중재고'             TO  ls_toolbar-quickinfo.
  MOVE '운송중재고'             TO  ls_toolbar-text.
  MOVE ' '                  TO  ls_toolbar-disabled.
  APPEND ls_toolbar         TO  r_object->mt_toolbar.

ENDFORM.                    " toobar_pros_tab01
*&---------------------------------------------------------------------*
*&      Form  toobar_pros_tab04
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM toobar_pros_tab04  USING   r_object
                                TYPE REF TO cl_alv_event_toolbar_set
                                r_interactive
                                ls_toolbar TYPE stb_button.


*// 보류해제
  CLEAR ls_toolbar.
  MOVE 'ZF04'               TO  ls_toolbar-function.
  MOVE icon_release_column  TO  ls_toolbar-icon.
  MOVE '보류해제'             TO  ls_toolbar-quickinfo.
  MOVE '보류해제'             TO  ls_toolbar-text.
  MOVE ' '                  TO  ls_toolbar-disabled.
  APPEND ls_toolbar         TO  r_object->mt_toolbar.

ENDFORM.                    " toobar_pros_tab01
*&---------------------------------------------------------------------*
*&      Form  toobar_pros_tab05
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM toobar_pros_tab05  USING   r_object
                                TYPE REF TO cl_alv_event_toolbar_set
                                r_interactive
                                ls_toolbar TYPE stb_button.


*// 외화금액
  CLEAR ls_toolbar.
  MOVE 'ZF05'               TO  ls_toolbar-function.
  MOVE icon_company_code  TO  ls_toolbar-icon.
*  move '외화금액'             to  ls_toolbar-quickinfo.
*  move '외화금액'             to  ls_toolbar-text.
  MOVE '금액변경(원화<->외화)' TO  ls_toolbar-quickinfo.
  MOVE '금액변경(원화<->외화)' TO  ls_toolbar-text.
  MOVE ' '                  TO  ls_toolbar-disabled.
  APPEND ls_toolbar         TO  r_object->mt_toolbar.

ENDFORM.                    " toobar_pros_tab01
*&---------------------------------------------------------------------*
*&      Form  toobar_pros_tab03
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM toobar_pros_tab06  USING   r_object
                                TYPE REF TO cl_alv_event_toolbar_set
                                r_interactive
                                ls_toolbar TYPE stb_button.


*// L/C별리스트
  CLEAR ls_toolbar.
  MOVE 'ZF06'               TO  ls_toolbar-function.
  MOVE icon_rental_agreement  TO  ls_toolbar-icon.
  MOVE 'L/C별리스트'        TO  ls_toolbar-quickinfo.
  MOVE 'L/C별리스트'        TO  ls_toolbar-text.
  MOVE ' '                  TO  ls_toolbar-disabled.
  APPEND ls_toolbar         TO  r_object->mt_toolbar.

ENDFORM.                    " toobar_pros_tab01

*&---------------------------------------------------------------------*
*&      Form  toobar_pros_tab07
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM toobar_pros_tab07  USING   r_object
                                TYPE REF TO cl_alv_event_toolbar_set
                                r_interactive
                                ls_toolbar TYPE stb_button.


*// 상세리스트
  CLEAR ls_toolbar.
  MOVE 'ZF07'               TO  ls_toolbar-function.
  MOVE icon_rental_agreement  TO  ls_toolbar-icon.
  MOVE '상세리스트'         TO  ls_toolbar-quickinfo.
  MOVE '상세리스트'         TO  ls_toolbar-text.
  MOVE ' '                  TO  ls_toolbar-disabled.
  APPEND ls_toolbar         TO  r_object->mt_toolbar.

ENDFORM.                    " toobar_pros_tab07

*&---------------------------------------------------------------------*
*&      Form  control_popup_msg
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM control_popup_msg  USING    p_quest.


* 처리대상선택 팝업
  READ TABLE gt_display WITH KEY chk = 'X'.
  IF sy-subrc  NE  0.
    MESSAGE i000 WITH '처리대상을 선택하십시요'.
    g_err = 'Y'.   "에러
    EXIT.
  ENDIF.

* 처리완료건이 있는지 확인
  READ TABLE gt_display WITH KEY chk  = 'X'
                                 flag = 'X'.   "처리완료건
  IF sy-subrc  EQ  0.
    MESSAGE i000 WITH '현재기간내 처리완료건이 존재합니다.'.
    g_err = 'Y'.   "에러
    EXIT.
  ENDIF.

* 최종처리일자가 현재년월과 같다면 처리완료된건으로...기표불가능
*  READ TABLE gt_display WITH KEY chk    = 'X'
*                                 lstdat = g_curyrs.
*  IF sy-subrc  EQ  0.
*    MESSAGE i000 WITH '현재기간내 처리완료건이 존재합니다.'.
*    g_err = 'Y'.   "에러
*    EXIT.
*  ENDIF.


* 실행모드/업데이트모드 설정.....................
  CLEAR g_flag.
  CALL SCREEN 200 STARTING AT 40 1
                    ENDING AT 90 3.
  IF g_flag EQ 'X'.   "취소이면...
    g_err = 'Y'.
    EXIT.
  ENDIF.

  DATA : l_answer.
  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      text_question = p_quest
      text_button_1 = TEXT-yes
      text_button_2 = TEXT-noo
    IMPORTING
      answer        = l_answer.

  IF l_answer  NE  '1'.
    g_err = 'Y'.   "에러
  ENDIF.

ENDFORM.                    " control_popup_msg

*&---------------------------------------------------------------------*
*&      Form  p2110_calculate_values
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM p2110_calculate_values .
  DATA: l_untcur        LIKE bseg-dmbtr.
  CLEAR l_untcur.       "일 보험료

*  if g_index = 6.
*    break-point.
*  endif.



*   기처리 플래그에 'X' 달아준다.
  gt_display-flag = 'X'.
*   '정상' 아이콘 입력한다.
*  gt_display-icon = icon_green_light.


ENDFORM.                    " p2110_calculate_values


*&---------------------------------------------------------------------*
*&      Form  p2110_cal_perid
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM p2110_cal_perid .
  DATA: l_frdate        LIKE sy-datum.
  CLEAR: l_frdate.



ENDFORM.                    " p2110_cal_perid


*&---------------------------------------------------------------------*
*&      Form  insert_upload_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM insert_upload_data USING VALUE(p_txt).
*  check not gt_upload[] is initial.
  CONDENSE p_txt.
*  modify zfit0017 from table gt_upload.
  IF sy-subrc  NE  0.
    MESSAGE s035 WITH p_txt.   "에러발생
    ROLLBACK WORK.
  ELSE.
    MESSAGE s034 WITH p_txt.   "성공
    COMMIT WORK.
  ENDIF.

ENDFORM.                    " insert_upload_data


*&---------------------------------------------------------------------*
*&      Form  control_msg_bdclog
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM control_msg_bdclog .

*  if gt_fb01[] is initial.    "BDC처리 전
*    g_err = 'Y'.
*    message i000 with 'BDC Log Message가 존재하지 않습니다.'.
*    exit.
*  endif.

ENDFORM.                    " control_msg_bdclog


*&---------------------------------------------------------------------*
*&      Form  structuring_bdc_msg
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM structuring_bdc_msg .
*  loop at gt_fb01.
*
*    move: gt_fb01-text       to bdc_msg-text,
*          gt_fb01-subrc      to bdc_msg-msgtyp.
*
*
*    if g_activetab = 'PUSH1'.
*      bdc_msg-item = gt_fb01-zuonr.
*    else.
*      bdc_msg-item = gt_fb01-xblnr.
*    endif.
*
*    append bdc_msg.   clear bdc_msg.
*
*  endloop.

ENDFORM.                    " structuring_bdc_msg


*&---------------------------------------------------------------------*
*&      Form  bdc_log_display
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM bdc_log_display .
  CHECK NOT bdc_msg[] IS INITIAL.

  CALL FUNCTION 'MESSAGES_INITIALIZE'.

  LOOP AT bdc_msg.

    CALL FUNCTION 'MESSAGE_STORE'
      EXPORTING
        arbgb  = 'ZSD1'
        msgty  = bdc_msg-msgtyp   "Icon
        msgv1  = bdc_msg-text     "Message text
        msgv2  = bdc_msg-text+98(02)
*       msgv3  = bdc_msg-text
*       msgv4  = itab_mesg-msgv4
        txtnr  = '002'
        zeile  = bdc_msg-item
      EXCEPTIONS
        OTHERS = 1.

  ENDLOOP.

  CALL FUNCTION 'MESSAGES_SHOW'
    EXPORTING
      i_use_grid          = 'X'
*     i_amodal_window     = 'X'
      object              = '※ BDC Log Data Display'
      show_linno_text_len = '0'
    EXCEPTIONS
      inconsistent_range  = 1
      no_messages         = 2
      OTHERS              = 3.


ENDFORM.                    " bdc_log_display



*&---------------------------------------------------------------------*
*&      Form  p0000_entries_pepst
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM p0000_entries_pepst  USING    p_spmon VALUE(p_dynprofield).

  DATA: dynpro_values TYPE TABLE OF dynpread WITH HEADER LINE.
  DATA: pronm TYPE d020s-prog,
        dynnr TYPE d020s-dnum,
        clmon TYPE isellist-month,
        rcode TYPE sy-ucomm.
  DATA: l_field              LIKE help_info-dynprofld.

  MOVE p_dynprofield    TO l_field.
  MOVE l_field TO dynpro_values-fieldname.
  APPEND dynpro_values.

  pronm = sy-repid.
  dynnr = sy-dynnr.
  CALL FUNCTION 'DYNP_VALUES_READ'
    EXPORTING
      dyname             = pronm
      dynumb             = dynnr
      translate_to_upper = 'X'
    TABLES
      dynpfields         = dynpro_values.

  READ TABLE dynpro_values INDEX 1.

  MOVE dynpro_values-fieldvalue TO clmon.
  IF clmon IS INITIAL.
    clmon = sy-datlo(6).
  ENDIF.
  PERFORM popup_to_select_month CHANGING clmon.
  CHECK NOT clmon IS INITIAL.
*  concatenate clmon+0(4) '.' clmon+4(2) into p_pepst.
*  condense p_pepst no-gaps.

ENDFORM.                    " p0000_entries_pepst


*&---------------------------------------------------------------------*
*&      Form  popup_to_select_month
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM popup_to_select_month  CHANGING e_clmon TYPE isellist-month.

  DATA: l_clmon              TYPE isellist-month.
  DATA: p_rcode              TYPE sy-subrc.
  l_clmon = e_clmon.

  CALL FUNCTION 'POPUP_TO_SELECT_MONTH'
    EXPORTING
      actual_month               = l_clmon
    IMPORTING
      selected_month             = l_clmon
      return_code                = p_rcode
    EXCEPTIONS
      factory_calendar_not_found = 01
      holiday_calendar_not_found = 02
      month_not_found            = 03.

  e_clmon = l_clmon.
ENDFORM.                    " popup_to_select_month
*&---------------------------------------------------------------------*
*&      Form  select_order_billing_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM select_order_billing_data .

  DATA : l_shkzg       LIKE vbrp-shkzg,
         l_vf_fkimg    LIKE vbrp-fkimg,
         l_check_fkimg LIKE vbrp-fkimg,
         l_sum_fkimg   LIKE vbrp-fkimg.
  DATA : l_netwr LIKE vbap-netwr,
         l_tax   TYPE p DECIMALS 2.

  DATA : l_menge     LIKE matdoc-menge,
         l_sum_menge LIKE matdoc-menge,
         l_pstyv     LIKE vbap-pstyv.

  DATA : ll_check_cnt TYPE i,
         ls_gbsta     LIKE vbap-gbsta,
         ll_netpr     LIKE vbap-netpr,
         ll_taxk1     LIKE vbak-taxk1,
         lt_billdata  LIKE TABLE OF gt_billdata WITH HEADER LINE,
         ls_result    TYPE mb5sit.

  RANGES : lr_wadt FOR likp-wadat_ist.

  CLEAR : l_shkzg, l_vf_fkimg, l_sum_fkimg,
          l_netwr, l_tax, ll_netpr.

  CLEAR: gt_billdata, gt_billdata[].

  SELECT a~vtweg AS vtweg
         b~vkbur AS vkbur "영업팀
         b~vkgrp AS vkgrp "영업그룹
         d~j_1bbranch AS branch
         a~kunnr AS kunnr
         a~vbeln AS vbeln
         c~posnr AS posnr
         c~netwr AS netwr
         a~waerk AS waerk
         a~vbtyp AS vbtyp
         c~mwsbp AS mwsbk  "Tax
         c~fkrel AS fkrel
         c~abgru AS abgru
         a~sortkri AS sortkri
         "B~AUART AS AUART
         c~matnr AS matnr
         c~pstyv AS pstyv
         c~werks AS werks
    INTO CORRESPONDING FIELDS OF TABLE gt_billdata
    FROM vkdfs AS a INNER JOIN vbak AS b
      ON a~vbeln = b~vbeln
   INNER JOIN vbap AS c
      ON a~vbeln = c~vbeln
   INNER JOIN t001w AS d
      ON c~werks = d~werks
    JOIN tvap  AS f
      ON f~pstyv = c~pstyv
   WHERE a~fktyp = 'A'  "오더관련 대금청구
     AND a~vkorg = p_vkorg
     AND a~vtweg IN s_vtweg
     AND a~spart = p_spart
     AND b~vkbur IN s_vkbur
     AND b~vkgrp IN s_vkgrp
     AND b~auart NE 'B3'
     AND a~kunnr IN s_kunnr
     AND a~fkdat IN r_fkdat
     AND d~j_1bbranch IN s_branch
     AND b~gbstk NE 'C'
     AND f~fkrel IN ('B','C','F').

  LOOP AT gt_billdata.

    SELECT SINGLE kdkg4
                  kursk
                  fbuda
      INTO (gt_billdata-kdkg4, gt_billdata-kurrf,
            gt_billdata-fbuda)
      FROM vbkd
     WHERE vbeln =  gt_billdata-vbeln
       AND posnr =  gt_billdata-posnr
       AND kdkg4 IN s_kdkg4.

    IF sy-subrc <> 0.
      SELECT SINGLE kdkg4
                    kursk
                    fbuda
        INTO (gt_billdata-kdkg4, gt_billdata-kurrf,
              gt_billdata-fbuda)
        FROM vbkd
       WHERE vbeln =  gt_billdata-vbeln
         AND posnr =  '000000'
         AND kdkg4 IN s_kdkg4.

      IF sy-subrc <> 0.
        DELETE gt_billdata.
        CONTINUE.
      ENDIF.
    ENDIF.

    SELECT SINGLE gbsta
      INTO ls_gbsta
      FROM vbap
     WHERE vbeln = gt_billdata-vbeln
       AND posnr = gt_billdata-posnr.
    IF ls_gbsta = 'C'.
      DELETE gt_billdata.
    ELSE.
      MODIFY gt_billdata INDEX sy-tabix.
    ENDIF.
  ENDLOOP.

  SELECT a~vtweg AS vtweg
         b~vkbur AS vkbur "영업팀
         b~vkgrp AS vkgrp "영업그룹
         d~j_1bbranch AS branch
         e~kdkg4 AS kdkg4 " 내수/로칼구분
         a~kunnr AS kunnr
         a~vbeln AS vbeln
         c~posnr AS posnr
         h~fakwr AS netwr
         a~waerk AS waerk
         e~kursk AS kurrf
         a~vbtyp AS vbtyp
         c~mwsbp AS mwsbk  "Tax
         c~fkrel AS fkrel
         c~abgru AS abgru
         a~sortkri AS sortkri
         "B~AUART AS AUART
         c~matnr AS matnr
         c~pstyv AS pstyv
         h~faksp AS faksp
         c~werks AS werks
         e~fbuda AS fbuda
    APPENDING CORRESPONDING FIELDS OF TABLE gt_billdata
    FROM vkdfs AS a INNER JOIN vbak AS b
      ON a~vbeln = b~vbeln
   INNER JOIN vbap AS c
      ON a~vbeln = c~vbeln
   INNER JOIN t001w AS d
      ON c~werks = d~werks
   INNER JOIN vbkd AS e
      ON b~vbeln = e~vbeln
     AND c~posnr = e~posnr
    JOIN tvap  AS f
      ON f~pstyv = c~pstyv
    JOIN fplt AS h ON h~fplnr = e~fplnr
   WHERE a~fktyp = 'A'  "오더관련 대금청구
     AND a~vkorg = p_vkorg
     AND a~vtweg IN s_vtweg
     AND a~spart = p_spart
     AND b~vkbur IN s_vkbur
     AND b~vkgrp IN s_vkgrp
     AND b~auart NE 'B3'
     AND a~kunnr IN s_kunnr
     AND a~fkdat IN r_fkdat
     AND h~fkdat IN r_fkdat
     AND d~j_1bbranch IN s_branch
     AND c~gbsta NE 'C'
     AND e~kdkg4 IN s_kdkg4
     AND f~fkrel ='I'
     AND h~fksaf <> 'C'.

  SORT gt_billdata BY vbeln posnr.

  DELETE ADJACENT DUPLICATES FROM gt_billdata COMPARING vbeln posnr.

  LOOP AT gt_billdata WHERE abgru NE ' '.
    gt_billdata-netwr = 0.
    gt_billdata-mwsbk = 0.
    MODIFY gt_billdata INDEX sy-tabix.
  ENDLOOP.

*  LOOP AT GT_BILLDATA.
*
*    IF P_SPART = '70' AND GT_BILLDATA-PSTYV = 'ZDIE'.
*
*      CLEAR: L_SUM_MENGE, L_MENGE, L_SHKZG.
*
*      SELECT MENGE SHKZG
*        INTO (L_MENGE, L_SHKZG)
*        FROM MATDOC
*       WHERE WERKS = GT_BILLDATA-WERKS
*         AND MATNR = GT_BILLDATA-MATNR
*         AND KDAUF = GT_BILLDATA-VBELN
*         AND KDPOS = GT_BILLDATA-POSNR
*         AND BUDAT IN R_FKDAT.
*
*        IF L_SHKZG = 'S'.
*          L_SUM_MENGE = L_SUM_MENGE + L_MENGE.
*        ELSE.
*          L_SUM_MENGE = L_SUM_MENGE - L_MENGE.
*        ENDIF.
*
*      ENDSELECT.
*
*      CLEAR:  L_MENGE, L_SHKZG, L_SUM_FKIMG.
*
*      SELECT  SUM( KWMENG )
*        INTO  L_VF_FKIMG
*        FROM  VBAP
*       WHERE  VBELN  =  GT_BILLDATA-VBELN
*         AND  POSNR  =  GT_BILLDATA-POSNR.
*
*      IF L_VF_FKIMG NE 0.
*        LL_NETPR  = ( GT_BILLDATA-NETWR / L_VF_FKIMG ).
*      ENDIF.
*
*      GT_BILLDATA-NETWR = LL_NETPR * L_SUM_MENGE.
*
*      CLEAR: LL_TAXK1.
*
*      SELECT SINGLE TAXK1 INTO LL_TAXK1 FROM VBAK WHERE VBELN = GT_BILLDATA-VBELN.
*      IF LL_TAXK1 = '1'.
*        GT_BILLDATA-MWSBK = GT_BILLDATA-NETWR / 10.
*      ELSE.
*        GT_BILLDATA-MWSBK = 0.
*      ENDIF.
*
*      MODIFY GT_BILLDATA INDEX SY-TABIX.
*
*      CLEAR : L_VF_FKIMG, LL_NETPR, L_CHECK_FKIMG.
*
*    ENDIF.
*  ENDLOOP.
**
************************************************************************
*** POD 잔량이 남아있는 미 청구수량 추출
***( 청구 시작일  ~  청구 종료일 : 선택 필드, 시작일과 종료일을  입력하지 않으면  모든 운송중 재고가 조회 된다.
************************************************************************
*
*  DATA : LV_SDT TYPE SY-DATUM,
*         LV_EDT TYPE SY-DATUM.
*
*  CONCATENATE  P_SPMON  '01'  INTO  LV_SDT.
*  CALL FUNCTION 'RP_LAST_DAY_OF_MONTHS'
*    EXPORTING
*      DAY_IN            = LV_SDT
*    IMPORTING
*      LAST_DAY_OF_MONTH = LV_EDT
*    EXCEPTIONS
*      DAY_IN_NO_DATE    = 1
*      OTHERS            = 2.
*
*  LV_SDT = '20000101'.
*  __RNG LR_WADT 'I' 'BT' LV_SDT LV_EDT.
*
*  SELECT B~VTWEG AS VTWEG
*         B~VKBUR AS VKBUR "영업팀
*         B~VKGRP AS VKGRP "영업그룹
*         D~J_1BBRANCH AS BRANCH
*         E~KDKG4 AS KDKG4 " 내수/로칼구분
*         B~KUNNR AS KUNNR
*         B~VBELN AS VBELN
*         C~POSNR AS POSNR
*         B~WAERK AS WAERK
*         B~VBTYP AS VBTYP
*         C~MWSBP AS MWSBK  "Tax
*         C~FKREL AS FKREL
*         C~ABGRU AS ABGRU
*         "B~SORTKRI AS SORTKRI
*         "B~AUART AS AUART
*         C~MATNR AS MATNR
*         C~PSTYV AS PSTYV
*         C~WERKS AS WERKS
*         G~VBELN AS VBELN_VL
*         G~POSNR AS POSNR_VL
*         E~KURSK AS KURRF
**         H~FAKSP AS FAKSP
**         H~FAKWR AS NETWR
*         C~NETWR
*         E~FBUDA AS FBUDA
*    INTO CORRESPONDING FIELDS OF TABLE LT_BILLDATA
*    FROM VBAK AS B INNER JOIN VBAP AS C
*      ON B~VBELN = C~VBELN
*   INNER JOIN LIPS AS G
*      ON C~VBELN = G~VGBEL
*     AND C~POSNR = G~VGPOS
*   INNER JOIN LIKP AS I
*      ON G~VBELN = I~VBELN
*   INNER JOIN T001W AS D
*      ON C~WERKS = D~WERKS
*   INNER JOIN VBKD AS E
*      ON B~VBELN = E~VBELN
**     AND C~POSNR = E~POSNR
*    JOIN TVAP  AS F
*      ON F~PSTYV = C~PSTYV
**    INNER JOIN FPLT AS H
**      ON H~FPLNR = E~FPLNR
*   WHERE B~VKORG = P_VKORG
*     AND B~VTWEG IN S_VTWEG
*     AND B~SPART = P_SPART
*     AND B~VKBUR IN S_VKBUR
*     AND B~VKGRP IN S_VKGRP
*     AND B~AUART NE 'B3'
*     AND B~KUNNR IN S_KUNNR
*     AND D~J_1BBRANCH IN S_BRANCH
*     AND E~KDKG4 IN S_KDKG4
**     AND E~FKDAT IN LR_WADT
*     AND I~WADAT_IST IN LR_WADT
*     AND G~GBSTA NE 'C'
**     AND H~FKSAF <> 'C'
**     AND H~FKDAT IN R_FKDAT
***     AND F~FKREL ='I'
*     AND G~BWART = '687'
*     AND G~FKSTA NE 'C'
*     AND G~WBSTA IN ('C', 'B')
*     AND G~PODREL IN ('A', 'B')
*     AND G~KZPOD IN ('A', 'B', 'X').
**     AND G~PDSTA IN ('A', 'B', 'C')    .
*
*  SORT LT_BILLDATA BY VBELN POSNR.
*  DELETE ADJACENT DUPLICATES FROM LT_BILLDATA COMPARING VBELN POSNR.
*  LOOP AT LT_BILLDATA.
*
*    IF LT_BILLDATA-ABGRU NE ' '.
*      LT_BILLDATA-NETWR = 0.
*      LT_BILLDATA-MWSBK = 0.
*    ENDIF.
*
*    CLEAR LS_RESULT.
*    PERFORM CALL_MB5SIT_GI USING LT_BILLDATA-VBELN_VL LT_BILLDATA-POSNR_VL
*                        CHANGING LS_RESULT.
*
*    IF LS_RESULT-MATNR IS NOT INITIAL AND LS_RESULT-SIT_GI IS INITIAL.
*      DELETE LT_BILLDATA. CONTINUE.
*    ENDIF.
*
*    LT_BILLDATA-POD = 'X'.
*    MODIFY LT_BILLDATA.
*  ENDLOOP.
*
*  LOOP AT LT_BILLDATA .
*    READ TABLE GT_BILLDATA WITH KEY VBELN = LT_BILLDATA-VBELN
*                                    POSNR = LT_BILLDATA-POSNR.
*    IF SY-SUBRC = 0.
*      CONTINUE.
*    ENDIF.
*    CLEAR GT_BILLDATA.
*    MOVE-CORRESPONDING LT_BILLDATA TO GT_BILLDATA.
*    APPEND GT_BILLDATA. CLEAR GT_BILLDATA.
*  ENDLOOP.


ENDFORM.                    " select_order_billing_data
*&---------------------------------------------------------------------*
*&      Form  select_delivery_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM select_delivery_data .

  DATA : lt_billdata LIKE TABLE OF gt_deldata WITH HEADER LINE,
         lt_join     LIKE TABLE OF gt_deldata WITH EMPTY KEY,
         lv_first    TYPE c,
         ls_result   TYPE mb5sit.

  CLEAR: gt_deldata, gt_deldata[].

  SELECT a~vtweg AS vtweg
         d~vkbur AS vkbur         "영업팀
         d~vkgrp AS vkgrp         "영업그룹
         f~j_1bbranch AS branch
         g~kdkg4 AS kdkg4         " 내수/로칼구분
         a~kunnr AS kunnr
         e~kwmeng AS kwmeng
         c~vbeln AS vbeln
         c~posnr AS posnr
         c~lfimg AS lfimg
         c~charg AS charg
         e~netwr AS netwr
         e~waerk AS waerk
         e~mwsbp AS mwsbk
         g~kursk AS kurrf
         "A~SORTKRI AS SORTKRI
         a~vbtyp AS vbtyp
         c~vgbel AS vgbel
         c~vgpos AS vgpos
         e~netpr AS netpr
         e~kpein AS kpein
         e~kmein AS kmein
         d~auart AS auart
         e~fkrel AS fkrel
    INTO CORRESPONDING FIELDS OF TABLE gt_deldata
    FROM vkdfs AS a INNER JOIN lips AS c
      ON a~vbeln = c~vbeln
   INNER JOIN vbak AS d
      ON c~vgbel = d~vbeln
   INNER JOIN vbap AS e
      ON  c~vgbel = e~vbeln
     AND c~vgpos = e~posnr
   INNER JOIN t001w AS f
      ON c~werks = f~werks
   INNER JOIN vbkd AS g
      ON d~vbeln = g~vbeln
   WHERE a~fktyp = 'L'  "납품관련 대금청구
     AND a~vkorg = p_vkorg
     AND a~vtweg IN s_vtweg
     AND a~spart = p_spart
     AND d~vkbur IN s_vkbur
     AND d~vkgrp IN s_vkgrp
     AND a~kunnr IN s_kunnr
     AND a~fkdat IN r_fkdat
     AND f~j_1bbranch IN s_branch
     AND g~posnr = '000000'
     AND g~kdkg4 IN s_kdkg4
     AND c~bwart NE '687'
     AND c~fksta NE 'C'
     AND c~fkrel IN ('K', 'H', 'A')
     AND c~pstyv NE 'ZKRN'.

  LOOP AT gt_deldata.
    READ TABLE gt_billdata WITH KEY vbeln_vl = gt_deldata-vbeln.
    IF sy-subrc = 0.
      DELETE gt_deldata.CONTINUE.
    ENDIF.
  ENDLOOP.


**********************************************************************
* POD 잔량이 남아있는 미 청구수량 추출
*( 청구 시작일  ~  청구 종료일 : 선택 필드, 시작일과 종료일을  입력하지 않으면  모든 운송중 재고가 조회 된다.
**********************************************************************
  RANGES : lr_wadt FOR likp-wadat_ist.
  DATA : lv_sdt TYPE sy-datum,
         lv_edt TYPE sy-datum.

  CONCATENATE  p_spmon  '01'  INTO  lv_sdt.
  CALL FUNCTION 'RP_LAST_DAY_OF_MONTHS'
    EXPORTING
      day_in            = lv_sdt
    IMPORTING
      last_day_of_month = lv_edt
    EXCEPTIONS
      day_in_no_date    = 1
      OTHERS            = 2.

  lv_sdt = '20000101'.
  __rng lr_wadt 'I' 'BT' lv_sdt lv_edt.

  SELECT b~vtweg AS vtweg
         b~vkbur AS vkbur "영업팀
         b~vkgrp AS vkgrp "영업그룹
         d~j_1bbranch AS branch
         e~kdkg4 AS kdkg4 " 내수/로칼구분
         b~kunnr AS kunnr
         c~kwmeng AS kwmeng
         g~vbeln AS vbeln
         g~posnr AS posnr
         g~lfimg AS lfimg
         g~charg AS charg
         b~netwr AS netwr
         b~waerk AS waerk
         c~mwsbp AS mwsbk  "Tax
         e~kursk AS kurrf
         b~vbtyp AS vbtyp
         g~vgbel AS vgbel
         g~vgpos AS vgpos
         c~netpr AS netpr
         c~kpein AS kpein
         c~kmein AS kmein
         b~auart AS auart
         c~fkrel AS fkrel

    INTO CORRESPONDING FIELDS OF TABLE lt_billdata
    FROM vbak AS b INNER JOIN vbap AS c
      ON b~vbeln = c~vbeln
   INNER JOIN lips AS g
      ON c~vbeln = g~vgbel
     AND c~posnr = g~vgpos
   INNER JOIN likp AS i
      ON g~vbeln = i~vbeln
   INNER JOIN t001w AS d
      ON c~werks = d~werks
   INNER JOIN vbkd AS e
      ON b~vbeln = e~vbeln
     AND e~posnr = '000000'
    JOIN tvap  AS f
      ON f~pstyv = c~pstyv
   WHERE b~vkorg = p_vkorg
     AND b~vtweg IN s_vtweg
     AND b~spart = p_spart
     AND b~vkbur IN s_vkbur
     AND b~vkgrp IN s_vkgrp
*     AND B~AUART NE 'B3'
     AND b~kunnr IN s_kunnr
     AND d~j_1bbranch IN s_branch
     AND e~kdkg4 IN s_kdkg4
     AND i~wadat_ist IN lr_wadt
     AND g~fksta NE 'C'
     AND g~bwart = '687'
     AND g~podrel IN ('A', 'B')
     AND g~kzpod IN ('A', 'B', 'X')
     AND g~fkrel IN ('K', 'H', 'A')
     AND g~wbsta IN ('C', 'B')
     AND g~pstyv NE 'ZKRN'
     AND b~auart NOT IN ('KB', 'KA', 'ZCS', 'VSH1', 'LA',
                             'CQ', 'WK1', 'ZCKB', 'ZITD', 'IN',
                             'ZIPD', 'ZBC1', 'ZBC3', 'QT').

*대금청구수량
  lt_join[] = lt_billdata[].
  SORT lt_join BY vbeln posnr.
  DELETE ADJACENT DUPLICATES FROM lt_join COMPARING vbeln posnr.
  IF lt_join[] IS NOT INITIAL.
    SELECT b~vgbel, b~vgpos,
           SUM( CASE WHEN shkzg = 'X' THEN b~fkimg * -1
                ELSE b~fkimg
                 END ) AS fkimg
      FROM @lt_join AS a INNER JOIN vbrp AS b
        ON b~vgbel = a~vbeln
       AND b~vgpos = a~posnr
       AND b~draft = @space
     INNER JOIN vbrk AS c
        ON b~vbeln = c~vbeln
     WHERE fksto EQ @space
       AND sfakn EQ @space
      GROUP BY b~vgbel, b~vgpos
      INTO TABLE @DATA(lt_vf_qty).
  ENDIF.

  lt_join[] = lt_billdata[].
  DELETE lt_join WHERE lfimg > 0.
  SORT lt_join BY vbeln posnr.
  DELETE ADJACENT DUPLICATES FROM lt_join COMPARING vbeln posnr.
  IF lt_join[] IS NOT INITIAL.
    SELECT b~vbeln, b~uecha, SUM( b~lfimg ) AS lfimg
      FROM @lt_join AS a INNER JOIN lips AS b
        ON a~vbeln = b~vbeln
       AND a~posnr = b~uecha
     GROUP BY b~vbeln, b~uecha
    INTO TABLE @DATA(lt_vl_qty).
  ENDIF.

  SORT lt_billdata BY vbeln posnr.
  SORT lt_vf_qty BY vgbel vgpos.
  SORT lt_vl_qty BY vbeln uecha.
  LOOP AT lt_billdata.
    READ TABLE lt_vl_qty INTO DATA(ls_vl)
                         WITH KEY vbeln = lt_billdata-vbeln
                                  uecha = lt_billdata-posnr
                                  BINARY SEARCH.

    READ TABLE lt_vf_qty INTO DATA(ls_qty)
                         WITH KEY vgbel = lt_billdata-vbeln
                                  vgpos = lt_billdata-posnr
                                  BINARY SEARCH.
    IF sy-subrc = 0.
      IF ls_qty-fkimg = ls_vl-lfimg.
        CLEAR : ls_vl, ls_qty. CONTINUE.
      ENDIF.
    ENDIF.

    CLEAR : ls_vl, ls_qty, ls_result, gt_deldata.

    PERFORM call_mb5sit_gi USING lt_billdata-vbeln lt_billdata-posnr
                        CHANGING ls_result lv_first.

    IF ls_result-matnr IS NOT INITIAL AND ls_result-sit_gi IS INITIAL.
      DELETE lt_billdata. CONTINUE.
    ENDIF.

    MOVE-CORRESPONDING lt_billdata TO gt_deldata.
    READ TABLE gt_billdata WITH KEY vbeln_vl = gt_deldata-vbeln.
    IF sy-subrc = 0.
      CONTINUE.
    ENDIF.

    gt_deldata-pod = 'X'.
    APPEND gt_deldata.
  ENDLOOP.

ENDFORM.                    " select_delivery_data
*&---------------------------------------------------------------------*
*&      Form  select_noslip_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM select_noslip_data .

  RANGES : lr_fkdat FOR likp-wadat_ist.

  CLEAR : gt_noslip, gt_noslip[].

  DATA : lv_sdt TYPE sy-datum,
         lv_edt TYPE sy-datum,
         lt_tmp LIKE TABLE OF gt_noslip WITH HEADER LINE.

  PERFORM range_select_fkart.

  SELECT DISTINCT a~vtweg AS vtweg
         c~vkbur AS vkbur "영업팀
         c~vkgrp AS vkgrp "영업그룹
         a~bupla AS branch
         c~kdkg4 AS kdkg4 " 내수/로칼구분
         a~kunag AS kunnr
         a~vbeln AS vbeln
         a~netwr AS netwr
         a~mwsbk AS mwsbk
         a~waerk AS waerk
         a~kurrf AS kurrf
         a~rfbsk   AS rfbsk
         a~fkart   AS fkart
         a~zzbilnr AS zzbilnr
         a~zzlcno  AS zzlcno
         a~zuonr   AS zuonr
         a~vbtyp   AS vbtyp
         a~taxk1   AS taxk1
    INTO CORRESPONDING FIELDS OF TABLE gt_noslip
    FROM vbrk AS a INNER JOIN vbrp AS c
      ON a~vbeln = c~vbeln
   WHERE a~vkorg = p_vkorg
     AND a~vtweg IN s_vtweg
     AND a~spart = p_spart
     AND c~vkbur IN s_vkbur
     AND c~vkgrp IN s_vkgrp
     AND a~kunag IN s_kunnr
     AND a~fkdat IN r_fkdat
     AND a~bupla IN s_branch
     AND c~kdkg4 IN s_kdkg4
     AND a~fksto = ' '
     AND a~fkart NOT IN lr_fkart
     AND a~draft = space
     AND c~draft = space.

  CONCATENATE  p_spmon  '01'  INTO  lv_sdt.
  CALL FUNCTION 'RP_LAST_DAY_OF_MONTHS'
    EXPORTING
      day_in            = lv_sdt
    IMPORTING
      last_day_of_month = lv_edt
    EXCEPTIONS
      day_in_no_date    = 1
      OTHERS            = 2.

  lv_sdt = '20000101'.
  __rng lr_fkdat 'I' 'BT' lv_sdt lv_edt.

  SELECT DISTINCT a~vtweg AS vtweg,
         c~vkbur AS vkbur, "영업팀
         c~vkgrp AS vkgrp, "영업그룹
         a~bupla AS branch,
         c~kdkg4 AS kdkg4, " 내수/로칼구분
         a~kunag AS kunnr,
         a~vbeln AS vbeln,
         a~netwr AS netwr,
         a~mwsbk AS mwsbk,
         a~waerk AS waerk,
         a~kurrf AS kurrf,
         a~rfbsk   AS rfbsk,
         a~fkart   AS fkart,
         a~zzbilnr AS zzbilnr,
         a~zzlcno  AS zzlcno,
         a~zuonr   AS zuonr,
         a~vbtyp   AS vbtyp,
         a~taxk1   AS taxk1,
         CASE WHEN d~kzpod IS NOT INITIAL THEN 'X' END  AS pod
*    APPENDING CORRESPONDING FIELDS OF TABLE GT_NOSLIP
    FROM vbrk AS a INNER JOIN vbrp AS c
      ON a~vbeln = c~vbeln
   INNER JOIN lips AS d
      ON c~vgbel = d~vbeln
     AND c~vgpos = d~posnr
   WHERE a~vkorg = @p_vkorg
     AND a~vtweg IN @s_vtweg
     AND a~spart = @p_spart
     AND c~vkbur IN @s_vkbur
     AND c~vkgrp IN @s_vkgrp
     AND a~kunag IN @s_kunnr
     AND a~fkdat IN @lr_fkdat
     AND a~bupla IN @s_branch
     AND c~kdkg4 IN @s_kdkg4
     AND a~fksto = ' '
     AND a~fkart NOT IN @lr_fkart
     AND a~draft = @space
     AND c~draft = @space
     AND d~bwart = '687'
     AND d~podrel IN ('A', 'B')
     AND d~kzpod IN ('A', 'B', 'X')
    INTO CORRESPONDING FIELDS OF TABLE @lt_tmp.

  LOOP AT gt_noslip.
    READ TABLE lt_tmp WITH KEY vbeln = gt_noslip-vbeln.
    IF sy-subrc = 0.
      DELETE gt_noslip.
    ENDIF.
  ENDLOOP.

  gt_noslip[] = CORRESPONDING #( BASE ( gt_noslip[] ) lt_tmp[] ).

*-- 대금청구 문서 기준 해당 납품문서 정보
  DATA : lt_noslip LIKE TABLE OF gt_noslip WITH EMPTY KEY.

  lt_noslip[] = CORRESPONDING #( gt_noslip[] ).
  __cle gt_do_info.
  WITH +vf_info AS ( SELECT a~vbeln
                       FROM @lt_noslip AS a
                      GROUP BY a~vbeln )
    SELECT a~vbeln,  a~vbelv
      FROM vbfa AS a INNER JOIN +vf_info AS b
        ON a~vbeln EQ b~vbeln
     WHERE a~vbtyp_v EQ 'J'           " 납품 문서 한정
     GROUP BY a~vbeln, a~vbelv
     ORDER BY a~vbeln, a~vbelv
      INTO CORRESPONDING FIELDS OF TABLE @gt_do_info.

  DATA : l_date LIKE sy-datum.
  DATA : BEGIN OF l_it_t OCCURS 0,
           vbelv LIKE vbfa-vbelv,
         END OF l_it_t.
  CLEAR : l_it_t, l_it_t[], l_date.

  CONCATENATE  p_spmon '01'  INTO  l_date.

** 기준년월의 말일을 계산한다.
  CALL FUNCTION 'RP_LAST_DAY_OF_MONTHS'
    EXPORTING
      day_in            = l_date
    IMPORTING
      last_day_of_month = l_date.

  SELECT vbfa~vbelv INTO  CORRESPONDING FIELDS OF TABLE l_it_t
    FROM likp INNER JOIN vbfa
      ON vbfa~vbeln = likp~vbeln
   WHERE likp~lfart  =  'LF3'
     AND likp~wadat_ist  =  l_date
     AND vbfa~vbtyp_v  =  'M'.

**********************************************************************

*기준년월 전으로 생성된 빌링 데이터는 삭제 한다.
  DATA(lt_for) = gt_noslip[].
  SORT lt_for BY vbeln.
  DELETE ADJACENT DUPLICATES FROM lt_for COMPARING vbeln.
  IF lt_for[] IS NOT INITIAL.
    __cle lr_fkdat.
    CONCATENATE  p_spmon  '01'  INTO  lv_sdt.
    lv_edt = lv_sdt - 1.
    lv_sdt = '20000101'.
    __rng lr_fkdat 'I' 'BT' lv_sdt lv_edt.

*    SELECT a~vbeln, wadat_ist INTO TABLE @DATA(lt_vl)
    SELECT a~vbeln, d~fkdat INTO TABLE @DATA(lt_vl)
      FROM vbrk AS d INNER JOIN vbrp AS a
        ON d~vbeln = a~vbeln
     INNER JOIN lips AS b
        ON a~vgbel = b~vbeln
       AND a~vgpos = b~posnr
     INNER JOIN likp AS c
        ON b~vbeln = c~vbeln
       FOR ALL ENTRIES IN @lt_for
     WHERE a~vbeln      = @lt_for-vbeln
*       AND wadat_ist IN @lr_fkdat
       AND d~fkdat IN @lr_fkdat
       AND d~fksto = ''
       AND d~sfakn = ''.
    SORT lt_vl BY vbeln.
    LOOP AT gt_noslip.
      READ TABLE lt_vl INTO DATA(ls_vl) WITH KEY
                                        vbeln = gt_noslip-vbeln
                                        BINARY SEARCH.
      IF sy-subrc = 0.
        gt_noslip-lmon = 'X'.
      ENDIF.
      MODIFY gt_noslip.
    ENDLOOP.
  ENDIF.
**********************************************************************

  LOOP AT gt_noslip.
    READ TABLE l_it_t WITH KEY vbelv = gt_noslip-vbeln.
    IF  sy-subrc  =  0.
      DELETE gt_noslip.
    ENDIF.

*-- 연결문서 정보 기준 납품문서 정보 구성
    READ TABLE gt_do_info WITH KEY vbeln = gt_noslip-vbeln
                          INTO DATA(ls_do_info).
    IF sy-subrc EQ 0.
      gt_noslip-do_no = ls_do_info-vbelv.
      MODIFY gt_noslip.
    ENDIF.
  ENDLOOP.

ENDFORM.                    " select_noslip_data

*&---------------------------------------------------------------------*
*&      Form  collect_data_sum
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM collect_data_sum USING p_conv.

  DATA : lv_netwr   LIKE vbap-netwr,
         lv_mwsbp   LIKE vbap-mwsbp,
         lv_rfmng   LIKE vbfa-rfmng,
         lv_menge   LIKE vbfa-rfmng,
         lv_menge2  LIKE lips-lfimg,
         lv_input   TYPE f,
         lv_output  TYPE f,
         lv_rtype   LIKE vtbleiste-rtype,
         lv_vbeln   LIKE vbfa-vbeln,
         lv_posnn   LIKE vbfa-posnn,
         lv_sortkri LIKE vkdfs-sortkri.

  DATA : ls_result    TYPE mb5sit.

  CLEAR : lt_display, lt_display[], gt_sum, gt_sum[].

  LOOP AT gt_billdata.

** 통화별 자리수계산
    CLEAR : gv_point.
    PERFORM decimal_point_compute USING gt_billdata-waerk.

    MOVE-CORRESPONDING gt_billdata TO lt_display.

    IF gt_billdata-vbtyp = 'C'.
      lt_display-netwr_a = gt_billdata-netwr.

      IF gt_billdata-fkrel = 'I' AND gt_billdata-mwsbk NE 0.
        lt_display-mwsbk_a = gt_billdata-netwr * c_buga.
      ELSE.
        lt_display-mwsbk_a = gt_billdata-mwsbk.
      ENDIF.

**********************************************************************
*POD 분할 납품이 있을경우 금액 차감
      IF gt_billdata-pod = |X|.
        READ TABLE gt_do_info WITH KEY vbelv = gt_billdata-vbeln_vl.
        IF sy-subrc = 0.
          READ TABLE gt_noslip WITH KEY vbeln = gt_do_info-vbeln.
          IF sy-subrc = 0.
            SELECT SINGLE SUM( b~netwr ) AS netwr,
                   SUM( b~mwsbp ) AS mwsbk
              FROM vbrk AS a INNER JOIN vbrp AS b
                ON a~vbeln = b~vbeln
             INNER JOIN lips AS c
                ON b~vgbel = c~vbeln
               AND b~vgpos = c~posnr
             INNER JOIN vbap AS d
                ON c~vgbel = d~vbeln
               AND c~vgpos = d~posnr
             WHERE a~fksto = ''
               AND a~sfakn = ''
               AND d~vbeln = @gt_billdata-vbeln
               AND d~posnr = @gt_billdata-posnr
              INTO @DATA(ls_amt).
          ENDIF.
        ENDIF.

        lt_display-netwr_a = lt_display-netwr_a - ls_amt-netwr.
        lt_display-mwsbk_a = lt_display-mwsbk_a - ls_amt-mwsbk.
        CLEAR ls_amt.

      ENDIF.
**********************************************************************

    ELSEIF gt_billdata-vbtyp = 'K' AND gt_billdata-abgru = ' '.
      CLEAR : lv_netwr, lv_mwsbp.
      SELECT SUM( netwr ) SUM( mwsbp ) INTO (lv_netwr, lv_mwsbp)
         FROM vbap WHERE vbeln = gt_billdata-vbeln.

      IF sy-subrc EQ 0.
        lt_display-netwr_a = lv_netwr * ( -1 ).
        lt_display-mwsbk_a = lv_mwsbp * ( -1 ).
      ENDIF.
    ELSE.
      CHECK gt_billdata-abgru = ' '.
      CLEAR : lv_netwr, lv_mwsbp.
      SELECT SUM( netwr ) SUM( mwsbp ) INTO (lv_netwr, lv_mwsbp)
         FROM vbap WHERE vbeln = gt_billdata-vbeln.

      IF sy-subrc EQ 0.
        lt_display-netwr_a = lv_netwr.
        lt_display-mwsbk_a = lv_mwsbp.
      ENDIF.
    ENDIF.

* 보류 문서 존재 여부
    CLEAR : vkdfs.
    SELECT SINGLE * FROM vkdfs WHERE fktyp = 'A'
                                AND  vkorg = p_vkorg
                                AND  vtweg = gt_billdata-vtweg
                                AND  spart = p_spart
                                AND  sortkri = gt_billdata-sortkri
                                AND  fkdat IN r_fkdat
                                AND  faksk NOT IN (' ', '10' )
                                AND  vbeln = gt_billdata-vbeln. " 06-24

    IF sy-subrc EQ 0.
      IF  vkdfs-vbtyp  =  'C'.
        lt_display-vbeln_a = vkdfs-vbeln.
        lt_display-zflag2 = 'O'.    " 대금청구계획보류
      ELSE.
        lt_display-vbeln_a = vkdfs-vbeln.
        lt_display-cstop = 'O'.
      ENDIF.
    ENDIF.

    IF gt_billdata-fkrel = 'I' AND gt_billdata-faksp NE ' '.
      lt_display-vbeln_a = vkdfs-vbeln.
      lt_display-zflag2 = 'O'.    " 대금청구계획보류
    ENDIF.

*외화금액 변환
    IF p_conv NE 'X'.
      IF gt_billdata-waerk NE 'KRW'.
        lt_display-netwr_a = lt_display-netwr_a * gt_billdata-kurrf *
                             gv_point.
        lt_display-mwsbk_a = lt_display-mwsbk_a * gt_billdata-kurrf *
                             gv_point.
        lv_rtype = ' '.  "반올림.

        DO 2 TIMES.
          IF sy-index = 1.
            lv_input = lt_display-netwr_a.
          ELSE.
            lv_input = lt_display-mwsbk_a.
          ENDIF.

          PERFORM fima_numerical_value_round USING lv_rtype
                                                   lv_input
                                             CHANGING lv_output.
          IF sy-index = 1.
            lt_display-netwr_a = lv_output.
          ELSE.
            lt_display-mwsbk_a = lv_output.
          ENDIF.
        ENDDO.
      ENDIF.
    ENDIF.

    lt_display-sumamt_a = lt_display-netwr_a + lt_display-mwsbk_a.

    APPEND lt_display. CLEAR lt_display.

  ENDLOOP.

**********************************************************************
*D/O
**********************************************************************
  PERFORM collect_deldata USING p_conv.
**********************************************************************

  PERFORM range_select_rfbsk.


  LOOP AT gt_noslip.
    g_index = sy-tabix.

** 통화별 자리수계산
    CLEAR : gv_point.
    PERFORM decimal_point_compute USING gt_noslip-waerk.
    IF gt_noslip-lmon = 'X'.
      CONTINUE.
    ENDIF.

    MOVE-CORRESPONDING gt_noslip TO lt_display.

* 1. 전표 미생성
    IF gt_noslip-rfbsk IN lr_rfbsk AND gt_noslip-fkart NE 'ZF2'.
      lt_display-netwr_b = gt_noslip-netwr.
      lt_display-mwsbk_b = gt_noslip-mwsbk.
    ENDIF.

* 2. 계산서 미발행
    IF gt_noslip-zzbilnr = ' '
    AND gt_noslip-fkart NE 'ZF2'
    AND gt_noslip-rfbsk = 'C'
    AND gt_noslip-kdkg4 <> '4E'.
      lt_display-netwr_c = gt_noslip-netwr.
      lt_display-mwsbk_c = gt_noslip-mwsbk.
    ELSEIF  gt_noslip-zzbilnr = ' '   "계산서 발행
    AND gt_noslip-fkart NE 'ZF2'
    AND gt_noslip-rfbsk = 'C'
    AND gt_noslip-kdkg4 = '4E'.
      lt_display-netwr_d = gt_noslip-netwr.
      lt_display-mwsbk_d = gt_noslip-mwsbk.
    ENDIF.

* 3.계산서 발행
    IF gt_noslip-zzbilnr NE ' '
     AND gt_noslip-rfbsk = 'C'
     AND gt_noslip-fkart NE 'ZF2'.
      lt_display-netwr_d = gt_noslip-netwr.
      lt_display-mwsbk_d = gt_noslip-mwsbk.
    ENDIF.

*5. 전자세금계산서 전송여부
    CLEAR: ls_fkdat_rl,ls_gjahr,ls_monat, ls_report_except_yn.

    IF gt_noslip-zzbilnr NE ' '
    AND gt_noslip-rfbsk = 'C'
    AND gt_noslip-fkart NE 'ZF2'.
      lt_display-cbilltax = 'N'.
      IF gt_noslip-taxk1 = 'X'.
        lt_display-netwr_g = gt_noslip-netwr.
        lt_display-mwsbk_g = gt_noslip-mwsbk.
        lt_display-cbilltax = 'Y'.
      ELSE.

        SELECT SINGLE fkdat_rl
          INTO ls_fkdat_rl
          FROM vbrk
         WHERE vbeln = gt_noslip-vbeln.

        IF ls_fkdat_rl IS INITIAL.
          ls_gjahr = p_spmon+0(4).
          ls_monat = p_spmon+4(2).
        ELSE.
          ls_gjahr = ls_fkdat_rl+0(4).
          ls_monat = ls_fkdat_rl+4(2).
        ENDIF.

        SELECT SINGLE billseq report_except_yn
          INTO (gt_noslip-billseq, ls_report_except_yn)
          FROM zbill_trans
         WHERE  bukrs = p_vkorg
           AND  gjahr = ls_gjahr
           AND  monat = ls_monat
           AND  bupla = gt_noslip-branch
           AND  bilnr = gt_noslip-zzbilnr.

        IF sy-subrc = 0.

          IF ls_report_except_yn = 'Y'.
            lt_display-netwr_g = gt_noslip-netwr.
            lt_display-mwsbk_g = gt_noslip-mwsbk.
            lt_display-billseq = gt_noslip-billseq.
            lt_display-cbilltax = 'Y'.
          ELSE.

            SELECT SINGLE billstat
              INTO gt_noslip-billstat
              FROM zbill_stat
             WHERE  billseq = gt_noslip-billseq.

            IF gt_noslip-billstat = '1'.
              lt_display-netwr_g = gt_noslip-netwr.
              lt_display-mwsbk_g = gt_noslip-mwsbk.
              lt_display-billseq = gt_noslip-billseq.
              lt_display-cbilltax = 'Y'.
            ENDIF.
            lt_display-billstat = gt_noslip-billstat.

          ENDIF.

        ENDIF.

      ENDIF.

    ENDIF.

*외화금액 변환
    IF p_conv NE 'X'.
      IF  gt_noslip-waerk EQ 'JPY'.
        lt_display-netwr_a = lt_display-netwr_a / 100.
      ENDIF.

      IF gt_noslip-vbtyp EQ 'O'.

        lt_display-netwr_b = lt_display-netwr_b * gt_noslip-kurrf *
                             gv_point * ( -1 ).
        lt_display-netwr_c = lt_display-netwr_c * gt_noslip-kurrf *
                             gv_point * ( -1 ).
        lt_display-netwr_d = lt_display-netwr_d * gt_noslip-kurrf *
                             gv_point * ( -1 ).
        lt_display-netwr_f = lt_display-netwr_f * gt_noslip-kurrf *
                             gv_point * ( -1 ).

        lt_display-netwr_g = lt_display-netwr_g * gt_noslip-kurrf *
                             gv_point * ( -1 ).

        lt_display-mwsbk_b = lt_display-mwsbk_b * ( -1 ).
        lt_display-mwsbk_c = lt_display-mwsbk_c * ( -1 ).
        lt_display-mwsbk_d = lt_display-mwsbk_d * ( -1 ).
        lt_display-mwsbk_f = lt_display-mwsbk_f * ( -1 ).
        lt_display-mwsbk_g = lt_display-mwsbk_g * ( -1 ).

      ELSE.

        lt_display-netwr_b = lt_display-netwr_b * gt_noslip-kurrf *
                             gv_point.
        lt_display-netwr_c = lt_display-netwr_c * gt_noslip-kurrf *
                             gv_point.
        lt_display-netwr_d = lt_display-netwr_d * gt_noslip-kurrf *
                             gv_point.
        lt_display-netwr_f = lt_display-netwr_f * gt_noslip-kurrf *
                             gv_point.
        lt_display-netwr_g = lt_display-netwr_g * gt_noslip-kurrf *
                             gv_point.

      ENDIF.

      IF  gt_noslip-waerk EQ 'JPY' OR gt_noslip-waerk EQ 'IDR'.
        lt_display-netwr_b = lt_display-netwr_b / 100.
        lt_display-netwr_c = lt_display-netwr_c / 100.
        lt_display-netwr_d = lt_display-netwr_d / 100.
        lt_display-netwr_f = lt_display-netwr_f / 100.
        lt_display-netwr_g = lt_display-netwr_g / 100.

      ENDIF.

      lv_rtype = ' '.  "반올림.

    ELSE.

      IF gt_noslip-vbtyp EQ 'O'.

        lt_display-netwr_b = lt_display-netwr_b * ( -1 ).
        lt_display-netwr_c = lt_display-netwr_c * ( -1 ).
        lt_display-netwr_d = lt_display-netwr_d * ( -1 ).
        lt_display-netwr_f = lt_display-netwr_f * ( -1 ).
        lt_display-netwr_g = lt_display-netwr_g * ( -1 ).

        lt_display-mwsbk_b = lt_display-mwsbk_b * ( -1 ).
        lt_display-mwsbk_c = lt_display-mwsbk_c * ( -1 ).
        lt_display-mwsbk_d = lt_display-mwsbk_d * ( -1 ).
        lt_display-mwsbk_f = lt_display-mwsbk_f * ( -1 ).
        lt_display-mwsbk_g = lt_display-mwsbk_g * ( -1 ).
      ENDIF.

    ENDIF.

    lt_display-sumamt_b = lt_display-netwr_b + lt_display-mwsbk_b.
    lt_display-sumamt_c = lt_display-netwr_c + lt_display-mwsbk_c.
    lt_display-sumamt_d = lt_display-netwr_d + lt_display-mwsbk_d.
    lt_display-sumamt_f = lt_display-netwr_f + lt_display-mwsbk_f.
    lt_display-sumamt_g = lt_display-netwr_g + lt_display-mwsbk_g.

*B/L NO ( 수출구분이 '4D'(내수), '4L'(내수로컬)인경우 쓸모없는번호이기때문에 지워준다.
    IF gt_noslip-kdkg4 EQ '4D'.
      CLEAR  gt_noslip-zuonr.
      MODIFY gt_noslip INDEX g_index.
    ENDIF.

    APPEND lt_display. CLEAR lt_display.

  ENDLOOP.

* 총합 = 빌링미처리 + 전표미생성 + 계산서미발행 + 계산서 발행
  SORT lt_display.
*  delete adjacent duplicates from lt_display.

  IF lt_display[] IS INITIAL.
    CALL FUNCTION 'WS_MSG'
      EXPORTING
        msg_type = 'I'
        text     = '조건에 맞는 DATA가 없습니다.'
        titl     = '검색결과'.
    gv_flag = 'X'.
    EXIT.
  ENDIF.

ENDFORM.                    " collect_data_sum

*&---------------------------------------------------------------------*
*&      Form  collect_data_sum_copy
*&---------------------------------------------------------------------*
FORM collect_data_sum_copy USING p_conv.

  DATA : lv_netwr   LIKE vbap-netwr,
         lv_mwsbp   LIKE vbap-mwsbp,
         lv_rfmng   LIKE vbfa-rfmng,
         lv_menge   LIKE vbfa-rfmng,
*         lv_menge2 like vbfa-rfmng,
         lv_menge2  LIKE lips-lfimg,
         lv_input   TYPE f,
         lv_output  TYPE f,
         lv_rtype   LIKE vtbleiste-rtype,
         lv_vbeln   LIKE vbfa-vbeln,
         lv_posnn   LIKE vbfa-posnn,
         lv_sortkri LIKE vkdfs-sortkri.
  DATA : lt_vbfa LIKE vbfa OCCURS 0 WITH HEADER LINE.

  CLEAR : lt_display2, lt_display2[].

  LOOP AT gt_billdata.

** Add by SDC06 : 2005-09-30
** 통화별 자리수계산
    CLEAR : gv_point.
    PERFORM decimal_point_compute USING gt_billdata-waerk.

    MOVE-CORRESPONDING gt_billdata TO lt_display2.

    IF gt_billdata-vbtyp = 'C'.
      lt_display2-netwr_a = gt_billdata-netwr.
      IF gt_billdata-fkrel = 'I' AND gt_billdata-mwsbk NE 0.
        lt_display2-mwsbk_a = gt_billdata-netwr * c_buga.
      ELSE.
        lt_display2-mwsbk_a = gt_billdata-mwsbk.
      ENDIF.
**********************************************************************
*POD 분할 납품이 있을경우 금액 차감
      IF gt_billdata-pod = |X|.
        READ TABLE gt_do_info WITH KEY vbelv = gt_billdata-vbeln_vl.
        IF sy-subrc = 0.
          READ TABLE gt_noslip WITH KEY vbeln = gt_do_info-vbeln.
          IF sy-subrc = 0.
            SELECT SINGLE SUM( b~netwr ) AS netwr,
                   SUM( b~mwsbp ) AS mwsbk
              FROM vbrk AS a INNER JOIN vbrp AS b
                ON a~vbeln = b~vbeln
             INNER JOIN lips AS c
                ON b~vgbel = c~vbeln
               AND b~vgpos = c~posnr
             INNER JOIN vbap AS d
                ON c~vgbel = d~vbeln
               AND c~vgpos = d~posnr
             WHERE a~fksto = ''
               AND a~sfakn = ''
               AND d~vbeln = @gt_billdata-vbeln
               AND d~posnr = @gt_billdata-posnr
              INTO @DATA(ls_amt).
          ENDIF.
        ENDIF.
        lt_display2-netwr_a = lt_display2-netwr_a - ls_amt-netwr.
        lt_display2-mwsbk_a = lt_display2-mwsbk_a - ls_amt-mwsbk.
        CLEAR ls_amt.
      ENDIF.
**********************************************************************
    ELSEIF gt_billdata-vbtyp = 'K' AND gt_billdata-abgru = ' '.
      CLEAR : lv_netwr, lv_mwsbp.
      SELECT SUM( netwr ) SUM( mwsbp ) INTO (lv_netwr, lv_mwsbp)
         FROM vbap WHERE vbeln = gt_billdata-vbeln.

      IF sy-subrc EQ 0.
        lt_display2-netwr_a = lv_netwr * ( -1 ).
        lt_display2-mwsbk_a = lv_mwsbp * ( -1 ).   " 2005-06-16
      ENDIF.
    ELSEIF gt_billdata-abgru = ' '.
      CLEAR : lv_netwr, lv_mwsbp.
      SELECT SUM( netwr ) SUM( mwsbp ) INTO (lv_netwr, lv_mwsbp)
         FROM vbap WHERE vbeln = gt_billdata-vbeln.

      IF sy-subrc EQ 0.
        lt_display2-netwr_a = lv_netwr.
        lt_display2-mwsbk_a = lv_mwsbp.
      ENDIF.
    ELSE.
      lt_display2-netwr_a = 0.
      lt_display2-mwsbk_a = 0.
    ENDIF.

    IF gt_billdata-pod = |X|.
      SELECT SINGLE b~vbeln
        FROM vbrk AS a INNER JOIN vbrp AS b
          ON a~vbeln = b~vbeln
       INNER JOIN lips AS c
          ON b~vgbel = c~vbeln
         AND b~vgpos = c~posnr
       INNER JOIN likp AS d
          ON c~vbeln = d~vbeln
       WHERE b~vgbel = @gt_billdata-vbeln_vl
         AND a~sfakn = ''
         AND a~fksto = ''
         AND d~fkstk NE 'C'
        INTO @DATA(lv_vf).
      IF lv_vf IS NOT INITIAL.
        lt_display2-vbeln = lt_display2-vbeln_a = gt_billdata-vbeln_vl.
        lt_display2-cstop = 'O'.
      ENDIF.
    ELSE.
* 보류 문서 존재 여부
      CLEAR : vkdfs.
      SELECT SINGLE * FROM vkdfs WHERE fktyp = 'A'
                                  AND  vkorg = p_vkorg
                                  AND  vtweg = gt_billdata-vtweg
                                  AND  spart = p_spart
                                  AND  sortkri = gt_billdata-sortkri
                                  AND  fkdat IN r_fkdat
                                  AND  faksk NOT IN (' ', '10' )
                                  AND  vbeln = gt_billdata-vbeln. " 06-24

      IF sy-subrc EQ 0.
        IF  vkdfs-vbtyp  =  'C'.
          lt_display2-vbeln_a = vkdfs-vbeln.
          lt_display2-zflag2 = 'O'.    " 대금청구계획보류
        ELSE.
          lt_display2-vbeln_a = vkdfs-vbeln.
          lt_display2-cstop = 'O'.
        ENDIF.
      ENDIF.
    ENDIF.

    IF gt_billdata-fkrel = 'I' AND gt_billdata-faksp NE ' '.
      lt_display2-vbeln_a = vkdfs-vbeln.
      lt_display2-zflag2 = 'O'.    " 대금청구계획보류
    ENDIF.

*외화금액 변환
    IF p_conv NE 'X'.
      IF gt_billdata-waerk NE 'KRW'.

        lt_display2-netwr_a = lt_display2-netwr_a * gt_billdata-kurrf *
                              gv_point.
        lt_display2-mwsbk_a = lt_display2-mwsbk_a * gt_billdata-kurrf *
                              gv_point.

        lv_rtype = ' '.  "반올림.

        DO 2 TIMES.
          IF sy-index = 1.
            lv_input = lt_display2-netwr_a.
          ELSE.
            lv_input = lt_display2-mwsbk_a.
          ENDIF.

          PERFORM fima_numerical_value_round USING lv_rtype
                                                   lv_input
                                             CHANGING lv_output.
          IF sy-index = 1.
            lt_display2-netwr_a = lv_output.
          ELSE.
            lt_display2-mwsbk_a = lv_output.
          ENDIF.
        ENDDO.
      ENDIF.
    ENDIF.

    lt_display2-sumamt_a = lt_display2-netwr_a + lt_display2-mwsbk_a.

    APPEND lt_display2. CLEAR lt_display2.

  ENDLOOP.

  DATA : l_shkzg     LIKE vbrp-shkzg,
         l_vf_fkimg  LIKE vbrp-fkimg,
         l_sum_fkimg LIKE vbrp-fkimg.

  LOOP AT gt_deldata.

** Add by SDC06 : 2005-09-30
** 통화별 자리수계산
    CLEAR : gv_point.
    PERFORM decimal_point_compute USING gt_deldata-waerk.

    CLEAR : l_shkzg, l_vf_fkimg, l_sum_fkimg.

    MOVE-CORRESPONDING gt_deldata TO lt_display2.

    IF gt_deldata-charg EQ ' ' AND
       gt_deldata-lfimg IS INITIAL.

** 로직변경요청 : 윤방희C
      SELECT  SUM( lfimg )
        INTO  gt_deldata-lfimg
        FROM  lips
       WHERE  vbeln = gt_deldata-vbeln
         AND  uecha = gt_deldata-posnr.

    ENDIF.

** 무상빌링미처리 Check
    IF  gt_deldata-netwr IS INITIAL  OR
        gt_deldata-netwr EQ 0.
      gt_deldata-zflag1   =  'O'.
      lt_display2-vbeln_a =  gt_deldata-vgbel.
      lt_display2-zflag1  =  'O'.
    ELSE.
      gt_deldata-zflag1   =  space.
      lt_display2-vbeln_a =  space.
      lt_display2-zflag1  =  space.
    ENDIF.

** 대금청구수량
    SELECT  fkimg shkzg
      INTO (l_vf_fkimg, l_shkzg)
      FROM  vbrp
     WHERE  vgbel = gt_deldata-vbeln
       AND  vgpos = gt_deldata-posnr
       AND  draft = space.
*<-

      IF  l_shkzg  =  'X'.
        l_vf_fkimg  =  l_vf_fkimg  *  -1.
      ENDIF.

      l_sum_fkimg  =  l_sum_fkimg  +  l_vf_fkimg.

    ENDSELECT.

    IF  sy-subrc  <>  0.
      l_sum_fkimg  =  0.
    ENDIF.

** 잔량 : 납품수량 - 청구수량
    IF  gt_deldata-fkrel  =  'K'.
      lv_menge2  =  gt_deldata-lfimg  -  l_sum_fkimg.
    ELSE.
      lv_menge2  =  gt_deldata-lfimg.
    ENDIF.

    IF  pa_chk2  NE  'X'.
** 정상반품(RE)의 경우 Function을 이용하지 않고 문서에서 가지고온다.
      IF  gt_deldata-auart  EQ  'RE' OR gt_deldata-auart  EQ  'ZRET'
       OR gt_deldata-auart  EQ  'YSRE'.
        lt_display2-netwr_a  =  gt_deldata-netwr  *  -1.
        lt_display2-mwsbk_a  =  gt_deldata-mwsbk  *  -1.
        lv_input  =  lt_display2-mwsbk_a.
      ELSE.
        PERFORM  invoice_amount_calc2  USING lv_menge2
                                    CHANGING lv_input.
      ENDIF.
    ENDIF.
    "부스덕트 분할출고시
    IF gt_deldata-kwmeng <> gt_deldata-lfimg AND gt_deldata-pod = 'X'.
      PERFORM invoice_biusduct_amt_cals USING gt_deldata-vbeln
                                              gt_deldata-posnr
                                        CHANGING lt_display2-netwr_a
                                                  lv_input.
    ENDIF.

    IF  gt_deldata-waerk  =  'KRW'.
      lv_input  =  lv_input  *  100.
    ENDIF.

    lv_rtype = '-'.  "버림.

    PERFORM fima_numerical_value_round USING lv_rtype
                                             lv_input
                                       CHANGING lv_output.

    lt_display2-mwsbk_a = lv_output.

    IF  gt_deldata-waerk  =  'KRW'  AND
        lt_display2-mwsbk_a  NE  0.
      lt_display2-mwsbk_a  =  lt_display2-mwsbk_a  /  100.
    ENDIF.


    CLEAR : likp.
    SELECT SINGLE * FROM likp WHERE vbeln = gt_deldata-vbeln
                                AND  faksk NOT IN (' ', '10' ).
    IF sy-subrc EQ 0.
      lt_display2-vbeln_a = likp-vbeln.
      lt_display2-cstop = 'O'.
    ELSE.
      CLEAR : vbak.
      SELECT SINGLE * FROM vbak WHERE vbeln = gt_deldata-vgbel
                                AND  faksk NOT IN (' ', '10' ).
      IF sy-subrc EQ 0.
        lt_display2-vbeln_a = vbak-vbeln.
        lt_display2-cstop = 'O'.
      ENDIF.
    ENDIF.

*외화금액 변환
    IF p_conv NE 'X'.
      IF gt_deldata-waerk NE 'KRW'.

        lt_display2-netwr_a = lt_display2-netwr_a * gt_deldata-kurrf *
                              gv_point.
        lt_display2-mwsbk_a = lt_display2-mwsbk_a * gt_deldata-kurrf *
                              gv_point.

        IF  gt_deldata-waerk EQ 'JPY'.
          lt_display2-netwr_a = lt_display2-netwr_a / 100.
        ENDIF.

        lv_rtype = ' '.  "반올림.

        DO 2 TIMES.
          IF sy-index = 1.
            lv_input = lt_display2-netwr_a.
          ELSE.
            lv_input = lt_display2-mwsbk_a.
          ENDIF.

          PERFORM fima_numerical_value_round USING lv_rtype
                                                   lv_input
                                             CHANGING lv_output.
          IF sy-index = 1.
            lt_display2-netwr_a = lv_output.
          ELSE.
            lt_display2-mwsbk_a = lv_output.
          ENDIF.
        ENDDO.
      ENDIF.
    ENDIF.
    lt_display2-sumamt_a = lt_display2-netwr_a + lt_display2-mwsbk_a.

*-- POD 여부 확인 위한 납품문서 정보 구성 추가 2025.02.13 - Start
    lt_display2-do_no = gt_deldata-vbeln.
*-- POD 여부 확인 위한 납품문서 정보 구성 추가 2025.02.13 - End

    APPEND lt_display2.

    CLEAR : gt_deldata, lt_display2.

  ENDLOOP.


  PERFORM range_select_rfbsk.

  LOOP AT gt_noslip.

    g_index = sy-tabix.

** Add by SDC06 : 2005-09-30
** 통화별 자리수계산
    CLEAR : gv_point.
    PERFORM decimal_point_compute USING gt_noslip-waerk.

    MOVE-CORRESPONDING gt_noslip TO lt_display2.

* 1. 전표 미생성
    IF gt_noslip-rfbsk IN lr_rfbsk AND ( gt_noslip-fkart NE 'ZF2' OR gt_noslip-pod IS INITIAL ).
      lt_display2-netwr_b = gt_noslip-netwr.
      lt_display2-mwsbk_b = gt_noslip-mwsbk.
    ENDIF.

* 2. 계산서 미발행
    IF gt_noslip-zzbilnr = ' '
    AND ( gt_noslip-fkart NE 'ZF2' OR gt_noslip-pod IS INITIAL )
    AND gt_noslip-rfbsk = 'C'
    AND gt_noslip-kdkg4 <> '4E'.
      lt_display2-netwr_c = gt_noslip-netwr.
      lt_display2-mwsbk_c = gt_noslip-mwsbk.
    ELSEIF  gt_noslip-zzbilnr = ' '   "계산서 발행
    AND ( gt_noslip-fkart NE 'ZF2' OR gt_noslip-pod IS INITIAL )
    AND gt_noslip-rfbsk = 'C'
    AND gt_noslip-kdkg4 = '4E'.
      lt_display2-netwr_d = gt_noslip-netwr.
      lt_display2-mwsbk_d = gt_noslip-mwsbk.
    ENDIF.

* 3.계산서 발행
    IF gt_noslip-zzbilnr NE ' '
     AND gt_noslip-rfbsk = 'C'
     AND ( gt_noslip-fkart NE 'ZF2' OR gt_noslip-pod IS INITIAL ).
      lt_display2-netwr_d = gt_noslip-netwr.
      lt_display2-mwsbk_d = gt_noslip-mwsbk.
    ENDIF.

*5. 전자세금계산서 전송여부[C20101019_56700 ]
    CLEAR: ls_fkdat_rl,ls_gjahr,ls_monat, ls_report_except_yn.
    lt_display2-cbilltax = 'N'.
    IF gt_noslip-zzbilnr NE ' '
    AND gt_noslip-rfbsk = 'C'
    AND ( gt_noslip-fkart NE 'ZF2' OR gt_noslip-pod IS INITIAL ).

      IF gt_noslip-taxk1 = 'X'.
        lt_display2-netwr_g = gt_noslip-netwr.
        lt_display2-mwsbk_g = gt_noslip-mwsbk.
        lt_display2-cbilltax = 'Y'.
        lt_display2-billstat = '1'.
      ELSE.

        SELECT SINGLE fkdat_rl
          INTO ls_fkdat_rl
          FROM vbrk
         WHERE vbeln = gt_noslip-vbeln.

        IF ls_fkdat_rl IS INITIAL.
          ls_gjahr = p_spmon+0(4).
          ls_monat = p_spmon+4(2).
        ELSE.
          ls_gjahr = ls_fkdat_rl+0(4).
          ls_monat = ls_fkdat_rl+4(2).
        ENDIF.

        SELECT SINGLE billseq report_except_yn
          INTO (gt_noslip-billseq, ls_report_except_yn)
          FROM zbill_trans
         WHERE  bukrs = p_vkorg
           AND  gjahr = ls_gjahr
           AND  monat = ls_monat
           AND  bupla = gt_noslip-branch
           AND  bilnr = gt_noslip-zzbilnr.

        IF sy-subrc = 0.

          IF ls_report_except_yn = 'Y'.
            lt_display2-netwr_g = gt_noslip-netwr.
            lt_display2-mwsbk_g = gt_noslip-mwsbk.
            lt_display2-billseq = gt_noslip-billseq.
            lt_display2-cbilltax = 'Y'.
            lt_display2-billstat = '1'.
          ELSE.

            SELECT SINGLE billstat
              INTO gt_noslip-billstat
              FROM zbill_stat
             WHERE  billseq = gt_noslip-billseq.

            IF gt_noslip-billstat = '1'.
              lt_display2-netwr_g = gt_noslip-netwr.
              lt_display2-mwsbk_g = gt_noslip-mwsbk.
              lt_display2-billseq = gt_noslip-billseq.
              lt_display2-cbilltax = 'Y'.
            ENDIF.
            lt_display2-billstat = gt_noslip-billstat.

          ENDIF.

        ENDIF.

      ENDIF.

    ENDIF.

*4. 적송
*    IF GT_NOSLIP-FKART EQ 'ZF2' OR GT_NOSLIP-POD IS NOT INITIAL.
*      LT_DISPLAY2-NETWR_F = GT_NOSLIP-NETWR.
*      LT_DISPLAY2-MWSBK_F = GT_NOSLIP-MWSBK.
*
** choi
*적송 미완료
*      IF P_SPART+0(1) = '7'.
*        CLEAR : VBFA, LV_VBELN, LV_POSNN.
*        SELECT SINGLE * FROM VBFA WHERE VBELV   = GT_NOSLIP-VBELN
*                                   AND  VBTYP_N = 'H'
*                                   AND  STUFE   = '0'.
*                                   and  rfmng   <> 0.
*        IF SY-SUBRC <> 0.
*          LT_DISPLAY2-CTXT = '미완료'.
*        ELSE.
*          LV_VBELN = VBFA-VBELN.
*          lv_posnn = vbfa-posnn.
*          CLEAR : VBFA, LV_VBELN, LV_POSNN.
*          SELECT SINGLE * FROM VBFA WHERE VBELV = LV_VBELN
*                                      and posnv = lv_posnn
*                                      AND VBTYP_N = 'T'
*                                      AND STUFE = '0'
*                                      AND RFMNG <> 0.
*          IF SY-SUBRC <> 0.
*            LT_DISPLAY2-CTXT = '미완료'.
*          ELSE.
*            LV_VBELN = VBFA-VBELN.
*            lv_posnn = vbfa-posnn.
*            CLEAR : VBFA, LV_VBELN, LV_POSNN.
*            SELECT SINGLE * FROM VBFA WHERE VBELV = LV_VBELN
*                                       and  posnv = lv_posnn
*                                       AND  VBTYP_N = 'O'
*                                       AND  STUFE = '0'
*                                       AND  RFMNG <> 0.
*            IF SY-SUBRC EQ 0.
*              LV_VBELN = VBFA-VBELN.
*              CLEAR VBRK.
*              SELECT SINGLE * FROM VBRK WHERE VBELN = LV_VBELN
*                                         AND  FKSTO = ' '.
*              IF SY-SUBRC <> 0.
*                LT_DISPLAY2-CTXT = '미완료'.
*              ELSE.
*                LV_VBELN = VBFA-VBELN.
*                lv_posnn = vbfa-posnn.
*                CLEAR : VBFA, LV_VBELN, LV_POSNN.
*                SELECT SINGLE * FROM VBFA WHERE VBELV = LV_VBELN
*                                           and  posnv = lv_posnn
*                                           AND  VBTYP_N = 'C'
*                                           AND  STUFE = '0'
*                                           AND  RFMNG <> 0.
*                IF SY-SUBRC <> 0.
*                  LT_DISPLAY2-CTXT = '미완료'.
*                ELSE.
*                  LV_VBELN = VBFA-VBELN.
*                  lv_posnn = vbfa-posnn.
*                  CLEAR : VBFA, LV_VBELN, LV_POSNN.
*                  SELECT SINGLE * FROM VBFA WHERE VBELV = LV_VBELN
*                                             and  posnv = lv_posnn
*                                             AND  VBTYP_N = 'J'
*                                             AND  STUFE = '0'
*                                             AND  RFMNG <> 0.
*                  IF SY-SUBRC <> 0.
*                    LT_DISPLAY2-CTXT = '미완료'.
*                  ELSE.
*                    LV_VBELN = VBFA-VBELN.
*                    lv_posnn = vbfa-posnn.
*                    CLEAR : VBFA, LV_VBELN, LV_POSNN.
*                    SELECT SINGLE * FROM VBFA WHERE VBELV = LV_VBELN
*                                               and  posnv = lv_posnn
*                                               AND  VBTYP_N = 'R'
*                                               AND  STUFE = '0'
*                                               AND  RFMNG <> 0.
*
*                    IF SY-SUBRC <> 0.
*                      LT_DISPLAY2-CTXT = '미완료'.
*                      GT_NOSLIP-CHK = 'X'.
*                    ENDIF.
*                  ENDIF.
*                ENDIF.
*              ENDIF.
*            ENDIF.
*          ENDIF.
*        ENDIF.
*      ELSE.
*        CLEAR : VBFA, LV_VBELN, LV_POSNN.
*        SELECT SINGLE * FROM VBFA WHERE VBELV   = GT_NOSLIP-VBELN
*                                   AND  VBTYP_N = 'H'
*                                   AND  STUFE   = '00'
*                                   AND  RFMNG   <> 0.
*        IF SY-SUBRC <> 0.
*          LT_DISPLAY2-CTXT = '미완료'.
*        ELSE.
*          LV_VBELN = VBFA-VBELN.
*          LV_POSNN = VBFA-POSNN.
*          CLEAR : VBFA, LV_VBELN, LV_POSNN.
*          SELECT SINGLE * FROM VBFA WHERE VBELV = LV_VBELN
*                                      AND POSNV = LV_POSNN
*                                      AND VBTYP_N = 'T'
*                                      AND STUFE = '00'
*                                      AND RFMNG <> 0.
*          IF SY-SUBRC <> 0.
*            LT_DISPLAY2-CTXT = '미완료'.
*          ELSE.
*            LV_VBELN = VBFA-VBELN.
*            LV_POSNN = VBFA-POSNN.
*            CLEAR : VBFA, LV_VBELN, LV_POSNN.
*            SELECT SINGLE * FROM VBFA WHERE VBELV = LV_VBELN
*                                       AND  POSNV = LV_POSNN
*                                       AND  VBTYP_N = 'O'
*                                       AND  STUFE = '00'
*                                       AND  RFMNG <> 0.
*            IF SY-SUBRC EQ 0.
*              LV_VBELN = VBFA-VBELN.
*
*              CLEAR VBRK.
*              SELECT SINGLE * FROM VBRK WHERE VBELN = LV_VBELN
*                                         AND  FKSTO = ' '.
*              IF SY-SUBRC <> 0.
*                LT_DISPLAY2-CTXT = '미완료'.
*              ELSE.
*                LV_VBELN = VBFA-VBELN.
*                LV_POSNN = VBFA-POSNN.
*                CLEAR : VBFA, LV_VBELN, LV_POSNN.
*                SELECT SINGLE * FROM VBFA WHERE VBELV = LV_VBELN
*                                           AND  POSNV = LV_POSNN
*                                           AND  VBTYP_N = 'C'
*                                           AND  STUFE = '00'
*                                           AND  RFMNG <> 0.
*                IF SY-SUBRC <> 0.
*                  LT_DISPLAY2-CTXT = '미완료'.
*                ELSE.
*                  LV_VBELN = VBFA-VBELN.
*                  LV_POSNN = VBFA-POSNN.
*                  CLEAR : VBFA, LV_VBELN, LV_POSNN.
*                  SELECT SINGLE * FROM VBFA WHERE VBELV = LV_VBELN
*                                             AND  POSNV = LV_POSNN
*                                             AND  VBTYP_N = 'J'
*                                             AND  STUFE = '00'
*                                             AND  RFMNG <> 0.
*                  IF SY-SUBRC <> 0.
*                    LT_DISPLAY2-CTXT = '미완료'.
*                  ELSE.
*                    LV_VBELN = VBFA-VBELN.
*                    LV_POSNN = VBFA-POSNN.
*                    CLEAR : VBFA, LV_VBELN, LV_POSNN.
*                    SELECT SINGLE * FROM VBFA WHERE VBELV = LV_VBELN
*                                               AND  POSNV = LV_POSNN
*                                               AND  VBTYP_N = 'R'
*                                               AND  STUFE = '00'
*                                               AND  RFMNG <> 0.
*
*                    IF SY-SUBRC <> 0.
*                      LT_DISPLAY2-CTXT = '미완료'.
*                      GT_NOSLIP-CHK = 'X'.
*                    ENDIF.
*                  ENDIF.
*                ENDIF.
*              ENDIF.
*            ENDIF.
*          ENDIF.
*        ENDIF.
*      ENDIF.
*    ENDIF.

*외화금액 변환
    IF p_conv NE 'X'.

** 원화도 계산하기 위해 Remark : 2005-04-26
*      if gt_noslip-waerk ne 'KRW'.

      IF gt_noslip-vbtyp EQ 'O'.

        lt_display2-netwr_b = lt_display2-netwr_b * gt_noslip-kurrf *
                              gv_point * ( -1 ).
        lt_display2-netwr_c = lt_display2-netwr_c * gt_noslip-kurrf *
                              gv_point * ( -1 ).
        lt_display2-netwr_d = lt_display2-netwr_d * gt_noslip-kurrf *
                              gv_point * ( -1 ).
        lt_display2-netwr_f = lt_display2-netwr_f * gt_noslip-kurrf *
                              gv_point * ( -1 ).
        lt_display2-netwr_g = lt_display2-netwr_g * gt_noslip-kurrf *
                              gv_point * ( -1 ).

        lt_display2-mwsbk_b = lt_display2-mwsbk_b * ( -1 ).
        lt_display2-mwsbk_c = lt_display2-mwsbk_c * ( -1 ).
        lt_display2-mwsbk_d = lt_display2-mwsbk_d * ( -1 ).
        lt_display2-mwsbk_f = lt_display2-mwsbk_f * ( -1 ).
        lt_display2-mwsbk_g = lt_display2-mwsbk_g * ( -1 ).
      ELSE.

        lt_display2-netwr_b = lt_display2-netwr_b * gt_noslip-kurrf *
                              gv_point.
        lt_display2-netwr_c = lt_display2-netwr_c * gt_noslip-kurrf *
                              gv_point.
        lt_display2-netwr_d = lt_display2-netwr_d * gt_noslip-kurrf *
                              gv_point.
        lt_display2-netwr_f = lt_display2-netwr_f * gt_noslip-kurrf *
                              gv_point.
        lt_display2-netwr_g = lt_display2-netwr_g * gt_noslip-kurrf *
                              gv_point.

      ENDIF.

      lv_rtype = ' '.  "반올림.

    ELSE.

      IF  gt_noslip-vbtyp EQ 'O'.
        lt_display2-netwr_b = lt_display2-netwr_b * -1.
        lt_display2-netwr_c = lt_display2-netwr_c * -1.
        lt_display2-netwr_d = lt_display2-netwr_d * -1.
        lt_display2-netwr_f = lt_display2-netwr_f * -1.
        lt_display2-mwsbk_b = lt_display2-mwsbk_b * -1.
        lt_display2-mwsbk_c = lt_display2-mwsbk_c * -1.
        lt_display2-mwsbk_d = lt_display2-mwsbk_d * -1.
        lt_display2-mwsbk_f = lt_display2-mwsbk_f * -1.
        lt_display2-mwsbk_g = lt_display2-mwsbk_g * -1.
      ENDIF.

    ENDIF.

    lt_display2-sumamt_b = lt_display2-netwr_b + lt_display2-mwsbk_b.
    lt_display2-sumamt_c = lt_display2-netwr_c + lt_display2-mwsbk_c.
    lt_display2-sumamt_d = lt_display2-netwr_d + lt_display2-mwsbk_d.
    lt_display2-sumamt_f = lt_display2-netwr_f + lt_display2-mwsbk_f.
    lt_display2-sumamt_g = lt_display2-netwr_g + lt_display2-mwsbk_g.

*B/L NO ( 수출구분이 '4D'(내수), '4L'(내수로컬)인경우 쓸모없는
*번호이기때문에 지워준다.
** '4L'은 지우지 않는다 : 2005-04-25 윤위원 요청.
    IF gt_noslip-kdkg4 EQ '4D'.
      CLEAR  gt_noslip-zuonr.
      MODIFY gt_noslip INDEX g_index.
    ENDIF.

*-- POD 여부 확인 위한 납품문서 정보 구성 추가 2025.02.13 - Start
    lt_display2-do_no = gt_noslip-do_no.
*-- POD 여부 확인 위한 납품문서 정보 구성 추가 2025.02.13 - End

    APPEND lt_display2. CLEAR lt_display2.
  ENDLOOP.

* 총합 = 빌링미처리 + 전표미생성 + 계산서미발행 + 계산서 발행

  SORT lt_display2.

ENDFORM.                    " collect_data_sum_copy

*&---------------------------------------------------------------------*
*&      Form  FIMA_NUMERICAL_VALUE_ROUND
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM fima_numerical_value_round  USING p_rtype
                                       p_input
                              CHANGING p_output.

  CALL FUNCTION 'FIMA_NUMERICAL_VALUE_ROUND'
    EXPORTING
      i_rtype     = p_rtype   " ' ':반올림, '+':올림, '-':버림
      i_runit     = '1'
      i_value     = p_input
    IMPORTING
      e_value_rnd = p_output.

ENDFORM.                    " FIMA_NUMERICAL_VALUE_ROUND
*&---------------------------------------------------------------------*
*&      Form  range_select_rfbsk
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM range_select_fkart .

  CLEAR : lr_fkart, lr_fkart[].
  MOVE: 'I'      TO lr_fkart-sign,
        'EQ'     TO lr_fkart-option,
        'ZRE'      TO lr_fkart-low.
  APPEND lr_fkart.
  MOVE: 'I'      TO lr_fkart-sign,
        'EQ'     TO lr_fkart-option,
        'S1'      TO lr_fkart-low.
  APPEND lr_fkart.
  MOVE: 'I'      TO lr_fkart-sign,
        'EQ'     TO lr_fkart-option,
        'S2'      TO lr_fkart-low.
  APPEND lr_fkart.
  MOVE: 'I'      TO lr_fkart-sign,
        'EQ'     TO lr_fkart-option,
        'FAS'      TO lr_fkart-low.
  APPEND lr_fkart.

ENDFORM.                    " range_select_rfbsk
*&---------------------------------------------------------------------*
*&      Form  range_select_rfbsk
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM range_select_rfbsk .

  CLEAR : lr_rfbsk, lr_rfbsk[].
  MOVE: 'I'      TO lr_rfbsk-sign,
        'EQ'     TO lr_rfbsk-option,
        ' '      TO lr_rfbsk-low.
  APPEND lr_rfbsk.
  MOVE: 'I'      TO lr_rfbsk-sign,
        'EQ'     TO lr_rfbsk-option,
        'A'      TO lr_rfbsk-low.
  APPEND lr_rfbsk.
  MOVE: 'I'      TO lr_rfbsk-sign,
        'EQ'     TO lr_rfbsk-option,
        'B'      TO lr_rfbsk-low.
  APPEND lr_rfbsk.
  MOVE: 'I'      TO lr_rfbsk-sign,
        'EQ'     TO lr_rfbsk-option,
        'F'      TO lr_rfbsk-low.
  APPEND lr_rfbsk.
  MOVE: 'I'      TO lr_rfbsk-sign,
        'EQ'     TO lr_rfbsk-option,
        'G'      TO lr_rfbsk-low.
  APPEND lr_rfbsk.
  MOVE: 'I'      TO lr_rfbsk-sign,
        'EQ'     TO lr_rfbsk-option,
        'K'      TO lr_rfbsk-low.
  APPEND lr_rfbsk.

ENDFORM.                    " range_select_rfbsk
*&---------------------------------------------------------------------*
*&      Form  fima_numerical_value
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_RTYPE  text
*      -->P_INPUT  text
*      <--P_UTPUT  text
*----------------------------------------------------------------------*
FORM fima_numerical_value  USING    p_rtype
                           CHANGING p_netwr
                                    p_mwsbk.

  DATA : lv_input  TYPE f,
         lv_output TYPE f.

  DO 2 TIMES.
    IF sy-index = 1.
      lv_input = p_netwr.
    ELSE.
      lv_input = p_mwsbk.
    ENDIF.

    PERFORM fima_numerical_value_round USING p_rtype
                                             lv_input
                                       CHANGING lv_output.
    IF sy-index = 1.
      p_netwr = lv_output.
    ELSE.
      p_mwsbk = lv_output.
    ENDIF.
  ENDDO.

ENDFORM.                    " fima_numerical_value
*&---------------------------------------------------------------------*
*&      Form  call_billing_screen
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM call_billing_screen .
*4D	Domestic
*4L	내수 Local
  DATA  : ls_check_billto.
  DATA : lv_sdt  TYPE sy-datum,
         lv_edt  TYPE sy-datum,
         lv_lock.

  DATA : l_data   TYPE REF TO data.

  RANGES lr_wadt FOR likp-wadat_ist.

  CLEAR : g_h_fkdat, ls_check_billto.


*-- 마감확정 상태의 경우 '내수/로컬 Billing' 처리 불가  - Start 250807
  READ TABLE gt_display WITH KEY chk   = 'X'
                                 compl = 'Y'.
  IF sy-subrc EQ 0.
    MESSAGE e001 WITH '마감확정 상태에서는 Billing 처리가 불가능합니다.'.
  ENDIF.
*-- 마감확정 상태의 경우 '내수/로컬 Billing' 처리 불가  - End 250807
  READ TABLE gt_display WITH KEY chk   = 'X'.
  CHECK gt_display-kdkg4 <> '4S'.

  ls_check_billto = 'Y'.

  LOOP AT gt_display WHERE chk EQ 'X'.

    IF  gt_display-sumamt_a  = '0.00'.
** Request by 최석원D : 2005-07-30
** 무상빌링건의 경우 Billing미처리금액과 무관하게 처리해야 됨.
      IF  gt_display-zflag1  NE  'O'.

        LOOP AT lt_display2 WHERE branch = gt_display-branch
                              AND vkbur  = gt_display-vkbur
                              AND vkgrp  = gt_display-vkgrp
                              AND vtweg  = gt_display-vtweg
                              AND kdkg4  = gt_display-kdkg4
                              AND kunnr  = gt_display-kunnr.

          IF lt_display2-sumamt_a NE '0.00'.
            ls_check_billto = 'N'.
          ENDIF.

        ENDLOOP.

        IF ls_check_billto = 'Y'.
          MESSAGE e001 WITH '선택한 Data를 확인하세요.'.
          EXIT.
        ENDIF.

      ENDIF.
    ENDIF.

    PERFORM check_range_value.

*    IF GT_DISPLAY-KDKG4 EQ '4D'.

    g_h_fkdat  =  r_fkdat-high.

    CALL SCREEN 3000 STARTING AT 20 10 ENDING AT 55 14.

    IF  sy-ucomm  =  'ENTE'.

      CHECK g_h_fkdat NE '00000000'.

      CONCATENATE  p_spmon  '01'  INTO  lv_sdt.
      CALL FUNCTION 'RP_LAST_DAY_OF_MONTHS'
        EXPORTING
          day_in            = lv_sdt
        IMPORTING
          last_day_of_month = lv_edt
        EXCEPTIONS
          day_in_no_date    = 1
          OTHERS            = 2.

      lv_sdt = '20000101'.
      __rng lr_wadt 'I' 'BT' lv_sdt lv_edt.

      IF gt_display-compl = 'Y'.
        lv_lock = 'X'.
      ELSE.
**********************************************************************
*프로그램 락 생성
**********************************************************************
        PERFORM prog_lock USING lv_lock 'ZGTSDR1080'.
**********************************************************************
      ENDIF.

      SUBMIT zgtsdr0120 WITH so_kunnr     IN r_kunnr
                 WITH pa_vkorg     = p_vkorg
                 WITH pa_vtweg     = gt_display-vtweg
                 WITH pa_spart     = p_spart
                 WITH so_vkbur-low     = gt_display-vkbur
                 WITH so_vkgrp-low     = gt_display-vkgrp
                 WITH so_wadat     IN r_fkdat
                 WITH pa_fkdat     = g_h_fkdat   " r_fkdat-high
                 WITH ps_chk2      = pa_chk2
                 WITH p_lock       = lv_lock
                 WITH pa_imode     = pa_imode
                 WITH p_local      = gt_display-kdkg4
                 AND RETURN.
**********************************************************************
*프로그램 종료후 락 해제
**********************************************************************
      IF lv_lock IS INITIAL.
        PERFORM prog_unlock USING 'ZGTSDR1080'.
      ENDIF.
**********************************************************************

      PERFORM p1000_initial_data.
      PERFORM p1000_select_data.
      PERFORM p2000_process_data USING ' '.
      MESSAGE s009(zgtsd01) WITH |{ lines( gt_display ) NUMBER = USER }|. "& 건 검색되었습니다.
*      ENDIF.

*    ELSEIF  GT_DISPLAY-KDKG4 EQ '4L'.
*
*      G_H_FKDAT  =  R_FKDAT-HIGH.
*
*      CALL SCREEN 3000 STARTING AT 20 10 ENDING AT 55 14.
*
*      IF  SY-UCOMM  =  'ENTE'.
*
*        CHECK G_H_FKDAT NE '00000000'.
*
*        SUBMIT ZTER0200 WITH P_BUKRS  = P_VKORG
*                   WITH S_KUNAG  IN R_KUNNR
*                   WITH S_VKORG  IN R_VKORG
*                   WITH S_VTWEG  IN R_VTWEG
*                   WITH S_SPART  IN R_SPART
*                   WITH S_VKBUR  IN R_VKBUR
*                   WITH S_VKGRP  IN R_VKGRP
*                   WITH PA_FKDAT     = G_H_FKDAT   " r_fkdat-high
*                   AND RETURN.
*
*      ENDIF.

    ENDIF.
  ENDLOOP.

ENDFORM.                    " call_billing_screen
*&---------------------------------------------------------------------*
*&      Form  call_computer_screen
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM call_computer_screen .

  DATA : lv_chk   VALUE 'X',
         lv_kunnr LIKE vbak-kunnr.
  DATA : ll_knrza LIKE kna1-knrza.
  DATA : ls_check_tax.
  CLEAR : g_payer_t, g_payer_t[].
  CLEAR : ll_knrza, ls_check_tax.

  ls_check_tax = 'Y'.

  LOOP AT gt_display WHERE chk EQ 'X'.

** 반품인 경우에도 이동가능하도록 변경
** Changed By SDC06 : 2005-06-21
*   if  gt_display-sumamt_c  <=  0.
*    if  gt_display-sumamt_c  =  0.
*      message e001 with '선택한 Data를 확인하세요.'.
*      exit.
*    endif.
    IF gt_display-compl = 'Y'.
      MESSAGE e001 WITH '마감 확정된 데이터 입니다..'.
      EXIT.
    ENDIF.

    IF  gt_display-sumamt_c  = '0.00'.

      LOOP AT lt_display2 WHERE branch = gt_display-branch
                            AND vkbur  = gt_display-vkbur
                            AND vkgrp  = gt_display-vkgrp
                            AND vtweg  = gt_display-vtweg
                            AND kdkg4  = gt_display-kdkg4
                            AND kunnr  = gt_display-kunnr.

        IF lt_display2-sumamt_c NE '0.00'.
          ls_check_tax = 'N'.
        ENDIF.

      ENDLOOP.

      IF ls_check_tax = 'Y'.
        MESSAGE e001 WITH '선택한 Data를 확인하세요.'.
        EXIT.
      ENDIF.

    ENDIF.


    IF gt_display-kdkg4 EQ '4D'.  "내수
      SET PARAMETER ID 'AA' FIELD lv_chk.
      lv_kunnr = gt_display-kunnr.
    ELSEIF gt_display-kdkg4 EQ '4L'.  "내수 Local
      SET PARAMETER ID 'BB' FIELD lv_chk.

      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
        EXPORTING
          input  = gt_display-kunnr
        IMPORTING
          output = lv_kunnr.

      REPLACE '1' LENGTH 1
                    WITH '2'
                    INTO lv_kunnr.

    ELSEIF gt_display-kdkg4 EQ '4S'. "
      SET PARAMETER ID 'CC' FIELD lv_chk.

      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
        EXPORTING
          input  = gt_display-kunnr
        IMPORTING
          output = lv_kunnr.

      REPLACE '1' LENGTH 1
                    WITH '2'
                    INTO lv_kunnr.

    ELSE.
      lv_kunnr = gt_display-kunnr.
    ENDIF.

** 선택한 Record의 지급처를 Gethering한다.
    LOOP AT gt_noslip WHERE branch = gt_display-branch
                        AND vkbur  = gt_display-vkbur
                        AND vkgrp  = gt_display-vkgrp
                        AND kdkg4  = gt_display-kdkg4
                        AND kunnr  = gt_display-kunnr.

      g_payer_t-vbeln  =  gt_noslip-vbeln.

      SELECT  SINGLE
              vbrk~kunrg kna1~name1
        INTO (g_payer_t-kunrg,
              g_payer_t-name1)
        FROM  vbrk INNER JOIN kna1 ON kna1~kunnr = vbrk~kunrg
       WHERE  vbrk~vbeln  =  g_payer_t-vbeln.

      APPEND  g_payer_t.
      CLEAR  g_payer_t.

    ENDLOOP.

    DELETE g_payer_t WHERE kunrg = space.


*** to select the same header office in the tracter division
*** written by choi seok won.

    IF  p_spart = '71'.

      SELECT SINGLE knrza
        INTO ll_knrza
        FROM kna1
       WHERE kunnr = lv_kunnr.

      IF ll_knrza IS NOT INITIAL.
        lv_kunnr = ll_knrza.
        CLEAR ll_knrza.
      ENDIF.

    ENDIF.

** 지급처를 입력받는다.
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
      EXPORTING
        input  = lv_kunnr
      IMPORTING
        output = g_h_kunrg.

    CALL SCREEN 4000 STARTING AT 20 10 ENDING AT 55 14.

    IF  sy-ucomm  =  'ENTE'.

      CHECK NOT g_h_kunrg IS INITIAL.

      SET PARAMETER ID 'VKO' FIELD p_vkorg.
      SET PARAMETER ID 'BUK' FIELD p_vkorg.
      SET PARAMETER ID 'VTW' FIELD gt_display-vtweg.
      SET PARAMETER ID 'SPA' FIELD p_spart.
      SET PARAMETER ID 'VKB' FIELD gt_display-vkbur.
      SET PARAMETER ID 'VKG' FIELD gt_display-vkgrp.
      SET PARAMETER ID 'KUN' FIELD g_h_kunrg.  " lv_kunnr.
      SET PARAMETER ID 'ZBU' FIELD gt_display-branch.
      SET PARAMETER ID 'BU1' FIELD r_fkdat-low.
      SET PARAMETER ID 'BU2' FIELD r_fkdat-high.

*      call transaction 'ZFIR0160'.
      CALL TRANSACTION 'ZFIR0160_NE'.
    ENDIF.

    SET PARAMETER ID 'AA' FIELD ' '.
    SET PARAMETER ID 'BB' FIELD ' '.
    SET PARAMETER ID 'CC' FIELD ' '.

  ENDLOOP.

ENDFORM.                    " call_computer_screen
*&---------------------------------------------------------------------*
*&      Form  call_delivery_screen
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM call_delivery_screen USING pv_type.

  RANGES : lr_vtweg  FOR vbak-vtweg,
           lr_spart  FOR vbak-spart,
           lr_branch FOR j_1bbranch-branch,
           lr_vkbur  FOR vbak-vkbur,
           lr_vkgrp  FOR vbak-vkgrp,
           lr_vbevl  FOR likp-vbeln,
           lr_wadat  FOR likp-wadat_ist,
           lr_kdkg4  FOR vbkd-kdkg4,
           lr_kunnr  FOR vbak-kunnr,
           lr_lifnr  FOR vbpa-lifnr,
           lr_ernam  FOR vbak-ernam,
           lr_erdat  FOR vbak-erdat.

  DATA : l_data   TYPE REF TO data.

  DATA : lv_sdt  TYPE sy-datum,
         lv_edt  TYPE sy-datum,
         lt_list TYPE TABLE OF abaplist.

  UNASSIGN <gfs_data>.

  CONCATENATE  p_spmon  '01'  INTO lv_sdt.

  CALL FUNCTION 'RP_LAST_DAY_OF_MONTHS'
    EXPORTING
      day_in            = lv_sdt
    IMPORTING
      last_day_of_month = lv_edt
    EXCEPTIONS
      day_in_no_date    = 1
      OTHERS            = 2.

  LOOP AT gt_display WHERE chk EQ 'X'.
    __rng : lr_vtweg 'I' 'EQ' gt_display-vtweg '',
            lr_spart 'I' 'EQ' p_spart '',
            lr_branch 'I' 'EQ' gt_display-branch '',
            lr_vkbur 'I' 'EQ' gt_display-vkbur '',
            lr_vkgrp 'I' 'EQ' gt_display-vkgrp '',
            lr_wadat 'I' 'EQ' '' lv_edt,
            lr_kdkg4 'I' 'EQ' gt_display-kdkg4 '',
            lr_kunnr 'I' 'EQ' gt_display-kunnr '',

            lr_erdat 'I' 'EQ' '' lv_edt.


    IF pv_type IS NOT INITIAL.
      cl_salv_bs_runtime_info=>set( display  = abap_false
                              metadata = abap_false
                              data     = abap_true ).
      UNASSIGN <gfs_data>.
    ELSE.
      cl_salv_bs_runtime_info=>set( display  = abap_true
                              metadata = abap_false
                              data     = abap_false ).
    ENDIF.

    SUBMIT zgtsdr1070 WITH p_vkorg   = p_vkorg
                      WITH s_vtweg  IN lr_vtweg
                      WITH s_spart  IN lr_spart
                      WITH s_branch IN lr_branch
                      WITH s_vkbur  IN lr_vkbur
                      WITH s_vkgrp  IN lr_vkgrp
                      WITH s_vbevl  IN lr_vbevl
                      WITH s_wadat  IN lr_wadat
                      WITH s_kdkg4  IN lr_kdkg4
                      WITH s_kunnr  IN lr_kunnr
                      WITH s_lifnr  IN lr_lifnr
                      WITH s_ernam  IN lr_ernam
                      WITH s_erdat  IN lr_erdat
                      AND RETURN.

    IF pv_type IS NOT INITIAL.
      TRY.
          cl_salv_bs_runtime_info=>get_data_ref( IMPORTING r_data = l_data ).
          ASSIGN l_data->* TO <gfs_data>.
          cl_salv_bs_runtime_info=>clear_all( ).
        CATCH cx_salv_bs_sc_runtime_info.
      ENDTRY.
    ENDIF.

  ENDLOOP.

ENDFORM.                    " call_delivery_screen
*&---------------------------------------------------------------------*
*&      Form  call_block_screen
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM call_block_screen .


  LOOP AT gt_display WHERE chk EQ 'X'.

    IF gt_display-compl = 'Y'.
      MESSAGE e001 WITH '마감 확정된 데이터 입니다..'.
      EXIT.
    ENDIF.

    PERFORM check_range_value.

    SUBMIT zsdfakspe
*    with kunnr-low     = gt_display-kunnr
                     WITH vkorg     = p_vkorg
                     WITH vtweg     IN r_vtweg
                     WITH spart     IN r_spart
                     WITH vkbur     IN r_vkbur
                     WITH vkgrp     IN r_vkgrp
                     WITH vbeln     IN r_vbeln
                     AND RETURN.

  ENDLOOP.

ENDFORM.                    " call_block_screen
*&---------------------------------------------------------------------*
*&      Form  display_detail_list
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM display_detail_list .

*  suppress dialog.
*
*  perform set_layout    changing g_layout_s.
*
  PERFORM select_lclist_data.

  EXPORT gt_temp  TO MEMORY ID 'ZSD02'.
  EXPORT p_spmon  TO MEMORY ID 'ZSD021'.      " 기준년월
  EXPORT pa_chk2  TO MEMORY ID 'ZSD022'.      " Check
  EXPORT g_imode  TO MEMORY ID 'ZSD023'.      " BDC 수행모드
  EXPORT p_vkorg  TO MEMORY ID 'ZSD024'.

  SUBMIT zsdr1081 AND RETURN.
*
*  perform alv_display_data.

ENDFORM.                    " display_detail_list

*&---------------------------------------------------------------------*
*&      Form  display_detail_list2
*&---------------------------------------------------------------------*
FORM display_detail_list2 .

  DATA : l_cnt   TYPE i,
         lv_lock TYPE char1,
         lv_sdt  TYPE sy-datum,
         lv_edt  TYPE sy-datum.

  RANGES lr_wadt FOR likp-wadat_ist.

  CLEAR : g_itab_t, g_itab_t[].

  l_cnt  =  0.

  LOOP AT gt_display WHERE chk EQ 'X'.

    LOOP AT lt_display2 WHERE branch = gt_display-branch
                          AND vkbur  = gt_display-vkbur
                          AND vkgrp  = gt_display-vkgrp
                          AND vtweg  = gt_display-vtweg
                          AND kdkg4  = gt_display-kdkg4
                          AND kunnr  = gt_display-kunnr.
*      CHECK LT_DISPLAY2-PSTYV NE |ZBIS|.
      MOVE-CORRESPONDING  lt_display2  TO  g_itab_t.
      APPEND  g_itab_t.
      CLEAR  g_itab_t.

    ENDLOOP.

    l_cnt  =  l_cnt  +  1.

  ENDLOOP.

*기준년월 전으로 생성된 빌링 데이터는 삭제 한다.
  DATA(lt_for) = g_itab_t[].
  SORT lt_for BY vbeln.
  DELETE ADJACENT DUPLICATES FROM lt_for COMPARING vbeln.
  IF lt_for[] IS NOT INITIAL.
    CONCATENATE  p_spmon  '01'  INTO  lv_sdt.
    lv_edt = lv_sdt - 1.
    lv_sdt = '20000101'.
    __rng lr_wadt 'I' 'BT' lv_sdt lv_edt.

*    SELECT a~vbeln, wadat_ist INTO TABLE @DATA(lt_vl)
    SELECT a~vbeln, d~fkdat INTO TABLE @DATA(lt_vl)
      FROM vbrp AS a INNER JOIN lips AS b
        ON a~vgbel = b~vbeln
       AND a~vgpos = b~posnr
      INNER JOIN vbrk AS d
        ON a~vbeln EQ d~vbeln
     INNER JOIN likp AS c
        ON b~vbeln = c~vbeln
       FOR ALL ENTRIES IN @lt_for
     WHERE a~vbeln      = @lt_for-vbeln
       AND d~fkdat IN @lr_wadt.
    SORT lt_vl BY vbeln.
    LOOP AT g_itab_t.
      READ TABLE lt_vl INTO DATA(ls_vl) WITH KEY
                                        vbeln = g_itab_t-vbeln
                                        BINARY SEARCH.
      IF sy-subrc = 0.
        DELETE g_itab_t. CONTINUE.
      ENDIF.
    ENDLOOP.
  ENDIF.

  IF  l_cnt  =  0.
    MESSAGE s001 WITH '상세리스트를 조회할 대상을 선택하세요.'.
  ELSEIF  l_cnt  >  1.
    MESSAGE s001 WITH '한건씩 조회 가능합니다.'.
  ELSE.

    DATA: g_p_spart LIKE vbak-spart.
    DATA: g_p_vkorg LIKE vbak-vkorg.

    g_p_spart = gs_header-spart.
    g_fkdat_high   = r_fkdat-high.
    g_fkdat_low    = r_fkdat-low.
    g_p_vkorg = p_vkorg.

    EXPORT g_itab_t TO MEMORY ID 'ZGTSD07'.
    EXPORT g_imode  TO MEMORY ID 'ZGTSD071'.      " BDC 수행모드
    EXPORT g_p_spart TO MEMORY ID 'ZGTSD072'.
    EXPORT g_fkdat_high  TO MEMORY ID 'ZGTSD073'.
    EXPORT g_fkdat_low  TO MEMORY ID 'ZGTSD074'.
    EXPORT g_p_vkorg TO MEMORY ID 'ZGTSD1075'.

    IF gt_display-compl = 'Y'.
      lv_lock = 'X'.
    ELSE.
*프로그램 락 생성
      PERFORM prog_lock USING lv_lock 'ZGTSDR1080'.
    ENDIF.

    SUBMIT zgtsdr1082 WITH p_lock = lv_lock AND RETURN.

*프로그램 종료후 락 해제
    IF lv_lock IS INITIAL.
      PERFORM prog_unlock USING 'ZGTSDR1080'.
    ENDIF.

    PERFORM p1000_initial_data.
    PERFORM p1000_select_data.
    PERFORM p2000_process_data USING ' '.
    MESSAGE s009(zgtsd01) WITH |{ lines( gt_display ) NUMBER = USER }|. "& 건 검색되었습니다.
  ENDIF.

ENDFORM.                    " display_detail_list2

*&---------------------------------------------------------------------*
*&      Form  convert_foreign_amt
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM convert_foreign_amt .
  DATA : lv_conv.

  IF gv_conv IS INITIAL.
    gv_conv = 'X'.
  ELSE.
    gv_conv = ' '.
  ENDIF.

  PERFORM collect_data_sum  USING gv_conv.

  PERFORM p2000_process_data USING gv_conv.

ENDFORM.                    " convert_foreign_amt
*&---------------------------------------------------------------------*
*&      Form  check_range_value
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM check_range_value .

  CLEAR : r_bupla, r_bupla[].
  r_bupla-sign    =  'I'.
  r_bupla-option  =  'EQ'.
  r_bupla-low     = gt_display-branch.
  APPEND r_bupla.

  CLEAR : r_vkorg, r_vkorg[].
  r_vkorg-sign    =  'I'.
  r_vkorg-option  =  'EQ'.
  r_vkorg-low     = p_vkorg.
  APPEND r_vkorg.

  CLEAR : r_kunnr, r_kunnr[].
  r_kunnr-sign    =  'I'.
  r_kunnr-option  =  'EQ'.
  r_kunnr-low     = gt_display-kunnr.
  APPEND r_kunnr.

  CLEAR : r_vtweg, r_vtweg[].
  r_vtweg-sign    =  'I'.
  r_vtweg-option  =  'EQ'.
  r_vtweg-low     = gt_display-vtweg.
  APPEND r_vtweg.
  CLEAR : r_spart, r_spart[].
  r_spart-sign    =  'I'.
  r_spart-option  =  'EQ'.
  r_spart-low     = p_spart.
  APPEND r_spart.
  CLEAR : r_vkbur, r_vkbur[].
  r_vkbur-sign    =  'I'.
  r_vkbur-option  =  'EQ'.
  r_vkbur-low     = gt_display-vkbur.
  APPEND r_vkbur.
  CLEAR : r_vkgrp, r_vkgrp[].
  r_vkgrp-sign    =  'I'.
  r_vkgrp-option  =  'EQ'.
  r_vkgrp-low     = gt_display-vkgrp.
  APPEND r_vkgrp.
  CLEAR : r_vbeln, r_vbeln[].
  r_vbeln-sign    =  'I'.
  r_vbeln-option  =  'EQ'.
  r_vbeln-low     = gt_display-vbeln_a.
  APPEND r_vbeln.

ENDFORM.                    " check_range_value

*&---------------------------------------------------------------------*
*&      Form  data_curr_change_rtn
*&---------------------------------------------------------------------*
FORM data_curr_change_rtn .

  IF  gt_itab-netwr_a  <>  0.
    gt_itab-netwr_a  =  gt_itab-netwr_a  /  100.
  ENDIF.
  IF  gt_itab-mwsbk_a  <>  0.
    gt_itab-mwsbk_a  =  gt_itab-mwsbk_a  /  100.
  ENDIF.
  IF  gt_itab-sumamt_a  <>  0.
    gt_itab-sumamt_a  =  gt_itab-sumamt_a  /  100.
  ENDIF.

  IF  gt_itab-netwr_b  <>  0.
    gt_itab-netwr_b  =  gt_itab-netwr_b  /  100.
  ENDIF.
  IF  gt_itab-mwsbk_b  <>  0.
    gt_itab-mwsbk_b  =  gt_itab-mwsbk_b  /  100.
  ENDIF.
  IF  gt_itab-sumamt_b  <>  0.
    gt_itab-sumamt_b  =  gt_itab-sumamt_b  /  100.
  ENDIF.

  IF  gt_itab-netwr_c  <>  0.
    gt_itab-netwr_c  =  gt_itab-netwr_c  /  100.
  ENDIF.
  IF  gt_itab-mwsbk_c  <>  0.
    gt_itab-mwsbk_c  =  gt_itab-mwsbk_c  /  100.
  ENDIF.
  IF  gt_itab-sumamt_c  <>  0.
    gt_itab-sumamt_c  =  gt_itab-sumamt_c  /  100.
  ENDIF.

  IF  gt_itab-netwr_d  <>  0.
    gt_itab-netwr_d  =  gt_itab-netwr_d  /  100.
  ENDIF.
  IF  gt_itab-mwsbk_d  <>  0.
    gt_itab-mwsbk_d  =  gt_itab-mwsbk_d  /  100.
  ENDIF.
  IF  gt_itab-sumamt_d  <>  0.
    gt_itab-sumamt_d  =  gt_itab-sumamt_d  /  100.
  ENDIF.

  IF  gt_itab-netwr_e  <>  0.
    gt_itab-netwr_e  =  gt_itab-netwr_e  /  100.
  ENDIF.
  IF  gt_itab-mwsbk_e  <>  0.
    gt_itab-mwsbk_e  =  gt_itab-mwsbk_e  /  100.
  ENDIF.
  IF  gt_itab-sumamt_e  <>  0.
    gt_itab-sumamt_e  =  gt_itab-sumamt_e  /  100.
  ENDIF.

  IF  gt_itab-netwr_f  <>  0.
    gt_itab-netwr_f  =  gt_itab-netwr_f  /  100.
  ENDIF.
  IF  gt_itab-mwsbk_f  <>  0.
    gt_itab-mwsbk_f  =  gt_itab-mwsbk_f  /  100.
  ENDIF.
  IF  gt_itab-sumamt_f  <>  0.
    gt_itab-sumamt_f  =  gt_itab-sumamt_f  /  100.
  ENDIF.

ENDFORM.                    " data_curr_change_rtn

*&---------------------------------------------------------------------*
*&      Form  AUTHORITY_CHECK
*&---------------------------------------------------------------------*
*       권한(ROLL) CHECK
*----------------------------------------------------------------------*
FORM authority_check.

  DATA: lv_subrc  LIKE sy-subrc.

  CLEAR : lv_subrc.

  CALL FUNCTION 'Z_SD_AUTHORIZATION_CHECK'
    EXPORTING
      i_vkorg = p_vkorg
      i_type  = '1'
    IMPORTING
      e_subrc = lv_subrc.

  IF lv_subrc <> 0.
    MESSAGE e002 WITH '영업조직에 대한 권한이 없읍니다'
                      p_vkorg.
  ENDIF.

  CLEAR : lv_subrc.

  CALL FUNCTION 'Z_SD_AUTHORIZATION_CHECK'
    EXPORTING
      i_spart = p_spart
      i_type  = '3'
    IMPORTING
      e_subrc = lv_subrc.

  IF lv_subrc <> 0.
    MESSAGE e002 WITH '제품군에 대한 권한이 없읍니다'
                      p_spart.
  ENDIF.
ENDFORM.                    " AUTHORITY_CHECK

*&---------------------------------------------------------------------*
*&      Form  invoice_amount_calc
*&---------------------------------------------------------------------*
FORM invoice_amount_calc   USING    p_menge2
                           CHANGING p_tax.

  DATA : l_date LIKE sy-datum,
         l_flag.

  CONCATENATE  p_spmon '01'  INTO  l_date.

  CALL FUNCTION 'RP_LAST_DAY_OF_MONTHS'      " 말일을 구함
    EXPORTING
      day_in            = l_date       " Date
    IMPORTING
      last_day_of_month = l_date.      " Date

  IF  p_chk  =  'X'.
    l_flag  =  'X'.
  ELSE.
    l_flag  =  space.
  ENDIF.

  CALL FUNCTION 'ZSD_PRICING'
    EXPORTING
      vbeln_o     = gt_deldata-vgbel
      posnr_o     = gt_deldata-vgpos
      vbeln_d     = gt_deldata-vbeln
      posnr_d     = gt_deldata-posnr
      fkimg       = p_menge2
      fkdat       = l_date
      export_flag = l_flag
    IMPORTING
      netwr       = lt_display-netwr_a
      mwsbp       = lt_display-mwsbk_a.

  p_tax  =  lt_display-mwsbk_a.

ENDFORM.                    " invoice_amount_calc

*&---------------------------------------------------------------------*
*&      Form  invoice_amount_calc2
*&---------------------------------------------------------------------*
FORM invoice_amount_calc2   USING    p_menge2
                           CHANGING p_tax.

  DATA : l_date LIKE sy-datum,
         l_flag.

  CONCATENATE  p_spmon '01'  INTO  l_date.

  CALL FUNCTION 'RP_LAST_DAY_OF_MONTHS'      " 말일을 구함
    EXPORTING
      day_in            = l_date       " Date
    IMPORTING
      last_day_of_month = l_date.      " Date

  IF  p_chk  =  'X'.
    l_flag  =  'X'.
  ELSE.
    l_flag  =  space.
  ENDIF.

  CALL FUNCTION 'ZSD_PRICING'
    EXPORTING
      vbeln_o     = gt_deldata-vgbel
      posnr_o     = gt_deldata-vgpos
      vbeln_d     = gt_deldata-vbeln
      posnr_d     = gt_deldata-posnr
      fkimg       = p_menge2
      fkdat       = l_date
      export_flag = l_flag
    IMPORTING
      netwr       = lt_display2-netwr_a
      mwsbp       = lt_display2-mwsbk_a.

  p_tax  =  lt_display2-mwsbk_a.

ENDFORM.                    " invoice_amount_calc2

*&---------------------------------------------------------------------*
*&      Module  STATUS_3000  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_3000 OUTPUT.

  SET PF-STATUS '3000'.
  SET TITLEBAR '3000'.

ENDMODULE.                 " STATUS_3000  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_3000  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_3000 INPUT.

  CASE  sy-ucomm.

    WHEN  'ENTE'.
      LEAVE TO SCREEN 0.

    WHEN  'CANC'.
      LEAVE TO SCREEN 0.

  ENDCASE.

ENDMODULE.                 " USER_COMMAND_3000  INPUT

*&---------------------------------------------------------------------*
*&      Module  STATUS_4000  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_4000 OUTPUT.

  SET PF-STATUS '4000'.
  SET TITLEBAR '4000'.

ENDMODULE.                 " STATUS_4000  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_4000  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_4000 INPUT.

  CASE  sy-ucomm.

    WHEN  'ENTE'.
      LEAVE TO SCREEN 0.

    WHEN  'CANC'.
      LEAVE TO SCREEN 0.

  ENDCASE.

ENDMODULE.                 " USER_COMMAND_4000  INPUT

*&---------------------------------------------------------------------*
*&      Module  f4_kunrg  INPUT
*&---------------------------------------------------------------------*
MODULE f4_kunrg INPUT.

  PERFORM  f4_kunrg_rtn.

ENDMODULE.                 " f4_kunrg  INPUT

*&---------------------------------------------------------------------*
*&      Form  f4_kunrg_rtn
*&---------------------------------------------------------------------*
FORM f4_kunrg_rtn .

  DATA : l_selectfield  LIKE help_info-fieldname,
         l_select_value LIKE help_info-fldvalue,
         l_fld_tab      LIKE help_value OCCURS 1 WITH HEADER LINE,
         l_ld_tabix     LIKE sy-tabix,
         l_scr_fields   LIKE dynpread OCCURS 0 WITH HEADER LINE,
         l_ktokd        LIKE kna1-ktokd.
*-> CCM : 13.04.2023 16:56:19 / ZLSGSD4
*         L_KKBER         LIKE KNKK-KKBER.
*<-

  DATA : BEGIN OF it_value OCCURS 0,
           kunrg LIKE  vbrk-kunrg,
           name1 LIKE  kna1-name1,
         END OF it_value.

  CLEAR: l_selectfield, l_fld_tab, l_ld_tabix, l_ktokd.
  REFRESH: l_fld_tab, it_value.

** Title 정의.
  MOVE: 'VBRK'      TO l_fld_tab-tabname,
        'KUNRG'     TO l_fld_tab-fieldname,
        'X'         TO l_fld_tab-selectflag.
  APPEND l_fld_tab.

  MOVE: 'KNA1'      TO l_fld_tab-tabname,
        'NAME1'     TO l_fld_tab-fieldname,
        ' '         TO l_fld_tab-selectflag.
  APPEND l_fld_tab.

** begin(추가부분) **
  LOOP AT g_payer_t.

    MOVE-CORRESPONDING  g_payer_t  TO  it_value.
    APPEND  it_value.
    CLEAR  it_value.

  ENDLOOP.

  DELETE ADJACENT DUPLICATES FROM it_value COMPARING kunrg.

  CALL FUNCTION 'HELP_VALUES_GET_NO_DD_NAME'
    EXPORTING
      selectfield                  = l_selectfield
    IMPORTING
      ind                          = l_ld_tabix
      select_value                 = l_select_value
    TABLES
      fields                       = l_fld_tab
      full_table                   = it_value
    EXCEPTIONS
      full_table_empty             = 1
      no_tablestructure_given      = 2
      no_tablefields_in_dictionary = 3
      more_then_one_selectfield    = 4
      no_selectfield               = 5
      OTHERS                       = 6.

  CHECK NOT l_ld_tabix IS INITIAL.

  READ TABLE it_value INDEX l_ld_tabix.

* 전달값 첫번째 값을 가져온다.
  g_h_kunrg = l_select_value.

** 코드 선택해서 Text 보요줄떄 사용.
*  l_scr_fields-fieldname  = 'G_H_NAME1'.
*  l_scr_fields-fieldvalue = it_value-name1.
*  append l_scr_fields.

  CALL FUNCTION 'DYNP_VALUES_UPDATE'
    EXPORTING
      dyname               = sy-cprog
      dynumb               = sy-dynnr
    TABLES
      dynpfields           = l_scr_fields
    EXCEPTIONS
      invalid_abapworkarea = 1
      invalid_dynprofield  = 2
      invalid_dynproname   = 3
      invalid_dynpronummer = 4
      invalid_request      = 5
      no_fielddescription  = 6
      undefind_error       = 7
      OTHERS               = 8.

ENDFORM.                    " f4_kunrg_rtn

*&---------------------------------------------------------------------*
*&      Form  decimal_point_compute
*&---------------------------------------------------------------------*
FORM decimal_point_compute  USING    p_waerk.

** TCURX-CURRKEY (통화키), TCURX-CURRDEC (소수 자릿수)

  gv_point = 1.

  CLEAR tcurx.

  SELECT  SINGLE currdec
    FROM  tcurx
    INTO  tcurx-currdec
   WHERE  currkey EQ p_waerk.

  IF  sy-subrc  NE  0.
    tcurx-currdec  =  2.
  ENDIF.

  IF  tcurx-currdec  =  2.
    gv_point  =  1  /  100.
  ELSEIF  tcurx-currdec  =  3.
    gv_point  =  1  /  1000.
  ELSEIF  tcurx-currdec  =  4.
    gv_point  =  1  /  10000.
  ELSEIF  tcurx-currdec  =  5.
    gv_point  =  1  /  100000.
  ENDIF.

ENDFORM.                    " decimal_point_compute
*&---------------------------------------------------------------------*
*& Form chk_pod_from_do
*&---------------------------------------------------------------------*
*& 출력 정보 기준 POD 확정여부 정보 Select
*&---------------------------------------------------------------------*
*&      --> PT_LIST       : 납품문서 정보 포함 상세 리스트 정보
*&      <-- PT_POD_CHK    :
*&---------------------------------------------------------------------*
FORM chk_pod_from_do  TABLES   pt_list    LIKE lt_display2[]
                      CHANGING pt_pod_chk TYPE gty_t_pod_chk.

  DATA : lt_list LIKE TABLE OF lt_display2 WITH EMPTY KEY.

  CLEAR : pt_pod_chk.

*-- 상세 리스트 납품문서 정보 기준 POD 완료여부 정보 Select
  lt_list[] = CORRESPONDING #( pt_list[] ).

  WITH +list_info AS ( SELECT a~branch, a~vkbur, a~vkgrp, a~vtweg,            "--> 납품 문서 정보 포함 상세 리스트 정보 구성
                              a~kdkg4,  a~kunnr, a~do_no
                         FROM @lt_list AS a ),

       +do_info   AS ( SELECT a~do_no                                         "--> 납품 문서 기준 Key 정보 구성
                         FROM +list_info AS a
                        WHERE a~do_no IS NOT INITIAL
                        GROUP BY a~do_no ),

       +pod_chk   AS ( SELECT a~vbeln, a~pdstk                                "--> 납품 Header 정보 기준 POD 확정여부 구성
                         FROM likp AS a INNER JOIN +do_info AS b
                                           ON a~vbeln EQ b~do_no ),

       +cnt_info  AS ( SELECT a~branch, a~vkbur, a~vkgrp, a~vtweg,            "--> 화면 출력 그룹정보 기준 POD 확정 대상 수 구성
                              a~kdkg4,  a~kunnr,
                              COUNT( * ) AS all_cnt,

                              SUM( CASE WHEN b~pdstk IS NOT NULL AND
                                             b~pdstk EQ 'C' THEN 1
                                        ELSE 0
                                        END ) AS comp_cnt
                         FROM +list_info AS a LEFT OUTER JOIN +pod_chk AS b
                                                      ON a~do_no EQ b~vbeln

                        GROUP BY a~branch, a~vkbur, a~vkgrp, a~vtweg,
                                 a~kdkg4,  a~kunnr )

    SELECT a~branch,  a~vkbur,  a~vkgrp,  a~vtweg,  a~kdkg4,  a~kunnr,        "--> 출력 Key 그룹 기준 POD 확정 완료 여부 정보 구성

           CASE WHEN a~all_cnt EQ a~comp_cnt THEN @abap_true
                ELSE @abap_false
           END AS pod_flg

      FROM +cnt_info AS a
     ORDER BY a~branch, a~vkbur, a~vkgrp, a~vtweg, a~kdkg4, a~kunnr

      INTO CORRESPONDING FIELDS OF TABLE @pt_pod_chk.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form MODIFY_SCREEN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM modify_screen .

  LOOP AT SCREEN.
    CASE screen-name.
      WHEN 'S_SPMON-HIGH'.
        screen-input = 0.
      WHEN OTHERS.
    ENDCASE.
    MODIFY SCREEN.
  ENDLOOP.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form CALL_MB5SIT_GI
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> G_ITAB_T_VBELN
*&      --> G_ITAB_T_POSNN
*&      <-- LS_RESULT
*&---------------------------------------------------------------------*
FORM call_mb5sit_gi  USING    pv_vbeln pv_posnr
                     CHANGING ps_result TYPE mb5sit
                              pv_first.

  STATICS : lt_stock TYPE TABLE OF mb5sit WITH NON-UNIQUE SORTED KEY k_key COMPONENTS vbeln posnr.
  DATA : lt_result TYPE TABLE OF mb5sit WITH DEFAULT KEY WITH HEADER LINE,
         lt_deli   TYPE TABLE OF shp_vbeln_range WITH HEADER LINE.

  RANGES : lr_sobkz FOR lips-sobkz,
           lr_ebeln FOR lips-ebeln,
           lr_ebelp FOR lips-ebelp,
           lr_lifnr FOR likp-lifnr.

  IF pv_first IS INITIAL.
    CLEAR : lt_stock, lt_stock[].
    pv_first = 'X'.
  ENDIF.

  TRY.
      READ TABLE lt_stock INTO ps_result WITH KEY k_key COMPONENTS vbeln = pv_vbeln
                                                                   posnr = pv_posnr.
      IF sy-subrc NE 0.

        __rng : lt_deli 'I' 'EQ' pv_vbeln ''.
        CALL FUNCTION 'MB_SELECT_STOCK_IN_TRANSIT'
          EXPORTING
            i_wi_gm               = 'X'
            i_condense            = space
          TABLES
            t_result              = lt_result
            t_ra_sobkz            = lr_sobkz
            t_ra_ebeln            = lr_ebeln
            t_ra_ebelp            = lr_ebelp
            t_ra_lifnr            = lr_lifnr
            t_ra_del_out          = lt_deli[] "delivery outbound
          EXCEPTIONS
            parameter_error       = 1
            missing_authorization = 2
            OTHERS                = 3.

        IF lt_result[] IS NOT INITIAL.
          lt_stock[] = CORRESPONDING #( BASE ( lt_stock  ) lt_result[] ).
          READ TABLE lt_result INTO ps_result WITH KEY posnr = pv_posnr.
        ENDIF.

      ENDIF.
    CATCH cx_root INTO DATA(lo_err).
      MESSAGE s001 WITH lo_err->get_longtext( ) DISPLAY LIKE zgtsd_e.
      LEAVE LIST-PROCESSING.
  ENDTRY.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_BD
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM check_bd .
  DATA : lv_active TYPE char01.
  CALL FUNCTION 'ZGTSD_EXIT_CONTROL'
    EXPORTING
      i_prog    = sy-cprog
      i_perform = 'CHECK_BD'
      i_vkorg   = p_vkorg
      i_vtweg   = s_vtweg-low
      i_spart   = p_spart
    IMPORTING
      e_active  = lv_active.
  IF lv_active NE 'Y'.
    MESSAGE e001 WITH 'ZSD1R1080 영업마감 프로그램 을 사용하세요 !' DISPLAY LIKE 'E'.
    LEAVE LIST-PROCESSING.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form EXPORT_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM export_data .

*  DATA : LT_FIS5000 TYPE TABLE OF ZGTFIS5000 WITH HEADER LINE.

*  LT_FIS5000[] = CORRESPONDING #( GT_DISPLAY[] ).
  DATA(lt_fis5000_bd) = gt_display[].
  FREE MEMORY ID 'ZGTSDR1085'.
  EXPORT lt_fis5000_bd TO MEMORY ID 'ZGTSDR1085'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SALES_CLOSING_CONFIRM
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM sales_closing_confirm .

  DATA : lv_sdt      TYPE sy-datum,
         lv_edt      TYPE sy-datum,
         lv_msg      TYPE char100,
         ls_1080     TYPE zgtsdt1080,
         lt_cald     TYPE TABLE OF vtbfcal,
         lv_err,
         lv_spmon    TYPE spmon,
         lv_subrc(1).

  READ TABLE gt_display WITH KEY chk = 'X'.
  IF sy-subrc NE 0.
    MESSAGE e004(zgtsd01).
    EXIT.
  ENDIF.

  IF p_spmon < '202507'.
    MESSAGE s001 WITH '마감확정 기능은 2025.07 이후 월만 가능합니다.'  DISPLAY LIKE 'E'.EXIT.
  ENDIF.

*1)-1-4 마감여부가 'Y'인 경우 화면 하단 에러 메세지 출력
  IF gt_display-compl EQ 'Y'.
    MESSAGE s001 WITH '이미 마감 확정된 거래처입니다.'  DISPLAY LIKE 'E'.EXIT.
  ENDIF.

*1)-1-2 보류된 BILLING 문서가 존재하고 있을 경우 화면 하단 에러 메세지 출력
  IF gt_display-cstop IS NOT INITIAL.
    MESSAGE s001 WITH '보류된 청구문서가 존재합니다.' DISPLAY LIKE 'E'.EXIT.
  ENDIF.

*1)-1-3 전표미생성 금액 혹은 계산서 미발행 금액이 있을 경우 화면 하단 에러 메세지 출력
  IF gt_display-netwr_b NE 0.
    MESSAGE s001 WITH '전표 미생성된 금액이 존재합니다.' DISPLAY LIKE 'E'.EXIT.
  ENDIF.

  IF gt_display-netwr_c NE 0.
    MESSAGE s001 WITH '계산서 미발행된 금액이 존재합니다.' DISPLAY LIKE 'E'.EXIT.
  ENDIF.

*1)-1-4 무상비링 미처리 내역이 존재할 경우 하단 에러메시지 출력
  IF gt_display-zflag1 IS NOT INITIAL.
    MESSAGE s001 WITH '전표 미생성된 무상빌링 문서가 존재합니다.' DISPLAY LIKE 'E'.EXIT.
  ENDIF.


**********************************************************************
*POD 데이터중 이상데이터 점검 " CHM2510-00065
**********************************************************************
  CLEAR : gv_check.
  PERFORM call_pod_error_check USING lv_subrc .
  CHECK lv_subrc IS INITIAL.

**********************************************************************
*POD 아닌 데이터 중 빌링 미처리
**********************************************************************
  CLEAR : gv_check.
  IF gt_display-kdkg4 = '4S'.
    PERFORM call_billing_screen3 USING lv_subrc.
  ELSE.
    PERFORM call_billing_screen2 USING lv_subrc.
  ENDIF.
  CHECK lv_subrc IS INITIAL.

**********************************************************************
*공사마감 미처리 내역 점검
**********************************************************************
  CLEAR : gv_check.
  PERFORM call_ci_error_check USING lv_subrc.
  CHECK lv_subrc IS INITIAL.


**********************************************************************
*운송중 재고 프로그램 호출후 인수예정 정보 체크
**********************************************************************
  IF gt_display-netwr_a IS NOT INITIAL.
    PERFORM call_delivery_screen USING 'X'.
    IF <gfs_data> IS ASSIGNED AND <gfs_data>[] IS NOT INITIAL.
*      LOOP AT <GFS_DATA> INTO GS_S0100.
*        IF GS_S0100-ZERDAT IS INITIAL.
*          CONTINUE.
*        ELSE.
*          LV_SPMON = GS_S0100-ZERDAT.
*          IF LV_SPMON <= P_SPMON.
*            CONTINUE.
*          ENDIF.
*        ENDIF.
*        DELETE <GFS_DATA>.
*      ENDLOOP.
*      IF <GFS_DATA>[] IS NOT INITIAL.
*        MESSAGE I001 WITH '인수 예정 날자 최신정보로 업데이트 해야 합니다.' DISPLAY LIKE 'W'.
      PERFORM call_delivery_input.
    ENDIF.
*    ENDIF.
  ENDIF.

  CASE gv_cflag.
    WHEN 'Y'.
    WHEN 'N'.
      EXIT.
    WHEN OTHERS.
      "거래처코드" & "거래처 이름" & P_SPMON & "마감 확정 하시겠습니까?"
      CONCATENATE '[' gt_display-kunnr  gt_display-name1 ']' ':' p_spmon
                  TEXT-m01 INTO lv_msg SEPARATED BY space.
      CLEAR gv_answer.
      gv_answer = zgtsd_cl_common=>popup_to_comfirm( iv_ucomm = space iv_messa = lv_msg ).
      CHECK gv_answer EQ zgtsd_j.
  ENDCASE.

  SELECT SINGLE * INTO @ls_1080
    FROM zgtsdt1080
   WHERE spmon EQ @p_spmon
     AND bupla EQ @gt_display-branch
     AND vkbur EQ @gt_display-vkbur
     AND vtweg EQ @gt_display-vtweg
     AND vkgrp EQ @gt_display-vkgrp
     AND kdkg4 EQ @gt_display-kdkg4
     AND kunnr EQ @gt_display-kunnr.
  IF sy-subrc = 0.
    zgtsd_cl_common=>set_timestamp( EXPORTING iv_gubun = zgtsd_u
                                    CHANGING  cs_timestamp = ls_1080-timestamp ).
  ELSE.

    ls_1080-spmon = p_spmon.
    ls_1080-bupla = gt_display-branch.
    ls_1080-vkbur = gt_display-vkbur.
    ls_1080-vtweg = gt_display-vtweg.
    ls_1080-vkgrp = gt_display-vkgrp.
    ls_1080-kdkg4 = gt_display-kdkg4.
    ls_1080-kunnr = gt_display-kunnr.
    zgtsd_cl_common=>set_timestamp( EXPORTING iv_gubun = zgtsd_c
                                    CHANGING  cs_timestamp = ls_1080-timestamp ).
  ENDIF.
  ls_1080-sales_closing = 'Y'.
  MODIFY zgtsdt1080 FROM ls_1080.

  MESSAGE s000(zgtsd01) WITH  '확정되었습니다.'.

  gt_display-compl = 'Y'.
  gt_display-pod_stat = icon_led_green.
  MODIFY gt_display TRANSPORTING compl pod_stat WHERE chk = 'X'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SALES_CLOSING_CONFIRM_CANC
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM sales_closing_confirm_canc .

  DATA : lv_sdt  TYPE sy-datum,
         lv_edt  TYPE sy-datum,
         lv_msg  TYPE char100,
         ls_1080 TYPE zgtsdt1080,
         lt_cald TYPE TABLE OF vtbfcal.

  READ TABLE gt_display WITH KEY chk = 'X'.
  IF sy-subrc NE 0.
    MESSAGE e004(zgtsd01).
    EXIT.
  ENDIF.

  SELECT SINGLE zmagam1
    INTO @DATA(lv_magam)
    FROM zsd0013t
    WHERE bukrs = '1000'
      AND zyyyymm = @p_spmon
      AND branch = '130'
      AND vtweg IN @s_vtweg.
  IF lv_magam = 'X'.
    MESSAGE s003 WITH p_spmon '은 이미 마감되었습니다. 회계팀에 문의 부탁드립니다.' DISPLAY LIKE 'E'.
    EXIT.
  ENDIF.

  IF p_spmon < '202507'.
    MESSAGE s001 WITH '마감확정취소 기능은 2025.07 이후 월만 가능합니다.'  DISPLAY LIKE 'E'.EXIT.
  ENDIF.

  DATA(lv_kunnr) = gt_display-kunnr.
  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
    EXPORTING
      input  = gt_display-kunnr
    IMPORTING
      output = lv_kunnr.

**1)-1-1 마감확정 처리 가능한 날짜 확인
*  SELECT SINGLE FLD_04 INTO @DATA(LV_CHK)
*    FROM ZGTPPT1010
*   WHERE MODULE_KIND = 'SD'
*     AND CODEGRP     = '5009'
*     AND FLD_01      = @P_SPMON
*     AND FLD_02      = @GT_DISPLAY-VKBUR
*     AND FLD_03      = @LV_KUNNR.
*  IF LV_CHK IS NOT INITIAL.
*    IF LV_CHK LT SY-DATLO.
*      CONCATENATE P_SPMON ':' TEXT-E02 INTO LV_MSG.
*      MESSAGE S001 WITH LV_MSG DISPLAY LIKE 'E'.EXIT.
*    ENDIF.
*  ELSE.
*    CONCATENATE P_SPMON '01' INTO LV_SDT.
*    APPEND 'LS' TO LT_CALD.
*    CALL FUNCTION 'DATE_CONVERT_TO_WORKINGDAY'
*      EXPORTING
*        DATE              = LV_SDT
*        DIRECTION         = '+'
*      IMPORTING
*        WORKINGDAY        = LV_EDT
*      TABLES
*        FACTORY_CALENDARS = LT_CALD.
*    IF SY-DATLO GT LV_EDT.
*      CONCATENATE P_SPMON ':' TEXT-E02 INTO LV_MSG.
*      MESSAGE S001 WITH LV_MSG DISPLAY LIKE 'E'.EXIT.
*    ENDIF.
*  ENDIF.

  IF gt_display-compl NE 'Y'.
    MESSAGE s001 WITH '마감 확정된 데이터가 아닙니다.'  DISPLAY LIKE 'E'.EXIT.
  ENDIF.

  "거래처코드" & "거래처 이름" & P_SPMON & "마감 확정 하시겠습니까?"
  CONCATENATE '[' gt_display-kunnr  gt_display-name1 ']' ':' p_spmon
              TEXT-m02 INTO lv_msg SEPARATED BY space.
  CLEAR gv_answer.
  gv_answer = zgtsd_cl_common=>popup_to_comfirm( iv_ucomm = space iv_messa = lv_msg ).
  CHECK gv_answer EQ zgtsd_j.

  SELECT SINGLE * INTO @ls_1080
    FROM zgtsdt1080
   WHERE spmon EQ @p_spmon
     AND bupla EQ @gt_display-branch
     AND vkbur EQ @gt_display-vkbur
     AND vtweg EQ @gt_display-vtweg
     AND vkgrp EQ @gt_display-vkgrp
     AND kdkg4 EQ @gt_display-kdkg4
     AND kunnr EQ @gt_display-kunnr.
  IF sy-subrc = 0.
    zgtsd_cl_common=>set_timestamp( EXPORTING iv_gubun = zgtsd_u
                                    CHANGING  cs_timestamp = ls_1080-timestamp ).
  ELSE.

    ls_1080-spmon = p_spmon.
    ls_1080-bupla = gt_display-branch.
    ls_1080-vkbur = gt_display-vkbur.
    ls_1080-vtweg = gt_display-vtweg.
    ls_1080-vkgrp = gt_display-vkgrp.
    ls_1080-kdkg4 = gt_display-kdkg4.
    ls_1080-kunnr = gt_display-kunnr.
    zgtsd_cl_common=>set_timestamp( EXPORTING iv_gubun = zgtsd_c
                                    CHANGING  cs_timestamp = ls_1080-timestamp ).
  ENDIF.
  ls_1080-sales_closing = 'N'.
  MODIFY zgtsdt1080 FROM ls_1080.


  MESSAGE s000(zgtsd01) WITH  '확정 취소 되었습니다.'.

  gt_display-compl = 'N'.
  gt_display-pod_stat = icon_led_yellow.
  MODIFY gt_display TRANSPORTING compl pod_stat WHERE chk = 'X'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROG_LOCK
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LV_LOCK
*&---------------------------------------------------------------------*
FORM prog_lock  USING    pv_lock
                         pv_prog.

  DATA : lv_nametxt TYPE user_addr-name_textc,
         lv_kunnr   TYPE kunnr,
         lv_err     TYPE flag.

  PERFORM check_lock_code USING    pv_prog
                          CHANGING lv_nametxt lv_kunnr lv_err.
  IF lv_err EQ 'X'.
    MESSAGE i103(zgtsd01) WITH lv_nametxt lv_kunnr DISPLAY LIKE 'E'.
    pv_lock = 'X'.
    RETURN.
  ENDIF.

  CALL FUNCTION 'ENQUEUE_EZGT_ZGTSD1080'
    EXPORTING
      mandt          = sy-mandt
      prog           = pv_prog
      vkbur          = gt_display-vkbur
      vkgrp          = gt_display-vkgrp
      kunnr          = gt_display-kunnr
      spmon          = p_spmon
    EXCEPTIONS
      foreign_lock   = 1
      system_failure = 2
      OTHERS         = 3.

  CASE sy-subrc.
    WHEN 0.

    WHEN 1.
      PERFORM get_lock_user USING    pv_prog
                            CHANGING lv_nametxt.

      MESSAGE i103(zgtsd01) WITH lv_nametxt gt_display-kunnr DISPLAY LIKE 'E'.
      pv_lock = 'X'.
      RETURN.

    WHEN OTHERS.
      MESSAGE s098(zgtsd01) DISPLAY LIKE 'E'.
      LEAVE LIST-PROCESSING.
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_LOCK_CODE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM check_lock_code USING pv_prog TYPE cprog
                  CHANGING pv_nametxt pv_code  pv_err.

  DATA : lt_enq  TYPE TABLE OF seqg3.

  CLEAR : pv_nametxt, pv_code, pv_err.

  CALL FUNCTION 'ENQUEUE_READ'
    EXPORTING
      gname                 = CONV eqegraname( |ZGTSDS1080| )
*     GARG                  = LV_GARG
      guname                = space
    TABLES
      enq                   = lt_enq
    EXCEPTIONS
      communication_failure = 1
      system_failure        = 2
      OTHERS                = 3.

  CHECK sy-subrc EQ 0.

  LOOP AT lt_enq INTO DATA(ls_enq).
    TRY.
        CHECK ls_enq-garg+00(03) EQ sy-mandt   AND
              ls_enq-garg+03(40) EQ pv_prog    AND
              ls_enq-garg+43(04) EQ gt_display-vkbur AND
              ls_enq-garg+47(03) EQ gt_display-vkgrp AND
              ls_enq-garg+50(10) EQ gt_display-kunnr AND
              ls_enq-garg+60(06) EQ p_spmon.
      CATCH cx_root INTO DATA(lo_err).
        MESSAGE s000 WITH lo_err->get_longtext( ).
    ENDTRY.
    pv_code = ls_enq-garg+50(10).
    pv_err  = 'X'.  EXIT.

  ENDLOOP.

  CHECK pv_err EQ 'X'.

  SELECT SINGLE bname && '(' && name_textc && ')' INTO @pv_nametxt
    FROM user_addr
   WHERE bname EQ @ls_enq-guname.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form GET_LOCK_USER
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_lock_user USING pv_prog TYPE cprog
                CHANGING pv_nametxt.

  DATA : lt_enq  TYPE TABLE OF seqg3.

  CLEAR pv_nametxt.

  CALL FUNCTION 'ENQUEUE_READ'
    EXPORTING
      gname                 = CONV eqegraname( |ZGTSDS1080| )
*     GARG                  = LV_GARG
      guname                = space
    TABLES
      enq                   = lt_enq
    EXCEPTIONS
      communication_failure = 1
      system_failure        = 2
      OTHERS                = 3.

  CHECK sy-subrc EQ 0.

  LOOP AT lt_enq INTO DATA(ls_enq).
    TRY.
        CHECK ls_enq-garg+00(03) EQ sy-mandt         AND
              ls_enq-garg+03(40) EQ pv_prog          AND
              ls_enq-garg+43(04) EQ gt_display-vkbur AND
              ls_enq-garg+47(03) EQ gt_display-vkgrp AND
              ls_enq-garg+50(10) EQ gt_display-kunnr AND
              ls_enq-garg+60(06) EQ p_spmon.
      CATCH cx_root INTO DATA(lo_err).
        MESSAGE s000 WITH lo_err->get_longtext( ).
    ENDTRY.
    SELECT SINGLE bname && '(' && name_textc && ')' INTO @pv_nametxt
      FROM user_addr
     WHERE bname EQ @ls_enq-guname.
*    PV_NAMETXT = LS_ENQ-GUNAME.
    EXIT.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROG_UNLOCK
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM prog_unlock USING pv_prog.

  CALL FUNCTION 'DEQUEUE_EZGT_ZGTSD1080'
    EXPORTING
      mandt = sy-mandt
      prog  = pv_prog
      vkbur = gt_display-vkbur
      vkgrp = gt_display-vkgrp
      kunnr = gt_display-kunnr
      spmon = p_spmon.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CALL_DELIVERY_INPUT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM call_delivery_input .
  CLEAR gv_cflag.
  CALL SCREEN 0300 STARTING AT 20 1 ENDING AT 160 34.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CREATE_EVENT_RECEIVER
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GO_GRID
*&---------------------------------------------------------------------*
FORM create_event_receiver  USING po_sender TYPE REF TO cl_gui_alv_grid.

  "Create Event
  CALL METHOD po_sender->register_edit_event
    EXPORTING
      i_event_id = cl_gui_alv_grid=>mc_evt_modified.

*  CALL METHOD g_grid->register_edit_event
*    EXPORTING
*      i_event_id = cl_gui_alv_grid=>mc_evt_enter.

*// Event Handler 등록
  DATA(lo_event) = NEW lcl_event_handler( ).
  SET HANDLER lo_event->handle_data_changed          FOR po_sender.
  SET HANDLER lo_event->handle_data_changed_finished FOR po_sender.
  SET HANDLER lo_event->handle_double_click          FOR po_sender.

  "Data Changed Event
  po_sender->register_edit_event( cl_gui_alv_grid=>mc_evt_modified ).
  po_sender->register_edit_event( cl_gui_alv_grid=>mc_evt_enter ).

  "Set Ready for Input
*  PO_SENDER->SET_READY_FOR_INPUT( SWITCH #( GV_EDIT WHEN ZGTSD_X THEN 1 ELSE 0 ) ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_FIELDCATALOG_POP
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_fieldcatalog_pop .

  SORT gt_fcat BY fieldname.

  PERFORM reset_field_catalog TABLES gt_fcat USING :

      'S' 'FIELDNAME'   'VBELN',
      ' ' 'COLTEXT'     '오더번호',
      'E' 'OUTPUTLEN'   '10',

      'S' 'FIELDNAME'   'POSNR',
      ' ' 'COLTEXT'     '오더항목번호',
      'E' 'OUTPUTLEN'   '10',

      'S' 'FIELDNAME'   'VBEVL',
      ' ' 'COLTEXT'     '납품문서',
      'E' 'OUTPUTLEN'   '20',

      'S' 'FIELDNAME'   'POSVL',
      ' ' 'COLTEXT'     '납품항목번호',
      'E' 'OUTPUTLEN'   '20',

      'S' 'FIELDNAME'   'MATNR',
      ' ' 'COLTEXT'     '자재코드',
      'E' 'OUTPUTLEN'   '20',

      'S' 'FIELDNAME'   'MAKTX',
      ' ' 'COLTEXT'     '자재내역',
      'E' 'OUTPUTLEN'   '20',

      'S' 'FIELDNAME'   'LFIMG',
      ' ' 'COLTEXT'     '납품수량',
      ' ' 'QFIELDNAME' 'VRKME',
      ' ' 'DO_SUM'     'X',
      'E' 'OUTPUTLEN'   '10',

      'S' 'FIELDNAME'   'VRKME',
      ' ' 'COLTEXT'     '단위',
      'E' 'OUTPUTLEN'   '10',

      'S' 'FIELDNAME'   'SIT_AMT',
      ' ' 'COLTEXT'     '금액',
      ' ' 'CFIELDNAME' 'WAERK',
      'E' 'OUTPUTLEN'   '10',

      'S' 'FIELDNAME'   'WAERK',
      ' ' 'COLTEXT'     '단위',
      'E' 'OUTPUTLEN'   '10',

      'S' 'FIELDNAME'   'CHARG',
      ' ' 'COLTEXT'     '배치번호',
      'E' 'OUTPUTLEN'   '10',

      'S' 'FIELDNAME'   'SIT_GI',
      ' ' 'COLTEXT'     '운송중재고수량',
      ' ' 'QFIELDNAME' 'VRKME',
      'E' 'OUTPUTLEN'   '10',

      'S' 'FIELDNAME'   'WADAT_IST',
      ' ' 'COLTEXT'     'POD/Billing일자',
      'E' 'OUTPUTLEN'   '10',

      'S' 'FIELDNAME'   'ZLFIMG',
      ' ' 'COLTEXT'     '인수예정수량',
      ' ' 'QFIELDNAME'  'VRKME',
      ' ' 'EDIT'        'X',
      ' ' 'NO_ZERO'     'X',
      ' ' 'REF_TABLE'   'ZGTSDT1070',
      ' ' 'REF_FIELD'   'ZLFIMG',
      'E' 'OUTPUTLEN'   '10',

      'S' 'FIELDNAME'   'ZERDAT',
      ' ' 'COLTEXT'     '인수예정일자',
      ' ' 'REF_TABLE'   'ZGTSDT1070',
      ' ' 'REF_FIELD'   'ZERDAT',
      ' ' 'EDIT'        'X',
      'E' 'OUTPUTLEN'   '10',

      'S' 'FIELDNAME'   'ZCONF',
      ' ' 'COLTEXT'     '인수협의내용',
      ' ' 'REF_TABLE'   'ZGTSDT1070',
      ' ' 'REF_FIELD'   'ZCONF',
      ' ' 'EDIT'        'X',
      'E' 'OUTPUTLEN'   '10'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form RESET_FIELD_CATALOG
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM reset_field_catalog TABLES pt_fcat TYPE lvc_t_fcat
                         USING  pv_flag
                                pv_fname
                                pv_value.

  STATICS : ls_fcat   TYPE lvc_s_fcat,
            lv_colpos TYPE lvc_colpos,
            lv_tabix  TYPE sytabix.

  IF pv_flag = zgtsd_s.  "Start
    CLEAR ls_fcat.
    READ TABLE pt_fcat INTO ls_fcat WITH KEY fieldname = pv_value BINARY SEARCH.
    CHECK sy-subrc = 0.
    lv_tabix = sy-tabix.

    lv_colpos = lv_colpos + 1.

    ls_fcat-tech    = space.
    ls_fcat-col_pos = lv_colpos.
  ENDIF.

  CASE pv_fname.
    WHEN 'COLTEXT'.   "Text
      ls_fcat-coltext  = pv_value.
      ls_fcat-reptext  = pv_value.
      ls_fcat-seltext  = pv_value.
      ls_fcat-tooltip  = pv_value.
    WHEN OTHERS.
      ASSIGN COMPONENT pv_fname OF STRUCTURE ls_fcat TO FIELD-SYMBOL(<lv_value>).
      CHECK sy-subrc = 0.
      <lv_value> = pv_value.
  ENDCASE.

  IF pv_flag = zgtsd_e.  "End
    MODIFY pt_fcat FROM ls_fcat INDEX lv_tabix.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SAVE_PROCESS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM save_process .

  DATA : lv_msg   TYPE char200,
         lv_spmon TYPE spmon,
         lv_err,
         lt_1070  TYPE TABLE OF zgtsdt1070 WITH HEADER LINE.

  LOOP AT <gfs_data> INTO gs_s0100.
    IF gs_s0100-zerdat IS INITIAL.
      MESSAGE s007(zgtsd01) WITH '인수예정일자' DISPLAY LIKE 'E'.
      lv_err = |X|.EXIT.
    ELSE.
      lv_spmon = gs_s0100-zerdat.
      IF lv_spmon <= p_spmon.
        MESSAGE s001 WITH '인수예정일자를 최신정보로 업데이트 해야 합니다.' DISPLAY LIKE 'E'.
        lv_err = |X|.EXIT.
      ENDIF.
    ENDIF.
  ENDLOOP.

  CHECK lv_err IS INITIAL.
  READ TABLE gt_display WITH KEY chk = 'X'.
  "거래처코드" & "거래처 이름" & P_SPMON & "마감 확정 하시겠습니까?"
  CONCATENATE '[' gt_display-kunnr  gt_display-name1 ']' ':' p_spmon
              TEXT-m01 INTO lv_msg SEPARATED BY space.
  CLEAR gv_answer.
  gv_answer = zgtsd_cl_common=>popup_to_comfirm( iv_ucomm = space iv_messa = lv_msg ).
  CHECK gv_answer EQ zgtsd_j.

***********************************************************************
**협의 내용 저장
***********************************************************************
  LOOP AT <gfs_data> INTO gs_s0100.

    MOVE-CORRESPONDING gs_s0100 TO lt_1070.
    GET TIME STAMP FIELD lt_1070-zckey.

    lt_1070-vbeln = gs_s0100-vbevl.
    lt_1070-posnr = gs_s0100-posvl.
    lt_1070-matnr = gs_s0100-matnr.
    lt_1070-meins = gs_s0100-vrkme.

    zgtsd_cl_common=>set_timestamp( EXPORTING iv_gubun = zgtsd_c
                                     CHANGING cs_timestamp = lt_1070-timestamp ).
    APPEND lt_1070. CLEAR lt_1070.

  ENDLOOP.

  IF lt_1070[] IS NOT INITIAL.
    MODIFY zgtsdt1070 FROM TABLE lt_1070.
  ENDIF.

  gv_cflag = 'Y'.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form MULTI_INPUT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM multi_input .

  DATA : lv_subrc TYPE sy-subrc.

*  "Selected Rows
*  DATA(LT_ROWS) = ZGTSD_CL_COMMON=>GET_SELECTED_ROWS( EXPORTING
*                                                        IO_GRID = GO_GRID
*                                                        IV_CK   = ZGTSD_X
*                                                      IMPORTING
*                                                        EV_SUBRC = LV_SUBRC ).
*  CHECK LV_SUBRC IS INITIAL.
*
*  LOOP AT LT_ROWS INTO DATA(LS_ROW).
*    READ TABLE <GFS_DATA> INTO GS_S0100 INDEX LS_ROW-INDEX.
*    CHECK SY-SUBRC = 0.
*    GS_S0100-SEL = GC_X.
*    MODIFY <GFS_DATA> FROM GS_S0100 INDEX LS_ROW-INDEX.
*  ENDLOOP.

  LOOP AT <gfs_data> INTO gs_s0100.
    gs_s0100-zlfimg = gs_s0100-lfimg.       "인수 예정 수량 "
    gs_s0100-zerdat = gs_s0300-zerdat.       "인수예정일자 "
    gs_s0100-zconf  = gs_s0300-zconf.        "인수협의내용 "
    MODIFY <gfs_data> FROM gs_s0100.
  ENDLOOP.

*  CLEAR GS_S0100.
*  MODIFY <GFS_DATA> FROM GS_S0100 TRANSPORTING SEL WHERE SEL IS NOT INITIAL.

  MESSAGE s001 WITH '처리되었습니다.'.
  PERFORM refresh_table_display USING go_grid space.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form REFRESH_TABLE_DISPLAY
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM refresh_table_display USING po_grid TYPE REF TO cl_gui_alv_grid
                                 pv_soft_refresh.

  CHECK po_grid IS BOUND.

  CALL METHOD po_grid->refresh_table_display
    EXPORTING
      is_stable      = CONV #( 'XX' )
      i_soft_refresh = pv_soft_refresh
    EXCEPTIONS
      finished       = 1
      OTHERS         = 2.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form FREE_OBJ
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM free_obj .

* Field Catalog
  CLEAR: gt_fcat[].

* Grid Clear
  CALL METHOD: go_grid->free.

  CLEAR: go_grid.

* Container Clear
  CALL METHOD: go_con->free.

  CLEAR: go_con.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form COLLECT_DELDATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM collect_deldata USING p_conv.

  DATA : l_shkzg     LIKE vbrp-shkzg,
         l_vf_fkimg  LIKE vbrp-fkimg,
         l_sum_fkimg LIKE vbrp-fkimg,
         lv_menge2   LIKE lips-lfimg,
         lv_input    TYPE f,
         lv_output   TYPE f,
         lv_rtype    LIKE vtbleiste-rtype,
         lt_join     LIKE TABLE OF gt_deldata WITH EMPTY KEY.

  DATA : BEGIN OF ls_lips,
           vbeln TYPE lips-vbeln,
           posnr TYPE lips-posnr,
           uecha TYPE lips-uecha,
           lfimg TYPE lips-lfimg,
           charg TYPE lips-charg,
         END OF ls_lips,
         lt_lips LIKE TABLE OF ls_lips WITH NON-UNIQUE SORTED KEY k_key COMPONENTS vbeln uecha.

  DATA : BEGIN OF ls_vbrp,
           vgbel TYPE vbrp-vgbel,
           vgpos TYPE vbrp-vgpos,
           fkimg TYPE vbrp-fkimg,
           shkzg TYPE vbrp-shkzg,
         END OF ls_vbrp,
         lt_vbrp LIKE TABLE OF ls_vbrp WITH NON-UNIQUE SORTED KEY k_key COMPONENTS vgbel vgpos.

  DATA(lt_for) = gt_deldata[].
  SORT lt_for BY vbeln posnr.
  DELETE ADJACENT DUPLICATES FROM lt_for COMPARING vbeln.
  IF lt_for[] IS NOT INITIAL.
    SELECT vbeln, posnr, uecha, lfimg, charg
      FROM lips
       FOR ALL ENTRIES IN @lt_for
     WHERE vbeln = @lt_for-vbeln
      INTO CORRESPONDING FIELDS OF TABLE @lt_lips.

    SELECT vbeln INTO TABLE @DATA(lt_likp)
      FROM likp
       FOR ALL ENTRIES IN @lt_for
     WHERE vbeln = @lt_for-vbeln
       AND faksk NOT IN (' ', '10' ).

    SELECT vbeln INTO TABLE @DATA(lt_vbak)
      FROM vbak
       FOR ALL ENTRIES IN @lt_for
     WHERE vbeln = @lt_for-vgbel
       AND  faksk NOT IN (' ', '10' ).

  ENDIF.

  lt_for[] = gt_deldata[].
  SORT lt_for BY vbeln posnr.
  DELETE ADJACENT DUPLICATES FROM lt_for COMPARING vbeln posnr.
  IF lt_for[] IS NOT INITIAL.
    SELECT a~vgbel, a~vgpos, a~fkimg, a~shkzg
      FROM vbrp AS a INNER JOIN vbrk AS b
        ON a~vbeln = b~vbeln
       FOR ALL ENTRIES IN @lt_for
     WHERE a~vgbel = @lt_for-vbeln
       AND a~vgpos = @lt_for-posnr
       AND a~draft = @space
       AND b~fksto EQ @space
       AND b~sfakn EQ @space
      INTO CORRESPONDING FIELDS OF TABLE @lt_vbrp.
  ENDIF.

  SORT lt_likp BY vbeln.
  SORT lt_vbak BY vbeln.

  LOOP AT gt_deldata.

** 통화별 자리수계산
    CLEAR : gv_point.
    PERFORM decimal_point_compute USING gt_deldata-waerk.

    CLEAR : l_shkzg, l_vf_fkimg, l_sum_fkimg.

    MOVE-CORRESPONDING gt_deldata TO lt_display.

    IF gt_deldata-charg EQ ' ' AND gt_deldata-lfimg IS INITIAL.

      gt_deldata-lfimg = REDUCE #( INIT lv_qty TYPE lfimg
                                    FOR ls_do IN lt_lips
                                  USING KEY k_key
                                  WHERE ( vbeln = gt_deldata-vbeln
                                    AND   uecha = gt_deldata-posnr )
                                   NEXT lv_qty = lv_qty + ls_do-lfimg ).
    ENDIF.

** 무상빌링미처리 Check
    IF  gt_deldata-netwr IS INITIAL  OR
        gt_deldata-netwr EQ 0.
      gt_deldata-zflag1  =  'O'.
      lt_display-vbeln_a =  gt_deldata-vgbel.
      lt_display-zflag1  =  'O'.
    ELSE.
      gt_deldata-zflag1  =  space.
      lt_display-vbeln_a =  space.
      lt_display-zflag1  =  space.
    ENDIF.

** 대금청구수량
    l_sum_fkimg = REDUCE #( INIT lv_qty TYPE lfimg
                             FOR ls_vf IN lt_vbrp
                           USING KEY k_key
                           WHERE ( vgbel = gt_deldata-vbeln
                             AND   vgpos = gt_deldata-posnr )
                            NEXT lv_qty = lv_qty + COND fkimg( WHEN ls_vf-shkzg = 'X' THEN ls_vf-fkimg * -1
                                                               ELSE ls_vf-fkimg )  ).
    IF  sy-subrc  <>  0.
      l_sum_fkimg  =  0.
    ENDIF.

** 잔량 : 납품수량 - 청구수량
    IF  gt_deldata-fkrel  =  'K'.
      lv_menge2  =  gt_deldata-lfimg  -  l_sum_fkimg.
    ELSE.
      lv_menge2  =  gt_deldata-lfimg.
    ENDIF.

    IF  pa_chk2  NE  'X'.
** 주문수량과 납품수량이 다를경우는 원래대로 Function을 이용

      IF  gt_deldata-auart  EQ  'RE' OR gt_deldata-auart  EQ  'ZRET'
       OR gt_deldata-auart  EQ  'YSRE'.

        IF  gt_deldata-kwmeng  =  lv_menge2.  " gt_deldata-lfimg.

          lt_display-netwr_a  =  gt_deldata-netwr  *  -1.
          lt_display-mwsbk_a  =  gt_deldata-mwsbk  *  -1.
          lv_input  =  lt_display-mwsbk_a.

        ELSE.
          PERFORM  invoice_amount_calc  USING lv_menge2
                                     CHANGING lv_input.
        ENDIF.

      ELSE.

        PERFORM  invoice_amount_calc  USING lv_menge2
                                   CHANGING lv_input.

      ENDIF.
    ENDIF.

    "부스덕트 분할출고시
    IF gt_deldata-kwmeng <> gt_deldata-lfimg AND gt_deldata-pod = 'X'.
      PERFORM invoice_biusduct_amt_cals USING gt_deldata-vbeln
                                              gt_deldata-posnr
                                        CHANGING lt_display-netwr_a
                                                  lv_input.
    ENDIF.

    IF  gt_deldata-waerk  =  'KRW'.
      lv_input  =  lv_input  *  100.
    ENDIF.

    lv_rtype = '-'.  "버림.

    PERFORM fima_numerical_value_round USING lv_rtype
                                             lv_input
                                       CHANGING lv_output.

    lt_display-mwsbk_a = lv_output.

    IF  gt_deldata-waerk  =  'KRW'  AND
        lt_display-mwsbk_a  NE  0.
      lt_display-mwsbk_a  =  lt_display-mwsbk_a  /  100.
    ENDIF.

    READ TABLE lt_likp INTO DATA(ls_vl) WITH KEY vbeln = gt_deldata-vbeln BINARY SEARCH.
    IF sy-subrc EQ 0.
      lt_display-vbeln_a = ls_vl-vbeln.
      lt_display-cstop = 'O'.
    ELSE.
      READ TABLE lt_vbak INTO DATA(ls_va) WITH KEY vbeln = gt_deldata-vgbel BINARY SEARCH.
      IF sy-subrc EQ 0.
        lt_display-vbeln_a = ls_va-vbeln.
        lt_display-cstop = 'O'.
      ENDIF.
    ENDIF.

** L/C별 리스트로 넘어갈때 잔량을 계산한 금액 및 Tax가 넘겨야
** 되므로 금액 및 Tax를 가지고 있는다.
    gt_deldata-r_netwr  =  lt_display-netwr_a.
    gt_deldata-r_mwsbk  =  lt_display-mwsbk_a.

    MODIFY gt_deldata.

*외화금액 변환
    IF p_conv NE 'X'.
      IF gt_deldata-waerk NE 'KRW'.

        lt_display-netwr_a = lt_display-netwr_a  *
                             gt_deldata-kurrf  *  gv_point.
        lt_display-mwsbk_a = lt_display-mwsbk_a  *
                             gt_deldata-kurrf  *  gv_point.
        IF  gt_deldata-waerk EQ 'JPY'.
          lt_display-netwr_a = lt_display-netwr_a / 100.
        ENDIF.

        lv_rtype = ' '.  "반올림.

        DO 2 TIMES.
          IF sy-index = 1.
            lv_input = lt_display-netwr_a.
          ELSE.
            lv_input = lt_display-mwsbk_a.
          ENDIF.

          PERFORM fima_numerical_value_round USING lv_rtype
                                                   lv_input
                                             CHANGING lv_output.
          IF sy-index = 1.
            lt_display-netwr_a = lv_output.
          ELSE.
            lt_display-mwsbk_a = lv_output.
          ENDIF.
        ENDDO.
      ENDIF.
    ENDIF.
    lt_display-sumamt_a = lt_display-netwr_a + lt_display-mwsbk_a.

    APPEND lt_display.

    CLEAR : gt_deldata, lt_display.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_FIELDCATALOG_POP2
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_fieldcatalog_pop2 .

  SORT gt_fcat BY fieldname.

  PERFORM reset_field_catalog TABLES gt_fcat USING :

      'S' 'FIELDNAME' 'AUART',
      ' ' 'COLTEXT'   '오더유형',
      ' ' 'OUTPUTLEN'   '5',
      ' ' 'COL_POS'     '1',
      'E' 'KEY'         'X',

      'S' 'FIELDNAME' 'BEZEI',
      ' ' 'COLTEXT'   '오더유형명',
      ' ' 'OUTPUTLEN'   '10',
      'E' 'COL_POS'     '2',

      'S' 'FIELDNAME' 'VGBEL',
      ' ' 'COLTEXT'   '주문번호',
      ' ' 'OUTPUTLEN'   '10',
      ' ' 'COL_POS'     '3',
      'E' 'KEY'         'X',

      'S' 'FIELDNAME' 'VGPOS',
      ' ' 'COLTEXT'   '주문품목',
      ' ' 'OUTPUTLEN'   '8',
      ' ' 'COL_POS'     '4',
      'E' 'KEY'         'X',

      'S' 'FIELDNAME' 'KWMENG',
      ' ' 'COLTEXT'   '주문수량',
      ' ' 'QFIELDNAME' 'VRKME_VA',
      ' ' 'OUTPUTLEN'   '15',
      ' ' 'JUST'        'R',
      'E' 'COL_POS'     '5',

      'S' 'FIELDNAME' 'VRKME_VA',
      ' ' 'COLTEXT'   '판매단위',
      ' ' 'OUTPUTLEN'   '8',
      'E' 'COL_POS'     '6',

      'S' 'FIELDNAME' 'VBELN',
      ' ' 'COLTEXT'   '납품문서',
      ' ' 'OUTPUTLEN'   '10',
      ' ' 'COL_POS'     '7',
      'E' 'KEY'         'X',

      'S' 'FIELDNAME' 'POSNR',
      ' ' 'COLTEXT'   '납품품목',
      ' ' 'OUTPUTLEN'   '8',
      ' ' 'COL_POS'     '8',
      'E' 'KEY'         'X',

      'S' 'FIELDNAME' 'MATNR',
      ' ' 'COLTEXT'   '자재코드',
      ' ' 'OUTPUTLEN'   '18',
      'E' 'COL_POS'     '9',

      'S' 'FIELDNAME' 'MAKTX',
      ' ' 'COLTEXT'   '자재내역',
      ' ' 'OUTPUTLEN'   '25',
      'E' 'COL_POS'     '10',

      'S' 'FIELDNAME' 'LFIMG',
      ' ' 'COLTEXT'   '납품수량',
      ' ' 'QFIELDNAME' 'VRKME',
      ' ' 'OUTPUTLEN'   '15',
      ' ' 'JUST'        'R',
      'E' 'COL_POS'     '11',

      'S' 'FIELDNAME' 'VRKME',
      ' ' 'COLTEXT'   '판매단위',
      ' ' 'OUTPUTLEN'   '8',
      'E' 'COL_POS'     '12',

      'S' 'FIELDNAME' 'NETWR',
      ' ' 'COLTEXT'   '청구액',
      ' ' 'CFIELDNAME' 'WAERK',
      ' ' 'OUTPUTLEN'   '15',
      ' ' 'JUST'        'R',
      'E' 'COL_POS'     '13',

      'S' 'FIELDNAME' 'WAERK',
      ' ' 'COLTEXT'   '통화',
      'E' 'COL_POS'     '14',


      'S' 'FIELDNAME' 'POD_STAT',
      'E' 'NO_OUT'     'X',

      'S' 'FIELDNAME' 'FKSTA',
      'E' 'NO_OUT'     'X'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CALL_BILLING_SCREEN2
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM call_billing_screen2 USING pv_subrc.
  DATA: lv_lock,
        lv_sdt  TYPE sy-datum,
        lv_edt  TYPE sy-datum.

  DATA : l_data   TYPE REF TO data.

  RANGES lr_wadt FOR likp-wadat_ist.

  CLEAR : g_h_fkdat, gs_s0400.
  REFRESH: gt_t0400.


  CLEAR : r_kunnr, r_kunnr[].
  r_kunnr-sign    =  'I'.
  r_kunnr-option  =  'EQ'.
  r_kunnr-low     = gt_display-kunnr.
  APPEND r_kunnr.

  g_h_fkdat  =  r_fkdat-high.

  SELECT vbap~auart_ana AS auart,
         tvakt~bezei,
         vbap~vbeln AS vgbel,
         vbap~posnr AS vgpos,
         vbap~kwmeng,
         vbap~vrkme AS vrkme_va,
         lips~vrkme,
         lips~vbeln, "납품문서번호
         lips~posnr, "품목
         lips~matnr, "자재
         vbap~arktx AS maktx, "자재명
         lips~lfimg, "납품수량
         vbap~netwr, "청구액
         vbap~waerk, "통화
         lips~fksta "대금청구상태
  INTO CORRESPONDING FIELDS OF TABLE @gt_t0400
   FROM  lips INNER JOIN likp ON likp~vbeln = lips~vbeln
                  JOIN vbap ON vbap~vbeln = lips~vgbel
                           AND vbap~posnr = lips~vgpos
                  JOIN vbak ON vbak~vbeln = lips~vgbel
                  JOIN vbkd ON vbkd~vbeln = vbap~vbeln
                           AND vbkd~posnr = '0'
                  JOIN vkdfs ON vkdfs~vbeln = lips~vbeln
              LEFT OUTER JOIN tvakt ON vbap~auart_ana = tvakt~auart
                                    AND tvakt~spras = @sy-langu
   WHERE  likp~kunag IN @r_kunnr
     AND  likp~vkorg EQ @p_vkorg
     AND  lips~vtweg EQ @gt_display-vtweg
     AND  lips~spart EQ @p_spart
     AND  vbak~vkbur EQ @gt_display-vkbur
     AND  vbak~vkgrp EQ @gt_display-vkgrp
     AND  likp~wadat_ist IN @r_fkdat
     AND  likp~wbstk EQ 'C'
     AND  lips~fksta NE 'C'
     AND  lips~bwart NE '687'
     AND  vbkd~kdkg4 EQ @gt_display-kdkg4
     AND  vkdfs~fktyp EQ 'L'
     AND  lips~fkrel IN ('K', 'A', 'H')
     AND  vbak~auart NOT IN ('KB', 'KA', 'ZCS', 'VSH1', 'LA',
                             'CQ', 'WK1', 'ZCKB', 'ZITD', 'IN',
                             'ZIPD', 'ZBC1', 'ZBC3', 'QT').

  "차변, 대변 추가
  SELECT vbap~auart_ana AS auart,
         tvakt~bezei,
         vbap~vbeln AS vgbel,
         vbap~posnr AS vgpos,
         vbap~zmeng AS kwmeng,
         vbap~vrkme AS vrkme_va,
         vbap~matnr, "자재
         vbap~arktx AS maktx, "자재명
         vbap~netwr, "청구액
         vbap~waerk "통화
  APPENDING CORRESPONDING FIELDS OF TABLE @gt_t0400
   FROM  vbap INNER JOIN vbak ON vbak~vbeln = vbap~vbeln
                  JOIN vbkd ON vbkd~vbeln = vbap~vbeln
                           AND vbkd~posnr = '0'
              LEFT OUTER JOIN tvakt ON vbap~auart_ana = tvakt~auart
                                    AND tvakt~spras = @sy-langu
   WHERE  vbak~kunnr IN @r_kunnr
     AND  vbak~vkorg EQ @p_vkorg
     AND  vbak~vtweg EQ @gt_display-vtweg
     AND  vbak~spart EQ @p_spart
     AND  vbak~vkbur EQ @gt_display-vkbur
     AND  vbak~vkgrp EQ @gt_display-vkgrp
     AND  vbkd~fkdat IN @r_fkdat
     AND  vbkd~kdkg4 EQ @gt_display-kdkg4
     AND  vbak~auart IN ('CR', 'DR', 'ZCR', 'ZDR', 'G2', 'L2')
     AND  vbap~fksaa = 'A'.


  IF gt_t0400 IS NOT INITIAL.
    MESSAGE i001 WITH 'Billing이 미생성된 오더가 존재합니다.' DISPLAY LIKE 'W'.
    CLEAR: gv_flag.

    DATA lv_lines TYPE i.
    DESCRIBE TABLE gt_t0400 LINES lv_lines.

    DATA(lv_height) = lv_lines + 5.
    IF lv_height > 20.
      lv_height = 20.
    ENDIF.
    CALL SCREEN 0400 STARTING AT 20 1 ENDING AT 140 lv_height.
    pv_subrc = 4.
  ELSE.
    CLEAR: pv_subrc.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form FREE_OBJ2
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM free_obj2 .
* Field Catalog
  CLEAR: gt_fcat[].

* Grid Clear
  CALL METHOD: go_grid2->free.

  CLEAR: go_grid2.

* Container Clear
  CALL METHOD: go_con2->free.

  CLEAR: go_con2.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form TOOBAR_PROS_TAB08
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> R_OBJECT
*&      --> R_INTERACTIVE
*&      --> LS_TOOLBAR
*&---------------------------------------------------------------------*
FORM toobar_pros_tab08  USING     r_object
                                TYPE REF TO cl_alv_event_toolbar_set
                                r_interactive
                                ls_toolbar TYPE stb_button.
*// 내수/로칼 LINK
  CLEAR ls_toolbar.
  MOVE 'ZFL01'               TO  ls_toolbar-function.
  MOVE icon_viewer_optical_archive  TO  ls_toolbar-icon.
  MOVE '내수로컬 LINK'           TO  ls_toolbar-quickinfo.
  MOVE '내수로컬 LINK'          TO  ls_toolbar-text.
  MOVE ' '                  TO  ls_toolbar-disabled.
  APPEND ls_toolbar         TO  r_object->mt_toolbar.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form CALL_4L_SCREEN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM call_4l_screen .
*4D	Domestic
*4L	내수 Local
  DATA  : ls_check_billto.
  DATA : lv_sdt  TYPE sy-datum,
         lv_edt  TYPE sy-datum,
         lv_lock.

  DATA : l_data   TYPE REF TO data.

  RANGES lr_wadt FOR likp-wadat_ist.

  CLEAR : g_h_fkdat, ls_check_billto.

*-- 마감확정 상태의 경우 '내수/로컬 Billing' 처리 불가  - Start 250807
  READ TABLE gt_display WITH KEY chk   = 'X'
                                 compl = 'Y'.
  CHECK gt_display-kdkg4 <> '4S'.
  IF sy-subrc EQ 0.
    MESSAGE e001 WITH '마감확정 상태에서는 Billing 처리가 불가능합니다.'.
  ENDIF.
*-- 마감확정 상태의 경우 '내수/로컬 Billing' 처리 불가  - End 250807

  ls_check_billto = 'Y'.

  LOOP AT gt_display WHERE chk EQ 'X'.

    IF  gt_display-sumamt_a  = '0.00'.
** Request by 최석원D : 2005-07-30
** 무상빌링건의 경우 Billing미처리금액과 무관하게 처리해야 됨.
      IF  gt_display-zflag1  NE  'O'.

        LOOP AT lt_display2 WHERE branch = gt_display-branch
                              AND vkbur  = gt_display-vkbur
                              AND vkgrp  = gt_display-vkgrp
                              AND vtweg  = gt_display-vtweg
                              AND kdkg4  = gt_display-kdkg4
                              AND kunnr  = gt_display-kunnr.

          IF lt_display2-sumamt_a NE '0.00'.
            ls_check_billto = 'N'.
          ENDIF.

        ENDLOOP.

        IF ls_check_billto = 'Y'.
          MESSAGE e001 WITH '선택한 Data를 확인하세요.'.
          EXIT.
        ENDIF.

      ENDIF.
    ENDIF.

    PERFORM check_range_value.

    IF gt_display-kdkg4 EQ '4D'.
      MESSAGE e001 WITH '내수 Data를 선택하세요'.

    ELSEIF  gt_display-kdkg4 EQ '4L'.

      g_h_fkdat  =  r_fkdat-high.

*      CALL SCREEN 3000 STARTING AT 20 10 ENDING AT 55 14.
*
*      IF  SY-UCOMM  =  'ENTE'.

      CHECK g_h_fkdat NE '00000000'.

      SUBMIT zter0200 WITH p_bukrs  = p_vkorg
                 WITH s_kunag  IN r_kunnr
                 WITH s_vkorg  IN r_vkorg
                 WITH s_vtweg  IN r_vtweg
                 WITH s_spart  IN r_spart
                 WITH s_vkbur  IN r_vkbur
                 WITH s_vkgrp  IN r_vkgrp
                 WITH pa_fkdat     = g_h_fkdat   " r_fkdat-high
                 WITH p_tcode  = sy-tcode
                 AND RETURN.

*      ENDIF.
    ENDIF.
  ENDLOOP.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form CALL_BILLING_SCREEN3
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LV_SUBRC
*&---------------------------------------------------------------------*
FORM call_billing_screen3  USING    pv_subrc.
  DATA: lv_lock.

  RANGES lr_wadt FOR likp-wadat_ist.

  RANGES : lr_vtweg  FOR vbak-vtweg,
           lr_spart  FOR vbak-spart,
           lr_branch FOR j_1bbranch-branch,
           lr_vkbur  FOR vbak-vkbur,
           lr_vkgrp  FOR vbak-vkgrp,
           lr_vbevl  FOR likp-vbeln,
           lr_wadat  FOR likp-wadat_ist,
           lr_kdkg4  FOR vbkd-kdkg4,
           lr_kunnr  FOR vbak-kunnr,
           lr_lifnr  FOR vbpa-lifnr,
           lr_ernam  FOR vbak-ernam,
           lr_erdat  FOR vbak-erdat.

  DATA : l_data   TYPE REF TO data.

  DATA : lv_sdt  TYPE sy-datum,
         lv_edt  TYPE sy-datum,
         lt_list TYPE TABLE OF abaplist,
         ls_4s   LIKE gs_s0100.

  CLEAR : g_h_fkdat, gs_s0400, ls_4s.
  REFRESH: gt_t0400.

  UNASSIGN <gfs_data>.

  CONCATENATE  p_spmon  '01'  INTO lv_sdt.

  CALL FUNCTION 'RP_LAST_DAY_OF_MONTHS'
    EXPORTING
      day_in            = lv_sdt
    IMPORTING
      last_day_of_month = lv_edt
    EXCEPTIONS
      day_in_no_date    = 1
      OTHERS            = 2.

  LOOP AT gt_display WHERE chk EQ 'X'.
    __rng : lr_vtweg 'I' 'EQ' gt_display-vtweg '',
            lr_spart 'I' 'EQ' p_spart '',
            lr_branch 'I' 'EQ' gt_display-branch '',
            lr_vkbur 'I' 'EQ' gt_display-vkbur '',
            lr_vkgrp 'I' 'EQ' gt_display-vkgrp '',
            lr_wadat 'I' 'EQ' '' lv_edt,
            lr_kdkg4 'I' 'EQ' gt_display-kdkg4 '',
            lr_kunnr 'I' 'EQ' gt_display-kunnr '',

            lr_erdat 'I' 'EQ' '' lv_edt.

    cl_salv_bs_runtime_info=>set( display  = abap_false
                            metadata = abap_false
                            data     = abap_true ).
    UNASSIGN <gfs_data>.

    SUBMIT zgtsdr1070 WITH p_vkorg   = p_vkorg
                      WITH s_vtweg  IN lr_vtweg
                      WITH s_spart  IN lr_spart
                      WITH s_branch IN lr_branch
                      WITH s_vkbur  IN lr_vkbur
                      WITH s_vkgrp  IN lr_vkgrp
                      WITH s_vbevl  IN lr_vbevl
                      WITH s_wadat  IN lr_wadat
                      WITH s_kdkg4  IN lr_kdkg4
                      WITH s_kunnr  IN lr_kunnr
                      WITH s_lifnr  IN lr_lifnr
                      WITH s_ernam  IN lr_ernam
                      WITH s_erdat  IN lr_erdat
                      AND RETURN.
    TRY.
        cl_salv_bs_runtime_info=>get_data_ref( IMPORTING r_data = l_data ).
        ASSIGN l_data->* TO <gfs_data>.
        cl_salv_bs_runtime_info=>clear_all( ).
      CATCH cx_salv_bs_sc_runtime_info.
    ENDTRY.
  ENDLOOP.

  IF <gfs_data> IS ASSIGNED.
    LOOP AT <gfs_data> ASSIGNING FIELD-SYMBOL(<ls>).
      MOVE-CORRESPONDING <ls> TO ls_4s.

      SELECT SINGLE  vbap~auart_ana AS auart,
                     tvakt~bezei,
                     vbap~vbeln AS vgbel,
                     vbap~posnr AS vgpos,
                     vbap~kwmeng,
                     vbap~vrkme AS vrkme_va,
                     lips~vrkme,
                     lips~vbeln, "납품문서번호
                     lips~posnr, "품목
                     lips~matnr, "자재
                     vbap~arktx AS maktx, "자재명
                     lips~lfimg, "납품수량
                     vbap~netwr, "청구액
                     vbap~waerk, "통화
                     lips~fksta "대금청구상태
      INTO CORRESPONDING FIELDS OF @gs_s0400
       FROM  lips INNER JOIN likp ON likp~vbeln = lips~vbeln
                      JOIN vbap ON vbap~vbeln = lips~vgbel
                               AND vbap~posnr = lips~vgpos
                      JOIN vbak ON vbak~vbeln = lips~vgbel
                      JOIN vbkd ON vbkd~vbeln = vbap~vbeln
                               AND vbkd~posnr = '0'
                      JOIN vkdfs ON vkdfs~vbeln = lips~vbeln
                  LEFT OUTER JOIN tvakt ON vbap~auart_ana = tvakt~auart
                                        AND tvakt~spras = @sy-langu
      WHERE vbap~vbeln = @ls_4s-vbeln
        AND vbap~posnr = @ls_4s-posnr
        AND  likp~wbstk EQ 'C'
        AND  lips~fksta NE 'C'
        AND  vkdfs~fktyp EQ 'L'
        AND  lips~fkrel IN ('K', 'A', 'H')
        AND  vbak~auart NOT IN ('KB', 'KA', 'ZCS', 'VSH1', 'LA',
                                 'CQ', 'WK1', 'ZCKB', 'ZITD', 'IN',
                                 'ZIPD', 'ZBC1', 'ZBC3', 'QT').

      APPEND gs_s0400 TO gt_t0400.
      CLEAR: gs_s0400, ls_4s.
    ENDLOOP.
  ENDIF.

  "BWART = 601
  SELECT vbap~auart_ana AS auart,
         tvakt~bezei,
         vbap~vbeln AS vgbel,
         vbap~posnr AS vgpos,
         vbap~kwmeng,
         vbap~vrkme AS vrkme_va,
         lips~vrkme,
         lips~vbeln, "납품문서번호
         lips~posnr, "품목
         lips~matnr, "자재
         vbap~arktx AS maktx, "자재명
         lips~lfimg, "납품수량
         vbap~netwr, "청구액
         vbap~waerk, "통화
         lips~fksta "대금청구상태
  APPENDING CORRESPONDING FIELDS OF TABLE @gt_t0400
   FROM  lips INNER JOIN likp ON likp~vbeln = lips~vbeln
                  JOIN vbap ON vbap~vbeln = lips~vgbel
                           AND vbap~posnr = lips~vgpos
                  JOIN vbak ON vbak~vbeln = lips~vgbel
                  JOIN vbkd ON vbkd~vbeln = vbap~vbeln
                           AND vbkd~posnr = '0'
                  JOIN vkdfs ON vkdfs~vbeln = lips~vbeln
              LEFT OUTER JOIN tvakt ON vbap~auart_ana = tvakt~auart
                                    AND tvakt~spras = @sy-langu
   WHERE  likp~kunag IN @r_kunnr
     AND  likp~vkorg EQ @p_vkorg
     AND  lips~vtweg EQ @gt_display-vtweg
     AND  lips~spart EQ @p_spart
     AND  vbak~vkbur EQ @gt_display-vkbur
     AND  vbak~vkgrp EQ @gt_display-vkgrp
     AND  likp~wadat_ist IN @r_fkdat
     AND  likp~wbstk EQ 'C'
     AND  lips~fksta NE 'C'
     AND  lips~bwart NE '687'
     AND  vbkd~kdkg4 EQ @gt_display-kdkg4
     AND  vkdfs~fktyp EQ 'L'
     AND  lips~fkrel IN ('K', 'A', 'H')
     AND  vbak~auart NOT IN ('KB', 'KA', 'ZCS', 'VSH1', 'LA',
                             'CQ', 'WK1', 'ZCKB', 'ZITD', 'IN',
                             'ZIPD', 'ZBC1', 'ZBC3', 'QT').

  "차변, 대변 추가
  SELECT vbap~auart_ana AS auart,
         tvakt~bezei,
         vbap~vbeln AS vgbel,
         vbap~posnr AS vgpos,
         vbap~zmeng AS kwmeng,
         vbap~vrkme AS vrkme_va,
         vbap~matnr, "자재
         vbap~arktx AS maktx, "자재명
         vbap~netwr, "청구액
         vbap~waerk "통화
  APPENDING CORRESPONDING FIELDS OF TABLE @gt_t0400
   FROM  vbap INNER JOIN vbak ON vbak~vbeln = vbap~vbeln
                  JOIN vbkd ON vbkd~vbeln = vbap~vbeln
                           AND vbkd~posnr = '0'
              LEFT OUTER JOIN tvakt ON vbap~auart_ana = tvakt~auart
                                    AND tvakt~spras = @sy-langu
   WHERE  vbak~kunnr IN @r_kunnr
     AND  vbak~vkorg EQ @p_vkorg
     AND  vbak~vtweg EQ @gt_display-vtweg
     AND  vbak~spart EQ @p_spart
     AND  vbak~vkbur EQ @gt_display-vkbur
     AND  vbak~vkgrp EQ @gt_display-vkgrp
     AND  vbkd~fkdat IN @r_fkdat
     AND  vbkd~kdkg4 EQ @gt_display-kdkg4
     AND  vbak~auart IN ('CR', 'DR', 'ZCR', 'ZDR', 'G2', 'L2')
     AND  vbap~fksaa = 'A'.

  IF gt_t0400 IS NOT INITIAL.
    MESSAGE i001 WITH 'Billing이 미생성된 오더가 존재합니다.' DISPLAY LIKE 'W'.
    CLEAR: gv_flag.

    DATA lv_lines TYPE i.
    DESCRIBE TABLE gt_t0400 LINES lv_lines.

    DATA(lv_height) = lv_lines + 5.
    IF lv_height > 20.
      lv_height = 20.
    ENDIF.
    CALL SCREEN 0400 STARTING AT 20 1 ENDING AT 140 lv_height.
    pv_subrc = 4.
  ELSE.
    CLEAR: pv_subrc.
  ENDIF.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form CALL_POD_ERROR_CHECK
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LV_SUBRC
*&---------------------------------------------------------------------*
FORM call_pod_error_check  USING    p_subrc.



  FIELD-SYMBOLS <gfs_data> TYPE STANDARD TABLE.
  DATA : l_data   TYPE REF TO data.
  DATA : lv_sdt TYPE sy-datum,
         lv_edt TYPE sy-datum.
  DATA : ls_check LIKE gt_check.
  RANGES :R_wadt FOR likp-wadat_ist.
  RANGES :r_kdkg4 FOR vbkd-kdkg4.
  RANGES :r_vkgrp FOR vbak-vkgrp.
*
  REFRESH : gt_check.

  CLEAR : r_kunnr, r_kunnr[].
  r_kunnr-sign    =  'I'.
  r_kunnr-option  =  'EQ'.
  r_kunnr-low     = gt_display-kunnr.
  APPEND r_kunnr.

  CLEAR : r_kdkg4, r_kdkg4[].
  r_kdkg4-sign    =  'I'.
  r_kdkg4-option  =  'EQ'.
  r_kdkg4-low     = gt_display-kdkg4.
  APPEND r_kdkg4.

  CLEAR : r_vkgrp, r_vkgrp[].
  r_vkgrp-sign    =  'I'.
  r_vkgrp-option  =  'EQ'.
  r_vkgrp-low     = gt_display-vkgrp.
  APPEND r_VKGRP.


  CONCATENATE  p_spmon  '01'  INTO  lv_sdt.
  CALL FUNCTION 'RP_LAST_DAY_OF_MONTHS'
    EXPORTING
      day_in            = lv_sdt
    IMPORTING
      last_day_of_month = lv_edt
    EXCEPTIONS
      day_in_no_date    = 1
      OTHERS            = 2.

  lv_sdt = '20000101'.
  __rng R_wadt 'I' 'BT' lv_sdt lv_edt.


  cl_salv_bs_runtime_info=>set( display  = abap_false
                          metadata = abap_false
                          data     = abap_true ).
  UNASSIGN <gfs_data>.

  SUBMIT zgtsdr1080_check WITH s_wadat IN r_wadt
                          WITH s_kunnr IN r_kunnr
                          WITH s_kdkg4 IN r_kdkg4
                          WITH s_vkgrp IN r_vkgrp
*                          WITH p_alv = ' '
                          AND RETURN.

  TRY.
      cl_salv_bs_runtime_info=>get_data_ref( IMPORTING r_data = l_data ).
      ASSIGN l_data->* TO <gfs_data>.
      cl_salv_bs_runtime_info=>clear_all( ).
    CATCH cx_salv_bs_sc_runtime_info.
  ENDTRY.

  IF <gfs_data> IS ASSIGNED.
    LOOP AT <gfs_data> ASSIGNING FIELD-SYMBOL(<ls>).
      CLEAR : GS_check.
      MOVE-CORRESPONDING <ls> TO Gs_check.
      APPEND GS_check TO gt_check .
    ENDLOOP.
  ENDIF.


  IF gt_check IS NOT INITIAL.
    MESSAGE i001 WITH '오류 데이터가 존재합니다.'   DISPLAY LIKE 'W'.
    CLEAR: gv_flag.
*
    DATA lv_lines TYPE i.
    DESCRIBE TABLE gt_check LINES lv_lines.

    DATA(lv_height) = lv_lines + 5.
    IF lv_height > 20.
      lv_height = 20.
    ENDIF.

    gv_check  = 'X'.
    CALL SCREEN 0400 STARTING AT 20 1 ENDING AT 140 lv_height.
    p_subrc = 4.
  ELSE.
    CLEAR: p_subrc.
  ENDIF.
*
*
ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_fieldcatalog_pop3
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_fieldcatalog_pop3 .


  SORT gt_fcat BY fieldname.

  PERFORM reset_field_catalog TABLES gt_fcat USING :


      'S' 'FIELDNAME' 'KUNNR' ,
      ' ' 'COLTEXT'   '고객코드',
      ' ' 'DDICTXT'     'L',
      ' ' 'OUTPUTLEN'   '10',
*      ' ' 'COL_POS'     '1',
      'E' 'KEY'         'X',

      'S' 'FIELDNAME' 'VGBEL'   ,
      ' ' 'COLTEXT'   '판매오더',
      ' ' 'DDICTXT'     'L',
      ' ' 'OUTPUTLEN'   '10',
*      ' ' 'COL_POS'     '2',
      'E' 'KEY'         'X',

      'S' 'FIELDNAME' 'VGPOS'   ,
      ' ' 'COLTEXT'   '품목',
      ' ' 'DDICTXT'     'L',
      ' ' 'OUTPUTLEN'   '6',
*      ' ' 'COL_POS'     '3',
      'E' 'KEY'         'X',

      'S' 'FIELDNAME' 'VBELN'   ,
      ' ' 'COLTEXT'   '납품번호',
      ' ' 'DDICTXT'     'L',
*      ' ' 'OUTPUTLEN'   '10',
*      ' ' 'COL_POS'     '4',
      'E' 'KEY'         'X',

      'S'  'FIELDNAME' 'POSNR'  ,
      ' ' 'COLTEXT'   '품목',
      ' ' 'DDICTXT'     'L',
*      ' ' 'OUTPUTLEN'   '6',
*      ' ' 'COL_POS'     '5',
      'E' 'KEY'         'X',


      'S' 'FIELDNAME' 'MATNR'   ,
      ' ' 'COLTEXT'   '자재코드',
      ' ' 'DDICTXT'     'L',
*      ' ' 'OUTPUTLEN'   '18',
      'E' 'KEY'         'X',


      'S' 'FIELDNAME' 'LFIMG'  ,
      ' ' 'COLTEXT'   '납품수량',
      ' ' 'DDICTXT'     'L',
*      ' ' 'OUTPUTLEN'   '13',
      'E' 'KEY'         'X',

      'S' 'FIELDNAME' 'LFIMG601' ,
      ' ' 'COLTEXT'   '출고수량(601)',
      ' ' 'DDICTXT'     'L',
*      ' ' 'OUTPUTLEN'   '13',
      'E' 'KEY'         'X',

      'S' 'FIELDNAME' 'LFIMG687'  ,
      ' ' 'COLTEXT'   '출고수량(687)',
      ' ' 'DDICTXT'     'L',
      'E' 'KEY'         'X',

      'S' 'FIELDNAME' 'ETC'  ,
      ' ' 'COLTEXT'   '기타출고',
      ' ' 'DDICTXT'     'L',
      'E' 'KEY'         'X',

      'S' 'FIELDNAME' 'FKIMG' ,
      ' ' 'COLTEXT'   '청구수량',
      ' ' 'DDICTXT'     'L',
      'E' 'KEY'         'X',

      'S' 'FIELDNAME' 'GAP1' ,
      ' ' 'COLTEXT'   '출고-빌링',
      ' ' 'DDICTXT'     'L',
      'E' 'KEY'         'X',

      'S' 'FIELDNAME' 'GAP2' ,
      ' ' 'COLTEXT'   '빌링-출고',
      ' ' 'DDICTXT'     'L',
      'E' 'KEY'         'X',

      'S' 'FIELDNAME' 'KDKG4',
      ' ' 'COLTEXT'   '수출구분',
      ' ' 'DDICTXT'     'L',
      'E' 'KEY'         'X'.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form INVOICE_BIUSDUCT_AMT_CALS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_DELDATA_VBELN
*&      --> GT_DELDATA_POSNR
*&      <-- LT_DISPLAY2_NETWR_A
*&      <-- LV_INPUT
*&---------------------------------------------------------------------*
FORM invoice_biusduct_amt_cals  USING    p_vbeln
                                         p_posnr
                                CHANGING p_netwr_a
                                         p_input.

  DATA : lv_netwr_i LIKE vbak-netwr.
  DATA : lv_xkwert LIKE komv-kwert.
  DATA : lv_netwr_e   LIKE vbak-netwr,
         lv_netwr_gap LIKE vbak-netwr,
         lv_mwsbp     LIKE vbap-mwsbp.

  lv_netwr_i = lt_display2-netwr_a.

  CALL FUNCTION 'ZGTSD_BD_SD_CAL_BILLING_AMT1'
    EXPORTING
      i_vbeln     = p_vbeln
      i_posnr     = p_posnr
      i_netwr     = lv_netwr_i
      i_waers     = lt_display2-waerk
    IMPORTING
      e_netwr     = lv_netwr_e
      e_netwr_gap = lv_netwr_gap
      e_mwsbp     = lv_mwsbp.

  IF lv_netwr_e IS NOT INITIAL.
    p_netwr_a = lv_netwr_e.
    p_input = lv_mwsbp.
  ENDIF.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form CALL_CI_ERROR_CHECK
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LV_SUBRC
*&---------------------------------------------------------------------*
FORM call_ci_error_check  USING pv_subrc.


  LOOP AT gt_display WHERE chk EQ 'X'.

    READ TABLE  lt_display2 WITH KEY branch = gt_display-branch
                           vkbur  = gt_display-vkbur
                          vkgrp  = gt_display-vkgrp
                          vtweg  = gt_display-vtweg
                          kdkg4  = gt_display-kdkg4
                          kunnr  = gt_display-kunnr
                          zflag2 = 'O'.
    IF sy-subrc = 0 .
      MESSAGE e002 WITH '미처리 공사오더가 존재합니다 -' lt_display2-vbeln DISPLAY LIKE 'E'.
      pv_subrc = 'X'. EXIT.
    ENDIF.

    READ TABLE gt_billdata  WITH KEY branch = gt_display-branch
                          vkbur  = gt_display-vkbur
                          vkgrp  = gt_display-vkgrp
                          vtweg  = gt_display-vtweg
                          kdkg4  = gt_display-kdkg4
                          kunnr  = gt_display-kunnr
                          pstyv = 'TAD'..
    IF sy-subrc = 0 .
      MESSAGE e002 WITH '미처리 공사오더가 존재합니다 -' gt_billdata-vbeln DISPLAY LIKE 'E'.
      pv_subrc = 'X'. EXIT.
    ENDIF.

  ENDLOOP.


ENDFORM.
