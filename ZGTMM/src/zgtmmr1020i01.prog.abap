*&---------------------------------------------------------------------*
*& Include          ZGTFIR4003I01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  EXIT_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE exit_0100 INPUT.

  gv_okcode_save = gv_okcode.
  CLEAR gv_okcode.
*
*  PERFORM popup_to_confirm_step USING zgtfi_n
*                                      TEXT-m04
*                                      ''
*                                      TEXT-t01.
*  CHECK gv_answer = zgtfi_j.

  CASE GV_OKCODE_SAVE.

    WHEN 'BACK' OR 'CANC'.
       PERFORM RELEASE_ALV.
       LEAVE TO SCREEN 0.

    WHEN 'EXIT'.
      PERFORM RELEASE_ALV.
      LEAVE PROGRAM.

  ENDCASE.

ENDMODULE.

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0100 INPUT.

  CLEAR : GV_ERR, GV_ANSWER.

  GV_OKCODE_SAVE = GV_OKCODE.
  CLEAR GV_OKCODE.

  CASE GV_OKCODE_SAVE.
*    WHEN 'REF'.
*      PERFORM GET_DATA.
*      CHECK GV_ERR IS INITIAL.
*
*      PERFORM REFRESH_TABLE USING GCL_GRID SPACE.

    WHEN 'CONV'.
       GV_EDIT = COND #( WHEN GV_EDIT = ZGTFI_X THEN '' ELSE ZGTFI_X ).

       IF  GV_EDIT = ZGTFI_X.
          PERFORM SET_CELL_STYLE.

       ELSE.
*조회 모드로 변경 시, 변경 필드가 존재하면, 팝업 확인 후 처리
          IF LINE_EXISTS( GT_LIST[ STATUS = ICON_CHANGE ] ) OR
            LINE_EXISTS( GT_LIST[ STATUS = ICON_LED_RED ] ).

            PERFORM POPUP_TO_CONFIRM_STEP USING ZGTFI_N
                                                                       TEXT-M04  "저장되지 않은 데이터가 존재합니다.
                                                                       TEXT-M05  "조회 모드로 변경 하시겠습니까?
                                                                       TEXT-T04. "확인
            CHECK GV_ANSWER = ZGTFI_J. "YES
            PERFORM GET_DATA.
            PERFORM SET_CELL_STYLE.

          ELSE.
            PERFORM SET_CELL_STYLE.

          ENDIF.
       ENDIF.

    WHEN 'SAVE'.
      PERFORM SET_CHANGE_SAVE.

  ENDCASE.

ENDMODULE.

**&---------------------------------------------------------------------*
**&      Module  USER_COMMAND_0200  INPUT
**&---------------------------------------------------------------------*
**       text
**----------------------------------------------------------------------*
*MODULE user_command_0200 INPUT.
*
*  CLEAR : gv_err.
*
*  gv_okcode_save_2 = gv_okcode.
*  CLEAR gv_okcode.
*
*  CASE gv_okcode_save_2.
*    WHEN 'CHECK'.
*      PERFORM clear_post_process USING zgtfi_x.
*
*    WHEN 'POST'.
*      PERFORM clear_post_process USING ''.
*      CHECK gv_err IS INITIAL.
*
*
*  ENDCASE.
*
*ENDMODULE.

*&---------------------------------------------------------------------*
*&      Module  F4_BLART  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE f4_blart INPUT.

*  DATA: BEGIN OF lt_t003t OCCURS 0 ,
*          blart LIKE t003t-blart,
*          ltext LIKE t003t-ltext,
*        END OF lt_t003t.
*  DATA: lt_field LIKE help_value OCCURS 0 WITH HEADER LINE,
*        lv_index TYPE i.
*
*  CLEAR: lt_field, lt_field[], lv_index.
*  REFRESH lt_t003t.
*  CLEAR lt_t003t.
*
*  SELECT blart,
*         ltext
*    FROM t003t
*   WHERE blart IN (@gc_blart_ca, @gc_blart_cl)
*     AND spras = @sy-langu
*    INTO CORRESPONDING FIELDS OF TABLE @lt_t003t.
*
** Display할 Field의 속성 지정
*  CLEAR: lt_field.
*  lt_field-tabname    = 'T003T'.
*  lt_field-fieldname  = 'BLART'.        "계정코드
*  lt_field-selectflag = 'X'.
*  APPEND lt_field.
*
*  CLEAR: lt_field.
*  lt_field-tabname    = 'T003T'.
*  lt_field-fieldname  = 'LTEXT'.        "
*  APPEND lt_field.
*
** Help Function을 Call 한다
*  CLEAR lv_index.
*  CALL FUNCTION 'HELP_VALUES_GET_NO_DD_NAME'
*    EXPORTING
*      selectfield                  = 'BLART'
*      titel                        = '수금유형'
*    IMPORTING
*      ind                          = lv_index
*    TABLES
*      fields                       = lt_field
*      full_table                   = lt_t003t
*    EXCEPTIONS
*      full_table_empty             = 1
*      no_tablestructure_given      = 2
*      no_tablefields_in_dictionary = 3
*      more_then_one_selectfield    = 4
*      no_selectfield               = 5
*      OTHERS                       = 6.
*
*  IF sy-subrc <> 0.
*
*  ELSE.
*    READ TABLE lt_t003t INDEX lv_index.
*    IF sy-subrc = 0.
*      gs_200-blart = lt_t003t-blart.   "계정코드
*      gs_200-blart_tx = lt_t003t-ltext.
*    ENDIF.
*  ENDIF.

ENDMODULE.

**&---------------------------------------------------------------------*
**&      Module  CHECK_KUNNR  INPUT
**&---------------------------------------------------------------------*
**       text
**----------------------------------------------------------------------*
*MODULE check_kunnr INPUT.
*
*  CLEAR : gs_info-kunnr_tx.
*  IF gs_info-kunnr IS NOT INITIAL.
*    gs_info-kunnr = |{ gs_info-kunnr ALPHA = IN }|.
*    SELECT SINGLE name1
*      FROM kna1
*      INTO @gs_info-kunnr_tx
*     WHERE kunnr = @gs_info-kunnr.
*    IF sy-subrc <> 0.
*      MESSAGE e017.  "유효하지 않은 코드 입니다.
*    ENDIF.
*  ENDIF.
*
*ENDMODULE.
*
**&---------------------------------------------------------------------*
**&      Module  CHECK_VKGRP  INPUT
**&---------------------------------------------------------------------*
**       text
**----------------------------------------------------------------------*
*MODULE check_vkgrp INPUT.
*
*  CLEAR : gs_info-vkgrp_tx.
*  IF gs_info-vkgrp IS NOT INITIAL.
**    gs_info-kunnr = |{ gs_info-kunnr ALPHA = IN }|.
*    SELECT SINGLE bezei
*      FROM tvgrt
*      INTO @gs_info-vkgrp_tx
*     WHERE vkgrp = @gs_info-vkgrp
*       AND spras = @sy-langu.
*    IF sy-subrc <> 0.
*      MESSAGE e017.  "유효하지 않은 코드 입니다.
*    ENDIF.
*  ENDIF.
*
*ENDMODULE.
*
**&---------------------------------------------------------------------*
**&      Module  CHECK_SPART  INPUT
**&---------------------------------------------------------------------*
**       text
**----------------------------------------------------------------------*
*MODULE check_spart INPUT.
*
*  CLEAR : gs_info-spart_tx.
*  IF gs_info-spart IS NOT INITIAL.
*    SELECT SINGLE vtext
*      FROM tspat
*      INTO @gs_info-spart_tx
*     WHERE spart = @gs_info-spart
*       AND spras = @sy-langu.
*    IF sy-subrc <> 0.
*      MESSAGE e017.  "유효하지 않은 코드 입니다.
*    ENDIF.
*  ENDIF.
*
*ENDMODULE.
