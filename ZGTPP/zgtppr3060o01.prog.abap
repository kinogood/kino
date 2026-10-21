*&---------------------------------------------------------------------*
*& Include          ZGTPPR3060O01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Module STATUS_0100 OUTPUT
*&---------------------------------------------------------------------*
MODULE STATUS_0100 OUTPUT.

  CLEAR : GT_UCOMM, GT_UCOMM[].

  APPEND 'RESEND' TO GT_UCOMM.
  APPEND 'SEND' TO GT_UCOMM.

  CASE ABAP_TRUE.
    WHEN P_R1.
      GV_TITLE = '제조지시별 재고 조회 (시리얼별)'.
    WHEN P_R2.
      GV_TITLE = '제조지시별 재고 조회 (판매오더 품목별)'.
    WHEN P_R3.
      GV_TITLE = '제조지시별 재고 조회 (제조지시별)'.
  ENDCASE.


      SET TITLEBAR 'TITLE_100_1' WITH GV_TITLE.

*    APPEND 'SEND' TO gt_ucomm.
*    SET TITLEBAR 'TITLE_100_2'.


      SET PF-STATUS 'STATUS_100' EXCLUDING GT_UCOMM.

ENDMODULE.
*&---------------------------------------------------------------------*
*& Module CREATE_INSTANCE_CONTROLS OUTPUT
*&---------------------------------------------------------------------*
MODULE CREATE_INSTANCE_CONTROLS OUTPUT.

  PERFORM CREATE_AND_INIT_CONTROLS.

ENDMODULE.
