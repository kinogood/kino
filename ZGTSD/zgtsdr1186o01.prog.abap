*&---------------------------------------------------------------------*
*& Include          ZGTSDR1186O01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Module STATUS_0100 OUTPUT
*&---------------------------------------------------------------------*
MODULE status_0100 OUTPUT.

**
  SET PF-STATUS 'PF200'.
  SET TITLEBAR 'T10'.

  IF G_DOCKING_CON IS INITIAL.

    PERFORM CREATE_OBJECT.

    PERFORM SET_LAYOUT .

    PERFORM CREATE_FIELDCATALOG.


    CALL METHOD G_GRID_HEAD->SET_TABLE_FOR_FIRST_DISPLAY
      EXPORTING
        I_SAVE               = 'A'
        IS_LAYOUT            = GS_LAYH
        IT_TOOLBAR_EXCLUDING = GT_EXCLUDE
        I_DEFAULT            = 'X'             " 레이아웃 사전셋팅 허용.
*       is_variant           = gs_variant
      CHANGING
        IT_OUTTAB            = GT_HEAD[]
        IT_FIELDCATALOG      = GT_FIELDH[]
        IT_SORT              = GT_SORTH[].


    PERFORM CREATE_EVENT_RECEIVER.


    CALL METHOD G_GRID_ITEM->SET_TABLE_FOR_FIRST_DISPLAY
      EXPORTING
        I_SAVE               = 'A'
        IS_LAYOUT            = GS_LAYI
        IT_TOOLBAR_EXCLUDING = GT_EXCLUDE
        I_DEFAULT            = 'X'             " 레이아웃 사전셋팅 허용.
*       is_variant           = gs_variant
      CHANGING
        IT_OUTTAB            = GT_SELT[]
        IT_FIELDCATALOG      = GT_FIELDI[]
        IT_SORT              = GT_SORTI[].
  ENDIF.

**

ENDMODULE.
