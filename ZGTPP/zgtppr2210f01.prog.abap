*&---------------------------------------------------------------------*
*& Include          ZGTPPR2210F01
*&---------------------------------------------------------------------*
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
    CASE SCREEN-NAME.
      WHEN 'P_WERKS' OR 'P_SPGCD' OR 'P_SPMON' OR 'P_VDATU'.
        SCREEN-REQUIRED = 2.
        MODIFY SCREEN.
    ENDCASE.

    IF P_R1 EQ GC_X.
      IF SCREEN-GROUP1 = 'S2'.
        SCREEN-ACTIVE = 0.
        MODIFY SCREEN.
      ENDIF.

    ELSEIF P_R2 EQ GC_X.
      IF SCREEN-GROUP1 = 'S1'.
        SCREEN-ACTIVE = 0.
        MODIFY SCREEN.
      ENDIF.

    ENDIF.
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

  IF P_WERKS IS INITIAL.
    MESSAGE S003 DISPLAY LIKE 'E'
       WITH TEXT-M01. "필수 필드 "플랜트"에 입력하십시오.
    LEAVE LIST-PROCESSING.
  ENDIF.

  IF P_SPGCD IS INITIAL.
    MESSAGE S003 DISPLAY LIKE 'E'
       WITH TEXT-M02. "필수 필드 "SPG"에 입력하십시오.
    LEAVE LIST-PROCESSING.
  ENDIF.

  IF P_SPMON IS INITIAL.
    MESSAGE S003 DISPLAY LIKE 'E'
       WITH TEXT-M03. "필수 필드 "판매년월"에 입력하십시오.
    LEAVE LIST-PROCESSING.
  ENDIF.

  IF P_R1 EQ GC_X.
    IF P_VDATU IS INITIAL.
      MESSAGE S003 DISPLAY LIKE 'E'
         WITH TEXT-M04. "필수 필드 "납기요청일"에 입력하십시오.
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

  IF P_R1 EQ GC_X.
    PERFORM GET_DATA_N.
  ELSEIF P_R2 EQ GC_X.
    PERFORM GET_DATA_C.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_DATA_N
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_DATA_N .

  SELECT SINGLE MAX( ZVERS_NO )
    FROM ZGTPPT2310
   WHERE WERKS EQ @P_WERKS
     AND SPGCD EQ @P_SPGCD
     AND SPMON EQ @P_SPMON
     AND VDATU EQ @P_VDATU
    INTO @DATA(LV_ZVERS_NO).

  LV_ZVERS_NO = LV_ZVERS_NO + 1.

  CLEAR: GT_TOP, GS_TOP.
  GS_TOP-WERKS = P_WERKS.
  GS_TOP-SPGCD = P_SPGCD.
  GS_TOP-SPMON = P_SPMON.
  GS_TOP-VDATU = P_VDATU.
  GS_TOP-ZVERS_NO = LV_ZVERS_NO.

  SELECT SINGLE NAME1
    FROM T001W
   WHERE WERKS EQ @GS_TOP-WERKS
    INTO @GS_TOP-NAME1.

  SELECT SINGLE DESCR
    FROM ZPPT0107
   WHERE WERKS EQ @GS_TOP-WERKS
     AND SPGCD EQ @GS_TOP-SPGCD
    INTO @GS_TOP-DESCR.

  GS_TOP-SEL = ICON_LED_INACTIVE.

  APPEND GS_TOP TO GT_TOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CLS_OBJT_RTN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CLS_OBJT_RTN .
  CLEAR: GT_FIELDCAT_0100[], GS_LAYOUT_0100, GT_EXCLUDE_0100[],
         GT_EXCLUDE_0100,
         GT_FIELDCAT_0101[], GS_LAYOUT_0101, GT_EXCLUDE_0101[],
         GT_EXCLUDE_0101,
         GV_OK_CODE, GV_DBCNT,
         GT_TOP[], GT_BOTTOM[].

  CALL METHOD GO_CONTAIN_0100->FREE.
  CALL METHOD GO_CONTAIN_0101->FREE.
  CLEAR : GO_CONTAIN_0100, GO_GRID_0100, GO_CONTAIN_0101, GO_GRID_0101.
  CALL METHOD CL_GUI_CFW=>FLUSH.
  LEAVE TO SCREEN 0.
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
*화면 분할
  CREATE OBJECT GO_SPLITTER
    EXPORTING
      PARENT  = GO_DOCKING_CONTAINER
      ROWS    = 2
      COLUMNS = 1.
* top 컨테이너
  CALL METHOD GO_SPLITTER->GET_CONTAINER
    EXPORTING
      ROW       = 1
      COLUMN    = 1
    RECEIVING
      CONTAINER = GO_CONTAIN_0100.
* bottom 컨테이너
  CALL METHOD GO_SPLITTER->GET_CONTAINER
    EXPORTING
      ROW       = 2
      COLUMN    = 1
    RECEIVING
      CONTAINER = GO_CONTAIN_0101.

  CREATE OBJECT GO_GRID_0100
    EXPORTING
      I_PARENT      = GO_CONTAIN_0100
      I_APPL_EVENTS = ABAP_TRUE.
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
*  GS_LAYOUT_0100-ZEBRA      = GC_X.
  GS_LAYOUT_0100-COL_OPT    = GC_X.
  GS_LAYOUT_0100-CWIDTH_OPT = GC_X.
*  GS_LAYOUT_0100-NO_ROWINS  = GC_X.
  GS_LAYOUT_0100-SEL_MODE   = GC_D.
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
      I_INCLNAME             = 'ZGTPPR2210TOP'
      I_INTERNAL_TABNAME     = 'GS_TOP'
    CHANGING
      CT_FIELDCAT            = LT_FCAT_SLIS
    EXCEPTIONS
      INCONSISTENT_INTERFACE = 1
      PROGRAM_ERROR          = 2
      OTHERS                 = 3.

  CALL FUNCTION 'LVC_TRANSFER_FROM_SLIS'
    EXPORTING
      IT_FIELDCAT_ALV = LT_FCAT_SLIS
    IMPORTING
      ET_FIELDCAT_LVC = GT_FIELDCAT_0100[]
    TABLES
      IT_DATA         = GT_TOP
    EXCEPTIONS
      OTHERS          = 1.

  LOOP AT GT_FIELDCAT_0100 ASSIGNING FIELD-SYMBOL(<LS_FCAT>).
    CASE <LS_FCAT>-FIELDNAME.
      WHEN 'SEL'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F01. "선택
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-ICON = GC_X.
      WHEN 'WERKS'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F02. "플랜트
        <LS_FCAT>-JUST = GC_C.
      WHEN 'NAME1'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F03. "플랜트내역
        <LS_FCAT>-JUST = GC_L.
      WHEN 'SPGCD'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F04. "SPG
        <LS_FCAT>-JUST = GC_C.
      WHEN 'DESCR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F05. "SPG내역
        <LS_FCAT>-JUST = GC_L.
      WHEN 'SPMON'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F06. "판매년월
        <LS_FCAT>-JUST = GC_C.
      WHEN 'VDATU'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F07. "기준일자
        <LS_FCAT>-JUST = GC_C.
      WHEN 'ZVERS_NO'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F08. "산출버전번호
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-HOTSPOT = GC_X.
        <LS_FCAT>-EMPHASIZE = 'C600'.
      WHEN 'ZVERS_DESC'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F09. "산출버전내역
        <LS_FCAT>-JUST = GC_L.
        IF P_R1 EQ 'X'.
          <LS_FCAT>-EDIT = GC_X.
        ENDIF.
      WHEN 'CRDAT'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F10. "생성일자
        <LS_FCAT>-JUST = GC_C.
      WHEN 'CRTIM'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F11. "생성시간
        <LS_FCAT>-JUST = GC_C.
      WHEN 'CRNAM'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F12. "생성자
        <LS_FCAT>-JUST = GC_C.
      WHEN OTHERS.
        <LS_FCAT>-NO_OUT = GC_X.
    ENDCASE.

    CLEAR: <LS_FCAT>-KEY.

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
    CHANGING
      IT_OUTTAB            = GT_TOP
      IT_FIELDCATALOG      = GT_FIELDCAT_0100.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_EVENT_GRID_0100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GO_GRID_0100
*&---------------------------------------------------------------------*
FORM SET_EVENT_GRID_0100  USING    PO_GRID TYPE REF TO CL_GUI_ALV_GRID.
  IF GO_EVTR_0100 IS NOT BOUND.
    CREATE OBJECT GO_EVTR_0100.
  ENDIF.

  CASE PO_GRID.
    WHEN GO_GRID_0100.
      SET HANDLER: GO_EVTR_0100->HDL_DOUBLE_CLICK FOR GO_GRID_0100.
      SET HANDLER: GO_EVTR_0100->HDL_HOTSPOT_CLICK FOR GO_GRID_0100.
  ENDCASE.

* 인풋이벤트 추가
  CALL METHOD PO_GRID->REGISTER_EDIT_EVENT
    EXPORTING
      I_EVENT_ID = CL_GUI_ALV_GRID=>MC_EVT_ENTER.

* DATA CHANGE
  CALL METHOD PO_GRID->REGISTER_EDIT_EVENT
    EXPORTING
      I_EVENT_ID = CL_GUI_ALV_GRID=>MC_EVT_MODIFIED.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_DATA_C
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_DATA_C .

  CLEAR: GT_TOP.
  SELECT A~*,
         B~NAME1,
         C~DESCR,
         'X' AS CAL_CHK
    FROM ZGTPPT2310 AS A
    LEFT JOIN T001W AS B ON B~WERKS EQ A~WERKS
    LEFT JOIN ZPPT0107 AS C ON C~WERKS EQ A~WERKS
                           AND C~SPGCD EQ A~SPGCD
   WHERE A~WERKS    EQ @P_WERKS
     AND A~SPGCD    EQ @P_SPGCD
     AND A~SPMON    EQ @P_SPMON
     AND A~ZVERS_NO IN @S_VERSNO
     AND A~VDATU    IN @S_VDATU
     AND A~CRDAT    IN @S_CRDAT
    INTO CORRESPONDING FIELDS OF TABLE @GT_TOP.

  CLEAR: GT_OBOTTOM.
  SELECT A~WERKS, A~SPGCD, A~SPMON, A~VDATU, A~ZVERS_NO,
         A~ZREQ_NO, A~ZREQ_TYPE, A~AUFNR, A~VBELN, A~POSNR,
         A~ZMANUAL_NO, A~PMATN, A~PMENG, A~PMEIN,
         B~ZOPER_SEQ, B~ARBPL, B~MATNR, B~MENGE, B~MEINS,
         B~ZTIME, B~ZUNIT,
         C~MAKTX AS PMAKT,
         D~MAKTX
    FROM ZGTPPT2320 AS A
    JOIN ZGTPPT2360 AS B ON B~WERKS    EQ A~WERKS
                        AND B~SPGCD    EQ A~SPGCD
                        AND B~SPMON    EQ A~SPMON
                        AND B~VDATU    EQ A~VDATU
                        AND B~ZVERS_NO EQ A~ZVERS_NO
                        AND B~ZREQ_NO  EQ A~ZREQ_NO
    LEFT JOIN MAKT AS C ON C~MATNR EQ A~PMATN
                       AND C~SPRAS EQ @SY-LANGU
    LEFT JOIN MAKT AS D ON D~MATNR EQ B~MATNR
                       AND D~SPRAS EQ @SY-LANGU
   WHERE A~WERKS    EQ @P_WERKS
     AND A~SPGCD    EQ @P_SPGCD
     AND A~SPMON    EQ @P_SPMON
     AND A~ZVERS_NO IN @S_VERSNO
     AND A~VDATU    IN @S_VDATU
    INTO CORRESPONDING FIELDS OF TABLE @GT_OBOTTOM.

  LOOP AT GT_OBOTTOM ASSIGNING FIELD-SYMBOL(<FS_OB>).
    "산출구분내역
    <FS_OB>-ZREQ_TYPENM = ZGTPP_CL_COMMON=>GET_DOMAIN_TEXT(
                             IV_DOMNAME  = 'ZGTDREQ_TYPE'
                             IV_DOMVALUE = CONV #( <FS_OB>-ZREQ_TYPE ) ).

    "작업장내역
    SELECT SINGLE B~KTEXT
      FROM CRHD AS A
      JOIN CRTX AS B ON B~OBJTY EQ A~OBJTY
                    AND B~OBJID EQ A~OBJID
                    AND B~SPRAS EQ @SY-LANGU
     WHERE A~OBJTY EQ @GC_A
       AND A~ARBPL EQ @<FS_OB>-ARBPL
      INTO @<FS_OB>-KTEXT.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROCESS_VER_ADD
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PROCESS_VER_ADD .

  DATA: LT_TOP LIKE TABLE OF GS_TOP.

  CLEAR: GS_TOP.
  GS_TOP-WERKS = P_WERKS.
  GS_TOP-SPGCD = P_SPGCD.
  GS_TOP-SPMON = P_SPMON.
  GS_TOP-VDATU = P_VDATU.

  SELECT SINGLE NAME1
    FROM T001W
   WHERE WERKS EQ @GS_TOP-WERKS
    INTO @GS_TOP-NAME1.

  SELECT SINGLE DESCR
    FROM ZPPT0107
   WHERE WERKS EQ @GS_TOP-WERKS
     AND SPGCD EQ @GS_TOP-SPGCD
    INTO @GS_TOP-DESCR.

  GS_TOP-SEL = ICON_LED_INACTIVE.

  "산출버전번호(DB)
  SELECT SINGLE MAX( ZVERS_NO )
    FROM ZGTPPT2310
   WHERE WERKS EQ @P_WERKS
     AND SPGCD EQ @P_SPGCD
     AND SPMON EQ @P_SPMON
     AND VDATU EQ @P_VDATU
    INTO @DATA(LV_ZVERS_NO_DB).

  "산출버전번호(ALV)
  CLEAR: LT_TOP.
  APPEND LINES OF GT_TOP TO LT_TOP.
  SORT LT_TOP BY ZVERS_NO DESCENDING.
  READ TABLE LT_TOP INTO DATA(LS_TOP) INDEX 1.

  IF LS_TOP-ZVERS_NO GE LV_ZVERS_NO_DB.
    GS_TOP-ZVERS_NO = LS_TOP-ZVERS_NO + 1.
  ELSE.
    GS_TOP-ZVERS_NO = LV_ZVERS_NO_DB + 1.
  ENDIF.

  APPEND GS_TOP TO GT_TOP.

  " REFRESH DISPLAY
  PERFORM REF_ALV_RTN USING GO_GRID_0100.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form REF_ALV_RTN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GO_GRID_0100
*&---------------------------------------------------------------------*
FORM REF_ALV_RTN  USING    PO_GRID TYPE REF TO CL_GUI_ALV_GRID.

  DATA: LV_TITLE TYPE LVC_TITLE.

  DATA LS_STABLE TYPE LVC_S_STBL.

  LS_STABLE-ROW = 'X'.
  LS_STABLE-COL = 'X'.

  CASE PO_GRID.
    WHEN GO_GRID_0100.
      CALL METHOD PO_GRID->SET_FRONTEND_LAYOUT
        EXPORTING
          IS_LAYOUT = GS_LAYOUT_0100.
    WHEN GO_GRID_0101.
      LV_TITLE = |산출 버전 번호 : | && GV_VERSNO.

      GS_LAYOUT_0101-GRID_TITLE = LV_TITLE.

      CALL METHOD PO_GRID->SET_FRONTEND_LAYOUT
        EXPORTING
          IS_LAYOUT = GS_LAYOUT_0101.
  ENDCASE.

  CALL METHOD PO_GRID->REFRESH_TABLE_DISPLAY
    EXPORTING
      IS_STABLE = LS_STABLE
    EXCEPTIONS
      FINISHED  = 1
      OTHERS    = 2.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROCESS_VER_DEL
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PROCESS_VER_DEL .

  DATA: LT_ROW_NO TYPE LVC_T_ROID WITH HEADER LINE,
        L_ANSWER  TYPE CHAR01.

  DATA: LS_2310 LIKE ZGTPPT2310,
        LS_2320 LIKE ZGTPPT2320.

  FIELD-SYMBOLS: <FS_T> LIKE GS_TOP.

  CLEAR: L_ANSWER.

  PERFORM SEL_ROW_RTN TABLES LT_ROW_NO
                      USING  GO_GRID_0100.

  IF LT_ROW_NO[] IS INITIAL.
    MESSAGE S003 DISPLAY LIKE GC_W
       WITH TEXT-M05. "삭제할 레코드를 선택하세요.
    EXIT.
  ENDIF.

  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      TITLEBAR              = TEXT-T04 "삭제
      TEXT_QUESTION         = TEXT-T05 "선택하신 버전의 데이터 삭제를 진행하시겠습니까?
      DISPLAY_CANCEL_BUTTON = SPACE
    IMPORTING
      ANSWER                = L_ANSWER.

  IF L_ANSWER = '1'.
    SORT LT_ROW_NO BY ROW_ID DESCENDING.

    LOOP AT LT_ROW_NO.
      READ TABLE GT_TOP ASSIGNING <FS_T> INDEX LT_ROW_NO-ROW_ID.

      CLEAR: LS_2310.
      SELECT SINGLE *
        FROM ZGTPPT2310
       WHERE WERKS EQ @<FS_T>-WERKS
         AND SPGCD EQ @<FS_T>-SPGCD
         AND SPMON EQ @<FS_T>-SPMON
         AND VDATU EQ @<FS_T>-VDATU
         AND ZVERS_NO EQ @<FS_T>-ZVERS_NO
        INTO @LS_2310.

      IF SY-SUBRC EQ 0.
        DELETE FROM ZGTPPT2310
              WHERE WERKS EQ <FS_T>-WERKS
                AND SPGCD EQ <FS_T>-SPGCD
                AND SPMON EQ <FS_T>-SPMON
                AND VDATU EQ <FS_T>-VDATU
                AND ZVERS_NO EQ <FS_T>-ZVERS_NO.

        DELETE FROM ZGTPPT2320
              WHERE WERKS EQ <FS_T>-WERKS
                AND SPGCD EQ <FS_T>-SPGCD
                AND SPMON EQ <FS_T>-SPMON
                AND VDATU EQ <FS_T>-VDATU
                AND ZVERS_NO EQ <FS_T>-ZVERS_NO.

        DELETE FROM ZGTPPT2360
              WHERE WERKS EQ <FS_T>-WERKS
                AND SPGCD EQ <FS_T>-SPGCD
                AND SPMON EQ <FS_T>-SPMON
                AND VDATU EQ <FS_T>-VDATU
                AND ZVERS_NO EQ <FS_T>-ZVERS_NO.

        IF SY-SUBRC EQ 0.
          COMMIT WORK.
          "ALV에서 삭제
          DELETE GT_TOP INDEX LT_ROW_NO-ROW_ID.
          MESSAGE S003 WITH TEXT-M06. "삭제되었습니다.
        ELSE.
          ROLLBACK WORK.
          MESSAGE S003 WITH TEXT-M07. "삭제 중 오류가 발생하였습니다.
        ENDIF.

      ELSE.
        "ALV에서 삭제
        DELETE GT_TOP INDEX LT_ROW_NO-ROW_ID.
        MESSAGE S003 WITH TEXT-M06. "삭제되었습니다.
      ENDIF.

    ENDLOOP.

    " REFRESH DISPLAY
    PERFORM REF_ALV_RTN USING GO_GRID_0100.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SEL_ROW_RTN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LT_ROW_NO
*&      --> GO_GRID_0100
*&---------------------------------------------------------------------*
FORM SEL_ROW_RTN  TABLES PT_ROW_NO TYPE LVC_T_ROID
                  USING  PR_ALV TYPE REF TO CL_GUI_ALV_GRID.

  DATA: LT_INDEX_ROWS TYPE LVC_T_ROW,
        LT_ROW_NO     TYPE LVC_T_ROID.

  CLEAR: LT_INDEX_ROWS, LT_INDEX_ROWS[],
         LT_ROW_NO, LT_ROW_NO[].

  PR_ALV->GET_SELECTED_ROWS(
    IMPORTING
      ET_INDEX_ROWS = LT_INDEX_ROWS
      ET_ROW_NO     = LT_ROW_NO ).

  PT_ROW_NO[] = LT_ROW_NO[].

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROCESS_ZSAVE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PROCESS_ZSAVE .

  DATA: LT_ROW_NO TYPE LVC_T_ROID WITH HEADER LINE,
        L_ANSWER  TYPE CHAR01.

  FIELD-SYMBOLS: <FS_T> LIKE GS_TOP.

  CLEAR: L_ANSWER.

  PERFORM SEL_ROW_RTN TABLES LT_ROW_NO
                      USING  GO_GRID_0100.

  IF LT_ROW_NO[] IS INITIAL.
    MESSAGE S003 DISPLAY LIKE GC_W
       WITH TEXT-M08. "저장할 레코드를 선택하세요.
    EXIT.
  ENDIF.

*  IF LINES( LT_ROW_NO ) > 1.
*    MESSAGE S003 DISPLAY LIKE GC_W
*       WITH TEXT-M10. "하나의 레코드만 선택하세요.
*    EXIT.
*  ENDIF.

  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      TITLEBAR              = TEXT-T06 "저장
      TEXT_QUESTION         = TEXT-T07 "산출한 데이터를 저장하시겠습니까?
      DISPLAY_CANCEL_BUTTON = SPACE
    IMPORTING
      ANSWER                = L_ANSWER.

  IF L_ANSWER = '1'.
    LOOP AT LT_ROW_NO.
      READ TABLE GT_TOP ASSIGNING <FS_T> INDEX LT_ROW_NO-ROW_ID.

      IF <FS_T>-ZVERS_DESC IS INITIAL.
        MESSAGE S031 DISPLAY LIKE 'E' WITH TEXT-F09. "산출버전내역
        EXIT.
      ENDIF.

      IF <FS_T>-CAL_CHK IS INITIAL.
        MESSAGE S003 DISPLAY LIKE 'E' WITH TEXT-M11. "데이터 산출이 진행되지 않았습니다.
        EXIT.
      ENDIF.

      PERFORM SAVE_CAL_DATA USING <FS_T>.

    ENDLOOP.

    MESSAGE S004.

    " REFRESH DISPLAY
    PERFORM REF_ALV_RTN USING GO_GRID_0100.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROCESS_CALC
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PROCESS_CALC .

  DATA: LT_ROW_NO TYPE LVC_T_ROID WITH HEADER LINE,
        L_ANSWER  TYPE CHAR01.

  FIELD-SYMBOLS: <FS_T> LIKE GS_TOP.

  CLEAR: L_ANSWER.

  PERFORM SEL_ROW_RTN TABLES LT_ROW_NO
                      USING  GO_GRID_0100.

  IF LT_ROW_NO[] IS INITIAL.
    MESSAGE S003 DISPLAY LIKE GC_W
       WITH TEXT-M09. "산출할 레코드를 선택하세요.
    EXIT.
  ENDIF.

  IF LINES( LT_ROW_NO ) > 1.
    MESSAGE S003 DISPLAY LIKE GC_W
       WITH TEXT-M10. "하나의 레코드만 선택하세요.
    EXIT.
  ENDIF.

  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      TITLEBAR              = TEXT-T08 "산출
      TEXT_QUESTION         = TEXT-T09 "선택하신 버전 기준으로 데이터 산출을 진행하시겠습니까?
      DISPLAY_CANCEL_BUTTON = SPACE
    IMPORTING
      ANSWER                = L_ANSWER.

  IF L_ANSWER = '1'.
    CLEAR: GT_OBOTTOM, GT_BOTTOM, GV_VERSNO.
    READ TABLE LT_ROW_NO INDEX 1.
    READ TABLE GT_TOP ASSIGNING <FS_T> INDEX LT_ROW_NO-ROW_ID.
    GV_VERSNO = <FS_T>-ZVERS_NO.

    IF <FS_T>-ZVERS_DESC IS INITIAL.
      MESSAGE S031 DISPLAY LIKE 'E' WITH TEXT-F09. "산출버전내역
      EXIT.
    ELSE.
      IF <FS_T>-CAL_CHK IS NOT INITIAL.
        MESSAGE S031 DISPLAY LIKE 'E' WITH TEXT-M11. "데이터 산출이 진행되지 않았습니다.
        EXIT.
      ELSE.
        CLEAR: GT_CALBOTTOM.
        PERFORM PROC_DATA_CALC USING <FS_T>.

        PERFORM MOVE_DATA_BOTTOM.
        PERFORM SET_BOTTOM_ALV_0101.
      ENDIF.
    ENDIF.

    " REFRESH DISPLAY
    PERFORM REF_ALV_RTN USING GO_GRID_0100.
    PERFORM REF_ALV_RTN USING GO_GRID_0101.
  ENDIF.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form SAVE_CAL_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> <FS_T>
*&---------------------------------------------------------------------*
FORM SAVE_CAL_DATA  USING    P_TOP LIKE GS_TOP.

  DATA: LT_ZGTPPT2310 TYPE TABLE OF ZGTPPT2310,
        LT_ZGTPPT2320 TYPE TABLE OF ZGTPPT2320,
        LT_ZGTPPT2360 TYPE TABLE OF ZGTPPT2360.

  DATA: LS_ZGTPPT2310 TYPE ZGTPPT2310,
        LS_ZGTPPT2320 TYPE ZGTPPT2320,
        LS_ZGTPPT2360 TYPE ZGTPPT2360.

  "ZGTPPT2310
  CLEAR: LT_ZGTPPT2310, LS_ZGTPPT2310.
  MOVE-CORRESPONDING P_TOP TO LS_ZGTPPT2310.
  P_TOP-CRDAT = LS_ZGTPPT2310-CRDAT = SY-DATUM.
  P_TOP-CRTIM = LS_ZGTPPT2310-CRTIM = SY-UZEIT.
  P_TOP-CRNAM = LS_ZGTPPT2310-CRNAM = SY-UNAME.
  APPEND LS_ZGTPPT2310 TO LT_ZGTPPT2310.

  LOOP AT GT_OBOTTOM INTO DATA(LS_OB) WHERE WERKS EQ P_TOP-WERKS
                                        AND SPGCD EQ P_TOP-SPGCD
                                        AND SPMON EQ P_TOP-SPMON
                                        AND VDATU EQ P_TOP-VDATU
                                        AND ZVERS_NO EQ P_TOP-ZVERS_NO.

    "ZGTPPT2320
    MOVE-CORRESPONDING LS_OB TO LS_ZGTPPT2320.
    LS_ZGTPPT2320-CRDAT = SY-DATUM.
    LS_ZGTPPT2320-CRTIM = SY-UZEIT.
    LS_ZGTPPT2320-CRNAM = SY-UNAME.
    APPEND LS_ZGTPPT2320 TO LT_ZGTPPT2320.

    "ZGTPPT2360
    MOVE-CORRESPONDING LS_OB TO LS_ZGTPPT2360.
    LS_ZGTPPT2360-CRDAT = SY-DATUM.
    LS_ZGTPPT2360-CRTIM = SY-UZEIT.
    LS_ZGTPPT2360-CRNAM = SY-UNAME.
    APPEND LS_ZGTPPT2360 TO LT_ZGTPPT2360.

    CLEAR: LS_OB, LS_ZGTPPT2320, LS_ZGTPPT2360.

  ENDLOOP.

  MODIFY ZGTPPT2310 FROM TABLE LT_ZGTPPT2310.
  MODIFY ZGTPPT2320 FROM TABLE LT_ZGTPPT2320.
  MODIFY ZGTPPT2360 FROM TABLE LT_ZGTPPT2360.

  COMMIT WORK AND WAIT.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROC_DATA_CALC
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PROC_DATA_CALC USING PS_TOP LIKE GS_TOP.

  CLEAR: GV_PMATN, GV_PMENG.
  PERFORM PROC_GET_DATA_CALC USING PS_TOP.
  LOOP AT GT_CALBOTTOM ASSIGNING FIELD-SYMBOL(<FS_CALOB>).
    PERFORM PROC_GET_MODIFY_CALC USING <FS_CALOB>.
  ENDLOOP.

  PS_TOP-CAL_CHK = 'X'.
  PS_TOP-SEL = ICON_LED_GREEN.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROC_GET_DATA_CALC
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_TOP
*&---------------------------------------------------------------------*
FORM PROC_GET_DATA_CALC  USING    PS_TOP LIKE GS_TOP.

  DATA: LV_DISPO(50).
  DATA: LV_REQ_NO TYPE ZGTEREQ_NO.

  CLEAR: LV_DISPO.
  LV_DISPO = |%| && P_SPGCD && |%|.

  CLEAR: LV_REQ_NO.

  "MTO 생산에 대한 작업지시 정보 추출
  SELECT A~AUFNR, A~KDAUF AS VBELN, A~KDPOS AS POSNR, A~MATNR AS PMATN,
         A~PSMNG AS PMENG, A~WEMNG, A~MEINS AS PMEIN
*         B~GAMNG AS PMENG, B~GMEIN AS PMEIN
    FROM AFPO AS A
    JOIN AFKO AS B ON B~AUFNR EQ A~AUFNR
    JOIN AUFK AS C ON C~AUFNR EQ A~AUFNR
    JOIN MARC AS D ON D~MATNR EQ A~MATNR
                  AND D~WERKS EQ C~WERKS
    JOIN VBAP AS E ON E~VBELN EQ A~KDAUF
                  AND E~POSNR EQ A~KDPOS
    JOIN VBAK AS F ON F~VBELN EQ E~VBELN
   WHERE C~WERKS EQ @P_WERKS
     AND D~DISPO LIKE @LV_DISPO
     AND F~VDATU LE @P_VDATU
     AND C~LOEKZ EQ @SPACE
     AND E~ABGRU EQ @SPACE
     AND E~WBSTA NE 'C'
     AND A~ELIKZ NE 'X'
    INTO TABLE @DATA(LT_MTO).

  IF LT_MTO IS NOT INITIAL.
    LOOP AT LT_MTO ASSIGNING FIELD-SYMBOL(<FS_MTO>).
      <FS_MTO>-PMENG = <FS_MTO>-PMENG - <FS_MTO>-WEMNG.
    ENDLOOP.

    LOOP AT LT_MTO INTO DATA(LS_MTO) WHERE PMENG > 0.
      LV_REQ_NO += 1.

      CLEAR: GS_OBOTTOM.
      GS_OBOTTOM-WERKS      = P_WERKS.
      GS_OBOTTOM-SPGCD      = P_SPGCD.
      GS_OBOTTOM-SPMON      = P_SPMON.
      GS_OBOTTOM-VDATU      = P_VDATU.
      GS_OBOTTOM-ZVERS_NO   = PS_TOP-ZVERS_NO.
      GS_OBOTTOM-ZREQ_NO    = LV_REQ_NO.
      GS_OBOTTOM-ZREQ_TYPE  = '1'. "작업지시 확정
      GS_OBOTTOM-AUFNR      = LS_MTO-AUFNR.
      GS_OBOTTOM-VBELN      = LS_MTO-VBELN.
      GS_OBOTTOM-POSNR      = LS_MTO-POSNR.
      GS_OBOTTOM-ZMANUAL_NO = SPACE.
      GS_OBOTTOM-PMATN      = LS_MTO-PMATN.
      GS_OBOTTOM-PMENG      = LS_MTO-PMENG.
      GS_OBOTTOM-PMEIN      = LS_MTO-PMEIN.

      APPEND GS_OBOTTOM TO GT_CALBOTTOM.

      CLEAR: LS_MTO.
    ENDLOOP.
  ENDIF.

  "MTS 생산에 대한 작업지시 정보 추출
  SELECT A~AUFNR, A~KDAUF AS VBELN, A~KDPOS AS POSNR, A~MATNR AS PMATN,
         A~PSMNG AS PMENG, A~WEMNG, A~MEINS AS PMEIN
*         B~GAMNG AS PMENG, B~GMEIN AS PMEIN
    FROM AFPO AS A
    JOIN AFKO AS B ON B~AUFNR EQ A~AUFNR
    JOIN AUFK AS C ON C~AUFNR EQ A~AUFNR
    JOIN MARC AS D ON D~MATNR EQ A~MATNR
                  AND D~WERKS EQ C~WERKS
    JOIN ZGTPPT2010 AS E ON E~ORDNR EQ A~AUFNR
   WHERE C~WERKS EQ @P_WERKS
     AND D~DISPO LIKE @LV_DISPO
     AND E~DMORDTY EQ 'SM'
     AND C~LOEKZ EQ @SPACE
     AND A~ELIKZ NE 'X'
     AND B~GSTRP <= @P_VDATU  "납기요청일
    INTO TABLE @DATA(LT_MTS).

  IF LT_MTS IS NOT INITIAL.
    LOOP AT LT_MTS ASSIGNING FIELD-SYMBOL(<FS_MTS>).
      <FS_MTS>-PMENG = <FS_MTS>-PMENG - <FS_MTS>-WEMNG.
    ENDLOOP.

    LOOP AT LT_MTS INTO DATA(LS_MTS) WHERE PMENG > 0.
      LV_REQ_NO += 1.

      CLEAR: GS_OBOTTOM.
      GS_OBOTTOM-WERKS      = P_WERKS.
      GS_OBOTTOM-SPGCD      = P_SPGCD.
      GS_OBOTTOM-SPMON      = P_SPMON.
      GS_OBOTTOM-VDATU      = P_VDATU.
      GS_OBOTTOM-ZVERS_NO   = PS_TOP-ZVERS_NO.
      GS_OBOTTOM-ZREQ_NO    = LV_REQ_NO.
      GS_OBOTTOM-ZREQ_TYPE  = '1'. "작업지시 확정
      GS_OBOTTOM-AUFNR      = LS_MTS-AUFNR.
      GS_OBOTTOM-VBELN      = LS_MTS-VBELN.
      GS_OBOTTOM-POSNR      = LS_MTS-POSNR.
      GS_OBOTTOM-ZMANUAL_NO = SPACE.
      GS_OBOTTOM-PMATN      = LS_MTS-PMATN.
      GS_OBOTTOM-PMENG      = LS_MTS-PMENG.
      GS_OBOTTOM-PMEIN      = LS_MTS-PMEIN.

      APPEND GS_OBOTTOM TO GT_CALBOTTOM.

      CLEAR: LS_MTS.
    ENDLOOP.
  ENDIF.

  "영업 수주 확정 정보 추출
  SELECT A~VBELN, A~POSNR, A~MATNR AS PMATN, A~KWMENG AS PMENG, A~VRKME AS PMEIN
    FROM VBAP AS A
    JOIN VBAK AS B ON B~VBELN EQ A~VBELN
    JOIN MARC AS C ON C~WERKS EQ A~WERKS
                  AND C~MATNR EQ A~MATNR
   WHERE A~WERKS EQ @P_WERKS
     AND B~VDATU LE @P_VDATU
     AND C~DISPO LIKE @LV_DISPO
    INTO TABLE @DATA(LT_OVBAP).

  SORT LT_OVBAP BY VBELN POSNR PMATN.
  IF LT_OVBAP IS NOT INITIAL.
    "영업수주 확정 정보 중 생산오더가 없는 수주 추출
    SELECT KDAUF AS VBELN, KDPOS AS POSNR, MATNR AS PMATN
      FROM AFPO
       FOR ALL ENTRIES IN @LT_OVBAP
     WHERE KDAUF EQ @LT_OVBAP-VBELN
       AND KDPOS EQ @LT_OVBAP-POSNR
       AND MATNR EQ @LT_OVBAP-PMATN
      INTO TABLE @DATA(LT_AFPO).

    SORT LT_AFPO BY VBELN POSNR PMATN.
  ENDIF.

  DATA: LS_VBAP LIKE LINE OF LT_OVBAP,
        LT_VBAP LIKE TABLE OF LS_VBAP.

  CLEAR: LT_VBAP.
  LOOP AT LT_OVBAP INTO DATA(LS_OVBAP).
    READ TABLE LT_AFPO INTO DATA(LS_AFPO) WITH KEY VBELN = LS_OVBAP-VBELN
                                                   POSNR = LS_OVBAP-POSNR
                                                   PMATN = LS_OVBAP-PMATN.

    IF SY-SUBRC NE 0.
      MOVE-CORRESPONDING LS_OVBAP TO LS_VBAP.
      APPEND LS_VBAP TO LT_VBAP.
      CLEAR: LS_VBAP.
    ENDIF.

    CLEAR: LS_OVBAP, LS_AFPO.
  ENDLOOP.

  IF LT_VBAP IS NOT INITIAL.
    CLEAR: LS_VBAP.
    LOOP AT LT_VBAP INTO LS_VBAP.
      LV_REQ_NO += 1.

      CLEAR: GS_OBOTTOM.
      GS_OBOTTOM-WERKS      = P_WERKS.
      GS_OBOTTOM-SPGCD      = P_SPGCD.
      GS_OBOTTOM-SPMON      = P_SPMON.
      GS_OBOTTOM-VDATU      = P_VDATU.
      GS_OBOTTOM-ZVERS_NO   = PS_TOP-ZVERS_NO.
      GS_OBOTTOM-ZREQ_NO    = LV_REQ_NO.
      GS_OBOTTOM-ZREQ_TYPE  = '2'. "영업수주 확정
      GS_OBOTTOM-AUFNR      = SPACE.
      GS_OBOTTOM-VBELN      = LS_VBAP-VBELN.
      GS_OBOTTOM-POSNR      = LS_VBAP-POSNR.
      GS_OBOTTOM-ZMANUAL_NO = SPACE.
      GS_OBOTTOM-PMATN      = LS_VBAP-PMATN.
      GS_OBOTTOM-PMENG      = LS_VBAP-PMENG.
      GS_OBOTTOM-PMEIN      = LS_VBAP-PMEIN.

      APPEND GS_OBOTTOM TO GT_CALBOTTOM.

      CLEAR: LS_VBAP.
    ENDLOOP.
  ENDIF.

  "수기 등록 정보 추출(추가)
  SELECT WERKS, SPGCD, ZMANUAL_NO, ZMANUAL_TYPE, MATNR AS PMATN,
         VBELN, POSNR, MENGE AS PMENG, MEINS AS PMEIN
    FROM ZGTPPT2300
   WHERE WERKS EQ @P_WERKS
     AND SPGCD EQ @P_SPGCD
     AND VDATU LE @P_VDATU
     AND ZMANUAL_TYPE IN ('M1', 'S1')  "수기물량&판매주문
    INTO TABLE @DATA(LT_2300_A).

  IF LT_2300_A IS NOT INITIAL.
    LOOP AT LT_2300_A INTO DATA(LS_2300_A).
      LV_REQ_NO += 1.

      CLEAR: GS_OBOTTOM.
      GS_OBOTTOM-WERKS      = P_WERKS.
      GS_OBOTTOM-SPGCD      = P_SPGCD.
      GS_OBOTTOM-SPMON      = P_SPMON.
      GS_OBOTTOM-VDATU      = P_VDATU.
      GS_OBOTTOM-ZVERS_NO   = PS_TOP-ZVERS_NO.
      GS_OBOTTOM-ZREQ_NO    = LV_REQ_NO.
      GS_OBOTTOM-ZREQ_TYPE  = '3'. "수기등록
      GS_OBOTTOM-AUFNR      = SPACE.
      GS_OBOTTOM-VBELN      = LS_2300_A-VBELN.
      GS_OBOTTOM-POSNR      = LS_2300_A-POSNR.
      GS_OBOTTOM-ZMANUAL_NO = LS_2300_A-ZMANUAL_NO.
      GS_OBOTTOM-PMATN      = LS_2300_A-PMATN.
      GS_OBOTTOM-PMENG      = LS_2300_A-PMENG.
      GS_OBOTTOM-PMEIN      = LS_2300_A-PMEIN.

      APPEND GS_OBOTTOM TO GT_CALBOTTOM.

      CLEAR: LS_2300_A.
    ENDLOOP.
  ENDIF.

  "수기 등록 정보 추출(제외)
  SELECT WERKS, SPGCD, ZMANUAL_NO, ZMANUAL_TYPE, VBELN, POSNR
    FROM ZGTPPT2300
   WHERE WERKS EQ @P_WERKS
     AND SPGCD EQ @P_SPGCD
     AND VDATU LE @P_VDATU
     AND ZMANUAL_TYPE EQ 'S2'  "판매주문제외
    INTO TABLE @DATA(LT_2300_D).

  SORT LT_2300_D BY VBELN POSNR.

  LOOP AT GT_CALBOTTOM ASSIGNING FIELD-SYMBOL(<FS_CAL>).
    READ TABLE LT_2300_D INTO DATA(LS_2300_D) WITH KEY VBELN = <FS_CAL>-VBELN
                                                       POSNR = <FS_CAL>-POSNR.

    IF SY-SUBRC EQ 0.
      <FS_CAL>-DEL = GC_X.
    ENDIF.
  ENDLOOP.

  DELETE GT_CALBOTTOM WHERE DEL EQ GC_X.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROC_GET_MODIFY_CALC
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PROC_GET_MODIFY_CALC USING PS_CALOB LIKE GS_OBOTTOM.

  "산출 품목 기준으로 BOM 전개하여 하위 제품/반제품 추출
  DATA: BEGIN OF LS_MATNR,
          SEQNO TYPE TTIDX,
          MATNR TYPE MATNR,
          MNGKO TYPE CS_E_MNGKO,
          MMEIN TYPE MEINS,
        END OF LS_MATNR.
  DATA: LT_MATNR LIKE TABLE OF LS_MATNR.

  IF PS_CALOB-PMATN NE GV_PMATN OR
     PS_CALOB-PMENG NE GV_PMENG.
* BOM 하위전개
    CLEAR: GS_TOPMAT, GT_STB, GT_STB[], GT_CSCMAT, GT_CSCMAT[].
    CALL FUNCTION 'CS_BOM_EXPL_MAT_V2'
      EXPORTING
        AUMGB                 = ABAP_ON
        CAPID                 = 'PP01'
        DATUV                 = SY-DATUM
        EHNDL                 = '1'
        EMENG                 = PS_CALOB-PMENG
        MKTLS                 = ABAP_ON
        MEHRS                 = ABAP_ON
        MMORY                 = '1'
        MTNRV                 = PS_CALOB-PMATN
        WERKS                 = P_WERKS
      IMPORTING
        TOPMAT                = GS_TOPMAT
      TABLES
        STB                   = GT_STB
        MATCAT                = GT_CSCMAT
      EXCEPTIONS
        ALT_NOT_FOUND         = 1
        CALL_INVALID          = 2
        MATERIAL_NOT_FOUND    = 3
        MISSING_AUTHORIZATION = 4
        NO_BOM_FOUND          = 5
        NO_PLANT_DATA         = 6
        NO_SUITABLE_BOM_FOUND = 7
        CONVERSION_ERROR      = 8
        OTHERS                = 9.

    GV_PMATN = PS_CALOB-PMATN.
    GV_PMENG = PS_CALOB-PMENG.
  ENDIF.

  IF GT_CSCMAT[] IS NOT INITIAL.
    "LT_CSCMAT의 자재코드의 자재유형으로 추출
    SELECT A~INDEX AS SEQNO, A~MATNR, B~MTART
      FROM @GT_CSCMAT AS A
      JOIN MARA AS B ON B~MATNR = A~MATNR
      JOIN MARC AS C ON C~MATNR = A~MATNR
                    AND C~WERKS = @P_WERKS
     WHERE B~MTART   IN ( 'MCFE', 'MCHF' )  " 완제품 반제품만 공정대상
*       AND B~MATKL LIKE 'H%'
*       AND ( A~INDEX EQ 1 OR ( A~INDEX NE 1 AND  A~VERID IS NOT INITIAL ) )
      INTO TABLE @DATA(LT_SEQ_ROUTING).

    "완/반제품 기준으로 공정수량 SUM, 공정단위 추출
    CLEAR: LT_MATNR.
    LOOP AT LT_SEQ_ROUTING INTO DATA(LS_SEQ_ROUTING).
      LS_MATNR-SEQNO = LS_SEQ_ROUTING-SEQNO.
      LS_MATNR-MATNR = LS_SEQ_ROUTING-MATNR.
      LOOP AT GT_STB INTO DATA(LS_STB) WHERE IDNRK EQ LS_SEQ_ROUTING-MATNR.
        LS_MATNR-MNGKO = LS_MATNR-MNGKO + LS_STB-MNGKO.
        LS_MATNR-MMEIN = LS_STB-MMEIN.
      ENDLOOP.
      APPEND LS_MATNR TO LT_MATNR.
      CLEAR: LS_SEQ_ROUTING, LS_MATNR, LS_STB.
    ENDLOOP.

    IF LT_MATNR[] IS NOT INITIAL.
      "자재코드-공정 수량 기준으로 라우팅 상세 정보 추출
      SELECT A~SEQNO, A~MATNR, A~MNGKO, A~MMEIN,
             B~PLNTY, B~PLNNR, B~PLNAL,
             D~PLNKN, D~ZAEHL, D~ARBID, D~BMSCH, D~VGW02, D~VGE02
        FROM @LT_MATNR AS A
        JOIN MAPL AS B ON B~MATNR EQ A~MATNR
        JOIN PLKO AS C ON C~PLNTY EQ B~PLNTY
                      AND C~PLNAL EQ B~PLNAL
                      AND C~PLNNR EQ B~PLNNR
                      AND C~ZAEHL EQ B~ZAEHL
        JOIN PLPO AS D ON D~PLNTY EQ C~PLNTY
                      AND D~PLNNR EQ C~PLNNR
                      AND D~ZAEHL EQ C~ZAEHL
       WHERE B~WERKS EQ @P_WERKS
         AND C~PLNAL EQ '01'
        INTO TABLE @DATA(LT_ROUTING).
    ENDIF.

  ENDIF.

  IF LT_ROUTING IS NOT INITIAL.
    CLEAR: GS_OBOTTOM.

    GS_OBOTTOM-WERKS      = PS_CALOB-WERKS.
    GS_OBOTTOM-SPGCD      = PS_CALOB-SPGCD.
    GS_OBOTTOM-SPMON      = PS_CALOB-SPMON.
    GS_OBOTTOM-VDATU      = PS_CALOB-VDATU.
    GS_OBOTTOM-ZVERS_NO   = PS_CALOB-ZVERS_NO.
    GS_OBOTTOM-ZREQ_NO    = PS_CALOB-ZREQ_NO.
    GS_OBOTTOM-ZREQ_TYPE  = PS_CALOB-ZREQ_TYPE.
    GS_OBOTTOM-VBELN      = PS_CALOB-VBELN.
    GS_OBOTTOM-POSNR      = PS_CALOB-POSNR.
    GS_OBOTTOM-AUFNR      = PS_CALOB-AUFNR.
    GS_OBOTTOM-ZMANUAL_NO = PS_CALOB-ZMANUAL_NO.
    GS_OBOTTOM-PMATN      = PS_CALOB-PMATN.
    GS_OBOTTOM-PMENG      = PS_CALOB-PMENG.
    GS_OBOTTOM-PMEIN      = PS_CALOB-PMEIN.

    "산출구분내역
    GS_OBOTTOM-ZREQ_TYPENM = ZGTPP_CL_COMMON=>GET_DOMAIN_TEXT(
                               IV_DOMNAME  = 'ZGTDREQ_TYPE'
                               IV_DOMVALUE = CONV #( GS_OBOTTOM-ZREQ_TYPE ) ).

    "품목 내역
    SELECT SINGLE MAKTX
      FROM MAKT
     WHERE MATNR EQ @GS_OBOTTOM-PMATN
       AND SPRAS EQ @SY-LANGU
      INTO @GS_OBOTTOM-PMAKT.

    LOOP AT LT_ROUTING INTO DATA(LS_ROUTING).
      "공정순번
      GS_OBOTTOM-ZOPER_SEQ = LS_ROUTING-SEQNO.

      "작업장/내역
      SELECT SINGLE A~ARBPL, B~KTEXT
        FROM CRHD AS A
        LEFT JOIN CRTX AS B ON B~OBJTY EQ A~OBJTY
                           AND B~OBJID EQ A~OBJID
                           AND B~SPRAS EQ @SY-LANGU
       WHERE A~OBJTY EQ 'A'
         AND A~OBJID EQ @LS_ROUTING-ARBID
        INTO (@GS_OBOTTOM-ARBPL, @GS_OBOTTOM-KTEXT).

      "공정품목코드/내역
      GS_OBOTTOM-MATNR = LS_ROUTING-MATNR.

      SELECT SINGLE MAKTX
        FROM MAKT
       WHERE MATNR EQ @GS_OBOTTOM-MATNR
         AND SPRAS EQ @SY-LANGU
        INTO @GS_OBOTTOM-MAKTX.

      "공정수량
      GS_OBOTTOM-MENGE = LS_ROUTING-MNGKO.
      "수량단위
      GS_OBOTTOM-MEINS = LS_ROUTING-MMEIN.
      "소요시간
      GS_OBOTTOM-ZTIME = ( LS_ROUTING-MNGKO * LS_ROUTING-VGW02 ) / LS_ROUTING-BMSCH.
      "시간단위
      GS_OBOTTOM-ZUNIT = LS_ROUTING-VGE02.

      APPEND GS_OBOTTOM TO GT_OBOTTOM.
    ENDLOOP.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form MOVE_DATA_BOTTOM
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM MOVE_DATA_BOTTOM.

  CLEAR: GT_BOTTOM.
  LOOP AT GT_OBOTTOM INTO DATA(LS_OB) WHERE ZVERS_NO = GV_VERSNO.
    CLEAR: GS_BOTTOM.
    MOVE-CORRESPONDING LS_OB TO GS_BOTTOM.

    APPEND GS_BOTTOM TO GT_BOTTOM.
  ENDLOOP.

  SORT GT_BOTTOM BY ZREQ_NO ZREQ_TYPE VBELN POSNR AUFNR PMATN ZOPER_SEQ.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_BOTTOM_ALV_0101
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_BOTTOM_ALV_0101.
  IF GO_GRID_0101 IS NOT BOUND.
    PERFORM SET_OBJECT_GRID_0101.
    PERFORM SET_LAYOUT_GRID_0101.
    PERFORM SET_FIELDCAT_GRID_0101.
    PERFORM EXCLUDE_OF_TOOLBAR_GRID_0101.
    PERFORM CALL_GRID_0101_DISPLAY.
  ELSE.
    PERFORM REF_ALV_RTN USING GO_GRID_0101.
  ENDIF.
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
* bottom 컨테이너
  CALL METHOD GO_SPLITTER->GET_CONTAINER
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
*& Form SET_LAYOUT_GRID_0101
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_LAYOUT_GRID_0101 .
  DATA: LV_TITLE TYPE LVC_TITLE.

  LV_TITLE = |산출 버전 번호 : | && GV_VERSNO.

  CLEAR GS_LAYOUT_0101.
  GS_LAYOUT_0101-ZEBRA      = GC_X.
  GS_LAYOUT_0101-COL_OPT    = GC_X.
  GS_LAYOUT_0101-CWIDTH_OPT = GC_X.
  GS_LAYOUT_0101-GRID_TITLE = LV_TITLE.
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
  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      I_PROGRAM_NAME         = SY-REPID
      I_INCLNAME             = 'ZGTPPR2210TOP'
      I_INTERNAL_TABNAME     = 'GS_BOTTOM'
    CHANGING
      CT_FIELDCAT            = LT_FCAT_SLIS
    EXCEPTIONS
      INCONSISTENT_INTERFACE = 1
      PROGRAM_ERROR          = 2
      OTHERS                 = 3.

  CALL FUNCTION 'LVC_TRANSFER_FROM_SLIS'
    EXPORTING
      IT_FIELDCAT_ALV = LT_FCAT_SLIS
    IMPORTING
      ET_FIELDCAT_LVC = GT_FIELDCAT_0101[]
    TABLES
      IT_DATA         = GT_BOTTOM
    EXCEPTIONS
      OTHERS          = 1.

  LOOP AT GT_FIELDCAT_0101 ASSIGNING FIELD-SYMBOL(<LS_FCAT>).
    CASE <LS_FCAT>-FIELDNAME.
      WHEN 'ZREQ_NO'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F13. "산출대상번호
        <LS_FCAT>-JUST = GC_C.
      WHEN 'ZREQ_TYPENM'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F14. "산출구분명
        <LS_FCAT>-JUST = GC_L.
      WHEN 'VBELN'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F15. "판매오더번호
        <LS_FCAT>-JUST = GC_C.
      WHEN 'POSNR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F16. "판매오더품목
        <LS_FCAT>-JUST = GC_C.
      WHEN 'AUFNR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F17. "생산오더번호(제품)
        <LS_FCAT>-JUST = GC_C.
      WHEN 'ZMANUAL_NO'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F18. "수기등록번호
        <LS_FCAT>-JUST = GC_C.
      WHEN 'PMATN'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F19. "산출품목코드
        <LS_FCAT>-JUST = GC_C.
      WHEN 'PMAKT'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F20. "산출품목내역
        <LS_FCAT>-JUST = GC_L.
      WHEN 'PMENG'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F21. "산출수량
        <LS_FCAT>-JUST = GC_R.
      WHEN 'PMEIN'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F22. "산출단위
        <LS_FCAT>-JUST = GC_C.
      WHEN 'ZOPER_SEQ'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F23. "공정순번
        <LS_FCAT>-JUST = GC_C.
      WHEN 'ARBPL'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F24. "작업장
        <LS_FCAT>-JUST = GC_C.
      WHEN 'KTEXT'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F25. "작업장내역
        <LS_FCAT>-JUST = GC_L.
      WHEN 'MATNR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F26. "공정품목코드
        <LS_FCAT>-JUST = GC_C.
      WHEN 'MAKTX'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F27. "공정품목내역
        <LS_FCAT>-JUST = GC_L.
      WHEN 'MENGE'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F28. "공정수량
        <LS_FCAT>-JUST = GC_R.
      WHEN 'MEINS'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F29. "수량단위
        <LS_FCAT>-JUST = GC_C.
      WHEN 'ZTIME'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F30. "소요시간
        <LS_FCAT>-JUST = GC_R.
      WHEN 'ZUNIT'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F31. "시간단위
        <LS_FCAT>-JUST = GC_C.
      WHEN OTHERS.
        <LS_FCAT>-NO_OUT = GC_X.
    ENDCASE.

    CLEAR: <LS_FCAT>-KEY.

  ENDLOOP.
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
      IT_OUTTAB            = GT_BOTTOM
      IT_FIELDCATALOG      = GT_FIELDCAT_0101.
ENDFORM.
