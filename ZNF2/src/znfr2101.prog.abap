************************************************************************
* 모듈/서브모듈 : MM / 비철                                            *
* Type          : Report                                               *
* GAP ID        : NF-2101                                              *
* T_CODE        : ZNF2R2101                                            *
* Description   : 선물요청 생성(Excel Upload)                          *
************************************************************************
*                        MODIFICATION LOG                              *
*----------------------------------------------------------------------*
*   DATE        AUTHORS              DESCRIPTION                       *
* ----------   --------- --------------------------------------------- *
* 2012/03/05   FIC23     Initial Release                               *
************************************************************************
* Comment :
************************************************************************

*----------------------------------------------------------------------*
*   Message Class : ZNF1 참조                                          *
*----------------------------------------------------------------------*
REPORT  ZNFR2101 MESSAGE-ID ZNF1.

INCLUDE ZNFR2101TOP.

*----------------------------------------------------------------------*
*   SELECT-OPTIONS
*----------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK B1 WITH FRAME TITLE TEXT-001.
PARAMETERS: P_BUKRS  LIKE ZNFT1010-BUKRS OBLIGATORY MEMORY ID BUK,
            P_FNAME1 LIKE RLGRAP-FILENAME.
SELECTION-SCREEN END OF BLOCK B1.

SELECTION-SCREEN FUNCTION KEY 1.

*----------------------------------------------------------------------*
*     INITIALIZATION                                                   *
*----------------------------------------------------------------------*
INITIALIZATION.

  GV_EXCEL_FLAG    = 'N'.
  GV_COMPLETE_SAVE = 'N'.
  GV_COMPLETE_REQ  = 'N'.

  PERFORM INTERFACE_SETTING.

*----------------------------------------------------------------------*
*     AT SELECTION-SCREEN                                              *
*----------------------------------------------------------------------*
AT SELECTION-SCREEN.

  CASE SSCRFIELDS-UCOMM.
    WHEN 'FC01'.
      CLEAR GV_SAVE_LOC.
      PERFORM SET_DOWNLOAD_LOCATION USING GV_SAVE_LOC.
      CHECK GV_SAVE_LOC IS NOT INITIAL.
      PERFORM GET_DOWNLOAD_EXCEL USING GV_SAVE_LOC.
    WHEN OTHERS.
  ENDCASE.

* ----------------------------------------------------------------------
* AT SELECTION-SCREEN ON VALUE-REQUEST
* ----------------------------------------------------------------------
AT SELECTION-SCREEN ON VALUE-REQUEST FOR P_FNAME1.
  PERFORM GET_UPLOAD_FILENAME CHANGING P_FNAME1.
*----------------------------------------------------------------------*
*     START-OF-SELECTION                                               *
*----------------------------------------------------------------------*
START-OF-SELECTION.

  IF P_FNAME1 IS INITIAL.
    MESSAGE 'Upload할 Excel파일을 먼저 선택하십시오.'
       TYPE 'I' DISPLAY LIKE 'E'.
  ENDIF.

  IF NOT P_FNAME1 IS INITIAL.
    PERFORM UPLOAD_EXCEL_TO_ITAB.
  ENDIF.


*----------------------------------------------------------------------*
*     END-OF-SELECTION                                                 *
*----------------------------------------------------------------------*
END-OF-SELECTION.

  IF gt_outtab IS NOT INITIAL AND lines( gt_outtab ) GT 0.
    call SCREEN 1100.
*    gv_cnt = lines( gt_outtab[] ).
*    MESSAGE s368(00) WITH gv_cnt '건이 Upload 되었습니다.'.
  ELSE.
    MESSAGE s383(me).
  ENDIF.

*----------------------------------------------------------------------*
*     ETC. Include 참조                                                *
*----------------------------------------------------------------------*

  INCLUDE ZNF2COMM.         " 공통 Sub-routine

  INCLUDE ZNFR2101F01.      " ZNFR2101 전용 Sub-routine

  INCLUDE ZNFR2101O01.      " PBO

  INCLUDE ZNFR2101I01.      " PAI
