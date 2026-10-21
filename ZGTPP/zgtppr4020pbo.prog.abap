*----------------------------------------------------------------------*
***INCLUDE ZGTPPR4020_PBO .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE STATUS_0100 OUTPUT.

  CASE GV_STATUS.
    WHEN 'A'.
      SET PF-STATUS 'STATUS100' EXCLUDING FCODE_B.
    WHEN 'B'.
      SET PF-STATUS 'STATUS100' EXCLUDING FCODE_A.
    WHEN 'C'.
      SET PF-STATUS 'STATUS100' EXCLUDING FCODE_C.
  ENDCASE.

  SET TITLEBAR    'TITLE100'.

ENDMODULE.                 " STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  INIT_CONTROLS  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE INIT_CONTROLS OUTPUT.
  PERFORM DISPLAY_ALV.
ENDMODULE.                 " INIT_CONTROLS  OUTPUT
