*&---------------------------------------------------------------------*
*& Include          ZGTMMR3000I01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  EXIT_0100  INPUT
*&---------------------------------------------------------------------*
*       TEXT
*----------------------------------------------------------------------*
MODULE EXIT_0100 INPUT.

  GV_OKCODE_SAVE = GV_OKCODE.
  CLEAR GV_OKCODE.

  CASE GV_OKCODE_SAVE.

    WHEN 'BACK' OR 'CANC'.
       PERFORM RELEASE_ALV.
       LEAVE TO SCREEN 0.

    WHEN 'EXIT'.
      IF SY-DYNNR = '0200'.
         LEAVE TO SCREEN 0.
      ELSE.
        PERFORM RELEASE_ALV.
        LEAVE PROGRAM.
      ENDIF.

  ENDCASE.

ENDMODULE.

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0100 INPUT.

  CLEAR : GV_OKCODE_SAVE, GV_ERR.

  GV_OKCODE_SAVE = GV_OKCODE.
  CLEAR GV_OKCODE.

  CASE GV_OKCODE_SAVE.
    WHEN 'REFRESH'.
      PERFORM GET_DATA.

    WHEN 'SCRAP'.
      PERFORM EXCUTE_SCRAP USING ''.

    WHEN 'SCR_CANC'.
      PERFORM EXCUTE_SCRAP USING 'C'.

    WHEN OTHERS.
  ENDCASE.

ENDMODULE.

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0200  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0200 INPUT.

  CLEAR : GV_OKCODE_SAVE2 , GV_ERR.

  GV_OKCODE_SAVE2 = GV_OKCODE.
  CLEAR GV_OKCODE.

  CASE GV_OKCODE_SAVE2.

    WHEN 'YES'.
      CASE GV_OKCODE_SAVE.
*  "폐기처리
        WHEN 'SCRAP'.
          IF GV_BUDAT IS INITIAL.
             MESSAGE S000 WITH TEXT-E03 DISPLAY LIKE 'E'.
           "전기일을 입력하세요.
          ELSE.
            PERFORM SET_BAPI_DATA.
            PERFORM SET_CELL_STYLE.
          ENDIF.

* "폐기취소
        WHEN 'SCR_CANC'.
           PERFORM SET_CANC_BAPI_DATA.
           PERFORM SET_CELL_STYLE.

        WHEN OTHERS.
      ENDCASE.

      PERFORM REFRESH_TABLE USING GCL_GRID SPACE.
      LEAVE TO SCREEN 0.

    WHEN 'NO'.
      LEAVE TO SCREEN 0.

    WHEN OTHERS.
  ENDCASE.

ENDMODULE.
