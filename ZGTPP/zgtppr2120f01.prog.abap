*&---------------------------------------------------------------------*
*& Include          ZGTPPR2120F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form INITIALIZATION
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM INITIALIZATION .

  IF S_SPMON IS INITIAL.
    CLEAR : GV_BGN_DT, GV_END_DT.

    GV_BGN_DT = SY-DATUM.
    S_SPMON-LOW = GV_BGN_DT+0(6).
    GV_END_DT = SY-DATUM.
    PERFORM CAL_DATE_TO_MONTH USING '2' CHANGING GV_END_DT.
    S_SPMON-HIGH = GV_END_DT+0(6).
    PERFORM GET_LAST_DAY_OF_MONTH CHANGING GV_END_DT.
    APPEND S_SPMON.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_LAST_DAY_OF_MONTH
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- LV_END_DATE
*&---------------------------------------------------------------------*
FORM GET_LAST_DAY_OF_MONTH  CHANGING PV_DATE TYPE SY-DATUM.

  CALL FUNCTION 'LAST_DAY_OF_MONTHS'
    EXPORTING
      DAY_IN            = PV_DATE
    IMPORTING
      LAST_DAY_OF_MONTH = PV_DATE
    EXCEPTIONS
      DAY_IN_NO_DATE    = 1
      OTHERS            = 2.
  .
  IF SY-SUBRC <> 0.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form cal_date_to_month
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- S_DATE_HIGH
*&---------------------------------------------------------------------*
FORM CAL_DATE_TO_MONTH  USING PV_MONTH
                                    CHANGING PV_DATE TYPE SY-DATUM.
  CALL FUNCTION 'CALCULATE_DATE'
    EXPORTING
      MONTHS      = PV_MONTH
      START_DATE  = PV_DATE
    IMPORTING
      RESULT_DATE = PV_DATE.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form MODIFY_FIRST_SCREEN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM MODIFY_FIRST_SCREEN .

  LOOP AT SCREEN.

    IF SCREEN-GROUP1 = 'M1'.
      SCREEN-INPUT = 0.
*      SCREEN-INTENSIFIED = 1.
      MODIFY SCREEN.
    ENDIF.

    IF SCREEN-GROUP1 = 'M2'.
      SCREEN-INPUT = 0.
      SCREEN-INTENSIFIED = 1.
      MODIFY SCREEN.
    ENDIF.

    IF SCREEN-NAME = 'S_DATE-LOW'.
      SCREEN-INPUT = 0.
      MODIFY SCREEN.
    ENDIF.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_PARAMETER_DESCRIPTION
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_PARAMETER_DESCRIPTION .

* SPG
  IF NOT P_SPGCD IS INITIAL.
    SELECT SINGLE DESCR INTO P_DESCR
             FROM ZPPT0107
            WHERE SPGCD EQ P_SPGCD.
  ELSE.
    CLEAR P_DESCR.
  ENDIF.

* 공급플랜트명
  IF NOT P_WERKS IS INITIAL.
    SELECT SINGLE NAME1 INTO P_NAME1
             FROM T001W
            WHERE WERKS EQ P_WERKS.
  ELSE.
    CLEAR P_NAME1.
  ENDIF.

* 요청플랜트명
  IF NOT P_WERK2 IS INITIAL.
    SELECT SINGLE NAME1 INTO P_NAME2
             FROM T001W
            WHERE WERKS EQ P_WERK2.
  ELSE.
    CLEAR P_NAME2.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form VALIDATION_OF_WERKS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM VALIDATION_OF_WERKS .

  IF P_WERKS IS NOT INITIAL.
    SELECT SINGLE WERKS FROM ZPPT0107
       INTO @DATA(LV_WERKS)
     WHERE SPGCD = @P_SPGCD
        AND WERKS =  @P_WERKS.
    IF SY-SUBRC NE 0.
      MESSAGE E006 WITH '소재(SCR)에 해당하는 플랜트가 아닙니다.'.
    ENDIF.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form F4_WERKS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&---------------------------------------------------------------------*
FORM F4_WERKS  USING    PV_DYNPROFLD TYPE HELP_INFO-DYNPROFLD .

  DATA : BEGIN OF LS_WERKS,
           WERKS TYPE ZPPT0107-WERKS,
           NAME1 TYPE T001W-NAME1,
           SPGCD TYPE ZPPT0107-SPGCD,
           DESCR TYPE ZPPT0107-DESCR,
         END OF LS_WERKS.
  DATA : LT_WERKS LIKE TABLE OF LS_WERKS.

  DATA : LT_RETURN_TAB TYPE TABLE OF DDSHRETVAL,
         LS_RETURN_TAB LIKE LINE OF LT_RETURN_TAB.

  DATA : LV_OFFSET(6) TYPE N.
  DATA : LO_FLIEF TYPE REF TO DATA.

  DATA : LT_FIELD_TAB TYPE TABLE OF DFIES.
  DATA : LO_STRUCTDESCR TYPE REF TO CL_ABAP_STRUCTDESCR.

  DATA : LV_LINE       LIKE SY-STEPL,
         LT_DYNPFIELDS LIKE TABLE OF DYNPREAD.

* SPG 기준 'BC' 해당 플랜트만 조회
  SELECT A~WERKS, B~NAME1, A~SPGCD, A~DESCR
    FROM ZPPT0107 AS A
    INNER JOIN T001W AS B ON B~WERKS = A~WERKS
    INTO CORRESPONDING FIELDS OF TABLE @LT_WERKS
   WHERE A~SPGCD = @P_SPGCD.
  SORT LT_WERKS BY WERKS.
  DELETE ADJACENT DUPLICATES FROM LT_WERKS COMPARING WERKS.

* 필드 속성 정의
  FREE LO_FLIEF.
  CREATE DATA LO_FLIEF LIKE LS_WERKS.

  LO_STRUCTDESCR ?= CL_ABAP_STRUCTDESCR=>DESCRIBE_BY_DATA_REF( LO_FLIEF ).
  LT_FIELD_TAB = CL_SALV_DATA_DESCR=>READ_STRUCTDESCR( LO_STRUCTDESCR ).

  CLEAR LV_OFFSET.
  LOOP AT LT_FIELD_TAB ASSIGNING FIELD-SYMBOL(<LS_FIELD_TAB>).

    CASE <LS_FIELD_TAB>-FIELDNAME.
      WHEN 'WERKS'.
        <LS_FIELD_TAB>-REPTEXT  = '플랜트'.
      WHEN 'NAME1'.
        <LS_FIELD_TAB>-REPTEXT  = '플랜트명'.
      WHEN 'SPGCD'.
        <LS_FIELD_TAB>-REPTEXT  = 'SPG'.
      WHEN 'DESCR'.
        <LS_FIELD_TAB>-REPTEXT  = 'SPG 내역'.
    ENDCASE.

    <LS_FIELD_TAB>-OFFSET = LV_OFFSET.
    LV_OFFSET = LV_OFFSET + <LS_FIELD_TAB>-INTLEN.
  ENDLOOP.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'  "F4 창 띄움
    EXPORTING
      RETFIELD        = 'WERKS'
      DYNPROFIELD     = PV_DYNPROFLD           "F4누른 필드->DEPT_CD
      VALUE_ORG       = 'S'                      "가져오는 엔트리가 다수일 경우인 것 같음. 다수일 경우 C로 하면 F4 안뜸
      WINDOW_TITLE    = '플랜트 조회'   "Search Help 타이틀
      DISPLAY         = 'F'
    TABLES
      FIELD_TAB       = LT_FIELD_TAB
      VALUE_TAB       = LT_WERKS                  "부서코드, 부서명 가져온 인터널 테이블
      RETURN_TAB      = LT_RETURN_TAB            "F4에서 선택한 값이 들어옴
    EXCEPTIONS
      PARAMETER_ERROR = 1
      NO_VALUES_FOUND = 2
      OTHERS          = 3.

  READ TABLE LT_RETURN_TAB INTO LS_RETURN_TAB INDEX 1.
  IF SY-SUBRC EQ 0.
    READ TABLE LT_WERKS INTO LS_WERKS WITH KEY WERKS = LS_RETURN_TAB-FIELDVAL.

    REFRESH LT_DYNPFIELDS.
    PERFORM GET_STEPL USING LV_LINE.
*      시뮬레이션 번호
    APPEND INITIAL LINE TO LT_DYNPFIELDS ASSIGNING FIELD-SYMBOL(<LS_DYNPFIELDS>).
    <LS_DYNPFIELDS>-FIELDNAME = 'P_WERKS'.
    <LS_DYNPFIELDS>-STEPL = LV_LINE.
    <LS_DYNPFIELDS>-FIELDVALUE = LS_WERKS-WERKS.

*      시뮬레이션 이름
    APPEND INITIAL LINE TO LT_DYNPFIELDS ASSIGNING <LS_DYNPFIELDS>.
    <LS_DYNPFIELDS>-FIELDNAME = 'P_NAME1'.
    <LS_DYNPFIELDS>-STEPL = LV_LINE.
    <LS_DYNPFIELDS>-FIELDVALUE = LS_WERKS-NAME1.

    CALL FUNCTION 'DYNP_VALUES_UPDATE'
      EXPORTING
        DYNAME               = SY-CPROG
        DYNUMB               = SY-DYNNR
      TABLES
        DYNPFIELDS           = LT_DYNPFIELDS
      EXCEPTIONS
        INVALID_ABAPWORKAREA = 1
        INVALID_DYNPROFIELD  = 2
        INVALID_DYNPRONAME   = 3
        INVALID_DYNPRONUMMER = 4
        INVALID_REQUEST      = 5
        NO_FIELDDESCRIPTION  = 6
        UNDEFIND_ERROR       = 7
        OTHERS               = 8.
    IF SY-SUBRC <> 0.
    ENDIF.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_STEPL
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LV_LINE
*&---------------------------------------------------------------------*
FORM GET_STEPL  USING    PV_LINE LIKE SY-STEPL.
  CALL FUNCTION 'DYNP_GET_STEPL'
    IMPORTING
      POVSTEPL        = PV_LINE
    EXCEPTIONS
      STEPL_NOT_FOUND = 01.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form AUTHORITY_CHECKING_PROC
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM AUTHORITY_CHECKING_PROC .

**& 플랜트에 대한 권한체크
*  AUTHORITY-CHECK OBJECT 'ZPP_WERKS'
*                      ID 'WERKS'  FIELD P_WERKS.
*
*  IF SY-SUBRC <> 0.
*    AUTHORITY-CHECK OBJECT 'ZPP_WERKS'
*                        ID 'WERKS'  FIELD P_WERK2.
*    IF SY-SUBRC <> 0.
*
*
*      MESSAGE E006 WITH '플랜트[' P_WERK2
*                        '] 작업권한을 확인하세요.'.
*    ENDIF.
*  ELSE.
**& SPG에 대한 권한체크
*    AUTHORITY-CHECK OBJECT 'ZPP_SPGCD'
*    ID 'WERKS'  FIELD P_WERKS
*    ID 'SPGCD'  FIELD P_SPGCD.
*
*    IF SY-SUBRC <> 0.
*      MESSAGE E006 WITH 'SPG[' P_SPGCD
*                        '] 작업권한을 확인하세요.'.
*    ENDIF.
*
*  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_PROC
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_PROC .

* 초기 세팅 설정, 조회날짜범위 세팅
  PERFORM INIT_DATA.
  PERFORM GET_MANAGEMENT_MATNR.

* 디스플레이 화면 구성, 동적 인터널테이블 생성
  PERFORM INIT_SCREEN_100.

* 대상정보 추출.
  PERFORM GET_DATA.

* 대상정보 추출.
  PERFORM SET_DISP_TABLE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form DISP_PROC
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM DISP_PROC .

  CALL SCREEN '0100'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form INIT_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM INIT_DATA .

  DATA : LV_SPMON TYPE SPMON.
  DATA : LV_STRING TYPE STRING.
  DATA : LV_NUM_C(2).
  DATA : LV_DATE TYPE SY-DATUM.

  REFRESH GT_SPMON.
  FREE GT_SPMON.
  REFRESH GR_SPMON.

  LV_SPMON = S_SPMON-LOW.

  DO.
    IF LV_SPMON > S_SPMON-HIGH.
      EXIT.
    ENDIF.

    CLEAR GS_SPMON.
    CLEAR LV_STRING.
    CLEAR LV_NUM_C.

    APPEND INITIAL LINE TO GR_SPMON ASSIGNING FIELD-SYMBOL(<LS_SPMON>).
    <LS_SPMON>-SIGN = 'I'.
    <LS_SPMON>-OPTION = 'EQ'.
    <LS_SPMON>-LOW = LV_SPMON.

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
      EXPORTING
        INPUT  = LV_SPMON+4(2)
      IMPORTING
        OUTPUT = LV_NUM_C.
    .

    LV_STRING = LV_SPMON+0(4) && '.' && LV_NUM_C && '월'.
    GS_SPMON-SPMON = LV_SPMON.
    GS_SPMON-FIELDNAME_A = LV_SPMON && 'A'.
    GS_SPMON-FIELDNAME_A_CHK = LV_SPMON && 'A_CHK'.
    GS_SPMON-FIELDNAME_B = LV_SPMON && 'B'.
    GS_SPMON-FIELDNAME_B_CHK = LV_SPMON && 'B_CHK'.
    GS_SPMON-REPTEXT_A = LV_STRING. " && '(월간)'.
    GS_SPMON-REPTEXT_B = LV_STRING && '(일간)'.
    GS_SPMON-FRDATE = LV_SPMON && '01'.
    GS_SPMON-TODATE = GS_SPMON-FRDATE.
    PERFORM GET_LAST_DAY_OF_MONTH CHANGING GS_SPMON-TODATE.
    APPEND GS_SPMON TO GT_SPMON.

    CLEAR LV_DATE.
    LV_DATE = GS_SPMON-TODATE + 1.
    LV_SPMON = LV_DATE+0(6).

  ENDDO.

* 공휴일체크

  GV_BGN_DT = S_SPMON-LOW && '01'.
  GV_END_DT = S_SPMON-HIGH && '01'.

  PERFORM GET_LAST_DAY_OF_MONTH CHANGING GV_END_DT.

  REFRESH GT_DAY_ATTR.

  DATA : LV_FACTORY_ID TYPE SCAL-FCALID.
  DATA : LV_HOLIDAY_ID TYPE SCAL-FCALID.

*  SELECT SINGLE A~FABKL, B~HOCID
*    FROM T001W AS A
*    INNER JOIN TFACD AS B ON B~IDENT = A~FABKL
*    WHERE A~WERKS = @P_WERKS
*    INTO ( @LV_FACTORY_ID, @LV_HOLIDAY_ID ).

  CALL FUNCTION 'DAY_ATTRIBUTES_GET'
    EXPORTING
      FACTORY_CALENDAR           = 'LG'   "LV_FACTORY_ID
      HOLIDAY_CALENDAR           = 'LG'     "LV_HOLIDAY_ID
      DATE_FROM                  = GV_BGN_DT
      DATE_TO                    = GV_END_DT
      LANGUAGE                   = SY-LANGU
    TABLES
      DAY_ATTRIBUTES             = GT_DAY_ATTR
    EXCEPTIONS
      FACTORY_CALENDAR_NOT_FOUND = 1
      HOLIDAY_CALENDAR_NOT_FOUND = 2
      DATE_HAS_INVALID_FORMAT    = 3
      DATE_INCONSISTENCY         = 4
      OTHERS                     = 5.
  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

  SORT GT_DAY_ATTR BY DATE.

* 요청플랜트 세팅
  REFRESH GR_WERKS.
  APPEND INITIAL LINE TO GR_WERKS ASSIGNING FIELD-SYMBOL(<LS_WERKS>).
  <LS_WERKS>-SIGN = 'I'.
  <LS_WERKS>-LOW = P_WERK2.

  IF P_WERK2 CS '*'.
    <LS_WERKS>-OPTION = 'CP'.
  ELSE.
    <LS_WERKS>-OPTION = 'EQ'.
  ENDIF.

  APPEND INITIAL LINE TO GR_WERKS ASSIGNING <LS_WERKS>.
  <LS_WERKS>-SIGN = 'E'.
  <LS_WERKS>-LOW = P_WERKS.
  <LS_WERKS>-OPTION = 'EQ'.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form INIT_SCREEN_100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM INIT_SCREEN_100 .

  PERFORM SET_FIELDCAT_0100.
  PERFORM MAKE_ITAB_FR_FCAT.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form TOOLBAR_PROS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> SENDER
*&      --> E_OBJECT
*&      --> E_INTERACTIVE
*&---------------------------------------------------------------------*
FORM TOOLBAR_PROS  USING    PO_SENDER
                          PO_OBJECT TYPE REF TO CL_ALV_EVENT_TOOLBAR_SET
                          R_INTERACTIVE.

  CASE PO_SENDER.
    WHEN GO_GRID_0100.
      PERFORM SET_TOOLBAR TABLES PO_OBJECT->MT_TOOLBAR
                        USING : '' '' '' '' 3,
*                                   'CONFIRM' ICON_ALLOW '사내이체요청' '사내이체요청' 0,
*                                   'CANCEL' ICON_REJECT '사내이체요청취소' '사내이체요청취소' 0,
*                                   '' '' '' '' 3,
                                    'CREATE' ICON_SET_STATE '사내이체오더발행' '사내이체오더발행' 0,
                                   'REJECT' ICON_DELETE '사내이체오더취소' '사내이체오더취소' 0,
                                   '' '' '' '' 3,
                                   'COPY' ICON_COPY_OBJECT 'Copy' 'Copy' 0,
                                   'DELE' ICON_DELETE_ROW 'Delete' 'Delete' 0,
                                   '' '' '' '' 3.
      .
    WHEN GO_GRID_0101.
      PERFORM SET_TOOLBAR TABLES PO_OBJECT->MT_TOOLBAR
                        USING : '' '' '' '' 3,
                                   'SAVE_DETAIL' ICON_SYSTEM_SAVE '상세요청저장' '상세요청저장' 0.
      IF GS_DISP_HEADER_101-GUBUN = ABAP_TRUE.
        PERFORM SET_TOOLBAR TABLES PO_OBJECT->MT_TOOLBAR
                          USING : '' '' '' '' 3,
                                     'ADD_101' ICON_INSERT_ROW '' 'Insert' 0,
                                     'DELE_101' ICON_DELETE_ROW '' 'Delete' 0.
      ENDIF.

      PERFORM SET_TOOLBAR TABLES PO_OBJECT->MT_TOOLBAR
                        USING : '' '' '' '' 3,
                                   'DELIVERY' ICON_SHOPPINGCART '출하요청' '출하요청' 0,
                                   'DELIVERY_CANC' ICON_DELETE_SHOPPINGCART '출하요청 취소' '출하요청 취소' 0,
                                   '' '' '' '' 3,
                                   'CLOSE' ICON_INCOMPLETE '닫기' '닫기' 0.



  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_toolbar
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> P_
*&      --> P_
*&      --> P_
*&      --> P_
*&      --> PO_OBJECT_>MT_TOOLBAR
*&---------------------------------------------------------------------*
FORM SET_TOOLBAR  TABLES  PT_TOOLBAR STRUCTURE STB_BUTTON
               USING    PV_FUNCTION
                           PV_ICON
                           PV_TEXT
                           PV_QUICKINFO
                           PV_BUTN_TYPE.

  DATA : LS_TOOLBAR  TYPE STB_BUTTON.

  CLEAR LS_TOOLBAR.
  LS_TOOLBAR-FUNCTION  = PV_FUNCTION.
  LS_TOOLBAR-ICON      = PV_ICON.
  IF PV_TEXT IS NOT INITIAL.
    CONCATENATE ' '  PV_TEXT ' '  INTO LS_TOOLBAR-TEXT SEPARATED BY SPACE.
  ENDIF.
  LS_TOOLBAR-QUICKINFO = PV_QUICKINFO.
  LS_TOOLBAR-BUTN_TYPE = PV_BUTN_TYPE.
  APPEND LS_TOOLBAR TO PT_TOOLBAR.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form USER_COMMAND_PROS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> SENDER
*&      --> E_UCOMM
*&---------------------------------------------------------------------*
FORM USER_COMMAND_PROS  USING    PO_SENDER  TYPE REF TO CL_GUI_ALV_GRID
                                 PV_UCOMM.

  CASE PO_SENDER.
    WHEN GO_GRID_0100.

      CASE PV_UCOMM. " 데이터 수정중일시 요청작업 불가
        WHEN 'CONFIRM' OR 'CANCEL'.
          IF GV_CHK_EDIT = ABAP_TRUE OR GV_CHK_EDIT_101 = ABAP_TRUE.
            MESSAGE S006 DISPLAY LIKE 'E' WITH '변경된 데이터가 있습니다. 저장 후 작업하세요.'.
            RETURN.
          ENDIF.
      ENDCASE.

      CASE PV_UCOMM.
        WHEN 'CREATE'. " 사내이체오더발행
          PERFORM PROC_AUTO_CREATE_PO.
        WHEN 'REJECT'. " 사내이체오더취소
          PERFORM PROC_AUTO_REJECT_PO.
        WHEN 'CONFIRM'. " 사내이체요청
*          PERFORM PROC_CONFIRM_PLAN.
        WHEN 'CANCEL'. " 사내이체요청취소
*          PERFORM PROC_CANCEL_PLAN.
        WHEN 'COPY'.
          PERFORM COPY_LINE.
        WHEN 'DELE'.
          PERFORM DELETE_LINE.
      ENDCASE.
    WHEN GO_GRID_0101.
*      CASE PV_UCOMM. " 데이터 수정중일시 요청작업 불가
*        WHEN 'CONFIRM' OR 'CANCEL'.
*          IF GV_CHK_EDIT_101 = ABAP_TRUE.
*            MESSAGE S006 DISPLAY LIKE 'E' WITH '변경된 데이터가 있습니다. 저장 후 작업하세요.'.
*            RETURN.
*          ENDIF.
*      ENDCASE.

      CASE PV_UCOMM.
        WHEN 'SAVE_DETAIL'. " 상세요청 저장
          PERFORM PROC_SAVE_DETAIL.
*        WHEN 'CONFIRM'. " 사내이체요청
*          PERFORM PROC_CONFIRM_PLAN.
*        WHEN 'CANCEL'. " 사내이체요청취소
*          PERFORM PROC_CANCEL_PLAN.
        WHEN 'ADD_101'.
          PERFORM PROC_ADD_101_LINE.
        WHEN 'DELE_101'.
          PERFORM PROC_DELE_101_LINE.

        WHEN 'CLOSE'.
          PERFORM PROC_CLOSE.
        WHEN 'CALC'.
          PERFORM PROC_CALC.
        WHEN 'DELIVERY'.
          PERFORM PROC_DELIVERY.
        WHEN 'DELIVERY_CANC'.
          PERFORM PROC_DELIVERY_CANC.
      ENDCASE.
  ENDCASE.



ENDFORM.
*&---------------------------------------------------------------------*
*& Form ALV_TOP_OF_PAGE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> SENDER
*&      <-- E_DYNDOC_ID
*&---------------------------------------------------------------------*
FORM ALV_TOP_OF_PAGE  USING    PO_SENDER TYPE REF TO CL_GUI_ALV_GRID
                                CHANGING    PO_DYNDOC_ID  TYPE REF TO  CL_DD_DOCUMENT.

  CASE PO_SENDER.
    WHEN GO_GRID_0100.
      PERFORM SET_TITLE_SCREEN100 CHANGING PO_DYNDOC_ID.
    WHEN GO_GRID_0101.
      PERFORM SET_TITLE_SCREEN101 CHANGING PO_DYNDOC_ID.
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_FIELDCAT_0100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_FIELDCAT_0100 .

  DATA : LT_FCAT TYPE SLIS_T_FIELDCAT_ALV.
  DATA : LV_COL_POS_A TYPE I.
  DATA : LV_COL_POS_B TYPE I.
  DATA : LV_DATE TYPE SY-DATUM.

  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      I_PROGRAM_NAME     = SY-REPID
      I_INTERNAL_TABNAME = 'GS_MAIN'
      I_INCLNAME         = 'ZGTPPR2120TOP'
      I_BYPASSING_BUFFER = 'X'
    CHANGING
      CT_FIELDCAT        = LT_FCAT.

  CALL FUNCTION 'LVC_TRANSFER_FROM_SLIS'
    EXPORTING
      IT_FIELDCAT_ALV = LT_FCAT
    IMPORTING
      ET_FIELDCAT_LVC = GT_FIELDCAT_0100[]
    TABLES
      IT_DATA         = GT_MAIN.

* 추가필드 세팅

  READ TABLE GT_FIELDCAT_0100 TRANSPORTING NO FIELDS WITH KEY FIELDNAME = 'SEQ_ATWRT'.
  IF SY-SUBRC NE 0.
    APPEND INITIAL LINE TO GT_FIELDCAT_0100 ASSIGNING FIELD-SYMBOL(<LS_FCAT>).
    <LS_FCAT>-COL_POS = 4.
    <LS_FCAT>-FIELDNAME = 'SEQ_ATWRT'.
    <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = <LS_FCAT>-FIELDNAME.
    <LS_FCAT>-DATATYPE = 'INT'.
    <LS_FCAT>-DD_OUTLEN = '10'.
    <LS_FCAT>-NO_OUT = ABAP_TRUE.
  ENDIF.

  READ TABLE GT_FIELDCAT_0100 TRANSPORTING NO FIELDS WITH KEY FIELDNAME = 'DETAIL'.
  IF SY-SUBRC NE 0.
    APPEND INITIAL LINE TO GT_FIELDCAT_0100 ASSIGNING <LS_FCAT>.
    <LS_FCAT>-COL_POS = 8.
    <LS_FCAT>-FIELDNAME = 'DETAIL'.
    <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = <LS_FCAT>-FIELDNAME.
    <LS_FCAT>-DATATYPE = 'CHAR'.
    <LS_FCAT>-DD_OUTLEN = '5'.
  ENDIF.

  READ TABLE GT_FIELDCAT_0100 TRANSPORTING NO FIELDS WITH KEY FIELDNAME = 'CHG_REMARK'.
  IF SY-SUBRC NE 0.
    APPEND INITIAL LINE TO GT_FIELDCAT_0100 ASSIGNING <LS_FCAT>.
    <LS_FCAT>-COL_POS = 10.
    <LS_FCAT>-FIELDNAME = 'CHG_REMARK'.
    <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = <LS_FCAT>-FIELDNAME.
    <LS_FCAT>-DATATYPE = 'CHAR'.
    <LS_FCAT>-DD_OUTLEN = '1'.
    <LS_FCAT>-NO_OUT = ABAP_TRUE.
  ENDIF.

  LV_COL_POS_A = 100.
  LV_COL_POS_B = 600.

  LOOP AT GT_SPMON INTO GS_SPMON.

    APPEND INITIAL LINE TO GT_FIELDCAT_0100 ASSIGNING <LS_FCAT>.
    ADD 1 TO LV_COL_POS_A.
    <LS_FCAT>-REF_TABLE = 'AFPO'.
    <LS_FCAT>-REF_FIELD = 'PSAMG'.
    <LS_FCAT>-COL_POS = LV_COL_POS_A.
    <LS_FCAT>-FIELDNAME = GS_SPMON-FIELDNAME_A.
    <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = GS_SPMON-REPTEXT_A.
    <LS_FCAT>-JUST = 'R'.
    <LS_FCAT>-EDIT = 'X'.
    <LS_FCAT>-DO_SUM = 'X'.
    <LS_FCAT>-QUANTITY = 'EA'.

    APPEND INITIAL LINE TO GT_FIELDCAT_0100 ASSIGNING <LS_FCAT>.
    ADD 1 TO LV_COL_POS_A.
    <LS_FCAT>-COL_POS = LV_COL_POS_A.
    <LS_FCAT>-FIELDNAME = GS_SPMON-FIELDNAME_A_CHK.
    <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = <LS_FCAT>-FIELDNAME.
    <LS_FCAT>-DATATYPE = 'CHAR'.
    <LS_FCAT>-DD_OUTLEN = '1'.
    <LS_FCAT>-NO_OUT = 'X'.


*    APPEND INITIAL LINE TO GT_FIELDCAT_0100 ASSIGNING <LS_FCAT>.
*    ADD 1 TO LV_COL_POS_A.
*    <LS_FCAT>-REF_TABLE = 'AFPO'.
*    <LS_FCAT>-REF_FIELD = 'PSAMG'.
*    <LS_FCAT>-COL_POS = LV_COL_POS_A.
*    <LS_FCAT>-FIELDNAME = GS_SPMON-FIELDNAME_B.
*    <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = GS_SPMON-REPTEXT_B.
*    <LS_FCAT>-JUST = 'R'.
*    <LS_FCAT>-QUANTITY = 'EA'.
*
*    APPEND INITIAL LINE TO GT_FIELDCAT_0100 ASSIGNING <LS_FCAT>.
*    ADD 1 TO LV_COL_POS_A.
*    <LS_FCAT>-COL_POS = LV_COL_POS_B.
*    <LS_FCAT>-FIELDNAME = GS_SPMON-FIELDNAME_B_CHK.
*    <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = <LS_FCAT>-FIELDNAME.
*    <LS_FCAT>-DATATYPE = 'CHAR'.
*    <LS_FCAT>-DD_OUTLEN = '1'.
*    <LS_FCAT>-NO_OUT = 'X'.

  ENDLOOP.

* 필드명 서술
  LOOP AT GT_FIELDCAT_0100 ASSIGNING <LS_FCAT>.
    CLEAR <LS_FCAT>-KEY.
    CASE <LS_FCAT>-FIELDNAME.
      WHEN 'SEQ_ATWRT'.
        <LS_FCAT>-NO_OUT = ABAP_TRUE.
      WHEN 'WERKS'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '요청플랜트'(f01).
        <LS_FCAT>-JUST = 'C'.
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
        <LS_FCAT>-OUTPUTLEN = '6'.
      WHEN 'MATNR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '자재코드'(f02).
        <LS_FCAT>-JUST = 'C'.
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
        <LS_FCAT>-OUTPUTLEN = '13'.
      WHEN 'MAKTX'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '자재내역'(f03).
        <LS_FCAT>-JUST = 'L'.
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
        <LS_FCAT>-OUTPUTLEN = '15'.
      WHEN 'ATWRT'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '등급'(f04).
        <LS_FCAT>-JUST = 'C'.
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
        <LS_FCAT>-OUTPUTLEN = '5'.
      WHEN 'ZSEQ'.
        <LS_FCAT>-NO_OUT = ABAP_TRUE.
      WHEN 'MEINS'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '단위'(f05).
        <LS_FCAT>-JUST = 'C'.
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
        <LS_FCAT>-OUTPUTLEN = '5'.
      WHEN 'OVERDUE'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '요청합계'(f06).
        <LS_FCAT>-JUST = 'C'.
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
        <LS_FCAT>-QUANTITY = 'EA'.
        <LS_FCAT>-OUTPUTLEN = '9'.
      WHEN 'DETAIL'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '상세'(f07).
        <LS_FCAT>-HOTSPOT = 'X'.
        <LS_FCAT>-ICON = 'X'.
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
        <LS_FCAT>-OUTPUTLEN = '5'.
      WHEN 'ZREMARK'.
        <LS_FCAT>-COL_POS = 999.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '비고'(f14).
        <LS_FCAT>-JUST = 'L'.
        <LS_FCAT>-OUTPUTLEN = '30'.
        <LS_FCAT>-EDIT = ABAP_TRUE.
      WHEN 'CHG_REMARK'.
        <LS_FCAT>-NO_OUT = 'X'.
    ENDCASE.
  ENDLOOP.

  SORT GT_FIELDCAT_0100 BY COL_POS.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form MAKE_ITAB_FR_FCAT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM MAKE_ITAB_FR_FCAT .

  FREE GT_MAIN_DISP_100.

  CALL METHOD CL_ALV_TABLE_CREATE=>CREATE_DYNAMIC_TABLE
    EXPORTING
      I_STYLE_TABLE             = ABAP_TRUE
      IT_FIELDCATALOG           = GT_FIELDCAT_0100
    IMPORTING
      EP_TABLE                  = GT_MAIN_DISP_100
    EXCEPTIONS
      GENERATE_SUBPOOL_DIR_FULL = 1                " At Most 36 Subroutine Pools Can Be Generated Temporarily
      OTHERS                    = 2.
  IF SY-SUBRC <> 0.
    MESSAGE S005 DISPLAY LIKE 'E' WITH 'At Most 36 Subroutine Pools' 'Can Be Generated Temporarily'.
    LEAVE LIST-PROCESSING..
  ENDIF.

  ASSIGN GT_MAIN_DISP_100->* TO <GT_MAIN_DISP_100>.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form popup_to_confirm_step
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> P_
*&      --> P_
*&      --> P_
*&---------------------------------------------------------------------*
FORM POPUP_TO_CONFIRM_STEP  USING LP_OPT
                                  LP_TEXT1
                                  LP_TEXT2
                                  LP_TITLE.
  CLEAR GV_ANSWER.
  CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
    EXPORTING
      DEFAULTOPTION  = LP_OPT
      TEXTLINE1      = LP_TEXT1
      TEXTLINE2      = LP_TEXT2
      TITEL          = LP_TITLE
      CANCEL_DISPLAY = ''
    IMPORTING
      ANSWER         = GV_ANSWER.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_OBJECT_GRID_0100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_OBJECT_GRID_0100 .

  CREATE OBJECT GO_DOCKING_0100
    EXPORTING
      REPID                       = SY-REPID
      DYNNR                       = SY-DYNNR
      EXTENSION                   = 10000
    EXCEPTIONS
      CNTL_ERROR                  = 1
      CNTL_SYSTEM_ERROR           = 2
      CREATE_ERROR                = 3
      LIFETIME_ERROR              = 4
      LIFETIME_DYNPRO_DYNPRO_LINK = 5.
*화면 분할
  CREATE OBJECT GO_SPLITTER_0100
    EXPORTING
      PARENT  = GO_DOCKING_0100
      ROWS    = 1
      COLUMNS = 2.

  CALL METHOD GO_SPLITTER_0100->GET_CONTAINER
    EXPORTING
      ROW       = 1
      COLUMN    = 1
    RECEIVING
      CONTAINER = GO_CONTAIN_LEFT_0100.

  CREATE OBJECT GO_SPLITTER_LEFT_0100
    EXPORTING
      PARENT  = GO_CONTAIN_LEFT_0100
      ROWS    = 2
      COLUMNS = 1.


  GO_SPLITTER_LEFT_0100->SET_ROW_HEIGHT(
    EXPORTING
      ID                =    1              " Row ID
      HEIGHT            =    6 ).             " Height

** top 컨테이너
  CALL METHOD GO_SPLITTER_LEFT_0100->GET_CONTAINER
    EXPORTING
      ROW       = 1
      COLUMN    = 1
    RECEIVING
      CONTAINER = GO_CONTAIN_TOP_0100.

* bottom 컨테이너
  CALL METHOD GO_SPLITTER_0100->GET_CONTAINER
    EXPORTING
      ROW       = 1
      COLUMN    = 2
    RECEIVING
      CONTAINER = GO_CONTAIN_RIGHT_0100.

  PERFORM SET_WITH_MAIN USING GV_CHK_DETAIL.

  CALL METHOD GO_SPLITTER_LEFT_0100->GET_CONTAINER
    EXPORTING
      ROW       = 2
      COLUMN    = 1
    RECEIVING
      CONTAINER = GO_CONTAIN_0100.

  CREATE OBJECT GO_GRID_0100
    EXPORTING
      I_PARENT      = GO_CONTAIN_0100
      I_APPL_EVENTS = ABAP_TRUE.

  CREATE OBJECT GO_SPLITTER_RIGHT_0100
    EXPORTING
      PARENT  = GO_CONTAIN_RIGHT_0100
      ROWS    = 2
      COLUMNS = 1.

  GO_SPLITTER_RIGHT_0100->SET_ROW_HEIGHT(
    EXPORTING
      ID                =    1              " Row ID
      HEIGHT            =    6 ).             " Height

  CALL METHOD GO_SPLITTER_RIGHT_0100->GET_CONTAINER
    EXPORTING
      ROW       = 1
      COLUMN    = 1
    RECEIVING
      CONTAINER = GO_CONTAIN_TOP_0101.

  CALL METHOD GO_SPLITTER_RIGHT_0100->GET_CONTAINER
    EXPORTING
      ROW       = 2
      COLUMN    = 1
    RECEIVING
      CONTAINER = GO_CONTAIN_0101.

  CREATE OBJECT GO_GRID_0101
    EXPORTING
      I_PARENT      = GO_CONTAIN_0101
      I_APPL_EVENTS = ABAP_TRUE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_TITLE_SCREEN100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- PO_DYNDOC_ID
*&---------------------------------------------------------------------*
FORM SET_TITLE_SCREEN100  CHANGING PO_DYNDOC_ID  TYPE REF TO  CL_DD_DOCUMENT.

  DATA : LV_TEXT(255) TYPE C.
  DATA : LV_FR_SPMON(10).
  DATA : LV_TO_SPMON(10).

* 플랜트명
  CLEAR LV_TEXT.
  IF P_NAME1 IS INITIAL.
    SELECT SINGLE NAME1 INTO P_NAME1
             FROM T001W
            WHERE WERKS EQ P_WERKS.
  ENDIF.
  IF P_DESCR IS INITIAL.
    SELECT SINGLE DESCR INTO P_DESCR
         FROM ZPPT0107
        WHERE SPGCD EQ P_SPGCD.
  ENDIF.

  LV_TEXT = P_NAME1 && '(' && P_DESCR && ')'.
  CONCATENATE '공급플랜트 :' LV_TEXT INTO LV_TEXT SEPARATED BY SPACE.

  "텍스트 추가
  CALL METHOD PO_DYNDOC_ID->ADD_TEXT
    EXPORTING
      TEXT         = LV_TEXT
      SAP_FONTSIZE = '20'.

  CALL METHOD PO_DYNDOC_ID->NEW_LINE.

* 기간
  CLEAR LV_TEXT.
  IF S_SPMON-LOW = S_SPMON-HIGH.
    LV_FR_SPMON = S_SPMON-LOW+0(4) &&'.' && S_SPMON-LOW+4(2).
    CONCATENATE '계획기간 :' LV_FR_SPMON INTO LV_TEXT SEPARATED BY SPACE.
  ELSE.
    .LV_FR_SPMON = S_SPMON-LOW+0(4) &&'.' && S_SPMON-LOW+4(2).
    .LV_TO_SPMON = S_SPMON-HIGH+0(4) &&'.' && S_SPMON-HIGH+4(2).
    CONCATENATE '계획기간 :' LV_FR_SPMON '~' LV_TO_SPMON INTO LV_TEXT SEPARATED BY SPACE.
  ENDIF.
  "텍스트 추가
  CALL METHOD PO_DYNDOC_ID->ADD_TEXT
    EXPORTING
      TEXT         = LV_TEXT
      SAP_FONTSIZE = '20'.

  CALL METHOD PO_DYNDOC_ID->NEW_LINE.


  "위쪽에 추가한 텍스트 출력
  CALL METHOD PO_DYNDOC_ID->DISPLAY_DOCUMENT
    EXPORTING
      PARENT             = GO_CONTAIN_TOP_0100
      REUSE_CONTROL      = ABAP_TRUE
      REUSE_REGISTRATION = ABAP_TRUE.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_DATA .

  DATA : LV_DISPO TYPE MARC-DISPO.
  DATA : LT_MAIN LIKE TABLE OF GS_MAIN.
  DATA : LS_MAIN LIKE GS_MAIN.
  DATA : LV_INDEX TYPE I.
  DATA : LV_ZSEQ TYPE I.
  DATA : LV_MAX_ZSEQ TYPE I.
  DATA : LT_2160 TYPE TABLE OF ZGTPPT2160.

  LV_DISPO = P_SPGCD && '%'.
*  모수대상 추출
  SELECT MATNR FROM MARC
    INTO TABLE @DATA(LT_MARC_CHK)
   WHERE DISPO LIKE @LV_DISPO
      AND WERKS EQ @P_WERKS
      AND MATNR IN @S_MATNR
      AND LVORM = ''
      AND MMSTA = ''
      AND EISBE <> ''
      AND EISLO <> ''.

  IF LT_MARC_CHK[] IS NOT INITIAL.
    SELECT WERKS, MATNR FROM MARC
      INTO TABLE @DATA(LT_MARC)
       FOR ALL ENTRIES IN @LT_MARC_CHK
     WHERE WERKS IN @GR_WERKS
        AND MATNR EQ @LT_MARC_CHK-MATNR
        AND LVORM = ''
        AND MMSTA = ''.
    SORT LT_MARC BY WERKS MATNR.
    DELETE ADJACENT DUPLICATES FROM LT_MARC COMPARING WERKS MATNR.
  ENDIF.

  IF LT_MARC[] IS INITIAL.
    MESSAGE S001 DISPLAY LIKE 'E'.
    LEAVE LIST-PROCESSING.
  ENDIF.


  SELECT * FROM ZGTPPT2160 INTO TABLE GT_2160
    WHERE PDWRK = P_WERKS
      AND SPGCD = P_SPGCD
      AND RQWRK IN GR_WERKS
      AND MATNR IN S_MATNR
      AND RQMON IN S_SPMON.

* 등급(특성값으로 조회) - 특성값 변경으로 하드코딩으로 구성
*  SELECT A~ATNAM, B~ATWRT
*      FROM CABN AS A
*      INNER JOIN CAWN AS B ON B~ATINN = A~ATINN
*    WHERE A~ATNAM = 'PD_AA_GRADE_TEST'
*      INTO TABLE @DATA(LT_GRADE).
  DATA : BEGIN OF LS_GRADE ,
           ATNAM TYPE CABN-ATNAM,
           ATWRT TYPE CAWN-ATWRT,
         END OF LS_GRADE.
  DATA : LT_GRADE LIKE TABLE OF LS_GRADE.

  DEFINE __SET_ATWRT.
    CLEAR LS_GRADE.
    LS_GRADE-ATNAM = &1.
    LS_GRADE-ATWRT = &2.
    APPEND LS_GRADE TO LT_GRADE.
  END-OF-DEFINITION.

  __SET_ATWRT : 'Grade 1' 'G1',
                     'Grade 2' 'G2',
                     'Grade 3' 'G3',
                     'Grade 4' 'G4'.

* 높은 등급순으로 정렬
  SORT LT_GRADE BY ATWRT DESCENDING.

  REFRESH GT_MAIN.
  FREE GT_MAIN.

  SORT GT_2151 BY MATNR.

  LOOP AT LT_MARC INTO DATA(LS_MATNR).
    CLEAR LS_MAIN.
    LS_MAIN-WERKS = LS_MATNR-WERKS.
    LS_MAIN-MATNR = LS_MATNR-MATNR.
    LS_MAIN-MAKTX = ZGTPP_CL_COMMON=>GET_MAKTX( IV_MATNR = LS_MAIN-MATNR ).
    LS_MAIN-MEINS = 'KG'.
    LS_MAIN-DETAIL = ICON_DETAIL.

    READ TABLE GT_2151 TRANSPORTING NO FIELDS WITH KEY MATNR = LS_MATNR-MATNR BINARY SEARCH.
    IF SY-SUBRC EQ 0. " 등급관리 테이블 등급 적용.
      CLEAR LV_INDEX.
      LOOP AT LT_GRADE INTO LS_GRADE.
        CLEAR : LV_ZSEQ, LV_MAX_ZSEQ.
        LV_INDEX = SY-TABIX.
        LS_MAIN-SEQ_ATWRT = LV_INDEX.
        LS_MAIN-ATWRT = LS_GRADE-ATWRT.

        PERFORM GET_MAX_SEQ TABLES LT_2160 USING LS_MAIN CHANGING LV_MAX_ZSEQ.

        DO.
          IF LV_ZSEQ = 0.
            LS_MAIN-ZSEQ = LV_ZSEQ.
            APPEND LS_MAIN TO GT_MAIN.
          ELSE.
            READ TABLE LT_2160 TRANSPORTING NO FIELDS WITH KEY ZSEQ = LV_ZSEQ.
            IF SY-SUBRC EQ 0.
              LS_MAIN-ZSEQ = LV_ZSEQ.
              APPEND LS_MAIN TO GT_MAIN.
            ENDIF.
          ENDIF.

          IF LV_ZSEQ = LV_MAX_ZSEQ.
            EXIT.
          ELSE.
            ADD 1 TO LV_ZSEQ.
          ENDIF.
        ENDDO.

      ENDLOOP.
    ELSE.
      CLEAR : LV_ZSEQ, LV_MAX_ZSEQ.

      LS_MAIN-SEQ_ATWRT = 9.
      LS_MAIN-ATWRT = ''.

      PERFORM GET_MAX_SEQ TABLES LT_2160 USING LS_MAIN CHANGING LV_MAX_ZSEQ.

      DO.

        IF LV_ZSEQ = 0.
          LS_MAIN-ZSEQ = LV_ZSEQ.
          APPEND LS_MAIN TO GT_MAIN.
        ELSE.
          READ TABLE LT_2160 TRANSPORTING NO FIELDS WITH KEY ZSEQ = LV_ZSEQ.
          IF SY-SUBRC EQ 0.
            LS_MAIN-ZSEQ = LV_ZSEQ.
            APPEND LS_MAIN TO GT_MAIN.
          ENDIF.
        ENDIF.

        IF LV_ZSEQ = LV_MAX_ZSEQ.
          EXIT.
        ELSE.
          ADD 1 TO LV_ZSEQ.
        ENDIF.
      ENDDO.
    ENDIF.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_DISP_TABLE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_DISP_TABLE .

  DATA : LO_WA TYPE REF TO DATA.
  DATA : LV_FIELDNAME TYPE FIELDNAME.
  DATA : LV_NUM_C(2) TYPE C.
  DATA : LV_OVERDUE   LIKE AFPO-PSAMG.
  FIELD-SYMBOLS : <LS_MAIN> TYPE ANY.
  FIELD-SYMBOLS : <LV_VALUE> TYPE ANY.

  CREATE DATA LO_WA LIKE LINE OF <GT_MAIN_DISP_100>.
  ASSIGN LO_WA->* TO <LS_MAIN>.

  REFRESH <GT_MAIN_DISP_100>.

  LOOP AT GT_MAIN INTO GS_MAIN.
    CLEAR <LS_MAIN>.
    MOVE-CORRESPONDING GS_MAIN TO <LS_MAIN>.

    CLEAR LV_OVERDUE.
* 요청수량
    LOOP AT GT_2160 INTO DATA(LS_2160) WHERE RQWRK = GS_MAIN-WERKS
                                                             AND  MATNR = GS_MAIN-MATNR
                                                             AND  SCRGRADE = GS_MAIN-ATWRT
                                                             AND  ZSEQ = GS_MAIN-ZSEQ.

      IF LS_2160-RQMON IN GR_SPMON.
        CLEAR GS_SPMON.
        READ TABLE GT_SPMON INTO GS_SPMON WITH KEY SPMON = LS_2160-RQMON.
        IF SY-SUBRC EQ 0.
          IF <LV_VALUE> IS ASSIGNED. UNASSIGN <LV_VALUE>. ENDIF.
          ASSIGN COMPONENT GS_SPMON-FIELDNAME_A OF STRUCTURE <LS_MAIN> TO <LV_VALUE>.
          <LV_VALUE> = LS_2160-RQMNG.
          ADD LS_2160-RQMNG TO LV_OVERDUE.

          IF LS_2160-EBELN IS NOT INITIAL..
            SELECT SINGLE EBELN, EBELP FROM EKPO
              INTO @DATA(LS_EKPO)
              WHERE EBELN = @LS_2160-EBELN
              AND EBELP = @LS_2160-EBELP.
            IF SY-SUBRC EQ 0.
              IF <LV_VALUE> IS ASSIGNED. UNASSIGN <LV_VALUE>. ENDIF.
              ASSIGN COMPONENT GS_SPMON-FIELDNAME_A_CHK OF STRUCTURE <LS_MAIN> TO <LV_VALUE>.

              SELECT SINGLE EBELN, EBELP,
                         SUM(
                         CASE SHKZG WHEN 'S' THEN MENGE
                                          WHEN 'H' THEN MENGE * -1
                            END ) AS MENGE
                   FROM MSEG
                  WHERE EBELN = @LS_2160-EBELN
                  AND EBELP = @LS_2160-EBELP
                  GROUP BY EBELN, EBELP
                  INTO @DATA(LS_CHK_MENGE).

              IF SY-SUBRC EQ 0 AND LS_CHK_MENGE-MENGE > 0.
                <LV_VALUE> = 'C'.
              ELSE.
                <LV_VALUE> = ABAP_TRUE.
              ENDIF.
            ENDIF.

          ENDIF.

          IF LS_2160-RQMON = S_SPMON-LOW(6).
            IF <LV_VALUE> IS ASSIGNED. UNASSIGN <LV_VALUE>. ENDIF.
            ASSIGN COMPONENT 'ZREMARK' OF STRUCTURE <LS_MAIN> TO <LV_VALUE>.
            <LV_VALUE> = LS_2160-ZREMARK.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDLOOP.

    IF <LV_VALUE> IS ASSIGNED. UNASSIGN <LV_VALUE>. ENDIF.
    ASSIGN COMPONENT 'OVERDUE' OF STRUCTURE <LS_MAIN> TO <LV_VALUE>.
    IF <LV_VALUE> IS ASSIGNED.
      <LV_VALUE> = LV_OVERDUE.
    ENDIF.

** 공급수량 -
*    LOOP AT GT_2170 INTO DATA(LS_2170) WHERE RQWRK = GS_MAIN-WERKS
*                                                              AND MATNR = GS_MAIN-MATNR
*                                                              AND SCRGRADE = GS_MAIN-ATWRT.
*
*      IF LS_2170-EINDT+0(6) IN GR_SPMON.
*        CLEAR GS_SPMON.
*        READ TABLE GT_SPMON INTO GS_SPMON WITH KEY SPMON = LS_2170-EINDT+0(6).
*        IF SY-SUBRC EQ 0.
*          IF <LV_VALUE> IS ASSIGNED. UNASSIGN <LV_VALUE>. ENDIF.
*          ASSIGN COMPONENT GS_SPMON-FIELDNAME_B OF STRUCTURE <LS_MAIN> TO <LV_VALUE>.
*          ADD LS_2170-MENGE  TO <LV_VALUE>.
*        ENDIF.
*      ENDIF.
*    ENDLOOP.

    APPEND <LS_MAIN> TO <GT_MAIN_DISP_100>.

  ENDLOOP.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form DATA_CHANGED
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> SENDER
*&      --> ER_DATA_CHANGED
*&      --> E_ONF4
*&      --> E_UCOMM
*&---------------------------------------------------------------------*
FORM DATA_CHANGED  USING    P_SENDER  TYPE REF TO CL_GUI_ALV_GRID
                                PO_DATA_CHANGED TYPE REF TO
                                          CL_ALV_CHANGED_DATA_PROTOCOL
                                PE_ONF4
                                PE_UCOMM.

  DATA: LS_MOD_CELLS TYPE LVC_S_MODI.
  DATA : LV_NUM(2) TYPE N.
  DATA : LV_CHK_ERR.
  DATA : LV_CHK_AVAILABLE.
  DATA : LV_CHK_CHANGE_101.
  DATA : LV_TOT_PSAMG TYPE AFPO-PSAMG.
  DATA : LV_TOT_PSAMG_C TYPE CHAR30.
  DATA : LV_CHK_PSAMG TYPE AFPO-PSAMG.
  DATA : LV_MESSAGE TYPE CHAR50.
  FIELD-SYMBOLS : <LV_VALUE> TYPE ANY.

  DEFINE __SET_ERR_MSG.
    lv_chk_err = abap_true.
    po_data_changed->add_protocol_entry(
        i_msgid     = 'ZGTPP00'                 " Message ID
        i_msgty     = 'E'                 " Message Type
        i_msgno     =  '03'                " Message No.
        i_msgv1     =  &1                " Message Variable1
        i_fieldname =  &2                " Field Name
        i_row_id    =  ls_mod_cells-row_id ).                " RowID
  END-OF-DEFINITION.

  DEFINE __MODI_CELL.
    po_data_changed->modify_cell(
      i_row_id     = ls_mod_cells-row_id               " Row ID
      i_fieldname = &1                 " Field Name
      i_value       = &2 ).               " Value
  END-OF-DEFINITION.

  CASE P_SENDER.
    WHEN GO_GRID_0100.
      GV_CHK_EDIT = ABAP_TRUE.
      LOOP AT PO_DATA_CHANGED->MT_GOOD_CELLS INTO LS_MOD_CELLS.
        READ TABLE GT_SPMON INTO GS_SPMON WITH KEY FIELDNAME_A = LS_MOD_CELLS-FIELDNAME.
        IF SY-SUBRC EQ 0.
          READ TABLE <GT_MAIN_DISP_100> ASSIGNING FIELD-SYMBOL(<LS_MAIN>) INDEX LS_MOD_CELLS-ROW_ID.
          MOVE-CORRESPONDING <LS_MAIN> TO GS_MAIN.
          PERFORM CHK_MENGE_OF_DETAIL CHANGING LV_TOT_PSAMG LV_CHK_AVAILABLE.
          IF LV_CHK_AVAILABLE = ABAP_TRUE.
            LV_CHK_ERR = ABAP_TRUE.
            READ TABLE GT_FIELDCAT_0100 INTO DATA(LS_FCAT) WITH KEY FIELDNAME = LS_MOD_CELLS-FIELDNAME.
            LV_MESSAGE = | { LS_FCAT-COLTEXT } 요청수량 변경을 할 수 없습니다.|.
            __SET_ERR_MSG LV_MESSAGE LS_MOD_CELLS-FIELDNAME.
          ELSE.

            IF LV_TOT_PSAMG > 0.
              LV_CHK_PSAMG = LS_MOD_CELLS-VALUE.
              IF LV_CHK_PSAMG < LV_TOT_PSAMG.
                LV_CHK_ERR = ABAP_TRUE.
                WRITE LV_TOT_PSAMG TO LV_TOT_PSAMG_C UNIT 'EA'.
                CONDENSE LV_TOT_PSAMG_C.
                READ TABLE GT_FIELDCAT_0100 INTO LS_FCAT WITH KEY FIELDNAME = LS_MOD_CELLS-FIELDNAME.

                LV_MESSAGE = | { LS_FCAT-COLTEXT }수량 변경은 { LV_TOT_PSAMG_C } 보다 커야합니다.|.

                __SET_ERR_MSG LV_MESSAGE LS_MOD_CELLS-FIELDNAME.
              ENDIF.
            ENDIF.
          ENDIF.

* 변경상태 정상의 경우 체인지 플레그 찍어준다.
          IF LV_CHK_ERR IS INITIAL.
            __MODI_CELL GS_SPMON-FIELDNAME_A_CHK 'U'.
          ENDIF.

        ENDIF.

        IF LS_MOD_CELLS-FIELDNAME = 'ZREMARK'.
          READ TABLE <GT_MAIN_DISP_100> ASSIGNING <LS_MAIN> INDEX LS_MOD_CELLS-ROW_ID.

          READ TABLE GT_SPMON INTO GS_SPMON WITH KEY SPMON = S_SPMON-LOW.
          IF <LV_VALUE> IS ASSIGNED. UNASSIGN <LV_VALUE>. ENDIF.
          ASSIGN COMPONENT GS_SPMON-FIELDNAME_A OF STRUCTURE <LS_MAIN> TO <LV_VALUE>.
          IF <LV_VALUE> NE 0.
            __MODI_CELL 'CHG_REMARK' 'U'.
          ELSE.

            IF LS_MOD_CELLS-VALUE IS INITIAL.
              CONTINUE.
            ENDIF.

            LV_MESSAGE = | 계획 시작월({ S_SPMON-LOW })에 입력된 수량이 없습니다.|.
            __SET_ERR_MSG LV_MESSAGE LS_MOD_CELLS-FIELDNAME.
          ENDIF.
        ENDIF.

      ENDLOOP.
    WHEN GO_GRID_0101.
      LV_CHK_CHANGE_101 = ABAP_TRUE.
      LOOP AT PO_DATA_CHANGED->MT_GOOD_CELLS INTO LS_MOD_CELLS.
        CASE LS_MOD_CELLS-FIELDNAME.
          WHEN 'PSAMG_R'.
            __MODI_CELL 'CAL_MARK' ICON_MASS_CHANGE.
        ENDCASE.
      ENDLOOP.
  ENDCASE.

  IF LV_CHK_ERR IS NOT INITIAL.
    PO_DATA_CHANGED->DISPLAY_PROTOCOL( ).
  ENDIF.

  IF LV_CHK_CHANGE_101 IS NOT INITIAL.
    CALL FUNCTION 'SAPGUI_SET_FUNCTIONCODE'
      EXPORTING
        FUNCTIONCODE           = 'CHANGE_101'              " Function code
      EXCEPTIONS
        FUNCTION_NOT_SUPPORTED = 1                " Not supported on this front end platform
        OTHERS                 = 2.
    IF SY-SUBRC <> 0.
    ENDIF.
  ENDIF.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form SAVE_PLAN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SAVE_PLAN .

  DATA : LS_2160 TYPE ZGTPPT2160.
  DATA : LT_SAVE_2161 TYPE TABLE OF ZGTPPT2161.
  DATA : LT_ORIGN_2161 TYPE TABLE OF ZGTPPT2161.
  DATA : LT_TEMP_2161 TYPE TABLE OF ZGTPPT2161.
  DATA : LT_SAVE_2160 TYPE TABLE OF ZGTPPT2160.
  DATA : LT_ORIGN_2160 TYPE TABLE OF ZGTPPT2160.
  DATA : LT_TEMP_2160 TYPE TABLE OF ZGTPPT2160.
  DATA : LT_MAIN_101 LIKE TABLE OF GS_MAIN_101.
  DATA : LT_BACKUP_101 LIKE TABLE OF GS_MAIN_101.
  DATA : LV_TOT_PSAMG TYPE AFPO-PSAMG.
  DATA : LV_CHK_ERR.
  DATA : LV_CHK_DIFF.

  FIELD-SYMBOLS <LV_RQMNG> TYPE ANY.
  FIELD-SYMBOLS <LV_RQMNG_CHK> TYPE ANY.
  FIELD-SYMBOLS <LV_VALUE> TYPE ANY.
  FIELD-SYMBOLS <LV_CHECK> TYPE ANY.

  DEFINE _SET_FIELD_ASSIGN.
    IF <LV_VALUE> IS ASSIGNED. UNASSIGN <LV_VALUE>. ENDIF.
    ASSIGN COMPONENT GS_SPMON-FIELDNAME_A OF STRUCTURE <LS_MAIN> TO <LV_VALUE>.
    IF <LV_CHECK> IS ASSIGNED. UNASSIGN <LV_CHECK>. ENDIF.
    ASSIGN COMPONENT GS_SPMON-FIELDNAME_A_CHK OF STRUCTURE <LS_MAIN> TO <LV_CHECK>.
  END-OF-DEFINITION.

  IF GV_CHK_EDIT_101 = ABAP_TRUE.
    LT_BACKUP_101 = GT_MAIN_101.
  ENDIF.

  LOOP AT <GT_MAIN_DISP_100> ASSIGNING FIELD-SYMBOL(<LS_MAIN>).
    CLEAR GS_MAIN.
    MOVE-CORRESPONDING <LS_MAIN> TO GS_MAIN.

*  현재 상세화면이 수정중인 상태일시
    IF GS_MAIN-MATNR = GS_DISP_HEADER_101-MATNR AND
      GS_MAIN-ATWRT = GS_DISP_HEADER_101-ATWRT AND
      GS_MAIN-ZSEQ = GS_DISP_HEADER_101-ZSEQ AND
      GV_CHK_EDIT_101 = ABAP_TRUE.

*    ZGTPPT2160 원본 원장
      REFRESH LT_TEMP_2160.
      PERFORM GET_ORIGN_2160 TABLES LT_TEMP_2160 USING GS_MAIN.
      IF LT_TEMP_2160[] IS NOT INITIAL.
        IF GV_DISP_SPMON NE '000000'.
          DELETE LT_TEMP_2160 WHERE RQMON NE GV_DISP_SPMON.
        ENDIF.

        APPEND LINES OF LT_TEMP_2160 TO LT_ORIGN_2160.
      ENDIF.

*    ZGTPPT2161 원본 원장
      PERFORM GET_DAILY_REQ.
      IF GV_DISP_SPMON NE '000000'.
        REFRESH LT_TEMP_2161.
        LT_TEMP_2161 = GT_2161.
        DELETE LT_TEMP_2161 WHERE RQMON NE GV_DISP_SPMON.
        APPEND LINES OF GT_2161 TO LT_ORIGN_2161.
      ELSE.
        APPEND LINES OF GT_2161 TO LT_ORIGN_2161.
      ENDIF.

      LOOP AT GT_SPMON INTO GS_SPMON.

        IF GV_DISP_SPMON NE '000000'.
          IF GV_DISP_SPMON = GS_SPMON-SPMON.

            REFRESH LT_MAIN_101.
            LT_MAIN_101 = VALUE #( FOR LW_MAIN_101 IN LT_BACKUP_101 WHERE ( SPMON = GS_SPMON-SPMON )
                                            ( CORRESPONDING #( LW_MAIN_101 ) ) ).

            CLEAR LV_TOT_PSAMG.
            IF <LV_RQMNG> IS ASSIGNED. UNASSIGN <LV_RQMNG>. ENDIF.
            ASSIGN COMPONENT GS_SPMON-FIELDNAME_A OF STRUCTURE <LS_MAIN> TO <LV_RQMNG>.
            LV_TOT_PSAMG = <LV_RQMNG>.

            PERFORM SAVE_DETAIL_FR_ITAB TABLES LT_MAIN_101 LT_TEMP_2161
                                                         USING GS_MAIN
                                                     CHANGING LV_CHK_ERR LV_TOT_PSAMG.

            IF <LV_RQMNG_CHK> IS ASSIGNED. UNASSIGN <LV_RQMNG_CHK>. ENDIF.
            ASSIGN COMPONENT GS_SPMON-FIELDNAME_A_CHK OF STRUCTURE <LS_MAIN> TO <LV_RQMNG_CHK>.
            CASE <LV_RQMNG_CHK>.
              WHEN 'C' OR 'X'.
              WHEN OTHERS.

*                IF <LV_RQMNG> NE LV_TOT_PSAMG.
*                  MESSAGE S006 DISPLAY LIKE 'E' WITH GS_SPMON-SPMON '총수량이 상세수량과 같지 않습니다.!'.
*                  RETURN.
*                ENDIF.
            ENDCASE.

*      상세데이터중 해당월 요청 금액 없으면 월테이블 생성 없음.
            IF LT_TEMP_2161[] IS INITIAL.
              CONTINUE.
            ENDIF.

            APPEND LINES OF LT_TEMP_2161 TO LT_SAVE_2161.

            CLEAR LS_2160.
            READ TABLE LT_TEMP_2160 INTO LS_2160 WITH KEY RQMON = GS_SPMON-SPMON.
            PERFORM SET_2160_DATA USING GS_MAIN GS_SPMON-SPMON <LV_RQMNG> CHANGING LS_2160.
            APPEND LS_2160 TO LT_SAVE_2160.
          ELSE.
            CLEAR LS_2160.
            _SET_FIELD_ASSIGN.

            IF <LV_CHECK> = 'U'. " 수정 체크된필드만 저장

*    ZGTPPT2160 원본 원장
              READ TABLE GT_2160 INTO DATA(LS_TEMP_2160) WITH KEY MATNR = GS_MAIN-MATNR
                                                                                       SCRGRADE = GS_MAIN-ATWRT
                                                                                       ZSEQ = GS_MAIN-ZSEQ
                                                                                       RQMON = GS_SPMON-SPMON.
              IF SY-SUBRC EQ 0.
                APPEND LS_TEMP_2160 TO LT_ORIGN_2160.
              ENDIF.

*    ZGTPPT2161 원본 원장
              REFRESH GT_MAIN_101.
              REFRESH LT_TEMP_2161.
              LT_TEMP_2161 = VALUE #( FOR LW_MAIN_2161 IN GT_2161 WHERE ( RQMON = GS_SPMON-SPMON )
                                                 ( CORRESPONDING #( LW_MAIN_2161 ) ) ).
              IF LT_TEMP_2161 IS NOT INITIAL.
                APPEND LINES OF LT_TEMP_2161 TO  LT_ORIGN_2161.
              ENDIF.

              PERFORM COMPARE_MENGE_OF_DAY USING GS_SPMON <LV_VALUE> CHANGING LV_CHK_DIFF.
              PERFORM SET_DISP_TABLE_101 USING GS_SPMON <LV_VALUE> LV_CHK_DIFF.

              REFRESH LT_MAIN_101.
              LT_MAIN_101 = VALUE #( FOR LW_MAIN_101 IN GT_MAIN_101 WHERE ( SPMON = GS_SPMON-SPMON )
                                              ( CORRESPONDING #( LW_MAIN_101 ) ) ).

              CLEAR LV_TOT_PSAMG.
              IF <LV_RQMNG> IS ASSIGNED. UNASSIGN <LV_RQMNG>. ENDIF.
              ASSIGN COMPONENT GS_SPMON-FIELDNAME_A OF STRUCTURE <LS_MAIN> TO <LV_RQMNG>.
              LV_TOT_PSAMG = <LV_RQMNG>.
              PERFORM SAVE_DETAIL_FR_ITAB TABLES LT_MAIN_101 LT_TEMP_2161
                                                           USING GS_MAIN
                                                       CHANGING LV_CHK_ERR LV_TOT_PSAMG.

*      상세데이터중 해당월 요청 금액 없으면 월테이블 생성 없음.
              IF LT_TEMP_2161[] IS INITIAL.
                CONTINUE.
              ENDIF.

              APPEND LINES OF LT_TEMP_2161 TO LT_SAVE_2161.

              CLEAR LS_2160.
              READ TABLE LT_TEMP_2160 INTO LS_2160 WITH KEY RQMON = GS_SPMON-SPMON.
              PERFORM SET_2160_DATA USING GS_MAIN GS_SPMON-SPMON LV_TOT_PSAMG CHANGING LS_2160.
              APPEND LS_2160 TO LT_SAVE_2160.

            ENDIF.
          ENDIF.
        ELSE.
          REFRESH LT_MAIN_101.
          LT_MAIN_101 = VALUE #( FOR LW_MAIN_101 IN LT_BACKUP_101 WHERE ( SPMON = GS_SPMON-SPMON )
                                          ( CORRESPONDING #( LW_MAIN_101 ) ) ).

          CLEAR LV_TOT_PSAMG.
          PERFORM SAVE_DETAIL_FR_ITAB TABLES LT_MAIN_101 LT_TEMP_2161
                                                       USING GS_MAIN
                                                   CHANGING LV_CHK_ERR LV_TOT_PSAMG.

          IF <LV_RQMNG> IS ASSIGNED. UNASSIGN <LV_RQMNG>. ENDIF.
          ASSIGN COMPONENT GS_SPMON-FIELDNAME_A OF STRUCTURE <LS_MAIN> TO <LV_RQMNG>.
          IF <LV_RQMNG_CHK> IS ASSIGNED. UNASSIGN <LV_RQMNG_CHK>. ENDIF.
          ASSIGN COMPONENT GS_SPMON-FIELDNAME_A_CHK OF STRUCTURE <LS_MAIN> TO <LV_RQMNG_CHK>.
          CASE <LV_RQMNG_CHK>.
            WHEN 'C' OR 'X'.
            WHEN OTHERS.

*              IF <LV_RQMNG> NE LV_TOT_PSAMG.
*                MESSAGE S006 DISPLAY LIKE 'E' WITH GS_SPMON-SPMON '총수량이 상세수량과 같지 않습니다.!'.
*                RETURN.
*              ENDIF.
          ENDCASE.

*      상세데이터중 해당월 요청 금액 없으면 월테이블 생성 없음.
          IF LT_TEMP_2161[] IS INITIAL.
            CONTINUE.
          ENDIF.

          APPEND LINES OF LT_TEMP_2161 TO LT_SAVE_2161.

          CLEAR LS_2160.
          READ TABLE LT_TEMP_2160 INTO LS_2160 WITH KEY RQMON = GS_SPMON-SPMON.
          PERFORM SET_2160_DATA USING GS_MAIN GS_SPMON-SPMON LV_TOT_PSAMG CHANGING LS_2160.
          APPEND LS_2160 TO LT_SAVE_2160.
        ENDIF.
      ENDLOOP.

    ELSE. " 기본저장

      PERFORM GET_DAILY_REQ.

      LOOP AT GT_SPMON INTO GS_SPMON.
        CLEAR LS_2160.
        _SET_FIELD_ASSIGN.

        IF <LV_CHECK> = 'U'. " 수정 체크된필드만 저장

*    ZGTPPT2160 원본 원장
          READ TABLE GT_2160 INTO LS_TEMP_2160 WITH KEY RQWRK = GS_MAIN-WERKS
                                                                                  MATNR = GS_MAIN-MATNR
                                                                                  SCRGRADE = GS_MAIN-ATWRT
                                                                                  ZSEQ = GS_MAIN-ZSEQ
                                                                                  RQMON = GS_SPMON-SPMON.
          IF SY-SUBRC EQ 0.
            APPEND LS_TEMP_2160 TO LT_ORIGN_2160.
          ENDIF.

*    ZGTPPT2161 원본 원장
          REFRESH GT_MAIN_101.
          REFRESH LT_TEMP_2161.
          LT_TEMP_2161 = VALUE #( FOR LW_MAIN_2161 IN GT_2161 WHERE ( RQMON = GS_SPMON-SPMON )
                                             ( CORRESPONDING #( LW_MAIN_2161 ) ) ).
          IF LT_TEMP_2161 IS NOT INITIAL.
            APPEND LINES OF LT_TEMP_2161 TO  LT_ORIGN_2161.
          ENDIF.

          PERFORM COMPARE_MENGE_OF_DAY USING GS_SPMON <LV_VALUE> CHANGING LV_CHK_DIFF.
          PERFORM SET_DISP_TABLE_101 USING GS_SPMON <LV_VALUE> LV_CHK_DIFF.

          REFRESH LT_MAIN_101.
          LT_MAIN_101 = VALUE #( FOR LW_MAIN_101 IN GT_MAIN_101 WHERE ( SPMON = GS_SPMON-SPMON )
                                          ( CORRESPONDING #( LW_MAIN_101 ) ) ).

          CLEAR LV_TOT_PSAMG.
          IF <LV_RQMNG> IS ASSIGNED. UNASSIGN <LV_RQMNG>. ENDIF.
          ASSIGN COMPONENT GS_SPMON-FIELDNAME_A OF STRUCTURE <LS_MAIN> TO <LV_RQMNG>.
          LV_TOT_PSAMG = <LV_RQMNG>.

          PERFORM SAVE_DETAIL_FR_ITAB TABLES LT_MAIN_101 LT_TEMP_2161
                                                       USING GS_MAIN
                                                   CHANGING LV_CHK_ERR LV_TOT_PSAMG.

*      상세데이터중 해당월 요청 금액 없으면 월테이블 생성 없음.
          IF LT_TEMP_2161[] IS INITIAL.
            CONTINUE.
          ENDIF.

          APPEND LINES OF LT_TEMP_2161 TO LT_SAVE_2161.

          PERFORM SET_2160_DATA USING GS_MAIN GS_SPMON-SPMON LV_TOT_PSAMG CHANGING LS_TEMP_2160.
          APPEND LS_TEMP_2160 TO LT_SAVE_2160.

        ELSEIF GS_MAIN-CHG_REMARK = 'U' AND GS_SPMON-SPMON = S_SPMON-LOW. " 월 비고란 수정시

*    ZGTPPT2160 원본 원장
          REFRESH LT_TEMP_2160.
          PERFORM GET_ORIGN_2160 TABLES LT_TEMP_2160 USING GS_MAIN.

          CLEAR LS_2160.
          READ TABLE LT_TEMP_2160 INTO LS_2160 WITH KEY RQMON = GS_SPMON-SPMON.
          PERFORM SET_2160_DATA USING GS_MAIN GS_SPMON-SPMON LS_2160-RQMNG CHANGING LS_2160.
          APPEND LS_2160 TO LT_SAVE_2160.
        ENDIF.

      ENDLOOP.
    ENDIF.
  ENDLOOP.

  CLEAR GV_ANSWER.
  PERFORM POPUP_TO_CONFIRM_STEP USING 'N'
    ' '
    '사내이체계획 저장합니다. 계속 진행하시겠습니까?'
    '저장확인'.
  IF GV_ANSWER NE 'J'.
    MESSAGE S003 DISPLAY LIKE 'E' WITH '저장 취소 되었습니다.'.
    RETURN.
  ENDIF.

  IF LT_ORIGN_2160 IS NOT   INITIAL.
    DELETE ZGTPPT2160 FROM TABLE LT_ORIGN_2160.
    IF SY-SUBRC NE 0.
      ROLLBACK WORK.
      MESSAGE S003 DISPLAY LIKE 'E' WITH '사내이체계획 저장 중 오류발생하였습니다.'.
      RETURN.
    ENDIF.
  ENDIF.

  IF LT_SAVE_2160[] IS NOT INITIAL.
    MODIFY ZGTPPT2160 FROM TABLE LT_SAVE_2160.
    IF SY-SUBRC NE 0.
      ROLLBACK WORK.
      MESSAGE S003 DISPLAY LIKE 'E' WITH '사내이체계획 저장 중 오류발생하였습니다.'.
      RETURN.
    ENDIF.
  ENDIF.

  IF LT_ORIGN_2161 IS NOT   INITIAL.
    DELETE ZGTPPT2161 FROM TABLE LT_ORIGN_2161.
    IF SY-SUBRC NE 0.
      ROLLBACK WORK.
      MESSAGE S003 DISPLAY LIKE 'E' WITH '사내이체계획 저장 중 오류발생하였습니다.'.
      RETURN.
    ENDIF.
  ENDIF.

  IF LT_SAVE_2161[] IS NOT INITIAL.
    MODIFY ZGTPPT2161 FROM TABLE LT_SAVE_2161.
    IF SY-SUBRC NE 0.
      ROLLBACK WORK.
      MESSAGE S003 DISPLAY LIKE 'E' WITH '사내이체계획 저장 중 오류발생하였습니다.'.
      RETURN.
    ENDIF.
  ENDIF.

  COMMIT WORK AND WAIT.

* 대상정보 추출.
  PERFORM GET_DATA.

* 대상정보 추출.
  PERFORM SET_DISP_TABLE.

  PERFORM SET_SCREEN_101.
  PERFORM SET_WITH_MAIN USING GV_CHK_DETAIL.

* 화면 초기화
  PERFORM REFRESH_0100.
  PERFORM REFRESH_0101.

  MESSAGE S003 WITH '사내이체계획 저장 완료하였습니다.'.

  CLEAR : GV_CHK_EDIT, GV_CHK_EDIT_101.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_2160_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GS_MAIN
*&      --> <LV_VALUE>
*&      <-- LS_2160
*&---------------------------------------------------------------------*
FORM SET_2160_DATA  USING    PS_MAIN LIKE GS_MAIN
                             PV_SPMON TYPE SPMON
                             PV_MENGE
                    CHANGING PS_2160 TYPE ZGTPPT2160 .

  IF PS_2160 IS INITIAL.
    PS_2160-PDWRK = P_WERKS.
    PS_2160-SPGCD = P_SPGCD.
    PS_2160-RQWRK = PS_MAIN-WERKS.
    PS_2160-MATNR = PS_MAIN-MATNR.
    PS_2160-SCRGRADE = PS_MAIN-ATWRT.
    PS_2160-ZSEQ = PS_MAIN-ZSEQ.
    PS_2160-RQMON = PV_SPMON.
    PS_2160-RQMNG = PV_MENGE.
    PS_2160-MEINS = PS_MAIN-MEINS.
    PS_2160-ERDAT = SY-DATUM.
    PS_2160-ERNAM = SY-UNAME.
  ELSE.
    PS_2160-RQMNG = PV_MENGE.
  ENDIF.

  IF PV_SPMON = S_SPMON-LOW.
    PS_2160-ZREMARK = PS_MAIN-ZREMARK.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form REFRESH_0100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM REFRESH_0100 .

  DATA: LS_SCROLL   TYPE LVC_S_STBL.

  LS_SCROLL-ROW = 'X'.
  LS_SCROLL-COL = 'X'.

  PERFORM SET_CELL_ATTRIBUTE_GRID_0100.
  GO_GRID_0100->SET_FRONTEND_LAYOUT( IS_LAYOUT = GS_LAYOUT_0100 ).

  CALL METHOD GO_GRID_0100->REFRESH_TABLE_DISPLAY
    EXPORTING
      IS_STABLE = LS_SCROLL.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROC_CONFIRM_PLAN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PROC_CONFIRM_PLAN .

*  DATA : LT_CHG_2160 TYPE TABLE OF ZGTPPT2160.
*  DATA : LT_CHG_2161 TYPE TABLE OF ZGTPPT2161.
*  DATA : LT_CHG_MAIN LIKE TABLE OF GS_MAIN_101.
*
*  DATA : LT_ROWS TYPE LVC_T_ROW.
*  DATA : LT_CELLS TYPE LVC_T_CENO.
*  DATA : LV_STRING TYPE STRING.
*  DATA : LV_STRING2 TYPE STRING.
*
*  LV_STRING = | 현재 상태 '계획'만 사내 이체 요청 할 수 있습니다.| .
*  LV_STRING2 = |요청상세의 상태를 확인해 주세요. |.
*
*  GO_GRID_0100->GET_SELECTED_ROWS(
*    IMPORTING
*      ET_INDEX_ROWS = LT_ROWS ). " Indexes of Selected Rows
*
*  DELETE LT_ROWS WHERE INDEX = 0.
*
*  IF LT_ROWS[] IS NOT INITIAL.
*    LOOP AT LT_ROWS INTO DATA(LS_ROWS).
*      APPEND INITIAL LINE TO LT_CELLS ASSIGNING FIELD-SYMBOL(<LS_CELLS>).
*      <LS_CELLS>-ROW_ID = LS_ROWS-INDEX.
*    ENDLOOP.
*    SORT LT_CELLS BY ROW_ID.
*  ELSE.
*    GO_GRID_0100->GET_SELECTED_CELLS_ID(
*          IMPORTING
*           ET_CELLS = LT_CELLS ).                " Cell IDs
*
*    IF LT_CELLS[] IS INITIAL.
*      RETURN.
*    ENDIF.
*
*  ENDIF.
*
** 정합성 확인.  상태'계획' 만 사내이체요청 가능
** 가용한 날짜 필드 인지 확인
*  LOOP AT LT_CELLS INTO DATA(LS_CELLS).
*
*    READ TABLE <GT_MAIN_DISP_100> ASSIGNING FIELD-SYMBOL(<LS_MIAN>) INDEX LS_CELLS-ROW_ID.
*    CLEAR GS_MAIN.
*    MOVE-CORRESPONDING <LS_MIAN> TO GS_MAIN.
*
*    IF LS_CELLS-COL_ID = 0.
*      LOOP AT GT_SPMON INTO GS_SPMON.
*        READ TABLE GT_2160 INTO DATA(LS_2160) WITH KEY RQWRK = GS_MAIN-WERKS
*                                                                      MATNR = GS_MAIN-MATNR
*                                                                      SCRGRADE = GS_MAIN-ATWRT
*                                                                      RQMON = GS_SPMON-SPMON.
*        IF SY-SUBRC EQ 0.
*          CASE LS_2160-RQSTA.
*            WHEN 'F' OR 'R'.
*              CONTINUE.
*          ENDCASE.
*          IF LS_2160-RQMNG NE 0.
*            LS_2160-RQSTA = 'R'.
*            APPEND LS_2160 TO LT_CHG_2160.
*          ENDIF.
*        ENDIF.
*      ENDLOOP.
*    ELSE.
*      READ TABLE GT_FIELDCAT_0100 INTO DATA(LS_FCAT) INDEX LS_CELLS-COL_ID.
*      IF SY-SUBRC EQ 0.
*        READ TABLE GT_SPMON INTO GS_SPMON WITH KEY FIELDNAME_A = LS_FCAT-FIELDNAME.
*        IF SY-SUBRC EQ 0.
*          READ TABLE GT_2160 INTO LS_2160 WITH KEY RQWRK = GS_MAIN-WERKS
*                                                                MATNR = GS_MAIN-MATNR
*                                                                SCRGRADE = GS_MAIN-ATWRT
*                                                                RQMON = GS_SPMON-SPMON.
*          IF SY-SUBRC EQ 0.
*            CASE LS_2160-RQSTA.
*              WHEN 'F' OR 'R'.
*                CONTINUE.
*            ENDCASE.
*            IF LS_2160-RQMNG NE 0.
*              LS_2160-RQSTA = 'R'.
*              APPEND LS_2160 TO LT_CHG_2160.
*            ENDIF.
*          ENDIF.
*        ENDIF.
*      ENDIF.
*    ENDIF.
*
*  ENDLOOP.
*
*  IF LT_CHG_2160[] IS INITIAL.
*    MESSAGE S006 DISPLAY LIKE 'E' WITH '요청할 수 있는 대상이 없습니다.'.
*    RETURN.
*  ENDIF.
*
*  CLEAR GV_ANSWER.
*  PERFORM POPUP_TO_CONFIRM_STEP USING 'N'
*    ' '
*    '공급 플랜트로 사내 이체 요청하시겠습니까?'
*    '요청 확인'.
*  IF GV_ANSWER NE 'J'.
*    MESSAGE S003 DISPLAY LIKE 'E' WITH '작업 취소 되었습니다.'.
*    RETURN.
*  ENDIF.
*
*  SELECT B~*
*    FROM @LT_CHG_2160 AS A
*    INNER JOIN ZGTPPT2161 AS B ON B~PDWRK = A~PDWRK
*                                     AND B~SPGCD = A~SPGCD
*                                     AND B~RQWRK = A~RQWRK
*                                     AND B~MATNR = A~MATNR
*                                     AND B~SCRGRADE = A~SCRGRADE
*                                     AND B~RQMON = A~RQMON
*    INTO TABLE @LT_CHG_2161.
*
*  LOOP AT LT_CHG_2161 ASSIGNING FIELD-SYMBOL(<LS_2161>).
*    <LS_2161>-RQSTA = 'R'.
*  ENDLOOP.
*
*  MODIFY ZGTPPT2160 FROM TABLE LT_CHG_2160.
*  IF SY-SUBRC NE 0.
*    ROLLBACK WORK.
*    MESSAGE S003 DISPLAY LIKE 'E' WITH '사내이체가 오류로 요청되지 않았습니다.'.
*    RETURN.
*  ENDIF.
*
*  IF LT_CHG_2161[] IS NOT INITIAL.
*    MODIFY ZGTPPT2161 FROM TABLE LT_CHG_2161.
*    IF SY-SUBRC NE 0.
*      ROLLBACK WORK.
*      MESSAGE S003 DISPLAY LIKE 'E' WITH '사내이체가 오류로 요청되지 않았습니다.'.
*      RETURN.
*    ENDIF.
*  ENDIF.
*
*  COMMIT WORK AND WAIT.
*
** 화면 초기화
*  PERFORM SET_SCREEN_101.
*  PERFORM SET_WITH_MAIN USING GV_CHK_DETAIL.
*  PERFORM REFRESH_0101.
*
*  MESSAGE S003 WITH '사내 이체 요청되었습니다.'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROC_CANCEL_PLAN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PROC_CANCEL_PLAN .

*  DATA : LT_CHG_2160 TYPE TABLE OF ZGTPPT2160.
*  DATA : LT_CHG_2161 TYPE TABLE OF ZGTPPT2161.
*  DATA : LT_CHG_MAIN LIKE TABLE OF GS_MAIN_101.
*
*  DATA : LT_ROWS TYPE LVC_T_ROW.
*  DATA : LT_CELLS TYPE LVC_T_CENO.
*  DATA : LV_STRING TYPE STRING.
*  DATA : LV_STRING2 TYPE STRING.
*
*  LV_STRING = | 현재 상태 '요청'만 사내이체 요청 취소 할 수 있습니다.| .
*  LV_STRING2 = |월 수량의 상태를 확인해 주세요. |.
*
*  GO_GRID_0100->GET_SELECTED_ROWS(
*    IMPORTING
*      ET_INDEX_ROWS = LT_ROWS ). " Indexes of Selected Rows
*
*  DELETE LT_ROWS WHERE INDEX = 0.
*
*  IF LT_ROWS[] IS NOT INITIAL.
*    LOOP AT LT_ROWS INTO DATA(LS_ROWS).
*      APPEND INITIAL LINE TO LT_CELLS ASSIGNING FIELD-SYMBOL(<LS_CELLS>).
*      <LS_CELLS>-ROW_ID = LS_ROWS-INDEX.
*    ENDLOOP.
*    SORT LT_CELLS BY ROW_ID.
*  ELSE.
*    GO_GRID_0100->GET_SELECTED_CELLS_ID(
*          IMPORTING
*           ET_CELLS = LT_CELLS ).                " Cell IDs
*
*    IF LT_CELLS[] IS INITIAL.
*      RETURN.
*    ENDIF.
*  ENDIF.
*
** 정합성 확인.  상태'요청' 만 사내이체요청 취소 가능
** 가용한 날짜 필드 인지 확인
*  LOOP AT LT_CELLS INTO DATA(LS_CELLS).
*
*    READ TABLE <GT_MAIN_DISP_100> ASSIGNING FIELD-SYMBOL(<LS_MIAN>) INDEX LS_CELLS-ROW_ID.
*    CLEAR GS_MAIN.
*    MOVE-CORRESPONDING <LS_MIAN> TO GS_MAIN.
*
*    IF LS_CELLS-COL_ID = 0.
*      LOOP AT GT_SPMON INTO GS_SPMON.
*        READ TABLE GT_2160 INTO DATA(LS_2160) WITH KEY RQWRK = GS_MAIN-WERKS
*                                                                      MATNR = GS_MAIN-MATNR
*                                                                      SCRGRADE = GS_MAIN-ATWRT
*                                                                      RQMON = GS_SPMON-SPMON.
*        IF SY-SUBRC EQ 0.
*          CASE LS_2160-RQSTA.
*            WHEN 'R'.
*            WHEN OTHERS.
*              CONTINUE.
*          ENDCASE.
*          IF LS_2160-RQMNG NE 0.
*            LS_2160-RQSTA = 'C'.
*            APPEND LS_2160 TO LT_CHG_2160.
*          ENDIF.
*        ENDIF.
*      ENDLOOP.
*    ELSE.
*      READ TABLE GT_FIELDCAT_0100 INTO DATA(LS_FCAT) INDEX LS_CELLS-COL_ID.
*      IF SY-SUBRC EQ 0.
*        READ TABLE GT_SPMON INTO GS_SPMON WITH KEY FIELDNAME_A = LS_FCAT-FIELDNAME.
*        IF SY-SUBRC EQ 0.
*          READ TABLE GT_2160 INTO LS_2160 WITH KEY RQWRK = GS_MAIN-WERKS
*                                                                MATNR = GS_MAIN-MATNR
*                                                                SCRGRADE = GS_MAIN-ATWRT
*                                                                RQMON = GS_SPMON-SPMON.
*          IF SY-SUBRC EQ 0.
*            CASE LS_2160-RQSTA.
*              WHEN 'R'.
*              WHEN OTHERS.
*                CONTINUE.
*            ENDCASE.
*            IF LS_2160-RQMNG NE 0.
*              LS_2160-RQSTA = 'C'.
*              APPEND LS_2160 TO LT_CHG_2160.
*            ENDIF.
*          ENDIF.
*        ENDIF.
*      ENDIF.
*    ENDIF.
*
*  ENDLOOP.
*
*  IF LT_CHG_2160[] IS INITIAL.
*    MESSAGE S006 DISPLAY LIKE 'E' WITH '사내이체 요청 취소할 수 있는 대상이 없습니다.'.
*    RETURN.
*  ENDIF.
*
*  CLEAR GV_ANSWER.
*  PERFORM POPUP_TO_CONFIRM_STEP USING 'N'
*    ' '
*    '사내이체 요청 취소하시겠습니까?'
*    '취소 확인'.
*  IF GV_ANSWER NE 'J'.
*    MESSAGE S003 DISPLAY LIKE 'E' WITH '작업 취소 되었습니다.'.
*    RETURN.
*  ENDIF.
*
*  SELECT B~*
*    FROM @LT_CHG_2160 AS A
*    INNER JOIN ZGTPPT2161 AS B ON B~PDWRK = A~PDWRK
*                                     AND B~SPGCD = A~SPGCD
*                                     AND B~RQWRK = A~RQWRK
*                                     AND B~MATNR = A~MATNR
*                                     AND B~SCRGRADE = A~SCRGRADE
*                                     AND B~RQMON = A~RQMON
*    INTO TABLE @LT_CHG_2161.
*
*  LOOP AT LT_CHG_2161 ASSIGNING FIELD-SYMBOL(<LS_2161>).
*    <LS_2161>-RQSTA = 'C'.
*  ENDLOOP.
*
*  MODIFY ZGTPPT2161 FROM TABLE LT_CHG_2161.
*  IF SY-SUBRC NE 0.
*    ROLLBACK WORK.
*    MESSAGE S003 DISPLAY LIKE 'E' WITH '사내이체 요청 취소가 오류로 취소되지 않았습니다.'.
*    RETURN.
*  ENDIF.
*
*  IF LT_CHG_2161[] IS NOT INITIAL.
*    MODIFY ZGTPPT2161 FROM TABLE LT_CHG_2161.
*    IF SY-SUBRC NE 0.
*      ROLLBACK WORK.
*      MESSAGE S003 DISPLAY LIKE 'E' WITH '사내이체 요청 취소가 오류로 취소되지 않았습니다.'.
*      RETURN.
*    ENDIF.
*  ENDIF.
*
*  COMMIT WORK AND WAIT.
*
** 화면 초기화
*  PERFORM SET_SCREEN_101.
*  PERFORM SET_WITH_MAIN USING GV_CHK_DETAIL.
*  PERFORM REFRESH_0101.
*
*  MESSAGE S003 WITH '사내이체 요청 취소되었습니다.'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_with_main
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GV_CHK_DETAIL
*&---------------------------------------------------------------------*
FORM SET_WITH_MAIN  USING    PV_CHK_DETAIL.

  IF PV_CHK_DETAIL = ABAP_TRUE.
    GO_SPLITTER_0100->SET_COLUMN_WIDTH(
      EXPORTING
        ID                = 1                 " Column ID
        WIDTH             =  50                " NPlWidth
      EXCEPTIONS
        CNTL_ERROR        = 1                " See CL_GUI_CONTROL
        CNTL_SYSTEM_ERROR = 2                " See CL_GUI_CONTROL
        OTHERS            = 3 ).
    IF SY-SUBRC <> 0.
      MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
        WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.
  ELSE.
    GO_SPLITTER_0100->SET_COLUMN_WIDTH(
      EXPORTING
        ID                = 1                 " Column ID
        WIDTH             =  100                " NPlWidth
      EXCEPTIONS
        CNTL_ERROR        = 1                " See CL_GUI_CONTROL
        CNTL_SYSTEM_ERROR = 2                " See CL_GUI_CONTROL
        OTHERS            = 3 ).
    IF SY-SUBRC <> 0.
      MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
        WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form HOTSPOT_CLICK
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> SENDER
*&      --> E_ROW
*&      --> E_COLUMN
*&---------------------------------------------------------------------*
FORM HOTSPOT_CLICK  USING    PO_SENDER TYPE REF TO CL_GUI_ALV_GRID
                             PS_ROW TYPE LVC_S_ROW
                             PS_COLUMN TYPE LVC_S_COL.

  DATA : LV_CHK_DIFF.
  DATA : LV_CHK_LINE_EXIST.
  DATA : LS_MAIN_CHK LIKE GS_MAIN.
  FIELD-SYMBOLS : <LV_RQMNG> TYPE ANY.
  CLEAR GV_DISP_SPMON.

  CASE PO_SENDER.
    WHEN GO_GRID_0100.
      CASE PS_COLUMN-FIELDNAME.
        WHEN 'DETAIL'.
          CLEAR LV_CHK_LINE_EXIST.
          LOOP AT <GT_MAIN_DISP_100> ASSIGNING FIELD-SYMBOL(<LS_MAIN_CHK>).
            IF SY-TABIX = PS_ROW-INDEX.
              CONTINUE.
            ENDIF.
            MOVE-CORRESPONDING <LS_MAIN_CHK> TO LS_MAIN_CHK.
            CASE LS_MAIN_CHK-DETAIL.
              WHEN ICON_DISPLAY.
                LS_MAIN_CHK-DETAIL = ICON_DETAIL.
                MOVE-CORRESPONDING LS_MAIN_CHK TO <LS_MAIN_CHK>.
                EXIT.
              WHEN ICON_CHANGE.
                CLEAR GV_ANSWER.
                PERFORM POPUP_TO_CONFIRM_STEP USING 'N'
                  ' '
                  '변경된 상세요청계획이 있습니다. 저장 없이 상세화면 변경하시겠습니까?'
                  '변경확인'.
                IF GV_ANSWER NE 'J'.
                  MESSAGE S003 DISPLAY LIKE 'E' WITH '작업 취소 되었습니다.'.
                  RETURN.
                ENDIF.
                LS_MAIN_CHK-DETAIL = ICON_DETAIL.
                MOVE-CORRESPONDING LS_MAIN_CHK TO <LS_MAIN_CHK>.
                EXIT.
            ENDCASE.
          ENDLOOP.

          READ TABLE <GT_MAIN_DISP_100> ASSIGNING FIELD-SYMBOL(<LS_MAIN>) INDEX PS_ROW-INDEX.
          MOVE-CORRESPONDING <LS_MAIN> TO GS_MAIN.

          CASE GS_MAIN-DETAIL.
            WHEN ICON_DETAIL.
              GV_CHK_DETAIL = ABAP_TRUE.
              REFRESH GT_MAIN_101.
* 월별 입력 수량과 기존 저장된 데일리 요청수량 점검
* --> 해당월 데일리 수량이 없다면 = 'I'
* --> 월별 수량 섬하여 수량이 틀릴경우 = 'C''
* --> 월별 수량 섬하여 수량이 같은경우 = 'S''
              PERFORM GET_DAILY_REQ.
              LOOP AT GT_SPMON INTO GS_SPMON.

                IF <LV_RQMNG> IS ASSIGNED. UNASSIGN <LV_RQMNG>. ENDIF.
                ASSIGN COMPONENT GS_SPMON-FIELDNAME_A OF STRUCTURE <LS_MAIN> TO <LV_RQMNG>.
                PERFORM COMPARE_MENGE_OF_DAY USING GS_SPMON <LV_RQMNG> CHANGING LV_CHK_DIFF.
                PERFORM SET_DISP_TABLE_101 USING GS_SPMON <LV_RQMNG> LV_CHK_DIFF.
                IF LV_CHK_DIFF = 'C' AND GS_SPMON-TODATE >= SY-DATUM.
                  GS_MAIN-DETAIL = ICON_CHANGE.
                  GV_CHK_EDIT_101 = ABAP_TRUE.
                ENDIF.

                IF LV_CHK_DIFF = 'I'  AND GS_SPMON-TODATE >= SY-DATUM AND <LV_RQMNG> NE 0.
                  GV_CHK_EDIT_101 = ABAP_TRUE.
                ENDIF.

              ENDLOOP.

              IF GS_MAIN-DETAIL NE ICON_CHANGE.
                GS_MAIN-DETAIL = ICON_DISPLAY.
              ENDIF.

              CLEAR GS_DISP_HEADER_101.
              MOVE-CORRESPONDING GS_MAIN TO GS_DISP_HEADER_101.

            WHEN ICON_DISPLAY.
              CLEAR GS_DISP_HEADER_101.
              REFRESH GT_MAIN_101.
              FREE GT_MAIN_101.
              CLEAR GV_CHK_EDIT_101.
              CLEAR GV_CHK_DETAIL.

              GS_MAIN-DETAIL = ICON_DETAIL.
            WHEN ICON_CHANGE.
              CLEAR GV_ANSWER.
              PERFORM POPUP_TO_CONFIRM_STEP USING 'N'
                ' '
                '변경된 상세요청계획이 있습니다. 저장 없이 상세화면 종료시겠습니까?'
                '종료확인'.
              IF GV_ANSWER NE 'J'.
                MESSAGE S003 DISPLAY LIKE 'E' WITH '종료 취소 되었습니다.'.
                RETURN.
              ENDIF.

              CLEAR GS_DISP_HEADER_101.
              REFRESH GT_MAIN_101.
              FREE GT_MAIN_101.
              CLEAR GV_CHK_EDIT_101.
              CLEAR GV_CHK_DETAIL.

              GS_MAIN-DETAIL = ICON_DETAIL.

          ENDCASE.

          PERFORM SET_WITH_MAIN USING GV_CHK_DETAIL.
          MOVE-CORRESPONDING GS_MAIN TO <LS_MAIN>.
          PERFORM REFRESH_0100.
          PERFORM REFRESH_0101.

      ENDCASE.
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form COMPARE_MENGE_OF_DAY
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- LV_CHK_DIFF
*&---------------------------------------------------------------------*
FORM COMPARE_MENGE_OF_DAY  USING PS_SPMON LIKE GS_SPMON
                                                        PV_RQMNG TYPE AFPO-PSAMG
                                        CHANGING PV_CHK_DIFF.

  DATA : LV_TOT_PSAMG TYPE AFPO-PSAMG.
  DATA : LV_CHK_INIT.
  LV_CHK_INIT = ABAP_TRUE.


  READ TABLE GT_2160 INTO DATA(LS_2160) WITH KEY RQWRK = GS_MAIN-WERKS
                                                                   MATNR = GS_MAIN-MATNR
                                                                   SCRGRADE = GS_MAIN-ATWRT
                                                                   ZSEQ = GS_MAIN-ZSEQ
                                                                   RQMON = PS_SPMON-SPMON.
  IF SY-SUBRC EQ 0 AND LS_2160-EBELN IS NOT INITIAL.
    PV_CHK_DIFF = 'F'.
    RETURN.
  ENDIF.

  CLEAR LV_TOT_PSAMG.
  LOOP AT GT_2161 INTO DATA(LS_2161) WHERE RQDAY BETWEEN PS_SPMON-FRDATE AND PS_SPMON-TODATE.
    CLEAR LV_CHK_INIT.
    ADD LS_2161-RQMNG TO LV_TOT_PSAMG.
  ENDLOOP.

* 월별 입력 수량과 기존 저장된 데일리 요청수량 점검
* --> 해당월 데일리 수량이 없다면 = 'I'
* --> 월별 수량 섬하여 수량이 틀릴경우 = 'C''
* --> 월별 수량 섬하여 수량이 같은경우 = 'S'
  IF LV_CHK_INIT = ABAP_TRUE.
    PV_CHK_DIFF = 'I'.
  ELSE.
*    PV_CHK_DIFF = 'S'.

    IF PV_RQMNG = LV_TOT_PSAMG.
      PV_CHK_DIFF = 'S'.
    ELSE.
      PV_CHK_DIFF = 'C'.
    ENDIF.
  ENDIF.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_DAILY_REQ
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_DAILY_REQ .

  REFRESH GT_2161.

  SELECT * FROM ZGTPPT2161 INTO TABLE GT_2161
    WHERE PDWRK = P_WERKS
      AND SPGCD = P_SPGCD
      AND RQWRK = GS_MAIN-WERKS
      AND MATNR = GS_MAIN-MATNR
      AND SCRGRADE = GS_MAIN-ATWRT
      AND ZSEQ = GS_MAIN-ZSEQ
      AND RQMON IN GR_SPMON.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_DISP_TABLE_101
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GS_SPMON
*&      --> <LV_RQMNG>
*&      --> LV_CHK_DIFF
*&---------------------------------------------------------------------*
FORM SET_DISP_TABLE_101  USING    PS_SPMON LIKE GS_SPMON
                                                    PV_RQMNG TYPE AFPO-PSAMG
                                                    PV_CHK_DIFF.

  DATA : LV_WORKING_DAYS TYPE I.
  DATA : LV_CAL_MENGE TYPE AFPO-PSAMG.
  DATA : LV_FIXED_MENGE TYPE AFPO-PSAMG.
  DATA : LV_LAST_FIXED_MENGE TYPE AFPO-PSAMG.
  DATA : LV_CUR_DATE TYPE SY-DATUM.
  DATA : LV_LAST_DATE TYPE SY-DATUM.
  DATA : LV_CHK_CONFIRM.
  DATA : LT_MAIN_101 LIKE TABLE OF GS_MAIN_101.
  DATA : LV_CHK_DATE TYPE SY-DATUM.
  DATA : LV_CHK_DUP_DATE TYPE SY-DATUM.

* 출하량
  IF PV_CHK_DIFF = 'F'.
    READ TABLE GT_2160 INTO DATA(LS_2160) WITH KEY RQWRK = GS_MAIN-WERKS
                                                                    MATNR = GS_MAIN-MATNR
                                                                    SCRGRADE = GS_MAIN-ATWRT
                                                                    ZSEQ = GS_MAIN-ZSEQ
                                                                    RQMON = PS_SPMON-SPMON.

    SELECT BUDAT_MKPF,
               SUM(
               CASE BWART WHEN '351' THEN MENGE
                                WHEN '352' THEN MENGE * -1
                  END ) AS MENGE
         FROM MSEG
        WHERE EBELN = @LS_2160-EBELN
        AND EBELP = @LS_2160-EBELP
        AND WERKS = @P_WERKS
        AND BWART IN ( '351', '352' )
        AND BUDAT_MKPF BETWEEN @PS_SPMON-FRDATE AND @PS_SPMON-TODATE
        GROUP BY EBELN, EBELP, BUDAT_MKPF
        INTO TABLE @DATA(LT_CHK_MENGE).

*MSEG-BWART IN ('351','352')
*MSEG-EBELN = 구매오더 번호
*MSEG-EBELP = 구매오더 품목
*MSEG-BUDAT_MKPF = 요청일자
*출고수량
*MSEG-MENGE
*BWART = '352' 이면 MSEG-MENGE * -1

  ENDIF.

* 계산을 위한 기준날짜 정하기
  LV_CHK_DATE = SY-DATUM.
  DATA(LT_2161) = GT_2161.
  DELETE LT_2161 WHERE RQMON NE PS_SPMON-SPMON.

  SORT LT_2161 BY UCONF RQDAY DESCENDING.
  READ TABLE LT_2161 INTO DATA(LS_CHK_2161) WITH KEY UCONF = 'C'. " 유저 확정 데이터중 가장 후일자 구하기
  IF SY-SUBRC EQ 0.
    LV_CHK_DATE = LS_CHK_2161-RQDAY + 1.
  ENDIF.

* 가용일자--> 월별 수량 분배를 위해 현재일 이후건에 대한 일별 평균 수량을 구해준다.
  IF PS_SPMON-TODATE >= LV_CHK_DATE.
    LV_CUR_DATE = PS_SPMON-FRDATE.

    DO.
      IF LV_CUR_DATE > PS_SPMON-TODATE.
        EXIT.
      ENDIF.

      IF  LV_CUR_DATE < LV_CHK_DATE.

        LOOP AT GT_2161 INTO DATA(LS_2161) WHERE RQDAY = LV_CUR_DATE
                                                            AND UCONF = 'C'.
          IF LS_2161-RQDAY < SY-DATUM.
            READ TABLE LT_CHK_MENGE INTO DATA(LS_CHK_MENGE) WITH KEY BUDAT_MKPF = LV_CUR_DATE.
            IF SY-SUBRC EQ 0.
              IF LV_CHK_DUP_DATE NE LS_2161-RQDAY.
                ADD LS_CHK_MENGE-MENGE TO LV_CAL_MENGE.
              ELSE.
                CONTINUE.
              ENDIF.
            ENDIF.
          ELSE.
            ADD LS_2161-RQMNG TO LV_CAL_MENGE.
          ENDIF.

          LV_CHK_DUP_DATE = LS_2161-RQDAY.
        ENDLOOP.
      ELSE.

        IF PV_CHK_DIFF NE 'F'.

          READ TABLE GT_DAY_ATTR INTO DATA(LS_DAY_ATTR) WITH KEY DATE = LV_CUR_DATE.
          IF SY-SUBRC EQ 0 AND NOT ( LS_DAY_ATTR-WEEKDAY = 6 OR LS_DAY_ATTR-WEEKDAY = 7 ).
            ADD 1 TO LV_WORKING_DAYS.
          ENDIF.
        ENDIF.

      ENDIF.

      ADD 1 TO LV_CUR_DATE.

    ENDDO.
  ENDIF.

  LV_CAL_MENGE = PV_RQMNG - LV_CAL_MENGE.
  IF LV_WORKING_DAYS NE 0.
    PERFORM SET_CAL_MENGE USING LV_CAL_MENGE LV_WORKING_DAYS CHANGING LV_FIXED_MENGE LV_LAST_FIXED_MENGE.

    LOOP AT GT_DAY_ATTR INTO LS_DAY_ATTR WHERE DATE+0(6) = PS_SPMON-SPMON.
      IF NOT ( LS_DAY_ATTR-WEEKDAY = 6 OR LS_DAY_ATTR-WEEKDAY = 7 ).
        IF LV_LAST_DATE < LS_DAY_ATTR-DATE.
          LV_LAST_DATE = LS_DAY_ATTR-DATE.
        ENDIF.
      ENDIF.
    ENDLOOP.

  ELSE.
    CASE PV_CHK_DIFF.
      WHEN 'S'. " 변경사항 없으므로 그대로 보여준다.
      WHEN 'I'. " 신규 생성이므로 월 워킹데이 기준으로 분할
      WHEN 'C'. " 남은 일자에 워킹 데이가 없다는 의미이므로 마지막 일자에 남은 요청수량 섬
        IF LV_CAL_MENGE > 0.
          LV_LAST_FIXED_MENGE = LV_CAL_MENGE.
        ENDIF.
        IF PS_SPMON-TODATE > LV_CHK_DATE.
          LV_LAST_DATE = PS_SPMON-TODATE.
        ENDIF.
    ENDCASE.
  ENDIF.



* 화면 디스플레이 테이블 구성
  LOOP AT GT_DAY_ATTR  INTO LS_DAY_ATTR WHERE DATE+0(6) = PS_SPMON-SPMON.
    CLEAR GS_MAIN_101.
    GS_MAIN_101-SPMON = PS_SPMON-SPMON.
    GS_MAIN_101-TOT_PSAMG = PV_RQMNG.

    IF LS_DAY_ATTR-WEEKDAY = 6 OR LS_DAY_ATTR-WEEKDAY = 7.
      GS_MAIN_101-CHK_OFFDAY = ABAP_TRUE.
    ENDIF.
    GS_MAIN_101-DATE = LS_DAY_ATTR-DATE.
    GS_MAIN_101-MEINS = 'KG'.
* 요청수량
    CASE PV_CHK_DIFF.
      WHEN 'F'.

        GS_MAIN_101-EBELN = LS_2160-EBELN.
        GS_MAIN_101-EBELP = LS_2160-EBELP.

        IF LS_DAY_ATTR-DATE < SY-DATUM.
          GS_MAIN_101-STATUS = ABAP_TRUE.
        ENDIF.

        REFRESH LT_MAIN_101.
        LOOP AT GT_2161 INTO LS_2161 WHERE RQDAY = LS_DAY_ATTR-DATE.
          CLEAR : GS_MAIN_101-PSAMG_R, GS_MAIN_101-ZREMARK,
            GS_MAIN_101-GUBUN, GS_MAIN_101-DAY_SEQ, GS_MAIN_101-STATUS,
            GS_MAIN_101-PSAMG_RT.

          GS_MAIN_101-PSAMG_RT = LS_2161-RQMNG.
          IF LS_2161-UCONF = 'C'.
            GS_MAIN_101-PSAMG_R = LS_2161-RQMNG.
            GS_MAIN_101-CAL_MARK = ICON_MASS_CHANGE.
          ENDIF.

          GS_MAIN_101-ZREMARK = LS_2161-ZREMARK.
          GS_MAIN_101-DAY_SEQ = LS_2161-DAY_SEQ.

          IF LS_DAY_ATTR-DATE < SY-DATUM.
            GS_MAIN_101-STATUS = ABAP_TRUE.
          ENDIF.

          IF LS_2161-RQSTA = 'F'.
            GS_MAIN_101-GUBUN = ABAP_TRUE.
            GS_MAIN_101-STATUS = ABAP_TRUE.
          ENDIF.

          CLEAR GS_MAIN_101-MENGE.
          IF LS_2161-DAY_SEQ EQ 0 AND LS_2161-ZSEQ = 0.
            READ TABLE LT_CHK_MENGE INTO LS_CHK_MENGE WITH KEY BUDAT_MKPF = LS_DAY_ATTR-DATE.
            IF SY-SUBRC EQ 0.
              GS_MAIN_101-MENGE = LS_CHK_MENGE-MENGE.
            ENDIF.
          ENDIF.

          APPEND GS_MAIN_101 TO LT_MAIN_101.

        ENDLOOP.

        IF LT_MAIN_101[] IS NOT INITIAL.
          APPEND LINES OF LT_MAIN_101 TO GT_MAIN_101.
        ELSE.
          APPEND GS_MAIN_101 TO GT_MAIN_101.
        ENDIF.

        CONTINUE.
*        GS_MAIN_101-STATUS = ABAP_TRUE.

      WHEN 'S'. " 변경사항 없으므로 그대로 보여준다.
        CLEAR LS_2161.
        READ TABLE GT_2161 INTO LS_2161 WITH KEY RQDAY = LS_DAY_ATTR-DATE.
        IF SY-SUBRC EQ 0.
          GS_MAIN_101-PSAMG_RT = LS_2161-RQMNG.
          IF LS_2161-UCONF = 'C'.
            GS_MAIN_101-PSAMG_R = LS_2161-RQMNG.
            GS_MAIN_101-CAL_MARK = ICON_MASS_CHANGE.
          ENDIF.
          GS_MAIN_101-ZREMARK = LS_2161-ZREMARK.
        ENDIF.
        IF LS_DAY_ATTR-DATE < SY-DATUM.
          GS_MAIN_101-STATUS = ABAP_TRUE.
        ENDIF.

      WHEN 'I'. " 계산된 개별 수량 적용
        IF LS_DAY_ATTR-DATE >= SY-DATUM.
          IF GS_MAIN_101-CHK_OFFDAY NE ABAP_TRUE.
            IF LS_DAY_ATTR-DATE = LV_LAST_DATE.
              GS_MAIN_101-PSAMG_RT = LV_LAST_FIXED_MENGE.
            ELSE.
              GS_MAIN_101-PSAMG_RT = LV_FIXED_MENGE.
            ENDIF.
          ENDIF.
        ELSE. " 현재일 이전은 수량 입력 불가
          GS_MAIN_101-STATUS = ABAP_TRUE.
        ENDIF.
      WHEN 'C'.
        IF LS_DAY_ATTR-DATE >= LV_CHK_DATE.
          CLEAR LS_2161.
          READ TABLE GT_2161 INTO LS_2161 WITH KEY RQDAY = LS_DAY_ATTR-DATE.
          IF SY-SUBRC EQ 0.
            GS_MAIN_101-ZREMARK = LS_2161-ZREMARK.
          ENDIF.

          IF LS_DAY_ATTR-DATE = LV_LAST_DATE.
            GS_MAIN_101-PSAMG_RT = LV_LAST_FIXED_MENGE.
          ELSEIF GS_MAIN_101-CHK_OFFDAY NE ABAP_TRUE. " 휴일이 아니라면 계산수량 입력
            GS_MAIN_101-PSAMG_RT = LV_FIXED_MENGE.
          ENDIF.
        ELSE. " 현재일 이전은 수량 입력 불가
          CLEAR LS_2161.
          READ TABLE GT_2161 INTO LS_2161 WITH KEY RQDAY = LS_DAY_ATTR-DATE.
          IF SY-SUBRC EQ 0.
            GS_MAIN_101-PSAMG_RT = LS_2161-RQMNG.
            IF LS_2161-UCONF = 'C'.
              GS_MAIN_101-PSAMG_R = LS_2161-RQMNG.
              GS_MAIN_101-CAL_MARK = ICON_MASS_CHANGE.
            ENDIF.
            GS_MAIN_101-ZREMARK = LS_2161-ZREMARK.
          ENDIF.

          IF LS_DAY_ATTR-DATE < SY-DATUM.
            GS_MAIN_101-STATUS = ABAP_TRUE.
          ENDIF.
        ENDIF.
    ENDCASE.

    APPEND GS_MAIN_101 TO GT_MAIN_101.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_CAL_MENGE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LV_CAL_MENGE
*&      --> LV_WORKING_DAYS
*&      <-- LV_FIXED_MENGE
*&      <-- LV_LAST_FIXED_MENGE
*&---------------------------------------------------------------------*
FORM SET_CAL_MENGE  USING    PV_CAL_MENGE TYPE AFPO-PSAMG
                                                PV_WORKING_DAYS TYPE I
                    CHANGING PV_FIXED_MENGE TYPE AFPO-PSAMG
                                   PV_LAST_FIXED_MENGE TYPE AFPO-PSAMG.

  DATA : LV_CAL_MENGE TYPE AFPO-PSAMG.

  IF PV_FIXED_MENGE < 0.
    EXIT.
  ENDIF.

  PV_FIXED_MENGE = PV_CAL_MENGE / PV_WORKING_DAYS.

  CALL FUNCTION 'FIMA_NUMERICAL_VALUE_ROUND'
    EXPORTING
      I_RTYPE     = '-' " 반올림
      I_RUNIT     = 1
      I_VALUE     = PV_FIXED_MENGE
    IMPORTING
      E_VALUE_RND = PV_FIXED_MENGE.

  LV_CAL_MENGE = PV_CAL_MENGE - ( PV_FIXED_MENGE * PV_WORKING_DAYS ).
  PV_LAST_FIXED_MENGE = PV_FIXED_MENGE + LV_CAL_MENGE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_LAYOUT_GRID_0101
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_LAYOUT_GRID_0101 .

  CLEAR GS_LAYOUT_0101.
*  GS_LAYOUT_0101-CWIDTH_OPT = ABAP_TRUE.
  GS_LAYOUT_0100-NO_ROWINS = ABAP_TRUE.
  GS_LAYOUT_0101-STYLEFNAME = 'CELLTAB'.
*  GS_LAYOUT_0101-NO_ROWMARK  = ABAP_TRUE.
  GS_LAYOUT_0101-SEL_MODE  = 'D'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_CELL_ATTRIBUTE_GRID_0101
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_CELL_ATTRIBUTE_GRID_0101 .

  DATA : LT_CELLTAB TYPE LVC_T_STYL.
  DATA : LS_CELLTAB TYPE LVC_S_STYL.
  DATA : LV_FIELDNAME TYPE FIELDNAME.

  FIELD-SYMBOLS <LT_CELLTAB> TYPE ANY.
  FIELD-SYMBOLS <LV_VALUE> TYPE ANY.

  LOOP AT GT_MAIN_101 ASSIGNING FIELD-SYMBOL(<LS_DATA>).
    REFRESH LT_CELLTAB.
* 키필드 색상지정
    LOOP AT GT_FIELDCAT_0101 INTO DATA(LS_FCAT).
      CASE LS_FCAT-FIELDNAME.
        WHEN 'SPMON' OR 'TOT_PSAMG' OR 'DATE'.
          CLEAR LS_CELLTAB.
          LS_CELLTAB-FIELDNAME = LS_FCAT-FIELDNAME.

          IF  <LS_DATA>-CHK_OFFDAY = ABAP_TRUE. "주말표시
            LS_CELLTAB-STYLE = ALV_STYLE_COLOR_GROUP.
          ELSE.
            LS_CELLTAB-STYLE = ALV_STYLE_COLOR_KEY.
          ENDIF.

          INSERT LS_CELLTAB INTO TABLE LT_CELLTAB.
        WHEN 'PSAMG_R'. " 실적완료시나, 기준일 이전데이터는 수정금지
          CLEAR LS_CELLTAB.
          LS_CELLTAB-FIELDNAME = LS_FCAT-FIELDNAME.

          IF  <LS_DATA>-STATUS = ABAP_TRUE. "잠금표시
            LS_CELLTAB-STYLE = ALV_STYLE_DISABLED.
          ELSE.
            LS_CELLTAB-STYLE = ALV_STYLE_ENABLED.
          ENDIF.

          INSERT LS_CELLTAB INTO TABLE LT_CELLTAB.
        WHEN 'PSAMG_S'.

      ENDCASE.
    ENDLOOP.

    IF <LT_CELLTAB> IS ASSIGNED. UNASSIGN <LT_CELLTAB>. ENDIF.
    ASSIGN COMPONENT 'CELLTAB' OF STRUCTURE <LS_DATA> TO <LT_CELLTAB>.
    IF <LT_CELLTAB> IS ASSIGNED.
      <LT_CELLTAB> = LT_CELLTAB.
    ENDIF.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_FIELDCAT_0101
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_FIELDCAT_0101 .

  DATA : LT_FCAT TYPE SLIS_T_FIELDCAT_ALV.
  DATA : LV_COL_POS_A TYPE I.
  DATA : LV_COL_POS_B TYPE I.
  DATA : LV_DATE TYPE SY-DATUM.

  REFRESH GT_FIELDCAT_0101.
  FREE GT_FIELDCAT_0101.

  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      I_PROGRAM_NAME     = SY-REPID
      I_INTERNAL_TABNAME = 'GS_MAIN_101'
      I_INCLNAME         = 'ZGTPPR2120TOP'
      I_BYPASSING_BUFFER = 'X'
    CHANGING
      CT_FIELDCAT        = LT_FCAT.

  CALL FUNCTION 'LVC_TRANSFER_FROM_SLIS'
    EXPORTING
      IT_FIELDCAT_ALV = LT_FCAT
    IMPORTING
      ET_FIELDCAT_LVC = GT_FIELDCAT_0101[]
    TABLES
      IT_DATA         = GT_MAIN_101.

  READ TABLE GT_FIELDCAT_0101 ASSIGNING FIELD-SYMBOL(<LS_FCAT>) WITH KEY FIELDNAME = 'GUBUN'.
  IF SY-SUBRC NE 0.
    APPEND INITIAL LINE TO GT_FIELDCAT_0101 ASSIGNING <LS_FCAT>.
    <LS_FCAT>-COL_POS = 9.
    <LS_FCAT>-FIELDNAME = 'GUBUN'.
    <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '구분'.
    <LS_FCAT>-DATATYPE = 'CHAR'.
    <LS_FCAT>-DD_OUTLEN = '1'.
    <LS_FCAT>-OUTPUTLEN = '5'.
  ENDIF.

* 필드명 서술
  LOOP AT GT_FIELDCAT_0101 ASSIGNING <LS_FCAT>.
    CLEAR <LS_FCAT>-KEY.
    CASE <LS_FCAT>-FIELDNAME.
      WHEN 'SPMON'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '월'(f08).
        <LS_FCAT>-JUST = 'C'.
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
        <LS_FCAT>-OUTPUTLEN = '7'.
      WHEN 'TOT_PSAMG'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '월요청량'(f09).
        <LS_FCAT>-JUST = 'R'.
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
        <LS_FCAT>-OUTPUTLEN = '7'.
        <LS_FCAT>-QUANTITY = 'EA'.
        <LS_FCAT>-COL_OPT = ABAP_TRUE.
      WHEN 'MENGE'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '출하량'(f17).
        <LS_FCAT>-JUST = 'R'.
        <LS_FCAT>-OUTPUTLEN = '5'.
        <LS_FCAT>-QUANTITY = 'EA'.
        <LS_FCAT>-DO_SUM = ABAP_TRUE.
        <LS_FCAT>-COL_OPT = ABAP_TRUE.
      WHEN 'GUBUN'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '출하요청'(f18).
        <LS_FCAT>-JUST = 'C'.
        <LS_FCAT>-CHECKBOX = ABAP_TRUE.

      WHEN 'DATE'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '요청일자'(f11).
        <LS_FCAT>-JUST = 'C'.
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
        <LS_FCAT>-OUTPUTLEN = '10'.
*        <LS_FCAT>-COL_OPT = ABAP_TRUE.
      WHEN 'CAL_MARK'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '　'.
        <LS_FCAT>-JUST = 'C'.
        <LS_FCAT>-ICON = ABAP_TRUE.
        <LS_FCAT>-NO_OUT = ABAP_TRUE.
      WHEN 'PSAMG_RT'.
        <LS_FCAT>-NO_OUT = ABAP_TRUE.
      WHEN 'PSAMG_R'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '요청량'(f12).
        <LS_FCAT>-JUST = 'R'.
        <LS_FCAT>-OUTPUTLEN = '5'.
        <LS_FCAT>-QUANTITY = 'EA'.
        <LS_FCAT>-DO_SUM = ABAP_TRUE.
        <LS_FCAT>-COL_OPT = ABAP_TRUE.
        <LS_FCAT>-EDIT = ABAP_TRUE.
      WHEN 'MEINS'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '단위'(f05).
        <LS_FCAT>-JUST = 'C'.
        <LS_FCAT>-OUTPUTLEN = '5'.
        <LS_FCAT>-NO_OUT = ABAP_TRUE.
      WHEN 'ZREMARK'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '비고'(f14).
        <LS_FCAT>-JUST = 'L'.
        <LS_FCAT>-OUTPUTLEN = '30'.
        <LS_FCAT>-EDIT = ABAP_TRUE.
      WHEN 'EBELN'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = 'STO 번호'(f15).
        <LS_FCAT>-JUST = 'C'.
        <LS_FCAT>-COL_OPT = ABAP_TRUE.
      WHEN 'EBELP'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = 'STO 품목'(f16).
        <LS_FCAT>-JUST = 'C'.
        <LS_FCAT>-COL_OPT = ABAP_TRUE.
      WHEN OTHERS.
        <LS_FCAT>-NO_OUT = ABAP_TRUE.
    ENDCASE.
  ENDLOOP.

  SORT GT_FIELDCAT_0101 BY COL_POS.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form EXCLUDE_OF_TOOLBAR_GRID_0101
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM EXCLUDE_OF_TOOLBAR_GRID_0101 .

  PERFORM ADD_EXCLUDE_TOOLBAR_BUTTON TABLES GT_EXCLUDE_0101
        USING : CL_GUI_ALV_GRID=>MC_FC_EXCL_ALL.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_SORTTAB_GRID_0101
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_SORTTAB_GRID_0101 .

  PERFORM SET_SORT_TAB TABLES GT_SORT_0101
                                  USING : 1 'SPMON' 'X' '' 'X',
                                        2 'DATE'  'X' '' '',
                                        3 'DAY_SEQ'  'X' '' ''.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CALL_GRID_0101_DISPLAY
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CALL_GRID_0101_DISPLAY .

  CALL METHOD GO_GRID_0101->SET_TABLE_FOR_FIRST_DISPLAY
    EXPORTING
      IS_LAYOUT            = GS_LAYOUT_0101
      IT_TOOLBAR_EXCLUDING = GT_EXCLUDE_0101
    CHANGING
      IT_OUTTAB            = GT_MAIN_101
      IT_SORT              = GT_SORT_0101
      IT_FIELDCATALOG      = GT_FIELDCAT_0101.

  IF GO_DD_DOCU_0101 IS BOUND.
    CALL METHOD GO_DD_DOCU_0101->INITIALIZE_DOCUMENT.
  ELSE.
    CREATE OBJECT GO_DD_DOCU_0101
      EXPORTING
        STYLE = 'ALV_GRID'.                 " Adjusting to the Style of a Particular GUI Environment
  ENDIF.

  CALL METHOD GO_GRID_0101->LIST_PROCESSING_EVENTS
    EXPORTING
      I_EVENT_NAME = 'TOP_OF_PAGE'
      I_DYNDOC_ID  = GO_DD_DOCU_0101.

* 인풋이벤트 추가
  CALL METHOD GO_GRID_0101->REGISTER_EDIT_EVENT
    EXPORTING
      I_EVENT_ID = CL_GUI_ALV_GRID=>MC_EVT_ENTER.

  CALL METHOD GO_GRID_0101->REGISTER_EDIT_EVENT
    EXPORTING
      I_EVENT_ID = CL_GUI_ALV_GRID=>MC_EVT_MODIFIED.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form REFRESH_0101
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM REFRESH_0101 .

  DATA: LS_SCROLL   TYPE LVC_S_STBL.

  LS_SCROLL-ROW = 'X'.
  LS_SCROLL-COL = 'X'.

  SORT GT_MAIN_101 BY SPMON DATE DAY_SEQ.

  IF GO_DD_DOCU_0101 IS BOUND.
    CALL METHOD GO_DD_DOCU_0101->INITIALIZE_DOCUMENT.
  ELSE.
    CREATE OBJECT GO_DD_DOCU_0101
      EXPORTING
        STYLE = 'ALV_GRID'.                 " Adjusting to the Style of a Particular GUI Environment
  ENDIF.

  CALL METHOD GO_GRID_0101->LIST_PROCESSING_EVENTS
    EXPORTING
      I_EVENT_NAME = 'TOP_OF_PAGE'
      I_DYNDOC_ID  = GO_DD_DOCU_0101.

  PERFORM SET_CELL_ATTRIBUTE_GRID_0101.
  GO_GRID_0101->SET_FRONTEND_LAYOUT( IS_LAYOUT = GS_LAYOUT_0101 ).

  CALL METHOD GO_GRID_0101->REFRESH_TABLE_DISPLAY
    EXPORTING
      IS_STABLE = LS_SCROLL.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_TITLE_SCREEN101
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- PO_DYNDOC_ID
*&---------------------------------------------------------------------*
FORM SET_TITLE_SCREEN101  CHANGING PO_DYNDOC_ID  TYPE REF TO  CL_DD_DOCUMENT.

  DATA : LV_TEXT(255) TYPE C.
  DATA : LV_FR_SPMON(10).
  DATA : LV_TO_SPMON(10).

* 자재명
  CLEAR LV_TEXT.
  CONCATENATE '자재명 :' GS_DISP_HEADER_101-MAKTX INTO LV_TEXT SEPARATED BY SPACE.

  "텍스트 추가
  CALL METHOD PO_DYNDOC_ID->ADD_TEXT
    EXPORTING
      TEXT         = LV_TEXT
      SAP_FONTSIZE = '20'.

  CALL METHOD PO_DYNDOC_ID->NEW_LINE.

* 등급
  IF GS_DISP_HEADER_101-ATWRT IS NOT INITIAL.
    CLEAR LV_TEXT.
    CONCATENATE '등급 :' GS_DISP_HEADER_101-ATWRT INTO LV_TEXT SEPARATED BY SPACE.
    "텍스트 추가
    CALL METHOD PO_DYNDOC_ID->ADD_TEXT
      EXPORTING
        TEXT         = LV_TEXT
        SAP_FONTSIZE = '20'.

    CALL METHOD PO_DYNDOC_ID->NEW_LINE.
  ENDIF.

  "위쪽에 추가한 텍스트 출력
  CALL METHOD PO_DYNDOC_ID->DISPLAY_DOCUMENT
    EXPORTING
      PARENT             = GO_CONTAIN_TOP_0101
      REUSE_CONTROL      = ABAP_TRUE
      REUSE_REGISTRATION = ABAP_TRUE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROC_SAVE_DETAIL
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PROC_SAVE_DETAIL .

  DATA : LT_MAIN_101 LIKE TABLE OF GS_MAIN_101.
  DATA : LT_SAVE_2161 TYPE TABLE OF ZGTPPT2161.
  DATA : LT_ORIGN_2161 TYPE TABLE OF ZGTPPT2161.
  DATA : LT_TEMP_2161 TYPE TABLE OF ZGTPPT2161.
  DATA : LT_SAVE_2160 TYPE TABLE OF ZGTPPT2160.
  DATA : LT_ORIGN_2160 TYPE TABLE OF ZGTPPT2160.
  DATA : LT_TEMP_2160 TYPE TABLE OF ZGTPPT2160.
  DATA : LV_TOT_PSAMG TYPE AFPO-PSAMG.
  DATA : LV_PSAMG TYPE AFPO-PSAMG.
  DATA : LS_2160 TYPE ZGTPPT2160.
  DATA : LV_CHK_ERR.
  DATA : LV_CHK_DIFF.
  FIELD-SYMBOLS : <LV_RQMNG> TYPE ANY.
  FIELD-SYMBOLS : <LV_RQMNG_CHK> TYPE ANY.


  IF GV_CHK_EDIT_101 IS INITIAL.
    MESSAGE S006 DISPLAY LIKE 'E' WITH '변경된 데이터가 없습니다.'.
    RETURN.
  ENDIF.

  CLEAR GV_ANSWER.
  PERFORM POPUP_TO_CONFIRM_STEP USING 'N'
    ' '
    '상세요청계획 저장하시겠습니까?'
    '저장확인'.
  IF GV_ANSWER NE 'J'.
    MESSAGE S003 DISPLAY LIKE 'E' WITH '작업 취소 되었습니다.'.
    RETURN.
  ENDIF.

  LOOP AT <GT_MAIN_DISP_100> ASSIGNING FIELD-SYMBOL(<LS_MAIN>).
    CLEAR GS_MAIN.
    MOVE-CORRESPONDING <LS_MAIN> TO GS_MAIN.
    IF GS_MAIN-WERKS = GS_DISP_HEADER_101-WERKS AND
       GS_MAIN-MATNR = GS_DISP_HEADER_101-MATNR AND
      GS_MAIN-ATWRT = GS_DISP_HEADER_101-ATWRT AND
      GS_MAIN-ZSEQ = GS_DISP_HEADER_101-ZSEQ.

*    ZGTPPT2160 원본 원장
      REFRESH LT_TEMP_2160.
      PERFORM GET_ORIGN_2160 TABLES LT_TEMP_2160 USING GS_MAIN.
      IF LT_TEMP_2160[] IS NOT INITIAL.
        IF GV_DISP_SPMON NE '000000'.
          DELETE LT_TEMP_2160 WHERE RQMON NE GV_DISP_SPMON.
        ENDIF.
        APPEND LINES OF LT_TEMP_2160 TO LT_ORIGN_2160.
      ENDIF.
*    ZGTPPT2161 원본 원장
      LT_ORIGN_2161 = GT_2161.

      LOOP AT GT_SPMON INTO GS_SPMON.
        IF GV_DISP_SPMON NE '000000' AND GS_SPMON-SPMON NE GV_DISP_SPMON.
          CONTINUE.
        ENDIF.
        REFRESH LT_MAIN_101.
        LT_MAIN_101 = VALUE #( FOR LW_MAIN_101 IN GT_MAIN_101 WHERE ( SPMON = GS_SPMON-SPMON )
                                        ( CORRESPONDING #( LW_MAIN_101 ) ) ).

        IF <LV_RQMNG> IS ASSIGNED. UNASSIGN <LV_RQMNG>. ENDIF.
        ASSIGN COMPONENT GS_SPMON-FIELDNAME_A OF STRUCTURE <LS_MAIN> TO <LV_RQMNG>.

        CLEAR LV_TOT_PSAMG.
        LV_TOT_PSAMG = <LV_RQMNG>.
        PERFORM SAVE_DETAIL_FR_ITAB TABLES LT_MAIN_101 LT_TEMP_2161
                                                     USING GS_MAIN
                                                 CHANGING LV_CHK_ERR LV_TOT_PSAMG.
        IF LV_CHK_ERR = ABAP_TRUE.
          MESSAGE S003 DISPLAY LIKE 'E' WITH '상세요청저장 중 오류발생하였습니다.'.
          RETURN.
        ENDIF.

        IF <LV_RQMNG_CHK> IS ASSIGNED. UNASSIGN <LV_RQMNG_CHK>. ENDIF.
        ASSIGN COMPONENT GS_SPMON-FIELDNAME_A_CHK OF STRUCTURE <LS_MAIN> TO <LV_RQMNG_CHK>.
        CASE <LV_RQMNG_CHK>.
          WHEN 'C' OR 'X'.
          WHEN OTHERS.

*            IF <LV_RQMNG> NE LV_TOT_PSAMG.
*              MESSAGE S006 DISPLAY LIKE 'E' WITH GS_SPMON-SPMON '총수량이 상세수량과 같지 않습니다.!'.
*              RETURN.
*            ENDIF.
        ENDCASE.

*      상세데이터중 해당월 요청 금액 없으면 월테이블 생성 없음.
        IF LT_TEMP_2161[] IS INITIAL.
          CONTINUE.
        ENDIF.

        APPEND LINES OF LT_TEMP_2161 TO LT_SAVE_2161.

        CLEAR LS_2160.
        READ TABLE LT_TEMP_2160 INTO LS_2160 WITH KEY RQMON = GS_SPMON-SPMON.
        PERFORM SET_2160_DATA USING GS_MAIN GS_SPMON-SPMON <LV_RQMNG> CHANGING LS_2160.
        APPEND LS_2160 TO LT_SAVE_2160.

      ENDLOOP.
    ENDIF.
  ENDLOOP.

  IF LT_ORIGN_2160 IS NOT   INITIAL.
    DELETE ZGTPPT2160 FROM TABLE LT_ORIGN_2160.
    IF SY-SUBRC NE 0.
      ROLLBACK WORK.
      MESSAGE S003 DISPLAY LIKE 'E' WITH '상세요청저장 중 오류발생하였습니다.'.
      RETURN.
    ENDIF.
  ENDIF.

  IF LT_SAVE_2160[] IS NOT INITIAL.
    MODIFY ZGTPPT2160 FROM TABLE LT_SAVE_2160.
    IF SY-SUBRC NE 0.
      ROLLBACK WORK.
      MESSAGE S003 DISPLAY LIKE 'E' WITH '상세요청저장 중 오류발생하였습니다.'.
      RETURN.
    ENDIF.
  ENDIF.

  IF LT_ORIGN_2161 IS NOT   INITIAL.
    DELETE ZGTPPT2161 FROM TABLE LT_ORIGN_2161.
    IF SY-SUBRC NE 0.
      ROLLBACK WORK.
      MESSAGE S003 DISPLAY LIKE 'E' WITH '상세요청저장 중 오류발생하였습니다.'.
      RETURN.
    ENDIF.
  ENDIF.

  IF LT_SAVE_2161[] IS NOT INITIAL.
    MODIFY ZGTPPT2161 FROM TABLE LT_SAVE_2161.
    IF SY-SUBRC NE 0.
      ROLLBACK WORK.
      MESSAGE S003 DISPLAY LIKE 'E' WITH '상세요청저장 중 오류발생하였습니다.'.
      RETURN.
    ENDIF.
  ENDIF.

  COMMIT WORK AND WAIT.

  PERFORM SET_SCREEN_101.
  PERFORM SET_WITH_MAIN USING GV_CHK_DETAIL.
  PERFORM REFRESH_0100.
  PERFORM REFRESH_0101.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form change_icon_detail
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CHANGE_ICON_DETAIL .
  GV_CHK_EDIT_101 = ABAP_TRUE.
  LOOP AT <GT_MAIN_DISP_100> ASSIGNING FIELD-SYMBOL(<LS_MAIN>).
    ASSIGN COMPONENT 'DETAIL' OF STRUCTURE <LS_MAIN> TO FIELD-SYMBOL(<LV_VALUE>).
    IF <LV_VALUE> = ICON_DISPLAY.
      <LV_VALUE> = ICON_CHANGE.
    ENDIF.
  ENDLOOP.

  PERFORM REFRESH_0100.
  PERFORM REFRESH_0101.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHK_MENGE_OF_DETAIL
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- LV_CHK_ERR
*&---------------------------------------------------------------------*
FORM CHK_MENGE_OF_DETAIL  CHANGING PV_TOT_PSAMG  TYPE AFPO-PSAMG
                                                  PV_CHK_AVAILABLE.

  DATA : LT_CHK_TAB TYPE TABLE OF ZGTPPT2161.
  DATA : LV_CURRENT_DT TYPE SY-DATUM.


  SELECT * FROM ZGTPPT2161 INTO TABLE LT_CHK_TAB
  WHERE PDWRK = P_WERKS
    AND SPGCD = P_SPGCD
    AND RQWRK = GS_MAIN-WERKS
    AND MATNR = GS_MAIN-MATNR
    AND SCRGRADE = GS_MAIN-ATWRT
    AND RQMON = GS_SPMON-SPMON
    AND  ZSEQ = GS_MAIN-ZSEQ.

  CLEAR PV_TOT_PSAMG.

  LOOP AT LT_CHK_TAB INTO DATA(LS_CHK_TAB).
    IF LS_CHK_TAB-RQDAY < SY-DATUM.
      ADD LS_CHK_TAB-RQMNG TO PV_TOT_PSAMG.
      CONTINUE.
    ENDIF.

    IF LS_CHK_TAB-RQSTA = 'F'.
      ADD LS_CHK_TAB-RQMNG TO PV_TOT_PSAMG.
      CONTINUE.
    ENDIF.

  ENDLOOP.

* 수량 입력 가능한 일자 존재하는지 체크(현재일 이후 데이터 확정건만 존재시 불가)
  IF SY-DATUM BETWEEN GS_SPMON-FRDATE AND GS_SPMON-TODATE.
    PV_CHK_AVAILABLE = ABAP_TRUE.
    LV_CURRENT_DT = SY-DATUM.
    DO.
      IF LV_CURRENT_DT > GS_SPMON-TODATE.
        EXIT.
      ENDIF.

      READ TABLE LT_CHK_TAB INTO LS_CHK_TAB WITH KEY RQDAY = LV_CURRENT_DT
                                                                       RQSTA = 'F'.
      IF SY-SUBRC NE 0.
        CLEAR PV_CHK_AVAILABLE.
        EXIT.
      ENDIF.

      ADD 1 TO LV_CURRENT_DT.
    ENDDO.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_ORIGN_2160
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LT_ORIGN_2160
*&      --> GS_MAIN
*&---------------------------------------------------------------------*
FORM GET_ORIGN_2160  TABLES   PT_2160 STRUCTURE ZGTPPT2160
                     USING    PS_MAIN LIKE GS_MAIN.

  REFRESH PT_2160[].
  FREE PT_2160[].

  SELECT * FROM ZGTPPT2160 INTO TABLE PT_2160[]
    WHERE PDWRK = P_WERKS
      AND SPGCD = P_SPGCD
      AND RQWRK = PS_MAIN-WERKS
      AND MATNR = PS_MAIN-MATNR
      AND SCRGRADE = PS_MAIN-ATWRT
      AND ZSEQ = PS_MAIN-ZSEQ
      AND RQMON IN S_SPMON.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SAVE_DETAIL_FR_ITAB
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LT_MAIN_101
*&      --> LT_TEMP_2161
*&      --> GS_MAIN
*&      <-- LV_CHK_ERR
*&      <-- LV_TOT_PSAMG
*&---------------------------------------------------------------------*
FORM SAVE_DETAIL_FR_ITAB  TABLES   PT_MAIN_101 STRUCTURE GS_MAIN_101
                                   PT_2161 STRUCTURE ZGTPPT2161
                          USING    PS_MAIN LIKE GS_MAIN
                          CHANGING PV_CHK_ERR
                                   PV_TOT_PSAMG TYPE AFPO-PSAMG.

  DATA : LS_2161 TYPE ZGTPPT2161.
  DATA : LV_CHK_DATE TYPE SY-DATUM.
  DATA : LV_CAL_PSAMG TYPE AFPO-PSAMG.
  DATA : LV_CHK_DUP_DATE TYPE SY-DATUM.

  REFRESH PT_2161[].

  DATA(LT_CHK_101) = PT_MAIN_101[].

  LOOP AT LT_CHK_101 INTO DATA(LS_CHK_101).
    IF LS_CHK_101-CAL_MARK = ICON_MASS_CHANGE.
      IF LV_CHK_DATE < LS_CHK_101-DATE.
        LV_CHK_DATE = LS_CHK_101-DATE.
      ENDIF.
    ENDIF.
  ENDLOOP.

  CLEAR LV_CAL_PSAMG.
  CLEAR LV_CHK_DUP_DATE.
  LOOP AT LT_CHK_101 INTO LS_CHK_101 WHERE DATE <= LV_CHK_DATE.
    IF LS_CHK_101-DATE < SY-DATUM.
      IF LV_CHK_DUP_DATE NE LS_CHK_101-DATE.
        ADD LS_CHK_101-MENGE TO LV_CAL_PSAMG.
      ELSE.
        CONTINUE.
      ENDIF.
    ELSE.
      ADD LS_CHK_101-PSAMG_R TO LV_CAL_PSAMG.
    ENDIF.

    LV_CHK_DUP_DATE = LS_CHK_101-DATE.
  ENDLOOP.


  PERFORM CAL_SAVE_DATA TABLES PT_MAIN_101
                            USING PS_MAIN LV_CHK_DATE PV_TOT_PSAMG LV_CAL_PSAMG.


  CLEAR PV_TOT_PSAMG.

  LOOP AT PT_MAIN_101 INTO DATA(LS_MAIN_101).
    CLEAR LS_2161.
    LS_2161-PDWRK = P_WERKS.
    LS_2161-SPGCD = P_SPGCD.
    LS_2161-RQWRK = PS_MAIN-WERKS.
    LS_2161-MATNR = PS_MAIN-MATNR.
    LS_2161-SCRGRADE = PS_MAIN-ATWRT.
    LS_2161-ZSEQ = PS_MAIN-ZSEQ.
    LS_2161-RQMON = LS_MAIN_101-SPMON.
    LS_2161-RQDAY = LS_MAIN_101-DATE.
    LS_2161-DAY_SEQ = LS_MAIN_101-DAY_SEQ.
    IF LS_MAIN_101-DATE <= LV_CHK_DATE.
      LS_2161-RQMNG = LS_MAIN_101-PSAMG_R.
      LS_2161-UCONF = 'C'.
    ELSE.
      LS_2161-RQMNG = LS_MAIN_101-PSAMG_RT.
    ENDIF.

    LS_2161-ZREMARK = LS_MAIN_101-ZREMARK.
    ADD LS_2161-RQMNG TO PV_TOT_PSAMG.

    IF LS_MAIN_101-GUBUN = 'X'.
      LS_2161-RQSTA = 'F'.
    ENDIF.

    LS_2161-MEINS = LS_MAIN_101-MEINS.
    LS_2161-ERDAT = SY-DATUM.
    LS_2161-ERNAM = SY-UNAME.

    IF LS_2161-UCONF = 'C' OR ( LS_2161-RQMNG NE 0 AND LS_2161-UCONF NE 'C' ).
      APPEND LS_2161 TO PT_2161[].
    ENDIF.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_SCREEN_101
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_SCREEN_101 .

  DATA : LV_TOT_PSAMG TYPE AFPO-PSAMG.
  DATA : LV_PSAMG TYPE AFPO-PSAMG.
  DATA : LV_CHK_DIFF.
  FIELD-SYMBOLS : <LV_RQMNG> TYPE ANY.
  FIELD-SYMBOLS : <LV_RQMNG_CHK> TYPE ANY.

  CLEAR LV_TOT_PSAMG.
* 저장 완료. 화면 초기화, 스크린 상태값 초기화 작업
  LOOP AT <GT_MAIN_DISP_100> ASSIGNING FIELD-SYMBOL(<LS_MAIN>).
    CLEAR GS_MAIN.
    MOVE-CORRESPONDING <LS_MAIN> TO GS_MAIN.
    IF GS_MAIN-WERKS = GS_DISP_HEADER_101-WERKS AND
       GS_MAIN-MATNR = GS_DISP_HEADER_101-MATNR AND
      GS_MAIN-ATWRT = GS_DISP_HEADER_101-ATWRT AND
      GS_MAIN-ZSEQ = GS_DISP_HEADER_101-ZSEQ.

      GV_CHK_DETAIL = ABAP_TRUE.
      REFRESH GT_MAIN_101.
      PERFORM GET_DAILY_REQ.
      IF GV_DISP_SPMON NE '000000'.
        DELETE GT_2161 WHERE RQMON NE GV_DISP_SPMON.
      ENDIF.

      LOOP AT GT_SPMON INTO GS_SPMON.

        IF GV_DISP_SPMON NE '000000' AND GS_SPMON-SPMON NE GV_DISP_SPMON.
          CONTINUE.
        ENDIF.


        IF <LV_RQMNG> IS ASSIGNED. UNASSIGN <LV_RQMNG>. ENDIF.
        ASSIGN COMPONENT GS_SPMON-FIELDNAME_A OF STRUCTURE <LS_MAIN> TO <LV_RQMNG>.

        IF <LV_RQMNG_CHK> IS ASSIGNED. UNASSIGN <LV_RQMNG_CHK>. ENDIF.
        ASSIGN COMPONENT GS_SPMON-FIELDNAME_A_CHK OF STRUCTURE <LS_MAIN> TO <LV_RQMNG_CHK>.

        IF GV_DISP_SPMON NE '000000' AND GS_SPMON-SPMON NE GV_DISP_SPMON.
          ADD <LV_RQMNG> TO LV_TOT_PSAMG.
        ELSE.
* 상세 테이블 수량 정보 가져오기
          CLEAR LV_PSAMG.
          LOOP AT GT_2161 INTO DATA(LS_2161) WHERE RQDAY BETWEEN GS_SPMON-FRDATE AND GS_SPMON-TODATE.
            ADD LS_2161-RQMNG TO LV_PSAMG.
          ENDLOOP.

*          <LV_RQMNG> = LV_PSAMG.
          ADD LV_PSAMG TO LV_TOT_PSAMG.
          IF <LV_RQMNG_CHK> = 'U'.
            CLEAR <LV_RQMNG_CHK>.
          ENDIF.

          PERFORM COMPARE_MENGE_OF_DAY USING GS_SPMON <LV_RQMNG> CHANGING LV_CHK_DIFF.
          PERFORM SET_DISP_TABLE_101 USING GS_SPMON <LV_RQMNG> LV_CHK_DIFF.
        ENDIF.

      ENDLOOP.

      GS_MAIN-OVERDUE = LV_TOT_PSAMG.
      GS_MAIN-DETAIL = ICON_DISPLAY.
      CLEAR GV_CHK_EDIT_101.

      MOVE-CORRESPONDING GS_MAIN TO <LS_MAIN>.

    ENDIF.
  ENDLOOP.

* 왼쪽 화면의 수정 필드 확인하여 수정중인 내역 없다면 변경상태 해제
  DATA : LV_CHK_CHANGE.
  LOOP AT <GT_MAIN_DISP_100> ASSIGNING <LS_MAIN>.
    LOOP AT GT_SPMON INTO GS_SPMON.
      IF <LV_RQMNG_CHK> IS ASSIGNED. UNASSIGN <LV_RQMNG_CHK>. ENDIF.
      ASSIGN COMPONENT GS_SPMON-FIELDNAME_A_CHK OF STRUCTURE <LS_MAIN> TO <LV_RQMNG_CHK>.
      IF <LV_RQMNG_CHK> = 'U'.
        LV_CHK_CHANGE = ABAP_TRUE.
        EXIT.
      ENDIF.
    ENDLOOP.
    IF LV_CHK_CHANGE = ABAP_TRUE.
      EXIT.
    ENDIF.
  ENDLOOP.

  IF LV_CHK_CHANGE IS INITIAL.
    CLEAR GV_CHK_EDIT.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form DOUBLE_CLICK
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> SENDER
*&      --> E_ROW
*&      --> E_COLUMN
*&---------------------------------------------------------------------*
FORM DOUBLE_CLICK  USING    P_SENDER TYPE REF TO CL_GUI_ALV_GRID
                            PS_ROW TYPE LVC_S_ROW
                            P_COLUMN TYPE LVC_S_COL.

  DATA : LV_CHK_DIFF.
  DATA : LV_CHK_LINE_EXIST.
  DATA : LS_MAIN_CHK LIKE GS_MAIN.
  FIELD-SYMBOLS : <LV_RQMNG> TYPE ANY.

  CASE P_SENDER.
    WHEN GO_GRID_0100.
      READ TABLE GT_SPMON INTO GS_SPMON WITH KEY FIELDNAME_A = P_COLUMN-FIELDNAME.
      IF SY-SUBRC EQ 0.
        GV_DISP_SPMON = GS_SPMON-SPMON.

        CLEAR LV_CHK_LINE_EXIST.
        LOOP AT <GT_MAIN_DISP_100> ASSIGNING FIELD-SYMBOL(<LS_MAIN_CHK>).
          MOVE-CORRESPONDING <LS_MAIN_CHK> TO LS_MAIN_CHK.
          CASE LS_MAIN_CHK-DETAIL.
            WHEN ICON_DISPLAY.
              LS_MAIN_CHK-DETAIL = ICON_DETAIL.
              MOVE-CORRESPONDING LS_MAIN_CHK TO <LS_MAIN_CHK>.
              EXIT.
            WHEN ICON_CHANGE.
              CLEAR GV_ANSWER.
              PERFORM POPUP_TO_CONFIRM_STEP USING 'N'
                ' '
                '변경된 상세요청계획이 있습니다. 저장 없이 상세화면 변경하시겠습니까?'
                '변경확인'.
              IF GV_ANSWER NE 'J'.
                MESSAGE S003 DISPLAY LIKE 'E' WITH '작업 취소 되었습니다.'.
                RETURN.
              ENDIF.
              LS_MAIN_CHK-DETAIL = ICON_DETAIL.
              MOVE-CORRESPONDING LS_MAIN_CHK TO <LS_MAIN_CHK>.
              EXIT.
          ENDCASE.
        ENDLOOP.

        READ TABLE <GT_MAIN_DISP_100> ASSIGNING FIELD-SYMBOL(<LS_MAIN>) INDEX PS_ROW-INDEX.
        MOVE-CORRESPONDING <LS_MAIN> TO GS_MAIN.

        GV_CHK_DETAIL = ABAP_TRUE.
        REFRESH GT_MAIN_101.
* 월별 입력 수량과 기존 저장된 데일리 요청수량 점검
* --> 해당월 데일리 수량이 없다면 = 'I'
* --> 월별 수량 섬하여 수량이 틀릴경우 = 'C''
* --> 월별 수량 섬하여 수량이 같은경우 = 'S''
        PERFORM GET_DAILY_REQ.
        DELETE GT_2161 WHERE RQMON NE GS_SPMON-SPMON.

        IF <LV_RQMNG> IS ASSIGNED. UNASSIGN <LV_RQMNG>. ENDIF.
        ASSIGN COMPONENT GS_SPMON-FIELDNAME_A OF STRUCTURE <LS_MAIN> TO <LV_RQMNG>.
        PERFORM COMPARE_MENGE_OF_DAY USING GS_SPMON <LV_RQMNG> CHANGING LV_CHK_DIFF.
        PERFORM SET_DISP_TABLE_101 USING GS_SPMON <LV_RQMNG> LV_CHK_DIFF.

        IF LV_CHK_DIFF = 'C' AND GS_SPMON-TODATE >= SY-DATUM.
          GS_MAIN-DETAIL = ICON_CHANGE.
          GV_CHK_EDIT_101 = ABAP_TRUE.
        ENDIF.

        IF LV_CHK_DIFF = 'I'  AND GS_SPMON-TODATE >= SY-DATUM AND <LV_RQMNG> NE 0.
          GV_CHK_EDIT_101 = ABAP_TRUE.
        ENDIF.


        IF GS_MAIN-DETAIL NE ICON_CHANGE.
          GS_MAIN-DETAIL = ICON_DISPLAY.
        ENDIF.

        CLEAR GS_DISP_HEADER_101.
        MOVE-CORRESPONDING GS_MAIN TO GS_DISP_HEADER_101.

        IF LV_CHK_DIFF = 'F'.
          GS_DISP_HEADER_101-GUBUN = ABAP_TRUE.
        ENDIF.

        PERFORM SET_WITH_MAIN USING GV_CHK_DETAIL.
        MOVE-CORRESPONDING GS_MAIN TO <LS_MAIN>.
        PERFORM REFRESH_0100.
        PERFORM REFRESH_0101.

      ENDIF.
    WHEN GO_GRID_0101.
      CASE  P_COLUMN-FIELDNAME.
        WHEN 'CAL_MARK'.
          READ TABLE GT_MAIN_101 INTO DATA(LS_MAIN) INDEX PS_ROW-INDEX.
          IF LS_MAIN-CAL_MARK = ICON_MASS_CHANGE.
            CLEAR GV_ANSWER.
            PERFORM POPUP_TO_CONFIRM_STEP USING 'N'
              ' '
              '선택 일자부터 선택월 말일까지 재계산합니다. 재계산 하시겠습니까?'
              '재계산확인'.
            IF GV_ANSWER NE 'J'.
              MESSAGE S003 DISPLAY LIKE 'E' WITH '작업 취소 되었습니다.'.
              RETURN.
            ENDIF.
          ENDIF.

          PERFORM CAL_MAIN_101 USING LS_MAIN.
        WHEN 'EBELN'.
          READ TABLE GT_MAIN_101 INTO LS_MAIN INDEX PS_ROW-INDEX.
          IF LS_MAIN-EBELN IS NOT INITIAL.
            SET PARAMETER ID 'BES' FIELD LS_MAIN-EBELN.

            CALL TRANSACTION 'ME23N' AND SKIP FIRST SCREEN.

          ENDIF.

      ENDCASE.


  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROC_CLOSE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PROC_CLOSE .

  LOOP AT <GT_MAIN_DISP_100> ASSIGNING FIELD-SYMBOL(<LS_MAIN>).
    CLEAR GS_MAIN.
    MOVE-CORRESPONDING <LS_MAIN> TO GS_MAIN.
    IF GS_MAIN-WERKS = GS_DISP_HEADER_101-WERKS AND
       GS_MAIN-MATNR = GS_DISP_HEADER_101-MATNR AND
      GS_MAIN-ATWRT = GS_DISP_HEADER_101-ATWRT AND
      GS_MAIN-ZSEQ = GS_DISP_HEADER_101-ZSEQ.

      CASE GS_MAIN-DETAIL.
        WHEN ICON_DISPLAY.
          CLEAR GS_DISP_HEADER_101.
          REFRESH GT_MAIN_101.
          FREE GT_MAIN_101.
          CLEAR GV_CHK_DETAIL.
          CLEAR GV_CHK_EDIT_101.

          GS_MAIN-DETAIL = ICON_DETAIL.
        WHEN ICON_CHANGE.
          CLEAR GV_ANSWER.
          PERFORM POPUP_TO_CONFIRM_STEP USING 'N'
            ' '
            '변경된 상세요청계획이 있습니다. 저장 없이 상세화면 종료시겠습니까?'
            '종료확인'.
          IF GV_ANSWER NE 'J'.
            MESSAGE S003 DISPLAY LIKE 'E' WITH '종료 취소 되었습니다.'.
            RETURN.
          ENDIF.

          CLEAR GS_DISP_HEADER_101.
          REFRESH GT_MAIN_101.
          FREE GT_MAIN_101.
          CLEAR GV_CHK_EDIT_101.
          CLEAR GV_CHK_DETAIL.

          GS_MAIN-DETAIL = ICON_DETAIL.

      ENDCASE.

      MOVE-CORRESPONDING GS_MAIN TO <LS_MAIN>.
      EXIT.

    ENDIF.
  ENDLOOP.

  PERFORM SET_WITH_MAIN USING GV_CHK_DETAIL.
  PERFORM REFRESH_0100.
  PERFORM REFRESH_0101.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_MANAGEMENT_MATNR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_MANAGEMENT_MATNR .

  SELECT * FROM ZGTPPT2151
    INTO TABLE GT_2151
    WHERE WERKS = P_WERKS.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROC_AUTO_CREATE_PO
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PROC_AUTO_CREATE_PO .

  DATA : LT_CELLS TYPE LVC_T_CENO.
  DATA : LV_ROW TYPE I.

  DATA : LV_CHK_ERR.

  IF GV_CHK_EDIT IS NOT INITIAL.
    MESSAGE S003 DISPLAY LIKE 'E' WITH '수정중인 데이터가 있습니다. 저장후 생성가능합니다.'.
    RETURN.
  ENDIF.

  REFRESH : GT_2160_CHG.

  GO_GRID_0100->GET_SELECTED_CELLS_ID(
    IMPORTING
     ET_CELLS = LT_CELLS ).                " Cell IDs

  IF LT_CELLS[] IS INITIAL.
    RETURN.
  ENDIF.

  LOOP AT LT_CELLS INTO DATA(LS_CELLS).

    READ TABLE GT_FIELDCAT_0100 INTO DATA(LS_FCAT) INDEX LS_CELLS-COL_ID.
    READ TABLE GT_SPMON INTO GS_SPMON WITH KEY FIELDNAME_A = LS_FCAT-FIELDNAME.
    IF SY-SUBRC EQ 0.

      READ TABLE <GT_MAIN_DISP_100> ASSIGNING FIELD-SYMBOL(<LS_MAIN>) INDEX LS_CELLS-ROW_ID.
      CLEAR GS_MAIN.
      MOVE-CORRESPONDING <LS_MAIN> TO GS_MAIN.

      READ TABLE GT_2160 INTO DATA(LS_2160) WITH KEY RQWRK = GS_MAIN-WERKS
                                                          MATNR = GS_MAIN-MATNR
                                                          SCRGRADE = GS_MAIN-ATWRT
                                                          ZSEQ = GS_MAIN-ZSEQ
                                                          RQMON = GS_SPMON-SPMON.
      IF SY-SUBRC EQ 0.
        IF LS_2160-EBELN IS NOT INITIAL.
          CONTINUE. " 이미 sto 오더 발행된 셀은 건너 띄어준다.
        ELSE.
          APPEND LS_2160 TO GT_2160_CHG.

*          LT_2170 = VALUE #( FOR LW_2170 IN GT_2170 WHERE ( RQWRK = GS_MAIN-WERKS
*                                                                       AND  MATNR = GS_MAIN-MATNR
*                                                                       AND SCRGRADE = GS_MAIN-ATWRT
*                                                                       AND EINDT BETWEEN GS_SPMON-FRDATE AND GS_SPMON-TODATE )
*                                                                       ( CORRESPONDING #( LW_2170 ) ) ).
*
*          APPEND LINES OF LT_2170 TO GT_2170_CHG.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDLOOP.

  IF GT_2160_CHG[] IS INITIAL.
    RETURN.
  ENDIF.

  CLEAR GV_ANSWER.
  PERFORM POPUP_TO_CONFIRM_STEP USING 'N'
    ' '
    '선택 수량에 대한 사내이체(STO) 오더를 발행 하시겠습니까?'
    '오더생성 확인'.
  IF GV_ANSWER NE 'J'.
    MESSAGE S003 DISPLAY LIKE 'E' WITH '작업 취소 되었습니다.'.
    RETURN.
  ENDIF.

  PERFORM CREATE_ORDER CHANGING LV_CHK_ERR.
  IF LV_CHK_ERR = ABAP_TRUE.
    RETURN.
  ENDIF.

* 대상정보 추출.
  PERFORM GET_DATA.

* 대상정보 추출.
  PERFORM SET_DISP_TABLE.

  PERFORM SET_SCREEN_101.
  PERFORM SET_WITH_MAIN USING GV_CHK_DETAIL.

* 화면 초기화
  PERFORM REFRESH_0100.
  PERFORM REFRESH_0101.

  CLEAR : GV_CHK_EDIT, GV_CHK_EDIT_101.

  MESSAGE S003 WITH '사내이체(STO) 오더 생성 하였습니다.'.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROC_AUTO_REJECT_PO
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PROC_AUTO_REJECT_PO .

  DATA : LT_CELLS TYPE LVC_T_CENO.
  DATA : LV_ROW TYPE I.
  DATA : LT_2161_BACKUP TYPE TABLE OF ZGTPPT2161.
  DATA : LV_CHK_ERR.

  IF GV_CHK_EDIT IS NOT INITIAL.
    MESSAGE S003 DISPLAY LIKE 'E' WITH '수정중인 데이터가 있습니다. 저장후 취소가능합니다.'.
    RETURN.
  ENDIF.

  REFRESH : GT_2160_CHG.

  GO_GRID_0100->GET_SELECTED_CELLS_ID(
    IMPORTING
     ET_CELLS = LT_CELLS ).                " Cell IDs

  IF LT_CELLS[] IS INITIAL.
    RETURN.
  ENDIF.

  IF GT_2161 IS NOT INITIAL.
    LT_2161_BACKUP = GT_2161.
  ENDIF.

  LOOP AT LT_CELLS INTO DATA(LS_CELLS).

    READ TABLE GT_FIELDCAT_0100 INTO DATA(LS_FCAT) INDEX LS_CELLS-COL_ID.
    READ TABLE GT_SPMON INTO GS_SPMON WITH KEY FIELDNAME_A = LS_FCAT-FIELDNAME.
    IF SY-SUBRC EQ 0.

      READ TABLE <GT_MAIN_DISP_100> ASSIGNING FIELD-SYMBOL(<LS_MAIN>) INDEX LS_CELLS-ROW_ID.
      CLEAR GS_MAIN.
      MOVE-CORRESPONDING <LS_MAIN> TO GS_MAIN.

      READ TABLE GT_2160 INTO DATA(LS_2160) WITH KEY RQWRK = GS_MAIN-WERKS
                                                          MATNR = GS_MAIN-MATNR
                                                          SCRGRADE = GS_MAIN-ATWRT
                                                          ZSEQ = GS_MAIN-ZSEQ
                                                          RQMON = GS_SPMON-SPMON.
      IF SY-SUBRC EQ 0.
        IF LS_2160-EBELN IS INITIAL.
          CONTINUE. " 이미 sto 오더 취소된 셀은 건너 띄어준다.
        ELSE.
*    ZGTPPT2161 원본 원장
          PERFORM GET_DAILY_REQ.
          IF LINE_EXISTS(  GT_2161[ RQSTA = 'F' RQMON = GS_SPMON-SPMON ] ).
            IF LT_2161_BACKUP[] IS NOT INITIAL.
              GT_2161 = LT_2161_BACKUP.
            ENDIF.
            MESSAGE S006 DISPLAY LIKE 'E' WITH '출하요청된 오더는 선택할 수 없습니다.'.
            RETURN.
          ENDIF.

          SELECT SINGLE EBELN, EBELP FROM EKPO
              INTO @DATA(LS_EKPO)
              WHERE EBELN = @LS_2160-EBELN
              AND EBELP = @LS_2160-EBELP.
          IF SY-SUBRC EQ 0 .
            SELECT SINGLE EBELN, EBELP,
                       SUM(
                       CASE SHKZG WHEN 'S' THEN MENGE
                                        WHEN 'H' THEN MENGE * -1
                          END ) AS MENGE
                 FROM MSEG
                WHERE EBELN = @LS_2160-EBELN
                AND EBELP = @LS_2160-EBELP
                GROUP BY EBELN, EBELP
                INTO @DATA(LS_CHK_MENGE).

            IF SY-SUBRC EQ 0 AND LS_CHK_MENGE-MENGE > 0.
              IF LT_2161_BACKUP[] IS NOT INITIAL.
                GT_2161 = LT_2161_BACKUP.
              ENDIF.
              MESSAGE S006 DISPLAY LIKE 'E' WITH '입고처리된 오더는 선택할 수 없습니다.'.
              RETURN.
            ELSE.

              APPEND LS_2160 TO GT_2160_CHG.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDLOOP.

  IF GT_2160_CHG[] IS INITIAL.
    RETURN.
  ENDIF.

  IF LT_2161_BACKUP[] IS NOT INITIAL.
    GT_2161 = LT_2161_BACKUP.
  ENDIF.

  CLEAR GV_ANSWER.
  PERFORM POPUP_TO_CONFIRM_STEP USING 'N'
    ' '
    '선택 사내이체(STO) 오더를 취소 하시겠습니까?'
    '오더취소 확인'.
  IF GV_ANSWER NE 'J'.
    MESSAGE S003 DISPLAY LIKE 'E' WITH '작업 취소 되었습니다.'.
    RETURN.
  ENDIF.

  PERFORM REJECT_PO CHANGING LV_CHK_ERR.
  IF LV_CHK_ERR = ABAP_TRUE.
    RETURN.
  ENDIF.

  IF GT_2160_CHG[] IS NOT INITIAL.
    MODIFY ZGTPPT2160 FROM TABLE GT_2160_CHG.
    IF SY-SUBRC NE 0.
      ROLLBACK WORK.
      MESSAGE S003 DISPLAY LIKE 'E' WITH '사내 이체가 취소 저장중 오류로 데이터 저장되지 않았습니다.'.
      RETURN.
    ENDIF.
  ENDIF.

* 대상정보 추출.
  PERFORM GET_DATA.

* 대상정보 추출.
  PERFORM SET_DISP_TABLE.

  PERFORM SET_SCREEN_101.
  PERFORM SET_WITH_MAIN USING GV_CHK_DETAIL.

* 화면 초기화
  PERFORM REFRESH_0100.
  PERFORM REFRESH_0101.

  CLEAR : GV_CHK_EDIT, GV_CHK_EDIT_101.

  MESSAGE S003 WITH '사내이체(STO) 오더 삭제 하였습니다.'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CREATE_ORDER
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- LV_CHK_ERR
*&---------------------------------------------------------------------*
FORM CREATE_ORDER  CHANGING PV_CHK_ERR.

  DATA : LT_1010 TYPE TABLE OF ZGTPPT1010.
  DATA : LS_POHEADER TYPE BAPIMEPOHEADER.
  DATA : LS_POHEADERX TYPE BAPIMEPOHEADERX.
  DATA : LV_PO_NO TYPE BAPIMEPOHEADER-PO_NUMBER.
  DATA : LT_RETURN TYPE TABLE OF BAPIRET2.
  DATA : LT_POITEM TYPE TABLE OF BAPIMEPOITEM.
  DATA : LT_POITEMX TYPE TABLE OF BAPIMEPOITEMX.
  DATA : LT_POSCHEDULE  TYPE TABLE OF BAPIMEPOSCHEDULE.
  DATA : LT_POSCHEDULEX TYPE TABLE OF BAPIMEPOSCHEDULX.
  DATA : LT_POTEXTITEM TYPE TABLE OF BAPIMEPOTEXT.
  DATA : LV_STRING TYPE CHAR200.
  DATA : LV_STRING2 TYPE CHAR200.
  DATA : LV_CHK_ERR.
  DATA : LT_DISP_MESSAGE TYPE TABLE OF ZTESMESSAGE.
  DATA : LS_DISP_MESSAGE TYPE ZTESMESSAGE.
  DATA : LV_QUANTITY TYPE BAPIMEPOITEM-QUANTITY.
  DATA : LT_2161_BACKUP TYPE TABLE OF ZGTPPT2161..


  SELECT * FROM ZGTPPT1010
    INTO TABLE LT_1010
   WHERE MODULE_KIND = 'PP'
      AND CODEGRP = '2070'
      AND FLD_01 = P_WERKS.

  SORT LT_1010 BY FLD_02.

  LOOP AT GT_2160_CHG ASSIGNING FIELD-SYMBOL(<LS_2160>).

    CLEAR : LS_POHEADER, LS_POHEADERX, LV_PO_NO.
    REFRESH : LT_RETURN, LT_POITEM, LT_POITEMX, LT_POSCHEDULE, LT_POSCHEDULEX.

    CLEAR LV_QUANTITY.

    LV_QUANTITY = <LS_2160>-RQMNG.

    READ TABLE GT_SPMON INTO DATA(LS_SPMON) WITH KEY SPMON = <LS_2160>-RQMON.


    SELECT SINGLE LGPRO FROM MARC
      INTO @DATA(LV_LGPRO)
     WHERE WERKS = @<LS_2160>-RQWRK
        AND MATNR = @<LS_2160>-MATNR.

    READ TABLE LT_1010 INTO DATA(LS_1010) WITH KEY FLD_02 = <LS_2160>-RQWRK BINARY SEARCH.
    IF SY-SUBRC EQ 0.
* Header Set
      LS_POHEADER-COMP_CODE = LS_1010-FLD_05.
      LS_POHEADER-DOC_TYPE = 'UB'.
      LS_POHEADER-CREAT_DATE = SY-DATUM.
      LS_POHEADER-ITEM_INTVL = '0010'.
      LS_POHEADER-PURCH_ORG = LS_1010-FLD_03.
      LS_POHEADER-PUR_GROUP = LS_1010-FLD_04.
      LS_POHEADER-DOC_DATE = SY-DATUM.
      LS_POHEADER-SUPPL_PLNT = P_WERKS.
* HeaderX Set
      LS_POHEADERX-COMP_CODE = ABAP_TRUE.
      LS_POHEADERX-DOC_TYPE = ABAP_TRUE.
      LS_POHEADERX-CREAT_DATE = ABAP_TRUE.
      LS_POHEADERX-ITEM_INTVL = ABAP_TRUE.
      LS_POHEADERX-PURCH_ORG = ABAP_TRUE.
      LS_POHEADERX-PUR_GROUP = ABAP_TRUE.
      LS_POHEADERX-DOC_DATE = ABAP_TRUE.
      LS_POHEADERX-SUPPL_PLNT = ABAP_TRUE.

* Item Set
      APPEND INITIAL LINE TO LT_POITEM ASSIGNING FIELD-SYMBOL(<LS_ITEM>).
      <LS_ITEM>-PO_ITEM = '0010'.
      <LS_ITEM>-MATERIAL = <LS_2160>-MATNR.
      <LS_ITEM>-PLANT = <LS_2160>-RQWRK.
      <LS_ITEM>-STGE_LOC = LV_LGPRO.
      <LS_ITEM>-QUANTITY = LV_QUANTITY.
      <LS_ITEM>-PO_UNIT = <LS_2160>-MEINS.
      <LS_ITEM>-ITEM_CAT = 'U'.
* ItemX Set
      APPEND INITIAL LINE TO LT_POITEMX ASSIGNING FIELD-SYMBOL(<LS_ITEMX>).
      <LS_ITEMX>-PO_ITEM = '0010'.
      <LS_ITEMX>-MATERIAL = ABAP_TRUE.
      <LS_ITEMX>-PLANT = ABAP_TRUE.
      <LS_ITEMX>-STGE_LOC = ABAP_TRUE.
      <LS_ITEMX>-QUANTITY = ABAP_TRUE.
      <LS_ITEMX>-PO_UNIT = ABAP_TRUE.
      <LS_ITEMX>-ITEM_CAT = ABAP_TRUE.

* Schedule Set
      APPEND INITIAL LINE TO LT_POSCHEDULE ASSIGNING FIELD-SYMBOL(<LS_POSCHEDULE>).
      <LS_POSCHEDULE>-PO_ITEM = '0010'.
      <LS_POSCHEDULE>-SCHED_LINE = '0001'.
      <LS_POSCHEDULE>-DELIVERY_DATE = LS_SPMON-TODATE.
      <LS_POSCHEDULE>-QUANTITY = LV_QUANTITY.
* ScheduleX Set
      APPEND INITIAL LINE TO LT_POSCHEDULEX ASSIGNING FIELD-SYMBOL(<LS_POSCHEDULEX>).
      <LS_POSCHEDULEX>-PO_ITEM = '0010'.
      <LS_POSCHEDULEX>-SCHED_LINE = '0001'.
      <LS_POSCHEDULEX>-DELIVERY_DATE = ABAP_TRUE.
      <LS_POSCHEDULEX>-QUANTITY = ABAP_TRUE.

* Item Text
      APPEND INITIAL LINE TO LT_POTEXTITEM ASSIGNING FIELD-SYMBOL(<LS_POTEXTITEM>).
      <LS_POTEXTITEM>-PO_ITEM = '0010'.
      <LS_POTEXTITEM>-TEXT_ID = 'F01'.
      <LS_POTEXTITEM>-TEXT_FORM = '*'.
      <LS_POTEXTITEM>-TEXT_LINE = <LS_2160>-SCRGRADE.


      CALL FUNCTION 'BAPI_PO_CREATE1'
        EXPORTING
          POHEADER         = LS_POHEADER
          POHEADERX        = LS_POHEADERX
        IMPORTING
          EXPPURCHASEORDER = LV_PO_NO
        TABLES
          RETURN           = LT_RETURN
          POITEM           = LT_POITEM
          POITEMX          = LT_POITEMX
          POSCHEDULE       = LT_POSCHEDULE
          POSCHEDULEX      = LT_POSCHEDULEX
          POTEXTITEM       = LT_POTEXTITEM.

      READ TABLE LT_RETURN INTO DATA(LS_RETURN) WITH KEY TYPE = 'E'.
      IF SY-SUBRC EQ 0.
        CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
        CLEAR : LV_STRING, LV_STRING2.
        LV_STRING = | 요청플랜트 ({ <LS_2160>-RQWRK }) 자재({ <LS_2160>-MATNR }), 일자 ({ LS_SPMON-TODATE }) : | .
        LV_STRING2 = LS_RETURN-MESSAGE.
        MESSAGE S006 DISPLAY LIKE 'E' WITH LV_STRING LV_STRING2.
        PV_CHK_ERR = ABAP_TRUE.
        RETURN.
      ELSE.
        <LS_2160>-EBELN = LV_PO_NO.
        <LS_2160>-EBELP = '0010'.
      ENDIF.
    ENDIF.
  ENDLOOP.

  CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
    EXPORTING
      WAIT = 'X'.

  REFRESH LT_DISP_MESSAGE.
  DATA : LV_SEQ(6) TYPE N.
* 등급 존재건은 BDC진행
  LOOP AT GT_2160_CHG ASSIGNING <LS_2160> WHERE SCRGRADE IS NOT INITIAL.
    CLEAR LS_DISP_MESSAGE.
    PERFORM BDC_CHG_CONFIG USING <LS_2160> CHANGING LV_CHK_ERR LS_DISP_MESSAGE.
    IF LV_CHK_ERR = ABAP_TRUE.
      ADD 1 TO LV_SEQ.
      LS_DISP_MESSAGE-MSGSQ = LV_SEQ.
      APPEND LS_DISP_MESSAGE TO LT_DISP_MESSAGE.
    ENDIF.
  ENDLOOP.

  IF GT_2160_CHG[] IS NOT INITIAL.
    MODIFY ZGTPPT2160 FROM TABLE GT_2160_CHG.
    IF SY-SUBRC NE 0.
      ROLLBACK WORK.
      MESSAGE S003 DISPLAY LIKE 'E' WITH '사내이체(STO) 오더를 발행 저장중 오류 발생하였습니다.'.
      RETURN.
    ENDIF.
  ENDIF.


  IF LT_DISP_MESSAGE[] IS NOT INITIAL.
    CALL FUNCTION 'Z_TE_POPUP_TO_ERROR_MESSAGE'
      TABLES
        XMSG = LT_DISP_MESSAGE.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form BDC_CHG_CONFIG
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> <LS_2160>
*&      <-- LV_CHK_ERR
*&      <-- LS_DISP_MESSAGE
*&---------------------------------------------------------------------*
FORM BDC_CHG_CONFIG  USING   PS_2160 TYPE ZGTPPT2160
                     CHANGING PV_CHK_ERR
                                   PS_DISP_MESSAGE TYPE ZTESMESSAGE.

  DATA : LV_ATWRT TYPE ATWRT.
  REFRESH : GT_BDCDATA, GT_MESSTAB.

  CLEAR LV_ATWRT.
  CASE PS_2160-SCRGRADE.
    WHEN 'G1'.
      LV_ATWRT = 'X08      1'.
    WHEN 'G2'.
      LV_ATWRT = 'X08      2'.
    WHEN 'G3'.
      LV_ATWRT = 'X08      3'.
    WHEN 'G4'.
      LV_ATWRT = 'X08      4'.
  ENDCASE.


  __SETTING_BDC_PARAMS.

  __BDC_DYNPRO 'SAPLMEGUI' '0014'.
  __BDC_FIELD : 'BDC_OKCODE' '=MECHOB',
                      'MEPO_TOPLINE-BSART' 'UB'.

  __BDC_DYNPRO 'SAPLMEGUI' '0002'.
  __BDC_FIELD : 'BDC_OKCODE' '=MEOK',
                      'MEPO_SELECT-EBELN' PS_2160-EBELN,
                      'MEPO_SELECT-BSTYP_F' ABAP_TRUE.

  __BDC_DYNPRO 'SAPLMEGUI' '0014'.
  __BDC_FIELD : 'BDC_OKCODE' '=MEPO1319CONFIG'.

  __BDC_DYNPRO 'SAPLCEI0' '0109'.
  __BDC_FIELD : 'BDC_OKCODE' '=BACK',
                      'RCTMS-MNAME(01)' 'BT_AA_GRADE',
                      'RCTMS-MWERT(01)' LV_ATWRT.


  __BDC_DYNPRO 'SAPLMEGUI' '0014'.
  __BDC_FIELD : 'BDC_OKCODE' '=MESAVE'.

  __BDC_TRANSACTION 'ME22N'.
  LOOP AT GT_MESSTAB INTO DATA(LS_MESSTAB) WHERE MSGTYP = 'A'
                                                         OR MSGTYP = 'E'
                                                         OR MSGTYP = 'X'.

    PS_DISP_MESSAGE-MSGID = LS_MESSTAB-MSGID.
    PS_DISP_MESSAGE-MSGNO = LS_MESSTAB-MSGNR..
    PS_DISP_MESSAGE-MSGTY = LS_MESSTAB-MSGTYP.
    PS_DISP_MESSAGE-MSGV1 = LS_MESSTAB-MSGV1.
    PS_DISP_MESSAGE-MSGV2 = LS_MESSTAB-MSGV2.
    PS_DISP_MESSAGE-MSGV3 = LS_MESSTAB-MSGV3.
    PS_DISP_MESSAGE-MSGV4 = LS_MESSTAB-MSGV4.
*    PS_DISP_MESSAGE-MSGTX = LS_MESSTAB-MESSAGE.

    PV_CHK_ERR = 'E'.
    RETURN.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form REJECT_PO
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- LV_CHK_ERR
*&---------------------------------------------------------------------*
FORM REJECT_PO  CHANGING PV_CHK_ERR.

  DATA : LV_NUMBER TYPE BAPIMEPOHEADER-PO_NUMBER.
  DATA: LT_RETURN TYPE TABLE OF BAPIRET2.
  DATA: LT_POITEM TYPE TABLE OF BAPIMEPOITEM.
  DATA: LT_POITEMX TYPE TABLE OF BAPIMEPOITEMX.
  DATA : LV_STRING TYPE CHAR200.
  DATA : LV_STRING2 TYPE CHAR200.

  LOOP AT GT_2160_CHG ASSIGNING FIELD-SYMBOL(<LS_2160>).

    CLEAR LV_NUMBER.
    REFRESH : LT_RETURN, LT_POITEM, LT_POITEMX.

    LV_NUMBER = <LS_2160>-EBELN.
* Item Set
    APPEND INITIAL LINE TO LT_POITEM ASSIGNING FIELD-SYMBOL(<LS_POITEM>).
    <LS_POITEM>-PO_ITEM = <LS_2160>-EBELP.
    <LS_POITEM>-DELETE_IND = ABAP_TRUE.
* ItemX Set
    APPEND INITIAL LINE TO LT_POITEMX ASSIGNING FIELD-SYMBOL(<LS_POITEMX>).
    <LS_POITEMX>-PO_ITEM = <LS_2160>-EBELP.
    <LS_POITEMX>-PO_ITEMX = ABAP_TRUE.
    <LS_POITEMX>-DELETE_IND = ABAP_TRUE.

    CALL FUNCTION 'BAPI_PO_CHANGE'
      EXPORTING
        PURCHASEORDER = LV_NUMBER
*       TESTRUN       = ABAP_TRUE
      TABLES
        RETURN        = LT_RETURN
        POITEM        = LT_POITEM
        POITEMX       = LT_POITEMX.

    READ TABLE LT_RETURN INTO DATA(LS_RETURN) WITH KEY TYPE = 'E'.
    IF SY-SUBRC EQ 0.
      CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

      READ TABLE GT_SPMON INTO GS_SPMON WITH KEY SPMON = <LS_2160>-RQMON.

      CLEAR : LV_STRING, LV_STRING2.
      LV_STRING = | 요청플랜트 ({ <LS_2160>-RQWRK }) 자재({ <LS_2160>-MATNR }), 일자 ({ GS_SPMON-TODATE }) : | .
      LV_STRING2 = LS_RETURN-MESSAGE.
      MESSAGE S006 DISPLAY LIKE 'E' WITH LV_STRING LV_STRING2.
      PV_CHK_ERR = ABAP_TRUE.
      RETURN.
    ELSE.
      CLEAR : <LS_2160>-EBELN, <LS_2160>-EBELP.

    ENDIF.
  ENDLOOP.

  CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
    EXPORTING
      WAIT = 'X'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_max_seq
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LS_MAIN
*&      <-- LV_MAX_ZSEQ
*&---------------------------------------------------------------------*
FORM GET_MAX_SEQ  TABLES PT_2160 STRUCTURE ZGTPPT2160
                        USING    PS_MAIN LIKE GS_MAIN
                  CHANGING PV_MAX_ZSEQ TYPE I..

  DATA : LT_2160 TYPE TABLE OF ZGTPPT2160.

  LT_2160 = VALUE #( FOR LW_2160 IN GT_2160 WHERE ( RQWRK = PS_MAIN-WERKS
                                                           AND  MATNR = PS_MAIN-MATNR
                                                           AND  SCRGRADE = PS_MAIN-ATWRT )
                        ( CORRESPONDING #( LW_2160 ) ) ).

  REFRESH PT_2160[].
  PT_2160[] = LT_2160.

  SORT LT_2160 BY ZSEQ DESCENDING.
  READ TABLE LT_2160 INTO DATA(LS_2160) INDEX 1.
  IF SY-SUBRC EQ 0.
    PV_MAX_ZSEQ = LS_2160-ZSEQ.
  ELSE.
    PV_MAX_ZSEQ = 0.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form COPY_LINE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM COPY_LINE .

  DATA : LT_CELLS TYPE LVC_T_CENO.
  DATA : LT_2160 TYPE TABLE OF ZGTPPT2160.
  DATA : LT_CHK_MAIN LIKE TABLE OF GS_MAIN.
  DATA : LV_ROW TYPE I.
  DATA : LS_MAIN TYPE REF TO DATA.
  DATA : LV_CHK_ERR.
  FIELD-SYMBOLS : <LS_MAIN> TYPE ANY.

  CREATE DATA LS_MAIN LIKE LINE OF <GT_MAIN_DISP_100>.
  ASSIGN LS_MAIN->* TO <LS_MAIN>.

  GO_GRID_0100->GET_SELECTED_CELLS_ID(
    IMPORTING
     ET_CELLS = LT_CELLS ).                " Cell IDs

  IF LT_CELLS[] IS INITIAL.
    RETURN.
  ENDIF.

  DATA(LT_CHK_CELL) = LT_CELLS.
  SORT LT_CHK_CELL BY ROW_ID.
  DELETE ADJACENT DUPLICATES FROM LT_CHK_CELL COMPARING ROW_ID.
  IF LINES( LT_CHK_CELL ) NE 1.
    MESSAGE S003 DISPLAY LIKE 'E' WITH '하나의 열만 Copy 할 수 있습니다.'.
    RETURN.
  ENDIF.

  READ TABLE LT_CELLS INTO DATA(LS_CELLS) INDEX 1.

  READ TABLE <GT_MAIN_DISP_100> ASSIGNING FIELD-SYMBOL(<LS_MIAN>) INDEX LS_CELLS-ROW_ID.
  CLEAR GS_MAIN.
  MOVE-CORRESPONDING <LS_MIAN> TO GS_MAIN.

  REFRESH LT_CHK_MAIN.
  LT_CHK_MAIN = VALUE #( FOR LW_MAIN IN GT_MAIN WHERE ( WERKS = GS_MAIN-WERKS
                                                               AND  MATNR = GS_MAIN-MATNR
                                                               AND  ATWRT = GS_MAIN-ATWRT )
                            ( CORRESPONDING #( LW_MAIN ) ) ).

  SORT LT_CHK_MAIN BY ZSEQ DESCENDING.
  READ TABLE LT_CHK_MAIN INTO DATA(LS_CHK_MAIN) INDEX 1.

  CLEAR GS_MAIN-OVERDUE.
  CLEAR GS_MAIN-ZREMARK.
  GS_MAIN-DETAIL = ICON_DETAIL.
  GS_MAIN-ZSEQ = LS_CHK_MAIN-ZSEQ + 1.
  APPEND GS_MAIN TO GT_MAIN.

  MOVE-CORRESPONDING GS_MAIN TO <LS_MAIN>.
  APPEND <LS_MAIN> TO <GT_MAIN_DISP_100>.

* 대상정보 추출.
  PERFORM SET_SCREEN_101.
  PERFORM SET_WITH_MAIN USING GV_CHK_DETAIL.

* 화면 초기화
  PERFORM REFRESH_0100.
  PERFORM REFRESH_0101.

  GV_CHK_EDIT = ABAP_TRUE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form DELETE_LINE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM DELETE_LINE .


  DATA : LT_CELLS TYPE LVC_T_CENO.
  DATA : LT_2160 TYPE TABLE OF ZGTPPT2160.
  DATA : LT_CHK_MAIN LIKE TABLE OF GS_MAIN.
  DATA : LV_ROW TYPE I.
  DATA : LV_CHK_USING.
  DATA : LV_CHK_ERR.

  GO_GRID_0100->GET_SELECTED_CELLS_ID(
    IMPORTING
     ET_CELLS = LT_CELLS ).                " Cell IDs

  IF LT_CELLS[] IS INITIAL.
    RETURN.
  ENDIF.

  DATA(LT_CHK_CELL) = LT_CELLS.
  SORT LT_CHK_CELL BY ROW_ID.
  DELETE ADJACENT DUPLICATES FROM LT_CHK_CELL COMPARING ROW_ID.
  IF LINES( LT_CHK_CELL ) NE 1.
    MESSAGE S003 DISPLAY LIKE 'E' WITH '하나의 열만 Delete 할 수 있습니다.'.
    RETURN.
  ENDIF.

  REFRESH GT_2160_CHG.

  READ TABLE LT_CELLS INTO DATA(LS_CELLS) INDEX 1.

  READ TABLE <GT_MAIN_DISP_100> ASSIGNING FIELD-SYMBOL(<LS_MIAN>) INDEX LS_CELLS-ROW_ID.
  CLEAR GS_MAIN.
  MOVE-CORRESPONDING <LS_MIAN> TO GS_MAIN.

  PERFORM CHECK_DELETE_LINE CHANGING LV_CHK_USING LV_CHK_ERR.

  IF LV_CHK_ERR IS NOT INITIAL.
    RETURN.
  ENDIF.

  IF LV_CHK_USING = ABAP_TRUE.
    CLEAR GV_ANSWER.
    PERFORM POPUP_TO_CONFIRM_STEP USING 'N'
      ' '
      '등록된 정보가 즉시 삭제 됩니다. 계속 진행하시겠습니까?'
      'Delete 확인'.
    IF GV_ANSWER NE 'J'.
      MESSAGE S003 DISPLAY LIKE 'E' WITH '작업 취소 되었습니다.'.
      RETURN.
    ENDIF.

    PERFORM GET_DAILY_REQ.

    IF GT_2160_CHG[] IS NOT INITIAL.
      DELETE ZGTPPT2160 FROM TABLE GT_2160_CHG.
      IF SY-SUBRC NE 0.
        ROLLBACK WORK.
        MESSAGE S003 DISPLAY LIKE 'E' WITH 'Delete 중 오류 발생하였습니다.'.
        RETURN.
      ENDIF.
    ENDIF.

    IF GT_2161[] IS NOT INITIAL.
      DELETE ZGTPPT2161 FROM TABLE GT_2161.
      IF SY-SUBRC NE 0.
        ROLLBACK WORK.
        MESSAGE S003 DISPLAY LIKE 'E' WITH 'Delete 중 오류 발생하였습니다.'.
        RETURN.
      ENDIF.
    ENDIF.
    COMMIT WORK AND WAIT.

    SELECT * FROM ZGTPPT2160 INTO TABLE GT_2160
      WHERE PDWRK = P_WERKS
        AND SPGCD = P_SPGCD
        AND RQWRK IN GR_WERKS
        AND MATNR IN S_MATNR
        AND RQMON IN S_SPMON.


  ENDIF.

  IF GS_MAIN-ZSEQ = 0.
    ASSIGN COMPONENT 'OVERDUE' OF STRUCTURE <LS_MIAN> TO FIELD-SYMBOL(<LV_OVERDUE>).
    CLEAR <LV_OVERDUE>.

    LOOP AT GT_SPMON INTO GS_SPMON.
      ASSIGN COMPONENT GS_SPMON-FIELDNAME_A OF STRUCTURE <LS_MIAN> TO FIELD-SYMBOL(<LV_VALUE>).
      ASSIGN COMPONENT GS_SPMON-FIELDNAME_A_CHK OF STRUCTURE <LS_MIAN> TO FIELD-SYMBOL(<LV_CHK>).
      CLEAR : <LV_VALUE>, <LV_CHK>.
    ENDLOOP.
    UNASSIGN <LS_MIAN>.

  ELSE.
    DELETE GT_MAIN WHERE WERKS = GS_MAIN-WERKS
                          AND MATNR = GS_MAIN-MATNR
                          AND ATWRT = GS_MAIN-ATWRT
                          AND ZSEQ = GS_MAIN-ZSEQ.
    UNASSIGN <LS_MIAN>.
    DELETE <GT_MAIN_DISP_100> INDEX LS_CELLS-ROW_ID.
  ENDIF.

* 대상정보 추출.
  PERFORM SET_SCREEN_101.
  PERFORM SET_WITH_MAIN USING GV_CHK_DETAIL.

* 화면 초기화
  PERFORM REFRESH_0100.
  PERFORM REFRESH_0101.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_DELETE_LINE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- LV_CHK_USING
*&      <-- PERFORM
*&      <-- SET_SCREEN_101
*&---------------------------------------------------------------------*
FORM CHECK_DELETE_LINE  CHANGING PV_CHK_USING
                                                 PV_CHK_ERR.

  IF GS_MAIN-DETAIL NE ICON_DETAIL.
    PV_CHK_ERR = ABAP_TRUE.
    MESSAGE S006 DISPLAY LIKE 'E' WITH '상세 정보 수정중인 라인이므로 삭제할수 없습니다.'.
    RETURN.
  ENDIF.

  GT_2160_CHG = VALUE #( FOR LW_2160 IN GT_2160 WHERE ( RQWRK = GS_MAIN-WERKS
                                                                      AND   MATNR = GS_MAIN-MATNR
                                                                      AND   SCRGRADE = GS_MAIN-ATWRT
                                                                      AND   ZSEQ = GS_MAIN-ZSEQ )
                                    ( CORRESPONDING #( LW_2160 ) ) ).

  IF GT_2160_CHG[] IS NOT INITIAL.
    PV_CHK_USING = ABAP_TRUE.
  ENDIF.

  LOOP AT GT_2160_CHG INTO DATA(LS_2160).
    IF LS_2160-EBELN IS NOT INITIAL.
      PV_CHK_ERR = ABAP_TRUE.
      MESSAGE S006 DISPLAY LIKE 'E' WITH LS_2160-RQMON '월 사내이체(STO) 오더 존재하여 삭제할수 없습니다.'.
      RETURN.
    ENDIF.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROC_CALC
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PROC_CALC .



ENDFORM.
*&---------------------------------------------------------------------*
*& Form CAL_MAIN_101
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LS_MAIN
*&---------------------------------------------------------------------*
FORM CAL_MAIN_101  USING    PS_MAIN LIKE GS_MAIN_101.

  DATA : LV_WORKING_DAYS TYPE I.
  DATA : LV_CAL_MENGE TYPE AFPO-PSAMG.
  DATA : LV_FIXED_MENGE TYPE AFPO-PSAMG.
  DATA : LV_LAST_FIXED_MENGE TYPE AFPO-PSAMG.
  DATA : LV_CUR_DATE TYPE SY-DATUM.
  DATA : LV_LAST_DATE TYPE SY-DATUM.
  DATA : LV_CHK_CONFIRM.

  CLEAR GS_SPMON.
  READ TABLE GT_SPMON INTO GS_SPMON WITH KEY SPMON = PS_MAIN-SPMON.

* 가용일자--> 월별 수량 분배를 위해 현재일 이후건에 대한 일별 평균 수량을 구해준다.
  LV_CUR_DATE = GS_SPMON-FRDATE.

  DO.
    IF LV_CUR_DATE > GS_SPMON-TODATE.
      EXIT.
    ENDIF.

    IF  LV_CUR_DATE <= PS_MAIN-DATE.

      READ TABLE GT_MAIN_101 INTO DATA(LS_MAIN_101) WITH KEY DATE = LV_CUR_DATE.
      IF SY-SUBRC EQ 0.
        ADD LS_MAIN_101-PSAMG_R TO LV_CAL_MENGE.
      ENDIF.

    ELSE.

      READ TABLE GT_2161 INTO DATA(LS_2161) WITH KEY RQDAY = LV_CUR_DATE.
      IF SY-SUBRC EQ 0 AND LS_2161-RQSTA = 'F'.
        READ TABLE GT_MAIN_101 INTO LS_MAIN_101 WITH KEY DATE = LV_CUR_DATE.
        IF SY-SUBRC EQ 0.
          ADD LS_MAIN_101-PSAMG_R TO LV_CAL_MENGE.
        ENDIF.
      ELSE.
        READ TABLE GT_DAY_ATTR INTO DATA(LS_DAY_ATTR) WITH KEY DATE = LV_CUR_DATE.
        IF SY-SUBRC EQ 0 AND LS_DAY_ATTR-FREEDAY IS INITIAL.
          ADD 1 TO LV_WORKING_DAYS.
        ENDIF.
      ENDIF.
    ENDIF.

    ADD 1 TO LV_CUR_DATE.

  ENDDO.

  LV_CAL_MENGE = PS_MAIN-TOT_PSAMG - LV_CAL_MENGE.

  IF LV_WORKING_DAYS NE 0.
    PERFORM SET_CAL_MENGE USING LV_CAL_MENGE LV_WORKING_DAYS CHANGING LV_FIXED_MENGE LV_LAST_FIXED_MENGE.

    LOOP AT GT_DAY_ATTR INTO LS_DAY_ATTR WHERE DATE+0(6) = GS_SPMON-SPMON.
      IF LS_DAY_ATTR-FREEDAY NE ABAP_TRUE.
        READ TABLE GT_2161 INTO LS_2161 WITH KEY RQDAY = LS_DAY_ATTR-DATE.
        IF SY-SUBRC EQ 0 AND LS_2161-RQSTA = 'F'.
          CONTINUE.
        ENDIF.

        IF LV_LAST_DATE < LS_DAY_ATTR-DATE.
          LV_LAST_DATE = LS_DAY_ATTR-DATE.
        ENDIF.
      ENDIF.
    ENDLOOP.

  ELSE.
    LV_LAST_FIXED_MENGE = LV_CAL_MENGE.
    LV_LAST_DATE = GS_SPMON-TODATE.
  ENDIF.


  LOOP AT GT_MAIN_101 ASSIGNING FIELD-SYMBOL(<LS_MAIN>) WHERE SPMON = GS_SPMON-SPMON.
    CLEAR <LS_MAIN>-CAL_MARK.

    IF <LS_MAIN>-DATE < PS_MAIN-DATE.
      CONTINUE.
    ENDIF.

    IF PS_MAIN-DATE = GS_SPMON-TODATE.
      <LS_MAIN>-PSAMG_R = <LS_MAIN>-PSAMG_R + LV_CAL_MENGE.
    ELSEIF PS_MAIN-DATE = LV_LAST_DATE.
      <LS_MAIN>-PSAMG_R = <LS_MAIN>-PSAMG_R + LV_CAL_MENGE.
    ELSEIF PS_MAIN-DATE = <LS_MAIN>-DATE.
      CONTINUE.
    ELSEIF PS_MAIN-DATE < <LS_MAIN>-DATE AND LV_CAL_MENGE < 0.
      READ TABLE GT_MAIN_101 ASSIGNING FIELD-SYMBOL(<LS_CAL_MAIN>) WITH KEY SPMON = GS_SPMON-SPMON
                                                                                                  DATE = PS_MAIN-DATE.
      IF <LS_MAIN>-DATE = LV_LAST_DATE.
        ADD LV_LAST_FIXED_MENGE TO <LS_CAL_MAIN>-PSAMG_R.
      ELSE.

        CLEAR LS_DAY_ATTR.
        READ TABLE GT_DAY_ATTR INTO LS_DAY_ATTR WITH KEY DATE = <LS_MAIN>-DATE.
        IF LS_DAY_ATTR-FREEDAY NE ABAP_TRUE.
          CLEAR <LS_MAIN>-PSAMG_R.
          ADD LV_FIXED_MENGE TO <LS_CAL_MAIN>-PSAMG_R.
        ENDIF.
      ENDIF.
    ELSE.
      IF <LS_MAIN>-DATE = LV_LAST_DATE.
        <LS_MAIN>-PSAMG_R = LV_LAST_FIXED_MENGE.
      ELSE.
        CLEAR LS_DAY_ATTR.
        READ TABLE GT_DAY_ATTR INTO LS_DAY_ATTR WITH KEY DATE = <LS_MAIN>-DATE.

        READ TABLE GT_2161 INTO LS_2161 WITH KEY RQDAY = <LS_MAIN>-DATE.
        IF SY-SUBRC EQ 0 AND LS_2161-RQSTA = 'F'.
          CONTINUE.
        ENDIF.

        IF LS_DAY_ATTR-FREEDAY NE ABAP_TRUE.
          <LS_MAIN>-PSAMG_R = LV_FIXED_MENGE.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDLOOP.

* 대상정보 추출.
  PERFORM SET_WITH_MAIN USING GV_CHK_DETAIL.

* 화면 초기화
  PERFORM REFRESH_0100.
  PERFORM REFRESH_0101.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROC_DELIVERY
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PROC_DELIVERY .

  DATA : LT_CELLS TYPE LVC_T_CENO.
  DATA : LT_ROW TYPE LVC_T_ROW.
  DATA : LT_ITEM TYPE TABLE OF ZGTPPSIF0035.

  IF GV_CHK_EDIT_101 IS NOT INITIAL.
    MESSAGE S003 DISPLAY LIKE 'E' WITH '수정중인 데이터가 있습니다. 저장 후 출하요청 가능합니다.'.
    RETURN.
  ENDIF.

  REFRESH GT_2161_CHG.
  FREE GT_2161_CHG.


  GO_GRID_0101->GET_SELECTED_ROWS(
    IMPORTING
      ET_INDEX_ROWS = LT_ROW                 " Indexes of Selected Rows
*      ET_ROW_NO     =                  " Numeric IDs of Selected Rows
  ).

  DELETE LT_ROW WHERE INDEX = 0.

  IF LT_ROW[] IS NOT INITIAL.
    SORT LT_ROW BY INDEX.
    LOOP AT LT_ROW INTO DATA(LS_ROWS).
      APPEND INITIAL LINE TO LT_CELLS ASSIGNING FIELD-SYMBOL(<LS_CELLS>).
      <LS_CELLS>-ROW_ID = LS_ROWS-INDEX.
    ENDLOOP.
  ELSE.
    GO_GRID_0101->GET_SELECTED_CELLS_ID(
      IMPORTING
       ET_CELLS = LT_CELLS ).                " Cell IDs

    IF LT_CELLS[] IS INITIAL.
      RETURN.
    ENDIF.

    SORT LT_CELLS BY ROW_ID.
    DELETE ADJACENT DUPLICATES FROM LT_CELLS COMPARING ROW_ID.
  ENDIF.

  LOOP AT <GT_MAIN_DISP_100> ASSIGNING FIELD-SYMBOL(<LS_MAIN>).
    CLEAR GS_MAIN.
    MOVE-CORRESPONDING <LS_MAIN> TO GS_MAIN.
    IF GS_MAIN-WERKS = GS_DISP_HEADER_101-WERKS AND
       GS_MAIN-MATNR = GS_DISP_HEADER_101-MATNR AND
      GS_MAIN-ATWRT = GS_DISP_HEADER_101-ATWRT AND
      GS_MAIN-ZSEQ = GS_DISP_HEADER_101-ZSEQ.

      LOOP AT LT_CELLS INTO DATA(LS_CELLS).
        READ TABLE GT_MAIN_101 INTO GS_MAIN_101 INDEX LS_CELLS-ROW_ID.

        READ TABLE GT_2160 INTO DATA(LS_TEMP_2160) WITH KEY RQWRK = GS_MAIN-WERKS
                                                                                  MATNR = GS_MAIN-MATNR
                                                                                  SCRGRADE = GS_MAIN-ATWRT
                                                                                  ZSEQ = GS_MAIN-ZSEQ
                                                                                  RQMON = GS_MAIN_101-SPMON.
        IF SY-SUBRC EQ 0 AND LS_TEMP_2160-EBELN IS NOT INITIAL. "STO 발행된 오더만 딜리버리 가능
          READ TABLE GT_2161 INTO DATA(LS_2161) WITH KEY RQDAY = GS_MAIN_101-DATE
                                                                                 DAY_SEQ = GS_MAIN_101-DAY_SEQ.
          IF SY-SUBRC EQ 0 AND LS_2161-RQSTA = '' AND
            LS_2161-RQMNG NE 0 AND LS_2161-UCONF IS NOT INITIAL.

            LS_2161-RQSTA = 'F'.
            APPEND LS_2161 TO GT_2161_CHG.

            APPEND INITIAL LINE TO LT_ITEM ASSIGNING FIELD-SYMBOL(<LS_ITEM>).
            MOVE-CORRESPONDING LS_2161 TO <LS_ITEM>.
            <LS_ITEM>-EBELN = LS_TEMP_2160-EBELN.
            <LS_ITEM>-EBELP = LS_TEMP_2160-EBELP.

          ENDIF.
        ENDIF.
      ENDLOOP.
    ENDIF.
  ENDLOOP.

  IF GT_2161_CHG[] IS INITIAL.
    MESSAGE S003 DISPLAY LIKE 'E' WITH '출하요청 가능한 대상이 없습니다.'.
    RETURN.
  ENDIF.

  CLEAR GV_ANSWER.
  PERFORM POPUP_TO_CONFIRM_STEP USING 'N'
    ' '
    '출하요청 진행합니다. 출하요청후 수량 수정 불가능합니다. 계속 진행하시겠습니까?'
    '출하요청 확인'.
  IF GV_ANSWER NE 'J'.
    MESSAGE S003 DISPLAY LIKE 'E' WITH '작업 취소 되었습니다.'.
    RETURN.
  ENDIF.

  MODIFY ZGTPPT2161 FROM TABLE GT_2161_CHG.
  IF SY-SUBRC NE 0.
    ROLLBACK WORK.
    MESSAGE S003 DISPLAY LIKE 'E' WITH '출하요청 DB 저장 중 오류발생하였습니다.'.
    RETURN.
  ENDIF.

  COMMIT WORK AND WAIT.

  IF LT_ITEM[] IS NOT INITIAL.
    PERFORM SEND_TO_MES TABLES LT_ITEM.
  ENDIF.


  PERFORM SET_SCREEN_101.
  PERFORM SET_WITH_MAIN USING GV_CHK_DETAIL.
  PERFORM REFRESH_0100.
  PERFORM REFRESH_0101.

  MESSAGE S003 WITH '출하요청 완료되었습니다.'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROC_DELIVERY_CANC
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PROC_DELIVERY_CANC .

  DATA : LT_CELLS TYPE LVC_T_CENO.
  DATA : LT_ROW TYPE LVC_T_ROW.
  DATA : LT_ITEM TYPE TABLE OF ZGTPPSIF0035.

  IF GV_CHK_EDIT_101 IS NOT INITIAL.
    MESSAGE S003 DISPLAY LIKE 'E' WITH '수정중인 데이터가 있습니다. 저장 후 출하요청 취소 가능합니다.'.
    RETURN.
  ENDIF.

  REFRESH GT_2161_CHG.
  FREE GT_2161_CHG.


  GO_GRID_0101->GET_SELECTED_ROWS(
    IMPORTING
      ET_INDEX_ROWS = LT_ROW                 " Indexes of Selected Rows
*      ET_ROW_NO     =                  " Numeric IDs of Selected Rows
  ).

  DELETE LT_ROW WHERE INDEX = 0.

  IF LT_ROW[] IS NOT INITIAL.
    SORT LT_ROW BY INDEX.
    LOOP AT LT_ROW INTO DATA(LS_ROWS).
      APPEND INITIAL LINE TO LT_CELLS ASSIGNING FIELD-SYMBOL(<LS_CELLS>).
      <LS_CELLS>-ROW_ID = LS_ROWS-INDEX.
    ENDLOOP.
  ELSE.
    GO_GRID_0101->GET_SELECTED_CELLS_ID(
      IMPORTING
       ET_CELLS = LT_CELLS ).                " Cell IDs

    IF LT_CELLS[] IS INITIAL.
      RETURN.
    ENDIF.

    SORT LT_CELLS BY ROW_ID.
    DELETE ADJACENT DUPLICATES FROM LT_CELLS COMPARING ROW_ID.
  ENDIF.

  LOOP AT <GT_MAIN_DISP_100> ASSIGNING FIELD-SYMBOL(<LS_MAIN>).
    CLEAR GS_MAIN.
    MOVE-CORRESPONDING <LS_MAIN> TO GS_MAIN.
    IF GS_MAIN-WERKS = GS_DISP_HEADER_101-WERKS AND
       GS_MAIN-MATNR = GS_DISP_HEADER_101-MATNR AND
      GS_MAIN-ATWRT = GS_DISP_HEADER_101-ATWRT AND
      GS_MAIN-ZSEQ = GS_DISP_HEADER_101-ZSEQ.

      LOOP AT LT_CELLS INTO DATA(LS_CELLS).
        READ TABLE GT_MAIN_101 INTO GS_MAIN_101 INDEX LS_CELLS-ROW_ID.

        READ TABLE GT_2160 INTO DATA(LS_TEMP_2160) WITH KEY RQWRK = GS_MAIN-WERKS
                                                                                  MATNR = GS_MAIN-MATNR
                                                                                  SCRGRADE = GS_MAIN-ATWRT
                                                                                  ZSEQ = GS_MAIN-ZSEQ
                                                                                  RQMON = GS_MAIN_101-SPMON.
        IF SY-SUBRC EQ 0 AND LS_TEMP_2160-EBELN IS NOT INITIAL. "STO 발행된 오더만 딜리버리 가능
          READ TABLE GT_2161 INTO DATA(LS_2161) WITH KEY RQDAY = GS_MAIN_101-DATE
                                                                          DAY_SEQ = GS_MAIN_101-DAY_SEQ.
          IF SY-SUBRC EQ 0 AND LS_2161-RQSTA = 'F' AND
            LS_2161-RQMNG NE 0 AND LS_2161-UCONF IS NOT INITIAL.
            CLEAR LS_2161-RQSTA.
            APPEND LS_2161 TO GT_2161_CHG.

            APPEND INITIAL LINE TO LT_ITEM ASSIGNING FIELD-SYMBOL(<LS_ITEM>).
            MOVE-CORRESPONDING LS_2161 TO <LS_ITEM>.
            <LS_ITEM>-EBELN = LS_TEMP_2160-EBELN.
            <LS_ITEM>-EBELP = LS_TEMP_2160-EBELP.
            <LS_ITEM>-DELFL = ABAP_TRUE.

          ENDIF.
        ENDIF.
      ENDLOOP.
    ENDIF.
  ENDLOOP.

  IF GT_2161_CHG[] IS INITIAL.
    MESSAGE S003 DISPLAY LIKE 'E' WITH '출하요청 취소 가능한 대상이 없습니다.'.
    RETURN.
  ENDIF.

  CLEAR GV_ANSWER.
  PERFORM POPUP_TO_CONFIRM_STEP USING 'N'
    ' '
    '출하요청 취소 진행합니다. 계속 진행하시겠습니까?'
    '출하요청 취소 확인'.
  IF GV_ANSWER NE 'J'.
    MESSAGE S003 DISPLAY LIKE 'E' WITH '작업 취소 되었습니다.'.
    RETURN.
  ENDIF.

  MODIFY ZGTPPT2161 FROM TABLE GT_2161_CHG.
  IF SY-SUBRC NE 0.
    ROLLBACK WORK.
    MESSAGE S003 DISPLAY LIKE 'E' WITH '출하요청 취소 DB 저장 중 오류발생하였습니다.'.
    RETURN.
  ENDIF.

  COMMIT WORK AND WAIT.

  IF LT_ITEM[] IS NOT INITIAL.
    PERFORM SEND_TO_MES TABLES LT_ITEM.
  ENDIF.


  PERFORM SET_SCREEN_101.
  PERFORM SET_WITH_MAIN USING GV_CHK_DETAIL.
  PERFORM REFRESH_0100.
  PERFORM REFRESH_0101.

  MESSAGE S003 WITH '출하요청 취소 완료되었습니다.'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROC_ADD_101_LINE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PROC_ADD_101_LINE .

  DATA : LT_CELLS TYPE LVC_T_CENO.
  DATA : LT_ROW TYPE LVC_T_ROW.
  DATA : LT_MAIN_101 LIKE TABLE OF GS_MAIN_101.

  GO_GRID_0101->GET_SELECTED_ROWS(
    IMPORTING
      ET_INDEX_ROWS = LT_ROW                 " Indexes of Selected Rows
*      ET_ROW_NO     =                  " Numeric IDs of Selected Rows
  ).

  DELETE LT_ROW WHERE INDEX = 0.

  IF LT_ROW[] IS NOT INITIAL.
    SORT LT_ROW BY INDEX.
    LOOP AT LT_ROW INTO DATA(LS_ROWS).
      APPEND INITIAL LINE TO LT_CELLS ASSIGNING FIELD-SYMBOL(<LS_CELLS>).
      <LS_CELLS>-ROW_ID = LS_ROWS-INDEX.
    ENDLOOP.
  ELSE.
    GO_GRID_0101->GET_SELECTED_CELLS_ID(
      IMPORTING
       ET_CELLS = LT_CELLS ).                " Cell IDs

    SORT LT_CELLS BY ROW_ID.
    DELETE ADJACENT DUPLICATES FROM LT_CELLS COMPARING ROW_ID.
  ENDIF.

  IF LT_CELLS[] IS INITIAL.
    RETURN.
  ENDIF.


  IF LINES( LT_CELLS ) > 1.
    MESSAGE S003 DISPLAY LIKE 'E' WITH '한개의 라인만 선택가능합니다.'.
    RETURN.
  ENDIF.

  READ TABLE LT_CELLS INTO DATA(LS_CELLS) INDEX 1.
  IF SY-SUBRC EQ 0.
    READ TABLE GT_MAIN_101 INTO GS_MAIN_101 INDEX LS_CELLS-ROW_ID.
    IF GS_MAIN_101-DATE < SY-DATUM.
      MESSAGE S003 DISPLAY LIKE 'E' WITH '현재일 이전 계획은 수정불가능합니다.'.
      RETURN.
    ENDIF.

    CLEAR : GS_MAIN_101-STATUS, GS_MAIN_101-ZREMARK, GS_MAIN_101-PSAMG_R, GS_MAIN_101-GUBUN.
    LT_MAIN_101[] = GT_MAIN_101[].
    SORT LT_MAIN_101 BY DATE DAY_SEQ DESCENDING.
    READ TABLE LT_MAIN_101 INTO DATA(LS_TEMP) WITH KEY DATE = GS_MAIN_101-DATE.
    GS_MAIN_101-DAY_SEQ = LS_TEMP-DAY_SEQ + 1.

    APPEND GS_MAIN_101 TO GT_MAIN_101.

  ENDIF.

  PERFORM SET_WITH_MAIN USING GV_CHK_DETAIL.
  PERFORM REFRESH_0101.
  GV_CHK_EDIT_101 = ABAP_TRUE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROC_DELE_101_LINE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PROC_DELE_101_LINE .

  DATA : LT_CELLS TYPE LVC_T_CENO.
  DATA : LT_ROW TYPE LVC_T_ROW.
  DATA : LT_MAIN_101 LIKE TABLE OF GS_MAIN_101.

  GO_GRID_0101->GET_SELECTED_ROWS(
    IMPORTING
      ET_INDEX_ROWS = LT_ROW                 " Indexes of Selected Rows
*      ET_ROW_NO     =                  " Numeric IDs of Selected Rows
  ).

  DELETE LT_ROW WHERE INDEX = 0.

  IF LT_ROW[] IS NOT INITIAL.
    SORT LT_ROW BY INDEX.
    LOOP AT LT_ROW INTO DATA(LS_ROWS).
      APPEND INITIAL LINE TO LT_CELLS ASSIGNING FIELD-SYMBOL(<LS_CELLS>).
      <LS_CELLS>-ROW_ID = LS_ROWS-INDEX.
    ENDLOOP.
  ELSE.
    GO_GRID_0101->GET_SELECTED_CELLS_ID(
      IMPORTING
       ET_CELLS = LT_CELLS ).                " Cell IDs

    SORT LT_CELLS BY ROW_ID.
    DELETE ADJACENT DUPLICATES FROM LT_CELLS COMPARING ROW_ID.
  ENDIF.

  IF LT_CELLS[] IS INITIAL.
    RETURN.
  ENDIF.

  IF LINES( LT_CELLS ) > 1.
    MESSAGE S003 DISPLAY LIKE 'E' WITH '한개의 라인만 선택가능합니다.'.
    RETURN.
  ENDIF.

  READ TABLE LT_CELLS INTO DATA(LS_CELLS) INDEX 1.
  IF SY-SUBRC EQ 0.
    READ TABLE GT_MAIN_101 INTO GS_MAIN_101 INDEX LS_CELLS-ROW_ID.
    IF GS_MAIN_101-DATE < SY-DATUM.
      MESSAGE S003 DISPLAY LIKE 'E' WITH '현재일 이전 계획은 수정불가능합니다.'.
      RETURN.
    ENDIF.

    IF GS_MAIN_101-DAY_SEQ = 0.
      CLEAR : GS_MAIN_101-STATUS, GS_MAIN_101-ZREMARK, GS_MAIN_101-PSAMG_R, GS_MAIN_101-CAL_MARK.
      MODIFY GT_MAIN_101 FROM GS_MAIN_101 INDEX LS_CELLS-ROW_ID.
    ELSE.
      DELETE GT_MAIN_101 INDEX LS_CELLS-ROW_ID.
    ENDIF.

  ENDIF.

  PERFORM SET_WITH_MAIN USING GV_CHK_DETAIL.
  PERFORM REFRESH_0101.
  GV_CHK_EDIT_101 = ABAP_TRUE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CAL_SAVE_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PT_MAIN_101
*&      --> PS_MAIN
*&      --> LV_CHK_DATE
*&      --> PV_TOT_PSAMG
*&      --> LV_CAL_PSAMG
*&---------------------------------------------------------------------*
FORM CAL_SAVE_DATA  TABLES   PT_MAIN_101 STRUCTURE GS_MAIN_101
                    USING    PS_MAIN LIKE GS_MAIN
                             PV_CHK_DATE TYPE SY-DATUM
                             PV_TOT_PSAMG TYPE AFPO-PSAMG
                             PV_CAL_PSAMG TYPE AFPO-PSAMG.

  DATA : LV_CUR_DATE TYPE SY-DATUM.
  DATA : LV_WORKING_DAYS TYPE I.
  DATA : LV_CAL_MENGE TYPE AFPO-PSAMG.
  DATA : LV_FIXED_MENGE TYPE AFPO-PSAMG.
  DATA : LV_LAST_DATE TYPE SY-DATUM.
  DATA : LV_LAST_FIXED_MENGE TYPE AFPO-PSAMG.

  LOOP AT GT_DAY_ATTR INTO DATA(LS_DAY_ATTR) WHERE DATE > PV_CHK_DATE.
    IF LS_DAY_ATTR-DATE+0(6) = GS_SPMON-SPMON.
      IF NOT ( LS_DAY_ATTR-WEEKDAY = 6 OR LS_DAY_ATTR-WEEKDAY = 7 ).
        ADD 1 TO LV_WORKING_DAYS.

        IF LV_LAST_DATE < LS_DAY_ATTR-DATE.
          LV_LAST_DATE = LS_DAY_ATTR-DATE.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDLOOP.

  LV_CAL_MENGE = PV_TOT_PSAMG - PV_CAL_PSAMG.
  IF LV_CAL_MENGE < 0.
    LV_CAL_MENGE = 0.
  ENDIF.

  IF LV_WORKING_DAYS NE 0.
    PERFORM SET_CAL_MENGE USING LV_CAL_MENGE LV_WORKING_DAYS CHANGING LV_FIXED_MENGE LV_LAST_FIXED_MENGE.

  ELSE.
    IF LV_CAL_MENGE > 0.
      LV_LAST_FIXED_MENGE = LV_CAL_MENGE.
    ENDIF.
    IF GS_SPMON-TODATE > PV_CHK_DATE.
      LV_LAST_DATE = GS_SPMON-TODATE.
    ENDIF.
  ENDIF.

  LOOP AT PT_MAIN_101 ASSIGNING FIELD-SYMBOL(<LS_MAIN>).

    IF <LS_MAIN>-DATE <= PV_CHK_DATE.
      CONTINUE.
    ENDIF.

    CLEAR <LS_MAIN>-PSAMG_RT.

    IF <LS_MAIN>-DATE = LV_LAST_DATE.
      <LS_MAIN>-PSAMG_RT = LV_LAST_FIXED_MENGE.
    ELSE.
      CLEAR LS_DAY_ATTR.
      READ TABLE GT_DAY_ATTR INTO LS_DAY_ATTR WITH KEY DATE = <LS_MAIN>-DATE.

      IF NOT ( LS_DAY_ATTR-WEEKDAY = 6 OR LS_DAY_ATTR-WEEKDAY = 7 ).
        <LS_MAIN>-PSAMG_RT = LV_FIXED_MENGE.
      ENDIF.
    ENDIF.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SEND_TO_MES
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LT_ITEM
*&---------------------------------------------------------------------*
FORM SEND_TO_MES  TABLES  PT_ITEM STRUCTURE ZGTPPSIF0035.

  DATA : LV_DEST TYPE ZIFDEST-DEST.
  DATA : LV_RESULT  TYPE ZO_RESULT,
         LV_MESSAGE TYPE ZO_MESSAGE.
  DATA : LV_TIMESTAMP TYPE TIMESTAMPL.
  DATA : LT_ITEM TYPE TABLE OF ZGTPPSIF0035.

  DATA : LT_LOG_TAB TYPE TABLE OF ZGTPPT2250.

* 전송대상 시스쳄 소재 MES
  CONSTANTS : LC_TARGET TYPE ZGTPPT1020-ZSYSTEM_ID VALUE 'KSCM'.

  LT_ITEM = PT_ITEM[].
* 앞자리 0코드 제거
  .
  LOOP AT LT_ITEM ASSIGNING FIELD-SYMBOL(<LS_ITEM>).

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
      EXPORTING
        INPUT  = <LS_ITEM>-MATNR
      IMPORTING
        OUTPUT = <LS_ITEM>-MATNR.

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
      EXPORTING
        INPUT  = <LS_ITEM>-EBELP
      IMPORTING
        OUTPUT = <LS_ITEM>-EBELP.
  ENDLOOP.


*- Destination 가져오기
  CALL FUNCTION 'Z_IF_DESTINATION'
    EXPORTING
      GUBUN                 = 'P1'    "Destination 점검
    IMPORTING
      DEST_NAME             = LV_DEST
    EXCEPTIONS
      DESTINATION_NOT_FOUND = 1
      OTHERS                = 2.

  CALL FUNCTION 'ZGTPP_IF_DLV_INFO' DESTINATION LV_DEST
    EXPORTING
      I_SYSTEM_ID = LC_TARGET
    IMPORTING
      ZO_RESULT   = LV_RESULT
      ZO_MESSAGE  = LV_MESSAGE
    TABLES
      OT_ITEM     = LT_ITEM[].

*- History_Table에 저장
  IF LV_RESULT = '00' OR LV_RESULT = '0'.
    IF LV_MESSAGE IS INITIAL.
      LV_MESSAGE    = |전송성공|.
    ENDIF.
  ELSE.
    IF LV_MESSAGE IS INITIAL.
      LV_MESSAGE = |전송실패|.
    ENDIF.
  ENDIF.

  GET TIME STAMP FIELD LV_TIMESTAMP.
* 송신 로그 저장
  LOOP AT PT_ITEM INTO DATA(LS_ITEM).
    APPEND INITIAL LINE TO LT_LOG_TAB ASSIGNING FIELD-SYMBOL(<LS_LOG_TAB>).
    MOVE-CORRESPONDING LS_ITEM TO <LS_LOG_TAB>.
    <LS_LOG_TAB>-ZIFKEY = LV_TIMESTAMP.
    <LS_LOG_TAB>-ZSYSTEM_ID = LC_TARGET.
    <LS_LOG_TAB>-ZSTAT = LV_RESULT.
    <LS_LOG_TAB>-ZMESSAGE = LV_MESSAGE.
    <LS_LOG_TAB>-IFDAT = SY-DATUM.
    <LS_LOG_TAB>-IFTIM = SY-UZEIT.
    <LS_LOG_TAB>-IFNAM = SY-UNAME.

  ENDLOOP.

  MODIFY ZGTPPT2250 FROM TABLE LT_LOG_TAB.
  IF SY-SUBRC EQ 0.
    COMMIT WORK AND WAIT.
  ENDIF.

ENDFORM.
