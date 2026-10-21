*&---------------------------------------------------------------------*
*& Include          ZGTMMR2020F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form F_SET_SCREEN_ATTR_1000
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_SET_SCREEN_ATTR_1000 .

  LOOP AT SCREEN.

    CASE SCREEN-GROUP1.

      WHEN 'DIS'.
        IF P_DISP EQ ABAP_TRUE.
          SCREEN-ACTIVE = 1.
        ELSE.
          SCREEN-ACTIVE = 0.
        ENDIF.
        MODIFY SCREEN.

      WHEN 'BAN'.   "구매요청
        IF P_NEW EQ ABAP_TRUE.
          SCREEN-ACTIVE = 0.
        ELSE.
          SCREEN-ACTIVE = 1.
        ENDIF.
        MODIFY SCREEN.

    ENDCASE.

  ENDLOOP.

ENDFORM.

*&---------------------------------------------------------------------*
*& FORM CHECK_AUTH
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
FORM CHECK_AUTH .

  AUTHORITY-CHECK OBJECT 'ZCBO_MM001'
               ID 'BUKRS' FIELD P_BUKRS.

  CHECK SY-SUBRC <> 0.

  SET CURSOR FIELD 'P_BUKRS'.
  MESSAGE E172 WITH P_BUKRS. "회사코드[&] 작업권한을 확인하세요.

  AUTHORITY-CHECK OBJECT 'ZCBO_SD001'
               ID 'VKORG' FIELD P_VKORG.

  CHECK SY-SUBRC <> 0.

  SET CURSOR FIELD 'P_VKORG'.
  MESSAGE E173 WITH P_VKORG. "영업조직[&] 작업권한을 확인하세요.

  IF S_VKBUR[] IS NOT INITIAL.
    LOOP AT S_VKBUR INTO DATA(LS_VKBUR).
      AUTHORITY-CHECK OBJECT 'ZCBO_SD003'
                   ID 'VKBUR' FIELD LS_VKBUR-LOW.

      CHECK SY-SUBRC <> 0.

      SET CURSOR FIELD 'S_VKBUR-LOW'.
      MESSAGE E174 WITH S_VKBUR-LOW. " 영업팀[&] 작업권한을 확인하세요.
    ENDLOOP.
  ENDIF.

  IF S_VKGRP[] IS NOT INITIAL.
    LOOP AT S_VKGRP INTO DATA(LS_VKGRP).
      AUTHORITY-CHECK OBJECT 'ZCBO_SD003'
                   ID 'VKGRP' FIELD LS_VKGRP-LOW.

      CHECK SY-SUBRC <> 0.

      SET CURSOR FIELD 'S_VKGRP-LOW'.
      MESSAGE E175 WITH S_VKGRP-LOW. "영업그룹[&] 작업권한을 확인하세요.
    ENDLOOP.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_AT_SCREEN_ON_BUKRS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_AT_SCREEN_ON_VKORG .

  CHECK SY-UCOMM EQ 'ONLI'. "실행 인 경우 만 점검
  CLEAR GV_ERROR.

  "필수 값 점검
  IF P_VKORG IS INITIAL.
    GV_ERROR = ABAP_TRUE.
    MESSAGE E278(00) WITH TEXT-F01.
  ENDIF.

  CHECK GV_ERROR EQ SPACE.

  "유효성 점검
  SELECT SINGLE
    VKORG
    FROM TVKO
    WHERE VKORG EQ @P_VKORG
    INTO @DATA(LV_CHK).
  CHECK SY-SUBRC NE 0.
  GV_ERROR = ABAP_TRUE.
  MESSAGE E013 WITH TEXT-F01.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form F_START_OF_SELECTION
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_START_OF_SELECTION .
  "오류가 있으면 종료
  IF GV_ERROR EQ ABAP_TRUE.
    LEAVE LIST-PROCESSING.
  ENDIF.

* DATA SELECT
  CASE ABAP_TRUE.
    WHEN P_NEW. "생성
      PERFORM F_GET_DATA_NEW.

    WHEN P_DISP. "조회/변경
      PERFORM F_GET_DATA_DISP.

    WHEN P_PRINT. "출력
      PERFORM F_GET_DATA_PRINT.

  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form F_END_OF_SELECTION
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_END_OF_SELECTION .

*  CASE ABAP_TRUE.
*    WHEN P_NEW.
*  IF GT_SKID[] IS INITIAL.
*    MESSAGE S002 DISPLAY LIKE GC_E.
*    LEAVE LIST-PROCESSING.
*  ENDIF.
*  CALL SCREEN 100.
*    WHEN P_DISP.
*      IF GT_SKID[] IS INITIAL.
*        MESSAGE S002 DISPLAY LIKE GC_E.
*        LEAVE LIST-PROCESSING.
*      ENDIF.
*      CALL SCREEN 100.
*  ENDCASE.

  IF GT_SKID[] IS INITIAL.
    MESSAGE S002 DISPLAY LIKE GC_E.
    LEAVE LIST-PROCESSING.
  ENDIF.
  CALL SCREEN 100.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form F_GET_DATA_NEW
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_GET_DATA_NEW .

  "초기화
  CLEAR:
    GT_SKID[].

  " -- DATA SELECT
  WITH +MAX_VBEP AS (
    SELECT VBELN, POSNR, MAX( EDATU ) AS EDATU
      FROM VBEP
     GROUP BY VBELN, POSNR
  )
    SELECT VK~VBELN,  VK~KUNNR, VK~VKORG, VK~VTWEG, VK~SPART, VK~VKGRP,  VK~VKBUR,
                 VP~POSNR, VP~MATNR, VP~ARKTX,  VP~KWMENG,  VP~VRKME, VP~CUOBJ, VP~WERKS,
                 CV~SUL_NO, CV~REV_SEQ, CV~COLOR, CV~WELENG,  CV~WECNT, CV~MATNR_DRUM,
                 CV~MATNR_SKID, CV~SKID_YN, CV~PACKMARK,
                 KN~NAME1, M~MEINS, VE~EDATU, Z1~BANFN
      FROM VBAK AS VK
        JOIN VBAP AS VP ON VK~VBELN EQ VP~VBELN
        JOIN MARA AS M ON VP~MATNR EQ M~MATNR
        JOIN +MAX_VBEP AS VE ON VK~VBELN EQ VE~VBELN
                                           AND VP~POSNR EQ VE~POSNR
        JOIN ZGTMM_CV_SO_VCVALUE_SKID	AS CV ON VK~VBELN EQ CV~VBELN
                                                                          AND VP~POSNR EQ CV~POSNR
       LEFT OUTER JOIN KNA1 AS KN ON VK~KUNNR EQ KN~KUNNR
                                                     AND KN~SPRAS EQ @SY-LANGU
      LEFT OUTER JOIN ZGTMMT2020 AS Z1 ON VK~VBELN EQ Z1~VBELN
                                                              AND VP~POSNR EQ Z1~POSNR
   WHERE VK~VKORG = @P_VKORG
      AND VK~VKBUR IN @S_VKBUR
      AND VK~VKGRP IN @S_VKGRP
      AND VK~KUNNR IN @S_KUNNR
      AND VK~VBELN IN @S_VBELN
      AND VP~WERKS IN @S_WERKS
      AND VE~EDATU IN @S_EDATU
      AND VP~MATNR IN @S_MATNR
      AND VP~ABGRU EQ @SPACE
      AND CV~SKID_YN EQ @GC_Y               " SKID 여부
      AND CV~PACKMARK EQ @GC_CM        " SKID 확정 여부
      AND CV~MATNR_SKID NE @SPACE      " SKID 드럼 코드 존재 여부
      AND ( Z1~BANFN IS NULL OR Z1~BANFN EQ @SPACE )
      ORDER BY VK~VBELN, VP~POSNR
    INTO CORRESPONDING FIELDS OF TABLE @GT_SKID.


  " LINE별 추가 데이터 (CBM 등)
  PERFORM F_GET_LINE_DATA.

  " SKID 구성표 데이터
  PERFORM F_GET_SKID_DATA.

  "

ENDFORM.
*&---------------------------------------------------------------------*
*& Form F_GET_DATA_DISP
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_GET_DATA_DISP .
  DATA:
    LT_WHERE TYPE TABLE OF STRING,
    LV_WHERE TYPE STRING.

  "초기화
  CLEAR:
    GT_SKID[].

  " --CHECKBOX에 따라 다르게 SELECT

  IF P_BEF IS INITIAL AND P_AFT IS INITIAL.
    MESSAGE S000 DISPLAY LIKE 'E' WITH TEXT-E04.
    LEAVE LIST-PROCESSING.

  ELSEIF P_BEF EQ ABAP_TRUE AND P_AFT EQ ABAP_TRUE. " 전체조회

  ELSEIF P_BEF EQ ABAP_TRUE. "구매요청 미생성
    LV_WHERE = |( Z1~BANFN IS NULL OR Z1~BANFN EQ @SPACE )|.
    APPEND LV_WHERE TO LT_WHERE.

  ELSEIF P_AFT EQ ABAP_TRUE. "구매요청 생성
    LV_WHERE = |( Z1~BANFN NE @SPACE )|.
    APPEND LV_WHERE TO LT_WHERE.
  ENDIF.


  " -- DATA SELECT
  WITH +MAX_VBEP AS (
    SELECT VBELN, POSNR, MAX( EDATU ) AS EDATU
      FROM VBEP
     GROUP BY VBELN, POSNR
  )
    SELECT VK~VBELN,  VK~KUNNR, VK~VKORG, VK~VTWEG, VK~SPART, VK~VKGRP,  VK~VKBUR,
                 VP~POSNR, VP~MATNR, VP~ARKTX,  VP~KWMENG,  VP~VRKME, VP~CUOBJ, VP~WERKS,
                 CV~SUL_NO, CV~REV_SEQ, CV~COLOR, CV~WELENG,  CV~WECNT, CV~MATNR_DRUM,
                 CV~MATNR_SKID, CV~SKID_YN, CV~PACKMARK,
                 KN~NAME1, M~MEINS, VE~EDATU, Z1~BANFN, Z1~BNFPO,
                 EB~EBELN, EB~LFDAT, EB~KOSTL, EB~SAKTO, EB~KNTTP, EB~AFNAM,
                 EB~EKGRP, EB~LGORT, EB~EKORG, EB~LIFNR, EB~MWSKZ, EB~PEINH
      FROM VBAK AS VK
        JOIN VBAP AS VP ON VK~VBELN EQ VP~VBELN
        JOIN MARA AS M ON VP~MATNR EQ M~MATNR
        JOIN +MAX_VBEP AS VE ON VK~VBELN EQ VE~VBELN
                                           AND VP~POSNR EQ VE~POSNR
        JOIN ZGTMM_CV_SO_VCVALUE_SKID	AS CV ON VK~VBELN EQ CV~VBELN
                                                                          AND VP~POSNR EQ CV~POSNR
      LEFT OUTER JOIN KNA1 AS KN ON VK~KUNNR EQ KN~KUNNR
                                                     AND KN~SPRAS EQ @SY-LANGU
      LEFT OUTER JOIN ZGTMMT2020 AS Z1 ON VK~VBELN EQ Z1~VBELN
                                                              AND VP~POSNR EQ Z1~POSNR
      LEFT OUTER JOIN EBAN AS EB ON Z1~BANFN EQ EB~BANFN
                                                      AND Z1~BNFPO EQ EB~BNFPO
   WHERE VK~VKORG = @P_VKORG
      AND VK~VKBUR IN @S_VKBUR
      AND VK~VKGRP IN @S_VKGRP
      AND VK~KUNNR IN @S_KUNNR
      AND VK~VBELN IN @S_VBELN
      AND VP~WERKS IN @S_WERKS
      AND VE~EDATU IN @S_EDATU
      AND VP~MATNR IN @S_MATNR
      AND VP~ABGRU EQ @SPACE
      AND CV~SKID_YN EQ @GC_Y               " SKID 여부
      AND CV~PACKMARK EQ @GC_CM        " SKID 확정 여부
*      AND CV~MATNR_SKID NE @SPACE    "SKID 드럼 코드 존재 여부 -> 조회모드에서는 주석
      AND EB~BANFN IN @S_BANFN      "구매요청 조회 조건 추가
      AND (LT_WHERE)
    ORDER BY VK~VBELN, VP~POSNR
    INTO CORRESPONDING FIELDS OF TABLE @GT_SKID.

* LINE별 추가 데이터 (CBM 등)
  PERFORM F_GET_LINE_DATA.

* SKID 구성표 데이터
  PERFORM F_GET_SKID_DATA.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form F_GET_LINE_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- GT_SKID
*&---------------------------------------------------------------------*
FORM F_GET_LINE_DATA.

  DATA:
    LT_OUTPUT TYPE STANDARD TABLE OF ZGTEDSIF0034,
    LS_OUTPUT TYPE ZGTEDSIF0034.

  CLEAR:
      LT_OUTPUT[],
      LS_OUTPUT.

  " -- CBM SELECT
  MOVE-CORRESPONDING GT_SKID TO LT_OUTPUT.

  CALL FUNCTION 'ZGTED_SELECT_CBM_DATA'
    TABLES
      OT_OUTPUT = LT_OUTPUT.

  LOOP AT GT_SKID ASSIGNING FIELD-SYMBOL(<LS_SKID>).
    CLEAR:
    LS_OUTPUT.

    IF P_NEW EQ ABAP_TRUE.  "신규 생성일때만 코드마스터 기본값 사용
      " -- 코드마스터
      SELECT SINGLE *
        FROM ZGTPPT1010
       WHERE MODULE_KIND = 'MM'
           AND CODEGRP = '0750'
           AND FLD_01 EQ @P_VKORG
           AND FLD_02 EQ @<LS_SKID>-WERKS
        INTO @DATA(LS_1010).

      LS_1010-FLD_07 = CONV LIFNR( |{ LS_1010-FLD_07 ALPHA = IN }| ).
      LS_1010-FLD_10 = CONV KOSTL( |{ LS_1010-FLD_10 ALPHA = IN }| ).
      LS_1010-FLD_11 = CONV SAKNR( |{ LS_1010-FLD_11 ALPHA = IN }| ).

      "--계정/코스트센터/공급업체 -> 단일값으로 수정불가
      <LS_SKID>-EKGRP = LS_1010-FLD_03.
      <LS_SKID>-LGORT = LS_1010-FLD_04.
      <LS_SKID>-KNTTP = LS_1010-FLD_05.
      <LS_SKID>-EKORG = LS_1010-FLD_06.
      <LS_SKID>-LIFNR = LS_1010-FLD_07.
      <LS_SKID>-MWSKZ = LS_1010-FLD_08.
      <LS_SKID>-PEINH = LS_1010-FLD_09.
      <LS_SKID>-KOSTL = LS_1010-FLD_10.
      <LS_SKID>-SAKTO = LS_1010-FLD_11.
      <LS_SKID>-ABLAD = LS_1010-FLD_12.
    ENDIF.

    "--CBM 값
    READ TABLE LT_OUTPUT INTO LS_OUTPUT WITH KEY VBELN = <LS_SKID>-VBELN POSNR = <LS_SKID>-POSNR.
    <LS_SKID>-OUT_WID = LS_OUTPUT-OUT_WID.
    <LS_SKID>-BARREL_DIA = LS_OUTPUT-BARREL_DIA.
    <LS_SKID>-BRGEW_DRUM = LS_OUTPUT-BRGEW.
    <LS_SKID>-GEWEI_DRUM = LS_OUTPUT-GEWEI.
    IF LS_OUTPUT-MSG_TYPE NE GC_S.
      <LS_SKID>-MESSAGE = LS_OUTPUT-MSG_TXT.
    ENDIF.

    "--DRUM&SKID 자재
    <LS_SKID>-MATNR_DRUM = |{ <LS_SKID>-MATNR_DRUM ALPHA = IN WIDTH = 18 }|.
    <LS_SKID>-MATNR_SKID = |{ <LS_SKID>-MATNR_SKID ALPHA = IN WIDTH = 18 }|.

    SELECT SINGLE MAKTX
      FROM MAKT
      INTO <LS_SKID>-MAKTX_DRUM
      WHERE MATNR EQ <LS_SKID>-MATNR_DRUM
      AND SPRAS EQ SY-LANGU.

    SELECT SINGLE MAKTX
      FROM MAKT
      INTO <LS_SKID>-MAKTX_SKID
      WHERE MATNR EQ <LS_SKID>-MATNR_SKID
      AND SPRAS EQ SY-LANGU.

    SELECT SINGLE MEINS
      FROM MARA
      INTO <LS_SKID>-MEINS_SKID
      WHERE MATNR EQ <LS_SKID>-MATNR_SKID.

    "--SKID 설계서용 중복 필드 값
    <LS_SKID>-BARREL_DIA_1 = <LS_SKID>-BARREL_DIA.
    <LS_SKID>-OUT_WID_1 = <LS_SKID>-OUT_WID.
    <LS_SKID>-WECNT_1 = <LS_SKID>-WECNT.

    "--STYLE 설정
    PERFORM F_SET_ALV_STYLE_GT_SKID CHANGING <LS_SKID>.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form F_GET_SKID_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_GET_SKID_DATA .
  DATA:
    LT_SO      TYPE STANDARD TABLE OF ZGTMMS1016,
    LT_SKID_FM TYPE STANDARD TABLE OF ZGTMMS1015,
    LS_SKID_FM TYPE ZGTMMS1015.

  CLEAR:
    LT_SO[],
    LT_SKID_FM[].

  MOVE-CORRESPONDING GT_SKID TO LT_SO.

  CALL FUNCTION 'ZGTMM_SELECT_SKID_DATA'
    EXPORTING
      I_VKORG = P_VKORG
    TABLES
      IT_SO   = LT_SO
      OT_SKID = LT_SKID_FM.

  LOOP AT GT_SKID ASSIGNING FIELD-SYMBOL(<LS_SKID>).
    CLEAR: LS_SKID_FM.
    READ TABLE LT_SKID_FM INTO LS_SKID_FM WITH KEY VBELN = <LS_SKID>-VBELN POSNR = <LS_SKID>-POSNR.

    <LS_SKID>-NTGEW = LS_SKID_FM-NTGEW.
    <LS_SKID>-NTGEW_SUM = LS_SKID_FM-NTGEW_SUM.
    <LS_SKID>-BRGEW = LS_SKID_FM-BRGEW.
    <LS_SKID>-BRGEW_SUM = LS_SKID_FM-BRGEW_SUM.
    <LS_SKID>-GEWEI = LS_SKID_FM-GEWEI.
    <LS_SKID>-FAR = LS_SKID_FM-FAR.
    <LS_SKID>-CHORD_A = LS_SKID_FM-CHORD_A.
    <LS_SKID>-BARREL_DIA_2 = LS_SKID_FM-BARREL_DIA_2.
    <LS_SKID>-OUT_WID_2 = LS_SKID_FM-OUT_WID_2.
    <LS_SKID>-BRGEW_2 = LS_SKID_FM-BRGEW_2.

    "--SKID 설계서용 중복 필드 값
    <LS_SKID>-BRGEW_1 = <LS_SKID>-BRGEW.

    IF LS_SKID_FM-TYPE NE GC_S.
      CHECK <LS_SKID>-MESSAGE IS INITIAL.
      <LS_SKID>-MESSAGE = LS_SKID_FM-CODE && LS_SKID_FM-MESSAGE.
    ENDIF.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form F_SET_ALV_STYLE_GT_SKID
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- <LS_SKID>
*&---------------------------------------------------------------------*
FORM F_SET_ALV_STYLE_GT_SKID  CHANGING PS_SKID TYPE TY_SKID.

  CLEAR PS_SKID-ZSTYLE[].

  CASE ABAP_TRUE.
      " 생성 -> PR 생성된 경우 납품요청일 필드 수정 불가
    WHEN P_NEW.
      IF PS_SKID-BANFN NE SPACE.
        PS_SKID-ZSTYLE[] = VALUE #( ( FIELDNAME = 'LFDAT' STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED ) ).
      ENDIF.

      " 조회/취소 -> 구매요청 미존재 OR 구매오더 존재하는 경우 체크 필드 수정 불가
    WHEN P_DISP.
      IF PS_SKID-EBELN NE SPACE OR PS_SKID-BANFN EQ SPACE.
        PS_SKID-ZSTYLE[] = VALUE #( ( FIELDNAME = 'CHECK' STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED ) ).
      ENDIF.

  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form F_REFRESH_RESULT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_REFRESH_RESULT .

  "--오류(LED RED)건 초기화
  LOOP AT GT_SKID ASSIGNING FIELD-SYMBOL(<LS_SKID>) WHERE STATUS = ICON_LED_RED.
    <LS_SKID>-STATUS = SPACE.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form F_CHECK_BUDGET
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_CHECK_BUDGET USING PT_SKID_CHK TYPE TY_T_SKID
                                        CHANGING CV_CHECK.

  " ZGTMMR2010 로직 참고
  " 2026.06.25SKID는 PR 단계에서 단가 입력 불가하므로 PO에서 예산점검하기로 협의 -> 전체 주석처리

*  DATA:
*    L_MSG   TYPE C LENGTH 120,
*    LS_EBAN TYPE EBAN,
*    LS_EBKN TYPE EBKN,
*    LT_EBAN TYPE STANDARD TABLE OF EBAN,
*    LT_EBKN TYPE STANDARD TABLE OF EBKN.
*
*  CLEAR:
*    LS_EBAN,
*    LS_EBKN.
*
*  LS_EBAN-BANFN += 1.
*  LS_EBAN-BSTYP = 'NB'.
*
*
*  SELECT SINGLE
*    KOKRS
*    FROM TKA02
*    WHERE BUKRS EQ @P_BUKRS
*    INTO @DATA(LV_KOKRS).
*
**  "- 동일한 계정지정범주 끼리만 예산점검 가능하게 함  -> SKID 는 항상 동일하므로 주석처리
**  DATA LV_KNTTP TYPE EBAN-KNTTP VALUE '$'.
**  LOOP AT LT_ROW_ID ASSIGNING <LS_ROW_ID>.
**    READ TABLE GT_OPT2 ASSIGNING <LS_SKID_CHK> INDEX <LS_ROW_ID>-ROW_ID.
**    CHECK SY-SUBRC EQ 0.
**    IF LV_KNTTP EQ '$'.
**      LV_KNTTP = <LS_SKID_CHK>-KNTTP.
**    ENDIF.
**
**    IF LV_KNTTP NE <LS_SKID_CHK>-KNTTP.
***동일한 계정지정 범주에 대해 예산 점검 가능합니다
**      MESSAGE E000 WITH TEXT-E15.
**    ENDIF.
**  ENDLOOP.
*
*
*  LOOP AT PT_SKID_CHK ASSIGNING FIELD-SYMBOL(<LS_SKID_CHK>).
*
**구매 요청 번호                 BANFN Default = "1" IM_T-EBAN
**품목                 BNFPO 품목 라인별 10단위 증가 채번
**문서유형                 BSTYP Default = "NB"
**계정 지정범주                  KNTTP ALV-KNTTP
**품목범주                 PSTYP ALV-PSTYP
**자재번호                 MATNR ALV-MATNR
**자재그룹                 MATKL ALV-MATKL
**플랜트                  WERKS ALV-WERKS
**저장위치                 LGORT ALV-LGORT
**요청 수량                  MENGE ALV-MENGE
**요청 단위                  MEINS ALV-MEINS
**납품 요청일                 LFDAT ALV-LFDAT
**구매조직                 EKORG ALV-EKORG
**구매그룹                 EKGRP ALV-EKGRP
**요청자                  AFNAM ALV-AFNAM
**희망 공급업체                  LIFNR ALV-LIFNR
**고정 공급업체                  FLIEF ALV-FLIEF
**예상 가격                  PREIS ALV-PREIS
**가격 통화                  WAERS ALV-WAERS
**가격 단위                  PEINH ALV-PEINH
**요청일                  BADAT SY-DATUM
**부채관련품목                 XOBLR Default = "X"
*
*
*    LS_EBAN-BNFPO += 10.
*    LS_EBAN-KNTTP = <LS_SKID_CHK>-KNTTP.
*    LS_EBAN-PSTYP = <LS_SKID_CHK>-PSTYP.
*    LS_EBAN-MATNR = <LS_SKID_CHK>-MATNR.
*    LS_EBAN-MATKL = <LS_SKID_CHK>-MATKL.
*    LS_EBAN-WERKS = <LS_SKID_CHK>-WERKS.
*    LS_EBAN-LGORT = <LS_SKID_CHK>-LGORT.
*    LS_EBAN-MENGE = <LS_SKID_CHK>-MENGE.
*    LS_EBAN-MEINS = <LS_SKID_CHK>-MEINS.
*    LS_EBAN-LFDAT = <LS_SKID_CHK>-LFDAT.
*    LS_EBAN-EKORG = <LS_SKID_CHK>-EKORG.
*    LS_EBAN-EKGRP = <LS_SKID_CHK>-EKGRP.
*    LS_EBAN-AFNAM = <LS_SKID_CHK>-AFNAM.
*    LS_EBAN-LIFNR = <LS_SKID_CHK>-LIFNR.
*    LS_EBAN-FLIEF = <LS_SKID_CHK>-FLIEF.
*    LS_EBAN-PREIS = <LS_SKID_CHK>-PREIS.
*    LS_EBAN-WAERS = <LS_SKID_CHK>-WAERS.
*    LS_EBAN-PEINH = <LS_SKID_CHK>-PEINH.
*    LS_EBAN-BADAT = SY-DATUM.
*    LS_EBAN-XOBLR = ABAP_TRUE.
*    APPEND LS_EBAN TO LT_EBAN.
*
**구매 요청 번호                 BANFN Default = "1"
**품목                 BNFPO 품목 라인별 10단위 증가 채번
**영업오더                 VBELN ALV-VBELN
**영업오더품목                 VBELP ALV-VBELP
**코스트센터                  KOSTL ALV-KOSTL
**G/L 계정                 SAKTO ALV-SAKTO
**자산번호                 ANLN1 ALV-ANLN1
**오더번호                 AUFNR ALV-AUFNR
**WBS 코드                 PS_PSP_PNR  ALV-PS_PSP_PNR
**하역지점                 ABLAD ALV-ABLAD
**수령인                  WEMPF ALV-WEMPF
**관리회계영역                 KOKRS ALV-KOKRS
*
*    LS_EBKN-BANFN = LS_EBAN-BANFN.
*    LS_EBKN-BNFPO = LS_EBAN-BNFPO.
**    LS_EBKN-VBELN = <LS_SKID_CHK>-VBELN.
**    LS_EBKN-VBELP = <LS_SKID_CHK>-VBELP.
*    LS_EBKN-KOSTL = <LS_SKID_CHK>-KOSTL.
*    LS_EBKN-SAKTO = <LS_SKID_CHK>-SAKTO.
*    LS_EBKN-ANLN1 = <LS_SKID_CHK>-ANLN1.
*    LS_EBKN-AUFNR = <LS_SKID_CHK>-AUFNR.
*    LS_EBKN-PS_PSP_PNR = <LS_SKID_CHK>-PS_PSP_PNR.
*    LS_EBKN-ABLAD = <LS_SKID_CHK>-ABLAD.
*    LS_EBKN-WEMPF = <LS_SKID_CHK>-WEMPF.
*    LS_EBKN-KOKRS = LV_KOKRS.
*    APPEND LS_EBKN TO LT_EBKN.
*
*  ENDLOOP.
*
**    4-1) 예산점검 버튼 변수 정의
**   SY-UCOMM = MECHEKMOC
**   4-2) 예산점검을 위한 PERFORM 문 호출
**     4-2-1) 호출전 MEMORY ID값 사전 clear
**     4-2-1) 아래 PERFOMR문 호출
**     PERFORM EXIT_FI_CHECK_BUDGET_RQ IN PROGRAM ZFII0010 IF FOUND
**                                            TABLES IM_T_EBAN
**                                                   IM_T_EBKN.
*
*  SY-UCOMM = 'MECHECKDOC'.
*  PERFORM EXIT_FI_CHECK_BUDGET_RQ IN PROGRAM ZFII0010 IF FOUND
*                                       TABLES LT_EBAN
*                                              LT_EBKN.
**4-3) 점검 결과(L_MSG) 값 POP-UP 창으로 표기
**   4-3-1) L-MSG 의 MEMORY ID값을 참조하여 보여줌
** 변수                  Type  Length
** L_MSG                 CHAR  120
**
**   : L_MSG <> "" 이면 L_MSG 값
**   : L_MSG = "" 이면 "구매요청 생성 가능합니다."
*  IMPORT L_MSG_AB TO L_MSG FROM MEMORY ID 'BUDGET_CHK'.
*  FREE MEMORY ID 'BUDGET_CHK'.
*
*  IF L_MSG IS INITIAL.
*
**    4-3) Perfomr문 실행 후 아래 Function 추가 호출 점검
**  CALL FUNCTION 'ME_STATISTICS_EBAN_RKO'
**    EXPORTING
**      I_REFRESH        = ' '
**      I_BEST           = ' '
**      I_AVC_PRUEFEN    = 'X'
**      I_FIRST_CALL     = ' '
**      I_COMPONENT      = ' '
**      I_INITIALIZE     = ' '
**      I_CO_SET_DATE    = 'X'
**      I_TRANS_DATE     = '00000000'
**      I_HELD_PO        = ' '
**      I_FLG_CHECK_ONLY = 'X'
**      I_NO_RWIN        = ' '
**    TABLES
**      T_EBAN           =IM_T-EBAN
**      T_EBKN           = IM_T-EBKN.
**
**  -> function 에서 점검된 오류 메시지인 경우도 Popup 메시지로 표기하여 보여줌
*    CALL FUNCTION 'MESSAGES_INITIALIZE'.
*    CALL FUNCTION 'ME_STATISTICS_EBAN_RKO'
*      EXPORTING
*        I_REFRESH        = ' '
*        I_BEST           = ' '
*        I_AVC_PRUEFEN    = 'X'
*        I_FIRST_CALL     = ' '
*        I_COMPONENT      = ' '
*        I_INITIALIZE     = ' '
*        I_CO_SET_DATE    = 'X'
*        I_TRANS_DATE     = '00000000'
*        I_HELD_PO        = ' '
*        I_FLG_CHECK_ONLY = 'X'
*        I_NO_RWIN        = ' '
*      TABLES
*        T_EBAN           = LT_EBAN
*        T_EBKN           = LT_EBKN.
*    CALL FUNCTION 'MESSAGES_STOP'
*      EXCEPTIONS
*        A_MESSAGE         = 1
*        E_MESSAGE         = 2
*        W_MESSAGE         = 3
*        I_MESSAGE         = 4
*        S_MESSAGE         = 5
*        DEACTIVATED_BY_MD = 6
*        OTHERS            = 7.
*
*    DATA LT_MESG TYPE TSMESG.
*    CALL FUNCTION 'MESSAGES_GIVE'
*      TABLES
*        T_MESG = LT_MESG.
*
*    LOOP AT  LT_MESG ASSIGNING FIELD-SYMBOL(<LS_MESG>).
*
*      CHECK <LS_MESG>-MSGTY EQ GC_E
*            OR <LS_MESG>-MSGTY EQ GC_A.
**            OR ( <LS_MESG>-MSGTY EQ GC_W AND LV_KNTTP EQ GC_F ). "- F 인경우만 W 유형 메세지 추가 " SKID는 모두 K
*
*      MESSAGE ID <LS_MESG>-ARBGB TYPE GC_S"<LS_MESG>-MSGTY
*          NUMBER <LS_MESG>-TXTNR WITH <LS_MESG>-MSGV1 <LS_MESG>-MSGV2 <LS_MESG>-MSGV3 <LS_MESG>-MSGV4
*                INTO L_MSG.
**      L_MSG = <LS_MESG>-TEXT.
*      EXIT.
*    ENDLOOP.
*  ENDIF.
*
*
***4-4) 버튼 선택 여부는 별도 내부 상태값으로 저장하고 구매요청 생성 버튼 선택시 예산점검버튼 실행 여부를 Check할때 사용
**  LOOP AT LT_ROW_ID ASSIGNING <LS_ROW_ID>.
**    READ TABLE GT_OPT2 ASSIGNING <LS_SKID_CHK> INDEX <LS_ROW_ID>-ROW_ID.
**    CHECK SY-SUBRC EQ 0.
**    "2. 변경 : KNTTP=F 인 경우 초과 메시지는 보여주고 구매요청 생성 가능하도록 변경
**    IF L_MSG IS INITIAL OR <LS_SKID_CHK>-KNTTP EQ GC_F.
**      <LS_SKID_CHK>-BGCHK = ABAP_TRUE.
**    ENDIF.
**  ENDLOOP.
**
**  IF L_MSG IS INITIAL.
**    L_MSG = TEXT-M03. "구매요청 생성 가능합니다.
**  ENDIF.
**
**  MESSAGE I000 WITH L_MSG.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form F_SEND_EMAIL
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PT_SKID_CHK
*&---------------------------------------------------------------------*
FORM F_SEND_EMAIL  USING    PT_SKID_CHK TYPE TY_T_SKID.

  DATA: LV_PERNR TYPE ZZPA0001-PERNR.

  "ZGTMMR2010 로직 참고
  "SKID PR은 PR 생성자와 상관없이 해당 구매그룹의 담당자를 승인담당자로 지정

  READ TABLE PT_SKID_CHK ASSIGNING FIELD-SYMBOL(<LS_SKID_CHK>) INDEX 1.

  " 1) 구매그룹 승인 담당자 조회
  SELECT SINGLE ANAME
    FROM ZGTMMT1020
  WHERE WERKS EQ @<LS_SKID_CHK>-WERKS
      AND EKGRP EQ @<LS_SKID_CHK>-EKGRP     "코드마스터 구매그룹 단일값
      INTO @DATA(LV_ANAME).

  " 사용자 ID(사번) ALPHA CONVERSION
  DATA(LV_ANAME2) = CONDENSE( LV_ANAME ).

  IF LV_ANAME2 CO '0123456789'.
    LV_PERNR = LV_ANAME2.
    LV_PERNR = |{ LV_PERNR ALPHA = IN }|.
  ENDIF.

  "2) 승인 담당자 이메일 정보 추출
  SELECT SINGLE
    USRID
    FROM ZPA0105
    WHERE PERNR EQ @LV_PERNR
    AND SUBTY EQ '0007'
    AND ENDDA EQ '99991231'
    INTO @DATA(LV_SYSID).
  IF LV_PERNR IS INITIAL OR LV_SYSID IS INITIAL.
    MESSAGE S000 DISPLAY LIKE GC_E WITH TEXT-E07. "구매그룹의 승인 담당자 정보를 찾을 수 없습니다.
    EXIT.
  ENDIF.



  DATA:
    LV_EMAIL     TYPE AD_SMTPADR,
    LV_HEAD_TEXT TYPE SO_OBJ_DES,
    LT_MSG       TYPE BCSY_TEXT,
    LV_RETURN    TYPE C LENGTH 1,
    LV_MESSAGE   TYPE C LENGTH 100.

  LV_EMAIL = LV_SYSID.
  LV_HEAD_TEXT = TEXT-Z01.

  "3) 이메일 본문 내용 구성
*	: ALV에서 생성된 구매요청번호,생성자이름,요청일자 정보를 리스트 형태로 구성

  DATA:
    LV_BANFN  TYPE EBAN-BANFN,
    LV_DATE_C TYPE C LENGTH 10.

  DATA:
    LT_APPR TYPE STANDARD TABLE OF ZGTMMT1070,
    LV_LINE TYPE SO_TEXT255,
    LT_BODY TYPE BCSY_TEXT.


  LV_LINE = |<html><body style="font-size:10">|.
  LT_BODY = VALUE #( BASE LT_BODY ( LINE = LV_LINE ) ).
  LV_LINE = |<p>{ TEXT-EM1 }</p>|.
  LT_BODY = VALUE #( BASE LT_BODY ( LINE = LV_LINE ) ).
  LV_LINE = |<p>SAP 메뉴 <strong>ZGTMMR2011</strong> 에서 확인 부탁드립니다. </p>|.
  LT_BODY = VALUE #( BASE LT_BODY ( LINE = LV_LINE ) ).
  LV_LINE = |<table border=1 STYLE="border-collapse: collapse;border-color: #000000;font-size:10" >|.
  LT_BODY = VALUE #( BASE LT_BODY ( LINE = LV_LINE ) ).

  LV_LINE = |<tr align="center" style="background-color: #B3B1B1" ><td width="150px"><strong>구매요청번호</strong></td>|.
  LT_BODY = VALUE #( BASE LT_BODY ( LINE = LV_LINE ) ).
  LV_LINE = |<td width="100px" ><strong>품목번호</strong></td>|.
  LT_BODY = VALUE #( BASE LT_BODY ( LINE = LV_LINE ) ).
  LV_LINE = |<td width="150px" ><strong>요청자</strong></td>|.
  LT_BODY = VALUE #( BASE LT_BODY ( LINE = LV_LINE ) ).
  LV_LINE = |<td width="150px" ><strong>요청일자</strong></td></tr>|.
  LT_BODY = VALUE #( BASE LT_BODY ( LINE = LV_LINE ) ).

  LOOP AT PT_SKID_CHK ASSIGNING <LS_SKID_CHK>.

    LV_LINE = |<tr><td align="center" >{ <LS_SKID_CHK>-BANFN ALPHA = OUT }</td>|. "구매 요청 번호
    LT_BODY = VALUE #( BASE LT_BODY ( LINE = LV_LINE ) ).
    LV_LINE = |<td align="center" >{ <LS_SKID_CHK>-BNFPO ALPHA = OUT }</td>|.   "품목 번호
    LT_BODY = VALUE #( BASE LT_BODY ( LINE = LV_LINE ) ).
    LV_LINE = |<td align="center" >{ <LS_SKID_CHK>-AFNAM }</td>|.   "요청자
    LT_BODY = VALUE #( BASE LT_BODY ( LINE = LV_LINE ) ).
    LV_LINE = |<td align="center" >{ <LS_SKID_CHK>-LFDAT+0(4) }.{ <LS_SKID_CHK>-LFDAT+4(2) }.{ <LS_SKID_CHK>-LFDAT+6(2) }</td></tr>|. "요청일자
    LT_BODY = VALUE #( BASE LT_BODY ( LINE = LV_LINE ) ).

    LT_APPR = VALUE #( BASE LT_APPR ( BANFN = <LS_SKID_CHK>-BANFN
                                                              BNFPO = <LS_SKID_CHK>-BNFPO
                                                              APPTYPE = GC_A
                                                              APPUSER = LV_PERNR ) ).

  ENDLOOP.

  LV_LINE = |</table></body></html>|.
  LT_BODY = VALUE #( BASE LT_BODY ( LINE = LV_LINE ) ).


  DATA:
    LV_CHECK       TYPE C LENGTH 1,
    LO_RECEIVER    TYPE REF TO IF_RECIPIENT_BCS,
    LO_EMAIL       TYPE REF TO CL_BCS,
    LO_EMAIL_BODY  TYPE REF TO CL_DOCUMENT_BCS,
    LX_EXCEPTION   TYPE REF TO CX_BCS,
    LV_SEND_RESULT TYPE C.

  TRY.
      LO_EMAIL = CL_BCS=>CREATE_PERSISTENT( ).

      LO_EMAIL_BODY = CL_DOCUMENT_BCS=>CREATE_DOCUMENT(
                      I_TYPE    = 'HTM'
                      I_TEXT    = LT_BODY
                      I_SUBJECT = LV_HEAD_TEXT ).

      LO_EMAIL->SET_DOCUMENT( LO_EMAIL_BODY ).

      LO_RECEIVER =
      CL_CAM_ADDRESS_BCS=>CREATE_INTERNET_ADDRESS( LV_EMAIL ).

      LO_EMAIL->ADD_RECIPIENT( I_RECIPIENT = LO_RECEIVER
                               I_EXPRESS = 'X' ).

      LO_EMAIL->SET_SEND_IMMEDIATELY( 'X' ).

      LO_EMAIL->SEND( EXPORTING I_WITH_ERROR_SCREEN = 'X'
                      RECEIVING RESULT = LV_SEND_RESULT ).
    CATCH CX_BCS INTO LX_EXCEPTION.
      LV_CHECK = GC_E.
  ENDTRY.

*3) 메일 발송 후 승인 요청 이력 테이블 업데이트

  LOOP AT LT_APPR ASSIGNING FIELD-SYMBOL(<LS_APPR>).
    IF LV_CHECK EQ GC_E.
      <LS_APPR>-MAILSEND = GC_N.
    ELSE.
      <LS_APPR>-MAILSEND = GC_Y.
    ENDIF.
    <LS_APPR>-ERDAT = SY-DATUM.
    <LS_APPR>-ERDAT_LOCAL = SY-DATLO.
    <LS_APPR>-ERTIM = SY-UZEIT.
    <LS_APPR>-ERTIM_LOCAL = SY-TIMLO.
  ENDLOOP.

  MODIFY ZGTMMT1070 FROM TABLE LT_APPR.
  COMMIT WORK.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form F_GET_DATA_PRINT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_GET_DATA_PRINT .

  "초기화
  CLEAR:
    GT_SKID[].

  " -- DATA SELECT
  WITH +MAX_VBEP AS (
    SELECT VBELN, POSNR, MAX( EDATU ) AS EDATU
      FROM VBEP
     GROUP BY VBELN, POSNR
  )
    SELECT VK~VBELN,  VK~KUNNR, VK~VKORG, VK~VTWEG, VK~SPART, VK~VKGRP,  VK~VKBUR,
                 VP~POSNR, VP~MATNR, VP~ARKTX,  VP~KWMENG,  VP~VRKME, VP~CUOBJ, VP~WERKS,
                 CV~SUL_NO, CV~REV_SEQ, CV~COLOR, CV~WELENG,  CV~WECNT, CV~MATNR_DRUM,
                 CV~MATNR_SKID, CV~SKID_YN, CV~PACKMARK,
                 KN~NAME1, M~MEINS, VE~EDATU, Z1~BANFN, Z1~BNFPO,
                 EB~EBELN, EB~LFDAT, EB~KOSTL, EB~SAKTO, EB~KNTTP, EB~AFNAM,
                 EB~EKGRP, EB~LGORT, EB~EKORG, EB~LIFNR, EB~MWSKZ, EB~PEINH
      FROM VBAK AS VK
        JOIN VBAP AS VP ON VK~VBELN EQ VP~VBELN
        JOIN MARA AS M ON VP~MATNR EQ M~MATNR
        JOIN +MAX_VBEP AS VE ON VK~VBELN EQ VE~VBELN
                                           AND VP~POSNR EQ VE~POSNR
        JOIN ZGTMM_CV_SO_VCVALUE_SKID	AS CV ON VK~VBELN EQ CV~VBELN
                                                                          AND VP~POSNR EQ CV~POSNR
      LEFT OUTER JOIN KNA1 AS KN ON VK~KUNNR EQ KN~KUNNR
                                                     AND KN~SPRAS EQ @SY-LANGU
      LEFT OUTER JOIN ZGTMMT2020 AS Z1 ON VK~VBELN EQ Z1~VBELN
                                                              AND VP~POSNR EQ Z1~POSNR
      LEFT OUTER JOIN EBAN AS EB ON Z1~BANFN EQ EB~BANFN
                                                      AND Z1~BNFPO EQ EB~BNFPO
   WHERE VK~VKORG = @P_VKORG
      AND VK~VKBUR IN @S_VKBUR
      AND VK~VKGRP IN @S_VKGRP
      AND VK~KUNNR IN @S_KUNNR
      AND VK~VBELN IN @S_VBELN
      AND VP~WERKS IN @S_WERKS
      AND VE~EDATU IN @S_EDATU
      AND VP~MATNR IN @S_MATNR
      AND VP~ABGRU EQ @SPACE
      AND CV~SKID_YN EQ @GC_Y               " SKID 여부
      AND CV~PACKMARK EQ @GC_CM        " SKID 확정 여부
      AND CV~MATNR_SKID NE @SPACE    "SKID 드럼 코드 존재 여부
*      AND Z1~BANFN NE @SPACE     "2026.07.15 PR 미생성시에도 출력 가능하도록 주석처리
      AND EB~BANFN IN @S_BANFN      "구매요청 조회 조건 추가
    ORDER BY VK~VBELN, VP~POSNR
    INTO CORRESPONDING FIELDS OF TABLE @GT_SKID.

* LINE별 추가 데이터 (CBM 등)
  PERFORM F_GET_LINE_DATA.

* SKID 구성표 데이터
  PERFORM F_GET_SKID_DATA.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form F_SMART_FORM_PRINT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_SMART_FORM_PRINT .
  CLEAR:
        CONTROL_PARAMETERS,
        OUTPUT_OPTIONS,
        FUNC_NAME,
        PRINTER,
        OTF[].

  DATA:
    LT_SKID_CHK TYPE TY_T_SKID,
    LV_ROW_ID   TYPE INT4,
    LV_CHECK    TYPE C LENGTH 1.

  CALL METHOD GO_GRID_100->CHECK_CHANGED_DATA
    IMPORTING
      E_VALID = LV_CHECK.

  CHECK LV_CHECK EQ ABAP_TRUE.

  " --MOVE CHECKED DATA
  LT_SKID_CHK = VALUE #( FOR LS_SKID IN GT_SKID WHERE ( CHECK = ABAP_TRUE ) ( LS_SKID ) ).

  IF LT_SKID_CHK IS INITIAL.
    MESSAGE S000 WITH TEXT-E03 DISPLAY LIKE GC_E.
    EXIT.
  ENDIF.

  SORT  LT_SKID_CHK BY LFDAT. "SMART FORM 기준으로 SORTING

  "-- SMART FORMS DATA HANDLING
  PERFORM F_SMART_FORM_DATA USING LT_SKID_CHK.
  PERFORM F_SMART_FORM_SETTING.

*  PERFORM F_SMART_FORM_FINALL_WRITE. " OTF 미사용으로 주석처리

ENDFORM.
*&---------------------------------------------------------------------*
*& Form F_SMART_FORM_SETTING
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_SMART_FORM_SETTING .

  DATA: RTAB  LIKE KUNNR_RAN  OCCURS 0 WITH HEADER LINE.
  DATA: SSFCRESPD TYPE SSFCRESPD,
        SSFCRESCL TYPE SSFCRESCL,
        SSFCRESOP TYPE SSFCRESOP.


  CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
    EXPORTING                "
      FORMNAME           = 'ZGTMM_SKID_CBM_FORM'
    IMPORTING
      FM_NAME            = FUNC_NAME
    EXCEPTIONS
      NO_FORM            = 1
      NO_FUNCTION_MODULE = 2
      OTHERS             = 3.

*  CONTROL_PARAMETERS-GETOTF = 'X'.
*  CONTROL_PARAMETERS-PREVIEW = 'X'.         "프리뷰
*  CONTROL_PARAMETERS-NO_DIALOG = SPACE.   "미리보기

  OUTPUT_OPTIONS-TDIMMED  = 'X'.  " 즉시 인쇄
  OUTPUT_OPTIONS-TDDELETE = 'X'.  " 출력 후 삭제
  OUTPUT_OPTIONS-TDDEST = 'ZP01'.

  CLEAR SSFCRESCL.

  CALL FUNCTION FUNC_NAME
    EXPORTING
      CONTROL_PARAMETERS   = CONTROL_PARAMETERS
      OUTPUT_OPTIONS       = OUTPUT_OPTIONS
      USER_SETTINGS        = ''
      I_HEADER             = GS_HEADER
    IMPORTING
      DOCUMENT_OUTPUT_INFO = SSFCRESPD
      JOB_OUTPUT_INFO      = SSFCRESCL
      JOB_OUTPUT_OPTIONS   = SSFCRESOP
    TABLES
      IT_DATA              = GT_DATA
    EXCEPTIONS
      FORMATTING_ERROR     = 1
      INTERNAL_ERROR       = 2
      SEND_ERROR           = 3
      USER_CANCELED        = 4
      OTHERS               = 5.

  IF SY-SUBRC <> 0.
    MESSAGE S000 WITH TEXT-M01.
  ENDIF.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form F_SMART_FORM_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_SMART_FORM_DATA USING PT_SKID_CHK TYPE TY_T_SKID.

  CLEAR: GT_DATA, GS_HEADER.
  "I_HEADER SETTING

  "--설계 담당자 정보 SELECT -> HEADER
  SELECT SINGLE *
    FROM ZGTMMT2021
    WHERE BUKRS EQ @P_BUKRS
    INTO CORRESPONDING FIELDS OF @GS_HEADER.

  " ITEM
  MOVE-CORRESPONDING PT_SKID_CHK[] TO GT_DATA.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form F_SMART_FORM_FINALL_WRITE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_SMART_FORM_FINALL_WRITE .

  DATA: SSFPP                TYPE SSFPP,
        ARC_PARAMS           TYPE ARC_PARAMS,
        SPOOL_JOB_ATTRIBUTES LIKE RSPOATTR OCCURS 0 WITH HEADER LINE.

  SSFPP-TDDEVICE        = 'PRINTER'.
  SSFPP-TDPREVIEW       = 'X'.
  SSFPP-TDPAGEFORM      = 'DINA4'.
  SSFPP-TDPAGES         = '00002'.
  SSFPP-TDDRIVER        = 'SWIN'.
  SSFPP-TDOTFTYPE       = 'OTFSWIN'.
  SSFPP-TDFORMS         = '00001'.
  SSFPP-TDPROGRAM       = 'SAPLSTXBE'.

  SSFPP-TDSCREEN          = 'WN32'.
  SSFPP-TDSCDRIVER        = 'WN32'.
  CLEAR: SSFPP-TDNOPRINT.

  SSFPP-TDARMOD         = '1'.
  SSFPP-TDDATASET       = 'SMART'.
  SSFPP-TDSUFFIX1       = 'ZP01'.
  SSFPP-TDSUFFIX2       = SY-UNAME.
  SSFPP-TDDEST          = 'ZP01'.
  SSFPP-TDPRINTER       = 'KPSAPWIN'.
  SSFPP-TDIMMED         = 'X'.
  SSFPP-TDDELETE        = 'X'.
  SSFPP-TDLIFETIME      = '8'.
  SSFPP-TDCOPIES      = '001'.


  SPOOL_JOB_ATTRIBUTES-PARAM    = 'S_COPYMETH'.
  SPOOL_JOB_ATTRIBUTES-VALUE    = 'COLLATE'.
  APPEND SPOOL_JOB_ATTRIBUTES.

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


ENDFORM.
*&---------------------------------------------------------------------*
*& Form F_MODIFY_2021
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_MODIFY_2021 .
  DATA: LS_2021 TYPE ZGTMMT2021.

  CLEAR GS_SCR_102.

  SELECT SINGLE *
    FROM ZGTMMT2021
    WHERE BUKRS EQ @P_BUKRS
    INTO CORRESPONDING FIELDS OF @GS_SCR_102.

  SELECT SINGLE BUTXT
    FROM T001
    WHERE BUKRS EQ @P_BUKRS
    INTO @GS_SCR_102-BUTXT.

  GS_SCR_102-BUKRS = P_BUKRS.

  CALL SCREEN 102 STARTING AT 1 4.

  CHECK GS_SCR_102-ZCHK EQ ABAP_TRUE.

  MOVE-CORRESPONDING GS_SCR_102 TO LS_2021.

  LS_2021 = VALUE #( BUKRS = GS_SCR_102-BUKRS
                                 NAME = GS_SCR_102-NAME
                                 CONTACT = GS_SCR_102-CONTACT
                                 ERDAT = SY-DATUM
                                 ERDAT_LOCAL = SY-DATLO
                                 ERTIM = SY-UZEIT
                                 ERTIM_LOCAL = SY-TIMLO
                                 ERNAM = SY-UNAME ).

  MODIFY ZGTMMT2021 FROM LS_2021.

  MESSAGE S000 WITH TEXT-M04.

ENDFORM.
