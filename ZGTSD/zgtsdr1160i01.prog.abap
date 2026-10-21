*&---------------------------------------------------------------------*
*& Include          ZGTSDR1160I01
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
      PERFORM EXIT_PROCESS.



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
    WHEN 'ZSAVE'. "저장
      PERFORM SAVE_DATA.

    WHEN 'REFR'.  "REFRESH
      PERFORM REFRESH_LIST.

    WHEN 'PICK'. "떠블클릭
      CLEAR GV_FNAME.
      GET CURSOR FIELD GV_FNAME.
      IF GV_FNAME EQ 'GS_HEAD-VBELN'.
        SET PARAMETER ID 'AUN' FIELD GS_HEAD-VBELN.
        SET PARAMETER ID 'VPO' FIELD GS_HEAD-POSNR.

        CALL TRANSACTION 'VA03' WITH AUTHORITY-CHECK
                                 AND SKIP FIRST SCREEN.
      ENDIF.
    WHEN OTHERS.
  ENDCASE.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  CHANGE_ATTR  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CHANGE_ATTR INPUT.
  IF *GS_HEAD-ZZLABEL_TYPE NE GS_HEAD-ZZLABEL_TYPE.
    CASE GS_HEAD-ZZLABEL_TYPE.
      WHEN GC_1.
        CLEAR: GS_HEAD-ZZLABEL_TITLE2_N,
               GS_HEAD-ZZLABEL_TITLE3_N,
               GS_HEAD-ZZLABEL_TITLE4_N.
      WHEN GC_2.
        CLEAR: GS_HEAD-ZZLABEL_TITLE3_N,
               GS_HEAD-ZZLABEL_TITLE4_N.
      WHEN GC_3.
        CLEAR: GS_HEAD-ZZLABEL_TITLE4_N.
      WHEN GC_4.
    ENDCASE.
  ENDIF.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  CHANGE_ITEM_ATTR  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CHANGE_ITEM_ATTR INPUT.
  PERFORM CHANGE_ITEM_ATTR.

  *GS_HEAD = GS_HEAD.
ENDMODULE.
