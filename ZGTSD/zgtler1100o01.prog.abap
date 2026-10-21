*----------------------------------------------------------------------*
***INCLUDE ZLER0401O01 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE STATUS_0100 OUTPUT.

  CLEAR   : GT_EXCL.
  REFRESH : GT_EXCL.

  CASE GV_TRTYP.
    WHEN 'H'.      "생성
      GT_EXCL-FCODE = 'SAVE'.   APPEND GT_EXCL.
      GT_EXCL-FCODE = 'SDCFM'.  APPEND GT_EXCL.
      GT_EXCL-FCODE = 'RDEL'.   APPEND GT_EXCL.
      GT_EXCL-FCODE = 'DISP'.   APPEND GT_EXCL.
      GT_EXCL-FCODE = 'DDIS'.   APPEND GT_EXCL.

    WHEN 'V'.      "변경
      GT_EXCL-FCODE = 'CREA'.   APPEND GT_EXCL.
      GT_EXCL-FCODE = 'DISP'.   APPEND GT_EXCL.
*      GT_EXCL-FCODE = 'DDIS'.   APPEND GT_EXCL.

    WHEN 'A'.      "조회
      GT_EXCL-FCODE = 'SAVE'.   APPEND GT_EXCL.
      GT_EXCL-FCODE = 'SDCFM'.  APPEND GT_EXCL.
      GT_EXCL-FCODE = 'RDEL'.   APPEND GT_EXCL.
      GT_EXCL-FCODE = 'CREA'.   APPEND GT_EXCL.
      GT_EXCL-FCODE = 'DCHG'.   APPEND GT_EXCL.
      GT_EXCL-FCODE = 'ASEL'.   APPEND GT_EXCL.
      GT_EXCL-FCODE = 'DSEL'.   APPEND GT_EXCL.

  ENDCASE.

  SET PF-STATUS '0100' EXCLUDING GT_EXCL.
  SET TITLEBAR  '0100' WITH GV_TITLE.

ENDMODULE.                 " STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  CREATE_ALV_GRID  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CREATE_ALV_GRID OUTPUT.

  IF GC_CUSTOM_CONTAINER IS INITIAL.
    CREATE OBJECT GC_CUSTOM_CONTAINER
        EXPORTING
            CONTAINER_NAME = GC_CONTAINER_NAME.

    CREATE OBJECT GC_ALV_GRID
        EXPORTING
            I_PARENT      = GC_CUSTOM_CONTAINER
            I_APPL_EVENTS = 'X'.

    PERFORM SET_GRID_LAYO.

    PERFORM SET_GRID_FCAT.

*___색상 삽입 및 셀 속성 제어
    PERFORM SET_CELL_ATTRIBUTE.

*___필요한 function만 삽입
    PERFORM EXCLUDE_TB_FUNCTIONS CHANGING GT_EXCLUDE.

*___Edit Event 및  Event Handler 등록
    PERFORM EVENT_HANDLER_REGISTER.

*___화면 Display
    PERFORM SET_TABLE_FOR_FIRST_DISPLAY.
  ELSE.
    PERFORM SET_CELL_ATTRIBUTE.

    GS_SCROLL-ROW = 'X'.
    GS_SCROLL-COL = 'X'.

    CALL METHOD GC_ALV_GRID->REFRESH_TABLE_DISPLAY
      EXPORTING
        I_SOFT_REFRESH = ' '
        IS_STABLE      = GS_SCROLL.     "화면 라인 Refresh
  ENDIF.

  PERFORM SET_SELECTED_ROWS.

*___Upload한 경우 메시지 팝업창 표시
  IF GV_MSG IS NOT INITIAL.
    CLEAR : GV_MSG.

    CALL FUNCTION 'MESSAGES_SHOW'
        EXPORTING
          show_linno = space.
  ENDIF.

ENDMODULE.                 " CREATE_ALV_GRID  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  STATUS_0200  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE STATUS_0200 OUTPUT.

  CLEAR   : GT_EXCL.
  REFRESH : GT_EXCL.

  IF GV_TRTYP = 'A' OR GV_DISP = 'X'.
    GV_TITLE1     = '조회'.
    GT_EXCL-FCODE = 'CHNG'.    APPEND GT_EXCL.
    GT_EXCL-FCODE = 'ACPT'.    APPEND GT_EXCL.
    GT_EXCL-FCODE = 'CNAC'.    APPEND GT_EXCL.
  ELSE.
    GV_TITLE1     = '변경'.

    IF GV_TRTYP = 'H' OR SY-TCODE = GC_TCODE2 OR GT_MAIN-TRADE = 'D'.
      GT_EXCL-FCODE = 'ACPT'.    APPEND GT_EXCL.
      GT_EXCL-FCODE = 'CNAC'.    APPEND GT_EXCL.

      IF GT_0406-SACPT = 'X'.
        GT_EXCL-FCODE = 'CHNG'.    APPEND GT_EXCL.
      ENDIF.
    ELSE.
      IF GT_0406-SACPT = 'X'.
        GT_EXCL-FCODE = 'CHNG'.    APPEND GT_EXCL.
        GT_EXCL-FCODE = 'ACPT'.    APPEND GT_EXCL.
      ELSE.
        GT_EXCL-FCODE = 'CNAC'.    APPEND GT_EXCL.
      ENDIF.
    ENDIF.
  ENDIF.

  IF GT_0406-DLVRQ IS NOT INITIAL.
    CONCATENATE GV_TITLE1 '-' GT_0406-DLVRQ
           INTO GV_TITLE1 SEPARATED BY SPACE.
  ENDIF.

  SET PF-STATUS '0200' EXCLUDING GT_EXCL.
  SET TITLEBAR  '0200' WITH GV_TITLE1.

ENDMODULE.                 " STATUS_0200  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  STATUS_0300  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE STATUS_0300 OUTPUT.

  SET PF-STATUS '0300'.
  SET TITLEBAR  '0300'.

ENDMODULE.                 " STATUS_0300  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  CREATE_ALV_GRID_0300  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CREATE_ALV_GRID_0300 OUTPUT.

  IF GC_CUSTOM_CONTAINER1 IS INITIAL.
    CREATE OBJECT GC_CUSTOM_CONTAINER1
        EXPORTING
            CONTAINER_NAME = GC_CONTAINER_NAME1.

    CREATE OBJECT GC_ALV_GRID1
        EXPORTING
            I_PARENT      = GC_CUSTOM_CONTAINER1
            I_APPL_EVENTS = 'X'.

    PERFORM SET_GRID_LAYO.

    PERFORM SET_GRID_FCAT_1.

*___필요한 function만 삽입
    PERFORM EXCLUDE_TB_FUNCTIONS CHANGING GT_EXCLUDE.

*___Edit Event 및  Event Handler 등록
    PERFORM EVENT_HANDLER_REGISTER_1.

*___화면 Display
    PERFORM SET_TABLE_FOR_FIRST_DISPLAY_1.
  ELSE.
    GS_SCROLL-ROW = 'X'.
    GS_SCROLL-COL = 'X'.

    CALL METHOD GC_ALV_GRID1->REFRESH_TABLE_DISPLAY
      EXPORTING
        I_SOFT_REFRESH = ' '
        IS_STABLE      = GS_SCROLL.     "화면 라인 Refresh
  ENDIF.

ENDMODULE.                 " CREATE_ALV_GRID_0300  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  SET_SCREEN_ATTRIBUTE_0200  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE SET_SCREEN_ATTRIBUTE_0200 OUTPUT.

  LOOP AT SCREEN.
    IF GV_TRTYP <> 'A' AND GV_DISP <> 'X'.
      IF ( SCREEN-GROUP1 = 'G11' AND GS_DELV-ARIND <> 'X' ).
*      IF ( SCREEN-GROUP1 = 'G11' AND GS_DELV-ARIND <> 'X' ) OR
*         ( SCREEN-GROUP1 = 'G21' AND GT_MAIN-TRADE <> 'E' ).
        SCREEN-INPUT = 0.
      ENDIF.

      IF SCREEN-GROUP2 = 'G21' AND GT_MAIN-TRADE = 'E'.
        SCREEN-REQUIRED = 0.
      ENDIF.

      IF GT_MAIN-TRADE = 'E' AND GT_0406-SACPT = 'X'.
        SCREEN-INPUT = 0.
      ENDIF.
    ELSE.

      SCREEN-INPUT = 0.
    ENDIF.

    IF SCREEN-GROUP1 EQ 'G18'. "직송의뢰 신청 유형
      IF GV_TRTYP EQ 'H'.
        SCREEN-INPUT = 1.
      ELSE.
        SCREEN-INPUT = 0.
      ENDIF.
    ENDIF.

    MODIFY SCREEN.
  ENDLOOP.

ENDMODULE.                 " SET_SCREEN_ATTRIBUTE_0200  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  SET_SCREEN_ATTRIBUTE_0201  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE SET_SCREEN_ATTRIBUTE_0201 OUTPUT.

  LOOP AT SCREEN.
    IF GV_TRTYP <> 'A' AND GV_DISP <> 'X'.
      CASE SCREEN-GROUP1.
        WHEN 'G11'.    "결제방법
*          IF GT_0406-PAYMT <> 'L/C'.
*            SCREEN-INPUT = 0.
*          ENDIF.

        WHEN 'G12'.    "Container Simulation
          IF GT_0406-CNTSM <> 'X'.
            SCREEN-INPUT = 0.
          ENDIF.

        WHEN 'G13'.    "리텐션
          IF GT_0406-RETNT <> 'X'.
            SCREEN-INPUT = 0.
          ENDIF.

        WHEN 'G14'.    "수출보험
          IF GT_0406-INSUR <> 'X'.
            SCREEN-INPUT = 0.
          ENDIF.

        WHEN 'G15'.    "커미션
          IF GT_0406-COMMS <> 'X'.
            SCREEN-INPUT = 0.
          ENDIF.

        WHEN 'G16'.    "입회검사
          IF GT_0406-INSPC <> 'X'.
            SCREEN-INPUT = 0.
          ENDIF.

        WHEN 'G17'.    "운송유형
          IF GT_0406-TRTYP1 <> 'O'.  "Ocean
            SCREEN-INPUT = 0.
          ENDIF.

      ENDCASE.

      IF GT_0406-SACPT = 'X'.
        SCREEN-INPUT = 0.
      ENDIF.
    ELSE.
      SCREEN-INPUT = 0.
    ENDIF.

    MODIFY SCREEN.
  ENDLOOP.

ENDMODULE.                 " SET_SCREEN_ATTRIBUTE_0201  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  SET_CURSOR  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE SET_CURSOR OUTPUT.

  CASE SY-DYNNR.
    WHEN '0200'.
     IF GV_CURSOR1 IS NOT INITIAL.
       SET CURSOR FIELD GV_CURSOR1.
     ENDIF.

    WHEN OTHERS.
     IF GV_CURSOR2 IS NOT INITIAL.
       SET CURSOR FIELD GV_CURSOR2.
     ENDIF.

   ENDCASE.

ENDMODULE.                 " SET_CURSOR  OUTPUT
