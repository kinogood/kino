*&---------------------------------------------------------------------*
*& Include          ZGTSDR9007F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form GET_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_DATA .

  CLEAR: GT_ODATA.
  SELECT DISTINCT VBELN, POSNR, VKGRP_ANA
    FROM VBAP
   WHERE VBELN IN @S_VBELN
     AND AUART_ANA EQ 'ZCS'
     AND PAOBJNR EQ '0000000000'
   ORDER BY VBELN, POSNR
    INTO CORRESPONDING FIELDS OF TABLE @GT_ODATA.

  CLEAR: GT_DATA.
  LOOP AT GT_ODATA INTO DATA(LS_O).
    MOVE-CORRESPONDING LS_O TO GS_DATA.

    COLLECT GS_DATA INTO GT_DATA.

    CLEAR: LS_O, GS_DATA.
  ENDLOOP.

  LOOP AT GT_DATA ASSIGNING FIELD-SYMBOL(<FS_S>).
    <FS_S>-CNT = REDUCE I(
                 INIT SUM = 0 FOR LS_ODATA IN GT_ODATA
                 WHERE ( VBELN = <FS_S>-VBELN )
                 NEXT SUM = SUM + 1 ).
  ENDLOOP.

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
         GV_OK_CODE, GV_DBCNT,
         GT_DATA[], GT_ODATA[].

  CALL METHOD GO_CONTAIN_0100->FREE.
  CLEAR : GO_CONTAIN_0100, GO_GRID_0100.
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
  GS_LAYOUT_0100-NO_ROWINS  = GC_X.
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
      I_INCLNAME             = 'ZGTSDR9007TOP'
      I_INTERNAL_TABNAME     = 'GS_DATA'
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
      IT_DATA         = GT_DATA
    EXCEPTIONS
      OTHERS          = 1.

  LOOP AT GT_FIELDCAT_0100 ASSIGNING FIELD-SYMBOL(<LS_FCAT>).
    CASE <LS_FCAT>-FIELDNAME.
      WHEN 'VBELN'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F01. "판매문서
        <LS_FCAT>-JUST = GC_C.
      WHEN 'VKGRP_ANA'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F02. "영업그룹
        <LS_FCAT>-JUST = GC_C.
      WHEN 'ZMSG'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F03. "메세지
        <LS_FCAT>-JUST = GC_L.
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
      IT_OUTTAB            = GT_DATA
      IT_FIELDCATALOG      = GT_FIELDCAT_0100.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROCESS_EXEC
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PROCESS_EXEC .
  DATA: LT_ROW_NO TYPE LVC_T_ROID WITH HEADER LINE,
        L_ANSWER  TYPE CHAR01.

  FIELD-SYMBOLS: <FS_S> LIKE GS_DATA.

  CLEAR: L_ANSWER.

  PERFORM SEL_ROW_RTN TABLES LT_ROW_NO
                      USING  GO_GRID_0100.

  IF LT_ROW_NO[] IS INITIAL.
    MESSAGE S003 DISPLAY LIKE GC_W
       WITH TEXT-M01. "레코드를 선택하세요.
    EXIT.
  ENDIF.

  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      TITLEBAR              = TEXT-T02 "S/O 수익성 세그먼트 갱신
      TEXT_QUESTION         = TEXT-T03 "보관품 S/O 수익성 세그먼트 갱신을 수행하시겠습니까?
      DISPLAY_CANCEL_BUTTON = SPACE
    IMPORTING
      ANSWER                = L_ANSWER.

  IF L_ANSWER = '1'.
    LOOP AT LT_ROW_NO.
      READ TABLE GT_DATA ASSIGNING <FS_S> INDEX LT_ROW_NO-ROW_ID.

      PERFORM EXEC_PA_UPDATE USING <FS_S>.

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

*--------------------------------------------------------------------*

  CLEAR: LT_INDEX_ROWS, LT_INDEX_ROWS[],
         LT_ROW_NO, LT_ROW_NO[].

  PR_ALV->GET_SELECTED_ROWS(
    IMPORTING
      ET_INDEX_ROWS = LT_INDEX_ROWS
      ET_ROW_NO     = LT_ROW_NO ).

  PT_ROW_NO[] = LT_ROW_NO[].

ENDFORM.
*&---------------------------------------------------------------------*
*& Form REF_ALV_RTN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GO_GRID_0100
*&---------------------------------------------------------------------*
FORM REF_ALV_RTN  USING    PO_GRID TYPE REF TO CL_GUI_ALV_GRID.

  DATA LS_STABLE TYPE LVC_S_STBL.

  LS_STABLE-ROW = 'X'.
  LS_STABLE-COL = 'X'.

  CASE PO_GRID.
    WHEN GO_GRID_0100.
      CALL METHOD PO_GRID->SET_FRONTEND_LAYOUT
        EXPORTING
          IS_LAYOUT = GS_LAYOUT_0100.
  ENDCASE.

  CALL METHOD PO_GRID->REFRESH_TABLE_DISPLAY
    EXPORTING
      IS_STABLE = LS_STABLE
    EXCEPTIONS
      FINISHED  = 1
      OTHERS    = 2.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form DYNPRO1
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> P_
*&      --> P_
*&---------------------------------------------------------------------*
FORM DYNPRO1  USING DYNBEGIN NAME VALUE.
  CLEAR BDCDATA.
  IF DYNBEGIN = 'X'.
    MOVE: NAME  TO BDCDATA-PROGRAM,
          VALUE TO BDCDATA-DYNPRO,
          'X'   TO BDCDATA-DYNBEGIN.
    APPEND BDCDATA.
  ELSE.
    MOVE: NAME  TO BDCDATA-FNAM,
          VALUE TO BDCDATA-FVAL.
    APPEND BDCDATA.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form EXEC_PA_UPDATE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> <FS_S>
*&---------------------------------------------------------------------*
FORM EXEC_PA_UPDATE  USING    P_LINE LIKE GS_DATA.

  DATA: LV_MSG TYPE STRING.

  CLEAR: BDCDATA, BDCDATA[], MESSTAB, MESSTAB[],
         GV_INDEX, GV_TEXT.

  PERFORM DYNPRO1 USING:
          'X' 'SAPMV45A'    '0102',
          ' ' 'BDC_OKCODE'  '/00',
          ' ' 'VBAK-VBELN'  P_LINE-VBELN.

  PERFORM DYNPRO1 USING:
          'X' 'SAPMV45A'    '4001',
          ' ' 'BDC_OKCODE'  '=PKNT',
          ' ' 'BDC_CURSOR'  'VBAP-POSNR(01)'.

  DO P_LINE-CNT TIMES.

    PERFORM DYNPRO1 USING:
            'X' 'SAPMV45A'    '4003',
            ' ' 'BDC_OKCODE'  '=COBL_XERGO'.

    PERFORM DYNPRO1 USING:
            'X' 'SAPLKEAK'    '0400',
            ' ' 'BDC_CURSOR'  'RKEAK-FIELD(03)',
            ' ' 'BDC_OKCODE'  '=P+'.

    PERFORM DYNPRO1 USING:
            'X' 'SAPLKEAK'        '0400',
            ' ' 'BDC_OKCODE'      '=WEIT',
            ' ' 'RKEAK-FIELD(15)' P_LINE-VKGRP_ANA.

    PERFORM DYNPRO1 USING:
            'X' 'SAPMV45A'    '4003',
            ' ' 'BDC_OKCODE'  '=POS+'.

  ENDDO.

  PERFORM DYNPRO1 USING:
          'X' 'SAPMV45A'    '4003',
          ' ' 'BDC_OKCODE'  '=SICH'.

  GS_PARAMS-DISMODE  = 'N'.   " 처리모드
  GS_PARAMS-UPDMODE  = 'S'.   " 갱신세션
  GS_PARAMS-CATTMODE = ' '.   " CATT모드
  GS_PARAMS-DEFSIZE  = ' '.   " 기본화면
  GS_PARAMS-RACOMMIT = ' '.   " COMMIT 이후 지속
  GS_PARAMS-NOBINPT  = 'X'.   " BI 세션

  CALL TRANSACTION 'VA02'
             USING BDCDATA
           OPTIONS FROM GS_PARAMS
          MESSAGES INTO MESSTAB.

  CLEAR: LV_MSG.
  READ TABLE MESSTAB WITH KEY MSGTYP = GC_E.

  IF SY-SUBRC EQ 0.
    CALL FUNCTION 'FORMAT_MESSAGE'
      EXPORTING
        ID   = MESSTAB-MSGID
        LANG = SY-LANGU
        NO   = MESSTAB-MSGNR
        V1   = MESSTAB-MSGV1
        V2   = MESSTAB-MSGV2
        V3   = MESSTAB-MSGV3
        V4   = MESSTAB-MSGV4
      IMPORTING
        MSG  = LV_MSG.

    P_LINE-ZMSG = LV_MSG.

  ELSE.
    READ TABLE MESSTAB WITH KEY MSGTYP = GC_S
                                MSGID  = 'V1'
                                MSGNR  = '311'.

    IF SY-SUBRC EQ 0.
      CALL FUNCTION 'FORMAT_MESSAGE'
        EXPORTING
          ID   = MESSTAB-MSGID
          LANG = SY-LANGU
          NO   = MESSTAB-MSGNR
          V1   = MESSTAB-MSGV1
          V2   = MESSTAB-MSGV2
          V3   = MESSTAB-MSGV3
          V4   = MESSTAB-MSGV4
        IMPORTING
          MSG  = LV_MSG.

    ELSE.
      READ TABLE MESSTAB INDEX 1.

      CALL FUNCTION 'FORMAT_MESSAGE'
        EXPORTING
          ID   = MESSTAB-MSGID
          LANG = SY-LANGU
          NO   = MESSTAB-MSGNR
          V1   = MESSTAB-MSGV1
          V2   = MESSTAB-MSGV2
          V3   = MESSTAB-MSGV3
          V4   = MESSTAB-MSGV4
        IMPORTING
          MSG  = LV_MSG.

    ENDIF.

    P_LINE-ZMSG = LV_MSG.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form BATCH_EXEC
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM BATCH_EXEC .

  READ TABLE GT_DATA ASSIGNING FIELD-SYMBOL(<FS_S>) INDEX 1.
  PERFORM EXEC_PA_UPDATE USING <FS_S>.

  MESSAGE S000 WITH <FS_S>-ZMSG.

ENDFORM.
