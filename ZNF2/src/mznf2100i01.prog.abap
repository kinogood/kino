*&---------------------------------------------------------------------*
*&  Include           MZNF2100I01
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
        PERFORM DEQUEUE_ZNFT1010.
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
      PERFORM GET_FUTURES_REQ_DATA.

      IF GV_ERROR = 'X' AND SY-CALLD = 'X'.
        LEAVE PROGRAM.
      ENDIF.

    WHEN 'SAVE'.    "저장
      PERFORM SAVE_FUTURES_REQUEST USING ' '.

    WHEN 'REQT'.    "결재요청
      PERFORM SAVE_FUTURES_REQUEST USING 'X'.

    WHEN 'DELE'.    "삭제
      PERFORM DELETE_FUTURES_REQ.

    WHEN 'RADD'.    "행추가
      PERFORM APPEND_ROW.

    WHEN 'RDEL'.    "행삭제
      PERFORM DELETE_ROW.

    WHEN 'ASEL' OR 'DSEL'.  "전체선택/해제
      PERFORM SELECT_ALL.

    WHEN 'APLY'.    "일괄적용
      PERFORM APPLY_ALL.

    WHEN 'HIST'.    "변경이력
      PERFORM DISPLAY_CHANGE_HISTORY.

    WHEN 'BACK' OR 'EXIT' OR 'CANC'.
      IF SY-DYNNR = '0200'.
        PERFORM DEQUEUE_ZNFT1010.
      ENDIF.

      IF SY-CALLD = 'X'.
        LEAVE PROGRAM.
      ELSE.
        LEAVE TO SCREEN 0.
      ENDIF.

  ENDCASE.

ENDMODULE.                 " USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*&      Module  F4HELP_ENDMM  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE F4HELP_ENDMM INPUT.

  CALL FUNCTION 'POPUP_TO_SELECT_MONTH'
    EXPORTING
      ACTUAL_MONTH   = SY-DATLO(6)
    IMPORTING
      SELECTED_MONTH = GT_1011-ENDMM.

ENDMODULE.                 " F4HELP_ENDMM  INPUT
*&---------------------------------------------------------------------*
*&      Module  F4HELP_CONNO  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE F4HELP_CONNO INPUT.

  PERFORM F4HELP_CONNO USING ZNFT1010-RQTYP.

ENDMODULE.                 " F4HELP_CONNO  INPUT
*&---------------------------------------------------------------------*
*&      Module  GET_CONTRACT_INFO  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE GET_CONTRACT_INFO INPUT.

  PERFORM GET_CONTRACT_DATA USING GT_1011-CONNO
                                  GT_1011-NFCTR
                                  GT_1011-PRCTR
                                  GT_1011-VKGRP
                                  GT_1011-COTYP
                                  GT_1011-COTXT
                                  GT_1011-KUNNR
                                  GT_1011-NCUST
                                  GT_1011-SALER
                                  GV_ERROR.

  IF GV_ERROR IS INITIAL.
    IF GT_1011-COTYP = GV_RQTYP.
      PERFORM PRICE_CLASSIFICATION USING GT_1011-CONNO
                                         GT_1011-NFKEY
                                         GT_1011-PRIND
                                         GT_1011-SUJUP
                                         GV_ERROR.
      IF GV_ERROR IS NOT INITIAL.
        MESSAGE E003 WITH '계약번호-비철구분'
                          GT_1011-CONNO GT_1011-NFKEY
                          '이(가) 존재하지 않습니다.'.
      ENDIF.
    ELSEIF GT_1011-CONNO IS NOT INITIAL.
      MESSAGE E003 WITH '선물요청유형과 계약유형을'
                        '확인하시기 바랍니다.'.
    ENDIF.
  ELSE.
    IF GV_ERROR = 'X'.
      MESSAGE E003 WITH '계약번호' GT_1011-CONNO
                        '이(가) 존재하지 않습니다.'.
    ELSE.
      MESSAGE E003 WITH '계약번호' GT_1011-CONNO
                        '은(는) 취소되거나 마감된 계약번호입니다.'.
    ENDIF.
  ENDIF.

ENDMODULE.                 " GET_CONTRACT_INFO  INPUT
*&---------------------------------------------------------------------*
*&      Module  MODIFY_ITAB  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE MODIFY_ITAB INPUT.

  READ TABLE GT_1011 INTO GS_1011 INDEX TC1-CURRENT_LINE.
  IF SY-SUBRC = 0.
    PERFORM MOVE_CHANGED_DATA.

    GS_1011-AEDAT = SY-DATLO.
    GS_1011-AEZET = SY-TIMLO.
    GS_1011-AENAM = SY-UNAME.

    IF GS_1011-UPDKZ IS INITIAL.
      GS_1011-UPDKZ = 'U'.
    ENDIF.

    MODIFY GT_1011 FROM GS_1011 INDEX TC1-CURRENT_LINE.
  ELSE.
    CHECK GT_1011-NFKEY IS NOT INITIAL OR
          GT_1011-BY_SL IS NOT INITIAL OR
          GT_1011-ENDMM IS NOT INITIAL OR
          GT_1011-EMENG IS NOT INITIAL OR
          GT_1011-CONNO IS NOT INITIAL OR
          GT_1011-BIGO4 IS NOT INITIAL.

    CLEAR : GS_1011.

    PERFORM MOVE_CHANGED_DATA.

    PERFORM GET_NEXT_SEQ USING GS_1011-H_NO1.

    GS_1011-COTYP = GT_1011-COTYP.
    GS_1011-MEINS = 'TON'.
    GS_1011-WAERS = 'USD'.
    GS_1011-ERDAT = SY-DATLO.
    GS_1011-ERZET = SY-TIMLO.
    GS_1011-ERNAM = SY-UNAME.
    GS_1011-AEDAT = SY-DATLO.
    GS_1011-AEZET = SY-TIMLO.
    GS_1011-AENAM = SY-UNAME.
    GS_1011-UPDKZ = 'I'.

    APPEND GS_1011 TO GT_1011.
  ENDIF.

ENDMODULE.                 " MODIFY_ITAB  INPUT
*&---------------------------------------------------------------------*
*&      Module  CHECK_EXPIRE_MONTH  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CHECK_EXPIRE_MONTH INPUT.

  CHECK GT_1011-ENDMM IS NOT INITIAL.

  IF GT_1011-ENDMM < SY-DATLO(6).
    MESSAGE E001 WITH '만기월은 당월 이후로 입력해야 합니다.'.
  ENDIF.

  IF GT_1011-ENDMM+4(2) < '01' OR GT_1011-ENDMM+4(2) > '12'.
    MESSAGE E001 WITH '만기월을 점검하시기 바랍니다.'.
  ENDIF.

ENDMODULE.                 " CHECK_EXPIRE_MONTH  INPUT
*&---------------------------------------------------------------------*
*&      Module  CHECK_REQUEST_QTY  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CHECK_REQUEST_QTY INPUT.

  CLEAR : GV_DEC.

  GV_DEC = FRAC( GT_1011-EMENG ).

  IF GV_DEC IS NOT INITIAL.
    MESSAGE E001 WITH '요청수량은 정수로 입력해야 합니다.'.
  ENDIF.

ENDMODULE.                 " CHECK_REQUEST_QTY  INPUT
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
*&      Module  GET_CURSOR  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE GET_CURSOR INPUT.

  GET CURSOR FIELD GV_CURSOR LINE GV_CURLIN.

ENDMODULE.                 " GET_CURSOR  INPUT
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
*   WHERE A~BUKRS =  ZNFT1010-BUKRS
*     AND A~CONGB =  '2'
*     AND A~CONSQ =  '1'
*     AND A~LVORM =  ' '.

*- [MM] PA0001 테이블 대체
  SELECT A~PERNR
         B~ENAME
    INTO TABLE GT_PERNR
    FROM ZNFT1090 AS A
   INNER JOIN ZZPA0001 AS B
      ON A~PERNR =  B~PERNR
     AND B~ENDDA >= SY-DATLO
     AND B~BEGDA <= SY-DATLO
   WHERE A~BUKRS =  ZNFT1010-BUKRS
     AND A~CONGB =  '2'
     AND A~CONSQ =  '1'
     AND A~LVORM =  ' '.
*- [MM] PA0001 테이블 대체

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
*&      Module  DISPLAY_CONTRACT  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE DISPLAY_CONTRACT INPUT.

  CHECK GT_1011-CONNO IS NOT INITIAL.

  SET PARAMETER ID 'ZNFCON' FIELD GT_1011-CONNO.

  CALL TRANSACTION 'ZNF2M2003' AND SKIP FIRST SCREEN.

ENDMODULE.                 " DISPLAY_CONTRACT  INPUT
