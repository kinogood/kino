FUNCTION ZGTSD_EXCEL_UPLOAD_2.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(FILENAME) TYPE  RLGRAP-FILENAME
*"     VALUE(I_BEGIN_COL) TYPE  I
*"     VALUE(I_BEGIN_ROW) TYPE  I
*"     VALUE(I_END_COL) TYPE  I
*"     VALUE(I_END_ROW) TYPE  I
*"     VALUE(I_SHEETS) TYPE  I OPTIONAL
*"     VALUE(I_SHEETNO) TYPE  I OPTIONAL
*"  TABLES
*"      INTERN STRUCTURE  ZGTSDS1090
*"  EXCEPTIONS
*"      INCONSISTENT_PARAMETERS
*"      UPLOAD_OLE
*"----------------------------------------------------------------------
  DATA: EXCEL_TAB    TYPE  TY_T_SENDER.
  DATA: LV_SEPARATOR TYPE  C.
  DATA: APPLICATION TYPE  OLE2_OBJECT,
        WORKBOOK    TYPE  OLE2_OBJECT,
        RANGE       TYPE  OLE2_OBJECT,

        WORKSHEET   TYPE  OLE2_OBJECT.
  DATA: H_CELL  TYPE  OLE2_OBJECT,
        H_CELL1 TYPE  OLE2_OBJECT.
  DATA:
        LV_RC            TYPE I.

  DATA : SHEETNO     TYPE I.
  DATA : SHEETNAME   TYPE CHAR30.
*   Rückgabewert der Methode "clipboard_export     "

* Makro für Fehlerbehandlung der Methods
  DEFINE M_MESSAGE.
    CASE SY-SUBRC.
      WHEN 0.
      WHEN 1.
        MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
           WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
      WHEN OTHERS.
        RAISE UPLOAD_OLE.
    ENDCASE.
  END-OF-DEFINITION.

* check parameters
  IF I_BEGIN_ROW > I_END_ROW. RAISE INCONSISTENT_PARAMETERS. ENDIF.
  IF I_BEGIN_COL > I_END_COL. RAISE INCONSISTENT_PARAMETERS. ENDIF.

* Get TAB-sign for separation of fields
  CLASS CL_ABAP_CHAR_UTILITIES DEFINITION LOAD.
  LV_SEPARATOR = CL_ABAP_CHAR_UTILITIES=>HORIZONTAL_TAB.

* open file in Excel
  IF APPLICATION-HEADER = SPACE OR APPLICATION-HANDLE = -1.
    CREATE OBJECT APPLICATION 'Excel.Application'.
    M_MESSAGE.
  ENDIF.
  CALL METHOD OF APPLICATION 'Workbooks' = WORKBOOK.
  M_MESSAGE.
  CALL METHOD OF WORKBOOK 'Open' EXPORTING #1 = FILENAME.
  M_MESSAGE.
*--^_^ han
  IF I_SHEETNO IS INITIAL AND I_SHEETS IS INITIAL.
    DATA(LV_FLAG) = 'A'. " ACTIVESHEET
    I_SHEETS = 1.
  ELSEIF I_SHEETNO IS NOT INITIAL AND I_SHEETS IS INITIAL.
    LV_FLAG = 'S'. " SELECT SHEET
    I_SHEETS = 1.
  ELSEIF I_SHEETNO IS INITIAL AND I_SHEETS IS NOT INITIAL.
    LV_FLAG = 'M'. " MULTI SHEET
  ELSEIF I_SHEETNO IS NOT INITIAL AND I_SHEETS IS NOT INITIAL.
    LV_FLAG = 'S'. " SELECT SHEET
    I_SHEETS = 1.
  ENDIF.

  CLEAR : SHEETNO.

  DO I_SHEETS TIMES.

    CASE LV_FLAG.
      WHEN 'A'.
*  set property of application 'Visible' = 1.
*  m_message.
        GET PROPERTY OF  APPLICATION 'ACTIVESHEET' = WORKSHEET.
        M_MESSAGE.

        GET PROPERTY OF WORKSHEET 'NAME' = SHEETNAME.
        M_MESSAGE.

      WHEN 'S'.

*  set property of application 'Visible' = 1.
*  m_message.
        GET PROPERTY OF  APPLICATION 'ACTIVESHEET' = WORKSHEET.
        M_MESSAGE.

        CALL METHOD OF APPLICATION 'Worksheets' = WORKSHEET
        EXPORTING
          #1 = I_SHEETNO.

        IF SY-SUBRC <> 0.
          IF SHEETNO = 1.
            M_MESSAGE.
          ELSE.
            EXIT.
          ENDIF.
        ENDIF.

        CALL METHOD OF WORKSHEET 'Activate'.
        M_MESSAGE.

        GET PROPERTY OF WORKSHEET 'NAME' = SHEETNAME.
        M_MESSAGE.

*    "Filtro POR SHEETNAME
*    CHECK SHEETNAME = I_SHEETNAME OR I_SHEETNAME IS NOT SUPPLIED.

        GET PROPERTY OF APPLICATION 'ACTIVESHEET' = WORKSHEET.
        M_MESSAGE.

      WHEN 'M'.
        SHEETNO = SHEETNO + 1.

        GET PROPERTY OF APPLICATION 'ACTIVESHEET' = WORKSHEET.
        M_MESSAGE.

        CALL METHOD OF APPLICATION 'Worksheets' = WORKSHEET
        EXPORTING
          #1 = SHEETNO.

        IF SY-SUBRC <> 0.
          IF SHEETNO = 1.
            M_MESSAGE.
          ELSE.
            EXIT.
          ENDIF.
        ENDIF.

        CALL METHOD OF WORKSHEET 'Activate'.
        M_MESSAGE.

        GET PROPERTY OF WORKSHEET 'NAME' = SHEETNAME.
        M_MESSAGE.

*    "Filtro POR SHEETNAME
*    CHECK SHEETNAME = I_SHEETNAME OR I_SHEETNAME IS NOT SUPPLIED.

        GET PROPERTY OF APPLICATION 'ACTIVESHEET' = WORKSHEET.
        M_MESSAGE.
*--^_^
      WHEN OTHERS.
    ENDCASE.
*   mark whole spread sheet
    CALL METHOD OF WORKSHEET 'Cells' = H_CELL
        EXPORTING #1 = I_BEGIN_ROW #2 = I_BEGIN_COL.
    M_MESSAGE.
    CALL METHOD OF WORKSHEET 'Cells' = H_CELL1
        EXPORTING #1 = I_END_ROW #2 = I_END_COL.
    M_MESSAGE.

    CALL METHOD  OF WORKSHEET 'RANGE' = RANGE
                   EXPORTING #1 = H_CELL #2 = H_CELL1.
    M_MESSAGE.
    CALL METHOD OF RANGE 'SELECT'.
    M_MESSAGE.

*   copy marked area (whole spread sheet) into Clippboard
    CALL METHOD OF RANGE 'COPY'.
    M_MESSAGE.

*   read clipboard into ABAP
    CALL METHOD CL_GUI_FRONTEND_SERVICES=>CLIPBOARD_IMPORT
      IMPORTING
        DATA       = EXCEL_TAB
      EXCEPTIONS
        CNTL_ERROR = 1
*       ERROR_NO_GUI         = 2
*       NOT_SUPPORTED_BY_GUI = 3
        OTHERS     = 4.
    IF SY-SUBRC <> 0.
      MESSAGE A037(ALSMEX).
    ENDIF.

*    PERFORM separated_to_intern_convertA TABLES EXCEL_TAB INTERN
*                                        USING  LV_SEPARATOR.

    PERFORM SEPARATED_TO_INTERN_CONVERT_S TABLES EXCEL_TAB INTERN
                                           USING LV_SEPARATOR
                                                 SHEETNO
                                                 SHEETNAME.


* clear clipboard
    REFRESH EXCEL_TAB.
    CALL METHOD CL_GUI_FRONTEND_SERVICES=>CLIPBOARD_EXPORT
      IMPORTING
        DATA       = EXCEL_TAB
      CHANGING
        RC         = LV_RC
      EXCEPTIONS
        CNTL_ERROR = 1
*       ERROR_NO_GUI         = 2
*       NOT_SUPPORTED_BY_GUI = 3
        OTHERS     = 4.
  ENDDO.
* quit Excel and free ABAP Object - unfortunately, this does not kill
* the Excel process
  CALL METHOD OF APPLICATION 'QUIT'.
  M_MESSAGE.

* >>>>> Begin of change note 575877
* to kill the Excel process it's necessary to free all used objects
  FREE OBJECT H_CELL.       M_MESSAGE.
  FREE OBJECT H_CELL1.      M_MESSAGE.
  FREE OBJECT RANGE.        M_MESSAGE.
  FREE OBJECT WORKSHEET.    M_MESSAGE.
  FREE OBJECT WORKBOOK.     M_MESSAGE.
  FREE OBJECT APPLICATION.  M_MESSAGE.

ENDFUNCTION.
*&---------------------------------------------------------------------*
*&      Form  SEPARATED_TO_INTERN_CONVERT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SEPARATED_TO_INTERN_CONVERT_S TABLES I_TAB       TYPE TY_T_SENDER
                                          I_INTERN    TYPE TY_T_ITAB
                                    USING I_SEPARATOR TYPE C
                                          I_SHEETNO
                                          I_SHEETNAME.
  DATA: LV_SIC_TABIX LIKE SY-TABIX,
        LV_SIC_COL   TYPE KCD_EX_COL.
  DATA: LV_FDPOS     LIKE SY-FDPOS.

*  REFRESH I_INTERN.

  LOOP AT I_TAB.
    LV_SIC_TABIX = SY-TABIX.
    LV_SIC_COL = 0.
    WHILE I_TAB CA I_SEPARATOR.
      LV_FDPOS = SY-FDPOS.
      LV_SIC_COL = LV_SIC_COL + 1.
      PERFORM LINE_TO_CELL_SEPARAT_S TABLES I_INTERN
                                      USING I_TAB
                                            LV_SIC_TABIX
                                            LV_SIC_COL
                                            I_SEPARATOR
                                            LV_FDPOS
                                            I_SHEETNO
                                            I_SHEETNAME.
    ENDWHILE.
    IF I_TAB <> SPACE.
      CLEAR I_INTERN.
      I_INTERN-SHEETNO   = I_SHEETNO.
      I_INTERN-SHEETNAME = I_SHEETNAME.
      I_INTERN-ROW       = LV_SIC_TABIX.
      I_INTERN-COL       = LV_SIC_COL + 1.
      I_INTERN-VALUE     = I_TAB.
      APPEND I_INTERN.
    ENDIF.
  ENDLOOP.
ENDFORM.                    " SEPARATED_TO_INTERN_CONVERT
*&---------------------------------------------------------------------*
*&      Form  LINE_TO_CELL_SEPARAT_S
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM LINE_TO_CELL_SEPARAT_S TABLES I_INTERN    TYPE TY_T_ITAB
                             USING I_LINE
                                   I_ROW       LIKE SY-TABIX
                                   CH_CELL_COL TYPE KCD_EX_COL
                                   I_SEPARATOR TYPE C
                                   I_FDPOS     LIKE SY-FDPOS
                                   I_SHEETNO
                                   I_SHEETNAME.

  DATA: LV_STRING   TYPE TY_S_SENDERLINE.
  DATA  LV_SIC_INT  TYPE I.

  CLEAR I_INTERN.
  LV_SIC_INT          = I_FDPOS.
  I_INTERN-SHEETNO    = I_SHEETNO.
  I_INTERN-SHEETNAME  = I_SHEETNAME.
  I_INTERN-ROW        = I_ROW.
  LV_STRING           = I_LINE.
  I_INTERN-COL        = CH_CELL_COL.
* csv Dateien mit separator in Zelle: --> ;"abc;cd";
  IF ( I_SEPARATOR = ';' OR  I_SEPARATOR = ',' ) AND
       LV_STRING(1) = GC_ESC.
    PERFORM LINE_TO_CELL_ESC_SEPA USING LV_STRING
                                       LV_SIC_INT
                                       I_SEPARATOR
                                       I_INTERN-VALUE.
  ELSE.
    IF LV_SIC_INT > 0.
      I_INTERN-VALUE = I_LINE(LV_SIC_INT).
    ENDIF.
  ENDIF.
  IF LV_SIC_INT > 0.
    APPEND I_INTERN.
  ENDIF.
  LV_SIC_INT = LV_SIC_INT + 1.
  I_LINE = I_LINE+LV_SIC_INT.
ENDFORM.
FORM LINE_TO_CELL_ESC_SEPA USING I_STRING
                                I_SIC_INT      TYPE I
                                I_SEPARATOR    TYPE C
                                I_INTERN_VALUE TYPE TY_D_ITABVALUE.
  DATA: LV_INT         TYPE I,
        LV_CELL_END(2).
  FIELD-SYMBOLS: <L_CELL>.
  LV_CELL_END   = GC_ESC.
  LV_CELL_END+1 = I_SEPARATOR .

  IF I_STRING CS GC_ESC.
    I_STRING = I_STRING+1.
    IF I_STRING CS LV_CELL_END.
      LV_INT = SY-FDPOS.
      ASSIGN I_STRING(LV_INT) TO <L_CELL>.
      I_INTERN_VALUE = <L_CELL>.
      LV_INT = LV_INT + 2.
      I_SIC_INT = LV_INT.
      I_STRING = I_STRING+LV_INT.
    ELSEIF I_STRING CS GC_ESC.
*     letzte Celle
      LV_INT = SY-FDPOS.
      ASSIGN I_STRING(LV_INT) TO <L_CELL>.
      I_INTERN_VALUE = <L_CELL>.
      LV_INT = LV_INT + 1.
      I_SIC_INT = LV_INT.
      I_STRING = I_STRING+LV_INT.
      LV_INT = STRLEN( I_STRING ).
      IF LV_INT > 0 . MESSAGE X001(KX) . ENDIF.
    ELSE.
      MESSAGE X001(KX) . "was ist mit csv-Format
    ENDIF.
  ENDIF.

ENDFORM.
