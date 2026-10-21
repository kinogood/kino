FUNCTION ZGTPP_SO_CHAR_BDC.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IV_VBELN) TYPE  VBELN_VA
*"     REFERENCE(IV_POSNR) TYPE  POSNR_VA
*"  EXPORTING
*"     REFERENCE(EV_TYPE) TYPE  CHAR01
*"  TABLES
*"      IT_CHA STRUCTURE  BAPI1003_ALLOC_VALUES_CHAR
*"      T_MESSAGE STRUCTURE  BDCMSGCOLL OPTIONAL
*"----------------------------------------------------------------------

  TABLES : VBFA.

  DATA : LV_NUM(2) TYPE N.
  DATA : LV_FIELDNAME TYPE FNAM_____4.
  DATA : LV_IS_SD_CHK    TYPE C.

*-. 영업문서 체크 (차후문서)
  SELECT SINGLE * FROM VBFA
     WHERE VBELV EQ IV_VBELN.
  IF SY-SUBRC EQ 0.
    LV_IS_SD_CHK = ABAP_TRUE.
  ELSE.
    CLEAR  LV_IS_SD_CHK.
  ENDIF.

  REFRESH : GT_BDCDATA, GT_MESSTAB.

  __SETTING_BDC_PARAMS.

  CLEAR GS_BDCPARAMS-DEFSIZE.

  __BDC_DYNPRO 'SAPMV45A' '0102'.
  __BDC_FIELD : 'BDC_OKCODE' '/00',
                      'VBAK-VBELN'  IV_VBELN.

  IF LV_IS_SD_CHK  EQ ABAP_TRUE.
    __BDC_DYNPRO 'SAPMV45A' '4001'.
    __BDC_FIELD : 'BDC_OKCODE' '/00'.

  ENDIF.

* 품목상위로
  __BDC_DYNPRO 'SAPMV45A' '4001'.
  __BDC_FIELD : 'BDC_OKCODE' '=POPO'.

  __BDC_DYNPRO 'SAPMV45A' '0251'.
  __BDC_FIELD : 'BDC_OKCODE' '=POSI',
                      'RV45A-POSNR' IV_POSNR.

*...품목 첫번째로 올린 후 품목선택
  __BDC_DYNPRO 'SAPMV45A' '4001'.
  __BDC_FIELD : 'BDC_OKCODE' '=POCO',
                      'RV45A-VBAP_SELKZ(01)' 'X'.

  LOOP AT IT_CHA ASSIGNING FIELD-SYMBOL(<LS_CHR>).
    ADD 1 TO LV_NUM.

    AT LAST.
      __BDC_DYNPRO 'SAPLCEI0' '0109'.
      __BDC_FIELD : 'BDC_OKCODE' '=BACK',
                          'RCTMS-MNAME(01)' <LS_CHR>-CHARACT,
                          'RCTMS-MWERT(01)' <LS_CHR>-VALUE_CHAR.
      EXIT.
    ENDAT.
*     특성값
    __BDC_DYNPRO 'SAPLCEI0' '0109'.
    __BDC_FIELD : 'BDC_OKCODE' '/00',
                        'RCTMS-MNAME(01)' <LS_CHR>-CHARACT,
                        'RCTMS-MWERT(01)' <LS_CHR>-VALUE_CHAR.
  ENDLOOP.


  __BDC_DYNPRO 'SAPMV45A' '4001'.
  __BDC_FIELD : 'BDC_OKCODE' '=SICH'.


  __BDC_TRANSACTION 'VA02'.

  IF SY-SUBRC EQ 0.
    EV_TYPE = 'S'.
  ELSE.
    EV_TYPE = 'E'.
    MOVE-CORRESPONDING GT_MESSTAB TO T_MESSAGE[].
  ENDIF.

ENDFUNCTION.
