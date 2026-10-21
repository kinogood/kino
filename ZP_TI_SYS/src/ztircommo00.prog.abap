************************************************************************
* Title         :  ZTIRCOMMO00                                         *
*                                                                      *
* Description   : 수입 공용 PBO Module Include                         *
*                                                                      *
* Creation Date : 2003/07/11                                           *
*                                                                      *
* Author        : SeogBong, Kang                                       *
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
*&      Module  pbo_scr2000_set_status  OUTPUT
*&---------------------------------------------------------------------*
MODULE PBO_SCR2000_SET_STATUS OUTPUT.

  FREE FTAB.

*> TCODE별 메뉴 SET.
  PERFORM  SET_FUNCTION_BY_TCODE.

*> SCREEN별 메뉴 SET.
  PERFORM  SET_FUNCTION_BY_SCREEN.

*> 업무영역별 메뉴 SET.
  PERFORM  SET_FUNCTION_BY_BUSINESS.

  SET PF-STATUS 'NORMAL' EXCLUDING FTAB.
*
  PERFORM  SET_TITLEBAR_BY_SCREEN.

ENDMODULE.                 " pbo_scr2000_set_status  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  pbo_finished  OUTPUT
*&---------------------------------------------------------------------*
*  OK Code값을 초기화 한다.                                            *
*----------------------------------------------------------------------*
MODULE PBO_FINISHED OUTPUT.

  IF SY-DYNNR EQ C_SCR2000.
    CALL METHOD G_DEFAULT_VIEW->HANDLE_EVENT( 'PBO_FINISHED' ).
  ENDIF.

  CLEAR: OK_CODE, SY-UCOMM, OK_CODE_OLD,
         G_FIELDNAME, G_FINDSCR, G_FINDLINE, G_ZTERM_MODIFY.

ENDMODULE.                 " event_pbo_finished  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  PBO_SCR2000_SET_SUBSCREEN  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE PBO_SCR2000_SET_SUBSCREEN OUTPUT.

* perform pbo_scr2000_set_subscreen.
  G_CALL_PROG  = SY-CPROG.

  CASE SY-DYNNR.
    WHEN C_SCR2000.
      IF G_BUTTON1 EQ 'Y'.
        G_CALL_SUBSCREEN = SY-DYNNR + 100.
      ELSE.
        G_CALL_SUBSCREEN = SY-DYNNR + 101.
      ENDIF.
    WHEN C_SCR2100 OR C_SCR2101.
      IF G_EDI_SCREEN EQ C_TRUE.
        G_CALL_SUBSCREEN = C_SCR2100 + 100.
      ELSE.
        IF G_LEVEL EQ 1.   ">Header Level
          IF G_BUTTON1 EQ 'Y'.
            G_CALL_SUBSCREEN = C_SCR2100 + 20.
          ELSE.
            G_CALL_SUBSCREEN = C_SCR9999.
          ENDIF.
        ELSE.              ">Items Level
          IF G_BUTTON1 EQ 'Y'.
            G_CALL_SUBSCREEN = C_SCR2100 + 30.
          ELSE.
            G_CALL_SUBSCREEN = C_SCR2100 + 30.
          ENDIF.
        ENDIF.
        G_LEVEL = G_LEVEL + 1.
      ENDIF.
  ENDCASE.

ENDMODULE.                 " PBO_SCR2000_SET_SUBSCREEN  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  pbo_scr2100_sub0_subscreen  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE PBO_SCR2100_SUB0_SUBSCREEN OUTPUT.

  G_LEVEL = 1.
  G_CALL_PROG  = SY-CPROG.
  G_CALL_SUBSCREEN = C_SCR9998.

ENDMODULE.                 " pbo_scr2100_sub0_subscreen  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  TABSTRIP_ACTIVE_TAB_SET  OUTPUT
*&---------------------------------------------------------------------*
*> OUTPUT MODULE FOR TS 'TABSTRIP'. DO NOT CHANGE THIS LINE!
*> SETS ACTIVE TAB
*----------------------------------------------------------------------*
MODULE TABSTRIP_ACTIVE_TAB_SET OUTPUT.

  LOOP AT SCREEN.
    IF SCREEN-NAME EQ 'TABSTRIP_TAB8'.
      IF G_HISTORY EQ C_TRUE.
        SCREEN-INPUT      =  C_CHAR1.
        SCREEN-INVISIBLE  =  C_CHAR0.
      ELSE.
        SCREEN-INPUT      =  C_CHAR0.
        SCREEN-INVISIBLE  =  C_CHAR1.
        MODIFY SCREEN.
      ENDIF.
    ENDIF.
    IF SCREEN-NAME EQ 'TABSTRIP_TAB7'.
      IF G_HISTORY_COST EQ C_TRUE.
        SCREEN-INPUT      =  C_CHAR1.
        SCREEN-INVISIBLE  =  C_CHAR0.
      ELSE.
        SCREEN-INPUT      =  C_CHAR0.
        SCREEN-INVISIBLE  =  C_CHAR1.
        MODIFY SCREEN.
      ENDIF.
    ENDIF.
*> 수입제비용일 경우.
    IF G_DOCUMENT     EQ C_CS AND
       SCREEN-NAME EQ 'TABSTRIP_TAB3'.
      IF G_HISTORY EQ C_TRUE.
        SCREEN-INPUT      =  C_CHAR1.
        SCREEN-INVISIBLE  =  C_CHAR0.
        MODIFY SCREEN.
      ELSE.
        SCREEN-INPUT      =  C_CHAR0.
        SCREEN-INVISIBLE  =  C_CHAR1.
        MODIFY SCREEN.
      ENDIF.
    ENDIF.
*> 컨테이너 탭 활성을 위해.
    IF G_DOCUMENT     EQ C_BL.
      IF SCREEN-NAME EQ 'TABSTRIP_TAB2'.
        IF ZTITIG00-CNTYN EQ C_TRUE.

          IF ZTITBLK-FWDTY EQ C_CHARA.
            SCREEN-INPUT      =  C_CHAR0.
            SCREEN-INVISIBLE  =  C_CHAR1.
            MODIFY SCREEN.
          ELSE.
            SCREEN-INPUT      =  C_CHAR1.
            SCREEN-INVISIBLE  =  C_CHAR0.
            MODIFY SCREEN.
          ENDIF.
        ELSE.
          SCREEN-INPUT      =  C_CHAR0.
          SCREEN-INVISIBLE  =  C_CHAR1.
          MODIFY SCREEN.
        ENDIF.
      ENDIF.
    ENDIF.

*> EDI 항목 활성화를 위해.
    IF G_DOCUMENT     EQ C_CC OR
       G_DOCUMENT     EQ C_CR.
      IF SCREEN-NAME EQ 'TABSTRIP_TAB4'.
        IF ZTITIG00-CCDCL IS INITIAL.
          SCREEN-INPUT      =  C_CHAR1.
          SCREEN-INVISIBLE  =  C_CHAR0.
          MODIFY SCREEN.
        ELSE.
          SCREEN-INPUT      =  C_CHAR0.
          SCREEN-INVISIBLE  =  C_CHAR1.
          MODIFY SCREEN.
        ENDIF.
      ELSEIF SCREEN-NAME EQ 'TABSTRIP_TAB1' OR
             SCREEN-NAME EQ 'TABSTRIP_TAB2'.
        IF ZTITIG00-CCDCL IS INITIAL.
          SCREEN-INPUT      =  C_CHAR0.
          SCREEN-INVISIBLE  =  C_CHAR1.
          MODIFY SCREEN.
        ELSE.
          SCREEN-INPUT      =  C_CHAR1.
          SCREEN-INVISIBLE  =  C_CHAR0.
          MODIFY SCREEN.
        ENDIF.
      ENDIF.
    ENDIF.
*> 포워더 탭 활성화를 위해.
    IF G_DOCUMENT     EQ C_LC.
*> 포워더 탭 활성화를 위해.
*      IF ZTITRQK-reqty EQ c_lc.
      IF SCREEN-NAME EQ 'TABSTRIP_TAB3'.
        IF ZTITRQK-FWDAS EQ C_TRUE.
          SCREEN-INPUT      =  C_CHAR1.
          SCREEN-INVISIBLE  =  C_CHAR0.
          MODIFY SCREEN.
        ELSE.
          SCREEN-INPUT      =  C_CHAR0.
          SCREEN-INVISIBLE  =  C_CHAR1.
          MODIFY SCREEN.
        ENDIF.
*        ENDIF.
      ELSE.
        IF SCREEN-NAME EQ 'TABSTRIP_TAB3'.
          SCREEN-INPUT      =  C_CHAR0.
          SCREEN-INVISIBLE  =  C_CHAR1.
          MODIFY SCREEN.
        ENDIF.
      ENDIF.

*> 지급확인서 관련 탭 활성화를 위해.
      IF SCREEN-NAME EQ 'TABSTRIP_TAB4'.
        IF ZTITRQK-ANBTY EQ C_CHARA  OR  ">사후송금이거나.
           ZTITRQK-TDPYN EQ C_TRUE.      ">중계무역일 경우.
          SCREEN-INPUT      =  C_CHAR1.
          SCREEN-INVISIBLE  =  C_CHAR0.
          MODIFY SCREEN.
        ELSE.
          SCREEN-INPUT      =  C_CHAR0.
          SCREEN-INVISIBLE  =  C_CHAR1.
          MODIFY SCREEN.
        ENDIF.
      ELSE.
        IF SCREEN-NAME EQ 'TABSTRIP_TAB4'.
          SCREEN-INPUT      =  C_CHAR0.
          SCREEN-INVISIBLE  =  C_CHAR1.
          MODIFY SCREEN.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDLOOP.

  TABSTRIP-ACTIVETAB = G_TABSTRIP-PRESSED_TAB.
  G_TABSTRIP-PROG = SY-CPROG.

  CASE G_TABSTRIP-PRESSED_TAB.
    WHEN C_TABSTRIP-TAB1.
      G_TABSTRIP-SUBSCREEN = C_SCR2121.
    WHEN C_TABSTRIP-TAB2.
      G_TABSTRIP-SUBSCREEN = C_SCR2122.
    WHEN C_TABSTRIP-TAB3.
      G_TABSTRIP-SUBSCREEN = C_SCR2123.
    WHEN C_TABSTRIP-TAB4.
      G_TABSTRIP-SUBSCREEN = C_SCR2124.
    WHEN C_TABSTRIP-TAB5.
      G_TABSTRIP-SUBSCREEN = C_SCR2125.
    WHEN C_TABSTRIP-TAB6.
      G_TABSTRIP-SUBSCREEN = C_SCR2126.
    WHEN C_TABSTRIP-TAB7.
*> 이력데이타 Put
      CALL FUNCTION 'Z_TI_COST_DOCUMENTS_EXPORT'
        TABLES
          XCOST = IT_COSTDOC.

      G_TABSTRIP-PROG      = C_COMMON_PROG.
      G_TABSTRIP-SUBSCREEN = C_SCR2127.

    WHEN C_TABSTRIP-TAB8.
      G_TABSTRIP-PROG      = C_COMMON_PROG.
      G_TABSTRIP-SUBSCREEN = C_SCR2128.
*> 이력데이타 Put
      CALL FUNCTION 'Z_TI_DOCUMENT_HISTORY_EXPORT'
        TABLES
          XDOCHIS = IT_DOCHIS.

    WHEN C_TABSTRIP-TAB9.
      G_TEXTOBJECT         = C_TEXTOBJECT_HEADER.
      G_TABSTRIP-PROG      = C_TEXT_PROG.
      G_TABSTRIP-SUBSCREEN = C_SCR0100.

      READ TABLE GT_CONTROL WITH KEY OBJECT = C_TEXTOBJECT_HEADER.
      IF SY-SUBRC EQ 0.
        IT_TEXTTYPES[] = GT_CONTROL-TEXTTYPES[].
        IT_ALL_LINES[] = GT_CONTROL-TEXTLINES[].
      ENDIF.

      CALL FUNCTION 'Z_TS_TEXT_EXP_SUBSCREEN'
        EXPORTING
          IM_TEXTOBJECT = C_TEXTOBJECT_HEADER
        TABLES
          IMT_TEXTTYPES = IT_TEXTTYPES
          IMT_TEXTLINES = IT_ALL_LINES.
    WHEN OTHERS.
  ENDCASE.

ENDMODULE.                    "TABSTRIP_ACTIVE_TAB_SET OUTPUT

*&---------------------------------------------------------------------*
*&      Module  PBO_SCR9998_ICON_CREATE  OUTPUT
*&---------------------------------------------------------------------*
MODULE PBO_SCR9998_ICON_CREATE OUTPUT.

  DATA:  L_QUICKINFO         TYPE ICONT-QUICKINFO,
         L_USE_STD_QUICKINFO LIKE ICON-INTERNAL,
         L_ICON              LIKE ICON-NAME.

  CASE G_CALL_BUTTON.
    WHEN '1'.
      IF G_BUTTON1 EQ 'Y'.
        L_ICON = ICON_DATA_AREA_COLLAPSE.
      ELSE.
        L_ICON = ICON_DATA_AREA_EXPAND.
      ENDIF.
      L_QUICKINFO = '헤더'.
    WHEN '2'.
*      IF W_BUTTON2 EQ 'Y'.
*        L_ICON = ICON_DATA_AREA_COLLAPSE.
*      ELSE.
*        L_ICON = ICON_DATA_AREA_EXPAND.
*      ENDIF.
*      l_quickinfo = '개요'.
    WHEN '3'.
*      IF W_BUTTON3 EQ 'Y'.
*        L_ICON = ICON_DATA_AREA_COLLAPSE.
*      ELSE.
*        L_ICON = ICON_DATA_AREA_EXPAND.
*      ENDIF.
*      l_quickinfo = '품목'.
  ENDCASE.

  IF L_ICON = ICON_DATA_AREA_COLLAPSE.
    CONCATENATE L_QUICKINFO '접기' INTO L_QUICKINFO.
  ELSE.
    CONCATENATE L_QUICKINFO '펼치기' INTO L_QUICKINFO.
  ENDIF.

  L_USE_STD_QUICKINFO = L_QUICKINFO.
*  P_BUTTON =

  PERFORM VALID_PUSHBUTTONS_ICONS_SET
     CHANGING L_ICON
              L_QUICKINFO
              L_USE_STD_QUICKINFO
              G_DYN_9998-BUTTON.

ENDMODULE.                 " PBO_SCR9998_ICON_CREATE  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  SCR2120_GET_OKCODE  INPUT
*&---------------------------------------------------------------------*
MODULE SCR2120_GET_OKCODE INPUT.

  IF G_TABSTRIP-SUBSCREEN EQ C_SCR0100 AND
     G_TABSTRIP-PROG      EQ C_TEXT_PROG.
*> 텍스트 데이타 Put
    CALL FUNCTION 'Z_TS_TEXT_SET_OKCODE'
      EXPORTING
        IM_TEXTOBJECT = C_TEXTOBJECT_HEADER
        IM_OKCODE     = OK_CODE.
  ENDIF.

  IF G_TABSTRIP-SUBSCREEN EQ C_SCR2128 AND
     G_TABSTRIP-PROG      EQ C_COMMON_PROG.
*> 이력데이타 Put
    CALL FUNCTION 'Z_TI_DOCUMENT_HISTORY_EXPORT'
      TABLES
        XDOCHIS = IT_DOCHIS.
  ENDIF.

ENDMODULE.                 " SCR2120_GET_OKCODE  INPUT
*&---------------------------------------------------------------------*
*&      Module  SET_cursor_position  OUTPUT
*&---------------------------------------------------------------------*
*       Cursor를 해당 필드에 Set
*----------------------------------------------------------------------*
MODULE SET_CURSOR_POSITION OUTPUT.

  CHECK NOT G_FINDSCR IS INITIAL.

  CHECK G_FINDSCR EQ SY-DYNNR.

  IF G_FINDLINE IS INITIAL.
    SET CURSOR FIELD G_FIELDNAME.
  ELSE.
    SET CURSOR FIELD G_FIELDNAME LINE G_FINDLINE.
  ENDIF.

ENDMODULE.                 " SET_cursor_position  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  change_field_attribute  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CHANGE_FIELD_ATTRIBUTE OUTPUT.


  LOOP AT  SCREEN .
    CLEAR G_FIELDGROUP.
    CONCATENATE SCREEN-GROUP1 SCREEN-GROUP2
                SCREEN-GROUP3 SCREEN-GROUP4
           INTO G_FIELDGROUP.

    SEARCH G_FIELDGROUP FOR G_MODE.
    IF SY-SUBRC <> 0.
      SCREEN-INPUT = C_CHAR0.
    ELSE.
      SCREEN-INPUT = C_CHAR1.
    ENDIF.
    IF SCREEN-NAME EQ 'G_TC_2150_WA-FLAG' OR
       SCREEN-NAME EQ 'G_TC_2151_WA-FLAG' OR
       SCREEN-NAME EQ 'G_TC_2152_WA-FLAG' OR
       SCREEN-NAME EQ 'G_TC_2130_WA-FLAG' OR
       SCREEN-NAME EQ 'G_TC_2124_WA-FLAG' OR
       SCREEN-NAME EQ 'G_TC_2210_WA-FLAG' OR
       SCREEN-NAME EQ 'G_TC_7000_WA-FLAG' OR
       SCREEN-NAME EQ 'ZTISIVVS-FLAG'.
      SCREEN-INPUT = C_CHAR1.
    ENDIF.
    IF G_DOCUMENT EQ C_PN.
      IF NOT ( ZTITRQK-REQTY EQ 'LO' OR
               ZTITRQK-REQTY EQ 'PU' ).
        IF SCREEN-NAME EQ 'ZTISPNIT-PNMNG'.
          SCREEN-INPUT = C_CHAR0.
        ENDIF.
      ENDIF.
    ENDIF.

    MODIFY SCREEN.
  ENDLOOP.

ENDMODULE.                 " change_field_attribute  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  pbo_scr2000_set_init  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE PBO_SCR2000_SET_INIT OUTPUT.

  IF NOT G_ALV_TREE IS INITIAL.
    IF G_INIT IS INITIAL.
* will be turned into a public method in a while
* if you use the esdus-personalization, you don't need to
* switch the tree on manually, enter fcode metron once and
* the tree appears, exit the transaction and it will be saved
* that the tree should be on
* by the way: fcode METRON : switch it on
*                   METROF : switch it off
      DATA: L_FCODE LIKE SY-UCOMM VALUE 'METRON'.
*      CALL METHOD g_alv_tree->execute( CHANGING im_fcode = l_fcode ).
      L_FCODE = 'METROF'.
      CALL METHOD G_ALV_TREE->EXECUTE( CHANGING IM_FCODE = L_FCODE ).
      CALL METHOD G_ALV_TREE->UPDATE_TREE_DISPLAY.

      IF L_FCODE EQ 'METROF'.
        CALL METHOD G_DOCKING->SET_VISIBLE
          EXPORTING
            VISIBLE           = '0'
          EXCEPTIONS
            CNTL_SYSTEM_ERROR = 1
            CNTL_ERROR        = 2.
      ENDIF.
      G_INIT = 'X'.
    ELSE.
*   give the tree a chance to update itself
*   must be during PBO due to the Control-Framework !
      CALL METHOD G_ALV_TREE->UPDATE_TREE_DISPLAY.
    ENDIF.
  ENDIF.

ENDMODULE.                 " pbo_scr2000_set_init  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  set_shopping_basket_pbo  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE SET_SHOPPING_BASKET_PBO OUTPUT.

  CALL METHOD G_SHOPPING_BASKET->PBO( ).

ENDMODULE.                 " set_shopping_basket_pbo  OUTPUT
