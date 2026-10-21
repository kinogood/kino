*&---------------------------------------------------------------------*
*& Include          ZGTMMR4900F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form SET_INIT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_INIT.

  PERFORM GET_IFNO.

  CLEAR : S_IFDAT[].
  S_IFDAT[] = VALUE #( ( SIGN   = GC_I
                         OPTION = GC_BT
                         LOW    = SY-DATLO - 1
                         HIGH   = SY-DATLO ) ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_IFNO
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_IFNO.

  CLEAR : GT_IFNO[].

  SELECT FLD_01      AS KEY,
         FLD_02      AS TEXT,
         FLD_03      AS TYPE,
         FLD_04      AS PROG,
         FLD_05      AS VIEW,
         MODULE_KIND AS KIND
    FROM ZGTMM_CV_GET_IFLIST
    INTO CORRESPONDING FIELDS OF TABLE @GT_IFNO
   WHERE MODULE_KIND IN ( @GC_MM, @GC_PP )
     AND CODEGRP      = @GC_0010.

  CHECK GT_IFNO[] IS NOT INITIAL.

  DELETE ADJACENT DUPLICATES FROM GT_IFNO COMPARING KIND KEY.

* SORT GT_IFNO BY KEY.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form F4_IFXXX
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&---------------------------------------------------------------------*
FORM F4_IFXXX USING PV_ID.

  DATA : LT_IFNO TYPE VRM_VALUES,
         LV_KIND LIKE GS_IFNO-KIND.


  LV_KIND = SWITCH #( PV_ID WHEN 'P_IFNUM' THEN GC_MM
                            WHEN 'P_IFSYT' THEN GC_PP ).

  LT_IFNO[] = CORRESPONDING #( FILTER #( GT_IFNO WHERE KIND = LV_KIND ) ).

  CALL FUNCTION 'VRM_SET_VALUES'
    EXPORTING
      ID     = PV_ID
      VALUES = LT_IFNO.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_COND
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CHECK_COND.

  CLEAR : GS_IFNO.
  READ TABLE GT_IFNO INTO GS_IFNO WITH KEY KIND = GC_MM
                                           KEY  = P_IFNUM
                                           BINARY SEARCH.

  CASE GS_IFNO-TYPE.
    WHEN ' ' OR 'I'.
      IF GS_IFNO-VIEW IS INITIAL.
        MESSAGE S000 DISPLAY LIKE 'E' WITH '조회 View가 셋팅되지 않았습니다.'(M01).
        EXIT.
      ENDIF.

      PERFORM GET_DATA USING ' '.

      IF GV_CNT IS NOT INITIAL.
        CALL SCREEN 100.
      ENDIF.

    WHEN 'O'.
      IF GS_IFNO-PROG IS INITIAL.
        MESSAGE S000 DISPLAY LIKE 'E' WITH '호출 Prg.이 셋팅되지 않았습니다.'(M02).
        EXIT.
      ENDIF.

      CLEAR : GT_SEL[].
      PERFORM SET_SELTAB USING 'P_IFSYT' 'P' P_IFSYT     ' '.
      PERFORM SET_SELTAB USING 'S_IFDAT' 'S' S_IFDAT-LOW S_IFDAT-HIGH.

      SUBMIT (GS_IFNO-PROG) VIA SELECTION-SCREEN
                           WITH SELECTION-TABLE GT_SEL
                            AND RETURN.
*     CALL TRANSACTION GS_IFNO-PROG.

  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_SELTAB
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> P_
*&      --> P_IFSYT
*&      --> P_
*&---------------------------------------------------------------------*
FORM SET_SELTAB USING PV_SNME
                      PV_KIND
                      PV_LOW
                      PV_HIGH.

  CLEAR : GT_SEL.

  GT_SEL-SELNAME = PV_SNME.
  GT_SEL-KIND    = PV_KIND.

  CASE PV_KIND.
    WHEN 'P'.
      GT_SEL-LOW = PV_LOW.
    WHEN 'S'.
      GT_SEL-SIGN   = GC_I.
      GT_SEL-OPTION = GC_BT.
      GT_SEL-LOW    = PV_LOW.
      GT_SEL-HIGH   = PV_HIGH.

      IF PV_HIGH IS INITIAL.
        GT_SEL-OPTION = GC_EQ.
      ENDIF.
  ENDCASE.

  APPEND GT_SEL.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_DATA USING PV_CHK.

  DATA : LR_DATA TYPE REF TO DATA.

  DATA : LV_COND    TYPE STRING,
         LV_STAT(1).


  IF PV_CHK IS INITIAL.
    DATA(LS_STRC) = CAST CL_ABAP_STRUCTDESCR(
                         CL_ABAP_TYPEDESCR=>DESCRIBE_BY_NAME( GS_IFNO-VIEW ) ).

    CREATE DATA LR_DATA TYPE HANDLE LS_STRC.
    ASSIGN LR_DATA->* TO  <GS_LIST>.
    FREE : LR_DATA.

    CREATE DATA LR_DATA LIKE STANDARD TABLE OF <GS_LIST>.
    ASSIGN LR_DATA->* TO <GT_LIST>.
    FREE : LR_DATA.
  ENDIF.

  CLEAR : GV_CNT, <GT_LIST>.

  LV_COND = | IFDAT IN @S_IFDAT |.

  IF P_IFSYT IS NOT INITIAL.
    LV_COND = LV_COND && | AND SYSTEM_ID = @P_IFSYT |.
  ENDIF.

  IF P_ALL IS INITIAL.
    LV_STAT = COND #( WHEN P_SUC = 'X' THEN GC_S
                      WHEN P_ERR = 'X' THEN GC_E ).

    LV_COND = LV_COND && | AND ZSTAT = @LV_STAT |.
  ENDIF.

  SELECT *
    FROM (GS_IFNO-VIEW)
    INTO CORRESPONDING FIELDS OF TABLE @<GT_LIST>
   WHERE (LV_COND).

  IF SY-SUBRC = 0.
    GV_CNT = LINES( <GT_LIST> ).
    MESSAGE S003 WITH GV_CNT. "& 건의 데이터가 조회되었습니다.
  ELSE.
    MESSAGE S002 DISPLAY LIKE 'E'. "조회된 값이 없습니다.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_OBJ
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GR_DOCK
*&      --> GR_GRID
*&---------------------------------------------------------------------*
FORM SET_OBJ USING PR_DOCK TYPE REF TO CL_GUI_DOCKING_CONTAINER
                   PR_GRID TYPE REF TO CL_GUI_ALV_GRID.

  PR_DOCK = NEW #( REPID     = SY-REPID
                   DYNNR     = SY-DYNNR
                   SIDE      = CL_GUI_DOCKING_CONTAINER=>DOCK_AT_TOP
                   EXTENSION = 655 ).

  PR_GRID = NEW #( I_PARENT      = PR_DOCK
                   I_APPL_EVENTS = GC_X ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_EXCL
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_EXCL.

  CLEAR : GT_EXCL[].

  "다운로드 기능(MC_MB_EXPORT) 삭제(송종면E 25.02.10)

  GT_EXCL[] = VALUE #( ( CL_GUI_ALV_GRID=>MC_FC_LOC_UNDO  )
                       ( CL_GUI_ALV_GRID=>MC_FC_LOC_COPY )
                       ( CL_GUI_ALV_GRID=>MC_FC_LOC_COPY_ROW )
                       ( CL_GUI_ALV_GRID=>MC_FC_LOC_CUT )
                       ( CL_GUI_ALV_GRID=>MC_FC_LOC_DELETE_ROW )
                       ( CL_GUI_ALV_GRID=>MC_FC_LOC_INSERT_ROW )
                       ( CL_GUI_ALV_GRID=>MC_FC_LOC_APPEND_ROW )
                       ( CL_GUI_ALV_GRID=>MC_FC_LOC_PASTE )
                       ( CL_GUI_ALV_GRID=>MC_FC_LOC_PASTE_NEW_ROW )
                       ( CL_GUI_ALV_GRID=>MC_MB_EXPORT )
                       ( CL_GUI_ALV_GRID=>MC_FC_REFRESH ) ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_LAYO
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GS_LAYO
*&---------------------------------------------------------------------*
FORM SET_LAYO USING PS_LAYO TYPE LVC_S_LAYO.

  CLEAR : PS_LAYO.

  PS_LAYO-SEL_MODE   = GC_D.
  PS_LAYO-CWIDTH_OPT = GC_X.
  PS_LAYO-ZEBRA      = GC_X.
  PS_LAYO-SMALLTITLE = GC_X.
  PS_LAYO-GRID_TITLE = 'Interface 처리 상태'(T01).
* PS_LAYO-STYLEFNAME = GC_STYLE.
* PS_LAYO-CTAB_FNAME = GC_COLOR.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_FCAT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_FCAT
*&---------------------------------------------------------------------*
FORM SET_FCAT TABLES PT_FCAT TYPE LVC_T_FCAT.

  DATA : LT_FCAT TYPE SLIS_T_FIELDCAT_ALV.


  CLEAR : LT_FCAT[].
  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
*     I_PROGRAM_NAME     = SY-REPID
*     I_INTERNAL_TABNAME = PV_TNAME
      I_STRUCTURE_NAME   = CONV TABNAME( GS_IFNO-VIEW )
*     I_INCLNAME         = SY-REPID
      I_BYPASSING_BUFFER = GC_X
*     I_BUFFER_ACTIVE    = ''
    CHANGING
      CT_FIELDCAT        = LT_FCAT[].

  DELETE LT_FCAT WHERE FIELDNAME = '.NODE1'.

  CALL FUNCTION 'LVC_TRANSFER_FROM_SLIS'
    EXPORTING
      IT_FIELDCAT_ALV = LT_FCAT[]
    IMPORTING
      ET_FIELDCAT_LVC = PT_FCAT[]
    TABLES
      IT_DATA         = <GT_LIST>
    EXCEPTIONS
      IT_DATA_MISSING = 1
      OTHERS          = 2.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_EVNT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GR_GRID
*&---------------------------------------------------------------------*
FORM SET_EVNT USING PR_GRID TYPE REF TO CL_GUI_ALV_GRID.

  GR_EVENTS = NEW LCL_EVENT_HANDLER( E_OBJECT_TEXT = 'GR_GRID' ).

  SET HANDLER GR_EVENTS->HANDLE_CONTEXT_MENU FOR PR_GRID.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_DISP
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_FCAT
*&      --> GR_GRID
*&      --> GS_LAYO
*&---------------------------------------------------------------------*
FORM SET_DISP TABLES PT_FCAT TYPE LVC_T_FCAT
               USING PR_GRID TYPE REF TO CL_GUI_ALV_GRID
                     PS_LAYO TYPE LVC_S_LAYO.

* CLEAR : GS_VARI.
* GS_VARI-REPORT   = SY-REPID.
* GS_VARI-HANDLE   = SY-DYNNR.
* GS_VARI-USERNAME = SY-UNAME.

  CALL METHOD PR_GRID->SET_TABLE_FOR_FIRST_DISPLAY
    EXPORTING
*     I_BUFFER_ACTIVE      =
*     I_BYPASSING_BUFFER   =
*     I_CONSISTENCY_CHECK  =
*     I_STRUCTURE_NAME     =
*     IS_VARIANT           = GS_VARI
      I_SAVE               = GC_A
*     I_DEFAULT            = GC_X
      IS_LAYOUT            = PS_LAYO
*     IS_PRINT             =
*     IT_SPECIAL_GROUPS    =
      IT_TOOLBAR_EXCLUDING = GT_EXCL
*     IT_HYPERLINK         =
*     IT_ALV_GRAPHICS      =
*     IT_EXCEPT_QINFO      =
*     IR_SALV_ADAPTER      =
    CHANGING
      IT_OUTTAB            = <GT_LIST>
      IT_FIELDCATALOG      = PT_FCAT[].
*     IT_SORT              = PT_SORT[].
*     IT_FILTER            =

ENDFORM.
*&---------------------------------------------------------------------*
*& Form REFRESH_GRID
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GR_GRID
*&      --> GS_LAYO
*&---------------------------------------------------------------------*
FORM REFRESH_GRID USING PR_GRID TYPE REF TO CL_GUI_ALV_GRID
                        PS_LAYO TYPE LVC_S_LAYO.

  DATA : LS_STBL TYPE LVC_S_STBL.


  LS_STBL-ROW = GC_X.
  LS_STBL-COL = GC_X.

  CALL METHOD PR_GRID->SET_FRONTEND_LAYOUT
    EXPORTING
      IS_LAYOUT = PS_LAYO.

  CALL METHOD PR_GRID->REFRESH_TABLE_DISPLAY
    EXPORTING
      IS_STABLE = LS_STBL
*     I_SOFT_REFRESH = GC_X
    EXCEPTIONS
      FINISHED  = 1
      OTHERS    = 2.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form FREE_OBJ
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM FREE_OBJ.

  CASE SY-DYNNR.
    WHEN '0100'.
      CALL METHOD GR_GRID->FREE.
      CALL METHOD GR_DOCK->FREE.
      CLEAR : GR_GRID, GR_DOCK.

    WHEN OTHERS.

  ENDCASE.

  CALL METHOD CL_GUI_CFW=>FLUSH.

ENDFORM.
