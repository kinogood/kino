*&---------------------------------------------------------------------*
*& Include          ZGTMMR4350F01
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*& Form F_INITIALIZATION
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_INITIALIZATION .

  "입고 일자
  IF S_GRDAT[] IS INITIAL.
    S_GRDAT[] = VALUE #( ( SIGN = 'I' OPTION = 'BT' LOW = SY-DATUM - 30 HIGH = SY-DATUM ) ).
  ENDIF.

  "납품 일자
  IF S_DLDAT[] IS INITIAL.
    S_DLDAT[] = VALUE #( ( SIGN = 'I' OPTION = 'BT' LOW = SY-DATUM - 30 HIGH = SY-DATUM ) ).
  ENDIF.

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

  AUTHORITY-CHECK OBJECT 'ZCBO_MM001'
               ID 'WERKS' FIELD P_WERKS.

  CHECK SY-SUBRC <> 0.

  SET CURSOR FIELD 'P_WERKS'.
  MESSAGE E106 WITH P_WERKS. "플랜트[&] 작업권한을 확인하세요.

  IF S_WERKS[] IS NOT INITIAL.
      LOOP AT S_WERKS INTO DATA(LS_WERKS).
        AUTHORITY-CHECK OBJECT 'ZCBO_MM001'
                     ID 'WERKS' FIELD LS_WERKS-LOW.

        CHECK SY-SUBRC <> 0.

        SET CURSOR FIELD 'S_WERKS-LOW'.
        MESSAGE E106 WITH S_WERKS-LOW. "플랜트 [&] 작업권한을 확인하세요.
      ENDLOOP.
  ENDIF.

ENDFORM.
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
    "필수 입력 값 설정
    CASE SCREEN-GROUP1.
      WHEN 'BUK' OR 'WRK' OR 'GRD' OR 'DLD' OR 'EBN' OR 'EBP'.
        SCREEN-REQUIRED = 2.
      WHEN 'SWE' OR 'SGR' OR 'SDL'.
        IF SCREEN-GROUP3 NE 'HGH'.
          SCREEN-REQUIRED = 2.
        ENDIF.
    ENDCASE.

    "활성/비활성화
    CASE SCREEN-GROUP1.
      WHEN 'WRK' OR 'GRD' OR 'DLD' OR 'EBN' OR 'EBP'.
        IF P_NEW EQ ABAP_TRUE.
          SCREEN-ACTIVE = 1.
        ELSE.
          SCREEN-ACTIVE = 0.
        ENDIF.
      WHEN 'SWE' OR 'SGR' OR 'SDL' OR 'SEN' OR 'SEP' OR 'MAT' OR 'LOT' OR 'LBL'.
        IF P_DISP EQ ABAP_TRUE.
          SCREEN-ACTIVE = 1.
        ELSE.
          SCREEN-ACTIVE = 0.
        ENDIF.
    ENDCASE.

    "원부자재/외주임가공 구분
    CASE SCREEN-GROUP1.
      WHEN 'GRD' OR 'SGR' OR 'LBL'.
        IF P_ROH NE ABAP_TRUE AND SCREEN-ACTIVE EQ 1.
          SCREEN-ACTIVE = 0.
        ENDIF.
      WHEN 'DLD' OR 'SDL' OR 'LOT'.
        IF P_EXW NE ABAP_TRUE AND SCREEN-ACTIVE EQ 1.
          SCREEN-ACTIVE = 0.
        ENDIF.
    ENDCASE.

    MODIFY SCREEN.
  ENDLOOP.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_AT_SCREEN_ON_BUKRS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_AT_SCREEN_ON_BUKRS .

  CHECK SY-UCOMM EQ 'ONLI'.

  CLEAR GV_ERROR.

  "필수 값 점검
  IF P_BUKRS IS INITIAL.
    GV_ERROR = ABAP_TRUE.
    MESSAGE E278(00) WITH TEXT-F01.
  ENDIF.

  CHECK GV_ERROR EQ SPACE.

  "유효성 점검
  SELECT SINGLE
    BUKRS
    FROM T001
    WHERE BUKRS EQ @P_BUKRS
    INTO @DATA(LV_CHK).
  CHECK SY-SUBRC NE 0.
  GV_ERROR = ABAP_TRUE.
  MESSAGE E013.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_AT_SCREEN_ON_WERKS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_AT_SCREEN_ON_WERKS .

  CHECK SY-UCOMM EQ 'ONLI'.

  CHECK P_NEW EQ ABAP_TRUE. "등록 인 경우만

  CLEAR GV_ERROR.

  "필수 값 점검
  IF P_WERKS IS INITIAL.
    GV_ERROR = ABAP_TRUE.
    MESSAGE E278(00) WITH TEXT-F02.
  ENDIF.

  CHECK GV_ERROR EQ SPACE.

  "유효성 점검
  SELECT SINGLE
    @ABAP_TRUE
    FROM T001W
    WHERE WERKS EQ @P_WERKS
    INTO @DATA(LV_CHK).
  CHECK SY-SUBRC NE 0.
  GV_ERROR = ABAP_TRUE.
  MESSAGE E013.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_AT_SCREEN_ON_GRDAT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_AT_SCREEN_ON_GRDAT .

  CHECK SY-UCOMM EQ 'ONLI'.

  CHECK P_NEW EQ ABAP_TRUE "등록 인 경우만
      AND P_ROH EQ ABAP_TRUE.  "원부자재 인 경우만

  CLEAR GV_ERROR.

  "필수 값 점검
  IF P_GRDAT IS INITIAL.
    GV_ERROR = ABAP_TRUE.
    MESSAGE E278(00) WITH TEXT-F03.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_AT_SCREEN_ON_DLDAT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
*FORM F_AT_SCREEN_ON_DLDAT .
*
*  CHECK SY-UCOMM EQ 'ONLI'.
*
*  CHECK P_NEW EQ ABAP_TRUE "등록 인 경우만
*      AND P_EXW EQ ABAP_TRUE.  "외주임가공 인 경우만
*
*  CLEAR GV_ERROR.
*
*  "필수 값 점검
*  IF P_DLDAT IS INITIAL.
*    GV_ERROR = ABAP_TRUE.
*    MESSAGE E278(00) WITH TEXT-F04.
*  ENDIF.
*
*ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_AT_SCREEN_ON_S_WERKS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_AT_SCREEN_ON_S_WERKS .

  CHECK SY-UCOMM EQ 'ONLI'.

  CHECK P_DISP EQ ABAP_TRUE. "조회 인 경우만

  CLEAR GV_ERROR.

  "필수 값 점검
  IF S_WERKS[] IS INITIAL.
    GV_ERROR = ABAP_TRUE.
    MESSAGE E278(00) WITH TEXT-F02.
  ENDIF.

  CHECK GV_ERROR EQ SPACE.

  "유효성 점검
  SELECT SINGLE
    @ABAP_TRUE
    FROM T001W
    WHERE WERKS IN @S_WERKS
    INTO @DATA(LV_CHK).
  CHECK SY-SUBRC NE 0.
  GV_ERROR = ABAP_TRUE.
  MESSAGE E013.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_AT_SCREEN_ON_S_GRDAT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_AT_SCREEN_ON_S_GRDAT .

  CHECK SY-UCOMM EQ 'ONLI'.

  CHECK P_DISP EQ ABAP_TRUE "조회 인 경우만
      AND P_ROH EQ ABAP_TRUE.  "원부자재 인 경우만

  CLEAR GV_ERROR.

  "필수 값 점검
  IF S_GRDAT[] IS INITIAL.
    GV_ERROR = ABAP_TRUE.
    MESSAGE E278(00) WITH TEXT-F03.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_AT_SCREEN_ON_S_DLDAT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_AT_SCREEN_ON_S_DLDAT .

  CHECK SY-UCOMM EQ 'ONLI'.

  CHECK P_DISP EQ ABAP_TRUE "조회 인 경우만
      AND P_EXW EQ ABAP_TRUE.  "외주임가공 인 경우만

  CLEAR GV_ERROR.

  "필수 값 점검
  IF S_DLDAT[] IS INITIAL.
    GV_ERROR = ABAP_TRUE.
    MESSAGE E278(00) WITH TEXT-F04.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_AT_SCREEN_ON_EBELN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_AT_SCREEN_ON_EBELN .

  CHECK SY-UCOMM EQ 'ONLI'.

  CHECK P_NEW EQ ABAP_TRUE. "등록 인 경우만

  CLEAR GV_ERROR.

  "필수 값 점검
  IF P_EBELN IS INITIAL.
    GV_ERROR = ABAP_TRUE.
    MESSAGE E278(00) WITH TEXT-F05.
  ENDIF.

  CHECK GV_ERROR EQ SPACE.

  "유효성 점검
  IF P_EBELP IS INITIAL.
    SELECT SINGLE
      @ABAP_TRUE
      FROM EKKO
      WHERE EBELN EQ @P_EBELN
      INTO @DATA(LV_CHK1).
  ELSE.
    SELECT SINGLE
      @ABAP_TRUE
      FROM EKPO
      WHERE EBELN EQ @P_EBELN
      AND EBELP EQ @P_EBELP
      INTO @DATA(LV_CHK2).
  ENDIF.

  CHECK SY-SUBRC NE 0.
  GV_ERROR = ABAP_TRUE.
  MESSAGE E013.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_AT_SCREEN_ON_EBELP
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_AT_SCREEN_ON_EBELP .

  CHECK SY-UCOMM EQ 'ONLI'.

  CHECK P_NEW EQ ABAP_TRUE. "등록 인 경우만

  CLEAR GV_ERROR.

  "필수 값 점검
  IF P_EBELP IS INITIAL.
    GV_ERROR = ABAP_TRUE.
    MESSAGE E278(00) WITH TEXT-F06.
  ENDIF.

  CHECK GV_ERROR EQ SPACE.

  "유효성 점검
  SELECT SINGLE
    @ABAP_TRUE
    FROM EKPO
    WHERE EBELN EQ @P_EBELN
    AND EBELP EQ @P_EBELP
    INTO @DATA(LV_CHK).
  CHECK SY-SUBRC NE 0.
  GV_ERROR = ABAP_TRUE.
  MESSAGE E013.

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


  CASE ABAP_TRUE.
    WHEN P_NEW. "등록
      PERFORM F_GET_DATA_NEW.

    WHEN P_DISP. "조회
      PERFORM F_GET_DATA_DISP.

  ENDCASE.


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

  CLEAR:
    GT_ROH[],
    GT_EXW[].

*
**3) 작업구분=등록, 등록대상=원부자재 일때 실행 버튼 선택시 선택한 구매오더가 외자인 경우 아래 POPUP 메시지 Display
**  수입 구매오더여부 점검 기준 : 입력한 PO의 공급업체 스키마그룹 LFM1-KALSK= "FT" 이거나 EKKO-INCO1<>"" 일때
*  CHECK P_ROH EQ ABAP_TRUE.
*
*  SELECT SINGLE
*    @ABAP_TRUE
*    FROM EKKO AS EK
*                INNER JOIN
*              LFM1 AS LF ON EK~LIFNR EQ LF~LIFNR
*                               AND EK~EKORG EQ LF~EKORG
*    WHERE EK~EBELN EQ @P_EBELN
*    AND LF~KALSK EQ 'FT'
*    AND EK~INCO1 NE @SPACE
*    INTO @DATA(LV_CHK).
*  CHECK SY-SUBRC EQ 0.
*
*  DATA LV_ANS TYPE C LENGTH 1.
*  CALL FUNCTION 'POPUP_TO_CONFIRM'
*    EXPORTING
*      TITLEBAR      = TEXT-TT1 "확인
*      TEXT_QUESTION = TEXT-Q01
*    IMPORTING
*      ANSWER        = LV_ANS.
*  IF LV_ANS EQ GC_1.
*    CALL TRANSACTION 'ZMM1R0043'.
*  ENDIF.
*
*  LEAVE LIST-PROCESSING.

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

  CASE ABAP_TRUE.
    WHEN P_ROH. "원자재
      PERFORM F_GET_DATA_DISP_ROH.

    WHEN P_EXW. "외주임가공
      PERFORM F_GET_DATA_DISP_EXW.

  ENDCASE.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_GET_DATA_DISP_ROH
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_GET_DATA_DISP_ROH .

*  1. 등록 대상 "원부자재"
*1)	 실행 조회조건 값을 기준으로 대상 정보 추출
*	Table : ZGTMMT9460
*
*	SELECT 조건: VLABELNO,BUDAT,LANCHARMATNR,WERKS,EBELN,EBELP,MENGE,MEINS,ERNAM,ERDAT
*
*	WHERE 조건:
*	WERKS = 조건 입력값
*	BUDAT = 조건 입력 값(or 기간)
*	EBELN = 조건 입력값
*	EBELP = 조건 입력값
*	MATNR = 조건 입력값
*
*2) 기타 및 Text 정보 조회
*  3-1) 플랜트명 : T001W-NAME1
*  3-2) 공급업체: EKKO-LIFNR
*  3-3) 공급업체명 : LFA1-NAME1
*  3-4) 자재내역: EKPO-TXZ01

*3) 추출한 데이터를 기준으로 ALV Display
*	- Data Sorting : BUDAT,VLABELNO,EBELN,EBELP 순으로 오름차순 정렬

  CLEAR GT_ROH[].

  SELECT
    Z1~WERKS,
    TW~NAME1 AS WERKS_TEXT,
    Z1~BUDAT,
    Z1~VLABELNO,
    Z1~MENGE,
    Z1~MEINS,
    Z1~LANCHAR,
    Z1~EBELN,
    Z1~EBELP,
    EK~LIFNR,
    LF~NAME1 AS LIFNR_TEXT,
    Z1~MATNR,
    EP~TXZ01,
    Z1~ERDAT,
    Z1~ERDAT_LOCAL,
    Z1~ERTIM,
    Z1~ERTIM_LOCAL,
    Z1~ERNAM
    FROM ZGTMMT9460 AS Z1
              INNER JOIN
            T001W AS TW ON Z1~WERKS EQ TW~WERKS
              INNER JOIN
            T001K AS TK ON TW~BWKEY EQ TK~BWKEY
              LEFT OUTER JOIN
            EKKO AS EK ON Z1~EBELN EQ EK~EBELN
              LEFT OUTER JOIN
            EKPO AS EP ON Z1~EBELN EQ EP~EBELN
                           AND Z1~EBELP EQ EP~EBELP
              LEFT OUTER JOIN
            LFA1 AS LF ON EK~LIFNR EQ LF~LIFNR
    WHERE TK~BUKRS EQ @P_BUKRS
    AND Z1~WERKS IN @S_WERKS
    AND Z1~BUDAT IN @S_GRDAT
    AND Z1~EBELN IN @S_EBELN
    AND Z1~EBELP IN @S_EBELP
    AND Z1~MATNR IN @S_MATNR
*>S.2026.07.07 '라벨번호' 조회조건 추가에 따른 셀렉트 웨어조건 추가
    AND Z1~VLABELNO IN @S_LABEL
*<E.2026.07.07 ZGODEV04.
    ORDER BY Z1~BUDAT, Z1~VLABELNO, Z1~EBELN, Z1~EBELP
    INTO CORRESPONDING FIELDS OF TABLE @GT_ROH.

    PERFORM F_DISPLAY_CHANGE.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_GET_DATA_DISP_EXW
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_GET_DATA_DISP_EXW .
*1)	 실행 조회조건 값을 기준으로 대상 정보 추출
*	Table : ZGTMMT9461
*
*	SELECT 조건: LOTNO,BUDAT,WERKS,EBELN,EBELP,MATNR,MENGE,MEINS,KUNNR2,TRANS,TRUCK_NO,GRADE,ERNAM,ERDAT
*
*	WHERE 조건:
*	WERKS = 조건 입력값
*	BUDAT = 조건 입력 값(or 기간)
*	EBELN = 조건 입력값
*	EBELP = 조건 입력값
*	MATNR = 조건 입력값
*
*2) 기타 및 Text 정보 조회
*  3-1) 플랜트명 : T001W-NAME1
*  3-2) 공급업체: EKKO-LIFNR
*  3-3) 공급업체명 : LFA1-NAME1
*  3-4) 자재내역 : EKPO-TXZ01
*
*3) 추출한 데이터를 기준으로 ALV Display
*	- Data Sorting : BUDAT,LOTNO,KUNNR2,EBELN,EBELP 순으로 오름차순 정렬
*

  CLEAR GT_EXW[].

  SELECT
    Z1~WERKS,
    TW~NAME1 AS WERKS_TEXT,
    Z1~BUDAT,
    Z1~LOTNO,
    Z1~MENGE,
    Z1~MEINS,
    Z1~EBELN,
    Z1~EBELP,
    EK~LIFNR,
    LF~NAME1 AS LIFNR_TEXT,
    Z1~MATNR,
    EP~TXZ01,
    Z1~KUNNR2,
    Z1~TRANS,
    Z1~TRUCK_NO,
    Z1~GRADE,
    Z1~ERDAT,
    Z1~ERDAT_LOCAL,
    Z1~ERTIM,
    Z1~ERTIM_LOCAL,
    Z1~ERNAM
    FROM ZGTMMT9461 AS Z1
              INNER JOIN
            T001W AS TW ON Z1~WERKS EQ TW~WERKS
              INNER JOIN
            T001K AS TK ON TW~BWKEY EQ TK~BWKEY
              LEFT OUTER JOIN
            EKKO AS EK ON Z1~EBELN EQ EK~EBELN
              LEFT OUTER JOIN
            EKPO AS EP ON Z1~EBELN EQ EP~EBELN
                           AND Z1~EBELP EQ EP~EBELP
              LEFT OUTER JOIN
            LFA1 AS LF ON EK~LIFNR EQ LF~LIFNR
    WHERE TK~BUKRS EQ @P_BUKRS
    AND Z1~WERKS IN @S_WERKS
    AND Z1~BUDAT IN @S_DLDAT
    AND Z1~EBELN IN @S_EBELN
    AND Z1~EBELP IN @S_EBELP
    AND Z1~MATNR IN @S_MATNR
*>S.2026.07.07 '라벨번호' 조회조건 추가에 따른 셀렉트 웨어조건 추가
    AND Z1~LOTNO IN @S_LOTNO
*<E.2026.07.07 ZGODEV04.
    ORDER BY Z1~BUDAT, Z1~LOTNO, Z1~KUNNR2, Z1~EBELN, Z1~EBELP
    INTO CORRESPONDING FIELDS OF TABLE @GT_EXW.

    PERFORM F_DISPLAY_CHANGE.

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

  CASE ABAP_TRUE.
    WHEN P_ROH.
      IF GT_ROH[] IS INITIAL AND P_DISP EQ ABAP_TRUE.
        MESSAGE S002 DISPLAY LIKE GC_E.
        LEAVE LIST-PROCESSING.
      ENDIF.
      CALL SCREEN 100.

    WHEN P_EXW.
      IF GT_EXW[] IS INITIAL AND P_DISP EQ ABAP_TRUE.
        MESSAGE S002 DISPLAY LIKE GC_E.
        LEAVE LIST-PROCESSING.
      ENDIF.
      CALL SCREEN 200.

  ENDCASE.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_TEMPLATE_DOWNLOAD
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GC_ZGTMMR4350_ROH
*&---------------------------------------------------------------------*
FORM F_TEMPLATE_DOWNLOAD  USING  PV_OBJID TYPE W3OBJID.

  DATA:
    LS_WWWDATA           TYPE WWWDATATAB,
    LV_DEFAULT_FILE_NAME TYPE STRING,
    LV_FILENAME          TYPE STRING,
    LV_PATH              TYPE STRING,
    LV_FULLPATH          TYPE STRING,
    LV_RC                TYPE SY-SUBRC.

  CONSTANTS
    LC_FILE_EXT          TYPE W3_NAME VALUE 'fileextension'.

  "SMW0 조회
  SELECT SINGLE *
    FROM WWWDATA
   WHERE OBJID EQ @PV_OBJID
    INTO CORRESPONDING FIELDS OF @LS_WWWDATA.

  IF SY-SUBRC NE 0.
    EXIT.
  ENDIF.

  SELECT SINGLE
    VALUE
    FROM WWWPARAMS
    WHERE RELID EQ @LS_WWWDATA-RELID
    AND OBJID EQ @LS_WWWDATA-OBJID
    AND NAME EQ @LC_FILE_EXT
    INTO @DATA(LV_FILE_EXT).

  LV_DEFAULT_FILE_NAME = LS_WWWDATA-TEXT && LV_FILE_EXT.
  CL_GUI_FRONTEND_SERVICES=>FILE_SAVE_DIALOG(
    EXPORTING
      DEFAULT_EXTENSION         = CONV STRING( LV_FILE_EXT )
      DEFAULT_FILE_NAME         = LV_DEFAULT_FILE_NAME
      FILE_FILTER               = CONV STRING( LV_FILE_EXT )
    CHANGING
      FILENAME                  = LV_FILENAME
      PATH                      = LV_PATH
      FULLPATH                  = LV_FULLPATH
    EXCEPTIONS
      CNTL_ERROR                = 1
      ERROR_NO_GUI              = 2
      NOT_SUPPORTED_BY_GUI      = 3
      INVALID_DEFAULT_FILE_NAME = 4
      OTHERS                    = 5
  ).

  IF SY-SUBRC NE 0.
    MESSAGE ID SY-MSGID TYPE GC_S NUMBER SY-MSGNO
      WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4
      DISPLAY LIKE GC_E.
    EXIT.
  ENDIF.

  CHECK LV_FULLPATH IS NOT INITIAL.
  CALL FUNCTION 'DOWNLOAD_WEB_OBJECT'
    EXPORTING
      KEY         = LS_WWWDATA
      DESTINATION = CONV LOCALFILE( LV_FULLPATH )
    IMPORTING
      RC          = LV_RC.

  CHECK LV_RC EQ 0.

  CL_GUI_FRONTEND_SERVICES=>EXECUTE(
    EXPORTING
      DOCUMENT               = LV_FULLPATH
    EXCEPTIONS
      CNTL_ERROR             = 1
      ERROR_NO_GUI           = 2
      BAD_PARAMETER          = 3
      FILE_NOT_FOUND         = 4
      PATH_NOT_FOUND         = 5
      FILE_EXTENSION_UNKNOWN = 6
      ERROR_EXECUTE_FAILED   = 7
      SYNCHRONOUS_FAILED     = 8
      NOT_SUPPORTED_BY_GUI   = 9
      OTHERS                 = 10
  ).

  IF SY-SUBRC NE 0.
    MESSAGE ID SY-MSGID TYPE GC_S NUMBER SY-MSGNO
      WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4
      DISPLAY LIKE GC_E.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_EXCEL_UPLOAD_ROH
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_EXCEL_UPLOAD_ROH .

*2. Excel Upload 버튼
*	2-1) 1) 의 등록 대상별 파일 업로드 하여 ALV List 데이터로 반영
*	2-2) Excel 업로드 시 ALV 에 데이터가 존재하면 데이터 Clear 후 반영
*	2-3) Excel 데이터 ALV 리스트 display]
*   : 모든 컬럼은 Editable 상태로 보여줌
*   2-3-1) 원부자재

  DATA LV_CHECK TYPE C LENGTH 1.
  CALL METHOD GO_GRID_100->CHECK_CHANGED_DATA
    IMPORTING
      E_VALID = LV_CHECK.

  CHECK LV_CHECK EQ ABAP_TRUE.

  DATA:
    LV_FILE TYPE RLGRAP-FILENAME,
    LT_XLS  TYPE STANDARD TABLE OF TY_ROH_XLS.

  "파일명 선택
  PERFORM F_GET_FILE_NAME CHANGING LV_FILE.

  "Excel 조회
  CHECK LV_FILE IS NOT INITIAL.
  PERFORM F_GET_EXCEL_DATA USING 1 2 4 60000 LV_FILE 'TY_ROH_XLS' CHANGING LT_XLS.

  "데이터 설정
  PERFORM F_SET_ALV_DATA_ROH USING LT_XLS CHANGING GT_ROH LV_CHECK.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_GET_FILE_NAME
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- LV_FILE
*&---------------------------------------------------------------------*
FORM F_GET_FILE_NAME  CHANGING CV_FILE.

  CLEAR CV_FILE.

  DATA:
    LT_FILE_TABLE TYPE FILETABLE,
    LV_SUBRC      TYPE SY-SUBRC,
    LV_ACTION     TYPE I.

  CALL METHOD CL_GUI_FRONTEND_SERVICES=>FILE_OPEN_DIALOG
    EXPORTING
      DEFAULT_EXTENSION       = CL_GUI_FRONTEND_SERVICES=>FILETYPE_EXCEL
      FILE_FILTER             = CL_GUI_FRONTEND_SERVICES=>FILETYPE_EXCEL
    CHANGING
      FILE_TABLE              = LT_FILE_TABLE
      RC                      = LV_SUBRC
      USER_ACTION             = LV_ACTION
    EXCEPTIONS
      FILE_OPEN_DIALOG_FAILED = 1
      CNTL_ERROR              = 2
      ERROR_NO_GUI            = 3
      NOT_SUPPORTED_BY_GUI    = 4
      OTHERS                  = 5.
  IF SY-SUBRC EQ 0 AND LT_FILE_TABLE[] IS NOT INITIAL.
    READ TABLE LT_FILE_TABLE ASSIGNING FIELD-SYMBOL(<LS_FILE>) INDEX 1.
    CHECK SY-SUBRC EQ 0.
    CV_FILE = <LS_FILE>-FILENAME.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_GET_EXCEL_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_1
*&      --> P_3
*&      --> P_4
*&      --> P_6000
*&      --> LV_FILE
*&      --> P_
*&      <-- LT_XLS
*&---------------------------------------------------------------------*
FORM F_GET_EXCEL_DATA  USING PV_BEGIN_COL
                                                      PV_BEGIN_ROW
                                                      PV_END_COL
                                                      PV_END_ROW
                                                      PV_FILE
                                                      PV_T_TYPE
                       CHANGING CT_XLS TYPE STANDARD TABLE.
  CLEAR:
     CT_XLS[].

  DATA LT_ITAB TYPE STANDARD TABLE OF ALSMEX_TABLINE.
  CALL FUNCTION 'ALSM_EXCEL_TO_INTERNAL_TABLE'
    EXPORTING
      FILENAME                = PV_FILE
      I_BEGIN_COL             = PV_BEGIN_COL
      I_BEGIN_ROW             = PV_BEGIN_ROW
      I_END_COL               = PV_END_COL
      I_END_ROW               = PV_END_ROW
    TABLES
      INTERN                  = LT_ITAB
    EXCEPTIONS
      INCONSISTENT_PARAMETERS = 1
      UPLOAD_OLE              = 2
      OTHERS                  = 3.

  CHECK SY-SUBRC EQ 0.

  DATA:
    LO_DATA    TYPE REF TO DATA,
    LV_COL_IDX TYPE INT4.

  FIELD-SYMBOLS <LS_STRU> TYPE ANY.

  CREATE DATA LO_DATA TYPE (PV_T_TYPE).
  ASSIGN LO_DATA->* TO <LS_STRU>.

  LOOP AT LT_ITAB ASSIGNING FIELD-SYMBOL(<LS_G>) GROUP BY ( ROW = <LS_G>-ROW )
                                                                             ASSIGNING FIELD-SYMBOL(<LS_GROUP>).

    "값 설정
    CLEAR <LS_STRU>.
    LOOP AT GROUP <LS_GROUP> ASSIGNING FIELD-SYMBOL(<LS_XLS>).
      LV_COL_IDX = <LS_XLS>-COL.
      ASSIGN COMPONENT LV_COL_IDX OF STRUCTURE <LS_STRU> TO FIELD-SYMBOL(<LV_VAL>).
      CHECK <LV_VAL> IS ASSIGNED.
      <LV_VAL> = <LS_XLS>-VALUE.
    ENDLOOP.

    "라인추가
    APPEND <LS_STRU> TO CT_XLS.
  ENDLOOP.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_SET_ALV_DATA_ROH
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LT_XLS
*&      <-- GT_ROH
*&      <-- LV_CHECK
*&---------------------------------------------------------------------*
FORM F_SET_ALV_DATA_ROH  USING  PT_XLS TYPE TY_T_ROH_XLS
                         CHANGING CT_ROH TYPE TY_T_ROH
                                  CV_CHECK.
  "초기화
  CLEAR:
    CV_CHECK.

  DATA:
    LT_ROH TYPE STANDARD TABLE OF TY_ROH,
    LS_ROH TYPE TY_ROH.

  SELECT SINGLE
    MATNR
    FROM EKPO
    WHERE EBELN EQ @P_EBELN
    AND EBELP EQ @P_EBELP
    INTO @DATA(LV_MATNR).

  LOOP AT PT_XLS ASSIGNING FIELD-SYMBOL(<LS_XLS>).

    "초기화
    CLEAR LS_ROH.

    "콤마 제거
    REPLACE ALL OCCURRENCES OF ',' IN <LS_XLS>-MENGE WITH SPACE.
    REPLACE ALL OCCURRENCES OF ',' IN <LS_XLS>-LANCHAR WITH SPACE.

    "숫자 점검
    IF <LS_XLS>-MENGE CN '0123456789.'.
      MESSAGE E168 WITH TEXT-H06 <LS_XLS>-MENGE.
    ENDIF.
    IF <LS_XLS>-LANCHAR CN '0123456789.'.
      MESSAGE E168 WITH TEXT-H08 <LS_XLS>-LANCHAR.
    ENDIF.

    LS_ROH = CORRESPONDING #( <LS_XLS> ).
    LS_ROH-WERKS = P_WERKS.
    LS_ROH-BUDAT = P_GRDAT.
    LS_ROH-EBELN = P_EBELN.
    LS_ROH-EBELP = P_EBELP.
    LS_ROH-MATNR = LV_MATNR.
    LS_ROH-ZNEW = ABAP_TRUE.

    CALL FUNCTION 'CONVERSION_EXIT_CUNIT_INPUT'
      EXPORTING
        INPUT  = LS_ROH-MEINS
      IMPORTING
        OUTPUT = LS_ROH-MEINS.

    APPEND LS_ROH TO LT_ROH.
  ENDLOOP.

  "중복 데이터 오류
##ITAB_KEY_IN_SELECT
##ITAB_DB_SELECT
  SELECT
    ZZ~VLABELNO
    FROM @LT_ROH AS ZZ
    WHERE ZZ~VLABELNO IS NOT INITIAL
    GROUP BY ZZ~VLABELNO
    HAVING SUM( 1 ) GT 1
    INTO TABLE @DATA(LT_KEY).

  IF LT_KEY[] IS NOT INITIAL.
    MESSAGE E000 WITH TEXT-E01. "중복 데이터가 존재 합니다.
  ENDIF.

  "기존 데이터 조회
##ITAB_KEY_IN_SELECT
  SELECT
    Z1~VLABELNO
    FROM ZGTMMT9460 AS Z1
    WHERE Z1~EBELN EQ @P_EBELN
    AND Z1~EBELP EQ @P_EBELP
    AND EXISTS (
      SELECT @ABAP_TRUE
      FROM @LT_ROH AS ZZ
      WHERE ZZ~VLABELNO EQ Z1~VLABELNO
    )
    ORDER BY Z1~VLABELNO
    INTO TABLE @DATA(LT_CBO).

  CT_ROH[] = LT_ROH[].
  LOOP AT CT_ROH ASSIGNING FIELD-SYMBOL(<LS_ROH>).
    READ TABLE LT_CBO WITH KEY VLABELNO = <LS_ROH>-VLABELNO BINARY SEARCH TRANSPORTING NO FIELDS.
    CHECK SY-SUBRC EQ 0.
    <LS_ROH>-ZNEW = SPACE.
    <LS_ROH>-STATUS = ICON_LED_GREEN.
    <LS_ROH>-ZSTYLE = VALUE #(
          ( FIELDNAME = 'VLABELNO' STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED )
          ( FIELDNAME = 'MENGE' STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED )
          ( FIELDNAME = 'MEINS' STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED )
          ( FIELDNAME = 'LANCHAR' STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED ) ).
  ENDLOOP.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_SAVE_ROH
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_SAVE_ROH .
*
*3. 저장 버튼
*	3-1) 라인은 다중선택 가능 (전체선택 포함)
*	3-2) 선택한 라인이 없는 경우 ALV에 조회된 전체 데이터 라인을 대상으로 함
*	3-3) 선택한 데이터가 존재하면 선택한 데이터에 대해서 테이블 업데이트
*	3-4) 선택한 라인이 존재하고 오류가 없는경우 POP-UP 확인 후 입력 데이터 테이블 업데이트
*   3-4-1) 대상 데이터가 모두 신규 건인 경우
*   3-4-1) 동일한 Key 데이터가 존재하는 경우 하단 POP-UP 메시지로 보여줌

  DATA:
    LT_CBO   TYPE STANDARD TABLE OF ZGTMMT9460,
    LV_CHECK TYPE C LENGTH 1,
    LV_ANS   TYPE C LENGTH 1,
    LT_ROW   TYPE LVC_T_ROID.

  CALL METHOD GO_GRID_100->CHECK_CHANGED_DATA
    IMPORTING
      E_VALID = LV_CHECK.

  CHECK LV_CHECK EQ ABAP_TRUE.

  IF GT_ROH[] IS INITIAL.
    MESSAGE E000 WITH TEXT-E02.
  ENDIF.

  CALL METHOD GO_GRID_100->GET_SELECTED_ROWS
    IMPORTING
      ET_ROW_NO = LT_ROW.
  DELETE LT_ROW WHERE ROW_ID LE 0.

  IF LT_ROW[] IS INITIAL.
    DO LINES( GT_ROH ) TIMES.
      LT_ROW = VALUE #( BASE LT_ROW ( ROW_ID = SY-INDEX ) ).
    ENDDO.
  ENDIF.

  CLEAR LV_CHECK.
  LOOP AT LT_ROW ASSIGNING FIELD-SYMBOL(<LS_ROW>).
    READ TABLE GT_ROH ASSIGNING FIELD-SYMBOL(<LS_ROH>) INDEX <LS_ROW>-ROW_ID.
    CHECK SY-SUBRC EQ 0.

    IF <LS_ROH>-ZNEW EQ SPACE. "이미 저장 된 데이터
      LV_CHECK = ABAP_TRUE.
      CONTINUE.
    ENDIF.

    LT_CBO = VALUE #( BASE LT_CBO (
      VLABELNO = <LS_ROH>-VLABELNO
      EBELN = <LS_ROH>-EBELN
      EBELP = <LS_ROH>-EBELP
      BUDAT = <LS_ROH>-BUDAT
      WERKS = <LS_ROH>-WERKS
      MATNR = <LS_ROH>-MATNR
      MENGE = <LS_ROH>-MENGE
      MEINS = <LS_ROH>-MEINS
      LANCHAR = <LS_ROH>-LANCHAR
      ERDAT = SY-DATUM
      ERDAT_LOCAL = SY-DATLO
      ERTIM = SY-UZEIT
      ERTIM_LOCAL = SY-TIMLO
      ERNAM = SY-UNAME
     ) ).
  ENDLOOP.

  DATA LV_QUESTION TYPE STRING.
  IF LV_CHECK EQ ABAP_TRUE.
    LV_QUESTION = TEXT-Q02. " 이미 등록된 라벨(LOT) 데이터는 제외하고 저장합니다. 진행하시겠 습니까?
  ELSE.
    LV_QUESTION = TEXT-Q03. "데이터를 저장하시겠습니까?
  ENDIF.
  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      TITLEBAR      = TEXT-TT1
      TEXT_QUESTION = LV_QUESTION
    IMPORTING
      ANSWER        = LV_ANS.
  CHECK LV_ANS EQ GC_1.


  MODIFY ZGTMMT9460 FROM TABLE LT_CBO.
  COMMIT WORK.

  LOOP AT LT_ROW ASSIGNING <LS_ROW>.
    READ TABLE GT_ROH ASSIGNING <LS_ROH> INDEX <LS_ROW>-ROW_ID.
    CHECK SY-SUBRC EQ 0.
    <LS_ROH>-STATUS = ICON_LED_GREEN.
    <LS_ROH>-ZNEW = SPACE.
    <LS_ROH>-ZSTYLE = VALUE #(
          ( FIELDNAME = 'VLABELNO' STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED )
          ( FIELDNAME = 'MENGE' STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED )
          ( FIELDNAME = 'MEINS' STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED )
          ( FIELDNAME = 'LANCHAR' STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED ) ).

  ENDLOOP.

*3-5) 테이블 저장 후 ALV-STATUS = GREEN 으로 업데이트 및 하단 메시지 처리 "데이터 &건 저장 완료되었습니다."
*3-6) 성공한 데이터라인은 Display 상태로 변경
  DATA:
    LV_CNT   TYPE INT4,
    LV_CNT_C TYPE C LENGTH 10.

  LV_CNT = LINES( LT_CBO ).
  WRITE LV_CNT TO LV_CNT_C LEFT-JUSTIFIED.
  MESSAGE S169 WITH LV_CNT_C.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_EXCEL_UPLOAD_EXW
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_EXCEL_UPLOAD_EXW .

*2. Excel Upload 버튼
*	2-1) 1) 의 등록 대상별 파일 업로드 하여 ALV List 데이터로 반영
*	2-2) Excel 업로드 시 ALV 에 데이터가 존재하면 데이터 Clear 후 반영
*	2-3) Excel 데이터 ALV 리스트 display]
*   : 모든 컬럼은 Editable 상태로 보여줌
*   2-3-1) 원부자재

  DATA LV_CHECK TYPE C LENGTH 1.
  CALL METHOD GO_GRID_200->CHECK_CHANGED_DATA
    IMPORTING
      E_VALID = LV_CHECK.

  CHECK LV_CHECK EQ ABAP_TRUE.

  DATA:
    LV_FILE TYPE RLGRAP-FILENAME,
    LT_XLS  TYPE STANDARD TABLE OF TY_EXW_XLS.

  "파일명 선택
  PERFORM F_GET_FILE_NAME CHANGING LV_FILE.

  "Excel 조회
  CHECK LV_FILE IS NOT INITIAL.
  PERFORM F_GET_EXCEL_DATA USING 1 2 9 60000 LV_FILE 'TY_EXW_XLS' CHANGING LT_XLS.

  "데이터 설정
  PERFORM F_SET_ALV_DATA_EXW USING LT_XLS CHANGING GT_EXW LV_CHECK.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_SET_ALV_DATA_EXW
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LT_XLS
*&      <-- GT_EXW
*&      <-- LV_CHECK
*&---------------------------------------------------------------------*
FORM F_SET_ALV_DATA_EXW  USING  PT_XLS TYPE TY_T_EXW_XLS
                         CHANGING CT_EXW TYPE TY_T_EXW
                                  CV_CHECK.
  "초기화
  CLEAR:
    CV_CHECK.

  DATA:
    LT_EXW TYPE STANDARD TABLE OF TY_EXW,
    LS_EXW TYPE TY_EXW.

  SELECT SINGLE
    MATNR
    FROM EKPO
    WHERE EBELN EQ @P_EBELN
    AND EBELP EQ @P_EBELP
    INTO @DATA(LV_MATNR).

  LOOP AT PT_XLS ASSIGNING FIELD-SYMBOL(<LS_XLS>).

    "초기화
    CLEAR LS_EXW.

    "대문자
    TRANSLATE <LS_XLS>-GRADE TO UPPER CASE.

    "콤마 제거
##REGEX_POSIX
    REPLACE ALL OCCURRENCES OF ',' IN <LS_XLS>-MENGE WITH SPACE.
##REGEX_POSIX
    REPLACE ALL OCCURRENCES OF REGEX '[^[:digit:]]' IN <LS_XLS>-BUDAT WITH SPACE.


    IF <LS_XLS>-MENGE CN '0123456789.'.
      MESSAGE E168 WITH TEXT-H24 <LS_XLS>-MENGE.
    ENDIF.

    LS_EXW = CORRESPONDING #( <LS_XLS> ).
    LS_EXW-WERKS = P_WERKS.
    LS_EXW-EBELN = P_EBELN.
    LS_EXW-EBELP = P_EBELP.
    LS_EXW-MATNR = LV_MATNR.
    LS_EXW-ZNEW = ABAP_TRUE.

    CALL FUNCTION 'CONVERSION_EXIT_CUNIT_INPUT'
      EXPORTING
        INPUT  = LS_EXW-MEINS
      IMPORTING
        OUTPUT = LS_EXW-MEINS.

    APPEND LS_EXW TO LT_EXW.
  ENDLOOP.

  "중복 데이터 오류
##ITAB_KEY_IN_SELECT
##ITAB_DB_SELECT
  SELECT
    ZZ~LOTNO
    FROM @LT_EXW AS ZZ
    WHERE ZZ~LOTNO IS NOT INITIAL
    GROUP BY ZZ~LOTNO
    HAVING SUM( 1 ) GT 1
    INTO TABLE @DATA(LT_KEY).

  IF LT_KEY[] IS NOT INITIAL.
    MESSAGE E000 WITH TEXT-E01. "중복 데이터가 존재 합니다.
  ENDIF.

  "기존 데이터 조회
##ITAB_KEY_IN_SELECT
  SELECT
    Z1~LOTNO
    FROM ZGTMMT9461 AS Z1
    WHERE Z1~EBELN EQ @P_EBELN
    AND Z1~EBELP EQ @P_EBELP
    AND EXISTS (
      SELECT @ABAP_TRUE
      FROM @LT_EXW AS ZZ
      WHERE ZZ~LOTNO EQ Z1~LOTNO
    )
    ORDER BY Z1~LOTNO
    INTO TABLE @DATA(LT_CBO).

  CT_EXW[] = LT_EXW[].
  LOOP AT CT_EXW ASSIGNING FIELD-SYMBOL(<LS_EXW>).
    READ TABLE LT_CBO WITH KEY LOTNO = <LS_EXW>-LOTNO BINARY SEARCH TRANSPORTING NO FIELDS.
    CHECK SY-SUBRC EQ 0.
    <LS_EXW>-ZNEW = SPACE.
    <LS_EXW>-STATUS = ICON_LED_GREEN.
    <LS_EXW>-ZSTYLE = VALUE #(
          ( FIELDNAME = 'KUNNR2' STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED )
          ( FIELDNAME = 'BUDAT' STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED )
          ( FIELDNAME = 'MAKTX' STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED )
          ( FIELDNAME = 'MENGE' STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED )
          ( FIELDNAME = 'MEINS' STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED )
          ( FIELDNAME = 'TRANS' STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED )
          ( FIELDNAME = 'TRUCK_NO' STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED )
          ( FIELDNAME = 'LOTNO' STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED )
          ( FIELDNAME = 'GRADE' STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED )
           ).
  ENDLOOP.


ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_SAVE_EXW
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_SAVE_EXW .
*
*3. 저장 버튼
*	3-1) 라인은 다중선택 가능 (전체선택 포함)
*	3-2) 선택한 라인이 없는 경우 ALV에 조회된 전체 데이터 라인을 대상으로 함
*	3-3) 선택한 데이터가 존재하면 선택한 데이터에 대해서 테이블 업데이트
*	3-4) 선택한 라인이 존재하고 오류가 없는경우 POP-UP 확인 후 입력 데이터 테이블 업데이트
*   3-4-1) 대상 데이터가 모두 신규 건인 경우
*   3-4-1) 동일한 Key 데이터가 존재하는 경우 하단 POP-UP 메시지로 보여줌

  DATA:
    LT_CBO   TYPE STANDARD TABLE OF ZGTMMT9461,
    LV_CHECK TYPE C LENGTH 1,
    LV_ANS   TYPE C LENGTH 1,
    LT_ROW   TYPE LVC_T_ROID.

  CALL METHOD GO_GRID_200->CHECK_CHANGED_DATA
    IMPORTING
      E_VALID = LV_CHECK.

  CHECK LV_CHECK EQ ABAP_TRUE.

  IF GT_EXW[] IS INITIAL.
    MESSAGE E000 WITH TEXT-E02.
  ENDIF.

  CALL METHOD GO_GRID_200->GET_SELECTED_ROWS
    IMPORTING
      ET_ROW_NO = LT_ROW.
  DELETE LT_ROW WHERE ROW_ID LE 0.

  IF LT_ROW[] IS INITIAL.
    DO LINES( GT_EXW ) TIMES.
      LT_ROW = VALUE #( BASE LT_ROW ( ROW_ID = SY-INDEX ) ).
    ENDDO.
  ENDIF.

  CLEAR LV_CHECK.
  LOOP AT LT_ROW ASSIGNING FIELD-SYMBOL(<LS_ROW>).
    READ TABLE GT_EXW ASSIGNING FIELD-SYMBOL(<LS_EXW>) INDEX <LS_ROW>-ROW_ID.
    CHECK SY-SUBRC EQ 0.

    IF <LS_EXW>-ZNEW EQ SPACE. "이미 저장 된 데이터
      LV_CHECK = ABAP_TRUE.
      CONTINUE.
    ENDIF.

    LT_CBO = VALUE #( BASE LT_CBO (
      LOTNO = <LS_EXW>-LOTNO
      EBELN = <LS_EXW>-EBELN
      EBELP = <LS_EXW>-EBELP
      BUDAT = <LS_EXW>-BUDAT
      WERKS = <LS_EXW>-WERKS
      MATNR = <LS_EXW>-MATNR
      MAKTX = <LS_EXW>-MAKTX
      MENGE = <LS_EXW>-MENGE
      MEINS = <LS_EXW>-MEINS
      KUNNR2 = <LS_EXW>-KUNNR2
      TRANS = <LS_EXW>-TRANS
      TRUCK_NO = <LS_EXW>-TRUCK_NO
      GRADE = <LS_EXW>-GRADE
      ERDAT = SY-DATUM
      ERDAT_LOCAL = SY-DATLO
      ERTIM = SY-UZEIT
      ERTIM_LOCAL = SY-TIMLO
      ERNAM = SY-UNAME
     ) ).
  ENDLOOP.

  DATA LV_QUESTION TYPE STRING.
  IF LV_CHECK EQ ABAP_TRUE.
    LV_QUESTION = TEXT-Q02. " 이미 등록된 라벨(LOT) 데이터는 제외하고 저장합니다. 진행하시겠 습니까?
  ELSE.
    LV_QUESTION = TEXT-Q03. "데이터를 저장하시겠습니까?
  ENDIF.
  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      TITLEBAR      = TEXT-TT1
      TEXT_QUESTION = LV_QUESTION
    IMPORTING
      ANSWER        = LV_ANS.
  CHECK LV_ANS EQ GC_1.

  MODIFY ZGTMMT9461 FROM TABLE LT_CBO.
  COMMIT WORK.

  LOOP AT LT_ROW ASSIGNING <LS_ROW>.
    READ TABLE GT_EXW ASSIGNING <LS_EXW> INDEX <LS_ROW>-ROW_ID.
    CHECK SY-SUBRC EQ 0.
    <LS_EXW>-STATUS = ICON_LED_GREEN.
    <LS_EXW>-ZNEW = SPACE.
    <LS_EXW>-ZSTYLE = VALUE #(
          ( FIELDNAME = 'KUNNR2' STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED )
          ( FIELDNAME = 'BUDAT' STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED )
          ( FIELDNAME = 'MAKTX' STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED )
          ( FIELDNAME = 'MENGE' STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED )
          ( FIELDNAME = 'MEINS' STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED )
          ( FIELDNAME = 'TRANS' STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED )
          ( FIELDNAME = 'TRUCK_NO' STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED )
          ( FIELDNAME = 'LOTNO' STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED )
          ( FIELDNAME = 'GRADE' STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED )
           ).

  ENDLOOP.

*3-5) 테이블 저장 후 ALV-STATUS = GREEN 으로 업데이트 및 하단 메시지 처리 "데이터 &건 저장 완료되었습니다."
*3-6) 성공한 데이터라인은 Display 상태로 변경
  DATA:
    LV_CNT   TYPE INT4,
    LV_CNT_C TYPE C LENGTH 10.

  LV_CNT = LINES( LT_CBO ).
  WRITE LV_CNT TO LV_CNT_C LEFT-JUSTIFIED.
  MESSAGE S169 WITH LV_CNT_C.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form F_SAVE_CHANGE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_SAVE_CHANGE .

  CASE ABAP_TRUE.
    WHEN P_ROH.
      PERFORM F_UPDATE_ROH.

    WHEN P_EXW.
      PERFORM F_UPDATE_EXW.

    WHEN OTHERS.
  ENDCASE.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form F_DISPLAY_CHANGE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_DISPLAY_CHANGE .

  CASE ABAP_TRUE.
    WHEN P_ROH.
      PERFORM F_SET_DISP_ROH CHANGING GT_ROH.

    WHEN P_EXW.
      PERFORM F_SET_DISP_EXW CHANGING GT_EXW.

    WHEN OTHERS.
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form F_SET_DISP_ROH
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- GT_ROH
*&---------------------------------------------------------------------*
FORM F_SET_DISP_ROH  CHANGING PT_ROH TYPE TY_T_ROH.

  "ALV 스타일 설정
  CHECK PT_ROH[] IS NOT INITIAL.

  LOOP AT PT_ROH ASSIGNING FIELD-SYMBOL(<LS_LIST>).
        "초기화
    CLEAR <LS_LIST>-ZSTYLE[].
          "변경->조회
    IF <LS_LIST>-ZCHANGE IS NOT INITIAL .
           CLEAR <LS_LIST>-ZCHANGE.
          <LS_LIST>-ZSTYLE = VALUE #(
                      ( FIELDNAME = 'EBELN'  STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED )
                      ( FIELDNAME = 'EBELP'  STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED )
                      ( FIELDNAME = 'BUDAT'  STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED )
                      ( FIELDNAME = 'MENGE'  STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED )
                      ( FIELDNAME = 'MEINS'  STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED )
                      ( FIELDNAME = 'LANCHAR'  STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED )
                    ).
        "조회->변경
    ELSE.
       IF GV_OKCODE IS INITIAL. "최초 조회 일 때,.
           CLEAR <LS_LIST>-ZCHANGE.
          <LS_LIST>-ZSTYLE = VALUE #(
                      ( FIELDNAME = 'EBELN'  STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED )
                      ( FIELDNAME = 'EBELP'  STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED )
                      ( FIELDNAME = 'BUDAT'  STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED )
                      ( FIELDNAME = 'MENGE'  STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED )
                      ( FIELDNAME = 'MEINS'  STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED )
                      ( FIELDNAME = 'LANCHAR'  STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED )
                    ).
       ELSE.
          <LS_LIST>-ZCHANGE = ABAP_TRUE.
          <LS_LIST>-ZSTYLE = VALUE #(
                      ( FIELDNAME = 'EBELN'  STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED )
                      ( FIELDNAME = 'EBELP'  STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED )
                      ( FIELDNAME = 'BUDAT'  STYLE = CL_GUI_ALV_GRID=>MC_STYLE_ENABLED )
                      ( FIELDNAME = 'MENGE'  STYLE = CL_GUI_ALV_GRID=>MC_STYLE_ENABLED )
                      ( FIELDNAME = 'MEINS'  STYLE = CL_GUI_ALV_GRID=>MC_STYLE_ENABLED )
                      ( FIELDNAME = 'LANCHAR'  STYLE = CL_GUI_ALV_GRID=>MC_STYLE_ENABLED )
                    ).
       ENDIF.
    ENDIF.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form F_SET_DISP_EXW
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- GT_EXW
*&---------------------------------------------------------------------*
FORM F_SET_DISP_EXW  CHANGING PT_EXW TYPE TY_T_EXW.

  "ALV 스타일 설정
  CHECK PT_EXW[] IS NOT INITIAL.

  LOOP AT PT_EXW ASSIGNING FIELD-SYMBOL(<LS_LIST>).
        "초기화
    CLEAR <LS_LIST>-ZSTYLE[].
          "변경->조회
    IF <LS_LIST>-ZCHANGE IS NOT INITIAL .
           CLEAR <LS_LIST>-ZCHANGE.
          <LS_LIST>-ZSTYLE = VALUE #(
                      ( FIELDNAME = 'EBELN'  STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED )
                      ( FIELDNAME = 'EBELP'  STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED )
                      ( FIELDNAME = 'BUDAT'  STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED )
                      ( FIELDNAME = 'MENGE'  STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED )
                      ( FIELDNAME = 'MEINS'  STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED )
                      ( FIELDNAME = 'TRANS'  STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED )
                      ( FIELDNAME = 'TRUCK_NO'  STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED )
                      ( FIELDNAME = 'GRADE'  STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED )
                      ( FIELDNAME = 'KUNNR2'  STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED )
                    ).
        "조회->변경
    ELSE.
       IF GV_OKCODE IS INITIAL. "최초 조회 일 때,.
           CLEAR <LS_LIST>-ZCHANGE.
          <LS_LIST>-ZSTYLE = VALUE #(
                      ( FIELDNAME = 'EBELN'  STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED )
                      ( FIELDNAME = 'EBELP'  STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED )
                      ( FIELDNAME = 'BUDAT'  STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED )
                      ( FIELDNAME = 'MENGE'  STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED )
                      ( FIELDNAME = 'MEINS'  STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED )
                      ( FIELDNAME = 'TRANS'  STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED )
                      ( FIELDNAME = 'TRUCK_NO'  STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED )
                      ( FIELDNAME = 'GRADE'  STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED )
                      ( FIELDNAME = 'KUNNR2'  STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED )
                    ).
       ELSE.
          <LS_LIST>-ZCHANGE = ABAP_TRUE.
          <LS_LIST>-ZSTYLE = VALUE #(
                      ( FIELDNAME = 'EBELN'  STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED )
                      ( FIELDNAME = 'EBELP'  STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED )
                      ( FIELDNAME = 'BUDAT'  STYLE = CL_GUI_ALV_GRID=>MC_STYLE_ENABLED )
                      ( FIELDNAME = 'MENGE'  STYLE = CL_GUI_ALV_GRID=>MC_STYLE_ENABLED )
                      ( FIELDNAME = 'MEINS'  STYLE = CL_GUI_ALV_GRID=>MC_STYLE_ENABLED )
                      ( FIELDNAME = 'TRANS'  STYLE = CL_GUI_ALV_GRID=>MC_STYLE_ENABLED )
                      ( FIELDNAME = 'TRUCK_NO'  STYLE = CL_GUI_ALV_GRID=>MC_STYLE_ENABLED )
                      ( FIELDNAME = 'GRADE'  STYLE = CL_GUI_ALV_GRID=>MC_STYLE_ENABLED )
                      ( FIELDNAME = 'KUNNR2'  STYLE = CL_GUI_ALV_GRID=>MC_STYLE_ENABLED )
                    ).
       ENDIF.
    ENDIF.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form F_UPDATE_ROH
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_UPDATE_ROH .

  DATA:
    LT_CBO   TYPE STANDARD TABLE OF ZGTMMT9460,
    LV_CHECK TYPE C LENGTH 1,
    LV_ANS   TYPE C LENGTH 1,
    LT_ROW   TYPE LVC_T_ROID.

  CALL METHOD GO_GRID_100->CHECK_CHANGED_DATA
    IMPORTING
      E_VALID = LV_CHECK.

  CHECK LV_CHECK EQ ABAP_TRUE.

  IF GT_ROH[] IS INITIAL.
    MESSAGE E000 WITH TEXT-E02.
  ENDIF.

  CALL METHOD GO_GRID_100->GET_SELECTED_ROWS
    IMPORTING
      ET_ROW_NO = LT_ROW.
  DELETE LT_ROW WHERE ROW_ID LE 0.

  IF LT_ROW[] IS INITIAL.
    MESSAGE E004. "라인을 선택하세요.
*    DO LINES( GT_EXW ) TIMES.
*      LT_ROW = VALUE #( BASE LT_ROW ( ROW_ID = SY-INDEX ) ).
*    ENDDO.
  ENDIF.

  LOOP AT LT_ROW ASSIGNING FIELD-SYMBOL(<LS_ROW>).
    READ TABLE GT_ROH ASSIGNING FIELD-SYMBOL(<LS_ROH>) INDEX <LS_ROW>-ROW_ID.
    CHECK SY-SUBRC EQ 0.

    LT_CBO = VALUE #( BASE LT_CBO
                 ( VALUE #( BASE CORRESPONDING #( <LS_ROH> )
             AEDAT = SY-DATUM
             AEDAT_LOCAL = SY-DATLO
             AETIM = SY-UZEIT
             AETIM_LOCAL = SY-TIMLO
             AENAM = SY-UNAME
                ) ) ).
  ENDLOOP.

  DATA LV_QUESTION TYPE STRING.
  LV_QUESTION = TEXT-Q03. "데이터를 저장하시겠습니까?

  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      TITLEBAR      = TEXT-TT1
      TEXT_QUESTION = LV_QUESTION
    IMPORTING
      ANSWER        = LV_ANS.
  CHECK LV_ANS EQ GC_1.

  MODIFY ZGTMMT9460 FROM TABLE LT_CBO.
  COMMIT WORK.

  LOOP AT LT_ROW ASSIGNING <LS_ROW>.
    READ TABLE GT_ROH ASSIGNING <LS_ROH> INDEX <LS_ROW>-ROW_ID.
    CHECK SY-SUBRC EQ 0.

    <LS_ROH>-ZCHANGE = ABAP_TRUE.
  ENDLOOP.

*3-5) 테이블 저장 후 ALV-STATUS = GREEN 으로 업데이트 및 하단 메시지 처리 "데이터 &건 저장 완료되었습니다."
*3-6) 성공한 데이터라인은 Display 상태로 변경
  DATA:
    LV_CNT   TYPE INT4,
    LV_CNT_C TYPE C LENGTH 10.

  LV_CNT = LINES( LT_CBO ).
  WRITE LV_CNT TO LV_CNT_C LEFT-JUSTIFIED.
  MESSAGE S169 WITH LV_CNT_C.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form F_UPDATE_EXW
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_UPDATE_EXW .

  DATA:
    LT_CBO   TYPE STANDARD TABLE OF ZGTMMT9461,
    LV_CHECK TYPE C LENGTH 1,
    LV_ANS   TYPE C LENGTH 1,
    LT_ROW   TYPE LVC_T_ROID.

  CALL METHOD GO_GRID_200->CHECK_CHANGED_DATA
    IMPORTING
      E_VALID = LV_CHECK.

  CHECK LV_CHECK EQ ABAP_TRUE.

  IF GT_EXW[] IS INITIAL.
    MESSAGE E000 WITH TEXT-E02.
  ENDIF.

  CALL METHOD GO_GRID_200->GET_SELECTED_ROWS
    IMPORTING
      ET_ROW_NO = LT_ROW.
  DELETE LT_ROW WHERE ROW_ID LE 0.

  IF LT_ROW[] IS INITIAL.
    MESSAGE E004.
  ENDIF.

  CLEAR LV_CHECK.

  LOOP AT LT_ROW ASSIGNING FIELD-SYMBOL(<LS_ROW>).
    READ TABLE GT_EXW ASSIGNING FIELD-SYMBOL(<LS_EXW>) INDEX <LS_ROW>-ROW_ID.
    CHECK SY-SUBRC EQ 0.

    LT_CBO = VALUE #( BASE LT_CBO (
                    VALUE #( BASE CORRESPONDING #( <LS_EXW> )
                                   MAKTX = <LS_EXW>-TXZ01
                                   ERDAT_LOCAL = <LS_EXW>-ERDAT
                                   AEDAT = SY-DATUM
                                   AEDAT_LOCAL = SY-DATLO
                                   AETIM = SY-UZEIT
                                   AETIM_LOCAL = SY-TIMLO
                                   AENAM = SY-UNAME
                                   ) ) ).
  ENDLOOP.

  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      TITLEBAR      = TEXT-TT1
      TEXT_QUESTION = TEXT-Q03 "데이터를 저장하시겠습니까?
    IMPORTING
      ANSWER        = LV_ANS.
  CHECK LV_ANS EQ GC_1.


  MODIFY ZGTMMT9461 FROM TABLE LT_CBO.
  COMMIT WORK.

  LOOP AT LT_ROW ASSIGNING <LS_ROW>.
    READ TABLE GT_EXW ASSIGNING <LS_EXW> INDEX <LS_ROW>-ROW_ID.
    CHECK SY-SUBRC EQ 0.

    <LS_EXW>-ZCHANGE = ABAP_TRUE.
  ENDLOOP.

*3-5) 테이블 저장 후 ALV-STATUS = GREEN 으로 업데이트 및 하단 메시지 처리 "데이터 &건 저장 완료되었습니다."
*3-6) 성공한 데이터라인은 Display 상태로 변경
  DATA:
    LV_CNT   TYPE INT4,
    LV_CNT_C TYPE C LENGTH 10.

  LV_CNT = LINES( LT_CBO ).
  WRITE LV_CNT TO LV_CNT_C LEFT-JUSTIFIED.
  MESSAGE S169 WITH LV_CNT_C.

ENDFORM.
