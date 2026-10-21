*&---------------------------------------------------------------------*
*& Include          ZGTPPR3200F01
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

  PERFORM SET_INIT_GS_WKDAT.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_INIT_GS_WKDAT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_INIT_GS_WKDAT .

  DATA : LV_BGN_DT TYPE SY-DATUM.
  DATA : LV_END_DT TYPE SY-DATUM.

* 처리일자 디폴트값 이전월 1일 당월 말일
  LV_BGN_DT = SY-DATUM+0(6) && '01'.
  LV_BGN_DT = LV_BGN_DT - 1.
  LV_BGN_DT = LV_BGN_DT+0(6) && '01'.

  LV_END_DT = SY-DATUM.
  PERFORM GET_LAST_DAY_OF_MONTH CHANGING   LV_END_DT.

  GS_WKDAT-SIGN = 'I'.
  GS_WKDAT-OPTION = 'BT'.
  GS_WKDAT-LOW = LV_BGN_DT.
  GS_WKDAT-HIGH = LV_END_DT.
  APPEND GS_WKDAT.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_LAST_DAY_OF_MONTH
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- LV_END_DT
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
*& Form READ_DATA_FROM_TABLES
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM READ_DATA_FROM_TABLES .

  DATA : BEGIN OF LT_AUFNR OCCURS 0,
           AUFNR LIKE AFPO-AUFNR,
         END OF LT_AUFNR.

  DATA LT_DATA LIKE GT_DATA OCCURS 0 WITH HEADER LINE.

  DATA : LV_KUNNR LIKE VBPA-KUNNR.

  REFRESH : LT_AUFNR.   CLEAR : LT_AUFNR.

*& 판매오더번호와 품목번호가 조건에 있으면 해당 생산오더를 먼저 조회
*& 판매오더가 없으면 zppt0001에서만 조회

  IF GS_KDAUF IS NOT INITIAL.
*>> START - Archiving 관련변경 02 -> 20080306
    SELECT AUFNR
    INTO CORRESPONDING FIELDS OF TABLE LT_AUFNR
     FROM  AFPO
    WHERE KDAUF IN GS_KDAUF
      AND KDPOS IN GS_KDPOS.
*-- 아카이브 체크를 한 경우에만 AS 테이블에서 정보를 가지고 온다.
    IF NOT P_ARCV IS INITIAL.
      SELECT AUFNR
      APPENDING CORRESPONDING FIELDS OF TABLE LT_AUFNR
        FROM ZARIXPP5
       WHERE KDAUF IN GS_KDAUF
         AND KDPOS IN GS_KDPOS.
    ENDIF.
*>> END   - Archiving 관련변경 02 -> 20080306
    IF LT_AUFNR[] IS INITIAL.
      MESSAGE S012.
      RETURN.
    ELSE.

      LOOP AT LT_AUFNR.
        GS_AUFNR-SIGN   = 'I'.
        GS_AUFNR-OPTION = 'EQ'.
        GS_AUFNR-LOW    = LT_AUFNR-AUFNR.

        APPEND GS_AUFNR.
      ENDLOOP.

    ENDIF.
  ENDIF.

*>> START - Archiving 관련변경 03 -> 20080306
  SELECT A~SPGCD      A~PROCD    A~TAGNR    A~AUFNR
           A~CHARG    A~MATNR    B~MAKTX    A~ARBPL
           A~MGVRG    A~MEINS    A~WKDAT    A~PTS_ARBPL
           A~WKINNAM  C~KDAUF    C~KDPOS    "SRM2009-094931
      INTO CORRESPONDING FIELDS OF TABLE LT_DATA
      FROM ZPPT0001 AS A  INNER JOIN MAKT AS B
                                  ON A~MATNR = B~MATNR
                          LEFT JOIN AFPO AS C
                                  ON A~AUFNR = C~AUFNR
                                 AND A~POSNR = C~POSNR
     WHERE A~WERKS  = GP_WERKS
       AND A~WKDAT IN GS_WKDAT
       AND A~SPGCD IN GS_SPGCD
       AND A~PROCD IN GS_PROCD
       AND A~AUFNR IN GS_AUFNR
       AND A~TAGNR IN GS_TAGNR
       AND A~MATNR IN GS_MATNR
       AND A~CHARG IN GS_CHARG
       AND B~SPRAS  = SY-LANGU
       AND A~SHIFT  = SPACE.                 " 교대조가 아닌 것
*-- 아카이브 체크를 한 경우에만 AS 테이블에서 정보를 가지고 온다.
  IF NOT P_ARCV IS INITIAL.
* 로컬변수선언
    DATA LT_DATA_E LIKE GT_DATA OCCURS 0.
    REFRESH LT_DATA_E.

    SELECT A~SPGCD      A~PROCD    A~TAGNR    A~AUFNR
             A~CHARG    A~MATNR    B~MAKTX    A~ARBPL
             A~MGVRG    A~MEINS    A~WKDAT    A~PTS_ARBPL
             A~WKINNAM  C~KDAUF    C~KDPOS    "SRM2009-094931
        INTO CORRESPONDING FIELDS OF TABLE LT_DATA_E
        FROM ZARIXPP1 AS A  INNER JOIN MAKT AS B
                                    ON A~MANDT = B~MANDT
                                   AND A~MATNR = B~MATNR
                            LEFT JOIN ZARIXPP5 AS C
                                    ON A~AUFNR = C~AUFNR
                                   AND A~POSNR = C~POSNR
       WHERE A~WERKS  = GP_WERKS
         AND A~AUFNR IN GS_AUFNR
         AND A~WKDAT IN GS_WKDAT
         AND A~SPGCD IN GS_SPGCD
         AND A~PROCD IN GS_PROCD
         AND A~TAGNR IN GS_TAGNR
         AND A~MATNR IN GS_MATNR
         AND A~CHARG IN GS_CHARG
         AND B~SPRAS  = SY-LANGU
         AND A~SHIFT  = SPACE                   " 교대조가 아닌 것
*-- 강제로 아래의 인덱스를 먼저 타게 한다. (ZARIXPP1~Z02)
         %_HINTS ORACLE 'INDEX_FFS(T_00 "ZARIXPP1~Z02")'.
    IF NOT LT_DATA_E[] IS INITIAL.
      APPEND LINES OF LT_DATA_E[] TO LT_DATA[].
    ENDIF.
  ENDIF.
*>> END   - Archiving 관련변경 03 -> 20080306

*& 2010.01.19 CSR : C20100118_94728
*& 납품처 또는 판매처 조회조건이 있는 경우 해당 거래처외 삭제처리
  IF GS_KUNN1[] IS NOT INITIAL OR
     GS_KUNN2[] IS NOT INITIAL.

    DELETE LT_DATA WHERE KDAUF IS INITIAL.

    LOOP AT LT_DATA.

      IF GS_KUNN1[] IS NOT INITIAL.   "판매처로 조회

        CLEAR : LV_KUNNR.

        SELECT SINGLE KUNNR
          INTO LV_KUNNR
          FROM VBPA
         WHERE VBELN = LT_DATA-KDAUF
           AND KUNNR IN GS_KUNN1
           AND PARVW EQ 'AG'.

        IF LV_KUNNR IS INITIAL.
          DELETE LT_DATA.
        ENDIF.

      ELSE.                           "납품처로 조회

        CLEAR : LV_KUNNR.

        SELECT SINGLE KUNNR
          INTO LV_KUNNR
          FROM VBPA
         WHERE VBELN = LT_DATA-KDAUF
           AND KUNNR IN GS_KUNN2
           AND PARVW EQ 'WE'.

        IF LV_KUNNR IS INITIAL.
          DELETE LT_DATA.
        ENDIF.
      ENDIF.

    ENDLOOP.
  ENDIF.

* 2020.10.08 조영현 START SRM2009-094931 - 판매처, 납품처 추가
  LOOP AT LT_DATA WHERE KDAUF IS NOT INITIAL.
    CLEAR: LT_DATA-KUNAG.
    SELECT SINGLE KUNNR INTO LT_DATA-KUNAG
                        FROM VBPA
                       WHERE VBELN = LT_DATA-KDAUF
                         AND PARVW = 'AG'.
    CLEAR: LT_DATA-KUNWE.
    SELECT SINGLE KUNNR INTO LT_DATA-KUNWE
                        FROM VBPA
                       WHERE VBELN = LT_DATA-KDAUF
                         AND PARVW = 'WE'.
    MODIFY LT_DATA.
  ENDLOOP.
* 2020.10.08 조영현 END   SRM2009-094931 - 판매처, 납품처 추가

  GT_DATA[] = LT_DATA[].

*& CSR : C2007042301000000514
*& 작업자 추가

  LOOP AT GT_DATA WHERE WKINNAM IS NOT INITIAL.

    SELECT SINGLE ENAME
      INTO GT_DATA-ENAME
* { begin --> 2023.08.10 HR Object 변경
*      FROM pa0001
      FROM ZZPA0001
* <-- 2023.08.10 HR Object 변경 end }
     WHERE PERNR  = GT_DATA-WKINNAM.

    MODIFY GT_DATA.

  ENDLOOP.

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
  GS_LAYOUT_0100-CWIDTH_OPT = ABAP_TRUE.
  GS_LAYOUT_0100-NO_ROWINS = ABAP_TRUE.
  GS_LAYOUT_0100-SEL_MODE   = 'A'.

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
*& Form SET_FIELDCAT_GRID_0100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_FIELDCAT_GRID_0100 .

  DATA: LS_FIELDCAT      LIKE LVC_S_FCAT.

  CLEAR: LS_FIELDCAT.

  REFRESH GT_FIELDCAT_0100.

  CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
    EXPORTING
      I_STRUCTURE_NAME = 'ZPPS038'
    CHANGING
      CT_FIELDCAT      = GT_FIELDCAT_0100[].

  LOOP AT GT_FIELDCAT_0100 INTO LS_FIELDCAT.
    CASE LS_FIELDCAT-FIELDNAME.
      WHEN 'SPGCD' OR 'PROCD' OR 'TAGNR'.
        LS_FIELDCAT-FIX_COLUMN = 'X'.
        LS_FIELDCAT-EMPHASIZE = 'C400'.
        MODIFY GT_FIELDCAT_0100 FROM LS_FIELDCAT.
    ENDCASE.
  ENDLOOP.

* 2020.10.08 조영현 START SRM2009-094931 - 판매/납품처,판매오더품번추가
* ZPPS038 구조체는 QMS 펑션에 쓰고 있으므로 수동으로 추가
  CLEAR: GV_POS.
  DESCRIBE TABLE GT_FIELDCAT_0100 LINES GV_POS.

  PERFORM SET_ALV_FIELD_DETAIL
   USING 'KDAUF' '영업오더' ' ' ' ' '10' ' ' ' ' ' ' ' ' 'X'.
  PERFORM SET_ALV_FIELD_DETAIL
   USING 'KDPOS' '품번'     ' ' ' ' '06' ' ' ' ' ' ' ' ' 'X'.
  PERFORM SET_ALV_FIELD_DETAIL
   USING 'KUNAG' '판매처'   ' ' ' ' '10' ' ' 'X' ' ' ' ' 'X'.
  PERFORM SET_ALV_FIELD_DETAIL
   USING 'KUNWE' '납품처'   ' ' ' ' '10' ' ' 'X' ' ' ' ' 'X'.
* 2020.10.08 조영현 END   SRM2009-094931 - 판매/납품처,판매오더품번추가

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_ALV_FIELD_DETAIL
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> P_
*&      --> P_
*&      --> P_
*&      --> P_
*&      --> P_
*&      --> P_
*&      --> P_
*&      --> P_
*&      --> P_
*&---------------------------------------------------------------------*
FORM SET_ALV_FIELD_DETAIL  USING    VALUE(PV_FIELDNAME)
                                 VALUE(PV_COLTEXT)
                                 VALUE(PV_JUST)
                                 VALUE(PV_KEY)
                                 VALUE(PV_OUTPUTLEN)
                                 VALUE(PV_CHECK)
                                 VALUE(PV_LZERO)
                                 VALUE(PV_EDIT)
                                 VALUE(PV_EMPHASIZE)
                                 VALUE(PV_NO_OUT).

  GV_POS = GV_POS + 1.
  APPEND INITIAL LINE TO GT_FIELDCAT_0100 ASSIGNING FIELD-SYMBOL(<LS_FCAT>).



  <LS_FCAT>-COL_POS   = GV_POS.
  <LS_FCAT>-FIELDNAME = PV_FIELDNAME.
  <LS_FCAT>-COLTEXT   = PV_COLTEXT.
  <LS_FCAT>-JUST      = PV_JUST.
  <LS_FCAT>-KEY       = PV_KEY.
  <LS_FCAT>-OUTPUTLEN = PV_OUTPUTLEN.
  <LS_FCAT>-CHECKBOX  = PV_CHECK.
  IF PV_LZERO = 'X'.
    <LS_FCAT>-CONVEXIT  = 'ALPHA'.
  ENDIF.
  <LS_FCAT>-NO_OUT    = PV_NO_OUT.
  <LS_FCAT>-EDIT      = PV_EDIT.
  <LS_FCAT>-EMPHASIZE = PV_EMPHASIZE.

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
      IT_OUTTAB            = GT_DATA[]
      IT_FIELDCATALOG      = GT_FIELDCAT_0100.

ENDFORM.
