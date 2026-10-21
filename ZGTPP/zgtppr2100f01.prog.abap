*&---------------------------------------------------------------------*
*& Include          ZGTPPR2100F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form get_parameter_description
*&---------------------------------------------------------------------*
FORM GET_PARAMETER_DESCRIPTION .
* SPG
  IF NOT P_SPGCD IS INITIAL.
    CLEAR ZPPT0107.
    SELECT SINGLE DESCR INTO P_DESCR FROM ZPPT0107
                                     WHERE SPGCD EQ P_SPGCD.
  ELSE.
    CLEAR P_DESCR.
  ENDIF.

* 플랜트명
  IF NOT P_WERKS IS INITIAL.
    CLEAR T001W.
    SELECT SINGLE NAME1 INTO P_NAME1 FROM T001W
                                     WHERE WERKS EQ P_WERKS.
  ELSE.
    CLEAR P_NAME1.
  ENDIF.

* 월간계획유형
  IF NOT P_SIMTY IS INITIAL.
    SELECT SINGLE DDTEXT INTO P_SIMDEC
             FROM DD07T
            WHERE DOMNAME = 'ZGTDSIMTY'
               AND DOMVALUE_L EQ P_SIMTY.
  ELSE.
    CLEAR P_SIMDEC.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form modify_first_screen
*&---------------------------------------------------------------------*
FORM MODIFY_FIRST_SCREEN .

  LOOP AT SCREEN.
    IF SCREEN-GROUP1 = 'M1'.
      SCREEN-INPUT = 0.
      SCREEN-INTENSIFIED = 1.
      MODIFY SCREEN.
    ENDIF.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form authority_checking_proc
*&---------------------------------------------------------------------*
FORM AUTHORITY_CHECKING_PROC .
*& 플랜트에 대한 권한체크
  AUTHORITY-CHECK OBJECT 'ZPP_WERKS'
  ID 'WERKS'  FIELD P_WERKS.

  IF SY-SUBRC <> 0.
    "플랜트[P_WERKS] 작업권한을 확인하세요.
    MESSAGE E006 WITH TEXT-005 P_WERKS TEXT-006.

  ELSE.
*& MRP관리자에 대한 권한체크
    AUTHORITY-CHECK OBJECT 'ZPP_SPGCD'
    ID 'WERKS'  FIELD P_WERKS
    ID 'SPGCD'  FIELD P_SPGCD.

    IF SY-SUBRC <> 0.

      MESSAGE E006 WITH TEXT-007 P_SPGCD TEXT-006.

    ENDIF.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_data
*&---------------------------------------------------------------------*
FORM GET_DATA .

  CLEAR : GS_DATA, GT_DATA, GS_BASE, GT_BASE, S_SPMON, GV_MON_CNT,
          GV_DATE_S, GV_DATE_E, GS_MONTH, GT_MONTH, GV_CNT.
* 동적 필드 구현을 위한 기간 개월 수 파악.
  READ TABLE S_SPMON INDEX 1.
  IF S_SPMON-HIGH IS NOT INITIAL.

    GV_DATE_S = S_SPMON-LOW && '01'.
    GV_DATE_E = S_SPMON-HIGH && '01'.
    CALL FUNCTION 'FIMA_DAYS_AND_MONTHS_AND_YEARS'
      EXPORTING
        I_DATE_FROM = GV_DATE_S
        I_DATE_TO   = GV_DATE_E
      IMPORTING
        E_MONTHS    = GV_MON_CNT.
    GV_MON_CNT = GV_MON_CNT + 1.

    DO GV_MON_CNT TIMES.

      GV_CNT = GV_CNT + 1.
      IF GV_CNT <> 1.
        CALL FUNCTION 'RE_ADD_MONTH_TO_DATE'
          EXPORTING
            MONTHS  = '1'
            OLDDATE = GV_DATE_S
          IMPORTING
            NEWDATE = GV_DATE_S.
      ENDIF.

      GS_MONTH-MONTH = GV_DATE_S+0(6).
      APPEND GS_MONTH TO GT_MONTH.

    ENDDO.

  ELSE.

    GV_MON_CNT = 1.
    GS_MONTH-MONTH = S_SPMON-LOW.
    APPEND GS_MONTH TO GT_MONTH.

  ENDIF.
* 72개월 초과시 오류 메시지 출력
  IF GV_MON_CNT > 72.
    GV_ERROR = 'X'.
    MESSAGE S000 DISPLAY LIKE 'E' WITH TEXT-E03.
  ENDIF.

  CHECK GV_ERROR IS INITIAL.
* 생산 계획 전체 데이터 및 ALV 고정 테이블 취합
  PERFORM GET_BASIC_DATA.
* 동적 필드 포함 ALV 테이블 구성
  PERFORM CREATE_DYNAMIC_ALV_TABLE.

  PERFORM MAKE_DISP_DATA.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_basic_data
*&---------------------------------------------------------------------*
FORM GET_BASIC_DATA .

  DATA : LV_QUANTITY_DP LIKE ZGTCVSALESPLAN-QUANTITY_DP.
  DATA : LV_ZPJNO TYPE ZSD0106T-ZPJNO.

  SELECT DISTINCT A~PLNID, A~SPEC, A~ZPJNO, B~MEINS, B~GONG_SEQ,
                  B~GONG_CD, B~MATNR AS MATNR_FH, C~MAKTX, B~SIMNO,
                  B~SIMVR, B~ZSPMON, B~MENGE
    INTO CORRESPONDING FIELDS OF TABLE @GT_DATA
    FROM ZGTPPT2080 AS A INNER JOIN ZGTPPT2100 AS B
      ON  A~WERKS EQ B~WERKS
      AND A~SPGCD EQ B~SPGCD
      AND A~PLNID EQ B~PLNID
      AND A~DELFL EQ @SPACE
      LEFT OUTER JOIN MAKT AS C
      ON  B~MATNR EQ C~MATNR
      AND C~SPRAS EQ @SY-LANGU
      WHERE A~WERKS   EQ @P_WERKS
        AND A~SPGCD   EQ @P_SPGCD
        AND A~SPEC    IN @S_SPEC
        AND A~ZPJNO   IN @S_PJNO
        AND B~GONG_CD IN @S_GONG
        AND B~ZSPMON  IN @S_SPMON
        AND B~SIMTY   EQ @P_SIMTY.

  SORT GT_DATA BY SPEC ZPJNO BASEMONTH MATNR_S GONG_SEQ.

  DATA(LT_DATA) = GT_DATA[].
  SORT LT_DATA BY SPEC ZPJNO PLNID.
  DELETE ADJACENT DUPLICATES FROM LT_DATA COMPARING SPEC ZPJNO PLNID.

  IF LT_DATA[] IS NOT INITIAL.

    SELECT SPEC, ZPJNO, ZPTXT, BASEMONTH, VRKME, QUANTITY_DP, MATNR, SPART
      INTO TABLE @DATA(LT_PLAN)
      FROM ZGTCVSALESPLAN
      FOR ALL ENTRIES IN @LT_DATA
      WHERE SPEC  EQ @LT_DATA-SPEC
        AND ZPJNO EQ @LT_DATA-ZPJNO
        AND PLNID EQ @LT_DATA-PLNID.
*        AND basemonth EQ ( SELECT MIN( basemonth )
*                             FROM zgtcvsalesplan
*                             WHERE spec  EQ @lt_data-spec
*                               AND zpjno EQ @lt_data-zpjno
*                               AND plnid EQ @lt_data-plnid ).

  ENDIF.

  LOOP AT GT_DATA INTO GS_DATA.

    CLEAR GS_BASE.
    MOVE-CORRESPONDING GS_DATA TO GS_BASE.
    GS_BASE-SIMUL = GS_DATA-SIMNO && GS_DATA-SIMVR.
    APPEND GS_BASE TO GT_BASE.

  ENDLOOP.

  SORT GT_BASE BY SPEC ZPJNO BASEMONTH MATNR_S GONG_SEQ.
  DELETE ADJACENT DUPLICATES FROM GT_BASE
         COMPARING SPEC ZPJNO BASEMONTH MATNR_S GONG_SEQ.
* 판매계획 반영
  LOOP AT GT_BASE INTO GS_BASE.

    GV_TABIX = SY-TABIX.

    CLEAR LV_QUANTITY_DP.
    LOOP AT LT_PLAN INTO DATA(LS_PLAN)
                    WHERE SPEC  EQ GS_BASE-SPEC
                      AND ZPJNO EQ GS_BASE-ZPJNO.

* 프로젝트내역 추가
      IF LS_PLAN-ZPTXT IS INITIAL AND LS_PLAN-ZPJNO IS NOT INITIAL.
        TRY.
            CLEAR LV_ZPJNO.
            LV_ZPJNO = LS_PLAN-ZPJNO && '%'.
            SELECT SINGLE ZPTXT FROM ZSD0106T
              INTO GS_BASE-ZPTXT
              WHERE ZPJNO LIKE LV_ZPJNO
                AND SPART = LS_PLAN-SPART.

          CATCH CX_ROOT.
        ENDTRY.
      ELSE.
        GS_BASE-ZPTXT = LS_PLAN-ZPTXT.
      ENDIF.

*      GS_BASE-ZPTXT       = LS_PLAN-ZPTXT.
      GS_BASE-BASEMONTH   = LS_PLAN-BASEMONTH+0(4) && '.' &&
                            LS_PLAN-BASEMONTH+4(2).
      GS_BASE-VRKME       = LS_PLAN-VRKME.
      GS_BASE-MATNR_S     = LS_PLAN-MATNR.
      LV_QUANTITY_DP      = LV_QUANTITY_DP + LS_PLAN-QUANTITY_DP.
    ENDLOOP.

    IF SY-SUBRC <> 0.
      DELETE GT_BASE INDEX GV_TABIX.
    ELSE.
      WRITE LV_QUANTITY_DP TO GS_BASE-QUANTITY_DP UNIT GS_BASE-VRKME.
      CONDENSE GS_BASE-QUANTITY_DP NO-GAPS.
      MODIFY GT_BASE FROM GS_BASE INDEX GV_TABIX.
    ENDIF.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form create_dynamic_alv_table
*&---------------------------------------------------------------------*
FORM CREATE_DYNAMIC_ALV_TABLE .

  PERFORM SET_DISP_TABLE.

  PERFORM CREATE_DYNAMIC_TABLE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_disp_table
*&---------------------------------------------------------------------*
FORM SET_DISP_TABLE .

  DATA : LT_FCAT TYPE SLIS_T_FIELDCAT_ALV.
  DATA : LV_COL_POS  TYPE I,
         LV_COL_POS2 TYPE I.
  DATA : LV_TEXT(100),
         LV_KTEXT(40).
  DATA : LS_DFIES_TAB	LIKE DFIES,
         LT_DFIES_TAB	LIKE TABLE OF	DFIES.
  DATA : LV_TABNAME	  TYPE DDOBJNAME,
         LV_FIELDNAME	TYPE DFIES-FIELDNAME.
  DATA : LV_CNT(2) TYPE I.

  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      I_PROGRAM_NAME     = SY-REPID
      I_INTERNAL_TABNAME = 'GS_BASE'
      I_INCLNAME         = 'ZGTPPR2100TOP'
      I_BYPASSING_BUFFER = 'X'
    CHANGING
      CT_FIELDCAT        = LT_FCAT.

  CALL FUNCTION 'LVC_TRANSFER_FROM_SLIS'
    EXPORTING
      IT_FIELDCAT_ALV = LT_FCAT
    IMPORTING
      ET_FIELDCAT_LVC = GT_FIELDCAT_0100[]
    TABLES
      IT_DATA         = GT_BASE.
* MONTH 필드 카탈로그 정의
  LV_COL_POS  = 100.
  LOOP AT GT_MONTH INTO GS_MONTH.

    LV_KTEXT = GS_MONTH-MONTH+0(4) && '.' && GS_MONTH-MONTH+4(2).
    APPEND INITIAL LINE TO GT_FIELDCAT_0100
                        ASSIGNING FIELD-SYMBOL(<LS_FCAT>).
    ADD 1 TO LV_COL_POS.
    <LS_FCAT>-COL_POS    = LV_COL_POS.
    <LS_FCAT>-FIELDNAME  = GS_MONTH-MONTH.
    <LS_FCAT>-REPTEXT    = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP
                         = LV_KTEXT.
    <LS_FCAT>-JUST       = 'R'.
    <LS_FCAT>-DATATYPE   = 'QUAN'.
    <LS_FCAT>-DD_OUTLEN  = '12'.
    <LS_FCAT>-DECIMALS   = '3'.
    <LS_FCAT>-QFIELDNAME = 'MEINS'.
    <LS_FCAT>-OUTPUTLEN = 11.


  ENDLOOP.
* 기본 필드 카탈로그 정의
  LOOP AT GT_FIELDCAT_0100 ASSIGNING <LS_FCAT>.
    CLEAR <LS_FCAT>-KEY.
    CASE <LS_FCAT>-FIELDNAME.
      WHEN 'SPEC'. "규격
        <LS_FCAT>-COL_POS = 1.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP
                          = TEXT-F01.
        <LS_FCAT>-JUST    = 'L'.
*        <LS_FCAT>-KEY     = ABAP_TRUE.
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
        <LS_FCAT>-OUTPUTLEN = 15.
      WHEN 'ZPJNO'. "프로젝트 No.
        <LS_FCAT>-COL_POS = 2.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP
                          = TEXT-F02.
        <LS_FCAT>-JUST    = 'C'.
*        <LS_FCAT>-KEY     = ABAP_TRUE.
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
        <LS_FCAT>-OUTPUTLEN = 10.
      WHEN 'ZPTXT'. "프로젝트명
        <LS_FCAT>-COL_POS = 3.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP
                          = TEXT-F03.
        <LS_FCAT>-JUST    = 'L'.
*        <LS_FCAT>-KEY     = ABAP_TRUE.
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
        <LS_FCAT>-OUTPUTLEN = 15.
      WHEN 'BASEMONTH'. "판매계획월
        CLEAR : <LS_FCAT>-REF_TABLE, <LS_FCAT>-REF_FIELD.
        <LS_FCAT>-COL_POS = 4.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP
                          = TEXT-F04.
        <LS_FCAT>-JUST    = 'C'.
*        <LS_FCAT>-KEY     = ABAP_TRUE.
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
        <LS_FCAT>-OUTPUTLEN = 7.
      WHEN 'VRKME'. "판매단위
        <LS_FCAT>-COL_POS = 5.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP
                          = TEXT-F05.
        <LS_FCAT>-JUST    = 'C'.
*        <LS_FCAT>-KEY     = ABAP_TRUE.
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
        <LS_FCAT>-OUTPUTLEN = 5.
      WHEN 'QUANTITY_DP'. "판매계획량
        CLEAR : <LS_FCAT>-REF_TABLE, <LS_FCAT>-REF_FIELD.
        <LS_FCAT>-COL_POS    = 6.
        <LS_FCAT>-REPTEXT    = <LS_FCAT>-COLTEXT
                             = <LS_FCAT>-TOOLTIP = TEXT-F06.
        <LS_FCAT>-JUST       = 'R'.
*        <LS_FCAT>-KEY        = ABAP_TRUE.
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
        <LS_FCAT>-DD_OUTLEN  = '13'.
        <LS_FCAT>-DECIMALS   = '3'.
        <LS_FCAT>-QFIELDNAME = 'VRKME'.
        <LS_FCAT>-OUTPUTLEN = 12.
      WHEN 'MATNR_S'. "판매계획제품
        <LS_FCAT>-COL_POS = 7.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP
                          = TEXT-F07.
        <LS_FCAT>-JUST    = 'C'.
*        <LS_FCAT>-KEY     = ABAP_TRUE.
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
        <LS_FCAT>-NO_ZERO = ABAP_TRUE.
        <LS_FCAT>-OUTPUTLEN = 10.
      WHEN 'MEINS'. "생산단위
        <LS_FCAT>-COL_POS = 8.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP
                          = TEXT-F08.
        <LS_FCAT>-JUST    = 'C'.
*        <LS_FCAT>-KEY     = ABAP_TRUE.
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
        <LS_FCAT>-OUTPUTLEN = 5.
      WHEN 'GONG_CD'. "공정
        <LS_FCAT>-COL_POS = 9.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP
                          = TEXT-F09.
        <LS_FCAT>-JUST    = 'C'.
*        <LS_FCAT>-KEY     = ABAP_TRUE.
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
        <LS_FCAT>-OUTPUTLEN = 5.
      WHEN 'MATNR_FH'. "완/반제품
        <LS_FCAT>-COL_POS = 10.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP
                          = TEXT-F10.
        <LS_FCAT>-JUST    = 'C'.
        <LS_FCAT>-NO_ZERO = ABAP_TRUE.
        <LS_FCAT>-OUTPUTLEN = 10.
      WHEN 'MAKTX'. "제품명
        <LS_FCAT>-COL_POS = 11.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP
                          = TEXT-F11.
        <LS_FCAT>-JUST    = 'L'.
        <LS_FCAT>-OUTPUTLEN = 15.
      WHEN 'SIMUL'. "확정시뮬레이션
        <LS_FCAT>-COL_POS = 12.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP
                          = TEXT-F12.
        <LS_FCAT>-JUST = 'C'.
        <LS_FCAT>-NO_OUT = 'X'.
        <LS_FCAT>-OUTPUTLEN = 12.
      WHEN 'HAP'. "생산계획량 합계
        CLEAR : <LS_FCAT>-REF_TABLE, <LS_FCAT>-REF_FIELD.
        <LS_FCAT>-COL_POS    = 13.
        <LS_FCAT>-REPTEXT    = <LS_FCAT>-COLTEXT
                             = <LS_FCAT>-TOOLTIP = TEXT-F13.
        <LS_FCAT>-JUST       = 'R'.
        <LS_FCAT>-DD_OUTLEN  = '13'.
        <LS_FCAT>-DECIMALS   = '3'.
        <LS_FCAT>-QFIELDNAME = 'MEINS'.
        <LS_FCAT>-OUTPUTLEN = 12.
      WHEN 'GONG_SEQ'.
        <LS_FCAT>-NO_OUT = 'X'.
    ENDCASE.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form toolbar_pros
*&---------------------------------------------------------------------*
FORM TOOLBAR_PROS USING PO_SENDER
                        PO_OBJECT TYPE REF TO CL_ALV_EVENT_TOOLBAR_SET
                        R_INTERACTIVE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form user_command_pros
*&---------------------------------------------------------------------*
FORM USER_COMMAND_PROS USING PO_SENDER TYPE REF TO CL_GUI_ALV_GRID
                             PV_UCOMM.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form data_changed
*&---------------------------------------------------------------------*
FORM DATA_CHANGED USING P_SENDER  TYPE REF TO CL_GUI_ALV_GRID
                        PO_DATA_CHANGED TYPE REF TO
                        CL_ALV_CHANGED_DATA_PROTOCOL
                        PE_ONF4
                        PE_UCOMM.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form double_click
*&---------------------------------------------------------------------*
FORM DOUBLE_CLICK USING P_SENDER TYPE REF TO CL_GUI_ALV_GRID
                        P_ROW TYPE LVC_S_ROW
                        P_COLUMN TYPE LVC_S_COL.

  RANGES : LR_SPEC FOR ZGTPPT2080-SPEC.

  CASE P_SENDER.
    WHEN GO_GRID_0100.

      IF P_COLUMN = 'HAP'.

        READ TABLE <GT_MAIN_DISP_100> ASSIGNING FIELD-SYMBOL(<LS_DATA>)
                                      INDEX P_ROW-INDEX.
        CLEAR GS_BASE.
        MOVE-CORRESPONDING <LS_DATA> TO GS_BASE.
        IF GS_BASE-HAP IS NOT INITIAL.

          CLEAR : LR_SPEC, LR_SPEC[].
          LR_SPEC-SIGN   = 'I'.
          LR_SPEC-OPTION = 'EQ'.
          LR_SPEC-LOW    = GS_BASE-SPEC.
          APPEND LR_SPEC.

          SUBMIT ZGTPPR2080 WITH P_WERKS EQ P_WERKS
                            WITH P_SPGCD EQ P_SPGCD
                            WITH S_SPEC  IN LR_SPEC
                            WITH S_SPMON IN S_SPMON
                            WITH P_RAD1  EQ ' '
                            WITH P_RAD2  EQ ' '
                            WITH P_RAD3  EQ 'X'
*                          VIA SELECTION-SCREEN
                            AND RETURN.

        ENDIF.

      ENDIF.

  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form alv_top_of_page
*&---------------------------------------------------------------------*
FORM ALV_TOP_OF_PAGE USING PO_SENDER TYPE REF TO CL_GUI_ALV_GRID
                           PV_DYNDOC_ID TYPE REF TO CL_DD_DOCUMENT.

  CASE PO_SENDER.
    WHEN GO_GRID_0100.
      PERFORM SET_TITLE_0100 CHANGING PV_DYNDOC_ID.
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_title_0100
*&---------------------------------------------------------------------*
FORM SET_TITLE_0100 CHANGING PV_DYNDOC_ID TYPE REF TO CL_DD_DOCUMENT.

  DATA : LV_TEXT(255) TYPE C.
  DATA : LV_NAME1 TYPE T001W-NAME1,
         LV_DESCR TYPE ZPPT0107-DESCR.
* 플랜트명
  IF P_WERKS IS NOT INITIAL.
    SELECT SINGLE NAME1 FROM T001W
                        WHERE WERKS EQ @P_WERKS
                        INTO @LV_NAME1.
  ENDIF.

  CONCATENATE TEXT-008 P_WERKS ', ' LV_NAME1 INTO LV_TEXT
    SEPARATED BY SPACE.
  "텍스트 추가
  CALL METHOD PV_DYNDOC_ID->ADD_TEXT
    EXPORTING
      TEXT         = LV_TEXT
      SAP_FONTSIZE = '20'.

  CALL METHOD PV_DYNDOC_ID->NEW_LINE.

  CLEAR S_SPMON.
  READ TABLE S_SPMON INDEX 1.
  CONCATENATE TEXT-009
              S_SPMON-LOW+0(4) '.' S_SPMON-LOW+4(2) '~ '
              S_SPMON-HIGH+0(4) '.' S_SPMON-HIGH+4(2)
         INTO LV_TEXT SEPARATED BY SPACE.
  "텍스트 추가
  CALL METHOD PV_DYNDOC_ID->ADD_TEXT
    EXPORTING
      TEXT         = LV_TEXT
      SAP_FONTSIZE = '20'.

  CALL METHOD PV_DYNDOC_ID->NEW_LINE.
  "위쪽에 추가한 텍스트 출력
  CALL METHOD GO_DD_DOCU_0100->DISPLAY_DOCUMENT
    EXPORTING
      PARENT = GO_CONTAIN_TOP_0100.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form onf4_proc
*&---------------------------------------------------------------------*
FORM ONF4_PROC USING PV_FIELDNAME  TYPE LVC_FNAME
                     PV_FIELDVALUE TYPE LVC_VALUE
                     PS_ROW_NO     TYPE LVC_S_ROID
                     PR_EVENT_DATA TYPE REF TO CL_ALV_EVENT_DATA
                     PT_BAD_CELLS  TYPE LVC_T_MODI
                     PV_DISPLAY    TYPE CHAR01.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form create_dynamic_table
*&---------------------------------------------------------------------*
FORM CREATE_DYNAMIC_TABLE .

  FREE : GT_MAIN_DISP_100.

  CALL METHOD CL_ALV_TABLE_CREATE=>CREATE_DYNAMIC_TABLE
    EXPORTING
      I_STYLE_TABLE             = ABAP_TRUE
      IT_FIELDCATALOG           = GT_FIELDCAT_0100
    IMPORTING
      EP_TABLE                  = GT_MAIN_DISP_100
    EXCEPTIONS
      GENERATE_SUBPOOL_DIR_FULL = 1
      OTHERS                    = 2.

  IF SY-SUBRC <> 0.
    MESSAGE S005 DISPLAY LIKE 'E' WITH TEXT-E01 TEXT-E02.
    LEAVE LIST-PROCESSING.
  ELSE.
    ASSIGN GT_MAIN_DISP_100->* TO <GT_MAIN_DISP_100>.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form make_disp_data
*&---------------------------------------------------------------------*
FORM MAKE_DISP_DATA .

  DATA : LS_DATA TYPE REF TO DATA.
  DATA : LT_DATA TYPE REF TO DATA.

  REFRESH <GT_MAIN_DISP_100>.

  CREATE DATA LS_DATA LIKE LINE OF <GT_MAIN_DISP_100>.
  ASSIGN LS_DATA->* TO <GS_LINE>.
  CREATE DATA LT_DATA LIKE <GT_MAIN_DISP_100>.
  ASSIGN LT_DATA->* TO <GT_LINE>.

  LOOP AT GT_BASE INTO GS_BASE.

    CLEAR : <GS_LINE>, <GT_LINE>.
* 고정 필드 값 반영
    MOVE-CORRESPONDING GS_BASE TO <GS_LINE>.
    APPEND INITIAL LINE TO <GT_LINE> ASSIGNING <GS_MAIN>.
    MOVE-CORRESPONDING <GS_LINE> TO <GS_MAIN>.

    __ASSIGN_FIELD2 'HAP'.
* 월별 생산계획 반영
    LOOP AT GT_DATA INTO GS_DATA WHERE SPEC     = GS_BASE-SPEC
                                   AND ZPJNO    = GS_BASE-ZPJNO
                                   AND GONG_CD  = GS_BASE-GONG_CD
                                   AND MATNR_FH = GS_BASE-MATNR_FH.

      CLEAR : GV_FIELDNAME.
      GV_FIELDNAME = GS_DATA-ZSPMON.
      __ASSIGN_FIELD  GV_FIELDNAME.

      <GV_FIELD>  = <GV_FIELD>  + GS_DATA-MENGE.
      <GV_FIELD2> = <GV_FIELD2> + GS_DATA-MENGE.

    ENDLOOP.

    APPEND LINES OF <GT_LINE> TO <GT_MAIN_DISP_100>.

  ENDLOOP.

  GV_COLUMNS = 'SPEC,ZPJNO,BASEMONTH,MATNR_S,GONG_SEQ'.

  SPLIT GV_COLUMNS AT `,` INTO TABLE DATA(LT_COLUMN_TAB).
  DATA(LT_ORDER) = VALUE ABAP_SORTORDER_TAB(
                  FOR WA IN LT_COLUMN_TAB
                 ( NAME = CONDENSE( TO_UPPER( WA ) ) ) ).

  TRY.
      SORT <GT_MAIN_DISP_100> BY (LT_ORDER).
    CATCH CX_SY_DYN_TABLE_ILL_COMP_VAL.

  ENDTRY.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_object_grid_0100
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
      ROWS    = 2
      COLUMNS = 1.

  GO_SPLITTER_0100->SET_ROW_HEIGHT(
    EXPORTING
      ID                =    1              " Row ID
      HEIGHT            =    10 ).             " Height
* top 컨테이너
  CALL METHOD GO_SPLITTER_0100->GET_CONTAINER
    EXPORTING
      ROW       = 1
      COLUMN    = 1
    RECEIVING
      CONTAINER = GO_CONTAIN_TOP_0100.
* bottom 컨테이너
  CALL METHOD GO_SPLITTER_0100->GET_CONTAINER
    EXPORTING
      ROW       = 2
      COLUMN    = 1
    RECEIVING
      CONTAINER = GO_CONTAIN_0100.

  CREATE OBJECT GO_GRID_0100
    EXPORTING
      I_PARENT      = GO_CONTAIN_0100
      I_APPL_EVENTS = ABAP_TRUE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form event_handler_register
*&---------------------------------------------------------------------*
FORM EVENT_HANDLER_REGISTER USING PO_GRID TYPE REF TO CL_GUI_ALV_GRID.

  IF GO_EVENT_HANDLER IS NOT BOUND.
    CREATE OBJECT GO_EVENT_HANDLER.
  ENDIF.
*// Event Handler ##
  CASE PO_GRID.
    WHEN GO_GRID_0100.
      SET HANDLER GO_EVENT_HANDLER->HANDLE_TOP_OF_PAGE  FOR PO_GRID.
      SET HANDLER GO_EVENT_HANDLER->HANDLE_TOOLBAR      FOR PO_GRID.
      SET HANDLER GO_EVENT_HANDLER->HANDLE_USER_COMMAND FOR PO_GRID.
      SET HANDLER GO_EVENT_HANDLER->HANDLE_DOUBLE_CLICK FOR PO_GRID.
      SET HANDLER GO_EVENT_HANDLER->HANDLE_DATA_CHANGED FOR PO_GRID.
      SET HANDLER GO_EVENT_HANDLER->HANDLE_ONF4         FOR PO_GRID.
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_layout_grid_0100
*&---------------------------------------------------------------------*
FORM SET_LAYOUT_GRID_0100 .

  CLEAR GS_LAYOUT_0100.
*  GS_LAYOUT_0100-CWIDTH_OPT = ABAP_TRUE.
  GS_LAYOUT_0100-NO_ROWINS  = ABAP_TRUE.
  GS_LAYOUT_0100-STYLEFNAME = 'XYZSTYLEZYX'.
  GS_LAYOUT_0100-SEL_MODE   = 'D'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_cell_attribute_grid_0100
*&---------------------------------------------------------------------*
FORM SET_CELL_ATTRIBUTE_GRID_0100 .

  DATA : LT_CELLTAB TYPE LVC_T_STYL.
  DATA : LS_CELLTAB TYPE LVC_S_STYL.
  FIELD-SYMBOLS <LT_CELLTAB> TYPE ANY.

  LOOP AT <GT_MAIN_DISP_100> ASSIGNING FIELD-SYMBOL(<LS_DATA>).
    REFRESH LT_CELLTAB.

    LOOP AT GT_FIELDCAT_0100 ASSIGNING FIELD-SYMBOL(<LS_FCAT>).
      CASE <LS_FCAT>-FIELDNAME.
        WHEN 'SPEC' OR 'ZPJNO' OR 'ZPTXT' OR 'BASEMONTH' OR 'VRKME'
          OR 'QUANTITY_DP' OR 'MATNR_S' OR 'MEINS' OR 'GONG_CD'.
          CLEAR LS_CELLTAB.
          LS_CELLTAB-FIELDNAME = <LS_FCAT>-FIELDNAME.
          LS_CELLTAB-STYLE = ALV_STYLE_COLOR_INT_KEY.
          INSERT LS_CELLTAB INTO TABLE LT_CELLTAB.
      ENDCASE.
    ENDLOOP.


    IF <LT_CELLTAB> IS ASSIGNED. UNASSIGN <LT_CELLTAB>. ENDIF.
    ASSIGN COMPONENT 'XYZSTYLEZYX' OF STRUCTURE <LS_DATA> TO <LT_CELLTAB>.
    IF <LT_CELLTAB> IS ASSIGNED.
      <LT_CELLTAB> = LT_CELLTAB.
    ENDIF.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form exclude_of_toolbar_grid_0100
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
            CL_GUI_ALV_GRID=>MC_FC_LOC_PASTE_NEW_ROW.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form add_exclude_toolbar_button
*&---------------------------------------------------------------------*
FORM ADD_EXCLUDE_TOOLBAR_BUTTON TABLES P_TABLE
                                 USING P_VALUE.

  DATA: L_EXCLUDE TYPE UI_FUNC.

  L_EXCLUDE = P_VALUE.
  APPEND L_EXCLUDE TO P_TABLE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_sorttab_grid_0100
*&---------------------------------------------------------------------*
FORM SET_SORTTAB_GRID_0100 .

  REFRESH GT_SORT_0100.
  PERFORM SET_SORT_TAB TABLES GT_SORT_0100
                        USING : 1 'SPEC'        'X' '' '', "규격
                                2 'ZPJNO'       'X' '' '', "프로젝트 No.
                                3 'ZPTXT'       'X' '' '', "프로젝트명
                                4 'BASEMONTH'   'X' '' '', "판매계획월
                                5 'VRKME'       'X' '' '', "판매단위
                                6 'QUANTITY_DP' 'X' '' '', "판매계획량
                                7 'MATNR_S'     'X' '' '', "판매계획제품
                                8 'MEINS'       'X' '' '', "생산단위
                                9 'GONG_SEQ'    'X' '' ''. "공정순번

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_f4_field_grid_0100
*&---------------------------------------------------------------------*
FORM SET_F4_FIELD_GRID_0100 .

  DATA: LT_F4 TYPE LVC_T_F4 WITH HEADER LINE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form call_grid_0100_display
*&---------------------------------------------------------------------*
FORM CALL_GRID_0100_DISPLAY .

  CALL METHOD GO_GRID_0100->SET_TABLE_FOR_FIRST_DISPLAY
    EXPORTING
      IS_LAYOUT                     = GS_LAYOUT_0100
      IT_TOOLBAR_EXCLUDING          = GT_EXCLUDE_0100
    CHANGING
      IT_OUTTAB                     = <GT_MAIN_DISP_100>
      IT_SORT                       = GT_SORT_0100
      IT_FIELDCATALOG               = GT_FIELDCAT_0100
    EXCEPTIONS
      INVALID_PARAMETER_COMBINATION = 1                " Wrong Parameter
      PROGRAM_ERROR                 = 2                " Program Errors
      TOO_MANY_LINES                = 3                " Too many Rows in Ready for Input Grid
      OTHERS                        = 4.

  IF SY-SUBRC <> 0.
    BREAK-POINT.
  ENDIF.

**& Edit  이벤트 등록
*  go_grid_0100->set_ready_for_input( 1 ).
** IF MC_EVT_MODIFY  -> 바로 수정됨.
*  CALL METHOD go_grid_0100->register_edit_event
*    EXPORTING
*      i_event_id = cl_gui_alv_grid=>mc_evt_enter.
*
*  CALL METHOD go_grid_0100->register_edit_event
*    EXPORTING
*      i_event_id = cl_gui_alv_grid=>mc_evt_modified.

  IF GO_DD_DOCU_0100 IS BOUND.
    CALL METHOD GO_DD_DOCU_0100->INITIALIZE_DOCUMENT.
  ELSE.
    CREATE OBJECT GO_DD_DOCU_0100
      EXPORTING
        STYLE = 'ALV_GRID'.                 " Adjusting to the Style of a Particular GUI Environment
  ENDIF.

  CALL METHOD GO_GRID_0100->LIST_PROCESSING_EVENTS
    EXPORTING
      I_EVENT_NAME = 'TOP_OF_PAGE'
      I_DYNDOC_ID  = GO_DD_DOCU_0100.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_SORT_TAB
*&---------------------------------------------------------------------*
FORM SET_SORT_TAB TABLES PT_SORTTAB STRUCTURE LVC_S_SORT
                   USING PV_POS
                         PV_FIELDNAME
                         PV_UP
                         PV_DOWN
                         PV_SUBTOT.

  DATA : LS_SORT TYPE LVC_S_SORT.

  LS_SORT-SPOS      = PV_POS.
  LS_SORT-FIELDNAME = PV_FIELDNAME.
  LS_SORT-UP        = PV_UP.
  LS_SORT-DOWN      = PV_DOWN.
  LS_SORT-SUBTOT    =  PV_SUBTOT.
  APPEND LS_SORT TO PT_SORTTAB.

ENDFORM.
