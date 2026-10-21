*&---------------------------------------------------------------------*
*& INCLUDE          ZGTMMR3010O01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& MODULE SET_STATUS_0100 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE SET_STATUS_0100 OUTPUT.

  CLEAR GT_EX.

  IF P_PO = GC_X.
    GT_EX = VALUE #( ( 'LABEL' )
                                 ( 'DELCLOSE' ) ).
  ENDIF.

  IF P_LNO = GC_X.
    GT_EX = VALUE #( ( 'LABEL' )
                                 ( 'DELCLOSE' )
                                 ( 'DELV_FIN' )
                                 ( 'FIN_CANC' ) ).
  ENDIF.

  IF P_DIS = GC_X.
    GT_EX = VALUE #( ( 'GR' )
                                 ( 'GR_CANC' )
                                 ( 'GRCANC' )
                                 ( 'LABEL' )
                                 ( 'DELCLOSE' )
                                 ( 'DELV_FIN' )
                                 ( 'FIN_CANC' ) ).
  ENDIF.

  SET PF-STATUS '0100' EXCLUDING GT_EX.
  SET TITLEBAR '0100' .

ENDMODULE.
*&---------------------------------------------------------------------*
*& MODULE SET_ALV_GRID_0100 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE SET_ALV_GRID_0100 OUTPUT.

  IF GCL_GRID IS NOT BOUND.
    PERFORM CREATE_ALV.

  ELSE.
    PERFORM REFRESH_TABLE USING GCL_GRID SPACE.

  ENDIF.

ENDMODULE.

*&---------------------------------------------------------------------*
*& MODULE MODIFY_SCREEN OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE MODIFY_SCREEN OUTPUT.

*  LOOP AT SCREEN.
*
*    MODIFY SCREEN.
*  ENDLOOP.

ENDMODULE.
*&---------------------------------------------------------------------*
*& Module STATUS_0200 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_0200 OUTPUT.

  SET PF-STATUS '0200' .
  SET TITLEBAR '0200' .

ENDMODULE.

*&---------------------------------------------------------------------*
*& Module STATUS_0300 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_0300 OUTPUT.

  SET PF-STATUS '0200' .
  SET TITLEBAR '0300' .

ENDMODULE.

*&---------------------------------------------------------------------*
*& MODULE SET_ALV_GRID_0300 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE SET_ALV_GRID_0300 OUTPUT.

  IF GCL_GRID_300 IS NOT BOUND.
    PERFORM CREATE_ALV_300.

  ELSE.
    PERFORM REFRESH_TABLE USING GCL_GRID_300 SPACE.

  ENDIF.

ENDMODULE.
*&---------------------------------------------------------------------*
*& Module SET_SCREEN OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE SET_SCREEN OUTPUT.

    LOOP AT SCREEN.

      IF SCREEN-NAME = 'GV_BUDAT'.
         IF GV_OKCODE_SAVE = 'GR_CANC'.
             SCREEN-INPUT = 0.  "비활성(입력불가)
         ELSE.
             SCREEN-INPUT = 1.  "활성(입력가능)
         ENDIF.
         MODIFY SCREEN.
      ENDIF.

    ENDLOOP.

ENDMODULE.
