************************************************************************
* 모듈/서브모듈 : MM / 비철                                            *
* Type          : Report                                               *
* GAP ID        : NF-xxxx                                              *
* T_CODE        : ZNF2C2010                                            *
* Description   : 계약번호 Upload                                      *
************************************************************************
*                        MODIFICATION LOG                              *
*----------------------------------------------------------------------*
*   DATE        AUTHORS              DESCRIPTION                       *
* ----------   --------- --------------------------------------------- *
* 2012/07/27   SDC24     Initial Release                               *
************************************************************************
* Comment :
************************************************************************

REPORT  ZNFC2010  MESSAGE-ID  ZNF1.

*___업로드한 파일내용
DATA : BEGIN OF GT_FILE OCCURS 0,
         VBELN(10),       "판매오더
         POSNR(6),        "품목
         CONNO(10),       "계약번호
       END   OF GT_FILE.

DATA : BEGIN OF GT_ORDER OCCURS 0,
         VBELN     LIKE VBAP-VBELN,      "주문번호
         POSNR     LIKE VBAP-POSNR,      "오더 품목 번호
         CONNO     LIKE VBAP-CONNO,      "계약번호
         CHECK,
         ICON(4),
         MESSAGE   LIKE BAPIRET2-MESSAGE, "메세지
       END   OF GT_ORDER.

DATA: GV_FLAG.

*___ALV용 변수
TYPE-POOLS : SLIS.

DATA : GV_USER_COMMAND     TYPE SLIS_FORMNAME VALUE 'USER_COMMAND',
       GV_STATUS_SET       TYPE SLIS_FORMNAME VALUE 'PF_STATUS_SET',
       GV_TOP_OF_PAGE      TYPE SLIS_FORMNAME VALUE 'TOP_OF_PAGE',
       GV_REPID            LIKE SY-REPID,
       GT_EVENTS           TYPE SLIS_T_EVENT,
       GS_EVENTS_LINE      TYPE SLIS_ALV_EVENT,
       GT_EVENTS_EXIT      TYPE SLIS_T_EVENT_EXIT,
       GS_EVENTS_EXIT_LINE TYPE SLIS_EVENT_EXIT,
       GS_LAYOUT           TYPE SLIS_LAYOUT_ALV,
       GT_FIELDCAT         TYPE SLIS_T_FIELDCAT_ALV,
       GS_FIELDCAT         TYPE SLIS_FIELDCAT_ALV,
       GT_LIST_TOP_OF_PAGE TYPE SLIS_T_LISTHEADER,
       GS_LIST_TOP_OF_PAGE TYPE SLIS_LISTHEADER,
       GV_GRID_SETTINGS    TYPE LVC_S_GLAY,
       GT_SORT             TYPE SLIS_T_SORTINFO_ALV,
       GS_SORT             TYPE SLIS_SORTINFO_ALV,
       GS_VARIANT          TYPE DISVARIANT.

DATA : GV_EXTAB            TYPE SLIS_EXTAB,
       GV_ITAB             LIKE GS_FIELDCAT-TABNAME,
       GV_POS              LIKE GS_FIELDCAT-COL_POS.

*----------------------------------------------------------------------*
*     SELECTION SCREEN                                                 *
*----------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK BLK1 WITH FRAME TITLE TEXT-001.
PARAMETERS     : P_FILE  TYPE LOCALFILE LOWER CASE OBLIGATORY.
SELECTION-SCREEN END   OF BLOCK BLK1.

*----------------------------------------------------------------------*
*     INITIALIZATION                                                   *
*----------------------------------------------------------------------*
INITIALIZATION.

*----------------------------------------------------------------------*
*     AT SELECTION-SCREEN ON VALUE-REQUEST                             *
*----------------------------------------------------------------------*
AT SELECTION-SCREEN ON VALUE-REQUEST FOR P_FILE.
  CALL FUNCTION 'WS_FILENAME_GET'
    EXPORTING
      MASK             = ',*.*,*.*.'
      MODE             = 'O'
    IMPORTING
      FILENAME         = P_FILE
    EXCEPTIONS
      INV_WINSYS       = 01
      NO_BATCH         = 02
      SELECTION_CANCEL = 03
      SELECTION_ERROR  = 04.

*----------------------------------------------------------------------*
*     START-OF-SELECTION                                               *
*----------------------------------------------------------------------*
START-OF-SELECTION.
  PERFORM FILE_UPLOAD.
  PERFORM CONVERT_UPLOAD_DATA.

*----------------------------------------------------------------------*
*     END-OF-SELECTION                                                 *
*----------------------------------------------------------------------*
END-OF-SELECTION.
  IF GT_ORDER[] IS NOT INITIAL.
    PERFORM DISPLAY_UPLOAD_DATA.
  ELSE.
    MESSAGE S003 DISPLAY LIKE 'E'
       WITH 'Upload Data가 없습니다.'.
  ENDIF.

*&---------------------------------------------------------------------
*& Form PF_STATUS_SET
*&---------------------------------------------------------------------
FORM PF_STATUS_SET USING  EXTAB  TYPE  SLIS_T_EXTAB.

  SET  PF-STATUS  '0100'  EXCLUDING  EXTAB .

ENDFORM.                " PF_STATUS_SET
*---------------------------------------------------------------------*
*       FORM USER_COMMAND                                             *
*---------------------------------------------------------------------*
FORM USER_COMMAND USING R_UCOMM     LIKE SY-UCOMM
                        RS_SELFIELD TYPE SLIS_SELFIELD.

  CASE R_UCOMM.
    WHEN '&IC1'.
      CASE RS_SELFIELD-FIELDNAME.
        WHEN 'VBELN'.
          IF RS_SELFIELD-VALUE IS NOT INITIAL.
            SET PARAMETER ID 'AUN'  FIELD RS_SELFIELD-VALUE.
            CALL TRANSACTION 'VA03' AND SKIP FIRST SCREEN.
          ENDIF.

        WHEN 'CONNO'.
          IF RS_SELFIELD-VALUE IS NOT INITIAL.
            SET PARAMETER ID 'ZNFCON' FIELD RS_SELFIELD-VALUE.

            CALL TRANSACTION 'ZNF2M2003' AND SKIP FIRST SCREEN.
          ENDIF.

      ENDCASE.

    WHEN 'UPLD'.      "계약번호 Upload
      PERFORM UPLOAD_CONTRACT_NO.

  ENDCASE.

ENDFORM.                               "USER_COMMAND
*&---------------------------------------------------------------------*
*&      Form  FILE_UPLOAD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM FILE_UPLOAD .
  TYPES : TRUXS_T_TEXT_DATA(4096) TYPE C OCCURS 0.

  DATA : LV_DATA  TYPE TRUXS_T_TEXT_DATA,
         LV_FILE1 LIKE RLGRAP-FILENAME,
         LV_FILE2 TYPE STRING.

  CLEAR   : GT_FILE, GV_FLAG.
  REFRESH : GT_FILE.

  IF P_FILE CS '.xls'.
    GV_FLAG = 'E'.
  ELSE.
    GV_FLAG = 'T'.
  ENDIF.

  IF GV_FLAG = 'E'.
    LV_FILE1 = P_FILE.
* Excel변환 함수 수정 #20221220
    DATA : LV_MESSAGE   TYPE  STRING.

    CALL FUNCTION 'ZCOMM_UPLOAD_EXCEL'
      EXPORTING
        I_HEADERLINE = 0
        I_FILENAME   = LV_FILE1
      IMPORTING
        E_MESSAGE    = LV_MESSAGE
      TABLES
        T_TAB        = GT_FILE.

    IF LV_MESSAGE IS NOT INITIAL.
      MESSAGE S001 WITH LV_MESSAGE.
    ENDIF.

*    CALL FUNCTION 'TEXT_CONVERT_XLS_TO_SAP'
*      EXPORTING
**       I_FIELD_SEPERATOR          =
*        I_LINE_HEADER              = ' '
*        I_TAB_RAW_DATA             = LV_DATA
*        I_FILENAME                 = LV_FILE1
*      TABLES
*        I_TAB_CONVERTED_DATA       = GT_FILE
*      EXCEPTIONS
*        CONVERSION_FAILED          = 1
*        OTHERS                     = 2.
* #20221220
  ELSE.
    LV_FILE2 = P_FILE.

    CALL FUNCTION 'GUI_UPLOAD'
      EXPORTING
        FILENAME                = LV_FILE2
        HAS_FIELD_SEPARATOR     = 'X'
      TABLES
        DATA_TAB                = GT_FILE
      EXCEPTIONS
        FILE_OPEN_ERROR         = 1
        FILE_READ_ERROR         = 2
        NO_BATCH                = 3
        GUI_REFUSE_FILETRANSFER = 4
        INVALID_TYPE            = 5
        NO_AUTHORITY            = 6
        UNKNOWN_ERROR           = 7
        BAD_DATA_FORMAT         = 8
        HEADER_NOT_ALLOWED      = 9
        SEPARATOR_NOT_ALLOWED   = 10
        HEADER_TOO_LONG         = 11
        UNKNOWN_DP_ERROR        = 12
        ACCESS_DENIED           = 13
        DP_OUT_OF_MEMORY        = 14
        DISK_FULL               = 15
        DP_TIMEOUT              = 16
        OTHERS                  = 17.
  ENDIF.

  IF SY-SUBRC <> 0.
    MESSAGE S003 WITH '파일명을 확인하시기 바랍니다.'.
    STOP.
  ENDIF.

ENDFORM.                    " FILE_UPLOAD
*&---------------------------------------------------------------------*
*&      Form  CONVERT_UPLOAD_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CONVERT_UPLOAD_DATA.
  DATA : LV_CURRDEC  LIKE TCURX-CURRDEC,
         LV_DEC(20),
         LV_CNT      TYPE I.

  CLEAR   : GT_ORDER.
  REFRESH : GT_ORDER.

  LOOP AT GT_FILE.
    CHECK SY-TABIX > 1.

    CLEAR : GT_ORDER.

    MOVE-CORRESPONDING GT_FILE TO GT_ORDER.

*___판매오더 존재여부 점검
    SELECT SINGLE VBELN
      INTO GT_ORDER-VBELN
      FROM VBAP
     WHERE VBELN = GT_ORDER-VBELN
       AND POSNR = GT_ORDER-POSNR.

    IF SY-SUBRC <> 0.
      GT_ORDER-MESSAGE = '/판매오더-품목'.
    ENDIF.

*___계약번호 존재여부 점검
    SELECT SINGLE CONNO
      INTO GT_ORDER-CONNO
      FROM ZNFT1000
     WHERE CONNO = GT_ORDER-CONNO.

    IF SY-SUBRC <> 0.
      CONCATENATE GT_ORDER-MESSAGE '계약번호'
             INTO GT_ORDER-MESSAGE SEPARATED BY '/'.
    ENDIF.

    IF GT_ORDER-MESSAGE IS NOT INITIAL.
      GT_ORDER-ICON = '@5C@'.

      REPLACE '/' WITH '' INTO GT_ORDER-MESSAGE.
      CONCATENATE GT_ORDER-MESSAGE '이(가) 존재하지 않습니다.'
             INTO GT_ORDER-MESSAGE.
    ELSE.
      GT_ORDER-ICON = '@5B@'.
    ENDIF.

    APPEND GT_ORDER.
  ENDLOOP.

ENDFORM.                    " CONVERT_UPLOAD_DATA
*&---------------------------------------------------------------------*
*&      Form  DISPLAY_UPLOAD_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM DISPLAY_UPLOAD_DATA .

  PERFORM CREATE_FIELD_CATEGORY.

  PERFORM DISPLAY_ALV_LIST TABLES GT_ORDER.

ENDFORM.                    " DISPLAY_UPLOAD_DATA
*&---------------------------------------------------------------------*
*&      Form  CREATE_FIELD_CATEGORY
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CREATE_FIELD_CATEGORY .

  CLEAR   : GS_LAYOUT, GV_POS.

  GV_ITAB = 'GT_ORDER'.

  GS_LAYOUT-ZEBRA             = 'X'.
  GS_LAYOUT-COLWIDTH_OPTIMIZE = 'X'.
  GS_LAYOUT-BOX_FIELDNAME     = 'CHECK'.
  GS_LAYOUT-BOX_TABNAME       = GV_ITAB.

  CLEAR   : GS_FIELDCAT.
  REFRESH : GT_FIELDCAT.

*___필드명/통화/단위/ICON/CHECKBOX/JUST/EMPHA/FIX/NOOUT/NOZERO/LENG/
*___TEXT/REF_FIELD/REF_TABLE/TECH/TYPE/NOSUM/DOSUM/HOT/EDIT
  PERFORM MAKE_FIELDCAT_DATA TABLES GT_FIELDCAT
                              USING :
      'ICON'     ' '      ' '     'X' ' ' ' ' ' '    'X' ' ' ' ' 4
      '상태'              ' '     ' '     ' ' 'CHAR' 'X' ' ' ' ' ' ',

      'VBELN'    ' '      ' '     ' ' ' ' ' ' ' '    'X' ' ' ' ' 10
      ' '                 'VBELN' 'VBAP'  ' ' ' '    'X' ' ' ' ' ' ',

      'POSNR'    ' '      ' '     ' ' ' ' 'R' ' '    'X' ' ' ' ' 6
      ' '                 'POSNR' 'VBAP'  ' ' ' '    'X' ' ' ' ' ' ',

      'CONNO'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 10
      '계약번호'          'CONNO' 'VBAP'  ' ' ' '    'X' ' ' ' ' ' ',

      'MESSAGE'  ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 100
      'Message'           ' '     ' '     ' ' 'CHAR' 'X' ' ' ' ' ' '.

ENDFORM.                    " CREATE_FIELD_CATEGORY
*&---------------------------------------------------------------------*
*&      Form  MAKE_FIELDCAT_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM MAKE_FIELDCAT_DATA  TABLES PT_FIELDCAT TYPE SLIS_T_FIELDCAT_ALV
                          USING PV_FNAME
                                PV_CURK
                                PV_UNIT
                                PV_ICON
                                PV_CHECK
                                PV_JUST
                                PV_EMPHA
                                PV_FIX
                                PV_NOOUT
                                PV_NOZERO
                                PV_LENGTH
                                PV_TEXT
                                PV_REFF
                                PV_REFT
                                PV_TECH
                                PV_TYPE
                                PV_NOSUM
                                PV_DOSUM
                                PV_HOTSPOT
                                PV_EDIT.

  DATA : LS_FIELDCAT          TYPE SLIS_FIELDCAT_ALV.

  CLEAR : LS_FIELDCAT.

  GV_POS = GV_POS + 1.

  LS_FIELDCAT-COL_POS        = GV_POS.
  LS_FIELDCAT-FIELDNAME      = PV_FNAME.
  LS_FIELDCAT-CFIELDNAME     = PV_CURK.
  LS_FIELDCAT-QFIELDNAME     = PV_UNIT.
  LS_FIELDCAT-ICON           = PV_ICON.
  LS_FIELDCAT-CHECKBOX       = PV_CHECK.
  LS_FIELDCAT-JUST           = PV_JUST.
  LS_FIELDCAT-EMPHASIZE      = PV_EMPHA.
  LS_FIELDCAT-FIX_COLUMN     = PV_FIX.
  LS_FIELDCAT-KEY            = PV_FIX.
  LS_FIELDCAT-NO_OUT         = PV_NOOUT.
  LS_FIELDCAT-NO_ZERO        = PV_NOZERO.
  LS_FIELDCAT-OUTPUTLEN      = PV_LENGTH.
  LS_FIELDCAT-SELTEXT_S      = PV_TEXT.
  LS_FIELDCAT-SELTEXT_M      = PV_TEXT.
  LS_FIELDCAT-SELTEXT_L      = PV_TEXT.
  LS_FIELDCAT-REF_FIELDNAME  = PV_REFF.
  LS_FIELDCAT-REF_TABNAME    = PV_REFT.
  LS_FIELDCAT-TECH           = PV_TECH.
  LS_FIELDCAT-DATATYPE       = PV_TYPE.
  LS_FIELDCAT-NO_SUM         = PV_NOSUM.
  LS_FIELDCAT-DO_SUM         = PV_DOSUM.
  LS_FIELDCAT-HOTSPOT        = PV_HOTSPOT.
  LS_FIELDCAT-EDIT           = PV_EDIT.

  LS_FIELDCAT-TABNAME        = GV_ITAB.

  APPEND LS_FIELDCAT TO PT_FIELDCAT.

ENDFORM.                    " MAKE_FIELDCAT_DATA
*&---------------------------------------------------------------------*
*&      Form  DISPLAY_ALV_LIST
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM DISPLAY_ALV_LIST  TABLES   P_ITAB.

  GV_REPID = SY-REPID.

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      I_CALLBACK_USER_COMMAND  = GV_USER_COMMAND
      I_CALLBACK_PF_STATUS_SET = GV_STATUS_SET
*      I_CALLBACK_TOP_OF_PAGE   = GV_TOP_OF_PAGE
      I_CALLBACK_PROGRAM       = GV_REPID
      I_GRID_SETTINGS          = GV_GRID_SETTINGS
      IS_LAYOUT                = GS_LAYOUT
      IT_FIELDCAT              = GT_FIELDCAT
      IT_SORT                  = GT_SORT
      I_SAVE                   = 'A'
      IS_VARIANT               = GS_VARIANT
      IT_EVENTS                = GT_EVENTS
      IT_EVENT_EXIT            = GT_EVENTS_EXIT
    TABLES
      T_OUTTAB                 = P_ITAB
    EXCEPTIONS
      PROGRAM_ERROR            = 1
      OTHERS                   = 2.

  IF SY-SUBRC <> 0.
    MESSAGE E003 WITH 'Grid Display 도중 오류가 발생하였습니다.'.
  ENDIF.

ENDFORM.                    " DISPLAY_ALV_LIST
*&---------------------------------------------------------------------*
*&      Form  UPLOAD_CONTRACT_NO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM UPLOAD_CONTRACT_NO .
  DATA: LV_ANSWER,
        LV_FLAG.

  READ TABLE GT_ORDER WITH KEY ICON = '@5C@'.
  IF SY-SUBRC = 0.
    MESSAGE S003 DISPLAY LIKE 'E'
       WITH 'Upload 데이터를 점검하십시오.'.
    EXIT.
  ENDIF.

  PERFORM POPUP_TO_CONFIRM USING '확인'
                                 '계약번호를 Upload 하시겠습니까?'
                                 '1'
                                 LV_ANSWER.
  IF LV_ANSWER = '1'.
    CLEAR : LV_FLAG.

    LOOP AT GT_ORDER.
      UPDATE VBAP SET CONNO = GT_ORDER-CONNO
                WHERE VBELN = GT_ORDER-VBELN
                  AND POSNR = GT_ORDER-POSNR.
      IF SY-SUBRC <> 0.
        LV_FLAG = 'X'.
        EXIT.
      ENDIF.
    ENDLOOP.

    IF LV_FLAG IS INITIAL.
      COMMIT WORK.
      MESSAGE S003 WITH '계약번호 Upload가 완료되었습니다.'.
    ELSE.
      ROLLBACK WORK.
      MESSAGE S003 DISPLAY LIKE 'E'
         WITH '판매오더-품목' GT_ORDER-VBELN GT_ORDER-POSNR
              '계약번호 Upload 시 에러발생!!'.
    ENDIF.
  ELSE.
    MESSAGE S007.
  ENDIF.

ENDFORM.                    " UPLOAD_CONTRACT_NO
*&---------------------------------------------------------------------*
*&      Form  POPUP_TO_CONFIRM
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM POPUP_TO_CONFIRM  USING    PV_TITLE
                                PV_TEXT
                                PV_DEFAULT
                                PV_ANSWER.

  CLEAR : PV_ANSWER.

  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      TITLEBAR              = PV_TITLE
      TEXT_QUESTION         = PV_TEXT
      TEXT_BUTTON_1         = '예'
      ICON_BUTTON_1         = 'ICON_OKAY'
      TEXT_BUTTON_2         = '아니오'
      ICON_BUTTON_2         = 'ICON_CANCEL'
      DEFAULT_BUTTON        = PV_DEFAULT
      DISPLAY_CANCEL_BUTTON = ' '
    IMPORTING
      ANSWER                = PV_ANSWER
    EXCEPTIONS
      TEXT_NOT_FOUND        = 1
      OTHERS                = 2.

ENDFORM.                    " POPUP_TO_CONFIRM
