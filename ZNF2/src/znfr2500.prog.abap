************************************************************************
* 모듈/서브모듈 : MM / 비철                                            *
* Type          : Report                                               *
* GAP ID        : NF-120                                               *
* T_CODE        : ZNF2R2500                                            *
* Description   : 패스워드 관리
************************************************************************
*                        MODIFICATION LOG                              *
*----------------------------------------------------------------------*
*   DATE        AUTHORS              DESCRIPTION                       *
* ----------   --------- --------------------------------------------- *
* 2012/03/30   FIN23     Initial Release                               *
************************************************************************
* Comment :
************************************************************************

REPORT  ZNFR2500 MESSAGE-ID ZNF1.

INCLUDE ZNFR2500TOP.

*----------------------------------------------------------------------*
*   SELECT-OPTIONS
*----------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK BLK1 WITH FRAME TITLE TEXT-001.
PARAMETERS     : P_BUKRS LIKE ZNFT1090-BUKRS OBLIGATORY MEMORY ID BUK.
SELECT-OPTIONS : S_DIVIS FOR  ZZPA0001-ZZ_DIVIS.
PARAMETERS     : P_IDTYP TYPE CHAR04  AS LISTBOX VISIBLE LENGTH 8 .
SELECT-OPTIONS : S_CONGB FOR  ZNFT1090-CONGB,
                 S_PERNR FOR  ZNFT1090-PERNR.

* 삭제여부
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT (31) TEXT-002.
PARAMETERS     : P_CHK01 AS CHECKBOX.
SELECTION-SCREEN COMMENT (16) TEXT-003 FOR FIELD P_CHK01.
PARAMETERS     : P_CHK02 AS CHECKBOX DEFAULT 'X'.
SELECTION-SCREEN COMMENT (16) TEXT-004 FOR FIELD P_CHK02.
SELECTION-SCREEN END   OF LINE.
SELECTION-SCREEN END   OF BLOCK BLK1.

*----------------------------------------------------------------------*
*   AT SELECTION-SCREEN
*----------------------------------------------------------------------*
AT SELECTION-SCREEN ON VALUE-REQUEST FOR S_DIVIS-LOW.
  PERFORM F4HELP_DIV USING S_DIVIS-LOW.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR S_DIVIS-HIGH.
  PERFORM F4HELP_DIV USING S_DIVIS-HIGH.

*AT SELECTION-SCREEN ON VALUE-REQUEST FOR S_PERNR-LOW.
*  PERFORM F4HELP_PERNR USING S_PERNR-LOW.
*
*AT SELECTION-SCREEN ON VALUE-REQUEST FOR S_PERNR-HIGH.
*  PERFORM F4HELP_PERNR USING S_PERNR-HIGH.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR P_IDTYP.
  PERFORM GET_DATA_ID_TYPE  USING 'P_IDTYP'.

*----------------------------------------------------------------------*
*     INITIALIZATION                                                   *
*----------------------------------------------------------------------*
INITIALIZATION.
*----------------------------------------------------------------------*
*     START-OF-SELECTION                                               *
*----------------------------------------------------------------------*
START-OF-SELECTION.
  PERFORM CHECK_LVORM USING GV_ERROR.
  CHECK GV_ERROR IS INITIAL.
  PERFORM DATA_SELECT_ZNFT1090.
*----------------------------------------------------------------------*
*     END-OF-SELECTION                                                 *
*----------------------------------------------------------------------*
END-OF-SELECTION.
*  CHECK GT_OUTTAB IS NOT INITIAL.
  CALL SCREEN 1100.
*----------------------------------------------------------------------*
*     INCLUDE                                                          *
*----------------------------------------------------------------------*
INCLUDE ZNF2COMM.

INCLUDE ZNFR2500F01.

INCLUDE ZNFR2500O01.

INCLUDE ZNFR2500I01.
