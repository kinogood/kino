*----------------------------------------------------------------------*
***INCLUDE LZ_TI_COMMON_FUNCTIONSO02 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  pbo_object_create_scr7000  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE PBO_OBJECT_CREATE_SCR7000 OUTPUT.

  SET PF-STATUS '7000'.
  SET TITLEBAR 'T7000'.

  IF G_INIT IS INITIAL.
    G_REPID = SY-REPID.
    G_DYNNR = SY-DYNNR.
* create the docking container
    CREATE OBJECT G_DOCKING
      EXPORTING
        REPID     = G_REPID
        DYNNR     = G_DYNNR
        SIDE      = G_DOCKING->DOCK_AT_LEFT
        EXTENSION = 220.
* The Tree Control has not been created yet.
* Create a Tree Control and insert nodes into it.
    PERFORM TREE_CREATE_AND_INIT USING G_SUBRC.
    IF SY-SUBRC <> 0.
      MESSAGE S000(TREE_CONTROL_MSG).                       "#EC NOTEXT
    ENDIF.
*> Tree Chosen
    PERFORM SET_TREE_CHOSEN_ITEM.

    G_INIT = 'X'.

  ENDIF.

ENDMODULE.                 " pbo_object_create_scr7000  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  change_field_visible_scr7000  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CHANGE_FIELD_VISIBLE_SCR7000 OUTPUT.

  LOOP AT SCREEN.
    IF SCREEN-NAME EQ 'ZTITCSK-KURSF' OR
       SCREEN-NAME EQ 'ZTITCSK-WWERT' OR
       SCREEN-NAME EQ 'ZTITCSK-DMBTR' OR
       SCREEN-NAME EQ 'ZTITCSK-HWAER'.
      IF ZTITCSK-WAERS EQ ZTITCSK-HWAER.
        SCREEN-INPUT     = C_CHAR0.
        SCREEN-INVISIBLE = C_CHAR1.
      ELSE.
*        IF g_mode EQ c_charc OR
*           g_mode EQ c_charm.
        IF SCREEN-NAME EQ 'ZTITCSK-KURSF' OR
           SCREEN-NAME EQ 'ZTITCSK-WWERT'.
          SCREEN-INPUT     = C_CHAR1.
        ELSE.
          SCREEN-INPUT     = C_CHAR0.
        ENDIF.
*        ELSE.
*          screen-input     = c_char0.
*        ENDIF.
*        screen-invisible = c_char0.
      ENDIF.
    ENDIF.
*> 사업장.
    IF ZTITIG00-CHKBP IS INITIAL AND
       SCREEN-NAME EQ 'ZTITCSK-BUPLA'.
      SCREEN-INPUT     = C_CHAR0.
      SCREEN-INVISIBLE = C_CHAR1.
    ENDIF.
*> 사업영역.
    IF ZTITIG00-CHKBA IS INITIAL AND
       SCREEN-NAME EQ 'ZTITCSK-GSBER'.
      SCREEN-INPUT     = C_CHAR0.
      SCREEN-INVISIBLE = C_CHAR1.
    ENDIF.
**> 지급조건변경 가능일 경우.
*    IF ztstiga-termx NE 'Y' AND
*       screen-name   EQ 'ZTITCSK-ZTERM'.
*      screen-input     = c_char0.
*    ENDIF.

**> 지급보류 변경 가능일 경우.
*    IF ztstiga-zlspx NE 'Y' AND
    IF SCREEN-NAME   EQ 'ZTITCSK-ZLSPR' .
      SCREEN-INPUT     = C_CHAR0.
    ENDIF.
**> 지급방법 변경 가능일 경우.
*    IF ztstiga-zlscx NE 'Y' AND
    IF SCREEN-NAME   EQ 'ZTITCSK-ZLSCH' .
      SCREEN-INPUT     = C_CHAR0.
    ENDIF.
**> 지급방법보충 변경 가능일 경우.
*    IF ztstiga-uzawx NE 'Y' AND
*       screen-name   EQ 'ZTITCSK-UZAWE' .
*      screen-input     = c_char0.
*    ENDIF.
**> 기준일 변경 가능일 경우.
*    IF ztstiga-fbdtx NE 'Y' AND
*       screen-name   EQ 'ZTITCSK-ZFBDT' .
*      screen-input     = c_char0.
*    ENDIF.
**> 기준일.
*    IF ztstiga-datmx EQ space.
*      CASE screen-name.
*        WHEN 'ZTITCSK-ZBD1T' OR 'ZTITCSK-ZBD2T' OR
*             'ZTITCSK-ZBD3T' OR 'ZTITCSK-ZBD1P' OR
*             'ZTITCSK-ZBD2P'.
*          screen-input     = c_char0.
*        WHEN OTHERS.
*      ENDCASE.
*    ENDIF.
*
**> 헤더텍스트.
*    IF ztitig07-dtrfd EQ '*' AND
*       screen-name EQ 'ZTITCSK-BKTXT'.
*      screen-input     = c_char0.
*      screen-invisible = c_char1.
*    ENDIF.
**> 헤더 참조.
*    IF ztitig07-dtrfh EQ '*' AND
*       screen-name EQ 'ZTITCSK-XBLNR'.
*      screen-input     = c_char0.
*      screen-invisible = c_char1.
*    ENDIF.
*
**> 대변 텍스트 .
*    IF ZTITIG07-DTRFIC EQ '*' AND
*       screen-name EQ 'ZTITCSK-SGTXT'.
*      screen-input     = c_char0.
*      screen-invisible = c_char1.
*    ENDIF.
**> 대변 지정.
*    IF ztitig07-dtrfaC EQ '*' AND
*       screen-name EQ 'ZTITCSK-ZUONR'.
**       BREAK-POINT.
*
*      screen-input     = c_char0.
*      screen-invisible = c_char1.
*    ENDIF.
**> 대변 참조키1
*    IF ztitig07-dtrf1c EQ '*' AND
*       screen-name EQ 'ZTITCSK-XREF1'.
*      screen-input     = c_char0.
*      screen-invisible = c_char1.
*    ENDIF.
**> 대변 참조키2
*    IF ztitig07-dtrf2c EQ '*' AND
*       screen-name EQ 'ZTITCSK-XREF2'.
*      screen-input     = c_char0.
*      screen-invisible = c_char1.
*    ENDIF.
**> 대변 참조키3
*    IF ztitig07-dtrf3c EQ '*' AND
*       screen-name EQ 'ZTITCSK-XREF3'.
*      screen-input     = c_char0.
*      screen-invisible = c_char1.
*    ENDIF.

*    IF ztitcsk-livst NE c_charn.
*      screen-input     = c_char0.
*    ENDIF.
*>
*    IF SCREEN-NAME EQ 'ZTITCSK-MWSKZ'.
*      IF ZTITCSK-EXPGR EQ C_CHARL OR
*         ZTITCSK-EXPGR EQ C_CHARI.
*        screen-input     = c_char0.
*      ENDIF.
*    ENDIF.

     IF ZTITCSK-BUKRS EQ '3000' AND SCREEN-GROUP3 EQ 'X' AND
        SY-TCODE EQ 'ZTIR913N'.
        IF SCREEN-NAME NE 'ZTITCSK-GSBER' AND
           SCREEN-NAME NE 'ZTITCSK-BUPLA' .

           SCREEN-INPUT     = C_CHAR0.
           SCREEN-INVISIBLE = C_CHAR1.
        ENDIF.
     ENDIF.

      MODIFY SCREEN.
    ENDLOOP.

  ENDMODULE.                 " change_field_visible_scr7000  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  tc_7000_init  OUTPUT
*&---------------------------------------------------------------------*
*> output module for tc 'TC_7000'. do not change this line!
*> copy ddic-table to itab
*----------------------------------------------------------------------*
MODULE TC_7000_INIT OUTPUT.
  IF G_TC_7000_COPIED IS INITIAL.
*> copy ddic-table 'ZTITCSP'
*> into internal table 'g_TC_7000_itab'
    G_TC_7000_COPIED = 'X'.
    REFRESH CONTROL 'TC_7000' FROM SCREEN '7000'.
  ENDIF.
ENDMODULE.                    "TC_7000_init OUTPUT

*&---------------------------------------------------------------------*
*&      Module  tc_7000_move  OUTPUT
*&---------------------------------------------------------------------*
*> output module for tc 'TC_7000'. do not change this line!
*> move itab to dynpro
*----------------------------------------------------------------------*
MODULE TC_7000_MOVE OUTPUT.

  MOVE-CORRESPONDING XZTITCSP TO ZTISCSIT.

ENDMODULE.                    "TC_7000_move OUTPUT

*&---------------------------------------------------------------------*
*&      Module  tc_7000_get_lines  OUTPUT
*&---------------------------------------------------------------------*
*> output module for tc 'TC_7000'. do not change this line!
*> get lines of tablecontrol
*----------------------------------------------------------------------*
MODULE TC_7000_GET_LINES OUTPUT.
  G_TC_7000_LINES = SY-LOOPC.
ENDMODULE.                    "TC_7000_get_lines OUTPUT
*&---------------------------------------------------------------------*
*&      Module  PBO_SET_STATUS  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE PBO_SET_STATUS OUTPUT.

  SET PF-STATUS '7000'.
  SET TITLEBAR 'T7000'.

ENDMODULE.                 " PBO_SET_STATUS  OUTPUT
