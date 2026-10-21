*&---------------------------------------------------------------------*
*& Include          ZGTSDR1140I01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_3000  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_3000 INPUT.

  G_SYUCOMM =  SY-UCOMM.

  CASE  SY-UCOMM.

    WHEN  'ENTE'.
      LEAVE TO SCREEN 0.

    WHEN  'CANC'.
      G_H_EMPFK  =  SPACE.
      LEAVE TO SCREEN 0.

  ENDCASE.

ENDMODULE.                 " USER_COMMAND_3000  INPUT

*&---------------------------------------------------------------------*
*&      Module  f4_empfk  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE F4_EMPFK INPUT.

  PERFORM  F4_EMPFK_RTN.

ENDMODULE.                 " f4_empfk  INPUT
*&---------------------------------------------------------------------*
*&      Module  data_check  INPUT
*&---------------------------------------------------------------------*
MODULE DATA_CHECK INPUT.

  CHECK NOT G_H_EMPFK IS INITIAL.

  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      INPUT  = G_H_EMPFK
    IMPORTING
      OUTPUT = G_H_EMPFK.

  READ TABLE G_LFZA_T WITH KEY EMPFK  =  G_H_EMPFK.

  IF  SY-SUBRC  NE  0.
    MESSAGE E001 WITH '입력한 코드를 확인하세요.'.
  ENDIF.

  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
    EXPORTING
      INPUT  = G_H_EMPFK
    IMPORTING
      OUTPUT = G_H_EMPFK.

ENDMODULE.                 " data_check  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_5000  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_5000 INPUT.

  G_SYUCOMM =  SY-UCOMM.

  CASE  SY-UCOMM.

    WHEN  'ENTE'.
      PERFORM SET_ZSD0016T_DATA USING 1.
      LEAVE TO SCREEN 0.

    WHEN  'CANC'.
      LEAVE TO SCREEN 0.

  ENDCASE.

ENDMODULE.                 " USER_COMMAND_5000  INPUT
