*&---------------------------------------------------------------------*
*&  Include           MZNF2100F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  GET_FUTURES_REQ_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_FUTURES_REQ_DATA .

  CLEAR : ZNFT1010.

  IF GV_TRTYP = 'H'.
    ZNFT1010-BUKRS = GV_BUKRS.
    ZNFT1010-RQTYP = GV_RQTYP.
    ZNFT1010-RSTAT = '1'.
  ELSE.
    CHECK GV_REQNO IS NOT INITIAL.

    SELECT SINGLE *
      FROM ZNFT1010
     WHERE REQNO = GV_REQNO.

    IF SY-SUBRC <> 0.
      GV_ERROR = 'X'.

      MESSAGE S003 DISPLAY LIKE 'E'
         WITH '선물요청 번호' GV_REQNO
              '이(가) 존재하지 않습니다.'.
      EXIT.
    ENDIF.
  ENDIF.

  IF GV_TRTYP = 'A'.   "변경
*___선물요청번호 변경 가능여부 점검
    PERFORM CHECK_FUTURES_REQ_DATA USING GV_ERROR.

    CHECK GV_ERROR IS INITIAL.

*___선물요청 번호 잠금 처리
    PERFORM ENQUEUE_ZNFT1010 USING GV_ERROR.

    CHECK GV_ERROR IS INITIAL.
  ENDIF.

*___회사코드 권한점검
  PERFORM CHECK_AUTHORIZATION USING ZNFT1010-BUKRS
                                    GV_ERROR.

  CHECK GV_ERROR IS INITIAL.

  CLEAR   : YZNFT1010, GV_RQTXT, GV_RSTXT,
            GT_1011, GT_1011N, GT_1011D, XGT_1011, YGT_1011.
  REFRESH : GT_1011, GT_1011N, GT_1011D, XGT_1011, YGT_1011.

*___회사코드 기본값
  PERFORM GET_DEFAULT_COMPANY_DATA USING ZNFT1010-BUKRS
                                         GV_WAERS
                                         GV_LAND1
                                         GV_BUTXT
                                         GV_KTOPL
                                         GV_KOKRS.

*___요청유형 내역
  PERFORM DOMAIN_VALUE_GET USING 'ZRQTYP_1'
                                 ZNFT1010-RQTYP
                                 GV_RQTXT.

*___결재상태 내역
  PERFORM DOMAIN_VALUE_GET USING 'ZRSTAT'
                                 ZNFT1010-RSTAT
                                 GV_RSTXT.

  IF GV_TRTYP <> 'H'.
*___선물요청 품목
    SELECT *
      INTO CORRESPONDING FIELDS OF TABLE GT_1011
      FROM ZNFT1011
     WHERE REQNO = ZNFT1010-REQNO.

    LOOP AT GT_1011.
*___계약정보
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

*___가격구분/비철수주가
      PERFORM PRICE_CLASSIFICATION USING GT_1011-CONNO
                                         GT_1011-NFKEY
                                         GT_1011-PRIND
                                         GT_1011-SUJUP
                                         GV_ERROR.

      MODIFY GT_1011.
    ENDLOOP.

*___변경이력 관리
    YZNFT1010 = ZNFT1010.

    LOOP AT GT_1011.
      CLEAR : YGT_1011.

      MOVE-CORRESPONDING GT_1011 TO YGT_1011.

      APPEND YGT_1011.
    ENDLOOP.
  ENDIF.

  GV_CURSOR = 'GT_1011-NFKEY'.
  GV_CURLIN = 1.

  CALL SCREEN 0200.

ENDFORM.                    " GET_FUTURES_REQ_DATA
*&---------------------------------------------------------------------*
*&      Form  ENQUEUE_ZNFT1010
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM ENQUEUE_ZNFT1010 USING PV_ERROR.
  DATA: LV_MSGV1  LIKE SY-MSGV1.

  CLEAR : PV_ERROR.

  CALL FUNCTION 'ENQUEUE_EZ_ZNFT1010'
    EXPORTING
      REQNO          = GV_REQNO
    EXCEPTIONS
      FOREIGN_LOCK   = 1
      SYSTEM_FAILURE = 2
      OTHERS         = 3.

  IF SY-SUBRC <> 0.
    LV_MSGV1 = SY-MSGV1.
    PV_ERROR = 'X'.

    MESSAGE S003 DISPLAY LIKE 'E'
       WITH '선물요청 번호' GV_REQNO
            '이(가) 현재 처리중입니다. 사용자:' LV_MSGV1.
  ENDIF.

ENDFORM.                    " ENQUEUE_ZNFT1010
*&---------------------------------------------------------------------*
*&      Form  DEQUEUE_ZNFT1010
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM DEQUEUE_ZNFT1010 .

  CALL FUNCTION 'DEQUEUE_EZ_ZNFT1010'
    EXPORTING
      REQNO = ZNFT1010-REQNO.

ENDFORM.                    " DEQUEUE_ZNFT1010
*&---------------------------------------------------------------------*
*&      Form  CHECK_FUTURES_REQ_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM CHECK_FUTURES_REQ_DATA  USING    PV_ERROR.

  CLEAR : PV_ERROR.

  IF ZNFT1010-RSTAT <> '1' AND ZNFT1010-RSTAT <> '7'.
    PV_ERROR = 'X'.

    MESSAGE S003 DISPLAY LIKE 'E'
       WITH '선물요청 상태가 ''입력'' 또는 ''반려''가'
            '아닌 경우는 변경할 수 없습니다.'.
  ENDIF.

ENDFORM.                    " CHECK_FUTURES_REQ_DATA
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

  LV_OBJCLS = 'ZNFT1010CHDOC'.

  SELECT SINGLE OBJECTCLAS
    INTO LV_OBJCLS
    FROM CDHDR
   WHERE OBJECTCLAS = LV_OBJCLS
     AND OBJECTID   = ZNFT1010-REQNO.

  IF SY-SUBRC <> 0.
    MESSAGE S002 DISPLAY LIKE 'E'
       WITH '변경이력이 없습니다.'.

    EXIT.
  ENDIF.

  CLEAR   : LT_RSPAR.
  REFRESH : LT_RSPAR.

  LT_RSPAR-SELNAME = 'OBJEKT'.
  LT_RSPAR-KIND    = 'P'.
*  LT_RSPAR-LOW     = 'ZNFT1010CHDOC'.
  LT_RSPAR-LOW     = LV_OBJCLS.
  APPEND LT_RSPAR.

  CLEAR : LT_RSPAR.
  LT_RSPAR-SELNAME = 'OBJEKTID'.
  LT_RSPAR-KIND    = 'P'.
  LT_RSPAR-LOW     = ZNFT1010-REQNO.
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
*&      Form  GET_CONTRACT_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM GET_CONTRACT_DATA  USING    PV_CONNO
                                 PV_NFCTR
                                 PV_PRCTR
                                 PV_VKGRP
                                 PV_COTYP
                                 PV_COTXT
                                 PV_KUNNR
                                 PV_NCUST
                                 PV_SALER
                                 PV_ERROR.
  DATA: LV_CSTAT    LIKE ZNFT1000-CSTAT.

  CLEAR : PV_NFCTR, PV_PRCTR, PV_VKGRP, PV_COTYP,
          PV_COTXT, PV_KUNNR, PV_NCUST, PV_SALER,
          PV_ERROR, LV_CSTAT.

  CHECK PV_CONNO IS NOT INITIAL.

  SELECT SINGLE NFCTR   "사업부
                PRCTR   "손익센터
                VKGRP   "영업그룹
                COTYP   "계약유형
                COTXT   "계약명
                KUNNR   "고객코드
                NCUST   "고객명
                SALER   "영업담당자
                CSTAT   "계약-상태
    INTO (PV_NFCTR, PV_PRCTR,
          PV_VKGRP, PV_COTYP,
          PV_COTXT, PV_KUNNR,
          PV_NCUST, PV_SALER,
          LV_CSTAT)
    FROM ZNFT1000
   WHERE CONNO = PV_CONNO.

  IF SY-SUBRC = 0.
    IF LV_CSTAT = 'L'.
*___고객명
      IF PV_KUNNR IS NOT INITIAL.
        PERFORM GET_KUNNR_DESC USING PV_KUNNR
                                     PV_NCUST.
      ENDIF.
    ELSE.
      PV_ERROR = 'D'.
    ENDIF.
  ELSE.
    PV_ERROR = 'X'.
  ENDIF.

ENDFORM.                    " GET_CONTRACT_DATA
*&---------------------------------------------------------------------*
*&      Form  GET_CONTRACT_INFO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_CONTRACT_INFO USING PV_RQTYP.

  RANGES: LR_COTYP  FOR ZNFT1000-COTYP,
          LR_NFKEY  FOR ZNFT1001-NFKEY,
          LR_CDATE  FOR ZNFT1000-ERDAT.

  CLEAR   : GT_CONNO, LR_COTYP, LR_NFKEY.
  REFRESH : GT_CONNO, LR_COTYP, LR_NFKEY.

  IF GT_1011-NFKEY IS NOT INITIAL.
    LR_NFKEY-SIGN   = 'I'.
    LR_NFKEY-OPTION = 'EQ'.
    LR_NFKEY-LOW    = GT_1011-NFKEY.
    APPEND LR_NFKEY.
  ENDIF.

  LR_COTYP-SIGN   = 'I'.
  LR_COTYP-OPTION = 'EQ'.
  LR_COTYP-LOW    = PV_RQTYP.
  APPEND LR_COTYP.

*.최근 한달내에 생성된 계약건만 조회.
  LR_CDATE-SIGN   = 'I'.
  LR_CDATE-OPTION = 'BT'.
  LR_CDATE-LOW    = SY-DATUM - 30.
  LR_CDATE-HIGH   = SY-DATUM.
  APPEND LR_CDATE.

*  CASE ZNFT1010-RQTYP.
*    WHEN '1' OR '2'.      "Firm Price/고객요청
*      LR_COTYP-LOW = '1'.  APPEND LR_COTYP.
*      LR_COTYP-LOW = '2'.  APPEND LR_COTYP.
*
*    WHEN '3'.      "경상선물
*      LR_COTYP-LOW = '1'.  APPEND LR_COTYP.
*      LR_COTYP-LOW = '2'.  APPEND LR_COTYP.
*      LR_COTYP-LOW = '3'.  APPEND LR_COTYP.
*
*    WHEN '4'.      "내부선물
*      LR_COTYP-LOW = '4'.  APPEND LR_COTYP.
*
*    WHEN '5'.      "재고헷지
*      LR_COTYP-LOW = '5'.  APPEND LR_COTYP.
*
*  ENDCASE.

  SELECT A~COTYP  "계약유형
         A~NFCTR  "사업부
         A~PRCTR  "손익센터
         A~VKGRP  "영업그룹
         A~CONNO  "계약번호
         A~ERDAT  "생성일
         A~COTXT  "계약명(PJT명)
         A~KUNNR  "고객코드
         A~NCUST  "고객명
         A~SUJUD  "수주일
         A~SALER  "영업담당자
         B~NFKEY  "비철구분
         B~EMENG  "수주량
         B~MEINS  "단위
    INTO CORRESPONDING FIELDS OF TABLE GT_CONNO
    FROM ZNFT1000 AS A
   INNER JOIN ZNFT1001 AS B
      ON A~CONNO = B~CONNO
   WHERE A~CSTAT = 'L'
     AND A~COTYP IN LR_COTYP
     AND B~NFKEY IN LR_NFKEY
     AND A~ERDAT IN LR_CDATE.

  IF SY-SUBRC <> 0.
    MESSAGE S003 DISPLAY LIKE 'E'
       WITH '조건에 해당하는 계약이 존재하지 않습니다.'.
  ENDIF.

  LOOP AT GT_CONNO.
*___고객명
    IF GT_CONNO-KUNNR IS NOT INITIAL.
      PERFORM GET_KUNNR_DESC USING GT_CONNO-KUNNR
                                   GT_CONNO-NCUST.
    ENDIF.

*___가격구분/비철수주가격
    PERFORM PRICE_CLASSIFICATION USING GT_CONNO-CONNO
                                       GT_CONNO-NFKEY
                                       GT_CONNO-PRIND
                                       GT_CONNO-SUJUP
                                       GV_ERROR.

*___수주량
    WRITE : GT_CONNO-EMENG TO GT_CONNO-SUJUQ UNIT GT_CONNO-MEINS.

    MODIFY GT_CONNO.
  ENDLOOP.

ENDFORM.                    " GET_CONTRACT_INFO
*&---------------------------------------------------------------------*
*&      Form  GET_NEXT_SEQ
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM GET_NEXT_SEQ  USING  PV_H_NO1.
  DATA: LS_1011     LIKE GT_1011.

  CLEAR : PV_H_NO1.

  LOOP AT GT_1011 INTO LS_1011.
    IF LS_1011-H_NO1 > PV_H_NO1.
      PV_H_NO1 = LS_1011-H_NO1.
    ENDIF.
  ENDLOOP.

  PV_H_NO1 = PV_H_NO1 + 1.

ENDFORM.                    " GET_NEXT_SEQ
*&---------------------------------------------------------------------*
*&      Form  MOVE_CHANGED_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM MOVE_CHANGED_DATA .

  GS_1011-REQNO = ZNFT1010-REQNO.
  GS_1011-H_NO1 = GT_1011-H_NO1.
  GS_1011-CONNO = GT_1011-CONNO.
  GS_1011-NFKEY = GT_1011-NFKEY.

  IF GV_RQTYP <> '4' AND GV_RQTYP <> '5'.
    GS_1011-BY_SL = 'B'.
  ELSE.
    GS_1011-BY_SL = GT_1011-BY_SL.
  ENDIF.

  GS_1011-ENDMM = GT_1011-ENDMM.
  GS_1011-EMENG = GT_1011-EMENG.
  GS_1011-MEINS = GT_1011-MEINS.
  GS_1011-BIGO4 = GT_1011-BIGO4.
  GS_1011-COTXT = GT_1011-COTXT.
  GS_1011-NFCTR = GT_1011-NFCTR.
  GS_1011-PRCTR = GT_1011-PRCTR.
  GS_1011-VKGRP = GT_1011-VKGRP.
  GS_1011-KUNNR = GT_1011-KUNNR.
  GS_1011-NCUST = GT_1011-NCUST.
  GS_1011-SALER = GT_1011-SALER.
  GS_1011-PRIND = GT_1011-PRIND.
  GS_1011-SUJUP = GT_1011-SUJUP.
  GS_1011-CHECK = GT_1011-CHECK.

ENDFORM.                    " MOVE_CHANGED_DATA
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
    LOOP AT GT_1011 WHERE CHECK = 'X'.
      IF GT_1011-UPDKZ <> 'I'.
        CLEAR : GT_1011D.

        MOVE-CORRESPONDING GT_1011 TO GT_1011D.

        APPEND GT_1011D.
      ENDIF.

      DELETE GT_1011.
    ENDLOOP.

    IF GV_TRTYP = 'H'.   "생성
      LOOP AT GT_1011.
        GT_1011-H_NO1 = SY-TABIX.

        MODIFY GT_1011.
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

  LOOP AT GT_1011 WHERE CHECK = 'X'.
    LV_CNT = LV_CNT + 1.
  ENDLOOP.

  IF LV_CNT < 1.
    PV_ERROR = 'X'.

    MESSAGE S003 DISPLAY LIKE 'E'
       WITH '선택된 행이 없습니다.'.
  ENDIF.

ENDFORM.                    " CHECK_SELECTED_ROW
*&---------------------------------------------------------------------*
*&      Form  APPEND_ROW
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM APPEND_ROW .

  DESCRIBE TABLE GT_1011 LINES TC1-TOP_LINE.
  IF TC1-TOP_LINE IS INITIAL.
    TC1-TOP_LINE = 1.
  ENDIF.
*  TC1-TOP_LINE = TC1-LINES.

  GV_CURSOR = 'GT_1011-NFKEY'.

  IF TC1-LINES IS INITIAL.
    GV_CURLIN = 1.
  ELSE.
    GV_CURLIN = 2.
  ENDIF.

ENDFORM.                    " APPEND_ROW
*&---------------------------------------------------------------------*
*&      Form  APPLY_ALL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM APPLY_ALL .
  DATA: LS_COL      LIKE LINE OF TC1-COLS .

  DATA: LV_LINE     TYPE I.

  CLEAR : LV_LINE, GV_ERROR.

  DESCRIBE TABLE GT_1011 LINES LV_LINE.
  IF LV_LINE < 2.
    MESSAGE S003 DISPLAY LIKE 'E'
       WITH '라인이 두줄 이상인 경우'
            '사용 가능합니다.'.
    EXIT.
  ENDIF.

  LOOP AT TC1-COLS INTO LS_COL WHERE SELECTED = 'X'.
    IF LS_COL-SCREEN-NAME <> 'GT_1011-NFKEY' AND
       LS_COL-SCREEN-NAME <> 'GT_1011-BY_SL' AND
       LS_COL-SCREEN-NAME <> 'GT_1011-CONNO' AND
       LS_COL-SCREEN-NAME <> 'GT_1011-BIGO4'.
      GV_ERROR = 'X'.
      EXIT.
    ENDIF.
  ENDLOOP.

  IF SY-SUBRC <> 0.
    MESSAGE S003 DISPLAY LIKE 'E'
       WITH '선택된 열이 없습니다.'.
    EXIT.
  ENDIF.

  IF GV_ERROR IS NOT INITIAL.
    MESSAGE S003 DISPLAY LIKE 'E'
       WITH '일괄적용 대상이 아닌 열이 선택되었습니다.'.
    EXIT.
  ENDIF.

  PERFORM POPUP_TO_CONFIRM
    USING '확인'
          '선택된 열의 첫라인 값을 모든 라인에 적용하시겠습니까?'
          '2'
          GV_ANSWER.

  IF GV_ANSWER = '1'.
    READ TABLE GT_1011 INDEX 1.
    IF SY-SUBRC = 0.
      LOOP AT TC1-COLS INTO LS_COL.
        IF LS_COL-SELECTED = 'X'.
          MODIFY GT_1011 TRANSPORTING (LS_COL-SCREEN-NAME+8)
                         WHERE H_NO1 IS NOT INITIAL.
        ENDIF.
      ENDLOOP.

      LOOP AT GT_1011.
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

        MODIFY GT_1011.
      ENDLOOP.

      MESSAGE S003 WITH '일괄적용하였습니다.'.
    ENDIF.
  ELSE.
    MESSAGE S003 WITH '작업이 취소되었습니다.'.
  ENDIF.

ENDFORM.                    " APPLY_ALL
*&---------------------------------------------------------------------*
*&      Form  DELETE_FUTURES_REQ
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM DELETE_FUTURES_REQ .

  PERFORM POPUP_TO_CONFIRM
    USING '삭제'
          '선물요청 전체 정보가 삭제됩니다. 계속하시겠습니까?'
          '2'
          GV_ANSWER.

  IF GV_ANSWER = '1'.
    DELETE FROM ZNFT1010 WHERE REQNO = ZNFT1010-REQNO.
    IF SY-SUBRC = 0.
      DELETE FROM ZNFT1011 WHERE REQNO = ZNFT1010-REQNO.
      IF SY-SUBRC = 0.
        COMMIT WORK.

        PERFORM SAVE_CHANGE_DOC USING 'D'.

        MESSAGE S003 WITH '선물요청이 삭제되었습니다.'.

        IF SY-CALLD = 'X'.
          LEAVE PROGRAM.
        ELSE.
          LEAVE TO SCREEN 0.
        ENDIF.
      ELSE.
        ROLLBACK WORK.

        MESSAGE E003 WITH '선물요청 품목 삭제 에러.'.
      ENDIF.
    ELSE.
      ROLLBACK WORK.

      MESSAGE E003 WITH '선물요청 헤더 삭제 에러.'.
    ENDIF.
  ELSE.
    MESSAGE S003 WITH '작업이 취소되었습니다.'.
  ENDIF.

ENDFORM.                    " DELETE_FUTURES_REQ
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

  LOOP AT GT_1011.
    CLEAR : XGT_1011.

    MOVE-CORRESPONDING GT_1011 TO XGT_1011.

    XGT_1011-KZ = GT_1011-UPDKZ.

    APPEND XGT_1011.
  ENDLOOP.

  LV_OBJECTID = ZNFT1010-REQNO.
  LV_TCODE    = SY-TCODE.

  CALL FUNCTION 'ZNFT1010CHDOC_WRITE_DOCUMENT'
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
      N_ZNFT1010   = ZNFT1010
      O_ZNFT1010   = YZNFT1010
      UPD_ZNFT1010 = LV_CDOC_UPD_OBJECT
      UPD_ZNFT1011 = LV_CDOC_UPD_OBJECT
    TABLES
      XZNFT1011    = XGT_1011
      YZNFT1011    = YGT_1011.

ENDFORM.                    " SAVE_CHANGE_DOC
*&---------------------------------------------------------------------*
*&      Form  SAVE_FUTURES_REQUEST
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM SAVE_FUTURES_REQUEST  USING PV_FLAG.

  PERFORM CHECK_FUTURES_ITEM_DATA USING GV_ERROR.

  CHECK GV_ERROR IS INITIAL.

  IF PV_FLAG IS INITIAL.
    PERFORM POPUP_TO_CONFIRM USING '저장'
                                   '선물요청을 저장하시겠습니까?'
                                   '1'
                                   GV_ANSWER.
  ELSE.
    PERFORM POPUP_TO_CONFIRM
      USING '저장'
            '선물요청을 결재요청 하시겠습니까?'
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

    PERFORM SAVE_FUTURES_REQ_DATA USING PV_FLAG.
  ELSE.
    MESSAGE S001 WITH '작업이 취소되었습니다.'.
  ENDIF.

ENDFORM.                    " SAVE_FUTURES_REQUEST
*&---------------------------------------------------------------------*
*&      Form  CHECK_FUTURES_ITEM_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM CHECK_FUTURES_ITEM_DATA   USING PV_ERROR.
  DATA: BEGIN OF LT_CONNO OCCURS 0,
          CONNO LIKE ZNFT1000-CONNO,
        END   OF LT_CONNO.

  DATA: LV_CNT      TYPE I.

  CLEAR   : LT_CONNO, PV_ERROR.
  REFRESH : LT_CONNO.

  IF GT_1011[] IS INITIAL.
    PV_ERROR = 'X'.

    MESSAGE S003 DISPLAY LIKE 'E'
       WITH '선물요청 품목 정보가 없습니다.'.
    EXIT.
  ENDIF.

  LOOP AT GT_1011.
*___계약번호 점검용
    LT_CONNO-CONNO = GT_1011-CONNO.
    COLLECT LT_CONNO.

    IF GT_1011-NFKEY IS INITIAL.
      PV_ERROR     = 'X'.
      TC1-TOP_LINE = SY-TABIX.
      GV_CURSOR    = 'GT_1011-NFKEY'.
      GV_CURLIN    = 1.

      MESSAGE S003 DISPLAY LIKE 'E'
         WITH '항번' GT_1011-H_NO1
              '의 비철구분이 입력되지 않았습니다.'.
      EXIT.
    ENDIF.

    IF GT_1011-BY_SL IS INITIAL.
      PV_ERROR     = 'X'.
      TC1-TOP_LINE = SY-TABIX.
      GV_CURSOR    = 'GT_1011-BY_SL'.
      GV_CURLIN    = 1.

      MESSAGE S003 DISPLAY LIKE 'E'
         WITH '항번' GT_1011-H_NO1
              '의 Buy/Sell 값이 입력되지 않았습니다.'.
      EXIT.
    ENDIF.

    IF GT_1011-ENDMM IS INITIAL.
      PV_ERROR     = 'X'.
      TC1-TOP_LINE = SY-TABIX.
      GV_CURSOR    = 'GT_1011-ENDMM'.
      GV_CURLIN    = 1.

      MESSAGE S003 DISPLAY LIKE 'E'
         WITH '항번' GT_1011-H_NO1
              '의 만기월이 입력되지 않았습니다.'.
      EXIT.
    ELSE.
      IF GT_1011-ENDMM < SY-DATLO(6).
        PV_ERROR     = 'X'.
        TC1-TOP_LINE = SY-TABIX.
        GV_CURSOR    = 'GT_1011-ENDMM'.
        GV_CURLIN    = 1.

        MESSAGE S003 DISPLAY LIKE 'E'
           WITH '항번' GT_1011-H_NO1
                '의 만기월이 당월 이전입니다.'.
        EXIT.
      ENDIF.
    ENDIF.

    IF GT_1011-EMENG IS INITIAL.
      PV_ERROR     = 'X'.
      TC1-TOP_LINE = SY-TABIX.
      GV_CURSOR    = 'GT_1011-EMENG'.
      GV_CURLIN    = 1.

      MESSAGE S003 DISPLAY LIKE 'E'
         WITH '항번' GT_1011-H_NO1
              '의 요청수량이 입력되지 않았습니다.'.
      EXIT.
    ENDIF.

    IF GT_1011-CONNO IS INITIAL.
      PV_ERROR     = 'X'.
      TC1-TOP_LINE = SY-TABIX.
      GV_CURSOR    = 'GT_1011-CONNO'.
      GV_CURLIN    = 1.

      MESSAGE S003 DISPLAY LIKE 'E'
         WITH '항번' GT_1011-H_NO1
              '의 계약번호가 입력되지 않았습니다.'.
      EXIT.
    ENDIF.
  ENDLOOP.

  IF PV_ERROR IS INITIAL.
    DESCRIBE TABLE LT_CONNO LINES LV_CNT.
    IF LV_CNT > 1.
      PV_ERROR     = 'X'.
      TC1-TOP_LINE = 1.
      GV_CURSOR    = 'GT_1011-CONNO'.
      GV_CURLIN    = 1.

      MESSAGE S003 DISPLAY LIKE 'E'
         WITH '계약번호가 다른 건들이 입력되었습니다.'.
    ENDIF.
  ENDIF.

ENDFORM.                    " CHECK_FUTURES_ITEM_DATA
*&---------------------------------------------------------------------*
*&      Form  CHECK_APPLOVAL_USER
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM CHECK_APPLOVAL_USER  USING    PV_PERNR.
  DATA: LV_USRID LIKE ZPA0105-USRID, " PA0105 테이블 대체
*        LV_USRID LIKE PA0105-USRID,
        LV_COMM.

*___사번 존재여부
*  SELECT SINGLE ENAME
*    INTO GV_ENAME
*    FROM PA0001
*   WHERE PERNR =  PV_PERNR
*     AND ENDDA >= SY-DATLO
*     AND BEGDA <= SY-DATLO.

*- [MM] PA0001 테이블 대체
  SELECT SINGLE ENAME
    INTO GV_ENAME
    FROM ZZPA0001
   WHERE PERNR =  PV_PERNR
     AND ENDDA >= SY-DATLO
     AND BEGDA <= SY-DATLO.
*- [MM] PA0001 테이블 변경

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
   WHERE BUKRS = ZNFT1010-BUKRS
     AND CONGB = '2'
     AND CONSQ = '1'
     AND PERNR = PV_PERNR
     AND LVORM = ' '.

  IF SY-SUBRC <> 0.
    MESSAGE E003 WITH '결재자 사번이 권한 마스터에'
                      '존재하지 않습니다.'.
*  ELSE.
*    IF ZNFT1090-CONGB <> '2' OR ZNFT1090-CONSQ <> '1'.
*      MESSAGE E003 WITH '선물요청 1단계 결재자 사번이 아닙니다.'.
*    ENDIF.
  ENDIF.

ENDFORM.                    " CHECK_APPLOVAL_USER
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
*&      Form  SAVE_FUTURES_REQ_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM SAVE_FUTURES_REQ_DATA USING PV_FLAG.
  DATA: LV_FLAG.

  CLEAR   : GT_1011N.
  REFRESH : GT_1011N.

  READ TABLE GT_1011 INDEX 1.

*___헤더정보 생성
  IF GV_TRTYP = 'H'.
    PERFORM GET_REQUEST_NO.

    IF PV_FLAG = 'X'.
      ZNFT1010-RSTAT = '2'.   "승인대기
    ELSE.
      ZNFT1010-RSTAT = '1'.   "입력
    ENDIF.

    ZNFT1010-ERDAT = SY-DATLO.
    ZNFT1010-ERZET = SY-TIMLO.
    ZNFT1010-ERNAM = SY-UNAME.

    GT_1011-REQNO = ZNFT1010-REQNO.

    MODIFY GT_1011 TRANSPORTING REQNO
                   WHERE H_NO1 IS NOT INITIAL.
  ELSE.
    IF PV_FLAG = 'X'.
      ZNFT1010-RSTAT = '2'.
    ENDIF.
  ENDIF.

  ZNFT1010-AEDAT = SY-DATLO.
  ZNFT1010-AEZET = SY-TIMLO.
  ZNFT1010-AENAM = SY-UNAME.

  IF GT_1011D[] IS NOT INITIAL.
    DELETE ZNFT1011 FROM TABLE GT_1011D.
  ENDIF.

*___결재이력 삭제
  DELETE FROM ZNFT1091 WHERE NFNUM = ZNFT1010-REQNO.

  MODIFY ZNFT1010 FROM ZNFT1010.
  IF SY-SUBRC = 0.
    MODIFY ZNFT1011 FROM TABLE GT_1011.
    IF SY-SUBRC = 0.
*___변경이력 저장
      PERFORM SAVE_CHANGE_DOC USING ' '.

      IF PV_FLAG = 'X'.
*___선물요청 메일 전송
        PERFORM SEND_EMAIL USING LV_FLAG.

*___승인요청정보
        PERFORM SAVE_APPROVE_REQUEST USING GV_ERROR.

        IF GV_ERROR IS NOT INITIAL.
          EXIT.
        ENDIF.
      ELSE.
        COMMIT WORK.
      ENDIF.

      IF PV_FLAG IS INITIAL.
        MESSAGE S010 WITH '선물요청번호' ZNFT1010-REQNO.

        IF GV_TRTYP = 'H' AND SY-CALLD IS INITIAL.
          SET PARAMETER ID 'ZNFREQ' FIELD ZNFT1010-REQNO.

          LEAVE TO TRANSACTION 'ZNF2M2102' AND SKIP FIRST SCREEN.
        ELSE.
*___다른 프로그램에서 호출된 경우 저장 후 변경으로 인식하기 위해
          GV_TRTYP = 'A'.

*___변경이력 초기화
          CLEAR   : XGT_1011, YGT_1011, YZNFT1010.
          REFRESH : XGT_1011, YGT_1011.

          YZNFT1010 = ZNFT1010.

          LOOP AT GT_1011.
            CLEAR : YGT_1011, GT_1011-UPDKZ.

            MOVE-CORRESPONDING GT_1011 TO YGT_1011.

            APPEND YGT_1011.

            MODIFY GT_1011.
          ENDLOOP.
        ENDIF.
      ELSE.
        IF LV_FLAG = 'X'.
          MESSAGE I003 WITH '결재요청 메일전송을 실패하였습니다.'.
        ENDIF.

        MESSAGE S011 WITH '선물요청번호' ZNFT1010-REQNO.

        IF SY-CALLD = 'X'.
          LEAVE PROGRAM.
        ELSE.
          LEAVE TO SCREEN 0.
        ENDIF.
      ENDIF.
    ELSE.
      ROLLBACK WORK.

      MESSAGE S003 DISPLAY LIKE 'E'
         WITH '선물요청 품목 정보 저장 에러!'.
    ENDIF.
  ELSE.
    ROLLBACK WORK.

    MESSAGE S003 DISPLAY LIKE 'E'
       WITH '선물요청 헤더 정보 저장 에러!'.
  ENDIF.

ENDFORM.                    " SAVE_FUTURES_REQ_DATA
*&---------------------------------------------------------------------*
*&      Form  GET_REQUEST_NO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_REQUEST_NO .

  CLEAR : ZNFT1010-REQNO.

  CALL FUNCTION 'NUMBER_GET_NEXT'
    EXPORTING
      NR_RANGE_NR             = '10'
      OBJECT                  = 'ZNF2_00002'
    IMPORTING
      NUMBER                  = ZNFT1010-REQNO
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

ENDFORM.                    " GET_REQUEST_NO
*&---------------------------------------------------------------------*
*&      Form  SAVE_APPROVE_REQUEST
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM SAVE_APPROVE_REQUEST  USING PV_ERROR.
  DATA: LV_COMM.

  CLEAR   : ZNFT1091, PV_ERROR.

  ZNFT1091-NFNUM = ZNFT1010-REQNO.
  ZNFT1091-CONSQ = '1'.
  ZNFT1091-CONGB = '2'.
  ZNFT1091-BUKRS = ZNFT1010-BUKRS.
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

*--- 간편결재 전송.
    PERFORM SEND_SIMPLE_APPROVAL
    USING ZNFT1091-NFNUM
          ZNFT1091-BUKRS
          '2A'.
  ELSE.
    ROLLBACK WORK.

    PV_ERROR = 'X'.

    MESSAGE S003 WITH '선물 승인요청 저장 에러!'.
  ENDIF.

ENDFORM.                    " SAVE_APPROVE_REQUEST
*&---------------------------------------------------------------------*
*&      Form  F4HELP_CONNO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM F4HELP_CONNO  USING    PV_RQTYP.

  CLEAR   : SELECTFIELD, SELECT_VALUE, LD_TABIX, GV_INDEX,
            IT_FIELDS, SCR_FIELDS, FELD_TABLE.
  REFRESH : IT_FIELDS, SCR_FIELDS, FELD_TABLE.

  GET CURSOR LINE GV_INDEX.

*___해당 라인의 비철구분을 읽는다.
  SCR_FIELDS-FIELDNAME = 'GT_1011-NFKEY'.
  SCR_FIELDS-STEPL     = GV_INDEX.
  APPEND SCR_FIELDS.

  CALL FUNCTION 'DYNP_VALUES_READ'
    EXPORTING
      DYNAME     = SY-CPROG
      DYNUMB     = SY-DYNNR
    TABLES
      DYNPFIELDS = SCR_FIELDS.

  READ TABLE SCR_FIELDS WITH KEY FIELDNAME = 'GT_1011-NFKEY'.
  GT_1011-NFKEY = SCR_FIELDS-FIELDVALUE.

  PERFORM GET_CONTRACT_INFO USING PV_RQTYP.

  CHECK GT_CONNO[] IS NOT INITIAL.

*___아래 부분이 F4를 눌렀을 때, Hit List를 보여준다.
  IT_FIELDS-TABNAME    = 'ZNFT1000'.
  IT_FIELDS-FIELDNAME  = 'COTYP'.
  IT_FIELDS-SELECTFLAG = ' '.
  APPEND IT_FIELDS.

  IT_FIELDS-TABNAME    = 'ZNFT1000'.
  IT_FIELDS-FIELDNAME  = 'NFCTR'.
  IT_FIELDS-SELECTFLAG = ' '.
  APPEND IT_FIELDS.

  IT_FIELDS-TABNAME    = 'ZNFT1000'.
  IT_FIELDS-FIELDNAME  = 'PRCTR'.
  IT_FIELDS-SELECTFLAG = ' '.
  APPEND IT_FIELDS.

  IT_FIELDS-TABNAME    = 'ZNFT1000'.
  IT_FIELDS-FIELDNAME  = 'VKGRP'.
  IT_FIELDS-SELECTFLAG = ' '.
  APPEND IT_FIELDS.

  IT_FIELDS-TABNAME    = 'ZNFT1000'.
  IT_FIELDS-FIELDNAME  = 'CONNO'.
  IT_FIELDS-SELECTFLAG = 'X'.
  APPEND IT_FIELDS.

  IT_FIELDS-TABNAME    = 'ZNFT1000'.
  IT_FIELDS-FIELDNAME  = 'ERDAT'.
  IT_FIELDS-SELECTFLAG = ' '.
  APPEND IT_FIELDS.

  IT_FIELDS-TABNAME    = 'ZNFT1000'.
  IT_FIELDS-FIELDNAME  = 'COTXT'.
  IT_FIELDS-SELECTFLAG = ' '.
  APPEND IT_FIELDS.

  IT_FIELDS-TABNAME    = 'ZNFT1000'.
  IT_FIELDS-FIELDNAME  = 'KUNNR'.
  IT_FIELDS-SELECTFLAG = ' '.
  APPEND IT_FIELDS.

  IT_FIELDS-TABNAME    = 'ZNFT1000'.
  IT_FIELDS-FIELDNAME  = 'NCUST'.
  IT_FIELDS-SELECTFLAG = ' '.
  APPEND IT_FIELDS.

  IT_FIELDS-TABNAME    = 'ZNFT1000'.
  IT_FIELDS-FIELDNAME  = 'SUJUD'.
  IT_FIELDS-SELECTFLAG = ' '.
  APPEND IT_FIELDS.

  IT_FIELDS-TABNAME    = 'ZNFT1000'.
  IT_FIELDS-FIELDNAME  = 'SALER'.
  IT_FIELDS-SELECTFLAG = ' '.
  APPEND IT_FIELDS.

  IT_FIELDS-TABNAME    = 'ZNFT1001'.
  IT_FIELDS-FIELDNAME  = 'NFKEY'.
  IT_FIELDS-SELECTFLAG = ' '.
  APPEND IT_FIELDS.

  IT_FIELDS-TABNAME    = 'ZNFS1001'.
  IT_FIELDS-FIELDNAME  = 'PRIND'.
  IT_FIELDS-SELECTFLAG = ' '.
  APPEND IT_FIELDS.

  IT_FIELDS-TABNAME    = 'ZNFS1001'.
  IT_FIELDS-FIELDNAME  = 'SUJUP'.
  IT_FIELDS-SELECTFLAG = ' '.
  APPEND IT_FIELDS.

  IT_FIELDS-TABNAME    = 'ZNFS1001'.
  IT_FIELDS-FIELDNAME  = 'SUJUQ'.
  IT_FIELDS-SELECTFLAG = ' '.
  APPEND IT_FIELDS.

  CALL FUNCTION 'HELP_VALUES_GET_NO_DD_NAME'
    EXPORTING
      SELECTFIELD                  = SELECTFIELD
    IMPORTING
      IND                          = LD_TABIX
      SELECT_VALUE                 = SELECT_VALUE
    TABLES
      FIELDS                       = IT_FIELDS
      FULL_TABLE                   = GT_CONNO
    EXCEPTIONS
      FULL_TABLE_EMPTY             = 1
      NO_TABLESTRUCTURE_GIVEN      = 2
      NO_TABLEFIELDS_IN_DICTIONARY = 3
      MORE_THEN_ONE_SELECTFIELD    = 4
      NO_SELECTFIELD               = 5
      OTHERS                       = 6.

  CHECK NOT LD_TABIX IS INITIAL.
  READ TABLE GT_CONNO INDEX LD_TABIX.
  IF SY-SUBRC = 0.
*___아래 부분이 선택된 값들을 화면 필드에 뿌려준다.
    IF GT_1011-NFKEY IS INITIAL.
      SCR_FIELDS-FIELDNAME  = 'GT_1011-NFKEY'.
      SCR_FIELDS-STEPL      = GV_INDEX.
      SCR_FIELDS-FIELDVALUE = GT_CONNO-NFKEY.
      APPEND SCR_FIELDS.
    ENDIF.

    SCR_FIELDS-FIELDNAME  = 'GT_1011-CONNO'.
    SCR_FIELDS-STEPL      = GV_INDEX.
    SCR_FIELDS-FIELDVALUE = GT_CONNO-CONNO.
    APPEND SCR_FIELDS.

    SCR_FIELDS-FIELDNAME  = 'GT_1011-COTXT'.
    SCR_FIELDS-STEPL      = GV_INDEX.
    SCR_FIELDS-FIELDVALUE = GT_CONNO-COTXT.
    APPEND SCR_FIELDS.

    SCR_FIELDS-FIELDNAME  = 'GT_1011-NFCTR'.
    SCR_FIELDS-STEPL      = GV_INDEX.
    SCR_FIELDS-FIELDVALUE = GT_CONNO-NFCTR.
    APPEND SCR_FIELDS.

    SCR_FIELDS-FIELDNAME  = 'GT_1011-PRCTR'.
    SCR_FIELDS-STEPL      = GV_INDEX.
    SCR_FIELDS-FIELDVALUE = GT_CONNO-PRCTR.
    APPEND SCR_FIELDS.

    SCR_FIELDS-FIELDNAME  = 'GT_1011-VKGRP'.
    SCR_FIELDS-STEPL      = GV_INDEX.
    SCR_FIELDS-FIELDVALUE = GT_CONNO-VKGRP.
    APPEND SCR_FIELDS.

    SCR_FIELDS-FIELDNAME  = 'GT_1011-KUNNR'.
    SCR_FIELDS-STEPL      = GV_INDEX.
    SCR_FIELDS-FIELDVALUE = GT_CONNO-KUNNR.
    APPEND SCR_FIELDS.

    SCR_FIELDS-FIELDNAME  = 'GT_1011-NCUST'.
    SCR_FIELDS-STEPL      = GV_INDEX.
    SCR_FIELDS-FIELDVALUE = GT_CONNO-NCUST.
    APPEND SCR_FIELDS.

    SCR_FIELDS-FIELDNAME  = 'GT_1011-SALER'.
    SCR_FIELDS-STEPL      = GV_INDEX.
    SCR_FIELDS-FIELDVALUE = GT_CONNO-SALER.
    APPEND SCR_FIELDS.

    SCR_FIELDS-FIELDNAME  = 'GT_1011-PRIND'.
    SCR_FIELDS-STEPL      = GV_INDEX.
    SCR_FIELDS-FIELDVALUE = GT_CONNO-PRIND.
    APPEND SCR_FIELDS.

    SCR_FIELDS-FIELDNAME  = 'GT_1011-SUJUP'.
    SCR_FIELDS-STEPL      = GV_INDEX.
    SCR_FIELDS-FIELDVALUE = GT_CONNO-SUJUP.
    APPEND SCR_FIELDS.

*    SCR_FIELDS-FIELDNAME  = 'GT_1011-BIGO4'.
*    SCR_FIELDS-STEPL      = GV_INDEX.
*    SCR_FIELDS-FIELDVALUE = GT_CONNO-BIGO4.
*    APPEND SCR_FIELDS.

    CALL FUNCTION 'DYNP_VALUES_UPDATE'
      EXPORTING
        DYNAME               = SY-CPROG
        DYNUMB               = SY-DYNNR
      TABLES
        DYNPFIELDS           = SCR_FIELDS
      EXCEPTIONS
        INVALID_ABAPWORKAREA = 1
        INVALID_DYNPROFIELD  = 2
        INVALID_DYNPRONAME   = 3
        INVALID_DYNPRONUMMER = 4
        INVALID_REQUEST      = 5
        NO_FIELDDESCRIPTION  = 6
        UNDEFIND_ERROR       = 7
        OTHERS               = 8.

    IF SY-SUBRC <> 0.
      MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
              WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.
  ENDIF.

ENDFORM.                    " F4HELP_CONNO
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
    GT_1011-CHECK = 'X'.
  ELSE.
    CLEAR : GT_1011-CHECK.
  ENDIF.

  MODIFY GT_1011 TRANSPORTING CHECK
                 WHERE H_NO1 IS NOT INITIAL.

ENDFORM.                    " SELECT_ALL
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

*- [MM] PA0105 테이블 대체
    SELECT SINGLE USRID
      INTO GV_ADDRESS
      FROM ZPA0105
     WHERE PERNR = GV_PERNR
       AND SUBTY = '0007'
       AND ENDDA >= SY-DATLO
       AND BEGDA <= SY-DATLO.
*- [MM] PA0105 테이블 대체
  ENDIF.

  CHECK GV_ADDRESS IS NOT INITIAL.

*___메일 제목
  GV_SUBJECT = '선물요청에 대한 승인요청'.

  CLEAR   : LS_MESSAGE.
  REFRESH : GT_MESSAGE.

*___메일 내용
  PERFORM APPEND_MESSAGE USING : '<html>',
                                 '<body>',
                                 '선물요청<br>',
                                 '<br>'.

  READ TABLE GT_1011 INDEX 1.

  CONCATENATE ZNFT1010-REQNO '(계약명:' GT_1011-COTXT ')<br>'
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
*&      --> ZNFT1091_NFNUM
*&      --> ZNFT1091_BUKRS
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
