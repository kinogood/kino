*&---------------------------------------------------------------------*
*& Include          ZGTPPR2210H01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form HDL_DOUBLE_CLICK
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> SENDER
*&      --> E_ROW
*&      --> E_COLUMN
*&---------------------------------------------------------------------*
FORM HDL_DOUBLE_CLICK  USING    P_SENDER TYPE REF TO CL_GUI_ALV_GRID
                                P_ROW TYPE LVC_S_ROW
                                P_COLUMN TYPE LVC_S_COL.

*  DATA: LS_SELTAB TYPE RSPARAMS,
*        LT_SELTAB TYPE TABLE OF RSPARAMS.
*
*  CASE P_SENDER.
*    WHEN GO_GRID_0100.
*      READ TABLE GT_DISP_HEADER INTO DATA(LS_HEAD) INDEX P_ROW-INDEX.
*
*      CLEAR: GT_DISP_ITEM_B.
*      LOOP AT GT_DISP_ITEM INTO DATA(LS_ITEM) WHERE ZSYSTEM_ID EQ LS_HEAD-ZSYSTEM_ID
*                                                AND ZIFKEY     EQ LS_HEAD-ZIFKEY
*                                                AND SOSUNCD    EQ LS_HEAD-SOSUNCD.
*        MOVE-CORRESPONDING LS_ITEM TO GS_DISP_ITEM.
*
*        CASE GS_DISP_ITEM-ZSTAT.
*          WHEN '00' OR '0'.
*            GS_DISP_ITEM-ID = ICON_LED_GREEN.
*          WHEN '01' OR '1'.
*            GS_DISP_ITEM-ID = ICON_LED_RED.
*        ENDCASE.
*
** 시스템 내역
*        GS_DISP_ITEM-ZSYSTEM_ID_DESC = ZGTPP_CL_COMMON=>GET_DOMAIN_TEXT(
*                                         IV_DOMNAME  = 'ZGTDTARGET'" 도메인이름
*                                         IV_DOMVALUE = CONV #( GS_DISP_ITEM-ZSYSTEM_ID ) ).
*
*        APPEND GS_DISP_ITEM TO GT_DISP_ITEM_B.
*        CLEAR: GS_DISP_ITEM.
*      ENDLOOP.
*
*      SORT: GT_DISP_ITEM_B BY ZSYSTEM_ID ZIFKEY ZSEQNO.
*
*      PERFORM SET_BOTTOM_ALV_0101.
*
*  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form HDL_HOTSPOT_CLICK
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> SENDER
*&      --> E_ROW_ID
*&      --> E_COLUMN_ID
*&      --> ES_ROW_NO
*&---------------------------------------------------------------------*
FORM HDL_HOTSPOT_CLICK  USING   P_SENDER    TYPE REF TO CL_GUI_ALV_GRID
                                P_ROW_ID    TYPE LVC_S_ROW
                                P_COLUMN_ID TYPE LVC_S_COL
                                PS_ROW_NO   TYPE LVC_S_ROID.

  CASE P_SENDER.
    WHEN GO_GRID_0100.
      READ TABLE GT_TOP INTO DATA(LS_TOP) INDEX PS_ROW_NO-ROW_ID.

      CASE P_COLUMN_ID.
        WHEN 'ZVERS_NO'.
          CHECK LS_TOP-ZVERS_NO IS NOT INITIAL AND LS_TOP-CAL_CHK EQ 'X'.

          CLEAR: GV_VERSNO.
          GV_VERSNO = LS_TOP-ZVERS_NO.

          PERFORM MOVE_DATA_BOTTOM.
          PERFORM SET_BOTTOM_ALV_0101.
      ENDCASE.

  ENDCASE.

ENDFORM.
