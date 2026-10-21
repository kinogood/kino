*&---------------------------------------------------------------------*
*&  Include           LZNF2100I01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_2000  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_2000 INPUT.

  CASE GV_FCODE.
    WHEN 'OKAY'.
      LEAVE TO SCREEN 0.
    WHEN 'CANC'.
      LEAVE TO SCREEN 0.
    WHEN 'DWN1'.
      PERFORM FILE_DOWN USING GV_FCODE.
    WHEN 'DWN2'.
      PERFORM FILE_DOWN USING GV_FCODE.
    WHEN 'DWN3'.
      PERFORM FILE_DOWN USING GV_FCODE.
    WHEN 'DWN4'.
      PERFORM FILE_DOWN USING GV_FCODE.
    WHEN 'DWN5'.
      PERFORM FILE_DOWN USING GV_FCODE.
  ENDCASE.

ENDMODULE.                 " USER_COMMAND_2000  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_2000  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_3000 INPUT.

  CASE GV_FCODE.
    WHEN 'OKAY'.
      LEAVE TO SCREEN 0.
    WHEN 'CANC'.
      LEAVE TO SCREEN 0.
    WHEN 'DWN6'.
      PERFORM FILE_DOWN USING GV_FCODE.
    WHEN 'DWN7'.
      PERFORM FILE_DOWN USING GV_FCODE.
    WHEN 'DWN8'.
      PERFORM FILE_DOWN USING GV_FCODE.
    WHEN 'DWN9'.
      PERFORM FILE_DOWN USING GV_FCODE.
    WHEN 'DWN10'.
      PERFORM FILE_DOWN USING GV_FCODE.
  ENDCASE.

ENDMODULE.                 " USER_COMMAND_3000  INPUT
*&---------------------------------------------------------------------*
*&      Module  F4_LINK1  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE F4_LINK1 INPUT.

  CLEAR: LV_RC, LV_FNAME,
         LT_FILE, LT_FILE[].

* 업로드할 파일의 PATH 지정하기.
  CALL METHOD CL_GUI_FRONTEND_SERVICES=>FILE_OPEN_DIALOG
    EXPORTING
      WINDOW_TITLE      = '업로드할 파일을 선택하세요'
      DEFAULT_FILENAME  = '*.*'
      INITIAL_DIRECTORY = 'C:\'
    CHANGING
      FILE_TABLE        = LT_FILE
      RC                = LV_RC.

  READ TABLE LT_FILE INDEX 1 INTO LV_FNAME.

  IF LV_FNAME IS INITIAL.
    MESSAGE S001 WITH '작업을 취소하셨습니다.'.
  ELSE.
    MOVE LV_FNAME TO GS_ZNFT1002-LINK1.
  ENDIF.

ENDMODULE.                 " F4_LINK1  INPUT

*&---------------------------------------------------------------------*
*&      Module  F4_LINK2  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE F4_LINK2 INPUT.

  CLEAR: LV_RC, LV_FNAME,
         LT_FILE, LT_FILE[].

* 업로드할 파일의 PATH 지정하기.
  CALL METHOD CL_GUI_FRONTEND_SERVICES=>FILE_OPEN_DIALOG
    EXPORTING
      WINDOW_TITLE      = '업로드할 파일을 선택하세요'
      DEFAULT_FILENAME  = '*.*'
      INITIAL_DIRECTORY = 'C:\'
    CHANGING
      FILE_TABLE        = LT_FILE
      RC                = LV_RC.

  READ TABLE LT_FILE INDEX 1 INTO LV_FNAME.

  IF LV_FNAME IS INITIAL.
    MESSAGE S001 WITH '작업을 취소하셨습니다.'.
  ELSE.
    MOVE LV_FNAME TO GS_ZNFT1002-LINK2.
  ENDIF.


ENDMODULE.                 " F4_LINK2  INPUT

*&---------------------------------------------------------------------*
*&      Module  F4_LINK3  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE F4_LINK3 INPUT.

  CLEAR: LV_RC, LV_FNAME,
         LT_FILE, LT_FILE[].

* 업로드할 파일의 PATH 지정하기.
  CALL METHOD CL_GUI_FRONTEND_SERVICES=>FILE_OPEN_DIALOG
    EXPORTING
      WINDOW_TITLE      = '업로드할 파일을 선택하세요'
      DEFAULT_FILENAME  = '*.*'
      INITIAL_DIRECTORY = 'C:\'
    CHANGING
      FILE_TABLE        = LT_FILE
      RC                = LV_RC.

  READ TABLE LT_FILE INDEX 1 INTO LV_FNAME.

  IF LV_FNAME IS INITIAL.
    MESSAGE S001 WITH '작업을 취소하셨습니다.'.
  ELSE.
    MOVE LV_FNAME TO GS_ZNFT1002-LINK3.
  ENDIF.

ENDMODULE.                 " F4_LINK3  INPUT

*&---------------------------------------------------------------------*
*&      Module  F4_LINK4  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE F4_LINK4 INPUT.

  CLEAR: LV_RC, LV_FNAME,
         LT_FILE, LT_FILE[].

* 업로드할 파일의 PATH 지정하기.
  CALL METHOD CL_GUI_FRONTEND_SERVICES=>FILE_OPEN_DIALOG
    EXPORTING
      WINDOW_TITLE      = '업로드할 파일을 선택하세요'
      DEFAULT_FILENAME  = '*.*'
      INITIAL_DIRECTORY = 'C:\'
    CHANGING
      FILE_TABLE        = LT_FILE
      RC                = LV_RC.

  READ TABLE LT_FILE INDEX 1 INTO LV_FNAME.

  IF LV_FNAME IS INITIAL.
    MESSAGE S001 WITH '작업을 취소하셨습니다.'.
  ELSE.
    MOVE LV_FNAME TO GS_ZNFT1002-LINK4.
  ENDIF.

ENDMODULE.                 " F4_LINK4  INPUT

*&---------------------------------------------------------------------*
*&      Module  F4_LINK5  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE F4_LINK5 INPUT.

  CLEAR: LV_RC, LV_FNAME,
         LT_FILE, LT_FILE[].

* 업로드할 파일의 PATH 지정하기.
  CALL METHOD CL_GUI_FRONTEND_SERVICES=>FILE_OPEN_DIALOG
    EXPORTING
      WINDOW_TITLE      = '업로드할 파일을 선택하세요'
      DEFAULT_FILENAME  = '*.*'
      INITIAL_DIRECTORY = 'C:\'
    CHANGING
      FILE_TABLE        = LT_FILE
      RC                = LV_RC.

  READ TABLE LT_FILE INDEX 1 INTO LV_FNAME.

  IF LV_FNAME IS INITIAL.
    MESSAGE S001 WITH '작업을 취소하셨습니다.'.
  ELSE.
    MOVE LV_FNAME TO GS_ZNFT1002-LINK5.
  ENDIF.

ENDMODULE.                 " F4_LINK5  INPUT
*&---------------------------------------------------------------------*
*&      Module  CHECK_LINK1_CHANGE  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CHECK_LINK1_CHANGE INPUT.

  GV_FLAG1 = 'X'.

ENDMODULE.                 " CHECK_LINK1_CHANGE  INPUT
*&---------------------------------------------------------------------*
*&      Module  CHECK_LINK2_CHANGE  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CHECK_LINK2_CHANGE INPUT.

  GV_FLAG2 = 'X'.

ENDMODULE.                 " CHECK_LINK2_CHANGE  INPUT
*&---------------------------------------------------------------------*
*&      Module  CHECK_LINK3_CHANGE  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CHECK_LINK3_CHANGE INPUT.

  GV_FLAG3 = 'X'.

ENDMODULE.                 " CHECK_LINK3_CHANGE  INPUT
*&---------------------------------------------------------------------*
*&      Module  CHECK_LINK4_CHANGE  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CHECK_LINK4_CHANGE INPUT.

  GV_FLAG4 = 'X'.

ENDMODULE.                 " CHECK_LINK4_CHANGE  INPUT
*&---------------------------------------------------------------------*
*&      Module  CHECK_LINK5_CHANGE  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CHECK_LINK5_CHANGE INPUT.

  GV_FLAG5 = 'X'.

ENDMODULE.                 " CHECK_LINK5_CHANGE  INPUT

*&---------------------------------------------------------------------*
*&      Module  CHECK_LINK1_CHANGE  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CHECK_LINK6_CHANGE INPUT.

  GV_FLAG6 = 'X'.

ENDMODULE.                 " CHECK_LINK1_CHANGE  INPUT
*&---------------------------------------------------------------------*
*&      Module  CHECK_LINK2_CHANGE  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CHECK_LINK7_CHANGE INPUT.

  GV_FLAG7 = 'X'.

ENDMODULE.                 " CHECK_LINK2_CHANGE  INPUT
*&---------------------------------------------------------------------*
*&      Module  CHECK_LINK3_CHANGE  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CHECK_LINK8_CHANGE INPUT.

  GV_FLAG8 = 'X'.

ENDMODULE.                 " CHECK_LINK3_CHANGE  INPUT
*&---------------------------------------------------------------------*
*&      Module  CHECK_LINK4_CHANGE  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CHECK_LINK9_CHANGE INPUT.

  GV_FLAG9 = 'X'.

ENDMODULE.                 " CHECK_LINK4_CHANGE  INPUT
*&---------------------------------------------------------------------*
*&      Module  CHECK_LINK5_CHANGE  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CHECK_LINK10_CHANGE INPUT.

  GV_FLAG10 = 'X'.

ENDMODULE.                 " CHECK_LINK5_CHANGE  INPUT
