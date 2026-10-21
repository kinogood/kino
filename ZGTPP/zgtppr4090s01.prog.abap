*&---------------------------------------------------------------------*
*& Include          ZGTPPR4090S01
*&---------------------------------------------------------------------*

*----------------------------------------------------------------------*
* Section Screen                                                       *
*----------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK blk1 WITH FRAME TITLE TEXT-t01.
  SELECTION-SCREEN BEGIN OF LINE.
    SELECTION-SCREEN COMMENT 1(31) TEXT-001 FOR FIELD p_werks.
    PARAMETER p_werks TYPE zgtppt4110-werks DEFAULT gc_werks-6500 MEMORY ID wrk MATCHCODE OBJECT zgthpp_werks.
    SELECTION-SCREEN COMMENT 40(30) p_name1 MODIF ID txt.
  SELECTION-SCREEN END OF LINE.

  SELECTION-SCREEN BEGIN OF LINE.
    SELECTION-SCREEN COMMENT 1(31) TEXT-002 FOR FIELD p_spgcd.
    PARAMETER p_spgcd TYPE zgtppt4110-spgcd DEFAULT 'GP' MEMORY ID zspg MATCHCODE OBJECT zh_pp_spgcd.
    SELECTION-SCREEN COMMENT 40(30) p_descr MODIF ID txt.
  SELECTION-SCREEN END OF LINE.

  SELECT-OPTIONS s_matnr  FOR zgtppt4110-matnr.
  SELECT-OPTIONS s_scpnr  FOR zgtppt4110-scpnr.
  SELECT-OPTIONS s_scpdat FOR zgtppt4110-scpdat.
  SELECT-OPTIONS s_indept FOR zgtppt4110-indept.
  SELECT-OPTIONS s_csarb  FOR zgtppt4110-cs_arbpl.
  SELECT-OPTIONS s_opcod  FOR zgtppt4110-opcod.
  SELECT-OPTIONS s_scrsn  FOR zgtppt4110-scpreason.
SELECTION-SCREEN END OF BLOCK blk1.

SELECTION-SCREEN FUNCTION KEY 1.

*---------------------------------------------------------------------*
* AT SELECTION-SCREEN OUTPUT                                          *
*---------------------------------------------------------------------*
AT SELECTION-SCREEN OUTPUT.
  PERFORM at_selection_screen_output.

*---------------------------------------------------------------------*
* AT SELECTION-SCREEN                                                 *
*---------------------------------------------------------------------*
AT SELECTION-SCREEN.
  PERFORM at_selection_screen.

*---------------------------------------------------------------------*
* AT SELECTION-SCREEN ON VALUE-REQUEST                                *
*---------------------------------------------------------------------*
AT SELECTION-SCREEN ON VALUE-REQUEST FOR s_indept-low.
  PERFORM value_request_indept USING s_indept-low.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR s_indept-high.
  PERFORM value_request_indept USING s_indept-high.

*AT SELECTION-SCREEN ON VALUE-REQUEST FOR s_arbpl-low.
*  PERFORM value_request_arbpl USING s_arbpl-low.
*
*AT SELECTION-SCREEN ON VALUE-REQUEST FOR s_arbpl-high.
*  PERFORM value_request_arbpl USING s_arbpl-high.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR s_opcod-low.
  PERFORM value_request_opcod USING s_opcod-low.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR s_opcod-high.
  PERFORM value_request_opcod USING s_opcod-high.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR s_scrsn-low.
  PERFORM value_request_scrsn USING s_scrsn-low.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR s_scrsn-high.
  PERFORM value_request_scrsn USING s_scrsn-high.
