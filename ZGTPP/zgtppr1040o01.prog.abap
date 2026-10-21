*&---------------------------------------------------------------------*
*& Include          ZGTPPI1030O01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Module STATUS_0100 OUTPUT
*&---------------------------------------------------------------------*
MODULE STATUS_0100 OUTPUT.

  CLEAR : GT_UCOMM, GT_UCOMM[].
  IF P_R1 EQ 'X'.
*U01
    IF S_WERKS-LOW NE '1306'.
      APPEND 'MATGIMIG' TO GT_UCOMM.
    ENDIF.
*U01
    APPEND 'RESEND' TO GT_UCOMM.
    APPEND 'SEND' TO GT_UCOMM.
    IF P_R1 = 'X'.
      SET TITLEBAR 'TITLE_100_1' WITH '(생산오더별)'.
    ELSEIF P_R2 = 'X'.
      SET TITLEBAR 'TITLE_100_1' WITH '(모품목별)'.
    ELSE.
      SET TITLEBAR 'TITLE_100_1' WITH '(자품목별)'.
    ENDIF.
  ELSE.
    APPEND 'CONFIRM' TO GT_UCOMM.
    APPEND 'RESEND' TO GT_UCOMM.
    APPEND 'SEND' TO GT_UCOMM.
    APPEND 'MATGIMIG' TO GT_UCOMM.   "U01
    SET TITLEBAR 'TITLE_100_2'.
    IF P_R1 = 'X'.
      SET TITLEBAR 'TITLE_100_2' WITH '(생산오더별)'.
    ELSEIF P_R2 = 'X'.
      SET TITLEBAR 'TITLE_100_2' WITH '(모품목별)'.
    ELSE.
      SET TITLEBAR 'TITLE_100_2' WITH '(자품목별)'.
    ENDIF.
  ENDIF.

  SET PF-STATUS 'STATUS_100' EXCLUDING GT_UCOMM.


ENDMODULE.
*&---------------------------------------------------------------------*
*& Module CREATE_INSTANCE_CONTROLS OUTPUT
*&---------------------------------------------------------------------*
MODULE CREATE_INSTANCE_CONTROLS OUTPUT.

  PERFORM CREATE_AND_INIT_CONTROLS.

ENDMODULE.
