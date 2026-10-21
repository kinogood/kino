*&---------------------------------------------------------------------*
*&  모듈       : SD
*&  프로그램 ID : ZGTSDR1250
*&  프로그램 명  : 고객불만 조회
*&  개요       : 가온전선_고객불만 조회
*&              ZQMR0696 COPY 생성
*&  생성일      : 2026.03.19
*&  생성자      : ZGODEV01
*&---------------------------------------------------------------------*
*& 외부호출 프로그램 개요   : N/A
*& 타 시스템 인터페이스 개요 : N/A
*----------------------------------------------------------------------*
*& 프로그램 수정이력
*&---------------------------------------------------------------------*
*& 수정일  :
*& 수정자  :
*& 수정개요 :
*&---------------------------------------------------------------------*
REPORT  ZGTSDR1250   NO STANDARD PAGE HEADING
                        MESSAGE-ID  ZQM1.


INCLUDE ZGTSDR1250TOP.
INCLUDE ZGTSDR1250CLS.
INCLUDE ZGTSDR1250O01.
INCLUDE ZGTSDR1250I01.
INCLUDE ZGTSDR1250F01.


*----------------------------------------------------------------------*
* INITIALIZATION
*----------------------------------------------------------------------*
INITIALIZATION.
  GV_REPID = SY-REPID.
  PERFORM SET_BUKRS.
  PERFORM INIT_VARIANT.


*----------------------------------------------------------------------*
*     AT SELECTION-SCREEN OUTPUT.                                      *
*----------------------------------------------------------------------*
AT SELECTION-SCREEN OUTPUT.
  PERFORM SELECTION_SCREEN_OUTPUT.

*----------------------------------------------------------------------*
* AT SELECTION-SCREEN ON VALUE-REQUEST
*----------------------------------------------------------------------*
AT SELECTION-SCREEN ON VALUE-REQUEST FOR P_VARI.
  PERFORM F4_FOR_VARIANT USING P_VARI.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR S_WERKSH-LOW.
  PERFORM F4_WERKS USING 'S_WERKSH-LOW'.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR S_WERKSH-HIGH.
  PERFORM F4_WERKS USING 'S_WERKSH-HIGH'.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR S_WERKSM-LOW.
  PERFORM F4_WERKS USING 'S_WERKSM-LOW'.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR S_WERKSM-HIGH.
  PERFORM F4_WERKS USING 'S_WERKSM-HIGH'.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR S_SPGCD-LOW.
  PERFORM F4_SPART USING 'S_SPGCD-LOW'.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR S_SPGCD-HIGH.
  PERFORM F4_SPART USING 'S_SPGCD-HIGH'.


*----------------------------------------------------------------------*
* AT SELECTION SCREEN
*----------------------------------------------------------------------*
AT SELECTION-SCREEN.
  PERFORM SSCRFIELDS-UCOMM.

*----------------------------------------------------------------------*
* START-OF-SELECTION                                                   *
*----------------------------------------------------------------------*
START-OF-SELECTION.


  PERFORM CHECK_AUTH.
  PERFORM CHECK_SUSER.
  PERFORM GET_BASE.
  PERFORM GET_DATA.
  PERFORM MAKE_DATA.

*----------------------------------------------------------------------*
* END-OF-SELECTION.
*----------------------------------------------------------------------*
END-OF-SELECTION.
  CALL SCREEN 0100.
