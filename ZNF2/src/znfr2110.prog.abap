************************************************************************
* 모듈/서브모듈 : MM / 비철                                            *
* Type          : Report                                               *
* GAP ID        : NF-110                                               *
* T_CODE        : ZNF2R2110                                            *
* Description   : 선물요청 List 조회                                   *
************************************************************************
*                        MODIFICATION LOG                              *
*----------------------------------------------------------------------*
*   DATE        AUTHORS              DESCRIPTION                       *
* ----------   --------- --------------------------------------------- *
************************************************************************
* 2012/02/03   SDC24     Initial Release                               *
*----------------------------------------------------------------------*
* Comment :
************************************************************************
* 2012/08/23   MMB04(HDY)     변경근거 : C20120821_68215               *
*----------------------------------------------------------------------*
* Comment : 수주금액의 통화값 변경
************************************************************************

REPORT  znfr2110  MESSAGE-ID znf1.

INCLUDE znfr2110top.

*----------------------------------------------------------------------*
*   SELECT-OPTIONS
*----------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK blk1 WITH FRAME TITLE text-001.
PARAMETERS     : p_bukrs LIKE znft1010-bukrs OBLIGATORY MEMORY ID buk.
SELECT-OPTIONS : s_erdat FOR  znft1010-erdat,
                 s_endmm FOR  znft1011-endmm,
                 s_nfkey FOR  znft1011-nfkey,
                 s_zpjno FOR  znft1000-zpjno,
                 s_nfctr FOR  znft1000-nfctr,
                 s_prctr FOR  znft1000-prctr,
                 s_vkgrp FOR  znft1000-vkgrp,
                 s_conno FOR  znft1011-conno,
                 s_reqno FOR  znft1010-reqno MEMORY ID zreqno.
SELECTION-SCREEN END   OF BLOCK blk1.

SELECTION-SCREEN BEGIN OF BLOCK blk2 WITH FRAME TITLE text-002.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS     : p_chk01 AS CHECKBOX DEFAULT 'X'.
SELECTION-SCREEN COMMENT (15) text-011 FOR FIELD p_chk01.
PARAMETERS     : p_chk02 AS CHECKBOX DEFAULT 'X'.
SELECTION-SCREEN COMMENT (15) text-012 FOR FIELD p_chk02.
PARAMETERS     : p_chk03 AS CHECKBOX DEFAULT 'X'.
SELECTION-SCREEN COMMENT (15) text-013 FOR FIELD p_chk03.
PARAMETERS     : p_chk04 AS CHECKBOX DEFAULT 'X'.
SELECTION-SCREEN COMMENT (15) text-014 FOR FIELD p_chk04.
PARAMETERS     : p_chk05 AS CHECKBOX DEFAULT 'X'.
SELECTION-SCREEN COMMENT (15) text-015 FOR FIELD p_chk05.
SELECTION-SCREEN END   OF LINE.
SELECTION-SCREEN END   OF BLOCK blk2.

SELECTION-SCREEN BEGIN OF BLOCK blk3 WITH FRAME TITLE text-003.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS     : p_chk11 AS CHECKBOX DEFAULT 'X'.
SELECTION-SCREEN COMMENT (15) text-021 FOR FIELD p_chk11.
PARAMETERS     : p_chk12 AS CHECKBOX DEFAULT 'X'.
SELECTION-SCREEN COMMENT (15) text-022 FOR FIELD p_chk12.
SELECTION-SCREEN END   OF LINE.
SELECTION-SCREEN END   OF BLOCK blk3.

SELECTION-SCREEN BEGIN OF BLOCK blk4 WITH FRAME TITLE text-004.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS     : p_chk21 AS CHECKBOX DEFAULT 'X'.
SELECTION-SCREEN COMMENT (10) text-031 FOR FIELD p_chk21.
PARAMETERS     : p_chk22 AS CHECKBOX DEFAULT 'X'.
SELECTION-SCREEN COMMENT (10) text-032 FOR FIELD p_chk22.
PARAMETERS     : p_chk23 AS CHECKBOX DEFAULT 'X'.
SELECTION-SCREEN COMMENT (10) text-033 FOR FIELD p_chk23.
PARAMETERS     : p_chk24 AS CHECKBOX DEFAULT 'X'.
SELECTION-SCREEN COMMENT (10) text-034 FOR FIELD p_chk24.
PARAMETERS     : p_chk25 AS CHECKBOX DEFAULT 'X'.
SELECTION-SCREEN COMMENT (10) text-035 FOR FIELD p_chk25.
PARAMETERS     : p_chk26 AS CHECKBOX DEFAULT 'X'.
SELECTION-SCREEN COMMENT (10) text-036 FOR FIELD p_chk26.
PARAMETERS     : p_chk27 AS CHECKBOX DEFAULT 'X'.
SELECTION-SCREEN COMMENT (10) text-037 FOR FIELD p_chk27.
SELECTION-SCREEN END   OF LINE.
SELECTION-SCREEN END   OF BLOCK blk4.

*----------------------------------------------------------------------*
*     INITIALIZATION                                                   *
*----------------------------------------------------------------------*
INITIALIZATION.
  PERFORM set_default_parameter.

*----------------------------------------------------------------------*
*     AT SELECTION-SCREEN                                              *
*----------------------------------------------------------------------*
AT SELECTION-SCREEN ON VALUE-REQUEST FOR s_endmm-low.
  PERFORM f4help_endmm USING s_endmm-low.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR s_endmm-high.
  PERFORM f4help_endmm USING s_endmm-high.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR s_nfctr-low.
  PERFORM f4help_nfctr USING s_nfctr-low.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR s_nfctr-high.
  PERFORM f4help_nfctr USING s_nfctr-high.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR s_prctr-low.
  PERFORM f4help_prctr USING s_prctr-low.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR s_prctr-high.
  PERFORM f4help_prctr USING s_prctr-high.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR s_vkgrp-low.
  PERFORM f4help_vkgrp USING s_vkgrp-low.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR s_vkgrp-high.
  PERFORM f4help_vkgrp USING s_vkgrp-high.

AT SELECTION-SCREEN.
  PERFORM check_authorization USING p_bukrs
                                    gv_error.

  IF gv_error IS NOT INITIAL.
    STOP.
  ENDIF.

  PERFORM check_selected_checkbox USING gv_error.

  IF gv_error IS NOT INITIAL.
    STOP.
  ENDIF.

*----------------------------------------------------------------------*
*     START-OF-SELECTION                                               *
*----------------------------------------------------------------------*
START-OF-SELECTION.
*___회사코드 기본값
  PERFORM get_default_company_data USING p_bukrs
                                         gv_waers
                                         gv_land1
                                         gv_butxt
                                         gv_ktopl
                                         gv_kokrs.

  PERFORM set_ranges.

  PERFORM get_futures_req_data.

*----------------------------------------------------------------------*
*     END-OF-SELECTION                                                 *
*----------------------------------------------------------------------*
END-OF-SELECTION.
  CHECK gv_error IS INITIAL.

  IF gt_main[] IS NOT INITIAL.
    PERFORM display_result.
  ELSE.
    MESSAGE s003 DISPLAY LIKE 'E'
       WITH '선택조건에 해당하는 데이터가 존재하지 않습니다.'.
  ENDIF.

  INCLUDE znf2comm.

  INCLUDE znfr2110f01.
