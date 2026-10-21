*&---------------------------------------------------------------------*
*& Include          ZGTPPR2220F01
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
    CLEAR ZPPT0107.
    SELECT SINGLE DESCR INTO P_DESCR
             FROM ZPPT0107
            WHERE SPGCD EQ P_SPGCD.
  ELSE.
    CLEAR P_DESCR.
  ENDIF.

* 플랜트명
  IF NOT P_WERKS IS INITIAL.
    CLEAR T001W.
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
      SCREEN-INPUT = 0.
      SCREEN-INTENSIFIED = 1.
      MODIFY SCREEN.
    ENDIF.
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
  AUTHORITY-CHECK OBJECT 'ZPP_SPGCD'
  ID 'WERKS'  FIELD P_WERKS
  ID 'SPGCD'  FIELD P_SPGCD.

  IF SY-SUBRC <> 0.
    MESSAGE E006 WITH 'SPG[' P_SPGCD
                      '] 작업권한을 확인하세요.'.
  ENDIF.

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

  PERFORM GET_INIT.

  PERFORM GET_DATA_FR_DB.

  CHECK GT_MAIN_DISP IS NOT INITIAL.

  PERFORM SET_DISP_DATA.

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

  IF GT_MAIN_DISP IS NOT INITIAL.
    CALL SCREEN '0100'.
  ELSE.
    MESSAGE S001 DISPLAY LIKE 'E'.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_DATA_FR_DB
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_DATA_FR_DB .

  REFRESH : GT_MAIN_DISP, GT_2320, GT_2360, GT_2360_CHG.
  REFRESH GT_ARBPL.

  SELECT WERKS, @P_NAME1 AS NAME1, SPGCD, @P_DESCR AS DESCR, SPMON,
    VDATU, ZVERS_NO, ZVERS_DESC, CRDAT, CRTIM, CRNAM
    FROM ZGTPPT2310
    INTO CORRESPONDING FIELDS OF TABLE @GT_MAIN_DISP
   WHERE WERKS = @P_WERKS
     AND SPMON = @P_SPMON
     AND ZVERS_NO IN @S_ZVERS
     AND VDATU IN @S_VDATU
     AND CRDAT IN @S_CRDAT.

  IF GT_MAIN_DISP IS NOT INITIAL.
    SELECT B~*
      FROM @GT_MAIN_DISP AS A
      INNER JOIN ZGTPPT2320 AS B ON B~WERKS = A~WERKS
                                AND B~SPGCD = A~SPGCD
                                AND B~SPMON = A~SPMON
                                AND B~ZVERS_NO = A~ZVERS_NO
     INTO TABLE @GT_2320.

    SORT GT_2320 BY WERKS SPGCD SPMON VDATU ZVERS_NO ZREQ_NO.

    SELECT B~*
      FROM @GT_MAIN_DISP AS A
      INNER JOIN ZGTPPT2360 AS B ON B~WERKS = A~WERKS
                                AND B~SPGCD = A~SPGCD
                                AND B~SPMON = A~SPMON
                                AND B~ZVERS_NO = A~ZVERS_NO
     INTO TABLE @GT_2360.

    SORT GT_2360 BY WERKS SPGCD SPMON VDATU ZVERS_NO ZREQ_NO ZOPER_SEQ.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_INIT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_INIT .

* SPG
  IF NOT P_SPGCD IS INITIAL.
    CLEAR ZPPT0107.
    SELECT SINGLE DESCR INTO P_DESCR
             FROM ZPPT0107
            WHERE SPGCD EQ P_SPGCD.
  ELSE.
    CLEAR P_DESCR.
  ENDIF.

* 플랜트명
  IF NOT P_WERKS IS INITIAL.
    CLEAR T001W.
    SELECT SINGLE NAME1 INTO P_NAME1
             FROM T001W
            WHERE WERKS EQ P_WERKS.
  ELSE.
    CLEAR P_NAME1.
  ENDIF.

* 탐뎀 구성을 위한 기준정보 추출
  SELECT * FROM ZGTPPT1010
    INTO TABLE GT_TANDEM
   WHERE MODULE_KIND = 'PP'
     AND CODEGRP = '1060'
     AND FLD_02 = P_WERKS
     AND FLD_07 = 'Y'.

  REFRESH GT_TANDEM_ARBPL.
  GT_TANDEM_ARBPL = VALUE #( FOR LW_1010 IN GT_TANDEM WHERE ( FLD_04 IS NOT INITIAL )
                                           ( SIGN = 'I' OPTION = 'EQ' LOW = LW_1010-FLD_04 ) ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_DISP_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_DISP_DATA .

  REFRESH : GT_MAIN_101, GT_MAIN_102.
* 선택한 버전의 설비정보
  CHECK GV_ZVERS_NO IS NOT INITIAL.

  DATA : LT_DUDATE TYPE RANGE OF SY-DATUM.

  DATA : LT_ARBPL TYPE RANGE OF ARBPL.

  LOOP AT GT_2360 INTO DATA(LS_2360) WHERE ZVERS_NO = GV_ZVERS_NO
                                       AND LOEKZ = ''.
    CLEAR GS_MAIN_101.
    GS_MAIN_101-ARBPL = LS_2360-ARBPL.
    GS_MAIN_101-ZTIME = LS_2360-ZTIME.
    GS_MAIN_101-ZUNIT = LS_2360-ZUNIT.
    COLLECT GS_MAIN_101 INTO GT_MAIN_101.
  ENDLOOP.

  REFRESH LT_ARBPL.

  LT_ARBPL = VALUE #( FOR LW_MAIN_101 IN GT_MAIN_101 WHERE ( ARBPL IS NOT INITIAL )
                    ( SIGN = 'I' OPTION = 'EQ' LOW = LW_MAIN_101-ARBPL ) ).

  SORT LT_ARBPL BY LOW.
  DELETE ADJACENT DUPLICATES FROM LT_ARBPL COMPARING  LOW.
  IF LT_ARBPL IS NOT INITIAL.
    SELECT A~ARBPL, B~KTEXT
      FROM CRHD AS A
      INNER JOIN CRTX AS B ON B~OBJTY = A~OBJTY
                          AND B~OBJID = A~OBJID
     WHERE A~OBJTY = 'A'
       AND A~ARBPL IN @LT_ARBPL
       AND B~SPRAS = @SY-LANGU
      INTO TABLE @GT_ARBPL.

    SORT GT_ARBPL BY ARBPL.

    APPEND INITIAL LINE TO LT_DUDATE ASSIGNING FIELD-SYMBOL(<LS_DUDATE>).
    <LS_DUDATE>-SIGN = 'I'.
    <LS_DUDATE>-OPTION = 'BT'.
    <LS_DUDATE>-LOW = P_SPMON && '01'.
    <LS_DUDATE>-HIGH = P_SPMON && '01'.
    PERFORM GET_LAST_DAY_OF_MONTH CHANGING <LS_DUDATE>-HIGH.

    DATA : BEGIN OF LS_2290,
             ARBPL     TYPE ZGTPPT2270-ARBPL,
             EQUCD     TYPE ZGTPPT2290-EQUCD,
             ZWORKDAY  TYPE ZGTPPT2290-ZWORKDAY,
             ZWORKTIME TYPE ZGTPPT2290-ZWORKTIME,
           END OF LS_2290.
    DATA : LT_2290 LIKE TABLE OF LS_2290.

    SELECT A~ARBPL, B~*
      FROM ZGTPPT2270 AS A
      INNER JOIN ZGTPPT2290 AS B ON B~WERKS = A~WERKS
                                AND B~EQUCD = A~EQUCD
      INTO CORRESPONDING FIELDS OF TABLE @LT_2290
     WHERE A~WERKS = @P_WERKS
       AND A~ARBPL IN @LT_ARBPL
       AND B~ZWORKDAY IN @LT_DUDATE.

    SORT LT_2290 BY ARBPL.

  ENDIF.

  LOOP AT GT_MAIN_101 ASSIGNING FIELD-SYMBOL(<LS_MAIN_101>).
    READ TABLE GT_ARBPL INTO DATA(LS_ARBPL_T) WITH KEY ARBPL = <LS_MAIN_101>-ARBPL BINARY SEARCH.
    IF SY-SUBRC EQ 0 .
      <LS_MAIN_101>-KTEXT = LS_ARBPL_T-KTEXT.
    ENDIF.

    <LS_MAIN_101>-ZDAY = <LS_MAIN_101>-ZTIME / 1440.
    <LS_MAIN_101>-ZUNIT1 = '10'.

* 월별 가용일수 / 비율 추가
    LOOP AT LT_2290 INTO LS_2290 WHERE ARBPL = <LS_MAIN_101>-ARBPL.
      ADD LS_2290-ZWORKTIME TO <LS_MAIN_101>-MONTHDAY.
    ENDLOOP.

    <LS_MAIN_101>-MONTHDAY = <LS_MAIN_101>-MONTHDAY / 24.
    IF <LS_MAIN_101>-MONTHDAY NE 0 AND <LS_MAIN_101>-ZDAY NE 0.
      <LS_MAIN_101>-MONTHRATE = ( <LS_MAIN_101>-ZDAY / <LS_MAIN_101>-MONTHDAY ) * 100.
      CONDENSE <LS_MAIN_101>-MONTHRATE.
      <LS_MAIN_101>-MONTHRATE = |{ <LS_MAIN_101>-MONTHRATE } %|.

    ENDIF.
  ENDLOOP.

* 설비의 상세 정보
  PERFORM GET_DETAIL_INFOR.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_DETAIL_INFOR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_DETAIL_INFOR .
* 설비의 상세 정보
  CHECK GV_ARBPL IS NOT INITIAL.

  LOOP AT GT_2360 INTO DATA(LS_2360) WHERE ZVERS_NO = GV_ZVERS_NO
                                       AND ARBPL = GV_ARBPL
                                       AND LOEKZ = ''.

    CLEAR GS_MAIN_102.
    GS_MAIN_102-ZREQ_NO = LS_2360-ZREQ_NO.
    GS_MAIN_102-ZOPER_SEQ = LS_2360-ZOPER_SEQ.
    GS_MAIN_102-ARBPL = LS_2360-ARBPL.

    READ TABLE GT_ARBPL INTO DATA(LS_ARBPL_T) WITH KEY ARBPL = GS_MAIN_102-ARBPL BINARY SEARCH.
    IF SY-SUBRC EQ 0.
      GS_MAIN_102-KTEXT = LS_ARBPL_T-KTEXT.
    ENDIF.
    GS_MAIN_102-MATNR = LS_2360-MATNR.
    GS_MAIN_102-MAKTX = ZGTPP_CL_COMMON=>GET_MAKTX( IV_MATNR = LS_2360-MATNR ).
    GS_MAIN_102-MENGE = LS_2360-MENGE.
    GS_MAIN_102-MEINS = LS_2360-MEINS.
    GS_MAIN_102-ZTIME = LS_2360-ZTIME.
    GS_MAIN_102-ZUNIT = LS_2360-ZUNIT.

    READ TABLE GT_2320 INTO DATA(LS_2320) WITH KEY ZVERS_NO = GV_ZVERS_NO
                                                   ZREQ_NO = LS_2360-ZREQ_NO.
    IF SY-SUBRC EQ 0.
      CASE LS_2320-ZREQ_TYPE.
        WHEN '1'.
          GS_MAIN_102-ZREQ_TYPET = '1. 작업지시 확정'.
        WHEN '2'.
          GS_MAIN_102-ZREQ_TYPET = '2. 영업수주 확정'.
        WHEN '3'.
          GS_MAIN_102-ZREQ_TYPET = '3. 수기 등록'.
      ENDCASE.

      GS_MAIN_102-VBELN = LS_2320-VBELN.
      GS_MAIN_102-POSNR = LS_2320-POSNR.
      GS_MAIN_102-AUFNR = LS_2320-AUFNR.
      GS_MAIN_102-ZMANUAL_NO = LS_2320-ZMANUAL_NO.
      GS_MAIN_102-PMATN = LS_2320-PMATN.
      GS_MAIN_102-PMAKT = ZGTPP_CL_COMMON=>GET_MAKTX( IV_MATNR = LS_2320-PMATN ).
      GS_MAIN_102-PMENG = LS_2320-PMENG.
      GS_MAIN_102-PMEIN = LS_2320-PMEIN.

    ENDIF.

    APPEND GS_MAIN_102 TO GT_MAIN_102.

  ENDLOOP.


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

  CREATE OBJECT GO_DOCKING_CONTAINER
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

  CREATE OBJECT GO_SPLITTER
    EXPORTING
      PARENT  = GO_DOCKING_CONTAINER
      ROWS    = 2
      COLUMNS = 1.

  PERFORM SET_SPLITER_HEIGHT.

* 1열 컨테이너
  CALL METHOD GO_SPLITTER->GET_CONTAINER
    EXPORTING
      ROW       = 1
      COLUMN    = 1
    RECEIVING
      CONTAINER = GO_CONTAIN_0100.

  CALL METHOD GO_SPLITTER->GET_CONTAINER
    EXPORTING
      ROW       = 2
      COLUMN    = 1
    RECEIVING
      CONTAINER = GO_BOTTOM_CONTAINER.

  CREATE OBJECT GO_SPLITTER2
    EXPORTING
      PARENT  = GO_BOTTOM_CONTAINER
      ROWS    = 1
      COLUMNS = 2.

  PERFORM SET_SPLITER_WIDTH.

  CALL METHOD GO_SPLITTER2->GET_CONTAINER
    EXPORTING
      ROW       = 1
      COLUMN    = 1
    RECEIVING
      CONTAINER = GO_CONTAIN_0101.

  CALL METHOD GO_SPLITTER2->GET_CONTAINER
    EXPORTING
      ROW       = 1
      COLUMN    = 2
    RECEIVING
      CONTAINER = GO_CONTAIN_0102.

  CREATE OBJECT GO_GRID_0100
    EXPORTING
      I_PARENT      = GO_CONTAIN_0100
      I_APPL_EVENTS = ABAP_TRUE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_SPLITER_HEIGHT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_SPLITER_HEIGHT .

  IF GV_ZVERS_NO IS INITIAL.
    GO_SPLITTER->SET_ROW_HEIGHT(
      EXPORTING
        ID                =  1                " Row ID
        HEIGHT            =  100    ).            " Height

    GO_SPLITTER->SET_ROW_HEIGHT(
      EXPORTING
        ID                =  2                " Row ID
        HEIGHT            =  0    ).            " Height

  ELSE.
    GO_SPLITTER->SET_ROW_HEIGHT(
      EXPORTING
        ID                =  1                " Row ID
        HEIGHT            =  30    ).            " Height

    GO_SPLITTER->SET_ROW_HEIGHT(
      EXPORTING
        ID                =  2                " Row ID
        HEIGHT            =  70    ).            " Height
  ENDIF.

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
      SET HANDLER GO_EVENT_HANDLER->HANDLE_HOTSPOT        FOR PO_GRID.
    WHEN GO_GRID_0101.
      SET HANDLER GO_EVENT_HANDLER->HANDLE_HOTSPOT          FOR PO_GRID.
    WHEN GO_GRID_0102.
      SET HANDLER GO_EVENT_HANDLER->HANDLE_TOOLBAR          FOR PO_GRID.
      SET HANDLER GO_EVENT_HANDLER->HANDLE_USER_COMMAND          FOR PO_GRID.
      SET HANDLER GO_EVENT_HANDLER->HANDLE_HOTSPOT          FOR PO_GRID.
      SET HANDLER GO_EVENT_HANDLER->HANDLE_CONTEXT_MENU          FOR PO_GRID.
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
  GS_LAYOUT_0100-NO_ROWMARK   = 'X'.
  GS_LAYOUT_0100-ZEBRA   = 'X'.
  GS_LAYOUT_0100-SEL_MODE   = 'C'.

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
  DATA : LV_COL_POS TYPE I.

  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      I_PROGRAM_NAME         = SY-REPID
      I_INCLNAME             = 'ZGTPPR2220TOP'
      I_INTERNAL_TABNAME     = 'GS_MAIN_DISP'
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
      WHEN 'CHECK'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '선택'(F01).
        <LS_FCAT>-JUST = 'C'.
        <LS_FCAT>-ICON = ABAP_TRUE.
      WHEN 'WERKS'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '플랜트'(F02).
        <LS_FCAT>-JUST = 'C'.
      WHEN 'NAME1'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '플랜트 내역'(F03).
        <LS_FCAT>-JUST = 'L'.
      WHEN 'SPGCD'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = 'SPG'(F04).
        <LS_FCAT>-JUST = 'C'.
      WHEN 'DESCR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = 'SPG 내역'(F05).
        <LS_FCAT>-JUST = 'L'.
      WHEN 'SPMON'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '판매년월'(F06).
        <LS_FCAT>-JUST = 'C'.
      WHEN 'VDATU'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '기준일자'(F07).
        <LS_FCAT>-JUST = 'C'.
      WHEN 'ZVERS_NO'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '산출 버전 번호'(F08).
        <LS_FCAT>-JUST = 'C'.
        <LS_FCAT>-HOTSPOT = ABAP_TRUE.
        <LS_FCAT>-EMPHASIZE = 'C700'.
      WHEN 'ZVERS_DESC'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '산출 버전 내역'(F09).
        <LS_FCAT>-JUST = 'L'.
      WHEN 'CRDAT'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '생성일자'(F10).
        <LS_FCAT>-JUST = 'C'.
      WHEN 'CRTIM'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '생성시간'(F11).
        <LS_FCAT>-JUST = 'C'.
      WHEN 'CRNAM'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '생성자'(F12).
        <LS_FCAT>-JUST = 'C'.
    ENDCASE.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_SORTTAB_GRID_0100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_SORTTAB_GRID_0100 .

  REFRESH GT_SORT_0100.

  PERFORM SET_SORT_TAB TABLES GT_SORT_0100
                            USING : 1 'ZVERS_NO'  'X' '' ''.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_SORT_TAB
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_SORT_0100
*&      --> P_1
*&      --> P_
*&      --> P_
*&      --> P_
*&      --> P_
*&---------------------------------------------------------------------*
FORM SET_SORT_TAB  TABLES   PT_SORTTAB STRUCTURE LVC_S_SORT
                   USING    PV_POS
                               PV_FIELDNAME
                               PV_UP
                               PV_DOWN
                               PV_SUBTOT.

  DATA : LS_SORT TYPE LVC_S_SORT.
  LS_SORT-SPOS = PV_POS.
  LS_SORT-FIELDNAME = PV_FIELDNAME.
  LS_SORT-UP = PV_UP.
  LS_SORT-DOWN = PV_DOWN.
  LS_SORT-SUBTOT =  PV_SUBTOT.
  APPEND LS_SORT TO PT_SORTTAB.

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
    CHANGING
      IT_OUTTAB            = GT_MAIN_DISP
      IT_SORT              = GT_SORT_0100
      IT_FIELDCATALOG      = GT_FIELDCAT_0100.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_OBJECT_GRID_0101
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_OBJECT_GRID_0101 .

  CREATE OBJECT GO_GRID_0101
    EXPORTING
      I_PARENT      = GO_CONTAIN_0101
      I_APPL_EVENTS = ABAP_TRUE.

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
  GS_LAYOUT_0101-NO_ROWMARK = ABAP_TRUE.
  GS_LAYOUT_0101-CWIDTH_OPT = ABAP_TRUE.
  GS_LAYOUT_0101-NO_ROWINS = ABAP_TRUE.
  GS_LAYOUT_0101-ZEBRA   = 'X'.
  IF GV_ZVERS_NO IS NOT INITIAL.
    GS_LAYOUT_0101-SMALLTITLE = 'X'.
    GS_LAYOUT_0101-GRID_TITLE = | 산출 버전 번호 : { GV_ZVERS_NO }　　{ GV_ZVERS_DESC }|.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_FIELDCAT_GRID_0101
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_FIELDCAT_GRID_0101 .

  DATA : LT_FCAT_SLIS TYPE SLIS_T_FIELDCAT_ALV.
  DATA : LV_COL_POS TYPE I.

  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      I_PROGRAM_NAME         = SY-REPID
      I_INCLNAME             = 'ZGTPPR2220TOP'
      I_INTERNAL_TABNAME     = 'GS_MAIN_101'
    CHANGING
      CT_FIELDCAT            = LT_FCAT_SLIS
    EXCEPTIONS
      INCONSISTENT_INTERFACE = 1
      PROGRAM_ERROR          = 2
      OTHERS                 = 3.

  REFRESH GT_FIELDCAT_0101.

*-- lt_fieldcat의 구조체를 pt_fcat의 구조체로 변경
  CALL FUNCTION 'LVC_TRANSFER_FROM_SLIS'
    EXPORTING
      IT_FIELDCAT_ALV = LT_FCAT_SLIS
    IMPORTING
      ET_FIELDCAT_LVC = GT_FIELDCAT_0101[]
    TABLES
      IT_DATA         = GT_MAIN_101
    EXCEPTIONS
      OTHERS          = 1.


  LOOP AT GT_FIELDCAT_0101 ASSIGNING FIELD-SYMBOL(<LS_FCAT>).
    CLEAR <LS_FCAT>-KEY.
    CASE   <LS_FCAT>-FIELDNAME.
      WHEN 'ARBPL'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '작업장코드'(F13).
        <LS_FCAT>-JUST = 'C'.
        <LS_FCAT>-HOTSPOT = ABAP_TRUE.
        <LS_FCAT>-EMPHASIZE = 'C700'.

      WHEN 'KTEXT'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '작업장내역'(F14).
        <LS_FCAT>-JUST = 'L'.
        <LS_FCAT>-EMPHASIZE = 'C700'.
      WHEN 'ZDAY'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '소요일수'(F15).
        <LS_FCAT>-JUST = 'R'.
        <LS_FCAT>-QUANTITY = 'D'.
      WHEN 'ZUNIT1'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '단위'(F16).
        <LS_FCAT>-JUST = 'C'.
      WHEN 'ZTIME'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '소요시간'(F17).
        <LS_FCAT>-JUST = 'R'.
        <LS_FCAT>-QUANTITY = 'MIN'.
      WHEN 'ZUNIT'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '단위'(F18).
        <LS_FCAT>-JUST = 'C'.

      WHEN 'MONTHDAY'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = P_SPMON+4(2) && '월 가용일수'(F37).
        <LS_FCAT>-JUST = 'R'.
      WHEN 'MONTHRATE'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = P_SPMON+4(2) && '월 가동율'(F38).
        <LS_FCAT>-JUST = 'R'.

    ENDCASE.

  ENDLOOP.

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

  REFRESH GT_SORT_0101.

  PERFORM SET_SORT_TAB TABLES GT_SORT_0101
                            USING : 1 'ARBPL'  'X' '' ''.

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

  REFRESH GT_EXCLUDE_0101.

  PERFORM ADD_EXCLUDE_TOOLBAR_BUTTON TABLES GT_EXCLUDE_0101
        USING : CL_GUI_ALV_GRID=>MC_FC_EXCL_ALL.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  add_exclude_toolbar_button
*&---------------------------------------------------------------------*
*       text
*-----------------------------------------------------------------------
FORM ADD_EXCLUDE_TOOLBAR_BUTTON  TABLES   P_TABLE
                                 USING    P_VALUE.
  DATA: L_EXCLUDE TYPE UI_FUNC.
  L_EXCLUDE = P_VALUE.
  APPEND L_EXCLUDE TO P_TABLE.
ENDFORM.                    " add_exclude_toolbar_button
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

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_OBJECT_GRID_0102
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_OBJECT_GRID_0102 .

  CREATE OBJECT GO_GRID_0102
    EXPORTING
      I_PARENT      = GO_CONTAIN_0102
      I_APPL_EVENTS = ABAP_TRUE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_LAYOUT_GRID_0102
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_LAYOUT_GRID_0102 .

  CLEAR GS_LAYOUT_0102.
  GS_LAYOUT_0102-NO_ROWMARK = ABAP_TRUE.
  GS_LAYOUT_0102-CWIDTH_OPT = ABAP_TRUE.
  GS_LAYOUT_0102-NO_ROWINS = ABAP_TRUE.
  GS_LAYOUT_0102-ZEBRA   = 'X'.
  GS_LAYOUT_0102-SEL_MODE   = 'D'.
  IF GV_ARBPL IS NOT INITIAL.
    GS_LAYOUT_0102-SMALLTITLE = 'X'.
    GS_LAYOUT_0102-GRID_TITLE = | 작업장 : { GV_ARBPL }　　{ GV_KTEXT }|.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_FIELDCAT_GRID_0102
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_FIELDCAT_GRID_0102 .

  DATA : LT_FCAT_SLIS TYPE SLIS_T_FIELDCAT_ALV.
  DATA : LV_COL_POS TYPE I.

  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      I_PROGRAM_NAME         = SY-REPID
      I_INCLNAME             = 'ZGTPPR2220TOP'
      I_INTERNAL_TABNAME     = 'GS_MAIN_102'
    CHANGING
      CT_FIELDCAT            = LT_FCAT_SLIS
    EXCEPTIONS
      INCONSISTENT_INTERFACE = 1
      PROGRAM_ERROR          = 2
      OTHERS                 = 3.

  REFRESH GT_FIELDCAT_0102.

*-- lt_fieldcat의 구조체를 pt_fcat의 구조체로 변경
  CALL FUNCTION 'LVC_TRANSFER_FROM_SLIS'
    EXPORTING
      IT_FIELDCAT_ALV = LT_FCAT_SLIS
    IMPORTING
      ET_FIELDCAT_LVC = GT_FIELDCAT_0102[]
    TABLES
      IT_DATA         = GT_MAIN_102
    EXCEPTIONS
      OTHERS          = 1.


  READ TABLE GT_FIELDCAT_0102 ASSIGNING FIELD-SYMBOL(<LS_FCAT>) WITH KEY FIELDNAME = 'CHECK'.
  IF SY-SUBRC NE 0.
    APPEND INITIAL LINE TO GT_FIELDCAT_0102 ASSIGNING <LS_FCAT>.
    <LS_FCAT>-FIELDNAME = 'CHECK'.
    <LS_FCAT>-COL_POS = 1.
    <LS_FCAT>-DATATYPE = 'CHAR'.
    <LS_FCAT>-DD_OUTLEN = '1'.
  ENDIF.


  LOOP AT GT_FIELDCAT_0102 ASSIGNING <LS_FCAT>.
    CLEAR <LS_FCAT>-KEY.
    CASE   <LS_FCAT>-FIELDNAME.
      WHEN 'CHECK'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '선택'(F01).
        <LS_FCAT>-JUST = 'C'.
        <LS_FCAT>-CHECKBOX = ABAP_TRUE.
        <LS_FCAT>-HOTSPOT = ABAP_TRUE.
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.

      WHEN 'ZREQ_NO'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '산출 대상 번호'(F19).
        <LS_FCAT>-JUST = 'C'.
      WHEN 'ZREQ_TYPET'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '산출 구분'(F20).
        <LS_FCAT>-JUST = 'L'.
      WHEN 'VBELN'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '판매오더번호'(F21).
        <LS_FCAT>-JUST = 'C'.
      WHEN 'POSNR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '판매오더품목'(F22).
        <LS_FCAT>-JUST = 'C'.
      WHEN 'AUFNR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '생산오더번호(제품)'(F23).
        <LS_FCAT>-JUST = 'C'.
      WHEN 'ZMANUAL_NO'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '수기 등록 번호'(F24).
        <LS_FCAT>-JUST = 'C'.
      WHEN 'PMATN'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '산출 품목코드'(F25).
        <LS_FCAT>-JUST = 'C'.
      WHEN 'PMAKT'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '산출 품목내역'(F26).
        <LS_FCAT>-JUST = 'L'.
      WHEN 'PMENG'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '산출 수량'(F27).
        <LS_FCAT>-JUST = 'R'.
        <LS_FCAT>-QFIELDNAME = 'PMEIN'.
      WHEN 'PMEIN'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '산출 단위'(F28).
        <LS_FCAT>-JUST = 'C'.
      WHEN 'ZOPER_SEQ'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '공정 순번'(F29).
        <LS_FCAT>-JUST = 'C'.
      WHEN 'ARBPL'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '작업장코드'(F13).
        <LS_FCAT>-JUST = 'C'.
        <LS_FCAT>-EMPHASIZE = 'C700'.
      WHEN 'KTEXT'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '작업장내역'(F30).
        <LS_FCAT>-JUST = 'L'.
        <LS_FCAT>-EMPHASIZE = 'C700'.
      WHEN 'MATNR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '공정 품목코드'(F31).
        <LS_FCAT>-JUST = 'C'.
      WHEN 'MAKTX'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '공정 품목내역'(F32).
        <LS_FCAT>-JUST = 'L'.
      WHEN 'MENGE'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '공정 수량'(F33).
        <LS_FCAT>-JUST = 'R'.
        <LS_FCAT>-QFIELDNAME = 'MEINS'.
      WHEN 'MEINS'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '수량 단위'(F34).
        <LS_FCAT>-JUST = 'C'.
      WHEN 'ZTIME'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '소요시간'(F35).
        <LS_FCAT>-JUST = 'R'.
        <LS_FCAT>-EMPHASIZE = 'C700'.
        <LS_FCAT>-QFIELDNAME = 'ZUNIT'.
      WHEN 'ZUNIT'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '시간단위'(F36).
        <LS_FCAT>-JUST = 'C'.
        <LS_FCAT>-EMPHASIZE = 'C700'.

    ENDCASE.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_SORTTAB_GRID_0102
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_SORTTAB_GRID_0102 .

  REFRESH GT_SORT_0102.

  PERFORM SET_SORT_TAB TABLES GT_SORT_0102
                            USING : 1 'ZREQ_NO'  'X' '' ''.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form EXCLUDE_OF_TOOLBAR_GRID_0102
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM EXCLUDE_OF_TOOLBAR_GRID_0102 .

  REFRESH GT_EXCLUDE_0102.

  PERFORM ADD_EXCLUDE_TOOLBAR_BUTTON TABLES GT_EXCLUDE_0102
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
*& Form CALL_GRID_0102_DISPLAY
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CALL_GRID_0102_DISPLAY .

  CALL METHOD GO_GRID_0102->SET_TABLE_FOR_FIRST_DISPLAY
    EXPORTING
      IS_LAYOUT            = GS_LAYOUT_0102
      IT_TOOLBAR_EXCLUDING = GT_EXCLUDE_0102
    CHANGING
      IT_OUTTAB            = GT_MAIN_102
      IT_SORT              = GT_SORT_0102
      IT_FIELDCATALOG      = GT_FIELDCAT_0102.

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
    WHEN GO_GRID_0101.
      PERFORM SET_LAYOUT_GRID_0101.
      GO_GRID_0101->SET_FRONTEND_LAYOUT( IS_LAYOUT = GS_LAYOUT_0101 ).
    WHEN GO_GRID_0102.
      PERFORM SET_LAYOUT_GRID_0102.
      GO_GRID_0102->SET_FRONTEND_LAYOUT( IS_LAYOUT = GS_LAYOUT_0102 ).
  ENDCASE.

  PERFORM SET_SPLITER_HEIGHT.
  PERFORM SET_SPLITER_WIDTH.

  CALL METHOD PO_GRID->REFRESH_TABLE_DISPLAY
    EXPORTING
*     I_SOFT_REFRESH = 'X'
      IS_STABLE = LS_SCROLL.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_SPLITER_WIDTH
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_SPLITER_WIDTH .

  IF GV_ARBPL IS NOT INITIAL.
    GO_SPLITTER2->SET_COLUMN_WIDTH(
      EXPORTING
        ID                = 1                 " Column ID
        WIDTH             = 30 ).                 " NPlWidth
  ELSE.
    GO_SPLITTER2->SET_COLUMN_WIDTH(
  EXPORTING
    ID                = 1                 " Column ID
    WIDTH             = 100 ).                 " NPlWidth
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form HOTSPOT_CLICK
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> SENDER
*&      --> E_ROW_ID
*&      --> E_COLUMN_ID
*&---------------------------------------------------------------------*
FORM HOTSPOT_CLICK  USING    P_SENDER    TYPE REF TO CL_GUI_ALV_GRID
                                PS_ROW_ID    TYPE LVC_S_ROW
                                P_COLUMN_ID TYPE LVC_S_COL.

  CHECK PS_ROW_ID-INDEX NE 0.

  CASE P_SENDER.
    WHEN GO_GRID_0100.
      READ TABLE GT_MAIN_DISP ASSIGNING FIELD-SYMBOL(<LS_MAIN>) INDEX PS_ROW_ID-INDEX.

      CASE P_COLUMN_ID.
        WHEN 'ZVERS_NO'.
          LOOP AT GT_MAIN_DISP ASSIGNING FIELD-SYMBOL(<LS_CLEAR>).
            CLEAR <LS_CLEAR>-CHECK.
          ENDLOOP.

          CLEAR : GV_ZVERS_NO, GV_ZVERS_DESC, GV_ARBPL, GV_KTEXT.
          GV_ZVERS_NO = <LS_MAIN>-ZVERS_NO.
          GV_ZVERS_DESC = <LS_MAIN>-ZVERS_DESC.

          <LS_MAIN>-CHECK = ICON_LED_GREEN.

          PERFORM SET_DISP_DATA.

          PERFORM REFRESH_GRID USING GO_GRID_0100.
          PERFORM REFRESH_GRID USING GO_GRID_0101.
          PERFORM REFRESH_GRID USING GO_GRID_0102.

      ENDCASE.
    WHEN GO_GRID_0101.
      READ TABLE GT_MAIN_101 INTO DATA(LS_MAIN_101) INDEX PS_ROW_ID-INDEX.

      CASE P_COLUMN_ID.
        WHEN 'ARBPL'.
          CLEAR : GV_ARBPL, GV_KTEXT.

          GV_ARBPL = LS_MAIN_101-ARBPL.
          GV_KTEXT = LS_MAIN_101-KTEXT .

* 설비의 상세 정보
          REFRESH GT_MAIN_102.
          PERFORM GET_DETAIL_INFOR.

          PERFORM REFRESH_GRID USING GO_GRID_0102.
      ENDCASE.
    WHEN GO_GRID_0102.
      READ TABLE GT_MAIN_102 ASSIGNING FIELD-SYMBOL(<LS_MAIN_102>)  INDEX PS_ROW_ID-INDEX.

      CASE P_COLUMN_ID.
        WHEN 'CHECK'.
          IF <LS_MAIN_102>-CHECK = ABAP_FALSE.
            <LS_MAIN_102>-CHECK = ABAP_TRUE.
          ELSE.
            CLEAR <LS_MAIN_102>-CHECK.
          ENDIF.

          PERFORM REFRESH_GRID USING GO_GRID_0102.
      ENDCASE.
  ENDCASE.

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
FORM TOOLBAR_PROS  USING   PO_SENDER
                          PO_OBJECT TYPE REF TO CL_ALV_EVENT_TOOLBAR_SET
                          R_INTERACTIVE.

  CASE PO_SENDER.
    WHEN GO_GRID_0102.
      PERFORM SET_TOOLBAR TABLES PO_OBJECT->MT_TOOLBAR
                         USING : 'REPLACE' '' '작업장 변경' '작업장 변경' 0.
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
    WHEN GO_GRID_0102.
      CASE PV_UCOMM.
        WHEN 'REPLACE'. " 작업장 변경
          PERFORM PROC_CHG_ARBPL.
        WHEN 'CHECK_LINE'.
          PERFORM PROCESS_CHECK_LINE_0102.
        WHEN 'DECHECK_LINE'.
          PERFORM PROCESS_DECHECK_LINE_0102.
      ENDCASE.
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROC_CHG_ARBPL
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PROC_CHG_ARBPL .

  DATA : LT_MOSU TYPE TABLE OF ZGTPPT2360.
  DATA : LT_MATNR TYPE RANGE OF MATNR.
  DATA : LS_MATNR LIKE LINE OF LT_MATNR.
  DATA : LV_CHK_TANDEM_ASIS.
  DATA : LV_CHK_TANDEM_TOBE.
  DATA : LV_CHK_ZOPER_SEQ TYPE ZGTPPT2360-ZOPER_SEQ.

  LOOP AT GT_MAIN_102 INTO DATA(LS_MAIN) WHERE CHECK = ABAP_TRUE.
    READ TABLE GT_2360 INTO DATA(LS_2360) WITH KEY ZVERS_NO = GV_ZVERS_NO
                                                   ZREQ_NO = LS_MAIN-ZREQ_NO
                                                   ZOPER_SEQ = LS_MAIN-ZOPER_SEQ.
    IF SY-SUBRC EQ 0.
      APPEND LS_2360 TO LT_MOSU.
    ENDIF.
  ENDLOOP.

  IF LT_MOSU IS INITIAL.
    RETURN.
  ENDIF.

  LOOP AT LT_MOSU INTO DATA(LS_MOSU).
    CLEAR LS_MATNR.
    LS_MATNR-SIGN = 'I'.
    LS_MATNR-OPTION = 'EQ'.
    LS_MATNR-LOW = LS_MOSU-MATNR.
    COLLECT LS_MATNR INTO LT_MATNR.
  ENDLOOP.

  SORT LT_MATNR BY LOW.
* 선택된 자재의 라우팅정보 확인
  REFRESH GT_ROUTING.
  SELECT * FROM ZGTCVROUTING
    INTO TABLE GT_ROUTING
   WHERE MATNR IN LT_MATNR
      AND WERKS = P_WERKS.

  SORT GT_ROUTING BY MATNR ARBPL.
  DELETE ADJACENT DUPLICATES FROM GT_ROUTING COMPARING MATNR ARBPL..

  LOOP AT LT_MATNR INTO LS_MATNR.
    CLEAR GS_HERDER_200.
    GS_HERDER_200-MATNR = LS_MATNR-LOW.
    GS_HERDER_200-MAKTX = ZGTPP_CL_COMMON=>GET_MAKTX( IV_MATNR = LS_MATNR-LOW ).
    GS_HERDER_200-ARBPL = GV_ARBPL.
    GS_HERDER_200-KTEXT = GV_KTEXT.

    PERFORM MAKE_F4_ARBPL USING LS_MATNR-LOW.

    CALL SCREEN '0200' STARTING AT 5 5 ENDING AT 95 9.

    CHECK GS_HERDER_200-CHK_CONFIRM = ABAP_TRUE.

    IF GV_CHK_CHG IS INITIAL.
      GV_CHK_CHG = ABAP_TRUE.
    ENDIF.

*  선택된 모두에서 자재가 동일한건은 전체 변경
    LOOP AT LT_MOSU INTO LS_MOSU WHERE MATNR = LS_MATNR-LOW.
      CLEAR LV_CHK_TANDEM_ASIS.
      CLEAR LV_CHK_TANDEM_TOBE.
      READ TABLE GT_2360 ASSIGNING FIELD-SYMBOL(<LS_2360>) WITH KEY ZVERS_NO = GV_ZVERS_NO
                                                                    ZREQ_NO = LS_MOSU-ZREQ_NO
                                                                    ZOPER_SEQ = LS_MOSU-ZOPER_SEQ.
      IF SY-SUBRC EQ 0.
        READ TABLE GT_TANDEM INTO DATA(LS_TANDEM) WITH KEY FLD_04 = <LS_2360>-ARBPL.
        IF SY-SUBRC EQ 0.
          LV_CHK_ZOPER_SEQ = LS_MOSU-ZOPER_SEQ + 1.
          READ TABLE GT_2360 ASSIGNING FIELD-SYMBOL(<LS_2360_TAN>) WITH KEY ZVERS_NO = GV_ZVERS_NO
                                                          ZREQ_NO = LS_MOSU-ZREQ_NO
                                                          ZOPER_SEQ = LV_CHK_ZOPER_SEQ
                                                          ARBPL+0(3) = LS_TANDEM-FLD_08.
          IF SY-SUBRC EQ 0 AND <LS_2360_TAN>-LOEKZ = ABAP_TRUE.
            LV_CHK_TANDEM_ASIS = ABAP_TRUE.
          ENDIF.
        ENDIF.

        <LS_2360>-ARBPL = GS_HERDER_200-ARBPL2.

        READ TABLE GT_ROUTING INTO DATA(LS_ROUTING) WITH KEY ARBPL = GS_HERDER_200-ARBPL2
                                                             MATNR = LS_MATNR-LOW.
        IF SY-SUBRC EQ 0.
          IF LS_ROUTING-BMSCH NE 0.
            <LS_2360>-ZTIME = ( <LS_2360>-MENGE * LS_ROUTING-VGW02 ) / LS_ROUTING-BMSCH.
          ELSE. " 1000을 기준으로 적용
            <LS_2360>-ZTIME = 0.
          ENDIF.
        ENDIF.

* 저장 테이블에 반영
        READ TABLE GT_2360_CHG ASSIGNING FIELD-SYMBOL(<LS_2360_CHG>) WITH KEY ZVERS_NO = GV_ZVERS_NO
                                                                    ZREQ_NO = LS_MOSU-ZREQ_NO
                                                                    ZOPER_SEQ = LS_MOSU-ZOPER_SEQ
                                                                    BINARY SEARCH.
        IF SY-SUBRC EQ 0.
          MOVE-CORRESPONDING <LS_2360> TO <LS_2360_CHG>.
        ELSE.
          INSERT INITIAL LINE INTO GT_2360_CHG  INDEX SY-TABIX ASSIGNING <LS_2360_CHG>.
          MOVE-CORRESPONDING <LS_2360> TO <LS_2360_CHG>.
        ENDIF.

* 탄뎀 반영 추가
        READ TABLE GT_F4_ARBPL INTO DATA(LS_F4_ARBPL) WITH KEY ARBPL = GS_HERDER_200-ARBPL2
                                                               TANDEM = ABAP_TRUE.
        IF SY-SUBRC EQ 0.
          LV_CHK_TANDEM_TOBE = ABAP_TRUE.
        ENDIF.

        IF  LV_CHK_TANDEM_TOBE = ABAP_TRUE.

          ADD 1  TO LS_MOSU-ZOPER_SEQ .

          READ TABLE GT_TANDEM INTO DATA(LS_TANDEM2) WITH KEY FLD_04 = GS_HERDER_200-ARBPL2.
          IF SY-SUBRC EQ 0.
            READ TABLE GT_2360 ASSIGNING <LS_2360_TAN> WITH KEY ZVERS_NO = GV_ZVERS_NO
                                                            ZREQ_NO = LS_MOSU-ZREQ_NO
                                                            ZOPER_SEQ = LS_MOSU-ZOPER_SEQ
                                                            ARBPL+0(3) = LS_TANDEM2-FLD_08.
            IF SY-SUBRC EQ 0.
              <LS_2360_TAN>-LOEKZ = LV_CHK_TANDEM_TOBE.

              READ TABLE GT_2360_CHG ASSIGNING <LS_2360_CHG> WITH KEY ZVERS_NO = GV_ZVERS_NO
                                                                      ZREQ_NO = LS_MOSU-ZREQ_NO
                                                                      ZOPER_SEQ = LS_MOSU-ZOPER_SEQ
                                                                      BINARY SEARCH.
              IF SY-SUBRC EQ 0.
                MOVE-CORRESPONDING <LS_2360_TAN> TO <LS_2360_CHG>.
              ELSE.
                INSERT INITIAL LINE INTO GT_2360_CHG  INDEX SY-TABIX ASSIGNING <LS_2360_CHG>.
                MOVE-CORRESPONDING <LS_2360_TAN> TO <LS_2360_CHG>.
              ENDIF.

            ENDIF.
          ENDIF.
        ELSEIF LV_CHK_TANDEM_ASIS = ABAP_TRUE AND LV_CHK_TANDEM_TOBE IS INITIAL.
          READ TABLE GT_2360 ASSIGNING <LS_2360_TAN> WITH KEY ZVERS_NO = GV_ZVERS_NO
                                                          ZREQ_NO = LS_MOSU-ZREQ_NO
                                                          ZOPER_SEQ = LV_CHK_ZOPER_SEQ.
          IF SY-SUBRC EQ 0.
            <LS_2360_TAN>-LOEKZ = LV_CHK_TANDEM_TOBE.

            READ TABLE GT_2360_CHG ASSIGNING <LS_2360_CHG> WITH KEY ZVERS_NO = GV_ZVERS_NO
                                                                    ZREQ_NO = LS_MOSU-ZREQ_NO
                                                                    ZOPER_SEQ = LV_CHK_ZOPER_SEQ
                                                                    BINARY SEARCH.
            IF SY-SUBRC EQ 0.
              MOVE-CORRESPONDING <LS_2360_TAN> TO <LS_2360_CHG>.
            ELSE.
              INSERT INITIAL LINE INTO GT_2360_CHG  INDEX SY-TABIX ASSIGNING <LS_2360_CHG>.
              MOVE-CORRESPONDING <LS_2360_TAN> TO <LS_2360_CHG>.
            ENDIF.

          ENDIF.

        ENDIF.

      ENDIF.

    ENDLOOP.

  ENDLOOP.

  PERFORM SET_DISP_DATA.
  PERFORM REFRESH_GRID USING GO_GRID_0101.
  PERFORM REFRESH_GRID USING GO_GRID_0102.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROCESS_CHECK_LINE_0102
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PROCESS_CHECK_LINE_0102 .

  DATA : LT_CELLS TYPE LVC_T_CENO.

  GO_GRID_0102->GET_SELECTED_CELLS_ID(
    IMPORTING
     ET_CELLS = LT_CELLS ).                " Cell IDs

  SORT LT_CELLS BY ROW_ID.
  DELETE ADJACENT DUPLICATES FROM LT_CELLS COMPARING ROW_ID.

  LOOP AT LT_CELLS INTO DATA(LS_CELLS).
    READ TABLE GT_MAIN_102 ASSIGNING FIELD-SYMBOL(<LS_MAIN>) INDEX LS_CELLS-ROW_ID.
    IF SY-SUBRC EQ 0.
      <LS_MAIN>-CHECK = ABAP_TRUE.
    ENDIF.
  ENDLOOP.

  PERFORM REFRESH_GRID USING GO_GRID_0102.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CONTEXT_MENU
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> SENDER
*&      --> E_OBJECT
*&---------------------------------------------------------------------*
FORM CONTEXT_MENU  USING     P_SENDER TYPE REF TO CL_GUI_ALV_GRID
                                         P_OBJECT TYPE REF TO CL_CTMENU.

  DATA : LT_CELLS TYPE LVC_T_CENO.
  DATA: LT_STD_FCODES TYPE UI_FUNCTIONS,
        LT_OWN_FCODES TYPE UI_FUNCTIONS.
  DATA : LV_TEXT TYPE GUI_TEXT.
  DATA : LV_CHK_EXIST.

  CASE P_SENDER.
    WHEN GO_GRID_0102.
      GO_GRID_0102->GET_SELECTED_CELLS_ID(
        IMPORTING
         ET_CELLS = LT_CELLS ).                " Cell IDs

      IF LT_CELLS[] IS INITIAL.
        RETURN.
      ENDIF.

      P_OBJECT->CLEAR( ).

      LOOP AT LT_CELLS INTO DATA(LS_CELLS).
        READ TABLE GT_MAIN_102 INTO DATA(LS_MAIN) INDEX LS_CELLS-ROW_ID.
        IF LS_MAIN-CHECK = ABAP_TRUE.
          LV_CHK_EXIST = ABAP_TRUE.
        ENDIF.

      ENDLOOP.

      IF LV_CHK_EXIST = ABAP_TRUE.
        LV_TEXT = '선택해제'.
        CALL METHOD P_OBJECT->ADD_FUNCTION
          EXPORTING
            FCODE = 'DECHECK_LINE'
            TEXT  = LV_TEXT.
      ELSE.
        LV_TEXT = '선택'.
        CALL METHOD P_OBJECT->ADD_FUNCTION
          EXPORTING
            FCODE = 'CHECK_LINE'
            TEXT  = LV_TEXT.
      ENDIF.
      CALL METHOD P_OBJECT->SHOW_FUNCTIONS
        EXPORTING
          FCODES = LT_OWN_FCODES.

      CALL METHOD CL_GUI_CFW=>FLUSH.

    WHEN OTHERS.
      RETURN.
  ENDCASE.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROCESS_DECHECK_LINE_0102
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PROCESS_DECHECK_LINE_0102 .

  DATA : LT_CELLS TYPE LVC_T_CENO.

  GO_GRID_0102->GET_SELECTED_CELLS_ID(
    IMPORTING
     ET_CELLS = LT_CELLS ).                " Cell IDs

  SORT LT_CELLS BY ROW_ID.
  DELETE ADJACENT DUPLICATES FROM LT_CELLS COMPARING ROW_ID.

  LOOP AT LT_CELLS INTO DATA(LS_CELLS).
    READ TABLE GT_MAIN_102 ASSIGNING FIELD-SYMBOL(<LS_MAIN>) INDEX LS_CELLS-ROW_ID.
    IF SY-SUBRC EQ 0.
      CLEAR <LS_MAIN>-CHECK.
    ENDIF.
  ENDLOOP.

  PERFORM REFRESH_GRID USING GO_GRID_0102.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form F4HELP_ARBPL
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F4HELP_ARBPL .

  DATA : LT_RETURN_TAB TYPE TABLE OF DDSHRETVAL,
         LS_RETURN_TAB LIKE LINE OF LT_RETURN_TAB.

  DATA : LV_OFFSET(6) TYPE N.
  DATA : LO_FLIEF TYPE REF TO DATA.

  DATA : LT_FIELD_TAB TYPE TABLE OF DFIES.
  DATA : LO_STRUCTDESCR TYPE REF TO CL_ABAP_STRUCTDESCR.

  DATA : LV_LINE       LIKE SY-STEPL,
         LT_DYNPFIELDS LIKE TABLE OF DYNPREAD.

  FREE LO_FLIEF.
  CREATE DATA LO_FLIEF LIKE GS_F4_ARBPL.

  LO_STRUCTDESCR ?= CL_ABAP_STRUCTDESCR=>DESCRIBE_BY_DATA_REF( LO_FLIEF ).
  LT_FIELD_TAB = CL_SALV_DATA_DESCR=>READ_STRUCTDESCR( LO_STRUCTDESCR ).

  CLEAR LV_OFFSET.
  LOOP AT LT_FIELD_TAB ASSIGNING FIELD-SYMBOL(<LS_FIELD_TAB>).

    CASE <LS_FIELD_TAB>-FIELDNAME.
      WHEN 'ARBPL'.
        <LS_FIELD_TAB>-REPTEXT  = '작업장'.
      WHEN 'KTEXT'.
        <LS_FIELD_TAB>-REPTEXT  = '작업장 내역'.
      WHEN 'TANDEM'.
        <LS_FIELD_TAB>-REPTEXT  = '탄뎀공정'.
      WHEN 'ZTIME'.
        <LS_FIELD_TAB>-REPTEXT  = '표준 작업시간'.
      WHEN 'ZUNIT'.
        <LS_FIELD_TAB>-REPTEXT  = '단위'.
    ENDCASE.

    <LS_FIELD_TAB>-OFFSET = LV_OFFSET.
    IF <LS_FIELD_TAB>-FIELDNAME = 'ZTIME'.
      LV_OFFSET = LV_OFFSET + 18.
    ELSE.
      LV_OFFSET = LV_OFFSET + <LS_FIELD_TAB>-INTLEN.
    ENDIF.
  ENDLOOP.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'  "F4 창 띄움
    EXPORTING
      RETFIELD        = 'ARBPL'
      DYNPROFIELD     = 'GS_HERDER_200-ARBPL2'           "F4누른 필드->DEPT_CD
      VALUE_ORG       = 'S'                      "가져오는 엔트리가 다수일 경우인 것 같음. 다수일 경우 C로 하면 F4 안뜸
      WINDOW_TITLE    = '작업장 조회'   "Search Help 타이틀
      DISPLAY         = 'F'
    TABLES
      FIELD_TAB       = LT_FIELD_TAB
      VALUE_TAB       = GT_F4_ARBPL                  "부서코드, 부서명 가져온 인터널 테이블
      RETURN_TAB      = LT_RETURN_TAB            "F4에서 선택한 값이 들어옴
    EXCEPTIONS
      PARAMETER_ERROR = 1
      NO_VALUES_FOUND = 2
      OTHERS          = 3.

  READ TABLE LT_RETURN_TAB INTO LS_RETURN_TAB INDEX 1.
  IF SY-SUBRC EQ 0.

    REFRESH LT_DYNPFIELDS.
    PERFORM GET_STEPL USING LV_LINE.

*  구매처
    APPEND INITIAL LINE TO LT_DYNPFIELDS ASSIGNING FIELD-SYMBOL(<LS_DYNPFIELDS>).
    <LS_DYNPFIELDS>-FIELDNAME = 'GS_HERDER_200-ARBPL2'.
    <LS_DYNPFIELDS>-STEPL = LV_LINE.
    <LS_DYNPFIELDS>-FIELDVALUE = LS_RETURN_TAB-FIELDVAL.

    READ TABLE GT_F4_ARBPL INTO DATA(LS_ARBPL) WITH KEY ARBPL = LS_RETURN_TAB-FIELDVAL..

*  구매처 내역
    APPEND INITIAL LINE TO LT_DYNPFIELDS ASSIGNING <LS_DYNPFIELDS>.
    <LS_DYNPFIELDS>-FIELDNAME = 'GS_HERDER_200-KTEXT2'.
    <LS_DYNPFIELDS>-STEPL = LV_LINE.
    <LS_DYNPFIELDS>-FIELDVALUE = LS_ARBPL-KTEXT.

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
*& Form MAKE_F4_ARBPL
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LS_MATNR_LOW
*&---------------------------------------------------------------------*
FORM MAKE_F4_ARBPL  USING    PV_MATNR TYPE MATNR.

  REFRESH GT_F4_ARBPL.

  LOOP AT GT_ROUTING INTO DATA(LS_ROUTING) WHERE MATNR = PV_MATNR.
    CLEAR GS_F4_ARBPL.
    GS_F4_ARBPL-ARBPL = LS_ROUTING-ARBPL.
    GS_F4_ARBPL-KTEXT = LS_ROUTING-KTEXT.

    IF LS_ROUTING-ARBPL IN GT_TANDEM_ARBPL.
      GS_F4_ARBPL-TANDEM = ABAP_TRUE.
    ENDIF.
    GS_F4_ARBPL-ZTIME = LS_ROUTING-VGW02.
    GS_F4_ARBPL-ZUNIT = LS_ROUTING-VGE02.
    APPEND GS_F4_ARBPL TO GT_F4_ARBPL.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROC_CONFIRM_ARBPL
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PROC_CONFIRM_ARBPL .

  IF GS_HERDER_200-ARBPL2 IS INITIAL.
    MESSAGE I003 WITH TEXT-M06. " 작업장 입력되지 안았습니다.
    RETURN.
  ENDIF.

  IF GS_HERDER_200-ARBPL2 = GS_HERDER_200-ARBPL.
    MESSAGE I003 WITH TEXT-M07. " 이전 작업장과 동일합니다.
    RETURN.
  ENDIF.

  READ TABLE GT_F4_ARBPL TRANSPORTING NO FIELDS WITH KEY ARBPL = GS_HERDER_200-ARBPL2.
  IF SY-SUBRC NE 0.
    MESSAGE I003 WITH TEXT-M08. " 자재에 유효한 작업장이 아닙니다.
    RETURN.
  ENDIF.

  GS_HERDER_200-CHK_CONFIRM = ABAP_TRUE.
  LEAVE TO SCREEN 0.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_LAST_DAY_OF_MONTH
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- <LS_DUDATE>_HIGH
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
