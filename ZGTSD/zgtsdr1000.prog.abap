************************************************************************
* 모듈/서브모듈 : SD / 커미션                                          *
* Type          : Report                                               *
* T_CODE        : ZGTSDR1000                                           *
* GAP No        :                                                      *
* Description   : 커미션 미지급 전표 생성                              *
************************************************************************
*                        MODIFICATION LOG                              *
*----------------------------------------------------------------------*
*   DATE        AUTHORS              DESCRIPTION                       *
* ----------   --------- --------------------------------------------- *
* 2024/12/16    양정혁    Initial Release                              *
************************************************************************
* Comment :
************************************************************************
REPORT ZSDR1000  NO STANDARD PAGE HEADING MESSAGE-ID ZGTSD01.

*----------------------------------------------------------------------*
*                       INCLUDE 문                                     *
*----------------------------------------------------------------------*
INCLUDE ZGTSDR1000TOP.
INCLUDE ZGTSDR1000F01.

*----------------------------------------------------------------------*
*                       INITIALIZATION                                 *
*----------------------------------------------------------------------*
INITIALIZATION.

  G_REPID = SY-REPID.
  PERFORM VARIANT_INIT.
  PERFORM INTIALIZATION_DATA.
  PERFORM GET_CODEMST.

*----------------------------------------------------------------------*
*   AT SELECTION-SCREEN ON VALUE-REQUEST                               *
*----------------------------------------------------------------------*
AT SELECTION-SCREEN ON VALUE-REQUEST FOR P_VARI.
  PERFORM F4_FOR_VARIANT.

AT SELECTION-SCREEN.
*     권한 CHECK
  PERFORM AUTHORITY_CHECK.
  PERFORM PAI_OF_SELECTION_SCREEN.

*----------------------------------------------------------------------*
*                    START-OF-SELECTION.                               *
*----------------------------------------------------------------------*
START-OF-SELECTION.

** 권한Check.
*  perform  authority_check.

  PERFORM STATUS USING GT_EXTAB.
  PERFORM INTIALIZATION_DATA.
  PERFORM READ_DATA_PROCESS.
  PERFORM MODIFY_DATA_PROCESS.

END-OF-SELECTION.

*----------------------------------------------------------------------*
*                    ALV - 영역                                        *
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

  CALL FUNCTION 'Z_SD_AUTHORIZATION_CHECK'
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
    CALL FUNCTION 'Z_SD_AUTHORIZATION_CHECK'
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
    CALL FUNCTION 'Z_SD_AUTHORIZATION_CHECK'
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

ENDFORM.                    " authority_check
*
