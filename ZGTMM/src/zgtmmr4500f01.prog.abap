*&---------------------------------------------------------------------*
*&  Include           ZLER0015F01                                      *
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  value_request
*&---------------------------------------------------------------------*
FORM VALUE_REQUEST  USING  P_XX.

* 통문유형 listbox
*  TYPE-POOLS vrm.
*  DATA: lt_values  TYPE vrm_values WITH HEADER LINE.
  DATA: LV_VRMID     TYPE VRM_ID     .
  DATA: P_SEQ(2)     TYPE C.
  DATA: LV_TYPE(30)  TYPE C.
  DATA: LV_WHERE     TYPE STRING.
  DATA: LT_0007      LIKE ZGTMMT4511 OCCURS 0 WITH HEADER LINE.
  DATA: LT_DYNP      LIKE DYNPREAD OCCURS 0 WITH HEADER LINE.

  CLEAR  : LT_VALUES, LT_0007, LV_VRMID.
  REFRESH: LT_VALUES, LT_0007.

  CASE P_XX.
    WHEN 'GUBUN1'.
      LV_VRMID = 'P_GUBUN1'.

*{ 기능개선 273711 - 변경
*      CASE P_BUKRS.
*        WHEN '1000'.
*          LV_WHERE = 'AND COCD1 = ''X'''.
*        WHEN '2000'.
*          LV_WHERE = 'AND COCD2 = ''X'''.
*        WHEN '3000'.
*          LV_WHERE = 'AND COCD3 = ''X'''.
*        WHEN '5000'.
*          LV_WHERE = 'AND COCD4 = ''X'''.
*        WHEN OTHERS.
*          CLEAR : LV_WHERE.
*      ENDCASE.

      CASE 'X'.
        WHEN R1. "MM일반
          CONCATENATE 'IV_TYPE LIKE ''B__'' AND MDULE <> ''SM'' AND BUKRS = P_BUKRS'
                      LV_WHERE
                 INTO LV_WHERE SEPARATED BY SPACE.

        WHEN R2. "매각/폐기
          CONCATENATE 'IV_TYPE LIKE ''D__'''
                      LV_WHERE
                 INTO LV_WHERE SEPARATED BY SPACE.
*가온전선_조회 조건 R3(PP)미사용으로 주석_(ZGODEV04_260106)
*->시작
*        WHEN R3.
*          CONCATENATE 'IV_TYPE LIKE ''B__'' AND MDULE = ''MMPP'''
*                      LV_WHERE
*                 INTO LV_WHERE SEPARATED BY SPACE.

        WHEN OTHERS.
*가온전선_조회 조건 R4(서비스)미사용으로 주석_(ZGODEV04_260106)
*          CONCATENATE 'IV_TYPE LIKE ''B__'' AND MDULE = ''SM'''
*                      LV_WHERE
*                 INTO LV_WHERE SEPARATED BY SPACE.
*<-끝.
      ENDCASE.

*     CASE 'X'.
*       WHEN R1.
*         CASE P_BUKRS.
*           WHEN '1000'.
*             LV_WHERE = 'AND COCD1 = ''X'''.
*           WHEN '2000'.
*             LV_WHERE = 'AND COCD2 = ''X'''.
*           WHEN '3000'.
*             LV_WHERE = 'AND COCD3 = ''X'''.
*           WHEN '5000'.
*             LV_WHERE = 'AND COCD4 = ''X'''.
*           WHEN OTHERS.
*             CLEAR : LV_WHERE.
*         ENDCASE.
*
*         CONCATENATE 'IV_TYPE LIKE ''B__'' AND MDULE <> ''SM'''
*                     LV_WHERE
*                INTO LV_WHERE SEPARATED BY SPACE.
*
*       WHEN R2.
*         LV_WHERE = 'IV_TYPE LIKE ''D__'''.
*
*       WHEN R3.
*         LV_WHERE = 'IV_TYPE LIKE ''B__'' AND MDULE = ''MMPP'''.
*
*       WHEN OTHERS.
*         LV_WHERE = 'IV_TYPE LIKE ''B__'' AND MDULE = ''SM'''.
*
*     ENDCASE.
*} 기능개선 273711 - 변경

      SELECT *
        INTO CORRESPONDING FIELDS OF TABLE LT_0007
*        INTO TABLE LT_0007
        FROM   ZGTMMT4511
       WHERE bukrs = p_bukrs and gubun = 'MM'.

*{ 기능개선 273305 - 삭제
**___'999:전체' 추가
*      PERFORM GET_VRM_ID_VALUES TABLES LT_VALUES
*                                USING  '999' '999:전체'.
*} 기능개선 273305 - 삭제

      LOOP AT LT_0007.
        CONCATENATE LT_0007-IV_TYPE ':' LT_0007-IV_TYPE_NM
               INTO LV_TYPE.

        PERFORM GET_VRM_ID_VALUES TABLES LT_VALUES
                                  USING  LT_0007-IV_TYPE
                                         LV_TYPE.
      ENDLOOP.
  ENDCASE.

  CALL FUNCTION 'VRM_SET_VALUES'
    EXPORTING
      ID              = LV_VRMID
      VALUES          = LT_VALUES[]
    EXCEPTIONS
      ID_ILLEGAL_NAME = 1
      OTHERS          = 2.

  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

ENDFORM.                    " value_request
*&---------------------------------------------------------------------*
*&      Form  MM_GET_DATA
*&---------------------------------------------------------------------*
FORM MM_GET_DATA .
  DATA: LV_WERKS    LIKE T001W-WERKS.


*/ 사업장
  CLEAR   : R_WERKS, R_UMWRK, R_LGORT, R_WERK1, R_UMWR1, R_UMLG1.
  REFRESH : R_WERKS, R_UMWRK, R_LGORT, R_WERK1, R_UMWR1, R_UMLG1.

*{ 기능개선 273305 - 추가
    IF P_GUBUN1 = 'B21'.
      SET_RANGES: R_WERKS 'I' 'EQ' '6500' ' ',       "출발지
                            R_UMWRK 'I' 'EQ' '6600' ' '.       "목적지

    ELSEIF P_GUBUN1 = 'B22'.
      SET_RANGES: R_WERKS 'I' 'EQ' '6600' ' ',       "출발지
                            R_UMWRK 'I' 'EQ' '6500' ' '.       "목적지

   ELSEIF P_GUBUN1 = 'B20'.
      IF R1 = 'X' AND P_WERKS ='6500'.
      SET_RANGES: R_UMLG1 'I' 'EQ' '1110' ' ',
                            R_UMLG1 'I' 'EQ' '3430' ' ',
                            R_UMLG1 'I' 'EQ' '3497' ' '.
     ELSEIF R1 = 'X' AND P_WERKS ='6600'.
      SET_RANGES: R_UMLG1 'I' 'EQ' '3497' ' ',
                            R_UMLG1 'I' 'EQ' '3498' ' '.

     ELSEIF R1 = 'X' AND P_WERKS ='6581'.
      SET_RANGES:  R_UMLG1 'I' 'EQ' '3498' ' '.

     ENDIF.
    ELSE.
*} 기능개선 273305 - 추가
      SELECT W~WERKS
          FROM T001K AS K
          INNER JOIN T001W    AS W
           ON W~BWKEY = K~BWKEY
          INNER JOIN ZLET0034 AS Z
           ON Z~WERKS = W~WERKS
          INTO LV_WERKS
          WHERE K~BUKRS  = P_BUKRS.

        SET_RANGES: R_WERKS 'I' 'EQ' LV_WERKS ' '.

      ENDSELECT.


      SELECT W~WERKS
        FROM T001K AS K
        INNER JOIN T001W    AS W
          ON W~BWKEY = K~BWKEY
*가온전선_사업장 조회조건 미사용으로 주석_(ZGODEV04_260106)
*        INNER JOIN ZLET0071 AS Z
*          ON Z~WERKS = W~WERKS
        INTO LV_WERKS
        WHERE K~BUKRS  = P_BUKRS.
*가온전선_사업장 조회조건 미사용으로 주석_(ZGODEV04_260106)
*        AND Z~BZAREA = P_BZAREA.

        SET_RANGES: R_WERKS 'I' 'EQ' LV_WERKS ' '.
      ENDSELECT.
*}E SRM2209-05218


    ENDIF.
*  ENDIF.
*<-끝.

*/ 이동유형
  CLEAR   : I_IVTYP.
  REFRESH : I_IVTYP.

*{ 기능개선 273711 - 변경
    SELECT SINGLE BWART
      FROM ZGTMMT4511 INTO @LV_BWART
     WHERE IV_TYPE = @P_GUBUN1.

    IF SY-SUBRC = 0.
      SET_RANGES: I_IVTYP 'I' 'EQ' LV_BWART ' '.
    ENDIF.


  CLEAR   : GT_TAB, GT_OUT.
  REFRESH : GT_TAB, GT_OUT.



  IF R1 = 'X' AND P_GUBUN1 = 'B01'.         "기능개선 249949 - 추가
* [END]   CSR NO : C20080221_20568

    SELECT B~CPUDT B~MBLNR B~ZEILE B~LIFNR B~MATNR
           B~ERFME AS MEINS B~ERFMG AS MENGE B~BWART B~MJAHR B~WERKS
           B~UMWRK B~SHKZG B~LGORT B~EBELN B~EBELP B~BKTXT
           INTO CORRESPONDING FIELDS OF TABLE GT_TAB

           FROM MATDOC AS B
          WHERE B~BUKRS =  P_BUKRS
            AND B~BWART IN I_IVTYP
            AND B~MBLNR IN I_MBLNR
            AND B~CPUDT IN I_CPUDT
            AND B~CPUDT > '20061231'
            AND B~WERKS = P_WERKS
            AND B~WERKS IN R_WERKS
            AND B~LIFNR IN I_LIFNR
            AND B~AUFNR IN I_AUFNR.
  ELSEIF R1 = 'X' AND P_GUBUN1 = 'B20'.
*} 기능개선 249949 - 변경
*-} 기능개선 65348_2015.02.04
    SELECT B~CPUDT B~MBLNR B~ZEILE B~LIFNR B~MATNR B~CHARG
           B~ERFME AS MEINS B~ERFMG AS MENGE B~BWART B~MJAHR B~WERKS
           B~UMWRK B~SHKZG B~LGORT B~EBELN B~EBELP B~UMLGO
           INTO CORRESPONDING FIELDS OF TABLE GT_TAB
           FROM MATDOC AS B
          WHERE B~BUKRS =  P_BUKRS
            AND B~BWART IN I_IVTYP
            AND B~MBLNR IN I_MBLNR
            AND B~CPUDT IN I_CPUDT
            AND B~WERKS = P_WERKS
            AND B~WERKS IN R_WERKS
            AND B~LIFNR IN I_LIFNR
            AND B~AUFNR IN I_AUFNR
            AND B~SHKZG =  'H'
            AND B~UMLGO IN  R_UMLG1.


  ELSEIF R1 = 'X' AND ( P_GUBUN1 = 'B21' OR P_GUBUN1 = 'B22' ).
    SELECT B~CPUDT B~MBLNR B~ZEILE "B~LINE_ID B~PARENT_ID
           B~LIFNR B~MATNR B~CHARG
           B~ERFME AS MEINS B~ERFMG AS MENGE B~BWART B~MJAHR B~WERKS
           B~UMWRK B~SHKZG B~LGORT B~EBELN B~EBELP
           INTO CORRESPONDING FIELDS OF TABLE GT_TAB
           FROM MATDOC AS B
          WHERE B~BUKRS =  P_BUKRS
            AND B~BWART IN I_IVTYP
            AND B~MBLNR IN I_MBLNR
            AND B~CPUDT IN I_CPUDT
            AND B~WERKS = P_WERKS
            AND B~WERKS IN R_WERKS
            AND B~UMWRK IN R_UMWRK           "기능개선 273305 - 추가
            AND B~LIFNR IN I_LIFNR
            AND B~AUFNR IN I_AUFNR
            AND B~SHKZG =  'H'
            AND B~cancelled = ''
            AND B~reversal_movement = ''.


  ELSE.
    SELECT B~CPUDT B~MBLNR B~ZEILE "B~LINE_ID B~PARENT_ID
           B~LIFNR B~MATNR
           B~ERFME AS MEINS B~ERFMG AS MENGE B~BWART B~MJAHR B~WERKS
           B~UMWRK B~SHKZG B~LGORT B~EBELN B~EBELP
           INTO CORRESPONDING FIELDS OF TABLE GT_TAB
*           FROM mkpf AS a INNER JOIN mseg AS b
*             ON a~mblnr EQ b~mblnr AND
*                a~mjahr EQ b~mjahr
           FROM MATDOC AS B
          WHERE B~BUKRS =  P_BUKRS
            AND B~BWART IN I_IVTYP
            AND B~MBLNR IN I_MBLNR
            AND B~CPUDT IN I_CPUDT
            AND B~WERKS = P_WERKS
            AND B~WERKS IN R_WERKS
            AND B~LIFNR IN I_LIFNR
            AND B~AUFNR IN I_AUFNR
            AND B~SHKZG =  'H'.
*            AND b~aufnr LIKE '9%'
  ENDIF.

  DATA: LV_FLAG.
  DATA: LV_IVTYP LIKE ZLET0009-IV_TYPE.
*  IF P_GUBUN1 = '1'.                        "기능개선 249949 - 삭제
  IF P_GUBUN1 = '999'.                       "기능개선 249949 - 추가
    LV_IVTYP = 'B__'.
  ELSE.
*{ 기능개선 273711 - 변경
    LV_IVTYP = P_GUBUN1.
*    LV_IVTYP = LT_VALUES-TEXT+0(3).
*} 기능개선 273711 - 변경
  ENDIF.

  LOOP AT GT_TAB.
* Y31 이동유형에 의해 발생한 자재문서는 동시에 입출고가 발생하므로
* MSEG-SHKZG 값 'H' 인것만 발행
    IF GT_TAB-BWART = 'Y31' AND GT_TAB-SHKZG NE 'H'. "저장위치간 이동
      DELETE GT_TAB.
      CONTINUE.
    ENDIF.

    CLEAR: MARC, LV_FLAG.
    SELECT SINGLE DISPO INTO MARC-DISPO FROM MARC
                       WHERE MATNR = GT_TAB-MATNR
                         AND WERKS = GT_TAB-WERKS
******************************************************************
* 20070222 simcho by 이길상K I_DISPO
******************************************************************
                         AND DISPO IN I_DISPO.
    IF I_DISPO IS NOT INITIAL AND
       SY-SUBRC <> 0.
      DELETE GT_TAB.
      CONTINUE.
    ENDIF.
******************************************************************
* [START] CSR NO : C20110307_37676
* 사용자가 역분개를 치지 않고 반대이동유형으로 취소했을 경우
* 제대로 취소데이터를 가져오지 못하는 현상 해결하기 위해
* 테이블 생성(ZLE0151)으로 수작업으로 제어
    SELECT SINGLE MANDT INTO SY-MANDT
    FROM   ZLET0151
    WHERE  MJAHR = GT_TAB-MJAHR
    AND    MBLNR = GT_TAB-MBLNR
    AND    ZUSE  = 'X'.
    IF SY-SUBRC = 0.
      DELETE GT_TAB.
      CONTINUE.
    ENDIF.
* [END]   CSR NO : C20110307_37676

** 외부창고이전(B20)인 경우 인동자동차부품, 전주트랙처만 가능
** by J.Y.Lee 09/11/2012 C20120822_68619
*    IF GT_TAB-BWART = '311'.
*      IF ( GT_TAB-WERKS = '3402' AND GT_TAB-LGORT = '3610' ) OR
*         ( GT_TAB-WERKS = '3602' AND GT_TAB-LGORT = '3710' ).
*      ELSE.
*        DELETE GT_TAB.
*        CONTINUE.
*      ENDIF.
*    ENDIF.

    CASE P_GUBUN1.
*      WHEN '12'. "B20: 외부창고출고         "기능개선 249949 - 삭제
      WHEN 'B20'. "B20: 외부창고출고         "기능개선 249949 - 추가
        IF GT_TAB-BWART = '311'.
          IF ( GT_TAB-WERKS = '6500' AND GT_TAB-LGORT = '1100' )  OR ( GT_TAB-WERKS = '6500' AND GT_TAB-LGORT = '3410' )  OR
               ( GT_TAB-WERKS = '6500' AND GT_TAB-LGORT = '3420' )  OR ( GT_TAB-WERKS = '6600' AND GT_TAB-LGORT = '3410' ) OR
               ( GT_TAB-WERKS = '6581' AND GT_TAB-LGORT = '3410' ) .
          ELSE.
            DELETE GT_TAB.
            CONTINUE.
          ENDIF.
        ENDIF.
      WHEN 'B21'.
        IF GT_TAB-BWART = '301'.
          IF GT_TAB-WERKS = '6500' AND GT_TAB-UMWRK = '6600' AND
           ( GT_TAB-LGORT = '1100' OR  GT_TAB-LGORT = '2110' OR
             GT_TAB-LGORT = '2120' OR  GT_TAB-LGORT = '3410' OR
             GT_TAB-LGORT = '3420' ).

          ELSE.
            DELETE GT_TAB.
            CONTINUE.
          ENDIF.
        ENDIF.
      WHEN 'B22'.
        IF GT_TAB-BWART = '301'.
          IF GT_TAB-WERKS = '6600' AND GT_TAB-UMWRK = '6500' AND
           ( GT_TAB-LGORT = '1100' OR  GT_TAB-LGORT = '2110' OR
             GT_TAB-LGORT = '2210' OR  GT_TAB-LGORT = '2310' OR
             GT_TAB-LGORT = '3410' ).

          ELSE.
            DELETE GT_TAB.
            CONTINUE.
          ENDIF.
        ENDIF.

      WHEN OTHERS.
    ENDCASE.

* 유상사급인 경우 전표텍스트가 INJSA이면 제외
* by J.Y.Lee 05/02/2012 C20120502_00791
* [START] CSR NO : C20080430_59983
    IF R1 = 'X' AND GT_TAB-BWART = '541'.
      IF GT_TAB-CPUDT < '20070101' OR GT_TAB-BKTXT = 'INJSA'.
        DELETE GT_TAB.
        CONTINUE.
      ENDIF.
    ENDIF.
* [END]   CSR NO : C20080430_59983

    IF GT_TAB-BWART = 'Z71' OR GT_TAB-BWART = 'Z81' OR
       GT_TAB-BWART = '281' OR GT_TAB-BWART = '221' OR
* 20060816 simcho 기계부문 이동유형 추가
       GT_TAB-BWART = '124' OR GT_TAB-BWART = 'Z75'.

    ELSE.
*   이동유형이 MM과 동일하므로 PP Table에 미 존재하는 Data만 발췌
      CLEAR: ZPPT0112.
      SELECT SINGLE * FROM ZPPT0112 WHERE WERKS = GT_TAB-WERKS
                                      AND DISPO = MARC-DISPO
                                      AND LGORT = GT_TAB-LGORT.
      IF SY-SUBRC = 0.
* 배치관리 안하는 것은 MM  - BY SDC08 , MMB03

* [START] CSR Number : C20110708_21829 BCKOO
* MM담당자 확인결과 과거이력은 확인 불가.
* 물류 흐름을 위해 배치사용유무에 따른 통문증 발행 가부 제어로직 제거
*        SELECT SINGLE MANDT INTO SY-MANDT FROM MARA
*           WHERE MATNR = GT_TAB-MATNR
*             AND XCHPF = 'X'.
*        IF SY-SUBRC = 0.
*          LV_FLAG = 'X'.
*        ENDIF.
* [END] CSR Number : C20110708_21829
      ELSE.
*      lv_flag = 'X'.
      ENDIF.
    ENDIF.

* SM이동유형 통문관리 대상 점검 CHECK.   SDB01 061218
* 이동유형이 Y* 인것만 예외 CHECK.
    IF GT_TAB-BWART+0(1) = 'Y'.
      PERFORM SM_IVTYPE_CHECK USING LV_IVTYP
                           CHANGING LV_FLAG.

    ENDIF.
* MM통문 대상 selection flag - LV_LFLAG = ' ' 인것만 대상임
    CHECK LV_FLAG = ' '.

    CLEAR MSEG.

*   자재문서 취소시 DATA 삭제
    SELECT SINGLE * FROM MSEG WHERE SMBLN = GT_TAB-MBLNR
                                AND SJAHR = GT_TAB-MJAHR
                                AND SMBLP = GT_TAB-ZEILE.
    CHECK SY-SUBRC <> 0.
    IF GT_TAB-BWART = '541' OR GT_TAB-BWART = '351'.
      CHECK GT_TAB-SHKZG = 'H'.
* 재고운송오더351 출고시 같은 사업장내이동 통문제외
      IF GT_TAB-BWART = '351'.
        CHECK GT_TAB-UMWRK+0(2) <>  GT_TAB-WERKS+0(2).
      ENDIF.
*

    ENDIF.
*   통문 Detail 에 존재
    CLEAR: ZGTMMT4500, T_LFIMG.
    SELECT * FROM ZGTMMT4501 WHERE MBLNR = GT_TAB-MBLNR
                             AND ZEILE = GT_TAB-ZEILE
                             AND MJAHR = GT_TAB-MJAHR.
*     통문증 Header에 삭제 Flag가 찍힌 Data는 통문증을 다시 재발행
      SELECT SINGLE * FROM ZGTMMT4500 WHERE IV_NO = ZGTMMT4501-IV_NO
                                      AND IV_CANCEL_YN <> 'X'.
      IF SY-SUBRC = 0.
        T_LFIMG = T_LFIMG + ZGTMMT4501-LFIMG.
      ENDIF.
    ENDSELECT.
    CHECK T_LFIMG < GT_TAB-MENGE.

* [START] CSR NO : C20071015_50616
    IF GT_TAB-BWART = 'Y91'.
      DATA : LV_AUFNR  LIKE MSEG-AUFNR.
      DATA : LV_VAPLZ  LIKE AUFK-VAPLZ.

      SELECT SINGLE AUFNR
      INTO   LV_AUFNR
      FROM   MSEG
      WHERE  MBLNR = GT_TAB-MBLNR.

      IF SY-SUBRC = 0.
        SELECT SINGLE VAPLZ
        INTO   LV_VAPLZ
        FROM   AUFK
        WHERE  AUFNR = LV_AUFNR.

        IF SY-SUBRC = 0.
          SELECT SINGLE  LTEXT
            INTO (GT_TAB-LTEXT)
            FROM ZSMT0070
           WHERE ARBPL = LV_VAPLZ.
        ELSE.
        ENDIF.
      ELSE.
      ENDIF.
    ELSE.
      SELECT SINGLE LGOBE
      INTO GT_TAB-LTEXT
      FROM T001L
      WHERE WERKS = GT_TAB-WERKS
      AND   LGORT = GT_TAB-LGORT.
    ENDIF.
* [END]   CSR NO : C20071015_50616

    MOVE-CORRESPONDING GT_TAB TO GT_OUT.

    IF LV_IVTYP IS NOT INITIAL.
      IF LV_IVTYP+2(1) = '_'.
        SELECT SINGLE IV_TYPE_NM IV_TYPE
          INTO (GT_OUT-BWTXT, GT_OUT-IVTYP)
          FROM ZGTMMT4511
         WHERE BWART = GT_TAB-BWART
           AND IV_TYPE LIKE LV_IVTYP.
      ELSE.
*{ 기능개선 273305 - 변경
        SELECT SINGLE IV_TYPE_NM IV_TYPE
          INTO (GT_OUT-BWTXT, GT_OUT-IVTYP)
          FROM ZGTMMT4511
         WHERE IV_TYPE = LV_IVTYP.

*        SELECT SINGLE IV_TYPE_NM IV_TYPE
*          INTO (GT_OUT-BWTXT, GT_OUT-IVTYP)
*          FROM ZLET0007
*         WHERE BWART   = GT_TAB-BWART
*           AND IV_TYPE = LV_IVTYP.
*} 기능개선 273305 - 변경
      ENDIF.
    ELSE.
      SELECT SINGLE IV_TYPE_NM IV_TYPE
        INTO (GT_OUT-BWTXT, GT_OUT-IVTYP)
        FROM ZGTMMT4511
       WHERE BWART = GT_TAB-BWART.
    ENDIF.


*******************************************************
* 2007.02.07 simcho by 이길상 K
* 무상사급일 경우 전체품명 select (if exit)
*******************************************************
*   자재 품명:규격
    IF GT_OUT-IVTYP = 'B01'.
      SELECT SINGLE ZZMAKTX80 INTO GT_OUT-MAKTX FROM MARA
                         WHERE MATNR EQ GT_TAB-MATNR.

      IF GT_OUT-MAKTX IS INITIAL.
        SELECT SINGLE MAKTX INTO GT_OUT-MAKTX FROM MAKT
                           WHERE MATNR EQ GT_TAB-MATNR
                             AND SPRAS EQ '3'.
      ENDIF.

    ELSE.
      SELECT SINGLE MAKTX INTO GT_OUT-MAKTX FROM MAKT
                         WHERE MATNR EQ GT_TAB-MATNR
                           AND SPRAS EQ '3'.
    ENDIF.

    IF GT_TAB-BWART = '351'.
      SELECT SINGLE NAME1 INTO GT_OUT-NAME1 FROM T001W
                         WHERE WERKS = GT_TAB-UMWRK.

      GT_OUT-LIFNR1 = GT_TAB-UMWRK.
    ELSE.
      SELECT SINGLE NAME1 INTO GT_OUT-NAME1 FROM LFA1
                         WHERE LIFNR = GT_TAB-LIFNR.

      GT_OUT-LIFNR1 = GT_TAB-LIFNR .
    ENDIF.

    APPEND GT_OUT.  CLEAR GT_OUT.
  ENDLOOP.
*


  DESCRIBE TABLE GT_OUT LINES SY-TFILL.
  IF SY-TFILL = 0.
    MESSAGE S005(ZLE1) WITH '조건에 맞는 DATA가 없습니다'.
    IF SY-DYNNR = '1000'.
      STOP.
    ELSE.
      LEAVE TO SCREEN 0.
    ENDIF.
  ENDIF.
  SORT GT_OUT BY IVTYP MBLNR ZEILE LIFNR MATNR.
  DESCRIBE TABLE GT_OUT LINES TC01-LINES.


***********************************************************************
* 3402플랜트 자재별 합계 로직

*}E SRM2209-05218
***********************************************************************

ENDFORM.                    " MM_GET_DATA
*&---------------------------------------------------------------------*
*&      Form  ALL_DE_SELECT_CHECKBOX
*&---------------------------------------------------------------------*
FORM ALL_DE_SELECT_CHECKBOX .

  LOOP AT GT_OUT.
    IF SY-UCOMM = 'ASEL'.
      GT_OUT-CHK   = 'X'.
      GT_OUT-CFLAG = 'X'.
    ELSE.
      GT_OUT-CHK   = ' '.
      GT_OUT-CFLAG = ' '.
    ENDIF.
    MODIFY GT_OUT.
  ENDLOOP.
  CLEAR: TEMP_LIFNR, TEMP_MBLNR.
ENDFORM.                    " ALL_DE_SELECT_CHECKBOX
*&---------------------------------------------------------------------*
*&      Form  INVOICE_NO_CREATE
*&---------------------------------------------------------------------*
FORM INVOICE_NO_CREATE  USING P_OBJT P_RANGE
                                             CHANGING P_NUMBER.

* I/V NO 를 Unique 하게 생성한다.
  CALL FUNCTION 'NUMBER_GET_NEXT'
    EXPORTING
      NR_RANGE_NR = P_RANGE
      OBJECT      = P_OBJT
    IMPORTING
      NUMBER      = P_NUMBER.

ENDFORM.                    " INVOICE_NO_CREATE
*&---------------------------------------------------------------------*
*&      Form  SAME_MBLNR_CHECK
*&---------------------------------------------------------------------*
FORM SAME_MBLNR_CHECK  USING    P_MBLNR.

* 동일 납품문서시 Check box 조건
  REFRESH LT_VTAB.  CLEAR: LT_VTAB.

  LOOP AT GT_OUT WHERE CHK = 'X'.

    IF TEMP_MBLNR <> ' ' AND  TEMP_MBLNR <> GT_OUT-MBLNR.
*      IF TEMP_MBLNR <> GT_OUT-MBLNR.

        IF TEMP_IVTYP <> GT_OUT-IVTYP.
          MESSAGE I005(ZLE1) WITH GT_OUT-MBLNR '은 통문유형이 틀립니다'(M05).

          LOOP AT GT_OUT.
            GT_OUT-CHK = 'X'.
            MODIFY GT_OUT TRANSPORTING CHK.
          ENDLOOP.

          GT_OUT-CHK = ' '.
          GT_OUT-CFLAG = ' '.
          MODIFY GT_OUT INDEX SY-TABIX.
          CONTINUE.
        ENDIF.
*
        IF TEMP_LIFNR <> GT_OUT-LIFNR.
          MESSAGE I005(ZLE1) WITH GT_OUT-MBLNR '의 거래처가 틀립니다'(M06).

          GT_OUT-CHK = ' '.
          GT_OUT-CFLAG = ' '.
          MODIFY GT_OUT INDEX SY-TABIX.
          CONTINUE.
        ENDIF.

        IF TEMP_IVTYP = 'B17'.
          IF TEMP_WERKS <> GT_OUT-WERKS.
            MESSAGE I005(ZLE1) WITH TEMP_WERKS '의 플랜트가 틀립니다'(M07).

            GT_OUT-CHK = ' '.
            GT_OUT-CFLAG = ' '.
            MODIFY GT_OUT INDEX SY-TABIX.
            CONTINUE.
          ENDIF.
        ENDIF.

*      ENDIF.
    ENDIF.
    LT_VTAB-MBLNR = GT_OUT-MBLNR.
    COLLECT LT_VTAB.
  ENDLOOP.
*

  LOOP AT LT_VTAB.
    AT NEW MBLNR.
      TEMP_MBLNR = LT_VTAB-MBLNR.
*      TEMP_WERKS = LT_VTAB-WERKS.
      READ TABLE GT_OUT WITH KEY MBLNR = LT_VTAB-MBLNR
                                   CHK = ' '
                                 CFLAG = 'X'.
      IF SY-SUBRC = 0.
        LV_CK = 'X'.
      ELSE.
        CLEAR LV_CK.
      ENDIF.
    ENDAT.

    IF LV_CK = 'X'.
      LOOP AT GT_OUT WHERE MBLNR = LT_VTAB-MBLNR.
        GT_OUT-CHK  = ' '.
        GT_OUT-CFLAG = ' '.
        MODIFY GT_OUT INDEX SY-TABIX.
        CLEAR GT_OUT.
      ENDLOOP.

    ELSE.
      LOOP AT GT_OUT WHERE MBLNR = LT_VTAB-MBLNR.
        GT_OUT-CHK   = 'X'.
        GT_OUT-CFLAG = 'X'.
        MODIFY GT_OUT INDEX SY-TABIX.
        CLEAR GT_OUT.
      ENDLOOP.
    ENDIF.
  ENDLOOP.

  READ TABLE GT_OUT WITH KEY MBLNR = TEMP_MBLNR.
  IF SY-SUBRC = 0.
    TEMP_LIFNR = GT_OUT-LIFNR.
    TEMP_IVTYP = GT_OUT-IVTYP.
    TEMP_WERKS = GT_OUT-WERKS.
  ENDIF.

  READ TABLE GT_OUT WITH KEY CHK = 'X'.
  IF SY-SUBRC <> 0.
    CLEAR: TEMP_MBLNR, TEMP_LIFNR, TEMP_IVTYP, TEMP_WERKS.
  ENDIF.

ENDFORM.                    " SAME_MBLNR_CHECK
*&---------------------------------------------------------------------*
*&      Form  IV_TYPE_SETTING
*&---------------------------------------------------------------------*
FORM IV_TYPE_SETTING  USING    P_SIGN P_OPTION P_TYPE.

  I_IVTYP-SIGN   = P_SIGN.
  I_IVTYP-OPTION = P_OPTION.
  I_IVTYP-LOW    = P_TYPE.
  APPEND I_IVTYP.  CLEAR I_IVTYP.

ENDFORM.                    " IV_TYPE_SETTING
*&---------------------------------------------------------------------*
*&      Form  PAGE_SCROLLING
*&---------------------------------------------------------------------*
FORM PAGE_SCROLLING  CHANGING P_TOP_LINE.

  CALL FUNCTION 'SCROLLING_IN_TABLE'
    EXPORTING
      ENTRY_ACT      = P_TOP_LINE
      ENTRY_TO       = TC01-LINES
      LAST_PAGE_FULL = ' '
      LOOPS          = LOOPS
      OK_CODE        = SY-UCOMM
      OVERLAPPING    = 'X'
    IMPORTING
      ENTRY_NEW      = P_TOP_LINE
    EXCEPTIONS
      OTHERS         = 01.
ENDFORM.                    " PAGE_SCROLLING
*&---------------------------------------------------------------------*
*&      Form  DD_GET_DATA
*&---------------------------------------------------------------------*
FORM DD_GET_DATA .

*/ 사업장
  CLEAR: R_WERKS[], R_WERKS.
  SELECT * FROM ZLET0034 WHERE BZAREA = P_BZAREA.

    SET_RANGES: R_WERKS 'I' 'EQ' ZLET0034-WERKS ' '.

  ENDSELECT.

* 이동유형
  REFRESH I_IVTYP. CLEAR I_IVTYP.
  REFRESH: GT_MTAB, GT_OUT.  CLEAR: GT_MTAB, GT_OUT.
*  IF P_GUBUN1 = '2'.                        "기능개선 249949 - 삭제
  IF P_GUBUN1 = 'D01'.                       "기능개선 249949 - 추가
    PERFORM IV_TYPE_SETTING USING 'I' 'EQ' '폐기'.   "LIFNR
*  ELSEIF P_GUBUN1 = '3'.                    "기능개선 249949 - 삭제
  ELSEIF P_GUBUN1 = 'D02'.                   "기능개선 249949 - 추가
    PERFORM IV_TYPE_SETTING USING 'I' 'EQ' '매각'.
  ELSE.
    PERFORM IV_TYPE_SETTING USING 'I' 'EQ' '폐기'.
    PERFORM IV_TYPE_SETTING USING 'I' 'EQ' '매각'.
  ENDIF.

* 매각/폐기 CBO 에서 조건에 맞는 DATA 발췌
* ZMMT0016: 매각/폐기 처리 HEADER
* ZMMT0017: 매각/폐기 처리 DETAIL
  SELECT A~DOCNO A~TRTYPE A~KUNNR A~LIFNR A~ERDAT
         B~POSNR B~MATNR B~MENGE B~MEINS B~WAERS B~NETPR B~DMBTR
         A~GSBER A~BUKRS C~WERKS
         INTO CORRESPONDING FIELDS OF TABLE GT_MTAB
       FROM ZMMT0016 AS A INNER JOIN ZMMT0017 AS B
            ON A~DOCNO = B~DOCNO
                          INNER JOIN ZMMT0018 AS C
            ON A~BUKRS  = C~BUKRS
           AND A~BRANCH = C~BRANCH
           AND A~GSBER  = C~GSBER
      WHERE A~BUKRS   =  P_BUKRS
        AND A~DOCNO   IN I_MBLNR
*        AND a~gsber   IN r_werks
        AND A~BRANCH = P_WERKS
        AND A~ERDAT   IN I_CPUDT
        AND A~TRTYPE  IN I_IVTYP.
*
  LOOP AT GT_MTAB.
    CLEAR: ZGTMMT4501, ZGTMMT4500, T_LFIMG.
*   통문 Detail 에 존재
    SELECT * FROM ZGTMMT4501 WHERE MBLNR = GT_MTAB-DOCNO
                             AND ZEILE = GT_MTAB-POSNR.
*     통문증 Header에 삭제 Flag가 찍힌 Data는 통문증을 다시 재발행
      SELECT SINGLE * FROM ZGTMMT4500 WHERE IV_NO = ZGTMMT4501-IV_NO
                                      AND IV_CANCEL_YN <> 'X'.
      IF SY-SUBRC = 0.
        T_LFIMG = T_LFIMG + ZGTMMT4501-LFIMG.
      ENDIF.
    ENDSELECT.
    CHECK T_LFIMG < GT_MTAB-MENGE.
*
    MOVE-CORRESPONDING GT_MTAB TO GT_OUT.
    GT_OUT-CPUDT = GT_MTAB-ERDAT.
    GT_OUT-MBLNR = GT_MTAB-DOCNO.
    GT_OUT-ZEILE = GT_MTAB-POSNR.
*    GT_OUT-WERKS = GT_MTAB-GSBER.
    GT_OUT-BUKRS = GT_MTAB-BUKRS. "회사코드 데이터 처리

*   이동유형별 Description
    IF GT_MTAB-TRTYPE = '매각'.
      CHECK GT_MTAB-KUNNR IN I_LIFNR.
      GT_OUT-LIFNR1 = GT_MTAB-KUNNR.
      GT_OUT-KUNNR  = GT_MTAB-KUNNR.
      GT_OUT-BWTXT = '매각'.
      GT_OUT-IVTYP = 'D02'.
      SELECT SINGLE NAME1 INTO GT_OUT-NAME1 FROM KNA1
                         WHERE KUNNR = GT_MTAB-KUNNR.
    ELSE.
      CHECK GT_MTAB-LIFNR IN I_LIFNR.
      GT_OUT-LIFNR1 = GT_MTAB-LIFNR.
      GT_OUT-LIFNR  = GT_MTAB-LIFNR.
      GT_OUT-BWTXT = '폐기'.
      GT_OUT-IVTYP = 'D01'.

      SELECT SINGLE NAME1 INTO GT_OUT-NAME1 FROM LFA1
                          WHERE LIFNR = GT_MTAB-LIFNR.
    ENDIF.
    CLEAR ZMMT0019.
    SELECT SINGLE MAKTX INTO GT_OUT-MAKTX FROM ZMMT0019
                       WHERE MATNR = GT_MTAB-MATNR.
    APPEND GT_OUT.  CLEAR GT_OUT.
  ENDLOOP.
*
  DESCRIBE TABLE GT_OUT LINES SY-TFILL.
  IF SY-TFILL = 0.
    MESSAGE S005(ZLE1) WITH '조건에 맞는 DATA가 없습니다'.
    IF SY-DYNNR = '1000'.
      STOP.
    ELSE.
      LEAVE TO SCREEN 0.
    ENDIF.
  ENDIF.
  SORT GT_OUT BY IVTYP MBLNR ZEILE.
  DESCRIBE TABLE GT_OUT LINES TC01-LINES.

ENDFORM.                    " DD_GET_DATA
*&---------------------------------------------------------------------*
*&      Form  SCREEN_FIELD_CHANG
*&---------------------------------------------------------------------*
FORM SCREEN_FIELD_CHANG .

*  clear p_gubun1. 기존주석
*가온전선_R3(PP)미사용으로 주석_(ZGODEV04_260106)
*->시작
*  IF R3 <> 'X'.
    IF R1 = 'X' AND GV_FLAG1 = ' '.
*      P_GUBUN1 = '999'. "기존주석
      GV_FLAG1 = 'X'.
      CLEAR: GV_FLAG2, GV_FLAG3.
    ENDIF.
    IF R2 = 'X' AND GV_FLAG2 = ' '.
*      P_GUBUN1 = '999'. 기존주석
      GV_FLAG2 = 'X'.
      CLEAR: GV_FLAG1, GV_FLAG3.
    ENDIF.
*  IF r3 = 'X' AND GV_FLAG3 = ' '. "기존주석
*    p_gubun1 = '2'.
*    GV_FLAG3 = 'X'.
*    CLEAR: GV_FLAG1, GV_FLAG2.
*  ENDIF.
*  ENDIF.
*<-끝.

  LOOP AT SCREEN.
    IF SCREEN-GROUP1 = 'M1'.
*      IF P_BUKRS IS INITIAL.
*        SCREEN-INPUT = 0.
*        P_GUBUN1 = ''.
*      ELSE.
*        SCREEN-INPUT = 1.
*        P_GUBUN1 = '2'.
*      ENDIF.
    ELSEIF SCREEN-GROUP1 = 'M2' AND P_BZAREA IS INITIAL.
      SCREEN-INPUT = 0.
      CLEAR: P_WERKS.
*가온전선_R4(서비스)미사용으로 주석_(ZGODEV04_260106)
*->시작
*    ELSEIF SCREEN-NAME = 'R4' AND P_BUKRS = '1000'.
*      SCREEN-INPUT = 0.
*      IF R4 = 'X'.
*        R1 = 'X'.
*        R4 = ''.
*      ENDIF.
*<-끝.
    ELSE.
      IF R2 = 'X'.
        IF SCREEN-NAME = 'I_WERKS-LOW' OR
           SCREEN-NAME = 'I_WERKS-HIGH'.
          SCREEN-INPUT = 0.
        ENDIF.
      ELSE.
        IF SCREEN-NAME = 'I_BRANCH-LOW' OR
           SCREEN-NAME = 'I_BRANCH-HIGH'.
          SCREEN-INPUT = 0.
        ENDIF.
      ENDIF.
    ENDIF.
*    IF SCREEN-NAME = 'R3'.
**      SCREEN-INPUT = 0.
*      SCREEN-ACTIVE = 0.
*    ENDIF.
    MODIFY SCREEN.
  ENDLOOP.

ENDFORM.                    " SCREEN_FIELD_CHANG
*&---------------------------------------------------------------------*
*&      Form  DESCENDING_SORT
*&---------------------------------------------------------------------*
FORM A_DE_SCENDING_SORT .

  DATA: INAME(10),
        SNAME(10).
*
  SPLIT G_CURSOR_FIELD AT '-' INTO INAME SNAME.
  IF SY-UCOMM = 'DSOR'.
    SORT GT_OUT BY (SNAME) DESCENDING.
  ELSE.
    SORT GT_OUT BY (SNAME) ASCENDING.
  ENDIF.

ENDFORM.                    " A_DE_SCENDING_SORT
*&---------------------------------------------------------------------*
*&      Form  SM_HEADER
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LV_IVNO  text
*      -->P_LV_MBLNR  text
*      -->P_LV_IVTYP  text
*      -->P_LV_LIFNR  text
*----------------------------------------------------------------------*
FORM SM_HEADER  USING    P_IVNO
                         P_MBLNR
                         P_IVTYP
                         P_LIFNR
                         P_WERKS
                         P_UMWRK
                         P_KUNNR
                         P_MJAHR.

  DATA : LS_OUT LIKE LINE OF GT_OUT OCCURS 0   WITH HEADER LINE.
  REFRESH: LV_SM01.
  CLEAR: LV_SM01.

* 회사주소
*{ 2014031100058 거래명세서의 공급자란 회사명/주소 정보 수정
  CLEAR T001W.
*  IF LV_IVTYP = 'D01' OR LV_IVTYP = 'D02'.
*  ELSE.
  SELECT SINGLE ADDRESS
    INTO LV_SM01-WNAME
    FROM ZLET0121 AS A
   INNER JOIN T001K AS B
      ON A~BUKRS   = B~BUKRS
   WHERE B~BWKEY   = GT_OUT-WERKS.
*가온전선_사업장(P_BZAREA)조회조건 미사용으로 주석_(ZGODEV04_260106)
*     AND A~ZBZAREA = P_BZAREA.

  IF SY-SUBRC <> 0.
    SELECT SINGLE ADDRESS
      INTO LV_SM01-WNAME
      FROM ZLET0121
     WHERE ZBZAREA = P_BZAREA.
  ENDIF.

*    SELECT SINGLE * FROM T001W WHERE WERKS =  P_WERKS.
*    IF T001W-ORT01 CO T001W-STRAS.
*      IF SY-FDPOS <> 0.
*        LV_SM01-WNAME = T001W-STRAS.
*      ENDIF.
*    ELSE.
*      CONCATENATE T001W-ORT01 ' ' T001W-STRAS
*      INTO LV_SM01-WNAME SEPARATED BY SPACE.
*    ENDIF.
*  ENDIF.

* [START] CSR NO : C20070807_12525
* JS전선 대표이사명 변경 by J.Y.Lee 11/03/2011 C20111101_91139
*{ 2014030700032 거래명세서의 공급자란 대표자 정보 수정 요청
  IF P_BZAREA+0(1) = 'J'.
    GV_BUKRS = '2000'.
  ELSE.
*-{자체개선 45041 - 추가
    IF R2 = 'X'.
      IF GV_BUKRS IS INITIAL.
        LOOP AT GT_OUT.
          SELECT SINGLE BUKRS
            INTO GV_BUKRS
            FROM T001K
           WHERE BWKEY = GT_OUT-WERKS.

          IF SY-SUBRC = 0.
            EXIT.
          ENDIF.
        ENDLOOP.
      ENDIF.
    ELSE.
      CLEAR : GV_BUKRS.

      SELECT SINGLE BUKRS
        INTO GV_BUKRS
        FROM MATDOC
       WHERE MBLNR = P_MBLNR.
    ENDIF.
  ENDIF.

  SELECT SINGLE BUKRS
                REPRES
                KR_BUTXT
    INTO (LV_SM01-BUKRS, LV_SM01-CEONM,
          LV_SM01-COMPA)
    FROM ZLET0120
   WHERE BUKRS  = GV_BUKRS
     AND ZMODUL = 'LE'.

  CONCATENATE '대표이사' LV_SM01-CEONM
         INTO LV_SM01-CEONM SEPARATED BY SPACE.


* 회사 전화번호
  SELECT SINGLE * FROM ZLET0034 WHERE WERKS =  P_WERKS.
  LV_SM01-COTEL = ZLET0034-TELNO.



  IF LV_IVTYP = 'B04'.
    CASE P_WERKS.
      WHEN '6500'.
        LV_SM01-GNAME = '전주통신공장'.
        LV_SM01-RNAME = '전주통신공장'.
        LV_SM01-RADDR = '구미시 공단동 129-8 엘에스테크(주) ' &
                                      '(팔복동 3가)'.

      WHEN '6600'.
        LV_SM01-GNAME = '군포전력공장'.
        LV_SM01-RNAME = '군포전력공장'.
        LV_SM01-RADDR = '(435-824) 경기도 군포시 엘에스로 45번길 120'.
    ENDCASE.

  ELSEIF LV_IVTYP = 'B20'.  "저장위치간 이동

    DATA : L_LGORT1 LIKE MSEG-LGORT.

    SELECT SINGLE LGORT INTO L_LGORT1
    FROM   MSEG
    WHERE  MBLNR = P_MBLNR
    AND    SHKZG = 'S'.

    IF SY-SUBRC = 0.
      SELECT SINGLE NAME1 WAEMP ADDR ZTIBORNM
        INTO (LV_SM01-GNAME, LV_SM01-RNAME,
              LV_SM01-RADDR, LV_SM01-RUSER)
      FROM   ZSMT0068
      WHERE  WERKS =  P_WERKS
      AND    LGORT =  L_LGORT1.
    ENDIF.

*  ELSEIF LV_IVTYP = 'B04'.
*    CASE P_WERKS.
*      WHEN '6500'.
*        LV_SM01-GNAME = '군포전력공장'.
*        LV_SM01-RNAME = '자동차부품외부'.
**       주소변경 by J.Y.Lee 12/19/2013 기능개선 3804
*        LV_SM01-RADDR = '구미시 공단동 129-8 엘에스테크(주) ' &
*                        '폭스공장 2층'.
**        LV_SM01-RADDR = '구미시 산동면 봉산리 구미제4단지 4B 10-42'.
*      WHEN '6600'.    "전주트랙터
*        LV_SM01-GNAME = '전주통신공장'.
*        LV_SM01-RNAME = '트랙터 외부창고'.
*        LV_SM01-RADDR = '전북 완주군 봉동읍 둔산리 931-8'.
*    ENDCASE.
*
*
*
*  ELSEIF LV_IVTYP = 'B11'.  "SM오더 출고(이동유형 Y91)
*
*    DATA : LV_AUFNR  LIKE MSEG-AUFNR.
*    DATA : LV_EQUNR  LIKE AFIH-EQUNR.
*    DATA : LV_OBJNR  LIKE EQUI-OBJNR.
*    DATA : LV_PARNR  LIKE IHPA-PARNR.
*    DATA : LV_CITY2  LIKE ADRC-CITY1.
*    DATA : LV_STRE2  LIKE ADRC-STREET.
** [START] CSR NO : C20071015_50616
*    DATA : LV_VAPLZ  LIKE AUFK-VAPLZ.
*    DATA : LV_UMLGO  LIKE ZSMT0070-LGORT.
** [END]   CSR NO : C20071015_50616
*    CLEAR: LV_CITY2, LV_STRE2.
*
*    SELECT SINGLE AUFNR
*    INTO   LV_AUFNR
*    FROM   MSEG
*    WHERE  MBLNR = LV_MBLNR.
*
*    IF SY-SUBRC = 0.
*
*      SELECT SINGLE EQUNR
*      INTO   LV_EQUNR
*      FROM   AFIH
*      WHERE  AUFNR = LV_AUFNR.
*
*      IF LV_EQUNR IS NOT INITIAL.
*
*        SELECT SINGLE OBJNR
*        INTO   LV_OBJNR
*        FROM   EQUI
*        WHERE  EQUNR = LV_EQUNR.
*
*        IF SY-SUBRC = 0.
*
*          SELECT SINGLE PARNR
*          INTO   LV_PARNR
*          FROM   IHPA
*          WHERE  OBJNR = LV_OBJNR
*          AND    PARVW = 'AG'
*          AND    KZLOESCH <> 'X'.
*
*          IF SY-SUBRC = 0.
*
*            SELECT SINGLE NAME1 ORT01 STRAS
*            INTO   (LV_SM01-RNAME, LV_CITY2, LV_STRE2)
*            FROM   KNA1
*            WHERE  KUNNR = LV_PARNR.
*
*            LV_SM01-GNAME = LV_SM01-RNAME . "상호
*
*            CONCATENATE LV_CITY2 '' LV_STRE2
*            INTO LV_SM01-RADDR SEPARATED BY SPACE.
*
*          ELSE.
*
*            SELECT SINGLE PARNR
*            INTO   LV_PARNR
*            FROM   IHPA
*            WHERE  OBJNR = LV_OBJNR
*            AND    PARVW = 'Y2'
*            AND    KZLOESCH <> 'X'.
*
*            IF SY-SUBRC = 0.
*
*              SELECT SINGLE NAME1 ORT01 STRAS
*              INTO   (LV_SM01-RNAME, LV_CITY2, LV_STRE2)
*              FROM   KNA1
*              WHERE  KUNNR = LV_PARNR.
*
*              LV_SM01-GNAME = LV_SM01-RNAME . "상호
*
*              CONCATENATE LV_CITY2 '' LV_STRE2
*              INTO LV_SM01-RADDR SEPARATED BY SPACE.
*
*            ENDIF.
*
*          ENDIF.
*
** [START] CSR NO : C20071015_50616
*          IF P_BZAREA <> '5100'.
*            SELECT SINGLE VAPLZ
*            INTO   LV_VAPLZ
*            FROM   AUFK
*            WHERE  AUFNR = LV_AUFNR.
*
*            IF SY-SUBRC = 0.
*              DATA: LV_RNAME LIKE ZLES014-RNAME.
*              DATA: LV_RADDR LIKE ZLES014-RADDR.
*              DATA: LV_RUSER LIKE ZLES014-RUSER.
*
*              SELECT SINGLE LGORT INTO LV_UMLGO
*              FROM   ZSMT0070
*              WHERE  ARBPL = LV_VAPLZ.
*
*              SELECT SINGLE NAME1 ADDR ZTIBORNM
*              INTO   (LV_RNAME,LV_RADDR,LV_RUSER)
*              FROM   ZSMT0068
*              WHERE  WERKS = P_WERKS
*              AND    LGORT = LV_UMLGO
*              AND    FLAG  = 'Y'.
*
*              IF SY-SUBRC = 0.
*                LV_SM01-RNAME = LV_RNAME.
*                LV_SM01-RADDR = LV_RADDR.
*                LV_SM01-RUSER = LV_RUSER.
*                LV_SM01-GNAME = LV_RNAME. "상호
*              ELSE.
*              ENDIF.
*            ELSE.
*
*            ENDIF.
*          ENDIF.
** [END]   CSR NO : C20071015_50616
*        ENDIF.
*
*      ELSE.
*
*      ENDIF.
*
*    ENDIF.
*
*  ELSEIF LV_IVTYP = 'B13' OR
*         LV_IVTYP = 'B14' .  "SM오더 출고(이동유형 Y93).
*
*    LV_SM01-GNAME = GV_GNAME.
*    LV_SM01-RNAME = GV_RNAME.
*    LV_SM01-RADDR = GV_RADDR.
*    LV_SM01-RUSER = GV_RUSER.
*
**[START] CSR NUMBER : C20110518_86311
** 트랙터 공장이체간일경우
*  ELSEIF LV_IVTYP = 'B17'.
*    IF P_WERKS = '3606'.
*      LV_SM01-RNAME = '3782'.
*    ELSEIF P_WERKS = '3782' AND P_BZAREA = '5300' .
*      LV_SM01-RNAME = '3602'.
*    ELSEIF P_WERKS = '3782'.
*      LV_SM01-RNAME = '3606'.
*    ENDIF.
*
*    SELECT SINGLE NAME1 BZAREA_T
*    INTO   (LV_SM01-GNAME, LV_SM01-RADDR)
*    FROM   ZLET0034
*    WHERE  WERKS = LV_SM01-RNAME.
*
*    IF P_WERKS = '3602'.
*      LV_SM01-RNAME = '3782'.
*      SELECT SINGLE NAME1 BZAREA_T
*      INTO   (LV_SM01-GNAME, LV_SM01-RADDR)
*      FROM   ZLET0071
*      WHERE  WERKS = LV_SM01-RNAME.
*    ENDIF.
*
**스크랩 출고일 경우 공급자 정보 가져오기 07.01.31
*  ELSEIF LV_IVTYP = 'B10'.
*    SELECT  SINGLE KUNNR
*      INTO  P_KUNNR
*      FROM  ZMMT0099
*     WHERE  MBLNR = P_MBLNR
*       AND  MJAHR = P_MJAHR.
*
*    SELECT  SINGLE NAME1 ORT01 STRAS
*      INTO (LV_SM01-RNAME, LV_CITY2, LV_STRE2)
*      FROM  KNA1
*     WHERE  KUNNR = P_KUNNR.
*
*    LV_SM01-GNAME = LV_SM01-RNAME . "상호
*
*    CONCATENATE LV_CITY2 '' LV_STRE2
*           INTO LV_SM01-RADDR SEPARATED BY SPACE.

  ELSEIF LV_IVTYP = 'B21' OR LV_IVTYP = 'B22'.
    CASE P_WERKS.
      WHEN '6500'.
        LV_SM01-GNAME = '전주통신공장'.
        LV_SM01-RNAME = '전주통신공장'.
        LV_SM01-RADDR = '구미시 공단동 129-8 엘에스테크(주) ' &
                                      '(팔복동 3가)'.

      WHEN '6600'.
        LV_SM01-GNAME = '군포전력공장'.
        LV_SM01-RNAME = '군포전력공장'.
        LV_SM01-RADDR = '(435-824) 경기도 군포시 엘에스로 45번길 120'.
    ENDCASE.


  ELSE. "그 외의 이동유형 일 경우 기존 로직 수행
    DATA: LV_CITY1  LIKE ADRC-CITY1,
          LV_STREET LIKE ADRC-STREET.
    CLEAR: LV_CITY1, LV_STREET.

    IF NOT LV_LIFNR IS INITIAL.
      SELECT SINGLE NAME1 ORT01 STRAS
       INTO (LV_SM01-RNAME, LV_CITY1, LV_STREET)  FROM LFA1
        WHERE LIFNR = P_LIFNR.
    ENDIF.

    IF NOT LV_KUNNR IS INITIAL.
      SELECT SINGLE NAME1 ORT01 STRAS
       INTO (LV_SM01-RNAME, LV_CITY1, LV_STREET)  FROM KNA1
        WHERE KUNNR = P_KUNNR.
    ENDIF.

    IF NOT LV_UMWRK IS INITIAL.
      SELECT SINGLE NAME1 ORT01 STRAS
       INTO (LV_SM01-RNAME, LV_CITY1, LV_STREET)  FROM T001W
        WHERE WERKS = P_UMWRK.
    ENDIF.

    LV_SM01-GNAME = LV_SM01-RNAME . "상호

    CONCATENATE LV_CITY1 '' LV_STREET
       INTO LV_SM01-RADDR SEPARATED BY SPACE.

  ENDIF.
* 20061201 수정종료



  IF P_IVTYP = 'B01'.
    LV_SM01-IVTYP = 'B01 무상사급'.
  ELSEIF P_IVTYP = 'B02'.
    LV_SM01-IVTYP = 'B02 반품(Return Delivery)'.
  ELSEIF P_IVTYP = 'B03'.
    LV_SM01-IVTYP = 'B03 반품(PO)'.
  ELSEIF P_IVTYP = 'B04'.
    LV_SM01-IVTYP = 'B04 공장간이체(STO)'.
  ELSEIF P_IVTYP = 'B20'.
    LV_SM01-IVTYP = 'B20 외부 창고 이동'.
  ELSEIF P_IVTYP = 'B21'.
    LV_SM01-IVTYP = 'B21 공장간 이체(군포->전주)'.
  ELSEIF P_IVTYP = 'B22'.
    LV_SM01-IVTYP = 'B22 공장간 이체(전주->군포)'.
*  ELSEIF P_IVTYP = 'B06'.
*    LV_SM01-IVTYP = 'B06 투자(Z81)'.
*  ELSEIF P_IVTYP = 'B07'.
*    LV_SM01-IVTYP = 'B07 공사(281)'.
*  ELSEIF P_IVTYP = 'B08'.
*    LV_SM01-IVTYP = 'B08 PROJECT(221)'.
*  ELSEIF P_IVTYP = 'B10'.
*    LV_SM01-IVTYP = 'B10 SCRAP 출고'.
*  ELSEIF P_IVTYP = 'B11'.
*    LV_SM01-IVTYP = 'B11 SM오더출고'.
*  ELSEIF P_IVTYP = 'B12'.
*    LV_SM01-IVTYP = 'B12 회수품폐기'.
*  ELSEIF P_IVTYP = 'B13'.
*    LV_SM01-IVTYP = 'B13 회수품교환'.
*  ELSEIF P_IVTYP = 'B14'.
*    LV_SM01-IVTYP = 'B14 WARR.출고'.
*  ELSEIF P_IVTYP = 'B15'.
*    LV_SM01-IVTYP = 'B15 창고간전기'.
*  ELSEIF P_IVTYP = 'D02'.
*    LV_SM01-IVTYP = 'D02 매각'.
*  ELSEIF P_IVTYP = 'D01'.
*    LV_SM01-IVTYP = 'D01 폐기'.
*  ELSEIF P_IVTYP = 'B17'.
*    LV_SM01-IVTYP = 'B17 창고이전(트랙터)'.
*  ELSEIF P_IVTYP = 'B20'.
*    LV_SM01-IVTYP = 'B20 문경창고이동'.
*  ELSEIF P_IVTYP = 'B21'.
*    LV_SM01-IVTYP = 'B21 공장간 이체(군포->전주)'.
*  ELSEIF P_IVTYP = 'B22'.
*    LV_SM01-IVTYP = 'B22 공장간 이체(전주->군포)'.
  ENDIF.




*
*[기능개선 41489 통문증 발행일자 오류 수정 요청 2014.08.28 by.H.M.LIM]
* 엠트론의 경우 발행일자, 출력일자 구분하여 표기
  IF GV_BUKRS = '3000'.
*   발행일자
    READ TABLE IZGTMMT4500 INDEX 1.
    IF SY-SUBRC = 0.

*{ CHM2008-00227 -S
      LV_SM01-SGDT1 = IZGTMMT4500-CREATE_DATE.
*} CHM2008-00227 -E

      CONCATENATE IZGTMMT4500-IV_DATE+0(4)     '년'
                  IZGTMMT4500-IV_DATE+4(2)     '월'
                  IZGTMMT4500-IV_DATE+6(2)     '일'
                  IZGTMMT4500-CREATE_TIME+0(2) ':'
                  IZGTMMT4500-CREATE_TIME+2(2) INTO LV_SM01-IVDAT.
    ELSE.
      CONCATENATE SY-DATUM+0(4) '년' SY-DATUM+4(2) '월' SY-DATUM+6(2)
                  '일' SY-UZEIT+0(2) ':' SY-UZEIT+2(2)
                  INTO LV_SM01-IVDAT.
*{ CHM2008-00227 -S
      LV_SM01-SGDT1 = SY-DATUM.
*} CHM2008-00227 -E
    ENDIF.
    CLEAR IZGTMMT4500.

*   출력일자
    LV_SM01-PTDAT = LV_SM01-IVDAT.
  ELSE.
*   발행일자
    CONCATENATE SY-DATUM+0(4) '년' SY-DATUM+4(2) '월' SY-DATUM+6(2)
                '일' SY-UZEIT+0(2) ':' SY-UZEIT+2(2)
                INTO LV_SM01-IVDAT.
  ENDIF.

  LV_SM01-IVNUM = P_IVNO.
  APPEND LV_SM01.

ENDFORM.                    " SM_HEADER
*&---------------------------------------------------------------------*
*&      Form  SM_DETAIL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SM_DETAIL .
  DATA: BEGIN OF LT_LONG OCCURS 0,
          TEXT(200),
        END   OF LT_LONG.

  DATA : LV_ZAUMA LIKE ZPPTIF68-ZAUMA,
         LV_CHARG LIKE ZPPTIF68-CHARG,
         LV_MATNR LIKE MARA-MATNR.

  DATA : LS_IFTAB TYPE ZPPTIF68,
         LT_IFTAB TYPE TABLE OF ZPPTIF68 WITH HEADER LINE.

  CLEAR : LV_ZAUMA, LV_CHARG.

  REFRESH: LV_SM03. CLEAR: LV_SM03.
  REFRESH: GT_RPRT. CLEAR: GT_RPRT.
  REFRESH: LT_IFTAB.

* 20061201 Bon-Chan Koo
* Y31 이동유형에 의해 발생한 자재문서는 동시에 입출고가 발생하므로
* MSEG-SHKZG 값 'H' 인것만 발행
  IF LV_IVTYP = 'B15'.  "저장위치간 이동(이동유형 Y31)
    DELETE GT_OUT WHERE SHKZG NE 'H'.
  ENDIF.
* 20061201 수정 완료

  IF P_PRTCHK = 'X'.
* COLLECT
* APPEND
    LOOP AT GT_OUT WHERE CHK = 'X'.
      MOVE-CORRESPONDING GT_OUT TO LV_SM03.

      LV_SM03-LFIMG = GT_OUT-MENGE.
      LV_SM03-VRKME = GT_OUT-MEINS.
      LV_SM03-ZEILE = ' '.
*-{기능개선110094 -플랜트 3402(전자부품) 자재별 합계시 자재문서 무시하고
* Collect 되도록 처리, 기존 자재문서별 합계 -> 자재별 합계

*-}기능개선110094_2016.01.11
      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
        EXPORTING
          INPUT  = GT_OUT-MATNR
        IMPORTING
          OUTPUT = GT_OUT-MATNR.

      CONCATENATE GT_OUT-MATNR '(' GT_OUT-MAKTX ')'
        INTO LV_SM03-MAKTX.

      CALL FUNCTION 'ZSD_SPLIT_STRING'
        EXPORTING
          I_STR         = LV_SM03-MAKTX
          STR_LEN       = 50
        IMPORTING
          O_STR         = LV_SM03-MAKTX
        TABLES
          IT_STR        = LT_LONG.

      IF R1 = 'X' AND GT_OUT-IVTYP = 'B04'.
        LV_SM03-TAGNR = GT_OUT-EBELN.
        LV_SM03-EBELN = GT_OUT-EBELP.
      ELSEIF R1 = 'X' AND GT_OUT-IVTYP = 'B20' AND
             GT_OUT-WERKS = '3602'.
        LV_SM03-TAGNR = GT_OUT-CHARG.
      ENDIF.

      COLLECT LV_SM03. CLEAR LV_SM03.
    ENDLOOP.

  ELSE.

* APPEND
    LOOP AT GT_OUT WHERE CHK = 'X'.

      MOVE-CORRESPONDING GT_OUT TO LV_SM03.

      LV_SM03-LFIMG = GT_OUT-MENGE.
      LV_SM03-VRKME = GT_OUT-MEINS.

      LV_MATNR = GT_OUT-MATNR.

      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
        EXPORTING
          INPUT  = GT_OUT-MATNR
        IMPORTING
          OUTPUT = GT_OUT-MATNR.

      CONCATENATE GT_OUT-MATNR '(' GT_OUT-MAKTX ')'
        INTO LV_SM03-MAKTX.

      CALL FUNCTION 'ZSD_SPLIT_STRING'
        EXPORTING
          I_STR         = LV_SM03-MAKTX
          STR_LEN       = 50
        IMPORTING
          O_STR         = LV_SM03-MAKTX
        TABLES
          IT_STR        = LT_LONG.

      IF R1 = 'X' AND GT_OUT-IVTYP = 'B04'.

        LV_SM03-TAGNR = GT_OUT-EBELN.
        LV_SM03-EBELN = GT_OUT-EBELP.

      ELSEIF R1 = 'X' AND GT_OUT-IVTYP = 'B20' AND
             GT_OUT-WERKS = '3602'.

        LV_SM03-TAGNR = GT_OUT-CHARG.

*-[SRM2208-01973_S
** 2140 이동일 경우, 비고란에 기대번호가 아닌 도킹번호 출력.
        IF GT_OUT-LGORT = '2140'.

          CLEAR : LV_ZAUMA, LV_CHARG, LS_IFTAB.

*-[SRM2303-10895_S
** 동일기대 출고 시에도 각 도킹번호 출력을 위해 수정 진행.

** 이슈사항 : 동일자재/배치/자재문서에서 도킹번호만 다름...

          CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
            EXPORTING
              INPUT  = LV_MATNR
            IMPORTING
              OUTPUT = LV_MATNR.

          SELECT SINGLE *
            INTO CORRESPONDING FIELDS OF LS_IFTAB
            FROM ZPPTIF68
           WHERE MBLNR = GT_OUT-MBLNR
             AND MATNR = LV_MATNR
             AND WERKS = GT_OUT-WERKS
             AND UMWRK = GT_OUT-WERKS
             AND LGORT = '2140'
             AND UMLGO = '2142'
             AND BWART = '311'
             AND ZAUMA = 'D'
             AND ZERET = '00'
             AND ZLE_USE <> 'X'.

          IF SY-SUBRC = 0.

            LV_ZAUMA          = LS_IFTAB-ZAUMA.
            LV_CHARG          = LS_IFTAB-CHARG.
            GT_OUT-DOCKING_NO = LV_CHARG.
            LS_IFTAB-ZLE_USE  = 'X'.

            CLEAR LV_SM03-TAGNR.
            CONCATENATE '  ' LV_CHARG INTO LV_SM03-TAGNR
            SEPARATED BY SPACE.

* 우선 저장 시키고, 뒤에서 미리 보기 시에는 삭제 처리함.
            UPDATE ZPPTIF68 SET ZLE_USE = 'X'
            WHERE IFNUM = LS_IFTAB-IFNUM
              AND SORT_SEQ = LS_IFTAB-SORT_SEQ.

            IF SY-SUBRC = 0.
              COMMIT WORK.
              APPEND LS_IFTAB TO LT_IFTAB.
            ELSE.
              ROLLBACK WORK.
            ENDIF.


          ENDIF.

          MODIFY GT_OUT INDEX SY-TABIX.

        ENDIF.

        CLEAR : LV_ZAUMA, LV_CHARG, LS_IFTAB.

** 기존 로직 주석 처리
*          SELECT SINGLE ZAUMA CHARG
*            INTO (LV_ZAUMA, LV_CHARG)
*            FROM ZPPTIF68
*            WHERE MBLNR = GT_OUT-MBLNR
*              AND MATNR = LV_MATNR
*              AND WERKS = GT_OUT-WERKS
*              AND UMWRK = GT_OUT-WERKS
*              AND LGORT = '2140'
*              AND UMLGO = '2142'
*              AND BWART = '311'
*              AND ZAUMA = 'D'
*              AND ZERET = '00'.
*
*          IF SY-SUBRC = 0.
*            CLEAR LV_SM03-TAGNR.
**            CONCATENATE '도킹번호 :' LV_CHARG INTO LV_SM03-TAGNR
*            CONCATENATE '  ' LV_CHARG INTO LV_SM03-TAGNR
*            SEPARATED BY SPACE.
*          ENDIF.
*
*          CLEAR : LV_ZAUMA, LV_CHARG.
*        ENDIF.
*]-SRM2208-01973_E
*]-SRM2303-10895_E

      ENDIF.

      APPEND LV_SM03. CLEAR LV_SM03.

    ENDLOOP.


*-[SRM2303-10895_S
* 미리 보기 시, 앞에서 저장한 DB 데이터는 삭제 처리
    IF SY-UCOMM = 'LV_PR' AND LT_IFTAB[] IS NOT INITIAL.

      LOOP AT LT_IFTAB.

        UPDATE ZPPTIF68 SET ZLE_USE = ' '
                      WHERE MATNR = LT_IFTAB-MATNR
                        AND CHARG = LT_IFTAB-CHARG
                        AND ZLE_USE = 'X'.

        IF SY-SUBRC = 0.
          COMMIT WORK.
        ELSE.
          ROLLBACK WORK.
        ENDIF.

      ENDLOOP.

    ENDIF.
*]-SRM2303-10895_E

  ENDIF.

  DESCRIBE TABLE LV_SM03 LINES LV_CT.

  MOK = LV_CT DIV 10.
  NAM = LV_CT MOD 10.
  IF NOT NAM IS INITIAL.
    LV_SM01-TOTNT = MOK + 1.
  ELSE.
    LV_SM01-TOTNT = MOK.
  ENDIF.
  CONDENSE LV_SM01-TOTNT.


  MODIFY LV_SM01 INDEX 1 TRANSPORTING TOTNT.

ENDFORM.                    " SM_DETAIL
*&---------------------------------------------------------------------*
*&      Form  SMART_FORM_SETTING
*&---------------------------------------------------------------------*
FORM SMART_FORM_SETTING .
  DATA: RTAB  LIKE KUNNR_RAN  OCCURS 0 WITH HEADER LINE.
  DATA: SSFCRESPD TYPE SSFCRESPD,
            SSFCRESCL  TYPE SSFCRESCL,
            SSFCRESOP  TYPE SSFCRESOP.

*  IF GV_BUKRS = '3000'.
*    IF R2 = 'X'.
*      CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
*        EXPORTING
*          FORMNAME           = 'ZM_MM_TRADE_DOCUMENT1'
*        IMPORTING
*          FM_NAME            = FUNC_NAME
*        EXCEPTIONS
*          NO_FORM            = 1
*          NO_FUNCTION_MODULE = 2
*          OTHERS             = 3.
*    ELSE.
*      CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
*        EXPORTING
*          FORMNAME           = 'ZM_MM_TRADE_DOCUMENT'
*        IMPORTING
*          FM_NAME            = FUNC_NAME
*        EXCEPTIONS
*          NO_FORM            = 1
*          NO_FUNCTION_MODULE = 2
*          OTHERS             = 3.
*    ENDIF.
*
*  ELSE.
    IF R2 = 'X'.
      CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
        EXPORTING                "'Z_MM_TRADE_DOCUMENT1'
          FORMNAME           = 'ZM_MM_GO_TRADE_DOCUMENT1'
        IMPORTING
          FM_NAME            = FUNC_NAME
        EXCEPTIONS
          NO_FORM            = 1
          NO_FUNCTION_MODULE = 2
          OTHERS             = 3.

    ELSE.
      CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
        EXPORTING              "'Z_MM_TRADE_DOCUMENT1'
          FORMNAME         = 'ZM_MM_GO_TRADE_DOCUMENT'
        IMPORTING
          FM_NAME            = FUNC_NAME
        EXCEPTIONS
          NO_FORM            = 1
          NO_FUNCTION_MODULE = 2
          OTHERS             = 3.
    ENDIF.
*  ENDIF.

  CONTROL_PARAMETERS-GETOTF = 'X'.
  CONTROL_PARAMETERS-NO_DIALOG = 'X'.
** control_parameters-no_close = 'X'.
** control_parameters-getotf = 'X'.
*  CONTROL_PARAMETERS-PREVIEW = 'X'.
*  OUTPUT_OPTIONS-TDDEST = 'ZP01'.
** OUTPUT_OPTIONS-TDPRINTER = 'ZP01'.
*
*  OUTPUT_OPTIONS-TDIMMED = 'X'.
*  OUTPUT_OPTIONS-TDDELETE = 'X'.

  CLEAR SSFCRESCL.
  CALL FUNCTION FUNC_NAME
    EXPORTING
      CONTROL_PARAMETERS   = CONTROL_PARAMETERS
      OUTPUT_OPTIONS       = OUTPUT_OPTIONS
      USER_SETTINGS        = ' '
*      lv_sum               = lv_sum
*      lv_sum_lfimg         = lv_sum_lfimg
*      lv_unit              = lv_unit
      LV_SM01              = LV_SM01
      LV_SM02              = LV_SM02
    IMPORTING
      DOCUMENT_OUTPUT_INFO = SSFCRESPD
      JOB_OUTPUT_INFO      = SSFCRESCL
      JOB_OUTPUT_OPTIONS   = SSFCRESOP
    TABLES
      LV_SM03              = LV_SM03
      LV_SM04              = LV_SM04
    EXCEPTIONS
      FORMATTING_ERROR     = 1
      INTERNAL_ERROR       = 2
      SEND_ERROR           = 3
      USER_CANCELED        = 4
      OTHERS               = 5.

  IF SY-SUBRC <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

  INSERT LINES OF SSFCRESCL-OTFDATA INTO TABLE OTF.

ENDFORM.                    " SMART_FORM_SETTING
*&---------------------------------------------------------------------*
*&      Form  SMART_FORM_FINALL_WRITE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SMART_FORM_FINALL_WRITE .
  DATA: SSFPP TYPE SSFPP,
        ARC_PARAMS TYPE ARC_PARAMS,
        SPOOL_JOB_ATTRIBUTES LIKE RSPOATTR OCCURS 0 WITH HEADER LINE.

  SSFPP-TDDEVICE        = 'PRINTER'.
  SSFPP-TDPREVIEW       = 'X'.
  SSFPP-TDPAGEFORM      = 'DINA4'.
  SSFPP-TDPAGES         = '00002'.
  SSFPP-TDDRIVER        = 'SWIN'.
  SSFPP-TDOTFTYPE       = 'OTFSWIN'.
  SSFPP-TDFORMS         = '00001'.
  SSFPP-TDPROGRAM       = 'SAPLSTXBE'.
  IF SY-UCOMM = 'LV_PR'.                 "미리보기
    SSFPP-TDNOPRINT       = 'X'.
    CLEAR: SSFPP-TDSCREEN, SSFPP-TDSCDRIVER.
  ELSE.                                  "출력
    SSFPP-TDSCREEN          = 'WN32'.
    SSFPP-TDSCDRIVER        = 'WN32'.
    CLEAR: SSFPP-TDNOPRINT.
  ENDIF.
  SSFPP-TDARMOD         = '1'.
  SSFPP-TDDATASET       = 'SMART'.
  SSFPP-TDSUFFIX1       = 'ZP01'.
  SSFPP-TDSUFFIX2       = SY-UNAME.
  SSFPP-TDDEST          = 'ZP01'.
  SSFPP-TDPRINTER       = 'KPSAPWIN'.
  SSFPP-TDIMMED         = 'X'.
  SSFPP-TDDELETE        = 'X'.
  SSFPP-TDLIFETIME      = '8'.
  IF LV_PCUN = 0.
    SSFPP-TDCOPIES      = '001'.
  ELSEIF LV_PCUN = 999.
    SSFPP-TDCOPIES      = '000'.
    SSFPP-TDIMMED         = ''.
    SSFPP-TDDELETE        = ''.
  ELSE.
    SSFPP-TDCOPIES      = LV_PCUN.
  ENDIF.

  SPOOL_JOB_ATTRIBUTES-PARAM    = 'S_COPYMETH'.
  SPOOL_JOB_ATTRIBUTES-VALUE    = 'COLLATE'.
  APPEND SPOOL_JOB_ATTRIBUTES.

  IF SY-UCOMM = 'LV_PR'.
*   미리보기 Function
    CALL FUNCTION 'SSFDISPLAY_OTF'
      EXPORTING
        DISPLAY_PARAMETERS = SSFPP
        ARCHIVE_PARAMS     = ARC_PARAMS
        SPOOLATTR          = SPOOL_JOB_ATTRIBUTES[]
      IMPORTING
        RESULT             = SSFPP
      TABLES
        OTF                = OTF
      EXCEPTIONS
        ERROR              = 1.

  ELSE.
*   출력 Function
    CALL FUNCTION 'SSFCOMP_OTF_OUTPUT'
      EXPORTING
        INPUT_PARAMS   = SSFPP
        ARCHIVE_PARAMS = ARC_PARAMS
        OTF_DATA       = OTF[]
        BMNOPRI        = ''
      IMPORTING
        OUTPUT_PARAMS  = SSFPP
      EXCEPTIONS
        EMPTY_OTF      = 1.

    IF SY-SUBRC = 0.
*     출력성공 시 DB에 저장
      LOOP AT IZGTMMT4500.
        MOVE-CORRESPONDING IZGTMMT4500 TO ZGTMMT4500.
        INSERT ZGTMMT4500. CLEAR ZGTMMT4500.
      ENDLOOP.

      LOOP AT IZGTMMT4501.
        MOVE-CORRESPONDING IZGTMMT4501 TO ZGTMMT4501.
        INSERT ZGTMMT4501. CLEAR ZGTMMT4501.
      ENDLOOP.

      COMMIT WORK.
      MESSAGE S005(ZLE1) WITH LV_IVNO '-> 거래명세서 발행되었습니다'(M01).

    ELSE.
      MESSAGE I005(ZLE1) WITH '거래명세서 발행 실패. 다시 시도하세요!'(E01).
    ENDIF.
  ENDIF.
ENDFORM.                    " SMART_FORM_FINALL_WRITE
*&---------------------------------------------------------------------*
*&      Form  SMART_FORM_PRINT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SMART_FORM_PRINT .

  CLEAR: LV_MBLNR, LV_ZEILE, LV_LIFNR, LV_IVTYP, LV_WERKS, LV_LIFNR,
              LV_BWART, LV_KUNNR.
  REFRESH: LV_SM01, LV_SM02, LV_SM03, OTF.
  CLEAR: LV_SM01, LV_SM02, LV_SM03, OTF, LV_CT.

  LOOP AT GT_OUT WHERE CHK = 'X'.
    LV_CT = LV_CT + 1.
    LV_MBLNR = GT_OUT-MBLNR.
    LV_ZEILE = GT_OUT-ZEILE.
    LV_LIFNR = GT_OUT-LIFNR.
    LV_IVTYP = GT_OUT-IVTYP.
    LV_WERKS = GT_OUT-WERKS.
    LV_LIFNR = GT_OUT-LIFNR.
    LV_KUNNR = GT_OUT-KUNNR.
    LV_BWART = GT_OUT-BWART.
    GV_BUKRS = GT_OUT-BUKRS.
  ENDLOOP.

  IF LV_CT = 0.
    MESSAGE S005(ZLE1) WITH 'DATA를 선택하세요'(M02).
    EXIT.
  ENDIF.
*-{기능개선 48104 - 추가
  PERFORM DRIVER_CHK.
*-}기능개선 48104_2014.10.16
*
  PERFORM POP_UP_CONFIRM(ZLER0004) USING '< 통문증 발행여부확인 >'(M03)
                                                                          '발행하시겠습니까?'(M04)
                                                                CHANGING LV_RETURN.
  CHECK LV_RETURN = 'J'.
  CLEAR LV_RETURN.
**가온전선_R3(PP)미사용으로 주석_(ZGODEV04_260106)
*->시작
*  IF R3 = 'X'.
*    PERFORM INVOICE_NO_CREATE USING 'ZLE001' '07'
*                           CHANGING LV_IVNO.
*  ELSE.
    PERFORM INVOICE_NO_CREATE USING 'ZLE001' '06'
                                                     CHANGING LV_IVNO.
*  ENDIF.
*<-끝.

  IF LV_IVNO = ' '.
    MESSAGE I005(ZLE1) WITH '통문번호 생성 실패!'(E02).
    LEAVE TO SCREEN 0.
  ENDIF.
* iZGTMMT4500
  PERFORM SM_IZGTMMT4500_APPEND USING LV_IVNO  LV_BWART LV_WERKS
                                                                      LV_LIFNR LV_IVTYP.
* iZGTMMT4501
  PERFORM SM_IZGTMMT4501_APPEND USING LV_IVNO.
* 통문증 Header
  PERFORM SM_HEADER USING LV_IVNO LV_MBLNR LV_IVTYP LV_LIFNR
                                               LV_WERKS  LV_UMWRK LV_KUNNR LV_MJAHR.
* 통문증 Middle
  PERFORM SM_MIDDLE.

* 통문증 Detail
  PERFORM SM_DETAIL.

* smart forms
  PERFORM SMART_FORM_SETTING.
* print
  PERFORM SMART_FORM_FINALL_WRITE.
  CLEAR: TEMP_MBLNR, TEMP_LIFNR, TEMP_IVTYP.

ENDFORM.                    " SMART_FORM_PRINT
*&---------------------------------------------------------------------*
*&      Form  SM_IZGTMMT4500_APPEND
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SM_IZGTMMT4500_APPEND USING P_IV_NO P_BWART P_WERKS P_LIFNR P_TYPE.

  REFRESH: IZGTMMT4500. CLEAR: IZGTMMT4500.
  IZGTMMT4500-IV_NO          =  P_IV_NO.
  IZGTMMT4500-BZAREA         = P_BZAREA.
  IZGTMMT4500-IV_DATE        =  SY-DATUM.
  IZGTMMT4500-IV_PRINT_YN    = 'X'.
  IZGTMMT4500-PRINT_CNT      = 1.
  IZGTMMT4500-DRIVER_NM      = LV_DRNAM.
  IZGTMMT4500-DRIVER_TELNO   = LV_DRTEL.
  IZGTMMT4500-TRUCK_NO       = LV_TRUNO.
  IZGTMMT4500-ETC_NM         = LV_LTEXT.
  IZGTMMT4500-TON_NO         = LV_TONNO.
  IZGTMMT4500-CREATE_USER_ID = SY-UNAME.
  IZGTMMT4500-CREATE_DATE    = SY-DATUM.
  IZGTMMT4500-CREATE_TIME    = SY-UZEIT.
  IZGTMMT4500-IV_TYPE        = P_TYPE.
  IZGTMMT4500-BWART          = P_BWART.
  IZGTMMT4500-WERKS          = P_WERKS.
  IZGTMMT4500-KUNNR          = P_LIFNR.
  IZGTMMT4500-REQNO          = GV_REQNO.       "기능개선 214781 - 추가
*{CHM2008-00227 - S
  IZGTMMT4500-PERNR          = LV_PERNR.
  IZGTMMT4500-ENAME          = LV_ENAME.
*  }CHM2008-00227 - E
  APPEND IZGTMMT4500.  CLEAR IZGTMMT4500.

ENDFORM.                    " SM_IZGTMMT4500_APPEND
*&---------------------------------------------------------------------*
*&      Form  SM_IZGTMMT4501_APPEND
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SM_IZGTMMT4501_APPEND USING P_IVNO.

  REFRESH: IZGTMMT4501. CLEAR: IZGTMMT4501, SEQ.
  LOOP AT GT_OUT WHERE CHK = 'X'.
    SEQ = SEQ + 1.
    IZGTMMT4501-IV_NO      = P_IVNO.
    IZGTMMT4501-IV_SEQ     = SEQ.
    IZGTMMT4501-MBLNR      = GT_OUT-MBLNR.
    IZGTMMT4501-ZEILE      = GT_OUT-ZEILE.
    IZGTMMT4501-MATNR      = GT_OUT-MATNR.
    IZGTMMT4501-LFIMG      = GT_OUT-MENGE.
    IZGTMMT4501-MTR_UNIT   = GT_OUT-MEINS.
    IZGTMMT4501-MJAHR      = GT_OUT-MJAHR.
    IZGTMMT4501-MAKTX      = GT_OUT-MAKTX.
    IZGTMMT4501-CHARG      = GT_OUT-CHARG.          "SDC08 추가
    IZGTMMT4501-DOCKING_NO = GT_OUT-DOCKING_NO.     "SRM2303-10895 추가
    APPEND IZGTMMT4501.    CLEAR IZGTMMT4501.
  ENDLOOP.

ENDFORM.                    " SM_IZGTMMT4501_APPEND
*&---------------------------------------------------------------------*
*&      Form  SM_MIDDLE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SM_MIDDLE .

  REFRESH: LV_SM02.  CLEAR LV_SM02.
  LV_SM02-EXTI1 = LV_TRUNO.
  IF LV_DRNAM <> ' ' AND LV_DRTEL <> ' '.
    CONCATENATE LV_DRNAM '(' LV_DRTEL ')' INTO LV_SM02-EXTI2
                SEPARATED BY SPACE.
  ELSEIF LV_DRNAM <> ' ' AND LV_DRTEL = ' '.
    LV_SM02-EXTI2 = LV_DRNAM.
  ELSEIF LV_DRNAM = ' ' AND LV_DRTEL <> ' '.
    CONCATENATE '(' LV_DRTEL ')' INTO LV_SM02-EXTI2
                SEPARATED BY SPACE.
  ENDIF.

*{CHM2008-00227 - S
  IF LV_PERNR IS NOT INITIAL.
    LV_SM02-PERNR = LV_PERNR.
    LV_SM02-PERNM = LV_ENAME.
  ENDIF.
*}CHM2008-00227 - E

  IF LV_TONNO = ' '.
    LV_SM02-LTEXT = LV_LTEXT.
  ELSE.
    CONCATENATE LV_TONNO '/' LV_LTEXT INTO LV_SM02-LTEXT.
  ENDIF.

  APPEND LV_SM02.

* 20061201 Bon-Chan Koo 수정 특기사항에 정보추가(서비스오더번호,실행일)
* Y91(CS오더에 의한 출고)이동유형 일 경우 서비스관련 정보를 추가

  DATA : LV_AUFNR  LIKE MSEG-AUFNR,
         LV_AUFNR1 LIKE MSEG-AUFNR,
         LV_GLTRS  LIKE AFKO-GLTRS,
         LV_AUFPL  LIKE AFKO-AUFPL.
*         LV_PERNR  LIKE AFVC-PERNR,
*         LV_ENAME  LIKE ZZPA0001-ENAME.
  CLEAR : LV_PERNR, LV_ENAME.

  REFRESH LV_SM04. CLEAR LV_SM04.

  IF LV_IVTYP = 'B11'.

    SELECT SINGLE AUFNR
    INTO   LV_AUFNR
    FROM   MSEG
    WHERE  MBLNR = LV_MBLNR.

    LV_AUFNR1 = LV_AUFNR.
    SHIFT  LV_AUFNR1  LEFT  DELETING  LEADING  '0'.

    IF SY-SUBRC = 0.

      SELECT SINGLE GLTRS AUFPL
      INTO   (LV_GLTRS, LV_AUFPL)
      FROM   AFKO
      WHERE  AUFNR = LV_AUFNR.

      IF SY-SUBRC = 0.

        SELECT SINGLE PERNR
        INTO   LV_PERNR
        FROM   AFVC
        WHERE  AUFPL = LV_AUFPL.

        IF SY-SUBRC = 0.
          SELECT SINGLE ENAME
          INTO   LV_ENAME
          FROM   ZZPA0001
          WHERE  PERNR = LV_PERNR
          AND    BEGDA <= SY-DATUM
          AND    ENDDA >= SY-DATUM.
        ENDIF.

      ENDIF.

      CONCATENATE 'SVC오더: ' LV_AUFNR1
                  '('  LV_ENAME   ')'
             INTO LV_SM04-LTEXT.

      CONCATENATE LV_SM04-LTEXT
                  ' 실행일:' LV_GLTRS
             INTO LV_SM04-LTEXT.

      APPEND LV_SM04.
    ENDIF.

  ENDIF.
* 20061201 수정완료

ENDFORM.                    " SM_MIDDLE
*&---------------------------------------------------------------------*
*&      Form  PP_GET_DATA
*&---------------------------------------------------------------------*
FORM PP_GET_DATA .
  DATA: LV_WERKS    LIKE T001W-WERKS.


** 통문유형 Setting
*  REFRESH i_ivtyp.  CLEAR i_ivtyp.
*  IF p_gubun1 = '2'.
*    PERFORM iv_type_setting USING 'I' 'EQ' '541'.
*  ELSEIF p_gubun1 = '3'.
*    PERFORM iv_type_setting USING 'I' 'EQ' '122'.
*  ELSEIF p_gubun1 = '4'.
*    PERFORM iv_type_setting USING 'I' 'EQ' '161'.
*  ELSEIF p_gubun1 = '5'.
*    PERFORM iv_type_setting USING 'I' 'EQ' '351'.
*  ELSE.
*    PERFORM iv_type_setting USING 'I' 'EQ' '541'.
*    PERFORM iv_type_setting USING 'I' 'EQ' '122'.
*    PERFORM iv_type_setting USING 'I' 'EQ' '161'.
*    PERFORM iv_type_setting USING 'I' 'EQ' '351'.
*  ENDIF.

*/ 사업장
  CLEAR: R_WERKS[], R_WERKS.
  SELECT W~WERKS
    FROM T001K AS K
         INNER JOIN T001W    AS W ON W~BWKEY = K~BWKEY
         INNER JOIN ZLET0034 AS Z ON Z~WERKS = W~WERKS
    INTO LV_WERKS
    WHERE K~BUKRS  = P_BUKRS
      AND Z~BZAREA = P_BZAREA.

    SET_RANGES: R_WERKS 'I' 'EQ' LV_WERKS ' '.

  ENDSELECT.
  IF SY-SUBRC <> 0.
    SELECT * FROM ZLET0034 WHERE BZAREA = P_BZAREA.

      SET_RANGES: R_WERKS 'I' 'EQ' ZLET0034-WERKS ' '.

    ENDSELECT.
  ENDIF.


*{S SRM2209-05218 26.09.2022 14:03:14
  SELECT W~WERKS
    FROM T001K AS K
         INNER JOIN T001W    AS W ON W~BWKEY = K~BWKEY
         INNER JOIN ZLET0071 AS Z ON Z~WERKS = W~WERKS
    INTO LV_WERKS
    WHERE K~BUKRS  = P_BUKRS
      AND Z~BZAREA = P_BZAREA.

    SET_RANGES: R_WERKS 'I' 'EQ' LV_WERKS ' '.
  ENDSELECT.
*}E SRM2209-05218



*/ 이동유형
  REFRESH I_IVTYP.  CLEAR I_IVTYP.
*  IF P_GUBUN1 = '1'.                        "기능개선 249949 - 삭제
  DATA : LR_BWART TYPE RANGE OF BWART.

  IF P_GUBUN1 = '999'.                       "기능개선 249949 - 추가


    SELECT 'I' AS SIGN ,  'EQ' AS OPTION , BWART AS LOW FROM ZGTMMT4511
      WHERE IV_TYPE LIKE 'B__'
                             AND MDULE   = 'MMPP'
      INTO TABLE @LR_BWART.

*     SET_RANGES: I_IVTYP 'I' 'EQ' ZGTMMT4511-BWART ' '.

*    ENDSELECT.
  ELSE.
*    LOOP AT LT_VALUES WHERE KEY = P_GUBUN1.
*      SELECT SINGLE * FROM ZGTMMT4511
*        WHERE IV_TYPE = LT_VALUES-TEXT+0(3).
*
*      IF SY-SUBRC = 0.
*        SET_RANGES: I_IVTYP 'I' 'EQ' ZGTMMT4511-BWART ' '.
*      ENDIF.
*    ENDLOOP.
    SELECT 'I' AS SIGN ,  'EQ' AS OPTION , BWART AS LOW FROM ZGTMMT4511
      WHERE IV_TYPE = @LT_VALUES-TEXT+0(3)
      INTO TABLE @LR_BWART.
  ENDIF.

* MM기준 통문증 발행 대상 DATA를 발췌한다.
  REFRESH: GT_TAB, GT_OUT.  CLEAR: GT_TAB, GT_OUT.
  SELECT B~CPUDT, B~MBLNR, B~ZEILE, B~LIFNR, B~MATNR,
         B~ERFME AS MEINS,
         B~ERFMG AS MENGE,
         B~BSTME,
         B~BSTMG,
         B~BWART, B~MJAHR, B~WERKS,
         B~UMWRK, B~SHKZG, B~LGORT, B~CHARG,
         B~EBELN
         INTO CORRESPONDING FIELDS OF TABLE @GT_TAB
*         FROM mkpf AS a INNER JOIN mseg AS b
*           ON a~mblnr EQ b~mblnr AND
*              a~mjahr EQ b~mjahr
         FROM MATDOC AS B
        WHERE B~XAUTO = ' '
          AND B~BUKRS =  @P_BUKRS
          AND B~BWART IN @LR_BWART
          AND B~MBLNR IN @I_MBLNR
          AND B~CPUDT IN @I_CPUDT
          AND B~WERKS = @P_WERKS
          AND B~LIFNR IN @I_LIFNR.

*{ SRM2401-14519 - 추가_S
*___ZPPT0019 테이블의 데이터와 비교하기 위해 임시 Internal Table에
*   자재문서/자재/배치/수량/사용여부를 저장
  CLEAR   : GT_MDOC.
  REFRESH : GT_MDOC.

  LOOP AT GT_TAB.
    CLEAR : GT_MDOC.

    MOVE-CORRESPONDING GT_TAB TO GT_MDOC.

    APPEND GT_MDOC.
  ENDLOOP.

  SORT GT_MDOC BY MBLNR MATNR CHARG MENGE ZEILE.
*} SRM2401-14519 - 추가_E

*/ 2005.07.01 BY SDC08 - PP 김주원 C 요청
  LOOP AT GT_TAB.
    CLEAR: MARC.
    SELECT SINGLE DISPO INTO MARC-DISPO FROM MARC
                       WHERE MATNR = GT_TAB-MATNR
                         AND WERKS = GT_TAB-WERKS.
*   이동유형이 MM과 동일하므로 PP Table에 존재하는 Data만 발췌
    CLEAR: ZPPT0112.
    SELECT SINGLE * FROM ZPPT0112 WHERE WERKS = GT_TAB-WERKS
                                    AND DISPO = MARC-DISPO
                                    AND LGORT = GT_TAB-LGORT.
    CHECK SY-SUBRC = 0.

*   자재문서 취소시 DATA 삭제
    SELECT SINGLE * FROM MSEG WHERE SMBLN = GT_TAB-MBLNR
                                AND SJAHR = GT_TAB-MJAHR
                                AND SMBLP = GT_TAB-ZEILE.
    CHECK SY-SUBRC <> 0.
    CHECK GT_TAB-SHKZG = 'H'.

*   통문 Detail 에 존재
    CLEAR: ZGTMMT4501, ZGTMMT4500, T_LFIMG.
    SELECT * FROM ZGTMMT4501 WHERE MBLNR = GT_TAB-MBLNR
                             AND ZEILE = GT_TAB-ZEILE
                             AND MJAHR = GT_TAB-MJAHR.
*     통문증 Header에 삭제 Flag가 찍힌 Data는 통문증을 다시 재발행
      SELECT SINGLE * FROM ZGTMMT4500 WHERE IV_NO = ZGTMMT4501-IV_NO
                                      AND IV_CANCEL_YN <> 'X'.
      IF SY-SUBRC = 0.
        T_LFIMG = T_LFIMG + ZGTMMT4501-LFIMG.
      ENDIF.
    ENDSELECT.
    CHECK T_LFIMG < GT_TAB-MENGE.

    IF GT_TAB-BWART = '351'.
      SELECT SINGLE NAME1 INTO GT_TAB-NAME1 FROM T001W
                         WHERE WERKS = GT_TAB-UMWRK.

      GT_TAB-LIFNR1 = GT_TAB-UMWRK.
    ELSE.
      SELECT SINGLE NAME1 INTO GT_TAB-NAME1 FROM LFA1
                         WHERE LIFNR = GT_TAB-LIFNR.

      GT_TAB-LIFNR1 = GT_TAB-LIFNR.
    ENDIF.

    IF GT_TAB-BWART = '122'.
      IF NOT GT_TAB-BSTMG IS INITIAL.
        GT_TAB-MENGE = GT_TAB-BSTMG.
        GT_TAB-MEINS = GT_TAB-BSTME.
      ENDIF.
    ENDIF.

    IF MARC-DISPO+0(2) = 'CN' OR MARC-DISPO+0(2) = 'IR' OR
       MARC-DISPO+0(2) = 'LF' OR MARC-DISPO+0(2) = 'PS' OR
       MARC-DISPO+0(2) = 'BD' OR MARC-DISPO+0(2) = 'CF' OR
       MARC-DISPO+0(2) = 'HS' OR MARC-DISPO+0(2) = 'AL' OR
       MARC-DISPO+0(2) = 'PA' OR MARC-DISPO+0(2) = 'AP' OR "부품산업
       GT_TAB-BWART = '122'.

      MOVE-CORRESPONDING GT_TAB TO GT_OUT.
*      gt_out-tagnr = zppt0019-tagnr.
*      gt_out-ebeln = zppt0019-ebeln.
      SELECT SINGLE IV_TYPE_NM IV_TYPE
        INTO (GT_OUT-BWTXT, GT_OUT-IVTYP)
        FROM ZGTMMT4511
       WHERE BWART = GT_TAB-BWART.

*   자재 품명:규격
      SELECT SINGLE MAKTX INTO GT_OUT-MAKTX FROM MAKT
                         WHERE MATNR EQ GT_TAB-MATNR
                           AND SPRAS EQ '3'.
*    SELECT SINGLE name1 INTO gt_out-name1 FROM lfa1
*                       WHERE lifnr = gt_out-lifnr.
      APPEND GT_OUT.  CLEAR GT_OUT.

    ELSE.
*   PP 꼬리표/구매오더 가져오는 로직
      IF GT_TAB-BWART = '351'.
        PERFORM GET_DATA_PP_351.
      ELSE.
        PERFORM GET_DATA_PP_ETC.
      ENDIF.
    ENDIF.
  ENDLOOP.
*
  DESCRIBE TABLE GT_OUT LINES SY-TFILL.
  IF SY-TFILL = 0.
    MESSAGE S005(ZLE1) WITH '조건에 맞는 DATA가 없습니다'.
    IF SY-DYNNR = '1000'.
      STOP.
    ELSE.
      LEAVE TO SCREEN 0.
    ENDIF.
  ENDIF.
  SORT GT_OUT BY IVTYP MBLNR ZEILE.
  DESCRIBE TABLE GT_OUT LINES TC01-LINES.


*{S SRM2209-05218 26.09.2022 14:26:11
  IF P_BUKRS = '3000'.
    SELECT SINGLE MANDT
      INTO SY-MANDT
      FROM ZLET0071
      WHERE BZAREA = P_BZAREA.
    IF SY-SUBRC = 0 .
      SELECT *
        FROM ZLET0071 .
        SET_RANGES: R_WERKS1 'I' 'EQ' ZLET0071-WERKS ' '.
        SET_RANGES: R_LGORT1 'I' 'EQ' ZLET0071-LGORT ' '.
      ENDSELECT.

      DELETE GT_OUT WHERE WERKS NOT IN R_WERKS1.
      DELETE GT_OUT WHERE LGORT NOT IN R_LGORT1.
    ELSE.
      SELECT *
        FROM ZLET0071 .
        DELETE GT_OUT WHERE WERKS = ZLET0071-WERKS
                                AND     LGORT  = ZLET0071-LGORT.
      ENDSELECT.
    ENDIF.
  ENDIF.
*}E SRM2209-05218



***********************************************************
*  LOOP AT gt_tab.
*    CLEAR: marc.
*    SELECT SINGLE dispo INTO marc-dispo FROM marc
*                       WHERE matnr = gt_tab-matnr
*                         AND werks = gt_tab-werks.
**   이동유형이 MM과 동일하므로 PP Table에 존재하는 Data만 발췌
*    CLEAR: zppt0112.
*    SELECT SINGLE * FROM zppt0112 WHERE werks = gt_tab-werks
*                                    AND dispo = marc-dispo
*                                    AND lgort = gt_tab-lgort.
*    CHECK sy-subrc = 0.
**   PP 꼬리표/구매오더 가져오는 로직
*    IF gt_tab-bwart = '351'.
*      CLEAR zppt0019.
*      SELECT SINGLE * FROM zppt0019 WHERE mblnr = gt_tab-mblnr
*                                      AND EBELN = GT_TAB-EBELN.
*    ELSE.
*      CLEAR zppt0018.
*      SELECT SINGLE * FROM zppt0018 WHERE mblnr = gt_tab-mblnr
*                                      AND EBELN = GT_TAB-EBELN.
*    ENDIF.
*    CLEAR mseg.
**   자재문서 취소시 DATA 삭제
*    SELECT SINGLE * FROM mseg WHERE smbln = gt_tab-mblnr
*                                AND sjahr = gt_tab-mjahr
*                                AND smblp = gt_tab-zeile.
*    CHECK sy-subrc <> 0.
*    CHECK gt_tab-shkzg = 'H'.
**   통문 Detail 에 존재
*    CLEAR: ZGTMMT4501, ZGTMMT4500, t_lfimg.
*    SELECT * FROM ZGTMMT4501 WHERE mblnr = gt_tab-mblnr
*                             AND zeile = gt_tab-zeile
*                             AND mjahr = gt_tab-mjahr.
**     통문증 Header에 삭제 Flag가 찍힌 Data는 통문증을 다시 재발행
*      SELECT SINGLE * FROM ZGTMMT4500 WHERE iv_no = ZGTMMT4501-iv_no
*                                      AND iv_cancel_yn <> 'X'.
*      IF sy-subrc = 0.
*        t_lfimg = t_lfimg + ZGTMMT4501-lfimg.
*      ENDIF.
*    ENDSELECT.
*    CHECK t_lfimg < gt_tab-menge.
**
*    MOVE-CORRESPONDING gt_tab TO gt_out.
*    IF p_gubun1 = '4'.
**      gt_out-ebeln = zppt0019-ebeln.
*      gt_out-tagnr = zppt0019-tagnr.
*    ELSE.
**      gt_out-ebeln = zppt0018-ebeln.
*      gt_out-tagnr = zppt0018-tagnr.
*    ENDIF.
*
*    SELECT SINGLE iv_type_nm iv_type
*      INTO (gt_out-bwtxt, gt_out-ivtyp)
*      FROM zlet0007
*     WHERE bwart = gt_tab-bwart.
*
***   통문 유형별 Description
**    IF gt_tab-bwart = '541'.
**      gt_out-bwtxt = '무상사급'.
**      gt_out-ivtyp = 'B01'.
**    ELSEIF gt_tab-bwart = '122'.
**      gt_out-bwtxt = '불량반품'.
**      gt_out-ivtyp = 'B02'.
**    ELSEIF gt_tab-bwart = '161'.
**      gt_out-bwtxt = '반품'.
**      gt_out-ivtyp = 'B03'.
**    ELSEIF gt_tab-bwart = '351'.
**      gt_out-bwtxt = '공장간이체'.
**      gt_out-ivtyp = 'B04'.
**      gt_out-lifnr = gt_tab-umwrk.
**    ENDIF.
**   자재 품명:규격
*    SELECT SINGLE maktx INTO gt_out-maktx FROM makt
*                       WHERE matnr EQ gt_tab-matnr
*                         AND spras EQ '3'.
*    SELECT SINGLE name1 INTO gt_out-name1 FROM lfa1
*                       WHERE lifnr = gt_out-lifnr.
*    APPEND gt_out.  CLEAR gt_out.
*  ENDLOOP.
**
*  DESCRIBE TABLE gt_out LINES sy-tfill.
*  IF sy-tfill = 0.
*    MESSAGE s005(zle1) WITH '조건에 맞는 DATA가 없습니다'.
*    IF sy-dynnr = '1000'.
*      STOP.
*    ELSE.
*      LEAVE TO SCREEN 0.
*    ENDIF.
*  ENDIF.
*  SORT gt_out BY ivtyp mblnr zeile.
*  DESCRIBE TABLE gt_out LINES tc01-lines.
ENDFORM.                    " PP_GET_DATA
*&---------------------------------------------------------------------*
*&      Form  get_vrm_id_values
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LT_VALUES  text
*----------------------------------------------------------------------*
FORM GET_VRM_ID_VALUES  TABLES   T_VALUES TYPE VRM_VALUES
                        USING    P_KEY
                                 P_TEXT.

  T_VALUES-KEY    = P_KEY.
  T_VALUES-TEXT   = P_TEXT.
  APPEND T_VALUES.


ENDFORM.                    " get_vrm_id_values
*&---------------------------------------------------------------------*
*&      Form  value_request_WERKS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_0051   text
*----------------------------------------------------------------------*
FORM VALUE_REQUEST_WERKS  USING    P_XX.

  DATA: BEGIN OF POV_WERKS OCCURS 0,
         WERKS LIKE ZLET0034-WERKS,
         NAME1 LIKE ZLET0034-NAME1,
        END OF POV_WERKS.

  CHECK P_BUKRS IS NOT INITIAL.

  SELECT W~WERKS W~NAME1
    FROM T001K AS K
         INNER JOIN T001W    AS W ON W~BWKEY = K~BWKEY
*가온전선_사업장(P_BZAREA)조회조건 미사용으로 주석_(ZGODEV04_260106)
*         INNER JOIN ZLET0034 AS Z ON Z~WERKS = W~WERKS
    INTO TABLE POV_WERKS
    WHERE K~BUKRS  = P_BUKRS.
*가온전선_조회조건 미사용으로 주석_(ZGODEV04_260106)
*      AND Z~BZAREA = P_BZAREA.

*  SELECT WERKS NAME1
*  INTO   CORRESPONDING FIELDS OF TABLE POV_WERKS
*  FROM   ZLET0034.
**  WHERE  BZAREA = P_BZAREA.
**출하지점
*  .

  SORT POV_WERKS.
  DELETE ADJACENT DUPLICATES FROM POV_WERKS.

  FIELDTAB-TABNAME   = 'T001W'.
  FIELDTAB-FIELDNAME = 'WERKS'.
  FIELDTAB-SELECTFLAG = 'X'.
  APPEND FIELDTAB.

  FIELDTAB-TABNAME   = 'T001W'.
  FIELDTAB-FIELDNAME = 'NAME1'.
  FIELDTAB-SELECTFLAG = ' '.
  APPEND FIELDTAB.

  LOOP AT POV_WERKS.
    VALUETAB-VALUE = POV_WERKS-WERKS.
    APPEND VALUETAB.
    VALUETAB-VALUE = POV_WERKS-NAME1.
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

*  IF J > 0.
*    READ TABLE POV_WERKS INDEX J.
**    VALUE       = pov_WERKS-VSTEL.
*    IF P_XX = '1'.
*      I_WERKS-LOW  = POV_WERKS-WERKS.
*    ELSE.
*      I_WERKS-HIGH = POV_WERKS-NAME1.
*    ENDIF.

*  ENDIF.
  REFRESH : FIELDTAB, VALUETAB, POV_WERKS.
  CLEAR   : J,FIELDTAB, VALUETAB, POV_WERKS.

ENDFORM.                    " value_request_WERKS
*&---------------------------------------------------------------------*
*&      Form  get_data_pp_351
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_DATA_PP_351 .

  SELECT * FROM ZPPT0019 WHERE MBLNR = GT_TAB-MBLNR
                           AND EBELN = GT_TAB-EBELN
                           AND MATNR = GT_TAB-MATNR
                           AND CHARG = GT_TAB-CHARG.
    MOVE-CORRESPONDING GT_TAB TO GT_OUT.
    GT_OUT-TAGNR = ZPPT0019-TAGNR.
    GT_OUT-EBELN = ZPPT0019-EBELN.

*{ SRM2401-14519 - 추가_S
*___자재문서 품목과 수량을 맞추기 위해 임시 Internal Table에서
*   자재문서/자재/배치/수량이 동일한 품목을 찾아 사용여부 표시
    READ TABLE GT_MDOC WITH KEY MBLNR = ZPPT0019-MBLNR
                                MATNR = ZPPT0019-MATNR
                                CHARG = ZPPT0019-CHARG
                                MENGE = ZPPT0019-ENMNG
                                USED  = ' '.
    IF SY-SUBRC <> 0.
      READ TABLE GT_MDOC WITH KEY MBLNR = ZPPT0019-MBLNR
                                  MATNR = ZPPT0019-MATNR
                                  CHARG = ZPPT0019-CHARG
                                  USED  = ' '.
    ENDIF.

    IF SY-SUBRC = 0.
      GT_OUT-ZEILE = GT_MDOC-ZEILE.

      GT_MDOC-USED = 'X'.
      MODIFY GT_MDOC INDEX SY-TABIX.
    ELSE.
      CONTINUE.
    ENDIF.

    IF ZPPT0019-TAGNR IS NOT INITIAL.
      GT_OUT-MENGE = ZPPT0019-ENMNG.    "꼬리표번호가 있는 경우 수량
    ENDIF.
*} SRM2401-14519 - 추가_E

    SELECT SINGLE IV_TYPE_NM IV_TYPE
      INTO (GT_OUT-BWTXT, GT_OUT-IVTYP)
      FROM ZGTMMT4511
     WHERE BWART = GT_TAB-BWART.



*   자재 품명:규격
    SELECT SINGLE MAKTX INTO GT_OUT-MAKTX FROM MAKT
                       WHERE MATNR EQ GT_TAB-MATNR
                         AND SPRAS EQ '3'.
*    SELECT SINGLE name1 INTO gt_out-name1 FROM lfa1
*                       WHERE lifnr = gt_out-lifnr.
    APPEND GT_OUT.  CLEAR GT_OUT.

*-{ 기능개선 57848  -추가
    SORT GT_OUT BY EBELN MATNR CHARG TAGNR .
    DELETE ADJACENT DUPLICATES FROM GT_OUT
    COMPARING MBLNR MATNR CHARG EBELN TAGNR.
*-} 기능개선 57848_2014.12.22

  ENDSELECT .
ENDFORM.                    " get_data_pp_351
*&---------------------------------------------------------------------*
*&      Form  GET_DATA_PP_ETC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_DATA_PP_ETC .

  DATA : LV_CNT TYPE I, LV_INDEX LIKE MATDOC-ZEILE.
  DATA : LT_MATDOC LIKE MATDOC OCCURS 0 WITH HEADER LINE.

  SELECT COUNT( * ) INTO LV_CNT
  FROM   ZPPT0018 WHERE MBLNR = GT_TAB-MBLNR
                    AND MATNR = GT_TAB-MATNR
                    AND CHARG = GT_TAB-CHARG.
  IF LV_CNT < 2.

    SELECT * FROM ZPPT0018 WHERE MBLNR = GT_TAB-MBLNR
*                            AND ebeln = gt_tab-ebeln
                             AND MATNR = GT_TAB-MATNR
                             AND CHARG = GT_TAB-CHARG.
      MOVE-CORRESPONDING GT_TAB TO GT_OUT.
      GT_OUT-TAGNR = ZPPT0018-TAGNR.
      GT_OUT-EBELN = ZPPT0018-EBELN.
      SELECT SINGLE IV_TYPE_NM IV_TYPE
        INTO (GT_OUT-BWTXT, GT_OUT-IVTYP)
        FROM ZGTMMT4511
       WHERE BWART = GT_TAB-BWART.

*     자재 품명:규격
      SELECT SINGLE MAKTX INTO GT_OUT-MAKTX FROM MAKT
                         WHERE MATNR EQ GT_TAB-MATNR
                           AND SPRAS EQ '3'.
*      SELECT SINGLE name1 INTO gt_out-name1 FROM lfa1
*                         WHERE lifnr = gt_out-lifnr.
      APPEND GT_OUT.  CLEAR GT_OUT.

    ENDSELECT .
  ELSE.
    SELECT * FROM MATDOC INTO TABLE LT_MATDOC
    WHERE MBLNR = GT_TAB-MBLNR
*    AND   ZEILE = GT_TAB-ZEILE
    AND   MATNR = GT_TAB-MATNR
    AND   CHARG = GT_TAB-CHARG
    AND   XAUTO = ' '.

    LOOP AT LT_MATDOC.
      LV_INDEX = LV_INDEX + 1.
      IF LT_MATDOC-ZEILE = GT_TAB-ZEILE.
        EXIT.
      ENDIF.
    ENDLOOP.

    SELECT * FROM ZPPT0018 WHERE MBLNR = GT_TAB-MBLNR
                             AND ZEILE = LV_INDEX
                             AND MATNR = GT_TAB-MATNR
                             AND CHARG = GT_TAB-CHARG.
      MOVE-CORRESPONDING GT_TAB TO GT_OUT.
      GT_OUT-TAGNR = ZPPT0018-TAGNR.
      GT_OUT-EBELN = ZPPT0018-EBELN.
      SELECT SINGLE IV_TYPE_NM IV_TYPE
        INTO (GT_OUT-BWTXT, GT_OUT-IVTYP)
        FROM ZGTMMT4511
       WHERE BWART = GT_TAB-BWART.

*     자재 품명:규격
      SELECT SINGLE MAKTX INTO GT_OUT-MAKTX FROM MAKT
                         WHERE MATNR EQ GT_TAB-MATNR
                           AND SPRAS EQ '3'.
      APPEND GT_OUT.  CLEAR GT_OUT.
    ENDSELECT .

  ENDIF.
  CLEAR : LV_CNT, LV_INDEX.
  REFRESH : LT_MATDOC.

*  SELECT * FROM zppt0018 WHERE mblnr = gt_tab-mblnr
**                          AND ebeln = gt_tab-ebeln
*                           AND matnr = gt_tab-matnr
*                           AND charg = gt_tab-charg.
*    MOVE-CORRESPONDING gt_tab TO gt_out.
*    gt_out-tagnr = zppt0018-tagnr.
*    gt_out-ebeln = zppt0018-ebeln.
*    SELECT SINGLE iv_type_nm iv_type
*      INTO (gt_out-bwtxt, gt_out-ivtyp)
*      FROM zlet0007
*     WHERE bwart = gt_tab-bwart.
*
**   자재 품명:규격
*    SELECT SINGLE maktx INTO gt_out-maktx FROM makt
*                       WHERE matnr EQ gt_tab-matnr
*                         AND spras EQ '3'.
**    SELECT SINGLE name1 INTO gt_out-name1 FROM lfa1
**                       WHERE lifnr = gt_out-lifnr.
*    APPEND gt_out.  CLEAR gt_out.
*
*  ENDSELECT .

ENDFORM.                    " GET_DATA_PP_ETC
*&---------------------------------------------------------------------*
*&      Form  value_request_branch
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_0077   text
*----------------------------------------------------------------------*
FORM VALUE_REQUEST_BRANCH  USING    P_BRANCH.
  DATA : BEGIN OF POV_BRANCH OCCURS 0 ,
           BRANCH LIKE  J_1BBRANCH-BRANCH,
           NAME   LIKE  J_1BBRANCH-NAME,
         END OF POV_BRANCH.

  CHECK P_BUKRS IS NOT INITIAL.

  SELECT A~BRANCH
         B~NAME
    INTO (POV_BRANCH-BRANCH , POV_BRANCH-NAME)
    FROM J_1BBRANCH AS A
   INNER JOIN J_1BBRANCHT AS B
      ON A~BUKRS      = B~BUKRS
     AND A~BRANCH     = B~BRANCH
     AND A~BUPLA_TYPE = B~BUPLA_TYPE
   WHERE A~BUKRS      = P_BUKRS
     AND B~LANGUAGE   = SY-LANGU.
*사업장
    APPEND POV_BRANCH.
  ENDSELECT.

  SORT POV_BRANCH.

  FIELDTAB-TABNAME   = 'J_1BBRANCH'.
  FIELDTAB-FIELDNAME = 'BRANCH'.
  FIELDTAB-SELECTFLAG = 'X'.
  APPEND FIELDTAB.

  FIELDTAB-TABNAME   = 'J_1BBRANCH'.
  FIELDTAB-FIELDNAME = 'NAME'.
  FIELDTAB-SELECTFLAG = ' '.
  APPEND FIELDTAB.

  LOOP AT POV_BRANCH.
    VALUETAB-VALUE = POV_BRANCH-BRANCH.
    APPEND VALUETAB.
    VALUETAB-VALUE = POV_BRANCH-NAME.
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

*  IF J > 0.
*    READ TABLE POV_BRANCH INDEX J.
**    VALUE       = pov_WERKS-VSTEL.
*    IF P_BRANCH = '1'.
*      I_BRANCH-LOW  = POV_BRANCH-BRANCH.
*    ELSE.
*      I_BRANCH-HIGH = POV_BRANCH-NAME.
*    ENDIF.
*
*  ENDIF.
  REFRESH : FIELDTAB, VALUETAB, POV_BRANCH.
  CLEAR   : J,FIELDTAB, VALUETAB, POV_BRANCH.

ENDFORM.                    " value_request_branch
*&---------------------------------------------------------------------*
*&      Form  costomer_info
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_0115   text
*      -->P_0116   text
*      -->P_0117   text
*----------------------------------------------------------------------*
FORM COSTOMER_INFO  USING    P_LIFNR
                             P_KUNNR
                             P_UMWRK.

  IF P_LIFNR IS INITIAL.
    GT_OUT-LIFNR = ' '.
  ENDIF.

  IF P_KUNNR IS INITIAL.
    GT_OUT-KUNNR = ' '.
  ENDIF.

  IF P_UMWRK IS INITIAL.
    GT_OUT-UMWRK = ' '.
  ENDIF.


ENDFORM.                    " costomer_info
*&---------------------------------------------------------------------*
*&      Form  SM_IVTYPE_CHECK
*&---------------------------------------------------------------------*
*       SM이동유형에 대한 통문여부를 CHECK함.
*       ZLET0009 TABLE에 등록된 이동유형, 플랜트,저장위치만 통문대상.
*----------------------------------------------------------------------*
FORM SM_IVTYPE_CHECK  USING    P_LV_IVTYP
                      CHANGING P_LV_FLAG.

  DATA: LV_ZUSE_YN.
  CLEAR: LV_ZUSE_YN.
  SELECT SINGLE ZUSE_YN INTO LV_ZUSE_YN FROM ZLET0009
                                  WHERE IV_TYPE LIKE P_LV_IVTYP
                                    AND WERKS   = GT_TAB-WERKS
                                    AND LGORT   = GT_TAB-LGORT.
  IF SY-SUBRC = 0 AND LV_ZUSE_YN = 'Y'.
  ELSE.
    SELECT SINGLE ZUSE_YN INTO LV_ZUSE_YN FROM ZLET0009
                                    WHERE IV_TYPE LIKE P_LV_IVTYP
                                      AND WERKS   = GT_TAB-WERKS
                                      AND LGORT   = ''.
    IF SY-SUBRC = 0 AND LV_ZUSE_YN = 'Y'.
    ELSE.
      SELECT SINGLE ZUSE_YN INTO LV_ZUSE_YN FROM ZLET0009
                                      WHERE IV_TYPE LIKE P_LV_IVTYP
                                        AND WERKS   = ''
                                        AND LGORT   = ''.
      IF SY-SUBRC = 0 AND LV_ZUSE_YN = 'Y'.
      ELSE.
        P_LV_FLAG = 'X'.
      ENDIF.
    ENDIF.
  ENDIF.

ENDFORM.                    " SM_IVTYPE_CHECK
*&---------------------------------------------------------------------*
*&      Form  excel_down
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM EXCEL_DOWN .

  CLEAR : GT_EXCEL, GT_EXCEL[].

  GT_EXCEL-CPUDT  = '문서발행일'.
  GT_EXCEL-BWTXT  = '통문유형명'.
  GT_EXCEL-MBLNR  = '자재문서'.
  GT_EXCEL-ZEILE  = 'ITEM'.
  GT_EXCEL-LIFNR1 = '거래처코드'.
  GT_EXCEL-NAME1  = '거래처명'.
  GT_EXCEL-WERKS  = '플랜트'.
  GT_EXCEL-MATNR  = '자재번호'.
  GT_EXCEL-MAKTX  = '품명:규격'.
  GT_EXCEL-MENGE  = '수량'.
  GT_EXCEL-MEINS  = '단위'.
*  GT_EXCEL-NETPR  = '단가'.
*  GT_EXCEL-DMBTR  = '금액'.
*  GT_EXCEL-WAERS  = '단위'.
  APPEND GT_EXCEL.

  LOOP AT GT_OUT.
    GT_EXCEL-CPUDT  = GT_OUT-CPUDT.
    GT_EXCEL-BWTXT  = GT_OUT-BWTXT.
    GT_EXCEL-MBLNR  = GT_OUT-MBLNR.
    GT_EXCEL-ZEILE  = GT_OUT-ZEILE.
    GT_EXCEL-LIFNR1 = GT_OUT-LIFNR1.
    GT_EXCEL-NAME1  = GT_OUT-NAME1.
    GT_EXCEL-WERKS  = GT_OUT-WERKS.
    GT_EXCEL-MATNR  = GT_OUT-MATNR.
    GT_EXCEL-MAKTX  = GT_OUT-MAKTX.
    GT_EXCEL-MENGE  = GT_OUT-MENGE.
    GT_EXCEL-MEINS  = GT_OUT-MEINS.
*    GT_EXCEL-NETPR  = GT_OUT-NETPR.
*    GT_EXCEL-DMBTR  = GT_OUT-DMBTR.
*    GT_EXCEL-WAERS  = GT_OUT-WAERS.
    APPEND GT_EXCEL.
  ENDLOOP.

  DATA: L_PATH LIKE RLGRAP-FILENAME.
  DATA: L_FILENAME LIKE RLGRAP-FILENAME.

  MOVE  'C:\'     TO  L_PATH.

  CALL FUNCTION 'WS_FILENAME_GET'
    EXPORTING
      DEF_FILENAME     = L_FILENAME
      DEF_PATH         = L_PATH
      MASK             = ',All Files,*.*,Some Files,*.txt;*.doc.'
      MODE             = 'S'
      TITLE            = ' '
    IMPORTING
      FILENAME         = L_FILENAME
    EXCEPTIONS
      INV_WINSYS       = 1
      NO_BATCH         = 2
      SELECTION_CANCEL = 3
      SELECTION_ERROR  = 4
      OTHERS           = 5.

  IF  SY-SUBRC  =  0.
*   20090203 Upgrade begin

*    CALL FUNCTION 'WS_DOWNLOAD'
*      EXPORTING
*        filename = l_filename
*        filetype = 'DAT'
*      TABLES
*        data_tab = gt_excel
*      EXCEPTIONS
*        OTHERS   = 99.
    DATA : WA_FILENAME TYPE STRING.
    WA_FILENAME = L_FILENAME.
    CALL FUNCTION 'GUI_DOWNLOAD'
      EXPORTING
        FILENAME                = WA_FILENAME
        FILETYPE                = 'DAT'
      TABLES
        DATA_TAB                = GT_EXCEL
      EXCEPTIONS
        FILE_WRITE_ERROR        = 1
        NO_BATCH                = 2
        GUI_REFUSE_FILETRANSFER = 3
        INVALID_TYPE            = 4
        NO_AUTHORITY            = 5
        UNKNOWN_ERROR           = 6
        HEADER_NOT_ALLOWED      = 7
        SEPARATOR_NOT_ALLOWED   = 8
        FILESIZE_NOT_ALLOWED    = 9
        HEADER_TOO_LONG         = 10
        DP_ERROR_CREATE         = 11
        DP_ERROR_SEND           = 12
        DP_ERROR_WRITE          = 13
        UNKNOWN_DP_ERROR        = 14
        ACCESS_DENIED           = 15
        DP_OUT_OF_MEMORY        = 16
        DISK_FULL               = 17
        DP_TIMEOUT              = 18
        FILE_NOT_FOUND          = 19
        DATAPROVIDER_EXCEPTION  = 20
        CONTROL_FLUSH_ERROR     = 21
        OTHERS                  = 22.
*   20090203 Upgrade end

    IF SY-SUBRC <> 0.
      RAISE UNKNOWN_ERROR.
    ELSE.
      MESSAGE I000(ZLES1) WITH L_FILENAME ' Excel File generated!'.
    ENDIF.
  ELSE.
    MESSAGE I000(ZLES1) WITH 'File Not Open.'.
    EXIT.                              "기능개선101435 - 수정
  ENDIF.

ENDFORM.                    " excel_down
*&---------------------------------------------------------------------*
*&      Form  authority_check
*&---------------------------------------------------------------------*
FORM AUTHORITY_CHECK .
  DATA: LV_SUBRC  LIKE SY-SUBRC.

*} 기능개선 273711 - 추가
*가온전선_해당 조회조건 제거로 체크 주석_(ZGODEV04_260106)
*  IF P_BZAREA IS INITIAL.
*    MESSAGE E000(ZLE1) WITH '사업장을 입력하십시오'.
*  ENDIF.
  IF P_BUKRS IS INITIAL.
    MESSAGE E000(ZLE1) WITH '회사코드를 입력하십시오'.
  ENDIF.
*  IF P_GUBUN1 IS INITIAL.
*    MESSAGE E000(ZLE1) WITH '이동유형(통문구분)을 입력하십시오'.
*  ENDIF.

*가온전선_사업장(P_BZAREA) 조회조건 미사용으로 주석_(ZGODEV04_260106)
*  CHECK P_BZAREA IS NOT INITIAL.

*  CLEAR : LV_SUBRC.
*
*  CALL FUNCTION 'Z_LE_AUTHORIZATION_CHECK'
*    EXPORTING
*      I_BZAREA = P_BZAREA
*      I_TYPE   = '5'
*    IMPORTING
*      E_SUBRC  = LV_SUBRC.
*
*  IF LV_SUBRC <> 0.
*    MESSAGE E002(ZSD1) WITH '사업장에 대한 권한이 없습니다'(E03) P_BZAREA.
*  ENDIF.

  AUTHORITY-CHECK OBJECT 'ZCBO_MM001'
               ID 'BUKRS' FIELD P_BUKRS.

  CHECK SY-SUBRC <> 0.

  SET CURSOR FIELD 'P_BUKRS'.
  MESSAGE E172 WITH P_BUKRS. "회사코드[&] 작업권한을 확인하세요.

  AUTHORITY-CHECK OBJECT 'ZCBO_MM001'
               ID 'WERKS' FIELD P_WERKS.

  CHECK SY-SUBRC <> 0.

  SET CURSOR FIELD 'P_WERKS'.
  MESSAGE E106 WITH P_WERKS. "플랜트[&] 작업권한을 확인하세요.

ENDFORM.                    " authority_check

*&---------------------------------------------------------------------*
*&      Form  check_bukrs
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM CHECK_BUKRS.

  IF P_BUKRS IS INITIAL.
    MESSAGE E001(ZGTMM01). "회사코드가 누락되었습니다.

  ELSE.
*  CHECK P_BUKRS IS NOT INITIAL.

    SELECT SINGLE MANDT
    FROM T001
    INTO SY-MANDT
    WHERE BUKRS = P_BUKRS.

    IF SY-SUBRC <> 0.
      MESSAGE E000(ZLE1) WITH '존재하지 않는 회사코드입니다'(E03).
    ELSE.
        PERFORM VALUE_REQUEST USING 'GUBUN1' .
    ENDIF.

  ENDIF.

ENDFORM.                    " check_bukrs
*&---------------------------------------------------------------------*
*&      Form  value_request_bukrs
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM VALUE_REQUEST_BUKRS.
*{ 자체개선 52264 - 변경
  DATA: LV_VRMID   TYPE VRM_ID     .

  CLEAR   : LT_VALUES, LV_VRMID.
  REFRESH : LT_VALUES.

  SELECT BUKRS AS KEY
         BUTXT AS TEXT
    FROM T001
    INTO TABLE LT_VALUES
   WHERE KTOPL =  '1000'
     AND FIKRS <> ' '.

  LV_VRMID = 'P_BUKRS'.

  CALL FUNCTION 'VRM_SET_VALUES'
    EXPORTING
      ID              = LV_VRMID
      VALUES          = LT_VALUES[]
    EXCEPTIONS
      ID_ILLEGAL_NAME = 1
      OTHERS          = 2.

*  DATA: BEGIN OF lt_t001 OCCURS 0,
*          bukrs LIKE t001-bukrs,
*          butxt LIKE t001-butxt,
*        END   OF lt_t001.
*
*  DATA: lt_fields   TYPE TABLE OF help_value WITH HEADER LINE,
*        lt_select   TYPE TABLE OF help_vtab  WITH HEADER LINE,
*        lt_valuetab TYPE TABLE OF text79_d   WITH HEADER LINE,
*        lv_value    TYPE t001-bukrs.
*
*  SELECT bukrs butxt
*    FROM t001
*    INTO TABLE lt_t001
*    WHERE ktopl =  '1000'
*      AND fikrs <> ''.
*
*  CHECK sy-subrc = 0.
*
*  lt_fields-tabname    = 'T001'.
*  lt_fields-fieldname  = 'BUKRS'.
*  lt_fields-selectflag = 'X'.
*  APPEND lt_fields.
*  lt_fields-tabname    = 'T001'.
*  lt_fields-fieldname  = 'BUTXT'.
*  lt_fields-selectflag = ' '.
*  APPEND lt_fields.
*
*  LOOP AT lt_t001.
*    lt_valuetab = lt_t001-bukrs.
*    APPEND lt_valuetab.
*    lt_valuetab = lt_t001-butxt.
*    APPEND lt_valuetab.
*  ENDLOOP.
*
*  CALL FUNCTION 'HELP_VALUES_GET_WITH_TABLE_EXT'
*    IMPORTING
*      select_value  = lv_value
*    TABLES
*      fields        = lt_fields
*      select_values = lt_select
*      valuetab      = lt_valuetab.
*
*  p_bukrs = lv_value.
*} 자체개선 52264 - 변경

ENDFORM.                    " value_request_bukrs
*&---------------------------------------------------------------------*
*&      Form  driver_chk
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM DRIVER_CHK.

  IF LV_DRNAM IS INITIAL.
    MESSAGE S000(ZLE1) DISPLAY LIKE 'E' WITH '운전자명을 입력하십시오'.
    LEAVE SCREEN.
  ENDIF.

  IF LV_TRUNO IS INITIAL.
    MESSAGE S000(ZLE1) DISPLAY LIKE 'E' WITH '차량번호를 입력하십시오'.
    LEAVE SCREEN.
  ENDIF.

  IF LV_DRTEL IS INITIAL.
    MESSAGE S000(ZLE1) DISPLAY LIKE 'E' WITH '전화번호를 입력하십시오'.
    LEAVE SCREEN.
  ENDIF.

  IF P_BUKRS = '1000' AND LV_LTEXT IS INITIAL.
    MESSAGE S000(ZLE1) DISPLAY LIKE 'E' WITH '특기사항을 입력하십시오'.
    LEAVE SCREEN.
  ENDIF.

  IF P_BUKRS = '3000' AND LV_PERNR IS INITIAL.
    MESSAGE S000(ZLE1) DISPLAY LIKE 'E' WITH '사번을 입력하십시오'.
    LEAVE SCREEN.
  ENDIF.

ENDFORM.                    " driver_chk
*&---------------------------------------------------------------------*
*&      Form  CHK_ALL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CHK_ALL .

*전체 체크 기능
  LOOP AT GT_OUT.
    GT_OUT-CHK = 'X'.
    MODIFY GT_OUT TRANSPORTING CHK.
  ENDLOOP.

  CLEAR LV_LIFNR.
  READ TABLE GT_OUT INTO GT_OUT_T INDEX 1.
  LV_LIFNR = GT_OUT_T-LIFNR.

* 동일 거래처시 Check box 조건
  LOOP AT GT_OUT WHERE CHK = 'X'.
    IF LV_LIFNR <> GT_OUT-LIFNR.
      GT_OUT-CHK_T = 'X'.
      IF GT_OUT-CHK_T IS NOT INITIAL.
        MESSAGE I005(ZLE1) WITH '거래처가 틀립니다. 확인해주세요.'.
        CLEAR : GT_OUT-CHK_T.
      ENDIF.
      LOOP AT GT_OUT.
        GT_OUT-CHK = ' '.
        MODIFY GT_OUT TRANSPORTING CHK.
      ENDLOOP.
    ENDIF.
  ENDLOOP.

ENDFORM.                    " CHK_ALL
*&---------------------------------------------------------------------*
*&      Form  GET_DRNAM_DRTEL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM GET_DRNAM_DRTEL  USING  PV_TRUNO PV_DRNAM PV_DRTEL.
*{ 기능개선 239072 - 변경
  DATA: LV_DRNAM    LIKE ZLET0017-DRNAM,
        LV_DRTEL    LIKE ZLET0017-DRPHO.

  CLEAR : LV_DRNAM, LV_DRTEL.

  SELECT SINGLE DRNAM
                DRPHO
    INTO (LV_DRNAM, LV_DRTEL)
    FROM ZLET0017
   WHERE TRNUM = PV_TRUNO.

  IF SY-SUBRC = 0 AND PV_DRNAM IS INITIAL AND PV_DRTEL IS INITIAL.
    PV_DRNAM = LV_DRNAM.
    PV_DRTEL = LV_DRTEL.
  ENDIF.

*  CLEAR : PV_DRNAM, PV_DRTEL.
*
*  SELECT SINGLE DRNAM DRPHO
*    INTO (PV_DRNAM, PV_DRTEL)
*    FROM ZLET0017
*   WHERE TRNUM = PV_TRUNO.
*} 기능개선 239072 - 변경

ENDFORM.                    " GET_DRNAM_DRTEL
*&---------------------------------------------------------------------*
*&      Form  F4_TRUNO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM F4_TRUNO  USING    PV_TRUNO.

  DATA : LV_TRNUM(20),
             LV_LINE TYPE I.

  CLEAR   : SELECTFIELD, SELECT_VALUE, LD_TABIX, GT_TRUCK,
             IT_FIELDS, SCR_FIELDS, FELD_TABLE, LV_TRNUM, LV_LINE.
  REFRESH : IT_FIELDS, SCR_FIELDS, FELD_TABLE, GT_TRUCK.

  CONCATENATE '%' PV_TRUNO INTO LV_TRNUM.

  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE GT_TRUCK
    FROM ZLET0017
   WHERE TRNUM LIKE LV_TRNUM.

  IF SY-SUBRC <> 0.
    EXIT.
  ELSE.
    DESCRIBE TABLE GT_TRUCK LINES LV_LINE.
    IF LV_LINE = 1.
      CLEAR PV_TRUNO.
      READ TABLE GT_TRUCK INDEX 1.
      IF SY-SUBRC = 0.
        PV_TRUNO = GT_TRUCK-TRNUM.
      ENDIF.
      EXIT.
    ENDIF.
  ENDIF.

  IT_FIELDS-TABNAME    = 'ZLET0017'.
  IT_FIELDS-FIELDNAME  = 'TRNUM'.
  IT_FIELDS-SELECTFLAG = 'X'.
  APPEND IT_FIELDS.

  IT_FIELDS-TABNAME    = 'ZLET0017'.
  IT_FIELDS-FIELDNAME  = 'DRNAM'.
  IT_FIELDS-SELECTFLAG = ' '.
  APPEND IT_FIELDS.

  IT_FIELDS-TABNAME    = 'ZLET0017'.
  IT_FIELDS-FIELDNAME  = 'DRPHO'.
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
      FULL_TABLE                   = GT_TRUCK
    EXCEPTIONS
      FULL_TABLE_EMPTY             = 1
      NO_TABLESTRUCTURE_GIVEN      = 2
      NO_TABLEFIELDS_IN_DICTIONARY = 3
      MORE_THEN_ONE_SELECTFIELD    = 4
      NO_SELECTFIELD               = 5
      OTHERS                       = 6.

  CHECK NOT LD_TABIX IS INITIAL.
  READ TABLE GT_TRUCK INDEX LD_TABIX.
  PV_TRUNO = GT_TRUCK-TRNUM.

ENDFORM.                    " F4_TRUNO
*&---------------------------------------------------------------------*
*&      Form  F4_TRNUM
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM F4_TRNUM  USING  PV_TRUNO.

  CLEAR   : SELECTFIELD, SELECT_VALUE, LD_TABIX, GT_TRUCK,
             IT_FIELDS, SCR_FIELDS, FELD_TABLE.
  REFRESH : IT_FIELDS, SCR_FIELDS, FELD_TABLE, GT_TRUCK.

  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE GT_TRUCK
    FROM ZLET0017.

  IT_FIELDS-TABNAME    = 'ZLET0017'.
  IT_FIELDS-FIELDNAME  = 'TRNUM'.
  IT_FIELDS-SELECTFLAG = 'X'.
  APPEND IT_FIELDS.

  IT_FIELDS-TABNAME    = 'ZLET0017'.
  IT_FIELDS-FIELDNAME  = 'DRNAM'.
  IT_FIELDS-SELECTFLAG = ' '.
  APPEND IT_FIELDS.

  IT_FIELDS-TABNAME    = 'ZLET0017'.
  IT_FIELDS-FIELDNAME  = 'DRPHO'.
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
      FULL_TABLE                   = GT_TRUCK
    EXCEPTIONS
      FULL_TABLE_EMPTY             = 1
      NO_TABLESTRUCTURE_GIVEN      = 2
      NO_TABLEFIELDS_IN_DICTIONARY = 3
      MORE_THEN_ONE_SELECTFIELD    = 4
      NO_SELECTFIELD               = 5
      OTHERS                       = 6.

  CHECK NOT LD_TABIX IS INITIAL.
  READ TABLE GT_TRUCK INDEX LD_TABIX.
  PV_TRUNO = GT_TRUCK-TRNUM.

ENDFORM.                    " F4_TRNUM
*&---------------------------------------------------------------------*
*&      Module  CHECK_REQNO  INPUT
*&---------------------------------------------------------------------*
*       기능개선 214781 - 추가
*----------------------------------------------------------------------*
MODULE CHECK_REQNO INPUT.

  PERFORM GET_TRANSPORTATION_REQ_DATA.

ENDMODULE.                 " CHECK_REQNO  INPUT
*&---------------------------------------------------------------------*
*&      Module  F4HELP_REQNO  INPUT
*&---------------------------------------------------------------------*
*       기능개선 214781 - 추가
*----------------------------------------------------------------------*
MODULE F4HELP_REQNO INPUT.

  PERFORM F4HELP_REQNO.

ENDMODULE.                 " F4HELP_REQNO  INPUT
*&---------------------------------------------------------------------*
*&      Form  F4HELP_REQNO
*&---------------------------------------------------------------------*
*       기능개선 214781 - 추가
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
  LT_RSPAR-LOW     = P_BUKRS.
  APPEND LT_RSPAR.

*___사업부
  CLEAR : LT_RSPAR.
  LT_RSPAR-SELNAME = 'P_BZAREA'.
  LT_RSPAR-KIND    = 'P'.
  LT_RSPAR-LOW     = P_BZAREA.
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

  GV_REQNO = LV_REQNO.

ENDFORM.                    " F4HELP_REQNO
*&---------------------------------------------------------------------*
*&      Form  GET_TRANSPORTATION_REQ_DATA
*&---------------------------------------------------------------------*
*       기능개선 214781 - 추가
*----------------------------------------------------------------------*
FORM GET_TRANSPORTATION_REQ_DATA .
  DATA: LS_1000     LIKE ZLET1000.

  CLEAR : LS_1000, GV_COPY.

  CHECK GV_REQNO IS NOT INITIAL.

  SELECT SINGLE *
    INTO LS_1000
    FROM ZLET1000
   WHERE REQNO = GV_REQNO.

  IF SY-SUBRC = 0.
    IF LS_1000-STATS = 'D'.
      MESSAGE E004(ZLE1) WITH '배차요청번호' GV_REQNO
                              '은(는) 요청삭제 되었습니다.'.
    ELSE.
      IF LS_1000-CARNO IS NOT INITIAL OR
         LS_1000-DRVNM IS NOT INITIAL OR
         LS_1000-TELNO IS NOT INITIAL.
        LV_TRUNO = LS_1000-CARNO.     "차량번호
        LV_DRNAM = LS_1000-DRVNM.     "운전자명
        LV_DRTEL = LS_1000-TELNO.     "운전자전화번호

        GV_COPY  = 'X'.
      ENDIF.
    ENDIF.
  ELSE.
    MESSAGE E004(ZLE1) WITH '배차요청번호' GV_REQNO
                            '이(가) 존재하지 않습니다.'.
  ENDIF.

ENDFORM.                    " GET_TRANSPORTATION_REQ_DATA
*&---------------------------------------------------------------------*
*&      Form  SET_DEFAULT_GUBUN
*&---------------------------------------------------------------------*
*       기능개선 214781 - 추가
*----------------------------------------------------------------------*
FORM SET_DEFAULT_GUBUN .

*___통문유형이 입력된 상태에서 회사코드나 대상구분이 바뀌면
*   입력된 통문유형이 존재하는지 점검하여 존재하지 않으면 Clear

  SORT LT_VALUES BY KEY.

  IF P_GUBUN1 IS NOT INITIAL.
    READ TABLE LT_VALUES WITH KEY KEY = P_GUBUN1.
    IF SY-SUBRC <> 0.
      CLEAR : P_GUBUN1.
    ENDIF.
  ENDIF.

*{ 기능개선 273305 - 변경
*___통문유형이 입력되어 있지 않으면 통문유형 중 1번째를
*   기본값으로 표시
  IF P_GUBUN1 IS INITIAL.
    READ TABLE LT_VALUES INDEX 1.
    IF SY-SUBRC = 0.
      P_GUBUN1 = LT_VALUES-KEY.
    ENDIF.
  ENDIF.

**___통문유형이 입력되어 있지 않으면 통문유형 중 2번째('999:전체' 다음)를
**   기본값으로 표시
*  IF P_GUBUN1 IS INITIAL.
*    READ TABLE LT_VALUES INDEX 2.
*    IF SY-SUBRC = 0.
*      P_GUBUN1 = LT_VALUES-KEY.
*    ELSE.
*      P_GUBUN1 = '999'.
*    ENDIF.
*  ENDIF.
*} 기능개선 273305 - 변경

ENDFORM.                    " SET_DEFAULT_GUBUN
*&---------------------------------------------------------------------*
*&      Form  INITIALIZATION
*&---------------------------------------------------------------------*
*       기능개선 214781 - Form 추가
*----------------------------------------------------------------------*
FORM INITIALIZATION .

  T1 = '통문문서 발행대상 구분'.
  T2 = '선택조건'.
  T3 = '발행조건'.

  CLEAR   : I_CPUDT.
  REFRESH : I_CPUDT.

  I_CPUDT-SIGN   = 'I'.
  I_CPUDT-OPTION = 'BT'.
  I_CPUDT-LOW    = SY-DATUM.                                "- 30.
  I_CPUDT-HIGH   = SY-DATUM.
  APPEND I_CPUDT.

*{ 기능개선 273711 - 삭제
**{ 기능개선 214781 - 추가
*  PERFORM VALUE_REQUEST USING 'GUBUN1' .
*
*  PERFORM SET_DEFAULT_GUBUN.
**} 기능개선 214781 - 추가
*} 기능개선 273711 - 삭제

ENDFORM.                    " INITIALIZATION
*&---------------------------------------------------------------------*
*&      Form  IMPORT_IVTYPE_FROM_PARAMETER
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM IMPORT_IVTYPE_FROM_PARAMETER .
  DATA: LV_IVTYP    LIKE ZGTMMT4500-IV_TYPE.

  GET PARAMETER ID 'ZIVTYPE' FIELD LV_IVTYP.

  IF LV_IVTYP IS NOT INITIAL.
    P_GUBUN1 = LV_IVTYP.
  ENDIF.

  SET PARAMETER ID 'ZIVTYPE' FIELD ' '.

ENDFORM.                    " IMPORT_IVTYPE_FROM_PARAMETER
*&---------------------------------------------------------------------*
*&      Module  INPUT_LV_PERNR  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE INPUT_LV_PERNR INPUT.

  IF NOT LV_PERNR IS INITIAL.
    SELECT SINGLE ENAME
      INTO (LV_ENAME)
      FROM ZZPA0001
     WHERE BEGDA <= SY-DATUM
       AND ENDDA >= SY-DATUM
       AND PERNR =  LV_PERNR
       AND PERSG =  '1'.      "재직자

    IF SY-SUBRC <> 0.
      MESSAGE E000(ZLE1) WITH '존재하지 않는 사원입니다'.
    ENDIF.
  ELSE.
    CLEAR: LV_ENAME.
  ENDIF.

ENDMODULE.                 " INPUT_LV_PERNR  INPUT
*&---------------------------------------------------------------------*
*&      Module  F4_PERNR  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE F4_PERNR INPUT.


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
     AND BUKRS =  P_BUKRS
     AND PERSG =  '1'.          "재직자
  SORT POV_PER BY PERNR.



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
    IMPORTING
      INDEX         = J
    TABLES
      FIELDS        = FIELDTAB
      SELECT_VALUES = I_HELP_VTAB
      VALUETAB      = VALUETAB.

  IF J > 0.
    READ TABLE POV_PER INDEX J.
    IF SY-SUBRC = 0.
      LV_PERNR = POV_PER-PERNR.
    ENDIF.
  ENDIF.


ENDMODULE.                 " F4_PERNR  INPUT
