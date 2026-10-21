*&---------------------------------------------------------------------*
*& Include          ZGTSDR1190F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form INITIALIZATION
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM initialization .

*-영업조직
  s_vkorg[] = VALUE #( ( sign = 'I' option = 'EQ' low = gc_vkorg_6000 ) ).

*-마감월
  PERFORM set_spmon.

*-VKBUR/VKGRP 제외
  PERFORM set_vkbur_vkgrp_exclud.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SELECTION_SCREEN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM selection_screen .

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SELECTION_SCREEN_OUTPUT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM selection_screen_output .
  LOOP AT SCREEN.
    IF screen-group1 EQ 'ZM1'.
      screen-input = 0.
    ENDIF.
    MODIFY SCREEN.
  ENDLOOP.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form F4_SPMON
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&---------------------------------------------------------------------*
FORM f4_spmon  USING    p_fval.
  DATA:lv_subrc TYPE sy-subrc.

  CALL FUNCTION 'POPUP_TO_SELECT_MONTH'
    EXPORTING
      actual_month               = sy-datlo(6)
    IMPORTING
      selected_month             = p_fval
      return_code                = lv_subrc
    EXCEPTIONS
      factory_calendar_not_found = 1
      holiday_calendar_not_found = 2
      month_not_found            = 3
      OTHERS                     = 4.
  IF sy-subrc <> 0.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_SPMON
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_spmon .
  DATA:lv_date TYPE sy-datum.

  lv_date = sy-datlo(6) && '01'.
  lv_date = lv_date - 1.

  p_spmon = lv_date(6).
ENDFORM.
*&---------------------------------------------------------------------*
*& Form F4_VKBUR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&---------------------------------------------------------------------*
FORM f4_vkbur  USING   pv_fname.

  SELECT DISTINCT a~vkbur,b~bezei
    FROM tvkbz AS a INNER JOIN tvkbt AS b
                    ON a~vkbur = b~vkbur

   WHERE a~vkorg IN @s_vkorg
     AND a~vkbur IN @gr_vkbur_ecl
    INTO TABLE @DATA(lt_value).
  SORT lt_value BY vkbur.
  CHECK lt_value[] IS NOT INITIAL.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield        = 'VKBUR'
      dynpprog        = sy-cprog
      dynpnr          = sy-dynnr
      dynprofield     = pv_fname
      value_org       = 'S'
    TABLES
      value_tab       = lt_value
    EXCEPTIONS
      parameter_error = 1
      no_values_found = 2
      OTHERS          = 3.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_VKBUR_VKGRP_EXCLUD
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_vkbur_vkgrp_exclud .
*-영업팀
  gr_vkbur_ecl[] = VALUE #( ( sign = 'I' option = 'NP' low = '69*' ) ).

*-영업그룹
  gr_vkgrp_ecl[] = VALUE #( ( sign = 'I' option = 'NP' low = '69*' ) ).
ENDFORM.
*&---------------------------------------------------------------------*
*& Form F4_VKGRP
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&---------------------------------------------------------------------*
FORM f4_vkgrp  USING    pv_fname.

  SELECT DISTINCT a~vkbur,b~bezei,a~vkgrp,c~bezei AS vkgrp_txt
    FROM tvkbz AS h INNER JOIN tvbvk AS a
                    ON h~vkbur = a~vkbur
                    INNER JOIN tvkbt AS b
                    ON a~vkbur = b~vkbur AND
                       b~spras = @sy-langu
                    INNER JOIN tvgrt AS c
                    ON a~vkgrp = c~vkgrp AND
                       c~spras = @sy-langu
   WHERE h~vkorg IN @s_vkorg
     AND h~vkbur IN @s_vkbur
     AND h~vkbur IN @gr_vkbur_ecl
     AND a~vkgrp IN @gr_vkgrp_ecl
    INTO TABLE @DATA(lt_value).

  SORT lt_value BY vkbur.

  CHECK lt_value[] IS NOT INITIAL.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield        = 'VKGRP'
      dynpprog        = sy-cprog
      dynpnr          = sy-dynnr
      dynprofield     = pv_fname
      value_org       = 'S'
    TABLES
      value_tab       = lt_value
    EXCEPTIONS
      parameter_error = 1
      no_values_found = 2
      OTHERS          = 3.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form MAIN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM main .
*-01. INIT OBJECTS
  PERFORM init_objects.

*-02. CHECK INPUT
  PERFORM check_input_value.

*-03. SET VALUES
  PERFORM set_values.

*-04. GET DATA
  PERFORM get_data.

*-05. MAKE LIST
  PERFORM make_list.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form INIT_OBJECTS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM init_objects .
  CLEAR:
        gv_title,
        gv_datefr,gv_dateto.

  REFRESH:
           gt_list,gr_xfeld.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_INPUT_VALUE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM check_input_value .

*-01. 기간
  PERFORM check_period.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_VALUES
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_values .
*-TITLE
  gv_title = TEXT-009.

*-마감구분
  CASE gc_x.
    WHEN p_r01. "ALL
      CLEAR:gr_xfeld[].

    WHEN p_r02. "마감전
      APPEND VALUE #( sign = 'I' option = 'EQ' low = gc_x )
          TO gr_xfeld.

    WHEN p_r03. "마감완료
      APPEND VALUE #( sign = 'I' option = 'EQ' low = space )
          TO gr_xfeld.
  ENDCASE.

*-마감월
  gv_datefr(6) = p_spmon.
  gv_datefr+6(2) = '01'.

  gv_dateto = '99991231'.


  gv_edit = gc_x.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_data .

*-영업팀/영업그룹/여신세그먼트
  SELECT DISTINCT a~vkbur,b~vkgrp,c~kkber,d~credit_sgmnt
    FROM tvkbz AS a INNER JOIN tvbvk AS b
                    ON a~vkbur = b~vkbur
                    INNER JOIN zgtsdt1012 AS c
                    ON b~vkgrp = c~vkgrp AND
                       c~loevm = @space
                    INNER JOIN ukm_kkber2sgm AS d
                    ON c~kkber = d~kkber
   WHERE a~vkorg IN @s_vkorg
     AND a~vkbur IN @s_vkbur
     AND a~vkbur IN @gr_vkbur_ecl
     AND b~vkgrp IN @s_vkgrp
     AND b~vkgrp IN @gr_vkgrp_ecl
    INTO TABLE @DATA(lt_base).
  SORT lt_base BY vkbur vkgrp credit_sgmnt.

  CHECK lt_base[] IS NOT INITIAL.

*-BP3100
  SELECT a~vkbur,
         a~vkgrp,
         b~partner,
         b~criter,
         b~addtype,
         b~data_type,
         b~counter,
         b~xfeld,
         b~datefr,
         b~dateto,
         d~customer AS kunnr,
         e~bezei AS vkbur_tx,
         f~bezei AS vkgrp_tx,
         g~name1 AS kunnr_tx,
*[S] 안정화  GW20260903003
         i~xcritical
*[E] 안정화  GW20260903003
    FROM @lt_base AS a INNER JOIN bp3100 AS b
                       ON a~credit_sgmnt = b~criter
                       INNER JOIN but000 AS c
                       ON b~partner = c~partner
                       INNER JOIN cvi_cust_link AS d
                       ON c~partner_guid = d~partner_guid
                       INNER JOIN but020 AS h
                       ON c~partner = h~partner
                       LEFT OUTER JOIN tvkbt AS e
                       ON a~vkbur = e~vkbur AND
                          e~spras = @sy-langu
                       LEFT OUTER JOIN tvgrt AS f
                       ON a~vkgrp = f~vkgrp AND
                          f~spras = @sy-langu
                       LEFT OUTER JOIN adrc AS g
                       ON h~addrnumber = g~addrnumber AND
                          g~nation     = @space
*[S] 안정화  GW20260903003
                     INNER JOIN ukmbp_cms_sgm AS i
                    ON  b~partner = i~partner   AND
                           b~criter = i~credit_sgmnt
*[E] 안정화  GW20260903003
   WHERE b~addtype   EQ @gc_addtype_50
     AND b~data_type EQ @gc_datatype_01
     AND b~datefr    EQ @gv_datefr
     AND b~dateto    EQ @gv_dateto
     AND b~xfeld     IN @gr_xfeld
     AND g~date_from LE @sy-datum
     AND g~date_to   GE @sy-datum
    INTO CORRESPONDING FIELDS OF TABLE @gt_list.

  SORT gt_list BY partner vkbur vkgrp.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_PERIOD
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM check_period .
  DATA: lv_date TYPE sy-datum.

  lv_date(6) = p_spmon.
  lv_date+6(2) = '01'.

  CALL FUNCTION 'DATE_CHECK_PLAUSIBILITY'
    EXPORTING
      date                      = lv_date
    EXCEPTIONS
      plausibility_check_failed = 1
      OTHERS                    = 2.
  IF sy-subrc <> 0.
    MESSAGE s000 WITH TEXT-m01 DISPLAY LIKE gc_e.
    LEAVE LIST-PROCESSING.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form MAKE_LIST
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM make_list .

  CHECK gt_list[] IS NOT INITIAL.

  LOOP AT gt_list ASSIGNING FIELD-SYMBOL(<fs_list>).
    "SET LED
    PERFORM set_led CHANGING <fs_list>.
  ENDLOOP.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form DISPLAY
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM display .
  IF gt_list[] IS NOT INITIAL.
    CALL SCREEN 0100.
  ELSE.
    MESSAGE s018.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_LED
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- <FS_LIST>
*&---------------------------------------------------------------------*
FORM set_led  CHANGING ps_list LIKE gt_list.
  CASE ps_list-xfeld.
    WHEN space.
      ps_list-stat = icon_led_green.
    WHEN OTHERS.
      ps_list-stat = icon_led_red.
  ENDCASE.

  CASE ps_list-rslt.
    WHEN gc_e.
      ps_list-stat2 = icon_led_red.
    WHEN OTHERS.
      CLEAR ps_list-stat2.
  ENDCASE.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SELECT_ALL
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM select_all .
  CLEAR gs_list.
  MODIFY gt_list FROM gs_list TRANSPORTING sel WHERE sel EQ gc_x.

  gs_list-sel = gc_x.
  MODIFY gt_list FROM gs_list TRANSPORTING sel WHERE sel   EQ space.

  PERFORM refresh_alv USING go_grid.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form DESELECT_ALL
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM deselect_all .
  CLEAR gs_list.
  MODIFY gt_list FROM gs_list TRANSPORTING sel WHERE sel EQ gc_x.

  PERFORM refresh_alv USING go_grid.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form COMPLETE_PROCESS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM complete_process USING p_step.
  DATA:lv_chk(1).

  PERFORM check_changed_data USING go_grid.

*-선택라인
  LOOP AT gt_list INTO DATA(ls_list) WHERE sel   EQ gc_x.

    lv_chk = gc_x.
    EXIT.
  ENDLOOP.
  IF lv_chk IS INITIAL.
    MESSAGE i004 DISPLAY LIKE gc_e.
    EXIT.
  ENDIF.

*-마감처리
  PERFORM complete_process_bp3100 USING p_step.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form COMPLETE_PROCESS_BP3100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM complete_process_bp3100 USING p_step.
  DATA: ls_ukmbp LIKE LINE OF gt_ukmbp.

  CLEAR gv_error.

  "동일 BP 별로 처리 한다.
  LOOP AT gt_list INTO DATA(ls_data) WHERE sel EQ gc_x
                                      GROUP BY ( partner = ls_data-partner )
                                      ASCENDING ASSIGNING FIELD-SYMBOL(<fs_main>).

    CLEAR gt_ukmbp[].
    LOOP AT GROUP <fs_main> ASSIGNING FIELD-SYMBOL(<fs_line>).
      CLEAR ls_ukmbp.
      MOVE-CORRESPONDING <fs_line> TO ls_ukmbp.
      APPEND ls_ukmbp TO gt_ukmbp.
    ENDLOOP.

    CHECK gt_ukmbp[] IS NOT INITIAL.

    "MAINTAIN ADDITIONAL INFO
    PERFORM maintain_bp_credit_add_data USING p_step.

    WAIT UP TO '0.5' SECONDS.

    "처리결과
    CLEAR ls_ukmbp.
    ls_ukmbp = VALUE #( gt_ukmbp[ 1 ] OPTIONAL ).
    LOOP AT GROUP <fs_main> ASSIGNING <fs_line>.
      CLEAR:<fs_line>-rslt,<fs_line>-message,<fs_line>-stat2.
      <fs_line>-rslt    = ls_ukmbp-rslt.
      <fs_line>-message = ls_ukmbp-message.

      PERFORM check_xfeld_complete CHANGING <fs_line>.

      PERFORM set_led CHANGING <fs_line>.
      IF ls_ukmbp-rslt EQ gc_e.
        gv_error = gc_x.
      ENDIF.
    ENDLOOP.

  ENDLOOP.

  IF gv_error IS NOT INITIAL.
    CASE p_step.
      WHEN gc_h.
        MESSAGE i000 WITH TEXT-m02 DISPLAY LIKE gc_e.
      WHEN gc_c.
        MESSAGE i000 WITH TEXT-m04 DISPLAY LIKE gc_e.
    ENDCASE.
  ELSE.
    CASE p_step.
      WHEN gc_h.
        MESSAGE s000 WITH TEXT-s01.
      WHEN gc_c.
        MESSAGE s000 WITH TEXT-s02.
    ENDCASE.

  ENDIF.
  PERFORM refresh_alv USING go_grid.



*  LOOP AT GT_LIST ASSIGNING FIELD-SYMBOL(<FS_LIST>) WHERE SEL EQ GC_X.
*    CLEAR:<FS_LIST>-RSLT,<FS_LIST>-MESSAGE,<FS_LIST>-STAT2.
*    PERFORM CHECK_XFELD_COMPLETE CHANGING <FS_LIST>.
*    CASE P_STEP.
*      WHEN GC_H. "마감
*        CHECK <FS_LIST>-XFELD IS NOT INITIAL.
*      WHEN GC_C. "마감취소
*        CHECK <FS_LIST>-XFELD IS INITIAL.
*    ENDCASE.
*
*    PERFORM CHANGE_BP_ADD_FIELDS    USING P_STEP
*                                 CHANGING <FS_LIST>.
**    PERFORM CHECK_XFELD_COMPLETE CHANGING <FS_LIST>.
*    PERFORM SET_LED CHANGING <FS_LIST>.
*  ENDLOOP.



ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_XFELD_COMPLETE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- <FS_LIST>
*&---------------------------------------------------------------------*
FORM check_xfeld_complete  CHANGING ps_list LIKE gt_list.

  SELECT SINGLE xfeld
    INTO ps_list-xfeld
    FROM bp3100
   WHERE partner   EQ ps_list-partner
     AND criter    EQ ps_list-criter
     AND addtype   EQ ps_list-addtype
     AND data_type EQ ps_list-data_type
     AND counter   EQ ps_list-counter.

*[S] 안정화  GW20260903003
    SELECT SINGLE xcritical
      INTO ps_list-xcritical
    FROM ukmbp_cms_sgm
  WHERE partner   EQ ps_list-partner
     AND credit_sgmnt EQ ps_list-criter.
*[E] 안정화  GW20260903003

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHANGE_BP_ADD_FIELDS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- <FS_LIST>
*&---------------------------------------------------------------------*
FORM change_bp_add_fields    USING p_step
                          CHANGING ps_list LIKE gt_list.
  DATA: io_facade       TYPE REF TO cl_ukm_facade,
        io_partner      TYPE REF TO cl_ukm_business_partner,
        io_bupa_factory TYPE REF TO cl_ukm_bupa_factory,
        io_account      TYPE REF TO cl_ukm_account.

  DATA: ls_bp_credit_sgm TYPE ukm_s_bp_cms_sgm,
        ls_ukm_s_bp_cms  TYPE ukm_s_bp_cms,
        lt_bp1012        TYPE ukm_t_bp1012,
        lv_grade         TYPE bp_grade,
        ls_new_score     TYPE bapi_str_bupa_fs_rating,
        ls_old_score     TYPE bapi_str_bupa_fs_rating,
        lt_add_info      TYPE ukm_ts_add_info,
        ls_add_info      TYPE ukm_s_add_info,
        ls_add_info_old  TYPE ukm_s_add_info,
        ls_add_info_new  TYPE ukm_s_add_info.

  DATA: lv_bupa_error TYPE mds_ctrls_error.

  DATA: lv_partner      TYPE bu_partner,
        lv_credit_sgmnt TYPE ukm_credit_sgmnt,
        lv_credit_group TYPE ukm_cred_group.

  DATA: lv_amt     TYPE ukm_amount,
        lv_date    TYPE sy-datum,
        lv_counter TYPE ukm_index.

  DATA: lv_datefr TYPE bp3100-datefr,
        lv_dateto TYPE bp3100-dateto.

  DATA: lt_return   TYPE ukm_t_monitor_return,
        ls_bapiret2 TYPE bapiret2.

  lv_partner      = ps_list-partner.
  lv_credit_sgmnt = ps_list-criter.

*-00. PARTNER LOCK 체크
  DATA(lo_bupa) = NEW cl_im_mds_bupa_lock( ).

  CALL METHOD lo_bupa->if_ex_bupa_lock~lock
    EXPORTING
      iv_partner = lv_partner
    CHANGING
      cs_error   = lv_bupa_error.

  IF lv_bupa_error-is_error IS NOT INITIAL.
    gv_error = gc_x.
    ps_list-rslt = gc_e.
    DATA(ls_msg) = VALUE #( lv_bupa_error-messages[ type = gc_e
                                                    id = 'MC'
                                                    number = '601' ] OPTIONAL ).
    IF ls_msg IS NOT INITIAL.
      ps_list-message = ls_msg-message.
    ELSE.
      LOOP AT lv_bupa_error-messages INTO ls_msg WHERE type EQ gc_e.
        IF ps_list-message IS INITIAL.
          ps_list-message = ls_msg-message.
        ELSE.
          ps_list-message = |{ ps_list-message }/{ ls_msg-message }|.
        ENDIF.
      ENDLOOP.
    ENDIF.
    EXIT.
  ENDIF.

  io_facade       = cl_ukm_facade=>create( i_activity = cl_ukm_cnst_eventing=>bp_maintenance ).
  io_bupa_factory = io_facade->get_bupa_factory( ).
  io_partner      = io_bupa_factory->get_business_partner( lv_partner ).

  CALL METHOD io_bupa_factory->get_credit_account
    EXPORTING
      i_partner         = lv_partner
      i_credit_sgmnt    = lv_credit_sgmnt
    RECEIVING
      ro_credit_account = io_account.


*-ADD INFOS
  CALL METHOD io_account->get_add_infos
    EXPORTING
      i_infocategory          = gc_addtype_50
      i_select_specified_only = 'X'
    RECEIVING
      rt_add_infos            = lt_add_info.

  ls_add_info_old = VALUE #( lt_add_info[ infocategory = ps_list-addtype
                                          infotype     = ps_list-data_type
                                          counter      = ps_list-counter
                                          credit_sgmnt = ps_list-criter   ] OPTIONAL ).

  CASE p_step.
    WHEN gc_h. "마감
      IF ls_add_info_old-check_relevant EQ space.
        EXIT.
      ENDIF.
    WHEN gc_c. "마감취소
      IF ls_add_info_old-check_relevant NE space.
        EXIT.
      ENDIF.
  ENDCASE.


  MOVE-CORRESPONDING ls_add_info_old TO ls_add_info_new.
  CASE p_step.
    WHEN gc_h.
      CLEAR ls_add_info_new-check_relevant.
    WHEN gc_c.
      ls_add_info_new-check_relevant = gc_x.
  ENDCASE.


  CALL METHOD io_account->set_add_info
    EXPORTING
      is_add_info = ls_add_info_new.

  CALL METHOD io_bupa_factory->save_all
    EXPORTING
      i_upd_task       = abap_false
*     I_FREE_ALL       = NO
*     I_WITH_EXTERNAL_SCORINGS = NO
      i_with_add_infos = abap_true
*     I_WITH_VECTORS   = NO
*     I_WITH_ENQUEUE   = NO
*     I_FROM_HCP       = NO
*     I_TESTRUN        = NO
    RECEIVING
      et_return        = lt_return
    EXCEPTIONS
      failed           = 1
      OTHERS           = 2.
  IF line_exists( lt_return[ msgty = 'E' ] ).
    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

    gv_error = gc_x.
    ps_list-rslt = gc_e.
    ps_list-message = TEXT-m03.
    LOOP AT lt_return INTO DATA(ls_return) WHERE msgty EQ gc_e.
      ps_list-message = |{ ps_list-message }/{ ls_return-message }|.
    ENDLOOP.

  ELSE.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        wait = abap_true.

    ps_list-rslt = gc_s.
*    PS_LIST-MESSAGE = TEXT-S01.

    CASE p_step.
      WHEN gc_h.
        CLEAR:ps_list-xfeld.
      WHEN gc_c.
        ps_list-xfeld = gc_x.
    ENDCASE.

  ENDIF.



  io_bupa_factory->refresh_preread_buffer( ).

  CALL METHOD lo_bupa->if_ex_bupa_lock~unlock
    EXPORTING
      iv_partner = lv_partner
    CHANGING
      cs_error   = lv_bupa_error.

  io_bupa_factory->free_all( ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form ALV_DOUBLE_CLICK_0100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PS_E_ROW
*&      --> PS_E_COLUMN
*&---------------------------------------------------------------------*
FORM alv_double_click_0100  USING    ps_e_row  TYPE lvc_s_row
                                     ps_e_column TYPE lvc_s_col.

  READ TABLE gt_list INTO DATA(ls_list) INDEX ps_e_row-index.
  CHECK sy-subrc EQ 0.

  CASE ps_e_column-fieldname.
    WHEN 'KUNNR'.
      IF ls_list-kunnr   IS NOT INITIAL AND
         ls_list-partner IS NOT INITIAL.
        SET PARAMETER ID 'UKM_SEGMENT' FIELD ls_list-criter.
        zgtsd_cl_common2=>bp_display( iv_partner = ls_list-partner
                                      iv_role    = gc_role_ukm000   ).
      ENDIF.

    WHEN 'PARTNER'.
      IF ls_list-partner IS NOT INITIAL.
        SET PARAMETER ID 'UKM_SEGMENT' FIELD ls_list-criter.
        zgtsd_cl_common2=>bp_display( iv_partner = ls_list-partner
                                      iv_role    = gc_role_ukm000   ).
      ENDIF.
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form MAINTAIN_BP_CREDIT_ADD_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_STEP
*&---------------------------------------------------------------------*
FORM maintain_bp_credit_add_data  USING    p_step.
  DATA: io_facade       TYPE REF TO cl_ukm_facade,
        io_partner      TYPE REF TO cl_ukm_business_partner,
        io_bupa_factory TYPE REF TO cl_ukm_bupa_factory,
        io_account      TYPE REF TO cl_ukm_account.

  DATA: ls_bp_credit_sgm TYPE ukm_s_bp_cms_sgm,
        ls_ukm_s_bp_cms  TYPE ukm_s_bp_cms,
        lt_bp1012        TYPE ukm_t_bp1012,
        lv_grade         TYPE bp_grade,
        ls_new_score     TYPE bapi_str_bupa_fs_rating,
        ls_old_score     TYPE bapi_str_bupa_fs_rating,
        lt_add_info      TYPE ukm_ts_add_info,
        ls_add_info      TYPE ukm_s_add_info,
        ls_add_info_old  TYPE ukm_s_add_info,
        ls_add_info_new  TYPE ukm_s_add_info.

  DATA: ls_bupa_error TYPE mds_ctrls_error.

  DATA: lv_partner      TYPE bu_partner,
        lv_credit_sgmnt TYPE ukm_credit_sgmnt,
        lv_infocat      TYPE bp3100-addtype,
        lv_credit_group TYPE ukm_cred_group.

  DATA: lv_amt     TYPE ukm_amount,
        lv_date    TYPE sy-datum,
        lv_counter TYPE ukm_index.

  DATA: lv_datefr TYPE bp3100-datefr,
        lv_dateto TYPE bp3100-dateto.

  DATA: lt_return   TYPE ukm_t_monitor_return,
        ls_bapiret2 TYPE bapiret2.

  DATA: lv_cms_chk(1),
        lv_sgm_chk(1),
        lv_add_chk(1),
        lv_chk(1).
  DATA: lv_add_flag(1).
  DATA: lv_msg(100).

  DATA(ls_ukmbp) = VALUE #( gt_ukmbp[ 1 ] OPTIONAL ).

  "BP PARTNER
  lv_partner = ls_ukmbp-partner.

  io_facade       = cl_ukm_facade=>create( i_activity = cl_ukm_cnst_eventing=>bp_maintenance ).
  io_bupa_factory = io_facade->get_bupa_factory( ).
  io_partner      = io_bupa_factory->get_business_partner( lv_partner ).

  "BP LOCK 체크
  DATA(lo_bupa) = NEW cl_im_mds_bupa_lock( ).

  CALL METHOD lo_bupa->if_ex_bupa_lock~lock
    EXPORTING
      iv_partner = lv_partner
    CHANGING
      cs_error   = ls_bupa_error.

  IF ls_bupa_error-is_error IS NOT INITIAL.
    gv_error      = gc_x.
    ls_ukmbp-rslt = gc_e.
    DATA(ls_msg) = VALUE #( ls_bupa_error-messages[ type   = gc_e
                                                    id     = 'MC'
                                                    number = '601' ] OPTIONAL ).
    IF ls_msg IS NOT INITIAL.
      ls_ukmbp-message = ls_msg-message.
    ELSE.
      LOOP AT ls_bupa_error-messages INTO ls_msg WHERE type EQ gc_e.
        IF ls_ukmbp-message IS INITIAL.
          ls_ukmbp-message = ls_msg-message.
        ELSE.
          ls_ukmbp-message = |{ ls_ukmbp-message }/{ ls_msg-message }|.
        ENDIF.
      ENDLOOP.
    ENDIF.

    "에러 메세지 처리
    MODIFY gt_ukmbp FROM ls_ukmbp TRANSPORTING rslt message WHERE partner = lv_partner.
    EXIT.
  ENDIF.


*-------------------------------------------------------
*-03. CREDIT SEGMENT - ADDITIONAL INFO
*-------------------------------------------------------
  "여신세그먼트 + 정보범주 별로 처리 한다.
  LOOP AT gt_ukmbp INTO DATA(ls_data) GROUP BY ( criter  = ls_data-criter    "여신세그먼트
                                                 addtype = ls_data-addtype ) " 정보범주
                                      ASCENDING ASSIGNING FIELD-SYMBOL(<fs_main>).

    CLEAR: io_account,lv_credit_sgmnt,lv_infocat,lt_add_info[].

    LOOP AT GROUP <fs_main> ASSIGNING FIELD-SYMBOL(<fs_line>).
      lv_credit_sgmnt = <fs_line>-criter.
      lv_infocat      = <fs_line>-addtype.
      EXIT.
    ENDLOOP.

    CALL METHOD io_bupa_factory->get_credit_account
      EXPORTING
        i_partner         = lv_partner
        i_credit_sgmnt    = lv_credit_sgmnt
      RECEIVING
        ro_credit_account = io_account.

*   ADDITIONAL INFOS
    CALL METHOD io_account->get_add_infos
      EXPORTING
        i_infocategory          = lv_infocat
        i_select_specified_only = gc_x
      RECEIVING
        rt_add_infos            = lt_add_info.

    LOOP AT GROUP <fs_main> ASSIGNING <fs_line>.
      CLEAR:ls_add_info_old,ls_add_info_new,lv_chk.
      ls_add_info_old = VALUE #( lt_add_info[ infotype = <fs_line>-data_type
                                              counter  = <fs_line>-counter   ] OPTIONAL ).
      IF ls_add_info_old IS NOT INITIAL.
        CASE p_step.
          WHEN gc_h.
            CHECK ls_add_info_old-check_relevant IS NOT INITIAL.
          WHEN gc_c.
            CHECK ls_add_info_old-check_relevant IS INITIAL.
        ENDCASE.

        lv_chk = gc_x.

        MOVE-CORRESPONDING ls_add_info_old TO ls_add_info_new.
        CASE p_step.
          WHEN gc_h.
            CLEAR ls_add_info_new-check_relevant.
          WHEN gc_c.
            ls_add_info_new-check_relevant = gc_x.
        ENDCASE.

      ENDIF.

      IF lv_chk EQ gc_x.
        lv_add_chk = gc_x.

        CALL METHOD io_account->set_add_info
          EXPORTING
            is_add_info = ls_add_info_new.

*[S] 안정화 월령체크 해제 CLEAR
        IF p_step = gc_h.
          CLEAR : ls_bp_credit_sgm-xcritical.
          io_account->set_bp_cms_sgm( EXPORTING is_bp_cms_sgm = ls_bp_credit_sgm ).
        ELSEIF p_step = gc_c.
          ls_bp_credit_sgm-xcritical = 'X'.
          io_account->set_bp_cms_sgm( EXPORTING is_bp_cms_sgm = ls_bp_credit_sgm ).
        ENDIF.
*[E] 안정화 월령체크 해제 CLEAR
      ENDIF.
    ENDLOOP.

  ENDLOOP.

  IF lv_add_chk IS NOT INITIAL.
    "여신데이터 저장
    CALL METHOD io_bupa_factory->save_all
      EXPORTING
        i_upd_task       = abap_false
        i_with_add_infos = gc_x
      RECEIVING
        et_return        = lt_return
      EXCEPTIONS
        failed           = 1
        OTHERS           = 2.
    IF line_exists( lt_return[ msgty = 'E' ] ).
      __bapi_transaction_rollback.

      gv_error = gc_x.

      ls_ukmbp-rslt   = gc_e.
      ls_ukmbp-message = TEXT-m03.
      LOOP AT lt_return INTO DATA(ls_return) WHERE msgty EQ gc_e.
        ls_ukmbp-message = |{ ls_ukmbp-message }/{ ls_return-message }|.
      ENDLOOP.

    ELSE.
      __bapi_transaction_commit.

      ls_ukmbp-rslt   = gc_s.

    ENDIF.
  ENDIF.

  "메세지 처리
  MODIFY gt_ukmbp FROM ls_ukmbp TRANSPORTING rslt message WHERE partner = lv_partner.

  io_bupa_factory->refresh_preread_buffer( ).

  CALL METHOD lo_bupa->if_ex_bupa_lock~unlock
    EXPORTING
      iv_partner = lv_partner
    CHANGING
      cs_error   = ls_bupa_error.

  io_bupa_factory->free_all( ).

ENDFORM.
