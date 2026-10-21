************************************************************************
* Title         :  ZTIR9000O01                                         *
*                                                                      *
* Description   : 수입 제비용 관리 PBO Include                         *
*                                                                      *
* Creation Date : 2004/02/22                                           *
*                                                                      *
* Author        : Seog bong, Kang                                      *
*                 Copyright ⓒ ASEG Co., LTD. All rights reserved.     *
************************************************************************
*----------------------------------------------------------------------*
*                M O D I F I C A T I O N   L O G                       *
*----------------------------------------------------------------------*
* Date         Programmer       Transport#  Description                *
*----------------------------------------------------------------------*
* dd-mmm-yyyy  xxxxxxxxxxxxxxx  DVPK9xxxxx  xxxxxxxxxxxxxxxxxxxxxxxxx  *
*                                                                      *
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

  MOVE-CORRESPONDING G_TC_2130_WA TO ZTISCSIT.

ENDMODULE.                 " tc_2130_move  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  tc_2130_get_lines  OUTPUT
*&---------------------------------------------------------------------*
MODULE TC_2130_GET_LINES OUTPUT.

  IF G_MODE EQ 'S' OR
     G_MODE EQ 'D' OR
     G_MODE EQ 'P' OR
     G_MODE EQ 'R'.
*    g_tc_2130_lines = sy-loopc.
    DESCRIBE TABLE IT_TAB  LINES G_LINE.         " LINE COUNT GET
    G_TC_2130_LINES = G_LINE.                    " LINE DEFINE
  ELSE.
    DESCRIBE TABLE IT_TAB  LINES G_LINE.         " LINE COUNT GET
    G_TC_2130_LINES = G_LINE + 20.               " LINE DEFINE
  ENDIF.
  TC_2130-LINES = G_TC_2130_LINES.

ENDMODULE.                 " tc_2130_get_lines  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  tc_2130_change_field_attr  OUTPUT
*&---------------------------------------------------------------------*
MODULE TC_2130_CHANGE_FIELD_ATTR OUTPUT.

  LOOP AT SCREEN.
*> 생성/변경 모드가 아닐 경우.
    IF NOT ( G_MODE EQ C_CHARC OR
             G_MODE EQ C_CHARM ) AND
       NOT ( SCREEN-NAME EQ 'G_TC_2130_WA-FLAG' ).
      SCREEN-INPUT = C_CHAR0.
    ENDIF.

    IF ZTITRQS-SETYN EQ C_TRUE AND   ">정산여부 = 'Y'.
       NOT ( SCREEN-NAME EQ 'G_TC_2130_WA-FLAG' ).
      SCREEN-INPUT = C_CHAR0.
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
    CASE  ZTITCSK-EXPGR.
      WHEN  C_CHARL.
        IF GS_COLS-SCREEN-NAME EQ 'ZTISCSIT-IIPNO' OR
           GS_COLS-SCREEN-NAME EQ 'ZTISCSIT-AMSEQ' OR
           GS_COLS-SCREEN-NAME EQ 'ZTISCSIT-IBLNO' OR
           GS_COLS-SCREEN-NAME EQ 'ZTISCSIT-TAXNO' OR
           GS_COLS-SCREEN-NAME EQ 'ZTISCSIT-ICCNO'.
          GS_COLS-INVISIBLE = C_CHAR1.
        ELSE.
          GS_COLS-INVISIBLE = C_CHAR0.
        ENDIF.
      WHEN  C_CHARI.
        IF GS_COLS-SCREEN-NAME EQ 'ZTISCSIT-REQNO' OR
           GS_COLS-SCREEN-NAME EQ 'ZTISCSIT-IBLNO' OR
           GS_COLS-SCREEN-NAME EQ 'ZTISCSIT-ICCNO' OR
           GS_COLS-SCREEN-NAME EQ 'ZTISCSIT-TAXNO' OR
           GS_COLS-SCREEN-NAME EQ 'ZTISCSIT-AMDSQ'.
          GS_COLS-INVISIBLE = C_CHAR1.
        ELSE.
          GS_COLS-INVISIBLE = C_CHAR0.
        ENDIF.
      WHEN  C_CHARB.
        IF GS_COLS-SCREEN-NAME EQ 'ZTISCSIT-REQNO' OR
           GS_COLS-SCREEN-NAME EQ 'ZTISCSIT-IIPNO' OR
           GS_COLS-SCREEN-NAME EQ 'ZTISCSIT-AMDSQ' OR
           GS_COLS-SCREEN-NAME EQ 'ZTISCSIT-TAXNO' OR
           GS_COLS-SCREEN-NAME EQ 'ZTISCSIT-AMSEQ' OR
           GS_COLS-SCREEN-NAME EQ 'ZTISCSIT-ICCNO'.
          GS_COLS-INVISIBLE = C_CHAR1.
        ELSE.
          GS_COLS-INVISIBLE = C_CHAR0.
        ENDIF.
      WHEN  C_CHARC.
        IF GS_COLS-SCREEN-NAME EQ 'ZTISCSIT-REQNO' OR
           GS_COLS-SCREEN-NAME EQ 'ZTISCSIT-IIPNO' OR
           GS_COLS-SCREEN-NAME EQ 'ZTISCSIT-AMDSQ' OR
           GS_COLS-SCREEN-NAME EQ 'ZTISCSIT-TAXNO' OR
*           gs_cols-screen-name EQ 'ZTISCSIT-AMSEQ' OR
           GS_COLS-SCREEN-NAME EQ 'ZTISCSIT-IBLNO'.
          GS_COLS-INVISIBLE = C_CHAR1.
        ELSE.
          GS_COLS-INVISIBLE = C_CHAR0.
        ENDIF.
      WHEN  C_CHART.
        IF GS_COLS-SCREEN-NAME EQ 'ZTISCSIT-REQNO' OR
           GS_COLS-SCREEN-NAME EQ 'ZTISCSIT-IIPNO' OR
           GS_COLS-SCREEN-NAME EQ 'ZTISCSIT-AMDSQ' OR
           GS_COLS-SCREEN-NAME EQ 'ZTISCSIT-AMSEQ' OR
           GS_COLS-SCREEN-NAME EQ 'ZTISCSIT-IBLNO' OR
           GS_COLS-SCREEN-NAME EQ 'ZTISCSIT-ICCNO'.
          GS_COLS-INVISIBLE = C_CHAR1.
        ELSE.
          GS_COLS-INVISIBLE = C_CHAR0.
        ENDIF.
    ENDCASE.
    MODIFY TC_2130-COLS  INDEX G_TABIX FROM GS_COLS.
  ENDLOOP.

ENDMODULE.                 " TC_2130_CHANGE_COL_ATTR  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  change_field_visible_mode  OUTPUT
*&---------------------------------------------------------------------*
*       업무별로 화면상에 필드를 visible/Invisible 함.
*----------------------------------------------------------------------*
MODULE CHANGE_FIELD_VISIBLE_MODE OUTPUT.

  CHECK SY-CALLD NE 'X'.

  LOOP AT SCREEN.
    IF SCREEN-NAME EQ 'ZTITCSK-KURSF' OR
       SCREEN-NAME EQ 'ZTITCSK-WWERT' OR
       SCREEN-NAME EQ 'ZTITCSK-DMBTR' OR
       SCREEN-NAME EQ 'ZTITCSK-HWAER'.
      IF ZTITCSK-WAERS EQ ZTITCSK-HWAER.
        SCREEN-INPUT     = C_CHAR0.
        SCREEN-INVISIBLE = C_CHAR1.
      ELSE.
        IF G_MODE EQ C_CHARC OR
           G_MODE EQ C_CHARM.
          IF SCREEN-NAME EQ 'ZTITCSK-HWAER'.
            SCREEN-INPUT     = C_CHAR0.
          ELSE.
            SCREEN-INPUT     = C_CHAR1.
          ENDIF.
        ELSE.
          SCREEN-INPUT     = C_CHAR0.
        ENDIF.
        SCREEN-INVISIBLE = C_CHAR0.
      ENDIF.
    ENDIF.
    IF ZTITIG00-CHKBP IS INITIAL AND
       SCREEN-NAME EQ 'ZTITCSK-BUPLA'.
      SCREEN-INPUT     = C_CHAR0.
      SCREEN-INVISIBLE = C_CHAR1.
    ENDIF.
    IF ZTITIG00-CHKBA IS INITIAL AND
       SCREEN-NAME EQ 'ZTITCSK-GSBER'.
      SCREEN-INPUT     = C_CHAR0.
      SCREEN-INVISIBLE = C_CHAR1.
    ENDIF.

**-2022.07.19 재무회계 최혜정 요청  -[s}
*    IF ZTITCSK-BUKRS EQ '3000' AND SY-TCODE EQ C_CHANGE .
*      IF SCREEN-NAME EQ 'ZTITCSK-CSTYP'  OR  "정산종류
*         SCREEN-NAME EQ 'ZTITCSK-ZLSPR'  OR  "지급종류
*         SCREEN-NAME EQ 'ZTITCSK-ZLSCH'  OR  "지급방법
*         SCREEN-NAME EQ 'ZTITCSK-ZTERM'   .  "지급조건
*         SCREEN-INPUT     = C_CHAR0.
*      ENDIF.
*
*      IF SCREEN-NAME EQ 'ZTITCSK-INAME'  . "담당자 미조회
*         SCREEN-INPUT     = C_CHAR0.
*         SCREEN-INVISIBLE = C_CHAR1.
*      ENDIF.
*    ENDIF.
**-2022.07.19 재무회계 최혜정 요청  -[e}


    MODIFY SCREEN.
  ENDLOOP.

ENDMODULE.                 " change_field_visible_mode  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  PBO_SCR2123_SET_GRID  OUTPUT
*&---------------------------------------------------------------------*
*       이력 GRID
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
        I_STRUCTURE_NAME = 'ZTISCSHS'
        I_SAVE           = G_VARIANT_SAVE
        IS_VARIANT       = G_VARIANT
        I_DEFAULT        = 'X'
      CHANGING
        IT_FIELDCATALOG  = IT_FIELDCAT_LVC[]
        IT_OUTTAB        = IT_ZTISCSHS[].
  ENDIF.

ENDMODULE.                 " PBO_SCR2123_SET_GRID  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  pbo_scr2120_set_tabstrip  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE PBO_SCR2120_SET_TABSTRIP OUTPUT.

  LOOP AT SCREEN.
    IF SCREEN-NAME EQ 'TABSTRIP_TAB3'.
      IF G_HISTORY EQ C_TRUE.
        SCREEN-INPUT      =  C_CHAR1.
        SCREEN-INVISIBLE  =  C_CHAR0.
      ELSE.
        SCREEN-INPUT      =  C_CHAR0.
        SCREEN-INVISIBLE  =  C_CHAR1.
        MODIFY SCREEN.
      ENDIF.
    ENDIF.
  ENDLOOP.

ENDMODULE.                 " pbo_scr2120_set_tabstrip  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  SET_SCREEN_2111_BY_BUSINESS  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE PBO_SCR2111_SET_SCREEN OUTPUT.

  LOOP AT SCREEN.

*-[CHM2207-00114] 엠트론 한정 트랜잭션 제비용변경시
*                  리스트 박스 비활성 처리
    IF SCREEN-NAME   EQ 'ZTITCSK-VORGANG' AND
       ZTITCSK-BUKRS EQ '3000'            AND
       SY-TCODE    EQ C_CHANGE .

      SCREEN-INPUT = C_CHAR0 .
      MODIFY SCREEN.
    ENDIF.
  ENDLOOP.

ENDMODULE.                 " SET_SCREEN_2111_BY_BUSINESS  OUTPUT
