*&---------------------------------------------------------------------*
*&  모듈       : SD
*&  프로그램 ID : ZGTSDR1150
*&  프로그램 명  : 커미션 현황 리스트
*&  개요       : 가온전선_커미션 현황 리스트
*&  생성일      : 2025.02.03
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
REPORT ZGTSDR1150   NO STANDARD PAGE HEADING MESSAGE-ID ZSD1.

*----------------------------------------------------------------------*
*                       INCLUDE 문                                     *
*----------------------------------------------------------------------*
INCLUDE ZGTSDR1150TOP.
INCLUDE ZGTSDR1150SEL.
INCLUDE ZGTSDR1150F01.


*----------------------------------------------------------------------*
*                       INITIALIZATION                                 *
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

AT SELECTION-SCREEN ON VALUE-REQUEST FOR PA_VTWEG-LOW.
  PERFORM F4_VTWEG USING 'PA_VTWEG-LOW'.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR PA_VTWEG-HIGH.
  PERFORM F4_VTWEG USING 'PA_VTWEG-HIGH'.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR PA_SPART-LOW.
  PERFORM F4_SPART USING 'PA_SPART-LOW'.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR PA_SPART-HIGH.
  PERFORM F4_SPART USING 'PA_SPART-HIGH'.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR PA_VKBUR-LOW.
  PERFORM F4_VKBUR USING 'PA_VKBUR-LOW'.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR PA_VKBUR-HIGH.
  PERFORM F4_VKBUR USING 'PA_VKBUR-HIGH'.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR PA_VKGRP-LOW.
  PERFORM F4_VKGRP USING 'PA_VKGRP-LOW'.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR PA_VKGRP-HIGH.
  PERFORM F4_VKGRP USING 'PA_VKGRP-HIGH'.

AT SELECTION-SCREEN.
* 권한 CHECK
  PERFORM AUTHORITY_CHECK.
  PERFORM PAI_OF_SELECTION_SCREEN.

*----------------------------------------------------------------------*
*                    START-OF-SELECTION.                               *
*----------------------------------------------------------------------*
START-OF-SELECTION.

  PERFORM SET_MONTH.
  PERFORM STATUS USING GT_EXTAB.
  PERFORM INTIALIZATION_DATA.
  PERFORM READ_DATA_PROCESS.
  PERFORM MODIFY_DATA_PROCESS.
  PERFORM READ_AMT_DATA.
*  PERFORM SET_WELS_DOC.

END-OF-SELECTION.

*----------------------------------------------------------------------*
*                    ALV - 영역                                         *
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

  DATA: GT_TVTW  LIKE TVTW OCCURS 0 WITH HEADER LINE,
        GT_TSPA  LIKE TSPA OCCURS 0 WITH HEADER LINE,
        LV_SUBRC LIKE SY-SUBRC.

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

  SELECT *
    INTO TABLE GT_TVTW
    FROM TVTW
   WHERE VTWEG IN PA_VTWEG.

  LOOP  AT  GT_TVTW.
    CALL FUNCTION 'ZGTSD_AUTHORIZATION_CHECK'
      EXPORTING
        I_VTWEG = GT_TVTW-VTWEG
        I_TYPE  = '2'
      IMPORTING
        E_SUBRC = LV_SUBRC.

    IF LV_SUBRC <> 0.
      MESSAGE E201(ZGTSD01) WITH GT_TVTW-VTWEG.
    ENDIF.
  ENDLOOP.

  SELECT *
    INTO TABLE GT_TSPA
    FROM TSPA
   WHERE SPART IN PA_SPART.

  LOOP  AT  GT_TSPA.
    CLEAR : LV_SUBRC.
    CALL FUNCTION 'ZGTSD_AUTHORIZATION_CHECK'
      EXPORTING
        I_SPART = GT_TSPA-SPART
        I_TYPE  = '3'
      IMPORTING
        E_SUBRC = LV_SUBRC.

    IF LV_SUBRC <> 0.
      MESSAGE E202(ZGTSD01) WITH GT_TSPA-SPART.
    ENDIF.
  ENDLOOP.

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
