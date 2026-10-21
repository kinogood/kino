*&---------------------------------------------------------------------*
*&  Include           MZLE0002O02                                      *
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  STATUS_0100  OUTPUT
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
    S_FUNC = 'APPL'.
    APPEND S_FUNC.
*/ EDIT FROM BY G.T.JUNG AT 2016.11.16
    S_FUNC = 'FILE'.
    APPEND S_FUNC.
    S_FUNC = 'SAVE'.
    APPEND S_FUNC.
*/ EDIT END
  ELSE.
    IF TS_FLAG1 = 'X'.
      S_FUNC = 'REFR'.
      APPEND S_FUNC.
*/ EDIT FROM BY G.T.JUNG AT 2016.11.16
      S_FUNC = 'FILE'.
      APPEND S_FUNC.
*/ EDIT END
    ENDIF.
    PERFORM CHECK_APPROVAL CHANGING GV_CHECK.
    IF GV_CHECK = 'X'.
      S_FUNC = 'APPL'.
      APPEND S_FUNC.
*/ EDIT FROM BY G.T.JUNG AT 2016.11.16
      IF GV_BUKRS = '3000'  AND
        ( GV_IV_TYPE = 'C05' OR GV_IV_TYPE = 'C06' ).
      ELSE.
        S_FUNC = 'FILE'.
        APPEND S_FUNC.
      ENDIF.
    ELSE.
      IF GV_BUKRS = '3000'  AND
        ( GV_IV_TYPE = 'C05' OR GV_IV_TYPE = 'C06' ).
      ELSE.
        S_FUNC = 'FILE'.
        APPEND S_FUNC.
      ENDIF.
*/ EDIT END

    ENDIF.
  ENDIF.

  CONCATENATE WA-IV_TYPE ':' WA-IV_TYPE_NM INTO LV_TITLE.

  SET PF-STATUS '0100' EXCLUDING S_FUNC.
  SET TITLEBAR '0100' WITH LV_TITLE.

  IF GV_BUKRS = '1000'.
    GV_TEXT1 = '사유'.
  ELSE.
    GV_TEXT1 = '특이사항'.
  ENDIF.

   SELECT SINGLE zactive
     INTO gv_simple_approval
    FROM zsat0004
    WHERE ztype = 'L1'.


ENDMODULE.                 " STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  DISPLAY  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE DISPLAY OUTPUT.

  MODIFY GT_OUT INDEX TC01-CURRENT_LINE.

ENDMODULE.                 " DISPLAY  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  INIT  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE INIT OUTPUT.

  DATA: TS_FLAG ,
        TS_IV_NO   LIKE ZLET0005-IV_NO ,
        TT_FLAG,
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
      MOVE-CORRESPONDING ZGTMMT4500 TO WA.
      WA-TEXT1 = ZGTMMT4500-ETC_NM.
*
      SELECT SINGLE NAME1 INTO WA-WERKS_T
        FROM T001W
       WHERE WERKS = WA-WERKS.
*
      SELECT SINGLE IV_TYPE_NM INTO WA-IV_TYPE_NM
        FROM ZLET0007
       WHERE GUBUN = 'MA'
         AND IV_TYPE LIKE 'C__'
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
      SELECT * FROM ZGTMMT4501 WHERE IV_NO = TS_IV_NO.
        MOVE-CORRESPONDING ZGTMMT4501 TO GT_OUT.
        GT_OUT-MENGE = ZGTMMT4501-LFIMG.
        GT_OUT-MEINS = ZGTMMT4501-MTR_UNIT.
        GT_OUT-FLAG  = 'X'.
        APPEND GT_OUT.  CLEAR GT_OUT.
      ENDSELECT.
*/.........< APPROVAL INFO >
      SELECT SINGLE APP_ID1 APP_NM1 APP_ID2 APP_NM2
        FROM ZLET0003
        INTO (WA_0110-APP_ID1, WA_0110-APP_NM1,
              WA_0110-APP_ID2, WA_0110-APP_NM2)
        WHERE IV_NO = TS_IV_NO.
      CONCATENATE '합의자:' WA_0110-APP_NM1  INTO WA-APPLINE.
      CONCATENATE WA-APPLINE '/' '승인자:'   INTO WA-APPLINE
                                             SEPARATED BY SPACE.
      CONCATENATE WA-APPLINE WA_0110-APP_NM2 INTO WA-APPLINE.
    ENDIF.
  ELSEIF TT_FLAG = 'X' AND TT_FLAG2 = 'X'.       "자체개선 52275-변경
    WA-IV_TYPE = TS_IV_TYPE.
    SELECT SINGLE IV_TYPE_NM INTO WA-IV_TYPE_NM
      FROM ZLET0007
     WHERE GUBUN = 'MA'
       AND IV_TYPE LIKE 'C__'
       AND IV_TYPE = WA-IV_TYPE.
    GV_IV_TYPE    = WA-IV_TYPE.
    GV_IV_TYPE_NM = WA-IV_TYPE_NM.
    WA-BUKRS = TS_BUKRS.
    PERFORM GET_BUKRS_DESC USING WA-BUKRS WA-BUTXT.
    GV_BUKRS = WA-BUKRS.
    CLEAR: TS_IV_TYPE, TS_BUKRS, TT_FLAG.
*-{자체개선 52275 - 추가
  ELSEIF TT_FLAG = ' ' AND TT_FLAG2 = ' '.
    MESSAGE I000 DISPLAY LIKE 'E' WITH 'ZLE0019T를 먼저 실행해 주세요'.
    LEAVE TO SCREEN 0.
*-}자체개선 52275_2014.11.07
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
*          CLEAR : WA-ADDRS, WA-KUNNR1_T.
        ENDIF.
      WHEN 'WA-TEXT1'.
        IF GV_BUKRS <> '1000'.
          SCREEN-REQUIRED = 0.
          MODIFY SCREEN.
        ENDIF.
*기능개선181725 LS전선 구매처비활성화
*      WHEN 'WA-KUNNR'.
*        IF GV_BUKRS = '1000'.
*          SCREEN-INPUT = 0.
*          MODIFY SCREEN.
*        ENDIF.
      WHEN 'WA-KUNNR1'.
        IF WA-CHANGE = 'X'.
          SCREEN-INPUT = 0.
          MODIFY SCREEN.
        ENDIF.
      WHEN 'WA-KUNNR1_T'.
        IF WA-CHANGE = 'X'.
          SCREEN-INPUT = 1.
          MODIFY SCREEN.
        ELSE.
          SCREEN-INPUT = 0.
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

        " 반입예정 체크박스 추가. 2017.03.29. MJLEE
      WHEN 'WA-RETURN_YN'.
        IF WA-IV_TYPE = 'C06' OR WA-IV_TYPE = 'C05'.
          SCREEN-INPUT  = 0.
          SCREEN-ACTIVE = 1.
        ELSE.
          SCREEN-ACTIVE = 0.
        ENDIF.
        MODIFY SCREEN.

*기능개선181725 H.M.LIM 20107.02.13
    ENDCASE.

    IF WA-BUKRS <> '1000' AND SCREEN-GROUP1 = 'G11'.
      SCREEN-INPUT     = 0.
      SCREEN-INVISIBLE = 1.

      MODIFY SCREEN.
    ENDIF.
  ENDLOOP.
*-}기능개선 48112_2014.10.15

  IF WA-IV_TYPE = 'C06' OR WA-IV_TYPE = 'C05'.
    WA-RETURN_YN = 'X'.
  ELSE.
    CLEAR WA-RETURN_YN.
  ENDIF.

  IF TS_FLAG1 = 'Y'.
    LOOP AT SCREEN.
      CASE SCREEN-NAME.
        WHEN 'WA-WERKS' OR 'WA-PERNR' OR 'WA-TEXT1' OR 'WA-KUNNR' OR
             'WA-KUNNR1' OR 'WA-ADDRS' OR 'WA-CHANGE' OR 'WA-KUNNR1_T' OR
             'DELE'.
          SCREEN-INPUT = 0.
          MODIFY SCREEN.
      ENDCASE.
    ENDLOOP.
  ENDIF.

  IF GV_FLAG = ' '.
    WA-CREATE_DATE = SY-DATUM.
    GV_FLAG = 'X'.
  ENDIF.

  DESCRIBE TABLE GT_OUT     LINES TC01-LINES.
  TC01-LINES = TC01-LINES + 14.

ENDMODULE.                 " INIT  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  SET_CURSOR  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE SET_CURSOR OUTPUT.

  SET CURSOR FIELD G_CURSOR_FIELD LINE I_CURSOR_LINE.

ENDMODULE.                 " SET_CURSOR  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  SCREEN_CHANGE  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE SCREEN_CHANGE OUTPUT.

  DATA: WA_COLS  LIKE LINE OF TC01-COLS.

  IF TS_FLAG1 = 'Y'.
    LOOP AT SCREEN.
      IF SCREEN-NAME = 'GT_OUT-ASSET_NO'   OR
         SCREEN-NAME = 'GT_OUT-ASSET_NM'   OR
         SCREEN-NAME = 'GT_OUT-ASSET_SPEC' OR
         SCREEN-NAME = 'GT_OUT-MENGE'      OR
         SCREEN-NAME = 'GT_OUT-ASSET_AMT'  OR
         SCREEN-NAME = 'GT_OUT-MEINS'      OR
         SCREEN-NAME = 'GT_OUT-ASSET_ETC'.
        SCREEN-INPUT = 0.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.
  ELSEIF GT_OUT-FLAG = 'X'.
    LOOP AT SCREEN.
      IF SCREEN-NAME = 'GT_OUT-ASSET_NO'.
        IF GT_OUT-ASSET_NO <> ' '.
          SCREEN-INPUT = 0.
        ENDIF.
      ELSEIF SCREEN-NAME = 'GT_OUT-ASSET_NM'.
        IF GT_OUT-ASSET_NM <> ' '.
          SCREEN-INPUT = 0.
        ENDIF.
      ELSEIF SCREEN-NAME = 'GT_OUT-ASSET_SPEC'.
        IF GT_OUT-ASSET_SPEC <> ' '.
          SCREEN-INPUT = 0.
        ENDIF.
*-{기능개선 48112 - 삭제
*      ELSEIF SCREEN-NAME = 'GT_OUT-MENGE'.
*        IF GT_OUT-MENGE <> ' '.
*          SCREEN-INPUT = 0.
*        ENDIF.
*-}기능개선 48112_2014.10.29
      ELSEIF SCREEN-NAME = 'GT_OUT-ASSET_AMT'.
        IF GT_OUT-ASSET_AMT <> ' '.
          SCREEN-INPUT = 0.
        ENDIF.
      ELSEIF SCREEN-NAME = 'GT_OUT-MEINS'.
        IF GT_OUT-MEINS <> ' '.
          SCREEN-INPUT = 0.
        ENDIF.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.
  ENDIF.

  " 반입예정일 추가. 2017.03.19. MJLEE.
  IF WA-IV_TYPE <> 'C06' AND WA-IV_TYPE <> 'C05'.
    LOOP AT TC01-COLS INTO WA_COLS
                     WHERE SCREEN-NAME = 'GT_OUT-RETURN_DUE_DATE'.
      WA_COLS-INVISIBLE       = '1'.
      WA_COLS-SCREEN-REQUIRED = 0.
      MODIFY TC01-COLS FROM WA_COLS.
    ENDLOOP.
  ENDIF.

*{ SRM2203-07882 - s 엠트론의 경우에는 해당 필드들
*                     마스터데이터에서 가져온 값만(수기입력 불가)
  IF GV_BUKRS = '3000'.
    LOOP AT SCREEN.
      IF  SCREEN-NAME = 'GT_OUT-ASSET_NM'   OR
          SCREEN-NAME = 'GT_OUT-ASSET_SPEC' OR
          SCREEN-NAME = 'GT_OUT-ASSET_AMT'  OR
          SCREEN-NAME = 'GT_OUT-MEINS'.
        SCREEN-INPUT = 0.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.
  ENDIF.
*} SRM2203-07882 - e

ENDMODULE.                 " SCREEN_CHANGE  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  STATUS_0110  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE STATUS_0110 OUTPUT.

  SET PF-STATUS '0110'.
  SET TITLEBAR '0110'.

ENDMODULE.                 " STATUS_0110  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  SCREEN_MODIFY_0100  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE SCREEN_MODIFY_0100 OUTPUT.

  LOOP AT TC01-COLS INTO COL_DATA .
    IF GV_BUKRS <> '3000'  OR
       ( GV_IV_TYPE <> 'C05' AND GV_IV_TYPE <> 'C06').
      IF COL_DATA-SCREEN-NAME = 'GT_OUT-GDLGRP' OR
         COL_DATA-SCREEN-NAME = 'GT_OUT-GDLGRP_TXT'.
        COL_DATA-SCREEN-INPUT = '0'.
        COL_DATA-INVISIBLE    = '1'.
        COL_DATA-SCREEN-REQUIRED    = '0'.
      ENDIF.
    ENDIF.


*{ 기능개선 251794 - 추가
*___회사코드 '3000'이 아닌 경우 통문사유 입력 필드 비가시화
    IF WA-BUKRS <> '3000' AND COL_DATA-SCREEN-GROUP3 = 'G33'.
      COL_DATA-INVISIBLE = '1'.
    ENDIF.
*} 기능개선 251794 - 추가



    MODIFY TC01-COLS INDEX SY-TABIX FROM COL_DATA.
  ENDLOOP.

**{S SRM2209-05218 23.09.2022 10:19:10
  LOOP AT SCREEN.
    IF GV_BUKRS = '3000' AND SCREEN-GROUP1 = 'S1'.
      IF GV_LGORT_FLAG = 'X'.
        SCREEN-INPUT = '1'.
      ELSE.
        SCREEN-INPUT = '0'.
      ENDIF.
      MODIFY SCREEN.
    ENDIF.
  ENDLOOP.
ENDMODULE.                    "SCREEN_MODIFY_0100 OUTPUT
**}E SRM2209-05218   " SCREEN_MODIFY_0100  OUTPUT
