*&---------------------------------------------------------------------*
*&  Include           MZLE0001O01                                      *
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  status_0100  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE STATUS_0100 OUTPUT.

  DATA : BEGIN OF S_FUNC OCCURS 0,
           UCOMM(6) TYPE C,
         END OF S_FUNC,
         LV_TITLE(40) TYPE C.

  CLEAR: S_FUNC[].
  IF TS_FLAG1 = 'Y'.
    S_FUNC = 'REFR'.
    APPEND S_FUNC.
    S_FUNC = 'TONG'.
    APPEND S_FUNC.
    S_FUNC = 'APPL'.
    APPEND S_FUNC.
    S_FUNC = 'SAVE'.
    APPEND S_FUNC.
  ELSE.
    IF TS_FLAG1 = 'X'.
      S_FUNC = 'REFR'.
      APPEND S_FUNC.
    ENDIF.

    PERFORM CHECK_APPROVAL CHANGING GV_CHECK.
    IF GV_CHECK = 'X'.
      S_FUNC = 'APPL'.
      APPEND S_FUNC.
*{ 기능개선 239718 - 변경
    ELSE.
      S_FUNC = 'TONG'.
      APPEND S_FUNC.
*} 기능개선 239718 - 변경
    ENDIF.
  ENDIF.

  CONCATENATE WA-IV_TYPE ':' WA-IV_TYPE_NM INTO LV_TITLE.

  SET PF-STATUS '100' EXCLUDING S_FUNC.
  SET TITLEBAR  '100' WITH LV_TITLE.

ENDMODULE.                 " status_0100  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  init  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE INIT OUTPUT.

  DATA: TS_FLAG ,
        TS_IV_NO   LIKE ZLET0005-IV_NO,
        TT_FLAG ,
        TT_FLAG2,   "자체개선 52275-추가
        TS_IV_TYPE LIKE ZLET0005-IV_TYPE,
        TS_BUKRS   LIKE MATDOC-BUKRS.

  IMPORT TS_FLAG
         TT_FLAG
         TT_FLAG2   "자체개선 52275-추가
         TS_IV_NO
         TS_IV_TYPE
         TS_BUKRS
         FROM MEMORY ID 'ZZZZ'.
  FREE MEMORY ID 'ZZZZ'.

   SELECT SINGLE zactive
     INTO gv_simple_approval
    FROM zsat0004
    WHERE ztype = 'L1'.

  IF TS_FLAG = 'X' OR TS_FLAG = 'Y'.
    TS_FLAG1 = TS_FLAG.
    WA-BUKRS = TS_BUKRS.
    PERFORM GET_BUKRS_DESC USING WA-BUKRS WA-BUTXT.
    GV_BUKRS = WA-BUKRS.

    CLEAR: TS_FLAG, TS_BUKRS.
    SELECT SINGLE * FROM ZGTMMT4500
       WHERE IV_NO = TS_IV_NO.
    IF SY-SUBRC = 0.
*/........< HEADER INFO >
      MOVE-CORRESPONDING ZGTMMT4500  TO WA.
*
      SELECT SINGLE NAME1 INTO WA-WERKS_T
        FROM T001W
       WHERE WERKS = WA-WERKS.
*
      SELECT SINGLE IV_TYPE_NM INTO WA-IV_TYPE_NM
        FROM ZGTMMT4511
       WHERE GUBUN = 'MA'
         AND IV_TYPE LIKE 'E__'
         AND IV_TYPE = WA-IV_TYPE.
*
      IF WA-KUNNR IS NOT INITIAL.
        SELECT SINGLE NAME1 ORT01 STRAS
          INTO (WA-KUNNR_T, WA-ORT01, WA-STRAS)
          FROM LFA1
         WHERE LIFNR = WA-KUNNR.
        CONCATENATE WA-ORT01 WA-STRAS INTO WA-ADDRS.
      ENDIF.

      IF WA-KUNNR1 IS NOT INITIAL.
        SELECT SINGLE NAME1 ORT01 STRAS
          INTO (WA-KUNNR1_T, WA-ORT01, WA-STRAS)
          FROM KNA1
         WHERE LIFNR = WA-KUNNR1.
        CONCATENATE WA-ORT01 WA-STRAS INTO WA-ADDRS.
      ENDIF.

      IF WA-KUNNR2 IS NOT INITIAL.
        WA-KUNNR1_T = WA-KUNNR2.
      ENDIF.

      IF ZGTMMT4500-ZMANUAL IS NOT INITIAL.
        WA-CHANGE = 'X'.
      ENDIF.

*
      SELECT SINGLE ENAME ORGEH
        INTO (WA-ENAME, WA-ORGEH)
        FROM ZZPA0001
       WHERE BEGDA <= SY-DATUM
         AND ENDDA >= SY-DATUM
         AND PERNR = WA-PERNR.
      SELECT SINGLE ORGTX INTO WA-ORGTX
        FROM T527X
       WHERE SPRSL = '3'
         AND ORGEH = WA-ORGEH
         AND ENDDA = '99991231'.
*/.........< ITEM INFO >
      SELECT *
         INTO CORRESPONDING FIELDS OF TABLE GT_LIST
         FROM ZGTMMT4501
        WHERE IV_NO =  TS_IV_NO.
*/.........< APPROVAL INFO >
      SELECT SINGLE APP_ID1 APP_NM1 APP_ID2 APP_NM2
        FROM ZLET0003
        INTO (WA_0110-APP_ID1, WA_0110-APP_NM1,
              WA_0110-APP_ID2, WA_0110-APP_NM2)
        WHERE IV_NO = TS_IV_NO.
      IF WA_0110-APP_NM1 IS INITIAL.
        CONCATENATE '승인자:' WA_0110-APP_NM2  INTO WA-APPLINE.
      ELSE.
        CONCATENATE '합의자:' WA_0110-APP_NM1  INTO WA-APPLINE.
        CONCATENATE WA-APPLINE '/' '승인자:'   INTO WA-APPLINE
                                               SEPARATED BY SPACE.
        CONCATENATE WA-APPLINE WA_0110-APP_NM2 INTO WA-APPLINE.
      ENDIF.
    ENDIF.
  ELSEIF TT_FLAG = 'X' AND TT_FLAG2 = 'X'.       "자체개선 52275-변경
    WA-IV_TYPE = TS_IV_TYPE.

    SELECT SINGLE IV_TYPE_NM INTO WA-IV_TYPE_NM
      FROM ZGTMMT4511
     WHERE GUBUN = 'MA'
       AND IV_TYPE LIKE 'E__'
       AND IV_TYPE = WA-IV_TYPE.

    GV_IV_TYPE    = WA-IV_TYPE.
    GV_IV_TYPE_NM = WA-IV_TYPE_NM.
    WA-BUKRS = TS_BUKRS.
    PERFORM GET_BUKRS_DESC USING WA-BUKRS WA-BUTXT.
    GV_BUKRS = WA-BUKRS.

    IF TS_IV_TYPE = 'E01' OR
       TS_IV_TYPE = 'E13' OR            "기능개선 307461  - 추가
       TS_IV_TYPE = 'E06'.              "기능개선 276257 - 추가
*___'E01:검,교정수리' 최초 실행시 반입예정 초기값
      WA-RETURN_YN = 'X'.
    ENDIF.

    CLEAR: TS_IV_TYPE, TS_BUKRS, TT_FLAG.
*-{자체개선 52275 - 추가
  ELSEIF TT_FLAG = ' ' AND TT_FLAG2 = ' '.
*    MESSAGE I000 DISPLAY LIKE 'E' WITH 'ZLE0019T를 먼저 실행해 주세요'.
*      LEAVE TO SCREEN 0.
*-}자체개선 52275_2014.11.07
  ENDIF.

  DATA: LV_CNT  TYPE I.
  DATA: LV_MOD  TYPE I.
  CLEAR: OK_CODE.

*  IF sy-ucomm = 'CHAN'.
*    LOOP AT SCREEN.
*      CASE screen-name .
*        WHEN 'WA-IV_NO'.
*          screen-input = 1.
**         screen-intensified = 1.
*      ENDCASE.
*      MODIFY SCREEN.
*    ENDLOOP.
*  ENDIF.

  IF  WA-IV_TYPE <> ' '.
    IF WA-IV_TYPE = 'E04' OR WA-IV_TYPE = 'E10'.  "사내소비
      LOOP AT SCREEN.
        CASE SCREEN-NAME .
          WHEN 'WA-UMWRK'.
            SCREEN-INPUT = 1.
            MODIFY SCREEN.
          WHEN 'WA-KUNNR1'.
*           IF WA-BUKRS = '3000'. "엠트론
*            SCREEN-INPUT = 1.
*            MODIFY SCREEN.
*           ELSE. "전선
            IF WA-CHANGE = 'X'. "수기입력
              SCREEN-INPUT = 0.
              MODIFY SCREEN.
            ELSE.
              SCREEN-INPUT = 1.
              MODIFY SCREEN.
*              CLEAR : WA-ADDRS, WA-KUNNR1_T.
            ENDIF.
*           ENDIF.
          WHEN 'WA-KUNNR1_T'.
*           IF WA-BUKRS = '3000'. "엠트론
*            SCREEN-INPUT = 0.
*            MODIFY SCREEN.
*           ELSE. "전선
            IF WA-CHANGE = 'X'. "수기입력
              SCREEN-INPUT = 1.
              MODIFY SCREEN.
            ELSE.
              SCREEN-INPUT = 0.
              MODIFY SCREEN.
            ENDIF.
*           ENDIF.
          WHEN 'WA-KUNNR'.
*           IF WA-BUKRS = '3000'.
            SCREEN-INPUT = 1.
            MODIFY SCREEN.
*           ELSE.
*             SCREEN-INPUT = 0.
*             MODIFY SCREEN.
*           ENDIF.
        ENDCASE.
      ENDLOOP.
    ELSE.
      LOOP AT SCREEN.
        CASE SCREEN-NAME .
          WHEN 'WA-KUNNR1'.
*           IF WA-BUKRS = '3000'. "엠트론
*            SCREEN-INPUT = 1.
*            MODIFY SCREEN.
*           ELSE. "전선
            IF WA-CHANGE = 'X'. "수기입력
              SCREEN-INPUT = 0.
              MODIFY SCREEN.
            ELSE.
              SCREEN-INPUT = 1.
              MODIFY SCREEN.
*              CLEAR : WA-ADDRS, WA-KUNNR1_T.
            ENDIF.
*           ENDIF.
          WHEN 'WA-KUNNR1_T'.
*           IF WA-BUKRS = '3000'. "엠트론
*            SCREEN-INPUT = 0.
*            MODIFY SCREEN.
*           ELSE. "전선
            IF WA-CHANGE = 'X'. "수기입력
              SCREEN-INPUT = 1.
              MODIFY SCREEN.
            ELSE.
              SCREEN-INPUT = 0.
              MODIFY SCREEN.
            ENDIF.
*           ENDIF.
          WHEN 'WA-KUNNR'.
*           IF WA-BUKRS = '3000'.
            SCREEN-INPUT = 1.
            MODIFY SCREEN.
*           ELSE.
*             SCREEN-INPUT = 0.
*             MODIFY SCREEN.
*           ENDIF.
        ENDCASE.
      ENDLOOP.
    ENDIF.
  ENDIF.

  IF WA-IV_TYPE = 'E03'.
    LOOP AT SCREEN.
      CASE SCREEN-NAME.
        WHEN 'WA-RETURN_YN'.
          SCREEN-INPUT = 0.
          MODIFY SCREEN.
      ENDCASE.
    ENDLOOP.
*-{기능개선 48112 - 추가
  ELSEIF WA-IV_TYPE = 'E01' AND WA-BUKRS <> '3000'.
*    WA-RETURN_YN = 'X'.
    LOOP AT SCREEN.
      CASE SCREEN-NAME.
        WHEN 'WA-RETURN_YN'.
          SCREEN-INPUT = 0.
          MODIFY SCREEN.
      ENDCASE.
    ENDLOOP.
*-}기능개선 48112_2014.10.15
  ENDIF.

*-{기능개선 48112 - 추가
  LOOP AT SCREEN.
    CASE SCREEN-NAME.
      WHEN 'WA-ADDRS'.
        IF WA-CHANGE = 'X'.
          SCREEN-INPUT = 1.
          MODIFY SCREEN.
        ELSE.
          SCREEN-INPUT = 0.
          MODIFY SCREEN.
        ENDIF.
      WHEN 'WA-ETC_NM'.
        IF GV_BUKRS <> '1000'.
          SCREEN-ACTIVE = 0.
          MODIFY SCREEN.
        ENDIF.
      WHEN 'WA-CHANGE'.
        IF WA-BUKRS = '1000'.
          IF WA-KUNNR1 IS NOT INITIAL.
            SCREEN-INPUT = 0.
            MODIFY SCREEN.
          ELSE.
            SCREEN-INPUT = 1.
            MODIFY SCREEN.
          ENDIF.
        ELSE.
*          SCREEN-INPUT = 0.
*          MODIFY SCREEN.
        ENDIF.
    ENDCASE.

    IF WA-BUKRS <> '1000' AND SCREEN-GROUP1 = 'G11'.
      SCREEN-INPUT     = 0.
      SCREEN-INVISIBLE = 1.
      MODIFY SCREEN.
    ENDIF.
  ENDLOOP.
*-}기능개선 48112_2014.10.15

  IF TS_FLAG1 = 'Y'.
    LOOP AT SCREEN.
      CASE SCREEN-NAME.
        WHEN 'WA-RETURN_YN' OR 'WA-WERKS' OR 'WA-UMWRK' OR 'WA-KUNNR' OR
             'WA-KUNNR1' OR 'WA-ADDRS' OR 'WA-PERNR' OR 'WA-ETC_NM' OR
             'WA-CHANGE' OR 'WA-KUNNR1_T' OR 'DELE'.
          SCREEN-INPUT = 0.
          MODIFY SCREEN.
      ENDCASE.
    ENDLOOP.
  ENDIF.

*{ 기능개선 228147 - 추가
  IF WA-IV_TYPE = 'E12'.
    GV_MAKTX = '모델'.

*{ 기능개선 229448 - 삭제
*    IF ( GS_IO-GIJUN = 'X' OR GS_IO-GIENG = 'X' ) AND
*         GS_IO-GRDAE = 'X'.
*      WA-RETURN_YN = 'X'.
*    ELSE.
*      CLEAR : WA-RETURN_YN.
*    ENDIF.
*} 기능개선 229448 - 삭제

    IF WA-WERKS IS INITIAL.
      WA-WERKS  = '3602'.

      PERFORM GET_WERKS_DESC USING WA-WERKS WA-WERKS_T.

      PERFORM GET_BIZ_AREA USING    WA-WERKS
                           CHANGING WA-BZAREA
                                    WA-BZAREA_T.
    ENDIF.
  ELSE.
    GV_MAKTX = '품명/규격'.
  ENDIF.

  LOOP AT SCREEN.
    IF ( WA-IV_TYPE =  'E12' AND SCREEN-GROUP2 = 'G21' ) OR
       ( WA-IV_TYPE <> 'E12' AND SCREEN-GROUP2 = 'G22' ).
      SCREEN-INPUT     = 0.
      SCREEN-INVISIBLE = 1.
    ENDIF.


*    IF ( SCREEN-NAME = 'WA-RETURN_YN' OR     "기능개선 229448 - 삭제
    IF ( SCREEN-NAME = 'WA-WERKS' )   AND
       WA-IV_TYPE = 'E12'.
      SCREEN-INPUT     = 0.
    ENDIF.

*-[SRM2112-01975_S
    IF  WA-BUKRS = '3000' AND  WA-IV_TYPE = 'E12'
                                        AND GS_IO-GREXT <> 'X'.
      IF SCREEN-GROUP2 = 'G23'.
        SCREEN-INPUT  = 0.
        CLEAR GV_GREXT.
      ENDIF.
    ENDIF.
*]-SRM2112-01975_E

    MODIFY SCREEN.
  ENDLOOP.
*} 기능개선 228147 - 추가

  IF GV_FLAG = ' '.
    WA-CREATE_DATE = SY-DATUM.
    GV_FLAG = 'X'.
  ENDIF.

  DESCRIBE TABLE GT_LIST     LINES LV_CNT.
*  lv_mod = lv_cnt MOD 10.
*  IF lv_mod = 0.
  DESCRIBE TABLE GT_LIST     LINES TC01-LINES.
  TC01-LINES = TC01-LINES + 11.
*  ENDIF.

ENDMODULE.                 " init  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  pbo_100_list  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE PBO_100_LIST OUTPUT.

  IF WA-RETURN_YN = ' '.
    LOOP AT TC01-COLS INTO WA_COLS
       WHERE SCREEN-NAME = 'GT_LIST-RETURN_DUE_DATE'.
      WA_COLS-INVISIBLE = '1'.
      WA_COLS-SCREEN-REQUIRED = 0.
      MODIFY TC01-COLS FROM WA_COLS INDEX SY-TABIX.
    ENDLOOP.
  ELSE.
    LOOP AT TC01-COLS INTO WA_COLS
       WHERE SCREEN-NAME = 'GT_LIST-RETURN_DUE_DATE'.
      WA_COLS-INVISIBLE = '0'.
      WA_COLS-SCREEN-REQUIRED = 2.
      MODIFY TC01-COLS FROM WA_COLS INDEX SY-TABIX.
    ENDLOOP.
  ENDIF.

  IF TS_FLAG1 = 'Y'.
*___조회인 경우 필드 비활성화
    LOOP AT TC01-COLS INTO WA_COLS.
      WA_COLS-SCREEN-INPUT = 0.
      MODIFY TC01-COLS FROM WA_COLS.
    ENDLOOP.
  ENDIF.

*{ 기능개선 276257 - 추가
  IF WA-IV_TYPE = 'E06' OR
     WA-IV_TYPE = 'E13' . "기능개선 -307461
    LOOP AT SCREEN.
      IF SCREEN-NAME = 'WA-RETURN_YN'.
        SCREEN-INPUT = '0'.
      ENDIF.
      IF SCREEN-GROUP3 = 'G40'..
        IF  WA-IV_TYPE = 'E13'.
          SCREEN-INVISIBLE = '0'.
        ELSE.
          SCREEN-INVISIBLE = '1'.
        ENDIF.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.

    LOOP AT TC01-COLS INTO WA_COLS.
*{ 기능개선 307461 - S
      IF WA-IV_TYPE = 'E13'.
        IF WA_COLS-SCREEN-NAME = 'GT_LIST-MAKTX'.
          WA_COLS-SCREEN-INPUT    = '0'.
        ELSEIF  WA_COLS-SCREEN-NAME = 'GT_LIST-LGORT'.
          WA_COLS-SCREEN-INPUT    = '1'.
          WA_COLS-INVISIBLE = '0'.
        ENDIF.
      ELSE.
*{ 기능개선 307461 - E
        IF WA_COLS-SCREEN-NAME = 'GT_LIST-MAKTX'.
          WA_COLS-SCREEN-INPUT    = '0'.
        ELSEIF WA_COLS-SCREEN-NAME = 'GT_LIST-LABST' OR
               WA_COLS-SCREEN-NAME = 'GT_LIST-MENGE_RE' OR
               WA_COLS-SCREEN-NAME = 'GT_LIST-MENGE_ST' OR
               WA_COLS-SCREEN-NAME = 'GT_LIST-LGORT'.
          WA_COLS-INVISIBLE = '1'.
        ELSE.
          CONTINUE.
        ENDIF.
      ENDIF.

      MODIFY TC01-COLS FROM WA_COLS.
    ENDLOOP.
  ELSE.

    LOOP AT SCREEN.
      IF SCREEN-GROUP3 = 'G40'..
        SCREEN-INVISIBLE = '1'.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.

*} 기능개선 276257 - 추가
*20100910 요청 이길상 C
*  IF WA-IV_TYPE NE 'E06'.
    LOOP AT TC01-COLS INTO WA_COLS
      WHERE SCREEN-NAME = 'GT_LIST-MATNR'
         OR SCREEN-NAME = 'GT_LIST-LABST'
         OR SCREEN-NAME = 'GT_LIST-LGORT'
         OR SCREEN-NAME = 'GT_LIST-MENGE_RE'
         OR SCREEN-NAME = 'GT_LIST-MENGE_ST'.
      WA_COLS-SCREEN-INPUT = '0'.            "기능개선 277121 - 추가
      WA_COLS-INVISIBLE    = '1'.
      MODIFY TC01-COLS FROM WA_COLS INDEX SY-TABIX.
    ENDLOOP.
*  ELSE.
*    LOOP AT TC01-COLS INTO WA_COLS
*      WHERE SCREEN-NAME = 'GT_LIST-MATNR'
*         OR SCREEN-NAME = 'GT_LIST-LABST'
*         OR SCREEN-NAME = 'GT_LIST-LGORT'.
*      WA_COLS-INVISIBLE = '0'.
*      MODIFY TC01-COLS FROM WA_COLS INDEX SY-TABIX.
*    ENDLOOP.
*  ENDIF.
*여기까지
  ENDIF.

  LOOP AT TC01-COLS INTO WA_COLS.
*{ 기능개선 228147 - 추가
    IF ( WA-IV_TYPE <> 'E12' AND WA_COLS-SCREEN-GROUP3 = 'G31' ) OR
       ( WA-IV_TYPE =  'E12' AND WA_COLS-SCREEN-GROUP3 = 'G32' ) OR
*{ 기능개선 307461 - S
       ( WA-IV_TYPE =  'E13' AND WA_COLS-SCREEN-GROUP3 = 'G32' ).
*{ 기능개선 307461 - E
      WA_COLS-INVISIBLE = '1'.
    ENDIF.
*} 기능개선 228147 - 추가

*{ 기능개선 251794 - 추가
*___회사코드 '3000', 'E99'가 아닌 경우 통문사유 입력 필드 비가시화
    IF ( ( WA-BUKRS <> '3000' OR WA-IV_TYPE <> 'E99' ) AND
         WA_COLS-SCREEN-GROUP3 = 'G33' ) .
      WA_COLS-INVISIBLE = '1'.
    ENDIF.
*} 기능개선 251794 - 추가

    MODIFY TC01-COLS FROM WA_COLS.
  ENDLOOP.

* gt_list-waers = 'KRW'.
* gt_list-dmbtr = gt_list-dmbtr / 100.




ENDMODULE.                 " pbo_100_list  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  STATUS_0110  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE STATUS_0110 OUTPUT.

  SET PF-STATUS '110'.
  SET TITLEBAR '110'.

ENDMODULE.                 " STATUS_0110  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  SET_CURSOR  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE SET_CURSOR OUTPUT.

  SET CURSOR FIELD G_CURSOR_FIELD LINE I_CURSOR_LINE.

ENDMODULE.                 " SET_CURSOR  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  PBO_100_FROM_MEMROY  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE PBO_100_FROM_MEMROY OUTPUT.

  DATA : BEGIN OF LT_MEM ,
           ORD_NUM  TYPE ZLET0105-ORD_NUM,
           WERKS    LIKE LIPS-WERKS,
           ARKTX    LIKE LIPS-ARKTX,
           GROES    LIKE MARA-GROES,
           KUNNR_T  LIKE KNA1-NAME1,  "납품처명
           ORT01(100),
           PERNR    LIKE ZZPA0001-PERNR,
        END OF LT_MEM.


  IMPORT  LT_GATE TO LT_MEM FROM MEMORY ID 'ZLE0101T'.

  CHECK LT_MEM  IS NOT INITIAL.
  FREE MEMORY ID 'ZLE0101T'.

  WA-KUNNR1_T   = LT_MEM-KUNNR_T.
  WA-ADDRS      = LT_MEM-ORT01.
  WA-PERNR      = LT_MEM-PERNR.
  WA-WERKS      = LT_MEM-WERKS.
  WA-CHANGE     = 'X'.

  GV_ORD_NUM      = LT_MEM-ORD_NUM.

  IF LT_MEM-GROES IS INITIAL.
    GT_LIST-MAKTX = LT_MEM-ARKTX .
  ELSEIF LT_MEM-GROES IS NOT INITIAL AND LT_MEM-ARKTX IS INITIAL.
    GT_LIST-MAKTX = LT_MEM-GROES .
  ELSEIF  LT_MEM-GROES  IS NOT INITIAL AND
          LT_MEM-ARKTX  IS NOT INITIAL .
    CONCATENATE LT_MEM-ARKTX '/' LT_MEM-GROES  INTO  GT_LIST-MAKTX.
  ENDIF.


  IF GT_LIST-MAKTX IS NOT INITIAL.
    APPEND GT_LIST.
  ENDIF.

  CLEAR LT_MEM.


  IF NOT WA-PERNR IS INITIAL.
    SELECT SINGLE ENAME ORGEH
      INTO (WA-ENAME, WA-ORGEH)
      FROM ZZPA0001
     WHERE BEGDA <= SY-DATUM
       AND ENDDA >= SY-DATUM
       AND PERNR =  WA-PERNR
       AND PERSG =  '1'.      "재직자 - 기능개선 239718 - 추가
    .
    IF SY-SUBRC <> 0.
      MESSAGE E000(ZLE1) WITH '존재하지 않는 사원입니다'.
    ELSE.
      SELECT SINGLE ORGTX
        INTO WA-ORGTX
        FROM T527X
       WHERE SPRSL = '3'
         AND ORGEH = WA-ORGEH
         AND BEGDA <= SY-DATUM
         AND ENDDA >= SY-DATUM.
    ENDIF.
  ELSE.
    CLEAR: WA-ENAME, WA-ORGTX, WA-ORGEH.
  ENDIF.



  IF WA-WERKS IS NOT INITIAL.
    PERFORM GET_WERKS_DESC USING WA-WERKS WA-WERKS_T.

    IF WA-BUKRS IS NOT INITIAL AND
       WA-WERKS IS NOT INITIAL.
      PERFORM CHECK_BUKRS_WERKS USING WA-BUKRS WA-WERKS.

      SELECT SINGLE BZAREA BZAREA_T
        INTO (WA-BZAREA, WA-BZAREA_T)
        FROM ZLET0034
       WHERE WERKS = WA-WERKS.

      IF WA-BZAREA IS INITIAL.
        MESSAGE E004 WITH '플랜트' WA-WERKS
                          '에 해당하는 사업장을 찾지 못했습니다.'
                          '관리자에게 문의하십시오.'.
      ENDIF.
    ENDIF.
  ENDIF.


* 강제로 user command를 실행해서 PBO를 한번 더 흐르게 함 --
  CALL FUNCTION 'SAPGUI_SET_FUNCTIONCODE'
    EXPORTING
      FUNCTIONCODE           = 'ENTER'
    EXCEPTIONS
      FUNCTION_NOT_SUPPORTED = 1
      OTHERS                 = 2.


ENDMODULE.                 " PBO_100_FROM_MEMROY  OUTPUT
