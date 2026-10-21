*&---------------------------------------------------------------------*
*&  Include           ZNFR2510F01
************************************************************************
*                        MODIFICATION LOG                              *
*----------------------------------------------------------------------*
* 2012/09/05   MMB04(HDY)     변경근거 : C20120829_73047               *
*----------------------------------------------------------------------*
* Comment : 요청유형 필드 추가
************************************************************************

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

  CLEAR GS_SORT. REFRESH GT_SORT.

  GS_SORT-SPOS = 1.
  GS_SORT-FIELDNAME = 'REQNO'.
  GS_SORT-UP = 'X'.
  GS_SORT-COMP = 'X'.
  GS_SORT-SUBTOT = 'X'.
  APPEND GS_SORT TO GT_SORT.

  GS_SORT-SPOS = 2.
  GS_SORT-FIELDNAME = 'H_NO1'.
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
  'CHECK'       '선택'            '10'     'C'    ' '     ,
  'REQNO'       '선물요청번호'    '10'     'L'    ' '     ,
  'H_NO1'       '항번'            '10'     'C'    ' '     ,
  'CONSQ'       'CONSQ'           '10'     'C'    ' '     ,
  'ERNAM'       '요청자'          '10'     'L'    ' '     ,
**** HDY 20120905 START C20120829_73047
**** 요청유형내역 필드 추가
  'RQTYP'      '요청유형'         '10'     'L'    ' '     ,
  'RQTXT'      '요청유형내역'     '20'     'L'    ' '     ,
**** HDY 20120905 END
  'PERNR'       '사원'            '10'     'L'    ' '     ,
  'SNAME'       '승인권한자'      '10'     'L'    ' '     ,
  'USRID3'      '승인자'          '10'     'L'    ' '     ,
  'USRID2'      '접수자'          '10'     'L'    ' '     ,
  'USRID1'      '확인자'          '10'     'L'    ' '     ,
  'AUDAT'       '승인요청일'      '10'     'C'    ' '     ,
  'NFKEY'       '비철구분'        '10'     'C'    ' '     ,
  'BY_SL'       'Buy-Sell'        '10'     'C'    ' '     ,
  'BY_SL_NM'    'Buy-Sell'        '10'     'C'    ' '     ,
  'ENDMM'       '만기월'          '10'     'C'    'PERI'  ,
  'EMENG'       '요청수량'        '14'     'R'    ' '     ,
  'MEINS'       '단위'            '10'     'C'    ' '     ,
  'CONNO'       '계약번호'        '10'     'C'    ' '     ,
  'COTXT'       '계약명'          '20'     'L'    ' '     ,
  'NFCTR'       '사업부'          '10'     'C'    'ALPHA' ,
  'NFCTR_NM'    '사업부명'        '10'     'L'    ' '     ,
  'PRCTR'       '손익센터'        '10'     'C'    'ALPHA' ,
  'PRCTR_NM'    '손익센터명'      '10'     'L'    ' '     ,
  'VKGRP'       '영업조직'        '10'     'C'    'ALPHA' ,
  'VKGRP_NM'    '영업조직명'      '10'     'L'    ' '     ,
  'KUNNR'       '고  객'          '10'     'C'    'ALPHA' ,
  'NCUST'       '고객명'          '20'     'L'    ' '     ,
  'SALER'       '영업담당자'      '10'     'C'    ' '     ,

  'SUJUD'       '수주일'          '10'     'C'    ' '     ,
  'PRATE'       '영업이익률(%)'   '10'     'R'    ' '     ,
  'ERATE'       '환율'            '10'     'R'    ' '     ,
  'FILE_YN'     '파일첨부여부'    '10'     'C'    ' '     ,

  'EMENG_C'     '수주비철량'      '14'     'R'    ' '     ,
  'MEINS_C'     '단위'            '10'     'C'    ' '     ,
  'PRIND'       '가격구분'        '10'     'C'    ' '     ,
  'SUJUP'       '비철수주가'      '10'     'R'    ' '     ,
* 'PRICE'       '수주금액'        '15'     'R'    ' '     ,
  'WAERS'       '통화'            '5'      'C'    ' '     ,
  'BIGO4'       '비고'            '20'     'L'    ' '     .

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
    WHEN 'BUKRS' OR 'PERNR'.
      GS_FIELDCAT-NO_OUT     = 'X'.
    WHEN 'PRICE'.
      GS_FIELDCAT-CFIELDNAME = 'WEARS'.
    WHEN 'EMENG_C'.
      GS_FIELDCAT-QFIELDNAME = 'MEINS_C'.
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
  DATA : LT_CELLTAB TYPE LVC_T_STYL,
         L_INDEX    TYPE I.

  LOOP AT GT_OUTTAB_A INTO GS_OUTTAB_A.
    L_INDEX = SY-TABIX.
    REFRESH LT_CELLTAB.
    CLEAR GS_OUTTAB_A-CELLTAB.
    PERFORM FILL_CELLTAB_C CHANGING LT_CELLTAB.
    INSERT LINES OF LT_CELLTAB INTO TABLE GS_OUTTAB_A-CELLTAB.
    MODIFY GT_OUTTAB_A FROM GS_OUTTAB_A INDEX L_INDEX.
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

* FieldName별 소트해서 APPEND
*  GS_F4-FIELDNAME = 'NFUTN'.
*  GS_F4-REGISTER  = 'X'.
*  APPEND GS_F4 TO GT_F4.
*
*  CALL METHOD GRF_GRID->REGISTER_F4_FOR_FIELDS
*    EXPORTING
*      IT_F4 = GT_F4.

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
      IT_OUTTAB                     = GT_OUTTAB_A
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

  DATA : LV_CNT TYPE I.

  CLEAR : GV_ERROR.
  CLEAR : GV_PERNR, GV_UNAME.
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
* 'A' = 선물요청승인
* --------------------------------------------------------------------
  DATA  : LT_NFNUM_A LIKE TABLE OF GS_NFNUM.
  CLEAR : GS_NFNUM. REFRESH : GT_NFNUM_A.

* ZNFT1090에 대한 권한유무 체크
  IF GT_PERNR[] IS NOT INITIAL.
    CLEAR: LV_CNT.
    SELECT COUNT(*) INTO LV_CNT
      FROM ZNFT1090
           FOR ALL ENTRIES IN GT_PERNR
     WHERE PERNR EQ GT_PERNR-PERNR
       AND BUKRS EQ P_BUKRS
       AND CONGB EQ '2'
       AND CONSQ IN (1,2,3,4)
       AND LVORM EQ SPACE.

    IF SY-SUBRC EQ 0 AND LV_CNT GE 1.
    ELSE.
      GV_ERROR = 'X'.
      MESSAGE S003 DISPLAY LIKE 'E'
         WITH GV_UNAME '에 대한 요청권한이 없습니다.'.
      EXIT.
    ENDIF.
  ELSE.
    MESSAGE S003 DISPLAY LIKE 'E'
       WITH GV_UNAME '에 대한 사번정보가 존재하지 않습니다.'.
    EXIT.
  ENDIF.

* CONSQ = 1 인경우는 ZNFT1090-PERNR 과 ZNFT1091-PERNR이 명시적으로
* 같은 경우 데이터를 가져온다.
  IF GT_PERNR[] IS NOT INITIAL.
    SELECT Z1~NFNUM INTO CORRESPONDING FIELDS OF TABLE GT_NFNUM_A
      FROM ZNFT1091 AS Z1
           INNER JOIN ZNFT1090 AS Z2
              ON Z2~BUKRS EQ Z1~BUKRS AND Z2~CONGB EQ Z1~CONGB
             AND Z2~CONSQ EQ Z1~CONSQ AND Z2~PERNR EQ Z1~PERNR
           FOR ALL ENTRIES IN GT_PERNR
     WHERE Z1~BUKRS EQ P_BUKRS
       AND Z1~CONGB EQ '2'
       AND Z1~CONST EQ 'B'
       AND Z1~CONSQ EQ 1
       AND Z1~PERNR EQ GT_PERNR-PERNR
       AND Z2~LVORM NE 'X'.

    REFRESH LT_NFNUM_A.

    SELECT Z1~NFNUM INTO  CORRESPONDING FIELDS OF TABLE LT_NFNUM_A
      FROM ZNFT1091 AS Z1
           INNER JOIN ZNFT1090 AS Z2
              ON Z2~BUKRS EQ Z1~BUKRS AND Z2~CONGB EQ Z1~CONGB
             AND Z2~CONSQ EQ Z1~CONSQ
           FOR ALL ENTRIES IN GT_PERNR
     WHERE Z1~BUKRS EQ P_BUKRS
       AND Z1~CONGB EQ '2'
       AND Z1~CONST EQ 'B'
       AND Z1~CONSQ IN (2,3,4)
       AND Z2~PERNR EQ GT_PERNR-PERNR
       AND Z2~LVORM NE 'X'.

    IF LT_NFNUM_A IS NOT INITIAL.
      APPEND LINES OF LT_NFNUM_A TO GT_NFNUM_A.
    ENDIF.
  ELSE.
    MESSAGE S003 DISPLAY LIKE 'E'
       WITH GV_UNAME '에 대한 사번정보가 존재하지 않습니다.'.
    EXIT.
  ENDIF.

  IF GT_NFNUM_A IS NOT INITIAL.
    SORT GT_NFNUM_A BY NFNUM.
    CLEAR GV_H_CNT.
    SELECT COUNT(*) INTO GV_H_CNT
      FROM ZNFT1010
           FOR ALL ENTRIES IN GT_NFNUM_A
     WHERE BUKRS EQ P_BUKRS
       AND REQNO EQ GT_NFNUM_A-NFNUM.
  ELSE.
    IF OK_SAVE EQ 'ALLOW' OR OK_SAVE EQ 'REJECT' OR
       OK_SAVE EQ 'CONF'  OR OK_SAVE EQ 'CANC'.
      GV_ERROR = 'X'.
    ELSE.
      GV_ERROR = 'X'.
      MESSAGE S003 DISPLAY LIKE 'E'
         WITH GV_UNAME
              '에 대한 승인요청데이터가 존재하지 않습니다.'.
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

  CLEAR GS_OUTTAB_A.
  LOOP AT P_DATA_CHANGED->MT_GOOD_CELLS INTO LS_MOD_CELLS.
    LV_INDEX = LS_MOD_CELLS-ROW_ID.
*   Data 가공용 Structure
    READ TABLE GT_OUTTAB_A INTO GS_OUTTAB_A INDEX LV_INDEX.
    IF SY-SUBRC EQ 0.
      CASE LS_MOD_CELLS-FIELDNAME.
        WHEN 'CHECK'.
          IF LS_MOD_CELLS-VALUE EQ 'X'.
            GS_OUTTAB_A-CHECK = 'X'.
            MODIFY GT_OUTTAB_A FROM GS_OUTTAB_A INDEX LV_INDEX
                               TRANSPORTING CHECK.
          ELSE.
            GS_OUTTAB_A-CHECK = SPACE.
            MODIFY GT_OUTTAB_A FROM GS_OUTTAB_A INDEX LV_INDEX
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

  READ TABLE GT_OUTTAB_A INTO GS_OUTTAB_A INDEX P_ES_ROW_NO-ROW_ID.

  IF SY-SUBRC EQ 0.

    CASE P_E_COLUMN.
      WHEN 'REQNO'.
        IF NOT GS_OUTTAB_A-CONNO IS INITIAL.
          SET PARAMETER ID 'ZNFREQ' FIELD GS_OUTTAB_A-REQNO.
          CALL TRANSACTION 'ZNF2M2103' AND SKIP FIRST SCREEN.
        ELSE.
          MESSAGE '요청번호가 존재하지 않습니다.'
             TYPE 'S' DISPLAY LIKE 'E'.
        ENDIF.
      WHEN 'CONNO'.
        IF NOT GS_OUTTAB_A-CONNO IS INITIAL.
          SET PARAMETER ID 'ZNFCON' FIELD GS_OUTTAB_A-CONNO.
          CALL TRANSACTION 'ZNF2M2003' AND SKIP FIRST SCREEN.
        ELSE.
          MESSAGE '계약번호가 존재하지 않습니다.'
             TYPE 'S' DISPLAY LIKE 'E'.
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

  PERFORM GET_REQNO_A.

ENDFORM.                    " DATA_SELECT
*&---------------------------------------------------------------------*
*&      Form  GET_REQNO_A
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_REQNO_A .

  DATA: LV_FLAG TYPE CHAR01.
  DATA: LV_TABIX TYPE SY-TABIX,
        LV_ERROR TYPE CHAR01.

  SELECT Z2~BUKRS
         Z2~REQNO
         Z1~H_NO1
         Z5~USRID AS USRID1  " 확인자
         Z6~USRID AS USRID2  " 접수자
         Z8~USRID AS USRID3  " 승인자
         Z7~PERNR            " 승인자 사번
*        PA0001-SNAME
         Z7~ERNAM            " 요청자
         Z7~ERDAT AS AUDAT
         Z1~NFKEY
         Z1~BY_SL
         Z1~ENDMM
         Z3~EMENG AS EMENG_C "수주비철량
         Z3~MEINS AS MEINS_C "단위
         Z1~EMENG
         Z1~MEINS
         Z1~CONNO
         Z4~COTXT
         Z4~NFCTR
*        ZNFT0005-NTEXT
         Z4~PRCTR
*        ZNFT0004-PTEXT
         Z4~VKGRP
*        ZNFT0003-VTEXT
         Z4~KUNNR
         Z4~NCUST
         Z4~SALER
         Z4~SUJUD
         Z4~PRATE
         Z4~ERATE
         Z3~WAERS
         Z3~BIGO4
**** HDY 20120905 START C20120829_73047
**** 요청유형 필드 추가
         Z2~RQTYP
**** HDY 20120905 END
         INTO CORRESPONDING FIELDS OF TABLE GT_OUTTAB_A
    FROM ZNFT1011 AS Z1
         INNER JOIN ZNFT1010 AS Z2
           ON Z2~REQNO EQ Z1~REQNO
         INNER JOIN ZNFT1001 AS Z3
           ON Z3~CONNO EQ Z1~CONNO AND Z3~NFKEY EQ Z1~NFKEY
         INNER JOIN ZNFT1000 AS Z4
           ON Z4~CONNO EQ Z3~CONNO
         LEFT OUTER JOIN ZNFT1091 AS Z7
           ON Z7~NFNUM EQ Z1~REQNO AND Z7~CONGB EQ '2' AND   " 요청
              Z7~CONSQ EQ '1' "     AND Z7~CONST EQ 'B'
         LEFT OUTER JOIN ZNFT1091 AS Z8
           ON Z8~NFNUM EQ Z1~REQNO AND Z8~CONGB EQ '2' AND   " 승인
              Z8~CONSQ EQ '1'      AND Z8~CONST EQ 'A'
         LEFT OUTER JOIN ZNFT1091 AS Z6
           ON Z6~NFNUM EQ Z1~REQNO AND Z6~CONGB EQ '2' AND   " 접수
              Z6~CONSQ EQ '2'      AND Z6~CONST EQ 'A'
         LEFT OUTER JOIN ZNFT1091 AS Z5
           ON Z5~NFNUM EQ Z1~REQNO AND Z5~CONGB EQ '2' AND   " 확인
              Z5~CONSQ EQ '3'      AND Z5~CONST EQ 'A'
         FOR ALL ENTRIES IN GT_NFNUM_A
   WHERE Z2~REQNO EQ GT_NFNUM_A-NFNUM.

  IF SY-SUBRC EQ 0 AND GT_OUTTAB_A IS NOT INITIAL.
    SORT GT_OUTTAB_A BY BUKRS REQNO H_NO1.
    CLEAR: LV_TABIX, GS_OUTTAB_A.
    LOOP AT GT_OUTTAB_A INTO GS_OUTTAB_A.
      LV_TABIX = SY-TABIX.

      AT NEW REQNO.
        LV_FLAG = 'X'.
      ENDAT.

      IF LV_FLAG = 'X'.
        CLEAR : LV_FLAG.
      ELSE.
        GS_OUTTAB_A-CHECK = '-'.
      ENDIF.

      SELECT SINGLE CONSQ INTO GS_OUTTAB_A-CONSQ
        FROM ZNFT1091
       WHERE BUKRS EQ P_BUKRS
         AND NFNUM EQ GS_OUTTAB_A-REQNO
         AND CONGB EQ '2'
         AND CONST EQ 'B'.

      PERFORM DOMAIN_VALUE_GET USING 'ZBY_SL'
                                     GS_OUTTAB_A-BY_SL
                                     GS_OUTTAB_A-BY_SL_NM.

**** HDY 20120905 START C20120829_73047
**** 요청유형 필드 추가
*___요청유형 내역
      PERFORM DOMAIN_VALUE_GET USING 'ZRQTYP_1'
                                     GS_OUTTAB_A-RQTYP
                                     GS_OUTTAB_A-RQTXT.
**** HDY 20120905 END

      PERFORM GET_PERNR_DESC USING GS_OUTTAB_A-PERNR
                                   GS_OUTTAB_A-SNAME.
      PERFORM GET_NFCTR_DESC USING GS_OUTTAB_A-BUKRS
                                   GS_OUTTAB_A-NFCTR
                                   GS_OUTTAB_A-NFCTR_NM.
      PERFORM GET_PRCTR_DESC USING GS_OUTTAB_A-BUKRS
                                   GS_OUTTAB_A-PRCTR
                                   GS_OUTTAB_A-PRCTR_NM.
      PERFORM GET_VKGRP_DESC USING GS_OUTTAB_A-BUKRS
                                   GS_OUTTAB_A-VKGRP
                                   GS_OUTTAB_A-VKGRP_NM.

*     계약서 - 파일첨부 여부
      SELECT SINGLE * FROM ZNFT1002 WHERE CONNO EQ GS_OUTTAB_A-CONNO.
      IF SY-SUBRC EQ 0.
        GS_OUTTAB_A-FILE_YN = 'Y'.
      ELSE.
        GS_OUTTAB_A-FILE_YN = 'N'.
      ENDIF.

*   - 가격구분/비철수주가
      PERFORM PRICE_CLASSIFICATION USING GS_OUTTAB_A-CONNO
                                         GS_OUTTAB_A-NFKEY
                                         GS_OUTTAB_A-PRIND
                                         GS_OUTTAB_A-SUJUP
                                         LV_ERROR.
      MODIFY GT_OUTTAB_A FROM GS_OUTTAB_A INDEX LV_TABIX.
      CLEAR: LV_TABIX, GS_OUTTAB_A.
    ENDLOOP.
  ENDIF.

ENDFORM.                    " GET_REQNO_A

*&---------------------------------------------------------------------*
*&      Form  DATA_ALLOW
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM DATA_ALLOW .

* 승인관련 데이터 체크
  CLEAR : GV_CONSQ, GV_ERROR.
  PERFORM DATA_CHECK_A USING GV_ERROR.
  CHECK GV_ERROR NE 'X'.

* 진행상황 체크
  PERFORM POPUP_TO_CONFIRM
    USING '확인'
          '승인처리 하시겠습니까?'
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

  PERFORM DATA_ALLOW_A.

ENDFORM.                    " DATA_ALLOW

*&---------------------------------------------------------------------*
*&      Form  DATA_CHECK_A
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM DATA_CHECK_A USING PV_ERROR.

  DATA: LV_DBCNT TYPE I.
  DATA: LS_OUTTAB_A LIKE GS_OUTTAB_A,
        LT_OUTTAB_A LIKE TABLE OF LS_OUTTAB_A.

* 선택한 동일-사번체크 (공용인 경우 로그인한 사번의 데이터만 처리가능)
* 선택한 ZNFT1091-NFNUM에 대한 권한이 있는 사번을 구한다.
  DATA: BEGIN OF LT_PERNR OCCURS 0,
          PERNR LIKE PA0105-PERNR,
        END   OF LT_PERNR,
        LV_CHECK_CNT TYPE I.

  LOOP AT GT_OUTTAB_A INTO GS_OUTTAB_A WHERE CHECK EQ 'X'.
    MOVE-CORRESPONDING GS_OUTTAB_A TO LS_OUTTAB_A.
    APPEND LS_OUTTAB_A TO LT_OUTTAB_A.
  ENDLOOP.

  IF LT_OUTTAB_A IS INITIAL.
    MESSAGE S003 DISPLAY LIKE 'E'
       WITH '승인하실 데이터를 선택하십시오.'.
    PV_ERROR = 'X'.
    EXIT.
  ENDIF.

* ### 로그인ID => 사번 가져오기
  DATA : LV_NFNUM TYPE ZNFNUM,
         LV_RSTAT TYPE ZRSTAT.

  CLEAR : GV_CONSQ, LV_NFNUM, LV_RSTAT.

  DATA: LV_CONSQ TYPE ZCONSQ,
        LV_CNT   TYPE I.

  LOOP AT LT_OUTTAB_A INTO LS_OUTTAB_A.
*   ==========================================================
*     승인권한 점검
*   ==========================================================
    CLEAR LV_CONSQ.
    SELECT SINGLE CONSQ INTO LV_CONSQ
      FROM ZNFT1091
     WHERE BUKRS EQ P_BUKRS
       AND NFNUM EQ LS_OUTTAB_A-REQNO
       AND CONGB EQ '2'
       AND CONST EQ 'B'.

    IF SY-SUBRC EQ 0.
      GV_CONSQ = LV_CONSQ.
    ELSE.
      MESSAGE S003 DISPLAY LIKE 'E'
         WITH '승인전 데이터가 없습니다.'.
      PV_ERROR = 'X'.
      EXIT.
    ENDIF.

*   GV_CONSQ = 1 인경우는
*   ZNFT1090-PERNR 과 ZNFT1091-PERNR이 명시적으로
*   같은 경우 데이터를 가져온다.
    IF GV_CONSQ EQ 1.
      CLEAR LV_CNT.
      IF GT_PERNR[] IS NOT INITIAL.
        SELECT COUNT(*) INTO LV_CNT
          FROM ZNFT1091 AS Z1
               INNER JOIN ZNFT1090 AS Z2
                  ON Z2~BUKRS EQ Z1~BUKRS AND Z2~CONSQ EQ Z1~CONSQ
                 AND Z2~CONGB EQ Z1~CONGB AND Z2~PERNR EQ Z1~PERNR
               FOR ALL ENTRIES IN GT_PERNR
         WHERE Z1~BUKRS EQ P_BUKRS
           AND Z1~CONST EQ 'B'
           AND Z1~CONGB EQ '2'
           AND Z1~NFNUM EQ LS_OUTTAB_A-REQNO
           AND Z2~PERNR EQ GT_PERNR-PERNR
           AND Z2~LVORM NE 'X'.
      ELSE.
        MESSAGE S003 DISPLAY LIKE 'E'
          WITH GV_UNAME '에 대한 사번정보가 존재하지 않습니다.'.
        EXIT.
      ENDIF.

      IF SY-SUBRC EQ 0.
        IF LV_CNT LT 1.
          MESSAGE S003 DISPLAY LIKE 'E'
             WITH '승인권한이 없습니다.'.
          PV_ERROR = 'X'.
          EXIT.
        ENDIF.
      ELSE.
        MESSAGE S003 DISPLAY LIKE 'E'
           WITH '승인권한이 없습니다.'.
        PV_ERROR = 'X'.
        EXIT.
      ENDIF.
    ELSE.
      CLEAR LV_CNT.
      IF GT_PERNR[] IS NOT INITIAL.
        SELECT COUNT(*) INTO LV_CNT
          FROM ZNFT1091 AS Z1
               INNER JOIN ZNFT1090 AS Z2
                  ON Z2~BUKRS EQ Z1~BUKRS AND Z2~CONSQ EQ Z1~CONSQ
                 AND Z2~CONGB EQ Z1~CONGB
               FOR ALL ENTRIES IN GT_PERNR
         WHERE Z1~BUKRS EQ P_BUKRS
           AND Z1~CONST EQ 'B'
           AND Z1~CONGB EQ '2'
           AND Z1~NFNUM EQ LS_OUTTAB_A-REQNO
           AND Z2~PERNR EQ GT_PERNR-PERNR
           AND Z2~LVORM NE 'X'.
      ELSE.
        MESSAGE S003 DISPLAY LIKE 'E'
          WITH GV_UNAME '에 대한 사번정보가 존재하지 않습니다.'.
        EXIT.
      ENDIF.

      IF SY-SUBRC EQ 0.
        IF LV_CNT LT 1.
          MESSAGE S003 DISPLAY LIKE 'E'
             WITH '승인권한이 없습니다.'.
          PV_ERROR = 'X'.
          EXIT.
        ENDIF.
      ELSE.
        MESSAGE S003 DISPLAY LIKE 'E'
           WITH '승인권한이 없습니다.'.
        PV_ERROR = 'X'.
        EXIT.
      ENDIF.
    ENDIF.

*   결재순번
    CASE GV_CONSQ.
      WHEN 1.
        SELECT SINGLE RSTAT INTO LV_RSTAT FROM ZNFT1010
         WHERE REQNO = LS_OUTTAB_A-REQNO.
        IF SY-SUBRC EQ 0.
          IF LV_RSTAT EQ '2'.
          ELSE.
            MESSAGE S003 DISPLAY LIKE 'E'
               WITH LS_OUTTAB_A-REQNO
                    '결재대상이 아닙니다. 결재상태를 확인하세요'.
            PV_ERROR = 'X'.
            EXIT.
          ENDIF.
        ELSE.
        ENDIF.
      WHEN 2.
        SELECT SINGLE RSTAT INTO LV_RSTAT FROM ZNFT1010
         WHERE REQNO = LS_OUTTAB_A-REQNO.
        IF SY-SUBRC EQ 0.
          IF LV_RSTAT EQ '3'.
          ELSE.
            MESSAGE S003 DISPLAY LIKE 'E'
               WITH LS_OUTTAB_A-REQNO
                    '-결재대상이 아닙니다. 결재상태를 확인하세요'.
            PV_ERROR = 'X'.
            EXIT.
          ENDIF.
        ELSE.
        ENDIF.
      WHEN 3.
        SELECT SINGLE RSTAT INTO LV_RSTAT FROM ZNFT1010
         WHERE REQNO = LS_OUTTAB_A-REQNO.
        IF SY-SUBRC EQ 0.
          IF LV_RSTAT EQ '4'.
          ELSE.
            MESSAGE S003 DISPLAY LIKE 'E'
               WITH LS_OUTTAB_A-REQNO
                    '-결재대상이 아닙니다. 결재상태를 확인하세요'.
            PV_ERROR = 'X'.
            EXIT.
          ENDIF.
        ELSE.
        ENDIF.
      WHEN 4.
        SELECT SINGLE RSTAT INTO LV_RSTAT FROM ZNFT1010
         WHERE REQNO = LS_OUTTAB_A-REQNO.
        IF SY-SUBRC EQ 0.
          IF LV_RSTAT EQ '5'.
          ELSE.
            MESSAGE S003 DISPLAY LIKE 'E'
               WITH LS_OUTTAB_A-REQNO
                    '-결재대상이 아닙니다. 결재상태를 확인하세요'.
            PV_ERROR = 'X'.
            EXIT.
          ENDIF.
        ELSE.
        ENDIF.
    ENDCASE.

  ENDLOOP.

ENDFORM.                    " DATA_CHECK_A

*&---------------------------------------------------------------------*
*&      Form  DATA_ALLOW_A
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM DATA_ALLOW_A .

  DATA: LS_ZNFT1010 TYPE ZNFT1010,
        LT_ZNFT1010 LIKE TABLE OF LS_ZNFT1010.

  DATA: LS_ZNFT1091Y TYPE ZNFT1091.

  DATA: LS_ZNFT1091  TYPE ZNFT1091,
        LT_ZNFT1091  LIKE TABLE OF LS_ZNFT1091,
        LS_ZNFT1091N TYPE ZNFT1091,
        LT_ZNFT1091N LIKE TABLE OF LS_ZNFT1091,
        LS_ZNFT1091D TYPE ZNFT1091,
        LT_ZNFT1091D LIKE TABLE OF LS_ZNFT1091.

  DATA: LV_RSTAT TYPE ZRSTAT.

  CLEAR GS_OUTTAB_A.
  CLEAR LS_ZNFT1010.  REFRESH LT_ZNFT1010.
  CLEAR LS_ZNFT1091.  REFRESH LT_ZNFT1091.
  CLEAR LS_ZNFT1091N. REFRESH LT_ZNFT1091N.
  CLEAR LS_ZNFT1091D. REFRESH LT_ZNFT1091D.
  CLEAR GS_ZNFT1010.  REFRESH GT_ZNFT1010.

* 개인아이디인 경우 인터널테이블에서 읽어오기
  IF GV_PERNR IS INITIAL AND LINES( GT_PERNR ) EQ 1.
    READ TABLE GT_PERNR INDEX 1.
    IF SY-SUBRC EQ 0.
      GV_PERNR = GT_PERNR-PERNR.
    ENDIF.
  ENDIF.

  LOOP AT GT_OUTTAB_A INTO GS_OUTTAB_A WHERE CHECK EQ 'X'.

*   =================================================
*   해당 선물요청번호의 CONSQ
*   =================================================
    CLEAR GV_CONSQ.
    SELECT SINGLE CONSQ INTO GV_CONSQ
      FROM ZNFT1091
     WHERE BUKRS EQ P_BUKRS
       AND NFNUM EQ GS_OUTTAB_A-REQNO
       AND CONGB EQ '2'
       AND CONST EQ 'B'.

*   =======================================================
*   STEP - 1 : ZNFT1010 변경 ( RSTAT )
*   =======================================================
*   ZNFT1010 데이터 변경 INTERNAL TABLE
    SELECT SINGLE * INTO CORRESPONDING FIELDS OF LS_ZNFT1010
      FROM ZNFT1010
     WHERE BUKRS EQ GS_OUTTAB_A-BUKRS
       AND REQNO EQ GS_OUTTAB_A-REQNO.

    IF SY-SUBRC EQ 0.
*     ### 문서변경이력관리용 ###
      APPEND LS_ZNFT1010 TO GT_ZNFT1010.
      LV_RSTAT = LS_ZNFT1010-RSTAT.
      CASE  GV_CONSQ.
        WHEN 1.
          LS_ZNFT1010-RSTAT = '3'.
        WHEN 2.
          LS_ZNFT1010-RSTAT = '4'.
        WHEN 3.
          LS_ZNFT1010-RSTAT = '5'.
        WHEN 4 .
          LS_ZNFT1010-RSTAT = '6'.
      ENDCASE.
      LS_ZNFT1010-AENAM = GV_UNAME.
      LS_ZNFT1010-AEDAT = SY-DATLO.
      LS_ZNFT1010-AEZET = SY-TIMLO.
      APPEND LS_ZNFT1010 TO LT_ZNFT1010.
      CLEAR  LS_ZNFT1010.
    ENDIF.

*   =======================================================
*   STEP - 2 : ZNFT1091 변경 ( CONST )
*   =======================================================
*   ZNFT1091 데이터 변경 : 해당 결재순번의 요청승인상태 = 'A'로 변경
    SELECT SINGLE * INTO CORRESPONDING FIELDS OF LS_ZNFT1091
      FROM ZNFT1091
     WHERE BUKRS EQ GS_OUTTAB_A-BUKRS
       AND NFNUM EQ GS_OUTTAB_A-REQNO
       AND CONGB EQ '2'
       AND CONSQ EQ GV_CONSQ.

    IF SY-SUBRC EQ 0.

      LS_ZNFT1091-CONST = 'A'.
      LS_ZNFT1091-PERNR = GV_PERNR.
      LS_ZNFT1091-USRID = GV_UNAME.
      LS_ZNFT1091-AENAM = GV_UNAME.
      LS_ZNFT1091-AEDAT = SY-DATLO.
      LS_ZNFT1091-AEZET = SY-TIMLO.
      APPEND LS_ZNFT1091 TO LT_ZNFT1091.

*   ======================================================
*   STEP - 3 : ZNFT1091 신규추가
*              CONSQ / CONGB / PERNR / USRID
*              (기존내역이 존재하는경 CONST = 'B'로 변경)
*   ======================================================

*     ZNFT1091-CONSQ = 4 인경우는 신규추가하지 않는다.
      IF GV_CONSQ EQ 4.
        CONTINUE.
      ENDIF.

      LS_ZNFT1091N-BUKRS = LS_ZNFT1091-BUKRS.
      LS_ZNFT1091N-NFNUM = LS_ZNFT1091-NFNUM.
      CASE  GV_CONSQ.
        WHEN 1.
          LS_ZNFT1091N-CONSQ = 2.
        WHEN 2.
          LS_ZNFT1091N-CONSQ = 3.
        WHEN 3.
          LS_ZNFT1091N-CONSQ = 4.
        WHEN 4 .
          LS_ZNFT1091N-CONSQ = 5.
      ENDCASE.

      SELECT SINGLE * INTO CORRESPONDING FIELDS OF LS_ZNFT1091Y
        FROM ZNFT1091
       WHERE BUKRS EQ LS_ZNFT1091N-BUKRS
         AND NFNUM EQ LS_ZNFT1091N-NFNUM
         AND CONSQ EQ LS_ZNFT1091N-CONSQ.

      IF SY-SUBRC EQ 0.
        MOVE-CORRESPONDING LS_ZNFT1091Y TO LS_ZNFT1091N.
        CASE  GV_CONSQ.
          WHEN 1.
            LS_ZNFT1091N-CONSQ = 2.
          WHEN 2.
            LS_ZNFT1091N-CONSQ = 3.
          WHEN 3.
            LS_ZNFT1091N-CONSQ = 4.
          WHEN 4 .
            LS_ZNFT1091N-CONSQ = 5.
        ENDCASE.
        LS_ZNFT1091N-CONGB = '2'.
        LS_ZNFT1091N-CONST = 'B'.
*        LS_ZNFT1091N-PERNR = GV_PERNR.
        LS_ZNFT1091N-PERNR = SPACE.
*        LS_ZNFT1091N-USRID = GV_UNAME.
        LS_ZNFT1091N-USRID = SPACE.
        LS_ZNFT1091N-AENAM = GV_UNAME.
        LS_ZNFT1091N-AEDAT = SY-DATLO.
        LS_ZNFT1091N-AEZET = SY-TIMLO.
      ELSE.
        LS_ZNFT1091N-CONGB = '2'.
        LS_ZNFT1091N-CONST = 'B'.
*        LS_ZNFT1091N-PERNR = GV_PERNR.
        LS_ZNFT1091N-PERNR = SPACE.
*        LS_ZNFT1091N-USRID = GV_UNAME.
        LS_ZNFT1091N-USRID = SPACE.
        LS_ZNFT1091N-ERNAM = GV_UNAME.
        LS_ZNFT1091N-ERDAT = SY-DATLO.
        LS_ZNFT1091N-ERZET = SY-TIMLO.
        LS_ZNFT1091N-AENAM = GV_UNAME.
        LS_ZNFT1091N-AEDAT = SY-DATLO.
        LS_ZNFT1091N-AEZET = SY-TIMLO.
      ENDIF.
      APPEND LS_ZNFT1091N TO LT_ZNFT1091N.

*     ==============================================================
*     STEP - 4 : ZNFT1010 점검
*                ZNFT1091-CONSQ = '1' AND ZNFT1010-RSTAT = '7'인경우
*                ZNFT1091-CONSQ IN 3,4 삭제
*     ==============================================================
      IF GV_CONSQ EQ '1' AND LV_RSTAT EQ '7'.
        SELECT * INTO CORRESPONDING FIELDS OF TABLE LT_ZNFT1091D
          FROM ZNFT1091
         WHERE BUKRS EQ GS_OUTTAB_A-BUKRS
           AND NFNUM EQ GS_OUTTAB_A-REQNO
           AND CONSQ IN (3,4).
      ENDIF.
    ENDIF.
    CLEAR : LS_ZNFT1091, LS_ZNFT1091N, LS_ZNFT1091Y.
  ENDLOOP.

  DATA: LV_DBCNT TYPE I.
  CLEAR LV_DBCNT.

  LV_DBCNT = LINES( LT_ZNFT1010 ).

* ZNFT1010 - 변경
  MODIFY ZNFT1010 FROM TABLE LT_ZNFT1010.
  IF SY-SUBRC EQ 0.
*   ZNFT1091 - 변경
    MODIFY ZNFT1091 FROM TABLE LT_ZNFT1091.
    IF SY-SUBRC EQ 0.
*     ZNFT1091 - 신규
      MODIFY ZNFT1091 FROM TABLE LT_ZNFT1091N.
      IF SY-SUBRC EQ 0.
        IF LT_ZNFT1091D IS NOT INITIAL.
*         ZNFT1091 - 삭제
          DELETE ZNFT1091 FROM TABLE LT_ZNFT1091D.
          IF SY-SUBRC EQ 0.
            PERFORM SAVE_CHANGE_DOC_ZNFT1010.
            MESSAGE S003 DISPLAY LIKE 'S'
               WITH LV_DBCNT '건이 승인 완료되었습니다.'.

            COMMIT WORK.

*--- 간편결재 전송.
            LOOP AT   LT_ZNFT1010 INTO LS_ZNFT1010.
              PERFORM SEND_SIMPLE_APPROVAL
              USING LS_ZNFT1010-REQNO
                        LS_ZNFT1010-BUKRS
                        '2A'.
            ENDLOOP.
          ELSE.
            MESSAGE S003 DISPLAY LIKE 'E'
               WITH '저장시 오류입니다.'.
            ROLLBACK WORK.
            EXIT.
          ENDIF.
        ELSE.
          PERFORM SAVE_CHANGE_DOC_ZNFT1010.
          MESSAGE S003 DISPLAY LIKE 'S'
             WITH LV_DBCNT '건이 승인 완료되었습니다.'.

          COMMIT WORK.
*--- 간편결재 전송.
          LOOP AT   LT_ZNFT1010 INTO LS_ZNFT1010.
            PERFORM SEND_SIMPLE_APPROVAL
            USING LS_ZNFT1010-REQNO
                      LS_ZNFT1010-BUKRS
                      '2A'.
          ENDLOOP.
        ENDIF.
      ELSE.
        MESSAGE S003 DISPLAY LIKE 'E'
           WITH '저장시 오류입니다.'.
        ROLLBACK WORK.
        EXIT.
      ENDIF.
    ELSE.
      MESSAGE S003 DISPLAY LIKE 'E'
         WITH '저장시 오류입니다.'.
      ROLLBACK WORK.
      EXIT.
    ENDIF.
  ELSE.
    MESSAGE S003 DISPLAY LIKE 'E'
       WITH '저장시 오류입니다.'.
    ROLLBACK WORK.
    EXIT.
  ENDIF.

ENDFORM.                    " DATA_ALLOW_A

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
  CLEAR : GV_CONSQ, GV_ERROR.
  PERFORM DATA_CHECK_R USING GV_ERROR.
  CHECK GV_ERROR NE 'X'.

* 진행상황 체크
  PERFORM POPUP_TO_CONFIRM
    USING '확인'
          '반려처리 하시겠습니까?'
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

  PERFORM DATA_REJECT_A.

ENDFORM.                    " DATA_REJECT

*&---------------------------------------------------------------------*
*&      Form  DATA_CHECK_R
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GV_ERROR  text
*----------------------------------------------------------------------*
FORM DATA_CHECK_R  USING  PV_ERROR.

  DATA: LV_DBCNT TYPE I.
  DATA: LS_OUTTAB_A LIKE GS_OUTTAB_A,
        LT_OUTTAB_A LIKE TABLE OF LS_OUTTAB_A.

* 선택한 동일-사번체크 (공용인 경우 로그인한 사번의 데이터만 처리가능)
  DATA: BEGIN OF LT_PERNR OCCURS 0,
          PERNR LIKE PA0105-PERNR,
        END   OF LT_PERNR,
        LV_CHECK_CNT TYPE I.

  LOOP AT GT_OUTTAB_A INTO GS_OUTTAB_A WHERE CHECK EQ 'X'.
    MOVE-CORRESPONDING GS_OUTTAB_A TO LS_OUTTAB_A.
    APPEND LS_OUTTAB_A TO LT_OUTTAB_A.
  ENDLOOP.

  IF LT_OUTTAB_A IS INITIAL.
    MESSAGE S003 DISPLAY LIKE 'E'
       WITH '승인하실 데이터를 선택하십시오.'.
    PV_ERROR = 'X'.
    EXIT.
  ENDIF.

* ### 로그인ID => 사번 가져오기
  DATA : LV_NFNUM TYPE ZNFNUM,
         LV_RSTAT TYPE ZRSTAT.

  CLEAR: GV_CONSQ, LV_NFNUM, LV_RSTAT.

  DATA: LV_CONSQ TYPE ZCONSQ,
        LV_CNT   TYPE I.

  LOOP AT LT_OUTTAB_A INTO LS_OUTTAB_A.
*   ==========================================================
*     승인권한 점검
*   ==========================================================
    CLEAR LV_CONSQ.
    SELECT SINGLE CONSQ INTO LV_CONSQ
      FROM ZNFT1091
     WHERE BUKRS EQ P_BUKRS
       AND NFNUM EQ LS_OUTTAB_A-REQNO
       AND CONGB EQ '2'
       AND CONST EQ 'B'.

    IF SY-SUBRC EQ 0.
      GV_CONSQ = LV_CONSQ.
    ELSE.
      MESSAGE S003 DISPLAY LIKE 'E'
         WITH '승인전 데이터가 없습니다.'.
      PV_ERROR = 'X'.
      EXIT.
    ENDIF.

*   GV_CONSQ = 1 인경우는
*   ZNFT1090-PERNR 과 ZNFT1091-PERNR이 명시적으로
*   같은 경우 데이터를 가져온다.
    IF GV_CONSQ EQ 1.

      CLEAR LV_CNT.
      IF GT_PERNR[] IS NOT INITIAL.
        SELECT COUNT(*) INTO LV_CNT
          FROM ZNFT1091 AS Z1
               INNER JOIN ZNFT1090 AS Z2
                  ON Z2~BUKRS EQ Z1~BUKRS AND Z2~CONSQ EQ Z1~CONSQ
                 AND Z2~CONGB EQ Z1~CONGB AND Z2~PERNR EQ Z1~PERNR
               FOR ALL ENTRIES IN GT_PERNR
         WHERE Z1~BUKRS EQ P_BUKRS
           AND Z1~CONST EQ 'B'
           AND Z1~NFNUM EQ LS_OUTTAB_A-REQNO
           AND Z2~PERNR EQ GT_PERNR-PERNR
           AND Z2~LVORM NE 'X'.
      ELSE.
        MESSAGE S003 DISPLAY LIKE 'E'
           WITH GV_UNAME '에 대한 사번정보가 존재하지 않습니다.'.
        EXIT.
      ENDIF.

      IF SY-SUBRC EQ 0.
        IF LV_CNT LT 1.
          MESSAGE S003 DISPLAY LIKE 'E'
             WITH '승인권한이 없습니다.'.
          PV_ERROR = 'X'.
          EXIT.
        ENDIF.
      ELSE.
        MESSAGE S003 DISPLAY LIKE 'E'
           WITH '승인권한이 없습니다.'.
        PV_ERROR = 'X'.
        EXIT.
      ENDIF.

    ELSE.

      CLEAR LV_CNT.
      IF GT_PERNR[] IS NOT INITIAL.
        SELECT COUNT(*) INTO LV_CNT
          FROM ZNFT1091 AS Z1
               INNER JOIN ZNFT1090 AS Z2
                  ON Z2~BUKRS EQ Z1~BUKRS AND Z2~CONSQ EQ Z1~CONSQ
                 AND Z2~CONGB EQ Z1~CONGB
               FOR ALL ENTRIES IN GT_PERNR
         WHERE Z1~BUKRS EQ P_BUKRS
           AND Z1~CONST EQ 'B'
           AND Z1~NFNUM EQ LS_OUTTAB_A-REQNO
           AND Z2~PERNR EQ GT_PERNR-PERNR
           AND Z2~LVORM NE 'X'.
      ELSE.
        MESSAGE S003 DISPLAY LIKE 'E'
           WITH GV_UNAME '에 대한 사번정보가 존재하지 않습니다.'.
        EXIT.
      ENDIF.

      IF SY-SUBRC EQ 0.
        IF LV_CNT LT 1.
          MESSAGE S003 DISPLAY LIKE 'E'
             WITH '승인권한이 없습니다.'.
          PV_ERROR = 'X'.
          EXIT.
        ENDIF.
      ELSE.
        MESSAGE S003 DISPLAY LIKE 'E'
           WITH '승인권한이 없습니다.'.
        PV_ERROR = 'X'.
        EXIT.
      ENDIF.
    ENDIF.

*   결재순번
    CASE GV_CONSQ.
      WHEN 1.
        SELECT SINGLE RSTAT INTO LV_RSTAT FROM ZNFT1010
         WHERE REQNO = LS_OUTTAB_A-REQNO.
        IF SY-SUBRC EQ 0.
          IF LV_RSTAT EQ '2'.
          ELSE.
            MESSAGE S003 DISPLAY LIKE 'E'
               WITH LS_OUTTAB_A-REQNO
                    '결재대상이 아닙니다. 결재상태를 확인하세요'.
            PV_ERROR = 'X'.
            EXIT.
          ENDIF.
        ELSE.
        ENDIF.
      WHEN 2.
        SELECT SINGLE RSTAT INTO LV_RSTAT FROM ZNFT1010
         WHERE REQNO = LS_OUTTAB_A-REQNO.
        IF SY-SUBRC EQ 0.
          IF LV_RSTAT EQ '3'.
          ELSE.
            MESSAGE S003 DISPLAY LIKE 'E'
               WITH LS_OUTTAB_A-REQNO
                    '-결재대상이 아닙니다. 결재상태를 확인하세요'.
            PV_ERROR = 'X'.
            EXIT.
          ENDIF.
        ELSE.
        ENDIF.
      WHEN 3.
        SELECT SINGLE RSTAT INTO LV_RSTAT FROM ZNFT1010
         WHERE REQNO = LS_OUTTAB_A-REQNO.
        IF SY-SUBRC EQ 0.
          IF LV_RSTAT EQ '4'.
          ELSE.
            MESSAGE S003 DISPLAY LIKE 'E'
               WITH LS_OUTTAB_A-REQNO
                    '-결재대상이 아닙니다. 결재상태를 확인하세요'.
            PV_ERROR = 'X'.
            EXIT.
          ENDIF.
        ELSE.
        ENDIF.
      WHEN 4.
        SELECT SINGLE RSTAT INTO LV_RSTAT FROM ZNFT1010
         WHERE REQNO = LS_OUTTAB_A-REQNO.
        IF SY-SUBRC EQ 0.
          IF LV_RSTAT EQ '5'.
          ELSE.
            MESSAGE S003 DISPLAY LIKE 'E'
               WITH LS_OUTTAB_A-REQNO
                    '-결재대상이 아닙니다. 결재상태를 확인하세요'.
            PV_ERROR = 'X'.
            EXIT.
          ENDIF.
        ELSE.
        ENDIF.
    ENDCASE.

  ENDLOOP.

ENDFORM.                    " DATA_CHECK_R

*&---------------------------------------------------------------------*
*&      Form  DATA_REJECT_A
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM DATA_REJECT_A .

  DATA: LV_NFUTN TYPE ZFUTNO.

  DATA: LS_ZNFT1010 TYPE ZNFT1010,
        LT_ZNFT1010 LIKE TABLE OF LS_ZNFT1010.

  DATA: LS_ZNFT1091 TYPE ZNFT1091,
        LT_ZNFT1091 LIKE TABLE OF LS_ZNFT1091.

  CLEAR GS_OUTTAB_A.
  CLEAR LS_ZNFT1010.  REFRESH LT_ZNFT1010.
  CLEAR LS_ZNFT1091.  REFRESH LT_ZNFT1091.
  CLEAR GS_ZNFT1010.  REFRESH GT_ZNFT1010.

* 개인아이디인 경우 인터널테이블에서 읽어오기
  IF GV_PERNR IS INITIAL AND LINES( GT_PERNR ) EQ 1.
    READ TABLE GT_PERNR INDEX 1.
    IF SY-SUBRC EQ 0.
      GV_PERNR = GT_PERNR-PERNR.
    ENDIF.
  ENDIF.

  LOOP AT GT_OUTTAB_A INTO GS_OUTTAB_A WHERE CHECK EQ 'X'.

*   =================================================
*   STEP - 1 : ZNFT1010 변경 ( RSTAT = '7' )
*   =================================================
    SELECT SINGLE * INTO CORRESPONDING FIELDS OF LS_ZNFT1010
      FROM ZNFT1010
     WHERE BUKRS EQ GS_OUTTAB_A-BUKRS
       AND REQNO EQ GS_OUTTAB_A-REQNO.

    IF SY-SUBRC EQ 0.
*     ### 문서변경이력관리용 ###
      APPEND LS_ZNFT1010 TO GT_ZNFT1010.

      LS_ZNFT1010-RSTAT = '7'.
      LS_ZNFT1010-AENAM = GV_UNAME.
      LS_ZNFT1010-AEDAT = SY-DATLO.
      LS_ZNFT1010-AEZET = SY-TIMLO.
      APPEND LS_ZNFT1010 TO LT_ZNFT1010.
    ENDIF.

*   =================================================
*   STEP - 2 : ZNFT1091 변경 ( CONST = 'R' )
*   =================================================
    SELECT SINGLE * INTO CORRESPONDING FIELDS OF LS_ZNFT1091
      FROM ZNFT1091
     WHERE BUKRS EQ GS_OUTTAB_A-BUKRS
       AND NFNUM EQ GS_OUTTAB_A-REQNO
       AND CONSQ EQ GV_CONSQ.

    LS_ZNFT1091-CONST = 'R'.
    LS_ZNFT1091-PERNR = GV_PERNR.
    LS_ZNFT1091-USRID = GV_UNAME.
    LS_ZNFT1091-AENAM = GV_UNAME.
    LS_ZNFT1091-AEDAT = SY-DATLO.
    LS_ZNFT1091-AEZET = SY-TIMLO.
    APPEND LS_ZNFT1091 TO LT_ZNFT1091.

*   =================================================
*   STEP - 3 : ZNFT1020에 생성 데이터 체크
*   =================================================
    IF GV_CONSQ EQ '3' OR GV_CONSQ EQ '4'.
      CLEAR LV_NFUTN.
      SELECT SINGLE NFUTN INTO LV_NFUTN FROM ZNFT1020
       WHERE BUKRS EQ P_BUKRS
         AND REQNO EQ GS_OUTTAB_A-REQNO
         AND ( YNCAN EQ SPACE OR ( CONFM NE '3' AND CONFM NE '7' ) ).
    ENDIF.
    CLEAR : LS_ZNFT1010, LS_ZNFT1091.
  ENDLOOP.

  DATA: LV_DBCNT TYPE I.
  CLEAR LV_DBCNT.

  LV_DBCNT = LINES( LT_ZNFT1091 ).

  MODIFY ZNFT1010 FROM TABLE LT_ZNFT1010.
  IF SY-SUBRC EQ 0.
    MODIFY ZNFT1091 FROM TABLE LT_ZNFT1091.
    IF SY-SUBRC EQ 0.
      IF LV_NFUTN IS NOT INITIAL.
        ROLLBACK WORK.
        MESSAGE I003 DISPLAY LIKE 'W'
           WITH '신규선물집행[' LV_NFUTN  ']이 이미 생성되었습니다.'
                '선물집행담당자에게 확인하십시오'.
        EXIT.
      ELSE.
        PERFORM SAVE_CHANGE_DOC_ZNFT1010.
        MESSAGE S003 DISPLAY LIKE 'S'
           WITH '선물요청 ' LV_DBCNT '건이 반려되었습니다.'.
        COMMIT WORK.
*--- 간편결재 전송.
        LOOP AT   LT_ZNFT1010 INTO LS_ZNFT1010.
          PERFORM SEND_SIMPLE_APPROVAL
          USING LS_ZNFT1010-REQNO
                    LS_ZNFT1010-BUKRS
                    '2A'.
        ENDLOOP.
      ENDIF.
    ELSE.
      MESSAGE S003 DISPLAY LIKE 'E'
          WITH '저장시 오류입니다.'.
      ROLLBACK WORK.
      EXIT.
    ENDIF.
  ELSE.
    MESSAGE S003 DISPLAY LIKE 'E'
        WITH '저장시 오류입니다.'.
    ROLLBACK WORK.
    EXIT.
  ENDIF.

ENDFORM.                    " DATA_REJECT_A

*&---------------------------------------------------------------------*
*&      Form  SAVE_CHANGE_DOC_ZNFT1010
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SAVE_CHANGE_DOC_ZNFT1010 .

  DATA: LS_ZNFT1010Y TYPE ZNFT1010,
        LS_ZNFT1010N TYPE ZNFT1010.

  DATA: LV_OBJECTID        TYPE CDHDR-OBJECTID,
        LV_TCODE           TYPE CDHDR-TCODE,
        LV_CDOC_UPD_OBJECT TYPE CDHDR-CHANGE_IND.

  DATA: XGT_1011 LIKE YZNFT1011 OCCURS 0 WITH HEADER LINE,
        YGT_1011 LIKE YZNFT1011 OCCURS 0 WITH HEADER LINE.

  CLEAR  :XGT_1011, YGT_1011, LS_ZNFT1010N, LS_ZNFT1010Y.
  REFRESH:XGT_1011, YGT_1011.

  CHECK GT_ZNFT1010 IS NOT INITIAL.

* 승인&반려 전에 기존 선물요청데이터를 가지고 COMMIT 이후의
* 변경데이터를 다시 SELECT해서 변경이력을 생성한다.

  CLEAR GS_ZNFT1010.
  LOOP AT  GT_ZNFT1010 INTO GS_ZNFT1010.

*   ### 변경이력

    MOVE-CORRESPONDING GS_ZNFT1010 TO LS_ZNFT1010Y.

    SELECT SINGLE * INTO CORRESPONDING FIELDS OF LS_ZNFT1010N
      FROM ZNFT1010
     WHERE BUKRS EQ GS_ZNFT1010-BUKRS
       AND REQNO EQ GS_ZNFT1010-REQNO.

    LV_OBJECTID        = GS_ZNFT1010-REQNO..
    LV_TCODE           = SY-TCODE.
    LV_CDOC_UPD_OBJECT = 'U'.

    CALL FUNCTION 'ZNFT1010CHDOC_WRITE_DOCUMENT'
      EXPORTING
        OBJECTID     = LV_OBJECTID
        TCODE        = LV_TCODE
        UTIME        = SY-TIMLO
        UDATE        = SY-DATLO
        USERNAME     = SY-UNAME
        N_ZNFT1010   = LS_ZNFT1010N
        O_ZNFT1010   = LS_ZNFT1010Y
        UPD_ZNFT1010 = LV_CDOC_UPD_OBJECT
        UPD_ZNFT1011 = SPACE
      TABLES
        XZNFT1011    = XGT_1011
        YZNFT1011    = YGT_1011.

  ENDLOOP.

ENDFORM.                    " SAVE_CHANGE_DOC_ZNFT1010

*&---------------------------------------------------------------------*
*&      Form  DATA_RELOAD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM DATA_RELOAD.

  CLEAR  : GS_NFNUM,   GS_OUTTAB_A.
  REFRESH: GT_NFNUM_A, GT_OUTTAB_A.

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
        IF GS_OUTTAB_A-CHECK = '-'.
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
*&      Form  SELECT_ALL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SELECT_ALL .

  LOOP AT GT_OUTTAB_A INTO GS_OUTTAB_A WHERE CHECK NE '-'.
    IF OK_SAVE = 'ASEL'.
      GS_OUTTAB_A-CHECK = 'X'.
    ELSE.
      CLEAR : GS_OUTTAB_A-CHECK.
    ENDIF.
    MODIFY GT_OUTTAB_A FROM GS_OUTTAB_A TRANSPORTING CHECK.
  ENDLOOP.

ENDFORM.                    " SELECT_ALL

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
