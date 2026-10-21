class ZGTPP_CL_COMMON definition
  public
  create public .

public section.

  class-data:
    mt_characteristics TYPE TABLE OF v_ibin_syval .
  class-data:
    gty_t_zgtppt1010 TYPE TABLE OF zgtppt1010 .
  class-data:
    gty_t_zassign_no TYPE RANGE OF zgtppt2170-zassign_no .

  class-methods GET_MAKTX
    importing
      value(IV_MATNR) type MATNR
    returning
      value(RV_MAKTX) type MAKTX .
  class-methods GET_CHARACTERISTICS
    importing
      !IV_CUOBJ type CUOBJ_VA .
  class-methods GET_CHA_MILLCA
    importing
      !IV_VBELN type VBELN optional
      !IV_POSNR type POSNR optional
      !IV_CUOBJ type CUOBJ_VA optional
    exporting
      !EV_ZGTEINDLEN type ANY
      !EV_ZGTEFACTOR type ANY
      !EV_PACK_YN type ANY
      !EV_PACK_NO type ANY
      !EV_PACK_TYPE type ANY
      !EV_GRADE type ANY
      !EV_SO_INDLEN type ANY
      !EV_PACK_DM type ANY
      !EV_PACK_BX type ANY
      !EV_PACK_PA type ANY
      !EV_PACK_SK type ANY
      !EV_PACK_PW type ANY
      !EV_PACK_FACTOR type ANY
      !EV_INSPECTION type ANY
      !EV_CONTENTS_1ST type ANY
      !EV_INSP_QLENG type ANY
      !EV_INSP_SPLENG type ANY .
  class-methods GET_PLANT_NAME
    importing
      !IV_WERKS type WERKS_D
    returning
      value(RV_NAME1) type T001W-NAME1 .
  class-methods GET_DOMAIN_TEXT
    importing
      !IV_DOMNAME type DOMNAME
      !IV_DOMVALUE type DOMVALUE_L
    returning
      value(RV_TEXT) type VAL_TEXT .
  class-methods GET_CODE_VALUE
    importing
      !IV_MODULE_KIND type ZGTPPT1010-MODULE_KIND default 'PP'
      !IV_CODEGRP type ZGTPPT1010-CODEGRP
    returning
      value(RT_RETURN_TAB) like GTY_T_ZGTPPT1010 .
  class-methods GET_BP_NAME
    importing
      !IV_KUNNR type KUNNR
    returning
      value(RV_NAME1) type NAME1_GP .
  class-methods GET_KLART
    importing
      !IV_SPRAS type SPRAS
      !IV_KLART type KLASSENART
    returning
      value(RV_ARTXT) type ARTTXT .
  class-methods GET_PRD_CHARACTERISTICS
    importing
      !IV_AUFNR type AUFNR
      !IV_POSNR type CO_POSNR optional
      !IV_WERKS type MARC-WERKS
    returning
      value(RS_CHART) type ZGTCVORDSYVAL .
  class-methods GET_MATKL
    importing
      value(IV_MATNR) type MATNR
    returning
      value(RV_MATKL) type MATKL .
  class-methods SUBMIT_ZGTPPI2030
    importing
      !IV_WERKS type WERKS_D
      !IT_ZASSIGN_NO like GTY_T_ZASSIGN_NO .
  class-methods JOB_OPEN
    importing
      !IV_JOBNAME type TBTCJOB-JOBNAME
    returning
      value(RV_JOBCOUNT) type TBTCJOB-JOBCOUNT .
  class-methods JOB_CLOSE
    importing
      !IV_JOBNAME type TBTCJOB-JOBNAME
      !IV_JOBCOUNT type TBTCJOB-JOBCOUNT
    exporting
      !EV_RELEASED type BTCH0000-CHAR1 .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZGTPP_CL_COMMON IMPLEMENTATION.


  METHOD GET_BP_NAME.

    DATA : BEGIN OF LS_KNA1,
             KUNNR TYPE KNA1-KUNNR,
             NAME1 TYPE KNA1-NAME1,
           END OF LS_KNA1.

    STATICS : LT_KNA1 LIKE TABLE OF LS_KNA1.
    DATA : LV_TABIX TYPE I.

    CLEAR RV_NAME1.
    CLEAR LS_KNA1.
    READ TABLE LT_KNA1 INTO LS_KNA1 WITH KEY KUNNR = IV_KUNNR BINARY SEARCH.
    IF SY-SUBRC EQ 0.
      RV_NAME1 = LS_KNA1-NAME1.
    ELSE.
      LV_TABIX = SY-TABIX.
      SELECT SINGLE WERKS NAME1 INTO LS_KNA1 FROM KNA1
                                      WHERE KUNNR EQ IV_KUNNR.
      IF SY-SUBRC EQ 0.
        RV_NAME1 = LS_KNA1-NAME1.
        INSERT LS_KNA1 INTO LT_KNA1 INDEX LV_TABIX.
      ENDIF.
    ENDIF.

  ENDMETHOD.


  METHOD get_characteristics.

    DATA : lv_bcos_tstmp TYPE bcos_tstmp.

    GET TIME STAMP FIELD lv_bcos_tstmp.

    REFRESH mt_characteristics.

    SELECT b~*
      INTO CORRESPONDING FIELDS OF TABLE @mt_characteristics
    FROM ibin AS a
    INNER JOIN v_ibin_syval AS b
                                     ON b~in_recno = a~in_recno
   WHERE a~instance = @iv_cuobj
       AND a~valfr <= @lv_bcos_tstmp
       AND a~valto > @lv_bcos_tstmp .


  ENDMETHOD.


  METHOD GET_CHA_MILLCA.

    DATA : LT_V_IBIN_SYVAL TYPE TABLE OF V_IBIN_SYVAL.
    DATA : BEGIN OF LS_CHARACTICS,
             INSTANCE TYPE IBIN-INSTANCE,
             ITAB     LIKE LT_V_IBIN_SYVAL,
           END OF LS_CHARACTICS.
    DATA : LV_ATINN TYPE ATINN.
    DATA : LV_COUBJ TYPE CUOBJ_VA.
    DATA : LV_VALUE TYPE CHAR20.
    DATA : BEGIN OF LS_CONV_CHARNAME,
             ATNAM TYPE CABN-ATNAM,
             ATINN TYPE CABN-ATINN,
           END OF LS_CONV_CHARNAME.
    STATICS : LT_CONV_CHARNAME LIKE TABLE OF LS_CONV_CHARNAME.
    DATA : LV_TABIX TYPE I.

    DEFINE __GET_ATINN.
      CLEAR LS_CONV_CHARNAME.
      READ TABLE LT_CONV_CHARNAME INTO LS_CONV_CHARNAME WITH KEY ATNAM = CONV #( &1 ) BINARY SEARCH.
      IF SY-SUBRC EQ 0.
        &2 = LS_CONV_CHARNAME-ATINN.
      ELSE.
        LV_TABIX = SY-TABIX.
        LS_CONV_CHARNAME-ATNAM = &1.
        CALL FUNCTION 'CONVERSION_EXIT_ATINN_INPUT'
          EXPORTING
            INPUT  = LS_CONV_CHARNAME-ATNAM
          IMPORTING
            OUTPUT = LS_CONV_CHARNAME-ATINN.

        INSERT LS_CONV_CHARNAME INTO  LT_CONV_CHARNAME INDEX LV_TABIX.
        &2 = LS_CONV_CHARNAME-ATINN.
      ENDIF.
    END-OF-DEFINITION.

    IF IV_CUOBJ IS INITIAL OR IV_CUOBJ = '000000000000000000'.
      SELECT SINGLE CUOBJ
         INTO LV_COUBJ
         FROM VBAP
       WHERE VBELN = IV_VBELN
          AND POSNR = IV_POSNR.
    ELSE.
      LV_COUBJ = IV_CUOBJ.
    ENDIF.

    CHECK LV_COUBJ IS NOT INITIAL.

    GET_CHARACTERISTICS( IV_CUOBJ = LV_COUBJ ).
    LS_CHARACTICS-INSTANCE = LV_COUBJ.
    LS_CHARACTICS-ITAB = MT_CHARACTERISTICS.


*  특성 조장값
    __GET_ATINN 'SAP_MILLCA_LENGTH' LV_ATINN.
*    CALL FUNCTION 'CONVERSION_EXIT_ATINN_INPUT'
*      EXPORTING
*        INPUT  = 'SAP_MILLCA_LENGTH'
*      IMPORTING
*        OUTPUT = LV_ATINN.
    READ TABLE LS_CHARACTICS-ITAB INTO DATA(LS_CHAR) WITH KEY ATINN = LV_ATINN.
    IF SY-SUBRC EQ 0.
      CALL FUNCTION 'FLTP_CHAR_CONVERSION'
        EXPORTING
          DECIM = 3
          INPUT = LS_CHAR-ATFLV
        IMPORTING
          FLSTR = LV_VALUE.
      EV_ZGTEINDLEN = LV_VALUE.
    ENDIF.

*  특성 조장수
    CLEAR : LV_ATINN, LV_VALUE.
    __GET_ATINN 'SAP_MILLCA_FACTOR' LV_ATINN.
*    CALL FUNCTION 'CONVERSION_EXIT_ATINN_INPUT'
*      EXPORTING
*        INPUT  = 'SAP_MILLCA_FACTOR'
*      IMPORTING
*        OUTPUT = LV_ATINN.
    READ TABLE LS_CHARACTICS-ITAB INTO LS_CHAR WITH KEY ATINN = LV_ATINN.
    IF SY-SUBRC EQ 0.
      CALL FUNCTION 'FLTP_CHAR_CONVERSION'
        EXPORTING
          DECIM = 3
          INPUT = LS_CHAR-ATFLV
        IMPORTING
          FLSTR = LV_VALUE.
      EV_ZGTEFACTOR = LV_VALUE.
    ENDIF.

*  특성 포장재 지정상태
    CLEAR : LV_ATINN, LV_VALUE.
    __GET_ATINN 'PD_CA_PACKMARK_STATUS' LV_ATINN.
*    CALL FUNCTION 'CONVERSION_EXIT_ATINN_INPUT'
*      EXPORTING
*        INPUT  = 'PD_CA_PACKMARK_STATUS'
*      IMPORTING
*        OUTPUT = LV_ATINN.
    READ TABLE LS_CHARACTICS-ITAB INTO LS_CHAR WITH KEY ATINN = LV_ATINN.
    IF SY-SUBRC EQ 0.
      EV_PACK_YN = LS_CHAR-ATWRT.
    ENDIF.

*  특성 포장재 코드
    CLEAR : LV_ATINN, LV_VALUE.
    __GET_ATINN 'SAP_MILLCA_PACKAGING' LV_ATINN.
*    CALL FUNCTION 'CONVERSION_EXIT_ATINN_INPUT'
*      EXPORTING
*        INPUT  = 'SAP_MILLCA_PACKAGING'
*      IMPORTING
*        OUTPUT = LV_ATINN.
    READ TABLE LS_CHARACTICS-ITAB INTO LS_CHAR WITH KEY ATINN = LV_ATINN.
    IF SY-SUBRC EQ 0.
      EV_PACK_NO = LS_CHAR-ATWRT.
    ENDIF.

*  특성 포장재 유형
    CLEAR : LV_ATINN, LV_VALUE.
    __GET_ATINN 'SAP_MILLCA_PACKAGING_CAT' LV_ATINN.
*    CALL FUNCTION 'CONVERSION_EXIT_ATINN_INPUT'
*      EXPORTING
*        INPUT  = 'SAP_MILLCA_PACKAGING_CAT'
*      IMPORTING
*        OUTPUT = LV_ATINN.
    READ TABLE LS_CHARACTICS-ITAB INTO LS_CHAR WITH KEY ATINN = LV_ATINN.
    IF SY-SUBRC EQ 0.
      EV_PACK_TYPE = LS_CHAR-ATWRT.
    ENDIF.

*  특성 포장재 유형
    CLEAR : LV_ATINN, LV_VALUE.
    __GET_ATINN 'BT_AA_GRADE' LV_ATINN.
*    CALL FUNCTION 'CONVERSION_EXIT_ATINN_INPUT'
*      EXPORTING
*        INPUT  = 'BT_AA_GRADE'
*      IMPORTING
*        OUTPUT = LV_ATINN.
    READ TABLE LS_CHARACTICS-ITAB INTO LS_CHAR WITH KEY ATINN = LV_ATINN.
    IF SY-SUBRC EQ 0.
      CASE LS_CHAR-ATWRT.
        WHEN 'X08      4'.
          EV_GRADE = 'G4'.
        WHEN 'X08      3'.
          EV_GRADE = 'G3'.
        WHEN 'X08      2'.
          EV_GRADE = 'G2'.
        WHEN 'X08      1'.
          EV_GRADE = 'G1'.
      ENDCASE.
    ENDIF.

* 특성 판매단위 조장
    CLEAR : LV_ATINN, LV_VALUE.
    __GET_ATINN 'SAP_LENGTH_VKRME' LV_ATINN.
*    CALL FUNCTION 'CONVERSION_EXIT_ATINN_INPUT'
*      EXPORTING
*        INPUT  = 'SAP_LENGTH_VKRME'
*      IMPORTING
*        OUTPUT = LV_ATINN.
    READ TABLE LS_CHARACTICS-ITAB INTO LS_CHAR WITH KEY ATINN = LV_ATINN.
    IF SY-SUBRC EQ 0.
      CALL FUNCTION 'FLTP_CHAR_CONVERSION'
        EXPORTING
          DECIM = 3
          INPUT = LS_CHAR-ATFLV
        IMPORTING
          FLSTR = LV_VALUE.
      EV_SO_INDLEN = LV_VALUE.
    ENDIF.

*PD_CA_PACKING_DM           포장재(드럼)
    CLEAR : LV_ATINN, LV_VALUE.
    __GET_ATINN 'PD_CA_PACKING_DM' LV_ATINN.
*    CALL FUNCTION 'CONVERSION_EXIT_ATINN_INPUT'
*      EXPORTING
*        INPUT  = 'PD_CA_PACKING_DM'
*      IMPORTING
*        OUTPUT = LV_ATINN.
    READ TABLE LS_CHARACTICS-ITAB INTO LS_CHAR WITH KEY ATINN = LV_ATINN.
    IF SY-SUBRC EQ 0.
      EV_PACK_DM = LS_CHAR-ATWRT.
    ENDIF.

*PD_CA_PACKING_BX             포장재(BOX)
    CLEAR : LV_ATINN, LV_VALUE.
    __GET_ATINN 'PD_CA_PACKING_BX' LV_ATINN.
*    CALL FUNCTION 'CONVERSION_EXIT_ATINN_INPUT'
*      EXPORTING
*        INPUT  = 'PD_CA_PACKING_BX'
*      IMPORTING
*        OUTPUT = LV_ATINN.
    READ TABLE LS_CHARACTICS-ITAB INTO LS_CHAR WITH KEY ATINN = LV_ATINN.
    IF SY-SUBRC EQ 0.
      EV_PACK_BX = LS_CHAR-ATWRT.
    ENDIF.
*PD_CA_PACKING_PA            포장재(PALLET)
    CLEAR : LV_ATINN, LV_VALUE.
    __GET_ATINN 'PD_CA_PACKING_PA' LV_ATINN.
*    CALL FUNCTION 'CONVERSION_EXIT_ATINN_INPUT'
*      EXPORTING
*        INPUT  = 'PD_CA_PACKING_PA'
*      IMPORTING
*        OUTPUT = LV_ATINN.
    READ TABLE LS_CHARACTICS-ITAB INTO LS_CHAR WITH KEY ATINN = LV_ATINN.
    IF SY-SUBRC EQ 0.
      EV_PACK_PA = LS_CHAR-ATWRT.
    ENDIF.
*PD_CA_PACKING_SK             포장재(SKID)
    CLEAR : LV_ATINN, LV_VALUE.
    __GET_ATINN 'PD_CA_PACKING_SK' LV_ATINN.
*    CALL FUNCTION 'CONVERSION_EXIT_ATINN_INPUT'
*      EXPORTING
*        INPUT  = 'PD_CA_PACKING_SK'
*      IMPORTING
*    OUTPUT = LV_ATINN.
    READ TABLE LS_CHARACTICS-ITAB INTO LS_CHAR WITH KEY ATINN = LV_ATINN.
    IF SY-SUBRC EQ 0.
      EV_PACK_SK = LS_CHAR-ATWRT.
    ENDIF.
*PD_CA_PACKING_PW           포장재(포장목)
    CLEAR : LV_ATINN, LV_VALUE.
    __GET_ATINN 'PD_CA_PACKING_PW' LV_ATINN.
*    CALL FUNCTION 'CONVERSION_EXIT_ATINN_INPUT'
*      EXPORTING
*        INPUT  = 'PD_CA_PACKING_PW'
*      IMPORTING
*        OUTPUT = LV_ATINN.
    READ TABLE LS_CHARACTICS-ITAB INTO LS_CHAR WITH KEY ATINN = LV_ATINN.
    IF SY-SUBRC EQ 0.
      EV_PACK_PW = LS_CHAR-ATWRT.
    ENDIF.
*PD_CA_PW_FACTOR            포장목 개수
    CLEAR : LV_ATINN, LV_VALUE.
    __GET_ATINN 'PD_CA_PW_FACTOR' LV_ATINN.
*    CALL FUNCTION 'CONVERSION_EXIT_ATINN_INPUT'
*      EXPORTING
*        INPUT  = 'PD_CA_PW_FACTOR'
*      IMPORTING
*        OUTPUT = LV_ATINN.
    READ TABLE LS_CHARACTICS-ITAB INTO LS_CHAR WITH KEY ATINN = LV_ATINN.
    IF SY-SUBRC EQ 0.
      CALL FUNCTION 'FLTP_CHAR_CONVERSION'
        EXPORTING
          DECIM = 3
          INPUT = LS_CHAR-ATFLV
        IMPORTING
          FLSTR = LV_VALUE.
      EV_PACK_FACTOR = LV_VALUE.
    ENDIF.

* PD_AA_WITNESS_INSPECTION     입회검사유무
    CLEAR : LV_ATINN, LV_VALUE.
    __GET_ATINN 'PD_AA_WITNESS_INSPECTION' LV_ATINN.
*    CALL FUNCTION 'CONVERSION_EXIT_ATINN_INPUT'
*      EXPORTING
*        INPUT  = 'PD_AA_WITNESS_INSPECTION'
*      IMPORTING
*        OUTPUT = LV_ATINN.
    READ TABLE LS_CHARACTICS-ITAB INTO LS_CHAR WITH KEY ATINN = LV_ATINN.
    IF SY-SUBRC EQ 0.
      EV_INSPECTION = LS_CHAR-ATWRT.
    ENDIF.

* PD_CA_MARK_CONTENTS_1ST     마킹내용1
    CLEAR : LV_ATINN, LV_VALUE.
    __GET_ATINN 'PD_CA_MARK_CONTENTS_1ST' LV_ATINN.
*    CALL FUNCTION 'CONVERSION_EXIT_ATINN_INPUT'
*      EXPORTING
*        INPUT  = 'PD_CA_MARK_CONTENTS_1ST'
*      IMPORTING
*        OUTPUT = LV_ATINN.
    READ TABLE LS_CHARACTICS-ITAB INTO LS_CHAR WITH KEY ATINN = LV_ATINN.
    IF SY-SUBRC EQ 0.
      EV_CONTENTS_1ST = LS_CHAR-ATWRT.
    ENDIF.

    "입회검사여장" : S/O 속성 MS-WITNESS_INSPE_LENGTH
    CLEAR : LV_ATINN, LV_VALUE.
    __GET_ATINN 'MS-WITNESS_INSPE_LENGTH' LV_ATINN.
*    CALL FUNCTION 'CONVERSION_EXIT_ATINN_INPUT'
*      EXPORTING
*        INPUT  = 'MS-WITNESS_INSPE_LENGTH'
*      IMPORTING
*        OUTPUT = LV_ATINN.
    READ TABLE LS_CHARACTICS-ITAB INTO LS_CHAR WITH KEY ATINN = LV_ATINN.
    IF SY-SUBRC EQ 0.
      CALL FUNCTION 'FLTP_CHAR_CONVERSION'
        EXPORTING
          DECIM = 3
          INPUT = LS_CHAR-ATFLV
        IMPORTING
          FLSTR = LV_VALUE.
      EV_INSP_QLENG = LV_VALUE.
    ENDIF.

    "특별검사여장" : S/O 속성 MS-SPECIAL_INSPE_LENGTH
    CLEAR : LV_ATINN, LV_VALUE.
    __GET_ATINN 'MS-SPECIAL_INSPE_LENGTH' LV_ATINN.
*    CALL FUNCTION 'CONVERSION_EXIT_ATINN_INPUT'
*      EXPORTING
*        INPUT  = 'MS-SPECIAL_INSPE_LENGTH'
*      IMPORTING
*        OUTPUT = LV_ATINN.
    READ TABLE LS_CHARACTICS-ITAB INTO LS_CHAR WITH KEY ATINN = LV_ATINN.
    IF SY-SUBRC EQ 0.
      CALL FUNCTION 'FLTP_CHAR_CONVERSION'
        EXPORTING
          DECIM = 3
          INPUT = LS_CHAR-ATFLV
        IMPORTING
          FLSTR = LV_VALUE.
      EV_INSP_SPLENG = LV_VALUE.
    ENDIF.
  ENDMETHOD.


  METHOD GET_CODE_VALUE.

    SELECT * FROM ZGTPPT1010 INTO CORRESPONDING FIELDS OF TABLE RT_RETURN_TAB
      WHERE MODULE_KIND = IV_MODULE_KIND
        AND CODEGRP = IV_CODEGRP.

  ENDMETHOD.


  METHOD GET_DOMAIN_TEXT.

    DATA : BEGIN OF LS_DD07T,
             DOMNAME    TYPE DD07T-DOMNAME,
             DOMVALUE_L TYPE DD07T-DOMVALUE_L,
             DDTEXT     TYPE DD07T-DDTEXT,
           END OF LS_DD07T.

    STATICS : LT_DD07T LIKE TABLE OF LS_DD07T.
    DATA : LV_TABIX TYPE I.

    CLEAR LS_DD07T.
    READ TABLE LT_DD07T INTO LS_DD07T WITH KEY DOMNAME = IV_DOMNAME
                                                                       DOMVALUE_L = IV_DOMVALUE
                                                                       BINARY SEARCH.
    IF SY-SUBRC EQ 0.
      RV_TEXT = LS_DD07T-DDTEXT.
    ELSE.
      LV_TABIX = SY-TABIX.
      SELECT SINGLE DOMNAME DOMVALUE_L DDTEXT INTO LS_DD07T FROM DD07T
                                      WHERE DDLANGUAGE EQ SY-LANGU
                                          AND DOMNAME EQ IV_DOMNAME
                                          AND DOMVALUE_L EQ IV_DOMVALUE.
      IF SY-SUBRC EQ 0.
        RV_TEXT = LS_DD07T-DDTEXT.
        INSERT LS_DD07T INTO LT_DD07T INDEX LV_TABIX.
      ENDIF.
    ENDIF.


  ENDMETHOD.


  METHOD get_klart.

    SELECT SINGLE artxt INTO rv_artxt FROM tclat
                                         WHERE spras EQ iv_spras
                                               AND klart EQ iv_klart.

  ENDMETHOD.


  METHOD get_maktx.

    DATA : BEGIN OF ls_maktx,
             matnr TYPE makt-matnr,
             maktx TYPE makt-maktx,
           END OF ls_maktx.

    STATICS : lt_maktx LIKE TABLE OF ls_maktx.
    DATA : lv_tabix TYPE i.
    DATA : lv_matnr TYPE matnr.

    CALL FUNCTION 'CONVERSION_EXIT_MATN1_INPUT'
      EXPORTING
        input        = iv_matnr
      IMPORTING
        output       = lv_matnr
      EXCEPTIONS
        length_error = 1
        OTHERS       = 2.
    IF sy-subrc <> 0.
* Implement suitable error handling here
    ENDIF.



    CLEAR ls_maktx.
    READ TABLE lt_maktx INTO ls_maktx WITH KEY matnr = lv_matnr BINARY SEARCH.
    IF sy-subrc EQ 0.
      rv_maktx = ls_maktx-maktx.
    ELSE.
      lv_tabix = sy-tabix.
      SELECT SINGLE matnr maktx INTO ls_maktx FROM makt
                                      WHERE matnr EQ lv_matnr
                                      AND   spras EQ sy-langu.
      IF sy-subrc EQ 0.
        rv_maktx = ls_maktx-maktx.
        INSERT ls_maktx INTO lt_maktx INDEX lv_tabix.
      ENDIF.
    ENDIF.

  ENDMETHOD.


  METHOD get_matkl.

    DATA : BEGIN OF ls_matkl,
             matnr TYPE mara-matnr,
             matkl TYPE mara-matkl,
           END OF ls_matkl.

    STATICS : lt_matkl LIKE TABLE OF ls_matkl.
    DATA : lv_tabix TYPE i.
    DATA : lv_matnr TYPE matnr.

    CALL FUNCTION 'CONVERSION_EXIT_MATN1_INPUT'
      EXPORTING
        input        = iv_matnr
      IMPORTING
        output       = lv_matnr
      EXCEPTIONS
        length_error = 1
        OTHERS       = 2.
    IF sy-subrc <> 0.
* Implement suitable error handling here
    ENDIF.

    CLEAR ls_matkl.
    READ TABLE lt_matkl INTO ls_matkl WITH KEY matnr = lv_matnr BINARY SEARCH.
    IF sy-subrc EQ 0.
      rv_matkl = ls_matkl-matkl.
    ELSE.
      lv_tabix = sy-tabix.
      SELECT SINGLE matnr matkl INTO ls_matkl FROM mara
                                      WHERE matnr EQ lv_matnr.
      IF sy-subrc EQ 0.
        rv_matkl = ls_matkl-matkl.
        INSERT ls_matkl INTO lt_matkl INDEX lv_tabix.
      ENDIF.
    ENDIF.

  ENDMETHOD.


  METHOD get_plant_name.

    DATA : BEGIN OF ls_t001w,
             werks TYPE t001w-werks,
             name1 TYPE t001w-name1,
           END OF ls_t001w.

    STATICS : lt_t001w LIKE TABLE OF ls_t001w.
    DATA : lv_tabix TYPE i.

    CLEAR ls_t001w.
    READ TABLE lt_t001w INTO ls_t001w WITH KEY werks = iv_werks BINARY SEARCH.
    IF sy-subrc EQ 0.
      rv_name1 = ls_t001w-name1.
    ELSE.
      lv_tabix = sy-tabix.
      SELECT SINGLE werks name1 INTO ls_t001w FROM t001w
                                      WHERE werks EQ iv_werks.
      IF sy-subrc EQ 0.
        rv_name1 = ls_t001w-name1.
        INSERT ls_t001w INTO lt_t001w INDEX lv_tabix.
      ENDIF.
    ENDIF.

  ENDMETHOD.


  METHOD get_prd_characteristics.

    DATA : lt_auart TYPE RANGE OF auart.
    DATA : lv_index TYPE i.

    STATICS : lt_chart TYPE TABLE OF zgtcvordsyval.

    CLEAR rs_chart.

    READ TABLE lt_chart INTO rs_chart WITH KEY werks = iv_werks
                                                                       aufnr = iv_aufnr
                                                                       posnr = iv_posnr
                                                                       BINARY SEARCH.

    IF sy-subrc NE 0.
      lv_index = sy-tabix.
      SELECT SINGLE *
        FROM zgtcvordsyval
        INTO CORRESPONDING FIELDS OF rs_chart
        WHERE werks = iv_werks
           AND auart IN lt_auart
           AND aufnr = iv_aufnr
           AND posnr = iv_posnr.
      IF sy-subrc = 0.
        INSERT rs_chart INTO lt_chart INDEX lv_index.
      ENDIF.
    ENDIF.


  ENDMETHOD.


  METHOD job_close.

    CALL FUNCTION 'JOB_CLOSE'
      EXPORTING
        jobcount             = iv_jobcount
        jobname              = iv_jobname
        strtimmed            = abap_true
      IMPORTING
        job_was_released     = ev_released
      EXCEPTIONS
        cant_start_immediate = 1
        invalid_startdate    = 2
        jobname_missing      = 3
        job_close_failed     = 4
        job_nosteps          = 5
        job_notex            = 6
        lock_failed          = 7
        OTHERS               = 8.

  ENDMETHOD.


  METHOD job_open.

    CALL FUNCTION 'JOB_OPEN'
      EXPORTING
        jobname          = iv_jobname
      IMPORTING
        jobcount         = rv_jobcount
      EXCEPTIONS
        cant_create_job  = 1
        invalid_job_data = 2
        jobname_missing  = 3
        OTHERS           = 4.

  ENDMETHOD.


  METHOD submit_zgtppi2030.
    DATA lv_jobname TYPE tbtcjob-jobname.
    DATA lt_seltab  TYPE TABLE OF rsparams.
    DATA lt_zgtppt1010 TYPE TABLE OF zgtppt1010.

    lv_jobname = |SUBMIT_ZGTPPI2030_VIA_{ sy-repid }|.

*    DATA(lt_zgtppt1010) = zgtpp_cl_common=>get_code_value( iv_codegrp = '0010' ).

    CLEAR: lt_zgtppt1010.
    SELECT *
      FROM zgtppt1010
     WHERE module_kind = 'PP'
       AND codegrp = '0010'
       AND fld_04 NE @space
      INTO CORRESPONDING FIELDS OF TABLE @lt_zgtppt1010.

    DATA(lv_sysid) = VALUE #( lt_zgtppt1010[ fld_03 = iv_werks ]-fld_01 OPTIONAL ).

    lt_seltab[] = VALUE #( FOR ls_zassign_no IN it_zassign_no[]
                           ( selname = 'S_ZASGNO'
                             kind    = 'S'
                             sign    = ls_zassign_no-sign
                             option  = ls_zassign_no-option
                             low     = ls_zassign_no-low ) ).

    lt_seltab = VALUE #( BASE lt_seltab ( selname = 'P_SYSID' kind = 'P' sign = 'I' option = 'EQ' low = lv_sysid   )    "// 대상시스템.
                                        ( selname = 'P_SEND'  kind = 'P' sign = 'I' option = 'EQ' low = abap_true  )    "// 처리모드.
                                        ( selname = 'P_LOG'   kind = 'P' sign = 'I' option = 'EQ' low = abap_false )
                                        ( selname = 'P_BATCH' kind = 'P' sign = 'I' option = 'EQ' low = abap_true  ) ). "// 배치.

    DATA(lv_jobcount) = job_open( lv_jobname ).

    CHECK lv_jobcount IS NOT INITIAL.

    SUBMIT zgtppi2030 VIA JOB lv_jobname NUMBER lv_jobcount
                      WITH SELECTION-TABLE lt_seltab AND RETURN.

    job_close( EXPORTING iv_jobname  = lv_jobname
                         iv_jobcount = lv_jobcount
               IMPORTING ev_released = DATA(lv_released) ).

  ENDMETHOD.
ENDCLASS.
