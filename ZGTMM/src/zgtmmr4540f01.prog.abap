*&---------------------------------------------------------------------*
*&  Include           MZLE0001F01                                      *
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  get_f4_iv_type
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_F4_IV_TYPE USING P_TYPE.

  DATA: BEGIN OF POV_TYPE OCCURS 0,
         IV_TYPE      LIKE ZLET0007-IV_TYPE,
         IV_TYPE_NM   LIKE ZLET0007-IV_TYPE_NM,
        END OF POV_TYPE.

  CLEAR: POV_TYPE[], POV_TYPE.
  IF SY-REPID = 'ZGTMMR4520'. "''ZLER0017'.
    SELECT * INTO CORRESPONDING FIELDS OF TABLE POV_TYPE
      FROM ZGTMMT4511
     WHERE GUBUN = 'MA'.
  ELSE.
    SELECT * INTO CORRESPONDING FIELDS OF TABLE POV_TYPE
      FROM ZGTMMT4511
     WHERE GUBUN = 'MA'
       AND IV_TYPE LIKE 'E__'.
  ENDIF.

  FIELDTAB-TABNAME   = 'ZGTMMT4511'.
  FIELDTAB-FIELDNAME = 'IV_TYPE'.
  FIELDTAB-SELECTFLAG = 'X'.
  APPEND FIELDTAB.

  FIELDTAB-TABNAME   = 'ZGTMMT4511'.
  FIELDTAB-FIELDNAME = 'IV_TYPE_NM'.
  FIELDTAB-SELECTFLAG = ' '.
  APPEND FIELDTAB.

  LOOP AT POV_TYPE.
    VALUETAB-VALUE = POV_TYPE-IV_TYPE.
    APPEND VALUETAB.
    VALUETAB-VALUE = POV_TYPE-IV_TYPE_NM.
    APPEND VALUETAB.
  ENDLOOP.

  CALL FUNCTION 'HELP_VALUES_GET_WITH_TABLE_EXT'
       EXPORTING
            DISPLAY       = ' '
*            fieldname     = 'NAME1'
       IMPORTING
            INDEX         = J
     TABLES
            FIELDS        = FIELDTAB
            SELECT_VALUES = I_HELP_VTAB
            VALUETAB      = VALUETAB.

  IF J > 0.
    READ TABLE POV_TYPE INDEX J.
    P_TYPE = POV_TYPE-IV_TYPE.
  ENDIF.
  REFRESH : FIELDTAB, VALUETAB, POV_TYPE.
  CLEAR   : J,FIELDTAB, VALUETAB, POV_TYPE.

ENDFORM.                    " get_f4_iv_type
*&---------------------------------------------------------------------*
*&      Form  get_f4_PERNR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_F4_PERNR USING  PV_FLAG   "' '사원번호, '1'합의, '2'승인
                         PV_BUKRS
                         PV_WERKS
                         PV_TYPE
                         PV_PERNR.
  DATA: LT_T527X    LIKE T527X OCCURS 0 WITH HEADER LINE,
        LV_BZAREA   LIKE ZLET0034-BZAREA.

  DATA: BEGIN OF POV_PER OCCURS 0,
         PERNR      LIKE ZZPA0001-PERNR,
         ENAME      LIKE ZZPA0001-ENAME,
         ORGEH      LIKE T527X-ORGEH,
         ORGTX      LIKE T527X-ORGTX,
        END OF POV_PER.

  CLEAR   : FIELDTAB, VALUETAB, POV_PER, J.
  REFRESH : FIELDTAB, VALUETAB, POV_PER.

*{ 기능개선 239718 - 변경
  SELECT PERNR
         ENAME
         ORGEH
    INTO CORRESPONDING FIELDS OF TABLE POV_PER
    FROM ZZPA0001
   WHERE BEGDA <= SY-DATUM
     AND ENDDA >= SY-DATUM
     AND BUKRS =  PV_BUKRS
     AND PERSG =  '1'.          "재직자
  SORT POV_PER BY PERNR.

  IF PV_FLAG IS NOT INITIAL.
    IF PV_FLAG = '1'.
*___합의자
      SELECT SINGLE BZAREA
        INTO LV_BZAREA
        FROM ZLET0034
       WHERE WERKS = PV_WERKS.

      LOOP AT POV_PER.
        SELECT SINGLE PERNR
          INTO POV_PER-PERNR
          FROM ZLET0083
         WHERE BUKRS  = PV_BUKRS
           AND BZAREA = LV_BZAREA
           AND PERNR  = POV_PER-PERNR
           AND LVORM  = ' '.

        IF SY-SUBRC <> 0 .
          DELETE POV_PER.
        ENDIF.
      ENDLOOP.

    ELSE.
*___승인자
      LOOP AT POV_PER.
        SELECT SINGLE MANDT
          INTO SY-MANDT
          FROM USR02
         WHERE BNAME = POV_PER-PERNR
           AND CLASS = 'PUSER'.

        IF SY-SUBRC <> 0 .
          DELETE POV_PER.
        ENDIF.
      ENDLOOP.

*{U1 기타통문 결재등록자도 승인자로 추가
      DATA: LT_PER LIKE POV_PER OCCURS 0 WITH HEADER LINE.
      SELECT A~PERNR
             A~ENAME
             A~ORGEH
        INTO CORRESPONDING FIELDS OF TABLE LT_PER
        FROM ZZPA0001 AS A
             INNER JOIN ZLET0014 AS B
          ON A~PERNR = B~UNAME
       WHERE BEGDA <= SY-DATUM
         AND ENDDA >= SY-DATUM
         AND BUKRS =  PV_BUKRS
         AND PERSG =  '1'.
      IF SY-SUBRC EQ 0.
        APPEND LINES OF LT_PER[] TO POV_PER[].
      ENDIF.
*}U1
    ENDIF.
  ENDIF.

  CHECK POV_PER[] IS NOT INITIAL.

  CLEAR   : LT_T527X.
  REFRESH : LT_T527X.

  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE LT_T527X
    FROM T527X
     FOR ALL ENTRIES IN POV_PER
   WHERE SPRSL =  SY-LANGU
     AND ORGEH =  POV_PER-ORGEH
     AND BEGDA <= SY-DATUM
     AND ENDDA >= SY-DATUM.

  LOOP AT POV_PER.
    READ TABLE LT_T527X WITH KEY ORGEH = POV_PER-ORGEH.
    IF SY-SUBRC = 0.
      POV_PER-ORGTX = LT_T527X-ORGTX.

      MODIFY POV_PER.
    ENDIF.
  ENDLOOP.

**-{기능개선73039-수정
*  SELECT A~PERNR
*         A~ENAME
*         A~ORGEH
*    INTO CORRESPONDING FIELDS OF TABLE POV_PER
*    FROM ZZPA0001 AS A
*   INNER JOIN USR02 AS B
*      ON A~PERNR =  B~BNAME
*   WHERE A~BEGDA <= SY-DATUM
*     AND A~ENDDA >= SY-DATUM
*     AND A~BUKRS =  PV_BUKRS
*     AND B~CLASS =  'PUSER'.
**-}기능개선73039_2015.04.02
*
*  IF NOT POV_PER[] IS INITIAL.
*    CLEAR: LT_T527X[].
*
*    SELECT *
*      INTO CORRESPONDING FIELDS OF TABLE LT_T527X
*      FROM T527X
*       FOR ALL ENTRIES IN POV_PER
*     WHERE SPRSL =  SY-LANGU
*       AND ORGEH =  POV_PER-ORGEH
*       AND BEGDA <= SY-DATUM
*       AND ENDDA >= SY-DATUM.
*
*    LOOP AT POV_PER.
*      READ TABLE LT_T527X WITH KEY ORGEH = POV_PER-ORGEH.
*      IF SY-SUBRC = 0.
*        POV_PER-ORGTX = LT_T527X-ORGTX.
*
*        MODIFY POV_PER.
*      ENDIF.
*    ENDLOOP.
*  ENDIF.
*
*  CLEAR : LV_BZAREA.
*
******** 기능개선 238656
** 전선/e99유형일경우 플랜트가 입력되어 있으면
** zlet0083에서 등록된 합의자만 보여줌
*  IF WA-BUKRS = '1000' AND WA-IV_TYPE = 'E99' AND
*    WA-WERKS IS NOT INITIAL.
*    IF ( WA-WERKS >= 1600 AND WA-WERKS <= 1609 ) OR
*       ( WA-WERKS >= 1781 AND WA-WERKS <= 1789 ) OR
*       ( WA-WERKS >= 3600 AND WA-WERKS <= 3609 ) OR
*       ( WA-WERKS >= 3781 AND WA-WERKS <= 3789 ) .
*      IF LV_BZAREA = ' '.
*        LV_BZAREA = '5000'.
*      ENDIF.
*    ELSE.
*      SELECT SINGLE BZAREA
*      INTO   (LV_BZAREA)
*      FROM   ZLET0034
*      WHERE  WERKS = WA-WERKS.
*    ENDIF.
*
*    IF LV_BZAREA IS NOT INITIAL.
*      LOOP AT POV_PER.
*
*        SELECT SINGLE MANDT
*          INTO SY-MANDT
*          FROM ZLET0083
*          WHERE BZAREA = LV_BZAREA
*          AND     PERNR = POV_PER-PERNR.
*        IF SY-SUBRC <> 0 .
*          DELETE POV_PER.
*        ENDIF.
*
*      ENDLOOP.
*    ENDIF.
*  ENDIF.
*
*  IF POV_PER[] IS INITIAL.
*    SELECT A~PERNR
*           A~ENAME
*           A~ORGEH
*      INTO CORRESPONDING FIELDS OF TABLE POV_PER
*      FROM ZZPA0001 AS A
*     INNER JOIN USR02 AS B
*        ON A~PERNR =  B~BNAME
*     WHERE A~BEGDA <= SY-DATUM
*       AND A~ENDDA >= SY-DATUM
*       AND A~BUKRS =  PV_BUKRS
*       AND B~CLASS =  'PUSER'.
*
**-}기능개선73039_2015.04.02
*    IF NOT POV_PER[] IS INITIAL.
*      LOOP AT POV_PER.
*        READ TABLE LT_T527X WITH KEY ORGEH = POV_PER-ORGEH.
*        IF SY-SUBRC = 0.
*          POV_PER-ORGTX = LT_T527X-ORGTX.
*
*          MODIFY POV_PER.
*        ENDIF.
*      ENDLOOP.
*    ENDIF.
*  ENDIF.
******* 기능개선 238656
*} 기능개선 239718 - 변경

  FIELDTAB-TABNAME    = 'ZZPA0001'.
  FIELDTAB-FIELDNAME  = 'PERNR'.
  FIELDTAB-SELECTFLAG = 'X'.
  APPEND FIELDTAB.

  FIELDTAB-TABNAME    = 'ZZPA0001'.
  FIELDTAB-FIELDNAME  = 'ENAME'.
  FIELDTAB-SELECTFLAG = ' '.
  APPEND FIELDTAB.

  FIELDTAB-TABNAME    = 'T527X'.
  FIELDTAB-FIELDNAME  = 'ORGTX'.
  FIELDTAB-SELECTFLAG = ' '.
  APPEND FIELDTAB.

  LOOP AT POV_PER.
    VALUETAB-VALUE = POV_PER-PERNR.
    APPEND VALUETAB.
    VALUETAB-VALUE = POV_PER-ENAME.
    APPEND VALUETAB.
    VALUETAB-VALUE = POV_PER-ORGTX.
    APPEND VALUETAB.
  ENDLOOP.

  CALL FUNCTION 'HELP_VALUES_GET_WITH_TABLE_EXT'
       EXPORTING
            DISPLAY       = ' '
*            fieldname     = 'NAME1'
       IMPORTING
            INDEX         = J
       TABLES
            FIELDS        = FIELDTAB
            SELECT_VALUES = I_HELP_VTAB
            VALUETAB      = VALUETAB.

  IF J > 0.
    READ TABLE POV_PER INDEX J.
    IF SY-SUBRC = 0.
      PV_PERNR = POV_PER-PERNR.
    ENDIF.
  ENDIF.

ENDFORM.                    " get_f4_PERNR
*&---------------------------------------------------------------------*
*&      Form  SAVE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SAVE .

  PERFORM DATA_CHECK_BEFORE_SAVE.


*  PERFORM change_data.
  PERFORM SAVE_DATA.

ENDFORM.                    " SAVE
*&---------------------------------------------------------------------*
*&      Form  DATA_CHECK_BEFORE_SAVE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM DATA_CHECK_BEFORE_SAVE .

  DATA: LV_FLAG.
  CLEAR: LV_FLAG.

  IF TS_FLAG1 = ' '.
    IF NOT WA-IV_NO IS INITIAL.
      MESSAGE I000 WITH '재설정하세요!!'.
      LEAVE SCREEN .
    ENDIF.
  ENDIF.

  IF WA-WERKS IS INITIAL.
    MESSAGE S000 DISPLAY LIKE 'E' WITH '플랜트를 입력하십시오'.
    G_CURSOR_FIELD = 'WA-WERKS'.
    LEAVE SCREEN.
  ENDIF.

  IF WA-BZAREA IS INITIAL.
    MESSAGE S000 DISPLAY LIKE 'E' WITH '사업장을 입력하십시오'.
    G_CURSOR_FIELD = 'WA-BZAREA'.
    LEAVE SCREEN.
  ENDIF.
*-{기능개선 69869 - 추가(전선 E10유형의 경우 입고플랜트 필수 조건 제외)
  IF WA-IV_TYPE = 'E04' OR WA-IV_TYPE = 'E10'.
    IF GV_BUKRS = '3000'.
      IF WA-UMWRK IS INITIAL.
        MESSAGE S000 DISPLAY LIKE 'E' WITH '입고Plant를 입력하십시오'.
        G_CURSOR_FIELD = 'WA-UMWRK'.
        LEAVE SCREEN.
      ENDIF.
    ELSEIF GV_BUKRS = '1000'.
      IF WA-IV_TYPE = 'E04'.
        IF WA-UMWRK IS INITIAL.
          MESSAGE S000 DISPLAY LIKE 'E' WITH '입고Plant를 입력하십시오'.
          G_CURSOR_FIELD = 'WA-UMWRK'.
          LEAVE SCREEN.
        ENDIF.
      ENDIF.
    ENDIF.
  ELSEIF WA-IV_TYPE <> 'E12'.
*    IF wa-kunnr IS INITIAL AND wa-kunnr1 IS INITIAL.
*      MESSAGE s000 DISPLAY LIKE 'E'
*                   WITH '구매처 또는 납품처를 입력하십시오'.
*      LEAVE SCREEN.
*    ENDIF.
    IF WA-CHANGE IS INITIAL.
      IF WA-KUNNR IS INITIAL AND WA-KUNNR1 IS INITIAL.
        MESSAGE S000 DISPLAY LIKE 'E'
                     WITH '구매처 또는 납품처를 입력하십시오'.
        G_CURSOR_FIELD = 'WA-KUNNR'.
        LEAVE SCREEN.
      ENDIF.
    ELSE.
      IF WA-KUNNR1_T IS INITIAL.
        MESSAGE S000 DISPLAY LIKE 'E'
                     WITH '구매처 또는 납품처를 입력하십시오'.
        G_CURSOR_FIELD = 'WA-KUNNR1_T'.
        LEAVE SCREEN.
      ENDIF.
    ENDIF.
  ENDIF.
*-}기능개선 69869_2015.03.09

  IF GV_ADDRS = 'X' AND WA-ADDRS IS INITIAL.
    MESSAGE S000 DISPLAY LIKE 'E' WITH '주소를 입력하십시오'.
    G_CURSOR_FIELD = 'WA-ADDRS'.
    LEAVE SCREEN.
  ENDIF.

  IF WA-PERNR IS INITIAL.
    MESSAGE S000 DISPLAY LIKE 'E' WITH '사원번호를 입력하십시오'.
    G_CURSOR_FIELD = 'WA-PERNR'.
    LEAVE SCREEN.
  ENDIF.

  IF GV_BUKRS = '1000' AND WA-ETC_NM IS INITIAL.
    MESSAGE S000 DISPLAY LIKE 'E' WITH '사유를 입력하십시오'.
    G_CURSOR_FIELD = 'WA-ETC_NM'.
    LEAVE SCREEN.
  ENDIF.

*{ 기능개선 228147 - 추가
  IF ( GS_IO-GIJUN = 'X' AND GS_IO-GRJUN = 'X' ) OR
     ( GS_IO-GIENG = 'X' AND GS_IO-GRENG = 'X' ) OR
     ( GS_IO-GIDAE = 'X' AND GS_IO-GRDAE = 'X' ).
    MESSAGE S004 DISPLAY LIKE 'E'
       WITH '출고장과 입고장이 동일합니다.'
            '점검하십시오.'.
    LEAVE SCREEN.
  ENDIF.
*} 기능개선 228147 - 추가

*-[SRM2112-01975_S
  IF GS_IO-GREXT = 'X' AND GV_GREXT = ' '.
    MESSAGE S004 DISPLAY LIKE 'E'
    WITH '입고 창고가 기타입니다.'
             '입고 창고를 수기 입력하세요.'.
    LEAVE SCREEN.
  ENDIF.
*]-SRM2112-01975_E

  DELETE GT_LIST WHERE MAKTX = ' '.

  LOOP AT GT_LIST.
    IF GT_LIST-MAKTX IS INITIAL.
      MESSAGE S000 DISPLAY LIKE 'E' WITH '품명/규격을 입력하십시오'.
      G_CURSOR_FIELD = 'GT_LIST-MAKTX'.
      LV_FLAG = 'X'.
      EXIT.
    ENDIF.
    IF GT_LIST-LFIMG IS INITIAL.
      MESSAGE S000 DISPLAY LIKE 'E' WITH '수량을 입력하십시오'.
      G_CURSOR_FIELD = 'GT_LIST-LFIMG'.
      LV_FLAG = 'X'.
      EXIT.
    ENDIF.
    IF GT_LIST-MTR_UNIT IS INITIAL.
      MESSAGE S000 DISPLAY LIKE 'E' WITH '단위을 입력하십시오'.
      G_CURSOR_FIELD = 'GT_LIST-MTR_UNIT'.
      LV_FLAG = 'X'.
      EXIT.
    ENDIF.

    IF WA-RETURN_YN = 'X'.
      IF GT_LIST-RETURN_DUE_DATE IS INITIAL.
        MESSAGE S000 DISPLAY LIKE 'E' WITH '반입예정일을 입력하십시오'.
        G_CURSOR_FIELD = 'GT_LIST-RETURN_DUE_DATE'.
        LV_FLAG = 'X'.
        EXIT.
      ENDIF.
      IF TS_FLAG1 = ' ' AND GT_LIST-RETURN_DUE_DATE < SY-DATUM.
        MESSAGE S000 DISPLAY LIKE 'E'
                     WITH '반입예정일이 지났음: 점검하십시오'.
        G_CURSOR_FIELD = 'GT_LIST-RETURN_DUE_DATE'.
        LV_FLAG = 'X'.
        EXIT.
      ENDIF.
    ENDIF.

*{ 기능개선 228147 - 추가
    IF WA-IV_TYPE = 'E12' AND GT_LIST-CHARG IS INITIAL.
      MESSAGE S000 DISPLAY LIKE 'E'
         WITH '기대번호를 입력하십시오.'.
      G_CURSOR_FIELD = 'GT_LIST-CHARG'.
      LV_FLAG = 'X'.
      EXIT.
    ENDIF.
*} 기능개선 228147 - 추가

*{ 기능개선 251794 - 추가
    IF WA-BUKRS = '3000'.
      IF WA-IV_TYPE = 'E99' AND GT_LIST-REASN IS INITIAL.
        MESSAGE S000 DISPLAY LIKE 'E'
           WITH '사유를 입력하십시오.'.
        G_CURSOR_FIELD = 'GT_LIST-REASN'.
        LV_FLAG = 'X'.
        EXIT.
      ENDIF.
    ENDIF.
*} 기능개선 251794 - 추가

*이길상C 요청 20100910
*[START]
*    IF wa-iv_type = 'E06'.
*      IF gt_list-matnr IS INITIAL.
*        MESSAGE i000 WITH '자재코드를 입력하세요'.
*        lv_flag = 'X'.
*        EXIT.
*      ENDIF.
*    ENDIF.
*[END]
  ENDLOOP.


  READ TABLE GT_LIST INDEX 1.
  IF SY-SUBRC <> 0.
    MESSAGE S000 DISPLAY LIKE 'E' WITH '품명을 입력하십시오'.
    G_CURSOR_FIELD = 'GT_LIST-MAKTX'.
    LV_FLAG = 'X'.
  ENDIF.

  IF LV_FLAG = 'X'.
    I_CURSOR_LINE = SY-TABIX - TC01-TOP_LINE + 1.

    IF I_CURSOR_LINE < 1.
      I_CURSOR_LINE  = 1.
    ENDIF.

    LEAVE SCREEN .
  ENDIF.

  IF GV_CHECK = ''.
    IF GV_APNUM = '2' AND WA_0110-APP_ID1 IS INITIAL.
      MESSAGE S000 DISPLAY LIKE 'E'
         WITH '(결재라인)합의자를 입력하십시오'.
      LEAVE SCREEN.
    ENDIF.
    IF WA_0110-APP_ID2 IS INITIAL.
      MESSAGE S000 DISPLAY LIKE 'E'
         WITH '(결재라인)승인자를 입력하십시오'.
      LEAVE SCREEN.
    ENDIF.
  ENDIF.

ENDFORM.                    " DATA_CHECK_BEFORE_SAVE
*&---------------------------------------------------------------------*
*&      Form  SAVE_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SAVE_DATA .

  DATA: LV_RETURN.

  PERFORM POP_UP_CONFIRM(ZLER0004) USING '< 저장여부확인 >'
                               '저장하시겠습니까?'
                      CHANGING LV_RETURN.
  CHECK LV_RETURN = 'J'.

  IF TS_FLAG1 = ' '.
    PERFORM INVOICE_NO_CREATE(ZLER0015) USING 'ZLE001' '06'
                           CHANGING WA-IV_NO.
  ENDIF.
  IF WA-IV_NO <> ' '.

*{ 기능개선 307461 - S
    IF WA-IV_TYPE  = 'E13'. "자재 예약처리.
      PERFORM MAKE_A_RESERVATION.
    ENDIF.
*} 기능개선 307461 - E

    DELETE FROM ZGTMMT4500 WHERE IV_NO = WA-IV_NO.
    COMMIT WORK.
    DELETE FROM ZGTMMT4501 WHERE IV_NO = WA-IV_NO.
    COMMIT WORK.
    PERFORM INSERT_HEADER .
    PERFORM INSERT_ITEM .
*-{기능개선 48116 - 추가
    IF GV_CHECK = ''.
      DELETE FROM ZLET0003 WHERE IV_NO = WA-IV_NO.
      COMMIT WORK.
      PERFORM INSERT_APPROVAL.
      PERFORM call_simple_approval USING wa-iv_no.
    ENDIF.
*-}기능개선 48116_2014.10.21

    PERFORM UPDATE_ZELT0105. "기타통문관련 배차요청 테이블 매핑
    MESSAGE I005(ZLE1) WITH LV_IV_NO
                           '번 통문이 생성되었습니다.'.
    IF GV_BUKRS = '1000'.
      LEAVE TO SCREEN 0.
    ENDIF.
  ELSE.
    MESSAGE I005(ZLE1) WITH '통문번호 생성 실패!'.
    LEAVE TO SCREEN 0.
  ENDIF.
  CLEAR LV_IV_NO.
ENDFORM.                    " SAVE_DATA
*&---------------------------------------------------------------------*
*&      Form  INSERT_HEADER
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM INSERT_HEADER .

  CLEAR: ZGTMMT4500.

* 070109 Bon-Chan Koo
* 통문유형 기타에 대하여
* 플랜트/사업단위 1600 ~ 1609, 1781~1789인 경우
* 통문 유형 Cxx 는 플랜트 Exx는 사업단위 옆에
* 반출 사업장 5000/5100 선택 필드 활성화(디폴트 5000)
* 내역 저장시 통문 DB에 마스터의 사업장이 아닌 반출사업장 입력
  MOVE-CORRESPONDING WA  TO ZGTMMT4500.

*{S SRM2209-05218 26.09.2022 12:47:15
* 통문에서 입력된 사업장으로 처리되도록 주석 처리
*  SELECT SINGLE BZAREA
*    INTO ZLET0005-BZAREA
*    FROM ZLET0034
*   WHERE WERKS = WA-WERKS.
*}E SRM2209-05218

  IF GV_ADDRS = ''.
    ZGTMMT4500-ADDRS = ''.
  ENDIF.

*{ 기능개선 228147 - 추가
  IF WA-IV_TYPE = 'E12'.
*___출고장
    CASE 'X'.
      WHEN GS_IO-GIJUN.
        ZGTMMT4500-KUNNR  = '전주공장'.
      WHEN GS_IO-GIENG.
        ZGTMMT4500-KUNNR  = '엔진공장'.
      WHEN GS_IO-GIDAE.
        ZGTMMT4500-KUNNR  = '대창엠코'.
    ENDCASE.

*___입고장
    CASE 'X'.
      WHEN GS_IO-GRJUN.
        ZGTMMT4500-KUNNR2 = '전주공장'.
      WHEN GS_IO-GRENG.
        ZGTMMT4500-KUNNR2 = '엔진공장'.
      WHEN GS_IO-GRDAE.
        ZGTMMT4500-KUNNR2 = '대창엠코'.
*-[SRM2112-01975_S
      WHEN GS_IO-GREXT.
        ZGTMMT4500-KUNNR2 = GV_GREXT.
*]-SRM2112-01975_E
    ENDCASE.
  ELSE.
*} 기능개선 228147 - 추가
    IF WA-CHANGE IS INITIAL.
      ZGTMMT4500-KUNNR1         = WA-KUNNR1.
      ZGTMMT4500-KUNNR          = WA-KUNNR.
    ELSE.
      ZGTMMT4500-ZMANUAL      = 'X'.
      ZGTMMT4500-KUNNR2         = WA-KUNNR1_T.
      ZGTMMT4500-ADDRS          = WA-ADDRS.
    ENDIF.
  ENDIF.

*{ 기능개선 307461 - S
  ZGTMMT4500-RSNUM          = WA-RSNUM.
*{ 기능개선 307461 - E

  LV_IV_NO                =  ZGTMMT4500-IV_NO.
  ZGTMMT4500-REQST          =  'X'.
  ZGTMMT4500-CREATE_TIME    = SY-UZEIT.
  INSERT ZGTMMT4500.  CLEAR ZGTMMT4500.
  COMMIT WORK.

ENDFORM.                    " INSERT_HEADER
*&---------------------------------------------------------------------*
*&      Form  INSERT_ITEM
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM INSERT_ITEM .

  DATA: SEQ   TYPE I.
  CLEAR: SEQ.
  LOOP AT GT_LIST.

* 100908 LGORT 추가
    MOVE-CORRESPONDING GT_LIST TO ZGTMMT4501.
    SEQ = SEQ + 1.
    ZGTMMT4501-IV_SEQ   = SEQ.
    ZGTMMT4501-IV_NO    = WA-IV_NO.
*    zlet0006-waers    = 'KRW'.
    IF WA-RETURN_YN = ' '.
      CLEAR: GT_LIST-RETURN_DUE_DATE,
             ZGTMMT4501-RETURN_DUE_DATE.
    ENDIF.

* 070208 Bon-Chan Koo
* 통문유형이 E07(미투입자재) 일 경우
* 납품문서 = 오더번호, 납품품목 = 영업오더품목번호
* 선적번호 = SM오더번호
    IF WA-IV_TYPE = 'E07'.
      ZGTMMT4501-VBELN = WA-VBELN.
      ZGTMMT4501-POSNR = WA-POSNR.
      ZGTMMT4501-TKNUM = WA-AUFNR.
    ENDIF.
* 070208 수정완료

    MODIFY GT_LIST.

    INSERT ZGTMMT4501.    CLEAR ZGTMMT4501.
    COMMIT WORK.
  ENDLOOP.

ENDFORM.                    " INSERT_ITEM
*&---------------------------------------------------------------------*
*&      Form  CHANGE_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CHANGE_DATA .

*  DATA: lv_return.
*
*  PERFORM pop_up_confirm(zler0004) USING '< 저장여부확인 >'
*                               '저장하시겠읍니까?'
*                      CHANGING lv_return.
*  CHECK lv_return = 'J'.
*
*  PERFORM invoice_no_create(zler0015) USING 'ZLE001' '06'
*                         CHANGING wa-iv_no.
*  IF wa-iv_no <> ' '.
*    PERFORM insert_header .
*    PERFORM insert_item .
*  ELSE.
*    MESSAGE i005(zle1) WITH '통문번호 생성 실패!'.
*    LEAVE TO SCREEN 0.
*  ENDIF.

ENDFORM.                    " CHANGE_DATA
*&---------------------------------------------------------------------*
*&      Form  get_f4_bzarea
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_WA_BZAREA  text
*----------------------------------------------------------------------*
FORM GET_F4_BZAREA  USING P_TYPE.

  DATA: BEGIN OF POV_TYPE OCCURS 0,
          BZAREA     LIKE ZLET0033-BZAREA,
          BZAREA_T   LIKE ZLET0033-BZAREA_T,
        END OF POV_TYPE.

  CLEAR: POV_TYPE[], POV_TYPE.
  SELECT *
  INTO   CORRESPONDING FIELDS OF TABLE POV_TYPE
  FROM   ZLET0033.

  SORT POV_TYPE.
  DELETE ADJACENT DUPLICATES FROM POV_TYPE.

  FIELDTAB-TABNAME    = 'ZLET0033'.
  FIELDTAB-FIELDNAME  = 'BZAREA'.
  FIELDTAB-SELECTFLAG = 'X'.
  APPEND FIELDTAB.

  FIELDTAB-TABNAME    = 'ZLET0034'.
  FIELDTAB-FIELDNAME  = 'BZAREA_T'.
  FIELDTAB-SELECTFLAG = ' '.
  APPEND FIELDTAB.

  LOOP AT POV_TYPE.
    VALUETAB-VALUE = POV_TYPE-BZAREA.
    APPEND VALUETAB.
    VALUETAB-VALUE = POV_TYPE-BZAREA_T.
    APPEND VALUETAB.
  ENDLOOP.

  CALL FUNCTION 'HELP_VALUES_GET_WITH_TABLE_EXT'
       EXPORTING
            DISPLAY       = ' '
*            fieldname     = 'NAME1'
       IMPORTING
            INDEX         = J
     TABLES
            FIELDS        = FIELDTAB
            SELECT_VALUES = I_HELP_VTAB
            VALUETAB      = VALUETAB.

  IF J > 0.
    READ TABLE POV_TYPE INDEX J.
    P_TYPE = POV_TYPE-BZAREA.
  ENDIF.
  REFRESH : FIELDTAB, VALUETAB, POV_TYPE.
  CLEAR   : J,FIELDTAB, VALUETAB, POV_TYPE.

ENDFORM.                    " get_f4_bzarea
*&---------------------------------------------------------------------*
*&      Form  get_mi_matnr_issue
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_MI_MATNR_ISSUE .
  DATA : LV_ERROR,
       : LT_MATNR_MI LIKE ZPPS800 OCCURS 0 WITH HEADER LINE.
  IF WA-VBELN IS INITIAL.
    MESSAGE W000(ZLE1) WITH '판매오더번호를 넣어주십시오.'.
  ELSEIF WA-POSNR IS INITIAL.
    MESSAGE W000(ZLE1) WITH '판매오더 품목번호를 넣어주십시오.'.
  ELSEIF WA-WERKS IS INITIAL.
    MESSAGE W000(ZLE1) WITH '플랜트를 넣어주십시오.'.
  ELSE.
    CALL FUNCTION 'Z_PP_MI_MATNR_ISSUE'
      EXPORTING
        LV_VBELN    = WA-VBELN
        LV_POSNR    = WA-POSNR
        LV_WERKS    = WA-WERKS
      IMPORTING
        EV_ERROR    = LV_ERROR
      TABLES
        GT_MATNR_MI = LT_MATNR_MI.
    IF LV_ERROR = 0.
* 통문이 가능한 수량 =  ENMNG
      LOOP AT LT_MATNR_MI.
        GT_LIST-MAKTX    = LT_MATNR_MI-MAKTX.
        GT_LIST-LFIMG    = LT_MATNR_MI-ENMNG.
        GT_LIST-MTR_UNIT = LT_MATNR_MI-MEINS.
        APPEND GT_LIST.
*GT_LIST-CHK,
*GT_LIST-MAKTX      LIKE MAKT-MAKTX,      "자재명
*GT_LIST-LFIMG      LIKE MSEG-MENGE,      "수량
*GT_LIST-MTR_UNIT   LIKE MSEG-MEINS,      "단위
*GT_LIST-DMBTR      LIKE MSEG-DMBTR,      "금액
*GT_LIST-WAERS      LIKE MSEG-WAERS,
*GT_LIST-RETURN_DUE_DATE LIKE SY-DATUM,   "반입예정일
*MATNR  MATNR CHAR  18  0 자재번호
*MAKTX  MAKTX CHAR  40  0 자재내역
*MEINS  MEINS UNIT  3 0 기본단위
*ERFMG  ERFMG QUAN  13  3 입력단위수량
*ENMNG  ENMNG QUAN  13  3 출고수량
      ENDLOOP.
    ELSE.
* 에러 '1' : 판매오더번호 미존재
*      '2' : 판매오더는 존재하다 전부 출고하여 통문 데이타 없음 Table
      IF LV_ERROR = '1'.
        MESSAGE I000(ZLE1) WITH '판매오더가 존재하지 않습니다.'.
      ELSEIF LV_ERROR = '2'.
        MESSAGE I000(ZLE1) WITH '출고 완료 되었습니다.'.
      ELSE.
        MESSAGE I000(ZLE1) WITH '기타오류가 발생하였습니다.'.
      ENDIF.
    ENDIF.
  ENDIF.
ENDFORM.                    " get_mi_matnr_issue
*&---------------------------------------------------------------------*
*&      Form  GET_BUKRS_DESC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_WA_BUKRS  text
*      -->P_WA_BUTXT  text
*----------------------------------------------------------------------*
FORM GET_BUKRS_DESC  USING    PV_BUKRS
                              PV_BUTXT.

  CLEAR : PV_BUTXT.

  CHECK PV_BUKRS IS NOT INITIAL.

  SELECT SINGLE BUTXT
    INTO PV_BUTXT
    FROM T001
   WHERE BUKRS = PV_BUKRS.

ENDFORM.                    " GET_BUKRS_DESC
*&---------------------------------------------------------------------*
*&      Form  GET_WERKS_DESC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_WA_WERKS  text
*      -->P_WA_WERKS_T  text
*----------------------------------------------------------------------*
FORM GET_WERKS_DESC  USING    PV_WERKS
                              PV_WERKS_T.

  CLEAR : PV_WERKS_T.

  CHECK PV_WERKS IS NOT INITIAL.

  SELECT SINGLE NAME1
    INTO PV_WERKS_T
    FROM T001W
   WHERE WERKS = PV_WERKS.

ENDFORM.                    " GET_WERKS_DESC
*&---------------------------------------------------------------------*
*&      Form  CHECK_BUKRS_WERKS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_WA_BUKRS  text
*      -->P_WA_WERKS  text
*----------------------------------------------------------------------*
FORM CHECK_BUKRS_WERKS  USING    PV_BUKRS
                                 PV_WERKS.

  CLEAR :   GT_PLANT.
  REFRESH : GT_PLANT.

  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE GT_PLANT
    FROM T001K AS A
   INNER JOIN T001W AS B
      ON A~BWKEY = B~BWKEY
   WHERE A~BUKRS = PV_BUKRS
     AND B~WERKS = PV_WERKS.

  IF SY-SUBRC <> 0.
    MESSAGE E001 WITH '회사코드에 해당하는 플랜트를 입력하세요!'.
  ENDIF.

ENDFORM.                    " CHECK_BUKRS_WERKS
*&---------------------------------------------------------------------*
*&      Form  F4HELP_BUKRS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_WA_BUKRS  text
*      -->P_WA_BUTXT  text
*----------------------------------------------------------------------*
FORM F4HELP_BUKRS  USING    PV_BUKRS
                            PV_BUTXT.

  CLEAR   : SELECTFIELD, SELECT_VALUE, LD_TABIX, GT_CODE,
            IT_FIELDS, SCR_FIELDS, FELD_TABLE.
  REFRESH : IT_FIELDS, SCR_FIELDS, FELD_TABLE, GT_CODE.

  SELECT BUKRS BUTXT
    INTO CORRESPONDING FIELDS OF TABLE GT_CODE
    FROM T001
   WHERE BUKRS IN ('1000', '2000', '3000', '5000').

  IT_FIELDS-TABNAME    = 'T001'.
  IT_FIELDS-FIELDNAME  = 'BUKRS'.
  IT_FIELDS-SELECTFLAG = 'X'.
  APPEND IT_FIELDS.

  IT_FIELDS-TABNAME    = 'T001'.
  IT_FIELDS-FIELDNAME  = 'BUTXT'.
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
      FULL_TABLE                   = GT_CODE
    EXCEPTIONS
      FULL_TABLE_EMPTY             = 1
      NO_TABLESTRUCTURE_GIVEN      = 2
      NO_TABLEFIELDS_IN_DICTIONARY = 3
      MORE_THEN_ONE_SELECTFIELD    = 4
      NO_SELECTFIELD               = 5
      OTHERS                       = 6.

  CHECK NOT LD_TABIX IS INITIAL.
  READ TABLE GT_CODE INDEX LD_TABIX.
  PV_BUKRS = GT_CODE-BUKRS.
  PV_BUTXT = GT_CODE-BUTXT.

ENDFORM.                    " F4HELP_BUKRS
*&---------------------------------------------------------------------*
*&      Form  F4HELP_WERKS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_WA_BUKRS  text
*      -->P_WA_WERKS  text
*----------------------------------------------------------------------*
FORM F4HELP_WERKS  USING    PV_BUKRS
                            PV_WERKS.

  CLEAR   : SELECTFIELD, SELECT_VALUE, LD_TABIX, GT_PLANT,
            IT_FIELDS, SCR_FIELDS, FELD_TABLE.
  REFRESH : IT_FIELDS, SCR_FIELDS, FELD_TABLE, GT_PLANT.

  MOVE : 'WA-BUKRS' TO FELD_TABLE-FIELDNAME.
  APPEND FELD_TABLE.

  CALL FUNCTION 'DYNP_VALUES_READ'
    EXPORTING
      DYNAME             = SY-REPID
      DYNUMB             = SY-DYNNR
      TRANSLATE_TO_UPPER = 'X'
    TABLES
      DYNPFIELDS         = FELD_TABLE
    EXCEPTIONS
      OTHERS             = 1.

  READ TABLE FELD_TABLE WITH KEY FIELDNAME = FELD_TABLE-FIELDNAME.
  IF SY-SUBRC <> 0 OR FELD_TABLE-FIELDVALUE IS INITIAL.
    MESSAGE S001 DISPLAY LIKE 'E' WITH '회사코드를 먼저 입력하세요!'.
    EXIT.
  ENDIF.

  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE GT_PLANT
    FROM T001K AS A
   INNER JOIN T001W AS B
      ON A~BWKEY = B~BWKEY
   WHERE A~BUKRS = PV_BUKRS.

  IF SY-SUBRC <> 0.
    MESSAGE S001 DISPLAY LIKE 'E'
    WITH '해당 플랜트가 존재하지 않습니다!'.
  ENDIF.

  IT_FIELDS-TABNAME    = 'T001W'.
  IT_FIELDS-FIELDNAME  = 'WERKS'.
  IT_FIELDS-SELECTFLAG = 'X'.
  APPEND IT_FIELDS.

  IT_FIELDS-TABNAME    = 'T001W'.
  IT_FIELDS-FIELDNAME  = 'NAME1'.
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
      FULL_TABLE                   = GT_PLANT
    EXCEPTIONS
      FULL_TABLE_EMPTY             = 1
      NO_TABLESTRUCTURE_GIVEN      = 2
      NO_TABLEFIELDS_IN_DICTIONARY = 3
      MORE_THEN_ONE_SELECTFIELD    = 4
      NO_SELECTFIELD               = 5
      OTHERS                       = 6.

  CHECK NOT LD_TABIX IS INITIAL.
  READ TABLE GT_PLANT INDEX LD_TABIX.
  PV_WERKS = GT_PLANT-WERKS.

ENDFORM.                    " F4HELP_WERKS
*&---------------------------------------------------------------------*
*&      Form  check_approval
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM CHECK_APPROVAL CHANGING P_CHECK TYPE C.

  CLEAR: GV_APNUM, P_CHECK.

  IF GV_BUKRS = '1000'.
    SELECT SINGLE APNUM
      FROM ZGTMMT4511
      INTO GV_APNUM
      WHERE IV_TYPE = WA-IV_TYPE.
    IF GV_APNUM = '0'.
      P_CHECK = 'X'.
    ELSEIF GV_APNUM > '2'.
      MESSAGE E000 WITH '결재차수가 유효하지 않습니다'.
    ENDIF.
*{ 기능개선 239718 - 추가
  ELSEIF GV_BUKRS = '3000'.
    SELECT SINGLE APNUM3
      FROM ZGTMMT4511
      INTO GV_APNUM
      WHERE IV_TYPE = WA-IV_TYPE.

    IF GV_APNUM = '0'.
      P_CHECK = 'X'.
    ELSEIF GV_APNUM > '2'.
      MESSAGE E000 WITH '결재차수가 유효하지 않습니다'.
    ENDIF.
*} 기능개선 239718 - 추가
  ELSE.
    P_CHECK = 'X'.
  ENDIF.

ENDFORM.                    " check_approval
*&---------------------------------------------------------------------*
*&      Form  insert_approval
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM INSERT_APPROVAL.

  DATA: LS_ZLET0003 LIKE ZLET0003,
        LV_PERNR        TYPE PERSNO,
        LV_APPNM1   LIKE ZLET0003-APP_NM1.

  LS_ZLET0003-IV_NO       = WA-IV_NO.
  IF GV_APNUM = '2'.
    LS_ZLET0003-IV_STATUS = 'A'.             "합의요청
  ELSE.
    LS_ZLET0003-IV_STATUS = 'B'.             "승인요청
  ENDIF.
  LS_ZLET0003-REQ_ID      = WA-PERNR.
  LS_ZLET0003-REQ_NM      = WA-ENAME.
  LS_ZLET0003-REQ_DATE    = SY-DATUM.
  LS_ZLET0003-REQ_TIME    = SY-UZEIT.
  LS_ZLET0003-APP_ID1     = WA_0110-APP_ID1.
  LS_ZLET0003-APP_NM1     = WA_0110-APP_NM1.
  LS_ZLET0003-APP_ID2     = WA_0110-APP_ID2.
  LS_ZLET0003-APP_NM2     = WA_0110-APP_NM2.
  INSERT ZLET0003 FROM LS_ZLET0003.
  COMMIT WORK.

  IF GV_APNUM = '1'.
    LV_PERNR = WA_0110-APP_ID2.
  ELSE.
    LV_PERNR = WA_0110-APP_ID1.
    LV_APPNM1 = WA_0110-APP_NM1.
  ENDIF.

  PERFORM SEND_EMAIL USING LV_PERNR LV_APPNM1.

ENDFORM.                    " insert_approval
*&---------------------------------------------------------------------*
*&      Form  send_email
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM SEND_EMAIL USING P_PERNR TYPE PERSNO
                                   P_APPNM1 LIKE ZLET0003-APP_NM1..

  DATA: LT_CONT_TXT  TYPE TABLE OF SOLISTI1,
        LT_PACK_LIST TYPE SOPCKLSTI1_T,
        LT_RECEIVERS TYPE SOMLRECI1_T,
        LS_CONT_TXT  TYPE SOLISTI1,
        LS_PACK_LIST TYPE SOPCKLSTI1,
        LS_RECEIVER  TYPE SOMLRECI1,
        LS_DOC_DATA  TYPE SODOCCHGI1,
        LV_TITLE     TYPE SO_OBJ_DES,
        LV_SENDER    TYPE SO_REC_EXT,

        BEGIN OF LT_ZLET0083 OCCURS 0,
          PERNR    TYPE ZLET0083-PERNR,
          APP_MAIL TYPE ZLET0083-APP_MAIL,
        END OF LT_ZLET0083.


* 간편결재 사용시 메일 미발송.
  IF gv_simple_approval = 'X' AND WA-IV_TYPE  <> 'E99'.
    EXIT.
  ENDIF.




* Populate message body text
  APPEND LS_CONT_TXT TO LT_CONT_TXT.
  IF GV_APNUM = '2'.
    CONCATENATE '기타통문번호' WA-IV_NO '에 대한 합의가 요청되었습니다.'
                INTO LS_CONT_TXT-LINE SEPARATED BY SPACE.
    APPEND LS_CONT_TXT TO LT_CONT_TXT.
    CONCATENATE '[' WA-IV_NO ']' INTO LV_TITLE.
    CONCATENATE LV_TITLE '통문 합의 요청'
                INTO LV_TITLE SEPARATED BY SPACE.

    CONCATENATE '주합의자' ' : ' '[' P_PERNR ']'  '[' P_APPNM1 ']'
                INTO LS_CONT_TXT-LINE SEPARATED BY SPACE.
    APPEND LS_CONT_TXT TO LT_CONT_TXT.

  ELSE.
    CONCATENATE '기타통문번호' WA-IV_NO '에 대한 승인이 요청되었습니다.'
                INTO LS_CONT_TXT-LINE SEPARATED BY SPACE.
    APPEND LS_CONT_TXT TO LT_CONT_TXT.
    CONCATENATE '[' WA-IV_NO ']' INTO LV_TITLE.
    CONCATENATE LV_TITLE '통문 승인 요청'
                INTO LV_TITLE SEPARATED BY SPACE.
  ENDIF.

* Fill the document data and get size of attachment
  LS_DOC_DATA-OBJ_NAME   = 'EMAIL'.
  LS_DOC_DATA-OBJ_DESCR  = LV_TITLE.
  LS_DOC_DATA-OBJ_LANGU  = SY-LANGU.
  LS_DOC_DATA-SENSITIVTY = 'F'.
  LS_DOC_DATA-OBJ_PRIO   = '1'.
  LS_DOC_DATA-NO_CHANGE  = 'X'.
  LS_DOC_DATA-PRIORITY   = '1'.

* Describe the body of the message
  LS_PACK_LIST-TRANSF_BIN = SPACE.
  LS_PACK_LIST-HEAD_START = 1.
  LS_PACK_LIST-HEAD_NUM   = 0.
  LS_PACK_LIST-BODY_START = 1.
  DESCRIBE TABLE LT_CONT_TXT LINES LS_PACK_LIST-BODY_NUM.
  LS_PACK_LIST-DOC_TYPE   = 'RAW'.
  APPEND LS_PACK_LIST TO LT_PACK_LIST.

  IF SY-SYSID CA 'DQ'.
*    LS_RECEIVER-RECEIVER = 'sdc24@lscns.com'.
*    LS_RECEIVER-REC_TYPE = 'U'.
*    LS_RECEIVER-COM_TYPE = 'INT'.
*    APPEND LS_RECEIVER TO LT_RECEIVERS.
  ELSE.
* Add the recipients email address
    SELECT SINGLE USRID
      FROM ZPA0105
      INTO LS_RECEIVER-RECEIVER
      WHERE PERNR = P_PERNR
        AND SUBTY = '0007'
        AND OBJPS = ''
        AND SPRPS = ''
        AND ENDDA >= SY-DATUM
        AND BEGDA <= SY-DATUM.

    IF SY-SUBRC = 0.
      LS_RECEIVER-REC_TYPE = 'U'.
      LS_RECEIVER-COM_TYPE = 'INT'.
      APPEND LS_RECEIVER TO LT_RECEIVERS.
    ENDIF.

* 동일 사업장 담당자들에게도 메일 수신하도록 추가. 2017-03-29. MJLEE
* 합의시에만 적용
    IF GV_APNUM = '2'.
      CLEAR: LT_ZLET0083, LT_ZLET0083[].
      SELECT PERNR
             APP_MAIL
        INTO CORRESPONDING FIELDS OF TABLE LT_ZLET0083
        FROM ZLET0083
       WHERE BZAREA = WA-BZAREA
         AND LVORM  = SPACE.

      LOOP AT LT_ZLET0083.
        LS_RECEIVER-RECEIVER = LT_ZLET0083-APP_MAIL.
        LS_RECEIVER-REC_TYPE = 'U'.
        LS_RECEIVER-COM_TYPE = 'INT'.
        APPEND LS_RECEIVER TO LT_RECEIVERS. CLEAR LS_RECEIVER.
      ENDLOOP.
    ENDIF.
  ENDIF.

* Sender email address
  SELECT SINGLE USRID
    FROM ZPA0105
    INTO LV_SENDER
    WHERE PERNR = WA-PERNR
      AND SUBTY = '0007'
      AND OBJPS = ''
      AND SPRPS = ''
      AND ENDDA >= SY-DATUM
      AND BEGDA <= SY-DATUM.

  CALL FUNCTION 'SO_DOCUMENT_SEND_API1'
    EXPORTING
      DOCUMENT_DATA              = LS_DOC_DATA
      PUT_IN_OUTBOX              = 'X'
      SENDER_ADDRESS             = LV_SENDER
      SENDER_ADDRESS_TYPE        = 'SMTP'
      COMMIT_WORK                = 'X'
*      ip_encrypt                 =
*      ip_sign                    =
*    IMPORTING
*      sent_to_all                =
*      new_object_id              =
*      sender_id                  =
    TABLES
      PACKING_LIST               = LT_PACK_LIST
*      object_header              =
*      contents_bin               =
      CONTENTS_TXT               = LT_CONT_TXT
*      contents_hex               =
*      object_para                =
*      object_parb                =
      RECEIVERS                  = LT_RECEIVERS
    EXCEPTIONS
      TOO_MANY_RECEIVERS         = 1
      DOCUMENT_NOT_SENT          = 2
      DOCUMENT_TYPE_NOT_EXIST    = 3
      OPERATION_NO_AUTHORIZATION = 4
      PARAMETER_ERROR            = 5
      X_ERROR                    = 6
      ENQUEUE_ERROR              = 7
      OTHERS                     = 8.

  IF SY-SUBRC = 0.
    WAIT UP TO 2 SECONDS.
    SUBMIT RSCONN01 WITH MODE   = 'INT'
                    WITH OUTPUT = ' '
                    AND RETURN.
  ENDIF.

  IF SY-SUBRC = 0.
    MESSAGE S000 WITH '메일을 전송했습니다'.
  ELSE.
    MESSAGE S000 DISPLAY LIKE 'E'
                         WITH '메일전송 도중 오류가 발생했습니다'.
  ENDIF.

ENDFORM.                    " send_email
*&---------------------------------------------------------------------*
*&      Form  tongmun
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM TONGMUN .
  IF NOT WA-IV_NO IS INITIAL.
*    DATA: LV_BZAREA LIKE ZLET0034-BZAREA.
*    RANGES: R_BZAREA FOR ZLET0034-BZAREA.
    RANGES: R_IV_NO FOR ZLET0005-IV_NO.

*    SELECT SINGLE BZAREA INTO LV_BZAREA
*      FROM ZLET0034
*     WHERE WERKS = WA-WERKS.
*
*    R_BZAREA-SIGN   = 'I'.
*    R_BZAREA-OPTION = 'EQ'.
*    R_BZAREA-LOW    = LV_BZAREA.
*    COLLECT R_BZAREA.

    R_IV_NO-SIGN   = 'I'.
    R_IV_NO-OPTION = 'EQ'.
    R_IV_NO-LOW    = WA-IV_NO.
    COLLECT R_IV_NO.

*    SUBMIT ZLER0017 AND RETURN
    SUBMIT ZGTMMR4520 AND RETURN
        WITH P_BUKRS  = GV_BUKRS
        WITH P_BZAREA = WA-BZAREA
        WITH S_IV_NO    IN R_IV_NO.

  ELSE.
    MESSAGE S000 WITH '통문번호 생성후 선택하세요!'.
  ENDIF.
ENDFORM.                    " tongmun
*&---------------------------------------------------------------------*
*&      Form  GET_TRANSPORTATION_REQ_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM GET_TRANSPORTATION_REQ_DATA .
  DATA: LS_1000     LIKE ZLET1000.

  CLEAR : LS_1000,      WA-TRUCK_NO,
          WA-DRIVER_NM, WA-DRIVER_TELNO.

  CHECK WA-REQNO IS NOT INITIAL.

  SELECT SINGLE *
    INTO LS_1000
    FROM ZLET1000
   WHERE REQNO = WA-REQNO.

  IF SY-SUBRC = 0.
    IF LS_1000-STATS = 'D'.
      MESSAGE E004(ZLE1) WITH '배차요청번호' WA-REQNO
                              '은(는) 요청삭제 되었습니다.'.
    ELSE.
      IF LS_1000-CARNO IS NOT INITIAL OR
         LS_1000-DRVNM IS NOT INITIAL OR
         LS_1000-TELNO IS NOT INITIAL.
        WA-TRUCK_NO     = LS_1000-CARNO.     "차량번호
        WA-DRIVER_NM    = LS_1000-DRVNM.     "운전자명
        WA-DRIVER_TELNO = LS_1000-TELNO.     "운전자전화번호
      ENDIF.
    ENDIF.
  ELSE.
    MESSAGE E004(ZLE1) WITH '배차요청번호' WA-REQNO
                            '이(가) 존재하지 않습니다.'.
  ENDIF.

ENDFORM.                    " GET_TRANSPORTATION_REQ_DATA
*&---------------------------------------------------------------------*
*&      Form  F4HELP_REQNO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM F4HELP_REQNO .
  DATA: LT_RSPAR    LIKE RSPARAMS OCCURS 0 WITH HEADER LINE,
        LV_REQNO    LIKE ZLET1000-REQNO.

  CLEAR   : LT_RSPAR.
  REFRESH : LT_RSPAR.

*___회사코드
  CLEAR : LT_RSPAR.
  LT_RSPAR-SELNAME = 'P_BUKRS'.
  LT_RSPAR-KIND    = 'P'.
  LT_RSPAR-LOW     = WA-BUKRS.
  APPEND LT_RSPAR.

*___사업장
  CLEAR : LT_RSPAR.
  LT_RSPAR-SELNAME = 'P_BZAREA'.
  LT_RSPAR-KIND    = 'P'.
  LT_RSPAR-LOW     = WA-BZAREA.
  APPEND LT_RSPAR.

  CLEAR : LT_RSPAR.
  LT_RSPAR-SELNAME = 'P_CALLD'.
  LT_RSPAR-KIND    = 'P'.
  LT_RSPAR-LOW     = 'X'.
  APPEND LT_RSPAR.

  SUBMIT ZLER1240 VIA SELECTION-SCREEN
                 WITH SELECTION-TABLE LT_RSPAR
                  AND RETURN.

  IMPORT LV_REQNO FROM MEMORY ID 'ZLER1240'.

  FREE MEMORY ID 'ZLER1240'.

  WA-REQNO = LV_REQNO.

ENDFORM.                    " F4HELP_REQNO
*&---------------------------------------------------------------------*
*&      Form  GET_BIZ_AREA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM GET_BIZ_AREA  USING    PV_WERKS
                   CHANGING PV_BZAREA
                            PV_BZAREA_T.

  CLEAR : PV_BZAREA, PV_BZAREA_T.

  SELECT SINGLE BZAREA
                BZAREA_T
    INTO (PV_BZAREA, PV_BZAREA_T)
    FROM ZLET0034
   WHERE WERKS = PV_WERKS.

ENDFORM.                    " GET_BIZ_AREA
*&---------------------------------------------------------------------*
*&      Form  SET_IO_WERKS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM SET_IO_WERKS .

  IF OK_CODE = 'IWRK'.
    IF GS_IO-GIJUN = 'X'.
      WA-WERKS = '3602'.
    ELSEIF GS_IO-GIENG = 'X'.
      WA-WERKS = '3606'.
    ELSE.
      CLEAR : WA-WERKS.
    ENDIF.

    PERFORM GET_WERKS_DESC USING WA-WERKS
                                 WA-WERKS_T.

    PERFORM GET_BIZ_AREA USING    WA-WERKS
                         CHANGING WA-BZAREA
                                  WA-BZAREA_T.
  ELSE.
    IF GS_IO-GRJUN = 'X'.
      WA-UMWRK = '3602'.
    ELSEIF GS_IO-GRENG = 'X'.
      WA-UMWRK = '3606'.
    ELSE.
      CLEAR : WA-UMWRK.
    ENDIF.

    PERFORM GET_WERKS_DESC USING WA-UMWRK
                                 WA-UMWRK_T.
  ENDIF.

ENDFORM.                    " SET_IO_WERKS
*&---------------------------------------------------------------------*
*&      Form  MAKE_A_RESERVATION
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM MAKE_A_RESERVATION .

  CLEAR : BDCTAB, G_MSG_T.
  REFRESH : BDCTAB, G_MSG_T.


  PERFORM RECORD_RESERVATION.


** Transaction option
  CTU_PARAMS-DISMODE  =  'N'.
  CTU_PARAMS-UPDMODE  =  'S'.
  CTU_PARAMS-NOBINPT = 'X'.
  CTU_PARAMS-RACOMMIT =  'X'.

  CALL TRANSACTION 'MB21' USING BDCTAB
                          OPTIONS FROM CTU_PARAMS
                          MESSAGES INTO G_MSG_T.

  PERFORM  MESSAGE_RTN2.


ENDFORM.                    " MAKE_A_RESERVATION
*&---------------------------------------------------------------------*
*&      Form  MESSAGE_RTN2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM MESSAGE_RTN2 .

  DATA : L_LINE TYPE I,
           L_MESG(70).

  DESCRIBE TABLE G_MSG_T LINES L_LINE.
  READ TABLE G_MSG_T INDEX L_LINE.

  IF  G_MSG_T-MSGTYP = 'S'.

    CALL FUNCTION 'MESSAGE_TEXT_BUILD'
      EXPORTING
        MSGID               = G_MSG_T-MSGID
        MSGNR               = G_MSG_T-MSGNR
        MSGV1               = G_MSG_T-MSGV1
        MSGV2               = G_MSG_T-MSGV2
        MSGV3               = G_MSG_T-MSGV3
        MSGV4               = G_MSG_T-MSGV4
      IMPORTING
        MESSAGE_TEXT_OUTPUT = L_MESG.
    WA-RSNUM = G_MSG_T-MSGV1.
  ELSE.

    CALL FUNCTION 'MESSAGE_TEXT_BUILD'
      EXPORTING
        MSGID               = G_MSG_T-MSGID
        MSGNR               = G_MSG_T-MSGNR
        MSGV1               = G_MSG_T-MSGV1
        MSGV2               = G_MSG_T-MSGV2
        MSGV3               = G_MSG_T-MSGV3
        MSGV4               = G_MSG_T-MSGV4
      IMPORTING
        MESSAGE_TEXT_OUTPUT = L_MESG.

    CLEAR : WA-IV_NO.
    MESSAGE E001(ZLE1) WITH L_MESG.

  ENDIF.

ENDFORM.                    " MESSAGE_RTN2
*&---------------------------------------------------------------------*
*&      Form  RECORD_RESERVATION
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM RECORD_RESERVATION .

  DATA : LV_LGORT LIKE ZLET0009-LGORT.
  DATA : LV_FIRST, LV_LAST.
  DATA : LV_LFIMG(20).

  CLEAR : LV_LGORT, LV_FIRST, LV_LAST.
  IF GV_BUKRS = '3000'.
    LV_LGORT = '1180'.
  ENDIF.

*--- 이동유형 날짜 입력
  PERFORM  DYNPRO  USING :
                   'X'  'SAPMM07R'         '0500',
                   ' '  'BDC_OKCODE'       '/00',
                   ' '  'RM07M-RSDAT'  WA-CREATE_DATE,
                   ' '  'RM07M-XCALE'        'X',
                   ' '  'RM07M-BWART'        '311',
                   ' '  'RM07M-WERKS'  WA-WERKS.

*--- ITEM 입력
  LOOP AT GT_LIST.
    CLEAR : LV_LFIMG, LV_FIRST, LV_LAST.
    LV_LFIMG = GT_LIST-LFIMG.
    CONDENSE LV_LFIMG NO-GAPS.

    AT FIRST.
      LV_FIRST = 'X'.
    ENDAT.
    AT LAST .
      LV_LAST = 'X'.
    ENDAT.
    PERFORM  DYNPRO  USING :
                     'X'  'SAPMM07R'         '0521',
                     ' '  'BDC_OKCODE'       '/00'.
    IF LV_FIRST = 'X'.
      PERFORM  DYNPRO  USING :
                       ' '  'RKPF-WEMPF'  WA-IV_NO,
                       ' '  'RKPF-UMLGO'  LV_LGORT.
    ENDIF.

    PERFORM  DYNPRO  USING :
                     ' '  'RESB-MATNR(01)'  GT_LIST-MATNR,
                     ' '  'RESB-ERFMG(01)'  LV_LFIMG,
                     ' '  'RESB-LGORT(01)'  GT_LIST-LGORT.
    IF LV_LAST <> 'X'.
      PERFORM  DYNPRO  USING :
                       'X'  'SAPMM07R'         '0521',
                       ' '  'BDC_OKCODE'       '=NLR'.
    ENDIF.
  ENDLOOP.


*--- 저장
  PERFORM  DYNPRO  USING :
                   'X'  'SAPMM07R'         '0521',
                   ' '  'BDC_OKCODE'       '=BU'.




ENDFORM.                    " RECORD_RESERVATION
*&---------------------------------------------------------------------*
*&      Form  DYNPRO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->DYNBEGIN   text
*      -->FNAM       text
*      -->FVAL       text
*----------------------------------------------------------------------*
FORM DYNPRO USING DYNBEGIN FNAM FVAL.

  CLEAR BDCTAB.

  IF  DYNBEGIN  =  'X'.

    BDCTAB-DYNBEGIN  =  'X'.
    BDCTAB-PROGRAM   =  FNAM.
    BDCTAB-DYNPRO    =  FVAL.
    APPEND BDCTAB.

  ELSE.

    BDCTAB-FNAM      =  FNAM.
    BDCTAB-FVAL      =  FVAL.
    APPEND BDCTAB.

  ENDIF.

ENDFORM.                    " dynpro
*&---------------------------------------------------------------------*
*&      Form  UPDATE_ZELT0105
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM UPDATE_ZELT0105 .

  CHECK GV_ORD_NUM IS NOT INITIAL.

  UPDATE ZLET0105  SET   IV_NO = LV_IV_NO
                 WHERE ORD_NUM EQ  GV_ORD_NUM.

ENDFORM.                    " UPDATE_ZELT0105
FORM call_simple_approval  USING    p_reqno.

  CALL FUNCTION 'ZSA1_LE_MAKE_SEND_DATA'
    EXPORTING
      i_iv_no = p_reqno
      i_ztype = 'L1'
      i_bukrs = gv_bukrs.


ENDFORM.
