*&---------------------------------------------------------------------*
*& Include          ZGTPPR9011O01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Module STATUS_0100 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE STATUS_0100 OUTPUT.
  CLEAR: GT_UCOMM, GT_UCOMM[].

  CASE ABAP_TRUE.
    WHEN P_R1.  "재고정보저장
      APPEND 'BATCHCRE'   TO GT_UCOMM.   "배치번호 생성
      APPEND 'TRAORDCRE'  TO GT_UCOMM.   "변환 생산오더 생성
      APPEND 'OMATGI'     TO GT_UCOMM.   "기존 자재 투입 처리
      APPEND 'NMATGR'     TO GT_UCOMM.   "신규 자재 입고 처리
      APPEND 'NMATGRCAN'  TO GT_UCOMM.   "신규 자재 입고 취소
      APPEND 'OMATGICAN'  TO GT_UCOMM.   "기존 자재 투입 취소
      APPEND 'TRAORDDEL'  TO GT_UCOMM.   "변환 생산오더 삭제 설정
      APPEND 'STKCONFCAN' TO GT_UCOMM.   "재고 확정 취소
      SET TITLEBAR '0100'.
    WHEN P_R2.  "재고변환처리
      APPEND 'STKCONF'    TO GT_UCOMM.   "재고 확정
      APPEND 'NMATGRCAN'  TO GT_UCOMM.   "신규 자재 입고 취소
      APPEND 'OMATGICAN'  TO GT_UCOMM.   "기존 자재 투입 취소
      APPEND 'TRAORDDEL'  TO GT_UCOMM.   "변환 생산오더 삭제 설정
      APPEND 'STKCONFCAN' TO GT_UCOMM.   "재고 확정 취소
      IF P_HALB EQ GC_X.
        APPEND 'BATCHCRE'   TO GT_UCOMM.   "배치번호 생성
      ENDIF.
      SET TITLEBAR '0101'.
    WHEN P_R3. "재고변환결과조회/취소
      APPEND 'STKCONF'    TO GT_UCOMM.   "재고 확정
      APPEND 'BATCHCRE'   TO GT_UCOMM.   "배치번호 생성
      APPEND 'TRAORDCRE'  TO GT_UCOMM.   "변환 생산오더 생성
      APPEND 'OMATGI'     TO GT_UCOMM.   "기존 자재 투입 처리
      APPEND 'NMATGR'     TO GT_UCOMM.   "신규 자재 입고 처리
      SET TITLEBAR '0102'.
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
    PERFORM SET_FIELDCAT_GRID_0100.
    PERFORM EXCLUDE_OF_TOOLBAR_GRID_0100.
    PERFORM SET_EVENT_GRID_0100 USING GO_GRID_0100.
    PERFORM SET_SORTTAB_GRID_0100.
    PERFORM CALL_GRID_0100_DISPLAY.
  ENDIF.
ENDMODULE.
