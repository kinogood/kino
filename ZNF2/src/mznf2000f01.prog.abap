*&---------------------------------------------------------------------*
*&  Include           MZNF2000F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  MOVE_CHANGED_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM MOVE_CHANGED_DATA .

  GS_ZNFT1001-CONNO = ZNFT1000-CONNO.
  GS_ZNFT1001-NFKEY = GT_ZNFT1001-NFKEY .
  GS_ZNFT1001-EMENG = GT_ZNFT1001-EMENG .
  GS_ZNFT1001-MEINS = GT_ZNFT1001-MEINS .
  GS_ZNFT1001-PRICE = GT_ZNFT1001-PRICE .
  GS_ZNFT1001-WAERS = GT_ZNFT1001-WAERS .
  GS_ZNFT1001-AVGPR = GT_ZNFT1001-AVGPR .
  GS_ZNFT1001-OFFCH = GT_ZNFT1001-OFFCH .
*  GS_ZNFT1001-CURPR = GT_ZNFT1001-CURPR .
  GS_ZNFT1001-BIGO4 = GT_ZNFT1001-BIGO4 .
  GS_ZNFT1001-CHECK = GT_ZNFT1001-CHECK .
  GS_ZNFT1001-DBCHK = GT_ZNFT1001-DBCHK .

ENDFORM.                    " MOVE_CHANGED_DATA
*&---------------------------------------------------------------------*
*&      Form  GET_FUTURES_REQ_DATA_100
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_FUTURES_REQ_DATA_100.

  CLEAR  : YZNFT1000, GT_ZNFT1001, GT_ZNFT1001N, GT_ZNFT1001D.
  REFRESH: GT_ZNFT1001, GT_ZNFT1001N, GT_ZNFT1001D, XGT_1001, YGT_1001.

  CLEAR : ZNFT1000, ZNFT1001, T001,
          ZNFT0003, ZNFT0004, ZNFT0005.

* 생성화면에 입력한 코드값
  ZNFT1000-BUKRS = GV_BUKRS.
  PERFORM GET_BUKRS_DESC USING GV_BUKRS T001-BUTXT.
  ZNFT1000-COTYP = GV_COTYP.
  ZNFT1000-WAERS = 'USD'.

* 회사코드 권한점검
  PERFORM CHECK_AUTHORIZATION USING ZNFT1000-BUKRS
                                    GV_ERROR.

  CHECK GV_ERROR IS INITIAL.

* 기본데이터 생성
  SELECT VALPOS     AS SEQ
         DOMVALUE_L AS NFKEY
         INTO CORRESPONDING FIELDS OF TABLE GT_NFKEY
    FROM DD07T
   WHERE DOMNAME    EQ 'ZNFKEY_1'
     AND DDLANGUAGE EQ SY-LANGU.

  IF GT_NFKEY[] IS NOT INITIAL.
    CLEAR GT_ZNFT1001. REFRESH GT_ZNFT1001.
    SORT GT_NFKEY BY SEQ.
    LOOP AT GT_NFKEY INTO GS_NFKEY.
      CONDENSE GS_NFKEY-NFKEY NO-GAPS.
      GS_ZNFT1001-NFKEY = GS_NFKEY-NFKEY.
*      GS_ZNFT1001-MEINS = 'TON'. " 비철 CME 관리
      GS_ZNFT1001-WAERS = 'USD'.
      GS_ZNFT1001-DBCHK = 'N'.    " ZNFT1001의 데이터가 아님
      APPEND GS_ZNFT1001 TO GT_ZNFT1001.
    ENDLOOP.
  ENDIF.

*---------------------------------------------------
* 변경이력 관리
*---------------------------------------------------
*             변경전      변경후
* - Header : ZNFT1000 >>> YNFT1000
* - Item   :
*---------------------------------------------------
* ### HEADER ###
  YZNFT1000 = ZNFT1000.

* ### ITEM ###
  LOOP AT GT_ZNFT1001.
    CLEAR : YGT_1001.
    MOVE-CORRESPONDING GT_ZNFT1001 TO YGT_1001.
    APPEND YGT_1001.
  ENDLOOP.

  IF GT_ZNFT1001[] IS NOT INITIAL.
    LOOP AT GT_ZNFT1001.
      MOVE-CORRESPONDING GT_ZNFT1001 TO GT_ZNFT1001.
      MODIFY GT_ZNFT1001 INDEX SY-TABIX.
    ENDLOOP.
  ENDIF.
*---------------------------------------------------

  GV_CURSOR = 'GT_ZNFT1001-NFKEY'.
  GV_CURLIN = 1.

  CALL SCREEN 0500.

ENDFORM.                    " GET_FUTURES_REQ_DATA_100
*&---------------------------------------------------------------------*
*&      Form  GET_FUTURES_REQ_DATA_200
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_FUTURES_REQ_DATA_200 .

  DATA: LV_CSTAT TYPE ZCSTAT.

  CLEAR  : YZNFT1000, GT_ZNFT1001, GT_ZNFT1001N, GT_ZNFT1001D.
  REFRESH: GT_ZNFT1001, GT_ZNFT1001N, GT_ZNFT1001D, XGT_1001, YGT_1001.

  CLEAR : ZNFT1000, ZNFT1001, T001,
          ZNFT0003, ZNFT0004, ZNFT0005.

* ### START : 계약번호 체크 ####
  CHECK GV_CONNO IS NOT INITIAL.

  SELECT SINGLE * FROM ZNFT1000
   WHERE CONNO EQ GV_CONNO.

  IF SY-SUBRC EQ 0.
*   회사코드
    PERFORM GET_BUKRS_DESC USING ZNFT1000-BUKRS
                                 T001-BUTXT.
*   사업부
    PERFORM GET_NFCTR_DESC USING ZNFT1000-BUKRS
                                 ZNFT1000-NFCTR
                                 ZNFT0005-NTEXT.
*   손익센터
    PERFORM GET_PRCTR_DESC USING ZNFT1000-BUKRS
                                 ZNFT1000-PRCTR
                                 ZNFT0004-PTEXT.
*   영업그룹
    PERFORM GET_VKGRP_DESC USING ZNFT1000-BUKRS
                                 ZNFT1000-VKGRP
                                 ZNFT0003-VTEXT.
*   고객
*    PERFORM GET_KUNNR_DESC USING ZNFT1000-KUNNR
*                                 ZNFT1000-NCUST.

*   수주계약 - ITEM
    SELECT * INTO CORRESPONDING FIELDS OF TABLE GT_ZNFT1001
      FROM ZNFT1001
     WHERE CONNO EQ ZNFT1000-CONNO.

    IF GT_ZNFT1001[] IS NOT INITIAL.
      LOOP AT GT_ZNFT1001.
        MOVE-CORRESPONDING GT_ZNFT1001 TO GT_ZNFT1001.
        GT_ZNFT1001-DBCHK = 'Y'.
        MODIFY GT_ZNFT1001 INDEX SY-TABIX.
      ENDLOOP.
    ENDIF.

  ELSE.
    GV_ERROR = 'X'.

    MESSAGE S003 DISPLAY LIKE 'E'
       WITH '계약번호' GV_CONNO '이(가) 존재하지 않습니다.'.
    EXIT.
  ENDIF.
* ### E N D : 계약번호 체크 ####

* ### 저장되지 않은 비철구분 데이터 추가 ###
  DATA: LV_NFKEY TYPE ZNFKEY1,
        LV_SEQ   TYPE SY-TABIX.

  SELECT VALPOS     AS SEQ
         DOMVALUE_L AS NFKEY
         INTO CORRESPONDING FIELDS OF TABLE GT_NFKEY
    FROM DD07T
   WHERE DOMNAME    EQ 'ZNFKEY_1'
     AND DDLANGUAGE EQ SY-LANGU.

  IF GT_NFKEY[] IS NOT INITIAL.
    SORT GT_NFKEY BY SEQ.
    LOOP AT GT_NFKEY INTO GS_NFKEY.
      CONDENSE GS_NFKEY-NFKEY NO-GAPS.
      LV_NFKEY = GS_NFKEY-NFKEY.
      LV_SEQ   = GS_NFKEY-SEQ.

      READ TABLE GT_ZNFT1001 INTO GS_ZNFT1001 WITH KEY CONNO = GV_CONNO
                                                       NFKEY = LV_NFKEY.
      IF SY-SUBRC EQ 0.
        GS_ZNFT1001-SEQ = LV_SEQ.
        MODIFY GT_ZNFT1001 FROM GS_ZNFT1001 TRANSPORTING SEQ
         WHERE CONNO EQ GV_CONNO
           AND NFKEY EQ LV_NFKEY.
      ELSE.
        CLEAR GS_ZNFT1001.
        GS_ZNFT1001-CONNO = GV_CONNO.
        GS_ZNFT1001-NFKEY = LV_NFKEY.
        GS_ZNFT1001-SEQ   = LV_SEQ.
*        GS_ZNFT1001-MEINS = 'TON'. "비철 CME 관리 위한 주석
        GS_ZNFT1001-WAERS = 'USD'.
        GS_ZNFT1001-DBCHK = 'N'.    " ZNFT1001의 데이터가 아님
        APPEND GS_ZNFT1001 TO GT_ZNFT1001.
      ENDIF.
    ENDLOOP.
  ENDIF.

  IF GT_ZNFT1001[] IS NOT INITIAL.
    SORT GT_ZNFT1001 BY SEQ.
  ENDIF.

* ### START : 변경시 계약상태 체크 ####
  SELECT SINGLE CSTAT INTO LV_CSTAT
    FROM ZNFT1000
   WHERE CONNO EQ GV_CONNO.

  IF LV_CSTAT NE 'L'.
    CASE LV_CSTAT.
      WHEN 'C'.
        GV_ERROR = 'X'.

        MESSAGE S003 DISPLAY LIKE 'E'
           WITH '계약번호' GV_CONNO '은 이미 취소된 계약번호입니다.'.
        EXIT.
      WHEN 'F'.
        GV_ERROR = 'X'.

        MESSAGE S003 DISPLAY LIKE 'E'
           WITH '계약번호' GV_CONNO '은 이미 마감된 계약번호입니다.'.
        EXIT.
    ENDCASE.
  ENDIF.

* ### E N D : 변경시 계약상태 체크 ####

* 계약번호 잠금
  PERFORM ENQUEUE_ZNFT1000 USING GV_ERROR.
  CHECK GV_ERROR IS INITIAL.

* 회사코드 권한점검
  PERFORM CHECK_AUTHORIZATION USING ZNFT1000-BUKRS
                                    GV_ERROR.

  CHECK GV_ERROR IS INITIAL.

*---------------------------------------------------
* 변경이력 관리
*---------------------------------------------------
*             변경전      변경후
* - Header : ZNFT1000 >>> YNFT1000
* - Item   :
*---------------------------------------------------
* ### HEADER ###
  YZNFT1000 = ZNFT1000.

* ### ITEM ###
  LOOP AT GT_ZNFT1001.
    CLEAR : YGT_1001.
    MOVE-CORRESPONDING GT_ZNFT1001 TO YGT_1001.
    APPEND YGT_1001.
  ENDLOOP.


* 첨부파일 정보 정보
  SELECT SINGLE * INTO GS_FILEM
    FROM ZNFT1002
   WHERE CONNO EQ GV_CONNO.

  GS_ZNFT1002Y = GS_FILEM.
*---------------------------------------------------

  GV_CURSOR = 'GT_ZNFT1001-NFKEY'.
  GV_CURLIN = 1.

  CALL SCREEN 0500.

ENDFORM.                    " GET_FUTURES_REQ_DATA_200
*&---------------------------------------------------------------------*
*&      Form  GET_FUTURES_REQ_DATA_300
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_FUTURES_REQ_DATA_300 .

  DATA: LV_CSTAT TYPE ZCSTAT.

  CLEAR  : YZNFT1000, GT_ZNFT1001, GT_ZNFT1001N, GT_ZNFT1001D.
  REFRESH: GT_ZNFT1001, GT_ZNFT1001N, GT_ZNFT1001D, XGT_1001, YGT_1001.

  CLEAR : ZNFT1000, ZNFT1001, T001,
          ZNFT0003, ZNFT0004, ZNFT0005.

* ### START : 계약번호 체크 ####
  CHECK GV_CONNO IS NOT INITIAL.

  SELECT SINGLE * FROM ZNFT1000
   WHERE CONNO EQ GV_CONNO.

  IF SY-SUBRC EQ 0.
*   회사코드
    PERFORM GET_BUKRS_DESC USING ZNFT1000-BUKRS
                                 T001-BUTXT.
*   사업부
    PERFORM GET_NFCTR_DESC USING ZNFT1000-BUKRS
                                 ZNFT1000-NFCTR
                                 ZNFT0005-NTEXT.
*   손익센터
    PERFORM GET_PRCTR_DESC USING ZNFT1000-BUKRS
                                 ZNFT1000-PRCTR
                                 ZNFT0004-PTEXT.
*   영업그룹
    PERFORM GET_VKGRP_DESC USING ZNFT1000-BUKRS
                                 ZNFT1000-VKGRP
                                 ZNFT0003-VTEXT.
*   고객
*    PERFORM GET_KUNNR_DESC USING ZNFT1000-KUNNR
*                                 ZNFT1000-NCUST.

*   수주계약 - ITEM
    SELECT * INTO CORRESPONDING FIELDS OF TABLE GT_ZNFT1001
      FROM ZNFT1001
     WHERE CONNO EQ GV_CONNO.

    IF GT_ZNFT1001[] IS NOT INITIAL.
      LOOP AT GT_ZNFT1001.
        MOVE-CORRESPONDING GT_ZNFT1001 TO GT_ZNFT1001.
        GT_ZNFT1001-DBCHK = 'Y'.
        MODIFY GT_ZNFT1001 INDEX SY-TABIX.
      ENDLOOP.
    ENDIF.

  ELSE.
    GV_ERROR = 'X'.

    MESSAGE S003 DISPLAY LIKE 'E'
       WITH '계약번호' GV_CONNO '이(가) 존재하지 않습니다.'.
    EXIT.
  ENDIF.
* ### E N D : 계약번호 체크 ####

* ### START : 변경시 계약상태 체크 ####
  SELECT SINGLE CSTAT INTO LV_CSTAT
    FROM ZNFT1000
   WHERE CONNO EQ GV_CONNO.

  IF LV_CSTAT NE 'L'.
    CASE LV_CSTAT.
      WHEN 'C'.
        GV_ERROR = 'X'.

        MESSAGE S003 DISPLAY LIKE 'E'
           WITH '계약번호' GV_CONNO '은 이미 취소된 계약번호입니다.'.
        EXIT.
      WHEN 'F'.
        GV_ERROR = 'X'.

        MESSAGE S003 DISPLAY LIKE 'E'
           WITH '계약번호' GV_CONNO '은 이미 마감된 계약번호입니다.'.
        EXIT.
    ENDCASE.
  ENDIF.

* ### E N D : 변경시 계약상태 체크 ####

* ### 저장되지 않은 비철구분 데이터 추가 ###
  DATA: LV_NFKEY TYPE ZNFKEY1,
        LV_SEQ   TYPE SY-TABIX.

  SELECT VALPOS     AS SEQ
         DOMVALUE_L AS NFKEY
         INTO CORRESPONDING FIELDS OF TABLE GT_NFKEY
    FROM DD07T
   WHERE DOMNAME    EQ 'ZNFKEY_1'
     AND DDLANGUAGE EQ SY-LANGU.

  IF GT_NFKEY[] IS NOT INITIAL.
    SORT GT_NFKEY BY SEQ.
    LOOP AT GT_NFKEY INTO GS_NFKEY.
      CONDENSE GS_NFKEY-NFKEY NO-GAPS.
      LV_NFKEY = GS_NFKEY-NFKEY.
      LV_SEQ   = GS_NFKEY-SEQ.

      READ TABLE GT_ZNFT1001 INTO GS_ZNFT1001 WITH KEY CONNO = GV_CONNO
                                                       NFKEY = LV_NFKEY.
      IF SY-SUBRC EQ 0.
        GS_ZNFT1001-SEQ = LV_SEQ.
        MODIFY GT_ZNFT1001 FROM GS_ZNFT1001 TRANSPORTING SEQ
         WHERE CONNO EQ GV_CONNO
           AND NFKEY EQ LV_NFKEY.
      ELSE.
        CLEAR GS_ZNFT1001.
        GS_ZNFT1001-CONNO = GV_CONNO.
        GS_ZNFT1001-NFKEY = LV_NFKEY.
        GS_ZNFT1001-SEQ   = LV_SEQ.
*        GS_ZNFT1001-MEINS = 'TON'. "비철 CME 관리 위한 주석
        GS_ZNFT1001-WAERS = 'USD'.
        GS_ZNFT1001-DBCHK = 'N'.    " ZNFT1001의 데이터가 아님
        APPEND GS_ZNFT1001 TO GT_ZNFT1001.
      ENDIF.
    ENDLOOP.
  ENDIF.

  IF GT_ZNFT1001[] IS NOT INITIAL.
    SORT GT_ZNFT1001 BY SEQ.
  ENDIF.

* 계약번호 잠금
  PERFORM ENQUEUE_ZNFT1000 USING GV_ERROR.
  CHECK GV_ERROR IS INITIAL.

* 회사코드 권한점검
  PERFORM CHECK_AUTHORIZATION USING ZNFT1000-BUKRS
                                    GV_ERROR.

  CHECK GV_ERROR IS INITIAL.

*---------------------------------------------------
* 변경이력 관리
*---------------------------------------------------
*             변경전      변경후
* - Header : ZNFT1000 >>> YNFT1000
* - Item   :
*---------------------------------------------------
* ### HEADER ###
  YZNFT1000 = ZNFT1000.

* ### ITEM ###
  LOOP AT GT_ZNFT1001.
    CLEAR : YGT_1001.
    MOVE-CORRESPONDING GT_ZNFT1001 TO YGT_1001.
    APPEND YGT_1001.
  ENDLOOP.

* 첨부파일 정보 정보
  SELECT SINGLE * INTO GS_FILEM
    FROM ZNFT1002
   WHERE CONNO EQ GV_CONNO.

  GS_ZNFT1002Y = GS_FILEM.
*---------------------------------------------------

  GV_CURSOR = 'GT_ZNFT1001-NFKEY'.
  GV_CURLIN = 1.

  CALL SCREEN 0500.

ENDFORM.                    " GET_FUTURES_REQ_DATA_300
*&---------------------------------------------------------------------*
*&      Form  GET_FUTURES_REQ_DATA_400
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_FUTURES_REQ_DATA_400 .

  DATA: LV_CSTAT TYPE ZCSTAT.

  CLEAR  : YZNFT1000, GT_ZNFT1001, GT_ZNFT1001N, GT_ZNFT1001D.
  REFRESH: GT_ZNFT1001, GT_ZNFT1001N, GT_ZNFT1001D, XGT_1001, YGT_1001.

  CLEAR : ZNFT1000, ZNFT1001, T001,
          ZNFT0003, ZNFT0004, ZNFT0005.

* ### START : 계약번호 체크 ####
  CHECK GV_CONNO IS NOT INITIAL.

  SELECT SINGLE * FROM ZNFT1000
   WHERE CONNO EQ GV_CONNO.

  IF SY-SUBRC EQ 0.
*   회사코드
    PERFORM GET_BUKRS_DESC USING ZNFT1000-BUKRS
                                 T001-BUTXT.
*   사업부
    PERFORM GET_NFCTR_DESC USING ZNFT1000-BUKRS
                                 ZNFT1000-NFCTR
                                 ZNFT0005-NTEXT.
*   손익센터
    PERFORM GET_PRCTR_DESC USING ZNFT1000-BUKRS
                                 ZNFT1000-PRCTR
                                 ZNFT0004-PTEXT.
*   영업그룹
    PERFORM GET_VKGRP_DESC USING ZNFT1000-BUKRS
                                 ZNFT1000-VKGRP
                                 ZNFT0003-VTEXT.
*   고객
*    PERFORM GET_KUNNR_DESC USING ZNFT1000-KUNNR
*                                 ZNFT1000-NCUST.

*   수주계약 - ITEM
    SELECT * INTO CORRESPONDING FIELDS OF TABLE GT_ZNFT1001
      FROM ZNFT1001
     WHERE CONNO EQ GV_CONNO.
  ELSE.
    GV_ERROR = 'X'.

    MESSAGE S003 DISPLAY LIKE 'E'
       WITH '계약번호' GV_CONNO '이(가) 존재하지 않습니다.'.
    EXIT.
  ENDIF.
* ### E N D : 계약번호 체크 ####

  DATA: LV_NFKEY TYPE ZNFKEY1,
        LV_SEQ   TYPE SY-TABIX.

  SELECT VALPOS     AS SEQ
         DOMVALUE_L AS NFKEY
         INTO CORRESPONDING FIELDS OF TABLE GT_NFKEY
    FROM DD07T
   WHERE DOMNAME    EQ 'ZNFKEY_1'
     AND DDLANGUAGE EQ SY-LANGU.

  IF GT_NFKEY[] IS NOT INITIAL.
    SORT GT_NFKEY BY SEQ.
    LOOP AT GT_NFKEY INTO GS_NFKEY.
      CONDENSE GS_NFKEY-NFKEY NO-GAPS.
      LV_NFKEY = GS_NFKEY-NFKEY.
      LV_SEQ   = GS_NFKEY-SEQ.

      READ TABLE GT_ZNFT1001 INTO GS_ZNFT1001 WITH KEY CONNO = GV_CONNO
                                                       NFKEY = LV_NFKEY.
      IF SY-SUBRC EQ 0.
        GS_ZNFT1001-SEQ = LV_SEQ.
        MODIFY GT_ZNFT1001 FROM GS_ZNFT1001 TRANSPORTING SEQ
         WHERE CONNO EQ GV_CONNO
           AND NFKEY EQ LV_NFKEY.
      ELSE.
        CLEAR GS_ZNFT1001.
        GS_ZNFT1001-CONNO = GV_CONNO.
        GS_ZNFT1001-NFKEY = LV_NFKEY.
        GS_ZNFT1001-SEQ   = LV_SEQ.
*        GS_ZNFT1001-MEINS = 'TON'. "비철 CME 관리 주석 처리
        GS_ZNFT1001-WAERS = 'USD'.
        GS_ZNFT1001-DBCHK = 'N'.    " ZNFT1001의 데이터가 아님
        APPEND GS_ZNFT1001 TO GT_ZNFT1001.
      ENDIF.
    ENDLOOP.
  ENDIF.

  IF GT_ZNFT1001[] IS NOT INITIAL.
    SORT GT_ZNFT1001 BY SEQ.
  ENDIF.

* ### START : 변경시 계약상태 체크 ####
  SELECT SINGLE CSTAT INTO LV_CSTAT
    FROM ZNFT1000
   WHERE CONNO EQ GV_CONNO.

  IF LV_CSTAT NE 'L'.
    CASE LV_CSTAT.
      WHEN 'C'.
        MESSAGE S003 DISPLAY LIKE 'W'
           WITH '계약번호' GV_CONNO '은 이미 취소된 계약번호입니다.'.
      WHEN 'F'.
        MESSAGE S003 DISPLAY LIKE 'W'
           WITH '계약번호' GV_CONNO '은 이미 마감된 계약번호입니다.'.
    ENDCASE.
  ENDIF.

* ### E N D : 변경시 계약상태 체크 ####

  GV_CURSOR = 'GT_ZNFT1001-NFKEY'.
  GV_CURLIN = 1.

* 첨부파일 정보 정보
  SELECT SINGLE * INTO GS_FILEM
    FROM ZNFT1002
   WHERE CONNO EQ GV_CONNO.

  CALL SCREEN 0500.

ENDFORM.                    " GET_FUTURES_REQ_DATA_400

*&---------------------------------------------------------------------*
*&      Form  ENQUEUE_ZNFT1000
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM ENQUEUE_ZNFT1000 USING PV_ERROR.

  DATA: LV_MSGV1  LIKE SY-MSGV1.
  CLEAR : PV_ERROR.

  CALL FUNCTION 'ENQUEUE_EZ_ZNFT1000'
    EXPORTING
      CONNO          = GV_CONNO
    EXCEPTIONS
      FOREIGN_LOCK   = 1
      SYSTEM_FAILURE = 2
      OTHERS         = 3.

  IF SY-SUBRC <> 0.
    LV_MSGV1 = SY-MSGV1.
    PV_ERROR = 'X'.
    MESSAGE S003 DISPLAY LIKE 'E'
       WITH '계약번호' GV_CONNO
            '이(가) 현재 처리중입니다. 사용자:' LV_MSGV1.
  ENDIF.

ENDFORM.                    " ENQUEUE_ZNFT1000

*&---------------------------------------------------------------------*
*&      Form  DEQUEUE_ZNFT1000
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM DEQUEUE_ZNFT1000 .

  CALL FUNCTION 'DEQUEUE_EZ_ZNFT1000'
    EXPORTING
      CONNO = ZNFT1000-CONNO.

ENDFORM.                    " DEQUEUE_ZNFT1000

*&---------------------------------------------------------------------*
*&      Form  DATA_SAVE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM DATA_SAVE .

* Table Control Data Check
  CLEAR GV_ERROR.

* 필수입력 데이터 체크
  PERFORM CHECK_ITEM_DATA USING GV_ERROR.

  CHECK GV_ERROR IS INITIAL.

* 영업이익률이 비어 있을경우 확인메시지
* (계약유형이 경상수지, 재고헷지가 아닌경우)
  IF NOT ( ZNFT1000-COTYP EQ '3' OR ZNFT1000-COTYP EQ '5' ).
    IF ZNFT1000-PRATE IS INITIAL.
      PERFORM POPUP_TO_CONFIRM USING
             '확인'
             '영업이익률(%)이 비어있습니다 저장하시겠습니까?'
             '1'
             GV_ANSWER.

      CHECK GV_ANSWER EQ '1'.
    ENDIF.
  ENDIF.

  IF GS_FILEM IS INITIAL AND
     ( ZNFT1000-COTYP EQ '1' OR ZNFT1000-COTYP EQ '2' OR
       ZNFT1000-COTYP EQ '4' ).

*   첨부파일 CHECK
*   계약유형이 Firm Price이거나 고객요청인 경우 파일이 첨부되지 않았을때
*   확인 메시지를 띄어준다
    PERFORM POPUP_TO_CONFIRM USING
           '확인'
           '계약서 또는 발주서가 첨부되지 않았습니다. 저장하시겠습니까?'
           '1'
           GV_ANSWER.

  ELSE.
*   확인 CHECK
    PERFORM POPUP_TO_CONFIRM USING
           '저장'
           '계약정보를 저장하시겠습니까?'
           '1'
           GV_ANSWER.
  ENDIF.

  IF GV_ANSWER EQ '1'.
    PERFORM DATA_SAVE_TABLE.
  ELSE.
    MESSAGE S001 WITH '작업이 취소되었습니다.'.
  ENDIF.

ENDFORM.                    " DATA_SAVE

*&---------------------------------------------------------------------*
*&      Form  DISPLAY_CHANGE_HISTORY
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM DISPLAY_CHANGE_HISTORY .

  DATA: LT_RSPAR LIKE RSPARAMS OCCURS 0 WITH HEADER LINE.

*- 2023.12.04 ZLSGMM4, 변경 이력 수정
  DATA: LV_OBJCLS   LIKE CDHDR-OBJECTCLAS.

  LV_OBJCLS = 'ZNFT1000CHDOC'.

  SELECT SINGLE OBJECTCLAS
    INTO LV_OBJCLS
    FROM CDHDR
   WHERE OBJECTCLAS = LV_OBJCLS
     AND OBJECTID   = ZNFT1000-CONNO.

  IF SY-SUBRC <> 0.
    MESSAGE S002 DISPLAY LIKE 'E'
       WITH '변경이력이 없습니다.'.

    EXIT.
  ENDIF.

  CLEAR   : LT_RSPAR.
  REFRESH : LT_RSPAR.

  LT_RSPAR-SELNAME = 'OBJEKT'.
  LT_RSPAR-KIND    = 'P'.
*  LT_RSPAR-LOW     = 'ZNFT1000CHDOC'.
  LT_RSPAR-LOW     = LV_OBJCLS.
  APPEND LT_RSPAR.

  CLEAR : LT_RSPAR.
  LT_RSPAR-SELNAME = 'OBJEKTID'.
  LT_RSPAR-KIND    = 'P'.
  LT_RSPAR-LOW     = ZNFT1000-CONNO.
  APPEND LT_RSPAR.

  CLEAR : LT_RSPAR.
  LT_RSPAR-SELNAME = 'AENDERER'.
  LT_RSPAR-KIND    = 'P'.
  LT_RSPAR-LOW     = ' '.
  APPEND LT_RSPAR.

  CLEAR : LT_RSPAR.
  LT_RSPAR-SELNAME = 'DATUM'.
  LT_RSPAR-KIND    = 'P'.
  LT_RSPAR-LOW     = ' '.
  APPEND LT_RSPAR.

*  SUBMIT RCS00120 WITH SELECTION-TABLE LT_RSPAR
*                   AND RETURN.

  SUBMIT RC1CD100 WITH SELECTION-TABLE LT_RSPAR
                   AND RETURN.
*- 2023.12.04 ZLSGMM4, 변경 이력 수정

ENDFORM.                    " DISPLAY_CHANGE_HISTORY
*&---------------------------------------------------------------------*
*&      Form  CHECK_ITEM_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GV_ERROR  text
*----------------------------------------------------------------------*
FORM CHECK_ITEM_DATA USING PV_ERROR.

  DATA: LV_CNT TYPE I.

  IF GT_ZNFT1001[] IS INITIAL.
    MESSAGE S003 DISPLAY LIKE 'E' WITH '계약-품목 정보가 없습니다.'.
    PV_ERROR = 'X'.
    EXIT.
  ENDIF.

* DB 반영할 건수 체크

  LV_CNT = 0.
* DB 반영할 건수 체크
  LOOP AT GT_ZNFT1001 INTO GS_ZNFT1001 WHERE UPDKZ NE SPACE.
    ADD 1 TO LV_CNT.
  ENDLOOP.

* DB저장된 데이터 체크
  LOOP AT GT_ZNFT1001 WHERE DBCHK EQ 'Y'.
    ADD 1 TO LV_CNT.
  ENDLOOP.

  IF LV_CNT EQ 0 OR LV_CNT IS INITIAL.
    MESSAGE S003 DISPLAY LIKE 'E'
       WITH '품목정보의 값이 존재하지 않습니다.'
            '품목을 입력하십시오'.
    PV_ERROR = 'X'.
    EXIT.
  ENDIF.

* Header & Item & 첨부파일 변경된 데이터 체크
* -------------------------------------------
* GV_H_CHNG : Header Data 변경유무 체크
* LV_CNT    : 변경된 Item Data 체크
* GS_FILEM  : 첨부파일 체크
* -------------------------------------------
  IF LV_CNT EQ 0 AND GS_FILEM IS INITIAL AND GV_H_CHNG NE 'Y'.
    MESSAGE S003 DISPLAY LIKE 'S' WITH
    '변경한 데이터가 존재하지 않습니다.'.
    PV_ERROR = 'X'.
    EXIT.
  ENDIF.

* Header Data Check
* 필수입력(유형별) 데이터 체크
  IF ZNFT1000-BUKRS IS INITIAL.
    MESSAGE S003 DISPLAY LIKE 'E' WITH '회사코드는 필수입니다.'.
    PV_ERROR = 'X'.
    EXIT.
  ENDIF.
  IF ZNFT1000-NFCTR IS INITIAL.
    MESSAGE S003 DISPLAY LIKE 'E' WITH '사업부는 필수입니다.'.
    PV_ERROR = 'X'.
    EXIT.
  ENDIF.
  IF ZNFT1000-PRCTR IS INITIAL.
    MESSAGE S003 DISPLAY LIKE 'E' WITH '손익센터는 필수입니다.'.
    PV_ERROR = 'X'.
    EXIT.
  ENDIF.

  IF ZNFT1000-COTXT IS INITIAL.
    MESSAGE S003 DISPLAY LIKE 'E' WITH '계약명는 필수입니다.'.
    PV_ERROR = 'X'.
    EXIT.
  ENDIF.

* 계약유형 : 경상수지 & 재고햇지가 아닌경우 필수입력 필드 체크
  IF ( ZNFT1000-COTYP EQ '1' OR
       ZNFT1000-COTYP EQ '2' ).

*   손익센터
    IF ZNFT1000-PRCTR IS INITIAL OR ZNFT1000-PRCTR EQ SPACE.
      MESSAGE S003 DISPLAY LIKE 'E' WITH '손익센터는 필수입니다.'.
      PV_ERROR = 'X'.
      EXIT.
    ENDIF.

*   영업그룹
    IF ZNFT1000-VKGRP IS INITIAL OR ZNFT1000-VKGRP EQ SPACE.
      MESSAGE S003 DISPLAY LIKE 'E' WITH '영업그룹은 필수입니다.'.
      PV_ERROR = 'X'.
      EXIT.
    ENDIF.

*   고객명
    IF ZNFT1000-NCUST IS INITIAL OR ZNFT1000-NCUST EQ SPACE.
      MESSAGE S003 DISPLAY LIKE 'E' WITH '고객명은 필수입니다.'.
      PV_ERROR = 'X'.
      EXIT.
    ENDIF.

*   수주일
    IF ZNFT1000-SUJUD IS INITIAL OR ZNFT1000-SUJUD EQ SPACE.
      MESSAGE S003 DISPLAY LIKE 'E' WITH '수주일는 필수입니다.'.
      PV_ERROR = 'X'.
      EXIT.
    ENDIF.

*   수주금액
    IF ZNFT1000-PRICE IS INITIAL OR ZNFT1000-PRICE EQ SPACE.
      MESSAGE S003 DISPLAY LIKE 'E' WITH '수주금액은 필수입니다.'.
      PV_ERROR = 'X'.
      EXIT.
    ENDIF.

*   통화
    IF ZNFT1000-WAERS IS INITIAL OR ZNFT1000-WAERS EQ SPACE.
      MESSAGE S003 DISPLAY LIKE 'E' WITH '수주통화는 필수입니다.'.
      PV_ERROR = 'X'.
      EXIT.
    ENDIF.

*   영업담당자
    IF ZNFT1000-SALER IS INITIAL OR ZNFT1000-SALER EQ SPACE.
      MESSAGE S003 DISPLAY LIKE 'E' WITH '영업담당자는 필수입니다.'.
      PV_ERROR = 'X'.
      EXIT.
    ENDIF.
  ENDIF.

* Item   Data Check
  DATA: LV_FIELD_EXIST TYPE I.
  CLEAR LV_FIELD_EXIST.

  DATA : LV_LB TYPE I,
         LV_TON TYPE I.

  LOOP AT GT_ZNFT1001 WHERE UPDKZ NE SPACE.

*   삭제 FLAG인 경우 필수입력 체크 안함
    IF GT_ZNFT1001-UPDKZ EQ 'D'.
      CONTINUE.
    ENDIF.

*--> 비철 CME 관리
**** LB(CME) 혹은 TON(LME) 단위만 입력 가능
    IF GT_ZNFT1001-MEINS IS INITIAL.
      PV_ERROR     = 'X'.
      TC1-TOP_LINE = SY-TABIX.
      GV_CURSOR    = 'GT_ZNFT1001-MEINS'.
      GV_CURLIN    = 1.

      MESSAGE S003 DISPLAY LIKE 'E' WITH
      '단위를 입력하세요'.
      EXIT.
    ELSE.
      IF GT_ZNFT1001-MEINS <> 'TON' AND GT_ZNFT1001-MEINS <> 'LB'.
        PV_ERROR     = 'X'.
        TC1-TOP_LINE = SY-TABIX.
        GV_CURSOR    = 'GT_ZNFT1001-MEINS'.
        GV_CURLIN    = 1.

        MESSAGE S003 DISPLAY LIKE 'E' WITH
        'LB or TON 단위만 입력 가능합니다.'.
        EXIT.
      ENDIF.

      IF GT_ZNFT1001-MEINS = 'TON'.
        LV_TON = LV_TON + 1.
      ELSEIF GT_ZNFT1001-MEINS = 'LB'.
        LV_LB = LV_LB + 1.
      ENDIF.
    ENDIF.
*--> 비철 CME 관리

*   비철구분 필수입력 체크
    IF GT_ZNFT1001-NFKEY IS INITIAL.
      PV_ERROR     = 'X'.
      TC1-TOP_LINE = SY-TABIX.
      GV_CURSOR    = 'GT_ZNFT1001-NFKEY'.
      GV_CURLIN    = 1.

      MESSAGE S003 DISPLAY LIKE 'E' WITH
      '비철구분은 필수입력 필드입니다.'.
      PV_ERROR = 'X'.
      EXIT.
    ENDIF.

*   수주량 필수입력 체크
    IF GT_ZNFT1001-EMENG IS INITIAL.
      PV_ERROR     = 'X'.
      TC1-TOP_LINE = SY-TABIX.
      GV_CURSOR    = 'GT_ZNFT1001-EMENG'.
      GV_CURLIN    = 1.
      MESSAGE S003 DISPLAY LIKE 'E'
         WITH '수주량은 필수입력 필드입니다.'.
      PV_ERROR = 'X'.
      EXIT.
    ELSE.
      CLEAR : GV_DEC.
      GV_DEC = FRAC( GT_ZNFT1001-EMENG ).
      IF GV_DEC IS NOT INITIAL.
        MESSAGE E001 WITH '수주량은 정수로 입력해야 합니다.'.
        PV_ERROR = 'X'.
        EXIT.
      ENDIF.
    ENDIF.

*   Fix Price/Aveage/Offical Cash/시세 필드체크
    LV_FIELD_EXIST = 0.
    IF GT_ZNFT1001-PRICE IS NOT INITIAL.
      ADD 1 TO LV_FIELD_EXIST.
    ENDIF.
    IF GT_ZNFT1001-AVGPR IS NOT INITIAL.
      ADD 1 TO LV_FIELD_EXIST.
    ENDIF.
    IF GT_ZNFT1001-OFFCH IS NOT INITIAL.
      ADD 1 TO LV_FIELD_EXIST.
    ENDIF.
*    IF GT_ZNFT1001-CURPR IS NOT INITIAL.
*      ADD 1 TO LV_FIELD_EXIST.
*    ENDIF.
    IF LV_FIELD_EXIST EQ 0.
      PV_ERROR     = 'X'.
      MESSAGE S003 DISPLAY LIKE 'E' WITH
      '가격정보를 입력하십시오. (Fix Price/Aveage/Offical Cash)'.
      PV_ERROR = 'X'.
      EXIT.
    ENDIF.
*    IF LV_FIELD_EXIST EQ 0.
*      PV_ERROR     = 'X'.
*      MESSAGE S003 DISPLAY LIKE 'E' WITH
*      '가격정보를 입력하십시오. (Fix Price/Aveage/Offical Cash/시세)'.
*      PV_ERROR = 'X'.
*      EXIT.
*    ENDIF.
    IF LV_FIELD_EXIST GE 2.
      PV_ERROR     = 'X'.
      MESSAGE S003 DISPLAY LIKE 'E' WITH
      '가격정보(Fix Price/Aveage/Offical Cash)'
      '는 하나만 입력하십시오.'.
      PV_ERROR = 'X'.
      EXIT.
    ENDIF.
*    IF LV_FIELD_EXIST GE 2.
*      PV_ERROR     = 'X'.
*      MESSAGE S003 DISPLAY LIKE 'E' WITH
*      '가격정보(Fix Price/Aveage/Offical Cash/시세)'
*      '는 하나만 입력하십시오.'.
*      PV_ERROR = 'X'.
*      EXIT.
*    ENDIF.

  ENDLOOP.

*--> 비철 CME 관리
  IF PV_ERROR IS INITIAL.
    IF LV_LB > 0 AND LV_TON > 0.
      MESSAGE S003 DISPLAY LIKE 'E' WITH
      '하나의 단위만 사용 가능합니다.'
      '(LB or TON)'.
      PV_ERROR = 'X'.
      EXIT.
    ENDIF.
  ENDIF.
*<-- 비철 CME 관리

ENDFORM.                    " CHECK_ITEM_DATA
*&---------------------------------------------------------------------*
*&      Form  DATA_SAVE_TABLE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM DATA_SAVE_TABLE .

  DATA : LV_SAVE_YN TYPE SY-SUBRC.

  CLEAR   : GT_ZNFT1001N, GT_ZNFT1001D.
  REFRESH : GT_ZNFT1001N, GT_ZNFT1001D.

  READ TABLE GT_ZNFT1001 INDEX 1.

* Header 정보 생성
  IF SY-TCODE EQ GV_TCODE1.

*   생성인 경우 계약번호 자동채번
    PERFORM GET_CONTRACT_NO.

    ZNFT1000-CSTAT = 'L'.     " 계약상태 : 진행
    ZNFT1000-ERDAT = SY-DATLO.
    ZNFT1000-ERZET = SY-TIMLO.
    ZNFT1000-ERNAM = SY-UNAME.

*   ITEM 계약번호
    GT_ZNFT1001-CONNO = ZNFT1000-CONNO.

    MODIFY GT_ZNFT1001 TRANSPORTING CONNO
                   WHERE NFKEY IS NOT INITIAL.

  ENDIF.

  ZNFT1000-AEDAT = SY-DATLO.
  ZNFT1000-AEZET = SY-TIMLO.
  ZNFT1000-AENAM = SY-UNAME.

* 신규
  IF SY-TCODE EQ GV_TCODE1.

*   Header - 파일첨부 데이터 저장 ( ZNFT1002 )
    IF ZNFT1000-CONNO IS NOT INITIAL.
      GS_FILEM-CONNO = ZNFT1000-CONNO.
    ENDIF.

    PERFORM INSERT_TABLE_ZNFT1002.

* 수정
  ELSE.

*   계약서 및 첨부문서 삭제후 생성
    PERFORM DMSDOC_DEL.
*    DELETE FROM ZNFT1002
*          WHERE CONNO EQ ZNFT1000-CONNO.


*   파일첨부 팝업창에 입력된 파일및 파일경로 데이터 등록
    GS_FILEM-CONNO = ZNFT1000-CONNO.
*   GS_FILEM-FILE1 / GS_FILEM-LINK1
*   GS_FILEM-FILE2 / GS_FILEM-LINK2
*   GS_FILEM-FILE3 / GS_FILEM-LINK3
*   GS_FILEM-FILE4 / GS_FILEM-LINK4
*   GS_FILEM-FILE5 / GS_FILEM-LINK5
    PERFORM INSERT_TABLE_ZNFT1002.

  ENDIF.

* Header 정보 Table에 반영
  MODIFY ZNFT1000 FROM ZNFT1000.

  IF SY-SUBRC EQ 0.
    LV_SAVE_YN = SY-SUBRC.
*   반영할 데이터 생성
    LOOP AT GT_ZNFT1001 INTO GS_ZNFT1001 WHERE UPDKZ NE SPACE.
      CASE GS_ZNFT1001-UPDKZ.
        WHEN 'D'.
          MOVE-CORRESPONDING GS_ZNFT1001 TO GT_ZNFT1001D.
          APPEND GT_ZNFT1001D.
        WHEN 'I' OR 'U'.
          MOVE-CORRESPONDING GS_ZNFT1001 TO GT_ZNFT1001N.
          APPEND GT_ZNFT1001N.
      ENDCASE.
    ENDLOOP.

*   ITEM - 삭제대상 반영
    IF GT_ZNFT1001D[] IS NOT INITIAL.
      DELETE ZNFT1001 FROM TABLE GT_ZNFT1001D.
      IF SY-SUBRC EQ 0.
        LV_SAVE_YN = SY-SUBRC.
      ENDIF.
    ENDIF.

*   ITEM - 추가/수정대상 반영
    IF GT_ZNFT1001N[] IS NOT INITIAL.
      MODIFY ZNFT1001 FROM TABLE GT_ZNFT1001N.
      IF SY-SUBRC EQ 0.
        LV_SAVE_YN = SY-SUBRC.
      ENDIF.
    ENDIF.

    IF LV_SAVE_YN EQ 0.
*     변경이력 저장
      PERFORM SAVE_CHANGE_DOC USING ' '.
      COMMIT WORK.
      MESSAGE S010 WITH '계약번호' ZNFT1000-CONNO.

*     저장이 성공한 경우 GT_ZNFT1001 필드의 정보를 일괄 갱신
*     UPDKZ : DB에 반영할 데이터인지 식별하기 위한 구분자
*     DBCHK : DB에 등록된 데이터인지 식별하기 위한 구분자
      GT_ZNFT1001-UPDKZ = SPACE.
      IF GT_ZNFT1001-DBCHK IS NOT INITIAL.
        GT_ZNFT1001-DBCHK = 'Y'.
      ENDIF.
      MODIFY GT_ZNFT1001 TRANSPORTING UPDKZ DBCHK
       WHERE EMENG IS NOT INITIAL.

*     신규생성시 초기화면 이동 및 기존 입력값 CLEAR
      IF SY-TCODE EQ GV_TCODE1.

        CLEAR : ZNFT1000, GS_ZNFT1001, GT_ZNFT1001,
                ZNFT0003, ZNFT0004,    ZNFT0005,
                GV_COTYP.

        REFRESH GT_ZNFT1001[].

*        SET PARAMETER ID 'ZNFCON' FIELD ZNFT1000-CONNO.
*        LEAVE TO TRANSACTION 'ZNF2M2002A' AND SKIP FIRST SCREEN.
        LEAVE TO SCREEN 0.
      ELSE.

*       변경이력 초기화
        CLEAR   : XGT_1001, YGT_1001, YZNFT1000.
        REFRESH : XGT_1001, YGT_1001.

        YZNFT1000 = ZNFT1000.

        LOOP AT GT_ZNFT1001.
          CLEAR : YGT_1001, GT_ZNFT1001-UPDKZ.

          IF GT_ZNFT1001-DBCHK IS NOT INITIAL.
            GT_ZNFT1001-DBCHK = 'Y'.
          ENDIF.

          MOVE-CORRESPONDING GT_ZNFT1001 TO YGT_1001.
          APPEND YGT_1001.
          MODIFY GT_ZNFT1001.
        ENDLOOP.
        GS_ZNFT1002N = GS_ZNFT1002Y.
      ENDIF.
    ELSE.
      IF GS_FILEM IS NOT INITIAL OR GV_H_CHNG EQ 'Y'.
        MESSAGE S010 WITH '계약번호' ZNFT1000-CONNO.
      ELSE.
        ROLLBACK WORK.
        MESSAGE S003 DISPLAY LIKE 'E'
           WITH '계약관리 품목 정보 저장 에러!'.
      ENDIF.
    ENDIF.
  ELSE.
    ROLLBACK WORK.
    MESSAGE S003 DISPLAY LIKE 'E'
       WITH '계약관리 헤더 정보 저장 에러!'.
  ENDIF.

ENDFORM.                    " DATA_SAVE_TABLE

*&---------------------------------------------------------------------*
*&      Form  GET_CONTRACT_NO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_CONTRACT_NO .

  CLEAR : ZNFT1000-CONNO.

  CALL FUNCTION 'NUMBER_GET_NEXT'
    EXPORTING
      NR_RANGE_NR             = '10'
      OBJECT                  = 'ZNF2_00001'
    IMPORTING
      NUMBER                  = ZNFT1000-CONNO
    EXCEPTIONS
      INTERVAL_NOT_FOUND      = 1
      NUMBER_RANGE_NOT_INTERN = 2
      OBJECT_NOT_FOUND        = 3
      QUANTITY_IS_0           = 4
      QUANTITY_IS_NOT_1       = 5
      INTERVAL_OVERFLOW       = 6
      BUFFER_OVERFLOW         = 7
      OTHERS                  = 8.

  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

ENDFORM.                    " GET_CONTRACT_NO
*&---------------------------------------------------------------------*
*&      Form  SAVE_CHANGE_DOC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_1122   text
*----------------------------------------------------------------------*
FORM SAVE_CHANGE_DOC  USING  PV_FLAG.

  DATA: LV_OBJECTID        TYPE CDHDR-OBJECTID,
        LV_TCODE           TYPE CDHDR-TCODE,
        LV_CDOC_UPD_OBJECT TYPE CDHDR-CHANGE_IND,
        LV_UPD_ICDTXT      TYPE CHAR1.

  IF PV_FLAG = 'D'.
    LV_CDOC_UPD_OBJECT = 'D'.
  ELSE.
    IF SY-TCODE EQ GV_TCODE1.
      LV_CDOC_UPD_OBJECT = 'I'.
    ELSE.
      LV_CDOC_UPD_OBJECT = 'U'.
    ENDIF.
  ENDIF.

  LOOP AT GT_ZNFT1001.
    CLEAR : XGT_1001.

    MOVE-CORRESPONDING GT_ZNFT1001 TO XGT_1001.

    XGT_1001-KZ = GT_ZNFT1001-UPDKZ.

    APPEND XGT_1001.
  ENDLOOP.

  LV_OBJECTID = ZNFT1000-CONNO.
  LV_TCODE    = SY-TCODE.

  CALL FUNCTION 'ZNFT1000CHDOC_WRITE_DOCUMENT'
    EXPORTING
      OBJECTID     = LV_OBJECTID
      TCODE        = LV_TCODE
      UTIME        = SY-TIMLO
      UDATE        = SY-DATLO
      USERNAME     = SY-UNAME
*     PLANNED_CHANGE_NUMBER         = ' '
*     OBJECT_CHANGE_INDICATOR       = 'U'
*     PLANNED_OR_REAL_CHANGES       = ' '
*     NO_CHANGE_POINTERS            = ' '
      N_ZNFT1000   = ZNFT1000
      O_ZNFT1000   = YZNFT1000
      UPD_ZNFT1000 = LV_CDOC_UPD_OBJECT
      UPD_ZNFT1001 = LV_CDOC_UPD_OBJECT
      N_ZNFT1002   = GS_ZNFT1002N
      O_ZNFT1002   = GS_ZNFT1002Y
      UPD_ZNFT1002 = LV_CDOC_UPD_OBJECT
    TABLES
      XZNFT1001    = XGT_1001
      YZNFT1001    = YGT_1001.

  IF SY-SUBRC EQ 0.

  ENDIF.

ENDFORM.                    " SAVE_CHANGE_DOC

*&---------------------------------------------------------------------*
*&      Form  INSERT_FILE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM INSERT_FILE .

  DATA: LV_MODE  TYPE CHAR01,
        LV_CONNO TYPE ZCONNO.

  LV_CONNO = ZNFT1000-CONNO.

  IF GS_FILEM IS INITIAL.
    SELECT SINGLE *
      FROM ZNFT1002
     WHERE CONNO EQ LV_CONNO.

    IF SY-SUBRC EQ 0.
      MOVE-CORRESPONDING ZNFT1002 TO GS_FILEM.
    ELSE.
      MOVE GV_CONNO TO GS_FILEM-CONNO.
    ENDIF.
  ENDIF.

* 생성,조회시 다운로드만 활성
  CASE SY-TCODE.
    WHEN GV_TCODE1.
      LV_MODE = '1'.   " UPLOAD
    WHEN GV_TCODE4.
      LV_MODE = '2'.   " DOWNLOAD
    WHEN GV_TCODE2 OR GV_TCODE3.
      LV_MODE = '3'.   " UPLOAD
  ENDCASE.

  CALL FUNCTION 'Z_NF2_FILE_CONTROL'
    EXPORTING
      IMP_MODE = LV_MODE
    IMPORTING
      EV_FLAG1 = GV_FLAG1
      EV_FLAG2 = GV_FLAG2
      EV_FLAG3 = GV_FLAG3
      EV_FLAG4 = GV_FLAG4
      EV_FLAG5 = GV_FLAG5
    TABLES
      FILEINFO = GS_FILEM.

ENDFORM.                    " INSERT_FILE
*&---------------------------------------------------------------------*
*&      Form  INSERT_TABLE_ZNFT1002
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM INSERT_TABLE_ZNFT1002 .
  DATA: LV_DESC(12),
        LV_MESSAGE(50).

  CLEAR : LV_MESSAGE.

  IF NOT ZNFT1002-FILE1 IS INITIAL AND GV_FLAG1 = 'X'.
    PERFORM DOC_DELETE USING ZNFT1002-FILE1.
  ENDIF.

  IF NOT GS_FILEM-LINK1 IS INITIAL AND GV_FLAG1 = 'X'
    OR SY-TCODE = GV_TCODE1 AND NOT GS_FILEM-LINK1 IS INITIAL. "113555
    CLEAR LV_DESC.
    CONCATENATE GS_FILEM-CONNO '-1' INTO LV_DESC.
*bapi
    PERFORM DATA_UPLOAD USING GS_FILEM-LINK1 LV_DESC.
    IF GV_ERROR IS INITIAL.
      GS_FILEM-FILE1 = G_DOKNR.
    ELSE.
      GS_FILEM-FILE1 = ZNFT1002-FILE1.
      GS_FILEM-LINK1 = ZNFT1002-LINK1.
      CONCATENATE LV_MESSAGE '/File 1' INTO LV_MESSAGE.
    ENDIF.
  ENDIF.

  IF NOT ZNFT1002-FILE2 IS INITIAL AND GV_FLAG2 = 'X'.
    PERFORM DOC_DELETE USING ZNFT1002-FILE2.
  ENDIF.

  IF NOT GS_FILEM-LINK2 IS INITIAL AND GV_FLAG2 = 'X'
    OR SY-TCODE = GV_TCODE1 AND NOT GS_FILEM-LINK2 IS INITIAL. "113555
    CLEAR LV_DESC.
    CONCATENATE GS_FILEM-CONNO '-2' INTO LV_DESC.
*bapi
    PERFORM DATA_UPLOAD USING GS_FILEM-LINK2 LV_DESC.
    IF GV_ERROR IS INITIAL.
      GS_FILEM-FILE2 = G_DOKNR.
    ELSE.
      GS_FILEM-FILE2 = ZNFT1002-FILE2.
      GS_FILEM-LINK2 = ZNFT1002-LINK2.
      CONCATENATE LV_MESSAGE '/File 2' INTO LV_MESSAGE.
    ENDIF.
  ENDIF.

  IF NOT ZNFT1002-FILE3 IS INITIAL AND GV_FLAG3 = 'X'.
    PERFORM DOC_DELETE USING ZNFT1002-FILE3.
  ENDIF.

  IF NOT GS_FILEM-LINK3 IS INITIAL AND GV_FLAG3 = 'X'
    OR SY-TCODE = GV_TCODE1 AND NOT GS_FILEM-LINK3 IS INITIAL. "113555
    CLEAR LV_DESC.
    CONCATENATE GS_FILEM-CONNO '-3' INTO LV_DESC.
*bapi
    PERFORM DATA_UPLOAD USING GS_FILEM-LINK3 LV_DESC.
    IF GV_ERROR IS INITIAL.
      GS_FILEM-FILE3 = G_DOKNR.
    ELSE.
      GS_FILEM-FILE3 = ZNFT1002-FILE3.
      GS_FILEM-LINK3 = ZNFT1002-LINK3.
      CONCATENATE LV_MESSAGE '/File 3' INTO LV_MESSAGE.
    ENDIF.
  ENDIF.

  IF NOT ZNFT1002-FILE4 IS INITIAL AND GV_FLAG4 = 'X'.
    PERFORM DOC_DELETE USING ZNFT1002-FILE4.
  ENDIF.

  IF NOT GS_FILEM-LINK4 IS INITIAL AND GV_FLAG4 = 'X'
    OR SY-TCODE = GV_TCODE1 AND NOT GS_FILEM-LINK4 IS INITIAL. "113555
    CLEAR LV_DESC.
    CONCATENATE GS_FILEM-CONNO '-4' INTO LV_DESC.
*bapi
    PERFORM DATA_UPLOAD USING GS_FILEM-LINK4 LV_DESC.
    IF GV_ERROR IS INITIAL.
      GS_FILEM-FILE4 = G_DOKNR.
    ELSE.
      GS_FILEM-FILE4 = ZNFT1002-FILE4.
      GS_FILEM-LINK4 = ZNFT1002-LINK4.
      CONCATENATE LV_MESSAGE '/File 4' INTO LV_MESSAGE.
    ENDIF.
  ENDIF.

  IF NOT ZNFT1002-FILE5 IS INITIAL AND GV_FLAG5 = 'X'.
    PERFORM DOC_DELETE USING ZNFT1002-FILE5.
  ENDIF.

  IF NOT GS_FILEM-LINK5 IS INITIAL AND GV_FLAG5 = 'X'
    OR SY-TCODE = GV_TCODE1 AND NOT GS_FILEM-LINK5 IS INITIAL. "113555
    CLEAR LV_DESC.
    CONCATENATE GS_FILEM-CONNO '-5' INTO LV_DESC.
*bapi
    PERFORM DATA_UPLOAD USING GS_FILEM-LINK5 LV_DESC.
    IF GV_ERROR IS INITIAL.
      GS_FILEM-FILE5 = G_DOKNR.
    ELSE.
      GS_FILEM-FILE5 = ZNFT1002-FILE5.
      GS_FILEM-LINK5 = ZNFT1002-LINK5.
      CONCATENATE LV_MESSAGE '/File 5' INTO LV_MESSAGE.
    ENDIF.
  ENDIF.

*  IF GV_ERROR EQ 'X'.
*
*    DELETE FROM ZNFT1002 WHERE CONNO EQ GS_FILEM-CONNO.
*    EXIT.
*
*  ELSE.

  CLEAR  ZNFT1002.

  IF NOT GS_FILEM-FILE1 IS INITIAL OR
     NOT GS_FILEM-FILE2 IS INITIAL OR
     NOT GS_FILEM-FILE3 IS INITIAL OR
     NOT GS_FILEM-FILE4 IS INITIAL OR
     NOT GS_FILEM-FILE5 IS INITIAL.

    MOVE-CORRESPONDING GS_FILEM TO ZNFT1002.

    IF SY-TCODE EQ GV_TCODE1.
      ZNFT1002-ERDAT = SY-DATLO.
      ZNFT1002-ERZET = SY-TIMLO.
      ZNFT1002-ERNAM = SY-UNAME.
    ELSE.
      ZNFT1002-ERDAT = SY-DATLO.
      ZNFT1002-ERZET = SY-TIMLO.
      ZNFT1002-ERNAM = SY-UNAME.
      ZNFT1002-AEDAT = SY-DATLO.
      ZNFT1002-AEZET = SY-TIMLO.
      ZNFT1002-AENAM = SY-UNAME.
    ENDIF.
    MODIFY ZNFT1002 FROM ZNFT1002.

*     Change Documemt 신규변경된 데이터 스트럭처 생성
    GS_ZNFT1002N = ZNFT1002.

  ENDIF.
*  ENDIF.

  IF LV_MESSAGE IS NOT INITIAL.
    REPLACE '/' IN LV_MESSAGE WITH ''.
    MESSAGE I001 WITH LV_MESSAGE 'Upload를 실패하였습니다.'.
  ENDIF.

ENDFORM.                    " INSERT_TABLE_ZNFT1002

*&---------------------------------------------------------------------*
*&      Form  DATA_UPLOAD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM DATA_UPLOAD USING P_LINK P_DESC.

  CLEAR: GS_DOCUMENTDATA, GT_FILES, GT_FILES[], GT_COMPS, GT_COMPS[].
  CLEAR: G_DOKAR, G_DOKNR, G_DOKTL, G_DOKVR.
  CLEAR: GV_ERROR.

* *** Documentdata******************************************
  GS_DOCUMENTDATA-DOCUMENTTYPE         =  'PCI'.
  GS_DOCUMENTDATA-DOCUMENTVERSION      =  '00' .
  GS_DOCUMENTDATA-DOCUMENTPART         =  '000' .

*  gs_documentdata-statusextern         =  'FR' .
*  gs_documentdata-statusintern         =  'FR' .
  GS_DOCUMENTDATA-STATUSEXTERN         =  'IA' .
  GS_DOCUMENTDATA-STATUSINTERN         =  'IA' .

  GS_DOCUMENTDATA-AUTHORITYGROUP       =  ZNFT1000-BUKRS.
  "권한그룹: 회사코드
  GS_DOCUMENTDATA-DESCRIPTION          =  P_DESC.
  "Desc:     품의번호
* *** Documentdata******************************************
  GT_FILES-DOCUMENTVERSION  = '00'.
  GT_FILES-DOCUMENTPART     = '000'.

*  gt_files-storagecategory  = 'Z_LSC_DMS'.

*& 기존 데이터 저장소 운영에서만 되도록 적용되었던 셋팅값 변경
  CASE SY-MANDT.
    WHEN '600'.
      MOVE 'Z_LSC_KPRO' TO GT_FILES-STORAGECATEGORY.
    WHEN '320' OR '330'.
      MOVE 'Z_LSC_KPRO' TO GT_FILES-STORAGECATEGORY.
    WHEN '100'.
      MOVE 'Z_LSC_DMS'  TO GT_FILES-STORAGECATEGORY.
    WHEN OTHERS.
      MOVE 'Z_LSC_KPRO' TO GT_FILES-STORAGECATEGORY.
  ENDCASE.

*-{기능개선 113555 - 첨부파일 확장자 로직변경
*__주석처리
** workstation application  WRD는 확장자 DOC임
*  DATA: LV_CNT1 TYPE I.
*  LV_CNT1 = STRLEN( P_LINK ) - 3.
*  MOVE P_LINK+LV_CNT1(3) TO GT_FILES-WSAPPLICATION.
*
*  TRANSLATE GT_FILES-WSAPPLICATION TO UPPER CASE.
*
*  CASE GT_FILES-WSAPPLICATION.
*    WHEN 'DOC'.
*      GT_FILES-WSAPPLICATION    = 'WRD'.
*    WHEN OTHERS.
*  ENDCASE.

*__신규로직
* P_LINK: R:\TEST.XLSX 형식으로 들어옴.
  DATA: LF_DUMMY          LIKE DRAW-FILEP,
        GF_LAST_DIRECTORY LIKE DRAW-FILEP.
  DATA: LV_CNT1 TYPE I.

  LV_CNT1 = STRLEN( P_LINK ).
  IF LV_CNT1 > 131.
    MESSAGE I213(23).
  ENDIF.

  CALL FUNCTION 'CV120_SPLIT_PATH'
    EXPORTING
      PF_PATH  = P_LINK
    IMPORTING
      PFX_PATH = GF_LAST_DIRECTORY
      PFX_FILE = LF_DUMMY.

  CALL FUNCTION 'CV120_DOC_GET_APPL'
    EXPORTING
      PF_DIALOG = ''
      PF_TYPDT  = 'PC'
      PF_FILE   = LF_DUMMY
    IMPORTING
      PFX_DAPPL = GT_FILES-WSAPPLICATION.
*-}기능개선 113555.

  GT_FILES-CHECKEDIN        = 'X'.

* Desc
  CLEAR LV_CNT1.
  LV_CNT1 = STRLEN( P_LINK ) - 3.
  MOVE P_LINK+3(LV_CNT1) TO GT_FILES-DESCRIPTION.

  GT_FILES-ORIGINALTYPE     = 1 .
  GT_FILES-DOCFILE          = P_LINK.

  APPEND GT_FILES.

***********************************************************
  CALL FUNCTION 'BAPI_DOCUMENT_CREATE2'
    EXPORTING
      DOCUMENTDATA    = GS_DOCUMENTDATA
    IMPORTING
      DOCUMENTTYPE    = G_DOKAR
      DOCUMENTNUMBER  = G_DOKNR
      DOCUMENTPART    = G_DOKTL
      DOCUMENTVERSION = G_DOKVR
      RETURN          = GS_RETURN1
    TABLES
      DOCUMENTFILES   = GT_FILES.
***********************************************************

  IF  GS_RETURN1-TYPE = 'A' OR GS_RETURN1-TYPE = 'E' .
    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
    GV_ERROR = 'X'.
    MESSAGE S068 WITH P_LINK.
    EXIT.
  ELSE.

    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        WAIT = 'X'.

    CALL FUNCTION 'BAPI_DOCUMENT_SETSTATUS'
      EXPORTING
        DOCUMENTTYPE    = G_DOKAR
        DOCUMENTNUMBER  = G_DOKNR
        DOCUMENTPART    = G_DOKTL
        DOCUMENTVERSION = G_DOKVR
        STATUSEXTERN    = 'FR'
        STATUSINTERN    = 'FR'
      IMPORTING
        RETURN          = GS_RETURN1.

  ENDIF.

ENDFORM.                    " DATA_UPLOAD
*&---------------------------------------------------------------------*
*&      Form  DMSDOC_DEL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM DMSDOC_DEL .

  SELECT SINGLE *
    FROM ZNFT1002
   WHERE CONNO EQ GV_CONNO.

  IF SY-SUBRC EQ 0.

*    IF NOT ZNFT1002-FILE1 IS INITIAL AND GV_FLAG1 = 'X'.
*      PERFORM DOC_DELETE USING ZNFT1002-FILE1.
*    ENDIF.
*
*    IF NOT ZNFT1002-FILE2 IS INITIAL AND GV_FLAG2 = 'X'.
*      PERFORM DOC_DELETE USING ZNFT1002-FILE2.
*    ENDIF.
*
*    IF NOT ZNFT1002-FILE3 IS INITIAL AND GV_FLAG3 = 'X'.
*      PERFORM DOC_DELETE USING ZNFT1002-FILE3.
*    ENDIF.
*
*    IF NOT ZNFT1002-FILE4 IS INITIAL AND GV_FLAG4 = 'X'.
*      PERFORM DOC_DELETE USING ZNFT1002-FILE4.
*    ENDIF.
*
*    IF NOT ZNFT1002-FILE5 IS INITIAL AND GV_FLAG5 = 'X'.
*      PERFORM DOC_DELETE USING ZNFT1002-FILE5.
*    ENDIF.

  ENDIF.

ENDFORM.                    " DMSDOC_DEL
*&---------------------------------------------------------------------*
*&      Form  DOC_DELETE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_ZNFT1002_FILE1  text
*----------------------------------------------------------------------*
FORM DOC_DELETE USING P_FILE.

  CALL FUNCTION 'BAPI_DOCUMENT_DELETE'
    EXPORTING
      DOCUMENTTYPE    = 'PCI'
      DOCUMENTNUMBER  = P_FILE
      DOCUMENTPART    = '000'
      DOCUMENTVERSION = '00'.
*      IMPORTING
*        return          = gv_subrc.

ENDFORM.                    " DOC_DELETE

*&---------------------------------------------------------------------*
*&      Form  CALL_SCREEN_0600
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CALL_SCREEN_0600 .

  CALL SCREEN 0600.

ENDFORM.                    " CALL_SCREEN_0600
*&---------------------------------------------------------------------*
*&      Form  DISPLAY_PRINT_SCREEN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM DISPLAY_PRINT_SCREEN .
  DATA: LV_COTYP_NM TYPE CHAR10,
        LV_CSTAT_NM TYPE CHAR10.

  DATA: LS_ZNFT1000 TYPE ZNFT1000,
        LS_ZNFT1001 TYPE ZNFT1001,
        LT_ZNFT1001 TYPE TABLE OF ZNFT1001.

  DATA: LV_AVGPR(10),
        LV_OFFCH(10).

  SELECT SINGLE * INTO CORRESPONDING FIELDS OF LS_ZNFT1000
    FROM ZNFT1000
   WHERE CONNO EQ GV_CONNO.

  SELECT * INTO CORRESPONDING FIELDS OF TABLE LT_ZNFT1001
    FROM ZNFT1001
   WHERE CONNO EQ GV_CONNO.

* 계약유형 & 계약상태 Text 가져오기
  PERFORM DOMAIN_VALUE_GET USING 'ZCOTYP'
                                 LS_ZNFT1000-COTYP
                                 LV_COTYP_NM.
  PERFORM DOMAIN_VALUE_GET USING 'ZCSTAT'
                                 LS_ZNFT1000-CSTAT
                                 LV_CSTAT_NM.

  NEW-PAGE LINE-SIZE  125
           LINE-COUNT 66
           NO-HEADING
           NO-TITLE.

  SKIP 6.

  ULINE.
  WRITE : '■ Header Info. ■'.
  ULINE. NEW-LINE.
  WRITE : '[계약정보]'.
  NEW-LINE.
  WRITE : '계약번호 : ',  (28) LS_ZNFT1000-CONNO,
          '생 성 자 :',   (20) LS_ZNFT1000-ERNAM,
          '생 성 일 :',   (20) LS_ZNFT1000-ERDAT.
  NEW-LINE.
  WRITE : '계 약 명 :',   (29) LS_ZNFT1000-COTXT,
          '변 경 자 :',   (20) LS_ZNFT1000-AENAM,
          '변 경 일 :',        LS_ZNFT1000-AEDAT.

  NEW-LINE.
  WRITE : '계약유형 :',   LV_COTYP_NM.

  NEW-LINE.
  WRITE : '계약상태 :',   (29) LV_CSTAT_NM,
          '계약취소일 :'.

  IF LS_ZNFT1000-CDATE IS NOT INITIAL AND
     LS_ZNFT1000-CDATE <> ' '.
    WRITE : LS_ZNFT1000-CDATE.
  ENDIF.

  ULINE.
  WRITE /.
  WRITE : '[조직정보]'.
  NEW-LINE.
  WRITE : '회사코드 :',  (08) LS_ZNFT1000-BUKRS, (20) T001-BUTXT,
          '손익센터 :',  (08) LS_ZNFT1000-PRCTR,      ZNFT0004-PTEXT.
  NEW-LINE.
  WRITE : '사 업 부 :',  (08) LS_ZNFT1000-NFCTR, (20) ZNFT0005-NTEXT,
          '영업그룹 :',  (08) LS_ZNFT1000-VKGRP,      ZNFT0003-VTEXT.

  ULINE.
  WRITE /.
  WRITE : '[수주정보]'.
  NEW-LINE.
  WRITE : '고객코드   :',     (27) LS_ZNFT1000-KUNNR,
          '수 주 일 :'.

  IF LS_ZNFT1000-SUJUD IS NOT INITIAL AND
     LS_ZNFT1000-SUJUD <> ' '.
    WRITE : LS_ZNFT1000-SUJUD.
  ENDIF.

  NEW-LINE.
  WRITE : '고 객 명   :',     (27) LS_ZNFT1000-NCUST,
          '수 주 금 :',
          (17) LS_ZNFT1000-PRICE CURRENCY LS_ZNFT1000-WAERS,
          LS_ZNFT1000-WAERS.
  NEW-LINE.
  WRITE : '영업담당자 :',     (27) LS_ZNFT1000-SALER,
          '영업이익률(%) :',  (12) LS_ZNFT1000-PRATE.
  NEW-LINE.

  SELECT SINGLE * FROM ZNFT1002 WHERE CONNO EQ GV_CONNO.
  IF SY-SUBRC EQ 0.
    WRITE : '계약서 및 발주서첨부 :',  (17) 'Yes',
            '환     율 :',                  LS_ZNFT1000-ERATE.
  ELSE.
    WRITE : '계약서 및 발주서첨부 :',  (17) 'No',
            '환    율 :',                   LS_ZNFT1000-ERATE.
  ENDIF.

  ULINE.
  WRITE /. WRITE /.
  ULINE.
  WRITE : '■ Item Info. ■'.
  NEW-LINE.
  SORT LT_ZNFT1001 BY NFKEY.
  LOOP AT LT_ZNFT1001 INTO LS_ZNFT1001.

*   ##### Header #####
    AT FIRST.
      ULINE.
      WRITE : (08) '비철구분'      CENTERED,
              (18) '수주량'        RIGHT-JUSTIFIED,
              (04) '단위'          CENTERED,
              (13) 'Fix Price'     RIGHT-JUSTIFIED,
              (04) '통화'          CENTERED,
              (15) 'Average Price' CENTERED,
              (15) 'Official Cash' CENTERED,
              (40) '비고'          LEFT-JUSTIFIED.
      ULINE.
    ENDAT.

    CLEAR : LV_AVGPR, LV_OFFCH.

    WRITE : LS_ZNFT1001-AVGPR TO LV_AVGPR.

    IF LS_ZNFT1001-OFFCH IS NOT INITIAL AND
       LS_ZNFT1001-OFFCH <> ' '.
      WRITE : LS_ZNFT1001-OFFCH TO LV_OFFCH.
    ENDIF.

*   ##### Item #####
    WRITE : (08) LS_ZNFT1001-NFKEY CENTERED,
            (18) LS_ZNFT1001-EMENG RIGHT-JUSTIFIED
                                   UNIT     LS_ZNFT1001-MEINS,
            (04) LS_ZNFT1001-MEINS CENTERED,
            (13) LS_ZNFT1001-PRICE RIGHT-JUSTIFIED
                                   CURRENCY LS_ZNFT1001-WAERS,
            (04) LS_ZNFT1001-WAERS CENTERED,
            (15) LV_AVGPR          CENTERED,
            (15) LV_OFFCH          CENTERED,
            (40) LS_ZNFT1001-BIGO4 LEFT-JUSTIFIED.

    NEW-LINE.

    AT LAST.
      ULINE.
    ENDAT.
  ENDLOOP.

ENDFORM.                    " DISPLAY_PRINT_SCREEN

*&---------------------------------------------------------------------*
*&      Form  SET_MODIFY_SCREEN_FLAG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SET_MODIFY_SCREEN_FLAG .


  CLEAR GV_SCR_CHANG_FIELD.

  IF SY-TCODE <> GV_TCODE1.
* =======================================================
* ### GV_MODI_A ### : S/O, 또는 선물요청과 연결유무
* =======================================================
    CLEAR : GV_MODI_A.

    DATA: LV_REQNO TYPE ZREQNO_1,
          LV_VBELN TYPE VBELN_VA.

    SELECT SINGLE REQNO INTO LV_REQNO
      FROM ZNFT1011
     WHERE CONNO EQ GV_CONNO.

    IF LV_REQNO IS NOT INITIAL.
      GV_MODI_A = 'X'.
    ENDIF.

    SELECT SINGLE VBELN INTO LV_VBELN
      FROM VBAP
     WHERE CONNO EQ GV_CONNO.

    IF LV_VBELN IS NOT INITIAL.
      GV_MODI_A = 'X'.
    ENDIF.


* =======================================================
* ### GV_MODI_B ### : 선물집행후 정산 여부
* =======================================================
    CLEAR : GV_MODI_B.

    DATA: LV_YNFIN TYPE ZFUTNO.

    SELECT SINGLE Z2~YNFIN INTO LV_YNFIN
      FROM ZNFT1011 AS Z1
           INNER JOIN ZNFT1020 AS Z2
              ON Z2~REQNO EQ Z1~REQNO AND Z2~H_NO1 EQ Z1~H_NO1
     WHERE Z1~CONNO EQ GV_CONNO.

    IF LV_YNFIN IS NOT INITIAL.
      GV_MODI_B = 'X'.
    ENDIF.
  ENDIF.

* =======================================================
* ### GV_MODI_B ### : 계약유형 (경상선물,재고헷지)
* =======================================================
  CLEAR : GV_MODI_C.

  DATA: LV_COTYP TYPE ZCOTYP.

  CASE SY-TCODE.
    WHEN GV_TCODE1.
      IF GV_COTYP EQ '3' OR GV_COTYP EQ '5'.
        GV_MODI_C = 'X'.
      ELSE.
        GV_MODI_C = SPACE.
      ENDIF.
    WHEN GV_TCODE2 OR GV_TCODE3.
      SELECT SINGLE COTYP INTO LV_COTYP
        FROM ZNFT1000
       WHERE CONNO EQ GV_CONNO.

      IF LV_COTYP EQ '3' OR LV_COTYP EQ '5'.
        GV_MODI_C = 'X'.
      ELSE.
        GV_MODI_C = SPACE.
      ENDIF.
  ENDCASE.

ENDFORM.                    " SET_MODIFY_SCREEN_FLAG
*&---------------------------------------------------------------------*
*&      Form  INSERT_FILE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM LINK_FILE .

  DATA: LV_MODE  TYPE CHAR01,
        LV_CONNO TYPE ZCONNO.

  LV_CONNO = ZNFT1000-CONNO.

  IF GS_FILEM IS INITIAL.
    SELECT SINGLE *
      FROM ZNFT1002
     WHERE CONNO EQ LV_CONNO.

    IF SY-SUBRC EQ 0.
      MOVE-CORRESPONDING ZNFT1002 TO GS_FILEM.
    ELSE.
      MOVE GV_CONNO TO GS_FILEM-CONNO.
    ENDIF.
  ENDIF.

* 생성,조회시 다운로드만 활성
  CASE SY-TCODE.
    WHEN GV_TCODE1.
      LV_MODE = '1'.   " UPLOAD
    WHEN GV_TCODE4.
      LV_MODE = '2'.   " DOWNLOAD
    WHEN GV_TCODE2 OR GV_TCODE3.
      LV_MODE = '3'.   " UPLOAD
  ENDCASE.

  CALL FUNCTION 'Z_NF2_FILE_CONTROL1'
    EXPORTING
      IMP_MODE = LV_MODE
    IMPORTING
      EV_FLAG1 = GV_FLAG1
      EV_FLAG2 = GV_FLAG2
      EV_FLAG3 = GV_FLAG3
      EV_FLAG4 = GV_FLAG4
      EV_FLAG5 = GV_FLAG5
    TABLES
      FILEINFO = GS_FILEM.

ENDFORM.                    " INSERT_FILE
