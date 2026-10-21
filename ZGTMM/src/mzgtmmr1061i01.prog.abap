*&---------------------------------------------------------------------*
*&  Include           MZNF0020I01                                      *
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  exit  INPUT
*&---------------------------------------------------------------------*
MODULE exit INPUT.

  LEAVE PROGRAM.

ENDMODULE.                 " exit  INPUT

*&---------------------------------------------------------------------*
*&      Module  user_command_0100  INPUT
*&---------------------------------------------------------------------*
MODULE user_command_0100 INPUT.

  CASE sy-ucomm.

    WHEN 'SELECT'.  "조회
      PERFORM data_clear.
      PERFORM data_select.

    WHEN 'SAVE'.    "저장
      IF gv_cu1_o_cash IS INITIAL OR
         gv_cu3_o_cash IS INITIAL OR
         gv_al1_o_cash IS INITIAL OR
         gv_al2_o_cash IS INITIAL OR
         gv_pb1_o_cash IS INITIAL.
        MESSAGE s000 WITH 'CU,AL,PB의 Cash-Official을 입력하세요.'.
      ELSE.
        PERFORM data_bdc.
      ENDIF.

  ENDCASE.

ENDMODULE.                 " user_command_0100  INPUT

*&---------------------------------------------------------------------*
*&      Module  f4_inmon  INPUT
*&---------------------------------------------------------------------*
MODULE f4_inmon INPUT.

  CALL FUNCTION 'POPUP_TO_SELECT_MONTH'
    EXPORTING
      actual_month   = sy-datum(6)
    IMPORTING
      selected_month = znft0002-inmon.

ENDMODULE.                 " f4_inmon  INPUT
