*&---------------------------------------------------------------------*
*& Include          ZGTMMR4360F01
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

  "납품일자
  IF S_BLDAT[] IS INITIAL.
    S_BLDAT[] = VALUE #( ( SIGN = 'I' OPTION = 'BT' LOW = SY-DATLO - 30  HIGH = SY-DATLO ) ).
  ENDIF.

  "입고일자
  IF S_BUDAT[] IS INITIAL.
    S_BUDAT[] = VALUE #( ( SIGN = 'I' OPTION = 'BT' LOW = SY-DATLO - 30  HIGH = SY-DATLO ) ).
  ENDIF.

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
  DATA : LV_MATNR TYPE ZLET0401-MATNR,
         LV_LIFNR TYPE LIFNR.

*공통코드 데이터 가져오기->조회조건 레인지 구성.
*해당 자재/공급업체_LS DATA 가져오기 위한 조건.
  SELECT CODEGRP,
               FLD_01,
               FLD_02,
               FLD_03,
               FLD_04
  FROM ZGTPPT1010
  WHERE MODULE_KIND = 'MM'
  AND ( CODEGRP = '0860' OR CODEGRP = '0870' OR CODEGRP = '0880')
  INTO CORRESPONDING FIELDS OF TABLE @GT_ZGTPPT1010.
  SORT GT_ZGTPPT1010 BY FLD_01 FLD_03.

***조회 조건 별 메인 데이터 가져오기
  CASE ABAP_TRUE.
*"전기동
    WHEN P_ELC.
      CLEAR : GR_LIFNR, GR_MATNR, LV_LIFNR, LV_MATNR.

      LOOP AT GT_ZGTPPT1010 INTO DATA(LS_1010).
        IF LS_1010-CODEGRP = '0860'.
          LV_LIFNR = |{ LS_1010-FLD_01 ALPHA = IN }|.

          APPEND VALUE #( SIGN = 'I'
                                  OPTION = 'EQ'
                                      LOW = LV_LIFNR )
          TO GR_LIFNR.

          CALL FUNCTION 'CONVERSION_EXIT_MATN1_INPUT'
            EXPORTING
              INPUT        = LS_1010-FLD_03
            IMPORTING
              OUTPUT       = LV_MATNR
            EXCEPTIONS
              LENGTH_ERROR = 1
              OTHERS       = 2.

          APPEND VALUE #( SIGN = 'I'
                                  OPTION = 'EQ'
                                       LOW =  LV_MATNR )
          TO GR_MATNR.
        ENDIF.
      ENDLOOP.

      IF P_GR EQ ABAP_TRUE.  "입고처리
        PERFORM F_GET_MATDOC_DATA_GR.

      ELSEIF P_DISP EQ ABAP_TRUE.  "처리결과조회
        PERFORM F_GET_MATDOC_DATA_DISP.
      ENDIF.

    WHEN P_SCR. "SCR
*"SCR
      CLEAR : GR_LIFNR, GR_MATNR, LV_LIFNR, LV_MATNR, LS_1010.

      LOOP AT GT_ZGTPPT1010 INTO LS_1010.
        IF LS_1010-CODEGRP = '0870'.
          LV_LIFNR = |{ LS_1010-FLD_01 ALPHA = IN }|.

          APPEND VALUE #( SIGN = 'I'
                                  OPTION = 'EQ'
                                      LOW = LV_LIFNR )
          TO GR_LIFNR.

*             CALL FUNCTION 'CONVERSION_EXIT_MATN1_INPUT'
*                EXPORTING
*                  INPUT  = LS_1010-FLD_03
*                IMPORTING
*                  OUTPUT = LV_MATNR
*                EXCEPTIONS
*                  LENGTH_ERROR = 1
*                OTHERS       = 2.
*
*            APPEND VALUE #( SIGN = 'I'
*                                    OPTION = 'EQ'
*                                         LOW =  LV_MATNR )
*            TO GR_MATNR.
        ENDIF.
      ENDLOOP.

      "입고처리
      IF P_GR EQ ABAP_TRUE.
        PERFORM F_GET_MATDOC_DATA_SCR_GR.
        " 처리결과조회
      ELSEIF P_DISP EQ ABAP_TRUE.
        PERFORM F_GET_MATDOC_DATA_SCR_DISP.
      ENDIF.

  ENDCASE.

  "ALV 스타일 설정
  PERFORM F_SET_ALV_STYLE.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_SET_ALV_STYLE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_SET_ALV_STYLE .

  CASE ABAP_TRUE.
    WHEN P_ELC.
      CHECK GT_LIST[] IS NOT INITIAL.

      LOOP AT GT_LIST ASSIGNING FIELD-SYMBOL(<LS_LIST>).
        "초기화
        CLEAR <LS_LIST>-ZSTYLE[].

        IF <LS_LIST>-GR_FIN IS INITIAL.
          <LS_LIST>-ZSTYLE = VALUE #(
                      ( FIELDNAME = 'EBELN'  STYLE = CL_GUI_ALV_GRID=>MC_STYLE_ENABLED )
                      ( FIELDNAME = 'EBELP'  STYLE = CL_GUI_ALV_GRID=>MC_STYLE_ENABLED )
                      ( FIELDNAME = 'ERFMG'  STYLE = CL_GUI_ALV_GRID=>MC_STYLE_ENABLED )
                    ).
          "입고완료 후 편집불가
        ELSE.
          <LS_LIST>-ZSTYLE = VALUE #(
                      ( FIELDNAME = 'EBELN'  STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED )
                      ( FIELDNAME = 'EBELP'  STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED )
                      ( FIELDNAME = 'ERFMG'  STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED )
                    ).
        ENDIF.
      ENDLOOP.

    WHEN P_SCR.
      CHECK GT_SCR_LIST[] IS NOT INITIAL.

      LOOP AT GT_SCR_LIST ASSIGNING FIELD-SYMBOL(<LS_SCR>).
        "초기화
        CLEAR <LS_SCR>-ZSTYLE[].

*         "입고 전_조건 별 제어
        IF <LS_SCR>-GR_FIN IS INITIAL.
          "가온 데이터이면 DISPLAY
          IF <LS_SCR>-ZCHK = GC_X.
            <LS_SCR>-ZSTYLE = VALUE #( BASE <LS_SCR>-ZSTYLE
                    ( FIELDNAME = 'EBELN'  STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED )
                    ( FIELDNAME = 'EBELP'  STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED )
                  ).
            "LS 시스템 데이터이면 EDITABLE
          ELSE.
            <LS_SCR>-ZSTYLE = VALUE #( BASE <LS_SCR>-ZSTYLE
                    ( FIELDNAME = 'EBELN'  STYLE = CL_GUI_ALV_GRID=>MC_STYLE_ENABLED )
                    ( FIELDNAME = 'EBELP'  STYLE = CL_GUI_ALV_GRID=>MC_STYLE_ENABLED )
                  ).
          ENDIF.
          "EDITABLE 공통
          <LS_SCR>-ZSTYLE = VALUE #( BASE <LS_SCR>-ZSTYLE
                      ( FIELDNAME = 'KUNNR'  STYLE = CL_GUI_ALV_GRID=>MC_STYLE_ENABLED )
                      ( FIELDNAME = 'VBELN'  STYLE = CL_GUI_ALV_GRID=>MC_STYLE_ENABLED )
                      ( FIELDNAME = 'POSNR'  STYLE = CL_GUI_ALV_GRID=>MC_STYLE_ENABLED )
                      ( FIELDNAME = 'LGORT'  STYLE = CL_GUI_ALV_GRID=>MC_STYLE_ENABLED )
                      ( FIELDNAME = 'GOGRADE'  STYLE = CL_GUI_ALV_GRID=>MC_STYLE_ENABLED )
                    ).

*          "입고완료 후 모든 필드 DISPLAY
        ELSE.
          <LS_SCR>-ZSTYLE = VALUE #( BASE <LS_SCR>-ZSTYLE
                    ( FIELDNAME = 'EBELN'  STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED )
                    ( FIELDNAME = 'EBELP'  STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED )
                    ( FIELDNAME = 'KUNNR'  STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED )
                    ( FIELDNAME = 'VBELN'  STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED )
                    ( FIELDNAME = 'POSNR'  STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED )
                    ( FIELDNAME = 'LGORT'  STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED )
                    ( FIELDNAME = 'GOGRADE'  STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED )
                  ).
        ENDIF.

      ENDLOOP.
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

  "데이터가 없으면 메세지 처리
  IF P_ELC = GC_X AND GT_LIST[] IS INITIAL
    OR P_SCR = GC_X AND GT_SCR_LIST[] IS INITIAL..
    MESSAGE S002 DISPLAY LIKE GC_E.
    LEAVE LIST-PROCESSING.
  ENDIF.

  "Screen 100
  CALL SCREEN 100.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_REFRESH
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_REFRESH .

  "데이터 다시 조회
  PERFORM F_START_OF_SELECTION.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_EBELN_POP
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_EBELN_POP .

  "초기화
  CLEAR:
   GS_SCR.
*   GT_BAT[],
*   GT_POP[].

  DATA LV_VALID TYPE C LENGTH 1.
  CALL METHOD GO_GRID_100->CHECK_CHANGED_DATA
    IMPORTING
      E_VALID = LV_VALID.
  CHECK LV_VALID EQ ABAP_TRUE.

*  1. 구매오더  조회/등록 버튼
*1-1) 선택한 라인이 없는 경우 하단 에러 메시지 "선택한 데이터가 없습니다."
  CALL METHOD GO_GRID_100->GET_SELECTED_ROWS
    IMPORTING
      ET_ROW_NO = GT_ROW.

  DELETE GT_ROW WHERE ROW_ID LE 0.

  IF GT_ROW[] IS INITIAL.
    MESSAGE E050.
  ENDIF.

  IF P_SCR = GC_X.
    LOOP AT GT_ROW ASSIGNING FIELD-SYMBOL(<LS_ROW>).
      READ TABLE GT_SCR_LIST ASSIGNING FIELD-SYMBOL(<LS_LIST>) INDEX <LS_ROW>-ROW_ID.
      CHECK SY-SUBRC EQ 0.
*1-2) 선택한 라인에 EBELN, EBELP 값이 존재하고 필드 상태가 Display 이면
*하단 오류 메시지 "이미 저장된 입고실적 데이터 입니다."
      IF ( <LS_LIST>-EBELN IS NOT INITIAL OR  <LS_LIST>-EBELN IS NOT INITIAL )
         AND <LS_LIST>-ZCHK = GC_X.
        MESSAGE E000 WITH TEXT-E10.
      ENDIF.
    ENDLOOP.
  ENDIF.

*1-2) 선택한 라인이 존재하면 구매오더 조회 용 POP-UP을 Display
  "화면호출
  CALL SCREEN 300 STARTING AT 1 4.
  PERFORM F_REFRESH_ALV USING GO_GRID_100.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_VBELN_POP
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_VBELN_POP .

  "초기화
  CLEAR:
   GS_SCR,
   GT_BAT[],
   GT_POP[].

  DATA LV_VALID TYPE C LENGTH 1.
  CALL METHOD GO_GRID_100->CHECK_CHANGED_DATA
    IMPORTING
      E_VALID = LV_VALID.
  CHECK LV_VALID EQ ABAP_TRUE.

*  1. 구매오더  조회/등록 버튼
*1-1) 선택한 라인이 없는 경우 하단 에러 메시지 "선택한 데이터가 없습니다."
  CALL METHOD GO_GRID_100->GET_SELECTED_ROWS
    IMPORTING
      ET_ROW_NO = GT_ROW.

  DELETE GT_ROW WHERE ROW_ID LE 0.

  IF GT_ROW[] IS INITIAL.
    MESSAGE E050.
  ENDIF.

*  IF P_SCR = GC_X.
*  LOOP AT GT_ROW ASSIGNING FIELD-SYMBOL(<LS_ROW>).
*    READ TABLE GT_SCR_LIST ASSIGNING FIELD-SYMBOL(<LS_LIST>) INDEX <LS_ROW>-ROW_ID.
*    CHECK SY-SUBRC EQ 0.
**1-2) 선택한 라인에 VBELN, POSNR 값이 존재하고 필드 상태가 Display 이면
**하단 오류 메시지 "이미 저장된 입고실적 데이터 입니다."
*    IF ( <LS_LIST>-VBELN IS NOT INITIAL OR  <LS_LIST>-POSNR IS NOT INITIAL )
*       AND <LS_LIST>-ZCHK = GC_X.
*      MESSAGE E000 WITH TEXT-E10.
*    ENDIF.
*  ENDLOOP.
*  ENDIF.

*1-2) 선택한 라인이 존재하면 구매오더 조회 용 POP-UP을 Display
  "화면호출
  CALL SCREEN 300 STARTING AT 1 4.
  PERFORM F_REFRESH_ALV USING GO_GRID_100.

ENDFORM.

**&---------------------------------------------------------------------*
**& Form F_SET_ERFMG
**&---------------------------------------------------------------------*
**& text
**&---------------------------------------------------------------------*
**& -->  p1        text
**& <--  p2        text
**&---------------------------------------------------------------------*
*FORM F_SET_ERFMG .
*
*  DATA LV_VALID TYPE C LENGTH 1.
*  CALL METHOD GO_GRID_200->CHECK_CHANGED_DATA
*    IMPORTING
*      E_VALID = LV_VALID.
*  CHECK LV_VALID EQ ABAP_TRUE.
*
**2-6) 입력한 처리 수량 > UNQTY 수량 이면 하단 오류 메시지 "처리 수량을 확인하세요."
**2-7) 예약오더에 지정된 배치번호에 해당하는 재고 수량이 없는 경우 하단 오류 메세지 "지정된 배치의 재고 수량을 확인하세요."
**2-8) 처리 대상 입력 후 체크 버튼 선택시 선행 화면의 처리 수량(ERFMG) 에 반영하고 별도 Internal Table 배치별재고 입력 현황을 내부 저장
**: BAPI 실행 시 처리해야할 BATCH 정보 수집 목적으로 별도관리
*
*  LOOP AT GT_POP ASSIGNING FIELD-SYMBOL(<LS_POP>).
*    CHECK <LS_POP>-ERFMG IS NOT INITIAL.
*
*    IF <LS_POP>-ERFMG GT <LS_POP>-UNQTY.
*      MESSAGE E000 WITH TEXT-E04. "처리 수량을 확인하세요.
*    ENDIF.
*
*    IF GS_SCR-CHARG IS NOT INITIAL AND GS_SCR-CHARG EQ <LS_POP>-CHARG
*      AND <LS_POP>-UNQTY IS INITIAL.
*      MESSAGE E000 WITH TEXT-E10. "지정된 배치의 재고 수량을 확인하세요.
*    ENDIF.
*
*    GT_BAT[] = VALUE #( BASE GT_BAT ( CORRESPONDING #( <LS_POP> ) ) ).
*  ENDLOOP.
*
*  IF GS_SCR-CHARG IS NOT INITIAL.
**    SELECT SINGLE ZZ~CHARG
**      FROM @GT_BAT AS ZZ
**      WHERE ZZ~CHARG EQ @GS_SCR-CHARG
**      INTO @DATA(LV_CHK).
**    IF SY-SUBRC NE 0.
**      CLEAR GT_BAT[].
**      MESSAGE E000 WITH TEXT-E10. "지정된 배치의 재고 수량을 확인하세요.
**    ENDIF.
*  ENDIF.
*
*  LEAVE TO SCREEN 0.
*
*ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_POST
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_POST .

*2. 입고 처리 버튼 선택
*2-1) 라인은 다중선택 가능 (전체선택 포함)

  DATA LV_VALID TYPE C LENGTH 1.
  CALL METHOD GO_GRID_100->CHECK_CHANGED_DATA
    IMPORTING
      E_VALID = LV_VALID.
  CHECK LV_VALID EQ ABAP_TRUE.

*2-2) 선택한 라인이 없는 경우 하단 에러 메시지 "선택한 데이터가 없습니다."
  CALL METHOD GO_GRID_100->GET_SELECTED_ROWS
    IMPORTING
      ET_ROW_NO = GT_ROW.

  DELETE GT_ROW WHERE ROW_ID LE 0.
  IF GT_ROW[] IS INITIAL.
    MESSAGE E050.
  ENDIF.

  CLEAR : GT_RUN, GV_GR.

  DATA:
    LT_RUN  LIKE STANDARD TABLE OF GS_RUN,
    LS_RUN  LIKE LINE OF GT_RUN,
    LT_9470 TYPE STANDARD TABLE OF ZGTMMT9470.

  LOOP AT GT_ROW ASSIGNING FIELD-SYMBOL(<LS_ROW>).
    READ TABLE GT_LIST ASSIGNING FIELD-SYMBOL(<LS_LIST>) INDEX <LS_ROW>-ROW_ID.
    CHECK SY-SUBRC EQ 0.
*2-3) 선택한 라인의 상태 ="GREEN" 인 경우 하단 에러메세지 "처리 상태를 확인하세요.
    IF <LS_LIST>-STATUS EQ ICON_LED_GREEN.
      MESSAGE E000 WITH TEXT-E05.
    ENDIF.

*2-4) 선택한 라인에 입고수량이 입력되지않은 경우 하단 오류 메시지 "처리 수량을 입력하세요."
    IF <LS_LIST>-ERFMG IS INITIAL.
      MESSAGE E000 WITH TEXT-E07.
    ENDIF.

*선택한 라인에 구매오더 미지정 : 구매오더 정보를 입력하세요.
    IF <LS_LIST>-EBELN IS INITIAL OR <LS_LIST>-EBELP IS INITIAL.
      MESSAGE E000 WITH TEXT-E04.
    ENDIF.

    "실행 대상
    LS_RUN = CORRESPONDING #( <LS_LIST> ).
    LS_RUN-TABIX = <LS_ROW>-ROW_ID.
    APPEND LS_RUN TO GT_RUN. "LT_RUN.
  ENDLOOP.

  CHECK GT_RUN[] IS NOT INITIAL.

*  2-5) 선택한 라인의 상태 <> "GREEN" 인 경우 하단 POP-UP 확인 후 입고처리
  CLEAR GS_SCR.
  GS_SCR-ZTEXT = TEXT-M01. "입고 처리 하시겠습니까?
  GS_SCR-BUDAT = SY-DATUM.
  CALL SCREEN 300 STARTING AT 1 4.

*  CHECK GS_SCR-ZOK EQ ABAP_TRUE. "Yes를 누른경우 진행

**  : 자재문서는 선택한 데이터 기준 BUDAT(입고일자) 별로 분할 생성
*  "bapi 사용
*  DATA:
*    "LV_LINE_ID TYPE MB_LINE_ID,
*    LS_HEADER TYPE BAPI2017_GM_HEAD_01,
*    LS_CODE   TYPE BAPI2017_GM_CODE,
*    LT_ITEM   TYPE STANDARD TABLE OF BAPI2017_GM_ITEM_CREATE,
*    LT_RETURN TYPE STANDARD TABLE OF BAPIRET2,
*    LS_HDRET  TYPE BAPI2017_GM_HEAD_RET.
*
*  LOOP AT LT_RUN ASSIGNING FIELD-SYMBOL(<LS_G1>) GROUP BY ( BUDAT = <LS_G1>-BUDAT )
*                                                                             ASSIGNING FIELD-SYMBOL(<LS_GROUP1>).
*
*    "초기화
*    CLEAR:
*      LS_CODE,
*      LS_HEADER,
*      LT_ITEM[],
*      LT_RETURN[],
*      LS_HDRET.
*
*    "CODE 설정
*    LS_CODE-GM_CODE = GC_01.
*
*    "헤더
*    LS_HEADER-PSTNG_DATE = <LS_GROUP1>-BUDAT.
*    LS_HEADER-DOC_DATE = <LS_GROUP1>-BUDAT.
*    LS_HEADER-PR_UNAME = SY-UNAME.
*
*    "아이템
*    LOOP AT GROUP <LS_GROUP1> ASSIGNING FIELD-SYMBOL(<LS_RUN>).
*        LT_ITEM = VALUE #( BASE LT_ITEM ( MOVE_TYPE = GC_101
*                                                MATERIAL = <LS_RUN>-POMAT
*                                                PLANT = <LS_RUN>-WERKS
*                                                STGE_LOC = <LS_RUN>-LGORT
*                                                PO_NUMBER = <LS_RUN>-EBELN
*                                                PO_ITEM = <LS_RUN>-EBELP
*                                                SPEC_STOCK = COND #( WHEN <LS_RUN>-EMLIF IS INITIAL THEN ''
*                                                                                      ELSE 'O' )
*                                                VENDOR = <LS_RUN>-LIFNR
*                                                SUPPL_VEND = <LS_RUN>-EMLIF
*                                                MVT_IND = COND #( WHEN <LS_RUN>-EMLIF IS INITIAL THEN ''
*                                                                                ELSE 'B' )
*                                                ENTRY_QNT = <LS_RUN>-ERFMG
*                                                ENTRY_UOM = <LS_RUN>-ERFME
*                                                LINE_ID = LINES( LT_ITEM ) + 1
*                                                 ) ).
*    ENDLOOP.
*
**bapi실행
*    CALL FUNCTION 'BAPI_GOODSMVT_CREATE'
*      EXPORTING
*        GOODSMVT_HEADER  = LS_HEADER
*        GOODSMVT_CODE    = LS_CODE
*      IMPORTING
*        GOODSMVT_HEADRET = LS_HDRET
*      TABLES
*        GOODSMVT_ITEM    = LT_ITEM
*        RETURN           = LT_RETURN.
*
*    READ TABLE LT_RETURN ASSIGNING FIELD-SYMBOL(<LS_REETURN>) WITH KEY TYPE = GC_E.
*    IF SY-SUBRC EQ 0.
**      오류
*      CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
*
*      LOOP AT GROUP <LS_GROUP1> ASSIGNING <LS_RUN>.
*        READ TABLE GT_LIST ASSIGNING <LS_LIST> INDEX <LS_RUN>-TABIX.
*        CHECK SY-SUBRC EQ 0.
*
*        <LS_LIST>-STATUS = ICON_LED_RED.
*        <LS_LIST>-MESSAGE = <LS_REETURN>-MESSAGE.
*        CLEAR <LS_LIST>-GR_FIN.
*        MODIFY GT_LIST FROM <LS_LIST> INDEX <LS_RUN>-TABIX.
*      ENDLOOP.
*
*      MESSAGE S000 DISPLAY LIKE 'E' WITH TEXT-M04. "입고 처리 실패했습니다.
*
*    ELSE.
**      성공
*      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
*        EXPORTING
*          WAIT = ABAP_TRUE.
*
*      LOOP AT GROUP <LS_GROUP1> ASSIGNING <LS_RUN>.
*        READ TABLE GT_LIST ASSIGNING <LS_LIST> INDEX <LS_RUN>-TABIX.
*        CHECK SY-SUBRC EQ 0.
*
*        <LS_LIST>-STATUS = ICON_LED_GREEN.
*        <LS_LIST>-MESSAGE = SPACE.
*        <LS_LIST>-MBLNR = LS_HDRET-MAT_DOC.
*        <LS_LIST>-MJAHR = LS_HDRET-DOC_YEAR.
*        <LS_LIST>-BUDAT = LS_HEADER-PSTNG_DATE.
*        <LS_LIST>-GR_FIN = ABAP_TRUE. "입고완료 여부->필드편집제어용
*         MODIFY GT_LIST FROM <LS_LIST> INDEX <LS_RUN>-TABIX.
*
**전기동 입고 처리 이력 LOG TABLE UPDATE
*         LT_9470[] = VALUE #( BASE LT_9470
*                                        ( VALUE #( BASE CORRESPONDING #( <LS_LIST> )
*                                          ERNAM = SY-UNAME
*                                          ERDAT = SY-DATUM
*                                          ERDAT_LOCAL = SY-DATLO
*                                          ERTIM = SY-UZEIT
*                                          ERTIM_LOCAL = SY-TIMLO ) ) ).
*      ENDLOOP.
*
*      IF LT_9470[] IS NOT INITIAL.
*         MODIFY ZGTMMT9470 FROM TABLE LT_9470.
*         IF SY-SUBRC = 0.
*             COMMIT WORK.
*             CLEAR LT_9470.
*         ENDIF.
*      ENDIF.
*
*      MESSAGE S000 WITH TEXT-M03."입고 처리 완료 하였습니다.
*    ENDIF.
*  ENDLOOP.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_POST_SCR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_POST_SCR .

*2. 입고 처리 버튼 선택
*2-1) 라인은 다중선택 가능 (전체선택 포함)

  DATA LV_VALID TYPE C LENGTH 1.
  CALL METHOD GO_GRID_100->CHECK_CHANGED_DATA
    IMPORTING
      E_VALID = LV_VALID.
  CHECK LV_VALID EQ ABAP_TRUE.

*2-2) 선택한 라인이 없는 경우 하단 에러 메시지 "선택한 데이터가 없습니다."
  CALL METHOD GO_GRID_100->GET_SELECTED_ROWS
    IMPORTING
      ET_ROW_NO = GT_ROW.

  DELETE GT_ROW WHERE ROW_ID LE 0.
  IF GT_ROW[] IS INITIAL.
    MESSAGE E050.
  ENDIF.

  DATA:
    LT_RUN  LIKE TABLE OF GS_RUN_SCR,
    LS_RUN  LIKE GS_RUN_SCR,
    LT_RESB TYPE TY_T_PO_RESB,
    LT_9471 TYPE STANDARD TABLE OF ZGTMMT9471.

  CLEAR GT_RUN_SCR.

  LOOP AT GT_ROW ASSIGNING FIELD-SYMBOL(<LS_ROW>).
    READ TABLE GT_SCR_LIST ASSIGNING FIELD-SYMBOL(<LS_LIST>) INDEX <LS_ROW>-ROW_ID.
    CHECK SY-SUBRC EQ 0.
*2-3) 선택한 라인의 상태 ="GREEN" 인 경우 하단 에러메세지 "처리 상태를 확인하세요."
    IF <LS_LIST>-STATUS EQ ICON_LED_GREEN.
      MESSAGE E000 WITH TEXT-E05.
    ENDIF.
*2-4) 선택한 라인에 입고수량이 입력되지않은 경우 하단 오류 메시지 "처리 수량을 입력하세요."
    IF <LS_LIST>-ERFMG IS INITIAL.
      MESSAGE E000 WITH TEXT-E07.
    ENDIF.
*2-5)선택 한 라인에 판매처가 빈값이거나 유효하지 않은 코드이면 하단 오류 메시지
*ALV-KUNNR= "" or KNA1-KUNNR 에 존재하지 않으면 "판매처 코드를 확인하세요."
    IF <LS_LIST>-KUNNR IS INITIAL. "OR <LS_LIST>-KUNWE IS INITIAL.
      MESSAGE E000 WITH TEXT-E06.
    ENDIF.
*2-6) 선택 한 라인에 VBELN,VBELP 값이 공백이면 하단 오류 메시지 "판매오더 정보를 입력하세요."
*    IF <LS_LIST>-VBELN IS INITIAL OR <LS_LIST>-POSNR IS INITIAL.
*      MESSAGE E000 WITH TEXT-E13.
*    ENDIF.

    "실행 대상
    LS_RUN = CORRESPONDING #( <LS_LIST> ).
    LS_RUN-TABIX = <LS_ROW>-ROW_ID.
    APPEND LS_RUN TO GT_RUN_SCR. "LT_RUN.
  ENDLOOP.

  CHECK GT_RUN_SCR IS NOT INITIAL.

*  2-7) 선택한 라인의 상태 <> "GREEN" 인 경우 하단 POP-UP 확인 후 입고처리
  CLEAR GS_SCR.
  GS_SCR-ZTEXT = TEXT-M01. "입고 처리 하시겠습니까?
  GS_SCR-BUDAT = SY-DATUM. "전기일
  CALL SCREEN 300 STARTING AT 1 4.

*  CHECK GS_SCR-ZOK EQ ABAP_TRUE. "Yes를 누른경우 진행
*
**투입 Component 자재 정보 추출
*  PERFORM GET_PO_RESB USING LT_RUN CHANGING LT_RESB.
*
**  : 자재문서는 선택한 데이터 기준 BUDAT(납품일자) 별로 분할 생성
*  "bapi 사용
*  DATA:
*    LS_HEADER TYPE BAPI2017_GM_HEAD_01,
*    LS_CODE   TYPE BAPI2017_GM_CODE,
*    LS_COMP TYPE BAPI2017_GM_ITEM_CREATE,
*    LT_ITEM   TYPE STANDARD TABLE OF BAPI2017_GM_ITEM_CREATE,
*    LT_RETURN TYPE STANDARD TABLE OF BAPIRET2,
*    LS_HDRET  TYPE BAPI2017_GM_HEAD_RET,
*    LT_ALLOC TYPE TABLE OF BAPI1003_ALLOC_VALUES_CHAR,
*    LT_ALC_NUM TYPE TABLE OF BAPI1003_ALLOC_VALUES_NUM,
*    LT_ALC_CURR TYPE TABLE OF BAPI1003_ALLOC_VALUES_CURR,
*    LV_KEY TYPE BAPI1003_KEY-OBJECT,
*    LV_MATNR TYPE MATNR18,
*    LV_ID TYPE BAPI2017_GM_ITEM_CREATE-LINE_ID,
*    LT_ZPPT0001 TYPE STANDARD TABLE OF ZPPT0001.
*
*  LOOP AT LT_RUN ASSIGNING FIELD-SYMBOL(<LS_G1>) GROUP BY ( BUDAT = <LS_G1>-BUDAT )
*                                                                             ASSIGNING FIELD-SYMBOL(<LS_GROUP1>).
*
*    "초기화
*    CLEAR:
*      LS_CODE,
*      LS_HEADER,
*      LT_ITEM[],
*      LT_RETURN[],
*      LS_HDRET.
*
*    "CODE 설정
*    LS_CODE-GM_CODE = GC_01.
*
*    "헤더
*    LS_HEADER-PSTNG_DATE = <LS_GROUP1>-BUDAT.
*    LS_HEADER-DOC_DATE = <LS_GROUP1>-BUDAT.
*    LS_HEADER-PR_UNAME = SY-UNAME.
*
*    "아이템
*    LOOP AT GROUP <LS_GROUP1> ASSIGNING FIELD-SYMBOL(<LS_RUN>).
*        LV_ID = LINES( LT_ITEM ) + 1.
*        LT_ITEM = VALUE #( BASE LT_ITEM ( MOVE_TYPE = GC_101
*                                                STCK_TYPE = ''
*                                                MATERIAL = <LS_RUN>-POMAT
*                                                PLANT = <LS_RUN>-WERKS
*                                                STGE_LOC = <LS_RUN>-LGORT
*                                                PO_NUMBER = <LS_RUN>-EBELN
*                                                PO_ITEM = <LS_RUN>-EBELP
*                                                ENTRY_QNT = <LS_RUN>-ERFMG
*                                                ENTRY_UOM = <LS_RUN>-ERFME
*                                                BATCH = <LS_RUN>-LOTNO
*                                                MVT_IND = GC_B
*                                                LINE_ID = LV_ID
*                                                PARENT_ID = ''
*                                                 ) ).
*    "PO COMPONENT 기준_아이템 추가
*        READ TABLE LT_RESB WITH KEY EBELN = <LS_RUN>-EBELN
*                                                          EBELP = <LS_RUN>-EBELP
*                              BINARY SEARCH TRANSPORTING NO FIELDS.
*        IF SY-SUBRC EQ 0.
*          LOOP AT LT_RESB ASSIGNING FIELD-SYMBOL(<LS_RESB>) FROM SY-TABIX.
*            IF <LS_RESB>-EBELN NE <LS_RUN>-EBELN
*               OR <LS_RESB>-EBELP NE <LS_RUN>-EBELP.
*                  EXIT.
*            ENDIF.
*
*            LS_COMP-LINE_ID = LV_ID.
*            LS_COMP-MATERIAL = <LS_RESB>-MATNR.
*            LS_COMP-PLANT = <LS_RESB>-WERKS.
*            LS_COMP-STGE_LOC = <LS_RESB>-LGORT.
*            LS_COMP-PO_NUMBER = <LS_RUN>-EBELN.
*            LS_COMP-PO_ITEM = <LS_RUN>-EBELP.
*            LS_COMP-MOVE_TYPE = '543'.
*            LS_COMP-BATCH = <LS_RESB>-CHARG.
**ENTRY_QNT(입고수량) 조건 별 설정
**  : PO 소요량정보로 입고수량 대비 투입 처리 수량 산출
**  ->COMPONENT 소비량  = 입고 수량 * 단위당소요량(RESB-BDMNG/EKPO-MENGE)"
*            IF <LS_RESB>-MENGE IS NOT INITIAL.
*              LS_COMP-ENTRY_QNT = <LS_RUN>-ERFMG * ( <LS_RESB>-BDMNG / <LS_RESB>-MENGE ).
*            ELSE.
*              LS_COMP-ENTRY_QNT = 0.
*            ENDIF.
*
*            LS_COMP-ENTRY_UOM = <LS_RESB>-MEINS.
*            LS_COMP-MVT_IND = GC_B.
*            LS_COMP-LINE_ID += 1.
*            LS_COMP-PARENT_ID = LV_ID.
*            LT_ITEM = VALUE #( BASE LT_ITEM ( LS_COMP ) ).
*
*          ENDLOOP.
*        ENDIF.
*    ENDLOOP.
*
**bapi실행
*    CALL FUNCTION 'BAPI_GOODSMVT_CREATE'
*      EXPORTING
*        GOODSMVT_HEADER  = LS_HEADER
*        GOODSMVT_CODE    = LS_CODE
*      IMPORTING
*        GOODSMVT_HEADRET = LS_HDRET
*      TABLES
*        GOODSMVT_ITEM    = LT_ITEM
*        RETURN           = LT_RETURN.
*
*    READ TABLE LT_RETURN ASSIGNING FIELD-SYMBOL(<LS_REETURN>) WITH KEY TYPE = GC_E.
*    IF SY-SUBRC EQ 0.
**      오류
*      CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
*
*      LOOP AT GROUP <LS_GROUP1> ASSIGNING <LS_RUN>.
*        READ TABLE GT_SCR_LIST ASSIGNING <LS_LIST> INDEX <LS_RUN>-TABIX.
*        CHECK SY-SUBRC EQ 0.
*
*        <LS_LIST>-STATUS = ICON_LED_RED.
*        <LS_LIST>-MESSAGE = <LS_REETURN>-MESSAGE.
*        CLEAR <LS_LIST>-GR_FIN.
*        MODIFY GT_SCR_LIST FROM <LS_LIST> INDEX <LS_RUN>-TABIX.
*      ENDLOOP.
*
*      MESSAGE S000 DISPLAY LIKE 'E' WITH TEXT-M04. "입고 처리 실패했습니다.
*
*    ELSE.
**      성공
*      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
*        EXPORTING
*          WAIT = ABAP_TRUE.
*
*      LOOP AT GROUP <LS_GROUP1> ASSIGNING <LS_RUN>.
*        READ TABLE GT_SCR_LIST ASSIGNING <LS_LIST> INDEX <LS_RUN>-TABIX.
*        CHECK SY-SUBRC EQ 0.
*
*        <LS_LIST>-STATUS = ICON_LED_GREEN.
*        <LS_LIST>-MESSAGE = SPACE.
*        <LS_LIST>-MBLNR = LS_HDRET-MAT_DOC.
*        <LS_LIST>-MJAHR = LS_HDRET-DOC_YEAR.
*        <LS_LIST>-BUDAT = LS_HEADER-PSTNG_DATE.
*        <LS_LIST>-GR_FIN = ABAP_TRUE. "입고완료 여부->필드편집제어용
*        MODIFY GT_SCR_LIST FROM <LS_LIST> INDEX <LS_RUN>-TABIX.
*
**SCR 입고 처리 이력 LOG TABLE UPDATE DATA SET
*         LT_9471[] = VALUE #( BASE LT_9471
*                                        ( VALUE #( BASE CORRESPONDING #( <LS_LIST> )
*                                          ERNAM = SY-UNAME
*                                          ERDAT = SY-DATUM
*                                          ERDAT_LOCAL = SY-DATLO
*                                          ERTIM = SY-UZEIT
*                                          ERTIM_LOCAL = SY-TIMLO ) ) ).
*
*         SELECT MD~WERKS, MD~EBELN, MD~EBELP,
*                      MD~CHARG_SID AS CHARG, MD~MBLNR,
*                      MD~MATNR, MD~ERFMG, MD~ERFME,
*                      MD~LGORT_SID AS LGORT,
*                      MC~DISPO
*             FROM MATDOC AS MD
*             INNER  JOIN EKPO AS EP ON MD~EBELN EQ EP~EBELN
*                                                 AND MD~EBELP EQ EP~EBELP
*             INNER JOIN MARC AS MC ON EP~WERKS EQ MC~WERKS
*                                                 AND EP~MATNR EQ MC~MATNR
*             WHERE MD~MBLNR = @<LS_LIST>-MBLNR
*             INTO TABLE @DATA(LT_MAT).
*
**2-9) 입고 정상 처리 후 꼬리표 테이블 업데이트 DATA SET
*           IF LT_MAT[] IS NOT INITIAL.
*             LOOP AT LT_MAT INTO DATA(LS_MAT).
*               CHECK LS_MAT-MATNR EQ <LS_LIST>-POMAT."MATNR.
*               APPEND VALUE #( WERKS = LS_MAT-WERKS
*                                     AUFNR = LS_MAT-EBELN
*                                     TAGNR = <LS_LIST>-LOTNO
*                                     POSNR = LS_MAT-EBELP
*                                     CHARG = LS_MAT-CHARG
*                                     MBLNR = LS_MAT-MBLNR
*                                     MATNR = LS_MAT-MATNR
*                                     SPGCD  = LS_MAT-DISPO(2)
*                                     MGVRG = LS_MAT-ERFMG
*                                     FOSTCNT = GC_1
*                                     REMAIN = LS_MAT-ERFMG
*                                     MEINS = LS_MAT-ERFME
*                                     OUTFLG = GC_3
*                                     GIFLG = GC_N
*                                     GRFLG = GC_Y
*                                     INSPFLG = GC_OK
*                                     LGORT = LS_MAT-LGORT
*                                     GRINDAT = SY-DATUM
*                                     GRINTIM = SY-UZEIT
*                                     GRINNAM = SY-UNAME ) TO LT_ZPPT0001.
*             ENDLOOP.
*           ENDIF.
**2-8) 입고 정상 처리 후 배치 클래스 속성 정보 업데이트  BAPI 수행
*         CLEAR LT_ALLOC.
*         LT_ALLOC[] = VALUE #( BASE LT_ALLOC
*                                          ( CHARACT = 'PD_CA_CUSTOMER_CODE'
*                                            VALUE_CHAR = |{ <LS_LIST>-KUNNR ALPHA = OUT }| )
*                                          ( CHARACT = 'PD_CA_GRADE'
*                                            VALUE_CHAR = <LS_LIST>-GOGRADE )
*                                          ( CHARACT = 'PD_CA_GIDATE'
*                                            VALUE_CHAR = <LS_LIST>-BUDAT ) ).
*
*         IF LINES( LT_MAT ) > 1.
*           LOOP AT LT_MAT ASSIGNING FIELD-SYMBOL(<BMAT>).
*             CLEAR : LV_MATNR, LV_KEY, LT_RETURN.
*             LV_MATNR = |{ <LS_LIST>-POMAT ALPHA = IN }|.
*
*             CHECK <BMAT>-CHARG IS NOT INITIAL.
*
*             LV_KEY(18) = LV_MATNR.
*             LV_KEY+18(10) = <BMAT>-CHARG.
*
*             CALL FUNCTION 'BAPI_OBJCL_CHANGE'
*               EXPORTING
*                 OBJECTKEY                = LV_KEY
*                 OBJECTTABLE            = 'MCH1'
*                 CLASSNUM                 = 'HB_GO_SCR'
*                 CLASSTYPE                = '023'
*               TABLES
*                 ALLOCVALUESNUMNEW    = LT_ALC_NUM
*                 ALLOCVALUESCHARNEW   = LT_ALLOC
*                 ALLOCVALUESCURRNEW   = LT_ALC_CURR
*                 RETURN                            = LT_RETURN
*                   .
*             READ TABLE LT_RETURN INTO DATA(LS_RT) WITH KEY TYPE = GC_E.
*             IF SY-SUBRC EQ 0.
*               CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
*               <LS_LIST>-MESSAGE = LS_RT-MESSAGE.
*               EXIT.
*             ELSE.
*               CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
*                 EXPORTING
*                   WAIT = ABAP_TRUE.
*             ENDIF.
*           ENDLOOP.
*
*           MESSAGE S000 WITH TEXT-E14 DISPLAY LIKE 'E'. "배치 특성 업데이트 실패하였습니다.
*
*         ELSE.
*           READ TABLE LT_MAT ASSIGNING FIELD-SYMBOL(<BBMAT>) INDEX 1.
*             CLEAR : LV_MATNR, LV_KEY, LT_RETURN.
*             LV_MATNR = |{ <LS_LIST>-POMAT ALPHA = IN }|.
*
*             CHECK <BBMAT>-CHARG IS NOT INITIAL.
*
*             LV_KEY(18) = LV_MATNR.
*             LV_KEY+18(10) = <BBMAT>-CHARG.
*
*           CALL FUNCTION 'BAPI_OBJCL_CHANGE'
*             EXPORTING
*               OBJECTKEY                = LV_KEY
*               OBJECTTABLE            = 'MCH1'
*               CLASSNUM                 = 'HB_GO_SCR'
*               CLASSTYPE                = '023'
*             TABLES
*               ALLOCVALUESNUMNEW    = LT_ALC_NUM
*               ALLOCVALUESCHARNEW   = LT_ALLOC
*               ALLOCVALUESCURRNEW   = LT_ALC_CURR
*               RETURN                            = LT_RETURN
*                   .
*           READ TABLE LT_RETURN ASSIGNING FIELD-SYMBOL(<LS_R2TURN>) WITH KEY TYPE = GC_E.
*           IF SY-SUBRC EQ 0.
**      오류
*             CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
*
*             READ TABLE GT_SCR_LIST ASSIGNING <LS_LIST> INDEX <LS_RUN>-TABIX.
*             CHECK SY-SUBRC EQ 0.
*
*             <LS_LIST>-MESSAGE = <LS_R2TURN>-MESSAGE.
**             MESSAGE S000 DISPLAY LIKE 'E' WITH TEXT-M07. "배치 특성 업데이트 실패했습니다.
*
*           ELSE.
**      배치특성 성공
*             CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
*               EXPORTING
*                 WAIT = ABAP_TRUE.
*           ENDIF.
*         ENDIF.
*
*      ENDLOOP.
*
**SCR 입고 처리 이력 업데이트
*      IF LT_9471[] IS NOT INITIAL.
*         MODIFY ZGTMMT9471 FROM TABLE LT_9471.
*         IF SY-SUBRC = 0.
*             COMMIT WORK.
*         ENDIF.
*      ENDIF.
**꼬리표 정보 업데이트
*      IF LT_ZPPT0001[] IS NOT INITIAL.
*         MODIFY ZPPT0001 FROM TABLE LT_ZPPT0001.
*         IF SY-SUBRC = 0.
*             COMMIT WORK.
*         ENDIF.
*      ENDIF.
*
*      MESSAGE S000 WITH TEXT-M03."입고 처리 완료 하였습니다.
*    ENDIF.
*  ENDLOOP.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_REVERSE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_REVERSE .

*4. 이전 취소 버튼 선택
*4-1) 동일한 자재문서 단위로 단일건만 선택 가능
*4-2) 선택한 라인이 없는 경우 하단 에러 메시지 "선택한 데이터가 없습니다."
*4-3) 선택한 라인의 상태 <> "GREEN" 인 경우 하단 에러메세지 "입고처리 되지 않은 정보입니다."
*4-4) 선택한 라인의 상태 = "GREEN" 인 경우 POP-UP 확인 후 재고 이전 취소 처리

  DATA LV_VALID TYPE C LENGTH 1.
  CALL METHOD GO_GRID_100->CHECK_CHANGED_DATA
    IMPORTING
      E_VALID = LV_VALID.
  CHECK LV_VALID EQ ABAP_TRUE.

*4-2) 선택한 라인이 없는 경우 하단 에러 메시지 "선택한 데이터가 없습니다."
  DATA LT_ROW TYPE LVC_T_ROID.
  CALL METHOD GO_GRID_100->GET_SELECTED_ROWS
    IMPORTING
      ET_ROW_NO = LT_ROW.
  DELETE LT_ROW WHERE ROW_ID LE 0.
  IF LT_ROW[] IS INITIAL.
    MESSAGE E050.
  ENDIF.

  DATA:
    BEGIN OF LS_RUN,
      TABIX TYPE SY-TABIX,
      MJAHR TYPE MATDOC-MJAHR,
      MBLNR TYPE MATDOC-MBLNR,
      BUDAT TYPE MATDOC-BUDAT,
    END OF LS_RUN,
    LT_RUN LIKE STANDARD TABLE OF LS_RUN.

  LOOP AT LT_ROW ASSIGNING FIELD-SYMBOL(<LS_ROW>).
    READ TABLE GT_LIST ASSIGNING FIELD-SYMBOL(<LS_LIST>) INDEX <LS_ROW>-ROW_ID.
    CHECK SY-SUBRC EQ 0.

*4-1) 동일한 자재문서 단위로 선택 가능
    IF LS_RUN-MBLNR IS NOT INITIAL AND <LS_LIST>-MBLNR NE LS_RUN-MBLNR.
      MESSAGE E000 WITH TEXT-E09. "동일한 자재문서만 선택 가능 합니다.
    ENDIF.

*4-3) 선택한 라인의 상태 <> "GREEN" 인 경우 하단 에러메세지 "입고처리 되지 않은 정보입니다."
    IF <LS_LIST>-MBLNR IS INITIAL.
      MESSAGE E000 WITH TEXT-E08.
    ENDIF.

    "실행 대상
    CLEAR LS_RUN.
    LS_RUN-MJAHR = <LS_LIST>-BUDAT(4)."MJAHR.
    LS_RUN-MBLNR = <LS_LIST>-MBLNR.
    LS_RUN-BUDAT = <LS_LIST>-BUDAT.
    LS_RUN-TABIX = <LS_ROW>-ROW_ID.
    APPEND LS_RUN TO LT_RUN.
  ENDLOOP.

**4-1) 동일한 자재문서 단위로 단일 건만 선택 가능
*##ITAB_KEY_IN_SELECT
*##ITAB_DB_SELECT
*  SELECT ZZ~MJAHR, ZZ~MBLNR
*    FROM @LT_RUN AS ZZ
*    GROUP BY ZZ~MJAHR, ZZ~MBLNR
*    INTO TABLE @DATA(LT_CHK).
*
*  IF LINES( LT_CHK ) GT 1.
*    MESSAGE E000 WITH TEXT-E09. "동일한 자재문서만 선택 가능 합니다.
*  ENDIF.

  CLEAR LS_RUN.
  READ TABLE LT_RUN INTO LS_RUN INDEX 1.

*4-4) 선택한 라인의 상태 = "GREEN" 인 경우 POP-UP 확인 후 재고 이전 취소 처리
  CLEAR GS_SCR.
  SELECT SINGLE BUDAT
       FROM ZGTMMT9470
       WHERE MBLNR = @LS_RUN-MBLNR
       INTO @DATA(LV_BUDAT).

  IF  SY-SUBRC = 0.
    GS_SCR-BUDAT = LV_BUDAT.
  ENDIF.

*  GS_SCR-BUDAT = LS_RUN-BUDAT.
  GS_SCR-ZTEXT = TEXT-M02. "입고 취소 처리 하시겠습니까?
  CALL SCREEN 300 STARTING AT 1 4.

  CHECK GS_SCR-ZOK EQ ABAP_TRUE. "Yes를 누른경우 진행

  DATA:
    LS_HEAD   LIKE BAPI2017_GM_HEAD_02,
    LS_HRET   LIKE BAPI2017_GM_HEAD_RET,
    LS_RETURN TYPE BAPIRET2,
    LT_RETURN TYPE STANDARD TABLE OF BAPIRET2.

  LS_HEAD-MAT_DOC    = LS_RUN-MBLNR.
  LS_HEAD-DOC_YEAR   = LS_RUN-MJAHR.
  LS_HEAD-PSTNG_DATE = COND #( WHEN LV_BUDAT IS INITIAL THEN LS_RUN-BUDAT
                                                        ELSE LV_BUDAT ).

  CALL FUNCTION 'BAPI_GOODSMVT_CANCEL'
    EXPORTING
      MATERIALDOCUMENT    = LS_HEAD-MAT_DOC
      MATDOCUMENTYEAR     = LS_HEAD-DOC_YEAR
      GOODSMVT_PSTNG_DATE = LS_HEAD-PSTNG_DATE
    IMPORTING
      GOODSMVT_HEADRET    = LS_HRET
    TABLES
      RETURN              = LT_RETURN.


  IF LS_HRET-MAT_DOC IS NOT INITIAL.
    "성공
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        WAIT = ABAP_TRUE.

    LOOP AT  LT_RUN ASSIGNING FIELD-SYMBOL(<LS_RUN>).
      READ TABLE GT_LIST ASSIGNING <LS_LIST> INDEX <LS_RUN>-TABIX.
      CHECK <LS_LIST>-MBLNR EQ <LS_RUN>-MBLNR.

      <LS_LIST>-STATUS = ICON_LED_YELLOW.
      <LS_LIST>-MESSAGE = SPACE.
      <LS_LIST>-MBLNR = SPACE.
      <LS_LIST>-GR_FIN = SPACE.
      MODIFY GT_LIST FROM <LS_LIST> INDEX <LS_RUN>-TABIX.

*전기동 입고 처리 이력 LOG TABLE UPDATE
      UPDATE ZGTMMT9470
            SET MBLNR = SPACE
                   MJAHR = SPACE
                   AENAM = SY-UNAME
                   AEDAT = SY-DATUM
                   AEDAT_LOCAL = SY-DATLO
                   AETIM = SY-UZEIT
                   AETIM_LOCAL = SY-TIMLO
        WHERE IFNUM = <LS_LIST>-IFNUM
             AND MBLNR = LS_HEAD-MAT_DOC.

      IF SY-SUBRC = 0.
        COMMIT WORK.
      ENDIF.

    ENDLOOP.
    MESSAGE S000 WITH TEXT-M05. "입고 취소 완료 하였습니다.

  ELSE.
    "오류
    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
    CLEAR LS_RETURN.
    READ TABLE LT_RETURN INTO LS_RETURN WITH KEY TYPE = GC_E.

    LOOP AT LT_RUN INTO LS_RUN.
      READ TABLE GT_LIST ASSIGNING <LS_LIST> INDEX LS_RUN-TABIX.
      CHECK SY-SUBRC EQ 0.
      <LS_LIST>-STATUS = ICON_LED_RED.
      <LS_LIST>-MESSAGE = LS_RETURN-MESSAGE.
      <LS_LIST>-GR_FIN = ABAP_TRUE.
      MODIFY GT_LIST FROM <LS_LIST> INDEX LS_RUN-TABIX.
    ENDLOOP.

    MESSAGE S000 DISPLAY LIKE 'E' WITH TEXT-M06. "입고 취소 실패 했습니다.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_REVERSE_SCR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_REVERSE_SCR .

*4. 이전 취소 버튼 선택
*4-1) 동일한 자재문서 단위로 단일건만 선택 가능
*4-2) 선택한 라인이 없는 경우 하단 에러 메시지 "선택한 데이터가 없습니다."
*4-3) 선택한 라인의 상태 <> "GREEN" 인 경우 하단 에러메세지 "입고처리 되지 않은 정보입니다."
*4-4) 선택한 라인의 상태 = "GREEN" 인 경우 POP-UP 확인 후 재고 이전 취소 처리

  DATA LV_VALID TYPE C LENGTH 1.
  CALL METHOD GO_GRID_100->CHECK_CHANGED_DATA
    IMPORTING
      E_VALID = LV_VALID.
  CHECK LV_VALID EQ ABAP_TRUE.

*4-2) 선택한 라인이 없는 경우 하단 에러 메시지 "선택한 데이터가 없습니다."
  DATA LT_ROW TYPE LVC_T_ROID.
  CALL METHOD GO_GRID_100->GET_SELECTED_ROWS
    IMPORTING
      ET_ROW_NO = LT_ROW.
  DELETE LT_ROW WHERE ROW_ID LE 0.
  IF LT_ROW[] IS INITIAL.
    MESSAGE E050.
  ENDIF.

  DATA:
    BEGIN OF LS_RUN,
      TABIX TYPE SY-TABIX,
      MJAHR TYPE MATDOC-MJAHR,
      MBLNR TYPE MATDOC-MBLNR,
      BUDAT TYPE MATDOC-BUDAT,
    END OF LS_RUN,
    LT_RUN LIKE STANDARD TABLE OF LS_RUN.

  LOOP AT LT_ROW ASSIGNING FIELD-SYMBOL(<LS_ROW>).
    READ TABLE GT_SCR_LIST ASSIGNING FIELD-SYMBOL(<LS_LIST>) INDEX <LS_ROW>-ROW_ID.
    CHECK SY-SUBRC EQ 0.

*4-1) 동일한 자재문서 단위로 선택 가능
    IF LS_RUN-MBLNR IS NOT INITIAL AND <LS_LIST>-MBLNR NE LS_RUN-MBLNR.
      MESSAGE E000 WITH TEXT-E09. "동일한 자재문서만 선택 가능 합니다.
    ENDIF.

    IF <LS_LIST>-MBLNR IS INITIAL.
      MESSAGE E000 WITH TEXT-E08.
    ENDIF.

    "실행 대상
    CLEAR LS_RUN.
    LS_RUN-MJAHR = <LS_LIST>-BUDAT(4)."<LS_LIST>-MJAHR.
    LS_RUN-MBLNR = <LS_LIST>-MBLNR.
    LS_RUN-BUDAT = <LS_LIST>-BUDAT.
    LS_RUN-TABIX = <LS_ROW>-ROW_ID.
    APPEND LS_RUN TO LT_RUN.
  ENDLOOP.

  CLEAR LS_RUN.
  READ TABLE LT_RUN INTO LS_RUN INDEX 1.

*4-4) 선택한 라인의 상태 = "GREEN" 인 경우 POP-UP 확인 후 재고 이전 취소 처리
  CLEAR GS_SCR.
  SELECT SINGLE BUDAT
       FROM ZGTMMT9471
       WHERE MBLNR = @LS_RUN-MBLNR
       INTO @DATA(LV_BUDAT).

  IF  SY-SUBRC = 0.
    GS_SCR-BUDAT = LV_BUDAT.
  ENDIF.
*  CLEAR GS_SCR.
*  GS_SCR-BUDAT = LS_RUN-BUDAT.
  GS_SCR-ZTEXT = TEXT-M02. "입고 취소 처리 하시겠습니까?
  CALL SCREEN 300 STARTING AT 1 4.

  CHECK GS_SCR-ZOK EQ ABAP_TRUE. "Yes를 누른경우 진행

  DATA:
    LS_HEAD   LIKE BAPI2017_GM_HEAD_02,
    LS_HRET   LIKE BAPI2017_GM_HEAD_RET,
    LS_RETURN TYPE BAPIRET2,
    LT_RETURN TYPE STANDARD TABLE OF BAPIRET2,
    LT_0001   LIKE TABLE OF ZPPT0001.

  LS_HEAD-MAT_DOC    = LS_RUN-MBLNR.
  LS_HEAD-DOC_YEAR   = LS_RUN-MJAHR.
  LS_HEAD-PSTNG_DATE = COND #( WHEN LV_BUDAT IS INITIAL THEN LS_RUN-BUDAT
                                                       ELSE LV_BUDAT ).

  CALL FUNCTION 'BAPI_GOODSMVT_CANCEL'
    EXPORTING
      MATERIALDOCUMENT    = LS_HEAD-MAT_DOC
      MATDOCUMENTYEAR     = LS_HEAD-DOC_YEAR
      GOODSMVT_PSTNG_DATE = LS_HEAD-PSTNG_DATE
    IMPORTING
      GOODSMVT_HEADRET    = LS_HRET
    TABLES
      RETURN              = LT_RETURN.


  IF LS_HRET-MAT_DOC IS NOT INITIAL.
    "성공
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        WAIT = ABAP_TRUE.

    LOOP AT  LT_RUN ASSIGNING FIELD-SYMBOL(<LS_RUN>).
      READ TABLE GT_SCR_LIST ASSIGNING <LS_LIST> INDEX <LS_RUN>-TABIX.
      CHECK SY-SUBRC EQ 0.
      CHECK <LS_LIST>-MBLNR EQ <LS_RUN>-MBLNR.

      <LS_LIST>-STATUS = ICON_LED_YELLOW.
      <LS_LIST>-MESSAGE = SPACE.
      <LS_LIST>-MJAHR = SPACE.
      <LS_LIST>-MBLNR = SPACE.
      <LS_LIST>-GR_FIN = SPACE.
      MODIFY GT_SCR_LIST FROM <LS_LIST> INDEX <LS_RUN>-TABIX.

*SCR 입고 처리 이력 LOG 테이블 업데이트
      UPDATE ZGTMMT9471
            SET MBLNR = <LS_LIST>-MBLNR
                   MJAHR = <LS_LIST>-MJAHR
                   AENAM = SY-UNAME
                   AEDAT  = SY-DATUM
                   AEDAT_LOCAL = SY-DATLO
                   AETIM = SY-UZEIT
                   AETIM_LOCAL = SY-TIMLO
       WHERE LOTNO = <LS_LIST>-LOTNO
           AND MBLNR = LS_RUN-MBLNR.

      IF SY-SUBRC = 0.
        COMMIT WORK.
      ENDIF.

*꼬리표 삭제를 위한 기존 데이터 가져오기.
      SELECT FROM ZPPT0001
      FIELDS *
      WHERE WERKS = @<LS_LIST>-WERKS
         AND AUFNR = @<LS_LIST>-EBELN
         AND TAGNR = @<LS_LIST>-LOTNO
         AND POSNR = @<LS_LIST>-EBELP
         AND MBLNR = @LS_RUN-MBLNR
      APPENDING TABLE @LT_0001.

    ENDLOOP.
*꼬리표 테이블 삭제
    IF LT_0001[] IS NOT INITIAL.
      DELETE ZPPT0001 FROM TABLE LT_0001.
      IF SY-SUBRC = 0.
        COMMIT WORK.
      ENDIF.
    ENDIF.

    MESSAGE S000 WITH TEXT-M05. "입고 취소 처리 완료 하였습니다.

  ELSE.
    "오류
    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
    CLEAR LS_RETURN.
    READ TABLE LT_RETURN INTO LS_RETURN WITH KEY TYPE = GC_E.

    LOOP AT LT_RUN INTO LS_RUN.
      READ TABLE GT_SCR_LIST ASSIGNING <LS_LIST> INDEX LS_RUN-TABIX.
      CHECK SY-SUBRC EQ 0.
      <LS_LIST>-STATUS = ICON_LED_RED.
      <LS_LIST>-MESSAGE = LS_RETURN-MESSAGE.
      <LS_LIST>-GR_FIN = GC_X.
      MODIFY GT_SCR_LIST FROM <LS_LIST> INDEX LS_RUN-TABIX.
    ENDLOOP.

    MESSAGE S000 DISPLAY LIKE 'E' WITH TEXT-M06. "입고 취소 처리 실패 했습니다.
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

    CASE SCREEN-NAME.
      WHEN 'S_BUDAT-LOW' OR 'S_BLDAT-LOW'.
        SCREEN-REQUIRED = 2.
        MODIFY SCREEN.
    ENDCASE.

    CASE SCREEN-GROUP1.

      WHEN 'ELC'. "전기동
        IF P_ELC EQ ABAP_TRUE.
          SCREEN-ACTIVE = 1.
        ELSE.
          SCREEN-ACTIVE = 0.
        ENDIF.
        MODIFY SCREEN.

      WHEN 'SCR'. "SCR
        IF P_SCR EQ ABAP_TRUE AND P_GR EQ ABAP_TRUE.
          SCREEN-ACTIVE = 1.
        ELSE.
          SCREEN-ACTIVE = 0.
        ENDIF.
        MODIFY SCREEN.

      WHEN 'SGR'. "SCR & GR일때 비활성->입고일자
        IF P_SCR EQ ABAP_TRUE AND P_GR EQ ABAP_TRUE.
          SCREEN-ACTIVE = 0.
        ELSE.
          SCREEN-ACTIVE = 1.
        ENDIF.
        MODIFY SCREEN.

      WHEN 'DIS'. "처리결과조회
        IF P_DISP EQ ABAP_TRUE.
          SCREEN-ACTIVE = 1.
        ELSE.
          SCREEN-ACTIVE = 0.
        ENDIF.
        MODIFY SCREEN.


    ENDCASE.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form F_GET_MATDOC_DATA_GR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_GET_MATDOC_DATA_GR.

  CLEAR:
    GT_LIST[].

  SELECT
    Z10~IFNUM,
    Z10~MBLNR,
    Z10~MJAHR,
    Z10~BUDAT,
    Z10~BLDAT,
    Z10~ERFMG,
    Z10~ERFME,

    CASE WHEN Z10~MBLNR IS INITIAL
             THEN '@5D@' ELSE '@5B@' END AS STATUS
*1-2)기타입고 이동 정보 데이터 조회
    FROM ZGTMMT9000 AS Z9 INNER JOIN ZGTMMT9110 AS Z10
        ON Z9~ZIFKEY EQ Z10~ZIFKEY

    USING CLIENT '100'
    WHERE Z9~ZIFNO EQ @GC_MM00011
         AND Z9~IFDAT IN @S_BUDAT
         AND Z9~SYSTEM_ID EQ @GC_KSCM
**1-2)공통코드에 등록된 공급업체/자재 기준으로만 조회
         AND Z10~LIFNR IN @GR_LIFNR
         AND Z10~MATNR IN @GR_MATNR
*1-4) 입고 자재문서 취소 여부 점검
*  : 1-1)~3)에서 조회된 MBLNR에 대한 ZGTMMT9111-MBLNR_C(취소문서)있는지,
    AND NOT EXISTS (
      SELECT Z111~MBLNR, Z111~MBLNR_C
          FROM ZGTMMT9111 AS Z111
          WHERE Z10~IFNUM EQ Z111~IFNUM
             AND Z10~MBLNR EQ Z111~MBLNR
             AND Z10~MJAHR EQ Z111~MJAHR
             AND Z111~MBLNR_C IS NOT INITIAL
             AND Z111~MESSAGE EQ @GC_S
            )
* MBLNR_C(취소문서)없으면,MATDOC-MBLNR에 REVERSAL_MOVEMENT= '' 인지 점검
    AND NOT EXISTS (
      SELECT ZZ~MBLNR_C, MD~REVERSAL_MOVEMENT
          FROM MATDOC AS MD
          INNER JOIN ZGTMMT9111 AS ZZ ON MD~MBLNR EQ ZZ~MBLNR
                                                        AND MD~MJAHR EQ ZZ~MJAHR
          WHERE Z10~MBLNR EQ MD~MBLNR
               AND Z10~MJAHR EQ MD~MJAHR
               AND ZZ~MBLNR_C IS INITIAL
               AND MD~REVERSAL_MOVEMENT IS NOT INITIAL
               )
    INTO CORRESPONDING FIELDS OF TABLE @GT_LIST.

  CHECK GT_LIST[] IS NOT INITIAL.
  SORT GT_LIST BY IFNUM BUDAT.

  SELECT IFNUM, MBLNR, MJAHR
     FROM ZGTMMT9470
     FOR ALL ENTRIES IN @GT_LIST
     WHERE IFNUM = @GT_LIST-IFNUM
      INTO TABLE @DATA(LT_9470).
  SORT LT_9470 BY IFNUM .

  DATA(LT_1010) = GT_ZGTPPT1010[].
  DELETE LT_1010 WHERE CODEGRP = '0870'.
  SORT LT_1010 BY FLD_03.

  LOOP AT GT_LIST ASSIGNING FIELD-SYMBOL(<LIST>).
    DATA(LV_TABIX) = SY-TABIX.
* 2) 최종 조회된 데이터 입고 처리 이력여부 점검
*  ZGTMMT9470 > MBLNR 값이 존재하면 조회 대상에서 제외
    READ TABLE LT_9470 ASSIGNING FIELD-SYMBOL(<LT9>)
    WITH KEY IFNUM = <LIST>-IFNUM BINARY SEARCH.

    IF SY-SUBRC = 0 AND <LT9>-MBLNR IS NOT INITIAL.
      DELETE GT_LIST INDEX LV_TABIX.
      CONTINUE.
    ENDIF.
*자재번호/자재내역
    READ TABLE GR_MATNR INTO DATA(LS_MATNR) INDEX 1.
    CHECK SY-SUBRC = 0.
    <LIST>-MATNR = |{ LS_MATNR-LOW ALPHA = OUT }|.

    READ TABLE LT_1010 ASSIGNING FIELD-SYMBOL(<G10>)
    WITH KEY FLD_03 = <LIST>-MATNR BINARY SEARCH.
    IF SY-SUBRC = 0.
      <LIST>-MAKTX = <G10>-FLD_04.
    ENDIF.

  ENDLOOP.

  SORT GT_LIST BY IFNUM BUDAT.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form F_GET_MATDOC_DATA_SCR_GR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_GET_MATDOC_DATA_SCR_GR.
  CLEAR:
    GT_SCR_LIST[].

*1.LS시스템 기준의 출하 정보 가져온다.
  DATA : LV_MANDT TYPE MANDT VALUE '100',
         LT_LIST  TYPE TY_T_SCR_LIST.

  SELECT DISTINCT
    Z400~DLVRQ, Z400~KUNAG,
    Z400~KUNWE, Z400~REMARK AS ZBIGO4,
    Z401~MATNR,
    Z402~VGBEL, Z402~VGPOS,
    KN~NAME1 AS KUNNR2,
    MD~VBELN_IM AS VGBEL,
    MD~BUDAT, MD~ERFME, MD~ERFMG,
    MD~CHARG_SID AS LOTNO

*1-1) 출하요청 정보 조회
    FROM ZLET0400 AS Z400
*1-2) 출하 요청 상세 정보 조회
              INNER JOIN
            ZLET0401 AS Z401 ON Z400~DLVRQ = Z401~DLVRQ
*1-3) 출하 확정 정보 조회
              INNER JOIN
            ZLET0402 AS Z402 ON Z400~DLVRQ = Z402~DLVRQ
                                       AND Z401~VBELN = Z402~VBELN
                                       AND Z401~POSNR = Z402~POSNR
              INNER JOIN
              LIKP AS LP ON Z402~VGBEL = LP~VBELN
              INNER JOIN
            KNA1 AS KN ON Z400~KUNWE = KN~KUNNR
*1-4) 출고 자재문서 상세 정보 조회
              INNER JOIN
            MATDOC AS MD ON Z402~VGBEL = MD~VBELN_IM

    USING CLIENT @LV_MANDT

    WHERE Z400~ERDAT IN @S_BLDAT
    AND Z400~KUNAG IN @GR_LIFNR  "납품처:(가온)공통코드 존재 공급업체만 대상
    AND Z400~LVORM IS INITIAL
*    AND Z401~MATNR  IN @GR_MATNR"자재번호:(가온)공통코드 존재 자재만 대상
    AND Z401~LVORM IS INITIAL
    AND Z401~LECFM IS NOT INITIAL "출하 확정 여부
*    AND ( Z402~WBSTA EQ @GC_B OR Z402~WBSTA EQ @GC_C ) "LIKP 값으로 조회
    AND ( LP~WBSTK EQ @GC_B OR LP~WBSTK EQ @GC_C )
    AND MD~CANCELLED = ''                                   "260803 추가
    AND MD~REVERSAL_MOVEMENT = ''                           "260803 추가

    INTO CORRESPONDING FIELDS OF TABLE @LT_LIST.

  IF  LT_LIST[] IS NOT INITIAL.
*2.가온 기준 데이터 및 자재문서 정보 매핑 및 ALV 추가 설정.
    PERFORM GET_GAON_DATA USING LT_LIST CHANGING GT_SCR_LIST.
  ENDIF.

*3.공급업체 입고 실적 이력 테이블 데이터 추가 조회
  SELECT DISTINCT @GC_X AS ZCHK,
               @SPACE AS MBLNR,
               @ICON_LED_YELLOW AS STATUS,
               ZZ~LOTNO, ZZ~BUDAT, ZZ~EBELN, ZZ~EBELP,
               ZZ~MENGE AS ERFMG,
               ZZ~MEINS AS ERFME, ZZ~KUNNR2, ZZ~TRANS ,
               ZZ~TRUCK_NO, ZZ~GRADE,
               ZZ~MATNR AS POMAT, ZZ~MAKTX AS POMAKTX,
               EP~MATNR, EP~TXZ01 AS MAKTX,
               EP~WERKS, EP~LGORT,
               EK~LIFNR,
               L~LGOBE,
               W~NAME1 AS NAME1_W,
               LF~NAME1,
               PP~FLD_02 AS GOGRADE

    FROM ZGTMMT9461 AS ZZ
             INNER JOIN EKPO AS EP ON ZZ~EBELN EQ EP~EBELN
                                                AND ZZ~EBELP EQ EP~EBELP
             INNER JOIN EKKO AS EK ON ZZ~EBELN EQ EK~EBELN
             LEFT OUTER JOIN
           ZGTPPT1010 AS PP ON MODULE_KIND = 'MM'
                                       AND CODEGRP = '0880'
                                       AND ZZ~GRADE EQ PP~FLD_01
             LEFT OUTER JOIN
           LFA1 AS LF ON EK~LIFNR EQ LF~LIFNR
             LEFT OUTER JOIN
           T001W AS W ON EP~WERKS EQ W~WERKS
             LEFT OUTER JOIN
           T001L AS L ON EP~WERKS EQ L~WERKS
                           AND EP~LGORT EQ L~LGORT

    WHERE ZZ~BUDAT IN @S_BLDAT
        AND EP~WERKS EQ @P_WERKS
**2-1) 최종 조회된 데이터 SCR입고 처리 이력 점검(GAON)
** : 동일한 LOT NO(=MATDOC-CHARG_SID)가 존재하고 MBLNR 값이 <>"" 이면 처리 대상에서 제외
        AND NOT EXISTS ( SELECT Z71~LOTNO, Z71~MBLNR
                                       FROM ZGTMMT9471 AS Z71
                                       WHERE Z71~LOTNO = ZZ~LOTNO
                                            AND Z71~MBLNR IS NOT INITIAL
                                   )
    APPENDING CORRESPONDING FIELDS OF TABLE @GT_SCR_LIST.

  SORT GT_SCR_LIST BY BUDAT LOTNO VGBEL VGPOS .



ENDFORM.
*&---------------------------------------------------------------------*
*& Form F_AT_SCREEN_ON_BUDAT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_AT_SCREEN_ON_BUDAT .

  CHECK SY-UCOMM EQ 'ONLI'. "실행 인 경우 만 점검

  "전기동인 경우에만 점검
  CHECK P_ELC EQ ABAP_TRUE.

  "필수 값 점검
  IF S_BUDAT IS INITIAL.
    MESSAGE E278(00) WITH TEXT-F01. "입고일자
    LEAVE LIST-PROCESSING.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form F_AT_SCREEN_ON_BLDAT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_AT_SCREEN_ON_BLDAT .

  CHECK SY-UCOMM EQ 'ONLI'. "실행 인 경우 만 점검

  "SCR인 경우에만 점검
  CHECK P_SCR EQ ABAP_TRUE.

  "필수 값 점검
  IF S_BLDAT IS INITIAL.
    MESSAGE E278(00) WITH TEXT-F02. "납품일자
    LEAVE LIST-PROCESSING.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form F_GET_MATDOC_DATA_DISP
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_GET_MATDOC_DATA_DISP .
  CLEAR:
    GT_LIST[].

  SELECT DISTINCT
    Z70~IFNUM,
    Z70~MBLNR,
    Z70~MJAHR,
    Z70~BUDAT,
    Z70~BLDAT,
    Z70~ERFMG,
    Z70~ERFME,
    Z70~ERDAT,
    Z70~ERNAM,
    Z70~EBELN,
    Z70~EBELP,
    Z70~WERKS,
    W~NAME1 AS NAME1_W,
    EP~MATNR AS POMAT,
    EP~TXZ01 AS POMAKTX,
    EP~LGORT,
    L~LGOBE,
    EK~LIFNR,
    LF~NAME1

    FROM ZGTMMT9470 AS Z70
              INNER JOIN
            EKKO AS EK ON EK~EBELN EQ Z70~EBELN
              INNER JOIN
            EKPO AS EP ON EP~EBELN EQ Z70~EBELN
                              AND EP~EBELP EQ EP~EBELP
              LEFT OUTER JOIN
            LFA1 AS LF ON Z70~LIFNR EQ LF~LIFNR
              LEFT OUTER JOIN
            T001L AS L ON Z70~WERKS EQ L~WERKS
                            AND EP~LGORT EQ L~LGORT
              LEFT OUTER JOIN
            T001W AS W ON Z70~WERKS EQ W~WERKS

    WHERE Z70~WERKS EQ @P_WERKS
    AND Z70~BUDAT IN @S_BUDAT
    AND Z70~EBELN IN @S_EBELN
    AND Z70~MBLNR IS NOT INITIAL

    INTO CORRESPONDING FIELDS OF TABLE @GT_LIST.

  SORT GT_LIST BY IFNUM BUDAT EBELN EBELP.

  IF GT_LIST[] IS NOT INITIAL.
    SORT GT_ZGTPPT1010 BY CODEGRP FLD_01.

    LOOP AT GT_LIST INTO DATA(LS_LIST).
      DATA(LV_LIFNR) = |{ LS_LIST-LIFNR  ALPHA = OUT }|.

      READ TABLE GT_ZGTPPT1010 ASSIGNING FIELD-SYMBOL(<PP>)
      WITH KEY CODEGRP = '0860'
                        FLD_01 = LV_LIFNR BINARY SEARCH.
      IF SY-SUBRC = 0.
        LS_LIST-MATNR = <PP>-FLD_03.
        LS_LIST-MAKTX = <PP>-FLD_04.
      ENDIF.

      MODIFY GT_LIST FROM LS_LIST.
      CLEAR LS_LIST.
    ENDLOOP.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form F_GET_MATDOC_DATA_SCR_DISP
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_GET_MATDOC_DATA_SCR_DISP .
  CLEAR:
    GT_SCR_LIST[].

  SELECT DISTINCT
    Z71~LOTNO,
    Z71~BUDAT,
    Z71~VGBEL,
    Z71~VGPOS,
    Z71~KUNWE,
    Z71~KUNNR2,
    Z71~MATNR,
    TX~MAKTX ,
    Z71~ERFMG,
    Z71~ERFME,
    Z71~TRANS,
*    LF~NAME1 AS TRANS_N,
    Z71~TRUCK_NO,
    Z71~GRADE,
    Z71~EBELN,
    Z71~EBELP,
    Z71~MBLNR,
    Z71~MJAHR,
    Z71~GOGRADE,
    Z71~KUNNR,
    K~NAME1 AS NAME1_K,
    Z71~VBELN,
    Z71~POSNR,
    Z71~ZBIGO4,
    Z71~ERDAT,
    Z71~ERNAM,

    EK~LIFNR,
    LFK~NAME1 AS NAME1,
    EP~MATNR AS POMAT,
    EP~TXZ01 AS POMAKTX,
    EP~WERKS,
    W~NAME1 AS NAME1_W,
    Z71~LGORT,
    L~LGOBE

    FROM ZGTMMT9471 AS Z71
              INNER JOIN
            EKKO AS EK ON EK~EBELN = Z71~EBELN
              INNER JOIN
            EKPO AS EP ON EP~EBELN = Z71~EBELN
                              AND EP~EBELP = EP~EBELP
              LEFT OUTER JOIN
            MAKT AS TX ON Z71~MATNR = TX~MATNR
                              AND TX~SPRAS = @GC_3
*              LEFT OUTER JOIN
*            LFA1 AS LF ON Z71~TRANS = LF~LIFNR
              LEFT OUTER JOIN
            LFA1 AS LFK ON EK~LIFNR = LFK~LIFNR
              LEFT OUTER JOIN
            KNA1 AS K ON Z71~KUNNR = K~KUNNR
              LEFT OUTER JOIN
            T001L AS L ON Z71~WERKS = L~WERKS
                            AND Z71~LGORT = L~LGORT
              LEFT OUTER JOIN
            T001W AS W ON Z71~WERKS = W~WERKS

    WHERE Z71~WERKS EQ @P_WERKS
    AND Z71~BUDAT IN @S_BUDAT
    AND Z71~EBELN IN @S_EBELN
    AND Z71~MBLNR IS NOT INITIAL

    INTO CORRESPONDING FIELDS OF TABLE @GT_SCR_LIST.

  SORT GT_SCR_LIST BY BUDAT LOTNO EBELN EBELP.

  IF GT_SCR_LIST[] IS NOT INITIAL.
    SORT GT_ZGTPPT1010 BY CODEGRP FLD_01.

    LOOP AT GT_SCR_LIST INTO DATA(LS_LIST).
      DATA(LV_LIFNR) = |{ LS_LIST-LIFNR  ALPHA = OUT }|.

      READ TABLE GT_ZGTPPT1010 ASSIGNING FIELD-SYMBOL(<PP>)
      WITH KEY CODEGRP = '0870'
                     FLD_01 = LV_LIFNR BINARY SEARCH.
      IF SY-SUBRC = 0.
        LS_LIST-MATNR = <PP>-FLD_03.
        LS_LIST-MAKTX = <PP>-FLD_04.
      ENDIF.

      MODIFY GT_SCR_LIST FROM LS_LIST.
      CLEAR LS_LIST.
    ENDLOOP.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form F_SET_CHECK_LGOBE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- <LS_MAN>
*&---------------------------------------------------------------------*
FORM F_SET_CHECK_LGOBE  CHANGING PS_MAN TYPE TY_MAN.

  SELECT SINGLE LGOBE
     FROM T001L
   WHERE WERKS EQ @PS_MAN-WERKS
       AND  LGORT EQ @PS_MAN-UMLGO
      INTO @DATA(LV_LGOBE).

  PS_MAN-LGOBE_T = LV_LGOBE.

ENDFORM.


*&---------------------------------------------------------------------*
*& Form SET_STAB
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> P_
*&      --> P_WERKS
*&      --> P_
*&---------------------------------------------------------------------*
FORM SET_STAB  USING PV_SNAME
                    PV_KIND
                    PV_LOW
                    PV_HIGH.

  CLEAR : GT_STAB.

  GT_STAB-SELNAME = PV_SNAME.
  GT_STAB-KIND    = PV_KIND.
  GT_STAB-LOW     = PV_LOW.
  GT_STAB-HIGH    = PV_HIGH.

  IF PV_KIND = GC_S. "???
    GT_STAB-SIGN = GC_I.

    IF PV_HIGH IS NOT INITIAL.
      GT_STAB-OPTION = GC_BT.
    ELSE.
      GT_STAB-OPTION = GC_EQ.
    ENDIF.
  ENDIF.

  APPEND GT_STAB.

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

  CHECK SY-UCOMM EQ 'ONLI'. "실행 인 경우 만 점검

*  CASE ABAP_TRUE.
*    WHEN P_MAN.
  IF P_WERKS IS INITIAL.
    MESSAGE E278(00) WITH TEXT-F03.
    LEAVE LIST-PROCESSING.
  ENDIF.

*    WHEN P_RES.
*      IF S_WERKS IS INITIAL.
*        MESSAGE E278(00) WITH TEXT-F03.
*        LEAVE LIST-PROCESSING.
*      ENDIF.
*  ENDCASE.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_SET_EBELN_EBELP
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_SET_EBELN_EBELP .

  SELECT DISTINCT EP~EBELN, EP~EBELP,
               EP~MATNR, EP~TXZ01,
               EP~WERKS, EP~LGORT, EP~EMLIF,
               EK~LIFNR,
               LF~NAME1,
               L~LGOBE,
               W~NAME1 AS NAME1_W
    FROM EKKO AS EK
              INNER JOIN
              EKPO AS EP ON EK~EBELN EQ EP~EBELN
*TEXT
      INNER JOIN T001W AS W ON EP~WERKS EQ W~WERKS
      LEFT OUTER JOIN LFA1 AS LF ON EK~LIFNR EQ LF~LIFNR
      LEFT JOIN T001L AS L ON EP~WERKS EQ L~WERKS
                                                 AND EP~LGORT EQ L~LGORT

    WHERE EK~EBELN = @GS_SCR-EBELN
         AND EP~EBELP = @GS_SCR-EBELP
    INTO TABLE @DATA(LT_MAT).

  SORT LT_MAT BY EBELN EBELP.

*  SELECT SINGLE MBLNR , MJAHR
*    FROM MATDOC
*    WHERE EBELN = @GS_SCR-EBELN
*         AND EBELP = @GS_SCR-EBELP
*    INTO ( @DATA(LV_MBLNR), @DATA(LV_MJAHR) ).

  LOOP AT GT_ROW INTO DATA(LS_ROW).
*"전기동 조회 인 경우,
    IF P_ELC = GC_X.
      READ TABLE GT_LIST ASSIGNING FIELD-SYMBOL(<LIST>) INDEX LS_ROW-ROW_ID.
      IF SY-SUBRC = 0.
        READ TABLE LT_MAT ASSIGNING FIELD-SYMBOL(<MAT>) INDEX 1.
        IF SY-SUBRC = 0.
          <LIST>-POMAT = <MAT>-MATNR.
          <LIST>-POMAKTX = <MAT>-TXZ01.
          <LIST>-LIFNR = <MAT>-LIFNR.
          <LIST>-NAME1 = <MAT>-NAME1.
          <LIST>-WERKS = <MAT>-WERKS.
          <LIST>-NAME1_W = <MAT>-NAME1_W.
          <LIST>-LGORT = <MAT>-LGORT.
          <LIST>-LGOBE = <MAT>-LGOBE.
*           <LIST>-MBLNR = LV_MBLNR.
*           <LIST>-MJAHR = LV_MJAHR.
          <LIST>-EMLIF = <MAT>-EMLIF.
        ENDIF.
        <LIST>-EBELN = GS_SCR-EBELN.
        <LIST>-EBELP = GS_SCR-EBELP.
      ENDIF.
*SCR인 경우,
    ELSEIF P_SCR = GC_X.
      READ TABLE GT_SCR_LIST ASSIGNING FIELD-SYMBOL(<SCR>) INDEX LS_ROW-ROW_ID.
      IF SY-SUBRC = 0.
        READ TABLE LT_MAT ASSIGNING FIELD-SYMBOL(<MATS>) INDEX 1.
        IF SY-SUBRC = 0.
          <SCR>-POMAT = <MATS>-MATNR.
          <SCR>-POMAKTX = <MATS>-TXZ01.
          <SCR>-LIFNR = <MATS>-LIFNR.
          <SCR>-NAME1 = <MATS>-NAME1.
          <SCR>-WERKS = <MATS>-WERKS.
          <SCR>-NAME1_W = <MATS>-NAME1_W.
          <SCR>-LGORT = <MATS>-LGORT.
          <SCR>-LGOBE = <MATS>-LGOBE.
*           <SCR>-MBLNR = LV_MBLNR.
*           <SCR>-MJAHR = LV_MJAHR.
          <SCR>-EMLIF = <MATS>-EMLIF.
        ENDIF.
        <SCR>-EBELN = GS_SCR-EBELN.
        <SCR>-EBELP = GS_SCR-EBELP.
      ENDIF.
    ENDIF.
  ENDLOOP.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_SET_VBELN_POSNR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_SET_VBELN_POSNR .

  LOOP AT GT_ROW INTO DATA(LS_ROW).
    READ TABLE GT_SCR_LIST ASSIGNING FIELD-SYMBOL(<SCR>) INDEX LS_ROW-ROW_ID.
    IF SY-SUBRC = 0.
      <SCR>-VBELN = GS_SCR-VBELN.
      <SCR>-POSNR = GS_SCR-POSNR.
    ENDIF.
  ENDLOOP.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form GET_PO_RESB
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LT_RUN
*&      <-- LT_RESB
*&---------------------------------------------------------------------*
FORM GET_PO_RESB  USING  PT_TAB LIKE  GT_RUN_SCR
                             CHANGING CT_RESB TYPE TY_T_PO_RESB.

*구매오더의 COMPONENT 자재 정보추출(PO_COMP)
*	TABLE ; RESB
*	SELECT조건 : RSPOS,MATNR,BDMNG,MEINS,WERKS,LGORT,CHARG
*	WHRE 조건 : PT_TAB-EBELN, PT-TAB-EBELP
*3-1) COMPONENT 소비량 산출(COMP_QTY)
*  입고 수량 * 단위당소요량(RESB-BDMNG/EKPO-MENGE)

  SELECT
    EP~EBELN,
    EP~EBELP,
    EP~MENGE,
    RS~RSNUM,
    RS~RSPOS,
    RS~BDMNG,
    RS~MATNR,
    RS~MEINS,
    RS~WERKS,
    RS~LGORT,
    RS~CHARG,
    MC~XCHPF,
    EK~LIFNR
    FROM EKPO AS EP
              INNER JOIN
            RESB AS RS ON EP~EBELN EQ RS~EBELN
                          AND EP~EBELP EQ RS~EBELP
              INNER JOIN
            MARC AS MC ON RS~MATNR EQ MC~MATNR
                             AND RS~WERKS EQ MC~WERKS
              INNER JOIN
            EKKO AS EK ON EP~EBELN EQ EK~EBELN
    WHERE EXISTS (
##ITAB_KEY_IN_SELECT
      SELECT ZZ~EBELN, ZZ~EBELP
        FROM @PT_TAB AS ZZ
        WHERE ZZ~EBELN EQ EP~EBELN
           AND ZZ~EBELP EQ EP~EBELP
    )
    AND EP~LOEKZ EQ @SPACE
    AND RS~XLOEK EQ @SPACE
    ORDER BY EP~EBELN, EP~EBELP, RS~RSNUM, RS~RSPOS
    INTO TABLE @CT_RESB.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_GAON_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LT_LIST
*&      <-- GT_SCR_LIST
*&---------------------------------------------------------------------*
FORM GET_GAON_DATA  USING  PT_LIST TYPE TY_T_SCR_LIST
                                CHANGING PT_SCR_LIST TYPE  TY_T_SCR_LIST.

  DATA : LS_LIST TYPE TY_SCR_LIST.

*1-5) 선적 정보 조회
  SELECT Z06~VBELN, Z06~POSNR,
               VT~EXTI1 AS TRUCK_NO, VT~TKNUM,
               LF~NAME1 AS TRANS
       FROM ZLET0006 AS Z06
         LEFT OUTER JOIN VTTK AS VT ON Z06~TKNUM EQ VT~TKNUM
         LEFT OUTER JOIN LFA1 AS LF ON VT~TDLNR EQ LF~LIFNR
       USING CLIENT '100'
       FOR ALL ENTRIES IN @PT_LIST
       WHERE Z06~VBELN = @PT_LIST-VGBEL
       INTO TABLE @DATA(LT_0006).
  SORT LT_0006 BY VBELN POSNR.

**1-6) 등급 정보 조회(LS)
  SELECT MATNR, CHARG AS LOTNO, GRADE
    FROM ZGTSD_CV_GET_VCOFBATCH
    WITH PRIVILEGED ACCESS
    USING CLIENT '100'
    FOR ALL ENTRIES IN @PT_LIST
    WHERE MATNR EQ @PT_LIST-MATNR
         AND CHARG EQ @PT_LIST-LOTNO
         AND ATNAM EQ 'BT_AA_GRADE'
    INTO TABLE @DATA(LT_VC).
  SORT LT_VC BY MATNR LOTNO.

*2-1) 최종 조회된 데이터 SCR입고 처리 이력 점검(GAON)
* : 동일한 LOT NO(=MATDOC-CHARG_SID)가 존재하고 MBLNR 값이 <>"" 이면 처리 대상에서 제외
  SELECT LOTNO, MATNR, MBLNR
    FROM  ZGTMMT9471
    FOR ALL ENTRIES IN @PT_LIST
    WHERE LOTNO EQ @PT_LIST-LOTNO
        AND MBLNR IS NOT INITIAL
    INTO TABLE @DATA(LT_9471).
  SORT LT_9471 BY LOTNO MATNR.

*판매처 공통코드 정보_LS DATA 가져오기 위한 조건.
  SELECT FLD_01, FLD_03, FLD_04, FLD_05
     FROM ZGTPPT1010
  WHERE MODULE_KIND = 'SD'
       AND CODEGRP = '6007'
    INTO CORRESPONDING FIELDS OF TABLE @GT_KUNNR.
  SORT GT_KUNNR BY FLD_01.

  SORT GT_ZGTPPT1010 BY CODEGRP FLD_01.

**ALV SET
  LOOP AT PT_LIST ASSIGNING FIELD-SYMBOL(<LIST>).
*SCR입고 처리 이력 점검
* : 동일한 LOT NO(=MATDOC-CHARG_SID)가 존재하고 MBLNR 값이 <>"" 이면 처리 대상에서 제외
    READ TABLE LT_9471 ASSIGNING FIELD-SYMBOL(<LOT>)
    WITH KEY LOTNO = <LIST>-LOTNO
                   MATNR = <LIST>-MATNR BINARY SEARCH.
    IF SY-SUBRC = 0.
      IF <LOT>-MBLNR IS NOT INITIAL.
        CONTINUE.
      ENDIF.
    ENDIF.

*공통코드 마스터 등록된 SCR 자재만 대상으로 한다.
    DATA(LV_MATNR) = |{ <LIST>-MATNR ALPHA = OUT }|.

    READ TABLE GT_ZGTPPT1010 TRANSPORTING NO FIELDS
    WITH KEY CODEGRP = '0870'
                   FLD_03 = LV_MATNR BINARY SEARCH.
    IF SY-SUBRC <> 0.
      CONTINUE.
    ENDIF.

    CHECK SY-SUBRC = 0.

    LS_LIST = CORRESPONDING #( <LIST> ).

*대상 공급업체&자재번호
    DATA(LV_LIFNR) = |{ <LIST>-KUNAG ALPHA = OUT }|.

    READ TABLE GT_ZGTPPT1010 ASSIGNING FIELD-SYMBOL(<LT10>)
    WITH KEY CODEGRP = '0870'
                   FLD_01 = LV_LIFNR
                   FLD_03 = LV_MATNR BINARY SEARCH.

    IF SY-SUBRC = 0.
      LS_LIST-MAKTX = <LT10>-FLD_04.

    ELSE.
      CLEAR LS_LIST.
      CONTINUE.
    ENDIF.

*선적정보
    READ TABLE LT_0006 ASSIGNING FIELD-SYMBOL(<L6>)
    WITH KEY VBELN = LS_LIST-VGBEL BINARY SEARCH.
    IF SY-SUBRC = 0.
      LS_LIST-TRANS = <L6>-TRANS. "운송사
      LS_LIST-TRUCK_NO = <L6>-TRUCK_NO."차량번호.
    ENDIF.

*등급(가온)
*LS기준의 등급 정보를 먼저 가져온다.
    READ TABLE LT_VC ASSIGNING FIELD-SYMBOL(<VC>)
    WITH KEY MATNR = LS_LIST-MATNR
                   LOTNO = LS_LIST-LOTNO BINARY SEARCH.
    IF SY-SUBRC = 0.
      LS_LIST-GRADE = <VC>-GRADE .
*조회된 LS등급을 가온 기준의 공통코드 등급 설정.
      READ TABLE GT_ZGTPPT1010 ASSIGNING FIELD-SYMBOL(<GRD>)
      WITH KEY FLD_01 = <VC>-GRADE BINARY SEARCH.
      IF SY-SUBRC = 0.
        LS_LIST-GOGRADE = <GRD>-FLD_02.
      ENDIF.

    ELSE.
      READ TABLE GT_ZGTPPT1010 ASSIGNING FIELD-SYMBOL(<GRD2>)
      WITH KEY FLD_01 = '' BINARY SEARCH.
      IF SY-SUBRC = 0.
        LS_LIST-GOGRADE = <GRD2>-FLD_02.
      ENDIF.
    ENDIF.

*판매처 정보
    DATA(LV_KUNNR) = |{ LS_LIST-KUNWE ALPHA = OUT }|.
    READ TABLE GT_KUNNR ASSIGNING FIELD-SYMBOL(<KUN>)
    WITH KEY FLD_01 = LV_KUNNR BINARY SEARCH.

    IF SY-SUBRC = 0.
*LS 기준의 판매처 정보(가온 공통코드와 맞는 것만)
      LS_LIST-KUNNR = |{ <KUN>-FLD_04  ALPHA = IN }|.
      LS_LIST-NAME1_K = <KUN>-FLD_05.
    ENDIF.

*처리상태
    LS_LIST-STATUS = COND #( WHEN LS_LIST-MBLNR IS INITIAL THEN ICON_LED_YELLOW
                                               ELSE ICON_LED_GREEN ).

    CLEAR LS_LIST-ZCHK. "공급업체 데이터(ZGTMMT9461)여부 구분필드
    APPEND LS_LIST TO PT_SCR_LIST.
  ENDLOOP.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_AUTH
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CHECK_AUTH .
*회사코드
  AUTHORITY-CHECK OBJECT 'ZCBO_MM001'
               ID 'BUKRS' FIELD P_BUKRS.

  CHECK SY-SUBRC <> 0.

  SET CURSOR FIELD 'P_BUKRS'.
  MESSAGE E172 WITH P_BUKRS. "회사코드 [&] 작업권한을 확인하세요.

  "플랜트
  AUTHORITY-CHECK OBJECT 'ZCBO_MM001'
               ID 'WERKS' FIELD P_WERKS.

  CHECK SY-SUBRC <> 0.

  SET CURSOR FIELD 'P_WERKS'.
  MESSAGE E106 WITH P_WERKS. "플랜트 [&] 작업권한을 확인하세요.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form F_SET_BAPI_DATA_ELC
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_SET_BAPI_DATA_ELC .
  DATA:
    LT_9470 TYPE STANDARD TABLE OF ZGTMMT9470.

*  : 자재문서는 선택한 데이터 기준 BUDAT(입고일자) 별로 분할 생성
  "bapi 사용
  DATA:
    LS_HEADER TYPE BAPI2017_GM_HEAD_01,
    LS_CODE   TYPE BAPI2017_GM_CODE,
    LT_ITEM   TYPE STANDARD TABLE OF BAPI2017_GM_ITEM_CREATE,
    LT_RETURN TYPE STANDARD TABLE OF BAPIRET2,
    LS_HDRET  TYPE BAPI2017_GM_HEAD_RET.

  "초기화
  CLEAR:
    LS_CODE,
    LS_HEADER,
    LT_ITEM[],
    LT_RETURN[],
    LS_HDRET,
    LT_9470[].

  "CODE 설정
  LS_CODE-GM_CODE = GC_01.

  "헤더
  LS_HEADER-PSTNG_DATE = GS_SCR-BUDAT.
  LS_HEADER-DOC_DATE = GS_SCR-BUDAT.
  LS_HEADER-PR_UNAME = SY-UNAME.

  "아이템
  LOOP AT GT_RUN ASSIGNING FIELD-SYMBOL(<LS_RUN>).
    LT_ITEM = VALUE #( BASE LT_ITEM ( MOVE_TYPE = GC_101
                                            MATERIAL = <LS_RUN>-POMAT
                                            PLANT = <LS_RUN>-WERKS
                                            STGE_LOC = <LS_RUN>-LGORT
                                            PO_NUMBER = <LS_RUN>-EBELN
                                            PO_ITEM = <LS_RUN>-EBELP
                                            SPEC_STOCK = COND #( WHEN <LS_RUN>-EMLIF IS INITIAL THEN ''
                                                                                  ELSE 'O' )
                                            VENDOR = <LS_RUN>-LIFNR
                                            SUPPL_VEND = <LS_RUN>-EMLIF
                                            MVT_IND = COND #( WHEN <LS_RUN>-EMLIF IS INITIAL THEN ''
                                                                            ELSE 'B' )
                                            ENTRY_QNT = <LS_RUN>-ERFMG
                                            ENTRY_UOM = <LS_RUN>-ERFME
                                            LINE_ID = LINES( LT_ITEM ) + 1
                                             ) ).
  ENDLOOP.

****BAPI실행****
  CALL FUNCTION 'BAPI_GOODSMVT_CREATE'
    EXPORTING
      GOODSMVT_HEADER  = LS_HEADER
      GOODSMVT_CODE    = LS_CODE
    IMPORTING
      GOODSMVT_HEADRET = LS_HDRET
    TABLES
      GOODSMVT_ITEM    = LT_ITEM
      RETURN           = LT_RETURN.
  IF LS_HDRET-MAT_DOC IS INITIAL.
*      오류
    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

    LOOP AT GT_RUN ASSIGNING <LS_RUN>.
      READ TABLE GT_LIST ASSIGNING FIELD-SYMBOL(<LS_LIST>)  INDEX <LS_RUN>-TABIX.
      CHECK SY-SUBRC EQ 0.

      <LS_LIST>-STATUS = ICON_LED_RED.
      CLEAR <LS_LIST>-GR_FIN.

      READ TABLE LT_RETURN ASSIGNING FIELD-SYMBOL(<LS_REETURN>) WITH KEY TYPE = GC_E.
      IF SY-SUBRC EQ 0.
        <LS_LIST>-MESSAGE = <LS_REETURN>-MESSAGE.
      ENDIF.

      MODIFY GT_LIST FROM <LS_LIST> INDEX <LS_RUN>-TABIX.
    ENDLOOP.

    MESSAGE S000 DISPLAY LIKE 'E' WITH TEXT-M04. "입고 처리 실패했습니다.

  ELSE.
*      성공
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        WAIT = ABAP_TRUE.

    LOOP AT GT_RUN ASSIGNING <LS_RUN>.
      READ TABLE GT_LIST ASSIGNING <LS_LIST> INDEX <LS_RUN>-TABIX.
      CHECK SY-SUBRC EQ 0.

      <LS_LIST>-STATUS = ICON_LED_GREEN.
      <LS_LIST>-MESSAGE = SPACE.
      <LS_LIST>-MBLNR = LS_HDRET-MAT_DOC.
      <LS_LIST>-MJAHR = LS_HDRET-DOC_YEAR.
      <LS_LIST>-GR_FIN = ABAP_TRUE. "입고완료 여부->필드편집제어용
      MODIFY GT_LIST FROM <LS_LIST> INDEX <LS_RUN>-TABIX.

*전기동 입고 처리 이력 LOG TABLE UPDATE
      LT_9470[] = VALUE #( BASE LT_9470
                                     ( VALUE #( BASE CORRESPONDING #( <LS_LIST> )
                                       BUDAT = GS_SCR-BUDAT
                                       ERNAM = SY-UNAME
                                       ERDAT = SY-DATUM
                                       ERDAT_LOCAL = SY-DATLO
                                       ERTIM = SY-UZEIT
                                       ERTIM_LOCAL = SY-TIMLO ) ) ).
    ENDLOOP.

    MESSAGE S000 WITH TEXT-M03."입고 처리 완료 하였습니다.
  ENDIF.

  IF LT_9470[] IS NOT INITIAL.
    MODIFY ZGTMMT9470 FROM TABLE LT_9470.
    IF SY-SUBRC = 0.
      COMMIT WORK.
    ENDIF.
  ENDIF.

*    READ TABLE LT_RETURN ASSIGNING FIELD-SYMBOL(<LS_REETURN>) WITH KEY TYPE = GC_E.
*    IF SY-SUBRC EQ 0.
**      오류
*      CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
*
*      LOOP AT GROUP <LS_GROUP1> ASSIGNING <LS_RUN>.
*        READ TABLE GT_LIST ASSIGNING FIELD-SYMBOL(<LS_LIST>)  INDEX <LS_RUN>-TABIX.
*        CHECK SY-SUBRC EQ 0.
*
*        <LS_LIST>-STATUS = ICON_LED_RED.
*        <LS_LIST>-MESSAGE = <LS_REETURN>-MESSAGE.
*        CLEAR <LS_LIST>-GR_FIN.
*        MODIFY GT_LIST FROM <LS_LIST> INDEX <LS_RUN>-TABIX.
*      ENDLOOP.
*
*      MESSAGE S000 DISPLAY LIKE 'E' WITH TEXT-M04. "입고 처리 실패했습니다.
*
*    ELSE.
**      성공
*      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
*        EXPORTING
*          WAIT = ABAP_TRUE.
*
*      LOOP AT GROUP <LS_GROUP1> ASSIGNING <LS_RUN>.
*        READ TABLE GT_LIST ASSIGNING <LS_LIST> INDEX <LS_RUN>-TABIX.
*        CHECK SY-SUBRC EQ 0.
*
*        <LS_LIST>-STATUS = ICON_LED_GREEN.
*        <LS_LIST>-MESSAGE = SPACE.
*        <LS_LIST>-MBLNR = LS_HDRET-MAT_DOC.
*        <LS_LIST>-MJAHR = LS_HDRET-DOC_YEAR.
*        <LS_LIST>-BUDAT = LS_HEADER-PSTNG_DATE.
*        <LS_LIST>-GR_FIN = ABAP_TRUE. "입고완료 여부->필드편집제어용
*         MODIFY GT_LIST FROM <LS_LIST> INDEX <LS_RUN>-TABIX.
*
**전기동 입고 처리 이력 LOG TABLE UPDATE
*         LT_9470[] = VALUE #( BASE LT_9470
*                                        ( VALUE #( BASE CORRESPONDING #( <LS_LIST> )
*                                          ERNAM = SY-UNAME
*                                          ERDAT = SY-DATUM
*                                          ERDAT_LOCAL = SY-DATLO
*                                          ERTIM = SY-UZEIT
*                                          ERTIM_LOCAL = SY-TIMLO ) ) ).
*      ENDLOOP.
*
*      IF LT_9470[] IS NOT INITIAL.
*         MODIFY ZGTMMT9470 FROM TABLE LT_9470.
*         IF SY-SUBRC = 0.
*             COMMIT WORK.
*             CLEAR LT_9470.
*         ENDIF.
*      ENDIF.
*
*      MESSAGE S000 WITH TEXT-M03."입고 처리 완료 하였습니다.
*    ENDIF.
*  ENDLOOP.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form F_SET_BAPI_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_SET_BAPI_DATA .

  DATA:
    LT_RESB TYPE TY_T_PO_RESB,
    LT_9471 TYPE STANDARD TABLE OF ZGTMMT9471,
* 꼬리표 생성 실패 진단 로그(화면 미노출, 조용히 테이블에만 기록)
    LT_9472 TYPE STANDARD TABLE OF ZGTMMT9472.

*  : 자재문서는 선택한 데이터 기준 BUDAT(납품일자) 별로 분할 생성
  "bapi 사용
  DATA:
    LS_HEADER   TYPE BAPI2017_GM_HEAD_01,
    LS_CODE     TYPE BAPI2017_GM_CODE,
    LS_COMP     TYPE BAPI2017_GM_ITEM_CREATE,
    LT_ITEM     TYPE STANDARD TABLE OF BAPI2017_GM_ITEM_CREATE,
    LT_RETURN   TYPE STANDARD TABLE OF BAPIRET2,
    LS_HDRET    TYPE BAPI2017_GM_HEAD_RET,
    LT_ALLOC    TYPE TABLE OF BAPI1003_ALLOC_VALUES_CHAR,
    LT_ALC_NUM  TYPE TABLE OF BAPI1003_ALLOC_VALUES_NUM,
    LT_ALC_CURR TYPE TABLE OF BAPI1003_ALLOC_VALUES_CURR,
    LV_KEY      TYPE BAPI1003_KEY-OBJECT,
    LV_MATNR    TYPE MATNR18,
    LV_ID       TYPE BAPI2017_GM_ITEM_CREATE-LINE_ID,
    LT_ZPPT0001 TYPE STANDARD TABLE OF ZPPT0001.

*투입 Component 자재 정보 추출
  PERFORM GET_PO_RESB USING GT_RUN_SCR CHANGING LT_RESB.

  "초기화
  CLEAR:
      LS_CODE,
      LS_HEADER,
      LT_ITEM[],
      LT_RETURN[],
      LS_HDRET.

  "CODE 설정
  LS_CODE-GM_CODE = GC_01.

  "헤더
  LS_HEADER-PSTNG_DATE = GS_SCR-BUDAT.
  LS_HEADER-DOC_DATE = GS_SCR-BUDAT.
  LS_HEADER-PR_UNAME = SY-UNAME.

  "아이템
  LOOP AT GT_RUN_SCR ASSIGNING FIELD-SYMBOL(<LS_RUN>).
    LV_ID = LINES( LT_ITEM ) + 1.
    LT_ITEM = VALUE #( BASE LT_ITEM ( MOVE_TYPE = GC_101
                                                STCK_TYPE = ''
                                                MATERIAL = <LS_RUN>-POMAT
                                                PLANT = <LS_RUN>-WERKS
                                                STGE_LOC = <LS_RUN>-LGORT
                                                PO_NUMBER = <LS_RUN>-EBELN
                                                PO_ITEM = <LS_RUN>-EBELP
                                                ENTRY_QNT = <LS_RUN>-ERFMG
                                                ENTRY_UOM = <LS_RUN>-ERFME
                                                BATCH = <LS_RUN>-LOTNO
                                                MVT_IND = GC_B
                                                LINE_ID = LV_ID
                                                PARENT_ID = ''
                                                 ) ).
    "PO COMPONENT 기준_아이템 추가
    READ TABLE LT_RESB WITH KEY EBELN = <LS_RUN>-EBELN
                                                     EBELP = <LS_RUN>-EBELP
                              BINARY SEARCH TRANSPORTING NO FIELDS.
    IF SY-SUBRC EQ 0.
      LOOP AT LT_RESB ASSIGNING FIELD-SYMBOL(<LS_RESB>) FROM SY-TABIX.
        IF <LS_RESB>-EBELN NE <LS_RUN>-EBELN OR <LS_RESB>-EBELP NE <LS_RUN>-EBELP.
          EXIT.
        ENDIF.

        LS_COMP-LINE_ID = LV_ID.
        LS_COMP-MATERIAL = <LS_RESB>-MATNR.
        LS_COMP-PLANT = <LS_RESB>-WERKS.
        LS_COMP-STGE_LOC = <LS_RESB>-LGORT.
        LS_COMP-PO_NUMBER = <LS_RUN>-EBELN.
        LS_COMP-PO_ITEM = <LS_RUN>-EBELP.
        LS_COMP-MOVE_TYPE = '543'.
        LS_COMP-BATCH = <LS_RESB>-CHARG.
*ENTRY_QNT(입고수량) 조건 별 설정
*: PO 소요량정보로 입고수량 대비 투입 처리 수량 산출
*->COMPONENT 소비량  = 입고 수량 * 단위당소요량(RESB-BDMNG/EKPO-MENGE)"
        IF <LS_RESB>-MENGE IS NOT INITIAL.
          LS_COMP-ENTRY_QNT = <LS_RUN>-ERFMG * ( <LS_RESB>-BDMNG / <LS_RESB>-MENGE ).
        ELSE.
          LS_COMP-ENTRY_QNT = 0.
        ENDIF.

        LS_COMP-ENTRY_UOM = <LS_RESB>-MEINS.
        LS_COMP-MVT_IND = GC_B.
        LS_COMP-LINE_ID += 1.
        LS_COMP-PARENT_ID = LV_ID.
        LT_ITEM = VALUE #( BASE LT_ITEM ( LS_COMP ) ).
      ENDLOOP.
    ENDIF.
  ENDLOOP.

  CLEAR : LT_9471, LT_ZPPT0001.

****BAPI실행****
  CALL FUNCTION 'BAPI_GOODSMVT_CREATE'
    EXPORTING
      GOODSMVT_HEADER  = LS_HEADER
      GOODSMVT_CODE    = LS_CODE
    IMPORTING
      GOODSMVT_HEADRET = LS_HDRET
    TABLES
      GOODSMVT_ITEM    = LT_ITEM
      RETURN           = LT_RETURN.
  IF LS_HDRET-MAT_DOC IS INITIAL.
*      오류
    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

    LOOP AT GT_RUN_SCR ASSIGNING <LS_RUN>.
      READ TABLE GT_SCR_LIST ASSIGNING FIELD-SYMBOL(<LS_LIST>) INDEX <LS_RUN>-TABIX.
      CHECK SY-SUBRC EQ 0.

      <LS_LIST>-STATUS = ICON_LED_RED.
      CLEAR <LS_LIST>-GR_FIN.

      READ TABLE LT_RETURN ASSIGNING FIELD-SYMBOL(<LS_REETURN>) WITH KEY TYPE = GC_E.
      IF SY-SUBRC EQ 0.
        <LS_LIST>-MESSAGE = <LS_REETURN>-MESSAGE.
      ENDIF.

      MODIFY GT_SCR_LIST FROM <LS_LIST> INDEX <LS_RUN>-TABIX.
    ENDLOOP.

    MESSAGE S000 DISPLAY LIKE 'E' WITH TEXT-M04. "입고 처리 실패했습니다.

  ELSE.
*      성공
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        WAIT = ABAP_TRUE.

    LOOP AT GT_RUN_SCR ASSIGNING <LS_RUN>.
      READ TABLE GT_SCR_LIST ASSIGNING <LS_LIST> INDEX <LS_RUN>-TABIX.
      CHECK SY-SUBRC EQ 0.

      <LS_LIST>-STATUS = ICON_LED_GREEN.
      <LS_LIST>-MESSAGE = SPACE.
      <LS_LIST>-MBLNR = LS_HDRET-MAT_DOC.
      <LS_LIST>-MJAHR = LS_HDRET-DOC_YEAR.
      <LS_LIST>-GR_FIN = ABAP_TRUE. "입고완료 여부->필드편집제어용
      MODIFY GT_SCR_LIST FROM <LS_LIST> INDEX <LS_RUN>-TABIX.

*2-9)SCR 입고 처리 이력 LOG TABLE UPDATE DATA SET
      LT_9471[] = VALUE #( BASE LT_9471
                                      ( VALUE #( BASE CORRESPONDING #( <LS_LIST> )
                                        BUDAT = GS_SCR-BUDAT
                                        ERNAM = SY-UNAME
                                        ERDAT = SY-DATUM
                                        ERDAT_LOCAL = SY-DATLO
                                        ERTIM = SY-UZEIT
                                        ERTIM_LOCAL = SY-TIMLO ) ) ).

*2-9) 입고 정상 처리 후 꼬리표 테이블 업데이트 DATA SET
      SELECT SINGLE MD~WERKS, MD~EBELN, MD~EBELP,
                    MD~CHARG_SID AS CHARG,
                    MD~MBLNR, MD~LINE_ID,
                    MD~MATNR, MD~ERFMG, MD~ERFME,
                    MD~LGORT_SID AS LGORT,
                    MC~DISPO
           FROM MATDOC AS MD
           INNER  JOIN EKPO AS EP ON MD~EBELN EQ EP~EBELN
                                               AND MD~EBELP EQ EP~EBELP
           INNER JOIN MARC AS MC ON MD~WERKS EQ MC~WERKS
                                               AND MD~MATNR EQ MC~MATNR
           WHERE MD~WERKS = @P_WERKS
                AND MD~BUKRS = @P_BUKRS
                AND MD~MATNR = @<LS_LIST>-POMAT
                AND MD~MBLNR = @<LS_LIST>-MBLNR
                AND MD~CHARG_SID = @<LS_LIST>-LOTNO
           INTO @DATA(LS_MAT).

      IF  LS_MAT IS NOT INITIAL.
        APPEND VALUE #( WERKS = LS_MAT-WERKS
                                   AUFNR = LS_MAT-EBELN
                                   TAGNR = <LS_LIST>-LOTNO
                                   POSNR = LS_MAT-EBELP
                                   CHARG = LS_MAT-CHARG
                                   MBLNR = LS_MAT-MBLNR
                                   MATNR = LS_MAT-MATNR
                                   SPGCD  = LS_MAT-DISPO(2)
                                   MGVRG = LS_MAT-ERFMG
                                   FOSTCNT = GC_1
                                   REMAIN = LS_MAT-ERFMG
                                   MEINS = LS_MAT-ERFME
                                   OUTFLG = GC_3
                                   GIFLG = GC_N
                                   GRFLG = GC_Y
                                   INSPFLG = GC_OK
                                   LGORT = LS_MAT-LGORT
                                   GRINDAT = SY-DATUM
                                   GRINTIM = SY-UZEIT
                                   GRINNAM = SY-UNAME ) TO LT_ZPPT0001.

*2-8) 입고 정상 처리 후 배치 클래스 속성 정보 업데이트  BAPI 수행
        CLEAR LT_ALLOC.
        LT_ALLOC[] = VALUE #( BASE LT_ALLOC
                                          ( CHARACT = 'PD_CA_CUSTOMER_CODE'
                                            VALUE_CHAR = |{ <LS_LIST>-KUNNR ALPHA = OUT }| )
                                          ( CHARACT = 'PD_CA_GRADE'
                                            VALUE_CHAR = <LS_LIST>-GOGRADE )
                                          ( CHARACT = 'PD_CA_GIDATE'
                                            VALUE_CHAR = <LS_LIST>-BUDAT ) ).

        CLEAR : LV_MATNR, LV_KEY, LT_RETURN.
        LV_MATNR = |{ <LS_LIST>-POMAT ALPHA = IN }|.

        CHECK LS_MAT-CHARG IS NOT INITIAL.

        LV_KEY(18) = LV_MATNR.
        LV_KEY+18(10) = LS_MAT-CHARG.

        CALL FUNCTION 'BAPI_OBJCL_CHANGE'
          EXPORTING
            OBJECTKEY          = LV_KEY
            OBJECTTABLE        = 'MCH1'
            CLASSNUM           = 'HB_GO_SCR'
            CLASSTYPE          = '023'
          TABLES
            ALLOCVALUESNUMNEW  = LT_ALC_NUM
            ALLOCVALUESCHARNEW = LT_ALLOC
            ALLOCVALUESCURRNEW = LT_ALC_CURR
            RETURN             = LT_RETURN.
        READ TABLE LT_RETURN ASSIGNING FIELD-SYMBOL(<LS_R2TURN>) WITH KEY TYPE = GC_E.
        IF SY-SUBRC EQ 0.
*      오류
          CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
          <LS_LIST>-MESSAGE = <LS_R2TURN>-MESSAGE.

        ELSE.
*      배치특성 성공
          CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
            EXPORTING
              WAIT = ABAP_TRUE.
        ENDIF.

        CLEAR LS_MAT.
      ELSE.
* 꼬리표 매칭 실패 진단 로그
        TRY.
            LT_9472 = VALUE #( BASE LT_9472
                                ( MANDT   = SY-MANDT
                                  LOTNO   = <LS_LIST>-LOTNO
                                  MBLNR   = <LS_LIST>-MBLNR
                                  MJAHR   = <LS_LIST>-MJAHR
                                  WERKS   = <LS_LIST>-WERKS
                                  POMAT   = <LS_LIST>-POMAT
                                  P_WERKS = P_WERKS
                                  P_BUKRS = P_BUKRS
                                  ERRTYPE = '매칭실패'
                                  ERDAT   = SY-DATUM
                                  ERTIM   = SY-UZEIT
                                  ERNAM   = SY-UNAME ) ).
          CATCH CX_ROOT.
        ENDTRY.
      ENDIF.

    ENDLOOP. "자재문서 생성 후, 후속처리 종료(테이블 업데이트 설정 및 배치클래스 변경)

  ENDIF.

*SCR 입고 처리 이력 업데이트
  IF LT_9471[] IS NOT INITIAL.
    MODIFY ZGTMMT9471 FROM TABLE LT_9471.
    IF SY-SUBRC = 0.
      COMMIT WORK.
    ELSE.
      TRY.
          LOOP AT LT_9471 ASSIGNING FIELD-SYMBOL(<LS_9471_ERR>).
            LT_9472 = VALUE #( BASE LT_9472
                                ( MANDT   = SY-MANDT
                                  LOTNO   = <LS_9471_ERR>-LOTNO
                                  MBLNR   = <LS_9471_ERR>-MBLNR
                                  MJAHR   = <LS_9471_ERR>-MJAHR
                                  WERKS   = <LS_9471_ERR>-WERKS
                                  P_WERKS = P_WERKS
                                  P_BUKRS = P_BUKRS
                                  ERRTYPE = '9471저장실패'
                                  ERDAT   = SY-DATUM
                                  ERTIM   = SY-UZEIT
                                  ERNAM   = SY-UNAME ) ).
          ENDLOOP.
        CATCH CX_ROOT.
      ENDTRY.
    ENDIF.
  ENDIF.
*꼬리표 정보 업데이트
  IF LT_ZPPT0001[] IS NOT INITIAL.
    MODIFY ZPPT0001 FROM TABLE LT_ZPPT0001.
    IF SY-SUBRC = 0.
      COMMIT WORK.
    ELSE.

      TRY.
          LOOP AT LT_ZPPT0001 ASSIGNING FIELD-SYMBOL(<LS_ZPPT_ERR>).
            LT_9472 = VALUE #( BASE LT_9472
                                ( MANDT   = SY-MANDT
                                  LOTNO   = <LS_ZPPT_ERR>-TAGNR
                                  MBLNR   = <LS_ZPPT_ERR>-MBLNR
                                  WERKS   = <LS_ZPPT_ERR>-WERKS
                                  POMAT   = <LS_ZPPT_ERR>-MATNR
                                  P_WERKS = P_WERKS
                                  P_BUKRS = P_BUKRS
                                  ERRTYPE = 'ZPPT0001저장실패'
                                  ERDAT   = SY-DATUM
                                  ERTIM   = SY-UZEIT
                                  ERNAM   = SY-UNAME ) ).
          ENDLOOP.
        CATCH CX_ROOT.
      ENDTRY.
    ENDIF.
  ENDIF.

  IF LT_9472[] IS NOT INITIAL.
    TRY.
        MODIFY ZGTMMT9472 FROM TABLE LT_9472.
        IF SY-SUBRC = 0.
          COMMIT WORK.
        ENDIF.
      CATCH CX_ROOT.
    ENDTRY.
  ENDIF.

*    READ TABLE LT_RETURN ASSIGNING FIELD-SYMBOL(<LS_REETURN>) WITH KEY TYPE = GC_E.
*    IF SY-SUBRC EQ 0.
**      오류
*      CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
*
*      LOOP AT GROUP <LS_GROUP1> ASSIGNING <LS_RUN>.
*        READ TABLE GT_SCR_LIST ASSIGNING FIELD-SYMBOL(<LS_LIST>) INDEX <LS_RUN>-TABIX.
*        CHECK SY-SUBRC EQ 0.
*
*        <LS_LIST>-STATUS = ICON_LED_RED.
*        <LS_LIST>-MESSAGE = <LS_REETURN>-MESSAGE.
*        CLEAR <LS_LIST>-GR_FIN.
*        MODIFY GT_SCR_LIST FROM <LS_LIST> INDEX <LS_RUN>-TABIX.
*      ENDLOOP.
*
*      MESSAGE S000 DISPLAY LIKE 'E' WITH TEXT-M04. "입고 처리 실패했습니다.
*
*    ELSE.
**      성공
*      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
*        EXPORTING
*          WAIT = ABAP_TRUE.
*
*      LOOP AT GROUP <LS_GROUP1> ASSIGNING <LS_RUN>.
*        READ TABLE GT_SCR_LIST ASSIGNING <LS_LIST> INDEX <LS_RUN>-TABIX.
*        CHECK SY-SUBRC EQ 0.
*
*        <LS_LIST>-STATUS = ICON_LED_GREEN.
*        <LS_LIST>-MESSAGE = SPACE.
*        <LS_LIST>-MBLNR = LS_HDRET-MAT_DOC.
*        <LS_LIST>-MJAHR = LS_HDRET-DOC_YEAR.
*        <LS_LIST>-BUDAT = LS_HEADER-PSTNG_DATE.
*        <LS_LIST>-GR_FIN = ABAP_TRUE. "입고완료 여부->필드편집제어용
*        MODIFY GT_SCR_LIST FROM <LS_LIST> INDEX <LS_RUN>-TABIX.
*
**SCR 입고 처리 이력 LOG TABLE UPDATE DATA SET
*        LT_9471[] = VALUE #( BASE LT_9471
*                                        ( VALUE #( BASE CORRESPONDING #( <LS_LIST> )
*                                          ERNAM = SY-UNAME
*                                          ERDAT = SY-DATUM
*                                          ERDAT_LOCAL = SY-DATLO
*                                          ERTIM = SY-UZEIT
*                                          ERTIM_LOCAL = SY-TIMLO ) ) ).
*
*        SELECT SINGLE MD~WERKS, MD~EBELN, MD~EBELP,
*                      MD~CHARG_SID AS CHARG,
*                      MD~MBLNR, MD~LINE_ID,
*                      MD~MATNR, MD~ERFMG, MD~ERFME,
*                      MD~LGORT_SID AS LGORT,
*                      MC~DISPO
*             FROM MATDOC AS MD
*             INNER  JOIN EKPO AS EP ON MD~EBELN EQ EP~EBELN
*                                                 AND MD~EBELP EQ EP~EBELP
*             INNER JOIN MARC AS MC ON MD~WERKS EQ MC~WERKS
*                                                 AND MD~MATNR EQ MC~MATNR
*             WHERE MD~WERKS = @P_WERKS
*                  AND MD~BUKRS = @P_BUKRS
*                  AND MD~MATNR = @<LS_LIST>-POMAT
*                  AND MD~MBLNR = @<LS_LIST>-MBLNR
*                  AND MD~CHARG_SID = @<LS_LIST>-LOTNO
*             INTO  @DATA(LS_MAT).
*
**2-9) 입고 정상 처리 후 꼬리표 테이블 업데이트 DATA SET
**           IF LT_MAT[] IS NOT INITIAL.
*        IF  LS_MAT IS NOT INITIAL.
**             LOOP AT LT_MAT INTO DATA(LS_MAT).
**               CHECK LS_MAT-MBLNR EQ <LS_LIST>-MBLNR.
**               CHECK LS_MAT-MATNR EQ <LS_LIST>-POMAT.
*          APPEND VALUE #( WERKS = LS_MAT-WERKS
*                                     AUFNR = LS_MAT-EBELN
*                                     TAGNR = <LS_LIST>-LOTNO
*                                     POSNR = LS_MAT-EBELP
*                                     CHARG = LS_MAT-CHARG
*                                     MBLNR = LS_MAT-MBLNR
*                                     MATNR = LS_MAT-MATNR
*                                     SPGCD  = LS_MAT-DISPO(2)
*                                     MGVRG = LS_MAT-ERFMG
*                                     FOSTCNT = GC_1
*                                     REMAIN = LS_MAT-ERFMG
*                                     MEINS = LS_MAT-ERFME
*                                     OUTFLG = GC_3
*                                     GIFLG = GC_N
*                                     GRFLG = GC_Y
*                                     INSPFLG = GC_OK
*                                     LGORT = LS_MAT-LGORT
*                                     GRINDAT = SY-DATUM
*                                     GRINTIM = SY-UZEIT
*                                     GRINNAM = SY-UNAME ) TO LT_ZPPT0001.
**             ENDLOOP.
**        ENDIF.
**2-8) 입고 정상 처리 후 배치 클래스 속성 정보 업데이트  BAPI 수행
*        CLEAR LT_ALLOC.
*        LT_ALLOC[] = VALUE #( BASE LT_ALLOC
*                                          ( CHARACT = 'PD_CA_CUSTOMER_CODE'
*                                            VALUE_CHAR = |{ <LS_LIST>-KUNNR ALPHA = OUT }| )
*                                          ( CHARACT = 'PD_CA_GRADE'
*                                            VALUE_CHAR = <LS_LIST>-GOGRADE )
*                                          ( CHARACT = 'PD_CA_GIDATE'
*                                            VALUE_CHAR = <LS_LIST>-BUDAT ) ).
*
**         IF LINES( LT_MAT ) > 1.
**           LOOP AT LT_MAT ASSIGNING FIELD-SYMBOL(<BMAT>).
**             CLEAR : LV_MATNR, LV_KEY, LT_RETURN.
**             LV_MATNR = |{ <LS_LIST>-POMAT ALPHA = IN }|.
**
**             CHECK <BMAT>-CHARG IS NOT INITIAL.
**
**             LV_KEY(18) = LV_MATNR.
**             LV_KEY+18(10) = <BMAT>-CHARG.
**
**             CALL FUNCTION 'BAPI_OBJCL_CHANGE'
**               EXPORTING
**                 OBJECTKEY                = LV_KEY
**                 OBJECTTABLE            = 'MCH1'
**                 CLASSNUM                 = 'HB_GO_SCR'
**                 CLASSTYPE                = '023'
**               TABLES
**                 ALLOCVALUESNUMNEW    = LT_ALC_NUM
**                 ALLOCVALUESCHARNEW   = LT_ALLOC
**                 ALLOCVALUESCURRNEW   = LT_ALC_CURR
**                 RETURN                            = LT_RETURN
**                   .
**             READ TABLE LT_RETURN INTO DATA(LS_RT) WITH KEY TYPE = GC_E.
**             IF SY-SUBRC EQ 0.
**               CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
**               <LS_LIST>-MESSAGE = LS_RT-MESSAGE.
**               EXIT.
**             ELSE.
**               CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
**                 EXPORTING
**                   WAIT = ABAP_TRUE.
**             ENDIF.
**           ENDLOOP.
**
**           MESSAGE S000 WITH TEXT-E14 DISPLAY LIKE 'E'. "배치 특성 업데이트 실패하였습니다.
**
**         ELSE.
**           READ TABLE LT_MAT ASSIGNING FIELD-SYMBOL(<BBMAT>) INDEX 1.
*          CLEAR : LV_MATNR, LV_KEY, LT_RETURN.
*          LV_MATNR = |{ <LS_LIST>-POMAT ALPHA = IN }|.
*
**             CHECK <BBMAT>-CHARG IS NOT INITIAL.
*          CHECK LS_MAT-CHARG IS NOT INITIAL.
*
*          LV_KEY(18) = LV_MATNR.
*          LV_KEY+18(10) = LS_MAT-CHARG."<BBMAT>-CHARG.
*
*          CALL FUNCTION 'BAPI_OBJCL_CHANGE'
*             EXPORTING
*               OBJECTKEY                = LV_KEY
*               OBJECTTABLE            = 'MCH1'
*               CLASSNUM                 = 'HB_GO_SCR'
*               CLASSTYPE                = '023'
*             TABLES
*               ALLOCVALUESNUMNEW    = LT_ALC_NUM
*               ALLOCVALUESCHARNEW   = LT_ALLOC
*               ALLOCVALUESCURRNEW   = LT_ALC_CURR
*               RETURN                            = LT_RETURN
*                   .
*          READ TABLE LT_RETURN ASSIGNING FIELD-SYMBOL(<LS_R2TURN>) WITH KEY TYPE = GC_E.
*          IF SY-SUBRC EQ 0.
**      오류
*             CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
*
*             READ TABLE GT_SCR_LIST ASSIGNING <LS_LIST> INDEX <LS_RUN>-TABIX.
*             CHECK SY-SUBRC EQ 0.
*
*             <LS_LIST>-MESSAGE = <LS_R2TURN>-MESSAGE.
**             MESSAGE S000 DISPLAY LIKE 'E' WITH TEXT-M07. "배치 특성 업데이트 실패했습니다.
*
*          ELSE.
**      배치특성 성공
*             CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
*               EXPORTING
*                 WAIT = ABAP_TRUE.
*          ENDIF.
*
*        ENDIF.
*      ENDLOOP.

**SCR 입고 처리 이력 업데이트
*      IF LT_9471[] IS NOT INITIAL.
*         MODIFY ZGTMMT9471 FROM TABLE LT_9471.
*         IF SY-SUBRC = 0.
*             COMMIT WORK.
*         ENDIF.
*      ENDIF.
**꼬리표 정보 업데이트
*      IF LT_ZPPT0001[] IS NOT INITIAL.
*         MODIFY ZPPT0001 FROM TABLE LT_ZPPT0001.
*         IF SY-SUBRC = 0.
*             COMMIT WORK.
*         ENDIF.
*      ENDIF.
*
*      MESSAGE S000 WITH TEXT-M03."입고 처리 완료 하였습니다.
*    ENDIF.

*  ENDLOOP.

ENDFORM.
