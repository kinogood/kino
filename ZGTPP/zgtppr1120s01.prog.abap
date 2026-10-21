*&---------------------------------------------------------------------*
*& Include          ZGTPPR1120S01
*&---------------------------------------------------------------------*
SELECTION-SCREEN: BEGIN OF BLOCK blk WITH FRAME TITLE TEXT-000.
  PARAMETERS: gp_werks TYPE marc-werks     OBLIGATORY,
              gp_dispo TYPE marc-dispo     OBLIGATORY,
              gp_procd TYPE zppt0031-procd OBLIGATORY.

  SELECTION-SCREEN: BEGIN OF LINE.
    SELECTION-SCREEN:   COMMENT 01(31) TEXT-001.
    SELECTION-SCREEN:   POSITION 33.
    PARAMETERS:         gp_new         RADIOBUTTON GROUP gr1 DEFAULT 'X'.
    SELECTION-SCREEN:   COMMENT 35(09) TEXT-002 FOR FIELD gp_new.
    SELECTION-SCREEN:   POSITION 47.
    PARAMETERS:         gp_ext         RADIOBUTTON GROUP gr1.
    SELECTION-SCREEN:   COMMENT 49(09) TEXT-003 FOR FIELD gp_ext.
    SELECTION-SCREEN:   POSITION 61.
    PARAMETERS:         gp_all         RADIOBUTTON GROUP gr1.
    SELECTION-SCREEN:   COMMENT 63(09) TEXT-004 FOR FIELD gp_all.
    PARAMETERS:         gp_seq         RADIOBUTTON GROUP gr1.
    SELECTION-SCREEN:   COMMENT 74(09) TEXT-005 FOR FIELD gp_seq.
  SELECTION-SCREEN:  END   OF LINE.

  SELECT-OPTIONS:   gs_spart     FOR mara-spart,
                    gs_mtart     FOR mara-mtart,
                    gs_matnr     FOR mara-matnr.
SELECTION-SCREEN: END   OF BLOCK blk.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR gp_procd.
  PERFORM pov_for_procd.
