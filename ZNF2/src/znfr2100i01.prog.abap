*----------------------------------------------------------------------*
***INCLUDE ZNFR2100I01 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  EXIT  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE EXIT INPUT.

  CASE OK_CODE.
    WHEN 'BACK' OR 'EXIT' OR 'CANC'.
      CLEAR : OK_CODE.

      LEAVE TO SCREEN 0.

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

  PERFORM GET_SELECTED_ROWS.

  CASE OK_SAVE.
    WHEN 'SAVE'.     "저장
      PERFORM SAVE_FUTURES_REQUEST USING ' '.

    WHEN 'REQT'.     "결재요청
      IF GV_SAVE = 'X'.
        PERFORM APPROVE_REQUEST.
      ELSE.
        PERFORM SAVE_FUTURES_REQUEST USING 'X'.
      ENDIF.

    WHEN 'BACK' OR 'EXIT' OR 'CANC'.
      LEAVE TO SCREEN 0.

  ENDCASE.

ENDMODULE.                 " USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*&      Module  F4HELP_NFCTR  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE F4HELP_NFCTR INPUT.

  CLEAR   : GT_NFCTR.
  REFRESH : GT_NFCTR.

  SELECT NFCTR
         NTEXT
    INTO TABLE GT_NFCTR
    FROM ZNFT0005
   WHERE BUKRS = P_BUKRS.   "회사코드

  IF SY-SUBRC <> 0.
    MESSAGE I002 WITH P_BUKRS '회사코드에 해당하는 사업부가 없습니다.'.
  ELSE.
    CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
      EXPORTING
        RETFIELD     = 'NFCTR'
        DYNPPROG     = SY-CPROG
        DYNPNR       = SY-DYNNR
        DYNPROFIELD  = 'GV_NFCTR'
        WINDOW_TITLE = '사업부'
        VALUE_ORG    = 'S'
      TABLES
        VALUE_TAB    = GT_NFCTR.

    IF SY-SUBRC <> 0.
      MESSAGE ID SY-MSGID
            TYPE SY-MSGTY
          NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.
  ENDIF.

ENDMODULE.                 " F4HELP_NFCTR  INPUT
*&---------------------------------------------------------------------*
*&      Module  F4HELP_PRCTR  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE F4HELP_PRCTR INPUT.

  CLEAR   : SCR_FIELDS, GT_PRCTR.
  REFRESH : SCR_FIELDS, GT_PRCTR.

*___화면상의 사업부를 읽는다.
  SCR_FIELDS-FIELDNAME = 'GV_NFCTR'.
  APPEND SCR_FIELDS.

  CALL FUNCTION 'DYNP_VALUES_READ'
    EXPORTING
      DYNAME     = SY-CPROG
      DYNUMB     = SY-DYNNR
    TABLES
      DYNPFIELDS = SCR_FIELDS.

  READ TABLE SCR_FIELDS WITH KEY FIELDNAME = 'GV_NFCTR'.
  GV_NFCTR = SCR_FIELDS-FIELDVALUE.

  PERFORM CONVERSION_EXIT_ALPHA USING 'I'
                                      GV_NFCTR.

  SELECT PRCTR
*         PTEXT
    INTO CORRESPONDING FIELDS OF TABLE GT_PRCTR
    FROM ZNFT0004
   WHERE KOKRS   = GV_KOKRS  "관리회계영역
     AND NFCTR   = GV_NFCTR  "사업부
     AND BDATU  >= SY-DATLO  "효력만료일
     AND CFACTIV = 'X'.      "선물요청(활성)

  IF SY-SUBRC <> 0.
    MESSAGE I000 WITH '사업부에 해당하는 손익센터가 없습니다.'.
  ELSE.
    LOOP AT GT_PRCTR.
      PERFORM GET_PRCTR_DESC USING GV_KOKRS
                                   GT_PRCTR-PRCTR
                                   GT_PRCTR-PTEXT.

      MODIFY GT_PRCTR.
    ENDLOOP.

    CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
      EXPORTING
        RETFIELD     = 'PRCTR'
        DYNPPROG     = SY-CPROG
        DYNPNR       = SY-DYNNR
        DYNPROFIELD  = 'GV_PRCTR'
        WINDOW_TITLE = '손익센터'
        VALUE_ORG    = 'S'
      TABLES
        VALUE_TAB    = GT_PRCTR.

    IF SY-SUBRC <> 0.
      MESSAGE ID SY-MSGID
            TYPE SY-MSGTY
          NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.
  ENDIF.

ENDMODULE.                 " F4HELP_PRCTR  INPUT
*&---------------------------------------------------------------------*
*&      Module  F4HELP_VKGRP  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE F4HELP_VKGRP INPUT.

  CLEAR   : SCR_FIELDS, GT_VKGRP.
  REFRESH : SCR_FIELDS, GT_VKGRP.

*___화면상의 손익센터를 읽는다.
  SCR_FIELDS-FIELDNAME = 'GV_PRCTR'.
  APPEND SCR_FIELDS.

  CALL FUNCTION 'DYNP_VALUES_READ'
    EXPORTING
      DYNAME     = SY-CPROG
      DYNUMB     = SY-DYNNR
    TABLES
      DYNPFIELDS = SCR_FIELDS.

  READ TABLE SCR_FIELDS WITH KEY FIELDNAME = 'GV_PRCTR'.
  GV_PRCTR = SCR_FIELDS-FIELDVALUE.

  PERFORM CONVERSION_EXIT_ALPHA USING 'I'
                                      GV_PRCTR.

  SELECT VKGRP
*         VTEXT
    INTO CORRESPONDING FIELDS OF TABLE GT_VKGRP
    FROM ZNFT0003
   WHERE KOKRS = P_BUKRS   "회사코드
     AND PRCTR = GV_PRCTR.

  IF SY-SUBRC <> 0.
    MESSAGE I000 WITH '손익센터에 해당하는 영업그룹이 없습니다.'.
  ELSE.
    LOOP AT GT_VKGRP.
      PERFORM GET_VKGRP_DESC USING P_BUKRS
                                   GT_VKGRP-VKGRP
                                   GT_VKGRP-VTEXT.

      MODIFY GT_VKGRP.
    ENDLOOP.

    CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
      EXPORTING
        RETFIELD     = 'VKGRP'
        DYNPPROG     = SY-CPROG
        DYNPNR       = SY-DYNNR
        DYNPROFIELD  = 'GV_VKGRP'
        WINDOW_TITLE = '영업그룹'
        VALUE_ORG    = 'S'
      TABLES
        VALUE_TAB    = GT_VKGRP.

    IF SY-SUBRC <> 0.
      MESSAGE ID SY-MSGID
            TYPE SY-MSGTY
          NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.
  ENDIF.

ENDMODULE.                 " F4HELP_VKGRP  INPUT
*&---------------------------------------------------------------------*
*&      Module  CHECK_NFCTR  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CHECK_NFCTR INPUT.

  PERFORM GET_NFCTR_DESC USING P_BUKRS
                               GV_NFCTR
                               GV_NTEXT.

ENDMODULE.                 " CHECK_NFCTR  INPUT
*&---------------------------------------------------------------------*
*&      Module  CHECK_PRCTR  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CHECK_PRCTR INPUT.

  PERFORM GET_PRCTR_DESC USING GV_KOKRS
                               GV_PRCTR
                               GV_PTEXT.

ENDMODULE.                 " CHECK_PRCTR  INPUT
*&---------------------------------------------------------------------*
*&      Module  CHECK_VKGRP  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CHECK_VKGRP INPUT.

  PERFORM GET_VKGRP_DESC USING GV_KOKRS
                               GV_VKGRP
                               GV_VTEXT.

ENDMODULE.                 " CHECK_VKGRP  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0200  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0200 INPUT.

  CASE OK_SAVE.
    WHEN 'CONT' OR 'CANC'.
      LEAVE TO SCREEN 0.

  ENDCASE.

ENDMODULE.                 " USER_COMMAND_0200  INPUT
*&---------------------------------------------------------------------*
*&      Module  CHECK_PERNR  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CHECK_PERNR INPUT.

  PERFORM CHECK_APPLOVAL_USER USING GV_PERNR.

ENDMODULE.                 " CHECK_PERNR  INPUT
*&---------------------------------------------------------------------*
*&      Module  EXIT_0200  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE EXIT_0200 INPUT.

  CASE OK_CODE.
    WHEN 'CONT' OR 'CANC'.
      OK_SAVE = OK_CODE.

      CLEAR : OK_CODE.

      LEAVE TO SCREEN 0.

  ENDCASE.

ENDMODULE.                 " EXIT_0200  INPUT
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
*   WHERE A~BUKRS =  P_BUKRS
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
   WHERE A~BUKRS =  P_BUKRS
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
