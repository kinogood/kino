*&---------------------------------------------------------------------*
*& Include          ZGTSDR0000F01
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

  S_UDATE-LOW = SY-DATLO - 1.
  S_UDATE-HIGH = SY-DATLO.
  __RNG S_UDATE 'I' 'EQ' S_UDATE-LOW S_UDATE-HIGH.

  "영업 팀.
  SELECT FLD_01, FLD_02, FLD_03, FLD_04
    FROM ZGTPPT1010
   WHERE MODULE_KIND EQ 'SD'
     AND CODEGRP EQ '5003'
    INTO CORRESPONDING FIELDS OF TABLE @GT_VKBUR.

  "오더 유형.
  SELECT B~FLD_01, B~FLD_02, B~FLD_03, B~FLD_04
    FROM @GT_VKBUR AS A INNER JOIN ZGTPPT1010 AS B
      ON A~FLD_01 = B~FLD_01
   WHERE B~MODULE_KIND EQ 'SD'
     AND B~CODEGRP EQ '5001'
    INTO CORRESPONDING FIELDS OF TABLE @GT_AUART.

  LOOP AT GT_AUART ASSIGNING FIELD-SYMBOL(<LS_AUART>).
    CALL FUNCTION 'CONVERSION_EXIT_AUART_INPUT'
      EXPORTING
        INPUT  = <LS_AUART>-FLD_03
      IMPORTING
        OUTPUT = <LS_AUART>-FLD_03.
  ENDLOOP.



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
      WHEN 'P_VKORG' OR  'P_UDATE'.      "영업조직

        SCREEN-REQUIRED = 2. "필수 필드 표시

      WHEN 'P_VTEXT'.      "영업조직Text

        SCREEN-INPUT = 0.
        SCREEN-INTENSIFIED = 1.
        SCREEN-DISPLAY_3D  = 0.
    ENDCASE.

    MODIFY SCREEN.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_VKORG
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> TEXT_S01
*&      --> P_VKORG
*&      <-- P_BEZEI
*&---------------------------------------------------------------------*
FORM CHECK_VKORG  USING    PV_CODE
                  CHANGING PV_TEXT.

  DATA : LV_SUBRC TYPE SYSUBRC.

  CLEAR PV_TEXT.
  CHECK PV_CODE IS NOT INITIAL.

  SELECT SINGLE VTEXT INTO @PV_TEXT FROM TVKOT WHERE VKORG = @PV_CODE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SEARCH_HELP_KOKRS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM SEARCH_HELP_VKORG  USING PV_TITLE
                              PV_RETFIELD
                              PV_FNAME
                     CHANGING PV_CODE
                              PV_TEXT.

  "Get Data
  SELECT VKORG, VTEXT INTO TABLE @DATA(LT_CODE)
    FROM TVKOT.

  "Call F4 Help
  PERFORM F4IF_INT_TABLE_VALUE_REQUEST TABLES   LT_CODE
                                       USING    PV_RETFIELD
                                                PV_TITLE
                                                SPACE
                                       CHANGING PV_CODE.

  "Set Desc.
  IF PV_CODE IS NOT INITIAL.
    PERFORM CHECK_VKORG USING    PV_CODE
                        CHANGING PV_TEXT.

    PERFORM DYNP_VALUES_UPDATE USING PV_FNAME
                                     PV_TEXT.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form F4IF_INT_TABLE_VALUE_REQUEST
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM F4IF_INT_TABLE_VALUE_REQUEST TABLES    PT_DATA
                                   USING    PV_RETFIELD
                                            PV_TITLE
                                            PV_DISPLAY
                                   CHANGING PV_CODE.
  DATA: LT_RETTAB TYPE TABLE OF DDSHRETVAL.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      RETFIELD        = PV_RETFIELD          " Return Field
      VALUE_ORG       = ZGTSD_S
      WINDOW_TITLE    = PV_TITLE
      DISPLAY         = PV_DISPLAY
    TABLES
      VALUE_TAB       = PT_DATA[]            " Value
      RETURN_TAB      = LT_RETTAB            " Return Tab
    EXCEPTIONS
      PARAMETER_ERROR = 1
      NO_VALUES_FOUND = 2
      OTHERS          = 3.

  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ELSE.
    PV_CODE = VALUE #( LT_RETTAB[ 1 ]-FIELDVAL OPTIONAL ).
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form DYNP_VALUES_UPDATE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM DYNP_VALUES_UPDATE USING PV_FNAME
                              PV_TEXT.

  ZGTSD_CL_COMMON=>SET_DYNP_VALUE( IV_REPID = SY-REPID
                                   IV_DYNNR = SY-DYNNR
                                   IV_FNAME = CONV #( PV_FNAME )
                                   IV_VALUE = CONV #( PV_TEXT  ) ).


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
  IF P_VKORG IS INITIAL. "
    MESSAGE S055(00) DISPLAY LIKE ZGTSD_E.
    GV_ERROR = ZGTSD_X.
    RETURN.
  ENDIF.

  IF S_UDATE[] IS INITIAL.
    MESSAGE S055(00) DISPLAY LIKE ZGTSD_E.
    GV_ERROR = ZGTSD_X.
    RETURN.
  ENDIF.

  SORT GT_AUART BY FLD_02.
  SORT GT_VKBUR BY FLD_01.

  CHECK GV_ERROR IS INITIAL.
  IF S_AUART[] IS NOT INITIAL.
    LOOP AT S_AUART.

*      CALL FUNCTION 'CONVERSION_EXIT_AUART_INPUT'
*        EXPORTING
*          INPUT  = S_AUART-LOW
*        IMPORTING
*          OUTPUT = <LS_AUART>-FLD_03.

      READ TABLE GT_AUART INTO DATA(LS_AUART) WITH KEY FLD_03 = S_AUART-LOW BINARY SEARCH.
      IF SY-SUBRC NE 0.
        MESSAGE S006 WITH %_S_AUART_%_APP_%-TEXT S_AUART-LOW  DISPLAY LIKE ZGTSD_E.
        GV_ERROR = ZGTSD_X.
        RETURN.
      ENDIF.
    ENDLOOP.

  ENDIF.

  CHECK GV_ERROR IS INITIAL.
  IF S_VKBUR[] IS NOT INITIAL.
    LOOP AT S_VKBUR.
      READ TABLE GT_VKBUR INTO DATA(LS_VKBUR) WITH KEY FLD_01 = S_VKBUR-LOW BINARY SEARCH.
      IF SY-SUBRC NE 0.
        MESSAGE S000 WITH TEXT-E03  DISPLAY LIKE ZGTSD_E.
        GV_ERROR = ZGTSD_X.
        RETURN.
      ENDIF.

      SELECT SINGLE MANDT INTO SY-MANDT
        FROM TVKBZ
       WHERE VKORG = P_VKORG
         AND VKBUR = S_VKBUR-LOW.
      IF SY-SUBRC NE 0.
        MESSAGE S006 WITH %_S_VKBUR_%_APP_%-TEXT S_VKBUR-LOW  DISPLAY LIKE ZGTSD_E.
        GV_ERROR = ZGTSD_X.
        RETURN.
      ENDIF.
    ENDLOOP.
  ENDIF.

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

  DATA : LV_KSCHL TYPE KSCHL,
         LV_POSNR TYPE POSNR_VA,
         LS_CDHDR TYPE CDHDR,
         LT_CDSHW TYPE TABLE OF CDSHW.

  RANGES : LR_FNAME FOR CDPOS-FNAME,
           LR_VKBUR FOR VBAK-VKBUR,
           LR_AUART FOR VBAK-AUART.

*코드 마스터에서 설정된 조회 조건만 읽는다.
  SELECT B~FLD_01, B~FLD_02, B~FLD_03, B~FLD_04
    FROM ZGTPPT1010 AS B
   WHERE B~MODULE_KIND EQ 'SD'
     AND B~CODEGRP EQ '5000'
    INTO TABLE @DATA(LT_FNAME).

  SELECT FLD_01, FLD_02, FLD_03, FLD_04
    FROM ZGTPPT1010
   WHERE MODULE_KIND EQ 'SD'
     AND CODEGRP EQ '5004'
    INTO TABLE @DATA(LT_KSCHL).

  LOOP AT GT_VKBUR INTO DATA(LS_DO).

    __CLE : LR_FNAME, LR_VKBUR, LR_AUART.

    LR_FNAME[] =  VALUE #( FOR LS_FNAME IN LT_FNAME  WHERE ( FLD_01 = LS_DO-FLD_01 ) (
                           SIGN    = ZGTSD_I
                           OPTION  = ZGTSD_EQ
                           LOW     = LS_FNAME-FLD_03  ) ).

    IF S_VKBUR[] IS INITIAL.
      APPEND VALUE #( SIGN    = ZGTSD_I
                      OPTION  = ZGTSD_EQ
                      LOW     = LS_DO-FLD_01 ) TO LR_VKBUR[].

    ELSE.
      LR_VKBUR[] = CORRESPONDING #( S_VKBUR[] ).
    ENDIF.

    IF S_AUART[] IS INITIAL.
      LR_AUART[] =  VALUE #( FOR LS_AUART IN GT_AUART WHERE ( FLD_01 = LS_DO-FLD_01 ) (
                             SIGN    = ZGTSD_I
                             OPTION  = ZGTSD_EQ
                             LOW     = CONV AUART( LS_AUART-FLD_03 ) ) ).
    ELSE.
      LR_AUART[] = CORRESPONDING #( S_AUART[] ).
    ENDIF.

    SELECT ZGTSDT1001~* APPENDING TABLE @DATA(LT_1001)
      FROM ZGTSDT1001
     WHERE VKORG   = @P_VKORG
       AND VKBUR  IN @LR_VKBUR
       AND AUART  IN @LR_AUART
       AND VBELN  IN @S_VBELN
*     AND MATNR  IN @S_MATNR
       AND UDATE  IN @S_UDATE.

*DATA 조회
    WITH +CDPOS AS (
      SELECT A~UDATE, A~UTIME, A~USERNAME, A~TCODE,
             B~TABKEY, B~CHANGENR, B~TABNAME, B~FNAME,
             B~VALUE_NEW, B~VALUE_OLD, B~OBJECTID
        FROM CDHDR AS A INNER JOIN CDPOS AS B
          ON A~OBJECTCLAS = B~OBJECTCLAS
         AND A~OBJECTID   = B~OBJECTID
         AND A~CHANGENR   = B~CHANGENR
       WHERE UDATE      IN @S_UDATE
         AND A~OBJECTID IN @S_VBELN
         AND FNAME      IN @LR_FNAME
         AND CHANGE_IND IN (@ZGTSD_U, @ZGTSD_D)
         AND CHNGIND    IN (@ZGTSD_U, @ZGTSD_D)
    )
    SELECT A~VBELN, A~AUART, VKBUR, VKORG, A~UPD_TMSTMP, "B~MATNR,
           C~UDATE, C~UTIME, C~USERNAME, C~TCODE,
           C~TABKEY, C~CHANGENR, C~TABNAME, C~FNAME,
           C~VALUE_NEW, C~VALUE_OLD, C~OBJECTID
      FROM VBAK AS A "INNER JOIN VBAP AS B
*      ON A~VBELN = B~VBELN
     INNER JOIN +CDPOS AS C
        ON A~VBELN = C~OBJECTID
      LEFT OUTER JOIN USR21 AS E
        ON C~USERNAME = E~BNAME
     WHERE A~VKORG   = @P_VKORG
       AND A~AUART  IN @LR_AUART
       AND A~VKBUR  IN @LR_VKBUR
       AND A~VBELN  IN @S_VBELN
      APPENDING TABLE @DATA(LT_DATA).

  ENDLOOP .

*변경자 명
  DATA(LT_FOR) = LT_DATA[].
  SORT LT_FOR BY USERNAME.
  DELETE ADJACENT DUPLICATES FROM LT_FOR COMPARING USERNAME.
  IF LT_FOR[] IS NOT INITIAL.
    SELECT A~BNAME, B~NAME_LAST INTO TABLE @DATA(LT_PER)
      FROM USR21 AS A INNER JOIN V_ADDR_USR AS B
        ON A~ADDRNUMBER = B~ADDRNUMBER
       AND A~PERSNUMBER = B~PERSNUMBER
       FOR ALL ENTRIES IN @LT_FOR
     WHERE BNAME = @LT_FOR-USERNAME.
  ENDIF.

  LT_FOR[] = LT_DATA[].
  SORT LT_FOR BY VBELN.
  DELETE ADJACENT DUPLICATES FROM LT_FOR COMPARING VBELN.
  IF LT_FOR[] IS NOT INITIAL.
    SELECT VBELN, POSNR, MATNR INTO TABLE @DATA(LT_VBAP)
      FROM VBAP
       FOR ALL ENTRIES IN @LT_FOR
     WHERE VBELN = @LT_FOR-VBELN.
*       AND MATNR  IN @S_MATNR.
  ENDIF.

* 인코텀즈
  SELECT TINCT~* INTO TABLE @DATA(LT_TINCT)
    FROM TINCT
   WHERE SPRAS = @SY-LANGU.

* 지급조건
  SELECT T052U~* INTO TABLE @DATA(LT_T052U)
    FROM T052U
   WHERE SPRAS = @SY-LANGU.

* 출하조건
  SELECT TVSBT~* INTO TABLE @DATA(LT_TVSBT)
    FROM TVSBT
   WHERE SPRAS = @SY-LANGU.

  SORT LT_TINCT BY INCO1.
  SORT LT_T052U BY ZTERM.
  SORT LT_TVSBT BY VSBED.

  SORT LT_PER   BY BNAME.
  SORT LT_1001  BY VBELN UDATE.
  SORT LT_VBAP  BY VBELN POSNR.
  SORT LT_KSCHL BY FLD_01 FLD_02.

  LOOP AT LT_DATA INTO DATA(LS_DATA).

    CLEAR GS_S0100.
    MOVE-CORRESPONDING LS_DATA TO GS_S0100.

    READ TABLE LT_VBAP INTO DATA(LS_VBAP) WITH KEY VBELN = LS_DATA-VBELN BINARY SEARCH.
    IF SY-SUBRC NE 0.
      CONTINUE.
    ELSE.
      DATA(LV_CNT) = STRLEN( LS_DATA-TABKEY ).
      DATA(LV_CUT) = LV_CNT - 6.
      CASE LS_DATA-FNAME.
        WHEN 'KBETR'.
          LV_POSNR = LS_DATA-TABKEY(6).
        WHEN OTHERS.
          LV_POSNR = LS_DATA-TABKEY+LV_CUT(6).
      ENDCASE.

      READ TABLE LT_VBAP INTO LS_VBAP WITH KEY VBELN = LS_DATA-VBELN
                                               POSNR = LV_POSNR BINARY SEARCH.
      IF SY-SUBRC = 0.
        GS_S0100-POSNR = LS_VBAP-POSNR.
        GS_S0100-MATNR = LS_VBAP-MATNR.
      ENDIF.

    ENDIF.

*VKBUR 단위로 필드 제어
    READ TABLE LT_FNAME INTO DATA(LS_FLD) WITH KEY FLD_01 = LS_DATA-VKBUR
                                                   FLD_03 = LS_DATA-FNAME.
    IF SY-SUBRC NE 0.
      CONTINUE.
    ENDIF.

    CASE LS_DATA-FNAME.
      WHEN 'KBETR'.
        .
        "ZPR0 허용
        LV_CNT = STRLEN( LS_DATA-TABKEY ).
        LV_CUT = LV_CNT - 4.
        LV_KSCHL = LS_DATA-TABKEY+LV_CUT(4).

        READ TABLE LT_KSCHL INTO DATA(LS_KSCHL) WITH KEY FLD_01 = LS_DATA-FNAME
                                                         FLD_02 = LV_KSCHL BINARY SEARCH.
        IF SY-SUBRC NE 0.
          CONTINUE.
        ENDIF.

        READ TABLE LT_VBAP INTO LS_VBAP WITH KEY VBELN = LS_DATA-VBELN
                                                 POSNR = LS_DATA-TABKEY(6) BINARY SEARCH.
        IF SY-SUBRC = 0.
          GS_S0100-POSNR = LS_VBAP-POSNR.
          GS_S0100-MATNR = LS_VBAP-MATNR.
        ENDIF.

      WHEN 'INCO1'.


        READ TABLE LT_TINCT INTO DATA(LS_TINCT) WITH KEY INCO1 = LS_DATA-VALUE_OLD BINARY SEARCH.
        IF SY-SUBRC = 0.
          GS_S0100-VALUE_OLD_NM = LS_TINCT-BEZEI.
        ENDIF.

        READ TABLE LT_TINCT INTO LS_TINCT WITH KEY INCO1 = LS_DATA-VALUE_NEW BINARY SEARCH.
        IF SY-SUBRC = 0.
          GS_S0100-VALUE_NEW_NM = LS_TINCT-BEZEI.
        ENDIF.

      WHEN 'ZTERM'.

        READ TABLE LT_T052U INTO DATA(LS_T052U) WITH KEY ZTERM = LS_DATA-VALUE_OLD BINARY SEARCH.
        IF SY-SUBRC = 0.
          GS_S0100-VALUE_OLD_NM = LS_T052U-TEXT1.
        ENDIF.

        READ TABLE LT_T052U INTO LS_T052U WITH KEY ZTERM = LS_DATA-VALUE_NEW BINARY SEARCH.
        IF SY-SUBRC = 0.
          GS_S0100-VALUE_NEW_NM = LS_T052U-TEXT1.
        ENDIF.

        READ TABLE LT_VBAP INTO LS_VBAP WITH KEY VBELN = LS_DATA-VBELN
                                                 POSNR = LS_DATA-TABKEY(6) BINARY SEARCH.
        IF SY-SUBRC = 0.
          GS_S0100-POSNR = LS_VBAP-POSNR.
          GS_S0100-MATNR = LS_VBAP-MATNR.
        ENDIF.

      WHEN 'VSBED'.

        READ TABLE LT_TVSBT INTO DATA(LS_TVSBT) WITH KEY VSBED = LS_DATA-VALUE_OLD BINARY SEARCH.
        IF SY-SUBRC = 0.
          GS_S0100-VALUE_OLD_NM = LS_TVSBT-VTEXT.
        ENDIF.

        READ TABLE LT_TVSBT INTO LS_TVSBT WITH KEY VSBED = LS_DATA-VALUE_NEW BINARY SEARCH.
        IF SY-SUBRC = 0.
          GS_S0100-VALUE_NEW_NM = LS_TVSBT-VTEXT.
        ENDIF.

    ENDCASE.

*TEXT
    __CLE LT_CDSHW. CLEAR LS_CDHDR.
    CALL FUNCTION 'CHANGEDOCUMENT_READ_POSITIONS'
      EXPORTING
        CHANGENUMBER      = LS_DATA-CHANGENR
        TABLEKEY          = LS_DATA-TABKEY
        TABLENAME         = LS_DATA-TABNAME
      IMPORTING
        HEADER            = LS_CDHDR
      TABLES
        EDITPOS           = LT_CDSHW
      EXCEPTIONS
        NO_POSITION_FOUND = 1
        OTHERS            = 2.

    READ TABLE LT_CDSHW INTO DATA(LS_CDSHW) WITH KEY FNAME = LS_DATA-FNAME.
    GS_S0100-FTEXT     = LS_CDSHW-FTEXT.
    GS_S0100-VALUE_OLD = LS_CDSHW-F_OLD.
    GS_S0100-VALUE_NEW = LS_CDSHW-F_NEW.
    CLEAR LS_CDSHW.


    READ TABLE LT_PER INTO DATA(LS_PER) WITH KEY BNAME = LS_DATA-USERNAME BINARY SEARCH.
    IF SY-SUBRC = 0.
      GS_S0100-NAME = LS_PER-NAME_LAST.
    ENDIF.

    READ TABLE LT_1001 INTO DATA(LS_1001) WITH KEY VBELN = LS_DATA-VBELN
                                                   UDATE = LS_DATA-UDATE BINARY SEARCH.
    IF SY-SUBRC = 0.
      GS_S0100-RECTP     = LS_1001-RECTP.
      GS_S0100-RECYR     = LS_1001-RECYR.
      GS_S0100-RECNO     = LS_1001-RECNO.
      GS_S0100-SEND_DATE = LS_1001-SCDATE.
      GS_S0100-SEND_TIME = LS_1001-SCTIME.

      IF GS_S0100-SEND_DATE IS NOT INITIAL.
        GS_S0100-STATU = ICON_LED_GREEN.
      ELSE.
        GS_S0100-STATU = ICON_LED_YELLOW.
      ENDIF.
    ELSE.
      GS_S0100-STATU = ICON_LED_RED.
    ENDIF.

    APPEND GS_S0100 TO GT_S0100.

  ENDLOOP.
  SORT GT_S0100 BY VBELN POSNR.
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
  PERFORM SET_GRID_LAYOUT USING SPACE SPACE ZGTSD_D.

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
      'S' 'FIELDNAME'   'STATU',
      ' ' 'COLTEXT'     TEXT-F01,
      ' ' 'ICON'        'X',
      ' ' 'OUTPUTLEN'   '10',
      'E' 'KEY'         'X',

      'S' 'FIELDNAME'   'VKBUR',
      ' ' 'COLTEXT'     TEXT-S02,
      ' ' 'OUTPUTLEN'   '10',
      'E' 'KEY'         'X',

      'S' 'FIELDNAME'   'VBELN',
      ' ' 'COLTEXT'     TEXT-F02,
      ' ' 'OUTPUTLEN'   '10',
      'E' 'KEY'         'X',

      'S' 'FIELDNAME'   'POSNR',
      ' ' 'COLTEXT'     TEXT-F17,
      ' ' 'OUTPUTLEN'   '10',
      'E' 'KEY'         'X',

      'S' 'FIELDNAME'   'MATNR',
      ' ' 'COLTEXT'     TEXT-F16,
      ' ' 'OUTPUTLEN'   '10',
      'E' 'KEY'         'X',

      'S' 'FIELDNAME'   'UDATE',
      ' ' 'COLTEXT'     TEXT-F03,
      'E' 'OUTPUTLEN'   '20',

      'S' 'FIELDNAME'   'UTIME',
      ' ' 'COLTEXT'     TEXT-F04,
      'E' 'OUTPUTLEN'   '20',

      'S' 'FIELDNAME'   'USERNAME',
      ' ' 'COLTEXT'     TEXT-F05,
      'E' 'OUTPUTLEN'   '20',

      'S' 'FIELDNAME'   'NAME',
      ' ' 'COLTEXT'     TEXT-F05,
      'E' 'OUTPUTLEN'   '20',

      'S' 'FIELDNAME'   'FNAME',
      ' ' 'COLTEXT'     TEXT-F06,
      'E' 'OUTPUTLEN'   '20',

      'S' 'FIELDNAME'   'FTEXT',
      ' ' 'COLTEXT'     TEXT-F06,
      'E' 'OUTPUTLEN'   '20',

      'S' 'FIELDNAME'   'VALUE_OLD',
      ' ' 'COLTEXT'     TEXT-F07,
      'E' 'OUTPUTLEN'   '20',

      'S' 'FIELDNAME'   'VALUE_OLD_NM',
      ' ' 'COLTEXT'     TEXT-F08,
      'E' 'OUTPUTLEN'   '20',

      'S' 'FIELDNAME'   'VALUE_NEW',
      ' ' 'COLTEXT'     TEXT-F09,
      'E' 'OUTPUTLEN'   '20',

      'S' 'FIELDNAME'   'VALUE_NEW_NM',
      ' ' 'COLTEXT'     TEXT-F10,
      'E' 'OUTPUTLEN'   '20',

      'S' 'FIELDNAME'   'SEND_DATE',
      ' ' 'COLTEXT'     TEXT-F11,
      'E' 'OUTPUTLEN'   '20',

      'S' 'FIELDNAME'   'SEND_TIME',
      ' ' 'COLTEXT'     TEXT-F12,
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
  PERFORM ADD_TEXT_COMMON USING LO_COL_KEY LO_COL_SEP LO_COL_VAL LO_TABLE         "영업조직
                                ZGTSD_P %_P_VKORG_%_APP_%-TEXT P_VKORG.

  PERFORM ADD_TEXT_COMMON USING LO_COL_KEY LO_COL_SEP LO_COL_VAL LO_TABLE         "주문유형
                                ZGTSD_S %_S_AUART_%_APP_%-TEXT 'S_AUART[]'.

  PERFORM ADD_TEXT_COMMON USING LO_COL_KEY LO_COL_SEP LO_COL_VAL LO_TABLE         "영업팀
                                ZGTSD_S %_S_VKBUR_%_APP_%-TEXT 'S_VKBUR[]'.

  PERFORM ADD_TEXT_COMMON USING LO_COL_KEY LO_COL_SEP LO_COL_VAL LO_TABLE         "SO
                                ZGTSD_S %_S_VBELN_%_APP_%-TEXT 'S_VBELN[]'.

*  PERFORM ADD_TEXT_COMMON USING LO_COL_KEY LO_COL_SEP LO_COL_VAL LO_TABLE         "자재
*                                ZGTSD_S %_S_MATNR_%_APP_%-TEXT 'S_MATNR[]'.

  PERFORM ADD_TEXT_COMMON USING LO_COL_KEY LO_COL_SEP LO_COL_VAL LO_TABLE         "기준일
                                ZGTSD_S %_S_UDATE_%_APP_%-TEXT 'S_UDATE[]'.

*  PERFORM CONVERSION_EXIT_PERI_OUTPUT USING P_SPMON CHANGING LV_TEXT.
*  PERFORM ADD_TEXT_COMMON USING LO_COL_KEY LO_COL_SEP LO_COL_VAL LO_TABLE         "마감 기준 연월
*                                ZGTSD_P TEXT-S12 LV_TEXT.
*
*  "AUC 생성
*  IF CB_COMP = ZPS01_X.
*    LV_TEXT = TEXT-S13.
*  ENDIF.
*  IF CB_INCOM = ZPS01_X.
*    LV_TEXT = COND #( WHEN LV_TEXT IS INITIAL THEN TEXT-S14
*                                              ELSE LV_TEXT && `, ` && TEXT-S14 ).
*  ENDIF.

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
*& Form SEARCH_HELP_VBKUR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> TEXT_S02
*&      --> P_
*&      <-- S_VKBUR_LOW
*&---------------------------------------------------------------------*
FORM SEARCH_HELP_VKBUR  USING PV_TITLE
                              PV_RETFIELD
                     CHANGING PV_CODE.
  DATA : BEGIN OF LS_CODE,
           VKBUR TYPE VKBUR,
           BEZEI TYPE TVKBT-BEZEI,
         END OF LS_CODE,
         LT_CODE LIKE TABLE OF LS_CODE.

  "Get Data
  LT_CODE[] = CORRESPONDING #( GT_VKBUR[] MAPPING VKBUR = FLD_01
                                                  BEZEI = FLD_02 ).

  "Call F4 Help
  PERFORM F4IF_INT_TABLE_VALUE_REQUEST TABLES   LT_CODE
                                       USING    PV_RETFIELD
                                                PV_TITLE
                                                SPACE
                                       CHANGING PV_CODE.

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
*& Form SEND_MAIL
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SEND_MAIL USING PV_TYPE.

  DATA : LV_DATE            TYPE CHAR20,
         LV_ANSWER          TYPE C,
         LV_STS             TYPE C,
         LV_TEXT            TYPE NATXT,
         LV_ATT_SIZE        TYPE SOOD-OBJLEN,
         LT_ATT_CONTENT_HEX TYPE SOLIX_TAB,
         LV_ATT_LINE        TYPE STRING,
         L_ADDRESS2         TYPE ADR6-SMTP_ADDR,
         LT_RECIP           TYPE TABLE OF ZGTPPT1010,
         LV_ERR             TYPE CHAR01,
         LT_JOIN            LIKE TABLE OF GS_S0100 WITH EMPTY KEY,
         LS_1001            TYPE ZGTSDT1001,
         LT_1001            TYPE TABLE OF ZGTSDT1001.

  DATA(LT_TMP) = GT_S0100[].
  SORT LT_TMP BY STATU.
  DELETE LT_TMP WHERE STATU NE ICON_LED_RED.
  IF LT_TMP[] IS INITIAL.
    MESSAGE S000 WITH TEXT-E02 DISPLAY LIKE 'E'.
    EXIT.
  ENDIF.
  SORT LT_TMP BY VKBUR.
  DELETE  ADJACENT DUPLICATES FROM LT_TMP COMPARING VKBUR.

  "수신자.
  LT_JOIN = CORRESPONDING #( LT_TMP ).
  SELECT B~FLD_01, B~FLD_02, B~FLD_03, B~FLD_04
    FROM @LT_JOIN AS A INNER JOIN ZGTPPT1010 AS B
      ON A~VKBUR = B~FLD_01
   WHERE B~MODULE_KIND EQ 'SD'
     AND B~CODEGRP EQ '5002'
    INTO TABLE @DATA(LT_REC).
  IF LT_REC[] IS INITIAL.
    IF PV_TYPE IS NOT INITIAL.
      WRITE :/ '메일 수신 대상자를 찾지 못했습니다.' .
    ELSE.
      MESSAGE S000 WITH '메일 수신 대상자를 찾지 못했습니다.' DISPLAY LIKE 'E'.
    ENDIF.
    EXIT.
  ENDIF.

  IF PV_TYPE IS INITIAL.
    CLEAR LV_ANSWER.
    CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
      EXPORTING
        TEXTLINE1      = TEXT-T02
        TEXTLINE2      = TEXT-T03
        TITEL          = TEXT-F00
        CANCEL_DISPLAY = ' '
      IMPORTING
        ANSWER         = LV_ANSWER.

    CHECK LV_ANSWER EQ ZGTSD_J.
  ENDIF.

  LOOP AT LT_TMP INTO DATA(LS_VKBUR).

    CLEAR : LV_ATT_LINE.
    __CLE : GT_BODY, LT_RECIP.

    LT_RECIP[] = VALUE #( FOR LS_VAL IN LT_REC WHERE ( FLD_01 = LS_VKBUR-VKBUR )
                                 ( FLD_01 = LS_VAL-FLD_01
                                   FLD_02 = LS_VAL-FLD_02
                                   FLD_03 = LS_VAL-FLD_03
                                   FLD_04 = LS_VAL-FLD_04 ) ).
    IF LT_RECIP[] IS INITIAL.
      IF PV_TYPE IS NOT INITIAL.
        WRITE :/ '영업팀 :', LS_VKBUR-VKBUR, '메일 수신 대상자를 찾지 못했습니다.' .
      ENDIF.
      LV_ERR = ZGTSD_X. CONTINUE.
    ENDIF.

*___ 메일 내용
    PERFORM APPEND_BODY USING  :
          '<BODY STYLE="FONT-SIZE: 11PT; FONT-FAMILY: 맑은 고딕;">',
          TEXT-F13,    "해당 메일은 주문 변경 이력이 발생되어 발송되는 시스템 자동 메일 입니다.
          '<BR><BR>'.

    PERFORM APPEND_BODY USING  :'<BR> '.
    PERFORM APPEND_BODY USING  :
          '<BODY STYLE="FONT-SIZE: 11PT; FONT-FAMILY: 맑은 고딕;">',
          TEXT-F14,   "[ 주문 변경 이력 ]
          '   <BR> '.

*___ 테이블 헤더
    PERFORM APPEND_BODY USING  :
  '<TABLE STYLE="BORDER-COLLAPSE:COLLAPSE; MSO-BORDER-LEFT-ALT: SOLIDBLACK0.25PT;'.
    PERFORM APPEND_BODY USING
          :  ' MSO-BORDER-TOP-ALT:SOLIDBLACK0.25PT; MSO-BORDER-RIGHT-ALT: SOLID BLACK 0.25PT;'.
    PERFORM APPEND_BODY USING
          :  ' MSO-BORDER-BOTTOM-ALT:SOLIDBLACK0.25PT;FONT-SIZE: 11PT; FONT-FAMILY: 맑은 고딕;'.
    PERFORM APPEND_BODY USING
          :  ' MSO-PADDING-ALT: 3PT 0PT3PT0PT"CELLSPACING=8 CELLPADDING=8 BORDER=1>'.
    PERFORM APPEND_BODY USING
          :  '<STYLE>TH,TD{PADDING:10PX;}</STYLE>'.
    PERFORM APPEND_BODY USING
          :  ' <TR BGCOLOR='' '' STYLE='' BORDER:1.1SOLID BLACK''>'.
    PERFORM APPEND_HTML_TD USING :  'B' TEXT-F02,
                                    'B' TEXT-F17,
                                    'B' TEXT-F03,
                                    'B' TEXT-F04,
                                    'B' TEXT-F05,
                                    'B' TEXT-F06,
                                    'B' TEXT-F06,
                                    'B' TEXT-F07,
                                    'B' TEXT-F08,
                                    'B' TEXT-F09,
                                    'B' TEXT-F10.
    PERFORM APPEND_BODY USING  :  ' </TR>'.

*___ 테이블 내용
    LOOP AT GT_S0100 INTO GS_S0100 WHERE STATU = ICON_LED_RED
                                     AND VKBUR = LS_VKBUR-VKBUR.
      PERFORM APPEND_BODY USING  :  ' <TR>'.
      PERFORM APPEND_HTML_TD USING : '' GS_S0100-VBELN.
      PERFORM APPEND_HTML_TD USING : '' GS_S0100-POSNR.
      PERFORM APPEND_HTML_TD USING : '' GS_S0100-UDATE.
      PERFORM APPEND_HTML_TD USING : '' GS_S0100-UTIME.
      PERFORM APPEND_HTML_TD USING : '' GS_S0100-USERNAME.
      PERFORM APPEND_HTML_TD USING : '' GS_S0100-FNAME.
      PERFORM APPEND_HTML_TD USING : '' GS_S0100-FTEXT.
      PERFORM APPEND_HTML_TD USING : '' GS_S0100-VALUE_OLD.
      PERFORM APPEND_HTML_TD USING : '' GS_S0100-VALUE_OLD_NM.
      PERFORM APPEND_HTML_TD USING : '' GS_S0100-VALUE_NEW.
      PERFORM APPEND_HTML_TD USING : '' GS_S0100-VALUE_NEW_NM.
      PERFORM APPEND_BODY USING  :  ' </TR>'.
    ENDLOOP.

*___ 테이블 종료
    PERFORM APPEND_BODY USING  :  '</TABLE>'.

*    PERFORM APPEND_BODY USING  :
*          '<BR>',
*          '※ T-CODE : ZSD1R0470에서 판매 오더에 대해 승인 처리 하시기 바랍니다.<BR>',
*          '※ 승인이 완료되지 않을 경우 출하가 불가능 합니다.<BR>'.

    PERFORM MAKE_ATTACH_CONTENTS USING LV_ATT_LINE.


    TRY.
        CLEAR GV_SUBJECT.
        IF S_UDATE-HIGH IS INITIAL.
          WRITE S_UDATE-LOW TO LV_DATE.
          CONCATENATE '[' LV_DATE ']' TEXT-F15 INTO  GV_SUBJECT  .
        ELSE.
          WRITE S_UDATE-LOW TO GV_SUBJECT.
          WRITE S_UDATE-HIGH TO LV_DATE.
          CONCATENATE GV_SUBJECT ` ~ `  LV_DATE INTO GV_SUBJECT SEPARATED BY SPACE.
          CONCATENATE '[' GV_SUBJECT ']' TEXT-F15 INTO  GV_SUBJECT SEPARATED BY SPACE.
        ENDIF.

        G_EMAIL = CL_BCS=>CREATE_PERSISTENT( ).
        G_EMAIL_BODY = CL_DOCUMENT_BCS=>CREATE_DOCUMENT(
                        I_TYPE    = 'HTM'
                        I_TEXT    = GT_BODY
                        I_SUBJECT = GV_SUBJECT ).
        G_EMAIL->SET_DOCUMENT( G_EMAIL_BODY ).

        LOOP AT LT_RECIP INTO DATA(LS_REC).

          L_ADDRESS2 = LS_REC-FLD_04. "이메일 주소
          G_RECEIVER = CL_CAM_ADDRESS_BCS=>CREATE_INTERNET_ADDRESS( I_ADDRESS_STRING = L_ADDRESS2 ).
          G_EMAIL->ADD_RECIPIENT( I_RECIPIENT = G_RECEIVER
                                  I_EXPRESS   = 'X' ).

        ENDLOOP.

        "발신자
*      G_SENDER = CL_CAM_ADDRESS_BCS=>CREATE_INTERNET_ADDRESS( I_ADDRESS_STRING = L_ADDRESS2 ).
        G_EMAIL->SET_SENDER( I_SENDER = G_SENDER ).
        G_EMAIL->SET_SEND_IMMEDIATELY( GC_X ).

**********************************************************************
        DATA(LO_GBT)     = NEW CL_GBT_MULTIRELATED_SERVICE( ).
        DATA(LO_DOC_BCS) = NEW CL_DOCUMENT_BCS( ).

        LO_GBT->SET_MAIN_HTML(
           EXPORTING
             CONTENT     = GT_BODY ).

        LO_DOC_BCS = CL_DOCUMENT_BCS=>CREATE_FROM_MULTIRELATED(
                       I_SUBJECT          = GV_SUBJECT
                       I_MULTIREL_SERVICE = LO_GBT ).

        CL_BCS_CONVERT=>STRING_TO_SOLIX(
           EXPORTING
             IV_STRING   = LV_ATT_LINE
             IV_CODEPAGE = '4103'
             IV_ADD_BOM  = 'X'
           IMPORTING
             ET_SOLIX    = LT_ATT_CONTENT_HEX
             EV_SIZE     = LV_ATT_SIZE ).

        LO_DOC_BCS->ADD_ATTACHMENT(
          EXPORTING
            I_ATTACHMENT_TYPE     = 'XLS'
            I_ATTACHMENT_SUBJECT  = 'ATTAHMENET_NAME'
            I_ATTACHMENT_SIZE     = LV_ATT_SIZE
            I_ATT_CONTENT_HEX     = LT_ATT_CONTENT_HEX ).

        "Set document
        G_EMAIL->SET_DOCUMENT( I_DOCUMENT = LO_DOC_BCS ).
        G_EMAIL->SET_STATUS_ATTRIBUTES( I_REQUESTED_STATUS = 'N' ).

**********************************************************************

        G_EMAIL->SEND( EXPORTING I_WITH_ERROR_SCREEN = GC_X
                       RECEIVING RESULT = GV_SEND_RESULT ).

        COMMIT WORK.

        WAIT UP TO 2 SECONDS.
        G_EMAIL->GET_SR_STATUS( IMPORTING EV_STATUS = LV_STS
                                          EV_TEXT   = LV_TEXT ).
        DATA(LV_ATT) = G_EMAIL->SEND_REQUEST.
        DATA(LV_KEY) = LV_ATT->GET_SCOM_KEY( ).

**********************************************************************
* 로그 테이블
**********************************************************************

        CLEAR LS_1001.
        IF LV_KEY IS NOT INITIAL.

          SELECT SINGLE RECTP, RECYR, RECNO, SCDATE, SCTIME
            INTO CORRESPONDING FIELDS OF @LS_1001
            FROM SOES
           WHERE RECTP = @LV_KEY(3)
             AND RECYR = @LV_KEY+3(2)
             AND RECNO = @LV_KEY+5(12).

          LOOP AT GT_S0100 INTO GS_S0100 WHERE STATU = ICON_LED_RED
                                           AND VKBUR = LS_VKBUR-VKBUR.

            GS_S0100-RECTP = LS_1001-RECTP.
            GS_S0100-RECYR = LS_1001-RECYR.
            GS_S0100-RECNO = LS_1001-RECNO.

            IF LS_1001-SCDATE IS NOT INITIAL.
              GS_S0100-STATU     = ICON_LED_GREEN.
              GS_S0100-SEND_DATE = LS_1001-SCDATE.
              GS_S0100-SEND_TIME = LS_1001-SCTIME.
            ELSE.
              GS_S0100-STATU = ICON_LED_YELLOW.
            ENDIF.

            MODIFY GT_S0100 FROM GS_S0100.

            LS_1001-UDATE = GS_S0100-UDATE.
            LS_1001-VBELN = GS_S0100-VBELN.
            LS_1001-VKORG = GS_S0100-VKORG.
            LS_1001-AUART = GS_S0100-AUART.
            LS_1001-VKBUR = GS_S0100-VKBUR.
            LS_1001-MATNR = GS_S0100-MATNR.
            ZGTSD_CL_COMMON=>SET_TIMESTAMP( EXPORTING IV_GUBUN     = ZGTSD_C
                                    CHANGING  CS_TIMESTAMP = LS_1001-TIMESTAMP ).

            APPEND LS_1001 TO LT_1001.
          ENDLOOP.

        ELSE.
          LV_ERR = ZGTSD_X.
          IF PV_TYPE IS NOT INITIAL.
            WRITE :/ '영업팀 :', LS_VKBUR-VKBUR, TEXT-E01.
*          MESSAGE S000 WITH TEXT-E01 DISPLAY LIKE 'E'.
          ENDIF.
        ENDIF.
      CATCH CX_ROOT INTO DATA(LO_EX). "G_EXCEPTION.
        EXIT.
    ENDTRY.

    IF PV_TYPE IS NOT INITIAL.
      WRITE :/ '영업팀 :', LS_VKBUR-VKBUR, 'SO 변경 메일발송 성공'.
    ENDIF.
  ENDLOOP.

  IF LT_1001[] IS NOT INITIAL.
    MODIFY ZGTSDT1001 FROM TABLE LT_1001.
    MESSAGE S000 WITH TEXT-M01.
  ELSE.
    MESSAGE S000 WITH TEXT-E01 DISPLAY LIKE 'E'.
  ENDIF.

  IF PV_TYPE IS INITIAL.
    PERFORM REFRESH_TABLE_DISPLAY USING GO_GRID SPACE.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  APPEND_BODY
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_TEXT     text
*----------------------------------------------------------------------*
FORM APPEND_BODY USING P_TEXT.


  DATA : LS_MSG   TYPE SO_TEXT255.
  LS_MSG = P_TEXT.
  APPEND LS_MSG TO GT_BODY. CLEAR LS_MSG.


ENDFORM.                    "APPEND_BODY
*&---------------------------------------------------------------------*
*&      Form  APPEND_HTML_TD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_TEXT     text
*----------------------------------------------------------------------*
FORM APPEND_HTML_TD  USING  P_BOLD P_TEXT.

  DATA : LV_LINE(100).

  CASE P_BOLD.
    WHEN 'B'.
      LV_LINE = '<B>' && P_TEXT .
    WHEN OTHERS.
      LV_LINE =  P_TEXT .
  ENDCASE.

  CONDENSE : LV_LINE.
  CONCATENATE GV_LINE '<TD>'  LV_LINE '</TD>' INTO  GV_LINE .
  PERFORM APPEND_BODY USING GV_LINE .
  CLEAR GV_LINE.

ENDFORM.                    "APPEND_HTML_TD
*&---------------------------------------------------------------------*
*&      Form  APPEND_HTML_TD_ROWSPAN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_TEXT     text
*      -->P_ROWS     text
*----------------------------------------------------------------------*
FORM APPEND_HTML_TD_ROWSPAN USING  P_TEXT
                                   P_ROWS.

  DATA : LV_LINE(100).

  LV_LINE =  P_TEXT .
  CONDENSE : LV_LINE, P_ROWS.
  CONCATENATE GV_LINE '<TD ROWSPAN=''' P_ROWS '''>'  LV_LINE '</TD>'
  INTO  GV_LINE .
  PERFORM APPEND_BODY USING GV_LINE .
  CLEAR GV_LINE.

ENDFORM.                    "APPEND_HTML_TD
*&---------------------------------------------------------------------*
*& Form MAKE_ATTACH_CONTENTS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LV_ATT_LINE
*&---------------------------------------------------------------------*
FORM MAKE_ATTACH_CONTENTS  USING    PV_ATT_LINE.


  "Create TABLE contents for XLS
  CONCATENATE TEXT-F14 GC_CRLF GC_CRLF INTO PV_ATT_LINE.

  CONCATENATE PV_ATT_LINE TEXT-F02   GC_TAB
                          TEXT-F17   GC_TAB
                          TEXT-F03   GC_TAB
                          TEXT-F04   GC_TAB
                          TEXT-F05   GC_TAB
                          TEXT-F06   GC_TAB
                          TEXT-F06   GC_TAB
                          TEXT-F07   GC_TAB
                          TEXT-F08   GC_TAB
                          TEXT-F09   GC_TAB
                          TEXT-F10   GC_CRLF INTO PV_ATT_LINE.


  LOOP AT GT_S0100 INTO GS_S0100 WHERE STATU = ICON_LED_RED.

    CONCATENATE PV_ATT_LINE
                GS_S0100-VBELN         GC_TAB
                GS_S0100-POSNR         GC_TAB
                GS_S0100-UDATE         GC_TAB
                GS_S0100-UTIME         GC_TAB
                GS_S0100-USERNAME      GC_TAB
                GS_S0100-FNAME         GC_TAB
                GS_S0100-FTEXT         GC_TAB
                GS_S0100-VALUE_OLD     GC_TAB
                GS_S0100-VALUE_OLD_NM  GC_TAB
                GS_S0100-VALUE_NEW     GC_TAB
                GS_S0100-VALUE_NEW_NM  GC_CRLF INTO PV_ATT_LINE.

  ENDLOOP.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form SEARCH_HELP_AUART
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> TEXT_S03
*&      --> P_
*&      <-- S_AUART_LOW
*&---------------------------------------------------------------------*
FORM SEARCH_HELP_AUART  USING PV_TITLE
                              PV_RETFIELD
                     CHANGING PV_CODE.

  DATA : BEGIN OF LS_CODE,
           AUART TYPE AUART,
           BEZEI TYPE TVAKT-BEZEI,
         END OF LS_CODE,
         LT_CODE LIKE TABLE OF LS_CODE.

  "Get Data
  LT_CODE[] = CORRESPONDING #( GT_AUART[] MAPPING AUART = FLD_03
                                                  BEZEI = FLD_04 ).
  SORT LT_CODE BY AUART.
  DELETE ADJACENT DUPLICATES FROM LT_CODE COMPARING AUART.

  "Call F4 Help
  PERFORM F4IF_INT_TABLE_VALUE_REQUEST TABLES   LT_CODE
                                       USING    PV_RETFIELD
                                                PV_TITLE
                                                SPACE
                                       CHANGING PV_CODE.

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
      CHECK GS_S0100-VBELN IS NOT INITIAL.
      SET PARAMETER ID: 'AUN'    FIELD   GS_S0100-VBELN.
      CALL TRANSACTION  'VA03' AND SKIP FIRST SCREEN.

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

  PERFORM SET_SORT_FIELD USING: PT_SORT 'VKBUR' GC_X '' '',
                                PT_SORT 'VBELN' GC_X '' '',
                                PT_SORT 'POSNR' GC_X '' '',
                                PT_SORT 'UDATE' GC_X '' '',
                                PT_SORT 'UTIME' GC_X '' ''.

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
