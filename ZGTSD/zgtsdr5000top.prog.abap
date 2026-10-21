*&---------------------------------------------------------------------*
*& Include          ZGTSDR0000TOP
*&---------------------------------------------------------------------*

*----------------------------------------------------------------------*
* TABLES
*----------------------------------------------------------------------*
TABLES : VBAK, VBAP, CDHDR.

*----------------------------------------------------------------------*
* Class
*----------------------------------------------------------------------*
CLASS : LCL_EVENT_RECEIVER DEFINITION DEFERRED.

*----------------------------------------------------------------------*
* CONSTANTS
*----------------------------------------------------------------------*
CONSTANTS : GC_E TYPE CHAR1 VALUE 'E',
            GC_X TYPE CHAR1 VALUE 'X'.

CONSTANTS : GC_CRLF TYPE C VALUE CL_BCS_CONVERT=>GC_CRLF,
            GC_TAB  TYPE C VALUE CL_BCS_CONVERT=>GC_TAB.


*----------------------------------------------------------------------*
* VARIABLE
*----------------------------------------------------------------------*
DATA : GV_SAVEOK LIKE SY-UCOMM,
       GV_OKCODE LIKE SY-UCOMM,
       GV_ERROR  TYPE CHAR1,
       GV_ANSWER TYPE CHAR1.

*----------------------------------------------------------------------*
* TYPE & STRUCTURE & INTERNAL TABLE
*----------------------------------------------------------------------*
DATA : GT_FCODE   TYPE TABLE OF SY-UCOMM,
       GT_CELLTAB TYPE LVC_T_STYL.

"ALV Default Fields
TYPES : BEGIN OF TY_S_ALVDEF,
          STATU TYPE ICON_D,     "신규/변경/삭제 상태 ICON
          INSRT TYPE CHAR1,      "신규 여부 Flag : 'X' or ' '
          MODI  TYPE CHAR1,      "변경 여부 Flag : 'X' or ' '
          CELLS TYPE LVC_T_STYL, "Cell Style
          CELLC TYPE LVC_T_STYL, "Cell Color
        END OF TY_S_ALVDEF.

TYPES : BEGIN OF TY_S_CHG,
          VKORG TYPE VKORG,
          MATNR TYPE MATNR,
        END OF TY_S_CHG,
        TY_T_CHG TYPE TABLE OF TY_S_CHG
                   WITH NON-UNIQUE SORTED KEY KEY_MODE
                   COMPONENTS VKORG.

DATA  : BEGIN OF GS_S0100,
          RECTP        TYPE ZGTSDT1001-RECTP,
          RECYR        TYPE ZGTSDT1001-RECYR,
          RECNO        TYPE ZGTSDT1001-RECNO,
          VBELN        TYPE VBELN,
          UPD_TMSTMP   TYPE VBAK-UPD_TMSTMP,
          USERNAME     TYPE CDHDR-USERNAME,
          NAME         TYPE AD_NAME1,
          UDATE        TYPE CDHDR-UDATE,
          UTIME        TYPE CDHDR-UTIME,
          FNAME        TYPE CDPOS-FNAME,
          FTEXT        TYPE DDTEXT,
          VALUE_OLD    TYPE CDPOS-VALUE_OLD,
          VALUE_OLD_NM TYPE CHAR40,
          VALUE_NEW    TYPE CDPOS-VALUE_NEW,
          VALUE_NEW_NM TYPE CHAR40,
          SEND_DATE    TYPE SY-DATUM,
          SEND_TIME    TYPE SY-UZEIT,
          VKORG        TYPE VKORG,
          VKBUR        TYPE VKBUR,
          AUART        TYPE AUART,
          MATNR        TYPE MATNR,
          POSNR        TYPE POSNR_VA.
          INCLUDE    TYPE TY_S_ALVDEF. "ALV Default Fields
DATA : END OF GS_S0100.
DATA : GT_S0100 LIKE TABLE OF GS_S0100.

"화면 변경 정보
DATA : GT_CHG   TYPE TY_T_CHG,
       GT_AUART TYPE TABLE OF ZGTPPT1010 WITH EMPTY KEY,
       GT_VKBUR TYPE TABLE OF ZGTPPT1010 WITH EMPTY KEY.

RANGES : GR_AUART FOR VBAK-AUART,
         GR_VKBUR FOR VBAK-VKBUR.
*----------------------------------------------------------------------*
*  ALV GRID.
*----------------------------------------------------------------------*

DATA : GT_TOOLBAR TYPE UI_FUNCTIONS.
DATA : GO_CON     TYPE REF TO CL_GUI_DOCKING_CONTAINER,
       GO_GRID    TYPE REF TO CL_GUI_ALV_GRID,
       GT_FCAT    TYPE LVC_T_FCAT,
       GS_FCAT    TYPE LVC_S_FCAT,
       GT_SORT    TYPE LVC_T_SORT,   " ALV Sort
       GS_LAYOUT  TYPE LVC_S_LAYO,
       GO_SPLIT   TYPE REF TO CL_GUI_SPLITTER_CONTAINER,
       GO_CON_TOP TYPE REF TO CL_GUI_CONTAINER,
       GO_DOCU    TYPE REF TO CL_DD_DOCUMENT.



*DATA : GO_EVNT TYPE REF TO LCL_ALV_EVENT_HANDLER. "EVENT
DATA : GS_VARIANT TYPE DISVARIANT.
DATA : GS_STBL TYPE LVC_S_STBL.

DATA : GT_ROW TYPE LVC_T_ROW WITH HEADER LINE,
       GS_ROW LIKE GT_ROW.

**------------------------------------------------------
** E-Mail Send 관련
**------------------------------------------------------
DATA: G_EMAIL        TYPE REF TO CL_BCS,
      G_EMAIL_BODY   TYPE REF TO CL_DOCUMENT_BCS,
      G_RECEIVER     TYPE REF TO IF_RECIPIENT_BCS,
      G_SENDER       TYPE REF TO IF_SENDER_BCS,
      GV_ADDRESS     TYPE AD_SMTPADR,
      GV_ADDRESS_MNG TYPE AD_SMTPADR,
      GV_SENDER      LIKE USR02-BNAME,  "발신인
      GV_SEND_RESULT TYPE C,
      G_EXCEPTION    TYPE REF TO CX_BCS,
      GT_BODY        TYPE  BCSY_TEXT,
      GT_EMAIL       TYPE SOMLRECI1 OCCURS 0 WITH HEADER LINE,
      GV_LINE(255) ,
      GV_SUBJECT     TYPE SO_OBJ_DES.

*----------------------------------------------------------------------*
* DEFINE
*----------------------------------------------------------------------*
DEFINE __CLE.
  CLEAR: &1, &1[].
END-OF-DEFINITION.

DEFINE __RNG.
  &1-SIGN   = &2.
  &1-OPTION = &3.
  &1-LOW    = &4.
  &1-HIGH    = &5.
  APPEND &1. CLEAR &1.
END-OF-DEFINITION.

DEFINE __ALPHA_IN.
  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      INPUT  = &1
    IMPORTING
      OUTPUT = &2.
END-OF-DEFINITION.

DEFINE __ALPHA_OU.
  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
    EXPORTING
      INPUT  = &1
    IMPORTING
      OUTPUT = &2.
END-OF-DEFINITION.
