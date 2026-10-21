*&---------------------------------------------------------------------*
*& Include          ZGTPPI4090F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form initialization
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM INITIALIZATION.

  P_INSMM = SY-DATUM+0(6).

  IF GT_DDLB IS INITIAL.
    GT_ZGTPPT1010 = ZGTPP_CL_COMMON=>GET_CODE_VALUE( IV_CODEGRP = '0010' ).

    LOOP AT GT_ZGTPPT1010 INTO DATA(LS_CODE).
      CHECK LS_CODE-FLD_03(1) EQ '6' AND LS_CODE-FLD_04 IS NOT INITIAL.

      APPEND VALUE #( KEY  = LS_CODE-FLD_01
                      TEXT = LS_CODE-FLD_02 ) TO GT_DDLB.
    ENDLOOP.

    SORT GT_DDLB BY KEY.
    DELETE ADJACENT DUPLICATES FROM GT_DDLB COMPARING KEY.
    SORT GT_DDLB BY TEXT.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form start_of_selection
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM START_OF_SELECTION.

  PERFORM SET_SEARCH_CONDITION.

  CASE ABAP_TRUE.
    WHEN P_SEND. "// 전송.
      PERFORM GET_PHYSICAL_INVENTORY.

    WHEN P_LOG.  "// 로그조회.
      PERFORM GET_TRANSFER_LOG.
  ENDCASE.

  PERFORM SET_FIRST_DATA.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form end_of_selection
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM END_OF_SELECTION .

  IF GT_HEADER IS NOT INITIAL.
    IF P_BATCH IS INITIAL.
      PERFORM CALL_SCREEN_100.
    ELSE.
      PERFORM USER_COMMAND_SEND.
    ENDIF.
  ELSE.
    MESSAGE S033.
    LEAVE LIST-PROCESSING.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form user_command_exit
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM USER_COMMAND_EXIT .

  IF GR_HEADER IS BOUND.
    GR_HEADER->FREE( ).
    CLEAR GR_HEADER.
  ENDIF.

  IF GR_DETAIL IS BOUND.
    GR_DETAIL->FREE( ).
    CLEAR GR_DETAIL.
  ENDIF.

  LEAVE TO SCREEN 0.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form confirmation_popup
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM CONFIRMATION_POPUP USING PV_QUESTION PV_ANSWER.

  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      TITLEBAR       = TEXT-C01
      TEXT_QUESTION  = PV_QUESTION
    IMPORTING
      ANSWER         = PV_ANSWER
    EXCEPTIONS
      TEXT_NOT_FOUND = 1
      OTHERS         = 2.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form handle_field_catalog
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM HANDLE_FIELD_CATALOG USING PR_SENDER.

  IF PR_SENDER EQ GR_HEADER.
    PERFORM MODIFY_FCAT_IN_HEADER.
  ENDIF.

  IF PR_SENDER EQ GR_DETAIL.
    PERFORM MODIFY_FCAT_IN_DETAIL.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form handle_layout
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM HANDLE_LAYOUT USING PR_SENDER.

  TRY.
*      gr_list->ms_layout-cwidth_opt = abap_false.

    CATCH CX_ROOT.

  ENDTRY.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form handle_double_click
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM HANDLE_DOUBLE_CLICK USING PR_SENDER
                               PS_ROW    TYPE LVC_S_ROID
                               PS_COLUMN TYPE LVC_S_COL.

  IF GR_HEADER IS BOUND AND PR_SENDER EQ GR_HEADER->MR_GRID.
    PERFORM DOUBLE_CLICK_IN_HEADER USING PS_ROW PS_COLUMN.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form at_selection_screen_output
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM AT_SELECTION_SCREEN_OUTPUT .

  CALL FUNCTION 'VRM_SET_VALUES'
    EXPORTING
      ID              = 'P_SYSID'
      VALUES          = GT_DDLB
    EXCEPTIONS
      ID_ILLEGAL_NAME = 1
      OTHERS          = 2.

  LOOP AT SCREEN INTO DATA(LS_SCREEN).
    CASE LS_SCREEN-GROUP1.
      WHEN 'SND'.
        IF P_SEND EQ ABAP_FALSE.
          LS_SCREEN-ACTIVE = 0.
          MODIFY SCREEN FROM LS_SCREEN.
        ENDIF.

      WHEN 'LOG'.
        IF P_LOG EQ ABAP_FALSE.
          LS_SCREEN-ACTIVE = 0.
          MODIFY SCREEN FROM LS_SCREEN.
        ENDIF.
    ENDCASE.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form at_selection_screen
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM AT_SELECTION_SCREEN .

  CASE SSCRFIELDS-UCOMM.
*// 실행.
    WHEN GC_FCODE-ONLI.
      PERFORM CHECK_SEL_SCREEN_INPUT_VALUE.
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form check_sel_screen_input_value
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM CHECK_SEL_SCREEN_INPUT_VALUE.

  IF P_SYSID IS INITIAL.
    MESSAGE E000 WITH TEXT-E01 DISPLAY LIKE 'S'.
  ENDIF.

  IF P_INSMM IS INITIAL.
    MESSAGE E000 WITH TEXT-E03 DISPLAY LIKE 'S'.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form call_screen_100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM CALL_SCREEN_100 .

  GV_TPAR1 = COND #( WHEN P_SEND EQ ABAP_TRUE THEN TEXT-C11
                     ELSE TEXT-C12 ).

  CALL SCREEN 100.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form modify_fcat_in_header
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM MODIFY_FCAT_IN_HEADER.

  LOOP AT GR_HEADER->MT_FCAT REFERENCE INTO DATA(LR_FCAT).
    LR_FCAT->COL_OPT = 'A'.

    CASE LR_FCAT->FIELDNAME.
      WHEN 'ZIFKEY'.
        LR_FCAT->COLTEXT    = TEXT-F00.
        LR_FCAT->TECH       = COND #( WHEN P_SEND EQ ABAP_TRUE THEN ABAP_TRUE ).
        LR_FCAT->EMPHASIZE  = 'C100'.

      WHEN 'STATUS'.
        LR_FCAT->COLTEXT    = TEXT-F01.
        LR_FCAT->JUST       = 'C'.

      WHEN 'ZMESSAGE'.
        LR_FCAT->COLTEXT    = TEXT-F02.

      WHEN 'ZSYSTEM_ID'.
        LR_FCAT->COLTEXT    = TEXT-F03.
        LR_FCAT->JUST       = 'C'.
        LR_FCAT->EMPHASIZE  = 'C100'.

      WHEN 'ZSYSTEM_DESC'.
        LR_FCAT->COLTEXT    = TEXT-F04.
        LR_FCAT->EMPHASIZE  = 'C100'.

      WHEN 'INSMM'.
        LR_FCAT->COLTEXT    = TEXT-F05.
        LR_FCAT->JUST       = 'C'.
        LR_FCAT->EMPHASIZE  = 'C100'.

      WHEN 'WERKS'.
        LR_FCAT->COLTEXT    = TEXT-F06.
        LR_FCAT->JUST       = 'C'.
        LR_FCAT->EMPHASIZE  = 'C100'.

      WHEN 'NAME1'.
        LR_FCAT->COLTEXT    = TEXT-F07.
        LR_FCAT->EMPHASIZE  = 'C100'.

      WHEN 'LGORT'.
        LR_FCAT->COLTEXT    = TEXT-F08.
        LR_FCAT->JUST       = 'C'.
        LR_FCAT->EMPHASIZE  = 'C100'.

      WHEN 'LGOBE'.
        LR_FCAT->COLTEXT    = TEXT-F09.
        LR_FCAT->EMPHASIZE  = 'C100'.

      WHEN 'ZCOUNT'.
        LR_FCAT->COLTEXT    = TEXT-F10.
        LR_FCAT->EMPHASIZE  = 'C100'.

      WHEN 'MATNR'.
        LR_FCAT->COLTEXT    = TEXT-F11.
        LR_FCAT->EMPHASIZE  = 'C100'.

      WHEN 'MAKTX'.
        LR_FCAT->COLTEXT    = TEXT-F12.
        LR_FCAT->EMPHASIZE  = 'C100'.

      WHEN 'SEQNO'.
        LR_FCAT->COLTEXT    = TEXT-F27.
        LR_FCAT->EMPHASIZE  = 'C100'.

      WHEN 'CHARG'.
        LR_FCAT->COLTEXT    = TEXT-F13.
        LR_FCAT->EMPHASIZE  = 'C110'.

      WHEN 'ITYPE'.
        LR_FCAT->COLTEXT    = TEXT-F14.
        LR_FCAT->JUST       = 'C'.
        LR_FCAT->EMPHASIZE  = 'C500'.

      WHEN 'ITYPE_TXT'.
        LR_FCAT->COLTEXT    = TEXT-F15.
        LR_FCAT->EMPHASIZE  = 'C500'.

      WHEN 'MENGE'.
        LR_FCAT->COLTEXT    = TEXT-F16.

      WHEN 'MEINS'.
        LR_FCAT->COLTEXT    = TEXT-F17.
        LR_FCAT->JUST       = 'C'.

      WHEN 'SPGCD'.
        LR_FCAT->COLTEXT    = TEXT-F18.
        LR_FCAT->JUST       = 'C'.

      WHEN 'VBELN'.
        LR_FCAT->COLTEXT    = TEXT-F19.
        LR_FCAT->JUST       = 'C'.

      WHEN 'POSNR'.
        LR_FCAT->COLTEXT    = TEXT-F20.
        LR_FCAT->JUST       = 'C'.

      WHEN 'SDATE'.
        LR_FCAT->COLTEXT    = TEXT-F21.
        LR_FCAT->JUST       = 'C'.

      WHEN OTHERS.
        LR_FCAT->TECH = ABAP_TRUE.
    ENDCASE.

    LR_FCAT->TOOLTIP = LR_FCAT->REPTEXT = LR_FCAT->COLTEXT.
    LR_FCAT->SCRTEXT_S = LR_FCAT->SCRTEXT_M = LR_FCAT->SCRTEXT_L = LR_FCAT->COLTEXT.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form split_screen_layout
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM SPLIT_SCREEN_LAYOUT .

  TRY.
      GR_DOCKING_CONTAINER = NEW #( PARENT    = CL_GUI_CONTAINER=>SCREEN0
                                    SIDE      = 2
                                    EXTENSION = 2000 ).

      GR_SPLITTER_CONTAINER = NEW #( PARENT  = GR_DOCKING_CONTAINER
                                     ROWS    = 2
                                     COLUMNS = 1 ).

      GR_SPLITTER_CONTAINER->SET_ROW_HEIGHT( ID = 1 HEIGHT = 70 ).

      GR_SPLITTER_CONTAINER->SET_ROW_SASH( ID    = 1
                                           TYPE  = CL_GUI_SPLITTER_CONTAINER=>TYPE_SASHVISIBLE
                                           VALUE = CL_GUI_SPLITTER_CONTAINER=>TRUE ).

      GR_SPLITTER_CONTAINER->SET_ROW_SASH( ID    = 1
                                           TYPE  = CL_GUI_SPLITTER_CONTAINER=>TYPE_MOVABLE
                                           VALUE = CL_GUI_SPLITTER_CONTAINER=>TRUE ).

      GR_TOP_CONTAINER = GR_SPLITTER_CONTAINER->GET_CONTAINER( ROW = 1 COLUMN = 1 ).
      GR_BOTTOM_CONTAINER = GR_SPLITTER_CONTAINER->GET_CONTAINER( ROW = 2 COLUMN = 1 ).

    CATCH CX_ROOT INTO DATA(LR_ROOT).
      MESSAGE LR_ROOT->GET_TEXT( ) TYPE 'I' DISPLAY LIKE 'E'.
  ENDTRY.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form modify_fcat_in_detail
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM MODIFY_FCAT_IN_DETAIL .

  LOOP AT GR_DETAIL->MT_FCAT REFERENCE INTO DATA(LR_FCAT).
    LR_FCAT->COL_OPT = 'A'.

    CASE LR_FCAT->FIELDNAME.
      WHEN 'ZIFKEY'.
        LR_FCAT->COLTEXT    = TEXT-F00.
        LR_FCAT->TECH       = COND #( WHEN P_SEND EQ ABAP_TRUE THEN ABAP_TRUE ).
        LR_FCAT->EMPHASIZE  = 'C100'.

      WHEN 'INSMM'.
        LR_FCAT->COLTEXT    = TEXT-F22.
        LR_FCAT->JUST       = 'C'.
        LR_FCAT->EMPHASIZE  = 'C100'.

      WHEN 'WERKS'.
        LR_FCAT->COLTEXT    = TEXT-F06.
        LR_FCAT->JUST       = 'C'.
        LR_FCAT->EMPHASIZE  = 'C100'.

      WHEN 'NAME1'.
        LR_FCAT->COLTEXT    = TEXT-F07.
        LR_FCAT->EMPHASIZE  = 'C100'.

      WHEN 'LGORT'.
        LR_FCAT->COLTEXT    = TEXT-F08.
        LR_FCAT->JUST       = 'C'.
        LR_FCAT->EMPHASIZE  = 'C100'.

      WHEN 'LGOBE'.
        LR_FCAT->COLTEXT    = TEXT-F09.
        LR_FCAT->EMPHASIZE  = 'C100'.

      WHEN 'ZCOUNT'.
        LR_FCAT->COLTEXT    = TEXT-F10.
        LR_FCAT->JUST       = 'C'.
        LR_FCAT->EMPHASIZE  = 'C100'.

      WHEN 'MATNR'.
        LR_FCAT->COLTEXT    = TEXT-F11.
        LR_FCAT->EMPHASIZE  = 'C100'.

      WHEN 'MAKTX'.
        LR_FCAT->COLTEXT    = TEXT-F12.
        LR_FCAT->EMPHASIZE  = 'C100'.

      WHEN 'SEQNO'.
        LR_FCAT->COLTEXT    = TEXT-F27.
        LR_FCAT->JUST       = 'C'.
        LR_FCAT->EMPHASIZE  = 'C100'.

      WHEN 'CHARG'.
        LR_FCAT->COLTEXT    = TEXT-F13.
        LR_FCAT->EMPHASIZE  = 'C110'.

      WHEN 'TAGNR'.
        LR_FCAT->COLTEXT    = TEXT-F23.
        LR_FCAT->JUST       = 'C'.
        LR_FCAT->EMPHASIZE  = 'C110'.

      WHEN 'MGVRG'.
        LR_FCAT->COLTEXT    = TEXT-F24.

      WHEN 'REMAIN'.
        LR_FCAT->COLTEXT    = TEXT-F25.

      WHEN 'MEINS'.
        LR_FCAT->COLTEXT    = TEXT-F26.
        LR_FCAT->JUST       = 'C'.

      WHEN 'SPGCD'.
        LR_FCAT->COLTEXT    = TEXT-F18.
        LR_FCAT->JUST       = 'C'.

      WHEN OTHERS.
        LR_FCAT->TECH = ABAP_TRUE.
    ENDCASE.

    LR_FCAT->TOOLTIP = LR_FCAT->REPTEXT = LR_FCAT->COLTEXT.
    LR_FCAT->SCRTEXT_S = LR_FCAT->SCRTEXT_M = LR_FCAT->SCRTEXT_L = LR_FCAT->COLTEXT.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_physical_inventory
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM GET_PHYSICAL_INVENTORY .
  DATA LT_DETAIL TYPE TY_T_DETAIL.
  DATA LV_ZCOUNT TYPE ZGTPPT4100-ZCOUNT.
  DATA LV_SEQNO1 TYPE ZGTPPT4090-SEQNO.
  DATA LV_SEQNO2 TYPE ZGTPPT4100-SEQNO.

  SELECT ZT01~*,
         ( ZT01~LABST + ZT01~INSME ) AS MENGE,
         CASE WHEN ZT01~ITYPE EQ '1' THEN '플랜트재고'
              WHEN ZT01~ITYPE EQ '2' THEN '배치재고'
              WHEN ZT01~ITYPE EQ '3' THEN '판매오더재고'
         END AS ITYPE_TXT,
         @ICON_LED_INACTIVE AS STATUS,
         MAKT~MAKTX,
         T001W~NAME1, T001L~LGOBE,
         @P_SYSID  AS ZSYSTEM_ID, @GV_SYSTX AS ZSYSTEM_DESC
    FROM ZPPT0601 AS ZT01
    LEFT JOIN MAKT
      ON ZT01~MATNR EQ MAKT~MATNR
     AND MAKT~SPRAS EQ @SY-LANGU
    LEFT JOIN T001W
      ON ZT01~WERKS EQ T001W~WERKS
    LEFT JOIN T001L
      ON ZT01~WERKS EQ T001L~WERKS
     AND ZT01~LGORT EQ T001L~LGORT
   WHERE ZT01~INSMM EQ @P_INSMM
     AND ZT01~WERKS EQ @P_WERKS "IN @GT_WERKS
     AND ZT01~LGORT IN @S_LGORT
     AND ZT01~SDATE IN @S_SDATE
   ORDER BY ZT01~INSMM, ZT01~WERKS, ZT01~LGORT, ZT01~MATNR, ZT01~CHARG
    INTO CORRESPONDING FIELDS OF TABLE @GT_HEADER.

  SELECT ZT01~*,
         B~MATKL,
         MAKT~MAKTX,
         T001W~NAME1, T001L~LGOBE
    FROM ZPPT0602 AS ZT01
    JOIN MARC AS A ON A~MATNR EQ ZT01~MATNR
                  AND A~WERKS EQ ZT01~WERKS
    JOIN MARA AS B ON B~MATNR EQ A~MATNR
    LEFT JOIN MAKT
      ON ZT01~MATNR EQ MAKT~MATNR
     AND MAKT~SPRAS EQ @SY-LANGU
    LEFT JOIN T001W
      ON ZT01~WERKS EQ T001W~WERKS
    LEFT JOIN T001L
      ON ZT01~WERKS EQ T001L~WERKS
     AND ZT01~LGORT EQ T001L~LGORT
   WHERE ZT01~INSMM EQ @P_INSMM
     AND ZT01~WERKS EQ @P_WERKS "IN @GT_WERKS
     AND ZT01~LGORT IN @S_LGORT
     AND A~DPCBT    NE 'A'
   ORDER BY ZT01~INSMM, ZT01~WERKS, ZT01~LGORT, ZT01~MATNR, ZT01~CHARG, ZT01~TAGNR
    INTO CORRESPONDING FIELDS OF TABLE @LT_DETAIL.

  SELECT ZT02~INSMM, ZT02~WERKS, ZT02~LGORT, MAX( ZT02~ZCOUNT ) AS ZCOUNT
    FROM @GT_HEADER AS ZT01
    JOIN ZGTPPT4090 AS ZT02
      ON ZT01~INSMM EQ ZT02~INSMM
     AND ZT01~WERKS EQ ZT02~WERKS
     AND ZT01~LGORT EQ ZT02~LGORT
   GROUP BY ZT02~INSMM, ZT02~WERKS, ZT02~LGORT
   ORDER BY ZT02~INSMM, ZT02~WERKS, ZT02~LGORT
    INTO TABLE @DATA(LT_ZGTPPT4090).

* 자재그룹 RW600101, RW600102 인 경우 하나의 꼬리표만 남기고 나머지는 제외
  DATA: LT_DETAIL1 TYPE TY_T_DETAIL.

  CLEAR: LT_DETAIL1.
  APPEND LINES OF LT_DETAIL TO LT_DETAIL1.

  DELETE LT_DETAIL WHERE MATKL EQ 'RW600101'
                      OR MATKL EQ 'RW600102'.

  DELETE LT_DETAIL1 WHERE MATKL NE 'RW600101'
                      AND MATKL NE 'RW600102'.

  SORT LT_DETAIL1 BY INSMM WERKS LGORT MATNR CHARG.
  DELETE ADJACENT DUPLICATES FROM LT_DETAIL1
                        COMPARING INSMM WERKS LGORT MATNR CHARG.

  APPEND LINES OF LT_DETAIL1 TO LT_DETAIL.

  SORT LT_DETAIL BY INSMM WERKS LGORT MATNR CHARG TAGNR.

  LOOP AT GT_HEADER REFERENCE INTO DATA(LR_HEADER).
    AT NEW LGORT.
      CLEAR: LV_ZCOUNT, LV_SEQNO2.

      READ TABLE LT_ZGTPPT4090 INTO DATA(LS_ZGTPPT4090) WITH KEY INSMM = LR_HEADER->INSMM
                                                                 WERKS = LR_HEADER->WERKS
                                                                 LGORT = LR_HEADER->LGORT BINARY SEARCH.
      IF SY-SUBRC IS INITIAL.
        LV_ZCOUNT = LS_ZGTPPT4090-ZCOUNT + 1.
      ELSE.
        LV_ZCOUNT = '01'.
      ENDIF.
    ENDAT.

    ON CHANGE OF LR_HEADER->MATNR.
      CLEAR: LV_SEQNO1.
    ENDON.

    IF LR_HEADER->CHARG IS INITIAL.
      LV_SEQNO1 = 1.
    ELSE.
      ON CHANGE OF LR_HEADER->CHARG.
        LV_SEQNO1 += 1.
      ENDON.
    ENDIF.

*    LV_SEQNO1 += 1.

    LR_HEADER->ZCOUNT = LV_ZCOUNT.
    LR_HEADER->SEQNO  = LV_SEQNO1.

    "DETAIL 제외 추가
    IF LR_HEADER->WERKS EQ '6500'.
      SELECT SINGLE PDCAPROCCODE
        FROM ZGTCVMSTVAL
       WHERE WERKS EQ @LR_HEADER->WERKS
         AND MATNR EQ @LR_HEADER->MATNR
        INTO @DATA(LV_GONG_CD).

      IF LV_GONG_CD EQ 'BWD'.
        CONTINUE.
      ENDIF.
    ENDIF.

    LOOP AT LT_DETAIL INTO DATA(LS_DETAIL) USING KEY SKEY1
                                           WHERE ZIFKEY EQ LR_HEADER->ZIFKEY
                                             AND INSMM  EQ LR_HEADER->INSMM
                                             AND WERKS  EQ LR_HEADER->WERKS
*                                             AND LGORT  EQ LR_HEADER->LGORT
                                             AND MATNR  EQ LR_HEADER->MATNR
                                             AND CHARG  EQ LR_HEADER->CHARG.
      CHECK LS_DETAIL-TAGNR NE SPACE.

      LV_SEQNO2 += 1.
      LS_DETAIL-ZCOUNT = LV_ZCOUNT.
      LS_DETAIL-SEQNO  = LV_SEQNO1. "LV_SEQNO2.
      LS_DETAIL-REMAIN = LR_HEADER->MENGE.
      APPEND LS_DETAIL TO LR_HEADER->DETAIL.
    ENDLOOP.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_transfer_log
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM GET_TRANSFER_LOG .

  DATA LT_DETAIL TYPE TY_T_DETAIL.

  SELECT ZT01~*,
         CASE WHEN ZT01~ITYPE EQ '1' THEN '플랜트재고'
              WHEN ZT01~ITYPE EQ '2' THEN '배치재고'
              WHEN ZT01~ITYPE EQ '3' THEN '판매오더재고'
         END AS ITYPE_TXT,
         CASE WHEN ZT01~ZSTAT EQ @ZGTPP_IF_CONST=>GC_IF_REC_RESULT-SUCCESS THEN @ICON_LED_GREEN
              WHEN ZT01~ZSTAT EQ @SPACE                                    THEN @ICON_LED_INACTIVE
              ELSE @ICON_LED_RED
         END AS STATUS,
         MAKT~MAKTX,
         T001W~NAME1, T001L~LGOBE,
         @GV_SYSTX AS ZSYSTEM_DESC
    FROM ZGTPPT4090 AS ZT01
    LEFT JOIN MAKT
      ON ZT01~MATNR EQ MAKT~MATNR
     AND MAKT~SPRAS EQ @SY-LANGU
    LEFT JOIN T001W
      ON ZT01~WERKS EQ T001W~WERKS
    LEFT JOIN T001L
      ON ZT01~WERKS EQ T001L~WERKS
     AND ZT01~LGORT EQ T001L~LGORT
   WHERE ZT01~ZSYSTEM_ID EQ @P_SYSID
     AND ZT01~INSMM      EQ @P_INSMM
     AND ZT01~WERKS      EQ @P_WERKS "IN @GT_WERKS
     AND ZT01~LGORT      IN @S_LGORT
     AND ZT01~SDATE      IN @S_SDATE
     AND ZT01~ZSTAT      IN @GT_ZSTAT
     AND ZT01~IFDAT      IN @S_IFDAT
   ORDER BY ZT01~INSMM, ZT01~WERKS, ZT01~LGORT, ZT01~MATNR
    INTO CORRESPONDING FIELDS OF TABLE @GT_HEADER.

  SELECT ZT01~*,
         MAKT~MAKTX,
         T001W~NAME1, T001L~LGOBE
    FROM ZGTPPT4100 AS ZT01
    LEFT JOIN MAKT
      ON ZT01~MATNR EQ MAKT~MATNR
     AND MAKT~SPRAS EQ @SY-LANGU
    LEFT JOIN T001W
      ON ZT01~WERKS EQ T001W~WERKS
    LEFT JOIN T001L
      ON ZT01~WERKS EQ T001L~WERKS
     AND ZT01~LGORT EQ T001L~LGORT
   WHERE ZT01~INSMM EQ @P_INSMM
     AND ZT01~WERKS EQ @P_WERKS "IN @GT_WERKS
     AND ZT01~LGORT IN @S_LGORT
   ORDER BY ZT01~INSMM, ZT01~WERKS, ZT01~LGORT, ZT01~MATNR, ZT01~CHARG, ZT01~TAGNR
    INTO CORRESPONDING FIELDS OF TABLE @LT_DETAIL.

  LOOP AT GT_HEADER REFERENCE INTO DATA(LR_HEADER).
    LR_HEADER->DETAIL = FILTER #( LT_DETAIL USING KEY SKEY1
                                            WHERE ZIFKEY EQ LR_HEADER->ZIFKEY
                                              AND INSMM  EQ LR_HEADER->INSMM
                                              AND WERKS  EQ LR_HEADER->WERKS
                                              AND LGORT  EQ LR_HEADER->LGORT
                                              AND MATNR  EQ LR_HEADER->MATNR
                                              AND CHARG  EQ LR_HEADER->CHARG ).
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_search_condition
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM SET_SEARCH_CONDITION .

  GT_WERKS = VALUE #( FOR LS_ZGTPPT1010 IN GT_ZGTPPT1010 WHERE ( FLD_01 = P_SYSID )
                     ( SIGN = 'I' OPTION = 'EQ' LOW = LS_ZGTPPT1010-FLD_03 ) ).

  GV_SYSTX = VALUE #( GT_DDLB[ KEY = P_SYSID ]-TEXT OPTIONAL ).

  IF P_LOG EQ ABAP_TRUE.
    GT_ZSTAT = COND #( WHEN P_SUC   EQ ABAP_TRUE THEN VALUE #( SIGN = 'I' OPTION = 'EQ' ( LOW = ZGTPP_IF_CONST=>GC_IF_REC_RESULT-SUCCESS ) )
                       WHEN P_ERROR EQ ABAP_TRUE THEN VALUE #( SIGN = 'I' OPTION = 'EQ' ( LOW = ZGTPP_IF_CONST=>GC_IF_REC_RESULT-EAI_ERROR ) ) ).
  ENDIF.

  IF P_SEND EQ ABAP_TRUE.
    READ TABLE GT_ZGTPPT1010 INTO DATA(LS_1010) WITH KEY FLD_01 = P_SYSID
                                                         FLD_03 = P_WERKS.
    IF SY-SUBRC NE 0.
      MESSAGE S003 DISPLAY LIKE 'E'
         WITH TEXT-M01. "전송대상 플랜트가 아닙니다.
      LEAVE LIST-PROCESSING.
    ENDIF.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form user_command_send
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM USER_COMMAND_SEND .

  TRY.
*// 사전점검.
      PERFORM CHECK_BEFORE_SEND.

*// 재고실사 대상 전송.
      PERFORM SEND_PHYSICAL_INVENTORY.

    CATCH LCX_EXCEPTION INTO DATA(LR_EXCEPTION).
      IF LR_EXCEPTION->GET_TEXT( ) IS NOT INITIAL.
        IF SY-BATCH IS NOT INITIAL.
          PERFORM HANDLE_PRINT_TOP_OF_LIST.
          WRITE:/ LR_EXCEPTION->GET_TEXT( ).
        ELSE.
          MESSAGE LR_EXCEPTION->GET_TEXT( ) TYPE 'I' DISPLAY LIKE 'E'.
        ENDIF.
      ENDIF.
  ENDTRY.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form user_command_detail
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM USER_COMMAND_DETAIL .

  GR_HEADER->MR_GRID->GET_SELECTED_ROWS( IMPORTING ET_INDEX_ROWS = DATA(LT_ROWS) ).
  DELETE LT_ROWS WHERE ROWTYPE NE SPACE.

  IF LT_ROWS IS INITIAL.
    RETURN.
  ENDIF.

  CLEAR GT_DETAIL.

  LOOP AT LT_ROWS INTO DATA(LS_ROW).
    READ TABLE GT_HEADER REFERENCE INTO DATA(LR_HEADER) INDEX LS_ROW-INDEX.
    CHECK SY-SUBRC IS INITIAL.

    APPEND LINES OF LR_HEADER->DETAIL TO GT_DETAIL.
  ENDLOOP.

  GR_DETAIL->REFRESH( ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form check_before_send
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM CHECK_BEFORE_SEND RAISING LCX_EXCEPTION.
  DATA LV_ANSWER TYPE C.

  PERFORM GET_ROWS_SELECTED_FOR_SEND.

  IF GS_RESULT-SEL IS INITIAL.
    RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E000 WITH TEXT-E11.
  ENDIF.

  IF GS_RESULT-TOTAL IS INITIAL.
    RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E000 WITH TEXT-E13.
  ENDIF.

  IF P_BATCH IS INITIAL.
    PERFORM CONFIRMATION_POPUP USING TEXT-C04 LV_ANSWER.

    IF LV_ANSWER NE '1'.
      RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E000 WITH SPACE.
    ENDIF.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form send_physical_inventory
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM SEND_PHYSICAL_INVENTORY .

  PERFORM SET_FUNC_PARAMETERS.

  PERFORM CALL_RFC_FUCNTION.

  CHECK GV_EXEC EQ SPACE.
  PERFORM SAVE_TRANSFER_LOG.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form handle_print_top_of_list
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM HANDLE_PRINT_TOP_OF_LIST .

  WRITE:/(sy-linsz) TEXT-H00 CENTERED.

  FORMAT COLOR COL_HEADING.

  ULINE.

  WRITE:/(sy-linsz) |{ ICON_LIST }{ TEXT-H01 } { GS_RESULT-TOTAL   WIDTH = 10 ALIGN = RIGHT NUMBER = USER } { TEXT-H99 }|,
        /(sy-linsz) |{ ICON_LED_GREEN }{ TEXT-H02 } { GS_RESULT-SUCCESS WIDTH = 10 ALIGN = RIGHT NUMBER = USER } { TEXT-H99 }|,
        /(sy-linsz) |{ ICON_LED_RED }{ TEXT-H03 } { GS_RESULT-ERROR   WIDTH = 10 ALIGN = RIGHT NUMBER = USER } { TEXT-H99 }|.

  ULINE.

  FORMAT COLOR OFF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_rows_selected_for_send
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM GET_ROWS_SELECTED_FOR_SEND .

  CLEAR GS_RESULT.

  GS_RESULT = VALUE #( TOTAL = LINES( GT_HEADER )
                       SEL   = GS_RESULT-TOTAL ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_func_parameters
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM SET_FUNC_PARAMETERS .

  CLEAR: GS_PHY_INV, GT_ZGTPPT4090, GT_ZGTPPT4100.

  LOOP AT GT_HEADER INTO DATA(LS_HEADER).
    GET TIME STAMP FIELD LS_HEADER-ZIFKEY.

    MODIFY LS_HEADER-DETAIL FROM VALUE #( ZIFKEY = LS_HEADER-ZIFKEY ) TRANSPORTING ZIFKEY
                            WHERE INSMM EQ LS_HEADER-INSMM.

    GS_PHY_INV-LIST  = VALUE #( BASE GS_PHY_INV-LIST ( CORRESPONDING #( LS_HEADER ) ) ).
    GS_PHY_INV-TAGNR = CORRESPONDING #( BASE ( GS_PHY_INV-TAGNR ) LS_HEADER-DETAIL ).

    GT_ZGTPPT4090 = VALUE #( BASE GT_ZGTPPT4090 ( CORRESPONDING #( LS_HEADER ) ) ).
    GT_ZGTPPT4100 = CORRESPONDING #( BASE ( GT_ZGTPPT4100 ) LS_HEADER-DETAIL ).
  ENDLOOP.

  LOOP AT GS_PHY_INV-LIST REFERENCE INTO DATA(LR_LIST).
    PERFORM CONVERSION_EXIT_MATN1_OUTPUT USING LR_LIST->MATNR.
  ENDLOOP.

  LOOP AT GS_PHY_INV-TAGNR REFERENCE INTO DATA(LR_TAGNR).
    PERFORM CONVERSION_EXIT_MATN1_OUTPUT USING LR_TAGNR->MATNR.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form call_rfc_fucntion
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM CALL_RFC_FUCNTION .

  DATA LV_DESTINATION TYPE ZIFDEST-DEST.
  DATA: LV_CHK(1),
        L_ANSWER  TYPE CHAR01.

  CLEAR: GV_EXEC.

  IF P_BATCH IS INITIAL.
    CLEAR: LV_CHK.
    LOOP AT GS_PHY_INV-LIST REFERENCE INTO DATA(LR_LIST) WHERE ZCOUNT GT 1.
      LV_CHK = 'X'.
      EXIT.
    ENDLOOP.

    IF LV_CHK = 'X'.
      CLEAR: L_ANSWER.
      CALL FUNCTION 'POPUP_TO_CONFIRM'
        EXPORTING
          TEXT_QUESTION         = TEXT-C16
          DISPLAY_CANCEL_BUTTON = SPACE
        IMPORTING
          ANSWER                = L_ANSWER.

      IF L_ANSWER = '1'.
        CLEAR: GV_EXEC.
      ELSE.
        GV_EXEC = 'X'.
      ENDIF.
    ENDIF.

  ENDIF.

  CHECK GV_EXEC EQ SPACE.

  CALL FUNCTION 'Z_IF_DESTINATION'
    EXPORTING
      GUBUN                 = 'P1'
    IMPORTING
      DEST_NAME             = LV_DESTINATION
    EXCEPTIONS
      DESTINATION_NOT_FOUND = 1
      OTHERS                = 2.

  CALL FUNCTION 'ZGTPP_IF_O_PHY_INV_LIST_INFO' DESTINATION LV_DESTINATION
    EXPORTING
      I_SYSTEM_ID           = P_SYSID
    IMPORTING
      ZO_RESULT             = GS_RESULT-ZSTAT
      ZO_MESSAGE            = GS_RESULT-ZMESSAGE
    TABLES
      OT_LIST               = GS_PHY_INV-LIST[]
      OT_TAGNR              = GS_PHY_INV-TAGNR[]
    EXCEPTIONS
      SYSTEM_FAILURE        = 1 MESSAGE GS_RESULT-SYS_MSG
      COMMUNICATION_FAILURE = 2 MESSAGE GS_RESULT-SYS_MSG
      OTHERS                = 3.

  IF SY-SUBRC IS INITIAL AND GS_RESULT-ZSTAT EQ ZGTPP_IF_CONST=>GC_IF_REC_RESULT-SUCCESS.
    GS_RESULT-SUCCESS = GS_RESULT-TOTAL.
    IF GS_RESULT-ZMESSAGE IS INITIAL.
      GS_RESULT-ZMESSAGE = TEXT-S01.
    ENDIF.
  ELSE.
    GS_RESULT-ERROR    = GS_RESULT-TOTAL.
    GS_RESULT-ZMESSAGE = GS_RESULT-SYS_MSG.
    IF GS_RESULT-ZSTAT IS INITIAL.
      GS_RESULT-ZSTAT = ZGTPP_IF_CONST=>GC_IF_REC_RESULT-EAI_ERROR.
    ENDIF.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form save_transfer_log
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM SAVE_TRANSFER_LOG .

  MODIFY GT_ZGTPPT4090 FROM VALUE #( ZSTAT      = GS_RESULT-ZSTAT
                                     ZMESSAGE   = GS_RESULT-ZMESSAGE
                                     IFDAT      = SY-DATUM
                                     IFTIM      = SY-UZEIT
                                     IFNAM      = SY-UNAME  )
                       TRANSPORTING ZSTAT ZMESSAGE IFDAT IFTIM IFNAM
                       WHERE ZSYSTEM_ID EQ P_SYSID.

  TRY.
      MODIFY ZGTPPT4090 FROM TABLE GT_ZGTPPT4090.
      MODIFY ZGTPPT4100 FROM TABLE GT_ZGTPPT4100.

    CATCH CX_ROOT INTO DATA(LR_ROOT).
      DATA(LV_SUBRC) = 4.
  ENDTRY.

  IF LV_SUBRC IS INITIAL.
    COMMIT WORK AND WAIT.
    GV_SAVED = ABAP_TRUE.
  ELSE.
    ROLLBACK WORK.
    MESSAGE E000 WITH TEXT-E02.
  ENDIF.

  MODIFY GT_HEADER FROM VALUE #( STATUS  = COND #( WHEN GS_RESULT-ERROR IS INITIAL THEN ICON_LED_GREEN
                                                   ELSE ICON_LED_RED )
                                 ZSTAT    = GS_RESULT-ZSTAT
                                 ZMESSAGE = GS_RESULT-ZMESSAGE )
                   TRANSPORTING STATUS ZSTAT ZMESSAGE
                   WHERE INSMM EQ P_INSMM.

  IF P_BATCH IS INITIAL.
    IF GR_HEADER IS BOUND.
      GR_HEADER->REFRESH( ).
    ENDIF.
  ELSE.
    GR_HEADER = NEW #( ).
    GR_HEADER->DISPLAY( EXPORTING IR_HANDLER   = NEW LCL_LIST_HANDLER( )
                                  IR_CONTAINER = CL_GUI_CONTAINER=>SCREEN0
                         CHANGING CT_DATA      = GT_HEADER ).
    WRITE:/ SPACE.
  ENDIF.

  MESSAGE S009 WITH GS_RESULT-TOTAL GS_RESULT-SUCCESS GS_RESULT-ERROR.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_first_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM SET_FIRST_DATA .

  SORT GT_HEADER BY ZCOUNT INSMM WERKS LGORT MATNR CHARG.

  GT_DETAIL = VALUE #( GT_HEADER[ 1 ]-DETAIL OPTIONAL ).

  SORT GT_DETAIL BY ZCOUNT INSMM WERKS LGORT MATNR CHARG TAGNR.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form conversion_exit_matn1_output
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM CONVERSION_EXIT_MATN1_OUTPUT  USING PV_MATNR.

  CHECK PV_MATNR IS NOT INITIAL.

  CALL FUNCTION 'CONVERSION_EXIT_MATN1_OUTPUT'
    EXPORTING
      INPUT  = PV_MATNR
    IMPORTING
      OUTPUT = PV_MATNR.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form double_click_in_header
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM DOUBLE_CLICK_IN_HEADER USING PS_ROW    TYPE LVC_S_ROID
                                  PS_COLUMN TYPE LVC_S_COL.

  TRY.
      DATA(LR_HEADER) = REF #( GT_HEADER[ PS_ROW-ROW_ID ] OPTIONAL ).

    CATCH CX_SY_ITAB_LINE_NOT_FOUND.
      RETURN.
  ENDTRY.

  TRY.
      GT_DETAIL = LR_HEADER->DETAIL.

      SORT GT_DETAIL BY CHARG INSMM WERKS LGORT ZCOUNT MATNR TAGNR .

      GR_DETAIL->REFRESH( ).

    CATCH CX_ROOT.
  ENDTRY.

ENDFORM.
