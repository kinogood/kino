*&---------------------------------------------------------------------*
*& Include          ZGTPPR1140F01
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

  GET PARAMETER ID 'WRK' FIELD P_WERKS.
  GET PARAMETER ID 'ZSPG' FIELD P_SPGCD.

  IF S_ANDAT[] IS INITIAL.
    S_ANDAT-LOW = SY-DATUM.
    S_ANDAT-HIGH = SY-DATUM.
    APPEND S_ANDAT.
  ENDIF.

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
    CASE ABAP_TRUE.
      WHEN P_CRTD.
        CASE ABAP_TRUE.
          WHEN P_TANDEM.
            CASE SCREEN-GROUP1.
              WHEN 'U05' OR 'U02' OR 'U06'.
                SCREEN-ACTIVE = 0.
                MODIFY SCREEN.
            ENDCASE.

          WHEN P_REPL.
            CASE SCREEN-GROUP1.
              WHEN 'U05' OR 'U03' OR 'U01'.
                SCREEN-ACTIVE = 0.
                MODIFY SCREEN.
              WHEN 'U06'.
                SCREEN-INPUT = 0.
                MODIFY SCREEN.
              WHEN 'U02'.
                SCREEN-REQUIRED = 2.
                MODIFY SCREEN.
            ENDCASE.
        ENDCASE.

      WHEN P_DISP.
        CASE SCREEN-GROUP1.
          WHEN 'U4' OR 'U02' OR 'U06' OR 'U01'.
            SCREEN-ACTIVE = 0.
            MODIFY SCREEN.
        ENDCASE.


    ENDCASE.
  ENDLOOP.

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

*& MRP관리자에 대한 권한체크
  AUTHORITY-CHECK OBJECT 'ZPP_WERKS'
  ID 'WERKS'  FIELD P_WERKS.

  IF SY-SUBRC <> 0.
    MESSAGE E006 WITH '플랜트[' P_WERKS
                      '] 작업권한을 확인하세요.'.
  ENDIF.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form INPUT_CHECK
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM INPUT_CHECK .

  IF P_CRTD = ABAP_TRUE AND P_REPL EQ ABAP_TRUE.
    IF P_MATNR IS INITIAL.
      MESSAGE S003 DISPLAY LIKE 'E' WITH '필수 필드 "품목코드"에 입력하십시오.'.
      LEAVE LIST-PROCESSING.
    ENDIF.
  ENDIF.

  IF P_CRTD = ABAP_TRUE AND P_TANDEM EQ ABAP_TRUE.
    IF P_SPGCD IS INITIAL.
      MESSAGE S003 DISPLAY LIKE 'E' WITH '필수 필드 "SPG"에 입력하십시오.'.
      LEAVE LIST-PROCESSING.
    ENDIF.
  ENDIF.

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

  CASE ABAP_TRUE.
    WHEN P_CRTD. " 생성
      CASE ABAP_TRUE.
        WHEN P_TANDEM. " 탄뎀 BOM
          PERFORM GET_TANDEM_DATA.
        WHEN P_REPL. " 대체 BOM
          PERFORM GET_REPLACE_BOM.
      ENDCASE.

    WHEN P_DISP. " 조회
      PERFORM GET_DISP_DATA.
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_TANDEM_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_TANDEM_DATA .

  DATA : LV_DISPO TYPE MARC-DISPO.
  DATA : LT_ARBPL TYPE RANGE OF CRHD-ARBPL.
  DATA : LV_NAME1 TYPE T001W-NAME1.

  LV_DISPO = P_SPGCD && '%'. "

* 플랜트명
  SELECT SINGLE NAME1 FROM T001W
    INTO LV_NAME1
   WHERE WERKS = P_WERKS.

* 탐뎀 구성을 위한 기준정보 추출
  SELECT * FROM ZGTPPT1010
    INTO TABLE GT_1010
   WHERE MODULE_KIND = 'PP'
     AND CODEGRP = '1060'
     AND FLD_02 = P_WERKS
     AND FLD_07 = 'Y'.

  IF GT_1010[] IS NOT INITIAL.
    LT_ARBPL = VALUE #( FOR LW_1010 IN GT_1010 WHERE ( FLD_04 IS NOT INITIAL )
                                ( SIGN = 'I' OPTION = 'EQ' LOW = LW_1010-FLD_04 ) ).

    IF LT_ARBPL[] IS INITIAL.
      RETURN.
    ELSE.
      SORT LT_ARBPL BY LOW.
      DELETE ADJACENT DUPLICATES FROM LT_ARBPL COMPARING LOW.
    ENDIF.

  ENDIF.

* 데이터 추출
  SELECT DISTINCT
      A~MATNR, A~WERKS, A~BESKZ, A~SOBSL,B~STLAN, B~STLNR, B~STLAL, B~ANDAT
    FROM MARA AS C
    INNER JOIN MARC AS A ON A~MATNR = C~MATNR
    INNER JOIN MAST AS B ON B~MATNR = A~MATNR
                             AND B~WERKS = A~WERKS
   WHERE A~WERKS = @P_WERKS
     AND A~MATNR IN @S_MATNR
     AND A~FEVOR IN @S_FEVOR
     AND A~DISPO LIKE @LV_DISPO
     AND B~ANDAT IN @S_ANDAT
     AND B~STLAN = '1'
     AND B~STLAL = '01'
     AND C~LVORM = ''
    INTO TABLE @DATA(LT_MOSU).

* 생산봄 존재건 대상으로 탐뎀설비 존재하는지 확인
  SELECT DISTINCT A~MATNR, A~WERKS, A~BESKZ, A~SOBSL,A~STLAN, A~STLNR, A~STLAL, A~ANDAT, D~ARBPL
    FROM  @LT_MOSU AS A
    INNER JOIN MAPL AS B ON B~MATNR = A~MATNR
                                 AND B~WERKS = A~WERKS
    INNER JOIN PLPO AS C ON C~PLNTY = B~PLNTY
                             AND C~PLNNR = B~PLNNR
                             AND C~ZAEHL = B~ZAEHL
    INNER JOIN CRHD AS D ON D~OBJID = C~ARBID
   WHERE D~OBJTY = 'A'
    AND D~ARBPL IN @LT_ARBPL
   INTO TABLE @DATA(LT_DATA).

* 해당 자재건중 탐뎀 Bom 존재건 확인
  SELECT DISTINCT
      A~MATNR, A~WERKS, B~STLAN, B~STLAL
    FROM @LT_DATA AS A
    INNER JOIN MAST AS B ON B~MATNR = A~MATNR
                             AND B~WERKS = A~WERKS
   WHERE B~STLAN = '1'
     AND B~STLAL = '90'
    INTO TABLE @DATA(LT_DATA2).

* 출력 테이블 구성
  REFRESH GT_MAIN_0100.

  LOOP AT LT_DATA INTO DATA(LS_DATA).
    CLEAR GS_MAIN_0100.
    GS_MAIN_0100-STATUS = ICON_LED_INACTIVE.
    READ TABLE LT_DATA2 INTO DATA(LS_DATA2) WITH KEY MATNR = LS_DATA-MATNR.
    IF SY-SUBRC EQ 0.
      GS_MAIN_0100-STATUS = ICON_LED_GREEN.
      GS_MAIN_0100-MESSAGE = '이미 탄뎀BOM이 존재합니다.'.
    ENDIF.

    GS_MAIN_0100-WERKS = P_WERKS.
    GS_MAIN_0100-NAME1 = LV_NAME1.
    GS_MAIN_0100-MATNR = LS_DATA-MATNR.
    GS_MAIN_0100-MAKTX = ZGTPP_CL_COMMON=>GET_MAKTX( IV_MATNR = LS_DATA-MATNR ).
    GS_MAIN_0100-BESKZ = LS_DATA-BESKZ.
    GS_MAIN_0100-SOBSL = LS_DATA-SOBSL.
    GS_MAIN_0100-STLAN =  LS_DATA-STLAN.
    GS_MAIN_0100-STLAL = '90'.


    READ TABLE GT_1010 INTO DATA(LS_1010) WITH KEY FLD_04 = LS_DATA-ARBPL.
    IF SY-SUBRC EQ 0.
      GS_MAIN_0100-FLD_06 = LS_1010-FLD_06.
      GS_MAIN_0100-FLD_04 = LS_1010-FLD_04.
      GS_MAIN_0100-FLD_05 = LS_1010-FLD_05.

      APPEND GS_MAIN_0100 TO GT_MAIN_0100.
    ENDIF.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_REPLACE_BOM
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_REPLACE_BOM .

  DATA : LV_NAME1 TYPE T001W-NAME1.

* 데이터 추출
  SELECT DISTINCT
      A~MATNR, A~WERKS, A~STLAN, A~STLAL, B~MEINS
    FROM MAST AS A
    INNER JOIN MARA AS B ON B~MATNR = A~MATNR
   WHERE A~WERKS = @P_WERKS
     AND A~MATNR = @P_MATNR
     AND A~STLAN = '1'
     AND A~STLAL IN ('01', '02' )
     AND B~LVORM = ''
    INTO TABLE @DATA(LT_MOSU).

  READ TABLE LT_MOSU INTO DATA(LS_MOSU) WITH KEY STLAL = '01'.
  IF SY-SUBRC EQ 0.
    READ TABLE LT_MOSU TRANSPORTING NO FIELDS WITH KEY STLAL = '02'.
    IF SY-SUBRC EQ 0.
      MESSAGE S003 DISPLAY LIKE 'E' WITH '이미 대체 BOM 02번이 존재합니다'.
      LEAVE LIST-PROCESSING.
    ENDIF.

  ELSE.
    MESSAGE S003 DISPLAY LIKE 'E' WITH '생산 BOM이 없는 품목코드입니다.'.
    LEAVE LIST-PROCESSING.
  ENDIF.

* 플랜트명
  SELECT SINGLE NAME1 FROM T001W
    INTO LV_NAME1
   WHERE WERKS = P_WERKS.

  REFRESH GT_MAIN_0200.
  CLEAR GS_MAIN_0200.

  GS_MAIN_0200-WERKS = P_WERKS.
  GS_MAIN_0200-NAME1 = LV_NAME1.
  GS_MAIN_0200-MATNR = LS_MOSU-MATNR.
  GS_MAIN_0200-MAKTX = ZGTPP_CL_COMMON=>GET_MAKTX( IV_MATNR = LS_MOSU-MATNR ).
  GS_MAIN_0200-STLAN = '1'.
  GS_MAIN_0200-STLAL = '02'.
  GS_MAIN_0200-MENGE_M = 1000.
  GS_MAIN_0200-MEINS_M = LS_MOSU-MEINS.

  DO 10 TIMES.
    APPEND GS_MAIN_0200 TO GT_MAIN_0200.
  ENDDO.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_DISP_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_DISP_DATA .

  DATA : LV_DISPO TYPE MARC-DISPO.
  DATA : LT_ARBPL TYPE RANGE OF CRHD-ARBPL.
  DATA : LT_CVMVAL TYPE TABLE OF ZGTCVMSTVAL.
  DATA : LT_MATNR TYPE RANGE OF MATNR.
  DATA : LV_NAME1 TYPE T001W-NAME1.

  LV_DISPO = P_SPGCD && '%'. "

* 플랜트명
  SELECT SINGLE NAME1 FROM T001W
    INTO LV_NAME1
   WHERE WERKS = P_WERKS.

* 탐뎀 구성을 위한 기준정보 추출
  SELECT * FROM ZGTPPT1010
    INTO TABLE GT_1010
   WHERE MODULE_KIND = 'PP'
     AND CODEGRP = '1060'
     AND FLD_02 = P_WERKS
     AND FLD_07 = 'Y'.

  IF GT_1010[] IS NOT INITIAL.
    LT_ARBPL = VALUE #( FOR LW_1010 IN GT_1010 WHERE ( FLD_04 IS NOT INITIAL )
                                ( SIGN = 'I' OPTION = 'EQ' LOW = LW_1010-FLD_04 ) ).

    IF LT_ARBPL[] IS INITIAL.
      RETURN.
    ELSE.
      SORT LT_ARBPL BY LOW.
      DELETE ADJACENT DUPLICATES FROM LT_ARBPL COMPARING LOW.
    ENDIF.

  ENDIF.

* 데이터 추출
  SELECT DISTINCT
      A~MATNR, A~WERKS, A~BESKZ, A~SOBSL,B~STLAN, B~STLNR, B~STLAL, B~ANDAT
    FROM MARA AS C
    INNER JOIN MARC AS A ON A~MATNR = C~MATNR
    INNER JOIN MAST AS B ON B~MATNR = A~MATNR
                             AND B~WERKS = A~WERKS
   WHERE A~WERKS = @P_WERKS
     AND A~MATNR IN @S_MATNR
     AND A~DISPO LIKE @LV_DISPO
     AND B~STLAN = '1'
     AND B~STLAL = '01'
    AND C~LVORM = ''
    INTO TABLE @DATA(LT_MOSU).

* 생산봄 존재건 대상으로 탐뎀설비 존재하는지 확인
  SELECT DISTINCT A~MATNR, A~WERKS, A~BESKZ, A~SOBSL,A~STLAN, A~STLNR, A~STLAL, A~ANDAT, D~ARBPL
    FROM  @LT_MOSU AS A
    INNER JOIN MAPL AS B ON B~MATNR = A~MATNR
                                 AND B~WERKS = A~WERKS
    INNER JOIN PLPO AS C ON C~PLNTY = B~PLNTY
                             AND C~PLNNR = B~PLNNR
                             AND C~ZAEHL = B~ZAEHL
    INNER JOIN CRHD AS D ON D~OBJID = C~ARBID
   WHERE D~OBJTY = 'A'
    AND D~ARBPL IN @LT_ARBPL
   INTO TABLE @DATA(LT_DATA).

* 해당 자재건중 탐뎀 Bom 존재건 확인
  SELECT DISTINCT
      A~MATNR, A~WERKS, B~STLAN, B~STLAL
    FROM @LT_MOSU AS A
    INNER JOIN MAST AS B ON B~MATNR = A~MATNR
                             AND B~WERKS = A~WERKS
   WHERE B~STLAN = '1'
     AND B~STLAL IN ( '02', '90' )
    INTO TABLE @DATA(LT_DATA2).

  REFRESH LT_MATNR.
  LT_MATNR = VALUE #( FOR LW_DATA2 IN LT_DATA2 WHERE ( MATNR IS NOT INITIAL )
                              ( SIGN = 'I' OPTION = 'EQ' LOW = LW_DATA2-MATNR ) ).

  IF LT_MATNR[] IS NOT INITIAL.
    SORT LT_MATNR BY LOW.
    DELETE ADJACENT DUPLICATES FROM LT_MATNR COMPARING LOW.

    SELECT * FROM ZGTCVMSTVAL
      APPENDING TABLE LT_CVMVAL
     WHERE WERKS = P_WERKS
        AND MATNR IN LT_MATNR.
  ENDIF.

  REFRESH GT_MAIN_0300.

  LOOP AT LT_MATNR INTO DATA(LS_MATNR).
    LOOP AT LT_DATA2 INTO DATA(LS_DATA2) WHERE MATNR = LS_MATNR-LOW.
      CASE LS_DATA2-STLAL.
        WHEN '02'.
          READ TABLE LT_CVMVAL INTO DATA(LS_CVMVAL) WITH KEY MATNR = LS_MATNR-LOW.
          IF SY-SUBRC EQ 0.
            CLEAR GS_MAIN_0300.
            GS_MAIN_0300-WERKS = P_WERKS.
            GS_MAIN_0300-NAME1 = LV_NAME1.
            GS_MAIN_0300-MATNR = LS_CVMVAL-MATNR.
            GS_MAIN_0300-MAKTX = ZGTPP_CL_COMMON=>GET_MAKTX( IV_MATNR = LS_CVMVAL-MATNR ).
            GS_MAIN_0300-GONG_NM = LS_CVMVAL-PDCAPROCNAME.
            GS_MAIN_0300-SOBSL = LS_CVMVAL-SOBSL.
            GS_MAIN_0300-BESKZ = LS_CVMVAL-BESKZ.
            GS_MAIN_0300-FLD_06 = '대체'.
            GS_MAIN_0300-STLAN = '1'.
            GS_MAIN_0300-STLAL = '02'.
            APPEND GS_MAIN_0300 TO GT_MAIN_0300.
          ENDIF.

        WHEN '90'.
          LOOP AT LT_DATA INTO DATA(LS_DATA) WHERE MATNR = LS_MATNR-LOW.
            CLEAR GS_MAIN_0300.
            GS_MAIN_0300-WERKS = P_WERKS.
            GS_MAIN_0300-NAME1 = LV_NAME1.
            GS_MAIN_0300-MATNR = LS_DATA-MATNR.
            GS_MAIN_0300-MAKTX = ZGTPP_CL_COMMON=>GET_MAKTX( IV_MATNR = LS_DATA-MATNR ).
            GS_MAIN_0300-BESKZ = LS_DATA-BESKZ.
            GS_MAIN_0300-SOBSL = LS_DATA-SOBSL.
            GS_MAIN_0300-STLAN =  LS_DATA-STLAN.
            GS_MAIN_0300-STLAL = '90'.
            GS_MAIN_0300-FLD_06 = '탄뎀'.

            READ TABLE GT_1010 INTO DATA(LS_1010) WITH KEY FLD_04 = LS_DATA-ARBPL.
            IF SY-SUBRC EQ 0.
              GS_MAIN_0300-GONG_NM = LS_1010-FLD_06.
              GS_MAIN_0300-ARBPL = LS_1010-FLD_04.
              GS_MAIN_0300-KTEXT = LS_1010-FLD_05.

              APPEND GS_MAIN_0300 TO GT_MAIN_0300.
            ENDIF.
          ENDLOOP.

      ENDCASE.
    ENDLOOP.

  ENDLOOP.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROC_DISP
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PROC_DISP .

  CASE ABAP_TRUE.
    WHEN P_CRTD. " 생성
      CASE ABAP_TRUE.
        WHEN P_TANDEM. " 탄뎀 BOM
          IF P_BATCH IS INITIAL.
            CALL SCREEN '0100'.
          ELSE.
            PERFORM MAKE_TANDEM_PROCESS.
          ENDIF.
        WHEN P_REPL. " 대체 BOM
          CALL SCREEN '0200'.
      ENDCASE.

    WHEN P_DISP. " 조회
      CALL SCREEN '0300'.
  ENDCASE.

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

  CREATE OBJECT GO_GRID_0100
    EXPORTING
      I_PARENT      = GO_DOCKING_0100
      I_APPL_EVENTS = ABAP_TRUE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form EVENT_HANDLER_REGISTER
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GO_GRID_0100
*&---------------------------------------------------------------------*
FORM EVENT_HANDLER_REGISTER  USING    PO_GRID TYPE REF TO CL_GUI_ALV_GRID.

  IF GO_EVENT_HANDLER IS NOT BOUND.
    CREATE OBJECT GO_EVENT_HANDLER.
  ENDIF.

  CASE PO_GRID.
    WHEN GO_GRID_0100.
*// Event Handler ##
      SET HANDLER GO_EVENT_HANDLER->HANDLE_TOOLBAR               FOR PO_GRID.
      SET HANDLER GO_EVENT_HANDLER->HANDLE_USER_COMMAND          FOR PO_GRID.
    WHEN GO_GRID_0200.
      SET HANDLER GO_EVENT_HANDLER->HANDLE_TOOLBAR               FOR PO_GRID.
      SET HANDLER GO_EVENT_HANDLER->HANDLE_USER_COMMAND          FOR PO_GRID.
      SET HANDLER GO_EVENT_HANDLER->HANDLE_DATA_CHANGED          FOR PO_GRID.
    WHEN GO_GRID_0300.
      SET HANDLER GO_EVENT_HANDLER->HANDLE_HOTSPOT_CLICK          FOR PO_GRID.
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_LAYOUT_GRID_0100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_LAYOUT_GRID_0100 .

  CLEAR GS_LAYOUT_0100.
  GS_LAYOUT_0100-CWIDTH_OPT = ABAP_TRUE.
  GS_LAYOUT_0100-NO_ROWINS = ABAP_TRUE.
  GS_LAYOUT_0100-SEL_MODE   = 'D'.
  GS_LAYOUT_0100-ZEBRA   = ABAP_TRUE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_FIELDCAT_GRID_0100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_FIELDCAT_GRID_0100 .

  DATA : LT_FCAT_SLIS TYPE SLIS_T_FIELDCAT_ALV.
  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      I_PROGRAM_NAME         = SY-REPID
      I_INCLNAME             = 'ZGTPPR1140TOP'
      I_INTERNAL_TABNAME     = 'GS_MAIN_0100'
      I_BYPASSING_BUFFER     = ABAP_TRUE
    CHANGING
      CT_FIELDCAT            = LT_FCAT_SLIS
    EXCEPTIONS
      INCONSISTENT_INTERFACE = 1
      PROGRAM_ERROR          = 2
      OTHERS                 = 3.

  REFRESH GT_FIELDCAT_0100.

*-- lt_fieldcat의 구조체를 pt_fcat의 구조체로 변경
  CALL FUNCTION 'LVC_TRANSFER_FROM_SLIS'
    EXPORTING
      IT_FIELDCAT_ALV = LT_FCAT_SLIS
    IMPORTING
      ET_FIELDCAT_LVC = GT_FIELDCAT_0100[]
    TABLES
      IT_DATA         = GT_MAIN_0100
    EXCEPTIONS
      OTHERS          = 1.


  LOOP AT GT_FIELDCAT_0100 ASSIGNING FIELD-SYMBOL(<LS_FCAT>).
    CLEAR <LS_FCAT>-KEY.
    CASE   <LS_FCAT>-FIELDNAME.
      WHEN 'STATUS'.
        <LS_FCAT>-JUST = 'C'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '처리상태'(F01).
      WHEN 'MESSAGE'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '처리 메시지'(F02).
        <LS_FCAT>-JUST = 'L'.
      WHEN 'WERKS'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '플랜트'(F03).
        <LS_FCAT>-JUST = 'C'.
      WHEN 'NAME1'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '플랜트내역'(F04).
        <LS_FCAT>-JUST = 'L'.
      WHEN 'MATNR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '품목코드'(F05).
        <LS_FCAT>-JUST = 'C'.
      WHEN 'MAKTX'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '품목내역'(F06).
        <LS_FCAT>-JUST = 'L'.
      WHEN 'FLD_06'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '공정'(F07).
        <LS_FCAT>-JUST = 'C'.
      WHEN 'FLD_04'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '작업장코드'(F08).
        <LS_FCAT>-JUST = 'C'.
      WHEN 'FLD_05'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '작업장내역'(F09).
        <LS_FCAT>-JUST = 'L'.
      WHEN 'BESKZ'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '조달유형'(F10).
        <LS_FCAT>-JUST = 'C'.
      WHEN 'SOBSL'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '특별조달'(F11).
        <LS_FCAT>-JUST = 'C'.
      WHEN 'STLAN'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = 'BOM 용도'(F12).
        <LS_FCAT>-JUST = 'C'.
      WHEN 'STLAL'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '대체 BOM'(F13).
        <LS_FCAT>-JUST = 'C'.
    ENDCASE.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form EXCLUDE_OF_TOOLBAR_GRID_0100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM EXCLUDE_OF_TOOLBAR_GRID_0100 .

  PERFORM ADD_EXCLUDE_TOOLBAR_BUTTON TABLES GT_EXCLUDE_0100
        USING : CL_GUI_ALV_GRID=>MC_FC_LOC_UNDO,
                CL_GUI_ALV_GRID=>MC_FC_AUF,
                CL_GUI_ALV_GRID=>MC_FC_CHECK,
                CL_GUI_ALV_GRID=>MC_FC_LOC_PASTE,
                CL_GUI_ALV_GRID=>MC_FC_LOC_COPY,
                CL_GUI_ALV_GRID=>MC_FC_AVERAGE,
                CL_GUI_ALV_GRID=>MC_FC_GRAPH,
                CL_GUI_ALV_GRID=>MC_FC_INFO,
                CL_GUI_ALV_GRID=>MC_FC_LOC_COPY_ROW,
                CL_GUI_ALV_GRID=>MC_FC_LOC_CUT,
                CL_GUI_ALV_GRID=>MC_FC_LOC_DELETE_ROW,
                CL_GUI_ALV_GRID=>MC_FC_LOC_INSERT_ROW,
                CL_GUI_ALV_GRID=>MC_FC_LOC_APPEND_ROW,
                CL_GUI_ALV_GRID=>MC_FC_LOC_PASTE,
                CL_GUI_ALV_GRID=>MC_FC_LOC_PASTE_NEW_ROW,
                CL_GUI_ALV_GRID=>MC_FC_REFRESH.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  add_exclude_toolbar_button
*&---------------------------------------------------------------------*
*       text
*-----------------------------------------------------------------------
**
FORM ADD_EXCLUDE_TOOLBAR_BUTTON  TABLES   P_TABLE
                                 USING    P_VALUE.
  DATA: L_EXCLUDE TYPE UI_FUNC.
  L_EXCLUDE = P_VALUE.
  APPEND L_EXCLUDE TO P_TABLE.
ENDFORM.                    " add_exclude_toolbar_button
*&---------------------------------------------------------------------*
*& Form CALL_GRID_0100_DISPLAY
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CALL_GRID_0100_DISPLAY .

  CALL METHOD GO_GRID_0100->SET_TABLE_FOR_FIRST_DISPLAY
    EXPORTING
      IS_LAYOUT            = GS_LAYOUT_0100
      IT_TOOLBAR_EXCLUDING = GT_EXCLUDE_0100
      I_BYPASSING_BUFFER   = ABAP_TRUE
    CHANGING
      IT_OUTTAB            = GT_MAIN_0100
      IT_FIELDCATALOG      = GT_FIELDCAT_0100.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_OBJECT_GRID_0200
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_OBJECT_GRID_0200 .

  CREATE OBJECT GO_DOCKING_0200
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

  CREATE OBJECT GO_GRID_0200
    EXPORTING
      I_PARENT      = GO_DOCKING_0200
      I_APPL_EVENTS = ABAP_TRUE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_LAYOUT_GRID_0200
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_LAYOUT_GRID_0200 .

  CLEAR GS_LAYOUT_0200.
  GS_LAYOUT_0200-CWIDTH_OPT = ABAP_TRUE.
  GS_LAYOUT_0200-NO_ROWINS = ABAP_TRUE.
  GS_LAYOUT_0200-SEL_MODE   = 'D'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_FIELDCAT_GRID_0200
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_FIELDCAT_GRID_0200 .

  DATA : LT_FCAT_SLIS TYPE SLIS_T_FIELDCAT_ALV.
  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      I_PROGRAM_NAME         = SY-REPID
      I_INCLNAME             = 'ZGTPPR1140TOP'
      I_INTERNAL_TABNAME     = 'GS_MAIN_0200'
      I_BYPASSING_BUFFER     = ABAP_TRUE
    CHANGING
      CT_FIELDCAT            = LT_FCAT_SLIS
    EXCEPTIONS
      INCONSISTENT_INTERFACE = 1
      PROGRAM_ERROR          = 2
      OTHERS                 = 3.

  REFRESH GT_FIELDCAT_0200.

*-- lt_fieldcat의 구조체를 pt_fcat의 구조체로 변경
  CALL FUNCTION 'LVC_TRANSFER_FROM_SLIS'
    EXPORTING
      IT_FIELDCAT_ALV = LT_FCAT_SLIS
    IMPORTING
      ET_FIELDCAT_LVC = GT_FIELDCAT_0200[]
    TABLES
      IT_DATA         = GT_MAIN_0200
    EXCEPTIONS
      OTHERS          = 1.


  LOOP AT GT_FIELDCAT_0200 ASSIGNING FIELD-SYMBOL(<LS_FCAT>).
    CLEAR <LS_FCAT>-KEY.
    CASE   <LS_FCAT>-FIELDNAME.
      WHEN 'STATUS'.
        <LS_FCAT>-JUST = 'C'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '처리상태'(F01).
      WHEN 'MESSAGE'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '처리 메시지'(F02).
        <LS_FCAT>-JUST = 'L'.
      WHEN 'WERKS'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '플랜트'(F03).
        <LS_FCAT>-JUST = 'C'.
        <LS_FCAT>-EMPHASIZE = 'C110'.
      WHEN 'NAME1'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '플랜트내역'(F04).
        <LS_FCAT>-JUST = 'L'.
        <LS_FCAT>-EMPHASIZE = 'C110'.
      WHEN 'MATNR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '품목코드'(F05).
        <LS_FCAT>-JUST = 'C'.
        <LS_FCAT>-EMPHASIZE = 'C110'.
      WHEN 'MAKTX'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '품목내역'(F06).
        <LS_FCAT>-JUST = 'L'.
        <LS_FCAT>-EMPHASIZE = 'C110'.
      WHEN 'STLAN'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = 'BOM 용도'(F12).
        <LS_FCAT>-JUST = 'C'.
        <LS_FCAT>-EMPHASIZE = 'C710'.
      WHEN 'STLAL'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '대체 BOM'(F13).
        <LS_FCAT>-JUST = 'C'.
        <LS_FCAT>-EMPHASIZE = 'C710'.
      WHEN 'IDNRK'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '자재코드'(F14).
        <LS_FCAT>-JUST = 'C'.
        <LS_FCAT>-EDIT = ABAP_TRUE.
      WHEN 'MAKTX2'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '자재내역'(F15).
        <LS_FCAT>-JUST = 'L'.
      WHEN 'MENGE'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '수량'(F16).
        <LS_FCAT>-JUST = 'R'.
        <LS_FCAT>-QUANTITY = 'EA'.
        <LS_FCAT>-EDIT = ABAP_TRUE.
      WHEN 'MEINS'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '단위'(F17).
        <LS_FCAT>-JUST = 'C'.
        <LS_FCAT>-EDIT = ABAP_TRUE.
      WHEN 'MENGE_M'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '기준수량'(F18).
        <LS_FCAT>-JUST = 'R'.
        <LS_FCAT>-QUANTITY = 'EA'.
      WHEN 'MEINS_M'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '수량단위'(F19).
        <LS_FCAT>-JUST = 'C'.
    ENDCASE.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form EXCLUDE_OF_TOOLBAR_GRID_0200
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM EXCLUDE_OF_TOOLBAR_GRID_0200 .

  PERFORM ADD_EXCLUDE_TOOLBAR_BUTTON TABLES GT_EXCLUDE_0200
        USING : CL_GUI_ALV_GRID=>MC_FC_EXCL_ALL.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CALL_GRID_0200_DISPLAY
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CALL_GRID_0200_DISPLAY .

  CALL METHOD GO_GRID_0200->SET_TABLE_FOR_FIRST_DISPLAY
    EXPORTING
      IS_LAYOUT            = GS_LAYOUT_0200
      IT_TOOLBAR_EXCLUDING = GT_EXCLUDE_0200
      I_BYPASSING_BUFFER   = ABAP_TRUE
    CHANGING
      IT_OUTTAB            = GT_MAIN_0200
      IT_FIELDCATALOG      = GT_FIELDCAT_0200.

* 인풋이벤트 추가
  CALL METHOD GO_GRID_0200->REGISTER_EDIT_EVENT
    EXPORTING
      I_EVENT_ID = CL_GUI_ALV_GRID=>MC_EVT_ENTER.

  CALL METHOD GO_GRID_0200->REGISTER_EDIT_EVENT
    EXPORTING
      I_EVENT_ID = CL_GUI_ALV_GRID=>MC_EVT_MODIFIED.

ENDFORM.
*&---------------------------------------------------------------------*
*& Module CREATE_ALV_0300 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE CREATE_ALV_0300 OUTPUT.
  IF GO_GRID_0300 IS NOT BOUND.
    PERFORM SET_OBJECT_GRID_0300.
    PERFORM EVENT_HANDLER_REGISTER USING GO_GRID_0300.
    PERFORM SET_LAYOUT_GRID_0300.
    PERFORM SET_FIELDCAT_GRID_0300.
    PERFORM EXCLUDE_OF_TOOLBAR_GRID_0300.
    PERFORM CALL_GRID_0300_DISPLAY.
  ENDIF.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Form SET_OBJECT_GRID_0300
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_OBJECT_GRID_0300 .

  CREATE OBJECT GO_DOCKING_0300
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

  CREATE OBJECT GO_GRID_0300
    EXPORTING
      I_PARENT      = GO_DOCKING_0300
      I_APPL_EVENTS = ABAP_TRUE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_LAYOUT_GRID_0300
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_LAYOUT_GRID_0300 .

  CLEAR GS_LAYOUT_0300.
  GS_LAYOUT_0300-CWIDTH_OPT = ABAP_TRUE.
  GS_LAYOUT_0300-NO_ROWINS = ABAP_TRUE.
  GS_LAYOUT_0300-SEL_MODE   = 'D'.
  GS_LAYOUT_0300-ZEBRA   = ABAP_TRUE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_FIELDCAT_GRID_0300
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_FIELDCAT_GRID_0300 .

  DATA : LT_FCAT_SLIS TYPE SLIS_T_FIELDCAT_ALV.
  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      I_PROGRAM_NAME         = SY-REPID
      I_INCLNAME             = 'ZGTPPR1140TOP'
      I_INTERNAL_TABNAME     = 'GS_MAIN_0300'
      I_BYPASSING_BUFFER     = ABAP_TRUE
    CHANGING
      CT_FIELDCAT            = LT_FCAT_SLIS
    EXCEPTIONS
      INCONSISTENT_INTERFACE = 1
      PROGRAM_ERROR          = 2
      OTHERS                 = 3.

  REFRESH GT_FIELDCAT_0300.

*-- lt_fieldcat의 구조체를 pt_fcat의 구조체로 변경
  CALL FUNCTION 'LVC_TRANSFER_FROM_SLIS'
    EXPORTING
      IT_FIELDCAT_ALV = LT_FCAT_SLIS
    IMPORTING
      ET_FIELDCAT_LVC = GT_FIELDCAT_0300[]
    TABLES
      IT_DATA         = GT_MAIN_0300
    EXCEPTIONS
      OTHERS          = 1.


  LOOP AT GT_FIELDCAT_0300 ASSIGNING FIELD-SYMBOL(<LS_FCAT>).
    CLEAR <LS_FCAT>-KEY.
    CASE   <LS_FCAT>-FIELDNAME.
      WHEN 'WERKS'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '플랜트'(F03).
        <LS_FCAT>-JUST = 'C'.
      WHEN 'NAME1'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '플랜트내역'(F04).
        <LS_FCAT>-JUST = 'L'.
      WHEN 'MATNR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '품목코드'(F05).
        <LS_FCAT>-JUST = 'C'.
        <LS_FCAT>-KEY = ABAP_TRUE.
        <LS_FCAT>-HOTSPOT = ABAP_TRUE.
      WHEN 'MAKTX'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '품목내역'(F06).
        <LS_FCAT>-JUST = 'L'.
        <LS_FCAT>-KEY = ABAP_TRUE.
        <LS_FCAT>-HOTSPOT = ABAP_TRUE.
      WHEN 'GONG_NM'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '공정'(F07).
        <LS_FCAT>-JUST = 'C'.
        <LS_FCAT>-KEY = ABAP_TRUE.
      WHEN 'ARBPL'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '작업장코드'(F08).
        <LS_FCAT>-JUST = 'C'.
        <LS_FCAT>-KEY = ABAP_TRUE.
      WHEN 'KTEXT'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '작업장내역'(F09).
        <LS_FCAT>-JUST = 'L'.
        <LS_FCAT>-KEY = ABAP_TRUE.
      WHEN 'BESKZ'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '조달유형'(F10).
        <LS_FCAT>-JUST = 'C'.
      WHEN 'SOBSL'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '특별조달'(F11).
        <LS_FCAT>-JUST = 'C'.
      WHEN 'FLD_06'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '유형'(002).
        <LS_FCAT>-JUST = 'C'.
      WHEN 'STLAN'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = 'BOM 용도'(F12).
        <LS_FCAT>-JUST = 'C'.
        <LS_FCAT>-EMPHASIZE = 'C710'.
      WHEN 'STLAL'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '대체 BOM'(F13).
        <LS_FCAT>-JUST = 'C'.
        <LS_FCAT>-EMPHASIZE = 'C710'.
    ENDCASE.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form EXCLUDE_OF_TOOLBAR_GRID_0300
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM EXCLUDE_OF_TOOLBAR_GRID_0300 .

  PERFORM ADD_EXCLUDE_TOOLBAR_BUTTON TABLES GT_EXCLUDE_0300
        USING : CL_GUI_ALV_GRID=>MC_FC_LOC_UNDO,
                CL_GUI_ALV_GRID=>MC_FC_AUF,
                CL_GUI_ALV_GRID=>MC_FC_CHECK,
                CL_GUI_ALV_GRID=>MC_FC_LOC_PASTE,
                CL_GUI_ALV_GRID=>MC_FC_LOC_COPY,
                CL_GUI_ALV_GRID=>MC_FC_AVERAGE,
                CL_GUI_ALV_GRID=>MC_FC_GRAPH,
                CL_GUI_ALV_GRID=>MC_FC_INFO,
                CL_GUI_ALV_GRID=>MC_FC_LOC_COPY_ROW,
                CL_GUI_ALV_GRID=>MC_FC_LOC_CUT,
                CL_GUI_ALV_GRID=>MC_FC_LOC_DELETE_ROW,
                CL_GUI_ALV_GRID=>MC_FC_LOC_INSERT_ROW,
                CL_GUI_ALV_GRID=>MC_FC_LOC_APPEND_ROW,
                CL_GUI_ALV_GRID=>MC_FC_LOC_PASTE,
                CL_GUI_ALV_GRID=>MC_FC_LOC_PASTE_NEW_ROW,
                CL_GUI_ALV_GRID=>MC_FC_REFRESH.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CALL_GRID_0300_DISPLAY
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CALL_GRID_0300_DISPLAY .

  CALL METHOD GO_GRID_0300->SET_TABLE_FOR_FIRST_DISPLAY
    EXPORTING
      IS_LAYOUT            = GS_LAYOUT_0300
      IT_TOOLBAR_EXCLUDING = GT_EXCLUDE_0300
      I_BYPASSING_BUFFER   = ABAP_TRUE
    CHANGING
      IT_OUTTAB            = GT_MAIN_0300
      IT_FIELDCATALOG      = GT_FIELDCAT_0300.

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
                           USING : 'TANDEM' ICON_BOM '탄뎀 BOM 생성' '탄뎀 BOM 생성' 0.

    WHEN GO_GRID_0200.
      PERFORM SET_TOOLBAR TABLES PO_OBJECT->MT_TOOLBAR
                           USING : 'ADD' ICON_INSERT_ROW '라인추가' '라인추가' 0,
                                    'DEL' ICON_DELETE_ROW '라인삭제' '라인삭제' 0,
                                    '' '' '' '' 3,
                                    'REPLACE' ICON_BOM '대체 BOM 생성' '대체 BOM 생성' 0.
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
      CASE PV_UCOMM.
        WHEN 'TANDEM'. " 오더삭제
          PERFORM PROC_TANDEMBOM.
      ENDCASE.
    WHEN GO_GRID_0200.
      CASE PV_UCOMM.
        WHEN 'ADD'. " 오더삭제
          PERFORM PROC_ADD_LINE_0200.
        WHEN 'DEL'. " 오더삭제
          PERFORM PROC_DEL_LINE_0200.
        WHEN 'REPLACE'. " 오더삭제
          PERFORM PROC_REPLACE_BOM.
      ENDCASE.
  ENDCASE.

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
FORM DATA_CHANGED  USING   P_SENDER  TYPE REF TO CL_GUI_ALV_GRID
                                PO_DATA_CHANGED TYPE REF TO
                                          CL_ALV_CHANGED_DATA_PROTOCOL
                                PE_ONF4
                                PE_UCOMM.

  DATA: LS_MOD_CELLS TYPE LVC_S_MODI.
  DATA : LV_MEINS TYPE MEINS.
  DATA : LV_MAKTX TYPE MAKTX.
  DATA : LV_CHK_ERR.

  DEFINE __MODI_CELL.
    po_data_changed->modify_cell(
      i_row_id     = ls_mod_cells-row_id               " Row ID
      i_fieldname = &1                 " Field Name
      i_value       = &2 ).               " Value
  END-OF-DEFINITION.

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

  CASE P_SENDER.
    WHEN GO_GRID_0200.
      LOOP AT PO_DATA_CHANGED->MT_GOOD_CELLS INTO LS_MOD_CELLS.
        CASE LS_MOD_CELLS-FIELDNAME.
          WHEN 'IDNRK'.
            IF LS_MOD_CELLS-VALUE IS NOT INITIAL.
              PERFORM CHK_VALIDATION_MATNR USING LS_MOD_CELLS-VALUE CHANGING LV_MEINS LV_MAKTX LV_CHK_ERR.
              IF LV_CHK_ERR = ABAP_TRUE.
                __SET_ERR_MSG '유효하지 않은 자재입니다.' 'IDNRK'.
              ELSE.
                __MODI_CELL : 'MEINS' LV_MEINS.
                __MODI_CELL : 'MAKTX2' LV_MAKTX.
              ENDIF.
            ENDIF.

        ENDCASE.
      ENDLOOP.
  ENDCASE.

  IF LV_CHK_ERR IS NOT INITIAL.
    PO_DATA_CHANGED->DISPLAY_PROTOCOL( ).
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHK_VALIDATION_MATNR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LS_MOD_CELLS_VALUE
*&      <-- LV_MEINS
*&      <-- LV_MAKTX
*&---------------------------------------------------------------------*
FORM CHK_VALIDATION_MATNR  USING    PV_VALUE
                           CHANGING PV_MEINS
                                    PV_MAKTX
                                    PV_CHK_ERR.

  DATA : LV_MATNR TYPE MATNR.

  LV_MATNR = PV_VALUE.
  CALL FUNCTION 'CONVERSION_EXIT_MATN1_INPUT'
    EXPORTING
      INPUT        = LV_MATNR
    IMPORTING
      OUTPUT       = LV_MATNR
    EXCEPTIONS
      LENGTH_ERROR = 1
      OTHERS       = 2.
  IF SY-SUBRC <> 0.
* Implement suitable error handling here
  ENDIF.



  SELECT SINGLE A~MATNR, MEINS
    FROM MARA AS A
    INNER JOIN MARC AS B ON B~MATNR = A~MATNR
    INTO @DATA(LS_MARA)
   WHERE A~MATNR = @LV_MATNR
      AND B~WERKS = @P_WERKS
      AND B~MMSTA = ''.
  IF SY-SUBRC EQ 0.
    PV_MEINS = LS_MARA-MEINS.
    PV_MAKTX = ZGTPP_CL_COMMON=>GET_MAKTX( IV_MATNR = LS_MARA-MATNR ).
  ELSE.
    PV_CHK_ERR = ABAP_TRUE.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROC_TANDEMBOM
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PROC_TANDEMBOM .

  DATA : LT_ROWS TYPE LVC_T_ROW.
  DATA : LT_MATNR TYPE RANGE OF MATNR.

  GO_GRID_0100->GET_SELECTED_ROWS(
    IMPORTING
      ET_INDEX_ROWS =   LT_ROWS               " Indexes of Selected Rows
  ).

  DELETE LT_ROWS WHERE INDEX = 0.

  IF LT_ROWS[] IS INITIAL.
    MESSAGE S003 DISPLAY LIKE 'E' WITH '탄뎀 BOM을 생성할 레코드를 선택하세요.'.
    RETURN.
  ENDIF.

  LOOP AT LT_ROWS INTO DATA(LS_ROWS).
    READ TABLE GT_MAIN_0100 ASSIGNING FIELD-SYMBOL(<LS_MAIN_0100>) INDEX LS_ROWS-INDEX.
    IF <LS_MAIN_0100>-STATUS = ICON_LED_GREEN.
      <LS_MAIN_0100>-MESSAGE = '이미 탄뎀 BOM이 생성된 레코드입니다.'.
      CONTINUE.
    ENDIF.

    PERFORM PROC_CREAT_TANDEM_BY_BDC USING <LS_MAIN_0100>-MATNR <LS_MAIN_0100>-FLD_04
                                                     CHANGING <LS_MAIN_0100>-STATUS <LS_MAIN_0100>-MESSAGE.

    IF <LS_MAIN_0100>-STATUS = ICON_LED_GREEN.
      APPEND INITIAL LINE TO LT_MATNR ASSIGNING FIELD-SYMBOL(<LS_MATNR>).
      <LS_MATNR>-SIGN = 'I'.
      <LS_MATNR>-OPTION = 'EQ'.
      <LS_MATNR>-LOW = <LS_MAIN_0100>-MATNR.
    ENDIF.

  ENDLOOP.

  IF LT_MATNR IS NOT INITIAL.
    SORT LT_MATNR BY LOW.
    DELETE ADJACENT DUPLICATES FROM LT_MATNR COMPARING LOW.
* 생산버전 생성
    TRY.
        SUBMIT ZGTPPR1110 WITH P_WERKS EQ P_WERKS
                          WITH P_SPGCD EQ P_SPGCD
                          WITH S_MATNR IN LT_MATNR
                          WITH P_R1    EQ ABAP_TRUE
                          WITH P_R2    EQ SPACE
                          WITH P_R3    EQ SPACE
                          WITH S_ANDAT IN S_ANDAT
                          WITH P_BATCH EQ ABAP_TRUE
                          AND RETURN.

        WAIT UP TO 1 SECONDS.

      CATCH CX_ROOT INTO DATA(LR_ROOT).
    ENDTRY.
  ENDIF.

  PERFORM REFRESH_GRID USING GO_GRID_0100.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROC_CREAT_TANDEM_BY_BDC
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> <LS_MAIN_0100>_MATNR
*&      <-- <LS_MAIN_0100>_MESSAGE
*&---------------------------------------------------------------------*
FORM PROC_CREAT_TANDEM_BY_BDC  USING    PV_MATNR
                                             PV_ARBPL
                               CHANGING PV_STATUS PV_MESSAGE.

  DATA : LV_MATKL TYPE MATKL.
  READ TABLE GT_1010 INTO DATA(LS_1010) WITH KEY FLD_04 = PV_ARBPL.
  IF SY-SUBRC EQ 0.
    CLEAR LV_MATKL.
    LV_MATKL = '%' && LS_1010-FLD_08 && '%'.
  ELSE.
    PV_MESSAGE = '이전공정 반제품 유형이 지정되지 않았습니다.'.
    RETURN.
  ENDIF.

  SELECT DISTINCT
       A~MATNR,
       C~IDNRK,
       C~POSNR
    FROM MAST AS A
    INNER JOIN STKO AS B
                           ON B~STLNR = A~STLNR
                         AND B~STLAL = A~STLAL
    INNER JOIN STPO AS C
                           ON C~STLNR = B~STLNR
                         AND C~STLTY = B~STLTY
    INNER JOIN MARA AS D
                          ON D~MATNR = C~IDNRK
   WHERE A~MATNR = @PV_MATNR
      AND A~WERKS  = @P_WERKS
      AND A~STLAN = '1'
      AND A~STLAL  = '01'
      AND B~STLTY  = 'M'
      AND B~LKENZ NE 'X'
      AND C~LKENZ NE 'X'
      AND D~MATKL LIKE @LV_MATKL
      AND D~MTART IN ( 'FERT', 'MCFE', 'HALB', 'MCHF' )
     INTO TABLE @DATA(LT_BOM).

  SORT LT_BOM BY MATNR IDNRK POSNR.
  DELETE ADJACENT DUPLICATES FROM LT_BOM COMPARING MATNR IDNRK POSNR.


  IF LT_BOM[] IS INITIAL.
    PV_MESSAGE = '이전공정 BOM 구성자재를 찾을수 없습니다.'.
    RETURN.
  ENDIF.

  REFRESH : GT_BDCDATA, GT_MESSTAB.

*  __SETTING_BDC_PARAMS.
  CLEAR: GS_BDCPARAMS.
  GS_BDCPARAMS-DISMODE  = 'N'.   " 처리모드
  GS_BDCPARAMS-UPDMODE  = 'A'.   " 갱신세션
*  MS_BDCPARAMS-CATTMODE = ''.   " CATT모드
  GS_BDCPARAMS-DEFSIZE  = 'X'.   " 기본화면
  GS_BDCPARAMS-RACOMMIT = 'X'.   " COMMAND 이후 지속
  GS_BDCPARAMS-NOBINPT  = 'X'.   " BI 세션


  __BDC_DYNPRO 'SAPLCSDI' '0100'.
  __BDC_FIELD : 'BDC_OKCODE' '=VOKO',
                      'RC29N-MATNR'  PV_MATNR,
                      'RC29N-WERKS'  P_WERKS,
                      'RC29N-STLAN'  '1',
                      'RC29N-STLAL'  '90'.

  __BDC_DYNPRO 'SAPLCSDI' '0105'.
  __BDC_FIELD : 'BDC_OKCODE' '=CLWI',
                      'RC29N-STLAL'  '01'.

  __BDC_DYNPRO 'SAPLCSDI' '0157'.
  __BDC_FIELD : 'BDC_OKCODE' '=MALL'.

  __BDC_DYNPRO 'SAPLCSDI' '0157'.
  __BDC_FIELD : 'BDC_OKCODE' '=FCUE'.

  LOOP AT LT_BOM INTO DATA(LS_BOM).

    __BDC_DYNPRO 'SAPLCSDI' '2150'.
    __BDC_FIELD : 'BDC_OKCODE' '=SETP'.

    __BDC_DYNPRO 'SAPLCSDI' '0708'.
    __BDC_FIELD : 'BDC_OKCODE' '=CLWI',
                        'BDC_CURSOR'  'RC29P-SELPO',
                        'RC29P-SELPO'  LS_BOM-POSNR.

    __BDC_DYNPRO 'SAPLCSDI' '2150'.
    __BDC_FIELD : 'BDC_OKCODE' '=PALL',
                        'RC29P-AUSKZ(01)'  'X'.

    __BDC_DYNPRO 'SAPLCSDI' '2130'.
    __BDC_FIELD : 'BDC_OKCODE' '/00',
                        'RC29P-ITSOB'  '50'.

    __BDC_DYNPRO 'SAPLCSDI' '2130'.
    __BDC_FIELD : 'BDC_OKCODE' '/EBACK'.
  ENDLOOP.

  __BDC_DYNPRO 'SAPLCSDI' '2150'.
  __BDC_FIELD : 'BDC_OKCODE' '=FCBU'.

  __BDC_TRANSACTION 'CS01'.

  READ TABLE GT_MESSTAB INTO DATA(LS_MESSTAB) WITH KEY MSGTYP = 'E'.
  IF SY-SUBRC EQ 0.
    PV_STATUS = ICON_LED_RED.
    MESSAGE ID LS_MESSTAB-MSGID TYPE 'S' NUMBER LS_MESSTAB-MSGNR
        WITH LS_MESSTAB-MSGV1 LS_MESSTAB-MSGV2 LS_MESSTAB-MSGV3 LS_MESSTAB-MSGV4
        INTO  PV_MESSAGE.
  ELSE.
    PV_STATUS = ICON_LED_GREEN.
    PV_MESSAGE = '탄뎀 BOM을 성공적으로 생성하였습니다.'.
    COMMIT WORK AND  WAIT.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form REFRESH_GRID
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GO_GRID_0100
*&---------------------------------------------------------------------*
FORM REFRESH_GRID  USING    PO_GRID TYPE REF TO CL_GUI_ALV_GRID.

  DATA: LS_SCROLL   TYPE LVC_S_STBL.

  LS_SCROLL-ROW = 'X'.
  LS_SCROLL-COL = 'X'.

  CASE PO_GRID.
    WHEN GO_GRID_0100.
      GO_GRID_0100->SET_FRONTEND_LAYOUT( IS_LAYOUT = GS_LAYOUT_0100 ).
    WHEN GO_GRID_0200.
      GO_GRID_0200->SET_FRONTEND_LAYOUT( IS_LAYOUT = GS_LAYOUT_0200 ).
  ENDCASE.

  CALL METHOD PO_GRID->REFRESH_TABLE_DISPLAY
    EXPORTING
*     I_SOFT_REFRESH = 'X'
      IS_STABLE = LS_SCROLL.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROC_ADD_LINE_0200
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PROC_ADD_LINE_0200 .

  APPEND INITIAL LINE TO GT_MAIN_0200.
  PERFORM REFRESH_GRID USING GO_GRID_0200.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROC_DEL_LINE_0200
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PROC_DEL_LINE_0200 .

  DATA : LT_ROWS TYPE LVC_T_ROW.

  GO_GRID_0200->GET_SELECTED_ROWS(
    IMPORTING
      ET_INDEX_ROWS =   LT_ROWS               " Indexes of Selected Rows
  ).

  DELETE LT_ROWS WHERE INDEX = 0.

  IF LT_ROWS[] IS INITIAL.
    MESSAGE S003 DISPLAY LIKE 'E' WITH '삭제할 라인을 선택하세요.'.
    RETURN.
  ENDIF.

*  삭제는 인덱스 역순으로
  SORT LT_ROWS BY INDEX DESCENDING.
  LOOP AT LT_ROWS INTO DATA(LS_ROW).
    DELETE GT_MAIN_0200 INDEX LS_ROW-INDEX.
  ENDLOOP.
  PERFORM REFRESH_GRID USING GO_GRID_0200.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROC_REPLACE_BOM
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PROC_REPLACE_BOM .

  DATA : LT_MOSU LIKE GT_MAIN_0200.
  DATA : LV_MEINS TYPE MEINS.
  DATA : LV_MAKTX TYPE MAKTX.
  DATA : LV_CHK_ERR.
  DATA : LV_EXIST_ERR.
  DATA : LV_MESSAGE(220).

  REFRESH LT_MOSU.
  LT_MOSU = VALUE #( FOR LW_MAIN IN GT_MAIN_0200 WHERE ( IDNRK IS NOT INITIAL )
                             ( CORRESPONDING #( LW_MAIN ) ) ).

  IF LT_MOSU[] IS INITIAL.
    MESSAGE S003 DISPLAY LIKE 'E' WITH '대체 BOM 구성을 위한 자재코드가 입력되지 않았습니다.'.
    RETURN.
  ENDIF.

  LOOP AT GT_MAIN_0200 ASSIGNING FIELD-SYMBOL(<LS_CHK_DATA>) WHERE IDNRK IS NOT INITIAL.
    CLEAR LV_CHK_ERR.
    PERFORM CHK_VALIDATION_MATNR USING <LS_CHK_DATA>-IDNRK CHANGING LV_MEINS LV_MAKTX LV_CHK_ERR.
    IF LV_CHK_ERR = ABAP_TRUE.
      <LS_CHK_DATA>-MENGE = '유효하지 않은 자재입니다.'.
      LV_EXIST_ERR = ABAP_TRUE.
      CONTINUE.
    ENDIF.

    IF <LS_CHK_DATA>-MENGE = 0.
      <LS_CHK_DATA>-MENGE = '자재 수량이 입력되지 않았습니다.'.
      LV_EXIST_ERR = ABAP_TRUE.
      CONTINUE.
    ENDIF.

  ENDLOOP.

  IF LV_EXIST_ERR = ABAP_TRUE.
    MESSAGE S003 DISPLAY LIKE 'E' WITH '봄 구성을 위한 입력필드를 확인하세요.'.
    PERFORM REFRESH_GRID USING GO_GRID_0200.
    RETURN.
  ENDIF.

  CLEAR LV_CHK_ERR.
* 대체봄 구성
  PERFORM PROC_CREATE_REPL_BOM TABLES LT_MOSU CHANGING LV_CHK_ERR LV_MESSAGE.

  LOOP AT GT_MAIN_0200 ASSIGNING <LS_CHK_DATA> WHERE IDNRK IS NOT INITIAL.
    IF LV_CHK_ERR = ABAP_TRUE.
      <LS_CHK_DATA>-STATUS = ICON_LED_RED.
      <LS_CHK_DATA>-MESSAGE = LV_MESSAGE.
    ELSE.
      <LS_CHK_DATA>-STATUS = ICON_LED_GREEN.
      <LS_CHK_DATA>-MESSAGE = '대체 BOM 성공적으로 생성하였습니다.'.
    ENDIF.
  ENDLOOP.

  PERFORM REFRESH_GRID USING GO_GRID_0200.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROC_CREATE_REPL_BOM
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LT_MOSU
*&      <-- LV_CHK_ERR
*&---------------------------------------------------------------------*
FORM PROC_CREATE_REPL_BOM  TABLES  PT_MOSU STRUCTURE GS_MAIN_0200
                           CHANGING PV_CHK_ERR
                                         PV_MESSAGE.

  DATA :LV_NUM(2) TYPE N.
  DATA : LV_FIELDNAME TYPE FNAM_____4.
  DATA : LV_MENGE_C TYPE CHAR30.

  REFRESH :  GT_BDCDATA, GT_MESSTAB.

*  __SETTING_BDC_PARAMS.

  CLEAR: GS_BDCPARAMS.
  GS_BDCPARAMS-DISMODE  = 'N'.   " 처리모드
  GS_BDCPARAMS-UPDMODE  = 'A'.   " 갱신세션
*  MS_BDCPARAMS-CATTMODE = ''.   " CATT모드
  GS_BDCPARAMS-DEFSIZE  = 'X'.   " 기본화면
  GS_BDCPARAMS-RACOMMIT = 'X'.   " COMMAND 이후 지속
  GS_BDCPARAMS-NOBINPT  = 'X'.   " BI 세션

  __BDC_DYNPRO 'SAPLCSDI' '0100'.
  __BDC_FIELD : 'BDC_OKCODE' '/00',
                      'RC29N-MATNR'  P_MATNR,
                      'RC29N-WERKS'  P_WERKS,
                      'RC29N-STLAN'  '1',
                      'RC29N-STLAL'  '02'.


  __BDC_DYNPRO 'SAPLCSDI' '2150'.
  __BDC_FIELD : 'BDC_OKCODE' '/00'.

  CLEAR LV_NUM.
  LOOP AT PT_MOSU INTO DATA(LS_BOM).
    ADD 1 TO LV_NUM.


*  품목 범주(BOM)
    CLEAR LV_FIELDNAME.
    LV_FIELDNAME = |RC29P-POSTP({ LV_NUM })|.
    __BDC_FIELD : LV_FIELDNAME 'L'.

*  자재코드
    CLEAR LV_FIELDNAME.
    LV_FIELDNAME = |RC29P-IDNRK({ LV_NUM })|.
    __BDC_FIELD : LV_FIELDNAME LS_BOM-IDNRK.
*  수량
    CLEAR LV_MENGE_C.
    LV_MENGE_C = LS_BOM-MENGE.
    CONDENSE LV_MENGE_C.
    CLEAR LV_FIELDNAME.
    LV_FIELDNAME = |RC29P-MENGE({ LV_NUM })|.
    __BDC_FIELD : LV_FIELDNAME LV_MENGE_C.
*  단위
    CLEAR LV_FIELDNAME.
    LV_FIELDNAME = |RC29P-MEINS({ LV_NUM })|.
    __BDC_FIELD : LV_FIELDNAME LS_BOM-MEINS.

  ENDLOOP.

  __BDC_DYNPRO 'SAPLCSDI' '2150'.
  __BDC_FIELD : 'BDC_OKCODE' '=FCBU'.

  __BDC_TRANSACTION 'CS01'.

  READ TABLE GT_MESSTAB INTO DATA(LS_MESSTAB) WITH KEY MSGTYP = 'E'.
  IF SY-SUBRC EQ 0.
    MESSAGE ID LS_MESSTAB-MSGID TYPE 'S' NUMBER LS_MESSTAB-MSGNR
        WITH LS_MESSTAB-MSGV1 LS_MESSTAB-MSGV2 LS_MESSTAB-MSGV3 LS_MESSTAB-MSGV4
        INTO  PV_MESSAGE.
    PV_CHK_ERR = ABAP_TRUE.
  ELSE.
    COMMIT WORK AND  WAIT.
  ENDIF.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form HOTSPOT_CLICK
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> SENDER
*&      --> E_ROW_ID
*&---------------------------------------------------------------------*
FORM HOTSPOT_CLICK  USING    P_SENDER  TYPE REF TO CL_GUI_ALV_GRID
                             PS_ROW_ID TYPE LVC_S_ROW.

  IF PS_ROW_ID-INDEX = 0.
    RETURN.
  ENDIF.

  CASE P_SENDER.
    WHEN GO_GRID_0300.
      READ TABLE GT_MAIN_0300 INTO DATA(LS_MAIN) INDEX PS_ROW_ID-INDEX.
      SET PARAMETER ID 'MAT' FIELD LS_MAIN-MATNR.
      SET PARAMETER ID 'WRK' FIELD P_WERKS.
      SET PARAMETER ID 'CSV' FIELD '1'.

      CALL TRANSACTION 'CS03' AND SKIP FIRST SCREEN.

  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form MAKE_TANDEM_PROCESS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM MAKE_TANDEM_PROCESS .

  IF GT_MAIN_0100[] IS INITIAL.
    MESSAGE S003 WITH '탄뎀 BOM 생성자재가 없습니다.'.
    LEAVE LIST-PROCESSING.
  ENDIF.

  IF NOT LINE_EXISTS( GT_MAIN_0100[ STATUS = ICON_LED_INACTIVE ] ).
    MESSAGE S003 WITH '탄뎀 BOM 생성자재가 없습니다.'.
    LEAVE LIST-PROCESSING.
  ENDIF.

  LOOP AT GT_MAIN_0100 INTO DATA(LS_MAIN) WHERE STATUS = ICON_LED_INACTIVE.
    PERFORM PROC_CREAT_TANDEM_BY_BDC USING LS_MAIN-MATNR LS_MAIN-FLD_04
                                                     CHANGING LS_MAIN-STATUS LS_MAIN-MESSAGE.
  ENDLOOP.

  MESSAGE S003 WITH '탄뎀 BOM 생성 완료되었습니다.'.

ENDFORM.
