*&--------------------------------------------------------*
*& 모듈           : MM                                                                              *
*& 프로그램 ID : ZGTMMR3000                                                                *
*& 프로그램 명 : [MM] 구매 발주 관리
*& 개요          :가온전선_구매오더로 전환/ 직접 PO 생성/ PO 승인/ PO 진행 현황을
*                    조회할 수 있는 프로그램
*& 생성일       : 2026.03.10                                                                    *
*& 생성자      : ZGODEV04                                                                      *
*&--------------------------------------------------------*
*& 외부 호출 프로그램 개요   : N/A                                                            *
*& 타 시스템 인터페이스 개요 : N/A                                                           *
*&-------------------------------------------------------*
*& 프로그램 수정이력
*&-------------------------------------------------------*
*&     수정일             수정자             수정개요
*& ----------   ---------  ---------------------------------*
*&
*&-------------------------------------------------------*
REPORT ZGTMMR3000 MESSAGE-ID ZGTMM01.

*&-------------------------------------------------------*
*&    INCLUDE.
*&-------------------------------------------------------*
INCLUDE ZGTMMR3000TOP.    " GLOBAL DATA
INCLUDE ZGTMMR3000C01.    " ALV CLASS
INCLUDE ZGTMMR3000O01.   " PBO-MODULES
INCLUDE ZGTMMR3000I01.    " PAI-MODULES
INCLUDE ZGTMMR3000F01.   " FORM-ROUTINES


*&---------------------------------------------------------------------*
*&    INITIALIZATION.
*&---------------------------------------------------------------------*
INITIALIZATION.
  PERFORM INITIALIZATION. "초기값 세팅

*&---------------------------------------------------------------------*
*&    AT SELECTION-SCREEN.
*&---------------------------------------------------------------------*
*AT SELECTION-SCREEN ON VALUE-REQUEST FOR P_VARI.
*  PERFORM F4_FOR_VARIANT USING P_VARI.

AT SELECTION-SCREEN OUTPUT.
  PERFORM SELECTION_SCREEN_OUTPUT. "스크린 PBO

AT SELECTION-SCREEN.

*&---------------------------------------------------------------------*
*&    START-OF-SELECTION.
*&---------------------------------------------------------------------*
START-OF-SELECTION.
  PERFORM CHECK_AUTH.

  PERFORM INPUT_VALIDATION.      "INPUT DATA VALIDATION CHECK
  CHECK GV_ERR IS INITIAL.

*  PERFORM CHECK_AUTH USING P_BUKRS. "권한 체크

  CASE GC_X.
**--> 26.09 *단순견적 - 추가
    WHEN P_PR OR P_PR2.
       PERFORM GET_DATA.

    WHEN P_CRE.
      PERFORM SET_CREATE_DATA.

    WHEN P_MOT.
*구매오더 진행 현황 모니터링_ZGTMMR3010 호출
       SUBMIT ZGTMMR3010 "VIA SELECTION-SCREEN
       WITH P_BUKRS = P_BUKRS
       WITH P_EKORG = P_EKORG
       WITH S_WERKS IN S_WERKS
       WITH S_EKGRP IN S_EKGRP
       WITH S_ERDAT IN S_ERDAT
       WITH S_EINDT IN S_EINDT
       WITH S_EBELN  IN S_EBELN
       WITH S_LIFNR   IN S_LIFNR
       WITH S_MATNR IN S_MATNR
       WITH S_VBELN IN S_VBELN
       WITH P_DPO = P_DPO
       WITH P_FIN = P_FIN
       WITH P_RPO = P_RPO
       WITH S_SOPO IN S_SOPO  "26.09 판매오더+품목 조회 추가
       AND RETURN.
    WHEN OTHERS.
  ENDCASE.

*&---------------------------------------------------------------------*
*&    END-OF-SELECTION.
*&---------------------------------------------------------------------*
END-OF-SELECTION.

  CHECK GV_ERR IS INITIAL.

  IF P_MOT NE GC_X.

    CASE SY-TCODE.
      WHEN 'ZGTMMR3000'.
        CALL SCREEN 100.

      WHEN 'ZGTMMR3001'.
        CALL SCREEN 400.

      WHEN OTHERS.
    ENDCASE.

  ENDIF.
