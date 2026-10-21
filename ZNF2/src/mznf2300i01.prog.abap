*&---------------------------------------------------------------------*
*&  Include           MZNF2300I01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  EXIT  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE EXIT INPUT.

  CASE OK_CODE.
    WHEN 'BACK' OR 'EXIT' OR 'CANC'.
      CLEAR : OK_CODE.

      IF SY-DYNNR = '0200'.
        PERFORM DEQUEUE_ZNFT1040.
        PERFORM DEQUEUE_ZNFT1020.
      ENDIF.

      IF SY-CALLD = 'X'.
        LEAVE PROGRAM.
      ELSE.
        LEAVE TO SCREEN 0.
      ENDIF.

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

  CASE OK_SAVE.
    WHEN 'ENTR'.
      PERFORM GET_SHIFT_REQ_DATA.

      IF GV_ERROR = 'X' AND SY-CALLD = 'X'.
        LEAVE PROGRAM.
      ENDIF.

    WHEN 'SAVE'.    "저장
      PERFORM SAVE_SHIFT_REQUEST USING ' '.

    WHEN 'REQT'.    "결재요청
      PERFORM SAVE_SHIFT_REQUEST USING 'X'.

    WHEN 'DELE'.    "삭제
      PERFORM DELETE_FUTURES_REQ.

    WHEN 'RADD'.    "행추가
      PERFORM APPEND_ROW.

    WHEN 'RDEL'.    "행삭제
      PERFORM DELETE_ROW.

    WHEN 'ASEL' OR 'DSEL'.  "전체선택/해제
      PERFORM SELECT_ALL.

    WHEN 'HIST'.    "변경이력
      PERFORM DISPLAY_CHANGE_HISTORY.

    WHEN 'BACK' OR 'EXIT' OR 'CANC'.
      IF SY-DYNNR = '0200'.
        PERFORM DEQUEUE_ZNFT1040.
        PERFORM DEQUEUE_ZNFT1020.
      ENDIF.

      IF SY-CALLD = 'X'.
        LEAVE PROGRAM.
      ELSE.
        LEAVE TO SCREEN 0.
      ENDIF.

  ENDCASE.

ENDMODULE.                 " USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*&      Module  GET_CURSOR  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE GET_CURSOR INPUT.

  GET CURSOR FIELD GV_CURSOR LINE GV_CURLIN.

ENDMODULE.                 " GET_CURSOR  INPUT
*&---------------------------------------------------------------------*
*&      Module  MODIFY_ITAB  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE MODIFY_ITAB INPUT.

  READ TABLE GT_1041 TRANSPORTING NO FIELDS
                     INDEX TC1-CURRENT_LINE.
  IF SY-SUBRC = 0.
    IF GT_1041-UPDKZ IS INITIAL.
      GT_1041-UPDKZ = 'U'.
    ENDIF.

    GT_1041-AENAM = SY-UNAME.
    GT_1041-AEDAT = SY-DATLO.
    GT_1041-AEZET = SY-TIMLO.

    MODIFY GT_1041 INDEX TC1-CURRENT_LINE
                   TRANSPORTING CHECK REMON RMENG UPDKZ
                                AENAM AEDAT AEZET.
  ELSE.
    CHECK GT_1041-REMON IS NOT INITIAL OR
          GT_1041-RMENG IS NOT INITIAL.

    PERFORM GET_NEXT_SEQ USING GT_1041-H_NO1.

    GT_1041-SHFNO = ZNFT1040-SHFNO.
    GT_1041-GUBUN = '1'.
*--> 비철 CME 관리 추가
*    GT_1041-MEINS = 'TON'.
    GT_1041-MEINS = ZNFT1020-MEINS. " 신규선물집행 단위 반영
*<-- 비철 CME 관리 추가
    GT_1041-WAERS = 'USD'.
    GT_1041-AENAM = SY-UNAME.
    GT_1041-ERDAT = SY-DATLO.
    GT_1041-ERZET = SY-TIMLO.
    GT_1041-ERNAM = SY-UNAME.
    GT_1041-AEDAT = SY-DATLO.
    GT_1041-AEZET = SY-TIMLO.

    GT_1041-UPDKZ = 'I'.

    APPEND GT_1041.
  ENDIF.

ENDMODULE.                 " MODIFY_ITAB  INPUT
*&---------------------------------------------------------------------*
*&      Module  CHECK_EXP_MONTH  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CHECK_EXP_MONTH INPUT.

  CHECK GT_1041-REMON IS NOT INITIAL.

  IF GT_1041-REMON < SY-DATLO(6).
    MESSAGE E003 WITH '만기월은 당월 이후로 입력해야 합니다.'.
  ENDIF.

*--> 유주수D 주석 요청 선처리. 이후 지토스 접수 예정
*  IF GT_1041-REMON = ZNFT1020-ENDAT(6).
*    MESSAGE E003 WITH '만기월이 신규선물집행의 만기월과 동일합니다.'.
*  ENDIF.
*<-- 유주수D 주석 요청 선처리. 이후 지토스 접수 예정

  IF GT_1041-REMON+4(2) < '01' OR GT_1041-REMON+4(2) > '12'.
    MESSAGE E001 WITH '만기월을 점검하시기 바랍니다.'.
  ENDIF.

ENDMODULE.                 " CHECK_EXP_MONTH  INPUT
*&---------------------------------------------------------------------*
*&      Module  EXIT_0300  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE EXIT_0300 INPUT.

  CASE OK_CODE.
    WHEN 'CONT' OR 'CANC'.
      OK_SAVE = OK_CODE.

      CLEAR : OK_CODE.

      LEAVE TO SCREEN 0.

  ENDCASE.

ENDMODULE.                 " EXIT_0300  INPUT
*&---------------------------------------------------------------------*
*&      Module  CHECK_PERNR  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CHECK_PERNR INPUT.

  PERFORM CHECK_APPLOVAL_USER USING GV_PERNR.

ENDMODULE.                 " CHECK_PERNR  INPUT
*&---------------------------------------------------------------------*
*&      Module  F4HELP_PERNR  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE F4HELP_PERNR INPUT.

  CLEAR   : GT_PERNR.
  REFRESH : GT_PERNR.

*  SELECT A~PERNR
*         B~ENAME
*    INTO TABLE GT_PERNR
*    FROM ZNFT1090 AS A
*   INNER JOIN PA0001 AS B
*      ON A~PERNR =  B~PERNR
*     AND B~ENDDA >= SY-DATLO
*     AND B~BEGDA <= SY-DATLO
*   WHERE A~BUKRS =  ZNFT1040-BUKRS
*     AND A~CONGB =  '5'
*     AND A~CONSQ =  '1'
*     AND A~LVORM =  ' '.

*- [MM] HR 테이블 대체
  SELECT A~PERNR
         B~ENAME
    INTO TABLE GT_PERNR
    FROM ZNFT1090 AS A
   INNER JOIN ZZPA0001 AS B
      ON A~PERNR =  B~PERNR
     AND B~ENDDA >= SY-DATLO
     AND B~BEGDA <= SY-DATLO
   WHERE A~BUKRS =  ZNFT1040-BUKRS
     AND A~CONGB =  '5'
     AND A~CONSQ =  '1'
     AND A~LVORM =  ' '.
*- [MM] HR 테이블 대체

  IF SY-SUBRC <> 0.
    MESSAGE I000 WITH '결재자 사번을 찾을수 없습니다.'.
  ELSE.
    SORT GT_PERNR BY ENAME.

    CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
      EXPORTING
        RETFIELD     = 'PERNR'
        DYNPPROG     = SY-CPROG
        DYNPNR       = SY-DYNNR
        DYNPROFIELD  = 'GV_PERNR'
        WINDOW_TITLE = '결재자사번'
        VALUE_ORG    = 'S'
      TABLES
        VALUE_TAB    = GT_PERNR.

    IF SY-SUBRC <> 0.
      MESSAGE ID SY-MSGID
            TYPE SY-MSGTY
          NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.
  ENDIF.

ENDMODULE.                 " F4HELP_PERNR  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0300  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0300 INPUT.

  CASE OK_SAVE.
    WHEN 'CONT' OR 'CANC'.
      LEAVE TO SCREEN 0.

  ENDCASE.

ENDMODULE.                 " USER_COMMAND_0300  INPUT
*&---------------------------------------------------------------------*
*&      Module  F4HELP_REMON  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE F4HELP_REMON INPUT.

  CALL FUNCTION 'POPUP_TO_SELECT_MONTH'
    EXPORTING
      ACTUAL_MONTH   = SY-DATLO(6)
    IMPORTING
      SELECTED_MONTH = GT_1041-REMON.

ENDMODULE.                 " F4HELP_REMON  INPUT
*&---------------------------------------------------------------------*
*&      Module  DISPLAY_REQUEST  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE DISPLAY_REQUEST INPUT.

  CHECK ZNFT1011-REQNO IS NOT INITIAL.

  SET PARAMETER ID 'ZNFREQ' FIELD ZNFT1011-REQNO.

  CALL TRANSACTION 'ZNF2M2103' AND SKIP FIRST SCREEN.

ENDMODULE.                 " DISPLAY_REQUEST  INPUT
*&---------------------------------------------------------------------*
*&      Module  DISPLAY_CONTRACT  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE DISPLAY_CONTRACT INPUT.

  CHECK ZNFT1000-CONNO IS NOT INITIAL.

  SET PARAMETER ID 'ZNFCON' FIELD ZNFT1000-CONNO.

  CALL TRANSACTION 'ZNF2M2003' AND SKIP FIRST SCREEN.

ENDMODULE.                 " DISPLAY_CONTRACT  INPUT
*&---------------------------------------------------------------------*
*&      Module  CHECK_REQUEST_QTY  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CHECK_REQUEST_QTY INPUT.

  CLEAR : GV_DEC.

  GV_DEC = FRAC( GT_1041-RMENG ).

  IF GV_DEC IS NOT INITIAL.
    MESSAGE E001 WITH '요청수량은 정수로 입력해야 합니다.'.
  ENDIF.

ENDMODULE.                 " CHECK_REQUEST_QTY  INPUT
*&---------------------------------------------------------------------*
*&      Module  DISPLAY_FUTURES_N  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE DISPLAY_FUTURES_N INPUT.

  IF ZNFT1020-NFUTN IS NOT INITIAL.
    PERFORM DISPLAY_FUTRUES_HISTORY USING 'N'
                                          ZNFT1020-NFUTN.
  ENDIF.

ENDMODULE.                 " DISPLAY_FUTURES_N  INPUT
*&---------------------------------------------------------------------*
*&      Module  DISPLAY_FUTURES_C  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE DISPLAY_FUTURES_C INPUT.

  IF ZNFT1030-CFUTN IS NOT INITIAL.
    PERFORM DISPLAY_FUTRUES_HISTORY USING 'C'
                                          ZNFT1030-CFUTN.
  ENDIF.

ENDMODULE.                 " DISPLAY_FUTURES_C  INPUT
*&---------------------------------------------------------------------*
*&      Module  DISPLAY_FUTURES_I  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE DISPLAY_FUTURES_I INPUT.

  IF GT_1041-NFUTN IS NOT INITIAL.
    PERFORM DISPLAY_FUTRUES_HISTORY USING 'N'
                                          GT_1041-NFUTN.
  ENDIF.

ENDMODULE.                 " DISPLAY_FUTURES_I  INPUT
