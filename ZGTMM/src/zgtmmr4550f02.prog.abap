*&---------------------------------------------------------------------*
*&  Include           MZLE0002F02                                      *
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  DATA_MODIFY
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM data_modify.
*
  i_cursor_line = tc01-current_line + i_cursor_line - 1.
  READ TABLE gt_out INTO gt_out_t INDEX i_cursor_line.
*
  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      input  = gt_out_t-asset_no
    IMPORTING
      output = gt_out_t-asset_no.

* 자산코드 선택시 View table 존재유/뮤 Check
* 입력한 플랜트로 회사코드 추출
*  DATA : LV_BUKRS LIKE VBRK-BUKRS.
*  DATA : LV_ACCNT LIKE USR02-ACCNT.
*
*  SELECT SINGLE ACCNT INTO LV_ACCNT FROM USR02
*  WHERE  BNAME = SY-UNAME.
*  IF LV_ACCNT IS INITIAL AND WA-WERKS IS NOT INITIAL.
*    SELECT SINGLE BUKRS INTO LV_BUKRS
*    FROM   T001K
*    WHERE  BWKEY = WA-WERKS.
*  ELSE.
*    LV_BUKRS = LV_ACCNT.
*  ENDIF.
  DATA : ls_anla    LIKE anla OCCURS 0 WITH HEADER LINE.

  SELECT SINGLE *
    FROM anla
    INTO CORRESPONDING FIELDS OF ls_anla
   WHERE bukrs = gv_bukrs
     AND anln1 = gt_out_t-asset_no
     AND spras = sy-langu.

*{ 기능개선 251794 - 변경
  CLEAR : v_anlsum_1.

  SELECT *
    FROM v_anlsum_1
      UP TO 1 ROWS
   WHERE bukrs = gv_bukrs
     AND anln1 = gt_out_t-asset_no
     AND afabe = '01'
   ORDER BY gjahr DESCENDING.

  ENDSELECT.

  CHECK sy-subrc = 0.

*  SELECT SINGLE *
*    FROM V_ANLSUM_1
*   WHERE BUKRS = GV_BUKRS
*     AND ANLN1 = GT_OUT_T-ASSET_NO
*     AND AFABE = '01'
*} 기능개선 251794 - 변경

*/ EDIT FROM BY G.T.JUNG 2016.11.16
*        GDLGRP       LIKE   ANLA-GDLGRP,   " 대여 업체
*        GDLGRP_TXT LIKE T087S-GDLGRP_TXT,  " 평가그룹 8곳에 대한 텍스트

  DATA : ls_t087s LIKE t087s . "  OCCURS 0.

  SELECT SINGLE *
    FROM t087s
    INTO ls_t087s
   WHERE spras EQ sy-langu
     AND gdlgrp  EQ  gt_out_t-gdlgrp .
*/ EDIT END  BY G.T.JUNG 2016.11.16

  LOOP AT gt_out WHERE asset_no = gt_out_t-asset_no.
    IF gt_out-asset_nm = ' '.
      gt_out-asset_nm = ls_anla-txt50.
    ENDIF.
    IF gt_out-asset_spec = ' '.
      gt_out-asset_spec  = ls_anla-txa50.
    ENDIF.
    IF gt_out-menge = 0.
      gt_out-menge = ls_anla-menge.
*-{기능개선 48112 - 수량 확인 조건 추가
    ELSEIF gt_out-menge < 0.
      MESSAGE s000 DISPLAY LIKE 'E'
      WITH '마이너스 값은 적용되지 않습니다.'.
    ENDIF.
*-}기능개선 48112_2014.10.29
*-{기능개선 48112 - KRW 단위수정 형민
    IF gt_out-asset_amt = 0.

*{ CHM2008-00308-s
*      GT_OUT-ASSET_AMT = V_ANLSUM_1-KANSW - V_ANLSUM_1-KNAFA -
*                         V_ANLSUM_1-NAFAG.
      gt_out-asset_amt = v_anlsum_1-kansw + v_anlsum_1-knafa +
                         v_anlsum_1-nafag.
*} CHM2008-00308-e

    ENDIF.
    gt_out-asset_cur = 'KRW'.
*-}기능개선 48112_2014.10.29
    IF gt_out-meins = ' '.
      gt_out-meins = ls_anla-meins.
    ENDIF.
    IF gt_out-werks = ' '.
      gt_out-werks = v_anlsum_1-werks.
    ENDIF.
    gt_out-flag = 'X'.

*/  EDIT FROM BY G.T.JUNG AT 2016.11.16
    IF gt_out-gdlgrp_txt = ' '.
      gt_out-gdlgrp_txt = ls_t087s-gdlgrp_txt.
    ENDIF.
*/ EDIT END  BY G.T.JUNG AT 2016.11.16

    MODIFY gt_out. CLEAR gt_out.
  ENDLOOP.

ENDFORM.                    " DATA_MODIFY
*&---------------------------------------------------------------------*
*&      Form  DATA_SAVE
*&---------------------------------------------------------------------*
FORM data_save.
  DATA: lv_return.

* 저장전 입력값 Check 한다.
  PERFORM before_save_check.
* 저장여부 POP UP
  PERFORM pop_up_confirm(zler0004) USING '< 저장여부확인 >'
                                         '저장하시겠습니까?'
                      CHANGING lv_return.
  CHECK lv_return = 'J'.
*
  IF ts_flag1 = ' '.
    PERFORM invoice_no_create(zler0015) USING 'ZLE001' '06'
                            CHANGING wa-iv_no.
  ENDIF.
  IF wa-iv_no <> ' '.
*    요청변경시 기존 저장된 Data Delete
    DELETE FROM zlet0005 WHERE iv_no = wa-iv_no.
    COMMIT WORK.
    DELETE FROM zlet0006 WHERE iv_no = wa-iv_no.
    COMMIT WORK.
*    Header 저장
    PERFORM header_insert.
*    Detail 저장
    PERFORM detail_insert.
*-{기능개선 48116 - 추가
    IF gv_check = ''.
      DELETE FROM zlet0003 WHERE iv_no = wa-iv_no.
      COMMIT WORK.
      PERFORM approval_insert.
      PERFORM call_simple_approval USING wa-iv_no.
    ENDIF.

*-}기능개선 48116_2014.10.21
    MESSAGE i005(zle1) WITH '통문이 생성되었습니다.'.
    LEAVE TO SCREEN 0.
  ELSE.
    MESSAGE i005(zle1) WITH '통문번호 생성실패'.
    LEAVE TO SCREEN 0.
  ENDIF.

ENDFORM.                    " DATA_SAVE
*&---------------------------------------------------------------------*
*&      Form  HEADER_INSERT
*&---------------------------------------------------------------------*
FORM header_insert .
  DATA: lv_werks LIKE marc-werks.

  CLEAR lv_werks.
  LOOP AT gt_out.
    IF gt_out-werks <> ' '.
      lv_werks = gt_out-werks.
      EXIT.
    ENDIF.
  ENDLOOP.
  CLEAR: ZGTMMT4500.

  MOVE-CORRESPONDING wa  TO ZGTMMT4500.
* 070109 Bon-Chan Koo
* 통문유형 기타에 대하여
* 플랜트/사업단위 1600 ~ 1609, 1781~1789인 경우
* 통문 유형 Cxx 는 플랜트 Exx는 사업단위 옆에
* 반출 사업장 5000/5100 선택 필드 활성화(디폴트 5000)
* 내역 저장시 통문 DB에 마스터의 사업장이 아닌 반출사업장 입력
  MOVE-CORRESPONDING wa  TO ZGTMMT4500.

  IF ( wa-werks >= 1600 AND wa-werks <= 1609 ) OR
     ( wa-werks >= 1781 AND wa-werks <= 1789 ) OR
     ( wa-werks >= 3600 AND wa-werks <= 3609 ) OR
     ( wa-werks >= 3781 AND wa-werks <= 3789 ) .
    IF wa-bzarea = '5000' OR wa-bzarea ='5100' OR
        wa-bzarea = '5300'." SRM2209-05218 26.09.2022 12:48:23
      .
      ZGTMMT4500-bzarea = wa-bzarea.
    ELSE.
      SELECT SINGLE bzarea INTO ZGTMMT4500-bzarea
      FROM zlet0034
      WHERE werks = wa-werks.
    ENDIF.
  ELSE.
* 070109 수정완료

    SELECT SINGLE bzarea INTO ZGTMMT4500-bzarea
      FROM zlet0034
     WHERE werks = wa-werks.
  ENDIF.

  IF gv_addrs = ''.
    ZGTMMT4500-addrs = ''.
  ENDIF.
*  ZLET0005-WERKS          = LV_WERKS.
  ZGTMMT4500-create_user_id = sy-uname.
*  zlet0005-create_date    = sy-datum.
  ZGTMMT4500-create_time    = sy-uzeit.
  IF wa-change IS INITIAL.
    ZGTMMT4500-kunnr1         = wa-kunnr1.
    ZGTMMT4500-kunnr          = wa-kunnr.
  ELSE.
    ZGTMMT4500-zmanual        = 'X'.
    ZGTMMT4500-kunnr2         = wa-kunnr1_t.
    ZGTMMT4500-addrs          = wa-addrs.
  ENDIF.
  ZGTMMT4500-reqst          = 'X'.
  ZGTMMT4500-etc_nm         = wa-text1.
*  ZLET0005-DRIVER_TELNO   = WA-DRPHO.
  INSERT ZGTMMT4500.  CLEAR ZGTMMT4500.
  COMMIT WORK.

ENDFORM.                    " HEADER_INSERT
*&---------------------------------------------------------------------*
*&      Form  DETAIL_INSERT
*&---------------------------------------------------------------------*
FORM detail_insert .

  DATA: seq   TYPE i.
  CLEAR: seq.
  LOOP AT gt_out.
    MOVE-CORRESPONDING gt_out TO ZGTMMT4501.
    seq = seq + 1.
    ZGTMMT4501-iv_seq     = seq.
    ZGTMMT4501-iv_no      = wa-iv_no.
    ZGTMMT4501-lfimg      = gt_out-menge.
    ZGTMMT4501-maktx      = gt_out-asset_nm.
    ZGTMMT4501-dmbtr      = gt_out-asset_amt.
    ZGTMMT4501-mtr_unit   = gt_out-meins.


    IF wa-return_yn = ' '.
      CLEAR: ZGTMMT4501-return_due_date.
    ENDIF.

    INSERT ZGTMMT4501.    CLEAR ZGTMMT4501.
    COMMIT WORK.
  ENDLOOP.

ENDFORM.                    " DETAIL_INSERT
*&---------------------------------------------------------------------*
*&      Form  BEFORE_SAVE_CHECK
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM before_save_check .

  CLEAR lv_flag.

  IF ts_flag1 = ' '.
    IF NOT wa-iv_no IS INITIAL.
      MESSAGE i000 WITH '재설정하세요!'.
      LEAVE SCREEN .
    ENDIF.
  ENDIF.

  IF wa-bukrs IS INITIAL.
    MESSAGE s000 DISPLAY LIKE 'E' WITH '회사코드를 입력하십시오'.
    g_cursor_field = 'WA-BUKRS'.
    LEAVE SCREEN.
  ENDIF.

  IF wa-werks IS INITIAL.
    MESSAGE s000 DISPLAY LIKE 'E' WITH '플랜트를 입력하십시오'.
    g_cursor_field = 'WA-WERKS'.
    LEAVE SCREEN.
  ENDIF.

  IF wa-bzarea IS INITIAL.
    MESSAGE s000 DISPLAY LIKE 'E' WITH '사업장을 입력하십시오'.
    g_cursor_field = 'WA-BZAREA'.
    LEAVE SCREEN.
  ENDIF.

  IF wa-pernr IS INITIAL.
    MESSAGE s000 DISPLAY LIKE 'E' WITH '사원번호를 입력하십시오'.
    g_cursor_field = 'WA-PERNR'.
    LEAVE SCREEN.
  ENDIF.

  IF gv_bukrs = '1000' AND wa-text1 IS INITIAL.
    MESSAGE s000 DISPLAY LIKE 'E' WITH '사유를 입력하십시오'.
    g_cursor_field = 'WA-TEXT1'.
    LEAVE SCREEN.
  ENDIF.

  IF gv_bukrs = '3000'.
    IF wa-iv_type = 'C05' OR wa-iv_type = 'C06'.
      IF wa-zpdf IS INITIAL.
        MESSAGE s000 DISPLAY LIKE 'E'
                     WITH '첨부파일을 꼭 첨부해 주세요.'.
        LEAVE SCREEN.
      ENDIF.
    ENDIF.
  ENDIF.

  IF wa-change IS INITIAL.
    IF wa-kunnr IS INITIAL AND wa-kunnr1 IS INITIAL.
      MESSAGE s000 DISPLAY LIKE 'E'
                   WITH '구매처 또는 납품처를 입력하십시오'.
      g_cursor_field = 'WA-KUNNR'.
      LEAVE SCREEN.
    ENDIF.
  ELSE.
    IF wa-kunnr1_t IS INITIAL.
      MESSAGE s000 DISPLAY LIKE 'E'
                   WITH '구매처 또는 납품처를 입력하십시오'.
      g_cursor_field = 'WA-KUNNR1_T'.
      LEAVE SCREEN.
    ENDIF.
  ENDIF.

  IF gv_addrs = 'X' AND wa-addrs IS INITIAL.
    MESSAGE s000 DISPLAY LIKE 'E' WITH '주소를 입력하십시오'.
    g_cursor_field = 'WA-ADDRS'.
    LEAVE SCREEN.
  ENDIF.

*
  DESCRIBE TABLE gt_out LINES sy-tfill.
  IF sy-tfill = 0.
    MESSAGE s000 DISPLAY LIKE 'E' WITH '자산정보를 입력하십시오'.
    g_cursor_field = 'GT_OUT-ASSET_NO'.
    i_cursor_line  = 1.
    LEAVE SCREEN.
  ENDIF.
*
  LOOP AT gt_out.
    IF gt_out-asset_no IS INITIAL.
      MESSAGE s000 DISPLAY LIKE 'E' WITH '자산코드를 입력하십시오'.
      g_cursor_field = 'GT_OUT-ASSET_NO'.
      lv_flag = 'X'.
      EXIT.
    ENDIF.
    IF gt_out-asset_nm IS INITIAL.
      MESSAGE s000 DISPLAY LIKE 'E' WITH '자산명칭을 입력하십시오'.
      g_cursor_field = 'GT_OUT-ASSET_NM'.
      lv_flag = 'X'.
      EXIT.
    ENDIF.
    IF gt_out-asset_spec IS INITIAL.
      MESSAGE s000 DISPLAY LIKE 'E' WITH '규격/용도을 입력하십시오'.
      g_cursor_field = 'GT_OUT-ASSET_SPEC'.
      lv_flag = 'X'.
      EXIT.
    ENDIF.
    IF gt_out-menge IS INITIAL.
      MESSAGE s000 DISPLAY LIKE 'E' WITH '수량을 입력하십시오'.
      g_cursor_field = 'GT_OUT-MENGE'.
      lv_flag = 'X'.
      EXIT.
*-{기능개선 48112 - 수량 확인 조건 추가
    ELSEIF gt_out-menge <= 0.
      MESSAGE s000 DISPLAY LIKE 'E' WITH '수량은 자연수를 입력하십시오'.
      g_cursor_field = 'GT_OUT-MENGE'.
      lv_flag = 'X'.
      EXIT.
    ENDIF.
*-}기능개선 48112_2014.10.29
    IF gt_out-meins IS INITIAL.
      MESSAGE s000 DISPLAY LIKE 'E' WITH '단위를 입력하십시오'.
      g_cursor_field = 'GT_OUT-MEINS'.
      lv_flag = 'X'.
      EXIT.
    ENDIF.

    IF wa-return_yn = 'X'.
      IF gt_out-return_due_date IS INITIAL.
        MESSAGE s000 DISPLAY LIKE 'E' WITH '반입예정일을 입력하십시오'.
        g_cursor_field = 'GT_OUT-RETURN_DUE_DATE'.
        lv_flag = 'X'.
        EXIT.
      ENDIF.
      IF ts_flag1 = ' ' AND gt_out-return_due_date < sy-datum.
        MESSAGE s000 DISPLAY LIKE 'E'
                     WITH '반입예정일이 지났음: 점검하십시오'.
        g_cursor_field = 'GT_OUT-RETURN_DUE_DATE'.
        lv_flag = 'X'.
        EXIT.
      ENDIF.
    ENDIF.

*{ 기능개선 251794 - 추가
    IF wa-bukrs = '3000' AND gt_out-reasn IS INITIAL.
      MESSAGE s000 DISPLAY LIKE 'E'
         WITH '사유를 입력하십시오.'.
      g_cursor_field = 'GT_OUT-REASN'.
      lv_flag = 'X'.
      EXIT.
    ENDIF.
*} 기능개선 251794 - 추가
  ENDLOOP.

  IF lv_flag = 'X'.
    i_cursor_line = sy-tabix - tc01-top_line + 1.

    IF i_cursor_line < 1.
      i_cursor_line  = 1.
    ENDIF.

    LEAVE SCREEN .
  ENDIF.

  IF gv_check = ''.
    IF wa_0110-app_id1 IS INITIAL.
      MESSAGE s000 DISPLAY LIKE 'E'
         WITH '(결재라인)합의자를 입력하십시오'.
      LEAVE SCREEN.
    ENDIF.
    IF wa_0110-app_id2 IS INITIAL.
      MESSAGE s000 DISPLAY LIKE 'E'
         WITH '(결재라인)승인자를 입력하십시오'.
      LEAVE SCREEN.
    ENDIF.
  ENDIF.

ENDFORM.                    " BEFORE_SAVE_CHECK
*&---------------------------------------------------------------------*
*&      Form  get_f4_bzarea
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_WA_BZAREA  text
*----------------------------------------------------------------------*
FORM get_f4_bzarea  USING p_type.

  DATA: BEGIN OF pov_type OCCURS 0,
          bzarea   LIKE zlet0033-bzarea,
          bzarea_t LIKE zlet0033-bzarea_t,
        END OF pov_type.

  CLEAR: pov_type[], pov_type.
  SELECT *
  INTO   CORRESPONDING FIELDS OF TABLE pov_type
  FROM   zlet0033.

  SORT pov_type.
  DELETE ADJACENT DUPLICATES FROM pov_type.

  fieldtab-tabname    = 'ZLET0033'.
  fieldtab-fieldname  = 'BZAREA'.
  fieldtab-selectflag = 'X'.
  APPEND fieldtab.

  fieldtab-tabname    = 'ZLET0034'.
  fieldtab-fieldname  = 'BZAREA_T'.
  fieldtab-selectflag = ' '.
  APPEND fieldtab.

  LOOP AT pov_type.
    valuetab-value = pov_type-bzarea.
    APPEND valuetab.
    valuetab-value = pov_type-bzarea_t.
    APPEND valuetab.
  ENDLOOP.

  CALL FUNCTION 'HELP_VALUES_GET_WITH_TABLE_EXT'
    EXPORTING
      display       = ' '
*     fieldname     = 'NAME1'
    IMPORTING
      index         = j
    TABLES
      fields        = fieldtab
      select_values = i_help_vtab
      valuetab      = valuetab.

  IF j > 0.
    READ TABLE pov_type INDEX j.
    p_type = pov_type-bzarea.
  ENDIF.
  REFRESH : fieldtab, valuetab, pov_type.
  CLEAR   : j,fieldtab, valuetab, pov_type.

ENDFORM.                    " get_f4_bzarea
*&---------------------------------------------------------------------*
*&      Form  GET_BUKRS_DESC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_WA_BUKRS  text
*      -->P_WA_BUTXT  text
*----------------------------------------------------------------------*
FORM get_bukrs_desc  USING    pv_bukrs
                              pv_butxt.

  CLEAR : pv_butxt.

  CHECK pv_bukrs IS NOT INITIAL.

  SELECT SINGLE butxt
    INTO pv_butxt
    FROM t001
   WHERE bukrs = pv_bukrs.

ENDFORM.                    " GET_BUKRS_DESC
*&---------------------------------------------------------------------*
*&      Form  GET_WERKS_DESC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_WA_BUKRS  text
*      -->P_WA_WERKS  text
*      -->P_WA_WERKS_T  text
*----------------------------------------------------------------------*
FORM get_werks_desc  USING   pv_werks
                              pv_werks_t.

  CLEAR : pv_werks_t.

  CHECK pv_werks IS NOT INITIAL.

  SELECT SINGLE name1
    INTO pv_werks_t
    FROM t001w
   WHERE werks = pv_werks.

ENDFORM.                    " GET_WERKS_DESC
*&---------------------------------------------------------------------*
*&      Form  F4HELP_BUKRS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_WA_BUKRS  text
*      -->P_WA_BUTXT  text
*----------------------------------------------------------------------*
FORM f4help_bukrs  USING    pv_bukrs
                            pv_butxt.

  CLEAR   : selectfield, select_value, ld_tabix, gt_code,
            it_fields, scr_fields, feld_table.
  REFRESH : it_fields, scr_fields, feld_table, gt_code.

  SELECT bukrs butxt
    INTO CORRESPONDING FIELDS OF TABLE gt_code
    FROM t001
   WHERE bukrs IN ('1000', '2000', '3000', '5000').

  it_fields-tabname    = 'T001'.
  it_fields-fieldname  = 'BUKRS'.
  it_fields-selectflag = 'X'.
  APPEND it_fields.

  it_fields-tabname    = 'T001'.
  it_fields-fieldname  = 'BUTXT'.
  it_fields-selectflag = ' '.
  APPEND it_fields.

  CALL FUNCTION 'HELP_VALUES_GET_NO_DD_NAME'
    EXPORTING
      selectfield                  = selectfield
    IMPORTING
      ind                          = ld_tabix
      select_value                 = select_value
    TABLES
      fields                       = it_fields
      full_table                   = gt_code
    EXCEPTIONS
      full_table_empty             = 1
      no_tablestructure_given      = 2
      no_tablefields_in_dictionary = 3
      more_then_one_selectfield    = 4
      no_selectfield               = 5
      OTHERS                       = 6.

  CHECK NOT ld_tabix IS INITIAL.
  READ TABLE gt_code INDEX ld_tabix.
  pv_bukrs = gt_code-bukrs.
  pv_butxt = gt_code-butxt.

ENDFORM.                    " F4HELP_BUKRS
*&---------------------------------------------------------------------*
*&      Form  F4HELP_WERKS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_WA_WERKS  text
*----------------------------------------------------------------------*
FORM f4help_werks  USING   pv_bukrs
                            pv_werks.

  CLEAR   : selectfield, select_value, ld_tabix, gt_plant,
            it_fields, scr_fields, feld_table.
  REFRESH : it_fields, scr_fields, feld_table, gt_plant.

  MOVE : 'WA-BUKRS' TO feld_table-fieldname.
  APPEND feld_table.

  CALL FUNCTION 'DYNP_VALUES_READ'
    EXPORTING
      dyname             = sy-repid
      dynumb             = sy-dynnr
      translate_to_upper = 'X'
    TABLES
      dynpfields         = feld_table
    EXCEPTIONS
      OTHERS             = 1.

  READ TABLE feld_table WITH KEY fieldname = feld_table-fieldname.
  IF sy-subrc <> 0 OR feld_table-fieldvalue IS INITIAL.
    MESSAGE s001 DISPLAY LIKE 'E' WITH '회사코드를 먼저 입력하세요!'.
    EXIT.
  ENDIF.

  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE gt_plant
    FROM t001k AS a
   INNER JOIN t001w AS b
      ON a~bwkey = b~bwkey
   WHERE a~bukrs = pv_bukrs.

  IF sy-subrc <> 0.
    MESSAGE s001 DISPLAY LIKE 'E'
    WITH '해당 플랜트가 존재하지 않습니다!'.
  ENDIF.

  it_fields-tabname    = 'T001W'.
  it_fields-fieldname  = 'WERKS'.
  it_fields-selectflag = 'X'.
  APPEND it_fields.

  it_fields-tabname    = 'T001W'.
  it_fields-fieldname  = 'NAME1'.
  it_fields-selectflag = ' '.
  APPEND it_fields.

  CALL FUNCTION 'HELP_VALUES_GET_NO_DD_NAME'
    EXPORTING
      selectfield                  = selectfield
    IMPORTING
      ind                          = ld_tabix
      select_value                 = select_value
    TABLES
      fields                       = it_fields
      full_table                   = gt_plant
    EXCEPTIONS
      full_table_empty             = 1
      no_tablestructure_given      = 2
      no_tablefields_in_dictionary = 3
      more_then_one_selectfield    = 4
      no_selectfield               = 5
      OTHERS                       = 6.

  CHECK NOT ld_tabix IS INITIAL.
  READ TABLE gt_plant INDEX ld_tabix.
  pv_werks = gt_plant-werks.

ENDFORM.                    " F4HELP_WERKS
*&---------------------------------------------------------------------*
*&      Form  CHECK_BUKRS_WERKS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_WA_BUKRS  text
*      -->P_WA_WERKS  text
*----------------------------------------------------------------------*
FORM check_bukrs_werks  USING    pv_bukrs
                                 pv_werks.
  CLEAR :   gt_plant.
  REFRESH : gt_plant.

  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE gt_plant
    FROM t001k AS a
   INNER JOIN t001w AS b
      ON a~bwkey = b~bwkey
   WHERE a~bukrs = pv_bukrs
     AND b~werks = pv_werks.

  IF sy-subrc <> 0.
    MESSAGE e001 WITH '회사코드에 해당하는 플랜트를 입력하세요!'.
  ENDIF.

ENDFORM.                    " CHECK_BUKRS_WERKS
*&---------------------------------------------------------------------*
*&      Form  check_approval
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM check_approval CHANGING p_check TYPE c.

  CLEAR: gv_apnum, p_check.

  IF gv_bukrs = '1000'.
    SELECT SINGLE apnum
      FROM zlet0007
      INTO gv_apnum
      WHERE iv_type = wa-iv_type.

    IF gv_apnum = '0'.
      p_check = 'X'.
    ELSEIF gv_apnum > '2'.
      MESSAGE e000 WITH '결재차수가 유효하지 않습니다'.
    ENDIF.
*{ 기능개선 239718 - 추가
  ELSEIF gv_bukrs = '3000'.
    SELECT SINGLE apnum3
      FROM zlet0007
      INTO gv_apnum
      WHERE iv_type = wa-iv_type.

    IF gv_apnum = '0'.
      p_check = 'X'.
    ELSEIF gv_apnum > '2'.
      MESSAGE e000 WITH '결재차수가 유효하지 않습니다'.
    ENDIF.
*} 기능개선 239718 - 추가
  ELSE.
    p_check = 'X'.
  ENDIF.

ENDFORM.                    " check_approval
*&---------------------------------------------------------------------*
*&      Form  approval_insert
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM approval_insert.

  DATA: ls_zlet0003 LIKE zlet0003,
        lv_pernr    TYPE persno,
        lv_appnm1   LIKE zlet0003-app_nm1.

  ls_zlet0003-iv_no     = wa-iv_no.
  ls_zlet0003-iv_status = 'A'.             "합의요청
  ls_zlet0003-req_id    = wa-pernr.
  ls_zlet0003-req_nm    = wa-ename.
  ls_zlet0003-req_date  = sy-datum.
  ls_zlet0003-req_time  = sy-uzeit.
  ls_zlet0003-app_id1   = wa_0110-app_id1.
  ls_zlet0003-app_nm1   = wa_0110-app_nm1.
  ls_zlet0003-app_id2   = wa_0110-app_id2.
  ls_zlet0003-app_nm2   = wa_0110-app_nm2.
  INSERT zlet0003 FROM ls_zlet0003.
  COMMIT WORK.

  IF gv_apnum = '1'.
    lv_pernr = wa_0110-app_id2.
  ELSE.
    lv_pernr = wa_0110-app_id1.
    lv_appnm1 = wa_0110-app_nm1.
  ENDIF.

  PERFORM send_email USING lv_pernr lv_appnm1.

ENDFORM.                    " approval_insert
*&---------------------------------------------------------------------*
*&      Form  send_email
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM send_email USING p_pernr  TYPE persno
                      p_appnm1 LIKE zlet0003-app_nm1.

  DATA: lt_cont_txt  TYPE TABLE OF solisti1,
        lt_pack_list TYPE sopcklsti1_t,
        lt_receivers TYPE somlreci1_t,
        ls_cont_txt  TYPE solisti1,
        ls_pack_list TYPE sopcklsti1,
        ls_receiver  TYPE somlreci1,
        ls_doc_data  TYPE sodocchgi1,
        lv_title     TYPE so_obj_des,
        lv_sender    TYPE so_rec_ext,

        BEGIN OF lt_zlet0083 OCCURS 0,
          pernr    TYPE zlet0083-pernr,
          app_mail TYPE zlet0083-app_mail,
        END OF lt_zlet0083.


* 간편결재 사용시 메일 미발송.
  IF gv_simple_approval = 'X'.
    EXIT.
  ENDIF.



* Populate message body text
  APPEND ls_cont_txt TO lt_cont_txt.
  CONCATENATE '기타통문번호' wa-iv_no '에 대한 합의가 요청되었습니다.'
              INTO ls_cont_txt-line SEPARATED BY space.
  APPEND ls_cont_txt TO lt_cont_txt.
  IF gv_apnum = '2'.
    CONCATENATE '주합의자' ' : ' '[' p_pernr ']'  '[' p_appnm1 ']'
                INTO ls_cont_txt-line SEPARATED BY space.
    APPEND ls_cont_txt TO lt_cont_txt.
  ENDIF.

  CONCATENATE '[' wa-iv_no ']' INTO lv_title.
  CONCATENATE lv_title '통문 합의 요청'
              INTO lv_title SEPARATED BY space.


* Fill the document data and get size of attachment
  ls_doc_data-obj_name   = 'EMAIL'.
  ls_doc_data-obj_descr  = lv_title.
  ls_doc_data-obj_langu  = sy-langu.
  ls_doc_data-sensitivty = 'F'.
  ls_doc_data-obj_prio   = '1'.
  ls_doc_data-no_change  = 'X'.
  ls_doc_data-priority   = '1'.

* Describe the body of the message
  ls_pack_list-transf_bin = space.
  ls_pack_list-head_start = 1.
  ls_pack_list-head_num   = 0.
  ls_pack_list-body_start = 1.
  DESCRIBE TABLE lt_cont_txt LINES ls_pack_list-body_num.
  ls_pack_list-doc_type   = 'RAW'.
  APPEND ls_pack_list TO lt_pack_list.

  IF sy-sysid CA 'DQ'.
*    ls_receiver-receiver = 'sdc24@lscns.com'.
*    ls_receiver-rec_type = 'U'.
*    ls_receiver-com_type = 'INT'.
*    APPEND ls_receiver TO lt_receivers.
  ELSE.
* Add the recipients email address
    SELECT SINGLE usrid
      FROM zpa0105
      INTO ls_receiver-receiver
      WHERE pernr = p_pernr
        AND subty = '0007'
        AND objps = ''
        AND sprps = ''
        AND endda >= sy-datum
        AND begda <= sy-datum.

    IF sy-subrc = 0.
      ls_receiver-rec_type = 'U'.
      ls_receiver-com_type = 'INT'.
      APPEND ls_receiver TO lt_receivers.
    ENDIF.

* 동일 사업장 담당자들에게도 메일 수신하도록 추가. 2017-03-29. MJLEE
* 합의시에만 적용
    IF gv_apnum = '2'.
      CLEAR: lt_zlet0083, lt_zlet0083[].
      SELECT pernr
             app_mail
        INTO CORRESPONDING FIELDS OF TABLE lt_zlet0083
        FROM zlet0083
       WHERE bzarea = wa-bzarea
         AND lvorm  = space.

      LOOP AT lt_zlet0083.
        ls_receiver-receiver = lt_zlet0083-app_mail.
        ls_receiver-rec_type = 'U'.
        ls_receiver-com_type = 'INT'.
        APPEND ls_receiver TO lt_receivers. CLEAR ls_receiver.
      ENDLOOP.
    ENDIF.
  ENDIF.

* Sender email address
  SELECT SINGLE usrid
    FROM zpa0105
    INTO lv_sender
    WHERE pernr = wa-pernr
      AND subty = '0007'
      AND objps = ''
      AND sprps = ''
      AND endda >= sy-datum
      AND begda <= sy-datum.

  CALL FUNCTION 'SO_DOCUMENT_SEND_API1'
    EXPORTING
      document_data              = ls_doc_data
      put_in_outbox              = 'X'
      sender_address             = lv_sender
      sender_address_type        = 'SMTP'
      commit_work                = 'X'
*     ip_encrypt                 =
*     ip_sign                    =
*    IMPORTING
*     sent_to_all                =
*     new_object_id              =
*     sender_id                  =
    TABLES
      packing_list               = lt_pack_list
*     object_header              =
*     contents_bin               =
      contents_txt               = lt_cont_txt
*     contents_hex               =
*     object_para                =
*     object_parb                =
      receivers                  = lt_receivers
    EXCEPTIONS
      too_many_receivers         = 1
      document_not_sent          = 2
      document_type_not_exist    = 3
      operation_no_authorization = 4
      parameter_error            = 5
      x_error                    = 6
      enqueue_error              = 7
      OTHERS                     = 8.

  IF sy-subrc = 0.
    WAIT UP TO 2 SECONDS.
    SUBMIT rsconn01 WITH mode   = 'INT'
                    WITH output = ' '
                    AND RETURN.
  ENDIF.

  IF sy-subrc = 0.
    MESSAGE s000 WITH '메일을 전송했습니다'.
  ELSE.
    MESSAGE s000 DISPLAY LIKE 'E'
                         WITH '메일전송 도중 오류가 발생했습니다'.
  ENDIF.

ENDFORM.                    " send_email
*&---------------------------------------------------------------------*
*&      Module  CHECK_MENGE  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE check_menge INPUT.
  IF gt_out-menge < 0.
    MESSAGE e001 WITH '마이너스 값은 입력이 불가능합니다.'.
  ENDIF.

ENDMODULE.                 " CHECK_MENGE  INPUT
*&---------------------------------------------------------------------*
*&      Form  FILE_UPLOAD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM file_upload .
  DATA: l_subrc LIKE sy-subrc.
  DATA: l_fullfname TYPE file_table-filename.
*  DATA: l_subrc LIKE sy-subrc.
  DATA: ls_doc_char TYPE zfis_attach_doc.

  CALL FUNCTION 'ZFI_DOC_SEL'
    IMPORTING
      e_fullfname = l_fullfname
      e_rc        = l_subrc.

  IF l_subrc = 8.
    MESSAGE s000 WITH '첨부파일은 PDF 만 지원합니다'
                 DISPLAY LIKE 'E'.
    EXIT.
  ENDIF.

  IF l_fullfname IS NOT INITIAL.
    gt_fullfname1 = l_fullfname.
    APPEND gt_fullfname1.
  ENDIF.

  ls_doc_char-bukrs = gv_bukrs.


  IF gt_fullfname1[] IS NOT INITIAL.

    CALL FUNCTION 'ZLE_DOC_CREATE_LSC'
      EXPORTING
        i_doc_char = ls_doc_char
        i_dktxt    = '기타 통문'
      IMPORTING
        e_att_no   = wa-zpdf.

    IF wa-zpdf IS NOT INITIAL.
      CALL FUNCTION 'ZLE_FILE_APPEND'
        EXPORTING
          i_docnr = wa-zpdf
        IMPORTING
          e_rc    = l_subrc
        TABLES
          it_file = gt_fullfname1[].
    ENDIF.

  ENDIF.




ENDFORM.                    " FILE_UPLOAD
*&---------------------------------------------------------------------*
*&      Form  GET_TRANSPORTATION_REQ_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM get_transportation_req_data .
  DATA: ls_1000     LIKE zlet1000.

  CLEAR : ls_1000,      wa-truck_no,
          wa-driver_nm, wa-driver_telno.

  CHECK wa-reqno IS NOT INITIAL.

  SELECT SINGLE *
    INTO ls_1000
    FROM zlet1000
   WHERE reqno = wa-reqno.

  IF sy-subrc = 0.
    IF ls_1000-stats = 'D'.
      MESSAGE e004(zle1) WITH '배차요청번호' wa-reqno
                              '은(는) 요청삭제 되었습니다.'.
    ELSE.
      IF ls_1000-carno IS NOT INITIAL OR
         ls_1000-drvnm IS NOT INITIAL OR
         ls_1000-telno IS NOT INITIAL.
        wa-truck_no     = ls_1000-carno.     "차량번호
        wa-driver_nm    = ls_1000-drvnm.     "운전자명
        wa-driver_telno = ls_1000-telno.     "운전자전화번호
      ENDIF.
    ENDIF.
  ELSE.
    MESSAGE e004(zle1) WITH '배차요청번호' wa-reqno
                            '이(가) 존재하지 않습니다.'.
  ENDIF.

ENDFORM.                    " GET_TRANSPORTATION_REQ_DATA
*&---------------------------------------------------------------------*
*&      Form  F4HELP_REQNO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f4help_reqno .
  DATA: lt_rspar LIKE rsparams OCCURS 0 WITH HEADER LINE,
        lv_reqno LIKE zlet1000-reqno.

  CLEAR   : lt_rspar.
  REFRESH : lt_rspar.

*___회사코드
  CLEAR : lt_rspar.
  lt_rspar-selname = 'P_BUKRS'.
  lt_rspar-kind    = 'P'.
  lt_rspar-low     = wa-bukrs.
  APPEND lt_rspar.

*___사업장
  CLEAR : lt_rspar.
  lt_rspar-selname = 'P_BZAREA'.
  lt_rspar-kind    = 'P'.
  lt_rspar-low     = wa-bzarea.
  APPEND lt_rspar.

  CLEAR : lt_rspar.
  lt_rspar-selname = 'P_CALLD'.
  lt_rspar-kind    = 'P'.
  lt_rspar-low     = 'X'.
  APPEND lt_rspar.

  SUBMIT zler1240 VIA SELECTION-SCREEN
                 WITH SELECTION-TABLE lt_rspar
                  AND RETURN.

  IMPORT lv_reqno FROM MEMORY ID 'ZLER1240'.

  FREE MEMORY ID 'ZLER1240'.

  wa-reqno = lv_reqno.

ENDFORM.                    " F4HELP_REQNO

FORM call_simple_approval  USING    p_reqno.

  CALL FUNCTION 'ZSA1_LE_MAKE_SEND_DATA'
    EXPORTING
      i_iv_no = p_reqno
      i_ztype = 'L1'
      i_bukrs = gv_bukrs.


ENDFORM.
