*&---------------------------------------------------------------------*
*& Include          ZGTSDR1040O01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Module STATUS_0100 OUTPUT
*&---------------------------------------------------------------------*
MODULE status_0100 OUTPUT.
  DATA: lt_ucomm  TYPE TABLE OF sy-ucomm.

**
  _clear: lt_ucomm.
  IF gv_disp = 'X'.
    APPEND: 'CREATE'    TO lt_ucomm,    " 매출정산
            'CANCEL'    TO lt_ucomm,    " 정산취소
            'DELETE'    TO lt_ucomm,    " 정산Data 삭제
            'PRICE'     TO lt_ucomm.    " 단가정정
  ELSE.
    APPEND: 'PRIC_DISP' TO lt_ucomm.
  ENDIF.

  SET PF-STATUS '0100' EXCLUDING lt_ucomm.
  SET TITLEBAR  '0100'.

**

ENDMODULE.

*&---------------------------------------------------------------------*
*& Module CREATE_GRID_0100 OUTPUT
*&---------------------------------------------------------------------*
MODULE create_grid_0100 OUTPUT.

**
  PERFORM create_grid   USING  '100'
                               go_docking.
**

ENDMODULE.

*&---------------------------------------------------------------------*
*& Module STATUS_0200 OUTPUT
*&---------------------------------------------------------------------*
MODULE status_0200 OUTPUT.

**
  SET PF-STATUS '0200'.
  SET TITLEBAR  '0200'.
**

ENDMODULE.

*&---------------------------------------------------------------------*
*& Module CREATE_GRID_0200 OUTPUT
*&---------------------------------------------------------------------*
MODULE create_grid_0200 OUTPUT.

**
  PERFORM create_custom_cont   USING  '200'
                                      go_costom.
**

ENDMODULE.
