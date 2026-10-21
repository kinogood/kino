*&---------------------------------------------------------------------*
*&  Include           LZNF2100F01
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  FILE_DOWN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_C_1  text
*----------------------------------------------------------------------*
FORM FILE_DOWN  USING PV_FCODE.
  DATA: LV_FIELD(10).

  SELECT SINGLE *
    FROM ZNFT1002
   WHERE CONNO EQ GS_ZNFT1002-CONNO.

  IF SY-SUBRC EQ 0.
    CASE PV_FCODE.

      WHEN 'DWN1'.
        CHECK NOT GS_ZNFT1002-LINK1 IS INITIAL.
        PERFORM BAPI_DOWNLOAD
          USING GS_ZNFT1002-FILE1 GS_ZNFT1002-LINK1.

      WHEN 'DWN2'.
        CHECK NOT GS_ZNFT1002-LINK2 IS INITIAL.
        PERFORM BAPI_DOWNLOAD
          USING GS_ZNFT1002-FILE2 GS_ZNFT1002-LINK2.

      WHEN 'DWN3'.
        CHECK NOT GS_ZNFT1002-LINK3 IS INITIAL.
        PERFORM BAPI_DOWNLOAD
          USING GS_ZNFT1002-FILE3 GS_ZNFT1002-LINK3.

      WHEN 'DWN4'.
        CHECK NOT GS_ZNFT1002-LINK4 IS INITIAL.
        PERFORM BAPI_DOWNLOAD
          USING GS_ZNFT1002-FILE4 GS_ZNFT1002-LINK4.

      WHEN 'DWN5'.
        CHECK NOT GS_ZNFT1002-LINK5 IS INITIAL.
        PERFORM BAPI_DOWNLOAD
          USING GS_ZNFT1002-FILE5 GS_ZNFT1002-LINK5.

      WHEN 'DWN6'.
        CHECK NOT GS_ZNFT1002-LINK6 IS INITIAL.
         PERFORM CALL_WEBSITE
          USING GS_ZNFT1002-FILE6 GS_ZNFT1002-LINK6.

      WHEN 'DWN7'.
        CHECK NOT GS_ZNFT1002-LINK7 IS INITIAL.
        PERFORM CALL_WEBSITE
          USING GS_ZNFT1002-FILE7 GS_ZNFT1002-LINK7.

      WHEN 'DWN8'.
        CHECK NOT GS_ZNFT1002-LINK8 IS INITIAL.
        PERFORM CALL_WEBSITE
          USING GS_ZNFT1002-FILE8 GS_ZNFT1002-LINK8.

      WHEN 'DWN9'.
        CHECK NOT GS_ZNFT1002-LINK9 IS INITIAL.
        PERFORM CALL_WEBSITE
          USING GS_ZNFT1002-FILE9 GS_ZNFT1002-LINK9.

      WHEN 'DWN10'.
        CHECK NOT GS_ZNFT1002-LINK10 IS INITIAL.
        PERFORM CALL_WEBSITE
          USING GS_ZNFT1002-FILE10 GS_ZNFT1002-LINK10.


    ENDCASE.
  ENDIF.

ENDFORM.                    " FILE_DOWN

*&---------------------------------------------------------------------*
*&      Form  BAPI_DOWNLOAD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM BAPI_DOWNLOAD USING P_FILE P_LINK.

  DATA: LF_PATHNAME LIKE BAPI_DOC_DRAW-DOCFILE1.
  DATA: LS_RETURN LIKE BAPIRET2.
  DATA: LT_FILES LIKE BAPI_DOC_FILES2 OCCURS 0 WITH HEADER LINE.
  DATA: LS_DOCUMENTFILE LIKE BAPI_DOC_FILES2.
  DATA: LV_CNT TYPE I.
  DATA: LV_TYP(3).

  REFRESH LT_FILES.
  CLEAR LT_FILES.

  LV_CNT = STRLEN( P_LINK ) - 3.
  MOVE P_LINK+LV_CNT(3) TO LV_TYP.

  LF_PATHNAME = GS_ZNFT1002-FILEP.
  LS_DOCUMENTFILE-WSAPPLICATION = LV_TYP.

  CALL FUNCTION 'BAPI_DOCUMENT_GETDETAIL2'
    EXPORTING
      DOCUMENTTYPE    = 'PCI'
      DOCUMENTNUMBER  = P_FILE
      DOCUMENTPART    = '000'
      DOCUMENTVERSION = '00'
    IMPORTING
      RETURN          = LS_RETURN
    TABLES
      DOCUMENTFILES   = LT_FILES.

** Error occurred
  IF LS_RETURN-TYPE CA 'EA'.
    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
  ELSE.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        WAIT = 'X'.

*-문서 구동
    CALL FUNCTION 'DOCUMENT_SHOW_DIRECT'
      EXPORTING
        DOKAR   = 'PCI'
        DOKNR   = P_FILE
        DOKTEIL = '000'
        DOKVR   = '00'.
  ENDIF.

ENDFORM.                    " BAPI_DOWNLOAD
FORM CALL_WEBSITE USING P_FILE P_LINK.

  DATA LV_URL(200) .

  CLEAR LV_URL.

  LV_URL = P_LINK.

  CALL FUNCTION 'CALL_BROWSER'
    EXPORTING
      URL                    = LV_URL
    EXCEPTIONS
      FRONTEND_NOT_SUPPORTED = 1
      FRONTEND_ERROR         = 2
      PROG_NOT_FOUND         = 3
      NO_BATCH               = 4
      UNSPECIFIED_ERROR      = 5
      OTHERS                 = 6.
  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.
ENDFORM.
