*&---------------------------------------------------------------------*
*& Include          ZGTPPR3000I01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  EXIT_COMMAND  INPUT
*&---------------------------------------------------------------------*
MODULE exit_command INPUT.

  gv_ok_code2 = gv_ok_code.
  CLEAR: gv_ok_code.

  CASE gv_ok_code2.
    WHEN 'BACK' OR 'CANC'.
      PERFORM exit_program.
      LEAVE TO SCREEN 0.
    WHEN 'EXIT'.
      LEAVE PROGRAM.
  ENDCASE.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
MODULE user_command_0100 INPUT.

  gv_ok_code2 = gv_ok_code.
  CLEAR: gv_ok_code.

  CASE gv_ok_code2.
    WHEN 'REWORK'. "백로그 재처리
      PERFORM rework_backlog.
    WHEN 'DEL'. "백로그, 실투입 삭제
      PERFORM delete_backlog.
    WHEN 'SAVE'. "삭제 사유 대량 등록
      PERFORM multi_delete_backlog.
    WHEN 'CHANGE'. "대체자재 일괄 변경
      PERFORM change_matnr.
*- Start 2025.05.08
    WHEN 'CHANGE_H'. "대체자재 변경 내역 확인
      PERFORM display_change_matnr_history.
  ENDCASE.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0200  INPUT
*&---------------------------------------------------------------------*
MODULE user_command_0200 INPUT.

  gv_ok_code4 = gv_ok_code3.
  CLEAR: gv_ok_code3.

  CASE gv_ok_code4.
    WHEN 'YES'.

      IF gv_del_reason IS INITIAL.
        MESSAGE i003 WITH TEXT-m05.
      ELSE.
        LEAVE TO SCREEN 0.
      ENDIF.

    WHEN 'NO'.

      CLEAR : gv_del_reason, gv_reason_text, gv_details.
      LEAVE TO SCREEN 0.

  ENDCASE.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  F4HELP_DEL_REASON  INPUT
*&---------------------------------------------------------------------*
MODULE f4help_del_reason INPUT.

  DATA : BEGIN OF lt_del_reason OCCURS 0,
           fld_02 LIKE zgtppt1010-fld_02,
           fld_03 LIKE zgtppt1010-fld_03,
         END OF lt_del_reason.
  DATA : lv_selectfield  LIKE help_info-fieldname,
         lt_fields       LIKE help_value OCCURS 0 WITH HEADER LINE,
         lv_tabix        LIKE sy-tabix,
         lv_select_value LIKE help_info-fldvalue.

  CLEAR : lt_del_reason, lt_del_reason[], lt_fields, lt_fields[], lv_selectfield, lv_tabix,
               lv_select_value.

  SELECT fld_02 fld_03
    INTO CORRESPONDING FIELDS OF TABLE lt_del_reason
    FROM zgtppt1010
   WHERE module_kind = 'PP'
        AND codegrp = '3000'
        AND fld_01 = p_werks.

  SORT lt_del_reason BY fld_02.
*___아래 부분이 F4를 눌렀을 때, Hit List를 보여준다.
  lt_fields-tabname    = 'ZGTPPT1010'.
  lt_fields-fieldname  = 'FLD_02'.
  lt_fields-selectflag = 'X'.
  APPEND lt_fields.

  lt_fields-tabname    = 'ZGTPPT1010'.
  lt_fields-fieldname  = 'FLD_03'.
  lt_fields-selectflag = 'X'.
  APPEND lt_fields.

  CALL FUNCTION 'HELP_VALUES_GET_NO_DD_NAME'
    EXPORTING
      selectfield                  = lv_selectfield
    IMPORTING
      ind                          = lv_tabix
      select_value                 = lv_select_value
    TABLES
      fields                       = lt_fields
      full_table                   = lt_del_reason
    EXCEPTIONS
      full_table_empty             = 1
      no_tablestructure_given      = 2
      no_tablefields_in_dictionary = 3
      more_then_one_selectfield    = 4
      no_selectfield               = 5
      OTHERS                       = 6.

  CHECK NOT lv_tabix IS INITIAL.
  READ TABLE lt_del_reason INDEX lv_tabix.

  CHECK sy-subrc = 0.
* 아래 부분이 선택된 값들을 화면 필드에 뿌려준다.
  lt_scr_fields-fieldname  = 'GV_DEL_REASON'.
  lt_scr_fields-fieldvalue = lt_del_reason-fld_02.
  APPEND lt_scr_fields.

  lt_scr_fields-fieldname  = 'GV_REASON_TEXT'.
  lt_scr_fields-fieldvalue = lt_del_reason-fld_03.
  APPEND lt_scr_fields.

  CALL FUNCTION 'DYNP_VALUES_UPDATE'
    EXPORTING
      dyname               = sy-repid
      dynumb               = sy-dynnr
    TABLES
      dynpfields           = lt_scr_fields
    EXCEPTIONS
      invalid_abapworkarea = 1
      invalid_dynprofield  = 2
      invalid_dynproname   = 3
      invalid_dynpronummer = 4
      invalid_request      = 5
      no_fielddescription  = 6
      undefind_error       = 7
      OTHERS               = 8.

  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  GET_TEXT  INPUT
*&---------------------------------------------------------------------*
MODULE get_text INPUT.

  IF gv_del_reason IS NOT INITIAL.

    CLEAR gs_zgtppt1010.
    READ TABLE gt_zgtppt1010 INTO gs_zgtppt1010
                                             WITH KEY fld_02 = gv_del_reason.
    IF gs_zgtppt1010 IS NOT INITIAL.
      gv_reason_text = gs_zgtppt1010-fld_03.
    ENDIF.

  ELSE.

    CLEAR gv_reason_text.

  ENDIF.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  GET_TEXT2  INPUT
*&---------------------------------------------------------------------*
MODULE get_text2 INPUT.

  DATA : lv_matnr    LIKE marc-matnr,
         lv_matnr2   LIKE marc-matnr,
         lv_text(60).

  CLEAR : gv_error.
  IF gv_matnr IS NOT INITIAL.

    CALL FUNCTION 'CONVERSION_EXIT_MATN1_INPUT'
      EXPORTING
        input  = gv_matnr
      IMPORTING
        output = lv_matnr2.

    SELECT SINGLE maktx INTO @gv_maktx FROM makt
                                      WHERE matnr EQ @lv_matnr2
                                           AND spras EQ @sy-langu.

    SELECT SINGLE a~lgpro, b~meins, a~matnr, b~matkl
                     INTO ( @gv_lgort, @gv_meins, @lv_matnr, @gv_matkl )
                                     FROM marc AS a INNER JOIN mara AS b
                                         ON a~matnr EQ b~matnr
                                         AND a~werks EQ @p_werks
                                     WHERE a~matnr EQ @lv_matnr2.

    SELECT SINGLE lgobe INTO @gv_lgobe FROM t001l
                                     WHERE werks EQ @p_werks
                                          AND lgort EQ @gv_lgort.
* 입력한 대체자재의 플랜트 데이터가 존재하는 지 점검
    IF  lv_matnr IS INITIAL.

      CONCATENATE TEXT-010 p_werks TEXT-011 gv_matnr TEXT-012 INTO lv_text
      SEPARATED BY space.
      MESSAGE i003 WITH lv_text.
      CLEAR : gv_maktx, gv_lgort, gv_lgobe, gv_meins, gv_matkl.
      gv_error = 'X'.

    ELSE.
* 대체 자재코드의 기본 단위가 선택 라인들의 기본 단위와 다를 경우 에러 메시지 출력
      CLEAR gs_meins.
      READ TABLE gt_meins INTO gs_meins WITH KEY meins = gv_meins.
      IF gs_meins IS INITIAL.
        MESSAGE i003 WITH TEXT-m15.
        CLEAR : gv_maktx, gv_lgort, gv_lgobe, gv_meins, gv_matkl.
        gv_error = 'X'.
      ELSE.
* 대체 자재코드의 자재 그룹이 선택 라인들의 자재 그룹과 다를 경우 에러 메시지 출력
        CLEAR gs_matkl.
        READ TABLE gt_matkl INTO gs_matkl WITH KEY matkl = gv_matkl.
        IF gv_matkl IS INITIAL.
          MESSAGE i003 WITH TEXT-m22.
          CLEAR : gv_maktx, gv_lgort, gv_lgobe, gv_meins, gv_matkl.
          gv_error = 'X'.
        ENDIF.
      ENDIF.

    ENDIF.

  ELSE.

    CLEAR : gv_maktx, gv_lgort, gv_lgobe, gv_meins, gv_matkl.

  ENDIF.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0300  INPUT
*&---------------------------------------------------------------------*
MODULE user_command_0300 INPUT.

  CLEAR: gv_answer.
  gv_ok_code4 = gv_ok_code3.
  CLEAR: gv_ok_code3.

  CASE gv_ok_code4.
    WHEN 'YES2'.

      CHECK gv_error IS INITIAL.

      IF gv_matnr IS INITIAL.
        MESSAGE i003 WITH TEXT-m14.
      ELSE.

        CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
          EXPORTING
            titel     = TEXT-033 "대체자재 일괄 변경
            textline1 = TEXT-034 "입력한 대체자재로 모두 일괄 변경 처리 하시겠습니까?
            textline2 = ''
          IMPORTING
            answer    = gv_answer.

        CHECK gv_answer = 'J'.

        LEAVE TO SCREEN 0.

      ENDIF.

  ENDCASE.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  EXIT_COMMAND2  INPUT
*&---------------------------------------------------------------------*
MODULE exit_command2 INPUT.

  gv_ok_code4 = gv_ok_code3.
  CLEAR: gv_ok_code3.

  CASE gv_ok_code4.
    WHEN 'BACK' OR 'CANC' OR 'EXIT'.
      LEAVE TO SCREEN 0.
  ENDCASE.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0102  INPUT
*&---------------------------------------------------------------------*
MODULE user_command_0102 INPUT.

  gv_ok_code4 = gv_ok_code3.
  CLEAR: gv_ok_code3.

  CASE gv_ok_code4.
    WHEN 'BACK' OR 'EXIT' OR 'CANC'.
      CALL METHOD go_contain_0102->free.
      FREE : go_contain_0102, go_grid_0102.
      CALL METHOD cl_gui_cfw=>flush.
      LEAVE TO SCREEN 0.
  ENDCASE.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0302  INPUT
*&---------------------------------------------------------------------*
MODULE user_command_0302 INPUT.

  gv_ok_code5 = gv_ok_code4.
  CLEAR: gv_ok_code4.

  CASE gv_ok_code5.
    WHEN 'BACK' OR 'EXIT' OR 'CANC'.
      CALL METHOD go_contain_0302->free.
      FREE : go_contain_0302, go_grid_0302.
      CALL METHOD cl_gui_cfw=>flush.
      LEAVE TO SCREEN 0.
  ENDCASE.

ENDMODULE.
