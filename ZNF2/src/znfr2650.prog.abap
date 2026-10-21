************************************************************************
* 모듈/서브모듈 : MM / 비철                                            *
* Type          : Report                                               *
* GAP ID        : NF-2650                                              *
* T_CODE        : ZNF2R2650                                            *
* Description   : Open Position 내역
************************************************************************
*                        MODIFICATION LOG                              *
*----------------------------------------------------------------------*
*   DATE        AUTHORS              DESCRIPTION                       *
* ----------   --------- --------------------------------------------- *
* 2012/05/08   FIC23     Initial Release                               *
* 2015/11/13   신재호    [기능개선 103161] 고객필드 및 조회조건 추가   *
* 2015/12/09   신재호    [기능개선 107383] 만기이동차수 필드 추가      *
************************************************************************
* Comment :
************************************************************************

REPORT  ZNFR2650  MESSAGE-ID ZNF1.

INCLUDE ZNFR2650TOP.

*----------------------------------------------------------------------*
*   SELECT-OPTIONS
*----------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK BLK1 WITH FRAME TITLE TEXT-001.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS     : P_R01 RADIOBUTTON GROUP GR1 DEFAULT 'X'
                                             USER-COMMAND RD_FCODE.
SELECTION-SCREEN COMMENT (20) TEXT-011 FOR FIELD P_R01.
PARAMETERS     : P_R02 RADIOBUTTON GROUP GR1.
SELECTION-SCREEN COMMENT (20) TEXT-012 FOR FIELD P_R02.
SELECTION-SCREEN END   OF LINE.
SELECTION-SCREEN END   OF BLOCK BLK1.

SELECTION-SCREEN BEGIN OF BLOCK BLK2 WITH FRAME TITLE TEXT-002.
PARAMETERS     : P_BUKRS LIKE ZNFT1040-BUKRS OBLIGATORY
                                             MEMORY ID BUK.
SELECT-OPTIONS : S_FCM   FOR  ZNFT1020-FCM   MODIF ID MD1, " FCM
                 S_RUDAT FOR  ZNFT1020-RUDAT MODIF ID MD1, " 집행일
                 S_RQTYP FOR  ZNFT1010-RQTYP MODIF ID MD1, " 요청유형
                 S_BY_SL FOR  ZNFT1020-BY_SL MODIF ID MD1, " BUY / SELL
                 S_ENDAT FOR  ZNFT1020-ENDAT MODIF ID MD1, " 만기일
                 S_NFKEY FOR  ZNFT1020-NFKEY MODIF ID MD1, " 비철구분
                 S_PRCTR FOR  ZNFT1000-PRCTR MODIF ID MD1, " 손익센터
                 S_VKGRP FOR  ZNFT1000-VKGRP MODIF ID MD1, " 영업그룹
                 S_NFCTR FOR  ZNFT1000-NFCTR MODIF ID MD1, " 사업부
                 S_REQNO FOR  ZNFT1011-REQNO MODIF ID MD1, " 선물요청번호
                 S_ERDAT FOR  ZNFT1011-ERDAT MODIF ID MD1, " 선물요청일
                 S_KUNNR FOR  ZNFT1000-KUNNR MODIF ID MD1. " 고객
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS     : P_CHK01 AS CHECKBOX DEFAULT 'X'
                                      MODIF ID MD1.        " 신규선물
SELECTION-SCREEN COMMENT (20) TEXT-013 FOR FIELD P_CHK01.
PARAMETERS     : P_CHK02 AS CHECKBOX DEFAULT 'X'
                                      MODIF ID MD1.        " 청산선물
SELECTION-SCREEN COMMENT (20) TEXT-014 FOR FIELD P_CHK02.
SELECTION-SCREEN END   OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS     : P_R11 RADIOBUTTON GROUP GR2
                                   MODIF ID MD1.         " 내부선물포함
SELECTION-SCREEN COMMENT (20) TEXT-015 FOR FIELD P_R11.
PARAMETERS     : P_R12 RADIOBUTTON GROUP GR2 DEFAULT 'X'
                                   MODIF ID MD1.         " 내부선물제외
SELECTION-SCREEN COMMENT (20) TEXT-016 FOR FIELD P_R12.
SELECTION-SCREEN END   OF LINE.
SELECTION-SCREEN END   OF BLOCK BLK2.

SELECTION-SCREEN BEGIN OF BLOCK BLK3 WITH FRAME TITLE TEXT-003.
PARAMETERS     : P_VRSIO LIKE ZNFT1054-VRSIO MODIF ID MD2,
                 P_SVDAT LIKE ZNFT1054-ERDAT MODIF ID MD2,
                 P_SRNAM LIKE ZNFT1054-ERNAM MODIF ID MD2.
SELECTION-SCREEN END   OF BLOCK BLK3.

*----------------------------------------------------------------------*
*     INITIALIZATION                                                   *
*----------------------------------------------------------------------*
INITIALIZATION.
  PERFORM INITIAL_SETTING.

*----------------------------------------------------------------------*
*     AT SELECTION-SCREEN                                              *
*----------------------------------------------------------------------*
AT SELECTION-SCREEN OUTPUT.
  PERFORM MODIF_SCREEN_1000.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR S_FCM-LOW.
  PERFORM F4HELP_FCM USING S_FCM-LOW.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR S_FCM-HIGH.
  PERFORM F4HELP_FCM USING S_FCM-HIGH.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR S_NFCTR-LOW.
  PERFORM F4HELP_NFCTR USING S_NFCTR-LOW.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR S_NFCTR-HIGH.
  PERFORM F4HELP_NFCTR USING S_NFCTR-HIGH.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR S_PRCTR-LOW.
  PERFORM F4HELP_PRCTR USING S_PRCTR-LOW.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR S_PRCTR-HIGH.
  PERFORM F4HELP_PRCTR USING S_PRCTR-HIGH.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR P_VRSIO.
  PERFORM F4HELP_SAVE_VER USING P_VRSIO   " 저장버전 - 일자
                                P_SVDAT   " 저장버전 - 일자
                                P_SRNAM.  " 저장버전 - 실행자

AT SELECTION-SCREEN ON VALUE-REQUEST FOR P_SVDAT.
  PERFORM F4HELP_SAVE_VER USING P_VRSIO   " 저장버전 - 일자
                                P_SVDAT   " 저장버전 - 일자
                                P_SRNAM.  " 저장버전 - 실행자

AT SELECTION-SCREEN ON VALUE-REQUEST FOR P_SRNAM.
  PERFORM F4HELP_SAVE_VER USING P_VRSIO   " 저장버전 - 일자
                                P_SVDAT   " 저장버전 - 일자
                                P_SRNAM.  " 저장버전 - 실행자

AT SELECTION-SCREEN.
  PERFORM CHECK_AUTHORIZATION USING P_BUKRS
                                    GV_ERROR.

  IF GV_ERROR IS NOT INITIAL.
    STOP.
  ENDIF.

  PERFORM CHECK_SELECTED_CHECKBOX USING GV_ERROR.

  IF GV_ERROR IS NOT INITIAL.
    STOP.
  ENDIF.

  PERFORM CHECK_SELECTED_RADIOBTN.

*----------------------------------------------------------------------*
*     START-OF-SELECTION                                               *
*----------------------------------------------------------------------*
START-OF-SELECTION.
* 회사코드 기본값
  PERFORM GET_DEFAULT_COMPANY_DATA USING P_BUKRS
                                         GV_WAERS
                                         GV_LAND1
                                         GV_BUTXT
                                         GV_KTOPL
                                         GV_KOKRS.

* GET_DATA
  IF P_R01 EQ 'X'.
    PERFORM DATA_SELECT.
  ELSE.
    PERFORM CHECK_R02_CONDI USING GV_ERROR.
    CHECK GV_ERROR IS INITIAL.
*    PERFORM MAKE_RANGES_VAR.
    PERFORM DATA_SAVE_LIST.
  ENDIF.


*----------------------------------------------------------------------*
*     END-OF-SELECTION                                                 *
*----------------------------------------------------------------------*
END-OF-SELECTION.
  CHECK GV_ERROR IS INITIAL.

  IF P_R01 EQ 'X'.
    IF GT_OUTTAB IS NOT INITIAL AND LINES( GT_OUTTAB ) GT 0.
      CALL SCREEN 1100.
    ELSE.
      MESSAGE S383(ME).
    ENDIF.
  ELSE.
    IF GT_OUTTAB_LIST IS NOT INITIAL AND LINES( GT_OUTTAB_LIST ) GT 0.
      CALL SCREEN 1100.
    ELSE.
      MESSAGE S383(ME).
    ENDIF.
  ENDIF.

  INCLUDE ZNF2COMM.
  INCLUDE ZNFR2650O01.
  INCLUDE ZNFR2650I01.
  INCLUDE ZNFR2650F01.
