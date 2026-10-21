*&---------------------------------------------------------------------*
*& Include          ZGTSDR1200I01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  EXIT_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE EXIT_0100 INPUT.
  SAVE_OK = OK_CODE.
  CLEAR OK_CODE.

  CASE SAVE_OK.
    WHEN 'BACK' OR 'CANC' OR 'EXIT'.
      PERFORM INIT_CONTROLS_0100.
      LEAVE TO SCREEN 0.


    WHEN OTHERS.
  ENDCASE.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0100 INPUT.
  SAVE_OK = OK_CODE.
  CLEAR OK_CODE.

  CASE SAVE_OK.
    WHEN 'ZF10'. "유효담보마감일(당월)
      PERFORM GET_FILTER_PERIOD_MONTH USING GC_A.

    WHEN 'ZF20'. "유효담보마감일(익월)
      PERFORM GET_FILTER_PERIOD_MONTH USING GC_B.

    WHEN 'ZF30'. "유효담보마감일(~익월)
      PERFORM GET_FILTER_PERIOD_MONTH USING GC_C.

    WHEN 'ZF40'. "ALL
      PERFORM GET_FILTER_PERIOD_MONTH USING GC_D.

    WHEN OTHERS.
  ENDCASE.
ENDMODULE.
