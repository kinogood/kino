*&---------------------------------------------------------------------*
*&  Include           ZGTMMR4700ALV                                   *
*&---------------------------------------------------------------------*

*-----------------------------------------------------------------*
* ALV DATA
*-----------------------------------------------------------------*
TYPE-POOLS: SLIS, KKBLO.
DATA: GT_EVENTS            TYPE SLIS_T_EVENT,
      GT_LIST_TOP_OF_PAGE  TYPE SLIS_T_LISTHEADER,
      GT_FIELDCAT          TYPE SLIS_T_FIELDCAT_ALV  WITH HEADER LINE,
      GT_FIELD             TYPE SLIS_T_FIELDCAT_ALV,
      GT_SORT              TYPE SLIS_T_SORTINFO_ALV  WITH HEADER LINE.
*      구조
DATA : GS_LAYOUT               TYPE SLIS_LAYOUT_ALV,
       GS_EXIT_CAUSED_BY_USER  TYPE SLIS_EXIT_BY_USER,
       GS_VARIANT              TYPE DISVARIANT,
       GS_FIELDCAT             TYPE SLIS_FIELDCAT_ALV,
       GS_SORT                 TYPE SLIS_SORTINFO_ALV,
       GS_KEYINFO              TYPE SLIS_KEYINFO_ALV.
*      일반변수
DATA : GV_EXIT_CAUSED_BY_CALLER  TYPE C,
       GV_SAVE                   TYPE C VALUE 'A',
       GV_REPID                  TYPE SY-REPID ,
       GV_PROGRAM                LIKE SY-REPID VALUE SY-REPID,
       GV_TABNAME_HEADER         TYPE SLIS_TABNAME,
       GV_TABNAME_ITEM           TYPE SLIS_TABNAME.
DATA:  GV_CNT LIKE SY-CUCOL.
DATA: LS_LINE  TYPE SLIS_LISTHEADER,
      L_INFO   TYPE SLIS_LISTHEADER-INFO.

CONSTANTS : C_STATUS_SET       TYPE SLIS_FORMNAME VALUE 'PF_STATUS_SET',
            C_USER_COMMAND     TYPE SLIS_FORMNAME VALUE 'USER_COMMAND',
            C_TOP_OF_PAGE      TYPE SLIS_FORMNAME VALUE 'TOP_OF_PAGE',
            C_TOP_OF_LIST      TYPE SLIS_FORMNAME VALUE 'TOP_OF_LIST',
            C_END_OF_LIST      TYPE SLIS_FORMNAME VALUE 'END_OF_LIST'.
