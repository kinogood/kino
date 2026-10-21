*&---------------------------------------------------------------------*
*& Include          ZGTMMR4915F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form SET_INIT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_init.

  PERFORM get_ifno.

  CLEAR : s_ifdat[], s_erdat[].
  s_ifdat[] = s_erdat[] = VALUE #( ( sign   = gc_i
                                     option = gc_bt
                                     low    = sy-datlo - 1
                                     high   = sy-datlo ) ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_IFNO
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_ifno.

  CLEAR : gt_ifno[].

  SELECT DISTINCT fld_01 AS key,
                  fld_02 AS text
    FROM zgtppt1010
    INTO CORRESPONDING FIELDS OF TABLE @gt_ifno
   WHERE module_kind = @gc_pp
     AND codegrp     = @gc_0010.

  SORT gt_ifno BY key.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form MODIFY_SCREEN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM modify_screen.

  CLEAR : gr_gr1[], gr_snm[].

  CASE 'X'.
    WHEN p_ilog.
      gr_gr1[] = VALUE #( ( sign = gc_i option = gc_eq low = gc_snd ) ).

      gr_snm[] = VALUE #( ( sign = gc_i option = gc_eq low = gc_s_ifdat-low ) ).

    WHEN p_send.
      gr_gr1[] = VALUE #( ( sign = gc_i option = gc_eq low = gc_dis ) ).

      gr_snm[] = VALUE #( ( sign = gc_i option = gc_eq low = gc_p_ifsyt )
                          ( sign = gc_i option = gc_eq low = gc_s_erdat-low ) ).

  ENDCASE.

  LOOP AT SCREEN.
    IF screen-group1 IN gr_gr1.
      screen-active = 0.
      MODIFY SCREEN.
    ENDIF.

    IF screen-name IN gr_snm.
      screen-required = 2.
      MODIFY SCREEN.
    ENDIF.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form F4_IFSYT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&---------------------------------------------------------------------*
FORM f4_ifsyt USING pv_id.

  DATA : lt_ifno TYPE vrm_values.


  lt_ifno[] = CORRESPONDING #( gt_ifno[] ).

  CALL FUNCTION 'VRM_SET_VALUES'
    EXPORTING
      id     = pv_id
      values = lt_ifno.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_COND
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM check_cond.

  CLEAR : gv_err.

  IF ( p_ilog = gc_x AND   s_ifdat[] IS INITIAL )
  OR ( p_send = gc_x AND ( s_erdat[] IS INITIAL
                        OR p_ifsyt   IS INITIAL ) ).
    MESSAGE s018 DISPLAY LIKE 'E'. "필수 입력 정보가 누락되었습니다.
    gv_err = gc_x. EXIT.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_data.

  CLEAR : gv_cnt.
  CHECK gv_err IS INITIAL.

  PERFORM get_mst_info USING 'MM00006'.

  PERFORM make_itab.
  CLEAR : <gt_list>.

  CASE 'X'.
    WHEN p_ilog.
      PERFORM get_ilog_data.
    WHEN p_send.
      PERFORM get_send_data.
  ENDCASE.

  gv_cnt = lines( <gt_list> ).
  IF gv_cnt IS NOT INITIAL.
    MESSAGE s003 WITH gv_cnt. "& 건의 데이터가 조회되었습니다.
  ELSE.
    MESSAGE s002 DISPLAY LIKE 'E'. "조회된 값이 없습니다.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_MST_INFO
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&---------------------------------------------------------------------*
FORM get_mst_info USING pv_id.

  CLEAR : gs_mst.

  SELECT SINGLE fld_03,
                fld_04,
                fld_05
    FROM zgtmm_cv_get_iflist
    INTO @gs_mst
   WHERE module_kind = @gc_mm
     AND codegrp     = @gc_0010
     AND fld_01      = @pv_id.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form MAKE_ITAB
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM make_itab.

  DATA : lr_data  TYPE REF TO data.


  CLEAR    : gv_tname.
  UNASSIGN : <gt_list>, <gs_list>.

  CASE 'X'.
    WHEN p_ilog.
      gv_tname = gs_mst-view. "ZGTMM_CV_RES_IF_LOG_L
    WHEN p_send.
      gv_tname = gc_zgtmmsif0009.
  ENDCASE.

  DATA(ls_strc) = CAST cl_abap_structdescr(
                       cl_abap_typedescr=>describe_by_name( gv_tname ) ).

  CREATE DATA lr_data TYPE HANDLE ls_strc.
  ASSIGN lr_data->* TO  <gs_list>.
  FREE : lr_data.

  CREATE DATA lr_data LIKE STANDARD TABLE OF <gs_list>.
  ASSIGN lr_data->* TO <gt_list>.
  FREE : lr_data.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_ILOG_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_ilog_data.

  DATA : lv_cond TYPE string.


  lv_cond = |     IFDAT IN @S_IFDAT |
         && | AND WERKS IN @S_WERKS |
         && | AND RSNUM IN @S_RSNUM |
         && | AND BWART IN @S_BWART |.

  IF p_ifsyt IS NOT INITIAL.
    lv_cond = lv_cond && | AND SYSTEM_ID = @P_IFSYT |.
  ENDIF.

  IF p_fnl IS NOT INITIAL.
    lv_cond = lv_cond && | AND LASTDATA = @GC_X |.
  ENDIF.

  IF p_frc IS INITIAL. "전송된 정보는 재전송 불가하게 조회 정보에서 삭제
    lv_cond = lv_cond && | AND ZSTAT <> @GC_S |.
  ENDIF.

  SELECT *
    FROM (gv_tname)
    INTO CORRESPONDING FIELDS OF TABLE @<gt_list>
   WHERE (lv_cond).

  CHECK <gt_list> IS NOT INITIAL.
  SORT <gt_list> BY ('ZIFKEY') DESCENDING
                    ('RSNUM')  ASCENDING
                    ('RSPOS')  ASCENDING.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_SEND_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_send_data.

  CLEAR : gt_list[].

  PERFORM convert_date.

  SELECT a~rsnum,
         a~rspos,
         b~rsdat,
         a~bdart,
         b~wempf,
         b~bwart,
         a~xwaok,
         a~kzear,
         a~xloek,
         a~matnr,
         a~werks,
         a~lgort,
         a~umwrk,
         a~umlgo,
         a~erfme,
         a~bdmng,
         a~erfmg AS enmng "A~ENMNG
    FROM resb AS a INNER JOIN rkpf AS b
      ON a~rsnum = b~rsnum
    INTO CORRESPONDING FIELDS OF TABLE @gt_list
   WHERE a~rsnum              IN @s_rsnum
     AND a~werks              IN @s_werks
     AND a~bwart              IN @s_bwart
     AND b~lastchangedatetime IN @gr_date.
*    AND B~RSDAT IN @S_ERDAT
*    AND A~XLOEK  = @SPACE
*    AND A~KZEAR  = @SPACE.

  CHECK gt_list[] IS NOT INITIAL.
  PERFORM except_send_data.

  CHECK gt_list[] IS NOT INITIAL.

  SORT gt_list BY rsnum rspos.
  <gt_list> = CORRESPONDING #( gt_list[] ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CONVERT_DATE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM convert_date.

  CLEAR : gr_date, gr_date[].

  CHECK s_erdat[] IS NOT INITIAL.
  READ TABLE s_erdat INDEX 1.

  PERFORM convert_date_to_tstmp USING s_erdat-low  '000000'
                             CHANGING gr_date-low.
  PERFORM convert_date_to_tstmp USING s_erdat-high '235959'
                             CHANGING gr_date-high.

*  CALL FUNCTION 'FRE_CONVERT_DATE_TO_TIMESTMP'
*    EXPORTING
*      IP_START_DATE    = S_ERDAT-LOW
*      IP_END_DATE      = S_ERDAT-HIGH
**     IP_WERKS         =
**     IP_TIME_ZONE     =
**     IP_ZERO_TIME     =
*    IMPORTING
*      EP_START_DATE    = GR_DATE-LOW
*      EP_END_DATE      = GR_DATE-HIGH
*    EXCEPTIONS
*      CONVERSION_ERROR = 1
*      OTHERS           = 2.

  gr_date-sign   = gc_i.
  gr_date-option = SWITCH #( gr_date-high WHEN ' ' THEN gc_eq
                                                   ELSE gc_bt ).
  APPEND gr_date.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CONVERT_DATE_TO_TSTMP
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> S_ERDAT_LOW
*&      --> P_
*&      <-- GR_DATE_LOW
*&---------------------------------------------------------------------*
FORM convert_date_to_tstmp USING pv_date
                                 pv_time
                        CHANGING pv_tstmp.

  CHECK pv_date IS NOT INITIAL.

  CONVERT DATE pv_date TIME pv_time
     INTO TIME STAMP pv_tstmp TIME ZONE sy-zonlo. "SY-TZONE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form EXCEPT_SEND_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM except_send_data.

  CHECK p_frc     IS INITIAL. "전송된 정보는 재전송 불가하게 조회 정보에서 삭제
  CHECK gt_list[] IS NOT INITIAL.

  SELECT rsnum,
         rspos,
         rsdat,
         bdart,
         wempf,
         bwart,
         xwaok,
         kzear,
         xloek,
         matnr,
         werks,
         lgort,
         umwrk,
         umlgo,
         erfme,
         bdmng,
         enmng
    FROM zgtmm_cv_res_if_log_l
     FOR ALL ENTRIES IN @gt_list
   WHERE rsnum = @gt_list-rsnum
     AND rspos = @gt_list-rspos
     AND zstat = @gc_s
    INTO TABLE @DATA(lt_old).

  CHECK sy-subrc = 0.

  SORT BY lt_old.
  SORT BY gt_list.

  LOOP AT gt_list INTO DATA(ls_new).
    READ TABLE lt_old INTO DATA(ls_resb_old)
                       WITH KEY rsnum = ls_new-rsnum
                                rspos = ls_new-rspos
                                rsdat = ls_new-rsdat
                                wempf = ls_new-wempf
                                bwart = ls_new-bwart
                                xwaok = ls_new-xwaok
                                kzear = ls_new-kzear
                                xloek = ls_new-xloek
                                matnr = ls_new-matnr
                                werks = ls_new-werks
                                lgort = ls_new-lgort
                                umwrk = ls_new-umwrk
                                umlgo = ls_new-umlgo
                                erfme = ls_new-erfme
                                bdmng = ls_new-bdmng
                                enmng = ls_new-enmng.

    IF sy-subrc = 0.
      DELETE gt_list WHERE rsnum = ls_new-rsnum
                       AND rspos = ls_new-rspos.
      CONTINUE.
    ENDIF.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SEND_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&---------------------------------------------------------------------*
FORM send_data USING pv_chk.

  DATA : lv_dest LIKE zifdest-dest,
         lv_rst  TYPE zo_result,
         lv_msg  TYPE zo_message,
         lv_ret  TYPE zife_ifret.

  DATA : lt_f009 LIKE zgtmmsif0009 OCCURS 0 WITH HEADER LINE.


  CLEAR : gt_f009[], gt_rlog[].
  CLEAR : gv_cnt,    gv_msg.

  IF pv_chk = gc_x.
    PERFORM send_sel_data.

    CHECK gv_err IS INITIAL.
    PERFORM popup_to_confirm USING '확인'(p01)
                                   'Data를 전송 하시겠습니까?'(p02).

    CHECK gv_ans = gc_1.
  ELSE.
    PERFORM send_bat_data.
  ENDIF.

  IF p_ifsyt IS INITIAL.
    MESSAGE s015 WITH 'I/F 시스템'(m01) DISPLAY LIKE 'E'. "&를(을) 입력하세요.
    EXIT.
  ENDIF.

  PERFORM modify_f009_data.

  lt_f009[] = gt_f009[].

*2025.08.13 통합솔루션 IS전환
  "Destination
  CALL FUNCTION 'Z_IF_DESTINATION'
    EXPORTING
      gubun                 = 'IS'
*     GUBUN                 = 'MM'
    IMPORTING
      dest_name             = lv_dest
    EXCEPTIONS
      destination_not_found = 1
      OTHERS                = 2.

  CALL FUNCTION 'ZGTMM_IF_O_RESB_SEND'
    DESTINATION lv_dest
    EXPORTING
      i_system_id = p_ifsyt
    IMPORTING
      zo_result   = lv_rst
      zo_message  = lv_msg
    TABLES
      ot_tab      = lt_f009[] "GT_F009[]
    EXCEPTIONS
      OTHERS      = 1.

  IF sy-subrc <> 0.
    lv_rst = gc_02.
  ENDIF.

  CASE lv_rst.
    WHEN '00'.
      lv_ret = gc_s.
      gv_cnt = lines( gt_f009[] ).
      gv_msg = gv_cnt && '건 전송 성공'(m02).
    WHEN OTHERS.
      lv_ret = gc_e.
      gv_msg = '전송 실패'(m03).
  ENDCASE.

  PERFORM save_log USING lv_ret
                         lv_msg.

  MESSAGE s000 DISPLAY LIKE lv_ret WITH gv_msg.

  CHECK p_ilog = gc_x.
  PERFORM get_data.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_SELECTED_ROWS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GR_GRID
*&      --> P_
*&      --> P_
*&---------------------------------------------------------------------*
FORM get_selected_rows USING pr_grid TYPE REF TO cl_gui_alv_grid
                             pv_mode
                             pv_chk.

  CLEAR : gt_row, gs_row, gv_err.
  CALL METHOD pr_grid->get_selected_rows
    IMPORTING
      et_index_rows = gt_row.

  DESCRIBE TABLE gt_row.

  CASE sy-tfill.
    WHEN 0.
      IF pv_chk = gc_x.
        gv_err = gc_x.
        MESSAGE s050 DISPLAY LIKE 'E'. "선택된 데이터가 없습니다.
      ENDIF.
    WHEN 1.
      IF pv_mode = gc_s.
        READ TABLE gt_row INTO gs_row INDEX 1.
      ENDIF.
    WHEN OTHERS.
      IF pv_mode = gc_s.
        gv_err = gc_x.
        MESSAGE s005 DISPLAY LIKE 'E'. "하나의 라인만 선택 가능합니다.
      ENDIF.
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form POPUP_TO_CONFIRM
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> P_
*&---------------------------------------------------------------------*
FORM popup_to_confirm USING pv_title
                            pv_qtext.

  CLEAR : gv_ans. "1/2/A

  CALL FUNCTION 'POPUP_TO_CONFIRM' "POPUP_TO_CONFIRM_STEP
    EXPORTING
      titlebar      = pv_title
*     DIAGNOSE_OBJECT             = ' '
      text_question = pv_qtext
*     TEXT_BUTTON_1 = 'Ja'(001)
*     ICON_BUTTON_1 = ' '
*     TEXT_BUTTON_2 = 'Nein'(002)
*     ICON_BUTTON_2 = ' '
*     DEFAULT_BUTTON              = '1'
*     DISPLAY_CANCEL_BUTTON       = 'X'
*     USERDEFINED_F1_HELP         = ' '
*     START_COLUMN  = 25
*     START_ROW     = 6
*     POPUP_TYPE    =
*     IV_QUICKINFO_BUTTON_1       = ' '
*     IV_QUICKINFO_BUTTON_2       = ' '
    IMPORTING
      answer        = gv_ans.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SEND_SEL_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM send_sel_data.

  DATA : lt_log LIKE zgtmmt9060 OCCURS 0 WITH HEADER LINE.

  DATA : BEGIN OF lt_sel OCCURS 0,
           zifkey LIKE zgtmmt9060-zifkey,
           rsnum  LIKE zgtmmt9060-rsnum,
         END   OF lt_sel.


  "라인 선택시 선택된 라인과 기준이 동일한 모든 데이터는 동시 선택(예약번호 단위 전송)
  " I/F Log 조회: ZIFKEY/RSNUM
  " Data 전송: RSNUM

  PERFORM get_selected_rows USING gr_grid 'M' 'X'.
  CHECK gv_err IS INITIAL.

  LOOP AT gt_row INTO gs_row.
    READ TABLE <gt_list> INTO <gs_list> INDEX gs_row-index.
    CHECK sy-subrc = 0.

    CASE 'X'.
      WHEN p_ilog.
        ASSIGN COMPONENT 'LASTDATA' OF STRUCTURE <gs_list> TO FIELD-SYMBOL(<lfs_last>).

        IF <lfs_last> IS INITIAL.
          MESSAGE s049 DISPLAY LIKE 'E'. "최종이 아닌 데이터는 전송할 수 없습니다.
          gv_err = gc_x. EXIT.
        ENDIF.

      WHEN OTHERS.

    ENDCASE.

    lt_sel = CORRESPONDING #( <gs_list> ).
    COLLECT lt_sel.
  ENDLOOP.

  CHECK lt_sel[] IS NOT INITIAL.

  lt_log[] = CORRESPONDING #( <gt_list> ).
  SORT lt_log BY zifkey DESCENDING
                 rsnum  ASCENDING.

  CLEAR : gt_row, gs_row.

  LOOP AT lt_sel.
    READ TABLE lt_log WITH KEY zifkey = lt_sel-zifkey
                               rsnum  = lt_sel-rsnum.
*                              BINARY SEARCH.

    CHECK sy-subrc = 0.

    LOOP AT lt_log FROM sy-tabix.
      IF NOT ( lt_log-zifkey = lt_sel-zifkey
           AND lt_log-rsnum  = lt_sel-rsnum ).
        EXIT.
      ENDIF.

      gs_row-index = sy-tabix.
      APPEND gs_row TO gt_row.

      gt_rlog = CORRESPONDING #( lt_log ).
      APPEND gt_rlog.
    ENDLOOP.
  ENDLOOP.

  gr_grid->set_selected_rows( it_index_rows = gt_row ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SEND_BAT_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM send_bat_data.

  gt_rlog[] = CORRESPONDING #( <gt_list> ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form MODIFY_F009_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM modify_f009_data.

  LOOP AT gt_rlog.
    gt_f009 = CORRESPONDING #( gt_rlog ).
    PERFORM convert_matn1_output USING gt_f009-matnr.

    SHIFT gt_f009-rsnum LEFT DELETING LEADING '0'. "추가(송종면E 24.12.10)
    SHIFT gt_f009-rspos LEFT DELETING LEADING '0'. "추가(송종면E 24.12.10)

    APPEND gt_f009.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CONVERT_MATN1_OUTPUT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_F006_MATNR
*&---------------------------------------------------------------------*
FORM convert_matn1_output USING pv_matnr.

  CHECK pv_matnr IS NOT INITIAL.

  CALL FUNCTION 'CONVERSION_EXIT_MATN1_OUTPUT'
    EXPORTING
      input  = pv_matnr
    IMPORTING
      output = pv_matnr.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SAVE_LOG
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LV_RET
*&      --> LV_MSG
*&---------------------------------------------------------------------*
FORM save_log USING pv_ret
                    pv_msg.

  CLEAR : gs_9000, gt_9060[].

  GET TIME STAMP FIELD gs_9000-zifkey.
  gs_9000-zifno       = gc_mm00006.
  gs_9000-system_id   = p_ifsyt.
  gs_9000-zstat       = pv_ret.
  gs_9000-message     = pv_msg.
  gs_9000-ifdat       = sy-datlo.
  gs_9000-iftim       = sy-timlo.
  gs_9000-ifnam       = sy-uname.
  gs_9000-erdat       = sy-datum.
  gs_9000-erdat_local = sy-datlo.
  gs_9000-ertim       = sy-uzeit.
  gs_9000-ertim_local = sy-timlo.
  gs_9000-ernam       = sy-uname.

  gt_9060[] = VALUE #( FOR ls_log IN gt_rlog
                       ( VALUE #( BASE CORRESPONDING #( ls_log )
                                  zifkey = gs_9000-zifkey ) ) ).

  CHECK gt_9060[] IS NOT INITIAL.

  MODIFY zgtmmt9060 FROM TABLE gt_9060.
  MODIFY zgtmmt9000 FROM gs_9000.

  CHECK sy-subrc = 0.
  COMMIT WORK.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_GUI
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_gui.

  gv_send = COND #( WHEN p_ilog = 'X' THEN '재전송'(b01)
                    WHEN p_send = 'X' THEN '전송'(b02) ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_OBJ
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GR_DOCK
*&      --> GR_GRID
*&---------------------------------------------------------------------*
FORM set_obj USING pr_dock TYPE REF TO cl_gui_docking_container
                   pr_grid TYPE REF TO cl_gui_alv_grid.

  pr_dock = NEW #( repid     = sy-repid
                   dynnr     = sy-dynnr
                   side      = cl_gui_docking_container=>dock_at_top
                   extension = 655 ).

  pr_grid = NEW #( i_parent      = pr_dock
                   i_appl_events = gc_x ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_EXCL
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_excl.

  CLEAR : gt_excl[].

  "다운로드 기능(MC_MB_EXPORT) 삭제(송종면E 25.02.10)

  gt_excl[] = VALUE #( ( cl_gui_alv_grid=>mc_fc_loc_undo  )
                       ( cl_gui_alv_grid=>mc_fc_loc_copy )
                       ( cl_gui_alv_grid=>mc_fc_loc_copy_row )
                       ( cl_gui_alv_grid=>mc_fc_loc_cut )
                       ( cl_gui_alv_grid=>mc_fc_loc_delete_row )
                       ( cl_gui_alv_grid=>mc_fc_loc_insert_row )
                       ( cl_gui_alv_grid=>mc_fc_loc_append_row )
                       ( cl_gui_alv_grid=>mc_fc_loc_paste )
                       ( cl_gui_alv_grid=>mc_fc_loc_paste_new_row )
                       ( cl_gui_alv_grid=>mc_mb_export )
                       ( cl_gui_alv_grid=>mc_fc_refresh ) ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_LAYO
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GS_LAYO
*&---------------------------------------------------------------------*
FORM set_layo USING ps_layo TYPE lvc_s_layo.

  CLEAR : ps_layo.

  ps_layo-sel_mode   = gc_d.
  ps_layo-cwidth_opt = gc_x.
  ps_layo-zebra      = gc_x.
  ps_layo-smalltitle = gc_x.
  ps_layo-grid_title = COND #( WHEN p_ilog = 'X' THEN 'Interface 처리상태'(t01)
                               WHEN p_send = 'X' THEN '예약정보'(t02) ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_FCAT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_FCAT
*&---------------------------------------------------------------------*
FORM set_fcat TABLES pt_fcat TYPE lvc_t_fcat.

  DATA : lt_fcat TYPE slis_t_fieldcat_alv.


  CLEAR : lt_fcat[].
  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
*     I_PROGRAM_NAME     = SY-REPID
*     I_INTERNAL_TABNAME = PV_TNAME
      i_structure_name   = CONV tabname( gv_tname )
*     I_INCLNAME         = SY-REPID
      i_bypassing_buffer = gc_x
*     I_BUFFER_ACTIVE    = ''
    CHANGING
      ct_fieldcat        = lt_fcat[].

  DELETE lt_fcat WHERE fieldname = '.NODE1'.

  CALL FUNCTION 'LVC_TRANSFER_FROM_SLIS'
    EXPORTING
      it_fieldcat_alv = lt_fcat[]
    IMPORTING
      et_fieldcat_lvc = pt_fcat[]
    TABLES
      it_data         = <gt_list>
    EXCEPTIONS
      it_data_missing = 1
      OTHERS          = 2.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_EVNT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GR_GRID
*&---------------------------------------------------------------------*
FORM set_evnt USING pr_grid TYPE REF TO cl_gui_alv_grid.

  gr_events = NEW lcl_event_handler( e_object_text = 'GR_GRID' ).

  SET HANDLER gr_events->handle_context_menu FOR pr_grid.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_DISP
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_FCAT
*&      --> GR_GRID
*&      --> GS_LAYO
*&---------------------------------------------------------------------*
FORM set_disp TABLES pt_fcat TYPE lvc_t_fcat
               USING pr_grid TYPE REF TO cl_gui_alv_grid
                     ps_layo TYPE lvc_s_layo.

  CLEAR : gs_vari.
  gs_vari-report   = sy-repid.
  gs_vari-handle   = sy-dynnr.
  gs_vari-username = sy-uname.

  CALL METHOD pr_grid->set_table_for_first_display
    EXPORTING
*     I_BUFFER_ACTIVE      =
*     I_BYPASSING_BUFFER   =
*     I_CONSISTENCY_CHECK  =
*     I_STRUCTURE_NAME     =
*     IS_VARIANT           = GS_VARI
      i_save               = gc_a
*     I_DEFAULT            = GC_X
      is_layout            = ps_layo
*     IS_PRINT             =
*     IT_SPECIAL_GROUPS    =
      it_toolbar_excluding = gt_excl
*     IT_HYPERLINK         =
*     IT_ALV_GRAPHICS      =
*     IT_EXCEPT_QINFO      =
*     IR_SALV_ADAPTER      =
    CHANGING
      it_outtab            = <gt_list>
      it_fieldcatalog      = pt_fcat[].
*     IT_SORT              = PT_SORT[].
*     IT_FILTER            =

ENDFORM.
*&---------------------------------------------------------------------*
*& Form REFRESH_GRID
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GR_GRID
*&      --> GS_LAYO
*&---------------------------------------------------------------------*
FORM refresh_grid USING pr_grid TYPE REF TO cl_gui_alv_grid
                        ps_layo TYPE lvc_s_layo.

  DATA : ls_stbl TYPE lvc_s_stbl.


  ls_stbl-row = gc_x.
  ls_stbl-col = gc_x.

  CALL METHOD pr_grid->set_frontend_layout
    EXPORTING
      is_layout = ps_layo.

  CALL METHOD pr_grid->refresh_table_display
    EXPORTING
      is_stable = ls_stbl
*     I_SOFT_REFRESH = GC_X
    EXCEPTIONS
      finished  = 1
      OTHERS    = 2.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form FREE_OBJ
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM free_obj.

  CASE sy-dynnr.
    WHEN '0100'.
      CALL METHOD gr_grid->free.
      CALL METHOD gr_dock->free.
      CLEAR : gr_grid, gr_dock.

    WHEN OTHERS.

  ENDCASE.

  CALL METHOD cl_gui_cfw=>flush.

ENDFORM.
