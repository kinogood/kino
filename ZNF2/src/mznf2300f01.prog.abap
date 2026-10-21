*&---------------------------------------------------------------------*
*&  Include           MZNF2300F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  ENQUEUE_ZNFT1020
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM ENQUEUE_ZNFT1020 USING PV_ERROR.
  DATA: LV_MSGV1  LIKE SY-MSGV1.

  CLEAR : PV_ERROR.

  CALL FUNCTION 'ENQUEUE_EZ_ZNFT1020'
    EXPORTING
      NFUTN          = ZNFT1040-OFUTN
    EXCEPTIONS
      FOREIGN_LOCK   = 1
      SYSTEM_FAILURE = 2
      OTHERS         = 3.

  IF SY-SUBRC <> 0.
    LV_MSGV1 = SY-MSGV1.
    PV_ERROR = 'X'.

    MESSAGE S003 DISPLAY LIKE 'E'
       WITH '선물집행 번호' ZNFT1040-OFUTN
            '이(가) 현재 처리중입니다. 사용자:' LV_MSGV1.
  ENDIF.

ENDFORM.                    " ENQUEUE_ZNFT1020
*&---------------------------------------------------------------------*
*&      Form  ENQUEUE_ZNFT1040
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM ENQUEUE_ZNFT1040 USING PV_ERROR.
  DATA: LV_MSGV1  LIKE SY-MSGV1.

  CLEAR : PV_ERROR.

  CALL FUNCTION 'ENQUEUE_EZ_ZNFT1040'
    EXPORTING
      SHFNO          = GV_SHFNO
    EXCEPTIONS
      FOREIGN_LOCK   = 1
      SYSTEM_FAILURE = 2
      OTHERS         = 3.

  IF SY-SUBRC <> 0.
    LV_MSGV1 = SY-MSGV1.
    PV_ERROR = 'X'.

    MESSAGE S003 DISPLAY LIKE 'E'
       WITH '만기이동요청 번호' GV_SHFNO
            '이(가) 현재 처리중입니다. 사용자:' LV_MSGV1.
  ENDIF.

ENDFORM.                    " ENQUEUE_ZNFT1040
*&---------------------------------------------------------------------*
*&      Form  DEQUEUE_ZNFT1020
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM DEQUEUE_ZNFT1020 .

  CALL FUNCTION 'DEQUEUE_EZ_ZNFT1020'
    EXPORTING
      NFUTN = ZNFT1040-OFUTN.

ENDFORM.                    " DEQUEUE_ZNFT1020
*&---------------------------------------------------------------------*
*&      Form  DEQUEUE_ZNFT1040
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM DEQUEUE_ZNFT1040 .

  CALL FUNCTION 'DEQUEUE_EZ_ZNFT1040'
    EXPORTING
      SHFNO = ZNFT1040-SHFNO.

ENDFORM.                    " DEQUEUE_ZNFT1040
*&---------------------------------------------------------------------*
*&      Form  GET_SHIFT_REQ_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_SHIFT_REQ_DATA .

  CLEAR : ZNFT1040, ZNFT1020.

  IF GV_TRTYP = 'H'.
    ZNFT1040-BUKRS = GV_BUKRS.
    ZNFT1040-OFUTN = GV_OFUTN.
    ZNFT1040-DRSTA = '1'.
  ELSE.
    CHECK GV_SHFNO IS NOT INITIAL.

    SELECT SINGLE *
      FROM ZNFT1040
     WHERE SHFNO = GV_SHFNO.

*>CHM2110-00472 승인반려 상태 수정 가능 상태로 변경
*>CHM2112-00416 승인반려 상태 수정 불가
    IF SY-SUBRC = 0.
*      IF ZNFT1040-DRSTA NE '7'.
      IF ZNFT1040-YNCAN = 'X'.
        MESSAGE S003 DISPLAY LIKE 'E'
           WITH '만기이동요청 번호' GV_SHFNO
                '은(는) 취소된 번호입니다.'.

        IF GV_TRTYP <> 'V'.
          GV_ERROR = 'X'.

          EXIT.
*          ENDIF.
        ENDIF.
      ENDIF.
    ELSE.
      GV_ERROR = 'X'.

      MESSAGE S003 DISPLAY LIKE 'E'
         WITH '만기이동요청 번호' GV_SHFNO
              '이(가) 존재하지 않습니다.'.
      EXIT.
    ENDIF.
  ENDIF.
*>CHM2110-00472 승인반려 상태 수정 가능 상태로 변경
*>CHM2112-00416 승인반려 상태 수정 불가

*___회사코드 권한점검
  PERFORM CHECK_AUTHORIZATION USING ZNFT1040-BUKRS
                                    GV_ERROR.

  CHECK GV_ERROR IS INITIAL.

*___이동전 선물집행
  SELECT SINGLE *
    FROM ZNFT1020
   WHERE NFUTN = ZNFT1040-OFUTN.

  IF SY-SUBRC <> 0.
    GV_ERROR = 'X'.

    MESSAGE S003 DISPLAY LIKE 'E'
       WITH '이동전 선물집행번호' ZNFT1040-OFUTN
            '이(가) 존재하지 않습니다.'.
    EXIT.
  ENDIF.

  IF GV_TRTYP = 'H'.       "생성
*___이동전 선물집행 상태 점검
    PERFORM CHECK_FUTURES_TRADING_DATA USING GV_ERROR.

    CHECK GV_ERROR IS INITIAL.

*___이동전 선물집행 번호 잠금 처리
    PERFORM ENQUEUE_ZNFT1020 USING GV_ERROR.

    CHECK GV_ERROR IS INITIAL.
  ELSEIF GV_TRTYP = 'A'.   "변경
*___만기이동요청번호 변경 가능여부 점검
    PERFORM CHECK_SHIFT_REQ_DATA USING GV_ERROR.

    CHECK GV_ERROR IS INITIAL.

*___이동전 선물집행 상태 점검
    PERFORM CHECK_FUTURES_TRADING_DATA USING GV_ERROR.

    CHECK GV_ERROR IS INITIAL.

*___만기이동요청 번호 잠금 처리
    PERFORM ENQUEUE_ZNFT1040 USING GV_ERROR.

    CHECK GV_ERROR IS INITIAL.

*___이동전 선물집행 번호 잠금 처리
    PERFORM ENQUEUE_ZNFT1020 USING GV_ERROR.

    CHECK GV_ERROR IS INITIAL.
  ENDIF.

  CLEAR   : YZNFT1040,
            GT_1041, XGT_1041, YGT_1041.
  REFRESH : GT_1041, XGT_1041, YGT_1041.

*___회사코드 기본값
  PERFORM GET_DEFAULT_COMPANY_DATA USING ZNFT1040-BUKRS
                                         GV_WAERS
                                         GV_LAND1
                                         GV_BUTXT
                                         GV_KTOPL
                                         GV_KOKRS.

*___선물요청/선물계약 정보
  PERFORM GET_CONTRACT_DATA.

*___청산선물집행 정보가 존재하는 경우
*  IF SY-CALLD IS INITIAL AND ZNFT1030 IS NOT INITIAL AND
*     GV_TRTYP = 'H'.
  IF ZNFT1030 IS NOT INITIAL AND
     GV_TRTYP = 'H'.
*    PERFORM POPUP_TO_CONFIRM      "기능개선 224268 팝업창 제거
*      USING '확인'
*            '청산이 완료된 건입니다. 계속하시겠습니까?'
*            '1'
*            GV_ANSWER.
*
*    IF GV_ANSWER <> '1'.
*      GV_ERROR = 'X'.
*
**___이동전 선물집행 번호 잠금 해제
*      PERFORM DEQUEUE_ZNFT1020.
*
*      EXIT.
*    ENDIF.
  ENDIF.

*___만기이동차수
  PERFORM GET_SHIFT_COUNT(ZNFR2310) USING ZNFT1040-OFUTN
                                          GV_SHFCNT.

*___FCM 명
  PERFORM GET_LIFNR_DESC USING ZNFT1020-FCM
                               GV_NAME1.

*___사업부명
  PERFORM GET_NFCTR_DESC USING ZNFT1000-BUKRS
                               ZNFT1000-NFCTR
                               GV_NTEXT.

*___손익센터명
  PERFORM GET_PRCTR_DESC USING GV_KOKRS
                               ZNFT1000-PRCTR
                               GV_PTEXT.

*___영업그룹명
  PERFORM GET_VKGRP_DESC USING GV_KOKRS
                               ZNFT1000-VKGRP
                               GV_VTEXT.

*___가격구분/비철수주가
  PERFORM PRICE_CLASSIFICATION USING ZNFT1011-CONNO
                                     ZNFT1011-NFKEY
                                     GV_PRIND
                                     GV_SUJUP
                                     GV_ERROR.

*___고객명
  IF ZNFT1000-KUNNR IS NOT INITIAL.
    PERFORM GET_KUNNR_DESC USING ZNFT1000-KUNNR
                                 ZNFT1000-NCUST.
  ENDIF.

  IF GV_TRTYP <> 'H'.
*___만기이동요청 품목
    SELECT *
      INTO CORRESPONDING FIELDS OF TABLE GT_1041
      FROM ZNFT1041
     WHERE SHFNO = ZNFT1040-SHFNO
       AND GUBUN = '1'.

*___변경이력 관리
    YZNFT1040 = ZNFT1040.

    LOOP AT GT_1041.
      CLEAR : YGT_1041.

      MOVE-CORRESPONDING GT_1041 TO YGT_1041.

      APPEND YGT_1041.
    ENDLOOP.
  ENDIF.

  GV_CURSOR    = 'GT_1041-REMON'.
  GV_CURLIN    = 1.
  TC1-TOP_LINE = 1.

  CALL SCREEN 0200.

ENDFORM.                    " GET_SHIFT_REQ_DATA
*&---------------------------------------------------------------------*
*&      Form  CHECK_SHIFT_REQ_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM CHECK_SHIFT_REQ_DATA  USING    PV_ERROR.

  CLEAR : PV_ERROR.

  IF ZNFT1040-DRSTA <> '1' AND ZNFT1040-DRSTA <> '7'.
    PV_ERROR = 'X'.

    MESSAGE S003 DISPLAY LIKE 'E'
       WITH '만기이동요청 상태가 ''입력'' 또는 ''반려''가'
            '아닌 경우는 변경할 수 없습니다.'.
    EXIT.
  ENDIF.

ENDFORM.                    " CHECK_SHIFT_REQ_DATA
*&---------------------------------------------------------------------*
*&      Form  CHECK_FUTURES_TRADING_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM CHECK_FUTURES_TRADING_DATA  USING    PV_ERROR.
  DATA: LV_SHFNO    LIKE ZNFT1040-SHFNO.

  CLEAR : PV_ERROR.

*___생성인 경우 다른 만기이동요청에 선물집행번호가 사용되었는지 점검
  IF GV_TRTYP = 'H'.
    CLEAR : LV_SHFNO.

    SELECT SINGLE SHFNO
      INTO LV_SHFNO
      FROM ZNFT1040
     WHERE OFUTN = ZNFT1040-OFUTN
       AND YNCAN = ' '.

    IF SY-SUBRC = 0.
      PV_ERROR = 'X'.

      MESSAGE S003 DISPLAY LIKE 'E'
         WITH '이동전 선물집행번호' ZNFT1040-OFUTN
              '이(가) 이미 만기이동요청 되었습니다. 만기이동요청:'
              LV_SHFNO.
      EXIT.
    ENDIF.
  ENDIF.

  IF ZNFT1020-CONFM <> '3' AND ZNFT1020-CONFM <> '7'.
    PV_ERROR = 'X'.

    MESSAGE S003 DISPLAY LIKE 'E'
       WITH '이동전 선물집행번호' ZNFT1040-OFUTN
            '이(가) ''승인'' 또는 ''수정승인'' 상태가 아닙니다.'.
    EXIT.
  ENDIF.

  IF ZNFT1020-YNCAN = 'X'.
    PV_ERROR = 'X'.

    MESSAGE S003 DISPLAY LIKE 'E'
       WITH '이동전 선물집행번호' ZNFT1040-OFUTN
            '은(는) 취소된 선물집행번호입니다.'.
    EXIT.
  ENDIF.

  IF ZNFT1020-YNFIN = 'X'.
    PV_ERROR = 'X'.

    MESSAGE S003 DISPLAY LIKE 'E'
       WITH '이동전 선물집행번호' ZNFT1040-OFUTN
            '은(는) 정산된 선물집행번호입니다.'.
    EXIT.
  ENDIF.

  IF ZNFT1020-YNNET = 'X'.
    PV_ERROR = 'X'.

    MESSAGE S003 DISPLAY LIKE 'E'
       WITH '이동전 선물집행번호' ZNFT1040-OFUTN
            '은(는) 넷팅 처리된 선물집행번호입니다.'.
    EXIT.
  ENDIF.

  IF ZNFT1020-ENDAT < SY-DATLO.
    PV_ERROR = 'X'.

    MESSAGE S003 DISPLAY LIKE 'E'
       WITH '이동전 선물집행번호' ZNFT1040-OFUTN
            '의 만기일이 당일 이전입니다.'.
    EXIT.
  ENDIF.

ENDFORM.                    " CHECK_FUTURES_TRADING_DATA
*&---------------------------------------------------------------------*
*&      Form  GET_CONTRACT_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_CONTRACT_DATA .

  CLEAR : ZNFT1000, ZNFT1010, ZNFT1011, ZNFT1030.

*___선물요청 품목 정보
  SELECT SINGLE *
    FROM ZNFT1011
   WHERE REQNO = ZNFT1020-REQNO
     AND H_NO1 = ZNFT1020-H_NO1.

*___선물요청 헤더 정보
  SELECT SINGLE *
    FROM ZNFT1010
   WHERE REQNO = ZNFT1020-REQNO.

*___계약정보
  SELECT SINGLE *
    FROM ZNFT1000
   WHERE CONNO = ZNFT1011-CONNO.

*___청산선물집행 정보
  SELECT SINGLE *
    FROM ZNFT1030
   WHERE NFUTN =  ZNFT1020-NFUTN
     AND YNCAN =  ' '
     AND YNNET =  ' '.

ENDFORM.                    " GET_CONTRACT_DATA
*&---------------------------------------------------------------------*
*&      Form  SAVE_SHIFT_REQUEST
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM SAVE_SHIFT_REQUEST  USING  PV_FLAG.

  PERFORM CHECK_SHIFT_REQUEST USING GV_ERROR.

  CHECK GV_ERROR IS INITIAL.

  IF PV_FLAG IS INITIAL.
    PERFORM POPUP_TO_CONFIRM USING '저장'
                                   '만기이동요청을 저장하시겠습니까?'
                                   '1'
                                   GV_ANSWER.
  ELSE.
    PERFORM POPUP_TO_CONFIRM
      USING '저장'
            '만기이동요청을 결재요청 하시겠습니까?'
            '1'
            GV_ANSWER.
  ENDIF.

  IF GV_ANSWER = '1'.
    IF PV_FLAG IS NOT INITIAL.
      CLEAR : GV_PERNR, GV_ENAME.

      CALL SCREEN 0300 STARTING AT 20 5.

      IF OK_SAVE = 'CANC'.
        MESSAGE S001 WITH '작업이 취소되었습니다.'.
        EXIT.
      ENDIF.
    ENDIF.

    PERFORM SAVE_SHIFT_REQ_DATA USING PV_FLAG.
  ELSE.
    MESSAGE S001 WITH '작업이 취소되었습니다.'.
  ENDIF.

ENDFORM.                    " SAVE_SHIFT_REQUEST
*&---------------------------------------------------------------------*
*&      Form  CHECK_SHIFT_REQUEST
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM CHECK_SHIFT_REQUEST  USING PV_ERROR.
  DATA: LV_REMON LIKE ZNFT1041-REMON,
        LV_RMENG LIKE ZNFT1041-RMENG.

  CLEAR : PV_ERROR, LV_REMON, LV_RMENG.

  LOOP AT GT_1041.
    IF GT_1041-REMON IS INITIAL.
      PV_ERROR     = 'X'.
      TC1-TOP_LINE = SY-TABIX.
      GV_CURSOR    = 'GT_1041-REMON'.
      GV_CURLIN    = 1.

      MESSAGE S003 DISPLAY LIKE 'E'
         WITH '항번' GT_1041-H_NO1
              '의 만기월이 입력되지 않았습니다.'.
      EXIT.
    ENDIF.

    IF GT_1041-RMENG IS INITIAL.
      PV_ERROR     = 'X'.
      TC1-TOP_LINE = SY-TABIX.
      GV_CURSOR    = 'GT_1041-RMENG'.
      GV_CURLIN    = 1.

      MESSAGE S003 DISPLAY LIKE 'E'
         WITH '항번' GT_1041-H_NO1
              '의 요청수량이 입력되지 않았습니다.'.
      EXIT.
    ENDIF.

    LV_RMENG = LV_RMENG + GT_1041-RMENG.

    IF LV_REMON IS INITIAL.
      LV_REMON = GT_1041-REMON.
    ELSE.
      IF GT_1041-REMON = LV_REMON.
        PV_ERROR     = 'X'.
        TC1-TOP_LINE = SY-TABIX.
        GV_CURSOR    = 'GT_1041-RMENG'.
        GV_CURLIN    = 1.

        MESSAGE S003 DISPLAY LIKE 'E'
           WITH '만기월이 동일한 품목이 존재합니다.'.
      ENDIF.
    ENDIF.
  ENDLOOP.

  IF LV_RMENG > ZNFT1020-EMENG.
    PV_ERROR     = 'X'.
    TC1-TOP_LINE = 1.
    GV_CURSOR    = 'GT_1041-RMENG'.
    GV_CURLIN    = 1.

    MESSAGE S003 DISPLAY LIKE 'E'
       WITH '요청수량의 합이 신규선물 집행수량을'
            '초과하였습니다.'.
  ENDIF.

ENDFORM.                    " CHECK_SHIFT_REQUEST
*&---------------------------------------------------------------------*
*&      Form  CHECK_APPLOVAL_USER
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM CHECK_APPLOVAL_USER  USING    PV_PERNR.
  DATA: LV_USRID LIKE ZPA0105-USRID,
*        LV_USRID LIKE PA0105-USRID  " [MM] HR 테이블 대체
        LV_COMM.

*___사번 존재여부
*  SELECT SINGLE ENAME
*    INTO GV_ENAME
*    FROM PA0001
*   WHERE PERNR =  PV_PERNR
*     AND ENDDA >= SY-DATLO
*     AND BEGDA <= SY-DATLO.

*- [MM] HR 테이블 변경
  SELECT SINGLE ENAME
    INTO GV_ENAME
    FROM ZZPA0001
   WHERE PERNR =  PV_PERNR
     AND ENDDA >= SY-DATLO
     AND BEGDA <= SY-DATLO.
*- [MM] HR 테이블 변경

  IF SY-SUBRC <> 0.
    MESSAGE E003 WITH '결재자 사번이 존재하지 않습니다.'.
  ENDIF.

*___결재자 사번의 SAP ID 점검
  PERFORM GET_SAPID_PER_USRID  USING PV_PERNR
                                     LV_USRID
                                     LV_COMM.
  IF LV_USRID IS INITIAL.
    MESSAGE E003 WITH '결재자 사번의 SAP ID를 찾지 못했습니다.'.
  ENDIF.

*___사번의 권한 점검
  CLEAR : ZNFT1090.

  SELECT SINGLE *
    FROM ZNFT1090
   WHERE BUKRS = ZNFT1040-BUKRS
     AND CONGB = '5'
     AND CONSQ = '1'
     AND PERNR = PV_PERNR
     AND LVORM = ' '.

  IF SY-SUBRC <> 0.
    MESSAGE E003 WITH '결재자 사번이 권한 마스터에'
                      '존재하지 않습니다.'.
*  ELSE.
*    IF ZNFT1090-CONGB <> '5' OR ZNFT1090-CONSQ <> '1'.
*      MESSAGE E003 WITH '만기이동요청 1단계 결재자 사번이 아닙니다.'.
*    ENDIF.
  ENDIF.

ENDFORM.                    " CHECK_APPLOVAL_USER
*&---------------------------------------------------------------------*
*&      Form  SAVE_SHIFT_REQ_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM SAVE_SHIFT_REQ_DATA  USING  PV_FLAG.
  DATA: LV_FLAG.

*___잔량에 대한 품목 생성
  PERFORM CREATE_REMAIN_QTY_ITEM.

*___헤더정보 생성
  IF GV_TRTYP = 'H'.
    PERFORM GET_SHIFT_REQUEST_NO.

    IF PV_FLAG = 'X'.
      ZNFT1040-DRSTA = '2'.   "승인대기
    ELSE.
      ZNFT1040-DRSTA = '1'.   "입력
    ENDIF.

    ZNFT1040-ERDAT = SY-DATLO.
    ZNFT1040-ERZET = SY-TIMLO.
    ZNFT1040-ERNAM = SY-UNAME.

    GT_1041-SHFNO = ZNFT1040-SHFNO.

    MODIFY GT_1041 TRANSPORTING SHFNO
                   WHERE H_NO1 IS NOT INITIAL.
  ELSE.
    IF PV_FLAG = 'X'.
      ZNFT1040-DRSTA = '2'.
    ENDIF.
  ENDIF.

  ZNFT1040-AEDAT = SY-DATLO.
  ZNFT1040-AEZET = SY-TIMLO.
  ZNFT1040-AENAM = SY-UNAME.

*___결재이력 삭제
  DELETE FROM ZNFT1091 WHERE NFNUM = ZNFT1040-SHFNO.

  IF GT_1041D[] IS NOT INITIAL.
    DELETE ZNFT1041 FROM TABLE GT_1041D.
  ENDIF.

  DELETE FROM ZNFT1041 WHERE SHFNO = ZNFT1040-SHFNO
                         AND GUBUN = '2'.

  MODIFY ZNFT1040 FROM ZNFT1040.
  IF SY-SUBRC = 0.
    MODIFY ZNFT1041 FROM TABLE GT_1041.
    IF SY-SUBRC = 0.
*___변경이력 저장
      PERFORM SAVE_CHANGE_DOC USING ' '.

      IF PV_FLAG = 'X'.
*___만기이동요청 메일 전송
        PERFORM SEND_EMAIL USING LV_FLAG.
*___승인요청정보
        PERFORM SAVE_APPROVE_REQUEST USING GV_ERROR.

        IF GV_ERROR IS INITIAL.
*--- 간편결재 전송.
          PERFORM SEND_SIMPLE_APPROVAL
          USING ZNFT1040-SHFNO
                ZNFT1040-BUKRS
                '2B'.
        ENDIF.
      ELSE.
        COMMIT WORK.
      ENDIF.

      IF PV_FLAG IS INITIAL.
        MESSAGE S010 WITH '만기이동요청번호' ZNFT1040-SHFNO.

        IF GV_TRTYP = 'H' AND SY-CALLD IS INITIAL.
          SET PARAMETER ID 'ZNFSHF' FIELD ZNFT1040-SHFNO.

          LEAVE TO TRANSACTION 'ZNF2M2302' AND SKIP FIRST SCREEN.
        ELSE.
*___다른 프로그램에서 호출된 경우 저장 후 변경으로 인식하기 위해
          GV_TRTYP = 'A'.

*___변경이력 초기화
          CLEAR   : XGT_1041, YGT_1041, YZNFT1040.
          REFRESH : XGT_1041, YGT_1041.

          YZNFT1040 = ZNFT1040.

          LOOP AT GT_1041.
*___자동생성된 잔량 데이터가 화면상에서 보이지 않도록 하기위해 삭제
            IF GT_1041-GUBUN = '2'.
              DELETE GT_1041.
              CONTINUE.
            ENDIF.

            CLEAR : YGT_1041, GT_1041-UPDKZ.

            MOVE-CORRESPONDING GT_1041 TO YGT_1041.

            APPEND YGT_1041.

            MODIFY GT_1041.
          ENDLOOP.
        ENDIF.
      ELSE.
        IF LV_FLAG = 'X'.
          MESSAGE I003 WITH '결재요청 메일전송을 실패하였습니다.'.
        ENDIF.

        MESSAGE S011 WITH '만기이동요청번호' ZNFT1040-SHFNO.

        IF SY-CALLD = 'X'.
          LEAVE PROGRAM.
        ELSE.
          LEAVE TO SCREEN 0.
        ENDIF.
      ENDIF.
    ELSE.
      ROLLBACK WORK.

      MESSAGE S003 DISPLAY LIKE 'E'
         WITH '만기이동요청 품목 정보 저장 에러!'.
    ENDIF.
  ELSE.
    ROLLBACK WORK.

    MESSAGE S003 DISPLAY LIKE 'E'
       WITH '만기이동요청 헤더 정보 저장 에러!'.
  ENDIF.

ENDFORM.                    " SAVE_SHIFT_REQ_DATA
*&---------------------------------------------------------------------*
*&      Form  GET_SHIFT_REQUEST_NO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_SHIFT_REQUEST_NO .

  CLEAR : ZNFT1040-SHFNO.

  CALL FUNCTION 'NUMBER_GET_NEXT'
    EXPORTING
      NR_RANGE_NR             = '10'
      OBJECT                  = 'ZNF2_00005'
    IMPORTING
      NUMBER                  = ZNFT1040-SHFNO
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

ENDFORM.                    " GET_SHIFT_REQUEST_NO
*&---------------------------------------------------------------------*
*&      Form  SAVE_APPROVE_REQUEST
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM SAVE_APPROVE_REQUEST  USING PV_ERROR.
  DATA: LV_COMM.

  CLEAR   : ZNFT1091, PV_ERROR.

  ZNFT1091-NFNUM = ZNFT1040-SHFNO.
  ZNFT1091-CONSQ = '1'.
  ZNFT1091-CONGB = '5'.
  ZNFT1091-BUKRS = ZNFT1040-BUKRS.
  ZNFT1091-PERNR = GV_PERNR.
  ZNFT1091-CONST = 'B'.
  ZNFT1091-ERDAT = SY-DATLO.
  ZNFT1091-ERZET = SY-TIMLO.
  ZNFT1091-ERNAM = SY-UNAME.
  ZNFT1091-AEDAT = SY-DATLO.
  ZNFT1091-AEZET = SY-TIMLO.
  ZNFT1091-AENAM = SY-UNAME.

*___사용자 ID
  PERFORM GET_SAPID_PER_USRID USING ZNFT1091-PERNR
                                    ZNFT1091-USRID
                                    LV_COMM.

  IF ZNFT1091-USRID IS INITIAL.
    ROLLBACK WORK.

    PV_ERROR = 'X'.

    MESSAGE S003 DISPLAY LIKE 'E'
       WITH '사용자 ID를 찾지 못했습니다.'.
    EXIT.
  ENDIF.

  INSERT ZNFT1091 FROM ZNFT1091.
  IF SY-SUBRC = 0.
    COMMIT WORK.
  ELSE.
    ROLLBACK WORK.

    PV_ERROR = 'X'.

    MESSAGE S003 DISPLAY LIKE 'E'
       WITH '만기이동 승인요청 저장 에러!'.
  ENDIF.

ENDFORM.                    " SAVE_APPROVE_REQUEST
*&---------------------------------------------------------------------*
*&      Form  SAVE_CHANGE_DOC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM SAVE_CHANGE_DOC  USING  PV_FLAG.
  DATA: LV_OBJECTID        TYPE CDHDR-OBJECTID,
        LV_TCODE           TYPE CDHDR-TCODE,
        LV_CDOC_UPD_OBJECT TYPE CDHDR-CHANGE_IND,
        LV_UPD_ICDTXT      TYPE CHAR1.

  IF PV_FLAG = 'D'.
    LV_CDOC_UPD_OBJECT = 'D'.
  ELSE.
    IF GV_TRTYP = 'H'.
      LV_CDOC_UPD_OBJECT = 'I'.
    ELSE.
      LV_CDOC_UPD_OBJECT = 'U'.
    ENDIF.
  ENDIF.

  LOOP AT GT_1041 WHERE GUBUN = '1'.
    CLEAR : XGT_1041.

    MOVE-CORRESPONDING GT_1041 TO XGT_1041.

    XGT_1041-KZ = GT_1041-UPDKZ.

    APPEND XGT_1041.
  ENDLOOP.

  LV_OBJECTID = ZNFT1040-SHFNO.
  LV_TCODE    = SY-TCODE.

  CALL FUNCTION 'ZNFT1040CHDOC_WRITE_DOCUMENT'
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
      N_ZNFT1040   = ZNFT1040
      O_ZNFT1040   = YZNFT1040
      UPD_ZNFT1040 = LV_CDOC_UPD_OBJECT
      UPD_ZNFT1041 = LV_CDOC_UPD_OBJECT
    TABLES
      XZNFT1041    = XGT_1041
      YZNFT1041    = YGT_1041.

ENDFORM.                    " SAVE_CHANGE_DOC
*&---------------------------------------------------------------------*
*&      Form  GET_NEXT_SEQ
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM GET_NEXT_SEQ  USING  PV_H_NO1.
  DATA: LS_1041     LIKE GT_1041.

  CLEAR : PV_H_NO1.

  LOOP AT GT_1041 INTO LS_1041.
    IF LS_1041-H_NO1 > PV_H_NO1.
      PV_H_NO1 = LS_1041-H_NO1.
    ENDIF.
  ENDLOOP.

  PV_H_NO1 = PV_H_NO1 + 1.

ENDFORM.                    " GET_NEXT_SEQ
*&---------------------------------------------------------------------*
*&      Form  DELETE_FUTURES_REQ
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM DELETE_FUTURES_REQ .

  PERFORM POPUP_TO_CONFIRM
    USING '삭제'
          '만기이동요청 전체 정보가 삭제됩니다. 계속하시겠습니까?'
          '2'
          GV_ANSWER.

  IF GV_ANSWER = '1'.
    DELETE FROM ZNFT1040 WHERE SHFNO = ZNFT1040-SHFNO.
    IF SY-SUBRC = 0.
      DELETE FROM ZNFT1041 WHERE SHFNO = ZNFT1040-SHFNO.
      IF SY-SUBRC = 0.
        COMMIT WORK.

        PERFORM SAVE_CHANGE_DOC USING 'D'.

        MESSAGE S003 WITH '만기이동요청번호'
                          ZNFT1040-SHFNO
                          '이(가) 삭제되었습니다.'.

        IF SY-CALLD = 'X'.
          LEAVE PROGRAM.
        ELSE.
          LEAVE TO SCREEN 0.
        ENDIF.
      ELSE.
        ROLLBACK WORK.

        MESSAGE E003 WITH '만기이동요청 품목 삭제 에러.'.
      ENDIF.
    ELSE.
      ROLLBACK WORK.

      MESSAGE E003 WITH '만기이동요청 헤더 삭제 에러.'.
    ENDIF.
  ELSE.
    MESSAGE S003 WITH '작업이 취소되었습니다.'.
  ENDIF.

ENDFORM.                    " DELETE_FUTURES_REQ
*&---------------------------------------------------------------------*
*&      Form  APPEND_ROW
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM APPEND_ROW .

  DESCRIBE TABLE GT_1041 LINES TC1-TOP_LINE.
  IF TC1-TOP_LINE IS INITIAL.
    TC1-TOP_LINE = 1.
  ENDIF.
*  TC1-TOP_LINE = TC1-LINES.

  GV_CURSOR = 'GT_1041-REMON'.

  IF TC1-LINES IS INITIAL.
    GV_CURLIN = 1.
  ELSE.
    GV_CURLIN = 2.
  ENDIF.

ENDFORM.                    " APPEND_ROW
*&---------------------------------------------------------------------*
*&      Form  DELETE_ROW
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM DELETE_ROW .

  PERFORM CHECK_SELECTED_ROW USING GV_ERROR.

  CHECK GV_ERROR IS INITIAL.

  PERFORM POPUP_TO_CONFIRM USING '행삭제'
                                 '선택한 라인을 삭제하시겠습니까?'
                                 '2'
                                 GV_ANSWER.
  IF GV_ANSWER = '1'.
    LOOP AT GT_1041 WHERE CHECK = 'X'.
      IF GT_1041-UPDKZ <> 'I'.
        CLEAR : GT_1041D.

        MOVE-CORRESPONDING GT_1041 TO GT_1041D.

        APPEND GT_1041D.
      ENDIF.

      DELETE GT_1041.
    ENDLOOP.

    IF GV_TRTYP = 'H'.   "생성
      LOOP AT GT_1041.
        GT_1041-H_NO1 = SY-TABIX.

        MODIFY GT_1041.
      ENDLOOP.
    ENDIF.

    MESSAGE S003 WITH '삭제되었습니다.'.
  ELSE.
    MESSAGE S003 WITH '작업이 취소되었습니다.'.
  ENDIF.

ENDFORM.                    " DELETE_ROW
*&---------------------------------------------------------------------*
*&      Form  CHECK_SELECTED_ROW
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM CHECK_SELECTED_ROW  USING    PV_ERROR.
  DATA: LV_CNT      TYPE I.

  CLEAR : PV_ERROR, LV_CNT.

  LOOP AT GT_1041 WHERE CHECK = 'X'.
    LV_CNT = LV_CNT + 1.
  ENDLOOP.

  IF LV_CNT < 1.
    PV_ERROR = 'X'.

    MESSAGE S003 DISPLAY LIKE 'E'
       WITH '선택된 행이 없습니다.'.
  ENDIF.

ENDFORM.                    " CHECK_SELECTED_ROW
*&---------------------------------------------------------------------*
*&      Form  SELECT_ALL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SELECT_ALL .

  IF OK_SAVE = 'ASEL'.
    GT_1041-CHECK = 'X'.
  ELSE.
    CLEAR : GT_1041-CHECK.
  ENDIF.

  MODIFY GT_1041 TRANSPORTING CHECK
                 WHERE H_NO1 IS NOT INITIAL.

ENDFORM.                    " SELECT_ALL
*&---------------------------------------------------------------------*
*&      Form  DISPLAY_CHANGE_HISTORY
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM DISPLAY_CHANGE_HISTORY .
  DATA: LT_RSPAR LIKE RSPARAMS OCCURS 0 WITH HEADER LINE.

*- 2023.12.04 ZLSGMM4, 변경 이력 수정
  DATA: LV_OBJCLS   LIKE CDHDR-OBJECTCLAS.

  LV_OBJCLS = 'ZNFT1040CHDOC'.

  SELECT SINGLE OBJECTCLAS
    INTO LV_OBJCLS
    FROM CDHDR
   WHERE OBJECTCLAS = LV_OBJCLS
     AND OBJECTID   = ZNFT1040-SHFNO.

  IF SY-SUBRC <> 0.
    MESSAGE S002 DISPLAY LIKE 'E'
       WITH '변경이력이 없습니다.'.

    EXIT.
  ENDIF.

  CLEAR   : LT_RSPAR.
  REFRESH : LT_RSPAR.

  LT_RSPAR-SELNAME = 'OBJEKT'.
  LT_RSPAR-KIND    = 'P'.
*  LT_RSPAR-LOW     = 'ZNFT1040CHDOC'.
  LT_RSPAR-LOW     = LV_OBJCLS.
  APPEND LT_RSPAR.

  CLEAR : LT_RSPAR.
  LT_RSPAR-SELNAME = 'OBJEKTID'.
  LT_RSPAR-KIND    = 'P'.
  LT_RSPAR-LOW     = ZNFT1040-SHFNO.
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
*&      Form  CREATE_REMAIN_QTY_ITEM
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM CREATE_REMAIN_QTY_ITEM .
  DATA: LV_RMENG    LIKE ZNFT1041-RMENG.

  CLEAR : LV_RMENG.

  LOOP AT GT_1041.
    LV_RMENG = LV_RMENG + GT_1041-RMENG.
  ENDLOOP.

  IF LV_RMENG <> ZNFT1020-EMENG.
    CLEAR : GT_1041.
    PERFORM GET_NEXT_SEQ USING GT_1041-H_NO1.

    GT_1041-SHFNO = ZNFT1040-SHFNO.
    GT_1041-REMON = ZNFT1020-ENDAT(6).
    GT_1041-RMENG = ZNFT1020-EMENG - LV_RMENG.
    GT_1041-GUBUN = '2'.
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

    APPEND GT_1041.
  ENDIF.

ENDFORM.                    " CREATE_REMAIN_QTY_ITEM
*&---------------------------------------------------------------------*
*&      Form  DISPLAY_FUTRUES_HISTORY
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM DISPLAY_FUTRUES_HISTORY USING PV_FLAG
                                   PV_FUTNO.
  DATA: LT_RSPAR LIKE RSPARAMS OCCURS 0 WITH HEADER LINE.

  CLEAR   : LT_RSPAR.
  REFRESH : LT_RSPAR.

  APPEND_PARAM : LT_RSPAR 'P_BUKRS' 'P' ' ' ' '  ZNFT1020-BUKRS  ' '.

  IF PV_FLAG = 'N'.
    APPEND_PARAM : LT_RSPAR 'S_NFUTN' 'S' 'I' 'EQ' PV_FUTNO        ' ',
                   LT_RSPAR 'P_CHK11' 'P' ' ' ' '  'X'             ' ',
                   LT_RSPAR 'P_CHK12' 'P' ' ' ' '  ' '             ' '.
  ELSE.
    APPEND_PARAM : LT_RSPAR 'S_CFUTN' 'S' 'I' 'EQ' PV_FUTNO        ' ',
                   LT_RSPAR 'P_CHK11' 'P' ' ' ' '  ' '             ' ',
                   LT_RSPAR 'P_CHK12' 'P' ' ' ' '  'X'             ' '.
  ENDIF.

  APPEND_PARAM : LT_RSPAR 'P_R01'   'P' ' ' ' '  ' '             ' ',
                 LT_RSPAR 'P_R02'   'P' ' ' ' '  ' '             ' ',
                 LT_RSPAR 'P_R03'   'P' ' ' ' '  'X'             ' ',
                 LT_RSPAR 'P_R11'   'P' ' ' ' '  ' '             ' ',
                 LT_RSPAR 'P_R12'   'P' ' ' ' '  ' '             ' ',
                 LT_RSPAR 'P_R13'   'P' ' ' ' '  'X'             ' ',
                 LT_RSPAR 'P_R21'   'P' ' ' ' '  ' '             ' ',
                 LT_RSPAR 'P_R22'   'P' ' ' ' '  ' '             ' ',
                 LT_RSPAR 'P_R23'   'P' ' ' ' '  'X'             ' '.

  SUBMIT ZNFR2600 WITH SELECTION-TABLE LT_RSPAR
                   AND RETURN.

ENDFORM.                    " DISPLAY_FUTRUES_HISTORY
*&---------------------------------------------------------------------*
*&      Form  SEND_EMAIL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SEND_EMAIL USING PV_FLAG.
  DATA: RESULT_TAB  TYPE MATCH_RESULT_TAB.

  CLEAR : PV_FLAG.

  PERFORM FILL_EMAIL_CONTENTS.

  IF GV_ADDRESS IS INITIAL.
    PV_FLAG = 'X'.
    EXIT.
  ENDIF.

  TRY.
      GC_EMAIL = CL_BCS=>CREATE_PERSISTENT( ).

      GC_EMAIL_BODY = CL_DOCUMENT_BCS=>CREATE_DOCUMENT(
                                            I_TYPE    = 'HTM'
                                            I_TEXT    = GT_MESSAGE
                                            I_SUBJECT = GV_SUBJECT ).

*     첨부
*      PERFORM add_attachment USING g_email_body.

      GC_EMAIL->SET_DOCUMENT( GC_EMAIL_BODY ).

      GF_RECEIVER =
      CL_CAM_ADDRESS_BCS=>CREATE_INTERNET_ADDRESS( GV_ADDRESS ).

      GC_EMAIL->ADD_RECIPIENT( I_RECIPIENT = GF_RECEIVER
                               I_EXPRESS   = 'X' ).

      GC_EMAIL->SET_SEND_IMMEDIATELY( 'X' ).

      GC_EMAIL->SEND( EXPORTING I_WITH_ERROR_SCREEN = 'X'
                      RECEIVING RESULT              = GV_SEND_RESULT ).

    CATCH CX_BCS INTO GC_EXCEPTION.
      PV_FLAG = 'X'.

  ENDTRY.

ENDFORM.                    " SEND_EMAIL
*&---------------------------------------------------------------------*
*&      Form  FILL_EMAIL_CONTENTS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM FILL_EMAIL_CONTENTS .
  DATA: LS_MESSAGE  LIKE SOLI.

*___수신자
  CLEAR : GV_ADDRESS.

  IF SY-SYSID = 'R3T'.
    GV_ADDRESS = 'jhyukim@lscns.com'.
  ELSE.
*    SELECT SINGLE USRID
*      INTO GV_ADDRESS
*      FROM PA0105
*     WHERE PERNR = GV_PERNR
*       AND SUBTY = '0007'
*       AND ENDDA >= SY-DATLO
*       AND BEGDA <= SY-DATLO.

*- [MM] HR 테이블 대체
    SELECT SINGLE USRID
      INTO GV_ADDRESS
      FROM ZPA0105
     WHERE PERNR = GV_PERNR
       AND SUBTY = '0007'
       AND ENDDA >= SY-DATLO
       AND BEGDA <= SY-DATLO.
*- [MM] HR 테이블 대체
  ENDIF.

  CHECK GV_ADDRESS IS NOT INITIAL.

*___메일 제목
  GV_SUBJECT = '만기이동요청에 대한 승인요청'.

  CLEAR   : LS_MESSAGE.
  REFRESH : GT_MESSAGE.

*___메일 내용
  PERFORM APPEND_MESSAGE USING : '<html>',
                                 '<body>',
                                 '만기이동요청<br>',
                                 '<br>'.

  CONCATENATE ZNFT1040-SHFNO '(계약명:' ZNFT1000-COTXT ')<br>'
         INTO LS_MESSAGE. " SEPARATED BY SPACE.

  PERFORM APPEND_MESSAGE USING : LS_MESSAGE,
                                 '<br>',
                                 '에 대해 승인바랍니다.<br>',
                                 '<br>',
                                 '<br>',
                                 '감사합니다.<br>',
                                 '</body>',
                                 '</html>'.

ENDFORM.                    " FILL_EMAIL_CONTENTS
*&---------------------------------------------------------------------*
*&      Form  APPEND_MESSAGE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM APPEND_MESSAGE  USING    PS_MESSAGE.

  APPEND PS_MESSAGE TO GT_MESSAGE.

ENDFORM.                    " APPEND_MESSAGE
*&---------------------------------------------------------------------*
*& Form SEND_SIMPLE_APPROVAL
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> ZNFT1040_SHFNO
*&      --> ZNFT1040_BUKRS
*&      --> P_
*&---------------------------------------------------------------------*
FORM SEND_SIMPLE_APPROVAL  USING    P_EXENO
                                    P_BUKRS
                                    P_TYPE TYPE ZESAZTYPE.

  CALL FUNCTION 'ZSA1_MM_MAKE_SEND_DATA'
    EXPORTING
      I_BUKRS = P_BUKRS
      I_EXENO = P_EXENO
      I_EXTYP = P_TYPE.

ENDFORM.
