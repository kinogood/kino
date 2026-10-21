*&---------------------------------------------------------------------*
*& Include          ZGTSDR1030F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form control_lock_object
*&---------------------------------------------------------------------*
FORM control_lock_object  USING    pi_type
                                   pi_lock
                                   pi_cprog
                          CHANGING pe_error.

  DATA: lv_name     TYPE user_addr-name_textc,
        lv_spmon(8),
        lv_kunnr    TYPE kunag.

**
  IF pi_type = 'L'.    " Lock
    CLEAR: lv_name, lv_spmon, lv_kunnr.
    PERFORM check_lock_obj_zgtsdr1030  USING    pi_cprog
                                       CHANGING lv_name
                                                lv_spmon
                                                lv_kunnr
                                                pe_error.
    IF pe_error IS NOT INITIAL.
*     사용자 &1가 &2 / &3 를 처리중 입니다.
      MESSAGE i114(zgtsd01) WITH lv_name lv_spmon lv_kunnr
                            DISPLAY LIKE 'E'.
    ENDIF.

  ENDIF.

  PERFORM lock_unlock_obj_zgtsdr1030    USING    pi_type
                                                 pi_cprog
                                        CHANGING pi_lock
                                                 pe_error.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form check_lock_obj_zgtsdr1030
*&---------------------------------------------------------------------*
FORM check_lock_obj_zgtsdr1030  USING    pi_cprog
                                CHANGING pe_name
                                         pe_spmon
                                         pe_kunnr
                                         pe_error.

  DATA : lt_enq    TYPE TABLE OF seqg3,
         ls_obj    TYPE zgtsds1030,
         lv_guname TYPE eqeuname.

**
  CHECK: gt_base[] IS NOT INITIAL.

  _clear: lt_enq.

  CALL FUNCTION 'ENQUEUE_READ'
    EXPORTING
      gname                 = CONV eqegraname( |ZGTSDS1030| )
      guname                = space
    TABLES
      enq                   = lt_enq
    EXCEPTIONS
      communication_failure = 1
      system_failure        = 2
      OTHERS                = 3.

  CHECK: sy-subrc EQ 0.

  LOOP AT lt_enq INTO DATA(ls_enq).

    CLEAR: ls_obj, lv_guname.
    MOVE: ls_enq-garg+00(03) TO ls_obj-mandt ,
          ls_enq-garg+03(40) TO ls_obj-prog  ,
          ls_enq-garg+43(06) TO ls_obj-spmon ,
          ls_enq-garg+49(10) TO ls_obj-kunnr .

    IF ls_obj-mandt EQ sy-mandt AND
       ls_obj-prog  EQ pi_cprog.

      DATA(ls_base) = VALUE #( gt_base[ spmon = ls_obj-spmon
                                        kunnr = ls_obj-kunnr ]
                               OPTIONAL ).

      IF ls_base IS NOT INITIAL.

        pe_error  = 'X'.
        pe_spmon  = ls_obj-spmon+0(4) && '.' && ls_obj-spmon+4(2).
        pe_kunnr  = ls_obj-kunnr.
        lv_guname = ls_enq-guname.
        EXIT.

      ENDIF.

    ENDIF.

  ENDLOOP.

  IF pe_error IS NOT INITIAL.

    SELECT SINGLE bname && '(' && name_textc && ')'
      FROM user_addr  WHERE bname EQ @lv_guname
      INTO @pe_name.

  ENDIF.

**
  FREE: lt_enq.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form lock_unlock_obj_zgtsdr1030
*&---------------------------------------------------------------------*
FORM lock_unlock_obj_zgtsdr1030  USING    pi_type
                                          pi_cprog
                                 CHANGING pe_lock
                                          pe_error.

**
  CHECK: pe_error IS INITIAL.

  DATA(lv_spmon) = VALUE #( s_spmon[ 1 ]-low  OPTIONAL ).

  DATA(lt_kunnr) = gt_base[].
  SORT: lt_kunnr BY kunnr.
  DELETE ADJACENT DUPLICATES FROM lt_kunnr COMPARING kunnr.

  LOOP AT lt_kunnr  INTO DATA(ls_kunnr).

    CASE pi_type.
      WHEN 'L'.    " Lock
        CALL FUNCTION 'ENQUEUE_EZGT_ZGTSDR1030'
          EXPORTING
            mandt          = sy-mandt
            prog           = pi_cprog
            spmon          = lv_spmon
            kunnr          = ls_kunnr-kunnr
          EXCEPTIONS
            foreign_lock   = 1
            system_failure = 2
            OTHERS         = 3.

        IF sy-subrc <> 0.
          CLEAR pe_lock.
          MESSAGE ID sy-msgid TYPE 'I' NUMBER sy-msgno
             WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
             DISPLAY LIKE 'E'.
          EXIT.
        ELSE.
          pe_lock = 'X'.
        ENDIF.

      WHEN 'U'.    " UnLock
        CALL FUNCTION 'DEQUEUE_EZGT_ZGTSDR1030'
          EXPORTING
            mandt = sy-mandt
            prog  = pi_cprog
            spmon = lv_spmon
            kunnr = ls_kunnr-kunnr.

    ENDCASE.

  ENDLOOP.

**
  FREE: lt_kunnr.

ENDFORM.

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

** 가격 단위.
  IF p_kpein  IS INITIAL.
    p_kpein = 1.
  ENDIF.
  IF p_kmein  IS INITIAL.
    p_kmein = 'KG'.
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
       screen-name = 'S_SPART-LOW' OR
       screen-name = 'P_KPEIN' OR
       screen-name = 'P_KMEIN' .
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
*& Form start_process
*&---------------------------------------------------------------------*
FORM start_process .

  CLEAR: gv_error.
  PERFORM check_valid_input_data.

  PERFORM get_data.

  PERFORM get_top_of_page_data.

  PERFORM make_dynamic_fieldcat_and_itab.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form check_valid_input_data
*&---------------------------------------------------------------------*
FORM check_valid_input_data .

**
  IF s_spmon[] IS INITIAL.
    gv_error = 'X'.
*   단가적용 월이 입력되지 않았습니다.
    MESSAGE s000 WITH TEXT-e02  DISPLAY LIKE 'E'.

  ELSE.

*   단가기준월 Check.
    PERFORM check_valid_spmon_date.

*   영업팀 Check.
    PERFORM check_valid_vkbur_data.

*   소재영업팀 거래처 Check
    PERFORM check_valid_kunnr.

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
  CHECK: rb_crt = 'X'.

  DATA(lv_spmon) = VALUE #( s_spmon[ 1 ]-low  OPTIONAL ).
  CHECK: lv_spmon < sy-datlo+0(6).

* 예외 사용자 Check.
  SELECT SINGLE @abap_true
    FROM zgtppt1010  WHERE module_kind EQ 'SD'
                       AND codegrp     EQ '6ZZZ'
                       AND fld_01      EQ @sy-repid
                       AND fld_02      EQ @sy-uname
    INTO @DATA(lv_flg).

  IF lv_flg IS INITIAL.

    DATA(lv_vkorg) = VALUE #( s_vkorg[ 1 ]-low  OPTIONAL ).
    DATA(lv_vkbur) = VALUE #( s_vkbur[ 1 ]-low  OPTIONAL ).

*   영업팀 단위로 로직 예외 여부확인.
    CLEAR: lv_active.
    CALL FUNCTION 'ZGTSD_EXIT_CONTROL'
      EXPORTING
        i_prog   = sy-repid
        i_vkorg  = lv_vkorg
        i_vkbur  = lv_vkbur
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
    lv_date = lv_spmon && '01'.
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
*     전월 단가는 익월 3영업일까지 생성/변경 가능합니다.
      MESSAGE s000 WITH TEXT-e04  DISPLAY LIKE 'E'.
    ENDIF.

  ENDIF.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form check_valid_vkbur_data
*&---------------------------------------------------------------------*
FORM check_valid_vkbur_data .

  DATA: lv_date   LIKE sy-datlo,
        lv_fld_03 LIKE zgtppt1010-fld_03,
        lr_vkorg  TYPE RANGE OF zgtppt1010-fld_01,

        lv_vkbur  TYPE vkbur,
        lv_type   TYPE char1,
        lv_subrc  LIKE sy-subrc.

**
  CHECK: gv_error IS INITIAL.

  CLEAR: lv_date.
  DATA(lv_spmon) = VALUE #( s_spmon[ 1 ]-low  OPTIONAL ).
  lv_date = lv_spmon && '01'.

  _clear: lr_vkorg.
  DATA(lv_vkorg) = VALUE #( s_vkorg[ 1 ]-low  OPTIONAL ).
  lr_vkorg = VALUE #( ( sign = 'I'  option = 'EQ'  low = lv_vkorg ) ).

  CLEAR: lv_fld_03, lv_vkbur.
  DATA(lv_vkbur_in) = VALUE #( s_vkbur[ 1 ]-low  OPTIONAL ).
  lv_fld_03 = condense( lv_vkbur_in ).
  lv_vkbur  = condense( lv_vkbur_in ).

  IF     rb_crt = 'X'.    " 생성.

    SELECT SINGLE @abap_true
      FROM zgtppt1010  WHERE module_kind EQ 'SD'
                         AND codegrp     EQ '6005'
                         AND fld_01      IN @lr_vkorg
                         AND fld_03      EQ @lv_fld_03
                         AND fld_07      LE @lv_date
                         AND fld_08      GE @lv_date
    INTO @DATA(lv_flg).

  ELSEIF rb_dis = 'X'.    " 조회.

    CLEAR: lv_flg.
    lv_flg = 'X'.
*    SELECT SINGLE @abap_true
*      FROM zgtsdt1030  WHERE vkorg IN @s_vkorg
*                         AND vtweg IN @s_vtweg
*                         AND spart IN @s_spart
*                         AND vkbur IN @s_vkbur
*                         AND spmon IN @s_spmon
*    INTO @lv_flg.

  ENDIF.

  IF lv_flg IS INITIAL.
    gv_error = 'X'.
*   유효하지 않은 영업팀입니다.
    MESSAGE s000 WITH TEXT-e03  DISPLAY LIKE 'E'.

  ELSE.

    CLEAR: lv_type, lv_subrc.
    lv_type = '8'.

    CALL FUNCTION 'ZGTSD_AUTHORIZATION_CHECK'
      EXPORTING
        i_vkbur = lv_vkbur
        i_type  = lv_type
      IMPORTING
        e_subrc = lv_subrc.

    IF lv_subrc NE 0.
      gv_error = 'X'.
*     해당 영업팀에 대한 권한이 없습니다.
      MESSAGE s000 WITH TEXT-e03  DISPLAY LIKE 'E'.
    ENDIF.

  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form check_valid_kunnr
*&---------------------------------------------------------------------*
FORM check_valid_kunnr .

  DATA: lv_date         LIKE sy-datlo,
        lv_fld_03       LIKE zgtppt1010-fld_03,
        lr_vkorg        TYPE RANGE OF zgtppt1010-fld_01,
        lr_credit_sgmnt TYPE RANGE OF ukmbp_cms_sgm-credit_sgmnt.

**
  CHECK: gv_error  IS INITIAL,
         rb_crt    IS NOT INITIAL,    " 생성.
         s_kunnr[] IS NOT INITIAL.

* Credit sgment
  CLEAR: lv_date.
  DATA(lv_spmon) = VALUE #( s_spmon[ 1 ]-low  OPTIONAL ).
  lv_date = lv_spmon && '01'.

  _clear: lr_vkorg.
  DATA(lv_vkorg) = VALUE #( s_vkorg[ 1 ]-low  OPTIONAL ).
  lr_vkorg = VALUE #( ( sign = 'I'  option = 'EQ'  low = lv_vkorg ) ).

  CLEAR: lv_fld_03.
  DATA(lv_vkbur) = VALUE #( s_vkbur[ 1 ]-low  OPTIONAL ).
  lv_fld_03 = condense( lv_vkbur ).

  SELECT fld_05
    FROM zgtppt1010  WHERE module_kind EQ 'SD'
                       AND codegrp     EQ '6005'
                       AND fld_01      IN @lr_vkorg
                       AND fld_03      EQ @lv_fld_03
                       AND fld_07      LE @lv_date
                       AND fld_08      GE @lv_date
    INTO TABLE @DATA(lt_fld_05).

  _clear: lr_credit_sgmnt.
  IF lt_fld_05[] IS NOT INITIAL.
    lr_credit_sgmnt = VALUE #( BASE lr_credit_sgmnt
                               FOR ls_05  IN lt_fld_05
                               ( sign = 'I'  option = 'EQ'
                                 low = ls_05-fld_05 ) ).
  ENDIF.

  IF lr_credit_sgmnt[] IS NOT INITIAL.

    SELECT a~customer AS kunnr, b~credit_sgmnt
      FROM i_businesspartnercustomer AS a  INNER JOIN ukmbp_cms_sgm AS b
                                           ON a~businesspartner EQ b~partner
     WHERE a~customer IN @s_kunnr
      INTO TABLE @DATA(lt_kunnr).

    DELETE lt_kunnr WHERE credit_sgmnt NOT IN lr_credit_sgmnt.

    IF lt_kunnr[] IS INITIAL.

      DATA(lv_kunnr) = VALUE #( s_kunnr[ 1 ]-low  OPTIONAL ).
      lv_kunnr = condense( |{ lv_kunnr ALPHA = OUT }| ).

      gv_error = 'X'.
*     입력하신 거래처 LT_ERR-LOW 는 소재영업팀 거래처에 해당하지 않습니다.'
      DATA(lv_msg) = |{ '입력하신 거래처' } | && lv_kunnr && | { TEXT-e05 }|.
      MESSAGE s000 WITH lv_msg  DISPLAY LIKE 'E'.

    ENDIF.

  ENDIF.

**
  FREE: lt_fld_05, lt_kunnr.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form get_data
*&---------------------------------------------------------------------*
FORM get_data .

**
  CHECK: gv_error IS INITIAL.

  PERFORM get_price_type_master_data.

  _clear: gt_base.
  IF     rb_crt  IS NOT INITIAL.    " 생성.

    PERFORM get_data_for_create.

  ELSEIF rb_dis  IS NOT INITIAL.    " 조회

    PERFORM get_data_from_1081 .

  ENDIF.

  PERFORM get_descriptions.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form get_price_type_master_data
*&---------------------------------------------------------------------*
FORM get_price_type_master_data .

  DATA: lv_date  LIKE sy-datlo.

**
  CHECK: gv_error IS INITIAL.

  CLEAR: lv_date.
  DATA(lv_spmon) = VALUE #( s_spmon[ 1 ]-low  OPTIONAL ).
  lv_date = lv_spmon && '01'.

  _clear: gt_type.
  SELECT codeid, fld_01, fld_02, fld_03, fld_06
    FROM zgtppt1010  WHERE module_kind EQ 'SD'
                       AND codegrp     EQ '6006'
                       AND fld_04      LE @lv_date
                       AND fld_05      GE @lv_date
    INTO CORRESPONDING FIELDS OF TABLE @gt_type.

  IF gt_type[] IS NOT INITIAL.
    SORT: gt_type BY fld_01 fld_06 fld_02.
  ENDIF.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form get_data_from_1081
*&---------------------------------------------------------------------*
FORM get_data_from_1081 .

  DATA: lr_spmon  LIKE RANGE OF zgtsdt1030-spmon,
        lv_fld_02 LIKE zgtppt1010-fld_02.

**
  CHECK: gv_error IS INITIAL.

  _clear: lr_spmon.
  IF     rb_crt  IS NOT INITIAL.    " 생성.

    DATA(lv_spmon) = VALUE #( s_spmon[ 1 ]-low  OPTIONAL ).
    DATA(lv_spmon_before) = lv_spmon - 1.

    lr_spmon = VALUE #( ( sign = 'I'  option = 'EQ'  low = lv_spmon_before )
                        ( sign = 'I'  option = 'EQ'  low = lv_spmon ) ).

  ELSEIF rb_dis  IS NOT INITIAL.    " 조회

    lr_spmon = CORRESPONDING #( s_spmon[] ).

  ENDIF.

  IF lr_spmon[] IS NOT INITIAL.

    SELECT *
      FROM zgtsdt1030  WHERE spmon  IN @lr_spmon
                         AND vkorg  IN @s_vkorg
                         AND kunnr  IN @s_kunnr
                         AND vtweg  IN @s_vtweg
                         AND spart  IN @s_spart
                         AND vkbur  IN @s_vkbur
      INTO CORRESPONDING FIELDS OF TABLE @gt_base.

  ENDIF.

* 전월 데이타를 당월로 변경.
  IF gt_base[] IS NOT INITIAL.

    IF rb_crt    IS NOT INITIAL.    " 생성.

*     당월데이타 / 전월데이타가 같이 있는 경우 전월 데이타 삭제
      DATA(lv_before) = VALUE #( gt_base[ spmon = lv_spmon_before ]-spmon
                                 OPTIONAL ).
      DATA(lv_now)    = VALUE #( gt_base[ spmon = lv_spmon ]-spmon
                                 OPTIONAL ).

      IF     lv_before IS NOT INITIAL AND lv_now IS INITIAL.
*       전월데이타만 있는 경우 당월로 변경.
        MODIFY gt_base  FROM VALUE #( spmon = lv_spmon
                                      kbetr = space
                                      waers = space
                                      kpein = space
                                      kmein = space )
                        TRANSPORTING spmon kbetr waers kpein kmein
                        WHERE spmon EQ lv_spmon_before.

      ELSEIF lv_before IS NOT INITIAL AND lv_now IS NOT INITIAL.
*       당월데이타 / 전월데이타가 같이 있는 경우 전월 데이타 삭제
        DELETE gt_base  WHERE spmon EQ lv_spmon_before.

      ELSEIF lv_before IS INITIAL AND lv_now IS NOT INITIAL.
*       당월데이타만 있는 경우 그대로 진행.
      ENDIF.

    ENDIF.

**  변경 또는 추가된 조건 유형 추가.
    PERFORM add_kondm_from_master_data .

  ENDIF.

  IF gt_base[] IS NOT INITIAL.
    LOOP AT gt_base  INTO DATA(ls_base).

      DATA(lv_index) = sy-tabix.

      CLEAR: lv_fld_02.
      lv_fld_02 = ls_base-kondm.

      DATA(ls_type) = VALUE #( gt_type[ fld_02 = lv_fld_02 ]  OPTIONAL ).

      IF ls_type IS NOT INITIAL.
        ls_base-fld_06 = ls_type-fld_06.
        ls_base-fld_01 = ls_type-fld_01.
        ls_base-waers  = 'KRW'.

        MODIFY gt_base  FROM ls_base.
      ELSE.
*       삭제된 가공비 유형 제외
        DELETE gt_base INDEX lv_index.
      ENDIF.

    ENDLOOP.
  ENDIF.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form add_KONDM_from_master_data
*&---------------------------------------------------------------------*
FORM add_kondm_from_master_data .

**
  CHECK: gt_base[] IS NOT INITIAL.

  DATA(lt_base) = gt_base[].
  SORT: lt_base BY kunnr matnr,
        gt_base BY kunnr matnr kondm.

  LOOP AT lt_base  INTO DATA(ls_base).

    PERFORM append_new_kondm_to_base    USING: 'OEM'    ls_base,
                                               'DIRECT' ls_base.

  ENDLOOP.

**
  FREE: lt_base.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form append_new_KONDM_to_base
*&---------------------------------------------------------------------*
FORM append_new_kondm_to_base  USING    pi_type
                                        ps_base   LIKE gs_base.

  DATA: lv_type  LIKE zgtppt1010-fld_01,
        lv_kondm LIKE zgtsdt1030-kondm.

**
  CHECK: pi_type IS NOT INITIAL,
         ps_base IS NOT INITIAL.

  CLEAR: lv_type.
  lv_type = pi_type.

  READ TABLE gt_type  INTO DATA(ls_type)
                      WITH KEY fld_01 = lv_type
                      BINARY SEARCH.
  IF sy-subrc = 0.
    LOOP AT gt_type INTO ls_type  FROM sy-tabix.
      IF ls_type-fld_01 = lv_type.

        CLEAR: lv_kondm.
        lv_kondm = ls_type-fld_02.

        READ TABLE gt_base  INTO DATA(ls_base)
                            WITH KEY kunnr = ps_base-kunnr
                                     matnr = ps_base-matnr
                                     kondm = lv_kondm.
        IF sy-subrc <> 0.

          ps_base-kondm  = ls_type-fld_02.
          ps_base-kondmt = ls_type-fld_03.
          ps_base-fld_06 = ls_type-fld_06.
          ps_base-fld_01 = ls_type-fld_01.

          CLEAR: ps_base-kbetr, ps_base-waers,
                 ps_base-kpein, ps_base-kmein.

          APPEND ps_base TO gt_base.

        ELSE.

          DATA(lv_index) = sy-tabix.
          ls_base-fld_06 = ls_type-fld_06.
          ls_base-fld_01 = ls_type-fld_01.
          MODIFY gt_base  FROM ls_base  INDEX lv_index
                          TRANSPORTING fld_06 fld_01.

        ENDIF.

      ELSE.
        EXIT.
      ENDIF.
    ENDLOOP.
  ENDIF.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form get_data_for_create
*&---------------------------------------------------------------------*
FORM get_data_for_create .

**
  CHECK: gv_error IS INITIAL.

  PERFORM get_data_from_1081 .

* 신규 거래처 추가.
  PERFORM get_new_customer.

* SCR 8.0mm 자재코드 추출
  IF gt_kunnr[] IS NOT INITIAL.

    DATA(lv_spmon) = VALUE #( s_spmon[ 1 ]-low  OPTIONAL ).
    DATA(lv_vkorg) = VALUE #( s_vkorg[ 1 ]-low  OPTIONAL ).
    DATA(lv_vtweg) = VALUE #( s_vtweg[ 1 ]-low  OPTIONAL ).
    DATA(lv_spart) = VALUE #( s_spart[ 1 ]-low  OPTIONAL ).
    DATA(lv_vkbur) = VALUE #( s_vkbur[ 1 ]-low  OPTIONAL ).

    SELECT SINGLE a~matnr
      FROM mvke AS a  INNER JOIN mara AS b
                      ON a~matnr EQ b~matnr
     WHERE a~vkorg EQ @lv_vkorg
       AND b~spart EQ '10'    " @lv_spart
       AND b~lvorm EQ @abap_false
       AND a~vtweg EQ @lv_vtweg
      INTO @DATA(lv_matnr).

    LOOP AT gt_kunnr  INTO DATA(ls_kunnr).

      DATA(lv_chk) = VALUE #( gt_base[ kunnr = ls_kunnr-kunnr ]
                              OPTIONAL ).
      IF lv_chk IS INITIAL.

        CLEAR: gs_base.
        gs_base = VALUE #( spmon  = lv_spmon
                           vkorg  = lv_vkorg
                           vtweg  = lv_vtweg
                           spart  = lv_spart
                           vkbur  = lv_vkbur
                           kunnr  = ls_kunnr-kunnr
                           matnr  = lv_matnr
                           waers  = 'KRW' ).

        PERFORM modify_new_cust_data_to_base  USING: 'OEM'    gs_base,
                                                     'DIRECT' gs_base.

      ENDIF.

    ENDLOOP.

  ENDIF.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form get_new_customer
*&---------------------------------------------------------------------*
FORM get_new_customer .

  DATA: lv_date         LIKE sy-datlo,
        lv_fld_03       LIKE zgtppt1010-fld_03,
        lr_vkorg        TYPE RANGE OF zgtppt1010-fld_01,
        lr_credit_sgmnt TYPE RANGE OF ukmbp_cms_sgm-credit_sgmnt.

**
  CHECK: gv_error  IS INITIAL.

* Credit sgment
  CLEAR: lv_date.
  DATA(lv_spmon) = VALUE #( s_spmon[ 1 ]-low  OPTIONAL ).
  lv_date = lv_spmon && '01'.

  _clear: lr_vkorg.
  DATA(lv_vkorg) = VALUE #( s_vkorg[ 1 ]-low  OPTIONAL ).
  lr_vkorg = VALUE #( ( sign = 'I'  option = 'EQ'  low = lv_vkorg ) ).

  CLEAR: lv_fld_03.
  DATA(lv_vkbur) = VALUE #( s_vkbur[ 1 ]-low  OPTIONAL ).
  lv_fld_03 = condense( lv_vkbur ).

  SELECT fld_05
    FROM zgtppt1010  WHERE module_kind EQ 'SD'
                       AND codegrp     EQ '6005'
                       AND fld_01      IN @lr_vkorg
                       AND fld_03      EQ @lv_fld_03
                       AND fld_07      LE @lv_date
                       AND fld_08      GE @lv_date
    INTO TABLE @DATA(lt_fld_05).

  _clear: lr_credit_sgmnt.
  IF lt_fld_05[] IS NOT INITIAL.
    lr_credit_sgmnt = VALUE #( BASE lr_credit_sgmnt
                               FOR ls_05  IN lt_fld_05
                               ( sign = 'I'  option = 'EQ'
                                 low = ls_05-fld_05 ) ).
  ENDIF.

  IF lr_credit_sgmnt[] IS NOT INITIAL.

    SELECT a~customer AS kunnr
      FROM i_businesspartnercustomer AS a  INNER JOIN ukmbp_cms_sgm AS b
                                           ON a~businesspartner EQ b~partner
                                           INNER JOIN ukmbp_cms AS c
                                           ON b~partner EQ c~partner
     WHERE b~credit_sgmnt IN @lr_credit_sgmnt
       AND c~check_rule   NE 'GO_LOCAL'
      INTO CORRESPONDING FIELDS OF TABLE @gt_kunnr.

  ENDIF.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form modify_new_cust_data_to_base
*&---------------------------------------------------------------------*
FORM modify_new_cust_data_to_base  USING    pi_type
                                            ps_base   LIKE gs_base.

  DATA: lv_type  LIKE zgtppt1010-fld_01.

**
  CHECK: pi_type IS NOT INITIAL,
         ps_base IS NOT INITIAL.

  CLEAR: lv_type.
  lv_type = pi_type.

  READ TABLE gt_type  INTO DATA(ls_type)
                      WITH KEY fld_01 = lv_type
                      BINARY SEARCH.
  IF sy-subrc = 0.
    LOOP AT gt_type INTO ls_type  FROM sy-tabix.
      IF ls_type-fld_01 = lv_type.

        ps_base-kondm  = ls_type-fld_02.
        ps_base-kondmt = ls_type-fld_03.
        ps_base-fld_06 = ls_type-fld_06.
        ps_base-fld_01 = ls_type-fld_01.

        APPEND ps_base TO gt_base.

      ELSE.
        EXIT.
      ENDIF.
    ENDLOOP.
  ENDIF.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form get_descriptions
*&---------------------------------------------------------------------*
FORM get_descriptions .

**
  CHECK: gv_error  IS INITIAL,
         gt_base[] IS NOT INITIAL.

  DATA(lt_kunnr) = gt_base[].
  SORT: lt_kunnr BY kunnr.
  DELETE ADJACENT DUPLICATES FROM lt_kunnr COMPARING kunnr.

  DATA(lt_matnr) = gt_base[].
  SORT: lt_matnr BY matnr.
  DELETE ADJACENT DUPLICATES FROM lt_matnr COMPARING matnr.

  IF lt_kunnr[] IS NOT INITIAL.
    SELECT a~kunnr, b~name1
      FROM @lt_kunnr AS a  INNER JOIN kna1 AS b
                           ON a~kunnr EQ b~kunnr
      INTO TABLE @DATA(lt_kna1).
  ENDIF.

  IF lt_matnr[] IS NOT INITIAL.
    SELECT a~matnr, b~maktx
      FROM @lt_matnr AS a  INNER JOIN makt AS b
                           ON  a~matnr EQ b~matnr
                           AND b~spras EQ @sy-langu
      INTO TABLE @DATA(lt_makt).
  ENDIF.

  DATA(lt_base) = gt_base[].

  _clear: gt_base.
  gt_base[] = VALUE #( BASE gt_base
                       FOR ls_base  IN lt_base
                       ( VALUE #( BASE CORRESPONDING #( ls_base )
                                  name1 = VALUE #( lt_kna1[ kunnr = ls_base-kunnr ]-name1
                                                   OPTIONAL )
                                  maktx = VALUE #( lt_makt[ matnr = ls_base-matnr ]-maktx
                                                   OPTIONAL )
                                 )
                        )
                      ).

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form get_top_of_page_data
*&---------------------------------------------------------------------*
FORM get_top_of_page_data .

  DATA: lv_date   LIKE sy-datlo,
        lv_quosrc TYPE oic_source,
        lv_quotyp TYPE oic_quotyp,
        lv_quotno TYPE oic_quota.

**
  CHECK: gv_error  IS INITIAL,
         gt_base[] IS NOT INITIAL.

  CLEAR: lv_date.
  DATA(lv_spmon) = VALUE #( s_spmon[ 1 ]-low  OPTIONAL ).
  lv_date = lv_spmon && '01'.

  CLEAR: lv_quosrc, lv_quotyp, lv_quotno.
  lv_quosrc = 'NF'.
  lv_quotyp = 'M1LOP'.
  lv_quotno = 'CU KRW'.

  CLEAR: gs_head.
  SELECT SINGLE price, defcurr, defper, defuom
    FROM oicqp  WHERE quosrc   EQ @lv_quosrc
                  AND quotyp   EQ @lv_quotyp
                  AND quotno   EQ @lv_quotno
                  AND quotdate EQ @lv_date
    INTO CORRESPONDING FIELDS OF @gs_head.

  DATA(lv_vkbur) = VALUE #( s_vkbur[ 1 ]-low  OPTIONAL ).
  gs_head-spmon = lv_spmon.
  gs_head-vkbur = lv_vkbur.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form make_dynamic_fieldcat_and_itab
*&---------------------------------------------------------------------*
FORM make_dynamic_fieldcat_and_itab .

**
  CHECK: gv_error  IS INITIAL,
         gt_base[] IS NOT INITIAL.

  _clear: gt_fcat.
  PERFORM make_dynamic_fieldcatalog  USING  gt_fcat.

  PERFORM make_dynamic_itab          USING  gt_fcat.

  PERFORM modify_data_to_dynamic_itab.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form make_dynamic_fieldcatalog
*&---------------------------------------------------------------------*
FORM make_dynamic_fieldcatalog  USING    pt_fcat    TYPE lvc_t_fcat.

  DATA: lt_fieldcat TYPE lvc_t_fcat,
        lv_color    TYPE lvc_emphsz.

**
  _clear: lt_fieldcat.
  PERFORM get_field_catalog       USING    gt_base[]
                                  CHANGING lt_fieldcat.

  CLEAR: gv_pos.
** Make Dynamic Fieldcatalog.
* Key field.
  PERFORM make_dynamic_field
*         1: Ref Field, 2: Key, 3: Just, 4: Chg Field, 5: Field Text
          USING: lt_fieldcat  'KUNNR'  'X'  'C'  ' '  '거래처'    ' '  CHANGING pt_fcat,
                 lt_fieldcat  'NAME1'  'X'  ' '  ' '  '거래처명'  ' '  CHANGING pt_fcat,
                 lt_fieldcat  'MATNR'  'X'  'C'  ' '  '자재코드'  ' '  CHANGING pt_fcat,
                 lt_fieldcat  'MAKTX'  'X'  ' '  ' '  '자재명'    ' '  CHANGING pt_fcat,
                 lt_fieldcat  'WAERS'  'X'  ' '  ' '  '단위'      ' '  CHANGING pt_fcat.


  SORT: gt_type BY codeid.  " fld_01

  LOOP AT gt_type  INTO DATA(ls_type).

    CLEAR: lv_color.
    IF ls_type-fld_01 = 'OEM'.
      lv_color = 'C300'.
    ELSE.
      lv_color = 'C210'.
    ENDIF.

    PERFORM make_dynamic_field  USING:   lt_fieldcat
                                         'KBETR'
                                         ' '
                                         'R'
                                         ls_type-fld_02
                                         ls_type-fld_03
                                         lv_color
                                CHANGING pt_fcat.

  ENDLOOP.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form make_dynamic_field
*&---------------------------------------------------------------------*
FORM make_dynamic_field  USING    pt_ref_fcat  TYPE lvc_t_fcat
                                  pi_fname
                                  pi_key
                                  pi_just
                                  pi_chg_fname
                                  pi_text
                                  pi_color
                         CHANGING pt_fcat      TYPE lvc_t_fcat.

  DATA: ls_fcat     TYPE lvc_s_fcat.

**
  CLEAR: ls_fcat.
  ls_fcat = VALUE #( pt_ref_fcat[ fieldname = pi_fname ]  OPTIONAL ).

  IF ls_fcat IS NOT INITIAL.

    gv_pos = gv_pos + 1.

    CLEAR: ls_fcat-tech, ls_fcat-ref_field, ls_fcat-ref_table.

    IF pi_chg_fname IS NOT INITIAL.

      ls_fcat-fieldname   = pi_chg_fname.
*      ls_fcat-cfieldname  = 'WAERS'.
      ls_fcat-decimals_o  = 0.
      ls_fcat-outputlen   = 10.
      IF rb_crt = 'X'.
        ls_fcat-edit      = 'X'.
      ELSE.
        CLEAR: ls_fcat-edit.
      ENDIF.

    ELSE.
      ls_fcat-col_opt   = 'X'.
    ENDIF.

    ls_fcat-col_pos   = gv_pos.
    ls_fcat-key       = pi_key.
    ls_fcat-just      = pi_just.
*    ls_fcat-col_opt   = 'X'.
    ls_fcat-coltext   = ls_fcat-scrtext_s =
                        ls_fcat-scrtext_m =
                        ls_fcat-scrtext_l =
                        ls_fcat-reptext   = pi_text.

    IF pi_color IS NOT INITIAL.
      ls_fcat-emphasize = pi_color.
    ENDIF.

    IF ls_fcat-fieldname = 'WAERS'.
      ls_fcat-no_out = 'X'.
    ENDIF.

    APPEND ls_fcat TO pt_fcat.

  ENDIF.



ENDFORM.

*&---------------------------------------------------------------------*
*& Form make_dynamic_itab
*&---------------------------------------------------------------------*
FORM make_dynamic_itab  USING    pt_fcat  TYPE lvc_t_fcat.

  DATA: lo_data TYPE REF TO data,
        lo_wa   TYPE REF TO data.

**
  CHECK: pt_fcat[] IS NOT INITIAL.

  CALL METHOD cl_alv_table_create=>create_dynamic_table
    EXPORTING
      it_fieldcatalog = pt_fcat
    IMPORTING
      ep_table        = lo_data.

  UNASSIGN: <gt_list>, <gs_list>.

  ASSIGN lo_data->* TO <gt_list>.
  CREATE DATA lo_wa LIKE LINE OF <gt_list>.
  ASSIGN: lo_wa->* TO <gs_list>.

**
  FREE: lo_data, lo_wa.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form modify_data_to_dynamic_itab
*&---------------------------------------------------------------------*
FORM modify_data_to_dynamic_itab .

**
  CHECK: gv_error  IS INITIAL,
         gt_base[] IS NOT INITIAL,
         <gt_list> IS ASSIGNED.

  DATA(lt_temp) = gt_base[].
  SORT: lt_temp BY kunnr matnr,
        gt_base BY kunnr matnr fld_06 kondm.

  DELETE ADJACENT DUPLICATES FROM lt_temp COMPARING kunnr matnr.

  LOOP AT lt_temp  INTO DATA(ls_temp).

    READ TABLE gt_base  INTO DATA(ls_base)
                        WITH KEY kunnr = ls_temp-kunnr
                                 matnr = ls_temp-matnr
                        BINARY SEARCH.
    IF sy-subrc = 0.
      LOOP AT gt_base INTO ls_base  FROM sy-tabix.
        IF ls_base-kunnr = ls_temp-kunnr AND
           ls_base-matnr = ls_temp-matnr.

          PERFORM set_data_to_dynamic_field  USING: ls_base
                                                    'KBETR'  " From
                                                    ls_base-kondm.  " To

        ELSE.
          EXIT.
        ENDIF.
      ENDLOOP.
    ENDIF.

    ls_temp-kunnr = condense( |{ ls_temp-kunnr ALPHA = OUT }| ).
    _matn1_output: ls_temp-matnr  ls_temp-matnr.

    PERFORM set_data_to_dynamic_field  USING: ls_temp  'KUNNR' 'KUNNR',
                                              ls_temp  'NAME1' 'NAME1',
                                              ls_temp  'MATNR' 'MATNR',
                                              ls_temp  'MAKTX' 'MAKTX',
                                              ls_temp  'WAERS' 'WAERS'.

    APPEND <gs_list> TO <gt_list>.

  ENDLOOP.

**
  FREE: lt_temp.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form set_data_to_dynamic_field
*&---------------------------------------------------------------------*
FORM set_data_to_dynamic_field  USING    ps_base   LIKE gs_base
                                         pi_from
                                         pi_to.

**
  ASSIGN COMPONENT pi_from OF STRUCTURE ps_base   TO FIELD-SYMBOL(<lfs_from>).

  ASSIGN COMPONENT pi_to OF STRUCTURE <gs_list> TO FIELD-SYMBOL(<lfs_to>).

  IF <lfs_from> IS ASSIGNED AND
     <lfs_to>   IS ASSIGNED.

    IF pi_from = 'WAERS'.
      <lfs_to> = 'KRW'.
    ELSE.
      <lfs_to> = <lfs_from>.
    ENDIF.

  ENDIF.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form end_process
*&---------------------------------------------------------------------*
FORM end_process .

**
  CHECK: gv_error IS INITIAL.

  CLEAR: gv_line.
  IF gt_base[] IS NOT INITIAL.

*   Lock Object.
    IF gv_lock IS INITIAL.
      PERFORM control_lock_object    USING    'L'
                                              gv_lock
                                              sy-cprog
                                     CHANGING gv_error.
    ENDIF.

    IF gv_error IS INITIAL.

      DESCRIBE TABLE <gt_list> LINES gv_line.
*  IF gv_line > 0.
      CALL SCREEN 100.

    ENDIF.

  ELSE.
*   조건에 맞는 DATA가 없습니다.
    MESSAGE s018  DISPLAY LIKE 'E'.

  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form price_save
*&---------------------------------------------------------------------*
FORM price_save .

**
  PERFORM popup_to_confirm     USING    '단가정보 저장'
                                        '거래처별 SCR 8MM 가공비 단가를'
                                        '저장하시겠습니까?'
                               CHANGING gv_answer.
  IF gv_answer EQ 'J'.

    PERFORM modify_value_from_dynamic_itab.

    PERFORM save_data.

*  PERFORM refresh_data.

    IF gv_error IS INITIAL.
*     저장 되었습니다.
      MESSAGE s011.
    ELSE.
*     저장을 실패하였습니다.
      MESSAGE s012 DISPLAY LIKE 'E'.
    ENDIF.

  ELSE.
    gv_error = 'X'.
*   작업이 취소되었습니다.
    MESSAGE s050 .

  ENDIF.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form modify_value_from_dynamic_itab
*&---------------------------------------------------------------------*
FORM modify_value_from_dynamic_itab .

**
  DATA(lt_base) = gt_base[].
  SORT: lt_base BY kunnr matnr kondm.

  LOOP AT <gt_list>  INTO <gs_list>.

    ASSIGN COMPONENT: 'KUNNR' OF STRUCTURE <gs_list> TO FIELD-SYMBOL(<lfs_kunnr>),
                      'MATNR' OF STRUCTURE <gs_list> TO FIELD-SYMBOL(<lfs_matnr>).

    IF <lfs_kunnr> IS ASSIGNED AND
       <lfs_matnr> IS ASSIGNED.

      <lfs_kunnr> = |{ <lfs_kunnr> ALPHA = IN }|.
      _matn1_input: <lfs_matnr> <lfs_matnr>.

      READ TABLE lt_base  INTO DATA(ls_base)
                          WITH KEY kunnr = <lfs_kunnr>
                                   matnr = <lfs_matnr>
                          BINARY SEARCH.
      IF sy-subrc = 0.
        LOOP AT lt_base INTO ls_base  FROM sy-tabix.
          IF ls_base-kunnr = <lfs_kunnr> AND
             ls_base-matnr = <lfs_matnr>.

            ASSIGN COMPONENT ls_base-kondm OF STRUCTURE <gs_list> TO FIELD-SYMBOL(<lfs_kbetr>).
            IF <lfs_kbetr> IS ASSIGNED.

              ls_base-kbetr = <lfs_kbetr>.

              MODIFY gt_base  FROM VALUE #( kbetr = ls_base-kbetr )
                              TRANSPORTING kbetr
                              WHERE kunnr = ls_base-kunnr
                                AND matnr = ls_base-matnr
                                AND kondm = ls_base-kondm.

              UNASSIGN: <lfs_kbetr>.

            ENDIF.

          ELSE.
            EXIT.
          ENDIF.
        ENDLOOP.
      ENDIF.

    ENDIF.

  ENDLOOP.

**
  FREE: lt_base.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form save_data
*&---------------------------------------------------------------------*
FORM save_data .

  DATA: lt_data TYPE TABLE OF zgtsdt1030,
        lt_temp TYPE TABLE OF zgtsdt1030.

**
  _clear: lt_data, lt_temp.

  DATA(lt_base) = gt_base[].

  SELECT b~*
    FROM @lt_base AS a  INNER JOIN zgtsdt1030 AS b
                        ON  a~spmon EQ b~spmon
                        AND a~vkorg EQ b~vkorg
                        AND a~kunnr EQ b~kunnr
                        AND a~matnr EQ b~matnr
*                        AND a~kondm EQ b~kondm
    INTO CORRESPONDING FIELDS OF TABLE @lt_temp.

* 삭제된 가공비유형정리를 위해 기존 Data 삭제 후 다시 저장.
  IF lt_temp[] IS NOT INITIAL.
    DELETE zgtsdt1030  FROM TABLE lt_temp[].
  ENDIF.
*

  LOOP AT lt_base  INTO DATA(ls_base).

    DATA(ls_temp) = VALUE #( lt_temp[ spmon = ls_base-spmon
                                      kunnr = ls_base-kunnr
                                      matnr = ls_base-matnr
                                      kondm = ls_base-kondm ]
                             OPTIONAL ).

    APPEND VALUE #( BASE CORRESPONDING #( ls_base )
                    kpein = p_kpein
                    kmein = p_kmein
                    erdat = COND #( WHEN ls_temp-erdat IS NOT INITIAL
                                         THEN ls_temp-erdat
                                    ELSE sy-datlo )
                    erzet = COND #( WHEN ls_temp-erzet IS NOT INITIAL
                                         THEN ls_temp-erzet
                                    ELSE sy-timlo )
                    ernam = COND #( WHEN ls_temp-ernam IS NOT INITIAL
                                         THEN ls_temp-ernam
                                    ELSE sy-uname )
                    aedat = COND #( WHEN ls_temp-erdat IS NOT INITIAL
                                         THEN sy-datlo
                                    ELSE space )
                    aezet = COND #( WHEN ls_temp-erzet IS NOT INITIAL
                                         THEN sy-timlo
                                    ELSE space )
                    aenam = COND #( WHEN ls_temp-ernam IS NOT INITIAL
                                         THEN sy-uname
                                    ELSE space )
                   ) TO lt_data.
  ENDLOOP.

  IF lt_data[] IS NOT INITIAL.

    MODIFY zgtsdt1030 FROM TABLE lt_data[].
    IF sy-subrc = 0.
      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
        EXPORTING
          wait = 'X'.

*     저장 되었습니다.
      MESSAGE s011.

    ELSE.
      CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

      gv_error = 'X'.
*     저장을 실패하였습니다.
      MESSAGE s012 DISPLAY LIKE 'E'.

    ENDIF.

  ENDIF.

**
  FREE: lt_base, lt_temp, lt_data.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form refresh_data
*&---------------------------------------------------------------------*
FORM refresh_data .

**
  CHECK: gv_error IS INITIAL.

  CLEAR: rb_crt.    " 생성.
  rb_dis = 'X'.     " 조회

  _clear: gt_base.
  PERFORM get_data_from_1081 .

  PERFORM get_descriptions.

  _clear: <gt_list>.
  PERFORM modify_data_to_dynamic_itab.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form call_nf_disp
*&---------------------------------------------------------------------*
FORM call_nf_disp .

**
  CHECK: s_spmon[] IS NOT INITIAL.

  SUBMIT znfr0002 AND RETURN
                  WITH s_inmon  IN s_spmon.

**

ENDFORM.
