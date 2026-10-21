*&---------------------------------------------------------------------*
*& Include          ZGTPPR4000I01
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
    WHEN 'ORDDLV'.
      PERFORM PROCESS_ORD_DLV.        "납품완료지시자 설정
    WHEN 'FORDCRE'.
      PERFORM PROCESS_FORD_CREATE.    "후속 생산오더 생성
    WHEN 'ITEMCHK'.
      PERFORM PROCESS_ITEMCHK.        "구성부품확인
    WHEN 'FORDDEL'.
      PERFORM PROCESS_FORD_DELETE.    "후속 생산오더 TECO 설정
    WHEN 'ORDDLVCAN'.
      PERFORM PROCESS_ORD_DLV_CANC.   "납품완료지시자 설정 해제
  ENDCASE.
ENDMODULE.
