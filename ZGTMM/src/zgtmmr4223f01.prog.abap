*&---------------------------------------------------------------------*
*& Include          ZGTMMR4223F01
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

  "입력값 유효성 Check
  PERFORM CHECK_WERKS.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_WERKS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CHECK_WERKS.

  CLEAR : GS_MCON.

  CHECK P_WERKS IS NOT INITIAL.

  SELECT SINGLE WERKS NAME1
    FROM T001W
    INTO CORRESPONDING FIELDS OF GS_MCON
   WHERE WERKS = P_WERKS
     AND SPRAS = SY-LANGU.

  CHECK GS_MCON-WERKS IS INITIAL.

  SET CURSOR FIELD 'P_WERKS'.
  MESSAGE E016 WITH '플랜트'(F03). "&를(을) 확인하세요.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_AUTH
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CHECK_AUTH.

  AUTHORITY-CHECK OBJECT 'ZPP_WERKS'
               ID 'WERKS' FIELD P_WERKS.

  CHECK SY-SUBRC <> 0.

  SET CURSOR FIELD 'P_WERKS'.
  MESSAGE E106 WITH P_WERKS. "플랜트 [&] 작업권한을 확인하세요.

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

  GT_KEY[] = VALUE #( ( FNAME = GC_BWART ) ).

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
  CLEAR : GT_D20[],  GT_M20[].

  SELECT M~WERKS
         W~NAME1
         M~BWART
         M~SHKZG
         M~ERDAT
         M~ERDAT_LOCAL
         M~ERTIM
         M~ERTIM_LOCAL
         M~ERNAM
    FROM ZGTMMT4200 AS M INNER JOIN T001W AS W
      ON M~WERKS = W~WERKS
    INTO CORRESPONDING FIELDS OF TABLE GT_LIST
   WHERE M~WERKS = P_WERKS.

  IF GT_LIST[] IS INITIAL.
    MESSAGE S002 DISPLAY LIKE 'E'. "조회된 값이 없습니다.
    EXIT.
  ENDIF.

  SORT GT_LIST BY WERKS BWART.

  GV_CNT = LINES( GT_LIST ).
  MESSAGE S003 WITH GV_CNT. "& 건의 데이터가 조회되었습니다.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_OBJ
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_OBJ.

  GR_DOCK = NEW #( REPID     = SY-REPID
                   DYNNR     = SY-DYNNR
                   SIDE      = CL_GUI_DOCKING_CONTAINER=>DOCK_AT_TOP
                   EXTENSION = 655 ).

  GR_GRID = NEW #( I_PARENT      = GR_DOCK
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

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_LAYO
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_LAYO.

  CLEAR : GS_LAYO.

  GS_LAYO-SEL_MODE   = GC_D.
  GS_LAYO-CWIDTH_OPT = GC_X.
  GS_LAYO-ZEBRA      = GC_X.
  GS_LAYO-STYLEFNAME = GC_STYLE.
  GS_LAYO-CTAB_FNAME = GC_COLOR.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_FCAT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_FCAT.

  DATA : LT_FCAT TYPE SLIS_T_FIELDCAT_ALV.


  CLEAR : LT_FCAT[], GT_FCAT[].

  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      I_PROGRAM_NAME     = SY-REPID
      I_INTERNAL_TABNAME = 'GT_LIST'
*     I_INCLNAME         = SY-REPID
      I_BYPASSING_BUFFER = GC_X
*     I_BUFFER_ACTIVE    = ''
    CHANGING
      CT_FIELDCAT        = LT_FCAT[].

  CALL FUNCTION 'LVC_TRANSFER_FROM_SLIS'
    EXPORTING
      IT_FIELDCAT_ALV = LT_FCAT[]
    IMPORTING
      ET_FIELDCAT_LVC = GT_FCAT[]
    TABLES
      IT_DATA         = GT_LIST
    EXCEPTIONS
      IT_DATA_MISSING = 1
      OTHERS          = 2.

  LOOP AT GT_FCAT INTO GS_FCAT.
    CLEAR : GS_FCAT-KEY.

    PERFORM SET_LIST_FCAT.
    MODIFY GT_FCAT FROM GS_FCAT.
  ENDLOOP.

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
      GS_FCAT-KEY  = GC_X.
    WHEN 'MSG_TXT'.
      PERFORM SET_FTXT USING 'Message'(F02).
      GS_FCAT-KEY  = GC_X.
    WHEN 'WERKS'.
      PERFORM SET_FTXT USING '플랜트'(F03).
      GS_FCAT-KEY  = GC_X.
    WHEN 'NAME1'.
      PERFORM SET_FTXT USING '플랜트명'(F04).
      GS_FCAT-KEY  = GC_X.
    WHEN 'BWART'.
      PERFORM SET_FTXT USING '이동유형'(F05).
      GS_FCAT-KEY        = GC_X.
      GS_FCAT-CHECKTABLE = GC_EM.
    WHEN 'SHKZG'.
      PERFORM SET_FTXT USING '차대구분'(F06).
      GS_FCAT-EDIT   = GC_X.
      GS_FCAT-VALEXI = GC_EM.
    WHEN 'ERDAT'.
      PERFORM SET_FTXT USING '생성일'(F07).
    WHEN 'ERDAT_LOCAL'.
      PERFORM SET_FTXT USING '생성일(Local)'(F08).
    WHEN 'ERTIM'.
      PERFORM SET_FTXT USING '생성시간'(F09).
    WHEN 'ERTIM_LOCAL'.
      PERFORM SET_FTXT USING '생성시간(Local)'(F10).
    WHEN 'ERNAM'.
      PERFORM SET_FTXT USING '생성자'(F11).

    WHEN OTHERS.
      GS_FCAT-NO_OUT = GC_X.
      GS_FCAT-TECH   = GC_X.
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_EVNT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_EVNT.

  GR_EVENTS = NEW LCL_EVENT_HANDLER( E_OBJECT_TEXT = 'GR_GRID' ).

  SET HANDLER GR_EVENTS->HANDLE_TOOLBAR               FOR GR_GRID.
  SET HANDLER GR_EVENTS->HANDLE_USER_COMMAND          FOR GR_GRID.
  SET HANDLER GR_EVENTS->HANDLE_DATA_CHANGED          FOR GR_GRID.
  SET HANDLER GR_EVENTS->HANDLE_DATA_CHANGED_FINISHED FOR GR_GRID.
* SET HANDLER GR_EVENTS->HANDLE_ONF4                  FOR GR_GRID.
* SET HANDLER GR_EVENTS->HANDLE_HOTSPOT_CLICK         FOR GR_GRID.

  CALL METHOD GR_GRID->SET_READY_FOR_INPUT
    EXPORTING
      I_READY_FOR_INPUT = 1.

  CALL METHOD GR_GRID->REGISTER_EDIT_EVENT
    EXPORTING
      I_EVENT_ID = CL_GUI_ALV_GRID=>MC_EVT_ENTER.

  CALL METHOD GR_GRID->REGISTER_EDIT_EVENT
    EXPORTING
      I_EVENT_ID = CL_GUI_ALV_GRID=>MC_EVT_MODIFIED.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_DISP
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_DISP.

  CLEAR : GS_VARI.
  GS_VARI-REPORT   = SY-REPID.
  GS_VARI-HANDLE   = SY-DYNNR.
  GS_VARI-USERNAME = SY-UNAME.

  CALL METHOD GR_GRID->SET_TABLE_FOR_FIRST_DISPLAY
    EXPORTING
*     I_BUFFER_ACTIVE      =
*     I_BYPASSING_BUFFER   =
*     I_CONSISTENCY_CHECK  =
*     I_STRUCTURE_NAME     =
      IS_VARIANT           = GS_VARI
      I_SAVE               = GC_A
*     I_DEFAULT            = GC_X
      IS_LAYOUT            = GS_LAYO
*     IS_PRINT             =
*     IT_SPECIAL_GROUPS    =
      IT_TOOLBAR_EXCLUDING = GT_EXCL
*     IT_HYPERLINK         =
*     IT_ALV_GRAPHICS      =
*     IT_EXCEPT_QINFO      =
*     IR_SALV_ADAPTER      =
    CHANGING
      IT_OUTTAB            = GT_LIST[]
      IT_FIELDCATALOG      = GT_FCAT[].
*     IT_SORT              = GT_SORT[].
*     IT_FILTER            =

ENDFORM.
*&---------------------------------------------------------------------*
*& Form REFRESH_GRID
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM REFRESH_GRID.

  DATA : LS_STBL TYPE LVC_S_STBL.


  LS_STBL-ROW = GC_X.
  LS_STBL-COL = GC_X.

  CALL METHOD GR_GRID->SET_FRONTEND_LAYOUT
    EXPORTING
      IS_LAYOUT = GS_LAYO.

  CALL METHOD GR_GRID->REFRESH_TABLE_DISPLAY
    EXPORTING
      IS_STABLE = LS_STBL
*     I_SOFT_REFRESH = GC_X
    EXCEPTIONS
      FINISHED  = 1
      OTHERS    = 2.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form POPUP_TO_CONFIRM
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> P_
*&---------------------------------------------------------------------*
FORM POPUP_TO_CONFIRM  USING PV_TITLE
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
*& Form CHECK_EXIT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&---------------------------------------------------------------------*
FORM CHECK_EXIT USING PV_MODE.

  PERFORM CHECK_CHGON.

  IF GV_CHG = GC_X.
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
     OR LINE_EXISTS( GT_LIST[ STATUS = ICON_CHANGE ] )
     OR LINE_EXISTS( GT_LIST[ STATUS = ICON_RED_LIGHT ] ).

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

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SAVE_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&---------------------------------------------------------------------*
FORM SAVE_DATA USING PV_POP.

  DATA : L_VALID.


  CLEAR : GT_M20[], GV_ERR, GV_REF.

  GR_GRID->CHECK_CHANGED_DATA( IMPORTING E_VALID = L_VALID ).
  CHECK L_VALID IS NOT INITIAL.

  IF PV_POP = GC_X.
    PERFORM CHECK_CHGON.

    IF GV_CHG = GC_X.
      PERFORM POPUP_TO_CONFIRM USING '확인'(P01)
                                     '변경된 Data를 저장하시겠습니까?'(P02).

      CHECK GV_ANS = GC_1.
    ELSE.
      MESSAGE S017. "변경된 내역이 없습니다.
      EXIT.
    ENDIF.
  ENDIF.

  GV_REF = GC_X.

  PERFORM CHECK_ERROR.
  CHECK GV_ERR IS INITIAL.

  PERFORM SET_TIMESTAMP USING 'X' 'X'.

  LOOP AT GT_LIST.
    CASE GT_LIST-STATUS.
      WHEN ICON_CREATE.
        PERFORM SET_M20 USING 'I'.

      WHEN ICON_CHANGE.
        PERFORM SET_M20 USING 'U'.

      WHEN OTHERS.
        CONTINUE.

    ENDCASE.

    MODIFY GT_LIST.
  ENDLOOP.

  IF GT_D20[] IS INITIAL AND GT_M20[] IS INITIAL.
    MESSAGE S007 DISPLAY LIKE 'E'. "저장할 내역이 없습니다.
    EXIT.
  ENDIF.

  IF GT_D20[] IS NOT INITIAL. "의미가 있나?
    DELETE ZGTMMT4200 FROM TABLE GT_D20.
    DATA(L_DEL) = SY-SUBRC.
  ENDIF.

  IF GT_M20[] IS NOT INITIAL.
    MODIFY ZGTMMT4200 FROM TABLE GT_M20.
    DATA(L_MOD) = SY-SUBRC.
  ENDIF.

  IF L_DEL = 0 AND L_MOD = 0.
    COMMIT WORK.

    PERFORM SET_URST.
    PERFORM SET_MRST.
    CLEAR : GT_D20[], GT_M20[].
  ELSE.
    ROLLBACK WORK.

    MESSAGE S010 DISPLAY LIKE 'E'. "저장에 실패했습니다.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_ERROR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CHECK_ERROR.

  LOOP AT GT_LIST.
    GV_TBX = SY-TABIX.
    PERFORM CHECK_ERR.

    CASE GT_LIST-STATUS.
      WHEN ICON_RED_LIGHT.
        MESSAGE S006 DISPLAY LIKE 'E'. "에러 내역이 존재합니다.
        GV_ERR = GC_X. "EXIT.

      WHEN OTHERS.
        CONTINUE.

    ENDCASE.

    MODIFY GT_LIST.
  ENDLOOP.

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

  CLEAR : GV_MSG, GV_SEQ.

  CHECK GT_LIST-TYPE = GC_I.

  ASSIGN COMPONENT 'COLOR' OF STRUCTURE GT_LIST TO <GFS_COL>.

  PERFORM CHECK_MAND USING GT_LIST-BWART 'BWART' '이동유형'(F05).
  PERFORM CHECK_MAND USING GT_LIST-SHKZG 'SHKZG' '차대구분'(F06).

  PERFORM RESET_STATUS.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_MAND
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_LIST_BWART
*&      --> P_
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

  GV_SEQ += 1.

  GS_ERR-INDEX = GV_TBX.
  GS_ERR-F_SEQ = GV_SEQ.
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

  PERFORM SET_MSG_TXT.

  IF GT_LIST-MSG_TXT IS NOT INITIAL.
    GT_LIST-STATUS = ICON_RED_LIGHT.
    PERFORM SET_LIST_CUR.
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


  CLEAR : GV_FNM, GT_LIST-MSG_TXT.

  READ TABLE GT_ERR INTO GS_ERR WITH KEY INDEX = GV_TBX
                                         BINARY SEARCH.

  IF SY-SUBRC = 0.
    GV_FNM          = GS_ERR-FNAME.
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

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_LIST_CUR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_LIST_CUR.

  CLEAR : GS_ROW, GS_COL.
  GS_ROW-INDEX     = GV_TBX.
  GS_COL-FIELDNAME = GV_FNM.

  CALL METHOD GR_GRID->SET_CURRENT_CELL_VIA_ID
    EXPORTING
      IS_ROW_ID    = GS_ROW
      IS_COLUMN_ID = GS_COL.
*     IS_ROW_NO    =

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
*& Form SET_M20
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&---------------------------------------------------------------------*
FORM SET_M20 USING P_CHK.

  CASE P_CHK.
    WHEN 'I'.
      MOVE-CORRESPONDING GS_CREA TO GT_LIST.
      GT_LIST-TYPE = GC_S.
    WHEN 'U'.
      MOVE-CORRESPONDING GS_CHNG TO GT_LIST.
      GT_LIST-TYPE = GC_U.
  ENDCASE.

  MOVE-CORRESPONDING GT_LIST TO GT_M20.
  APPEND GT_M20.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_URST
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_URST.

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

  SORT GT_LIST BY WERKS BWART.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_MRST
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_MRST.

  CLEAR : GV_TCNT, GV_MCNT, GV_DCNT.

  GV_MCNT = LINES( GT_M20 ).
  GV_DCNT = LINES( GT_D20 ).
  GV_TCNT = GV_MCNT + GV_DCNT.

  MESSAGE S009 WITH GV_TCNT GV_MCNT GV_DCNT. "총 &1 건: 저장 &2 건, 삭제 &3 건.

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
  GT_LIST-WERKS  = P_WERKS.
  GT_LIST-NAME1  = GS_MCON-NAME1.

  PERFORM SET_STYLE USING 'E' 'BWART' GT_LIST-STYLE.
  PERFORM SET_STYLE USING 'E' 'SHKZG' GT_LIST-STYLE.

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
*& Form GET_SELECTED_ROWS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GR_GRID
*&      --> P_
*&      --> P_
*&      --> P_
*&---------------------------------------------------------------------*
FORM GET_SELECTED_ROWS USING PR_GRID TYPE REF TO CL_GUI_ALV_GRID
                             PV_MODE
                             PV_CHK
                             PV_MSG.

  CLEAR : GT_ROW, GS_ROW, GV_ERR.
  CALL METHOD PR_GRID->GET_SELECTED_ROWS
    IMPORTING
      ET_INDEX_ROWS = GT_ROW.

  DESCRIBE TABLE GT_ROW.

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
        READ TABLE GT_ROW INTO GS_ROW INDEX 1.
      ENDIF.
    WHEN OTHERS.
      IF PV_MODE = GC_S.
        GV_ERR = GC_X.
        MESSAGE S005 DISPLAY LIKE 'E'. "하나의 라인만 선택 가능합니다.
      ENDIF.
  ENDCASE.

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

  DELETE GT_ROW WHERE INDEX IS INITIAL.
  SORT GT_ROW BY INDEX DESCENDING.

  PERFORM CHK_DEL_LIST.

  IF GV_CHK = GC_X.
    PERFORM POPUP_TO_CONFIRM USING '확인'(P01)
                                   '저장되었던 데이터를 삭제합니다. 삭제하시겠습니까?'(P03).

    CHECK GV_ANS = GC_1.
  ENDIF.

  GV_REF = GC_X.

  PERFORM DEL_TAB_DATA.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHK_DEL_LIST
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CHK_DEL_LIST.

  CLEAR : GT_D20[], GR_IDX[], GV_CHK.

  GT_TMP[] = GT_LIST[].

  LOOP AT GT_ROW INTO GS_ROW.
    READ TABLE GT_TMP INDEX GS_ROW-INDEX.
    CHECK SY-SUBRC = 0.

    CASE GT_TMP-TYPE.
      WHEN 'I'. "신규 라인

      WHEN OTHERS.
        GV_CHK = GC_X.
        MOVE-CORRESPONDING GT_TMP TO GT_D20.
        APPEND GT_D20.

    ENDCASE.

    DELETE GT_TMP INDEX GS_ROW-INDEX.

    APPEND VALUE #( SIGN   = GC_I
                    OPTION = GC_EQ
                    LOW    = GS_ROW-INDEX ) TO GR_IDX.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form DEL_TAB_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM DEL_TAB_DATA.

  GT_LIST[] = GT_TMP[].

  DELETE GT_ERR WHERE INDEX IN GR_IDX.

  CHECK GT_D20[] IS NOT INITIAL.
  DELETE ZGTMMT4200 FROM TABLE GT_D20.

  IF SY-SUBRC = 0.
    COMMIT WORK.

    PERFORM SET_MRST.
    CLEAR : GT_D20[].
  ELSE.
    ROLLBACK WORK.

    MESSAGE S014 DISPLAY LIKE 'E'. "삭제에 실패했습니다.
  ENDIF.

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
      WHEN 'BWART' OR 'SHKZG'.
        PERFORM MODIFY_CELL USING PR_CHNG 'STATUS' ICON_CHANGE.

      WHEN OTHERS.

    ENDCASE.

    GV_REF = GC_X.
  ENDLOOP.

  CHECK GR_DROW[] IS NOT INITIAL. "ALV List 반영!
  PERFORM REFRESH_GRID.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form MODIFY_CELL
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PR_CHNG
*&      --> P_
*&      --> ICON_CHANGE
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
  SORT GT_SCR BY WERKS BWART.

  IF GR_DROW[] IS NOT INITIAL.
    DELETE PT_MODI WHERE ROW_ID IN GR_DROW.
  ENDIF.

  LOOP AT PT_MODI INTO GS_MODI.
    READ TABLE GT_LIST INDEX GS_MODI-ROW_ID.
    CHECK SY-SUBRC = 0.

    AT NEW ROW_ID.
      GV_NEW = GC_X.
    ENDAT.

    GV_SEQ = SPACE.
    GV_TBX = GS_MODI-ROW_ID.
    ASSIGN COMPONENT 'COLOR' OF STRUCTURE GT_LIST TO <GFS_COL>.

    PERFORM CHECK_DUP.

    CASE GS_MODI-FIELDNAME.
      WHEN 'BWART'.
        PERFORM CHANGE_BWART.

      WHEN 'SHKZG'.
        PERFORM CHANGE_SHKZG.

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

  CHECK   GV_NEW = GC_X.
  CLEAR : GV_NEW.

  CHECK GT_LIST-TYPE = GC_I. "Only 신규 입력건

  CHECK GT_LIST-WERKS IS NOT INITIAL
    AND GT_LIST-BWART IS NOT INITIAL.

  "기 저장 여부 Check
  SELECT SINGLE MANDT
    FROM ZGTMMT4200 INTO @DATA(L_MANDT)
   WHERE WERKS = @GT_LIST-WERKS
     AND BWART = @GT_LIST-BWART.

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


  READ TABLE GT_SCR WITH KEY WERKS = GT_LIST-WERKS
                             BWART = GT_LIST-BWART
                             BINARY SEARCH.

  CHECK SY-SUBRC = 0.

  LOOP AT GT_SCR FROM SY-TABIX.
    IF NOT ( GT_SCR-WERKS = GT_LIST-WERKS
         AND GT_SCR-BWART = GT_LIST-BWART ).
      EXIT.
    ENDIF.

    LV_CNT += 1.
  ENDLOOP.

  CHECK LV_CNT > 1.
  MESSAGE E012 INTO GV_MSG. "중복된 데이터가 존재합니다.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHANGE_BWART
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CHANGE_BWART.

  PERFORM CHECK_MAND USING GT_LIST-BWART 'BWART' '이동유형'(F05).

  PERFORM CHECK_T156 USING GT_LIST-BWART.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_T156
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_LIST_BWART
*&---------------------------------------------------------------------*
FORM CHECK_T156 USING PV_BWART.

  CHECK PV_BWART IS NOT INITIAL.

  SELECT SINGLE BWART
    FROM T156 INTO @DATA(LV_BWART)
   WHERE BWART = @PV_BWART.

  IF SY-SUBRC <> 0.
    MESSAGE E081 WITH '이동유형'(F05) INTO GV_MSG. "존재하지 않는 &입니다.

    PERFORM SET_ERR_MSG USING 'BWART' 'V'.
    PERFORM SET_ERR_COL USING 'BWART'.
  ELSE.
    PERFORM RESET_ERR   USING 'BWART' 'V'.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHANGE_SHKZG
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CHANGE_SHKZG.

  PERFORM CHECK_MAND USING GT_LIST-SHKZG 'SHKZG' '차대구분'(F06).

  PERFORM CHECK_SHKZG USING GT_LIST-SHKZG.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_SHKZG
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_LIST_SHKZG
*&---------------------------------------------------------------------*
FORM CHECK_SHKZG USING PV_SHKZG.

  CHECK PV_SHKZG IS NOT INITIAL.

  IF PV_SHKZG = GC_H OR PV_SHKZG = GC_S.
    PERFORM RESET_ERR   USING 'SHKZG' 'V'.
  ELSE.
    MESSAGE E081 WITH '차대구분'(F06) INTO GV_MSG. "존재하지 않는 &입니다.

    PERFORM SET_ERR_MSG USING 'SHKZG' 'V'.
    PERFORM SET_ERR_COL USING 'SHKZG'.
  ENDIF.

ENDFORM.
