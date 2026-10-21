*&---------------------------------------------------------------------*
*& Include          ZGTPPR3180C01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  EXIT  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE EXIT INPUT.

  PERFORM USER_COMMAND_EXIT.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_100 INPUT.

  CASE GV_OKCODE.
    WHEN GC_FCODE-BACK OR GC_FCODE-EXIT. "// Back, Exit.
      PERFORM USER_COMMAND_EXIT.

    WHEN GC_FCODE-SELECT.                "// 선택.
      PERFORM USER_COMMAND_SELECT USING ABAP_TRUE.

    WHEN GC_FCODE-UNSELECT.              "// 선택해제.
      PERFORM USER_COMMAND_SELECT USING ABAP_FALSE.

    WHEN GC_FCODE-CREATE.                "// 자재 청구.
      PERFORM USER_COMMAND_CREATE.

    WHEN GC_FCODE-CHANGE.                "// 청구 변경.
      PERFORM USER_COMMAND_CHANGE.

    WHEN GC_FCODE-DELETE.                "// 청구 삭제.
      PERFORM USER_COMMAND_DELETE.

    WHEN GC_FCODE-REQ_COMP.              "// 개별 품목 청구.
      PERFORM USER_COMMAND_REQ_COMP.

    WHEN GC_FCODE-REQ_BAS_FT.            "// 완제품 기준 청구.
      PERFORM USER_COMMAND_REQ_BAS_FT.

    WHEN 'MTO_CREATE'. "MTO 청구생성
      PERFORM USER_COMMAND_MTO_CREATE.
  ENDCASE.

  CLEAR GV_OKCODE.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0200  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0200 INPUT.

  CASE GV_OKCODE.
    WHEN GC_FCODE-INDV_REQ.
      PERFORM USER_COMMAND_INDV_REQ.     "// 개별 품목 청구.
  ENDCASE.

  CLEAR GV_OKCODE.

ENDMODULE.

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0300  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0300 INPUT.

  CASE GV_OKCODE.
    WHEN GC_FCODE-COMP_CHK.
      PERFORM USER_COMMAND_COMP_CHK.     "// 구성부품 확인.
  ENDCASE.

  CLEAR GV_OKCODE.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  CHECK_INDV_REQ_MATNR  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CHECK_INDV_REQ_MATNR INPUT.

  CLEAR GS_INDV_REQ-MAKTX.

  IF GS_INDV_REQ-MATNR IS INITIAL.
    MESSAGE E031 WITH TEXT-F65 DISPLAY LIKE 'S'.
  ENDIF.

  SELECT SINGLE MARA~MEINS, MARA~MTART, MAKT~MAKTX
    INTO @DATA(LS_MARA)
    FROM MARA
    LEFT JOIN MAKT
      ON MARA~MATNR EQ MAKT~MATNR
     AND MAKT~SPRAS EQ @SY-LANGU
   WHERE MARA~MATNR EQ @GS_INDV_REQ-MATNR.

  IF SY-SUBRC IS INITIAL.
    GS_INDV_REQ = VALUE #( BASE GS_INDV_REQ MAKTX = LS_MARA-MAKTX
                                            ERFME = COND #( WHEN GS_INDV_REQ-ERFME IS INITIAL THEN LS_MARA-MEINS ) ).

*    IF LS_MARA-MTART IN GT_MTART.
*      MESSAGE E000 WITH TEXT-E02 DISPLAY LIKE 'S'.
*    ENDIF.
  ELSE.
    MESSAGE E305(M3) WITH GS_INDV_REQ-MATNR DISPLAY LIKE 'S'.
  ENDIF.

  SELECT SINGLE WERKS, MATNR, LGPRO
    INTO @DATA(LS_MARC)
    FROM MARC
   WHERE MATNR EQ @GS_INDV_REQ-MATNR
     AND WERKS EQ @P_WERKS.

  IF SY-SUBRC IS INITIAL.
    IF GS_INDV_REQ-LGORT_T IS INITIAL.
      GS_INDV_REQ-LGORT_T = LS_MARC-LGPRO.
    ENDIF.
  ELSE.
    MESSAGE E351(M3) WITH GS_INDV_REQ-MATNR P_WERKS DISPLAY LIKE 'S'.
  ENDIF.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  CHECK_INDV_REQ_ERFME  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CHECK_INDV_REQ_ERFME INPUT.

  IF GS_INDV_REQ-ERFME IS INITIAL.
    MESSAGE E031 WITH TEXT-F61 DISPLAY LIKE 'S'.
  ELSE.
    SELECT SINGLE MSEHI
      INTO @DATA(LV_MSEHI)
      FROM T006
     WHERE MSEHI EQ @GS_INDV_REQ-ERFME.

    CHECK SY-SUBRC IS NOT INITIAL.

    MESSAGE E000 WITH TEXT-E03 DISPLAY LIKE 'S'.
  ENDIF.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  CHECK_INDV_REQ_REQDAT  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CHECK_INDV_REQ_REQDAT INPUT.

  IF GS_INDV_REQ-REQDAT IS INITIAL.
    MESSAGE E031 WITH TEXT-F51 DISPLAY LIKE 'S'.
  ENDIF.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  CHECK_INDV_REQ_LGORT_T  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CHECK_INDV_REQ_LGORT_T INPUT.

  IF GS_INDV_REQ-LGORT_T IS INITIAL.
*    MESSAGE e031 WITH TEXT-f52 DISPLAY LIKE 'S'.
  ELSE.
    SELECT SINGLE LGOBE
      INTO @DATA(LV_LGOBE)
      FROM T001L
     WHERE WERKS EQ @P_WERKS
       AND LGORT EQ @GS_INDV_REQ-LGORT_T.

    CHECK SY-SUBRC IS NOT INITIAL.

    MESSAGE E000 WITH TEXT-E04 DISPLAY LIKE 'S'.
  ENDIF.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  CHECK_FERT_REQ_MATNR  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CHECK_FERT_REQ_MATNR INPUT.

  CLEAR GS_FERT_REQ-MAKTX.

  IF GS_FERT_REQ-MATNR IS INITIAL.
    MESSAGE E031 WITH TEXT-F65 DISPLAY LIKE 'S'.
  ENDIF.

  SELECT SINGLE MARA~MEINS, MARA~MTART, MAKT~MAKTX
    INTO CORRESPONDING FIELDS OF @LS_MARA
    FROM MARA
    LEFT JOIN MAKT
      ON MARA~MATNR EQ MAKT~MATNR
     AND MAKT~SPRAS EQ @SY-LANGU
   WHERE MARA~MATNR EQ @GS_FERT_REQ-MATNR.

  IF SY-SUBRC IS INITIAL.
    GS_FERT_REQ = VALUE #( BASE GS_FERT_REQ MAKTX = LS_MARA-MAKTX
                                            BMEIN = COND #( WHEN GS_FERT_REQ-BMEIN IS INITIAL THEN LS_MARA-MEINS ) ).

    IF LS_MARA-MTART IN GT_MTART.
      MESSAGE E000 WITH TEXT-E02 DISPLAY LIKE 'S'.
    ENDIF.
  ELSE.
    MESSAGE E305(M3) WITH GS_FERT_REQ-MATNR DISPLAY LIKE 'S'.
  ENDIF.

  SELECT SINGLE STLAN, STLAL
    INTO CORRESPONDING FIELDS OF @GS_FERT_REQ
    FROM MAST
   WHERE MATNR EQ @GS_FERT_REQ-MATNR
     AND WERKS EQ @P_WERKS
     AND STLAN EQ @ZGTPP_IF_CONST=>GC_STLAN-PRODUCTION
     AND STLAL EQ '01'.

  IF SY-SUBRC IS NOT INITIAL.
    MESSAGE E001(29) DISPLAY LIKE 'S'.
  ENDIF.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  CHECK_FERT_REQ_REQDAT  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CHECK_FERT_REQ_REQDAT INPUT.

  IF GS_FERT_REQ-REQDAT IS INITIAL.
    MESSAGE E031 WITH TEXT-F51 DISPLAY LIKE 'S'.
  ENDIF.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  F4_REQDAT  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE F4_REQDAT INPUT.
  DATA LR_REQDAT TYPE REF TO DATA.

  LR_REQDAT = SWITCH #( SY-DYNNR WHEN 200 THEN REF #( GS_INDV_REQ-REQDAT )
                                 WHEN 300 THEN REF #( GS_FERT_REQ-REQDAT )
                                 WHEN 500 THEN REF #( GS_SUMMARY-REQDAT )
                                 WHEN 800 THEN REF #( GS_HEADER_800-REQDAT ) ) .

  CALL FUNCTION 'F4_DATE'
    EXPORTING
      DATE_FOR_FIRST_MONTH = SY-DATUM
    IMPORTING
      SELECT_DATE          = LR_REQDAT->*
    EXCEPTIONS
      SELECT_DATE_INVALID  = 1
      OTHERS               = 2.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_500  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_500 INPUT.

  CASE GV_OKCODE.
    WHEN GC_FCODE-MAT_REQ.
      PERFORM USER_COMMAND_MAT_REQ.     "// 자재 청구.
  ENDCASE.

  CLEAR GV_OKCODE.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  CHECK_LGORT  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CHECK_LGORT INPUT.

  CLEAR GS_SUMMARY-LGOBE.

  IF GS_SUMMARY-LGORT IS INITIAL.
    MESSAGE E031 WITH TEXT-F65 DISPLAY LIKE 'S'.
  ENDIF.

  READ TABLE GT_T001L INTO DATA(LS_T001L) WITH TABLE KEY WERKS = GS_SUMMARY-WERKS
                                                         LGORT = GS_SUMMARY-LGORT.
  IF SY-SUBRC IS INITIAL.
    GS_SUMMARY-LGOBE = LS_T001L-LGOBE.
  ELSE.
    MESSAGE E103(M3) WITH GS_SUMMARY-LGORT GS_SUMMARY-WERKS DISPLAY LIKE 'S'.
  ENDIF.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0700  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0700 INPUT.

  CLEAR GV_OKCODE2.
  GV_OKCODE2 = SY-UCOMM.

  CASE GV_OKCODE2.
    WHEN 'BACK' OR 'EXIT' OR 'CANC' OR 'CONFIRM'.
      CALL METHOD GO_CONTAIN_0700->FREE.
      FREE : GO_CONTAIN_0700, GO_GRID_0700.
      REFRESH : GT_SORT_0700, GT_EXCLUDE_0700, GT_FIELDCAT_0700.
      CALL METHOD CL_GUI_CFW=>FLUSH.
      LEAVE TO SCREEN 0.

  ENDCASE.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  CHECK_INDV_REQ_MATNR_800  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CHECK_INDV_REQ_MATNR_800 INPUT.

  CLEAR GS_HEADER_800-MAKTX.

  IF GS_HEADER_800-MATNR IS INITIAL.
    MESSAGE S031 WITH TEXT-F65 DISPLAY LIKE 'E'.
  ENDIF.

  SELECT SINGLE MARA~MEINS, MARA~MTART, MAKT~MAKTX
    INTO @LS_MARA
    FROM MARA
    LEFT JOIN MAKT
      ON MARA~MATNR EQ MAKT~MATNR
     AND MAKT~SPRAS EQ @SY-LANGU
   WHERE MARA~MATNR EQ @GS_HEADER_800-MATNR
     AND MARA~MTART LIKE 'MRM%' .

  IF SY-SUBRC IS INITIAL.
    GS_HEADER_800 = VALUE #( BASE GS_HEADER_800 MAKTX = LS_MARA-MAKTX
                                            ERFME = COND #( WHEN GS_HEADER_800-ERFME IS INITIAL THEN LS_MARA-MEINS ) ).

  ELSE.
    MESSAGE S006 WITH '드럼자재만 입력 가능합니다.' DISPLAY LIKE 'E'.
  ENDIF.

  SELECT SINGLE WERKS, MATNR, LGPRO
    INTO @LS_MARC
    FROM MARC
   WHERE MATNR EQ @GS_HEADER_800-MATNR
     AND WERKS EQ @P_WERKS.

  IF SY-SUBRC IS INITIAL.
    IF GS_HEADER_800-LGORT_T IS INITIAL.
      GS_HEADER_800-LGORT_T = LS_MARC-LGPRO.
    ENDIF.
  ELSE.
    MESSAGE E351(M3) WITH GS_INDV_REQ-MATNR P_WERKS DISPLAY LIKE 'S'.
  ENDIF.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  CHECK_INDV_REQ_LFIMG_800  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CHECK_INDV_REQ_LFIMG_800 INPUT.

  IF GS_HEADER_800-LFIMG IS INITIAL.
    MESSAGE E031 WITH TEXT-F60 DISPLAY LIKE 'S'.
  ENDIF.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  CHECK_INDV_REQ_ERFME_800  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CHECK_INDV_REQ_ERFME_800 INPUT.

  IF GS_HEADER_800-ERFME IS INITIAL.
    MESSAGE E031 WITH TEXT-F61 DISPLAY LIKE 'S'.
  ELSE.
    SELECT SINGLE MSEHI
      INTO @LV_MSEHI
      FROM T006
     WHERE MSEHI EQ @GS_HEADER_800-ERFME.

    CHECK SY-SUBRC IS NOT INITIAL.

    MESSAGE E000 WITH TEXT-E03 DISPLAY LIKE 'S'.
  ENDIF.


ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  CHECK_INDV_REQ_REQDAT_800  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CHECK_INDV_REQ_REQDAT_800 INPUT.

  IF GS_HEADER_800-REQDAT IS INITIAL.
    MESSAGE E031 WITH TEXT-F51 DISPLAY LIKE 'S'.
  ENDIF.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  CHECK_INDV_REQ_LGORT_T_800  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CHECK_INDV_REQ_LGORT_T_800 INPUT.

  IF GS_HEADER_800-REQDAT IS INITIAL.
    MESSAGE E031 WITH TEXT-F51 DISPLAY LIKE 'S'.
  ENDIF.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0800  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0800 INPUT.

  CASE GV_OKCODE.
    WHEN 'REQUEST'.
      PERFORM USER_COMMAND_INDV_REQ_800.     "// 개별 품목 청구.
  ENDCASE.

  CLEAR GV_OKCODE.

ENDMODULE.
