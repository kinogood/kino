*----------------------------------------------------------------------*
***INCLUDE ZGTPPR4020F01 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  CONVERSION_MATNR_INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_IT_LIST_MATNR  text
*----------------------------------------------------------------------*
FORM CONVERSION_MATNR_INPUT  CHANGING P_MATNR.

  CALL FUNCTION 'CONVERSION_EXIT_MATN1_INPUT'
    EXPORTING
      INPUT            = P_MATNR
    IMPORTING
      OUTPUT           = P_MATNR
    EXCEPTIONS
      NUMBER_NOT_FOUND = 1
      LENGTH_ERROR     = 2
      OTHERS           = 3.

  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

ENDFORM.                    " CONVERSION_MATNR_INPUT
*&---------------------------------------------------------------------*
*&      Form  BDC_DYNPRO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_0209   text
*      -->P_0210   text
*----------------------------------------------------------------------*
FORM BDC_DYNPRO  USING    P_PROGRAM P_DYNPRO.
  CLEAR GT_BDCDATA.
  GT_BDCDATA-PROGRAM  = P_PROGRAM.
  GT_BDCDATA-DYNPRO   = P_DYNPRO.
  GT_BDCDATA-DYNBEGIN = 'X'.
  APPEND GT_BDCDATA.

ENDFORM.                    " BDC_DYNPRO
*&---------------------------------------------------------------------*
*&      Form  BDC_FIELD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_0244   text
*      -->P_0245   text
*----------------------------------------------------------------------*
FORM BDC_FIELD  USING    P_FNAM P_FVAL.
  CLEAR GT_BDCDATA.
  GT_BDCDATA-FNAM = P_FNAM.
  GT_BDCDATA-FVAL = P_FVAL.
  CONDENSE GT_BDCDATA-FVAL.
  APPEND GT_BDCDATA.
ENDFORM.                    " BDC_FIELD
*&---------------------------------------------------------------------*
*&      Form  CANCEL_MAT_DOC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_P_TEMP_MBLNR  text
*      -->P_P_TEMP_MJAHR  text
*----------------------------------------------------------------------*
FORM CANCEL_MAT_DOC  USING    P_TEMP TYPE ZGTBDS310.

  CLS: GM_RETURN.
  CLEAR: GM_HEADRET.

  CALL FUNCTION 'BAPI_GOODSMVT_CANCEL'
    EXPORTING
      MATERIALDOCUMENT = P_TEMP-MBLNR
      MATDOCUMENTYEAR  = P_TEMP-MJAHR
*     GOODSMVT_PSTNG_DATE =
    IMPORTING
      GOODSMVT_HEADRET = GM_HEADRET
    TABLES
      RETURN           = GM_RETURN.

  IF NOT GM_HEADRET-MAT_DOC IS INITIAL.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        WAIT = 'X'.

    CLEAR: P_TEMP-MBLNR, P_TEMP-MJAHR.

  ELSE.
    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

    CONCATENATE P_TEMP-ZMESSAGE TEXT-E11
           INTO P_TEMP-ZMESSAGE SEPARATED BY SPACE.
  ENDIF.

ENDFORM.                    " CANCEL_MAT_DOC
*&---------------------------------------------------------------------*
*&      Form  PROCESSING_STATUS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LS_LINES  text
*      -->P_LS_COUNT  text
*----------------------------------------------------------------------*
FORM PROCESSING_STATUS  USING    P_LINES
                                 P_COUNT.
  DATA: LS_TEXT(100).
  DATA: LINES(4) TYPE N,
        COUNT(4) TYPE N.

  WRITE: P_LINES TO LINES NO-ZERO,
         P_COUNT TO COUNT NO-ZERO.

  CONCATENATE COUNT '/' LINES
              ' ' TEXT-011
         INTO LS_TEXT.

  CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
    EXPORTING
*     PERCENTAGE       = 0
      TEXT = LS_TEXT.


ENDFORM.                    " PROCESSING_STATUS
*&---------------------------------------------------------------------*
*& Form CHK_COCKPIT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CHK_COCKPIT .
  DATA: LV_CKP(1).
  IMPORT CKP TO LV_CKP FROM MEMORY ID 'CKP'.
  FREE MEMORY ID 'CKP'.

  IF LV_CKP EQ 'X'.
    EXPORT CKP = 'S' TO MEMORY ID 'CKP'.
    CLEAR: LV_CKP.
  ENDIF.
ENDFORM.
