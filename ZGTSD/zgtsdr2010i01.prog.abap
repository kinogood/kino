*&---------------------------------------------------------------------*
*& Include          ZGTSDR2010I01
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
    WHEN 'ZF100'. "적송처리
      PERFORM PROCESS_JS_STEP.

    WHEN 'ZF200'. "당월출고분 BILLING 취소
      PERFORM PROCESS_BILLING_M_CANCEL.

    WHEN 'ZF300'. "당월출고분 BILLING
      PERFORM PROCESS_BILLING_M_STEP.

    WHEN 'ZF900'. "적송취소
      PERFORM PROCESS_JS_STEP_CANCEL.

    WHEN OTHERS.
  ENDCASE.
ENDMODULE.
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
      "적송지정 처리가 수행된 경우 SCREEN 0100 REBUILD
      PERFORM CHECK_CHANGED_STATUS_0200.
*      IF ZGTSDS0020-CH_FLAG EQ GC_X.
*        PERFORM REBUILD_LIST_0100.
*      ENDIF.
      "UNLOCK OBJECT
      IF ZGTSDS0020-LOCK EQ GC_X.
        PERFORM SET_UNLOCK_OBJECT CHANGING ZGTSDS0020-VBELN.
      ENDIF.

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
    WHEN 'ZF500'. "적송지정
      PERFORM ASSIGN_JS_DATA.

    WHEN 'ZF600'. "적송지정 취소
      PERFORM UNASSIGN_JS_DATA.

    WHEN 'ZF700'. "당월매출일자 지정
      PERFORM SET_FKDAT_M_DATE.


    WHEN 'DCLICK'. "DOUBLE CLICK
      PERFORM DOUBLE_CLICK_FIELD_0200.

    WHEN OTHERS.
  ENDCASE.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0900  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0900 INPUT.
  SAVE_OK = OK_CODE.
  CLEAR OK_CODE.

  CASE SAVE_OK.
    WHEN 'ZOK' OR 'ZCANC'.
      PERFORM INIT_CONTROLS_0900.
      LEAVE TO SCREEN 0.
    WHEN OTHERS.
  ENDCASE.
ENDMODULE.
