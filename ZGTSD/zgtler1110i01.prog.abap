*&---------------------------------------------------------------------*
*& Include          ZGTLER1110I01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  EXIT  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE EXIT_0100 INPUT.

  CASE OK_CODE.
    WHEN 'BACK' OR 'EXIT' OR 'CANC'.
      CLEAR : OK_CODE.

      LEAVE TO SCREEN 0.

  ENDCASE.

ENDMODULE.                 " EXIT  INPUT
*&---------------------------------------------------------------------*
*&      Module  SAVE_OK_CODE  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE SAVE_OK_CODE INPUT.

  OK_SAVE = OK_CODE.

  CLEAR : OK_CODE.

ENDMODULE.                 " SAVE_OK_CODE  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0100 INPUT.

  PERFORM GET_SELECTED_ROWS.

  CASE OK_SAVE.
    WHEN 'LEREV'.           "출하검토
      PERFORM LE_CONFIRM USING ' '.

    WHEN 'LECFM'.           "출하확정
      PERFORM LE_CONFIRM USING 'X'.

    WHEN 'DCHG'.            "납품정보변경
      PERFORM CALL_SCREEN_0200.

    WHEN 'RFSH'.            "Refresh
      PERFORM GET_DELIVERY_REQ_DATA.

    WHEN 'ASEL' OR 'DSEL'.  "전체선택/해제
      PERFORM SELECT_ALL.

    WHEN 'STOK'.            "재고조회
*      PERFORM DISPLAY_STOCK.
      PERFORM DISPLAY_STOCK_0900.

*    WHEN 'BACK' OR 'EXIT' OR 'CANC'.
*      LEAVE TO SCREEN 0.

  ENDCASE.

ENDMODULE.                 " USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*&      Module  CHECK_EDATU  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CHECK_EDATU INPUT.

  IF GV_EDATU IS NOT INITIAL AND GV_EDATU < SY-DATLO.
    MESSAGE E004 WITH '납품일에 과거일자를'
                      '입력할 수 없습니다.'.
  ENDIF.

ENDMODULE.                 " CHECK_EDATU  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0200  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0200 INPUT.
*--------------------------------------------------------------------*
**-- 26.09
*   HISTORY 저장 오류 후 ENTER 처리시 화면 그냥 나오도록 조치
*--------------------------------------------------------------------*
  IF GV_ERROR IS NOT INITIAL.
    CLEAR : OK_CODE, GV_ERROR.
  ENDIF.


  CASE OK_SAVE.
    WHEN 'CHNG'.     "변경
      PERFORM CHANGE_DELIVERY_INFO.

    WHEN 'BACK' OR 'EXIT' OR 'CANC'.
      LEAVE TO SCREEN 0.

*--------------------------------------------------------------------*
**-- 26.09
*   POP-UP 화면 상태에서 ENTER 하면 POP-UP 화면에서 나오게 하고
*   납품정보변경 내역은 ZLET0400 에 UPDATE 하지 않는다
*--------------------------------------------------------------------*
    WHEN ''.
      LEAVE TO SCREEN 0.

  ENDCASE.

ENDMODULE.                 " USER_COMMAND_0200  INPUT
*&---------------------------------------------------------------------*
*&      Module  CHECK_POST_CODE  INPUT
*&---------------------------------------------------------------------*
*       기능개선 157326 - 추가
*----------------------------------------------------------------------*
MODULE CHECK_POST_CODE INPUT.

  CHECK GS_DELV-POST_CODE1 IS NOT INITIAL.

  PERFORM CHECK_POST_CODE_NEW USING GS_DELV-POST_CODE1.


*  IF GS_DELV-POST_CODE1 IS INITIAL.
*    IF GT_MAIN-KDKG4 = '4D' OR GT_MAIN-KDKG4 = '4L'.
*      CLEAR : GS_DELV-LZONE.
*    ENDIF.
*  ELSE.
*    PERFORM CHECK_POST_CODE USING GS_DELV-POST_CODE1
*                                  GS_DELV-LZONE.
*  ENDIF.

ENDMODULE.                 " CHECK_POST_CODE  INPUT
*&---------------------------------------------------------------------*
*&      Module  CHECK_TRANSPORT_ZONE  INPUT
*&---------------------------------------------------------------------*
*       기능개선 157326 - 추가
*----------------------------------------------------------------------*
MODULE CHECK_TRANSPORT_ZONE INPUT.

  PERFORM CHECK_TRANSPORT_ZONE.

ENDMODULE.                 " CHECK_TRANSPORT_ZONE  INPUT
*&---------------------------------------------------------------------*
*&      Module  F4HELP_POST  INPUT
*&---------------------------------------------------------------------*
*       기능개선 157326 - 추가
*----------------------------------------------------------------------*
MODULE F4HELP_POST INPUT.

  PERFORM F4HELP_POST USING GS_DELV-POST_CODE1.

ENDMODULE.                 " F4HELP_POST  INPUT
*&---------------------------------------------------------------------*
*&      Module  GET_VHCTP_DESC  INPUT
*&---------------------------------------------------------------------*
*       기능개선 157326 - 추가
*----------------------------------------------------------------------*
MODULE GET_VHCTP_DESC INPUT.

  PERFORM GET_VHCTP_DESC USING GS_DELV-VHCTP
                               GS_DELV-VHCTX.

  IF GS_DELV-VHCTP IS NOT INITIAL AND
     GS_DELV-VHCTX IS INITIAL.
    MESSAGE E004 WITH '차량제한여부 입력값을 점검하십시오.'.
  ENDIF.

ENDMODULE.                 " GET_VHCTP_DESC  INPUT
*&---------------------------------------------------------------------*
*&      Module  CHECK_ARRIVAL_TIME  INPUT
*&---------------------------------------------------------------------*
*       기능개선 157326 - 추가
*----------------------------------------------------------------------*
MODULE CHECK_ARRIVAL_TIME INPUT.

  IF GS_DELV-ARIND IS INITIAL.
    CLEAR : GS_DELV-ARRDT, GS_DELV-ARRTM.
  ENDIF.

ENDMODULE.                 " CHECK_ARRIVAL_TIME  INPUT
*&---------------------------------------------------------------------*
*&      Module  EXIT_0200  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE EXIT_0200 INPUT.
  CASE OK_CODE.
    WHEN 'CANC'.
      CLEAR : OK_CODE.

      LEAVE TO SCREEN 0.

  ENDCASE.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0900  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0900 INPUT.
  OK_SAVE = OK_CODE.
  CLEAR OK_CODE.

  CASE OK_SAVE.
    WHEN 'ZOK' OR 'ZCANC'.
      PERFORM INIT_CONTROLS_0900.
      LEAVE TO SCREEN 0.
    WHEN OTHERS.
  ENDCASE.
ENDMODULE.
