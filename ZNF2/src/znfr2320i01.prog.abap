*----------------------------------------------------------------------*
***INCLUDE ZNFR2320I01 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  EXIT  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE EXIT INPUT.

  CASE OK_CODE.
    WHEN 'BACK' OR 'EXIT' OR 'CANC'.
      CLEAR : OK_CODE.

      LEAVE TO SCREEN 0.

  ENDCASE.

ENDMODULE.                 " EXIT  INPUT
*&---------------------------------------------------------------------*
*&      Module  SAVE_OK_CODE  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE SAVE_OK_CODE INPUT.

  OK_SAVE = OK_CODE.

  CLEAR : OK_CODE.

ENDMODULE.                 " SAVE_OK_CODE  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0100 INPUT.

  PERFORM GET_SELECTED_ROWS.

  CASE OK_SAVE.
    WHEN 'SAVE'.    "저장
      PERFORM SAVE_SHIFT_APPROVAL USING ' '.

    WHEN 'REQT'.    "결재요청
      PERFORM SAVE_SHIFT_APPROVAL USING 'X'.

    WHEN 'REJT'.    "반려
      PERFORM REJECT_SHIFT_APPROVAL.

    WHEN 'RFSH'.    "Refresh
      PERFORM DEQUEUE_ZNFT1040.

      PERFORM GET_SHIFT_REQ_DATA.

    WHEN 'ASEL' OR 'DSEL'.
      PERFORM SELECT_ALL.

    WHEN 'CONT'.  "사번/비밀번호 입력 시
      PERFORM CHECK_PASSWORD.

    WHEN 'BACK' OR 'EXIT' OR 'CANC'.
      LEAVE TO SCREEN 0.

  ENDCASE.

ENDMODULE.                 " USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*&      Module  CHECK_PERNR  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CHECK_PERNR INPUT.

  PERFORM GET_PERNR_DESC USING GV_PERNR
                               GV_ENAME.

  IF GV_ENAME IS NOT INITIAL.
*___공용 SAP ID에 해당하는 사원번호인지 점검
    READ TABLE GT_PERNR WITH KEY PERNR = GV_PERNR.
    IF SY-SUBRC <> 0.
      MESSAGE E003
         WITH '사원번호가 공용 SAP ID에 지정되어 있지 않습니다.'
              '사원번호-SAP ID:'
              GV_PERNR SY-UNAME.
    ENDIF.
  ELSE.
    MESSAGE E003 WITH '사원번호' GV_PERNR
                      '이(가) 존재하지 않습니다.'.
  ENDIF.

ENDMODULE.                 " CHECK_PERNR  INPUT
