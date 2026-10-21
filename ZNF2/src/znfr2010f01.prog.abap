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

*  GS_SORT-SPOS = 1.
*  GS_SORT-FIELDNAME = 'CONNO'.
*  GS_SORT-UP = 'X'.
*  GS_SORT-COMP = 'X'.
*  GS_SORT-SUBTOT = 'X'.
*  APPEND GS_SORT TO GT_SORT.

*  GS_SORT-SPOS = 2.
*  GS_SORT-FIELDNAME = 'COTYP_NM'.
*  GS_SORT-UP = 'X'.
*  GS_SORT-COMP = 'X'.
*  GS_SORT-SUBTOT = 'X'.
*  APPEND GS_SORT TO GT_SORT.
*
*  GS_SORT-SPOS = 3.
*  GS_SORT-FIELDNAME = 'COTXT'.
*  GS_SORT-UP = 'X'.
*  GS_SORT-COMP = 'X'.
*  GS_SORT-SUBTOT = 'X'.
*  APPEND GS_SORT TO GT_SORT.
*
*  GS_SORT-SPOS = 4.
*  GS_SORT-FIELDNAME = 'BUKRS_NM'.
*  GS_SORT-UP = 'X'.
*  GS_SORT-COMP = 'X'.
*  GS_SORT-SUBTOT = 'X'.
*  APPEND GS_SORT TO GT_SORT.
*
*  GS_SORT-SPOS = 5.
*  GS_SORT-FIELDNAME = 'NFCTR_NM'.
*  GS_SORT-UP = 'X'.
*  GS_SORT-COMP = 'X'.
*  GS_SORT-SUBTOT = 'X'.
*  APPEND GS_SORT TO GT_SORT.
*
*  GS_SORT-SPOS = 6.
*  GS_SORT-FIELDNAME = 'PRCTR_NM'.
*  GS_SORT-UP = 'X'.
*  GS_SORT-COMP = 'X'.
*  GS_SORT-SUBTOT = 'X'.
*  APPEND GS_SORT TO GT_SORT.
*
*  GS_SORT-SPOS = 7.
*  GS_SORT-FIELDNAME = 'VKGRP_NM'.
*  GS_SORT-UP = 'X'.
*  GS_SORT-COMP = 'X'.
*  GS_SORT-SUBTOT = 'X'.
*  APPEND GS_SORT TO GT_SORT.
*
*  GS_SORT-SPOS = 8.
*  GS_SORT-FIELDNAME = 'KUNNR'.
*  GS_SORT-UP = 'X'.
*  GS_SORT-COMP = 'X'.
*  GS_SORT-SUBTOT = 'X'.
*  APPEND GS_SORT TO GT_SORT.
*
*  GS_SORT-SPOS = 9.
*  GS_SORT-FIELDNAME = 'KUNNR_NM'.
*  GS_SORT-UP = 'X'.
*  GS_SORT-COMP = 'X'.
*  GS_SORT-SUBTOT = 'X'.
*  APPEND GS_SORT TO GT_SORT.
*
*  GS_SORT-SPOS = 10.
*  GS_SORT-FIELDNAME = 'SUJUD'.
*  GS_SORT-UP = 'X'.
*  GS_SORT-COMP = 'X'.
*  GS_SORT-SUBTOT = 'X'.
*  APPEND GS_SORT TO GT_SORT.
*
*  GS_SORT-SPOS = 11.
*  GS_SORT-FIELDNAME = 'SALER'.
*  GS_SORT-UP = 'X'.
*  GS_SORT-COMP = 'X'.
*  GS_SORT-SUBTOT = 'X'.
*  APPEND GS_SORT TO GT_SORT.
*
*  GS_SORT-SPOS = 12.
*  GS_SORT-FIELDNAME = 'PRATE'.
*  GS_SORT-UP = 'X'.
*  GS_SORT-COMP = 'X'.
*  GS_SORT-SUBTOT = 'X'.
*  APPEND GS_SORT TO GT_SORT.
*
*  GS_SORT-SPOS = 13.
*  GS_SORT-FIELDNAME = 'ERDAT'.
*  GS_SORT-UP = 'X'.
*  GS_SORT-COMP = 'X'.
*  GS_SORT-SUBTOT = 'X'.
*  APPEND GS_SORT TO GT_SORT.
*
*  GS_SORT-SPOS = 14.
*  GS_SORT-FIELDNAME = 'ERNAM'.
*  GS_SORT-UP = 'X'.
*  GS_SORT-COMP = 'X'.
*  GS_SORT-SUBTOT = 'X'.
*  APPEND GS_SORT TO GT_SORT.

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
    'CONNO'           '계약번호'        '10'     'C'    ' '     ,
    'COTYP'           '계약유형'        '10'     'C'    ' '     ,
    'COTYP_NM'        '계약유형'        '10'     'C'    ' '     ,
    'COTXT'           '계약명'          '20'     'L'    ' '     ,
    'BUKRS'           '회사코드'        '10'     'C'    ' '     ,
    'BUKRS_NM'        '회사명'          '10'     'L'    ' '     ,
    'NFCTR'           '사업부'          '10'     'C'    ' '     ,
    'NFCTR_NM'        '사업부명'        '10'     'L'    ' '     ,
    'PRCTR'           '손익센터'        '10'     'C'    ' '     ,
    'PRCTR_NM'        '손익센터명'      '10'     'L'    ' '     ,
    'VKGRP'           '영업그룹'        '10'     'C'    ' '     ,
    'VKGRP_NM'        '영업그룹명'      '10'     'L'    ' '     ,
    'ERDAT'           '생성일'          '20'     'L'    ' '     ,
    'ERNAM'           '생성자'          '20'     'L'    ' '     ,
    'KUNNR'           '고  객'          '10'     'C'    'ALPHA' ,
    'KUNNR_NM'        '고객명'          '20'     'L'    ' '     ,
    'SUJUD'           '수주일'          '10'     'C'    ' '     ,
    'SALER'           '영업담당자'      '10'     'C'    ' '     ,
    'PRATE'           '영업이익률(%)'   '12'     'R'    ' '     ,
    'ERATE'           '환율'            '10'     'R'    ' '     ,
    'CSTAT'           '계약상태'        '10'     'C'    ' '     ,
    'CSTAT_NM'        '계약상태'        '10'     'C'    ' '     ,
    'NFKEY'           '비철구분'        '10'     'C'    ' '     ,
    'NFKEY_NM'        '비철구분'        '18'     'L'    ' '     ,
    'EMENG'           '수주량'          '10'     'R'    ' '     ,
    'MEINS'           '단위'            '10'     'C'    ' '     ,
    'PRICE'           '수주금액'        '15'     'R'    ' '     ,
    'WAERS'           '통화'            '5'      'C'    ' '     ,
    'PRIND'           '가격구분'        '10'     'C'    ' '     ,
    'ZPJNO'           'Project NO'      '10'     'C'    ' '     ,
    'SUJUP'           '비철수주가'      '10'     'R'    ' '     ,
    'REQNO'           '요청번호'        '10'     'L'    ' '     ,
    'H_NO1'           '항번'            '10'     'C'    ' '     ,
    'ENDMM'           '만기월'          '10'     'C'    'PERI'  ,
    'EMENG_R'         '요청수량'        '10'     'R'    ' '     ,
    'MEINS_R'         '단위'            '10'     'C'    ' '     ,
    'ERDAT_R'         '생성일'          '20'     'L'    ' '     ,
    'BY_SL'           'Buy-Sell'        '10'     'C'    ' '     ,
    'BY_SL_NM'        'Buy-Sell'        '10'     'L'    ' '     ,
    'BIGO4'           '비고'            '40'     'L'    ' '     ,
    'BY_SL'           'Buy-Sell'        '10'     'C'    ' '     ,
    'BY_SL_NM'        'Buy-Sell'        '10'     'L'    ' '     ,
    'BIGO4'           '비고'            '40'     'L'    ' '     ,
    'NFUTN_N'         '선물집행번호'    '10'     'L'    ' '     ,
    'RUDAT_N'         '집행일'          '10'     'C'    ' '     ,
    'ENDAT_N'         '만기일'          '10'     'C'    ' '     ,
    'MITYP_N'         '집행유형'        '1'      'C'    ' '     ,
    'MITYP_NM'        '집행유형'        '10'     'C'    ' '     ,
    'MISPD_N'         'Spread'          '10'     'R'    ' '     ,
    'MIMON_N'         '기준월'          '8'      'C'    ' '     ,
    'PRICE_N'         '집행단가'        '10'     'R'    ' '     ,
    'EMENG_N'         '집행수량'        '10'     'R'    ' '     .

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
    WHEN 'COTYP' OR 'BUKRS' OR 'BUKRS_NM' OR 'NFCTR' OR 'PRCTR'
       OR 'VKGRP' OR 'COTYP' OR 'BY_SL'.
      GS_FIELDCAT-NO_OUT     = 'X'.
    WHEN 'NFKEY_NM' OR 'CSTAT'.
      GS_FIELDCAT-NO_OUT     = 'X'.
    WHEN 'PRICE'.
      GS_FIELDCAT-CFIELDNAME = 'WAERS'.
    WHEN 'EMENG'.
      GS_FIELDCAT-QFIELDNAME = 'MEINS'.
    WHEN 'EMENG_R'.
      GS_FIELDCAT-QFIELDNAME = 'MEINS_R'.
  ENDCASE.

  APPEND GS_FIELDCAT TO GT_FIELDCAT.

ENDFORM.                    " SET_FIELDCAT

*&---------------------------------------------------------------------*
*&      Form  SET_FIELDCAT_HIERARCHY
*&---------------------------------------------------------------------*
FORM SET_FIELDCAT_HIERARCHY  USING  P_FIELDNAME
                          P_COLTEXT
                          P_OUTPUTLEN
                          P_JUST
                          P_CONVEXIT.

  CLEAR GS_FIELDCAT_H.

  GV_POS = GV_POS + 1.

  GS_FIELDCAT_H-TABNAME    = GV_ITAB.
  GS_FIELDCAT_H-COL_POS    = GV_POS.
  GS_FIELDCAT_H-FIELDNAME  = P_FIELDNAME .
  GS_FIELDCAT_H-SELTEXT_S  = P_COLTEXT   .
  GS_FIELDCAT_H-SELTEXT_M  = P_COLTEXT   .
  GS_FIELDCAT_H-SELTEXT_L  = P_COLTEXT   .
  GS_FIELDCAT_H-OUTPUTLEN  = P_OUTPUTLEN .
  GS_FIELDCAT_H-JUST       = P_JUST      .

  CASE P_FIELDNAME.
    WHEN 'CONNO'.
      GS_FIELDCAT_H-KEY        = 'X'.
      GS_FIELDCAT_H-FIX_COLUMN = 'X'.
    WHEN  'REQNO'.
      GS_FIELDCAT_H-KEY        = 'X'.
    WHEN 'COTYP' OR 'BUKRS' OR 'BUKRS_NM' OR 'NFCTR' OR 'PRCTR'
       OR 'VKGRP' OR 'COTYP' OR 'BY_SL'.
      GS_FIELDCAT_H-NO_OUT     = 'X'.
    WHEN 'NFKEY_NM' OR 'CSTAT'.
      GS_FIELDCAT_H-NO_OUT     = 'X'.
    WHEN 'PRICE'.
      GS_FIELDCAT_H-CFIELDNAME = 'WAERS'.
    WHEN 'EMENG'.
      GS_FIELDCAT_H-QFIELDNAME = 'MEINS'.
    WHEN 'EMENG_R'.
      GS_FIELDCAT_H-QFIELDNAME = 'MEINS_R'.
  ENDCASE.

  APPEND GS_FIELDCAT_H TO GT_FIELDCAT_H.

ENDFORM.                    " SET_FIELDCAT_HIERARCHY


*&---------------------------------------------------------------------*
*&      Form  SET_GRID_FIELDCATALOG_H
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SET_GRID_FIELDCATALOG_H.

  CLEAR   : GT_FIELDCAT_H.
  REFRESH : GT_FIELDCAT_H.


  CLEAR : GV_POS.
  GV_ITAB = 'GT_HEADER'.
  PERFORM SET_FIELDCAT_HIERARCHY USING:
    'CONNO'           '계약번호'        '10'     'C'    ' '     ,
    'NFKEY'           '비철구분'        '10'     'C'    ' '     ,
    'NFKEY_NM'        '비철구분'        '18'     'L'    ' '     ,
    'COTYP'           '계약유형'        '10'     'C'    ' '     ,
    'COTYP_NM'        '계약유형'        '10'     'C'    ' '     ,
    'COTXT'           '계약명'          '20'     'L'    ' '     ,
    'BUKRS'           '회사코드'        '10'     'C'    ' '     ,
    'BUKRS_NM'        '회사명'          '10'     'L'    ' '     ,
    'NFCTR'           '사업부'          '10'     'C'    ' '     ,
    'NFCTR_NM'        '사업부명'        '10'     'L'    ' '     ,
    'PRCTR'           '손익센터'        '10'     'C'    ' '     ,
    'PRCTR_NM'        '손익센터명'      '10'     'L'    ' '     ,
    'ZPJNO'           'Project NO'      '10'     'L'    ' '     ,
    'VKGRP'           '영업조직'        '10'     'C'    ' '     ,
    'VKGRP_NM'        '영업조직명'      '10'     'L'    ' '     ,
    'ERDAT'           '생성일'          '20'     'L'    ' '     ,
    'ERNAM'           '생성자'          '20'     'L'    ' '     ,
    'KUNNR'           '고  객'          '10'     'C'    'ALPHA' ,
    'KUNNR_NM'        '고객명'          '20'     'L'    ' '     ,
    'SUJUD'           '수주일'          '10'     'C'    ' '     ,
    'SALER'           '영업담당자'      '10'     'C'    ' '     ,
    'PRATE'           '영업이익률(%)'   '12'     'R'    ' '     ,
    'CSTAT'           '계약상태'        '10'     'C'    ' '     ,
    'CSTAT_NM'        '계약상태'        '10'     'C'    ' '     ,
    'EMENG'           '수주량'          '10'     'R'    ' '     ,
    'MEINS'           '단위'            '10'     'C'    ' '     ,
    'PRICE'           '수주금액'        '15'     'R'    ' '     ,
    'WAERS'           '통화'            '5'      'C'    ' '     ,
    'PRIND'           '가격구분'        '10'     'C'    ' '     ,
    'SUJUP'           '비철수주가'      '10'     'R'    ' '     .

  CLEAR : GV_POS.
  GV_ITAB = 'GT_ITEM'.
  PERFORM SET_FIELDCAT_HIERARCHY USING:
*    'CONNO'           '계약번호'        '10'     'C'    ' '     ,
    'REQNO'           '요청번호'        '10'     'L'    ' '     ,
    'H_NO1'           '항번'            '10'     'C'    ' '     ,
    'NFKEY'           '비철구분'        '10'     'C'    ' '     ,
    'NFKEY_NM'        '비철구분'        '18'     'L'    ' '     ,
    'ENDMM'           '만기월'          '10'     'C'    ' '     ,
    'EMENG_R'         '요청수량'        '10'     'R'    ' '     ,
    'MEINS_R'         '단위'            '10'     'C'    ' '     ,
    'ERDAT_R'         '생성일'          '20'     'L'    ' '     ,
    'BY_SL'           'Buy-Sell'        '10'     'C'    ' '     ,
    'BY_SL_NM'        'Buy-Sell'        '10'     'L'    ' '     ,
    'BIGO4'           '비고'            '40'     'L'    ' '     .

ENDFORM.                    " SET_GRID_FIELDCATALOG_H

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
  REFRESH: GT_OUTTAB,
           GT_OUTTAB_B.
  CLEAR:   GS_OUTTAB_B.

  SELECT A~CONNO
         A~COTYP
         A~COTXT
         A~BUKRS
         A~NFCTR
         A~PRCTR
         A~VKGRP
         A~KUNNR
         A~NCUST
         A~SUJUD
         A~SALER
         A~PRATE
         A~ERATE
         A~ERDAT
         A~ERNAM
         A~PRICE
         A~WAERS
         A~CSTAT
         A~ZPJNO
         C~REQNO
         C~H_NO1
         B~NFKEY
         B~EMENG
         B~MEINS
         C~ERDAT AS ERDAT_R
         C~EMENG AS EMENG_R
         C~MEINS AS MEINS_R
         C~ENDMM
         C~BY_SL
         C~BIGO4
         INTO CORRESPONDING FIELDS OF TABLE GT_OUTTAB_B
    FROM ZNFT1000 AS A
         INNER JOIN ZNFT1001 AS B
            ON B~CONNO EQ A~CONNO
         LEFT OUTER JOIN ZNFT1011 AS C
            ON C~CONNO EQ B~CONNO AND C~NFKEY EQ B~NFKEY
   WHERE A~BUKRS EQ P_BUKRS
     AND A~ERDAT IN S_ERDAT
     AND A~CONNO IN S_CONNO
     AND A~NFCTR IN S_NFCTR
     AND A~PRCTR IN S_PRCTR
     AND A~VKGRP IN S_VKGRP
     AND A~ZPJNO IN S_ZPJNO
     AND A~ERNAM IN S_ERNAM
     AND A~CSTAT IN R_CSTAT
     AND A~CSTAT NE 'D'.        " 삭제인건 제외

  IF GT_OUTTAB_B IS NOT INITIAL.
    LOOP AT GT_OUTTAB_B INTO GS_OUTTAB_B.
      CLEAR: GS_OUTTAB.
*   - 회사코드
      PERFORM GET_BUKRS_DESC USING GS_OUTTAB_B-BUKRS
                                   GS_OUTTAB_B-BUKRS_NM.

*   - 사업부
      PERFORM GET_NFCTR_DESC USING GS_OUTTAB_B-BUKRS
                                   GS_OUTTAB_B-NFCTR
                                   GS_OUTTAB_B-NFCTR_NM.

*   - 손익센터
      PERFORM GET_PRCTR_DESC USING GS_OUTTAB_B-BUKRS
                                   GS_OUTTAB_B-PRCTR
                                   GS_OUTTAB_B-PRCTR_NM.

*   - 영업그룹
      PERFORM GET_VKGRP_DESC USING GS_OUTTAB_B-BUKRS
                                   GS_OUTTAB_B-VKGRP
                                   GS_OUTTAB_B-VKGRP_NM.

*   - 고객명
      IF GS_OUTTAB_B-KUNNR IS NOT INITIAL.
        PERFORM GET_KUNNR_DESC USING GS_OUTTAB_B-KUNNR
                                     GS_OUTTAB_B-KUNNR_NM.
      ELSE.
        GS_OUTTAB-KUNNR_NM = GS_OUTTAB_B-NCUST.
      ENDIF.

*   - 계약유형
      PERFORM DOMAIN_VALUE_GET USING 'ZCOTYP'
                                     GS_OUTTAB_B-COTYP
                                     GS_OUTTAB_B-COTYP_NM.

*   - 계약상태
      IF GS_OUTTAB_B-NFKEY IS NOT INITIAL.
        PERFORM DOMAIN_VALUE_GET USING 'ZCSTAT'
                                       GS_OUTTAB_B-CSTAT
                                       GS_OUTTAB_B-CSTAT_NM.
      ENDIF.

*   - 비철구분
      IF GS_OUTTAB_B-NFKEY IS NOT INITIAL.
        PERFORM DOMAIN_VALUE_GET USING 'ZNFKEY_1'
                                       GS_OUTTAB_B-NFKEY
                                       GS_OUTTAB_B-NFKEY_NM.
      ENDIF.

*   - Buy-Sell 구분
      IF GS_OUTTAB_B-BY_SL IS NOT INITIAL.
        PERFORM DOMAIN_VALUE_GET USING 'ZBY_SL'
                                       GS_OUTTAB_B-BY_SL
                                       GS_OUTTAB_B-BY_SL_NM.
      ENDIF.

*   - 가격구분 & 비철 수주가
      IF GS_OUTTAB_B-NFKEY IS NOT INITIAL.
        PERFORM PRICE_CLASSIFICATION USING GS_OUTTAB_B-CONNO
                                           GS_OUTTAB_B-NFKEY
                                           GS_OUTTAB_B-PRIND
                                           GS_OUTTAB_B-SUJUP
                                           GV_ERROR.
      ENDIF.

      REFRESH: GT_OUTTAB_A.
      CLEAR:   GS_OUTTAB_A.

      SELECT NFUTN AS NFUTN_N
             RUDAT AS RUDAT_N
             ENDAT AS ENDAT_N
             MITYP AS MITYP_N
             MISPD AS MISPD_N
             MIMON AS MIMON_N
             PRICE AS PRICE_N
             EMENG AS EMENG_N
        INTO CORRESPONDING FIELDS OF TABLE GT_OUTTAB_A
        FROM ZNFT1020
       WHERE REQNO = GS_OUTTAB_B-REQNO
         AND H_NO1 = GS_OUTTAB_B-H_NO1
         AND ( YNCAN <> 'X' OR ( CONFM <> '3' AND CONFM <> '7' ) ).

      IF sy-subrc = 0 AND GT_OUTTAB_A IS NOT INITIAL.
        LOOP AT GT_OUTTAB_A INTO GS_OUTTAB_A.
          CLEAR: GS_OUTTAB.
          MOVE-CORRESPONDING GS_OUTTAB_B TO GS_OUTTAB.
          GS_OUTTAB-NFUTN_N = GS_OUTTAB_A-NFUTN_N.
          GS_OUTTAB-RUDAT_N = GS_OUTTAB_A-RUDAT_N.
          GS_OUTTAB-ENDAT_N = GS_OUTTAB_A-ENDAT_N.
          GS_OUTTAB-MITYP_N = GS_OUTTAB_A-MITYP_N.
          GS_OUTTAB-MISPD_N = GS_OUTTAB_A-MISPD_N.
          GS_OUTTAB-MIMON_N = GS_OUTTAB_A-MIMON_N.
          GS_OUTTAB-PRICE_N = GS_OUTTAB_A-PRICE_N.
          GS_OUTTAB-EMENG_N = GS_OUTTAB_A-EMENG_N.

*.........집행유형
          IF GS_OUTTAB-NFKEY IS NOT INITIAL.
            PERFORM DOMAIN_VALUE_GET USING 'ZMITYP_1'
                                           GS_OUTTAB-MITYP_N
                                           GS_OUTTAB-MITYP_NM.
          ENDIF.

          APPEND GS_OUTTAB TO GT_OUTTAB.

        ENDLOOP.
      ELSE.
        MOVE-CORRESPONDING GS_OUTTAB_B TO GS_OUTTAB.
        APPEND GS_OUTTAB TO GT_OUTTAB.
      ENDIF.
    ENDLOOP.
  ENDIF.

  IF GT_OUTTAB IS NOT INITIAL.
    SORT GT_OUTTAB BY CONNO.
  ENDIF.

ENDFORM.                    " DATA_SELECT_ZNFT1000
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
      WHEN 'REQNO'.
        IF NOT GS_OUTTAB-REQNO IS INITIAL.
          SET PARAMETER: ID 'ZNFREQ' FIELD GS_OUTTAB-REQNO.
          CALL TRANSACTION 'ZNF2M2103' AND SKIP FIRST SCREEN.
        ELSE.
          MESSAGE '요청번호가 존재하지 않습니다.'
             TYPE 'S' DISPLAY LIKE 'E'.
        ENDIF.
    ENDCASE.

  ENDIF.

ENDFORM.                    " ALV_EVENT_DOUBLE_CLICK
*&---------------------------------------------------------------------*
*&      Form  MAKE_RANGE_CSTAT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM MAKE_RANGE_CSTAT USING PV_ERROR.

  CLEAR R_CSTAT. REFRESH R_CSTAT.

  IF P_CHK01 EQ 'X'.
    R_CSTAT-SIGN   = 'I'.
    R_CSTAT-OPTION = 'EQ'.
    R_CSTAT-LOW    = 'L'.
    APPEND R_CSTAT.
  ENDIF.

  IF P_CHK02 EQ 'X'.
    R_CSTAT-SIGN   = 'I'.
    R_CSTAT-OPTION = 'EQ'.
    R_CSTAT-LOW    = 'F'.
    APPEND R_CSTAT.
  ENDIF.

  IF P_CHK03 EQ 'X'.
    R_CSTAT-SIGN   = 'I'.
    R_CSTAT-OPTION = 'EQ'.
    R_CSTAT-LOW    = 'C'.
    APPEND R_CSTAT.
  ENDIF.

  IF R_CSTAT IS INITIAL.
    PV_ERROR = 'X'.
    MESSAGE S003 DISPLAY LIKE 'E'
       WITH '계약상태값을 체크하십시오.'.
  ENDIF.

ENDFORM.                    " MAKE_RANGE_CSTAT
*&---------------------------------------------------------------------*
*&      Form  DATA_SELECT_HIERARCHY
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM DATA_SELECT_HIERARCHY .

  PERFORM CREATE_GT_HEADER.

  PERFORM CREATE_GT_ITEM.

  PERFORM SET_GRID_FIELDCATALOG_H.

  CLEAR : GS_VARIANT_H.
  GS_VARIANT_H-REPORT = SY-REPID.
  GS_VARIANT_H-HANDLE = '0001'.

  CLEAR : GS_KEYINFO_H.
  GS_KEYINFO_H-HEADER01 = 'CONNO'.
  GS_KEYINFO_H-ITEM01   = 'CONNO'.
  GS_KEYINFO_H-HEADER02 = 'NFKEY'.
  GS_KEYINFO_H-ITEM02   = 'NFKEY'.
  GS_KEYINFO_H-ITEM03   = 'REQNO'.
  GS_KEYINFO_H-ITEM04   = 'H_NO1'.


  GS_LAYOUT_H-GROUP_CHANGE_EDIT = 'X'.
  GS_LAYOUT_H-COLWIDTH_OPTIMIZE = 'X'.
  GS_LAYOUT_H-ZEBRA             = 'X'.
  GS_LAYOUT_H-DETAIL_POPUP      = 'X'.
  GS_LAYOUT_H-GET_SELINFOS      = 'X'.
  GS_LAYOUT_H-EXPAND_ALL        = 'X'.
  GS_LAYOUT_H-EXPAND_FIELDNAME  = 'EXPAND'.

  GT_SORT_H-TABNAME   = 'GT_HEADER'.
  GT_SORT_H-FIELDNAME = 'CONNO'.
  GT_SORT_H-UP        = 'X'.
  APPEND GT_SORT_H.

  GT_SORT_H-TABNAME   = 'GT_ITEM'.
  GT_SORT_H-FIELDNAME = 'CONNO'.
  GT_SORT_H-UP        = 'X'.
  APPEND GT_SORT_H.

  GT_SORT_H-TABNAME   = 'GT_ITEM'.
  GT_SORT_H-FIELDNAME = 'REQNO'.
  GT_SORT_H-UP        = 'X'.
  APPEND GT_SORT_H.

  GT_SORT_H-TABNAME   = 'GT_ITEM'.
  GT_SORT_H-FIELDNAME = 'H_NO1'.
  GT_SORT_H-UP        = 'X'.
  APPEND GT_SORT_H.

  CALL FUNCTION 'REUSE_ALV_HIERSEQ_LIST_DISPLAY'
    EXPORTING
      I_CALLBACK_PROGRAM             = SY-CPROG
      I_CALLBACK_USER_COMMAND        = 'USER_COMMAND'
      IS_LAYOUT                      = GS_LAYOUT_H
      IT_FIELDCAT                    = GT_FIELDCAT_H[]
      IT_SORT                        = GT_SORT_H[]
*      IT_EVENTS                      = GT_EVENTS_H[]
      I_TABNAME_HEADER               = 'GT_HEADER'
      I_TABNAME_ITEM                 = 'GT_ITEM'
      IS_KEYINFO                     = GS_KEYINFO_H
    TABLES
      T_OUTTAB_HEADER                = GT_HEADER
      T_OUTTAB_ITEM                  = GT_ITEM
    EXCEPTIONS
      PROGRAM_ERROR                  = 1
      OTHERS                         = 2.

  IF SY-SUBRC NE 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
          WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

ENDFORM.                    " DATA_SELECT_HIERARCHY

*&---------------------------------------------------------------------*
*&      Form  alvprn_basic
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM ALVPRN_BASIC .

* FORM문 발췌함수
  CALL FUNCTION 'REUSE_ALV_EVENTS_GET'
    EXPORTING
      I_LIST_TYPE = 0
    IMPORTING
      ET_EVENTS   = GT_EVENTS_H.

* FORM문   생성
  PERFORM  FORM_SETTING USING:
           SLIS_EV_PF_STATUS_SET  C_STATUS_SET,
           SLIS_EV_USER_COMMAND   C_USER_COMMAND,
           SLIS_EV_TOP_OF_PAGE    C_TOP_OF_PAGE.

ENDFORM.                    " alvprn_basic

*&---------------------------------------------------------------------*
*&      Form  form_setting
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_SLIS_EV_PF_STATUS_SET  text
*      -->P_C_STATUS_SET  text
*----------------------------------------------------------------------*
FORM FORM_SETTING  USING    P_COM P_FORM.

* 해당  FORM발췌
  DATA : LS_EVENT TYPE SLIS_ALV_EVENT.
  READ TABLE GT_EVENTS_H WITH KEY NAME = P_COM
                            INTO LS_EVENT.
* FORM 생성
  IF SY-SUBRC EQ 0.
    MOVE P_FORM TO LS_EVENT-FORM.
    MODIFY GT_EVENTS_H FROM LS_EVENT INDEX SY-TABIX.
  ENDIF.

ENDFORM.                    " form_setting

*&---------------------------------------------------------------------*
*&      Form  CREATE_GT_HEADER
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CREATE_GT_HEADER .

  DATA : LV_TABIX TYPE SY-TABIX.

  SELECT A~CONNO
         A~COTYP
         A~COTXT
         A~BUKRS
         A~NFCTR
         A~PRCTR
         A~VKGRP
         A~KUNNR
         A~NCUST
         A~SUJUD
         A~SALER
         A~PRATE
         A~ERDAT
         A~ERNAM
         A~PRICE
         A~WAERS
         A~CSTAT
         B~NFKEY
         B~EMENG
         B~MEINS
         INTO CORRESPONDING FIELDS OF TABLE GT_HEADER
    FROM ZNFT1000 AS A
         INNER JOIN ZNFT1001 AS B
            ON B~CONNO EQ A~CONNO
   WHERE A~BUKRS EQ P_BUKRS
     AND A~ERDAT IN S_ERDAT
     AND A~CONNO IN S_CONNO
     AND A~NFCTR IN S_NFCTR
     AND A~PRCTR IN S_PRCTR
     AND A~VKGRP IN S_VKGRP
     AND A~ERNAM IN S_ERNAM
     AND A~CSTAT IN R_CSTAT
     AND A~CSTAT NE 'D'.        " 삭제인건 제외

  IF GT_HEADER[] IS NOT INITIAL.
    CLEAR LV_TABIX.
    LOOP AT GT_HEADER.

      LV_TABIX = SY-TABIX.

*   - 회사코드
      PERFORM GET_BUKRS_DESC USING GT_HEADER-BUKRS
                                   GT_HEADER-BUKRS_NM.

*   - 사업부
      PERFORM GET_NFCTR_DESC USING GT_HEADER-BUKRS
                                   GT_HEADER-NFCTR
                                   GT_HEADER-NFCTR_NM.

*   - 손익센터
      PERFORM GET_PRCTR_DESC USING GT_HEADER-BUKRS
                                   GT_HEADER-PRCTR
                                   GT_HEADER-PRCTR_NM.

*   - 영업그룹
      PERFORM GET_VKGRP_DESC USING GT_HEADER-BUKRS
                                   GT_HEADER-VKGRP
                                   GT_HEADER-VKGRP_NM.

*   - 고객
      IF GT_HEADER-NCUST IS NOT INITIAL AND GT_HEADER-NCUST EQ SPACE.
        GT_HEADER-KUNNR_NM = GT_HEADER-NCUST.
      ELSE.
        PERFORM GET_KUNNR_DESC USING GT_HEADER-KUNNR
                                     GT_HEADER-KUNNR_NM.
        GT_HEADER-KUNNR_NM = GT_HEADER-KUNNR_NM.
      ENDIF.

*   - 계약유형
      PERFORM DOMAIN_VALUE_GET USING 'ZCOTYP'
                                     GT_HEADER-COTYP
                                     GT_HEADER-COTYP_NM.

*   - 계약상태
      IF GT_HEADER-CSTAT IS NOT INITIAL.
        PERFORM DOMAIN_VALUE_GET USING 'ZCSTAT'
                                       GT_HEADER-CSTAT
                                       GT_HEADER-CSTAT_NM.
      ENDIF.

*   - 비철구분
      IF GT_HEADER-NFKEY IS NOT INITIAL.
        PERFORM DOMAIN_VALUE_GET USING 'ZNFKEY_1'
                                       GT_HEADER-NFKEY
                                       GT_HEADER-NFKEY_NM.
      ENDIF.

*   - 가격구분 & 비철 수주가
      IF GT_HEADER-NFKEY IS NOT INITIAL.
        PERFORM PRICE_CLASSIFICATION USING GT_HEADER-CONNO
                                           GT_HEADER-NFKEY
                                           GT_HEADER-PRIND
                                           GT_HEADER-SUJUP
                                           GV_ERROR.
      ENDIF.

      MODIFY GT_HEADER INDEX LV_TABIX.

    ENDLOOP.

  ENDIF.

  IF GT_HEADER IS NOT INITIAL.
    SORT GT_HEADER BY CONNO.
  ENDIF.

ENDFORM.                    " CREATE_GT_HEADER
*&---------------------------------------------------------------------*
*&      Form  CREATE_GT_ITEM
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CREATE_GT_ITEM .

  DATA LV_TABIX TYPE SY-TABIX.

  CHECK GT_HEADER[] IS NOT INITIAL.

  SELECT C~CONNO
         C~REQNO
         C~H_NO1
         C~NFKEY
         C~ERDAT AS ERDAT_R
         C~EMENG AS EMENG_R
         C~MEINS AS MEINS_R
         C~ENDMM
         C~BY_SL
         C~BIGO4
         INTO CORRESPONDING FIELDS OF TABLE GT_ITEM
    FROM ZNFT1011 AS C
         FOR ALL ENTRIES IN GT_HEADER
   WHERE C~CONNO EQ GT_HEADER-CONNO
     AND C~NFKEY EQ GT_HEADER-NFKEY.

  IF GT_ITEM[] IS NOT INITIAL.
    LOOP AT GT_ITEM.

      LV_TABIX = SY-TABIX.

*   - 비철구분
      IF GT_ITEM-NFKEY IS NOT INITIAL.
        PERFORM DOMAIN_VALUE_GET USING 'ZNFKEY_1'
                                       GT_ITEM-NFKEY
                                       GT_ITEM-NFKEY_NM.
      ENDIF.

*   - Buy-Sell 구분
      IF GT_ITEM-BY_SL IS NOT INITIAL.
        PERFORM DOMAIN_VALUE_GET USING 'ZBY_SL'
                                       GT_ITEM-BY_SL
                                       GT_ITEM-BY_SL_NM.
      ENDIF.

      MODIFY GT_ITEM FROM GT_ITEM INDEX LV_TABIX.

    ENDLOOP.

  ENDIF.

  IF GT_ITEM IS NOT INITIAL.
    SORT GT_ITEM BY CONNO.
  ENDIF.

ENDFORM.                    " CREATE_GT_ITEM
