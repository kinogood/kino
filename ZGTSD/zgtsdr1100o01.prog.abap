*----------------------------------------------------------------------*
***INCLUDE ZSDR0950O01.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Module STATUS_0100 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE STATUS_0100 OUTPUT.
  IF VBAK-VKORG IS INITIAL.
    VBAK-VKORG = GC_VKORG_6000.
  ENDIF.
  SET PF-STATUS 'S0100'.
  SET TITLEBAR  'T0100'.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module SCREEN_CONTROL OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE SCREEN_CONTROL_100 OUTPUT.

  LOOP AT SCREEN.
    IF SCREEN-GROUP1 = 'G1'.
*      SCREEN-REQUIRED = 2.
      SCREEN-REQUIRED = 1. "필수입력
      MODIFY SCREEN.
    ENDIF.

    IF SCREEN-GROUP1 = 'G2'.
      SCREEN-INPUT = 0.
      MODIFY SCREEN.
    ENDIF.
  ENDLOOP.

ENDMODULE.
*&---------------------------------------------------------------------*
*& Module STATUS_0200 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE STATUS_0200 OUTPUT.
  DATA : FCODE    TYPE TABLE OF SY-UCOMM.

  CASE SY-TCODE.
*_생성
    WHEN GC_ZVBO1.
      IF GV_SAVE EQ GC_X.  "계약문서 저장
        FCODE = VALUE #( ( 'BT02' ) ( 'SAVE' ) ( 'DELETE' ) ( 'ATTC' ) ).
      ELSE.
        FCODE = VALUE #( ( 'BT02' ) ( 'DELETE' ) ( 'ATTC' ) ).
      ENDIF.
*      IF GV_SAVE = 'X'.
*        FCODE = VALUE #( ( 'BT02' )      ( 'DELETE' ) ( 'APPR_REQ' )
*                         ( 'APPR_CANC' ) ( 'APPR' )   ( 'REJEC' )
*                         ( 'SAVE' )      ( 'ATTC' )   ( 'LOG_DISP' ) ).
*      ELSE.
*        FCODE = VALUE #( ( 'BT02' )      ( 'DELETE' ) ( 'APPR_REQ' )
*                         ( 'APPR_CANC' ) ( 'APPR' )   ( 'REJEC' )
*                         ( 'ATTC' )      ( 'LOG_DISP' ) ).
*      ENDIF.

*_ 변경
    WHEN GC_ZVBO2.

      FCODE = VALUE #( ( 'BT02' ) ).

*      IF GV_APRV_STAT = 'P' OR GV_APRV_STAT = 'C'.  "승인요청 중 OR 승인완료
*
*        FCODE = VALUE #( ( 'BT02' )     ( 'DELETE' )
*                         ( 'APPR_REQ' ) ( 'APPR_CANC' )
*                         ( 'APPR' )     ( 'REJEC' )
*                         ( 'SAVE' )     ( 'LOG_DISP' ) ).
*
*      ELSE.
*
*        FCODE = VALUE #( ( 'BT02' ) ( 'APPR_CANC' )
*                         ( 'APPR' ) ( 'REJEC' )
*                         ( 'LOG_DISP' ) ).
*
*      ENDIF.

*_ 조회
    WHEN GC_ZVBO3.
      FCODE = VALUE #( ( 'DELETE' )    ( 'APPR_REQ' )
                       ( 'APPR_CANC' ) ( 'APPR' )
                       ( 'REJEC' )     ( 'SAVE' )
                       ( 'LOG_DISP' ) ).


**_ 요청취소
*    WHEN GC_ZVBO4.
*      FCODE = VALUE #( ( 'BT02' )     ( 'DELETE' )
*                       ( 'APPR_REQ' ) ( 'APPR' )
*                       ( 'REJEC' )    ( 'SAVE' )
*                       ( 'LOG_DISP' ) ).
*
*      IF GV_SAVE = 'X'.
*        FCODE = VALUE #( ( 'BT02' )     ( 'DELETE' )
*                         ( 'APPR_REQ' ) ( 'APPR' )
*                         ( 'REJEC' )    ( 'APPR_CANC' )
*                         ( 'SAVE' )     ( 'LOG_DISP' ) ).
*
*      ENDIF.


**_ 승인/반려
*    WHEN GC_ZVBO5.
*      IF GV_SAVE = 'X'.
*
*        FCODE = VALUE #( ( 'BT02' )     ( 'DELETE' )
*                         ( 'APPR_REQ' ) ( 'APPR' )
*                         ( 'REJEC' )    ( 'APPR_CANC' )
*                         ( 'SAVE' )     ( 'LOG_DISP' ) ).
*
*      ELSE.
*
*        FCODE = VALUE #( ( 'BT02' )     ( 'DELETE' )
*                         ( 'APPR_REQ' ) ( 'APPR_CANC' )
*                         ( 'SAVE' )     ( 'LOG_DISP' ) ).
*
*      ENDIF.
*
*
**_승인후 변경(권한자) - 회계팀
*    WHEN GC_ZVBO6.
*
*      FCODE = VALUE #( ( 'BT02' )     ( 'DELETE' )
*                       ( 'APPR_REQ' ) ( 'APPR_CANC' )
*                       ( 'APPR' )     ( 'REJEC' ) ).

  ENDCASE.

  SET PF-STATUS 'S0200' EXCLUDING FCODE.

  CASE SY-TCODE.
    WHEN GC_ZVBO1.
      SET TITLEBAR  'T0200' WITH GC_TITLE1.
    WHEN GC_ZVBO2.
      SET TITLEBAR  'T0200' WITH GC_TITLE2.
    WHEN GC_ZVBO3.
      SET TITLEBAR  'T0200' WITH GC_TITLE3.
    WHEN GC_ZVBO4.
      SET TITLEBAR  'T0200' WITH GC_TITLE2.
    WHEN GC_ZVBO5.
      SET TITLEBAR  'T0200' WITH GC_TITLE2.
    WHEN GC_ZVBO6.
      SET TITLEBAR  'T0200' WITH GC_TITLE6.
  ENDCASE.

*  PERFORM GET_APPROVER_INFO. "SRM2404-03220 - s 승인자 정보 조회

*{ ZLSGSD4 - s
  CLEAR GV_EXIT.
  GET PARAMETER ID 'CAL' FIELD GV_EXIT.
*} ZLSGSD4 - e
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module DISPLAY_ALV OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE DISPLAY_ALV_200 OUTPUT.

  CHECK  GV_ZSA1 = ' '.


  GS_STBL-ROW = 'X'.
  GS_STBL-COL = 'X'.

  IF GRID IS INITIAL.

    PERFORM CREATE_CONTROLS.
    PERFORM SET_EVENT.
    PERFORM ALV_LAYOUT.
    PERFORM EXCLUDE_TB_FUNCTIONS CHANGING GT_EXCLUDE.
    PERFORM SET_VARIANT.
    PERFORM INIT_LISTBOX.
    PERFORM FIELDCAT_INIT.
*   [CHG]----S
    PERFORM APPEND_NEW.
*   [CHG]----E
    PERFORM CONTROL_CELL_EDIT.

    CALL METHOD GRID->SET_TABLE_FOR_FIRST_DISPLAY
      EXPORTING
        I_SAVE               = 'U'
        IS_LAYOUT            = GS_LAYOUT
        IS_VARIANT           = GS_VARIANT
        IT_TOOLBAR_EXCLUDING = GT_EXCLUDE[]
      CHANGING
        IT_OUTTAB            = GT_ITAB
        IT_SORT              = GT_SORT[]
        IT_FIELDCATALOG      = GT_FIELDCAT.

  ELSE.
    PERFORM FIELDCAT_INIT.
    PERFORM ALV_LAYOUT.
    PERFORM CONTROL_CELL_EDIT.

    CALL METHOD GRID->SET_FRONTEND_FIELDCATALOG
      EXPORTING
        IT_FIELDCATALOG = GT_FIELDCAT[].


    CALL METHOD GRID->SET_FRONTEND_LAYOUT
      EXPORTING
        IS_LAYOUT = GS_LAYOUT.

    CALL METHOD GRID->REFRESH_TABLE_DISPLAY
      EXPORTING
        IS_STABLE = GS_STBL.
  ENDIF.

ENDMODULE.
*&---------------------------------------------------------------------*
*& Module STATUS_0300 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE STATUS_0300 OUTPUT.
  GET PARAMETER ID 'VBO' FIELD GV_KNUMA.
  SET PF-STATUS 'S0300'.

*{ ZLSGSD4 - s T-code에 따라 문구변경
  CASE SY-TCODE.
    WHEN GC_ZVBO1.
      SET TITLEBAR  'T0200' WITH GC_TITLE1.
    WHEN GC_ZVBO2.
      SET TITLEBAR  'T0200' WITH GC_TITLE2.
    WHEN GC_ZVBO3.
      SET TITLEBAR  'T0200' WITH GC_TITLE3.
    WHEN GC_ZVBO4.
      SET TITLEBAR  'T0200' WITH GC_TITLE4.
    WHEN GC_ZVBO5.
      SET TITLEBAR  'T0200' WITH GC_TITLE5.
    WHEN GC_ZVBO6.
      SET TITLEBAR  'T0200' WITH GC_TITLE6.
  ENDCASE.
*} ZLSGSD4 - e

  GET PARAMETER ID 'ZSA1' FIELD GV_ZSA1.

  SELECT SINGLE ZACTIVE
     INTO GV_SIMPLE_APPROVAL
    FROM ZSAT0004
    WHERE ZTYPE = 'V6'.


ENDMODULE.
*&---------------------------------------------------------------------*
*& Module SCREEN_CONTROL_0300 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE SCREEN_CONTROL_0300 OUTPUT.

  LOOP AT SCREEN.
*    IF SCREEN-NAME = 'GV_KNUMA'.
*      SCREEN-REQUIRED = 1.
*      MODIFY SCREEN.
*    ENDIF.
  ENDLOOP.

ENDMODULE.
*&---------------------------------------------------------------------*
*& Module SCREEN_CONTROL_200 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE SCREEN_CONTROL_200 OUTPUT.


  CHECK  GV_ZSA1 = ' '.


  LOOP AT SCREEN.
    CASE SY-TCODE.

*_생성
      WHEN GC_ZVBO1.
        IF SCREEN-GROUP4 = 'G4'.
          SCREEN-INPUT = 0.
        ENDIF.
*       [CHG]--------S
        IF SCREEN-GROUP2 = 'G2'.
          IF GS_HEADER-KNUMA IS NOT INITIAL.
            SCREEN-INPUT = 0.
          ELSE.
            SCREEN-INPUT = 1.
            SCREEN-REQUIRED = 2.
          ENDIF.
        ENDIF.
        IF SCREEN-GROUP2 = 'Z1'.
          IF GS_HEADER-KNUMA IS NOT INITIAL.
            SCREEN-INPUT = 0.
          ELSE.
            SCREEN-INPUT = 1.

          ENDIF.
        ENDIF.
*        IF SCREEN-GROUP2 = 'G2'.
*          SCREEN-REQUIRED = 2.
*        ENDIF.
*       [CHG]--------E

        IF SCREEN-GROUP1 = 'L1'.
          SCREEN-INVISIBLE = '1'.
        ENDIF.


*_ 변경
      WHEN GC_ZVBO2.
*       [CHG]--------S
*        IF SCREEN-GROUP4 = 'G4'.
*          SCREEN-INPUT = 0.
*        ENDIF.
*        IF SCREEN-GROUP2 = 'G2'.
*          IF GS_HEADER-KNUMA IS NOT INITIAL.
*            SCREEN-INPUT = 0.
*          ELSE.
*            SCREEN-INPUT = 1.
*            SCREEN-REQUIRED = 2.
*          ENDIF.
*        ENDIF.
*        IF SCREEN-GROUP2 = 'Z1'.
*          IF GS_HEADER-KNUMA IS NOT INITIAL.
*            SCREEN-INPUT = 0.
*          ELSE.
*            SCREEN-INPUT = 1.
*
*          ENDIF.
*        ENDIF.
        IF GV_APRV_STAT = 'P'. "승인요청 중
          IF SCREEN-GROUP1 = 'G1'.
            SCREEN-INPUT = 0.
          ENDIF.
        ELSEIF GV_APRV_STAT = 'C'. "승인후 .
          IF SCREEN-GROUP1 = 'G1'.
            SCREEN-INPUT = 0.
          ENDIF.
*          IF SCREEN-GROUP3 = 'G3'.
*            SCREEN-INPUT = 0.
*          ENDIF.
*          IF SCREEN-GROUP2 = 'G2'.
*            SCREEN-REQUIRED = 2.
*          ENDIF.
        ELSE.
          IF SCREEN-GROUP3 = 'G3'.
            SCREEN-INPUT = 0.
          ENDIF.
          IF SCREEN-GROUP2 = 'G2'.
            SCREEN-REQUIRED = 2.
          ENDIF.
        ENDIF.
*       [CHG]--------E
*{ SRM2404-03220 - s
        IF SCREEN-GROUP1 = 'L1'.
          SCREEN-INVISIBLE = '1'.
        ENDIF.
*} SRM2404-03220 - e

*_ 조회
      WHEN GC_ZVBO3.
        IF SCREEN-GROUP1 = 'G1'.
          SCREEN-INPUT = 0.
        ENDIF.
*{ SRM2404-03220 - s
        IF SCREEN-GROUP1 = 'L1'.
          SCREEN-INVISIBLE = '0'.
        ENDIF.
*} SRM2404-03220 - e

**_ 요청취소
*      WHEN GC_ZVBO4.
*        IF SCREEN-GROUP1 = 'G1'.
*          SCREEN-INPUT = 0.
*        ENDIF.
**{ SRM2404-03220 - s
*        IF SCREEN-GROUP1 = 'L1'.
*          SCREEN-INVISIBLE = '1'.
*        ENDIF.
**} SRM2404-03220 - e
*
**_ 승인/반려
*      WHEN GC_ZVBO5.
*        IF SCREEN-GROUP1 = 'G1'.
*          SCREEN-INPUT = 0.
*        ENDIF.
**{ SRM2404-03220 - s
*        IF SCREEN-GROUP1 = 'L1'.
*          SCREEN-INVISIBLE = '1'.
*        ENDIF.
**} SRM2404-03220 - e
*
**_승인후 변경(권한자)
*      WHEN GC_ZVBO6.
**-[SRM2406-00779_S
*        IF SCREEN-GROUP1 = 'G1'.
*          SCREEN-INPUT = 0.
*        ENDIF.
*
*        IF SCREEN-GROUP2 = 'G2'.
*          SCREEN-INPUT = 1.
*        ENDIF.
*
*        IF SCREEN-GROUP3 = 'G3'.
*          SCREEN-INPUT = 0.
*        ENDIF.
*
*        IF SCREEN-GROUP4 = 'G4'.
*          SCREEN-INPUT = 1.
*        ENDIF.
**]-SRM2406-00779_E
*
**{ SRM2404-03220 - s
*        IF SCREEN-GROUP1 = 'L1'.
*          SCREEN-INVISIBLE = '0'.
*        ENDIF.
**} SRM2404-03220 - e

    ENDCASE.
    MODIFY SCREEN.
  ENDLOOP.

ENDMODULE.
*&---------------------------------------------------------------------*
*& Module STATUS_0400 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE STATUS_0400 OUTPUT.
  SET PF-STATUS 'S0400'.
  SET TITLEBAR  'T0400'.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module SCREEN_CONTROL_400 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE SCREEN_CONTROL_400 OUTPUT.

  LOOP AT SCREEN.
    IF SCREEN-GROUP1 = 'G3'.
      SCREEN-INPUT = 0.
      MODIFY SCREEN.
    ENDIF.
  ENDLOOP.

ENDMODULE.
*&---------------------------------------------------------------------*
*& Module STATUS_0500 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE STATUS_0500 OUTPUT.
  SET PF-STATUS 'S0500'.
  SET TITLEBAR  'T0500'.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module SCREEN_CONTROL_0500 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE SCREEN_CONTROL_0500 OUTPUT.

*  LOOP AT SCREEN.
*    IF SCREEN-NAME = 'GV_KNUMA'.
*      SCREEN-REQUIRED = 1.
*      MODIFY SCREEN.
*    ENDIF.
*  ENDLOOP.

ENDMODULE.
*&---------------------------------------------------------------------*
*& Module STATUS_0600 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE STATUS_0600 OUTPUT.
  SET PF-STATUS 'S0600'.
  SET TITLEBAR 'T0600'.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module SET_SCREEN OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE SET_SCREEN OUTPUT.

  IF GRID2 IS INITIAL.

    PERFORM CREATE_CONTROLS2.
    PERFORM ALV_ALYOUT2.
    PERFORM GET_KSCHL_COUNT.
    PERFORM FIELDCAT_INIT2.
    PERFORM DISPLAY_DATA.

  ELSE.

    CALL METHOD : GRID2->REFRESH_TABLE_DISPLAY.

  ENDIF.


ENDMODULE.
*&---------------------------------------------------------------------*
*& Module SET_LONGTEXT OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE SET_LONGTEXT OUTPUT.

  CHECK  GV_ZSA1 = ' '.

  IF G_EDITOR IS INITIAL.
    CREATE OBJECT G_CUSTOM_CONTAINER3
      EXPORTING
        CONTAINER_NAME = 'TEXT_CON'.

    CREATE OBJECT G_EDITOR
      EXPORTING
        WORDWRAP_MODE              = 2
        WORDWRAP_POSITION          = 72
        WORDWRAP_TO_LINEBREAK_MODE = CL_GUI_TEXTEDIT=>TRUE
        PARENT                     = G_CUSTOM_CONTAINER3.
  ENDIF.


  CASE SY-TCODE.
*__ ZVBO2 - 승인요청 할때 첨언 입력 가능
    WHEN 'ZVBO2'.
*__ 요청승인 혹은 요청승인진행중일 시 변경 불가능
      IF GV_APRV_STAT = 'P' OR GV_APRV_STAT = 'C'.
        PERFORM SET_LONGTEXT_TABLE USING 1.
      ELSE.
*__ 승인요청 전에 첨언 변경 가능
        PERFORM SET_LONGTEXT_TABLE USING 0.
        PERFORM GET_TEXT USING 0.
      ENDIF.

*__ ZVBO5 - 승인/반려시 첨언 입력 가능
    WHEN 'ZVBO5'.
      PERFORM SET_LONGTEXT_TABLE USING 0.


    WHEN OTHERS.  "나머지는 첨언 변경 불가능
      PERFORM SET_LONGTEXT_TABLE USING 1.

  ENDCASE.

ENDMODULE.
