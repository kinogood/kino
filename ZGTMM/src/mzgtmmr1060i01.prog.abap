*&---------------------------------------------------------------------*
*&  Include           MZNF0010I01                                      *
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  exit  INPUT
*&---------------------------------------------------------------------*
module EXIT input.

  leave program.

endmodule.                 " exit  INPUT

*&---------------------------------------------------------------------*
*&      Module  user_command_0100  INPUT
*&---------------------------------------------------------------------*
module USER_COMMAND_0100 input.

  case SY-UCOMM.

    when 'SELECT'.  "조회
      perform DATA_CLEAR.
      perform DATA_SELECT.

    when 'SAVE'.    "저장
      if GV_CU1_O_CASH is initial or
         GV_AL1_O_CASH is initial or
         GV_PB1_O_CASH is initial.
        message S000 with 'CU1,AL1,PB1의 Cash-Official을 입력하세요.'.
      else.
        perform DATA_BDC.
      endif.

    when 'DELETE'.   "삭제
      PERFORM DATA_CHECK.         "해당 날짜의 데이터가 있는지 확인

  endcase.

endmodule.                 " user_command_0100  INPUT

*&---------------------------------------------------------------------*
*&      Module  check_data  INPUT
*&---------------------------------------------------------------------*
module CHECK_DATA input.

  GV_CU1_C_CASH = GV_CU1_C_3M - GV_CU1_SPREAD.
  GV_AL1_C_CASH = GV_AL1_C_3M - GV_AL1_SPREAD.
  GV_PB1_C_CASH = GV_PB1_C_3M - GV_PB1_SPREAD.
  GV_NI1_C_CASH = GV_NI1_C_3M - GV_NI1_SPREAD.

  if GV_CU1_C_CASH < 0.
    GV_CU1_C_CASH = 0.
  endif.

  if GV_AL1_C_CASH < 0.
    GV_AL1_C_CASH = 0.
  endif.

  if GV_PB1_C_CASH < 0.
    GV_PB1_C_CASH = 0.
  endif.

  if GV_NI1_C_CASH < 0.
    GV_NI1_C_CASH = 0.
  endif.

  if     GV_CU1_SPREAD > 0.
    GV_CU1_C_B = 'c'.
  elseif GV_CU1_SPREAD < 0.
    GV_CU1_C_B = 'b'.
  else.
    GV_CU1_C_B = ' '.
  endif.

  if     GV_AL1_SPREAD > 0.
    GV_AL1_C_B = 'c'.
  elseif GV_AL1_SPREAD < 0.
    GV_AL1_C_B = 'b'.
  else.
    GV_AL1_C_B = ' '.
  endif.

  if     GV_PB1_SPREAD > 0.
    GV_PB1_C_B = 'c'.
  elseif GV_PB1_SPREAD < 0.
    GV_PB1_C_B = 'b'.
  else.
    GV_PB1_C_B = ' '.
  endif.

  if     GV_NI1_SPREAD > 0.
    GV_NI1_C_B = 'c'.
  elseif GV_NI1_SPREAD < 0.
    GV_NI1_C_B = 'b'.
  else.
    GV_NI1_C_B = ' '.
  endif.

  if GV_CU2_SHFE_LOGIC1 = 0 or GV_CU2_SHFE_LOGIC2 = 0.
    GV_CU2_C_CASH = 0.
  else.
    GV_CU2_C_CASH = GV_CU2_SHFE_1M /
                    GV_CU2_SHFE_LOGIC1 / GV_CU2_SHFE_LOGIC2.
    GV_CU3_C_CASH = GV_CU2_SHFE_1M /
                    GV_CU2_SHFE_LOGIC1 / GV_CU2_SHFE_LOGIC2.

  endif.

endmodule.                 " check_data  INPUT
*&---------------------------------------------------------------------*
*&      Form  POPUP_TO_CONFIRM
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form POPUP_TO_CONFIRM .

  clear : GV_ANSWER.

*.삭제시 팝업메시지로 한번 더 확인한다.
  call function 'POPUP_TO_CONFIRM'
    exporting
      TITLEBAR      = '확인'
      TEXT_QUESTION = '정말로 삭제 하시겠습니까?'
      TEXT_BUTTON_1 = '예'
      ICON_BUTTON_1 = 'ICON_OKAY'
      TEXT_BUTTON_2 = '아니오'
      ICON_BUTTON_2 = 'ICON_CANCEL'
      DISPLAY_CANCEL_BUTTON = ' '
    importing
      ANSWER        = GV_ANSWER.


endform.                    " POPUP_TO_CONFIRM
