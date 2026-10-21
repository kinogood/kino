*&---------------------------------------------------------------------*
*& Include          ZGTPPI1030F02
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form add_exclude_toolbar_button
*&---------------------------------------------------------------------*
FORM ADD_EXCLUDE_TOOLBAR_BUTTON TABLES PT_TABLE USING PV_VALUE.

  DATA: LV_EXCLUDE TYPE UI_FUNC.

  LV_EXCLUDE = PV_VALUE.
*& 결과적으로 GT_EXCLUDE에 제거할 버튼 저장
  APPEND LV_EXCLUDE TO PT_TABLE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form fill_field_catalogs
*&---------------------------------------------------------------------*
FORM FILL_FIELD_CATALOGS TABLES PT_FIELDCAT TYPE LVC_T_FCAT
                          USING  PV_GUB
                                 PV_FNAME
                                 PV_VALUE.
*& 'S' -> Structure에 필드 속성 값 Setting을 Start 시점
*& 'E' -> Structure의 내용을 필드 카타로그 테이블에 저장 시점
  IF PV_GUB = 'S'.
    CLEAR GS_FIELDCAT.
  ENDIF.
*& 출력될 Field 속성을 정의해서 필드 카타로그 테이블에 저장
  DATA LV_FNAME(40).
  FIELD-SYMBOLS <FS_FIELD> TYPE ANY.

  CONCATENATE 'GS_FIELDCAT-' PV_FNAME INTO LV_FNAME.

  ASSIGN (LV_FNAME) TO <FS_FIELD>.
  <FS_FIELD> = PV_VALUE.

  IF PV_GUB = 'E'.
    APPEND GS_FIELDCAT TO PT_FIELDCAT.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form toolbar_proc
*&---------------------------------------------------------------------*
FORM TOOLBAR_PROC USING PS_OBJECT TYPE REF TO CL_ALV_EVENT_TOOLBAR_SET
                                  PV_INTERACTIVE.

  DATA : LS_TOOLBAR  TYPE STB_BUTTON.

  MOVE   3             TO  LS_TOOLBAR-BUTN_TYPE.
  APPEND LS_TOOLBAR TO  PS_OBJECT->MT_TOOLBAR.

  CLEAR LS_TOOLBAR.
**  MOVE 'SELA'               TO  ls_toolbar-function.
**  MOVE icon_select_all      TO  ls_toolbar-icon.
**  MOVE '전체선택'           TO  ls_toolbar-quickinfo.
**&  MOVE '전체선택'           TO  ls_toolbar-text.
*  MOVE ' '                  TO  ls_toolbar-disabled.
*  APPEND ls_toolbar         TO  r_object->mt_toolbar.
*
**&  MOVE   3                  TO  ls_toolbar-butn_type.
**&  APPEND ls_toolbar         TO  r_object->mt_toolbar.
*
*  CLEAR ls_toolbar.
*  MOVE 'DSEL'               TO  ls_toolbar-function.
*  MOVE icon_deselect_all    TO  ls_toolbar-icon.
*  MOVE '전체해제'           TO  ls_toolbar-quickinfo.
**&  MOVE '전체해제'           TO  ls_toolbar-text.
*  MOVE ' '                  TO  ls_toolbar-disabled.
*  APPEND ls_toolbar         TO  r_object->mt_toolbar.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form user_command_proc
*&---------------------------------------------------------------------*
FORM USER_COMMAND_PROC USING PV_UCOMM.

*  CASE r_ucomm.
*    WHEN ''.
*  ENDCASE.

*  PERFORM refresh_grid_display .

ENDFORM.
*&---------------------------------------------------------------------*
*& Form after_user_command
*&---------------------------------------------------------------------*
FORM AFTER_USER_COMMAND USING PV_UCOMM.

*  CASE pv_ucomm.
*    WHEN '&REFRESH'.
*  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form data_changed
*&---------------------------------------------------------------------*
FORM DATA_CHANGED USING PR_DATA_CHANGED TYPE REF TO CL_ALV_CHANGED_DATA_PROTOCOL
                                       PV_ONF4 TYPE CHAR1.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form hotspot_click
*&---------------------------------------------------------------------*
FORM HOTSPOT_CLICK USING PV_ROW_ID     TYPE LVC_S_ROW
                                     PV_COLUMN_ID TYPE LVC_S_COL.

  CASE PV_COLUMN_ID-FIELDNAME.

    WHEN 'MATNR'. "품목코드


      CLEAR GS_DISP.
      READ TABLE GT_DISP INTO GS_DISP INDEX PV_ROW_ID-INDEX.

      SET PARAMETER ID 'MAT' FIELD GS_DISP-MATNR.



      CALL TRANSACTION 'MM03' AND SKIP FIRST SCREEN.

  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form double_click
*&---------------------------------------------------------------------*
FORM DOUBLE_CLICK USING PV_ROW PV_COLUMN.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form button_click
*&---------------------------------------------------------------------*
FORM BUTTON_CLICK USING PS_COL_ID  TYPE  LVC_S_COL
                                 PS_ROW_NO  TYPE  LVC_S_ROID.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form onf4_proc
*&---------------------------------------------------------------------*
FORM ONF4_PROC USING PV_FIELDNAME   TYPE LVC_FNAME
                                 PV_FIELDVALUE  TYPE LVC_VALUE
                                 PS_ROW_NO     TYPE LVC_S_ROID
                                 PR_EVENT_DATA TYPE REF TO CL_ALV_EVENT_DATA
                                 PT_BAD_CELLS  TYPE LVC_T_MODI
                                 PV_DISPLAY     TYPE CHAR01.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_object_grid_0100
*&---------------------------------------------------------------------*
FORM SET_OBJECT_GRID_0100 .

  CREATE OBJECT GO_DOCKING_CONTAINER
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
*화면 분할
  CREATE OBJECT GO_SPLITTER
    EXPORTING
      PARENT  = GO_DOCKING_CONTAINER
      ROWS    = 1
      COLUMNS = 1.
* top 컨테이너
  CALL METHOD GO_SPLITTER->GET_CONTAINER
    EXPORTING
      ROW       = 1
      COLUMN    = 1
    RECEIVING
      CONTAINER = GO_CONTAIN_0100.
** bottom 컨테이너
*  CALL METHOD GO_SPLITTER->GET_CONTAINER
*    EXPORTING
*      ROW       = 2
*      COLUMN    = 1
*    RECEIVING
*      CONTAINER = GO_CONTAIN_0101.

  CREATE OBJECT GO_GRID_0100
    EXPORTING
      I_PARENT      = GO_CONTAIN_0100
      I_APPL_EVENTS = ABAP_TRUE.

*  CREATE OBJECT go_grid_0101
*    EXPORTING
*      i_parent      = go_contain_0101
*      i_appl_events = abap_true.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form event_handler_register
*&---------------------------------------------------------------------*
FORM EVENT_HANDLER_REGISTER USING PO_GRID TYPE REF TO CL_GUI_ALV_GRID.
*& Edit  이벤트 등록
* IF MC_EVT_MODIFY  -> 바로 수정됨.
  CALL METHOD PO_GRID->REGISTER_EDIT_EVENT
    EXPORTING
      I_EVENT_ID = CL_GUI_ALV_GRID=>MC_EVT_MODIFIED.
*& Event Handler 등록
  CREATE OBJECT GO_EVENT_HANDLER.

  SET HANDLER GO_EVENT_HANDLER->HANDLE_TOOLBAR
          FOR PO_GRID.
  SET HANDLER GO_EVENT_HANDLER->HANDLE_USER_COMMAND
          FOR PO_GRID.
  SET HANDLER GO_EVENT_HANDLER->HANDLE_DATA_CHANGED
          FOR PO_GRID.
  SET HANDLER GO_EVENT_HANDLER->HANDLE_DATA_CHANGED_FINISHED
          FOR PO_GRID.
  SET HANDLER GO_EVENT_HANDLER->HANDLE_HOTSPOT_CLICK
          FOR PO_GRID.
  SET HANDLER GO_EVENT_HANDLER->HANDLE_DOUBLE_CLICK
          FOR PO_GRID.
  SET HANDLER GO_EVENT_HANDLER->HANDLE_AFTER_USER_COMMAND
          FOR PO_GRID.
  SET HANDLER GO_EVENT_HANDLER->HANDLE_BUTTON_CLICK
          FOR PO_GRID.
  SET HANDLER GO_EVENT_HANDLER->HANDLE_ONF4
          FOR PO_GRID.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_layout_grid_0100
*&---------------------------------------------------------------------*
FORM SET_LAYOUT_GRID_0100 .
*& General display options
  CLEAR GS_LAYOUT_0100.
  GS_LAYOUT_0100-CWIDTH_OPT = 'X'.
  GS_LAYOUT_0100-SEL_MODE   = 'D'.
*  ps_layocat-edit       = 'E'.
  GS_LAYOUT_0100-NO_ROWMARK = ' '.           "선택버튼 비활성
  GS_LAYOUT_0100-STYLEFNAME = 'CELLTAB'.       "셀스타일
  GS_LAYOUT_0100-CTAB_FNAME = 'CELLSCOL'.    "셀색상
*&  ps_layocat-smalltitle = 'X'.           "작은타이틀.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_fieldcat_grid_0100
*&---------------------------------------------------------------------*
FORM SET_FIELDCAT_GRID_0100 .


  PERFORM SET_FIELDCAT_FOR_SEND.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_FIELDCAT_FOR_SEND
*&---------------------------------------------------------------------*
FORM SET_FIELDCAT_FOR_SEND .

  DATA : LT_FCAT_SLIS TYPE SLIS_T_FIELDCAT_ALV.
  DATA : LV_IDX           TYPE NUMC2,
         LV_CHATACTNUM(2),
         LV_COL_POS       TYPE NUMC2.
  DATA : LV_CHARACT(9),
         LV_STR(19).

  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      I_PROGRAM_NAME         = SY-REPID
      I_INCLNAME             = 'ZGTPPR3060TOP'
      I_INTERNAL_TABNAME     = 'GS_DISP'
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
      IT_DATA         = GT_DISP
    EXCEPTIONS
      OTHERS          = 1.

  LOOP AT GT_FIELDCAT_0100 ASSIGNING FIELD-SYMBOL(<LS_FCAT>).
    CASE <LS_FCAT>-FIELDNAME.
      WHEN 'ICON'.
        <LS_FCAT>-COLTEXT = TEXT-F01. "전송 상태
        <LS_FCAT>-COL_POS = '1'.
        <LS_FCAT>-NO_OUT = 'X'.
        <LS_FCAT>-JUST      = 'C'.
      WHEN 'MESSAGE'.
        <LS_FCAT>-COLTEXT = TEXT-F02.  "결과 메시지
        <LS_FCAT>-COL_POS = '2'.
        <LS_FCAT>-NO_OUT = 'X'.
        <LS_FCAT>-JUST      = 'L'.
      WHEN 'WERKS'.
        <LS_FCAT>-COLTEXT = TEXT-F03. "플랜트
        <LS_FCAT>-COL_POS = '3'.
        <LS_FCAT>-NO_OUT = ' '.
        <LS_FCAT>-JUST      = 'C'.
      WHEN 'NAME1'.
        <LS_FCAT>-COLTEXT = TEXT-F04. "플랜트 내역
        <LS_FCAT>-COL_POS = '4'.
        <LS_FCAT>-NO_OUT = 'X'.
        <LS_FCAT>-JUST      = 'L'.
      WHEN 'MATNR'.
        <LS_FCAT>-COLTEXT = TEXT-F05. "자재코드
        <LS_FCAT>-COL_POS = '5'.
        <LS_FCAT>-NO_OUT = ' '.
        <LS_FCAT>-JUST      = 'C'.
      WHEN 'MAKTX'.
        <LS_FCAT>-COLTEXT = TEXT-F06. "자재내역
        <LS_FCAT>-COL_POS = '6'.
        <LS_FCAT>-NO_OUT = ' '.
        <LS_FCAT>-JUST      = 'L'.
      WHEN 'MTART'.
        <LS_FCAT>-COLTEXT = TEXT-F07. "자재유형
        <LS_FCAT>-COL_POS = '7'.
        <LS_FCAT>-NO_OUT = 'X'.
*        <ls_fcat>-hotspot = 'X'.
        <LS_FCAT>-JUST      = 'C'.
      WHEN 'MTBEZ'.
        <LS_FCAT>-COLTEXT = TEXT-F08.  "자재유형 내역
        <LS_FCAT>-COL_POS = '8'.
        <LS_FCAT>-NO_OUT = ' '.
        <LS_FCAT>-JUST      = 'L'.
      WHEN 'MATKL'.
        <LS_FCAT>-COLTEXT = TEXT-F09.  "자재그룹
        <LS_FCAT>-COL_POS = '9'.
        <LS_FCAT>-NO_OUT = 'X'.
        <LS_FCAT>-JUST      = 'C'.
      WHEN 'WGBEZ'.
        <LS_FCAT>-COLTEXT = TEXT-F10.  "자재그룹 내역
        <LS_FCAT>-COL_POS = '10'.
        <LS_FCAT>-NO_OUT = ' '.
        <LS_FCAT>-JUST      = 'L'.
      WHEN 'LGORT'.
        <LS_FCAT>-COLTEXT = TEXT-F11. "저장위치
        <LS_FCAT>-COL_POS = '11'.
        <LS_FCAT>-NO_OUT = ' '.
        <LS_FCAT>-JUST      = 'C'.
      WHEN 'LGOBE'.
        <LS_FCAT>-COLTEXT = TEXT-F12.  "저장위치 내역
        <LS_FCAT>-COL_POS = '12'.
        <LS_FCAT>-NO_OUT = ' '.
        <LS_FCAT>-JUST      = 'L'.

      WHEN 'ZPJNO'.
        <LS_FCAT>-COLTEXT = TEXT-F19.  "프로젝트번호
        <LS_FCAT>-COL_POS = '13'.
        <LS_FCAT>-NO_OUT = ' '.
        <LS_FCAT>-JUST      = 'C'.


      WHEN 'BSTNK'.
        <LS_FCAT>-COLTEXT = TEXT-F21.  "제조지시번호
        <LS_FCAT>-COL_POS = '14'.
        <LS_FCAT>-NO_OUT = ' '.
        <LS_FCAT>-JUST      = 'C'.



      WHEN 'ZZLINE_NO'.
        <LS_FCAT>-COLTEXT = TEXT-F28. "라인번호
        <LS_FCAT>-COL_POS = '15'.
        IF P_R1 = 'X'.
          <LS_FCAT>-NO_OUT = ' '.
        ELSEIF P_R2 = 'X'.
          <LS_FCAT>-NO_OUT = 'X'.
        ELSEIF P_R3 = 'X'.
          <LS_FCAT>-NO_OUT = 'X'.
        ENDIF.
        <LS_FCAT>-JUST      = 'C'.
      WHEN 'ZZSERIAL_INFO'.
        <LS_FCAT>-COLTEXT = TEXT-F29. "시리얼정보
        <LS_FCAT>-COL_POS = '16'.
        IF P_R1 = 'X'.
          <LS_FCAT>-NO_OUT = ' '.
        ELSEIF P_R2 = 'X'.
          <LS_FCAT>-NO_OUT = 'X'.
        ELSEIF P_R3 = 'X'.
          <LS_FCAT>-NO_OUT = 'X'.
        ENDIF.
        <LS_FCAT>-JUST      = 'C'.

      WHEN 'CHARG'.
        <LS_FCAT>-COLTEXT = TEXT-F13. "배치번호
        <LS_FCAT>-COL_POS = '17'.
        IF P_R1 = 'X'.
          <LS_FCAT>-NO_OUT = ' '.
        ELSEIF P_R2 = 'X'.
          <LS_FCAT>-NO_OUT = 'X'.
        ELSEIF P_R3 = 'X'.
          <LS_FCAT>-NO_OUT = 'X'.
        ENDIF.
        <LS_FCAT>-JUST      = 'C'.


      WHEN 'SOBKZ'.
        <LS_FCAT>-COLTEXT = TEXT-F14. "특별재고지시자
        <LS_FCAT>-COL_POS = '18'.
        IF P_R1 = 'X'.  "시리얼별
          <LS_FCAT>-NO_OUT = ' '.
        ELSEIF P_R2 = 'X'.
          <LS_FCAT>-NO_OUT = ' '.
        ELSEIF P_R3 = 'X'.
          <LS_FCAT>-NO_OUT = 'X'.
        ENDIF.
        <LS_FCAT>-JUST      = 'C'.

      WHEN 'VBELN'.
        <LS_FCAT>-COLTEXT = TEXT-F17.  "판매오더
        <LS_FCAT>-COL_POS = '19'.
        IF P_R1 = 'X'.
          <LS_FCAT>-NO_OUT = ' '.
        ELSEIF P_R2 = 'X'.
          <LS_FCAT>-NO_OUT = ' '.
        ELSEIF P_R3 = 'X'.
          <LS_FCAT>-NO_OUT = 'X'.
        ENDIF.
        <LS_FCAT>-JUST      = 'C'.

      WHEN 'POSNR'.
        <LS_FCAT>-COLTEXT = TEXT-F18.   "판매오더 품목
        <LS_FCAT>-COL_POS = '20'.
        IF P_R1 = 'X'.
          <LS_FCAT>-NO_OUT = ' '.
        ELSEIF P_R2 = 'X'.
          <LS_FCAT>-NO_OUT = ' '.
        ELSEIF P_R3 = 'X'.
          <LS_FCAT>-NO_OUT = 'X'.
        ENDIF.
        <LS_FCAT>-JUST      = 'R'.

      WHEN 'KALAB'.
        <LS_FCAT>-COLTEXT = TEXT-F23.  "재고수량(가용)
        <LS_FCAT>-COL_POS = '21'.
        <LS_FCAT>-NO_OUT = ' '.
        <LS_FCAT>-JUST      = 'R'.
***        IF p_r1 = 'X'.
***          <ls_fcat>-do_sum    = ' '.
***        ELSEIF p_r2 = 'X'.
***          <ls_fcat>-do_sum    = 'X'.
***        ELSEIF p_r3 = 'X'.
***          <ls_fcat>-do_sum    = 'X'.
***        ENDIF.

      WHEN 'MEINS'.
        <LS_FCAT>-COLTEXT = TEXT-F26.  "재고단위
        <LS_FCAT>-COL_POS = '22'.
        <LS_FCAT>-NO_OUT = ' '.
        <LS_FCAT>-JUST      = 'C'.


      WHEN 'PRJNM'.
        <LS_FCAT>-COLTEXT = TEXT-F20.  "프로젝트 내역
        IF P_R1 = 'X'.
          <LS_FCAT>-COL_POS = '23'.
        ELSEIF P_R2 = 'X'.
          <LS_FCAT>-COL_POS = '23'.
        ELSEIF P_R3 = 'X'.
          <LS_FCAT>-COL_POS = '27'.
        ENDIF.
        <LS_FCAT>-NO_OUT = ' '.
        <LS_FCAT>-JUST      = 'L'.

      WHEN 'PRDNM'.
        <LS_FCAT>-COLTEXT = TEXT-F22.  "제조지시 내역
        IF P_R1 = 'X'.
          <LS_FCAT>-COL_POS = '23'.
        ELSEIF P_R2 = 'X'.
          <LS_FCAT>-COL_POS = '23'.
        ELSEIF P_R3 = 'X'.
          <LS_FCAT>-COL_POS = '28'.
        ENDIF.
        <LS_FCAT>-NO_OUT = ' '.
        <LS_FCAT>-JUST      = 'L'.


      WHEN 'KAINS'.
        <LS_FCAT>-COLTEXT = TEXT-F24.  "재고수량(품질)
        <LS_FCAT>-COL_POS = '25'.
        <LS_FCAT>-NO_OUT = ' '.
        <LS_FCAT>-JUST      = 'R'.

      WHEN 'KASPE'.
        <LS_FCAT>-COLTEXT = TEXT-F25.  "재고수량(보류)
        <LS_FCAT>-COL_POS = '26'.
        <LS_FCAT>-NO_OUT = ' '.
        <LS_FCAT>-JUST      = 'R'.




      WHEN 'LIFNR'.
        <LS_FCAT>-COLTEXT = TEXT-F15.  "공급업체번호
        <LS_FCAT>-COL_POS = '27'.
        IF P_R1 = 'X'.
          <LS_FCAT>-NO_OUT = 'X'.
        ELSEIF P_R2 = 'X'.
          <LS_FCAT>-NO_OUT = 'X'.
        ELSEIF P_R3 = 'X'.
          <LS_FCAT>-NO_OUT = 'X'.
        ENDIF.
        <LS_FCAT>-JUST      = 'R'.
      WHEN 'NAME2'.
        <LS_FCAT>-COLTEXT = TEXT-F16.  "업체명
        <LS_FCAT>-COL_POS = '28'.
        IF P_R1 = 'X'.
          <LS_FCAT>-NO_OUT = 'X'.
        ELSEIF P_R2 = 'X'.
          <LS_FCAT>-NO_OUT = 'X'.
        ELSEIF P_R3 = 'X'.
          <LS_FCAT>-NO_OUT = 'X'.
        ENDIF.
        <LS_FCAT>-JUST      = 'L'.




      WHEN 'CHARACT01'
        OR 'CHARACT02'
        OR 'CHARACT03'
        OR 'CHARACT04'
        OR 'CHARACT05'
        OR 'CHARACT06'
        OR 'CHARACT07'
        OR 'CHARACT08'
        OR 'CHARACT09'
        OR 'CHARACT10'
        OR 'CHARACT11'
        OR 'CHARACT12'
        OR 'CHARACT13'
        OR 'CHARACT14'
        OR 'CHARACT15'
        OR 'CHARACT16'
        OR 'CHARACT17'
        OR 'CHARACT18'
        OR 'CHARACT19'
        OR 'CHARACT20'
        OR 'CHARACT21'
        OR 'CHARACT22'
        OR 'CHARACT23'
        OR 'CHARACT24'
        OR 'CHARACT25'
        OR 'CHARACT26'
        OR 'CHARACT27'
        OR 'CHARACT28'
        OR 'CHARACT29'
        OR 'CHARACT30'
          .



        LV_CHATACTNUM =  <LS_FCAT>-FIELDNAME+7(2).
        LV_IDX = <LS_FCAT>-FIELDNAME+7(2).
        LV_COL_POS = LV_IDX + 40.

        CLEAR : LV_CHARACT.
        CONCATENATE 'CHARACT' LV_CHATACTNUM INTO LV_CHARACT.
        READ TABLE GT_T1010 INTO GS_T1010 WITH KEY FLD_01 = LV_CHARACT.
        IF SY-SUBRC = 0.
          IF GS_T1010-FLD_02 IS NOT INITIAL.
            <LS_FCAT>-COLTEXT = GS_T1010-FLD_03.  "CHARACT01
            <LS_FCAT>-COL_POS = LV_COL_POS.
            IF P_R1 = 'X'.
              <LS_FCAT>-NO_OUT = ' '.
            ELSEIF P_R2 = 'X'.
              <LS_FCAT>-NO_OUT = ' '.
            ELSEIF P_R3 = 'X'.
              <LS_FCAT>-NO_OUT = 'X'.
            ENDIF.
            <LS_FCAT>-JUST      = 'C'.
            <LS_FCAT>-NO_ZERO   = 'X'.
          ELSE.
            <LS_FCAT>-COLTEXT = GS_T1010-FLD_03.  "CHARACT01
            <LS_FCAT>-COL_POS = LV_COL_POS.
            <LS_FCAT>-NO_OUT = 'X'.
            IF P_R1 = 'X'.
              <LS_FCAT>-NO_OUT = 'X'.
            ELSEIF P_R2 = 'X'.
              <LS_FCAT>-NO_OUT = 'X'.
            ELSEIF P_R3 = 'X'.
              <LS_FCAT>-NO_OUT = 'X'.
            ENDIF.
            <LS_FCAT>-JUST      = 'C'.
            <LS_FCAT>-NO_ZERO   = 'X'.
          ENDIF.
        ENDIF.


      WHEN 'LIFNR_PROJ'.
        <LS_FCAT>-COLTEXT = TEXT-F30.  "완제품외주업체코드
        <LS_FCAT>-COL_POS = 201.
        <LS_FCAT>-JUST      = 'C'.
      WHEN 'NAME1_PROJ'.
        <LS_FCAT>-COLTEXT = TEXT-F31.  "업체명
        <LS_FCAT>-COL_POS = 202.
        <LS_FCAT>-JUST      = 'L'.

      WHEN OTHERS .
        <LS_FCAT>-NO_OUT = 'X'.


    ENDCASE.

  ENDLOOP.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form set_cell_attribute_grid_0100
*&---------------------------------------------------------------------*
FORM SET_CELL_ATTRIBUTE_GRID_0100 .

  DATA : LT_CELLCOL TYPE LVC_T_SCOL.
  DATA : LS_CELLCOL TYPE LVC_S_SCOL.
  DATA : LS_COL  TYPE LVC_S_COLO. "색상이 임시 저장될 구조체

  LOOP AT GT_DISP INTO GS_DISP.
    REFRESH LT_CELLCOL.

    LS_CELLCOL-FNAME = 'BSTNK'.
    LS_CELLCOL-COLOR-COL = '1'.
    LS_CELLCOL-COLOR-INT = '0'.
    LS_CELLCOL-COLOR-INV = '4'.
    LS_CELLCOL-NOKEYCOL  = ' '.
    INSERT LS_CELLCOL INTO TABLE LT_CELLCOL.

    LS_CELLCOL-FNAME = 'CHARACT01'.
    LS_CELLCOL-COLOR-COL = '6'.
    LS_CELLCOL-COLOR-INT = '0'.
    LS_CELLCOL-COLOR-INV = '0'.
    LS_CELLCOL-NOKEYCOL  = ' '.
    INSERT LS_CELLCOL INTO TABLE LT_CELLCOL.

    LS_CELLCOL-FNAME = 'CHARACT02'.
    LS_CELLCOL-COLOR-COL = '6'.
    LS_CELLCOL-COLOR-INT = '0'.
    LS_CELLCOL-COLOR-INV = '0'.
    LS_CELLCOL-NOKEYCOL  = ' '.
    INSERT LS_CELLCOL INTO TABLE LT_CELLCOL.

    LS_CELLCOL-FNAME = 'CHARACT03'.
    LS_CELLCOL-COLOR-COL = '6'.
    LS_CELLCOL-COLOR-INT = '0'.
    LS_CELLCOL-COLOR-INV = '0'.
    LS_CELLCOL-NOKEYCOL  = ' '.
    INSERT LS_CELLCOL INTO TABLE LT_CELLCOL.

    LS_CELLCOL-FNAME = 'CHARACT04'.
    LS_CELLCOL-COLOR-COL = '6'.
    LS_CELLCOL-COLOR-INT = '0'.
    LS_CELLCOL-COLOR-INV = '0'.
    LS_CELLCOL-NOKEYCOL  = ' '.
    INSERT LS_CELLCOL INTO TABLE LT_CELLCOL.

    LS_CELLCOL-FNAME = 'CHARACT05'.
    LS_CELLCOL-COLOR-COL = '6'.
    LS_CELLCOL-COLOR-INT = '0'.
    LS_CELLCOL-COLOR-INV = '0'.
    LS_CELLCOL-NOKEYCOL  = ' '.
    INSERT LS_CELLCOL INTO TABLE LT_CELLCOL.

    LS_CELLCOL-FNAME = 'CHARACT06'.
    LS_CELLCOL-COLOR-COL = '6'.
    LS_CELLCOL-COLOR-INT = '0'.
    LS_CELLCOL-COLOR-INV = '0'.
    LS_CELLCOL-NOKEYCOL  = ' '.
    INSERT LS_CELLCOL INTO TABLE LT_CELLCOL.

    LS_CELLCOL-FNAME = 'CHARACT07'.
    LS_CELLCOL-COLOR-COL = '6'.
    LS_CELLCOL-COLOR-INT = '0'.
    LS_CELLCOL-COLOR-INV = '0'.
    LS_CELLCOL-NOKEYCOL  = ' '.
    INSERT LS_CELLCOL INTO TABLE LT_CELLCOL.

    LS_CELLCOL-FNAME = 'CHARACT08'.
    LS_CELLCOL-COLOR-COL = '6'.
    LS_CELLCOL-COLOR-INT = '0'.
    LS_CELLCOL-COLOR-INV = '0'.
    LS_CELLCOL-NOKEYCOL  = ' '.
    INSERT LS_CELLCOL INTO TABLE LT_CELLCOL.

    LS_CELLCOL-FNAME = 'CHARACT09'.
    LS_CELLCOL-COLOR-COL = '6'.
    LS_CELLCOL-COLOR-INT = '0'.
    LS_CELLCOL-COLOR-INV = '0'.
    LS_CELLCOL-NOKEYCOL  = ' '.
    INSERT LS_CELLCOL INTO TABLE LT_CELLCOL.

    LS_CELLCOL-FNAME = 'CHARACT10'.
    LS_CELLCOL-COLOR-COL = '6'.
    LS_CELLCOL-COLOR-INT = '0'.
    LS_CELLCOL-COLOR-INV = '0'.
    LS_CELLCOL-NOKEYCOL  = ' '.
    INSERT LS_CELLCOL INTO TABLE LT_CELLCOL.

    LS_CELLCOL-FNAME = 'CHARACT11'.
    LS_CELLCOL-COLOR-COL = '6'.
    LS_CELLCOL-COLOR-INT = '0'.
    LS_CELLCOL-COLOR-INV = '0'.
    LS_CELLCOL-NOKEYCOL  = ' '.
    INSERT LS_CELLCOL INTO TABLE LT_CELLCOL.

    LS_CELLCOL-FNAME = 'CHARACT12'.
    LS_CELLCOL-COLOR-COL = '6'.
    LS_CELLCOL-COLOR-INT = '0'.
    LS_CELLCOL-COLOR-INV = '0'.
    LS_CELLCOL-NOKEYCOL  = ' '.
    INSERT LS_CELLCOL INTO TABLE LT_CELLCOL.

    LS_CELLCOL-FNAME = 'CHARACT13'.
    LS_CELLCOL-COLOR-COL = '6'.
    LS_CELLCOL-COLOR-INT = '0'.
    LS_CELLCOL-COLOR-INV = '0'.
    LS_CELLCOL-NOKEYCOL  = ' '.
    INSERT LS_CELLCOL INTO TABLE LT_CELLCOL.

    LS_CELLCOL-FNAME = 'CHARACT14'.
    LS_CELLCOL-COLOR-COL = '6'.
    LS_CELLCOL-COLOR-INT = '0'.
    LS_CELLCOL-COLOR-INV = '0'.
    LS_CELLCOL-NOKEYCOL  = ' '.
    INSERT LS_CELLCOL INTO TABLE LT_CELLCOL.

    LS_CELLCOL-FNAME = 'CHARACT15'.
    LS_CELLCOL-COLOR-COL = '6'.
    LS_CELLCOL-COLOR-INT = '0'.
    LS_CELLCOL-COLOR-INV = '0'.
    LS_CELLCOL-NOKEYCOL  = ' '.
    INSERT LS_CELLCOL INTO TABLE LT_CELLCOL.

    LS_CELLCOL-FNAME = 'CHARACT16'.
    LS_CELLCOL-COLOR-COL = '6'.
    LS_CELLCOL-COLOR-INT = '0'.
    LS_CELLCOL-COLOR-INV = '0'.
    LS_CELLCOL-NOKEYCOL  = ' '.
    INSERT LS_CELLCOL INTO TABLE LT_CELLCOL.

    LS_CELLCOL-FNAME = 'CHARACT17'.
    LS_CELLCOL-COLOR-COL = '6'.
    LS_CELLCOL-COLOR-INT = '0'.
    LS_CELLCOL-COLOR-INV = '0'.
    LS_CELLCOL-NOKEYCOL  = ' '.
    INSERT LS_CELLCOL INTO TABLE LT_CELLCOL.

    LS_CELLCOL-FNAME = 'CHARACT18'.
    LS_CELLCOL-COLOR-COL = '6'.
    LS_CELLCOL-COLOR-INT = '0'.
    LS_CELLCOL-COLOR-INV = '0'.
    LS_CELLCOL-NOKEYCOL  = ' '.
    INSERT LS_CELLCOL INTO TABLE LT_CELLCOL.

    LS_CELLCOL-FNAME = 'CHARACT19'.
    LS_CELLCOL-COLOR-COL = '6'.
    LS_CELLCOL-COLOR-INT = '0'.
    LS_CELLCOL-COLOR-INV = '0'.
    LS_CELLCOL-NOKEYCOL  = ' '.
    INSERT LS_CELLCOL INTO TABLE LT_CELLCOL.

    LS_CELLCOL-FNAME = 'CHARACT20'.
    LS_CELLCOL-COLOR-COL = '6'.
    LS_CELLCOL-COLOR-INT = '0'.
    LS_CELLCOL-COLOR-INV = '0'.
    LS_CELLCOL-NOKEYCOL  = ' '.
    INSERT LS_CELLCOL INTO TABLE LT_CELLCOL.

    LS_CELLCOL-FNAME = 'CHARACT21'.
    LS_CELLCOL-COLOR-COL = '6'.
    LS_CELLCOL-COLOR-INT = '0'.
    LS_CELLCOL-COLOR-INV = '0'.
    LS_CELLCOL-NOKEYCOL  = ' '.
    INSERT LS_CELLCOL INTO TABLE LT_CELLCOL.

    LS_CELLCOL-FNAME = 'CHARACT22'.
    LS_CELLCOL-COLOR-COL = '6'.
    LS_CELLCOL-COLOR-INT = '0'.
    LS_CELLCOL-COLOR-INV = '0'.
    LS_CELLCOL-NOKEYCOL  = ' '.
    INSERT LS_CELLCOL INTO TABLE LT_CELLCOL.

    LS_CELLCOL-FNAME = 'CHARACT23'.
    LS_CELLCOL-COLOR-COL = '6'.
    LS_CELLCOL-COLOR-INT = '0'.
    LS_CELLCOL-COLOR-INV = '0'.
    LS_CELLCOL-NOKEYCOL  = ' '.
    INSERT LS_CELLCOL INTO TABLE LT_CELLCOL.

    LS_CELLCOL-FNAME = 'CHARACT24'.
    LS_CELLCOL-COLOR-COL = '6'.
    LS_CELLCOL-COLOR-INT = '0'.
    LS_CELLCOL-COLOR-INV = '0'.
    LS_CELLCOL-NOKEYCOL  = ' '.
    INSERT LS_CELLCOL INTO TABLE LT_CELLCOL.

    LS_CELLCOL-FNAME = 'CHARACT25'.
    LS_CELLCOL-COLOR-COL = '6'.
    LS_CELLCOL-COLOR-INT = '0'.
    LS_CELLCOL-COLOR-INV = '0'.
    LS_CELLCOL-NOKEYCOL  = ' '.
    INSERT LS_CELLCOL INTO TABLE LT_CELLCOL.

    LS_CELLCOL-FNAME = 'CHARACT26'.
    LS_CELLCOL-COLOR-COL = '6'.
    LS_CELLCOL-COLOR-INT = '0'.
    LS_CELLCOL-COLOR-INV = '0'.
    LS_CELLCOL-NOKEYCOL  = ' '.
    INSERT LS_CELLCOL INTO TABLE LT_CELLCOL.

    LS_CELLCOL-FNAME = 'CHARACT27'.
    LS_CELLCOL-COLOR-COL = '6'.
    LS_CELLCOL-COLOR-INT = '0'.
    LS_CELLCOL-COLOR-INV = '0'.
    LS_CELLCOL-NOKEYCOL  = ' '.
    INSERT LS_CELLCOL INTO TABLE LT_CELLCOL.

    LS_CELLCOL-FNAME = 'CHARACT28'.
    LS_CELLCOL-COLOR-COL = '6'.
    LS_CELLCOL-COLOR-INT = '0'.
    LS_CELLCOL-COLOR-INV = '0'.
    LS_CELLCOL-NOKEYCOL  = ' '.
    INSERT LS_CELLCOL INTO TABLE LT_CELLCOL.

    LS_CELLCOL-FNAME = 'CHARACT29'.
    LS_CELLCOL-COLOR-COL = '6'.
    LS_CELLCOL-COLOR-INT = '0'.
    LS_CELLCOL-COLOR-INV = '0'.
    LS_CELLCOL-NOKEYCOL  = ' '.
    INSERT LS_CELLCOL INTO TABLE LT_CELLCOL.

    LS_CELLCOL-FNAME = 'CHARACT30'.
    LS_CELLCOL-COLOR-COL = '6'.
    LS_CELLCOL-COLOR-INT = '0'.
    LS_CELLCOL-COLOR-INV = '0'.
    LS_CELLCOL-NOKEYCOL  = ' '.
    INSERT LS_CELLCOL INTO TABLE LT_CELLCOL.



    INSERT LINES OF LT_CELLCOL INTO TABLE GS_DISP-CELLSCOL.

    MODIFY GT_DISP FROM GS_DISP.


  ENDLOOP.


*  DATA : LT_CELLTAB TYPE LVC_T_STYL.
*  DATA : LS_CELLTAB TYPE LVC_S_STYL.
*  LOOP AT GT_HEADER ASSIGNING FIELD-SYMBOL(<LS_HEADER>).
*    REFRESH LT_CELLTAB.
*    IF GV_DIS_MODE = 'D'.
*    ELSE.
*      LOOP AT GT_FIELDCAT_0100 INTO DATA(LS_FCAT).
*        IF <LS_HEADER>-CHK_CHG = 'N'. " 라인추가시 변경불가필드 세팅
*          CASE LS_FCAT-FIELDNAME.
*            WHEN 'STATUS'.
*              CONTINUE.
*          ENDCASE.
*        ELSE. " 변경불가필드 세팅
*          CASE <LS_HEADER>-STATUS.
*            WHEN ICON_LED_YELLOW.
*              CASE LS_FCAT-FIELDNAME.
*                WHEN 'STATUS'.
*                  CONTINUE.
*              ENDCASE.
*            WHEN ICON_LED_GREEN.
*              CASE LS_FCAT-FIELDNAME.
*                WHEN 'STATUS' OR 'MODULE_KIND' OR 'CODEGRP' OR 'FLDNR'.
*                  CONTINUE.
*              ENDCASE.
*          ENDCASE.
*
*        ENDIF.
*        CLEAR LS_CELLTAB.
*        __SET_CELL_ATTRIBUTE LS_FCAT-FIELDNAME CL_GUI_ALV_GRID=>MC_STYLE_ENABLED.
*        INSERT LS_CELLTAB INTO TABLE LT_CELLTAB.
*      ENDLOOP.
*    ENDIF.
*    <LS_HEADER>-CELLTAB = LT_CELLTAB.
*  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form exclude_of_toolbar_grid_0100
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
*& Form call_grid_0100_display
*&---------------------------------------------------------------------*
FORM CALL_GRID_0100_DISPLAY .

  ALV_VARIANT-REPORT = SY-REPID.


  CALL METHOD GO_GRID_0100->SET_TABLE_FOR_FIRST_DISPLAY
    EXPORTING
      IS_LAYOUT            = GS_LAYOUT_0100
      IT_TOOLBAR_EXCLUDING = GT_EXCLUDE_0100
      IS_VARIANT           = ALV_VARIANT  " 선택 메뉴 display
      I_SAVE               = 'X'
    CHANGING
      IT_OUTTAB            = GT_DISP
      IT_FIELDCATALOG      = GT_FIELDCAT_0100
      IT_SORT              = GT_SORT_0100.


* 인풋이벤트 추가
  CALL METHOD GO_GRID_0100->REGISTER_EDIT_EVENT
    EXPORTING
      I_EVENT_ID = CL_GUI_ALV_GRID=>MC_EVT_ENTER.

  CALL METHOD GO_GRID_0100->REGISTER_EDIT_EVENT
    EXPORTING
      I_EVENT_ID = CL_GUI_ALV_GRID=>MC_EVT_MODIFIED.

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

  DATA : LS_SORT TYPE LVC_S_SORT.

  REFRESH GT_SORT_0100.


  IF  P_R1 = 'X'.

  ELSEIF P_R2 = 'X'.

    LS_SORT-SPOS = 1.
    LS_SORT-FIELDNAME = 'WERKS'.
    LS_SORT-UP = 'X'.
    LS_SORT-DOWN = ''.
*    LS_SORT-SUBTOT =  'X'.
    APPEND LS_SORT TO GT_SORT_0100.

    LS_SORT-SPOS = 2.
    LS_SORT-FIELDNAME = 'MATNR'.
    LS_SORT-UP = 'X'.
    LS_SORT-DOWN = ''.
*    LS_SORT-SUBTOT =  'X'.
    APPEND LS_SORT TO GT_SORT_0100.

    LS_SORT-SPOS = 3.
    LS_SORT-FIELDNAME = 'LGORT'.
    LS_SORT-UP = 'X'.
    LS_SORT-DOWN = ''.
*    LS_SORT-SUBTOT =  'X'.
    APPEND LS_SORT TO GT_SORT_0100.

    LS_SORT-SPOS = 4.
    LS_SORT-FIELDNAME = 'VBELN'.
    LS_SORT-UP = 'X'.
    LS_SORT-DOWN = ''.
*    LS_SORT-SUBTOT =  'X'.
    APPEND LS_SORT TO GT_SORT_0100.

    LS_SORT-SPOS = 5.
    LS_SORT-FIELDNAME = 'POSNR'.
    LS_SORT-UP = 'X'.
    LS_SORT-DOWN = ''.
    LS_SORT-SUBTOT =  'X'.
    APPEND LS_SORT TO GT_SORT_0100.

  ELSEIF P_R3 = 'X'.

    LS_SORT-SPOS = 1.
    LS_SORT-FIELDNAME = 'WERKS'.
    LS_SORT-UP = 'X'.
    LS_SORT-DOWN = ''.
*    LS_SORT-SUBTOT =  'X'.
    APPEND LS_SORT TO GT_SORT_0100.

    LS_SORT-SPOS = 2.
    LS_SORT-FIELDNAME = 'MATNR'.
    LS_SORT-UP = 'X'.
    LS_SORT-DOWN = ''.
*    LS_SORT-SUBTOT =  'X'.
    APPEND LS_SORT TO GT_SORT_0100.

    LS_SORT-SPOS = 3.
    LS_SORT-FIELDNAME = 'LGORT'.
    LS_SORT-UP = 'X'.
    LS_SORT-DOWN = ''.
*    LS_SORT-SUBTOT =  'X'.
    APPEND LS_SORT TO GT_SORT_0100.

    LS_SORT-SPOS = 4.
    LS_SORT-FIELDNAME = 'BSTNK'.
    LS_SORT-UP = 'X'.
    LS_SORT-DOWN = ''.
    LS_SORT-SUBTOT =  'X'.
    APPEND LS_SORT TO GT_SORT_0100.

  ENDIF.


ENDFORM.
