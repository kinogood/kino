*&---------------------------------------------------------------------*
*& Include          ZGTPPR3070O01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Module STATUS_0100 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE STATUS_0100 OUTPUT.
  CLEAR: GT_UCOMM, GT_UCOMM[].

  CASE ABAP_TRUE.
    WHEN P_R1.  "생산오더생성
      APPEND 'ORDUPD' TO GT_UCOMM.      "생산오더 업데이트 반영
      APPEND 'ORDDEL' TO GT_UCOMM.      "생산오더 생성 취소
*-임시 비활성
      APPEND 'ORDCRE' TO GT_UCOMM.      "생산오더 생성
*-임시 비활성
      SET TITLEBAR '0100'.
    WHEN P_R2.  "생산오더조회/변경
      APPEND 'ORDCRE' TO GT_UCOMM.      "생산오더 생성
      APPEND 'ITEMCRE' TO GT_UCOMM.     "구성부품 생성
      APPEND 'ORDITEMCRE' TO GT_UCOMM.  "생산오더 생성 및 구성 부품 등록
      APPEND 'JOBNOEXC' TO GT_UCOMM.    "선택한 제번 조회 제외
      APPEND 'JOBNOEXCCAN' TO GT_UCOMM. "조회 제외 취소
*-임시 비활성
      APPEND 'ORDUPD' TO GT_UCOMM.      "생산오더 업데이트 반영
*-임시 비활성
      SET TITLEBAR '0101'.
  ENDCASE.
  SET PF-STATUS '0100' EXCLUDING GT_UCOMM.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module CREATE_ALV_0100 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE CREATE_ALV_0100 OUTPUT.
  IF GO_GRID_0100 IS NOT BOUND.
    PERFORM SET_OBJECT_GRID_0100.
    PERFORM SET_LAYOUT_GRID_0100.
    PERFORM SET_VARIANT_GRID_0100.
    PERFORM SET_FIELDCAT_GRID_0100.
    PERFORM EXCLUDE_OF_TOOLBAR_GRID_0100.
    PERFORM SET_SORTTAB_GRID_0100.
    PERFORM SET_EVENT_GRID_0100 USING GO_GRID_0100.
    PERFORM CALL_GRID_0100_DISPLAY.
  ENDIF.
ENDMODULE.
