*&---------------------------------------------------------------------*
*& Include          ZGTSDI0001F01
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

  DATA : LV_SDT TYPE SY-DATLO,
         LV_EDT TYPE SY-DATLO.
  CONCATENATE SY-DATLO(6) '01' INTO LV_SDT.
*  S_ERDAT-LOW = LV_SDT.
  S_ERDAT-HIGH = SY-DATLO.
  __RNG S_ERDAT 'I' 'EQ' S_ERDAT-LOW S_ERDAT-HIGH.
  S_WADAT[] = S_ERDAT[].
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
    CASE SCREEN-NAME.
      WHEN 'S_TARG-LOW'.
        SCREEN-REQUIRED = 2.
      WHEN OTHERS.
    ENDCASE.

*    CASE SCREEN-GROUP1.
*
*      WHEN 'M1'.
*        IF RB_DISP = GC_X.
*          SCREEN-ACTIVE = 0.
*        ENDIF.
*      WHEN 'M2'.
*        IF RB_SEND = GC_X.
*          SCREEN-ACTIVE = 0.
*        ENDIF.
*    ENDCASE.

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

  "기본 필수입력 필드 체크
*  IF S_KUNNR[] IS INITIAL. "
*    MESSAGE S055(00) DISPLAY LIKE ZGTSD_E.
*    GV_ERROR = ZGTSD_X.
*    RETURN.
*  ENDIF.

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

  DATA : LT_RESULT TYPE TABLE OF MB5SIT WITH DEFAULT KEY WITH HEADER LINE,
         LT_DELI   TYPE TABLE OF SHP_VBELN_RANGE WITH HEADER LINE,
         LT_JOIN   LIKE TABLE OF GS_S0100 WITH EMPTY KEY.

  RANGES : LR_SOBKZ FOR LIPS-SOBKZ,
           LR_EBELN FOR LIPS-EBELN,
           LR_EBELP FOR LIPS-EBELP,
           LR_LIFNR FOR LIKP-LIFNR,
           LR_DELI FOR LIKP-VBELN.

  WITH +VF AS ( SELECT VGBEL, VGPOS, SUM( A~FKIMG ) AS FKIMG,
                       SUM( A~NETWR ) AS NETWR
                  FROM VBRP AS A INNER JOIN VBRK AS B
                    ON A~VBELN = B~VBELN
                 WHERE B~FKSTO = ''
                   AND B~SFAKN = ''
                 GROUP BY VGBEL, VGPOS )
  SELECT A~SPART, A~VTWEG, A~VKBUR, A~VKGRP, A~WAERK, A~VBELN,
         B~POSNR, B~MATNR, B~VRKME, C~VBELN AS VBEVL,
         C~POSNR AS POSVL, C~WERKS, C~CHARG,
         D~KUNAG, H~NAME1 AS KUNAG_NM,
         E~J_1BBRANCH AS BRANCH, F~KDKG4,
         G~MAKTX, VF~FKIMG, VF~NETWR, D~WADAT_IST
    FROM VBAK AS A INNER JOIN VBAP AS B
      ON A~VBELN = B~VBELN
   INNER JOIN LIPS AS C
      ON B~VBELN = C~VGBEL
     AND B~POSNR = C~VGPOS
   INNER JOIN LIKP AS D
      ON C~VBELN = D~VBELN
   INNER JOIN T001W AS E
      ON C~WERKS = E~WERKS
   INNER JOIN VBKD AS F
      ON A~VBELN = F~VBELN
     AND F~POSNR = 0
   INNER JOIN KNA1 AS H
      ON D~KUNAG = H~KUNNR
    LEFT OUTER JOIN +VF AS VF
      ON VF~VGBEL = C~VBELN
     AND VF~VGPOS = C~POSNR
    LEFT OUTER JOIN MAKT AS G
      ON B~MATNR = G~MATNR
     AND G~SPRAS = @SY-LANGU
   WHERE A~VKORG  = @P_VKORG
     AND A~VTWEG IN @S_VTWEG
     AND A~SPART IN @S_SPART
     AND A~VKBUR IN @S_VKBUR
     AND A~VKGRP IN @S_VKGRP
     AND A~AUART NE 'B3'
     AND C~VBELN IN @S_VBEVL
     AND C~FKREL IN ('K', 'A', 'H')
     AND A~KUNNR IN @S_KUNNR
     AND C~BWART = '687'
     AND D~ERDAT IN @S_ERDAT
     AND D~WADAT_IST IN @S_WADAT
     AND C~PDSTA IN ('A', 'B', 'C')
     AND C~FKSTA NE 'C'
     AND C~GBSTA NE 'C'
     AND C~BWART = '687'
     AND C~WBSTA IN ('C', 'B')
     AND C~PODREL IN ('A', 'B')
     AND C~KZPOD IN ('A', 'B', 'X')
     AND E~J_1BBRANCH IN @S_BRANCH
     AND F~KDKG4 IN @S_KDKG4
    INTO CORRESPONDING FIELDS OF TABLE @GT_S0100.

  LT_JOIN[] = GT_S0100[].
  SORT LT_JOIN BY VBELN POSNR.
  DELETE ADJACENT DUPLICATES FROM LT_JOIN COMPARING VBELN POSNR.
  IF LT_JOIN[] IS NOT INITIAL.
*    SELECT B~VBELN, B~CHARG, B~VGBEL, B~VGPOS,
*           SUM( B~LFIMG ) AS LFIMG,
*           CASE WHEN B~UECHA IS INITIAL THEN B~POSNR
*                ELSE B~UECHA END AS POSNR
*      FROM @LT_JOIN AS A INNER JOIN LIPS AS B
*        ON A~VBELN = B~VGBEL
*       AND A~POSNR = B~VGPOS
*       AND B~LFIMG > 0
*     GROUP BY B~VBELN, B~POSNR, B~CHARG,  B~VGBEL, B~VGPOS
*    INTO TABLE @DATA(LT_VL_QTY).

    SELECT B~VBELN, B~UECHA, SUM( B~LFIMG ) AS LFIMG, "B~POSNR,
           B~VGBEL, B~VGPOS
      FROM @LT_JOIN AS A INNER JOIN LIPS AS B
        ON A~VBELN = B~VGBEL
       AND A~POSNR = B~VGPOS
     WHERE B~LFIMG > 0
     GROUP BY B~VBELN, B~UECHA, B~VGBEL, B~VGPOS
    INTO TABLE @DATA(LT_VL_QTY).

    SELECT B~VBELN, B~UECHA, B~POSNR, B~CHARG, B~VGBEL, B~VGPOS
      FROM @LT_JOIN AS A INNER JOIN LIPS AS B
        ON A~VBELN = B~VGBEL
       AND A~POSNR = B~VGPOS
     WHERE B~LFIMG > 0
    INTO TABLE @DATA(LT_CHARG).
  ENDIF.

*영업사원
  DATA(LT_FOR) = GT_S0100[].
  SORT LT_FOR BY VBELN.
  DELETE ADJACENT DUPLICATES FROM LT_FOR COMPARING VBELN.
  IF LT_FOR[] IS NOT INITIAL.
    SELECT A~VBELN, A~KUNNR, PARVW, B~NAME1
      FROM VBPA AS A INNER JOIN KNA1 AS B
        ON B~KUNNR = A~LIFNR
       FOR ALL ENTRIES IN @LT_FOR
     WHERE A~VBELN = @LT_FOR-VBELN
       AND A~POSNR = '0'
       AND A~PARVW  IN ('VE')
       AND A~LIFNR IN @S_LIFNR
        OR B~NAME1 IN @S_LIFNR
      INTO TABLE @DATA(LT_KNA1).
  ENDIF.

  LT_FOR[] = GT_S0100[].
  SORT LT_FOR BY VBEVL.
  DELETE ADJACENT DUPLICATES FROM LT_FOR COMPARING VBEVL.
  IF LT_FOR[] IS NOT INITIAL.
    SELECT VBELV, B~BUDAT_MKPF INTO TABLE @DATA(LT_BUDAT)
      FROM VBFA AS A INNER JOIN MSEG AS B
        ON A~VBELN = B~MBLNR
       FOR ALL ENTRIES IN @LT_FOR
     WHERE VBELV   = @LT_FOR-VBEVL
       AND A~BWART = '687'.
  ENDIF.

  LT_FOR[] = GT_S0100[].
  SORT LT_FOR BY VBEVL POSVL MATNR.
  DELETE ADJACENT DUPLICATES FROM LT_FOR COMPARING  VBEVL POSVL MATNR.
  IF LT_FOR[] IS NOT INITIAL.
    SELECT ZGTSDT1070~* INTO TABLE @DATA(LT_1070)
      FROM ZGTSDT1070
       FOR ALL ENTRIES IN @LT_FOR
     WHERE VBELN = @LT_FOR-VBEVL
       AND POSNR = @LT_FOR-POSVL
       AND MATNR = @LT_FOR-MATNR
       AND ZCKEY = ( SELECT MAX( ZCKEY )
                       FROM ZGTSDT1070
                      WHERE VBELN = @LT_FOR-VBEVL
                        AND POSNR = @LT_FOR-POSVL
                        AND MATNR = @LT_FOR-MATNR ).
  ENDIF.

*이전오더
  LT_JOIN[] = GT_S0100[].
  SORT LT_JOIN BY VBELN POSNR.
  DELETE ADJACENT DUPLICATES FROM LT_JOIN COMPARING VBELN POSNR.
  IF LT_JOIN[] IS NOT INITIAL.
    WITH +LIPS AS ( SELECT DISTINCT B~VBELN, POSNR, VGBEL, VGPOS, WADAT_IST
                      FROM LIPS AS A INNER JOIN LIKP AS B
                        ON A~VBELN = B~VBELN )
    SELECT B~VBELN_N, B~POSNR_N, B~VBELN_O, B~POSNR_O,
           C~VBELN AS VBEVL_O, C~POSNR AS POSVL_O,
           C~WADAT_IST AS WADAT_IST_O
      FROM @LT_JOIN AS A INNER JOIN ZGTSDT9062 AS B
        ON A~VBELN = B~VBELN_N
       AND A~POSNR = B~POSNR_N
      LEFT OUTER JOIN +LIPS AS C
        ON B~VBELN_O = C~VGBEL
       AND B~POSNR_O = C~VGPOS
      INTO TABLE @DATA(LT_ORI).
  ENDIF.


  SORT LT_VL_QTY BY VGBEL VGPOS.
  SORT LT_CHARG  BY VGBEL VGPOS.
  SORT LT_ORI    BY VBELN_N POSNR_N.
  SORT LT_KNA1   BY VBELN.
  SORT LT_BUDAT  BY VBELV.
  SORT LT_1070   BY VBELN POSNR MATNR.

  LOOP AT GT_S0100 INTO GS_S0100.

    IF S_LIFNR[] IS NOT INITIAL.
      READ TABLE LT_KNA1 INTO DATA(LS_KNA) WITH KEY VBELN = GS_S0100-VBELN BINARY SEARCH.
      IF SY-SUBRC = 0 AND ( LS_KNA-NAME1 IN S_LIFNR OR LS_KNA-KUNNR IN S_LIFNR ).
      ELSE.
        DELETE GT_S0100 . CONTINUE.
      ENDIF.
    ENDIF.

    IF GS_S0100-LFIMG = 0.
      READ TABLE LT_VL_QTY INTO DATA(LS_VL)
                           WITH KEY VGBEL = GS_S0100-VBELN
                                    VGPOS = GS_S0100-POSNR
                                    BINARY SEARCH.
      IF SY-SUBRC = 0.
        GS_S0100-LFIMG = LS_VL-LFIMG.
      ENDIF.

      READ TABLE LT_CHARG  INTO DATA(LS_CHARG)
                           WITH KEY VGBEL = GS_S0100-VBELN
                                    VGPOS = GS_S0100-POSNR
                                    BINARY SEARCH.
      IF SY-SUBRC = 0.
        GS_S0100-CHARG = LS_CHARG-CHARG.
        GS_S0100-POSNN = LS_CHARG-POSNR.
      ENDIF.

    ENDIF.

    __CLE : LT_RESULT, LT_DELI, LR_SOBKZ, LR_EBELN, LR_EBELP, LR_LIFNR.
    __RNG : LT_DELI 'I' 'EQ' GS_S0100-VBEVL ''.
    TRY.
        CALL FUNCTION 'MB_SELECT_STOCK_IN_TRANSIT'
          EXPORTING
            I_WI_GM               = 'X'
            I_CONDENSE            = SPACE
          TABLES
            T_RESULT              = LT_RESULT
            T_RA_SOBKZ            = LR_SOBKZ
            T_RA_EBELN            = LR_EBELN
            T_RA_EBELP            = LR_EBELP
            T_RA_LIFNR            = LR_LIFNR
            T_RA_DEL_OUT          = LT_DELI[] "delivery outbound
          EXCEPTIONS
            PARAMETER_ERROR       = 1
            MISSING_AUTHORIZATION = 2
            OTHERS                = 3.
      CATCH CX_ROOT INTO DATA(LO_ERR).
    ENDTRY.

    SELECT SINGLE B~* INTO @DATA(LS_PDO_KONV)
      FROM VBAK AS A INNER JOIN KONV AS B
        ON A~KNUMV = B~KNUMV
     WHERE A~VBELN = @GS_S0100-VBELN
       AND B~KPOSN = @GS_S0100-POSNR
       AND KSCHL = 'ZPR0'.
    IF SY-SUBRC = 0.
      GS_S0100-KBETR = LS_PDO_KONV-KBETR.
    ENDIF.
    CLEAR LS_PDO_KONV.

    READ TABLE LT_CHARG INTO LS_CHARG WITH KEY VBELN = GS_S0100-VBEVL
                                               UECHA = GS_S0100-POSVL.
    IF SY-SUBRC = 0.
      LOOP AT LT_CHARG INTO LS_CHARG WHERE VBELN = GS_S0100-VBEVL
                                       AND UECHA = GS_S0100-POSVL.

        READ TABLE LT_RESULT WITH KEY POSNR = LS_CHARG-POSNR.
        IF LT_RESULT-SIT_GI IS NOT INITIAL.
          GS_S0100-SIT_GI   = GS_S0100-SIT_GI + LT_RESULT-SIT_GI.
          GS_S0100-SIT_FREE = GS_S0100-SIT_FREE + LT_RESULT-SIT_FREE.
        ENDIF.

      ENDLOOP.
    ELSE.
      READ TABLE LT_RESULT WITH KEY POSNR = GS_S0100-POSNN.
      IF LT_RESULT-SIT_GI IS NOT INITIAL.
        GS_S0100-SIT_GI   = LT_RESULT-SIT_GI.
        GS_S0100-SIT_FREE = LT_RESULT-SIT_FREE.
      ENDIF.
    ENDIF.

    GS_S0100-SIT_AMT  = GS_S0100-SIT_GI * GS_S0100-KBETR.

    IF GS_S0100-SIT_FREE IS INITIAL.
      GS_S0100-BAL_STS = ICON_LED_INACTIVE.
    ELSE.

      IF GS_S0100-SIT_FREE = GS_S0100-FKIMG AND GS_S0100-SIT_GI IS INITIAL.
        GS_S0100-BAL_STS = ICON_LED_GREEN.
      ELSE.
        GS_S0100-BAL_STS = ICON_LED_RED.
      ENDIF.

      IF GS_S0100-SIT_FREE = GS_S0100-FKIMG AND GS_S0100-SIT_GI > 0.
        GS_S0100-BAL_STS = ICON_LED_YELLOW.
      ENDIF.

    ENDIF.

    READ TABLE LT_BUDAT INTO DATA(LS_DT) WITH KEY VBELV = GS_S0100-VBEVL BINARY SEARCH.
    IF SY-SUBRC = 0.
      GS_S0100-WADAT_IST2 = LS_DT-BUDAT_MKPF.
    ENDIF.

    READ TABLE LT_1070 INTO DATA(LS_1070) WITH KEY VBELN = GS_S0100-VBEVL
                                                   POSNR = GS_S0100-POSVL
                                                   MATNR = GS_S0100-MATNR BINARY SEARCH.
    IF SY-SUBRC = 0.
      GS_S0100-ZLFIMG = LS_1070-ZLFIMG.
      GS_S0100-ZERDAT = LS_1070-ZERDAT.
      GS_S0100-ZCONF  = LS_1070-ZCONF.
    ENDIF.

*1)최초납품문서 2)항목번호 3)최초출고일  필드추가
    READ TABLE LT_ORI INTO DATA(LS_ORI) WITH KEY VBELN_N = GS_S0100-VBELN
                                                 POSNR_N = GS_S0100-POSNR BINARY SEARCH.
    IF SY-SUBRC = 0.
      GS_S0100-VBEVL_O      = LS_ORI-VBEVL_O.
      GS_S0100-POSVL_O      = LS_ORI-POSVL_O.
      GS_S0100-WADAT_IST_O  = LS_ORI-WADAT_IST_O.
    ENDIF.

    MODIFY GT_S0100 FROM GS_S0100.
  ENDLOOP.

  SORT GT_S0100 BY VKBUR VKGRP KDKG4 KUNAG VBEVL POSVL.
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

  "Split
  GO_SPLIT = NEW #( PARENT = PO_DCON ROWS = 2 COLUMNS = 1 ).

  GO_CON_TOP       = GO_SPLIT->GET_CONTAINER( ROW = 1 COLUMN = 1 ).
  DATA(LO_CON_BTT) = GO_SPLIT->GET_CONTAINER( ROW = 2 COLUMN = 1 ).

  GO_SPLIT->SET_ROW_HEIGHT( ID = 1 HEIGHT = 15 ).

  "Create Object
  GO_DOCU = NEW #( STYLE = 'ALV_GRID' ).  "Top-Of-Page

  PERFORM CREATE_ALV USING    LO_CON_BTT
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

  PERFORM RESET_FIELD_CATALOG TABLES GT_FCAT USING :
      'S' 'FIELDNAME'   'BRANCH',
      ' ' 'COLTEXT'     TEXT-F01,
      ' ' 'ICON'        'X',
      ' ' 'OUTPUTLEN'   '10',
      'E' 'KEY'         'X',

      'S' 'FIELDNAME'   'VKGRP',
      ' ' 'COLTEXT'     TEXT-F02,
      ' ' 'OUTPUTLEN'   '10',
      'E' 'KEY'         'X',

      'S' 'FIELDNAME'   'KDKG4',
      ' ' 'COLTEXT'     TEXT-F03,
      ' ' 'OUTPUTLEN'   '20',
      'E' 'KEY'         'X',

      'S' 'FIELDNAME'   'KUNAG',
      ' ' 'COLTEXT'     TEXT-F04,
      ' ' 'OUTPUTLEN'   '20',
      'E' 'KEY'         'X',

      'S' 'FIELDNAME'   'KUNAG_NM',
      ' ' 'COLTEXT'     TEXT-F05,
      ' ' 'OUTPUTLEN'   '20',
      'E' 'KEY'         'X',

      'S' 'FIELDNAME'   'VBEVL',
      ' ' 'COLTEXT'     TEXT-F06,
      'E' 'OUTPUTLEN'   '20',

      'S' 'FIELDNAME'   'POSVL',
      ' ' 'COLTEXT'     TEXT-F07,
      'E' 'OUTPUTLEN'   '20',

      'S' 'FIELDNAME'   'MATNR',
      ' ' 'COLTEXT'     TEXT-F08,
      'E' 'OUTPUTLEN'   '20',

      'S' 'FIELDNAME'   'MAKTX',
      ' ' 'COLTEXT'     TEXT-F09,
      'E' 'OUTPUTLEN'   '20',

      'S' 'FIELDNAME'   'VRKME',
      ' ' 'COLTEXT'     TEXT-F22,
      'E' 'OUTPUTLEN'   '10',

      'S' 'FIELDNAME'   'LFIMG',
      ' ' 'COLTEXT'     TEXT-F10,
      ' ' 'QFIELDNAME' 'VRKME',
      'E' 'OUTPUTLEN'   '10',

      'S' 'FIELDNAME'   'CHARG',
      ' ' 'COLTEXT'     TEXT-F11,
      'E' 'OUTPUTLEN'   '10',

      'S' 'FIELDNAME'   'SIT_FREE',
      ' ' 'COLTEXT'     TEXT-F12,
      ' ' 'QFIELDNAME' 'VRKME',
      'E' 'OUTPUTLEN'   '10',

      'S' 'FIELDNAME'   'SIT_GI',
      ' ' 'COLTEXT'     TEXT-F13,
      ' ' 'QFIELDNAME' 'VRKME',
      'E' 'OUTPUTLEN'   '10',

      'S' 'FIELDNAME'   'KBETR',
      ' ' 'COLTEXT'     TEXT-F14,
      ' ' 'CFIELDNAME' 'WAERK',
      'E' 'OUTPUTLEN'   '10',

      'S' 'FIELDNAME'   'SIT_AMT',
      ' ' 'COLTEXT'     TEXT-F15,
      ' ' 'CFIELDNAME' 'WAERK',
      'E' 'OUTPUTLEN'   '10',

      'S' 'FIELDNAME'   'WAERK',
      ' ' 'COLTEXT'     TEXT-F21,
      'E' 'OUTPUTLEN'   '10',

      'S' 'FIELDNAME'   'VBELN',
      ' ' 'COLTEXT'     TEXT-F16,
      'E' 'OUTPUTLEN'   '10',

      'S' 'FIELDNAME'   'POSNR',
      ' ' 'COLTEXT'     TEXT-F17,
      'E' 'OUTPUTLEN'   '10',

      'S' 'FIELDNAME'   'BAL_STS',
      ' ' 'COLTEXT'     TEXT-F18,
      ' ' 'ICON'        'X',
      'E' 'OUTPUTLEN'   '10',

      'S' 'FIELDNAME'   'WADAT_IST2',
      ' ' 'COLTEXT'     TEXT-F23,
      'E' 'OUTPUTLEN'   '10',

      'S' 'FIELDNAME'   'WADAT_IST',
      ' ' 'COLTEXT'     TEXT-F19,
      'E' 'OUTPUTLEN'   '10',

      'S' 'FIELDNAME'   'ZLFIMG',
      ' ' 'COLTEXT'     TEXT-F24,
      ' ' 'QFIELDNAME'  'VRKME',
      ' ' 'EDIT'        'X',
      ' ' 'NO_ZERO'     'X',
      ' ' 'REF_TABLE'   'ZGTSDT1070',
      ' ' 'REF_FIELD'   'ZLFIMG',
      'E' 'OUTPUTLEN'   '10',

      'S' 'FIELDNAME'   'ZERDAT',
      ' ' 'COLTEXT'     TEXT-F20,
      ' ' 'REF_TABLE'   'ZGTSDT1070',
      ' ' 'REF_FIELD'   'ZERDAT',
      ' ' 'EDIT'        'X',
      'E' 'OUTPUTLEN'   '10',

      'S' 'FIELDNAME'   'ZCONF',
      ' ' 'COLTEXT'     TEXT-F25,
      ' ' 'REF_TABLE'   'ZGTSDT1070',
      ' ' 'REF_FIELD'   'ZCONF',
      ' ' 'EDIT'        'X',
      'E' 'OUTPUTLEN'   '10',

      'S' 'FIELDNAME'   'VBEVL_O',
      ' ' 'COLTEXT'     TEXT-F27,
      'E' 'OUTPUTLEN'   '10',

      'S' 'FIELDNAME'   'POSVL_O',
      ' ' 'COLTEXT'     TEXT-F28,
      'E' 'OUTPUTLEN'   '10',

      'S' 'FIELDNAME'   'WADAT_IST_O',
      ' ' 'COLTEXT'     TEXT-F29,
      'E' 'OUTPUTLEN'   '10'.

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
                LO_EVENT->HANDLE_DATA_CHANGED          FOR PO_SENDER,
                LO_EVENT->HANDLE_TOOLBAR               FOR PO_SENDER,
                LO_EVENT->HANDLE_USER_COMMAND          FOR PO_SENDER,
                LO_EVENT->HANDLE_DBL_CLICK             FOR PO_SENDER.
*                LO_EVENT->HANDLE_ON_F4                 FOR PO_SENDER.
*               LO_EVENT->HANDLE_DATA_CHANGED_FINISHED FOR PO_SENDER.

  "Data Changed Event
  PO_SENDER->REGISTER_EDIT_EVENT( CL_GUI_ALV_GRID=>MC_EVT_MODIFIED ).
  PO_SENDER->REGISTER_EDIT_EVENT( CL_GUI_ALV_GRID=>MC_EVT_ENTER ).

  "Set Ready for Input
  GO_GRID->SET_READY_FOR_INPUT( SWITCH #( GV_EDIT WHEN ZGTSD_X THEN 1 ELSE 0 ) ).

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

  RANGES : LR_DO FOR LIPS-VBELN.

  CHECK PV_ROW-ROWTYPE EQ SPACE.
  READ TABLE GT_S0100 INTO GS_S0100 INDEX PV_ROW-INDEX.
  CHECK SY-SUBRC = 0 .

  CASE PV_COLUMN.
    WHEN 'VBEVL'.
      CHECK GS_S0100-VBEVL IS NOT INITIAL.
      SET PARAMETER ID 'VL' FIELD   GS_S0100-VBEVL.
      CALL TRANSACTION  'VL03N' AND SKIP FIRST SCREEN.

    WHEN 'VBEVL_O'.
      CHECK GS_S0100-VBEVL_O IS NOT INITIAL.
      SET PARAMETER ID 'VL' FIELD   GS_S0100-VBEVL_O.
      CALL TRANSACTION  'VL03N' AND SKIP FIRST SCREEN.
    WHEN 'VBELN'.
      CHECK GS_S0100-VBELN IS NOT INITIAL.
      SET PARAMETER ID 'AUN' FIELD   GS_S0100-VBELN.
      CALL TRANSACTION  'VA03' AND SKIP FIRST SCREEN.

    WHEN 'KUNAG'.
      CHECK GS_S0100-KUNAG IS NOT INITIAL.
      SET PARAMETER ID 'KUN' FIELD   GS_S0100-KUNAG.
      SET PARAMETER ID 'VKO' FIELD   P_VKORG.
      SET PARAMETER ID 'VTW' FIELD   GS_S0100-VTWEG.
      SET PARAMETER ID 'SPA' FIELD   GS_S0100-SPART.
      CALL TRANSACTION  'VD03' AND SKIP FIRST SCREEN.

    WHEN 'LIFNR'.
      CHECK GS_S0100-LIFNR IS NOT INITIAL.
      SET PARAMETER ID 'KUN' FIELD   GS_S0100-LIFNR.
      SET PARAMETER ID 'VKO' FIELD   P_VKORG.
      SET PARAMETER ID 'VTW' FIELD   GS_S0100-VTWEG.
      SET PARAMETER ID 'SPA' FIELD   GS_S0100-SPART.
      CALL TRANSACTION  'VD03' AND SKIP FIRST SCREEN.

    WHEN 'SIT_GI'.
      CHECK GS_S0100-VBEVL IS NOT INITIAL.
      __CLE LR_DO.
      __RNG LR_DO 'I' 'EQ' GS_S0100-VBEVL ''.
      SUBMIT RM07SIT WITH SO_DELOU IN LR_DO AND RETURN.

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

*  PERFORM SET_SORT_FIELD USING: PT_SORT 'KUNNR' GC_X '' '',
*                                PT_SORT 'AEDAT' GC_X '' '',
*                                PT_SORT 'AEZET' GC_X '' ''.

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

  LO_TABLE->ADD_COLUMN( EXPORTING WIDTH = '20%' IMPORTING COLUMN = DATA(LO_COL_KEY) ).
  LO_TABLE->ADD_COLUMN( EXPORTING WIDTH = '3%' IMPORTING COLUMN = DATA(LO_COL_SEP) ).
  LO_TABLE->ADD_COLUMN( EXPORTING WIDTH = '77%' IMPORTING COLUMN = DATA(LO_COL_VAL) ).
  LO_TABLE->NEW_ROW( ).

  "Set Column Style
  LO_TABLE->SET_COLUMN_STYLE( COL_NO = 1 SAP_EMPHASIS = CL_DD_DOCUMENT=>STRONG SAP_ALIGN = 'LEFT' ).
  LO_TABLE->SET_COLUMN_STYLE( COL_NO = 3 SAP_EMPHASIS = CL_DD_DOCUMENT=>MEDIUM SAP_ALIGN = 'LEFT' ).

  PERFORM ADD_TEXT_COMMON USING LO_COL_KEY LO_COL_SEP LO_COL_VAL LO_TABLE
                                ZGTSD_P %_P_VKORG_%_APP_%-TEXT P_VKORG.

  PERFORM ADD_TEXT_COMMON USING LO_COL_KEY LO_COL_SEP LO_COL_VAL LO_TABLE
                                ZGTSD_S %_S_VTWEG_%_APP_%-TEXT 'S_VTWEG[]'.

  PERFORM ADD_TEXT_COMMON USING LO_COL_KEY LO_COL_SEP LO_COL_VAL LO_TABLE
                                ZGTSD_S %_S_SPART_%_APP_%-TEXT 'S_SPART[]'.

  PERFORM ADD_TEXT_COMMON USING LO_COL_KEY LO_COL_SEP LO_COL_VAL LO_TABLE
                                ZGTSD_S %_S_BRANCH_%_APP_%-TEXT 'S_BRANCH[]'.

  PERFORM ADD_TEXT_COMMON USING LO_COL_KEY LO_COL_SEP LO_COL_VAL LO_TABLE
                              ZGTSD_S %_S_VKBUR_%_APP_%-TEXT 'S_VKBUR[]'.

  PERFORM ADD_TEXT_COMMON USING LO_COL_KEY LO_COL_SEP LO_COL_VAL LO_TABLE
                              ZGTSD_S %_S_VKGRP_%_APP_%-TEXT 'S_VKGRP[]'.

  PERFORM ADD_TEXT_COMMON USING LO_COL_KEY LO_COL_SEP LO_COL_VAL LO_TABLE
                              ZGTSD_S %_S_VBEVL_%_APP_%-TEXT 'S_VBEVL[]'.

  PERFORM ADD_TEXT_COMMON USING LO_COL_KEY LO_COL_SEP LO_COL_VAL LO_TABLE
                              ZGTSD_S %_S_WADAT_%_APP_%-TEXT 'S_WADAT[]'.

  PERFORM ADD_TEXT_COMMON USING LO_COL_KEY LO_COL_SEP LO_COL_VAL LO_TABLE
                             ZGTSD_S %_S_KDKG4_%_APP_%-TEXT 'S_KDKG4[]'.

  PERFORM ADD_TEXT_COMMON USING LO_COL_KEY LO_COL_SEP LO_COL_VAL LO_TABLE
                              ZGTSD_S %_S_KUNNR_%_APP_%-TEXT 'S_KUNNR[]'.

  PERFORM ADD_TEXT_COMMON USING LO_COL_KEY LO_COL_SEP LO_COL_VAL LO_TABLE
                            ZGTSD_S %_S_LIFNR_%_APP_%-TEXT 'S_LIFNR[]'.

  PERFORM ADD_TEXT_COMMON USING LO_COL_KEY LO_COL_SEP LO_COL_VAL LO_TABLE
                             ZGTSD_S %_S_KDKG4_%_APP_%-TEXT 'S_ERNAM[]'.

  PERFORM ADD_TEXT_COMMON USING LO_COL_KEY LO_COL_SEP LO_COL_VAL LO_TABLE
                             ZGTSD_S %_S_ERDAT_%_APP_%-TEXT 'S_ERDAT[]'.


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

  CHECK PO_SENDER = GO_GRID. "Main

  CASE PS_COLUMN-FIELDNAME.

    WHEN 'MATNR'. "자산번호

      READ TABLE GT_S0100 INTO DATA(LS_MAIN) INDEX PS_ROW_NO-ROW_ID.
      CHECK SY-SUBRC = 0.

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
      WHEN 'A'. "Append
        APPEND LS_TOOLBAR TO PO_OBJECT->MT_TOOLBAR.
      WHEN 'I'. "Insert
        INSERT LS_TOOLBAR INTO PO_OBJECT->MT_TOOLBAR INDEX 1.
    ENDCASE.
  END-OF-DEFINITION.

  DATA : LS_TOOLBAR TYPE STB_BUTTON.

  CHECK GV_EDIT = ZGTSD_X.     "수정가능 상태

  CASE PO_SENDER.
    WHEN GO_GRID. "Main
      _ADD_TOOLBAR SPACE SPACE SPACE SPACE  3 'A'.
      _ADD_TOOLBAR 'MULTI' ICON_INSERT_MULTIPLE_LINES TEXT-F26 '인수예정일괄입력' 0 'A'. "
      _ADD_TOOLBAR 'SAVE' ICON_SYSTEM_SAVE TEXT-F26 TEXT-F26 0 'A'. "
  ENDCASE.

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
*& Form SAVE_PROCESS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> SENDER
*&---------------------------------------------------------------------*
FORM SAVE_PROCESS  USING    P_SENDER.

  DATA : LV_SUBRC TYPE SY-SUBRC,
         LV_ERR   TYPE C,
         LT_TMP   LIKE TABLE OF GS_S0100,
         LT_1070  TYPE TABLE OF ZGTSDT1070 WITH HEADER LINE.

*  "Selected Rows
*  DATA(LT_ROWS) = ZGTSD_CL_COMMON=>GET_SELECTED_ROWS( EXPORTING
*                                                        IO_GRID = GO_GRID
*                                                        IV_CK   = ZGTSD_X
*                                                      IMPORTING
*                                                        EV_SUBRC = LV_SUBRC ).
*  CHECK LV_SUBRC IS INITIAL.
*
*  CLEAR GS_S0100.
*  MODIFY GT_S0100 FROM GS_S0100 TRANSPORTING SEL WHERE SEL IS NOT INITIAL.


* 기존 데이터 삭제할 때도 Check 하고 있어서 주석처리 - start
*  LOOP AT GT_S0100 INTO GS_S0100.
*
*    IF GS_S0100-ZLFIMG IS INITIAL.
*      MESSAGE S007 WITH TEXT-F24 DISPLAY LIKE 'E'.
*      LV_ERR = 'X'. EXIT.
*    ENDIF.
*
*    IF GS_S0100-ZERDAT IS INITIAL.
*      MESSAGE S007 WITH TEXT-F20 DISPLAY LIKE 'E'.
*      LV_ERR = 'X'. EXIT.
*    ENDIF.
*
*  ENDLOOP.
* 기존 데이터 삭제할 때도 Check 하고 있어서 주석처리 - end


  CHECK LV_ERR IS INITIAL.

  CLEAR GV_ANSWER.
  GV_ANSWER = ZGTSD_CL_COMMON=>POPUP_TO_COMFIRM( IV_UCOMM = SPACE
                                                 IV_MESSA = TEXT-M01 ).
  CHECK GV_ANSWER = ZGTSD_J.

***********************************************************************
**협의 내용 저장
***********************************************************************
  LOOP AT GT_S0100 INTO GS_S0100.

    MOVE-CORRESPONDING GS_S0100 TO LT_1070.
    GET TIME STAMP FIELD LT_1070-ZCKEY.

    LT_1070-VBELN = GS_S0100-VBEVL.
    LT_1070-POSNR = GS_S0100-POSVL.
    LT_1070-MATNR = GS_S0100-MATNR.
    LT_1070-MEINS = GS_S0100-VRKME.

    ZGTSD_CL_COMMON=>SET_TIMESTAMP( EXPORTING IV_GUBUN = ZGTSD_C
                                     CHANGING CS_TIMESTAMP = LT_1070-TIMESTAMP ).
    APPEND LT_1070. CLEAR LT_1070.

  ENDLOOP.

  IF LT_1070[] IS NOT INITIAL.
    MODIFY ZGTSDT1070 FROM TABLE LT_1070.
  ENDIF.

  MESSAGE S011.
*  PERFORM REFRESH_TABLE_DISPLAY USING GO_GRID SPACE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form MULTI_INPUT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> SENDER
*&---------------------------------------------------------------------*
FORM MULTI_INPUT  USING PV_SENDER.

  DATA : LV_SUBRC TYPE SY-SUBRC,
         LV_ERR   TYPE C,
         LT_TMP   LIKE TABLE OF GS_S0100,
         LT_1070  TYPE TABLE OF ZGTSDT1070 WITH HEADER LINE.

  "Selected Rows
  DATA(LT_ROWS) = ZGTSD_CL_COMMON=>GET_SELECTED_ROWS( EXPORTING
                                                        IO_GRID = GO_GRID
                                                        IV_CK   = ZGTSD_X
                                                      IMPORTING
                                                        EV_SUBRC = LV_SUBRC ).
  CHECK LV_SUBRC IS INITIAL.

  CLEAR GS_S0100.
  MODIFY GT_S0100 FROM GS_S0100 TRANSPORTING SEL WHERE SEL IS NOT INITIAL.

  LOOP AT LT_ROWS INTO DATA(LS_ROW).
    READ TABLE GT_S0100 INTO GS_S0100 INDEX LS_ROW-INDEX.
    CHECK SY-SUBRC = 0.
    GS_S0100-SEL = GC_X.
    MODIFY GT_S0100 FROM GS_S0100 INDEX LS_ROW-INDEX.
  ENDLOOP.

  CLEAR GS_S0200.
  CALL SCREEN 0200 STARTING AT 60 1 ENDING AT 108 4.
  CHECK GS_S0200-CONFIRM IS NOT INITIAL.

  LOOP AT GT_S0100 INTO GS_S0100 WHERE SEL IS NOT INITIAL.
    GS_S0100-ZLFIMG = GS_S0100-LFIMG.       "인수 예정 수량 "
    GS_S0100-ZERDAT = GS_S0200-ZERDAT.       "인수예정일자 "
    GS_S0100-ZCONF  = GS_S0200-ZCONF.        "인수협의내용 "
    MODIFY GT_S0100 FROM GS_S0100.
  ENDLOOP.

  CLEAR GS_S0100.
  MODIFY GT_S0100 FROM GS_S0100 TRANSPORTING SEL WHERE SEL IS NOT INITIAL.

  MESSAGE S000 WITH '처리되었습니다.'.
  PERFORM REFRESH_TABLE_DISPLAY USING GO_GRID SPACE.
ENDFORM.
