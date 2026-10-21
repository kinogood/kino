*&---------------------------------------------------------------------*
*& Include          ZGTPPR3070I01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  EXIT_COMMAND  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE EXIT_COMMAND INPUT.
  CASE GV_OK_CODE.
    WHEN 'BACK' OR 'EXIT' OR 'CANC'.
      PERFORM CLS_OBJT_RTN.
*SRM2510-03432
      IF GV_OK_CODE EQ 'BACK' OR GV_OK_CODE EQ 'EXIT'.
          PERFORM DEQUEUE_OBJ.
      ENDIF.
*SRM2510-03432
      LEAVE TO SCREEN 0.
  ENDCASE.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0100 INPUT.
  CASE GV_OK_CODE.
    WHEN 'ORDCRE'.
      PERFORM PROCESS_ORDCRE.      "생산오더생성
    WHEN 'ITEMCHK'.
      PERFORM PROCESS_ITEMCHK.     "구성부품확인
    WHEN 'ITEMCRE'.
      PERFORM PROCESS_ITEMCRE.     "구성부품등록
*    WHEN 'ORDUPD'.
*      PERFORM PROCESS_ORDUPD.      "생산오더 업데이트 반영
    WHEN 'ORDITEMCRE'.
      PERFORM PROCESS_ORDITEMCRE.  "생산오더생성 및 구성부품등록
    WHEN 'ORDDEL'.
      PERFORM PROCESS_ORDDEL.      "생산오더삭제
    WHEN 'JOBNOEXC'.
      PERFORM PROCESS_JOBNOEXC.    "선택한 제번 조회 제외
    WHEN 'JOBNOEXCCAN'.
      PERFORM PROCESS_JOBNOEXCCAN. "조회 제외 취소
  ENDCASE.
ENDMODULE.
