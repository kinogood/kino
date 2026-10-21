*&---------------------------------------------------------------------*
*& Include          ZGTPPR1170S01
*&---------------------------------------------------------------------*
SELECTION-SCREEN: BEGIN OF BLOCK blk WITH FRAME TITLE TEXT-000.
  PARAMETERS: gp_werks TYPE marc-werks      OBLIGATORY,
              gp_dispo TYPE marc-dispo      OBLIGATORY,
              gp_procd TYPE zppt0030-procd  OBLIGATORY,
              gp_stlan TYPE mast-stlan      OBLIGATORY.

  SELECTION-SCREEN: BEGIN OF LINE.
    SELECTION-SCREEN:   COMMENT 01(31) TEXT-001.
    SELECTION-SCREEN:   POSITION 33.
    PARAMETERS:         gp_new         RADIOBUTTON GROUP gr1 DEFAULT 'X'.
    SELECTION-SCREEN:   COMMENT 35(04) TEXT-002 FOR FIELD gp_new.
    SELECTION-SCREEN:   POSITION 43.
    PARAMETERS:         gp_ext         RADIOBUTTON GROUP gr1.
    SELECTION-SCREEN:   COMMENT 45(04) TEXT-003 FOR FIELD gp_ext.
    SELECTION-SCREEN:   POSITION 53.
    PARAMETERS:         gp_all         RADIOBUTTON GROUP gr1.
    SELECTION-SCREEN:   COMMENT 55(04) TEXT-004 FOR FIELD gp_all.
  SELECTION-SCREEN:  END   OF LINE.

  SELECT-OPTIONS:   gs_spart     FOR mara-spart,
                    gs_mtart     FOR mara-mtart,
                    gs_matnr     FOR mara-matnr.
SELECTION-SCREEN: END   OF BLOCK blk.

SELECTION-SCREEN FUNCTION KEY 1.

AT SELECTION-SCREEN OUTPUT.
  sscrfields-functxt_01 = TEXT-fc1.

AT SELECTION-SCREEN.
  CASE sscrfields-ucomm.
    WHEN 'FC01'.
      PERFORM user_command_fc01.
  ENDCASE.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR gp_procd.
  PERFORM pov_for_procd.
