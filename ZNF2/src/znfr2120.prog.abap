************************************************************************
* 모듈/서브모듈 : MM / 비철                                            *
* Type          : Report                                               *
* GAP ID        : NF-120                                               *
* T_CODE        : ZNF2R2120                                            *
* Description   : 선물요청 변경(선물부서용)                            *
************************************************************************
*                        MODIFICATION LOG                              *
*----------------------------------------------------------------------*
*   DATE        AUTHORS              DESCRIPTION                       *
* ----------   --------- --------------------------------------------- *
* 2012/02/09   SDC24     Initial Release                               *
************************************************************************
* Comment :
************************************************************************

REPORT  ZNFR2120  MESSAGE-ID ZNF1.

INCLUDE ZNFR2120TOP.

*----------------------------------------------------------------------*
*   SELECT-OPTIONS
*----------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK BLK1 WITH FRAME TITLE TEXT-001.
PARAMETERS     : P_BUKRS LIKE ZNFT1010-BUKRS OBLIGATORY MEMORY ID BUK.
SELECT-OPTIONS : S_ERDAT FOR  ZNFT1010-ERDAT,
                 S_ENDMM FOR  ZNFT1011-ENDMM,
                 S_NFKEY FOR  ZNFT1011-NFKEY,
                 S_NFCTR FOR  ZNFT1000-NFCTR,
                 S_PRCTR FOR  ZNFT1000-PRCTR,
                 S_VKGRP FOR  ZNFT1000-VKGRP,
                 S_CONNO FOR  ZNFT1011-CONNO,
                 S_REQNO FOR  ZNFT1010-REQNO.
SELECTION-SCREEN END   OF BLOCK BLK1.

*___선물요청 마감여부
SELECTION-SCREEN BEGIN OF BLOCK BLK2 WITH FRAME TITLE TEXT-002.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS     : P_CHK01 AS CHECKBOX." DEFAULT 'X'.
SELECTION-SCREEN COMMENT (15) TEXT-011 FOR FIELD P_CHK01.
PARAMETERS     : P_CHK02 AS CHECKBOX DEFAULT 'X'.
SELECTION-SCREEN COMMENT (15) TEXT-012 FOR FIELD P_CHK02.
SELECTION-SCREEN END   OF LINE.
SELECTION-SCREEN END   OF BLOCK BLK2.

*___선물집행 여부
SELECTION-SCREEN BEGIN OF BLOCK BLK3 WITH FRAME TITLE TEXT-003.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS     : P_CHK11 AS CHECKBOX DEFAULT 'X'.
SELECTION-SCREEN COMMENT (15) TEXT-011 FOR FIELD P_CHK11.
PARAMETERS     : P_CHK12 AS CHECKBOX DEFAULT 'X'.
SELECTION-SCREEN COMMENT (15) TEXT-012 FOR FIELD P_CHK12.
SELECTION-SCREEN END   OF LINE.
SELECTION-SCREEN END   OF BLOCK BLK3.

*___요청유형
SELECTION-SCREEN BEGIN OF BLOCK BLK4 WITH FRAME TITLE TEXT-004.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS     : P_CHK21 AS CHECKBOX DEFAULT 'X'.
SELECTION-SCREEN COMMENT (15) TEXT-021 FOR FIELD P_CHK21.
PARAMETERS     : P_CHK22 AS CHECKBOX DEFAULT 'X'.
SELECTION-SCREEN COMMENT (15) TEXT-022 FOR FIELD P_CHK22.
PARAMETERS     : P_CHK23 AS CHECKBOX DEFAULT 'X'.
SELECTION-SCREEN COMMENT (15) TEXT-023 FOR FIELD P_CHK23.
PARAMETERS     : P_CHK24 AS CHECKBOX DEFAULT 'X'.
SELECTION-SCREEN COMMENT (15) TEXT-024 FOR FIELD P_CHK24.
PARAMETERS     : P_CHK25 AS CHECKBOX DEFAULT 'X'.
SELECTION-SCREEN COMMENT (15) TEXT-025 FOR FIELD P_CHK25.
SELECTION-SCREEN END   OF LINE.
SELECTION-SCREEN END   OF BLOCK BLK4.

*___가격구분
SELECTION-SCREEN BEGIN OF BLOCK BLK5 WITH FRAME TITLE TEXT-005.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS     : P_CHK31 AS CHECKBOX DEFAULT 'X'.
SELECTION-SCREEN COMMENT (15) TEXT-031 FOR FIELD P_CHK31.
PARAMETERS     : P_CHK32 AS CHECKBOX DEFAULT 'X'.
SELECTION-SCREEN COMMENT (15) TEXT-032 FOR FIELD P_CHK32.
PARAMETERS     : P_CHK33 AS CHECKBOX DEFAULT 'X'.
SELECTION-SCREEN COMMENT (15) TEXT-033 FOR FIELD P_CHK33.
*PARAMETERS     : P_CHK34 AS CHECKBOX DEFAULT 'X'.
*SELECTION-SCREEN COMMENT (15) TEXT-034 FOR FIELD P_CHK34.
SELECTION-SCREEN END   OF LINE.
SELECTION-SCREEN END   OF BLOCK BLK5.

*----------------------------------------------------------------------*
*     INITIALIZATION                                                   *
*----------------------------------------------------------------------*
INITIALIZATION.
  PERFORM SET_DEFAULT_PARAMETER.

*----------------------------------------------------------------------*
*     AT SELECTION-SCREEN                                              *
*----------------------------------------------------------------------*
AT SELECTION-SCREEN ON VALUE-REQUEST FOR S_ENDMM-LOW.
  PERFORM F4HELP_ENDMM USING S_ENDMM-LOW.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR S_ENDMM-HIGH.
  PERFORM F4HELP_ENDMM USING S_ENDMM-HIGH.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR S_NFCTR-LOW.
  PERFORM F4HELP_NFCTR USING S_NFCTR-LOW.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR S_NFCTR-HIGH.
  PERFORM F4HELP_NFCTR USING S_NFCTR-HIGH.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR S_PRCTR-LOW.
  PERFORM F4HELP_PRCTR USING S_PRCTR-LOW.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR S_PRCTR-HIGH.
  PERFORM F4HELP_PRCTR USING S_PRCTR-HIGH.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR S_VKGRP-LOW.
  PERFORM F4HELP_VKGRP USING S_VKGRP-LOW.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR S_VKGRP-HIGH.
  PERFORM F4HELP_VKGRP USING S_VKGRP-HIGH.

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

*----------------------------------------------------------------------*
*     START-OF-SELECTION                                               *
*----------------------------------------------------------------------*
START-OF-SELECTION.
*___회사코드 기본값
  PERFORM GET_DEFAULT_COMPANY_DATA USING P_BUKRS
                                         GV_WAERS
                                         GV_LAND1
                                         GV_BUTXT
                                         GV_KTOPL
                                         GV_KOKRS.

  PERFORM SET_RANGES.

  PERFORM GET_FUTURES_REQ_DATA.

*----------------------------------------------------------------------*
*     END-OF-SELECTION                                                 *
*----------------------------------------------------------------------*
END-OF-SELECTION.
  CHECK GV_ERROR IS INITIAL.

  IF GT_MAIN[] IS NOT INITIAL.
    CALL SCREEN 0100.
  ELSE.
    MESSAGE S003 DISPLAY LIKE 'E'
       WITH '선택조건에 해당하는 데이터가 존재하지 않습니다.'.
  ENDIF.

INCLUDE ZNF2COMM.

INCLUDE ZNFR2120F01.

INCLUDE ZNFR2120O01.

INCLUDE ZNFR2120I01.
