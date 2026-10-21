*&---------------------------------------------------------------------*
*& Include          ZGTMMR1000F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form CHECK_COND
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CHECK_COND.

  PERFORM CHECK_BUKRS.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_BUKRS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CHECK_BUKRS.

  CHECK P_BUKRS IS NOT INITIAL.

  SELECT SINGLE BUKRS
    FROM T001 INTO @DATA(LV_BUKRS)
   WHERE BUKRS = @P_BUKRS.

  CHECK SY-SUBRC <> 0.
  MESSAGE E016 WITH '회사코드'(F03). "&를(을) 확인하세요.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_BUTXT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_BUTXT.

  CLEAR : G_BUTXT.

  SELECT SINGLE BUTXT
    FROM T001 INTO G_BUTXT
   WHERE BUKRS = P_BUKRS
     AND SPRAS = SY-LANGU.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_KEY
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_KEY.

  "Table Key
  CLEAR : GT_KEY[].

  SELECT FIELDNAME
         POSITION
    FROM DD03L
    INTO TABLE GT_KEY
   WHERE TABNAME = GC_ZGTMMT1000
     AND KEYFLAG = GC_X.

  DELETE GT_KEY WHERE FNAME = GC_MANDT.
  DELETE GT_KEY WHERE FNAME = GC_BUKRS.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_DD07V
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_DD07V.

  GT_DD07V[] = VALUE #( ( DOMNAME = GC_ZGTDMMTYPE ) ).

  SORT GT_DD07V BY DOMNAME.

  SELECT DOMNAME
         DOMVALUE_L
         DDTEXT
    FROM DD07V
    INTO TABLE GT_DD07V
     FOR ALL ENTRIES IN GT_DD07V
   WHERE DOMNAME    = GT_DD07V-DOMNAME
     AND DDLANGUAGE = SY-LANGU.

  CHECK GT_DD07V[] IS NOT INITIAL.
  SORT GT_DD07V BY DOMNAME DOMVALUE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_DD07V
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> GT_LIST_ZTYPE
*&      <-- GT_LIST_TYPENAME
*&---------------------------------------------------------------------*
FORM SET_DD07V USING P_DOMNAME
                     P_DOMVALUE
            CHANGING P_DDTEXT.

  DATA : L_FNAME TYPE LVC_FNAME.


  CLEAR : P_DDTEXT.
  CHECK P_DOMVALUE IS NOT INITIAL.

  CASE P_DOMNAME.
    WHEN 'ZGTDMMTYPE'.
      L_FNAME = GC_ZTYPE.
  ENDCASE.

  READ TABLE GT_DD07V WITH KEY DOMNAME  = P_DOMNAME
                               DOMVALUE = P_DOMVALUE
                               BINARY SEARCH.

  IF SY-SUBRC <> 0.
    MESSAGE E013 WITH P_DOMVALUE INTO GV_MSG. "입력된 값이 올바르지 않습니다. &

    PERFORM SET_ERR_MSG USING L_FNAME 'V'.
    PERFORM SET_ERR_COL USING L_FNAME.
  ELSE.
    PERFORM RESET_ERR   USING L_FNAME 'V'.
    P_DDTEXT = GT_DD07V-DDTEXT.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_DATA.

  CLEAR : GT_LIST[], GV_CNT.
  CLEAR : GT_D10[],  GT_M10[].

  SELECT @ICON_YELLOW_LIGHT AS STATUS,
         M~*
    FROM ZGTMM_CV_GETAPPSTATBYSPG AS M
    INTO CORRESPONDING FIELDS OF TABLE @GT_LIST
   WHERE BUKRS = @P_BUKRS.

  IF GT_LIST[] IS INITIAL.
    MESSAGE S002 DISPLAY LIKE 'E'. "조회된 값이 없습니다.
    EXIT.
  ENDIF.

  SORT GT_LIST BY BUKRS WERKS ZTYPE.

  GV_CNT = LINES( GT_LIST ).
  MESSAGE S003 WITH GV_CNT. "& 건의 데이터가 조회되었습니다.

* PERFORM SET_ORGN TABLES GT_LIST GT_OLD.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_ORGN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_LIST
*&      --> GT_OLD
*&---------------------------------------------------------------------*
*FORM SET_ORGN TABLES PT_NEW STRUCTURE GT_LIST
*                     PT_OLD STRUCTURE GT_LIST.
*
*  CLEAR : PT_OLD[].
*  CLEAR : GT_D10[], GT_M10[].
*
*  PT_OLD[] = PT_NEW[]. "변경 전 Data
*
*ENDFORM.
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

  CREATE OBJECT PR_DOCK
    EXPORTING
      DYNNR                       = SY-DYNNR
      REPID                       = SY-REPID
      SIDE                        = PR_DOCK->DOCK_AT_TOP
      EXTENSION                   = 655
    EXCEPTIONS
      CNTL_ERROR                  = 1
      CNTL_SYSTEM_ERROR           = 2
      CREATE_ERROR                = 3
      LIFETIME_ERROR              = 4
      LIFETIME_DYNPRO_DYNPRO_LINK = 5.

  CREATE OBJECT PR_GRID
    EXPORTING
      I_PARENT      = PR_DOCK
      I_APPL_EVENTS = GC_X.

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

  GT_EXCL[] = VALUE #( ( CL_GUI_ALV_GRID=>MC_FC_LOC_UNDO  )
                       ( CL_GUI_ALV_GRID=>MC_FC_LOC_COPY )
                       ( CL_GUI_ALV_GRID=>MC_FC_LOC_COPY_ROW )
                       ( CL_GUI_ALV_GRID=>MC_FC_LOC_CUT )
                       ( CL_GUI_ALV_GRID=>MC_FC_LOC_DELETE_ROW )
                       ( CL_GUI_ALV_GRID=>MC_FC_LOC_INSERT_ROW )
                       ( CL_GUI_ALV_GRID=>MC_FC_LOC_APPEND_ROW )
                       ( CL_GUI_ALV_GRID=>MC_FC_LOC_PASTE )
                       ( CL_GUI_ALV_GRID=>MC_FC_LOC_PASTE_NEW_ROW )
                       ( CL_GUI_ALV_GRID=>MC_FC_REFRESH ) ).

* _SET_EXCL CL_GUI_ALV_GRID=>MC_FC_EXCL_ALL.
* _SET_EXCL CL_GUI_ALV_GRID=>MC_FC_AUF.
* _SET_EXCL CL_GUI_ALV_GRID=>MC_FC_AVERAGE.
* _SET_EXCL CL_GUI_ALV_GRID=>MC_FC_BACK_CLASSIC.
* _SET_EXCL CL_GUI_ALV_GRID=>MC_FC_CALL_ABC.
* _SET_EXCL CL_GUI_ALV_GRID=>MC_FC_CALL_CHAIN.
* _SET_EXCL CL_GUI_ALV_GRID=>MC_FC_CALL_CRBATCH.
* _SET_EXCL CL_GUI_ALV_GRID=>MC_FC_CALL_CRWEB.
* _SET_EXCL CL_GUI_ALV_GRID=>MC_FC_CALL_LINEITEMS.
* _SET_EXCL CL_GUI_ALV_GRID=>MC_FC_CALL_MASTER_DATA.
* _SET_EXCL CL_GUI_ALV_GRID=>MC_FC_CALL_MORE.
* _SET_EXCL CL_GUI_ALV_GRID=>MC_FC_CALL_REPORT.
* _SET_EXCL CL_GUI_ALV_GRID=>MC_FC_CALL_XINT.
* _SET_EXCL CL_GUI_ALV_GRID=>MC_FC_CALL_XXL.
* _SET_EXCL CL_GUI_ALV_GRID=>MC_FC_COL_INVISIBLE.
* _SET_EXCL CL_GUI_ALV_GRID=>MC_FC_COL_OPTIMIZE.
* _SET_EXCL CL_GUI_ALV_GRID=>MC_FC_CURRENT_VARIANT.
* _SET_EXCL CL_GUI_ALV_GRID=>MC_FC_DATA_SAVE.
* _SET_EXCL CL_GUI_ALV_GRID=>MC_FC_DELETE_FILTER.
* _SET_EXCL CL_GUI_ALV_GRID=>MC_FC_DESELECT_ALL.
* _SET_EXCL CL_GUI_ALV_GRID=>MC_FC_DETAIL.
* _SET_EXCL CL_GUI_ALV_GRID=>MC_FC_EXPCRDATA.
* _SET_EXCL CL_GUI_ALV_GRID=>MC_FC_EXPCRDESIG.
* _SET_EXCL CL_GUI_ALV_GRID=>MC_FC_EXPCRTEMPL.
* _SET_EXCL CL_GUI_ALV_GRID=>MC_FC_EXPMDB.
* _SET_EXCL CL_GUI_ALV_GRID=>MC_FC_EXTEND.
* _SET_EXCL CL_GUI_ALV_GRID=>MC_FC_F4.
* _SET_EXCL CL_GUI_ALV_GRID=>MC_FC_FILTER.
* _SET_EXCL CL_GUI_ALV_GRID=>MC_FC_FIND.
* _SET_EXCL CL_GUI_ALV_GRID=>MC_FC_FIX_COLUMNS.
* _SET_EXCL CL_GUI_ALV_GRID=>MC_FC_GRAPH.
* _SET_EXCL CL_GUI_ALV_GRID=>MC_FC_HELP.
* _SET_EXCL CL_GUI_ALV_GRID=>MC_FC_INFO.
* _SET_EXCL CL_GUI_ALV_GRID=>MC_FC_LOAD_VARIANT.
* _SET_EXCL CL_GUI_ALV_GRID=>MC_FC_HTML.
* _SET_EXCL CL_GUI_ALV_GRID=>MC_FC_LOC_MOVE_ROW.
* _SET_EXCL CL_GUI_ALV_GRID=>MC_FC_MAINTAIN_VARIANT.
* _SET_EXCL CL_GUI_ALV_GRID=>MC_FC_MAXIMUM.
* _SET_EXCL CL_GUI_ALV_GRID=>MC_FC_MINIMUM.
* _SET_EXCL CL_GUI_ALV_GRID=>MC_FC_PC_FILE.
* _SET_EXCL CL_GUI_ALV_GRID=>MC_FC_PRINT.
* _SET_EXCL CL_GUI_ALV_GRID=>MC_FC_PRINT_BACK.
* _SET_EXCL CL_GUI_ALV_GRID=>MC_FC_PRINT_PREV.
* _SET_EXCL CL_GUI_ALV_GRID=>MC_FC_REPREP.
* _SET_EXCL CL_GUI_ALV_GRID=>MC_FC_SAVE_VARIANT.
* _SET_EXCL CL_GUI_ALV_GRID=>MC_FC_SELECT_ALL.
* _SET_EXCL CL_GUI_ALV_GRID=>MC_FC_SEND.
* _SET_EXCL CL_GUI_ALV_GRID=>MC_FC_SEPARATOR.
* _SET_EXCL CL_GUI_ALV_GRID=>MC_FC_SORT.
* _SET_EXCL CL_GUI_ALV_GRID=>MC_FC_SORT_ASC.
* _SET_EXCL CL_GUI_ALV_GRID=>MC_FC_SORT_DSC.
* _SET_EXCL CL_GUI_ALV_GRID=>MC_FC_SUBTOT.
* _SET_EXCL CL_GUI_ALV_GRID=>MC_FC_SUM.
* _SET_EXCL CL_GUI_ALV_GRID=>MC_FC_TO_OFFICE.
* _SET_EXCL CL_GUI_ALV_GRID=>MC_FC_TO_REP_TREE.
* _SET_EXCL CL_GUI_ALV_GRID=>MC_FC_UNFIX_COLUMNS.
* _SET_EXCL CL_GUI_ALV_GRID=>MC_FC_VIEWS.
* _SET_EXCL CL_GUI_ALV_GRID=>MC_FC_VIEW_CRYSTAL.
* _SET_EXCL CL_GUI_ALV_GRID=>MC_FC_VIEW_EXCEL.
* _SET_EXCL CL_GUI_ALV_GRID=>MC_FC_VIEW_GRID.
* _SET_EXCL  CL_GUI_ALV_GRID=>MC_FC_WORD_PROCESSOR.

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
  PS_LAYO-STYLEFNAME = GC_STYLE.
  PS_LAYO-CTAB_FNAME = GC_COLOR.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_FCAT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_FCAT
*&      --> GT_LIST
*&      --> P_
*&---------------------------------------------------------------------*
FORM SET_FCAT TABLES PT_FCAT TYPE LVC_T_FCAT
                     PT_DATA
               USING PV_TNAME.

  DATA : LT_FCAT TYPE SLIS_T_FIELDCAT_ALV.


  CLEAR : LT_FCAT[].
  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      I_PROGRAM_NAME     = SY-REPID
      I_INTERNAL_TABNAME = PV_TNAME
*     I_INCLNAME         = SY-REPID
      I_BYPASSING_BUFFER = GC_X
*     I_BUFFER_ACTIVE    = ''
    CHANGING
      CT_FIELDCAT        = LT_FCAT[].

  CALL FUNCTION 'LVC_TRANSFER_FROM_SLIS'
    EXPORTING
      IT_FIELDCAT_ALV = LT_FCAT[]
    IMPORTING
      ET_FIELDCAT_LVC = PT_FCAT[]
    TABLES
      IT_DATA         = PT_DATA
    EXCEPTIONS
      IT_DATA_MISSING = 1
      OTHERS          = 2.

  LOOP AT PT_FCAT INTO GS_FCAT.
    CLEAR : GS_FCAT-KEY.

    CASE PV_TNAME.
      WHEN 'GT_LIST'.
        PERFORM SET_LIST_FCAT.
      WHEN OTHERS.

    ENDCASE.

    MODIFY PT_FCAT FROM GS_FCAT.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_LIST_FCAT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_LIST_FCAT.

  CASE GS_FCAT-FIELDNAME.
    WHEN 'STATUS'.
      PERFORM SET_FTXT USING 'Status'(F01).
      GS_FCAT-JUST = GC_C.
    WHEN 'MSG_TXT'.
      PERFORM SET_FTXT USING 'Message'(F02).
    WHEN 'BUKRS'.
      PERFORM SET_FTXT USING '회사코드'(F03).
      GS_FCAT-JUST = GC_C.
    WHEN 'BUTXT'.
      PERFORM SET_FTXT USING '회사명'(F04).
    WHEN 'WERKS'.
      PERFORM SET_FTXT USING '플랜트'(F05).
      GS_FCAT-JUST   = GC_C.
*     GS_FCAT-VALEXI = GC_EM.
    WHEN 'PLANTNAME'.
      PERFORM SET_FTXT USING '플랜트명'(F06).
    WHEN 'ZTYPE'.
      PERFORM SET_FTXT USING '과제구분'(F07).
      GS_FCAT-JUST   = GC_C.
      GS_FCAT-VALEXI = GC_EM.
    WHEN 'TYPENAME'.
      PERFORM SET_FTXT USING '과제명'(F08).
    WHEN 'ZUSE'.
      PERFORM SET_FTXT USING '적용여부'(F09).
      GS_FCAT-CHECKBOX = GC_X.
      GS_FCAT-EDIT     = GC_X.
      GS_FCAT-JUST     = GC_C.

    WHEN OTHERS.
      GS_FCAT-NO_OUT = GC_X.
      GS_FCAT-TECH   = GC_X.
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_FTXT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&---------------------------------------------------------------------*
FORM SET_FTXT USING PV_TEXT.

  GS_FCAT-SELTEXT = GS_FCAT-TOOLTIP
= GS_FCAT-REPTEXT = GS_FCAT-COLTEXT = PV_TEXT.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_EVNT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GR_GRID
*&      --> P_
*&---------------------------------------------------------------------*
FORM SET_EVNT USING PR_GRID TYPE REF TO CL_GUI_ALV_GRID
                    PV_OTEXT.

  CREATE OBJECT GR_EVENTS
    EXPORTING
      E_OBJECT_TEXT = PV_OTEXT.

* SET HANDLER GR_EVENTS->HANDLE_HOTSPOT_CLICK FOR PR_GRID.

  CASE PV_OTEXT.
    WHEN 'GR_GRID'.
      SET HANDLER GR_EVENTS->HANDLE_TOOLBAR               FOR PR_GRID.
      SET HANDLER GR_EVENTS->HANDLE_USER_COMMAND          FOR PR_GRID.
      SET HANDLER GR_EVENTS->HANDLE_DATA_CHANGED          FOR PR_GRID.
      SET HANDLER GR_EVENTS->HANDLE_DATA_CHANGED_FINISHED FOR PR_GRID.

      CALL METHOD PR_GRID->SET_READY_FOR_INPUT
        EXPORTING
          I_READY_FOR_INPUT = 1.

      CALL METHOD PR_GRID->REGISTER_EDIT_EVENT
        EXPORTING
          I_EVENT_ID = CL_GUI_ALV_GRID=>MC_EVT_ENTER.

      CALL METHOD PR_GRID->REGISTER_EDIT_EVENT
        EXPORTING
          I_EVENT_ID = CL_GUI_ALV_GRID=>MC_EVT_MODIFIED.

    WHEN OTHERS.

  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_DISP
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_FCAT
*&      --> GT_LIST
*&      --> GR_GRID
*&---------------------------------------------------------------------*
FORM SET_DISP TABLES PT_FCAT TYPE LVC_T_FCAT
                     PT_LIST
               USING PR_GRID TYPE REF TO CL_GUI_ALV_GRID
                     PS_LAYO TYPE LVC_S_LAYO.

  CLEAR : GS_VARI.
  GS_VARI-REPORT = SY-REPID.
  GS_VARI-HANDLE = 1.

  CALL METHOD PR_GRID->SET_TABLE_FOR_FIRST_DISPLAY
    EXPORTING
*     I_BUFFER_ACTIVE      =
*     I_BYPASSING_BUFFER   =
*     I_CONSISTENCY_CHECK  =
*     I_STRUCTURE_NAME     =
      IS_VARIANT           = GS_VARI
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
      IT_OUTTAB            = PT_LIST[]
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

* CALL METHOD PR_GRID->SET_FRONTEND_FIELDCATALOG
*   EXPORTING
*     IT_FIELDCATALOG = GT_FCAT.

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
*& Form CHECK_EXIT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&---------------------------------------------------------------------*
FORM CHECK_EXIT USING PV_MODE.

  PERFORM CHECK_CHGON.

  IF GV_CHG = GC_X. "GT_OLD[] <> GT_LIST[].
    PERFORM POPUP_TO_CONFIRM USING '확인'(P01)
                                   '변경된 Data를 저장하시겠습니까?'(P02).

    IF GV_ANS = GC_1.
      PERFORM SAVE_DATA USING ' '.
      EXIT.
    ENDIF.
  ENDIF.

  PERFORM FREE_OBJ.

  CASE PV_MODE.
    WHEN 'C'.
      LEAVE PROGRAM.
    WHEN 'N'.
      SET SCREEN 0.
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_CHGON
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CHECK_CHGON.

  CLEAR : GV_CHG.

  CHECK LINE_EXISTS( GT_LIST[ STATUS = ICON_CREATE ] )
     OR LINE_EXISTS( GT_LIST[ STATUS = ICON_CHANGE ] ).

  GV_CHG = GC_X.

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
*&---------------------------------------------------------------------*
*& Form HANDLE_TOOLBAR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> E_OBJECT
*&      --> GV_OTEXT
*&---------------------------------------------------------------------*
FORM HANDLE_TOOLBAR USING PR_OBJ TYPE REF TO CL_ALV_EVENT_TOOLBAR_SET
                          PV_OTEXT.

  DATA : LS_TBAR TYPE STB_BUTTON.


  DEFINE _SET_TBAR.
    CLEAR : LS_TBAR.
    LS_TBAR-BUTN_TYPE = &1.
    LS_TBAR-FUNCTION  = &2.
    LS_TBAR-ICON      = &3.
    LS_TBAR-TEXT      = &4.
    LS_TBAR-QUICKINFO = &4.
    APPEND LS_TBAR TO PR_OBJ->MT_TOOLBAR.
  END-OF-DEFINITION.


  CASE PV_OTEXT.
    WHEN 'GR_GRID'.
      _SET_TBAR 3 '    ' '              ' '    '.
      _SET_TBAR 0 'SAVE' ICON_SYSTEM_SAVE 'Save'(B01).
      _SET_TBAR 0 'INSR' ICON_INSERT_ROW  '신규'(B02).
      _SET_TBAR 0 'MISR' ICON_INSERT_ROW  '멀티'(B03).
      _SET_TBAR 0 'DELE' ICON_DELETE_ROW  '삭제'(B04).

    WHEN OTHERS.

  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form HANDLE_USER_COMMAND
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> E_UCOMM
*&      --> GV_OTEXT
*&---------------------------------------------------------------------*
FORM HANDLE_USER_COMMAND USING PV_UCOMM LIKE SY-UCOMM
                               PV_OTEXT.

  CLEAR : GV_REF.

  CASE PV_UCOMM.
    WHEN 'SAVE'.
      PERFORM SAVE_DATA USING 'X'.

    WHEN 'INSR'.
      PERFORM INSR_DATA.

    WHEN 'MISR'.
      PERFORM MISR_DATA.

    WHEN 'DELE'.
      PERFORM DELE_DATA.

  ENDCASE.

* CALL METHOD CL_GUI_CFW=>SET_NEW_OK_CODE
*   EXPORTING
*     NEW_CODE = 'DUMMY'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_STYLE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> P_
*&      --> GT_LIST_STYLE
*&---------------------------------------------------------------------*
FORM SET_STYLE USING PV_MODE
                     PV_FNAME
                     PT_STYLE TYPE LVC_T_STYL.

  DATA : LS_STYLE TYPE LVC_S_STYL.


  LS_STYLE-FIELDNAME = PV_FNAME.

  CASE PV_MODE.
    WHEN 'E'.
      LS_STYLE-STYLE = CL_GUI_ALV_GRID=>MC_STYLE_ENABLED.
    WHEN 'D'.
      LS_STYLE-STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED.
  ENDCASE.

  INSERT LS_STYLE INTO TABLE PT_STYLE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form INSR_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM INSR_DATA.

  CLEAR : GT_LIST.

  GT_LIST-STATUS = ICON_CREATE.
  GT_LIST-TYPE   = GC_I.
  GT_LIST-BUKRS  = P_BUKRS.
  GT_LIST-BUTXT  = G_BUTXT.

  PERFORM SET_STYLE USING 'E' 'WERKS' GT_LIST-STYLE.
  PERFORM SET_STYLE USING 'E' 'ZTYPE' GT_LIST-STYLE.
  PERFORM SET_STYLE USING 'E' 'ZUSE'  GT_LIST-STYLE.

  APPEND GT_LIST.

  GV_REF = GC_X.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form MISR_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM MISR_DATA.

  "신규 멀티 라인 추가 기능(송종면E 24.12.20)

  DATA : LV_RTRN,
         LT_SVAL TYPE TABLE OF SVAL,
         LV_LINE LIKE ZGTMMT1010-SEQ.


  LT_SVAL = VALUE #( (  TABNAME   = 'ZGTMMT1010' "임의지정
                        FIELDNAME = 'SEQ'
                        VALUE     = '2'
                        FIELDTEXT = '추가할 라인 수(1~999)'(T02) ) ).

  CALL FUNCTION 'POPUP_GET_VALUES'
    EXPORTING
*     NO_VALUE_CHECK  = ' '
      POPUP_TITLE     = '라인수 입력'(T01)
*     START_COLUMN    = '5'
*     START_ROW       = '5'
    IMPORTING
      RETURNCODE      = LV_RTRN
    TABLES
      FIELDS          = LT_SVAL
    EXCEPTIONS
      ERROR_IN_FIELDS = 1
      OTHERS          = 2.

  CHECK LV_RTRN IS INITIAL.

  LV_LINE = VALUE #( LT_SVAL[ 1 ]-VALUE OPTIONAL ).

  IF LV_LINE IS INITIAL.
    MESSAGE S015 WITH TEXT-T02 DISPLAY LIKE 'E'. "&를(을)입력하세요.
    EXIT.
  ENDIF.

  DO LV_LINE TIMES.
    PERFORM INSR_DATA.
  ENDDO.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form DELE_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM DELE_DATA.

  PERFORM GET_SELECTED_ROWS USING GR_GRID 'M' 'X'
                                  '삭제할 대상을 선택하세요.'(M01).
  CHECK GV_ERR IS INITIAL.
  PERFORM POPUP_TO_CONFIRM USING '확인'(P01)
                                 '선택한 Data를 완전 삭제하시겠습니까?'(P03).

  CHECK GV_ANS = GC_1.

  GV_REF = GC_X.

  DELETE GT_ROWS WHERE INDEX IS INITIAL.
  SORT GT_ROWS BY INDEX DESCENDING.

  LOOP AT GT_ROWS INTO GS_ROWS.
    READ TABLE GT_LIST INDEX GS_ROWS-INDEX.
    CHECK SY-SUBRC = 0.

    CASE GT_LIST-TYPE.
      WHEN 'I'.

      WHEN OTHERS.
        MOVE-CORRESPONDING GT_LIST TO GT_D10.
        APPEND GT_D10.

    ENDCASE.

    DELETE GT_LIST INDEX GS_ROWS-INDEX.
    DELETE GT_ERR  WHERE INDEX = GS_ROWS-INDEX.
  ENDLOOP.

  CHECK GT_D10[] IS NOT INITIAL.
  DELETE ZGTMMT1000 FROM TABLE GT_D10.

  IF SY-SUBRC = 0.
    COMMIT WORK.

    PERFORM SET_MSG_RST.
    CLEAR : GT_D10[].
*   PERFORM SET_ORGN TABLES GT_LIST GT_OLD.
  ELSE.
    ROLLBACK WORK.

    MESSAGE S014 DISPLAY LIKE 'E'. "삭제에 실패했습니다.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_SELECTED_ROWS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GR_GRID
*&      --> P_
*&      --> P_
*&---------------------------------------------------------------------*
FORM GET_SELECTED_ROWS USING PR_GRID TYPE REF TO CL_GUI_ALV_GRID
                             PV_MODE
                             PV_CHK
                             PV_MSG.

  CLEAR : GT_ROWS, GS_ROWS, GV_ERR.
  CALL METHOD PR_GRID->GET_SELECTED_ROWS
    IMPORTING
      ET_INDEX_ROWS = GT_ROWS.

  DESCRIBE TABLE GT_ROWS.

  CASE SY-TFILL.
    WHEN 0.
      IF PV_CHK = GC_X.
        GV_ERR = GC_X.
        IF PV_MSG IS NOT INITIAL.
          MESSAGE S000 DISPLAY LIKE 'E' WITH PV_MSG.
        ELSE.
          MESSAGE S004 DISPLAY LIKE 'E'. "라인을 선택하세요.
        ENDIF.
      ENDIF.
    WHEN 1.
      IF PV_MODE = GC_S.
        READ TABLE GT_ROWS INTO GS_ROWS INDEX 1.
      ENDIF.
    WHEN OTHERS.
      IF PV_MODE = GC_S.
        GV_ERR = GC_X.
        MESSAGE S005 DISPLAY LIKE 'E'. "하나의 라인만 선택 가능합니다.
      ENDIF.
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form POPUP_TO_CONFIRM
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> P_
*&---------------------------------------------------------------------*
FORM POPUP_TO_CONFIRM USING PV_TITLE
                            PV_QTEXT.

  CLEAR : GV_ANS. "1/2/A

  CALL FUNCTION 'POPUP_TO_CONFIRM' "POPUP_TO_CONFIRM_STEP
    EXPORTING
      TITLEBAR      = PV_TITLE
*     DIAGNOSE_OBJECT             = ' '
      TEXT_QUESTION = PV_QTEXT
*     TEXT_BUTTON_1 = 'Ja'(001)
*     ICON_BUTTON_1 = ' '
*     TEXT_BUTTON_2 = 'Nein'(002)
*     ICON_BUTTON_2 = ' '
*     DEFAULT_BUTTON              = '1'
*     DISPLAY_CANCEL_BUTTON       = 'X'
*     USERDEFINED_F1_HELP         = ' '
*     START_COLUMN  = 25
*     START_ROW     = 6
*     POPUP_TYPE    =
*     IV_QUICKINFO_BUTTON_1       = ' '
*     IV_QUICKINFO_BUTTON_2       = ' '
    IMPORTING
      ANSWER        = GV_ANS.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SAVE_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SAVE_DATA USING PV_POP.

  DATA : L_VALID.


  CLEAR : GT_M10[], GV_ERR.
* CLEAR : GV_TCNT, GV_MCNT, GV_DCNT.

  GR_GRID->CHECK_CHANGED_DATA( IMPORTING E_VALID = L_VALID ).
  CHECK L_VALID IS NOT INITIAL.

  IF PV_POP = GC_X.
    PERFORM CHECK_CHGON.

    IF GV_CHG = GC_X. "GT_OLD[] <> GT_LIST[].
      PERFORM POPUP_TO_CONFIRM USING '확인'(P01)
                                     '변경된 Data를 저장하시겠습니까?'(P02).

      CHECK GV_ANS = GC_1.
    ELSE.
      MESSAGE S017. "변경된 내역이 없습니다.
      EXIT.
    ENDIF.
  ENDIF.

  PERFORM SET_TIMESTAMP USING 'X' 'X'.

  LOOP AT GT_LIST.
    GV_TBX = SY-TABIX.
    PERFORM CHECK_ERR.

    CASE GT_LIST-STATUS.
      WHEN ICON_RED_LIGHT.
        MESSAGE S006 DISPLAY LIKE 'E'. "에러 내역이 존재합니다.
        GV_ERR = GC_X. "EXIT.

      WHEN ICON_CREATE.
        PERFORM SET_M10 USING 'I'.
        GT_LIST-TYPE = GC_S.

      WHEN ICON_CHANGE.
        PERFORM SET_M10 USING 'U'.
        GT_LIST-TYPE = GC_U.

      WHEN OTHERS.
        CONTINUE.

    ENDCASE.

    MODIFY GT_LIST. "TRANSPORTING STATUS MSG_TXT TYPE COLOR.
  ENDLOOP.

  GV_REF = GC_X.

  CHECK GV_ERR IS INITIAL.

  IF GT_D10[] IS INITIAL AND GT_M10[] IS INITIAL.
    MESSAGE S007 DISPLAY LIKE 'E'. "저장할 내역이 없습니다.
    EXIT.
  ENDIF.

  IF GT_D10[] IS NOT INITIAL.
    DELETE ZGTMMT1000 FROM TABLE GT_D10.
    DATA(L_DEL) = SY-SUBRC.
  ENDIF.

  IF GT_M10[] IS NOT INITIAL.
    MODIFY ZGTMMT1000 FROM TABLE GT_M10.
    DATA(L_MOD) = SY-SUBRC.
  ENDIF.

  IF L_DEL = 0 AND L_MOD = 0.
    COMMIT WORK.

    PERFORM UPDATE_RST.
    CLEAR : GT_D10[], GT_M10[].
*   PERFORM SET_ORGN TABLES GT_LIST GT_OLD.
  ELSE.
    ROLLBACK WORK.

    MESSAGE S010 DISPLAY LIKE 'E'. "저장에 실패했습니다.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_TIMESTAMP
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> P_
*&---------------------------------------------------------------------*
FORM SET_TIMESTAMP USING PV_CREA
                         PV_CHNG.

  CLEAR : GS_CREA, GS_CHNG.

  IF PV_CREA = GC_X.
    PERFORM SET_TSTMP USING GS_CREA.
  ENDIF.

  IF PV_CHNG = GC_X.
    PERFORM SET_TSTMP USING GS_CHNG.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_TSTMP
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GS_CREA
*&---------------------------------------------------------------------*
FORM SET_TSTMP USING PS_TIME.

  ASSIGN COMPONENT 1 OF STRUCTURE PS_TIME TO FIELD-SYMBOL(<LFS_DATUM>).
  ASSIGN COMPONENT 2 OF STRUCTURE PS_TIME TO FIELD-SYMBOL(<LFS_DATLO>).
  ASSIGN COMPONENT 3 OF STRUCTURE PS_TIME TO FIELD-SYMBOL(<LFS_UZEIT>).
  ASSIGN COMPONENT 4 OF STRUCTURE PS_TIME TO FIELD-SYMBOL(<LFS_TIMLO>).
  ASSIGN COMPONENT 5 OF STRUCTURE PS_TIME TO FIELD-SYMBOL(<LFS_UNAME>).

  <LFS_DATUM> = SY-DATUM.
  <LFS_DATLO> = SY-DATLO.
  <LFS_UZEIT> = SY-UZEIT.
  <LFS_TIMLO> = SY-TIMLO.
  <LFS_UNAME> = SY-UNAME.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_ERR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CHECK_ERR.

  "신규 라인만 추가하고 값을 입력하지 않을 수 있으므로 필수 필드 Check

  CLEAR : GV_MSG.

  CHECK GT_LIST-TYPE = GC_I. "GT_LIST-STATUS = ICON_CREATE.

  ASSIGN COMPONENT 'COLOR' OF STRUCTURE GT_LIST TO <GFS_COL>.

  PERFORM CHECK_MAND USING GT_LIST-WERKS 'WERKS' '플랜트'(F05).
  PERFORM CHECK_MAND USING GT_LIST-ZTYPE 'ZTYPE' '과제구분'(F07).

  PERFORM RESET_STATUS.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_MAND
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_LIST_WERKS
*&      --> P_
*&---------------------------------------------------------------------*
FORM CHECK_MAND USING P_VAL
                      P_FNM
                      P_TXT.

  IF P_VAL IS INITIAL.
    MESSAGE E008 WITH P_TXT INTO GV_MSG. "필수 값이 누락되었습니다. &

    PERFORM SET_ERR_MSG USING P_FNM 'M'.
    PERFORM SET_ERR_COL USING P_FNM.
  ELSE.
    PERFORM RESET_ERR   USING P_FNM 'M'.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_ERR_MSG
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_FNM
*&      --> P_
*&---------------------------------------------------------------------*
FORM SET_ERR_MSG USING PV_FNM
                       PV_TYPE.

  GS_ERR-INDEX = GV_TBX.
  GS_ERR-FNAME = PV_FNM.
  GS_ERR-MSG   = GV_MSG.
  GS_ERR-TYPE  = PV_TYPE.
  INSERT GS_ERR INTO TABLE GT_ERR.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_ERR_COL
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_FNM
*&---------------------------------------------------------------------*
FORM SET_ERR_COL USING P_FNM.

  APPEND VALUE #( FNAME     = P_FNM
                  COLOR-COL = GC_6
                  COLOR-INT = GC_0
                  COLOR-INV = GC_0 ) TO <GFS_COL>.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form RESET_ERR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_FNM
*&      --> P_
*&---------------------------------------------------------------------*
FORM RESET_ERR USING PV_FNM
                     PV_TYPE.

  DELETE GT_ERR WHERE INDEX = GV_TBX
                  AND FNAME = PV_FNM
                  AND TYPE  = PV_TYPE.

  "여러 타입의 에러가 중복 발생시 구분자 부재로 모두 삭제되어버리는 현상 발생
* IF SY-SUBRC = 0.
*   DELETE <GFS_COL> WHERE FNAME = PV_FNM.
* ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form RESET_STATUS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM RESET_STATUS.

* CHECK GV_MSG IS NOT INITIAL.

  PERFORM SET_MSG_TXT.

  IF GT_LIST-MSG_TXT IS NOT INITIAL.
    GT_LIST-STATUS = ICON_RED_LIGHT.
  ELSE.
    CASE GT_LIST-TYPE.
      WHEN 'I'.
        GT_LIST-STATUS = ICON_CREATE.
      WHEN 'U' OR 'S'.
        GT_LIST-STATUS = ICON_CHANGE.

    ENDCASE.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_MSG_TXT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_MSG_TXT.

  DATA : LR_FNAME TYPE RANGE OF LVC_FNAME.


  CLEAR : GT_LIST-MSG_TXT.

  READ TABLE GT_ERR INTO GS_ERR WITH KEY INDEX = GV_TBX
                                         BINARY SEARCH.

  IF SY-SUBRC = 0.
    GT_LIST-MSG_TXT = GS_ERR-MSG.

    LOOP AT GT_ERR INTO GS_ERR FROM SY-TABIX.
      IF GS_ERR-INDEX <> GV_TBX.
        EXIT.
      ENDIF.

      APPEND VALUE #( SIGN   = GC_E
                      OPTION = GC_EQ
                      LOW    = GS_ERR-FNAME ) TO LR_FNAME.
    ENDLOOP.
  ELSE.
    CLEAR : <GFS_COL>.
  ENDIF.

  CHECK LR_FNAME[] IS NOT INITIAL.
  DELETE <GFS_COL> WHERE FNAME IN LR_FNAME.

* IF SY-SUBRC = 0.
*   DELETE <GFS_COL> WHERE FNAME = PV_FNM.
* ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_M10
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&---------------------------------------------------------------------*
FORM SET_M10 USING P_CHK.

  CASE P_CHK.
    WHEN 'I'.
      MOVE-CORRESPONDING GS_CREA TO GT_LIST.
    WHEN 'U'.
      MOVE-CORRESPONDING GS_CHNG TO GT_LIST.
  ENDCASE.

  MOVE-CORRESPONDING GT_LIST TO GT_M10.
  APPEND GT_M10.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form UPDATE_RST
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM UPDATE_RST.

  LOOP AT GT_LIST.
    CASE GT_LIST-STATUS.
      WHEN ICON_CREATE.
        CLEAR : GT_LIST-STYLE.

      WHEN ICON_CHANGE.
      WHEN ICON_GREEN_LIGHT.

      WHEN OTHERS.
        CONTINUE.

    ENDCASE.

    "이미 저장 작업한 뒤 바로 재작업시..
    IF GT_LIST-STATUS = ICON_GREEN_LIGHT.
      GT_LIST-STATUS = ICON_YELLOW_LIGHT.
    ELSE.
      GT_LIST-STATUS = ICON_GREEN_LIGHT.
    ENDIF.

    GT_LIST-MSG_TXT = SPACE.

    MODIFY GT_LIST TRANSPORTING STATUS MSG_TXT STYLE.
  ENDLOOP.

  SORT GT_LIST BY BUKRS WERKS ZTYPE.

  PERFORM SET_MSG_RST.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_MSG_RST
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_MSG_RST.

  CLEAR : GV_TCNT, GV_MCNT, GV_DCNT.

  GV_MCNT = LINES( GT_M10 ).
  GV_DCNT = LINES( GT_D10 ).
  GV_TCNT = GV_MCNT + GV_DCNT.

  MESSAGE S009 WITH GV_TCNT GV_MCNT GV_DCNT. "총 &1 건: 저장 &2 건, 삭제 &3 건.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form HANDLE_DATA_CHANGED
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> ER_DATA_CHANGED
*&      --> GV_OTEXT
*&---------------------------------------------------------------------*
FORM HANDLE_DATA_CHANGED USING PR_CHNG TYPE REF TO CL_ALV_CHANGED_DATA_PROTOCOL
                               PV_OTEXT.

  CLEAR : GV_REF, GR_DROW[].

  IF PR_CHNG->MT_INSERTED_ROWS IS NOT INITIAL.
    GR_DROW[] = VALUE #( FOR LS_IROW IN PR_CHNG->MT_INSERTED_ROWS
                         ( VALUE #( SIGN = GC_I OPTION = GC_EQ LOW = LS_IROW-ROW_ID ) ) ).

    DELETE PR_CHNG->MT_GOOD_CELLS WHERE ROW_ID IN GR_DROW.
    DELETE PR_CHNG->MT_MOD_CELLS  WHERE ROW_ID IN GR_DROW.
    CLEAR : PR_CHNG->MT_INSERTED_ROWS.
  ENDIF.

  LOOP AT PR_CHNG->MT_GOOD_CELLS INTO GS_MODI.
    CASE GS_MODI-FIELDNAME.
      WHEN 'WERKS'.
        PERFORM MODIFY_CELL USING PR_CHNG 'STATUS' ICON_CHANGE.
      WHEN 'ZTYPE'.
        PERFORM MODIFY_CELL USING PR_CHNG 'STATUS' ICON_CHANGE.
      WHEN 'ZUSE'.
        PERFORM MODIFY_CELL USING PR_CHNG 'STATUS' ICON_CHANGE.
    ENDCASE.

    GV_REF = GC_X.
  ENDLOOP.

  CHECK GR_DROW[] IS NOT INITIAL.
  PERFORM REFRESH_GRID USING GR_GRID
                             GS_LAYO.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form MODIFY_CELL
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PR_CHNG
*&      --> P_
*&      --> P_
*&---------------------------------------------------------------------*
FORM MODIFY_CELL USING PR_CHNG TYPE REF TO CL_ALV_CHANGED_DATA_PROTOCOL
                       PV_FNAME
                       PV_FVAL.

  CALL METHOD PR_CHNG->MODIFY_CELL
    EXPORTING
      I_ROW_ID    = GS_MODI-ROW_ID
      I_FIELDNAME = PV_FNAME
      I_VALUE     = PV_FVAL.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form HANDLE_DATA_CHANGED_FINISHED
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> E_MODIFIED
*&      --> ET_GOOD_CELLS
*&      --> GV_OTEXT
*&---------------------------------------------------------------------*
FORM HANDLE_DATA_CHANGED_FINISHED USING PV_MODI
                                        PT_MODI TYPE LVC_T_MODI
                                        PV_OTEXT.

  CLEAR : GV_REF.
  CHECK PV_MODI IS NOT INITIAL.

  GT_SCR[] = GT_LIST[].
  SORT GT_SCR BY BUKRS WERKS ZTYPE.

  IF GR_DROW[] IS NOT INITIAL.
    DELETE PT_MODI WHERE ROW_ID IN GR_DROW.
  ENDIF.

  LOOP AT PT_MODI INTO GS_MODI.
    READ TABLE GT_LIST INDEX GS_MODI-ROW_ID.
    CHECK SY-SUBRC = 0.

    GV_TBX = GS_MODI-ROW_ID.
    ASSIGN COMPONENT 'COLOR' OF STRUCTURE GT_LIST TO <GFS_COL>.

    PERFORM CHECK_DUP.

    CASE GS_MODI-FIELDNAME.
      WHEN 'WERKS'.
        PERFORM CHANGE_WERKS.

      WHEN 'ZTYPE'.
        PERFORM CHANGE_ZTYPE.

      WHEN 'ZUSE'.
*       PERFORM CHANGE_ZUSE.

    ENDCASE.

    AT END OF ROW_ID.
      PERFORM RESET_STATUS.
    ENDAT.

    MODIFY GT_LIST INDEX GS_MODI-ROW_ID.
    GV_REF = GC_X.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_DUP
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CHECK_DUP.

  CLEAR : GV_ERR, GV_MSG.

  CHECK GT_LIST-TYPE = GC_I. "Only 신규 입력건

  CHECK GT_LIST-BUKRS IS NOT INITIAL
    AND GT_LIST-WERKS IS NOT INITIAL
    AND GT_LIST-ZTYPE IS NOT INITIAL.

  "기 저장 여부 Check
  SELECT SINGLE MANDT
    FROM ZGTMMT1000 INTO @DATA(L_MANDT)
   WHERE BUKRS = @GT_LIST-BUKRS
     AND WERKS = @GT_LIST-WERKS
     AND ZTYPE = @GT_LIST-ZTYPE.

  IF SY-SUBRC = 0.
    MESSAGE E011 INTO GV_MSG. "이미 동일한 데이터가 등록된 상태입니다.
  ELSE.
    PERFORM CHECK_SCR_DUP.
  ENDIF.

  LOOP AT GT_KEY.
    IF GV_MSG IS NOT INITIAL.
      PERFORM SET_ERR_MSG USING GT_KEY-FNAME 'D'.
      PERFORM SET_ERR_COL USING GT_KEY-FNAME.
    ELSE.
      PERFORM RESET_ERR   USING GT_KEY-FNAME 'D'.
    ENDIF.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_SCR_DUP
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CHECK_SCR_DUP.

  DATA : LV_CNT TYPE I.


  READ TABLE GT_SCR WITH KEY BUKRS = GT_LIST-BUKRS
                             WERKS = GT_LIST-WERKS
                             ZTYPE = GT_LIST-ZTYPE
                             BINARY SEARCH.

  CHECK SY-SUBRC = 0.

  LOOP AT GT_SCR FROM SY-TABIX.
    IF NOT ( GT_SCR-BUKRS = GT_LIST-BUKRS
         AND GT_SCR-WERKS = GT_LIST-WERKS
         AND GT_SCR-ZTYPE = GT_LIST-ZTYPE ).
      EXIT.
    ENDIF.

    LV_CNT += 1.
  ENDLOOP.

  CHECK LV_CNT > 1.
  MESSAGE E012 INTO GV_MSG. "중복된 데이터가 존재합니다.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHANGE_WERKS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CHANGE_WERKS.

  PERFORM CHECK_MAND USING GT_LIST-WERKS 'WERKS' '플랜트'(F05).

  PERFORM CHECK_T001W USING GT_LIST-WERKS
                   CHANGING GT_LIST-PLANTNAME.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHANGE_ZTYPE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CHANGE_ZTYPE.

  PERFORM CHECK_MAND USING GT_LIST-ZTYPE 'ZTYPE' '과제구분'(F07).

  PERFORM SET_DD07V USING 'ZGTDMMTYPE'
                          GT_LIST-ZTYPE
                 CHANGING GT_LIST-TYPENAME.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_T001W
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_LIST_WERKS
*&      <-- GT_LIST_PLANTNAME
*&---------------------------------------------------------------------*
FORM CHECK_T001W USING PV_WERKS
              CHANGING PV_WNAME.

  CLEAR : PV_WNAME.
  CHECK PV_WERKS IS NOT INITIAL.

  SELECT SINGLE W~NAME1 INTO PV_WNAME
    FROM T001W AS W INNER JOIN T001K AS K
      ON W~BWKEY = K~BWKEY
   WHERE K~BUKRS = P_BUKRS
     AND W~WERKS = PV_WERKS.

  IF SY-SUBRC <> 0.
    MESSAGE E013 WITH PV_WERKS INTO GV_MSG. "입력된 값이 올바르지 않습니다. &

    PERFORM SET_ERR_MSG USING 'WERKS' 'V'.
    PERFORM SET_ERR_COL USING 'WERKS'.
  ELSE.
    PERFORM RESET_ERR   USING 'WERKS' 'V'.
  ENDIF.

ENDFORM.
