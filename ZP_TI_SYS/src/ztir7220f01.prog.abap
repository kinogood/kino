*&---------------------------------------------------------------------*
*&  Include           ZNFR2000F01
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  MAKE_RANGES_CSTAT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM MAKE_RANGES_ELDFN .

  CLEAR R_ELDFN.
  REFRESH R_ELDFN.

  CASE SY-TCODE.
    WHEN GC_TCODE_A.
      R_ELDFN-LOW    = 'A'.
      R_ELDFN-HIGH   = 'Z'.
      R_ELDFN-SIGN   = 'E'.
      R_ELDFN-OPTION = 'BT'.
      APPEND R_ELDFN.
    WHEN GC_TCODE_B.
      R_ELDFN-LOW    = 'A'.
      R_ELDFN-HIGH   = ''.
      R_ELDFN-SIGN   = 'I'.
      R_ELDFN-OPTION = 'EQ'.
      APPEND R_ELDFN.
    WHEN GC_TCODE_C.
      R_ELDFN-LOW    = 'B'.
      R_ELDFN-HIGH   = ''.
      R_ELDFN-SIGN   = 'I'.
      R_ELDFN-OPTION = 'EQ'.
      APPEND R_ELDFN.
  ENDCASE.

ENDFORM.                    " MAKE_RANGES_ELDFN

*&---------------------------------------------------------------------*
*&      Form  CREATE_OBJECT
*&---------------------------------------------------------------------*
*       text
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
FORM SET_GRID_SORT .

  CLEAR : GS_SORT, GT_SORT.
  REFRESH GT_SORT.

  GS_SORT-SPOS = 1.
  GS_SORT-FIELDNAME = 'ACDNO'.
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
FORM SET_GRID_FIELDCATALOG .

  IF SY-TCODE <> 'ZTIR722'.
    PERFORM SET_FIELDCAT USING:
      'CHECK'           '선택'             '4'      'C'    ' '     .
  ENDIF.
  PERFORM SET_FIELDCAT USING:
    'ACDNO'           '인수증관리번호'   '10'     'C'    ' '     ,
    'BUKRS'           '회사코드'         '10'     'C'    ' '     ,
    'EKGRP'           '구매그룹'         '8'      'C'    ' '     ,
    'REQNO'           '수입요청관리번호' '10'     'C'    ' '     ,
    'AMDSQ'           'Amend 차수'       '10'     'C'    ' '     ,
    'LBANR'           '신용장번호'       '10'     'L'    ' '     ,
    'ELDFN_NM'        '승인상태'         '10'     'L'    ' '     ,
    'ACCNO'           '인수증발급번호'   '35'     'C'    ' '     ,
    'ACDAT'           '인수일'           '10'     'C'    ' '     ,
    'AEXDT'           '유효일'           '10'     'C'    ' '     ,
    'ISSDT'           '발급일'           '10'     'C'    ' '     ,
    'LIFNR'           '구매처'           '10'     'C'    'ALPHA' ,
    'VENNM'           '공급자'           '35'     'L'    ' '     ,
    'ACAMT'           '인수금액'         '15'     'R'    ' '     ,
    'ACAMTC'          '통화'             '5'      'L'    ' '     ,
    'ACKMT'           '인수금액(원화)'   '15'     'R'    ' '     ,
    'ACKMTC'          '통화'             '5'      'L'    ' '     ,
    'EXCRT'           '환율'             '9'      'R'    ' '     .

ENDFORM.                    " SET_GRID_FIELDCATALOG

*&---------------------------------------------------------------------*
*&      Form  SET_FIELDCAT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
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
    WHEN 'BUKRS'.
      GS_FIELDCAT-NO_OUT     = 'X'.
    WHEN 'ACAMT'.
      GS_FIELDCAT-CFIELDNAME = 'ACAMTC'.
    WHEN 'ACKMT'.
      GS_FIELDCAT-CFIELDNAME = 'ACKMTC'.
  ENDCASE.

  APPEND GS_FIELDCAT TO GT_FIELDCAT.

ENDFORM.                    " SET_FIELDCAT

*&---------------------------------------------------------------------*
*&      Form  SET_CELL_ATTRIBUTE
*&---------------------------------------------------------------------*
*       text
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

*  EDIT 가능상태
*  CALL METHOD GRF_GRID->SET_READY_FOR_INPUT
*    EXPORTING
*      I_READY_FOR_INPUT = 1.

ENDFORM.                    " SET_EVENT_HANDLER

*&---------------------------------------------------------------------*
*&      Form  SET_F4_HELP_REGISTER
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM SET_F4_HELP_REGISTER .

  CLEAR   : GS_F4.
  REFRESH : GT_F4.

* FieldName별 소트해서 APPEND
  GS_F4-FIELDNAME = 'ACDNO'.
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
*&      Form  DATA_SELECT_ZTITACK
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM DATA_SELECT_ZTITACK.

  DATA: LV_TABIX TYPE SY-TABIX.

  CLEAR : GS_OUTTAB,
          GT_OUTTAB.
  REFRESH GT_OUTTAB.

  SELECT * INTO CORRESPONDING FIELDS OF TABLE GT_OUTTAB
    FROM ZTITACK AS Z1
   WHERE Z1~ACDNO  IN  S_ACDNO        "(인수증관리번호)
     AND Z1~BUKRS  EQ  P_BUKRS        "(회사코드)
     AND Z1~REQNO  IN  S_REQNO        "(수입요청관리번호)
     AND Z1~LIFNR  IN  S_LIFNR        "(구매처)
     AND Z1~ISSDT  IN  S_ISSDT        "(발급일)
     AND Z1~LBANR  IN  S_LBANR        "(신용장(계약서)번호)
     AND Z1~ELDFN  IN  R_ELDFN.       "(승인상태)

  IF GT_OUTTAB IS NOT INITIAL.
    LOOP AT GT_OUTTAB INTO GS_OUTTAB.

      LV_TABIX = SY-TABIX.

*.....승인상태
      PERFORM DOMAIN_VALUE_GET USING 'ZTIELDFN'
                                     GS_OUTTAB-ELDFN
                                     GS_OUTTAB-ELDFN_NM.

      MODIFY GT_OUTTAB FROM GS_OUTTAB INDEX LV_TABIX.

    ENDLOOP.
  ENDIF.

ENDFORM.                    " DATA_SELECT_ZTITACK

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

    IF SY-SUBRC EQ 0 AND
       LS_MOD_CELLS-FIELDNAME EQ 'CHECK'.
      IF LS_MOD_CELLS-VALUE EQ 'X'.

        GS_OUTTAB-CHECK = 'X'.
        MODIFY GT_OUTTAB FROM GS_OUTTAB INDEX LV_INDEX
                         TRANSPORTING CHECK.

*.......해당 인수증관리번호 LOCK OBJECT 잠금
        GS_ACDNO-ACDNO = GS_OUTTAB-ACDNO.
        APPEND GS_ACDNO TO GT_ACDNO.
        PERFORM SET_AC_LOCK_OBJECT USING GS_ACDNO-ACDNO
                                         C_LOCK
                                         C_ERROR
                                         G_MODIFY.
        IF G_MODIFY EQ 'X'.
          CALL METHOD P_DATA_CHANGED->MODIFY_CELL
            EXPORTING
              I_ROW_ID    = LS_MOD_CELLS-ROW_ID
              I_FIELDNAME = 'CHECK'
              I_VALUE     = SPACE.
          EXIT.
        ENDIF.
        DELETE ADJACENT DUPLICATES FROM GT_ACDNO.

      ELSE.
        GS_OUTTAB-CHECK = SPACE.
        MODIFY GT_OUTTAB FROM GS_OUTTAB INDEX LV_INDEX
                         TRANSPORTING CHECK.

*.......해당 인수증관리번호 LOCK OBJECT 잠금해제
        GS_ACDNO-ACDNO = GS_OUTTAB-ACDNO.
        DELETE GT_ACDNO FROM GS_ACDNO.
        PERFORM SET_AC_LOCK_OBJECT USING GS_ACDNO-ACDNO
                                         C_UNLOCK
                                         C_ERROR
                                         G_MODIFY.
        DELETE ADJACENT DUPLICATES FROM GT_ACDNO.

      ENDIF.
    ENDIF.
  ENDLOOP.

ENDFORM.                    " ALV_EVENT_DATA_CHANGED

*&---------------------------------------------------------------------*
*&      Form  ALV_EVENT_DOUBLE_CLICK
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM ALV_EVENT_DOUBLE_CLICK USING P_E_ROW     TYPE LVC_S_ROW
                                  P_E_COLUMN  TYPE LVC_S_COL
                                  P_ES_ROW_NO TYPE LVC_S_ROID.

  READ TABLE GT_OUTTAB INTO GS_OUTTAB INDEX P_ES_ROW_NO-ROW_ID.

  IF SY-SUBRC EQ 0.

    CASE P_E_COLUMN.

      WHEN 'ACDNO'.
        IF NOT GS_OUTTAB-ACDNO IS INITIAL.
          SET PARAMETER ID 'ZTIACDNO' FIELD GS_OUTTAB-ACDNO.
          CALL TRANSACTION 'ZTIT723' AND SKIP FIRST SCREEN.
        ELSE.
          MESSAGE '인수증관리번호가 존재하지 않습니다.'
             TYPE 'S' DISPLAY LIKE 'E'.
        ENDIF.

    ENDCASE.

  ENDIF.

ENDFORM.                    " ALV_EVENT_DOUBLE_CLICK

*&---------------------------------------------------------------------*
*&      Form  DATA_SAVE_ZTITACK
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM DATA_SAVE_ZTITACK USING PS_CODE.

  DATA: LV_ACDNO TYPE ZTIACDNO,
        LV_R_MSG TYPE CHAR6.

  DATA: LV_ERROR TYPE CHAR01.

  DATA: LS_ZTITACK  TYPE ZTITACK,
        LT_ZTITACK  LIKE TABLE OF ZTITACK.

  DATA: LS_ZTITACH  TYPE ZTITACH,
        LT_ZTITACH  LIKE TABLE OF ZTITACH.

  CALL METHOD GRF_GRID->CHECK_CHANGED_DATA.

  CLEAR LV_ERROR.

  LOOP AT GT_OUTTAB INTO GS_OUTTAB WHERE CHECK EQ 'X'.

    CLEAR LS_ZTITACH.

    LV_ACDNO = GS_OUTTAB-ACDNO.

    MOVE-CORRESPONDING GS_OUTTAB TO LS_ZTITACK.

    IF PS_CODE = 'ACPT'.
      CASE SY-TCODE.
        WHEN GC_TCODE_A.
*-> 2014.02.26 엠트론 승인 프로세스 전선과 동일하게 처리_hjkim
*          IF gs_outtab-bukrs = '3000'. "hjkim 주석
*            ls_ztitack-eldfn = 'C'.  "(2차승인-재무) "hjkim 주석
*          ELSE. "hjkim 주석
          LS_ZTITACK-ELDFN = 'A'.  "(1차승인-구매)
*          ENDIF. "hjkim 주석
*<- 2014.02.26 엠트론 승인 프로세스 전선과 동일하게 처리_hjkim

        WHEN GC_TCODE_B.
          LS_ZTITACK-ELDFN = 'B'.  "(접수-재무)
        WHEN GC_TCODE_C.
          LS_ZTITACK-ELDFN = 'C'.  "(2차승인-재무)
      ENDCASE.
    ELSEIF PS_CODE = 'REJT'.
      CASE SY-TCODE.
        WHEN GC_TCODE_A.
          LS_ZTITACK-ELDFN = 'X'.  "(1차승인반려-구매)
        WHEN GC_TCODE_B.
          LS_ZTITACK-ELDFN = 'Y'.  "(접수반려-재무)
        WHEN GC_TCODE_C.
          LS_ZTITACK-ELDFN = 'Z'.  "(2차승인반려-재무)
      ENDCASE.
    ENDIF.

    APPEND LS_ZTITACK TO LT_ZTITACK.

*...승인/반려 이력 저장
    LS_ZTITACH-ACDNO = LV_ACDNO.
    LS_ZTITACH-CDAT  = SY-DATLO.
    LS_ZTITACH-CTME  = SY-TIMLO.
    LS_ZTITACH-ELDFN = LS_ZTITACK-ELDFN.
    LS_ZTITACH-CNAM  = SY-UNAME.

    APPEND LS_ZTITACH TO LT_ZTITACH.

  ENDLOOP.

  IF LT_ZTITACK IS INITIAL.
    MESSAGE S999 DISPLAY LIKE 'E'
       WITH '수정하실 데이터를 선택하십시오.'.
    EXIT.
  ENDIF.

  MODIFY ZTITACK FROM TABLE LT_ZTITACK.

  IF PS_CODE = 'ACPT'.
    LV_R_MSG = '승인이'.
  ELSEIF PS_CODE = 'REJT'.
    LV_R_MSG = '반려가'.
  ENDIF.

  IF SY-SUBRC EQ 0.
    MODIFY ZTITACH FROM TABLE LT_ZTITACH.
    COMMIT WORK.
    PERFORM DATA_RELOAD.
    PERFORM DEQUEUE_ZTITACK_T.

*...2차 승인시 EDI 문서 전송
    LOOP AT LT_ZTITACK INTO LS_ZTITACK.
      IF SY-TCODE EQ GC_TCODE_C AND PS_CODE = 'ACPT'. "hjkim 주석
*-> 2014.02.26 엠트론 승인 프로세스 전선과 동일하게 처리_hjkim
*         ( SY-TCODE EQ GC_TCODE_A AND LS_ZTITACK-BUKRS = '3000' ).
*<- 2014.02.26 엠트론 승인 프로세스 전선과 동일하게 처리_hjkim
        PERFORM SEND_EDI_LOCRCT USING LS_ZTITACK
                                      G_SUBRC.
      ENDIF.
    ENDLOOP.


    MESSAGE S997 DISPLAY LIKE 'S'
       WITH '선택 데이터에 대한 ' LV_R_MSG ' 성공하였습니다.'.
  ELSE.
    ROLLBACK WORK.
    MESSAGE S997 DISPLAY LIKE 'S'
       WITH '선택 데이터에 대한 ' LV_R_MSG ' 실패하였습니다.'.
    EXIT.
  ENDIF.

ENDFORM.                    " DATA_SAVE_ZTITACK

*&---------------------------------------------------------------------*
*&      Form  DATA_RELOAD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM DATA_RELOAD .

  PERFORM DATA_SELECT_ZTITACK.

ENDFORM.                    " DATA_RELOAD

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
      WHEN OTHERS.
        LS_CELLTAB-STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED.
    ENDCASE.
    INSERT LS_CELLTAB INTO TABLE PT_CELLTAB.
  ENDLOOP.

ENDFORM.                    " FILL_CELLTAB_C

*&---------------------------------------------------------------------*
*&      Form  DEQUEUE_ZTITACK_T
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM DEQUEUE_ZTITACK_T.

  LOOP AT GT_ACDNO INTO GS_ACDNO.
    CALL FUNCTION 'DEQUEUE_EZ_TI_ZTITACK'
      EXPORTING
        MANDT = SY-MANDT
        ACDNO = GS_ACDNO-ACDNO.
  ENDLOOP.

ENDFORM.                    " DEQUEUE_ZNFT1000_T

**&---------------------------------------------------------------------*
**&      Form  CHECK_AUTHORIZATION
**&---------------------------------------------------------------------*
**       text
**----------------------------------------------------------------------*
*FORM CHECK_AUTHORIZATION  USING    PV_BUKRS
*                                   PV_ERROR.
*
*  CLEAR : PV_ERROR.
*
*  AUTHORITY-CHECK OBJECT 'ZNF_000002'
*       ID 'BUKRS' FIELD PV_BUKRS
*       ID 'PRCTR' DUMMY
*       ID 'WERKS' DUMMY.
*
*  IF SY-SUBRC <> 0.
*    PV_ERROR = 'X'.
*
*    MESSAGE S003 DISPLAY LIKE 'E'
*       WITH '회사코드' PV_BUKRS
*            '에 대한 권한을 점검하시기 바랍니다.'.
*  ENDIF.
*
*ENDFORM.                    " CHECK_AUTHORIZATION

**&---------------------------------------------------------------------*
**&      Form  POPUP_TO_CONFIRM
**&---------------------------------------------------------------------*
**       text
**----------------------------------------------------------------------*
*FORM POPUP_TO_CONFIRM  USING    PV_TITLE
*                                PV_TEXT
*                                PV_DEFAULT
*                                PV_ANSWER.
*
*  CLEAR : PV_ANSWER.
*
*  CALL FUNCTION 'POPUP_TO_CONFIRM'
*    EXPORTING
*      TITLEBAR              = PV_TITLE
*      TEXT_QUESTION         = PV_TEXT
*      TEXT_BUTTON_1         = '예'
*      ICON_BUTTON_1         = 'ICON_OKAY'
*      TEXT_BUTTON_2         = '아니오'
*      ICON_BUTTON_2         = 'ICON_CANCEL'
*      DEFAULT_BUTTON        = PV_DEFAULT
*      DISPLAY_CANCEL_BUTTON = ' '
*    IMPORTING
*      ANSWER                = PV_ANSWER
*    EXCEPTIONS
*      TEXT_NOT_FOUND        = 1
*      OTHERS                = 2.
*
*ENDFORM.                    " POPUP_TO_CONFIRM

*&---------------------------------------------------------------------*
*&      Form  DOMAIN_VALUE_GET
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM DOMAIN_VALUE_GET  USING  PV_DOMNAME
                              PV_DOMVALUE
                              PV_DDTEXT.
  DATA: LV_DOMNAME  LIKE DD07V-DOMNAME,
        LV_DOMVALUE LIKE DD07V-DOMVALUE_L,
        LV_DDTEXT   LIKE  DD07V-DDTEXT.

  CLEAR : LV_DDTEXT, PV_DDTEXT.

  LV_DOMNAME  = PV_DOMNAME.
  LV_DOMVALUE = PV_DOMVALUE.

  CALL FUNCTION 'DOMAIN_VALUE_GET'
    EXPORTING
      I_DOMNAME  = LV_DOMNAME
      I_DOMVALUE = LV_DOMVALUE
    IMPORTING
      E_DDTEXT   = LV_DDTEXT
    EXCEPTIONS
      NOT_EXIST  = 1
      OTHERS     = 2.

  PV_DDTEXT = LV_DDTEXT.

ENDFORM.                    " DOMAIN_VALUE_GET

**&---------------------------------------------------------------------*
**&      Form  GET_DEFAULT_COMPANY_DATA
**&---------------------------------------------------------------------*
**       text
**----------------------------------------------------------------------*
*FORM GET_DEFAULT_COMPANY_DATA  USING    PV_BUKRS
*                                        PV_WAERS
*                                        PV_LAND1
*                                        PV_BUTXT
*                                        PV_KTOPL
*                                        PV_KOKRS.
*
*  CLEAR : PV_WAERS, PV_LAND1, PV_BUTXT,
*          PV_KTOPL, PV_KOKRS.
*
*  CHECK PV_BUKRS IS NOT INITIAL.
*
*  SELECT SINGLE A~WAERS
*                A~LAND1
*                A~BUTXT
*                A~KTOPL
*                B~KOKRS
*    INTO (PV_WAERS, PV_LAND1, PV_BUTXT,
*          PV_KTOPL, PV_KOKRS)
*    FROM T001 AS A
*   INNER JOIN TKA02 AS B
*      ON A~BUKRS = B~BUKRS
*   WHERE A~BUKRS = PV_BUKRS.
*
*ENDFORM.                    " GET_DEFAULT_COMPANY_DATA

**&---------------------------------------------------------------------*
**&      Form  CONVERSION_EXIT_ALPHA
**&---------------------------------------------------------------------*
**       text
**----------------------------------------------------------------------*
*FORM CONVERSION_EXIT_ALPHA  USING    PV_FLAG
*                                     PV_VALUE.
*
*  IF PV_FLAG = 'I'.
*    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
*      EXPORTING
*        INPUT  = PV_VALUE
*      IMPORTING
*        OUTPUT = PV_VALUE.
*  ELSE.
*    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
*      EXPORTING
*        INPUT  = PV_VALUE
*      IMPORTING
*        OUTPUT = PV_VALUE.
*  ENDIF.
*
*ENDFORM.                    " CONVERSION_EXIT_ALPHA

**&---------------------------------------------------------------------*
**&      Form  GET_LIFNR_DESC
**&---------------------------------------------------------------------*
**       text
**----------------------------------------------------------------------*
*FORM GET_LIFNR_DESC  USING    PV_LIFNR
*                              PV_NAME1.
*
*  CLEAR : PV_NAME1.
*
*  CHECK PV_LIFNR IS NOT INITIAL.
*
*  SELECT SINGLE NAME1
*    INTO PV_NAME1
*    FROM LFA1
*   WHERE LIFNR = PV_LIFNR.
*
*ENDFORM.                    " GET_LIFNR_DESC

*&---------------------------------------------------------------------*
*&      Form  set_ac_lock_object
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM SET_AC_LOCK_OBJECT  USING    P_ACDNO
                                  P_MODE
                                  P_ERRMODE
                                  P_CHECK.
  DATA: LV_MSGV1  LIKE SY-MSGV1.
  CLEAR: P_CHECK.

  IF P_MODE EQ 'L'.
    CALL FUNCTION 'ENQUEUE_EZ_TI_ZTITACK'
      EXPORTING
        MANDT          = SY-MANDT
        ACDNO          = P_ACDNO
      EXCEPTIONS
        FOREIGN_LOCK   = 1
        SYSTEM_FAILURE = 2
        OTHERS         = 3.
    IF SY-SUBRC <> 0.
      LV_MSGV1 = SY-MSGV1.
      P_CHECK = C_TRUE.
      MESSAGE S997 DISPLAY LIKE P_ERRMODE
              WITH P_ACDNO ' 인수증이 현재 처리중입니다. 사용자:' LV_MSGV1.
    ENDIF.
  ELSE.
    CALL FUNCTION 'DEQUEUE_EZ_TI_ZTITACK'
      EXPORTING
        MANDT = SY-MANDT
        ACDNO = P_ACDNO.
  ENDIF.

ENDFORM.                    " set_ac_lock_object

*&---------------------------------------------------------------------*
*&      Form  SET_DEFAULT_PARAMETER
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM SET_DEFAULT_PARAMETER .

  IF SY-TCODE = GC_TCODE_A.
    GV_TITLE = '1차승인'.
  ELSEIF SY-TCODE = GC_TCODE_B.
    GV_TITLE = '접수'.
  ELSEIF SY-TCODE = GC_TCODE_C.
    GV_TITLE = '최종승인'.
  ELSE.
    GV_TITLE = '승인 현황'.
  ENDIF.

  SET TITLEBAR '1100' WITH GV_TITLE.

ENDFORM.                    " SET_DEFAULT_PARAMETER
*&---------------------------------------------------------------------*
*&      Form  SEND_EDI_LOCRCT
*&---------------------------------------------------------------------*
*       인수증 EDI 문서 전송
*----------------------------------------------------------------------*
FORM SEND_EDI_LOCRCT USING P_ZTITACK TYPE ZTITACK
                           G_SUBRC.

  CLEAR : ZTSTIG0.

  SELECT SINGLE *
    FROM ZTSTIG0
   WHERE BUKRS EQ P_ZTITACK-BUKRS.

  IF SY-SUBRC <> 0.
    ROLLBACK WORK.
    MESSAGE S999 DISPLAY LIKE 'E'
       WITH '데이터 전송실패!!!'.
    EXIT.
  ENDIF.

  PERFORM  BUILD_EDI_LOCRCT_RECORD USING ZTSTEDIS-SNCNT
                                         'LOCRCT2AH'
                                         P_ZTITACK-BUKRS
                                         P_ZTITACK-ACDNO
                                         P_ZTITACK-LIFNR
                                         P_ZTITACK-VENNM
                                         G_SUBRC.

  IF G_SUBRC NE 0.
    ROLLBACK WORK.
    EXIT.
  ENDIF.

  CALL FUNCTION 'Z_TD_EDI_OUTBOUND_FOR_RK'
    EXPORTING
      IM_IMEXI    = 'I'  "(수출입구분 - 수입)
      IM_DOCTY    = 'LOCRCT2AH'
      IM_DOCNO    = P_ZTITACK-ACDNO
      IM_SEQNO    = '00'
      IM_ZTSTEDIS = ZTSTEDIS
      IM_ZTSTIG0  = ZTSTIG0
    IMPORTING
      EX_SUBRC    = G_SUBRC
      EX_ZTSTEDIS = ZTSTEDIS.

ENDFORM.                    " SEND_EDI_LOCRCT
*&---------------------------------------------------------------------*
*&      Form  BUILD_EDI_LOCRCT_RECORD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM BUILD_EDI_LOCRCT_RECORD  USING P_SNCNT
                                    P_EDITY
                                    P_BUKRS
                                    P_REFNO
                                    P_RECID
                                    P_RECNM
                                    P_SUBRC.

  DATA: L_LCONO TYPE  ZTIREQNO.
  CLEAR: P_SUBRC.

  CHECK NOT P_EDITY IS INITIAL.

  CALL FUNCTION 'Z_TI_GET_NUMBER_NEXT'
    EXPORTING
      ZMPTY    = 'ED'
    IMPORTING
      LCONO    = L_LCONO
    EXCEPTIONS
      NOT_TYPE = 1
      OTHERS   = 2.

  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

  CLEAR: ZTSTEDIS.
  MOVE: SY-MANDT     TO ZTSTEDIS-MANDT,
        L_LCONO      TO ZTSTEDIS-SNCNT,
        P_EDITY      TO ZTSTEDIS-EDITY,
        SPACE        TO ZTSTEDIS-SNDST,
        P_REFNO      TO ZTSTEDIS-REFNO,
        P_RECID      TO ZTSTEDIS-RECID,
        P_RECNM      TO ZTSTEDIS-RECNM,
*        P_RECNO      TO ZTSTEDIS-RECNO,
        P_BUKRS      TO ZTSTEDIS-BUKRS,
        'I'          TO ZTSTEDIS-IMEXI,
        SY-UNAME     TO ZTSTEDIS-CNAM,
        SY-DATLO     TO ZTSTEDIS-CDAT,
        SY-TIMLO     TO ZTSTEDIS-CTME,
        SY-UNAME     TO ZTSTEDIS-UNAM,
        SY-DATLO     TO ZTSTEDIS-UDAT,
        SY-TIMLO     TO ZTSTEDIS-UTME.

  MODIFY   ZTSTEDIS.

  P_SUBRC = SY-SUBRC.

  IF P_SUBRC NE 0.
    EXIT.
  ENDIF.

  P_SNCNT = L_LCONO.

ENDFORM.                    " BUILD_EDI_LOCRCT_RECORD
*&---------------------------------------------------------------------*
*&      Form  AUTHORIZATION_CHECK
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM AUTHORIZATION_CHECK .

* 권한작업
  DATA: LV_SUBRC LIKE SY-SUBRC.

  CLEAR : LV_SUBRC.

  CALL FUNCTION 'Z_MM_AUTHORIZATION_CHECK'
    EXPORTING
      I_BUKRS = P_BUKRS
      I_TYPE  = '1'
    IMPORTING
      E_SUBRC = LV_SUBRC.

  IF LV_SUBRC <> 0.
    MESSAGE E002 WITH '회사코드에 대한 권한이 없습니다' P_BUKRS.
  ENDIF.

ENDFORM.                    " AUTHORIZATION_CHECK
