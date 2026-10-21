*&---------------------------------------------------------------------*
*& Include          ZGTSDR0010SEL
*&---------------------------------------------------------------------*
*----------------------------------------------------------------------*
* Selection-Screen
*----------------------------------------------------------------------*

selection-screen begin of block b04 with frame title text-s00.
  selection-screen begin of line.
    selection-screen comment (12) text-s12.
    selection-screen position 33.
    parameters: rb_mbt1 radiobutton group gr2 default 'X' user-command usr2.   " 판매계획
    selection-screen comment (10) text-s08 for field rb_mbt1.

    selection-screen position 52.
    parameters: rb_mbt2 radiobutton group gr2.                                 " 실시간 주문
    selection-screen comment (10) text-s09 for field rb_mbt2.
  selection-screen end of line.


  selection-screen begin of line .
    selection-screen comment (12) text-s13 modif id m1.
    selection-screen position 33.
    parameters: rb_mbt3 radiobutton group gr3 default 'X' user-command usr3 modif id m1.   " 월
    selection-screen comment (10) text-s10 for field rb_mbt3 modif id m1.

    selection-screen position 52.
    parameters: rb_mbt4 radiobutton group gr3 modif id m1.                                 " 주
    selection-screen comment (10) text-s11 for field rb_mbt4 modif id m1.
  selection-screen end of line.
selection-screen end of block b04.

selection-screen begin of block b01 with frame title text-s00.

  select-options : s_vkbur   for zsdt_d365_020-vkbur memory id vkb  matchcode object h_tvbur,
                   s_spart   for zsdt_d365_021-spart.

  selection-screen begin of line.
    selection-screen comment (10) text-s07 for field p_kunnr.
    selection-screen position 33.
    parameters : p_kunnr type vbak-kunnr.
    selection-screen position 44.
    parameters : p_name1 type kna1-name1.
  selection-screen end of line.

  select-options : s_zpjno   for vbak-zpjno matchcode object zsd_pjnot,
                   s_vbeln   for zsdt_d365_021-vbeln,
                   s_matnr   for zsdt_d365_021-matnr,
                   s_spmon   for zsdt_d365_021-basemonth no intervals,
                   s_edatu   for vbak-erdat modif id m2.

*  PARAMETERS : P_ERDAT TYPE ERDAT.

selection-screen end of block b01.

*SELECTION-SCREEN BEGIN OF BLOCK b02 WITH FRAME TITLE TEXT-s01.
*  SELECTION-SCREEN BEGIN OF LINE.
*    SELECTION-SCREEN POSITION 3.
*    PARAMETERS: rb_bt1 RADIOBUTTON GROUP gr1 DEFAULT 'X' USER-COMMAND usr.
*    SELECTION-SCREEN COMMENT (8) TEXT-s02 FOR FIELD rb_bt1.
*
*    SELECTION-SCREEN POSITION 20.
*    PARAMETERS: rb_bt2 RADIOBUTTON GROUP gr1.
*    SELECTION-SCREEN COMMENT (8) TEXT-s03 FOR FIELD rb_bt2.
*
*    SELECTION-SCREEN POSITION 37.
*    PARAMETERS: rb_bt3 RADIOBUTTON GROUP gr1.
*    SELECTION-SCREEN COMMENT (5) TEXT-s04 FOR FIELD rb_bt3.
*
*    SELECTION-SCREEN POSITION 54.
*    PARAMETERS: rb_bt4 RADIOBUTTON GROUP gr1.
*    SELECTION-SCREEN COMMENT (8) TEXT-s05 FOR FIELD rb_bt4.
*  SELECTION-SCREEN END OF LINE.
*SELECTION-SCREEN END OF BLOCK b02.

selection-screen begin of block b02 with frame title text-s01.
  selection-screen begin of line.
    selection-screen position 3.
    parameters: rb_bt1 as checkbox user-command usr.  " 생산완료일(확정)
    selection-screen comment (8) text-s02 for field rb_bt1.
    selection-screen position 20.
    parameters: rb_bt2 as checkbox.                              " FAT
    selection-screen comment (8) text-s03 for field rb_bt2.
    selection-screen position 37.
    parameters: rb_bt3 as checkbox.                              " 출하일
    selection-screen comment (5) text-s04 for field rb_bt3.
    selection-screen position 54.
    parameters: rb_bt4 as checkbox.                              " 선적확정일
    selection-screen comment (8) text-s05 for field rb_bt4.
  selection-screen end of line.
selection-screen end of block b02.


selection-screen begin of block b03 with frame title text-s06.
  parameters : p_vari    like disvariant-variant.
selection-screen end of block b03.
