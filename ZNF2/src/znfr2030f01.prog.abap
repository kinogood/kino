*&---------------------------------------------------------------------*
*&  Include           ZNFR2000F01
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  MAKE_RANGES_CSTAT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM MAKE_RANGES_CSTAT .

  CLEAR R_CSTAT. REFRESH R_CSTAT.

  IF P_CHK01 EQ 'X'.
    R_CSTAT-LOW    = 'L'.
    R_CSTAT-HIGH   = ''.
    R_CSTAT-SIGN   = 'I'.
    R_CSTAT-OPTION = 'EQ'.
    APPEND R_CSTAT.
  ENDIF.

  IF P_CHK02 EQ 'X'.
    R_CSTAT-LOW    = 'C'.
    R_CSTAT-HIGH   = ''.
    R_CSTAT-SIGN   = 'I'.
    R_CSTAT-OPTION = 'EQ'.
    APPEND R_CSTAT.
  ENDIF.

  IF P_CHK03 EQ 'X'.
    R_CSTAT-LOW    = 'F'.
    R_CSTAT-HIGH   = ''.
    R_CSTAT-SIGN   = 'I'.
    R_CSTAT-OPTION = 'EQ'.
    APPEND R_CSTAT.
  ENDIF.

ENDFORM.                    " MAKE_RANGES_CSTAT

*&---------------------------------------------------------------------*
*&      Form  CREATE_OBJECT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CREATE_OBJECT .

* Create Object : GRF_CONTAINER
  CREATE OBJECT GRF_CONTAINER
    EXPORTING
      CONTAINER_NAME = GRF_CONTAINER_NAME.

* Create Object : GRF_GRID
  CREATE OBJECT GRF_GRID
    EXPORTING
      I_PARENT      = GRF_CONTAINER
      I_APPL_EVENTS = 'X'.

ENDFORM.                    " CREATE_OBJECT

*&---------------------------------------------------------------------*
*&      Form  EXCLUDE_TB_FUNCTIONS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_GT_EXCLUDE  text
*----------------------------------------------------------------------*
FORM EXCLUDE_TB_FUNCTIONS CHANGING PT_EXCLUDE TYPE UI_FUNCTIONS.
  DATA : LS_EXCLUDE TYPE UI_FUNC.

  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_INSERT_ROW.
  APPEND LS_EXCLUDE TO PT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_UNDO.
  APPEND LS_EXCLUDE TO PT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_DELETE_ROW.
  APPEND LS_EXCLUDE TO PT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_APPEND_ROW.
  APPEND LS_EXCLUDE TO PT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_COPY.
  APPEND LS_EXCLUDE TO PT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_COPY_ROW.
  APPEND LS_EXCLUDE TO PT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_CUT.
  APPEND LS_EXCLUDE TO PT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_MOVE_ROW.
  APPEND LS_EXCLUDE TO PT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_PASTE.
  APPEND LS_EXCLUDE TO PT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_PASTE_NEW_ROW.
  APPEND LS_EXCLUDE TO PT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_REFRESH.
  APPEND LS_EXCLUDE TO PT_EXCLUDE.

ENDFORM.                    " EXCLUDE_TB_FUNCTIONS

*&---------------------------------------------------------------------*
*&      Form  SET_GRID_LAYOUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SET_GRID_LAYOUT .

  GS_LAYOUT-SEL_MODE   = 'A'.
  GS_LAYOUT-ZEBRA      = 'X'.
  GS_LAYOUT-CWIDTH_OPT = 'X'.
  GS_LAYOUT-STYLEFNAME = 'CELLTAB'.
  GS_LAYOUT-NO_ROWINS  = 'X'.

ENDFORM.                    " SET_GRID_LAYOUT
*&---------------------------------------------------------------------*
*&      Form  SET_GRID_SORT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SET_GRID_SORT .

  CLEAR : GS_SORT, GT_SORT.
  REFRESH GT_SORT.

  GS_SORT-SPOS = 1.
  GS_SORT-FIELDNAME = 'CONNO'.
  GS_SORT-UP = 'X'.
  GS_SORT-COMP = 'X'.
  GS_SORT-SUBTOT = 'X'.
  APPEND GS_SORT TO GT_SORT.

ENDFORM.                    " SET_GRID_SORT
*&---------------------------------------------------------------------*
*&      Form  SET_GRID_FIELDCATALOG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SET_GRID_FIELDCATALOG .

  PERFORM SET_FIELDCAT USING:
    'CHECK'           '선택'            '4'      'C'    ' '     ,
    'CONNO'           '계약번호'        '10'     'C'    ' '     ,
    'CSTAT'           '계약상태'        '8'      'C'    ' '     ,
    'CSTAT_NM'        '계약상태'        '8'      'C'    ' '     ,
    'CDATE'           '계약취소일'      '10'     'C'    ' '     ,
    'COTYP'           '계약유형'        '10'     'C'    ' '     ,
    'COTYP_NM'        '계약유형'        '10'     'C'    ' '     ,
    'BUKRS'           '회사코드'        '10'     'C'    ' '     ,
    'BUKRS_NM'        '회사명'          '10'     'L'    ' '     ,
    'NFCTR'           '사업부'          '10'     'C'    ' '     ,
    'NFCTR_NM'        '사업부명'        '10'     'L'    ' '     ,
    'PRCTR'           '손익센터'        '10'     'C'    ' '     ,
    'PRCTR_NM'        '손익센터명'      '10'     'L'    ' '     ,
    'VKGRP'           '영업조직'        '10'     'C'    ' '     ,
    'VKGRP_NM'        '영업조직명'      '10'     'L'    ' '     ,
    'COTXT'           '계약명'          '20'     'L'    ' '     ,
    'KUNNR'           '고  객'          '10'     'C'    'ALPHA' ,
    'KUNNR_NM'        '고객명'          '20'     'L'    ' '     ,
    'SUJUD'           '수주일'          '10'     'C'    ' '     ,
    'PRICE'           '수주금액'        '15'     'R'    ' '     ,
    'WAERS'           '통화'            '5'      'C'    ' '     ,
    'PRATE'           '영업이익률(%)'   '12'     'R'    ' '     ,
    'ERATE'           '환율'            '10'     'R'    ' '     ,
    'SALER'           '영업담당자'      '10'     'C'    ' '     ,
*    계약서/발주서 필드추가
    'ERNAM'           '생성자'          '10'     'C'    ' '     ,
    'ERDAT'           '생성일'          '10'     'C'    ' '     .

ENDFORM.                    " SET_GRID_FIELDCATALOG
*&---------------------------------------------------------------------*
*&      Form  SET_FIELDCAT
*&---------------------------------------------------------------------*
FORM SET_FIELDCAT  USING  P_FIELDNAME
                          P_COLTEXT
                          P_OUTPUTLEN
                          P_JUST
                          P_CONVEXIT.

  CLEAR GS_FIELDCAT.

  GS_FIELDCAT-FIELDNAME  = P_FIELDNAME .
  GS_FIELDCAT-COLTEXT    = P_COLTEXT   .
  GS_FIELDCAT-OUTPUTLEN  = P_OUTPUTLEN .
  GS_FIELDCAT-JUST       = P_JUST      .
  GS_FIELDCAT-CONVEXIT   = P_CONVEXIT  .

  CASE P_FIELDNAME.
    WHEN 'CHECK'.
      GS_FIELDCAT-CHECKBOX   = 'X'.
      GS_FIELDCAT-EDIT       = 'X'.
    WHEN 'CSTAT'.
      GS_FIELDCAT-EDIT       = 'X'.
      GS_FIELDCAT-F4AVAILABL = 'X'.
*      GS_FIELDCAT-REF_TABLE  = 'ZNFT1000'.
*      GS_FIELDCAT-REF_FIELD  = 'CSTAT'.
    WHEN 'CDATE'.
      GS_FIELDCAT-EDIT       = 'X'.
      GS_FIELDCAT-REF_TABLE  = 'ZNFT1000'.
      GS_FIELDCAT-REF_FIELD  = 'CDATE'.
    WHEN 'BUKRS' OR 'NFCTR' OR 'PRCTR' OR 'VKGRP' OR 'COTYP' OR 'CSTAT'.
      GS_FIELDCAT-NO_OUT     = 'X'.
    WHEN 'PRICE'.
      GS_FIELDCAT-CFIELDNAME = 'WAERS'.
    WHEN 'ERDAT' OR 'ERNAM'.
      GS_FIELDCAT-EDIT       = ''.
  ENDCASE.

  APPEND GS_FIELDCAT TO GT_FIELDCAT.

ENDFORM.                    " SET_FIELDCAT
*&---------------------------------------------------------------------*
*&      Form  SET_CELL_ATTRIBUTE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SET_CELL_ATTRIBUTE .

* 각 셀의 특성 제어
  DATA : LT_CELLTAB TYPE LVC_T_STYL,
         LV_INDEX    TYPE I.

  LOOP AT GT_OUTTAB INTO GS_OUTTAB.
    LV_INDEX = SY-TABIX.
    REFRESH LT_CELLTAB.
    CLEAR GS_OUTTAB-CELLTAB.
    PERFORM FILL_CELLTAB_C CHANGING LT_CELLTAB.
    INSERT LINES OF LT_CELLTAB INTO TABLE GS_OUTTAB-CELLTAB.
    MODIFY GT_OUTTAB FROM GS_OUTTAB INDEX LV_INDEX.
  ENDLOOP.

ENDFORM.                    " SET_CELL_ATTRIBUTE
*&---------------------------------------------------------------------*
*&      Form  SET_EVENT_HANDLER
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SET_EVENT_HANDLER .

* DATA가 변경될 경우
  CALL METHOD GRF_GRID->REGISTER_EDIT_EVENT
    EXPORTING
      I_EVENT_ID = CL_GUI_ALV_GRID=>MC_EVT_ENTER.

  CREATE OBJECT GRF_EVENT_RECEIVER.
  SET HANDLER :
    GRF_EVENT_RECEIVER->HANDLE_DATA_CHANGED FOR GRF_GRID,
    GRF_EVENT_RECEIVER->HANDLE_DOUBLE_CLICK FOR GRF_GRID,
    GRF_EVENT_RECEIVER->HANDLE_ON_F4        FOR GRF_GRID.

*  EDITE 가능상태
*  CALL METHOD GRF_GRID->SET_READY_FOR_INPUT
*    EXPORTING
*      I_READY_FOR_INPUT = 1.

ENDFORM.                    " SET_EVENT_HANDLER
*&---------------------------------------------------------------------*
*&      Form  SET_F4_HELP_REGISTER
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SET_F4_HELP_REGISTER .

  CLEAR   : GS_F4.
  REFRESH : GT_F4.

* FieldName별 소트해서 APPEND
  GS_F4-FIELDNAME = 'CSTAT'.
  GS_F4-REGISTER  = 'X'.
  APPEND GS_F4 TO GT_F4.

  CALL METHOD GRF_GRID->REGISTER_F4_FOR_FIELDS
    EXPORTING
      IT_F4 = GT_F4.

ENDFORM.                    " SET_F4_HELP_REGISTER
*&---------------------------------------------------------------------*
*&      Form  SET_TABLE_FOR_FIRST_DISPLAY
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SET_TABLE_FOR_FIRST_DISPLAY .

  GS_VARIANT-HANDLE = '0001'.
  GS_VARIANT-REPORT = SY-REPID.

  CALL METHOD GRF_GRID->SET_TABLE_FOR_FIRST_DISPLAY
    EXPORTING
      I_BYPASSING_BUFFER            = 'X'
      I_DEFAULT                     = 'X'
      I_SAVE                        = 'A'
      IS_VARIANT                    = GS_VARIANT
      IS_LAYOUT                     = GS_LAYOUT
      IT_TOOLBAR_EXCLUDING          = GT_EXCLUDE
    CHANGING
      IT_FIELDCATALOG               = GT_FIELDCAT[]
      IT_FILTER                     = GT_FILTER
      IT_OUTTAB                     = GT_OUTTAB[]
      IT_SORT                       = GT_SORT[]
    EXCEPTIONS
      INVALID_PARAMETER_COMBINATION = 1
      PROGRAM_ERROR                 = 2
      TOO_MANY_LINES                = 3
      OTHERS                        = 4.

  CALL METHOD GRF_GRID->REGISTER_EDIT_EVENT
    EXPORTING
      I_EVENT_ID = CL_GUI_ALV_GRID=>MC_EVT_MODIFIED.

ENDFORM.                    " SET_TABLE_FOR_FIRST_DISPLAY

*&---------------------------------------------------------------------*
*&      Form  DATA_SELECT_ZNFT1000
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM DATA_SELECT_ZNFT1000 .

  DATA: LV_TABIX TYPE SY-TABIX.

  CLEAR : GS_OUTTAB, GT_OUTTAB.
  REFRESH GT_OUTTAB.

  SELECT * INTO CORRESPONDING FIELDS OF TABLE GT_OUTTAB
    FROM ZNFT1000 AS Z1
   WHERE Z1~BUKRS EQ P_BUKRS
     AND Z1~ERDAT IN S_ERDAT
     AND Z1~CONNO IN S_CONNO
     AND Z1~NFCTR IN S_NFCTR
     AND Z1~PRCTR IN S_PRCTR
     AND Z1~VKGRP IN S_VKGRP
     AND Z1~ERNAM IN S_ERNAM
     AND Z1~CSTAT IN R_CSTAT
     AND Z1~CSTAT NE 'D'.      " 삭제인건 제외

  IF GT_OUTTAB IS NOT INITIAL.
    LOOP AT GT_OUTTAB INTO GS_OUTTAB.

      LV_TABIX = SY-TABIX.

*   - 회사코드
      PERFORM GET_BUKRS_DESC USING GS_OUTTAB-BUKRS
                                   GS_OUTTAB-BUKRS_NM.

*   - 사업부
      PERFORM GET_NFCTR_DESC USING GS_OUTTAB-BUKRS
                                   GS_OUTTAB-NFCTR
                                   GS_OUTTAB-NFCTR_NM.

*   - 손익센터
      PERFORM GET_PRCTR_DESC USING GS_OUTTAB-BUKRS
                                   GS_OUTTAB-PRCTR
                                   GS_OUTTAB-PRCTR_NM.

*   - 영업그룹
      PERFORM GET_VKGRP_DESC USING GS_OUTTAB-BUKRS
                                   GS_OUTTAB-VKGRP
                                   GS_OUTTAB-VKGRP_NM.

*   - 고객
      IF GS_OUTTAB-NCUST IS NOT INITIAL.
        GS_OUTTAB-KUNNR_NM = GS_OUTTAB-NCUST.
      ELSE.
        PERFORM GET_KUNNR_DESC USING GS_OUTTAB-KUNNR
                                     GS_OUTTAB-KUNNR_NM.
        GS_OUTTAB-NCUST = GS_OUTTAB-KUNNR_NM.
      ENDIF.

*   - 계약유형
      PERFORM DOMAIN_VALUE_GET USING 'ZCOTYP'
                                     GS_OUTTAB-COTYP
                                     GS_OUTTAB-COTYP_NM.

*   - 상태
      PERFORM DOMAIN_VALUE_GET USING 'ZCSTAT'
                                     GS_OUTTAB-CSTAT
                                     GS_OUTTAB-CSTAT_NM.


*     변경불가능한 DB의 계약상태값 : CSTAT ( Field의 Edit 기준 )
      GS_OUTTAB-CSTAT_DM = GS_OUTTAB-CSTAT.

      MODIFY GT_OUTTAB FROM GS_OUTTAB INDEX LV_TABIX.

    ENDLOOP.
  ENDIF.

ENDFORM.                    " DATA_SELECT_ZNFT1000
*&---------------------------------------------------------------------*
*&      Form  ALV_EVENT_DATA_CHANGED
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_ER_DATA_CHANGED  text
*----------------------------------------------------------------------*
FORM ALV_EVENT_DATA_CHANGED USING
            P_DATA_CHANGED TYPE REF TO CL_ALV_CHANGED_DATA_PROTOCOL.

  DATA: LS_MOD_CELLS TYPE LVC_S_MODI,
        LV_INDEX TYPE I,
        LV_TABIX TYPE I.

  DATA: LT_LVC_STYL TYPE LVC_T_STYL,
        LS_LVC_STYL TYPE LVC_S_STYL.

  DATA: LV_CSTAT LIKE ZNFT1000-CSTAT,
        LV_CDATE LIKE ZNFT1000-CDATE.
  CLEAR:LV_CSTAT, LV_CDATE.

  CLEAR LT_LVC_STYL. REFRESH LT_LVC_STYL.
  CLEAR LV_INDEX.

  LOOP AT P_DATA_CHANGED->MT_MOD_CELLS INTO LS_MOD_CELLS.
    LV_INDEX = LS_MOD_CELLS-ROW_ID.

*   Data 가공용 Structure
    READ TABLE GT_OUTTAB INTO GS_OUTTAB INDEX LV_INDEX.

    IF SY-SUBRC EQ 0.
      CASE LS_MOD_CELLS-FIELDNAME.
        WHEN 'CHECK'.
          IF LS_MOD_CELLS-VALUE EQ 'X'.
            IF GS_OUTTAB-CSTAT_DM EQ 'C'.
              CALL METHOD P_DATA_CHANGED->MODIFY_CELL
                EXPORTING
                  I_ROW_ID    = LS_MOD_CELLS-ROW_ID
                  I_FIELDNAME = 'CHECK'
                  I_VALUE     = SPACE.

              MESSAGE '계약상태가 취소인 데이터는 수정하실 수 없습니다.'
                 TYPE 'S' DISPLAY LIKE 'E'.
              EXIT.
            ELSE.
              GS_OUTTAB-CHECK = 'X'.
              MODIFY GT_OUTTAB FROM GS_OUTTAB INDEX LV_INDEX
                               TRANSPORTING CHECK.

*             해당 계약번호 LOCK OBJECT 잠금
              GS_CONNO-CONNO = GS_OUTTAB-CONNO.
              APPEND GS_CONNO TO GT_CONNO.
              PERFORM ENQUEUE_ZNFT1000 USING GS_CONNO-CONNO
                                             GV_ERROR.
              IF GV_ERROR EQ 'X'.
                CALL METHOD P_DATA_CHANGED->MODIFY_CELL
                  EXPORTING
                    I_ROW_ID    = LS_MOD_CELLS-ROW_ID
                    I_FIELDNAME = 'CHECK'
                    I_VALUE     = SPACE.
                EXIT.
              ENDIF.
              DELETE ADJACENT DUPLICATES FROM GT_CONNO.

            ENDIF.
          ELSE.
            GS_OUTTAB-CHECK = SPACE.
            MODIFY GT_OUTTAB FROM GS_OUTTAB INDEX LV_INDEX
                             TRANSPORTING CHECK.

*           해당 계약번호 LOCK OBJECT 잠금해제
            GS_CONNO-CONNO = GS_OUTTAB-CONNO.
            DELETE GT_CONNO FROM GS_CONNO.
            PERFORM DEQUEUE_ZNFT1000_S USING GS_CONNO-CONNO.
            DELETE ADJACENT DUPLICATES FROM GT_CONNO.

          ENDIF.
        WHEN 'CSTAT'.
          GS_OUTTAB-CSTAT = LS_MOD_CELLS-VALUE.
          PERFORM DOMAIN_VALUE_GET USING 'ZCSTAT'
                                         GS_OUTTAB-CSTAT
                                         GS_OUTTAB-CSTAT_NM.

*         취소인 경우 계약취소일(Default:SY-DATUM)변경
          IF GS_OUTTAB-CSTAT EQ 'C'.
            GS_OUTTAB-CDATE = SY-DATUM.
          ELSE.
            GS_OUTTAB-CDATE = SPACE.
          ENDIF.

          MODIFY GT_OUTTAB FROM GS_OUTTAB INDEX LV_INDEX
                           TRANSPORTING CSTAT CSTAT_NM CDATE.

        WHEN 'CDATE'.
          GS_OUTTAB-CDATE = LS_MOD_CELLS-VALUE.
          MODIFY GT_OUTTAB FROM GS_OUTTAB INDEX LV_INDEX
                           TRANSPORTING CDATE.
      ENDCASE.
    ENDIF.
  ENDLOOP.

ENDFORM.                    " ALV_EVENT_DATA_CHANGED

*&---------------------------------------------------------------------*
*&      Form  ALV_EVENT_DOUBLE_CLICK
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_E_ROW  text
*      -->P_E_COLUMN  text
*      -->P_ES_ROW_NO  text
*----------------------------------------------------------------------*
FORM ALV_EVENT_DOUBLE_CLICK USING P_E_ROW     TYPE LVC_S_ROW
                                  P_E_COLUMN  TYPE LVC_S_COL
                                  P_ES_ROW_NO TYPE LVC_S_ROID.

  READ TABLE GT_OUTTAB INTO GS_OUTTAB INDEX P_ES_ROW_NO-ROW_ID.

  IF SY-SUBRC EQ 0.

    CASE P_E_COLUMN.
      WHEN 'CONNO'.
        IF NOT GS_OUTTAB-CONNO IS INITIAL.
          SET PARAMETER ID 'ZNFCON' FIELD GS_OUTTAB-CONNO.
          CALL TRANSACTION 'ZNF2M2003' AND SKIP FIRST SCREEN.
        ELSE.
          MESSAGE '계약번호가 존재하지 않습니다.'
             TYPE 'S' DISPLAY LIKE 'E'.
        ENDIF.
    ENDCASE.

  ENDIF.

ENDFORM.                    " ALV_EVENT_DOUBLE_CLICK

*&---------------------------------------------------------------------*
*&      Form  ALV_EVENT_ON_F4
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_SENDER  text
*      -->P_E_FIELDNAME  text
*      -->P_E_FIELDVALUE  text
*      -->P_ES_ROW_NO  text
*      -->P_ER_EVENT_DATA  text
*      -->P_ET_BAD_CELLS  text
*      -->P_E_DISPLAY  text
*----------------------------------------------------------------------*
FORM ALV_EVENT_ON_F4 USING  SENDER         TYPE REF TO CL_GUI_ALV_GRID
                            E_FIELDNAME    TYPE LVC_FNAME
                            E_FIELDVALUE   TYPE LVC_VALUE
                            ES_ROW_NO      TYPE LVC_S_ROID
                            ER_EVENT_DATA  TYPE REF TO CL_ALV_EVENT_DATA
                            ET_BAD_CELLS   TYPE LVC_T_MODI
                            E_DISPLAY      TYPE CHAR01.

  DATA: LV_INDEX TYPE SY-INDEX.

  CASE E_FIELDNAME.
    WHEN 'CSTAT'.
      LV_INDEX = ES_ROW_NO-ROW_ID.
      READ TABLE GT_OUTTAB INTO GS_OUTTAB INDEX LV_INDEX.
      IF SY-SUBRC EQ 0.
        PERFORM F4HELP_CSTAT USING GS_OUTTAB-CSTAT
                                   GS_OUTTAB-CSTAT_NM.
        MODIFY GT_OUTTAB FROM GS_OUTTAB INDEX LV_INDEX.
      ENDIF.
  ENDCASE.

  ER_EVENT_DATA->M_EVENT_HANDLED = 'X'.

ENDFORM.                    " ALV_EVENT_ON_F4

*&---------------------------------------------------------------------*
*&      Form  DATA_SAVE_ZNFT1000
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM DATA_SAVE_ZNFT1000 .

  DATA: LV_REQNO TYPE ZREQNO_1,
        LV_VBELN TYPE VBELN_VA,
        LV_CONNO TYPE ZCONNO,
        LV_R_MSG TYPE CHAR100.

  DATA: LV_ERROR TYPE CHAR01.
  DATA: LS_ZNFT1000  TYPE ZNFT1000,
        LT_ZNFT1000  LIKE TABLE OF ZNFT1000,
        LS_ZNFT1000Y TYPE ZNFT1000,
        LT_ZNFT1000Y LIKE TABLE OF ZNFT1000.

  CALL METHOD GRF_GRID->CHECK_CHANGED_DATA.

  CLEAR LV_ERROR.
  LOOP AT GT_OUTTAB INTO GS_OUTTAB WHERE CHECK EQ 'X'.
    LV_CONNO = GS_OUTTAB-CONNO.

*   계약상태 코드값 체크
    PERFORM DOMAIN_VALUE_GET USING 'ZCSTAT'
                                   GS_OUTTAB-CSTAT
                                   GS_OUTTAB-CSTAT_NM.

*...계약상태값 변경시 오류 현상 개선
*   (C20120821_68213 Req. by 구영헌 2012/08/23)
    IF GS_OUTTAB-CSTAT_NM IS INITIAL.
      MESSAGE '계약상태 코드값이 잘못되었습니다.'
         TYPE 'I' DISPLAY LIKE 'E'.
      LV_ERROR = 'X'.
      EXIT.
    ENDIF.

*   삭제인경우 이후 문서 점검
    IF GS_OUTTAB-CSTAT EQ 'D'.
      PERFORM DELETE_CHECK_ZNFT1011 USING LV_CONNO LV_REQNO.
      IF LV_REQNO IS NOT INITIAL.
        CLEAR LV_R_MSG.
        CONCATENATE '계약번호' LV_CONNO '는 선물요청 ' LV_REQNO
                    '와 연결되어 있어 삭제가 불가능합니다.'
                    INTO LV_R_MSG.
        MESSAGE LV_R_MSG TYPE 'S' DISPLAY LIKE 'E'.
        LV_ERROR = 'X'.
        EXIT.
      ENDIF.
      PERFORM DELETE_CHECK_VBAP     USING LV_CONNO LV_VBELN.
      IF LV_VBELN IS NOT INITIAL.
        CLEAR LV_R_MSG.
        CONCATENATE '계약번호' LV_CONNO '는 S/O ' LV_VBELN
                    '와 연결되어 있어 삭제가 불가능합니다.'
                    INTO LV_R_MSG.
        MESSAGE LV_R_MSG TYPE 'S' DISPLAY LIKE 'E'.
        LV_ERROR = 'X'.
        EXIT.
      ENDIF.
    ENDIF.

*   계약상태 Flag Check ( CSTAT = 'C'인경우 계약취소일 입력 )
    IF GS_OUTTAB-CSTAT EQ 'C' AND
        ( GS_OUTTAB-CDATE IS INITIAL OR GS_OUTTAB-CDATE EQ SPACE ).
      MESSAGE S003 DISPLAY LIKE 'E'
         WITH '계약상태가 취소인 경우 계약취소일은 필수입니다.'.
      LV_ERROR = 'X'.
      EXIT.
    ENDIF.
    MOVE-CORRESPONDING GS_OUTTAB TO LS_ZNFT1000.
    LS_ZNFT1000-AENAM = SY-UNAME.
    LS_ZNFT1000-AEDAT = SY-DATLO.
    LS_ZNFT1000-AEZET = SY-TIMLO.
    APPEND LS_ZNFT1000 TO LT_ZNFT1000.

*   변경문서 이력관리용 : 수정전 데이터 취합
    SELECT SINGLE *
           INTO CORRESPONDING FIELDS OF LS_ZNFT1000Y
      FROM ZNFT1000
     WHERE CONNO EQ GS_OUTTAB-CONNO.
    IF SY-SUBRC EQ 0.
      APPEND LS_ZNFT1000Y TO LT_ZNFT1000Y.
    ENDIF.

  ENDLOOP.

  CHECK LV_ERROR NE 'X'.

  READ TABLE GT_OUTTAB INTO GS_OUTTAB WITH KEY CHECK = 'X'
                                               CSTAT = 'D'.

  IF SY-SUBRC EQ 0.

*   진행상황 체크
    CLEAR GV_ANSWER.
    PERFORM POPUP_TO_CONFIRM
      USING '삭제상태변경건 존재'
            '계약이 완전히 삭제되는건이 있습니다. 삭제 상태로 변경하시겠습니까?'
            '1'
            GV_ANSWER.
    CHECK GV_ANSWER EQ '1'.

  ENDIF.

  CHECK NOT LV_ERROR = 'X'.

  IF LT_ZNFT1000 IS INITIAL.
    MESSAGE S003 DISPLAY LIKE 'E'
       WITH '수정하실 데이터를 선택하십시오.'.
    EXIT.
  ENDIF.

  MODIFY ZNFT1000 FROM TABLE LT_ZNFT1000.

  IF SY-SUBRC EQ 0.
    PERFORM SAVE_CHANGE_DOC TABLES LT_ZNFT1000Y.
    COMMIT WORK.
    PERFORM DATA_RELOAD.
    PERFORM DEQUEUE_ZNFT1000_T.
    MESSAGE S003 DISPLAY LIKE 'S'
       WITH '데이터를 변경에 성공하였습니다.'.
  ELSE.
    ROLLBACK WORK.
    MESSAGE S003 DISPLAY LIKE 'S'
       WITH '데이터를 변경에 실패하였습니다.'.
    EXIT.
  ENDIF.

ENDFORM.                    " DATA_SAVE_ZNFT1000

*&---------------------------------------------------------------------*
*&      Form  DELETE_CHECK_ZNFT1011
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LS_CONNO  text
*      -->P_LV_CHECK  text
*----------------------------------------------------------------------*
FORM DELETE_CHECK_ZNFT1011  USING  PS_CONNO
                                   PV_REQNO.

  SELECT SINGLE REQNO INTO PV_REQNO
    FROM ZNFT1011
   WHERE CONNO EQ PS_CONNO.

ENDFORM.                    " DELETE_CHECK_ZNFT1011
*&---------------------------------------------------------------------*
*&      Form  DELETE_CHECK_VBAP
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LS_CONNO  text
*      -->P_LV_CHECK  text
*----------------------------------------------------------------------*
FORM DELETE_CHECK_VBAP  USING    PS_CONNO
                                 PV_VBELN.

  SELECT SINGLE VBELN INTO PV_VBELN
    FROM VBAP
   WHERE CONNO EQ PS_CONNO.

ENDFORM.                    " DELETE_CHECK_VBAP

*&---------------------------------------------------------------------*
*&      Form  DATA_RELOAD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM DATA_RELOAD .

  PERFORM DATA_SELECT_ZNFT1000.

*  GS_STBL-ROW = 'X'.
*  GS_STBL-COL = 'X'.
*
*  CALL METHOD GRF_GRID->REFRESH_TABLE_DISPLAY
*    EXPORTING
*      I_SOFT_REFRESH = ' '
*      IS_STABLE      = GS_STBL.     "화면 라인 Refresh

ENDFORM.                    " DATA_RELOAD

*&---------------------------------------------------------------------*
*&      Form  SAVE_CHANGE_DOC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LV_FLAG  text
*      -->P_LT_ZNFT1000  text
*----------------------------------------------------------------------*
FORM SAVE_CHANGE_DOC TABLES PT_ZNFT1000.

  DATA: LS_ZNFT1000 TYPE ZNFT1000,
        LT_ZNFT1000 LIKE TABLE OF LS_ZNFT1000,
        LS_ZNFT1001 TYPE ZNFT1001,
        LT_ZNFT1001 LIKE TABLE OF LS_ZNFT1001,
        LS_ZNFT1002N TYPE ZNFT1002,
        LS_ZNFT1002Y TYPE ZNFT1002.

  DATA: XGT_1000 LIKE ZNFT1000,
        YGT_1000 LIKE ZNFT1000.

  DATA: LV_OBJECTID             TYPE CDHDR-OBJECTID,
        LV_TCODE                TYPE CDHDR-TCODE,
        LV_CDOC_UPD_OBJECT      TYPE CDHDR-CHANGE_IND,
        LV_UPD_ICDTXT           TYPE CHAR1.

  LT_ZNFT1000[] = PT_ZNFT1000[].

* ----------------------------------------------------------------------
* HEADER TABLE ZNFT1000의 CSTAT의 FLAG변경에 따른 변경이력관리
* - ITEM TABLE ZNFT1001은 변경되지 않음
* ----------------------------------------------------------------------
* 각각의 HEADER (XGT_1000, YGT_1000), ITEM (XGT_1001, YGT_1001)의 값을
* 만들어준다.
* ----------------------------------------------------------------------

  LOOP AT LT_ZNFT1000 INTO LS_ZNFT1000.

    LV_CDOC_UPD_OBJECT = 'U'.
    LV_OBJECTID = LS_ZNFT1000-CONNO.
    LV_TCODE    = SY-TCODE.

*   변경전/후 : ZNFT1000 ( XGT_1001 / YGT_1001 )

*   - 변경전 : YGT_1000
    MOVE-CORRESPONDING LS_ZNFT1000 TO YGT_1000.

*   - 변경전 : XGT_1000
    SELECT SINGLE * INTO CORRESPONDING FIELDS OF XGT_1000
      FROM ZNFT1000
     WHERE CONNO EQ LS_ZNFT1000-CONNO.

*   변경전/후 : ZNFT1001 ( XGT_1001 / YGT_1001 )
    SELECT * INTO CORRESPONDING FIELDS OF TABLE LT_ZNFT1001
      FROM ZNFT1001
     WHERE CONNO EQ LS_ZNFT1000-CONNO.

    IF SY-SUBRC EQ 0.
      LOOP AT LT_ZNFT1001 INTO LS_ZNFT1001.
        CLEAR : XGT_1001.
        MOVE-CORRESPONDING LS_ZNFT1001 TO XGT_1001.
        XGT_1001-KZ = 'U'.
        APPEND XGT_1001.
      ENDLOOP.

      YGT_1001[] = XGT_1001[].
    ENDIF.

    CALL FUNCTION 'ZNFT1000CHDOC_WRITE_DOCUMENT'
      EXPORTING
        OBJECTID                      = LV_OBJECTID
        TCODE                         = LV_TCODE
        UTIME                         = SY-TIMLO
        UDATE                         = SY-DATLO
        USERNAME                      = SY-UNAME
*       PLANNED_CHANGE_NUMBER         = ' '
*       OBJECT_CHANGE_INDICATOR       = 'U'
*       PLANNED_OR_REAL_CHANGES       = ' '
*       NO_CHANGE_POINTERS            = ' '
        N_ZNFT1000                    = XGT_1000
        O_ZNFT1000                    = YGT_1000
        UPD_ZNFT1000                  = LV_CDOC_UPD_OBJECT
        UPD_ZNFT1001                  = LV_CDOC_UPD_OBJECT
        N_ZNFT1002                    = LS_ZNFT1002N
        O_ZNFT1002                    = LS_ZNFT1002Y
        UPD_ZNFT1002                  = 'U'
    TABLES
      XZNFT1001                     = XGT_1001
      YZNFT1001                     = YGT_1001.

  ENDLOOP.

ENDFORM.                    " SAVE_CHANGE_DOC

*&---------------------------------------------------------------------*
*&      Form  FILL_CELLTAB_C
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM FILL_CELLTAB_C CHANGING PT_CELLTAB TYPE LVC_T_STYL.

  DATA : LS_CELLTAB TYPE LVC_S_STYL,
         L_MODE     TYPE RAW4.

  DATA : L_FIELDCAT TYPE LVC_S_FCAT.

  LOOP AT GT_FIELDCAT INTO L_FIELDCAT.
    LS_CELLTAB-FIELDNAME = L_FIELDCAT-FIELDNAME.

*   필드 활성화 여부
    CASE LS_CELLTAB-FIELDNAME.
      WHEN 'CHECK'.
        LS_CELLTAB-STYLE = CL_GUI_ALV_GRID=>MC_STYLE_ENABLED.
      WHEN 'CSTAT'.
        IF GS_OUTTAB-CHECK EQ 'X' AND GS_OUTTAB-CSTAT_DM NE 'C'.
          LS_CELLTAB-STYLE = CL_GUI_ALV_GRID=>MC_STYLE_ENABLED.
        ELSE.
          LS_CELLTAB-STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED.
        ENDIF.
      WHEN 'CDATE'.
        IF GS_OUTTAB-CHECK EQ 'X' AND
            GS_OUTTAB-CSTAT EQ 'C' AND
            GS_OUTTAB-CSTAT_DM NE 'C'.
          LS_CELLTAB-STYLE = CL_GUI_ALV_GRID=>MC_STYLE_ENABLED.
        ELSE.
          LS_CELLTAB-STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED.
        ENDIF.
      WHEN OTHERS.
        LS_CELLTAB-STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED.
    ENDCASE.
    INSERT LS_CELLTAB INTO TABLE PT_CELLTAB.
  ENDLOOP.

ENDFORM.                    " FILL_CELLTAB_C


*&---------------------------------------------------------------------*
*&      Form  ENQUEUE_ZNFT1000
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM ENQUEUE_ZNFT1000 USING PS_CONNO
                            PV_ERROR.

  DATA: LV_MSGV1  LIKE SY-MSGV1.
  CLEAR : PV_ERROR.

  CALL FUNCTION 'ENQUEUE_EZ_ZNFT1000'
    EXPORTING
      CONNO          = PS_CONNO
    EXCEPTIONS
      FOREIGN_LOCK   = 1
      SYSTEM_FAILURE = 2
      OTHERS         = 3.

  IF SY-SUBRC <> 0.
    LV_MSGV1 = SY-MSGV1.
    PV_ERROR = 'X'.
    MESSAGE S003 DISPLAY LIKE 'E'
       WITH '계약번호' PS_CONNO
            '이(가) 현재 처리중입니다. 사용자:' LV_MSGV1.
  ENDIF.

ENDFORM.                    " ENQUEUE_ZNFT1000

*&---------------------------------------------------------------------*
*&      Form  DEQUEUE_ZNFT1000_S
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM DEQUEUE_ZNFT1000_S USING PV_CONNO.

  CALL FUNCTION 'DEQUEUE_EZ_ZNFT1000'
    EXPORTING
      CONNO = PV_CONNO.

ENDFORM.                    " DEQUEUE_ZNFT1000_S

*&---------------------------------------------------------------------*
*&      Form  DEQUEUE_ZNFT1000_T
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM DEQUEUE_ZNFT1000_T.

  LOOP AT GT_CONNO INTO GS_CONNO.
    CALL FUNCTION 'DEQUEUE_EZ_ZNFT1000'
      EXPORTING
        CONNO = GS_CONNO-CONNO.
  ENDLOOP.

ENDFORM.                    " DEQUEUE_ZNFT1000_T
*&---------------------------------------------------------------------*
*&      Form  F4HELP_CSTAT
*&---------------------------------------------------------------------*
*       선택된 계약 상태값에 따른 코드와 상태명을 변경
*----------------------------------------------------------------------*
*.계약상태값 변경시 오류 현상 개선
* (C20120821_68213 Req. by 구영헌 2012/08/23)
FORM F4HELP_CSTAT  USING  PV_CSTAT
                          PV_CSTAT_NM.

  CLEAR   : SELECTFIELD, SELECT_VALUE, LD_TABIX, GV_INDEX,
            IT_FIELDS.
  REFRESH : IT_FIELDS.

  DATA: BEGIN OF LS_CSTAT,
         DOMVALUE_L LIKE DD07T-DOMVALUE_L,
         DDTEXT     LIKE DD07T-DDTEXT,
        END OF LS_CSTAT,
        LT_CSTAT LIKE TABLE OF LS_CSTAT.

  SELECT DOMVALUE_L
         DDTEXT
         INTO CORRESPONDING FIELDS OF TABLE LT_CSTAT
    FROM DD07T
   WHERE DOMNAME EQ 'ZCSTAT'
     AND DDLANGUAGE EQ SY-LANGU
     AND AS4LOCAL EQ 'A'
     AND DOMVALUE_L NE 'D'.

  IF SY-SUBRC NE 0.
    MESSAGE S003 DISPLAY LIKE 'E'
       WITH '결재상 정보가 존재하지 않습니다.'.
    EXIT.
  ENDIF.

* 아래 부분이 F4를 눌렀을 때, Hit List를 보여준다.
  IT_FIELDS-TABNAME    = 'DD07T'.    IT_FIELDS-FIELDNAME  = 'DOMVALUE_L'.
  IT_FIELDS-SELECTFLAG = 'X'.
  APPEND IT_FIELDS.

  IT_FIELDS-TABNAME    = 'DD07T'.    IT_FIELDS-FIELDNAME  = 'DDTEXT'.
  IT_FIELDS-SELECTFLAG = ' '.
  APPEND IT_FIELDS.

  CALL FUNCTION 'HELP_VALUES_GET_NO_DD_NAME'
    EXPORTING
      SELECTFIELD                  = SELECTFIELD
    IMPORTING
      IND                          = LD_TABIX
      SELECT_VALUE                 = SELECT_VALUE
    TABLES
      FIELDS                       = IT_FIELDS
      FULL_TABLE                   = LT_CSTAT
    EXCEPTIONS
      FULL_TABLE_EMPTY             = 1
      NO_TABLESTRUCTURE_GIVEN      = 2
      NO_TABLEFIELDS_IN_DICTIONARY = 3
      MORE_THEN_ONE_SELECTFIELD    = 4
      NO_SELECTFIELD               = 5
      OTHERS                       = 6.

  CHECK NOT LD_TABIX IS INITIAL.
  CLEAR LS_CSTAT.
  READ TABLE LT_CSTAT INTO LS_CSTAT INDEX LD_TABIX.
  IF SY-SUBRC = 0.
    PV_CSTAT = LS_CSTAT-DOMVALUE_L.
    PV_CSTAT_NM = LS_CSTAT-DDTEXT.
  ENDIF.

ENDFORM.                    " F4HELP_CSTAT
