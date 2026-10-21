*&---------------------------------------------------------------------*
*& INCLUDE          ZGTMMR4390F01
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*& FORM INITIALIZATION
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
FORM INITIALIZATION .

  "기간(YYYYMM)
  P_PERIOD =  SY-DATLO(6)  - 1.

ENDFORM.

*&---------------------------------------------------------------------*
*& FORM SELECTION_SCREEN_OUTPUT
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
FORM SELECTION_SCREEN_OUTPUT .

*  LOOP AT SCREEN.
*    CASE SCREEN-GROUP1.
*
*      WHEN 'YR'.
*         SCREEN-ACTIVE = COND #( WHEN P_YEAR = GC_X THEN 1 ELSE 0 ).
*
*      WHEN 'MON'.
*          SCREEN-ACTIVE = COND #( WHEN P_MON = GC_X THEN 1 ELSE 0 ).
*
*      WHEN 'DAY'.
*          SCREEN-ACTIVE = COND #( WHEN P_DAY = GC_X THEN 1 ELSE 0 ).
*
*      WHEN OTHERS.
*    ENDCASE.
*
*    MODIFY SCREEN.
*  ENDLOOP.

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

  AUTHORITY-CHECK OBJECT 'ZCBO_MM001'
               ID 'EKGRP' FIELD P_EKGRP.

  CHECK SY-SUBRC <> 0.

  SET CURSOR FIELD 'P_EKGRP'.
  MESSAGE E171 WITH P_EKGRP. "구매그룹[&] 작업권한을 확인하세요.

ENDFORM.
*&---------------------------------------------------------------------*
*& FORM F_START_OF_SELECTION
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
*& -->  P1        TEXT
*& <--  P2        TEXT
*&---------------------------------------------------------------------*
FORM F_START_OF_SELECTION .

  PERFORM F_INPUT_VALIDATION.
  CHECK GV_ERR IS INITIAL.

  "데이터 조회
  PERFORM F_GET_DATA.

ENDFORM.

*&---------------------------------------------------------------------*
*& FORM F_END_OF_SELECTION
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
*& -->  P1        TEXT
*& <--  P2        TEXT
*&---------------------------------------------------------------------*
FORM F_END_OF_SELECTION .

  "데이터가 없으면 메세지 처리
  IF GT_LIST[] IS INITIAL.
    MESSAGE S002 DISPLAY LIKE GC_E.
    LEAVE LIST-PROCESSING.
  ENDIF.

  CALL SCREEN 100.

ENDFORM.

*&---------------------------------------------------------------------*
*& FORM F_CHECK_AUTH
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
FORM F_CHECK_AUTH.

  AUTHORITY-CHECK OBJECT 'ZCBO_MM001'
                     ID 'BUKRS' FIELD P_BUKRS.

  CHECK SY-SUBRC <> 0.

  SET CURSOR FIELD 'P_BUKRS'.
  MESSAGE E172 WITH P_BUKRS. "회사코드 [&] 작업권한을 확인하세요.

ENDFORM.

*&---------------------------------------------------------------------*
*& FORM F_INPUT_VALIDATION
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
FORM F_INPUT_VALIDATION.

  CLEAR : GT_LIST, GV_ERR.

  IF P_BUKRS IS INITIAL.
    GV_ERR = GC_X. "회사코드가 누락되었습니다.
    MESSAGE S001 DISPLAY LIKE GC_E.
  ENDIF.

  IF P_WERKS IS INITIAL.
    GV_ERR = GC_X. "플랜트가 누락되었습니다.
    MESSAGE S008 WITH '플랜트' DISPLAY LIKE GC_E.
  ENDIF.

  IF P_EKGRP IS INITIAL.
    GV_ERR = GC_X. "구매그룹이 누락되었습니다.
    MESSAGE S008 WITH '구매그룹' DISPLAY LIKE GC_E.
  ENDIF.

  IF  P_PERIOD IS INITIAL.
    GV_ERR = GC_X. "기간 입력은 필수 입니다.
    MESSAGE S000 WITH TEXT-M01 DISPLAY LIKE GC_E.
  ENDIF.

  CHECK GV_ERR IS INITIAL.

ENDFORM.

*&---------------------------------------------------------------------*
*& FORM F_GET_DATA
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
*& -->  P1        TEXT
*& <--  P2        TEXT
*&---------------------------------------------------------------------*
FORM F_GET_DATA.

  "초기화
  CLEAR GT_LIST[].

  SELECT FROM ZGTMM_CV_GET_OEM_IV_TARGET
    FIELDS *
    WHERE BUKRS = @P_BUKRS
        AND WERKS = @P_WERKS
        AND EKGRP = @P_EKGRP
        AND SPMON = @P_PERIOD
        AND LIFNR IN @S_LIFNR
  INTO CORRESPONDING FIELDS OF TABLE @GT_LIST.

  SORT GT_LIST BY BUKRS WERKS SPMON LIFNR VBELN POSNR.


ENDFORM.

*&---------------------------------------------------------------------*
*& FORM F_REFRESH
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
*& -->  P1        TEXT
*& <--  P2        TEXT
*&---------------------------------------------------------------------*
FORM F_REFRESH .

  "데이터 조회
  PERFORM F_GET_DATA.

ENDFORM.
*&---------------------------------------------------------------------*
*&      FORM  POPUP_TO_CONFIRM_STEP
*&---------------------------------------------------------------------*
*       TEXT
*----------------------------------------------------------------------*
FORM POPUP_TO_CONFIRM_STEP  USING PV_OPT
                                                                PV_TEXT1
                                                                PV_TEXT2
                                                                PV_TITLE.
  CLEAR GV_ANSWER.
  CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
    EXPORTING
      DEFAULTOPTION  = PV_OPT
      TEXTLINE1      = PV_TEXT1
      TEXTLINE2      = PV_TEXT2
      TITEL          = PV_TITLE
      CANCEL_DISPLAY = ''
    IMPORTING
      ANSWER         = GV_ANSWER.

ENDFORM.                    " POPUP_TO_CONFIRM_STEP
*&---------------------------------------------------------------------*
*& FORM SET_CHANGE_TAX
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
*& -->  P1        TEXT
*& <--  P2        TEXT
*&---------------------------------------------------------------------*
FORM SET_CHANGE_TAX .

  CLEAR : GV_ANSWER, GV_ERR.

  PERFORM GET_SELECTED_ROWS USING GO_GRID.
  CHECK GV_ERR IS INITIAL.

  PERFORM POPUP_TO_CONFIRM_STEP  USING 'N' TEXT-M02 '' TEXT-T01.
*  영세율을 10% 세율로 변경 하시겠습니까?
  CHECK GV_ANSWER = ZGTFI_J.

* YES 선택 시 선택된 라인 중 MWSKZ = 'V1'인 데이터를 모두 'VA'로 변환
  SELECT SINGLE TEXT1
     FROM T007S
     WHERE SPRAS = @SY-LANGU
          AND KALSM = 'TAXKR'
          AND MWSKZ = 'VA'
     INTO @DATA(LV_TEXT).

  LOOP AT GT_ROWS INTO GS_ROW.

    READ TABLE GT_LIST  INTO DATA(LS_LIST) INDEX GS_ROW-INDEX.
    IF SY-SUBRC = 0.
      IF LS_LIST-MWSKZ_P = 'V1'.
        LS_LIST-MWSKZ_P = 'VA'.
        LS_LIST-MWSKZ_P_N = LV_TEXT.
        LS_LIST-STATUS = ICON_CHANGE.
      ENDIF.

      MODIFY GT_LIST FROM LS_LIST INDEX GS_ROW-INDEX.
    ENDIF.
  ENDLOOP.


ENDFORM.

*&---------------------------------------------------------------------*
*& FORM SET_SAVE_TAX
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
*& -->  P1        TEXT
*& <--  P2        TEXT
*&---------------------------------------------------------------------*
FORM SET_SAVE_TAX .

  DATA LT_5020 TYPE STANDARD TABLE OF ZGTMMT5020.
  CLEAR : GV_ANSWER, GV_ERR.

  PERFORM GET_SELECTED_ROWS USING GO_GRID.
  CHECK GV_ERR IS INITIAL.

  IF LINE_EXISTS( GT_LIST[ STATUS = ICON_CHANGE ] ).
    PERFORM POPUP_TO_CONFIRM_STEP  USING 'N' TEXT-M03 '' TEXT-T01.
*  변경된 TAX를 저장 하시겠습니까?

  ELSE.
    GV_ERR = ABAP_TRUE. "저장 할 데이터가 없습니다.
    MESSAGE S000 WITH TEXT-M08 DISPLAY LIKE 'E'.
  ENDIF.

  CHECK GV_ANSWER = ZGTFI_J.
  CHECK GV_ERR IS INITIAL.

* YES 선택 시 선택된 라인 중 ALV-STATUS = 'ICON_CHANGE'인 라인을 ZGTMMT5020에 MODIFY
  LOOP AT GT_ROWS INTO GS_ROW.
    READ TABLE GT_LIST  INTO DATA(LS_LIST) INDEX GS_ROW-INDEX.
    IF SY-SUBRC = 0.

      IF LS_LIST-STATUS = ICON_CHANGE.
        LT_5020 = VALUE #( BASE LT_5020 ( VALUE #( BASE CORRESPONDING #( LS_LIST )
                                                                              MWSKZ = LS_LIST-MWSKZ_P
                                                                              ERDAT = SY-DATUM
                                                                              ERDAT_LOCAL = SY-DATLO
                                                                              ERTIM = SY-UZEIT
                                                                              ERTIM_LOCAL = SY-TIMLO
                                                                              ERNAM = SY-UNAME ) ) ).
      ENDIF.
    ENDIF.
  ENDLOOP.

  IF LT_5020 IS NOT INITIAL.
    MODIFY ZGTMMT5020 FROM TABLE LT_5020.
    COMMIT WORK.

    IF SY-SUBRC = 0.
      CLEAR : GS_ROW, LS_LIST.
*MODIFY 성공 후 선택된 라인의 ALV-STATUS = ''으로 초기화
      LOOP AT GT_ROWS INTO GS_ROW.
        READ TABLE GT_LIST  INTO LS_LIST INDEX GS_ROW-INDEX.

        IF SY-SUBRC = 0  AND LS_LIST-STATUS = ICON_CHANGE.
          CLEAR LS_LIST-STATUS .
          MODIFY GT_LIST FROM LS_LIST INDEX GS_ROW-INDEX.
        ENDIF.
      ENDLOOP.
    ENDIF.

    MESSAGE S080. "저장성공
  ELSE.
    MESSAGE S007 DISPLAY LIKE 'E'. "저장할 내역이 없습니다.
  ENDIF.


ENDFORM.
*&---------------------------------------------------------------------*
*& FORM SET_DEL_TAX
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
*& -->  P1        TEXT
*& <--  P2        TEXT
*&---------------------------------------------------------------------*
FORM SET_DEL_TAX .

  DATA: LS_5020 LIKE  ZGTMMT5020,
        LT_5020 TYPE STANDARD TABLE OF ZGTMMT5020.

  CLEAR : GV_ANSWER, GV_ERR.

  PERFORM GET_SELECTED_ROWS USING GO_GRID.
  CHECK GV_ERR IS INITIAL.

  PERFORM POPUP_TO_CONFIRM_STEP  USING 'N' TEXT-M04 TEXT-M05 TEXT-T01.
* 기존 PO 세율로 변경됩니다. 최초 세율로 변경 하시겠습니까?
  CHECK GV_ANSWER = ZGTFI_J.

*YES CLICK 시 선택된 ALV-SPMON,LIFNR,VBEL,POSNR 기준으로 ZGTMMT5020 TABLE DATA 삭제(DELETE)
  LOOP AT GT_ROWS INTO GS_ROW.
    READ TABLE GT_LIST  INTO DATA(LS_LIST) INDEX GS_ROW-INDEX.
    IF SY-SUBRC = 0.
      LS_5020 = CORRESPONDING #( LS_LIST ).
      APPEND LS_5020 TO LT_5020.
      CLEAR LS_5020.
*      SELECT SINGLE *
*        FROM ZGTMMT5020
*        WHERE SPMON = @LS_LIST-SPMON
*             AND LIFNR = @LS_LIST-LIFNR
*             AND EBELN = @LS_LIST-EBELN
*             AND EBELP = @LS_LIST-EBELP
*             AND VBELN = @LS_LIST-VBELN
*             AND POSNR = @LS_LIST-POSNR
*        INTO @LS_5020.
*
*        IF SY-SUBRC = 0 .
*          DELETE ZGTMMT5020 FROM LS_5020.
*          IF SY-SUBRC = 0 .
*             COMMIT WORK AND WAIT.
*          ENDIF.
*        ENDIF.
    ENDIF.
  ENDLOOP.

  IF LT_5020 IS NOT INITIAL.
    SORT LT_5020 BY SPMON LIFNR EBELN EBELP VBELN POSNR.
    DELETE ADJACENT DUPLICATES FROM LT_5020 COMPARING SPMON LIFNR EBELN EBELP VBELN POSNR.

    CHECK LT_5020 IS NOT INITIAL.
    DELETE ZGTMMT5020 FROM TABLE LT_5020.
    COMMIT WORK.

    MESSAGE S000 WITH TEXT-M09. "삭제성공
  ELSE.
    MESSAGE S103 DISPLAY LIKE 'E'. "삭제할 대상이 없습니다.
  ENDIF.

*14) 화면 재 조회
  PERFORM F_GET_DATA.

ENDFORM.
*&---------------------------------------------------------------------*
*& FORM SET_BILLING
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
*& -->  P1        TEXT
*& <--  P2        TEXT
*&---------------------------------------------------------------------*
FORM SET_BILLING .

  CLEAR : GV_ANSWER, GV_ERR.

  PERFORM GET_SELECTED_ROWS USING GO_GRID.
  CHECK GV_ERR IS INITIAL.

  PERFORM POPUP_TO_CONFIRM_STEP  USING 'N' TEXT-M06 '' TEXT-T01.
*선택된 라인에 대해 정산서를 인쇄 하시겠습니까?
  CHECK GV_ANSWER = ZGTFI_J.

*18) YES CLICK 시 SMARTFORM 호출(PDF FILE로 저장 가능해야 함)
*  DATA:
*        LV_FM_NAME       TYPE RS38L_FNAM,
*        LS_CONTROL       TYPE SSFCTRLOP,
*        LS_OUTPUT        TYPE SSFCOMOP,
*        LS_JOB_OUTPUT    TYPE SSFCRESCL, " 스마트폼 결과 데이터(OTF)를 받을 구조체
*        LT_OTF           TYPE TSFOTF,     " OTF 데이터 테이블
*        LT_PDF_TEXT      TYPE TABLE OF TLINE, " PDF 텍스트 테이블
*        LV_PDF_XSTRING   TYPE XSTRING,    " 바이너리 PDF 데이터
*        LV_BIN_FILESIZE  TYPE I,          " 파일 사이즈
*        LV_FILENAME      TYPE STRING,     " 저장할 파일 경로 및 이름
*        LV_PATH          TYPE STRING,
*        LV_FULLPATH      TYPE STRING.

*SMARTFORM 호출 구성용 ITAB
  DATA :
    LS_HEAD TYPE ZGTMMS5006,
    LS_ITEM TYPE ZGTMMS5005,
    LT_ITEM TYPE STANDARD TABLE OF ZGTMMS5005.

  " 하단 합계 정보 구조체
  DATA :
    BEGIN OF LS_SF_SUMMARY,
      V1_MATGR   TYPE ZGTMMS5006-V1_MATGR,
      VA_MATGR   TYPE ZGTMMS5006-VA_MATGR,
      TOT_MATGR  TYPE ZGTMMS5006-TOT_MATGR,
      V1_TCU     TYPE ZGTMMS5006-V1_TCU,
      VA_TCU     TYPE ZGTMMS5006-VA_TCU,
      TOT_TCU    TYPE ZGTMMS5006-TOT_TCU,
      V1_PRICE   TYPE ZGTMMS5006-V1_PRICE,
      VA_PRICE   TYPE ZGTMMS5006-VA_PRICE,
      TOT_PRICE  TYPE ZGTMMS5006-TOT_PRICE,
      VA_TAX     TYPE ZGTMMS5006-VA_TAX,
      TOT_TAX    TYPE ZGTMMS5006-TOT_TAX,
      V1_AMOUNT  TYPE ZGTMMS5006-V1_AMOUNT,
      VA_AMOUNT  TYPE ZGTMMS5006-VA_AMOUNT,
      TOT_AMOUNT TYPE ZGTMMS5006-TOT_AMOUNT,
    END OF LS_SF_SUMMARY.

  FIELD-SYMBOLS: <FS_ALV> LIKE LINE OF GT_LIST.

  " -----------------------------------------------------------------
  " 데이터 가공 및 하단 합계 연산
  " -----------------------------------------------------------------
  CLEAR: LS_HEAD, LT_ITEM, LS_SF_SUMMARY.
  DATA: LV_REGION_NAME TYPE STRING.

  LOOP AT GT_ROWS INTO GS_ROW.

    READ TABLE GT_LIST ASSIGNING <FS_ALV> INDEX GS_ROW-INDEX.
    IF SY-SUBRC = 0.
      IF SY-TABIX = 1.
*HEADER
        SELECT SINGLE CASE WHEN B~BEZEI IS NOT INITIAL
                                          THEN B~BEZEI  ELSE A~ORT01 END
            FROM LFA1 AS A
            LEFT OUTER JOIN T005U AS B ON B~SPRAS = @SY-LANGU
                                                        AND B~LAND1 = A~LAND1
                                                        AND B~BLAND = A~REGIO
            WHERE A~LIFNR = @<FS_ALV>-LIFNR
            INTO @LV_REGION_NAME.

        LS_HEAD-LIFNR      = <FS_ALV>-LIFNR.
        LS_HEAD-LIFNR_N  = <FS_ALV>-LIFNR_N ."&& LV_REGION_NAME. "거래처+지역
        LS_HEAD-PERIOD   = P_PERIOD. "입고년월
        LS_HEAD-CU_LMC = <FS_ALV>-CU_LMC. "적용동가
        LS_HEAD-CU_WAERS = <FS_ALV>-CU_KWAERS. "적용동가통화(원화)
        LS_HEAD-LME       = <FS_ALV>-CU_CASH. "현물가(LME)
        LS_HEAD-WAERS =  <FS_ALV>-CU_WAERS. "현물가격 통화(외화)
        LS_HEAD-EXRATE  = <FS_ALV>-EXRATE_TTS . "환율
        LS_HEAD-MEINS    = <FS_ALV>-MATGR_UNIT.   "입고단위
      ENDIF.
*ITEM
      CLEAR LS_ITEM.
      LS_ITEM = CORRESPONDING #( <FS_ALV> ).
      LS_ITEM-MWSKZ_P_N = COND #( WHEN LS_ITEM-MWSKZ_P = 'V1' THEN '영세'
                                                         WHEN LS_ITEM-MWSKZ_P = 'VA' THEN '내수' ELSE '' ).
      APPEND LS_ITEM TO LT_ITEM .

*하단 표기용 세금코드 별 SUMMARY
      CASE <FS_ALV>-MWSKZ_P.
        WHEN 'V1'. " 영세
          LS_SF_SUMMARY-V1_MATGR = LS_SF_SUMMARY-V1_MATGR + <FS_ALV>-MATGR. "입고수량
          LS_SF_SUMMARY-V1_TCU     = LS_SF_SUMMARY-V1_TCU   + <FS_ALV>-VGW_T_CU. "동량
          LS_SF_SUMMARY-V1_PRICE   = LS_SF_SUMMARY-V1_PRICE + <FS_ALV>-TOTALPRICE. "정산금액(총금액)
        WHEN 'VA'. " 내수
          LS_SF_SUMMARY-VA_MATGR = LS_SF_SUMMARY-VA_MATGR + <FS_ALV>-MATGR.
          LS_SF_SUMMARY-VA_TCU     = LS_SF_SUMMARY-VA_TCU + <FS_ALV>-VGW_T_CU.
          LS_SF_SUMMARY-VA_PRICE  = LS_SF_SUMMARY-VA_PRICE + <FS_ALV>-TOTALPRICE.
      ENDCASE.
    ENDIF.
  ENDLOOP.
*최종 마감 연산
  " 1. 영세 + 내수 입고수량
  LS_SF_SUMMARY-TOT_MATGR =  LS_SF_SUMMARY-V1_MATGR + LS_SF_SUMMARY-VA_MATGR.
  LS_HEAD-TOT_MATGR = LS_SF_SUMMARY-TOT_MATGR.

  " 2. 영세 + 내수 동량
  LS_SF_SUMMARY-TOT_TCU = LS_SF_SUMMARY-V1_TCU + LS_SF_SUMMARY-VA_TCU.
  LS_HEAD-TOT_TCU = LS_SF_SUMMARY-TOT_TCU.

  " 3. 영세 + 내수 정산금액
  LS_SF_SUMMARY-TOT_PRICE = LS_SF_SUMMARY-V1_PRICE + LS_SF_SUMMARY-VA_PRICE.
  LS_HEAD-TOT_PRICE = LS_SF_SUMMARY-TOT_PRICE.

  " 4. 내수 부가세 10%
  LS_SF_SUMMARY-VA_TAX =  LS_SF_SUMMARY-VA_PRICE * '0.1'.
  LS_SF_SUMMARY-TOT_TAX =  LS_SF_SUMMARY-VA_TAX.

  LS_HEAD-TOT_TAX = LS_SF_SUMMARY-TOT_TAX.

  " 5. 영세 합계금액 = 영세 정산금액
  LS_SF_SUMMARY-V1_AMOUNT = LS_SF_SUMMARY-V1_PRICE.
  LS_HEAD-V1_AMOUNT =  LS_SF_SUMMARY-V1_AMOUNT.

  " 6. 내수 합계금액 = 내수 정산금액 + 부가세
  LS_SF_SUMMARY-VA_AMOUNT = LS_SF_SUMMARY-VA_PRICE + LS_SF_SUMMARY-VA_TAX.
  LS_HEAD-VA_AMOUNT =  LS_SF_SUMMARY-VA_AMOUNT.

  " 7. 최종 합계금액
  LS_SF_SUMMARY-TOT_AMOUNT =  LS_SF_SUMMARY-V1_AMOUNT + LS_SF_SUMMARY-VA_AMOUNT.
  LS_HEAD-TOT_AMOUNT = LS_SF_SUMMARY-TOT_AMOUNT.


  " -----------------------------------------------------------------
  " PDF 추출을 위한 스마트폼 제어 옵션
  " -----------------------------------------------------------------
  DATA: RTAB  LIKE KUNNR_RAN  OCCURS 0 WITH HEADER LINE.
  DATA: SSFCRESPD          TYPE SSFCRESPD,
        SSFCRESCL          TYPE SSFCRESCL,
        SSFCRESOP          TYPE SSFCRESOP,
        CONTROL_PARAMETERS TYPE SSFCTRLOP,
        OUTPUT_OPTIONS     TYPE SSFCOMPOP.

  " --- PDF 변환 및 다운로드를 위한 변수 추가 ---
  DATA: LT_STAND_OTF TYPE TABLE OF ITCOO. " 표준 OTF 라인 타입
  DATA: LT_PDF_TEXT     TYPE TABLE OF TLINE, " PDF 텍스트 테이블
        LV_BIN_FILESIZE TYPE I,              " 파일 사이즈
        LV_PDF_XSTRING  TYPE XSTRING,        " 바이너리 PDF 데이터
        LV_FILENAME     TYPE STRING,         " 기본 파일명
        LV_PATH         TYPE STRING,         " 폴더 경로
        LV_FULLPATH     TYPE STRING.         " 전체 경로

  CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
    EXPORTING
      FORMNAME           = 'ZM_MM_GO_OEM_BILLING'
    IMPORTING
      FM_NAME            = FUNC_NAME
    EXCEPTIONS
      NO_FORM            = 1
      NO_FUNCTION_MODULE = 2
      OTHERS             = 3.

  CONTROL_PARAMETERS-GETOTF    = 'X'.
  CONTROL_PARAMETERS-NO_DIALOG = ' '."'X'.
  OUTPUT_OPTIONS-TDNOPREV      = ' '.  " 미리보기 금지 해제
  OUTPUT_OPTIONS-TDDEST        = 'ZP01'. "'LOCL'. " 가상 프린터 지정 필수

  CLEAR SSFCRESCL.
  CALL FUNCTION FUNC_NAME
    EXPORTING
      CONTROL_PARAMETERS   = CONTROL_PARAMETERS
      OUTPUT_OPTIONS       = OUTPUT_OPTIONS
      USER_SETTINGS        = ' '
      PW_HEAD              = LS_HEAD
    IMPORTING
      DOCUMENT_OUTPUT_INFO = SSFCRESPD
      JOB_OUTPUT_INFO      = SSFCRESCL
      JOB_OUTPUT_OPTIONS   = SSFCRESOP
    TABLES
      PT_DATA              = LT_ITEM
    EXCEPTIONS
      FORMATTING_ERROR     = 1
      INTERNAL_ERROR       = 2
      SEND_ERROR           = 3
      USER_CANCELED        = 4
      OTHERS               = 5.

  IF SY-SUBRC <> 0.
    MESSAGE '스마트폼 호출 실패' TYPE 'E'.
    RETURN.
  ENDIF.

*  INSERT LINES OF SSFCRESCL-OTFDATA INTO TABLE OTF.
  LT_STAND_OTF[] = SSFCRESCL-OTFDATA[].

  " =================================================================
  " PDF 변환 및 파일 다운로드
  " =================================================================
  DATA: LT_PDF_BIN TYPE STANDARD TABLE OF SOLIX.

*   1. 스마트폼의 OTF 데이터를 PDF 바이너리로 변환
  CALL FUNCTION 'CONVERT_OTF'
    EXPORTING
      FORMAT                   = 'PDF'
    IMPORTING
      BIN_FILESIZE             = LV_BIN_FILESIZE
      BIN_FILE                 = LV_PDF_XSTRING
    TABLES
      OTF                      = LT_STAND_OTF "SSFCRESCL-OTFDATA
      LINES                    = LT_PDF_TEXT
    EXCEPTIONS
      ERR_MAX_LINEWIDTH        = 1
      ERR_FORMAT               = 2
      ERR_CONVERT_NOT_POSSIBLE = 3
      OTHERS                   = 4.

  IF SY-SUBRC <> 0.
    MESSAGE 'PDF 포맷 변환에 실패했습니다.' TYPE 'E'.
    RETURN.
  ENDIF.

  DATA LV_XSTR_LEN TYPE I.
  LV_XSTR_LEN = XSTRLEN( LV_PDF_XSTRING ).

  IF LV_BIN_FILESIZE = 0.
    LV_BIN_FILESIZE = XSTRLEN( LV_PDF_XSTRING ).
  ENDIF.

  CLEAR LT_PDF_BIN.
  CALL FUNCTION 'SCMS_XSTRING_TO_BINARY'
    EXPORTING
      BUFFER     = LV_PDF_XSTRING
    TABLES
      BINARY_TAB = LT_PDF_BIN
    EXCEPTIONS
      FAILED     = 1
      OTHERS     = 2.

  IF SY-SUBRC <> 0.
    MESSAGE 'PDF 바이너리 변환에 실패했습니다.' TYPE 'E'.
    RETURN.
  ENDIF.

  " 2. PC 파일 저장 창에 띄울 기본 파일명 세팅 (예: 정산서.PDF)
  " 필요하다면 '정산서_' && SY-DATUM && '.PDF' 형태로 동적 생성 가능합니다.
  LV_FILENAME = 'OEM_정산서_' && SY-DATUM && '.PDF'.

  " 3. 사용자 화면에 "어디에 저장하시겠습니까?" 팝업 창 열기
  CALL METHOD CL_GUI_FRONTEND_SERVICES=>FILE_SAVE_DIALOG
    EXPORTING
      DEFAULT_FILE_NAME = LV_FILENAME
      DEFAULT_EXTENSION = 'PDF'
      FILE_FILTER       = '*.PDF'
    CHANGING
      FILENAME          = LV_FILENAME
      PATH              = LV_PATH
      FULLPATH          = LV_FULLPATH
    EXCEPTIONS
      OTHERS            = 1.

  " 4. 사용자가 저장을 취소하지 않고 경로를 정상 선택했을 때만 파일 다운로드 실행
  IF SY-SUBRC = 0 AND LV_FULLPATH IS NOT INITIAL.

    CALL METHOD CL_GUI_FRONTEND_SERVICES=>GUI_DOWNLOAD
      EXPORTING
        BIN_FILESIZE            = LV_BIN_FILESIZE
        FILENAME                = LV_FULLPATH
        FILETYPE                = 'BIN' " 바이너리(PDF) 형식 파일 다운로드
      CHANGING
        DATA_TAB                = LT_PDF_BIN "LT_PDF_TEXT
*      TABLES
*       DATA_TAB                = LT_PDF_TEXT
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
        DP_ERROR_WRITE          = 12
        UNKNOWN_DP_ERROR        = 13
        ACCESS_DENIED           = 14
        DP_OUT_OF_MEMORY        = 15
        DISK_FULL               = 16
        DP_TIMEOUT              = 17
        NOT_SUPPORTED_BY_GUI    = 18
        OTHERS                  = 19.

    IF SY-SUBRC = 0.
      MESSAGE 'PDF 파일이 지정된 경로에 성공적으로 다운로드되었습니다.' TYPE 'S'.
    ELSE.
      MESSAGE '파일 다운로드 중 에러가 발생했습니다.' TYPE 'E'.
    ENDIF.

  ENDIF.


ENDFORM.
*&---------------------------------------------------------------------*
*& FORM SET_BILLING_NEW
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
*& -->  P1        TEXT
*& <--  P2        TEXT
*&---------------------------------------------------------------------*
FORM SET_BILLING_NEW .

  CLEAR : GV_ANSWER, GV_ERR, GS_ROW.

  DATA : LV_LIFNR TYPE LIFNR.

  PERFORM GET_SELECTED_ROWS USING GO_GRID.
  CHECK GV_ERR IS INITIAL.

  READ TABLE GT_ROWS INTO GS_ROW INDEX 1.
  IF SY-SUBRC = 0.

    READ TABLE GT_LIST ASSIGNING FIELD-SYMBOL(<LS_ROW>)  INDEX GS_ROW-INDEX.
    IF SY-SUBRC = 0.
      LV_LIFNR = <LS_ROW>-LIFNR.

      LOOP AT GT_ROWS INTO GS_ROW FROM 2.
        READ TABLE GT_LIST ASSIGNING <LS_ROW> INDEX GS_ROW-INDEX.

        IF SY-SUBRC = 0 AND <LS_ROW>-LIFNR <> LV_LIFNR.
          MESSAGE S000 WITH TEXT-E01 DISPLAY LIKE 'E'.
          GV_ERR = GC_X.
          EXIT.
        ENDIF.
      ENDLOOP.

    ENDIF.
  ENDIF.

  CHECK GV_ERR IS INITIAL.

  PERFORM POPUP_TO_CONFIRM_STEP  USING 'N' TEXT-M06 '' TEXT-T01.
*선택된 라인에 대해 정산서를 인쇄 하시겠습니까?
  CHECK GV_ANSWER = ZGTFI_J.

*SMARTFORM 호출 구성용 ITAB
  DATA :
    LS_HEAD TYPE ZGTMMS5006,
    LS_ITEM TYPE ZGTMMS5005,
    LT_ITEM TYPE STANDARD TABLE OF ZGTMMS5005.

  " 하단 합계 정보 구조체
  DATA :
    BEGIN OF LS_SF_SUMMARY,
      V1_MATGR   TYPE ZGTMMS5006-V1_MATGR,
      VA_MATGR   TYPE ZGTMMS5006-VA_MATGR,
      TOT_MATGR  TYPE ZGTMMS5006-TOT_MATGR,
      V1_TCU     TYPE ZGTMMS5006-V1_TCU,
      VA_TCU     TYPE ZGTMMS5006-VA_TCU,
      TOT_TCU    TYPE ZGTMMS5006-TOT_TCU,
      V1_PRICE   TYPE ZGTMMS5006-V1_PRICE,
      VA_PRICE   TYPE ZGTMMS5006-VA_PRICE,
      TOT_PRICE  TYPE ZGTMMS5006-TOT_PRICE,
      VA_TAX     TYPE ZGTMMS5006-VA_TAX,
      TOT_TAX    TYPE ZGTMMS5006-TOT_TAX,
      V1_AMOUNT  TYPE ZGTMMS5006-V1_AMOUNT,
      VA_AMOUNT  TYPE ZGTMMS5006-VA_AMOUNT,
      TOT_AMOUNT TYPE ZGTMMS5006-TOT_AMOUNT,
    END OF LS_SF_SUMMARY.

  FIELD-SYMBOLS: <FS_ALV> LIKE LINE OF GT_LIST.

  " -----------------------------------------------------------------
  " 데이터 가공 및 하단 합계 연산
  " -----------------------------------------------------------------
  CLEAR: LS_HEAD, LT_ITEM, LS_SF_SUMMARY, GS_ROW.
  DATA: LV_REGION_NAME TYPE STRING.

  LOOP AT GT_ROWS INTO GS_ROW.

    READ TABLE GT_LIST ASSIGNING <FS_ALV> INDEX GS_ROW-INDEX.
    IF SY-SUBRC = 0.
      IF SY-INDEX = 1.
*HEADER
        SELECT SINGLE CASE WHEN B~BEZEI IS NOT INITIAL
                                          THEN B~BEZEI  ELSE A~ORT01 END
            FROM LFA1 AS A
            LEFT OUTER JOIN T005U AS B ON B~SPRAS = @SY-LANGU
                                                        AND B~LAND1 = A~LAND1
                                                        AND B~BLAND = A~REGIO
            WHERE A~LIFNR = @<FS_ALV>-LIFNR
            INTO @LV_REGION_NAME.

        LS_HEAD-LIFNR      = <FS_ALV>-LIFNR.
        LS_HEAD-LIFNR_N  = <FS_ALV>-LIFNR_N .
        LS_HEAD-PERIOD   = P_PERIOD. "입고년월
        LS_HEAD-CU_LMC = <FS_ALV>-CU_LMC. "적용동가
        LS_HEAD-CU_WAERS = <FS_ALV>-CU_KWAERS. "적용동가통화(원화)
        LS_HEAD-LME       = <FS_ALV>-CU_CASH. "현물가(LME)
        LS_HEAD-WAERS =  <FS_ALV>-KONWA. "CU_WAERS. "현물가격 통화(외화)
        LS_HEAD-EXRATE  = <FS_ALV>-EXRATE_TTS . "환율
        LS_HEAD-MEINS    = <FS_ALV>-KMEIN. "MATGR_UNIT.   "입고단위
      ENDIF.
*ITEM
      CLEAR LS_ITEM.
      LS_ITEM = CORRESPONDING #( <FS_ALV> ).
      SHIFT LS_ITEM-POSNR LEFT DELETING LEADING '0'.
      LS_ITEM-MATGR = TRUNC( LS_ITEM-MATGR ).
      LS_ITEM-WAERS = <FS_ALV>-KONWA.
      LS_ITEM-MEINS = <FS_ALV>-KMEIN.
      LS_ITEM-MWSKZ_P_N = COND #( WHEN LS_ITEM-MWSKZ_P = 'V1' THEN '영세'
                                                         WHEN LS_ITEM-MWSKZ_P = 'VA' THEN '내수' ELSE '' ).
      APPEND LS_ITEM TO LT_ITEM .

*하단 표기용 세금코드 별 SUMMARY
      CASE <FS_ALV>-MWSKZ_P.
        WHEN 'V1'. " 영세
          LS_SF_SUMMARY-V1_MATGR = LS_SF_SUMMARY-V1_MATGR + <FS_ALV>-MATGR. "입고수량
          LS_SF_SUMMARY-V1_TCU     = LS_SF_SUMMARY-V1_TCU   + <FS_ALV>-VGW_T_CU. "동량
          LS_SF_SUMMARY-V1_PRICE   = LS_SF_SUMMARY-V1_PRICE + <FS_ALV>-TOTALPRICE. "정산금액(총금액)
        WHEN 'VA'. " 내수
          LS_SF_SUMMARY-VA_MATGR = LS_SF_SUMMARY-VA_MATGR + <FS_ALV>-MATGR.
          LS_SF_SUMMARY-VA_TCU     = LS_SF_SUMMARY-VA_TCU + <FS_ALV>-VGW_T_CU.
          LS_SF_SUMMARY-VA_PRICE  = LS_SF_SUMMARY-VA_PRICE + <FS_ALV>-TOTALPRICE.
*          LS_SF_SUMMARY-VA_TAX  = LS_SF_SUMMARY-VA_TAX + <FS_ALV>-TAXVALUE.
      ENDCASE.
    ENDIF.
  ENDLOOP.

*최종 마감 연산
  " 1. 영세 + 내수 입고수량
  LS_SF_SUMMARY-TOT_MATGR =  LS_SF_SUMMARY-V1_MATGR + LS_SF_SUMMARY-VA_MATGR.
  LS_HEAD-TOT_MATGR = LS_SF_SUMMARY-TOT_MATGR.
  LS_HEAD-V1_MATGR = LS_SF_SUMMARY-V1_MATGR.
  LS_HEAD-VA_MATGR = LS_SF_SUMMARY-VA_MATGR.

  " 2. 영세 + 내수 동량
  LS_SF_SUMMARY-TOT_TCU = LS_SF_SUMMARY-V1_TCU + LS_SF_SUMMARY-VA_TCU.
  LS_HEAD-TOT_TCU = LS_SF_SUMMARY-TOT_TCU.
  LS_HEAD-V1_TCU = LS_SF_SUMMARY-V1_TCU.
  LS_HEAD-VA_TCU = LS_SF_SUMMARY-VA_TCU.

  " 3. 영세 + 내수 정산금액
  LS_SF_SUMMARY-TOT_PRICE = LS_SF_SUMMARY-V1_PRICE + LS_SF_SUMMARY-VA_PRICE.
  LS_HEAD-TOT_PRICE = LS_SF_SUMMARY-TOT_PRICE.
  LS_HEAD-V1_PRICE = LS_SF_SUMMARY-V1_PRICE.
  LS_HEAD-VA_PRICE = LS_SF_SUMMARY-VA_PRICE.

  " 4. 내수 부가세 10%
*ALV-TAXVALUE합산->내수 정산금액 * 0.1로 변경.(1원단위로 차이 발생 때문)
  PERFORM CONVERT_CURRENCY_IDOC USING LS_SF_SUMMARY-VA_PRICE CHANGING LS_SF_SUMMARY-VA_PRICE.
  LS_SF_SUMMARY-TOT_TAX =  LS_SF_SUMMARY-VA_PRICE * '0.1'. "LS_SF_SUMMARY-VA_TAX.
  LS_HEAD-TOT_TAX = LS_HEAD-VA_TAX  = TRUNC( LS_SF_SUMMARY-TOT_TAX ).
*  LS_HEAD-TOT_TAX = LS_HEAD-VA_TAX  = LS_SF_SUMMARY-TOT_TAX.

  " 5. 영세 합계금액 = 영세 정산금액
  PERFORM CONVERT_CURRENCY_IDOC USING LS_SF_SUMMARY-V1_PRICE CHANGING LS_SF_SUMMARY-V1_PRICE.
  LS_SF_SUMMARY-V1_AMOUNT = LS_SF_SUMMARY-V1_PRICE.
  LS_HEAD-V1_AMOUNT =  LS_SF_SUMMARY-V1_AMOUNT.

  " 6. 내수 합계금액 = 내수 정산금액 + 부가세
  LS_HEAD-VA_AMOUNT =  LS_SF_SUMMARY-VA_PRICE + LS_HEAD-TOT_TAX.

*" 7. 최종 합계금액
*  LS_SF_SUMMARY-TOT_AMOUNT =  LS_SF_SUMMARY-V1_AMOUNT + LS_SF_SUMMARY-VA_AMOUNT.
*  LS_HEAD-TOT_AMOUNT = LS_SF_SUMMARY-TOT_AMOUNT.

  PERFORM CONVERT_CURRENCY_SAP USING LS_HEAD-VA_TAX CHANGING LS_HEAD-VA_TAX.
  PERFORM CONVERT_CURRENCY_SAP USING LS_HEAD-TOT_TAX CHANGING LS_HEAD-TOT_TAX.
  PERFORM CONVERT_CURRENCY_SAP USING LS_HEAD-VA_AMOUNT CHANGING LS_HEAD-VA_AMOUNT.
  PERFORM CONVERT_CURRENCY_SAP USING LS_HEAD-V1_AMOUNT CHANGING LS_HEAD-V1_AMOUNT.
  " 7. 최종 합계금액
  LS_HEAD-TOT_AMOUNT = LS_HEAD-VA_AMOUNT + LS_HEAD-V1_AMOUNT .

  " -----------------------------------------------------------------
  " PDF 추출을 위한 스마트폼 제어 옵션
  " -----------------------------------------------------------------
  DATA: RTAB  LIKE KUNNR_RAN  OCCURS 0 WITH HEADER LINE.
  DATA: SSFCRESPD          TYPE SSFCRESPD,
        SSFCRESCL          TYPE SSFCRESCL,
        SSFCRESOP          TYPE SSFCRESOP,
        CONTROL_PARAMETERS TYPE SSFCTRLOP,
        OUTPUT_OPTIONS     TYPE SSFCOMPOP.

  " --- PDF 변환 및 다운로드를 위한 변수 추가 ---
  DATA: LT_STAND_OTF TYPE TABLE OF ITCOO. " 표준 OTF 라인 타입
  DATA: LT_PDF_TEXT     TYPE TABLE OF TLINE, " PDF 텍스트 테이블
        LV_BIN_FILESIZE TYPE I,              " 파일 사이즈
        LV_PDF_XSTRING  TYPE XSTRING,        " 바이너리 PDF 데이터
        LV_FILENAME     TYPE STRING,         " 기본 파일명
        LV_PATH         TYPE STRING,         " 폴더 경로
        LV_FULLPATH     TYPE STRING.         " 전체 경로

  CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
    EXPORTING
      FORMNAME           = 'ZM_MM_GO_OEM_BILLING'
    IMPORTING
      FM_NAME            = FUNC_NAME
    EXCEPTIONS
      NO_FORM            = 1
      NO_FUNCTION_MODULE = 2
      OTHERS             = 3.

  CLEAR CONTROL_PARAMETERS.
  CONTROL_PARAMETERS-NO_DIALOG = ' '. " <--인쇄 팝업창을 보여줌

  " 가상 PDF 프린터로 세팅
  OUTPUT_OPTIONS-TDDEST        = 'LP01'.
  OUTPUT_OPTIONS-TDNOPREV   = ' '.    " 인쇄 미리보기 금지 해제 (미리보기 허용)

  CLEAR SSFCRESCL.
  CALL FUNCTION FUNC_NAME
    EXPORTING
      CONTROL_PARAMETERS   = CONTROL_PARAMETERS
      OUTPUT_OPTIONS       = OUTPUT_OPTIONS
      USER_SETTINGS        = ' '
      PW_HEAD              = LS_HEAD
    IMPORTING
      DOCUMENT_OUTPUT_INFO = SSFCRESPD
      JOB_OUTPUT_INFO      = SSFCRESCL
      JOB_OUTPUT_OPTIONS   = SSFCRESOP
    TABLES
      PT_DATA              = LT_ITEM
    EXCEPTIONS
      FORMATTING_ERROR     = 1
      INTERNAL_ERROR       = 2
      SEND_ERROR           = 3
      USER_CANCELED        = 4
      OTHERS               = 5.

  IF SY-SUBRC <> 0.
    MESSAGE '스마트폼 호출 실패' TYPE 'E'.
    RETURN.
  ENDIF.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form CONVERT_CURRENCY
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM CONVERT_CURRENCY_SAP USING PV_PRICE
                                       CHANGING PV_EX_PRICE .

  DATA LV_AMOUNT(20) TYPE C.

  LV_AMOUNT = PV_PRICE.
  CONDENSE LV_AMOUNT NO-GAPS.

  CALL FUNCTION 'CURRENCY_AMOUNT_IDOC_TO_SAP'
    EXPORTING
      CURRENCY    = 'KRW'
      IDOC_AMOUNT = LV_AMOUNT
    IMPORTING
      SAP_AMOUNT  = LV_AMOUNT.

  PV_EX_PRICE = LV_AMOUNT.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CONVERT_CURRENCY
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM CONVERT_CURRENCY_IDOC  USING PV_PRICE
                                       CHANGING PV_EX_PRICE .

  DATA LV_AMOUNT(20) TYPE C.
  LV_AMOUNT = PV_PRICE.  CONDENSE LV_AMOUNT NO-GAPS.

  CALL FUNCTION 'CURRENCY_AMOUNT_SAP_TO_IDOC'
    EXPORTING
      CURRENCY    = 'KRW'
      SAP_AMOUNT  = LV_AMOUNT
    IMPORTING
      IDOC_AMOUNT = LV_AMOUNT.
  PV_EX_PRICE = LV_AMOUNT.

ENDFORM.
