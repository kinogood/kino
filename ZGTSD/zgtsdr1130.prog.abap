*&---------------------------------------------------------------------*
*&  모듈       : SD
*&  프로그램 ID : ZGTSDR1130
*&  프로그램 명  : 커미션 미지급전표 생성
*&  개요       : 가온전선_커미션 미지급전표 생성
*&  생성일      : 2025.02.05
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
REPORT ZGTSDR1130   NO STANDARD PAGE HEADING
                    MESSAGE-ID ZSD1.

*----------------------------------------------------------------------*
*   INCLUDE                                                            *
*----------------------------------------------------------------------*
INCLUDE ZGTSDR1130TOP.
INCLUDE ZGTSDR1130SEL.
INCLUDE ZGTSDR1130O01.
INCLUDE ZGTSDR1130F01.
INCLUDE ZGTSDR1130F02.


*----------------------------------------------------------------------*
*   INITIALIZATION                                                     *
*----------------------------------------------------------------------*
INITIALIZATION.

  G_REPID = SY-REPID.
  PERFORM VARIANT_INIT.
  PERFORM SET_INIT.
  PERFORM INTIALIZATION_DATA.


*----------------------------------------------------------------------*
*   AT SELECTION-SCREEN OUTPUT                                         *
*----------------------------------------------------------------------*
AT SELECTION-SCREEN OUTPUT.
  PERFORM MODIFY_SCREEN.


*----------------------------------------------------------------------*
*   AT SELECTION-SCREEN ON VALUE-REQUEST                               *
*----------------------------------------------------------------------*
AT SELECTION-SCREEN ON VALUE-REQUEST FOR P_VARI.
  PERFORM F4_FOR_VARIANT.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR S_VTWEG-LOW.
  PERFORM F4_VTWEG USING 'S_VTWEG-LOW'.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR S_SPART-LOW.
  PERFORM F4_SPART USING 'S_SPART-LOW'.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR S_VKBUR-LOW.
  PERFORM F4_VKBUR USING 'S_VKBUR-LOW'.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR S_VKGRP-LOW.
  PERFORM F4_VKGRP USING 'S_VKGRP-LOW'.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR S_KNUMA-LOW. "계약No.
  PERFORM F4_KNUMA USING 'S_KNUMA-LOW'.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR P_SPMON.
  PERFORM F4_SPMON USING P_SPMON.



AT SELECTION-SCREEN.
* 권한 CHECK
  PERFORM AUTHORITY_CHECK.
  PERFORM PAI_OF_SELECTION_SCREEN.

*----------------------------------------------------------------------*
*                    START-OF-SELECTION.                               *
*----------------------------------------------------------------------*
START-OF-SELECTION.

  PERFORM STATUS USING GT_EXTAB.
  PERFORM INTIALIZATION_DATA.
  PERFORM READ_DATA_PROCESS.
  PERFORM MODIFY_DATA_PROCESS.

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
      I_VKORG = S_VKORG-LOW
      I_TYPE  = '1'
    IMPORTING
      E_SUBRC = LV_SUBRC.

  IF LV_SUBRC <> 0.
    MESSAGE E002 WITH '영업조직에 대한 권한이 없읍니다'
                      S_VKORG-LOW.
  ENDIF.

  SELECT *
    INTO TABLE GT_TVTW
    FROM TVTW
   WHERE VTWEG IN S_VTWEG.

  LOOP  AT  GT_TVTW.
    CALL FUNCTION 'ZGTSD_AUTHORIZATION_CHECK'
      EXPORTING
        I_VTWEG = GT_TVTW-VTWEG
        I_TYPE  = '2'
      IMPORTING
        E_SUBRC = LV_SUBRC.

    IF LV_SUBRC <> 0.
      MESSAGE E002 WITH '유통채널에 대한 권한이 없읍니다'
                        GT_TVTW-VTWEG.
    ENDIF.
  ENDLOOP.

  SELECT *
    INTO TABLE GT_TSPA
    FROM TSPA
   WHERE SPART IN S_SPART.

  LOOP  AT  GT_TSPA.
    CLEAR : LV_SUBRC.
    CALL FUNCTION 'ZGTSD_AUTHORIZATION_CHECK'
      EXPORTING
        I_SPART = GT_TSPA-SPART
        I_TYPE  = '3'
      IMPORTING
        E_SUBRC = LV_SUBRC.

    IF LV_SUBRC <> 0.
      MESSAGE E002 WITH '제품군에 대한 권한이 없읍니다'
                        GT_TSPA-SPART.
    ENDIF.
  ENDLOOP.

*-영업그룹
  SELECT VKGRP
    FROM TVBVK
   WHERE VKGRP IN @S_VKGRP
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
