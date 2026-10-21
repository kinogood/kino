*&---------------------------------------------------------------------*
*&  Include           MZGTPPR1020I01                                      *
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  exit_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE EXIT_0100 INPUT.
  CASE SY-UCOMM.
    WHEN 'EXIT'.
      LEAVE PROGRAM.
  ENDCASE.

ENDMODULE.                 " exit_0100  INPUT
*&---------------------------------------------------------------------*
*&      Module  user_command_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0100 INPUT.
  CASE SY-UCOMM.
    WHEN 'ENTER'.
      CLEAR: GT_DATA[], GT_SAVE[], GV_SAVEFLG.

      DATA : LV_SUBRC   LIKE SY-SUBRC.

* 권한 차후 추가
      CALL FUNCTION 'ZPP_AUTHORIZATION_CHECK'
        EXPORTING
          I_WERKS = GW_SEL-WERKS
          I_SPGCD = GW_SEL-SPGCD
          I_TYPE  = '4'
        IMPORTING
          E_SUBRC = LV_SUBRC.

      IF LV_SUBRC <> 0.
        MESSAGE S003 WITH '제품군[' GW_SEL-SPGCD
                          '] 작업권한을 확인하세요.'.
        RETURN.
      ENDIF.

      PERFORM CHECK_VALIDATION_0100.

      CHECK NOT GW_SEL-NAME1 IS INITIAL.

      PERFORM READ_DATA_FROM_TABLES.

      DESCRIBE TABLE GT_DATA LINES TC_200-LINES.

      IF GT_COLS[] IS INITIAL.
        GT_COLS[] = TC_200-COLS[].
      ENDIF.

      CALL SCREEN '0200'.
  ENDCASE.
ENDMODULE.                 " user_command_0100  INPUT
*&---------------------------------------------------------------------*
*&      Module  exit_0200  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE EXIT_0200 INPUT.
  DATA: LV_ANSWER             TYPE C.

  CASE SY-UCOMM.
    WHEN 'BACK'.
      IF GV_SAVEFLG = 'NONE'.
        PERFORM FUNCTION_FOR_CONFIRM  USING '저장 확인'
                                      '변경사항을 저장 하겠습니까?'
                                      SPACE
                            CHANGING LV_ANSWER.

        IF LV_ANSWER = 'J'.
          PERFORM SAVE_DATA.
        ELSE.
          MESSAGE S013.
        ENDIF.
      ENDIF.

      TC_200-COLS[] = GT_COLS[].

      LEAVE TO SCREEN 0.
  ENDCASE.

ENDMODULE.                 " exit_0200  INPUT
*&---------------------------------------------------------------------*
*&      Module  modify_field_200_del  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE MODIFY_FIELD_200_DEL INPUT.
  MODIFY GT_DATA INDEX TC_200-CURRENT_LINE.
ENDMODULE.                 " modify_field_200_del  INPUT
*&---------------------------------------------------------------------*
*&      Module  modify_field_200  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE MODIFY_FIELD_200 INPUT.
  GV_SAVEFLG  = 'NONE'.
  GT_DATA-CHK = 'X'.
  GT_DATA-FLAG = 'MOD'.

  CALL FUNCTION 'CONVERSION_EXIT_MATN1_INPUT'
    EXPORTING
      INPUT  = GT_DATA-MATNR
    IMPORTING
      OUTPUT = GT_DATA-MATNR.

  IF GT_DATA-PROCD IS INITIAL.
    MESSAGE E003 WITH '공정코드를 입력하세요.'.
    EXIT.
  ELSE.
* 공정코드 관련 정합성 차후 추가

    IF SY-SUBRC <> 0.
      MESSAGE E003 WITH '공정코드를 확인하세요.'.
      EXIT.
    ENDIF.

  ENDIF.

  IF GT_DATA-MATNR IS NOT INITIAL AND
     GT_DATA-MATNR NE '000000000000000000'.

    SELECT SINGLE *
      FROM MARC
     WHERE WERKS = GT_DATA-WERKS
       AND MATNR = GT_DATA-MATNR.

    IF SY-SUBRC <> 0.

      MESSAGE E003 WITH '자재코드를 확인하세요.'.

    ENDIF.

  ENDIF.

  IF GT_DATA-MATKL IS NOT INITIAL AND GW_SEL-WERKS NP '6*'.

    SELECT SINGLE *
      FROM MARA
     WHERE MATKL = GT_DATA-MATKL.

    IF SY-SUBRC <> 0.
      MESSAGE E003 WITH '자재그룹을 확인하세요.'.
    ENDIF.

  ENDIF.

  MODIFY GT_DATA INDEX TC_200-CURRENT_LINE
      TRANSPORTING WERKS SPGCD PROCD MATNR MATKL ZCUSTOMER A_SCRAP C_SCRAP1 C_SCRAP6 CHK FLAG.

ENDMODULE.                 " modify_field_200  INPUT
*&---------------------------------------------------------------------*
*&      Module  user_command_0200  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0200 INPUT.
  DATA: LV_STATUS         TYPE CHAR6.
  CLEAR: GV_INDEX.

  GV_OKCODE = OK_CODE.
  CLEAR OK_CODE.
  CASE GV_OKCODE.
    WHEN 'ADD_200'.
      PERFORM ADD_LINE_TO_SCREEN  USING 'X'.

      DESCRIBE TABLE GT_DATA LINES TC_200-LINES.
    WHEN 'DEL_200'.
      PERFORM DELETE_LINE_FROM_SCREEN.

      DESCRIBE TABLE GT_DATA LINES TC_200-LINES.

    WHEN 'SELA'.
      PERFORM MARK_LINE_ITEMS USING 'X'.

    WHEN 'DSEL'.
      PERFORM MARK_LINE_ITEMS USING ' '.

    WHEN 'ASCE'.
      READ TABLE TC_200-COLS INTO GS_COLS
                              WITH KEY SELECTED = 'X'.
      IF SY-SUBRC = 0.
        SORT GT_DATA BY (GS_COLS-SCREEN-NAME+8) ASCENDING.
        GS_COLS-SELECTED = ' '.
        MODIFY TC_200-COLS FROM GS_COLS INDEX SY-TABIX.
      ENDIF.

    WHEN 'DESC'.
      READ TABLE TC_200-COLS INTO GS_COLS
                             WITH KEY SELECTED = 'X'.
      IF SY-SUBRC = 0.
        SORT GT_DATA BY (GS_COLS-SCREEN-NAME+8) DESCENDING.
        GS_COLS-SELECTED = ' '.
        MODIFY TC_200-COLS FROM GS_COLS INDEX SY-TABIX.
      ENDIF.

    WHEN 'UPLOAD'.

      IF GT_SAVE[] IS NOT INITIAL.

        MESSAGE E003 WITH '삭제한 Data가 있으니 저장후 Upload 하세요'.
        EXIT.
      ENDIF.
*      PERFORM file_upload_process.
      PERFORM FILE_UPLOAD_PROCESS_NEW.

    WHEN 'DOWNLOAD'.

      READ TABLE GT_DATA WITH KEY CHK = 'X'.

      IF SY-SUBRC <> 0.

        MESSAGE E003 WITH 'Download할 데이타가 없습니다.'.
        EXIT.
      ENDIF.
*      PERFORM file_down_process.
      PERFORM FILE_DOWN_PROCESS_NEW.

    WHEN 'SAVE'.

      PERFORM SAVE_DATA.

  ENDCASE.

ENDMODULE.                 " user_command_0200  INPUT
*&---------------------------------------------------------------------*
*&      Module  modify_field_200_chk  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE MODIFY_FIELD_200_CHK INPUT.
  MODIFY GT_DATA INDEX TC_200-CURRENT_LINE
                 TRANSPORTING CHK.
ENDMODULE.                 " modify_field_200_chk  INPUT
*&---------------------------------------------------------------------*
*&      Module  get_cursor_field  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE GET_CURSOR_FIELD INPUT.
  CLEAR: GV_FIELD, GV_LILLI.
  GET CURSOR FIELD GV_FIELD LINE GV_LILLI.

ENDMODULE.                 " get_cursor_field  INPUT
*&---------------------------------------------------------------------*
*&      Module  modify_lines_proc  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE MODIFY_LINES_PROC INPUT.
  MODIFY GT_DATA INDEX TC_200-CURRENT_LINE
      TRANSPORTING WERKS SPGCD PROCD MATNR MATKL ZCUSTOMER A_SCRAP C_SCRAP1 C_SCRAP6.
ENDMODULE.                 " modify_lines_proc  INPUT
*&---------------------------------------------------------------------*
*&      Module  pov_for_spgcd  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE POV_FOR_SPGCD INPUT.

  DATA: BEGIN OF LS_SPGCD,
          WERKS TYPE WERKS_D,
          SPGCD TYPE ZPPT0107-SPGCD,
          DESCR TYPE ZPPT0107-DESCR,
        END   OF LS_SPGCD.
  DATA : LT_SPGCD LIKE TABLE OF LS_SPGCD.
  DATA : LV_WERKS TYPE WERKS_D.

  DATA : LV_OFFSET(6) TYPE N.
  DATA : LO_FLIEF TYPE REF TO DATA.

  DATA : LT_FIELD_TAB TYPE TABLE OF DFIES.
  DATA : LO_STRUCTDESCR TYPE REF TO CL_ABAP_STRUCTDESCR.

  DATA : LV_LINE       LIKE SY-STEPL,
         LT_DYNPFIELDS LIKE TABLE OF DYNPREAD.

  DATA : LT_RETURN_TAB TYPE TABLE OF DDSHRETVAL,
         LS_RETURN_TAB LIKE LINE OF LT_RETURN_TAB.

  PERFORM GET_DYNP_VALUE USING 'GW_SEL-WERKS'.

  LV_WERKS = GW_SEL-WERKS.

  SELECT DISTINCT WERKS SPGCD DESCR
    INTO CORRESPONDING FIELDS OF TABLE LT_SPGCD
    FROM ZPPT0107
   WHERE WERKS  = LV_WERKS.

  FREE LO_FLIEF.
  CREATE DATA LO_FLIEF LIKE LS_SPGCD.

  LO_STRUCTDESCR ?= CL_ABAP_STRUCTDESCR=>DESCRIBE_BY_DATA_REF( LO_FLIEF ).
  LT_FIELD_TAB = CL_SALV_DATA_DESCR=>READ_STRUCTDESCR( LO_STRUCTDESCR ).

  CLEAR LV_OFFSET.
  LOOP AT LT_FIELD_TAB ASSIGNING FIELD-SYMBOL(<LS_FIELD_TAB>).

    CASE <LS_FIELD_TAB>-FIELDNAME.
      WHEN 'WERKS'.
        <LS_FIELD_TAB>-REPTEXT  = '플랜트'.
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
      RETFIELD        = 'SPGCD'
      DYNPROFIELD     = 'GW_SEL-SPGCD'           "F4누른 필드->DEPT_CD
      VALUE_ORG       = 'S'                      "가져오는 엔트리가 다수일 경우인 것 같음. 다수일 경우 C로 하면 F4 안뜸
      WINDOW_TITLE    = 'SPG 조회'   "Search Help 타이틀
      DISPLAY         = 'F'
    TABLES
      FIELD_TAB       = LT_FIELD_TAB
      VALUE_TAB       = LT_SPGCD                  "부서코드, 부서명 가져온 인터널 테이블
      RETURN_TAB      = LT_RETURN_TAB            "F4에서 선택한 값이 들어옴
    EXCEPTIONS
      PARAMETER_ERROR = 1
      NO_VALUES_FOUND = 2
      OTHERS          = 3.

  READ TABLE LT_RETURN_TAB INTO LS_RETURN_TAB INDEX 1.
  IF SY-SUBRC EQ 0.

    REFRESH LT_DYNPFIELDS.
    PERFORM GET_STEPL USING LV_LINE.

*      시뮬레이션 번호
    APPEND INITIAL LINE TO LT_DYNPFIELDS ASSIGNING FIELD-SYMBOL(<LS_DYNPFIELDS>).
    <LS_DYNPFIELDS>-FIELDNAME = 'GW_SEL-SPGCD'.
    <LS_DYNPFIELDS>-STEPL = LV_LINE.
    <LS_DYNPFIELDS>-FIELDVALUE = LS_RETURN_TAB-FIELDVAL.

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

ENDMODULE.                 " pov_for_spgcd  INPUT
*&---------------------------------------------------------------------*
*& Form GET_DYNP_VALUE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&---------------------------------------------------------------------*
FORM GET_DYNP_VALUE  USING  PV_FIELDNAME TYPE DYNPREAD-FIELDNAME.

  ASSIGN (PV_FIELDNAME) TO FIELD-SYMBOL(<LV_VALUE>).

  CALL FUNCTION 'GET_DYNP_VALUE'
    EXPORTING
      I_FIELD = PV_FIELDNAME
      I_REPID = SY-CPROG
      I_DYNNR = SY-DYNNR
    CHANGING
      O_VALUE = <LV_VALUE>.

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
*&      Module  F4_GONG_CD  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE F4_GONG_CD INPUT.

  PERFORM F4_GONG_CD.

ENDMODULE.
