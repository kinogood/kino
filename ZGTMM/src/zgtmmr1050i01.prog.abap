*&---------------------------------------------------------------------*
*& Include          ZGTMMR3000I01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  EXIT_0100  INPUT
*&---------------------------------------------------------------------*
*       TEXT
*----------------------------------------------------------------------*
MODULE EXIT_0100 INPUT.

  GV_OKCODE_SAVE = GV_OKCODE.
  CLEAR GV_OKCODE.
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
*&      Module  F4_BLART  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*MODULE f4_blart INPUT.
*
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
*
*ENDMODULE.

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
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0200  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0200 INPUT.

  CLEAR : GV_OKCODE_SAVE2 , GV_ERR.

  GV_OKCODE_SAVE2 = GV_OKCODE.
  CLEAR GV_OKCODE.

  CASE GV_OKCODE_SAVE2.
    WHEN 'YES'.
*      IF GV_OKCODE_SAVE = 'CHANGE' AND GV_EKGRP IS INITIAL.
*        MESSAGE S000 WITH TEXT-E08 DISPLAY LIKE 'E'.
*        "구매그룹은 필수 입력입니다.
*
*      ELSE.
*        IF GV_OKCODE_SAVE = 'CHANGE'. "구매그룹변경
*          PERFORM SET_BAPI_DATA.
*       ENDIF.
*        PERFORM REFRESH_TABLE USING GCL_GRID SPACE.
        LEAVE TO SCREEN 0.
*      ENDIF.

    WHEN OTHERS.
      LEAVE TO SCREEN 0.
  ENDCASE.

ENDMODULE.
