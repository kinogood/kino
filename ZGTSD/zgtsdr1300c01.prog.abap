*&---------------------------------------------------------------------*
*& Include          ZGTSDR1300C01
*&---------------------------------------------------------------------*

*----------------------------------------------------------------------*
*  TYPES                                                               *
*----------------------------------------------------------------------*
TYPE-POOLS : SLIS.

*----------------------------------------------------------------------*
*  DATA                                                                *
*----------------------------------------------------------------------*
**     Internal Table
DATA : G_EVENTS_T           TYPE SLIS_T_EVENT,
       G_LIST_TOP_OF_PAGE_T TYPE SLIS_T_LISTHEADER,
       G_FIELDCAT_T         TYPE SLIS_T_FIELDCAT_ALV,
       G_FIELD_T            TYPE SLIS_T_FIELDCAT_ALV WITH HEADER LINE,
       G_SORT_T             TYPE SLIS_T_SORTINFO_ALV.

**     구조
DATA : G_LAYOUT_S              TYPE SLIS_LAYOUT_ALV,
       G_EXIT_CAUSED_BY_USER_S TYPE SLIS_EXIT_BY_USER,
       G_VARIANT_S             TYPE DISVARIANT,
       G_FIELDCAT_S            TYPE SLIS_FIELDCAT_ALV,
       G_SORT_S                TYPE SLIS_SORTINFO_ALV.

**     일반변수
DATA : G_EXIT_CAUSED_BY_CALLER TYPE C,
       G_SAVE                  TYPE C,
       G_REPID                 TYPE SY-REPID,
       G_PROGRAM               LIKE SY-REPID,
       G_POS                   LIKE SY-CUCOL.

** Layout관련
* The variables 'def_layout' and 'spec_layout' are set during
* interactions on the selection screen.
* 'gs_variant' finally holds the chosen layout.
DATA : DEF_LAYOUT  TYPE DISVARIANT,     " default layout
       DEFAULT     TYPE C VALUE ' ',
       SPEC_LAYOUT TYPE DISVARIANT,     " specific layout
       GS_VARIANT  TYPE DISVARIANT.     " finally chosen layout

DATA : G_LAYOUT TYPE DISVARIANT,
       G_EXIT   TYPE C.  "is set if the user has aborted a layout popup

*----------------------------------------------------------------------*
*  CONSTANTS:                                                          *
*----------------------------------------------------------------------*
CONSTANTS : C_STATUS_SET   TYPE SLIS_FORMNAME VALUE 'PF_STATUS_SET',
            C_USER_COMMAND TYPE SLIS_FORMNAME VALUE 'USER_COMMAND',
            C_TOP_OF_PAGE  TYPE SLIS_FORMNAME VALUE 'TOP_OF_PAGE',
            C_TOP_OF_LIST  TYPE SLIS_FORMNAME VALUE 'TOP_OF_LIST',
            C_END_OF_LIST  TYPE SLIS_FORMNAME VALUE 'END_OF_LIST'.

*&---------------------------------------------------------------------*
*&      Form  form_setting
*&---------------------------------------------------------------------*
*       ALV 이벤트 종류 Set.
*----------------------------------------------------------------------*
*      -->p_events_t  이벤트 Table
*      -->p_com       이벤트 종료
*      -->p_form      관련된 FORM문
*----------------------------------------------------------------------*
FORM FORM_SETTING TABLES P_EVENTS_T LIKE G_EVENTS_T
                   USING P_COM
                         P_FORM.

* 해당  FORM발췌
  DATA : L_EVENT_S    TYPE  SLIS_ALV_EVENT.

  READ TABLE  P_EVENTS_T  WITH KEY  NAME = P_COM
                            INTO L_EVENT_S.
* FORM 생성
  IF   SY-SUBRC EQ 0.
    MOVE     P_FORM      TO   L_EVENT_S-FORM.
    MODIFY   P_EVENTS_T  FROM L_EVENT_S INDEX SY-TABIX.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  header_setting
*&---------------------------------------------------------------------*
*       ALV Head 설정.
*----------------------------------------------------------------------*
*      -->p_list_top_of_page_t  저장될 Table
*      -->p_typ                 종류
*      -->p_key                 key
*      -->p_info                Text
*----------------------------------------------------------------------*
FORM   HEADER_SETTING
          TABLES P_LIST_TOP_OF_PAGE_T LIKE G_LIST_TOP_OF_PAGE_T
          USING  P_TYP
                 P_KEY
                 P_INFO.

* HEADER SETTING
  DATA : L_LINE_S  TYPE SLIS_LISTHEADER.

  CLEAR L_LINE_S.
  MOVE   P_TYP     TO L_LINE_S-TYP.
  MOVE   P_KEY     TO L_LINE_S-KEY.
  MOVE   P_INFO    TO L_LINE_S-INFO.
  APPEND L_LINE_S  TO P_LIST_TOP_OF_PAGE_T.

ENDFORM.

*&--------------------------------------------------------------------*
*&    Form  FIELD_SETTING
*---------------------------------------------------------------------*
*     ALV FIELD SETTING작업을 수행
*---------------------------------------------------------------------*
*      -->p_fieldcat_t  저장될 Table
*      -->p_gun         종류
*      -->p_fname       이름
*      -->p_con         Value
*----------------------------------------------------------------------*
FORM  FIELD_SETTING TABLES P_FIELDCAT_T LIKE G_FIELDCAT_T
                    USING  P_GUB
                           P_FNAME
                           P_CON.

* FIELD 속성 READ
  IF   P_GUB =  'S'.
    CLEAR G_FIELDCAT_S.
    READ  TABLE G_FIELD_T INTO G_FIELDCAT_S
          WITH KEY FIELDNAME  = P_FNAME.
    EXIT.
  ENDIF.

* 속성 MOVE
  DATA L_COL(40).
  FIELD-SYMBOLS <FS>.
  CONCATENATE 'G_FIELDCAT_S-' P_FNAME  INTO L_COL.
  ASSIGN      (L_COL)         TO       <FS>.
  MOVE         P_CON          TO       <FS>.

** DATA  APPEND
*  CHECK  P_GUB = 'E'.
*  IF     G_FIELDCAT_S-DATATYPE  = 'CURR'.
*    G_FIELDCAT_S-CURRENCY  = 'KRW'.
*  ENDIF.
*  APPEND G_FIELDCAT_S TO P_FIELDCAT_T.

* DATA  APPEND
  CHECK  P_GUB = 'E'.
  IF G_FIELDCAT_S-DATATYPE  = 'CURR'.
*    G_FIELDCAT_S-CURRENCY  = 'KRW'.
    READ TABLE G_FIELD_T WITH KEY DATATYPE  = 'CUKY'.
    IF SY-SUBRC EQ 0.
      G_FIELDCAT_S-CFIELDNAME = G_FIELD_T-FIELDNAME.
    ENDIF.
  ENDIF.

  G_POS = G_POS + 1.
  G_FIELDCAT_S-COL_POS = G_POS.

  APPEND G_FIELDCAT_S TO G_FIELDCAT_T.

ENDFORM.

*&---------------------------------------------------------------------*
*&    Form  SORT_SETTING
*---------------------------------------------------------------------*
*     ALV SORT SETTING작업을 수행
*---------------------------------------------------------------------*
*      -->p_sort_t  저장될 Table
*      -->p_gun         종류
*      -->p_fname       이름
*      -->p_con         Value
*----------------------------------------------------------------------*
FORM  SORT_SETTING TABLES P_SORT_T LIKE G_SORT_T
                   USING  P_GUB
                          P_FNAME
                          P_CON.

  DATA L_COL(40).
  FIELD-SYMBOLS <FS>.

  IF P_GUB = 'S'.

    CLEAR G_SORT_S.

    CONCATENATE 'G_SORT_S-' P_FNAME  INTO L_COL.
    ASSIGN      (L_COL)         TO       <FS>.
    MOVE         P_CON          TO       <FS>.

    EXIT.

  ENDIF.

* 속성 MOVE
  CONCATENATE 'G_SORT_S-' P_FNAME  INTO L_COL.
  ASSIGN      (L_COL)         TO       <FS>.
  MOVE         P_CON          TO       <FS>.

* DATA  APPEND
  CHECK  P_GUB = 'E'.
  APPEND G_SORT_S TO P_SORT_T.

ENDFORM.
