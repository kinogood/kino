*&---------------------------------------------------------------------*
*& Include          ZGTMMR6300F01
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

  P_EKORG = GC_1100.

  "버튼 Text 고정(박상진E 25.02.11)
  GV_DC = GC_D. "최초(조회)

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

  "자재번호 없는 것 대상(박상진E 25.02.11)

  SELECT @ICON_LED_YELLOW AS STATUS,
         P~INFNR,
         P~EKORG,
         P~ESOKZ,
         P~WERKS,
         P~MATKL,
         P~IDNLF,
         P~LIFNR,
         L~NAME1,
         P~DATAB,
         P~DATBI,
         P~KONWA,
         P~KBETR,
         P~PEINH,
         P~BPRME,
         P~TXZ01,
         T~WGBEZ
    FROM ZGTMM_CV_BD_INFO_PRICE AS P LEFT JOIN LFA1 AS L
      ON P~LIFNR = L~LIFNR
     AND L~LOEVM = @SPACE
    LEFT JOIN T023T AS T
      ON P~MATKL = T~MATKL
     AND T~SPRAS = @SY-LANGU
   WHERE P~EKORG  = @P_EKORG
     AND P~WERKS  = @P_WERKS
     AND P~LIFNR IN @S_LIFNR
     AND P~MATKL IN @S_MATKL
     AND P~MATNR  = @SPACE
     AND P~MATKL <> @SPACE
     AND P~IDNLF IN @S_IDNLF
     AND P~ESOKZ IN @S_ESOKZ
     AND P~INFNR IN @S_INFNR
     AND P~DATBI  = @GC_99991231
    INTO CORRESPONDING FIELDS OF TABLE @GT_LIST.

  IF GT_LIST[] IS INITIAL.
    MESSAGE S002 DISPLAY LIKE 'E'. "조회된 값이 없습니다.
    EXIT.
  ENDIF.

  PERFORM SET_COLOR_LIST.

  SORT GT_LIST BY MATKL IDNLF LIFNR
                  INFNR ESOKZ.

  GV_CNT = LINES( GT_LIST ).
  MESSAGE S003 WITH GV_CNT. "& 건의 데이터가 조회되었습니다.

  PERFORM SET_CCHK TABLES GT_LIST GT_CCHK.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_COLOR_LIST
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_COLOR_LIST.

  CLEAR : GT_LIST-COLOR.

  PERFORM SET_COLOR USING 'STATUS' '4' '1' '0' GT_LIST-COLOR.
  PERFORM SET_COLOR USING 'INFNR'  '4' '1' '0' GT_LIST-COLOR.
  PERFORM SET_COLOR USING 'EKORG'  '4' '1' '0' GT_LIST-COLOR.
  PERFORM SET_COLOR USING 'ESOKZ'  '4' '1' '0' GT_LIST-COLOR.
  PERFORM SET_COLOR USING 'WERKS'  '4' '1' '0' GT_LIST-COLOR.
  PERFORM SET_COLOR USING 'MATKL'  '4' '1' '0' GT_LIST-COLOR.

  PERFORM SET_COLOR USING 'DATAB'  '3' '0' '0' GT_LIST-COLOR.
  PERFORM SET_COLOR USING 'DATBI'  '3' '0' '0' GT_LIST-COLOR.

  PERFORM SET_COLOR USING 'KONWA'  '5' '0' '0' GT_LIST-COLOR.
  PERFORM SET_COLOR USING 'KBETR'  '5' '0' '0' GT_LIST-COLOR.
  PERFORM SET_COLOR USING 'PEINH'  '5' '0' '0' GT_LIST-COLOR.
  PERFORM SET_COLOR USING 'BPRME'  '5' '0' '0' GT_LIST-COLOR.

  MODIFY GT_LIST TRANSPORTING COLOR WHERE COLOR IS INITIAL.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_COLOR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> P_
*&      --> P_
*&      --> P_
*&      --> GT_LIST_COLOR
*&---------------------------------------------------------------------*
FORM SET_COLOR USING PV_FNM
                     PV_COL
                     PV_INT
                     PV_INV
                     PT_COL TYPE LVC_T_SCOL.

  DATA : LS_COL TYPE LVC_S_SCOL.


  LS_COL-FNAME     = PV_FNM.
  LS_COL-COLOR-COL = PV_COL.
  LS_COL-COLOR-INT = PV_INT.
  LS_COL-COLOR-INV = PV_INV.

  INSERT LS_COL INTO TABLE PT_COL.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_CCHK
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_LIST
*&      --> GT_CCHK
*&---------------------------------------------------------------------*
FORM SET_CCHK TABLES PT_LIST
                     PT_CCHK. "STRUCTURE GT_CCHK.

  PT_CCHK[] = CORRESPONDING #( PT_LIST[] ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_GUI
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_GUI.

  CASE GV_DC.
    WHEN 'D'.
      GT_EXCD[] = VALUE #( ( 'SAVE' ) ).
    WHEN 'C'.
      CLEAR : GT_EXCD[].
  ENDCASE.

  "공급업체 복사 기능 추가(PSJ 25.03.21)
  IF P_CALLD <> GC_X.
    GT_EXCD[] = VALUE #( BASE GT_EXCD[]
                             ( 'COPY' ) ).
  ENDIF.

  SET PF-STATUS '0100' EXCLUDING GT_EXCD.
  SET TITLEBAR  '0100'.

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
      PERFORM SET_FTXT USING 'Msg'(F01).
      GS_FCAT-KEY     = GC_X.
      GS_FCAT-JUST    = GC_C.
    WHEN 'INFNR'.
      PERFORM SET_FTXT USING '정보레코드'(F02).
      GS_FCAT-KEY     = GC_X.
      GS_FCAT-HOTSPOT = GC_X.
    WHEN 'EKORG'.
      PERFORM SET_FTXT USING '구매조직'(F03).
      GS_FCAT-KEY     = GC_X.
      GS_FCAT-JUST    = GC_C.
    WHEN 'ESOKZ'.
      PERFORM SET_FTXT USING '범주'(F04).
      GS_FCAT-KEY     = GC_X.
      GS_FCAT-JUST    = GC_C.
    WHEN 'WERKS'.
      PERFORM SET_FTXT USING '플랜트'(F05).
      GS_FCAT-KEY     = GC_X.
      GS_FCAT-JUST    = GC_C.
    WHEN 'MATKL'.
      PERFORM SET_FTXT USING '자재그룹'(F06).
      GS_FCAT-KEY     = GC_X.
    WHEN 'IDNLF'.
      PERFORM SET_FTXT USING '외주공정 자재그룹'(F07).
*     GS_FCAT-EDIT    = GC_X.
    WHEN 'LIFNR'.
      PERFORM SET_FTXT USING '공급업체'(F08).
    WHEN 'NAME1'.
      PERFORM SET_FTXT USING '공급업체명'(F09).
    WHEN 'DATAB'.
      PERFORM SET_FTXT USING '효력 시작일'(F10).
    WHEN 'DATBI'.
      PERFORM SET_FTXT USING '효력 종료일'(F11).
    WHEN 'KONWA'.
      PERFORM SET_FTXT USING '통화'(F12).
    WHEN 'KBETR'.
      PERFORM SET_FTXT USING '단가'(F13).
    WHEN 'PEINH'.
      PERFORM SET_FTXT USING '/'(F14).
    WHEN 'BPRME'.
      PERFORM SET_FTXT USING '단위'(F15).
    WHEN 'TXZ01'.
      PERFORM SET_FTXT USING '정보레코드 내역'(F16).
    WHEN 'WGBEZ'.
      PERFORM SET_FTXT USING '자재그룹 내역'(F17).

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

* SET HANDLER GR_EVENTS->HANDLE_DATA_CHANGED          FOR GR_GRID.
* SET HANDLER GR_EVENTS->HANDLE_DATA_CHANGED_FINISHED FOR GR_GRID.
  SET HANDLER GR_EVENTS->HANDLE_DOUBLE_CLICK          FOR GR_GRID.
  SET HANDLER GR_EVENTS->HANDLE_HOTSPOT_CLICK         FOR GR_GRID.

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
                                   '변경건이 있습니다. 저장하시겠습니까?'(P02).

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

  DATA : LT_CCHK LIKE GT_CCHK OCCURS 0 WITH HEADER LINE.


  CLEAR : GV_CHG.

  PERFORM SET_CCHK TABLES GT_LIST LT_CCHK.

  CHECK LT_CCHK[] <> GT_CCHK[].

  GV_CHG = GC_X. "변경 내역 존재!

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
*& Form REFR_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM REFR_DATA.

  PERFORM GET_DATA.
  GV_REF = GC_X.

  GV_DC  = GC_D.  "최초(초기상태)

ENDFORM.
*&---------------------------------------------------------------------*
*& Form DSCH_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM DSCH_DATA.

  CASE GV_DC.
    WHEN 'D'.
      GV_DC = GC_C.
      PERFORM SET_STYLE USING 'E' 'IDNLF' GT_LIST-STYLE.

    WHEN 'C'. "'수정'.
      PERFORM CHECK_CHGON.

      IF GV_CHG = GC_X.
        PERFORM POPUP_TO_CONFIRM USING '확인'(P01)
                                       '변경건이 있습니다. 조회 모드로 바꾸시겠습니까?'(P03).

        IF GV_ANS = GC_1.
          PERFORM REFR_DATA.
          EXIT.
        ELSE.
          DATA(LV_PSS) = GC_X. "수정 모드 유지
        ENDIF.
      ELSE.
        GV_DC = GC_D.
        CLEAR : GT_LIST-STYLE.
      ENDIF.

  ENDCASE.

  CHECK LV_PSS IS INITIAL. "모드 변경시

  MODIFY GT_LIST TRANSPORTING STYLE WHERE INFNR IS NOT INITIAL.
  GV_REF = GC_X.

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
*& Form SAVE_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&---------------------------------------------------------------------*
FORM SAVE_DATA USING PV_POP.

  DATA : L_VALID.


  CLEAR : GV_SUC, GV_FAL, GV_TOT.

  GR_GRID->CHECK_CHANGED_DATA( IMPORTING E_VALID = L_VALID ).
  CHECK L_VALID IS NOT INITIAL.

  PERFORM GET_SELECTED_ROWS USING GR_GRID 'M' 'X'
                                  '저장할 레코드를 선택하세요.'(M01).
  CHECK GV_ERR IS INITIAL.

  IF PV_POP = GC_X.
    PERFORM CHECK_CHGON.

    IF GV_CHG = GC_X.
      PERFORM POPUP_TO_CONFIRM USING '확인'(P01)
                                     '변경건이 있습니다. 저장하시겠습니까?'(P02).

      CHECK GV_ANS = GC_1.
    ELSE.
      MESSAGE S017. "변경된 내역이 없습니다.
      EXIT.
    ENDIF.
  ENDIF.

  GV_REF = GC_X.

  LOOP AT GT_ROW INTO GS_ROW.
    READ TABLE GT_LIST INDEX GS_ROW-INDEX.
    CHECK SY-SUBRC = 0.

    PERFORM SET_EINA.
    PERFORM BAPI_INFO_REC_MAINTAIN.

    MODIFY GT_LIST INDEX GS_ROW-INDEX TRANSPORTING STATUS MSG.
  ENDLOOP.

  MESSAGE S073 WITH GV_TOT GV_SUC GV_FAL.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_EINA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_EINA.

  CLEAR : GS_EINA, GS_EINAX.

  GS_EINA-INFO_REC = GT_LIST-INFNR. "정보레코드
  GS_EINA-MAT_GRP  = GT_LIST-MATKL. "자재그룹
  GS_EINA-VENDOR   = GT_LIST-LIFNR. "공급업체
  GS_EINA-VEND_MAT = GT_LIST-IDNLF. "외주공정 자재그룹

* GS_EINAX-INFO_REC = GC_X.
  GS_EINAX-MAT_GRP  = GC_X.
  GS_EINAX-VENDOR   = GC_X.
  GS_EINAX-VEND_MAT = GC_X.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form BAPI_INFO_REC_MAINTAIN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM BAPI_INFO_REC_MAINTAIN.

  CLEAR : GT_RTN[].

  CALL FUNCTION 'ME_INFORECORD_MAINTAIN'
    EXPORTING
      I_EINA  = GS_EINA
      I_EINAX = GS_EINAX
*     I_EINE  =
*     I_EINEX =
*     TESTRUN =
*     IMPORTING
*     E_EINA  =
*     E_EINE  =
    TABLES
*     TXT_LINES              =
*     COND_VALIDITY          =
*     CONDITION              =
*     COND_SCALE_VALUE       =
*     COND_SCALE_QUAN        =
      RETURN  = GT_RTN.

  READ TABLE GT_RTN WITH KEY TYPE = GC_E.

  IF SY-SUBRC <> 0.
    PERFORM BAPI_COMMIT.
    PERFORM UPDATE_CCHK.

    PERFORM SET_RST USING 'S'.
  ELSE.
    PERFORM BAPI_ROLLBACK.
    PERFORM SET_RST USING 'E'.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form BAPI_COMMIT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM BAPI_COMMIT.

  CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
    EXPORTING
      WAIT = 'X'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form BAPI_ROLLBACK
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM BAPI_ROLLBACK.

  CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form UPDATE_CCHK
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM UPDATE_CCHK.

  "라인 순번의 변동이 없다는 전제하..

  GT_CCHK-IDNLF = GT_LIST-IDNLF.

  MODIFY GT_CCHK INDEX GS_ROW-INDEX TRANSPORTING IDNLF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_RST
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&---------------------------------------------------------------------*
FORM SET_RST USING PV_CHK.

  CASE PV_CHK.
    WHEN 'S'.
      GT_LIST-STATUS = ICON_LED_GREEN.
      CLEAR : GT_LIST-MSG[].

      GV_SUC += 1.

    WHEN 'E'.
      GT_LIST-STATUS = ICON_LED_RED.

      LOOP AT GT_RTN.
        CHECK GT_RTN-TYPE = GC_E OR GT_RTN-TYPE = GC_A.

        PERFORM SET_POP_MSG USING GT_RTN-TYPE
                                  GT_RTN-CODE+0(2)
                                  GT_RTN-CODE+2(3)
                                  GT_RTN-MESSAGE_V1
                                  GT_RTN-MESSAGE_V2
                                  GT_RTN-MESSAGE_V3
                                  GT_RTN-MESSAGE_V4.
      ENDLOOP.

      GV_FAL += 1.

  ENDCASE.

  GV_TOT += 1.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_POP_MSG
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_RTN_TYPE
*&      --> GT_RTN_ID
*&      --> GT_RTN_NUMBER
*&      --> GT_RTN_MESSAGE_V1
*&      --> GT_RTN_MESSAGE_V2
*&      --> GT_RTN_MESSAGE_V3
*&      --> GT_RTN_MESSAGE_V4
*&---------------------------------------------------------------------*
FORM SET_POP_MSG USING PV_MSGTY
                       PV_MSGID
                       PV_MSGNO
                       PV_MSGV1
                       PV_MSGV2
                       PV_MSGV3
                       PV_MSGV4.

  APPEND VALUE #( MSGTY = PV_MSGTY
                  MSGID = PV_MSGID
                  MSGNO = PV_MSGNO
                  MSGV1 = PV_MSGV1
                  MSGV2 = PV_MSGV2
                  MSGV3 = PV_MSGV3
                  MSGV4 = PV_MSGV4 ) TO GT_LIST-MSG.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form COPY_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM COPY_DATA.

  "공급업체 복사 기능 추가(PSJ 25.03.21)

  PERFORM GET_SELECTED_ROWS USING GR_GRID 'S' 'X'
                                  '복사할 레코드를 선택하세요.'(M02).
  CHECK GV_ERR IS INITIAL.

  PERFORM POPUP_TO_CONFIRM USING '확인'(P01)
                                 '선택한 공급업체를 복사하시겠습니까?'(P04).
  CHECK GV_ANS = GC_1.

  READ TABLE GT_LIST INDEX GS_ROW-INDEX.
  CHECK SY-SUBRC = 0.

  SET PARAMETER ID 'ZGTMM_FLIEF' FIELD GT_LIST-LIFNR.

  IF SY-SUBRC = 0.
    MESSAGE S036. "& 성공했습니다.
    SET SCREEN 0.
  ELSE.
    MESSAGE S037 DISPLAY LIKE 'E'. "& 실패했습니다.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form HANDLE_DOUBLE_CLICK
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> E_ROW
*&      --> E_COLUMN
*&      --> ES_ROW_NO
*&      --> GV_OTEXT
*&---------------------------------------------------------------------*
FORM HANDLE_DOUBLE_CLICK USING PS_ROW  TYPE LVC_S_ROW
                               PS_COL  TYPE LVC_S_COL
                               PS_ROID TYPE LVC_S_ROID
                               PV_OTEXT.

  CLEAR : GV_CHK, GV_IDX.

  CASE PV_OTEXT.
    WHEN 'GR_GRID'.
      IF PS_COL-FIELDNAME = GC_STATUS.
        GV_CHK = GC_M.
      ENDIF.

      GV_IDX = PS_ROW-INDEX.
      PERFORM CLK_DUB_LIST.

    WHEN OTHERS.

  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CLK_DUB_LIST
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CLK_DUB_LIST.

  CHECK GV_CHK = GC_M.

  READ TABLE GT_LIST INDEX GV_IDX.
  CHECK SY-SUBRC = 0.

  PERFORM DISPLAY_MSG.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form DISPLAY_MSG
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM DISPLAY_MSG.

  DATA : LS_LOG TYPE BAL_S_LOG,
         LS_MSG TYPE BAL_S_MSG,
         LS_PRF TYPE BAL_S_PROF.


  IF GT_LIST-MSG IS INITIAL.
    EXIT.
  ENDIF.

  IF GS_HND IS NOT INITIAL.
    CALL FUNCTION 'BAL_LOG_REFRESH'
      EXPORTING
        I_LOG_HANDLE = GS_HND
      EXCEPTIONS
        OTHERS       = 1.

    CLEAR : GS_HND.
  ENDIF.

  "Create an initial log file
  CALL FUNCTION 'BAL_LOG_CREATE'
    EXPORTING
      I_S_LOG      = LS_LOG
    IMPORTING
      E_LOG_HANDLE = GS_HND
    EXCEPTIONS
      OTHERS       = 1.

  LOOP AT GT_LIST-MSG INTO LS_MSG.
    "Add message to log file
    CALL FUNCTION 'BAL_LOG_MSG_ADD'
      EXPORTING
        I_LOG_HANDLE = GS_HND
        I_S_MSG      = LS_MSG
      EXCEPTIONS
        OTHERS       = 1.
  ENDLOOP.

  "Get a prepared profile
  CALL FUNCTION 'BAL_DSP_PROFILE_POPUP_GET'
    IMPORTING
      E_S_DISPLAY_PROFILE = LS_PRF
    EXCEPTIONS
      OTHERS              = 1.

  LS_PRF-USE_GRID          = GC_X.
  LS_PRF-DISVARIANT-REPORT = SY-REPID.
  LS_PRF-DISVARIANT-HANDLE = GC_LOG.

  CALL FUNCTION 'BAL_DSP_LOG_DISPLAY'
    EXPORTING
      I_S_DISPLAY_PROFILE = LS_PRF
    EXCEPTIONS
      OTHERS              = 1.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form HANDLE_HOTSPOT_CLICK
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> E_ROW_ID
*&      --> E_COLUMN_ID
*&      --> ES_ROW_NO
*&      --> GV_OTEXT
*&---------------------------------------------------------------------*
FORM HANDLE_HOTSPOT_CLICK USING PS_ROW  TYPE LVC_S_ROW
                                PS_COL  TYPE LVC_S_COL
                                PS_ROID TYPE LVC_S_ROID
                                PV_OTEXT.

  CLEAR : GV_IDX, GV_FNM.

  CASE PV_OTEXT.
    WHEN 'GR_GRID'.
      GV_IDX = PS_ROW-INDEX.
      GV_FNM = PS_COL-FIELDNAME.

      PERFORM CLK_HOT_LIST.

    WHEN OTHERS.

  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CLK_HOT_LIST
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CLK_HOT_LIST.

  READ TABLE GT_LIST INDEX GV_IDX.
  CHECK SY-SUBRC = 0.

  CASE GV_FNM.
    WHEN 'INFNR'.
      CHECK GT_LIST-INFNR IS NOT INITIAL.

      SET PARAMETER ID 'LIF' FIELD GT_LIST-LIFNR.
      SET PARAMETER ID 'EKO' FIELD GT_LIST-EKORG.
      SET PARAMETER ID 'WRK' FIELD GT_LIST-WERKS.
      SET PARAMETER ID 'INF' FIELD GT_LIST-INFNR.
      SET PARAMETER ID 'ESO' FIELD GT_LIST-ESOKZ.

      CALL TRANSACTION 'ME13' AND SKIP FIRST SCREEN.

    WHEN OTHERS.

  ENDCASE.

ENDFORM.
