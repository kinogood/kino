*&---------------------------------------------------------------------*
*&  Include           ZMMR1360_I01
*&---------------------------------------------------------------------**&---------------------------------------------------------------------*
*&      Module  EXIT  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE EXIT INPUT.

  CASE SY-UCOMM.
    WHEN 'BACK' OR 'CANC'.
      LEAVE TO SCREEN 0.
    WHEN 'EXIT'.
      LEAVE PROGRAM.
  ENDCASE.

ENDMODULE.                    "EXIT INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0100 INPUT.

  DATA : LT_BLH LIKE TABLE OF ZTITBLH WITH HEADER LINE.

  IF OK_CODE EQ 'SAVE'.

    CLEAR : LT_BLH, LT_BLH, GV_CHK .

    PERFORM GRID_CHECK_CHANGED_DATA USING GS_ALV_GRID."ALV최신화
      LOOP AT GT_LIST.
        CLEAR LT_BLH.
        MOVE-CORRESPONDING GT_LIST TO LT_BLH.

        LT_BLH-BPKTY = 'GT'.
        LT_BLH-GEWEI = 'KG'.
        LT_BLH-VOLEH = 'M3'.
        LT_BLH-BLAYN = 'D'.

        IF GT_LIST-LIFNR IS INITIAL.
          MESSAGE S001 WITH '업체코드는 필수 입력입니다. '.
          GV_CHK = C_X.
        ELSE.
          SELECT SINGLE * FROM LFA1 WHERE LIFNR EQ GT_LIST-LIFNR.
          IF SY-SUBRC NE 0.
            MESSAGE S002 WITH GT_LIST-LIFNR
                               '는 존재하지 않는 업체코드입니다.'.
            GV_CHK = C_X.
          ENDIF.
        ENDIF.


        IF GT_LIST-FWDCD  IS INITIAL.
          MESSAGE S001 WITH '포워더는 필수 입력입니다. '.
          GV_CHK = C_X.
        ELSE.
          SELECT SINGLE * FROM LFA1 WHERE LIFNR EQ GT_LIST-FWDCD .
          IF SY-SUBRC NE 0.
            MESSAGE S002 WITH GT_LIST-FWDCD
                               '는 존재하지 않는 포워더입니다.'.
            GV_CHK = C_X.
          ENDIF.
        ENDIF.


        IF GT_LIST-BLNUM IS INITIAL.
          MESSAGE S001 WITH 'B/L 번호는 필수 입력입니다. '.
          GV_CHK = C_X.
        ENDIF.

        APPEND LT_BLH.
      ENDLOOP.

       CHECK GV_CHK IS INITIAL.

    PERFORM CHECK_MESSAGE USING 'SAVE'.
    IF GV_ANSWER EQ '1'.
      CALL FUNCTION 'ZMM_SET_CBO_DATE_SINGLE'
        TABLES
          PT_DATA = LT_BLH[].

      MODIFY ZTITBLH FROM TABLE LT_BLH[].
      IF SY-SUBRC EQ 0.
        MESSAGE S001 WITH '정상 저장되었습니다. '.
        LEAVE TO SCREEN 0.
      ENDIF.
    ENDIF.
  ENDIF.


ENDMODULE.                 " USER_COMMAND_0100  INPUT
