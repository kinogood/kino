*&---------------------------------------------------------------------*
*& Include          ZGTLER1150F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form initialization
*&---------------------------------------------------------------------*
FORM initialization .

**
* 출고요청일.
  IF s_wadat[] IS INITIAL.
    DATA(lv_tdate) = sy-datlo + 1.
    s_wadat[] = VALUE #( ( sign = 'I'  option = 'BT'
                            low = sy-datlo  high = lv_tdate ) ).
  ENDIF.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form check_input
*&---------------------------------------------------------------------*
FORM check_input  USING    p_area.

**
  CHECK: p_area IS NOT INITIAL.

  SELECT SINGLE @abap_true  INTO @DATA(lv_chk)
    FROM zlet0033  WHERE bzarea EQ @p_area.

  IF sy-subrc NE 0 OR lv_chk IS INITIAL.

    SELECT SINGLE @abap_true  INTO @lv_chk
      FROM zlet0072  WHERE bzarea EQ @p_area.

    IF sy-subrc NE 0 OR lv_chk IS INITIAL.
*     존재하지 않는 사업장입니다
      MESSAGE e000 WITH TEXT-e01.
    ENDIF.

  ENDIF.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form authority_check
*&---------------------------------------------------------------------*
FORM authority_check .

  DATA: lv_subrc LIKE sy-subrc,
        lv_type  TYPE char1.

**
* 1) 사업장 Check.
  CLEAR: lv_subrc, lv_type.
  lv_type = '5'.
  CALL FUNCTION 'ZGTLE_AUTHORIZATION_CHECK'
    EXPORTING
      i_bzarea = p_bzarea
      i_type   = lv_type
    IMPORTING
      e_subrc  = lv_subrc.

  IF lv_subrc <> 0.
*   사업장 &1 에 대한 권한이 없습니다.
    MESSAGE e016 WITH p_bzarea.

  ENDIF.

* 1) 출하지점 Check.
  SELECT *  INTO TABLE @DATA(lt_tvst)
    FROM tvst  WHERE vstel IN @s_vstel.

  CLEAR: lv_type .
  lv_type = '3'.

  LOOP AT lt_tvst  INTO DATA(ls_tvst).

    CLEAR : lv_subrc.
    CALL FUNCTION 'Z_LE_AUTHORIZATION_CHECK'
      EXPORTING
        i_vstel = ls_tvst-vstel
        i_type  = lv_type
      IMPORTING
        e_subrc = lv_subrc.

    IF lv_subrc <> 0.
*     출하지점 &1에 대한 권한이 없습니다.
      MESSAGE e019 WITH ls_tvst-vstel.
      EXIT.
    ENDIF.

  ENDLOOP.

**
  FREE: lt_tvst.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form modify_screen_1000
*&---------------------------------------------------------------------*
FORM modify_screen_1000 .

**
  LOOP AT SCREEN.

    IF rb_vl = 'X'.    " 납품기준
      IF screen-name = 'S_TKNUM-LOW' OR
         screen-name = 'S_TKNUM-HIGH'.
        screen-input = 0.
      ENDIF.
    ENDIF.

    IF rb_new = 'X'.    " 신규발행
      IF screen-name = 'S_IV_NO-LOW' OR
         screen-name = 'S_IV_NO-HIGH' OR
         screen-name = 'S_DATE-LOW' OR
         screen-name = 'S_DATE-HIGH'.
        screen-input = 0.
      ENDIF.
    ENDIF.

*    IF rb_sto = 'X'.    " STO
*      p_vl = 'X'.    " 발행시 납품문서기준으로 출력됨
*    ELSE.
*      p_vl = space.
*    ENDIF.

**   자동차부품 외부창고 추가
*    IF gv_bzarea = 'X'.
*      CASE screen-name.
*        WHEN 'P_BZAREA' OR 'S_VSTEL-LOW' OR 'S_VSTEL-HIGH'.
*          screen-input = 0.
*      ENDCASE.
*    ENDIF.

    MODIFY SCREEN.

  ENDLOOP.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form start_process
*&---------------------------------------------------------------------*
FORM start_process .

**
  CLEAR: gv_error.

* 1) Check, 출고일 or 출고요청일
  PERFORM check_input_date_field .

* 2) Get Data.
  PERFORM selection.

* 3) Make Display List.
  PERFORM make_display_list.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form check_input_date_field
*&---------------------------------------------------------------------*
FORM check_input_date_field .

**
  CLEAR: gv_wadat_s, gv_wadat_t,
         gv_wadat_ist_s, gv_wadat_ist_t.

  IF s_wadat[]  IS INITIAL AND    " 출고요청일
     s_wdtist[] IS INITIAL.       " 출고일
*   출고요청일 ( or 출고일 ) 은 필수입니다.
    MESSAGE s000 WITH TEXT-e02   DISPLAY LIKE 'E'.
    gv_error = 'X'.

  ELSE.

    gv_wadat_s     = VALUE #( s_wadat[ 1 ]-low    OPTIONAL ).
    gv_wadat_t     = VALUE #( s_wadat[ 1 ]-high   OPTIONAL ).
    gv_wadat_ist_s = VALUE #( s_wdtist[ 1 ]-low   OPTIONAL ).
    gv_wadat_ist_t = VALUE #( s_wdtist[ 1 ]-high  OPTIONAL ).

  ENDIF.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form selection
*&---------------------------------------------------------------------*
FORM selection .

**
  CHECK: gv_error IS INITIAL.

*/ LIKP-ZOUT = 'X'   "통문확정없이 빌링 가능
*  LIKP-ZOUT = 'Y'   "통문확정

* 1) Set Range values.
  PERFORM setting_ranges              USING p_bzarea.

* 2) Get data.
  PERFORM get_base_data_from_rb.

* 3) Modify Data.
  PERFORM data_modify .

  SORT gt_data.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form setting_ranges
*&---------------------------------------------------------------------*
FORM setting_ranges  USING    pi_bzarea.

**
* 납품 유형
  _clear: gr_lfart.
  IF     rb_so = 'X'.
    PERFORM set_ranges_lfart USING: 'LF',  'LF2', 'LF4', 'LF5',  'LF6',
                                    'LF7', 'LF8', 'LF9', 'LF10', 'ZLF7',
                                    'LR',  'LR1', 'LR2', 'LR3'.
  ELSEIF rb_sto = 'X'.
    PERFORM set_ranges_lfart USING: 'NL'.
  ELSE.
    PERFORM set_ranges_lfart USING: 'LF',  'LF2', 'LF4', 'LF5',  'LF6',
                                    'LF7', 'LF8', 'LF9', 'LF10', 'ZLF7',
                                    'LR',  'LR1', 'LR2', 'LR3',  'NL'.
  ENDIF.

* Route 제외
  _clear: gr_route.
  gr_route[] = VALUE #( BASE gr_route
                        ( sign = 'I'  option = 'NE'  low = '14-001' )
                        ( sign = 'I'  option = 'NE'  low = '15-001' )
                        ( sign = 'I'  option = 'NE'  low = '16-001' ) ).

* 출하지점
  _clear: gr_vstel.
  SELECT 'I'   AS sign,
         'EQ'  AS option,
         vstel AS low
    INTO CORRESPONDING FIELDS OF TABLE @gr_vstel
    FROM zlet0033  WHERE bzarea EQ @pi_bzarea.

* 저장위치
  _clear: gr_lgort.
  IF s_lgort[] IS NOT INITIAL.
    gr_lgort[] = CORRESPONDING #( s_lgort[] ).
*  ELSE.
*    SELECT 'I'   AS sign,
*           'EQ'  AS option,
*           lgort AS low
*      INTO CORRESPONDING FIELDS OF TABLE @gr_lgort
*      FROM zlet0072 WHERE bzarea EQ @pi_bzarea.
  ENDIF.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form set_ranges_lfart
*&---------------------------------------------------------------------*
FORM set_ranges_lfart  USING    pi_lfart.

**
  CHECK: pi_lfart IS NOT INITIAL.

  gr_lfart[] = VALUE #( BASE gr_lfart
                        ( sign = 'I'option = 'EQ'  low = pi_lfart ) ).

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form get_base_data_from_rb
*&---------------------------------------------------------------------*
FORM get_base_data_from_rb .

**
  CHECK: gv_error IS INITIAL.

  _clear: gt_data.
  IF     rb_vl = 'X'.  " 납품문서 기준

    IF rb_new = 'X'.   " 신규발행
      PERFORM get_data_vl_new .
    ELSE.
      PERFORM get_data_vbeln_others .
    ENDIF.

  ELSEIF rb_tk = 'X'.  " 선적문서 기준

    IF rb_new = 'X'.   " 신규발행
      PERFORM get_data_tknum_new .
    ELSE.
      PERFORM get_data_tknum_others .
    ENDIF.

  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form get_data_vl_new
*&---------------------------------------------------------------------*
FORM get_data_vl_new .

**
  CHECK: gv_error IS INITIAL.

  SELECT a~kunnr, a~route, a~lfart, a~vsart, a~wadat, a~wadat_ist,
         a~vbtyp, a~vstel, a~kunag, a~wbstk, a~lifsk,
         b~vbeln, b~posnr, b~werks, b~matnr, b~arktx, b~lfimg, b~vrkme,
         b~charg, b~meins, b~vgbel, b~vgpos, b~umvkz, b~umvkn, b~lgort,
         b~vkbur, b~vkgrp, b~vtweg, b~spart, b~mtart, b~ntgew, b~gewei
    INTO CORRESPONDING FIELDS OF TABLE @gt_data
    FROM likp AS a  INNER JOIN lips AS b
                    ON  a~vbeln = b~vbeln
   WHERE a~vbeln     IN @s_vl
     AND a~lifsk     NE 'G3'
     AND a~lfart     IN @gr_lfart
     AND a~vstel     IN @s_vstel
     AND a~vstel     IN @gr_vstel
     AND a~wadat     IN @s_wadat
     AND a~wadat_ist IN @s_wdtist
     AND a~kunag     IN @s_kunag
*     AND a~kunnr     IN @s_kunnr
     AND a~ernam     IN @s_ernam
     AND a~route     IN @s_route
     AND a~route     IN @gr_route
     AND a~vsart     IN @s_vsart
     AND b~vgbel     IN @s_va
     AND b~vkbur     IN @s_vkbur
     AND b~vkgrp     IN @s_vkgrp
     AND b~vtweg     IN @s_vtweg
     AND b~uecha     EQ '000000'
     AND b~lgort     IN @gr_lgort.

* 적송대상(LIFSK = 'G3') Data Get.
  SELECT a~lifsk,
         b~kunnr, b~route, b~lfart, b~vsart, b~wadat, b~wadat_ist,
         b~vbtyp, b~vstel, b~kunag, b~wbstk, " b~lifsk,
         c~vbeln, c~posnr, c~werks, c~matnr, c~arktx, c~lfimg, c~vrkme,
         c~charg, c~meins, c~vgbel, c~vgpos, c~umvkz, c~umvkn, c~lgort,
         c~vkbur, c~vkgrp, c~vtweg, c~spart, c~mtart, c~ntgew, c~gewei
    APPENDING CORRESPONDING FIELDS OF TABLE @gt_data
    FROM likp AS a  INNER JOIN zgtsdt9110 AS b
                    ON  a~vbeln = b~vbeln
                    INNER JOIN zgtsdt9120 AS c
                    ON  b~vbeln = c~vbeln
   WHERE a~vbeln     IN @s_vl
     AND a~lifsk     EQ 'G3'
     AND b~lfart     IN @gr_lfart
     AND b~vstel     IN @s_vstel
     AND b~vstel     IN @gr_vstel
     AND b~wadat     IN @s_wadat
     AND b~wadat_ist IN @s_wdtist
     AND b~kunag     IN @s_kunag
*     AND b~kunnr     IN @s_kunnr
     AND b~ernam     IN @s_ernam
     AND b~route     IN @s_route
     AND b~route     IN @gr_route
     AND b~vsart     IN @s_vsart
     AND c~vgbel     IN @s_va
     AND c~vkbur     IN @s_vkbur
     AND c~vkgrp     IN @s_vkgrp
     AND c~vtweg     IN @s_vtweg
     AND c~uecha     EQ '000000'
     AND c~lgort     IN @gr_lgort.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form get_data_vbeln_others
*&---------------------------------------------------------------------*
FORM get_data_vbeln_others .

**
  CHECK: gv_error IS INITIAL.

  SELECT a~kunnr, a~route, a~lfart, a~vsart, a~wadat, a~wadat_ist,
         a~vbtyp, a~vstel, a~kunag, a~wbstk, a~lifsk,
         b~vbeln, b~posnr, b~werks, b~matnr, b~arktx, b~lfimg, b~vrkme,
         b~charg, b~meins, b~vgbel, b~vgpos, b~umvkz, b~umvkn, b~lgort,
         b~vkbur, b~vkgrp, b~vtweg, b~spart, b~mtart, b~ntgew, b~gewei,
         c~tknum,
         d~iv_no, d~iv_date
    INTO CORRESPONDING FIELDS OF TABLE @gt_data
    FROM likp AS a  INNER JOIN lips AS b
                    ON  a~vbeln = b~vbeln
                    INNER JOIN zlet0006 AS c
                    ON  a~vbeln = c~vbeln
                    AND b~posnr = c~posnr
                    INNER JOIN zlet0005 AS d
                    ON  c~iv_no = d~iv_no
   WHERE a~vbeln        IN @s_vl
     AND a~lifsk        NE 'G3'
     AND a~lfart        IN @gr_lfart
     AND a~vstel        IN @s_vstel
     AND a~vstel        IN @gr_vstel
     AND a~wadat        IN @s_wadat
     AND a~wadat_ist    IN @s_wdtist
     AND a~kunag        IN @s_kunag
*     AND a~kunnr        IN @s_kunnr
     AND a~ernam        IN @s_ernam
     AND a~route        IN @s_route
     AND a~route        IN @gr_route
     AND b~vgbel        IN @s_va
     AND b~vkbur        IN @s_vkbur
     AND b~vkgrp        IN @s_vkgrp
     AND b~vtweg        IN @s_vtweg
     AND b~uecha        EQ '000000'
     AND d~iv_print_yn  EQ 'X'   "거래명세서 발행여부
     AND d~iv_cancel_yn EQ ' '   "거래명세서 취소여부
     AND d~iv_date      IN @s_date
     AND d~iv_no        IN @s_iv_no
     AND d~bzarea       EQ @p_bzarea
     AND b~lgort        IN @gr_lgort
     AND a~vsart        IN @s_vsart.

* 적송대상(LIFSK = 'G3') Data Get.
  SELECT a~lifsk,
         b~kunnr, b~route, b~lfart, b~vsart, b~wadat, b~wadat_ist,
         b~vbtyp, b~vstel, b~kunag, b~wbstk, " b~lifsk,
         c~vbeln, c~posnr, c~werks, c~matnr, c~arktx, c~lfimg, c~vrkme,
         c~charg, c~meins, c~vgbel, c~vgpos, c~umvkz, c~umvkn, c~lgort,
         c~vkbur, c~vkgrp, c~vtweg, c~spart, c~mtart, c~ntgew, c~gewei,
         d~tknum,
         e~iv_no, e~iv_date
    APPENDING CORRESPONDING FIELDS OF TABLE @gt_data
    FROM likp AS a  INNER JOIN zgtsdt9110 AS b
                    ON  a~vbeln = b~vbeln
                    INNER JOIN zgtsdt9120 AS c
                    ON  b~vbeln = c~vbeln
                    INNER JOIN zlet0006 AS d
                    ON  c~vbeln = d~vbeln
                    AND c~posnr = d~posnr
                    INNER JOIN zlet0005 AS e
                    ON  d~iv_no = e~iv_no
   WHERE a~vbeln        IN @s_vl
     AND a~lifsk        EQ 'G3'
     AND b~lfart        IN @gr_lfart
     AND b~vstel        IN @s_vstel
     AND b~vstel        IN @gr_vstel
     AND b~wadat        IN @s_wadat
     AND b~wadat_ist    IN @s_wdtist
     AND b~kunag        IN @s_kunag
*     AND b~kunnr        IN @s_kunnr
     AND b~ernam        IN @s_ernam
     AND b~route        IN @s_route
     AND b~route        IN @gr_route
     AND c~vgbel        IN @s_va
     AND c~vkbur        IN @s_vkbur
     AND c~vkgrp        IN @s_vkgrp
     AND c~vtweg        IN @s_vtweg
     AND c~uecha        EQ '000000'
     AND e~iv_print_yn  EQ 'X'   "거래명세서 발행여부
     AND e~iv_cancel_yn EQ ' '   "거래명세서 취소여부
     AND e~iv_date      IN @s_date
     AND e~iv_no        IN @s_iv_no
     AND e~bzarea       EQ @p_bzarea
     AND c~lgort        IN @gr_lgort
     AND b~vsart        IN @s_vsart.

* 선적문서번호가 있으면 대상에서 제외
  DELETE gt_data WHERE tknum IS NOT INITIAL.

  DATA(lt_temp) = gt_data[].
  IF lt_temp[] IS NOT INITIAL.
    SORT lt_temp BY vbeln.
    DELETE ADJACENT DUPLICATES FROM lt_temp COMPARING vbeln.
    SELECT vbeln,posnr,uecha,ntgew,gewei
      FROM lips
       FOR ALL ENTRIES IN @lt_temp
     WHERE vbeln EQ @lt_temp-vbeln
      INTO TABLE @DATA(lt_lips).
    LOOP AT gt_data ASSIGNING FIELD-SYMBOL(<fs_data>).
      IF line_exists( lt_lips[ vbeln = <fs_data>-vbeln posnr = <fs_data>-posnr ] ).
        CLEAR: <fs_data>-ntgew.
        LOOP AT lt_lips INTO DATA(ls_lips) WHERE vbeln = <fs_data>-vbeln
                                             AND ( posnr = <fs_data>-posnr OR
                                                   uecha = <fs_data>-posnr    ).
          <fs_data>-ntgew = <fs_data>-ntgew + ls_lips-ntgew.
          <fs_data>-gewei = ls_lips-gewei.
        ENDLOOP.
      ENDIF.
    ENDLOOP.
  ENDIF.

**
  FREE:lt_temp.
ENDFORM.

*&---------------------------------------------------------------------*
*& Form get_data_tknum_new
*&---------------------------------------------------------------------*
FORM get_data_tknum_new .

**
  CHECK: gv_error IS INITIAL.

  SELECT a~tknum, a~exti2, a~exti1, a~tpbez, a~shtyp, a~tdlnr, a~sdabw,
         c~kunnr, c~route, c~lfart, c~vsart, c~wadat, c~wadat_ist,
         c~vbtyp, c~vstel, c~kunag, c~wbstk, c~lifsk,
         d~vbeln, d~posnr, d~werks, d~matnr, d~arktx, d~lfimg, d~vrkme,
         d~charg, d~meins, d~vgbel, d~vgpos, d~umvkz, d~umvkn, d~lgort,
         d~vkbur, d~vkgrp, d~vtweg, d~spart, d~mtart, d~ntgew, d~gewei
    INTO CORRESPONDING FIELDS OF TABLE @gt_data
    FROM vttk AS a  INNER JOIN vttp AS b
                    ON a~tknum = b~tknum
                    INNER JOIN likp AS c
                    ON b~vbeln = c~vbeln
                    INNER JOIN lips AS d
                    ON c~vbeln = d~vbeln
     WHERE a~tknum IN @s_tknum
       AND a~shtyp     NOT IN ('Z002', 'Z009', 'Z103')
       AND b~vbeln     IN @s_vl
       AND c~lifsk     NE 'G3'
       AND c~lfart     IN @gr_lfart
       AND c~vstel     IN @s_vstel
       AND c~vstel     IN @gr_vstel
       AND c~wadat     IN @s_wadat
       AND c~wadat_ist IN @s_wdtist
       AND c~kunag     IN @s_kunag
*       AND c~kunnr     IN @s_kunnr
       AND c~ernam     IN @s_ernam
       AND c~route     IN @s_route
       AND c~route     IN @gr_route
       AND d~vgbel     IN @s_va
       AND d~vkbur     IN @s_vkbur
       AND d~vkgrp     IN @s_vkgrp
       AND d~vtweg     IN @s_vtweg
       AND d~uecha     EQ '000000'
       AND d~lgort     IN @gr_lgort
       AND c~vsart     IN @s_vsart.

* 적송대상(LIFSK = 'G3') Data Get.
  SELECT a~tknum, a~exti2, a~exti1, a~tpbez, a~shtyp, a~tdlnr, a~sdabw,
         c~lifsk,
         d~kunnr, d~route, d~lfart, d~vsart, d~wadat, d~wadat_ist,
         d~vbtyp, d~vstel, d~kunag, d~wbstk, " d~lifsk,
         e~vbeln, e~posnr, e~werks, e~matnr, e~arktx, e~lfimg, e~vrkme,
         e~charg, e~meins, e~vgbel, e~vgpos, e~umvkz, e~umvkn, e~lgort,
         e~vkbur, e~vkgrp, e~vtweg, e~spart, e~mtart, e~ntgew, e~gewei
    APPENDING CORRESPONDING FIELDS OF TABLE @gt_data
    FROM vttk AS a  INNER JOIN vttp AS b
                    ON a~tknum = b~tknum
                    INNER JOIN likp AS c
                    ON b~vbeln = c~vbeln
                    INNER JOIN zgtsdt9110 AS d
                    ON c~vbeln = d~vbeln
                    INNER JOIN zgtsdt9120 AS e
                    ON c~vbeln = e~vbeln
     WHERE a~tknum IN @s_tknum
       AND a~shtyp     NOT IN ('Z002', 'Z009', 'Z103')
       AND b~vbeln     IN @s_vl
       AND c~lifsk     EQ 'G3'
       AND d~lfart     IN @gr_lfart
       AND d~vstel     IN @s_vstel
       AND d~vstel     IN @gr_vstel
       AND d~wadat     IN @s_wadat
       AND d~wadat_ist IN @s_wdtist
       AND d~kunag     IN @s_kunag
*       AND d~kunnr     IN @s_kunnr
       AND d~ernam     IN @s_ernam
       AND d~route     IN @s_route
       AND d~route     IN @gr_route
       AND e~vgbel     IN @s_va
       AND e~vkbur     IN @s_vkbur
       AND e~vkgrp     IN @s_vkgrp
       AND e~vtweg     IN @s_vtweg
       AND e~uecha     EQ '000000'
       AND e~lgort     IN @gr_lgort
       AND d~vsart     IN @s_vsart.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form get_data_tknum_others
*&---------------------------------------------------------------------*
FORM get_data_tknum_others .

  SELECT a~tknum, a~exti2, a~exti1, a~tpbez, a~shtyp, a~tdlnr, a~sdabw,
         c~kunnr, c~route, c~lfart, c~vsart, c~wadat, c~wadat_ist,
         c~vbtyp, c~vstel, c~kunag, c~wbstk, c~lifsk,
         d~vbeln, d~posnr, d~werks, d~matnr, d~arktx, d~lfimg, d~vrkme,
         d~charg, d~meins, d~vgbel, d~vgpos, d~umvkz, d~umvkn, d~lgort,
         d~vkbur, d~vkgrp, d~vtweg, d~spart, d~mtart, d~ntgew, d~gewei,
         f~iv_no, f~iv_date
    INTO CORRESPONDING FIELDS OF TABLE @gt_data
    FROM vttk AS a  INNER JOIN vttp AS b
                    ON  a~tknum = b~tknum
                    INNER JOIN likp AS c
                    ON  b~vbeln = c~vbeln
                    INNER JOIN lips AS d
                    ON  c~vbeln = d~vbeln
                    INNER JOIN zlet0006 AS e
                    ON  d~vbeln = e~vbeln
                    AND d~posnr = e~posnr
                    AND a~tknum = e~tknum
                    INNER JOIN zlet0005 AS f
                    ON  e~iv_no = f~iv_no
     WHERE a~tknum        IN @s_tknum
       AND a~shtyp        NOT IN ('Z002', 'Z009', 'Z103')          ", 'Z007')
       AND b~vbeln        IN @s_vl
       AND c~lifsk        NE 'G3'
       AND c~lfart        IN @gr_lfart
       AND c~vstel        IN @s_vstel
       AND c~vstel        IN @gr_vstel
       AND c~wadat        IN @s_wadat
       AND c~wadat_ist    IN @s_wdtist
       AND c~kunag        IN @s_kunag
*       AND c~kunnr        IN @s_kunnr
       AND c~ernam        IN @s_ernam
       AND c~route        IN @s_route
       AND c~route        IN @gr_route
       AND d~vgbel        IN @s_va
       AND d~vkbur        IN @s_vkbur
       AND d~vkgrp        IN @s_vkgrp
       AND d~vtweg        IN @s_vtweg
       AND d~uecha        EQ '000000'
       AND f~iv_print_yn  EQ 'X'   "거래명세서 발행여부
       AND f~iv_cancel_yn EQ ' '   "거래명세서 취소여부
       AND f~iv_date      IN @s_date
       AND f~iv_no        IN @s_iv_no
       AND f~bzarea       EQ @p_bzarea
       AND d~lgort        IN @gr_lgort
       AND c~vsart        IN @s_vsart.

* 적송대상(LIFSK = 'G3') Data Get.
  SELECT a~tknum, a~exti2, a~exti1, a~tpbez, a~shtyp, a~tdlnr, a~sdabw,
         c~lifsk,
         d~kunnr, d~route, d~lfart, d~vsart, d~wadat, d~wadat_ist,
         d~vbtyp, d~vstel, d~kunag, d~wbstk, " d~lifsk,
         e~vbeln, e~posnr, e~werks, e~matnr, e~arktx, e~lfimg, e~vrkme,
         e~charg, e~meins, e~vgbel, e~vgpos, e~umvkz, e~umvkn, e~lgort,
         e~vkbur, e~vkgrp, e~vtweg, e~spart, e~mtart, e~ntgew, e~gewei,
         g~iv_no, g~iv_date
    APPENDING CORRESPONDING FIELDS OF TABLE @gt_data
    FROM vttk AS a  INNER JOIN vttp AS b
                    ON  a~tknum = b~tknum
                    INNER JOIN likp AS c
                    ON  b~vbeln = c~vbeln
                    INNER JOIN zgtsdt9110 AS d
                    ON  c~vbeln = d~vbeln
                    INNER JOIN zgtsdt9120 AS e
                    ON  c~vbeln = e~vbeln
                    INNER JOIN zlet0006 AS f
                    ON  e~vbeln = f~vbeln
                    AND e~posnr = f~posnr
                    AND a~tknum = f~tknum
                    INNER JOIN zlet0005 AS g
                    ON  f~iv_no = g~iv_no
     WHERE a~tknum        IN @s_tknum
       AND a~shtyp        NOT IN ('Z002', 'Z009', 'Z103')          ", 'Z007')
       AND b~vbeln        IN @s_vl
       AND c~lifsk        EQ 'G3'
       AND d~lfart        IN @gr_lfart
       AND d~vstel        IN @s_vstel
       AND d~vstel        IN @gr_vstel
       AND d~wadat        IN @s_wadat
       AND d~wadat_ist    IN @s_wdtist
       AND d~kunag        IN @s_kunag
*       AND d~kunnr        IN @s_kunnr
       AND d~ernam        IN @s_ernam
       AND d~route        IN @s_route
       AND d~route        IN @gr_route
       AND e~vgbel        IN @s_va
       AND e~vkbur        IN @s_vkbur
       AND e~vkgrp        IN @s_vkgrp
       AND e~vtweg        IN @s_vtweg
       AND e~uecha        EQ '000000'
       AND g~iv_print_yn  EQ 'X'   "거래명세서 발행여부
       AND g~iv_cancel_yn EQ ' '   "거래명세서 취소여부
       AND g~iv_date      IN @s_date
       AND g~iv_no        IN @s_iv_no
       AND g~bzarea       EQ @p_bzarea
       AND e~lgort        IN @gr_lgort
       AND d~vsart        IN @s_vsart.

** (2026.07.30) 납품문서 하나에 여러개의 선적문서가 있는 경우 Check.
*  PERFORM get_data_multi_tknum_others.

  DATA(lt_temp) = gt_data[].
  IF lt_temp[] IS NOT INITIAL.
    SORT lt_temp BY vbeln.
    DELETE ADJACENT DUPLICATES FROM lt_temp COMPARING vbeln.
    SELECT vbeln,posnr,uecha,ntgew,gewei
      FROM lips
       FOR ALL ENTRIES IN @lt_temp
     WHERE vbeln EQ @lt_temp-vbeln
      INTO TABLE @DATA(lt_lips).
    LOOP AT gt_data ASSIGNING FIELD-SYMBOL(<fs_data>).
      IF line_exists( lt_lips[ vbeln = <fs_data>-vbeln posnr = <fs_data>-posnr ] ).
        CLEAR: <fs_data>-ntgew.
        LOOP AT lt_lips INTO DATA(ls_lips) WHERE vbeln = <fs_data>-vbeln
                                             AND ( posnr = <fs_data>-posnr OR
                                                   uecha = <fs_data>-posnr    ).
          <fs_data>-ntgew = <fs_data>-ntgew + ls_lips-ntgew.
          <fs_data>-gewei = ls_lips-gewei.
        ENDLOOP.
      ENDIF.
    ENDLOOP.
  ENDIF.

**
  FREE:lt_temp.
ENDFORM.

*&---------------------------------------------------------------------*
*& Form data_modify
*&---------------------------------------------------------------------*
FORM data_modify .

**
  CHECK: gv_error  IS INITIAL,
         gt_data[] IS NOT INITIAL.

* 1) Data validation Check.
  PERFORM check_data_validation .

* 2) Modify infomation data
  PERFORM modify_infomation_data .

* 3) 다중배차시 거래명세서 발행수정
  IF     p_bzarea = '5000' AND rb_tk = 'X' AND rb_new = 'X'.
    SORT: gt_data BY vbeln posnr.
    DELETE ADJACENT DUPLICATES FROM gt_data COMPARING vbeln posnr.

  ELSEIF p_bzarea = '6000'.
    SORT: gt_data BY empst vgbel vgpos.

  ENDIF.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form check_data_validation
*&---------------------------------------------------------------------*
FORM check_data_validation .

**
  CHECK: gv_error  IS INITIAL,
         gt_data[] IS NOT INITIAL,
         rb_new    EQ 'X'.  "신규발행

  DATA(lt_data) = gt_data[].
  SORT: lt_data BY vbeln tknum.
  DELETE ADJACENT DUPLICATES FROM lt_data COMPARING vbeln tknum.

  LOOP AT lt_data  INTO DATA(ls_data).

    IF     rb_vl = 'X'.    " 납품문서 기준 신규발행 조건 점검
*_____발행여부 Check.
      SELECT SINGLE @abap_true  INTO @DATA(lv_chk)
        FROM zlet0005 AS k  INNER JOIN zlet0006 AS p
                            ON k~iv_no = p~iv_no
       WHERE k~iv_print_yn  EQ  'X'    "거래명세서 발행여부
         AND k~iv_cancel_yn EQ ' '     "거래명세서 취소여부
         AND k~iv_type      NE 'L01'  "수출컨테이너 재고이전 제외
         AND p~vbeln        EQ @ls_data-vbeln.

      IF sy-subrc EQ 0 OR lv_chk IS NOT INITIAL.
        DELETE gt_data WHERE vbeln = ls_data-vbeln.
        CLEAR lv_chk.
        CONTINUE.
      ENDIF.

*_____선적문서 존재여부 Check
      CLEAR: lv_chk.
      SELECT SINGLE @abap_true  INTO @lv_chk
        FROM vttk AS k  INNER JOIN vttp AS p
                        ON k~tknum  =  p~tknum
       WHERE p~vbeln EQ @ls_data-vbeln
         AND k~shtyp NE 'Z103'.

      IF sy-subrc EQ 0 OR lv_chk IS NOT INITIAL.
        DELETE gt_data WHERE vbeln = ls_data-vbeln.
        CLEAR lv_chk.
        CONTINUE.
      ENDIF.

    ELSEIF rb_tk = 'X'.    " 선적문서 기준 신규발행 조건 점검
*_____선적문서기준 발행여부
      CLEAR: lv_chk.
      SELECT SINGLE @abap_true  INTO @lv_chk
        FROM zlet0005 AS k  INNER JOIN zlet0006 AS p
                            ON k~iv_no = p~iv_no
       WHERE k~iv_print_yn  EQ  'X'    "거래명세서 발행여부
         AND k~iv_cancel_yn EQ ' '    "거래명세서 취소여부
         AND k~iv_type      NE 'L01'  "수출컨테이너 재고이전 제외
         AND p~vbeln        EQ @ls_data-vbeln
         AND p~tknum        EQ @ls_data-tknum.

      IF sy-subrc EQ 0 OR lv_chk IS NOT INITIAL.
        DELETE gt_data WHERE vbeln = ls_data-vbeln
                         AND tknum = ls_data-tknum.
        CLEAR lv_chk.
        CONTINUE.
      ELSE.
**       (2026.07.30) 납품문서 하나에 여러개의 선적문서가 있는 경우 Check.
**       같은 납품문서로 발행된 이력이 있는 경우 대상에서 제외.
*        CLEAR: lv_chk.
*        PERFORM check_delivery_from_tknum  USING    ls_data-vbeln
*                                                    ls_data-tknum
*                                           CHANGING lv_chk.
*        IF lv_chk IS NOT INITIAL.
*          DELETE gt_data WHERE vbeln = ls_data-vbeln
*                           AND tknum = ls_data-tknum.
*          CLEAR lv_chk.
*          CONTINUE.
*        ENDIF.

      ENDIF.

*_____납품문서기준으로 발행한 거래명세서 존재여부 점검
      SELECT p~tknum  INTO TABLE @DATA(lt_tknum)
        FROM zlet0005 AS k  INNER JOIN zlet0006 AS p
                            ON k~iv_no = p~iv_no
       WHERE k~iv_print_yn  EQ  'X'   "거래명세서 발행여부
         AND k~iv_cancel_yn EQ ' '    "거래명세서 취소여부
         AND k~iv_type      NE 'L01'  "수출컨테이너 재고이전 제외
         AND p~vbeln        EQ @ls_data-vbeln.

      IF sy-subrc = 0 AND lt_tknum[] IS NOT INITIAL.

        DELETE lt_tknum  WHERE tknum NE space.
        IF lt_tknum[] IS NOT INITIAL.
          DELETE gt_data WHERE vbeln = ls_data-vbeln.
          CONTINUE.
        ENDIF.

      ENDIF.

    ENDIF.

  ENDLOOP.

**
  FREE: lt_data, lt_tknum.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form modify_infomation_data
*&---------------------------------------------------------------------*
FORM modify_infomation_data .

  DATA: lv_vbeln TYPE vbeln_vl.

**
  CHECK: gv_error  IS INITIAL,
         gt_data[] IS NOT INITIAL.

  LOOP AT gt_data  ASSIGNING FIELD-SYMBOL(<lfs_wa>).

*   통문유형 & Characteristic field set
    IF <lfs_wa>-lfart = 'NL'.
      PERFORM modify_infomation_for_nl     USING  <lfs_wa>.

    ELSE.
      PERFORM modify_infomation_for_other  USING  <lfs_wa>.

    ENDIF.

*   Batch info set.
    PERFORM modify_data_with_batch         USING  <lfs_wa>.

    IF <lfs_wa>-base IS INITIAL OR
       <lfs_wa>-iden IS INITIAL.

      SELECT SINGLE zzcolor_base, zziden_code,
                    zzcolor_stripe, zzral_code
        INTO (@<lfs_wa>-base, @<lfs_wa>-iden,
              @<lfs_wa>-stripe, @<lfs_wa>-detail)
        FROM mara  WHERE matnr EQ @<lfs_wa>-matnr.

    ENDIF.

*   Get Descriptions
    PERFORM modify_descriptions            USING  <lfs_wa>.

*   Other Data Modify
    PERFORM modify_data_from_check_data    USING  <lfs_wa>
                                                  lv_vbeln.

  ENDLOOP.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form modify_infomation_for_nl
*&---------------------------------------------------------------------*
FORM modify_infomation_for_nl  USING    ps_data  LIKE gt_data.

  DATA: ls_return TYPE bapiret2_t,
        lt_char   LIKE e1cuval OCCURS 0 WITH HEADER LINE,

        lv_ebeln  LIKE ekpo-ebeln,
        lv_ebelp  LIKE ekpo-ebelp,
        lv_value  TYPE cux_value40,
        lv_length LIKE zppt0001-mgvrg.

**
  CHECK: ps_data IS NOT INITIAL.

  ps_data-iv_type = 'A02'.

  CLEAR: lv_ebeln, lv_ebelp,
         ls_return.
  _clear: lt_char.

  lv_ebeln = ps_data-vgbel.
  lv_ebelp = ps_data-vgpos.

  CALL FUNCTION 'ZMM_EKPO_SPEC_GET'
    EXPORTING
      ebeln                        = lv_ebeln
      ebelp                        = lv_ebelp
    IMPORTING
      et_return                    = ls_return
    TABLES
      t_e1cuval                    = lt_char
    EXCEPTIONS
      instance_not_found           = 1
      internal_error               = 2
      instance_is_a_classification = 3
      OTHERS                       = 4.

  IF NOT lt_char[] IS INITIAL.
*   조장
    CLEAR: lv_value.
    lv_value = VALUE #( lt_char[ charc = 'SAP_MILLCA_LENGTH' ]-value
                        OPTIONAL ).
    IF lv_value IS NOT INITIAL.
      CLEAR: lv_length.
      PERFORM char_fltp_conversion  USING    lv_value
                                    CHANGING lv_length.

      ps_data-length_so = lv_length.

    ENDIF.

    PERFORM set_char_value_from_mm  TABLES   lt_char
*                  색상(Base)  PD_CA_COLOR_BASE
            USING: 'PD_CA_COLOR_BASE'    CHANGING ps_data-base,
*                  색상(Stripe) PD_CA_COLOR_STRIPE
                   'PD_CA_COLOR_STRIPE'  CHANGING ps_data-stripe,
*                  절연선심식별 PD_CA_INS_IDEN_CODE
                   'PD_CA_INS_IDEN_CODE' CHANGING ps_data-iden,
*                  색상(상세):  PD_CA_COLOR_DETAIL
                   'PD_CA_COLOR_DETAIL'  CHANGING ps_data-detail.

  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form char_fltp_conversion
*&---------------------------------------------------------------------*
FORM char_fltp_conversion  USING    pi_value
                           CHANGING pe_value.

  DATA: lv_fltp     LIKE rscvp-valu1.

**
  CLEAR: lv_fltp.
  CALL FUNCTION 'CHAR_FLTP_CONVERSION'
    EXPORTING
      string          = pi_value
    IMPORTING
      flstr           = lv_fltp
*&      ivalu           = x_ival
    EXCEPTIONS
      string_not_fltp = 1.

  pe_value = lv_fltp.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form set_char_value_from_mm
*&---------------------------------------------------------------------*
FORM set_char_value_from_mm  TABLES   pt_char STRUCTURE e1cuval
                             USING    pi_charc
                             CHANGING pe_value.

  DATA: lv_charc  TYPE cu_charc.

**
  CHECK: pt_char[] IS NOT INITIAL.

  CLEAR: lv_charc.
  lv_charc = pi_charc.

  DATA(lv_value) = VALUE #( pt_char[ charc = lv_charc ]-value
                            OPTIONAL ).

  IF lv_value IS NOT INITIAL.
    pe_value = lv_value.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form modify_infomation_for_other
*&---------------------------------------------------------------------*
FORM modify_infomation_for_other  USING    ps_data  LIKE gt_data.

  DATA: lt_char1 LIKE conf_out OCCURS 0 WITH HEADER LINE.

**
  CHECK: ps_data IS NOT INITIAL.

  IF ps_data-lfart EQ 'LF2'. "유상판매원자재부산물
    ps_data-iv_type = 'A03'.
  ELSE.
    ps_data-iv_type = 'A01'.
  ENDIF.


  _clear: lt_char1.
  PERFORM get_characteristic_table(zler0001) TABLES lt_char1
                                             USING  ps_data-vgbel
                                                    ps_data-vgpos.

  IF lt_char1[] IS NOT INITIAL.

    PERFORM set_char_value_from_conf         TABLES   lt_char1
*                  조장
            USING: 'T' 'SAP_LENGTH_VKRME'        CHANGING ps_data-length_so,
*                  색상(Base)
                   'T' 'PD_CA_COLOR_BASE'        CHANGING ps_data-base,
*                  색상(Stripe)
                   'T' 'PD_CA_COLOR_STRIPE'      CHANGING ps_data-stripe,
*                  색상-STRIPE수
                   'T' 'PD_CA_COLOR_STRIPE_NO'   CHANGING ps_data-stripe_no,
*                  색상-선심식별코드
                   'T' 'PD_CA_INS_IDEN_CODE'     CHANGING ps_data-iden,
*                  색상(상세)
                   'T' 'PD_CA_COLOR_DETAIL'      CHANGING ps_data-detail.

  ENDIF.

  SELECT SINGLE varcond, vctext
    INTO ( @ps_data-so_grd, @ps_data-so_grdt )
    FROM zgtsd_cv_get_soprice
   WHERE vbeln   EQ @ps_data-vgbel
     AND posnr   EQ @ps_data-vgpos
     AND varcond NE @space.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form set_char_value_from_conf
*&---------------------------------------------------------------------*
FORM set_char_value_from_conf  TABLES   pt_char1 STRUCTURE conf_out
                               USING    pi_type
                                        pi_atnam
                               CHANGING pe_atwrt.

  DATA: lv_atnam  TYPE atnam.

**
  CHECK: pt_char1[] IS NOT INITIAL.

  CLEAR: lv_atnam.
  lv_atnam = pi_atnam.

  IF     pi_type = 'T'.
    DATA(lv_atwrt) = VALUE #( pt_char1[ atnam = lv_atnam ]-atwrt
                              OPTIONAL ).

    IF lv_atwrt IS NOT INITIAL.
      pe_atwrt = lv_atwrt.
    ENDIF.

  ELSEIF pi_type = 'B'.
    DATA(lv_atwtb) = VALUE #( pt_char1[ atnam = lv_atnam ]-atwtb
                              OPTIONAL ).

    IF lv_atwtb IS NOT INITIAL.
      pe_atwrt = lv_atwtb.
    ENDIF.

  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form modify_data_with_batch
*&---------------------------------------------------------------------*
FORM modify_data_with_batch  USING    ps_data  LIKE gt_data.

  DATA: lv_factor TYPE i,
        lv_lfimg  LIKE lips-lfimg,
        lv_lfimg1 LIKE lips-lfimg.

**
  CHECK: ps_data IS NOT INITIAL.


* Charg count / Qty
  IF ps_data-lifsk NE 'G3'.
    SELECT lfimg  INTO TABLE @DATA(lt_lfimg)
      FROM lips  WHERE vbeln EQ @ps_data-vbeln
                   AND uecha EQ @ps_data-posnr .
  ELSE.
    SELECT lfimg  INTO CORRESPONDING FIELDS OF TABLE @lt_lfimg
      FROM zgtsdt9120  WHERE vbeln EQ @ps_data-vbeln
                        AND uecha EQ @ps_data-posnr .
  ENDIF.

  CLEAR: lv_lfimg.
  IF lt_lfimg[] IS NOT INITIAL.
    lv_lfimg = REDUCE i( INIT x = 0
                         FOR ls_sum  IN lt_lfimg
                         WHERE ( lfimg > 0 )
                         NEXT x = x + ls_sum-lfimg ).
    DATA(lv_cnt) = lines( lt_lfimg[] ).
  ENDIF.

  ps_data-charg_cnt = lv_cnt.

  IF ps_data-charg IS NOT INITIAL.
    ps_data-charg_cnt = ps_data-charg_cnt + 1.

  ELSE.

    IF ps_data-lifsk NE 'G3'.
      SELECT SINGLE charg  INTO @ps_data-charg
        FROM lips  WHERE vbeln EQ @ps_data-vbeln
                     AND uecha EQ @ps_data-posnr.
    ELSE.
      SELECT SINGLE charg  INTO @ps_data-charg
        FROM zgtsdt9120  WHERE vbeln EQ @ps_data-vbeln
                           AND uecha EQ @ps_data-posnr.
    ENDIF.

  ENDIF.
  ps_data-lfimg = ps_data-lfimg + lv_lfimg.

*소재 사업부 SCR품질 BATCH 등급
  SELECT SINGLE grade, grade_t
    INTO ( @ps_data-batch_grd, @ps_data-batch_grdt )
    FROM zgtsd_cv_get_vcofbatch
   WHERE matnr EQ @ps_data-matnr
     AND charg EQ @ps_data-charg
     AND werks EQ @ps_data-werks
     AND atnam EQ 'BT_AA_GRADE'.

* 배치특성
  PERFORM get_batch_characteristic    USING    ps_data-matnr
                                               ps_data-charg
                                      CHANGING ps_data-length
                                               ps_data-packg
                                               ps_data-packc.

* 싱글 유닛배치는 납품수량이 조장
  SELECT SINGLE xpcbt  INTO @DATA(lv_xpcbt)
    FROM mch1  WHERE matnr EQ @ps_data-matnr
                 AND charg EQ @ps_data-charg.

  IF lv_xpcbt = 'X'.
    IF ps_data-charg_cnt IS NOT INITIAL.
      ps_data-length = ps_data-lfimg / ps_data-charg_cnt.
    ENDIF.
  ENDIF.

  IF ps_data-length > 0.
    IF ps_data-meins <> ps_data-vrkme.
*     기본단위와 판매단위가 상이할때
      ps_data-length = ps_data-length * ps_data-umvkn / ps_data-umvkz.
    ENDIF.
  ENDIF.

  ps_data-length_c = ps_data-length.
  CONDENSE ps_data-length_c.

  ps_data-length_so_c = ps_data-length_so.
  CONDENSE ps_data-length_so_c.

  IF ps_data-length IS NOT INITIAL.
    ps_data-factor = ps_data-lfimg / ps_data-length.
  ENDIF.

  IF ps_data-length_c <> ps_data-length_so_c.

    ps_data-diff = 'X'.

    CLEAR: lv_factor .
    IF ps_data-length IS NOT INITIAL.
      lv_factor = ps_data-lfimg / ps_data-length.
      ps_data-factor = lv_factor.
    ENDIF.

  ENDIF.

  CLEAR: lv_lfimg1.
  IF lv_xpcbt <> 'X'.  "MKJANG

    lv_lfimg1 = ps_data-factor * ps_data-length.
*   FACTOR BATCH 중 LIPS한건 불러온게 마침 주문조장과 같아버렸을때.
    IF lv_lfimg1 <> lv_lfimg.
      ps_data-diff = 'X'.
    ENDIF.

  ENDIF.

**
  FREE: lt_lfimg.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form get_batch_characteristic
*&---------------------------------------------------------------------*
FORM get_batch_characteristic  USING    pi_matnr
                                        pi_charg
                               CHANGING pe_length
                                        pe_packg
                                        pe_packc.

  DATA: lv_value(13)  TYPE p DECIMALS 3,
        lv_objek_kssk LIKE kssk-objek,  "TYPE OBJNUM,
        lv_objno      LIKE inob-cuobj,  "TYPE CUOBJ,
        lv_objek_ausp LIKE ausp-objek,  "TYPE OBJNUM.
        ls_mckey      LIKE mch1_key,

        lr_atnam      LIKE RANGE OF cabn-atnam,
        lt_ausp       LIKE ausp OCCURS 0 WITH HEADER LINE.

**
  _clear: lr_atnam.
  lr_atnam = VALUE #( ( sign = 'I'  option = 'EQ'  low = 'SAP_MILLCA_LENGTH' )        "조장
                      ( sign = 'I'  option = 'EQ'  low = 'SAP_MILLCA_FACTOR' )        "조장수
                      ( sign = 'I'  option = 'EQ'  low = 'SAP_MILLCA_PACKAGING' )     "포장재 코드
                      ( sign = 'I'  option = 'EQ'  low = 'SAP_MILLCA_PACKAGING_CAT' ) "포장재 유형
                      ( sign = 'I'  option = 'EQ'  low = 'PD_CA_COLOR_BASE' )         "색상
                      ( sign = 'I'  option = 'EQ'  low = 'BT_AL_LENGTH' ) ).          "절단길이

  SELECT DISTINCT atinn, atnam  INTO TABLE @DATA(lt_cabn)
    FROM cabn  WHERE atnam IN @lr_atnam.

  CLEAR: lv_objek_kssk, lv_objno, ls_mckey.
  ls_mckey-matnr = pi_matnr.
  ls_mckey-charg = pi_charg.

  lv_objek_kssk  = ls_mckey.

  CALL FUNCTION 'CUOB_GET_NUMBER'
    EXPORTING
      class_type       = '023'
      object_id        = lv_objek_kssk
      table            = 'MCH1'
    IMPORTING
      object_number    = lv_objno
    EXCEPTIONS
      lock_problem     = 1
      object_not_found = 2
      OTHERS           = 3.

  IF sy-subrc = 0.

    CLEAR: lv_objek_ausp.
    lv_objek_ausp = lv_objno.

    _clear: lt_ausp.
    SELECT b~*
      FROM @lt_cabn AS a  INNER JOIN ausp AS b
                           ON  a~atinn = b~atinn
                           AND b~objek = @lv_objek_ausp
                           AND b~klart = '023'
      INTO CORRESPONDING FIELDS OF TABLE @lt_ausp.

    IF lt_ausp[] IS NOT INITIAL.

      LOOP AT lt_cabn  INTO DATA(ls_cabn).

        DATA(ls_ausp) = VALUE #( lt_ausp[ atinn = ls_cabn-atinn ]
                                 OPTIONAL ).

        IF ls_ausp IS NOT INITIAL.

          CLEAR: lv_value.
          CASE ls_cabn-atnam .
            WHEN 'SAP_MILLCA_LENGTH' .        "조장
              IF ls_ausp-atflv > 0.
                lv_value = ls_ausp-atflv.
                pe_length = lv_value.

              ENDIF.

            WHEN 'SAP_MILLCA_FACTOR' .        "조장수
            WHEN 'SAP_MILLCA_PACKAGING' .     "포장재 코드
              pe_packg = ls_ausp-atwrt.

            WHEN 'SAP_MILLCA_PACKAGING_CAT' . "포장재 유형
              pe_packc = ls_ausp-atwrt.

            WHEN 'PD_CA_COLOR_BASE' .         "색상
            WHEN 'BT_AL_LENGTH' .             "절단길이
*              IF gt_item-vstel = '4200'.
*                IF ls_ausp-atflv > 0.
*                  lv_value = ls_ausp-atflv.
*                  pe_length = lv_value.
*                ENDIF.
*
*              ENDIF.

          ENDCASE.

        ENDIF.

      ENDLOOP.

    ENDIF.

  ENDIF.

**
  FREE: lt_cabn, lr_atnam, lt_ausp.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form modify_descriptions
*&---------------------------------------------------------------------*
FORM modify_descriptions  USING    ps_data  LIKE gt_data.

**
* 포장재
  PERFORM  get_description_from_makt  USING    ps_data-packg
                                      CHANGING ps_data-packg_t.

* 납품처
  PERFORM  get_name_from_vbpa_adrc    USING    ps_data-vbeln
                                               ps_data-kunnr
                                               'WE'
                                      CHANGING ps_data-kunnr_t.
* 판매처
  PERFORM  get_name_from_vbpa_adrc    USING    ps_data-vbeln
                                               ps_data-kunag
                                               'SP'
                                      CHANGING ps_data-kunag_t.
* 운송대행업체
  PERFORM  get_name_from_lfa1         USING    ps_data-tdlnr
                                      CHANGING ps_data-tdlnr_t.

* 선적문서 출고전기 여부 텍스트
  CASE ps_data-wbstk.
    WHEN 'A'.
      ps_data-wbstk_t = '출고미완료'.
    WHEN 'B'.
      ps_data-wbstk_t = '일부처리'.
    WHEN 'C'.
      ps_data-wbstk_t = '출고완료'.
    WHEN ' '.
      ps_data-wbstk_t = '관련없음'.
  ENDCASE.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form get_description_from_makt
*&---------------------------------------------------------------------*
FORM get_description_from_makt  USING    pi_matnr
                                CHANGING pe_maktx.

**
  CHECK: pi_matnr IS NOT INITIAL.

  SELECT SINGLE maktx  INTO @pe_maktx
    FROM makt  WHERE matnr EQ @pi_matnr
                 AND spras EQ @sy-langu.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form get_name_from_vbpa_adrc
*&---------------------------------------------------------------------*
FORM get_name_from_vbpa_adrc  USING    pi_vbeln
                                       pi_kunnr
                                       pi_parvw
                              CHANGING pe_name.

**
  CHECK: pi_vbeln IS NOT INITIAL.

  SELECT SINGLE adrnr  INTO @DATA(lv_adrnr)
    FROM vbpa  WHERE vbeln EQ @pi_vbeln
                 AND posnr EQ '000000'
                 AND parvw EQ @pi_parvw.

  SELECT SINGLE name1  INTO @pe_name
    FROM adrc  WHERE addrnumber EQ @lv_adrnr.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form get_name_from_lfa1
*&---------------------------------------------------------------------*
FORM get_name_from_lfa1  USING    pi_lifnr
                         CHANGING pe_name.

**
  CHECK: pi_lifnr IS NOT INITIAL.

  SELECT SINGLE name1  INTO @pe_name
    FROM lfa1  WHERE lifnr EQ @pi_lifnr.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form modify_data_from_check_data
*&---------------------------------------------------------------------*
FORM modify_data_from_check_data  USING    ps_data  LIKE gt_data
                                           pi_vbeln.

**
  CHECK: ps_data IS NOT INITIAL.

* ZLET0033에 출하지점 8100인 경우에는 사업장 6000만 존재
  IF p_bzarea EQ '6000'.
    SELECT SINGLE empst  INTO @ps_data-empst
      FROM vbkd  WHERE vbeln EQ @ps_data-vgbel
                   AND posnr EQ @ps_data-vgpos.
  ENDIF.

* 지중 오출하 방지용 체크박스 제어 로직
  IF s_vstel-low = '3400' AND ps_data-mtart = 'MCFE'.

    IF pi_vbeln EQ ps_data-vbeln.
      ps_data-chk_b = 'X'.

    ELSE.

      CLEAR : pi_vbeln.

      SELECT SINGLE vbeln  INTO @DATA(lv_zcodi)
        FROM zlet0098  WHERE vbeln EQ @ps_data-vbeln
                         AND posnr EQ @ps_data-posnr.

      IF lv_zcodi IS INITIAL.

        CLEAR: lv_zcodi.
        SELECT SINGLE vbeln  INTO @lv_zcodi
          FROM zlet0097  WHERE vbeln EQ @ps_data-vbeln.

        IF lv_zcodi IS INITIAL.
          ps_data-chk_b = 'X'.
          pi_vbeln       = ps_data-vbeln.
        ELSE.
          ps_data-chk_b = 'O'.
        ENDIF.
      ELSE.
        ps_data-chk_b = 'O'.
      ENDIF.
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
  DESCRIBE TABLE gt_list LINES gv_line.
  IF gv_line > 0.
    CALL SCREEN 100.

  ELSE.
*   조건에 맞는 DATA가 없습니다.
    MESSAGE s018  DISPLAY LIKE 'E'.

  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form make_display_list
*&---------------------------------------------------------------------*
FORM make_display_list .

**
  CHECK: gv_error IS INITIAL,
         gt_data[] IS NOT INITIAL.

  _clear: gt_list.
  gt_list[] = CORRESPONDING #( gt_data[] ).

* 폭/드럼, 약경/드럼, 드럼무게/개
  PERFORM get_data_from_cbm_fm .

** 특성값 조회
*  PERFORM get_characteristic_data.
*
* OS / 구분을 위한 Stock Data Get.
  PERFORM get_stock_data_for_os_zgubun.


  LOOP AT gt_list  ASSIGNING FIELD-SYMBOL(<lfs_list>).

    IF <lfs_list>-lfart = 'NL'.    " 납품유형
      <lfs_list>-iv_type = 'A02'.     " 통문유형
    ELSEIF <lfs_list>-lfart = 'LF2'.
      <lfs_list>-iv_type = 'A03'.     " 통문유형
    ELSE.
      <lfs_list>-iv_type = 'A01'.     " 통문유형
    ENDIF.

*   영업그룹 Desc
    PERFORM get_description_for_vkgrp   USING    <lfs_list>-vkgrp
                                        CHANGING <lfs_list>-vkgrp_txt.

*   판매처
    PERFORM get_name_from_vbpa_adrc     USING    <lfs_list>-vbeln
                                                 <lfs_list>-kunag
                                                 'AG'
                                        CHANGING <lfs_list>-kunag_nm.

*   납품처
    PERFORM get_name_from_vbpa_adrc     USING    <lfs_list>-vbeln
                                                 <lfs_list>-kunnr
                                                 'WE'
                                        CHANGING <lfs_list>-kunnr_nm.
*   영업소 코드
    PERFORM get_yuscd_from_fm           USING    <lfs_list>-vkgrp
                                                 <lfs_list>-vgbel
                                        CHANGING <lfs_list>-zzyuscd.

*   자재내역
    PERFORM get_description_from_makt   USING    <lfs_list>-matnr
                                        CHANGING <lfs_list>-maktx.

*   Set Characteristic Value.
    PERFORM set_characteristic_values   USING    <lfs_list>.
*    PERFORM set_characteristic_value_v2 USING    <lfs_list>.

    <lfs_list>-factor_n = <lfs_list>-factor.

*   F 량 Check.
    PERFORM check_characteristic_fiber  USING    <lfs_list>-matnr
                                                 <lfs_list>-werks
                                                 <lfs_list>-lfimg
                                                 <lfs_list>-fiber
                                        CHANGING <lfs_list>-fiber_c
                                                 <lfs_list>-fiber_n.

*   동량.
    PERFORM get_tkgw_select_single      USING    <lfs_list>-matnr
                                                 <lfs_list>-werks
                                                 <lfs_list>-lfimg
                                        CHANGING <lfs_list>-kgw.

*   제품 총 중량 Set.
    PERFORM set_brgew_from_data         USING    <lfs_list>.

*   폭/드럼, 약경/드럼, 드럼무게/개, 총 중량(드럼포함)
    PERFORM set_data_from_cdm           USING    <lfs_list>.

*   OS / 구분 Field.
    PERFORM set_os_zgubun_field         USING    <lfs_list>-vgbel
                                                 <lfs_list>-vgpos
                                                 <lfs_list>-matnr
                                                 <lfs_list>-werks
                                                 <lfs_list>-lgort
                                                 <lfs_list>-factor_n
                                        CHANGING <lfs_list>-fixmg
                                                 <lfs_list>-zgubun.

*   납지 / 특이사항
    PERFORM get_city1_remark_from_400   USING    <lfs_list>-vgbel
                                                 <lfs_list>-vgpos
                                                 <lfs_list>-vbeln
                                                 <lfs_list>-posnr
                                        CHANGING <lfs_list>-city1
                                                 <lfs_list>-remark
                                                 <lfs_list>-zremark1
                                                 <lfs_list>-extension1   " 수령인
                                                 <lfs_list>-tel_number.  " 수령인 연락처

*   Info with TKNUM
    PERFORM get_infomation_from_tknum   USING    <lfs_list>.

*   PO No.
    SELECT SINGLE bstnk  INTO @<lfs_list>-bstnk
      FROM vbak  WHERE vbeln EQ @<lfs_list>-vgbel.

*   입력일
    SELECT SINGLE a~erdat
      FROM zlet0400 AS a  INNER JOIN zlet0402 AS b
                          ON a~dlvrq = b~dlvrq
     WHERE b~vgbel EQ @<lfs_list>-vbeln
       AND b~vgpos EQ @<lfs_list>-posnr
      INTO @<lfs_list>-erdat.

  ENDLOOP.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form get_description_for_vkgrp
*&---------------------------------------------------------------------*
FORM get_description_for_vkgrp  USING    pi_vkgrp
                                CHANGING pe_bezei.

**
  CHECK: pi_vkgrp IS NOT INITIAL.

  SELECT SINGLE bezei  INTO @pe_bezei
    FROM tvgrt  WHERE vkgrp EQ @pi_vkgrp
                  AND spras EQ @sy-langu.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form get_yuscd_from_fm
*&---------------------------------------------------------------------*
FORM get_yuscd_from_fm  USING    pi_vkgrp
                                 pi_vbeln
                        CHANGING pe_zzyuscd.

  DATA: lv_zzyuscd TYPE zgteyuscd,
        lv_type    TYPE bapi_mtype,
        lv_msg     TYPE bapi_msg.

**
  CHECK: pi_vkgrp IS NOT INITIAL,
         pi_vbeln IS NOT INITIAL.

  SELECT SINGLE a~vkorg, b~kdkg4  INTO @DATA(ls_va_info)
    FROM vbak AS a  INNER JOIN vbkd AS b
                    ON  a~vbeln = b~vbeln
                    AND b~posnr = '000000'
   WHERE a~vbeln EQ @pi_vbeln.

  CLEAR: lv_zzyuscd, lv_type, lv_msg.
  CALL FUNCTION 'ZGTSD_GET_ZZYUSCD'
    EXPORTING
      i_vkorg   = ls_va_info-vkorg
      i_vkgrp   = pi_vkgrp
      i_kdkg4   = ls_va_info-kdkg4
    IMPORTING
      e_zzyuscd = lv_zzyuscd
      e_type    = lv_type
      e_msg     = lv_msg.

  IF lv_type EQ 'S'.
    pe_zzyuscd = lv_zzyuscd.
  ENDIF.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form set_characteristic_values
*&---------------------------------------------------------------------*
FORM set_characteristic_values  USING    ps_list  LIKE gt_list.

  DATA: lt_char  LIKE conf_out OCCURS 0 WITH HEADER LINE.

**
  CHECK: ps_list IS NOT INITIAL.

  _clear: lt_char.
  CALL FUNCTION 'Z_LE_GET_CHARACTERISTIC_TABLE2'
    EXPORTING
      i_vbeln                      = ps_list-vgbel
      i_posnr                      = ps_list-vgpos
    TABLES
      et_char                      = lt_char
    EXCEPTIONS
      characteristic_not_found     = 1
      instance_not_found           = 2
      instance_is_a_classification = 3
      invalid_data                 = 4
      OTHERS                       = 5.

  CHECK: lt_char[] IS NOT INITIAL.

  PERFORM set_char_value_from_conf         TABLES   lt_char
*                색상 ( PD_CA_COLOR_BASE )
          USING: 'T' 'PD_CA_COLOR_BASE'        CHANGING ps_list-color,
*                F량 ( PD_CA_FIBER_NO_1ST )
                 'T' 'PD_CA_FIBER_NO_1ST'      CHANGING ps_list-fiber,
*                조장 ( SAP_LENGTH_VKRME )
                 'T' 'SAP_LENGTH_VKRME'        CHANGING ps_list-length,
*                조장수 ( SAP_MILLCA_FACTOR )
                 'T' 'SAP_MILLCA_FACTOR'       CHANGING ps_list-factor,
*                포장구분 ( PD_GA_PACKAGE_METHOD )
                 'B' 'PD_GA_PACKAGE_METHOD'    CHANGING ps_list-pack_gubun.

* Str / 띄줄 추가
  PERFORM set_char_value_from_conf                TABLES   lt_char
*                Str ( PD_CA_COLOR_STRIPE )
          USING: 'T' 'PD_CA_COLOR_STRIPE'         CHANGING ps_list-str,
*                띄줄 ( PD_CA_COLOR_STRIPE_NO )
                 'T' 'PD_CA_COLOR_STRIPE_NO'      CHANGING ps_list-str_no.
*

  "조장수 = 납품수량 / 조장
  IF ps_list-length NE 0.
    ps_list-factor = ps_list-lfimg / ps_list-length.
  ENDIF.
**
  FREE: lt_char.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form get_tkgw_select_single
*&---------------------------------------------------------------------*
FORM get_tkgw_select_single  USING    pi_matnr
                                      pi_werks
                                      pi_lfimg
                             CHANGING pe_kgw.

  DATA: lv_nes  LIKE /nfm/tkgw-nes,
        ls_tkgw LIKE /nfm/tkgw.
  DATA: lv_werks TYPE werks_d.

  lv_werks = pi_werks.

  IF lv_werks+2(2) EQ '91'.
    lv_werks+2(2) = '00'.
  ENDIF.

**
  CLEAR: ls_tkgw, lv_nes.
  lv_nes = 'CU'.

  CALL FUNCTION '/NFM/TKGW_SELECT_SINGLE'
    EXPORTING
      i_matnr   = pi_matnr
      i_werks   = lv_werks "pi_werks
      i_nes     = lv_nes
    IMPORTING
      e_tkgw    = ls_tkgw
    EXCEPTIONS
      not_found = 1
      OTHERS    = 2.

  IF ls_tkgw IS NOT INITIAL.
    pe_kgw = ls_tkgw-kgw * pi_lfimg / ls_tkgw-kgu.
  ENDIF.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form check_characteristic_fiber
*&---------------------------------------------------------------------*
FORM check_characteristic_fiber  USING    pi_matnr
                                          pi_werks
                                          pi_lfimg
                                          pi_fiber
                                 CHANGING pe_fiber_c
                                          pe_fiber_n.

  DATA: lv_calculate  TYPE p DECIMALS 2.

**
  SELECT SINGLE dispo  INTO @DATA(lv_dispo)
    FROM marc  WHERE matnr EQ @pi_matnr
                 AND werks EQ @pi_werks
                 AND lvorm EQ @space.
  IF lv_dispo+0(3) = 'GOF'.

    lv_calculate = ( pi_lfimg * pi_fiber ) / 1000.
    pe_fiber_c = lv_calculate.
    pe_fiber_n = lv_calculate.

  ELSE.
    CLEAR: pi_fiber, pe_fiber_c, pe_fiber_n.
  ENDIF.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form set_os_zgubun_field
*&---------------------------------------------------------------------*
FORM set_os_zgubun_field  USING    pi_vbeln
                                   pi_posnr
                                   pi_matnr
                                   pi_werks
                                   pi_lgort
                                   pi_factor
                          CHANGING pe_fixmg
                                   pe_zgubun.

**
  SELECT SINGLE fixmg, mvgr3
    INTO @DATA(ls_vbap)
    FROM vbap  WHERE vbeln EQ @pi_vbeln
                 AND posnr EQ @pi_posnr.

* OS Field.
  IF ls_vbap-fixmg = 'X'.
    pe_fixmg = 'S'.
  ELSE.
    pe_fixmg = 'O'.
  ENDIF.

* 구분
  IF     ls_vbap-fixmg IS INITIAL.         " MTO.
    CLEAR: pe_zgubun.

  ELSEIF ls_vbap-fixmg IS NOT INITIAL.    " MTS.

    IF     ls_vbap-mvgr3 = 'X'.    " 절단하지 않은 정조장인 경우
      pe_zgubun = '정'.

    ELSEIF ls_vbap-mvgr3 = 'Y'.
*          부분 정조장으로 SO/항번 기준으로 일부는 절단, 일부는 정조장을 사용하는 경우
      PERFORM set_gubun_from_lstock_link  USING    pi_vbeln
                                                   pi_posnr
                                                   pi_matnr
                                                   pi_werks
                                                   pi_lgort
                                                   pi_factor
                                          CHANGING pe_zgubun.

    ELSEIF ls_vbap-mvgr3 = '' .  " 절단하는 경우
*     EX) 완 3  -> SALES ORDER STOCK 재고가 3 LINE 이라는 의미
*                  (절단된 SALES ORDER STOCK 재고가 3 조장이란 의미)
* Before
*      PERFORM set_gubun_from_stock_fm USING    pi_vbeln
*                                               pi_posnr
*                                               pi_matnr
*                                               pi_werks
*                                               pi_lgort
*                                               pi_factor
*                                      CHANGING pe_zgubun.

* After
      PERFORM set_gubun_from_stock_v2 USING    pi_vbeln
                                               pi_posnr
                                               pi_matnr
                                               pi_werks
                                               pi_lgort
                                               pi_factor
                                      CHANGING pe_zgubun.

*      SELECT COUNT( * ) AS cnt  INTO @DATA(lv_cnt)
*        FROM mska AS a  INNER JOIN lips AS b
*                        ON  a~vbeln = b~vgbel
*                        AND a~posnr = b~vgpos
*                        AND a~matnr = b~matnr
*                        AND a~werks = b~werks
*                        AND a~lgort = b~lgort
*       WHERE b~vgbel EQ @pi_vbeln
*         AND b~vgpos EQ @pi_posnr.
*
*      pe_zgubun = '완'.
*      pe_zgubun = |{ pe_zgubun }| && | { lv_cnt }|.

    ENDIF.

  ENDIF.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form get_city1_remark_from_400
*&---------------------------------------------------------------------*
FORM get_city1_remark_from_400  USING    pi_vbeln
                                         pi_posnr
                                         pi_vbeln_vl
                                         pi_posnr_vl
                                CHANGING pe_city1
                                         pe_remark
                                         pe_zremark1
                                         pe_extension1   " 수령인
                                         pe_tel_number.  " 수령인 연락처

  DATA: lv_vbeln_vl  LIKE zlet0402-vgbel.
**
  CLEAR: lv_vbeln_vl.
  lv_vbeln_vl = pi_vbeln_vl.

  SELECT SINGLE vbeln
    FROM zlet0402  WHERE vgbel EQ @lv_vbeln_vl
    INTO @DATA(lv_vbeln).

  IF lv_vbeln IS INITIAL.
** 납품분할의 경우 Original DO 번호를 찾아 수령인, 연락처 정보를 찍어준다
    CLEAR: lv_vbeln_vl.
    SELECT SINGLE vbeln
      FROM ledspd_flow  WHERE vbeln_new EQ @pi_vbeln_vl
                          AND posnr_new EQ @pi_posnr_vl
                          AND updkz     EQ 'I'
      INTO @lv_vbeln_vl.

  ENDIF.

  IF lv_vbeln_vl IS NOT INITIAL.

    SELECT SINGLE a~city1, a~street, a~remark,
                  a~zremark1, a~extension1, a~tel_number
      INTO @DATA(ls_0400)
      FROM zlet0400 AS a  INNER JOIN zlet0401 AS b
                          ON a~dlvrq = b~dlvrq
                          INNER JOIN zlet0402 AS c
                          ON a~dlvrq EQ c~dlvrq
                          AND b~vbeln EQ c~vbeln
                          AND b~posnr EQ c~posnr
     WHERE b~vbeln EQ @pi_vbeln
       AND b~posnr EQ @pi_posnr
       AND b~lvorm EQ @abap_false
       AND c~vgbel EQ @lv_vbeln_vl.

    IF ls_0400 IS NOT INITIAL.
      pe_city1      = | { ls_0400-city1 }{ ls_0400-street }|.
      pe_remark     = ls_0400-remark.
      pe_zremark1   = ls_0400-zremark1.
      pe_extension1 = ls_0400-extension1. " 수령인
      pe_tel_number = ls_0400-tel_number. " 수령인 연락처

    ENDIF.

  ENDIF.

* 오더유형 'ZOT'
  SELECT SINGLE auart
    FROM vbak
   WHERE vbeln EQ @pi_vbeln
    INTO @DATA(lv_auart).
  IF lv_auart EQ 'ZOT'.
    SELECT SINGLE b~extension2
      FROM vbpa AS a INNER JOIN adrc AS b
                     ON a~adrnr = b~addrnumber AND
                        b~date_from <= @sy-datlo AND
                        b~nation = @space
     WHERE a~vbeln EQ @pi_vbeln_vl
       AND a~posnr EQ '000000'
       AND a~parvw EQ 'WE'
      INTO @DATA(lv_exten2).

    IF sy-subrc EQ 0.
      pe_extension1 = lv_exten2.
    ENDIF.
  ENDIF.


  IF pe_city1 IS INITIAL.

    SELECT SINGLE adrnr  INTO @DATA(lv_adrnr)
*      FROM vbpa  WHERE vbeln EQ @pi_vbeln
      FROM vbpa  WHERE vbeln EQ @pi_vbeln_vl
                   AND posnr EQ '000000'
                   AND parvw EQ 'WE'.

    SELECT SINGLE city1, street, str_suppl1  INTO @DATA(ls_adrc)
      FROM adrc  WHERE addrnumber EQ @lv_adrnr.

    pe_city1 = |{ ls_adrc-city1 }{ ls_adrc-street } { ls_adrc-str_suppl1 }|.

  ENDIF.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form get_infomation_from_tknum
*&---------------------------------------------------------------------*
FORM get_infomation_from_tknum  USING    ps_list  LIKE gt_list.

  DATA: lv_route  LIKE vttk-route.

**
  CLEAR: lv_route, ps_list-route.
  IF ps_list-tknum IS NOT INITIAL.

    SELECT SINGLE route, shtyp, tdlnr, exti1, exti2, tpbez
      INTO @DATA(ls_vttk)
      FROM vttk  WHERE tknum EQ @ps_list-tknum.

    lv_route      = ls_vttk-route.
    ps_list-shtyp = ls_vttk-shtyp.
    ps_list-tdlnr = ls_vttk-tdlnr.    " 운송사
    ps_list-exti1 = ls_vttk-exti1.    " 차량번호
    ps_list-exti2 = ls_vttk-exti2.    " 운전자명
    ps_list-tpbez = ls_vttk-tpbez.    " 전화번호

  ENDIF.

* 선적유형내역
  IF ps_list-shtyp IS NOT INITIAL.
    SELECT SINGLE bezei  INTO @ps_list-shtyp_txt
      FROM tvtkt  WHERE spras EQ @sy-langu
                    AND shtyp EQ @ps_list-shtyp.

  ENDIF.

* 운송경로명
  IF lv_route IS INITIAL.
    CLEAR: lv_route.
    SELECT SINGLE route  INTO @lv_route
      FROM likp  WHERE vbeln EQ @ps_list-vbeln.

  ENDIF.

  IF lv_route IS NOT INITIAL.
    SELECT SINGLE bezei  INTO @ps_list-route_txt
      FROM tvrot  WHERE spras EQ @sy-langu
                    AND route EQ @lv_route.

    ps_list-route = lv_route.

  ENDIF.

* 차량정보
  IF ps_list-tknum IS INITIAL AND
     ps_list-iv_no IS NOT INITIAL.
    SELECT SINGLE driver_nm, driver_telno, truck_no
      INTO ( @ps_list-exti2, @ps_list-tpbez, @ps_list-exti1 )
      FROM zlet0005  WHERE iv_no EQ @ps_list-iv_no.

  ENDIF.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form data_refresh
*&---------------------------------------------------------------------*
FORM data_refresh .

**
  _clear: gt_data, gt_list.

* 1) Get Data.
  PERFORM selection.

* 2) Make Display List.
  PERFORM make_display_list.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form doc_print_exc
*&---------------------------------------------------------------------*
FORM doc_print_exc  USING    pi_ucomm.

**
  CHECK: gv_error IS INITIAL.

* Selected line check.
  PERFORM get_selected_low             USING pi_ucomm.

* data Validation Check.
  PERFORM selected_data_validation     USING pi_ucomm.

* Confirm.
  PERFORM popup_to_confirm_for_print   USING pi_ucomm.

* 거래명세서 출력
  PERFORM print_iv_document            USING pi_ucomm.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form get_selected_low
*&---------------------------------------------------------------------*
FORM get_selected_low  USING    pi_ucomm.

  DATA: lv_subrc      TYPE sy-subrc,
        lv_do_base(1).

**
  _clear: gt_row, gt_stab.
  CLEAR: lv_subrc.
  gt_row[] = zgtsd_cl_common=>get_selected_rows( EXPORTING
                                                   io_grid = go_grid
                                                   iv_ck   = zgtsd_x
                                                 IMPORTING
                                                   ev_subrc = lv_subrc ).

  IF gt_row[] IS INITIAL.
    gv_error = 'X'.
*   처리할 데이타를 선택 하세요.
    MESSAGE s004  DISPLAY LIKE 'E'.

  ELSE.

    LOOP AT gt_row  INTO gs_row.

      CLEAR: lv_do_base.

      IF rb_re   = 'X' OR    " 재발행의 경우.
         rb_canc = 'X'.

        IF pi_ucomm = 'DOWN'.       " Picking List Download.
          lv_do_base = 'X'.
        ELSE.

          DATA(lv_iv_no) = VALUE #( gt_list[ gs_row-index ]-iv_no
                                    OPTIONAL ).
          IF lv_iv_no IS NOT INITIAL.

            gt_stab = VALUE #( BASE gt_stab
                               FOR ls_wa  IN gt_list
                               WHERE ( iv_no = lv_iv_no )
                               ( CORRESPONDING #( ls_wa ) )
                              ).

          ENDIF.

        ENDIF.

      ELSE.
        lv_do_base = 'X'.
      ENDIF.

      IF lv_do_base = 'X'.

        DATA(lv_vbeln) = VALUE #( gt_list[ gs_row-index ]-vbeln
                                  OPTIONAL ).

        IF lv_vbeln IS NOT INITIAL.

          gt_stab = VALUE #( BASE gt_stab
                             FOR ls_wa_do  IN gt_list
                             WHERE ( vbeln = lv_vbeln )
                             ( CORRESPONDING #( ls_wa_do ) )
                            ).

        ENDIF.

      ENDIF.

    ENDLOOP.

  ENDIF.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form selected_data_validation
*&---------------------------------------------------------------------*
FORM selected_data_validation  USING    pi_ucomm.

**
  CHECK: pi_ucomm EQ 'PRINT'.      " 발행.

* 신규발행의 경우, 다시 발행 금지.(두번발행금지).
  PERFORM check_already_print_data .

* 납지 확인.
  PERFORM check_delivery_address       USING  pi_ucomm.

** 납품 품번 검증.
*  PERFORM delivery_doc_varification    USING  pi_ucomm.
*
** 발행여부 확인. / 스크랩자재 확인
*  PERFORM check_already_printed        USING  pi_ucomm.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form popup_to_confirm_for_print
*&---------------------------------------------------------------------*
FORM popup_to_confirm_for_print  USING    pi_ucomm.

  DATA: lv_answer(1).

**
  CHECK: gv_error IS INITIAL,
         pi_ucomm EQ 'PRINT' OR    " 발행.
         pi_ucomm EQ 'REVERSE' OR  " 출력취소
         pi_ucomm EQ 'DOWN'.       " Picking List Download.

  CLEAR: lv_answer.

  IF     pi_ucomm EQ 'PRINT' .     " 발행.
*    PERFORM popup_to_confirm    USING    'CONFIRM'    " Title
*                                         '< 거래명세서 발행여부확인 >'
*                                         '발행하시겠습니까?'
*                                CHANGING lv_answer.
    PERFORM popup_to_confirm_with_cnt    USING    'CONFIRM'    " Title
                                                  '< 거래명세서 발행여부확인 >'
                                                  '발행하시겠습니까?'
                                         CHANGING lv_answer.

  ELSEIF pi_ucomm EQ 'REVERSE'.    " 출력취소
    PERFORM popup_to_confirm    USING    'CONFIRM'    " Title
                                         '< 거래명세서취소여부확인 >'
                                         '취소하시겠습니까?'
                                CHANGING lv_answer.
  ELSEIF pi_ucomm EQ 'DOWN'.       " Picking List Download.
    PERFORM popup_to_confirm    USING    'CONFIRM'    " Title
                                         '< Order Picking List >'
                                         'Order Picking List 를 Download하시겠습니까?'
                                CHANGING lv_answer.
  ENDIF.

  IF lv_answer NE 'J'.
    gv_error = 'X'.
*   작업이 취소되었습니다.
    MESSAGE s050  DISPLAY LIKE 'E'.
  ENDIF.

**

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
*& Form delivery_doc_varification
*&---------------------------------------------------------------------*
FORM delivery_doc_varification  USING    pi_ucomm.

**
  CHECK: gv_error  IS INITIAL,
         gt_stab[] IS NOT INITIAL.

  DATA(lt_data) = gt_stab[].

  SELECT b~vbeln
    FROM @lt_data AS a  INNER JOIN zlet0098 AS b
                        ON  a~vbeln = b~vbeln
                        AND a~vstel = '3400'
                        AND a~mtart = 'MCFE'
   GROUP BY b~vbeln
    INTO TABLE @DATA(lt_0098).

  LOOP AT lt_data  INTO DATA(ls_data).

    DATA(ls_0098) = VALUE #( lt_0098[ vbeln = ls_data-vbeln ]
                             OPTIONAL ).

    IF ls_0098 IS INITIAL.

      SELECT SINGLE vbeln  INTO @DATA(lv_zcodi)
        FROM zlet0097  WHERE vbeln EQ @ls_data-vbeln.

      IF lv_zcodi IS INITIAL.

*       미검증 납품 품번 + DO + DO item
        DATA(lv_msg) = |{ TEXT-t01 }| && | { ls_data-vbeln }| && | { ls_data-posnr }|.

        gv_error = 'X'.
*       출하 꼬리표 검증이 완료되지 않았습니다! + Msg.
        MESSAGE s000 WITH TEXT-e03 lv_msg  DISPLAY LIKE 'E'.
        EXIT.

      ENDIF.

    ENDIF.

  ENDLOOP.

**
  FREE: lt_data, lt_0098.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form check_already_printed
*&---------------------------------------------------------------------*
FORM check_already_printed  USING    pi_ucomm.

**
  CHECK: gv_error  IS INITIAL,
         gt_stab[] IS NOT INITIAL,
         rb_new    EQ 'X'.

  DATA(lt_data) = gt_stab[].

  SELECT a~vbeln, a~posnr, a~tknum,
         b~iv_no
    FROM @lt_data AS a  INNER JOIN zlet0006 AS b
                        ON  a~vbeln = b~vbeln
                        AND a~posnr = b~posnr
                        AND a~tknum = b~tknum
                        INNER JOIN zlet0005 AS c
                        ON  b~iv_no = c~iv_no
                        AND c~iv_cancel_yn NE 'X'
    INTO TABLE @DATA(lt_check).

  LOOP AT lt_data  INTO DATA(ls_data).

*___납품문서/품목, 선적문서로 발생한 거래명세서가 존재하면 에러
    DATA(ls_check) = VALUE #( lt_check[ vbeln = ls_data-vbeln
                                        posnr = ls_data-posnr
                                        tknum = ls_data-tknum ]
                              OPTIONAL ).

    IF ls_check IS NOT INITIAL.

      DATA(lv_doc) = ls_data-vbeln && '-' && ls_data-posnr && '/' && ls_data-tknum.

      gv_error = 'X'.
*     납품문서-품목/선적문서' lv_docno
*     로 거래명세서가 이미 발행되었습니다.
*     점검 후 발행하시기 바랍니다.
      MESSAGE s000 WITH TEXT-t02 lv_doc TEXT-t03 TEXT-e04
                   DISPLAY LIKE 'E'.
    ENDIF.

*   스크랩 출하시 계산서 발행 후 가능토록 제어
    PERFORM check_billing_status     USING     ls_data-vbeln
                                               ls_data-posnr
                                               ls_data-matnr
                                               ls_data-vrkme
                                               ls_data-lfimg
                                     CHANGING  gv_error.

    IF gv_error IS NOT INITIAL.
      EXIT.
    ENDIF.

  ENDLOOP.

**
  FREE: lt_check.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form check_billing_status
*&---------------------------------------------------------------------*
FORM check_billing_status    USING     pi_vbeln
                                       pi_posnr
                                       pi_matnr
                                       pi_vrkme
                                       pi_lfimg
                             CHANGING  pe_error.

  DATA: lv_fkimg LIKE zfit0023-fkimg,
        lv_vrkme LIKE zfit0023-vrkme,
        lv_total LIKE zfit0023-fkimg.

**
  CHECK: pe_error IS INITIAL.

**
*___스크랩 자재여부
  SELECT SINGLE a~matnr  INTO @DATA(lv_matnr)
    FROM zsdt0420 AS a  INNER JOIN likp AS b
                        ON a~bukrs = b~vkorg
   WHERE b~vbeln EQ @pi_vbeln
     AND a~matnr EQ @pi_matnr
     AND lvorm   EQ ' '.

  CHECK: sy-subrc = 0.

*___납품문서 품목 상태
  SELECT SINGLE fksta  INTO @DATA(lv_fksta)
    FROM lips  WHERE vbeln EQ @pi_vbeln
                 AND posnr EQ @pi_posnr.

  IF lv_fksta <> 'C'.

    pe_error = 'X'.
*   스크랩 자재는 계산서 발행(승인)후 출력 가능합니다. DO + DO Item
    MESSAGE s000 WITH TEXT-e05  pi_vbeln  pi_posnr   DISPLAY LIKE 'E'.

  ENDIF.

  IF pe_error IS INITIAL.

    SELECT a~vbeln, a~posnr  INTO TABLE @DATA(lt_vbrp)
      FROM vbrp AS a  INNER JOIN vbrk AS b
                      ON a~vbeln = b~vbeln
     WHERE a~vgbel EQ @pi_vbeln
       AND a~vgpos EQ @pi_posnr
       AND a~draft EQ ' '
       AND b~sfakn EQ ' '
       AND b~fksto EQ ' '
       AND b~draft EQ ' '.

    SELECT b~vbeln, b~posnr, b~vrkme, b~fkimg
      FROM @lt_vbrp AS a  INNER JOIN zfit0023 AS b
                          ON  a~vbeln   = b~vbeln
                          AND a~posnr   = b~posnr
                          INNER JOIN zfit0022 AS c
                          ON  b~bukrs = c~bukrs
                          AND b~gjahr = c~gjahr
                          AND b~monat = c~monat
                          AND b~bupla = c~bupla
                          AND b~bilnr = c~bilnr
                          AND c~accsign = 'Y'
                          AND c~isscnt  <> '000'
                          AND c~isstyp NOT IN ('J', 'S', 'C')
      INTO TABLE @DATA(lt_fitab).

    SORT: lt_vbrp   BY vbeln posnr,
          lt_fitab  BY vbeln posnr.

    CLEAR: lv_total.
    LOOP AT lt_vbrp  INTO DATA(ls_vbrp).

      READ TABLE lt_fitab  INTO DATA(ls_fitab)
                           WITH KEY vbeln = ls_vbrp-vbeln
                                    posnr = ls_vbrp-posnr
                           BINARY SEARCH.
      IF sy-subrc = 0.
        LOOP AT lt_fitab  INTO ls_fitab  FROM sy-tabix.
          IF ls_fitab-vbeln = ls_vbrp-vbeln AND
             ls_fitab-posnr = ls_vbrp-posnr.

            CLEAR: lv_fkimg, lv_vrkme.
            lv_fkimg = ls_fitab-fkimg.
            lv_vrkme = ls_fitab-vrkme.

*___________단위에 따른 수량환산
            PERFORM convert_material_unit USING pi_matnr
                                                lv_vrkme
                                                pi_vrkme
                                                lv_fkimg.

            lv_total = lv_total + lv_fkimg.

          ELSE.
            EXIT.
          ENDIF.
        ENDLOOP.
      ENDIF.

    ENDLOOP.

    IF pi_lfimg > lv_total.

      pe_error = 'X'.
*     스크랩 자재는 계산서 발행(승인)후 출력 가능합니다. DO + DO Item
      MESSAGE s000 WITH TEXT-e05  pi_vbeln  pi_posnr   DISPLAY LIKE 'E'.

    ENDIF.

  ENDIF.

**
  FREE: lt_vbrp, lt_fitab.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form convert_material_unit
*&---------------------------------------------------------------------*
FORM convert_material_unit  USING  pi_matnr LIKE mara-matnr
                                   pi_meins LIKE mara-meins
                                   pi_bmein LIKE mara-meins
                                   pi_brgew.

  DATA : lv_brgew  LIKE mara-brgew,
         lv_menge  LIKE ekpo-menge,
         lv_menge1 TYPE p DECIMALS 2,
         lv_meins  LIKE mara-meins.

**
  CHECK pi_meins <> pi_bmein.

  CLEAR : lv_menge, lv_meins.
  SELECT SINGLE meins  INTO @lv_meins
    FROM mara  WHERE matnr EQ @pi_matnr.

  CHECK sy-subrc = 0.

  CALL FUNCTION 'MATERIAL_UNIT_CONVERSION'
    EXPORTING
      matnr                = pi_matnr
      input                = pi_brgew
      meinh                = pi_meins
      kzmeinh              = 'X'
      meins                = lv_meins
    IMPORTING
      output               = lv_menge
    EXCEPTIONS
      conversion_not_found = 01
      input_invalid        = 02
      material_not_found   = 03
      meinh_not_found      = 04
      meins_missing        = 05
      no_meinh             = 06
      output_invalid       = 07
      overflow             = 08.

  IF sy-subrc = 0.
    CALL FUNCTION 'MATERIAL_UNIT_CONVERSION'
      EXPORTING
        matnr                = pi_matnr
        input                = lv_menge
        meinh                = pi_bmein
        kzmeinh              = space
        meins                = lv_meins
      IMPORTING
        output               = lv_menge
      EXCEPTIONS
        conversion_not_found = 01
        input_invalid        = 02
        material_not_found   = 03
        meinh_not_found      = 04
        meins_missing        = 05
        no_meinh             = 06
        output_invalid       = 07
        overflow             = 08.
  ELSE.
    CALL FUNCTION 'UNIT_CONVERSION_SIMPLE'
      EXPORTING
        input                = pi_brgew
        round_sign           = 'X'
        unit_in              = pi_meins
        unit_out             = pi_bmein
      IMPORTING
        output               = lv_menge
      EXCEPTIONS
        conversion_not_found = 1
        division_by_zero     = 2
        input_invalid        = 3
        output_invalid       = 4
        overflow             = 5
        type_invalid         = 6
        units_missing        = 7
        unit_in_not_found    = 8
        unit_out_not_found   = 9
        OTHERS               = 10.
  ENDIF.

  IF sy-subrc = 0.
    lv_menge1 = lv_menge.
    pi_brgew  = lv_menge1.
  ENDIF.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form print_iv_document
*&---------------------------------------------------------------------*
FORM print_iv_document  USING    pi_ucomm.

**
  CHECK: gv_error  IS INITIAL,
         gt_stab[] IS NOT INITIAL.

  IF rb_re = 'X'.    " 재발행
    SORT: gt_stab BY iv_no vbeln posnr.
    DELETE ADJACENT DUPLICATES FROM gt_stab COMPARING iv_no vbeln posnr.
  ELSE.
    SORT: gt_stab BY vbeln posnr.
    DELETE ADJACENT DUPLICATES FROM gt_stab COMPARING vbeln posnr.
  ENDIF.

* A형, B형 구분.
  DATA(lt_stab_a) = gt_stab[].
  DATA(lt_stab_b) = gt_stab[].
  DELETE: lt_stab_a  WHERE werks(2) NE '65',
          lt_stab_b  WHERE werks(2) NE '66'.

  IF lt_stab_a[] IS INITIAL AND
     lt_stab_b[] IS INITIAL.
    gv_error = 'X'.
*   거래명세서를 출력할 대상이 없습니다.
    MESSAGE s000 WITH TEXT-e07  DISPLAY LIKE 'E'.
  ENDIF.

* 미리보기의 경우 출력매수 = 1
  IF pi_ucomm = 'PREVIEW'.      " 미리보기.
    gv_copies = '1'.
  ENDIF.

  _clear: gt_otf,              " Smartform OTF Data
          gt_iv_tab,           " 거래명세서 번호 발행용.
          gt_0005, gt_0006,    " 통문 데이터 저장용.
          gt_2101, gt_2102.    " 거래명세서 발행 내용 저장용.

* A형(군포용) Print
  PERFORM print_document_from_plant  TABLES   lt_stab_a
                                     USING    'A'
                                              pi_ucomm
                                     CHANGING gv_error.

* B형(전주용) Print
  PERFORM print_document_from_plant  TABLES   lt_stab_b
                                     USING    'B'
                                              pi_ucomm
                                     CHANGING gv_error.

* Smartform Print from OTF
  PERFORM smartform_print_with_otf   USING    pi_ucomm
                                     CHANGING gv_error.

  IF gv_error IS NOT INITIAL.
*   거래명세서 발행실패 다시 시도하세요!
    MESSAGE s000 WITH TEXT-e07  DISPLAY LIKE 'E'.
  ENDIF.

* Update Table.
  PERFORM update_db_data             USING    pi_ucomm
                                     CHANGING gv_error.

* Send Print Data.
*  PERFORM send_print_data            USING    pi_ucomm
*                                     CHANGING gv_error.

* Send MES.
  PERFORM send_to_mes                USING    pi_ucomm
                                     CHANGING gv_error.

*  SORT lt_iv.
*  DELETE ADJACENT DUPLICATES FROM lt_iv COMPARING ALL FIELDS.
*  LOOP AT lt_iv.
*    gv_iv_no = lt_iv-iv_no.
*    PERFORM send_mes.
*  ENDLOOP.

  IF gv_error IS INITIAL.
*   거래명세서를 성공적으로 발행하였습니다.
    MESSAGE s000 WITH TEXT-s01.

*   신규발행 후 다시 발행하지 못하도록 설정.
    IF rb_new = 'X'.    " 신규발행.

      PERFORM update_iv_no_to_disp_list  TABLES: lt_stab_a,
                                                 lt_stab_b.

    ENDIF.
  ENDIF.

**
  FREE: lt_stab_a, lt_stab_b.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form print_document_from_plant
*&---------------------------------------------------------------------*
FORM print_document_from_plant  TABLES   pt_tab STRUCTURE gt_list
                                USING    pi_type
                                         pi_ucomm
                                CHANGING pe_error.

  DATA: lv_iv_no      LIKE zlet0005-iv_no,
        lv_iv_date    LIKE zlet0005-iv_date,
        lv_title(20),
        lv_prt_cnt(1),

        ls_head       LIKE zgtsds1001,
        ls_iv_info    LIKE zgtsds1003,
        lt_item_tm    LIKE gt_list OCCURS 0 WITH HEADER LINE,
        lt_item       TYPE TABLE OF zgtsds1002,
        lt_remark     LIKE TABLE OF gt_list.
*        lt_remark    TYPE TABLE OF zgtsds1002.

**
  CHECK: pe_error IS INITIAL,
         pt_tab[] IS NOT INITIAL.

* Do no / 납품처 / 판매처 별로 거래명세서 발행.
  DATA(lt_tab) = pt_tab[].

* 재발행의 경우 IV NO 별로 재발행을 해야 하나??
  IF     rb_new = 'X'.    " 신규발행.
    SORT: lt_tab BY vbeln kunnr kunag.
    DELETE ADJACENT DUPLICATES FROM lt_tab COMPARING vbeln kunnr kunag.

  ELSEIF rb_re = 'X'.    " 재발행
    SORT: lt_tab BY vbeln kunnr kunag iv_no.
    DELETE ADJACENT DUPLICATES FROM lt_tab COMPARING vbeln kunnr kunag iv_no.

  ENDIF.

  LOOP AT lt_tab  INTO DATA(ls_tab).

*   거래명세서 Title set.
    CLEAR: lv_title.
    IF ls_tab-route+3(3) = '001'.
      lv_title = '거래명세서(보관품)'.
    ELSE.

      SELECT SINGLE auart
        FROM vbak  WHERE vbeln EQ @ls_tab-vgbel
        INTO @DATA(lv_auart).

      IF lv_auart = 'ZCS'.
        lv_title = '거래명세서(보관출고)'.
      ELSE.
        lv_title = '거 래 명 세 서'.
      ENDIF.

    ENDIF.

*   1) 거래명세서 번호, 발행일 Get
    CLEAR: lv_iv_no, lv_iv_date.
    PERFORM set_iv_no_date           USING     ls_tab
                                               pi_ucomm
                                     CHANGING  lv_iv_no
                                               lv_iv_date.
*    perform
    CLEAR: ls_head, ls_iv_info.
    _clear: lt_item, lt_remark,
            lt_item_tm.
*   1) Smartforms Item Data and Sum Data.
    PERFORM make_doc_item_data       TABLES    pt_tab
                                               lt_item    " Smartform Item
                                               lt_remark  " Remark Setting
                                               lt_item_tm " TOOGMOON Item
                                     USING     ls_tab
                                               pi_type
                                               pi_ucomm
                                               lv_iv_no
                                               lv_iv_date
                                     CHANGING  ls_head.

*   2) Smartforms Header Data Create.
    PERFORM make_doc_header_data     TABLES    lt_remark
                                     USING     ls_tab
                                               pi_type
                                               pi_ucomm
                                               lv_iv_no
                                               lv_iv_date
                                     CHANGING  ls_head
                                               ls_iv_info.


*   3) 통문 Header Save.
    PERFORM make_tong_moon_header    USING     pi_ucomm
                                               lv_iv_no
                                               lv_iv_date
                                               ls_tab
                                               ls_head.

*   4) 통문 Item Save.
    PERFORM make_tong_moon_item      TABLES    lt_item_tm
                                     USING     pi_ucomm
                                               lv_iv_no
                                               lv_iv_date
                                               ls_tab
                                               ls_head.

** 출력장수 별 Title 변경
    CLEAR: lv_prt_cnt.
    DO gv_copies TIMES.
*   5) Smartforms Set
      lv_prt_cnt = lv_prt_cnt + 1.

      PERFORM smartforms_setting       TABLES    lt_item
                                       USING     pi_type
                                                 pi_ucomm
                                                 lv_title
                                                 lv_prt_cnt
                                                 ls_head
                                                 ls_iv_info
                                       CHANGING  pe_error.
    ENDDO.

*   6) 거래명세서 발행내용 저장용
    PERFORM make_iv_doc_save_data    TABLES    lt_item
                                     USING     pi_ucomm
                                               ls_iv_info
                                               ls_head
                                               ls_tab-vbeln
                                               ls_tab-kunag
                                               ls_tab-vstel
                                     CHANGING  pe_error.

*   신규발행 후 다시 발행하지 못하도록 설정.
    IF rb_new = 'X'.    " 신규발행.

      MODIFY pt_tab  FROM VALUE #( iv_no = lv_iv_no )
                     TRANSPORTING iv_no
                     WHERE vbeln = ls_tab-vbeln
                       AND kunnr = ls_tab-kunnr
                       AND kunag = ls_tab-kunag.

    ENDIF.

  ENDLOOP.

**
  FREE: lt_tab.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form set_iv_no_date
*&---------------------------------------------------------------------*
FORM set_iv_no_date  USING    ps_data      LIKE gt_list
                              pi_ucomm     LIKE sy-ucomm
                     CHANGING pe_iv_no
                              pe_iv_date.

**
  IF     rb_new = 'X'.    " 신규발행
    IF     pi_ucomm EQ 'PRINT'.      " 발행.
      PERFORM make_iv_no     CHANGING pe_iv_no
                                      pe_iv_date.

    ELSEIF pi_ucomm EQ 'PREVIEW'.    " 미리보기.
*      pe_iv_no   = ps_data-iv_no.
      pe_iv_date = sy-datlo.

    ENDIF.


  ELSEIF rb_re = 'X'.    " 재발행
    pe_iv_no   = ps_data-iv_no.
    pe_iv_date = ps_data-iv_date.

  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form make_iv_no
*&---------------------------------------------------------------------*
FORM make_iv_no  CHANGING pe_iv_no
                          pe_iv_date.

  DATA: lr_iv_no      LIKE RANGE OF zlet0005-iv_no,
        lv_iv_no      LIKE zlet0005-iv_no,
        lv_yymmdd(6),
        lv_yymmdd*(7).

**
*  IV No : YYMMDD + Seq(4).
  _clear: lr_iv_no.
  CLEAR: lv_yymmdd, lv_yymmdd*.
  lv_yymmdd  = sy-datlo+2(6).
  lv_yymmdd* = sy-datlo+2(6) && '*'.
  lr_iv_no = VALUE #( ( sign = 'I'  option = 'CP'  low = lv_yymmdd* ) ).

  CLEAR: lv_iv_no.
  IF gt_iv_tab[] IS NOT INITIAL.

    SORT: gt_iv_tab DESCENDING BY iv_no.

    DATA(ls_iv) = VALUE #( gt_iv_tab[ 1 ]  OPTIONAL ).

    IF ls_iv-iv_no(6) NE lv_yymmdd.
      CLEAR: lv_iv_no.
    ELSE.
      lv_iv_no   = ls_iv-iv_no.
      pe_iv_date = ls_iv-iv_date.
    ENDIF.

  ELSE.
    SELECT MAX( iv_no )  INTO @lv_iv_no
      FROM zlet0005  WHERE iv_no IN @lr_iv_no.

    IF lv_iv_no IS NOT INITIAL.
      pe_iv_date = sy-datlo.
    ENDIF.

  ENDIF.

  IF lv_iv_no IS NOT INITIAL.
    pe_iv_no = lv_iv_no + 1.

  ELSE.
    pe_iv_no   = sy-datlo+2(6) && '0001'.
    pe_iv_date = sy-datlo.
  ENDIF.

* Append
  APPEND VALUE #( iv_no   = pe_iv_no
                  iv_date = pe_iv_date
                 )  TO gt_iv_tab.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form make_doc_item_data
*&---------------------------------------------------------------------*
FORM make_doc_item_data  TABLES   pt_data     STRUCTURE gt_list
                                  pt_item     STRUCTURE zgtsds1002
                                  pt_remark   STRUCTURE gt_list "zgtsds1002
                                  pt_item_tm  STRUCTURE gt_list
                         USING    ps_tab      LIKE gt_list
                                  pi_type
                                  pi_ucomm
                                  pi_iv_no
                                  pi_iv_date
                         CHANGING ps_head     LIKE zgtsds1001.

  DATA: ls_item              LIKE zgtsds1002,
        ls_remark            LIKE gt_list,  " zgtsds1002,

        lv_vrkme             TYPE vbap-vrkme,
        lv_fiber             TYPE p DECIMALS 2,         " F 량 계산.

        lv_convt_brgew       LIKE mara-brgew ,          " Convert 중량
        lv_convt_kgw         TYPE /nfm/kgw ,            " Convert 동량
        lv_gewei             TYPE mara-gewei,

        lv_total             LIKE lips-lfimg ,          " 납품수량
        lv_total_brgew       LIKE mara-brgew ,          " 중량
        lv_total_brgew_c(20),                      " 중량
        lv_total_ntgew       LIKE mara-ntgew ,          " 순중량
        lv_total_ntgew_c(20),                      " 순중량
        lv_total_kgw         TYPE /nfm/kgw ,            " 동량
        lv_total_kgw_c(20),                       " 동량
        lv_total_f           TYPE p DECIMALS 2,         " F 량
        lv_ntgew             TYPE lips-ntgew,
        lv_length_cnt        LIKE conf_out-atwrt ,      " 조장수
        lv_length_cnt_i(10)  TYPE i.

**
  CHECK: ps_tab IS NOT INITIAL.

  DATA(lt_data) = pt_data[].
  SORT: lt_data BY vbeln kunnr kunag iv_no.

  IF     rb_new = 'X'.    " 신규발행.
    READ TABLE lt_data  INTO DATA(ls_data)
                        WITH KEY vbeln = ps_tab-vbeln
                                 kunnr = ps_tab-kunnr
                                 kunag = ps_tab-kunag
                        BINARY SEARCH.
    IF sy-subrc = 0.
      DATA(lv_index) = sy-tabix.
    ENDIF.

  ELSEIF rb_re = 'X'.    " 재발행
    CLEAR: ls_data, lv_index.
    READ TABLE lt_data  INTO ls_data
                        WITH KEY vbeln = ps_tab-vbeln
                                 kunnr = ps_tab-kunnr
                                 kunag = ps_tab-kunag
                                 iv_no = pi_iv_no
                        BINARY SEARCH.
    IF sy-subrc = 0.
      lv_index = sy-tabix.
    ENDIF.

  ENDIF.

  CLEAR: ls_data,  lv_vrkme,
         lv_total, lv_total_brgew, lv_total_kgw, lv_total_f, lv_length_cnt,
         lv_total_ntgew,lv_total_ntgew_c,
         lv_total_brgew_c, lv_total_kgw_c, lv_length_cnt_i.

  LOOP AT lt_data  INTO ls_data  FROM lv_index.
*    clear:lv_ntgew.
    IF ls_data-vbeln = ps_tab-vbeln AND
       ls_data-kunnr = ps_tab-kunnr AND
       ls_data-kunag = ps_tab-kunag.

      IF rb_re = 'X' AND    " 재발행
         ls_data-iv_no NE pi_iv_no.
        EXIT.
      ENDIF.

      lv_total       = lv_total       + ls_data-lfimg.   " 납품수량
      lv_length_cnt  = lv_length_cnt  + ls_data-factor.  " 조장수
      lv_total_kgw   = lv_total_kgw   + ls_data-kgw.     " 동량

      lv_total_ntgew = lv_total_ntgew + ls_data-ntgew.   " 순중량

*      clear ls_lips_tmp.

      IF     pi_type = 'A'.    " A형(군포용)
        lv_total_brgew = lv_total_brgew + ls_data-total_brgew.   " 총중량

      ELSEIF pi_type = 'B'.    " B형(전주용)
        CLEAR: lv_fiber.
        lv_fiber = ls_data-fiber_c.
        lv_total_f     = lv_total_f     + lv_fiber.        " F 량 계산.

      ENDIF.

      CLEAR: ls_item, ls_remark.
      MOVE-CORRESPONDING: ls_data TO ls_item.
      ls_item-vbeln_va = ls_data-vgbel.
      ls_item-posnr_va = ls_data-vgpos.
      ls_item-arktx    = ls_data-maktx.
      ls_item-os       = ls_data-fixmg.

**    Color / STr 띄줄 추가
      IF ls_data-str IS NOT INITIAL OR
         ls_data-str_no IS NOT INITIAL.
        CONDENSE: ls_item-color  NO-GAPS,
                  ls_data-str    NO-GAPS,
                  ls_data-str_no NO-GAPS.
        ls_item-color = ls_item-color && '/' && ls_data-str_no && ls_data-str.
      ENDIF.

      lv_gewei = ls_data-gewei.

      PERFORM convt_number_to_char
              USING: 'C0'  ls_data-length   CHANGING ls_item-length,
                     'C0'  ls_data-factor   CHANGING ls_item-factor,
                     'P1'  ls_data-kgw      CHANGING ls_item-kgw,
*                     'P1'  lv_convt_kgw     CHANGING ls_item-kgw,
                     'P'   ls_data-fiber    CHANGING ls_item-fiber,
                     'P0'  ls_data-lfimg    CHANGING ls_item-lfimg_c.
*                     'P0'  ls_data-plan_dia CHANGING ls_item-plan_dia_c,
*                     'P0'  ls_data-out_wid  CHANGING ls_item-out_wid_c.

      CLEAR: ls_item-fiber.
      IF pi_type = 'B'.    " B형(전주용)
        PERFORM convt_number_to_char
                USING: 'C' ls_data-fiber_c   CHANGING ls_item-fiber.
      ENDIF.

*     REMARK : 구 작번이 존재하면 출력, 없으면 보관출고 오더의 경우, Original SO번호-항번
      CLEAR: ls_item-remark.
      SELECT SINGLE bstkd_e
        FROM vbkd  WHERE vbeln EQ @ls_data-vgbel
                     AND posnr EQ @ls_data-vgpos
        INTO @DATA(lv_bstkd_e).

      IF lv_bstkd_e IS NOT INITIAL.
        ls_item-remark = lv_bstkd_e.
      ELSE.

        SELECT SINGLE b~auart, a~vgbel, a~vgpos
          FROM vbap AS a  INNER JOIN vbak AS b
                          ON a~vbeln EQ b~vbeln
         WHERE a~vbeln EQ @ls_data-vgbel
           AND a~posnr EQ @ls_data-vgpos
          INTO @DATA(ls_vg_info).

        IF ls_vg_info-auart = 'ZCS'.

          IF ls_vg_info-vgbel IS NOT INITIAL.
            ls_item-remark = |{ ls_vg_info-vgbel }| && '-' &&
                             |{ ls_vg_info-vgpos ALPHA = OUT }|.
          ENDIF.

        ENDIF.

      ENDIF.

**    Remark 에 저장위치 구분 추가 ( 3410/공, 3420/주, 3430/문 ).
      IF pi_type = 'A'.    " 군포
        IF     ls_data-lgort = '3410'.
          ls_item-remark = ls_item-remark && '/공'.
        ELSEIF ls_data-lgort = '3420'.
          ls_item-remark = ls_item-remark && '/주'.
        ELSEIF ls_data-lgort = '3430'.
          ls_item-remark = ls_item-remark && '/문'.
        ENDIF.
      ENDIF.
**

      ls_item-posnr_prt = |{ ls_item-posnr_va ALPHA = OUT }|.
      CONDENSE ls_item-posnr_prt NO-GAPS.

*      CLEAR: ls_item-remark.
      APPEND ls_item TO pt_item.

*     특기사항
      ls_remark-remark = ls_data-remark.
      APPEND ls_remark TO pt_remark.

*     통문 Item 저장용.
      APPEND ls_data TO pt_item_tm.

*     단위
      lv_vrkme = ls_data-vrkme.

    ELSE.
      EXIT.
    ENDIF.
  ENDLOOP.

  IF     pi_type = 'A'.    " A형(군포용)

    PERFORM convt_weight_simple           USING:   lv_total_brgew
                                                   lv_gewei
                                                   'KG'
                                          CHANGING lv_convt_brgew.
*                                                   lv_total_kgw
*                                                   lv_gewei
*                                                   'KG'
*                                          CHANGING lv_convt_kgw.
    PERFORM convt_number_to_char
*                  중량 Total
            USING: 'P1'   lv_convt_brgew  CHANGING lv_total_brgew_c,
*                  동량 Total
                   'P1'   lv_total_kgw    CHANGING lv_total_kgw_c.

    PERFORM convt_number_to_char USING 'P1' lv_total_ntgew
                                 CHANGING lv_total_ntgew_c.

*   총중량 = 총중량 / 총동량
*    ps_head-total_brgew = |{ lv_total_brgew_c }| && | { '/' } | && |{ lv_total_kgw_c }|.
*   총중량 = 총중량 / 순중량
    ps_head-total_brgew = |{ lv_total_brgew_c }| && | { '/' } | && |{ lv_total_ntgew_c }|.

  ELSEIF pi_type = 'B'.    " B형(전주용)

    PERFORM convt_number_to_char
*                동량 Total
            USING: 'P1'   lv_total_kgw     CHANGING ps_head-total_kgw,
*                F 량 계산 Total
                   'P'   lv_total_f       CHANGING ps_head-total_f.

  ENDIF.

  PERFORM convt_number_to_char
*                납품수량 Total
          USING: 'P0'  lv_total         CHANGING ps_head-total,
*                조장수 Total
                 'C0'  lv_length_cnt    CHANGING ps_head-length_cnt.

**
  FREE: lt_data.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form make_doc_header_data
*&---------------------------------------------------------------------*
FORM make_doc_header_data  TABLES   pt_remark  STRUCTURE gt_list  "zgtsds1002
                           USING    ps_tab     LIKE gt_list
                                    pi_type
                                    pi_ucomm
                                    pi_iv_no
                                    pi_iv_date
                           CHANGING ps_head    LIKE zgtsds1001
                                    ps_iv_info LIKE zgtsds1003.

  DATA: ls_adrc      LIKE adrc,
        lv_addr      LIKE zgtsds1001-we_addr,
        lv_telno(30),
        lv_faxno(30).

**
** 도착예정일, 도착예정시간 추가
  SELECT SINGLE b~arrdt, b~arrtm
    FROM zlet0402 AS a  INNER JOIN zlet0400 AS b
                        ON a~dlvrq EQ b~dlvrq
   WHERE a~vgbel EQ @ps_tab-vbeln
    INTO @DATA(ls_arr_date).
**
* 거래명세서 번호
  ps_iv_info = VALUE #( BASE ps_iv_info
                        iv_no    = pi_iv_no      " 거래명세서 번호
                        iv_date  = pi_iv_date    " 거래명세서 발행일자
                        arrdt    = ls_arr_date-arrdt " 도착일
                        arrtm    = ls_arr_date-arrtm " 도착시간
                       ).

* 공급자 등록번호
  SELECT SINGLE a~stcd2  INTO @DATA(lv_stcd2)
    FROM j_1bbranch AS a  INNER JOIN t001w AS b
                          ON a~branch = b~j_1bbranch
   WHERE b~werks EQ @ps_tab-werks.

  IF lv_stcd2 IS NOT INITIAL.
    ps_head-we_stcd2 = lv_stcd2+0(3) && '-' && lv_stcd2+3(2) && '-' && lv_stcd2+5(5).
  ENDIF.

* 공급자 상호
  SELECT SINGLE a~butxt  INTO @ps_head-we_butxt
    FROM t001 AS a  INNER JOIN vbak AS b
                    ON a~bukrs = b~bukrs_vf
   WHERE b~vbeln EQ @ps_tab-vgbel.

* 공급자 주소 / 전화번호
  SELECT SINGLE adrnr  INTO @DATA(lv_adrnr)
    FROM tvst  WHERE vstel EQ @ps_tab-vstel.

  CLEAR: ls_adrc.
  PERFORM get_address_from_adrc   USING    lv_adrnr
                                  CHANGING ls_adrc.

  ps_head-we_addr = |{ ls_adrc-city1 }| && | ' ' | && |{ ls_adrc-street }|.

* 공급자 주소에 대한 자릿수 조정.
  CLEAR: lv_addr.
  lv_addr = ps_head-we_addr.
  PERFORM set_wrap_from_address   USING    lv_addr  'H'
                                  CHANGING ps_head-we_addr
                                           ps_head-we_addr2.

  CLEAR: lv_telno, lv_faxno.
  IF ls_adrc-tel_number IS NOT INITIAL.
    lv_telno = |{ 'TEL)' } | && ls_adrc-tel_number.
  ENDIF.
  IF ls_adrc-fax_number IS NOT INITIAL.
    lv_faxno = |{ 'FAX)' } | && ls_adrc-fax_number.
  ENDIF.

  IF lv_telno IS NOT INITIAL.
    ps_head-we_cont_number = |{ lv_telno }   | && lv_faxno.
  ELSE.
    ps_head-we_cont_number = lv_faxno.
  ENDIF.
  IF ps_head-we_cont_number IS INITIAL.
    ps_head-we_cont_number = 'TEL)'.
  ENDIF.

* 공급받는자 등록번호 / 상호 / 주소
  CLEAR: lv_stcd2, lv_adrnr.
  SELECT SINGLE stcd2, adrnr  INTO (@lv_stcd2, @lv_adrnr)
    FROM kna1  WHERE kunnr EQ @ps_tab-kunag.

  IF lv_stcd2 IS NOT INITIAL.
    ps_head-ag_stcd2 = lv_stcd2+0(3) && '-' && lv_stcd2+3(2) && '-' && lv_stcd2+5(5).
  ENDIF.

  CLEAR: ls_adrc.
  PERFORM get_address_from_adrc   USING    lv_adrnr
                                  CHANGING ls_adrc.

*[S] 안정화 GW20260827004
* as-is :  ps_head-ag_butxt = ls_adrc-name1.
* to-be start
  IF     pi_type EQ 'A'.
    ps_head-ag_butxt = |{ ls_adrc-name1 } ({ condense( |{ ps_tab-kunag ALPHA = OUT }| ) })|.
  ELSE.
    ps_head-ag_butxt = ls_adrc-name1.
  ENDIF.
* to-be end
*[E] 안정화 GW20260827004


  ps_head-ag_addr  = |{ ls_adrc-city1 } | && |{ ls_adrc-street }|.

* 공급받는자 주소에 대한 자릿수 조정.
*  CLEAR: lv_addr.
*  lv_addr = ps_head-ag_addr.
*  PERFORM set_wrap_from_address   USING    lv_addr  'H'
*                                  CHANGING ps_head-ag_addr
*                                           ps_head-ag_addr2.
* 공급받는자 주소 변경.

*  ps_head-ag_addr = ' 납지 참조'.
*  CLEAR: ps_head-ag_addr2.

* 납지
  " VBAK-AUART = 'ZOT'
  SELECT SINGLE auart
    FROM vbak
   WHERE vbeln EQ @ps_tab-vgbel
    INTO @DATA(lv_auart).
  IF lv_auart EQ 'ZOT'.
    ps_head-address = |{ ps_tab-city1 } | && '/' && | { ps_tab-extension1 } |.
  ELSE.
    ps_head-address = |{ ps_tab-city1 } | && '/' && | { ps_tab-extension1 } | && '/' &&
                      | { ps_tab-tel_number }|.
  ENDIF.

* 공급받는자 주소
* 전주의 경우 '납지참조' -> 실주소변경
  IF     pi_type EQ 'A'.
    ps_head-ag_addr = ' 납지 참조'.
    CLEAR: ps_head-ag_addr2.

*[S] 안정화      GW20260826001
    ps_head-ag_addr2 = | 선적번호 : { ps_tab-tknum ALPHA = OUT }|.
*[E] 안정화      GW20260826001

  ELSEIF pi_type EQ 'B'.
*    ps_head-ag_addr = ps_head-address.
    CLEAR: lv_addr.
    lv_addr = ps_head-address.
    PERFORM set_wrap_from_address   USING    lv_addr  'H'
                                    CHANGING ps_head-ag_addr
                                             ps_head-ag_addr2.
  ENDIF.

* 수령인 / 수령인 연락처
  ps_head-extension1 = ps_tab-extension1.
  ps_head-tel_number = ps_tab-tel_number.

* 특기사항.
  SORT: pt_remark BY remark.
  DELETE ADJACENT DUPLICATES FROM pt_remark COMPARING remark.

  LOOP AT pt_remark  INTO DATA(ls_remark).

    IF ps_head-remark IS INITIAL.
      ps_head-remark = ls_remark-remark.
    ELSE.
      ps_head-remark = |{ ps_head-remark } | && |{ '/' }| && | { ls_remark-remark }|.
    ENDIF.

  ENDLOOP.

* 특기사항에 대한 자릿수 조정.
  CLEAR: lv_addr.
  lv_addr = ps_head-remark.
  PERFORM set_wrap_from_address   USING    lv_addr  'T'
                                  CHANGING ps_head-remark
                                           ps_head-remark2.

* 납지에 대한 자릿수 조정.
  CLEAR: lv_addr.
  lv_addr = ps_head-address.
  PERFORM set_wrap_from_address   USING    lv_addr  'T'
                                  CHANGING ps_head-address
                                           ps_head-address2.

  ps_head-truck_no     = ps_tab-exti1 .          " 차량번호
  ps_head-driver_nm    = ps_tab-exti2 .          " 운전자명
  ps_head-driver_telno = ps_tab-tpbez .          " 전화번호

* 상기 물품의 외관 및 수량에 이상 없음을 확인함.
  ps_head-check_text = TEXT-t04.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form get_address_from_adrc
*&---------------------------------------------------------------------*
FORM get_address_from_adrc  USING    pi_adrnr
                            CHANGING ps_adrc   LIKE adrc.

  DATA: lv_addrnumber  TYPE ad_addrnum.

**
  CHECK: pi_adrnr IS NOT INITIAL.

  CLEAR: lv_addrnumber.
  lv_addrnumber = pi_adrnr.

  SELECT SINGLE *  INTO @ps_adrc
    FROM adrc  WHERE addrnumber EQ @lv_addrnumber.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form set_wrap_from_address
*&---------------------------------------------------------------------*
FORM set_wrap_from_address  USING    pi_addr
                                     pi_type
                            CHANGING pe_out_addr1
                                     pe_out_addr2.

  DATA: lv_text(100)      TYPE c,
        lv_out_text1(100) TYPE c,
        lv_out_text2(100) TYPE c,
        lv_out_text3(100) TYPE c,
        lv_outputlen(3)   TYPE i.

**
  CHECK: pi_addr IS NOT INITIAL.

  CLEAR: lv_text, lv_out_text1, lv_out_text2, lv_out_text3,
         lv_outputlen.

  lv_text      = pi_addr.

  IF     pi_type = 'H'.
*    lv_outputlen = '35'.
    lv_outputlen = '40'.
  ELSEIF pi_type = 'T'.
*    lv_outputlen = '55'.
    lv_outputlen = '60'.
  ENDIF.

  CALL FUNCTION 'RKD_WORD_WRAP'
    EXPORTING
      textline            = lv_text
      outputlen           = lv_outputlen
    IMPORTING
      out_line1           = lv_out_text1
      out_line2           = lv_out_text2
      out_line3           = lv_out_text3
    EXCEPTIONS
      outputlen_too_large = 1
      OTHERS              = 2.

  CLEAR: pe_out_addr1, pe_out_addr2.
  pe_out_addr1  = lv_out_text1.
  CONDENSE pe_out_addr1.
  pe_out_addr2  = |{ lv_out_text2 }| && | { lv_out_text3 }|.
  CONDENSE pe_out_addr2.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form check_delivery_address
*&---------------------------------------------------------------------*
FORM check_delivery_address  USING    pi_ucomm.

*  DATA: lv_city1  LIKE zlet0400-city1 ,      " 납지
  DATA: lv_city1(100) ,      " 납지
        lv_chk(1).

**
  CHECK: gv_error  IS INITIAL,
         gt_stab[] IS NOT INITIAL.

  DATA(lt_tab) = gt_stab[].

  IF     rb_new = 'X'.    " 신규발행.
    SORT: lt_tab BY kunnr kunag city1.
    DELETE ADJACENT DUPLICATES FROM lt_tab COMPARING kunnr kunag city1.

  ELSEIF rb_re = 'X'.    " 재발행
    SORT: lt_tab BY kunnr kunag iv_no city1.
    DELETE ADJACENT DUPLICATES FROM lt_tab COMPARING kunnr kunag iv_no city1.

  ENDIF.

  CLEAR: lv_city1.
  LOOP AT lt_tab  INTO DATA(ls_tab).

    CLEAR: lv_chk.

    IF lv_city1 IS INITIAL.
      lv_city1 = ls_tab-city1.
    ELSE.
      IF lv_city1 <> ls_tab-city1.
        gv_error = 'X'.
*       납지가 2개 이상 존재합니다.
        MESSAGE s000 WITH TEXT-e06  DISPLAY LIKE 'E'.
        EXIT.
      ENDIF.
    ENDIF.

    AT END OF kunnr.
      lv_chk = 'X'.
    ENDAT.
    AT END OF kunag.
      lv_chk = 'X'.
    ENDAT.
    IF rb_re = 'X'.    " 재발행
      AT END OF iv_no.
        lv_chk = 'X'.
      ENDAT.
    ENDIF.

    IF lv_chk = 'X'.

      IF lv_city1 IS NOT INITIAL.
        IF lv_city1 <> ls_tab-city1.
          gv_error = 'X'.
*         납지가 2개 이상 존재합니다.
          MESSAGE s000 WITH TEXT-e06  DISPLAY LIKE 'E'.
          EXIT.
        ENDIF.
      ENDIF.

      CLEAR: lv_city1.

    ENDIF.

  ENDLOOP.

**
  FREE: lt_tab.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form make_tong_moon_header
*&---------------------------------------------------------------------*
FORM make_tong_moon_header  USING    pi_ucomm
                                     pi_iv_no
                                     pi_iv_date
                                     ps_data     LIKE gt_list
                                     ps_head     LIKE zgtsds1001.

**
  CHECK: pi_ucomm EQ 'PRINT'.      " 발행.
*         pi_ucomm EQ 'PREVIEW'.    " 미리보기.

  APPEND VALUE #( iv_no          = pi_iv_no             " 거래명세서번호
                  iv_date        = pi_iv_date           " 거래명세서 발행일자
                  iv_type        = ps_data-iv_type      " 통문유형
                  bzarea         = p_bzarea             " 사업장
                  iv_print_yn    = 'X'                  " 거래명세서 발행여부
                  print_cnt      = 1
                  truck_no       = ps_head-truck_no     " 차량번호
                  driver_nm      = ps_head-driver_nm    " 운전자명
                  driver_telno   = ps_head-driver_telno " 운전기사 전화번호
                  create_user_id = sy-uname
                  create_date    = sy-datum
                  create_time    = sy-uzeit
                  werks          = ps_data-werks
                  kunnr          = ps_data-kunnr
                  ename          = sy-uname
                 ) TO gt_0005.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form make_tong_moon_item
*&---------------------------------------------------------------------*
FORM make_tong_moon_item  TABLES   pt_item     STRUCTURE gt_list
                          USING    pi_ucomm
                                   pi_iv_no
                                   pi_iv_date
                                   ps_data     LIKE gt_list
                                   ps_head     LIKE zgtsds1001.

  DATA: lv_seq   TYPE i.

**
  CHECK: pi_ucomm EQ 'PRINT'.      " 발행.
*         pi_ucomm EQ 'PREVIEW'.    " 미리보기.

  CLEAR: lv_seq.

  LOOP AT pt_item  INTO DATA(ls_item).

    lv_seq = lv_seq + 1.

    APPEND VALUE #( iv_no    = pi_iv_no
                    iv_seq   = lv_seq
                    vbeln    = ls_item-vbeln
                    posnr    = ls_item-posnr
                    matnr    = ls_item-matnr
                    tknum    = ls_item-tknum
                    sdabw    = ls_item-sdabw
                    maktx    = ls_item-maktx
                    lfimg    = ls_item-lfimg
                    mtr_unit = ls_item-vrkme
                   ) TO gt_0006.

  ENDLOOP.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form smartforms_setting
*&---------------------------------------------------------------------*
FORM smartforms_setting  TABLES   pt_item    STRUCTURE zgtsds1002
                         USING    pi_type
                                  pi_ucomm
                                  pi_title
                                  pi_prt_cnt
                                  ps_head    LIKE zgtsds1001
                                  ps_iv_info LIKE zgtsds1003
                         CHANGING pe_error.

  DATA: lv_title(30),

        lv_reprint(20),
        lv_formname(30),
        lv_func_name          LIKE rs38l-name,
        ls_control_parameters TYPE ssfctrlop,
        ls_output_options     TYPE ssfcompop,
        ls_ssfcrespd          TYPE ssfcrespd,
        ls_ssfcrescl          TYPE ssfcrescl,
        ls_ssfcresop          TYPE ssfcresop.

**
  CHECK: pe_error  IS INITIAL,
         ps_head   IS NOT INITIAL,
         pt_item[] IS NOT INITIAL.

  CLEAR: lv_formname.
  IF     pi_type = 'A'.    " A형(군포용)
*    lv_formname = 'ZGTSD_TRANS_DOC_01'.
    lv_formname = 'ZGTSD_TRANS_DOC_01N'.

  ELSEIF pi_type = 'B'.    " B형(전주용)
*    lv_formname = 'ZGTSD_TRANS_DOC_02'.
    lv_formname = 'ZGTSD_TRANS_DOC_02N'.

  ENDIF.

  CLEAR: lv_func_name.
  CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
    EXPORTING
      formname           = lv_formname
    IMPORTING
      fm_name            = lv_func_name
    EXCEPTIONS
      no_form            = 1
      no_function_module = 2
      OTHERS             = 3.

  CHECK: lv_func_name IS NOT INITIAL.

*** 재발행 표시: 향후 사용?
*  CLEAR: lv_reprint.
*  IF rb_re = 'X'.
*    lv_reprint = '(재 발 행)'.
*  ENDIF.
***

  CLEAR: ls_control_parameters,
         ls_output_options.
  ls_control_parameters-getotf    = 'X'.
  ls_control_parameters-no_dialog = 'X'.

  ls_output_options-tddest = 'ZP01'.
  IF pi_ucomm EQ 'PREVIEW'.    " 미리보기.
    ls_output_options-tdnoprint = 'X'.
  ELSE.
    CLEAR: ls_output_options-tdnoprint.
  ENDIF.

  CLEAR: ls_ssfcrespd, ls_ssfcrescl, ls_ssfcresop.

** 출력장수 별 Title 변경
  CLEAR: lv_title.
  DATA(lv_add_txt) = VALUE #( gt_prt_title[ seq = pi_prt_cnt ]-title
                              OPTIONAL ).
  IF lv_add_txt IS NOT INITIAL.
    lv_title = pi_title && '(' && lv_add_txt && ')'.
  ELSE.
    lv_title = pi_title.
  ENDIF.

* Call Smartform Function.
  CALL FUNCTION lv_func_name
    EXPORTING
      control_parameters   = ls_control_parameters
      output_options       = ls_output_options
      user_settings        = ' '
      i_title              = lv_title    " pi_title
      i_reprint            = lv_reprint
      gs_iv_info           = ps_iv_info
      gs_header            = ps_head
    IMPORTING
      document_output_info = ls_ssfcrespd
      job_output_info      = ls_ssfcrescl
      job_output_options   = ls_ssfcresop
    TABLES
      gt_item              = pt_item
    EXCEPTIONS
      formatting_error     = 1
      internal_error       = 2
      send_error           = 3
      user_canceled        = 4
      OTHERS               = 5.

  IF sy-subrc <> 0.
    pe_error = 'X'.
*   거래명세서 발행에 실패 하였습니다. (Form error).
    MESSAGE s000 WITH TEXT-e12  DISPLAY LIKE 'E'.
  ELSE.
    INSERT LINES OF ls_ssfcrescl-otfdata INTO TABLE gt_otf.

  ENDIF.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form smartform_print_with_otf
*&---------------------------------------------------------------------*
FORM smartform_print_with_otf  USING    pi_ucomm
                               CHANGING pe_error.

  DATA: ls_ssfpp      TYPE ssfpp,
        ls_arc_params TYPE arc_params,
        lt_spool_job  LIKE rspoattr OCCURS 0 WITH HEADER LINE.

**
  CHECK: pe_error IS INITIAL,
         gt_otf[] IS NOT INITIAL.

* 스마트 편집기 옵션.
  CLEAR: ls_ssfpp, ls_arc_params.
  PERFORM set_ssfpp_option          USING     pi_ucomm
                                    CHANGING  ls_ssfpp.

* Spool Job
  _clear: lt_spool_job.
  APPEND VALUE #( param    = 'S_COPYMETH'
                  value    = 'COLLATE'
                 ) TO lt_spool_job.

  IF pi_ucomm = 'PREVIEW'.    " 미리보기.
*   미리보기 Function
    CALL FUNCTION 'SSFDISPLAY_OTF'
      EXPORTING
        display_parameters = ls_ssfpp
        archive_params     = ls_arc_params
        spoolattr          = lt_spool_job[]
      IMPORTING
        result             = ls_ssfpp
      TABLES
        otf                = gt_otf
      EXCEPTIONS
        error              = 1.

  ELSE.
*   출력 Function
    CALL FUNCTION 'SSFCOMP_OTF_OUTPUT'
      EXPORTING
        input_params   = ls_ssfpp
        archive_params = ls_arc_params
        otf_data       = gt_otf[]
        bmnopri        = ''
      IMPORTING
        output_params  = ls_ssfpp
      EXCEPTIONS
        error          = 1.

    IF sy-subrc <> 0.
      pe_error = 'X'.
    ENDIF.

  ENDIF.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form set_ssfpp_option
*&---------------------------------------------------------------------*
FORM set_ssfpp_option  USING    pi_ucomm
                       CHANGING ps_ssfpp   LIKE ssfpp.

  DATA: lv_tdcopies  TYPE tdsfcopies.

**
  CLEAR: lv_tdcopies.
  lv_tdcopies = 1.
*  IF gv_copies IS INITIAL OR
*     gv_copies EQ 0.
*    lv_tdcopies = 1.
*  ELSE.
*    lv_tdcopies = gv_copies.
*  ENDIF.

  CLEAR: ps_ssfpp.
  ps_ssfpp = VALUE #( tddevice        = 'PRINTER'
                      tdpreview       = 'X'
                      tdpageform      = 'DINA4'
                      tdpages         = '00002'
                      tddriver        = 'SWIN'
                      tdotftype       = 'OTFSWIN'
                      tdforms         = '00001'
                      tdprogram       = 'SAPLSTXBE'
                      tdarmod         = '1'
                      tddataset       = 'SMART'
                      tdsuffix1       = 'ZP01'
                      tdsuffix2       = sy-uname
                      tddest          = 'ZP01'
                      tdprinter       = 'KPSAPWIN'
*                      rqposname       = 'Microsoft Print to PDF'
                      tdimmed         = 'X'
                      tddelete        = 'X'
                      tdlifetime      = '8'
                      tdcopies        = lv_tdcopies   " 발행수.'
                     ).

  IF pi_ucomm = 'PREVIEW'.    " 미리보기.
    ps_ssfpp-tdnoprint  = 'X'.
    CLEAR: ps_ssfpp-tdscreen, ps_ssfpp-tdscdriver.

  ELSE.                                  "출력
    ps_ssfpp-tdscreen   = 'WN32'.
    ps_ssfpp-tdscdriver = 'WN32'.
    CLEAR: ps_ssfpp-tdnoprint.

  ENDIF.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form update_db_data
*&---------------------------------------------------------------------*
FORM update_db_data  USING    pi_ucomm
                     CHANGING pe_error.

**
  CHECK: pe_error IS INITIAL,
         pi_ucomm EQ 'PRINT',    " 발행.
         rb_new   EQ 'X'.        " 신규발행.

* 통문 Header
  IF gt_0005[] IS NOT INITIAL.
    MODIFY zlet0005  FROM TABLE gt_0005[].
    IF sy-subrc <> 0.
      pe_error = 'X'.
    ENDIF.
  ENDIF.

* 통문 Item
  IF gt_0006[] IS NOT INITIAL AND
     pe_error  IS INITIAL.
    MODIFY zlet0006  FROM TABLE gt_0006[].
    IF sy-subrc <> 0.
      pe_error = 'X'.
    ENDIF.
  ENDIF.

* 거래명세서 발행 내용 Header
  IF gt_2101[] IS NOT INITIAL AND
     pe_error  IS INITIAL.
    MODIFY zgtsdt2101  FROM TABLE gt_2101[].
  ENDIF.

* 거래명세서 발행 내용 Item
  IF gt_2102[] IS NOT INITIAL AND
     pe_error  IS INITIAL.
    MODIFY zgtsdt2102  FROM TABLE gt_2102[].
  ENDIF.

* 통문유형 'A01'인 경우 거래명세서 발행 후 납품헤더 Update
  IF pe_error IS INITIAL.
    SORT: gt_0005 BY iv_no,
          gt_0006 BY iv_no.

    LOOP AT gt_0005  INTO DATA(ls_0005)
                      WHERE iv_type = 'A01'.

      READ TABLE gt_0006  INTO DATA(ls_0006)
                          WITH KEY iv_no = ls_0005-iv_no
                          BINARY SEARCH.
      IF sy-subrc = 0.
        LOOP AT gt_0006  INTO ls_0006  FROM sy-tabix.
          IF ls_0006-iv_no = ls_0005-iv_no.

            PERFORM update_likp     USING    ls_0005-iv_type
                                             ls_0006-vbeln
                                    CHANGING pe_error.
            IF pe_error IS NOT INITIAL.
              EXIT.
            ENDIF.

          ELSE.
            EXIT.
          ENDIF.
        ENDLOOP.
      ENDIF.

    ENDLOOP.

  ENDIF.

  IF pe_error IS INITIAL.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        wait = 'X'.

  ELSE.
    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

*   통문 Data 저장에 실패하였습니다.(DB)
    MESSAGE s000 WITH TEXT-e08  DISPLAY LIKE 'E'.

  ENDIF.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form update_likp
*&---------------------------------------------------------------------*
FORM update_likp  USING    pi_ivtyp
                           pi_vbeln
                  CHANGING pe_error.

  DATA: lv_werks LIKE lips-werks,
        lv_lgort LIKE lips-lgort,
        lv_zuse  LIKE zlet0009-zuse_yn.

**
  CHECK: pi_vbeln IS NOT INITIAL,
         pi_ivtyp IS NOT INITIAL.

*___납품 첫번째 품목의 배치분할 품목의 플랜트/저장위치
  CLEAR: lv_werks, lv_lgort, lv_zuse.

  SELECT SINGLE werks, lgort  INTO (@lv_werks, @lv_lgort)
    FROM lips  WHERE vbeln EQ @pi_vbeln
                 AND uecha <> '000000'.

  IF sy-subrc <> 0.
*___배치분할 품목이 없으면 첫번째 품목의 플랜트/저장위치
    SELECT SINGLE werks, lgort  INTO (@lv_werks, @lv_lgort)
      FROM lips  WHERE vbeln EQ @pi_vbeln.
  ENDIF.

  CHECK lv_werks IS NOT INITIAL AND
        lv_lgort IS NOT INITIAL.

  SELECT SINGLE zuse_yn  INTO @lv_zuse
    FROM zlet0009  WHERE iv_type EQ @pi_ivtyp
                     AND werks   EQ @lv_werks
                     AND lgort   EQ @lv_lgort.

  IF sy-subrc <> 0.
    SELECT SINGLE zuse_yn  INTO @lv_zuse
      FROM zlet0009  WHERE iv_type EQ @pi_ivtyp
                       AND werks   EQ @lv_werks
                       AND lgort   EQ ' '.

    IF sy-subrc <> 0.
      SELECT SINGLE zuse_yn  INTO @lv_zuse
        FROM zlet0009  WHERE iv_type EQ @pi_ivtyp
                         AND werks   EQ ' '
                         AND lgort   EQ ' '.

    ENDIF.

  ENDIF.

  IF sy-subrc = 0  AND
     lv_zuse = 'Y'.

    UPDATE likp SET zout  = 'X'
              WHERE vbeln = pi_vbeln.

    IF sy-subrc <> 0.
      pe_error = 'X'.
    ENDIF.

  ENDIF.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form send_print_data
*&---------------------------------------------------------------------*
FORM send_print_data  USING    pi_ucomm
                      CHANGING pe_error.

  DATA: lt_zsdt9499    LIKE zsdt9499 OCCURS 0 WITH HEADER LINE,
        ls_zsdt9499    LIKE zsdt9499,
        lt_9420        LIKE zsds9420 OCCURS 0 WITH HEADER LINE,
        ls_9420        LIKE zsds9420,

        lv_destination LIKE zifdest-dest,
        lv_zresult     LIKE bapie1ret2-type,
        lv_message     LIKE bapie1ret2-message,
        lv_msg(250).

**
  CHECK: pe_error IS INITIAL,
         pi_ucomm EQ 'PRINT'.    " 발행.

* [SD] 스크랩 자재 Check.
  DATA(lt_mat) = gt_stab[].
  SORT: lt_mat BY matnr.
  DELETE ADJACENT DUPLICATES FROM lt_mat  COMPARING matnr.

  SELECT b~*
    FROM @lt_mat AS a  INNER JOIN zsdt0420 AS b
                       ON  a~matnr = b~matnr
                       AND b~bukrs = '1000'
    INTO TABLE @DATA(lt_zsdt0420).

  IF lt_zsdt0420[] IS NOT INITIAL.
    SORT: lt_zsdt0420 BY matnr lvorm.
  ENDIF.

* 선적정보 Check.
  DATA(lt_vl) = gt_stab[].
  SORT: lt_vl BY vbeln.
  DELETE ADJACENT DUPLICATES FROM lt_vl COMPARING vbeln.

  SELECT a~vbeln,
         d~tknum, d~tpbez, d~exti2, d~sdabw, d~exti1
    FROM @lt_vl AS a  INNER JOIN likp AS b
                      ON  a~vbeln = b~vbeln
                      AND ( b~vstel IN ('3100','3110','3120') OR
                            b~vstel IN ('4710') OR "산업기기
                            b~vstel IN ('4730') OR "튜브
                            b~vstel IN ('3200') OR "권선
                            b~vstel IN ('4800') )  "통합배선
                      INNER JOIN vttp AS c
                      ON  b~vbeln = c~vbeln
                      INNER JOIN vttk AS d
                      ON  c~tknum = d~tknum
                      AND d~vbtyp = '8'
                      AND d~shtyp = 'Z001'
    INTO TABLE @DATA(lt_vttk).

  IF lt_vttk[] IS NOT INITIAL.
    SORT: lt_vttk BY vbeln.
  ENDIF.

*
  _clear: lt_9420.
  LOOP AT gt_stab  INTO DATA(ls_tab).

    DATA(ls_0420) = VALUE #( lt_zsdt0420[ matnr = ls_tab-matnr
                                          lvorm = '' ]
                             OPTIONAL ).

    IF ls_0420 IS NOT INITIAL.
      CONTINUE.
    ENDIF.

*   수출제외
    SELECT COUNT(*) INTO @DATA(lv_cnt)
      FROM vbak  WHERE vbeln EQ @ls_tab-vgbel
                   AND vtweg EQ 50.

    IF lv_cnt IS NOT INITIAL.
      CONTINUE.
    ENDIF.

*   선적정보.
    DATA(ls_vttk) = VALUE #( lt_vttk[ vbeln = ls_tab-vbeln ]
                             OPTIONAL ).

    IF ls_vttk IS INITIAL.
      CONTINUE.
    ELSE.

      IF ls_vttk-exti2 IS INITIAL AND
         ls_vttk-tpbez IS INITIAL AND
         ls_vttk-exti1 IS INITIAL AND
         ls_vttk-sdabw IS INITIAL.
        CONTINUE.
      ENDIF.

    ENDIF.

    SELECT SINGLE spart, vkbur INTO @DATA(ls_lips)
      FROM lips  WHERE vbeln EQ @ls_tab-vbeln
                   AND posnr EQ @ls_tab-posnr.



    CLEAR: ls_9420.
    ls_9420 = VALUE #( exti2  = ls_vttk-exti2
                       tpbez  = ls_vttk-tpbez
                       exti1  = ls_vttk-exti1
                       sdabw  = ls_vttk-sdabw
                       vbeln  = ls_tab-vbeln
                       posnr  = ls_tab-posnr
                       vgbel  = ls_tab-vgbel
                       vgpos  = ls_tab-vgpos
                       spart  = ls_lips-spart
                       vkbur  = ls_lips-vkbur
                      ).

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
      EXPORTING
        input  = ls_9420-vbeln
      IMPORTING
        output = ls_9420-vbeln.

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
      EXPORTING
        input  = ls_9420-tknum
      IMPORTING
        output = ls_9420-tknum.

    COLLECT: ls_9420  INTO lt_9420.

  ENDLOOP.

  IF lt_9420[] IS NOT INITIAL.

    DATA(lt_temp) = lt_9420[].

    CLEAR: lv_destination.
    CALL FUNCTION 'Z_IF_DESTINATION'
      EXPORTING
        gubun                 = 'IS'
      IMPORTING
        dest_name             = lv_destination
      EXCEPTIONS
        destination_not_found = 1
        OTHERS                = 2.

    CLEAR: lv_zresult, lv_message, lv_msg.
    IF lv_destination IS NOT INITIAL.

      CALL FUNCTION 'ZCNET_DISPATCH_INFO'
        DESTINATION lv_destination
        IMPORTING
          e_zresult             = lv_zresult
          e_message             = lv_message
        TABLES
          et_data               = lt_9420
        EXCEPTIONS
          system_failure        = 1 MESSAGE lv_msg
          communication_failure = 2 MESSAGE lv_msg
          OTHERS                = 3.

      IF sy-subrc <> 0.
        lv_zresult = 'E'.
        lv_message = lv_msg.
      ENDIF.

      DATA(lv_datum) = sy-datum.
      DATA(lv_uzeit) = sy-uzeit.

      _clear: lt_zsdt9499.
      LOOP AT lt_temp  INTO DATA(ls_temp).

        CLEAR: ls_zsdt9499.
        MOVE-CORRESPONDING  ls_temp TO ls_zsdt9499.
        ls_zsdt9499-tdate = lv_datum.
        ls_zsdt9499-ttime = lv_uzeit.
        ls_zsdt9499-zresult = lv_zresult.
        ls_zsdt9499-message = lv_message.
        APPEND ls_zsdt9499 TO lt_zsdt9499.

      ENDLOOP.


      CHECK lt_zsdt9499[] IS NOT INITIAL.

      MODIFY zsdt9499 FROM TABLE lt_zsdt9499.
      IF sy-subrc EQ 0.
        COMMIT WORK.
      ELSE.
        ROLLBACK WORK.
      ENDIF.

    ENDIF.

  ENDIF.

**
  FREE: lt_mat, lt_vl,
        lt_zsdt0420, lt_vttk, lt_9420, lt_temp, lt_zsdt9499.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form send_to_mes
*&---------------------------------------------------------------------*
FORM send_to_mes  USING    pi_ucomm
                  CHANGING pe_error.

**
  CHECK rb_new = 'X'.    " 신규발행
  CHECK: pe_error IS INITIAL,
         pi_ucomm EQ 'PRINT'.    " 발행.

  DATA(lt_do) = gt_0006[].
  SORT : lt_do BY vbeln.
  DELETE ADJACENT DUPLICATES FROM lt_do COMPARING vbeln.

  DATA(lt_iv) = gt_0005[].
  SORT: lt_iv BY iv_no.
  DELETE ADJACENT DUPLICATES FROM lt_iv COMPARING iv_no.

  DATA(lt_tmp) = lt_iv[].

* Send Outbound Delivery Order
  IF lt_do[] IS NOT INITIAL.
    LOOP AT lt_do INTO DATA(ls_do).

      READ TABLE lt_tmp INTO DATA(ls_tmp) WITH KEY iv_no = ls_do-iv_no
                                                   iv_type = 'A01'.

      IF sy-subrc EQ 0.
        PERFORM send_mes_with_do  USING ls_do-vbeln
                                  CHANGING pe_error.
      ENDIF.
    ENDLOOP.
  ENDIF.


* Send Invoice
  IF lt_iv[] IS NOT INITIAL.
    LOOP AT lt_iv  INTO DATA(ls_iv).
      IF ls_iv-iv_type EQ 'A01'.
        PERFORM send_mes_with_iv_no   USING    ls_iv-iv_no
                                      CHANGING pe_error.
      ENDIF.
    ENDLOOP.
  ENDIF.

**
  FREE: lt_iv, lt_do.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form send_mes_with_iv_no
*&---------------------------------------------------------------------*
FORM send_mes_with_iv_no  USING    pi_iv_no
                          CHANGING pe_error.

  DATA: lv_jobname      LIKE tbtcjob-jobname,
        lv_jobname_head LIKE tbtcjob-jobname,
        lv_jobcount     LIKE tbtcjob-jobcount,

        lv_go(1),
        lv_gp(1),
        lv_gc(1).

  RANGES: lr_ivno  FOR zlet0005-iv_no,
          lr_erdat FOR vbak-erdat .

**
  CHECK: pi_iv_no IS NOT INITIAL.

  SELECT SINGLE *  INTO @DATA(ls_0005)
    FROM zlet0005  WHERE iv_no EQ @pi_iv_no.

*  SELECT COUNT(*)  INTO @DATA(lv_cnt)
*    FROM zlet0201  WHERE zcodh EQ 'SO04'
*                     AND zdesi EQ @ls_0005-werks.

  SELECT SINGLE fld_01 INTO @DATA(lv_target)
    FROM zgtppt1010  WHERE module_kind EQ 'PP'
                       AND codegrp     EQ '0010'
                       AND fld_03      EQ @ls_0005-werks
                       AND fld_04      NE @space.

  CLEAR: lv_jobname_head, lv_gp, lv_go, lv_gc.
  IF lv_target IS NOT INITIAL.

    lv_jobname_head = |{ '[SD]C_' }| && |{ lv_target }| && |{ '_명세서(' }|.

    IF     lv_target = 'KGOM'.
      CLEAR: lv_gp, lv_gc.    lv_go = 'X'.
    ELSEIF lv_target = 'KGPM'.
      lv_gp = 'X'.    CLEAR: lv_go, lv_gc.
    ENDIF.

  ENDIF.

*  IF lv_cnt    IS NOT INITIAL AND
*     lv_target IS NOT INITIAL.
  IF lv_target IS NOT INITIAL.

    CLEAR: lv_jobname, lv_jobcount.
    lv_jobname = |{ lv_jobname_head }| && |{ pi_iv_no }| && |{ ')' }|.

    CALL FUNCTION 'JOB_OPEN'
      EXPORTING
        jobname          = lv_jobname
        jobclass         = 'A'
      IMPORTING
        jobcount         = lv_jobcount
      EXCEPTIONS
        cant_create_job  = 1
        invalid_job_data = 2
        jobname_missing  = 3
        OTHERS           = 4.

    _clear: lr_ivno, lr_erdat.
    lr_ivno[]  = VALUE #( ( sign = 'I' option = 'EQ' low = pi_iv_no ) ).
    lr_erdat[] = VALUE #( ( sign = 'I' option = 'BT' low  = ls_0005-iv_date
                                                     high = ls_0005-iv_date ) ).
*
    SUBMIT zgtsdi0005 VIA JOB lv_jobname  NUMBER lv_jobcount
                      AND RETURN
                      WITH s_ivno  IN lr_ivno
                      WITH s_erdat IN lr_erdat
                      WITH rb_send EQ 'X'
                      WITH rb_10   EQ ' '
                      WITH rb_t1   EQ ' '
                      WITH rb_gp   EQ lv_gp
                      WITH rb_go   EQ lv_go
                      WITH rb_gc   EQ lv_gc
                      WITH p_call  EQ 'X'.

    CALL FUNCTION 'JOB_CLOSE'
      EXPORTING
        jobcount             = lv_jobcount
        jobname              = lv_jobname
        strtimmed            = 'X'
      EXCEPTIONS
        cant_start_immediate = 1
        invalid_startdate    = 2
        jobname_missing      = 3
        job_close_failed     = 4
        job_nosteps          = 5
        job_notex            = 6
        lock_failed          = 7
        OTHERS               = 8.

  ENDIF.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form print_cancel_exc
*&---------------------------------------------------------------------*
FORM print_cancel_exc  USING    pi_ucomm.

**
  CHECK: gv_error IS INITIAL.

* Selected line check.
  PERFORM get_selected_low             USING pi_ucomm.

* data Validation Check - Cancel.
  PERFORM data_validation_for_cancel   USING pi_ucomm.

* Confirm.
  PERFORM popup_to_confirm_for_print   USING pi_ucomm.

* 거래명세서 출력취소
  PERFORM print_iv_cancel              USING pi_ucomm.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form data_validation_for_cancel
*&---------------------------------------------------------------------*
FORM data_validation_for_cancel  USING    pi_ucomm.

**
  CHECK: pi_ucomm EQ 'REVERSE'.    " 출력취소

  DATA(lt_data) = gt_stab[].

  SELECT a~iv_no
    FROM @lt_data AS a  INNER JOIN zlet0005 AS b
                        ON a~iv_no   = b~iv_no
                        AND b~out_yn = 'X'
    INTO TABLE @DATA(lt_0005).

  IF lt_0005[] IS NOT INITIAL.
    gv_error = 'X'.
*   통문확정 취소후 발행취소하세요.
    MESSAGE s000 WITH TEXT-e10  DISPLAY LIKE 'I'.
  ENDIF.

**
  FREE: lt_data, lt_0005.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form print_iv_cancel
*&---------------------------------------------------------------------*
FORM print_iv_cancel  USING    pi_ucomm.

**
  CHECK: gv_error  IS INITIAL,
         gt_stab[] IS NOT INITIAL.

  DATA(lt_data) = gt_stab[].
  SORT: lt_data BY iv_no.
  DELETE ADJACENT DUPLICATES FROM lt_data COMPARING iv_no.

  CHECK: lt_data[] IS NOT INITIAL.

  LOOP AT lt_data  INTO DATA(ls_data).

    UPDATE zlet0005 SET: iv_cancel_yn = 'X'
                         change_date  = sy-datum
                         change_time  = sy-uzeit
                  WHERE iv_no = ls_data-iv_no.
    IF sy-subrc = 0.

      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
        EXPORTING
          wait = 'X'.

*     거래명세서 발행 내용 - Header
      UPDATE zgtsdt2101  SET: iv_cancel_yn = 'X'
                              aenam   = sy-uname
                              aedat   = sy-datum
                              aezeit  = sy-uzeit
                              aedatlo = sy-datlo
                              aetimlo = sy-timlo
                       WHERE iv_no = ls_data-iv_no.

      PERFORM send_mes_with_iv_no   USING    ls_data-iv_no
                                    CHANGING gv_error.

      DELETE gt_list WHERE iv_no = ls_data-iv_no.

    ELSE.
      gv_error = 'X'.
      CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
      EXIT.

    ENDIF.

  ENDLOOP.

  IF gv_error IS INITIAL.
*   거래명세서 출력 취소처리 하였습니다.
    MESSAGE s000 WITH TEXT-s02.
  ELSE.
*   거래명세서 취소에 실패하였습니다. (DB)
    MESSAGE s000 WITH TEXT-e11  DISPLAY LIKE 'E'.
  ENDIF.

**
  FREE: lt_data.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form convt_number_to_char
*&---------------------------------------------------------------------*
FORM convt_number_to_char  USING    pi_type
                                    pi_value
                           CHANGING pe_conv_value.

  DATA: lv_type_p0 TYPE p DECIMALS 0,
        lv_type_p1 TYPE p DECIMALS 1,
        lv_type_p2 TYPE p DECIMALS 2,
        lv_type_p3 TYPE p DECIMALS 3.

**
  CHECK: pi_value IS NOT INITIAL.

  CLEAR: lv_type_p0, lv_type_p1, lv_type_p2, lv_type_p3,
         pe_conv_value.

  CASE pi_type.
    WHEN 'C' OR
         'C0'.    " Char -> Type p -> Char

      CONDENSE pi_value NO-GAPS.
      CALL FUNCTION 'MOVE_CHAR_TO_NUM'
        EXPORTING
          chr             = pi_value
        IMPORTING
          num             = lv_type_p2
        EXCEPTIONS
          convt_no_number = 1
          convt_overflow  = 2
          OTHERS          = 3.

      IF     pi_type = 'C'.
        WRITE: lv_type_p2 TO pe_conv_value.
      ELSEIF pi_type = 'C0'.
        WRITE: lv_type_p2 TO pe_conv_value  DECIMALS 0.
      ENDIF.

    WHEN 'P'.    " Type p -> Char.
      WRITE: pi_value TO pe_conv_value.

    WHEN 'P0'.    " Type p -> Char Decimals 0.
      WRITE: pi_value TO pe_conv_value  DECIMALS 0.

    WHEN 'P1'.    " Type p -> Char unit 'KG' (중량관련필드)
      lv_type_p0 = pi_value.
      WRITE: lv_type_p0 TO pe_conv_value UNIT 'KG'.

    WHEN 'C3'.

      CONDENSE pi_value NO-GAPS.
      lv_type_p3 = pi_value.
      WRITE: lv_type_p3 TO pe_conv_value.

  ENDCASE.

  CONDENSE pe_conv_value NO-GAPS.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form make_iv_doc_save_data
*&---------------------------------------------------------------------*
FORM make_iv_doc_save_data  TABLES   pt_item     STRUCTURE zgtsds1002
                            USING    pi_ucomm
                                     ps_iv_info  LIKE zgtsds1003
                                     ps_head     LIKE zgtsds1001
                                     pi_vbeln
                                     pi_kunag
                                     pi_vstel
                            CHANGING pe_error.

  DATA: lv_seq  LIKE zgtsdt2102-iv_seq.

**
  CHECK: pe_error IS INITIAL,
         rb_new   EQ 'X',           " 신규발행
         pi_ucomm EQ 'PRINT' .      " 발행.

* SALES_EMPLOYEE
  SELECT SINGLE c~name1 AS sales_employee,
                d~usrid AS empl_telno
    FROM lips AS a  INNER JOIN vbpa AS b
                    ON  a~vgbel EQ b~vbeln
                    AND b~posnr EQ '000000'
                    AND b~parvw EQ 'VE'
                    INNER JOIN lfa1 AS c
                    ON b~lifnr EQ c~lifnr
                    LEFT JOIN zpa0105 AS d
                    ON  c~sortl EQ d~pernr
                    AND d~subty EQ '0003'
   WHERE a~vbeln EQ @pi_vbeln
    INTO @DATA(ls_empl).
*    INTO @DATA(lv_sales_employee).

*CUST_MANAGER
*  SELECT SINGLE b~extension1
*    FROM kna1 AS a  INNER JOIN adrc AS b
*                    ON a~adrnr EQ b~addrnumber
*   WHERE a~kunnr EQ @pi_kunag
*    INTO @DATA(lv_extansion1).
  SELECT SINGLE b~cust_name AS cust_manager,
                b~cust_tel  AS cust_telno
    FROM zlet0402 AS a  INNER JOIN zlet0400 AS b
                        ON a~dlvrq EQ b~dlvrq
   WHERE a~vgbel EQ @pi_vbeln
    INTO @DATA(ls_cust).

*  SELECT SINGLE d~userid AS creator,
*                c~usrid  AS creator_telno,
  SELECT SINGLE d~name AS creator,
                d~email AS creator_telno
    FROM lips AS a  INNER JOIN vbap AS b
                    ON  a~vgbel EQ b~vbeln
                    AND a~vgpos EQ b~posnr
*                    INNER JOIN zpa0105 AS c
*                    ON  b~ernam EQ c~pernr
*                    AND c~subty EQ '0003'
                    INNER JOIN zgtmm_cv_getusername_g AS d
                    ON  b~ernam EQ d~userid AND
                        d~subty EQ '0003'
   WHERE a~vgbel EQ @pi_vbeln
    INTO @DATA(ls_crt).

* Header
  gt_2101 = VALUE #( BASE gt_2101
                     ( VALUE #( BASE CORRESPONDING #( ps_head )
                                iv_no          = ps_iv_info-iv_no
                                iv_date        = ps_iv_info-iv_date
                                arrdt          = ps_iv_info-arrdt
                                arrtm          = ps_iv_info-arrtm
                                iv_print_yn    = 'X'
                                sales_employee = ls_empl-sales_employee
                                empl_telno     = ls_empl-empl_telno
                                cust_manager   = ls_cust-cust_manager  "lv_extansion1
                                cust_telno     = ls_cust-cust_telno
                                creator        = ls_crt-creator
                                creator_telno  = ls_crt-creator_telno
                                vstel          = pi_vstel
                                ernam          = sy-uname
                                erdat          = sy-datum
                                erzeit         = sy-uzeit
                                erdatlo        = sy-datlo
                                ertimlo        = sy-timlo
                               )
                      )
                    ).

* Item
  CLEAR: lv_seq.
  LOOP AT pt_item  INTO DATA(ls_item).

    lv_seq = lv_seq + 1.

    APPEND VALUE #( BASE CORRESPONDING #( ls_item )
                                iv_no       = ps_iv_info-iv_no
                                iv_seq      = lv_seq
                                ernam       = sy-uname
                                erdat       = sy-datum
                                erzeit      = sy-uzeit
                                erdatlo     = sy-datlo
                                ertimlo     = sy-timlo
                   ) TO gt_2102.
  ENDLOOP.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form get_data_from_cbm_fm
*&---------------------------------------------------------------------*
FORM get_data_from_cbm_fm .

**
  CHECK: gv_error IS INITIAL,
         gt_list[] IS NOT INITIAL.

  _clear: gt_cbm.

  gt_cbm = VALUE #( BASE gt_cbm
                    FOR ls_wa  IN gt_list
                    ( vbeln = ls_wa-vgbel
                      posnr = ls_wa-vgpos )
                   ).

  CALL FUNCTION 'ZGTED_SELECT_CBM_DATA'
    TABLES
      ot_output = gt_cbm.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form set_data_from_cdm
*&---------------------------------------------------------------------*
FORM set_data_from_cdm  USING    ps_list  LIKE gt_list.

  DATA: lv_brgew  LIKE mara-brgew,
        lv_type_p TYPE p DECIMALS 0,
        lv_factor LIKE conf_out-atwrt .      " 조장수

**
  CHECK: ps_list-vgbel IS NOT INITIAL,
         ps_list-vgpos IS NOT INITIAL,
         gt_cbm[]      IS NOT INITIAL.

  DATA(ls_cbm) = VALUE #( gt_cbm[ vbeln = ps_list-vgbel
                                  posnr = ps_list-vgpos ]
                          OPTIONAL ).

  IF ls_cbm IS NOT INITIAL.

    ps_list-out_wid   = ls_cbm-out_wid .      " 폭/드럼
    ps_list-plan_dia  = ls_cbm-barrel_dia .   " 약경/드럼
    ps_list-dr_weight = ls_cbm-brgew .        " 드럼무게/개

    CLEAR: lv_brgew.
    IF ls_cbm-gewei IS NOT INITIAL AND
       ls_cbm-gewei <> ps_list-gewei.

      PERFORM convert_material_unit USING ps_list-matnr
                                          ps_list-gewei
                                          ls_cbm-gewei
                                          ps_list-brgew.
      ps_list-gewei = ls_cbm-gewei.
    ENDIF.

    lv_brgew = ps_list-brgew.

    CLEAR: lv_factor, lv_type_p.
    lv_factor = condense( ps_list-factor ).

    CALL FUNCTION 'MOVE_CHAR_TO_NUM'
      EXPORTING
        chr             = lv_factor
      IMPORTING
        num             = lv_type_p
      EXCEPTIONS
        convt_no_number = 1
        convt_overflow  = 2
        OTHERS          = 3.

*   총 중량(드럼포함) : 드럼무게/개 * 조장수 + 제품 총 중량 (NTGEW)
    ps_list-total_brgew = ( ps_list-dr_weight * lv_type_p ) + lv_brgew.

  ENDIF.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form set_brgew_from_data
*&---------------------------------------------------------------------*
FORM set_brgew_from_data  USING    ps_list  LIKE gt_list.

**
  CHECK: ps_list IS NOT INITIAL.

  IF ps_list-ntgew IS INITIAL OR
     ps_list-ntgew EQ 0.

    SELECT SINGLE ntgew, gewei  INTO (@ps_list-ntgew, @ps_list-gewei)
      FROM mara  WHERE matnr EQ @ps_list-matnr.

  ENDIF.

* KG 로 변환
  PERFORM convert_material_unit USING ps_list-matnr
                                      ps_list-gewei
                                      'KG'
                                      ps_list-ntgew.

  ps_list-brgew = ps_list-ntgew.

  ps_list-gewei = 'KG'.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form convt_weight_simple
*&---------------------------------------------------------------------*
FORM convt_weight_simple  USING    pi_value
                                   pi_meins_b
                                   pi_meins_n
                          CHANGING pe_value.

**
  CHECK: pi_value IS NOT INITIAL.

  CLEAR: pe_value.

  IF pi_meins_b IS INITIAL.
    pi_meins_b = 'G'.
  ENDIF.

  CALL FUNCTION 'UNIT_CONVERSION_SIMPLE'
    EXPORTING
      input                = pi_value
      round_sign           = 'X'
      unit_in              = pi_meins_b
      unit_out             = pi_meins_n
    IMPORTING
      output               = pe_value
    EXCEPTIONS
      conversion_not_found = 1
      division_by_zero     = 2
      input_invalid        = 3
      output_invalid       = 4
      overflow             = 5
      type_invalid         = 6
      units_missing        = 7
      unit_in_not_found    = 8
      unit_out_not_found   = 9
      OTHERS               = 10.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form set_gubun_from_stock_fm
*&---------------------------------------------------------------------*
FORM set_gubun_from_stock_fm  USING    pi_vbeln
                                       pi_posnr
                                       pi_matnr
                                       pi_werks
                                       pi_lgort
                                       pi_factor
                              CHANGING pe_zgubun.

  DATA: lv_mode     TYPE zgtemode_stock,
        ls_login    TYPE zsds_log_0000_go,
        ls_return   TYPE zsds_log_0001_go,
        lt_search	  TYPE TABLE OF zgtsdsif0096,
        lt_lstock   TYPE TABLE OF zgtsdsif0100,
        lt_lstock_d TYPE TABLE OF zgtsdsif0101,
        lt_estock   TYPE TABLE OF zgtsdsif0102.

**
  CLEAR: lv_mode,
         ls_login, ls_return.
  _clear: lt_search, lt_estock.

* LINK재고조회 + 판매오더재고조회
  lv_mode        = 'Z'.    " 'C'.
  ls_login-ename = sy-uname.

  APPEND VALUE #( matnr = pi_matnr
                  werks = pi_werks
                  lgort = pi_lgort
                  vbeln = pi_vbeln
                  posnr = pi_posnr
                 ) TO lt_search.

  CALL FUNCTION 'ZSD_365_0050_0040_GO'
    EXPORTING
      is_d365_login  = ls_login
      i_mode         = lv_mode
    IMPORTING
      es_return      = ls_return
    TABLES
      it_search      = lt_search
      et_estock_item = lt_estock.

  CHECK: ls_return-mtype = 'S' AND
         lt_estock[] IS NOT INITIAL.

  DATA(lv_estock) = VALUE #( lt_estock[ vbeln = pi_vbeln
                                        posnr = pi_posnr ]-estock
                             OPTIONAL ).

  IF     lv_estock >= pi_factor.
    pe_zgubun = '완'.
    pe_zgubun = |{ pe_zgubun }| && | { pi_factor }|.

  ELSEIF lv_estock < pi_factor.

    DATA(lv_cnt) = pi_factor - lv_estock.

    pe_zgubun = '미'.
    pe_zgubun = |{ pe_zgubun }| && | { lv_cnt }|.

  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form picking_list_download
*&---------------------------------------------------------------------*
FORM picking_list_download  USING    pi_ucomm.

**
  CHECK: gv_error IS INITIAL.

* Selected line check.
  PERFORM get_selected_low             USING pi_ucomm.

*  _clear: gt_stab.
*  gt_stab[] = CORRESPONDING #( gt_list[] ).

* Confirm.
  PERFORM popup_to_confirm_for_print   USING pi_ucomm.

* Picking List Download.
  PERFORM download_picking_list        USING pi_ucomm.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form download_picking_list
*&---------------------------------------------------------------------*
FORM download_picking_list  USING    pi_ucomm.

  DATA: lv_filename TYPE string,
        lv_path     TYPE rlgrap-filename.

**
  CHECK: gv_error  IS INITIAL,
         gt_stab[] IS NOT INITIAL.

  SORT: gt_stab BY vbeln posnr.
  DELETE ADJACENT DUPLICATES FROM gt_stab COMPARING vbeln posnr.

* A형, B형 구분.
  DATA(lt_stab_a) = gt_stab[].
  DATA(lt_stab_b) = gt_stab[].
  DELETE: lt_stab_a  WHERE werks(2) NE '65',
          lt_stab_b  WHERE werks(2) NE '66'.

  IF lt_stab_a[] IS INITIAL AND
     lt_stab_b[] IS INITIAL.
    gv_error = 'X'.
*   Picking list 출력대상이 없습니다.
    MESSAGE s000 WITH TEXT-e18  DISPLAY LIKE 'E'.
  ENDIF.

  _clear: gt_otf,              " Smartform OTF Data
          gt_iv_tab,           " 거래명세서 번호 발행용.
          gt_0005, gt_0006,    " 통문 데이터 저장용.
          gt_2101, gt_2102.    " 거래명세서 발행 내용 저장용.

* Download File Path.
  CLEAR: lv_path, lv_filename.
* Order Picking List.
  PERFORM file_path_dialog            USING    'S'
                                               TEXT-t05   " File Save.
                                               TEXT-005
                                      CHANGING lv_path
                                               lv_filename.

** A형(군포용) Download
  PERFORM picking_list_download_etc   TABLES   lt_stab_a
                                      USING    'A'
                                               pi_ucomm
                                               lv_path
                                               lv_filename
                                      CHANGING gv_error.

* B형(전주용) Download
  PERFORM picking_list_download_etc   TABLES   lt_stab_b
                                      USING    'B'
                                               pi_ucomm
                                               lv_path
                                               lv_filename
                                      CHANGING gv_error.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form file_path_dialog
*&---------------------------------------------------------------------*
FORM file_path_dialog  USING    pi_type
                                pi_title
                                pi_fname
                       CHANGING pe_file
                                pe_filename.

  DATA: lv_rc          TYPE i VALUE 1,
        lt_file        TYPE filetable,
        lv_user_action TYPE i,
        lv_directory   TYPE string,
        lv_title       TYPE string,
        lv_exten       TYPE string,
        lv_filename    TYPE string,
        lv_path        TYPE string,
        lv_fullpath    TYPE string.

**
  CHECK: gv_error IS INITIAL.

  CLEAR: lv_title.
  lv_title = pi_title.

  CASE pi_type.
    WHEN 'O'.    " File Open Dialog.

      CLEAR: lv_rc, lv_directory, lv_user_action.
      _clear: lt_file.

      CONCATENATE cl_gui_frontend_services=>filetype_excel
                  cl_gui_frontend_services=>filetype_all
             INTO DATA(lv_filter).

      CALL METHOD cl_gui_frontend_services=>get_desktop_directory
        CHANGING
          desktop_directory = lv_directory.

      CALL METHOD cl_gui_cfw=>update_view.

      CALL METHOD cl_gui_frontend_services=>file_open_dialog
        EXPORTING
          window_title      = lv_title
          file_filter       = lv_filter
          initial_directory = lv_directory
        CHANGING
          file_table        = lt_file
          rc                = lv_rc
          user_action       = lv_user_action.

      IF lt_file[] IS NOT INITIAL.
        pe_file = VALUE #( lt_file[ 1 ]-filename  OPTIONAL ).
      ENDIF.

    WHEN 'S'.    " File Save Dialog.
      CLEAR: lv_filename, lv_path, lv_fullpath, lv_exten.

      lv_exten    = |xlsx|.
      lv_filename = pi_fname.

      CALL METHOD cl_gui_frontend_services=>file_save_dialog
        EXPORTING
          window_title         = lv_title
          default_extension    = lv_exten
          default_file_name    = lv_filename
          file_filter          = 'xlsx'
          prompt_on_overwrite  = abap_true
        CHANGING
          filename             = lv_filename
          path                 = lv_path
          fullpath             = lv_fullpath
          user_action          = lv_user_action
        EXCEPTIONS
          cntl_error           = 1
          error_no_gui         = 2
          not_supported_by_gui = 3
          OTHERS               = 4.

      IF sy-subrc <> 0.
        gv_error = 'X'.
*       프론트엔드 통신중 오류발생
        MESSAGE s162(alvht)  DISPLAY LIKE 'E'.
        EXIT.
      ENDIF.

      IF lv_user_action = cl_gui_frontend_services=>action_cancel .
        gv_error = 'X'.
*       사용자가 취소했습니다.
        MESSAGE s161(alvht) DISPLAY LIKE 'E'.
        EXIT.
      ENDIF.

      IF lv_fullpath IS INITIAL.
        gv_error = 'X'.
*       파일명을 확인하세요.
        MESSAGE s000 WITH TEXT-e13  DISPLAY LIKE 'E'.
        EXIT.

      ELSE.

        DATA(lv_len) = strlen( lv_fullpath ).
        IF lv_len > 128.
          gv_error = 'X'.
*         파일 경로가 너무 깁니다. ( 128 이상 ).
          MESSAGE s000 WITH TEXT-e14  DISPLAY LIKE 'E'.
          EXIT.
        ELSE.
          pe_file     = lv_path.    " lv_fullpath.
          pe_filename = lv_filename.
        ENDIF.

      ENDIF.

  ENDCASE.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form picking_list_download_etc
*&---------------------------------------------------------------------*
FORM picking_list_download_etc  TABLES   pt_tab STRUCTURE gt_list
                                USING    pi_type
                                         pi_ucomm
                                         pi_path
                                         pi_filename
                                CHANGING pe_error.

  DATA: lv_objid TYPE wwwdata-objid,
        lv_path  TYPE rlgrap-filename.

**
  CHECK: pe_error IS INITIAL,
         pt_tab[] IS NOT INITIAL.

  CLEAR: lv_objid, lv_path.
  IF     pi_type = 'A'.
    lv_objid = 'ZGTLER1150_A'.
    lv_path  = |{ pi_path }| && |{ TEXT-005 }| && |{ '_A' }|.

  ELSEIF pi_type = 'B'.
    lv_objid = 'ZGTLER1150_B'.
    lv_path  = |{ pi_path }| && |{ TEXT-005 }| && |{ '_B' }|.

  ENDIF.

* Picking List Download.
  PERFORM start_picking_list_download      TABLES   pt_tab
                                           USING    pi_type
                                                    lv_objid
                                                    lv_path
                                           CHANGING pe_error.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form start_picking_list_download
*&---------------------------------------------------------------------*
FORM start_picking_list_download  TABLES   pt_tab STRUCTURE gt_list
                                  USING    pi_type
                                           pi_objid
                                           pi_path
                                  CHANGING pe_error.

  DATA: lv_seq(1) TYPE i.

**
  CHECK: pe_error IS INITIAL.

* Document Count: 출하지점별
  DATA(lt_data) = pt_tab[].
  SORT: lt_data BY vstel.
  DELETE ADJACENT DUPLICATES FROM lt_data COMPARING vstel.

  DATA(lv_cnt) = lines( lt_data ).

* 출하지점별 Picking List Download.
  CLEAR: lv_seq.
  LOOP AT lt_data  INTO DATA(ls_data).

*   1) Picking list Header Info
    PERFORM make_download_header_data      USING    ls_data
                                           CHANGING gs_pick_head.

*   2) Picking list item .
    PERFORM make_download_item_data        TABLES   pt_tab
                                                    gt_picking
                                           USING    pi_type
                                                    ls_data.

    IF lv_cnt > 1.
      lv_seq = lv_seq + 1.
    ENDIF.

*   3) 양식 Download form SMW0.
    PERFORM download_template_from_smw0    USING    pi_objid
                                                    pi_path
                                                    lv_seq
                                           CHANGING pe_error.

*   4) Make Excel form.
    PERFORM make_ole_object                TABLES   gt_picking
                                           USING    gs_pick_head
                                                    pi_path
                                                    pi_type
                                           CHANGING pe_error.

    IF pe_error IS NOT INITIAL.
      EXIT.
    ENDIF.

  ENDLOOP.

**
  FREE: lt_data.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form download_template_from_smw0
*&---------------------------------------------------------------------*
FORM download_template_from_smw0  USING    pi_objid
                                           pi_path
                                           pi_seq
                                  CHANGING pe_error.

  DATA: lv_objid       TYPE char40,
        ls_key         TYPE wwwdatatab,
        lv_destination TYPE rlgrap-filename,
        lv_rc          TYPE sy-subrc,
        lv_fullpath    TYPE string.

**
  CHECK: gv_error IS INITIAL,
         pi_objid IS NOT INITIAL,
         pi_path  IS NOT INITIAL.

  CLEAR: lv_objid.
  lv_objid = pi_objid.

  CLEAR: ls_key.
  SELECT SINGLE *
    FROM wwwdata  WHERE objid EQ @lv_objid
    INTO CORRESPONDING FIELDS OF @ls_key.

  ls_key-relid   = 'MI'.
  ls_key-objid   = lv_objid.
  IF pi_seq > 0.
    lv_destination = sy-datum+2(6) && '_' && sy-uzeit && '_' && pi_seq && '.xls'.
  ELSE.
    lv_destination = sy-datum+2(6) && '_' && sy-uzeit && '.xls'.
  ENDIF.
  lv_destination = pi_path && '_' && lv_destination.

  CLEAR: lv_rc.
  CALL FUNCTION 'DOWNLOAD_WEB_OBJECT'
    EXPORTING
      key         = ls_key
      destination = lv_destination
    IMPORTING
      rc          = lv_rc
    EXCEPTIONS
      OTHERS      = 1.
  IF sy-subrc IS NOT INITIAL OR
     lv_rc    IS NOT INITIAL.
    pe_error = 'X'.
*   Picking list 다운로드 중 오류가 발생하였습니다.
    MESSAGE s000 WITH TEXT-e03  DISPLAY LIKE 'E'.

  ELSE.
    pi_path = lv_destination.

  ENDIF.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form make_download_header_data
*&---------------------------------------------------------------------*
FORM make_download_header_data  USING    ps_data    LIKE gt_list
                                CHANGING ps_head    LIKE gs_pick_head.

  DATA: lv_date_l(10),
        lv_date_h(10).

**
  CLEAR: ps_head.

* 출하지점 + 출하지점명
  SELECT SINGLE vtext  INTO @DATA(lv_vtext)
    FROM tvstt  WHERE vstel EQ @ps_data-vstel
                  AND spras EQ @sy-langu.

  ps_head-vstel = |{ ps_data-vstel } | && | { lv_vtext }|.

* 영업그룹
  DATA(lt_vkgrp) = gt_stab[].
  DELETE lt_vkgrp WHERE vstel NE ps_data-vstel.

  SORT: lt_vkgrp BY vkgrp.
  DATA(ls_vkgrp_s) = VALUE #( lt_vkgrp[ 1 ]  OPTIONAL ).

  SORT: lt_vkgrp DESCENDING BY vkgrp.
  DATA(ls_vkgrp_e) = VALUE #( lt_vkgrp[ 1 ]  OPTIONAL ).

  IF     ls_vkgrp_s-vkgrp IS INITIAL     AND ls_vkgrp_e-vkgrp IS INITIAL.
    ps_head-vkgrp = '*'.

  ELSEIF ls_vkgrp_s-vkgrp IS NOT INITIAL AND ls_vkgrp_e-vkgrp IS INITIAL.
    ps_head-vkgrp = |{ ls_vkgrp_s-vkgrp } | && | { ls_vkgrp_s-vkgrp_txt }|.

  ELSEIF ls_vkgrp_s-vkgrp IS INITIAL     AND ls_vkgrp_e-vkgrp IS NOT INITIAL.
    ps_head-vkgrp = |{ ls_vkgrp_e-vkgrp } | && | { ls_vkgrp_e-vkgrp_txt }|.

  ELSEIF ls_vkgrp_s-vkgrp EQ ls_vkgrp_e-vkgrp.
    ps_head-vkgrp = |{ ls_vkgrp_s-vkgrp } | && | { ls_vkgrp_s-vkgrp_txt }|.

  ELSEIF ls_vkgrp_s-vkgrp NE ls_vkgrp_e-vkgrp.
    ps_head-vkgrp = |{ ls_vkgrp_s-vkgrp }| && | { '~' } | && |{ ls_vkgrp_e-vkgrp }|.

  ENDIF.

* 출하요청일 ( from / to )
  IF s_wadat[] IS NOT INITIAL.
    DATA(ls_date) = VALUE #( s_wadat[ 1 ]  OPTIONAL ).

    CLEAR: lv_date_l, lv_date_h.
    WRITE: ls_date-low  TO lv_date_l,
           ls_date-high TO lv_date_h.
    ps_head-wadat = |{ lv_date_l }| && | { '~' } | && |{ lv_date_h }|.

  ENDIF.

* lgort(25),         " 저장위치 + 저장위치명
  DATA(lt_lgort) = gt_stab[].
  DELETE lt_lgort WHERE vstel NE ps_data-vstel.

  SORT: lt_lgort BY lgort.
  DATA(ls_lgort_s) = VALUE #( lt_lgort[ 1 ]  OPTIONAL ).

  SORT: lt_lgort DESCENDING BY lgort.
  DATA(ls_lgort_e) = VALUE #( lt_lgort[ 1 ]  OPTIONAL ).

  IF     ls_lgort_s-lgort IS INITIAL     AND ls_lgort_e-lgort IS INITIAL.
    ps_head-lgort = '*'.

  ELSEIF ls_lgort_s-lgort IS NOT INITIAL AND ls_lgort_e-lgort IS INITIAL.

    SELECT SINGLE lgobe  INTO @DATA(lv_lgobe)
      FROM t001l  WHERE werks EQ @ls_lgort_s-werks
                    AND lgort EQ @ls_lgort_s-lgort.

    ps_head-lgort = |{ ls_lgort_s-lgort } | && | { lv_lgobe }|.

  ELSEIF ls_lgort_s-lgort IS INITIAL     AND ls_lgort_e-lgort IS NOT INITIAL.

    CLEAR: lv_lgobe.
    SELECT SINGLE lgobe  INTO @lv_lgobe
      FROM t001l  WHERE werks EQ @ls_lgort_e-werks
                    AND lgort EQ @ls_lgort_e-lgort.

    ps_head-lgort = |{ ls_lgort_e-lgort } | && | { lv_lgobe }|.

  ELSEIF ls_lgort_s-lgort EQ ls_lgort_e-lgort.

    CLEAR: lv_lgobe.
    SELECT SINGLE lgobe  INTO @lv_lgobe
      FROM t001l  WHERE werks EQ @ls_lgort_s-werks
                    AND lgort EQ @ls_lgort_s-lgort.

    ps_head-lgort = |{ ls_lgort_s-lgort } | && | { lv_lgobe }|.

  ELSEIF ls_lgort_s-lgort NE ls_lgort_e-lgort.
    ps_head-lgort = |{ ls_lgort_s-lgort }| && | { '~' } | && |{ ls_lgort_e-lgort }|.

  ENDIF.

* 출력일
  WRITE: sy-datlo TO ps_head-prt_date.
* prt_time(8),       " 출력시간
  WRITE: sy-timlo TO ps_head-prt_time.

**
  FREE: lt_vkgrp, lt_lgort.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form make_download_item_data
*&---------------------------------------------------------------------*
FORM make_download_item_data  TABLES   pt_tab   STRUCTURE gt_list
                                       pt_data  LIKE gt_picking
                              USING    pi_type
                                       ps_data  LIKE gt_list.

  DATA: lv_color(15),
        ls_picking    LIKE gs_picking,
        lv_seq(4)     TYPE i,
        lv_lfimg_s    LIKE lips-lfimg ,          " 납품수량
        lv_factor_s   TYPE p DECIMALS 0 ,        " 조장수
*       A형 Only
        lv_brgew_s    LIKE mara-brgew ,          " 총 중량(드럼포함)
*       B형 Only
        lv_kgw_s      TYPE /nfm/kgw ,            " 동량
        lv_fiber_s    TYPE p DECIMALS 2 ,        " F량
**      Total Summary
        lv_lfimg_tot  LIKE lips-lfimg ,          " 납품수량
        lv_factor_tot TYPE p DECIMALS 0 ,        " 조장수
*       A형 Only
        lv_brgew_tot  LIKE mara-brgew ,          " 총 중량(드럼포함)
*       B형 Only
        lv_kgw_tot    TYPE /nfm/kgw ,            " 동량
        lv_fiber_tot  TYPE p DECIMALS 2 .        " F량

**
  _clear: pt_data.

  DATA(lt_vkgrp_grp) = pt_tab[].
  DELETE: lt_vkgrp_grp WHERE vstel NE ps_data-vstel.

  SORT: pt_tab       BY vstel vkgrp kunag vbeln posnr,
        lt_vkgrp_grp BY vkgrp.

  DELETE ADJACENT DUPLICATES FROM lt_vkgrp_grp COMPARING vkgrp.

  CLEAR: lv_seq,
         lv_lfimg_tot, lv_factor_tot, lv_brgew_tot,
         lv_kgw_tot, lv_fiber_tot.

  LOOP AT lt_vkgrp_grp  INTO DATA(ls_vkgrp).

    lv_seq = lv_seq + 1.

    CLEAR: gs_picking.
*   영업그룹 Summary line.
    gs_picking = VALUE #( seq      = lv_seq
                          type     = 'S'
                          kunag_nm = ls_vkgrp-vkgrp_txt
                         ).

    CLEAR: lv_lfimg_s,         " 납품수량
           lv_factor_s,        " 조장수
*          A형 Only
           lv_brgew_s,         " 총 중량
*          B형 Only
           lv_kgw_s,           " 동량
           lv_fiber_s.         " F량

    READ TABLE pt_tab  INTO DATA(ls_tab)
                       WITH KEY vstel = ls_vkgrp-vstel
                                vkgrp = ls_vkgrp-vkgrp
                       BINARY SEARCH.
    IF sy-subrc = 0.
      LOOP AT pt_tab INTO ls_tab  FROM sy-tabix.
        IF ls_tab-vstel = ls_vkgrp-vstel AND
           ls_tab-vkgrp = ls_vkgrp-vkgrp.

          lv_seq = lv_seq + 1.

          CLEAR: lv_color.
          lv_color = ls_tab-color.         " 색상
          IF ls_tab-str IS NOT INITIAL OR
             ls_tab-str_no IS NOT INITIAL.
            CONDENSE: lv_color      NO-GAPS,
                      ls_tab-str    NO-GAPS,
                      ls_tab-str_no NO-GAPS.
            lv_color = lv_color && '/' && ls_tab-str_no && ls_tab-str.
          ENDIF.

          CLEAR: ls_picking.
          ls_picking = VALUE #( seq      = lv_seq
*                               Line Type: T: Total Sum, S:Sub Sum, N: Nomal.
                                type     = 'N'
                                kunag_nm = ls_tab-kunag_nm  " 영업그룹명, 판매처명
*                               거래명세서번호 유무( 유: 완, 무: Null )
                                iv_stat  = COND #( WHEN ls_tab-iv_no IS NOT INITIAL
                                                        THEN '완'
                                                   ELSE space )
                                zzyuscd  = ls_tab-zzyuscd    " 영업소코드
                                vbeln    = ls_tab-vgbel      " 주문번호
                                posnr    = condense( |{ ls_tab-vgpos ALPHA = OUT }| )      " 항번
                                maktx    = ls_tab-maktx         " 자재내역
*                                color    = ls_tab-color         " 색상
                                color    = lv_color             " 색상/띄줄Str
                                fixmg    = ls_tab-fixmg         " OS.
                                zgubun   = ls_tab-zgubun        " 구분
                                route_txt  = ls_tab-route_txt   " 운송경로명
                                remark     = ls_tab-remark      " 특기사항
                                city1      = ls_tab-city1       " 납지
                                pack_gubun = ls_tab-pack_gubun  " 포장구분
                                iv_no       = ls_tab-iv_no      " 거래명세서번호
                                tknum       = ls_tab-tknum      " 선적번호
                               ).

*         저장위치명
          IF ls_tab-lgort IS NOT INITIAL.
            SELECT SINGLE lgobe  INTO @ls_picking-lgort_nm
              FROM t001l  WHERE werks EQ @ls_tab-werks
                            AND lgort EQ @ls_tab-lgort.

          ENDIF.
*         출고요청일 / 입력일
          WRITE: ls_tab-wadat TO ls_picking-wadat,
                 ls_tab-erdat TO ls_picking-erdat.

          PERFORM convt_number_to_char
*                        납품수량
                  USING: 'P0'  ls_tab-lfimg     CHANGING ls_picking-lfimg,
*                        조장
                         'C0'  ls_tab-length    CHANGING ls_picking-length,
*                        조장수
                         'C0'  ls_tab-factor    CHANGING ls_picking-factor.

          IF     pi_type = 'A'.
            PERFORM convt_number_to_char
*                          총중량
                    USING: 'P1'  ls_tab-total_brgew CHANGING ls_picking-total_brgew,
*                          약경
                           'P0'  ls_tab-plan_dia    CHANGING ls_picking-plan_dia,
*                          폭
                           'P0'  ls_tab-out_wid     CHANGING ls_picking-out_wid.

          ELSEIF pi_type = 'B'.
            PERFORM convt_number_to_char
*                          동량
                    USING: 'P1'  ls_tab-kgw       CHANGING ls_picking-kgw,
*                          F 량
                           'P'   ls_tab-fiber_n   CHANGING ls_picking-fiber.
          ENDIF.

          lv_lfimg_s  = lv_lfimg_s  + ls_tab-lfimg.     " 납품수량
          lv_factor_s = lv_factor_s + ls_tab-factor_n.  " 조장수
*          A형 Only
          lv_brgew_s  = lv_brgew_s  + ls_tab-total_brgew.     " 총 중량
*          B형 Only
          lv_kgw_s    = lv_kgw_s    + ls_tab-kgw.       " 동량
          lv_fiber_s  = lv_fiber_s  + ls_tab-fiber_n.   " F량

          APPEND ls_picking TO pt_data.

        ELSE.
          EXIT.
        ENDIF.
      ENDLOOP.
    ENDIF.

    PERFORM convt_number_to_char
*                  납품수량 Total
            USING: 'P0'  lv_lfimg_s   CHANGING gs_picking-lfimg,
*                  조장수 Total
                   'P0'  lv_factor_s  CHANGING gs_picking-factor.

    IF     pi_type = 'A'.
      PERFORM convt_number_to_char
*                  중량 Total
              USING: 'P1'  lv_brgew_s   CHANGING gs_picking-total_brgew.

    ELSEIF pi_type = 'B'.
      PERFORM convt_number_to_char
*                  동량 Total
              USING: 'P1'  lv_kgw_s     CHANGING gs_picking-kgw,
*                  F 량 계산 Total
                     'P'   lv_fiber_s   CHANGING gs_picking-fiber.
    ENDIF.

    APPEND gs_picking TO pt_data.

*   Total Summary
    lv_lfimg_tot  = lv_lfimg_tot  + lv_lfimg_s.
    lv_factor_tot = lv_factor_tot + lv_factor_s.
    lv_brgew_tot  = lv_brgew_tot  + lv_brgew_s.
    lv_kgw_tot    = lv_kgw_tot    + lv_kgw_s.
    lv_fiber_tot  = lv_fiber_tot  + lv_fiber_s.

  ENDLOOP.

*** For Test
*  IF pt_data[] IS NOT INITIAL.
*
*    DATA(lt_temp) = pt_data[].
*    SORT: lt_temp BY seq.
*
*    DO 6 TIMES.
*      LOOP AT lt_temp  INTO DATA(ls_temp).
*        IF ls_temp-type NE 'T'.
*          lv_seq = lv_seq + 1.
*          ls_temp-seq = lv_seq.
*          APPEND ls_temp TO pt_data.
*        ENDIF.
*      ENDLOOP.
*
*    ENDDO.
*
*  ENDIF.
***

  CLEAR: gs_picking.
  lv_seq = lv_seq + 1.

  gs_picking = VALUE #( seq      = lv_seq
                        type     = 'T'
                        kunag_nm = 'Sum'
                       ).
* Total Summary Line
  PERFORM convt_number_to_char
*                납품수량 Total
          USING: 'P0'  lv_lfimg_tot   CHANGING gs_picking-lfimg,
*                조장수 Total
                 'P0'  lv_factor_tot  CHANGING gs_picking-factor.

  IF     pi_type = 'A'.
    PERFORM convt_number_to_char
*                  중량 Total
            USING: 'P1'  lv_brgew_tot   CHANGING gs_picking-total_brgew.

  ELSEIF pi_type = 'B'.
    PERFORM convt_number_to_char
*                  동량 Total
            USING: 'P1'  lv_kgw_tot     CHANGING gs_picking-kgw,
*                  F 량 계산 Total
                   'P'   lv_fiber_tot   CHANGING gs_picking-fiber.
  ENDIF.

  APPEND gs_picking TO pt_data.

**
  FREE: lt_vkgrp_grp.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form make_ole_object
*&---------------------------------------------------------------------*
FORM make_ole_object  TABLES   pt_data   LIKE gt_picking
                      USING    ps_head   LIKE gs_pick_head
                               pi_path
                               pi_type
                      CHANGING pe_error.

  DATA: lv_page TYPE i.

**
  CHECK: pe_error IS INITIAL,
         pi_path  IS NOT INITIAL.

* 1) Create Excel work-sheet (OLE)
  PERFORM create_excel_object         USING    pi_path
                                      CHANGING pe_error.

* 2) Set Header Data
  PERFORM set_header_value_to_cell    USING    ps_head
                                               pi_type.

* 3) Set Item Data
  PERFORM set_item_value_to_cell      TABLES   pt_data
                                      USING    pi_type
                                      CHANGING lv_page.

* 4) Set Page No.
  PERFORM set_page_no_total           USING    lv_page
                                               pi_type.

* 5) Excel Save
  PERFORM save_excel_ole_object       USING    pi_path.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form create_excel_object
*&---------------------------------------------------------------------*
FORM create_excel_object  USING    pi_path
                          CHANGING pe_error.

  DATA: lv_sheet_nm(20).

**
* 1) Create Excel OLE Object.
  CREATE OBJECT go_excel 'EXCEL.APPLICATION'.
  IF sy-subrc NE 0.
    MESSAGE s000 WITH 'EXCEL creation Error'  DISPLAY LIKE 'E'.
    pe_error = 'X'.
    EXIT.
  ENDIF.

  CHECK: pe_error IS INITIAL.

* 0: 팝업 비활성화 , 1: 활성화
  SET PROPERTY OF: go_excel 'DisplayAlerts' = 0.

* Excel 화면을 볼것인가?
  SET PROPERTY OF: go_excel 'VISIBLE' = 0.

* Work Area Set.
  CALL METHOD OF go_excel 'WORKBOOKS' = go_workbook.

  CALL METHOD OF go_workbook  'OPEN' = go_workopen
    EXPORTING
      #1 = pi_path.
  IF sy-subrc NE 0.
    MESSAGE s000 WITH 'EXCEL creation Error'  DISPLAY LIKE 'E'.
    pe_error = 'X'.
    EXIT.
  ENDIF.

* Work Sheet Active.
*  CALL METHOD OF go_excel  'WORKSHEETS' = go_sheet
*    EXPORTING
*      #1 = 1.
*  IF sy-subrc NE 0.
*    MESSAGE s000 WITH 'EXCEL creation Error'  DISPLAY LIKE 'E'.
*    pe_error = 'X'.
*    EXIT.
*  ELSE.

  CLEAR: lv_sheet_nm.
  lv_sheet_nm = 'Picking List'.

*    CALL METHOD OF go_sheet 'ACTIVATE'.
  GET PROPERTY OF go_excel  'ACTIVESHEET' = go_sheet.
  SET PROPERTY OF go_sheet  'Name' = lv_sheet_nm.

*  ENDIF.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form set_header_value_to_cell
*&---------------------------------------------------------------------*
FORM set_header_value_to_cell  USING    ps_head   LIKE gs_pick_head
                                        pi_type.

**
  CHECK: ps_head IS NOT INITIAL.

* 출하지점 + 출하지점명
  PERFORM set_value_to_cell    USING:  1  2  0  ps_head-vstel.

* 영업그룹 + 영업그룹명
  PERFORM set_value_to_cell    USING:  2  2  0  ps_head-vkgrp.

* 출하요청일 ( from / to )
  PERFORM set_value_to_cell    USING:  3  2  0  ps_head-wadat.

* 저장위치 + 저장위치명
  PERFORM set_value_to_cell    USING:  4  2  0  ps_head-lgort.

* 신규발행시 Picking list 표시
  IF rb_new = 'X'.
    PERFORM set_value_to_cell    USING:  1  6  0  'PRE'.
  ENDIF.
*

  IF     pi_type = 'A'.    " A형(군포용)
* 출력일
    PERFORM set_value_to_cell    USING:  4  23  0  ps_head-prt_date.

* 출력시간
    PERFORM set_value_to_cell    USING:  4  24  0  ps_head-prt_time.

  ELSEIF pi_type = 'B'.    " B형(전주용)
* 출력일
    PERFORM set_value_to_cell    USING:  4  19  0  ps_head-prt_date.

* 출력시간
    PERFORM set_value_to_cell    USING:  4  20  0  ps_head-prt_time.

  ENDIF.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form set_value_to_cell
*&---------------------------------------------------------------------*
FORM set_value_to_cell  USING    pi_row
                                 pi_col
                                 pi_bold
                                 pi_value.

  DATA: lo_cell TYPE ole2_object,
        lo_font TYPE ole2_object.

**
  CALL METHOD OF go_sheet  'CELLS' = lo_cell
    EXPORTING
      #1 = pi_row
      #2 = pi_col.

  SET PROPERTY OF lo_cell  'VALUE' = pi_value.

*  CALL METHOD OF lo_cell 'SELECT'.

  CALL METHOD OF lo_cell 'FONT' = lo_font.
  SET PROPERTY OF lo_font 'BOLD' = pi_bold.


**
  FREE OBJECT: lo_cell,
               lo_font.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form set_item_value_to_cell
*&---------------------------------------------------------------------*
FORM set_item_value_to_cell  TABLES   pt_data     LIKE gt_picking
                             USING    pi_type
                             CHANGING pe_page.

  DATA: lv_row  TYPE i,
        lv_line TYPE i.

**
  CHECK: pt_data[] IS NOT INITIAL.

  SORT: pt_data BY seq.

  CLEAR: lv_row.
  lv_row = 6.    " Header + item title line.

  DATA(lv_first_s) = 'X'.
  DATA(lv_first_n) = 'X'.

  CLEAR: lv_line.
  lv_line = 6.

  CLEAR: pe_page.
  pe_page = 1.

  LOOP AT pt_data  INTO DATA(ls_data).

**  Page Split.
    PERFORM page_split_and_setup     USING    lv_line
                                     CHANGING lv_row
                                              pe_page.

    IF     ls_data-type = 'S'.    " Sub Sum.
      PERFORM set_summary_line       USING   lv_first_s
                                             lv_first_n
                                             lv_row
                                             pi_type
                                             ls_data.

    ELSEIF ls_data-type = 'N'.    " Nomal.
      PERFORM set_nomal_line         USING   lv_first_n
                                             lv_row
                                             pi_type
                                             ls_data.

    ELSEIF ls_data-type = 'T'.    " Total Sum.
      PERFORM set_total_sum_line     USING   lv_row
                                             pi_type
                                             ls_data.
    ENDIF.

    lv_line = lv_line + 1.

  ENDLOOP.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form save_excel_ole_object
*&---------------------------------------------------------------------*
FORM save_excel_ole_object  USING    pi_path.

  DATA: lo_setup  TYPE ole2_object.

**
** 가로출력 설정
*  get PROPERTY OF po_sheet  'PageSetup' = lo_setup.
*
*  set PROPERTY OF lo_setup  'Orientation' = 2.    " 1:세로, 2:가로.
*  set PROPERTY OF lo_setup  'Zoom' = 50.          " 배율 조정
*  set PROPERTY OF lo_setup  'FitToPagesWide' = 1. " 컬럼너비

* Excel Save
  GET PROPERTY OF go_excel 'ActiveSheet'    = go_sheet.

  GET PROPERTY OF go_excel 'ActiveWorkbook' = go_workbook.

  CALL METHOD OF go_workbook 'SAVEAs'
    EXPORTING
      #1 = pi_path
      #2 = 1.

  CALL METHOD OF go_workbook 'CLOSE'.

  CALL METHOD OF go_excel 'QUIT'.

**
  FREE OBJECT: go_excel,
               go_workbook,
               go_workopen,
               go_sheet.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form set_value_item_line_to_cell
*&---------------------------------------------------------------------*
FORM set_value_item_line_to_cell  USING    pi_row
                                           pi_type
                                           ps_data  LIKE gs_picking.

  DATA: lv_col TYPE i.

**
  CLEAR: lv_col.
  PERFORM make_item_value_line    USING:  pi_row  lv_col  ps_data-kunag_nm,  " 영업그룹명, 판매처명
                                          pi_row  lv_col  ps_data-iv_stat,   " 거래명세서번호 유무( 유: 완, 무: Null )
                                          pi_row  lv_col  ps_data-zzyuscd,   " 영업소코드
                                          pi_row  lv_col  ps_data-vbeln,     " 주문번호
                                          pi_row  lv_col  ps_data-posnr,     " 항번
                                          pi_row  lv_col  ps_data-maktx,     " 자재내역
                                          pi_row  lv_col  ps_data-color.     " 색상

  IF     pi_type = 'A'.    " A형
    PERFORM make_item_value_line    USING:  pi_row  lv_col  ps_data-lfimg,       " 납품수량
                                            pi_row  lv_col  ps_data-length,      " 조장
                                            pi_row  lv_col  ps_data-factor,      " 조장수
                                            pi_row  lv_col  ps_data-fixmg,       " OS.
                                            pi_row  lv_col  ps_data-zgubun,      " 구분
                                            pi_row  lv_col  ps_data-plan_dia,    " 약경
                                            pi_row  lv_col  ps_data-out_wid,     " 폭
                                            pi_row  lv_col  ps_data-total_brgew, " 총중량
                                            pi_row  lv_col  ps_data-route_txt,   " 운송경로명
                                            pi_row  lv_col  ps_data-remark,      " 특기사항
                                            pi_row  lv_col  ps_data-city1,       " 납지
                                            pi_row  lv_col  ps_data-pack_gubun,  " 포장구분
                                            pi_row  lv_col  ps_data-wadat,       " 출고요청일
                                            pi_row  lv_col  ps_data-erdat,       " 입력일
                                            pi_row  lv_col  ps_data-lgort_nm,    " 저장위치명
                                            pi_row  lv_col  ps_data-iv_no,       " 거래명세서번호
                                            pi_row  lv_col  ps_data-tknum.       " 선적번호

  ELSEIF pi_type = 'B'.    " B형
    PERFORM make_item_value_line    USING:  pi_row  lv_col  ps_data-kgw,         " 동량
                                            pi_row  lv_col  ps_data-fiber,       " F량
                                            pi_row  lv_col  ps_data-lfimg,       " 납품수량
                                            pi_row  lv_col  ps_data-length,      " 조장
                                            pi_row  lv_col  ps_data-factor,      " 조장수
                                            pi_row  lv_col  ps_data-fixmg,       " OS.
                                            pi_row  lv_col  ps_data-zgubun,      " 구분
                                            pi_row  lv_col  ps_data-route_txt,   " 운송경로명
                                            pi_row  lv_col  ps_data-wadat,       " 출고요청일
                                            pi_row  lv_col  ps_data-remark,      " 특기사항
                                            pi_row  lv_col  ps_data-city1.       " 납지

  ENDIF.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form make_item_value_line
*&---------------------------------------------------------------------*
FORM make_item_value_line  USING    pi_row
                                    pi_col
                                    pi_value.

**
  pi_col = pi_col + 1.

  PERFORM set_value_to_cell    USING:  pi_row  pi_col  0  pi_value.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form set_summary_line
*&---------------------------------------------------------------------*
FORM set_summary_line  USING    pi_first
                                pi_first_n
                                pi_row
                                pi_type
                                ps_data   LIKE gs_picking.

  DATA: lv_row  TYPE i.

**
* start row no.
  pi_row = pi_row + 1.

  IF pi_first = 'X'.
*   첫번째 Summary line.
    PERFORM set_value_item_line_to_cell   USING  pi_row
                                                 pi_type
                                                 ps_data.
    CLEAR: pi_first.

  ELSE.
*   Summary line copy and insert.
    PERFORM rows_copy_and_insert          USING  ps_data-type
                                                 pi_row.

    PERFORM set_value_item_line_to_cell   USING  pi_row
                                                 pi_type
                                                 ps_data.

*   Summary line 의 경우 다음 Normal Line을 미리 추가
    CLEAR: lv_row.
    lv_row = pi_row + 1.
    PERFORM rows_copy_and_insert          USING  'N'
                                                 lv_row.
*   Set Normal Line first flag.
    pi_first_n = 'X'.

  ENDIF.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form set_nomal_line
*&---------------------------------------------------------------------*
FORM set_nomal_line  USING    pi_first
                              pi_row
                              pi_type
                              ps_data   LIKE gs_picking.

**
* start row no.
  pi_row = pi_row + 1.

  IF pi_first = 'X'.
*   첫번째 Nomal line.
    PERFORM set_value_item_line_to_cell   USING  pi_row
                                                 pi_type
                                                 ps_data.
    CLEAR: pi_first.

  ELSE.
*   Nomal line copy and insert.
    PERFORM rows_copy_and_insert          USING  ps_data-type
                                                 pi_row.

    PERFORM set_value_item_line_to_cell   USING  pi_row
                                                 pi_type
                                                 ps_data.
  ENDIF.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form rows_copy_and_insert
*&---------------------------------------------------------------------*
FORM rows_copy_and_insert  USING    pi_type  pi_row.

  DATA: lv_row      TYPE i,

        lo_copy_row TYPE ole2_object,
        lo_row      TYPE ole2_object.

**
  CLEAR: lv_row.
  IF     pi_type = 'S'.    " Sub Sum.
    lv_row = 7.

  ELSEIF pi_type = 'N'.    " Nomal.
    lv_row = 8.

  ENDIF.

* Line Copy
  CALL METHOD OF go_excel  'Rows' = lo_copy_row
    EXPORTING
      #1 = lv_row.

  CALL METHOD OF lo_copy_row 'Select'.
  CALL METHOD OF lo_copy_row 'Copy'.

* Insert line.
  CALL METHOD OF go_excel  'Rows' = lo_row
    EXPORTING
      #1 = pi_row.

  CALL METHOD OF lo_row 'Select'.
  CALL METHOD OF lo_row 'Insert'.

**
  FREE OBJECT: lo_copy_row, lo_row.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form set_total_sum_line
*&---------------------------------------------------------------------*
FORM set_total_sum_line  USING    pi_row
                                  pi_type
                                  ps_data   LIKE gs_picking.

**
* start row no.
  pi_row = pi_row + 1.

  PERFORM set_value_item_line_to_cell   USING  pi_row
                                               pi_type
                                               ps_data.
**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form page_split_and_setup
*&---------------------------------------------------------------------*
FORM page_split_and_setup  USING    pi_line
                           CHANGING pe_row
                                    pe_page.

  DATA: lv_row      TYPE i,

        lo_copy_row TYPE ole2_object,
        lo_row      TYPE ole2_object,
        lo_range    TYPE ole2_object,
        lo_row2     TYPE ole2_object.

**
  CHECK: pi_line = 35.

**
  pe_page = pe_page + 1.

  CLEAR: pi_line, lv_row.
  lv_row = pe_row + 1.

* 1) 빈 Line 삽입.
* Line Copy
  CALL METHOD OF go_excel  'Rows' = lo_copy_row
    EXPORTING
      #1 = 5.

  CALL METHOD OF lo_copy_row 'Select'.
  CALL METHOD OF lo_copy_row 'Copy'.

* Insert line.
  CALL METHOD OF go_excel  'Rows' = lo_row
    EXPORTING
      #1 = lv_row.

  CALL METHOD OF lo_row 'Select'.
  CALL METHOD OF lo_row 'Insert'.

* 2) Title / Header row copy
  pe_row = pe_row + 2.

* Line Copy
  CALL METHOD OF go_excel  'Range' = lo_range
    EXPORTING
      #1 = '1:6'.

  CALL METHOD OF lo_range 'Select'.
  CALL METHOD OF lo_range 'Copy'.

* Insert line.
  CALL METHOD OF go_excel  'Rows' = lo_row2
    EXPORTING
      #1 = pe_row.

  CALL METHOD OF lo_row2 'Select'.
  CALL METHOD OF lo_row2 'Insert'.

* Next Page 시작점.
  pe_row = pe_row + 5.
  pi_line = pi_line + 6.

**
  FREE OBJECT: lo_copy_row, lo_row,
               lo_range, lo_row2.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form set_page_no_total
*&---------------------------------------------------------------------*
FORM set_page_no_total  USING    pi_tot_page
                                 pi_type.

  DATA: lv_page TYPE i,
        lv_row  TYPE i,
        lv_col  TYPE i.

**
  CLEAR: lv_page, lv_row.

  WHILE lv_page < pi_tot_page.
    lv_page = lv_page + 1.
    lv_row  = lv_row  + 3.

    DATA(lv_text) = lv_page && | { 'of' } | && pi_tot_page.

    IF     pi_type = 'A'.    " A형(군포용)
      PERFORM set_value_to_cell    USING:  lv_row  24  0  lv_text.
    ELSEIF pi_type = 'B'.    " B형(전주용)
      PERFORM set_value_to_cell    USING:  lv_row  20  0  lv_text.
    ENDIF.

    lv_row = lv_row + 33.

  ENDWHILE.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form update_iv_no_to_disp_list
*&---------------------------------------------------------------------*
FORM update_iv_no_to_disp_list  TABLES   pt_tab STRUCTURE gt_list.

**
  CHECK: pt_tab[] IS NOT INITIAL.

  DATA(lt_tab) = pt_tab[].
  SORT: lt_tab BY vbeln .
  DELETE ADJACENT DUPLICATES FROM lt_tab COMPARING vbeln.

  LOOP AT lt_tab  INTO DATA(ls_tab).

    MODIFY gt_list  FROM VALUE #( iv_no = ls_tab-iv_no )
                    TRANSPORTING iv_no
                    WHERE vbeln = ls_tab-vbeln.

  ENDLOOP.

**
  FREE: lt_tab.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form check_already_print_data
*&---------------------------------------------------------------------*
FORM check_already_print_data .

  CHECK: gv_error  IS INITIAL,
         gt_stab[] IS NOT INITIAL,
         rb_new    EQ 'X'.    " 신규발행.

  DATA(lv_cnt) = REDUCE i( INIT x = 0  FOR ls_tab IN gt_stab
                           WHERE ( iv_no IS NOT INITIAL )
                           NEXT x = x + 1 ).

  IF lv_cnt > 0.
    gv_error = 'X'.
*   거래명세서가 이미 발행되었습니다.
    MESSAGE s000 WITH TEXT-e16  DISPLAY LIKE 'E'.
  ENDIF.

**

ENDFORM.
*&---------------------------------------------------------------------*
*& Form send_mes_with_do
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LS_DO_VBELN
*&      <-- PE_ERROR
*&---------------------------------------------------------------------*
FORM send_mes_with_do  USING    pi_vbeln
                       CHANGING pe_error.

  DATA: lv_jobname      LIKE tbtcjob-jobname,
        lv_jobname_head LIKE tbtcjob-jobname,
        lv_jobcount     LIKE tbtcjob-jobcount,

        lv_go(1),
        lv_gp(1),
        lv_gc(1).

  RANGES: lr_vbeln  FOR lips-vbeln,
          lr_erdat FOR vbak-erdat .

**
  CHECK: pi_vbeln IS NOT INITIAL.

  SELECT SINGLE *  INTO @DATA(ls_lips)
    FROM lips  WHERE vbeln EQ @pi_vbeln.

*  SELECT COUNT(*)  INTO @DATA(lv_cnt)
*    FROM zlet0201  WHERE zcodh EQ 'SO04'
*                     AND zdesi EQ @ls_0005-werks.

  SELECT SINGLE fld_01 INTO @DATA(lv_target)
    FROM zgtppt1010  WHERE module_kind EQ 'PP'
                       AND codegrp     EQ '0010'
                       AND fld_03      EQ @ls_lips-werks
                       AND fld_04      NE @space.

  CLEAR: lv_jobname_head, lv_gp, lv_go, lv_gc.
  IF lv_target IS NOT INITIAL.

    lv_jobname_head = |{ '[SD]C_' }| && |{ lv_target }| && |{ '_납품오더(' }|.

    IF     lv_target = 'KGOM'.
      CLEAR: lv_gp, lv_gc.    lv_go = 'X'.
    ELSEIF lv_target = 'KGPM'.
      lv_gp = 'X'.    CLEAR: lv_go, lv_gc.
    ENDIF.

  ENDIF.

*  IF lv_cnt    IS NOT INITIAL AND
*     lv_target IS NOT INITIAL.
  IF lv_target IS NOT INITIAL.


    CLEAR: lv_jobname, lv_jobcount.
    lv_jobname = |{ lv_jobname_head }| && |{ pi_vbeln }| && |{ ')' }|.

    CALL FUNCTION 'JOB_OPEN'
      EXPORTING
        jobname          = lv_jobname
        jobclass         = 'A'
      IMPORTING
        jobcount         = lv_jobcount
      EXCEPTIONS
        cant_create_job  = 1
        invalid_job_data = 2
        jobname_missing  = 3
        OTHERS           = 4.

    _clear: lr_vbeln, lr_erdat.
    lr_vbeln[] = VALUE #( ( sign = 'I' option = 'EQ' low  = pi_vbeln ) ).
    lr_erdat[] = VALUE #( ( sign = 'I' option = 'BT' low  = ls_lips-erdat
                                                  high = ls_lips-erdat ) ).
*
    SUBMIT zgtsdi0003 VIA JOB lv_jobname  NUMBER lv_jobcount
                      AND RETURN
                      WITH s_vbeln  IN lr_vbeln
                      WITH s_erdat  IN lr_erdat
                      WITH rb_send  EQ 'X'
                      WITH rb_10    EQ ' '
                      WITH rb_t1    EQ ' '
                      WITH rb_gp    EQ lv_gp
                      WITH rb_go    EQ lv_go
                      WITH p_call   EQ 'X'.

    CALL FUNCTION 'JOB_CLOSE'
      EXPORTING
        jobcount             = lv_jobcount
        jobname              = lv_jobname
        strtimmed            = 'X'
      EXCEPTIONS
        cant_start_immediate = 1
        invalid_startdate    = 2
        jobname_missing      = 3
        job_close_failed     = 4
        job_nosteps          = 5
        job_notex            = 6
        lock_failed          = 7
        OTHERS               = 8.

  ENDIF.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form popup_to_confirm_with_cnt
*&---------------------------------------------------------------------*
FORM popup_to_confirm_with_cnt  USING    pi_title
                                         pi_text1
                                         pi_text2
                                CHANGING pe_answer.

**
  CHECK: gv_error IS INITIAL.

  CLEAR: gv_title, gv_text1, gv_text2, gv_copies,
         gv_title_chk1, gv_title_chk2, gv_title_chk3, gv_title_chk4.

  gv_title  = pi_title.
  gv_text1  = pi_text1.
  gv_text2  = pi_text2.

  IF     p_bzarea+0(2) = '65'.
    gv_copies = '4'.
    gv_title_chk1 = gv_title_chk2 = gv_title_chk3 = gv_title_chk4 = 'X'.

  ELSEIF p_bzarea+0(2) = '66'.
    gv_copies = '3'.
    gv_title_chk1 = gv_title_chk2 = gv_title_chk3 = 'X'.

  ENDIF.

  CLEAR: gv_okcode2, gv_answer.

  CALL SCREEN 200  STARTING AT 25 7.

  pe_answer = gv_answer.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form check_input_copies
*&---------------------------------------------------------------------*
FORM check_input_copies .

  DATA: lv_chk_cnt(1).

**
  CLEAR: lv_chk_cnt.
  IF gv_copies IS INITIAL OR
     gv_copies = 0.
    gv_error = 'X'.
*   출력매수가 없습니다.
    MESSAGE s000 WITH TEXT-e17  DISPLAY LIKE 'E'.
    CLEAR: gv_answer.

  ELSE.
    IF gv_title_chk1 = 'X'.
      lv_chk_cnt = lv_chk_cnt + 1.
      APPEND VALUE #( seq   = lv_chk_cnt
                      title = TEXT-t06   " 지게차용
                     ) TO gt_prt_title.
    ENDIF.
    IF gv_title_chk3 = 'X'.
      lv_chk_cnt = lv_chk_cnt + 1.
      APPEND VALUE #( seq   = lv_chk_cnt
                      title = TEXT-t08   " 경비실제출
                     ) TO gt_prt_title.
    ENDIF.
    IF gv_title_chk2 = 'X'.
      lv_chk_cnt = lv_chk_cnt + 1.
      APPEND VALUE #( seq   = lv_chk_cnt
                      title = TEXT-t07   " 기사용
                     ) TO gt_prt_title.
    ENDIF.
    IF gv_title_chk4 = 'X'.
      lv_chk_cnt = lv_chk_cnt + 1.
      APPEND VALUE #( seq   = lv_chk_cnt
                      title = TEXT-t09   " 인수용
                     ) TO gt_prt_title.
    ENDIF.

    IF lv_chk_cnt NE gv_copies.
      gv_error = 'X'.
*     출력매수만큼 제목을 선택해야 합니다.
      MESSAGE s000 WITH TEXT-e19  DISPLAY LIKE 'E'.
      CLEAR: gv_answer.
      _clear: gt_prt_title.
    ENDIF.

  ENDIF.

  IF gv_error IS INITIAL.
    gv_answer = 'J'.
  ENDIF.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form get_characteristic_data
*&---------------------------------------------------------------------*
FORM get_characteristic_data .

**
  CHECK: gt_list[] IS NOT INITIAL.

  _clear: gt_char.

  DATA(lt_list) = gt_list[].
  SORT: lt_list BY vgbel vgpos.
  DELETE ADJACENT DUPLICATES FROM lt_list COMPARING vgbel vgpos.

  SELECT a~vgbel AS vbeln, a~vgpos AS posnr,
         b~matnr,
         b~length, b~factor,        " 조장 / 조장수
         b~pkgtyp AS pack_gubun,    " 포장구분 ( PD_GA_PACKAGE_METHOD )
         c~atwrt  AS color,
         d~atwrt  AS str,
         e~atwrt  AS str_no,
         f~atwrt  AS fiber
    FROM @lt_list AS a  INNER JOIN zgtsd_cv_get_vcofso AS b
                        ON  a~vgbel = b~vbeln
                        AND a~vgpos = b~posnr
                        LEFT JOIN zgtsd_i_materialcharacteristic AS c
                        ON  b~matnr EQ c~matnr
                        AND c~atnam EQ 'PD_CA_COLOR_BASE'      " 색상
                        LEFT JOIN zgtsd_i_materialcharacteristic AS d
                        ON  b~matnr EQ d~matnr
                        AND d~atnam EQ 'PD_CA_COLOR_STRIPE'    " Str
                        LEFT JOIN zgtsd_i_materialcharacteristic AS e
                        ON  b~matnr EQ e~matnr
                        AND e~atnam EQ 'PD_CA_COLOR_STRIPE_NO' " 띄줄
                        LEFT JOIN zgtsd_i_materialcharacteristic AS f
                        ON  b~matnr EQ f~matnr
                        AND f~atnam EQ 'PD_CA_FIBER_NO_1ST'    " F량
    INTO CORRESPONDING FIELDS OF TABLE @gt_char.

  IF gt_char[] IS NOT INITIAL.
    SORT: gt_char BY vbeln posnr matnr.
  ENDIF.

**
  FREE: lt_list.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form set_characteristic_value_v2
*&---------------------------------------------------------------------*
FORM set_characteristic_value_v2  USING    ps_list  LIKE gt_list.

**
  CHECK: ps_list IS NOT INITIAL.

  DATA(ls_char) = VALUE #( gt_char[ vbeln = ps_list-vgbel
                                    posnr = ps_list-vgpos ]
                           OPTIONAL ).

  IF ls_char IS NOT INITIAL.
    ps_list-pack_gubun = ls_char-pack_gubun.   " 포장구분 ( PD_GA_PACKAGE_METHOD )
    ps_list-color      = ls_char-color.        " 색상 ( PD_CA_COLOR_BASE )
    ps_list-str        = ls_char-str.          " Str ( PD_CA_COLOR_STRIPE )
    ps_list-str_no     = ls_char-str_no.       " 띄줄 ( PD_CA_COLOR_STRIPE_NO )
    ps_list-fiber      = ls_char-fiber.        " F량 ( PD_CA_FIBER_NO_1ST )
    ps_list-length     = ls_char-length.       " 조장 ( SAP_LENGTH_VKRME )
    ps_list-factor     = ls_char-factor.       " 조장수 ( SAP_MILLCA_FACTOR )

    "조장수 = 납품수량 / 조장
    IF ps_list-length NE 0.
      ps_list-factor = ps_list-lfimg / ps_list-length.
    ENDIF.

  ENDIF.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form get_stock_data_for_os_zgubun
*&---------------------------------------------------------------------*
FORM get_stock_data_for_os_zgubun .

  DATA: lv_mode   TYPE zgtemode_stock,
        ls_login  TYPE zsds_log_0000_go,
        ls_return TYPE zsds_log_0001_go,
        lt_search	TYPE TABLE OF zgtsdsif0096.

**
  _clear: gt_estock.

  CHECK: gt_list[] IS NOT INITIAL.

  DATA(lt_list) = gt_list[].
  SORT: lt_list BY vgbel vgpos.
  DELETE ADJACENT DUPLICATES FROM lt_list COMPARING vgbel vgpos.

  SELECT a~vgbel AS vbeln, a~vgpos AS posnr,
         a~matnr, a~werks, a~lgort,
         b~fixmg, b~mvgr3
    FROM @lt_list AS a  INNER JOIN vbap AS b
                        ON  a~vgbel EQ b~vbeln
                        AND a~vgpos EQ b~posnr
                        AND b~fixmg > 0
*                        AND b~mvgr3 EQ @space
    INTO TABLE @DATA(lt_so).

*
  CHECK: lt_so[] IS NOT INITIAL.

  CLEAR: lv_mode,
         ls_login, ls_return.
  _clear: lt_search,
          gt_lstock, gt_lstock_d,
          gt_estock, gt_estock_d.

*  LINK재고조회 + 판매오더재고조회
  lv_mode        = 'Z'.    " 'C'.
  ls_login-ename = sy-uname.

  lt_search[] = VALUE #( BASE lt_search[]
                         FOR ls_so  IN lt_so
                         ( matnr = ls_so-matnr
                           werks = ls_so-werks
                           lgort = ls_so-lgort
                           vbeln = ls_so-vbeln
                           posnr = ls_so-posnr )
                        ).

  CALL FUNCTION 'ZSD_365_0050_0040_GO'
    EXPORTING
      is_d365_login    = ls_login
      i_mode           = lv_mode
    IMPORTING
      es_return        = ls_return
    TABLES
      it_search        = lt_search
      et_lstock_item   = gt_lstock
      et_lstock_detail = gt_lstock_d
      et_estock_item   = gt_estock
      et_estock_detail = gt_estock_d.

  IF ls_return-mtype NE 'S' .
    _clear: gt_lstock, gt_lstock_d,
            gt_estock, gt_estock_d.
  ENDIF.

**
  FREE: lt_list, lt_so.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form set_gubun_from_stock_v2
*&---------------------------------------------------------------------*
FORM set_gubun_from_stock_v2  USING    pi_vbeln
                                       pi_posnr
                                       pi_matnr
                                       pi_werks
                                       pi_lgort
                                       pi_factor
                              CHANGING pe_zgubun.

**
  CHECK: gt_estock[] IS NOT INITIAL.

  DATA(lv_estock) = VALUE #( gt_estock[ vbeln = pi_vbeln
                                        posnr = pi_posnr ]-estock
                             OPTIONAL ).

  IF     lv_estock >= pi_factor.
    pe_zgubun = '완'.
    pe_zgubun = |{ pe_zgubun }| && | { pi_factor }|.

  ELSEIF lv_estock < pi_factor.

    DATA(lv_cnt) = pi_factor - lv_estock.

    pe_zgubun = '미'.
    pe_zgubun = |{ pe_zgubun }| && | { lv_cnt }|.

  ENDIF.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form set_gubun_from_lstock_link
*&---------------------------------------------------------------------*
FORM set_gubun_from_lstock_link  USING    pi_vbeln
                                          pi_posnr
                                          pi_matnr
                                          pi_werks
                                          pi_lgort
                                          pi_factor
                                 CHANGING pe_zgubun.

  DATA: lv_stock TYPE zgtewecnt.

**
  CHECK: gt_estock[] IS NOT INITIAL OR
         gt_lstock[] IS NOT INITIAL.

* 판매오더 Stock 조장수
  DATA(lv_estock) = VALUE #( gt_estock[ vbeln = pi_vbeln
                                        posnr = pi_posnr ]-estock
                             OPTIONAL ).
* Link 재고 조장수
  DATA(lv_lstock) = VALUE #( gt_lstock[ vbeln = pi_vbeln
                                        posnr = pi_posnr ]-lstock
                             OPTIONAL ).

* 1) 재고 조장수 계산 : 판매오더 STOCK 조장수 + LINK 재고 조장수
  CLEAR: lv_stock.
  lv_stock = lv_estock + lv_lstock.

  IF     lv_stock >= pi_factor.
* 2) 재고 조장수량 >= 조장수 이면 (재고가 많은 경우)

    IF     lv_estock >= pi_factor.
*   2-1) 판매오더 STOCK 조장수 >= 조장수 (판매오더 STOCK 만으로 충분한 경우)
      pe_zgubun = '완'.
      pe_zgubun = |{ pe_zgubun }| && | { pi_factor }|.

    ELSEIF lv_estock < pi_factor.
*   2-2) 판매오더 STOCK 조장수 < 조장수
*        (판매오더 STOCK 으로는 재고가 부족해 LINK 재고를 추가로 표시해 줘야 함)
      pe_zgubun = '완'.
      pe_zgubun = |{ pe_zgubun }| && |{ lv_estock }|.

      DATA(lv_lstock_c) = pi_factor - lv_estock.
      pe_zgubun = |{ pe_zgubun }| && |{ ',미' }| && |{ lv_lstock_c }|.

    ENDIF.

  ELSEIF lv_stock <  pi_factor.
* 3) 재고 조장수량 < 조장수 이면 (재고가 부족한 경우)

    DATA(lv_stock_c) = pi_factor - lv_stock.
    pe_zgubun = '미'.
    pe_zgubun = |{ pe_zgubun }| && |{ lv_stock_c }|.

    IF     lv_lstock IS INITIAL OR lv_lstock = 0.
*   3-1) 판매오더 STOCK 만 존재하는 경우
      pe_zgubun = |{ pe_zgubun }| && |{ ',완' }| && |{ pi_factor }|.

    ELSEIF lv_estock IS INITIAL OR lv_estock = 0.
*   3-2) LINK재고만 존재하는 경우
      pe_zgubun = |{ pe_zgubun }| && |{ ',미' }| && |{ pi_factor }|.

    ELSEIF ( lv_estock IS NOT INITIAL AND lv_estock > 0 ) AND
           ( lv_lstock IS NOT INITIAL AND lv_lstock > 0 ).
*   3-3) 판매오더 STOCK 과 LINK재고 둘다 존재하는 경우
      pe_zgubun = |{ pe_zgubun }| && |{ ',완' }| && |{ pi_factor }|.
      pe_zgubun = |{ pe_zgubun }| && |{ ',미' }| && |{ pi_factor }|.

    ENDIF.

  ENDIF.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form check_delivery_from_tknum
*&---------------------------------------------------------------------*
FORM check_delivery_from_tknum  USING    pi_vbeln
                                         pi_tknum
                                CHANGING pe_chk.

**
  CHECK: pi_vbeln IS NOT INITIAL AND
         pi_tknum IS NOT INITIAL.

  SELECT SINGLE vbeln
    FROM vttp  WHERE tknum EQ @pi_tknum
    INTO @DATA(lv_vbeln_tp).

  SELECT SINGLE vbeln
    FROM zlet0005 AS k  INNER JOIN zlet0006 AS p
                        ON k~iv_no = p~iv_no
   WHERE k~iv_print_yn  EQ 'X'    "거래명세서 발행여부
     AND k~iv_cancel_yn EQ ' '    "거래명세서 취소여부
     AND k~iv_type      NE 'L01'  "수출컨테이너 재고이전 제외
     AND p~vbeln        EQ @pi_vbeln
    INTO @DATA(lv_vbeln_iv).

  IF lv_vbeln_tp EQ lv_vbeln_iv.
    pe_chk = 'X'.
  ENDIF.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form get_data_multi_tknum_others
*&---------------------------------------------------------------------*
FORM get_data_multi_tknum_others .

  DATA: lr_tknum  LIKE RANGE OF vttk-tknum.        " 선적번호

**
  CHECK: s_tknum[] IS NOT INITIAL.

  _clear: lr_tknum.
*   납품문서 하나에 여러개의 선적문서가 있는 경우 Check.
  SELECT tknum, vbeln
    FROM vttp  WHERE tknum  IN @s_tknum
    INTO TABLE @DATA(lt_multi).

  IF lt_multi[] IS NOT INITIAL.

    IF gt_data[] IS INITIAL.
      SORT: lt_multi BY vbeln.
      DELETE ADJACENT DUPLICATES FROM lt_multi COMPARING vbeln.
    ENDIF.

    LOOP AT lt_multi  INTO DATA(ls_multi).

      DATA(lv_index) = sy-tabix.

      DATA(ls_data) = VALUE #( gt_data[ vbeln = ls_multi-vbeln ]
                               OPTIONAL ).
      IF ls_data IS NOT INITIAL.
        DELETE lt_multi  INDEX lv_index.
      ELSE.
        lr_tknum = VALUE #( BASE lr_tknum
                            ( sign = 'I' option = 'EQ'  low = ls_multi-tknum ) ).
      ENDIF.

    ENDLOOP.

  ENDIF.

  CHECK: lr_tknum[] IS NOT INITIAL.

  SELECT a~tknum, a~exti2, a~exti1, a~tpbez, a~shtyp, a~tdlnr, a~sdabw,
         c~kunnr, c~route, c~lfart, c~vsart, c~wadat, c~wadat_ist,
         c~vbtyp, c~vstel, c~kunag, c~wbstk, c~lifsk,
         d~vbeln, d~posnr, d~werks, d~matnr, d~arktx, d~lfimg, d~vrkme,
         d~charg, d~meins, d~vgbel, d~vgpos, d~umvkz, d~umvkn, d~lgort,
         d~vkbur, d~vkgrp, d~vtweg, d~spart, d~mtart, d~ntgew, d~gewei,
         f~iv_no, f~iv_date
    APPENDING CORRESPONDING FIELDS OF TABLE @gt_data
    FROM vttk AS a  INNER JOIN vttp AS b
                    ON  a~tknum = b~tknum
                    INNER JOIN likp AS c
                    ON  b~vbeln = c~vbeln
                    INNER JOIN lips AS d
                    ON  c~vbeln = d~vbeln
                    INNER JOIN zlet0006 AS e
                    ON  d~vbeln = e~vbeln
                    AND d~posnr = e~posnr
*                    AND a~tknum = e~tknum
                    INNER JOIN zlet0005 AS f
                    ON  e~iv_no = f~iv_no
     WHERE a~tknum        IN @lr_tknum
       AND a~shtyp        NOT IN ('Z002', 'Z009', 'Z103')          ", 'Z007')
       AND b~vbeln        IN @s_vl
       AND c~lifsk        NE 'G3'
       AND c~lfart        IN @gr_lfart
       AND c~vstel        IN @s_vstel
       AND c~vstel        IN @gr_vstel
       AND c~wadat        IN @s_wadat
       AND c~wadat_ist    IN @s_wdtist
       AND c~kunag        IN @s_kunag
*       AND c~kunnr        IN @s_kunnr
       AND c~ernam        IN @s_ernam
       AND c~route        IN @s_route
       AND c~route        IN @gr_route
       AND d~vgbel        IN @s_va
       AND d~vkbur        IN @s_vkbur
       AND d~vkgrp        IN @s_vkgrp
       AND d~vtweg        IN @s_vtweg
       AND d~uecha        EQ '000000'
       AND f~iv_print_yn  EQ 'X'   "거래명세서 발행여부
       AND f~iv_cancel_yn EQ ' '   "거래명세서 취소여부
       AND f~iv_date      IN @s_date
       AND f~iv_no        IN @s_iv_no
       AND f~bzarea       EQ @p_bzarea
       AND d~lgort        IN @gr_lgort
       AND c~vsart        IN @s_vsart.

* 적송대상(LIFSK = 'G3') Data Get.
  SELECT a~tknum, a~exti2, a~exti1, a~tpbez, a~shtyp, a~tdlnr, a~sdabw,
         c~lifsk,
         d~kunnr, d~route, d~lfart, d~vsart, d~wadat, d~wadat_ist,
         d~vbtyp, d~vstel, d~kunag, d~wbstk, " d~lifsk,
         e~vbeln, e~posnr, e~werks, e~matnr, e~arktx, e~lfimg, e~vrkme,
         e~charg, e~meins, e~vgbel, e~vgpos, e~umvkz, e~umvkn, e~lgort,
         e~vkbur, e~vkgrp, e~vtweg, e~spart, e~mtart, e~ntgew, e~gewei,
         g~iv_no, g~iv_date
    APPENDING CORRESPONDING FIELDS OF TABLE @gt_data
    FROM vttk AS a  INNER JOIN vttp AS b
                    ON  a~tknum = b~tknum
                    INNER JOIN likp AS c
                    ON  b~vbeln = c~vbeln
                    INNER JOIN zgtsdt9110 AS d
                    ON  c~vbeln = d~vbeln
                    INNER JOIN zgtsdt9120 AS e
                    ON  c~vbeln = e~vbeln
                    INNER JOIN zlet0006 AS f
                    ON  e~vbeln = f~vbeln
                    AND e~posnr = f~posnr
*                    AND a~tknum = f~tknum
                    INNER JOIN zlet0005 AS g
                    ON  f~iv_no = g~iv_no
     WHERE a~tknum        IN @lr_tknum
       AND a~shtyp        NOT IN ('Z002', 'Z009', 'Z103')          ", 'Z007')
       AND b~vbeln        IN @s_vl
       AND c~lifsk        EQ 'G3'
       AND d~lfart        IN @gr_lfart
       AND d~vstel        IN @s_vstel
       AND d~vstel        IN @gr_vstel
       AND d~wadat        IN @s_wadat
       AND d~wadat_ist    IN @s_wdtist
       AND d~kunag        IN @s_kunag
*       AND d~kunnr        IN @s_kunnr
       AND d~ernam        IN @s_ernam
       AND d~route        IN @s_route
       AND d~route        IN @gr_route
       AND e~vgbel        IN @s_va
       AND e~vkbur        IN @s_vkbur
       AND e~vkgrp        IN @s_vkgrp
       AND e~vtweg        IN @s_vtweg
       AND e~uecha        EQ '000000'
       AND g~iv_print_yn  EQ 'X'   "거래명세서 발행여부
       AND g~iv_cancel_yn EQ ' '   "거래명세서 취소여부
       AND g~iv_date      IN @s_date
       AND g~iv_no        IN @s_iv_no
       AND g~bzarea       EQ @p_bzarea
       AND e~lgort        IN @gr_lgort
       AND d~vsart        IN @s_vsart.

**
  FREE: lt_multi.

ENDFORM.
