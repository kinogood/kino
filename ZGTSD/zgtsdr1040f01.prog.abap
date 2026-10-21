*&---------------------------------------------------------------------*
*& Include          ZGTSDR1040F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form popup_to_confirm
*&---------------------------------------------------------------------*
FORM popup_to_confirm  USING    pi_title
                                pi_text1
                                pi_text2
                       CHANGING pe_answer.

**
  CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
    EXPORTING
      textline1 = pi_text1
      textline2 = pi_text2
      titel     = pi_title
    IMPORTING
      answer    = pe_answer.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form message_build
*&---------------------------------------------------------------------*
FORM message_build  USING    pv_msgid
                             pv_msgnr
                             pv_msgv1
                             pv_msgv2
                             pv_msgv3
                             pv_msgv4
                             pv_message.

**
  CLEAR : pv_message.

  CALL FUNCTION 'MESSAGE_TEXT_BUILD'
    EXPORTING
      msgid               = pv_msgid
      msgnr               = pv_msgnr
      msgv1               = pv_msgv1
      msgv2               = pv_msgv2
      msgv3               = pv_msgv3
      msgv4               = pv_msgv4
    IMPORTING
      message_text_output = pv_message.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form convert_auart
*&---------------------------------------------------------------------*
FORM convert_auart  USING    pi_type
                             pi_auart.

**
  CHECK: pi_auart IS NOT INITIAL.

  IF     pi_type = 'I'.
    CALL FUNCTION 'CONVERSION_EXIT_AUART_INPUT'
      EXPORTING
        input  = pi_auart
      IMPORTING
        output = pi_auart.

  ELSEIF pi_type = 'O'.
    CALL FUNCTION 'CONVERSION_EXIT_AUART_OUTPUT'
      EXPORTING
        input  = pi_auart
      IMPORTING
        output = pi_auart.

  ENDIF.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form calc_date_interval
*&---------------------------------------------------------------------*
FORM calc_date_interval  USING    pi_date
                                  pi_day
                                  pi_month
                                  pi_year
                                  pi_signum
                         CHANGING pe_date.

  DATA: lv_date      LIKE p0001-begda,
        lv_days      LIKE t5a4a-dlydy,
        lv_months    LIKE t5a4a-dlymo,
        lv_years     LIKE t5a4a-dlyyr,
        lv_signum    LIKE t5a4a-split,
        lv_calc_date LIKE p0001-begda.

**
  CHECK: pi_date IS NOT INITIAL.

  CLEAR: lv_date, lv_days, lv_months, lv_years, lv_signum,
         lv_calc_date.
  lv_date   = pi_date.
  lv_days   = pi_day.
  lv_months = pi_month.
  lv_years  = pi_year.
  lv_signum = pi_signum.

  CALL FUNCTION 'RP_CALC_DATE_IN_INTERVAL'
    EXPORTING
      date      = lv_date
      days      = lv_days
      months    = lv_months
      signum    = lv_signum
      years     = lv_years
    IMPORTING
      calc_date = lv_calc_date.

  pe_date = lv_calc_date.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form calc_factory_date
*&---------------------------------------------------------------------*
FORM calc_factory_date  USING    pi_date
                                 pi_id
                                 pi_signum
                        CHANGING pe_date.

  DATA: lv_option   LIKE scal-indicator,
        lv_date     LIKE scal-date,
        lv_id       LIKE scal-fcalid,
        lv_fac_date LIKE scal-facdate.

**
  CHECK: pi_date IS NOT INITIAL.

  CLEAR: lv_option, lv_date, lv_id.
  lv_option = pi_signum.
  lv_date   = pi_date.
  lv_id     = pi_id.

  CALL FUNCTION 'DATE_CONVERT_TO_FACTORYDATE'
    EXPORTING
      correct_option               = lv_option
      date                         = lv_date
      factory_calendar_id          = lv_id
    IMPORTING
      factorydate                  = pe_date
    EXCEPTIONS
      calendar_buffer_not_loadable = 1
      correct_option_invalid       = 2
      date_after_range             = 3
      date_before_range            = 4
      date_invalid                 = 5
      factory_calendar_not_found   = 6
      OTHERS                       = 7.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form conv_factory_to_date
*&---------------------------------------------------------------------*
FORM conv_factory_to_date  USING    pi_date
                                    pi_id
                           CHANGING pe_date.

  DATA: lv_date LIKE scal-facdate,
        lv_id   LIKE scal-fcalid.

**
  CLEAR: lv_date, lv_id.
  lv_date = pi_date.
  lv_id   = pi_id.

  CALL FUNCTION 'FACTORYDATE_CONVERT_TO_DATE'
    EXPORTING
      factorydate                  = lv_date
      factory_calendar_id          = lv_id
    IMPORTING
      date                         = pe_date
    EXCEPTIONS
      calendar_buffer_not_loadable = 1
      factorydate_after_range      = 2
      factorydate_before_range     = 3
      factorydate_invalid          = 4
      factory_calendar_id_missing  = 5
      factory_calendar_not_found   = 6
      OTHERS                       = 7.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form initialization
*&---------------------------------------------------------------------*
FORM initialization .

**
* 영업조직.
  IF s_vkorg[] IS INITIAL.
    s_vkorg[] = VALUE #( ( sign = 'I'  option = 'EQ'  low = '6000' ) ).
  ENDIF.
* 유통경로.
  IF s_vtweg[] IS INITIAL.
    s_vtweg[] = VALUE #( ( sign = 'I'  option = 'EQ'  low = '10' ) ).
  ENDIF.
* 제품군.
  IF s_spart[] IS INITIAL.
    s_spart[] = VALUE #( ( sign = 'I'  option = 'EQ'  low = '3C' ) ).
  ENDIF.
* 단가적용월.
  IF s_spmon[] IS INITIAL.
    s_spmon[] = VALUE #( ( sign = 'I'  option = 'EQ'  low = sy-datlo+0(6) ) ).
  ENDIF.

** T-code: ZGTSDR1043 : Display Only.
  CLEAR: gv_disp.
  IF sy-tcode = 'ZGTSDR1043'.
    gv_disp = 'X'.
  ENDIF.
**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form modify_screen_1000
*&---------------------------------------------------------------------*
FORM modify_screen_1000 .

**
  LOOP AT SCREEN.
    IF screen-name = 'S_VKORG-LOW' OR
       screen-name = 'S_VTWEG-LOW' OR
       screen-name = 'S_SPART-LOW' .
      screen-input = 0.
      MODIFY SCREEN.
    ENDIF.
  ENDLOOP.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form f4_spmon
*&---------------------------------------------------------------------*
FORM f4_spmon  CHANGING pe_spmon.

  DATA: lv_month        LIKE isellist-month,
        lv_return_month LIKE isellist-month,
        lv_subrc        LIKE sy-subrc.


**
  CLEAR: lv_month, lv_return_month, lv_subrc.
  lv_month = sy-datlo+0(6).

  CALL FUNCTION 'POPUP_TO_SELECT_MONTH'
    EXPORTING
      actual_month               = lv_month
*     FACTORY_CALENDAR           = ' '
*     HOLIDAY_CALENDAR           = ' '
*     LANGUAGE                   = SY-LANGU
*     START_COLUMN               = 8
*     START_ROW                  = 5
    IMPORTING
      selected_month             = lv_return_month
      return_code                = lv_subrc
    EXCEPTIONS
      factory_calendar_not_found = 1
      holiday_calendar_not_found = 2
      month_not_found            = 3
      OTHERS                     = 4.

  IF lv_subrc = 0 AND
     lv_return_month > 0.
    pe_spmon = lv_return_month.
  ENDIF.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form f4_vkbur
*&---------------------------------------------------------------------*
FORM f4_vkbur  CHANGING pe_vkbur.

  DATA: lr_vkorg  TYPE RANGE OF zgtppt1010-fld_01,
        lt_return TYPE TABLE OF ddshretval.

**
  _clear: lr_vkorg.
  DATA(lv_vkorg) = VALUE #( s_vkorg[ 1 ]-low  OPTIONAL ).
  lr_vkorg = VALUE #( ( sign = 'I'  option = 'EQ'  low = lv_vkorg ) ).

  SELECT fld_03 AS vkbur, fld_04 AS vtext
    FROM zgtppt1010  WHERE module_kind EQ 'SD'
                       AND codegrp     EQ '6005'
                       AND fld_01      IN @lr_vkorg
  INTO TABLE @DATA(lt_vkbur).

  _clear: lt_return.
  IF lt_vkbur[] IS NOT INITIAL.

    CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
      EXPORTING
        retfield        = 'VKBUR'
        dynpprog        = sy-cprog
        dynpnr          = sy-dynnr
        value_org       = 'S'
      TABLES
        value_tab       = lt_vkbur
        return_tab      = lt_return
      EXCEPTIONS
        parameter_error = 1
        no_values_found = 2
        OTHERS          = 3.

    pe_vkbur = VALUE #( lt_return[ 1 ]-fieldval  OPTIONAL ).

  ELSE.
*   유효한 영업팀이 존재하지 않습니다.
    MESSAGE s000 WITH TEXT-e01  DISPLAY LIKE 'E'.
  ENDIF.

**
  FREE: lt_vkbur, lt_return.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form f4_vkgrp
*&---------------------------------------------------------------------*
FORM f4_vkgrp  CHANGING pe_vkgrp.

  DATA: lr_vkorg  TYPE RANGE OF zgtppt1010-fld_01,
        lr_vkbur  TYPE RANGE OF zgtsdt1040-vkbur,
        lt_return TYPE TABLE OF ddshretval.

**
  _clear: lr_vkorg, lr_vkbur.
  IF s_vkbur[] IS NOT INITIAL.
    lr_vkbur[] = CORRESPONDING #( s_vkbur[] ).
  ELSE.

    DATA(lv_vkorg) = VALUE #( s_vkorg[ 1 ]-low  OPTIONAL ).
    lr_vkorg = VALUE #( ( sign = 'I'  option = 'EQ'  low = lv_vkorg ) ).

    SELECT fld_03 AS vkbur, fld_04 AS vtext
      FROM zgtppt1010  WHERE module_kind EQ 'SD'
                         AND codegrp     EQ '6005'
                         AND fld_01      IN @lr_vkorg
    INTO TABLE @DATA(lt_vkbur).

    IF lt_vkbur[] IS NOT INITIAL.
      lr_vkbur = VALUE #( BASE lr_vkbur
                          FOR ls_vkbur  IN lt_vkbur
                          ( sign = 'I'  option = 'EQ'
                            low  = ls_vkbur-vkbur ) ).

    ENDIF.

  ENDIF.

  SELECT a~vkbur, b~vkgrp, b~bezei
    FROM tvbvk AS a  INNER JOIN tvgrt AS b
                     ON a~vkgrp EQ b~vkgrp
   WHERE a~vkbur IN @lr_vkbur
     AND b~spras EQ @sy-langu
    INTO TABLE @DATA(lt_vkgrp).

  _clear: lt_return.
  IF lt_vkgrp[] IS NOT INITIAL.

    CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
      EXPORTING
        retfield        = 'VKGRP'
        dynpprog        = sy-cprog
        dynpnr          = sy-dynnr
        value_org       = 'S'
      TABLES
        value_tab       = lt_vkgrp
        return_tab      = lt_return
      EXCEPTIONS
        parameter_error = 1
        no_values_found = 2
        OTHERS          = 3.

    pe_vkgrp = VALUE #( lt_return[ 1 ]-fieldval  OPTIONAL ).

  ELSE.
*   유효한 영업그룹이 존재하지 않습니다.
    MESSAGE s000 WITH TEXT-e02  DISPLAY LIKE 'E'.
  ENDIF.

**
  FREE: lt_vkbur, lt_return.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form start_process
*&---------------------------------------------------------------------*
FORM start_process .

**
  CLEAR: gv_error, gv_change_h.
*-권한점검
  PERFORM check_authority   USING: '7', '8'.

  PERFORM set_gloval_values.

* 입력값 Check.
  PERFORM check_valid_input_data.

* Get Data / Make List.
  PERFORM get_data.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form check_authority
*&---------------------------------------------------------------------*
FORM check_authority    USING  pi_type.

  DATA: lv_subrc  TYPE sy-subrc,
        lv_date   LIKE sy-datlo,
        lv_fld_01 LIKE zgtppt1010-fld_01,
        lv_fld_03 LIKE zgtppt1010-fld_03.

**
  CHECK: gv_error IS INITIAL.

  CASE pi_type.
    WHEN '7'."영업그룹
      DATA(lv_vkgrp) = VALUE #( s_vkgrp[ 1 ]-low  OPTIONAL ).

      SELECT SINGLE @abap_true
        FROM tvkgr  WHERE vkgrp EQ @lv_vkgrp
        INTO @DATA(lv_flag).

      IF lv_flag IS INITIAL.
        gv_error = 'X'.
*       유효한 영업그룹을 입력 하세요.
        MESSAGE s000 WITH TEXT-e31 DISPLAY LIKE 'E'.

      ELSE.

        CLEAR lv_subrc.
        PERFORM authorization_check_exec    USING    pi_type
                                                     lv_vkgrp
                                            CHANGING lv_subrc.
        IF lv_subrc NE 0.
          gv_error = 'X'.
          MESSAGE s203 WITH lv_vkgrp DISPLAY LIKE 'E'.
          EXIT.
        ENDIF.

      ENDIF.

    WHEN '8'."영업팀
      CLEAR: lv_fld_01, lv_fld_03.
      DATA(lv_vkorg) = VALUE #( s_vkorg[ 1 ]-low  OPTIONAL ).
      DATA(lv_vkbur) = VALUE #( s_vkbur[ 1 ]-low  OPTIONAL ).
      DATA(lv_spmon) = VALUE #( s_spmon[ 1 ]-low  OPTIONAL ).

      lv_fld_01 = lv_vkorg.
      lv_fld_03 = lv_vkbur.
      lv_date   = lv_spmon && '01'.

      CLEAR: lv_flag.
      SELECT SINGLE @abap_true
        FROM zgtppt1010  WHERE module_kind EQ 'SD'
                           AND codegrp     EQ '6005'
                           AND fld_01      EQ @lv_fld_01
                           AND fld_03      EQ @lv_fld_03
                           AND fld_07      LE @lv_date
                           AND fld_08      GE @lv_date
      INTO @lv_flag.

      IF lv_flag IS INITIAL.
        gv_error = 'X'.
*       유효하지 않은 영업팀입니다.
        MESSAGE s000 WITH TEXT-e33  DISPLAY LIKE 'E'.

      ELSE.

        CLEAR lv_subrc.
        PERFORM authorization_check_exec    USING    pi_type
                                                     lv_vkbur
                                            CHANGING lv_subrc.

        IF lv_subrc NE 0.
          gv_error = 'X'.
*         해당 영업팀에 대한 권한이 없습니다.
          MESSAGE s000 WITH TEXT-e32  DISPLAY LIKE 'E'.
          EXIT.
        ENDIF.

      ENDIF.

  ENDCASE.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form authorization_check_exec
*&---------------------------------------------------------------------*
FORM authorization_check_exec  USING    pv_step
                                        pv_value
                               CHANGING pv_subrc.
  DATA:lv_vkorg TYPE vkorg,
       lv_vtweg TYPE vtweg,
       lv_spart TYPE spart,
       lv_vkgrp TYPE vkgrp,
       lv_vkbur TYPE vkbur.
  DATA:lv_type(1).

**
  lv_type = pv_step.

  CASE lv_type.
    WHEN '1'."영업조직
      lv_vkorg = pv_value.
      CALL FUNCTION 'ZGTSD_AUTHORIZATION_CHECK'
        EXPORTING
          i_vkorg = lv_vkorg
          i_type  = lv_type
        IMPORTING
          e_subrc = pv_subrc.

    WHEN '2'."유통채널
      lv_vtweg = pv_value.
      CALL FUNCTION 'ZGTSD_AUTHORIZATION_CHECK'
        EXPORTING
          i_vtweg = lv_vtweg
          i_type  = lv_type
        IMPORTING
          e_subrc = pv_subrc.

    WHEN '3'."제품군
      lv_spart = pv_value.
      CALL FUNCTION 'ZGTSD_AUTHORIZATION_CHECK'
        EXPORTING
          i_spart = lv_spart
          i_type  = lv_type
        IMPORTING
          e_subrc = pv_subrc.

    WHEN '7'."영업그룹
      lv_vkgrp = pv_value.
      CALL FUNCTION 'ZGTSD_AUTHORIZATION_CHECK'
        EXPORTING
          i_vkgrp = lv_vkgrp
          i_type  = lv_type
        IMPORTING
          e_subrc = pv_subrc.

    WHEN '8'."영업팀
      lv_vkbur = pv_value.
      CALL FUNCTION 'ZGTSD_AUTHORIZATION_CHECK'
        EXPORTING
          i_vkbur = lv_vkbur
          i_type  = lv_type
        IMPORTING
          e_subrc = pv_subrc.

  ENDCASE.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form set_gloval_values
*&---------------------------------------------------------------------*
FORM set_gloval_values .

**
  CLEAR: gv_vkorg, gv_vtweg, gv_spart,
         gv_vkbur, gv_vkgrp, gv_spmon.

  gv_vkorg = VALUE #( s_vkorg[ 1 ]-low  OPTIONAL ).
  gv_vtweg = VALUE #( s_vtweg[ 1 ]-low  OPTIONAL ).
  gv_spart = VALUE #( s_spart[ 1 ]-low  OPTIONAL ).
  gv_vkbur = VALUE #( s_vkbur[ 1 ]-low  OPTIONAL ).
  gv_vkgrp = VALUE #( s_vkgrp[ 1 ]-low  OPTIONAL ).
  gv_spmon = VALUE #( s_spmon[ 1 ]-low  OPTIONAL ).

  CLEAR: gv_first_day, gv_last_day.
  gv_first_day = gv_spmon && '01'.
  PERFORM get_last_day_of_month   USING    gv_first_day
                                  CHANGING gv_last_day.
**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form check_valid_input_data
*&---------------------------------------------------------------------*
FORM check_valid_input_data .

**
  CHECK: gv_error IS INITIAL.

  IF s_spmon[] IS INITIAL.
    gv_error = 'X'.
*   매출마감 월이 입력되지 않았습니다.
    MESSAGE s000 WITH TEXT-e03  DISPLAY LIKE 'E'.

  ELSE.
*   매출정산월 Check.
    PERFORM check_valid_spmon_date.

*   소재사업부 거래처 Check
    PERFORM check_valid_kunag.

*   가공비 단가 Check.
    PERFORM check_zgtsdt1030_data.

  ENDIF.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form check_valid_spmon_date
*&---------------------------------------------------------------------*
FORM check_valid_spmon_date .

  DATA: lv_active(1),
        lv_date      LIKE sy-datlo,
        lv_date_n    LIKE sy-datlo,
        lv_fac_date  LIKE scal-facdate.

**
  CHECK: gv_error IS INITIAL,
         gv_spmon IS NOT INITIAL,
         gv_disp  IS INITIAL.

  CHECK: gv_spmon < sy-datlo+0(6).

* 예외 사용자 Check.
  SELECT SINGLE @abap_true
    FROM zgtppt1010  WHERE module_kind EQ 'SD'
                       AND codegrp     EQ '6ZZZ'
                       AND fld_01      EQ @sy-repid
                       AND fld_02      EQ @sy-uname
    INTO @DATA(lv_flg).

  IF lv_flg IS INITIAL.

*   영업팀 단위로 로직 예외 여부확인.
    CLEAR: lv_active.
    CALL FUNCTION 'ZGTSD_EXIT_CONTROL'
      EXPORTING
        i_prog   = sy-repid
        i_vkorg  = gv_vkorg
        i_vkbur  = gv_vkbur
      IMPORTING
        e_active = lv_active.

    IF lv_active NE 'Y'.
      DATA(lv_chk) = 'X'.
    ENDIF.

  ENDIF.

* 단가적용 월 점검.
  IF lv_chk IS NOT INITIAL.

*   Next Month
    CLEAR: lv_date, lv_date_n.
    lv_date = gv_spmon && '01'.
    PERFORM calc_date_interval   USING    lv_date
                                          ' '    " Day
                                          '1'    " Month
                                          ' '    " Year
                                          '+'    " signum
                                 CHANGING lv_date_n.
*   Day + 1 from Factory Date
    CLEAR: lv_date, lv_fac_date.
    lv_date = lv_date_n.
    PERFORM calc_factory_date    USING    lv_date
                                          'LS'    " Factory ID
                                          '+'     " Signum
                                 CHANGING lv_fac_date.

*   익월 3 영업일 날짜 계산.
    CLEAR: lv_date_n.
    lv_fac_date = lv_fac_date + 2.
    PERFORM conv_factory_to_date USING    lv_fac_date
                                          'LS'    " Factory ID
                                 CHANGING lv_date_n.

    IF sy-datlo > lv_date_n.
      gv_error = 'X'.
*     매출 정산은 3영업일까지 생성/수정 가능합니다. ( 과거 Data조회: ZGTSDR1043 ).
      MESSAGE s000 WITH TEXT-e04  DISPLAY LIKE 'E'.
    ENDIF.

  ENDIF.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form check_valid_kunag
*&---------------------------------------------------------------------*
FORM check_valid_kunag .

  DATA: lv_date  LIKE sy-datum.

**
  CHECK: gv_error IS INITIAL.

  CLEAR: lv_date.
  lv_date = gv_spmon && '01'.

  SELECT SINGLE @abap_true
    FROM i_businesspartnercustomer AS bp INNER JOIN ukmbp_cms_sgm AS sgm
                                         ON  bp~businesspartner EQ sgm~partner
                                         INNER JOIN zgtppt1010 AS cdm
                                         ON  sgm~credit_sgmnt EQ cdm~fld_05
  WHERE bp~customer     IN @s_kunag
    AND cdm~fld_01      EQ @gv_vkorg
    AND cdm~fld_07      LE @lv_date
    AND cdm~fld_08      GE @lv_date
    AND cdm~module_kind EQ 'SD'
    AND cdm~codegrp     EQ '6005'
   INTO @DATA(lv_flg).

  IF lv_flg IS INITIAL.
    gv_error = 'X'.
*   소재사업부에 해당하는 거래처만 매출 정산이 가능합니다.
    MESSAGE s000 WITH TEXT-e05  DISPLAY LIKE 'E'.
  ENDIF.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form check_zgtsdt1030_data
*&---------------------------------------------------------------------*
FORM check_zgtsdt1030_data .

**
  CHECK: gv_error IS INITIAL.

  SELECT SINGLE @abap_true
    FROM zgtsdt1030  WHERE spmon IN @s_spmon
                       AND vkorg IN @s_vkorg
                       AND vtweg IN @s_vtweg
                       AND spart IN @s_spart
                       AND vkbur IN @s_vkbur
                       AND kunnr IN @s_kunag
                       AND kbetr GT 0
    INTO @DATA(lv_flg).

  IF lv_flg IS INITIAL.
    gv_error = 'X'.
*   매출정산월에 해당하는 가공비 단가 내용이 없습니다.
    MESSAGE s000 WITH TEXT-e06  DISPLAY LIKE 'E'.
  ENDIF.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form get_data
*&---------------------------------------------------------------------*
FORM get_data .

**
  CHECK: gv_error IS INITIAL.

  _clear: gt_head, gt_item, gt_item_tmp.

* 평균 동가 산출.
  PERFORM get_nf_price_info.

* 매출정산월에 이미 저장된 Data Get.
  PERFORM get_recon_data_from_log.

* 출고내역 집계데이타 Get
  PERFORM get_summary_recon_data_for_std.

* Make list
  PERFORM make_item_list.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form get_nf_price_info
*&---------------------------------------------------------------------*
FORM get_nf_price_info .

  DATA: lv_date  LIKE oicqp-quotdate.

**
  CHECK: gv_error IS INITIAL.

  CLEAR: gs_nfprice,
         lv_date.

  lv_date = gv_spmon && '01'.

  SELECT SINGLE price, defper
    FROM oicqp  WHERE quosrc   EQ 'NF'
                  AND quotyp   EQ 'M1LOP'
                  AND quotno   EQ 'CU KRW'
                  AND quotdate EQ @lv_date
    INTO @gs_nfprice.

  IF gs_nfprice-price > 0 AND
     gs_nfprice-defper > 0.
    gs_nfprice-nfprice = gs_nfprice-price / gs_nfprice-defper.
  ENDIF.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form get_recon_data_from_log
*&---------------------------------------------------------------------*
FORM get_recon_data_from_log .

**
  CHECK: gv_error IS INITIAL.

* Get Header Data.
  _clear: gt_head.
  SELECT a~*,
         CASE a~prereconsta  " 정산 Data 저장상태
              WHEN 'C'  THEN @icon_led_green
         ELSE @icon_led_inactive
         END AS save,
         CASE a~reconsta     " 정산상태
              WHEN 'A'  THEN @icon_led_yellow    " 판매오더 생성상태
              WHEN 'B'  THEN @icon_led_yellow    " 납품오더 생성상태
              WHEN 'C'  THEN @icon_led_yellow    " 배치 지정 상태
              WHEN 'D'  THEN @icon_led_yellow    " Good Issue 상태
              WHEN 'E'  THEN @icon_led_green     " Billing Block상태
         ELSE @icon_led_inactive
         END AS stat
    FROM zgtsdt1040 AS a
   WHERE a~spmon IN @s_spmon
     AND a~vkorg IN @s_vkorg
     AND a~vtweg IN @s_vtweg
     AND a~spart IN @s_spart
     AND a~vkbur IN @s_vkbur
     AND a~vkgrp IN @s_vkgrp
     AND a~kunag IN @s_kunag
    INTO CORRESPONDING FIELDS OF TABLE @gt_head.

* Get Item Data.
  _clear: gt_save_item.
  SELECT *
    FROM zgtsdt1041
   WHERE spmon IN @s_spmon
     AND vkorg IN @s_vkorg
     AND vkbur IN @s_vkbur
     AND vkgrp IN @s_vkgrp
     AND kunag IN @s_kunag
    INTO CORRESPONDING FIELDS OF TABLE @gt_save_item.

* Get Billing Info
  DATA(lt_data) = gt_save_item[].
  DELETE lt_data  WHERE vbeln    EQ space
                     OR do_vbeln EQ space.

  _clear: gt_bl_info.
  IF lt_data[] IS NOT INITIAL.

    SELECT a~vbeln, a~posnr, a~do_vbeln, a~do_posnr,
           b~vbeln_bl AS bl_vbeln, b~posnr_bl AS bl_posnr
      FROM @lt_data AS a  INNER JOIN zgtsd_i_valid_billing AS b
                          ON  a~vbeln    EQ b~vbeln_so
                          AND a~posnr    EQ b~posnr_so
                          AND a~do_vbeln EQ b~vbeln_do
                          AND a~do_posnr EQ b~posnr_do
      INTO CORRESPONDING FIELDS OF TABLE @gt_bl_info.

  ENDIF.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form get_summary_recon_data_for_std
*&---------------------------------------------------------------------*
FORM get_summary_recon_data_for_std .
  DATA: lt_head_tmp     LIKE TABLE OF gs_head.

  DATA: lv_1per  TYPE p DECIMALS 1,
        lr_wadat LIKE RANGE OF likp-wadat_ist.

**
  CHECK: gv_error IS INITIAL.

  CLEAR: lv_1per.
  lv_1per = '0.1'.

  _clear: lr_wadat.
  lr_wadat = VALUE #( ( sign = 'I'           option = 'BT'
                        low  = gv_first_day  high   = gv_last_day ) ).

* 정산 월/거래처/자재코드/프로젝트 코드/통화 단위로 출고내역 집계
  SELECT soi~kunnr_ana AS kunag, cust~name1 AS customername,
         soi~matnr, soi~arktx,
         soi~vkorg_ana AS vkorg, soi~vtweg_ana AS vtweg,
         soi~spart_ana AS spart, soi~vkbur_ana AS vkbur,
         soi~vkgrp_ana AS vkgrp, soi~waerk,
         do~wadat_ist, do~vrkme,
         pjt~zpjno, pjt~zptxt,
         SUM( do~lfimg ) AS lfimg,
         SUM( soi~netpr * do~lfimg ) AS netwr

    FROM zgtsd_i_delivery_base_sum AS do  INNER JOIN vbap AS soi
                                          ON  do~vbeln_so EQ soi~vbeln
                                          AND do~posnr_so EQ soi~posnr
                                          AND soi~pstyv   EQ 'ZSCR'
                                          INNER JOIN vbak AS soh
                                          ON soi~vbeln EQ soh~vbeln
                                          LEFT OUTER JOIN zsd0106t AS pjt
                                          ON soh~zpjno EQ pjt~zpjno
                                          INNER JOIN kna1 AS cust
                                          ON soi~kunnr_ana EQ cust~kunnr
   WHERE soi~kunnr_ana IN @s_kunag
     AND soi~vkorg_ana IN @s_vkorg
     AND soi~vtweg_ana IN @s_vtweg
     AND soi~spart_ana IN @s_spart
     AND soi~vkbur_ana IN @s_vkbur
     AND soi~vkgrp_ana IN @s_vkgrp
     AND do~wadat_ist  IN @lr_wadat
     AND do~wbsta EQ 'C'
   GROUP BY soi~kunnr_ana, cust~name1, soi~matnr, soi~arktx,
            soi~vkorg_ana, soi~vtweg_ana, soi~spart_ana, soi~vkbur_ana,
            soi~vkgrp_ana, soi~waerk,
            do~wadat_ist, do~vrkme, pjt~zpjno, pjt~zptxt
    INTO TABLE @DATA(lt_data).

  IF lt_data[] IS NOT INITIAL AND
     gt_head[] IS NOT INITIAL.

    SORT: lt_data BY vkorg vkbur vkgrp kunag matnr wadat_ist.

    LOOP AT gt_head  INTO DATA(ls_head).

      DATA(lv_sum_index) = sy-tabix.

      DATA(lv_lfimg) = REDUCE i( INIT x = 0
                                 FOR ls_data_sum  IN lt_data
                                 WHERE ( vkorg     EQ ls_head-vkorg AND
                                         vkbur     EQ ls_head-vkbur AND
                                         vkgrp     EQ ls_head-vkgrp AND
                                         kunag     EQ ls_head-kunag AND
                                         matnr     EQ ls_head-matnr AND
                                         wadat_ist IN lr_wadat )
                                 NEXT x = x + ls_data_sum-lfimg ).

      ls_head-cur_lfimg = lv_lfimg.
      MODIFY gt_head  FROM ls_head  INDEX lv_sum_index.

      DELETE lt_data  WHERE wadat_ist IN lr_wadat
                        AND vkorg = ls_head-vkorg
                        AND vkbur = ls_head-vkbur
                        AND vkgrp = ls_head-vkgrp
                        AND kunag = ls_head-kunag
                        AND matnr = ls_head-matnr.
    ENDLOOP.

  ENDIF.



  IF lt_data[] IS NOT INITIAL.
    lt_head_tmp = VALUE #(   "BASE gt_head
                       FOR ls_data  IN lt_data
                       ( VALUE #( BASE CORRESPONDING #( ls_data )
                         spmon       = ls_data-wadat_ist+0(6)
                         mwsbp       = ls_data-netwr * lv_1per
                         prereconsta = space
                         reconsta    = space
                         cur_lfimg   = ls_data-lfimg
                         drs_qty     = ls_data-lfimg   " - LS_DATA-OEMGR_SUMQTY"ls_data-oemgr_qty
                         save        = icon_led_inactive
                         stat        = icon_led_inactive )
                        )
                      ).

*    gt_head = VALUE #( BASE gt_head
*                       FOR ls_data  IN lt_data
*                       ( VALUE #( BASE CORRESPONDING #( ls_data )
*                         spmon       = ls_data-wadat_ist+0(6)
*                         mwsbp       = ls_data-netwr * lv_1per
*                         prereconsta = space
*                         reconsta    = space
***                       For Test
**                         oemgr_qty   = 100   " Test 용
*                         drs_qty     = ls_data-lfimg   " - LS_DATA-OEMGR_SUMQTY"ls_data-oemgr_qty
***
*                         save        = icon_led_inactive
*                         stat        = icon_led_inactive )
*                        )
*                      ).



  ENDIF.

  "OEM 입고 정보 추출
  IF lt_data[] IS NOT INITIAL.
    SORT lt_data BY kunag.
    DATA(lt_temp) = lt_data[].
    DELETE ADJACENT DUPLICATES FROM lt_data COMPARING kunag.

    SELECT a~kunag,c~period,
           SUM( c~tax0_kg )  AS oeml_grqty,
           SUM( c~tax10_kg ) AS oemn_grqty
      FROM @lt_temp AS a INNER JOIN kna1 AS b "Customer Master
                         ON a~kunag = b~kunnr
                         INNER JOIN zgtmm_cv_get_gtqty_sweight AS c
                         ON b~lifnr = c~lifnr
     WHERE c~period IN @s_spmon
      GROUP BY c~period,a~kunag
      INTO TABLE @DATA(lt_sum).

    "KNA1에 Vendor 정보가 없을 경우 LFA1의 판매처 정보를 기준으로 LIFNR 찾음
    SELECT a~kunag,c~period,
           SUM( c~tax0_kg )  AS oeml_grqty,
           SUM( c~tax10_kg ) AS oemn_grqty
      FROM @lt_temp AS a INNER JOIN lfa1 AS b "Vendor Master
                         ON a~kunag = b~kunnr
                         INNER JOIN zgtmm_cv_get_gtqty_sweight AS c
                         ON b~lifnr = c~lifnr
     WHERE c~period IN @s_spmon
      GROUP BY c~period,a~kunag
      APPENDING TABLE @lt_sum.

    DELETE ADJACENT DUPLICATES FROM lt_sum COMPARING kunag period.
    SORT lt_sum BY kunag period.

    LOOP AT lt_head_tmp ASSIGNING FIELD-SYMBOL(<fs_head_tmp>).
      READ TABLE lt_sum INTO DATA(ls_sum) WITH KEY kunag  = <fs_head_tmp>-kunag
                                                   period = <fs_head_tmp>-spmon.
      IF sy-subrc EQ 0.
        <fs_head_tmp>-oeml_grqty   = ls_sum-oeml_grqty.
        <fs_head_tmp>-oemn_grqty   = ls_sum-oemn_grqty.
        <fs_head_tmp>-oemgr_sumqty = ls_sum-oeml_grqty + ls_sum-oemn_grqty.
        <fs_head_tmp>-oemgr_qty    = <fs_head_tmp>-oemgr_sumqty.
        <fs_head_tmp>-drs_qty      = <fs_head_tmp>-lfimg - <fs_head_tmp>-oemgr_qty.
      ELSE.
        <fs_head_tmp>-oemgr_qty    = <fs_head_tmp>-oemgr_sumqty.
        <fs_head_tmp>-drs_qty      = <fs_head_tmp>-lfimg - <fs_head_tmp>-oemgr_qty.
      ENDIF.
    ENDLOOP.

    IF lt_head_tmp[] IS NOT INITIAL.
      APPEND LINES OF lt_head_tmp TO gt_head.
    ENDIF.
  ENDIF.

**
*-HEADER OEML_GRQTY,OEMN_GRQTY => EDIT
  LOOP AT gt_head INTO gs_head.
    DATA(lv_index) = sy-tabix.

    IF gs_head-reconsta    EQ space AND
       gs_head-prereconsta EQ space.
      CLEAR gs_head-noedit.
    ELSE.
      gs_head-noedit = 'X'.
    ENDIF.

    IF gv_disp IS NOT INITIAL.
      gs_head-noedit = 'X'.
    ENDIF.

    PERFORM set_alv_style_color  USING    'H'.

    MODIFY gt_head FROM gs_head INDEX lv_index.
  ENDLOOP.

  FREE: lt_data,lt_temp,lt_sum.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form make_item_list
*&---------------------------------------------------------------------*
FORM make_item_list .

  DATA: lv_adj_avg_netpr LIKE zgtsdt1040-adj_avg_netpr,
        lv_adj_avg_netwr LIKE zgtsdt1040-adj_avg_netwr,
        lv_adj_avg_mwsbp LIKE zgtsdt1040-adj_avg_mwsbp.

**
  CHECK: gv_error  IS INITIAL,
         gt_head[] IS NOT INITIAL.

* Line 생성을 위한 Data Get.
  PERFORM line_infomation_data_get    TABLES  gt_head.

  SORT: gt_head      BY kunag matnr ,
        gt_save_item BY kunag zseglev2 kondm,
        gt_seginfo   BY kunag zpjno zseglev2,
        gt_kondm     BY kunnr matnr kondm,
        gt_type      BY fld_07 fld_06.

* Make Item list.
*  LOOP AT gt_head  INTO DATA(ls_head).
  LOOP AT gt_head  ASSIGNING FIELD-SYMBOL(<lfs_wa>).

    CLEAR: lv_adj_avg_netpr, lv_adj_avg_netwr, lv_adj_avg_mwsbp.

*   가공비 유형별 라인 생성.
    READ TABLE gt_kondm  INTO DATA(ls_kondm)
                         WITH KEY kunnr = <lfs_wa>-kunag
                                  matnr = <lfs_wa>-matnr
                         BINARY SEARCH.
    IF sy-subrc = 0.
      LOOP AT gt_kondm INTO ls_kondm  FROM sy-tabix.
        IF ls_kondm-kunnr = <lfs_wa>-kunag AND
           ls_kondm-matnr = <lfs_wa>-matnr.

*         Make Line item.
          CLEAR: gs_item.
          PERFORM modify_line_item     USING    <lfs_wa>
                                                ls_kondm
                                       CHANGING gs_item.

          IF <lfs_wa>-reconsta IS NOT INITIAL.
            gs_item-noedit = 'X'.
          ENDIF.

          IF gv_disp IS NOT INITIAL.
            gs_item-noedit = 'X'.
          ENDIF.

*         Set ALV Field Style / Color
          PERFORM set_alv_style_color  USING    'I'.

          IF gs_item-fkimg <> 0.
            lv_adj_avg_netpr = lv_adj_avg_netpr + gs_item-netpr.
            lv_adj_avg_netwr = lv_adj_avg_netwr + gs_item-netwr.
            lv_adj_avg_mwsbp = lv_adj_avg_mwsbp + gs_item-mwsbp.
          ENDIF.

          APPEND gs_item TO gt_item_tmp.

        ELSE.
          EXIT.
        ENDIF.
      ENDLOOP.
    ENDIF.

    IF <lfs_wa>-reconsta    IS INITIAL AND
       <lfs_wa>-prereconsta IS INITIAL.
*      <lfs_wa>-adj_avg_netpr = lv_adj_avg_netpr.
      <lfs_wa>-adj_avg_netwr = lv_adj_avg_netwr.
      <lfs_wa>-adj_avg_mwsbp = lv_adj_avg_mwsbp.
      IF <lfs_wa>-lfimg <> 0 AND lv_adj_avg_netwr NE 0.
        <lfs_wa>-adj_avg_netpr = lv_adj_avg_netwr / <lfs_wa>-lfimg.
      ENDIF.
      <lfs_wa>-diff_netwr = <lfs_wa>-netwr - <lfs_wa>-adj_avg_netwr.
      <lfs_wa>-diff_mwsbp = <lfs_wa>-mwsbp - <lfs_wa>-adj_avg_mwsbp.
    ENDIF.

  ENDLOOP.

  SORT gt_item_tmp BY kunag zseglev2 kondm.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form get_last_day_of_month
*&---------------------------------------------------------------------*
FORM get_last_day_of_month  USING    pi_date
                            CHANGING pe_date.

**
  CHECK: pi_date IS NOT INITIAL.

  CALL FUNCTION 'RP_LAST_DAY_OF_MONTHS'
    EXPORTING
      day_in            = pi_date
    IMPORTING
      last_day_of_month = pe_date
    EXCEPTIONS
      day_in_no_date    = 1
      OTHERS            = 2.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form make_item_list_from_std_data
*&---------------------------------------------------------------------*
FORM make_item_list_from_std_data  TABLES   pt_temp STRUCTURE zgtsdt1040.

  DATA: lt_seginfo  TYPE TABLE OF zgtsdt1110,
        lt_kondm    TYPE TABLE OF zgtsdt1030,
        ls_item     TYPE zgtsdt1041,

        lv_fld_07   LIKE zgtppt1010-fld_07,
        lv_first(1).

**
  CHECK: pt_temp[] IS NOT INITIAL.

* Segment Info, Kondm Info.
*  PERFORM line_infomation_data_get    TABLES  pt_temp
*                                              lt_seginfo
*                                              lt_kondm.

  DATA(lt_base) = pt_temp[].
  SORT: lt_base    BY kunag matnr vkorg vtweg spart vkbur vkgrp,
        pt_temp    BY kunag matnr vkorg vtweg spart vkbur vkgrp zpjno,
        lt_seginfo BY kunag vkorg vkgrp zpjno zseglev2,
        lt_kondm   BY kunnr matnr vkorg vtweg spart vkbur kondm,
        gt_type    BY fld_07 fld_06.

  DELETE ADJACENT DUPLICATES FROM lt_base
                             COMPARING kunag matnr
                                       vkorg vtweg spart vkbur vkgrp.

* Make Item list.
  LOOP AT lt_base  INTO DATA(ls_base).

*   Project No / Kondm 별 line 생성.
    READ TABLE pt_temp  INTO DATA(ls_temp)
                        WITH KEY kunag = ls_base-kunag
                                 matnr = ls_base-matnr
                                 vkorg = ls_base-vkorg
                                 vtweg = ls_base-vtweg
                                 spart = ls_base-spart
                                 vkbur = ls_base-vkbur
                                 vkgrp = ls_base-vkgrp
                        BINARY SEARCH.
    IF sy-subrc = 0.
      LOOP AT pt_temp INTO ls_temp  FROM sy-tabix.
        IF ls_temp-kunag = ls_base-kunag AND
           ls_temp-matnr = ls_base-matnr AND
           ls_temp-vkorg = ls_base-vkorg AND
           ls_temp-vtweg = ls_base-vtweg AND
           ls_temp-spart = ls_base-spart AND
           ls_temp-vkbur = ls_base-vkbur AND
           ls_temp-vkgrp = ls_base-vkgrp .

*         Item base
          CLEAR: ls_item.
          ls_item = VALUE #( spmon = ls_base-spmon
                             vkorg = ls_base-vkorg
                             vkbur = ls_base-vkbur
                             vkgrp = ls_base-vkgrp
                             kunag = ls_base-kunag
                             vrkme = ls_base-vrkme
                             waerk = ls_base-waerk ).
*         Set Segment.
          DATA(ls_seg) = VALUE #( lt_seginfo[ kunag = ls_temp-kunag
                                              vkorg = ls_temp-vkorg
                                              vkgrp = ls_temp-vkgrp
                                              zpjno = ls_temp-zpjno ]
                                  OPTIONAL ).

          CLEAR: lv_fld_07.
          lv_fld_07         = ls_seg-zseglev2.
          ls_item-zseglev2  = ls_seg-zseglev2.
          ls_item-zseglev2t = ls_seg-zseglev2t.

*         Set KONDM.
          CLEAR: lv_first.
          lv_first = 'X'.

          READ TABLE gt_type  INTO DATA(ls_type)
                              WITH KEY fld_07 = lv_fld_07
                              BINARY SEARCH.
          IF sy-subrc = 0.
            LOOP AT gt_type INTO ls_type  FROM sy-tabix.
              IF ls_type-fld_07 = lv_fld_07.

                CLEAR: ls_item-kondm, ls_item-kbetr, ls_item-fkimg.

                ls_item-kondm  = ls_type-fld_02.
*                ls_item-kondmt = ls_type-fld_03.

                ls_item-kbetr = VALUE #( lt_kondm[ kunnr = ls_base-kunag
                                                   matnr = ls_base-matnr
                                                   vkorg = ls_base-vkorg
                                                   vtweg = ls_base-vtweg
                                                   spart = ls_base-spart
                                                   vkbur = ls_base-vkbur
                                                   kondm = ls_item-kondm ]-kbetr
                                         OPTIONAL ).

                IF lv_first IS NOT INITIAL.

                  CASE ls_item-zseglev2.
                    WHEN 'S001'.    " Direct
                      IF ls_base-drs_qty > 0.
                        ls_item-fkimg = ls_base-drs_qty.
                      ENDIF.

                    WHEN 'S002'.    " OEM
                      IF ls_base-oemgr_qty > 0.
                        ls_item-fkimg = ls_base-oemgr_qty.
                      ENDIF.

                  ENDCASE.

                  CLEAR: lv_first.

                ENDIF.

              ELSE.
                EXIT.
              ENDIF.
            ENDLOOP.
          ENDIF.

        ELSE.
          EXIT.
        ENDIF.
      ENDLOOP.
    ENDIF.

  ENDLOOP.

**
  FREE: lt_base, lt_seginfo, lt_kondm.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form line_infomation_data_get
*&---------------------------------------------------------------------*
FORM line_infomation_data_get  TABLES   pt_temp    STRUCTURE gs_head.

  DATA: lv_date LIKE sy-datlo,
*        lr_stat TYPE RANGE OF zecrmstat,
        lr_seg  TYPE RANGE OF zgteseglev2.

**
  CHECK: pt_temp[] IS NOT INITIAL.

  _clear: gt_seginfo, gt_kondm.

* 세그먼트 정보 Get.
  DATA(lt_pjno) = pt_temp[].
  SORT: lt_pjno BY vkorg vkgrp kunag.
  DELETE ADJACENT DUPLICATES FROM lt_pjno COMPARING vkorg vkgrp kunag.

  IF lt_pjno[] IS NOT INITIAL.

    LOOP AT lt_pjno ASSIGNING FIELD-SYMBOL(<lfs_pjno>).
      <lfs_pjno>-kunag = CONV kunnr( |{ <lfs_pjno>-kunag ALPHA = OUT }| ).
    ENDLOOP.

*    _clear: lr_stat, lr_seg.
    _clear: lr_seg.
*    lr_stat = VALUE #( ( sign = 'E' option = 'EQ' low = 'D010' )
*                       ( sign = 'E' option = 'EQ' low = 'E010' )
*                       ( sign = 'E' option = 'EQ' low = 'Z010' ) ).

    lr_seg = VALUE #( ( sign = 'I' option = 'EQ' low = 'S001' )
                      ( sign = 'I' option = 'EQ' low = 'S002' ) ).

    SELECT a~vkorg, a~vkgrp, a~kunag, b~zpjno,
           b~zseglev2, b~zseglev2t
      FROM @lt_pjno AS a  INNER JOIN zgtsdt1110 AS b
*                          ON  a~zpjno EQ b~zpjno
                          ON  a~vkorg EQ b~vkorg
                          AND a~vkgrp EQ b~vkgrp
                          AND a~kunag EQ b~kunag
                          INNER JOIN zsd0106t AS c
                          ON  b~zpjno EQ c~zpjno
     WHERE c~stat     EQ 'C010' "수주확정 Pjt
       AND b~zseglev2 IN @lr_seg
      INTO CORRESPONDING FIELDS OF TABLE @gt_seginfo.

  ENDIF.

* KONDM Info.
  DATA(lt_temp) = pt_temp[].
  SORT: lt_temp BY spmon vkorg kunag matnr.
  DELETE ADJACENT DUPLICATES FROM lt_temp COMPARING spmon vkorg kunag matnr.

  IF lt_temp[] IS NOT INITIAL.

    SELECT a~spmon, a~vkorg, a~vtweg, a~spart, a~vkbur,
           a~kunag AS kunnr, a~matnr,
           b~kondm, b~kondmt, b~kbetr
      FROM @lt_temp AS a  INNER JOIN zgtsdt1030 AS b
                          ON  a~spmon EQ b~spmon
                          AND a~vkorg EQ b~vkorg
                          AND a~vtweg EQ b~vtweg
                          AND a~spart EQ b~spart
                          AND a~vkbur EQ b~vkbur
                          AND a~kunag EQ b~kunnr
                          AND a~matnr EQ b~matnr
      INTO CORRESPONDING FIELDS OF TABLE @gt_kondm.

  ENDIF.

* KONDM from master data.
  CLEAR: lv_date.
  lv_date = gv_spmon && '01'.

  _clear: gt_type.
  SELECT codeid, fld_01, fld_02, fld_03, fld_06, fld_07
    FROM zgtppt1010  WHERE module_kind EQ 'SD'
                       AND codegrp     EQ '6006'
                       AND fld_04      LE @lv_date
                       AND fld_05      GE @lv_date
    INTO CORRESPONDING FIELDS OF TABLE @gt_type.

**
  FREE: lt_pjno, lt_temp.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form modify_line_item
*&---------------------------------------------------------------------*
FORM modify_line_item  USING    ps_head    LIKE gs_head
                                ps_kondm   LIKE zgtsdt1030
                       CHANGING ps_item    LIKE gs_item.

  DATA: lv_fld_02 LIKE zgtppt1010-fld_02,
        lv_fld_06 LIKE zgtppt1010-fld_06,
        lv_fld_07 LIKE zgtppt1010-fld_07,
        lv_seg    TYPE zgteseglev2,
        lv_kondm  LIKE zgtsdt1041-kondm.

**
  CHECK: ps_head  IS NOT INITIAL,
         ps_kondm IS NOT INITIAL.

  CLEAR: lv_fld_02, lv_fld_06, lv_fld_07.
  lv_fld_02 = condense( ps_kondm-kondm ).

  CLEAR: lv_seg.
  DATA(lt_type) = gt_type[].
  lv_fld_07 = VALUE #( lt_type[ fld_02 = lv_fld_02 ]-fld_07
                       OPTIONAL ).
  lv_fld_06 = VALUE #( lt_type[ fld_02 = lv_fld_02 ]-fld_06
                       OPTIONAL ).
  IF lv_fld_07 IS NOT INITIAL.
    lv_seg = lv_fld_07.

*   Set Segment.
    data(lv_kunag) = CONV kunnr( |{ ps_head-kunag ALPHA = OUT }| ).
    DATA(ls_seg) = VALUE #( gt_seginfo[ kunag = lv_kunag
                                        vkorg = ps_head-vkorg
                                        vkgrp = ps_head-vkgrp
                                        zseglev2 = lv_seg ]
                            OPTIONAL ).

    IF ls_seg-zpjno IS NOT INITIAL.
      SELECT SINGLE zptxt  INTO @DATA(lv_zptxt)
        FROM zsd0106t  WHERE zpjno EQ @ls_seg-zpjno.
    ENDIF.

    CLEAR: lv_kondm.
    READ TABLE gt_type  INTO DATA(ls_type)
                        WITH KEY fld_07 = lv_fld_07
                        BINARY SEARCH.
    IF sy-subrc = 0.
      lv_kondm = ls_type-fld_02.
    ENDIF.

  ELSE.
    DATA(lv_del) = 'X'.
  ENDIF.


* Item Data Set
  ps_item = VALUE #( spmon     = ps_head-spmon
                     vkorg     = ps_head-vkorg
                     vkbur     = ps_head-vkbur
                     vkgrp     = ps_head-vkgrp
                     kunag     = ps_head-kunag
                     vrkme     = ps_head-vrkme
                     waerk     = ps_head-waerk
                     matnr     = ps_head-matnr
                     werks     = '6500'
                     zpjno     = ls_seg-zpjno
                     zptxt     = lv_zptxt
                     zseglev2  = ls_seg-zseglev2
                     zseglev2t = ls_seg-zseglev2t
                     kondm     = ps_kondm-kondm
                     kondmt    = ps_kondm-kondmt
                     kbetr     = ps_kondm-kbetr
                     nfprice   = gs_nfprice-nfprice
                     fld_06    = lv_fld_06 ).

* 이미 저장된 정산내역이 있는 경우 먼저 가져옴.
* 저장된 정산내역이 없는 경우 분배 실행.
  DATA(ls_s_item) = VALUE #( gt_save_item[ kunag    = ps_item-kunag
                                           matnr    = ps_item-matnr
                                           zseglev2 = ps_item-zseglev2
                                           kondm    = ps_item-kondm ]
                             OPTIONAL ).

  IF ls_s_item IS NOT INITIAL.
*    ps_item-fkimg = ls_s_item-fkimg.
    MOVE-CORRESPONDING: ls_s_item TO ps_item.
    ps_item-save  = icon_led_green.

    ps_item-noedit = 'X'.

    IF ps_kondm-kondm = lv_kondm.
      ps_item-noedit_kondm = 'X'.
    ELSE.
      IF ls_s_item-zseglev2 EQ 'S002' AND
         ls_s_item-kondm EQ '62'.
        ps_item-noedit_kondm = 'X'.
      ENDIF.
    ENDIF.

*   Add Billing Info
    IF ps_item-vbeln    IS NOT INITIAL AND
       ps_item-do_vbeln IS NOT INITIAL.

      CLEAR: gs_bl_info.
      gs_bl_info = VALUE #( gt_bl_info[ vbeln    = ps_item-vbeln
                                        posnr    = ps_item-posnr
                                        do_vbeln = ps_item-do_vbeln
                                        do_posnr = ps_item-do_posnr ]
                            OPTIONAL ).

      ps_item-bl_vbeln = gs_bl_info-bl_vbeln.
      ps_item-bl_posnr = gs_bl_info-bl_posnr.

    ENDIF.

  ELSE.

    IF ps_kondm-kondm = lv_kondm.

      ps_item-noedit       = 'X'.
      ps_item-noedit_kondm = 'X'.
      IF     lv_fld_07 = 'S002'.
        CASE ps_kondm-kondm.
          WHEN '60'.
            ps_item-fkimg = ps_head-oemn_grqty. "OEM 입고량
          WHEN '62'.
            ps_item-fkimg = ps_head-oeml_grqty. "OEM 로컬입고량
        ENDCASE.
*        ps_item-fkimg = ps_head-oemgr_qty.
      ELSEIF lv_fld_07 = 'S001'.
        ps_item-fkimg = ps_head-drs_qty.
      ENDIF.

    ELSE.
      CLEAR: ps_item-fkimg, ps_item-noedit.

      CASE ps_kondm-kondm.
        WHEN '60'.
          ps_item-noedit_kondm = 'X'.
          ps_item-fkimg = ps_head-oemn_grqty. "OEM 입고량
        WHEN '62'.
          ps_item-noedit_kondm = 'X'.
          ps_item-fkimg = ps_head-oeml_grqty. "OEM 로컬입고량
      ENDCASE.
    ENDIF.

    ps_item-save = icon_led_inactive.

  ENDIF.

  IF ps_item-save = icon_led_inactive.

    IF ps_item-kbetr > 0.
      ps_item-netpr = ( ps_item-kbetr / 100 ) + ps_item-nfprice .
    ELSE.
      ps_item-netpr = ps_item-nfprice .
    ENDIF.
    ps_item-netwr = ps_item-fkimg * ps_item-netpr .

    IF ps_item-kondm EQ '62' OR
       ps_item-kondm EQ '72'.
      CLEAR: ps_item-mwsbp.
    ELSE.
      ps_item-mwsbp = ps_item-netwr * '0.1' .
    ENDIF.

    IF ps_item-vrkme IS INITIAL.
      ps_item-vrkme = 'KG'.
    ENDIF.
    IF ps_item-waerk IS INITIAL.
      ps_item-waerk = 'KRW'.
    ENDIF.

  ENDIF.

* 가공비가 없을 경우 수정 금지.
  IF ps_item-kbetr = 0 OR
     ps_item-kbetr IS INITIAL.
    ps_item-noedit       = 'X'.

  ELSE.
    IF ps_item-zseglev2 = 'S002' AND
       ( ps_item-kondm    = '60' OR ps_item-kondm    = '62' ).
      ps_item-noedit       = 'X'.
    ENDIF.
  ENDIF.

  IF lv_del IS NOT INITIAL.
    ps_item-save    = icon_led_red.
*   삭제된 가공비 유형입니다.
    ps_item-message = TEXT-e28.
  ENDIF.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form set_alv_style_color
*&---------------------------------------------------------------------*
FORM set_alv_style_color  USING    pi_type.

**
  _clear: gt_color, gt_style.

  CASE pi_type.
    WHEN 'H'.    " Header
      "STYLE
      IF gs_head-noedit IS NOT INITIAL.
        PERFORM set_edit_style_field  USING: 'OEML_GRQTY'  'D'.
        PERFORM set_edit_style_field  USING: 'OEMN_GRQTY'  'D'.
      ELSE.
        IF gv_change_h IS NOT INITIAL.
          PERFORM set_edit_style_field  USING: 'OEML_GRQTY'  'D'.
          PERFORM set_edit_style_field  USING: 'OEMN_GRQTY'  'D'.
        ELSE.
          PERFORM set_edit_style_field  USING: 'OEML_GRQTY'  'E'.
          PERFORM set_edit_style_field  USING: 'OEMN_GRQTY'  'E'.
        ENDIF.
      ENDIF.
      IF gt_style[] IS NOT INITIAL.
        INSERT LINES OF gt_style INTO TABLE gs_head-style_tab.
      ENDIF.

      IF gs_head-cur_lfimg <> gs_head-lfimg.
        PERFORM set_field_color       USING: 'CUR_LFIMG'     '6'  '0'  '0',
                                             'LFIMG'         '6'  '0'  '0'.
        IF gt_color[] IS NOT INITIAL.
          INSERT LINES OF gt_color INTO TABLE gs_head-color_tab.
        ENDIF.
      ENDIF.

    WHEN 'I'.    " Item
*     Style: Edit.
      IF gs_item-noedit IS NOT INITIAL.
        PERFORM set_edit_style_field  USING: 'FKIMG'  'D'.

        IF gs_item-noedit_kondm IS NOT INITIAL.
          PERFORM set_field_color       USING: 'FKIMG'  '3'  '1'  '0'.
        ENDIF.

      ELSE.
        PERFORM set_edit_style_field  USING: 'FKIMG'  'E'.
      ENDIF.

*     Field Color
      PERFORM set_field_color       USING: 'NETWR'     '3'  '1'  '0',    " yellow
                                           'MWSBP'     '3'  '1'  '0',
                                           'VBELN'     '5'  '0'  '0',    " Green
                                           'POSNR'     '5'  '0'  '0',
                                           'DO_VBELN'  '5'  '0'  '0',
                                           'DO_POSNR'  '5'  '0'  '0',
                                           'MBLNR'     '5'  '0'  '0',
                                           'BL_VBELN'  '5'  '0'  '0',
                                           'BL_POSNR'  '5'  '0'  '0'.

      IF gs_item-save EQ icon_led_red.
*       삭제된 가공비 유형
        PERFORM set_field_color       USING: 'KONDMT'    '6'  '0'  '0'.    " Red
      ENDIF.

      IF gt_style[] IS NOT INITIAL.
        INSERT LINES OF gt_style INTO TABLE gs_item-style_tab.
      ENDIF.
      IF gt_color[] IS NOT INITIAL.
        INSERT LINES OF gt_color INTO TABLE gs_item-color_tab.
      ENDIF.

  ENDCASE.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form set_edit_style_field
*&---------------------------------------------------------------------*
FORM set_edit_style_field  USING    pi_fieldname
                                    pi_type.

  DATA: ls_style  TYPE lvc_s_styl.

**
  CLEAR: ls_style.
  ls_style-fieldname = pi_fieldname.

  IF     pi_type = 'E'.
    ls_style-style     = cl_gui_alv_grid=>mc_style_enabled.
  ELSEIF pi_type = 'D'.
    ls_style-style     = cl_gui_alv_grid=>mc_style_disabled.
  ENDIF.

  APPEND ls_style TO gt_style.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form set_field_color
*&---------------------------------------------------------------------*
FORM set_field_color  USING    pi_fieldname
                               pi_col
                               pi_int
                               pi_inv.

  DATA: ls_color  TYPE lvc_s_scol.

**
  CLEAR: ls_color.
  ls_color-fname     = pi_fieldname.
  ls_color-color-col = pi_col.
  ls_color-color-int = pi_int.
  ls_color-color-inv = pi_inv.

  APPEND ls_color TO gt_color.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form end_process
*&---------------------------------------------------------------------*
FORM end_process .

**
  CHECK: gv_error IS INITIAL.

  IF gt_head[] IS NOT INITIAL.
    CALL SCREEN 100.

  ELSE.
    gv_error = 'X'.
*   조회 가능한 Data가 존재하지 않습니다.
    MESSAGE s000 WITH TEXT-e07  DISPLAY LIKE 'E'.

  ENDIF.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form display_item_list
*&---------------------------------------------------------------------*
FORM display_item_list  USING    pi_ucomm.

**
  CHECK: gv_error IS INITIAL.

* Get selected row.
  PERFORM get_selected_row          USING pi_ucomm.

* Modify Item list.
  PERFORM make_item_display_list    USING gs_head.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form get_selected_row
*&---------------------------------------------------------------------*
FORM get_selected_row  USING    pi_ucomm.

  DATA: lv_lifnr  LIKE knvp-lifnr.

**
  DATA(lv_cnt) = REDUCE i( INIT x = 0  FOR ls_wa IN gt_head
                           WHERE ( chk = 'X' )
                           NEXT x = x + 1 ).

  IF     lv_cnt = 0.
    gv_error = 'X'.
*   처리할 데이타를 선택 하세요.
    MESSAGE s004 DISPLAY LIKE 'E'.

  ELSEIF lv_cnt > 1.

*    IF pi_ucomm NE 'DELETE'.    " 정산Data 삭제
    gv_error = 'X'.
*     유효한 라인을 하나만 선택하십시오.
    MESSAGE s002 DISPLAY LIKE 'E'.
*    ENDIF.

  ELSE.

    DATA(lv_save) = VALUE #( gt_head[ chk = 'X' ]-save  OPTIONAL ).
    DATA(lv_stat) = VALUE #( gt_head[ chk = 'X' ]-stat  OPTIONAL ).

    IF     pi_ucomm = 'CREATE'.    " 매출정산
      IF     lv_save EQ icon_led_inactive.
        gv_error = 'X'.
*       저장된 정산Data가 없습니다.
        MESSAGE s000 WITH TEXT-e17  DISPLAY LIKE 'E'.

      ELSEIF lv_stat EQ icon_led_green.
        gv_error = 'X'.
*       이미 매출정산이 완료되었습니다.
        MESSAGE s000 WITH TEXT-e18  DISPLAY LIKE 'E'.

      ENDIF.

    ELSEIF pi_ucomm = 'CANCEL'.    " 정산취소
      IF lv_stat EQ icon_led_inactive.
        gv_error = 'X'.
*       매출정산이 진행되지 않았습니다.
        MESSAGE s000 WITH TEXT-e19  DISPLAY LIKE 'E'.

      ENDIF.

    ELSEIF pi_ucomm = 'PRICE'.     " 단가정정
      IF     lv_save EQ icon_led_green.
        gv_error = 'X'.
*       이미 저장된 정산Data가 있습니다.
        MESSAGE s000 WITH TEXT-e20  DISPLAY LIKE 'E'.

      ENDIF.

    ENDIF.

  ENDIF.

  IF gv_error IS INITIAL.

    CLEAR: gs_head.
    gs_head = VALUE #( gt_head[ chk = 'X' ]  OPTIONAL ).

    IF pi_ucomm = 'CREATE' AND    " 매출정산
       gs_head-cur_lfimg <> gs_head-lfimg.
*     당월출고실적이 변경되었습니다. 정산데이터 삭제후 다시 생성하세요.
      MESSAGE s000 WITH TEXT-e40  DISPLAY LIKE 'E'.
      gv_error = 'X'.

    ELSEIF pi_ucomm = 'CREATE' AND    " 매출정산
            gs_head-reconsta IS INITIAL.  " 판매오더 생성

      CLEAR: lv_lifnr.
      PERFORM check_sales_vendor   USING    gs_head
                                   CHANGING lv_lifnr.
      IF lv_lifnr IS INITIAL.
*       영업사원 Vendor 정보를 찾을 수 없습니다. 거래처 마스터의 영업사원 정보를 확인해주세요.
        MESSAGE s000 WITH TEXT-e41  DISPLAY LIKE 'E'.
        gv_error = 'X'.
      ENDIF.

    ENDIF.

    PERFORM check_item_error_line    USING  pi_ucomm.

  ENDIF.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form check_item_error_line
*&---------------------------------------------------------------------*
FORM check_item_error_line  USING    pi_ucomm.

**
  CHECK: gv_error IS INITIAL,
         gs_head  IS NOT INITIAL,
         pi_ucomm EQ 'CREATE' OR    " 매출정산
         pi_ucomm EQ 'CANCEL'.      " 정산취소

  CLEAR: gs_item.
  IF gt_item[] IS NOT INITIAL.
    gs_item = VALUE #( gt_item[ kunag = gs_head-kunag
                                matnr = gs_head-matnr
                                save  = icon_led_red ]
                       OPTIONAL ).
  ELSE.
    gs_item = VALUE #( gt_item_tmp[ kunag = gs_head-kunag
                                    matnr = gs_head-matnr
                                    save  = icon_led_red ]
                       OPTIONAL ).

  ENDIF.

  IF gs_item IS NOT INITIAL.
    gv_error = 'X'.
*   삭제된 가공비 유형이 있어서 진행할 수 없습니다.
    MESSAGE s000 WITH TEXT-e29  DISPLAY LIKE 'E'.
  ELSE.

    IF     pi_ucomm = 'CREATE'.    " 매출정산
      DATA(lt_local) = gt_item[].
      DELETE: lt_local  WHERE fkimg EQ 0,
              lt_local  WHERE kondm NE '62'
                          AND kondm NE '72'.

      DATA(lv_local_kunnr) = VALUE #( lt_local[ 1 ]-kunag
                                      OPTIONAL ).

      IF lv_local_kunnr IS NOT INITIAL.

        lv_local_kunnr = condense( |{ lv_local_kunnr ALPHA = OUT }| ).
        lv_local_kunnr+0(1) = '2'.
        lv_local_kunnr = |{ lv_local_kunnr ALPHA = IN }|.

        SELECT SINGLE @abap_true
          FROM knb1  WHERE kunnr EQ @lv_local_kunnr
                       AND bukrs EQ '6000'
          INTO @DATA(lv_flg).

        IF lv_flg IS INITIAL.
          gv_error = 'X'.
*         Local 지급처가 생성되어 있지 않습니다. Local 지급처 생성 바랍니다.
          MESSAGE s000 WITH TEXT-e36  DISPLAY LIKE 'E'.
        ENDIF.

      ENDIF.


    ELSEIF pi_ucomm = 'CANCEL'.    " 정산취소

      DATA(lt_item) = gt_item[].
      DELETE lt_item  WHERE vbeln EQ space.

      CLEAR: lv_flg.
      IF lt_item[] IS NOT INITIAL.

        SELECT SINGLE @abap_true
          FROM @lt_item AS a  INNER JOIN vbrp AS b
                              ON  a~vbeln EQ b~aubel
                              AND a~posnr EQ b~aupos
                              INNER JOIN vbrk AS c
                              ON b~vbeln EQ c~vbeln
         WHERE c~vbtyp NE 'N' AND c~vbtyp NE 'S'
           AND c~sfakn EQ @abap_false
           AND c~fksto EQ @abap_false
          INTO @lv_flg.

        IF lv_flg IS NOT INITIAL.
          gv_error = 'X'.
*         Billing 문서가 생성되어 있습니다. Billing 취소 후 진행하시기 바랍니다.
          MESSAGE s000 WITH TEXT-e34  DISPLAY LIKE 'E'.
          EXIT.
        ENDIF.

      ENDIF.

    ENDIF.

  ENDIF.

**
  FREE: lt_local, lt_item.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form make_item_display_list
*&---------------------------------------------------------------------*
FORM make_item_display_list  USING    ps_head  LIKE gs_head.

**
  CHECK: gv_error IS INITIAL,
         ps_head  IS NOT INITIAL.

  _clear: gt_item.
  gt_item = VALUE #( BASE gt_item
                     FOR ls_item  IN gt_item_tmp
                     WHERE ( kunag = ps_head-kunag AND
                             matnr = ps_head-matnr )
                     ( CORRESPONDING #( ls_item ) )
                    ).

  IF gt_item[] IS NOT INITIAL.
    IF gv_change_h EQ space.
      gv_change_h = 'X'.
    ENDIF.
*    SORT: gt_item BY zseglev2 DESCENDING kondm ASCENDING.
    SORT: gt_item BY fld_06.

    IF gv_change_h EQ 'X'.

      IF ps_head IS NOT INITIAL.
        DATA(ls_head_temp) = ps_head.
      ENDIF.

      CLEAR: gs_head.
      LOOP AT gt_head INTO gs_head.

        DATA(lv_index) = sy-tabix.
        IF gs_head-reconsta    EQ space AND
           gs_head-prereconsta EQ space.
          CLEAR gs_head-noedit.
        ELSE.
          gs_head-noedit = 'X'.
        ENDIF.

        IF gv_disp IS NOT INITIAL.
          gs_head-noedit = 'X'.
        ENDIF.

        CLEAR:gs_head-style_tab[].
        PERFORM set_alv_style_color  USING    'H'.

        MODIFY gt_head FROM gs_head INDEX lv_index.

      ENDLOOP.

      PERFORM refresh_alv USING go_grid_h.

      IF ls_head_temp IS NOT INITIAL.
        ps_head = ls_head_temp.
      ENDIF.

    ENDIF.
  ENDIF.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form check_input_fkimg
*&---------------------------------------------------------------------*
FORM check_input_fkimg  USING    pi_zseglev2
                                 pi_kondm
                                 pi_fkimg
                                 ps_mod_cells TYPE lvc_s_modi
                        CHANGING pe_err.

  DATA: lv_fkimg_sum TYPE fkimg.

  DATA: lv_fld_07 LIKE zgtppt1010-fld_07,
        lv_kondm  LIKE zgtsdt1041-kondm.

**
  CHECK: pi_fkimg > 0.

  DATA(ls_head) = VALUE #( gt_head[ chk = 'X' ] OPTIONAL ).

  "ITEM 정산수량 SUM
  LOOP AT gt_item INTO DATA(ls_item) WHERE zseglev2 = pi_zseglev2.
    DATA(lv_index) = sy-tabix.
    CHECK ls_item-noedit_kondm NE 'X'.

    IF lv_index = ps_mod_cells-row_id.
      lv_fkimg_sum = lv_fkimg_sum + pi_fkimg .
    ELSE.
      lv_fkimg_sum = lv_fkimg_sum + ls_item-fkimg .
    ENDIF.

  ENDLOOP.

  CASE pi_zseglev2.
    WHEN 'S001'. "직납
      IF lv_fkimg_sum > ls_head-drs_qty.
        pe_err = 'X'.
      ENDIF.
    WHEN 'S002'. "OEM
      IF lv_fkimg_sum > ls_head-oemn_grqty.
        pe_err = 'X'.
      ENDIF.
  ENDCASE.



*  CLEAR: LV_KONDM, LV_FLD_07.
*  LV_FLD_07 = PI_ZSEGLEV2.
*
*  READ TABLE GT_TYPE  INTO DATA(LS_TYPE)
*                      WITH KEY FLD_07 = LV_FLD_07
*                      BINARY SEARCH.
*  IF SY-SUBRC = 0.
*    LV_KONDM = LS_TYPE-FLD_02.
*  ENDIF.
*
*  DATA(LV_BASE_FKIMG) = VALUE #( GT_ITEM[ ZSEGLEV2 = PI_ZSEGLEV2
*                                          KONDM    = LV_KONDM ]-FKIMG
*                                 OPTIONAL ).
*  IF LV_BASE_FKIMG > 0.
*
*    IF LV_BASE_FKIMG < PI_FKIMG.
*      PE_ERR = 'X'.
*    ENDIF.
*
*  ELSE.
*    PE_ERR = 'X'.
*  ENDIF.

**

  FREE:lv_index.
ENDFORM.

*&---------------------------------------------------------------------*
*& Form calculate_item_value
*&---------------------------------------------------------------------*
FORM calculate_item_value .

**
  CHECK: gv_change IS NOT INITIAL.

  DATA(ls_head) = VALUE #( gt_head[ chk = 'X' ]  OPTIONAL ).

  CLEAR: ls_head-adj_avg_netpr,
         ls_head-adj_avg_netwr,
         ls_head-adj_avg_mwsbp.

  PERFORM calculate_item_qty_amount  USING:   'S002'    " OEM
                                              ls_head-oemgr_qty
                                     CHANGING ls_head-adj_avg_netpr
                                              ls_head-adj_avg_netwr
                                              ls_head-adj_avg_mwsbp.

  PERFORM calculate_item_qty_amount  USING:   'S001'    " Direct
                                              ls_head-drs_qty
                                     CHANGING ls_head-adj_avg_netpr
                                              ls_head-adj_avg_netwr
                                              ls_head-adj_avg_mwsbp.

  IF ls_head-lfimg NE 0 AND ls_head-adj_avg_netwr NE 0.
    ls_head-adj_avg_netpr = ls_head-adj_avg_netwr / ls_head-lfimg.
  ENDIF.

  MODIFY gt_head  FROM VALUE #( adj_avg_netpr = ls_head-adj_avg_netpr
                                adj_avg_netwr = ls_head-adj_avg_netwr
                                adj_avg_mwsbp = ls_head-adj_avg_mwsbp
                                diff_netwr    = ls_head-netwr - ls_head-adj_avg_netwr
                                diff_mwsbp    = ls_head-mwsbp - ls_head-adj_avg_mwsbp
                               )
                  TRANSPORTING adj_avg_netpr adj_avg_netwr adj_avg_mwsbp
                               diff_netwr diff_mwsbp
                  WHERE chk = 'X'.

  IF gs_head IS NOT INITIAL.
    gs_head = VALUE #( BASE gs_head
                       adj_avg_netpr = ls_head-adj_avg_netpr
                       adj_avg_netwr = ls_head-adj_avg_netwr
                       adj_avg_mwsbp = ls_head-adj_avg_mwsbp
                       diff_netwr    = ls_head-netwr - ls_head-adj_avg_netwr
                       diff_mwsbp    = ls_head-mwsbp - ls_head-adj_avg_mwsbp ).
  ENDIF.

  CLEAR: gv_change.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form calculate_item_qty_amount
*&---------------------------------------------------------------------*
FORM calculate_item_qty_amount  USING    pi_seg
                                         pi_qty
                                CHANGING pe_avg_netpr
                                         pe_avg_netwr
                                         pe_avg_mwsbp.

  DATA: lv_fld_07 LIKE zgtppt1010-fld_07,
        lv_kondm  LIKE zgtsdt1041-kondm,
        lv_fkimg  TYPE fkimg,
        lv_sum    TYPE fkimg.
**
  CHECK: pi_seg IS NOT INITIAL.

  CLEAR: lv_fld_07, lv_kondm.
  lv_fld_07 = condense( pi_seg ).

  READ TABLE gt_type  INTO DATA(ls_type)
                      WITH KEY fld_07 = lv_fld_07
                      BINARY SEARCH.
  IF sy-subrc = 0.
    lv_kondm = ls_type-fld_02.
  ENDIF.

  CLEAR: lv_fkimg.
  lv_fkimg = pi_qty.

  CLEAR: lv_sum.
  LOOP AT gt_item  ASSIGNING FIELD-SYMBOL(<lfs_wa>)
                   WHERE zseglev2 EQ pi_seg
                     AND kondm    NE lv_kondm.

    lv_sum = lv_sum + <lfs_wa>-fkimg.

    <lfs_wa>-netwr = <lfs_wa>-fkimg * <lfs_wa>-netpr .

    IF <lfs_wa>-kondm EQ '62' OR
       <lfs_wa>-kondm EQ '72'.
      CLEAR: <lfs_wa>-mwsbp.
    ELSE.
      <lfs_wa>-mwsbp = <lfs_wa>-netwr * '0.1' .
    ENDIF.

    IF <lfs_wa>-fkimg > 0.

      pe_avg_netpr = pe_avg_netpr + <lfs_wa>-netpr.
      pe_avg_netwr = pe_avg_netwr + <lfs_wa>-netwr.
      IF <lfs_wa>-kondm NE '72'.
        pe_avg_mwsbp = pe_avg_mwsbp + <lfs_wa>-mwsbp.
      ENDIF.

    ENDIF.

  ENDLOOP.

  lv_fkimg = lv_fkimg - lv_sum.
  LOOP AT gt_item  ASSIGNING FIELD-SYMBOL(<lfs_item>)
                   WHERE zseglev2 EQ pi_seg
                     AND kondm    EQ lv_kondm.

    <lfs_item>-fkimg = lv_fkimg.
    <lfs_item>-netwr = <lfs_item>-fkimg * <lfs_item>-netpr .

    IF <lfs_item>-kondm NE '72'.
      <lfs_item>-mwsbp = <lfs_item>-netwr * '0.1' .
    ENDIF.

    IF <lfs_item>-fkimg > 0.

      pe_avg_netpr = pe_avg_netpr + <lfs_item>-netpr.
      pe_avg_netwr = pe_avg_netwr + <lfs_item>-netwr.
      IF <lfs_item>-kondm NE '72'.
        pe_avg_mwsbp = pe_avg_mwsbp + <lfs_item>-mwsbp.
      ENDIF.

    ENDIF.

  ENDLOOP.

  SORT gt_item BY zseglev2 kondm.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form handle_data_from_db
*&---------------------------------------------------------------------*
FORM handle_data_from_db  USING    pi_ucomm.

**
  CHECK: gv_error IS INITIAL.

  PERFORM check_before_save_or_cancel  USING  pi_ucomm.

  PERFORM handle_data_save             USING  pi_ucomm.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form handle_data_save
*&---------------------------------------------------------------------*
FORM handle_data_save  USING    pi_ucomm.

  DATA: lt_head_save TYPE TABLE OF zgtsdt1040,
        lt_item_save TYPE TABLE OF zgtsdt1041.

**
  CHECK: gv_error  IS INITIAL,
         gs_head   IS NOT INITIAL,
         gt_item[] IS NOT INITIAL.

* get already saved data.
  SELECT *  FROM zgtsdt1040
           WHERE spmon EQ @gs_head-spmon
             AND vkorg EQ @gs_head-vkorg
             AND vkbur EQ @gs_head-vkbur
             AND vkgrp EQ @gs_head-vkgrp
             AND kunag EQ @gs_head-kunag
             AND matnr EQ @gs_head-matnr
    INTO TABLE @DATA(lt_head).

  SELECT * FROM zgtsdt1041
           WHERE spmon EQ @gs_head-spmon
             AND vkorg EQ @gs_head-vkorg
             AND vkbur EQ @gs_head-vkbur
             AND vkgrp EQ @gs_head-vkgrp
             AND kunag EQ @gs_head-kunag
             AND matnr EQ @gs_head-matnr
    INTO TABLE @DATA(lt_item).


  DELETE: zgtsdt1040  FROM TABLE lt_head[],
          zgtsdt1041  FROM TABLE lt_item[].
*  IF pi_ucomm = 'CANCEL'.    " 정산Data 저장취소
  IF pi_ucomm = 'DELETE'.    " 정산Data 삭제

    IF sy-subrc EQ 0.
*     저장된 정산Data가 삭제되었습니다.
      MESSAGE s000 WITH TEXT-s01.
    ELSE.
      gv_error = 'X'.
*     정산Data 삭제에 실패하였습니다.
      MESSAGE s000 WITH TEXT-e10  DISPLAY LIKE 'E'.
    ENDIF.

  ENDIF.

  IF     pi_ucomm = 'SAVE'.      " 정산Data 저장

    _clear: lt_head_save, lt_item_save.
**  Make Header Data.
    DATA(ls_head) = VALUE #( lt_head[ 1 ]  OPTIONAL ).

    APPEND VALUE #( BASE CORRESPONDING #( gs_head )
                    prereconsta = 'C'
                    reconsta    = space
                    erdat       = COND #( WHEN ls_head-erdat IS NOT INITIAL
                                               THEN ls_head-erdat
                                          ELSE sy-datlo )
                    erzet       = COND #( WHEN ls_head-erzet IS NOT INITIAL
                                               THEN ls_head-erzet
                                          ELSE sy-timlo )
                    ernam       = COND #( WHEN ls_head-ernam IS NOT INITIAL
                                               THEN ls_head-ernam
                                          ELSE sy-uname )
                    aedat       = COND #( WHEN ls_head-erdat IS NOT INITIAL
                                               THEN sy-datlo
                                          ELSE space )
                    aezet       = COND #( WHEN ls_head-erzet IS NOT INITIAL
                                               THEN sy-timlo
                                          ELSE space )
                    aenam       = COND #( WHEN ls_head-ernam IS NOT INITIAL
                                               THEN sy-uname
                                          ELSE space )
                   ) TO lt_head_save.

**  Make Item Data.
    lt_item_save = VALUE #( BASE lt_item_save
                            FOR ls_item  IN gt_item
                            ( VALUE #( BASE CORRESPONDING #( ls_item )
                                       vbeln       = space
                                       posnr       = space
                                       bl_vbeln    = space
                                       bl_posnr    = space
                                       prereconsta = COND #( WHEN ls_item-fkimg > 0
                                                                  THEN 'C'
                                                             ELSE space )
                                       erdat       = COND #( WHEN ls_head-erdat IS NOT INITIAL
                                                                  THEN ls_head-erdat
                                                             ELSE sy-datlo )
                                       erzet       = COND #( WHEN ls_head-erzet IS NOT INITIAL
                                                                  THEN ls_head-erzet
                                                             ELSE sy-timlo )
                                       ernam       = COND #( WHEN ls_head-ernam IS NOT INITIAL
                                                                  THEN ls_head-ernam
                                                             ELSE sy-uname )
                                       aedat       = COND #( WHEN ls_head-erdat IS NOT INITIAL
                                                                  THEN sy-datlo
                                                             ELSE space )
                                       aezet       = COND #( WHEN ls_head-erzet IS NOT INITIAL
                                                                  THEN sy-timlo
                                                             ELSE space )
                                       aenam       = COND #( WHEN ls_head-ernam IS NOT INITIAL
                                                                  THEN sy-uname
                                                             ELSE space )
                                      )
                             )
                           ).

    IF lt_head_save[] IS NOT INITIAL AND
       lt_item_save[] IS NOT INITIAL.

      MODIFY: zgtsdt1040  FROM TABLE lt_head_save[],
              zgtsdt1041  FROM TABLE lt_item_save[].
      IF sy-subrc EQ 0.
*       정산Data가 저장되었습니다.
        MESSAGE s000 WITH TEXT-s02.
      ELSE.
        gv_error = 'X'.
*       정산Data 저장에 실패하였습니다.
        MESSAGE s000 WITH TEXT-e11  DISPLAY LIKE 'E'.
      ENDIF.

    ELSE.
      gv_error = 'X'.
*     저장할 정산Data가 없습니다.
      MESSAGE s000 WITH TEXT-e13  DISPLAY LIKE 'E'.

    ENDIF.

  ENDIF.

  IF gv_error IS INITIAL.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        wait = 'X'.
  ELSE.
    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

  ENDIF.

**
  FREE: lt_head,      lt_item,
        lt_head_save, lt_item_save.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form check_before_save_or_cancel
*&---------------------------------------------------------------------*
FORM check_before_save_or_cancel  USING    pi_ucomm.

**
  CHECK: pi_ucomm IS NOT INITIAL,
         gs_head  IS NOT INITIAL.

  IF     pi_ucomm = 'SAVE'.      " 정산Data 저장
    IF gs_head-stat NE icon_led_inactive.
      gv_error = 'X'.
*     이미 매출정산 진행된 Data는 저장할 수 없습니다.
      MESSAGE s000 WITH TEXT-e14  DISPLAY LIKE 'E'.
    ELSE.
      IF gt_item[] IS INITIAL.
        gv_error = 'X'.
*       저장할 정산Data가 없습니다.
        MESSAGE s000 WITH TEXT-e13  DISPLAY LIKE 'E'.
      ELSE.

        DATA(lt_item) = gt_item[].
        DELETE lt_item WHERE zpjno IS NOT INITIAL.
        IF lt_item[] IS NOT INITIAL.
          gv_error = 'X'.
*         유효한 프로젝트가 존재하지 않습니다.
          MESSAGE s000 WITH TEXT-e42  DISPLAY LIKE 'E'.
        ELSE.

          DATA(ls_item) = VALUE #( gt_item[ kunag = gs_head-kunag
                                      matnr = gs_head-matnr
                                      save  = icon_led_red ]
                                   OPTIONAL ).
          IF ls_item IS NOT INITIAL.
            gv_error = 'X'.
*           삭제된 가공비 유형이 있어서 단가정정을 다시해야 합니다.
            MESSAGE s000 WITH TEXT-e30  DISPLAY LIKE 'E'.
          ENDIF.

        ENDIF.

      ENDIF.
    ENDIF.

*  ELSEIF pi_ucomm = 'CANCEL'.      " 정산Data 저장취소
  ELSEIF pi_ucomm = 'DELETE'.      " 정산Data 삭제
    IF     gs_head-save NE icon_led_green.
      gv_error = 'X'.
*     삭제할 정산Data가 없습니다.
      MESSAGE s000 WITH TEXT-e16  DISPLAY LIKE 'E'.

    ELSEIF gs_head-stat NE icon_led_inactive.
      gv_error = 'X'.
*     이미 매출정산 진행된 Data는 삭제할 수 없습니다.
      MESSAGE s000 WITH TEXT-e12  DISPLAY LIKE 'E'.

    ENDIF.

  ELSEIF pi_ucomm = 'CHANGE'.      " 정산 저장Data 변경
    IF gs_head-stat EQ icon_led_green.
      gv_error = 'X'.
*     이미 매출정산 진행된 Data는 변경할 수 없습니다.
      MESSAGE s000 WITH TEXT-e15  DISPLAY LIKE 'E'.
    ENDIF.

  ENDIF.

**
  FREE: lt_item.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form item_edit_field_change
*&---------------------------------------------------------------------*
FORM item_edit_field_change  USING    pi_ucomm.

**
  CHECK: gv_error IS INITIAL,
         pi_ucomm = 'CHANGE'.

  LOOP AT gt_item  INTO gs_item
                   WHERE noedit = 'X'
                     AND noedit_kondm IS INITIAL.

    DATA(lv_index) = sy-tabix.

    CLEAR: gs_item-noedit .
    _clear: gs_item-style_tab,
            gs_item-color_tab.

*   Set ALV Field Style / Color
    PERFORM set_alv_style_color  USING    'I'.

    MODIFY gt_item FROM gs_item  INDEX lv_index.

  ENDLOOP.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form handle_db_data_delete
*&---------------------------------------------------------------------*
FORM handle_db_data_delete  USING    pi_ucomm.

**
  CHECK: gv_error IS INITIAL.

* Get selected row.
  PERFORM get_selected_row             USING  pi_ucomm.

  PERFORM check_before_save_or_cancel  USING  pi_ucomm.

  PERFORM confirm_before_crt_or_canc   USING  pi_ucomm.

  PERFORM handle_data_save             USING  pi_ucomm.

* Refresh.
  PERFORM get_data.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form submit_price_manage
*&---------------------------------------------------------------------*
FORM submit_price_manage  USING    pi_ucomm.

  DATA: lv_crt(1),
        lv_dis(1).

**
  CHECK: gv_error IS INITIAL.

  CLEAR: lv_crt, lv_dis.
  IF gv_disp IS NOT INITIAL.    " 조회
    lv_dis = 'X'.
    CLEAR: lv_crt.
  ELSE.
    lv_crt = 'X'.
    CLEAR: lv_dis.
  ENDIF.

  SUBMIT zgtsdr1030 AND RETURN
                    WITH s_vkorg  IN s_vkorg
                    WITH s_vtweg  IN s_vtweg
                    WITH s_spart  IN s_spart
                    WITH s_vkbur  IN s_vkbur
                    WITH s_spmon  IN s_spmon
                    WITH s_kunnr  IN s_kunag
                    WITH rb_crt   EQ lv_crt
                    WITH rb_dis   EQ lv_dis.

* Refresh.
  PERFORM get_data.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form start_document_process
*&---------------------------------------------------------------------*
FORM start_document_process  USING    pi_ucomm.

**
  CHECK: gv_error IS INITIAL.

* Get selected row.
  PERFORM get_selected_row             USING pi_ucomm.

  PERFORM confirm_before_crt_or_canc   USING pi_ucomm.

  PERFORM create_document_exc          USING pi_ucomm.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form confirm_before_crt_or_canc
*&---------------------------------------------------------------------*
FORM confirm_before_crt_or_canc  USING    pi_ucomm.

  DATA: lv_title    LIKE bapiret2-message,
        lv_msg      LIKE bapiret2-message,
        lv_month(7).

**
  CHECK: gv_error IS INITIAL.

  CLEAR: lv_title, lv_msg, lv_month.
  lv_month = gv_spmon+0(4) && '.' && gv_spmon+4(2).
  lv_msg = |{ gs_head-customername }| && | { '의' } | && lv_month.

  IF     pi_ucomm = 'CREATE'.    " 매출정산
    lv_title = TEXT-004.
*   '판매처'의 '매출정산 월' 매출 정산을 하시겠습니까?
    lv_msg   = lv_msg && | { TEXT-006 }|.

  ELSEIF pi_ucomm = 'CANCEL'.    " 정산취소
    lv_title = TEXT-005.
*   '판매처'의 '매출정산 월' 매출 정산을 취소 하시겠습니까?
    lv_msg   = lv_msg && | { TEXT-007 }|.

  ELSEIF pi_ucomm = 'DELETE'.    " 정산Data 삭제
*   '판매처'의 '매출정산 월' 매출 정산data를 삭제 하시겠습니까?
    lv_msg   = lv_msg && | { TEXT-013 }|.

  ENDIF.

  CLEAR: gv_answer.
  PERFORM popup_to_confirm    USING    'CONFIRM'
                                       lv_title
                                       lv_msg
                              CHANGING gv_answer.
  IF gv_answer NE 'J'.
    gv_error = 'X'.
*   작업이 취소되었습니다.
    MESSAGE s050 DISPLAY LIKE 'E'.
  ENDIF.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form create_document_exc
*&---------------------------------------------------------------------*
FORM create_document_exc  USING    pi_ucomm.

**
  CHECK: gv_error IS INITIAL.

* 정산Data 가 없는 경우, 구성함.
  IF gt_item[] IS INITIAL.
*   Modify Item list.
    PERFORM make_item_display_list        USING gs_head.

  ENDIF.

  CASE gs_head-reconsta.
    WHEN space.  " 판매오더 생성
      PERFORM create_sales_order          USING  pi_ucomm.

      PERFORM create_delivery_order       USING  pi_ucomm.

      PERFORM batch_split_to_delivery     USING  pi_ucomm.

      PERFORM create_good_issue_doc       USING  pi_ucomm.

      PERFORM set_so_billing_block        USING  pi_ucomm.

    WHEN 'A'.    " 판매오더 생성됨 -> 납품오더 생성
      PERFORM create_delivery_order       USING  pi_ucomm.

      PERFORM batch_split_to_delivery     USING  pi_ucomm.

      PERFORM create_good_issue_doc       USING  pi_ucomm.

      PERFORM set_so_billing_block        USING  pi_ucomm.

    WHEN 'B'.    " 납품오더 생성됨 -> 배치 지정
      PERFORM batch_split_to_delivery     USING  pi_ucomm.

      PERFORM create_good_issue_doc       USING  pi_ucomm.

      PERFORM set_so_billing_block        USING  pi_ucomm.

    WHEN 'C'.    " 배치 지정됨 -> Good Issue
      PERFORM create_good_issue_doc       USING  pi_ucomm.

      PERFORM set_so_billing_block        USING  pi_ucomm.

    WHEN 'D'.    " Good Issue 처리됨 -> 기존 S/O Billing Block
      PERFORM set_so_billing_block        USING  pi_ucomm.

  ENDCASE.

  PERFORM update_item_temp_data       USING  pi_ucomm.

  PERFORM update_document_result      USING  pi_ucomm.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form create_sales_order
*&---------------------------------------------------------------------*
FORM create_sales_order  USING    pi_ucomm.

**
  CHECK: gv_error         IS INITIAL,
         gs_head-reconsta IS INITIAL.

* 1) Create Sales Order
  PERFORM sales_order_creation        USING: 'S002' 'D',  " OEM. 내수
                                             'S002' 'L',  " OEM. 로컬
                                             'S001' 'D',  " 직판 내수
                                             'S001' 'L'.  " 직판 로컬
* 2) Result modify to display list.
  PERFORM set_document_create_result.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form sales_order_creation
*&---------------------------------------------------------------------*
FORM sales_order_creation  USING    pi_seg  pi_type.

  DATA: lv_seg   LIKE zgtsdt1041-zseglev2,
        lv_vbeln TYPE vbeln_va.

**
  CHECK: gv_error  IS INITIAL,
         gs_head   IS NOT INITIAL,
         gt_item[] IS NOT INITIAL.

  CLEAR: gs_so_head, gs_so_headx.
  _clear: gt_so_item,  gt_so_itemx,  gt_so_partn,
          gt_so_schdl, gt_so_schdlx,
          gt_so_cond,  gt_so_condx,  gt_so_exten,
          gt_return.

**
  CLEAR: lv_seg.
  lv_seg = pi_seg.

  DATA(lt_item) = gt_item[].
  DELETE: lt_item  WHERE zseglev2 NE lv_seg,
          lt_item  WHERE fkimg = 0.

  IF     pi_seg = 'S002'.  " OEM.
    IF     pi_type = 'D'.    " 내수
      DELETE: lt_item WHERE kondm EQ '62'.

    ELSEIF pi_type = 'L'.    " 로컬
      DELETE: lt_item WHERE kondm NE '62'.

    ENDIF.

  ELSEIF pi_seg = 'S001'.  " 직판
    IF     pi_type = 'D'.    " 내수
      DELETE: lt_item WHERE kondm EQ '72'.

    ELSEIF pi_type = 'L'.    " 로컬
      DELETE: lt_item WHERE kondm NE '72'.

    ENDIF.

  ENDIF.
  SORT: lt_item BY kondm.

* Make Header Data
  PERFORM make_bapi_sales_order_header    USING:   pi_seg
                                                   pi_type
                                                   gs_head
                                          CHANGING gs_so_head
                                                   gs_so_headx.
* Make Item / Schedule Line / Condition Data
  PERFORM make_bapi_sales_order_item      TABLES   lt_item
                                                   gt_so_item
                                                   gt_so_itemx
                                                   gt_so_schdl
                                                   gt_so_schdlx
                                                   gt_so_cond
                                                   gt_so_condx
                                          USING    pi_seg
                                                   pi_type
                                                   gs_head.
* Make Extension
  PERFORM make_bapi_sales_order_exten     TABLES   gt_so_exten
                                          USING    pi_seg.
* Make Partner function.
  PERFORM make_bapi_sales_order_partn     TABLES   gt_so_partn
                                          USING    pi_seg
                                                   pi_type
                                                   gs_head.

* BAPI_SALESORDER_CREATEFROMDAT2
  PERFORM call_sales_order_bapi           TABLES   gt_return
                                          CHANGING lv_vbeln.

  PERFORM modify_so_result                TABLES   lt_item
                                                   gt_return
                                          USING    lv_vbeln.

**
  FREE: lt_item.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form make_bapi_sales_order_header
*&---------------------------------------------------------------------*
FORM make_bapi_sales_order_header  USING    pi_seg
                                            pi_type
                                            ps_head     LIKE gs_head
                                   CHANGING ps_so_head  LIKE bapisdhd1
                                            ps_so_headx LIKE bapisdhd1x.

  DATA: lv_auart TYPE auart,
        lv_bstkd TYPE bstkd.

**
  CLEAR: lv_auart, lv_bstkd.
  IF     pi_seg = 'S002'.    " OEM.

    IF     pi_type = 'D'.    " 내수
      lv_auart  = 'ZOEM'.
*     소재 OEM - 내수 매출정산
      lv_bstkd  = |{ TEXT-009 }| && | { TEXT-008 }|.

    ELSEIF pi_type = 'L'.    " 로컬
      lv_auart  = 'ZOEL'.
*     소재 OEM - 로컬 매출정산
      lv_bstkd  = |{ TEXT-012 }| && | { TEXT-008 }|.

    ENDIF.

  ELSEIF pi_seg = 'S001'.    " 직판.
    IF     pi_type = 'D'.    " 내수
      lv_auart = 'ZDSD'.
*     소재 직판-내수 매출정산
      lv_bstkd  = |{ TEXT-010 }| && | { TEXT-008 }|.

    ELSEIF pi_type = 'L'.    " 로컬
      lv_auart = 'ZDSL'.
*     소재 직판-로컬 매출정산
      lv_bstkd  = |{ TEXT-011 }| && | { TEXT-008 }|.

    ENDIF.

  ENDIF.

  lv_bstkd = |{ gv_spmon+0(4) }| && |{ gv_spmon+4(2) } | && lv_bstkd.

  PERFORM convert_auart   USING: 'I'  lv_auart.

  ps_so_head = VALUE #( sales_org  = ps_head-vkorg
                        distr_chan = ps_head-vtweg
                        division   = ps_head-spart
                        sales_off  = ps_head-vkbur
                        sales_grp  = ps_head-vkgrp
                        doc_type   = lv_auart
                        purch_no_c = lv_bstkd
                        currency   = 'KRW' ).

  ps_so_headx = VALUE #( updateflag = 'I'
                         sales_org  = 'X'
                         distr_chan = 'X'
                         division   = 'X'
                         sales_off  = 'X'
                         sales_grp  = 'X'
                         doc_type   = 'X'
                         purch_no_c = 'X'
                         currency   = 'X' ).

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form make_bapi_sales_order_item
*&---------------------------------------------------------------------*
FORM make_bapi_sales_order_item  TABLES   pt_item      STRUCTURE gs_item
                                          pt_so_item   STRUCTURE bapisditm
                                          pt_so_itemx  STRUCTURE bapisditmx
                                          pt_so_schdl  STRUCTURE bapischdl
                                          pt_so_schdlx STRUCTURE bapischdlx
                                          pt_so_cond   STRUCTURE bapicond
                                          pt_so_condx  STRUCTURE bapicondx
                                 USING    pi_seg
                                          pi_type
                                          ps_head     LIKE gs_head.

  DATA: lv_posnr TYPE posnr_va,
        lv_vrkme TYPE vrkme,
        lv_netpr LIKE bapicurr-bapicurr.

**
  CHECK: pt_item[] IS NOT INITIAL.

  CLEAR: lv_posnr.
  LOOP AT pt_item  ASSIGNING FIELD-SYMBOL(<lfs_item>).

    lv_posnr = lv_posnr + 10.
    <lfs_item>-posnr = lv_posnr.

    CLEAR: lv_vrkme.
    lv_vrkme = <lfs_item>-vrkme.

    PERFORM conversion_cunit  USING  'I' lv_vrkme.

*   Item Data
    APPEND VALUE #( itm_number = lv_posnr
                    material   = ps_head-matnr
                    plant      = '6500'
                    target_qty = <lfs_item>-fkimg
                    target_qu  = lv_vrkme
                    mat_pr_grp = <lfs_item>-kondm
                   ) TO pt_so_item.

    APPEND VALUE #( itm_number = lv_posnr
*                    updateflag = 'I'
                    material   = 'X'
                    plant      = 'X'
                    target_qty = 'X'
                    target_qu  = 'X'
                    mat_pr_grp = 'X'
                   ) TO pt_so_itemx.

*   Schedule Line.
    APPEND VALUE #( itm_number = lv_posnr
                    sched_line = '1'
                    req_date   = sy-datlo
                    req_qty    = <lfs_item>-fkimg
                   ) TO pt_so_schdl.

    APPEND VALUE #( itm_number = lv_posnr
                    sched_line = '1'
*                    updateflag = 'I'
                    req_date   = 'X'
                    req_qty    = 'X'
                   ) TO pt_so_schdlx.

    CLEAR: lv_netpr.
    PERFORM currency_convert_for_bapi    USING    <lfs_item>-netpr
                                                  <lfs_item>-waerk
                                         CHANGING lv_netpr.
*   Condition
    APPEND VALUE #( itm_number = lv_posnr
                    cond_type  = 'ZPR0'
                    cond_value = lv_netpr  " <lfs_item>-netpr
                    currency   = <lfs_item>-waerk
                   ) TO pt_so_cond.

    APPEND VALUE #( itm_number = lv_posnr
                    cond_type  = 'ZPR0'
*                    updateflag = 'I'
                    cond_value = 'X'
                    currency   = 'X'
                   ) TO pt_so_condx.

  ENDLOOP.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form make_bapi_sales_order_exten
*&---------------------------------------------------------------------*
FORM make_bapi_sales_order_exten  TABLES   pt_so_exten STRUCTURE bapiparex
                                  USING    pi_seg.

  DATA: ls_bape_vbak  TYPE bape_vbak,
        ls_bape_vbakx TYPE bape_vbakx,

        lv_seg        TYPE zgteseglev2.

**
*  CHECK: pt_item[] IS NOT INITIAL.

  CLEAR: lv_seg.
  lv_seg = pi_seg.

  DATA(lv_zpjno) = VALUE #( gt_item[ zseglev2 = lv_seg ]-zpjno
                            OPTIONAL ).

  CLEAR: ls_bape_vbak, ls_bape_vbakx.
  ls_bape_vbak-zpjno  = lv_zpjno.
  ls_bape_vbakx-zpjno = 'X'.

  APPEND VALUE #( structure  = 'BAPE_VBAK'
                  valuepart1 = ls_bape_vbak
                 ) TO pt_so_exten.

  APPEND VALUE #( structure  = 'BAPE_VBAKX'
                  valuepart1 = ls_bape_vbakx
                 ) TO pt_so_exten.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form make_bapi_sales_order_partn
*&---------------------------------------------------------------------*
FORM make_bapi_sales_order_partn  TABLES   pt_so_partn STRUCTURE bapiparnr
                                  USING    pi_seg
                                           pi_type
                                           ps_head     LIKE gs_head.

  DATA: lv_parvw TYPE parvw,
        lv_kunnr TYPE kunnr,
        lv_lifnr TYPE lifnr.

**

* 판매처
  CLEAR: lv_parvw.
  PERFORM convert_parvw   USING:   'I'  'AG'
                          CHANGING lv_parvw.
  APPEND VALUE #( partn_role = lv_parvw
                  partn_numb = ps_head-kunag
                 ) TO pt_so_partn.

* 배송처
  CLEAR: lv_parvw.
  PERFORM convert_parvw   USING:   'I'  'WE'
                          CHANGING lv_parvw.
  APPEND VALUE #( partn_role = lv_parvw
                  partn_numb = ps_head-kunag
                 ) TO pt_so_partn.

* 지급처
  CLEAR: lv_parvw.
  PERFORM convert_parvw   USING:   'I'  'RG'
                          CHANGING lv_parvw.

  CLEAR: lv_kunnr.
  IF pi_type = 'L'.    " 로컬
    lv_kunnr = condense( |{ ps_head-kunag ALPHA = OUT }| ).
    lv_kunnr+0(1) = '2'.
    lv_kunnr = |{ lv_kunnr ALPHA = IN }|.
  ELSE.
    lv_kunnr = ps_head-kunag.
  ENDIF.

  APPEND VALUE #( partn_role = lv_parvw
                  partn_numb = lv_kunnr
                 ) TO pt_so_partn.

* 청구처
  CLEAR: lv_parvw.
  PERFORM convert_parvw   USING:   'I'  'RE'
                          CHANGING lv_parvw.
  APPEND VALUE #( partn_role = lv_parvw
                  partn_numb = ps_head-kunag
                 ) TO pt_so_partn.

* 영업사원
  CLEAR: lv_lifnr.
  PERFORM check_sales_vendor   USING    gs_head
                               CHANGING lv_lifnr.

*  SELECT SINGLE lifnr
*    FROM knvp  WHERE vkorg EQ @gv_vkorg
*                 AND vtweg EQ @gv_vtweg
*                 AND spart EQ @gv_spart
*                 AND parvw EQ 'VE'
*                 AND kunnr EQ @ps_head-kunag
*    INTO @DATA(lv_lifnr).

  IF lv_lifnr IS NOT INITIAL.
    CLEAR: lv_parvw.
    PERFORM convert_parvw   USING:   'I'  'VE'
                            CHANGING lv_parvw.
    APPEND VALUE #( partn_role = lv_parvw
                    partn_numb = lv_lifnr
                   ) TO pt_so_partn.
  ENDIF.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form convert_parvw
*&---------------------------------------------------------------------*
FORM convert_parvw  USING    pi_type
                             pi_parvw
                    CHANGING pe_parvw.

  DATA: lv_parvw  TYPE parvw.

**
  CHECK: pi_parvw IS NOT INITIAL.

  CLEAR: lv_parvw.
  lv_parvw = pi_parvw.

  IF     pi_type = 'I'.
    CALL FUNCTION 'CONVERSION_EXIT_PARVW_INPUT'
      EXPORTING
        input  = lv_parvw
      IMPORTING
        output = pe_parvw.

  ELSEIF pi_type = 'O'.
    CALL FUNCTION 'CONVERSION_EXIT_PARVW_OUTPUT'
      EXPORTING
        input  = lv_parvw
      IMPORTING
        output = pe_parvw.

  ENDIF.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form call_sales_order_bapi
*&---------------------------------------------------------------------*
FORM call_sales_order_bapi  TABLES   pt_return STRUCTURE bapiret2
                            CHANGING pe_vbeln.

**
  CHECK: gs_so_head   IS NOT INITIAL,
         gt_so_item[] IS NOT INITIAL.

  CLEAR: pe_vbeln.
  _clear: pt_return.
  CALL FUNCTION 'BAPI_SALESORDER_CREATEFROMDAT2'
    EXPORTING
      order_header_in      = gs_so_head
      order_header_inx     = gs_so_headx
    IMPORTING
      salesdocument        = pe_vbeln
    TABLES
      return               = pt_return
      order_items_in       = gt_so_item
      order_items_inx      = gt_so_itemx
      order_partners       = gt_so_partn
      order_schedules_in   = gt_so_schdl
      order_schedules_inx  = gt_so_schdlx
      order_conditions_in  = gt_so_cond
      order_conditions_inx = gt_so_condx
      extensionin          = gt_so_exten.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form modify_so_result
*&---------------------------------------------------------------------*
FORM modify_so_result  TABLES   pt_item   STRUCTURE gs_item
                                pt_return STRUCTURE bapiret2
                       USING    pi_vbeln.

**
  CHECK: pt_item[] IS NOT INITIAL.

  DATA(ls_return) = VALUE #( pt_return[ type = 'E' ]  OPTIONAL ).

  IF ls_return IS INITIAL.
    IF pi_vbeln IS INITIAL.
      gv_error = 'X'.
      ls_return-type = 'E'.
*     판매오더 생성시 오류가 발견되었습니다.
      ls_return-message = TEXT-e18.
    ELSE.
      ls_return-type = 'S'.
      CLEAR: ls_return-message.
**     판매오더가 생성되었습니다.
*      ls_return-message = TEXT-s02.
    ENDIF.
  ELSE.
    gv_error = 'X'.
  ENDIF.

  LOOP AT pt_item  INTO DATA(ls_item).

    MODIFY gt_item  FROM VALUE #( vbeln   = pi_vbeln
                                  posnr   = ls_item-posnr
                                  message = ls_return-message )
                    TRANSPORTING vbeln posnr message
                    WHERE zseglev2 = ls_item-zseglev2
                      AND kondm    = ls_item-kondm.
  ENDLOOP.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form set_document_create_result.
*&---------------------------------------------------------------------*
FORM set_document_create_result.

  DATA: lv_stat(4),       " 정산 상태
        lv_msg         LIKE bapiret2-message,
        lv_reconsta    TYPE zgtereconsta,
        lv_error_va(1),
        lv_error_vl(1),
        lv_error_cg(1),
        lv_error_gi(1),
        lv_error_vf(1).

**
  CLEAR: lv_reconsta, lv_msg, lv_stat,
         lv_error_va, lv_error_vl, lv_error_cg, lv_error_gi, lv_error_vf.
  IF gv_error IS INITIAL.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        wait = 'X'.

    CASE gs_head-reconsta.
      WHEN space.  " 판매오더 생성
        lv_stat     = icon_led_yellow.
        lv_reconsta = 'A'.
*       판매오더가 생성되었습니다.
        lv_msg = TEXT-s03.

        PERFORM create_so_status_object .

      WHEN 'A'.    " 판매오더 생성됨 -> 납품오더 생성
        lv_stat     = icon_led_yellow.
        lv_reconsta = 'B'.
*       납품오더가 생성되었습니다.
        lv_msg = TEXT-s04.

      WHEN 'B'.    " 납품오더 생성됨 -> 배치 지정
        lv_stat     = icon_led_yellow.
        lv_reconsta = 'C'.
*       납품오더 배치 지정 되었습니다.
        lv_msg = TEXT-s05.

      WHEN 'C'.    " 배치 지정됨 -> Good Issue
        lv_stat     = icon_led_yellow.
        lv_reconsta = 'D'.
*       출고처리 되었습니다.
        lv_msg = TEXT-s06.

      WHEN 'D'.    " Good Issue 처리됨 -> Billing 생성
        lv_stat     = icon_led_green.
        lv_reconsta = 'E'.    " Billing 생성됨
*       매출정산이 완료되었습니다.
        lv_msg = TEXT-s10.

    ENDCASE.

  ELSE.
    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

    lv_reconsta = gs_head-reconsta.
    CASE gs_head-reconsta.
      WHEN space.  " 판매오더 생성
        lv_stat     = icon_led_red.
        lv_error_va = 'X'.
*       판매오더 생성시 오류가 발견되었습니다.
        lv_msg = TEXT-e21.

      WHEN 'A'.    " 판매오더 생성됨 -> 납품오더 생성
        lv_stat     = icon_led_red.
        lv_error_vl = 'X'.
*       납품오더 생성시 오류가 발견되었습니다.
        lv_msg = TEXT-e22.

      WHEN 'B'.    " 납품오더 생성됨 -> 배치 지정
        lv_stat     = icon_led_red.
        lv_error_cg = 'X'.
*       납품오더 배치 지정 중 오류가 발생하였습니다.
        lv_msg = TEXT-e23.

      WHEN 'C'.    " 배치 지정됨 -> Good Issue
        lv_stat     = icon_led_red.
        lv_error_gi = 'X'.
*       출고처리 중 오류가 발생하였습니다.
        lv_msg = TEXT-e24.

      WHEN 'D'.    " Good Issue 처리됨 -> Billing 생성
        lv_stat     = icon_led_red.
        lv_error_vf = 'X'.
*       Billing block 시 오류가 발생하였습니다.
        lv_msg = TEXT-e38.

    ENDCASE.

  ENDIF.

* 판매오더 이후 작업에서 Error일 경우 Red icon? Yellow icon?
*  IF lv_stat     = icon_led_red.
*    IF gs_head-reconsta IS NOT INITIAL.
*      lv_stat = icon_led_yellow.
*    ENDIF.
*  ENDIF.

* Header Update.
  MODIFY gt_head  FROM VALUE #( reconsta = lv_reconsta
                                stat     = lv_stat
                                message  = lv_msg )
                  TRANSPORTING reconsta stat message
                  WHERE chk = 'X'.

  gs_head-reconsta = lv_reconsta.
  gs_head-stat     = lv_stat.
  gs_head-message  = lv_msg.

* Item Update : document clear.
  IF lv_error_va IS NOT INITIAL OR
     lv_error_vl IS NOT INITIAL OR
     lv_error_cg IS NOT INITIAL OR
     lv_error_gi IS NOT INITIAL OR
     lv_error_vf IS NOT INITIAL .

    LOOP AT gt_item  INTO gs_item  WHERE fkimg > 0.

      DATA(lv_index) = sy-tabix.

      gs_item = VALUE #( BASE gs_item
                         vbeln    = COND #( WHEN lv_error_va IS NOT INITIAL
                                                 THEN space
                                            ELSE gs_item-vbeln )
                         posnr    = COND #( WHEN lv_error_va IS NOT INITIAL
                                                 THEN space
                                            ELSE gs_item-posnr )
*                      납품오더 생성
                         do_vbeln = COND #( WHEN lv_error_vl IS NOT INITIAL
                                                 THEN space
                                            ELSE gs_item-do_vbeln )
                         do_posnr = COND #( WHEN lv_error_vl IS NOT INITIAL
                                                 THEN space
                                            ELSE gs_item-do_posnr )
                         mblnr    = COND #( WHEN lv_error_gi IS NOT INITIAL
                                                 THEN space
                                            ELSE gs_item-mblnr )
*                      Billing 생성
*                         bl_vbeln = COND #( WHEN lv_error_vf IS NOT INITIAL
*                                                 THEN space
*                                            ELSE gs_item-bl_vbeln )
*                         bl_posnr = COND #( WHEN lv_error_vf IS NOT INITIAL
*                                                 THEN space
*                                            ELSE gs_item-bl_posnr )
                        ).

      MODIFY gt_item FROM gs_item   INDEX lv_index
                     TRANSPORTING vbeln posnr do_vbeln do_posnr
                                  mblnr bl_vbeln bl_posnr.

    ENDLOOP.

  ENDIF.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form conversion_cunit
*&---------------------------------------------------------------------*
FORM conversion_cunit  USING    pi_type
                                pi_vrkme.

**
  CHECK: pi_vrkme IS NOT INITIAL.

  IF     pi_type = 'I'.
    CALL FUNCTION 'CONVERSION_EXIT_CUNIT_INPUT'
      EXPORTING
        input          = pi_vrkme
        language       = sy-langu
      IMPORTING
        output         = pi_vrkme
      EXCEPTIONS
        unit_not_found = 1
        OTHERS         = 2.

  ELSEIF pi_type = 'O'.
    CALL FUNCTION 'CONVERSION_EXIT_CUNIT_OUTPUT'
      EXPORTING
        input          = pi_vrkme
        language       = sy-langu
      IMPORTING
        output         = pi_vrkme
      EXCEPTIONS
        unit_not_found = 1
        OTHERS         = 2.

  ENDIF.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form create_delivery_order
*&---------------------------------------------------------------------*
FORM create_delivery_order  USING    pi_ucomm.

**
  CHECK: gv_error         IS INITIAL,
         gs_head-reconsta EQ 'A'.    " 판매오더 생성됨.

* 1) Create Delivery Order
  PERFORM delivery_order_creation .

* 2) Result modify to display list.
  PERFORM set_document_create_result.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form update_document_result
*&---------------------------------------------------------------------*
FORM update_document_result  USING    pi_ucomm.

  DATA: lt_head_save TYPE TABLE OF zgtsdt1040,
        lt_item_save TYPE TABLE OF zgtsdt1041.

**
*  CHECK: gv_error IS INITIAL.

* get already saved data.
  SELECT *  FROM zgtsdt1040
           WHERE spmon EQ @gs_head-spmon
             AND vkorg EQ @gs_head-vkorg
             AND vkbur EQ @gs_head-vkbur
             AND vkgrp EQ @gs_head-vkgrp
             AND kunag EQ @gs_head-kunag
             AND matnr EQ @gs_head-matnr
    INTO TABLE @DATA(lt_head).

  _clear: lt_head_save, lt_item_save.

* 1) Update Header Status
  DATA(ls_head) = VALUE #( lt_head[ 1 ]  OPTIONAL ).

  APPEND VALUE #( BASE CORRESPONDING #( ls_head )
*                  prereconsta = 'C'
                  reconsta    = gs_head-reconsta
                  aedat       = sy-datlo
                  aezet       = sy-timlo
                  aenam       = sy-uname
                 ) TO lt_head_save.

* 2) Update Item Status
  lt_item_save = VALUE #( BASE lt_item_save
                          FOR ls_item  IN gt_item
                          ( VALUE #( BASE CORRESPONDING #( ls_item )
                                     aedat       = sy-datlo
                                     aezet       = sy-timlo
                                     aenam       = sy-uname
                                    )
                           )
                         ).

  IF lt_head_save[] IS NOT INITIAL AND
     lt_item_save[] IS NOT INITIAL.

    MODIFY: zgtsdt1040  FROM TABLE lt_head_save[],
            zgtsdt1041  FROM TABLE lt_item_save[].
    IF sy-subrc EQ 0.
      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
        EXPORTING
          wait = 'X'.

    ELSE.
      gv_error = 'X'.
      CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
    ENDIF.

  ELSE.
    gv_error = 'X'.
    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

  ENDIF.

**
  FREE: lt_head, lt_head_save, lt_item_save.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form delivery_order_creation
*&---------------------------------------------------------------------*
FORM delivery_order_creation .

  DATA: lv_vbeln_vl  TYPE vbeln_vl.

**
  CHECK: gv_error  IS INITIAL,
         gs_head   IS NOT INITIAL,
         gt_item[] IS NOT INITIAL.

* SO 별 DO 생성.
  DATA(lt_so) = gt_item[].
  DELETE lt_so  WHERE vbeln EQ space.

  SORT: lt_so  BY zseglev2 vbeln.
  DELETE ADJACENT DUPLICATES FROM lt_so COMPARING zseglev2 vbeln.

  LOOP AT lt_so  INTO DATA(ls_so).

    CLEAR: lv_vbeln_vl, gs_do_tech.
    _clear: gt_do_request, gt_do_item, gt_return.

    PERFORM make_delivery_data         TABLES   gt_do_request
                                                gt_item
                                       USING    ls_so-vbeln
                                       CHANGING gs_do_tech.

    PERFORM call_delivery_bapi         TABLES   gt_return
                                       CHANGING lv_vbeln_vl.

    PERFORM modify_delivery_result     TABLES   gt_item
                                                gt_return
                                       USING    ls_so-vbeln
                                                lv_vbeln_vl.
    IF gv_error IS NOT INITIAL.
      EXIT.
    ENDIF.

  ENDLOOP.

**
  FREE: lt_so.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form make_delivery_data
*&---------------------------------------------------------------------*
FORM make_delivery_data  TABLES   pt_request STRUCTURE bapideliciousrequest
                                  pt_item    STRUCTURE gs_item
                         USING    pi_vbeln
                         CHANGING ps_tech    TYPE bapideliciouscontrol.

**
  CHECK: pi_vbeln IS NOT INITIAL.

* Tech Set.
  ps_tech-post_async = 'X'.

* Request Set.
  pt_request[] = VALUE #( BASE pt_request[]
                          FOR ls_item  IN pt_item
                          WHERE ( vbeln = pi_vbeln )
                          ( id                     = 1
                            document_type          = 'A'
                            document_type_delivery = 'ZLFS'
                            document_numb          = ls_item-vbeln
                            document_item          = ls_item-posnr
                            material_long          = ls_item-matnr
                            plant                  = ls_item-werks
                            stge_loc               = '3410'
                            quantity_sales_uom     = ls_item-fkimg
                            sales_unit             = ls_item-vrkme
                            goods_issue_date       = sy-datlo
                           )
                         ).

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form call_delivery_bapi
*&---------------------------------------------------------------------*
FORM call_delivery_bapi  TABLES   pt_return STRUCTURE bapiret2
                         CHANGING pe_vbeln.

**
  CHECK: gt_do_request[] IS NOT INITIAL.

  _clear: gt_do_item, gt_return.

  CALL FUNCTION 'RV_DELIVERY_INIT'
    EXPORTING
      status_buff_init = 'X'.

  CALL FUNCTION 'BAPI_DELIVERYPROCESSING_EXEC'
    EXPORTING
      techn_control = gs_do_tech
    TABLES
      request       = gt_do_request
      createditems  = gt_do_item
      return        = pt_return.

  IF gt_do_item[] IS NOT INITIAL.
    pe_vbeln = VALUE #( gt_do_item[ 1 ]-document_numb OPTIONAL ).
  ENDIF.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form modify_delivery_result
*&---------------------------------------------------------------------*
FORM modify_delivery_result  TABLES   pt_item   STRUCTURE gs_item
                                      pt_return STRUCTURE bapiret2
                             USING    pi_vbeln
                                      pi_vbeln_vl.

**
  CHECK: pt_item[] IS NOT INITIAL.

  IF     pi_vbeln_vl IS INITIAL.
    DATA(ls_return) = VALUE #( pt_return[ type = 'E' ]  OPTIONAL ).
    IF ls_return IS INITIAL.
      CLEAR: ls_return.
      ls_return = VALUE #( pt_return[ type = 'A' ]  OPTIONAL ).
    ENDIF.
    gv_error = 'X'.
    ls_return-type = 'E'.

  ELSEIF pi_vbeln_vl IS NOT INITIAL.
    ls_return-type = 'S'.
    CLEAR: ls_return-message.

  ENDIF.

*  IF gv_error IS INITIAL.
  LOOP AT pt_item  ASSIGNING FIELD-SYMBOL(<lfs_item>)
                   WHERE vbeln = pi_vbeln.
    <lfs_item>-do_vbeln = pi_vbeln_vl.
    <lfs_item>-do_posnr = <lfs_item>-posnr.
    <lfs_item>-message  = ls_return-message.
  ENDLOOP.
*  ENDIF.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form batch_split_to_delivery
*&---------------------------------------------------------------------*
FORM batch_split_to_delivery  USING    pi_ucomm.

**
  CHECK: gv_error         IS INITIAL,
         gs_head-reconsta EQ 'B'.    " 납품오더 생성됨.

* Batch Data Get.
  PERFORM get_batch_split_data .

* Batch split create.
  PERFORM batch_split_creation .

* 2) Result modify to display list.
  PERFORM set_document_create_result.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form get_batch_split_data
*&---------------------------------------------------------------------*
FORM get_batch_split_data .

**
  DATA(lt_data) = gt_item[].
  DELETE lt_data  WHERE do_vbeln EQ space.
  SORT: lt_data BY do_vbeln do_posnr.

  _clear: gt_batch.
  SELECT b~*
    FROM @lt_data AS a  INNER JOIN zgtsdt1042 AS b
                        ON  a~spmon    EQ b~spmon
                        AND a~do_vbeln EQ b~do_vbeln
                        AND a~do_posnr EQ b~do_posnr
    INTO CORRESPONDING FIELDS OF TABLE @gt_batch.

* Make batch split data.
  IF gt_batch[] IS INITIAL.

    PERFORM make_batch_split_base_data   TABLES  lt_data.

  ENDIF.

**
  FREE: lt_data.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form make_batch_split_base_data
*&---------------------------------------------------------------------*
FORM make_batch_split_base_data  TABLES   pt_data STRUCTURE gs_item.

  DATA: lr_wadat    LIKE RANGE OF likp-wadat_ist,

        ls_batch    LIKE zgtsdt1042,
        lv_do_lfimg LIKE zgtsdt1042-lfimg,
        lv_lfimg    LIKE zgtsdt1042-lfimg.

**
  CHECK: pt_data[] IS NOT INITIAL.

  _clear: lr_wadat.
  lr_wadat = VALUE #( ( sign = 'I'           option = 'BT'
                        low  = gv_first_day  high   = gv_last_day ) ).

* Get DO/Charg Data.
  SELECT b~matnr, b~charg, b~werks, b~lgort, b~lfimg, b~vrkme
    FROM likp AS a  INNER JOIN lips AS b
                    ON a~vbeln EQ b~vbeln
   WHERE a~kunag     EQ @gs_head-kunag
     AND a~wadat_ist IN @lr_wadat
     AND b~matnr     EQ @gs_head-matnr
     AND b~lfimg     >  0
     AND b~wbsta     EQ 'C'
    INTO TABLE @DATA(lt_charg).

  IF lt_charg[] IS NOT INITIAL.

    SORT: lt_charg BY matnr charg.

    LOOP AT pt_data  INTO DATA(ls_data).

      CLEAR: ls_batch.
      MOVE-CORRESPONDING: ls_data TO ls_batch.

*     DO 수량.
      CLEAR: lv_do_lfimg.
      lv_do_lfimg = ls_data-fkimg.

      READ TABLE lt_charg  INTO DATA(ls_charg)
                           WITH KEY matnr = ls_data-matnr
                           BINARY SEARCH.
      IF sy-subrc = 0.
        LOOP AT lt_charg INTO ls_charg  FROM sy-tabix.
          IF ls_charg-matnr EQ ls_data-matnr.
            IF ls_charg-lfimg > 0.

              DATA(lv_index) = sy-tabix.

              CLEAR: lv_lfimg.
              IF     lv_do_lfimg >  ls_charg-lfimg.
*               DO 잔량 이 Batch 수량보다 클경우.
                lv_do_lfimg = lv_do_lfimg - ls_charg-lfimg.
                lv_lfimg    = ls_charg-lfimg.
                CLEAR: ls_charg-lfimg.

              ELSEIF lv_do_lfimg <= ls_charg-lfimg.
*               DO 잔량 이 Batch 수량보다 작거나 같은 경우.
                ls_charg-lfimg = ls_charg-lfimg - lv_do_lfimg.
                lv_lfimg    = lv_do_lfimg.
                CLEAR: lv_do_lfimg.

              ENDIF.

              ls_batch = VALUE #( BASE ls_batch
                                  charg = ls_charg-charg
                                  werks = ls_charg-werks
                                  lgort = ls_charg-lgort
                                  lfimg = lv_lfimg
                                  vrkme = ls_charg-vrkme
                                  erdat = sy-datlo
                                  erzet = sy-timlo
                                  ernam = sy-uname ).

              APPEND ls_batch TO gt_batch.

              MODIFY lt_charg  FROM ls_charg  INDEX lv_index
                               TRANSPORTING lfimg.

*             DO 잔량이 없을 경우
              IF lv_do_lfimg = 0.
                EXIT.
              ENDIF.

            ENDIF.
          ELSE.
            EXIT.
          ENDIF.
        ENDLOOP.
      ENDIF.

    ENDLOOP.

  ENDIF.

**
  FREE: lt_charg.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form batch_split_creation
*&---------------------------------------------------------------------*
FORM batch_split_creation .


**
  CHECK: gv_error   IS INITIAL,
         gs_head    IS NOT INITIAL,
         gt_item[]  IS NOT INITIAL,
         gt_batch[] IS NOT INITIAL.

  DATA(lt_do) = gt_item[].
  DELETE lt_do  WHERE do_vbeln EQ space.
  SORT: lt_do BY do_vbeln .
  DELETE ADJACENT DUPLICATES FROM lt_do COMPARING do_vbeln.

  SORT: gt_batch BY do_vbeln do_posnr.

  LOOP AT lt_do  INTO DATA(ls_do).

    CLEAR:  gs_do_chg_head, gs_do_chg_cont.
    _clear: gt_do_chg_item, gt_do_chg_item_cont, gt_do_chg_item_splt,
            gt_return.

    PERFORM make_batch_split_header    USING    ls_do
                                       CHANGING gs_do_chg_head
                                                gs_do_chg_cont.

    PERFORM make_batch_split_item      TABLES   gt_do_chg_item
                                                gt_do_chg_item_cont
                                                gt_do_chg_item_splt
                                       USING    ls_do.

    PERFORM call_delivery_chg_bapi     TABLES   gt_return
                                       USING    ls_do-do_vbeln.

    PERFORM modify_batch_split_result  TABLES   gt_item
                                                gt_return
                                       USING    ls_do-do_vbeln.

    IF gv_error IS NOT INITIAL.
      EXIT.
    ENDIF.

  ENDLOOP.

**
  FREE: lt_do.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form make_batch_split_header
*&---------------------------------------------------------------------*
FORM make_batch_split_header  USING    ps_do    LIKE gs_item
                              CHANGING ps_head  TYPE bapiobdlvhdrchg
                                       ps_cont  TYPE bapiobdlvhdrctrlchg.

**
  CHECK: ps_do IS NOT INITIAL.

  CLEAR: ps_head, ps_cont.
  ps_head-deliv_numb = ps_do-do_vbeln.
  ps_cont-deliv_numb = ps_do-do_vbeln.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form make_batch_split_item
*&---------------------------------------------------------------------*
FORM make_batch_split_item  TABLES   pt_item STRUCTURE bapiobdlvitemchg
                                     pt_cont STRUCTURE bapiobdlvitemctrlchg
                                     pt_splt STRUCTURE /spe/bapiobdlvitemchg
                            USING    ps_do   LIKE gs_item.

  DATA: lv_posnr      TYPE posnr_vl,
        lv_already(1).

**
  CHECK: ps_do      IS NOT INITIAL,
         gt_batch[] IS NOT INITIAL.

  DATA(lt_data) = gt_item[].
  DELETE lt_data  WHERE do_vbeln NE ps_do-do_vbeln.

  SORT: lt_data BY do_vbeln do_posnr.
  DELETE ADJACENT DUPLICATES FROM lt_data COMPARING do_vbeln do_posnr.

  CLEAR: lv_posnr.
  SELECT MAX( posnr )
    FROM lips  WHERE vbeln EQ @ps_do-vbeln
                 AND uecha NE '000000'
    INTO @lv_posnr.

  IF lv_posnr IS INITIAL.
    lv_posnr = '900000'.
  ENDIF.

* DO 정보 Get.
  SELECT b~*
    FROM @lt_data AS a   INNER JOIN lips AS b
                         ON  a~do_vbeln EQ b~vbeln
                         AND a~do_posnr EQ b~posnr
   WHERE a~vbeln EQ @ps_do-vbeln
    INTO TABLE @DATA(lt_lips).

  IF lt_lips[] IS NOT INITIAL.

    SORT: lt_lips BY vbeln posnr.

    LOOP AT lt_lips  INTO DATA(ls_lips).

      IF line_exists( gt_batch[ do_vbeln = ls_lips-vbeln
                                do_posnr = ls_lips-posnr ] ).

        APPEND VALUE #( deliv_numb = ls_lips-vbeln
                        deliv_item = ls_lips-posnr
                        chg_delqty = 'X'
                       ) TO pt_cont .

        APPEND VALUE #( deliv_numb      = ls_lips-vbeln
                        deliv_item      = ls_lips-posnr
                        material_long   = ls_lips-matnr
                        batch           = ls_lips-charg
                        dlv_qty         = 0
                        sales_unit      = ls_lips-vrkme
                        fact_unit_nom   = ls_lips-umvkz
                        fact_unit_denom = ls_lips-umvkn
                        conv_fact       = ls_lips-umref
                       ) TO pt_item.

        CLEAR lv_already.
        READ TABLE gt_batch  INTO DATA(ls_batch)
                             WITH KEY do_vbeln = ls_lips-vbeln
                                      do_posnr = ls_lips-posnr
                             BINARY SEARCH.
        IF sy-subrc = 0.
          LOOP AT gt_batch INTO ls_batch  FROM sy-tabix.
            IF ls_batch-do_vbeln = ls_lips-vbeln AND
                ls_batch-do_posnr = ls_lips-posnr.

              IF lv_already IS INITIAL AND
                 ls_lips-lgort NE ls_batch-lgort.

                APPEND VALUE #( deliv_numb = ls_lips-vbeln
                                deliv_item = ls_lips-posnr
                                stge_loc   = ls_batch-lgort
                               ) TO pt_splt.

                lv_already = 'X'.

              ENDIF.

              lv_posnr = lv_posnr + 1.

              APPEND VALUE #( deliv_numb      = ls_batch-do_vbeln
                              deliv_item      = lv_posnr
                              material_long   = ls_lips-matnr
                              batch           = ls_batch-charg
                              hieraritem      = ls_batch-do_posnr
                              usehieritm      = '1'
                              dlv_qty         = ls_batch-lfimg
                              sales_unit      = ls_batch-vrkme
                              fact_unit_nom   = ls_lips-umvkz
                              fact_unit_denom = ls_lips-umvkn
                              conv_fact       = ls_lips-umref
                             ) TO pt_item.

              APPEND VALUE #( deliv_numb = ls_batch-do_vbeln
                              deliv_item = lv_posnr
                              chg_delqty = 'X'
                             ) TO pt_cont.

            ELSE.
              EXIT.
            ENDIF.
          ENDLOOP.
        ENDIF.

      ENDIF.

    ENDLOOP.

  ENDIF.

**
  FREE: lt_data, lt_lips.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form call_delivery_chg_bapi
*&---------------------------------------------------------------------*
FORM call_delivery_chg_bapi  TABLES   pt_return STRUCTURE bapiret2
                             USING    pi_vbeln.

  DATA: lv_vbeln  LIKE bapiobdlvhdrchg-deliv_numb.

**
  CHECK: gt_do_chg_item[] IS NOT INITIAL.

  CLEAR: lv_vbeln.
  lv_vbeln = pi_vbeln.

  _clear: pt_return.
  CALL FUNCTION 'BAPI_OUTB_DELIVERY_CHANGE'
    EXPORTING
      header_data    = gs_do_chg_head
      header_control = gs_do_chg_cont
      delivery       = lv_vbeln
    TABLES
      item_data      = gt_do_chg_item
      item_control   = gt_do_chg_item_cont
      item_data_spl  = gt_do_chg_item_splt
      return         = pt_return.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form modify_batch_split_result
*&---------------------------------------------------------------------*
FORM modify_batch_split_result  TABLES   pt_item   STRUCTURE gs_item
                                         pt_return STRUCTURE bapiret2
                                USING    pi_vbeln.

**
  CHECK: gv_error IS INITIAL.

  DATA(ls_return) = VALUE #( pt_return[ type = 'E' ]  OPTIONAL ).
  IF ls_return IS INITIAL.
    CLEAR: ls_return.
    ls_return = VALUE #( pt_return[ type = 'A' ]  OPTIONAL ).

    IF ls_return IS INITIAL.
      CLEAR: ls_return.
      ls_return = VALUE #( pt_return[ type = 'X' ]  OPTIONAL ).

    ENDIF.

  ENDIF.

  IF ls_return IS INITIAL.
    ls_return-type = 'S'.
    CLEAR: ls_return-message.

  ELSE.
    gv_error = 'X'.
    ls_return-type = 'E'.

    PERFORM message_build USING ls_return-id
                                ls_return-number
                                ls_return-message_v1
                                ls_return-message_v2
                                ls_return-message_v3
                                ls_return-message_v4
                                ls_return-message.

  ENDIF.

  MODIFY pt_item  FROM VALUE #( message = ls_return-message )
                  TRANSPORTING message
                  WHERE do_vbeln = pi_vbeln.
**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form create_good_issue_doc
*&---------------------------------------------------------------------*
FORM create_good_issue_doc  USING    pi_ucomm.

**
  CHECK: gv_error         IS INITIAL,
         gs_head-reconsta EQ 'C'.    " 배치 지정됨.

* 1) Create Good issue
  PERFORM good_issue_creation .

* 2) Result modify to display list.
  PERFORM set_document_create_result.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form good_issue_creation
*&---------------------------------------------------------------------*
FORM good_issue_creation .

  DATA: lv_mblnr  TYPE mblnr.

**
  CHECK: gv_error  IS INITIAL,
         gs_head   IS NOT INITIAL,
         gt_item[] IS NOT INITIAL.

  DATA(lt_do) = gt_item[].
  DELETE lt_do  WHERE do_vbeln EQ space.
  SORT: lt_do BY do_vbeln .
  DELETE ADJACENT DUPLICATES FROM lt_do COMPARING do_vbeln .

  LOOP AT lt_do  INTO DATA(ls_do).

    CLEAR: gs_gi_vbkok, lv_mblnr.
    _clear: gt_gi_vbpok, gt_gi_prot.

    PERFORM make_good_issue_data        TABLES   gt_item
                                                 gt_gi_vbpok
                                        USING    ls_do-do_vbeln
                                        CHANGING gs_gi_vbkok.

    PERFORM call_good_issue_fm          TABLES   gt_gi_prot
                                        USING    ls_do-do_vbeln
                                        CHANGING lv_mblnr.

    PERFORM modify_good_issue_result    TABLES   gt_item
                                                 gt_gi_prot
                                        USING    ls_do-do_vbeln
                                                 lv_mblnr.

    IF gv_error IS NOT INITIAL.
      EXIT.
    ENDIF.

  ENDLOOP.

**
  FREE: lt_do.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form make_good_issue_data
*&---------------------------------------------------------------------*
FORM make_good_issue_data  TABLES   pt_item  STRUCTURE gs_item
                                    pt_vbpok STRUCTURE vbpok
                           USING    pi_vbeln
                           CHANGING ps_vbkok LIKE vbkok.

**
  CHECK: pi_vbeln  IS NOT INITIAL,
         pt_item[] IS NOT INITIAL.

  DATA(lt_item) = pt_item[].
  DELETE lt_item  WHERE do_vbeln NE pi_vbeln.

* Get Delivery Item data.
  SELECT *
    FROM lips  WHERE vbeln EQ @pi_vbeln
    INTO TABLE @DATA(lt_batch).

  DATA(lt_data) = lt_batch[].
  DELETE lt_data  WHERE uecha NE '000000'.

* Set Header
  ps_vbkok-vbeln_vl  = pi_vbeln.
  ps_vbkok-wabuc     = 'X'.
  ps_vbkok-komue     = 'X'.
  ps_vbkok-wadat_ist = gv_last_day.

  SORT: lt_data  BY vbeln posnr,
        lt_batch BY vbeln uecha posnr.

  IF lt_data[] IS NOT INITIAL.

    LOOP AT lt_data  INTO DATA(ls_data).

      PERFORM append_gi_item_data   TABLES pt_vbpok
                                    USING  ls_data
                                           'I'.    " Item

*     Batch Item
      READ TABLE lt_batch  INTO DATA(ls_batch)
                           WITH KEY vbeln = ls_data-vbeln
                                    uecha = ls_data-posnr
                           BINARY SEARCH.
      IF sy-subrc = 0.
        LOOP AT lt_batch INTO ls_batch  FROM sy-tabix.
          IF ls_batch-vbeln = ls_data-vbeln AND
             ls_batch-uecha = ls_data-posnr.

            PERFORM append_gi_item_data   TABLES pt_vbpok
                                          USING  ls_batch
                                                 'B'.    " Batch

          ELSE.
            EXIT.
          ENDIF.
        ENDLOOP.
      ENDIF.

    ENDLOOP.

  ENDIF.

**
  FREE: lt_item, lt_data, lt_batch.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form append_gi_item_data
*&---------------------------------------------------------------------*
FORM append_gi_item_data  TABLES   pt_vbpok STRUCTURE vbpok
                          USING    ps_data  LIKE lips
                                   pi_type.

**
  CHECK: ps_data IS NOT INITIAL.

  APPEND VALUE #( vbeln_vl  = ps_data-vbeln
                  posnr_vl  = ps_data-posnr
                  vbeln     = ps_data-vgbel
                  posnn     = ps_data-vgpos
                  matnr     = ps_data-matnr
                  werks     = ps_data-werks
                  lgort     = ps_data-lgort
                  charg     = COND #( WHEN ps_data-charg IS NOT INITIAL
                                           THEN ps_data-charg )
                  pikmg     = ps_data-lfimg
                  lfimg     = ps_data-lfimg
                 ) TO pt_vbpok.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form call_good_issue_fm
*&---------------------------------------------------------------------*
FORM call_good_issue_fm  TABLES   pt_prot STRUCTURE prott
                         USING    pi_vbeln
                         CHANGING pe_mblnr.

  FIELD-SYMBOLS: <lfs_emkpf> TYPE emkpf.

**
  CHECK: gs_gi_vbkok   IS NOT INITIAL,
         gt_gi_vbpok[] IS NOT INITIAL.

  UNASSIGN: <lfs_emkpf>.

  CALL FUNCTION 'WS_DELIVERY_UPDATE_2'
    EXPORTING
      vbkok_wa               = gs_gi_vbkok
      synchron               = 'X'
      commit                 = abap_false
      delivery               = pi_vbeln
      update_picking         = 'X'
      nicht_sperren_1        = 'Y'
      if_error_messages_send = ' '
    TABLES
      vbpok_tab              = gt_gi_vbpok
      prot                   = pt_prot.

  ASSIGN ('(SAPLV50S)EMKPF') TO <lfs_emkpf>.

  IF <lfs_emkpf> IS ASSIGNED.
    pe_mblnr = <lfs_emkpf>-mblnr.
  ENDIF.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form modify_good_issue_result
*&---------------------------------------------------------------------*
FORM modify_good_issue_result  TABLES   pt_item   STRUCTURE gs_item
                                        pt_prot   STRUCTURE prott
                               USING    pi_vbeln
                                        pi_mblnr.

  DATA: lv_mtype LIKE bapiret2-type,
        lv_msg   LIKE bapiret2-message.

**
  CLEAR: lv_mtype, lv_msg.

  IF pt_prot[] IS INITIAL.

    IF pi_mblnr IS NOT INITIAL.
      lv_mtype = 'S'.
    ELSE.
      gv_error = 'X'.
      lv_mtype = 'E'.
*     출고처리 중 오류가 발생하였습니다.
      lv_msg   = TEXT-e24.
    ENDIF.

    MODIFY pt_item  FROM VALUE #( mblnr   = pi_mblnr
                                  message = lv_msg )
                    TRANSPORTING mblnr message
                    WHERE do_vbeln = pi_vbeln.

  ELSE.
    DATA(ls_prot) = VALUE #( pt_prot[ msgty = 'E' ]  OPTIONAL ).
    IF ls_prot IS INITIAL.
      CLEAR: ls_prot.
      ls_prot = VALUE #( pt_prot[ msgty = 'A' ]  OPTIONAL ).
    ENDIF.

    gv_error = 'X'.
    IF ls_prot IS NOT INITIAL.

      DELETE: pt_prot  WHERE msgid EQ 'VU'.

      CLEAR: ls_prot.
      LOOP AT pt_prot  INTO ls_prot
                        WHERE msgty = 'E' OR msgty = 'A'.
        lv_mtype = 'E'.

        CLEAR: lv_msg.
        PERFORM message_build USING ls_prot-msgid
                                    ls_prot-msgno
                                    ls_prot-msgv1
                                    ls_prot-msgv2
                                    ls_prot-msgv3
                                    ls_prot-msgv4
                                    lv_msg.

        MODIFY pt_item  FROM VALUE #( message = lv_msg )
                        TRANSPORTING message
                        WHERE do_vbeln = ls_prot-vbeln.
*                          AND do_posnr = ls_prot-posnr.

      ENDLOOP.

    ELSE.
      lv_mtype = 'E'.
*     출고처리 중 오류가 발생하였습니다.
      lv_msg   = TEXT-e24.

      MODIFY pt_item  FROM VALUE #( message = lv_msg )
                      TRANSPORTING message
                      WHERE do_vbeln = pi_vbeln.

    ENDIF.

  ENDIF.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form start_cancel_document
*&---------------------------------------------------------------------*
FORM start_cancel_document  USING    pi_ucomm.

**
  CHECK: gv_error IS INITIAL.

* Get selected row.
  PERFORM get_selected_row             USING pi_ucomm.

  PERFORM confirm_before_crt_or_canc   USING pi_ucomm.

  PERFORM cancel_document_exc          USING pi_ucomm.

* Refresh.
  PERFORM get_data.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form cancel_document_exc
*&---------------------------------------------------------------------*
FORM cancel_document_exc  USING    pi_ucomm.

**
  CHECK: gv_error IS INITIAL.

* 정산Data 가 없는 경우, 구성함.
  IF gt_item[] IS INITIAL.
*   Modify Item list.
    PERFORM make_item_display_list        USING gs_head.

  ENDIF.

  CASE gs_head-reconsta.
    WHEN 'A'.    " 판매오더 취소
      PERFORM cancel_sales_order          USING  pi_ucomm.

    WHEN 'B' OR  " 판매오더 / 납품오더 취소
         'C'.    " 판매오더 / 납품오더 / 배치 지정 취소
      PERFORM cancel_delivery_order       USING  pi_ucomm.

      PERFORM cancel_sales_order          USING  pi_ucomm.

    WHEN 'D'.    " 판매오더 / 납품오더 / 배치 지정 / Good Issue 취소
      PERFORM cancel_good_issue_doc       USING  pi_ucomm.

      PERFORM cancel_delivery_order       USING  pi_ucomm.

      PERFORM cancel_sales_order          USING  pi_ucomm.

    WHEN 'E'.    " 판매오더 / 납품오더 / 배치 지정 / Good Issue / Billing 취소
      PERFORM cancel_so_billing_block     USING  pi_ucomm.

      PERFORM cancel_good_issue_doc       USING  pi_ucomm.

      PERFORM cancel_delivery_order       USING  pi_ucomm.

      PERFORM cancel_sales_order          USING  pi_ucomm.

  ENDCASE.

  PERFORM update_item_temp_data           USING  pi_ucomm.

  PERFORM update_document_result          USING  pi_ucomm.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form cancel_good_issue_doc
*&---------------------------------------------------------------------*
FORM cancel_good_issue_doc  USING    pi_ucomm.

**
  CHECK: gv_error         IS INITIAL,
         gs_head-reconsta EQ 'D'.    " Good Issue 처리됨.

* 1) Cancel Good issue
  PERFORM start_good_issue_cancel .

* 2) Result modify to display list.
  PERFORM set_document_cancel_result.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form start_good_issue_cancel
*&---------------------------------------------------------------------*
FORM start_good_issue_cancel .

  DATA: lt_msg   TYPE TABLE OF mesg,
        lv_mblnr TYPE mblnr.

**
  CHECK: gv_error  IS INITIAL,
         gs_head   IS NOT INITIAL,
         gt_item[] IS NOT INITIAL.

  DATA(lt_gi) = gt_item[].
  DELETE lt_gi  WHERE mblnr EQ space.

  SORT: lt_gi BY mblnr .
  DELETE ADJACENT DUPLICATES FROM lt_gi COMPARING mblnr .

  LOOP AT lt_gi  INTO DATA(ls_gi).

    CLEAR: lv_mblnr.
    _clear: lt_msg.
    PERFORM call_good_issue_cancel      TABLES   lt_msg
                                        USING    ls_gi
                                        CHANGING lv_mblnr.

    PERFORM modify_gi_cancel_result     TABLES   gt_item
                                                 lt_msg
                                        USING    ls_gi-mblnr
                                                 lv_mblnr.

    IF gv_error IS NOT INITIAL.
      EXIT.
    ENDIF.

  ENDLOOP.

**
  FREE: lt_gi, lt_msg.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form call_good_issue_cancel
*&---------------------------------------------------------------------*
FORM call_good_issue_cancel  TABLES   pt_msg  STRUCTURE mesg
                             USING    ps_gi   LIKE gs_item
                             CHANGING pe_mblnr.

  DATA: lv_vbeln TYPE likp-vbeln,
        lv_budat TYPE mkpf-budat,
        lv_tcode TYPE sy-tcode,
        lv_vbtyp TYPE likp-vbtyp.

  DATA: lt_mesg  TYPE TABLE OF mesg,
        lv_mblnr TYPE mblnr.

**
  CHECK: ps_gi-do_vbeln IS NOT INITIAL.

  SELECT SINGLE vbeln, wadat_ist, vbtyp
    FROM likp  WHERE vbeln EQ @ps_gi-do_vbeln
    INTO @DATA(ls_likp).

  IF ls_likp IS NOT INITIAL.

    CLEAR: lv_vbeln, lv_budat, lv_vbtyp, lv_tcode, lv_mblnr.
    _clear: lt_mesg.

    lv_vbeln = ls_likp-vbeln.
    lv_budat = ls_likp-wadat_ist.
    lv_vbtyp = ls_likp-vbtyp.
    lv_tcode = 'VL09'.

    SUBMIT zgtsdr0120_cancel WITH p_vbeln = lv_vbeln
                             WITH p_budat = lv_budat
                             WITH p_tcode = lv_tcode
                             WITH p_vbtyp = lv_vbtyp
                             AND RETURN.

    IMPORT lv_mblnr lt_mesg FROM MEMORY ID 'ZGTSDDOCANC'.
    FREE MEMORY ID 'ZGTSDDOCANC'.

    pt_msg[] = CORRESPONDING #( lt_mesg[] ).
    pe_mblnr = lv_mblnr.

  ENDIF.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form modify_gi_cancel_result
*&---------------------------------------------------------------------*
FORM modify_gi_cancel_result  TABLES   pt_item  STRUCTURE gs_item
                                       pt_msg   STRUCTURE mesg
                              USING    pi_mblnr
                                       pi_canc_mblnr.

  DATA: lv_mtype LIKE bapiret2-type,
        lv_msg   LIKE bapiret2-message.

**
  CLEAR: lv_mtype, lv_msg.

  IF pi_canc_mblnr IS NOT INITIAL.
    lv_mtype = 'S'.
*   출고처리가 취소 되었습니다.
    lv_msg = TEXT-s07.

  ELSE.
    gv_error = 'X'.
    lv_mtype = 'E'.

    LOOP AT pt_msg  INTO DATA(ls_msg)
                    WHERE msgty CA 'AEX'.
      IF lv_msg IS INITIAL.
        lv_msg = ls_msg-text.
      ELSE.
        lv_msg = |{ lv_msg }/{ ls_msg-text }|.
      ENDIF.
    ENDLOOP.

  ENDIF.

  MODIFY pt_item  FROM VALUE #( message = lv_msg )
                  TRANSPORTING message
                  WHERE mblnr = pi_mblnr.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form set_document_cancel_result
*&---------------------------------------------------------------------*
FORM set_document_cancel_result .

  DATA: lv_stat(4),       " 정산 상태
        lv_msg           LIKE bapiret2-message,
        lv_reconsta      TYPE zgtereconsta,
        lv_success_va(1),
        lv_success_vl(1),
        lv_success_cg(1),
        lv_success_gi(1),
        lv_success_vf(1).

**
  CLEAR: lv_reconsta, lv_msg, lv_stat,
         lv_success_va, lv_success_vl, lv_success_cg, lv_success_gi, lv_success_vf.

  IF gv_error IS INITIAL.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        wait = 'X'.

    CASE gs_head-reconsta.
      WHEN 'A'.    " 판매오더 취소
        CLEAR: lv_reconsta.
        lv_stat       = icon_led_inactive.
        lv_success_va = 'X'.
*       판매오더가 취소 되었습니다.
        lv_msg = TEXT-s09.

        PERFORM cancel_so_check_from_db .

      WHEN 'B'.    " 판매오더 / 납품오더 취소
        lv_stat       = icon_led_yellow.
        lv_reconsta   = 'A'.
        lv_success_vl = 'X'.
*       납품오더가 취소 되었습니다.
        lv_msg = TEXT-s08.

      WHEN 'C'.    " 판매오더 / 납품오더 / 배치 지정 취소
        lv_stat       = icon_led_yellow.
        lv_reconsta   = 'A'.
        lv_success_vl = 'X'.
*       납품오더가 취소 되었습니다.
        lv_msg = TEXT-s08.

      WHEN 'D'.    " 판매오더 / 납품오더 / 배치 지정 / Good Issue 취소
        lv_stat       = icon_led_yellow.
        lv_reconsta   = 'C'.
        lv_success_gi = 'X'.
*       출고처리가 취소 되었습니다.
        lv_msg = TEXT-s07.

      WHEN 'E'.    " 판매오더 / 납품오더 / 배치 지정 / Good Issue / Billing 취소
        lv_stat       = icon_led_yellow.
        lv_reconsta   = 'D'.
        lv_success_vf = 'X'.
*       Billing block이 취소되었습니다.
        lv_msg = TEXT-s11.

    ENDCASE.

  ELSE.
    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

    lv_reconsta = gs_head-reconsta.
    CASE gs_head-reconsta.
      WHEN 'A'.    " 판매오더 취소
        lv_stat = icon_led_red.
*       판매오더 취소중 오류가 발생하였습니다.
        lv_msg = TEXT-e27.

      WHEN 'B'.    " 판매오더 / 납품오더 취소
        lv_stat = icon_led_red.
*       납품오더 취소중 오류가 발생하였습니다.
        lv_msg = TEXT-e26.

      WHEN 'C'.    " 판매오더 / 납품오더 / 배치 지정 취소
        lv_stat = icon_led_red.
*       납품오더 취소중 오류가 발생하였습니다.
        lv_msg = TEXT-e26.

      WHEN 'D'.    " 판매오더 / 납품오더 / 배치 지정 / Good Issue 취소
        lv_stat = icon_led_red.
*       출고처리 취소중 오류가 발생하였습니다.
        lv_msg = TEXT-e25.

      WHEN 'E'.    " 판매오더 / 납품오더 / 배치 지정 / Good Issue / Billing 취소
        lv_stat = icon_led_red.
*       Billing block 취소중 오류가 발생하였습니다.
        lv_msg = TEXT-e39.

    ENDCASE.

  ENDIF.

* 판매오더 이전 작업에서 Error일 경우 Red icon? Yellow icon?
  IF lv_stat     = icon_led_red.
    IF gs_head-reconsta NE 'A'.
      lv_stat = icon_led_yellow.
    ENDIF.
  ENDIF.

  MODIFY gt_head  FROM VALUE #( reconsta = lv_reconsta
                                stat     = lv_stat
                                message  = lv_msg )
                  TRANSPORTING reconsta stat message
                  WHERE chk = 'X'.

  gs_head-reconsta = lv_reconsta.
  gs_head-stat     = lv_stat.
  gs_head-message  = lv_msg.

* Item Update : document clear.
  IF lv_success_va IS NOT INITIAL OR
     lv_success_vl IS NOT INITIAL OR
     lv_success_cg IS NOT INITIAL OR
     lv_success_gi IS NOT INITIAL OR
     lv_success_vf IS NOT INITIAL .

    LOOP AT gt_item  INTO gs_item  WHERE fkimg > 0.

      DATA(lv_index) = sy-tabix.

      gs_item = VALUE #( BASE gs_item
                         vbeln    = COND #( WHEN lv_success_va IS NOT INITIAL
                                                 THEN space
                                            ELSE gs_item-vbeln )
                         posnr    = COND #( WHEN lv_success_va IS NOT INITIAL
                                                 THEN space
                                            ELSE gs_item-posnr )
*                        납품오더 생성
                         do_vbeln = COND #( WHEN lv_success_vl IS NOT INITIAL
                                                 THEN space
                                            ELSE gs_item-do_vbeln )
                         do_posnr = COND #( WHEN lv_success_vl IS NOT INITIAL
                                                 THEN space
                                            ELSE gs_item-do_posnr )
                         mblnr    = COND #( WHEN lv_success_gi IS NOT INITIAL
                                                 THEN space
                                            ELSE gs_item-mblnr )
*                        Billing 생성
*                         bl_vbeln = COND #( WHEN lv_success_vf IS NOT INITIAL
*                                                 THEN space
*                                            ELSE gs_item-bl_vbeln )
*                         bl_posnr = COND #( WHEN lv_success_vf IS NOT INITIAL
*                                                 THEN space
*                                            ELSE gs_item-bl_posnr )
                        ).

      MODIFY gt_item FROM gs_item   INDEX lv_index
                     TRANSPORTING vbeln posnr do_vbeln do_posnr
                                  mblnr bl_vbeln bl_posnr.

    ENDLOOP.

  ENDIF.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form cancel_delivery_order
*&---------------------------------------------------------------------*
FORM cancel_delivery_order  USING    pi_ucomm.

**
  CHECK: gv_error         IS INITIAL,
         gs_head-reconsta EQ 'B' OR  " 납품오더 생성됨
         gs_head-reconsta EQ 'C'.    " 배치 지정됨.

* 1) Cancel Delivery Order
  PERFORM start_delivery_cancel .

* 2) Result modify to display list.
  PERFORM set_document_cancel_result.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form start_delivery_cancel
*&---------------------------------------------------------------------*
FORM start_delivery_cancel .

**
  CHECK: gv_error  IS INITIAL,
         gs_head   IS NOT INITIAL,
         gt_item[] IS NOT INITIAL.

  DATA(lt_do) = gt_item[].
  DELETE lt_do  WHERE do_vbeln EQ space.

  SORT: lt_do BY do_vbeln .
  DELETE ADJACENT DUPLICATES FROM lt_do COMPARING do_vbeln .

  LOOP AT lt_do  INTO DATA(ls_do).

    _clear: gt_return.

    PERFORM call_delivery_canc_bapi     TABLES  gt_return
                                        USING   ls_do-do_vbeln.

    PERFORM modify_do_cancel_result     TABLES  gt_item
                                                gt_return
                                        USING   ls_do-do_vbeln.

    IF gv_error IS NOT INITIAL.
      EXIT.
    ELSE.
      PERFORM delete_cbo_batch_info     USING   ls_do-do_vbeln.
    ENDIF.

  ENDLOOP.

**
  FREE: lt_do.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form call_delivery_canc_bapi
*&---------------------------------------------------------------------*
FORM call_delivery_canc_bapi  TABLES   pt_return STRUCTURE bapiret2
                              USING    pi_vbeln.

  DATA: lv_delivery TYPE bapiobdlvhdrchg-deliv_numb.

**
  CHECK: pi_vbeln IS NOT INITIAL.

  CLEAR: gs_do_chg_head, gs_do_chg_cont, lv_delivery.

  gs_do_chg_head-deliv_numb = pi_vbeln.

  gs_do_chg_cont-deliv_numb = pi_vbeln.
  gs_do_chg_cont-dlv_del    = 'X'.

  lv_delivery               = pi_vbeln.

  CALL FUNCTION 'RV_DELIVERY_INIT'
    EXPORTING
      if_no_deque = 'X'.

  CALL FUNCTION 'BAPI_OUTB_DELIVERY_CHANGE'
    EXPORTING
      header_data    = gs_do_chg_head
      header_control = gs_do_chg_cont
      delivery       = lv_delivery
    TABLES
      return         = pt_return[].

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form modify_do_cancel_result
*&---------------------------------------------------------------------*
FORM modify_do_cancel_result  TABLES   pt_item   STRUCTURE gs_item
                                       pt_return STRUCTURE bapiret2
                              USING    pi_vbeln.

  DATA: lv_mtype LIKE bapiret2-type,
        lv_msg   LIKE bapiret2-message.

**
  CLEAR: lv_mtype, lv_msg.

  LOOP AT pt_return  INTO DATA(ls_return)
                      WHERE type CA 'AE'.

    IF lv_msg IS INITIAL.
      lv_msg = ls_return-message.
    ELSE.
      lv_msg = |{ lv_msg }/{ ls_return-message }|.
    ENDIF.

  ENDLOOP.

  IF lv_msg IS NOT INITIAL.
    gv_error = 'X'.
    lv_mtype = 'E'.

  ELSE.
    lv_mtype = 'S'.
*   납품오더가 취소 되었습니다.
    lv_msg = TEXT-s08.
  ENDIF.

  MODIFY pt_item  FROM VALUE #( message = lv_msg )
                  TRANSPORTING message
                  WHERE do_vbeln = pi_vbeln.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form delete_cbo_batch_info
*&---------------------------------------------------------------------*
FORM delete_cbo_batch_info  USING    pi_vbeln.

**
  CHECK: pi_vbeln IS NOT INITIAL.

  SELECT *
    FROM zgtsdt1042  WHERE spmon    EQ @gs_head-spmon
                       AND do_vbeln EQ @pi_vbeln
    INTO TABLE @DATA(lt_data).

  IF lt_data[] IS NOT INITIAL.
    DELETE zgtsdt1042  FROM  TABLE lt_data[].
  ENDIF.

**
  FREE: lt_data.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form cancel_sales_order
*&---------------------------------------------------------------------*
FORM cancel_sales_order  USING    pi_ucomm.

**
  CHECK: gv_error         IS INITIAL,
         gs_head-reconsta EQ 'A'.    " 판매오더 생성됨

* 1) Cancel Sales Order
  PERFORM start_sales_order_cancel .

* 2) Result modify to display list.
  PERFORM set_document_cancel_result.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form start_sales_order_cancel
*&---------------------------------------------------------------------*
FORM start_sales_order_cancel .

**
  CHECK: gv_error  IS INITIAL,
         gs_head   IS NOT INITIAL,
         gt_item[] IS NOT INITIAL.

  DATA(lt_so) = gt_item[].
  DELETE lt_so  WHERE vbeln EQ space.

  SORT: lt_so BY vbeln .
  DELETE ADJACENT DUPLICATES FROM lt_so COMPARING vbeln .

  LOOP AT lt_so  INTO DATA(ls_so).

    _clear: gt_return.

    PERFORM call_sales_order_canc_bapi     TABLES  gt_return
                                           USING   ls_so-vbeln.

    PERFORM modify_so_cancel_result        TABLES  gt_item
                                                   gt_return
                                           USING   ls_so-vbeln.

    IF gv_error IS NOT INITIAL.
      EXIT.
    ENDIF.

  ENDLOOP.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form call_sales_order_canc_bapi
*&---------------------------------------------------------------------*
FORM call_sales_order_canc_bapi  TABLES   pt_return STRUCTURE bapiret2
                                 USING    pi_vbeln.

  DATA: lv_vbeln   LIKE bapivbeln-vbeln.

**
  CHECK: pi_vbeln IS NOT INITIAL.

  CLEAR: lv_vbeln, gs_so_canc_hdx.

  lv_vbeln                  = pi_vbeln.
  gs_so_canc_hdx-updateflag = 'D'.

  CALL FUNCTION 'BAPI_SALESORDER_CHANGE'
    EXPORTING
      salesdocument    = lv_vbeln
      order_header_inx = gs_so_canc_hdx
    TABLES
      return           = pt_return.
*      ORDER_ITEM_IN    = gt_so_item
*      ORDER_ITEM_INX   = gt_so_itemX.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form modify_so_cancel_result
*&---------------------------------------------------------------------*
FORM modify_so_cancel_result  TABLES   pt_item   STRUCTURE gs_item
                                       pt_return STRUCTURE bapiret2
                              USING    pi_vbeln.

  DATA: lv_mtype LIKE bapiret2-type,
        lv_msg   LIKE bapiret2-message.

**
  CLEAR: lv_mtype, lv_msg.

  LOOP AT pt_return  INTO DATA(ls_return)
                      WHERE type CA 'AE'.

    IF lv_msg IS INITIAL.
      lv_msg = ls_return-message.
    ELSE.
      lv_msg = |{ lv_msg }/{ ls_return-message }|.
    ENDIF.

  ENDLOOP.

  IF lv_msg IS NOT INITIAL.
    gv_error = 'X'.
    lv_mtype = 'E'.

  ELSE.
    lv_mtype = 'S'.
*   판매오더가 취소 되었습니다.
    lv_msg = TEXT-s09.
  ENDIF.

  MODIFY pt_item  FROM VALUE #( message = lv_msg )
                  TRANSPORTING message
                  WHERE vbeln = pi_vbeln.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form update_item_temp_data
*&---------------------------------------------------------------------*
FORM update_item_temp_data  USING    pi_ucomm.

**
  CHECK: gt_item[] IS NOT INITIAL.

  LOOP AT gt_item  INTO gs_item
                   WHERE fkimg > 0.

    MODIFY gt_item_tmp  FROM gs_item
                        TRANSPORTING vbeln posnr do_vbeln do_posnr
                                     mblnr bl_vbeln bl_posnr message
                        WHERE spmon    = gs_item-spmon
                          AND vkorg    = gs_item-vkorg
                          AND vkbur    = gs_item-vkbur
                          AND vkgrp    = gs_item-vkgrp
                          AND kunag    = gs_item-kunag
                          AND zseglev2 = gs_item-zseglev2
                          AND kondm    = gs_item-kondm.

  ENDLOOP.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form create_so_status_object
*&---------------------------------------------------------------------*
FORM create_so_status_object .

  DATA: lr_vbeln LIKE RANGE OF vbak-vbeln.

**
  CHECK: gv_error IS INITIAL.

  WAIT UP TO 1 SECONDS.

  DATA(lt_so) = gt_item[].
  DELETE lt_so  WHERE vbeln EQ space.

  CHECK: lt_so[] IS NOT INITIAL.

  SORT: lt_so BY vbeln.
  DELETE ADJACENT DUPLICATES FROM lt_so COMPARING vbeln.

  lr_vbeln = VALUE #( FOR ls_so  IN lt_so
                      ( sign   = 'I'
                        option = 'EQ'
                        low    = ls_so-vbeln ) ).

  SUBMIT zgtsdr1040_stat  WITH s_vbeln IN lr_vbeln
                          AND RETURN.

**
  FREE: lt_so, lr_vbeln.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form call_migo_dialog
*&---------------------------------------------------------------------*
FORM call_migo_dialog  USING    pi_mblnr.

  DATA: lv_mblnr TYPE mblnr,
        lv_mjahr TYPE mjahr.

**
  CHECK: pi_mblnr IS NOT INITIAL.

  CLEAR: lv_mblnr, lv_mjahr.
  lv_mblnr = pi_mblnr.
  lv_mjahr = gv_spmon+0(4).

  CALL FUNCTION 'MIGO_DIALOG'
    EXPORTING
      i_action            = 'A04'
      i_refdoc            = 'R02'
      i_notree            = 'X'
      i_skip_first_screen = 'X'
      i_deadend           = 'X'
      i_okcode            = 'OK_GO'
      i_new_rollarea      = 'X'
      i_mblnr             = lv_mblnr
      i_mjahr             = lv_mjahr
    EXCEPTIONS
      illegal_combination = 1
      OTHERS              = 2.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form cancel_so_check_from_db
*&---------------------------------------------------------------------*
FORM cancel_so_check_from_db .

  DATA: lr_vbeln     LIKE RANGE OF vbak-vbeln,
        lv_nodata(1).

**
  CHECK: gv_error IS INITIAL.

  WAIT UP TO 1 SECONDS.

  DATA(lt_so) = gt_item[].
  DELETE lt_so  WHERE vbeln EQ space.

  CHECK: lt_so[] IS NOT INITIAL.

  WHILE lv_nodata IS INITIAL.

    SELECT SINGLE @abap_true
      FROM @lt_so AS a  INNER JOIN vbak AS b
                        ON a~vbeln EQ b~vbeln
      INTO @DATA(lv_flg).

    IF lv_flg IS INITIAL.
      lv_nodata = 'X'.
    ENDIF.

  ENDWHILE.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form currency_convert_for_bapi
*&---------------------------------------------------------------------*
FORM currency_convert_for_bapi  USING    pi_amount
                                         pi_waers
                                CHANGING pe_amount.

  DATA: lv_currency LIKE tcurc-waers,
        lv_amount   LIKE bapicurr-bapicurr.

**
  CHECK: pi_amount NE 0 AND
         pi_waers IS NOT INITIAL.

  CLEAR: lv_currency, lv_amount.

  lv_currency = pi_waers.
  lv_amount   = pi_amount.

  CALL FUNCTION 'CURRENCY_AMOUNT_SAP_TO_BAPI'
    EXPORTING
      currency    = lv_currency
      sap_amount  = lv_amount
    IMPORTING
      bapi_amount = pe_amount.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form search_delivery_of_month
*&---------------------------------------------------------------------*
FORM search_delivery_of_month  USING    pi_ucomm.

**
  CHECK: gv_error IS INITIAL.

* Get selected row.
  PERFORM get_selected_row             USING pi_ucomm.

* Get Delivery data
  PERFORM get_delivery_of_month        USING pi_ucomm.

  IF gv_error IS INITIAL.

    IF gt_do_info[] IS NOT INITIAL.
      CALL SCREEN 0200  STARTING AT  20  5.
    ELSE.
      gv_error = 'X'.
*     당월 출고내역이 없습니다.
      MESSAGE s000 WITH TEXT-e35  DISPLAY LIKE 'E'.
    ENDIF.

  ENDIF.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form get_delivery_of_month
*&---------------------------------------------------------------------*
FORM get_delivery_of_month  USING    pi_ucomm.

  DATA: lr_wadat  LIKE RANGE OF likp-wadat_ist.

**
  CHECK: gv_error IS INITIAL,
         gs_head  IS NOT INITIAL.

  _clear: lr_wadat.
  lr_wadat = VALUE #( ( sign = 'I'           option = 'BT'
                        low  = gv_first_day  high = gv_last_day ) ).

  _clear: gt_do_info.
  SELECT a~vbeln, a~posnr,
         b~matnr, b~arktx, b~vbeln AS do_vbeln, b~posnr AS do_posnr,
         b~lfimg, b~vrkme,
         c~kunnr, e~name1,
         d~zpjno, d~zptxt,
         f~wadat_ist
    FROM vbap AS a INNER JOIN lips AS b
                   ON  a~vbeln EQ b~vgbel
                   AND a~posnr EQ b~vgpos
                   INNER JOIN vbak AS c
                   ON a~vbeln EQ c~vbeln
                   INNER JOIN zsd0106t AS d
                   ON c~zpjno EQ d~zpjno
                   INNER JOIN kna1 AS e
                   ON c~kunnr EQ e~kunnr
                   INNER JOIN likp AS f
                   ON b~vbeln EQ f~vbeln
   WHERE b~lfimg     NE 0
     AND b~wbsta     EQ 'C'
     AND a~kunnr_ana EQ @gs_head-kunag
     AND f~wadat_ist IN @lr_wadat
     AND a~matnr     EQ @gs_head-matnr
     AND c~auart     EQ 'TA'
    INTO CORRESPONDING FIELDS OF TABLE @gt_do_info.
**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form set_so_billing_block
*&---------------------------------------------------------------------*
FORM set_so_billing_block  USING    pi_ucomm.


**
  CHECK: gv_error         IS INITIAL,
         gs_head-reconsta EQ 'D'.    " Good Issue 처리됨.

* Billing block 대상 Get
  PERFORM get_delivery_of_month        USING pi_ucomm.

* Billing block set
  PERFORM change_billing_block         USING pi_ucomm.

* Result modify to display list.
  PERFORM set_document_create_result.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form change_billing_block
*&---------------------------------------------------------------------*
FORM change_billing_block  USING    pi_ucomm.

  DATA: lv_vbeln   LIKE bapivbeln-vbeln,
        ls_header  LIKE bapisdh1,
        ls_headerx LIKE bapisdh1x.

**
  CHECK: gv_error  IS INITIAL,
         gs_head   IS NOT INITIAL,
         gt_item[] IS NOT INITIAL.

  DATA(lt_so) = gt_do_info[].
  SORT: lt_so BY vbeln .
  DELETE ADJACENT DUPLICATES FROM lt_so COMPARING vbeln .

  LOOP AT lt_so  INTO DATA(ls_so).

    CLEAR: lv_vbeln, ls_header, ls_headerx.
    lv_vbeln = ls_so-vbeln.

    IF     pi_ucomm EQ 'CREATE'.    " 매출정산
      ls_header-bill_block  = 'G1'.
    ELSEIF pi_ucomm EQ 'CANCEL'.    " 정산취소
      ls_header-bill_block  = ' '.
    ENDIF.

    ls_headerx-bill_block = 'X'.
    ls_headerx-updateflag = 'U'.

    _clear: gt_return.
    CALL FUNCTION 'BAPI_SALESORDER_CHANGE'
      EXPORTING
        salesdocument    = lv_vbeln
        order_header_in  = ls_header
        order_header_inx = ls_headerx
      TABLES
        return           = gt_return.

    DATA(ls_return) = VALUE #( gt_return[ type = 'E' ]  OPTIONAL ).
    IF ls_return IS NOT INITIAL.
      gv_error = 'X'.
      EXIT.
    ENDIF.

  ENDLOOP.

**
  FREE: lt_so.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form cancel_so_billing_block
*&---------------------------------------------------------------------*
FORM cancel_so_billing_block  USING    pi_ucomm.

**
  CHECK: gv_error         IS INITIAL,
         gs_head-reconsta EQ 'E'.    " Billing Block

* Billing block 대상 Get
  PERFORM get_delivery_of_month        USING pi_ucomm.

* Billing block set
  PERFORM change_billing_block         USING pi_ucomm.

* Result modify to display list.
  PERFORM set_document_cancel_result.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form check_sales_vendor
*&---------------------------------------------------------------------*
FORM check_sales_vendor  USING    ps_head    LIKE gs_head
                         CHANGING pv_lifnr.

  DATA: lv_emp  LIKE lfa1-lifnr.

**
  CHECK: ps_head  IS NOT INITIAL,
         gv_error IS INITIAL.

* 영업사원 정보 조회 - KNVP.
  SELECT SINGLE lifnr
    FROM knvp  WHERE vkorg EQ @gv_vkorg
                 AND vtweg EQ @gv_vtweg
                 AND spart EQ @gv_spart
                 AND parvw EQ 'VE'
                 AND kunnr EQ @ps_head-kunag
    INTO @DATA(lv_lifnr).

  IF lv_lifnr IS INITIAL.

    CLEAR: lv_emp.
    lv_emp = 'E00' && sy-uname.

    SELECT SINGLE lifnr
      FROM lfa1  WHERE lifnr EQ @lv_emp
                   AND ktokk EQ 'EMP'
      INTO @lv_lifnr.

  ENDIF.

  IF lv_lifnr IS NOT INITIAL.
    pv_lifnr = lv_lifnr.
  ENDIF.

**

ENDFORM.
