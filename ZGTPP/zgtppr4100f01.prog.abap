*&---------------------------------------------------------------------*
*& Include          ZGTPPR4100F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form initialization
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM INITIALIZATION.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form start_of_selection
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM START_OF_SELECTION.

  PERFORM SET_CONDITION_VALUE.

  CASE ABAP_TRUE.
    WHEN P_POST. "// 차이 전기.
      PERFORM EXTRACT_VARIANCE_POSTING_DATA.
      PERFORM GET_MATERIAL_STOCK.
      PERFORM PHYSICAL_INV_QTY_SPLIT.
      PERFORM ADJUST_POSTING_DATA.

    WHEN P_DISP. "// 결과 조회.
      PERFORM GET_PROCESSING_RESULT.
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form end_of_selection
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM END_OF_SELECTION .

  IF GT_LIST IS NOT INITIAL.
    PERFORM CALL_SCREEN_100.
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

  IF GR_LIST IS BOUND.
    GR_LIST->FREE( ).
    CLEAR GR_LIST.
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
FORM HANDLE_FIELD_CATALOG.

  LOOP AT GR_LIST->MT_FCAT REFERENCE INTO DATA(LR_FCAT).
    CASE LR_FCAT->FIELDNAME.
      WHEN 'STAT'.
        LR_FCAT->COLTEXT    = COND #( WHEN P_POST EQ ABAP_TRUE THEN TEXT-F01
                                                               ELSE TEXT-F51 ).
        LR_FCAT->JUST       = 'C'.

      WHEN 'STAT_MSG'.
        LR_FCAT->COLTEXT    = TEXT-F02.

      WHEN 'ITEM_NO'.
        LR_FCAT->COLTEXT    = TEXT-F03.

*      WHEN 'ITEM_TYPE'.
      WHEN 'ITYPE_TXT'.
        LR_FCAT->COLTEXT    = TEXT-F04.

      WHEN 'IBLNR'.
        LR_FCAT->COLTEXT    = TEXT-F05.
        LR_FCAT->JUST       = 'C'.
        LR_FCAT->EMPHASIZE  = 'C500'.

      WHEN 'MBLNR'.
        LR_FCAT->COLTEXT    = TEXT-F06.
        LR_FCAT->JUST       = 'C'.
        LR_FCAT->EMPHASIZE  = 'C500'.

      WHEN 'INSMM'.
        LR_FCAT->COLTEXT    = TEXT-F07.
        LR_FCAT->JUST       = 'C'.
        LR_FCAT->EMPHASIZE  = 'C100'.

      WHEN 'WERKS'.
        LR_FCAT->COLTEXT    = TEXT-F08.
        LR_FCAT->JUST       = 'C'.
        LR_FCAT->EMPHASIZE  = 'C100'.

      WHEN 'NAME1'.
        LR_FCAT->COLTEXT    = TEXT-F09.
        LR_FCAT->EMPHASIZE  = 'C100'.

      WHEN 'LGORT'.
        LR_FCAT->COLTEXT    = TEXT-F10.
        LR_FCAT->JUST       = 'C'.
        LR_FCAT->EMPHASIZE  = 'C100'.

      WHEN 'LGOBE'.
        LR_FCAT->COLTEXT    = TEXT-F11.
        LR_FCAT->EMPHASIZE  = 'C100'.

      WHEN 'SEQNO'.
        LR_FCAT->COLTEXT    = TEXT-F12.
        LR_FCAT->JUST       = 'C'.
        LR_FCAT->EMPHASIZE  = 'C100'.

      WHEN 'MATNR'.
        LR_FCAT->COLTEXT    = TEXT-F13.
        LR_FCAT->EMPHASIZE  = 'C100'.

      WHEN 'MAKTX'.
        LR_FCAT->COLTEXT    = TEXT-F14.
        LR_FCAT->EMPHASIZE  = 'C100'.

      WHEN 'CHARG'.
        LR_FCAT->COLTEXT    = TEXT-F15.
        LR_FCAT->TECH       = COND #( WHEN P_DISP EQ ABAP_TRUE THEN ABAP_TRUE ).

      WHEN 'TAGNR'.
        LR_FCAT->COLTEXT    = TEXT-F16.
        LR_FCAT->TECH       = COND #( WHEN P_DISP EQ ABAP_TRUE THEN ABAP_TRUE ).

      WHEN 'VBELN'.
        LR_FCAT->COLTEXT    = TEXT-F17.
        LR_FCAT->JUST       = 'C'.
        LR_FCAT->TECH       = COND #( WHEN P_DISP EQ ABAP_TRUE THEN ABAP_TRUE ).

      WHEN 'POSNR'.
        LR_FCAT->COLTEXT    = TEXT-F18.
        LR_FCAT->JUST       = 'C'.
        LR_FCAT->TECH       = COND #( WHEN P_DISP EQ ABAP_TRUE THEN ABAP_TRUE ).

      WHEN 'CHECK'.
        LR_FCAT->COLTEXT    = TEXT-F19.
        LR_FCAT->JUST       = 'C'.
        LR_FCAT->TECH       = COND #( WHEN P_DISP EQ ABAP_TRUE THEN ABAP_TRUE ).

      WHEN 'LABST'.
        LR_FCAT->COLTEXT    = TEXT-F20.
        LR_FCAT->NO_ZERO    = ABAP_TRUE.
        LR_FCAT->EMPHASIZE  = 'C300'.
        LR_FCAT->TECH       = COND #( WHEN P_DISP EQ ABAP_TRUE THEN ABAP_TRUE ).

      WHEN 'MENGE'.
        LR_FCAT->COLTEXT    = TEXT-F21.
        LR_FCAT->EMPHASIZE  = 'C300'.
        LR_FCAT->NO_ZERO    = ABAP_TRUE.

      WHEN 'MEINS'.
        LR_FCAT->COLTEXT    = TEXT-F22.
        LR_FCAT->EMPHASIZE  = 'C300'.
        LR_FCAT->JUST       = 'C'.
        LR_FCAT->TECH       = COND #( WHEN P_DISP EQ ABAP_TRUE THEN ABAP_TRUE ).

      WHEN 'ERFMG'.
        LR_FCAT->COLTEXT    = TEXT-F70.
        LR_FCAT->NO_ZERO    = ABAP_TRUE.
        LR_FCAT->JUST       = 'C'.
        LR_FCAT->EMPHASIZE  = 'C300'.
        LR_FCAT->TECH       = COND #( WHEN P_POST EQ ABAP_TRUE THEN ABAP_TRUE ).

      WHEN 'ERFME'.
        LR_FCAT->COLTEXT    = TEXT-F71.
        LR_FCAT->EMPHASIZE  = 'C300'.
        LR_FCAT->TECH       = COND #( WHEN P_POST EQ ABAP_TRUE THEN ABAP_TRUE ).

      WHEN 'CRDAT'.
        LR_FCAT->COLTEXT    = TEXT-F72.
        LR_FCAT->JUST       = 'C'.
        LR_FCAT->TECH       = COND #( WHEN P_POST EQ ABAP_TRUE THEN ABAP_TRUE ).

      WHEN 'CRTIM'.
        LR_FCAT->COLTEXT    = TEXT-F73.
        LR_FCAT->JUST       = 'C'.
        LR_FCAT->TECH       = COND #( WHEN P_POST EQ ABAP_TRUE THEN ABAP_TRUE ).

      WHEN 'CRNAM'.
        LR_FCAT->COLTEXT    = TEXT-F74.
        LR_FCAT->JUST       = 'C'.
        LR_FCAT->TECH       = COND #( WHEN P_POST EQ ABAP_TRUE THEN ABAP_TRUE ).

      WHEN OTHERS.
        LR_FCAT->TECH = ABAP_TRUE.
    ENDCASE.

    LR_FCAT->TOOLTIP = LR_FCAT->REPTEXT = LR_FCAT->COLTEXT.
    LR_FCAT->SCRTEXT_S = LR_FCAT->SCRTEXT_M = LR_FCAT->SCRTEXT_L = LR_FCAT->COLTEXT.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form handle_layout
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM HANDLE_LAYOUT.

*  TRY.
*      gr_list->ms_layout = VALUE #( BASE gr_list->ms_layout  stylefname = 'STYLE'
*                                                             cwidth_opt = abap_false
*                                                             info_fname = COND #( WHEN gv_list EQ gc_table-zgtppt2290 THEN 'ROW_COLOR' )
*                                                             grid_title = COND #( WHEN gv_list EQ gc_table-zgtppt2270 THEN |{ TEXT-f00 }: { p_werks } { p_name1 }|
*                                                                                  WHEN gv_list EQ gc_table-zgtppt2280 THEN |{ TEXT-f09 }: { p_spmon+0(4) }  { TEXT-f00 }: { p_werks } { p_name1 }|
*                                                                                  WHEN gv_list EQ gc_table-zgtppt2290 THEN |{ TEXT-f10 }: { gv_spmon }   { TEXT-f01 }: { gs_eqpm-equcd } { gs_eqpm-equnm }| ) ).
*    CATCH cx_root.
*
*  ENDTRY.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form handle_double_click
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM HANDLE_DOUBLE_CLICK USING PS_ROW    TYPE LVC_S_ROID
                               PS_COLUMN TYPE LVC_S_COL.

*  TRY.
*      DATA(ls_list) = gt_list[ ps_row-row_id ].
*
*    CATCH cx_sy_itab_line_not_found.
*      RETURN.
*  ENDTRY.
*
*  CASE ps_column-fieldname.
*    WHEN 'CRUDQ' OR 'STATUS' OR 'MESSAGE'.
*      IF ls_list-return IS NOT INITIAL.
*        gr_list->display_message( ls_list-return ).
*      ENDIF.
*
*    WHEN OTHERS.
**      TRY.
**          CALL TRANSACTION 'CR03' WITH AUTHORITY-CHECK AND SKIP FIRST SCREEN.
**
**        CATCH cx_sy_authorization_error.
**          MESSAGE e077(s#) WITH 'CR03' DISPLAY LIKE 'S'.
**      ENDTRY.
*  ENDCASE.
*
ENDFORM.
*&---------------------------------------------------------------------*
*& Form at_selection_screen_output
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM AT_SELECTION_SCREEN_OUTPUT .

  LOOP AT SCREEN INTO DATA(LS_SCREEN).
    CASE LS_SCREEN-GROUP1.
      WHEN 'OBL'.
        LS_SCREEN-REQUIRED = COND #( WHEN LS_SCREEN-NAME NE 'S_LGORT-HIGH' THEN  2 ).
        MODIFY SCREEN FROM LS_SCREEN.

      WHEN 'PST'.
        IF P_POST EQ ABAP_FALSE.
          LS_SCREEN-ACTIVE = 0.
          MODIFY SCREEN FROM LS_SCREEN.
        ENDIF.

      WHEN 'DSP'.
        IF P_DISP EQ ABAP_FALSE.
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
    WHEN GC_FCODE-ONLI.   "// 실행.
      PERFORM CHECK_SEL_SCREEN_INPUT_VALUE.
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form check_sel_screen_input_value
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM CHECK_SEL_SCREEN_INPUT_VALUE.

*// 플랜트.
  IF P_WERKS IS INITIAL.
    MESSAGE E164(M3) DISPLAY LIKE 'S'.
  ELSE.
    SELECT SINGLE @ABAP_TRUE
      INTO @DATA(LV_CHECK)
      FROM T001W
     WHERE WERKS EQ @P_WERKS.

    IF SY-SUBRC IS NOT INITIAL.
      MESSAGE E011(VF) WITH P_WERKS DISPLAY LIKE 'S'.
    ENDIF.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form call_screen_100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM CALL_SCREEN_100 .

  IF P_POST IS NOT INITIAL.
    GV_TPAR1 = TEXT-C11.
    GV_TPAR2 = COND #( WHEN P_RAW IS NOT INITIAL THEN TEXT-C21
                                                 ELSE TEXT-C22 ).
    GV_TPAR2 = |/{ GV_TPAR2 }|.
    GT_EXCLUDE = VALUE #( ( GC_FCODE-CNCL_POST )
                          ( GC_FCODE-CNCL_SCRAP ) ).

    GT_EXCLUDE = COND #( WHEN P_RAW IS NOT INITIAL THEN VALUE #( BASE GT_EXCLUDE ( GC_FCODE-SCRAP ) )
                                                   ELSE VALUE #( BASE GT_EXCLUDE ( GC_FCODE-POST ) ) ).
  ELSE.
    GV_TPAR1 = TEXT-C12.
    GT_EXCLUDE = VALUE #( ( GC_FCODE-POST )
                          ( GC_FCODE-SCRAP ) ).

    GT_EXCLUDE = COND #( WHEN P_RAW IS NOT INITIAL THEN VALUE #( BASE GT_EXCLUDE ( GC_FCODE-CNCL_SCRAP )
                                                                                 ( GC_FCODE-CNCL_POST ) )
                                                   ELSE VALUE #( BASE GT_EXCLUDE ( GC_FCODE-CNCL_POST ) ) ).
  ENDIF.

  CALL SCREEN 100.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form f4_insmm
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM F4_INSMM .

  CALL FUNCTION 'POPUP_TO_SELECT_MONTH'
    EXPORTING
      ACTUAL_MONTH               = CONV KMONTH( SY-DATUM+0(6) )
    IMPORTING
      SELECTED_MONTH             = P_INSMM
    EXCEPTIONS
      FACTORY_CALENDAR_NOT_FOUND = 1
      HOLIDAY_CALENDAR_NOT_FOUND = 2
      MONTH_NOT_FOUND            = 3
      OTHERS                     = 4.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form user_command_post
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM USER_COMMAND_POST .

  TRY.
      PERFORM CHECK_BEFORE_POSTING. "// 사전점검.
      PERFORM RUN_VARIANCE_POSTING. "// 차이전기.

    CATCH LCX_EXCEPTION INTO DATA(LR_EXCEPTION).
      IF LR_EXCEPTION->GET_TEXT( ) IS NOT INITIAL.
        GR_LIST->REFRESH( ).
        MESSAGE LR_EXCEPTION->GET_TEXT( ) TYPE 'I' DISPLAY LIKE 'E'.
      ENDIF.
  ENDTRY.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form user_command_scrap
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM USER_COMMAND_SCRAP .

  TRY.
      PERFORM CHECK_BEFORE_SCRAP_PROCESSING. "// 사전점검.
      PERFORM RUN_SCRAP_PROCESSING.          "// 스크랩 처리.

    CATCH LCX_EXCEPTION INTO DATA(LR_EXCEPTION).
      IF LR_EXCEPTION->GET_TEXT( ) IS NOT INITIAL.
        GR_LIST->REFRESH( ).
        MESSAGE LR_EXCEPTION->GET_TEXT( ) TYPE 'I' DISPLAY LIKE 'E'.
      ENDIF.
  ENDTRY.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form user_command_cncl_post
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM USER_COMMAND_CNCL_POST .

  TRY.
      PERFORM CHECK_BEFORE_CANCEL_POSTING. "// 사전점검.
      PERFORM RUN_CANCEL_VARIANCE_POSTING. "// 차이전기 취소 실행.

    CATCH LCX_EXCEPTION INTO DATA(LR_EXCEPTION).
      IF LR_EXCEPTION->GET_TEXT( ) IS NOT INITIAL.
        GR_LIST->REFRESH( ).
        MESSAGE LR_EXCEPTION->GET_TEXT( ) TYPE 'I' DISPLAY LIKE 'E'.
      ENDIF.
  ENDTRY.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form user_command_cncl_scrap
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM USER_COMMAND_CNCL_SCRAP .

  TRY.
      PERFORM CHECK_BEFORE_CANCEL_SCRAP.   "// 사전점검.
      PERFORM RUN_CANCEL_SCRAP_PROCESSING. "// 스크랩 처리 취소.

    CATCH LCX_EXCEPTION INTO DATA(LR_EXCEPTION).
      IF LR_EXCEPTION->GET_TEXT( ) IS NOT INITIAL.
        GR_LIST->REFRESH( ).
        MESSAGE LR_EXCEPTION->GET_TEXT( ) TYPE 'I' DISPLAY LIKE 'E'.
      ENDIF.
  ENDTRY.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form extract_variance_posting_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM EXTRACT_VARIANCE_POSTING_DATA .

  DATA(LV_ITYPE_TXT) = VALUE CHAR20( ).
  LV_ITYPE_TXT = TEXT-T11.

  SELECT CASE WHEN ZT02~WERKS IS NOT NULL THEN @ICON_LED_GREEN
              ELSE @ICON_LED_INACTIVE
         END AS STAT,
         @GV_ITEM_TYPE AS ITEM_TYPE,
         @LV_ITYPE_TXT AS ITYPE_TXT,
         ZT02~IBLNR, ZT02~MBLNR, ZT02~ITEM_NO,
         ZT01~INSMM,
         ZT01~WERKS, T001W~NAME1,
         ZT01~LGORT, T001L~LGOBE,
         ZT01~SEQNO,
         ZT01~MATNR, MAKT~MAKTX,
         ZT01~CHARG, ZT01~TAGNR, ZT01~VBELN, ZT01~POSNR,
         ZT01~MENGE, ZT01~MEINS,
         MSEG~MENGE AS ERFMG, MSEG~MEINS AS ERFME,
         MARC~DISPO,
        CASE WHEN @P_RAW  EQ @ABAP_TRUE THEN CASE WHEN ZT01~CHARG IS INITIAL AND
                                                       ZT01~TAGNR IS INITIAL AND
                                                       ZT01~VBELN IS INITIAL AND
                                                       ZT01~POSNR IS INITIAL THEN @ICON_LED_GREEN END
             WHEN @P_HALB EQ @ABAP_TRUE THEN @ICON_LED_GREEN
        END AS CHECK
    FROM ZPPT0600 AS ZT01
    LEFT JOIN ZPPT0610 AS ZT02
      ON ZT01~INSMM     EQ ZT02~INSMM
     AND ZT01~WERKS     EQ ZT02~WERKS
     AND ZT01~LGORT     EQ ZT02~LGORT
     AND ZT01~SEQNO     EQ ZT02~SEQNO
     AND ZT01~MATNR     EQ ZT02~MATNR
     AND ZT01~CHARG     EQ ZT02~CHARG
     AND ZT01~TAGNR     EQ ZT02~TAGNR
     AND ZT02~ITEM_TYPE EQ @GV_ITEM_TYPE
     AND ZT02~LOEKZ     EQ @SPACE
    LEFT JOIN MSEG
      ON ZT02~MBLNR EQ MSEG~MBLNR
     AND SUBSTRING( ZT02~INSMM, 1, 4 ) EQ MSEG~GJAHR
     AND ZT01~MATNR EQ MSEG~MATNR
     AND MSEG~ZEILE EQ '0001'
    JOIN MARC
      ON ZT01~MATNR EQ MARC~MATNR
     AND ZT01~WERKS EQ MARC~WERKS
    JOIN MARA
      ON ZT01~MATNR EQ MARA~MATNR
    JOIN MAKT
      ON MARA~MATNR EQ MAKT~MATNR
     AND MAKT~SPRAS EQ @SY-LANGU
    JOIN T001W
      ON ZT01~WERKS EQ T001W~WERKS
    LEFT JOIN T001L
      ON ZT01~WERKS EQ T001L~WERKS
     AND ZT01~LGORT EQ T001L~LGORT
   WHERE ZT01~WERKS EQ @P_WERKS
     AND ZT01~INSMM EQ @P_INSMM
     AND ZT01~LGORT IN @S_LGORT
     AND MARA~MTART IN @GT_MTART
     AND MARA~XCHPF IN @GT_XCHPF
   ORDER BY ZT01~INSMM, ZT01~WERKS, ZT01~LGORT, ZT01~SEQNO, ZT01~MATNR, ZT01~CHARG
    INTO CORRESPONDING FIELDS OF TABLE @GT_LIST.

  IF P_OPT1 EQ ABAP_TRUE. "// 차이 수량 0 제외.
    DELETE GT_LIST WHERE MENGE IS INITIAL.
  ENDIF.

  IF P_OPT2 EQ ABAP_TRUE. "// 차이 조정 대상만 조회.
    DELETE GT_LIST WHERE CHECK NE ICON_LED_GREEN.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_processing_result
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM GET_PROCESSING_RESULT .

  SELECT ZT01~*,
         ZT02~MENGE, ZT02~MEINS,
         MAKT~MAKTX, T001W~NAME1, T001L~LGOBE,
         ZT03~DDTEXT AS ITYPE_TXT,
         @ICON_LED_INACTIVE AS STAT
    FROM ZPPT0610 AS ZT01
    JOIN ZPPT0600 AS ZT02
      ON ZT01~INSMM EQ ZT02~INSMM
     AND ZT01~WERKS EQ ZT02~WERKS
     AND ZT01~LGORT EQ ZT02~LGORT
     AND ZT01~SEQNO EQ ZT02~SEQNO
     AND ZT01~MATNR EQ ZT02~MATNR
     AND ZT01~CHARG EQ ZT02~CHARG
     AND ZT01~TAGNR EQ ZT02~TAGNR
    JOIN MARC
      ON ZT01~MATNR EQ MARC~MATNR
     AND ZT01~WERKS EQ MARC~WERKS
    JOIN MARA
      ON ZT01~MATNR EQ MARA~MATNR
    JOIN MAKT
      ON MARA~MATNR EQ MAKT~MATNR
     AND MAKT~SPRAS EQ @SY-LANGU
    JOIN T001W
      ON ZT01~WERKS EQ T001W~WERKS
    LEFT JOIN T001L
      ON ZT01~WERKS EQ T001L~WERKS
     AND ZT01~LGORT EQ T001L~LGORT
    LEFT JOIN @GT_DD07T AS ZT03
      ON ZT03~DOMNAME   EQ 'ZGTDITEM_TYPE'
     AND ZT01~ITEM_TYPE EQ ZT03~DOMVALUE_L
   WHERE ZT01~WERKS     EQ @P_WERKS
     AND ZT01~INSMM     EQ @P_INSMM
     AND ZT01~LGORT     IN @S_LGORT
     AND ZT01~MATNR     IN @S_MATNR
     AND ZT01~IBLNR     IN @S_IBLNR
     AND ZT01~MBLNR     IN @S_MBLNR
     AND ZT01~ITEM_TYPE EQ @GV_ITEM_TYPE
     AND ZT01~CRDAT     IN @S_CRDAT
     AND ZT01~LOEKZ     EQ @SPACE
   ORDER BY ZT01~INSMM, ZT01~WERKS, ZT01~LGORT, ZT01~SEQNO, ZT01~MATNR
    INTO CORRESPONDING FIELDS OF TABLE @GT_LIST.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_material_stock
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM GET_MATERIAL_STOCK .

  CHECK GT_LIST IS NOT INITIAL.

  SELECT DISTINCT ZT01~WERKS, ZT01~LGORT, ZT01~MATNR
    FROM @GT_LIST AS ZT01
   ORDER BY ZT01~WERKS, ZT01~LGORT, ZT01~MATNR
    INTO TABLE @DATA(LT_MAT).

*// 판매 오더 재고.
  SELECT MSKA~MATNR, MSKA~WERKS, MSKA~LGORT, MSKA~CHARG, MSKA~SOBKZ,
         MSKA~VBELN, MSKA~POSNR, MSKA~KALAB, MSKA~LFGJA, MSKA~LFMON
    FROM @LT_MAT AS ZT01
    JOIN MSKA
      ON ZT01~MATNR EQ MSKA~MATNR
     AND ZT01~WERKS EQ MSKA~WERKS
     AND ZT01~LGORT EQ MSKA~LGORT
    INTO CORRESPONDING FIELDS OF TABLE @GT_MSKA.

  SELECT MSKAH~MATNR, MSKAH~WERKS, MSKAH~LGORT, MSKAH~CHARG, MSKAH~SOBKZ,
         MSKAH~VBELN, MSKAH~POSNR, MSKAH~KALAB, MSKAH~LFGJA, MSKAH~LFMON
    FROM @LT_MAT AS ZT01
    JOIN MSKAH
      ON ZT01~MATNR EQ MSKAH~MATNR
     AND ZT01~WERKS EQ MSKAH~WERKS
     AND ZT01~LGORT EQ MSKAH~LGORT
     AND CONCAT( MSKAH~LFGJA, MSKAH~LFMON ) EQ @P_INSMM
    INTO CORRESPONDING FIELDS OF TABLE @GT_MSKAH.

*// 배치 재고.
  SELECT MCHB~MATNR, MCHB~WERKS, MCHB~LGORT, MCHB~CHARG,
         MCHB~CLABS, MCHB~LFGJA, MCHB~LFMON
    FROM @LT_MAT AS ZT01
    JOIN MCHB
      ON ZT01~MATNR EQ MCHB~MATNR
     AND ZT01~WERKS EQ MCHB~WERKS
     AND ZT01~LGORT EQ MCHB~LGORT
    INTO CORRESPONDING FIELDS OF TABLE @GT_MCHB.

  SELECT MCHBH~MATNR, MCHBH~WERKS, MCHBH~LGORT, MCHBH~CHARG,
         MCHBH~CLABS, MCHBH~LFGJA, MCHBH~LFMON
    FROM @LT_MAT AS ZT01
    JOIN MCHBH
      ON ZT01~MATNR EQ MCHBH~MATNR
     AND ZT01~WERKS EQ MCHBH~WERKS
     AND ZT01~LGORT EQ MCHBH~LGORT
     AND CONCAT( MCHBH~LFGJA, MCHBH~LFMON ) EQ @P_INSMM
    INTO CORRESPONDING FIELDS OF TABLE @GT_MCHBH.

*// 저장위치 재고.
  SELECT MARD~MATNR, MARD~WERKS, MARD~LGORT,
         MARD~LABST, MARD~LFGJA, MARD~LFMON
    FROM @LT_MAT AS ZT01
    JOIN MARD
      ON ZT01~MATNR EQ MARD~MATNR
     AND ZT01~WERKS EQ MARD~WERKS
     AND ZT01~LGORT EQ MARD~LGORT
    INTO CORRESPONDING FIELDS OF TABLE @GT_MARD.

  SELECT MARDH~MATNR, MARDH~WERKS, MARDH~LGORT,
         MARDH~LABST, MARDH~LFGJA, MARDH~LFMON
    FROM @LT_MAT AS ZT01
    JOIN MARDH
      ON ZT01~MATNR EQ MARDH~MATNR
     AND ZT01~WERKS EQ MARDH~WERKS
     AND ZT01~LGORT EQ MARDH~LGORT
     AND CONCAT( MARDH~LFGJA, MARDH~LFMON ) EQ @P_INSMM
    INTO CORRESPONDING FIELDS OF TABLE @GT_MARDH.

*// 생산오더
  SELECT MATDOC~MATNR, MATDOC~WERKS, MATDOC~CHARG, MATDOC~AUFNR, MATDOC~MEINS,
         SUM( MATDOC~MENGE ) AS MENGE
    FROM @GT_LIST AS ZT01
    JOIN MATDOC
      ON ZT01~MATNR   EQ MATDOC~MATNR
     AND ZT01~WERKS   EQ MATDOC~WERKS
     AND ZT01~CHARG   EQ MATDOC~CHARG
     AND MATDOC~BWART EQ '261'
     AND MATDOC~AUFNR NE @SPACE
     AND MATDOC~BUDAT BETWEEN @GV_FROM AND @GV_TO
     AND MATDOC~CANCELLED EQ @SPACE
   GROUP BY MATDOC~MATNR, MATDOC~WERKS, MATDOC~CHARG, MATDOC~AUFNR, MATDOC~MEINS
  HAVING SUM( MATDOC~MENGE ) GT 0
   ORDER BY MATDOC~MATNR, MATDOC~WERKS, MATDOC~CHARG, MATDOC~AUFNR, MATDOC~MEINS
    INTO CORRESPONDING FIELDS OF TABLE @GT_AUFK.

*// 출고수량.
  SELECT MATDOC~MATNR, MATDOC~WERKS, MATDOC~MEINS,
         COUNT( DISTINCT MATDOC~AUFNR ) AS COUNT,
*        2 AS count,
         SUM( MATDOC~MENGE ) AS MENGE
    FROM @LT_MAT AS ZT01
    JOIN MATDOC
      ON ZT01~MATNR   EQ MATDOC~MATNR
     AND ZT01~WERKS   EQ MATDOC~WERKS
     AND MATDOC~BWART EQ '261'
     AND MATDOC~AUFNR NE @SPACE
     AND MATDOC~BUDAT BETWEEN @GV_FROM AND @GV_TO
     AND MATDOC~CANCELLED EQ @SPACE
   GROUP BY MATDOC~MATNR, MATDOC~WERKS, MATDOC~MEINS
    INTO CORRESPONDING FIELDS OF TABLE @GT_MATDOC.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form adjust_posting_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM ADJUST_POSTING_DATA .
  DATA LT_ZPPT0610 TYPE TABLE OF ZPPT0610 WITH NON-UNIQUE SORTED KEY SKEY
                                                          COMPONENTS INSMM WERKS LGORT SEQNO MATNR CHARG TAGNR.
  DATA LV_MENGE  TYPE ZPPT0600-MENGE.
  DATA LV_MENGE1 TYPE ZPPT0600-MENGE.
  DATA LV_STRING TYPE CHAR30.

  DATA(LT_ZGTPPT1010) = ZGTPP_CL_COMMON=>GET_CODE_VALUE( IV_CODEGRP = '4000' ).
  DATA(LS_ZGTPPT1010) = VALUE #( LT_ZGTPPT1010[ FLD_01 = P_WERKS ] OPTIONAL ).
  DATA(LS_DD07T) = VALUE #( GT_DD07T[ DOMVALUE_L = GV_ITEM_TYPE ] OPTIONAL ).

  SELECT ZT01~INSMM, ZT01~WERKS, ZT01~LGORT, ZT01~SEQNO, ZT01~MATNR, ZT01~CHARG, ZT01~TAGNR, MAX( ZT01~ITEM_NO ) AS ITEM_NO
    FROM ZPPT0610 AS ZT01
   WHERE ZT01~INSMM EQ @P_INSMM
     AND ZT01~WERKS EQ @P_WERKS
     AND ZT01~LGORT IN @S_LGORT
   GROUP BY ZT01~INSMM, ZT01~WERKS, ZT01~LGORT, ZT01~SEQNO, ZT01~MATNR, ZT01~CHARG, ZT01~TAGNR
    INTO CORRESPONDING FIELDS OF TABLE @LT_ZPPT0610.

  LOOP AT GT_LIST REFERENCE INTO DATA(LR_LIST).
    IF LR_LIST->ITEM_NO IS INITIAL.
      READ TABLE LT_ZPPT0610 REFERENCE INTO DATA(LR_ZPPT0610)
                             WITH TABLE KEY SKEY COMPONENTS INSMM = LR_LIST->INSMM
                                                            WERKS = LR_LIST->WERKS
                                                            LGORT = LR_LIST->LGORT
                                                            SEQNO = LR_LIST->SEQNO
                                                            MATNR = LR_LIST->MATNR
                                                            CHARG = LR_LIST->CHARG
                                                            TAGNR = LR_LIST->TAGNR.
      IF SY-SUBRC IS INITIAL.
        LR_ZPPT0610->ITEM_NO = LR_ZPPT0610->ITEM_NO + 1.
        LR_LIST->ITEM_NO = LR_ZPPT0610->ITEM_NO.
      ELSE.
        LR_LIST->ITEM_NO = 1.
        APPEND INITIAL LINE TO LT_ZPPT0610 REFERENCE INTO LR_ZPPT0610.
        LR_ZPPT0610->* = CORRESPONDING #( LR_LIST->* ).
      ENDIF.
    ENDIF.

    LR_LIST->ITYPE_TXT = LS_DD07T-DDTEXT.

    PERFORM GET_STOCK_QTY USING LR_LIST->*.

    IF P_RAW EQ ABAP_TRUE.
      CLEAR LV_MENGE.
      SORT GT_MATDOC BY MATNR WERKS.
      READ TABLE GT_MATDOC INTO DATA(LS_MATDOC) WITH KEY MATNR = LR_LIST->MATNR
                                                         WERKS = LR_LIST->WERKS BINARY SEARCH.
      IF SY-SUBRC IS INITIAL.
        LV_MENGE = LS_MATDOC-MENGE * LS_ZGTPPT1010-FLD_02 / 100. "// 조정 허용 수량.
      ELSE.
        LV_MENGE = LS_MATDOC-MENGE.
      ENDIF.

      CLEAR: LV_MENGE1.
      IF LR_LIST->MENGE < 0.
        LV_MENGE1 = ABS( LR_LIST->MENGE ).

*      IF LR_LIST->MENGE > LV_MENGE. "// 재고조정수량 > 조정 허용 수량.
        IF LV_MENGE1 > LV_MENGE. "// 재고조정수량 > 조정 허용 수량.
          LR_LIST->STAT = ICON_LED_RED.
          WRITE LV_MENGE UNIT LS_MATDOC-MEINS TO LV_STRING LEFT-JUSTIFIED.
          MESSAGE E035 WITH LV_STRING INTO LR_LIST->STAT_MSG.
        ENDIF.
      ENDIF.

      CLEAR: LS_MATDOC.
    ELSE.
      LR_LIST->STAT  = ICON_LED_INACTIVE.
    ENDIF.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form check_before_posting
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM CHECK_BEFORE_POSTING  RAISING LCX_EXCEPTION.
  DATA LV_ANSWER TYPE C.

  PERFORM GET_ROWS_SELECTED_POSTING.

  IF GS_RESULT-INVALID IS NOT INITIAL.
    RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E000 WITH TEXT-E13.
  ENDIF.

  IF GS_RESULT-SEL IS INITIAL.
    RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E000 WITH TEXT-E11.
  ENDIF.

  IF GS_RESULT-TOTAL IS INITIAL.
    RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E000 WITH TEXT-E12.
  ENDIF.

  PERFORM CONFIRMATION_POPUP USING TEXT-C03 LV_ANSWER.

  IF LV_ANSWER NE '1'.
    RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E000 WITH SPACE.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form run_variance_posting
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM RUN_VARIANCE_POSTING .

  LOOP AT GT_LIST REFERENCE INTO DATA(LR_LIST)
                  WHERE SEL EQ ABAP_TRUE.
    PERFORM BUILD_BDC_DATA USING LR_LIST->*.
    PERFORM GET_RESULT_BDC_MI10 USING LR_LIST->*.
  ENDLOOP.

  GR_LIST->REFRESH( ).

*//==> 처리결과 메시지.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_rows_selected_POSTING
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM GET_ROWS_SELECTED_POSTING .

  CLEAR GS_RESULT.

  MODIFY GT_LIST FROM VALUE #( SEL = ABAP_FALSE )
                 TRANSPORTING SEL
                 WHERE SEL EQ ABAP_TRUE.

  GR_LIST->MR_GRID->GET_SELECTED_ROWS( IMPORTING ET_INDEX_ROWS = DATA(LT_ROWS) ).
  DELETE LT_ROWS WHERE ROWTYPE NE SPACE.

  IF LT_ROWS IS INITIAL.
    RETURN.
  ENDIF.

  LOOP AT LT_ROWS INTO DATA(LS_ROW).
    READ TABLE GT_LIST REFERENCE INTO DATA(LR_LIST) INDEX LS_ROW-INDEX.

    CHECK SY-SUBRC IS INITIAL.

    GS_RESULT-SEL += 1.

    CHECK LR_LIST->CHECK EQ ICON_LED_GREEN.

    IF LR_LIST->STAT EQ ICON_LED_GREEN.
      GS_RESULT-INVALID = ABAP_TRUE.
      CONTINUE.
    ENDIF.

    LR_LIST->SEL = ABAP_TRUE.
    GS_RESULT-TOTAL += 1.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form Set_Condition_Value
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM SET_CONDITION_VALUE .

  GT_MTART = COND #( WHEN P_RAW EQ ABAP_TRUE THEN VALUE #( SIGN = 'I' OPTION = 'EQ' ( LOW = 'ROH1' )
                                                                                    ( LOW = 'ROH2' )
                                                                                    ( LOW = 'MRM1' )
                                                                                    ( LOW = 'MRM2' ) )
                                             ELSE VALUE #( SIGN = 'I' OPTION = 'EQ' ( LOW = 'MCHF' )
                                                                                    ( LOW = 'HALB' ) ) ).

  GT_XCHPF = COND #( WHEN P_RAW EQ ABAP_TRUE THEN VALUE #( SIGN = 'I' OPTION = 'EQ' ( LOW = SPACE ) ) ).

  GV_FROM = P_INSMM && '01'.
  GV_TO   = CL_RECA_DATE=>SET_TO_END_OF_MONTH( GV_FROM ).

  GV_ITEM_TYPE = COND #( WHEN P_RAW  IS NOT INITIAL THEN ZGTPP_IF_CONST=>GC_ITEM_TYPE-A
                         WHEN P_HALB IS NOT INITIAL THEN ZGTPP_IF_CONST=>GC_ITEM_TYPE-B ).

  SELECT DOMNAME, DOMVALUE_L, DDTEXT
    FROM DD07T
    INTO CORRESPONDING FIELDS OF TABLE @GT_DD07T
   WHERE DOMNAME    EQ 'ZGTDITEM_TYPE'
     AND DDLANGUAGE EQ @SY-LANGU
   ORDER BY DOMNAME, DOMVALUE_L.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form build_bdc_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM BUILD_BDC_DATA  USING PS_LIST TYPE TY_S_LIST.
  DATA LV_LABST TYPE MARD-LABST.
  DATA LV_ERFMG TYPE CHAR18.
  DATA LV_MENGE TYPE MARD-LABST.

  PERFORM GET_STORAGE_LOCATION_STOCK USING PS_LIST LV_LABST.

  CLEAR: LV_MENGE.
  IF P_POST EQ ABAP_TRUE.
    LV_MENGE = LV_LABST + PS_LIST-MENGE. "// 차이전기.
  ELSE.
    LV_MENGE = LV_LABST - PS_LIST-MENGE. "// 차이전기취소.
  ENDIF.

  WRITE LV_MENGE UNIT PS_LIST-MEINS TO LV_ERFMG LEFT-JUSTIFIED.

  GT_BDCDATA = VALUE #( ( DYNBEGIN = 'X'  PROGRAM = 'SAPMM07I'       DYNPRO = '0700' )
                        ( DYNBEGIN = ' '  FNAM    = 'BDC_OKCODE'     FVAL   = '/00' )
                        ( DYNBEGIN = ' '  FNAM    = 'RM07I-ZLDAT'    FVAL   = |{ GV_TO DATE = USER }| )
                        ( DYNBEGIN = ' '  FNAM    = 'RM07I-BLDAT'    FVAL   = |{ GV_TO DATE = USER }| )
                        ( DYNBEGIN = ' '  FNAM    = 'IKPF-WERKS'     FVAL   = PS_LIST-WERKS )
                        ( DYNBEGIN = ' '  FNAM    = 'IKPF-LGORT'     FVAL   = PS_LIST-LGORT )
                        ( DYNBEGIN = 'X'  PROGRAM = 'SAPMM07I'       DYNPRO = '0731' )
                        ( DYNBEGIN = ' '  FNAM    = 'BDC_OKCODE'     FVAL   = '=BU' )
                        ( DYNBEGIN = ' '  FNAM    = 'ISEG-MATNR(01)' FVAL   = PS_LIST-MATNR )
                        ( DYNBEGIN = ' '  FNAM    = 'ISEG-XNULL(01)' FVAL   = COND #( WHEN LV_MENGE EQ 0 THEN ABAP_TRUE
                                                                                                         ELSE ABAP_FALSE ) )
                        ( DYNBEGIN = ' '  FNAM    = 'ISEG-ERFMG(01)' FVAL   = LV_ERFMG )
                        ( DYNBEGIN = ' '  FNAM    = 'ISEG-ERFME(01)' FVAL   = PS_LIST-MEINS ) ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_result_bdc_mi10
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM GET_RESULT_BDC_MI10  USING PS_LIST TYPE TY_S_LIST.
  DATA LT_MESSTAB TYPE TABLE OF BDCMSGCOLL.

  DATA(LS_OPTION) = VALUE CTU_PARAMS( DISMODE = 'N'
                                      UPDMODE = 'S' ).

  CALL TRANSACTION 'MI10' USING GT_BDCDATA OPTIONS  FROM LS_OPTION
                                           MESSAGES INTO LT_MESSTAB.

  READ TABLE LT_MESSTAB INTO DATA(LS_MESSTAB) WITH KEY MSGTYP = 'S'
                                                       MSGID  = 'M7'
                                                       MSGNR  = '716'.
  IF SY-SUBRC IS NOT INITIAL.
    PS_LIST-STAT = ICON_LED_RED.
    LS_MESSTAB = VALUE #( LT_MESSTAB[ MSGTYP = 'E' ] OPTIONAL ).
    PERFORM BUILD_MESSAGE USING LS_MESSTAB PS_LIST-STAT_MSG.
    RETURN.
  ENDIF.

  PERFORM BUILD_MESSAGE USING LS_MESSTAB PS_LIST-STAT_MSG.

  IF P_POST EQ ABAP_TRUE.  "// 차이전기.
    PS_LIST-STAT  = ICON_LED_GREEN.
    PS_LIST-MBLNR = LS_MESSTAB-MSGV2.

    SELECT SINGLE IBLNR
      INTO @PS_LIST-IBLNR
      FROM ISEG
     WHERE MBLNR EQ @PS_LIST-MBLNR
       AND GJAHR EQ @PS_LIST-INSMM(4).

    DATA(LS_ZPPT0610) = CORRESPONDING ZPPT0610( PS_LIST ).
    LS_ZPPT0610 = VALUE #( BASE LS_ZPPT0610  CRDAT = SY-DATUM
                                             CRTIM = SY-UZEIT
                                             CRNAM = SY-UNAME ).

    MODIFY ZPPT0610 FROM LS_ZPPT0610.
  ELSE.                    "// 차이전기취소.
    PS_LIST-STAT = ICON_LED_GREEN.
    CLEAR: PS_LIST-MBLNR, PS_LIST-IBLNR.

    UPDATE ZPPT0610
       SET LOEKZ = @ABAP_TRUE,
           CHDAT = @SY-DATUM,
           CHTIM = @SY-UZEIT,
           CHNAM = @SY-UNAME
     WHERE INSMM   EQ @PS_LIST-INSMM
       AND WERKS   EQ @PS_LIST-WERKS
       AND LGORT   EQ @PS_LIST-LGORT
       AND SEQNO   EQ @PS_LIST-SEQNO
       AND MATNR   EQ @PS_LIST-MATNR
       AND CHARG   EQ @PS_LIST-CHARG
       AND TAGNR   EQ @PS_LIST-TAGNR
       AND ITEM_NO EQ @PS_LIST-ITEM_NO.
  ENDIF.

  COMMIT WORK AND WAIT.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form check_before_cancel_posting
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM CHECK_BEFORE_CANCEL_POSTING RAISING LCX_EXCEPTION.
  DATA LV_ANSWER TYPE C.

  PERFORM GET_ROWS_SELECTED_CNCL_POSTING.

  IF GS_RESULT-INVALID IS NOT INITIAL.
    RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E000 WITH TEXT-E23.
  ENDIF.

  IF GS_RESULT-MESSAGE IS NOT INITIAL.
    RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E000 WITH GS_RESULT-MESSAGE.
  ENDIF.

  IF GS_RESULT-SEL IS INITIAL.
    RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E000 WITH TEXT-E21.
  ENDIF.

  IF GS_RESULT-TOTAL IS INITIAL.
    RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E000 WITH TEXT-E12.
  ENDIF.

  PERFORM CONFIRMATION_POPUP USING TEXT-C04 LV_ANSWER.

  IF LV_ANSWER NE '1'.
    RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E000 WITH SPACE.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form run_cancel_variance_posting
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM RUN_CANCEL_VARIANCE_POSTING .

  LOOP AT GT_LIST REFERENCE INTO DATA(LR_LIST)
                  WHERE SEL EQ ABAP_TRUE.
    PERFORM BUILD_BDC_DATA USING LR_LIST->*.
    PERFORM GET_RESULT_BDC_MI10 USING LR_LIST->*.
  ENDLOOP.

  GR_LIST->REFRESH( ).

*//==> 처리결과 메시지.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_rows_selected_cncl_posting
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM GET_ROWS_SELECTED_CNCL_POSTING .

  CLEAR GS_RESULT.

  MODIFY GT_LIST FROM VALUE #( SEL = ABAP_FALSE )
                 TRANSPORTING SEL
                 WHERE SEL EQ ABAP_TRUE.

  GR_LIST->MR_GRID->GET_SELECTED_ROWS( IMPORTING ET_INDEX_ROWS = DATA(LT_ROWS) ).
  DELETE LT_ROWS WHERE ROWTYPE NE SPACE.

  IF LT_ROWS IS INITIAL.
    RETURN.
  ENDIF.

  LOOP AT LT_ROWS INTO DATA(LS_ROW).
    READ TABLE GT_LIST REFERENCE INTO DATA(LR_LIST) INDEX LS_ROW-INDEX.

    CHECK SY-SUBRC IS INITIAL.

    GS_RESULT-SEL += 1.

    IF LR_LIST->STAT EQ ICON_LED_GREEN.
      GS_RESULT-INVALID = ABAP_TRUE.
      CONTINUE.
    ENDIF.

    LR_LIST->SEL = ABAP_TRUE.
    GS_RESULT-TOTAL += 1.
  ENDLOOP.

  LOOP AT GT_LIST INTO DATA(LS_LIST)
                  WHERE SEL EQ ABAP_TRUE.
    LOOP AT GT_LIST TRANSPORTING NO FIELDS WHERE INSMM EQ LS_LIST-INSMM
                                             AND WERKS EQ LS_LIST-WERKS
                                             AND LGORT EQ LS_LIST-LGORT
                                             AND SEQNO EQ LS_LIST-SEQNO
                                             AND MATNR EQ LS_LIST-MATNR
                                             AND STAT  NE ICON_LED_GREEN
                                             AND SEL   EQ ABAP_FALSE.
      GS_RESULT-MESSAGE = TEXT-E14.
      RETURN.
    ENDLOOP.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form check_before_scrap_processing
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM CHECK_BEFORE_SCRAP_PROCESSING RAISING LCX_EXCEPTION.
  DATA LV_ANSWER TYPE C.

  PERFORM GET_ROWS_SELECTED_SCRAP.

  IF GS_RESULT-INVALID IS NOT INITIAL.
    RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E000 WITH TEXT-E13.
  ENDIF.

  IF GS_RESULT-MENGECHK IS NOT INITIAL.
    RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E000 WITH TEXT-E15.
  ENDIF.

  IF GS_RESULT-SEL IS INITIAL.
    RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E000 WITH TEXT-E11.
  ENDIF.

  IF GS_RESULT-TOTAL IS INITIAL.
    RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E000 WITH TEXT-E12.
  ENDIF.

  PERFORM CONFIRMATION_POPUP USING TEXT-C05 LV_ANSWER.

  IF LV_ANSWER NE '1'.
    RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E000 WITH SPACE.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form run_scrap_processing
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM RUN_SCRAP_PROCESSING .
  DATA LT_ITEM TYPE TABLE OF ZGTPPSIF0067.
  DATA LV_MODE TYPE CHAR02 VALUE 'A'.

  DATA(LT_ZGTPPT1010) = ZGTPP_CL_COMMON=>GET_CODE_VALUE( IV_CODEGRP = '0010' ).
  DATA(LS_ZGTPPT1010) = VALUE #( LT_ZGTPPT1010[ FLD_03 = P_WERKS ] OPTIONAL ).

  LOOP AT GT_LIST REFERENCE INTO DATA(LR_LIST)
                  WHERE SEL EQ ABAP_TRUE.
    PERFORM SET_PARAMETER_SCRAP_PROCESSING TABLES LT_ITEM USING LR_LIST->* LV_MODE.
    PERFORM CALL_IF_MES_SCRAP TABLES LT_ITEM USING LR_LIST->* LV_MODE LS_ZGTPPT1010-FLD_01.
  ENDLOOP.

  GR_LIST->REFRESH( ).

*//==> 처리결과 메시지.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_rows_selected_scrap
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM GET_ROWS_SELECTED_SCRAP .

  CLEAR GS_RESULT.

  MODIFY GT_LIST FROM VALUE #( SEL = ABAP_FALSE )
                 TRANSPORTING SEL
                 WHERE SEL EQ ABAP_TRUE.

  GR_LIST->MR_GRID->GET_SELECTED_ROWS( IMPORTING ET_INDEX_ROWS = DATA(LT_ROWS) ).
  DELETE LT_ROWS WHERE ROWTYPE NE SPACE.

  IF LT_ROWS IS INITIAL.
    RETURN.
  ENDIF.

  LOOP AT LT_ROWS INTO DATA(LS_ROW).
    READ TABLE GT_LIST REFERENCE INTO DATA(LR_LIST) INDEX LS_ROW-INDEX.

    CHECK SY-SUBRC IS INITIAL.

    GS_RESULT-SEL += 1.

    CHECK LR_LIST->CHECK EQ ICON_LED_GREEN.

    IF LR_LIST->STAT EQ ICON_LED_GREEN.
      GS_RESULT-INVALID = ABAP_TRUE.
      CONTINUE.
    ENDIF.

    IF LR_LIST->MENGE >= 0.
      GS_RESULT-MENGECHK = ABAP_TRUE.
      CONTINUE.
    ENDIF.

    LR_LIST->SEL = ABAP_TRUE.
    GS_RESULT-TOTAL += 1.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form check_before_cancel_scrap
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM CHECK_BEFORE_CANCEL_SCRAP RAISING LCX_EXCEPTION.
  DATA LV_ANSWER TYPE C.

  PERFORM GET_ROWS_SELECTED_CNCL_POSTING.

  IF GS_RESULT-INVALID IS NOT INITIAL.
    RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E000 WITH TEXT-E33.
  ENDIF.

  IF GS_RESULT-SEL IS INITIAL.
    RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E000 WITH TEXT-E31.
  ENDIF.

  IF GS_RESULT-TOTAL IS INITIAL.
    RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E000 WITH TEXT-E12.
  ENDIF.

  PERFORM CONFIRMATION_POPUP USING TEXT-C06 LV_ANSWER.

  IF LV_ANSWER NE '1'.
    RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E000 WITH SPACE.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form run_cancel_scrap_processing
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM RUN_CANCEL_SCRAP_PROCESSING .
  DATA LT_ITEM TYPE TABLE OF ZGTPPSIF0067.
  DATA LV_MODE TYPE CHAR02 VALUE 'AC'.

  DATA(LT_ZGTPPT1010) = ZGTPP_CL_COMMON=>GET_CODE_VALUE( IV_CODEGRP = '0010' ).
  DATA(LS_ZGTPPT1010) = VALUE #( LT_ZGTPPT1010[ FLD_03 = P_WERKS ] OPTIONAL ).

  LOOP AT GT_LIST REFERENCE INTO DATA(LR_LIST)
                  WHERE SEL EQ ABAP_TRUE.
    PERFORM SET_PARAMETER_SCRAP_PROCESSING TABLES LT_ITEM USING LR_LIST->* LV_MODE.
    PERFORM CALL_IF_MES_SCRAP TABLES LT_ITEM USING LR_LIST->* LV_MODE LS_ZGTPPT1010-FLD_01.
  ENDLOOP.

  GR_LIST->REFRESH( ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_parameter_scrap_processing
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM SET_PARAMETER_SCRAP_PROCESSING  TABLES PT_ITEM STRUCTURE ZGTPPSIF0067
                                     USING  PS_LIST TYPE TY_S_LIST
                                            PV_MODE.

  CLEAR PT_ITEM[].
  APPEND INITIAL LINE TO PT_ITEM REFERENCE INTO DATA(LR_ITEM).

  IF PV_MODE EQ 'A'. "// 스크랩 처리.
    LR_ITEM->* = VALUE #( ZSERNO = |{ SY-DATUM }9{ PS_LIST-SEQNO+1(3) }|
                          WERKS  = PS_LIST-WERKS
                          SPGCD  = PS_LIST-DISPO+(2)
                          MATNR  = PS_LIST-MATNR
                          LGORT  = PS_LIST-LGORT
                          AUFNR  = VALUE #( GT_AUFK[ WERKS = PS_LIST-WERKS
                                                     MATNR = PS_LIST-MATNR
                                                     CHARG = PS_LIST-CHARG ]-AUFNR OPTIONAL )
                          CHARG  = PS_LIST-CHARG
                          TAGNR  = PS_LIST-TAGNR
                          MENGE  = PS_LIST-MENGE
                          MEINS  = PS_LIST-MEINS
                          BUDAT  = GV_TO ).

    LR_ITEM->MENGE = LR_ITEM->MENGE * ( -1 ).

  ELSE.
    LR_ITEM->* = VALUE #( ZSERNO  = |{ SY-DATUM }9{ PS_LIST-SEQNO+1(3) }|
                          WERKS   = PS_LIST-WERKS
                          SPGCD   = PS_LIST-DISPO+(2)
                          MATNR   = PS_LIST-MATNR
                          LGORT   = PS_LIST-LGORT
                          CHARG   = PS_LIST-CHARG
                          TAGNR   = PS_LIST-TAGNR
                          BUDAT   = GV_TO
                          C_MBLNR = PS_LIST-MBLNR
                          C_MJAHR = PS_LIST-INSMM(4) ).
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form call_if_mes_scrap
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM CALL_IF_MES_SCRAP  TABLES PT_ITEM STRUCTURE ZGTPPSIF0067
                        USING PS_LIST TYPE TY_S_LIST
                              PV_MODE
                              PV_SYSTEM_ID.
  DATA LT_RESULT  TYPE TABLE OF ZGTPPSIF0068.
  DATA LV_RESULT  TYPE ZO_RESULT.
  DATA LV_MESSAGE TYPE ZO_MESSAGE.

  CALL FUNCTION 'ZGTPP_IF_I_MES_SCRAP'
    EXPORTING
      I_MODE      = PV_MODE
      I_SYSTEM_ID = CONV CHAR04( PV_SYSTEM_ID )
    IMPORTING
      ZO_RESULT   = LV_RESULT
      ZO_MESSAGE  = LV_MESSAGE
    TABLES
      IT_ITEM     = PT_ITEM
      OT_RESULT   = LT_RESULT.

  DATA(LS_RESULT) = VALUE #( LT_RESULT[ ZERP_STAT = ZGTPP_IF_CONST=>GC_RESULT-SUCCESS ] OPTIONAL ).

  IF LS_RESULT-ZERP_STAT EQ ZGTPP_IF_CONST=>GC_RESULT-SUCCESS.
    PS_LIST-STAT = ICON_LED_GREEN.
    PS_LIST-STAT_MSG = LS_RESULT-ZERP_MESSAGE.

    IF PV_MODE EQ 'A'. "// 재고실사 스크랩 처리.
      PS_LIST-MBLNR = LS_RESULT-MBLNR.

      DATA(LS_ZPPT0610) = CORRESPONDING ZPPT0610( PS_LIST ).
      LS_ZPPT0610 = VALUE #( BASE LS_ZPPT0610  CRDAT = SY-DATUM
                                               CRTIM = SY-UZEIT
                                               CRNAM = SY-UNAME ).
      MODIFY ZPPT0610 FROM LS_ZPPT0610.
    ELSE.             "// 스크랩 처리 취소.
      CLEAR PS_LIST-MBLNR.

      UPDATE ZPPT0610
         SET LOEKZ = @ABAP_TRUE,
             CHDAT = @SY-DATUM,
             CHTIM = @SY-UZEIT,
             CHNAM = @SY-UNAME
       WHERE INSMM   EQ @PS_LIST-INSMM
         AND WERKS   EQ @PS_LIST-WERKS
         AND LGORT   EQ @PS_LIST-LGORT
         AND SEQNO   EQ @PS_LIST-SEQNO
         AND MATNR   EQ @PS_LIST-MATNR
         AND CHARG   EQ @PS_LIST-CHARG
         AND TAGNR   EQ @PS_LIST-TAGNR
         AND ITEM_NO EQ @PS_LIST-ITEM_NO.
    ENDIF.

    COMMIT WORK AND WAIT.
  ELSE.
    PS_LIST-STAT = ICON_LED_RED.
    PS_LIST-STAT_MSG = VALUE #( LT_RESULT[ ZERP_STAT = ZGTPP_IF_CONST=>GC_RESULT-ERROR ]-ZERP_MESSAGE OPTIONAL ).
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form BUILD_MESSAGE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM BUILD_MESSAGE  USING  PS_MESSTAB TYPE BDCMSGCOLL
                           PV_MESSAGE.

  CALL FUNCTION 'FORMAT_MESSAGE'
    EXPORTING
      ID        = PS_MESSTAB-MSGID
      LANG      = SY-LANGU
      NO        = PS_MESSTAB-MSGNR
      V1        = PS_MESSTAB-MSGV1
      V2        = PS_MESSTAB-MSGV2
      V3        = PS_MESSTAB-MSGV3
      V4        = PS_MESSTAB-MSGV4
    IMPORTING
      MSG       = PV_MESSAGE
    EXCEPTIONS
      NOT_FOUND = 1
      OTHERS    = 2.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form adjust_result_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM ADJUST_RESULT_DATA .

  LOOP AT GT_LIST REFERENCE INTO DATA(LR_LIST).
    PERFORM GET_STOCK_QTY USING LR_LIST->*.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_stock_qty
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM GET_STOCK_QTY  USING  PS_LIST TYPE TY_S_LIST.

  IF P_INSMM EQ SY-DATUM+0(6).
    PS_LIST-LABST = COND #( WHEN PS_LIST-VBELN IS NOT INITIAL THEN VALUE #( GT_MSKA[ KEY SKEY MATNR = PS_LIST-MATNR
                                                                                              WERKS = PS_LIST-WERKS
                                                                                              LGORT = PS_LIST-LGORT
                                                                                              CHARG = PS_LIST-CHARG
                                                                                              VBELN = PS_LIST-VBELN
                                                                                              POSNR = PS_LIST-POSNR ]-KALAB OPTIONAL )
                            WHEN PS_LIST-CHARG IS NOT INITIAL THEN VALUE #( GT_MCHB[ KEY SKEY MATNR = PS_LIST-MATNR
                                                                                              WERKS = PS_LIST-WERKS
                                                                                              LGORT = PS_LIST-LGORT
                                                                                              CHARG = PS_LIST-CHARG ]-CLABS OPTIONAL )
                                                              ELSE VALUE #( GT_MARD[ KEY SKEY MATNR = PS_LIST-MATNR
                                                                                              WERKS = PS_LIST-WERKS
                                                                                              LGORT = PS_LIST-LGORT ]-LABST OPTIONAL ) ).
  ELSE.
    PS_LIST-LABST = COND #( WHEN PS_LIST-VBELN IS NOT INITIAL THEN VALUE #( GT_MSKAH[ KEY SKEY MATNR = PS_LIST-MATNR
                                                                                               WERKS = PS_LIST-WERKS
                                                                                               LGORT = PS_LIST-LGORT
                                                                                               CHARG = PS_LIST-CHARG
                                                                                               VBELN = PS_LIST-VBELN
                                                                                               POSNR = PS_LIST-POSNR ]-KALAB OPTIONAL )
                            WHEN PS_LIST-CHARG IS NOT INITIAL THEN VALUE #( GT_MCHBH[ KEY SKEY MATNR = PS_LIST-MATNR
                                                                                               WERKS = PS_LIST-WERKS
                                                                                               LGORT = PS_LIST-LGORT
                                                                                               CHARG = PS_LIST-CHARG ]-CLABS  OPTIONAL )
                                                               ELSE VALUE #( GT_MARDH[ KEY SKEY MATNR = PS_LIST-MATNR
                                                                                                WERKS = PS_LIST-WERKS
                                                                                                LGORT = PS_LIST-LGORT ]-LABST OPTIONAL ) ).
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form Physical_inv_qty_Split
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM PHYSICAL_INV_QTY_SPLIT .
  DATA LT_LIST TYPE TABLE OF TY_S_LIST.
  DATA LT_DATA TYPE TABLE OF TY_S_LIST.
  DATA LV_COUNT TYPE I.
  DATA LV_MENGE TYPE ZPPT0600-MENGE.

  CHECK P_RAW EQ ABAP_TRUE.

  DATA(LT_ZGTPPT1010) = ZGTPP_CL_COMMON=>GET_CODE_VALUE( IV_CODEGRP = '4010' ).
  DATA(LS_ZGTPPT1010) = VALUE #( LT_ZGTPPT1010[ FLD_01 = P_WERKS ] OPTIONAL ).

  DATA(LV_FLD02) = CONV I( LS_ZGTPPT1010-FLD_02 ).

  CHECK LV_FLD02 IS NOT INITIAL.

  LOOP AT GT_MATDOC INTO DATA(LS_MATDOC)
                    WHERE COUNT GT LV_FLD02.
    LV_COUNT = ROUND( VAL  = ( LS_MATDOC-COUNT / LV_FLD02 )
                      DEC  = 0
                      MODE = CL_ABAP_MATH=>ROUND_UP ).

    CLEAR: LT_DATA, LV_MENGE.

*// 수량 분할.
    LOOP AT GT_LIST REFERENCE INTO DATA(LR_LIST)
                    WHERE MATNR EQ LS_MATDOC-MATNR
                      AND WERKS EQ LS_MATDOC-WERKS.
      DO LV_COUNT TIMES.
        APPEND INITIAL LINE TO LT_DATA REFERENCE INTO DATA(LR_DATA).
        LR_DATA->* = LR_LIST->*.
        LR_DATA->MENGE = LR_DATA->MENGE / LV_COUNT.
        LV_MENGE = LV_MENGE + LR_DATA->MENGE.
        CLEAR: LR_DATA->ITEM_NO, LR_DATA->IBLNR, LR_DATA->MBLNR.
      ENDDO.

      IF LR_LIST->MENGE NE LV_MENGE.
        LR_DATA->MENGE = LR_DATA->MENGE + ( LR_LIST->MENGE - LV_MENGE ).
      ENDIF.

      LR_LIST->SEL = ABAP_TRUE.
    ENDLOOP.

*// 이전 처리 내역.
    LOOP AT LT_DATA REFERENCE INTO LR_DATA.
      READ TABLE GT_LIST REFERENCE INTO LR_LIST WITH KEY MATNR = LR_DATA->MATNR
                                                         WERKS = LR_DATA->WERKS
                                                         ERFMG = LR_DATA->ERFMG
                                                         DSTR  = ABAP_FALSE.
      IF SY-SUBRC IS INITIAL.
        LR_DATA->ITEM_NO = LR_LIST->ITEM_NO.
        LR_DATA->IBLNR   = LR_LIST->IBLNR.
        LR_DATA->MBLNR   = LR_LIST->MBLNR.
        LR_LIST->DSTR    = ABAP_TRUE.
      ENDIF.
    ENDLOOP.

    APPEND LINES OF LT_DATA TO LT_LIST.
  ENDLOOP.

  DELETE GT_LIST WHERE SEL EQ ABAP_TRUE.
  APPEND LINES OF LT_LIST TO GT_LIST.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_storage_location_stock
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM GET_STORAGE_LOCATION_STOCK  USING PS_LIST TYPE TY_S_LIST
                                       PV_LABST.

*// 저장위치 재고.

  IF P_INSMM EQ SY-DATUM+0(6).
    SELECT SINGLE LABST
      FROM MARD
     WHERE MATNR EQ @PS_LIST-MATNR
       AND WERKS EQ @PS_LIST-WERKS
       AND LGORT EQ @PS_LIST-LGORT
      INTO @PV_LABST.
  ELSE.
    SELECT SINGLE LABST
      FROM MARDH
     WHERE MATNR EQ @PS_LIST-MATNR
       AND WERKS EQ @PS_LIST-WERKS
       AND LGORT EQ @PS_LIST-LGORT
       AND CONCAT( LFGJA, LFMON ) EQ @P_INSMM
      INTO @PV_LABST.
  ENDIF.

ENDFORM.
