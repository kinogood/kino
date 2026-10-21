*&---------------------------------------------------------------------*
*& Include          ZGTSDR1410F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form CREATE_CONTROLS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CREATE_CONTROLS .


  G_CUSTOM_CONTAINER = NEW #( CONTAINER_NAME = 'G_CON' ).

  GRID = NEW #( I_PARENT = G_CUSTOM_CONTAINER ).


*  G_DOCKING_CONTAINER = NEW #( REPID     = SY-REPID
*                               DYNNR     = SY-DYNNR
*                               EXTENSION = 500
*                               SIDE      = CL_GUI_DOCKING_CONTAINER=>DOCK_AT_BOTTOM ).

***--SPLIT
*  G_SPLITTER = NEW #( PARENT = G_DOCKING_CONTAINER ROWS = 2 COLUMNS = 1 ).
*
*  G_CONTAINER  = G_SPLITTER->GET_CONTAINER( ROW = 1 COLUMN = 1 ).
*  G_CONTAINER2 = G_SPLITTER->GET_CONTAINER( ROW = 2 COLUMN = 1 ).
*
*  G_SPLITTER2 = NEW #( PARENT = G_CONTAINER2 ROWS = 1 COLUMNS = 2 ) .
*  DATA(L_B_LEFT) = G_SPLITTER2->GET_CONTAINER( ROW = 1 COLUMN = 1 ).
*  DATA(L_B_RIGHT) = G_SPLITTER2->GET_CONTAINER( ROW = 1 COLUMN = 2 ).
*
*  G_SPLITTER->SET_ROW_MODE( MODE = CL_GUI_SPLITTER_CONTAINER=>MODE_RELATIVE ).
*  G_SPLITTER->SET_ROW_HEIGHT( ID = 1 HEIGHT = 50 ).
*  G_SPLITTER->SET_ROW_HEIGHT( ID = 2 HEIGHT = 50 ).
*
*  GRID  = NEW #( I_PARENT = G_CONTAINER ).
*  GRID2 = NEW #( I_PARENT = L_B_LEFT ).
*  GRID3 = NEW #( I_PARENT = L_B_RIGHT ).
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_EVENT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_EVENT .

  GRID->REGISTER_EDIT_EVENT( EXPORTING I_EVENT_ID =
                                 CL_GUI_ALV_GRID=>MC_EVT_MODIFIED ).
  GRID->REGISTER_EDIT_EVENT( EXPORTING I_EVENT_ID =
                                 CL_GUI_ALV_GRID=>MC_EVT_ENTER ).

  CREATE OBJECT EVENT_RECEIVER.
*  SET HANDLER EVENT_RECEIVER->HANDLE_TOP_OF_PAGE  FOR GRID.
*  SET HANDLER EVENT_RECEIVER->HANDLE_DOUBLE_CLICK FOR GRID.
  SET HANDLER EVENT_RECEIVER->HANDLE_HOTSPOT_CLICK FOR GRID.
  SET HANDLER EVENT_RECEIVER->HANDLE_DATA_CHANGED_FINISHED FOR GRID.
  SET HANDLER EVENT_RECEIVER->HANDLE_TOOLBAR      FOR GRID.
  SET HANDLER EVENT_RECEIVER->HANDLE_USER_COMMAND FOR GRID.
  SET HANDLER EVENT_RECEIVER->HANDLE_DATA_CHANGED FOR GRID.
  SET HANDLER EVENT_RECEIVER->HANDLE_ONF4         FOR GRID.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form ALV_LAYOUT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM ALV_LAYOUT CHANGING PS_LAYOUT TYPE LVC_S_LAYO.
  PS_LAYOUT-SEL_MODE   = 'A'.
  PS_LAYOUT-ZEBRA      = 'X'.
  PS_LAYOUT-CWIDTH_OPT = 'X'.
  PS_LAYOUT-STYLEFNAME = 'CELLTAB'.
  PS_LAYOUT-CTAB_FNAME = 'CELLCOL'.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form EXCLUDE_TB_FUNCTIONS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- GT_EXCLUDE
*&---------------------------------------------------------------------*
FORM EXCLUDE_TB_FUNCTIONS  CHANGING PT_EXCLUDE TYPE UI_FUNCTIONS.
  DATA LS_EXCLUDE TYPE UI_FUNC.

  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_INSERT_ROW.
  APPEND LS_EXCLUDE TO PT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_UNDO.
  APPEND LS_EXCLUDE TO PT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_COPY_ROW.
  APPEND LS_EXCLUDE TO PT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_DELETE_ROW.
  APPEND LS_EXCLUDE TO PT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_INSERT_ROW.
  APPEND LS_EXCLUDE TO PT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_COPY.
  APPEND LS_EXCLUDE TO PT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_CUT.
  APPEND LS_EXCLUDE TO PT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_PASTE.
  APPEND LS_EXCLUDE TO PT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_PASTE_NEW_ROW.
  APPEND LS_EXCLUDE TO PT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_APPEND_ROW.
  APPEND LS_EXCLUDE TO PT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_GRAPH.
  APPEND LS_EXCLUDE TO PT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_INFO.
  APPEND LS_EXCLUDE TO PT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_DETAIL.
  APPEND LS_EXCLUDE TO PT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_REFRESH.
  APPEND LS_EXCLUDE TO PT_EXCLUDE.
*  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_EXCL_ALL.
*  APPEND LS_EXCLUDE TO PT_EXCLUDE.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_VARIANT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- GS_VARIANT
*&---------------------------------------------------------------------*
FORM SET_VARIANT  CHANGING PS_VARIANT TYPE DISVARIANT.
  PS_VARIANT-REPORT   = SY-CPROG.
  PS_VARIANT-USERNAME = SY-UNAME.
  PS_VARIANT-HANDLE   = SY-DYNNR.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form FIELDCAT_INIT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM FIELDCAT_INIT .
  DATA(LO_TABLE) = CAST CL_ABAP_TABLEDESCR( CL_ABAP_TYPEDESCR=>DESCRIBE_BY_DATA( GT_DATA ) ).
  DATA(LO_STRUC) = CAST CL_ABAP_STRUCTDESCR( LO_TABLE->GET_TABLE_LINE_TYPE( ) ).
  DATA(LT_DFIES) = CL_SALV_DATA_DESCR=>READ_STRUCTDESCR( LO_STRUC ).

  GT_FIELDCAT = CORRESPONDING #( LT_DFIES MAPPING REF_TABLE = REFTABLE
                                                  REF_FIELD = REFFIELD ).

  DEFINE _FIELDCAT.
    CASE &1-fieldname.
      WHEN &2.
     &1-coltext  = &3.
     &1-checkbox = &4.
     &1-icon     = &5.
     &1-hotspot  = &6.
     &1-edit     = &7.
    ENDCASE.
  END-OF-DEFINITION.


  LOOP AT GT_FIELDCAT ASSIGNING FIELD-SYMBOL(<FS_FCAT>).
*                        FIELDNAME    COLTEXT  CHECKOBX ICON HOTSPOT EDIT
    _FIELDCAT :
                <FS_FCAT> 'CHK  '     TEXT-F99 'X'      ' '  ' '    'X',
                <FS_FCAT> 'VBELN'     TEXT-F19 ' '      ' '  'X'    ' ',
                <FS_FCAT> 'POSNR'     TEXT-F01 ' '      ' '  ' '    ' ',
                <FS_FCAT> 'ETENR'     TEXT-F02 ' '      ' '  ' '    ' ',
                <FS_FCAT> 'ARKTX'     TEXT-F03 ' '      ' '  ' '    ' ',
                <FS_FCAT> 'SPEC'      TEXT-F04 ' '      ' '  ' '    ' ',
                <FS_FCAT> 'EDATU'     TEXT-F05 ' '      ' '  ' '    ' ',
                <FS_FCAT> 'EDATU_N'   TEXT-F06 ' '      ' '  ' '    'X',
                <FS_FCAT> 'KWMENG '   TEXT-F07 ' '      ' '  ' '    ' ',
                <FS_FCAT> 'VRKME'     TEXT-F08 ' '      ' '  ' '    ' ',
                <FS_FCAT> 'KWMENG_N'  TEXT-F09 ' '      ' '  ' '    'X',
                <FS_FCAT> 'OM_SM'     TEXT-F10 ' '      ' '  ' '    ' ',
                <FS_FCAT> 'UPDRQ'     TEXT-F11 ' '      ' '  'X'    ' ',
                <FS_FCAT> 'STATUS_SM' TEXT-F12 ' '      'X'  ' '    ' ',
                <FS_FCAT> 'AUFNR'     TEXT-F13 ' '      ' '  'X'    ' ',
                <FS_FCAT> 'CO_POSNR'  TEXT-F14 ' '      ' '  ' '    ' ',
                <FS_FCAT> 'STATUS_AU' TEXT-F15 ' '      'X'  ' '    ' ',
                <FS_FCAT> 'EBELN'     TEXT-F16 ' '      ' '  'X'    ' ',
                <FS_FCAT> 'EBELP'     TEXT-F17 ' '      ' '  ' '    ' ',
                <FS_FCAT> 'STATUS_PO' TEXT-F18 ' '      'X'  ' '    ' '.

    CASE <FS_FCAT>-FIELDNAME.
      WHEN 'BSTYP' OR 'FIXMG' OR 'LIFSP' OR 'WERKS'.
        <FS_FCAT>-NO_OUT = ABAP_TRUE.
    ENDCASE.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_SORT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_SORT .

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
  CLEAR : GS_DATA. REFRESH GT_DATA.
*--------------------------------------------------------------------*
**--  초기 값 체크
*--------------------------------------------------------------------*
  PERFORM GET_CHECK_DATA.
  CHECK GV_ERROR IS INITIAL.

*--------------------------------------------------------------------*
*1) 판매오더번호와 요청구분, 정정사유, 세부원인을 입력하고 실행하면
*    판매처 정보와 품목의 Data 를 조회 해 준다.
*      VBAK + VBAP + VBEP
*--------------------------------------------------------------------*

  SELECT FROM VBAK AS A INNER JOIN VBAP AS B
                       ON A~VBELN EQ B~VBELN
                        INNER JOIN VBEP AS C
                       ON A~VBELN EQ C~VBELN
                      AND B~POSNR EQ C~POSNR
         FIELDS A~VBELN,
                B~POSNR, B~ARKTX, B~MATNR,
                C~ETENR, C~WMENG AS KWMENG, C~VRKME, C~EDATU,
                B~FIXMG, C~LIFSP,
                C~BANFN, C~BNFPO,
                CASE  WHEN ( B~FIXMG = 'X'  OR C~LIFSP <> @SPACE ) THEN 'SM'
                      ELSE 'OM' END AS OM_SM
        WHERE A~VBELN EQ @P_VBELN
          INTO TABLE @DATA(LT_DATA).


  IF LT_DATA[] IS INITIAL.
    MESSAGE S010 DISPLAY LIKE 'E'.
    EXIT.
  ENDIF.

  "SM LINK 체크
  SELECT FROM @LT_DATA AS Z INNER JOIN ZGTPPT3360 AS A
                            ON Z~VBELN EQ A~VBELN
                           AND Z~POSNR EQ A~POSNR
    FIELDS Z~VBELN, Z~POSNR, A~UPDRQ, A~WERKS,
           CASE WHEN A~UPDRQ <> @SPACE THEN '@5B@' ELSE ' ' END AS STATUS_SM
      INTO TABLE @DATA(LT_3360).

  "생산오더 체크
  SELECT FROM @LT_DATA AS Z INNER JOIN AFPO AS A
                            ON Z~VBELN EQ A~KDAUF
                           AND Z~POSNR EQ A~KDPOS
         FIELDS Z~VBELN, Z~POSNR, A~AUFNR, A~POSNR AS CO_POSNR,
                CASE WHEN A~AUFNR <> @SPACE THEN '@5B@' ELSE ' ' END AS STATUS_AU
      INTO TABLE @DATA(LT_AFPO).

  "구매오더 체크
  DATA(LT_DATA2) = LT_DATA[].
  SORT LT_DATA2 BY VBELN POSNR BANFN BNFPO.
  DELETE LT_DATA2 WHERE BANFN EQ SPACE.

  IF LT_DATA2[] IS NOT INITIAL.
    SELECT FROM @LT_DATA2 AS Z  INNER JOIN EKPO AS A
                              ON Z~BANFN EQ A~BANFN
                             AND Z~BNFPO EQ A~BNFPO
           FIELDS Z~VBELN, Z~POSNR, A~EBELN, A~EBELP,
                  CASE WHEN A~EBELN <> @SPACE THEN '@5B@' ELSE ' ' END AS STATUS_PO
         INTO TABLE @DATA(LT_EKPO).
  ENDIF.

  "특성 체크 ( SPEC )
  DATA(LT_DATA3) = LT_DATA[].
  SORT LT_DATA3 BY MATNR.
  DELETE ADJACENT DUPLICATES FROM LT_DATA3 COMPARING MATNR.
  IF LT_DATA3[] IS NOT INITIAL.
*    SELECT FROM LT_DATA3 AS Z INNER JOIN MARA AS A
*                          ON Z~MATNR EQ A~MATNR
*                              INNER JOIN KSSK AS B
*                          ON A~CUOBF EQ B~OBJEK
*                              INNER JOIN KLAH AS C
*                          ON C~CLINT EQ B~CLINT
*           FIELDS
  ENDIF.

  SORT LT_DATA BY VBELN POSNR.
  SORT LT_3360 BY VBELN POSNR.
  SORT LT_AFPO BY VBELN POSNR.
  SORT LT_EKPO BY VBELN POSNR.

*--------------------------------------------------------------------*
  "DATA MERGE
*--------------------------------------------------------------------*
  GT_DATA = VALUE #(
      FOR LS_DATA IN LT_DATA
      LET LS_3360 = VALUE #( LT_3360[ VBELN = LS_DATA-VBELN
                                      POSNR = LS_DATA-POSNR ] OPTIONAL )
          LS_AFPO = VALUE #( LT_AFPO[ VBELN = LS_DATA-VBELN
                                      POSNR = LS_DATA-POSNR ] OPTIONAL )
          LS_EKPO = VALUE #( LT_EKPO[ VBELN = LS_DATA-VBELN
                                      POSNR = LS_DATA-POSNR ] OPTIONAL )
      IN ( VALUE #( BASE CORRESPONDING #( LS_DATA )

          UPDRQ     = LS_3360-UPDRQ
          STATUS_SM = LS_3360-STATUS_SM

          AUFNR     = LS_AFPO-AUFNR
          CO_POSNR  = LS_AFPO-CO_POSNR
          STATUS_AU = LS_AFPO-STATUS_AU

          EBELN     = LS_EKPO-EBELN
          EBELP     = LS_EKPO-EBELP
          STATUS_PO = LS_EKPO-STATUS_PO

          EDATU_N   = COND #( WHEN P_EDATUN IS NOT INITIAL THEN P_EDATUN ELSE SPACE )
          CELLTAB   = COND #( WHEN ( P_REQT = 'H' OR P_REQT = 'J' )
                              THEN VALUE LVC_T_STYL( ( FIELDNAME = 'KWMENG_N'  STYLE = CL_GUI_ALV_GRID=>MC_STYLE_ENABLED )
                                                     ( FIELDNAME = 'EDATU_N'   STYLE = CL_GUI_ALV_GRID=>MC_STYLE_ENABLED ) )

                               ELSE VALUE LVC_T_STYL( ( FIELDNAME = 'KWMENG_N'  STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED )
                                                      ( FIELDNAME = 'EDATU_N'   STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED ) )

                              )

        )
      )
    ).

  SORT GT_DATA BY VBELN POSNR ETENR.
*--------------------------------------------------------------------*

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_CHECK_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_CHECK_DATA .
  "조건에 안맞는 경우 오류 메시지로 띄운다.

  IF P_REQT IS NOT INITIAL.
    CASE P_REQT.
      WHEN 'D'.
        CASE P_REASON.
          WHEN '06' OR '02'.
          WHEN OTHERS.
            MESSAGE S000 DISPLAY LIKE 'E' WITH TEXT-E02.
            "요청구분에 맞는 정정사유가 아닙니다.
            GV_ERROR = ABAP_TRUE.
        ENDCASE.
      WHEN 'H' OR 'J'.
        IF P_REQT NE P_REASON.
          MESSAGE S000 DISPLAY LIKE 'E' WITH TEXT-E02.
          "요청구분에 맞는 정정사유가 아닙니다.
          GV_ERROR = ABAP_TRUE.
        ENDIF.
      WHEN 'A'.
        CASE P_REASON.
          WHEN 'A1' OR 'A2'.
          WHEN OTHERS.
            MESSAGE S000 DISPLAY LIKE 'E' WITH TEXT-E02.
            "요청구분에 맞는 정정사유가 아닙니다.
            GV_ERROR = ABAP_TRUE.
        ENDCASE.
    ENDCASE.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SELECTION_SCREEN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SELECTION_SCREEN .
  LOOP AT SCREEN.
    CASE SCREEN-GROUP1.
      WHEN 'KN'.    "판매처 INPUT 제외
        SCREEN-INPUT = 0.
        MODIFY SCREEN.
    ENDCASE.
    CASE SCREEN-NAME.
      WHEN 'P_VBELN' OR 'P_REQT' OR 'P_REASON' OR 'P_READTL'.
        SCREEN-REQUIRED = 2.
        MODIFY SCREEN.
    ENDCASE.

  ENDLOOP.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form F4_REASON
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- P_REASON
*&---------------------------------------------------------------------*
FORM F4_REASON  CHANGING P_P_REASON.

  DATA: LT_DYNPFIELDS TYPE TABLE OF DYNPREAD,
        LS_DYNPFIELD  TYPE DYNPREAD,
        LV_REQTYPE    TYPE ZGTSDT1410-REQTYPE.
  CLEAR : LS_DYNPFIELD, LV_REQTYPE.
  REFRESH LT_DYNPFIELDS.


  LS_DYNPFIELD-FIELDNAME = 'P_REQT'.
  APPEND LS_DYNPFIELD TO LT_DYNPFIELDS.

  CALL FUNCTION 'DYNP_VALUES_READ'
    EXPORTING
      DYNAME     = SY-REPID                 " Program Name
      DYNUMB     = SY-DYNNR                 " Screen Number
    TABLES
      DYNPFIELDS = LT_DYNPFIELDS.                 " Table for Reading Current Screen Values

  READ TABLE LT_DYNPFIELDS INTO LS_DYNPFIELD INDEX 1.
  IF SY-SUBRC EQ 0.
    LV_REQTYPE = LS_DYNPFIELD-FIELDVALUE.
  ELSE.
    CLEAR LV_REQTYPE.
  ENDIF.

  SELECT FROM DD07V FIELDS DISTINCT DOMVALUE_L, DDTEXT
    WHERE DOMNAME EQ 'ZREASON_SD'
      AND DDLANGUAGE EQ @SY-LANGU
         INTO TABLE @DATA(LT_F4).
  SORT LT_F4 BY DOMVALUE_L.

  "요청구분이 존재할시 정정사유를 구분하여 보여준다.
  CASE LV_REQTYPE.
    WHEN 'D'.
      DELETE LT_F4 WHERE DOMVALUE_L NE '06'     "생산불가
                     AND DOMVALUE_L NE '02' .   "원청발주 취소
    WHEN 'H'.
      DELETE LT_F4 WHERE DOMVALUE_L NE 'H'.     "수량정정
    WHEN 'J'.
      DELETE LT_F4 WHERE DOMVALUE_L NE 'J'.     "납기정정
    WHEN 'A'.
      DELETE LT_F4 WHERE DOMVALUE_L NE 'A1'     "OM->SM
                     AND DOMVALUE_L NE 'A2' .   "SM->OM
  ENDCASE.

  " F4 팝업 호출
  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      RETFIELD        = 'DOMVALUE_L'         " 인터널 테이블에서 화면으로 넘겨줄 필드명 (대문자)
      DYNPPROG        = SY-REPID        " 현재 프로그램 ID
      DYNPNR          = SY-DYNNR        " 현재 화면 번호
      DYNPROFIELD     = 'P_REQT'   " 값이 들어갈 화면 필드 이름 (대문자)
      VALUE_ORG       = 'S'             " 'S': 구조체 기반(자동 헤더/타이틀), 'C': 단일 셀
    TABLES
      VALUE_TAB       = LT_F4           " F4 목록 인터널 테이블
    EXCEPTIONS
      PARAMETER_ERROR = 1
      NO_VALUES_FOUND = 2
      OTHERS          = 3.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_KUNNR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_KUNNR .
  DATA: LT_DYNPFIELDS TYPE TABLE OF DYNPREAD,
        LS_DYNPFIELD  TYPE DYNPREAD,
        LV_VBELN      TYPE VBAK-VBELN.
  CLEAR : LS_DYNPFIELD, LV_VBELN.
  REFRESH LT_DYNPFIELDS.

  "판매오더 입력시 고객처 고객처명 자동 입력
  LS_DYNPFIELD-FIELDNAME = 'P_VBELN'.
  APPEND LS_DYNPFIELD TO LT_DYNPFIELDS.

  CALL FUNCTION 'DYNP_VALUES_READ'
    EXPORTING
      DYNAME     = SY-REPID                 " Program Name
      DYNUMB     = SY-DYNNR                 " Screen Number
    TABLES
      DYNPFIELDS = LT_DYNPFIELDS.                 " Table for Reading Current Screen Values

  READ TABLE LT_DYNPFIELDS INTO LS_DYNPFIELD INDEX 1.
  IF SY-SUBRC EQ 0.
    LV_VBELN = LS_DYNPFIELD-FIELDVALUE.
  ELSE.
    CLEAR LV_VBELN.
  ENDIF.

  SELECT SINGLE FROM VBAK AS A INNER JOIN KNA1 AS B
                              ON A~KUNNR EQ B~KUNNR
                FIELDS A~KUNNR, B~NAME1
    WHERE A~VBELN EQ @LV_VBELN
    INTO ( @P_KUNNR, @GV_NAME1 ).
ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_REQTYPE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_REQTYPE .
  DATA: LT_DYNPFIELDS TYPE TABLE OF DYNPREAD,
        LS_DYNPFIELD  TYPE DYNPREAD,
        LV_REQTYPE    TYPE ZGTSDT1410-REQTYPE.
  CLEAR : LS_DYNPFIELD, LV_REQTYPE.
  REFRESH LT_DYNPFIELDS.

  "요청구분별로 표시 1개인 경우는 자동입력처리

  LS_DYNPFIELD-FIELDNAME = 'P_REQT'.
  APPEND LS_DYNPFIELD TO LT_DYNPFIELDS.

  CALL FUNCTION 'DYNP_VALUES_READ'
    EXPORTING
      DYNAME     = SY-REPID                 " Program Name
      DYNUMB     = SY-DYNNR                 " Screen Number
    TABLES
      DYNPFIELDS = LT_DYNPFIELDS.                 " Table for Reading Current Screen Values

  READ TABLE LT_DYNPFIELDS INTO LS_DYNPFIELD INDEX 1.
  IF SY-SUBRC EQ 0.
    LV_REQTYPE = LS_DYNPFIELD-FIELDVALUE.
  ELSE.
    CLEAR LV_REQTYPE.
  ENDIF.

  CASE LV_REQTYPE.
    WHEN 'H' OR 'J'.
      IF P_REASON IS INITIAL.
        P_REASON = LV_REQTYPE.
      ENDIF.
  ENDCASE.

  SELECT SINGLE FROM DD07V FIELDS DDTEXT
  WHERE DOMNAME EQ 'ZREQTYPE'
    AND DDLANGUAGE EQ @SY-LANGU
    AND DOMVALUE_L EQ @LV_REQTYPE
    INTO @GV_REQTT.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_REASON
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_REASON .
  DATA: LT_DYNPFIELDS TYPE TABLE OF DYNPREAD,
        LS_DYNPFIELD  TYPE DYNPREAD,
        LV_REASON     TYPE ZGTSDT1410-REASON.
  CLEAR : LS_DYNPFIELD, LV_REASON.
  REFRESH LT_DYNPFIELDS.
  CLEAR GV_ERROR.

  LS_DYNPFIELD-FIELDNAME = 'P_REASON'.
  APPEND LS_DYNPFIELD TO LT_DYNPFIELDS.

  CALL FUNCTION 'DYNP_VALUES_READ'
    EXPORTING
      DYNAME     = SY-REPID                 " Program Name
      DYNUMB     = SY-DYNNR                 " Screen Number
    TABLES
      DYNPFIELDS = LT_DYNPFIELDS.                 " Table for Reading Current Screen Values

  READ TABLE LT_DYNPFIELDS INTO LS_DYNPFIELD INDEX 1.
  IF SY-SUBRC EQ 0.
    LV_REASON = LS_DYNPFIELD-FIELDVALUE.
  ELSE.
    CLEAR LV_REASON.
  ENDIF.


  SELECT SINGLE FROM DD07V FIELDS DDTEXT
    WHERE DOMNAME EQ 'ZREASON_SD'
      AND DDLANGUAGE EQ @SY-LANGU
      AND DOMVALUE_L EQ @LV_REASON
         INTO @GV_REAT.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form DATA_SAVE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM DATA_SAVE .
  CLEAR GV_ERROR.
*--------------------------------------------------------------------*
**--  1) Check Data
*--------------------------------------------------------------------*
  PERFORM CHECK_DATA USING GV_ERROR.
  CHECK GV_ERROR IS INITIAL.

  DATA(LV_RETURN) = ''.
  PERFORM POP_UP_CONFIRM(ZLER0004) USING '< 확인 >'
                               '해당건 저장 하시겠습니까?'
                      CHANGING LV_RETURN.
  CHECK LV_RETURN = 'J'.

*--------------------------------------------------------------------*
**--  2) Update
*--------------------------------------------------------------------*
  DATA: LT_SAVE TYPE TABLE OF ZGTSDT1410.
  REFRESH LT_SAVE.

  LT_SAVE = VALUE #( FOR WA IN GT_DATA WHERE ( CHK = ABAP_TRUE )
                        ( VALUE #( BASE CORRESPONDING #( WA )
                                     REQNO   = '' "MAX 기준으로 갈지 확인 필요
                                     REQTYPE = P_REQT
                                     REQDATE = SY-DATLO
                                     REASON  = P_REASON
                                     READTL  = P_READTL
                                     CFMPP   = COND #( WHEN WA-BSTYP <> 'B' THEN 'A'
                                                       WHEN ( WA-STATUS_SM IS INITIAL
                                                        AND WA-AUFNR IS INITIAL  ) THEN 'Y'
                                                       ELSE SPACE )
                                     PSTAT   = 'A'
                                     CFMMM   = COND #( WHEN WA-BSTYP = 'B' THEN 'A'
                                                       WHEN WA-EBELN IS INITIAL THEN 'Y'
                                                       ELSE SPACE )
                                     FIXMG   = COND #( WHEN ( WA-FIXMG = 'X' OR WA-LIFSP <> SPACE ) THEN 'X'
                                                       ELSE SPACE )

                                     ERDAT  = SY-DATLO
                                     ERZET  = SY-TIMLO
                                     ERNAM  = SY-UNAME
                                     AEDAT  = SY-DATLO
                                     AEZET  = SY-TIMLO
                                     AENAM  = SY-UNAME
                                     ) ) ).

  CHECK LT_SAVE[] IS NOT INITIAL.
  MODIFY ZGTSDT1410 FROM TABLE LT_SAVE.
  IF SY-SUBRC EQ 0.
    COMMIT WORK AND WAIT.
    MESSAGE S011 .
  ELSE.
    ROLLBACK WORK.
    MESSAGE S012 DISPLAY LIKE 'E'.
  ENDIF.

*--------------------------------------------------------------------*
ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GV_ERROR
*&---------------------------------------------------------------------*
FORM CHECK_DATA  USING    PV_ERROR.

*--------------------------------------------------------------------*
* - 선택항목이 있는지?
* - 납기정정이면 정정납기일이 입력되어 있고 현재납기일과 정정납기일이 서로 다른지??
* - 입력한 정정납기일이  D-30 ~ D+180 일 사이에 있는지?
* - 수량정정이면 정정수량이 입력되어 있고 현재수량과 정정수량이 서로 다른지?
*
* - SM Link 요청번호, 생산오더, 구매오더 가 모두 initial 이면 에러
*     차후 프로세스가 진행되지 않았습니다. 판매오더번호를 Click 하여 직접 수정 하세요. "
*          ---> Warning 으로 변경할 수 있음.
*--------------------------------------------------------------------*

  "  선택항목 확인
  READ TABLE GT_DATA TRANSPORTING NO FIELDS WITH KEY CHK = ABAP_TRUE.
  IF SY-SUBRC NE 0.
    MESSAGE S000 DISPLAY LIKE 'E' WITH TEXT-E03.
    "선택사항이 없습니다.
    PV_ERROR = ABAP_TRUE.
    EXIT.
  ENDIF.

  "납기정정이면 정정납기일이 입력되어 있고 현재납기일과 정정납기일이 서로 다른지??
  IF P_REQT EQ 'J'.
    DATA(LV_SAME_CNT) = REDUCE I( INIT CNT = 0
                                   FOR WA IN GT_DATA WHERE ( CHK = 'X' AND EDATU_N IS NOT INITIAL )
                                   NEXT CNT = COND #(
                                       WHEN WA-EDATU_N = WA-EDATU THEN CNT + 1 ELSE CNT )
                                 ).

    IF LV_SAME_CNT > 0.
      MESSAGE S000 DISPLAY LIKE 'E' WITH TEXT-E04.
      "기존 납기일자와 동일한 정정일자는 입력할 수 없습니다.
      PV_ERROR = ABAP_TRUE.
      EXIT.
    ENDIF.

    "입력한 정정납기일이  D-30 ~ D+180 일 사이에 있는지?
    DATA(LV_ERR_CNT) = REDUCE I( INIT CNT = 0
                                        FOR WA IN GT_DATA WHERE ( CHK = 'X' AND EDATU_N IS NOT INITIAL )
                                        NEXT CNT = COND #(
                                          WHEN + WA-EDATU_N < ( WA-EDATU - 30 )
                                            OR + WA-EDATU_N > ( WA-EDATU + 180 )
                                          THEN CNT + 1 ELSE CNT )
                                        ).

    IF LV_ERR_CNT > 0.
      MESSAGE S000 DISPLAY LIKE 'E' WITH TEXT-E05.
      "정정납기일은 기존 납기일 기준 D-30 ~ D+180 범위 내의 일자여야 합니다.
      PV_ERROR = ABAP_TRUE.
      EXIT.
    ENDIF.


  ENDIF.


  " 수량정정이면 정정수량이 입력되어 있고 현재수량과 정정수량이 서로 다른지?
  IF P_REQT EQ 'H'.
    DATA(LV_KWMENG_CNT) = REDUCE I( INIT CNT = 0
                                        FOR WA IN GT_DATA WHERE ( CHK = 'X' AND KWMENG_N IS NOT INITIAL )
                                        NEXT CNT = COND #(
                                          WHEN  WA-KWMENG_N <> WA-KWMENG
                                          THEN CNT + 1 ELSE CNT )
                                        ).

    IF LV_KWMENG_CNT > 0.
      MESSAGE S000 DISPLAY LIKE 'E' WITH TEXT-E06.
      "기존 수량과 동일한 정정수량으로 입력할 수 없습니다.
      PV_ERROR = ABAP_TRUE.
      EXIT.
    ENDIF.

  ENDIF.

  "- SM Link 요청번호, 생산오더, 구매오더 가 모두 initial 이면 에러
  DATA(LV_SM_CNT) = REDUCE I( INIT CNT = 0
                                      FOR WA IN GT_DATA WHERE ( CHK = 'X')
                                      NEXT CNT = COND #(
                                        WHEN  WA-STATUS_AU EQ SPACE
                                          AND WA-STATUS_PO EQ SPACE
                                          AND WA-STATUS_SM EQ SPACE
                                        THEN CNT + 1 ELSE CNT )
                                      ).

  IF LV_SM_CNT > 0.
    MESSAGE S000 DISPLAY LIKE 'E' WITH TEXT-E01.
    "차후 프로세스가 진행되지 않았습니다. 판매오더번호를 Click 하여 직접 수정 하세요
    PV_ERROR = ABAP_TRUE.
    EXIT.
  ENDIF.



ENDFORM.
