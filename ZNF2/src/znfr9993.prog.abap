*&---------------------------------------------------------------------*
*& Report ZNFR9993
*&---------------------------------------------------------------------*
*& [TOOL] Market Carry 만기이동 OLDFT 연결 Migration
*&
*&  - 배경 : ZNFR2320 Market Carry(ZNFT1041-GUBUN = '1') 만기이동 시
*&           (a) MCTYP = 'M' 건 : OLDFT = 이동전 선물집행번호(OFUTN)
*&           (b) MCTYP = 'N' 건 : OLDFT = ''  <-- 연결 끊김
*&           으로 저장되어 ZNFR2600 Tree 에서 (b)가 별도 Root 로 표시됨.
*&           2026.08.02 이후 생성분은 ZNFR2320 수정으로 (b)-OLDFT = (a)
*&  - 처리 : 같은 만기이동요청(SHFNO) 안에서 (b)의 직전 채번
*&           (NFUTN - 1) 인 (a) 를 찾아 (b)-OLDFT 에 설정
*&           짝이 없으면 변경하지 않고 결과에 표시
*&  - P_TEST = 'X' 이면 조회만 하고 DB 변경 없음
*&---------------------------------------------------------------------*
*& 2026.10.13  박우진  최초 작성
*&---------------------------------------------------------------------*
REPORT ZNFR9993.

TABLES: ZNFT1040, ZNFT1020.

TYPES: BEGIN OF TY_OUT,
         STATUS  TYPE ICON_D,
         BUKRS   TYPE ZNFT1040-BUKRS,
         SHFNO   TYPE ZNFT1041-SHFNO,
         DRSTA   TYPE ZNFT1040-DRSTA,
         OFUTN   TYPE ZNFT1040-OFUTN,    "이동전 선물집행번호
         H_NO1   TYPE ZNFT1041-H_NO1,
         NFUTN   TYPE ZNFT1020-NFUTN,    "신규(N) 선물집행번호
         MCTYP   TYPE ZNFT1020-MCTYP,
         YNCAN   TYPE ZNFT1020-YNCAN,
         ERDAT   TYPE ZNFT1020-ERDAT,
         OLDFT_B TYPE ZNFT1020-OLDFT,    "변경전 OLDFT
         OLDFT_A TYPE ZNFT1020-OLDFT,    "변경후 OLDFT (M 건 번호)
         MSG     TYPE CHAR100,
       END OF TY_OUT.

DATA: GT_OUT TYPE STANDARD TABLE OF TY_OUT.

*----------------------------------------------------------------------*
* Selection Screen
*----------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK B1 WITH FRAME.
SELECT-OPTIONS: S_BUKRS FOR ZNFT1040-BUKRS,
                S_SHFNO FOR ZNFT1040-SHFNO,
                S_ERDAT FOR ZNFT1020-ERDAT.
SELECTION-SCREEN END OF BLOCK B1.

SELECTION-SCREEN BEGIN OF BLOCK B2 WITH FRAME.
PARAMETERS: P_TEST AS CHECKBOX DEFAULT 'X'.   "Test Run (DB 변경 없음)
SELECTION-SCREEN END OF BLOCK B2.

*----------------------------------------------------------------------*
START-OF-SELECTION.
*----------------------------------------------------------------------*
  PERFORM GET_DATA.

  IF GT_OUT IS INITIAL.
    MESSAGE '처리 대상이 없습니다.' TYPE 'S'.
    RETURN.
  ENDIF.

  IF P_TEST IS INITIAL.
    PERFORM UPDATE_DATA.
  ENDIF.

  PERFORM DISPLAY_DATA.

*&---------------------------------------------------------------------*
*&      Form  GET_DATA
*&---------------------------------------------------------------------*
FORM GET_DATA.

  TYPES: BEGIN OF LTY_M,
           SHFNO TYPE ZNFT1041-SHFNO,
           NFUTN TYPE ZNFT1020-NFUTN,
         END OF LTY_M.

  DATA: LT_M   TYPE SORTED TABLE OF LTY_M WITH UNIQUE KEY SHFNO NFUTN,
        LV_NUM TYPE N LENGTH 10,
        LV_PRV TYPE ZNFT1020-NFUTN.

*___OLDFT 가 끊어진 Market Carry 신규(N) 건
  SELECT A~BUKRS, B~SHFNO, A~DRSTA, A~OFUTN, B~H_NO1,
         C~NFUTN, C~MCTYP, C~YNCAN, C~ERDAT, C~OLDFT AS OLDFT_B
    FROM ZNFT1041 AS B
   INNER JOIN ZNFT1040 AS A ON A~SHFNO = B~SHFNO
   INNER JOIN ZNFT1020 AS C ON C~NFUTN = B~NFUTN
   WHERE B~GUBUN = '1'      "신규(만기이동)
     AND C~MCTYP = 'N'
     AND C~OLDFT = @SPACE
     AND A~BUKRS IN @S_BUKRS
     AND A~SHFNO IN @S_SHFNO
     AND C~ERDAT IN @S_ERDAT
    INTO CORRESPONDING FIELDS OF TABLE @GT_OUT.

  CHECK GT_OUT IS NOT INITIAL.

*___같은 만기이동요청의 (a) M 건
  SELECT B~SHFNO, B~NFUTN
    FROM ZNFT1041 AS B
   INNER JOIN ZNFT1020 AS C ON C~NFUTN = B~NFUTN
     FOR ALL ENTRIES IN @GT_OUT
   WHERE B~SHFNO = @GT_OUT-SHFNO
     AND C~MCTYP = 'M'
    INTO CORRESPONDING FIELDS OF TABLE @LT_M.

  LOOP AT GT_OUT ASSIGNING FIELD-SYMBOL(<LS_OUT>).
    IF <LS_OUT>-NFUTN CN '0123456789'.
      <LS_OUT>-STATUS = ICON_LED_RED.
      <LS_OUT>-MSG    = '선물집행번호가 숫자가 아님'.
      CONTINUE.
    ENDIF.

*___(a)와 (b)는 연속 채번 : (a) = (b) - 1
    LV_NUM = <LS_OUT>-NFUTN.
    LV_NUM = LV_NUM - 1.
    LV_PRV = LV_NUM.

    READ TABLE LT_M TRANSPORTING NO FIELDS
         WITH TABLE KEY SHFNO = <LS_OUT>-SHFNO
                        NFUTN = LV_PRV.
    IF SY-SUBRC = 0.
      <LS_OUT>-OLDFT_A = LV_PRV.
      <LS_OUT>-STATUS  = ICON_LED_YELLOW.
      <LS_OUT>-MSG     = '연결 대상'.
    ELSE.
      <LS_OUT>-STATUS  = ICON_LED_RED.
      <LS_OUT>-MSG     = '같은 SHFNO 에 직전번호 M 건 없음 - 미처리'.
    ENDIF.
  ENDLOOP.

  SORT GT_OUT BY BUKRS SHFNO H_NO1.

ENDFORM.                    " GET_DATA
*&---------------------------------------------------------------------*
*&      Form  UPDATE_DATA
*&---------------------------------------------------------------------*
FORM UPDATE_DATA.

  DATA: LV_ANSWER TYPE C,
        LV_CNT    TYPE I,
        LV_TEXT   TYPE STRING.

  LOOP AT GT_OUT TRANSPORTING NO FIELDS WHERE STATUS = ICON_LED_YELLOW.
    LV_CNT = LV_CNT + 1.
  ENDLOOP.

  IF LV_CNT = 0.
    RETURN.
  ENDIF.

  LV_TEXT = |ZNFT1020-OLDFT { LV_CNT } 건을 변경합니다. 진행하시겠습니까?|.

  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      TITLEBAR              = 'OLDFT 연결 Migration'
      TEXT_QUESTION         = LV_TEXT
      DISPLAY_CANCEL_BUTTON = SPACE
    IMPORTING
      ANSWER                = LV_ANSWER
    EXCEPTIONS
      OTHERS                = 1.

  IF SY-SUBRC <> 0 OR LV_ANSWER <> '1'.
    MESSAGE '취소되었습니다. DB 변경 없음.' TYPE 'S'.
    LOOP AT GT_OUT ASSIGNING FIELD-SYMBOL(<LS_OUT>)
                   WHERE STATUS = ICON_LED_YELLOW.
      <LS_OUT>-MSG = '연결 대상 (취소됨)'.
    ENDLOOP.
    RETURN.
  ENDIF.

  LOOP AT GT_OUT ASSIGNING <LS_OUT> WHERE STATUS = ICON_LED_YELLOW.

    CALL FUNCTION 'ENQUEUE_EZ_ZNFT1020'
      EXPORTING
        NFUTN          = <LS_OUT>-NFUTN
      EXCEPTIONS
        FOREIGN_LOCK   = 1
        SYSTEM_FAILURE = 2
        OTHERS         = 3.
    IF SY-SUBRC <> 0.
      <LS_OUT>-STATUS = ICON_LED_RED.
      <LS_OUT>-MSG    = |Lock 실패 (사용자: { SY-MSGV1 })|.
      CONTINUE.
    ENDIF.

*___조회 이후 다른 곳에서 변경되었으면 건드리지 않음 (OLDFT = SPACE 조건)
    UPDATE ZNFT1020 SET OLDFT = @<LS_OUT>-OLDFT_A
     WHERE NFUTN = @<LS_OUT>-NFUTN
       AND OLDFT = @SPACE.

    IF SY-SUBRC = 0.
      <LS_OUT>-STATUS = ICON_LED_GREEN.
      <LS_OUT>-MSG    = '변경 완료'.
    ELSE.
      <LS_OUT>-STATUS = ICON_LED_RED.
      <LS_OUT>-MSG    = '변경 안됨 (이미 OLDFT 존재)'.
    ENDIF.
  ENDLOOP.

  COMMIT WORK AND WAIT.

  CALL FUNCTION 'DEQUEUE_ALL'.

ENDFORM.                    " UPDATE_DATA
*&---------------------------------------------------------------------*
*&      Form  DISPLAY_DATA
*&---------------------------------------------------------------------*
FORM DISPLAY_DATA.

  DATA: LO_ALV  TYPE REF TO CL_SALV_TABLE,
        LO_COLS TYPE REF TO CL_SALV_COLUMNS_TABLE,
        LX_MSG  TYPE REF TO CX_SALV_MSG.

  TRY.
      CL_SALV_TABLE=>FACTORY(
        IMPORTING R_SALV_TABLE = LO_ALV
        CHANGING  T_TABLE      = GT_OUT ).
    CATCH CX_SALV_MSG INTO LX_MSG.
      MESSAGE LX_MSG TYPE 'E'.
  ENDTRY.

  LO_ALV->GET_FUNCTIONS( )->SET_ALL( ABAP_TRUE ).
  LO_ALV->GET_DISPLAY_SETTINGS( )->SET_STRIPED_PATTERN( ABAP_TRUE ).

  IF P_TEST IS NOT INITIAL.
    LO_ALV->GET_DISPLAY_SETTINGS( )->SET_LIST_HEADER(
      'OLDFT 연결 Migration - TEST RUN (DB 변경 없음)' ).
  ELSE.
    LO_ALV->GET_DISPLAY_SETTINGS( )->SET_LIST_HEADER(
      'OLDFT 연결 Migration - 실행 결과' ).
  ENDIF.

  LO_COLS = LO_ALV->GET_COLUMNS( ).
  LO_COLS->SET_OPTIMIZE( ABAP_TRUE ).

  PERFORM SET_COLUMN_TEXT USING LO_COLS:
    'STATUS'  '상태',
    'NFUTN'   '신규(N)선물집행',
    'OLDFT_B' '변경전 OLDFT',
    'OLDFT_A' '변경후 OLDFT',
    'MCTYP'  '만기이동유형',
    'MSG'     '메시지'.

  LO_ALV->DISPLAY( ).

ENDFORM.                    " DISPLAY_DATA
*&---------------------------------------------------------------------*
*&      Form  SET_COLUMN_TEXT
*&---------------------------------------------------------------------*
FORM SET_COLUMN_TEXT USING PO_COLS  TYPE REF TO CL_SALV_COLUMNS_TABLE
                           PV_FIELD TYPE LVC_FNAME
                           PV_TEXT  TYPE CSEQUENCE.

  DATA: LO_COL TYPE REF TO CL_SALV_COLUMN.

  TRY.
      LO_COL = PO_COLS->GET_COLUMN( PV_FIELD ).
      LO_COL->SET_SHORT_TEXT( CONV #( PV_TEXT ) ).
      LO_COL->SET_MEDIUM_TEXT( CONV #( PV_TEXT ) ).
      LO_COL->SET_LONG_TEXT( CONV #( PV_TEXT ) ).
    CATCH CX_SALV_NOT_FOUND.
  ENDTRY.

ENDFORM.                    " SET_COLUMN_TEXT
