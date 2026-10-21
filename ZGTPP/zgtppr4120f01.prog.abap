*&---------------------------------------------------------------------*
*& Include          ZGTPPR4120F01
*&---------------------------------------------------------------------*
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

* 플랜트명
  IF NOT P_WERKS IS INITIAL.
    SELECT SINGLE NAME1 INTO P_NAME1
             FROM T001W
            WHERE WERKS EQ P_WERKS.
  ELSE.
    CLEAR P_NAME1.
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
    IF SCREEN-GROUP1 = 'M1'.
      SCREEN-INPUT = 0.
      SCREEN-INTENSIFIED = 1.
      MODIFY SCREEN.
    ENDIF.

    IF SCREEN-GROUP1 = 'M2'.
      SCREEN-ACTIVE = 0.
      MODIFY SCREEN.
    ENDIF.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROC_GET_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PROC_GET_DATA .

  REFRESH GT_MAIN_DISP.

  PERFORM INIT.
  PERFORM GET_MOSU.

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
  AUTHORITY-CHECK OBJECT 'ZPP_SPGCD'
  ID 'WERKS'  FIELD P_WERKS
  ID 'SPGCD'  FIELD P_SPGCD.

  IF SY-SUBRC <> 0.
    MESSAGE E006 WITH 'SPG[' P_SPGCD
                      '] 작업권한을 확인하세요.'.
  ENDIF.

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

  IF GT_MAIN_DISP IS INITIAL.
    MESSAGE S001 DISPLAY LIKE 'E'.
  ELSE.
    CALL SCREEN '0100'.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_MOSU
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_MOSU .

  DATA : LV_DISPO TYPE MARC-DISPO.
  DATA : LT_AUFNR TYPE RANGE OF AUFNR.
  DATA : LT_MATNR TYPE RANGE OF MATNR.
  DATA : BEGIN OF LS_CHK_MSEG,
           AUFNR TYPE MSEG-AUFNR,
           MATNR TYPE MSEG-MATNR,
           MENGE TYPE MSEG-MENGE,
           MEINS TYPE MSEG-MEINS,
           BWART TYPE MSEG-BWART,
         END OF LS_CHK_MSEG.
  DATA : LT_CHK_MSEG LIKE TABLE OF LS_CHK_MSEG.
  DATA : LT_COLLECT_MSEG LIKE TABLE OF LS_CHK_MSEG.
  DATA : LV_CHK_MOSU.
  DATA : LT_MSEG_CHK TYPE TABLE OF MSEG.
  DATA : LV_LINES TYPE I.
  DATA : LV_CAL_MENGE TYPE MENGE_D.
  DATA : LS_4150  TYPE ZGTPPT4150.
  DATA : LT_DLV TYPE RANGE OF ABAP_BOOL.

* SPG 테이블 조회용 필드로 변경
  LV_DISPO = P_SPGCD && '%'. "

  IF P_DLV = ABAP_TRUE.
  ELSE.
    APPEND INITIAL LINE TO LT_DLV ASSIGNING FIELD-SYMBOL(<LS_DLV>).
    <LS_DLV>-SIGN = 'I'.
    <LS_DLV>-OPTION = 'EQ'.
  ENDIF.

  SELECT * FROM ZGTCVORDSYVAL
    INTO TABLE GT_ORDSYVAL
   WHERE WERKS = P_WERKS
     AND AUFNR IN S_AUFNR
     AND KDAUF IN S_KDAUF
     AND KDPOS IN S_KDPOS
     AND DISPO LIKE LV_DISPO
     AND PDCAPROCCODE IN S_GONGCD
     AND DLFL = ''
     AND LKD = ''
     AND CLSD = ''
     AND TECO = ''
     AND REL = ABAP_TRUE
     AND DLV IN  LT_DLV.

  CHECK SY-SUBRC EQ 0.

  SELECT * FROM ZGTPPT4150
    INTO TABLE GT_4150
   WHERE WERKS = P_WERKS
     AND WIPST = 'W'.

  SELECT * FROM ZGTPPT4150
    INTO TABLE GT_4150_ENDED
   WHERE WERKS = P_WERKS
     AND WIPST = 'P'
     AND CONF_SPMON = P_SPMON.

  SORT GT_4150 BY AUFNR.
  IF GT_4150[] IS NOT INITIAL.
    REFRESH LT_AUFNR.
    LT_AUFNR = VALUE #( FOR LW_4150 IN GT_4150 WHERE ( AUFNR IS NOT INITIAL )
                  ( SIGN = 'I' OPTION = 'EQ' LOW = LW_4150-AUFNR ) ).

    SELECT * FROM ZGTPPT4151
        INTO TABLE @GT_4151
       WHERE WERKS = @P_WERKS
         AND AUFNR IN @LT_AUFNR
         AND RUECK_R NE ' '.

    SELECT * FROM ZGTPPT4152
        INTO TABLE @GT_4152
       WHERE WERKS = @P_WERKS
         AND AUFNR IN @LT_AUFNR
         AND MBLNR_R NE ' '.

    SORT GT_4151 BY AUFNR.
    SORT GT_4152 BY AUFNR.

  ENDIF.

  REFRESH LT_AUFNR.
  LT_AUFNR = VALUE #( FOR LW_ORDSYVAL IN GT_ORDSYVAL WHERE ( AUFNR IS NOT INITIAL )
                    ( SIGN = 'I' OPTION = 'EQ' LOW = LW_ORDSYVAL-AUFNR ) ).

  SELECT * FROM MSEG
    INTO CORRESPONDING FIELDS OF TABLE @LT_CHK_MSEG
   WHERE AUFNR IN @LT_AUFNR
     AND BWART IN ( '261', '262' ).
  IF SY-SUBRC EQ 0.

    LOOP AT LT_CHK_MSEG INTO LS_CHK_MSEG.
      IF LS_CHK_MSEG-BWART = '262'.
        LS_CHK_MSEG-MENGE = LS_CHK_MSEG-MENGE * -1.
      ENDIF.

      CLEAR LS_CHK_MSEG-BWART.
      COLLECT LS_CHK_MSEG INTO LT_COLLECT_MSEG.
    ENDLOOP.

    SORT LT_CHK_MSEG BY AUFNR.

  ENDIF.

  REFRESH GT_ORD_MOSU.

* wip 모수 추출
*③ 투입 합계 수량이 > 0 or ZGTCVORDSYVAL-PCNF or ZGTCVORDSYVAL-PDLV 이면 WIP 오더
  LOOP AT GT_ORDSYVAL INTO DATA(LS_ORDSYVAL).
    CASE ABAP_TRUE.
      WHEN LS_ORDSYVAL-DLV.
      WHEN LS_ORDSYVAL-PCNF OR LS_ORDSYVAL-PDLV.
      WHEN OTHERS.

        READ TABLE GT_4150 TRANSPORTING NO FIELDS WITH KEY AUFNR = LS_ORDSYVAL-AUFNR.
        IF SY-SUBRC NE 0.

          CLEAR LV_CHK_MOSU.
          READ TABLE LT_CHK_MSEG TRANSPORTING NO FIELDS WITH KEY AUFNR = LS_ORDSYVAL-AUFNR.
          IF SY-SUBRC EQ 0.
            LOOP AT LT_CHK_MSEG INTO LS_CHK_MSEG FROM SY-TABIX.
              IF LS_CHK_MSEG-AUFNR NE LS_ORDSYVAL-AUFNR.
                EXIT.
              ENDIF.
              IF LS_CHK_MSEG-MENGE > 0.
                LV_CHK_MOSU = ABAP_TRUE.
                EXIT.
              ENDIF.
            ENDLOOP.

            IF LV_CHK_MOSU IS INITIAL.
              CONTINUE.
            ENDIF.
          ENDIF.
        ENDIF.
    ENDCASE.
    APPEND LS_ORDSYVAL TO GT_ORD_MOSU.
  ENDLOOP.

  CHECK GT_ORD_MOSU IS NOT INITIAL.
  SORT GT_ORD_MOSU BY AUFNR.
  DELETE ADJACENT DUPLICATES FROM GT_ORD_MOSU COMPARING AUFNR.

* 확정, 투입, 입고 상태 확인을 위한 데이터 모수 가져오기
  REFRESH LT_AUFNR.
  LT_AUFNR = VALUE #( FOR LW_ORDSYVAL IN GT_ORD_MOSU WHERE ( AUFNR IS NOT INITIAL )
                    ( SIGN = 'I' OPTION = 'EQ' LOW = LW_ORDSYVAL-AUFNR ) ).

  REFRESH LT_MATNR.
  LT_MATNR = VALUE #( FOR LW_ORDSYVAL IN GT_ORD_MOSU WHERE ( MATNR IS NOT INITIAL )
                      ( SIGN = 'I' OPTION = 'EQ' LOW = LW_ORDSYVAL-MATNR ) ).

  SORT LT_AUFNR BY LOW.
  DELETE ADJACENT DUPLICATES FROM LT_AUFNR COMPARING LOW.

  SORT LT_MATNR BY LOW.
  DELETE ADJACENT DUPLICATES FROM LT_MATNR COMPARING LOW.

  REFRESH GT_AFRU.
  SELECT DISTINCT A~AUFNR, C~RUECK, C~RMZHL, C~BUDAT
    FROM AFKO AS A
    INNER JOIN AFVC AS B ON B~AUFPL = A~AUFPL
    INNER JOIN AFRU AS C ON C~AUFPL = B~AUFPL
                        AND C~ARBID = B~ARBID
    INTO CORRESPONDING FIELDS OF TABLE @GT_AFRU
   WHERE A~AUFNR IN @LT_AUFNR
     AND C~STOKZ = ''
     AND C~STZHL = '00000000'. " 역분개 제외

  SORT GT_AFRU BY AUFNR.

  LOOP AT GT_AFRU ASSIGNING FIELD-SYMBOL(<LS_AFRU>).
    READ TABLE GT_4151 TRANSPORTING NO FIELDS WITH KEY RUECK_R = <LS_AFRU>-RUECK
                                                       RMZHL_R = <LS_AFRU>-RMZHL.
    IF SY-SUBRC EQ 0.
      DELETE GT_AFRU.
    ENDIF.

  ENDLOOP.

  SELECT * FROM MSEG
    INTO TABLE @DATA(LT_MSEG)
   WHERE AUFNR IN @LT_AUFNR.

  LT_MSEG_CHK = VALUE #( FOR LW_MSEG IN LT_MSEG WHERE ( SMBLN IS NOT INITIAL )
                       ( CORRESPONDING #( LW_MSEG ) ) ).
  SORT LT_MSEG_CHK BY SMBLN SMBLP.

  REFRESH GT_MSEG_MOSU.
  LOOP AT LT_MSEG INTO DATA(LS_MSEG).
    READ TABLE LT_MSEG_CHK INTO DATA(LS_MSEG_CHK) WITH KEY SMBLN = LS_MSEG-MBLNR
                                                           SMBLP = LS_MSEG-ZEILE
                                                           BINARY SEARCH.
    IF SY-SUBRC EQ 0.
      CONTINUE.
* 제외대상
    ELSE.

      IF LS_MSEG-SMBLN IS NOT INITIAL.
        CONTINUE.
      ELSE.
        IF LS_MSEG-AUFPL = ''. " Backflush 대상 제외
          APPEND LS_MSEG TO GT_MSEG_MOSU.
        ENDIF.
      ENDIF.
    ENDIF.

  ENDLOOP.

  REFRESH : LT_MSEG, LT_MSEG_CHK.
  FREE : LT_MSEG, LT_MSEG_CHK.

* 자재색상 조회
  IF LT_MATNR IS NOT INITIAL.
    SELECT * FROM ZGTCVMSTVAL
      INTO TABLE @DATA(LT_MSTVAL)
     WHERE MATNR IN @LT_MATNR
       AND WERKS = @P_WERKS.
  ENDIF.

  SORT GT_MSEG_MOSU BY AUFNR.

  LOOP AT GT_ORD_MOSU INTO DATA(LS_ORD_MOSU).
    CLEAR GS_MAIN_DISP.
    GS_MAIN_DISP-WERKS = P_WERKS.
    GS_MAIN_DISP-GONG_CD = LS_ORD_MOSU-PDCAPROCCODE.
    GS_MAIN_DISP-GONG_NAME = LS_ORD_MOSU-PDCAPROCNAME.
    GS_MAIN_DISP-AUART = LS_ORD_MOSU-AUART.
    GS_MAIN_DISP-AUFNR = LS_ORD_MOSU-AUFNR.
    GS_MAIN_DISP-MATNR = LS_ORD_MOSU-MATNR.
    GS_MAIN_DISP-MAKTX = LS_ORD_MOSU-MAKTX.
    READ TABLE LT_MSTVAL INTO DATA(LS_MSTVAL) WITH KEY MATNR = LS_ORD_MOSU-MATNR.
    IF SY-SUBRC EQ 0.
      GS_MAIN_DISP-COLOR = LS_MSTVAL-COLORBASE.
    ENDIF.
    GS_MAIN_DISP-ARBPL = LS_ORD_MOSU-ARBPL.
    GS_MAIN_DISP-KTEXT = LS_ORD_MOSU-KTEXT.
    GS_MAIN_DISP-GAMNG = LS_ORD_MOSU-GAMNG.
    GS_MAIN_DISP-GMEIN = LS_ORD_MOSU-GMEIN.
* 전기 데이터 기준
    REFRESH LT_MSEG_CHK.
    LT_MSEG_CHK = VALUE #( FOR LW_MSEG IN GT_MSEG_MOSU WHERE ( AUFNR = LS_ORD_MOSU-AUFNR )
                         ( CORRESPONDING #( LW_MSEG ) ) ).

    SORT LT_MSEG_CHK BY BUDAT_MKPF.
    READ TABLE LT_MSEG_CHK INTO LS_MSEG_CHK INDEX 1 .
    IF SY-SUBRC EQ 0.
      GS_MAIN_DISP-SBUDAT = LS_MSEG_CHK-BUDAT_MKPF.
    ENDIF.

    CLEAR LV_LINES.
    LV_LINES = LINES( LT_MSEG_CHK ) .
    READ TABLE LT_MSEG_CHK INTO LS_MSEG_CHK INDEX LV_LINES .
    IF SY-SUBRC EQ 0.
      GS_MAIN_DISP-EBUDAT = LS_MSEG_CHK-BUDAT_MKPF.
    ENDIF.

* 상태(확정)
    GS_MAIN_DISP-STATUS_01 = ICON_LED_INACTIVE.

    LOOP AT GT_AFRU INTO DATA(LS_AFRU) WHERE AUFNR = LS_ORD_MOSU-AUFNR
                                         AND BUDAT IN GT_BUDAT.
      GS_MAIN_DISP-STATUS_01 = ICON_LED_GREEN.
      EXIT.
    ENDLOOP.


* 상태(확정취소)
* 기본상태 인액티브
    GS_MAIN_DISP-STATUS_02 = ICON_LED_INACTIVE.
    READ TABLE GT_4151 TRANSPORTING NO FIELDS WITH KEY AUFNR = LS_ORD_MOSU-AUFNR.
    IF SY-SUBRC EQ 0.
      LOOP AT GT_4151 INTO DATA(LS_4151) FROM SY-TABIX.
        IF LS_4151-AUFNR NE LS_ORD_MOSU-AUFNR.
          EXIT.
        ENDIF.

        IF LS_4151-RUECK_P IS INITIAL.
          GS_MAIN_DISP-STATUS_02 = ICON_LED_GREEN.
          EXIT.
        ENDIF.

      ENDLOOP.
    ENDIF.


* 상태(투입)
    CLEAR LV_CAL_MENGE.
    GS_MAIN_DISP-STATUS_03 = ICON_LED_INACTIVE.
    LOOP AT LT_MSEG_CHK INTO LS_MSEG_CHK WHERE ( BWART = '261' OR BWART = '262')
                                           AND BUDAT_MKPF IN GT_BUDAT.
      IF LS_MSEG_CHK-BWART = '262'.
        LV_CAL_MENGE = LV_CAL_MENGE - LS_MSEG_CHK-MENGE.
      ELSE.
        LV_CAL_MENGE = LV_CAL_MENGE + LS_MSEG_CHK-MENGE.
      ENDIF.
    ENDLOOP.
    IF LV_CAL_MENGE > 0.
      GS_MAIN_DISP-STATUS_03 = ICON_LED_GREEN.
    ENDIF.


* 상태(투입취소)
* 기본상태 인액티브
    GS_MAIN_DISP-STATUS_04 = ICON_LED_INACTIVE.
    READ TABLE GT_4152 TRANSPORTING NO FIELDS WITH KEY AUFNR = LS_ORD_MOSU-AUFNR
                                                       ZGRGI = 'GI'                                         .
    IF SY-SUBRC EQ 0.
      LOOP AT GT_4152 INTO DATA(LS_4152) FROM SY-TABIX.
        IF LS_4152-AUFNR NE LS_ORD_MOSU-AUFNR.
          EXIT.
        ENDIF.

        IF LS_4152-ZGRGI NE 'GI'.
          CONTINUE.
        ENDIF.

        IF LS_4152-MBLNR_P IS INITIAL.
          GS_MAIN_DISP-STATUS_04 = ICON_LED_GREEN.
          EXIT.
        ENDIF.

      ENDLOOP.
    ENDIF.


* 상태(입고)
    CLEAR LV_CAL_MENGE.
    GS_MAIN_DISP-STATUS_05 = ICON_LED_INACTIVE.
    LOOP AT LT_MSEG_CHK INTO LS_MSEG_CHK WHERE ( BWART = '101' OR BWART = '102' )
                                           AND BUDAT_MKPF IN GT_BUDAT..
      IF LS_MSEG_CHK-BWART = '102'.
        LV_CAL_MENGE = LV_CAL_MENGE - LS_MSEG_CHK-MENGE.
      ELSE.
        LV_CAL_MENGE = LV_CAL_MENGE + LS_MSEG_CHK-MENGE.
      ENDIF.
    ENDLOOP.

    IF LV_CAL_MENGE > 0.
      GS_MAIN_DISP-STATUS_05 = ICON_LED_GREEN.
    ENDIF.


* 상태(입고취소)
* 기본상태 인액티브
    GS_MAIN_DISP-STATUS_06 = ICON_LED_INACTIVE.
    READ TABLE GT_4152 TRANSPORTING NO FIELDS WITH KEY AUFNR = LS_ORD_MOSU-AUFNR
                                                       ZGRGI = 'GR'                                         .
    IF SY-SUBRC EQ 0.
      LOOP AT GT_4152 INTO LS_4152 FROM SY-TABIX.
        IF LS_4152-AUFNR NE LS_ORD_MOSU-AUFNR.
          EXIT.
        ENDIF.

        IF LS_4152-ZGRGI NE 'GR'.
          CONTINUE.
        ENDIF.

        IF LS_4152-MBLNR_P IS INITIAL.
          GS_MAIN_DISP-STATUS_06 = ICON_LED_GREEN.
          EXIT.
        ENDIF.

      ENDLOOP.
    ENDIF.


    CASE ICON_LED_GREEN.
      WHEN GS_MAIN_DISP-STATUS_01 OR GS_MAIN_DISP-STATUS_02 OR GS_MAIN_DISP-STATUS_03 OR
        GS_MAIN_DISP-STATUS_04 OR GS_MAIN_DISP-STATUS_05 OR GS_MAIN_DISP-STATUS_06.
        APPEND GS_MAIN_DISP TO GT_MAIN_DISP.
      WHEN OTHERS.
        READ TABLE GT_4150 TRANSPORTING NO FIELDS WITH KEY AUFNR = GS_MAIN_DISP-AUFNR.
        IF SY-SUBRC EQ 0.
          APPEND GS_MAIN_DISP TO GT_MAIN_DISP.
        ENDIF.
    ENDCASE.

  ENDLOOP.

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

  IF P_DLV = ABAP_TRUE.
    IF S_AUFNR[] IS INITIAL.
      MESSAGE S003 DISPLAY LIKE 'E' WITH '입고 완료 포함시 반드시 생산오더 입력되어야 합니다.'.
      LEAVE LIST-PROCESSING.
    ENDIF.
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
                            P_ROW TYPE LVC_S_ROW
                            P_COLUMN TYPE LVC_S_COL.

  CHECK P_ROW-INDEX > 0.

  CASE P_SENDER.
    WHEN GO_GRID_0100.
      READ TABLE GT_MAIN_DISP ASSIGNING FIELD-SYMBOL(<LS_MAIN>) INDEX P_ROW-INDEX.

      CASE P_COLUMN-FIELDNAME.
        WHEN 'AUFNR'.
          SET PARAMETER ID 'ANR' FIELD <LS_MAIN>-AUFNR.
          CALL TRANSACTION 'CO03' AND SKIP FIRST SCREEN.

      ENDCASE.

  ENDCASE.

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
  ENDCASE.

  CALL METHOD PO_GRID->REFRESH_TABLE_DISPLAY
    EXPORTING
*     I_SOFT_REFRESH = 'X'
      IS_STABLE = LS_SCROLL.

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

  CREATE OBJECT GO_CONTAIN_0100
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
      I_PARENT      = GO_CONTAIN_0100
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

*// Event Handler ##
  SET HANDLER GO_EVENT_HANDLER->HANDLE_DOUBLE_CLICK          FOR PO_GRID.

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

  DATA : LV_TEXT1 TYPE CHAR100.
  DATA : LV_TEXT2 TYPE CHAR100.
  DATA : LV_TEXT3 TYPE CHAR100.
  DATA : LV_NAME1 TYPE T001W-NAME1.
  DATA : LV_DESCR TYPE ZPPT0107-DESCR.

* 플랜트명
  CLEAR LV_NAME1.
  LV_NAME1 = ZGTPP_CL_COMMON=>GET_PLANT_NAME( IV_WERKS = P_WERKS ).

* SPG명
  CLEAR LV_DESCR.
  SELECT SINGLE DESCR INTO LV_DESCR
         FROM ZPPT0107
        WHERE SPGCD EQ P_SPGCD.

  CLEAR GS_LAYOUT_0100.
  GS_LAYOUT_0100-CWIDTH_OPT = ABAP_TRUE.
  GS_LAYOUT_0100-NO_ROWINS = ABAP_TRUE.
  GS_LAYOUT_0100-SEL_MODE   = 'D'.

  GS_LAYOUT_0100-SMALLTITLE = 'X'.
  CLEAR LV_TEXT1.
  CONCATENATE '플랜트 :' P_WERKS LV_NAME1 INTO LV_TEXT1 SEPARATED BY SPACE.
  LV_TEXT1 = LV_TEXT1 && ','.

  CLEAR LV_TEXT2.
  CONCATENATE 'SPG :' P_SPGCD LV_DESCR INTO LV_TEXT2 SEPARATED BY SPACE.
  LV_TEXT2 = LV_TEXT2 && ','.

  CLEAR LV_TEXT3.
  CONCATENATE '전기월 :' P_SPMON  INTO LV_TEXT3 SEPARATED BY SPACE.

  CONCATENATE LV_TEXT1 LV_TEXT2 LV_TEXT3  INTO GS_LAYOUT_0100-GRID_TITLE SEPARATED BY SPACE.


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
      I_INCLNAME             = 'ZGTPPR4120TOP'
      I_INTERNAL_TABNAME     = 'GS_MAIN_DISP'
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
      IT_DATA         = GT_MAIN_DISP
    EXCEPTIONS
      OTHERS          = 1.

  LOOP AT GT_FIELDCAT_0100 ASSIGNING FIELD-SYMBOL(<LS_FCAT>).
    CLEAR <LS_FCAT>-KEY.
    CASE   <LS_FCAT>-FIELDNAME.
      WHEN 'WERKS'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '플랜트'(f01).
        <LS_FCAT>-KEY = ABAP_TRUE.
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
        <LS_FCAT>-JUST = 'C'.
      WHEN 'GONG_CD'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '공정'(f02).
        <LS_FCAT>-KEY = ABAP_TRUE.
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
        <LS_FCAT>-JUST = 'C'.
      WHEN 'GONG_NAME'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '공정명'(f03).
        <LS_FCAT>-KEY = ABAP_TRUE.
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
        <LS_FCAT>-JUST = 'C'.
      WHEN 'AUART'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '오더유형'(f04).
        <LS_FCAT>-KEY = ABAP_TRUE.
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
        <LS_FCAT>-JUST = 'C'.
      WHEN 'AUFNR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '생산오더'(f05).
        <LS_FCAT>-KEY = ABAP_TRUE.
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
        <LS_FCAT>-JUST = 'C'.
      WHEN 'MATNR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '자재코드'(f06).
        <LS_FCAT>-JUST = 'C'.
      WHEN 'MAKTX'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '자재명'(f07).
        <LS_FCAT>-JUST = 'L'.
      WHEN 'COLOR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '색상'(f08).
        <LS_FCAT>-JUST = 'C'.
      WHEN 'ARBPL'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '작업설비코드'(f09).
        <LS_FCAT>-JUST = 'C'.
        <LS_FCAT>-NO_OUT = ABAP_TRUE.
      WHEN 'KTEXT'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '작업설비'(f10).
        <LS_FCAT>-JUST = 'L'.
      WHEN 'GAMNG'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '오더수량'(f11).
        <LS_FCAT>-JUST = 'R'.
        <LS_FCAT>-QFIELDNAME = 'GMEIN'.
      WHEN 'GMEIN'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '단위'(f12).
        <LS_FCAT>-JUST = 'C'.
      WHEN 'SBUDAT'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '최초전기일'(f13).
        <LS_FCAT>-JUST = 'C'.
      WHEN 'EBUDAT'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '최종전기일'(f14).
        <LS_FCAT>-JUST = 'C'.
      WHEN 'STATUS_01'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '확정'(f15).
        <LS_FCAT>-JUST = 'C'.
        <LS_FCAT>-ICON = ABAP_TRUE.
      WHEN 'STATUS_02'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '확정취소'(f16).
        <LS_FCAT>-JUST = 'C'.
        <LS_FCAT>-ICON = ABAP_TRUE.
      WHEN 'STATUS_03'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '투입'(f17).
        <LS_FCAT>-JUST = 'C'.
        <LS_FCAT>-ICON = ABAP_TRUE.
      WHEN 'STATUS_04'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '투입취소'(f18).
        <LS_FCAT>-JUST = 'C'.
        <LS_FCAT>-ICON = ABAP_TRUE.
      WHEN 'STATUS_05'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '입고'(f19).
        <LS_FCAT>-JUST = 'C'.
        <LS_FCAT>-ICON = ABAP_TRUE.
      WHEN 'STATUS_06'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '입고취소'(f20).
        <LS_FCAT>-JUST = 'C'.
        <LS_FCAT>-ICON = ABAP_TRUE.
      WHEN 'STATUS'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '처리상태'(f21).
        <LS_FCAT>-JUST = 'C'.
        <LS_FCAT>-ICON = ABAP_TRUE.
      WHEN 'MESSAGE'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '처리 메시지'(f22).
        <LS_FCAT>-JUST = 'L'.

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

  REFRESH GT_EXCLUDE_0100.

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
*& Form ADD_EXCLUDE_TOOLBAR_BUTTON
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_EXCLUDE_0100
*&      --> CL_GUI_ALV_GRID=>MC_FC_LOC_UND
*&---------------------------------------------------------------------*
FORM ADD_EXCLUDE_TOOLBAR_BUTTON  TABLES   P_TABLE
                                 USING    P_VALUE.
  DATA: L_EXCLUDE TYPE UI_FUNC.
  L_EXCLUDE = P_VALUE.
  APPEND L_EXCLUDE TO P_TABLE.

ENDFORM.
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
      IT_OUTTAB            = GT_MAIN_DISP
      IT_FIELDCATALOG      = GT_FIELDCAT_0100.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROC_WIP
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PROC_WIP .

  DATA : LT_ROWS TYPE LVC_T_ROW.
  DATA : LT_MOSU LIKE TABLE OF GS_MAIN_DISP.
  DATA : LT_HISTORY_MSG LIKE TABLE OF GS_MAIN_DISP.
  DATA : LT_CHG_4150 TYPE TABLE OF ZGTPPT4150.

  DATA : LT_CHG_4151 TYPE TABLE OF ZGTPPT4151.
  DATA : LT_TMP_4151 TYPE TABLE OF ZGTPPT4151.
  DATA : LT_CHG_4152 TYPE TABLE OF ZGTPPT4152.
  DATA : LT_TMP_4152 TYPE TABLE OF ZGTPPT4152.
  DATA : LV_SUC_CNT TYPE I.

  GO_GRID_0100->GET_SELECTED_ROWS(
    IMPORTING
      ET_INDEX_ROWS =  LT_ROWS  ).              " Indexes of Selected Rows

  DELETE LT_ROWS WHERE INDEX = 0.

  IF LT_ROWS IS INITIAL.
    MESSAGE S006 DISPLAY LIKE 'E' WITH '선택된 열이 없습니다.'(M01).
    RETURN.
  ENDIF.

  LT_HISTORY_MSG = GT_MAIN_DISP.
  DELETE LT_HISTORY_MSG WHERE MESSAGE IS INITIAL.

  LOOP AT LT_ROWS INTO DATA(LS_ROW).
    READ TABLE GT_MAIN_DISP ASSIGNING FIELD-SYMBOL(<LS_MAIN>) INDEX LS_ROW-INDEX.

    CASE ICON_LED_GREEN.
      WHEN <LS_MAIN>-STATUS_01 OR <LS_MAIN>-STATUS_03 OR <LS_MAIN>-STATUS_05.
        APPEND <LS_MAIN> TO LT_MOSU.
      WHEN  OTHERS.
        <LS_MAIN>-MESSAGE = 'WIP 실적취소 가능한 오더가 선택되지 않았습니다.'(M02).
    ENDCASE.

  ENDLOOP.

  IF LT_MOSU IS INITIAL.
    PERFORM REFRESH_GRID USING GO_GRID_0100.
    MESSAGE S006 DISPLAY LIKE 'E' WITH 'WIP 실적취소 가능한 오더가 선택되지 않았습니다.'(M03).
    RETURN.
  ENDIF.

  CLEAR GV_ANSWER.
  PERFORM POPUP_TO_CONFIRM_STEP USING 'N'
    ' '
    'WIP 실적취소 진행합니다. 진행하시겠습니까?'(M04)
    '진행확인'(M05).
  IF GV_ANSWER = 'J'.
  ELSE.
    MESSAGE S000 WITH '작업이 취소 되었습니다.'(M06).
    RETURN.
  ENDIF.

  LOOP AT LT_MOSU ASSIGNING FIELD-SYMBOL(<LS_MOSU>).
    CLEAR <LS_MOSU>-MESSAGE.

    READ TABLE GT_4150 TRANSPORTING NO FIELDS WITH KEY AUFNR = <LS_MOSU>-AUFNR.
    IF SY-SUBRC NE 0.
      APPEND INITIAL LINE TO LT_CHG_4150 ASSIGNING FIELD-SYMBOL(<LS_CHG_4150>).
      <LS_CHG_4150>-WERKS = P_WERKS.
      <LS_CHG_4150>-AUFNR = <LS_MOSU>-AUFNR.
      <LS_CHG_4150>-WIPST = 'W'.
    ENDIF.

*   실적 취소처리
    REFRESH LT_TMP_4151.
    IF <LS_MOSU>-STATUS_01 = ICON_LED_GREEN.
      PERFORM PROC_CONF TABLES LT_TMP_4151 CHANGING <LS_MOSU>.
    ENDIF.

    IF LT_TMP_4151[] IS NOT INITIAL.
      APPEND LINES OF LT_TMP_4151 TO LT_CHG_4151.
    ENDIF.

    CHECK <LS_MOSU>-MESSAGE IS INITIAL.

    REFRESH LT_TMP_4152.
*   투입 취소처리
    IF <LS_MOSU>-STATUS_03 = ICON_LED_GREEN.
      PERFORM PROC_GI TABLES LT_TMP_4152 CHANGING <LS_MOSU>.
    ENDIF.

    IF LT_TMP_4152[] IS NOT INITIAL.
      APPEND LINES OF LT_TMP_4152 TO LT_CHG_4152.
    ENDIF.

    CHECK <LS_MOSU>-MESSAGE IS INITIAL.

*   입고 취소처리
    REFRESH LT_TMP_4152.

    IF <LS_MOSU>-STATUS_05 = ICON_LED_GREEN.
      PERFORM PROC_GR TABLES LT_TMP_4152 CHANGING <LS_MOSU>.
    ENDIF.

    IF LT_TMP_4152[] IS NOT INITIAL.
      APPEND LINES OF LT_TMP_4152 TO LT_CHG_4152.
    ENDIF.

    CHECK <LS_MOSU>-MESSAGE IS INITIAL.

    <LS_MOSU>-STATUS = ICON_LED_GREEN.
    <LS_MOSU>-MESSAGE = 'WIP 실적취소 완료되었습니다.'.
    ADD 1 TO LV_SUC_CNT.

  ENDLOOP.

  IF LT_CHG_4150 IS NOT INITIAL.
    MODIFY ZGTPPT4150 FROM TABLE LT_CHG_4150.
    IF SY-SUBRC EQ 0.
      COMMIT WORK AND WAIT.
    ENDIF.
  ENDIF.

  IF LT_CHG_4151 IS NOT INITIAL.
    MODIFY ZGTPPT4151 FROM TABLE LT_CHG_4151.
    IF SY-SUBRC EQ 0.
      COMMIT WORK AND WAIT.
    ENDIF.
  ENDIF.

  IF LT_CHG_4152 IS NOT INITIAL.
    MODIFY ZGTPPT4152 FROM TABLE LT_CHG_4152.
    IF SY-SUBRC EQ 0.
      COMMIT WORK AND WAIT.
    ENDIF.
  ENDIF.

  PERFORM PROC_GET_DATA.
* 메시지처리 동기화
  LOOP AT GT_MAIN_DISP ASSIGNING <LS_MAIN>.
    READ TABLE LT_MOSU INTO DATA(LS_MODI) WITH KEY AUFNR = <LS_MAIN>-AUFNR.
    IF SY-SUBRC EQ 0.
      <LS_MAIN>-STATUS = LS_MODI-STATUS.
      <LS_MAIN>-MESSAGE = LS_MODI-MESSAGE.
      CONTINUE.
    ENDIF.

    READ TABLE LT_HISTORY_MSG INTO LS_MODI WITH KEY AUFNR = <LS_MAIN>-AUFNR.
    IF SY-SUBRC EQ 0.
      <LS_MAIN>-STATUS = LS_MODI-STATUS.
      <LS_MAIN>-MESSAGE = LS_MODI-MESSAGE.
      CONTINUE.
    ENDIF.
  ENDLOOP.

  PERFORM REFRESH_GRID USING GO_GRID_0100.
  DATA : LV_CNT TYPE I.
  DATA : LV_INT_C(12).
  DATA : LV_INT_C2(12).
  DATA : LV_MESSAGE(100).

  LV_CNT = LINES( LT_MOSU ).
  LV_INT_C = LV_CNT.
  CONDENSE LV_INT_C.

  LV_INT_C2 = LV_SUC_CNT.
  CONDENSE LV_INT_C2.

  CLEAR LV_MESSAGE.
  LV_MESSAGE = |총 { LV_INT_C } 건 중 성공 { LV_INT_C2 } 건 처리되었습니다.|.

  MESSAGE S006 WITH LV_MESSAGE.


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
*& Form PROC_CONF
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LT_TMP_4151
*&      <-- <LS_MOSU>
*&---------------------------------------------------------------------*
FORM PROC_CONF  TABLES   PT_4151 STRUCTURE ZGTPPT4151
                CHANGING PS_MOSU LIKE GS_MAIN_DISP.

  DATA : LT_AFRU LIKE GT_AFRU.
  DATA : LS_4151 TYPE ZGTPPT4151.
  DATA : LV_CHK_ERR.

  LT_AFRU = VALUE #( FOR LW_AFRU IN GT_AFRU WHERE ( AUFNR = PS_MOSU-AUFNR
                                              AND   BUDAT IN GT_BUDAT )
                   ( CORRESPONDING #( LW_AFRU ) ) ).

  SORT LT_AFRU BY RUECK DESCENDING
                  RMZHL DESCENDING. " 역순으로 실적 재생성

  LOOP AT LT_AFRU INTO DATA(LS_AFRU).
    CLEAR LV_CHK_ERR.
    PERFORM CHECK_PRODORDCONF_LOCK USING 'C' CHANGING PS_MOSU LV_CHK_ERR.
    IF LV_CHK_ERR = 'E'.
      RETURN.
    ENDIF.

    CLEAR LS_4151.
    LS_4151-WERKS = PS_MOSU-WERKS.
    LS_4151-AUFNR = PS_MOSU-AUFNR.
    CLEAR LV_CHK_ERR.
    PERFORM BAPI_PRODORDCONF_CANCEL CHANGING PS_MOSU LS_AFRU LS_4151 LV_CHK_ERR.
    IF LV_CHK_ERR = 'E'.
      PS_MOSU-STATUS = ICON_LED_RED.
      PS_MOSU-MESSAGE = '확정 취소 문서를 찾을 수 없습니다.'(m09).
      LV_CHK_ERR = ABAP_TRUE.
      RETURN.
    ENDIF.

    APPEND LS_4151 TO PT_4151.

    WAIT UP TO 2 SECONDS.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_PRODORDCONF_LOCK
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- PS_MOSU
*&      <-- LV_CHK_ERR
*&---------------------------------------------------------------------*
FORM CHECK_PRODORDCONF_LOCK  USING PV_GUBUN
                          CHANGING PS_MOSU LIKE GS_MAIN_DISP
                                   PV_CHK_ERR.

  DATA : LT_ENQ    TYPE SEQG3  OCCURS 0 WITH HEADER LINE.
  DATA : LV_GARG      TYPE  SEQG3-GARG,
         LV_GARG_MAT  TYPE  SEQG3-GARG,
         LV_GARG_RESB TYPE  SEQG3-GARG,
         LV_NUMBER    TYPE  SY-TABIX,
         LV_SUBRC     TYPE  SY-SUBRC.

  DATA : LV_RSNUM TYPE RSNUM.

  DATA : LV_MESSAGE(220).

  CONCATENATE SY-MANDT PS_MOSU-AUFNR
         INTO LV_GARG.


  CONCATENATE SY-MANDT  PS_MOSU-MATNR                       "250926 추가
         INTO LV_GARG_MAT.

  LV_GARG_MAT+43(4) = PS_MOSU-WERKS.

  SELECT SINGLE RSNUM FROM RESB
    INTO LV_RSNUM
   WHERE AUFNR = PS_MOSU-AUFNR.

  CONCATENATE SY-MANDT LV_RSNUM
           INTO LV_GARG_RESB.

  DO 50 TIMES.

    CALL FUNCTION 'ENQUEUE_READ'
      EXPORTING
        GCLIENT               = SY-MANDT
        GNAME                 = 'AUFK'  "AUFK
        GARG                  = LV_GARG "CLIENT 번호 + 현재 오더번호
      IMPORTING
        NUMBER                = LV_NUMBER
        SUBRC                 = LV_SUBRC
      TABLES
        ENQ                   = LT_ENQ  "값이 있으면 현재 오더 누가 잡고 있다 .WHILE ENQ 있으면 0.1
      EXCEPTIONS
        COMMUNICATION_FAILURE = 1
        SYSTEM_FAILURE        = 2
        OTHERS                = 3.

    IF LT_ENQ[] IS INITIAL.
      CLEAR PS_MOSU-MESSAGE.
      PV_CHK_ERR = 'S'.
    ELSE.
      READ TABLE LT_ENQ INTO DATA(LS_ENQ) INDEX 1.
      PV_CHK_ERR = 'E'.
      PS_MOSU-STATUS = ICON_LED_RED.
      PS_MOSU-MESSAGE = |오더번호 { PS_MOSU-AUFNR } { LS_ENQ-GUNAME }이 처리중입니다|.
      WAIT UP TO '0.1' SECONDS.
    ENDIF.

    IF PV_CHK_ERR = 'S'.

      CALL FUNCTION 'ENQUEUE_READ'
        EXPORTING
          GCLIENT               = SY-MANDT
          GNAME                 = 'MARC'  "MARA
          GARG                  = LV_GARG_MAT
        IMPORTING
          NUMBER                = LV_NUMBER
          SUBRC                 = LV_SUBRC
        TABLES
          ENQ                   = LT_ENQ  "값이 있으면 현재 자재 누가 잡고 있다 .WHILE ENQ 있으면 0.1
        EXCEPTIONS
          COMMUNICATION_FAILURE = 1
          SYSTEM_FAILURE        = 2
          OTHERS                = 3.

      IF LT_ENQ[] IS INITIAL.
        CLEAR PS_MOSU-MESSAGE.
        PV_CHK_ERR = 'S'.
      ELSE.
        READ TABLE LT_ENQ INTO LS_ENQ INDEX 1.
        PV_CHK_ERR = 'X'.
        PS_MOSU-STATUS = ICON_LED_RED.
        PS_MOSU-MESSAGE = |자재번호 { PS_MOSU-MATNR } { LS_ENQ-GUNAME }이 처리중입니다|.
        WAIT UP TO '0.1' SECONDS.
      ENDIF.

    ENDIF.

    IF PV_CHK_ERR = 'S' AND PV_GUBUN = 'P' AND LV_GARG_RESB IS NOT INITIAL.

      CALL FUNCTION 'ENQUEUE_READ'
        EXPORTING
          GCLIENT               = SY-MANDT
          GNAME                 = 'RKPF'  "MARA
          GARG                  = LV_GARG_RESB
        IMPORTING
          NUMBER                = LV_NUMBER
          SUBRC                 = LV_SUBRC
        TABLES
          ENQ                   = LT_ENQ  "값이 있으면 현재 자재 누가 잡고 있다 .WHILE ENQ 있으면 0.1
        EXCEPTIONS
          COMMUNICATION_FAILURE = 1
          SYSTEM_FAILURE        = 2
          OTHERS                = 3.

      IF LT_ENQ[] IS INITIAL.
        CLEAR PS_MOSU-MESSAGE.
        PV_CHK_ERR = 'S'.
      ELSE.
        READ TABLE LT_ENQ INTO LS_ENQ INDEX 1.
        PV_CHK_ERR = 'X'.
        PS_MOSU-STATUS = ICON_LED_RED.
        PS_MOSU-MESSAGE = |예약번호 { LV_RSNUM } { LS_ENQ-GUNAME }이 처리중입니다|.
        WAIT UP TO '0.2' SECONDS.
      ENDIF.

    ENDIF.

    IF PV_CHK_ERR = 'S'.
      EXIT.
    ENDIF.

  ENDDO.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form BAPI_PRODORDCONF_CANCEL
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- PS_MOSU
*&      <-- LS_4151
*&      <-- LV_CHK_ERR
*&---------------------------------------------------------------------*
FORM BAPI_PRODORDCONF_CANCEL  CHANGING PS_MOSU LIKE GS_MAIN_DISP
                                       PS_AFRU LIKE GS_AFRU
                                       PS_4151 TYPE ZGTPPT4151
                                       PV_CHK_ERR.

  DATA : LS_RETURN  TYPE BAPIRET1,
         LV_RUECK   TYPE BAPI_PP_CONF_KEY-CONF_NO,
         LV_RMZHL   TYPE BAPI_PP_CONF_KEY-CONF_CNT,
         LV_MESSAGE TYPE BAPIRET1-MESSAGE.

  CLEAR : LS_RETURN, LV_RUECK, LV_RMZHL, LV_MESSAGE.
  CLEAR : GV_JOB, GS_RETURN.

  CALL FUNCTION 'ZGTPP_CONF_CANCEL' STARTING NEW TASK 'CONF_CNC'
    PERFORMING RETURN_CONF_CANCEL ON END OF TASK
    EXPORTING
      CONFIRMATION        = PS_AFRU-RUECK
      CONFIRMATIONCOUNTER = PS_AFRU-RMZHL
      POSTG_DATE          = PS_AFRU-BUDAT.

  WAIT UNTIL GV_JOB = '1'.

  CASE GS_RETURN-TYPE.
    WHEN 'E'.
      PS_MOSU-STATUS = ICON_LED_RED.
      PS_MOSU-MESSAGE = GS_RETURN-MESSAGE.
    WHEN OTHERS.
      PS_4151-RUECK_R = GS_RETURN-RUECK.
      PS_4151-RMZHL_R = GS_RETURN-RMZHL.
  ENDCASE.

***- 실적 취소 펑션
**  CALL FUNCTION 'BAPI_PRODORDCONF_CANCEL'
**    EXPORTING
**      CONFIRMATION        = PS_AFRU-RUECK "확정번호
**      CONFIRMATIONCOUNTER = PS_AFRU-RMZHL "확정카운터
**      POSTG_DATE          = PS_AFRU-BUDAT
**    IMPORTING
**      RETURN              = LS_RETURN
**      CREATED_CONF_NO     = PS_4151-RUECK_R
**      CREATED_CONF_COUNT  = PS_4151-RMZHL_R.
***- 실패
**  IF PS_4151-RUECK_R IS INITIAL.
**    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
**    PV_CHK_ERR = 'E'.
**    PS_MOSU-STATUS = ICON_LED_RED.
**    PS_MOSU-MESSAGE = LS_RETURN-MESSAGE.
***- 성공
**  ELSE.
**    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
**      EXPORTING
**        WAIT = 'X'.
**
**  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROC_GI
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LT_TMP_4152
*&      <-- <LS_MOSU>
*&---------------------------------------------------------------------*
FORM PROC_GI  TABLES   PT_4152 STRUCTURE ZGTPPT4152
              CHANGING PS_MOSU LIKE GS_MAIN_DISP.

  DATA : LT_MSEG TYPE TABLE OF MSEG.
  DATA : LS_4152 TYPE ZGTPPT4152.
  DATA : LV_CHK_ERR.

  LT_MSEG = VALUE #( FOR LW_MSEG IN GT_MSEG_MOSU WHERE ( AUFNR = PS_MOSU-AUFNR
                                                   AND   BWART = '261'
                                                   AND   BUDAT_MKPF IN GT_BUDAT )
                 ( CORRESPONDING #( LW_MSEG ) ) ).

  SORT LT_MSEG BY MBLNR DESCENDING. " 역순으로 취소예정

  LOOP AT LT_MSEG INTO DATA(LS_MSEG).
    CLEAR LS_4152.
    LS_4152-WERKS = PS_MOSU-WERKS.
    LS_4152-AUFNR = PS_MOSU-AUFNR.
    LS_4152-ZGRGI = 'GI'.

    PERFORM PROC_BAPI_GOODSMVT_CANCEL CHANGING PS_MOSU LS_MSEG LS_4152 LV_CHK_ERR.
    IF LV_CHK_ERR = 'E'.
      RETURN.
    ENDIF.

    APPEND LS_4152 TO PT_4152.
  ENDLOOP.

  LT_MSEG = VALUE #( FOR LW_MSEG IN GT_MSEG_MOSU WHERE ( AUFNR = PS_MOSU-AUFNR
                                                 AND   BWART = '531'
                                                 AND   BUDAT_MKPF IN GT_BUDAT )
               ( CORRESPONDING #( LW_MSEG ) ) ).

  SORT LT_MSEG BY MBLNR DESCENDING. " 역순으로 취소예정


  LOOP AT LT_MSEG INTO DATA(LS_MSEG2).
    PERFORM PROC_BAPI_GOODSMVT_CANCEL CHANGING PS_MOSU LS_MSEG2 LS_4152 LV_CHK_ERR.
    IF LV_CHK_ERR = 'E'.
      RETURN.
    ENDIF.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROC_BAPI_GOODSMVT_CANCEL
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- PS_MOSU
*&      <-- LS_MSEG
*&      <-- LS_4152
*&      <-- LV_CHK_ERR
*&---------------------------------------------------------------------*
FORM PROC_BAPI_GOODSMVT_CANCEL  CHANGING PS_MOSU LIKE GS_MAIN_DISP
                                         PS_MSEG TYPE MSEG
                                         PS_4152 TYPE ZGTPPT4152
                                         PV_CHK_ERR.

  DATA : LS_HEADRET TYPE BAPI2017_GM_HEAD_RET,
         LT_RETURN  TYPE TABLE OF BAPIRET2,
         LV_MESSAGE TYPE BAPIRET2-MESSAGE.

  DATA : LT_MATDOCITEM TYPE TABLE OF BAPI2017_GM_ITEM_04 WITH HEADER LINE.

  DATA : LV_HD_TEXT TYPE BAPI2017_GM_HEAD_02-HEADER_TXT.
  IF PS_4152-ZGRGI = 'GI'.
    LV_HD_TEXT = |WIP오더투입취소({ SY-TCODE })|.
  ELSE.
    LV_HD_TEXT = |WIP오더입고취소({ SY-TCODE })|.
  ENDIF.

  CLEAR: LT_MATDOCITEM, LT_MATDOCITEM[].
  LT_MATDOCITEM-MATDOC_ITEM = PS_MSEG-ZEILE.
  APPEND LT_MATDOCITEM TO LT_MATDOCITEM.

  CLEAR : GV_JOB, GS_RETURN.

  CALL FUNCTION 'ZGTPP_GOODSMVT_CANCEL' STARTING NEW TASK 'GOODSMVT_CANCEL'
    PERFORMING RETURN_GOODSMVT_CANCEL ON END OF TASK
    EXPORTING
      MATERIALDOCUMENT    = PS_MSEG-MBLNR
      MATDOCUMENTYEAR     = PS_MSEG-MJAHR
      GOODSMVT_PSTNG_DATE = PS_MSEG-BUDAT_MKPF
      GOODSMVT_PR_UNAME   = SY-UNAME
      DOCUMENTHEADER_TEXT = LV_HD_TEXT
    TABLES
      GOODSMVT_MATDOCITEM = LT_MATDOCITEM.

  WAIT UNTIL GV_JOB = '1'.

  CASE GS_RETURN-TYPE.
    WHEN 'E'.
      PS_MOSU-STATUS = ICON_LED_RED.
      PS_MOSU-MESSAGE = GS_RETURN-MESSAGE.
    WHEN OTHERS.
      PS_4152-MBLNR_R = GS_RETURN-MBLNR.
      PS_4152-MJAHR_R = GS_RETURN-MJAHR.
  ENDCASE.


*  CALL FUNCTION 'BAPI_GOODSMVT_CANCEL'
*    EXPORTING
*      MATERIALDOCUMENT    = PS_MSEG-MBLNR
*      MATDOCUMENTYEAR     = PS_MSEG-MJAHR
*      GOODSMVT_PSTNG_DATE = PS_MSEG-BUDAT_MKPF
*      GOODSMVT_PR_UNAME   = SY-UNAME
*      DOCUMENTHEADER_TEXT = LV_HD_TEXT      "2025.08.14 Edit
*    IMPORTING
*      GOODSMVT_HEADRET    = LS_HEADRET
*    TABLES
*      RETURN              = LT_RETURN
*      GOODSMVT_MATDOCITEM = LT_MATDOCITEM.
*
**- 실패
*  IF LINE_EXISTS( LT_RETURN[ TYPE = 'E' ] ).
*
*    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
*    PV_CHK_ERR = 'E'.
*    PS_MOSU-STATUS = ICON_LED_RED.
*    READ TABLE LT_RETURN INTO DATA(LS_RETURN) WITH KEY TYPE = 'E'.
*    PS_MOSU-MESSAGE = LS_RETURN-MESSAGE.
*
*  ELSE.
**- 성공
*    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
*      EXPORTING
*        WAIT = 'X'.
*    PS_4152-MBLNR_R = LS_HEADRET-MAT_DOC.
*    READ TABLE LT_MATDOCITEM INTO DATA(LS_MATDOCITEM) INDEX 1.
*    PS_4152-ZEILE_R = LS_MATDOCITEM-MATDOC_ITEM.
*    PS_4152-MJAHR_R = LS_HEADRET-DOC_YEAR.
*
*  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROC_GR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LT_TMP_4152
*&      <-- <LS_MOSU>
*&---------------------------------------------------------------------*
FORM PROC_GR  TABLES   PT_4152 STRUCTURE ZGTPPT4152
              CHANGING PS_MOSU LIKE GS_MAIN_DISP.

  DATA : LT_MSEG TYPE TABLE OF MSEG.
  DATA : LS_4152 TYPE ZGTPPT4152.
  DATA : LV_CHK_ERR.

  LT_MSEG = VALUE #( FOR LW_MSEG IN GT_MSEG_MOSU WHERE ( AUFNR = PS_MOSU-AUFNR
                                                   AND   BWART = '101'
                                                   AND   BUDAT_MKPF IN GT_BUDAT )
                 ( CORRESPONDING #( LW_MSEG ) ) ).

  SORT LT_MSEG BY MBLNR DESCENDING. " 역순으로 취소예정

  LOOP AT LT_MSEG INTO DATA(LS_MSEG).
    CLEAR LS_4152.
    LS_4152-WERKS = PS_MOSU-WERKS.
    LS_4152-AUFNR = PS_MOSU-AUFNR.
    LS_4152-ZGRGI = 'GR'.

    PERFORM PROC_BAPI_GOODSMVT_CANCEL CHANGING PS_MOSU LS_MSEG LS_4152 LV_CHK_ERR.
    IF LV_CHK_ERR = 'E'.
      RETURN.
    ENDIF.

    APPEND LS_4152 TO PT_4152.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROC_CNC_WIP
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PROC_CNC_WIP .

  DATA : LT_ROWS TYPE LVC_T_ROW.
  DATA : LT_MOSU LIKE TABLE OF GS_MAIN_DISP.
  DATA : LT_HISTORY_MSG LIKE TABLE OF GS_MAIN_DISP.
  DATA : LT_CHG_4150 TYPE TABLE OF ZGTPPT4150.

  DATA : LT_CHG_4151 TYPE TABLE OF ZGTPPT4151.
  DATA : LT_TMP_4151 TYPE TABLE OF ZGTPPT4151.
  DATA : LT_CHG_4152 TYPE TABLE OF ZGTPPT4152.
  DATA : LT_TMP_4152 TYPE TABLE OF ZGTPPT4152.
  DATA : LV_SUC_CNT TYPE I.
  DATA : LV_CHK_ERR.

  GO_GRID_0100->GET_SELECTED_ROWS(
    IMPORTING
      ET_INDEX_ROWS =  LT_ROWS  ).              " Indexes of Selected Rows

  DELETE LT_ROWS WHERE INDEX = 0.

  IF LT_ROWS IS INITIAL.
    MESSAGE S006 DISPLAY LIKE 'E' WITH '선택된 열이 없습니다.'(M01).
    RETURN.
  ENDIF.

  LT_HISTORY_MSG = GT_MAIN_DISP.
  DELETE LT_HISTORY_MSG WHERE MESSAGE IS INITIAL.

  LOOP AT LT_ROWS INTO DATA(LS_ROW).
    READ TABLE GT_MAIN_DISP ASSIGNING FIELD-SYMBOL(<LS_MAIN>) INDEX LS_ROW-INDEX.

    CASE ICON_LED_GREEN.
      WHEN <LS_MAIN>-STATUS_02 OR <LS_MAIN>-STATUS_04 OR <LS_MAIN>-STATUS_06.
        APPEND <LS_MAIN> TO LT_MOSU.
      WHEN  OTHERS.

* 2026.10.02 실적 재처리시 상태값 변경 추가
        IF <LS_MAIN>-STATUS_01 = ICON_LED_INACTIVE AND
          <LS_MAIN>-STATUS_02 = ICON_LED_INACTIVE AND
          <LS_MAIN>-STATUS_03 = ICON_LED_INACTIVE AND
          <LS_MAIN>-STATUS_04 = ICON_LED_INACTIVE AND
          <LS_MAIN>-STATUS_05 = ICON_LED_INACTIVE AND
          <LS_MAIN>-STATUS_06 = ICON_LED_INACTIVE.

          APPEND INITIAL LINE TO LT_CHG_4150 ASSIGNING FIELD-SYMBOL(<LS_CHG_4150>).
          <LS_CHG_4150>-WERKS = P_WERKS.
          <LS_CHG_4150>-AUFNR = <LS_MAIN>-AUFNR.
          <LS_CHG_4150>-WIPST = 'P'.
          <LS_CHG_4150>-CONF_SPMON = P_SPMON.

          <LS_MAIN>-STATUS = ICON_LED_GREEN.
          <LS_MAIN>-MESSAGE = 'WIP 실적재처리 완료되었습니다.'.
        ELSE.
          <LS_MAIN>-MESSAGE = 'WIP 실적재처리 가능한 오더가 선택되지 않았습니다.'(M07).
        ENDIF.
    ENDCASE.

  ENDLOOP.

* 2026.10.02 실적 재처리시 상태값 변경 추가
  IF LT_CHG_4150 IS NOT INITIAL.
    MODIFY ZGTPPT4150 FROM TABLE LT_CHG_4150.
    IF SY-SUBRC EQ 0.
      COMMIT WORK AND WAIT.
    ENDIF.
  ENDIF.

  IF LT_MOSU IS INITIAL.
    PERFORM REFRESH_GRID USING GO_GRID_0100.
    MESSAGE S006 DISPLAY LIKE 'E' WITH 'WIP 실적재처리 가능한 오더가 선택되지 않았습니다.'(M07).
    RETURN.
  ENDIF.

  REFRESH LT_CHG_4150.

* 현재 데이터 생성될 budat 입력을 받아온다.
  CLEAR GV_ANSWER.
  PERFORM GET_BUDAT_POPUP.

  CHECK GV_ANSWER = ABAP_TRUE.

  LOOP AT LT_MOSU ASSIGNING FIELD-SYMBOL(<LS_MOSU>).

    CLEAR <LS_MOSU>-MESSAGE.
    CLEAR LV_CHK_ERR.

*   실적 재처리
    REFRESH LT_TMP_4151.
    IF <LS_MOSU>-STATUS_02 = ICON_LED_GREEN.
      LOOP AT GT_4151 INTO DATA(LS_4151) WHERE AUFNR = <LS_MOSU>-AUFNR.
        IF LS_4151-RUECK_P IS INITIAL.
          APPEND LS_4151 TO LT_TMP_4151.
        ENDIF.
      ENDLOOP.
      PERFORM PROC_REGENERATE_CONF TABLES LT_TMP_4151
                                 CHANGING <LS_MOSU> LV_CHK_ERR.
    ENDIF.

    IF LT_TMP_4151[] IS NOT INITIAL.
      APPEND LINES OF LT_TMP_4151 TO LT_CHG_4151.
    ENDIF.

    CHECK <LS_MOSU>-MESSAGE IS INITIAL.

    PERFORM CHECK_PRODORDCONF_LOCK USING 'P' CHANGING <LS_MOSU> LV_CHK_ERR.

    CHECK <LS_MOSU>-MESSAGE IS INITIAL.

    REFRESH LT_TMP_4152.
*   투입 취소처리
    IF <LS_MOSU>-STATUS_04 = ICON_LED_GREEN.
      LOOP AT GT_4152 INTO DATA(LS_4152) WHERE AUFNR = <LS_MOSU>-AUFNR
                                           AND ZGRGI = 'GI'.                          .
        IF LS_4152-MBLNR_P IS INITIAL.
          APPEND LS_4152 TO LT_TMP_4152.
        ENDIF.
      ENDLOOP.

      PERFORM PROC_POSTING TABLES LT_TMP_4152 CHANGING <LS_MOSU> LV_CHK_ERR.
    ENDIF.

    IF LT_TMP_4152[] IS NOT INITIAL.
      APPEND LINES OF LT_TMP_4152 TO LT_CHG_4152.
    ENDIF.

    CHECK <LS_MOSU>-MESSAGE IS INITIAL.

*   입고 취소처리
    REFRESH LT_TMP_4152.

    IF <LS_MOSU>-STATUS_06 = ICON_LED_GREEN.
      LOOP AT GT_4152 INTO LS_4152 WHERE AUFNR = <LS_MOSU>-AUFNR
                                           AND ZGRGI = 'GR'.                          .
        IF LS_4152-MBLNR_P IS INITIAL.
          APPEND LS_4152 TO LT_TMP_4152.
        ENDIF.
      ENDLOOP.

      PERFORM PROC_POSTING TABLES LT_TMP_4152 CHANGING <LS_MOSU> LV_CHK_ERR.
    ENDIF.

    IF LT_TMP_4152[] IS NOT INITIAL.
      APPEND LINES OF LT_TMP_4152 TO LT_CHG_4152.
    ENDIF.

    CHECK <LS_MOSU>-MESSAGE IS INITIAL.

    APPEND INITIAL LINE TO LT_CHG_4150 ASSIGNING <LS_CHG_4150>.
    <LS_CHG_4150>-WERKS = P_WERKS.
    <LS_CHG_4150>-AUFNR = <LS_MOSU>-AUFNR.
    <LS_CHG_4150>-WIPST = 'P'.
    <LS_CHG_4150>-CONF_SPMON = P_SPMON.


    <LS_MOSU>-STATUS = ICON_LED_GREEN.
    <LS_MOSU>-MESSAGE = 'WIP 실적재처리 완료되었습니다.'.
    ADD 1 TO LV_SUC_CNT.

  ENDLOOP.

  IF LT_CHG_4150 IS NOT INITIAL.
    MODIFY ZGTPPT4150 FROM TABLE LT_CHG_4150.
    IF SY-SUBRC EQ 0.
      COMMIT WORK AND WAIT.
    ENDIF.
  ENDIF.

  IF LT_CHG_4151 IS NOT INITIAL.
    MODIFY ZGTPPT4151 FROM TABLE LT_CHG_4151.
    IF SY-SUBRC EQ 0.
      COMMIT WORK AND WAIT.
    ENDIF.
  ENDIF.

  IF LT_CHG_4152 IS NOT INITIAL.
    MODIFY ZGTPPT4152 FROM TABLE LT_CHG_4152.
    IF SY-SUBRC EQ 0.
      COMMIT WORK AND WAIT.
    ENDIF.
  ENDIF.

  PERFORM PROC_GET_DATA.
* 메시지처리 동기화
  LOOP AT GT_MAIN_DISP ASSIGNING <LS_MAIN>.
    READ TABLE LT_MOSU INTO DATA(LS_MODI) WITH KEY AUFNR = <LS_MAIN>-AUFNR.
    IF SY-SUBRC EQ 0.
      <LS_MAIN>-STATUS = LS_MODI-STATUS.
      <LS_MAIN>-MESSAGE = LS_MODI-MESSAGE.
      CONTINUE.
    ENDIF.

    READ TABLE LT_HISTORY_MSG INTO LS_MODI WITH KEY AUFNR = <LS_MAIN>-AUFNR.
    IF SY-SUBRC EQ 0.
      <LS_MAIN>-STATUS = LS_MODI-STATUS.
      <LS_MAIN>-MESSAGE = LS_MODI-MESSAGE.
      CONTINUE.
    ENDIF.
  ENDLOOP.

  PERFORM REFRESH_GRID USING GO_GRID_0100.
  DATA : LV_CNT TYPE I.
  DATA : LV_INT_C(12).
  DATA : LV_INT_C2(12).
  DATA : LV_MESSAGE(100).

  LV_CNT = LINES( LT_MOSU ).
  LV_INT_C = LV_CNT.
  CONDENSE LV_INT_C.

  LV_INT_C2 = LV_SUC_CNT.
  CONDENSE LV_INT_C2.

  CLEAR LV_MESSAGE.
  LV_MESSAGE = |총 { LV_INT_C } 건 중 성공 { LV_INT_C2 } 건 처리되었습니다.|.

  MESSAGE S006 WITH LV_MESSAGE.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_BUDAT_POPUP
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_BUDAT_POPUP .

  CLEAR GV_BUDAT.

  DATA : LV_RETURN_CODE TYPE C.
  DATA : LT_FIELD TYPE TABLE OF SVAL.

  IF SY-DATUM+6(2) <= 15. " 현재 일자가 15일 이전일시 현재월 1일
    GV_BUDAT = SY-DATUM+0(6) && '01'.
  ELSE.
    GV_BUDAT = SY-DATUM. " 현재 일자가 15일 이후 다음월 1일
    PERFORM GET_LAST_DAY_OF_MONTH CHANGING GV_BUDAT.
    GV_BUDAT = GV_BUDAT + 1.
  ENDIF.

  APPEND INITIAL LINE TO LT_FIELD ASSIGNING FIELD-SYMBOL(<LS_FIELD>).
  <LS_FIELD>-FIELDTEXT = '전기일자'.
  <LS_FIELD>-TABNAME = 'AFRU'.
  <LS_FIELD>-FIELDNAME = 'BUDAT'.
  <LS_FIELD>-FIELD_OBL = ABAP_TRUE.
  <LS_FIELD>-VALUE = GV_BUDAT.
*  WRITE GV_BUDAT TO <LS_FIELD>-VALUE.

  CALL FUNCTION 'POPUP_GET_VALUES'
    EXPORTING
      POPUP_TITLE     = '전기일자 입력'
*     START_COLUMN    = '5'
*     START_ROW       = '5'
    IMPORTING
      RETURNCODE      = LV_RETURN_CODE
    TABLES
      FIELDS          = LT_FIELD
    EXCEPTIONS
      ERROR_IN_FIELDS = 1
      OTHERS          = 2.
  IF SY-SUBRC <> 0.
    RETURN.
  ENDIF.

  IF LV_RETURN_CODE = 'A'. " 취소로 종료시
    RETURN.
  ENDIF.

  GV_ANSWER = ABAP_TRUE.

  READ TABLE LT_FIELD INTO DATA(LS_FIELD) INDEX 1.
  GV_BUDAT = LS_FIELD-VALUE.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_LAST_DAY_OF_MONTH
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- GV_BUDAT
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
*& Form PROC_REGENERATE_CONF
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- LS_4171
*&      <-- <LS_MOSU>
*&      <-- LV_CHK_ERR
*&---------------------------------------------------------------------*
FORM PROC_REGENERATE_CONF TABLES PT_4151 STRUCTURE ZGTPPT4151
                        CHANGING PS_MOSU LIKE GS_MAIN_DISP
                                 PV_CHK_ERR.

  DATA : LS_AFRU TYPE AFRU.
  DATA : LT_MOSU TYPE TABLE OF ZGTPPT4151.

  SORT PT_4151 BY RUECK_R DESCENDING
                  RMZHL_R DESCENDING. " 역순으로 실적 재생성

  LOOP AT PT_4151.

    CLEAR PV_CHK_ERR.
    PERFORM CHECK_PRODORDCONF_LOCK USING 'P' CHANGING PS_MOSU PV_CHK_ERR.
    IF PV_CHK_ERR = 'E'.
      RETURN.
    ENDIF.

* 실적 재처리
    CLEAR LS_AFRU.
    SELECT SINGLE * FROM AFRU
      INTO LS_AFRU
     WHERE RUECK = PT_4151-RUECK_R
       AND RMZHL = PT_4151-RMZHL_R.
    IF SY-SUBRC EQ 0.
      CLEAR PV_CHK_ERR.
      PERFORM PRODORDCONF_CREATE USING LS_AFRU CHANGING PS_MOSU  PT_4151 PV_CHK_ERR.
      IF PV_CHK_ERR IS INITIAL.
        APPEND PT_4151 TO LT_MOSU.
        WAIT UP TO '0.5' SECONDS.
      ELSE.
        EXIT.
      ENDIF.
    ELSE.
      PS_MOSU-STATUS = ICON_LED_RED.
      PS_MOSU-MESSAGE = '확정 취소 문서를 찾을 수 없습니다.'(m09).
      PV_CHK_ERR = ABAP_TRUE.
      EXIT.
    ENDIF.
  ENDLOOP.

  REFRESH PT_4151[].
  IF LT_MOSU[] IS NOT INITIAL.
    MOVE-CORRESPONDING LT_MOSU TO PT_4151[].
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PRODORDCONF_CREATE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LS_AFRU
*&      --> PS_MOSU
*&      <-- PV_CHK_ERR
*&---------------------------------------------------------------------*
FORM PRODORDCONF_CREATE  USING    PS_AFRU TYPE AFRU
                         CHANGING PS_MOSU LIKE GS_MAIN_DISP
                                  PS_4151 TYPE ZGTPPT4151
                                  PV_CHK_ERR.

  DATA : LT_TIMETICKETS TYPE TABLE OF BAPI_PP_TIMETICKET.
  DATA : LT_DETAIL_RETURN TYPE TABLE OF BAPI_CORU_RETURN.
  DATA : LS_RETURN TYPE BAPIRETURN1.

  APPEND INITIAL LINE TO LT_TIMETICKETS ASSIGNING FIELD-SYMBOL(<LS_TIMETICKETS>).
  <LS_TIMETICKETS>-ORDERID          = PS_MOSU-AUFNR.
  <LS_TIMETICKETS>-OPERATION      = PS_AFRU-VORNR.
  <LS_TIMETICKETS>-FIN_CONF       = PS_AFRU-AUERU.
  <LS_TIMETICKETS>-CLEAR_RES      = PS_AFRU-AUSOR.
  <LS_TIMETICKETS>-POSTG_DATE     = GV_BUDAT.
  <LS_TIMETICKETS>-DEV_REASON       = PS_AFRU-GRUND.
  <LS_TIMETICKETS>-PLANT                = PS_AFRU-WERKS.
  <LS_TIMETICKETS>-WORK_CNTR        = PS_MOSU-ARBPL.
  <LS_TIMETICKETS>-YIELD                  = PS_AFRU-LMNGA.
  <LS_TIMETICKETS>-SCRAP                 = PS_AFRU-XMNGA.
  <LS_TIMETICKETS>-REWORK               = PS_AFRU-RMNGA.
  <LS_TIMETICKETS>-CONF_TEXT           = PS_AFRU-LTXA1.
  <LS_TIMETICKETS>-CONF_ACTIVITY1   = PS_AFRU-ISM01 .
  <LS_TIMETICKETS>-CONF_ACTI_UNIT1 = PS_AFRU-ILE01.
  <LS_TIMETICKETS>-CONF_ACTIVITY2   = PS_AFRU-ISM02.
  <LS_TIMETICKETS>-CONF_ACTI_UNIT2  = PS_AFRU-ILE02.
  <LS_TIMETICKETS>-CONF_ACTIVITY3   = PS_AFRU-ISM03.
  <LS_TIMETICKETS>-CONF_ACTI_UNIT3 = PS_AFRU-ILE03.
  <LS_TIMETICKETS>-CONF_ACTIVITY4   = PS_AFRU-ISM04.
  <LS_TIMETICKETS>-CONF_ACTI_UNIT4  = PS_AFRU-ILE04.
  <LS_TIMETICKETS>-CONF_ACTIVITY5   = PS_AFRU-ISM05.
  <LS_TIMETICKETS>-CONF_ACTI_UNIT5 = PS_AFRU-ILE05.
  <LS_TIMETICKETS>-CONF_ACTIVITY6   = PS_AFRU-ISM06.
  <LS_TIMETICKETS>-CONF_ACTI_UNIT6 = PS_AFRU-ILE06.
  <LS_TIMETICKETS>-EXEC_START_DATE = PS_AFRU-ISDD.
  <LS_TIMETICKETS>-EXEC_START_TIME = PS_AFRU-ISDZ.
  <LS_TIMETICKETS>-PROC_FIN_DATE   = PS_AFRU-IEBD.
  <LS_TIMETICKETS>-PROC_FIN_TIME    = PS_AFRU-IEBZ.
  <LS_TIMETICKETS>-EX_IDENT             = PS_AFRU-EXTID .
  <LS_TIMETICKETS>-PERS_NO             = PS_AFRU-PERNR .

  CLEAR : GV_JOB, GS_RETURN.

  CALL FUNCTION 'ZGTPP_CONF_CREATE_TT' STARTING NEW TASK 'CREATE_TT'
    PERFORMING RETURN_CONF_CREATE_TT ON END OF TASK
    TABLES
      TIMETICKETS = LT_TIMETICKETS.

  WAIT UNTIL GV_JOB = '1'.

  CASE GS_RETURN-TYPE.
    WHEN 'E'.
      PV_CHK_ERR = 'X'.
      PS_MOSU-STATUS = ICON_LED_RED.
      PS_MOSU-MESSAGE = GS_RETURN-MESSAGE.
    WHEN OTHERS.
      PS_4151-RUECK_P = GS_RETURN-RUECK.
      PS_4151-RMZHL_P = GS_RETURN-RMZHL.
  ENDCASE.


*  CALL FUNCTION 'BAPI_PRODORDCONF_CREATE_TT'
*    EXPORTING
**     POST_WRONG_ENTRIES = '1'
*      TESTRUN       = ''
*    IMPORTING
*      RETURN        = LS_RETURN
*    TABLES
*      TIMETICKETS   = LT_TIMETICKETS
*      DETAIL_RETURN = LT_DETAIL_RETURN.
*
*  READ TABLE LT_DETAIL_RETURN INTO DATA(LS_DETAIL_RETURN) WITH KEY ID = 'RU'
*                                                                   NUMBER = '100'.
*  IF SY-SUBRC = 0.
*    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
*      EXPORTING
*        WAIT = 'X'.
*
*    PS_4151-RUECK_P = LS_DETAIL_RETURN-CONF_NO.
*    PS_4151-RMZHL_P = LS_DETAIL_RETURN-CONF_CNT.
*
*  ELSE.
*    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
*
*    PV_CHK_ERR = 'X'.
*
*    READ TABLE LT_DETAIL_RETURN INTO LS_DETAIL_RETURN WITH KEY TYPE = 'E'.
*
*    MESSAGE ID     LS_DETAIL_RETURN-ID
*            TYPE   'S'
*            NUMBER LS_DETAIL_RETURN-NUMBER
*            WITH   LS_DETAIL_RETURN-MESSAGE_V1
*                   LS_DETAIL_RETURN-MESSAGE_V2
*                   LS_DETAIL_RETURN-MESSAGE_V3
*                   LS_DETAIL_RETURN-MESSAGE_V4
*           INTO PS_MOSU-MESSAGE.
*    PS_MOSU-STATUS = ICON_LED_RED.
*  ENDIF.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROC_POSTING
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LT_TMP_4152
*&      <-- <LS_MOSU>
*&      <-- LV_CHK_ERR
*&---------------------------------------------------------------------*
FORM PROC_POSTING  TABLES   PT_4152 STRUCTURE ZGTPPT4152
                      CHANGING PS_MOSU LIKE GS_MAIN_DISP
                               PV_CHK_ERR.

  DATA : LT_MOSU TYPE TABLE OF ZGTPPT4152.
  DATA : LS_MSEG TYPE MSEG.

  SORT PT_4152 BY MBLNR_R DESCENDING.

  LOOP AT PT_4152.

    SELECT SINGLE * FROM MSEG
      INTO LS_MSEG
     WHERE MBLNR = PT_4152-MBLNR_R
       AND MJAHR = PT_4152-MJAHR_R.
*       AND ZEILE = PT_4152-ZEILE_R.

    IF SY-SUBRC EQ 0.
      CLEAR PV_CHK_ERR.
      IF PT_4152-ZGRGI = 'GI'.
        PERFORM BAPI_GOODSMVT_CREATE_GI USING LS_MSEG CHANGING PT_4152 PS_MOSU PV_CHK_ERR.
      ELSE.
        PERFORM BAPI_GOODSMVT_CREATE_GR USING LS_MSEG CHANGING PT_4152 PS_MOSU PV_CHK_ERR.
      ENDIF.

      IF PV_CHK_ERR IS INITIAL.
        APPEND PT_4152 TO LT_MOSU.
        WAIT UP TO 1 SECONDS.
      ELSE.
        EXIT.
      ENDIF.

    ELSE.
      PS_MOSU-STATUS = ICON_LED_RED.
      IF PT_4152-ZGRGI = 'GI'.
        PS_MOSU-MESSAGE = '투입 취소 문서를 찾을 수 없습니다.'(m10).
      ELSE.
        PS_MOSU-MESSAGE = '입고 취소 문서를 찾을 수 없습니다.'(m11).
      ENDIF.
      PV_CHK_ERR = ABAP_TRUE.
      EXIT.
    ENDIF.

  ENDLOOP.

  REFRESH PT_4152[].

  IF LT_MOSU[] IS NOT INITIAL.
    MOVE-CORRESPONDING LT_MOSU TO PT_4152[].
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form BAPI_GOODSMVT_CREATE_GI
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LS_MSEG
*&      <-- PT_4152
*&      <-- PS_MOSU
*&      <-- PV_CHK_ERR
*&---------------------------------------------------------------------*
FORM BAPI_GOODSMVT_CREATE_GI  USING    PS_MSEG TYPE MSEG
                              CHANGING PS_4152 TYPE ZGTPPT4152
                                       PS_MOSU LIKE GS_MAIN_DISP
                                       PV_CHK_ERR.

  DATA : LS_HEADER TYPE BAPI2017_GM_HEAD_01.
  DATA : LT_ITEM  TYPE TABLE OF BAPI2017_GM_ITEM_CREATE.
  DATA : LT_RETURN TYPE TABLE OF BAPIRET2.
  DATA : LS_GMHEADRET LIKE BAPI2017_GM_HEAD_RET.
  DATA : LT_ITEM_NO TYPE TABLE OF BAPI2017_GM_SERIALNUMBER.

* 헤더구성
  LS_HEADER-PSTNG_DATE = GV_BUDAT.
  LS_HEADER-DOC_DATE = GV_BUDAT.
  LS_HEADER-PR_UNAME = SY-UNAME.
  LS_HEADER-HEADER_TXT = |WIP오더투입재처리({ SY-TCODE })|.
* 아이템 구성
  APPEND INITIAL LINE TO LT_ITEM ASSIGNING FIELD-SYMBOL(<LS_ITEM>).
  <LS_ITEM>-MATERIAL = PS_MSEG-MATNR.
  <LS_ITEM>-PLANT = PS_MSEG-WERKS.
  <LS_ITEM>-STGE_LOC = PS_MSEG-LGORT.
  <LS_ITEM>-BATCH = PS_MSEG-CHARG.
  <LS_ITEM>-MOVE_TYPE = '261'.
  <LS_ITEM>-STCK_TYPE = PS_MSEG-INSMK.
  <LS_ITEM>-ENTRY_QNT = PS_MSEG-ERFMG.
  <LS_ITEM>-ENTRY_UOM = PS_MSEG-ERFME.
  <LS_ITEM>-ORDERID = PS_MSEG-AUFNR.
  <LS_ITEM>-RESERV_NO = PS_MSEG-RSNUM.
  <LS_ITEM>-RES_ITEM = PS_MSEG-RSPOS.
  <LS_ITEM>-SPEC_STOCK = PS_MSEG-SOBKZ.
  <LS_ITEM>-VAL_SALES_ORD = PS_MSEG-MAT_KDAUF.
  <LS_ITEM>-VAL_S_ORD_ITEM = PS_MSEG-MAT_KDPOS.


  CLEAR : GV_JOB, GS_RETURN.

  CALL FUNCTION 'ZGTPP_GOODSMVT_CREATE' STARTING NEW TASK 'GOODSMVT_CREATE'
    PERFORMING RETURN_GOODSMVT_CREATE ON END OF TASK
    EXPORTING
      GOODSMVT_HEADER = LS_HEADER
      GOODSMVT_CODE   = '03'
    TABLES
      GOODSMVT_ITEM   = LT_ITEM.

  WAIT UNTIL GV_JOB = '1'.

  CASE GS_RETURN-TYPE.
    WHEN 'E'.
      PV_CHK_ERR = 'E'.
      PS_MOSU-STATUS = ICON_LED_RED.
      PS_MOSU-MESSAGE = GS_RETURN-MESSAGE.
    WHEN OTHERS.
      PS_4152-MBLNR_P = GS_RETURN-MBLNR.
      PS_4152-MJAHR_P = GS_RETURN-MJAHR.
  ENDCASE.

*  CALL FUNCTION 'BAPI_GOODSMVT_CREATE'
*    EXPORTING
*      GOODSMVT_HEADER       = LS_HEADER
*      GOODSMVT_CODE         = '03'
*    IMPORTING
*      GOODSMVT_HEADRET      = LS_GMHEADRET
*    TABLES
*      GOODSMVT_ITEM         = LT_ITEM
*      RETURN                = LT_RETURN
*      GOODSMVT_SERIALNUMBER = LT_ITEM_NO.
*
*  IF LS_GMHEADRET IS INITIAL.
*    PV_CHK_ERR = 'E'.
*    PS_MOSU-STATUS = ICON_LED_RED.
*    READ TABLE LT_RETURN INTO DATA(LS_RETURN) WITH KEY TYPE = 'E'.
*    PS_MOSU-MESSAGE = LS_RETURN-MESSAGE.
*
*  ELSE.
**- 성공
*    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
*      EXPORTING
*        WAIT = 'X'.
*    PS_4152-MBLNR_P = LS_GMHEADRET-MAT_DOC.
*    READ TABLE LT_ITEM_NO INTO DATA(LS_MATDOCITEM) INDEX 1.
*    PS_4152-ZEILE_P = LS_MATDOCITEM-MATDOC_ITM.
*    PS_4152-MJAHR_P = LS_GMHEADRET-DOC_YEAR.
*
*  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form BAPI_GOODSMVT_CREATE_Gr
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LS_MSEG
*&      <-- PT_4152
*&      <-- PS_MOSU
*&      <-- PV_CHK_ERR
*&---------------------------------------------------------------------*
FORM BAPI_GOODSMVT_CREATE_GR  USING    PS_MSEG TYPE MSEG
                              CHANGING PS_4152 TYPE ZGTPPT4152
                                       PS_MOSU LIKE GS_MAIN_DISP
                                       PV_CHK_ERR.

  DATA : LS_HEADER TYPE BAPI2017_GM_HEAD_01.
  DATA : LT_ITEM  TYPE TABLE OF BAPI2017_GM_ITEM_CREATE.
  DATA : LT_RETURN TYPE TABLE OF BAPIRET2.
  DATA : LS_GMHEADRET LIKE BAPI2017_GM_HEAD_RET.
  DATA : LT_ITEM_NO TYPE TABLE OF BAPI2017_GM_SERIALNUMBER.

* 헤더구성
  LS_HEADER-PSTNG_DATE = GV_BUDAT.
  LS_HEADER-DOC_DATE = GV_BUDAT.
  LS_HEADER-PR_UNAME = SY-UNAME.
  LS_HEADER-HEADER_TXT = |WIP오더입고재처리({ SY-TCODE })|.
* 아이템 구성
  APPEND INITIAL LINE TO LT_ITEM ASSIGNING FIELD-SYMBOL(<LS_ITEM>).
  <LS_ITEM>-MATERIAL = PS_MSEG-MATNR.
  <LS_ITEM>-PLANT = PS_MSEG-WERKS.
  <LS_ITEM>-STGE_LOC = PS_MSEG-LGORT.
  <LS_ITEM>-BATCH = PS_MSEG-CHARG.
  <LS_ITEM>-MOVE_TYPE = '101'.
  <LS_ITEM>-STCK_TYPE = PS_MSEG-INSMK.
  <LS_ITEM>-NO_MORE_GR = PS_MSEG-ELIKZ.
  <LS_ITEM>-ENTRY_QNT = PS_MSEG-ERFMG.
  <LS_ITEM>-ENTRY_UOM = PS_MSEG-ERFME.
  <LS_ITEM>-ORDERID = PS_MSEG-AUFNR.
  <LS_ITEM>-ORDER_ITNO = PS_MSEG-AUFPS.
  <LS_ITEM>-SPEC_STOCK = PS_MSEG-SOBKZ.
  <LS_ITEM>-VAL_SALES_ORD = PS_MSEG-KDAUF.
  <LS_ITEM>-VAL_S_ORD_ITEM = PS_MSEG-KDPOS.
  <LS_ITEM>-ITEM_TEXT = PS_MSEG-SGTXT.
  <LS_ITEM>-PROD_DATE = PS_MSEG-HSDAT.
  <LS_ITEM>-MVT_IND = PS_MSEG-KZBEW.

  CLEAR : GV_JOB, GS_RETURN.

  CALL FUNCTION 'ZGTPP_GOODSMVT_CREATE' STARTING NEW TASK 'GOODSMVT_CREATE'
    PERFORMING RETURN_GOODSMVT_CREATE ON END OF TASK
    EXPORTING
      GOODSMVT_HEADER = LS_HEADER
      GOODSMVT_CODE   = '02'
    TABLES
      GOODSMVT_ITEM   = LT_ITEM.

  WAIT UNTIL GV_JOB = '1'.

  CASE GS_RETURN-TYPE.
    WHEN 'E'.
      PV_CHK_ERR = 'E'.
      PS_MOSU-STATUS = ICON_LED_RED.
      PS_MOSU-MESSAGE = GS_RETURN-MESSAGE.
    WHEN OTHERS.
      PS_4152-MBLNR_P = GS_RETURN-MBLNR.
      PS_4152-MJAHR_P = GS_RETURN-MJAHR.
  ENDCASE.

*  CALL FUNCTION 'BAPI_GOODSMVT_CREATE'
*    EXPORTING
*      GOODSMVT_HEADER       = LS_HEADER
*      GOODSMVT_CODE         = '02'
*    IMPORTING
*      GOODSMVT_HEADRET      = LS_GMHEADRET
*    TABLES
*      GOODSMVT_ITEM         = LT_ITEM
*      RETURN                = LT_RETURN
*      GOODSMVT_SERIALNUMBER = LT_ITEM_NO.
*
*  IF LS_GMHEADRET IS INITIAL.
*    PV_CHK_ERR = 'E'.
*    PS_MOSU-STATUS = ICON_LED_RED.
*    READ TABLE LT_RETURN INTO DATA(LS_RETURN) WITH KEY TYPE = 'E'.
*    PS_MOSU-MESSAGE = LS_RETURN-MESSAGE.
*
*  ELSE.
**- 성공
*    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
*      EXPORTING
*        WAIT = 'X'.
*    PS_4152-MBLNR_P = LS_GMHEADRET-MAT_DOC.
*    READ TABLE LT_ITEM_NO INTO DATA(LS_MATDOCITEM) INDEX 1.
*    PS_4152-ZEILE_P = LS_MATDOCITEM-MATDOC_ITM.
*    PS_4152-MJAHR_P = LS_GMHEADRET-DOC_YEAR.
*
*  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form INIT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM INIT .

  REFRESH GT_BUDAT.
  APPEND INITIAL LINE TO GT_BUDAT ASSIGNING FIELD-SYMBOL(<LS_BUDAT>).
  <LS_BUDAT>-SIGN = 'I'.
  <LS_BUDAT>-OPTION = 'BT'.
  <LS_BUDAT>-LOW = P_SPMON && '01'.
  <LS_BUDAT>-HIGH = <LS_BUDAT>-LOW.
  PERFORM GET_LAST_DAY_OF_MONTH CHANGING <LS_BUDAT>-HIGH.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form RETURN_CONF_CANCEL
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM RETURN_CONF_CANCEL USING P_TASKNAME.

  RECEIVE RESULTS FROM FUNCTION 'ZGTPP_BAPI_GOODSMVT_CANCEL'
   IMPORTING
     CREATED_CONF_NO    = GS_RETURN-RUECK
     CREATED_CONF_COUNT = GS_RETURN-RMZHL
     EV_TYPE = GS_RETURN-TYPE
     EV_MESSAGE = GS_RETURN-MESSAGE.

  GV_JOB = '1'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form RETURN_GOODSMVT_CANCEL
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
FORM RETURN_GOODSMVT_CANCEL  USING P_TASKNAME.

  RECEIVE RESULTS FROM FUNCTION 'ZGTPP_GOODSMVT_CANCEL'
   IMPORTING
     EV_MBLNR    = GS_RETURN-MBLNR
     EV_MJAHR = GS_RETURN-MJAHR
     EV_TYPE = GS_RETURN-TYPE
     EV_MESSAGE = GS_RETURN-MESSAGE.

  GV_JOB = '1'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form RETURN_CONF_CREATE_TT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GOODSMVT_MATDOCITEM
*&      --> =
*&      --> LT_MATDOCITEM
*&---------------------------------------------------------------------*
FORM RETURN_CONF_CREATE_TT  USING P_TASKNAME.

  RECEIVE RESULTS FROM FUNCTION 'ZGTPP_CONF_CREATE_TT'
   IMPORTING
     CREATED_CONF_NO    = GS_RETURN-RUECK
     CREATED_CONF_COUNT = GS_RETURN-RMZHL
     EV_TYPE = GS_RETURN-TYPE
     EV_MESSAGE = GS_RETURN-MESSAGE.

  GV_JOB = '1'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form RETURN_GOODSMVT_CREATE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GOODSMVT_ITEM
*&      --> =
*&      --> LT_ITEM
*&---------------------------------------------------------------------*
FORM RETURN_GOODSMVT_CREATE  USING P_TASKNAME.

  RECEIVE RESULTS FROM FUNCTION 'ZGTPP_GOODSMVT_CREATE'
   IMPORTING
     EV_MBLNR    = GS_RETURN-MBLNR
     EV_MJAHR = GS_RETURN-MJAHR
     EV_TYPE = GS_RETURN-TYPE
     EV_MESSAGE = GS_RETURN-MESSAGE.

  GV_JOB = '1'.

ENDFORM.
