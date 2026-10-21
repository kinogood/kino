*&---------------------------------------------------------------------*
*&  Include           ZNFR2000F01
*&---------------------------------------------------------------------*
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
    'COTYP'           '계약유형'        '10'     'C'    ' '     ,
    'COTYP_NM'        '계약유형'        '10'     'C'    ' '     ,
    'BUKRS'           '회사코드'        '10'     'C'    ' '     ,
    'BUKRS_NM'        '회사명'          '10'     'L'    ' '     ,
    'NFCTR'           '사업부'          '10'     'C'    ' '     ,
    'NFCTR_NM'        '사업부명'        '10'     'L'    ' '     ,
    'PRCTR'           '손익센터'        '10'     'C'    ' '     ,
    'PRCTR_NM'        '손익센터명'      '10'     'L'    ' '     ,
    'ZPJNO'           'Project NO'      '10'     'C'    ' '     ,
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
    'CSTAT'           '계약상태'        '8'      'C'    ' '     ,
    'CSTAT_NM'        '계약상태'        '8'      'C'    ' '     ,
    'CDATE'           '계약취소일'      '10'     'C'    ' '     ,
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
      GS_FIELDCAT-CHECKBOX = 'X'.
      GS_FIELDCAT-EDIT     = 'X'.
    WHEN 'BUKRS' OR 'NFCTR' OR 'PRCTR' OR 'VKGRP' OR 'COTYP' OR 'CSTAT'.
      GS_FIELDCAT-NO_OUT = 'X'.
    WHEN 'PRICE'.
      GS_FIELDCAT-CFIELDNAME = 'WAERS'.
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
         L_INDEX    TYPE I.

  LOOP AT GT_OUTTAB INTO GS_OUTTAB.
    L_INDEX = SY-TABIX.
    REFRESH LT_CELLTAB.
    CLEAR GS_OUTTAB-CELLTAB.
    INSERT LINES OF LT_CELLTAB INTO TABLE GS_OUTTAB-CELLTAB.
    MODIFY GT_OUTTAB FROM GS_OUTTAB INDEX L_INDEX.
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
    GRF_EVENT_RECEIVER->HANDLE_DOUBLE_CLICK FOR GRF_GRID.


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
  GS_F4-FIELDNAME = 'CONNO'.
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
      IS_VARIANT                    = GS_VARIANT
      IS_LAYOUT                     = GS_LAYOUT
      I_SAVE                        = 'A'
      I_DEFAULT                     = 'X'
      IT_TOOLBAR_EXCLUDING          = GT_EXCLUDE
    CHANGING
      IT_FIELDCATALOG               = GT_FIELDCAT[]
      IT_SORT                       = GT_SORT[]
      IT_OUTTAB                     = GT_OUTTAB[]
      IT_FILTER                     = GT_FILTER
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

* FOR ALL ENTRIES 용 Internal Table
  DATA: BEGIN OF LS_CONNO,
          CONNO LIKE ZNFT1011-CONNO,
        END OF LS_CONNO.
  DATA: LT_CONNO LIKE TABLE OF LS_CONNO.

* 선물집행이 취소되지 않으면서 마감된 건은 제외
* 위의 조건을 만족하는 계약번호를 제외한다.
  SELECT Z1~CONNO INTO CORRESPONDING FIELDS OF TABLE LT_CONNO
    FROM ZNFT1011 AS Z1
         INNER JOIN ZNFT1020 AS Z2
            ON Z2~REQNO EQ Z1~REQNO AND Z2~H_NO1 EQ Z1~H_NO1
   WHERE Z2~YNCAN NE 'X'
     AND Z2~YNFIN EQ 'X'.

* CSTAT : D (삭제) 제외
  SELECT * INTO CORRESPONDING FIELDS OF TABLE GT_OUTTAB
    FROM ZNFT1000 AS Z1
   WHERE Z1~BUKRS EQ P_BUKRS
     AND Z1~ERDAT IN S_ERDAT
     AND Z1~CONNO IN S_CONNO
     AND Z1~ZPJNO IN S_ZPJNO
     AND Z1~NFCTR IN S_NFCTR
     AND Z1~PRCTR IN S_PRCTR
     AND Z1~VKGRP IN S_VKGRP
     AND Z1~ERNAM IN S_ERNAM
     AND Z1~CSTAT NE 'D'. " 삭제인건 제외

  CLEAR LV_TABIX.
  IF GT_OUTTAB IS NOT INITIAL.
    LOOP AT GT_OUTTAB INTO GS_OUTTAB.
      LV_TABIX = SY-TABIX.
      READ TABLE LT_CONNO INTO LS_CONNO
        WITH KEY CONNO = GS_OUTTAB-CONNO.
      IF SY-SUBRC EQ 0.
        DELETE GT_OUTTAB INDEX LV_TABIX.
      ENDIF.
    ENDLOOP.
  ENDIF.

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
        GS_OUTTAB-KUNNR_NM = GS_OUTTAB-KUNNR_NM.
      ENDIF.

*   - 계약유형
      PERFORM DOMAIN_VALUE_GET USING 'ZCOTYP'
                                     GS_OUTTAB-COTYP
                                     GS_OUTTAB-COTYP_NM.

*   - 상태
      PERFORM DOMAIN_VALUE_GET USING 'ZCSTAT'
                                     GS_OUTTAB-CSTAT
                                     GS_OUTTAB-CSTAT_NM.

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

  CLEAR LV_INDEX.
  CLEAR GS_CONNO.
  LOOP AT P_DATA_CHANGED->MT_GOOD_CELLS INTO LS_MOD_CELLS.
    LV_INDEX = LS_MOD_CELLS-ROW_ID.

*   Data 가공용 Structure
    READ TABLE GT_OUTTAB INTO GS_OUTTAB INDEX LV_INDEX.

    IF SY-SUBRC EQ 0.
      CASE LS_MOD_CELLS-FIELDNAME.
        WHEN 'CHECK'.
          IF LS_MOD_CELLS-VALUE EQ 'X'.
            GS_OUTTAB-CHECK = 'X'.

*           해당 계약번호 LOCK OBJECT 잠금
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

          ELSE.
            GS_OUTTAB-CHECK = SPACE.

*           해당 계약번호 LOCK OBJECT 잠금해제
            GS_CONNO-CONNO = GS_OUTTAB-CONNO.
            DELETE GT_CONNO FROM GS_CONNO.
            PERFORM DEQUEUE_ZNFT1000_S USING GS_CONNO-CONNO.
            DELETE ADJACENT DUPLICATES FROM GT_CONNO.

          ENDIF.
          MODIFY GT_OUTTAB FROM GS_OUTTAB INDEX LV_INDEX.
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
*&      Form  CALL_TRANSACTION_ZNF2M2002
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CALL_TRANSACTION_ZNF2M2002 .

  DATA: LV_CONNO TYPE ZCONNO,
        LV_CNT   TYPE I.

  LV_CNT = 0.
  LOOP AT GT_OUTTAB INTO GS_OUTTAB WHERE CHECK EQ 'X'.
    ADD 1 TO LV_CNT.
    LV_CONNO = GS_OUTTAB-CONNO.
  ENDLOOP.

  CASE LV_CNT.
    WHEN 0.
      MESSAGE '수정하실 데이터를 선택하십시오.'
         TYPE 'S' DISPLAY LIKE 'E'.
      EXIT.
    WHEN 1.
*     Lock Object 잠금해제
      PERFORM DEQUEUE_ZNFT1000_S USING LV_CONNO.

*     T-CODE별로 구분
      CASE SY-TCODE.
        WHEN GV_TCODE1.
          SET PARAMETER ID 'ZNFCON' FIELD LV_CONNO.
          CALL TRANSACTION 'ZNF2M2002A' AND SKIP FIRST SCREEN.
        WHEN GV_TCODE2.
          SET PARAMETER ID 'ZNFCON' FIELD LV_CONNO.
          CALL TRANSACTION 'ZNF2M2002B' AND SKIP FIRST SCREEN.
      ENDCASE.

    WHEN OTHERS.
      MESSAGE '계약정보의 수정은 하나만 선택이 가능합니다.'
         TYPE 'S' DISPLAY LIKE 'W'.
      EXIT.
  ENDCASE.

ENDFORM.                    " CALL_TRANSACTION_ZNF2M2002
*&---------------------------------------------------------------------*
*&      Form  DATA_DELETE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM DATA_DELETE .

  DATA: LV_REQNO TYPE ZREQNO_1,
        LV_VBELN TYPE VBELN_VA,
        LV_ERROR TYPE CHAR01,
        LV_R_MSG TYPE CHAR100.

  DATA: BEGIN OF LS_CONNO,
          CONNO TYPE ZCONNO,
        END OF LS_CONNO.
  DATA: LT_CONNO LIKE TABLE OF LS_CONNO.

  DATA: LT_ZNFT1000  LIKE TABLE OF ZNFT1000 WITH HEADER LINE,
        LT_ZNFT1000Y LIKE TABLE OF ZNFT1000 WITH HEADER LINE.

* FOR ALL ENTRIES 용 인터널테이블 생성
  LOOP AT GT_OUTTAB INTO GS_OUTTAB WHERE CHECK EQ 'X'.
    LS_CONNO = GS_OUTTAB-CONNO.
    APPEND LS_CONNO TO LT_CONNO.
  ENDLOOP.

  IF LT_CONNO IS INITIAL.
    MESSAGE '삭제하실 데이터를 선택하십시오.'
       TYPE 'S' DISPLAY LIKE 'E'.
    EXIT.
  ENDIF.

  CLEAR LV_R_MSG.
  LOOP AT LT_CONNO INTO LS_CONNO.
    PERFORM DELETE_CHECK_ZNFT1011 USING LS_CONNO LV_REQNO.
    IF LV_REQNO IS NOT INITIAL.
      CLEAR LV_R_MSG.
      CONCATENATE '계약번호' LS_CONNO '는 선물요청 ' LV_REQNO
                  '와 연결되어 있어 삭제가 불가능합니다.'
                  INTO LV_R_MSG.
      MESSAGE LV_R_MSG TYPE 'S' DISPLAY LIKE 'E'.
      LV_ERROR = 'X'.
      EXIT.
    ENDIF.

    PERFORM DELETE_CHECK_VBAP     USING LS_CONNO LV_VBELN.
    IF LV_VBELN IS NOT INITIAL.
      CLEAR LV_R_MSG.
      CONCATENATE '계약번호' LS_CONNO '는 S/O ' LV_VBELN
                  '와 연결되어 있어 삭제가 불가능합니다.'
                  INTO LV_R_MSG.
      MESSAGE LV_R_MSG TYPE 'S' DISPLAY LIKE 'E'.
      LV_ERROR = 'X'.
      EXIT.
    ENDIF.
  ENDLOOP.

  CHECK LV_ERROR NE 'X'.

*.진행상황 체크
  CLEAR GV_ANSWER.
  PERFORM POPUP_TO_CONFIRM USING '삭제'
          '선택된 계약(들)이 완전히 삭제됩니다. 삭제를 진행하시겠습니까?'                                 '1'
                                 GV_ANSWER.
  CHECK GV_ANSWER EQ '1'.

* -------------------------------------------------------------
* 점검결과 이상없을경우 삭제 (ZNFT1000-CSTAT = 'D'로 상태변경)
* -------------------------------------------------------------
  CLEAR LT_ZNFT1000. REFRESH LT_ZNFT1000.
  IF LT_CONNO IS NOT INITIAL.
    SELECT * INTO CORRESPONDING FIELDS OF TABLE LT_ZNFT1000
      FROM ZNFT1000
           FOR ALL ENTRIES IN LT_CONNO
     WHERE CONNO EQ LT_CONNO-CONNO.

    IF SY-SUBRC EQ 0 AND LT_ZNFT1000[] IS NOT INITIAL.
      LT_ZNFT1000Y[] = LT_ZNFT1000[].
      LT_ZNFT1000-CSTAT = 'D'.
      MODIFY LT_ZNFT1000 TRANSPORTING CSTAT WHERE CONNO NE SPACE.
      IF SY-SUBRC EQ 0.
        MODIFY ZNFT1000 FROM TABLE LT_ZNFT1000.
        IF SY-SUBRC EQ 0.
          PERFORM SAVE_CHANGE_DOC TABLES LT_ZNFT1000Y.
          COMMIT WORK.
          MESSAGE '데이터를 삭제하였습니다.'
             TYPE 'S' DISPLAY LIKE 'S'.
        ELSE.
          ROLLBACK WORK.
          MESSAGE '데이터 삭제에 실패하였습니다.'
             TYPE 'S' DISPLAY LIKE 'E'.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.
ENDFORM.                    " DATA_DELETE
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

* 변경전 데이터 PT_ZNFT1000
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

*   변경 전/후 : ZNFT1000 ( XGT_1001 / YGT_1001 )

*   ### Header ###
*   - 변경전 : YGT_1000
    MOVE-CORRESPONDING LS_ZNFT1000 TO YGT_1000.
*   - 변경후 : XGT_1000
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

    IF SY-SUBRC EQ 0.

    ENDIF.

  ENDLOOP.

ENDFORM.                    " SAVE_CHANGE_DOC

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
