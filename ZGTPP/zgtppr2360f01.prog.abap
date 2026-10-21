*&---------------------------------------------------------------------*
*& Include          ZGTPPR3090F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form MODIFY_FIRST_SCREEN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM MODIFY_FIRST_SCREEN .

  CASE ABAP_TRUE.
    WHEN P_ONLINE.
      GV_TEXT1 = '판매오더 정보 갱신 재처리'(005).
      GV_TEXT2 = '처리결과 조회'(006).
    WHEN P_BATCH.
      GV_TEXT1 = '판매오더 정보 갱신'(007).
      GV_TEXT2 = '판매오더 정보 갱신 재처리'(005).
  ENDCASE.

  LOOP AT SCREEN.
    CASE SCREEN-GROUP1.
      WHEN 'S01'.
        IF P_BATCH = ABAP_TRUE AND P_PROC = ABAP_TRUE.
          SCREEN-ACTIVE = 0.
        ELSE.
          SCREEN-ACTIVE = 1.
        ENDIF.
        MODIFY SCREEN.
      WHEN 'S02'.
        IF P_ONLINE = ABAP_TRUE AND P_DISP = ABAP_TRUE.
          SCREEN-ACTIVE = 1.
        ELSE.
          SCREEN-ACTIVE = 0.
        ENDIF.
        MODIFY SCREEN.
      WHEN 'S03'.
        IF P_BATCH = ABAP_TRUE AND P_PROC = ABAP_TRUE.
          SCREEN-ACTIVE = 1.
          SCREEN-REQUIRED = 2.
        ELSE.
          SCREEN-ACTIVE = 0.
          SCREEN-REQUIRED = 0.
        ENDIF.
        MODIFY SCREEN.
      WHEN 'S04'.
        IF P_BATCH = ABAP_TRUE AND P_PROC = ABAP_TRUE.
          SCREEN-ACTIVE = 1.
        ELSE.
          SCREEN-ACTIVE = 0.
        ENDIF.
        MODIFY SCREEN.
    ENDCASE.

  ENDLOOP.

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

  REFRESH : GT_2460, GT_MAIN_DISP.
  CLEAR GV_TITLE.

  CASE ABAP_TRUE.
    WHEN P_ONLINE.
      CASE ABAP_TRUE.
        WHEN P_PROC.
          GV_TITLE = TEXT-005.
          PERFORM GET_RE_PROC_DATA.
        WHEN P_DISP.
          GV_TITLE = TEXT-006.
          PERFORM GET_DISP_DATA.
      ENDCASE.
    WHEN P_BATCH.
      CASE ABAP_TRUE.
        WHEN P_PROC.
          PERFORM MAKE_UPDATE_DATA.
        WHEN P_DISP.
          GV_TITLE = TEXT-005.
          PERFORM GET_RE_PROC_DATA.
      ENDCASE.
  ENDCASE.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHK_VALIDATION
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CHK_VALIDATION .

  IF P_BATCH = ABAP_TRUE AND P_PROC = ABAP_TRUE.

    IF P_ASSIGN IS INITIAL.
      MESSAGE S006 DISPLAY LIKE 'E' WITH '주문할당번호' '는(은) 필수값 입니다.'.
      SET CURSOR FIELD P_ASSIGN.
      LEAVE LIST-PROCESSING.
    ENDIF.

    IF P_VBELN IS INITIAL.
      MESSAGE S006 DISPLAY LIKE 'E' WITH '판매오더번호' '는(은) 필수값 입니다.'.
      SET CURSOR FIELD P_VBELN.
      LEAVE LIST-PROCESSING.
    ENDIF.

    IF P_POSNR IS INITIAL.
      MESSAGE S006 DISPLAY LIKE 'E' WITH '판매오더항번' '는(은) 필수값 입니다.'.
      SET CURSOR FIELD P_POSNR.
      LEAVE LIST-PROCESSING.
    ENDIF.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROC
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PROC .

  IF P_BATCH = ABAP_TRUE .

    IF P_PROC = ABAP_TRUE.
      PERFORM EXCUTE_RECEIVE_STOCD_LINK TABLES GT_2460.
      PERFORM SAVE_RESULT_2460 TABLES GT_2460.
      READ TABLE GT_2460 INTO DATA(LS_2460) INDEX 1.
      CASE LS_2460-PROC_STAT.
        WHEN 'S'.
          MESSAGE S006 WITH TEXT-007 '되었습니다'(m01).
        WHEN 'E'.
          MESSAGE S006 DISPLAY LIKE 'E' WITH LS_2460-STAT_MSG.
      ENDCASE.
    ELSE.
      IF GT_2460 IS NOT INITIAL.
        PERFORM PROC_BATCH_PROC.
        MESSAGE S006 WITH TEXT-005 '되었습니다'(m01).
      ELSE.
        MESSAGE S006 WITH TEXT-005 '대상이 없습니다'(m02).
      ENDIF.

    ENDIF.
  ELSE.
    CALL SCREEN '0100'.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form MAKE_UPDATE_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM MAKE_UPDATE_DATA .

  APPEND INITIAL LINE TO GT_2460 ASSIGNING FIELD-SYMBOL(<LS_2460>).
* Link 업데이트요청번호
  PERFORM   NUMBER_GET_NEXT CHANGING <LS_2460>-UPDRQ.
  <LS_2460>-UPD_TYPE = 'S1'.
  <LS_2460>-WERKS = P_WERKS.
  <LS_2460>-ZASSIGN_NO = P_ASSIGN.
  <LS_2460>-VBELN = P_VBELN.
  <LS_2460>-POSNR = P_POSNR.
  <LS_2460>-MVGR3 = P_MVGR3.
  <LS_2460>-LIFSP = P_LIFSP.
  <LS_2460>-FIXMG = P_FIXMG.
  <LS_2460>-CRDAT = SY-DATUM.
  <LS_2460>-CRTIM = SY-UZEIT.
  <LS_2460>-CRNAM = SY-UZEIT.
  <LS_2460>-CHDAT = SY-DATUM.
  <LS_2460>-CHTIM = SY-UZEIT.
  <LS_2460>-CHNAM = SY-UZEIT.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form NUMBER_GET_NEXT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- <LS_2460>_UPDRQ
*&---------------------------------------------------------------------*
FORM NUMBER_GET_NEXT  CHANGING PV_UPDRQ.

  CALL FUNCTION 'NUMBER_GET_NEXT'
    EXPORTING
      NR_RANGE_NR             = '03'
      OBJECT                  = 'ZGTPP_GORD'
    IMPORTING
      NUMBER                  = PV_UPDRQ
    EXCEPTIONS
      INTERVAL_NOT_FOUND      = 1
      NUMBER_RANGE_NOT_INTERN = 2
      OBJECT_NOT_FOUND        = 3
      QUANTITY_IS_0           = 4
      QUANTITY_IS_NOT_1       = 5
      INTERVAL_OVERFLOW       = 6
      BUFFER_OVERFLOW         = 7
      OTHERS                  = 8.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_RE_PROC_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_RE_PROC_DATA .

  PERFORM GET_DATA_FROM_2460.

  DELETE GT_2460 WHERE PROC_STAT = 'S'.

  IF P_ONLINE = ABAP_TRUE.
    PERFORM MAKE_DISP_TABLE.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_DATA_FROM_2460
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_DATA_FROM_2460 .

  SELECT * FROM ZGTPPT2460
    INTO TABLE GT_2460
   WHERE WERKS = P_WERKS
     AND UPDRQ IN S_UPDRQ
     AND ZASSIGN_NO IN S_ASSIGN
     AND VBELN IN S_VBELN
     AND POSNR IN S_POSNR
     AND MVGR3 IN S_MVGR3
     AND LIFSP IN S_LIFSP
     AND FIXMG IN S_FIXMG
     AND CRDAT IN S_CRDAT.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form MAKE_DISP_TABLE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM MAKE_DISP_TABLE .

  LOOP AT GT_2460 INTO DATA(LS_2460).
    APPEND INITIAL LINE TO GT_MAIN_DISP ASSIGNING FIELD-SYMBOL(<LS_MAIN>).
    MOVE-CORRESPONDING LS_2460 TO <LS_MAIN>.

    CASE LS_2460-PROC_STAT.
      WHEN 'E'.
        <LS_MAIN>-STATUS = ICON_LED_RED .
      WHEN 'S'.
        <LS_MAIN>-STATUS = ICON_LED_GREEN.
      WHEN OTHERS.
        <LS_MAIN>-STATUS = ICON_LED_INACTIVE.
    ENDCASE.

    <LS_MAIN>-NAME1 = ZGTPP_CL_COMMON=>GET_PLANT_NAME( IV_WERKS = <LS_MAIN>-WERKS ).
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_DISP_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_DISP_DATA .

  PERFORM GET_DATA_FROM_2460.

  IF S_PSTAT[] IS NOT INITIAL.
    DELETE GT_2460 WHERE PROC_STAT NOT IN S_PSTAT.
  ENDIF.

  PERFORM MAKE_DISP_TABLE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form EXCUTE_RECEIVE_STOCD_LINK
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_2460
*&---------------------------------------------------------------------*
FORM EXCUTE_RECEIVE_STOCD_LINK  TABLES   PT_2460 STRUCTURE ZGTPPT2460.

  LOOP AT PT_2460 ASSIGNING FIELD-SYMBOL(<LS_2460>).

    CALL FUNCTION 'ZGTSD_RECEIVE_STOCK_LINK_INFO'
      EXPORTING
        I_VBELN = <LS_2460>-VBELN
        I_POSNR = <LS_2460>-POSNR
        I_MVGR3 = <LS_2460>-MVGR3
        I_LIFSP = <LS_2460>-LIFSP
        I_FIXMG = <LS_2460>-FIXMG
      IMPORTING
        E_TYPE  = <LS_2460>-PROC_STAT
        E_MSG   = <LS_2460>-STAT_MSG.

    <LS_2460>-CHDAT = SY-DATUM.
    <LS_2460>-CHTIM = SY-UZEIT.
    <LS_2460>-CHNAM = SY-UNAME.

    IF <LS_2460>-STAT_MSG CP '영업문서 *을(를) 변경하지 않았습니다'.
      <LS_2460>-PROC_STAT = 'S'.
    ENDIF.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form REFRESH_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM REFRESH_DATA .

  DATA : LT_2460 TYPE TABLE OF ZGTPPT2460.

* refresh 처리
  LT_2460 = GT_2460.
  REFRESH GT_2460.
  REFRESH GT_MAIN_DISP.

  SELECT * FROM ZGTPPT2460
    INTO TABLE GT_2460
    FOR ALL ENTRIES IN LT_2460
   WHERE WERKS = P_WERKS
     AND UPDRQ = LT_2460-UPDRQ.

  PERFORM MAKE_DISP_TABLE.

  PERFORM REFRESH_GRID USING GO_GRID_0100.

ENDFORM.
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

  CLEAR GS_LAYOUT_0100.
  GS_LAYOUT_0100-CWIDTH_OPT = ABAP_TRUE.
  GS_LAYOUT_0100-NO_ROWINS = ABAP_TRUE.
  GS_LAYOUT_0100-SEL_MODE   = 'D'.
  GS_LAYOUT_0100-ZEBRA   = ABAP_TRUE.

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
  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      I_PROGRAM_NAME         = SY-REPID
      I_INCLNAME             = 'ZGTPPR2360TOP'
      I_INTERNAL_TABNAME     = 'GS_MAIN_DISP'
      I_BYPASSING_BUFFER     = ABAP_TRUE
    CHANGING
      CT_FIELDCAT            = LT_FCAT_SLIS
    EXCEPTIONS
      INCONSISTENT_INTERFACE = 1
      PROGRAM_ERROR          = 2
      OTHERS                 = 3.

  REFRESH GT_FIELDCAT_0100.

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

  LOOP AT GT_FIELDCAT_0100 ASSIGNING FIELD-SYMBOL(<LS_FCAT>).
    CLEAR <LS_FCAT>-KEY.
    CASE   <LS_FCAT>-FIELDNAME.
      WHEN 'STATUS'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '처리 상태'(f01).
        <LS_FCAT>-JUST  = 'C'.
        <LS_FCAT>-ICON  = ABAP_TRUE.
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
        <LS_FCAT>-EMPHASIZE  = 'C600'.
      WHEN 'STAT_MSG'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '처리 메시지'(f02).
        <LS_FCAT>-JUST  = 'L'.
        <LS_FCAT>-ICON  = ABAP_TRUE.
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
        <LS_FCAT>-EMPHASIZE  = 'C600'.
      WHEN 'UPDRQ'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = 'Link업데이트 요청 번호'(f03).
        <LS_FCAT>-JUST  = 'L'.
        <LS_FCAT>-ICON  = ABAP_TRUE.
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
        <LS_FCAT>-EMPHASIZE  = 'C100'.
      WHEN 'UPD_TYPE'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '처리 구분'(f04).
        <LS_FCAT>-JUST  = 'C'.
      WHEN 'LOEKZ'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '삭제 지시자'(f05).
        <LS_FCAT>-JUST  = 'C'.
      WHEN 'WERKS'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '플랜트'(f06).
        <LS_FCAT>-JUST  = 'C'.
      WHEN 'NAME1'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '플랜트 내역'(f07).
        <LS_FCAT>-JUST  = 'L'.
      WHEN 'ZASSIGN_NO'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '주문할당번호'(f08).
        <LS_FCAT>-JUST  = 'C'.
      WHEN 'VBELN'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '판매오더번호'(f09).
        <LS_FCAT>-JUST  = 'C'.
      WHEN 'POSNR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '판매오더항번'(f10).
        <LS_FCAT>-JUST  = 'C'.
      WHEN 'MVGR3'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '자재그룹3'(f11).
        <LS_FCAT>-JUST  = 'C'.
      WHEN 'LIFSP'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '납품보류'(f12).
        <LS_FCAT>-JUST  = 'C'.
      WHEN 'FIXMG'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = 'SM/OM'(f13).
        <LS_FCAT>-JUST  = 'C'.
      WHEN 'CRDAT'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '생성일자'(f14).
        <LS_FCAT>-JUST  = 'C'.
      WHEN 'CRTIM'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '생성시간'(f15).
        <LS_FCAT>-JUST  = 'C'.
      WHEN 'CRNAM'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '생성자'(f16).
        <LS_FCAT>-JUST  = 'C'.
      WHEN 'CHDAT'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '변경일자'(f17).
        <LS_FCAT>-JUST  = 'C'.
      WHEN 'CHTIM'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '변경시간'(f18).
        <LS_FCAT>-JUST  = 'C'.
      WHEN 'CHNAM'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '변경자'(f19).
        <LS_FCAT>-JUST  = 'C'.
    ENDCASE.
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

  REFRESH GT_EXCLUDE_0100.

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
                            USING : 1 'UPDRQ' 'X' '' ''.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_sort_tab
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
      I_BYPASSING_BUFFER   = ABAP_TRUE
    CHANGING
      IT_OUTTAB            = GT_MAIN_DISP
      IT_SORT              = GT_SORT_0100
      IT_FIELDCATALOG      = GT_FIELDCAT_0100.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROC_REPROC
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PROC_REPROC .

  DATA : LT_ROW TYPE LVC_T_ROW.
  DATA : LT_MOSU TYPE TABLE OF ZGTPPT2460.

  CALL METHOD GO_GRID_0100->GET_SELECTED_ROWS
    IMPORTING
      ET_INDEX_ROWS = LT_ROW.

  DELETE LT_ROW WHERE INDEX = 0. " 서브토탈 제외

  LOOP AT LT_ROW INTO DATA(LS_ROW).
    READ TABLE GT_MAIN_DISP INTO GS_MAIN_DISP INDEX LS_ROW-INDEX.
    IF GS_MAIN_DISP-STATUS NE ICON_LED_GREEN.
      READ TABLE GT_2460 INTO DATA(LS_2460) WITH KEY UPDRQ = GS_MAIN_DISP-UPDRQ.
      IF SY-SUBRC EQ 0.
        APPEND LS_2460 TO LT_MOSU.
      ENDIF.
    ENDIF.
  ENDLOOP.

  IF LT_MOSU IS NOT INITIAL.

    CLEAR GV_ANSWER.
    PERFORM POPUP_TO_CONFIRM_STEP USING 'N'
      ' '
      '판매오더 정보 갱신 재처리 하시겠습니까?'
      '재처리확인'.
    IF GV_ANSWER NE 'J'.
      MESSAGE S003 DISPLAY LIKE 'E' WITH '작업이 취소 되었습니다.'.
      RETURN.
    ENDIF.

    PERFORM EXCUTE_RECEIVE_STOCD_LINK TABLES LT_MOSU.

    PERFORM SAVE_RESULT_2460 TABLES LT_MOSU.

    PERFORM REFRESH_DATA.

    MESSAGE S006 WITH TEXT-005 '되었습니다'(m01).

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

  CALL METHOD PO_GRID->REFRESH_TABLE_DISPLAY
    EXPORTING
*     I_SOFT_REFRESH = 'X'
      IS_STABLE = LS_SCROLL.

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
*& Form PROC_BATCH_PROC
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PROC_BATCH_PROC .

  DATA : LT_2460 TYPE TABLE OF ZGTPPT2460.

  LT_2460 = GT_2460.

  SORT LT_2460 BY VBELN
                  POSNR
                  UPDRQ DESCENDING.
  DELETE ADJACENT DUPLICATES FROM LT_2460 COMPARING VBELN POSNR.

  PERFORM EXCUTE_RECEIVE_STOCD_LINK TABLES LT_2460.

  LOOP AT LT_2460 INTO DATA(LS_2460).
    LOOP AT GT_2460 ASSIGNING FIELD-SYMBOL(<LS_2460>) WHERE VBELN = LS_2460-VBELN
                                                        AND POSNR = LS_2460-POSNR.
      <LS_2460>-PROC_STAT = LS_2460-PROC_STAT.
      <LS_2460>-STAT_MSG = LS_2460-STAT_MSG.
      <LS_2460>-CHDAT = LS_2460-CHDAT.
      <LS_2460>-CHTIM = LS_2460-CHTIM.
      <LS_2460>-CHNAM = LS_2460-CHNAM.
    ENDLOOP.
  ENDLOOP.


  PERFORM SAVE_RESULT_2460 TABLES GT_2460.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SAVE_RESULT_2460
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PT_2460
*&---------------------------------------------------------------------*
FORM SAVE_RESULT_2460  TABLES   PT_2460 STRUCTURE ZGTPPT2460.

  MODIFY ZGTPPT2460 FROM TABLE PT_2460[].
  IF SY-SUBRC EQ 0.
    COMMIT WORK AND WAIT.
  ENDIF.


ENDFORM.
