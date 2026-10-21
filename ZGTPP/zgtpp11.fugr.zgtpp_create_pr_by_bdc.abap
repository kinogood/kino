FUNCTION ZGTPP_CREATE_PR_BY_BDC .
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(IS_PR_INFOR) TYPE  ZGTPPS0004
*"  EXPORTING
*"     VALUE(EV_RESULT) TYPE  CHAR01
*"     VALUE(EV_BANFN) TYPE  BANFN
*"  TABLES
*"      IT_CHART TYPE  ZGTPPY0005 OPTIONAL
*"----------------------------------------------------------------------

  DATA : LV_NUM(2) TYPE N.
  DATA : LV_FIELDNAME TYPE FNAM_____4.

  REFRESH : GT_BDCDATA, GT_MESSTAB.

  __SETTING_BDC_PARAMS.

  __BDC_DYNPRO 'SAPMM06B' '0100'.
  __BDC_FIELD : 'BDC_OKCODE' '=AB',
                      'EBAN-BSART'  IS_PR_INFOR-BSART,
                      'EBAN-KNTTP' IS_PR_INFOR-KNTTP,
                      'RM06B-EEIND' IS_PR_INFOR-EEIND,
                      'RM06B-LPEIN' IS_PR_INFOR-LPEIN,
                      'EBAN-WERKS' IS_PR_INFOR-WERKS,
                      'EBAN-EKGRP' IS_PR_INFOR-EKGRP,
                      'EBAN-AFNAM' IS_PR_INFOR-AFNAM.



  __BDC_DYNPRO 'SAPMM06B' '0106'.
  __BDC_FIELD : 'BDC_OKCODE' '=DETA',
                      'RM06B-TCSELFLAG(01)'  'X',
                      'EBAN-MATNR(01)' IS_PR_INFOR-MATNR,
                      'EBAN-MENGE(01)' IS_PR_INFOR-MENGE.

  __BDC_DYNPRO 'SAPMM06B' '0102'.
  __BDC_FIELD : 'BDC_OKCODE' '=KN',
                      'EBAN-EKORG'  IS_PR_INFOR-EKORG.
  IF IS_PR_INFOR-INFNR IS NOT INITIAL.
    __BDC_FIELD :  'EBAN-INFNR'  IS_PR_INFOR-INFNR,
                       'EBAN-LIFNR'  IS_PR_INFOR-LIFNR.
  ENDIF.

  IF IS_PR_INFOR-KDAUF IS NOT INITIAL.
    __BDC_DYNPRO 'SAPMM06B' '0505'.
    __BDC_FIELD : 'BDC_OKCODE' '=KWE'.

    __BDC_DYNPRO 'SAPLKACB' '0002'.
    __BDC_FIELD : 'BDC_OKCODE' '=ENTE',
                        'COBL-KDAUF' IS_PR_INFOR-KDAUF,
                        'COBL-KDPOS' IS_PR_INFOR-KDPOS.
  ENDIF.

  IF IT_CHART[] IS NOT INITIAL.
    __BDC_DYNPRO 'SAPMM06B' '0106'.
    __BDC_FIELD : 'BDC_OKCODE' '=KONF',
                        'RM06B-TCSELFLAG(01)'  'X'.

    __BDC_DYNPRO 'SAPMM06B' '0102'.
    __BDC_FIELD : 'BDC_OKCODE' '=KONF'.

    __BDC_DYNPRO 'SAPLCEI0' '0109'.
    __BDC_FIELD : 'BDC_OKCODE' '=BACK'.
    LOOP AT IT_CHART INTO DATA(LS_CHART).
      ADD 1 TO LV_NUM.
*     특성값
      CLEAR LV_FIELDNAME.
      LV_FIELDNAME = |RCTMS-MNAME({ LV_NUM })|.
      __BDC_FIELD :  LV_FIELDNAME LS_CHART-ATNAM.
*     특성밸류
      CLEAR LV_FIELDNAME.
      LV_FIELDNAME = |RCTMS-MWERT({ LV_NUM })|.
      __BDC_FIELD :  LV_FIELDNAME LS_CHART-ATWRT.
    ENDLOOP.

  ENDIF.

  __BDC_DYNPRO 'SAPMM06B' '0106'.
  __BDC_FIELD : 'BDC_OKCODE' '=BU'.


  __BDC_TRANSACTION 'ME51'.

  LOOP AT GT_MESSTAB INTO DATA(LS_MESSTAB) WHERE MSGTYP = 'S'
                                                         AND MSGID = '06'
                                                         AND MSGNR = '402'.
    DATA(LV_CHK_SUCESS) = ABAP_TRUE.
    EV_BANFN = LS_MESSTAB-MSGV1.
  ENDLOOP.

  IF LV_CHK_SUCESS IS INITIAL.
    EV_RESULT = 'E'.
  ELSE.
    EV_RESULT = 'S'.
    COMMIT WORK AND  WAIT.
  ENDIF.

ENDFUNCTION.
