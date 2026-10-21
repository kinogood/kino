*&---------------------------------------------------------------------*
*& Include          ZGTSDR0010TOP
*&---------------------------------------------------------------------*

*----------------------------------------------------------------------*
* TABLES
*----------------------------------------------------------------------*
TABLES : ZSDT_D365_020, ZSDT_D365_021, VBAK.

*----------------------------------------------------------------------*
* Class
*----------------------------------------------------------------------*
CLASS : LCL_EVENT_RECEIVER DEFINITION DEFERRED.

*----------------------------------------------------------------------*
* CONSTANTS
*----------------------------------------------------------------------*
CONSTANTS : GC_E    TYPE CHAR1 VALUE 'E',
            GC_X    TYPE CHAR1 VALUE 'X',
            GC_KPCM TYPE ZGTETARGET VALUE 'KPCM',
            GC_KBDM TYPE ZGTETARGET VALUE 'KBDM'.

CONSTANTS : GC_CRLF TYPE C VALUE CL_BCS_CONVERT=>GC_CRLF,
            GC_TAB  TYPE C VALUE CL_BCS_CONVERT=>GC_TAB.


*----------------------------------------------------------------------*
* VARIABLE
*----------------------------------------------------------------------*
DATA : GV_SAVEOK LIKE SY-UCOMM,
       GV_OKCODE LIKE SY-UCOMM,
       GV_ERROR  TYPE CHAR1,
       GV_EDIT   TYPE CHAR1 VALUE 'X',
       GV_TAR    TYPE ZGTETARGET,
       GV_ANSWER TYPE CHAR1.

*----------------------------------------------------------------------*
* TYPE & STRUCTURE & INTERNAL TABLE
*----------------------------------------------------------------------*
DATA : GT_FCODE   TYPE TABLE OF SY-UCOMM,
       GT_CELLTAB TYPE LVC_T_STYL.

"ALV Default Fields
TYPES : BEGIN OF TY_S_ALVDEF,
          STATU TYPE ICON_D,     "신규/변경/삭제 상태 ICON
          MSG   TYPE TEXT100,
          INSRT TYPE CHAR1,      "신규 여부 Flag : 'X' or ' '
          MODI  TYPE CHAR1,      "변경 여부 Flag : 'X' or ' '
          SEL   TYPE CHAR1,
          CELLS TYPE LVC_T_STYL, "Cell Style
          CELLC TYPE LVC_T_SCOL, "Cell Color
        END OF TY_S_ALVDEF.

TYPES : BEGIN OF TY_S_CHG,
          VKORG TYPE VKORG,
          MATNR TYPE MATNR,
        END OF TY_S_CHG,
        TY_T_CHG TYPE TABLE OF TY_S_CHG
                   WITH NON-UNIQUE SORTED KEY KEY_MODE
                   COMPONENTS VKORG.


DATA  : BEGIN OF GS_S0100,
          HDSEL    TYPE CHAR1,    " SO 단위 선택
          ITSEL    TYPE CHAR1,    " 개별 선택
          KUNNR    TYPE ZSDT_D365_021-KUNNR,
          NAME1    TYPE KNA1-NAME1,
          VKBUR    TYPE ZSDT_D365_021-VKBUR,
          BEZEI    TYPE TVKBT-BEZEI,
          ZPJNO    TYPE ZSDT_D365_021-ZPJNO,
          ZPTXT    TYPE ZSD0106T-ZPTXT,
          NAME     TYPE ZGTMM_CV_GETUSERNAME-NAME,
          VBELN    TYPE ZSDT_D365_021-VBELN,
          POSNR    TYPE ZSDT_D365_021-POSNR,
          MATNR    TYPE ZSDT_D365_021-MATNR,
          ITEMNAME TYPE ZSDT_D365_021-ITEMNAME,
          KWMENG   TYPE VBAP-KWMENG,
          VRKME    TYPE ZSDT_D365_021-VRKME,
          PLNUM    TYPE PLAF-PLNUM,
          PEDTR    TYPE PLAF-PEDTR,
          PPDAT    TYPE ZGTSDT0010-PPDAT,
          SEQNO    TYPE ZSDT_D365_021-SEQNO,
          QUANTITY TYPE ZSDT_D365_021-QUANTITY,
          DLVDATE  TYPE ZSDT_D365_021-DLVDATE,
          QMDAT    TYPE ZGTSDT0010-QMDAT,
          LEDAT    TYPE ZGTSDT0010-LEDAT,
          LODAT    TYPE ZGTSDT0010-LODAT,
          FKDAT    TYPE ZSDT_D365_021-FKDAT,
          ERDAT    TYPE ZSDT_D365_020-ERDAT,
          EDATU    TYPE VBEP-EDATU,
          SPART    TYPE VBAK-SPART,
          VTEXT    TYPE TSPAT-VTEXT,
          UICON    TYPE CHAR10,
          URL      TYPE SPURLURL.
          INCLUDE  TYPE TY_S_ALVDEF.        "ALV Default Fields
DATA : END OF GS_S0100.
DATA : GT_S0100 LIKE TABLE OF GS_S0100.

DATA : BEGIN OF GS_S0101,
         DATE TYPE ERDAT,
         TEXT TYPE CHAR20,
       END OF GS_S0101.

DATA : BEGIN OF GS_S0200,
         VBELN  LIKE ZGTSDT0010-VBELN,
         POSNR  LIKE ZGTSDT0010-POSNR,
         PPDAT  LIKE ZGTSDT0010-PPDAT,
         QMDAT  LIKE ZGTSDT0010-QMDAT,
         LEDAT  LIKE ZGTSDT0010-LEDAT,
         LODAT  LIKE ZGTSDT0010-LODAT,
         ERDAT  LIKE ZGTSDT0010-ERDAT,
         ERZEIT LIKE ZGTSDT0010-ERZEIT,
         ERNAM  LIKE ZGTSDT0010-ERNAM,
         NAME   TYPE CHAR40,
       END OF GS_S0200,
       GT_S0200 LIKE TABLE OF GS_S0200.

"화면 변경 정보
DATA : GT_CHG   TYPE TY_T_CHG.
*----------------------------------------------------------------------*
*  ALV GRID.
*----------------------------------------------------------------------*

DATA : GT_TOOLBAR TYPE UI_FUNCTIONS.
DATA : GT_TOOLBAR2 TYPE UI_FUNCTIONS.
DATA : GO_CON     TYPE REF TO CL_GUI_DOCKING_CONTAINER,
       GO_GRID    TYPE REF TO CL_GUI_ALV_GRID,
       GT_FCAT    TYPE LVC_T_FCAT,
       GS_FCAT    TYPE LVC_S_FCAT,
       GT_SORT    TYPE LVC_T_SORT,   " ALV Sort
       GS_LAYOUT  TYPE LVC_S_LAYO,

       GO_CON2    TYPE REF TO CL_GUI_DOCKING_CONTAINER,
       GO_GRID2   TYPE REF TO CL_GUI_ALV_GRID,
       GT_FCAT2   TYPE LVC_T_FCAT,
       GS_FCAT2   TYPE LVC_S_FCAT,
       GT_SORT2   TYPE LVC_T_SORT,   " ALV Sort
       GS_LAYOUT2 TYPE LVC_S_LAYO,

       GO_SPLIT   TYPE REF TO CL_GUI_SPLITTER_CONTAINER,
       GO_CON_TOP TYPE REF TO CL_GUI_CONTAINER,
       GO_DOCU    TYPE REF TO CL_DD_DOCUMENT.


DATA : GS_VARIANT TYPE DISVARIANT.
DATA : GS_STBL TYPE LVC_S_STBL.

DATA : GT_ROW TYPE LVC_T_ROW WITH HEADER LINE,
       GS_ROW LIKE GT_ROW.

" 'PP'|'QM'|'LE'|'LO'
DATA gv_apply_mode TYPE char2.

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

DEFINE __GET_ROWS.
  __CLE : &2.
  CHECK &1 IS BOUND.
  CALL METHOD &1->GET_SELECTED_ROWS
     IMPORTING
       ET_INDEX_ROWS = &2[].

  DELETE &2 WHERE ROWTYPE IS NOT INITIAL.

  CHECK &3 IS NOT INITIAL.


END-OF-DEFINITION.
