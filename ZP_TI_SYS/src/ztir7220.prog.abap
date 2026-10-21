************************************************************************
* 모듈/서브모듈 : MM / 수입                                            *
* Type          : Report                                               *
* GAP ID        :                                                      *
* T_CODE        : ZTIR7221, ZTIR7222, ZTIR7223                         *
* Description   : 인수증 발행 승인
************************************************************************
*                        MODIFICATION LOG                              *
*----------------------------------------------------------------------*
*   DATE        AUTHORS              DESCRIPTION                       *
* ----------   --------- --------------------------------------------- *
* 2014/01/31   EDB03     Initial Release                               *
************************************************************************
* Comment :
************************************************************************

REPORT  ZTIR7220 MESSAGE-ID ZMTI00.

INCLUDE ZTIR7220TOP.

*----------------------------------------------------------------------*
*   SELECT-OPTIONS
*----------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK BLK1 WITH FRAME TITLE TEXT-001.
PARAMETERS     : P_BUKRS LIKE ZTITTXK-BUKRS OBLIGATORY MEMORY ID BUK.
SELECT-OPTIONS : S_ACDNO  FOR ZTITACK-ACDNO,   "(인수증관리번호)
                 S_REQNO  FOR ZTITACK-REQNO,   "(수입요청관리번호)
                 S_LIFNR  FOR ZTITACK-LIFNR,   "(구매처)
                 S_ISSDT  FOR ZTITACK-ISSDT,   "(발급일)
                 S_LBANR  FOR ZTITACK-LBANR.   "(신용장(계약서번호))
SELECTION-SCREEN END   OF BLOCK BLK1.

*----------------------------------------------------------------------*
*     INITIALIZATION                                                   *
*----------------------------------------------------------------------*
INITIALIZATION.
  PERFORM SET_DEFAULT_PARAMETER.

*----------------------------------------------------------------------*
*   AT SELECTION-SCREEN                                                *
*----------------------------------------------------------------------*
AT SELECTION-SCREEN.
*.권한체크
  PERFORM authorization_check.

*----------------------------------------------------------------------*
*     START-OF-SELECTION                                               *
*----------------------------------------------------------------------*
START-OF-SELECTION.
  PERFORM MAKE_RANGES_ELDFN.
  PERFORM DATA_SELECT_ZTITACK.

*----------------------------------------------------------------------*
*     END-OF-SELECTION                                                 *
*----------------------------------------------------------------------*
END-OF-SELECTION.
  IF GT_OUTTAB IS NOT INITIAL AND LINES( GT_OUTTAB ) GT 0.
    CALL SCREEN 1100.
  ELSE.
    MESSAGE S383(ME).
  ENDIF.


*----------------------------------------------------------------------*
*     INCLUDE                                                          *
*----------------------------------------------------------------------*
  INCLUDE ZTIR7220F01.

  INCLUDE ZTIR7220O01.

  INCLUDE ZTIR7220I01.
