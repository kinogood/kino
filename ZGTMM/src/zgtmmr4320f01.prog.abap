*&---------------------------------------------------------------------*
*& Include          ZGTMMR4320F01
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

  "요청일
  IF S_RSDAT[] IS INITIAL.
    S_RSDAT[] = VALUE #( ( SIGN = 'I' OPTION = 'BT' LOW = SY-DATLO - 1  HIGH = SY-DATLO ) ).
  ENDIF.

  "전기일자
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

  CASE ABAP_TRUE.
    WHEN P_RES. "예약 전기
      "예약
      PERFORM F_GET_RESB_DATA.
      "자재문서
      PERFORM F_GET_MATDOC_DATA.
      "재고 조회
      PERFORM F_GET_MARD_DATA.

    WHEN P_MAN. "수기 생성
      IF P_ALL EQ ABAP_TRUE.  "이전전기 처리
        PERFORM F_GET_MATDOC_DATA_MAN.
      ELSEIF P_COM EQ ABAP_TRUE.  "조회
        PERFORM F_GET_MATDOC_DATA_MAN_DISP.
      ENDIF.

      SORT GT_MAN[] BY BUDAT MATNR LGORT CHARG.
  ENDCASE.

  "ALV 스타일 설정
  PERFORM F_SET_ALV_STYLE.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_GET_RESB_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_GET_RESB_DATA .

  "초기화
  CLEAR GT_LIST[].
*
*1)	 실행 조회조건 값을 기준으로 대상 예약오더 대상 추출
*	Table : RBKP
*	Select 조건  : RSNUM
*	WHERE조건
*	WERKS = 입력 플랜트
*	RSDAT = 입력 요청일
*	BWART = '311'
*
*2)	 예약오더 상세 정보 추출
*	Table : RESB
*	Select 조건  : RSNUM,RSPOS,BWART,BDTER,MATNR,WERKS,LGORT,BDMNG,MEINS,CHARG,UMLGO
*	WHERE조건
*	RSNUM = 1) 의 대상 문서번호

  "<--2026.05.29 필드 추가 - 최신 I/F SELECT
  SELECT Z4~RSNUM,
         MAX( Z4~ZIFKEY ) AS ZIFKEY
    FROM ZGTPPT3340 AS Z4
    JOIN ZGTPPT3350 AS Z5 ON  Z4~ZIFKEY EQ Z5~ZIFKEY
                                        AND Z4~ZSERNO EQ Z5~ZSERNO
                                        AND Z4~ZREQ_NO EQ Z5~ZREQ_NO
    WHERE  Z4~ZERP_STAT EQ @GC_S
    AND Z4~WERKS EQ @P_WERKS
    AND Z4~RSNUM IN @S_RSNUM
    AND Z5~REQ_DATE IN @S_RSDAT
    GROUP BY RSNUM
   INTO TABLE @DATA(LT_IF_MAX).
  "2026.05.29 필드 추가-->


  SELECT
    RK~RSNUM,
    RS~RSPOS,
    RK~BWART,
    RS~BDTER,
    RS~MATNR,
    MT~MAKTX,
    RS~WERKS,
    RS~LGORT,
    RS~BDMNG,
    RS~MEINS,
    RS~UMWRK,
    RS~UMLGO,
    MC~XCHPF,
    RS~CHARG,
    Z5~LOCATION,  "2026.05.29 필드 추가
    Z5~REMARKS    "2026.05.29 필드 추가
    FROM RKPF AS RK
                INNER JOIN
              RESB AS RS ON RK~RSNUM EQ RS~RSNUM
                INNER JOIN
              MARC AS MC ON RS~WERKS EQ MC~WERKS
                                 AND RS~MATNR EQ MC~MATNR
    "<--2026.05.29 필드 추가
                LEFT OUTER JOIN @LT_IF_MAX AS ZM
                  ON RS~RSNUM = ZM~RSNUM
                LEFT OUTER JOIN ZGTPPT3340 AS Z4
                  ON Z4~RSNUM  = ZM~RSNUM
                 AND Z4~ZIFKEY = ZM~ZIFKEY
                LEFT OUTER JOIN
              ZGTPPT3350 AS Z5 ON RS~RSPOS EQ Z5~ZREQ_ITEM
                                           AND RS~MATNR EQ Z5~MATNR
                                           AND Z4~ZIFKEY EQ Z5~ZIFKEY
                                           AND Z4~ZSERNO EQ Z5~ZSERNO
                                           AND Z4~ZREQ_NO EQ Z5~ZREQ_NO
"2026.05.29 필드 추가-->
                LEFT OUTER JOIN
              MAKT AS MT ON RS~MATNR EQ MT~MATNR
                                AND MT~SPRAS EQ @SY-LANGU
    WHERE RK~UMWRK EQ @P_WERKS
    AND RK~RSDAT IN @S_RSDAT
    AND RK~RSNUM IN @S_RSNUM
    AND RK~BWART EQ @GC_311
    AND RS~MATNR IN @S_MATNR
    ORDER BY RS~RSNUM, RS~RSPOS
    INTO CORRESPONDING FIELDS OF TABLE @GT_LIST.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_GET_MATDOC_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_GET_MATDOC_DATA .

  "대상 예약오더가 있으면 진행
  CHECK GT_LIST[] IS NOT INITIAL.

*3) 2)의 대상 예약오더,품목의 자재문서 이력 점검
*	Table : MATDOC
*	Select 조건 : MJAHR,MBLNR,ZEILE
*	WHERE 조건 : 2) 의 대상 RSNUM, RSPOS
*	MBLNR <> "" 이고, CANCELLED = "" 이면 XAUTO ="" 라인의 데이터 선택
*	(MBLNR = "" or MBLRN <> "" 이고 CANCELLED <> "" 이면 예약오더 상세 정보 필드만 대상으로 함)
  SELECT
    MD~RSNUM,
    MD~RSPOS,
    MD~MJAHR,
    MD~MBLNR,
    MD~BUDAT,
    SUM( MD~ERFMG ) AS ERFMG
    FROM MATDOC AS MD
    WHERE EXISTS (
      SELECT ZZ~RSNUM, ZZ~RSPOS
        FROM @GT_LIST AS ZZ
        WHERE ZZ~RSNUM EQ MD~RSNUM
           AND ZZ~RSPOS EQ MD~RSPOS
    )
    AND MD~XAUTO EQ @SPACE
    AND MD~CANCELLED EQ @SPACE
    AND MD~REVERSAL_MOVEMENT EQ @SPACE
    GROUP BY MD~RSNUM, MD~RSPOS, MD~MJAHR, MD~MBLNR, MD~BUDAT
    ORDER BY MD~RSNUM, MD~RSPOS
    INTO TABLE @DATA(LT_MATDOC).

  LOOP AT GT_LIST ASSIGNING FIELD-SYMBOL(<LS_LIST>).

    READ TABLE LT_MATDOC ASSIGNING FIELD-SYMBOL(<LS_MATDOC>) WITH KEY RSNUM = <LS_LIST>-RSNUM
                                                                                                              RSPOS = <LS_LIST>-RSPOS BINARY SEARCH.
    IF SY-SUBRC EQ 0.
      "미완료를 선택 한 경우 전표가 이미 생성 되어 있으면 제외
      IF P_TAR EQ ABAP_TRUE.
        DELETE GT_LIST.
        CONTINUE.
      ENDIF.

      "전표 설정
      <LS_LIST>-BUDAT = <LS_MATDOC>-BUDAT.
      <LS_LIST>-MJAHR = <LS_MATDOC>-MJAHR.
      <LS_LIST>-MBLNR = <LS_MATDOC>-MBLNR.
      <LS_LIST>-ERFMG = <LS_MATDOC>-ERFMG.

      "상태
      <LS_LIST>-STATUS = ICON_LED_GREEN.

    ELSE.
      "완료를 선택 한 경우 전표가 없으면 제외
      IF P_COM EQ ABAP_TRUE.
        DELETE GT_LIST.
        CONTINUE.
      ENDIF.

      "상태
      <LS_LIST>-STATUS = ICON_LED_YELLOW.
    ENDIF.
  ENDLOOP.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_GET_MARD_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_GET_MARD_DATA .

  "예약 오더 데이터가 있으면 진행
  CHECK GT_LIST[] IS NOT INITIAL.
*ZGTMM_CV_GET_STOCKLIST-LABST

  SELECT
    V1~MATNR,
    V1~WERKS,
    V1~LGORT,
    SUM( V1~LABST ) AS LABST
    FROM ZGTMM_CV_GET_STOCKLIST AS V1
    WHERE EXISTS (
      SELECT ZZ~MATNR, ZZ~WERKS, ZZ~LGORT
        FROM @GT_LIST AS ZZ
        WHERE ZZ~MATNR EQ V1~MATNR
            AND ZZ~WERKS EQ V1~WERKS
            AND ZZ~LGORT EQ V1~LGORT
    )
    GROUP BY V1~MATNR, V1~WERKS, V1~LGORT
    ORDER BY V1~MATNR, V1~WERKS, V1~LGORT
    INTO TABLE @DATA(LT_LABST).

  CHECK LT_LABST[] IS NOT INITIAL.

  LOOP AT GT_LIST ASSIGNING FIELD-SYMBOL(<LS_LIST>).
    READ TABLE LT_LABST ASSIGNING FIELD-SYMBOL(<LS_LABST>) WITH KEY MATNR = <LS_LIST>-MATNR
                                                                                                      WERKS = <LS_LIST>-WERKS
                                                                                                      LGORT = <LS_LIST>-LGORT
                                                                                                      BINARY SEARCH.
    CHECK SY-SUBRC EQ 0.
    <LS_LIST>-SLQTY = <LS_LABST>-LABST.

  ENDLOOP.

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
    WHEN P_RES.
      CHECK GT_LIST[] IS NOT INITIAL.

      LOOP AT GT_LIST ASSIGNING FIELD-SYMBOL(<LS_LIST>).
        "초기화
        CLEAR <LS_LIST>-ZSTYLE[].

        IF <LS_LIST>-STATUS EQ ICON_LED_GREEN.
          "이전전기된 경우 처리수량 변경 불가
          <LS_LIST>-ZSTYLE = VALUE #( ( FIELDNAME = 'ERFMG'  STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED ) ).
        ELSE.
          IF <LS_LIST>-XCHPF EQ ABAP_TRUE.
            "배치관리 자재인 경우 처리수량 변경 불가
            <LS_LIST>-ZSTYLE = VALUE #( ( FIELDNAME = 'ERFMG'  STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED ) ).
          ENDIF.
        ENDIF.

      ENDLOOP.

    WHEN P_MAN.

      CHECK GT_MAN[] IS NOT INITIAL.

      LOOP AT GT_MAN ASSIGNING FIELD-SYMBOL(<LS_MAN>).
        "초기화
        CLEAR <LS_MAN>-ZSTYLE[].

        IF <LS_MAN>-MBLNR NE SPACE.
          "자재문서 있는 경우 저장위치,수량 변경 불가
          <LS_MAN>-ZSTYLE = VALUE #(
                      ( FIELDNAME = 'ERFMG'  STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED )
                      ( FIELDNAME = 'UMLGO'  STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED )
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

  CASE ABAP_TRUE.
    WHEN P_RES.
      "데이터가 없으면 메세지 처리
      IF GT_LIST[] IS INITIAL.
        MESSAGE S002 DISPLAY LIKE GC_E.
        LEAVE LIST-PROCESSING.
      ENDIF.

      "Screen 100 이동
      CALL SCREEN 100.

    WHEN P_MAN.

      IF GT_MAN[] IS INITIAL.
        MESSAGE S002 DISPLAY LIKE GC_E.
        LEAVE LIST-PROCESSING.
      ENDIF.

      CALL SCREEN 400.

  ENDCASE.

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
*& Form F_XCHPF_POP
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_XCHPF_POP .

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

*  2. 재고 조회 버튼
*2-1) 예약오더번호, 품목 단위로 라인은 단일선택만 가능
*2-2) 선택한 라인이 없는 경우 하단 에러 메시지 "선택한 데이터가 없습니다."
*2-3) 선택한 라인의 배치관리 지시자가 "" 이면 하단 오류 메시지 "배치 미관리 자재는 처리 수량을 직접 입력하세요."
*2-4) 선택한 라인의 상태가 GREEN 이면 하단 오류 메시지 "조회 대상이 아닙니다. 처리 상태를 확인하세요."
*2-5) 선택한 라인이 존재하고 배치지시자(XCHPF) = "X" 이면 재고 조회 용 POP-UP을 Display

*2-2) 선택한 라인이 없는 경우 하단 에러 메시지 "선택한 데이터가 없습니다."
  DATA LT_ROW TYPE LVC_T_ROID.
  CALL METHOD GO_GRID_100->GET_SELECTED_ROWS
    IMPORTING
      ET_ROW_NO = LT_ROW.
  DELETE LT_ROW WHERE ROW_ID LE 0.
  IF LT_ROW[] IS INITIAL.
    MESSAGE E050.
  ENDIF.

*2-1) 예약오더번호, 품목 단위로 라인은 단일선택만 가능
  IF LINES( LT_ROW ) GT 1.
    MESSAGE E000 WITH TEXT-E01. "하나의 라인만 선택해야 합니다.
  ENDIF.

  READ TABLE LT_ROW ASSIGNING FIELD-SYMBOL(<LS_ROW>) INDEX 1.
  CHECK SY-SUBRC EQ 0.
  READ TABLE GT_LIST ASSIGNING FIELD-SYMBOL(<LS_LIST>) INDEX <LS_ROW>-ROW_ID.
  CHECK SY-SUBRC EQ 0.
*2-3) 선택한 라인의 배치관리 지시자가 "" 이면 하단 오류 메시지 "배치 미관리 자재는 처리 수량을 직접 입력하세요."
  IF <LS_LIST>-XCHPF NE ABAP_TRUE.
    MESSAGE E000 WITH TEXT-E02. "배치 미관리 자재는 처리 수량을 직접 입력하세요."
  ENDIF.

*2-4) 선택한 라인의 상태가 GREEN 이면 하단 오류 메시지 "조회 대상이 아닙니다. 처리 상태를 확인하세요."
  IF <LS_LIST>-STATUS EQ ICON_LED_GREEN.
    MESSAGE E000 WITH TEXT-E03. "조회 대상이 아닙니다. 처리 상태를 확인하세요.
  ENDIF.

*2-5) 선택한 라인이 존재하고 배치지시자(XCHPF) = "X" 이면 재고 조회 용 POP-UP을 Display
  GS_SCR-WERKS = <LS_LIST>-WERKS.
  GS_SCR-LGORT = <LS_LIST>-LGORT.
  GS_SCR-MATNR = <LS_LIST>-MATNR.
  GS_SCR-MAKTX = <LS_LIST>-MAKTX.
  GS_SCR-CHARG = <LS_LIST>-CHARG.

  SELECT SINGLE
    NAME1
    FROM T001W
    WHERE WERKS EQ @GS_SCR-WERKS
    INTO @GS_SCR-NAME1.

  SELECT SINGLE
    LGOBE
    FROM T001L
    WHERE WERKS EQ @GS_SCR-WERKS
    AND LGORT EQ @GS_SCR-LGORT
    INTO @GS_SCR-LGOBE.

  "하단
  DATA LR_CHARG TYPE RANGE OF CHARG_D.
  IF <LS_LIST>-CHARG IS NOT INITIAL.
    LR_CHARG = VALUE #( ( SIGN = 'I' OPTION = 'EQ' LOW = <LS_LIST>-CHARG ) ).
  ENDIF.
  SELECT
    V1~CHARG,
    V1~TAGNR,
    V1~UNQTY,
    V1~MEINS
    FROM ZGTMM_CV_STOCKLIST AS V1
    WHERE V1~MATNR EQ @GS_SCR-MATNR
    AND V1~WERKS EQ @GS_SCR-WERKS
    AND V1~LGORT EQ @GS_SCR-LGORT
    AND V1~CHARG IN @LR_CHARG
    AND V1~UNQTY IS NOT INITIAL
    ORDER BY V1~CHARG, V1~TAGNR
    INTO CORRESPONDING FIELDS OF TABLE @GT_POP.

  "화면호출
  CLEAR GT_BAT[].
  CALL SCREEN 200 STARTING AT 1 4.

  CHECK GT_BAT[] IS NOT INITIAL.

*2-8) 처리 대상 입력 후 체크 버튼 선택시 선행 화면의 처리 수량(ERFMG) 에 반영하고 별도 Internal Table 배치별재고 입력 현황을 내부 저장
  <LS_LIST>-ZBAT[] = GT_BAT[].
  "수량
  SELECT SUM( ZZ~ERFMG )
    FROM @GT_BAT AS ZZ
    INTO @<LS_LIST>-ERFMG.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_SET_ERFMG
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_SET_ERFMG .

  DATA LV_VALID TYPE C LENGTH 1.
  CALL METHOD GO_GRID_200->CHECK_CHANGED_DATA
    IMPORTING
      E_VALID = LV_VALID.
  CHECK LV_VALID EQ ABAP_TRUE.

*2-6) 입력한 처리 수량 > UNQTY 수량 이면 하단 오류 메시지 "처리 수량을 확인하세요."
*2-7) 예약오더에 지정된 배치번호에 해당하는 재고 수량이 없는 경우 하단 오류 메세지 "지정된 배치의 재고 수량을 확인하세요."
*2-8) 처리 대상 입력 후 체크 버튼 선택시 선행 화면의 처리 수량(ERFMG) 에 반영하고 별도 Internal Table 배치별재고 입력 현황을 내부 저장
*: BAPI 실행 시 처리해야할 BATCH 정보 수집 목적으로 별도관리

  LOOP AT GT_POP ASSIGNING FIELD-SYMBOL(<LS_POP>).
    CHECK <LS_POP>-ERFMG IS NOT INITIAL.

    IF <LS_POP>-ERFMG GT <LS_POP>-UNQTY.
      MESSAGE E000 WITH TEXT-E04. "처리 수량을 확인하세요.
    ENDIF.

    IF GS_SCR-CHARG IS NOT INITIAL AND GS_SCR-CHARG EQ <LS_POP>-CHARG
      AND <LS_POP>-UNQTY IS INITIAL.
      MESSAGE E000 WITH TEXT-E10. "지정된 배치의 재고 수량을 확인하세요.
    ENDIF.

    GT_BAT[] = VALUE #( BASE GT_BAT ( CORRESPONDING #( <LS_POP> ) ) ).
  ENDLOOP.

  IF GS_SCR-CHARG IS NOT INITIAL.
    SELECT SINGLE ZZ~CHARG
      FROM @GT_BAT AS ZZ
      WHERE ZZ~CHARG EQ @GS_SCR-CHARG
      INTO @DATA(LV_CHK).
    IF SY-SUBRC NE 0.
      CLEAR GT_BAT[].
      MESSAGE E000 WITH TEXT-E10. "지정된 배치의 재고 수량을 확인하세요.
    ENDIF.
  ENDIF.

  LEAVE TO SCREEN 0.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_POST
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_POST .

*
*3. 이전 처리 버튼 선택
*3-1) 라인은 다중선택 가능 (전체선택 포함)
*3-2) 선택한 라인이 없는 경우 하단 에러 메시지 "선택한 데이터가 없습니다."
*3-3) 선택한 라인의 상태 <>"GREEN" 인 경우 하단 에러메세지 "처리 상태를 확인하세요."
*3-4) 선택한 라인의 배치관리 지시자가 X 이고 배치별 수량이 지정되지 않은 경우 하단 오류 메시지 "배치 처리 수량을 입력 하세요."
*3-5) 선택한 라인에 처리수량이 입력되지안은 경우 하단 오류 메시지 "처리 수량을 입력하세요."
*3-6) 선택한 라인의 상태 <> "GREEN" 인 경우 하단 POP-UP 확인 후 재고 이전저치리

  DATA LV_VALID TYPE C LENGTH 1.
  CALL METHOD GO_GRID_100->CHECK_CHANGED_DATA
    IMPORTING
      E_VALID = LV_VALID.
  CHECK LV_VALID EQ ABAP_TRUE.

*3-2) 선택한 라인이 없는 경우 하단 에러 메시지 "선택한 데이터가 없습니다."
  DATA LT_ROW TYPE LVC_T_ROID.
  CALL METHOD GO_GRID_100->GET_SELECTED_ROWS
    IMPORTING
      ET_ROW_NO = LT_ROW.
  DELETE LT_ROW WHERE ROW_ID LE 0.
  IF LT_ROW[] IS INITIAL.
    MESSAGE E050.
  ENDIF.

  DATA:
    LT_RUN LIKE STANDARD TABLE OF GS_RUN,
    LS_RUN LIKE LINE OF GT_RUN.

  LOOP AT LT_ROW ASSIGNING FIELD-SYMBOL(<LS_ROW>).
    READ TABLE GT_LIST ASSIGNING FIELD-SYMBOL(<LS_LIST>) INDEX <LS_ROW>-ROW_ID.
    CHECK SY-SUBRC EQ 0.
*3-3) 선택한 라인의 상태 <>"GREEN" 인 경우 하단 에러메세지 "처리 상태를 확인하세요."
    IF <LS_LIST>-STATUS EQ ICON_LED_GREEN.
      MESSAGE E000 WITH TEXT-E05.
    ENDIF.

*3-4) 선택한 라인의 배치관리 지시자가 X 이고 배치별 수량이 지정되지 않은 경우 하단 오류 메시지 "배치 처리 수량을 입력 하세요."
    IF <LS_LIST>-XCHPF EQ ABAP_TRUE AND <LS_LIST>-ZBAT[] IS INITIAL.
      MESSAGE E000 WITH TEXT-E06.
    ENDIF.

*3-5) 선택한 라인에 처리수량이 입력되지안은 경우 하단 오류 메시지 "처리 수량을 입력하세요."
    IF <LS_LIST>-ERFMG IS INITIAL.
      MESSAGE E000 WITH TEXT-E07.
    ENDIF.

    "실행 대상
    LS_RUN = CORRESPONDING #( <LS_LIST> ).
    LS_RUN-TABIX = <LS_ROW>-ROW_ID.
    APPEND LS_RUN TO LT_RUN.
  ENDLOOP.

  CHECK LT_RUN[] IS NOT INITIAL.

*  3-6) 선택한 라인의 상태 <> "GREEN" 인 경우 하단 POP-UP 확인 후 재고 이전저치리
  CLEAR GS_SCR.
  GS_SCR-BUDAT = SY-DATLO.
  GS_SCR-ZTEXT = TEXT-M01. "이전전기 처리 하시겠습니까?
  CALL SCREEN 300 STARTING AT 1 4.

  CHECK GS_SCR-ZOK EQ ABAP_TRUE. "Yes를 누른경우 진행

*  	: 동일한 예약오더번호 문서 단위로 자재문서 생성

  "bapi 사용
  DATA:
    "LV_LINE_ID TYPE MB_LINE_ID,
    LS_HEADER TYPE BAPI2017_GM_HEAD_01,
    LS_CODE   TYPE BAPI2017_GM_CODE,
    LT_ITEM   TYPE STANDARD TABLE OF BAPI2017_GM_ITEM_CREATE,
    LT_RETURN TYPE STANDARD TABLE OF BAPIRET2,
    LS_HDRET  TYPE BAPI2017_GM_HEAD_RET.

  LOOP AT LT_RUN ASSIGNING FIELD-SYMBOL(<LS_G1>) GROUP BY ( RSNUM = <LS_G1>-RSNUM )
                                                                             ASSIGNING FIELD-SYMBOL(<LS_GROUP1>).

    "초기화
    CLEAR:
      LS_CODE,
      LS_HEADER,
      LT_ITEM[],
      LT_RETURN[],
      LS_HDRET.

    "CODE 설정
    LS_CODE-GM_CODE = GC_04.

    "헤더
    LS_HEADER-PSTNG_DATE = GS_SCR-BUDAT.
    LS_HEADER-DOC_DATE = GS_SCR-BUDAT.

    "아이템
    LOOP AT GROUP <LS_GROUP1> ASSIGNING FIELD-SYMBOL(<LS_RUN>).
      IF <LS_RUN>-XCHPF EQ SPACE.
        LT_ITEM = VALUE #( BASE LT_ITEM ( MOVE_TYPE = GC_311
                                                MATERIAL = <LS_RUN>-MATNR
                                                PLANT = <LS_RUN>-WERKS
                                                STGE_LOC = <LS_RUN>-LGORT
                                                MOVE_STLOC = <LS_RUN>-UMLGO
                                                RESERV_NO = <LS_RUN>-RSNUM
                                                RES_ITEM = <LS_RUN>-RSPOS
                                                ENTRY_QNT = <LS_RUN>-ERFMG
                                                ENTRY_UOM = <LS_RUN>-MEINS
                                                BATCH = <LS_RUN>-CHARG
                                                MOVE_BATCH = <LS_RUN>-CHARG ) ).
      ELSE.
        LOOP AT <LS_RUN>-ZBAT ASSIGNING FIELD-SYMBOL(<LS_BAT>).
          LT_ITEM = VALUE #( BASE LT_ITEM ( MOVE_TYPE = GC_311
                                                          MATERIAL = <LS_RUN>-MATNR
                                                          PLANT = <LS_RUN>-WERKS
                                                          STGE_LOC = <LS_RUN>-LGORT
                                                          MOVE_STLOC = <LS_RUN>-UMLGO
                                                          RESERV_NO = <LS_RUN>-RSNUM
                                                          RES_ITEM = <LS_RUN>-RSPOS
                                                          ENTRY_QNT = <LS_BAT>-ERFMG
                                                          ENTRY_UOM = <LS_RUN>-MEINS
                                                          BATCH = <LS_BAT>-CHARG
                                                          MOVE_BATCH = <LS_BAT>-CHARG ) ).
        ENDLOOP.
      ENDIF.
    ENDLOOP.

    "bapi실행
    CALL FUNCTION 'BAPI_GOODSMVT_CREATE'
      EXPORTING
        GOODSMVT_HEADER  = LS_HEADER
        GOODSMVT_CODE    = LS_CODE
      IMPORTING
        GOODSMVT_HEADRET = LS_HDRET
      TABLES
        GOODSMVT_ITEM    = LT_ITEM
        RETURN           = LT_RETURN.

    READ TABLE LT_RETURN ASSIGNING FIELD-SYMBOL(<LS_REETURN>) WITH KEY TYPE = GC_E.
    IF SY-SUBRC EQ 0.
      "오류
      CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

      LOOP AT GROUP <LS_GROUP1> ASSIGNING <LS_RUN>.
        READ TABLE GT_LIST ASSIGNING <LS_LIST> INDEX <LS_RUN>-TABIX.
        CHECK SY-SUBRC EQ 0.

        <LS_LIST>-STATUS = ICON_LED_RED.
        <LS_LIST>-MESSAGE = <LS_REETURN>-MESSAGE.
      ENDLOOP.

      MESSAGE S000 DISPLAY LIKE 'E' WITH TEXT-M04.

    ELSE.
      "성공
      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
        EXPORTING
          WAIT = ABAP_TRUE.

      LOOP AT GROUP <LS_GROUP1> ASSIGNING <LS_RUN>.
        READ TABLE GT_LIST ASSIGNING <LS_LIST> INDEX <LS_RUN>-TABIX.
        CHECK SY-SUBRC EQ 0.

        <LS_LIST>-STATUS = ICON_LED_GREEN.
        <LS_LIST>-MESSAGE = SPACE.
        <LS_LIST>-MBLNR = LS_HDRET-MAT_DOC.
        <LS_LIST>-MJAHR = LS_HDRET-DOC_YEAR.
        <LS_LIST>-BUDAT = LS_HEADER-PSTNG_DATE.
        <LS_LIST>-ZSTYLE = VALUE #( ( FIELDNAME = 'ERFMG'  STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED ) ).

        CLEAR:
        <LS_LIST>-ZBAT[].

      ENDLOOP.
      MESSAGE S000 WITH TEXT-M03.
    ENDIF.
  ENDLOOP.

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
*4-3) 선택한 라인의 상태 <> "GREEN" 인 경우 하단 에러메세지 "이전처리 되지 않은 정보입니다."
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
*4-3) 선택한 라인의 상태 <> "GREEN" 인 경우 하단 에러메세지 "이전처리 되지 않은 정보입니다."
    IF <LS_LIST>-STATUS NE ICON_LED_GREEN
      OR <LS_LIST>-MBLNR IS INITIAL.
      MESSAGE E000 WITH TEXT-E08.
    ENDIF.

    "실행 대상
    CLEAR LS_RUN.
    LS_RUN-MJAHR = <LS_LIST>-MJAHR.
    LS_RUN-MBLNR = <LS_LIST>-MBLNR.
    LS_RUN-BUDAT = <LS_LIST>-BUDAT.
    LS_RUN-TABIX = <LS_ROW>-ROW_ID.
    APPEND LS_RUN TO LT_RUN.
  ENDLOOP.

*4-1) 동일한 자재문서 단위로 단일건만 선택 가능
  SELECT ZZ~MJAHR, ZZ~MBLNR
    FROM @LT_RUN AS ZZ
    GROUP BY ZZ~MJAHR, ZZ~MBLNR
    INTO TABLE @DATA(LT_CHK).

  IF LINES( LT_CHK ) GT 1.
    MESSAGE E000 WITH TEXT-E09. "동일한 자재문서 단위로 단일건만 선택 가능 합니다.
  ENDIF.

  CLEAR LS_RUN.
  READ TABLE LT_RUN INTO LS_RUN INDEX 1.

*4-4) 선택한 라인의 상태 = "GREEN" 인 경우 POP-UP 확인 후 재고 이전 취소 처리
  CLEAR GS_SCR.
  GS_SCR-BUDAT = LS_RUN-BUDAT.
  GS_SCR-ZTEXT = TEXT-M02. "이전취소 처리 하시겠습니까?
  CALL SCREEN 300 STARTING AT 1 4.

  CHECK GS_SCR-ZOK EQ ABAP_TRUE. "Yes를 누른경우 진행

  DATA:
    LS_HEAD   LIKE BAPI2017_GM_HEAD_02,
    LS_HRET   LIKE BAPI2017_GM_HEAD_RET,
    LS_RETURN TYPE BAPIRET2,
    LT_RETURN TYPE STANDARD TABLE OF BAPIRET2.

  LS_HEAD-MAT_DOC    = LS_RUN-MBLNR.
  LS_HEAD-DOC_YEAR   = LS_RUN-MJAHR.
  LS_HEAD-PSTNG_DATE = GS_SCR-BUDAT.

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
*    LOOP AT LT_RUN INTO LS_RUN.
    LOOP AT GT_LIST ASSIGNING <LS_LIST>.
      CHECK <LS_LIST>-MJAHR EQ LS_RUN-MJAHR
      AND <LS_LIST>-MBLNR EQ LS_RUN-MBLNR.
*      READ TABLE GT_LIST ASSIGNING <LS_LIST> INDEX LS_RUN-TABIX.
*      CHECK SY-SUBRC EQ 0.
      <LS_LIST>-STATUS = ICON_LED_YELLOW.
      <LS_LIST>-MESSAGE = SPACE.
      <LS_LIST>-MJAHR = SPACE.
      <LS_LIST>-MBLNR = SPACE.
      <LS_LIST>-BUDAT = SPACE.

      CHECK <LS_LIST>-XCHPF EQ SPACE.
      CLEAR:
        <LS_LIST>-ZSTYLE[],
        <LS_LIST>-ZBAT[].

    ENDLOOP.
    MESSAGE S000 WITH TEXT-M05.

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
    ENDLOOP.
    MESSAGE S000 DISPLAY LIKE 'E' WITH TEXT-M06.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*& FORM CHECK_AUTH
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
FORM CHECK_AUTH .

  AUTHORITY-CHECK OBJECT 'ZCBO_MM001'
               ID 'WERKS' FIELD P_WERKS.

  CHECK SY-SUBRC <> 0.

  SET CURSOR FIELD 'P_WERKS'.
  MESSAGE E106 WITH P_WERKS. "플랜트[&] 작업권한을 확인하세요.

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

  " 라디오 버튼 텍스트, 기본 설정 버튼 설정
  CASE ABAP_TRUE.
    WHEN P_RES.
      GV_TEXT1 = TEXT-R01.
      GV_TEXT2 = TEXT-R02.

    WHEN OTHERS.
      GV_TEXT1 = TEXT-R06.
      GV_TEXT2 = TEXT-R07.
      CLEAR: P_TAR.
  ENDCASE.

  LOOP AT SCREEN.

    CASE SCREEN-NAME.
      WHEN 'S_BUDAT-LOW' OR 'S_RSDAT-LOW' OR 'S_WERKS-LOW' OR 'P_WERKS'.
        SCREEN-REQUIRED = 2.
        MODIFY SCREEN.
    ENDCASE.

    CASE SCREEN-GROUP1.

      WHEN 'RES'. "예약오더
        IF P_RES EQ ABAP_TRUE.
          SCREEN-ACTIVE = 1.
        ELSE.
          SCREEN-ACTIVE = 0.
        ENDIF.
        MODIFY SCREEN.

      WHEN 'MAN'. "재고
        IF P_MAN EQ ABAP_TRUE.
          SCREEN-ACTIVE = 1.
        ELSE.
          SCREEN-ACTIVE = 0.
        ENDIF.
        MODIFY SCREEN.

      WHEN 'MAO'. "재고 Optional
        IF P_MAN EQ ABAP_TRUE AND P_COM EQ ABAP_TRUE.
          SCREEN-ACTIVE = 1.
        ELSE.
          SCREEN-ACTIVE = 0.
        ENDIF.
        MODIFY SCREEN.


    ENDCASE.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form F_GET_MATDOC_DATA_MAN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_GET_MATDOC_DATA_MAN .

  CLEAR:
    GT_MAN[].

  SELECT
    CV~WERKS,
    TW~NAME1,
    CV~LGORT,
    TLF~LGOBE AS LGOBE_F,
    CV~MATNR,
    MK~MAKTX,
    CV~CHARG,
    CV~LABST,
    CV~MEINS AS ERFME,
    CV~VBELN,
    CV~POSNR
    FROM ZGTMM_CV_GET_STOCKLIST AS CV
    LEFT OUTER JOIN MAKT AS MK ON CV~MATNR EQ MK~MATNR
                                                   AND MK~SPRAS EQ @SY-LANGU
    LEFT OUTER JOIN T001W AS TW ON CV~WERKS EQ TW~WERKS
                                                AND TW~SPRAS EQ @SY-LANGU
    LEFT OUTER JOIN T001L AS TLF ON CV~WERKS EQ TLF~WERKS
                                                   AND CV~LGORT EQ TLF~LGORT
    WHERE CV~WERKS EQ @P_WERKS
    AND CV~LGORT IN @S_LGORT
    AND CV~MATNR IN @S_MATNR
    AND CV~LABST GT @SPACE        "2026.06.08 재고 존재하는 건만 조회
    AND CV~CHARG IN @S_CHARG     "2026.07.22 배치 조회 조건 추가
    INTO CORRESPONDING FIELDS OF TABLE @GT_MAN.

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

  "재고인 경우에만 점검
  CHECK P_MAN EQ ABAP_TRUE.

  "필수 값 점검
  IF S_BUDAT IS INITIAL.
    MESSAGE E278(00) WITH TEXT-F01.
    LEAVE LIST-PROCESSING.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form F_AT_SCREEN_ON_RSDAT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_AT_SCREEN_ON_RSDAT .

  CHECK SY-UCOMM EQ 'ONLI'. "실행 인 경우 만 점검

  "예약오더인 경우에만 점검
  CHECK P_RES EQ ABAP_TRUE.

  "필수 값 점검
  IF S_RSDAT IS INITIAL.
    MESSAGE E278(00) WITH TEXT-F02.
    LEAVE LIST-PROCESSING.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form F_GET_MATDOC_DATA_MAN_DISP
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_GET_MATDOC_DATA_MAN_DISP .
  CLEAR:
    GT_MAN[].

  SELECT
    MD~MBLNR,
    MD~MJAHR,
    MD~ZEILE,
    MD~BUDAT,
    MD~BWART,
    TT~BTEXT,
    MD~WERKS,
    TW~NAME1,
    MD~LGORT,
    TLF~LGOBE AS LGOBE_F,
    TLT~LGOBE AS LGOBE_T,
    MD~MATNR,
    MK~MAKTX,
    MD~ERFMG,
    MD~ERFME,
    MD~USNAM,
    MD~UMLGO,
    MD~UMCHA,
    MD~SMBLN,
    MD~SJAHR,
    MD~KDAUF AS VBELN,
    MD~KDPOS AS POSNR
*    AD~NAME_TEXT
    FROM MATDOC AS MD
    JOIN MARA AS M ON MD~MATNR EQ M~MATNR
*    JOIN USR21 AS UR ON MD~USNAM EQ UR~BNAME
*    LEFT OUTER JOIN ADRP AS AD ON UR~PERSNUMBER EQ AD~PERSNUMBER
    LEFT OUTER JOIN MAKT AS MK ON MD~MATNR EQ MK~MATNR
                                                   AND MK~SPRAS EQ @SY-LANGU
    LEFT OUTER JOIN T156T AS TT ON MD~BWART EQ TT~BWART
                                                   AND MD~SOBKZ EQ TT~SOBKZ
                                                   AND MD~KZBEW EQ TT~KZBEW
                                                   AND MD~KZZUG EQ TT~KZZUG
                                                   AND MD~KZVBR EQ TT~KZVBR
                                                   AND TT~SPRAS EQ @SY-LANGU
    LEFT OUTER JOIN T001W AS TW ON MD~WERKS EQ TW~WERKS
                                                AND TW~SPRAS EQ @SY-LANGU
    LEFT OUTER JOIN T001L AS TLF ON MD~WERKS EQ TLF~WERKS
                                                   AND MD~LGORT EQ TLF~LGORT
    LEFT OUTER JOIN T001L AS TLT ON MD~WERKS EQ TLT~WERKS
                                                   AND MD~UMLGO EQ TLT~LGORT
    WHERE MD~WERKS EQ @P_WERKS
    AND MD~LGORT IN @S_LGORT
    AND MD~MATNR IN @S_MATNR
    AND MD~BUDAT IN @S_BUDAT

    AND MD~MBLNR NE @SPACE
    AND MD~CANCELLED EQ @SPACE
    AND MD~XAUTO EQ @SPACE
    AND MD~BWART EQ @GC_311
*    AND MD~SOBKZ EQ @SPACE
    AND MD~CHARG IN @S_CHARG     "2026.07.22 배치 조회 조건 추가
    INTO CORRESPONDING FIELDS OF TABLE @GT_MAN.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form F_POST_MANUAL
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_POST_MANUAL .
*
*3. 이전 처리 버튼 선택
*3-1) 라인은 다중선택 가능 (전체선택 포함)
*3-2) 선택한 라인이 없는 경우 하단 에러 메시지 "선택한 데이터가 없습니다."
*3-3) 선택한 라인에 자재문서 존재하는 경우 "이미 이전된 자재를 포함합니다.
*3-4) 선택한 라인에 처리수량이 입력되지안은 경우 하단 오류 메시지 "처리 수량을 입력하세요."
*3-5) 선택한 라인에 입고 저장위치가 입력되지안은 경우 하단 오류 메시지 "입고 저장위치를 입력하세요."
*3-6) POP-UP 확인 후 재고 이전 처리

  DATA:
    LV_VALID      TYPE C LENGTH 1,
    LV_LINE_DATA  TYPE STRING,
    LV_MATNR      TYPE MATNR,
    LV_CHARG      TYPE STRING,

    "판매오더 STOCK 분기
    LV_SPEC_STOCK TYPE BAPI2017_GM_ITEM_CREATE-SPEC_STOCK,
    LV_VBELN      TYPE BAPI2017_GM_ITEM_CREATE-VAL_SALES_ORD,
    LV_POSNR      TYPE BAPI2017_GM_ITEM_CREATE-VAL_S_ORD_ITEM.

  CALL METHOD GO_GRID_400->CHECK_CHANGED_DATA
    IMPORTING
      E_VALID = LV_VALID.
  CHECK LV_VALID EQ ABAP_TRUE.

*3-2) 선택한 라인이 없는 경우 하단 에러 메시지 "선택한 데이터가 없습니다."
  DATA LT_ROW TYPE LVC_T_ROID.
  CALL METHOD GO_GRID_400->GET_SELECTED_ROWS
    IMPORTING
      ET_ROW_NO = LT_ROW.
  DELETE LT_ROW WHERE ROW_ID LE 0.
  IF LT_ROW[] IS INITIAL.
    MESSAGE E050.
  ENDIF.

  DATA:
    LT_RUN LIKE STANDARD TABLE OF GS_RUN_M,
    LS_RUN LIKE LINE OF GT_RUN_M.

  LOOP AT LT_ROW ASSIGNING FIELD-SYMBOL(<LS_ROW>).
    CLEAR: LV_LINE_DATA, LV_MATNR, LV_CHARG.

    READ TABLE GT_MAN ASSIGNING FIELD-SYMBOL(<LS_MAN>) INDEX <LS_ROW>-ROW_ID.
    CHECK SY-SUBRC EQ 0.

    " MESSAGE 출력 용 LINE 정보(자재번호, 저장위치, 배치번호 값
    LV_MATNR = |{ <LS_MAN>-MATNR ALPHA = OUT }|.
    IF <LS_MAN>-CHARG IS NOT INITIAL.
      LV_CHARG = |/ { <LS_MAN>-CHARG }|.
    ENDIF.
    LV_LINE_DATA = |( { LV_MATNR } / { <LS_MAN>-LGORT } { LV_CHARG })|.

*3-3) 선택한 라인에 자재문서 존재하는 경우 "이미 이전된 자재입니다.
    IF <LS_MAN>-MBLNR IS NOT INITIAL.
      MESSAGE E000 WITH TEXT-E12 && LV_LINE_DATA.
    ENDIF.

*3-4) 선택한 라인에 처리수량이 입력되지안은 경우 하단 오류 메시지 "처리 수량을 입력하세요."
    IF <LS_MAN>-ERFMG IS INITIAL.
      MESSAGE E000 WITH TEXT-E07 && LV_LINE_DATA.
    ENDIF.

*3-5) 선택한 라인에 입고 저장위치가 입력되지안은 경우 하단 오류 메시지 "입고 저장위치를 입력하세요."
    IF <LS_MAN>-UMLGO IS INITIAL.
      MESSAGE E000 WITH TEXT-E11 && LV_LINE_DATA.
    ENDIF.

    "실행 대상
    LS_RUN = CORRESPONDING #( <LS_MAN> ).
    LS_RUN-TABIX = <LS_ROW>-ROW_ID.
    APPEND LS_RUN TO LT_RUN.
  ENDLOOP.

  CHECK LT_RUN[] IS NOT INITIAL.

*  3-6) POP-UP 확인 후 재고 이전처리
  CLEAR GS_SCR.
  GS_SCR-BUDAT = SY-DATLO.
  GS_SCR-ZTEXT = TEXT-M01. "이전전기 처리 하시겠습니까?
  CALL SCREEN 300 STARTING AT 1 4.

  CHECK GS_SCR-ZOK EQ ABAP_TRUE. "Yes를 누른경우 진행

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
    LS_HDRET.

  LOOP AT LT_RUN ASSIGNING FIELD-SYMBOL(<LS_RUN>) .
    CLEAR: LV_SPEC_STOCK, LV_VBELN, LV_POSNR.

    "CODE 설정
    LS_CODE-GM_CODE = GC_04.

    "헤더
    LS_HEADER-PSTNG_DATE = GS_SCR-BUDAT.
    LS_HEADER-DOC_DATE = GS_SCR-BUDAT.

    "판매오더재고 유무에 따른 값 할당
    IF <LS_RUN>-VBELN IS NOT INITIAL. "판매오더 재고
      LV_SPEC_STOCK = GC_E.
      LV_VBELN = <LS_RUN>-VBELN.
      LV_POSNR = <LS_RUN>-POSNR.
    ENDIF.

*    "아이템
*    LT_ITEM = VALUE #( BASE LT_ITEM ( MOVE_TYPE = GC_311
*                                            MATERIAL = <LS_RUN>-MATNR
*                                            PLANT = <LS_RUN>-WERKS
*                                            STGE_LOC = <LS_RUN>-LGORT
*                                            MOVE_STLOC = <LS_RUN>-UMLGO
*                                            ENTRY_QNT = <LS_RUN>-ERFMG
*                                            ENTRY_UOM = <LS_RUN>-ERFME
*                                            BATCH = <LS_RUN>-CHARG
*                                            MOVE_BATCH = <LS_RUN>-CHARG
*                                            SPEC_STOCK = LV_SPEC_STOCK
*                                            VAL_SALES_ORD = LV_VBELN
*                                            VAL_S_ORD_ITEM = LV_POSNR ) ).

    "아이템
    "Factor Batch 여부 확인: MARC-DPCBT = 'A' 명시적 판별
    SELECT SINGLE DPCBT
      FROM MARC
      WHERE MATNR EQ @<LS_RUN>-MATNR
        AND WERKS EQ @<LS_RUN>-WERKS
      INTO @DATA(LV_DPCBT).

    IF LV_DPCBT EQ 'A'.
**-- > 26.09 펙터 배치인 경우 판매오더 존재시 판매오더 수량이상으로만 처리 안되게끔 변경처리
      IF <LS_RUN>-VBELN IS NOT INITIAL  .
        SELECT SINGLE FROM VBAP FIELDS KWMENG
          WHERE VBELN EQ @<LS_RUN>-VBELN
            AND POSNR EQ @<LS_RUN>-POSNR
          INTO @DATA(LV_KWMENG).
        "판매오더 품목수량 => 이전전기수량 비교
        IF LV_KWMENG => <LS_RUN>-ERFMG.
          LT_ITEM = VALUE #( BASE LT_ITEM ( MOVE_TYPE = GC_311
                                            MATERIAL = <LS_RUN>-MATNR
                                            PLANT = <LS_RUN>-WERKS
                                            STGE_LOC = <LS_RUN>-LGORT
                                            MOVE_STLOC = <LS_RUN>-UMLGO
                                            ENTRY_QNT = <LS_RUN>-ERFMG
                                            ENTRY_UOM = <LS_RUN>-ERFME
                                            BATCH = <LS_RUN>-CHARG
                                            MOVE_BATCH = <LS_RUN>-CHARG
                                            SPEC_STOCK = LV_SPEC_STOCK
                                            VAL_SALES_ORD = LV_VBELN
                                            VAL_S_ORD_ITEM = LV_POSNR ) ).
        ELSE.
          READ TABLE GT_MAN ASSIGNING <LS_MAN> INDEX <LS_RUN>-TABIX.
          CHECK SY-SUBRC EQ 0.

          <LS_MAN>-STATUS = ICON_LED_RED.
          <LS_MAN>-MESSAGE = TEXT-M12.
          MESSAGE S000 DISPLAY LIKE 'E' WITH TEXT-M12.
          "판매오더 수량을 초과하여 처리할 수 없습니다.
          EXIT.
        ENDIF.
      ELSE.
        LT_ITEM = VALUE #( BASE LT_ITEM ( MOVE_TYPE = GC_311
                                          MATERIAL = <LS_RUN>-MATNR
                                          PLANT = <LS_RUN>-WERKS
                                          STGE_LOC = <LS_RUN>-LGORT
                                          MOVE_STLOC = <LS_RUN>-UMLGO
                                          ENTRY_QNT = <LS_RUN>-ERFMG
                                          ENTRY_UOM = <LS_RUN>-ERFME
                                          BATCH = <LS_RUN>-CHARG
                                          MOVE_BATCH = <LS_RUN>-CHARG
                                          SPEC_STOCK = LV_SPEC_STOCK
                                          VAL_SALES_ORD = LV_VBELN
                                          VAL_S_ORD_ITEM = LV_POSNR ) ).
      ENDIF.


**      "Factor Batch (DPCBT='A'): TAGNR별 개별 처리 (예: 300M × 500다발)
**      SELECT V1~CHARG, V1~TAGNR, V1~UNQTY AS ERFMG, V1~MEINS
**        FROM ZGTMM_CV_STOCKLIST AS V1
**        WHERE V1~MATNR EQ @<LS_RUN>-MATNR
**          AND V1~WERKS EQ @<LS_RUN>-WERKS
**          AND V1~LGORT EQ @<LS_RUN>-LGORT
**          AND V1~CHARG EQ @<LS_RUN>-CHARG
**          AND V1~UNQTY IS NOT INITIAL
**        ORDER BY V1~CHARG, V1~TAGNR
**        INTO TABLE @DATA(LT_BAT_ITEMS).
**
**      LOOP AT LT_BAT_ITEMS ASSIGNING FIELD-SYMBOL(<LS_BAT>).
**        LT_ITEM = VALUE #( BASE LT_ITEM ( MOVE_TYPE = GC_311
**                                                MATERIAL = <LS_RUN>-MATNR
**                                                PLANT = <LS_RUN>-WERKS
**                                                STGE_LOC = <LS_RUN>-LGORT
**                                                MOVE_STLOC = <LS_RUN>-UMLGO
**                                                ENTRY_QNT = <LS_BAT>-ERFMG
**                                                ENTRY_UOM = <LS_RUN>-ERFME
**                                                BATCH = <LS_BAT>-CHARG
**                                                MOVE_BATCH = <LS_BAT>-CHARG
**                                                SPEC_STOCK = LV_SPEC_STOCK
**                                                VAL_SALES_ORD = LV_VBELN
**                                                VAL_S_ORD_ITEM = LV_POSNR ) ).
**      ENDLOOP.



    ELSE.
      "일반 배치 (DPCBT<>'A'): 기존 로직 유지
      LT_ITEM = VALUE #( BASE LT_ITEM ( MOVE_TYPE = GC_311
                                              MATERIAL = <LS_RUN>-MATNR
                                              PLANT = <LS_RUN>-WERKS
                                              STGE_LOC = <LS_RUN>-LGORT
                                              MOVE_STLOC = <LS_RUN>-UMLGO
                                              ENTRY_QNT = <LS_RUN>-ERFMG
                                              ENTRY_UOM = <LS_RUN>-ERFME
                                              BATCH = <LS_RUN>-CHARG
                                              MOVE_BATCH = <LS_RUN>-CHARG
                                              SPEC_STOCK = LV_SPEC_STOCK
                                              VAL_SALES_ORD = LV_VBELN
                                              VAL_S_ORD_ITEM = LV_POSNR ) ).
    ENDIF.

  ENDLOOP.

  "bapi실행
  CALL FUNCTION 'BAPI_GOODSMVT_CREATE'
    EXPORTING
      GOODSMVT_HEADER  = LS_HEADER
      GOODSMVT_CODE    = LS_CODE
    IMPORTING
      GOODSMVT_HEADRET = LS_HDRET
    TABLES
      GOODSMVT_ITEM    = LT_ITEM
      RETURN           = LT_RETURN.

  READ TABLE LT_RETURN ASSIGNING FIELD-SYMBOL(<LS_REETURN>) WITH KEY TYPE = GC_E.

  IF SY-SUBRC EQ 0.
    "오류
    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

    LOOP AT LT_RUN ASSIGNING <LS_RUN>.
      READ TABLE GT_MAN ASSIGNING <LS_MAN> INDEX <LS_RUN>-TABIX.
      CHECK SY-SUBRC EQ 0.

      <LS_MAN>-STATUS = ICON_LED_RED.
      <LS_MAN>-MESSAGE = <LS_REETURN>-MESSAGE.
    ENDLOOP.
    MESSAGE S000 DISPLAY LIKE 'E' WITH TEXT-M04.
  ELSE.
    "성공
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        WAIT = ABAP_TRUE.

    LOOP AT LT_RUN ASSIGNING <LS_RUN>.
      CHECK SY-SUBRC EQ 0.

      READ TABLE GT_MAN ASSIGNING <LS_MAN> INDEX <LS_RUN>-TABIX.
      CHECK SY-SUBRC EQ 0.

      <LS_MAN>-STATUS = ICON_LED_GREEN.
      <LS_MAN>-MESSAGE = SPACE.
      <LS_MAN>-MBLNR = LS_HDRET-MAT_DOC.
      <LS_MAN>-MJAHR = LS_HDRET-DOC_YEAR.
      <LS_MAN>-BUDAT = LS_HEADER-PSTNG_DATE.
      "
      <LS_MAN>-SMBLN = SPACE.
      <LS_MAN>-SJAHR = SPACE.

      "자재문서 있는 경우 저장위치,수량 변경 불가
      <LS_MAN>-ZSTYLE = VALUE #(
                  ( FIELDNAME = 'ERFMG'  STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED )
                  ( FIELDNAME = 'UMLGO'  STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED )
                ).

    ENDLOOP.
    MESSAGE S000 WITH TEXT-M03.
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
*& Form F_REVERSE_MANUAL
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_REVERSE_MANUAL .
*4. 이전 취소 버튼 선택
*4-1) 동일한 자재문서 단위로 단일건만 선택 가능
*4-2) 선택한 라인이 없는 경우 하단 에러 메시지 "선택한 데이터가 없습니다."
*4-3) 선택한 라인에 자재문서 없는 경우 하단 에러메세지 "이전처리 되지 않은 정보입니다."
*4-4) 그 외, POP-UP 확인 후 재고 이전 취소 처리

  DATA LV_VALID TYPE C LENGTH 1.
  CALL METHOD GO_GRID_400->CHECK_CHANGED_DATA
    IMPORTING
      E_VALID = LV_VALID.
  CHECK LV_VALID EQ ABAP_TRUE.

*4-2) 선택한 라인이 없는 경우 하단 에러 메시지 "선택한 데이터가 없습니다."
  DATA LT_ROW TYPE LVC_T_ROID.
  CALL METHOD GO_GRID_400->GET_SELECTED_ROWS
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
    READ TABLE GT_MAN ASSIGNING FIELD-SYMBOL(<LS_MAN>) INDEX <LS_ROW>-ROW_ID.
    CHECK SY-SUBRC EQ 0.

*4-3) 선택한 라인에 자재문서 없는 경우 하단 에러메세지 "이전처리 되지 않은 정보입니다."
    IF <LS_MAN>-MBLNR IS INITIAL.
      MESSAGE E000 WITH TEXT-E08.
    ENDIF.

    "실행 대상
    CLEAR LS_RUN.
    LS_RUN-MJAHR = <LS_MAN>-MJAHR.
    LS_RUN-MBLNR = <LS_MAN>-MBLNR.
    LS_RUN-BUDAT = <LS_MAN>-BUDAT.
    LS_RUN-TABIX = <LS_ROW>-ROW_ID.
    APPEND LS_RUN TO LT_RUN.
  ENDLOOP.

*4-1) 동일한 자재문서 단위로 단일건만 선택 가능
  SELECT ZZ~MJAHR, ZZ~MBLNR
    FROM @LT_RUN AS ZZ
    GROUP BY ZZ~MJAHR, ZZ~MBLNR
    INTO TABLE @DATA(LT_CHK).

  IF LINES( LT_CHK ) GT 1.
    MESSAGE E000 WITH TEXT-E09. "동일한 자재문서 단위로 단일건만 선택 가능 합니다.
  ENDIF.

*4-5) 통문증 있는경우 취소 로직
  SELECT SINGLE @ABAP_TRUE
    FROM @LT_RUN AS ZZ
        JOIN ZGTMMT4501 AS Z1 ON Z1~MBLNR EQ ZZ~MBLNR
                                            AND Z1~MJAHR EQ ZZ~MJAHR
        JOIN ZGTMMT4500 AS Z0 ON Z0~IV_NO EQ Z1~IV_NO
       WHERE Z0~IV_CANCEL_YN EQ @SPACE
        INTO @DATA(LV_CHK).

  IF LV_CHK IS NOT INITIAL.
    DATA LV_ANS TYPE C LENGTH 1.

    CALL FUNCTION 'POPUP_TO_CONFIRM'
      EXPORTING
        TITLEBAR      = TEXT-TT1 "확인
        TEXT_QUESTION = TEXT-Q01
      IMPORTING
        ANSWER        = LV_ANS.

    IF LV_ANS EQ GC_1..
      PERFORM F_IV_CANCEL .
      "취소여부 재확인
      SELECT SINGLE @ABAP_TRUE
        FROM @LT_RUN AS ZZ
            JOIN ZGTMMT4501 AS Z1 ON Z1~MBLNR EQ ZZ~MBLNR
                                                AND Z1~MJAHR EQ ZZ~MJAHR
            JOIN ZGTMMT4500 AS Z0 ON Z0~IV_NO EQ Z1~IV_NO
           WHERE Z0~IV_CANCEL_YN EQ @SPACE
            INTO @DATA(LV_CHK2).

      IF LV_CHK2 IS NOT INITIAL.
        MESSAGE E000 WITH TEXT-M07.
      ENDIF.

    ELSE.
      MESSAGE E000 WITH TEXT-M06.
    ENDIF.
  ENDIF.

*4-4) 그 외, POP-UP 확인 후 재고 이전 취소 처리
  CLEAR LS_RUN.
  READ TABLE LT_RUN INTO LS_RUN INDEX 1.

  CLEAR GS_SCR.
  GS_SCR-BUDAT = LS_RUN-BUDAT.
  GS_SCR-ZTEXT = TEXT-M02. "이전취소 처리 하시겠습니까?
  CALL SCREEN 300 STARTING AT 1 4.

  CHECK GS_SCR-ZOK EQ ABAP_TRUE. "Yes를 누른경우 진행


  " BAPI 실행
  DATA:
    LS_HEAD   LIKE BAPI2017_GM_HEAD_02,
    LS_HRET   LIKE BAPI2017_GM_HEAD_RET,
    LS_RETURN TYPE BAPIRET2,
    LT_RETURN TYPE STANDARD TABLE OF BAPIRET2.

  LS_HEAD-MAT_DOC    = LS_RUN-MBLNR.
  LS_HEAD-DOC_YEAR   = LS_RUN-MJAHR.
  LS_HEAD-PSTNG_DATE = GS_SCR-BUDAT.

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

    LOOP AT GT_MAN ASSIGNING <LS_MAN>.
      CHECK <LS_MAN>-MJAHR EQ LS_RUN-MJAHR
      AND <LS_MAN>-MBLNR EQ LS_RUN-MBLNR.

      <LS_MAN>-STATUS = ICON_LED_YELLOW.
      <LS_MAN>-MESSAGE = SPACE.
      <LS_MAN>-MJAHR = SPACE.
      <LS_MAN>-MBLNR = SPACE.
      <LS_MAN>-BUDAT = SPACE.

      CLEAR:
        <LS_MAN>-ZSTYLE[].
    ENDLOOP.
    MESSAGE S000 WITH TEXT-M05.
  ELSE.
    "오류
    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
    CLEAR LS_RETURN.
    READ TABLE LT_RETURN INTO LS_RETURN WITH KEY TYPE = GC_E.

    LOOP AT LT_RUN INTO LS_RUN.
      READ TABLE GT_MAN ASSIGNING <LS_MAN> INDEX LS_RUN-TABIX.
      CHECK SY-SUBRC EQ 0.
      <LS_MAN>-STATUS = ICON_LED_RED.
      <LS_MAN>-MESSAGE = LS_RETURN-MESSAGE.
    ENDLOOP.
    MESSAGE S000 DISPLAY LIKE 'E' WITH TEXT-M06.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form F_IV_CREATE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_IV_CREATE .
*3-1) 동일한 자재문서 단위로 단일건만 선택 가능
*3-2) 선택한 라인이 없는 경우 하단 에러 메시지 "선택한 데이터가 없습니다."
*3-3) 선택한 라인에 자재문서 없는 경우 하단 에러메세지 "이전처리 되지 않은 정보입니다."
*3-4) 선택한 라인의 자재문서로 발행된 통문증 번호가 존재하는 경우 하단 에러 메시지 "발행한 통문증 번호가 존재합니다."

  DATA:
    LV_VALID     TYPE C LENGTH 1,
    LV_LINE_DATA TYPE STRING,
    LV_MATNR     TYPE MATNR,
    LV_CHARG     TYPE STRING,
    LV_BUKRS     TYPE BUKRS.

  CALL METHOD GO_GRID_400->CHECK_CHANGED_DATA
    IMPORTING
      E_VALID = LV_VALID.
  CHECK LV_VALID EQ ABAP_TRUE.

*3-2) 선택한 라인이 없는 경우 하단 에러 메시지 "선택한 데이터가 없습니다."
  DATA LT_ROW TYPE LVC_T_ROID.
  CALL METHOD GO_GRID_400->GET_SELECTED_ROWS
    IMPORTING
      ET_ROW_NO = LT_ROW.
  DELETE LT_ROW WHERE ROW_ID LE 0.

  IF LT_ROW[] IS INITIAL.
    MESSAGE E050.
  ENDIF.

  DATA:
    LT_RUN LIKE STANDARD TABLE OF GS_RUN_M,
    LS_RUN LIKE LINE OF GT_RUN_M.

  LOOP AT LT_ROW ASSIGNING FIELD-SYMBOL(<LS_ROW>).
    READ TABLE GT_MAN ASSIGNING FIELD-SYMBOL(<LS_MAN>) INDEX <LS_ROW>-ROW_ID.
    CHECK SY-SUBRC EQ 0.

*3-3) 선택한 라인에 자재문서 없는 경우 하단 에러메세지 "이전처리 되지 않은 정보입니다."
    IF <LS_MAN>-MBLNR IS INITIAL.
      MESSAGE E000 WITH TEXT-E08.
    ENDIF.

    "실행 대상
    CLEAR LS_RUN.
    LS_RUN-MJAHR = <LS_MAN>-MJAHR.
    LS_RUN-MBLNR = <LS_MAN>-MBLNR.
    LS_RUN-BUDAT = <LS_MAN>-BUDAT.
    LS_RUN-TABIX = <LS_ROW>-ROW_ID.
    APPEND LS_RUN TO LT_RUN.
  ENDLOOP.

*3-1) 동일한 자재문서 단위로 단일건만 선택 가능
  SELECT ZZ~MJAHR, ZZ~MBLNR
    FROM @LT_RUN AS ZZ
    GROUP BY ZZ~MJAHR, ZZ~MBLNR
    INTO TABLE @DATA(LT_CHK).

  IF LINES( LT_CHK ) GT 1.
    MESSAGE E000 WITH TEXT-E09. "동일한 자재문서 단위로 단일건만 선택 가능 합니다.
  ENDIF.

*3-4) 선택한 라인의 자재문서로 발행된 통문증 번호가 존재하는 경우 하단 에러 메시지 "발행한 통문증 번호가 존재합니다."
  SELECT SINGLE @ABAP_TRUE
    FROM @LT_RUN AS ZZ
        JOIN ZGTMMT4501 AS Z1 ON Z1~MBLNR EQ ZZ~MBLNR
                                            AND Z1~MJAHR EQ ZZ~MJAHR
        JOIN ZGTMMT4500 AS Z0 ON Z0~IV_NO EQ Z1~IV_NO
       WHERE Z0~IV_CANCEL_YN EQ @SPACE
        INTO @DATA(LV_CHK).

  IF SY-SUBRC EQ 0.
    MESSAGE E000 WITH TEXT-E13.
  ENDIF.


  " 통문증 프로그램 호출
  CLEAR LS_RUN.
  READ TABLE LT_RUN INTO LS_RUN INDEX 1.

* 해당 회사코드 SELECT
  SELECT SINGLE K~BUKRS
    FROM T001W AS W
       JOIN T001K AS K
         ON K~BWKEY = W~BWKEY
       INTO LV_BUKRS
   WHERE W~WERKS = P_WERKS.

  CLEAR : GT_STAB[].

  PERFORM SET_STAB USING 'R1' 'P' 'X' ' '. "MM 일반(Default)
  PERFORM SET_STAB USING 'R2' 'P' ' ' ' '. "매각/폐기

  PERFORM SET_STAB USING 'P_BUKRS'  'P' LV_BUKRS   ' '. "회사코드

  SET PARAMETER ID 'ZIVTYPE' FIELD 'B05'. "이동유형: 저장위치 이전

  _CALC_DATE SY-DATLO '00' '06' '-' '00'. "기준 변경(SJM 25.03.10)
  PERFORM SET_STAB USING 'I_CPUDT' 'S' GV_CDATE SY-DATLO.   "자재문서 발행일
  PERFORM SET_STAB USING 'I_MBLNR' 'S' LS_RUN-MBLNR ' '. "자재문서 번호
  PERFORM SET_STAB USING 'P_WERKS'  'P' P_WERKS   ' '. "플랜트

  CHECK NOT GT_STAB[] IS INITIAL.

  "통문증 발행 Pgm.호출(ZGTMMR4500)
  SUBMIT ZGTMMR4500 WITH SELECTION-TABLE GT_STAB
                                   AND RETURN.

  " 생성 여부 확인
  SELECT SINGLE *
    FROM ZGTMMT4500 AS Z0
    JOIN ZGTMMT4501 AS Z1 ON Z0~IV_NO EQ Z1~IV_NO
WHERE Z1~MBLNR EQ @LS_RUN-MBLNR
    AND Z1~MJAHR EQ @LS_RUN-MJAHR
    AND Z0~IV_CANCEL_YN EQ @SPACE
    INTO @DATA(LS_IV).

  IF LS_IV IS NOT INITIAL.
    MESSAGE S000 WITH TEXT-M10.
  ELSE.
    MESSAGE S000 DISPLAY LIKE 'E' WITH TEXT-M11.
  ENDIF.

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

  CASE ABAP_TRUE.
    WHEN P_MAN.
      IF P_WERKS IS INITIAL.
        MESSAGE E278(00) WITH TEXT-F03.
        LEAVE LIST-PROCESSING.
      ENDIF.

*    WHEN P_RES.
*      IF S_WERKS IS INITIAL.
*        MESSAGE E278(00) WITH TEXT-F03.
*        LEAVE LIST-PROCESSING.
*      ENDIF.
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form F_IV_CANCEL
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_IV_CANCEL .
*3-1) 동일한 자재문서 단위로 단일건만 선택 가능
*3-2) 선택한 라인이 없는 경우 하단 에러 메시지 "선택한 데이터가 없습니다."
*3-3) 선택한 라인에 자재문서 없는 경우 하단 에러메세지 "이전처리 되지 않은 정보입니다."
*3-4) 선택한 라인에 발행된 통문증 없는 경우 하단 에러메세지 "취소할 통문증 번호가 없습니다."

  DATA:
    LV_VALID     TYPE C LENGTH 1,
    LV_LINE_DATA TYPE STRING,
    LV_MATNR     TYPE MATNR,
    LV_CHARG     TYPE STRING,
    LV_BUKRS     TYPE BUKRS.

  CALL METHOD GO_GRID_400->CHECK_CHANGED_DATA
    IMPORTING
      E_VALID = LV_VALID.
  CHECK LV_VALID EQ ABAP_TRUE.

*3-2) 선택한 라인이 없는 경우 하단 에러 메시지 "선택한 데이터가 없습니다."
  DATA LT_ROW TYPE LVC_T_ROID.
  CALL METHOD GO_GRID_400->GET_SELECTED_ROWS
    IMPORTING
      ET_ROW_NO = LT_ROW.
  DELETE LT_ROW WHERE ROW_ID LE 0.

  IF LT_ROW[] IS INITIAL.
    MESSAGE E050.
  ENDIF.

  DATA:
    LT_RUN LIKE STANDARD TABLE OF GS_RUN_M,
    LS_RUN LIKE LINE OF GT_RUN_M.

  LOOP AT LT_ROW ASSIGNING FIELD-SYMBOL(<LS_ROW>).
    READ TABLE GT_MAN ASSIGNING FIELD-SYMBOL(<LS_MAN>) INDEX <LS_ROW>-ROW_ID.
    CHECK SY-SUBRC EQ 0.

*3-3) 선택한 라인에 자재문서 없는 경우 하단 에러메세지 "이전처리 되지 않은 정보입니다."
    IF <LS_MAN>-MBLNR IS INITIAL.
      MESSAGE E000 WITH TEXT-E08.
    ENDIF.

    "실행 대상
    CLEAR LS_RUN.
    LS_RUN-MJAHR = <LS_MAN>-MJAHR.
    LS_RUN-MBLNR = <LS_MAN>-MBLNR.
    LS_RUN-BUDAT = <LS_MAN>-BUDAT.
    LS_RUN-TABIX = <LS_ROW>-ROW_ID.
    APPEND LS_RUN TO LT_RUN.
  ENDLOOP.

*3-1) 동일한 자재문서 단위로 단일건만 선택 가능
  SELECT ZZ~MJAHR, ZZ~MBLNR
    FROM @LT_RUN AS ZZ
    GROUP BY ZZ~MJAHR, ZZ~MBLNR
    INTO TABLE @DATA(LT_CHK).

  IF LINES( LT_CHK ) GT 1.
    MESSAGE E000 WITH TEXT-E09. "동일한 자재문서 단위로 단일건만 선택 가능 합니다.
  ENDIF.

*3-4) 선택한 라인에 발행된 통문증 없는 경우 하단 에러메세지 "취소할 통문증 번호가 없습니다."
  SELECT SINGLE ZZ~MBLNR, ZZ~MJAHR ,Z0~IV_NO, Z0~OUT_YN, Z0~IV_DATE
    FROM @LT_RUN AS ZZ
        JOIN ZGTMMT4501 AS Z1 ON Z1~MBLNR EQ ZZ~MBLNR
                                            AND Z1~MJAHR EQ ZZ~MJAHR
        JOIN ZGTMMT4500 AS Z0 ON Z0~IV_NO EQ Z1~IV_NO
       WHERE Z0~IV_CANCEL_YN EQ @SPACE
            AND Z0~OUT_YN EQ @SPACE
        INTO @DATA(LS_IV).

  IF LS_IV IS INITIAL.
    MESSAGE E000 WITH TEXT-E14.
  ENDIF.


  " 통문증 프로그램 호출
  CLEAR LS_RUN.
  READ TABLE LT_RUN INTO LS_RUN INDEX 1.

* 해당 회사코드 SELECT
  SELECT SINGLE K~BUKRS
    FROM T001W AS W
       JOIN T001K AS K
         ON K~BWKEY = W~BWKEY
       INTO LV_BUKRS
   WHERE W~WERKS = P_WERKS.

  CLEAR : GT_STAB[].

  PERFORM SET_STAB USING 'R1' 'P' 'X' ' '. "MM 일반(Default)
  PERFORM SET_STAB USING 'R2' 'P' ' ' ' '. "매각/폐기

  PERFORM SET_STAB USING 'P_BUKRS'  'P' LV_BUKRS   ' '. "회사코드

  PERFORM SET_STAB USING 'I_DATE' 'S' LS_IV-IV_DATE ' '. "통문증 발행일
  PERFORM SET_STAB USING 'I_IVNO' 'S' LS_IV-IV_NO   ' '. "통문번호

  CHECK NOT GT_STAB[] IS INITIAL.


  PERFORM SET_STAB USING 'P_WERKS'  'P' P_WERKS   ' '. "플랜트
  SET PARAMETER ID 'ZIVTYPE' FIELD 'B01'. "이동유형: 무상사급(Default)
  "통문증 발행 취소 Pgm.호출(ZLER0016)
  SUBMIT ZGTMMR4510 WITH SELECTION-TABLE GT_STAB
*              VIA SELECTION-SCREEN
                   AND RETURN.

  " 취소 여부 확인
  SELECT SINGLE *
    FROM ZGTMMT4500
    WHERE IV_NO EQ @LS_IV-IV_NO
    INTO @DATA(LS_IV2).

  IF LS_IV2-IV_CANCEL_YN EQ ABAP_TRUE.
    MESSAGE S000 WITH TEXT-M08.
  ELSE.
    MESSAGE S000 DISPLAY LIKE 'E' WITH TEXT-M09.
  ENDIF.

ENDFORM.
