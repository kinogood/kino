*&---------------------------------------------------------------------*
*& Include          ZGTPPI1030I01
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
    WHEN 'CREATE'. " 생산버젼 생성
      DATA : answer(1)    TYPE c,
             lv_text(100).
      CLEAR : answer , lv_text.

      lv_text = '생산버전을 생성하시겠습니까?'.
      " 생산버젼 생성 확인 팝업
      CALL FUNCTION 'POPUP_TO_CONFIRM'
        EXPORTING
          titlebar              = '생산버젼 생성 확인'
          text_question         = lv_text
          display_cancel_button = space
        IMPORTING
          answer                = answer.

      IF answer = '1'.
        " 생산버젼 생성
        PERFORM create_data.

        " REFRESH DISPLAY
        CALL METHOD go_grid_0100->refresh_table_display
          EXPORTING
            i_soft_refresh = 'X'
            is_stable      = gv_stable.
      ENDIF.

    WHEN 'REFRESH'. "REFRESH
* 데이터 갱신
      PERFORM get_data.
  ENDCASE.
* REFRESH DISPLAY
*  CALL METHOD go_grid_0100->refresh_table_display
*    EXPORTING
*      i_soft_refresh = 'X'
*      is_stable      = gv_stable.

ENDMODULE.
