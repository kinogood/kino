*&---------------------------------------------------------------------*
*& Include          ZGTPPI2030F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form initialization
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM INITIALIZATION.

  IF GT_DDLB IS INITIAL.
    CLEAR: GT_ZGTPPT1010.

    SELECT *
      FROM ZGTPPT1010
     WHERE MODULE_KIND = 'PP'
       AND CODEGRP = '0010'
       AND FLD_04 NE @SPACE
      INTO CORRESPONDING FIELDS OF TABLE @GT_ZGTPPT1010.

    LOOP AT GT_ZGTPPT1010 INTO DATA(LS_CODE).
      CHECK LS_CODE-FLD_03+(1) EQ '6' AND LS_CODE-FLD_04 IS NOT INITIAL.

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
      PERFORM GET_CUTTING_ORDER.
      PERFORM MODIFY_DATA.
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

  IF PR_SENDER EQ GR_ITEM.
    PERFORM MODIFY_FCAT_IN_ITEM.
  ENDIF.

  IF PR_SENDER EQ GR_BOM.
    PERFORM MODIFY_FCAT_IN_BOM.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form handle_layout
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM HANDLE_LAYOUT USING PR_SENDER.

  IF PR_SENDER EQ GR_HEADER.
    PERFORM SET_LAYOUT_IN_HEADER.
  ENDIF.

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
*
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

ENDFORM.
*&---------------------------------------------------------------------*
*& Form call_screen_100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM CALL_SCREEN_100 .

  GV_TPAR1 = COND #( WHEN P_SEND EQ ABAP_TRUE THEN TEXT-C11
                     ELSE TEXT-C12 ).

  TABSTRIP-ACTIVETAB = GC_FCODE-TAB1.
  GV_DYNNR = '0110'.

  CALL SCREEN 100.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_cutting_order
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM GET_CUTTING_ORDER .

  SELECT ZT01~ZCUT_ORD_NO, ZT01~ZCUT_ORD_ITEM, ZT01~LOEKZ, ZT01~ZCUT_LEN,
         ZT01~ZCUT_CNT, ZT01~ZREW_YN, ZT01~SOBKZ, ZT01~MULTI_YN,
         ZT01~ORG_LENGTH, ZT01~CRDAT,
         ZT02~WERKS, ZT02~ZASSIGN_TYPE, ZT02~MATNR, ZT02~VKORG,
         ZT02~VKGRP, ZT02~VBELN, ZT02~POSNR, ZT02~ETENR, ZT02~EDATU,
         ZT02~WEMENG, ZT02~VRKME, ZT02~WELENG, ZT02~WECNT,
         ZT03~LGORT, ZT03~ZORD_TYPE, ZT03~F_CHARG, ZT03~LABST3,
         ZT04~POSNR AS ZPOSNR, ZT04~BDMNG, ZT04~MEINS, ZT04~LGORT AS ZLGORT,
         ZT04~MATNR AS ZMATNR, MKT1~MAKTX, MKT2~MAKTX AS ZMAKTX,
         T001L~LGOBE, VBKD~KDKG4,
         @ICON_LED_INACTIVE AS STATUS,
         @P_SYSID  AS ZSYSTEM_ID,
         @GV_SYSTX AS SYSTX
    FROM ZGTPPT2190 AS ZT01
    JOIN ZGTPPT2170 AS ZT02
      ON ZT01~ZASSIGN_NO EQ ZT02~ZASSIGN_NO
    JOIN ZGTPPT2180 AS ZT03
      ON ZT01~ZASSIGN_NO   EQ ZT03~ZASSIGN_NO
     AND ZT01~ZASSIGN_ITEM EQ ZT03~ZASSIGN_ITEM
    LEFT JOIN ZGTPPT2191 AS ZT04
      ON ZT01~ZCUT_ORD_NO   EQ ZT04~ZCUT_ORD_NO
     AND ZT01~ZCUT_ORD_ITEM EQ ZT04~ZCUT_ORD_ITEM
    JOIN MARC
      ON ZT02~MATNR EQ MARC~MATNR
     AND ZT02~WERKS EQ MARC~WERKS
    LEFT JOIN VBKD
      ON ZT02~VBELN EQ VBKD~VBELN
     AND VBKD~POSNR EQ '000000'
    LEFT JOIN MAKT AS MKT1
      ON ZT02~MATNR EQ MKT1~MATNR
     AND MKT1~SPRAS EQ @SY-LANGU
    LEFT JOIN MAKT AS MKT2
      ON ZT04~MATNR EQ MKT2~MATNR
     AND MKT2~SPRAS EQ @SY-LANGU
    LEFT JOIN T001L
      ON ZT02~WERKS EQ T001L~WERKS
     AND ZT03~LGORT EQ T001L~LGORT
   WHERE ZT01~WERKS        IN @GT_WERKS
     AND ZT02~ZASSIGN_NO   IN @S_ZASGNO
     AND ZT02~ZASSIGN_TYPE IN @S_ZASGTP
     AND ZT01~ZCUT_ORD_NO  IN @S_ZCUTNO
     AND ZT02~VBELN IN @S_VBELN
     AND ZT02~POSNR IN @S_POSNR
     AND ZT02~VKBUR IN @S_VKBUR
     AND ZT02~KUNNR IN @S_KUNNR
     AND ZT02~EDATU IN @S_EDATU
     AND ZT02~MATNR IN @S_MATNR
     AND MARC~FEVOR IN @S_FEVOR
     AND ZT01~CRDAT IN @S_ERDAT
   ORDER BY ZT01~ZCUT_ORD_NO, ZT01~ZCUT_ORD_ITEM, ZT04~POSNR
    INTO TABLE @DATA(LT_BASE).

  LOOP AT LT_BASE INTO DATA(LS_BASE)
                  GROUP BY ( ZCUT_ORD_NO = LS_BASE-ZCUT_ORD_NO )
                  INTO DATA(LT_GROUP).

    LOOP AT GROUP LT_GROUP INTO DATA(LS_GROUP).
      IF NOT LINE_EXISTS( GT_HEADER[ KEY SKEY1 ZCUT_ORD_NO = LS_GROUP-ZCUT_ORD_NO ] ).
        APPEND INITIAL LINE TO GT_HEADER REFERENCE INTO DATA(LR_HEADER).
        LR_HEADER->* = CORRESPONDING #( LS_GROUP ).

        CLEAR: LR_HEADER->LOEKZ. "헤더의 삭제지시자는 사용 안함

        PERFORM GET_ZZYUSCD USING LR_HEADER->*.
      ENDIF.

      IF NOT LINE_EXISTS( LR_HEADER->ITEM[ KEY SKEY1 ZCUT_ORD_NO   = LS_GROUP-ZCUT_ORD_NO
                                                     ZCUT_ORD_ITEM = LS_GROUP-ZCUT_ORD_ITEM ] ).
        APPEND INITIAL LINE TO LR_HEADER->ITEM REFERENCE INTO DATA(LR_ITEM).
        LR_ITEM->* = CORRESPONDING #( LS_GROUP ).
      ENDIF.

      IF LS_GROUP-ZPOSNR IS NOT INITIAL.
        IF NOT LINE_EXISTS( LR_HEADER->BOM[ KEY SKEY1 ZCUT_ORD_NO   = LS_GROUP-ZCUT_ORD_NO
                                                      ZCUT_ORD_ITEM = LS_GROUP-ZCUT_ORD_ITEM
                                                      POSNR         = LS_GROUP-ZPOSNR ] ).
          APPEND INITIAL LINE TO LR_HEADER->BOM REFERENCE INTO DATA(LR_BOM).
          LR_BOM->* = VALUE #( BASE CORRESPONDING #( LS_GROUP ) POSNR = LS_GROUP-ZPOSNR
                                                                MATNR = LS_GROUP-ZMATNR
                                                                MAKTX = LS_GROUP-ZMAKTX
                                                                LGORT = LS_GROUP-ZLGORT ).
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_transfer_log
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM GET_TRANSFER_LOG .

  SELECT ZT01~ZIFKEY, ZT01~ZCUT_ORD_NO, ZT01~ZSYSTEM_ID, ZT01~WERKS, "ZT01~LOEKZ,
         ZT01~ZASSIGN_TYPE, ZT01~VBELN, ZT01~POSNR, ZT01~ETENR,
         ZT01~EDATU, ZT01~DRDAT, ZT01~WEMENG, ZT01~VRKME, ZT01~WELENG, ZT01~WECNT,
         ZT01~MATNR, ZT01~ZZYUSCD, ZT01~ZSTAT, ZT01~ZMESSAGE,
         ZT01~ZERP_STAT, ZT01~ZERP_MESSAGE, ZT01~IFDAT, ZT01~IFTIM, ZT01~IFNAM,
         ZT02~ZCUT_ORD_ITEM, ZT02~LOEKZ, ZT02~LGORT, ZT02~F_CHARG, ZT02~ZORD_TYPE,
         ZT02~ZCUT_LEN, ZT02~ZCUT_CNT, ZT02~ZREW_YN, ZT02~SOBKZ, ZT02~LABST3,
         ZT02~F_TAGNR, ZT02~MULTI_YN, ZT02~ORG_LENGTH,
         ZT03~POSNR AS ZPOSNR, ZT03~MATNR AS ZMATNR, ZT03~BDMNG, ZT03~MEINS,
         ZT03~LGORT AS ZLGORT,
         MKT1~MAKTX, MKT2~MAKTX AS ZMAKTX,T001L~LGOBE,
         @GV_SYSTX AS SYSTX,
         CASE WHEN ZT01~ZSTAT EQ @ZGTPP_IF_CONST=>GC_IF_REC_RESULT-SUCCESS THEN @ICON_LED_GREEN
              WHEN ZT01~ZSTAT EQ @SPACE                                    THEN @ICON_LED_INACTIVE
              ELSE @ICON_LED_RED
         END AS STATUS
    FROM ZGTPPT2200 AS ZT01
    JOIN ZGTPPT2210 AS ZT02
      ON ZT01~ZIFKEY      EQ ZT02~ZIFKEY
     AND ZT01~ZCUT_ORD_NO EQ ZT02~ZCUT_ORD_NO
    LEFT JOIN ZGTPPT2220 AS ZT03
      ON ZT02~ZIFKEY        EQ ZT03~ZIFKEY
     AND ZT02~ZCUT_ORD_NO   EQ ZT03~ZCUT_ORD_NO
     AND ZT02~ZCUT_ORD_ITEM EQ ZT03~ZCUT_ORD_ITEM
    JOIN MARC
      ON ZT01~MATNR EQ MARC~MATNR
     AND ZT01~WERKS EQ MARC~WERKS
    LEFT JOIN MAKT AS MKT1
      ON ZT01~MATNR EQ MKT1~MATNR
     AND MKT1~SPRAS EQ @SY-LANGU
    LEFT JOIN MAKT AS MKT2
      ON ZT03~MATNR EQ MKT2~MATNR
     AND MKT2~SPRAS EQ @SY-LANGU
    LEFT JOIN T001L
      ON ZT01~WERKS EQ T001L~WERKS
     AND ZT02~LGORT EQ T001L~LGORT
   WHERE ZT01~WERKS       IN @GT_WERKS
     AND ZT01~ZCUT_ORD_NO IN @S_ZCUTNO
     AND ZT01~ZSYSTEM_ID  EQ @P_SYSID
     AND ZT01~VBELN       IN @S_VBELN
     AND ZT01~POSNR       IN @S_POSNR
     AND ZT01~MATNR       IN @S_MATNR
     AND MARC~FEVOR       IN @S_FEVOR
     AND ZT01~ZSTAT       IN @GT_ZSTAT
     AND ZT01~IFDAT       IN @S_IFDAT
    INTO TABLE @DATA(LT_LOG).

  LOOP AT LT_LOG INTO DATA(LS_LOG)
                 GROUP BY ( ZIFKEY      = LS_LOG-ZIFKEY
                            ZCUT_ORD_NO = LS_LOG-ZCUT_ORD_NO  )
                 INTO DATA(LT_GROUP).

    LOOP AT GROUP LT_GROUP INTO DATA(LS_GROUP).
      IF NOT LINE_EXISTS( GT_HEADER[ KEY SKEY2 ZIFKEY      = LS_GROUP-ZIFKEY
                                               ZCUT_ORD_NO = LS_GROUP-ZCUT_ORD_NO ] ).
        APPEND INITIAL LINE TO GT_HEADER REFERENCE INTO DATA(LR_HEADER).
        LR_HEADER->* = CORRESPONDING #( LS_GROUP ).

        "절단오더생성일
        SELECT SINGLE CRDAT
          FROM ZGTPPT2190
         WHERE ZCUT_ORD_NO EQ @LR_HEADER->ZCUT_ORD_NO
          INTO @LR_HEADER->CRDAT.
      ENDIF.

      IF NOT LINE_EXISTS( LR_HEADER->ITEM[ KEY SKEY2 ZIFKEY        = LS_GROUP-ZIFKEY
                                                     ZCUT_ORD_NO   = LS_GROUP-ZCUT_ORD_NO
                                                     ZCUT_ORD_ITEM = LS_GROUP-ZCUT_ORD_ITEM ] ).
        APPEND INITIAL LINE TO LR_HEADER->ITEM REFERENCE INTO DATA(LR_ITEM).
        LR_ITEM->* = CORRESPONDING #( LS_GROUP ).
      ENDIF.

      IF LS_GROUP-ZPOSNR IS NOT INITIAL.
        IF NOT LINE_EXISTS( LR_HEADER->BOM[ KEY SKEY2 ZIFKEY        = LS_GROUP-ZIFKEY
                                                      ZCUT_ORD_NO   = LS_GROUP-ZCUT_ORD_NO
                                                      ZCUT_ORD_ITEM = LS_GROUP-ZCUT_ORD_ITEM
                                                      POSNR         = LS_GROUP-ZPOSNR ] ).
          APPEND INITIAL LINE TO LR_HEADER->BOM REFERENCE INTO DATA(LR_BOM).
          LR_BOM->* = VALUE #( BASE CORRESPONDING #( LS_GROUP ) POSNR = LS_GROUP-ZPOSNR
                                                                MATNR = LS_GROUP-ZMATNR
                                                                MAKTX = LS_GROUP-ZMAKTX
                                                                LGORT = LS_GROUP-ZLGORT ).
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form modify_fcat_in_header
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM MODIFY_FCAT_IN_HEADER .

  LOOP AT GR_HEADER->MT_FCAT REFERENCE INTO DATA(LR_FCAT).
    LR_FCAT->COL_OPT = 'A'.

    CASE LR_FCAT->FIELDNAME.
      WHEN 'ZIFKEY'.
        LR_FCAT->COLTEXT    = TEXT-F00.
        LR_FCAT->JUST       = 'C'.
        LR_FCAT->TECH       = COND #( WHEN P_SEND EQ ABAP_TRUE THEN ABAP_TRUE ).
        LR_FCAT->KEY        = ABAP_TRUE.

      WHEN 'STATUS'.
        LR_FCAT->COLTEXT    = TEXT-F01.
        LR_FCAT->JUST       = 'C'.

      WHEN 'ZMESSAGE'.
        LR_FCAT->COLTEXT    = TEXT-F02.

      WHEN 'ZSYSTEM_ID'.
        LR_FCAT->COLTEXT    = TEXT-F03.
        LR_FCAT->JUST       = 'C'.

      WHEN 'SYSTX'.
        LR_FCAT->COLTEXT    = TEXT-F04.

      WHEN 'ZCUT_ORD_NO'.
        LR_FCAT->COLTEXT    = TEXT-F05.
        LR_FCAT->JUST       = 'C'.
        LR_FCAT->EMPHASIZE  = 'C500'.

      WHEN 'CRDAT'.
        LR_FCAT->COLTEXT    = TEXT-F63.
        LR_FCAT->JUST       = 'C'.
        LR_FCAT->EMPHASIZE  = 'C500'.

      WHEN 'WERKS'.
        LR_FCAT->COLTEXT    = TEXT-F06.
        LR_FCAT->JUST       = 'C'.

*      WHEN 'LOEKZ'.
*        LR_FCAT->COLTEXT    = TEXT-F07.
*        LR_FCAT->CHECKBOX   = ABAP_TRUE.

      WHEN 'ZASSIGN_TYPE'.
        LR_FCAT->COLTEXT    = TEXT-F08.
        LR_FCAT->JUST       = 'C'.

      WHEN 'VBELN'.
        LR_FCAT->COLTEXT    = TEXT-F09.
        LR_FCAT->JUST       = 'C'.
        LR_FCAT->EMPHASIZE  = 'C100'.

      WHEN 'POSNR'.
        LR_FCAT->COLTEXT    = TEXT-F10.
        LR_FCAT->JUST       = 'C'.
        LR_FCAT->EMPHASIZE  = 'C100'.

      WHEN 'ETENR'.
        LR_FCAT->COLTEXT    = TEXT-F11.
        LR_FCAT->EMPHASIZE  = 'C100'.

      WHEN 'EDATU'.
        LR_FCAT->COLTEXT    = TEXT-F12.
        LR_FCAT->JUST       = 'C'.

      WHEN 'DRDAT'.
        LR_FCAT->COLTEXT    = TEXT-F62.
        LR_FCAT->JUST       = 'C'.

      WHEN 'WEMENG'.
        LR_FCAT->COLTEXT    = TEXT-F13.

      WHEN 'VRKME'.
        LR_FCAT->COLTEXT    = TEXT-F14.
        LR_FCAT->JUST       = 'C'.

      WHEN 'WELENG'.
        LR_FCAT->COLTEXT    = TEXT-F15.

      WHEN 'WECNT'.
        LR_FCAT->COLTEXT    = TEXT-F16.

      WHEN 'MATNR'.
        LR_FCAT->COLTEXT    = TEXT-F17.
        LR_FCAT->EMPHASIZE  = 'C700'.

      WHEN 'MAKTX'.
        LR_FCAT->COLTEXT    = TEXT-F18.
        LR_FCAT->EMPHASIZE  = 'C700'.

      WHEN 'ZZYUSCD'.
        LR_FCAT->COLTEXT    = TEXT-F19.
        LR_FCAT->JUST       = 'C'.

      WHEN 'IFDAT'.
        IF P_SEND EQ 'X'.
          LR_FCAT->COLTEXT    = TEXT-F67.
        ELSEIF P_LOG EQ 'X'.
          LR_FCAT->COLTEXT    = TEXT-F64.
        ENDIF.

      WHEN 'IFTIM'.
        IF P_SEND EQ 'X'.
          LR_FCAT->COLTEXT    = TEXT-F68.
        ELSEIF P_LOG EQ 'X'.
          LR_FCAT->COLTEXT    = TEXT-F65.
        ENDIF.

      WHEN 'IFNAM'.
        IF P_SEND EQ 'X'.
          LR_FCAT->COLTEXT    = TEXT-F69.
        ELSEIF P_LOG EQ 'X'.
          LR_FCAT->COLTEXT    = TEXT-F66.
        ENDIF.

      WHEN OTHERS.
        LR_FCAT->TECH = ABAP_TRUE.
    ENDCASE.

    LR_FCAT->TOOLTIP = LR_FCAT->REPTEXT = LR_FCAT->COLTEXT.
    LR_FCAT->SCRTEXT_S = LR_FCAT->SCRTEXT_M = LR_FCAT->SCRTEXT_L = LR_FCAT->COLTEXT.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_layout_in_header
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM SET_LAYOUT_IN_HEADER .

  TRY.
      IF P_BATCH IS NOT INITIAL AND SY-BATCH IS INITIAL.
        MESSAGE S009 WITH GS_RESULT-TOTAL GS_RESULT-SUCCESS GS_RESULT-ERROR INTO GR_HEADER->MS_LAYOUT-GRID_TITLE.
      ENDIF.

    CATCH CX_ROOT.

  ENDTRY.

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
      GT_ITEM = LR_HEADER->ITEM.
      GT_BOM  = LR_HEADER->BOM.

      SORT GT_ITEM BY ZIFKEY ZCUT_ORD_NO ZCUT_ORD_ITEM.
      SORT GT_BOM  BY ZIFKEY ZCUT_ORD_NO ZCUT_ORD_ITEM POSNR.

      GR_ITEM->REFRESH( ).
      GR_BOM->REFRESH( ).

    CATCH CX_ROOT.
  ENDTRY.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_search_condition
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM SET_SEARCH_CONDITION.

  GT_WERKS = VALUE #( FOR LS_ZGTPPT1010 IN GT_ZGTPPT1010 WHERE ( FLD_01 = P_SYSID )
                    ( SIGN = 'I' OPTION = 'EQ' LOW = LS_ZGTPPT1010-FLD_03 ) ).

  GV_SYSTX = VALUE #( GT_DDLB[ KEY = P_SYSID ]-TEXT OPTIONAL ).

  IF P_LOG EQ ABAP_TRUE.
    GT_ZSTAT = COND #( WHEN P_SUC   EQ ABAP_TRUE THEN VALUE #( SIGN = 'I' OPTION = 'EQ' ( LOW = '00' )
                                                                                        ( LOW = 'S'  ) )
                       WHEN P_ERROR EQ ABAP_TRUE THEN VALUE #( SIGN = 'I' OPTION = 'EQ' ( LOW = '01' )
                                                                                        ( LOW = 'E'  ) ) ).
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form modify_fcat_in_item
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM MODIFY_FCAT_IN_ITEM .

  LOOP AT GR_ITEM->MT_FCAT REFERENCE INTO DATA(LR_FCAT).
    LR_FCAT->COL_OPT = 'A'.

    CASE LR_FCAT->FIELDNAME.
      WHEN 'ZIFKEY'.
        LR_FCAT->COLTEXT    = TEXT-F00.
        LR_FCAT->JUST       = 'C'.
        LR_FCAT->TECH       = COND #( WHEN P_SEND EQ ABAP_TRUE THEN ABAP_TRUE ).
        LR_FCAT->KEY        = ABAP_TRUE.

      WHEN 'ZCUT_ORD_NO'.
        LR_FCAT->COLTEXT    = TEXT-F31.
        LR_FCAT->JUST       = 'C'.
        LR_FCAT->EMPHASIZE  = 'C500'.

      WHEN 'ZCUT_ORD_ITEM'.
        LR_FCAT->COLTEXT    = TEXT-F32.
        LR_FCAT->JUST       = 'C'.
        LR_FCAT->EMPHASIZE  = 'C500'.

      WHEN 'LOEKZ'.
        LR_FCAT->COLTEXT    = TEXT-F07.
        LR_FCAT->CHECKBOX   = ABAP_TRUE.

      WHEN 'LGORT'.
        LR_FCAT->COLTEXT    = TEXT-F33.
        LR_FCAT->JUST       = 'C'.

      WHEN 'LGOBE'.
        LR_FCAT->COLTEXT    = TEXT-F34.

      WHEN 'F_CHARG'.
        LR_FCAT->COLTEXT    = TEXT-F35.

      WHEN 'F_TAGNR'.
        LR_FCAT->COLTEXT    = TEXT-F59.
        LR_FCAT->JUST       = 'C'.

      WHEN 'ZORD_TYPE'.
        LR_FCAT->COLTEXT    = TEXT-F36.
        LR_FCAT->JUST       = 'C'.

      WHEN 'ZCUT_LEN'.
        LR_FCAT->COLTEXT    = TEXT-F37.

      WHEN 'ZCUT_CNT'.
        LR_FCAT->COLTEXT    = TEXT-F38.

      WHEN 'ZREW_YN'.
        LR_FCAT->COLTEXT    = TEXT-F39.
        LR_FCAT->JUST       = 'C'.

      WHEN 'SOBKZ'.
        LR_FCAT->COLTEXT    = TEXT-F40.
        LR_FCAT->JUST       = 'C'.

      WHEN 'MULTI_YN'.
        LR_FCAT->COLTEXT    = TEXT-F60.
        LR_FCAT->JUST       = 'C'.

      WHEN 'ORG_LENGTH'.
        LR_FCAT->COLTEXT    = TEXT-F61.

      WHEN 'LABST3'.
        LR_FCAT->COLTEXT    = TEXT-F41.
        LR_FCAT->NO_ZERO    = ABAP_TRUE.

      WHEN OTHERS.
        LR_FCAT->TECH = ABAP_TRUE.
    ENDCASE.

    LR_FCAT->TOOLTIP = LR_FCAT->REPTEXT = LR_FCAT->COLTEXT.
    LR_FCAT->SCRTEXT_S = LR_FCAT->SCRTEXT_M = LR_FCAT->SCRTEXT_L = LR_FCAT->COLTEXT.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form modify_fcat_in_bom
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM MODIFY_FCAT_IN_BOM .

  LOOP AT GR_BOM->MT_FCAT REFERENCE INTO DATA(LR_FCAT).
    LR_FCAT->COL_OPT = 'A'.

    CASE LR_FCAT->FIELDNAME.
      WHEN 'ZIFKEY'.
        LR_FCAT->COLTEXT    = TEXT-F00.
        LR_FCAT->JUST       = 'C'.
        LR_FCAT->TECH       = COND #( WHEN P_SEND EQ ABAP_TRUE THEN ABAP_TRUE ).
        LR_FCAT->KEY        = ABAP_TRUE.

      WHEN 'ZCUT_ORD_NO'.
        LR_FCAT->COLTEXT    = TEXT-F51.
        LR_FCAT->JUST       = 'C'.
        LR_FCAT->EMPHASIZE  = 'C500'.

      WHEN 'ZCUT_ORD_ITEM'.
        LR_FCAT->COLTEXT    = TEXT-F52.
        LR_FCAT->JUST       = 'C'.
        LR_FCAT->EMPHASIZE  = 'C500'.

      WHEN 'POSNR'.
        LR_FCAT->COLTEXT    = TEXT-F53.
        LR_FCAT->JUST       = 'C'.
        LR_FCAT->EMPHASIZE  = 'C500'.

      WHEN 'MATNR'.
        LR_FCAT->COLTEXT    = TEXT-F54.

      WHEN 'MAKTX'.
        LR_FCAT->COLTEXT    = TEXT-F55.

      WHEN 'BDMNG'.
        LR_FCAT->COLTEXT    = TEXT-F56.

      WHEN 'MEINS'.
        LR_FCAT->COLTEXT    = TEXT-F57.
        LR_FCAT->JUST       = 'C'.

      WHEN 'LGORT'.
        LR_FCAT->COLTEXT    = TEXT-F58.
        LR_FCAT->JUST       = 'C'.

      WHEN OTHERS.
        LR_FCAT->TECH = ABAP_TRUE.
    ENDCASE.

    LR_FCAT->TOOLTIP = LR_FCAT->REPTEXT = LR_FCAT->COLTEXT.
    LR_FCAT->SCRTEXT_S = LR_FCAT->SCRTEXT_M = LR_FCAT->SCRTEXT_L = LR_FCAT->COLTEXT.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Module CREATE_ALV_110 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE CREATE_ALV_110 OUTPUT.

  TRY.
      IF GR_ITEM IS NOT BOUND.
        GR_ITEM = NEW #( ).
        GR_ITEM->DISPLAY( EXPORTING IR_HANDLER   = NEW LCL_LIST_HANDLER( )
                                    IR_CONTAINER = NEW CL_GUI_CUSTOM_CONTAINER( CONTAINER_NAME = 'CONT2' )
                          CHANGING  CT_DATA      = GT_ITEM ).
      ENDIF.

    CATCH CX_ROOT INTO LR_ROOT.
      MESSAGE LR_ROOT->GET_TEXT( ) TYPE 'I' DISPLAY LIKE 'E'.
  ENDTRY.

ENDMODULE.
*&---------------------------------------------------------------------*
*& Module CREATE_ALV_120 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE CREATE_ALV_120 OUTPUT.

  TRY.
      IF GR_BOM IS NOT BOUND.
        GR_BOM = NEW #( ).
        GR_BOM->DISPLAY( EXPORTING IR_HANDLER   = NEW LCL_LIST_HANDLER( )
                                   IR_CONTAINER = NEW CL_GUI_CUSTOM_CONTAINER( CONTAINER_NAME = 'CONT3' )
                          CHANGING CT_DATA      = GT_BOM ).
      ENDIF.

    CATCH CX_ROOT INTO LR_ROOT.
      MESSAGE LR_ROOT->GET_TEXT( ) TYPE 'I' DISPLAY LIKE 'E'.
  ENDTRY.

ENDMODULE.
*&---------------------------------------------------------------------*
*& Form set_subscreen
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM SET_SUBSCREEN  USING PV_CODE.

  TABSTRIP-ACTIVETAB = PV_CODE.
  GV_DYNNR = COND #( WHEN PV_CODE EQ GC_FCODE-TAB1 THEN '0110'
                     ELSE '0120' ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_ZZYUSCD
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM GET_ZZYUSCD  USING  PS_HEADER TYPE TY_S_HEADER.

  CALL FUNCTION 'ZGTSD_GET_ZZYUSCD'
    EXPORTING
      I_VKORG   = PS_HEADER-VKORG
      I_VKGRP   = PS_HEADER-VKGRP
      I_KDKG4   = PS_HEADER-KDKG4
    IMPORTING
      E_ZZYUSCD = PS_HEADER-ZZYUSCD.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form user_command_send
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM USER_COMMAND_SEND .

  TRY.
      PERFORM CHECK_BEFORE_SEND.  "// 사전점검.
      PERFORM SEND_CUTTING_ORDER. "// 절단 오더 전송.

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
*& Form check_before_send
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM CHECK_BEFORE_SEND  RAISING LCX_EXCEPTION.
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
*& Form send_cutting_order
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM SEND_CUTTING_ORDER .

  PERFORM SET_FUNC_PARAMETERS.

  PERFORM CALL_RFC_FUCNTION.

  PERFORM SAVE_TRANSFER_LOG.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_rows_selected_for_SEND
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM GET_ROWS_SELECTED_FOR_SEND .

  CLEAR GS_RESULT.

  IF P_BATCH IS NOT INITIAL.
    MODIFY GT_HEADER FROM VALUE #( SEL = ABAP_TRUE )
                     TRANSPORTING SEL
                     WHERE SEL EQ ABAP_FALSE.
    GS_RESULT-TOTAL = LINES( GT_HEADER ).
    GS_RESULT-SEL = GS_RESULT-TOTAL.
    RETURN.
  ENDIF.

  MODIFY GT_HEADER FROM VALUE #( SEL = ABAP_FALSE )
                   TRANSPORTING SEL
                   WHERE SEL EQ ABAP_TRUE.

  GR_HEADER->MR_GRID->GET_SELECTED_ROWS( IMPORTING ET_INDEX_ROWS = DATA(LT_ROWS) ).
  DELETE LT_ROWS WHERE ROWTYPE NE SPACE.

  IF LT_ROWS IS INITIAL.
    RETURN.
  ENDIF.

*// 선택된 데이터 유효성 점검.
  LOOP AT LT_ROWS INTO DATA(LS_ROW).
    GS_RESULT-SEL += 1.

    READ TABLE GT_HEADER REFERENCE INTO DATA(LR_HEADER) INDEX LS_ROW-INDEX.
    CHECK SY-SUBRC IS INITIAL.

    CHECK LR_HEADER->STATUS NE ICON_LED_GREEN.

    GS_RESULT-TOTAL += 1.

    LR_HEADER->SEL = ABAP_TRUE.
  ENDLOOP.

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

  CLEAR: GT_ITEM, GT_BOM.

  LOOP AT LT_ROWS INTO DATA(LS_ROW).
    READ TABLE GT_HEADER REFERENCE INTO DATA(LR_HEADER) INDEX LS_ROW-INDEX.
    CHECK SY-SUBRC IS INITIAL.

    APPEND LINES OF LR_HEADER->ITEM TO GT_ITEM.
    APPEND LINES OF LR_HEADER->BOM  TO GT_BOM.
  ENDLOOP.

  TRY.
      GR_ITEM->REFRESH( ).
      GR_BOM->REFRESH( ).

    CATCH CX_ROOT.
  ENDTRY.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form save_transfer_log
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM SAVE_TRANSFER_LOG .

  MODIFY GT_ZGTPPT2200 FROM VALUE #( ZSTAT      = GS_RESULT-ZSTAT
                                     ZMESSAGE   = GS_RESULT-ZMESSAGE
                                     IFDAT      = SY-DATUM
                                     IFTIM      = SY-UZEIT
                                     IFNAM      = SY-UNAME  )
                       TRANSPORTING ZSTAT ZMESSAGE IFDAT IFTIM IFNAM
                       WHERE ZSYSTEM_ID EQ P_SYSID.

  TRY.
      MODIFY ZGTPPT2200 FROM TABLE GT_ZGTPPT2200.
      MODIFY ZGTPPT2210 FROM TABLE GT_ZGTPPT2210.
      MODIFY ZGTPPT2220 FROM TABLE GT_ZGTPPT2220.

    CATCH CX_ROOT INTO DATA(LR_ROOT).
      DATA(LV_SUBRC) = 4.
  ENDTRY.

  IF LV_SUBRC IS INITIAL.
    COMMIT WORK AND WAIT.
  ELSE.
    ROLLBACK WORK.
    MESSAGE E000 WITH TEXT-E02.
  ENDIF.

  MODIFY GT_HEADER FROM VALUE #( STATUS   = COND #( WHEN GS_RESULT-ERROR IS INITIAL THEN ICON_LED_GREEN
                                                    ELSE ICON_LED_RED )
                                 ZSTAT    = GS_RESULT-ZSTAT
                                 ZMESSAGE = GS_RESULT-ZMESSAGE )
                   TRANSPORTING STATUS ZSTAT ZMESSAGE
                   WHERE SEL EQ ABAP_TRUE.

  IF P_BATCH IS INITIAL.
    IF GR_HEADER IS BOUND.
      GR_HEADER->REFRESH( ).
    ENDIF.
  ELSE.
    GR_HEADER = NEW #( ).
    GR_HEADER->DISPLAY( EXPORTING IR_HANDLER   = NEW LCL_LIST_HANDLER( )
                                  IR_CONTAINER = CL_GUI_CONTAINER=>SCREEN0
                         CHANGING CT_DATA      = GT_HEADER ).
    WRITE:/ ' '.
  ENDIF.

  MESSAGE S009 WITH GS_RESULT-TOTAL GS_RESULT-SUCCESS GS_RESULT-ERROR.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_func_parameters
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM SET_FUNC_PARAMETERS .

  CLEAR: GT_ORDER_H, GT_ORDER_I, GT_ORDER_BOM,
         GT_ZGTPPT2200, GT_ZGTPPT2210, GT_ZGTPPT2220.

  LOOP AT GT_HEADER INTO DATA(LS_HEADER)
                    WHERE SEL EQ ABAP_TRUE.
    APPEND CORRESPONDING #( LS_HEADER ) TO GT_ORDER_H.
    GT_ORDER_I   = CORRESPONDING #( BASE ( GT_ORDER_I )   LS_HEADER-ITEM[] ).
    GT_ORDER_BOM = CORRESPONDING #( BASE ( GT_ORDER_BOM ) LS_HEADER-BOM[] ).

    APPEND CORRESPONDING #( LS_HEADER ) TO GT_ZGTPPT2200.
    GT_ZGTPPT2210 = CORRESPONDING #( BASE ( GT_ZGTPPT2210 ) LS_HEADER-ITEM[] ).
    GT_ZGTPPT2220 = CORRESPONDING #( BASE ( GT_ZGTPPT2220 ) LS_HEADER-BOM[] ).
  ENDLOOP.

  LOOP AT GT_ORDER_H REFERENCE INTO DATA(LR_ORDER_H).
    PERFORM CONVERSION_EXIT_MATN1_OUTPUT USING LR_ORDER_H->MATNR.
  ENDLOOP.

  LOOP AT GT_ORDER_BOM REFERENCE INTO DATA(LR_ORDER_BOM).
    PERFORM CONVERSION_EXIT_MATN1_OUTPUT USING LR_ORDER_BOM->MATNR.
  ENDLOOP.

  CHECK P_SEND EQ ABAP_TRUE.

  GET TIME STAMP FIELD DATA(LV_ZIFKEY).

  MODIFY GT_ZGTPPT2200 FROM VALUE #( ZIFKEY     = LV_ZIFKEY
                                     ZSYSTEM_ID = P_SYSID )
                       TRANSPORTING ZIFKEY ZSYSTEM_ID
                       WHERE ZIFKEY IS INITIAL.

  MODIFY GT_ZGTPPT2210 FROM VALUE #( ZIFKEY = LV_ZIFKEY )
                       TRANSPORTING ZIFKEY
                       WHERE ZIFKEY IS INITIAL.

  MODIFY GT_ZGTPPT2220 FROM VALUE #( ZIFKEY = LV_ZIFKEY )
                       TRANSPORTING ZIFKEY
                       WHERE ZIFKEY IS INITIAL.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form call_rfc_fucntion
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM CALL_RFC_FUCNTION .
  DATA LV_DESTINATION TYPE ZIFDEST-DEST.

  CALL FUNCTION 'Z_IF_DESTINATION'
    EXPORTING
      GUBUN                 = 'P1'
    IMPORTING
      DEST_NAME             = LV_DESTINATION
    EXCEPTIONS
      DESTINATION_NOT_FOUND = 1
      OTHERS                = 2.

  CALL FUNCTION 'ZGTPP_IF_O_CUTTING_ORD_INFO' DESTINATION LV_DESTINATION
    EXPORTING
      I_SYSTEM_ID           = P_SYSID
    IMPORTING
      ZO_RESULT             = GS_RESULT-ZSTAT
      ZO_MESSAGE            = GS_RESULT-ZMESSAGE
    TABLES
      OT_ORDER_H            = GT_ORDER_H
      OT_ORDER_I            = GT_ORDER_I
      OT_BOM                = GT_ORDER_BOM
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
*& Form set_first_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM SET_FIRST_DATA .

  SORT GT_HEADER BY ZIFKEY ZCUT_ORD_NO.

  DATA(LS_HEADER) = VALUE #( GT_HEADER[ 1 ] OPTIONAL ).

  GT_ITEM = LS_HEADER-ITEM.
  GT_BOM  = LS_HEADER-BOM.

  SORT GT_ITEM BY ZIFKEY ZCUT_ORD_NO ZCUT_ORD_ITEM.
  SORT GT_BOM  BY ZIFKEY ZCUT_ORD_NO ZCUT_ORD_ITEM POSNR.

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
*& Form conversion_exit_matn1_output
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM CONVERSION_EXIT_MATN1_OUTPUT  USING PV_MATNR.

  CALL FUNCTION 'CONVERSION_EXIT_MATN1_OUTPUT'
    EXPORTING
      INPUT  = PV_MATNR
    IMPORTING
      OUTPUT = PV_MATNR.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form MODIFY_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM MODIFY_DATA .

  DATA: BEGIN OF LS_VBELN,
          VBELN TYPE ZGTPPT2170-VBELN,
          POSNR TYPE ZGTPPT2170-POSNR,
        END OF LS_VBELN.
  DATA: LT_VBELN LIKE TABLE OF LS_VBELN.

  DATA: BEGIN OF LS_SEND_MAX,
          ZCUT_ORD_NO LIKE ZGTPPT2190-ZCUT_ORD_NO,
          IFDAT       LIKE ZGTPPT2200-IFDAT,
          IFTIM       LIKE ZGTPPT2200-IFTIM,
          IFNAM       LIKE ZGTPPT2200-IFNAM,
        END OF LS_SEND_MAX.
  DATA: LT_SEND_MAX LIKE TABLE OF LS_SEND_MAX.

  CLEAR: LT_VBELN.
  LOOP AT GT_HEADER INTO DATA(LS_HEADER).
    MOVE-CORRESPONDING LS_HEADER TO LS_VBELN.
    COLLECT LS_VBELN INTO LT_VBELN.
    MOVE-CORRESPONDING LS_HEADER TO LS_SEND_MAX.
    COLLECT LS_SEND_MAX INTO LT_SEND_MAX.
    CLEAR: LS_HEADER, LS_VBELN, LS_SEND_MAX.
  ENDLOOP.

  IF LT_VBELN[] IS NOT INITIAL.
    SORT LT_VBELN BY VBELN POSNR.

    "출하요청일자
    SELECT A~VBELN, A~POSNR, B~DRDAT
      FROM ZLET0401 AS A
      JOIN ZLET0400 AS B ON B~DLVRQ EQ A~DLVRQ
       FOR ALL ENTRIES IN @LT_VBELN
     WHERE A~VBELN EQ @LT_VBELN-VBELN
       AND A~POSNR EQ @LT_VBELN-POSNR
       AND A~LVORM EQ @SPACE
      INTO TABLE @DATA(LT_ZLET0401).

    SORT LT_ZLET0401 BY VBELN POSNR.

    LOOP AT GT_HEADER ASSIGNING FIELD-SYMBOL(<FS_H>).
      READ TABLE LT_ZLET0401 INTO DATA(LS_0401) WITH KEY VBELN = <FS_H>-VBELN
                                                         POSNR = <FS_H>-POSNR.
      IF SY-SUBRC EQ 0.
        <FS_H>-DRDAT = LS_0401-DRDAT.
      ENDIF.
    ENDLOOP.
  ENDIF.

  IF LT_SEND_MAX[] IS NOT INITIAL.
    SORT LT_SEND_MAX BY ZCUT_ORD_NO.

    "최종전송정보 추출
    SELECT A~ZCUT_ORD_NO, MAX( B~IFDAT ) AS IFDAT
      FROM @LT_SEND_MAX AS A
      JOIN ZGTPPT2200 AS B ON B~ZCUT_ORD_NO EQ A~ZCUT_ORD_NO
     GROUP BY A~ZCUT_ORD_NO
      INTO CORRESPONDING FIELDS OF TABLE @LT_SEND_MAX.

    LOOP AT LT_SEND_MAX ASSIGNING FIELD-SYMBOL(<FS_SM>).
      SELECT SINGLE MAX( IFTIM ) AS IFDAT, IFNAM
        FROM ZGTPPT2200
       WHERE ZCUT_ORD_NO EQ @<FS_SM>-ZCUT_ORD_NO
         AND IFDAT       EQ @<FS_SM>-IFDAT
       GROUP BY IFNAM
        INTO ( @<FS_SM>-IFTIM, @<FS_SM>-IFNAM ).
    ENDLOOP.


  ENDIF.

  IF S_DRDAT[] IS NOT INITIAL.
    DELETE GT_HEADER WHERE DRDAT NOT IN S_DRDAT.
  ENDIF.

  LOOP AT GT_HEADER REFERENCE INTO DATA(LR_HEADER).
    LOOP AT LR_HEADER->ITEM ASSIGNING FIELD-SYMBOL(<FS_ITEM>).
      "절단오더 아이템의 꼬리표번호 추출
      SELECT SINGLE TAGNR
        FROM ZPPT0001
       WHERE WERKS EQ @LR_HEADER->WERKS
         AND MATNR EQ @LR_HEADER->MATNR
         AND CHARG EQ @<FS_ITEM>-F_CHARG
        INTO @<FS_ITEM>-F_TAGNR.

    ENDLOOP.

    "최종전송정보 추출
    CLEAR: LS_SEND_MAX.
    READ TABLE LT_SEND_MAX INTO LS_SEND_MAX WITH KEY ZCUT_ORD_NO = LR_HEADER->ZCUT_ORD_NO.
    IF SY-SUBRC EQ 0.
      LR_HEADER->IFDAT = LS_SEND_MAX-IFDAT.
      LR_HEADER->IFTIM = LS_SEND_MAX-IFTIM.
      LR_HEADER->IFNAM = LS_SEND_MAX-IFNAM.
    ENDIF.
  ENDLOOP.

ENDFORM.
