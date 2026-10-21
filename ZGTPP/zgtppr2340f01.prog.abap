*&---------------------------------------------------------------------*
*& Include          ZGTPPR2340F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form AUTHORITY_CHECKING_PROC
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM AUTHORITY_CHECKING_PROC .

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_PROC
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_PROC .

  PERFORM GET_INIT_DATA.

*  CASE ABAP_TRUE.
*    WHEN P_RAD01.
  PERFORM GET_DATA_FROM_PP.
  REFRESH GT_MAIN_DISP.
  GT_MAIN_DISP = GT_MAIN_DISP2.
*    WHEN P_RAD02.
*  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Module CREATE_ALV_0100 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE CREATE_ALV_0100 OUTPUT.
  IF GO_GRID_0100 IS NOT BOUND.
    PERFORM SET_OBJECT_GRID_0100.
    PERFORM SET_LAYOUT_GRID_0100.
    PERFORM SET_FIELDCAT_GRID_0100.
    PERFORM EVENT_HANDLER_REGISTER USING GO_GRID_0100.
*    PERFORM SET_SORTTAB_GRID_0100.
    PERFORM SET_CELL_ATTRIBUTE_GRID_0100.
    PERFORM EXCLUDE_OF_TOOLBAR_GRID_0100.
    PERFORM CALL_GRID_0100_DISPLAY.
  ENDIF.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Form SET_OBJECT_GRID_0100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_OBJECT_GRID_0100 .

  CREATE OBJECT GO_CONTAIN_0100
    EXPORTING
      REPID                       = SY-REPID
      DYNNR                       = SY-DYNNR
      EXTENSION                   = 10000
    EXCEPTIONS
      CNTL_ERROR                  = 1
      CNTL_SYSTEM_ERROR           = 2
      CREATE_ERROR                = 3
      LIFETIME_ERROR              = 4
      LIFETIME_DYNPRO_DYNPRO_LINK = 5.

  CREATE OBJECT GO_GRID_0100
    EXPORTING
      I_PARENT      = GO_CONTAIN_0100
      I_APPL_EVENTS = ABAP_TRUE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_LAYOUT_GRID_0100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_LAYOUT_GRID_0100 .

  DATA : LV_TEXT1 TYPE CHAR100.
  DATA : LV_TEXT2 TYPE CHAR100.

  CLEAR GS_LAYOUT_0100.
  GS_LAYOUT_0100-CWIDTH_OPT = ABAP_TRUE.
  GS_LAYOUT_0100-NO_ROWINS = ABAP_TRUE.
*  GS_LAYOUT_0100-NO_ROWMARK   = 'X'.
  GS_LAYOUT_0100-SEL_MODE   = 'D'.
  GS_LAYOUT_0100-ZEBRA   = ABAP_TRUE.
  GS_LAYOUT_0100-STYLEFNAME = 'CELLTAB'.

  GS_LAYOUT_0100-SMALLTITLE = 'X'.
  CLEAR LV_TEXT1.
  CONCATENATE '플랜트 :' P_WERKS GV_NAME1 INTO LV_TEXT1 SEPARATED BY SPACE.
  LV_TEXT1 = LV_TEXT1 && ','.

  CLEAR LV_TEXT2.
  CONCATENATE '저장위치 :' P_LGORT GV_LGOBE INTO LV_TEXT2 SEPARATED BY SPACE.

  CONCATENATE LV_TEXT1 LV_TEXT2 INTO GS_LAYOUT_0100-GRID_TITLE SEPARATED BY SPACE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_FIELDCAT_GRID_0100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_FIELDCAT_GRID_0100 .

  DATA : LT_FCAT_SLIS TYPE SLIS_T_FIELDCAT_ALV.
  FIELD-SYMBOLS : <LS_FCAT> TYPE LVC_S_FCAT..

  DEFINE __SET_CHART_FCAT.
    READ TABLE gt_fieldcat_0100 ASSIGNING <ls_fcat> WITH KEY fieldname = &1.
    IF sy-subrc NE 0.
      APPEND INITIAL LINE TO gt_fieldcat_0100 ASSIGNING <ls_fcat>.
      <ls_fcat>-fieldname = &1.
      <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = <ls_fcat>-fieldname.
      <ls_fcat>-col_pos = &2.
      <ls_fcat>-datatype = 'CHAR'.
      <ls_fcat>-dd_outlen = '40'.
    ENDIF.
  END-OF-DEFINITION.

  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      I_PROGRAM_NAME         = SY-REPID
      I_INCLNAME             = 'ZGTPPR2340TOP'
      I_INTERNAL_TABNAME     = 'GS_MAIN_DISP'
    CHANGING
      CT_FIELDCAT            = LT_FCAT_SLIS
    EXCEPTIONS
      INCONSISTENT_INTERFACE = 1
      PROGRAM_ERROR          = 2
      OTHERS                 = 3.

*-- lt_fieldcat의 구조체를 pt_fcat의 구조체로 변경
  CALL FUNCTION 'LVC_TRANSFER_FROM_SLIS'
    EXPORTING
      IT_FIELDCAT_ALV = LT_FCAT_SLIS
    IMPORTING
      ET_FIELDCAT_LVC = GT_FIELDCAT_0100[]
    TABLES
      IT_DATA         = GT_MAIN_DISP
    EXCEPTIONS
      OTHERS          = 1.

  READ TABLE GT_FIELDCAT_0100 ASSIGNING <LS_FCAT> WITH KEY FIELDNAME = 'ZTYPE'.
  IF SY-SUBRC NE 0.
    APPEND INITIAL LINE TO GT_FIELDCAT_0100 ASSIGNING <LS_FCAT>.
    <LS_FCAT>-FIELDNAME = 'ZTYPE'.
    <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = <LS_FCAT>-FIELDNAME.
    <LS_FCAT>-COL_POS = 6.
    <LS_FCAT>-DATATYPE = 'CHAR'.
    <LS_FCAT>-DD_OUTLEN = '2'.
  ENDIF.

  READ TABLE GT_FIELDCAT_0100 ASSIGNING <LS_FCAT> WITH KEY FIELDNAME = 'CHK_OEM'.
  IF SY-SUBRC NE 0.
    APPEND INITIAL LINE TO GT_FIELDCAT_0100 ASSIGNING <LS_FCAT>.
    <LS_FCAT>-FIELDNAME = 'CHK_OEM'.
    <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = 'PR 생성'(f41).
    <LS_FCAT>-COL_POS = 10.
    <LS_FCAT>-DATATYPE = 'CHAR'.
    <LS_FCAT>-DD_OUTLEN = '1'.
    <LS_FCAT>-JUST = 'C'.
    <LS_FCAT>-CHECKBOX = ABAP_TRUE.
  ENDIF.

  READ TABLE GT_FIELDCAT_0100 ASSIGNING <LS_FCAT> WITH KEY FIELDNAME = 'MESSAGE'.
  IF SY-SUBRC NE 0.
    APPEND INITIAL LINE TO GT_FIELDCAT_0100 ASSIGNING <LS_FCAT>.
    <LS_FCAT>-FIELDNAME = 'MESSAGE'.
    <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = <LS_FCAT>-FIELDNAME.
    <LS_FCAT>-COL_POS = 12.
    <LS_FCAT>-DATATYPE = 'CHAR'.
    <LS_FCAT>-DD_OUTLEN = '100'.
  ENDIF.



  __SET_CHART_FCAT : 'ZCOLOR__BASE' 13,
                     'ZCOLOR_DTL' 14,
                     'ZCOLOR_STR' 15,
                     'ZCOLOR_STRN' 16,
                     'SKID_YN' 35,
                     'DRUM_GUBUN' 36,
                     'PACK_METHOD' 37,
                     'PROT_YN' 38,
                     'PRINT_METHOD' 39,
                     'NEW_DRUM_YN' 40,
                     'WRAP_YN' 41.

  <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '선택'(f01).

  LOOP AT GT_FIELDCAT_0100 ASSIGNING <LS_FCAT>.
    CLEAR <LS_FCAT>-KEY.
    CASE   <LS_FCAT>-FIELDNAME.
      WHEN 'VBELN'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '판매오더번호'(f01).
        <LS_FCAT>-JUST = 'C'.
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
      WHEN 'POSNR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '판매오더품목'(f02).
        <LS_FCAT>-JUST = 'C'.
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
      WHEN 'MATNR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '품목코드'(f03).
        <LS_FCAT>-JUST = 'C'.
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
      WHEN 'MAKTX'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '품목내역'(f04).
        <LS_FCAT>-JUST = 'L'.
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
      WHEN 'ZZSPEC_NO'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = 'Spec No'(f05).
        <LS_FCAT>-JUST = 'C'.
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
      WHEN 'ZTYPE'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '유형'(f06).
        <LS_FCAT>-JUST = 'C'.
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
      WHEN 'LIFSP'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '납품보류'(f07).
        <LS_FCAT>-JUST = 'C'.
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
      WHEN 'VTEXT'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '납품보류 내역'(f08).
        <LS_FCAT>-JUST = 'L'.
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
      WHEN 'FIXMG'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '재고 사용(SM)'(f09).
        <LS_FCAT>-JUST = 'C'.
        <LS_FCAT>-CHECKBOX = ABAP_TRUE.
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
      WHEN 'STATUS'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '처리 상태'(f10).
        <LS_FCAT>-JUST = 'C'.
        <LS_FCAT>-ICON = ABAP_TRUE.
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
      WHEN 'MESSAGE'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '처리 메시지'(f11).
        <LS_FCAT>-JUST = 'L'.
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
      WHEN 'ZCOLOR__BASE'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '색상(BASE)'(f12).
        <LS_FCAT>-JUST = 'C'.
      WHEN 'ZCOLOR_DTL'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '색상(상세)'(f13).
        <LS_FCAT>-JUST = 'C'.
      WHEN 'ZCOLOR_STR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '색상(Stripe)'(f14).
        <LS_FCAT>-JUST = 'C'.
      WHEN 'ZCOLOR_STRN'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '색상(Stripe)수'(f15).
        <LS_FCAT>-JUST = 'C'.
      WHEN 'MTART'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '자재유형'(f16).
        <LS_FCAT>-JUST = 'C'.
      WHEN 'MATKL'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '자재그룹'(f17).
        <LS_FCAT>-JUST = 'C'.
      WHEN 'ERDAT'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '판매오더 생성일자'(f18).
        <LS_FCAT>-JUST = 'C'.
      WHEN 'EDATU'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '납품일자'(f19).
        <LS_FCAT>-JUST = 'C'.
      WHEN 'ETENR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '일정라인번호'(f20).
        <LS_FCAT>-JUST = 'C'.
      WHEN 'WMENG'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '납품수량'(f21).
        <LS_FCAT>-JUST = 'R'.
      WHEN 'VRKME'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '단위'(f22).
        <LS_FCAT>-JUST = 'C'.
      WHEN 'INLENGTH'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '조장'(f23).
        <LS_FCAT>-JUST = 'R'.
      WHEN 'INFACTOR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '조장 수'(f24).
        <LS_FCAT>-JUST = 'R'.
      WHEN 'LABST2'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '기할당 수량'(f25).
        <LS_FCAT>-JUST = 'R'.
      WHEN 'INFACTOR2'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '기할당 조장 수'(f26).
        <LS_FCAT>-JUST = 'R'.
      WHEN 'KALAB'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '판매오더 재고'(f27).
        <LS_FCAT>-JUST = 'R'.
      WHEN 'KUNNR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '고객번호'(f28).
        <LS_FCAT>-JUST = 'C'.
      WHEN 'NAME1'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '고객명'(f29).
        <LS_FCAT>-JUST = 'L'.
      WHEN 'VTWEG'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '유통경로'(f30).
        <LS_FCAT>-JUST = 'C'.
      WHEN 'SPART'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '제품군'(f31).
        <LS_FCAT>-JUST = 'C'.
      WHEN 'VKGRP'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '영업그룹'(f32).
        <LS_FCAT>-JUST = 'C'.
      WHEN 'VKBUR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '영업팀'(f33).
        <LS_FCAT>-JUST = 'C'.
      WHEN 'SKID_YN'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = 'SKID유무'(f34).
        <LS_FCAT>-JUST = 'C'.
      WHEN 'DRUM_GUBUN'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '드럼구분'(f35).
        <LS_FCAT>-JUST = 'C'.
      WHEN 'PACK_METHOD'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '포장구분'(f36).
        <LS_FCAT>-JUST = 'C'.
      WHEN 'PROT_YN'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '악판골판지'(f37).
        <LS_FCAT>-JUST = 'C'.
      WHEN 'PRINT_METHOD'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '프린트'(f38).
        <LS_FCAT>-JUST = 'C'.
      WHEN 'NEW_DRUM_YN'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '신드럼사용'(f39).
        <LS_FCAT>-JUST = 'C'.
      WHEN 'WRAP_YN'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '랩포장'(f40).
        <LS_FCAT>-JUST = 'C'.
      WHEN 'BANFN'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '구매요청번호'(f42).
        <LS_FCAT>-JUST = 'C'.
      WHEN 'BNFPO'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '구매요청품목'(f43).
        <LS_FCAT>-JUST = 'C'.
      WHEN 'LFDAT'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '구매납품예정일'(f44).
        <LS_FCAT>-JUST = 'C'.
      WHEN 'STATU'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '구매처리상태'(f45).
        <LS_FCAT>-JUST = 'C'.
      WHEN 'PR_NAME1'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '공급업체명'(f46).
        <LS_FCAT>-JUST = 'L'.

    ENDCASE.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_CELL_ATTRIBUTE_GRID_0100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_CELL_ATTRIBUTE_GRID_0100 .

  DATA : LT_CELLTAB TYPE LVC_T_STYL.
  DATA : LS_CELLTAB TYPE LVC_S_STYL.
  FIELD-SYMBOLS : <LT_CELLTAB> TYPE ANY.

* Macro
  DEFINE __SET_CELL_ATTRIBUTE.
    CLEAR ls_celltab.
    ls_celltab-fieldname = &1.
    ls_celltab-style = &2.
    INSERT ls_celltab INTO TABLE lt_celltab.
  END-OF-DEFINITION.

  LOOP AT GT_MAIN_DISP ASSIGNING FIELD-SYMBOL(<LS_MAIN>).

    CLEAR LS_CELLTAB.
    REFRESH LT_CELLTAB.
    __SET_CELL_ATTRIBUTE : 'VBELN' ALV_STYLE_COLOR_INT_KEY,
                           'POSNR' ALV_STYLE_COLOR_INT_KEY,
                           'ZTYPE' ALV_STYLE_COLOR_INT_GROUP,
                           'CHK_OEM' ALV_STYLE_COLOR_INT_KEY,
                           'LIFSP' ALV_STYLE_COLOR_INT_KEY,
                           'VTEXT' ALV_STYLE_COLOR_INT_KEY,
                           'FIXMG' ALV_STYLE_COLOR_INT_KEY,
                           'STATUS' ALV_STYLE_COLOR_INT_KEY,
                           'MESSAGE' ALV_STYLE_COLOR_INT_KEY,
                           'WMENG' ALV_STYLE_COLOR_INT_POSITIVE,
                           'VRKME' ALV_STYLE_COLOR_INT_POSITIVE,
                           'INLENGTH' ALV_STYLE_COLOR_INT_POSITIVE,
                           'INFACTOR' ALV_STYLE_COLOR_INT_POSITIVE,
                           'LABST2' ALV_STYLE_COLOR_GROUP,
                           'INFACTOR2' ALV_STYLE_COLOR_GROUP,
                           'KALAB' ALV_STYLE_COLOR_GROUP.

    IF <LT_CELLTAB> IS ASSIGNED.
      UNASSIGN <LT_CELLTAB>.
    ENDIF.
    ASSIGN COMPONENT 'CELLTAB' OF STRUCTURE <LS_MAIN> TO <LT_CELLTAB>.
    IF <LT_CELLTAB> IS ASSIGNED.
      <LT_CELLTAB> = LT_CELLTAB.
    ENDIF.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form EXCLUDE_OF_TOOLBAR_GRID_0100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM EXCLUDE_OF_TOOLBAR_GRID_0100 .

  PERFORM ADD_EXCLUDE_TOOLBAR_BUTTON TABLES GT_EXCLUDE_0100
        USING : CL_GUI_ALV_GRID=>MC_FC_LOC_UNDO,
                CL_GUI_ALV_GRID=>MC_FC_AUF,
                CL_GUI_ALV_GRID=>MC_FC_CHECK,
                CL_GUI_ALV_GRID=>MC_FC_LOC_PASTE,
                CL_GUI_ALV_GRID=>MC_FC_LOC_COPY,
                CL_GUI_ALV_GRID=>MC_FC_AVERAGE,
                CL_GUI_ALV_GRID=>MC_FC_GRAPH,
                CL_GUI_ALV_GRID=>MC_FC_INFO,
                CL_GUI_ALV_GRID=>MC_FC_LOC_COPY_ROW,
                CL_GUI_ALV_GRID=>MC_FC_LOC_CUT,
                CL_GUI_ALV_GRID=>MC_FC_LOC_DELETE_ROW,
                CL_GUI_ALV_GRID=>MC_FC_LOC_INSERT_ROW,
                CL_GUI_ALV_GRID=>MC_FC_LOC_APPEND_ROW,
                CL_GUI_ALV_GRID=>MC_FC_LOC_PASTE,
                CL_GUI_ALV_GRID=>MC_FC_LOC_PASTE_NEW_ROW,
                CL_GUI_ALV_GRID=>MC_FC_REFRESH.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  add_exclude_toolbar_button
*&---------------------------------------------------------------------*
*       text
*-----------------------------------------------------------------------
**
FORM ADD_EXCLUDE_TOOLBAR_BUTTON  TABLES   P_TABLE
                                 USING    P_VALUE.
  DATA: L_EXCLUDE TYPE UI_FUNC.
  L_EXCLUDE = P_VALUE.
  APPEND L_EXCLUDE TO P_TABLE.
ENDFORM.                    " add_exclude_toolbar_button
*&---------------------------------------------------------------------*
*& Form CALL_GRID_0100_DISPLAY
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CALL_GRID_0100_DISPLAY .

  CALL METHOD GO_GRID_0100->SET_TABLE_FOR_FIRST_DISPLAY
    EXPORTING
      IS_LAYOUT            = GS_LAYOUT_0100
      IT_TOOLBAR_EXCLUDING = GT_EXCLUDE_0100
    CHANGING
      IT_OUTTAB            = GT_MAIN_DISP
      IT_SORT              = GT_SORT_0100
      IT_FIELDCATALOG      = GT_FIELDCAT_0100.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_VALUE_FROM_CHAR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      <-- <LS_MAIN>_ZCOLOR__BASE
*&---------------------------------------------------------------------*
FORM GET_VALUE_FROM_CHAR  USING   PV_CHARNAME
                                  PV_GUBUN
                          CHANGING PV_VALUE.

  DATA : BEGIN OF LS_CHK_CHAR_NAME,
           ATNAM TYPE CABN-ATNAM,
           ATINN TYPE CABN-ATINN,
         END OF LS_CHK_CHAR_NAME.
  STATICS : LT_CHK_CHAR_NAME LIKE TABLE OF LS_CHK_CHAR_NAME.
  DATA : LV_TABIX TYPE I.
  DATA : LV_VALUE TYPE CHAR20.

  CLEAR LS_CHK_CHAR_NAME.
  READ TABLE LT_CHK_CHAR_NAME INTO LS_CHK_CHAR_NAME WITH KEY ATNAM = PV_CHARNAME BINARY SEARCH.
  IF SY-SUBRC NE 0.
    LV_TABIX = SY-TABIX.
    LS_CHK_CHAR_NAME-ATNAM = PV_CHARNAME.

    CALL FUNCTION 'CONVERSION_EXIT_ATINN_INPUT'
      EXPORTING
        INPUT  = LS_CHK_CHAR_NAME-ATNAM
      IMPORTING
        OUTPUT = LS_CHK_CHAR_NAME-ATINN.

    INSERT LS_CHK_CHAR_NAME INTO LT_CHK_CHAR_NAME INDEX LV_TABIX.
  ENDIF.

  CHECK LS_CHK_CHAR_NAME-ATINN IS NOT INITIAL.
  READ TABLE GT_CHART INTO DATA(LS_CHAR) WITH KEY ATINN = LS_CHK_CHAR_NAME-ATINN.
  IF SY-SUBRC EQ 0.
    CASE PV_GUBUN.
      WHEN 'C'.
        PV_VALUE = LS_CHAR-ATWRT.
      WHEN OTHERS.
        CLEAR LV_VALUE.
        CALL FUNCTION 'FLTP_CHAR_CONVERSION'
          EXPORTING
            DECIM = 3
            INPUT = LS_CHAR-ATFLV
          IMPORTING
            FLSTR = LV_VALUE.
        PV_VALUE = LV_VALUE + 0.
    ENDCASE.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_QUINTITY_CONV_UINT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LS_MAIN_WMENG
*&      --> LS_MAIN_VRKME
*&      --> LS_MAIN_MEINS
*&      <-- <LS_MAIN>_WMENG
*&---------------------------------------------------------------------*
FORM GET_QUINTITY_CONV_UINT  USING    PV_MATNR TYPE MATNR
                                      PV_IN_MENGE TYPE MENGE_D
                                      PV_IN_MEINS TYPE MEINS
                                      PV_OUT_MEINS TYPE MEINS
                             CHANGING PV_OUT_MENGE TYPE MENGE_D.

  CALL FUNCTION 'MD_CONVERT_MATERIAL_UNIT'
    EXPORTING
      I_MATNR              = PV_MATNR
      I_IN_ME              = PV_IN_MEINS
      I_OUT_ME             = PV_OUT_MEINS
      I_MENGE              = PV_IN_MENGE
    IMPORTING
      E_MENGE              = PV_OUT_MENGE
    EXCEPTIONS
      ERROR_IN_APPLICATION = 1
      ERROR                = 2
      OTHERS               = 3.
  IF SY-SUBRC <> 0.
* Implement suitable error handling here
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_LABST_FR_LGORT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LS_MAIN_VBELN
*&      --> LS_MAIN_POSNR
*&      --> LS_MAIN_MATNR
*&      <-- <LS_MAIN>_LABST2
*&---------------------------------------------------------------------*
FORM GET_LABST_FR_LGORT  USING    PV_TYPE
                                  PV_VBELN TYPE VBELN
                                  PV_POSNR TYPE VBAP-POSNR
                                  PV_MATNR TYPE MATNR
                         CHANGING PV_MENGE TYPE MENGE_D.

  DATA : LV_EXIST.
  CLEAR PV_MENGE.

  LOOP AT GT_LINK_STOCK INTO DATA(LS_LINK) WHERE STOCK_TABLE = PV_TYPE
                                             AND VBELN = PV_VBELN
                                             AND POSNR = PV_POSNR
                                             AND MATNR = PV_MATNR.

    ADD LS_LINK-LABST2 TO PV_MENGE.
    LV_EXIST = ABAP_TRUE.
  ENDLOOP.

  IF LV_EXIST IS INITIAL.
    LOOP AT GT_LINK_DETAIL INTO DATA(LS_DETAIL) WHERE VBELN = PV_VBELN
                                               AND POSNR = PV_POSNR.
      LOOP AT GT_LINK_STOCK INTO LS_LINK WHERE STOCK_TABLE = PV_TYPE
                                             AND CHARG = LS_DETAIL-F_CHARG
                                             AND MATNR = PV_MATNR.
        ADD LS_LINK-LABST2 TO PV_MENGE.
      ENDLOOP.
    ENDLOOP.
  ENDIF.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_STOCK_LINK_INFO
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_STOCK_LINK_INFO .

  CLEAR: GT_LINK_DETAIL, GT_LINK_STOCK.

  CALL FUNCTION 'ZGTPP_GET_STOCK_LINK_INFO'
    EXPORTING
      I_WERKS        = P_WERKS
      I_LGORT        = P_LGORT
      IT_MATNR       = GT_MATNR
    TABLES
      OT_LINK_DETAIL = GT_LINK_DETAIL
      OT_LINK_STOCK  = GT_LINK_STOCK.

  SORT GT_LINK_STOCK BY STOCK_TABLE VBELN POSNR.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROC_CHG_TYPE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&---------------------------------------------------------------------*
FORM PROC_CHG_TYPE  USING  PV_ZTYPE.

  DATA : LT_ROWS TYPE LVC_T_ROW.
  DATA : LT_ROWS_EXCUTE TYPE LVC_T_ROW.
  DATA : LS_BACKUP LIKE GS_MAIN_DISP.
  DATA : LV_MESSAGE TYPE STRING.
  DATA : LV_MESSAGE_DISP TYPE CHAR100.

  GO_GRID_0100->GET_SELECTED_ROWS(
    IMPORTING
      ET_INDEX_ROWS = LT_ROWS ).                " Indexes of Selected Rows
*      ET_ROW_NO     =                  " Numeric IDs of Selected Rows

  DELETE LT_ROWS WHERE INDEX = 0.

  IF LT_ROWS[] IS INITIAL.
    MESSAGE S006 DISPLAY LIKE 'E' WITH '선택된 라인이 없습니다.'(e01).
    RETURN.
  ENDIF.

* 변경 가능 대상인지 확인
  LOOP AT LT_ROWS INTO DATA(LS_ROW).
    READ TABLE GT_MAIN_DISP ASSIGNING FIELD-SYMBOL(<LS_MAIN>) INDEX LS_ROW-INDEX.
    IF <LS_MAIN>-NOT_USE = ABAP_TRUE.
      CONTINUE.
    ENDIF.

    IF <LS_MAIN>-ZTYPE = PV_ZTYPE.
*  "OM 전환" 버튼 클릭 시, 유형이 "OM" 이면서 납품보류가 "G1"인 레코드도 전환 대상으로 포함
*    (현재는 "이미 유형이 OM 과 같습니다." 오류 메시지 출력됨)
*   => 처리 시, OM 유형은 유지되고, 납품보류만 G1 -> SPACE로 변경하고자 함
      IF <LS_MAIN>-ZTYPE = 'OM' AND <LS_MAIN>-LIFSP = 'G1'.
      ELSE.
        <LS_MAIN>-STATUS = ICON_LED_RED.
        <LS_MAIN>-MESSAGE = | 이미 유형이 { PV_ZTYPE } 과 같습니다. |.
        LV_MESSAGE_DISP = <LS_MAIN>-MESSAGE.
        CONTINUE.
      ENDIF.
    ENDIF.

    IF <LS_MAIN>-BANFN IS NOT INITIAL.
      <LS_MAIN>-STATUS = ICON_LED_RED.
      <LS_MAIN>-MESSAGE = | 상품 PR 존재하여 변경할 수 없습니다. Pr삭제후 진행하세요 |.
      LV_MESSAGE_DISP = <LS_MAIN>-MESSAGE.
      CONTINUE.
    ENDIF.

    IF <LS_MAIN>-EBELN IS NOT INITIAL.
      <LS_MAIN>-STATUS = ICON_LED_RED.
      <LS_MAIN>-MESSAGE = | 상품 구매오더 존재하여 변경할 수 없습니다. 구매오더 삭제후 진행하세요 |.
      LV_MESSAGE_DISP = <LS_MAIN>-MESSAGE.
      CONTINUE.
    ENDIF.

    APPEND LS_ROW TO LT_ROWS_EXCUTE.

  ENDLOOP.

  IF LT_ROWS_EXCUTE[] IS INITIAL.
    PERFORM REFRESH_GRID USING GO_GRID_0100.
    MESSAGE S006 DISPLAY LIKE 'E' WITH LV_MESSAGE_DISP.
    RETURN.
  ENDIF.

  IF LT_ROWS_EXCUTE[] IS NOT INITIAL.

    LV_MESSAGE = | { PV_ZTYPE } 전환 하시겠습니까? |.
    CLEAR GV_ANSWER.
    PERFORM POPUP_TO_CONFIRM_STEP USING 'N'
      ' '
      LV_MESSAGE
      '전환확인'.
    IF GV_ANSWER NE 'J'.
      MESSAGE S003 DISPLAY LIKE 'E' WITH '작업이 취소 되었습니다.'.
      RETURN.
    ENDIF.

    DATA : LV_FIXMG TYPE VBAP-FIXMG.
    DATA : LV_MVGR3 TYPE MVGR3.
    DATA : LV_LIFSP TYPE LIFSP.
    DATA : LV_TYPE TYPE BAPI_MTYPE.
    DATA : LV_MSG TYPE BAPI_MSG.

    IF LT_ROWS_EXCUTE IS INITIAL.
      PERFORM REFRESH_GRID USING GO_GRID_0100.
      MESSAGE S006 DISPLAY LIKE 'E' WITH '전환 가능한 대상이 선택되지 않았습니다.'.
      RETURN.
    ENDIF.

    LOOP AT LT_ROWS_EXCUTE INTO LS_ROW.
      CLEAR : LV_FIXMG, LV_MVGR3, LV_TYPE, LV_MSG .
      CLEAR LV_LIFSP.
      READ TABLE GT_MAIN_DISP ASSIGNING <LS_MAIN> INDEX LS_ROW-INDEX.

* 전환필드
      CASE PV_ZTYPE.
        WHEN 'SM'.
          LV_FIXMG = ABAP_TRUE.
          LV_LIFSP = 'G1'.
        WHEN 'OM'.

      ENDCASE.

      PERFORM CHECK_MVGNR3 USING <LS_MAIN>-VBELN <LS_MAIN>-POSNR CHANGING LV_MVGR3.

      CALL FUNCTION 'ZGTSD_RECEIVE_STOCK_LINK_INFO'
        EXPORTING
          I_VBELN = <LS_MAIN>-VBELN
          I_POSNR = <LS_MAIN>-POSNR
          I_MVGR3 = LV_MVGR3
          I_LIFSP = LV_LIFSP
          I_FIXMG = LV_FIXMG
        IMPORTING
          E_TYPE  = LV_TYPE
          E_MSG   = LV_MSG.

      IF LV_TYPE = 'S'.
        <LS_MAIN>-STATUS = ICON_LED_GREEN.
        <LS_MAIN>-MESSAGE = LV_MSG.

        SELECT SINGLE B~LIFSP, A~FIXMG,  C~VTEXT
          FROM VBAP AS A
          INNER JOIN VBEP AS B ON B~VBELN = A~VBELN
                        AND B~POSNR = A~POSNR
          INNER JOIN TVLST AS C ON C~LIFSP = B~LIFSP
                               AND C~SPRAS = @SY-LANGU
         WHERE A~VBELN = @<LS_MAIN>-VBELN
            AND A~POSNR = @<LS_MAIN>-POSNR
            AND B~ETENR = '0001'
           INTO ( @<LS_MAIN>-LIFSP, @<LS_MAIN>-FIXMG, @<LS_MAIN>-VTEXT ).

        <LS_MAIN>-ZTYPE = PV_ZTYPE.

      ELSE.
        <LS_MAIN>-STATUS = ICON_LED_RED.
        <LS_MAIN>-MESSAGE = LV_MSG.
      ENDIF.

    ENDLOOP.

    WAIT UP TO 1 SECONDS.
* 화면재설정을 위한 초기화
    PERFORM GET_DATA_FROM_PP.

    LOOP AT LT_ROWS_EXCUTE INTO LS_ROW.
      READ TABLE GT_MAIN_DISP ASSIGNING <LS_MAIN> INDEX LS_ROW-INDEX.
      CLEAR LS_BACKUP.
      MOVE-CORRESPONDING <LS_MAIN> TO LS_BACKUP.
      READ TABLE GT_MAIN_DISP2 INTO DATA(LS_TOBE) WITH KEY VBELN = LS_BACKUP-VBELN
                                                           POSNR = LS_BACKUP-POSNR.
      IF SY-SUBRC EQ 0.
        MOVE-CORRESPONDING LS_TOBE TO <LS_MAIN>.
        <LS_MAIN>-STATUS = LS_BACKUP-STATUS.
        <LS_MAIN>-MESSAGE = LS_BACKUP-MESSAGE.
      ELSE.
        <LS_MAIN>-STATUS = 'E'.
        <LS_MAIN>-MESSAGE = '판매오더 정보가 변경되었습니다. 해당 품목을 찾을 수 없습니다.'.
      ENDIF.
    ENDLOOP.

  ENDIF.

  PERFORM REFRESH_GRID USING GO_GRID_0100.
  MESSAGE S006 WITH '전환되었습니다.'.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form popup_to_confirm_step
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> P_
*&      --> P_
*&      --> P_
*&---------------------------------------------------------------------*
FORM POPUP_TO_CONFIRM_STEP  USING LP_OPT
                                  LP_TEXT1
                                  LP_TEXT2
                                  LP_TITLE.
  CLEAR GV_ANSWER.
  CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
    EXPORTING
      DEFAULTOPTION  = LP_OPT
      TEXTLINE1      = LP_TEXT1
      TEXTLINE2      = LP_TEXT2
      TITEL          = LP_TITLE
      CANCEL_DISPLAY = ''
    IMPORTING
      ANSWER         = GV_ANSWER.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_DATA_FROM_PP
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_DATA_FROM_PP .

  DATA : LT_DISPO TYPE RANGE OF MARC-DISPO.
  DATA : LV_WMENG TYPE VBEP-WMENG.
  DATA : LT_CUOBJ TYPE RANGE OF CUOBJ.
  DATA : LV_BCOS_TSTMP TYPE BCOS_TSTMP.
  DATA : BEGIN OF LS_AUFNR_STATUS,
           AUFNR  TYPE AUFK-AUFNR,
           STATUS TYPE CHAR10,
         END OF LS_AUFNR_STATUS.
  DATA : LT_AUFNR_STATUS LIKE TABLE OF LS_AUFNR_STATUS.
  DATA : LV_STATUS TYPE CHAR10.
  DATA : LV_TABIX TYPE I.

  IF S_SPGCD[] IS NOT INITIAL.
    READ TABLE S_SPGCD INDEX 1.
    APPEND INITIAL LINE TO LT_DISPO ASSIGNING FIELD-SYMBOL(<LS_DISPO>).
    <LS_DISPO>-SIGN = 'I'.
    <LS_DISPO>-OPTION = 'CP'.
    <LS_DISPO>-LOW = S_SPGCD-LOW && '*'.
  ENDIF.

  REFRESH GT_MAIN_DISP2.

  SELECT DISTINCT
         A~VBELN, B~POSNR, A~KUNNR, A~VKORG, A~VTWEG, A~SPART, A~VKGRP, A~VKBUR, B~FIXMG,
         A~ERDAT, B~MATNR, B~VRKME, B~CUOBJ, C~LIFSP, C~ETENR, C~EDATU, C~WMENG, D~MEINS,
         D~ZZSPEC_NO, D~MTART, D~MATKL, E~XCHAR, F~NAME1
    FROM VBAK AS A
    INNER JOIN VBAP AS B ON B~VBELN = A~VBELN
    INNER JOIN VBEP AS C ON C~VBELN = B~VBELN
                        AND C~POSNR = B~POSNR
    INNER JOIN MARA AS D ON D~MATNR = B~MATNR
    INNER JOIN MARC AS E ON E~MATNR = B~MATNR
                        AND E~WERKS = B~WERKS
    INNER JOIN KNA1 AS F ON F~KUNNR = A~KUNNR
   WHERE A~VBELN IN @S_VBELN
     AND A~VKBUR IN @S_VKBUR
     AND A~KUNNR IN @S_KUNNR
     AND A~ERDAT IN @S_ERDAT
     AND B~WERKS = @P_WERKS
     AND B~POSNR IN @S_POSNR
     AND B~MATNR IN @S_MATNR
     AND B~ABGRU = ''
     AND B~FIXMG IN @S_FIXMG
     AND C~EDATU IN @S_EDATU
     AND C~LIFSP IN @S_LIFSP
     AND C~ETENR = '0001'
     AND D~MTART IN @S_MTART
     AND D~MATKL IN @S_MATKL
     AND E~DISPO IN @LT_DISPO
    INTO TABLE @DATA(LT_MAIN).

  IF LT_MAIN[] IS NOT INITIAL.

    LT_CUOBJ = VALUE #( FOR LW_MAIN IN LT_MAIN WHERE ( CUOBJ IS NOT INITIAL )
                      ( SIGN = 'I' OPTION = 'EQ' LOW = LW_MAIN-CUOBJ ) ).

    SORT LT_CUOBJ BY LOW.
    DELETE ADJACENT DUPLICATES FROM LT_CUOBJ COMPARING LOW.

    GET TIME STAMP FIELD LV_BCOS_TSTMP.

* 판매오더로 특성정보 가져오기
    SELECT A~INSTANCE, B~*
      INTO  TABLE @GT_CHART_FUL
      FROM IBIN AS A
      INNER JOIN V_IBIN_SYVAL AS B ON B~IN_RECNO = A~IN_RECNO
     WHERE A~INSTANCE IN @LT_CUOBJ
       AND A~VALFR <= @LV_BCOS_TSTMP
       AND A~VALTO > @LV_BCOS_TSTMP
      ORDER BY INSTANCE .

    SELECT B~*
      FROM @LT_MAIN AS A
      INNER JOIN ZGTPPT2170 AS B ON B~VBELN = A~VBELN
                                AND B~POSNR = A~POSNR
                                AND B~LOEKZ = ''
      INTO TABLE @DATA(LT_2170).

    SELECT B~*
      FROM @LT_MAIN AS A
      INNER JOIN ZGTPPT2000 AS B ON B~ORDNO = A~VBELN
                                AND B~POSNR = A~POSNR
     WHERE B~ZSTATUS <> 'D'
      INTO TABLE @DATA(LT_2000).

    WITH +JOJANG AS (
      SELECT B~ORDNR, RIGHT( B~POSNR, 4 ) AS POSNR
        FROM @LT_2000 AS A
        INNER JOIN ZGTPPT2010 AS B ON B~GRPNR = A~GRPNR
                                   AND B~DMORD = A~ORDNO
                                   AND B~DMLINE = A~POSNR
       WHERE B~DMORDTY = 'SO'
         AND B~ORDTY = 'PRD' )
     SELECT D~KDAUF, D~KDPOS, D~AUFNR, D~POSNR, D~PSMNG, D~WEMNG, D~PSAMG
       FROM +JOJANG AS C
       INNER JOIN AFPO AS D ON D~AUFNR = C~ORDNR
                           AND D~POSNR = C~POSNR
       INTO TABLE @DATA(LT_AFPO).
* 해당 생산오더가 완료처리되고 입고량이 없다면 제외처리
    REFRESH LT_AUFNR_STATUS.
    LOOP AT LT_AFPO ASSIGNING FIELD-SYMBOL(<LS_AFPO>).
*  상태값조회후 삭제 상태 제외
      READ TABLE LT_AUFNR_STATUS INTO LS_AUFNR_STATUS WITH KEY AUFNR = <LS_AFPO>-AUFNR BINARY SEARCH.
      LV_TABIX = SY-TABIX.
      IF SY-SUBRC EQ 0.
      ELSE.
        CLEAR LV_STATUS.
        PERFORM GET_STATUS USING <LS_AFPO>-AUFNR
                              CHANGING LV_STATUS.

        LS_AUFNR_STATUS-AUFNR = <LS_AFPO>-AUFNR.
        LS_AUFNR_STATUS-STATUS = LV_STATUS.
        INSERT LS_AUFNR_STATUS INTO LT_AUFNR_STATUS INDEX LV_TABIX.

      ENDIF.

      IF LS_AUFNR_STATUS-STATUS = 'DEL'.
        DELETE TABLE LT_AFPO FROM <LS_AFPO>.
      ELSE.
* 완료처리된건이나 입고
        IF LS_AUFNR_STATUS-STATUS = 'DLV' AND <LS_AFPO>-WEMNG = 0.
          DELETE TABLE LT_AFPO FROM <LS_AFPO>.
        ENDIF.
      ENDIF.

    ENDLOOP.


* 범주 판매오더의 구매요청 확인
    SELECT A~BANFN, A~BNFPO, A~LFDAT, A~STATU, B~VBELN, B~VBELP, A~LIFNR, C~NAME1, A~ESTKZ
      FROM EBAN AS A
      INNER JOIN EBKN AS B ON B~BANFN = A~BANFN
                                AND B~BNFPO = A~BNFPO
      LEFT JOIN LFA1 AS C ON C~LIFNR = A~LIFNR
      FOR ALL ENTRIES IN @LT_MAIN
     WHERE B~VBELN =  @LT_MAIN-VBELN
        AND B~VBELP =  @LT_MAIN-POSNR
        AND A~MATNR =  @LT_MAIN-MATNR
        AND A~WERKS =  @P_WERKS
        AND A~BSTYP = 'B'
        AND A~EKORG = @GS_EKORG-EKORG
        AND A~EKGRP = @GS_EKORG-EKGRP
        AND A~LOEKZ = ''
      INTO TABLE @DATA(LT_EBAN).

    SELECT DISTINCT A~VBELN, A~VBELP AS POSNR, C~LIFNR, A~EBELN, A~EBELP, B~BANFN, B~BNFPO, D~NAME1
      FROM EKKN AS A
      INNER JOIN EKPO AS B ON B~EBELN = A~EBELN
                          AND B~EBELP = A~EBELP
      INNER JOIN EKKO AS C ON C~EBELN = A~EBELN
      INNER JOIN LFA1 AS D ON D~LIFNR = C~LIFNR
      INNER JOIN @LT_MAIN AS E ON E~VBELN = A~VBELN
                                         AND E~POSNR = A~VBELP
     WHERE B~LOEKZ = ''
      INTO TABLE @DATA(LT_EKKO).


    REFRESH GT_MATNR.
    GT_MATNR = VALUE #( FOR LW_MAIN IN LT_MAIN WHERE ( MATNR IS NOT INITIAL )
                      ( SIGN = 'I' OPTION = 'EQ' LOW =   LW_MAIN-MATNR ) ).
    SORT GT_MATNR BY LOW.
    DELETE ADJACENT DUPLICATES FROM GT_MATNR COMPARING LOW.

    PERFORM GET_STOCK_LINK_INFO.

  ENDIF.

  SORT LT_EBAN BY VBELN VBELP.

  LOOP AT LT_MAIN INTO DATA(LS_MAIN).
    APPEND INITIAL LINE TO GT_MAIN_DISP2 ASSIGNING FIELD-SYMBOL(<LS_MAIN>).
    MOVE-CORRESPONDING LS_MAIN TO <LS_MAIN>.

    <LS_MAIN>-VRKME = LS_MAIN-MEINS.
* 품목내역
    <LS_MAIN>-MAKTX = ZGTPP_CL_COMMON=>GET_MAKTX( IV_MATNR = <LS_MAIN>-MATNR ).

* 유형
    CASE <LS_MAIN>-FIXMG.
      WHEN 'X'.
        <LS_MAIN>-ZTYPE = 'SM'.
      WHEN ''.
        <LS_MAIN>-ZTYPE = 'OM'.
    ENDCASE.

* 납품보류내역
    SELECT SINGLE VTEXT FROM TVLST
      INTO <LS_MAIN>-VTEXT
     WHERE LIFSP = LS_MAIN-LIFSP
       AND SPRAS = SY-LANGU.

    <LS_MAIN>-STATUS = ICON_LED_INACTIVE.
* 색상관련 특성값
    REFRESH GT_CHART.
    READ TABLE GT_CHART_FUL INTO DATA(LS_CHART) WITH KEY INSTANCE = LS_MAIN-CUOBJ BINARY SEARCH.
    IF SY-SUBRC EQ 0.
      LOOP AT GT_CHART_FUL INTO LS_CHART FROM SY-TABIX.
        IF LS_CHART-INSTANCE NE LS_MAIN-CUOBJ.
          EXIT.
        ENDIF.

        APPEND LS_CHART TO GT_CHART.

      ENDLOOP.
    ENDIF.

    PERFORM GET_VALUE_FROM_CHAR USING 'PD_CA_COLOR_BASE' 'C' CHANGING <LS_MAIN>-ZCOLOR__BASE.
    PERFORM GET_VALUE_FROM_CHAR USING 'PD_CA_COLOR_DETAIL' 'C' CHANGING <LS_MAIN>-ZCOLOR_DTL.
    PERFORM GET_VALUE_FROM_CHAR USING 'PD_CA_COLOR_STRIPE' 'C' CHANGING <LS_MAIN>-ZCOLOR_STR.
    PERFORM GET_VALUE_FROM_CHAR USING 'PD_CA_COLOR_STRIPE_NO' 'C' CHANGING <LS_MAIN>-ZCOLOR_STRN.

* 납품수량
    IF  LS_MAIN-MEINS NE LS_MAIN-VRKME.
      PERFORM GET_QUINTITY_CONV_UINT USING LS_MAIN-MATNR LS_MAIN-WMENG LS_MAIN-VRKME LS_MAIN-MEINS
                                  CHANGING <LS_MAIN>-WMENG.

    ENDIF.

* 조장
    IF LS_MAIN-MEINS = 'EA'.
      <LS_MAIN>-INLENGTH = <LS_MAIN>-WMENG.
    ELSE.
      PERFORM GET_VALUE_FROM_CHAR USING 'SAP_MILLCA_LENGTH' '' CHANGING <LS_MAIN>-INLENGTH.
    ENDIF.

* 조장수
    IF LS_MAIN-MEINS = 'EA'.
      <LS_MAIN>-INFACTOR = <LS_MAIN>-WMENG / <LS_MAIN>-INLENGTH.
    ELSE.
      PERFORM GET_VALUE_FROM_CHAR USING 'SAP_MILLCA_FACTOR' '' CHANGING <LS_MAIN>-INFACTOR.
    ENDIF.

* 기할당수량
    PERFORM GET_LABST_FR_LGORT USING 'MCHB' LS_MAIN-VBELN LS_MAIN-POSNR LS_MAIN-MATNR
                            CHANGING <LS_MAIN>-LABST2.

* 기할당조장수
    IF <LS_MAIN>-LABST2 NE 0 AND <LS_MAIN>-INLENGTH NE 0.
      <LS_MAIN>-INFACTOR2 = <LS_MAIN>-LABST2 / <LS_MAIN>-INLENGTH.
    ELSE.
      <LS_MAIN>-INFACTOR2 = 0.
    ENDIF.

* 판매오더 재고
    SELECT * FROM ZGTCV_STOCKVAL
      INTO TABLE @DATA(LT_STOCKVAL)
     WHERE WERKS = @P_WERKS
       AND MATNR = @LS_MAIN-MATNR
       AND VBELN = @LS_MAIN-VBELN
       AND POSNR = @LS_MAIN-POSNR.
    IF SY-SUBRC EQ 0.
      LOOP AT LT_STOCKVAL INTO DATA(LS_STOCKVAL).
        <LS_MAIN>-KALAB = <LS_MAIN>-KALAB + LS_STOCKVAL-LABST.
      ENDLOOP.

    ENDIF.
*    PERFORM GET_LABST_FR_LGORT USING 'MSKA' LS_MAIN-VBELN LS_MAIN-POSNR LS_MAIN-MATNR
*                            CHANGING <LS_MAIN>-KALAB.

* 고객명
*    <LS_MAIN>-NAME1 = ZGTPP_CL_COMMON=>GET_BP_NAME( IV_KUNNR = <LS_MAIN>-KUNNR ).

* 그외 특성 정보들
    PERFORM GET_VALUE_FROM_CHAR USING 'PD_CA_SKID_YN' 'C' CHANGING <LS_MAIN>-SKID_YN.
    PERFORM GET_VALUE_FROM_CHAR USING 'PD_GA_DRUM_GUBUN' 'C' CHANGING <LS_MAIN>-DRUM_GUBUN.
    PERFORM GET_VALUE_FROM_CHAR USING 'PD_GA_PACKAGE_METHOD' 'C' CHANGING <LS_MAIN>-PACK_METHOD.
    PERFORM GET_VALUE_FROM_CHAR USING 'PD_GA_FLANGE_PROT_YN' 'C' CHANGING <LS_MAIN>-PROT_YN.
    PERFORM GET_VALUE_FROM_CHAR USING 'PD_GA_PRINT_METHOD' 'C' CHANGING <LS_MAIN>-PRINT_METHOD.
    PERFORM GET_VALUE_FROM_CHAR USING 'PD_GA_NEW_DRUM_YN' 'C' CHANGING <LS_MAIN>-NEW_DRUM_YN.
    PERFORM GET_VALUE_FROM_CHAR USING 'PD_GA_WRAP_PACKING_YN' 'C' CHANGING <LS_MAIN>-WRAP_YN.

* 주문할당 오더 확인
    READ TABLE LT_2170 INTO DATA(LS_2170) WITH KEY VBELN = LS_MAIN-VBELN
                                                   POSNR = LS_MAIN-POSNR.
    IF SY-SUBRC EQ 0.
      <LS_MAIN>-STATUS = ICON_LED_RED.
      <LS_MAIN>-MESSAGE = '이미 주문 할당된 판매오더입니다.'.
      <LS_MAIN>-NOT_USE = ABAP_TRUE.
    ENDIF.

* 조장구성 오더 확인
    READ TABLE LT_2000 INTO DATA(LS_2000) WITH KEY ORDNO = LS_MAIN-VBELN
                                                   POSNR = LS_MAIN-POSNR.
    IF SY-SUBRC EQ 0.
* 조장구성된 생산오더의 상태를 조회하여 특정생산오더( 상태 DLV, 입고량 0) 의 경우 조장대상에서 제외되어야 함
      READ TABLE LT_AFPO TRANSPORTING NO FIELDS WITH KEY KDAUF = LS_MAIN-VBELN
                                                         KDPOS = LS_MAIN-POSNR.
      IF SY-SUBRC EQ 0.
        <LS_MAIN>-STATUS = ICON_LED_RED.
        <LS_MAIN>-MESSAGE = '이미 조장 구성된 판매오더입니다.'.
        <LS_MAIN>-NOT_USE = ABAP_TRUE.
      ENDIF.
    ENDIF.

* PR 확인
    READ TABLE  LT_EBAN INTO DATA(LS_EBAN) WITH KEY VBELN = <LS_MAIN>-VBELN
                                                                 VBELP = <LS_MAIN>-POSNR
                                                                 BINARY SEARCH.
    IF SY-SUBRC EQ 0.
      <LS_MAIN>-CHK_OEM = ABAP_TRUE.
      <LS_MAIN>-BANFN = LS_EBAN-BANFN.
      <LS_MAIN>-BNFPO = LS_EBAN-BNFPO.
      <LS_MAIN>-LFDAT = LS_EBAN-LFDAT.
      <LS_MAIN>-STATU = ZGTPP_CL_COMMON=>GET_DOMAIN_TEXT(
                                    IV_DOMNAME  = 'BANST'
                                    IV_DOMVALUE = CONV #( LS_EBAN-STATU ) ).

      <LS_MAIN>-PR_NAME1 = LS_EBAN-NAME1.

      IF LS_EBAN-ESTKZ = 'V'.
        <LS_MAIN>-NOT_DEL = ABAP_TRUE.
      ENDIF.
    ENDIF.

    READ TABLE LT_EKKO INTO DATA(LS_EKKO) WITH KEY VBELN = <LS_MAIN>-VBELN
                                                                      POSNR = <LS_MAIN>-POSNR.
    IF SY-SUBRC EQ 0.
      <LS_MAIN>-CHK_OEM = ABAP_TRUE.
      <LS_MAIN>-EBELN = LS_EKKO-EBELN.
      <LS_MAIN>-EBELP = LS_EKKO-EBELP.

      <LS_MAIN>-PR_NAME1 = LS_EKKO-NAME1.
    ENDIF.

  ENDLOOP.

  SORT GT_MAIN_DISP2 BY VBELN POSNR.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROC_DISP
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PROC_DISP .

*  CASE ABAP_TRUE.
*    WHEN P_RAD01.
  CALL SCREEN 0100.
*    WHEN P_RAD02.
*  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_MVGNR3
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> <LS_MAIN>_VBELN
*&      --> <LS_MAIN>_POSNR
*&      <-- LV_MVGR3
*&---------------------------------------------------------------------*
FORM CHECK_MVGNR3  USING    PV_VBELN TYPE VBELN
                            PV_POSNR TYPE VBAP-POSNR
                   CHANGING PV_MVGR3 TYPE MVGR3.

  DATA : LV_CHK_ZORD_TYPE TYPE I.

  SELECT DISTINCT B~*
    FROM ZGTPPT2170 AS A
    INNER JOIN ZGTPPT2180 AS B ON B~ZASSIGN_NO = A~ZASSIGN_NO
    INTO TABLE @DATA(LT_2180)
   WHERE A~VBELN = @PV_VBELN
     AND A~POSNR = @PV_POSNR
     AND A~LOEKZ NE 'X'
     AND B~ZORD_TYPE NE 'C9'. ""고 비활성만 제외

  IF LT_2180 IS NOT INITIAL.
    CLEAR PV_MVGR3.
    CLEAR LV_CHK_ZORD_TYPE.
    LOOP AT LT_2180 INTO DATA(LS_2180).
      IF LS_2180-ZORD_TYPE = 'C0'.
        ADD 1 TO LV_CHK_ZORD_TYPE.
      ENDIF.
    ENDLOOP.

    IF LV_CHK_ZORD_TYPE = LINES( LT_2180 ).
      PV_MVGR3 = ABAP_TRUE.
    ELSEIF LV_CHK_ZORD_TYPE = 0.
      CLEAR PV_MVGR3.
    ELSE.
      PV_MVGR3 = 'Y'.
    ENDIF.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form REFRESH_GRID
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GO_GRID_0100
*&---------------------------------------------------------------------*
FORM REFRESH_GRID  USING    PO_GRID TYPE REF TO CL_GUI_ALV_GRID.

  DATA: LS_SCROLL   TYPE LVC_S_STBL.

  LS_SCROLL-ROW = 'X'.
  LS_SCROLL-COL = 'X'.

  CASE PO_GRID.
    WHEN GO_GRID_0100.
      GO_GRID_0100->SET_FRONTEND_LAYOUT( IS_LAYOUT = GS_LAYOUT_0100 ).
      PERFORM SET_CELL_ATTRIBUTE_GRID_0100.
  ENDCASE.


  CALL METHOD PO_GRID->REFRESH_TABLE_DISPLAY
    EXPORTING
*     I_SOFT_REFRESH = 'X'
      IS_STABLE = LS_SCROLL.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_INIT_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_INIT_DATA .

* 플랜트명
  CLEAR GV_NAME1.
  GV_NAME1 = ZGTPP_CL_COMMON=>GET_PLANT_NAME( IV_WERKS = P_WERKS ).

* 저장위치명
  CLEAR GV_LGOBE.
  SELECT SINGLE LGOBE INTO GV_LGOBE
    FROM T001L
   WHERE LGORT EQ P_LGORT
     AND WERKS = P_WERKS.

  SELECT SINGLE FLD_02 AS WERKS, FLD_03 AS EKORG, FLD_04 AS EKGRP
    FROM ZGTPPT1010
    INTO @GS_EKORG
   WHERE MODULE_KIND = 'PP'
     AND CODEGRP = '2090'
     AND FLD_01 = ' '
     AND FLD_02 = @P_WERKS.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROC_CREATE_PR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PROC_CREATE_PR .

  DATA : LT_ROW TYPE LVC_T_ROW.
  DATA : LT_ROWS_EXCUTE TYPE LVC_T_ROW.
  DATA : LS_BACKUP LIKE GS_MAIN_DISP.
  DATA : LV_CHK_ERR.
  DATA : LV_TOT_CNT TYPE I.
  DATA : LV_TOT_CNT_C TYPE C LENGTH 11.
  DATA : LV_SUC_CNT TYPE I.
  DATA : LV_SUC_CNT_C TYPE C LENGTH 11.

  CALL METHOD GO_GRID_0100->GET_SELECTED_ROWS
    IMPORTING
      ET_INDEX_ROWS = LT_ROW.

  DELETE LT_ROW WHERE INDEX = 0. " 서브토탈 제외

  IF LT_ROW[] IS INITIAL.
    MESSAGE S006 DISPLAY LIKE 'E' WITH '선택된 라인이 없습니다.'(e01).
    RETURN.
  ENDIF.

* 변경 가능 대상인지 확인
  LOOP AT LT_ROW INTO DATA(LS_ROW).
    READ TABLE GT_MAIN_DISP ASSIGNING FIELD-SYMBOL(<LS_MAIN>) INDEX LS_ROW-INDEX.
    IF <LS_MAIN>-NOT_USE = ABAP_TRUE.
      MESSAGE S006 DISPLAY LIKE 'E' WITH '상품 PR 생성할 수 없는 판매오더가 선택 되었습니다.'(e02).
      RETURN.
    ENDIF.

    IF <LS_MAIN>-ZTYPE NE 'OM'.
      MESSAGE S006 DISPLAY LIKE 'E' WITH 'OM 유형만 상품 PR 생성 가능합니다.'(e03).
      RETURN.
    ENDIF.

    IF <LS_MAIN>-BANFN IS NOT INITIAL.
      MESSAGE S006 DISPLAY LIKE 'E' WITH '이미 생성된 상품 PR 있습니다.'(e05).
      RETURN.
    ENDIF.

    CASE <LS_MAIN>-MTART.
      WHEN 'MCHA' OR 'HAWA'.
      WHEN OTHERS.
        MESSAGE S006 DISPLAY LIKE 'E' WITH '상품 PR 생성 가능한 품목코드가 아닙니다.'(e04).
        RETURN.
    ENDCASE.

    APPEND LS_ROW TO LT_ROWS_EXCUTE.

  ENDLOOP.

  CLEAR GV_ANSWER.
  PERFORM POPUP_TO_CONFIRM_STEP USING 'N'
    ' '
    '상품 PR 생성하시겠습니까?'
    '생성확인'.
  IF GV_ANSWER NE 'J'.
    MESSAGE S003 DISPLAY LIKE 'E' WITH '작업이 취소 되었습니다.'.
    RETURN.
  ENDIF.

  LOOP AT LT_ROWS_EXCUTE INTO LS_ROW.

    READ TABLE GT_MAIN_DISP ASSIGNING <LS_MAIN> INDEX LS_ROW-INDEX.
    CLEAR LV_CHK_ERR.
    PERFORM CREATE_PR CHANGING <LS_MAIN> LV_CHK_ERR.
    IF LV_CHK_ERR NE ABAP_TRUE.
      ADD 1 TO LV_SUC_CNT.
    ENDIF.

  ENDLOOP.

* 화면재설정을 위한 초기화
  PERFORM GET_DATA_FROM_PP.

  LOOP AT LT_ROWS_EXCUTE INTO LS_ROW.
    READ TABLE GT_MAIN_DISP ASSIGNING <LS_MAIN> INDEX LS_ROW-INDEX.
    CLEAR LS_BACKUP.
    MOVE-CORRESPONDING <LS_MAIN> TO LS_BACKUP.
    READ TABLE GT_MAIN_DISP2 INTO DATA(LS_TOBE) WITH KEY VBELN = LS_BACKUP-VBELN
                                                         POSNR = LS_BACKUP-POSNR.
    IF SY-SUBRC EQ 0.
      MOVE-CORRESPONDING LS_TOBE TO <LS_MAIN>.
      <LS_MAIN>-STATUS = LS_BACKUP-STATUS.
      <LS_MAIN>-MESSAGE = LS_BACKUP-MESSAGE.
    ELSE.
      <LS_MAIN>-STATUS = 'E'.
      <LS_MAIN>-MESSAGE = '판매오더 정보가 변경되었습니다. 해당 품목을 찾을 수 없습니다.'.
    ENDIF.
  ENDLOOP.

  DATA : LV_MESSAGE(100).
  LV_TOT_CNT_C = LV_TOT_CNT.
  LV_SUC_CNT_C = LV_SUC_CNT.
  CONDENSE : LV_TOT_CNT_C, LV_SUC_CNT_C.


  PERFORM REFRESH_GRID USING GO_GRID_0100.
  LV_MESSAGE = |선택 주문 : { LV_TOT_CNT_C }건 중 구매요청 { LV_SUC_CNT_C }건 생성되었습니다.|.
  MESSAGE S006 WITH LV_MESSAGE.



ENDFORM.
*&---------------------------------------------------------------------*
*& Form CREATE_PR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- <LS_MAIN>
*&      <-- LV_CHK_ERR
*&---------------------------------------------------------------------*
FORM CREATE_PR  CHANGING PS_MAIN LIKE GS_MAIN_DISP
                         PV_CHK_ERR.

  DATA : LV_INLENGTH TYPE MENGE_D.
  DATA : LV_INLENGTH_C(20) TYPE C.
  DATA : LV_INFACTOR TYPE I.
  DATA : LV_INFACTOR_C(20) TYPE C.
  DATA : LS_PR_INFOR TYPE ZGTPPS0004.
  DATA : LT_CHART TYPE ZGTPPY0005.
  DATA : LV_DATE TYPE SY-DATUM.
  DATA : LV_PSMNG_C(30) TYPE C.
  DATA : LV_DPCBT TYPE MILL_DPCBT.

  CLEAR LV_DPCBT.
  SELECT SINGLE DPCBT FROM MARC
    INTO LV_DPCBT
   WHERE WERKS = P_WERKS
     AND MATNR = PS_MAIN-MATNR.

* 특성값 잆력대상( DBCDP 값이 존재하는건)
  IF LV_DPCBT IS NOT INITIAL.

    ZGTPP_CL_COMMON=>GET_CHA_MILLCA(
      EXPORTING
        IV_VBELN = PS_MAIN-VBELN
        IV_POSNR = PS_MAIN-POSNR
      IMPORTING
        EV_ZGTEINDLEN = LV_INLENGTH
        EV_ZGTEFACTOR = LV_INFACTOR ).

    IF LV_INLENGTH = 0.
      LV_INLENGTH = PS_MAIN-WMENG.
      LV_INFACTOR = 1.
    ENDIF.

    LV_INLENGTH_C = LV_INLENGTH.
    CONDENSE LV_INLENGTH_C.

    LV_INFACTOR_C = LV_INFACTOR.
    CONDENSE LV_INFACTOR_C.

    APPEND INITIAL LINE TO LT_CHART ASSIGNING FIELD-SYMBOL(<LS_CHART>).
    <LS_CHART>-ATNAM = 'SAP_MILLCA_LENGTH'.
    <LS_CHART>-ATWRT = LV_INLENGTH_C.

    APPEND INITIAL LINE TO LT_CHART ASSIGNING <LS_CHART>.
    <LS_CHART>-ATNAM = 'SAP_MILLCA_FACTOR'.
    <LS_CHART>-ATWRT = LV_INFACTOR_C.

  ENDIF.
  LV_PSMNG_C = PS_MAIN-WMENG.
  CONDENSE : LV_PSMNG_C.


  CLEAR LS_PR_INFOR.
  LS_PR_INFOR-BSART = 'NB'.
  LS_PR_INFOR-KNTTP = 'M'.
*  LV_DATE = GS_MAIN_DISP-EDATU - 1.
  LS_PR_INFOR-EEIND = SY-DATUM.
  LS_PR_INFOR-LPEIN = 'T'.
  LS_PR_INFOR-WERKS = P_WERKS.
  LS_PR_INFOR-EKGRP = GS_EKORG-EKGRP.
  LS_PR_INFOR-AFNAM = SY-UNAME.
  LS_PR_INFOR-MATNR = PS_MAIN-MATNR.
  LS_PR_INFOR-EKORG = GS_EKORG-EKORG.
  LS_PR_INFOR-MENGE = LV_PSMNG_C.
*  LS_PR_INFOR-INFNR = GS_PR_INFOR-INFNR.
*  LS_PR_INFOR-LIFNR = GS_PR_INFOR-LIFNR.
  LS_PR_INFOR-KDAUF = PS_MAIN-VBELN.
  LS_PR_INFOR-KDPOS = PS_MAIN-POSNR.

  DATA : LV_RESULT TYPE CHAR01.
  DATA : LV_BANFN TYPE BANFN.

  CALL FUNCTION 'ZGTPP_CREATE_PR_BY_BDC'
    EXPORTING
      IS_PR_INFOR = LS_PR_INFOR
    IMPORTING
      EV_RESULT   = LV_RESULT
      EV_BANFN    = LV_BANFN
    TABLES
      IT_CHART    = LT_CHART.

  IF LV_RESULT NE 'S'.
    PS_MAIN-STATUS = ICON_LED_RED.
    PS_MAIN-MESSAGE = '상품 PR 생성에 실패하였습니다.'.
    PV_CHK_ERR = ABAP_TRUE.
    RETURN.
  ENDIF.

  PS_MAIN-STATUS = ICON_LED_GREEN.
  PS_MAIN-MESSAGE = '상품 PR 생성 되었습니다.'.
  PS_MAIN-CHK_OEM = ABAP_TRUE.
  PS_MAIN-BANFN = LV_BANFN.
  PS_MAIN-BNFPO = '00010'..

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROC_DELETE_PR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PROC_DELETE_PR .

  DATA : LT_ROW TYPE LVC_T_ROW.
  DATA : LS_ROW TYPE LVC_S_ROW.
  DATA : LT_ROWS_EXCUTE TYPE LVC_T_ROW.
  DATA : LS_BACKUP LIKE GS_MAIN_DISP.
  DATA : LV_CHK_ERR.

  CALL METHOD GO_GRID_0100->GET_SELECTED_ROWS
    IMPORTING
      ET_INDEX_ROWS = LT_ROW.

  DELETE LT_ROW WHERE INDEX = 0. " 서브토탈 제외

  LOOP AT LT_ROW INTO LS_ROW.
    READ TABLE GT_MAIN_DISP INTO GS_MAIN_DISP INDEX LS_ROW-INDEX.

    IF GS_MAIN_DISP-CHK_OEM IS INITIAL.
      MESSAGE S003 DISPLAY LIKE 'E' WITH '상품 PR 생성되지 않은 라인이 있습니다.'.
      RETURN.
    ENDIF.

    IF GS_MAIN_DISP-NOT_DEL IS NOT INITIAL.
      MESSAGE S003 DISPLAY LIKE 'E' WITH '판매 문서에서 생성된 PR로 삭제 할 수 없습니다.'.
      RETURN.
    ENDIF.

    IF GS_MAIN_DISP-EBELN IS NOT INITIAL.
      MESSAGE S003 DISPLAY LIKE 'E' WITH '구매 오더로 생성된 구매 요청으로 삭제 할 수 없습니다.'.
      RETURN.
    ENDIF.

    APPEND LS_ROW TO LT_ROWS_EXCUTE.

  ENDLOOP.

  IF LT_ROWS_EXCUTE[] IS INITIAL.
    MESSAGE S003 DISPLAY LIKE 'E' WITH '선택된 라인이 없습니다.'.
    RETURN.
  ENDIF.

  CLEAR GV_ANSWER.
  PERFORM POPUP_TO_CONFIRM_STEP USING 'N'
    ' '
    '선택된 상품 PR 삭제 됩니다. 계속 진행 하시겠습니까?'
    '삭제확인'.
  IF GV_ANSWER NE 'J'.
    MESSAGE S003 DISPLAY LIKE 'E' WITH '작업이 취소 되었습니다.'.
    RETURN.
  ENDIF.

  DATA : LV_TOT_CNT TYPE I.
  DATA : LV_TOT_CNT_C TYPE C LENGTH 11.
  DATA : LV_SUC_CNT TYPE I.
  DATA : LV_SUC_CNT_C TYPE C LENGTH 11.

  LOOP AT LT_ROWS_EXCUTE INTO LS_ROW.
    READ TABLE GT_MAIN_DISP ASSIGNING FIELD-SYMBOL(<LS_MAIN>) INDEX LS_ROW-INDEX.

    CLEAR LV_CHK_ERR.
    ADD 1 TO LV_TOT_CNT.
    PERFORM DELETE_PR CHANGING <LS_MAIN> LV_CHK_ERR.
    IF LV_CHK_ERR NE ABAP_TRUE.
      ADD 1 TO LV_SUC_CNT.
    ENDIF.
  ENDLOOP.

* 화면재설정을 위한 초기화
  PERFORM GET_DATA_FROM_PP.

  LOOP AT LT_ROWS_EXCUTE INTO LS_ROW.
    READ TABLE GT_MAIN_DISP ASSIGNING <LS_MAIN> INDEX LS_ROW-INDEX.
    CLEAR LS_BACKUP.
    MOVE-CORRESPONDING <LS_MAIN> TO LS_BACKUP.
    READ TABLE GT_MAIN_DISP2 INTO DATA(LS_TOBE) WITH KEY VBELN = LS_BACKUP-VBELN
                                                         POSNR = LS_BACKUP-POSNR.
    IF SY-SUBRC EQ 0.
      MOVE-CORRESPONDING LS_TOBE TO <LS_MAIN>.
      <LS_MAIN>-STATUS = LS_BACKUP-STATUS.
      <LS_MAIN>-MESSAGE = LS_BACKUP-MESSAGE.
    ELSE.
      <LS_MAIN>-STATUS = 'E'.
      <LS_MAIN>-MESSAGE = '판매오더 정보가 변경되었습니다. 해당 품목을 찾을 수 없습니다.'.
    ENDIF.
  ENDLOOP.


  DATA : LV_MESSAGE(100).
  LV_TOT_CNT_C = LV_TOT_CNT.
  LV_SUC_CNT_C = LV_SUC_CNT.
  CONDENSE : LV_TOT_CNT_C, LV_SUC_CNT_C.

  PERFORM REFRESH_GRID USING GO_GRID_0100.
  LV_MESSAGE = |선택 구매요청 : { LV_TOT_CNT_C }건 중 구매요청 { LV_SUC_CNT_C }건 삭제되었습니다.|.
  MESSAGE S006 WITH LV_MESSAGE.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form DELETE_PR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- LV_CHK_ERR
*&---------------------------------------------------------------------*
FORM DELETE_PR  CHANGING PS_MAIN LIKE GS_MAIN_DISP
                                  PV_CHK_ERR.

  DATA : LV_NUMBER TYPE BAPIMEREQHEADER-PREQ_NO.
  DATA : LT_RETURN TYPE TABLE OF BAPIRET2.
  DATA : LT_PRITEM TYPE TABLE OF BAPIMEREQITEMIMP.
  DATA : LT_PRITEMX TYPE TABLE OF BAPIMEREQITEMX.

  LV_NUMBER = PS_MAIN-BANFN.

* Item 정보 입력
  APPEND INITIAL LINE TO LT_PRITEM ASSIGNING FIELD-SYMBOL(<LS_PRITEM>).
  <LS_PRITEM>-PREQ_ITEM = '0010'.
  <LS_PRITEM>-DELETE_IND = 'X'.

* ItemX 정보 입력
  APPEND INITIAL LINE TO LT_PRITEMX ASSIGNING FIELD-SYMBOL(<LS_PRITEMX>).
  <LS_PRITEMX>-PREQ_ITEM = '0010'.
  <LS_PRITEMX>-DELETE_IND = 'X'.

  CALL FUNCTION 'BAPI_PR_CHANGE'
    EXPORTING
      NUMBER  = LV_NUMBER
    TABLES
      RETURN  = LT_RETURN
      PRITEM  = LT_PRITEM
      PRITEMX = LT_PRITEMX.

  IF LINE_EXISTS( LT_RETURN[ TYPE = 'E' ] ).
    PV_CHK_ERR = ABAP_TRUE.
    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

    PS_MAIN-STATUS = ICON_LED_RED.
    PS_MAIN-MESSAGE = '상품 PR 삭제 실패하였습니다.'.

  ELSE.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        WAIT = ABAP_TRUE.

    PS_MAIN-STATUS = ICON_LED_GREEN.
    PS_MAIN-MESSAGE = '상품 PR 삭제되었습니다.'.
    CLEAR : PS_MAIN-BANFN, PS_MAIN-BNFPO, PS_MAIN-LFDAT, PS_MAIN-STATU, PS_MAIN-CHK_OEM.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_SORTTAB_GRID_0100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_SORTTAB_GRID_0100 .

  REFRESH GT_SORT_0100.

  PERFORM SET_SORT_TAB TABLES GT_SORT_0100
                            USING : 1 'VBELN'  'X' '' '',
                                    2 'POSNR'  'X' '' ''.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_SORT_TAB
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_SORT_0100
*&      --> P_1
*&      --> P_
*&      --> P_
*&      --> P_
*&      --> P_
*&---------------------------------------------------------------------*
FORM SET_SORT_TAB  TABLES   PT_SORTTAB STRUCTURE LVC_S_SORT
                   USING    PV_POS
                               PV_FIELDNAME
                               PV_UP
                               PV_DOWN
                               PV_SUBTOT.

  DATA : LS_SORT TYPE LVC_S_SORT.
  LS_SORT-SPOS = PV_POS.
  LS_SORT-FIELDNAME = PV_FIELDNAME.
  LS_SORT-UP = PV_UP.
  LS_SORT-DOWN = PV_DOWN.
  LS_SORT-SUBTOT =  PV_SUBTOT.
  APPEND LS_SORT TO PT_SORTTAB.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form DOUBLE_CLICK
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> SENDER
*&      --> E_ROW
*&      --> E_COLUMN
*&---------------------------------------------------------------------*
FORM DOUBLE_CLICK  USING    P_SENDER TYPE REF TO CL_GUI_ALV_GRID
                            P_ROW TYPE LVC_S_ROW
                            P_COLUMN TYPE LVC_S_COL.

  DATA : LV_NUM(2) TYPE N.
  DATA : LV_CHK_USEFIELD.
  DATA : LV_FIELDNAME TYPE FIELDNAME.
  DATA : LV_FIELDNAME02 TYPE FIELDNAME.
  DATA : LV_SEQNO TYPE I.

  CHECK P_ROW-INDEX > 0.

  CASE P_SENDER.
    WHEN GO_GRID_0100.
      READ TABLE GT_MAIN_DISP INTO DATA(LS_MAIN) INDEX P_ROW-INDEX.
      CASE P_COLUMN-FIELDNAME.
        WHEN 'VBELN' OR 'POSNR'.
          IF LS_MAIN-VBELN IS NOT INITIAL.
            SET PARAMETER ID 'AUN' FIELD LS_MAIN-VBELN.
            CALL TRANSACTION 'VA03' AND SKIP FIRST SCREEN.
            SET PARAMETER ID 'AUN' FIELD ''.
          ENDIF.

        WHEN 'BANFN' OR 'BNFPO'.
          IF LS_MAIN-BANFN IS NOT INITIAL.
            SET PARAMETER ID 'BAN' FIELD LS_MAIN-BANFN.
            CALL TRANSACTION 'ME53N'.
            SET PARAMETER ID 'BAN' FIELD ''.
          ENDIF.
        WHEN 'EBELN' OR 'EBELP'.
          IF LS_MAIN-EBELN IS NOT INITIAL.
            SET PARAMETER ID 'BES' FIELD LS_MAIN-EBELN.
            CALL TRANSACTION 'ME23N' AND SKIP FIRST SCREEN.
          ENDIF.
      ENDCASE.
  ENDCASE.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form EVENT_HANDLER_REGISTER
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GO_GRID_0100
*&---------------------------------------------------------------------*
FORM EVENT_HANDLER_REGISTER  USING    PO_GRID TYPE REF TO CL_GUI_ALV_GRID.

  IF GO_EVENT_HANDLER IS NOT BOUND.
    CREATE OBJECT GO_EVENT_HANDLER.
  ENDIF.

  CASE PO_GRID.
    WHEN GO_GRID_0100.
*// Event Handler ##
      SET HANDLER GO_EVENT_HANDLER->HANDLE_DOUBLE_CLICK          FOR PO_GRID.
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_INIT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_INIT .

  S_ERDAT-LOW = SY-DATUM+0(6) && '01'.
  S_ERDAT-HIGH = S_ERDAT-LOW.
  PERFORM GET_LAST_DAY_OF_MONTH CHANGING S_ERDAT-HIGH.
  APPEND S_ERDAT.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_LAST_DAY_OF_MONTH
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- S_ERDAT_HIGH
*&---------------------------------------------------------------------*
FORM GET_LAST_DAY_OF_MONTH  CHANGING PV_DATE TYPE SY-DATUM.

  CALL FUNCTION 'LAST_DAY_OF_MONTHS'
    EXPORTING
      DAY_IN            = PV_DATE
    IMPORTING
      LAST_DAY_OF_MONTH = PV_DATE
    EXCEPTIONS
      DAY_IN_NO_DATE    = 1
      OTHERS            = 2.
  .
  IF SY-SUBRC <> 0.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_STATUS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> <LS_AFPO>_AUFNR
*&      <-- LV_STATUS
*&---------------------------------------------------------------------*
FORM GET_STATUS  USING    PV_AUFNR
                 CHANGING PV_STATUS.

  DATA  : LV_STTXT LIKE RC65D-STTXT,
          LV_INDEX LIKE SY-INDEX,
          LT_TJ02T LIKE TJ02T OCCURS 0 WITH HEADER LINE,
          LV_OBJNR LIKE AUFK-OBJNR,
          LV_TEXT  LIKE ZPPS300-TEXT.

*  DATA : LV_OBJNR TYPE JEST-OBJNR.
  DATA : LV_USER_LINE TYPE BSVX-STTXT.

  RANGES: LR_STATUS      FOR RC65D-STATUS.

  CALL FUNCTION 'Z_PP_RETURN_ORDER_STATUS'
    EXPORTING
      IM_AUFNR        = PV_AUFNR
    TABLES
      ET_STTXT        = LT_TJ02T
    EXCEPTIONS
      NO_SELECTION    = 1
      NOT_FOUND_OBJNR = 2
      OTHERS          = 3.

  REFRESH: LR_STATUS.
  CLEAR: LR_STATUS, LV_INDEX.
  LOOP AT LT_TJ02T.
    MOVE: 'I'                    TO LR_STATUS-SIGN,
          'EQ'                   TO LR_STATUS-OPTION,
          LT_TJ02T-TXT04         TO LR_STATUS-LOW.
    APPEND LR_STATUS.       CLEAR LR_STATUS.
  ENDLOOP.

  LOOP AT LT_TJ02T.
    CASE LT_TJ02T-TXT04.
      WHEN 'TECO' OR 'DLFL' OR 'CLSD' OR 'VCAL' OR 'LKD'.
        PV_STATUS = 'DEL'.
        RETURN.
      WHEN OTHERS.
    ENDCASE.
  ENDLOOP.

  IF LINE_EXISTS( LT_TJ02T[ TXT04 = 'DLV' ] ).
    PV_STATUS = 'DLV'.
  ENDIF.

ENDFORM.
