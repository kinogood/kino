*&---------------------------------------------------------------------*
*&  모듈       : SD
*&  프로그램 ID : ZGTSDR1140
*&  프로그램 명  : 커미션 수금현황 및 지급요청
*&  개요       : 가온전선_커미션 수금현황 및 지급요청
*&  생성일      : 2026.01.29
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
REPORT ZGTSDR1140   NO STANDARD PAGE HEADING
                  MESSAGE-ID ZSD1.

*----------------------------------------------------------------------*
*   INCLUDE                                                            *
*----------------------------------------------------------------------*
INCLUDE ZGTSDR1140TOP.
INCLUDE ZGTSDR1140SEL.
INCLUDE ZGTSDR1140O01.
INCLUDE ZGTSDR1140I01.
INCLUDE ZGTSDR1140F01.
INCLUDE ZGTSDR1140F02.


*----------------------------------------------------------------------*
*   INITIALIZATION                                                     *
*----------------------------------------------------------------------*
INITIALIZATION.

  G_REPID = SY-REPID.
  PERFORM VARIANT_INIT.
  PERFORM SET_INIT.
  PERFORM INTIALIZATION_DATA.

*----------------------------------------------------------------------*
*   AT SELECTION-SCREEN ON VALUE-REQUEST                               *
*----------------------------------------------------------------------*
AT SELECTION-SCREEN ON VALUE-REQUEST FOR P_VARI.
  PERFORM F4_FOR_VARIANT.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR PA_VTWEG.
  PERFORM F4_VTWEG USING 'PA_VTWEG'.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR PA_SPART.
  PERFORM F4_SPART USING 'PA_SPART'.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR PA_VKBUR-LOW.
  PERFORM F4_VKBUR USING 'PA_VKBUR-LOW'.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR PA_VKGRP-LOW.
  PERFORM F4_VKGRP USING 'PA_VKGRP-LOW'.


AT SELECTION-SCREEN.
* 권한 CHECK
  PERFORM AUTHORITY_CHECK.

  PERFORM PAI_OF_SELECTION_SCREEN.

*----------------------------------------------------------------------*
*   START-OF-SELECTION.                                                *
*----------------------------------------------------------------------*
START-OF-SELECTION.

  C_BUKRS  = PA_VKORG.

  PERFORM STATUS USING GT_EXTAB.
  PERFORM INTIALIZATION_DATA.
  PERFORM READ_DATA_PROCESS_HANA.
  PERFORM MODIFY_DATA_PROCESS.

END-OF-SELECTION.
*----------------------------------------------------------------------*
*   ALV                                                                *
*----------------------------------------------------------------------*
  PERFORM DATA_WRITE_PROCESS.






*----------------------------------------------------------------------*
*                  AT USER-COMMAND                                     *
*----------------------------------------------------------------------*
AT USER-COMMAND.
  PERFORM USER_COMMAND USING SY-UCOMM
                             GS_SELFIELD.
*----------------------------------------------------------------------

*&---------------------------------------------------------------------*
*&      Form  authority_check
*&---------------------------------------------------------------------*
FORM AUTHORITY_CHECK .

  DATA: LV_SUBRC  LIKE SY-SUBRC.

  CLEAR : LV_SUBRC.

  CALL FUNCTION 'ZGTSD_AUTHORIZATION_CHECK'
    EXPORTING
      I_VKORG = PA_VKORG
      I_TYPE  = '1'
    IMPORTING
      E_SUBRC = LV_SUBRC.

  IF LV_SUBRC <> 0.
    MESSAGE E200(ZGTSD01) WITH PA_VKORG.
  ENDIF.

  CLEAR : LV_SUBRC.

  CALL FUNCTION 'ZGTSD_AUTHORIZATION_CHECK'
    EXPORTING
      I_VTWEG = PA_VTWEG
      I_TYPE  = '2'
    IMPORTING
      E_SUBRC = LV_SUBRC.

  IF LV_SUBRC <> 0.
    MESSAGE E201(ZGTSD01) WITH PA_VTWEG.
  ENDIF.

  CLEAR : LV_SUBRC.

  CALL FUNCTION 'ZGTSD_AUTHORIZATION_CHECK'
    EXPORTING
      I_SPART = PA_SPART
      I_TYPE  = '3'
    IMPORTING
      E_SUBRC = LV_SUBRC.

  IF LV_SUBRC <> 0.
    MESSAGE E202(ZGTSD01) WITH PA_SPART.
  ENDIF.

*-영업그룹
  SELECT VKGRP
    FROM TVBVK
   WHERE VKGRP IN @PA_VKGRP
    INTO TABLE @DATA(LT_VKGRP).

  LOOP AT LT_VKGRP INTO DATA(LS_VKGRP).
    CALL FUNCTION 'ZGTSD_AUTHORIZATION_CHECK'
      EXPORTING
        I_VKGRP = LS_VKGRP-VKGRP
        I_TYPE  = '7'
      IMPORTING
        E_SUBRC = LV_SUBRC.

    IF LV_SUBRC <> 0.
      MESSAGE E203(ZGTSD01) WITH LS_VKGRP-VKGRP.

    ENDIF.
  ENDLOOP.

ENDFORM.                    " authority_check
*
