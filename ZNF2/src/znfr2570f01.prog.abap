*&---------------------------------------------------------------------*
*&  Include           ZNFR2510F01
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

  CLEAR GS_LAYOUT.
  GS_LAYOUT-SEL_MODE   = 'A'.
  GS_LAYOUT-ZEBRA      = 'X'.
  GS_LAYOUT-CWIDTH_OPT = 'X'.
  GS_LAYOUT-STYLEFNAME = 'CELLTAB'.
  GS_LAYOUT-CTAB_FNAME = 'COLINFO'.
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

  CLEAR : GS_SORT. REFRESH GT_SORT.

  GS_SORT-SPOS = 1.
  GS_SORT-FIELDNAME = 'NFUTN'.
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

  CLEAR GT_FIELDCAT.   REFRESH GT_FIELDCAT.

  PERFORM SET_FIELDCAT USING:
  'CHECK'       '선택'             '10'     'C'    ' '     ,
  'GUBUN'       '구분'             '10'     'C'    ' '     ,
  'RESON'       '변경사유'         '20'     'L'    ' '     ,
  'YNCAN'       '삭제여부'         '10'     'C'    ' '     ,
  'NFUTN'       '선물집행번호'     '12'     'L'    ' '     ,
  'AUDAT'       '승인요청일'       '10'     'C'    ' '     ,
  'RUDAT'       '집행일'           '10'     'C'    ' '     ,
  'FCM'         'FCM'              '5'      'C'    'ALPHA' ,
  'FCM_NM'      'FCM'              '20'     'L'    ' '     ,
  'BY_SL'       'Buy/Sell'         '10'     'C'    ' '     ,
  'BY_SL_NM'    'Buy-Sell'         '10'     'C'    ' '     ,
  'ENDAT'       '만기일'           '10'     'C'    ' '     ,
  'MITYP'       '집행유형'         '10'     'C'    ' '     ,
  'MISPD'       'Spread'           '10'     'R'    ' '     ,
  'MIMON'       '기준월'           '10'     'C'    ' '     ,
  'PRICE'       '집행단가'         '15'     'R'    ' '     ,
  'WAERS'       '통화'             '5'      'C'    ' '     ,
  'EMENG'       '집행수량'         '14'     'R'    ' '     ,
  'MEINS'       '단위'             '10'     'C'    ' '     ,
  'MISUS'       '수수료'           '10'     'C'    ' '     ,
  'NFKEY'       '비철구분'         '10'     'C'    ' '     ,
  'BIGO4'       '비고'             '20'     'L'    ' '     ,
  'RQTYP'       '요청유형'         '10'     'C'    ' '     ,
  'CONNO'       '계약번호'         '10'     'C'    ' '     ,
  'PRCTR'       '손익센터'         '10'     'C'    'ALPHA' ,
  'PTEXT'       '손익센터명'       '10'     'L'    ' '     ,
  'COTXT'       '계약명'           '20'     'L'    ' '     ,
  'NCUST'       '고객명'           '20'     'L'    ' '     ,
  'PRIND'       '가격구분'         '10'     'C'    ' '     ,
  'SUJUP'       '비철수주가'       '10'     'R'    ' '     ,
  'AEDAT'       '수정요청일'       '10'     'C'    ' '     ,
  'AEZET'       '수정요청시간'     '6'      'C'    ' '     ,
  'AENAM'       '수정요청자'       '10'     'C'    ' '     ,
  'ANAME'       '수정요청자명'     '10'     'C'    ' '     ,
  'ERDAT'       '요청일'           '10'     'C'    ' '     ,
  'ERZET'       '요청시간'         '6'      'C'    ' '     ,
  'ERNAM'       '요청자'           '10'     'C'    ' '     ,
  'ENAME'       '요청자명'         '10'     'C'    ' '     .

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
    WHEN 'BY_SL'.
      GS_FIELDCAT-NO_OUT     = 'X'.
    WHEN 'YNCAN'.
      GS_FIELDCAT-CHECKBOX   = 'X'.
    WHEN 'PRICE'.
      GS_FIELDCAT-CFIELDNAME = 'WAERS'.
    WHEN 'EMENG'.
      GS_FIELDCAT-QFIELDNAME = 'MEINS'.
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
  DATA: LT_CELLTAB TYPE LVC_T_STYL,
        LT_COLOR   TYPE LVC_T_SCOL,
        LV_INDEX   TYPE I.

  LOOP AT GT_OUTTAB_F INTO GS_OUTTAB_F.
    LV_INDEX = SY-TABIX.
    CLEAR GS_OUTTAB_F-CELLTAB.
    CLEAR LT_COLOR. REFRESH LT_COLOR.
    PERFORM FILL_CELLTAB_C CHANGING LT_CELLTAB.
    PERFORM FILL_COLOR CHANGING LT_COLOR.
    INSERT LINES OF LT_COLOR INTO TABLE GS_OUTTAB_F-COLINFO.
    MODIFY GT_OUTTAB_F FROM GS_OUTTAB_F INDEX LV_INDEX.
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

** FieldName별 소트해서 APPEND
* GS_F4-FIELDNAME = 'NFUTN'.
* GS_F4-REGISTER  = 'X'.
* APPEND GS_F4 TO GT_F4.
*
* CALL METHOD GRF_GRID->REGISTER_F4_FOR_FIELDS
*   EXPORTING
*     IT_F4 = GT_F4.

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
      IT_OUTTAB                     = GT_OUTTAB_F[]
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
*&      Form  GET_REQ_LIST
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_REQ_LIST .

*   =========================================
*   REQ_TYPE 코드값(Hotsopt용 구분값)
*   =========================================
*   'A' = 선물요청승인
*   'B' = 만기이동요청승인
*   'C' = 만기이동집행승인
*   'D' = 신규선물집행승인
*   'E' = 청산선물집행승인
*   'F' = 신규/청산선물집행수정승인
*   =========================================

  CLEAR : GV_PERNR, GV_UNAME, GV_ERROR.
  CLEAR : GT_PERNR. REFRESH GT_PERNR[].

  IF P_UNAME IS NOT INITIAL.
    GV_UNAME = P_UNAME.
  ELSE.
    GV_UNAME = SY-UNAME.
  ENDIF.

  PERFORM GET_USRID_PER_SAPID TABLES GT_PERNR
                               USING GV_UNAME
                                     GV_PERNR.
*   개인아이디 : GV_PERNR // 공용아이디 : GT_PERNR
*   GV_PERNR 과 GT_PERNR은 둘다 가질수 없음
  IF GV_PERNR IS NOT INITIAL.
    GT_PERNR-PERNR = GV_PERNR.
    APPEND GT_PERNR.
  ENDIF.

  IF GT_PERNR[] IS INITIAL.
    MESSAGE S003 DISPLAY LIKE 'E'
       WITH GV_UNAME '에 대한 사번정보가 존재하지 않습니다.'.
    GV_ERROR = 'X'.
    EXIT.
  ENDIF.

* --------------------------------------------------------------------
* 'F' = 신규/청산선물집행수정승인
* --------------------------------------------------------------------
  DATA  : LV_CNT TYPE I.
  CLEAR : LV_CNT, GV_H_CNT.
  CLEAR : GS_NFNUM. REFRESH : GT_NFNUM_F.
  CLEAR : GV_AUTH.

* 개인아이디인 경우 GV_PERNR을 GT_PERNR에 APPEND해서
* 공통적으로 FOR ALL ENTRIES IN GT_PERNR를 이용해서 체크
  IF GV_PERNR IS NOT INITIAL.
    CLEAR GT_PERNR. REFRESH GT_PERNR.
    GT_PERNR-PERNR = GV_PERNR.
    APPEND GT_PERNR.
  ENDIF.

* ############### 신규 ###############
  CLEAR LV_CNT.
  SELECT COUNT(*) INTO LV_CNT
    FROM ZNFT1090
         FOR ALL ENTRIES IN GT_PERNR
   WHERE BUKRS EQ P_BUKRS
     AND CONGB EQ '3'
     AND CONSQ EQ '1'
     AND PERNR EQ GT_PERNR-PERNR
     AND LVORM NE 'X'.

  IF SY-SUBRC EQ 0 AND LV_CNT GE 0.
    GV_AUTH = 'A'.
*   신규건수
    CLEAR LV_CNT.
    SELECT COUNT(*) INTO LV_CNT
      FROM ZNFT1020
     WHERE BUKRS EQ P_BUKRS
       AND CONFM EQ '6'
*       AND OLDFT EQ SPACE
*       AND YNCAN NE 'X'
       AND YNFIN NE 'X'
       AND YNNET NE 'X'.

    IF SY-SUBRC EQ 0.
      ADD LV_CNT TO GV_H_CNT.
    ENDIF.
  ELSE.
    GV_ERROR = 'X'.
    MESSAGE S003 DISPLAY LIKE 'E'
       WITH GV_UNAME '에 대한 승인권한이 없습니다.'.
    EXIT.
  ENDIF.

* ############### 청산 ###############

  CLEAR LV_CNT.
  SELECT COUNT(*) INTO LV_CNT
    FROM ZNFT1090
         FOR ALL ENTRIES IN GT_PERNR
   WHERE BUKRS EQ P_BUKRS
     AND CONGB EQ '4'
     AND CONSQ EQ '1'
     AND PERNR EQ GT_PERNR-PERNR
     AND LVORM NE 'X'.

  IF SY-SUBRC EQ 0 AND LV_CNT NE 0.
    IF GV_AUTH IS INITIAL.
      GV_AUTH = 'B'.
    ELSE.
      GV_AUTH = 'C'.
    ENDIF.
*   청산건수
    CLEAR LV_CNT.
    SELECT COUNT(*) INTO LV_CNT
      FROM ZNFT1030
     WHERE BUKRS EQ P_BUKRS
       AND CONFM EQ '6'
*       AND OLDFT EQ SPACE
*       AND YNCAN NE 'X'
       AND YNFIN NE 'X'
       AND YNNET NE 'X'.

    IF SY-SUBRC EQ 0.
      ADD LV_CNT TO GV_H_CNT.
    ENDIF.
  ELSE.
    GV_ERROR = 'X'.
    MESSAGE S003 DISPLAY LIKE 'E'
       WITH GV_UNAME '에 대한 승인권한이 없습니다.'.
    EXIT.
  ENDIF.

  IF GV_H_CNT IS INITIAL.
    IF OK_SAVE EQ 'ALLOW' OR OK_SAVE EQ 'REJECT' OR
       OK_SAVE EQ 'CONF'  OR OK_SAVE EQ 'CANC'.
      GV_ERROR = 'X'.
    ELSE.
      GV_ERROR = 'X'.
      MESSAGE S003 DISPLAY LIKE 'E'
         WITH GV_UNAME
              '에 대한 수정승인 데이터가 존재하지 않습니다.'.
    ENDIF.
  ENDIF.

ENDFORM.                    " GET_REQ_LIST

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
        LV_INDEX     TYPE I,
        LV_TABIX     TYPE I.

  DATA: LT_LVC_STYL TYPE LVC_T_STYL,
        LS_LVC_STYL TYPE LVC_S_STYL.

  DATA: LV_CSTAT LIKE ZNFT1000-CSTAT,
        LV_CDATE LIKE ZNFT1000-CDATE.

  FIELD-SYMBOLS : <FS_ITAB> TYPE ANY TABLE.

  CLEAR:LV_CSTAT, LV_CDATE.
  CLEAR LT_LVC_STYL. REFRESH LT_LVC_STYL.
  CLEAR LV_INDEX.

  CLEAR GS_OUTTAB_F.
  LOOP AT P_DATA_CHANGED->MT_GOOD_CELLS INTO LS_MOD_CELLS.
    LV_INDEX = LS_MOD_CELLS-ROW_ID.
*   Data 가공용 Structure
    READ TABLE GT_OUTTAB_F INTO GS_OUTTAB_F INDEX LV_INDEX.
    IF SY-SUBRC EQ 0.
      CASE LS_MOD_CELLS-FIELDNAME.
        WHEN 'CHECK'.
          IF LS_MOD_CELLS-VALUE EQ 'X'.
            GS_OUTTAB_F-CHECK = 'X'.
            MODIFY GT_OUTTAB_F FROM GS_OUTTAB_F INDEX LV_INDEX
                               TRANSPORTING CHECK.
          ELSE.
            GS_OUTTAB_F-CHECK = SPACE.
            MODIFY GT_OUTTAB_F FROM GS_OUTTAB_F INDEX LV_INDEX
                               TRANSPORTING CHECK.
          ENDIF.
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

  READ TABLE GT_OUTTAB_F INTO GS_OUTTAB_F INDEX P_ES_ROW_NO-ROW_ID.

  IF SY-SUBRC EQ 0.

    CASE P_E_COLUMN.
      WHEN 'CONNO'.
        IF NOT GS_OUTTAB_F-CONNO IS INITIAL.
          SET PARAMETER ID 'ZNFCON' FIELD GS_OUTTAB_F-CONNO.
          CALL TRANSACTION 'ZNF2M2003' AND SKIP FIRST SCREEN.
        ELSE.
          MESSAGE '계약번호가 존재하지 않습니다.'
             TYPE 'S' DISPLAY LIKE 'E'.
        ENDIF.
      WHEN 'NFUTN'.
        IF GS_OUTTAB_F-GUBUN EQ '신규'.
          PERFORM CALL_NFUTN_PGM USING GS_OUTTAB_F-NFUTN.
        ELSE.
          PERFORM CALL_CFUTN_PGM USING GS_OUTTAB_F-NFUTN.
        ENDIF.
    ENDCASE.

  ENDIF.

ENDFORM.                    " ALV_EVENT_DOUBLE_CLICK

*&---------------------------------------------------------------------*
*&      Form  DATA_SELECT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GS_LIST_REQ_TYPE  text
*----------------------------------------------------------------------*
FORM DATA_SELECT.

  PERFORM GET_REQNO_F.

ENDFORM.                    " DATA_SELECT

*&---------------------------------------------------------------------*
*&      Form  GET_REQNO_F
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_REQNO_F .

  DATA: LV_FLAG TYPE CHAR01.
  DATA: LS_OUTTAB_F01 LIKE GS_OUTTAB_F,
        LT_OUTTAB_F01 LIKE TABLE OF LS_OUTTAB_F01,
        LS_OUTTAB_F02 LIKE GS_OUTTAB_F,
        LT_OUTTAB_F02 LIKE TABLE OF LS_OUTTAB_F02.

  DATA: LV_TABIX TYPE SY-TABIX,
        LV_ERROR TYPE CHAR01.

  CLEAR   : GS_OUTTAB_F.
  REFRESH : LT_OUTTAB_F01, LT_OUTTAB_F02.

  IF GV_AUTH EQ 'A' OR GV_AUTH EQ 'C'.
    SELECT Z1~BIGO4
           Z1~YNCAN
           Z1~NFUTN          " ZNFT1030-CFUTN
           Z1~AEDAT AS AUDAT " 승인요청일
           Z1~RUDAT
           Z1~FCM
           Z1~BY_SL
           Z1~ENDAT
           Z1~MITYP
           Z1~MISPD
           Z1~MIMON
           Z1~PRICE
           Z1~WAERS
           Z1~EMENG
           Z1~MEINS
           Z1~MISUS
           Z1~NFKEY
           Z3~RQTYP
           Z4~CONNO
           Z4~PRCTR
           Z4~COTXT
           Z4~NCUST
           Z1~RESON
           Z1~AEDAT
           Z1~AEZET
           Z1~AENAM
           Z1~ERDAT
           Z1~ERZET
           Z1~ERNAM
*          가격구분
*          비철수주가격
           INTO CORRESPONDING FIELDS OF TABLE LT_OUTTAB_F01
      FROM ZNFT1020 AS Z1
           INNER JOIN ZNFT1011 AS Z2
             ON Z2~REQNO EQ Z1~REQNO AND Z2~H_NO1 EQ Z1~H_NO1
           INNER JOIN ZNFT1010 AS Z3
             ON Z3~REQNO EQ Z1~REQNO
           INNER JOIN ZNFT1000 AS Z4
             ON Z4~CONNO EQ Z2~CONNO
     WHERE Z1~BUKRS EQ P_BUKRS
       AND Z1~CONFM EQ '6'
*       AND Z1~OLDFT EQ SPACE
*       AND Z1~YNCAN NE 'X'
       AND Z1~YNFIN NE 'X'
       AND Z1~YNNET NE 'X'.

    IF SY-SUBRC EQ 0.
*     취합 : GT_OUTTAB_F
      SORT LT_OUTTAB_F01 BY NFUTN.

      CLEAR LS_OUTTAB_F01.
      LOOP AT LT_OUTTAB_F01 INTO LS_OUTTAB_F01.
        LS_OUTTAB_F01-GUBUN = '신규'.
        APPEND LS_OUTTAB_F01 TO GT_OUTTAB_F.
      ENDLOOP.
    ENDIF.
  ENDIF.

  IF GV_AUTH EQ 'B' OR GV_AUTH EQ 'C'.
    SELECT Z1~BIGO4
           Z1~YNCAN
           Z1~CFUTN AS NFUTN
           Z1~AEDAT AS AUDAT " 승인요청일
           Z1~RUDAT
           Z1~FCM
           Z1~BY_SL
           Z1~ENDAT
           Z1~MITYP
           Z1~MISPD
           Z1~MIMON
           Z1~PRICE
           Z1~WAERS
           Z1~EMENG
           Z1~MEINS
           Z1~MISUS
           Z1~NFKEY
           Z4~RQTYP
           Z5~CONNO
           Z5~PRCTR
           Z5~COTXT
           Z5~NCUST
           Z1~RESON
           Z1~AEDAT
           Z1~AEZET
           Z1~AENAM
           Z1~ERDAT
           Z1~ERZET
           Z1~ERNAM
*          가격구분
*          비철수주가격
           APPENDING CORRESPONDING FIELDS OF TABLE LT_OUTTAB_F02
      FROM ZNFT1030 AS Z1
           INNER JOIN ZNFT1020 AS Z2
             ON Z2~NFUTN EQ Z1~NFUTN AND Z2~BUKRS EQ Z1~BUKRS
           INNER JOIN ZNFT1011 AS Z3
             ON Z3~REQNO EQ Z2~REQNO AND Z3~H_NO1 EQ Z2~H_NO1
           INNER JOIN ZNFT1010 AS Z4
             ON Z4~REQNO EQ Z2~REQNO
           INNER JOIN ZNFT1000 AS Z5
             ON Z5~CONNO EQ Z3~CONNO
     WHERE Z1~BUKRS EQ P_BUKRS
       AND Z1~CONFM EQ '6'
*       AND Z1~OLDFT EQ SPACE
*       AND Z1~YNCAN NE 'X'
       AND Z1~YNFIN NE 'X'
       AND Z1~YNNET NE 'X'.

    IF SY-SUBRC EQ 0.
*     취합 : GT_OUTTAB_F
      SORT LT_OUTTAB_F02 BY NFUTN.
      CLEAR LS_OUTTAB_F02.
      LOOP AT LT_OUTTAB_F02 INTO LS_OUTTAB_F02.
        LS_OUTTAB_F02-GUBUN = '청산'.
        APPEND LS_OUTTAB_F02 TO GT_OUTTAB_F.
      ENDLOOP.
    ENDIF.
  ENDIF.

  IF GT_OUTTAB_F IS NOT INITIAL.
    SORT GT_OUTTAB_F BY NFUTN RUDAT.
    CLEAR: LV_TABIX, GS_OUTTAB_F.
    LOOP AT GT_OUTTAB_F INTO GS_OUTTAB_F.
      LV_TABIX = SY-TABIX.

      AT NEW NFUTN.
        LV_FLAG = 'X'.
      ENDAT.

      IF LV_FLAG = 'X'.
        CLEAR : LV_FLAG.
      ELSE.
        GS_OUTTAB_F-CHECK = '-'.
      ENDIF.

      PERFORM GET_LIFNR_DESC USING GS_OUTTAB_F-FCM
                                   GS_OUTTAB_F-FCM_NM.

      PERFORM GET_PRCTR_DESC USING P_BUKRS
                                   GS_OUTTAB_F-PRCTR
                                   GS_OUTTAB_F-PTEXT.

      PERFORM DOMAIN_VALUE_GET USING 'ZBY_SL'
                                     GS_OUTTAB_F-BY_SL
                                     GS_OUTTAB_F-BY_SL_NM.

*___생성인이름
      PERFORM GET_SAPID_NAME USING: GS_OUTTAB_F-AENAM
                                    GS_OUTTAB_F-ANAME,

                                    GS_OUTTAB_F-ERNAM
                                    GS_OUTTAB_F-ENAME.

*   - 가격구분/비철수주가
      PERFORM PRICE_CLASSIFICATION USING GS_OUTTAB_F-CONNO
                                         GS_OUTTAB_F-NFKEY
                                         GS_OUTTAB_F-PRIND
                                         GS_OUTTAB_F-SUJUP
                                         LV_ERROR.
      MODIFY GT_OUTTAB_F FROM GS_OUTTAB_F INDEX LV_TABIX.
      CLEAR: LV_TABIX, GS_OUTTAB_F.
    ENDLOOP.
  ENDIF.

ENDFORM.                    " GET_REQNO_F

*&---------------------------------------------------------------------*
*&      Form  DATA_ALLOW
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM DATA_ALLOW .

* 데이터 체크
  CLEAR GV_ERROR.
  PERFORM DATA_CHECK USING GV_ERROR.
  CHECK GV_ERROR NE 'X'.

* 진행상황 체크
  CLEAR GV_ANSWER.
  PERFORM POPUP_TO_CONFIRM
    USING '승인'
          '해당 데이터를 승인하시겠습니까?'
          '1'
          GV_ANSWER.
  CHECK GV_ANSWER EQ '1'.

* 공용아이디 체크로직
  SELECT SINGLE * FROM PA0105
   WHERE USRTY EQ '9001'
     AND USRID EQ GV_UNAME
     AND ENDDA GE SY-DATLO
     AND BEGDA LE SY-DATLO.

  IF SY-SUBRC EQ 0.
    CALL SCREEN 1210 STARTING AT 10 03
                     ENDING   AT 55 06.
    CHECK GV_ERROR NE 'X'.
  ENDIF.

  PERFORM DATA_ALLOW_F.

ENDFORM.                    " DATA_ALLOW

*&---------------------------------------------------------------------*
*&      Form  DATA_CHECK
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM DATA_CHECK USING PV_ERROR.

  DATA: LS_OUTTAB_F01 LIKE GS_OUTTAB_F,
        LT_OUTTAB_F01 LIKE TABLE OF LS_OUTTAB_F01.

  DATA: LS_OUTTAB_F02 LIKE GS_OUTTAB_F,
        LT_OUTTAB_F02 LIKE TABLE OF LS_OUTTAB_F02.

  LOOP AT GT_OUTTAB_F INTO GS_OUTTAB_F WHERE CHECK EQ 'X'.
    CASE GS_OUTTAB_F-GUBUN.
      WHEN '신규'.
        MOVE-CORRESPONDING GS_OUTTAB_F TO LS_OUTTAB_F01.
        APPEND LS_OUTTAB_F01 TO LT_OUTTAB_F01.
      WHEN '청산'.
        MOVE-CORRESPONDING GS_OUTTAB_F TO LS_OUTTAB_F02.
        APPEND LS_OUTTAB_F02 TO LT_OUTTAB_F02.
    ENDCASE.
  ENDLOOP.

  IF LT_OUTTAB_F01 IS INITIAL AND LT_OUTTAB_F02 IS INITIAL.
    MESSAGE S003 DISPLAY LIKE 'E'
       WITH '승인하실 데이터를 선택하십시오.'.
    PV_ERROR = 'X'.
    EXIT.
  ENDIF.

* ### 로그인ID => 사번 가져오기
  DATA : LV_NFNUM TYPE ZNFNUM.
  CLEAR: LV_NFNUM.

* 개인아이디인 경우 인터널테이블에서 읽어오기
  IF GV_PERNR IS INITIAL AND LINES( GT_PERNR ) EQ 1.
    READ TABLE GT_PERNR INDEX 1.
    IF SY-SUBRC EQ 0.
      GV_PERNR = GT_PERNR-PERNR.
    ENDIF.
  ENDIF.

* ==========================================================
*   신규&청산 - 승인권한 점검
*   초기 체크대상의 데이터 자체가 승인권한을 받아서 나온 데이터
* ==========================================================
  DATA: LV_CNT TYPE I.
  CLEAR LV_CNT.

  IF GT_PERNR[] IS NOT INITIAL.
    SELECT COUNT(*) INTO LV_CNT
      FROM ZNFT1090 AS Z2
           FOR ALL ENTRIES IN GT_PERNR
     WHERE Z2~PERNR EQ GT_PERNR-PERNR
       AND Z2~BUKRS EQ P_BUKRS
       AND Z2~CONGB IN ('3', '4')
       AND Z2~CONSQ EQ '1'
       AND Z2~LVORM NE 'X'.

    IF SY-SUBRC NE 0.
      MESSAGE S003 DISPLAY LIKE 'E'
         WITH '승인권한이 없습니다.'.
      PV_ERROR = 'X'.
      EXIT.
    ENDIF.
  ELSE.
    MESSAGE S003 DISPLAY LIKE 'E'
       WITH GV_UNAME '에 대한 사번정보가 존재하지 않습니다.'.
    EXIT.
  ENDIF.

ENDFORM.                    " DATA_CHECK

*&---------------------------------------------------------------------*
*&      Form  DATA_ALLOW_F
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM DATA_ALLOW_F .

  DATA: LS_ZNFT1020 TYPE ZNFT1020,
        LT_ZNFT1020 LIKE TABLE OF LS_ZNFT1020.

  DATA: LS_ZNFT1030 TYPE ZNFT1030,
        LT_ZNFT1030 LIKE TABLE OF LS_ZNFT1030.

  CLEAR LS_ZNFT1020.  REFRESH LT_ZNFT1020.
  CLEAR GS_ZNFT1020.  REFRESH GT_ZNFT1020.

  CLEAR LS_ZNFT1030.  REFRESH LT_ZNFT1030.
  CLEAR GS_ZNFT1030.  REFRESH GT_ZNFT1030.
  CLEAR GS_OUTTAB_F.

* 개인아이디인 경우 인터널테이블에서 읽어오기
  IF GV_PERNR IS INITIAL AND LINES( GT_PERNR ) EQ 1.
    READ TABLE GT_PERNR INDEX 1.
    IF SY-SUBRC EQ 0.
      GV_PERNR = GT_PERNR-PERNR.
    ENDIF.
  ENDIF.

  LOOP AT GT_OUTTAB_F INTO GS_OUTTAB_F WHERE CHECK EQ 'X'.
    CASE GS_OUTTAB_F-GUBUN.
      WHEN '신규'.
        SELECT SINGLE * INTO CORRESPONDING FIELDS OF LS_ZNFT1020
          FROM ZNFT1020
         WHERE NFUTN EQ GS_OUTTAB_F-NFUTN.
        IF SY-SUBRC EQ 0.
          APPEND LS_ZNFT1020 TO GT_ZNFT1020.

          LS_ZNFT1020-CONFM = '7'.
          LS_ZNFT1020-CONAM = SY-UNAME. " 결재자 정보
          LS_ZNFT1020-CODAT = SY-DATLO. " 결재자 정보
          LS_ZNFT1020-COZET = SY-TIMLO. " 결재자 정보
          LS_ZNFT1020-AENAM = SY-UNAME.
          LS_ZNFT1020-AEDAT = SY-DATLO.
          LS_ZNFT1020-AEZET = SY-TIMLO.
          APPEND LS_ZNFT1020 TO LT_ZNFT1020.
        ENDIF.
      WHEN '청산'.
        SELECT SINGLE * INTO CORRESPONDING FIELDS OF LS_ZNFT1030
          FROM ZNFT1030
         WHERE CFUTN EQ GS_OUTTAB_F-NFUTN.
        IF SY-SUBRC EQ 0.
          APPEND LS_ZNFT1020 TO GT_ZNFT1020.

          LS_ZNFT1030-CONFM = '7'.
          LS_ZNFT1030-CONAM = SY-UNAME. " 결재자 정보
          LS_ZNFT1030-CODAT = SY-DATLO. " 결재자 정보
          LS_ZNFT1030-COZET = SY-TIMLO. " 결재자 정보
          LS_ZNFT1030-AENAM = SY-UNAME.
          LS_ZNFT1030-AEDAT = SY-DATLO.
          LS_ZNFT1030-AEZET = SY-TIMLO.
          APPEND LS_ZNFT1030 TO LT_ZNFT1030.
        ENDIF.
    ENDCASE.
  ENDLOOP.

  DATA: LV_CNT1020  TYPE I,
        LV_CNT1030  TYPE I,
        LV_DBCNT    TYPE I,
        LV_SAVE_CHK TYPE CHAR01.

  CLEAR: LV_CNT1020, LV_CNT1030, LV_DBCNT,
         LV_SAVE_CHK.

  IF LT_ZNFT1020 IS NOT INITIAL.
    LV_CNT1020 = LINES( LT_ZNFT1020 ).
    ADD LV_CNT1020 TO LV_DBCNT.
    MODIFY ZNFT1020 FROM TABLE LT_ZNFT1020.
    IF SY-SUBRC EQ 0.
      PERFORM SAVE_CHANGE_DOC_ZNFT1020.
    ELSE.
      LV_SAVE_CHK = 'X'.
    ENDIF.
  ENDIF.

  IF LT_ZNFT1030 IS NOT INITIAL.
    LV_CNT1030 = LINES( LT_ZNFT1030 ).
    ADD LV_CNT1030 TO LV_DBCNT.
    MODIFY ZNFT1030 FROM TABLE LT_ZNFT1030.
    IF SY-SUBRC EQ 0.
      PERFORM SAVE_CHANGE_DOC_ZNFT1030.
    ELSE.
      LV_SAVE_CHK = 'X'.
    ENDIF.
  ENDIF.

  IF LV_SAVE_CHK = 'X'.
    ROLLBACK WORK.
    MESSAGE S003 DISPLAY LIKE 'E'
       WITH '승인시 저장오류입니다.'.
  ELSE.
    COMMIT WORK.

*--- 간편결재 전송.
    IF LT_ZNFT1020 IS NOT INITIAL.
      CLEAR : LS_ZNFT1020.
      LOOP AT LT_ZNFT1020 INTO LS_ZNFT1020.
        PERFORM SEND_SIMPLE_APPROVAL
        USING LS_ZNFT1020-NFUTN
                  P_BUKRS
                  '2F'.
      ENDLOOP.
    ENDIF.
*--- 간편결재 전송.
    IF LT_ZNFT1020 IS NOT INITIAL.
      CLEAR : LS_ZNFT1030.
      LOOP AT LT_ZNFT1030 INTO LS_ZNFT1030.
        PERFORM SEND_SIMPLE_APPROVAL
        USING LS_ZNFT1030-CFUTN
                  P_BUKRS
                  '2F'.
      ENDLOOP.
    ENDIF.

    MESSAGE S003 DISPLAY LIKE 'S'
       WITH LV_DBCNT '건이 승인 완료되었습니다.'.

  ENDIF.

ENDFORM.                    " DATA_ALLOW_F

*&---------------------------------------------------------------------*
*&      Form  DATA_REJECT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM DATA_REJECT .

* 반려관련 데이터 체크
  CLEAR GV_ERROR.
  PERFORM DATA_CHECK USING GV_ERROR.
  CHECK GV_ERROR NE 'X'.

* 진행상황 체크
  CLEAR GV_ANSWER.
  PERFORM POPUP_TO_CONFIRM
    USING '반려'
          '해당 데이터를 반려하시겠습니까?'
          '1'
          GV_ANSWER.
  CHECK GV_ANSWER EQ '1'.

* 공용아이디 체크로직
  SELECT SINGLE * FROM PA0105
   WHERE USRTY EQ '9001'
     AND USRID EQ GV_UNAME
     AND ENDDA GE SY-DATLO
     AND BEGDA LE SY-DATLO.

  IF SY-SUBRC EQ 0.
    CALL SCREEN 1210 STARTING AT 10 03
                     ENDING   AT 55 06.
    CHECK GV_ERROR NE 'X'.
  ENDIF.

  PERFORM DATA_REJECT_F.

ENDFORM.                    " DATA_REJECT

*&---------------------------------------------------------------------*
*&      Form  DATA_REJECT_F
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM DATA_REJECT_F .


  DATA: LS_ZNFT1020 TYPE ZNFT1020,
        LT_ZNFT1020 LIKE TABLE OF LS_ZNFT1020.

  DATA: LS_ZNFT1030 TYPE ZNFT1030,
        LT_ZNFT1030 LIKE TABLE OF LS_ZNFT1030.

  CLEAR LS_ZNFT1020.  REFRESH LT_ZNFT1020.
  CLEAR GS_ZNFT1020.  REFRESH GT_ZNFT1020.

  CLEAR LS_ZNFT1030.  REFRESH LT_ZNFT1030.
  CLEAR GS_ZNFT1030.  REFRESH GT_ZNFT1030.
  CLEAR GS_OUTTAB_F.

* 개인아이디인 경우 인터널테이블에서 읽어오기
  IF GV_PERNR IS INITIAL AND LINES( GT_PERNR ) EQ 1.
    READ TABLE GT_PERNR INDEX 1.
    IF SY-SUBRC EQ 0.
      GV_PERNR = GT_PERNR-PERNR.
    ENDIF.
  ENDIF.

  LOOP AT GT_OUTTAB_F INTO GS_OUTTAB_F WHERE CHECK EQ 'X'.
    CASE GS_OUTTAB_F-GUBUN.
      WHEN '신규'.
        SELECT SINGLE * INTO CORRESPONDING FIELDS OF LS_ZNFT1020
          FROM ZNFT1020
         WHERE NFUTN EQ GS_OUTTAB_F-NFUTN.
        IF SY-SUBRC EQ 0.
          APPEND LS_ZNFT1020 TO GT_ZNFT1020.

          LS_ZNFT1020-CONFM = '8'.
          LS_ZNFT1020-CONAM = SY-UNAME. " 결재자 정보
          LS_ZNFT1020-CODAT = SY-DATLO. " 결재자 정보
          LS_ZNFT1020-COZET = SY-TIMLO. " 결재자 정보
          LS_ZNFT1020-AENAM = SY-UNAME.
          LS_ZNFT1020-AEDAT = SY-DATLO.
          LS_ZNFT1020-AEZET = SY-TIMLO.
          APPEND LS_ZNFT1020 TO LT_ZNFT1020.
        ENDIF.
      WHEN '청산'.
        SELECT SINGLE * INTO CORRESPONDING FIELDS OF LS_ZNFT1030
          FROM ZNFT1030
         WHERE CFUTN EQ GS_OUTTAB_F-NFUTN.
        IF SY-SUBRC EQ 0.
          APPEND LS_ZNFT1020 TO GT_ZNFT1020.

          LS_ZNFT1030-CONFM = '8'.
          LS_ZNFT1030-CONAM = SY-UNAME. " 결재자 정보
          LS_ZNFT1030-CODAT = SY-DATLO. " 결재자 정보
          LS_ZNFT1030-COZET = SY-TIMLO. " 결재자 정보
          LS_ZNFT1030-AENAM = SY-UNAME.
          LS_ZNFT1030-AEDAT = SY-DATLO.
          LS_ZNFT1030-AEZET = SY-TIMLO.
          APPEND LS_ZNFT1030 TO LT_ZNFT1030.
        ENDIF.
    ENDCASE.
  ENDLOOP.

  DATA: LV_CNT1020  TYPE I,
        LV_CNT1030  TYPE I,
        LV_DBCNT    TYPE I,
        LV_SAVE_CHK TYPE CHAR01.

  CLEAR: LV_CNT1020, LV_CNT1030, LV_DBCNT,
         LV_SAVE_CHK.

  IF LT_ZNFT1020 IS NOT INITIAL.
    LV_CNT1020 = LINES( LT_ZNFT1020 ).
    ADD LV_CNT1020 TO LV_DBCNT.
    MODIFY ZNFT1020 FROM TABLE LT_ZNFT1020.
    IF SY-SUBRC EQ 0.
      PERFORM SAVE_CHANGE_DOC_ZNFT1020.
    ELSE.
      LV_SAVE_CHK = 'X'.
    ENDIF.
  ENDIF.

  IF LT_ZNFT1030 IS NOT INITIAL.
    LV_CNT1030 = LINES( LT_ZNFT1030 ).
    ADD LV_CNT1030 TO LV_DBCNT.
    MODIFY ZNFT1030 FROM TABLE LT_ZNFT1030.
    IF SY-SUBRC EQ 0.
      PERFORM SAVE_CHANGE_DOC_ZNFT1030.
    ELSE.
      LV_SAVE_CHK = 'X'.
    ENDIF.
  ENDIF.

  IF LV_SAVE_CHK NE 'X'.
    COMMIT WORK.
    MESSAGE S003 DISPLAY LIKE 'S'
       WITH LV_DBCNT '건이 반려되었습니다.'.

*--- 간편결재 전송.
    LOOP AT LT_ZNFT1020 INTO LS_ZNFT1020.
      PERFORM SEND_SIMPLE_APPROVAL
      USING LS_ZNFT1020-NFUTN
                P_BUKRS
                '2F'.
    ENDLOOP.



  ELSE.
    ROLLBACK WORK.
    MESSAGE S003 DISPLAY LIKE 'E'
       WITH '반려시 저장오류입니다.'.
  ENDIF.

ENDFORM.                    " DATA_REJECT_F

*&---------------------------------------------------------------------*
*&      Form  SAVE_CHANGE_DOC_ZNFT1020
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SAVE_CHANGE_DOC_ZNFT1020 .

  DATA: LV_OBJECTID        TYPE CDHDR-OBJECTID,
        LV_TCODE           TYPE CDHDR-TCODE,
        LV_CDOC_UPD_OBJECT TYPE CDHDR-CHANGE_IND.

  DATA: LS_ZNFT1020N TYPE ZNFT1020,
        LS_ZNFT1020Y TYPE ZNFT1020.

  LV_CDOC_UPD_OBJECT = 'U'.
  LV_TCODE    = SY-TCODE.

  CLEAR GS_ZNFT1020.
  LOOP AT GT_ZNFT1020 INTO GS_ZNFT1020.

*   변경전 데이터
    MOVE-CORRESPONDING GS_ZNFT1020 TO LS_ZNFT1020Y.

*   변경후 데이터
    SELECT SINGLE * INTO CORRESPONDING FIELDS OF LS_ZNFT1020N
      FROM ZNFT1020
     WHERE NFUTN EQ GS_ZNFT1020-NFUTN.

    LV_OBJECTID = GS_ZNFT1020-NFUTN.

    CALL FUNCTION 'ZNFT1020CHDOC_WRITE_DOCUMENT'
      EXPORTING
        OBJECTID     = LV_OBJECTID
        TCODE        = LV_TCODE
        UTIME        = SY-TIMLO
        UDATE        = SY-DATLO
        USERNAME     = SY-UNAME
        N_ZNFT1020   = LS_ZNFT1020N        " 변경후 데이터
        O_ZNFT1020   = LS_ZNFT1020Y        " 변경전 데이터
        UPD_ZNFT1020 = LV_CDOC_UPD_OBJECT.

  ENDLOOP.

ENDFORM.                    " SAVE_CHANGE_DOC_ZNFT1020

*&---------------------------------------------------------------------*
*&      Form  SAVE_CHANGE_DOC_ZNFT1030
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SAVE_CHANGE_DOC_ZNFT1030 .

  DATA: LV_OBJECTID        TYPE CDHDR-OBJECTID,
        LV_TCODE           TYPE CDHDR-TCODE,
        LV_CDOC_UPD_OBJECT TYPE CDHDR-CHANGE_IND.

  DATA: LS_ZNFT1030N TYPE ZNFT1030,
        LS_ZNFT1030Y TYPE ZNFT1030.

  LV_CDOC_UPD_OBJECT = 'U'.
  LV_TCODE    = SY-TCODE.

  CLEAR GS_ZNFT1030.
  LOOP AT GT_ZNFT1030 INTO GS_ZNFT1030.

*   변경전 데이터
    MOVE-CORRESPONDING GS_ZNFT1030 TO LS_ZNFT1030Y.

*   변경후 데이터
    SELECT SINGLE * INTO CORRESPONDING FIELDS OF LS_ZNFT1030N
      FROM ZNFT1030
     WHERE NFUTN EQ GS_ZNFT1030-NFUTN.

    LV_OBJECTID = GS_ZNFT1030-CFUTN.

    CALL FUNCTION 'ZNFT1030CHDOC_WRITE_DOCUMENT'
      EXPORTING
        OBJECTID     = LV_OBJECTID
        TCODE        = LV_TCODE
        UTIME        = SY-TIMLO
        UDATE        = SY-DATLO
        USERNAME     = SY-UNAME
        N_ZNFT1030   = LS_ZNFT1030N
        O_ZNFT1030   = LS_ZNFT1030Y
        UPD_ZNFT1030 = LV_CDOC_UPD_OBJECT.

  ENDLOOP.

ENDFORM.                    " SAVE_CHANGE_DOC_ZNFT1030

*&---------------------------------------------------------------------*
*&      Form  FILL_COLOR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_LT_COLOR  text
*----------------------------------------------------------------------*
FORM FILL_COLOR  CHANGING PT_COLOR TYPE LVC_T_SCOL.

  DATA: LS_CELLTAB TYPE LVC_S_STYL,
        LS_COLOR   TYPE LVC_S_SCOL,
        L_MODE     TYPE RAW4.

  DATA: LS_FIELDCAT TYPE LVC_S_FCAT.

  LOOP AT GT_FIELDCAT INTO LS_FIELDCAT.
    LS_COLOR-FNAME = LS_FIELDCAT-FIELDNAME.

    CLEAR GV_CHANGE_YN.
    CASE LS_COLOR-FNAME.
      WHEN 'YNCAN' OR 'RUDAT' OR 'FCM' OR 'ENDAT' OR 'MITYP' OR
            'MISPD' OR 'MIMON' OR 'PRICE' OR 'EMENG' OR 'MISUS'.
        IF GS_OUTTAB_F-GUBUN EQ '신규'.
          PERFORM FIELD_CHANG_DATA_CHECK USING 'ZNF2R2240'
                                               'ZNFT1020CHDOC'
                                               'ZNFT1020'
                                               GS_OUTTAB_F-NFUTN
                                               LS_COLOR-FNAME
                                               GV_CHANGE_YN.
          IF GV_CHANGE_YN EQ 'Y'.
            LS_COLOR-COLOR-COL = 6.
*            LS_COLOR-COLOR-INT = 1.
            LS_COLOR-COLOR-INV = 1.
            INSERT LS_COLOR INTO TABLE PT_COLOR.
          ENDIF.
        ELSE.
          PERFORM FIELD_CHANG_DATA_CHECK USING 'ZNF2R2240'
                                               'ZNFT1030CHDOC'
                                               'ZNFT1030'
                                               GS_OUTTAB_F-NFUTN
                                               LS_COLOR-FNAME
                                               GV_CHANGE_YN.
          IF GV_CHANGE_YN EQ 'Y'.
            LS_COLOR-COLOR-COL = 6.
*            LS_COLOR-COLOR-INT = 1.
            LS_COLOR-COLOR-INV = 1.
            INSERT LS_COLOR INTO TABLE PT_COLOR.
          ENDIF.
        ENDIF.
    ENDCASE.

  ENDLOOP.

ENDFORM.                    " FILL_COLOR

*&---------------------------------------------------------------------*
*&      Form  FIELD_CHANG_DATA_CHECK
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_0423   text
*      -->P_GS_OUTTAB_F_NFUTN  text
*      -->P_0425   text
*      -->P_0426   text
*      -->P_GV_CHANGE_YN  text
*----------------------------------------------------------------------*
FORM FIELD_CHANG_DATA_CHECK  USING    PV_TCODE
                                      PV_OBEJCT_CLASS
                                      PV_OBEJCT_ID
                                      PV_TABLE_NAME
                                      PV_FIELD
                                      PV_CHANGE_YN.

  CLEAR  PV_CHANGE_YN.
  CLEAR: CDHDR, CDPOS.
  SELECT SINGLE * FROM CDHDR
   WHERE OBJECTCLAS EQ PV_OBEJCT_CLASS
     AND OBJECTID   EQ PV_OBEJCT_ID
     AND TCODE      EQ PV_TCODE.
  IF SY-SUBRC EQ 0.
    SELECT SINGLE * FROM CDPOS
     WHERE OBJECTCLAS EQ PV_OBEJCT_CLASS
       AND OBJECTID   EQ PV_OBEJCT_ID
       AND TABNAME    EQ PV_TABLE_NAME
       AND FNAME      EQ PV_FIELD.
    IF SY-SUBRC EQ 0.
      PV_CHANGE_YN = 'Y'.
    ELSE.
      PV_CHANGE_YN = 'N'.
    ENDIF.
  ELSE.
    PV_CHANGE_YN = 'N'.
  ENDIF.

ENDFORM.                    " FIELD_CHANG_DATA_CHECK

*&---------------------------------------------------------------------*
*&      Form  DATA_RELOAD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM DATA_RELOAD.

  CLEAR  : GS_NFNUM,   GS_OUTTAB_F.
  REFRESH: GT_NFNUM_F, GT_OUTTAB_F.

  PERFORM GET_REQ_LIST.
  CHECK GV_ERROR IS INITIAL.
  PERFORM DATA_SELECT.

*  GS_STBL-ROW = 'X'.
*  GS_STBL-COL = 'X'.
*
*  CALL METHOD GRF_GRID->REFRESH_TABLE_DISPLAY
*    EXPORTING
*      I_SOFT_REFRESH = ' '
*      IS_STABLE      = GS_STBL.     "화면 라인 Refresh

ENDFORM.                    " DATA_RELOAD

*&---------------------------------------------------------------------*
*&      Form  FILL_CELLTAB_C
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM FILL_CELLTAB_C  CHANGING PT_CELLTAB TYPE LVC_T_STYL.

  DATA : LS_CELLTAB TYPE LVC_S_STYL,
         L_MODE     TYPE RAW4.

  DATA : L_FIELDCAT TYPE LVC_S_FCAT.

  LOOP AT GT_FIELDCAT INTO L_FIELDCAT.
    LS_CELLTAB-FIELDNAME = L_FIELDCAT-FIELDNAME.

*  필드 활성화 여부
    IF L_FIELDCAT-EDIT = 'X'.
      IF LS_CELLTAB-FIELDNAME = 'CHECK'.
        IF GS_OUTTAB_F-CHECK = '-'.
          LS_CELLTAB-STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED.
        ELSE.
          LS_CELLTAB-STYLE = CL_GUI_ALV_GRID=>MC_STYLE_ENABLED.
        ENDIF.
      ELSE.
        LS_CELLTAB-STYLE = CL_GUI_ALV_GRID=>MC_STYLE_ENABLED.
      ENDIF.
    ELSE.
      LS_CELLTAB-STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED.
    ENDIF.
    INSERT LS_CELLTAB INTO TABLE PT_CELLTAB.
  ENDLOOP.

ENDFORM.                    " FILL_CELLTAB_C

*&---------------------------------------------------------------------*
*&      Form  SELECT_ALL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SELECT_ALL .

  LOOP AT GT_OUTTAB_F INTO GS_OUTTAB_F WHERE CHECK NE '-'.
    IF OK_SAVE = 'ASEL'.
      GS_OUTTAB_F-CHECK = 'X'.
    ELSE.
      CLEAR : GS_OUTTAB_F-CHECK.
    ENDIF.
    MODIFY GT_OUTTAB_F FROM GS_OUTTAB_F TRANSPORTING CHECK.
  ENDLOOP.

ENDFORM.                    " SELECT_ALL
*&---------------------------------------------------------------------*
*&      Form  DISPLAY_CHANGED_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM DISPLAY_CHANGED_DATA .
  DATA: LT_RSPAR    LIKE RSPARAMS OCCURS 0 WITH HEADER LINE.

  DATA: LV_OBJCLS LIKE CDHDR-OBJECTCLAS,
        LV_DATUM  LIKE SY-DATUM,
        LV_UZEIT  LIKE SY-UZEIT,
        LV_FLAG.

  PERFORM CHECK_SELECTED_ROWS USING LV_FLAG.

  CHECK LV_FLAG IS INITIAL.

  IF GS_OUTTAB_F-GUBUN = '신규'.
    LV_OBJCLS = 'ZNFT1020CHDOC'.
  ELSE.
    LV_OBJCLS = 'ZNFT1030CHDOC'.
  ENDIF.

  PERFORM GET_DISPLAY_START_DATETIME USING LV_OBJCLS
                                           LV_DATUM
                                           LV_UZEIT
                                           LV_FLAG.

  CHECK LV_FLAG IS INITIAL.

  CLEAR   : LT_RSPAR.
  REFRESH : LT_RSPAR.

  LT_RSPAR-SELNAME = 'OBJEKT'.
  LT_RSPAR-KIND    = 'P'.
  LT_RSPAR-LOW     = LV_OBJCLS.
  APPEND LT_RSPAR.

  LT_RSPAR-SELNAME = 'OBJEKTID'.
  LT_RSPAR-KIND    = 'P'.
  LT_RSPAR-LOW     = GS_OUTTAB_F-NFUTN.
  APPEND LT_RSPAR.

  LT_RSPAR-SELNAME = 'DATUM'.
  LT_RSPAR-KIND    = 'P'.
  LT_RSPAR-LOW     = LV_DATUM.
  APPEND LT_RSPAR.

  LT_RSPAR-SELNAME = 'ZEIT'.
  LT_RSPAR-KIND    = 'P'.
  LT_RSPAR-LOW     = LV_UZEIT.
  APPEND LT_RSPAR.

  SUBMIT RSSCD100 WITH SELECTION-TABLE LT_RSPAR
                   AND RETURN.

ENDFORM.                    " DISPLAY_CHANGED_DATA
*&---------------------------------------------------------------------*
*&      Form  CHECK_SELECTED_ROWS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM CHECK_SELECTED_ROWS  USING    PV_ERROR.
  DATA: LV_CNT   TYPE I.

  CLEAR : LV_CNT, PV_ERROR.

  LOOP AT GT_OUTTAB_F INTO GS_OUTTAB_F WHERE CHECK EQ 'X'.
    LV_CNT = LV_CNT + 1.
  ENDLOOP.

  IF LV_CNT > 1.
    PV_ERROR = 'X'.
    MESSAGE S003 DISPLAY LIKE 'E'
       WITH '한 라인만 선택하시기 바랍니다.'.
  ELSEIF LV_CNT < 1.
    PV_ERROR = 'X'.
    MESSAGE S003 DISPLAY LIKE 'E'
       WITH '선택된 라인이 없습니다.'.
  ENDIF.

ENDFORM.                    " CHECK_SELECTED_ROWS
*&---------------------------------------------------------------------*
*&      Form  GET_DISPLAY_START_DATETIME
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM GET_DISPLAY_START_DATETIME  USING    PV_OBJCLS
                                          PV_DATUM
                                          PV_UZEIT
                                          PV_ERROR.
  DATA: BEGIN OF LT_DOCNO OCCURS 0,
          CHANGENR LIKE CDHDR-CHANGENR,
        END   OF LT_DOCNO.

  CLEAR   : LT_DOCNO, PV_DATUM, PV_UZEIT, PV_ERROR.
  REFRESH : LT_DOCNO.

*___결재상태가 '3'/'7' 로 변경된 문서
  SELECT CHANGENR
    INTO TABLE LT_DOCNO
    FROM CDPOS
   WHERE OBJECTCLAS =  PV_OBJCLS
     AND OBJECTID   =  GS_OUTTAB_F-NFUTN
     AND FNAME      =  'CONFM'
     AND VALUE_NEW  IN ('3', '7').

*___가장 최근에 변경된 문서
  SORT LT_DOCNO BY CHANGENR DESCENDING.

  READ TABLE LT_DOCNO INDEX 1.
  IF SY-SUBRC = 0.
*___변경일/시간
    SELECT SINGLE UDATE
                  UTIME
      INTO (PV_DATUM, PV_UZEIT)
      FROM CDHDR
     WHERE OBJECTCLAS = PV_OBJCLS
       AND OBJECTID   = GS_OUTTAB_F-NFUTN
       AND CHANGENR   = LT_DOCNO-CHANGENR.

    IF SY-SUBRC = 0.
      IF PV_UZEIT = '235959'.
        PV_DATUM = PV_DATUM + 1.
        PV_UZEIT = '000000'.
      ELSE.
        PV_UZEIT = PV_UZEIT + 1.
      ENDIF.
    ENDIF.
  ENDIF.

  IF PV_DATUM IS INITIAL AND PV_UZEIT IS INITIAL.
    PV_ERROR = 'X'.

    MESSAGE S003 DISPLAY LIKE 'E'
       WITH '변경내역을 찾지 못했습니다.'.
  ENDIF.

ENDFORM.                    " GET_DISPLAY_START_DATETIME

*&---------------------------------------------------------------------*
*&      Form  CALL_NFUTN_PGM
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GS_OUTTAB_D_NFUTN  text
*----------------------------------------------------------------------*
FORM CALL_NFUTN_PGM  USING    PV_NFUTN.

  DATA: LT_RSPAR LIKE RSPARAMS OCCURS 0 WITH HEADER LINE.

  CLEAR   : LT_RSPAR.
  REFRESH : LT_RSPAR.

  APPEND_PARAM : LT_RSPAR 'P_BUKRS' 'P' ' ' ' '  P_BUKRS       ' ',
                 LT_RSPAR 'S_NFUTN' 'S' 'I' 'EQ' PV_NFUTN      ' ',
                 LT_RSPAR 'P_CHK11' 'P' ' ' ' '  'X'           ' ',
                 LT_RSPAR 'P_CHK12' 'P' ' ' ' '  ' '           ' ',
                 LT_RSPAR 'P_R01'   'P' ' ' ' '  ' '           ' ',
                 LT_RSPAR 'P_R02'   'P' ' ' ' '  ' '           ' ',
                 LT_RSPAR 'P_R03'   'P' ' ' ' '  'X'           ' ',
                 LT_RSPAR 'P_R11'   'P' ' ' ' '  ' '           ' ',
                 LT_RSPAR 'P_R12'   'P' ' ' ' '  ' '           ' ',
                 LT_RSPAR 'P_R13'   'P' ' ' ' '  'X'           ' ',
                 LT_RSPAR 'P_R21'   'P' ' ' ' '  ' '           ' ',
                 LT_RSPAR 'P_R22'   'P' ' ' ' '  ' '           ' ',
                 LT_RSPAR 'P_R23'   'P' ' ' ' '  'X'           ' '.

  SUBMIT ZNFR2600 WITH SELECTION-TABLE LT_RSPAR
                   AND RETURN.

ENDFORM.                    " CALL_NFUTN_PGM

*&---------------------------------------------------------------------*
*&      Form  CALL_CFUTN_PGM
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GS_OUTTAB_D_CFUTN  text
*----------------------------------------------------------------------*
FORM CALL_CFUTN_PGM  USING    PV_CFUTN.

  DATA: LT_RSPAR LIKE RSPARAMS OCCURS 0 WITH HEADER LINE.

  CLEAR   : LT_RSPAR.
  REFRESH : LT_RSPAR.

  APPEND_PARAM : LT_RSPAR 'P_BUKRS' 'P' ' ' ' '  P_BUKRS       ' ',
                 LT_RSPAR 'S_CFUTN' 'S' 'I' 'EQ' PV_CFUTN      ' ',
                 LT_RSPAR 'P_CHK11' 'P' ' ' ' '  'X'           ' ',
                 LT_RSPAR 'P_CHK12' 'P' ' ' ' '  ' '           ' ',
                 LT_RSPAR 'P_R01'   'P' ' ' ' '  ' '           ' ',
                 LT_RSPAR 'P_R02'   'P' ' ' ' '  ' '           ' ',
                 LT_RSPAR 'P_R03'   'P' ' ' ' '  'X'           ' ',
                 LT_RSPAR 'P_R11'   'P' ' ' ' '  ' '           ' ',
                 LT_RSPAR 'P_R12'   'P' ' ' ' '  ' '           ' ',
                 LT_RSPAR 'P_R13'   'P' ' ' ' '  'X'           ' ',
                 LT_RSPAR 'P_R21'   'P' ' ' ' '  ' '           ' ',
                 LT_RSPAR 'P_R22'   'P' ' ' ' '  ' '           ' ',
                 LT_RSPAR 'P_R23'   'P' ' ' ' '  'X'           ' '.

  SUBMIT ZNFR2600 WITH SELECTION-TABLE LT_RSPAR
                   AND RETURN.

ENDFORM.                    " CALL_CFUTN_PGM

*&---------------------------------------------------------------------*
*&      Form  PASWD_CHECK
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GV_ERROR  text
*----------------------------------------------------------------------*
FORM PASWD_CHECK  USING    PV_ERROR.

  IF GV_PASSWD IS INITIAL.
    MESSAGE S003 DISPLAY LIKE 'E'
       WITH '비밀번호를 입력하십시오.'.
    PV_ERROR = 'X'.
  ENDIF.

ENDFORM.                    " PASWD_CHECK

*&---------------------------------------------------------------------*
*&      Form  MODIFY_SCREEN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM MODIFY_SCREEN .

  IF NOT ( SY-UNAME EQ 'ZERPMM'  OR SY-UNAME EQ 'ZLSGMM2' OR
           SY-UNAME EQ 'ZLSGMM'  OR SY-UNAME EQ 'ZLSGLSC' OR
           SY-UNAME EQ 'ZLSGLSM' OR SY-UNAME EQ 'ZTEST07').
    LOOP AT SCREEN.
      IF SCREEN-NAME = 'P_UNAME' OR
        SCREEN-NAME  = '%_P_UNAME_%_APP_%-TEXT'.
        SCREEN-INPUT     = 0.
        SCREEN-INVISIBLE = 1.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.
  ENDIF.

ENDFORM.                    " MODIFY_SCREEN
FORM SEND_SIMPLE_APPROVAL  USING    P_EXENO
                                    P_BUKRS
                                    P_TYPE TYPE ZESAZTYPE.


  CALL FUNCTION 'ZSA1_MM_MAKE_SEND_DATA'
    EXPORTING
      I_BUKRS = P_BUKRS
      I_EXENO = P_EXENO
      I_EXTYP = P_TYPE.

ENDFORM.
