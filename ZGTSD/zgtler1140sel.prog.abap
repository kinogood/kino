*&---------------------------------------------------------------------*
*& Include          ZGTLER1140SEL
*&---------------------------------------------------------------------*
* Screen Layout
SELECTION-SCREEN: BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-001.
  PARAMETERS: p_gubun1(3) AS LISTBOX
                          VISIBLE LENGTH 25 OBLIGATORY "통문유형
                          DEFAULT 'A01'.

  SELECTION-SCREEN: BEGIN OF LINE.
    PARAMETERS: r_com    RADIOBUTTON GROUP rd1     "통문확정
                         USER-COMMAND ucomm DEFAULT 'X'.
    SELECTION-SCREEN: COMMENT 4(28)  TEXT-001 FOR FIELD r_com.

    PARAMETERS: r_cnc    RADIOBUTTON GROUP rd1.    "통문취소
    SELECTION-SCREEN: COMMENT 50(15) TEXT-002 FOR FIELD r_cnc.
  SELECTION-SCREEN: END OF LINE.

SELECTION-SCREEN: END OF BLOCK b1.
*
SELECTION-SCREEN: BEGIN OF BLOCK b2 WITH FRAME TITLE TEXT-003.
  PARAMETERS    : p_bzarea   LIKE  zlet0033-bzarea OBLIGATORY
                                   MEMORY ID zbarea.
  SELECT-OPTIONS: s_ivdate   FOR   sy-datum OBLIGATORY. "거래명세서일자
  SELECT-OPTIONS: s_wadat    FOR   likp-wadat.          "계획출고일
  SELECT-OPTIONS: s_oudat    FOR   zlet0005-out_date.   "통문확정일
  SELECT-OPTIONS: s_ivno     FOR   zlet0005-iv_no.      "통문번호
  SELECT-OPTIONS: s_tknum    FOR   zlet0006-tknum.      "선적문서
  PARAMETERS    : p_trno     LIKE  zlet0005-truck_no.   "차량 번호
  SELECT-OPTIONS: s_ivtyp    FOR   zlet0005-iv_type NO-DISPLAY.
SELECTION-SCREEN: END OF BLOCK b2.
