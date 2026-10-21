*&---------------------------------------------------------------------*
*&  Include           ZNFR2670I01
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Module  EXIT  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE EXIT INPUT.

  CLEAR : GV_CODE.
  GV_CODE = OK_CODE.
  CLEAR : OK_CODE.

  CASE SY-UCOMM.
    WHEN 'EXIT'.
      LEAVE PROGRAM.
    WHEN 'BACK' OR 'CANC'.
      LEAVE TO SCREEN 0.
  ENDCASE.

ENDMODULE.                 " EXIT  INPUT

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_1100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_1100 INPUT.

  CLEAR : GV_CODE.
  GV_CODE = OK_CODE.
  CLEAR : OK_CODE.

  CALL METHOD GRF_GRID_T->CHECK_CHANGED_DATA.

  CASE GV_CODE.
    WHEN 'SIMUL'.
      PERFORM GET_FCM_CREDIT.
    WHEN 'FCM'.
      PERFORM GET_FCM_CREDTI_DATA.
      CALL SCREEN 1200 STARTING AT 10 03
                       ENDING   AT 90 28.
    WHEN 'CASE'.
      CLEAR GV_ANSWER.
      PERFORM POPUP_TO_CONFIRM USING '확인'
                                     '저장하시겠습니까?'
                                     '1'
                                     GV_ANSWER.
      CHECK GV_ANSWER EQ 1.
      PERFORM DATA_SAVE_NFKEY.

    WHEN 'DOWN'.
      PERFORM DATA_DOWNLOAD.

  ENDCASE.

ENDMODULE.                 " USER_COMMAND_1100  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_1200  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_1200 INPUT.

  CLEAR : GV_CODE.
  GV_CODE = OK_CODE.
  CLEAR : OK_CODE.

  CASE GV_CODE.
    WHEN 'SAVE'.
      PERFORM DATA_CHECK_FCM USING GV_ERROR.
      CLEAR GV_ANSWER.
      PERFORM POPUP_TO_CONFIRM USING '확인'
                                     '저장하시겠습니까?'
                                     '1'
                                     GV_ANSWER.
      CHECK GV_ANSWER EQ 1.
      PERFORM DATA_SAVE.
      PERFORM DATA_RELOAD.
    WHEN 'CANC'.
      LEAVE TO SCREEN 0.
  ENDCASE.

ENDMODULE.                 " USER_COMMAND_1200  INPUT
*&---------------------------------------------------------------------*
*&      Module  CHECK_BUKRS  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CHECK_BUKRS INPUT.

* 회사코드 기본값
  PERFORM GET_DEFAULT_COMPANY_DATA USING GV_BUKRS
                                         GV_WAERS
                                         GV_LAND1
                                         GV_BUTXT
                                         GV_KTOPL
                                         GV_KOKRS.
  IF GV_BUTXT IS INITIAL.
    MESSAGE E001 WITH '회사코드가 존재하지 않습니다.'.
  ENDIF.

  PERFORM CHECK_AUTHORIZATION USING GV_BUKRS
                                    GV_ERROR.

  IF GV_ERROR IS NOT INITIAL.
    MESSAGE E001 WITH '회사코드' GV_BUKRS
                      '에 대한 권한을 점검하시기 바랍니다.'.
  ENDIF.

ENDMODULE.                 " CHECK_BUKRS  INPUT

*&---------------------------------------------------------------------*
*&      Module  CHECK_DATE  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CHECK_DATE INPUT.

  IF GV_TODAT IS NOT INITIAL AND GV_FRDAT > GV_TODAT.
    MESSAGE E001 WITH '일자를 점검하시기 바랍니다.'.
  ELSE.
    PERFORM SET_ENDAT_RANGES.
  ENDIF.

ENDMODULE.                 " CHECK_DATE  INPUT
