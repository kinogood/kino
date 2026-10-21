*&---------------------------------------------------------------------*
*& Include          ZGTPPR4030F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form DOUBLE_CLICK
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> SENDER
*&      --> E_ROW
*&      --> E_COLUMN
*&---------------------------------------------------------------------*
FORM DOUBLE_CLICK  USING   P_SENDER TYPE REF TO CL_GUI_ALV_GRID
                            P_ROW TYPE LVC_S_ROW
                            P_COLUMN TYPE LVC_S_COL.

  DATA : LT_BDCTAB TYPE TABLE OF BDCDATA..
  DATA : LS_BDCTAB TYPE BDCDATA.

  DEFINE __BDC_DYNPRO.
    CLEAR LS_BDCTAB.
    LS_BDCTAB-PROGRAM  = &1.
    LS_BDCTAB-DYNPRO   = &2.
    LS_BDCTAB-DYNBEGIN = 'X'.
    APPEND LS_BDCTAB TO LT_BDCTAB.
  END-OF-DEFINITION.

  DEFINE __BDC_FIELD.
    CLEAR LS_BDCTAB.
    LS_BDCTAB-FNAM = &1.
    LS_BDCTAB-FVAL = conv #( &2 ).
    APPEND LS_BDCTAB TO LT_BDCTAB.
  END-OF-DEFINITION.

  REFRESH LT_BDCTAB.

  READ TABLE GT_MAIN_DISP ASSIGNING FIELD-SYMBOL(<LS_MAIN>) INDEX P_ROW-INDEX.
  CASE P_COLUMN-FIELDNAME.
    WHEN 'AUFNR'.
      CHECK <LS_MAIN>-AUFNR IS NOT INITIAL.
      SET PARAMETER ID 'ANR' FIELD <LS_MAIN>-AUFNR.
      CALL TRANSACTION 'CO03' AND SKIP FIRST SCREEN.
    WHEN 'MBLNR' OR 'MJAHR'.
      CHECK <LS_MAIN>-MBLNR IS NOT INITIAL.

      __BDC_DYNPRO 'SAPLMIGO' '0001'.
      __BDC_FIELD : 'BDC_OKCODE' '=MIGO_OK_ACTION',
                          'GODYNPRO-ACTION' 'A04',
                          'GODYNPRO-REFDOC' 'R02'.

      __BDC_DYNPRO 'SAPLMIGO' '0001'.
      __BDC_FIELD : 'BDC_OKCODE' '=MIGO_OK_GO',
                          'GODYNPRO-MAT_DOC' <LS_MAIN>-MBLNR,
                          'GODYNPRO-DOC_YEAR' <LS_MAIN>-MJAHR.

      CALL TRANSACTION 'MIGO' USING LT_BDCTAB
                                MODE 'E'
                                UPDATE 'S'.
    WHEN 'RUECK' OR 'RMZHL'.
      CHECK <LS_MAIN>-RUECK IS NOT INITIAL.
      SET PARAMETER ID 'RCK' FIELD <LS_MAIN>-RUECK.
      SET PARAMETER ID 'RZL' FIELD <LS_MAIN>-RMZHL.
      CALL TRANSACTION 'CO14' AND SKIP FIRST SCREEN.
  ENDCASE.

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
*& Form GET_PROC
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_PROC .

  PERFORM GET_MAIN_DATA.
  PERFORM PROC_MAKE_DISP_DATA.

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

  CLEAR GS_LAYOUT_0100.
  GS_LAYOUT_0100-CWIDTH_OPT = ABAP_TRUE.
  GS_LAYOUT_0100-NO_ROWMARK   = 'X'.
  GS_LAYOUT_0100-ZEBRA   = 'X'.
  GS_LAYOUT_0100-SEL_MODE   = 'C'.
  GS_LAYOUT_0100-STYLEFNAME = 'CELLTAB'.
  GS_LAYOUT_0100-SMALLTITLE = ABAP_TRUE.
  CASE ABAP_TRUE.
    WHEN P_DIS1.
      GS_LAYOUT_0100-GRID_TITLE = '조회 기준 : 시리얼 별'.
      CLEAR: GS_LAYOUT_0100-NO_ROWMARK.
*      GS_LAYOUT_0100-NO_ROWINS  = 'X'.
      GS_LAYOUT_0100-SEL_MODE   = 'D'.   "U01
    WHEN P_DIS2.
      GS_LAYOUT_0100-GRID_TITLE = '조회 기준 : 생산오더 별'.
    WHEN P_DIS3.
      GS_LAYOUT_0100-GRID_TITLE = '조회 기준 : 공정 별'.
    WHEN P_DIS4.
      GS_LAYOUT_0100-GRID_TITLE = '조회 기준 : 제조지시 별'.
  ENDCASE.

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
      I_INCLNAME             = 'ZGTPPR4030TOP'
      I_INTERNAL_TABNAME     = 'GS_MAIN'
    CHANGING
      CT_FIELDCAT            = LT_FCAT_SLIS
    EXCEPTIONS
      INCONSISTENT_INTERFACE = 1
      PROGRAM_ERROR          = 2
      OTHERS                 = 3.

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

  IF NOT LINE_EXISTS( GT_FIELDCAT_0100[ FIELDNAME = 'ORD_STAT' ] ).
    APPEND INITIAL LINE TO GT_FIELDCAT_0100 ASSIGNING FIELD-SYMBOL(<LS_FCAT>).
    <LS_FCAT>-FIELDNAME = 'ORD_STAT'.
    <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '생산오더 상태'.
    <LS_FCAT>-COL_POS = 10.
    <LS_FCAT>-DATATYPE = 'CHAR'.
    <LS_FCAT>-DD_OUTLEN = '100'.
    <LS_FCAT>-JUST = 'L'.
  ENDIF.

  LOOP AT GT_FIELDCAT_0100 ASSIGNING <LS_FCAT>.
    CLEAR <LS_FCAT>-KEY.
    <LS_FCAT>-JUST = 'C'.
    CASE   <LS_FCAT>-FIELDNAME.
      WHEN 'ZPJNO'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '프로젝트 번호'.
      WHEN 'ZPTXT'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '프로젝트 내역'.
        <LS_FCAT>-JUST = 'L'.
      WHEN 'JOB_NO'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '제조지시 번호'.
      WHEN 'ZJOB_NAME'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '제조지시 내역'.
        <LS_FCAT>-JUST = 'L'.
      WHEN 'KDAUF'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '판매오더 번호'.
      WHEN 'KDPOS'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '판매오더 품목'.
      WHEN 'LINE_NO'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '라인 번호'.
      WHEN 'SERIAL_INFO'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '시리얼 정보'.
      WHEN 'AUFNR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '생산오더 번호'.
      WHEN 'ORD_STAT'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '생산오더 상태'.
      WHEN 'STATUS_SI'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '입고 상태'.
        <LS_FCAT>-ICON = 'X'.
      WHEN 'STATUS_CONFRM'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '확정 상태'.
        <LS_FCAT>-ICON = 'X'.
*U01
      WHEN 'STATUS_T10'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '시간투입 상태(10)'.
        <LS_FCAT>-ICON = 'X'.
      WHEN 'STATUS_T11'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '시간투입 상태(11)'.
        <LS_FCAT>-ICON = 'X'.
*U01
      WHEN 'WERKS'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '플랜트'.
      WHEN 'NAME1'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '플랜트 내역'.
        <LS_FCAT>-JUST = 'L'.
      WHEN 'MTART'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '자재유형'.
      WHEN 'MTBEZ'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '자재유형 내역'.
        <LS_FCAT>-JUST = 'L'.
      WHEN 'AUART'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '생산오더 유형'.
      WHEN 'MATKL'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '자재그룹'.
      WHEN 'WGBEZ'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '자재그룹 내역'.
        <LS_FCAT>-JUST = 'L'.
      WHEN 'MATNR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '품목코드'.
      WHEN 'MAKTX'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '품목코드 내역'.
        <LS_FCAT>-JUST = 'L'.
      WHEN 'FLD_02'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '공정코드'.
      WHEN 'FLD_03'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '공정코드 내역'.
        <LS_FCAT>-JUST = 'L'.
      WHEN 'GAMNG'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '생산오더 수량'.
        <LS_FCAT>-JUST = 'R'.
        <LS_FCAT>-QFIELDNAME = 'GMEIN'.
      WHEN 'WEMNG'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '생산입고 수량'.
        <LS_FCAT>-JUST = 'R'.
        <LS_FCAT>-QFIELDNAME = 'GMEIN'.
      WHEN 'GMEIN'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '생산 단위'.
      WHEN 'IGMNG'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '생산확정 수량'.
        <LS_FCAT>-JUST = 'R'.
        <LS_FCAT>-QFIELDNAME = 'GMEIN2'.
      WHEN 'GMEIN2'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '확정단위'.
      WHEN 'MBLNR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '입고 자재문서번호'.
      WHEN 'MJAHR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '입고 자재문서연도'.
      WHEN 'MENGE'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '생산 입고수량'.
        <LS_FCAT>-JUST = 'R'.
        <LS_FCAT>-QFIELDNAME = 'MEINS'.
      WHEN 'MEINS'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '생산단위'.
      WHEN 'RUECK'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '확정번호'.
      WHEN 'RMZHL'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '확정카운터'.
      WHEN 'LMNGA'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '생산 확정수량'.
        <LS_FCAT>-JUST = 'R'.
        <LS_FCAT>-QFIELDNAME = 'MEINH'.
      WHEN 'MEINH'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '확정단위'.
      WHEN 'ISM02'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '투입시간'.
      WHEN 'ILE02'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '시간단위'.
*U01
      WHEN 'MENGE3160'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = 'MIG수량'.
        <LS_FCAT>-JUST = 'R'.
        <LS_FCAT>-QFIELDNAME = 'MEINS3160'.
      WHEN 'MEINS3160'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = 'MIG단위'.
      WHEN 'RTMSG'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '처리메시지'.
        <LS_FCAT>-JUST = 'L'.
      WHEN 'BUDATT10'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '전기일(10)'.
*U01
    ENDCASE.

    CASE ABAP_TRUE.
      WHEN P_DIS1.
        CASE  <LS_FCAT>-FIELDNAME.
          WHEN  'WEMNG' OR 'GMEIN' OR 'IGMNG' OR 'GMEIN2'
             OR 'MENGE3160' OR 'MEINS3160'    "U01
             OR 'STATUS_T10' OR 'STATUS_T11'  "U01
             OR 'RTMSG' OR 'BUDATT10'.    "U01
            <LS_FCAT>-NO_OUT = ABAP_TRUE.
*U01
            IF SY-UNAME CP 'ZG*'.
              IF <LS_FCAT>-FIELDNAME = 'RTMSG' OR
                 <LS_FCAT>-FIELDNAME = 'STATUS_T10' OR
                 <LS_FCAT>-FIELDNAME = 'STATUS_T11'.
                CLEAR: <LS_FCAT>-NO_OUT.
              ENDIF.
            ENDIF.
*U01
        ENDCASE.
      WHEN P_DIS2.
        CASE  <LS_FCAT>-FIELDNAME.
          WHEN  'LINE_NO' OR 'SERIAL_INFO' OR
                    'MBLNR' OR 'MJAHR' OR 'MENGE' OR
                    'MEINS' OR 'RUECK' OR  'RMZHL' OR 'LMNGA' OR 'MEINH'
             OR 'MENGE3160' OR 'MEINS3160'    "U01
             OR 'STATUS_T10' OR 'STATUS_T11'  "U01
             OR 'RTMSG' OR 'BUDATT10'.    "U01
            <LS_FCAT>-NO_OUT = ABAP_TRUE.
        ENDCASE.
      WHEN P_DIS3.
        CASE  <LS_FCAT>-FIELDNAME.
          WHEN  'WERKS' OR 'NAME1' OR
                    'FLD_02' OR 'FLD_03' OR 'GAMNG' OR
                    'GAMNG' OR 'GMEIN' OR  'IGMNG' OR 'GMEIN2' OR 'ISM02' OR 'ILE02' .
          WHEN OTHERS.
            <LS_FCAT>-NO_OUT = ABAP_TRUE.
        ENDCASE.
      WHEN P_DIS4.
        CASE  <LS_FCAT>-FIELDNAME.
          WHEN  'LINE_NO' OR 'SERIAL_INFO' OR 'AUFNR' OR 'ORD_STAT' OR 'STATUS_SI' OR
                    'STATUS_CONFRM' OR 'AUART' OR
                    'MBLNR' OR 'MJAHR' OR 'MENGE' OR
                    'MEINS' OR 'RUECK' OR  'RMZHL' OR 'LMNGA' OR 'MEINH'
             OR 'MENGE3160' OR 'MEINS3160'    "U01
             OR 'STATUS_T10' OR 'STATUS_T11'  "U01
             OR 'RTMSG' OR 'BUDATT10'.    "U01
            <LS_FCAT>-NO_OUT = ABAP_TRUE.
        ENDCASE.
    ENDCASE.

  ENDLOOP.

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

  CLEAR GS_VARIANT_0100.
  GS_VARIANT_0100-REPORT = SY-REPID.
  IF P_LAY IS NOT INITIAL.
    GS_VARIANT_0100-VARIANT = P_LAY.
  ENDIF.


  CALL METHOD GO_GRID_0100->SET_TABLE_FOR_FIRST_DISPLAY
    EXPORTING
      IS_LAYOUT            = GS_LAYOUT_0100
      IT_TOOLBAR_EXCLUDING = GT_EXCLUDE_0100
      IS_VARIANT           = GS_VARIANT_0100
      I_SAVE               = 'A'
    CHANGING
      IT_OUTTAB            = GT_MAIN_DISP
      IT_FIELDCATALOG      = GT_FIELDCAT_0100.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form proc_disp
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PROC_DISP .

  IF GT_MAIN_DISP[] IS INITIAL.
    MESSAGE S001 DISPLAY LIKE 'E'.
  ELSE.
    CALL SCREEN '0100'.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_MAIN_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_MAIN_DATA .

  DATA : LV_CHK_EXIST.
  REFRESH GT_MAIN.

* 모수 데이터 추출
  SELECT A~WERKS, A~AUFNR, A~AUART, B~GAMNG, B~IGMNG, B~GMEIN, B~GMEIN AS GMEIN2,
          C~MATNR, C~WEMNG, C~KDAUF, C~KDPOS, D~MTART, D~MATKL,
          E~ZPJNO, F~JOB_NO, F~LINE_NO, F~SERIAL_INFO, F~OPER_CODE,
          F~MENGE AS MENGE3160, F~MEINS AS MEINS3160,   "U01
          G~FLD_02, G~FLD_03
    FROM AUFK AS A
    INNER JOIN AFKO AS B
                         ON B~AUFNR = A~AUFNR
    INNER JOIN ZGTPPT3160 AS F
                                  ON F~AUFNR = A~AUFNR
    INNER JOIN AFPO AS C
                         ON C~AUFNR = A~AUFNR
    INNER JOIN MARA AS D
                         ON D~MATNR = C~MATNR
    INNER JOIN VBAK AS E
                         ON E~VBELN = C~KDAUF
    INNER JOIN ZGTPPT1010 AS G
                                  ON G~FLD_04 = F~OPER_CODE
   WHERE A~WERKS = @P_WERKS
     AND A~AUFNR IN @S_AUFNR
     AND A~AUART IN @S_AUART
     AND C~KDAUF IN @S_KDAUF
     AND C~KDPOS IN @S_KDPOS
     AND C~MATNR IN @S_MATNR
     AND D~MTART IN @S_MTART
     AND D~MATKL IN @S_MATKL
     AND B~GSTRP IN @S_GSTRP
     AND B~GLTRP IN @S_GLTRP
     AND G~MODULE_KIND = 'PP'
     AND G~CODEGRP = '2030'
     AND G~FLD_02 IN @S_GONG
     AND E~ZPJNO IN @S_ZPJNO
     AND F~JOB_NO IN @S_JOBNO
    INTO TABLE @DATA(LT_MAIN).

* 생산오더 확정 데이터, 생산오더 입고 데이터 추출
***  2025.03.30 중복 제거 로직 수정 pys s
  SORT LT_MAIN BY AUFNR JOB_NO LINE_NO SERIAL_INFO FLD_02.
  DELETE ADJACENT DUPLICATES FROM LT_MAIN COMPARING AUFNR JOB_NO LINE_NO SERIAL_INFO FLD_02.
***  2025.03.30 중복 제거 로직 수정 pys e

  DATA(LT_CHK_AUFNR) = LT_MAIN.

  SORT LT_CHK_AUFNR BY AUFNR.
  DELETE ADJACENT DUPLICATES FROM LT_CHK_AUFNR COMPARING AUFNR.

  IF LT_CHK_AUFNR[] IS NOT INITIAL.
    SELECT AUFNR, RUECK, RMZHL, LMNGA, MEINH, ISM02, ILE02, LTXA1,
           BUDAT   "U01
       FROM AFRU
       FOR ALL ENTRIES IN @LT_CHK_AUFNR
     WHERE AUFNR = @LT_CHK_AUFNR-AUFNR
        AND BUDAT IN @S_BUDAT
        AND ERSDA IN @S_CPUDT
        AND STOKZ = ' '
        AND STZHL = ' '
        AND VORNR NE '0011'    "U01
       INTO TABLE @DATA(LT_AFRU).

    SELECT  MBLNR, MJAHR, AUFNR, BKTXT, MENGE, MEINS
       FROM MATDOC
       FOR ALL ENTRIES IN @LT_CHK_AUFNR
     WHERE AUFNR = @LT_CHK_AUFNR-AUFNR
        AND BUDAT IN @S_BUDAT
        AND CPUDT IN @S_CPUDT
        AND BWART = '101'
        AND CANCELLED = ' '
       INTO TABLE @DATA(LT_MATDOC).
  ENDIF.

  SORT LT_AFRU BY AUFNR.
  SORT LT_MATDOC BY AUFNR.

  DATA : LV_STRING01 TYPE STRING.
  DATA : LV_STRING02 TYPE STRING.

* 조회된 데이터로 기준테이블 생성

  LOOP AT LT_MAIN INTO DATA(LS_MAIN).
    CLEAR : GS_MAIN, LV_CHK_EXIST.
    MOVE-CORRESPONDING LS_MAIN TO GS_MAIN.

*  생산오더 확정 데이터
    READ TABLE LT_AFRU TRANSPORTING NO FIELDS WITH KEY AUFNR = LS_MAIN-AUFNR BINARY SEARCH.
    IF SY-SUBRC EQ 0.
      LOOP AT LT_AFRU INTO DATA(LS_AFRU) FROM SY-TABIX.
        IF NOT LS_AFRU-AUFNR = LS_MAIN-AUFNR.
          EXIT.
        ENDIF.
        CLEAR : LV_STRING01, LV_STRING02.
        SPLIT LS_AFRU-LTXA1 AT ',' INTO LV_STRING01 LV_STRING02.
        IF LV_STRING01 = LS_MAIN-LINE_NO AND
           LV_STRING02 = LS_MAIN-SERIAL_INFO.
          LV_CHK_EXIST = ABAP_TRUE.

          IF GS_MAIN-RUECK IS INITIAL AND GS_MAIN-RMZHL IS INITIAL.
            GS_MAIN-RUECK = LS_AFRU-RUECK.
            GS_MAIN-RMZHL = LS_AFRU-RMZHL.
            GS_MAIN-LMNGA = LS_AFRU-LMNGA.
            GS_MAIN-MEINH = LS_AFRU-MEINH.
            GS_MAIN-ISM02 = LS_AFRU-ISM02.
            GS_MAIN-ILE02 = LS_AFRU-ILE02.
            GS_MAIN-BUDATT10 = LS_AFRU-BUDAT.   "U01
          ELSE.
            GS_MAIN-LMNGA = GS_MAIN-LMNGA + LS_AFRU-LMNGA.
            IF GS_MAIN-RUECK < LS_AFRU-RUECK.
              GS_MAIN-RUECK = LS_AFRU-RUECK.
              GS_MAIN-RMZHL = LS_AFRU-RMZHL.
              GS_MAIN-MEINH = LS_AFRU-MEINH.
              GS_MAIN-ISM02 = LS_AFRU-ISM02.
              GS_MAIN-ILE02 = LS_AFRU-ILE02.
              GS_MAIN-BUDATT10 = LS_AFRU-BUDAT.   "U01
            ELSEIF GS_MAIN-RMZHL < LS_AFRU-RMZHL.
              GS_MAIN-RMZHL = LS_AFRU-RMZHL.
              GS_MAIN-MEINH = LS_AFRU-MEINH.
              GS_MAIN-ISM02 = LS_AFRU-ISM02.
              GS_MAIN-ILE02 = LS_AFRU-ILE02.
              GS_MAIN-BUDATT10 = LS_AFRU-BUDAT.   "U01
            ENDIF.
          ENDIF.
        ENDIF.
      ENDLOOP.
    ENDIF.

*  생산오더 입고 데이터
    READ TABLE LT_MATDOC TRANSPORTING NO FIELDS WITH KEY AUFNR = LS_MAIN-AUFNR BINARY SEARCH.
    IF SY-SUBRC EQ 0.
      LOOP AT LT_MATDOC INTO DATA(LS_MATDOC) FROM SY-TABIX.
        IF NOT LS_MATDOC-AUFNR = LS_MAIN-AUFNR.
          EXIT.
        ENDIF.
        CLEAR : LV_STRING01, LV_STRING02.
        SPLIT LS_MATDOC-BKTXT AT ',' INTO LV_STRING01 LV_STRING02.
        IF LV_STRING01 = LS_MAIN-LINE_NO AND
           LV_STRING02 = LS_MAIN-SERIAL_INFO.
          LV_CHK_EXIST = ABAP_TRUE.

          IF GS_MAIN-MBLNR IS INITIAL AND GS_MAIN-MJAHR IS INITIAL.
            GS_MAIN-MBLNR = LS_MATDOC-MBLNR.
            GS_MAIN-MJAHR = LS_MATDOC-MJAHR.
            GS_MAIN-MENGE = LS_MATDOC-MENGE.
            GS_MAIN-MEINS = LS_MATDOC-MEINS.
          ELSE.
            GS_MAIN-MENGE = GS_MAIN-MENGE + LS_MATDOC-MENGE.
            IF GS_MAIN-MBLNR < LS_MATDOC-MBLNR.
              GS_MAIN-MBLNR = LS_MATDOC-MBLNR.
              GS_MAIN-MJAHR = LS_MATDOC-MJAHR.
              GS_MAIN-MEINS = LS_MATDOC-MEINS.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDLOOP.
    ENDIF.

    IF ( S_BUDAT[] IS NOT INITIAL OR
      S_CPUDT[] IS NOT INITIAL ) AND
      LV_CHK_EXIST IS INITIAL.
      CONTINUE.
    ENDIF.

    APPEND GS_MAIN TO GT_MAIN.

  ENDLOOP.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROC_MAKE_DISP_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PROC_MAKE_DISP_DATA .

  CHECK GT_MAIN IS NOT INITIAL.

  DATA : LT_COLLECT_TAB LIKE GT_MAIN.
  DATA : LT_COLLECT_TAB2 LIKE GT_MAIN.
  DATA : LS_COLLECT_TAB LIKE GS_MAIN.
  DATA : LT_TEMP_TAB LIKE GT_MAIN.
  DATA : LS_TEMP_TAB LIKE GS_MAIN.
  DATA : LV_CHK_DISP.
  DATA : LV_LTXA1 LIKE AFRU-LTXA1.

* 조회 기준별로 대상 콜렉트 처리
  LOOP AT GT_MAIN INTO GS_MAIN.
    CASE ABAP_TRUE.
      WHEN P_DIS1.
      WHEN OTHERS.
        LS_COLLECT_TAB-AUFNR = GS_MAIN-AUFNR.
        LS_COLLECT_TAB-ISM02 = GS_MAIN-ISM02.
        IF GS_MAIN-ILE02 IS NOT INITIAL.
          LS_COLLECT_TAB-ILE02 = GS_MAIN-ILE02.
        ELSE.
          LS_COLLECT_TAB-ILE02 = 'MIN'.
        ENDIF.

        COLLECT LS_COLLECT_TAB INTO LT_COLLECT_TAB.
    ENDCASE.
  ENDLOOP.

  IF P_DIS1 NE ABAP_TRUE.
    LOOP AT LT_COLLECT_TAB INTO LS_COLLECT_TAB.
      READ TABLE GT_MAIN INTO GS_MAIN WITH KEY AUFNR = LS_COLLECT_TAB-AUFNR.
      IF SY-SUBRC EQ 0.
        CASE ABAP_TRUE.
          WHEN P_DIS2.
            CLEAR LS_TEMP_TAB.
            LS_TEMP_TAB-ZPJNO = GS_MAIN-ZPJNO.
            LS_TEMP_TAB-JOB_NO = GS_MAIN-JOB_NO.
            LS_TEMP_TAB-KDAUF = GS_MAIN-KDAUF.
            LS_TEMP_TAB-KDPOS = GS_MAIN-KDPOS.
            LS_TEMP_TAB-AUFNR = GS_MAIN-AUFNR.
            LS_TEMP_TAB-WERKS = GS_MAIN-WERKS.
            LS_TEMP_TAB-NAME1 = GS_MAIN-NAME1.
            LS_TEMP_TAB-MTART = GS_MAIN-MTART.
            LS_TEMP_TAB-AUART = GS_MAIN-AUART.
            LS_TEMP_TAB-MATKL = GS_MAIN-MATKL.
            LS_TEMP_TAB-MATNR = GS_MAIN-MATNR.
            LS_TEMP_TAB-FLD_02 = GS_MAIN-FLD_02.
            LS_TEMP_TAB-FLD_03 = GS_MAIN-FLD_03.
            LS_TEMP_TAB-GAMNG = GS_MAIN-GAMNG.
            LS_TEMP_TAB-WEMNG = GS_MAIN-WEMNG.
            LS_TEMP_TAB-GMEIN = GS_MAIN-GMEIN.
            LS_TEMP_TAB-IGMNG = GS_MAIN-IGMNG.
            LS_TEMP_TAB-GMEIN2 = GS_MAIN-GMEIN2.
            LS_TEMP_TAB-ISM02 = LS_COLLECT_TAB-ISM02.
            LS_TEMP_TAB-ILE02 = LS_COLLECT_TAB-ILE02.
            APPEND LS_TEMP_TAB TO LT_TEMP_TAB.
          WHEN P_DIS3.
            CLEAR LS_TEMP_TAB.
            LS_TEMP_TAB-WERKS = GS_MAIN-WERKS.
            LS_TEMP_TAB-NAME1 = GS_MAIN-NAME1.
            LS_TEMP_TAB-FLD_02 = GS_MAIN-FLD_02.
            LS_TEMP_TAB-FLD_03 = GS_MAIN-FLD_03.
            LS_TEMP_TAB-GAMNG = GS_MAIN-GAMNG.
            LS_TEMP_TAB-WEMNG = GS_MAIN-WEMNG.
            LS_TEMP_TAB-GMEIN = GS_MAIN-GMEIN.
            LS_TEMP_TAB-IGMNG = GS_MAIN-IGMNG.
            LS_TEMP_TAB-GMEIN2 = GS_MAIN-GMEIN2.
            LS_TEMP_TAB-ISM02 = LS_COLLECT_TAB-ISM02.
            LS_TEMP_TAB-ILE02 = LS_COLLECT_TAB-ILE02.
            COLLECT LS_TEMP_TAB INTO LT_COLLECT_TAB2.
          WHEN P_DIS4.
            CLEAR LS_TEMP_TAB.
            LS_TEMP_TAB-ZPJNO = GS_MAIN-ZPJNO.
            LS_TEMP_TAB-JOB_NO = GS_MAIN-JOB_NO.
            LS_TEMP_TAB-KDAUF = GS_MAIN-KDAUF.
            LS_TEMP_TAB-KDPOS = GS_MAIN-KDPOS.
            LS_TEMP_TAB-WERKS = GS_MAIN-WERKS.
            LS_TEMP_TAB-NAME1 = GS_MAIN-NAME1.
            LS_TEMP_TAB-MTART = GS_MAIN-MTART.
            LS_TEMP_TAB-MATKL = GS_MAIN-MATKL.
            LS_TEMP_TAB-MATNR = GS_MAIN-MATNR.
            LS_TEMP_TAB-FLD_02 = GS_MAIN-FLD_02.
            LS_TEMP_TAB-FLD_03 = GS_MAIN-FLD_03.
            LS_TEMP_TAB-GAMNG = GS_MAIN-GAMNG.
            LS_TEMP_TAB-WEMNG = GS_MAIN-WEMNG.
            LS_TEMP_TAB-GMEIN = GS_MAIN-GMEIN.
            LS_TEMP_TAB-IGMNG = GS_MAIN-IGMNG.
            LS_TEMP_TAB-GMEIN2 = GS_MAIN-GMEIN2.
            LS_TEMP_TAB-ISM02 = LS_COLLECT_TAB-ISM02.
            LS_TEMP_TAB-ILE02 = LS_COLLECT_TAB-ILE02.
            COLLECT LS_TEMP_TAB INTO LT_COLLECT_TAB2.

        ENDCASE.
      ENDIF.
    ENDLOOP.

    REFRESH GT_MAIN.
    CASE ABAP_TRUE.
      WHEN P_DIS2.
        MOVE-CORRESPONDING LT_TEMP_TAB TO GT_MAIN.
      WHEN P_DIS3 OR P_DIS4.
        MOVE-CORRESPONDING LT_COLLECT_TAB2 TO GT_MAIN.
    ENDCASE.
  ENDIF.


  REFRESH GT_MAIN_DISP.
  DATA : LV_NAME1 TYPE T001W-NAME1.
  LV_NAME1 = ZGTPP_CL_COMMON=>GET_PLANT_NAME( IV_WERKS = CONV #( P_WERKS ) ).

*  Make Display table
  LOOP AT GT_MAIN INTO GS_MAIN.

    APPEND INITIAL LINE TO GT_MAIN_DISP ASSIGNING FIELD-SYMBOL(<LS_DISP>).
    DATA(LV_TABIX) = SY-TABIX.

    MOVE-CORRESPONDING GS_MAIN TO <LS_DISP>.
    IF GS_MAIN-ILE02 IS INITIAL.
      <LS_DISP>-ILE02 = 'MIN'.
    ENDIF.

* 상태 정보
    PERFORM GET_STATUS_AUFNR USING GS_MAIN
                                         CHANGING <LS_DISP>-ORD_STAT
                                                       <LS_DISP>-STATUS_SI
                                                       <LS_DISP>-STATUS_CONFRM.
* 파라미터 값에 따른 디스플레이 세팅
    CASE ABAP_TRUE.
      WHEN P_DIS1 OR P_DIS2.
        CLEAR LV_CHK_DISP.
        PERFORM CHECK_DISP_FOR_PARAMETER USING <LS_DISP> CHANGING LV_CHK_DISP.

        IF LV_CHK_DISP EQ ABAP_TRUE.
          DELETE GT_MAIN_DISP INDEX LV_TABIX.
          CONTINUE.
        ENDIF.

    ENDCASE.

* 프로젝트 정보
    IF GS_MAIN-ZPJNO IS NOT INITIAL.
      PERFORM GET_DESC_PROJCT USING GS_MAIN-ZPJNO CHANGING <LS_DISP>-ZPTXT.
    ENDIF.

* 제조지시내역
    IF GS_MAIN-JOB_NO IS NOT INITIAL.
      PERFORM GET_DESC_JOB_NO USING GS_MAIN-JOB_NO CHANGING <LS_DISP>-ZJOB_NAME.
    ENDIF.

* 플랜트명
    IF GS_MAIN-WERKS IS NOT INITIAL.
      <LS_DISP>-NAME1 = LV_NAME1.
    ENDIF.

* 자재유형 내역
    IF GS_MAIN-MTART IS NOT INITIAL.
      PERFORM GET_DESC_MTART USING GS_MAIN-MTART CHANGING <LS_DISP>-MTBEZ.
    ENDIF.

* 자재그룹내역
    IF GS_MAIN-MATKL IS NOT INITIAL.
      PERFORM GET_DESC_MATKL USING GS_MAIN-MATKL CHANGING <LS_DISP>-WGBEZ.
    ENDIF.

* 품목내역
    IF GS_MAIN-MATNR IS NOT INITIAL.
      <LS_DISP>-MAKTX = ZGTPP_CL_COMMON=>GET_MAKTX( IV_MATNR = GS_MAIN-MATNR ).
    ENDIF.

*U01
    CLEAR: LV_LTXA1.
    LV_LTXA1 = GS_MAIN-LINE_NO && |,| && GS_MAIN-SERIAL_INFO.

*시간투입상태(10)
    SELECT SINGLE B~RUECK
      FROM AFKO AS A
     INNER JOIN AFVC AS B ON B~AUFPL EQ A~AUFPL
     WHERE A~AUFNR EQ @GS_MAIN-AUFNR
       AND B~VORNR EQ '0010'
      INTO @DATA(LV_RUECK10).

    IF LV_RUECK10 IS INITIAL.
      <LS_DISP>-STATUS_T10 = ICON_LED_RED.
    ELSE.
      SELECT SINGLE RUECK
        FROM AFRU
       WHERE RUECK EQ @LV_RUECK10
         AND LTXA1 EQ @LV_LTXA1
         AND ISM02 NE @SPACE
         AND STOKZ EQ @SPACE
         AND STZHL EQ @SPACE
        INTO @DATA(LV_RUECKA10).

      IF LV_RUECKA10 IS INITIAL.
        <LS_DISP>-STATUS_T10 = ICON_LED_INACTIVE.
      ELSE.
        <LS_DISP>-STATUS_T10 = ICON_LED_GREEN.
      ENDIF.
    ENDIF.

*시간투입상태(11)
    SELECT SINGLE B~RUECK
      FROM AFKO AS A
     INNER JOIN AFVC AS B ON B~AUFPL EQ A~AUFPL
     WHERE A~AUFNR EQ @GS_MAIN-AUFNR
       AND B~VORNR EQ '0011'
      INTO @DATA(LV_RUECK11).

    IF LV_RUECK11 IS INITIAL.
      <LS_DISP>-STATUS_T11 = ICON_LED_RED.
    ELSE.
      SELECT SINGLE RUECK
        FROM AFRU
       WHERE RUECK EQ @LV_RUECK11
         AND LTXA1 EQ @LV_LTXA1
         AND ISM02 NE @SPACE
         AND STOKZ EQ @SPACE
         AND STZHL EQ @SPACE
        INTO @DATA(LV_RUECKA11).

      IF LV_RUECKA11 IS INITIAL.
        <LS_DISP>-STATUS_T11 = ICON_LED_INACTIVE.
      ELSE.
        <LS_DISP>-STATUS_T11 = ICON_LED_GREEN.
      ENDIF.
    ENDIF.

    CLEAR: LV_RUECK10, LV_RUECKA10, LV_RUECK11, LV_RUECKA11.
*U01

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_STATUS_AUFNR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GS_MAIN_AUFNR
*&      <-- <LS_DISP>_ORD_STAT
*&---------------------------------------------------------------------*
FORM GET_STATUS_AUFNR  USING    PS_MAIN LIKE GS_MAIN
                       CHANGING PV_ORD_STAT
                                     PV_STATUS_SI
                                     PV_STATUS_CONFRM.

  CHECK P_DIS1 = ABAP_TRUE OR P_DIS2 = ABAP_TRUE.

  DATA : LT_TJ02T LIKE TJ02T OCCURS 0 WITH HEADER LINE.

*    상태값 조회
  REFRESH LT_TJ02T.
  CALL FUNCTION 'Z_PP_RETURN_ORDER_STATUS'
    EXPORTING
      IM_AUFNR        = PS_MAIN-AUFNR
    IMPORTING
      EX_STNAM        = PV_ORD_STAT
    TABLES
      ET_STTXT        = LT_TJ02T
    EXCEPTIONS
      NO_SELECTION    = 1
      NOT_FOUND_OBJNR = 2
      OTHERS          = 3.

  CASE ABAP_TRUE.
    WHEN P_DIS1.
      IF PS_MAIN-MENGE > 0.
        PV_STATUS_SI = ICON_LED_GREEN.
      ELSE.
        PV_STATUS_SI = ICON_LED_RED.
      ENDIF.

      IF PS_MAIN-LMNGA > 0.
        PV_STATUS_CONFRM = ICON_LED_GREEN.
      ELSE.
        PV_STATUS_CONFRM = ICON_LED_RED.
      ENDIF.
    WHEN P_DIS2.
      READ TABLE LT_TJ02T WITH KEY TXT04 = 'PDLV'.
      IF SY-SUBRC EQ 0.
        PV_STATUS_SI = ICON_LED_YELLOW.
      ELSE.
        READ TABLE LT_TJ02T WITH KEY TXT04 = 'DLV'.
        IF SY-SUBRC EQ 0.
          PV_STATUS_SI = ICON_LED_GREEN.
        ELSE.
          PV_STATUS_SI = ICON_LED_RED.
        ENDIF.
      ENDIF.

      READ TABLE LT_TJ02T WITH KEY TXT04 = 'PCNF'.
      IF SY-SUBRC EQ 0.
        PV_STATUS_CONFRM = ICON_LED_YELLOW.
      ELSE.
        READ TABLE LT_TJ02T WITH KEY TXT04 = 'CNF'.
        IF SY-SUBRC EQ 0.
          PV_STATUS_CONFRM = ICON_LED_GREEN.
        ELSE.
          PV_STATUS_CONFRM = ICON_LED_RED.
        ENDIF.
      ENDIF.

  ENDCASE.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_DESC_PROJCT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GS_MAIN_ZPJN
*&      <-- <LS_DISP>_ZPTXT
*&---------------------------------------------------------------------*
FORM GET_DESC_PROJCT  USING    PV_ZPJNO
                      CHANGING PV_DESC.

  SELECT SINGLE ZPTXT
    FROM ZSD0106T
    INTO PV_DESC
   WHERE ZPJNO = PV_ZPJNO.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_DESC_JOB_NO
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GS_MAIN_JOB_NO
*&      <-- <LS_DISP>_ZJOB_NAME
*&---------------------------------------------------------------------*
FORM GET_DESC_JOB_NO  USING    PV_JOB_NO
                      CHANGING PV_DESC.

  SELECT SINGLE ZJOB_NAME
    FROM ZGTEDT2121
    INTO PV_DESC
    WHERE ZJOB_NO = PV_JOB_NO.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_DESC_MTART
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GS_MAIN_MTART
*&      <-- <LS_DISP>_MTBEZ
*&---------------------------------------------------------------------*
FORM GET_DESC_MTART  USING    PV_MTART
                              CHANGING PV_DESC.

  SELECT SINGLE MTBEZ
    FROM T134T
    INTO PV_DESC
   WHERE SPRAS = SY-LANGU
     AND MTART = PV_MTART.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_DESC_MATKL
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GS_MAIN_MATKL
*&      <-- <LS_DISP>_WGBEZ
*&---------------------------------------------------------------------*
FORM GET_DESC_MATKL  USING    PV_MATKL
                     CHANGING PV_DESC.

  SELECT SINGLE WGBEZ
    FROM T023T
    INTO PV_DESC
   WHERE SPRAS = SY-LANGU
     AND MATKL = PV_MATKL.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_CELL_ATTRIBUTE_GRID_0100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_CELL_ATTRIBUTE_GRID_0100 .

  DATA : LT_CELLTAB TYPE LVC_T_STYL.
  DATA : LS_CELLTAB TYPE LVC_S_STYL.

  LOOP AT GT_MAIN_DISP ASSIGNING FIELD-SYMBOL(<LS_MAIN_DISP>).
    REFRESH LT_CELLTAB.

    LOOP AT GT_FIELDCAT_0100 INTO DATA(LS_FIELDCAT).
      CASE LS_FIELDCAT-FIELDNAME.
        WHEN 'WEMNG' OR 'GMEIN' OR 'MBLNR' OR 'MJAHR' OR 'MENGE' OR 'MEINS'.
*       key 색깔지정
          CLEAR LS_CELLTAB.
          LS_CELLTAB-FIELDNAME = LS_FIELDCAT-FIELDNAME.
          LS_CELLTAB-STYLE = ALV_STYLE_COLOR_NEGATIVE.
          INSERT LS_CELLTAB INTO TABLE LT_CELLTAB.
        WHEN 'IGMNG' OR 'GMEIN2' OR 'RUECK' OR 'RMZHL' OR 'LMNGA' OR 'MEINH' OR 'ISM02' OR 'ILE02'.
*       key 색깔지정
          CLEAR LS_CELLTAB.
          LS_CELLTAB-FIELDNAME = LS_FIELDCAT-FIELDNAME.
          LS_CELLTAB-STYLE = ALV_STYLE_COLOR_POSITIVE.
          INSERT LS_CELLTAB INTO TABLE LT_CELLTAB.
      ENDCASE.
    ENDLOOP.
    <LS_MAIN_DISP>-CELLTAB = LT_CELLTAB.
  ENDLOOP.

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
      WHEN P_DIS1 OR P_DIS2.
      WHEN P_DIS3 OR P_DIS4.
        IF SCREEN-GROUP1 = 'S1'.
          SCREEN-ACTIVE = 0.
          MODIFY SCREEN.
        ENDIF.
    ENDCASE.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_DISP_FOR_PARAMETER
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> <LS_DISP>
*&      <-- LV_CHK_DISP
*&---------------------------------------------------------------------*
FORM CHECK_DISP_FOR_PARAMETER  USING    PS_DISP LIKE GS_MAIN_DISP
                                              CHANGING    PV_CHK_DISP.

  CASE ABAP_TRUE.
    WHEN P_ALL1.
    WHEN P_CONF1.
      CASE PS_DISP-STATUS_SI.
        WHEN ICON_LED_YELLOW OR ICON_LED_RED.
          PV_CHK_DISP = ABAP_TRUE.
          RETURN.
      ENDCASE.
    WHEN P_REL1.
      CASE PS_DISP-STATUS_SI.
        WHEN ICON_LED_GREEN.
          PV_CHK_DISP = ABAP_TRUE.
          RETURN.
      ENDCASE.
  ENDCASE.

  CASE ABAP_TRUE.
    WHEN P_ALL2.
    WHEN P_CONF2.
      CASE PS_DISP-STATUS_CONFRM.
        WHEN ICON_LED_YELLOW OR ICON_LED_RED.
          PV_CHK_DISP = ABAP_TRUE.
          RETURN.
      ENDCASE.
    WHEN P_REL2.
      CASE PS_DISP-STATUS_CONFRM.
        WHEN ICON_LED_GREEN.
          PV_CHK_DISP = ABAP_TRUE.
          RETURN.
      ENDCASE.
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SELECT_ALV_VARIANT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- P_LAY
*&---------------------------------------------------------------------*
FORM SELECT_ALV_VARIANT  CHANGING PV_LAY.

  DATA: LS_VARIANT TYPE DISVARIANT.

  LS_VARIANT-REPORT = SY-REPID.

  CALL FUNCTION 'REUSE_ALV_VARIANT_F4'
    EXPORTING
      IS_VARIANT    = LS_VARIANT
      I_SAVE        = 'A'
    IMPORTING
      ES_VARIANT    = LS_VARIANT
    EXCEPTIONS
      NOT_FOUND     = 1
      PROGRAM_ERROR = 2.
  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE 'S' NUMBER SY-MSGNO
      WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ELSE.
    PV_LAY = LS_VARIANT-VARIANT.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form F4_GONG_CD
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> S_GONG_LOW
*&---------------------------------------------------------------------*
FORM F4_GONG_CD  USING    PV_GONG.

  DATA: LT_RETURN     TYPE TABLE OF DDSHRETVAL WITH HEADER LINE,
        LT_DYNPFIELDS TYPE TABLE OF DYNPREAD WITH HEADER LINE.

  DATA : LT_FIELDS TYPE TABLE OF DFIES,
         LS_FIELD  TYPE DFIES.
  DATA : LV_WERKS TYPE WERKS_D.

  CALL FUNCTION 'GET_DYNP_VALUE'
    EXPORTING
      I_FIELD = 'P_WERKS'
      I_REPID = SY-REPID
      I_DYNNR = '1000'
    CHANGING
      O_VALUE = LV_WERKS.


  SELECT DISTINCT FLD_02, FLD_03 INTO TABLE @DATA(LT_1010)
    FROM ZGTPPT1010
    WHERE MODULE_KIND = 'PP'
    AND CODEGRP = '2030'
    AND FLD_01 = @LV_WERKS.

  SORT LT_1010 BY FLD_02.
  DELETE ADJACENT DUPLICATES FROM LT_1010 COMPARING FLD_02.



  CLEAR LS_FIELD.
  CALL FUNCTION 'DDIF_FIELDINFO_GET'
    EXPORTING
      TABNAME        = 'ZGTPPT1010'
    TABLES
      DFIES_TAB      = LT_FIELDS
    EXCEPTIONS
      NOT_FOUND      = 1
      INTERNAL_ERROR = 2
      OTHERS         = 3.
  IF SY-SUBRC <> 0.
* Implement suitable error handling here
  ENDIF.

  APPEND LS_FIELD TO LT_FIELDS.

  LOOP AT LT_FIELDS ASSIGNING FIELD-SYMBOL(<LS_FIELD>).

    CASE <LS_FIELD>-FIELDNAME.
      WHEN 'FLD_02'.
        <LS_FIELD>-POSITION = 1.
        <LS_FIELD>-OFFSET = 0.
        <LS_FIELD>-SCRTEXT_S = 'ERP 공정'.
        <LS_FIELD>-SCRTEXT_M = 'ERP 공정'.
        <LS_FIELD>-SCRTEXT_L = 'ERP 공정'.
        <LS_FIELD>-REPTEXT   = 'ERP 공정'.
      WHEN 'FLD_03'.
        <LS_FIELD>-POSITION = 2.
        <LS_FIELD>-OFFSET = 40.
        <LS_FIELD>-SCRTEXT_S = 'ERP 공정내역'.
        <LS_FIELD>-SCRTEXT_M = 'ERP 공정내역'.
        <LS_FIELD>-SCRTEXT_L = 'ERP 공정내역'.
        <LS_FIELD>-REPTEXT   = 'ERP 공정내역'.
      WHEN OTHERS.
        DELETE LT_FIELDS.
    ENDCASE.
  ENDLOOP.


  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      RETFIELD        = 'FLD_02'
      DYNPPROG        = SY-CPROG
      DYNPNR          = SY-DYNNR
      VALUE_ORG       = 'S'
      WINDOW_TITLE    = '공정코드'
    TABLES
      VALUE_TAB       = LT_1010
      FIELD_TAB       = LT_FIELDS
      RETURN_TAB      = LT_RETURN
    EXCEPTIONS
      PARAMETER_ERROR = 1
      NO_VALUES_FOUND = 2
      OTHERS          = 3.

  READ TABLE LT_RETURN INDEX 1.

  PV_GONG = LT_RETURN-FIELDVAL.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROC_MIG
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PROC_MIG .
  DATA: LT_ROW_NO TYPE LVC_T_ROID WITH HEADER LINE,
        L_ANSWER  TYPE CHAR01.

  FIELD-SYMBOLS: <FS_S> LIKE GS_MAIN_DISP.

  CLEAR: L_ANSWER.

  PERFORM SEL_ROW_RTN TABLES LT_ROW_NO
                      USING  GO_GRID_0100.

  IF LT_ROW_NO[] IS INITIAL.
    MESSAGE S003 DISPLAY LIKE 'W'
       WITH '실행 할 레코드를 선택하세요.'.
    EXIT.
  ENDIF.

  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      TITLEBAR              = '생산 실적 등록'
      TEXT_QUESTION         = '생산 실적 등록을 수행하시겠습니까?'
      DISPLAY_CANCEL_BUTTON = SPACE
    IMPORTING
      ANSWER                = L_ANSWER.

  IF L_ANSWER = '1'.
    LOOP AT LT_ROW_NO.
      READ TABLE GT_MAIN_DISP ASSIGNING <FS_S> INDEX LT_ROW_NO-ROW_ID.

      IF <FS_S>-STATUS_SI EQ ICON_LED_RED.
        PERFORM EXEC_GR USING <FS_S>.
      ENDIF.

      IF <FS_S>-STATUS_CONFRM EQ ICON_LED_RED.
        PERFORM EXEC_CONFIRMED USING <FS_S>.
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
      I_SOFT_REFRESH = 'X'
      IS_STABLE      = LS_STABLE
    EXCEPTIONS
      FINISHED       = 1
      OTHERS         = 2.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form EXEC_GR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> <FS_S>
*&---------------------------------------------------------------------*
FORM EXEC_GR  USING    P_LINE LIKE GS_MAIN_DISP.

  DATA: LT_GR     TYPE TABLE OF ZGTPPSIF0022,
        LT_RESULT TYPE TABLE OF ZGTPPSIF0023.

  DATA: LS_GR     TYPE ZGTPPSIF0022,
        LS_RESULT TYPE ZGTPPSIF0023.

  CLEAR: LT_GR.
  LS_GR-WERKS   = P_LINE-WERKS.
  LS_GR-AUFNR   = P_LINE-AUFNR.
  LS_GR-POSNR   = '0001'.
  LS_GR-MATNR   = P_LINE-MATNR.
  LS_GR-CHARG   = SPACE.
  LS_GR-BUDAT   = SY-DATUM.
  LS_GR-ZSERNO  = SY-DATUM && |9999|.
  LS_GR-BWART   = '101'.
  LS_GR-MENGE   = P_LINE-MENGE3160.
  LS_GR-MEINS   = P_LINE-MEINS3160.
  LS_GR-HSDAT   = SY-DATUM.
  LS_GR-LGORT   = '2540'.
  LS_GR-PERNR   = '99999999'.
  LS_GR-NAME    = 'MIG'.
  LS_GR-CLASS   = 'LINE,SERIAL'.
  LS_GR-ATNAM01 = P_LINE-LINE_NO && |,| && P_LINE-SERIAL_INFO.
  APPEND LS_GR TO LT_GR.

  CLEAR: LT_RESULT.
  CALL FUNCTION 'ZGTPP_IF_I_PROD_GR'
    EXPORTING
      I_MODE      = 'P'
      I_SYSTEM_ID = 'KBDM'
* IMPORTING
*     ZO_RESULT   =
*     ZO_MESSAGE  =
    TABLES
      IT_GR       = LT_GR
      OT_RESULT   = LT_RESULT.

  CLEAR: LS_RESULT.
  READ TABLE LT_RESULT INTO LS_RESULT WITH KEY ZERP_STAT = 'S'.
  IF SY-SUBRC EQ 0 AND LS_RESULT IS NOT INITIAL.
    P_LINE-MBLNR = LS_RESULT-MBLNR.
    P_LINE-MJAHR = LS_RESULT-MJAHR.
    P_LINE-MENGE = P_LINE-MENGE3160.
    P_LINE-MEINS = P_LINE-MEINS3160.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form EXEC_CONFIRMED
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> <FS_S>
*&---------------------------------------------------------------------*
FORM EXEC_CONFIRMED  USING    P_LINE LIKE GS_MAIN_DISP.

  DATA: LT_CON    TYPE TABLE OF ZGTPPSIF0020,
        LT_RESULT TYPE TABLE OF ZGTPPSIF0021.

  DATA: LS_CON    TYPE ZGTPPSIF0020,
        LS_RESULT TYPE ZGTPPSIF0021.

  CLEAR: LT_CON.
  LS_CON-WERKS  = P_LINE-WERKS.
  LS_CON-AUFNR  = P_LINE-AUFNR.
  LS_CON-BUDAT  = SY-DATUM.
  LS_CON-ZSERNO = SY-DATUM && |9999|.
  LS_CON-MENGE  = P_LINE-MENGE3160.
  LS_CON-MEINH  = P_LINE-MEINS3160.
  LS_CON-VORNR  = '0010'.
  LS_CON-LMNGA  = P_LINE-MENGE3160.
  LS_CON-TAGNR  = P_LINE-LINE_NO && |,| && P_LINE-SERIAL_INFO.
  LS_CON-ISDD   = SY-DATUM.
  LS_CON-IEDD   = SY-DATUM.
  LS_CON-ISM01  = '0.001'.
  LS_CON-ILE01  = 'MIN'.
  LS_CON-PERNR  = '99999999'.
  LS_CON-NAME   = 'MIG'.
  IF P_LINE-MATKL EQ 'HNBD-INS'.
    LS_CON-ARBPL = 'INS001'.
  ELSE.
    LS_CON-ARBPL = 'BUS001'.
  ENDIF.
  APPEND LS_CON TO LT_CON.

  CLEAR: LT_RESULT.
  CALL FUNCTION 'ZGTPP_IF_I_PROD_CONF'
    EXPORTING
      I_MODE      = 'P'
      I_SYSTEM_ID = 'KBDM'
* IMPORTING
*     ZO_RESULT   =
*     ZO_MESSAGE  =
    TABLES
      IT_CON      = LT_CON
      OT_RESULT   = LT_RESULT.

  CLEAR: LS_RESULT.
  READ TABLE LT_RESULT INTO LS_RESULT WITH KEY ZERP_STAT = 'S'.
  IF SY-SUBRC EQ 0 AND LS_RESULT IS NOT INITIAL.
    P_LINE-RUECK = LS_RESULT-RUECK.
    P_LINE-RMZHL = LS_RESULT-RMZHL.
    P_LINE-LMNGA = P_LINE-MENGE3160.
    P_LINE-MEINH = P_LINE-MEINS3160.
    P_LINE-ISM02 = '0.001'.
    P_LINE-ILE02 = 'MIN'.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROC_CRET11
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PROC_CRET11 .

  DATA: LT_ROW_NO TYPE LVC_T_ROID WITH HEADER LINE,
        L_ANSWER  TYPE CHAR01.

  FIELD-SYMBOLS: <FS_S> LIKE GS_MAIN_DISP.

  CLEAR: L_ANSWER.

  PERFORM SEL_ROW_RTN TABLES LT_ROW_NO
                      USING  GO_GRID_0100.

  IF LT_ROW_NO[] IS INITIAL.
    MESSAGE S003 DISPLAY LIKE 'W'
       WITH '실행 할 레코드를 선택하세요.'.
    EXIT.
  ENDIF.

  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      TITLEBAR              = '생산 실적 등록'
      TEXT_QUESTION         = '생산 실적 등록을 수행하시겠습니까?'
      DISPLAY_CANCEL_BUTTON = SPACE
    IMPORTING
      ANSWER                = L_ANSWER.

  IF L_ANSWER = '1'.
    LOOP AT LT_ROW_NO.
      READ TABLE GT_MAIN_DISP ASSIGNING <FS_S> INDEX LT_ROW_NO-ROW_ID.

      IF <FS_S>-STATUS_T11 EQ ICON_LED_GREEN.
        <FS_S>-RTMSG = '이미 생산실적 보정 처리가 완료된 레코드입니다.'.
      ELSE.
        PERFORM EXEC_CRET11 USING <FS_S>.
      ENDIF.

    ENDLOOP.

    " REFRESH DISPLAY
    PERFORM REF_ALV_RTN USING GO_GRID_0100.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form EXEC_CRET11
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> <FS_S>
*&---------------------------------------------------------------------*
FORM EXEC_CRET11  USING    P_LINE LIKE GS_MAIN_DISP.

  DATA: LT_CON    TYPE TABLE OF ZGTPPSIF0020,
        LT_RESULT TYPE TABLE OF ZGTPPSIF0021.

  DATA: LS_CON    TYPE ZGTPPSIF0020,
        LS_RESULT TYPE ZGTPPSIF0021.

  CLEAR: LT_CON.
  LS_CON-WERKS  = P_LINE-WERKS.
  LS_CON-AUFNR  = P_LINE-AUFNR.
  LS_CON-BUDAT  = SY-DATUM.
  LS_CON-ZSERNO = SY-DATUM && |9998|.
  LS_CON-MENGE  = P_LINE-LMNGA.
  LS_CON-MEINH  = P_LINE-MEINS.
  LS_CON-VORNR  = '0011'.
  LS_CON-LMNGA  = P_LINE-LMNGA.
  LS_CON-TAGNR  = P_LINE-LINE_NO && |,| && P_LINE-SERIAL_INFO.
  LS_CON-ISDD   = SY-DATUM.
  LS_CON-IEDD   = SY-DATUM.
  LS_CON-ISM01  = P_LINE-ISM02.
  LS_CON-ILE01  = 'MIN'.
  LS_CON-PERNR  = '99999998'.
  LS_CON-NAME   = 'ACT'.
  IF P_LINE-MTART EQ 'HALB'.
    IF P_LINE-MATKL EQ 'HNBD-INS'.
      LS_CON-ARBPL = 'INS001'.
    ELSE.
      LS_CON-ARBPL = 'BUS001'.
    ENDIF.
  ELSEIF P_LINE-MTART EQ 'FERT'.
    LS_CON-ARBPL = 'ASM001'.
  ENDIF.
  APPEND LS_CON TO LT_CON.

  CLEAR: LT_RESULT.
  CALL FUNCTION 'ZGTPP_IF_I_PROD_CONF'
    EXPORTING
      I_MODE      = 'P'
      I_SYSTEM_ID = 'KBDM'
* IMPORTING
*     ZO_RESULT   =
*     ZO_MESSAGE  =
    TABLES
      IT_CON      = LT_CON
      OT_RESULT   = LT_RESULT.

  CLEAR: LS_RESULT.
  READ TABLE LT_RESULT INTO LS_RESULT WITH KEY ZERP_STAT = 'S'.
  IF SY-SUBRC EQ 0.
    P_LINE-STATUS_T11 = ICON_LED_GREEN.
    P_LINE-RTMSG = '투입 성공'.
  ELSE.
    READ TABLE LT_RESULT INTO LS_RESULT WITH KEY ZERP_STAT = 'E'.
    P_LINE-RTMSG = LS_RESULT-ZERP_MESSAGE.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROC_CANT10
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PROC_CANT10 .
  DATA: LT_ROW_NO TYPE LVC_T_ROID WITH HEADER LINE,
        L_ANSWER  TYPE CHAR01.

  FIELD-SYMBOLS: <FS_S> LIKE GS_MAIN_DISP.

  CLEAR: L_ANSWER.

  PERFORM SEL_ROW_RTN TABLES LT_ROW_NO
                      USING  GO_GRID_0100.

  IF LT_ROW_NO[] IS INITIAL.
    MESSAGE S003 DISPLAY LIKE 'W'
       WITH '실행 할 레코드를 선택하세요.'.
    EXIT.
  ENDIF.

  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      TITLEBAR              = '생산 실적 취소'
      TEXT_QUESTION         = '생산 실적 취소를 수행하시겠습니까?'
      DISPLAY_CANCEL_BUTTON = SPACE
    IMPORTING
      ANSWER                = L_ANSWER.

  IF L_ANSWER = '1'.
    LOOP AT LT_ROW_NO.
      READ TABLE GT_MAIN_DISP ASSIGNING <FS_S> INDEX LT_ROW_NO-ROW_ID.

      IF <FS_S>-STATUS_T10 EQ ICON_LED_RED.
        <FS_S>-RTMSG = '이미 생산실적 취소 처리가 완료된 레코드입니다.'.
      ELSEIF <FS_S>-STATUS_T10 EQ ICON_LED_GREEN.
        PERFORM EXEC_CANT10 USING <FS_S>.
      ENDIF.

    ENDLOOP.

    " REFRESH DISPLAY
    PERFORM REF_ALV_RTN USING GO_GRID_0100.

  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form EXEC_CANT10
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> <FS_S>
*&---------------------------------------------------------------------*
FORM EXEC_CANT10  USING    P_LINE LIKE GS_MAIN_DISP.

  DATA: LV_LOCKED    TYPE RU_LOCKED,
        LV_CONF_NO   TYPE CO_RUECK,
        LV_CONF_CNT  TYPE CO_RMZHL,
        LS_RETURN    TYPE BAPIRET1,
        LV_CONF_TEXT TYPE BAPI_PP_CONFIRM-CONF_TEXT.

  CLEAR: LV_CONF_TEXT.
  LV_CONF_TEXT = P_LINE-LINE_NO && |,| && P_LINE-SERIAL_INFO.

  CLEAR: LV_LOCKED, LV_CONF_NO, LV_CONF_CNT, LS_RETURN.

  CALL FUNCTION 'BAPI_PRODORDCONF_CANCEL'
    EXPORTING
      CONFIRMATION        = P_LINE-RUECK
      CONFIRMATIONCOUNTER = P_LINE-RMZHL
      POSTG_DATE          = P_LINE-BUDATT10
      CONF_TEXT           = LV_CONF_TEXT
    IMPORTING
      RETURN              = LS_RETURN
      LOCKED              = LV_LOCKED
      CREATED_CONF_NO     = LV_CONF_NO
      CREATED_CONF_COUNT  = LV_CONF_CNT.

  IF LV_CONF_NO IS NOT INITIAL.
    P_LINE-RTMSG = '투입 취소 성공'.

    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        WAIT = 'X'.

    WAIT UP TO '0.5' SECONDS.
  ELSE.
    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

    P_LINE-RTMSG = LS_RETURN-MESSAGE.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHK_COCKPIT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CHK_COCKPIT .
  DATA: LV_CKP(1).
  IMPORT CKP TO LV_CKP FROM MEMORY ID 'CKP'.
  FREE MEMORY ID 'CKP'.

  IF LV_CKP EQ 'X'.
    EXPORT CKP = 'S' TO MEMORY ID 'CKP'.
    CLEAR: LV_CKP.
  ENDIF.
ENDFORM.
