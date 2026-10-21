*&---------------------------------------------------------------------*
*& Include          ZGTSDR0120I01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  EXIT  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE EXIT INPUT.
  CLEAR : GV_SAVEOK.

  GV_SAVEOK = GV_OKCODE.
  CLEAR GV_OKCODE.

  CASE GV_SAVEOK.
    WHEN 'EXIT' OR 'CANC' OR 'CANL' OR 'BACK'.
      CASE SY-DYNNR.
        WHEN '0100'.
*          PERFORM FREE_OBJECT.

        WHEN '0200'.

      ENDCASE.
**********************************************************************
*프로그램 종료후 락 해제
**********************************************************************
        IF P_LOCK IS INITIAL.
          PERFORM PROG_UNLOCK USING 'ZGTSDR1080'.
        ENDIF.
**********************************************************************

      LEAVE TO SCREEN 0.

  ENDCASE.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0100 INPUT.

  CLEAR : GV_SAVEOK.

  GV_SAVEOK = GV_OKCODE.
  CLEAR GV_OKCODE.

  CASE GV_SAVEOK.

    WHEN 'ESTI'.
      PERFORM VIEW_QUOTE.

    WHEN 'POD_C'.
      PERFORM POD_REVERSE.

    WHEN 'ZEDIT'.
      PERFORM SET_ALV_EDIT_FLD USING SPACE.

    WHEN 'ZDISP'.  "확정
      PERFORM SET_ALV_EDIT_FLD USING 'X'.

    WHEN 'F_ALL'.
      PERFORM SET_SELECT USING 'X'.

    WHEN 'F_SAL'.
      PERFORM SET_SELECT USING ''.

    WHEN  'VF01'.            " 대금청구 온라인

      G_UCOMM  =  GV_SAVEOK.

      CLEAR : G_SUBRC, G_ERR.

*___ 대금청구, 대금청구 온라인 버튼 클릭 시
      PERFORM CHECK_DATA USING G_ERR.

*___ 오류가 없으면 bdc진행
      CHECK G_ERR IS INITIAL AND GV_ERROR IS INITIAL.

      PERFORM  BDC_DATA_CHECK.

      PERFORM  BDC_DATA_MOVE.
      CHECK G_ERR IS INITIAL AND GV_ERROR IS INITIAL.

      IF GV_TYPE = 'X'.

        READ TABLE G_MSG_T  WITH KEY  MSGTYP = 'S'
                                      MSGID  = 'VF'
                                      MSGNR  = '311'.
        IF SY-SUBRC = 0.
          PERFORM UPDATE_VBRK USING G_MSG_T-MSGV1.
        ELSE.

          READ TABLE G_MSG_T  WITH KEY  MSGTYP = 'S'
                                        MSGID  = 'VF'
                                        MSGNR  = '050'.
          IF SY-SUBRC = 0.
            PERFORM UPDATE_VBRK USING G_MSG_T-MSGV1.
          ENDIF.
        ENDIF.

      ENDIF.

      IF G_ERR IS INITIAL.
        MESSAGE I001 WITH TEXT-M03 DISPLAY LIKE 'S'.
        PERFORM QUERY_DATA.
        PERFORM ALVPRN_HEADER2 USING SPACE..   " Header의 금액을 Change하기위함.
        MESSAGE S014.
        PERFORM REFRESH_TABLE_DISPLAY USING GO_GRID SPACE.
      ENDIF.
    WHEN  'VA02'.
      PERFORM CALL_VA02.
      PERFORM QUERY_DATA.
      PERFORM REFRESH_TABLE_DISPLAY USING GO_GRID SPACE.

    WHEN  'REFS'.
      PERFORM SET_ALV_EDIT_FLD USING SPACE.
      PERFORM QUERY_DATA.
      PERFORM ALVPRN_HEADER2 USING SPACE.   " Header의 금액을 Change하기위함.
      PERFORM REFRESH_TABLE_DISPLAY USING GO_GRID SPACE.

    WHEN  'SAMS'.
      PERFORM ALVPRN_HEADER2 USING 'X'.   " Header의 금액을 Change하기위함.

    WHEN  'ZTAX'.           " 부가세조정
      MESSAGE E001 WITH '빌링 후 매출마감처리[ZGTSDR1080]의 상세리스트 이용'.
      PERFORM ZTAX_CALC_RTN.
      PERFORM REFRESH_TABLE_DISPLAY USING GO_GRID SPACE.

    WHEN  'ZAMT'.           " 청구액조정
      PERFORM ZAMT_CALC_RTN.
      PERFORM REFRESH_TABLE_DISPLAY USING GO_GRID SPACE.

  ENDCASE.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0200  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0200 INPUT.
  CLEAR : GV_SAVEOK.

  GV_SAVEOK = GV_OKCODE.
  CLEAR GV_OKCODE.

  CASE GV_SAVEOK.
    WHEN 'CLOSE'.
      PERFORM FREE_OBJ.
      LEAVE TO SCREEN 0.
  ENDCASE.
ENDMODULE.
