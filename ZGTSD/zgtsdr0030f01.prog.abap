*&---------------------------------------------------------------------*
*& Include          ZGTSDR0030F01
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

*  P_VKORG = |1000|.
*  P_VTWEG = |10|.
*  P_SPART = |60|.
  P_ERDAT = SY-DATLO.

  CLEAR GV_WEB.
  CALL FUNCTION 'GUI_IS_ITS'
    IMPORTING
      RETURN = GV_WEB.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form MODIFY_SCREEN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM MODIFY_SCREEN .

  LOOP AT SCREEN.

    CASE SCREEN-GROUP1.
      WHEN 'GR1'.
        IF RB_BT3 = ZGTSD_X.
          SCREEN-ACTIVE = 1.

          CASE SCREEN-NAME.
            WHEN 'P_KUNWE' OR '%_P_KUNWE_%_APP_%-TEXT'.
              IF P_RB1 = ZGTSD_X.
                SCREEN-ACTIVE = 1.
              ELSE.
                SCREEN-ACTIVE = 0.
              ENDIF.
            WHEN 'P_KUNNR' OR '%_P_KUNNR_%_APP_%-TEXT'.
              CASE ZGTSD_X.
                WHEN P_RB1 OR P_RB2 OR P_RB6.
                  SCREEN-ACTIVE = 1.
                WHEN OTHERS.
                  SCREEN-ACTIVE = 0.
              ENDCASE.
            WHEN 'P_PLTYP' OR '%_P_PLTYP_%_APP_%-TEXT'.
              CASE ZGTSD_X.
                WHEN P_RB3.
                  SCREEN-ACTIVE = 1.
                WHEN OTHERS.
                  SCREEN-ACTIVE = 0.
              ENDCASE.
            WHEN 'P_WAERK' OR '%_P_WAERK_%_APP_%-TEXT'.
              CASE ZGTSD_X.
                WHEN P_RB4 OR P_RB5.
                  SCREEN-ACTIVE = 1.
                WHEN OTHERS.
                  SCREEN-ACTIVE = 0.
              ENDCASE.
            WHEN 'P_SPART' OR '%_P_SPART_%_APP_%-TEXT'.
              CASE ZGTSD_X.
                WHEN P_RB5.
                  SCREEN-ACTIVE = 0.
                WHEN OTHERS.
                  SCREEN-ACTIVE = 1.
                  SCREEN-REQUIRED = 2.
              ENDCASE.

            WHEN 'P_VAR' OR '%_P_VAR_%_APP_%-TEXT'.
              CASE ZGTSD_X.
                WHEN P_RB6.
                  SCREEN-ACTIVE = 1.
                WHEN OTHERS.
                  SCREEN-ACTIVE = 0.
              ENDCASE.

          ENDCASE.

        ELSE.
          SCREEN-ACTIVE = 0.
        ENDIF.

      WHEN 'GR2'.

        CASE ZGTSD_X.
          WHEN RB_BT1 OR RB_BT3.
            SCREEN-ACTIVE = 1.
            SCREEN-REQUIRED = 2.
          WHEN OTHERS.
            SCREEN-ACTIVE = 0.
        ENDCASE.

      WHEN 'UPL'.
        IF RB_BT1 = ZGTSD_X.
          SCREEN-ACTIVE = 1.
        ELSE.
          SCREEN-ACTIVE = 0.
        ENDIF.
    ENDCASE.

    MODIFY SCREEN.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_INPUT_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CHECK_INPUT_DATA .

  CLEAR GV_ERROR.

  IF RB_BT1 = ZGTSD_X AND P_FNAME IS INITIAL.
    GV_ERROR = ZGTSD_X.
    MESSAGE S007 WITH %_P_FNAME_%_APP_%-TEXT DISPLAY LIKE GC_E.
    LEAVE LIST-PROCESSING.
  ENDIF.

  CASE ZGTSD_X.
    WHEN RB_BT1 OR RB_BT3.
      IF P_VKORG IS INITIAL.
        GV_ERROR = ZGTSD_X.
        MESSAGE S007 WITH %_P_VKORG_%_APP_%-TEXT DISPLAY LIKE GC_E.
        LEAVE LIST-PROCESSING.
      ENDIF.
  ENDCASE.

  CASE ZGTSD_X.
    WHEN RB_BT3.
      IF P_RB5 IS INITIAL AND P_SPART IS INITIAL.
        GV_ERROR = ZGTSD_X.
        MESSAGE S007 WITH %_P_SPART_%_APP_%-TEXT DISPLAY LIKE GC_E.
        LEAVE LIST-PROCESSING.
      ENDIF.
  ENDCASE.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form AUTHORITY_CHECK
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM AUTHORITY_CHECK .

*  "권한 체크
*  ZGTSD_CL_COMMON=>AUTHORITY_CHECK( EXPORTING IV_OBJECT     = 'VKO'
*                                              IV_AUTH_FIELD = CONV XUFIELD( |VKORG| )
*                                              IV_AUTH_VAL   = CONV XUVAL( P_VKORG )
*                                    IMPORTING EV_MTYPE      = DATA(LV_MTYPE)
*                                              EV_MSGTX      = DATA(LV_MSGTX) ).
*  IF LV_MTYPE = GC_E.
*    MESSAGE S001(00) WITH LV_MSGTX DISPLAY LIKE GC_E.
*    LEAVE LIST-PROCESSING.
*  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form DATA_QUERY
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM DATA_QUERY .

  RANGES : LR_KUNNR FOR A915-KUNNR,
           LR_KUNWE FOR A915-KUNWE,
           LR_SPART FOR A915-SPART,
           LR_PLTYP FOR A516-PLTYP,
           LR_VAR   FOR A514-VARCOND,
           LR_WAERK FOR A506-WAERK.

  IF P_SPART IS NOT INITIAL.
    __RNG : LR_SPART 'I' 'EQ' P_SPART ''.
  ENDIF.

  IF P_KUNNR IS NOT INITIAL.
    __RNG : LR_KUNNR 'I' 'EQ' P_KUNNR ''.
  ENDIF.

  IF P_KUNWE IS NOT INITIAL.
    __RNG : LR_KUNWE 'I' 'EQ' P_KUNWE ''.
  ENDIF.

  IF P_PLTYP IS NOT INITIAL.
    __RNG : LR_PLTYP 'I' 'EQ' P_PLTYP ''.
  ENDIF.

  IF P_WAERK IS NOT INITIAL.
    __RNG : LR_WAERK 'I' 'EQ' P_WAERK ''.
  ENDIF.

  IF P_VAR IS NOT INITIAL.
    __RNG : LR_VAR 'I' 'EQ' P_VAR ''.
  ENDIF.

  CASE ZGTSD_X.
    WHEN P_RB1.

      SELECT A~MATNR, B~MAKTX, C~KBETR, C~KONWA, C~KPEIN,
             A~DATAB, A~DATBI, A~VKORG, A~VTWEG, A~SPART,
             A~KUNNR, A~KUNWE, C~KMEIN, C~LOEVM_KO,
             D~VTEXT AS VTWEG_NM, F~VTEXT AS SPART_NM,
             H~VTEXT AS VKORG_NM, E~NAME1, G~NAME1 AS KUNWE_NM
        FROM A915 AS A LEFT OUTER JOIN MAKT AS B
          ON A~MATNR = B~MATNR
         AND B~SPRAS = @SY-LANGU
       INNER JOIN KONP AS C
          ON A~KNUMH = C~KNUMH
        LEFT OUTER JOIN TVKOT AS H
          ON A~VKORG = H~VKORG
         AND H~SPRAS = @SY-LANGU
        LEFT OUTER JOIN TVTWT AS D
          ON A~VTWEG = D~VTWEG
         AND D~SPRAS = @SY-LANGU
        LEFT OUTER JOIN TSPAT AS F
          ON A~SPART = F~SPART
         AND F~SPRAS = @SY-LANGU
        LEFT OUTER JOIN KNA1 AS E
          ON E~KUNNR = A~KUNNR
        LEFT OUTER JOIN KNA1 AS G
          ON G~KUNNR = A~KUNWE
       WHERE A~KSCHL = 'PR00'
         AND A~VKORG = @P_VKORG
         AND A~VTWEG = @P_VTWEG
         AND A~SPART IN @LR_SPART
         AND A~KUNNR IN @LR_KUNNR
         AND A~KUNWE IN @LR_KUNWE
         AND A~MATNR IN @S_MATNR
         AND A~DATAB <= @P_ERDAT
         AND A~DATBI >= @P_ERDAT
        INTO CORRESPONDING FIELDS OF TABLE @GT_S0100.

    WHEN P_RB2.

      SELECT A~MATNR, B~MAKTX, C~KBETR, C~KONWA, C~KPEIN,
             A~DATAB, A~DATBI, A~VKORG, A~VTWEG, A~SPART, C~LOEVM_KO,
             D~VTEXT AS VTWEG_NM, F~VTEXT AS SPART_NM, C~KMEIN,
             H~VTEXT AS VKORG_NM, E~NAME1, A~KUNNR
        FROM A515 AS A LEFT OUTER JOIN MAKT AS B
          ON A~MATNR = B~MATNR
         AND B~SPRAS = @SY-LANGU
       INNER JOIN KONP AS C
          ON A~KNUMH = C~KNUMH
        LEFT OUTER JOIN TVKOT AS H
          ON A~VKORG = H~VKORG
         AND H~SPRAS = @SY-LANGU
        LEFT OUTER JOIN TVTWT AS D
          ON A~VTWEG = D~VTWEG
         AND D~SPRAS = @SY-LANGU
        LEFT OUTER JOIN TSPAT AS F
          ON A~SPART = F~SPART
         AND F~SPRAS = @SY-LANGU
        LEFT OUTER JOIN KNA1 AS E
          ON E~KUNNR = A~KUNNR
       WHERE A~KSCHL = 'PR00'
         AND A~VKORG = @P_VKORG
         AND A~VTWEG = @P_VTWEG
         AND A~SPART IN @LR_SPART
         AND A~KUNNR IN @LR_KUNNR
         AND A~MATNR IN @S_MATNR
         AND A~DATAB <= @P_ERDAT
         AND A~DATBI >= @P_ERDAT
        INTO CORRESPONDING FIELDS OF TABLE @GT_S0100.

    WHEN P_RB3.

      SELECT A~MATNR, B~MAKTX, C~KBETR, C~KONWA, C~KPEIN, C~KMEIN,
             A~DATAB, A~DATBI, A~VKORG, A~VTWEG, A~SPART, C~LOEVM_KO,
             D~VTEXT AS VTWEG_NM, F~VTEXT AS SPART_NM,
             H~VTEXT AS VKORG_NM, E~PTEXT, A~PLTYP
        FROM A516 AS A LEFT OUTER JOIN MAKT AS B
          ON A~MATNR = B~MATNR
         AND B~SPRAS = @SY-LANGU
       INNER JOIN KONP AS C
          ON A~KNUMH = C~KNUMH
        LEFT OUTER JOIN TVKOT AS H
          ON A~VKORG = H~VKORG
         AND H~SPRAS = @SY-LANGU
        LEFT OUTER JOIN TVTWT AS D
          ON A~VTWEG = D~VTWEG
         AND D~SPRAS = @SY-LANGU
        LEFT OUTER JOIN TSPAT AS F
          ON A~SPART = F~SPART
         AND F~SPRAS = @SY-LANGU
        LEFT OUTER JOIN T189T AS E
          ON A~PLTYP = E~PLTYP
         AND E~SPRAS = @SY-LANGU
       WHERE A~KSCHL = 'PR00'
         AND A~VKORG = @P_VKORG
         AND A~VTWEG = @P_VTWEG
         AND A~SPART IN @LR_SPART
         AND A~PLTYP IN @LR_PLTYP
         AND A~MATNR IN @S_MATNR
         AND A~DATAB <= @P_ERDAT
         AND A~DATBI >= @P_ERDAT
        INTO CORRESPONDING FIELDS OF TABLE @GT_S0100.

    WHEN P_RB4.

      SELECT A~MATNR, B~MAKTX, C~KBETR, C~KONWA, C~KPEIN, C~KMEIN,
             A~DATAB, A~DATBI, A~VKORG, A~VTWEG, A~SPART, C~LOEVM_KO,
             D~VTEXT AS VTWEG_NM, F~VTEXT AS SPART_NM,
             H~VTEXT AS VKORG_NM
        FROM A506 AS A LEFT OUTER JOIN MAKT AS B
          ON A~MATNR = B~MATNR
         AND B~SPRAS = @SY-LANGU
       INNER JOIN KONP AS C
          ON A~KNUMH = C~KNUMH
        LEFT OUTER JOIN TVKOT AS H
          ON A~VKORG = H~VKORG
         AND H~SPRAS = @SY-LANGU
        LEFT OUTER JOIN TVTWT AS D
          ON A~VTWEG = D~VTWEG
         AND D~SPRAS = @SY-LANGU
        LEFT OUTER JOIN TSPAT AS F
          ON A~SPART = F~SPART
         AND F~SPRAS = @SY-LANGU
       WHERE A~KSCHL = 'PR00'
         AND A~VKORG = @P_VKORG
         AND A~VTWEG = @P_VTWEG
         AND A~SPART IN @LR_SPART
         AND A~WAERK IN @LR_WAERK
         AND A~MATNR IN @S_MATNR
         AND A~DATAB <= @P_ERDAT
         AND A~DATBI >= @P_ERDAT
        INTO CORRESPONDING FIELDS OF TABLE @GT_S0100.

    WHEN P_RB5.

      SELECT A~MATNR, B~MAKTX, C~KBETR, C~KONWA, C~KPEIN, C~KMEIN,
             A~DATAB, A~DATBI, A~VKORG, A~VTWEG, C~LOEVM_KO,
             D~VTEXT AS VTWEG_NM, H~VTEXT AS VKORG_NM
        FROM A507 AS A LEFT OUTER JOIN MAKT AS B
          ON A~MATNR = B~MATNR
         AND B~SPRAS = @SY-LANGU
       INNER JOIN KONP AS C
          ON A~KNUMH = C~KNUMH
        LEFT OUTER JOIN TVKOT AS H
          ON A~VKORG = H~VKORG
         AND H~SPRAS = @SY-LANGU
        LEFT OUTER JOIN TVTWT AS D
          ON A~VTWEG = D~VTWEG
         AND D~SPRAS = @SY-LANGU
       WHERE A~KSCHL = 'PR00'
         AND A~VKORG = @P_VKORG
         AND A~VTWEG = @P_VTWEG
         AND A~WAERK IN @LR_WAERK
         AND A~MATNR IN @S_MATNR
         AND A~DATAB <= @P_ERDAT
         AND A~DATBI >= @P_ERDAT
        INTO CORRESPONDING FIELDS OF TABLE @GT_S0100.

    WHEN P_RB6.

      SELECT A~MATNR, B~MAKTX, C~KBETR, C~KONWA, C~KPEIN,
             A~DATAB, A~DATBI, A~VKORG, A~VTWEG, A~SPART, C~LOEVM_KO,
             D~VTEXT AS VTWEG_NM, F~VTEXT AS SPART_NM, C~KMEIN,
             H~VTEXT AS VKORG_NM, E~NAME1, A~KUNNR, VARCOND
        FROM A514 AS A LEFT OUTER JOIN MAKT AS B
          ON A~MATNR = B~MATNR
         AND B~SPRAS = @SY-LANGU
       INNER JOIN KONP AS C
          ON A~KNUMH = C~KNUMH
        LEFT OUTER JOIN TVKOT AS H
          ON A~VKORG = H~VKORG
         AND H~SPRAS = @SY-LANGU
        LEFT OUTER JOIN TVTWT AS D
          ON A~VTWEG = D~VTWEG
         AND D~SPRAS = @SY-LANGU
        LEFT OUTER JOIN TSPAT AS F
          ON A~SPART = F~SPART
         AND F~SPRAS = @SY-LANGU
        LEFT OUTER JOIN KNA1 AS E
          ON E~KUNNR = A~KUNNR
       WHERE A~KSCHL = 'PR00'
         AND A~VKORG = @P_VKORG
         AND A~VTWEG = @P_VTWEG
         AND A~SPART IN @LR_SPART
         AND A~KUNNR IN @LR_KUNNR
         AND A~VARCOND IN @LR_VAR
         AND A~MATNR IN @S_MATNR
         AND A~DATAB <= @P_ERDAT
         AND A~DATBI >= @P_ERDAT
        INTO CORRESPONDING FIELDS OF TABLE @GT_S0100.
  ENDCASE.

  "데이타 건수 메시지 출력
  IF GT_S0100 IS NOT INITIAL.
    MESSAGE S009 WITH |{ LINES( GT_S0100 ) NUMBER = USER }|. "& 건 검색되었습니다.
  ELSE.
    MESSAGE S010.                                           "조회할 데이타가 없습니다.
    GV_ERROR = GC_X.                                        "데이타 없으면 출력 X
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form INIT_ALV_0100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- GO_CON
*&      <-- GO_GRID
*&---------------------------------------------------------------------*
FORM INIT_ALV_0100  CHANGING PO_DCON TYPE REF TO CL_GUI_DOCKING_CONTAINER
                             PO_GRID TYPE REF TO CL_GUI_ALV_GRID.

  "Create Main Container
  PERFORM CREATE_DOC_CONTAINER CHANGING PO_DCON.

*  "Split
*  GO_SPLIT = NEW #( PARENT = PO_DCON ROWS = 2 COLUMNS = 1 ).
*
*  GO_CON_TOP       = GO_SPLIT->GET_CONTAINER( ROW = 1 COLUMN = 1 ).
*  DATA(LO_CON_BTT) = GO_SPLIT->GET_CONTAINER( ROW = 2 COLUMN = 1 ).
*
*  GO_SPLIT->SET_ROW_HEIGHT( ID = 1 HEIGHT = 15 ).
*
*  "Create Object
*  GO_DOCU = NEW #( STYLE = 'ALV_GRID' ).  "Top-Of-Page

  PERFORM CREATE_ALV USING    PO_DCON
                     CHANGING PO_GRID.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  CREATE_DOC_CONTAINER
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM CREATE_DOC_CONTAINER CHANGING PO_DCON TYPE REF TO CL_GUI_DOCKING_CONTAINER.

  CREATE OBJECT PO_DCON
    EXPORTING
      PARENT                      = CL_GUI_CONTAINER=>DEFAULT_SCREEN
      REPID                       = SY-REPID
      DYNNR                       = SY-DYNNR
      SIDE                        = CL_GUI_DOCKING_CONTAINER=>DOCK_AT_TOP
      EXTENSION                   = 3000
    EXCEPTIONS
      CNTL_ERROR                  = 1
      CNTL_SYSTEM_ERROR           = 2
      CREATE_ERROR                = 3
      LIFETIME_ERROR              = 4
      LIFETIME_DYNPRO_DYNPRO_LINK = 5
      OTHERS                      = 6.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  CREATE_ALV
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM CREATE_ALV CHANGING PO_CON
                         PO_GRID TYPE REF TO CL_GUI_ALV_GRID.

  CREATE OBJECT PO_GRID
    EXPORTING
      I_PARENT          = PO_CON
    EXCEPTIONS
      ERROR_CNTL_CREATE = 1
      ERROR_CNTL_INIT   = 2
      ERROR_CNTL_LINK   = 3
      ERROR_DP_CREATE   = 4
      OTHERS            = 5.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_ATTRIBUTES_0100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM SET_ATTRIBUTES_0100 .

  "Layout 지정
  PERFORM SET_GRID_LAYOUT USING 'X' SPACE ZGTSD_D.

  "Field Catalog
  PERFORM SET_FIELDCATALOG.

  "Toolbar 제외
  PERFORM EXCLUDE_TOOLBAR TABLES GT_TOOLBAR.

  "Event Handler 등록
  PERFORM CREATE_EVENT_RECEIVER USING GO_GRID.

  "F4 필드 등록
  PERFORM REGISTER_F4_FIELDS.

  "SORT
  PERFORM SET_ALV_SORT CHANGING GT_SORT.

  "Top-Of-Page Event 등록
  PERFORM SET_TOP_OF_PAGE_EVENT.

  "ALV Grid Display
  PERFORM SET_TABLE_FOR_FIRST_DISPLAY USING GO_GRID
                                            GT_S0100.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_GRID_LAYOUT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM SET_GRID_LAYOUT USING PV_CWOPT
                           PV_STYLEFNAME
                           PV_SEL_MODE.

  CLEAR GS_LAYOUT.
  GS_LAYOUT = VALUE #( SEL_MODE   = PV_SEL_MODE
                       ZEBRA      = ZGTSD_X
                       CWIDTH_OPT = PV_CWOPT
                       STYLEFNAME = PV_STYLEFNAME ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_FIELDCATALOG
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM SET_FIELDCATALOG .

  "Get Field Catalog
  PERFORM GET_FIELD_CATALOG USING GT_S0100 CHANGING GT_FCAT.

  "Set Field Catalog
  PERFORM SET_FIELDCATALOG_MAIN.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_FIELD_CATALOG
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM GET_FIELD_CATALOG USING PT_TABLE TYPE TABLE
                    CHANGING PT_FCAT TYPE LVC_T_FCAT.

  REFRESH PT_FCAT.

  PT_FCAT = ZGTSD_CL_COMMON=>GET_FIELD_CATALOG( IT_TABLE = PT_TABLE
                                                IV_CELLS = ZGTSD_X
                                                IV_CELLC = ZGTSD_X ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_FIELDCATALOG_MAIN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_FIELDCATALOG_MAIN .


  SORT GT_FCAT BY FIELDNAME.
  IF RB_BT1 = 'X'.
    PERFORM RESET_FIELD_CATALOG TABLES GT_FCAT USING :
        'S' 'FIELDNAME'   'STAT',
        ' ' 'COLTEXT'     TEXT-F13,
        ' ' 'ICON'        'X',
        ' ' 'HOTSPOT'     'X',
        ' ' 'OUTPUTLEN'   '10',
        'E' 'KEY'         'X'.
  ENDIF.

  PERFORM RESET_FIELD_CATALOG TABLES GT_FCAT USING :
      'S' 'FIELDNAME'   'VKORG',
      ' ' 'COLTEXT'     TEXT-F14,
      ' ' 'OUTPUTLEN'   '10',
      'E' 'KEY'         'X',

      'S' 'FIELDNAME'   'VKORG_NM',
      ' ' 'COLTEXT'     '영업조직명',
      ' ' 'OUTPUTLEN'   '10',
      'E' 'KEY'         'X',

      'S' 'FIELDNAME'   'VTWEG',
      ' ' 'COLTEXT'     TEXT-F01,
      'E' 'OUTPUTLEN'   '10',

      'S' 'FIELDNAME'   'VTWEG_NM',
      ' ' 'COLTEXT'     '유통 경로명',
      'E' 'OUTPUTLEN'   '10'.

  IF P_RB5 IS INITIAL.
    PERFORM RESET_FIELD_CATALOG TABLES GT_FCAT USING :
        'S' 'FIELDNAME'   'SPART',
        ' ' 'COLTEXT'     TEXT-F02,
        'E' 'OUTPUTLEN'   '10',

        'S' 'FIELDNAME'   'SPART_NM',
        ' ' 'COLTEXT'     '제품군명',
        'E' 'OUTPUTLEN'   '10'.
  ENDIF.

  CASE ZGTSD_X.
    WHEN P_RB1.
      PERFORM RESET_FIELD_CATALOG TABLES GT_FCAT USING :
          'S' 'FIELDNAME'   'KUNNR',
          ' ' 'COLTEXT'     TEXT-F03,
          'E' 'OUTPUTLEN'   '10',

          'S' 'FIELDNAME'   'NAME1',
          ' ' 'COLTEXT'     '판매처명',
          'E' 'OUTPUTLEN'   '10',

          'S' 'FIELDNAME'   'KUNWE',
          ' ' 'COLTEXT'     TEXT-F04,
          'E' 'OUTPUTLEN'   '10',

          'S' 'FIELDNAME'   'KUNWE_NM',
          ' ' 'COLTEXT'     '납품처명',
          'E' 'OUTPUTLEN'   '10'.

    WHEN P_RB2.

      PERFORM RESET_FIELD_CATALOG TABLES GT_FCAT USING :
          'S' 'FIELDNAME'   'KUNNR',
          ' ' 'COLTEXT'     TEXT-F03,
          'E' 'OUTPUTLEN'   '10',

          'S' 'FIELDNAME'   'NAME1',
          ' ' 'COLTEXT'     '판매처명',
          'E' 'OUTPUTLEN'   '10'.

    WHEN P_RB3.

      PERFORM RESET_FIELD_CATALOG TABLES GT_FCAT USING :
          'S' 'FIELDNAME'   'PLTYP',
          ' ' 'COLTEXT'     '가격리스트',
          'E' 'OUTPUTLEN'   '10',

          'S' 'FIELDNAME'   'PTEXT',
          ' ' 'COLTEXT'     '가격리스트명',
          'E' 'OUTPUTLEN'   '10'.

    WHEN P_RB6.

      PERFORM RESET_FIELD_CATALOG TABLES GT_FCAT USING :

          'S' 'FIELDNAME'   'KUNNR',
          ' ' 'COLTEXT'     TEXT-F03,
          'E' 'OUTPUTLEN'   '10',

          'S' 'FIELDNAME'   'NAME1',
          ' ' 'COLTEXT'     '판매처명',
          'E' 'OUTPUTLEN'   '10',

          'S' 'FIELDNAME'   'VARCOND',
          ' ' 'COLTEXT'     'SCR 등급',
          'E' 'OUTPUTLEN'   '10'.

  ENDCASE.

  PERFORM RESET_FIELD_CATALOG TABLES GT_FCAT USING :
      'S' 'FIELDNAME'   'MATNR',
      ' ' 'COLTEXT'     TEXT-F05,
      'E' 'OUTPUTLEN'   '10',

      'S' 'FIELDNAME'   'MAKTX',
      ' ' 'COLTEXT'     '자재명',
      'E' 'OUTPUTLEN'   '20',

      'S' 'FIELDNAME'   'LOEVM_KO',
      ' ' 'COLTEXT'     '삭제 여부',
      ' ' 'CHECKBOX'    'X',

      'E' 'OUTPUTLEN'   '10',

      'S' 'FIELDNAME'   'KBETR',
      ' ' 'COLTEXT'     TEXT-F06,
      ' ' 'CFIELDNAME'  'KONWA',

      'E' 'OUTPUTLEN'   '20',

      'S' 'FIELDNAME'   'KONWA',
      ' ' 'COLTEXT'     TEXT-F07,
      'E' 'OUTPUTLEN'   '20',

      'S' 'FIELDNAME'   'KPEIN',
      ' ' 'COLTEXT'     TEXT-F08,
      'E' 'OUTPUTLEN'   '20'.


  PERFORM RESET_FIELD_CATALOG TABLES GT_FCAT USING :
      'S' 'FIELDNAME'   'KMEIN',
      ' ' 'COLTEXT'     TEXT-F09,
      'E' 'OUTPUTLEN'   '20',

      'S' 'FIELDNAME'   'DATAB',
      ' ' 'COLTEXT'     TEXT-F10,
      'E' 'OUTPUTLEN'   '20',

      'S' 'FIELDNAME'   'DATBI',
      ' ' 'COLTEXT'     TEXT-F11,
      'E' 'OUTPUTLEN'   '20'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form RESET_FIELD_CATALOG
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM RESET_FIELD_CATALOG TABLES PT_FCAT TYPE LVC_T_FCAT
                         USING  PV_FLAG
                                PV_FNAME
                                PV_VALUE.

  STATICS : LS_FCAT   TYPE LVC_S_FCAT,
            LV_COLPOS TYPE LVC_COLPOS,
            LV_TABIX  TYPE SYTABIX.

  IF PV_FLAG = ZGTSD_S.  "Start
    CLEAR LS_FCAT.
    READ TABLE PT_FCAT INTO LS_FCAT WITH KEY FIELDNAME = PV_VALUE BINARY SEARCH.
    CHECK SY-SUBRC = 0.
    LV_TABIX = SY-TABIX.

    LV_COLPOS = LV_COLPOS + 1.

    LS_FCAT-TECH    = SPACE.
    LS_FCAT-COL_POS = LV_COLPOS.
  ENDIF.

  CASE PV_FNAME.
    WHEN 'COLTEXT'.   "Text
      LS_FCAT-COLTEXT  = PV_VALUE.
      LS_FCAT-REPTEXT  = PV_VALUE.
      LS_FCAT-SELTEXT  = PV_VALUE.
      LS_FCAT-TOOLTIP  = PV_VALUE.
    WHEN OTHERS.
      ASSIGN COMPONENT PV_FNAME OF STRUCTURE LS_FCAT TO FIELD-SYMBOL(<LV_VALUE>).
      CHECK SY-SUBRC = 0.
      <LV_VALUE> = PV_VALUE.
  ENDCASE.

  IF PV_FLAG = ZGTSD_E.  "End
    MODIFY PT_FCAT FROM LS_FCAT INDEX LV_TABIX.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form EXCLUDE_TOOLBAR
*&---------------------------------------------------------------------*
*& text
*----------------------------------------------------------------------*
FORM EXCLUDE_TOOLBAR TABLES PT_EXCLUDE TYPE UI_FUNCTIONS.

  REFRESH PT_EXCLUDE.

  APPEND : CL_GUI_ALV_GRID=>MC_FC_LOC_UNDO            TO PT_EXCLUDE,
           CL_GUI_ALV_GRID=>MC_FC_DATA_SAVE           TO PT_EXCLUDE,
           CL_GUI_ALV_GRID=>MC_FC_LOC_COPY            TO PT_EXCLUDE,
           CL_GUI_ALV_GRID=>MC_FC_LOC_COPY_ROW        TO PT_EXCLUDE,
           CL_GUI_ALV_GRID=>MC_FC_LOC_CUT             TO PT_EXCLUDE,
           CL_GUI_ALV_GRID=>MC_FC_LOC_DELETE_ROW      TO PT_EXCLUDE,
           CL_GUI_ALV_GRID=>MC_FC_LOC_INSERT_ROW      TO PT_EXCLUDE,
           CL_GUI_ALV_GRID=>MC_FC_LOC_MOVE_ROW        TO PT_EXCLUDE,
           CL_GUI_ALV_GRID=>MC_FC_LOC_APPEND_ROW      TO PT_EXCLUDE,
           CL_GUI_ALV_GRID=>MC_FC_LOC_PASTE           TO PT_EXCLUDE,
           CL_GUI_ALV_GRID=>MC_FC_LOC_PASTE_NEW_ROW   TO PT_EXCLUDE,
           CL_GUI_ALV_GRID=>MC_FC_REFRESH             TO PT_EXCLUDE,
           CL_GUI_ALV_GRID=>MC_FC_CHECK               TO PT_EXCLUDE,
           CL_GUI_ALV_GRID=>MC_FC_PRINT               TO PT_EXCLUDE,
           CL_GUI_ALV_GRID=>MC_FC_VIEWS               TO PT_EXCLUDE,
           CL_GUI_ALV_GRID=>MC_FC_GRAPH               TO PT_EXCLUDE,
           CL_GUI_ALV_GRID=>MC_FC_INFO                TO PT_EXCLUDE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CREATE_EVENT_RECEIVER
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM CREATE_EVENT_RECEIVER USING PO_SENDER TYPE REF TO CL_GUI_ALV_GRID.

  "Create Event
  DATA(LO_EVENT) = NEW LCL_EVENT_RECEIVER( ).

  CASE PO_SENDER.
    WHEN GO_GRID.
      SET HANDLER : LO_EVENT->HANDLE_TOP_OF_PAGE FOR PO_SENDER.
  ENDCASE.

  SET HANDLER : LO_EVENT->HANDLE_HOTSPOT_CLICK         FOR PO_SENDER,
                LO_EVENT->HANDLE_DBL_CLICK             FOR PO_SENDER.
*                LO_EVENT->HANDLE_TOOLBAR               FOR PO_SENDER,
*                LO_EVENT->HANDLE_USER_COMMAND          FOR PO_SENDER,
*                LO_EVENT->HANDLE_ON_F4                 FOR PO_SENDER.
*               LO_EVENT->HANDLE_DATA_CHANGED          FOR PO_SENDER,
*               LO_EVENT->HANDLE_DATA_CHANGED_FINISHED FOR PO_SENDER.

*  "Data Changed Event
*  PO_SENDER->REGISTER_EDIT_EVENT( CL_GUI_ALV_GRID=>MC_EVT_MODIFIED ).
*  PO_SENDER->REGISTER_EDIT_EVENT( CL_GUI_ALV_GRID=>MC_EVT_ENTER ).

*  "Set Ready for Input
*  GO_GRID->SET_READY_FOR_INPUT( SWITCH #( GV_EDIT WHEN ZGTSD_X THEN 1 ELSE 0 ) ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form REGISTER_F4_FIELDS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM REGISTER_F4_FIELDS .

  DATA : LT_F4   TYPE LVC_T_F4,
         LT_FCAT TYPE TABLE OF LVC_S_FCAT
                 WITH NON-UNIQUE SORTED KEY KEY_MODE
                 COMPONENTS F4AVAILABL FIELDNAME.

  LT_FCAT = GT_FCAT.
  LOOP AT LT_FCAT INTO DATA(LS_FCAT) USING KEY KEY_MODE
                  WHERE F4AVAILABL = ZGTSD_X.
    LT_F4 = VALUE #( BASE LT_F4 ( FIELDNAME  = LS_FCAT-FIELDNAME
                                  REGISTER   = ZGTSD_X
                                  CHNGEAFTER = ZGTSD_X ) ).
  ENDLOOP.

  GO_GRID->REGISTER_F4_FOR_FIELDS( EXPORTING IT_F4 = LT_F4 ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_TOP_OF_PAGE_EVENT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM SET_TOP_OF_PAGE_EVENT .

  CHECK GO_DOCU IS BOUND.

  GO_DOCU->INITIALIZE_DOCUMENT( BACKGROUND_COLOR = CL_DD_AREA=>COL_TEXTAREA ).

  CALL METHOD GO_GRID->LIST_PROCESSING_EVENTS(
      I_EVENT_NAME = SLIS_EV_TOP_OF_PAGE
      I_DYNDOC_ID  = GO_DOCU ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_TABLE_FOR_FIRST_DISPLAY
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM SET_TABLE_FOR_FIRST_DISPLAY USING PO_SENDER TYPE REF TO CL_GUI_ALV_GRID
                                       PT_DATA TYPE TABLE.
  DATA : LV_HANDL TYPE SLIS_HANDL.

  "레이아웃 Variant 구분자
  PERFORM SET_VARIANT_HANDLE USING PO_SENDER CHANGING LV_HANDL.

  DELETE GT_FCAT WHERE TECH = ZGTSD_X. "불필요한 필드 제외

  "Formatted Output Table is Sent to Control
  CALL METHOD PO_SENDER->SET_TABLE_FOR_FIRST_DISPLAY
    EXPORTING
      IS_LAYOUT            = GS_LAYOUT
      IS_VARIANT           = VALUE #( REPORT = SY-REPID
                                      HANDLE = LV_HANDL )
      I_SAVE               = ZGTSD_A
      IT_TOOLBAR_EXCLUDING = GT_TOOLBAR
    CHANGING
      IT_FIELDCATALOG      = GT_FCAT
      IT_SORT              = GT_SORT[]
      IT_OUTTAB            = PT_DATA[].

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_VARIANT_HANDLE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM SET_VARIANT_HANDLE USING PO_SENDER TYPE REF TO CL_GUI_ALV_GRID
                         CHANGING PV_HANDL.

  CLEAR PV_HANDL.
  CASE PO_SENDER.
    WHEN GO_GRID. "Main
      PV_HANDL = 1.
    WHEN OTHERS.

  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form HANDLE_TOP_OF_PAGE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM HANDLE_TOP_OF_PAGE USING PO_DOCU TYPE REF TO CL_DD_DOCUMENT
                                  PO_SENDER.
  DATA : LV_TEXT TYPE SDYDO_TEXT_ELEMENT.

  CHECK PO_SENDER = GO_GRID "Main
    AND PO_DOCU IS BOUND.

  "Set Column Width
  PO_DOCU->ADD_TABLE( EXPORTING NO_OF_COLUMNS = 3 BORDER = '0' IMPORTING TABLE = DATA(LO_TABLE) ).

  LO_TABLE->ADD_COLUMN( EXPORTING WIDTH = '35%' IMPORTING COLUMN = DATA(LO_COL_KEY) ).
  LO_TABLE->ADD_COLUMN( EXPORTING WIDTH = '3%' IMPORTING COLUMN = DATA(LO_COL_SEP) ).
  LO_TABLE->ADD_COLUMN( EXPORTING WIDTH = '62%' IMPORTING COLUMN = DATA(LO_COL_VAL) ).
  LO_TABLE->NEW_ROW( ).

  "Set Column Style
  LO_TABLE->SET_COLUMN_STYLE( COL_NO = 1 SAP_EMPHASIS = CL_DD_DOCUMENT=>STRONG SAP_ALIGN = 'LEFT' ).
  LO_TABLE->SET_COLUMN_STYLE( COL_NO = 3 SAP_EMPHASIS = CL_DD_DOCUMENT=>MEDIUM SAP_ALIGN = 'LEFT' ).

  "Add Text
*  PERFORM ADD_TEXT_COMMON USING LO_COL_KEY LO_COL_SEP LO_COL_VAL LO_TABLE         "영업조직
*                                ZGTSD_P %_P_VKORG_%_APP_%-TEXT P_VKORG.


  "Display Document
  PO_DOCU->MERGE_DOCUMENT( ).
  PO_DOCU->DISPLAY_DOCUMENT( EXPORTING
                               REUSE_CONTROL      = ZGTSD_X
                               PARENT             = GO_CON_TOP
                             EXCEPTIONS
                               HTML_DISPLAY_ERROR = 1 ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form ADD_TEXT_COMMON
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM ADD_TEXT_COMMON USING PO_COL_KEY TYPE REF TO CL_DD_AREA
                               PO_COL_SEP TYPE REF TO CL_DD_AREA
                               PO_COL_VAL TYPE REF TO CL_DD_AREA
                               PO_TABLE   TYPE REF TO CL_DD_TABLE_ELEMENT
                               PV_FLAG
                               PV_KEY
                               PV_VALUE.
  FIELD-SYMBOLS : <LT_SELOPT> TYPE TABLE.
  DATA LV_TEXT TYPE CHAR255.

  CASE PV_FLAG.
    WHEN ZGTSD_P. "Parameter
      CHECK PV_VALUE IS NOT INITIAL.
      LV_TEXT = CONV SDYDO_TEXT_ELEMENT( PV_VALUE ).
    WHEN ZGTSD_S. "Select-Option
      ASSIGN (PV_VALUE) TO <LT_SELOPT>.
      CHECK SY-SUBRC = 0.

      CHECK LINES( <LT_SELOPT> ) => 1.

      ASSIGN COMPONENT 'LOW' OF STRUCTURE <LT_SELOPT>[ 1 ] TO FIELD-SYMBOL(<LV_LOW>).
      CHECK SY-SUBRC = 0.
      ASSIGN COMPONENT 'HIGH' OF STRUCTURE <LT_SELOPT>[ 1 ] TO FIELD-SYMBOL(<LV_HIGH>).
      CHECK SY-SUBRC = 0.

      IF <LV_HIGH> IS INITIAL.
        LV_TEXT = <LV_LOW>.
      ELSEIF <LV_LOW> IS INITIAL.
        LV_TEXT = `~ ` &&  <LV_LOW>.
      ELSE.
        LV_TEXT = <LV_LOW> && ` ~ ` &&  <LV_HIGH>.
      ENDIF.
  ENDCASE.

  PO_COL_KEY->ADD_TEXT( TEXT = CONV SDYDO_TEXT_ELEMENT( PV_KEY ) ).
  PO_COL_SEP->ADD_TEXT( TEXT = CONV SDYDO_TEXT_ELEMENT( ZGTSD_COLON ) ).
  PO_COL_VAL->ADD_TEXT( TEXT = LV_TEXT ).

  PO_TABLE->NEW_ROW( ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form HANDLE_HOTSPOT_CLICK
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM HANDLE_HOTSPOT_CLICK USING PS_COLUMN TYPE LVC_S_COL
                                PS_ROW_NO TYPE LVC_S_ROID
                                PO_SENDER.

  DATA : LT_MSG TYPE RS_T_MSG.

  CHECK PO_SENDER = GO_GRID. "Main

  CASE PS_COLUMN-FIELDNAME.

    WHEN 'STAT'.

      READ TABLE GT_S0100 INTO DATA(LS_MAIN) INDEX PS_ROW_NO-ROW_ID.
      CHECK SY-SUBRC = 0.
      CHECK LS_MAIN-MSGPOP[] IS NOT INITIAL.
      LT_MSG[] = LS_MAIN-MSGPOP[].

      CALL FUNCTION 'RSDC_SHOW_MESSAGES_POPUP'
        EXPORTING
          I_T_MSG           = LT_MSG
          I_TXT             = '업로드 에러 메세지'
          I_WITH_S_ON_EMPTY = RS_C_TRUE
          I_ONE_MSG_DIRECT  = ''
          I_ONE_MSG_TYPE_S  = RS_C_TRUE.

  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form HANDLE_DATA_CHANGED
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM HANDLE_DATA_CHANGED USING PO_DATA_CHANGED TYPE REF TO
                                 CL_ALV_CHANGED_DATA_PROTOCOL
                                 PO_SENDER.

  CHECK PO_SENDER = GO_GRID.  "Main

  DATA(LT_MOD_CELLS) = PO_DATA_CHANGED->MT_GOOD_CELLS.
  SORT LT_MOD_CELLS BY ROW_ID FIELDNAME.

  REFRESH GT_CHG.

  LOOP AT LT_MOD_CELLS INTO DATA(LS_MOD_TEMP).

    DATA(LS_MOD_CELLS) = LS_MOD_TEMP.

    AT NEW ROW_ID.
      READ TABLE GT_S0100 INTO DATA(LS_MAIN) INDEX LS_MOD_CELLS-ROW_ID.
      CHECK SY-SUBRC = 0.
    ENDAT.

    "체크사항 점검 및 Set Value
    PERFORM CHECK_VALUE_IN_DATACHD USING    PO_DATA_CHANGED
                                            LS_MOD_CELLS
                                   CHANGING LS_MAIN.

    AT END OF ROW_ID.
      "변경상태 Update
      PERFORM UPDATE_STATU USING    PO_DATA_CHANGED
                                    LS_MOD_CELLS
                           CHANGING LS_MAIN-STATU
                                    LS_MAIN-MODI.
      MODIFY GT_S0100 FROM LS_MAIN INDEX LS_MOD_CELLS-ROW_ID.
      APPEND CORRESPONDING #( LS_MAIN ) TO GT_CHG.
    ENDAT.

  ENDLOOP.

  "Display Protocol
  PO_DATA_CHANGED->DISPLAY_PROTOCOL( ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_VALUE_IN_DATACHD
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM CHECK_VALUE_IN_DATACHD USING PO_DATA_CHANGED TYPE REF TO
                                      CL_ALV_CHANGED_DATA_PROTOCOL
                                      PS_MOD_CELLS TYPE LVC_S_MODI
                            CHANGING PS_DATA STRUCTURE GS_S0100.

  CASE PS_MOD_CELLS-FIELDNAME.

    WHEN OTHERS.
      ASSIGN COMPONENT PS_MOD_CELLS-FIELDNAME OF STRUCTURE PS_DATA TO FIELD-SYMBOL(<LV_VALUE>).
      CHECK SY-SUBRC = 0.
      <LV_VALUE> = PS_MOD_CELLS-VALUE.
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_CHANGED_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM CHECK_CHANGED_DATA USING PO_GRID TYPE REF TO CL_GUI_ALV_GRID
                              PV_CK.

  CLEAR GV_ERROR.
  CHECK PO_GRID IS BOUND.

  PO_GRID->CHECK_CHANGED_DATA( IMPORTING E_VALID = DATA(LV_VALID) ).

  IF PV_CK = ZGTSD_X AND LV_VALID IS INITIAL.
    GV_ERROR = ZGTSD_X. "오류 Flag
    MESSAGE S029 DISPLAY LIKE ZGTSD_E. "오류 내역이 존재합니다.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form UPDATE_STATU
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM UPDATE_STATU USING PO_DATA_CHANGED TYPE REF TO
                            CL_ALV_CHANGED_DATA_PROTOCOL
                            PS_MOD_CELLS TYPE LVC_S_MODI
                   CHANGING PV_STATU
                            PV_MODI.

  PV_MODI  = ZGTSD_X.     "변경 Flag
  PV_STATU = ICON_CHANGE. "변경 Icon

  PERFORM MODIFY_CELL USING PO_DATA_CHANGED
                            PS_MOD_CELLS-ROW_ID
                            PS_MOD_CELLS-TABIX
                            'STATU'
                            PV_STATU.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_CELL_VALUE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM GET_CELL_VALUE USING PO_DATA_CHANGED TYPE REF TO
                              CL_ALV_CHANGED_DATA_PROTOCOL
                              PV_ROW_ID
                              PV_FIELDNAME
                     CHANGING PV_VALUE.

  CLEAR PV_VALUE.
  PO_DATA_CHANGED->GET_CELL_VALUE( EXPORTING
                                     I_ROW_ID    = PV_ROW_ID
                                     I_FIELDNAME = PV_FIELDNAME
                                   IMPORTING
                                     E_VALUE     = PV_VALUE ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form ADD_PROTOCOL_ENTRY
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM ADD_PROTOCOL_ENTRY USING PO_DATA_CHANGED TYPE REF TO
                                CL_ALV_CHANGED_DATA_PROTOCOL
                                PV_MSGID
                                PV_MSGNO
                                PV_MSGV1
                                PV_MSGV2
                                PV_FIELDNAME
                                PV_ROW_ID.

  DATA : LT_DATA TYPE TABLE OF LVC_S_MSG1
                 WITH NON-UNIQUE SORTED KEY KEY_MODE
                 COMPONENTS MSGID MSGNO MSGV1 MSGV2 FIELDNAME ROW_ID.

  LT_DATA = PO_DATA_CHANGED->MT_PROTOCOL.  "기존 동일 오류 제외

  CHECK NOT LINE_EXISTS( LT_DATA[ KEY KEY_MODE COMPONENTS MSGID     = PV_MSGID
                                                          MSGNO     = PV_MSGNO
                                                          MSGV1     = PV_MSGV1
                                                          MSGV2     = PV_MSGV2
                                                          FIELDNAME = PV_FIELDNAME
                                                          ROW_ID    = PV_ROW_ID ] ).

  PO_DATA_CHANGED->ADD_PROTOCOL_ENTRY(
      EXPORTING
        I_MSGID     = PV_MSGID
        I_MSGNO     = PV_MSGNO
        I_MSGTY     = ZGTSD_E
        I_MSGV1     = PV_MSGV1
        I_MSGV2     = PV_MSGV2
        I_FIELDNAME = PV_FIELDNAME
        I_ROW_ID    = PV_ROW_ID ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form MODIFY_CELL
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM MODIFY_CELL USING PO_DATA_CHANGED TYPE REF TO
                         CL_ALV_CHANGED_DATA_PROTOCOL
                         PV_ROW_ID
                         PV_TABIX
                         PV_FIELDNAME
                         PV_VALUE.

  PO_DATA_CHANGED->MODIFY_CELL( I_ROW_ID    = PV_ROW_ID
                                I_TABIX     = PV_TABIX
                                I_FIELDNAME = PV_FIELDNAME
                                I_VALUE     = PV_VALUE ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form HANDLE_DATA_CHANGED_FINISHED
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM HANDLE_DATA_CHANGED_FINISHED USING PV_MODIFIED
                                            PT_GOOD_CELLS TYPE LVC_T_MODI
                                            PO_SENDER.

  CHECK PV_MODIFIED = ZGTSD_X
    AND PO_SENDER   = GO_GRID
    AND GT_CHG IS NOT INITIAL.

*  변경사항 반영
  PERFORM UPDATE_EDIT_FIELDS USING GT_CHG.

  "Refresh Grid
  PERFORM REFRESH_TABLE_DISPLAY USING PO_SENDER SPACE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form UPDATE_EDIT_FIELDS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM UPDATE_EDIT_FIELDS USING PT_CHG TYPE TY_T_CHG.

*  "Set 수정 필드
*  DELETE ADJACENT DUPLICATES FROM PT_CHG USING KEY KEY_MODE COMPARING PSPID.
*
*  LOOP AT PT_CHG INTO DATA(LS_CHG).
*
*    DATA(LS_DATA) = VALUE #( GT_MAIN[ KEY KEY_STUFE
*                               COMPONENTS PSPID = LS_CHG-PSPID
*                                          STUFE = 1 ] OPTIONAL ).
*    CHECK LS_DATA-PSPID IS NOT INITIAL.
*
*    LOOP AT GT_MAIN ASSIGNING FIELD-SYMBOL(<LS_MAIN>) USING KEY KEY_MODE
*                     WHERE PSPID = LS_DATA-PSPID.
*      <LS_MAIN>-Z_IV_PUR       = LS_DATA-Z_IV_PUR.       "자산 매각
*      <LS_MAIN>-Z_IV_ANLKL     = LS_DATA-Z_IV_ANLKL.     "자산 클래스
*      <LS_MAIN>-Z_IV_ANLKL_TXT = LS_DATA-Z_IV_ANLKL_TXT. "자산 클래스 명
*      <LS_MAIN>-Z_KSTAR        = LS_DATA-Z_KSTAR.        "원가요소
*      <LS_MAIN>-Z_KSTAR_TXT    = LS_DATA-Z_KSTAR_TXT.    "원가요소 명
*    ENDLOOP.
*  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form HANDLE_TOOLBAR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM HANDLE_TOOLBAR USING PO_OBJECT TYPE REF TO CL_ALV_EVENT_TOOLBAR_SET
                              PO_SENDER.
  DEFINE _ADD_TOOLBAR.
    LS_TOOLBAR = VALUE #( FUNCTION   = &1
                          ICON       = &2
                          QUICKINFO  = &3
                          TEXT       = &4
                          BUTN_TYPE  = &5 ).

    CASE &6.
      WHEN ZGTSD_A. "Append
        APPEND LS_TOOLBAR TO PO_OBJECT->MT_TOOLBAR.
      WHEN ZGTSD_I. "Insert
        INSERT LS_TOOLBAR INTO PO_OBJECT->MT_TOOLBAR INDEX 1.
    ENDCASE.
  END-OF-DEFINITION.

  DATA : LS_TOOLBAR TYPE STB_BUTTON.

*  CHECK GV_EDIT = ZGTSD_X.     "수정가능 상태
*
*  CASE PO_SENDER.
*    WHEN GO_GRID. "Main
*      _ADD_TOOLBAR SPACE                SPACE            SPACE    SPACE    3 ZPS01_A.
*      _ADD_TOOLBAR ZPS01_UCOMM-AUC_SETL ICON_GENERATE    TEXT-009 TEXT-009 0 ZPS01_A. "AUC 정산규칙(F) 생성
*  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form REFRESH_TABLE_DISPLAY
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM REFRESH_TABLE_DISPLAY USING PO_GRID TYPE REF TO CL_GUI_ALV_GRID
                                  PV_SOFT_REFRESH.

  CHECK PO_GRID IS BOUND.

  CALL METHOD PO_GRID->REFRESH_TABLE_DISPLAY
    EXPORTING
      IS_STABLE      = CONV #( 'XX' )
      I_SOFT_REFRESH = PV_SOFT_REFRESH
    EXCEPTIONS
      FINISHED       = 1
      OTHERS         = 2.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form HANDLE_ON_F4
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM HANDLE_ON_F4 USING PV_FIELDNAME TYPE LVC_FNAME
                            PV_FIELDVALUE  TYPE LVC_VALUE
                            PS_ROW_NO      TYPE LVC_S_ROID
                            PO_EVENT_DATA  TYPE REF TO CL_ALV_EVENT_DATA
                            PV_DISPLAY     TYPE CHAR01
                            PO_SENDER.
  DATA : LV_VALUE TYPE LVC_VALUE.
  FIELD-SYMBOLS : <LT_DATA> TYPE TABLE.

*  CHECK PO_SENDER = GO_GRID. "Main
*
*  PO_EVENT_DATA->M_EVENT_HANDLED = ZPS01_X.
*
*  CASE PV_FIELDNAME.
*    WHEN ZPS01_FNAME-Z_IV_ANLKL.  "자산 클래스
*
*      PERFORM F4_CODE_MASTER USING    ZPS01_ROLLNAME-ZE_IV_ANLKL
*                                      ZPS01_CODE-PSAC02
*                                      PV_DISPLAY
*                             CHANGING LV_VALUE.
*
*    WHEN OTHERS.
*      RETURN.
*  ENDCASE.
*
*  CHECK LV_VALUE IS NOT INITIAL.
*
*  ASSIGN PO_EVENT_DATA->M_DATA->* TO <LT_DATA>.
*  CHECK SY-SUBRC = 0.
*
*  APPEND VALUE LVC_S_MODI( FIELDNAME = PV_FIELDNAME
*                           ROW_ID    = PS_ROW_NO-ROW_ID
*                           VALUE     = LV_VALUE ) TO <LT_DATA>.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form FREE_OBJECT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM FREE_OBJECT .
* Field Catalog
  CLEAR: GT_FCAT[].

* Grid Clear
  CALL METHOD: GO_GRID->FREE.

  CLEAR: GO_GRID.

* Container Clear
  CALL METHOD: GO_CON->FREE,
               GO_SPLIT->FREE,
               GO_CON_TOP->FREE.

  CLEAR: GO_CON, GO_SPLIT, GO_CON_TOP.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form HANDLE_DBL_CLICK
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> E_ROW
*&      --> E_COLUMN
*&      --> ES_ROW_NO
*&---------------------------------------------------------------------*
FORM HANDLE_DBL_CLICK  USING    PV_ROW     TYPE LVC_S_ROW
                                PV_COLUMN  TYPE LVC_S_COL.

  CHECK PV_ROW-ROWTYPE EQ SPACE.
  READ TABLE GT_S0100 INTO GS_S0100 INDEX PV_ROW-INDEX.
  CHECK SY-SUBRC = 0 .

  CASE PV_COLUMN.
    WHEN 'VBELN'.
*      CHECK GS_S0100-VBELN IS NOT INITIAL.
*      SET PARAMETER ID: 'AUN'    FIELD   GS_S0100-VBELN.
*      CALL TRANSACTION  'VA03' AND SKIP FIRST SCREEN.

*  	WHEN .
    WHEN OTHERS.
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_ALV_SORT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- GT_SORT
*&---------------------------------------------------------------------*
FORM SET_ALV_SORT  CHANGING PT_SORT TYPE LVC_T_SORT.

  CLEAR : PT_SORT[].

*  PERFORM SET_SORT_FIELD USING: PT_SORT 'VBELN' GC_X '' '',
*                                PT_SORT 'UDATE' GC_X '' '',
*                                PT_SORT 'UTIME' GC_X '' ''.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_SORT_FIELD
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PT_SORT
*&      --> P_
*&      --> GC_X
*&      --> P_
*&      --> P_
*&---------------------------------------------------------------------*
FORM SET_SORT_FIELD  USING PT_SORT TYPE LVC_T_SORT
                           PV_FLDNAME
                           PV_UP
                           PV_DOWN
                           PV_SUBTOT.

  APPEND VALUE #( SPOS      = LINES( PT_SORT ) + 1
                  FIELDNAME = PV_FLDNAME
                  UP        = PV_UP
                  DOWN      = PV_DOWN
                  SUBTOT    = PV_SUBTOT ) TO PT_SORT.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form EXCEL_DOWNLOAD
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM EXCEL_DOWNLOAD .

  DATA : LV_OBJ TYPE CHAR40.

  DATA : LV_DESTINATION TYPE RLGRAP-FILENAME,
         LV_FILENAME    TYPE STRING,
         LV_PATH        TYPE STRING,
         LV_FULLPATH    TYPE STRING,
         LS_KEY         TYPE WWWDATATAB,
         LV_EXTEN       TYPE STRING,
         LV_SUBRC       TYPE SY-SUBRC,
         LV_USER_ACTION TYPE I.

  CONSTANTS : LC_TITLE TYPE STRING VALUE 'Select File',
              LC_MI(2) TYPE C VALUE 'MI'.

  CASE ZGTSD_X.
    WHEN P_RB1.
      LV_OBJ = |ZGTSDR0030_A915|.
    WHEN P_RB2.
      LV_OBJ = |ZGTSDR0030_A515|.
    WHEN P_RB3.
      LV_OBJ = |ZGTSDR0030_A516|.
    WHEN P_RB4.
      LV_OBJ = |ZGTSDR0030_A506|.
    WHEN P_RB5.
      LV_OBJ = |ZGTSDR0030_A507|.
    WHEN P_RB6.
      LV_OBJ = |ZGTSDR0030_A514|.
  ENDCASE.

  TRY .
*-----------------------------------------------------------------------------*
**Pop-up for select file saving path
*-----------------------------------------------------------------------------*
      LV_EXTEN    = |xlsx|.
      LV_FILENAME = LV_OBJ.

      CALL METHOD CL_GUI_FRONTEND_SERVICES=>FILE_SAVE_DIALOG
        EXPORTING
          WINDOW_TITLE         = LC_TITLE
          DEFAULT_EXTENSION    = LV_EXTEN
          DEFAULT_FILE_NAME    = LV_FILENAME
*         INITIAL_DIRECTORY    = IV_INITIAL_DIRECTORY
          FILE_FILTER          = 'xlsx'
          PROMPT_ON_OVERWRITE  = ABAP_TRUE
        CHANGING
          FILENAME             = LV_FILENAME
          PATH                 = LV_PATH
          FULLPATH             = LV_FULLPATH
          USER_ACTION          = LV_USER_ACTION
        EXCEPTIONS
          CNTL_ERROR           = 1
          ERROR_NO_GUI         = 2
          NOT_SUPPORTED_BY_GUI = 3
          OTHERS               = 4.
      IF SY-SUBRC <> 0.
        LV_SUBRC  = SY-SUBRC.
        MESSAGE E162(ALVHT).
        EXIT.
      ENDIF.

      IF LV_USER_ACTION = CL_GUI_FRONTEND_SERVICES=>ACTION_CANCEL .
        MESSAGE S161(ALVHT) DISPLAY LIKE GC_E.
        EXIT.
      ENDIF.

*-- check file path
      IF LV_FULLPATH IS INITIAL.
        MESSAGE E000 WITH TEXT-E01. "Check the file name.
        EXIT.
      ENDIF.

*-----------------------------------------------------------------------------*
* DOWNLOAD OBJECT FILE
*-----------------------------------------------------------------------------
      CLEAR: LS_KEY.
      SELECT SINGLE * FROM WWWDATA INTO CORRESPONDING FIELDS OF LS_KEY WHERE OBJID = LV_OBJ.

*  CONCATENATE LC_MI IV_OBJID INTO LV_KEY.
      LS_KEY-RELID = LC_MI.
      LS_KEY-OBJID = LV_OBJ.
      LV_DESTINATION = LV_FULLPATH.

      DATA(LV_LEN) = STRLEN( LV_FULLPATH ).
      IF LV_LEN > 128.
        MESSAGE S001 WITH TEXT-E02 DISPLAY LIKE ZGTSD_E.
        EXIT.
      ENDIF.

      CALL FUNCTION 'DOWNLOAD_WEB_OBJECT'
        EXPORTING
          KEY         = LS_KEY
          DESTINATION = LV_DESTINATION
        IMPORTING
          RC          = LV_SUBRC
        EXCEPTIONS
          OTHERS      = 1.
      IF SY-SUBRC IS NOT INITIAL OR LV_SUBRC IS NOT INITIAL.
        MESSAGE E001 WITH TEXT-E02.
        EXIT.
      ENDIF.

*-----------------------------------------------------------------------------*
* EXCUTE SAVE DOCUMENT
*-----------------------------------------------------------------------------*
      CALL METHOD CL_GUI_FRONTEND_SERVICES=>EXECUTE
        EXPORTING
          DOCUMENT               = LV_FULLPATH
        EXCEPTIONS
          CNTL_ERROR             = 1
          ERROR_NO_GUI           = 2
          BAD_PARAMETER          = 3
          FILE_NOT_FOUND         = 4
          PATH_NOT_FOUND         = 5
          FILE_EXTENSION_UNKNOWN = 6
          ERROR_EXECUTE_FAILED   = 7
          SYNCHRONOUS_FAILED     = 8
          NOT_SUPPORTED_BY_GUI   = 9
          OTHERS                 = 10.
      IF SY-SUBRC IS NOT INITIAL.
        MESSAGE E162(ALVHT).
        EXIT.
      ENDIF.

    CATCH CX_ROOT INTO DATA(LO_ERR).
      MESSAGE S000 WITH LO_ERR->GET_LONGTEXT( ) DISPLAY LIKE ZGTSD_E.
  ENDTRY.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_EXCEL_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CHECK_EXCEL_DATA .

  DATA : LV_TABLE TYPE STRING.

  DATA(LT_FOR) = GT_S0100.
  CASE ZGTSD_X.
    WHEN P_RB1.
      SELECT A~MATNR, A~DATAB, A~DATBI, A~VKORG, A~VTWEG, A~SPART,
             A~KUNNR, A~KUNWE,
             B~KBETR, B~KONWA, B~KPEIN, B~KMEIN, B~LOEVM_KO
        FROM A915 AS A INNER JOIN KONP AS B
          ON A~KNUMH = B~KNUMH
         FOR ALL ENTRIES IN @LT_FOR
       WHERE A~KSCHL = 'PR00'
         AND A~VKORG = @P_VKORG
         AND A~VTWEG = @LT_FOR-VTWEG
         AND A~SPART = @LT_FOR-SPART
         AND A~KUNNR = @LT_FOR-KUNNR
         AND A~KUNWE = @LT_FOR-KUNWE
         AND A~MATNR = @LT_FOR-MATNR
        INTO TABLE @DATA(LT_A915).

    WHEN P_RB2.

      SELECT A~MATNR, A~DATAB, A~DATBI, A~VKORG, A~VTWEG, A~SPART,
             A~KUNNR,
             B~KBETR, B~KONWA, B~KPEIN, B~KMEIN, B~LOEVM_KO
        FROM A515 AS A INNER JOIN KONP AS B
          ON A~KNUMH = B~KNUMH
         FOR ALL ENTRIES IN @LT_FOR
       WHERE A~KSCHL = 'PR00'
         AND A~VKORG = @P_VKORG
         AND A~VTWEG = @LT_FOR-VTWEG
         AND A~SPART = @LT_FOR-SPART
         AND A~KUNNR = @LT_FOR-KUNNR
         AND A~MATNR = @LT_FOR-MATNR
        INTO TABLE @DATA(LT_A515).

    WHEN P_RB3.

      SELECT A~MATNR, A~DATAB, A~DATBI, A~VKORG, A~VTWEG, A~SPART,
             A~PLTYP,
             B~KBETR, B~KONWA, B~KPEIN, B~KMEIN, B~LOEVM_KO
        FROM A516 AS A INNER JOIN KONP AS B
          ON A~KNUMH = B~KNUMH
         FOR ALL ENTRIES IN @LT_FOR
       WHERE A~KSCHL = 'PR00'
         AND A~VKORG = @P_VKORG
         AND A~VTWEG = @LT_FOR-VTWEG
         AND A~SPART = @LT_FOR-SPART
         AND A~PLTYP = @LT_FOR-PLTYP
         AND A~MATNR = @LT_FOR-MATNR
        INTO TABLE @DATA(LT_A516).

    WHEN P_RB4.

      SELECT A~MATNR, A~DATAB, A~DATBI, A~VKORG, A~VTWEG, A~SPART,
             A~WAERK,
             B~KBETR, B~KONWA, B~KPEIN, B~KMEIN, B~LOEVM_KO
        FROM A506 AS A INNER JOIN KONP AS B
          ON A~KNUMH = B~KNUMH
         FOR ALL ENTRIES IN @LT_FOR
       WHERE A~KSCHL = 'PR00'
         AND A~VKORG = @P_VKORG
         AND A~VTWEG = @LT_FOR-VTWEG
         AND A~SPART = @LT_FOR-SPART
         AND A~WAERK = @LT_FOR-KONWA
         AND A~MATNR = @LT_FOR-MATNR
        INTO TABLE @DATA(LT_A506).

    WHEN P_RB5.

      SELECT A~MATNR, A~DATAB, A~DATBI, A~VKORG, A~VTWEG,
             A~WAERK,
             B~KBETR, B~KONWA, B~KPEIN, B~KMEIN, B~LOEVM_KO
        FROM A507 AS A INNER JOIN KONP AS B
          ON A~KNUMH = B~KNUMH
         FOR ALL ENTRIES IN @LT_FOR
       WHERE A~KSCHL = 'PR00'
         AND A~VKORG = @P_VKORG
         AND A~VTWEG = @LT_FOR-VTWEG
         AND A~WAERK = @LT_FOR-KONWA
         AND A~MATNR = @LT_FOR-MATNR
        INTO TABLE @DATA(LT_A507).

    WHEN P_RB6.
      SELECT A~MATNR, A~DATAB, A~DATBI, A~VKORG, A~VTWEG, A~SPART,
             A~KUNNR, A~VARCOND,
             B~KBETR, B~KONWA, B~KPEIN, B~KMEIN, B~LOEVM_KO
        FROM A514 AS A INNER JOIN KONP AS B
          ON A~KNUMH = B~KNUMH
         FOR ALL ENTRIES IN @LT_FOR
       WHERE A~KSCHL = 'PR00'
         AND A~VKORG = @P_VKORG
         AND A~VTWEG = @LT_FOR-VTWEG
         AND A~SPART = @LT_FOR-SPART
         AND A~KUNNR = @LT_FOR-KUNNR
         AND A~VARCOND = @LT_FOR-VARCOND
         AND A~MATNR = @LT_FOR-MATNR
        INTO TABLE @DATA(LT_A514).
  ENDCASE.

*         AND A~DATAB <= @P_ERDAT
*         AND A~DATBI >= @P_ERDAT

  LOOP AT GT_S0100 INTO GS_S0100.

    GS_S0100-STAT = ICON_LED_INACTIVE.

    IF GS_S0100-ERR_MSG IS NOT INITIAL.
      GS_S0100-STAT = ICON_LED_RED.
      PERFORM APPEND_MSG TABLES GS_S0100-MSGPOP
                          USING 'E'
                                '000'
                                GS_S0100-ERR_MSG.
    ENDIF.

    IF GS_S0100-VTWEG IS INITIAL.
      GS_S0100-STAT = ICON_LED_RED.
      PERFORM APPEND_MSG TABLES GS_S0100-MSGPOP
                          USING 'E'
                                '006'
                                TEXT-F01.
    ENDIF.

    IF P_RB5 IS INITIAL AND GS_S0100-SPART IS INITIAL.
      GS_S0100-STAT = ICON_LED_RED.
      PERFORM APPEND_MSG TABLES GS_S0100-MSGPOP
                          USING 'E'
                                '006'
                                TEXT-F02.
    ENDIF.


    CASE ZGTSD_X.

      WHEN P_RB1.
        IF GS_S0100-KUNNR IS INITIAL.
          GS_S0100-STAT = ICON_LED_RED.
          PERFORM APPEND_MSG TABLES GS_S0100-MSGPOP
                              USING 'E'
                                    '006'
                                    TEXT-F03.
        ENDIF.

        IF GS_S0100-KUNWE IS INITIAL.
          GS_S0100-STAT = ICON_LED_RED.
          PERFORM APPEND_MSG TABLES GS_S0100-MSGPOP
                              USING 'E'
                                    '006'
                                    TEXT-F04.
        ENDIF.

      WHEN P_RB2.
        IF GS_S0100-KUNNR IS INITIAL.
          GS_S0100-STAT = ICON_LED_RED.
          PERFORM APPEND_MSG TABLES GS_S0100-MSGPOP
                              USING 'E'
                                    '006'
                                    TEXT-F03.
        ENDIF.
      WHEN P_RB3.

        IF GS_S0100-PLTYP IS INITIAL.
          GS_S0100-STAT = ICON_LED_RED.
          PERFORM APPEND_MSG TABLES GS_S0100-MSGPOP
                              USING 'E'
                                    '006'
                                    TEXT-F12.
        ENDIF.
      WHEN P_RB4.
      WHEN P_RB5.
      WHEN P_RB6.

        IF GS_S0100-KUNNR IS INITIAL.
          GS_S0100-STAT = ICON_LED_RED.
          PERFORM APPEND_MSG TABLES GS_S0100-MSGPOP
                              USING 'E'
                                    '006'
                                    TEXT-F03.
        ENDIF.

        IF GS_S0100-VARCOND IS INITIAL.
          GS_S0100-STAT = ICON_LED_RED.
          PERFORM APPEND_MSG TABLES GS_S0100-MSGPOP
                              USING 'E'
                                    '006'
                                    TEXT-F15.
        ENDIF.

    ENDCASE.

    IF GS_S0100-MATNR IS INITIAL.
      GS_S0100-STAT = ICON_LED_RED.
      PERFORM APPEND_MSG TABLES GS_S0100-MSGPOP
                          USING 'E'
                                '006'
                                TEXT-F05.
    ENDIF.

    IF GS_S0100-KBETR IS NOT INITIAL.
*      GS_S0100-STAT = ICON_LED_RED.
*      PERFORM APPEND_MSG TABLES GS_S0100-MSGPOP
*                          USING 'E'
*                                '006'
*                                TEXT-F06.
*    ELSE.
      CASE GS_S0100-KONWA.
        WHEN 'KRW' OR 'JPY' OR 'VND'.
          GS_S0100-KBETR = GS_S0100-KBETR / 100.
        WHEN OTHERS.
      ENDCASE.
    ENDIF.

    IF GS_S0100-KONWA IS INITIAL.
      GS_S0100-STAT = ICON_LED_RED.
      PERFORM APPEND_MSG TABLES GS_S0100-MSGPOP
                          USING 'E'
                                '006'
                                TEXT-F07.
    ENDIF.

    IF GS_S0100-KPEIN IS INITIAL.
      GS_S0100-STAT = ICON_LED_RED.
      PERFORM APPEND_MSG TABLES GS_S0100-MSGPOP
                          USING 'E'
                                '006'
                                TEXT-F08.
    ENDIF.

    IF GS_S0100-KMEIN IS INITIAL.
      GS_S0100-STAT = ICON_LED_RED.
      PERFORM APPEND_MSG TABLES GS_S0100-MSGPOP
                          USING 'E'
                                '006'
                                TEXT-F09.
    ELSE.
      IF GS_S0100-KMEIN NE GS_S0100-MEINS.
        GS_S0100-STAT = ICON_LED_RED.
        PERFORM APPEND_MSG TABLES GS_S0100-MSGPOP
                            USING 'E'
                                  '000'
                                  '자재마스터 단위와 입력한 단위가 서로 다릅니다.'(E03).
      ENDIF.
    ENDIF.

    IF GS_S0100-DATAB IS INITIAL OR GS_S0100-DATAB = SPACE.
      GS_S0100-STAT = ICON_LED_RED.
      PERFORM APPEND_MSG TABLES GS_S0100-MSGPOP
                          USING 'E'
                                '006'
                                TEXT-F10.
    ENDIF.

    IF GS_S0100-DATBI IS INITIAL OR GS_S0100-DATBI = SPACE.
      GS_S0100-STAT = ICON_LED_RED.
      PERFORM APPEND_MSG TABLES GS_S0100-MSGPOP
                          USING 'E'
                                '006'
                                TEXT-F11.
    ENDIF.


    READ TABLE GS_S0100-MSGPOP INTO DATA(LS_POP) WITH KEY MSGTY = 'E'.
    IF SY-SUBRC = 0.
      GS_S0100-STAT = ICON_LED_RED.
    ENDIF.

    MODIFY GT_S0100 FROM GS_S0100.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form APPEND_MSG
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GS_S0100_MSGPOP
*&      --> P_
*&      --> TEXT_E05
*&---------------------------------------------------------------------*
FORM APPEND_MSG  TABLES   PT_MSG TYPE RS_T_MSG
                 USING    PV_TYPE
                          PV_MSGNO
                          PV_TEXT.

  DATA : LS_MSG TYPE RS_S_MSG.

  LS_MSG-MSGTY = PV_TYPE.
  LS_MSG-MSGID = 'ZGTSD01'.
  LS_MSG-MSGNO = PV_MSGNO.
  LS_MSG-MSGV1 =  PV_TEXT.
  APPEND LS_MSG TO PT_MSG.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SAVE_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SAVE_DATA .

  DATA : LV_AMTC  TYPE CHAR20,
         LV_KPEIN TYPE CHAR20.

  READ TABLE GT_S0100 TRANSPORTING NO FIELDS WITH KEY STAT = ICON_LED_INACTIVE.
  IF SY-SUBRC NE 0.
    MESSAGE S015 DISPLAY LIKE ZGTSD_E.EXIT.
  ENDIF.

  CLEAR GV_ANSWER.
  GV_ANSWER = ZGTSD_CL_COMMON=>POPUP_TO_COMFIRM( IV_UCOMM = SPACE
                                                 IV_MESSA = TEXT-M02 ).
  CHECK GV_ANSWER = ZGTSD_J.

  LOOP AT GT_S0100 INTO GS_S0100 WHERE STAT = ICON_LED_INACTIVE.

    __CLE : GT_BDCTAB, GT_MSG. CLEAR GS_PARAM.
    CLEAR LV_AMTC.
    DATA(LV_AMT) = CL_ABAP_DECFLOAT=>CONVERT_CURR_TO_DECFLOAT( EXPORTING AMOUNT_CURR = GS_S0100-KBETR
                                                                         CUKY        = GS_S0100-KONWA ).
    LV_AMTC = LV_AMT.
    CONDENSE LV_AMTC.

    PERFORM  DYNPRO  USING :
                'X'  'SAPMV13A'         '0100',
                ' '  'RV13A-KSCHL'      'PR00',
                ' '  'BDC_OKCODE'       '=ANTA'.

    PERFORM  DYNPRO  USING :
                  'X'  'SAPLV14A'         '0100'.

    CASE ZGTSD_X.

      WHEN P_RB1.
        PERFORM  DYNPRO  USING :
                      ' '  'RV130-SELKZ(01)'  SPACE,
                      ' '  'RV130-SELKZ(02)'  'X'.
      WHEN P_RB2.
        PERFORM  DYNPRO  USING :
                      ' '  'RV130-SELKZ(01)'  SPACE,
                      ' '  'RV130-SELKZ(03)'  'X'.
      WHEN P_RB3.
        PERFORM  DYNPRO  USING :
                      ' '  'RV130-SELKZ(01)'  SPACE,
                      ' '  'RV130-SELKZ(04)'  'X'.
      WHEN P_RB4.
        PERFORM  DYNPRO  USING :
                      ' '  'RV130-SELKZ(01)'  SPACE,
                      ' '  'RV130-SELKZ(06)'  'X'.
      WHEN P_RB5.
        PERFORM  DYNPRO  USING :
                      ' '  'RV130-SELKZ(01)'  SPACE,
                      ' '  'RV130-SELKZ(07)'  'X'.
      WHEN P_RB6.
        PERFORM  DYNPRO  USING :
                      ' '  'RV130-SELKZ(01)'  SPACE,
                      ' '  'RV130-SELKZ(01)'  'X'.

    ENDCASE.

    PERFORM  DYNPRO  USING :
                  ' '  'BDC_OKCODE'       '=WEIT'.

*    IF P_VK12 = 'X'.
*      PERFORM  DYNPRO  USING :
*                  'X'  'RV13A514'         '1000',
*                  ' '  'F001'             GS_S0100-VKORG,
*                  ' '  'F002'             GS_S0100-VTWEG,
*                  ' '  'F003'             GS_S0100-SPART,
*                  ' '  'F004'             GS_S0100-KUNNR,
*                  ' '  'F005'             GS_S0100-MATNR,
*                  ' '  'SEL_DATE'         GS_S0100-DATAB,
*                  ' '  'KODELFL'          'X',
*                  ' '  'BDC_OKCODE'       '=ONLI'.
*    ENDIF.

    CASE ZGTSD_X.
      WHEN P_RB1.
        PERFORM  DYNPRO  USING :
                    'X'  'SAPMV13A'        '1915'.
      WHEN P_RB2.
        PERFORM  DYNPRO  USING :
                    'X'  'SAPMV13A'        '1515'.
      WHEN P_RB3.
        PERFORM  DYNPRO  USING :
                    'X'  'SAPMV13A'        '1516'.
      WHEN P_RB4.
        PERFORM  DYNPRO  USING :
                    'X'  'SAPMV13A'        '1506'.
      WHEN P_RB5.
        PERFORM  DYNPRO  USING :
                    'X'  'SAPMV13A'        '1507'.
      WHEN P_RB6.
        PERFORM  DYNPRO  USING :
                    'X'  'SAPMV13A'        '1514'.
    ENDCASE.

    PERFORM  DYNPRO  USING :
                ' '  'KOMG-VKORG'      GS_S0100-VKORG,
                ' '  'KOMG-VTWEG'      GS_S0100-VTWEG.

    IF P_RB5 IS INITIAL.
      PERFORM  DYNPRO  USING :
                    ' '  'KOMG-SPART'   GS_S0100-SPART.
    ENDIF.

    CASE ZGTSD_X.
      WHEN P_RB1.
        PERFORM  DYNPRO  USING :
                      ' '  'KOMG-KUNNR'      GS_S0100-KUNNR,
                      ' '  'KOMG-KUNWE'      GS_S0100-KUNWE.
      WHEN P_RB2.
        PERFORM  DYNPRO  USING :
                      ' '  'KOMG-KUNNR'      GS_S0100-KUNNR.
      WHEN P_RB3.
        PERFORM  DYNPRO  USING :
                      ' '  'KOMG-PLTYP'      GS_S0100-PLTYP.
      WHEN P_RB4.
        PERFORM  DYNPRO  USING :
                      ' '  'KOMG-WAERK'      GS_S0100-KONWA.
      WHEN P_RB6.
        PERFORM  DYNPRO  USING :
                      ' '  'KOMG-KUNNR'      GS_S0100-KUNNR,
                      ' '  'KOMG-MATNR'      GS_S0100-MATNR,
                      ' '  'KOMG-VARCOND(01)'    GS_S0100-VARCOND.
    ENDCASE.

    LV_KPEIN = GS_S0100-KPEIN.
    CONDENSE LV_KPEIN.
*    DATA(lv_text) = |KOMG-MATNR(| && lv_cnt && |)|.
    IF P_RB6 IS INITIAL.
      PERFORM  DYNPRO  USING :
                  ' '  'KOMG-MATNR(01)'      GS_S0100-MATNR.
    ENDIF.
    PERFORM  DYNPRO  USING :
*                ' '  'KOMG-KBSTAT(01)'     'U',
                ' '  'KONP-KBETR(01)'      LV_AMTC,"GS_S0100-KBETR,
                ' '  'KONP-KONWA(01)'      GS_S0100-KONWA,
                ' '  'KONP-KPEIN(01)'      LV_KPEIN, "GS_S0100-KPEIN,
                ' '  'KONP-KMEIN(01)'      GS_S0100-KMEIN,
                ' '  'RV13A-DATAB(01)'     GS_S0100-DATAB,
                ' '  'RV13A-DATBI(01)'     GS_S0100-DATBI,
                ' '  'BDC_OKCODE'          '/00'.

    CASE ZGTSD_X.
      WHEN P_RB1.
        PERFORM  DYNPRO  USING :
                    'X'  'SAPMV13A'        '1915'.
      WHEN P_RB2.
        PERFORM  DYNPRO  USING :
                    'X'  'SAPMV13A'        '1515'.
      WHEN P_RB3.
        PERFORM  DYNPRO  USING :
                    'X'  'SAPMV13A'        '1516'.
      WHEN P_RB4.
        PERFORM  DYNPRO  USING :
                    'X'  'SAPMV13A'        '1506'.
      WHEN P_RB5.
        PERFORM  DYNPRO  USING :
                    'X'  'SAPMV13A'        '1507'.
      WHEN P_RB6.
        PERFORM  DYNPRO  USING :
                    'X'  'SAPMV13A'        '1514'.
    ENDCASE.
    PERFORM  DYNPRO  USING :
        ' '  'BDC_OKCODE'       '=SICH'.

    GS_PARAM-DISMODE  =  'N'.
    GS_PARAM-UPDMODE  =  'S'.
    GS_PARAM-RACOMMIT =  'X'.

*    IF P_VK11 = 'X'.
    DATA(LV_TCODE) = 'VK11'.
*    ELSE.
*      LV_TCODE = 'VK12'.
*    ENDIF.
    CALL TRANSACTION LV_TCODE USING GT_BDCTAB
                            OPTIONS FROM GS_PARAM
                            MESSAGES INTO GT_MSG.

    READ TABLE GT_MSG INTO DATA(LS_MSG) WITH KEY MSGTYP = 'E'.
    IF SY-SUBRC = 0.
      GS_S0100-STAT = ICON_LED_RED.
      PERFORM APPEND_MSG TABLES GS_S0100-MSGPOP
                          USING 'E'
                                '001'
                                LS_MSG-MSGV1.
    ELSE.
      GS_S0100-STAT = ICON_LED_GREEN.
    ENDIF.

    MODIFY GT_S0100 FROM GS_S0100.
  ENDLOOP.

  MESSAGE S011.
  "Refresh Grid
  PERFORM REFRESH_TABLE_DISPLAY USING GO_GRID SPACE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form DYNPRO
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> P_
*&      --> P_
*&---------------------------------------------------------------------*
FORM DYNPRO  USING PV_DYNBEGIN
                   PV_FNAM
                   PV_FVAL.

  CLEAR GT_BDCTAB.

  IF  PV_DYNBEGIN  =  'X'.

    GT_BDCTAB-DYNBEGIN  =  'X'.
    GT_BDCTAB-PROGRAM   =  PV_FNAM.
    GT_BDCTAB-DYNPRO    =  PV_FVAL.
    APPEND GT_BDCTAB.

  ELSE.

    GT_BDCTAB-FNAM      =  PV_FNAM.
    GT_BDCTAB-FVAL      =  PV_FVAL.
    APPEND GT_BDCTAB.

  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form DATA_UPLOAD
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM DATA_UPLOAD .

  __CLE : GT_S0100, GT_A915, GT_A515, GT_A516, GT_A506, GT_A507, GT_A514,
          GT_JOIN.

  "Read Excel File
  CASE ZGTSD_X.
    WHEN P_RB1.

      ZGTSD_CL_COMMON=>EXCEL_UPLOAD( EXPORTING IV_FILENAME  = P_FNAME
                                               IV_UPPERCASE = SPACE
                                     IMPORTING ET_TABLE     = GT_A915 ).
      GT_JOIN[] = CORRESPONDING #( GT_A915 ).
    WHEN P_RB2.

      ZGTSD_CL_COMMON=>EXCEL_UPLOAD( EXPORTING IV_FILENAME  = P_FNAME
                                               IV_UPPERCASE = SPACE
                                     IMPORTING ET_TABLE     = GT_A515 ).
      GT_JOIN[] = CORRESPONDING #( GT_A515 ).
    WHEN P_RB3.

      ZGTSD_CL_COMMON=>EXCEL_UPLOAD( EXPORTING IV_FILENAME  = P_FNAME
                                               IV_UPPERCASE = SPACE
                                     IMPORTING ET_TABLE     = GT_A516 ).
      GT_JOIN[] = CORRESPONDING #( GT_A516 ).
    WHEN P_RB4.

      ZGTSD_CL_COMMON=>EXCEL_UPLOAD( EXPORTING IV_FILENAME  = P_FNAME
                                               IV_UPPERCASE = SPACE
                                     IMPORTING ET_TABLE     = GT_A506 ).
      GT_JOIN[] = CORRESPONDING #( GT_A506 ).
    WHEN P_RB5.

      ZGTSD_CL_COMMON=>EXCEL_UPLOAD( EXPORTING IV_FILENAME  = P_FNAME
                                               IV_UPPERCASE = SPACE
                                     IMPORTING ET_TABLE     = GT_A507 ).
      GT_JOIN[] = CORRESPONDING #( GT_A507 ).
    WHEN P_RB6.

      ZGTSD_CL_COMMON=>EXCEL_UPLOAD( EXPORTING IV_FILENAME  = P_FNAME
                                               IV_UPPERCASE = SPACE
                                     IMPORTING ET_TABLE     = GT_A514 ).
      GT_JOIN[] = CORRESPONDING #( GT_A514 ).
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form WEB_DATA_UPLOAD
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM WEB_DATA_UPLOAD .


  __CLE : GT_S0100, GT_A915, GT_A515, GT_A516, GT_A506, GT_A507, GT_A514,
          GT_JOIN.

  "Read Excel File
  CASE ZGTSD_X.
    WHEN P_RB1.

      ZGTSD_CL_COMMON=>EXCEL_WEB_UPLOAD( EXPORTING IV_FILENAME  = P_FNAME
                                                   IV_UPPERCASE = SPACE
                                         IMPORTING ET_TABLE     = GT_A915 ).
      GT_JOIN[] = CORRESPONDING #( GT_A915 ).
    WHEN P_RB2.

      ZGTSD_CL_COMMON=>EXCEL_WEB_UPLOAD( EXPORTING IV_FILENAME  = P_FNAME
                                                   IV_UPPERCASE = SPACE
                                          IMPORTING ET_TABLE     = GT_A515 ).
      GT_JOIN[] = CORRESPONDING #( GT_A515 ).
    WHEN P_RB3.

      ZGTSD_CL_COMMON=>EXCEL_WEB_UPLOAD( EXPORTING IV_FILENAME  = P_FNAME
                                                   IV_UPPERCASE = SPACE
                                         IMPORTING ET_TABLE     = GT_A516 ).
      GT_JOIN[] = CORRESPONDING #( GT_A516 ).
    WHEN P_RB4.

      ZGTSD_CL_COMMON=>EXCEL_WEB_UPLOAD( EXPORTING IV_FILENAME  = P_FNAME
                                                   IV_UPPERCASE = SPACE
                                         IMPORTING ET_TABLE     = GT_A506 ).
      GT_JOIN[] = CORRESPONDING #( GT_A506 ).
    WHEN P_RB5.

      ZGTSD_CL_COMMON=>EXCEL_WEB_UPLOAD( EXPORTING IV_FILENAME  = P_FNAME
                                                   IV_UPPERCASE = SPACE
                                         IMPORTING ET_TABLE     = GT_A507 ).
      GT_JOIN[] = CORRESPONDING #( GT_A507 ).
    WHEN P_RB6.

      ZGTSD_CL_COMMON=>EXCEL_WEB_UPLOAD( EXPORTING IV_FILENAME  = P_FNAME
                                                   IV_UPPERCASE = SPACE
                                         IMPORTING ET_TABLE     = GT_A514 ).
      GT_JOIN[] = CORRESPONDING #( GT_A514 ).
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form MAKE_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM MAKE_DATA .

**********************************************************************
  LOOP AT GT_JOIN INTO DATA(LS_JOIN).

    CALL FUNCTION 'CONVERSION_EXIT_MATN1_INPUT'
      EXPORTING
        INPUT       = LS_JOIN-MATNR
      IMPORTING
        OUTPUT      = LS_JOIN-MATNR
      EXCEPTIONS
        LENTH_ERROR = 1
        OTHERS      = 2.

    IF LS_JOIN-KUNNR  IS NOT INITIAL.
      __ALPHA_IN LS_JOIN-KUNNR LS_JOIN-KUNNR.
    ENDIF.

    IF LS_JOIN-KUNWE  IS NOT INITIAL.
      __ALPHA_IN LS_JOIN-KUNWE LS_JOIN-KUNWE.
    ENDIF.

    LS_JOIN-VKORG = P_VKORG.
    MODIFY GT_JOIN FROM LS_JOIN.
  ENDLOOP.

  SELECT A~VKORG, A~VTWEG, A~SPART, A~PLTYP, A~ERR_MSG,
         A~KUNNR, KUNWE, A~MATNR, A~KBETR, VARCOND,
         KONWA, KPEIN, KMEIN, A~DATAB, A~DATBI, B~MAKTX,
         D~VTEXT AS VTWEG_NM, F~VTEXT AS SPART_NM,
         C~VTEXT AS VKORG_NM, E~NAME1, G~NAME1 AS KUNWE_NM, MAT~MEINS
    FROM @GT_JOIN AS A INNER JOIN MARA AS MAT
      ON A~MATNR = MAT~MATNR
    LEFT OUTER JOIN MAKT AS B
      ON B~MATNR = A~MATNR
     AND B~SPRAS = @SY-LANGU
    LEFT OUTER JOIN TVKOT AS C
      ON A~VKORG = C~VKORG
     AND C~SPRAS = @SY-LANGU
    LEFT OUTER JOIN TVTWT AS D
      ON A~VTWEG = D~VTWEG
     AND D~SPRAS = @SY-LANGU
    LEFT OUTER JOIN TSPAT AS F
      ON A~SPART = F~SPART
     AND F~SPRAS = @SY-LANGU
    LEFT OUTER JOIN KNA1 AS E
      ON E~KUNNR = A~KUNNR
    LEFT OUTER JOIN KNA1 AS G
      ON G~KUNNR = A~KUNWE
    INTO CORRESPONDING FIELDS OF TABLE @GT_S0100.

**********************************************************************
  PERFORM CHECK_EXCEL_DATA.
**********************************************************************

  "데이타 건수 메시지 출력
  IF GT_S0100 IS NOT INITIAL.
    MESSAGE S009 WITH |{ LINES( GT_S0100 ) NUMBER = USER }|. "& 건 검색되었습니다.
  ELSE.
    MESSAGE S010.                                           "조회할 데이타가 없습니다.
    GV_ERROR = GC_X.                                        "데이타 없으면 출력 X
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_FLD_EXCEL_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> <LFV_XLS>
*&      <-- <LFV_ITAB>
*&---------------------------------------------------------------------*
FORM CHECK_FLD_EXCEL_DATA  USING    PV_VAL
                           CHANGING PV_NVAL.

  DATA : LV_CONV TYPE CHAR1024.
  CONSTANTS : LC_QUOTA TYPE CHAR1 VALUE '"'.

  LV_CONV = PV_VAL.
  DESCRIBE FIELD PV_NVAL TYPE DATA(LV_TYPE).
  CASE LV_TYPE.
    WHEN ZGTSD_D. " DATE.
      ZGTSD_CL_COMMON=>CONV_DATE_INPUT( CHANGING CV_INPUT = LV_CONV ).
      PV_NVAL = LV_CONV.

    WHEN ZGTSD_T. " TIME
      ZGTSD_CL_COMMON=>CONV_TIME_INPUT( CHANGING CV_INPUT = LV_CONV ).
      PV_NVAL = LV_CONV.

    WHEN ZGTSD_I  OR ZGTSD_P OR ZGTSD_N OR
         'b' OR 's'. " 숫자인 경우..
      ZGTSD_CL_COMMON=>CONV_CURR_INPUT( CHANGING   CV_INPUT    = LV_CONV
                                      EXCEPTIONS NOT_NUMERIC = 1 ).
      IF SY-SUBRC EQ 0.
        PV_NVAL = LV_CONV.
      ENDIF.

    WHEN ZGTSD_X. "RAW
      PV_NVAL = LV_CONV.

    WHEN 'g'.
      IF LV_CONV IS INITIAL.
        CLEAR PV_NVAL.

      ELSE.
        IF PV_NVAL IS INITIAL.
          IF LV_CONV(1) EQ LC_QUOTA. "'"'.
            LV_CONV(1) = SPACE.
          ENDIF.
          DATA(LV_LEN) = STRLEN( LV_CONV ).
          LV_LEN = LV_LEN - 1.
          IF LV_CONV+LV_LEN(1) EQ LC_QUOTA.
            LV_CONV+LV_LEN(1) = SPACE.
          ENDIF.
          CONDENSE LV_CONV.
          PV_NVAL = LV_CONV.
        ENDIF.
      ENDIF.

    WHEN OTHERS.
      IF PV_VAL IS INITIAL.
        CLEAR PV_NVAL.

      ELSE.
        IF PV_NVAL IS INITIAL.
          SHIFT LV_CONV LEFT DELETING LEADING SPACE.
          WRITE LV_CONV TO PV_NVAL LEFT-JUSTIFIED.
        ENDIF.
      ENDIF.
  ENDCASE.

ENDFORM.
