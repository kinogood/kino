************************************************************************
* 모듈/서브모듈 : MM / 비철                                            *
* Type          : Report                                               *
* GAP ID        : NF-2690                                              *
* T_CODE        : ZNF2R2690                                            *
* Description   : 신규-청산 선물집행 List                              *
************************************************************************
*                        MODIFICATION LOG                              *
*----------------------------------------------------------------------*
*   DATE        AUTHORS              DESCRIPTION                       *
* ----------   --------- --------------------------------------------- *
* 2012/07/23   EDB03     Initial Release                               *
* 2012/09/03   EDB03     C20120831_74728 - 청산조회 SQL 수정           *
************************************************************************
* Comment :
************************************************************************

REPORT  ZNFR2690  MESSAGE-ID ZNF1.

INCLUDE ZNFR2690_TOP.

*----------------------------------------------------------------------*
*   SELECT-OPTIONS
*----------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK BLK1 WITH FRAME TITLE TEXT-001.
PARAMETERS     : P_BUKRS LIKE ZNFT1040-BUKRS OBLIGATORY MEMORY ID BUK.
SELECT-OPTIONS : S_FCM   FOR  ZNFT1020-FCM  ,  " FCM
                 S_RUDAT FOR  ZNFT1020-RUDAT,  " 선물집행일
                 S_NFKEY FOR  ZNFT1020-NFKEY,  " 비철구분
                 S_PRCTR FOR  ZNFT1000-PRCTR,  " 손익센터
                 S_ENDAT FOR  ZNFT1020-ENDAT,  " 만기일
                 S_NFCTR FOR  ZNFT1000-NFCTR,  " 사업부
                 S_REQNO FOR  ZNFT1010-REQNO,  " 선물요청번호
                 S_ERDAT FOR  ZNFT1010-ERDAT,  " 선물요청일
                 S_NFUTN FOR  ZNFT1020-NFUTN,  " 신규선물집행번호
                 S_CFUTN FOR  ZNFT1030-CFUTN.  " 청산선물집행번호
SELECTION-SCREEN END   OF BLOCK BLK1.

*요청유형 구분
SELECTION-SCREEN BEGIN OF BLOCK BLK4 WITH FRAME TITLE TEXT-002.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS     : P_R01   RADIOBUTTON GROUP GR1.
SELECTION-SCREEN COMMENT (15) TEXT-021 FOR FIELD P_R01.
PARAMETERS     : P_R02   RADIOBUTTON GROUP GR1 DEFAULT 'X'.
SELECTION-SCREEN COMMENT (15) TEXT-022 FOR FIELD P_R02.
SELECTION-SCREEN END   OF LINE.
SELECTION-SCREEN END   OF BLOCK BLK4.

*넷팅 구분
SELECTION-SCREEN BEGIN OF BLOCK BLK5 WITH FRAME TITLE TEXT-003.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS     : P_R11   RADIOBUTTON GROUP GR2.
SELECTION-SCREEN COMMENT (15) TEXT-031 FOR FIELD P_R11.
PARAMETERS     : P_R12   RADIOBUTTON GROUP GR2 DEFAULT 'X'.
SELECTION-SCREEN COMMENT (15) TEXT-032 FOR FIELD P_R12.
SELECTION-SCREEN END   OF LINE.
SELECTION-SCREEN END   OF BLOCK BLK5.

*----------------------------------------------------------------------*
*     INITIALIZATION                                                   *
*----------------------------------------------------------------------*
INITIALIZATION.

*----------------------------------------------------------------------*
*     AT SELECTION-SCREEN                                              *
*----------------------------------------------------------------------*
AT SELECTION-SCREEN ON VALUE-REQUEST FOR S_FCM-LOW.
  PERFORM F4HELP_FCM USING S_FCM-LOW.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR S_FCM-HIGH.
  PERFORM F4HELP_FCM USING S_FCM-HIGH.


AT SELECTION-SCREEN.
  PERFORM CHECK_AUTHORIZATION USING P_BUKRS
                                    GV_ERROR.
  IF GV_ERROR IS NOT INITIAL.
    STOP.
  ENDIF.

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

* 요청유형 & 넷팅
  PERFORM CHECK_SELECT_RADIO.

* Selected Data Query
  PERFORM DATA_SELECT.

*----------------------------------------------------------------------*
*     END-OF-SELECTION                                                 *
*----------------------------------------------------------------------*
END-OF-SELECTION.

  CHECK GV_ERROR IS INITIAL.

  IF GT_OUTTAB IS NOT INITIAL AND LINES( GT_OUTTAB ) GT 0.
    CALL SCREEN 1100.
  ELSE.
    MESSAGE S383(ME).
  ENDIF.

  INCLUDE ZNF2COMM.
  INCLUDE ZNFR2690_F01.
  INCLUDE ZNFR2690_O01.
  INCLUDE ZNFR2690_I01.
