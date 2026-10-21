*&---------------------------------------------------------------------*
*& Include          ZGTPPI3090I01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  EXIT  INPUT
*&---------------------------------------------------------------------*
MODULE exit INPUT.

  gv_ok_code2 = gv_ok_code.
  CLEAR: gv_ok_code.

  CASE gv_ok_code2.
    WHEN 'BACK' OR 'CANC'.
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
    WHEN 'TAB01'.         "구매 제조지시
      PERFORM init_subscreen USING '0110'.
    WHEN 'TAB02'.         "구매 제조지시 구성품
      PERFORM init_subscreen USING '0120'.
    WHEN 'DETAIL'.
      PERFORM get_detail_data.
    WHEN 'SEND' OR "전송
            'RESEND'. "재처리
      PERFORM send_data.
* REFRESH DISPLAY
*      CALL METHOD g_grid->refresh_table_display
      CALL METHOD go_grid_0100->refresh_table_display
        EXPORTING
          i_soft_refresh = 'X'
          is_stable      = gv_stable.
    WHEN 'REFRESH'. "REFRESH
* 데이터 갱신
      PERFORM get_data.
  ENDCASE.

ENDMODULE.
