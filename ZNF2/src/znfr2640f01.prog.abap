*&---------------------------------------------------------------------*
*&  Include           ZNFR2640F01
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
*  GS_SORT-FIELDNAME = 'BUKRS'.
**  GS_SORT-UP = 'X'.
**  GS_SORT-COMP = 'X'.
**  GS_SORT-SUBTOT = 'X'.
*  APPEND GS_SORT TO GT_SORT.
*
*  GS_SORT-SPOS = 2.
*  GS_SORT-FIELDNAME = 'NFCTR'.
**  GS_SORT-UP = 'X'.
**  GS_SORT-COMP = 'X'.
**  GS_SORT-SUBTOT = 'X'.
*  APPEND GS_SORT TO GT_SORT.
*
*  GS_SORT-SPOS = 3.
*  GS_SORT-FIELDNAME = 'PRCTR'.
**  GS_SORT-UP = 'X'.
**  GS_SORT-COMP = 'X'.
**  GS_SORT-SUBTOT = 'X'.
*  APPEND GS_SORT TO GT_SORT.
*
*  GS_SORT-SPOS = 4.
*  GS_SORT-FIELDNAME = 'VKGRP'.
**  GS_SORT-UP = 'X'.
**  GS_SORT-COMP = 'X'.
**  GS_SORT-SUBTOT = 'X'.
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
    'CHECK'    '선택'             '5'    'C'   ' '     ,
    'BUKRS'    '회사코드'         '10'   'C'   ' '     ,
    'BUKRS_NM' '회사코드'         '10'   'C'   ' '     ,
    'NFCTR'    '사업부'           '10'   'C'   'ALPHA' ,
    'NFCTR_NM' '사업부명'         '10'   'L'   ' '     ,
    'PRCTR'    '손익센터'         '10'   'C'   'ALPHA' ,
    'PRCTR_NM' '손익센터명'       '10'   'L'   ' '     ,
    'VKGRP'    '영업그룹'         '10'   'C'   'ALPHA' ,
    'VKGRP_NM' '영업그룹명'       '10'   'L'   ' '     ,
    'CONNO'    '계약번호'         '10'   'L'   ' '     ,
    'COTXT'    '계약명'           '10'   'L'   ' '     ,
    'KUNNR'    '고  객'           '10'   'C'   'ALPHA' ,
    'NCUST'    '고객명'           '20'   'L'   ' '     ,
    'NFKEY'    '비철구분'         '10'   'C'   ' '     ,
    'EMENG'    '요청수량'         '10'   'R'   ' '     ,
    'MEINS'    '단위'             '10'   'C'   ' '     ,
    'CU_V_Q'   '판매오더 비철량'  '10'   'R'   ' '     ,
    'CU_N_Q'   '선물집행 비철량'  '10'   'R'   ' '     .

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
    WHEN 'BUKRS_NM'.
      GS_FIELDCAT-NO_OUT     = 'X'.
    WHEN 'EMENG' OR 'CU_V_Q' OR 'CU_N_Q'.
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
*&      Form  CREATE_OBJECT_D
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CREATE_OBJECT_D .

* Create Object : GRF_CONTAINER_D
  CREATE OBJECT GRF_CONTAINER_D
    EXPORTING
      CONTAINER_NAME = GRF_CONTAINER_NAME_D.

* Create Object : GRF_GRID_D
  CREATE OBJECT GRF_GRID_D
    EXPORTING
      I_PARENT      = GRF_CONTAINER_D
      I_APPL_EVENTS = 'X'.

ENDFORM.                    " CREATE_OBJECT_D

*&---------------------------------------------------------------------*
*&      Form  EXCLUDE_TB_FUNCTIONS_D
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_GT_EXCLUDE  text
*----------------------------------------------------------------------*
FORM EXCLUDE_TB_FUNCTIONS_D CHANGING PT_EXCLUDE TYPE UI_FUNCTIONS.
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
*&      Form  SET_GRID_LAYOUT_D
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SET_GRID_LAYOUT_D .

  GS_LAYOUT_D-SEL_MODE   = 'A'.
  GS_LAYOUT_D-ZEBRA      = 'X'.
  GS_LAYOUT_D-CWIDTH_OPT = 'X'.
  GS_LAYOUT_D-STYLEFNAME = 'CELLTAB'.
  GS_LAYOUT_D-NO_ROWINS  = 'X'.

ENDFORM.                    " SET_GRID_LAYOUT_D
*&---------------------------------------------------------------------*
*&      Form  SET_GRID_SORT_D
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SET_GRID_SORT_D .

  CLEAR : GS_SORT_D, GT_SORT_D.
  REFRESH GT_SORT_D.

*  GS_SORT-SPOS = 1.
*  GS_SORT-FIELDNAME = 'BUKRS'.
**  GS_SORT-UP = 'X'.
**  GS_SORT-COMP = 'X'.
**  GS_SORT-SUBTOT = 'X'.
*  APPEND GS_SORT TO GT_SORT.
*
*  GS_SORT-SPOS = 2.
*  GS_SORT-FIELDNAME = 'NFCTR'.
**  GS_SORT-UP = 'X'.
**  GS_SORT-COMP = 'X'.
**  GS_SORT-SUBTOT = 'X'.
*  APPEND GS_SORT TO GT_SORT.
*
*  GS_SORT-SPOS = 3.
*  GS_SORT-FIELDNAME = 'PRCTR'.
**  GS_SORT-UP = 'X'.
**  GS_SORT-COMP = 'X'.
**  GS_SORT-SUBTOT = 'X'.
*  APPEND GS_SORT TO GT_SORT.
*
*  GS_SORT-SPOS = 4.
*  GS_SORT-FIELDNAME = 'VKGRP'.
**  GS_SORT-UP = 'X'.
**  GS_SORT-COMP = 'X'.
**  GS_SORT-SUBTOT = 'X'.
*  APPEND GS_SORT TO GT_SORT.

ENDFORM.                    " SET_GRID_SORT_D
*&---------------------------------------------------------------------*
*&      Form  SET_GRID_FIELDCATALOG_D
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SET_GRID_FIELDCATALOG_D .

  IF GV_CODE EQ 'ORDER_V'.
    PERFORM SET_FIELDCAT_D USING:
      'VBELN'     '판매오더'   '10'   'C'   'ALPHA' ,
      'POSNR'     '순번'       '10'   'C'   ' '     ,
      'MATNR'     '자재코드'   '10'   'C'   'ALPHA' ,
      'ARKTX'     '자재내역'   '10'   'L'   ' '     ,
      'CU_V_Q'    '비철량'     '10'   'C'   ' '     ,
      'MEINS'     '단위'       '10'   'L'   ' '     ,
      'CONNO'     '계약번호'   '10'   'C'   'ALPHA' ,
      'COTXT'     '계약명'     '10'   'L'   ' '     .
  ELSE.
    PERFORM SET_FIELDCAT_D USING:
      'NFUTN'     '신규집행번호'     '10'     'C'    ' '     ,
*     --------------------------------------------------------     *
      'RUDAT'     '신규집행일'       '10'     'C'    ' '     ,
      'FCM'       'FCM(신규)'        '10'     'C'    'ALPHA' ,
      'FCM_NM'    'FCM(신규)'        '10'     'L'    ' '     ,
      'NFKEY'     '비철구분(신규)'   '10'     'C'    ' '     ,
      'BY_SL'     'Buy-Sell(신규)'   '10'     'C'    ' '     ,
      'BYSL_NM'  'Buy-Sell(신규)'    '10'     'C'    ' '     ,
      'ENDAT'     '만기일(신규)'     '10'     'C'    ' '     ,
      'MITYP'     '집행유형(신규)'   '10'     'C'    ' '     ,
      'MISPD'     'Spread(신규)'     '10'     'R'    ' '     ,
      'MIMON'     '기준월(신규)'     '10'     'C'    ' '     ,
      'PRICE'     '집행단가(신규)'   '15'     'R'    ' '     ,
      'WAERS'     '통화(신규)'       '5'      'C'    ' '     ,
      'EMENG'     '집행수량(신규)'   '14'     'R'    ' '     ,
      'MEINS'     '단위(신규)'       '10'     'C'    ' '     ,
*     --------------------------------------------------------     *
      'RUDAT1'    '집행일(청산)'     '10'     'C'    ' '     ,
      'FCM1'      'FCM(청산)'        '10'     'C'    'ALPHA' ,
      'FCM_NM1'   'FCM(청산)'        '10'     'L'    ' '     ,
      'NFKEY1'    '비철구분(청산)'   '10'     'C'    ' '     ,
      'BY_SL1'    'Buy-Sell(청산)'   '10'     'C'    ' '     ,
      'BYSL_NM1'  'Buy-Sell(청산)'   '10'     'C'    ' '     ,
      'ENDAT1'    '만기일(청산)'     '10'     'C'    ' '     ,
      'MITYP1'    '집행유형(청산)'   '10'     'C'    ' '     ,
      'MISPD1'    'Spread(청산)'     '10'     'R'    ' '     ,
      'MIMON1'    '기준월(청산)'     '10'     'C'    ' '     ,
      'PRICE1'    '집행단가(청산)'   '15'     'R'    ' '     ,
      'WAERS1'    '통화(청산)'       '5'      'C'    ' '     ,
      'EMENG1'    '집행수량(청산)'   '14'     'R'    ' '     ,
      'MEINS1'    '단위(청산)'       '10'     'C'    ' '     .
  ENDIF.


ENDFORM.                    " SET_GRID_FIELDCATALOG_D
*&---------------------------------------------------------------------*
*&      Form  SET_FIELDCAT_D
*&---------------------------------------------------------------------*
FORM SET_FIELDCAT_D  USING  P_FIELDNAME
                            P_COLTEXT
                            P_OUTPUTLEN
                            P_JUST
                            P_CONVEXIT.

  CLEAR GS_FIELDCAT_D.

  GS_FIELDCAT_D-FIELDNAME  = P_FIELDNAME .
  GS_FIELDCAT_D-COLTEXT    = P_COLTEXT   .
  GS_FIELDCAT_D-OUTPUTLEN  = P_OUTPUTLEN .
  GS_FIELDCAT_D-JUST       = P_JUST      .
  GS_FIELDCAT_D-CONVEXIT   = P_CONVEXIT  .

  CASE P_FIELDNAME.
    WHEN 'CHECK'.
      GS_FIELDCAT_D-CHECKBOX   = 'X'.
      GS_FIELDCAT_D-EDIT       = 'X'.
    WHEN 'BUKRS' OR 'BY_SL' OR 'BY_SL1'.
      GS_FIELDCAT_D-NO_OUT     = 'X'.
    WHEN 'EMENG' OR 'CU_V_Q' OR 'CU_N_Q'.
      GS_FIELDCAT_D-QFIELDNAME = 'MEINS'.
  ENDCASE.

  APPEND GS_FIELDCAT_D TO GT_FIELDCAT_D.

ENDFORM.                    " SET_FIELDCAT_D

*&---------------------------------------------------------------------*
*&      Form  SET_CELL_ATTRIBUTE_D
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SET_CELL_ATTRIBUTE_D .

* 각 셀의 특성 제어
  DATA : LT_CELLTAB TYPE LVC_T_STYL,
         L_INDEX    TYPE I.

  CASE GV_CODE.
    WHEN 'ORDER_V'.
      LOOP AT GT_OUTTAB_V INTO GS_OUTTAB_V.
        L_INDEX = SY-TABIX.
        REFRESH LT_CELLTAB.
        CLEAR GS_OUTTAB_V-CELLTAB.
        INSERT LINES OF LT_CELLTAB INTO TABLE GS_OUTTAB_V-CELLTAB.
        MODIFY GT_OUTTAB_V FROM GS_OUTTAB_V INDEX L_INDEX.
      ENDLOOP.
    WHEN 'ORDER_Z'.
      LOOP AT GT_OUTTAB_Z INTO GS_OUTTAB_Z.
        L_INDEX = SY-TABIX.
        REFRESH LT_CELLTAB.
        CLEAR GS_OUTTAB_Z-CELLTAB.
        INSERT LINES OF LT_CELLTAB INTO TABLE GS_OUTTAB_Z-CELLTAB.
        MODIFY GT_OUTTAB_Z FROM GS_OUTTAB_Z INDEX L_INDEX.
      ENDLOOP.
  ENDCASE.

ENDFORM.                    " SET_CELL_ATTRIBUTE_D

*&---------------------------------------------------------------------*
*&      Form  SET_EVENT_HANDLER_D
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SET_EVENT_HANDLER_D .

* DATA가 변경될 경우
  CALL METHOD GRF_GRID_D->REGISTER_EDIT_EVENT
    EXPORTING
      I_EVENT_ID = CL_GUI_ALV_GRID=>MC_EVT_ENTER.

  CREATE OBJECT GRF_EVENT_RECEIVER_D.
  SET HANDLER :
    GRF_EVENT_RECEIVER_D->HANDLE_DOUBLE_CLICK FOR GRF_GRID_D.


ENDFORM.                    " SET_EVENT_HANDLER_D

*&---------------------------------------------------------------------*
*&      Form  SET_F4_HELP_REGISTER_D
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SET_F4_HELP_REGISTER_D .

  CLEAR   : GS_F4_D.
  REFRESH : GT_F4_D.

* FieldName별 소트해서 APPEND
*  GS_F4_D-FIELDNAME = 'CONNO'.
*  GS_F4_D-REGISTER  = 'X'.
*  APPEND GS_F4_D TO GT_F4_D.
*
*  CALL METHOD GRF_GRID_D->REGISTER_F4_FOR_FIELDS
*    EXPORTING
*      IT_F4 = GT_F4_D.

ENDFORM.                    " SET_F4_HELP_REGISTER_D

*&---------------------------------------------------------------------*
*&      Form  SET_TABLE_FOR_FIRST_DISPLAY_D
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SET_TABLE_FOR_FIRST_DISPLAY_D .

  GS_VARIANT_D-REPORT = SY-REPID.

  CASE GV_CODE.
    WHEN 'ORDER_V'.
      GS_VARIANT_D-HANDLE = '0002'.

      CALL METHOD GRF_GRID_D->SET_TABLE_FOR_FIRST_DISPLAY
        EXPORTING
          IS_VARIANT                    = GS_VARIANT_D
          IS_LAYOUT                     = GS_LAYOUT_D
          I_SAVE                        = 'A'
          I_DEFAULT                     = 'X'
          IT_TOOLBAR_EXCLUDING          = GT_EXCLUDE_D
        CHANGING
          IT_FIELDCATALOG               = GT_FIELDCAT_D
          IT_SORT                       = GT_SORT_D
          IT_OUTTAB                     = GT_OUTTAB_V
          IT_FILTER                     = GT_FILTER_D
        EXCEPTIONS
          INVALID_PARAMETER_COMBINATION = 1
          PROGRAM_ERROR                 = 2
          TOO_MANY_LINES                = 3
          OTHERS                        = 4.
    WHEN 'ORDER_Z'.
      GS_VARIANT_D-HANDLE = '0003'.

      CALL METHOD GRF_GRID_D->SET_TABLE_FOR_FIRST_DISPLAY
        EXPORTING
          IS_VARIANT                    = GS_VARIANT_D
          IS_LAYOUT                     = GS_LAYOUT_D
          I_SAVE                        = 'A'
          I_DEFAULT                     = 'X'
          IT_TOOLBAR_EXCLUDING          = GT_EXCLUDE_D
        CHANGING
          IT_FIELDCATALOG               = GT_FIELDCAT_D
          IT_SORT                       = GT_SORT_D
          IT_OUTTAB                     = GT_OUTTAB_Z
          IT_FILTER                     = GT_FILTER_D
        EXCEPTIONS
          INVALID_PARAMETER_COMBINATION = 1
          PROGRAM_ERROR                 = 2
          TOO_MANY_LINES                = 3
          OTHERS                        = 4.
  ENDCASE.

  CALL METHOD GRF_GRID_D->REGISTER_EDIT_EVENT
    EXPORTING
      I_EVENT_ID = CL_GUI_ALV_GRID=>MC_EVT_MODIFIED.

ENDFORM.                    " SET_TABLE_FOR_FIRST_DISPLAY_D

*&---------------------------------------------------------------------*
*&      Form  DATA_SELECT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM DATA_SELECT .

  DATA: LV_TABIX TYPE SY-TABIX.

  SELECT Z1~BUKRS
         Z1~NFCTR
         Z1~PRCTR
         Z1~VKGRP
         Z1~CONNO
         Z1~COTXT
         Z1~KUNNR
         Z1~NCUST
         Z2~NFKEY
         Z2~EMENG
         Z2~MEINS
         INTO CORRESPONDING FIELDS OF TABLE GT_OUTTAB
    FROM ZNFT1000 AS Z1
         INNER JOIN ZNFT1001 AS Z2
            ON Z2~CONNO EQ Z1~CONNO
         INNER JOIN ZNFT1011 AS Z3
            ON Z3~CONNO EQ Z2~CONNO AND Z3~NFKEY EQ Z2~NFKEY
         INNER JOIN ZNFT1020 AS Z4
            ON Z4~REQNO EQ Z3~REQNO AND Z4~H_NO1 EQ Z3~H_NO1
   WHERE Z1~BUKRS EQ P_BUKRS
     AND Z1~NFCTR IN S_NFCTR
     AND Z1~PRCTR IN S_PRCTR
     AND Z1~VKGRP IN S_VKGRP
     AND Z2~NFKEY IN S_NFKEY
     AND Z1~CSTAT NE 'D'
     AND Z1~CONNO IN S_CONNO
     AND Z1~ERDAT IN S_ERDAT
     AND Z4~NFUTN IN S_NFUTN
     AND Z4~RUDAT IN S_RUDAT.

  IF SY-SUBRC EQ 0.
    SORT GT_OUTTAB BY BUKRS NFCTR PRCTR VKGRP CONNO
                      COTXT KUNNR NCUST NFKEY.
    DELETE ADJACENT DUPLICATES FROM GT_OUTTAB.
    CLEAR: LV_TABIX, GS_OUTTAB.
    LOOP AT GT_OUTTAB INTO GS_OUTTAB.

      LV_TABIX = SY-TABIX.

*     회사코드
      IF GS_OUTTAB-BUKRS IS NOT INITIAL.
        PERFORM GET_BUKRS_DESC USING GS_OUTTAB-BUKRS
                                     GS_OUTTAB-BUKRS_NM.
      ENDIF.

*     고객명
      IF GS_OUTTAB-KUNNR IS NOT INITIAL.
        PERFORM GET_KUNNR_DESC USING GS_OUTTAB-KUNNR
                                     GS_OUTTAB-NCUST.
      ENDIF.

*     사업부명
      PERFORM GET_NFCTR_DESC USING P_BUKRS
                                   GS_OUTTAB-NFCTR
                                   GS_OUTTAB-NFCTR_NM.

*     손익센터명
      PERFORM GET_PRCTR_DESC USING GV_KOKRS
                                   GS_OUTTAB-PRCTR
                                   GS_OUTTAB-PRCTR_NM.

*     영업그룹명
      PERFORM GET_VKGRP_DESC USING GV_KOKRS
                                   GS_OUTTAB-VKGRP
                                   GS_OUTTAB-VKGRP_NM.

*     판매오더 CU량 조회 (계약번호별)
      PERFORM GET_SD_CU_QTY USING GS_OUTTAB-CONNO
                                  GS_OUTTAB-NFKEY
                                  GS_OUTTAB-CU_V_Q.

*     선물집행 CU량 조회 (계약번호별)
      PERFORM GET_NF_CU_QTY USING GS_OUTTAB-BUKRS
                                  GS_OUTTAB-CONNO
                                  GS_OUTTAB-NFKEY
                                  GS_OUTTAB-CU_N_Q.


      MODIFY GT_OUTTAB FROM GS_OUTTAB INDEX LV_TABIX.
      CLEAR: LV_TABIX, GS_OUTTAB.
    ENDLOOP.

  ELSE.

  ENDIF.

ENDFORM.                    " DATA_SELECT

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

  LOOP AT P_DATA_CHANGED->MT_GOOD_CELLS INTO LS_MOD_CELLS.
    LV_INDEX = LS_MOD_CELLS-ROW_ID.

*   Data 가공용 Structure
    READ TABLE GT_OUTTAB INTO GS_OUTTAB INDEX LV_INDEX.

    IF SY-SUBRC EQ 0.
      CASE LS_MOD_CELLS-FIELDNAME.
        WHEN 'CHECK'.
          IF LS_MOD_CELLS-VALUE EQ 'X'.
            GS_OUTTAB-CHECK = 'X'.
            MODIFY GT_OUTTAB FROM GS_OUTTAB INDEX LV_INDEX
                             TRANSPORTING CHECK.
          ELSE.
            GS_OUTTAB-CHECK = SPACE.
            MODIFY GT_OUTTAB FROM GS_OUTTAB INDEX LV_INDEX
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

  IF SY-SUBRC EQ 0.
    CASE P_E_COLUMN.
      WHEN 'CONNO'.
        CLEAR GS_OUTTAB.
        READ TABLE GT_OUTTAB INTO GS_OUTTAB
            INDEX P_ES_ROW_NO-ROW_ID.

        IF NOT GS_OUTTAB-CONNO IS INITIAL.
          SET PARAMETER ID 'ZNFCON' FIELD GS_OUTTAB-CONNO.
          CALL TRANSACTION 'ZNF2M2003' AND SKIP FIRST SCREEN.
        ELSE.
          MESSAGE '계약번호가 존재하지 않습니다.'
             TYPE 'S' DISPLAY LIKE 'E'.
        ENDIF.
      WHEN 'NFUTN'.
        CLEAR GS_OUTTAB_Z.
        READ TABLE GT_OUTTAB_Z INTO GS_OUTTAB_Z
             INDEX P_ES_ROW_NO-ROW_ID.

        IF NOT GS_OUTTAB_Z-NFUTN IS INITIAL.
          PERFORM DISPLAY_FUTRUES_HISTORY USING GS_OUTTAB_Z-NFUTN.
        ELSE.
          MESSAGE '선물집행번호가 존재하지 않습니다.'
             TYPE 'S' DISPLAY LIKE 'E'.
        ENDIF.
      WHEN 'VBELN'.
        READ TABLE GT_OUTTAB_V INTO GS_OUTTAB_V
             INDEX P_ES_ROW_NO-ROW_ID.
        IF SY-SUBRC = 0 AND GS_OUTTAB_V-VBELN IS NOT INITIAL.
          SET PARAMETER ID 'AUN' FIELD GS_OUTTAB_V-VBELN.
          CALL TRANSACTION 'VA03' AND SKIP FIRST SCREEN.
        ENDIF.
    ENDCASE.
  ENDIF.

ENDFORM.                    " ALV_EVENT_DOUBLE_CLICK

*&---------------------------------------------------------------------*
*&      Form  DISPLAY_FUTRUES_HISTORY
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM DISPLAY_FUTRUES_HISTORY USING PV_NFUTN.

  DATA: LT_RSPAR LIKE RSPARAMS OCCURS 0 WITH HEADER LINE.

  CLEAR   : LT_RSPAR.  REFRESH : LT_RSPAR.

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

ENDFORM.                    " DISPLAY_FUTRUES_HISTORY

*&---------------------------------------------------------------------*
*&      Form  F4HELP_NFCTR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM F4HELP_NFCTR  USING    PV_NFCTR.

  CLEAR   : SELECTFIELD, SELECT_VALUE, LD_TABIX,
            IT_FIELDS, SCR_FIELDS, FELD_TABLE, GT_NFCTR.
  REFRESH : IT_FIELDS, SCR_FIELDS, FELD_TABLE, GT_NFCTR.

*___화면상의 회사코드를 읽는다.
  SCR_FIELDS-FIELDNAME = 'P_BUKRS'.
  APPEND SCR_FIELDS.

  CALL FUNCTION 'DYNP_VALUES_READ'
    EXPORTING
      DYNAME     = 'ZNFR2640'
      DYNUMB     = '1000'
    TABLES
      DYNPFIELDS = SCR_FIELDS.

  READ TABLE SCR_FIELDS WITH KEY FIELDNAME = 'P_BUKRS'.
  P_BUKRS = SCR_FIELDS-FIELDVALUE.

  IF P_BUKRS IS INITIAL.
    MESSAGE S003 DISPLAY LIKE 'E'
       WITH '회사코드를 입력하시기 바랍니다.'.
    EXIT.
  ENDIF.

  SELECT NFCTR
         NTEXT
    INTO TABLE GT_NFCTR
    FROM ZNFT0005
   WHERE BUKRS = P_BUKRS.   "회사코드

  IF SY-SUBRC <> 0.
    MESSAGE S003 DISPLAY LIKE 'E'
       WITH '회사코드' P_BUKRS
            '에 해당하는 사업부가 없습니다.'.
    EXIT.
  ENDIF.

*___아래 부분이 F4를 눌렀을 때, Hit List를 보여준다.
  IT_FIELDS-TABNAME    = 'ZNFT0005'.
  IT_FIELDS-FIELDNAME  = 'NFCTR'.
  IT_FIELDS-SELECTFLAG = 'X'.
  APPEND IT_FIELDS.

  IT_FIELDS-TABNAME    = 'ZNFT0005'.
  IT_FIELDS-FIELDNAME  = 'NTEXT'.
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
      FULL_TABLE                   = GT_NFCTR
    EXCEPTIONS
      FULL_TABLE_EMPTY             = 1
      NO_TABLESTRUCTURE_GIVEN      = 2
      NO_TABLEFIELDS_IN_DICTIONARY = 3
      MORE_THEN_ONE_SELECTFIELD    = 4
      NO_SELECTFIELD               = 5
      OTHERS                       = 6.

  CHECK NOT LD_TABIX IS INITIAL.
  READ TABLE GT_NFCTR INDEX LD_TABIX.
  IF SY-SUBRC = 0.
    PV_NFCTR = GT_NFCTR-NFCTR.
  ENDIF.

ENDFORM.                    " F4HELP_NFCTR

*&---------------------------------------------------------------------*
*&      Form  F4HELP_PRCTR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM F4HELP_PRCTR  USING    PV_PRCTR.
  RANGES: LR_NFCTR  FOR  ZNFT1000-NFCTR.

  CLEAR   : SELECTFIELD, SELECT_VALUE, LD_TABIX,
            IT_FIELDS, SCR_FIELDS, FELD_TABLE, GT_PRCTR,
             LR_NFCTR.
  REFRESH : IT_FIELDS, SCR_FIELDS, FELD_TABLE, GT_PRCTR,
            LR_NFCTR.

  LR_NFCTR[] = S_NFCTR[].

*___화면상의 데이터를 읽는다.
  SCR_FIELDS-FIELDNAME = 'P_BUKRS'.
  APPEND SCR_FIELDS.

  SCR_FIELDS-FIELDNAME = 'S_NFCTR-LOW'.
  APPEND SCR_FIELDS.

  SCR_FIELDS-FIELDNAME = 'S_NFCTR-HIGH'.
  APPEND SCR_FIELDS.

  CALL FUNCTION 'DYNP_VALUES_READ'
    EXPORTING
      DYNAME     = 'ZNFR2640'
      DYNUMB     = '1000'
    TABLES
      DYNPFIELDS = SCR_FIELDS.

  LOOP AT SCR_FIELDS.
    CASE SCR_FIELDS-FIELDNAME.
      WHEN 'P_BUKRS'.
        P_BUKRS      = SCR_FIELDS-FIELDVALUE.
      WHEN 'S_NFCTR-LOW'.
        LR_NFCTR-LOW  = SCR_FIELDS-FIELDVALUE.
        PERFORM CONVERSION_EXIT_ALPHA USING 'I' LR_NFCTR-LOW.
      WHEN 'S_NFCTR-HIGH'.
        LR_NFCTR-HIGH = SCR_FIELDS-FIELDVALUE.
        PERFORM CONVERSION_EXIT_ALPHA USING 'I' LR_NFCTR-HIGH.
    ENDCASE.
  ENDLOOP.

  READ TABLE LR_NFCTR INDEX 1 TRANSPORTING SIGN.
  IF SY-SUBRC = 0.
    IF LR_NFCTR-LOW  IS NOT INITIAL OR
       LR_NFCTR-HIGH IS NOT INITIAL.
      IF LR_NFCTR-HIGH IS NOT INITIAL.
        LR_NFCTR-OPTION = 'BT'.
      ELSE.
        LR_NFCTR-OPTION = 'EQ'.
      ENDIF.

      MODIFY LR_NFCTR INDEX 1.
    ELSE.
      DELETE LR_NFCTR INDEX 1.
    ENDIF.
  ELSE.
    IF LR_NFCTR-LOW  IS NOT INITIAL OR
       LR_NFCTR-HIGH IS NOT INITIAL.
      IF LR_NFCTR-HIGH IS NOT INITIAL.
        LR_NFCTR-SIGN   = 'I'.
        LR_NFCTR-OPTION = 'BT'.
        APPEND LR_NFCTR.
      ELSE.
        LR_NFCTR-SIGN   = 'I'.
        LR_NFCTR-OPTION = 'EQ'.
        APPEND LR_NFCTR.
      ENDIF.
    ENDIF.
  ENDIF.

  SELECT PRCTR
*         PTEXT
    INTO TABLE GT_PRCTR
    FROM ZNFT0004
   WHERE KOKRS   =  P_BUKRS   "관리회계영역
     AND NFCTR   IN LR_NFCTR  "사업부
     AND BDATU  >=  SY-DATLO  "효력만료일
     AND CFACTIV =  'X'.      "선물요청(활성)

  IF SY-SUBRC EQ 0.
    LOOP AT GT_PRCTR.
      PERFORM GET_PRCTR_DESC USING P_BUKRS
                                   GT_PRCTR-PRCTR
                                   GT_PRCTR-PTEXT.

      MODIFY GT_PRCTR.
    ENDLOOP.
  ELSE.
    MESSAGE S003 DISPLAY LIKE 'E'
       WITH '손익센터가 없습니다.'.
    EXIT.
  ENDIF.

*___아래 부분이 F4를 눌렀을 때, Hit List를 보여준다.
  IT_FIELDS-TABNAME    = 'ZNFT0004'.
  IT_FIELDS-FIELDNAME  = 'PRCTR'.
  IT_FIELDS-SELECTFLAG = 'X'.
  APPEND IT_FIELDS.

  IT_FIELDS-TABNAME    = 'ZNFT0004'.
  IT_FIELDS-FIELDNAME  = 'PTEXT'.
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
      FULL_TABLE                   = GT_PRCTR
    EXCEPTIONS
      FULL_TABLE_EMPTY             = 1
      NO_TABLESTRUCTURE_GIVEN      = 2
      NO_TABLEFIELDS_IN_DICTIONARY = 3
      MORE_THEN_ONE_SELECTFIELD    = 4
      NO_SELECTFIELD               = 5
      OTHERS                       = 6.

  CHECK NOT LD_TABIX IS INITIAL.
  READ TABLE GT_PRCTR INDEX LD_TABIX.
  IF SY-SUBRC = 0.
    PV_PRCTR = GT_PRCTR-PRCTR.
  ENDIF.

ENDFORM.                    " F4HELP_PRCTR

*&---------------------------------------------------------------------*
*&      Form  F4HELP_VKGRP
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM F4HELP_VKGRP  USING    PV_VKGRP.
  RANGES: LR_PRCTR  FOR  ZNFT1000-PRCTR.

  CLEAR   : SELECTFIELD, SELECT_VALUE, LD_TABIX,
            IT_FIELDS, SCR_FIELDS, FELD_TABLE, GT_VKGRP,
            LR_PRCTR.
  REFRESH : IT_FIELDS, SCR_FIELDS, FELD_TABLE, GT_VKGRP,
            LR_PRCTR.

  LR_PRCTR[] = S_PRCTR[].

*___화면상의 데이터를 읽는다.
  SCR_FIELDS-FIELDNAME = 'P_BUKRS'.
  APPEND SCR_FIELDS.

  SCR_FIELDS-FIELDNAME = 'S_PRCTR-LOW'.
  APPEND SCR_FIELDS.

  SCR_FIELDS-FIELDNAME = 'S_PRCTR-HIGH'.
  APPEND SCR_FIELDS.

  CALL FUNCTION 'DYNP_VALUES_READ'
    EXPORTING
      DYNAME     = 'ZNFR2640'
      DYNUMB     = '1000'
    TABLES
      DYNPFIELDS = SCR_FIELDS.

  LOOP AT SCR_FIELDS.
    CASE SCR_FIELDS-FIELDNAME.
      WHEN 'P_BUKRS'.
        P_BUKRS       = SCR_FIELDS-FIELDVALUE.
      WHEN 'S_PRCTR-LOW'.
        LR_PRCTR-LOW  = SCR_FIELDS-FIELDVALUE.
        PERFORM CONVERSION_EXIT_ALPHA USING 'I' LR_PRCTR-LOW.
      WHEN 'S_PRCTR-HIGH'.
        LR_PRCTR-HIGH = SCR_FIELDS-FIELDVALUE.
        PERFORM CONVERSION_EXIT_ALPHA USING 'I' LR_PRCTR-HIGH.
    ENDCASE.
  ENDLOOP.

  READ TABLE LR_PRCTR INDEX 1 TRANSPORTING SIGN.
  IF SY-SUBRC = 0.
    IF LR_PRCTR-LOW  IS NOT INITIAL OR
       LR_PRCTR-HIGH IS NOT INITIAL.
      IF LR_PRCTR-HIGH IS NOT INITIAL.
        LR_PRCTR-OPTION = 'BT'.
      ELSE.
        LR_PRCTR-OPTION = 'EQ'.
      ENDIF.

      MODIFY LR_PRCTR INDEX 1.
    ELSE.
      DELETE LR_PRCTR INDEX 1.
    ENDIF.

  ELSE.
    IF LR_PRCTR-LOW  IS NOT INITIAL OR
       LR_PRCTR-HIGH IS NOT INITIAL.
      IF LR_PRCTR-HIGH IS NOT INITIAL.
        LR_PRCTR-SIGN   = 'I'.
        LR_PRCTR-OPTION = 'BT'.
        APPEND LR_PRCTR.
      ELSE.
        LR_PRCTR-SIGN   = 'I'.
        LR_PRCTR-OPTION = 'EQ'.
        APPEND LR_PRCTR.
      ENDIF.
    ENDIF.
  ENDIF.

  SELECT VKGRP
*         VTEXT
    INTO TABLE GT_VKGRP
    FROM ZNFT0003
   WHERE KOKRS =  P_BUKRS    "회사코드
     AND PRCTR IN LR_PRCTR.  "손익센터

  IF SY-SUBRC EQ 0.
    LOOP AT GT_VKGRP.
      PERFORM GET_VKGRP_DESC USING P_BUKRS
                                   GT_VKGRP-VKGRP
                                   GT_VKGRP-VTEXT.

      MODIFY GT_VKGRP.
    ENDLOOP.
  ELSE.
    MESSAGE S003 DISPLAY LIKE 'E'
       WITH '사업부가 없습니다.'.
    EXIT.
  ENDIF.

*___아래 부분이 F4를 눌렀을 때, Hit List를 보여준다.
  IT_FIELDS-TABNAME    = 'ZNFT0003'.
  IT_FIELDS-FIELDNAME  = 'VKGRP'.
  IT_FIELDS-SELECTFLAG = 'X'.
  APPEND IT_FIELDS.

  IT_FIELDS-TABNAME    = 'ZNFT0003'.
  IT_FIELDS-FIELDNAME  = 'VTEXT'.
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
      FULL_TABLE                   = GT_VKGRP
    EXCEPTIONS
      FULL_TABLE_EMPTY             = 1
      NO_TABLESTRUCTURE_GIVEN      = 2
      NO_TABLEFIELDS_IN_DICTIONARY = 3
      MORE_THEN_ONE_SELECTFIELD    = 4
      NO_SELECTFIELD               = 5
      OTHERS                       = 6.

  CHECK NOT LD_TABIX IS INITIAL.
  READ TABLE GT_VKGRP INDEX LD_TABIX.
  IF SY-SUBRC = 0.
    PV_VKGRP = GT_VKGRP-VKGRP.
  ENDIF.

ENDFORM.                    " F4HELP_VKGRP

*&---------------------------------------------------------------------*
*&      Form  GET_NF_CU_QTY
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GS_OUTTAB_BUKRS  text
*      -->P_GS_OUTTAB_CONNO  text
*      -->P_GS_OUTTAB_NFKEY  text
*      -->P_GS_OUTTAB_CU_V_Q  text
*----------------------------------------------------------------------*
FORM GET_NF_CU_QTY  USING    PV_BUKRS
                             PV_CONNO
                             PV_NFKEY
                             PV_CU_N_Q.


  SELECT SUM( Z4~EMENG ) INTO  PV_CU_N_Q
    FROM ZNFT1000 AS Z1
         INNER JOIN ZNFT1001 AS Z2
            ON Z2~CONNO EQ Z1~CONNO
         INNER JOIN ZNFT1011 AS Z3
            ON Z3~CONNO EQ Z2~CONNO AND Z3~NFKEY EQ Z2~NFKEY
         INNER JOIN ZNFT1020 AS Z4
            ON Z4~REQNO EQ Z3~REQNO AND Z4~H_NO1 EQ Z3~H_NO1
   WHERE Z1~BUKRS EQ PV_BUKRS
     AND Z1~CONNO EQ PV_CONNO
     AND Z2~NFKEY EQ PV_NFKEY
     AND Z4~YNCAN NE 'X'.

ENDFORM.                    " GET_NF_CU_QTY
*&---------------------------------------------------------------------*
*&      Form  CREATE_CONNO_ITAB
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CREATE_CONNO_ITAB USING GV_ERROR.

  CLEAR GV_ERROR.

* 상세화면 FOR ALL ENTRIES 용 인터널테이블
  CLEAR GS_CONNO. REFRESH GT_CONNO.
  LOOP AT GT_OUTTAB INTO GS_OUTTAB WHERE CHECK EQ 'X'.
    GS_CONNO-CONNO = GS_OUTTAB-CONNO.
    APPEND GS_CONNO TO GT_CONNO.
  ENDLOOP.

  IF GT_CONNO IS INITIAL.
    GV_ERROR = 'X'.
    MESSAGE S003 DISPLAY LIKE 'E'
       WITH '데이터를 선택하십시오.'.
    EXIT.
  ENDIF.

ENDFORM.                    " CREATE_CONNO_ITAB
*&---------------------------------------------------------------------*
*&      Form  DATA_SELECT_V
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM DATA_SELECT_V .

  DATA: LV_TABIX TYPE SY-TABIX.

  SELECT V1~VBELN
         V1~POSNR
         V1~MATNR
         V1~ARKTX
         V1~KWMENG AS CU_V_Q
*         V1~MEINS
         Z1~CONNO
         Z1~COTXT
         INTO CORRESPONDING FIELDS OF TABLE GT_OUTTAB_V
    FROM VBAP AS V1
         INNER JOIN VBAK AS V2
            ON V2~VBELN EQ V1~VBELN
         INNER JOIN ZNFT1000 AS Z1
            ON Z1~CONNO EQ V1~CONNO
         FOR ALL ENTRIES IN GT_CONNO
   WHERE V1~CONNO EQ GT_CONNO-CONNO
     AND V1~ABGRU EQ SPACE.

  IF SY-SUBRC EQ 0.
    SORT GT_OUTTAB_V BY VBELN POSNR.
    LOOP AT GT_OUTTAB_V INTO GS_OUTTAB_V.
      LV_TABIX = SY-TABIX.

*     단위 : TON
      GS_OUTTAB_V-MEINS = 'TON'.

*     판매오더 CU량 조회 (계약번호별)
      PERFORM GET_VB_CU_QTY USING GS_OUTTAB_V-VBELN
                                  GS_OUTTAB_V-POSNR
                                  GS_OUTTAB_V-CONNO
                                  GS_OUTTAB_V-MATNR
                                  GS_OUTTAB_V-CU_V_Q.

      MODIFY GT_OUTTAB_V FROM GS_OUTTAB_V INDEX LV_TABIX.
      CLEAR: LV_TABIX, GS_OUTTAB.
    ENDLOOP.
  ELSE.

  ENDIF.

ENDFORM.                    " DATA_SELECT_V
*&---------------------------------------------------------------------*
*&      Form  DATA_SELECT_Z
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM DATA_SELECT_Z .

  DATA: LV_TABIX TYPE SY-TABIX.

  SELECT Z4~NFUTN AS NFUTN
         Z4~RUDAT AS RUDAT
         Z4~FCM   AS FCM
         Z4~NFKEY AS NFKEY
         Z4~BY_SL AS BY_SL
         Z4~ENDAT AS ENDAT
         Z4~MITYP AS MITYP
         Z4~MISPD AS MISPD
         Z4~MIMON AS MIMON
         Z4~PRICE AS PRICE
         Z4~WAERS AS WAERS
         Z4~EMENG AS EMENG
         Z4~MEINS AS MEINS
         Z5~RUDAT AS RUDAT1
         Z5~FCM   AS FCM1
         Z5~NFKEY AS NFKEY1
         Z5~BY_SL AS BY_SL1
         Z5~ENDAT AS ENDAT1
         Z5~MITYP AS MITYP1
         Z5~MISPD AS MISPD1
         Z5~MIMON AS MIMON1
         Z5~PRICE AS PRICE1
         Z5~WAERS AS WAERS1
         Z5~EMENG AS EMENG1
         Z5~MEINS AS MEINS1
         INTO CORRESPONDING FIELDS OF TABLE GT_OUTTAB_Z
    FROM ZNFT1000 AS Z1
         INNER JOIN ZNFT1001 AS Z2
            ON Z2~CONNO EQ Z1~CONNO
         INNER JOIN ZNFT1011 AS Z3
            ON Z3~CONNO EQ Z2~CONNO AND Z3~NFKEY EQ Z2~NFKEY
         INNER JOIN ZNFT1020 AS Z4
            ON Z4~REQNO EQ Z3~REQNO AND Z4~H_NO1 EQ Z3~H_NO1
         LEFT OUTER JOIN ZNFT1030 AS Z5
            ON Z5~BUKRS EQ Z4~BUKRS AND Z5~NFUTN EQ Z4~NFUTN
         FOR ALL ENTRIES IN GT_CONNO
   WHERE Z1~CONNO EQ GT_CONNO-CONNO
     AND Z4~YNCAN EQ SPACE
     AND Z3~NFKEY IN S_NFKEY.

  IF SY-SUBRC EQ 0.
    SORT GT_OUTTAB_Z BY NFUTN RUDAT FCM NFKEY BY_SL.
    CLEAR GS_OUTTAB_Z.
    LOOP AT GT_OUTTAB_Z INTO GS_OUTTAB_Z.

      LV_TABIX = SY-TABIX.

*     FCM
      PERFORM GET_LIFNR_DESC USING GS_OUTTAB_Z-FCM
                                   GS_OUTTAB_Z-FCM_NM.

*     FCM
      PERFORM GET_LIFNR_DESC USING GS_OUTTAB_Z-FCM1
                                   GS_OUTTAB_Z-FCM_NM1.

*   - BUY & SELL : 신규
      PERFORM DOMAIN_VALUE_GET USING 'ZBY_SL'
                                     GS_OUTTAB_Z-BY_SL
                                     GS_OUTTAB_Z-BYSL_NM.

*   - BUY & SELL : 신규
      PERFORM DOMAIN_VALUE_GET USING 'ZBY_SL'
                                     GS_OUTTAB_Z-BY_SL1
                                     GS_OUTTAB_Z-BYSL_NM1.

      MODIFY GT_OUTTAB_Z FROM GS_OUTTAB_Z INDEX LV_TABIX.
      CLEAR : LV_TABIX, GS_OUTTAB_Z.

    ENDLOOP.
  ELSE.

  ENDIF.

ENDFORM.                    " DATA_SELECT_Z

*&---------------------------------------------------------------------*
*&      Form  MAKE_SELETCT_OPTION
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM MAKE_SELETCT_OPTION .

***  ==================================================
***  사용안함
***  ==================================================
***  CLEAR S_NFKEY. REFRESH S_NFKEY.
***
***  S_NFKEY-LOW    = 'CU'.
***  S_NFKEY-HIGH   = SPACE.
***  S_NFKEY-SIGN   = 'I'.
***  S_NFKEY-OPTION = 'EQ'.
***  APPEND S_NFKEY.
***
***  LOOP AT SCREEN.
***    IF ( SCREEN-NAME EQ 'S_NFKEY-LOW'
***      OR SCREEN-NAME EQ 'S_NFKEY-HIGH' ).
****     INPUT = 0 : 입력 비활성화
****     INPUT = 1 : 입력   활성화
***      SCREEN-INPUT = 0.
***    ENDIF.
***    MODIFY SCREEN.
***  ENDLOOP.

ENDFORM.                    " MAKE_SELETCT_OPTION
*&---------------------------------------------------------------------*
*&      Form  REFRESH_SCR1200
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM REFRESH_SCR1200 .

  CALL METHOD GRF_CONTAINER_D->FREE
    EXCEPTIONS
      CNTL_ERROR        = 1
      CNTL_SYSTEM_ERROR = 2.

  FREE   : GRF_GRID_D,
           GRF_CONTAINER_D,
           GRF_EVENT_RECEIVER_D.

  CLEAR  : GS_LAYOUT_D, GS_VARIANT_D, GT_EXCLUDE_D,
           GS_FIELDCAT_D, GS_SORT_D, GS_OUTTAB_V, GS_OUTTAB_Z.

  REFRESH: GT_FIELDCAT_D, GT_SORT_D, GT_OUTTAB_V, GT_OUTTAB_Z.

ENDFORM.                    " REFRESH_SCR1200

*&---------------------------------------------------------------------*
*&      Form  GET_SD_CU_QTY
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GS_OUTTAB_CONNO  text
*      -->P_GS_OUTTAB_NFKEY  text
*      -->P_GS_OUTTAB_CU_V_Q  text
*----------------------------------------------------------------------*
FORM GET_SD_CU_QTY  USING    PV_CONNO
                             PV_NFKEY
                             PV_CU_V_Q.

  DATA: BEGIN OF LS_VBELN,
          VTWEG  LIKE VBAK-VTWEG ,
          CONNO  LIKE VBAP-CONNO ,
          MATNR  LIKE VBAP-MATNR ,
          KWMENG LIKE VBAP-KWMENG,
          VGW    TYPE /NFM/VGW   ,
          VGE    TYPE /NFM/VGE   ,
        END OF LS_VBELN.
  DATA: LT_VBELN LIKE TABLE OF LS_VBELN.

  DATA: LV_TABIX TYPE SY-TABIX,
        LV_QTY   LIKE VBAP-KWMENG.

* 해당 계약의 판매오더수량을 SUM.
  SELECT V1~CONNO V1~MATNR V2~VTWEG SUM( V1~KWMENG ) AS KWMENG
    INTO CORRESPONDING FIELDS OF TABLE LT_VBELN
    FROM VBAP AS V1
         INNER JOIN VBAK AS V2
            ON V2~VBELN EQ V1~VBELN
   WHERE V1~CONNO EQ PV_CONNO
     AND V1~ABGRU EQ SPACE
   GROUP BY V1~CONNO V1~MATNR V2~VTWEG.

  IF SY-SUBRC EQ 0.
*   각 판매오더번호의 자재에 대한 수수료가중치정보를 가져온다.
    CLEAR PV_CU_V_Q.
    LOOP AT LT_VBELN INTO LS_VBELN.
      LV_TABIX = SY-TABIX.
      SELECT SINGLE VGW VGE INTO (LS_VBELN-VGW, LS_VBELN-VGE)
        FROM /NFM/TVGW
       WHERE KAPPL EQ 'V'
         AND VTWEG EQ LS_VBELN-VTWEG
         AND NES   EQ PV_NFKEY
         AND MATNR EQ LS_VBELN-MATNR.

      IF SY-SUBRC EQ 0.
*       계약번호별 수량 SUM
        MODIFY LT_VBELN FROM LS_VBELN INDEX LV_TABIX.
        IF LS_VBELN-VGE NE 0 OR LS_VBELN-VGE IS NOT INITIAL.
          LV_QTY =
          ( ( LS_VBELN-VGW * LS_VBELN-KWMENG ) / LS_VBELN-VGE ) / 1000.
        ELSE.
          LV_QTY = 0.
        ENDIF.
        ADD LV_QTY TO PV_CU_V_Q.
      ELSE.
        CONTINUE.
      ENDIF.
      CLEAR : LS_VBELN, LV_TABIX.
    ENDLOOP.
  ENDIF.

ENDFORM.                    " GET_SD_CU_QTY

*&---------------------------------------------------------------------*
*&      Form  GET_VB_CU_QTY
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GS_OUTTAB_VBELN  text
*      -->P_GS_OUTTAB_POSNR  text
*      -->P_GS_OUTTAB_CONNO  text
*      -->P_GS_OUTTAB_MATNR  text
*      -->P_CU_V_Q  text
*----------------------------------------------------------------------*
FORM GET_VB_CU_QTY  USING    PV_VBELN
                             PV_POSNR
                             PV_CONNO
                             PV_MATNR
                             PV_CU_QTY.

  DATA: BEGIN OF LS_VBELN,
          VBELN  LIKE VBAP-VBELN ,
          POSNR  LIKE VBAP-POSNR ,
          VKORG  LIKE VBAK-VKORG ,
          VTWEG  LIKE VBAK-VTWEG ,
          MATNR  LIKE VBAP-MATNR ,
          KWMENG LIKE VBAP-KWMENG,
          VGW    TYPE /NFM/VGW   ,
          VGE    TYPE /NFM/VGE   ,
          CU_QTY TYPE KWMENG     ,
        END OF LS_VBELN.
  DATA: LT_VBELN     LIKE TABLE OF LS_VBELN.

  DATA: BEGIN OF LS_VBELN_SUM,
          VBELN  LIKE VBAP-VBELN ,
          POSNR  LIKE VBAP-POSNR ,
          CU_QTY TYPE KWMENG,
        END OF LS_VBELN_SUM.
  DATA: LT_VBELN_SUM LIKE TABLE OF LS_VBELN_SUM.

  DATA: LV_TABIX TYPE SY-TABIX.

  CLEAR PV_CU_QTY.

* 해당 계약의 판매오더수량을 SUM.
  SELECT V2~VKORG
         V2~VTWEG
         V1~MATNR
         V1~KWMENG
         INTO CORRESPONDING FIELDS OF TABLE LT_VBELN
    FROM VBAP AS V1
         INNER JOIN VBAK AS V2
            ON V2~VBELN EQ V1~VBELN
   WHERE V1~VBELN EQ PV_VBELN
     AND V1~POSNR EQ PV_POSNR
     AND V1~CONNO EQ PV_CONNO
     AND V1~ABGRU EQ SPACE.

  IF SY-SUBRC EQ 0.
    LOOP AT LT_VBELN INTO LS_VBELN.

      LV_TABIX = SY-TABIX.

      SELECT SINGLE VGW VGE INTO (LS_VBELN-VGW, LS_VBELN-VGE)
        FROM /NFM/TVGW
       WHERE PARNR EQ SPACE
         AND MATNR EQ LS_VBELN-MATNR
         AND KAPPL EQ 'V'
         AND ORG   EQ LS_VBELN-VKORG
         AND WERKS EQ SPACE
         AND VTWEG EQ LS_VBELN-VTWEG
         AND NES   IN S_NFKEY.

      IF SY-SUBRC EQ 0.
        LS_VBELN_SUM-VBELN = LS_VBELN-VBELN.
        LS_VBELN_SUM-POSNR = LS_VBELN-POSNR.
        IF LS_VBELN-VGE NE 0 OR LS_VBELN-VGE IS NOT INITIAL.
          LS_VBELN_SUM-CU_QTY =
          ( ( LS_VBELN-VGW * LS_VBELN-KWMENG ) / LS_VBELN-VGE ) / 1000.
        ELSE.
          LS_VBELN_SUM-CU_QTY = 0.
        ENDIF.
        APPEND LS_VBELN_SUM TO LT_VBELN_SUM.
      ENDIF.

    ENDLOOP.

    IF LT_VBELN_SUM IS NOT INITIAL.
      READ TABLE LT_VBELN_SUM INTO LS_VBELN_SUM INDEX 1.
      IF SY-SUBRC EQ 0.
        PV_CU_QTY = LS_VBELN_SUM-CU_QTY.
      ENDIF.
    ENDIF.
  ENDIF.

ENDFORM.                    " GET_VB_CU_QTY
