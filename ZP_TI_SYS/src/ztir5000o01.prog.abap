************************************************************************
* Title         : ZTIR5000O01                                          *
*                                                                      *
* Description   : 수입 입고 관리 PBO Include                           *
*                                                                      *
* Creation Date : 2004/02/11                                           *
*                                                                      *
* Author        : SeogBong, Kang                                       *
*                 Copyright ⓒ ASEG Co., LTD. All rights reserved.     *
************************************************************************
*----------------------------------------------------------------------*
*                M O D I F I C A T I O N   L O G                       *
*----------------------------------------------------------------------*
* Date         Programmer       CSR            Description             *
*----------------------------------------------------------------------*
* 20091019      MMB03      C20091014_40571    배치자재입고 시 공급업체 *
*                                             배치 관리 가능토록 개선  *
*                                                                      *
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  tc_2130_init  OUTPUT
*&---------------------------------------------------------------------*
MODULE TC_2130_INIT OUTPUT.

  IF G_TC_2130_COPIED IS INITIAL.
    G_TC_2130_COPIED = 'X'.
    REFRESH CONTROL 'TC_2130' FROM SCREEN '2130'.
  ENDIF.

ENDMODULE.                 " tc_2130_init  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  tc_2130_move  OUTPUT
*&---------------------------------------------------------------------*
MODULE TC_2130_MOVE OUTPUT.

  MOVE-CORRESPONDING G_TC_2130_WA TO ZTISGRIT.

ENDMODULE.                 " tc_2130_move  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  tc_2130_get_lines  OUTPUT
*&---------------------------------------------------------------------*
MODULE TC_2130_GET_LINES OUTPUT.

*  g_tc_2130_lines = sy-loopc.
  DESCRIBE TABLE IT_TAB  LINES G_LINE.              " LINE COUNT GET
  G_TC_2130_LINES = G_LINE.                         " LINE DEFINE
  TC_2130-LINES = G_LINE.

ENDMODULE.                 " tc_2130_get_lines  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  tc_2130_change_field_attr  OUTPUT
*&---------------------------------------------------------------------*
MODULE TC_2130_CHANGE_FIELD_ATTR OUTPUT.

  LOOP AT SCREEN.
    CLEAR G_FIELDGROUP.
    CONCATENATE SCREEN-GROUP1 SCREEN-GROUP2
                SCREEN-GROUP3 SCREEN-GROUP4
           INTO G_FIELDGROUP.

*> 생성/변경 모드가 아닐 경우.
    IF NOT ( G_MODE EQ C_CHARC OR
             G_MODE EQ C_CHARM ) AND
       NOT ( SCREEN-NAME EQ 'G_TC_2130_WA-FLAG' ).
      SCREEN-INPUT = C_CHAR0.
    ENDIF.
    SEARCH G_FIELDGROUP FOR G_MODE.
    IF SY-SUBRC <> 0.
      SCREEN-INPUT = C_CHAR0.
    ELSE.
      SCREEN-INPUT = C_CHAR1.
************************************************************************
**> Batch 관련 Modified
**> Batch 데이타가 있을 경우 필드 막기...
************************************************************************
*************************< Begin of Modify >****************************
      IF G_TC_2130_WA-BATCHX EQ C_TRUE.
        IF SCREEN-NAME EQ 'PB_SELECT'.
          SCREEN-INPUT = C_CHAR1.
        ELSE.
          SCREEN-INPUT = C_CHAR0.
        ENDIF.
      ENDIF.
*************************< End   of Modify >****************************

************************************************************************
**> 기기 장비재 로직 변경
**2. 수출입 시스템에서의 기자재 시스템의 구분은
**   자재 그룹이 '1Y'로 시작되는 자재 중 금액을 가진 자재는 시스템,
**   금액이 없는 자재는 아이템으로 구분
**   (기존 Account Assignment Category 'P'에서 'Q'로 변경)
************************************************************************
*************************< Begin of Modify >****************************
**      IF g_tc_2130_wa-knttp EQ c_charp.
*      IF g_tc_2130_wa-knttp    EQ c_charq AND
*         g_tc_2130_wa-matnr    NE space   AND
*         g_tc_2130_wa-repos    EQ c_true  AND
*         g_tc_2130_wa-matkl(2) EQ '1Y'.
*
*        screen-input = c_char0.
*      ENDIF.
*************************< End   of Modify >****************************
    ENDIF.
    IF SCREEN-NAME EQ 'PB_SELECT'.
      IF G_TC_2130_WA-MATNR IS INITIAL.
        SCREEN-INPUT = C_CHAR0.
      ELSE.
        SCREEN-INPUT = C_CHAR1.
      ENDIF.
    ENDIF.

    MODIFY SCREEN.
  ENDLOOP.

ENDMODULE.                 " tc_2130_change_field_attr  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  TC_2130_CHANGE_COL_ATTR  OUTPUT
*&---------------------------------------------------------------------*
*       Column Invisibe/Visible
*----------------------------------------------------------------------*
MODULE TC_2130_CHANGE_COL_ATTR OUTPUT.

  LOOP AT TC_2130-COLS INTO GS_COLS.
    G_TABIX = SY-TABIX.
    CASE  GS_COLS-SCREEN-NAME.
      WHEN 'ZTISGRIT-RSNUM' OR 'ZTISGRIT-RSPOS' OR 'ZTISGRIT-RSART'.
        IF ZTITGRK-IGRTY EQ C_CHARP.
          GS_COLS-INVISIBLE = C_CHAR1.
          MODIFY TC_2130-COLS  INDEX G_TABIX FROM GS_COLS.
        ELSE.
          GS_COLS-INVISIBLE = C_CHAR0.
          MODIFY TC_2130-COLS  INDEX G_TABIX FROM GS_COLS.
        ENDIF.
      WHEN 'ZTISGRIT-EBELN' OR 'ZTISGRIT-EBELP' OR 'ZTISGRIT-KNTTP'.
        IF ZTITGRK-IGRTY EQ C_CHARR.
          GS_COLS-INVISIBLE = C_CHAR0.
          MODIFY TC_2130-COLS  INDEX G_TABIX FROM GS_COLS.
        ELSE.
          GS_COLS-INVISIBLE = C_CHAR0.
          MODIFY TC_2130-COLS  INDEX G_TABIX FROM GS_COLS.
        ENDIF.
    ENDCASE.
  ENDLOOP.

ENDMODULE.                 " TC_2130_CHANGE_COL_ATTR  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  TC_7000_init  OUTPUT
*&---------------------------------------------------------------------*
MODULE TC_7000_INIT OUTPUT.

  REFRESH FTAB.

  IF G_MODE EQ C_CHARC OR
     G_MODE EQ C_CHARM.
    MOVE 'BACK'       TO FTAB-FCODE.   APPEND FTAB. ">개요펼치기.
  ELSE.
    MOVE 'BU'         TO FTAB-FCODE.   APPEND FTAB. ">개요펼치기.
    MOVE 'CHECK'      TO FTAB-FCODE.   APPEND FTAB. ">개요펼치기.
    MOVE 'DELE'       TO FTAB-FCODE.   APPEND FTAB. ">개요펼치기.
    MOVE 'INSR'       TO FTAB-FCODE.   APPEND FTAB. ">개요펼치기.
  ENDIF.

  SET PF-STATUS '7000' EXCLUDING FTAB.

  IF G_TC_7000_COPIED IS INITIAL.
    G_TC_7000_COPIED = 'X'.
    REFRESH CONTROL 'TC_7000' FROM SCREEN '7000'.
  ENDIF.

ENDMODULE.                 " TC_7000_init  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  TC_7000_move  OUTPUT
*&---------------------------------------------------------------------*
MODULE TC_7000_MOVE OUTPUT.

  MOVE-CORRESPONDING G_TC_7000_WA TO ZTISGRB.

ENDMODULE.                 " TC_7000_move  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  TC_7000_get_lines  OUTPUT
*&---------------------------------------------------------------------*
MODULE TC_7000_GET_LINES OUTPUT.

*  g_TC_7000_lines = sy-loopc.
  DESCRIBE TABLE G_TC_7000_TEMP LINES G_LINE.       " LINE COUNT GET

  IF G_MODE EQ C_CHARC OR
     G_MODE EQ C_CHARM.
    IF ZTISGRIT-IFCHK EQ C_TRUE.
      G_TC_7000_LINES = G_LINE.                       " LINE DEFINE
    ELSE.
      G_TC_7000_LINES = TC_7000-TOP_LINE  + 20.       " LINE DEFINE
    ENDIF.
  ELSE.
    G_TC_7000_LINES = G_LINE.                       " LINE DEFINE
  ENDIF.
  TC_7000-LINES = G_TC_7000_LINES.

ENDMODULE.                 " TC_7000_get_lines  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  TC_7000_change_field_attr  OUTPUT
*&---------------------------------------------------------------------*
*                        MODIFICATION LOG
*-----------------------------------------------------------------------
*  Date.        Author.   CSR #.           Description
*-----------------------------------------------------------------------
*  2015.04.07   김홍직    기능개선 75028   배치필드입력 활성/비활성 추가
*-----------------------------------------------------------------------
MODULE TC_7000_CHANGE_FIELD_ATTR OUTPUT.

  DATA L_CHECK(1). CLEAR L_CHECK.

  LOOP AT SCREEN.
    CLEAR G_FIELDGROUP.
    CONCATENATE SCREEN-GROUP1 SCREEN-GROUP2
                SCREEN-GROUP3 SCREEN-GROUP4
           INTO G_FIELDGROUP.

*> 생성/변경 모드가 아닐 경우.
    IF NOT ( G_MODE EQ C_CHARC OR
             G_MODE EQ C_CHARM ) AND
       NOT ( SCREEN-NAME EQ 'G_TC_7000_WA-FLAG' ).
      SCREEN-INPUT = C_CHAR0.
    ENDIF.

    SEARCH G_FIELDGROUP FOR G_MODE.
    IF SY-SUBRC <> 0.
      SCREEN-INPUT = C_CHAR0.
    ELSE.
      SCREEN-INPUT = C_CHAR1.
    ENDIF.

    IF NOT G_TC_7000_WA-ZDATA IS INITIAL.
      CASE SCREEN-NAME.
**********************************************************
* DATE : 20091019
* CSR  : C20091014_40571
* 내용 : 공급업체 배치 입력 가능토록 수정
**********************************************************
*        WHEN 'ZTISGRB-GRMNG' OR 'ZTISGRB-LICHA'.
        WHEN 'ZTISGRB-GRMNG'." OR 'ZTISGRB-LICHA'.
          SCREEN-INPUT = C_CHAR0.
      ENDCASE.
    ENDIF.

*-> 기능개선 75028_플랜트 3204일 경우 배치필드 입력 활성화
*  LOOP AT           g_tc_7000_temp
*       INTO         g_tc_7000_wa
*       WITH CONTROL tc_7000
*       CURSOR       tc_7000-current_line.
    IF SCREEN-NAME EQ 'ZTISGRB-BATCH'.
      IF G_TC_2130_WA-WERKS = '3204' AND
         G_TC_2130_WA-XCHPF = 'X'.
        SCREEN-INPUT = C_CHAR1.
      ELSE.
        SCREEN-INPUT = C_CHAR0.
      ENDIF.
      IF SY-UNAME+0(4) = 'ZLSG' AND
         G_TC_2130_WA-XCHPF = 'X'.
        SCREEN-INPUT = C_CHAR1.
        L_CHECK = 'X'.
      ENDIF.
    ENDIF.
*<- 기능개선 75028_플랜트 3204일 경우 배치필드 입력 활성화
    MODIFY SCREEN.
  ENDLOOP.

  IF L_CHECK = 'X'.
    MESSAGE '운영자ID로 접속하여 배치필드가 활성화 됩니다.' TYPE 'I'.
  ENDIF.
ENDMODULE.                 " TC_7000_change_field_attr  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  TC_7000_CHANGE_COL_ATTR  OUTPUT
*&---------------------------------------------------------------------*
*       Column Invisibe/Visible
*----------------------------------------------------------------------*
MODULE TC_7000_CHANGE_COL_ATTR OUTPUT.

*  LOOP AT tc_7000-cols INTO gs_cols.
*    g_tabix = sy-tabix.
*    CASE  gs_cols-screen-name.
*      WHEN 'ZTISGRB-RSNUM' OR 'ZTISGRB-RSPOS' OR 'ZTISGRB-RSART'.
*        IF ztitgrk-igrty EQ c_charp.
*          gs_cols-invisible = c_char1.
*          MODIFY tc_7000-cols  INDEX g_tabix FROM gs_cols.
*        ELSE.
*          gs_cols-invisible = c_char0.
*          MODIFY tc_7000-cols  INDEX g_tabix FROM gs_cols.
*        ENDIF.
*      WHEN 'ZTISGRB-EBELN' OR 'ZTISGRB-EBELP' OR 'ZTISGRB-KNTTP'.
*        IF ztitgrk-igrty EQ c_charr.
*          gs_cols-invisible = c_char0.
*          MODIFY tc_7000-cols  INDEX g_tabix FROM gs_cols.
*        ELSE.
*          gs_cols-invisible = c_char0.
*          MODIFY tc_7000-cols  INDEX g_tabix FROM gs_cols.
*        ENDIF.
*    ENDCASE.
*  ENDLOOP.

ENDMODULE.                 " TC_7000_CHANGE_COL_ATTR  OUTPUT


*&---------------------------------------------------------------------*
*&      Module  pbo_scr2210_sub0_subscreen  OUTPUT
*&---------------------------------------------------------------------*
MODULE PBO_SCR2210_SUB0_SUBSCREEN OUTPUT.

*  g_call_prog        =  c_common_prog.
  G_CALL_PROG        =  SY-CPROG.
  G_CALL_SUBSCREEN   =  C_SCR2211.

*  CALL FUNCTION 'Z_TI_OTHERS_TEXT_EXPORT'
*    EXPORTING
*      lcity  = c_char7
*      start  = c_chars
*      mode   = g_mode
*    TABLES
*      it_tab = it_lctext.
*
ENDMODULE.                 " pbo_scr2210_sub0_subscreen  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  pbo_scr2210_sub1_subscreen  OUTPUT
*&---------------------------------------------------------------------*
MODULE PBO_SCR2210_SUB1_SUBSCREEN OUTPUT.

*  g_call_prog        =  c_common_prog.
  G_CALL_PROG        =  SY-CPROG.
  G_CALL_SUBSCREEN   =  C_SCR2212.

*  CALL FUNCTION 'Z_TI_OTHERS_TEXT_EXPORT'
*    EXPORTING
*      lcity  = c_char7
*      start  = c_chars
*      mode   = g_mode
*    TABLES
*      it_tab = it_lctext.
*


ENDMODULE.                 " pbo_scr2210_sub1_subscreen  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  pbo_scr2210_sub2_subscreen  OUTPUT
*&---------------------------------------------------------------------*
MODULE PBO_SCR2210_SUB2_SUBSCREEN OUTPUT.

*  g_call_prog        =  c_common_prog.
  G_CALL_PROG        =  SY-CPROG.
  G_CALL_SUBSCREEN   =  C_SCR2213.

*  CALL FUNCTION 'Z_TI_OTHERS_TEXT_EXPORT'
*    EXPORTING
*      lcity  = c_char7
*      start  = c_chars
*      mode   = g_mode
*    TABLES
*      it_tab = it_lctext.
*

ENDMODULE.                 " pbo_scr2210_sub2_subscreen  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  pbo_scr2210_sub3_subscreen  OUTPUT
*&---------------------------------------------------------------------*
MODULE PBO_SCR2210_SUB3_SUBSCREEN OUTPUT.

*  g_call_prog        =  c_common_prog.
  G_CALL_PROG        =  SY-CPROG.
  G_CALL_SUBSCREEN   =  C_SCR2214.

*  CALL FUNCTION 'Z_TI_OTHERS_TEXT_EXPORT'
*    EXPORTING
*      lcity  = c_char7
*      start  = c_chars
*      mode   = g_mode
*    TABLES
*      it_tab = it_lctext.
*
ENDMODULE.                 " pbo_scr2210_sub3_subscreen  OUTPUT


*&---------------------------------------------------------------------*
*&      Module  change_EDI_field_attr  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CHANGE_EDI_FIELD_ATTR OUTPUT.

  LOOP AT SCREEN.
    IF G_MODE EQ 'D' OR
       G_MODE EQ 'S'.
      SCREEN-INPUT = '0'.
    ENDIF.
    IF G_MODE EQ 'D'   OR
       G_MODE EQ 'S' .

      IF SCREEN-GROUP1 EQ 'MOD' AND
         SCREEN-NAME(3) EQ 'TC_'.
        SCREEN-INPUT = '0'.
      ENDIF.
    ENDIF.
    MODIFY SCREEN.
  ENDLOOP.

ENDMODULE.                 " change_EDI_field_attr  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  pbo_scr2215_sub0_subscreen  OUTPUT
*&---------------------------------------------------------------------*
MODULE PBO_SCR2215_SUB0_SUBSCREEN OUTPUT.

  G_CALL_PROG        =  SY-CPROG.
  G_CALL_SUBSCREEN   =  C_SCR2214.

ENDMODULE.                 " pbo_scr2215_sub0_subscreen  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  pbo_scr2215_sub1_subscreen  OUTPUT
*&---------------------------------------------------------------------*
MODULE PBO_SCR2215_SUB1_SUBSCREEN OUTPUT.

  G_CALL_PROG        =  SY-CPROG.
  G_CALL_SUBSCREEN   =  C_SCR2216.

ENDMODULE.                 " pbo_scr2215_sub1_subscreen  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  change_field_visible_mode  OUTPUT
*&---------------------------------------------------------------------*
*       업무별로 화면상에 필드를 visible/Invisible 함.
*----------------------------------------------------------------------*
MODULE CHANGE_FIELD_VISIBLE_MODE OUTPUT.

  LOOP AT SCREEN. "엠트론 한정 조회필드
    IF SCREEN-NAME EQ 'GF_POST_DIV' .
      IF ZTITGRK-BUKRS NE '3000'.
        SCREEN-INPUT      =   C_CHAR0.
        SCREEN-INVISIBLE  =   C_CHAR1.
        MODIFY SCREEN.
      ELSEIF  ( SY-UNAME NE 'C526812' AND "엠트론 사용자 한정
                SY-UNAME NE 'C526806' AND
                SY-UNAME NE 'C526811' AND
                SY-UNAME(4) NE 'ZLSG'  ).
        SCREEN-INPUT      =   C_CHAR0.
        SCREEN-INVISIBLE  =   C_CHAR1.
        MODIFY SCREEN.
      ENDIF.
    ENDIF.
  ENDLOOP.

***************************************************
* 20080714 simcho by 박혁세K
* 입고 시 구매처 수정가능토록 수정
***************************************************

  LOOP AT SCREEN.
    IF SCREEN-NAME EQ 'ZTITGRK-LIFNR'.
      SCREEN-INPUT = C_CHAR1.
    ENDIF.
    MODIFY SCREEN.
  ENDLOOP.

ENDMODULE.                 " change_field_visible_mode  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  PBO_SCR2123_SET_GRID  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE PBO_SCR2123_SET_GRID OUTPUT.

  IF G_SCR2123_CONTAINER IS INITIAL.
*> FIELD CATALLOG BUILD
    PERFORM SCR2123_FIELDCAT_BUILD.

* create a custom container control for our ALV Control
    CREATE OBJECT G_SCR2123_CONTAINER
      EXPORTING
        CONTAINER_NAME = 'SCR2123_CONTAINER'.

* create an instance of alv control
    CREATE OBJECT G_SCR2123_GRID
      EXPORTING
        I_PARENT = G_SCR2123_CONTAINER.

*> Set grid handler
*-. Event Receive.
    CREATE OBJECT EVENT_RECEIVER.

* Edit  이벤트 등록
    SET HANDLER :
        EVENT_RECEIVER->HANDLE_DOUBLE_CLICK          FOR G_SCR2123_GRID,
        EVENT_RECEIVER->HANDLE_HOTSPOT_CLICK         FOR G_SCR2123_GRID.
*
    CALL METHOD G_SCR2123_GRID->SET_TABLE_FOR_FIRST_DISPLAY
      EXPORTING
        I_STRUCTURE_NAME = 'ZTISGRHS'
        I_SAVE           = G_VARIANT_SAVE
        IS_VARIANT       = G_VARIANT
        I_DEFAULT        = 'X'
      CHANGING
        IT_FIELDCATALOG  = IT_FIELDCAT_LVC[]
        IT_OUTTAB        = IT_ZTISGRHS[].
  ENDIF.

ENDMODULE.                 " PBO_SCR2123_SET_GRID  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  pbo_scr2123_set_tabstrip  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE PBO_SCR2123_SET_TABSTRIP OUTPUT.

  LOOP AT SCREEN.
    IF SCREEN-NAME EQ 'TABSTRIP_TAB3'.
      IF G_HISTORY_POST EQ C_TRUE.
        SCREEN-INPUT      =  C_CHAR1.
        SCREEN-INVISIBLE  =  C_CHAR0.
      ELSE.
        SCREEN-INPUT      =  C_CHAR0.
        SCREEN-INVISIBLE  =  C_CHAR1.
        MODIFY SCREEN.
      ENDIF.
    ENDIF.
  ENDLOOP.

ENDMODULE.                 " pbo_scr2123_set_tabstrip  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  pbo_status_6010  OUTPUT
*&---------------------------------------------------------------------*
*       입고취소 전기창.
*----------------------------------------------------------------------*
MODULE PBO_STATUS_6010 OUTPUT.

  SET PF-STATUS '6010'.
  IF SY-DYNNR EQ '6010'.
    SET TITLEBAR  'T6010'.
  ELSE.
    SET TITLEBAR  'T6020'.
  ENDIF.

ENDMODULE.                 " pbo_status_6010  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  pbo_scr0100_import_memory  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE PBO_SCR0100_IMPORT_MEMORY OUTPUT.

  IF SY-CALLD EQ C_TRUE .
*> Batch Input일 경우.
    IF SY-BINPT EQ C_TRUE.
      FREE MEMORY ID G_INDXKEY.

      GS_INDX-AEDAT = SY-DATLO.
      GS_INDX-USERA = SY-UNAME.

      IMPORT G_TCODE = G_TCODE1
             FROM DATABASE INDX(ZM)  ID G_INDXKEY
                                     TO GS_INDX.
      G_TCODE = G_TCODE1.
    ENDIF.

    IMPORT G_TCODE      = G_TCODE
           IT_ZTISCCIT  = IT_ZTISCCIT
           FROM DATABASE INDX(ZM)  ID G_INDXKEY
                                   TO GS_INDX.

    IF SY-TCODE NE C_CREATE.
      G_TCODE = SY-TCODE.
    ENDIF.

    CASE G_TCODE.
      WHEN C_NO_DRAFT_DUE_LIST.  ">미통관 입고..
        IF IT_ZTISCCIT[] IS INITIAL.
          MESSAGE A003(OK).
        ENDIF.
        G_TCODE1 = G_TCODE.
        G_TCODE  = C_CREATE.
        G_MODE   = C_CHARC.
      WHEN OTHERS.
        G_TCODE = SY-TCODE.
    ENDCASE.
  ELSE.
    G_TCODE = SY-TCODE.
  ENDIF.

  IF G_TCODE IS INITIAL.
    G_TCODE  = SY-TCODE.
    G_TCODE1 = SY-TCODE.
  ENDIF.

ENDMODULE.                 " pbo_scr0100_import_memory  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  pbo_finished_scr7000  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE PBO_FINISHED_SCR7000 OUTPUT.

  CLEAR: OK-CODE, SY-UCOMM, OK_CODE,
         G_FIELDNAME, G_FINDSCR, G_FINDLINE.

ENDMODULE.                 " pbo_finished_scr7000  OUTPUT
