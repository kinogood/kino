*&---------------------------------------------------------------------*
*& Include          ZGTMMR4340F01
*&---------------------------------------------------------------------*
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
    WHEN P_DISP. "조회
      PERFORM F_GET_LIST_DISP.
    WHEN P_CREA. "등록
      PERFORM F_GET_LIST_CREA.
  ENDCASE.


ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_GET_LIST_CREA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_GET_LIST_CREA .

*1)	 실행 조회조건 값을 기준으로 외주업체 재고 수량 조회
*
*
*	Table: MSLB
*	Select 조건 : WERKS,LIFNR,MATNR,LABST
*	WHERE 조건 :
*	WERKS = 조건 입력 값
*	LIFNR = 조건 입력값
*	CHARG = 조건 입력값
*
*	LABST 값이 0 이 아닌 데이터 추출
*
*2) 조회된 데이터를 ALV리스트로 보여준다
*	- Data Sorting : WERKS,LIFNR,MATNR,CHARG 순으로 오름차순 정렬


  "초기화
  CLEAR GT_LIST[].

  SELECT
    MS~WERKS,
    TW~NAME1 AS WERKS_TEXT,
    MS~LIFNR,
    LF~NAME1 AS LIFNR_TEXT,
    MS~MATNR AS IDNRK,
    MT~MAKTX,
    MS~CHARG,
    MS~LBLAB AS MENGE,
    MR~MEINS
    FROM MSLB AS MS
                INNER JOIN
              T001W AS TW ON MS~WERKS EQ TW~WERKS
                INNER JOIN
              T001K AS TK ON TW~BWKEY EQ TK~BWKEY
                INNER JOIN
              MARA AS MR ON MS~MATNR EQ MR~MATNR
                INNER JOIN
              LFA1 AS LF ON MS~LIFNR EQ LF~LIFNR
                LEFT OUTER JOIN
              MAKT AS MT ON MR~MATNR EQ MT~MATNR
                             AND MT~SPRAS EQ @SY-LANGU
    WHERE TK~BUKRS EQ @P_BUKRS
    AND MS~WERKS EQ @P_WERKS
    AND MS~LIFNR IN @S_LIFNR
    AND MS~CHARG IN @S_CHARG
    AND MS~LBLAB IS NOT INITIAL
    ORDER BY MS~WERKS, MS~LIFNR, MS~MATNR, MS~CHARG
    INTO CORRESPONDING FIELDS OF TABLE @GT_LIST.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_GET_LIST_DISP
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_GET_LIST_DISP .

*  1)	 실행 조회조건 값을 기준으로 임가공 투입정보 등록 이력 추출
*
*	Table : ZGTMMT9450
*
*	SELECT 조건: EBELN,EBELP,LIFNR,WERKS,IDNRK,CHARG,MENGE,MEINS,ERNAM,ERDAT
*
*	WHERE 조건:
*	WERKS = 조건 입력값
*	LIFNR = 조건 입력값
*	CHARG = 조건 입력값
*	MATNR = 조건 입력값
*	EBELN = 조건 입력값
*
*2) Text 정보 추출
*	3-1) MAKTX : MAKT-MAKTX (출고 자재)
*	3-2) NAME1 : LIFNR-NAME1 (업체명)
*	3-3) TXZ01 : EKPO-TXZ01 (구매오더 상위 자재)
*	3-4) NAME1 : T001W-NAME1 (플랜트명)
*	3-5) MEINS : MARA-MEINS
*
*
*3) 추출한 데이터를 기준으로 ALV Display
*	- Data Sorting : WERKS,LIFNR,EBELN,EBELP,IDNRK,MENGE,MEINS


  "초기화
  CLEAR GT_LIST[].

  SELECT
    Z1~WERKS,
    TW~NAME1 AS WERKS_TEXT,
    Z1~LIFNR,
    LF~NAME1 AS LIFNR_TEXT,
    Z1~IDNRK,
    MT~MAKTX,
    Z1~CHARG,
    Z1~MENGE,
    Z1~MEINS,
    Z1~EBELN,
    Z1~EBELP,
    EP~MATNR,
    EP~TXZ01,
    Z1~ERNAM,
    Z1~ERDAT
    FROM ZGTMMT9450 AS Z1
                INNER JOIN
              T001W AS TW ON Z1~WERKS EQ TW~WERKS
                INNER JOIN
              T001K AS TK ON TW~BWKEY EQ TK~BWKEY
                INNER JOIN
              MARA AS MR ON Z1~IDNRK EQ MR~MATNR
                INNER JOIN
              LFA1 AS LF ON Z1~LIFNR EQ LF~LIFNR
                INNER JOIN
              EKPO AS EP ON Z1~EBELN EQ EP~EBELN
                              AND Z1~EBELP EQ EP~EBELP
                LEFT OUTER JOIN
              MAKT AS MT ON MR~MATNR EQ MT~MATNR
                             AND MT~SPRAS EQ @SY-LANGU
    WHERE TK~BUKRS EQ @P_BUKRS
    AND Z1~WERKS EQ @P_WERKS
    AND Z1~LIFNR IN @S_LIFNR
    AND Z1~CHARG IN @S_CHARG
    AND Z1~IDNRK IN @S_MATNR
    AND Z1~EBELN IN @S_EBELN
    ORDER BY Z1~WERKS, Z1~LIFNR, Z1~EBELN, Z1~EBELP, Z1~IDNRK, Z1~MENGE, Z1~MEINS
    INTO CORRESPONDING FIELDS OF TABLE @GT_LIST.

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
  IF GT_LIST[] IS INITIAL.
    MESSAGE S002 DISPLAY LIKE GC_E.
    LEAVE LIST-PROCESSING.
  ENDIF.

  CALL SCREEN 100.

ENDFORM.

*&---------------------------------------------------------------------*
*& Module STATUS_0100 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE STATUS_0100 OUTPUT.

  CLEAR GT_ECOMM.

  CASE ABAP_TRUE.
    WHEN P_DISP.
      GT_ECOMM = VALUE #( ( 'SAVE' ) ( 'BSAVE' ) ).
    WHEN P_CREA.
      GT_ECOMM = VALUE #( ( 'DELE' ) ).
  ENDCASE.

  SET PF-STATUS '0100' EXCLUDING GT_ECOMM.
  SET TITLEBAR '0100'.

ENDMODULE.

*&---------------------------------------------------------------------*
*& Form F_SAVE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_SAVE .

*2. 저장 버튼
*	2-1) 라인은 다중선택 가능 (전체선택 포함)
*	2-2) 선택한 라인이 없는 경우 하단 에러 메시지 "선택한 데이터가 없습니다."
*	2-3) 구매오더번호, 구매오더품목 번호가 없는 데이터가 존재하면 하단 메시지 처리. "필수 입력 값이 누락되었습니다."
*	2-4) 선택한 라인이 존재하고 오류가 없는경우 POP-UP 확인 후 입력 데이터 테이블 업데이트

  DATA:
    LV_CHECK  TYPE C LENGTH 1,
    LT_ROW_ID TYPE LVC_T_ROID.

  CALL METHOD GO_GRID->CHECK_CHANGED_DATA
    IMPORTING
      E_VALID = LV_CHECK.

  CHECK LV_CHECK EQ ABAP_TRUE.

  CALL METHOD GO_GRID->GET_SELECTED_ROWS
    IMPORTING
      ET_ROW_NO = LT_ROW_ID.

*	2-2) 선택한 라인이 없는 경우 하단 에러 메시지 "선택한 데이터가 없습니다."
  DELETE LT_ROW_ID WHERE ROW_ID LE 0.
  IF LT_ROW_ID[] IS INITIAL.
    MESSAGE E163. "선택한 데이터가 없습니다.
  ENDIF.

  LOOP AT LT_ROW_ID ASSIGNING FIELD-SYMBOL(<LS_ROW_ID>).
    READ TABLE GT_LIST ASSIGNING FIELD-SYMBOL(<LS_LIST>) INDEX <LS_ROW_ID>-ROW_ID.
    CHECK SY-SUBRC EQ 0.
*	2-3) 구매오더번호, 구매오더품목 번호가 없는 데이터가 존재하면 하단 메시지 처리. "필수 입력 값이 누락되었습니다."
    IF <LS_LIST>-EBELN IS INITIAL
      OR <LS_LIST>-EBELP IS INITIAL.
      MESSAGE E008. "필수 값이 누락되었습니다.
    ENDIF.
  ENDLOOP.

*	2-4) 선택한 라인이 존재하고 오류가 없는경우 POP-UP 확인 후 입력 데이터 테이블 업데이트
  DATA LV_ANS TYPE C LENGTH 1.
  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      TITLEBAR      = TEXT-TT0
      TEXT_QUESTION = TEXT-Q01 "선택한 데이터를 저장하시겠습니까?
    IMPORTING
      ANSWER        = LV_ANS.
  CHECK LV_ANS EQ GC_1.

*2-4) 선택한 라인이 존재하고 오류가 없는경우 POP-UP 확인 후 입력 데이터 테이블 업데이트
  DATA:
    LS_ZGTMMT9450 TYPE ZGTMMT9450,
    LT_ZGTMMT9450 TYPE STANDARD TABLE OF ZGTMMT9450.
  LOOP AT LT_ROW_ID ASSIGNING <LS_ROW_ID>.
    READ TABLE GT_LIST ASSIGNING <LS_LIST> INDEX <LS_ROW_ID>-ROW_ID.
    CHECK SY-SUBRC EQ 0.

    LS_ZGTMMT9450 = CORRESPONDING #( <LS_LIST> ).
    LS_ZGTMMT9450-ERNAM = SY-UNAME.
    LS_ZGTMMT9450-ERDAT = SY-DATUM.
    LS_ZGTMMT9450-ERDAT_LOCAL = SY-DATLO.
    LS_ZGTMMT9450-ERTIM = SY-UZEIT.
    LS_ZGTMMT9450-ERTIM_LOCAL = SY-TIMLO.
    APPEND LS_ZGTMMT9450 TO LT_ZGTMMT9450.

    <LS_LIST>-ZSTYLE[] = VALUE #( ( FIELDNAME = 'EBELN'  STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED )
                                                        ( FIELDNAME = 'EBELP'  STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED ) ).

  ENDLOOP.

  MODIFY ZGTMMT9450 FROM TABLE LT_ZGTMMT9450.
  COMMIT WORK.

  MESSAGE S000 WITH TEXT-M01. "데이터 저장 완료되었습니다.


ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_DELETE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_DELETE .
*1. 삭제 버튼
*
*	1-1) 라인은 다중선택 가능 (전체선택 포함)
*	1-2) 선택한 라인이 없는 경우 하단 에러 메시지 "선택한 데이터가 없습니다."
*	1-3) 선택한 라인이 존재하고 오류가 없는경우 POP-UP 확인 후 입력 데이터 라인 테이블 삭제처리
*
*	 : Yes 선택시 선택된 라인 데이터 ZGTMMT9450 삭제
*	 : NO 선택 시 기존화면 유지
*	1-4) 삭제 처리 후 하단 메시지 처리 "데이터 삭제 완료되었습니다."

  DATA:
    LV_ROW_ID  TYPE INT4,
    LV_DEL_CNT TYPE INT4,
    LV_CHECK   TYPE C LENGTH 1,
    LT_ROW_ID  TYPE LVC_T_ROID.

  CALL METHOD GO_GRID->CHECK_CHANGED_DATA
    IMPORTING
      E_VALID = LV_CHECK.

  CHECK LV_CHECK EQ ABAP_TRUE.

  CALL METHOD GO_GRID->GET_SELECTED_ROWS
    IMPORTING
      ET_ROW_NO = LT_ROW_ID.

*	1-2) 선택한 라인이 없는 경우 하단 에러 메시지 "선택한 데이터가 없습니다."
  DELETE LT_ROW_ID WHERE ROW_ID LE 0.
  IF LT_ROW_ID[] IS INITIAL.
    MESSAGE E163. "선택한 데이터가 없습니다.
  ENDIF.

*	1-3) 선택한 라인이 존재하고 오류가 없는경우 POP-UP 확인 후 입력 데이터 라인 테이블 삭제처리
  DATA LV_ANS TYPE C LENGTH 1.
  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      TITLEBAR      = TEXT-TT0
      TEXT_QUESTION = TEXT-Q02 "선택한 데이터가 삭제됩니다. 진행 하시겠습니까?
    IMPORTING
      ANSWER        = LV_ANS.
  CHECK LV_ANS EQ GC_1.

  DATA:
    LS_ZGTMMT9450 TYPE ZGTMMT9450,
    LT_ZGTMMT9450 TYPE STANDARD TABLE OF ZGTMMT9450.

  LOOP AT LT_ROW_ID ASSIGNING FIELD-SYMBOL(<LS_ROW_ID>).
    LV_ROW_ID = <LS_ROW_ID>-ROW_ID - LV_DEL_CNT.
    READ TABLE GT_LIST ASSIGNING FIELD-SYMBOL(<LS_LIST>) INDEX LV_ROW_ID.
    CHECK SY-SUBRC EQ 0.

    LS_ZGTMMT9450 = CORRESPONDING #( <LS_LIST> ).
    APPEND LS_ZGTMMT9450 TO LT_ZGTMMT9450.

    DELETE GT_LIST INDEX LV_ROW_ID.
    LV_DEL_CNT += 1.
    CONTINUE.

  ENDLOOP.

  DELETE ZGTMMT9450 FROM TABLE LT_ZGTMMT9450.
  COMMIT WORK.
*	1-4) 삭제 처리 후 하단 메시지 처리 "데이터 삭제 완료되었습니다."
  MESSAGE S000 WITH TEXT-M02. "데이터 삭제 완료되었습니다.

ENDFORM.
