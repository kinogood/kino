*&---------------------------------------------------------------------*
*& Include          ZGTSDR2020I01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  EXIT_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE EXIT_0100 INPUT.
  SAVE_OK = OK_CODE.
  CLEAR OK_CODE.

  CASE SAVE_OK.
    WHEN 'BACK' OR 'CANC' OR 'EXIT'.
      PERFORM INIT_CONTROLS_0100.
      LEAVE TO SCREEN 0.


    WHEN OTHERS.
  ENDCASE.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0100 INPUT.
  SAVE_OK = OK_CODE.
  CLEAR OK_CODE.

  CASE SAVE_OK.
    WHEN 'ZF100'.  "매출지정
      PERFORM SET_BILLING_FOR_JS.

    WHEN 'REFR'.
      PERFORM REFRESH_0100.

    WHEN OTHERS.
  ENDCASE.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  SET_NETWR_BLH_SCREEN_120  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE SET_NETWR_BLH_SCREEN_120 INPUT.
  "실매출금액 = 매출금액 SUM - 유보금액
  PERFORM SET_REAL_NETWR USING ZGTSDS1100-VBELN_VL.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Form SET_FIELDCAT_0100_BOT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_FIELDCAT_0100_BOT .
  CLEAR: GT_FIELDCAT2[].

  PERFORM CREATE_FIELDCAT USING 'GT_SPLIT'
                                GT_FIELDCAT2.

  PERFORM MODIFY_FIELDCAT_0100_BOT USING GT_FIELDCAT2.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Module  EXIT_0200  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE EXIT_0200 INPUT.
  SAVE_OK = OK_CODE.
  CLEAR OK_CODE.

  CASE SAVE_OK.
    WHEN 'BACK' OR 'CANC' OR 'EXIT'.
      PERFORM INIT_CONTROLS_0200.
      PERFORM REBUILD_LIST_0100.
      PERFORM REFRESH_ALV USING: GO_GRID1,
                                 GO_GRID2.
      "UNLOCK OBJECT
      PERFORM SET_UNLOCK_OBJECT USING GC_O.
      LEAVE TO SCREEN 0.


    WHEN OTHERS.
  ENDCASE.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0200  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0200 INPUT.
  SAVE_OK = OK_CODE.
  CLEAR OK_CODE.

  CASE SAVE_OK.
    WHEN 'ZCRT'. "매출처리
      PERFORM PROCESS_BILLING_JS.

    WHEN 'ZCANC'.
      PERFORM PROCESS_BILLING_CANCEL_JS.

    WHEN 'PICK'.
      PERFORM DOUBLE_CLICK_FIELD_0200.

    WHEN OTHERS.
  ENDCASE.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  CHECK_FKDAT  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CHECK_FKDAT INPUT.
  IF NOT ZGTSDS1100-FKDAT IN GR_FKDAT.
    MESSAGE E113 WITH P_SPMON.
  ENDIF.
ENDMODULE.
