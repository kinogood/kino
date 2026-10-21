*&---------------------------------------------------------------------*
*& Include          ZGTMMR6500F01
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
  P_WERKS = GC_1306.
  P_EKGRP = GC_30D.

  CLEAR : S_BADAT[].
  S_BADAT[] = VALUE #( ( SIGN   = GC_I
                         OPTION = GC_EQ
                         LOW    = SY-DATLO ) ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form MODIFY_SCREEN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM MODIFY_SCREEN.

  SET CURSOR FIELD GV_FNM.

  LOOP AT SCREEN.
    IF P_CREA = GC_X.
      IF SCREEN-GROUP1 = GC_DIS.
        SCREEN-ACTIVE = GC_0.
        MODIFY SCREEN.
      ENDIF.

      IF SCREEN-NAME = GC_P_EKGRP.
        SCREEN-INPUT = GC_0.
        MODIFY SCREEN.
      ENDIF.
    ELSE.
      IF SCREEN-NAME = GC_S_BADAT-LOW.
        SCREEN-REQUIRED = GC_2.
        MODIFY SCREEN.
      ENDIF.
    ENDIF.
  ENDLOOP.

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

  CLEAR : GV_ERR, GV_FNM.

  CHECK P_DISP = GC_X.

  IF S_BADAT[] IS INITIAL.
    GV_FNM = GC_S_BADAT-LOW.

    MESSAGE S278(00) WITH '요청일'(F22) DISPLAY LIKE 'E'.
    GV_ERR = GC_X. EXIT.
  ENDIF.

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

  CHECK P_WERKS IS NOT INITIAL.

  AUTHORITY-CHECK OBJECT 'ZPP_WERKS'
               ID 'WERKS' FIELD P_WERKS.

  CHECK SY-SUBRC <> 0.

  SET CURSOR FIELD 'P_WERKS'.
  MESSAGE E106 WITH P_WERKS. "플랜트 [&] 작업권한을 확인하세요.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form F4_S_FLIEF
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&---------------------------------------------------------------------*
FORM F4_S_FLIEF USING PV_FIELD.

  GR_MATNR[] = S_MATNR[].

  PERFORM SET_F4_FLIEF USING PV_FIELD.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_F4_FLIEF
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PV_FIELD
*&---------------------------------------------------------------------*
FORM SET_F4_FLIEF USING PV_FIELD.

  SELECT DISTINCT E~LIFNR, L~NAME1
    FROM EORD AS E LEFT JOIN LFA1 AS L
      ON E~LIFNR = L~LIFNR
*    AND L~LOEVM = @SPACE
     AND L~SPRAS = @SY-LANGU
    INTO TABLE @DATA(LT_LIFNR)
   WHERE E~MATNR IN @GR_MATNR
     AND E~WERKS  = @P_WERKS
     AND E~NOTKZ  = @SPACE      "추가(PSJ 25.04.17)
     AND E~VDATU <= @SY-DATLO   "추가(PSJ 25.05.07)
     AND E~BDATU >= @SY-DATLO   "추가(PSJ 25.05.07)
     AND L~LOEVM  = @SPACE.     "변경(PSJ 25.05.07)

  SORT LT_LIFNR BY LIFNR.

  PERFORM F4IF_TABLE TABLES LT_LIFNR
                      USING 'LIFNR'
                            PV_FIELD.

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
  CHECK GV_ERR IS INITIAL.

  CASE 'X'.
    WHEN P_DISP.
      PERFORM GET_DISP_DATA.

    WHEN P_CREA.
      PERFORM GET_CREA_DATA.

  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_DISP_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_DISP_DATA.

  SELECT M~*,
         @ICON_LED_GREEN AS STATUS,
         L~NAME1,
         T~MAKTX,
         P~EBELN,
         P~EBELP
    FROM ZGTMMT6500 AS M LEFT JOIN LFA1 AS L
      ON M~FLIEF = L~LIFNR
     AND L~LOEVM = @SPACE
     AND L~SPRAS = @SY-LANGU
    LEFT JOIN MAKT AS T
      ON M~MATNR = T~MATNR
     AND T~SPRAS = @SY-LANGU
    LEFT JOIN EKPO AS P      "추가(PSJ 25.04.17)
      ON M~BANFN = P~BANFN
     AND M~BNFPO = P~BNFPO
     AND P~LOEKZ <> @GC_L
    INTO CORRESPONDING FIELDS OF TABLE @GT_LIST
   WHERE M~EKORG  = @P_EKORG
     AND M~WERKS  = @P_WERKS
     AND M~EKGRP  = @P_EKGRP
     AND M~BANFN IN @S_BANFN
     AND M~AFNAM IN @S_AFNAM
     AND M~MATNR IN @S_MATNR
     AND M~LFDAT IN @S_LFDAT
     AND M~FLIEF IN @S_FLIEF
     AND M~BADAT IN @S_BADAT.

  IF GT_LIST[] IS INITIAL.
    MESSAGE S002 DISPLAY LIKE 'E'. "조회된 값이 없습니다.
    EXIT.
  ENDIF.

  SORT GT_LIST BY BADAT LFDAT MATNR BANFN.

  GV_CNT = LINES( GT_LIST ).
  MESSAGE S003 WITH GV_CNT. "& 건의 데이터가 조회되었습니다.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_CREA_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_CREA_DATA.

  "라인 한 건 추가('라인추가' 기능 동일)
  PERFORM INSR_DATA.

  GV_CNT = LINES( GT_LIST ).

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

  GT_LIST-STATUS = ICON_LED_YELLOW.
  GT_LIST-EKORG  = P_EKORG.
  GT_LIST-WERKS  = P_WERKS.
  GT_LIST-EKGRP  = P_EKGRP.
  PERFORM GET_UNAME USING SY-UNAME
                 CHANGING GT_LIST-AFNAM.
  GT_LIST-LFDAT = SY-DATLO + 5.
  GT_LIST-BADAT = SY-DATLO.

  PERFORM SET_STYLE USING 'E' 'AFNAM' GT_LIST-STYLE.
  PERFORM SET_STYLE USING 'E' 'MATNR' GT_LIST-STYLE.
  PERFORM SET_STYLE USING 'E' 'LENTH' GT_LIST-STYLE.
  PERFORM SET_STYLE USING 'E' 'NUMBR' GT_LIST-STYLE.
  PERFORM SET_STYLE USING 'E' 'LFDAT' GT_LIST-STYLE.
  PERFORM SET_STYLE USING 'E' 'ETCTX' GT_LIST-STYLE. "추가(PSJ 25.04.30)
  PERFORM SET_STYLE USING 'E' 'FLIEF' GT_LIST-STYLE.

  PERFORM SET_COLOR USING 'STATUS' '4' '1' '0' GT_LIST-COLOR.
  PERFORM SET_COLOR USING 'BANFN'  '4' '1' '0' GT_LIST-COLOR.
  PERFORM SET_COLOR USING 'BNFPO'  '4' '1' '0' GT_LIST-COLOR.
  PERFORM SET_COLOR USING 'EKORG'  '4' '1' '0' GT_LIST-COLOR.
  PERFORM SET_COLOR USING 'WERKS'  '4' '1' '0' GT_LIST-COLOR.
  PERFORM SET_COLOR USING 'EKGRP'  '4' '1' '0' GT_LIST-COLOR.

  APPEND GT_LIST.

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
*& Form GET_UNAME
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      <-- GT_LIST_AFNAM
*&---------------------------------------------------------------------*
FORM GET_UNAME USING PV_USERID
            CHANGING PV_UNAME.

  CLEAR : PV_UNAME.
  CHECK PV_USERID IS NOT INITIAL.

  SELECT SINGLE NAME
    FROM ZGTMM_CV_GETUSERNAME
    INTO @PV_UNAME
   WHERE USERID = @PV_USERID.

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

  CLEAR : GT_EXCD[], GV_TITLE.

  CASE 'X'.
    WHEN P_DISP.
      GV_TITLE  = TEXT-R01. "조회
      GT_EXCD[] = VALUE #( ( GC_SAVE ) ).

    WHEN P_CREA.
      GV_TITLE  = TEXT-R02. "생성
      GT_EXCD[] = VALUE #( ( GC_REFR ) ).

  ENDCASE.

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
*& Form SET_F4
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_F4.

  CLEAR : GT_F4.

  CASE SY-DYNNR.
    WHEN '0100'.
      APPEND VALUE #( FIELDNAME = GC_FLIEF
                      REGISTER  = GC_X ) TO GT_F4.
      APPEND VALUE #( FIELDNAME = GC_MATNR  "추가(PSJ 25.03.12)
                      REGISTER  = GC_X ) TO GT_F4.

  ENDCASE.

  CALL METHOD GR_GRID->REGISTER_F4_FOR_FIELDS
    EXPORTING
      IT_F4 = GT_F4.

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

  DATA(LV_NDOT) = COND #( WHEN P_DISP = GC_X THEN GC_X
                          WHEN P_CREA = GC_X THEN ' ' ).

  DATA(LV_NCOT) = COND #( WHEN P_DISP = GC_X THEN ' '
                          WHEN P_CREA = GC_X THEN GC_X ).

* DATA(LV_EDIT) = COND #( WHEN P_DISP = GC_X THEN ' '
*                         WHEN P_CREA = GC_X THEN GC_X ).

  CASE GS_FCAT-FIELDNAME.
    WHEN 'STATUS'.
      PERFORM SET_FTXT USING 'Status'(F01).
      GS_FCAT-JUST   = GC_C.
      GS_FCAT-KEY    = GC_X.
      GS_FCAT-NO_OUT = LV_NDOT.
    WHEN 'BANFN'.
      PERFORM SET_FTXT USING '구매요청 번호'(F02).
      GS_FCAT-KEY     = GC_X.
      GS_FCAT-HOTSPOT = GC_X.
    WHEN 'BNFPO'.
      PERFORM SET_FTXT USING '품목'(F03).
      GS_FCAT-KEY = GC_X.
    WHEN 'EKORG'.
      PERFORM SET_FTXT USING '구매조직'(F04).
      GS_FCAT-KEY = GC_X.
    WHEN 'WERKS'.
      PERFORM SET_FTXT USING '플랜트'(F05).
      GS_FCAT-KEY = GC_X.
    WHEN 'EKGRP'.
      PERFORM SET_FTXT USING '구매그룹'(F06).
      GS_FCAT-KEY = GC_X.
    WHEN 'AFNAM'.
      PERFORM SET_FTXT USING '요청자이름'(F07).
*     GS_FCAT-EDIT = LV_EDIT.
    WHEN 'MATNR'.
      PERFORM SET_FTXT USING '자재 코드(BusBar)'(F08).
      GS_FCAT-CHECKTABLE = GC_EM. "'!'
      GS_FCAT-F4AVAILABL = GC_X.
*     GS_FCAT-EDIT = LV_EDIT.
    WHEN 'LENTH'.
      PERFORM SET_FTXT USING '길이(MM)'(F09).
*     GS_FCAT-EDIT = LV_EDIT.
    WHEN 'NUMBR'.
      PERFORM SET_FTXT USING '개수(EA)'(F10).
*     GS_FCAT-EDIT = LV_EDIT.
    WHEN 'LFDAT'.
      PERFORM SET_FTXT USING '납품일'(F11).
*     GS_FCAT-EDIT = LV_EDIT.
    WHEN 'ETCTX'. "추가(PSJ 25.04.30)
      PERFORM SET_FTXT USING ' 비   고 '(F32).
    WHEN 'FLIEF'.
      PERFORM SET_FTXT USING '고정 공급업체'(F12).
      GS_FCAT-CHECKTABLE = GC_EM. "'!'
      GS_FCAT-F4AVAILABL = GC_X.
      GS_FCAT-EMPHASIZE  = GC_C300.
*     GS_FCAT-EDIT = LV_EDIT.
    WHEN 'NAME1'.
      PERFORM SET_FTXT USING '고정 공급업체명'(F13).
      GS_FCAT-EMPHASIZE  = GC_C300.
    WHEN 'MAKTX'.
      PERFORM SET_FTXT USING '자재 내역'(F14).
    WHEN 'BAMNG'.
      PERFORM SET_FTXT USING 'PR 수량'(F15).
      GS_FCAT-EMPHASIZE  = GC_C500.
    WHEN 'BAMEI'.
      PERFORM SET_FTXT USING 'PR 단위'(F16).
      GS_FCAT-EMPHASIZE  = GC_C500.
    WHEN 'EBELN'. "추가(PSJ 25.04.17)
      PERFORM SET_FTXT USING '구매오더 번호'(F31).
      GS_FCAT-HOTSPOT    = GC_X.
      GS_FCAT-EMPHASIZE  = GC_C112.
      GS_FCAT-NO_OUT     = LV_NCOT.
    WHEN 'EBELP'. "추가(PSJ 25.04.17)
      PERFORM SET_FTXT USING '품목'(F03).
      GS_FCAT-EMPHASIZE  = GC_C112.
      GS_FCAT-NO_OUT     = LV_NCOT.
    WHEN 'UMREN'.
      PERFORM SET_FTXT USING '대체수량'(F17).
    WHEN 'MEINH'.
      PERFORM SET_FTXT USING '대체단위'(F18).
    WHEN 'UMREZ'.
      PERFORM SET_FTXT USING '기본수량'(F19).
    WHEN 'MEINS'.
      PERFORM SET_FTXT USING '기본단위'(F20).
    WHEN 'LGORT'.
      PERFORM SET_FTXT USING '저장위치'(F21).
    WHEN 'BADAT'.
      PERFORM SET_FTXT USING '요청일'(F22).
    WHEN 'ERNAM'.
      PERFORM SET_FTXT USING '생성자'(F23).
    WHEN 'ERDAT_LOCAL'.
      PERFORM SET_FTXT USING '생성일'(F24).
    WHEN 'ERTIM_LOCAL'.
      PERFORM SET_FTXT USING '생성시간'(F25).
    WHEN 'EM_RECV'.
      PERFORM SET_FTXT USING '수신자 E-Mail'(F26).
    WHEN 'EM_UNAME'.
      PERFORM SET_FTXT USING '메일 전송자'(F27).
    WHEN 'EM_DATLO'.
      PERFORM SET_FTXT USING '메일 전송일'(F28).
    WHEN 'EM_TIMLO'.
      PERFORM SET_FTXT USING '메일 전송시간'(F29).
    WHEN 'GUIDC'.
      PERFORM SET_FTXT USING 'GUID'(F30).
      GS_FCAT-NO_OUT = GC_X.

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
  SET HANDLER GR_EVENTS->HANDLE_ONF4                  FOR GR_GRID.
  SET HANDLER GR_EVENTS->HANDLE_DOUBLE_CLICK          FOR GR_GRID.
  SET HANDLER GR_EVENTS->HANDLE_HOTSPOT_CLICK         FOR GR_GRID.

  CHECK P_CREA = GC_X.

  CALL METHOD GR_GRID->SET_READY_FOR_INPUT
    EXPORTING
      I_READY_FOR_INPUT = 1.

  CALL METHOD GR_GRID->REGISTER_EDIT_EVENT
    EXPORTING
      I_EVENT_ID = CL_GUI_ALV_GRID=>MC_EVT_ENTER.

  CALL METHOD GR_GRID->REGISTER_EDIT_EVENT
    EXPORTING
      I_EVENT_ID = CL_GUI_ALV_GRID=>MC_EVT_MODIFIED.

  GR_GRID->ACTIVATE_DISPLAY_PROTOCOL( SPACE ).

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
*& Form CHECK_EXIT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&---------------------------------------------------------------------*
FORM CHECK_EXIT USING PV_MODE.

  PERFORM FREE_OBJ.

  CASE PV_MODE.
    WHEN 'C'.
      LEAVE PROGRAM.
    WHEN 'N'.
      SET SCREEN 0.
  ENDCASE.

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
*& Form PRCS_REFR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PRCS_REFR.

  PERFORM GET_DATA.
  GV_REF = GC_X.

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


  CHECK P_CREA = GC_X.

  CASE PV_OTEXT.
    WHEN 'GR_GRID'.
      _SET_TBAR 3 '    ' '              ' '    '.
      _SET_TBAR 0 'INSR' ICON_INSERT_ROW  '라인추가'(B01).
      _SET_TBAR 0 'DELE' ICON_DELETE_ROW  '라인삭제'(B02).

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
    WHEN 'INSR'.
      PERFORM INSR_DATA.

    WHEN 'DELE'.
      PERFORM DELE_DATA.

  ENDCASE.

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
                                  '삭제할 레코드를 선택하세요.'(M01).
  CHECK GV_ERR IS INITIAL.

  DELETE GT_ROW WHERE INDEX IS INITIAL.
  SORT GT_ROW BY INDEX DESCENDING.

  PERFORM CHK_DEL_LIST.
  CHECK GV_ERR IS INITIAL.

  GT_LIST[] = GT_TMP[].

  GV_REF = GC_X.

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

  CLEAR : GV_ERR.

  GT_TMP[] = GT_LIST[].

  LOOP AT GT_ROW INTO GS_ROW.
    READ TABLE GT_TMP INDEX GS_ROW-INDEX.
    CHECK SY-SUBRC = 0.

    IF GT_TMP-BANFN IS NOT INITIAL.
      MESSAGE S110 DISPLAY LIKE 'E'. "삭제할 수 없는 데이터가 포함되어 있습니다.
      GV_ERR = GC_X.
    ENDIF.

    DELETE GT_TMP INDEX GS_ROW-INDEX.
  ENDLOOP.

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

* LOOP AT PR_CHNG->MT_GOOD_CELLS INTO GS_MODI.
*   CASE GS_MODI-FIELDNAME.
*     WHEN 'ZMTGRP' OR 'LIFNR' OR 'LVORM'.
*       PERFORM MODIFY_CELL USING PR_CHNG 'STATUS' ICON_CHANGE.
*
*      WHEN OTHERS.
*
*   ENDCASE.
*
*   GV_REF = GC_X.
* ENDLOOP.

  CHECK GR_DROW[] IS NOT INITIAL. "ALV List 반영!
  PERFORM REFRESH_GRID.

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

  IF GR_DROW[] IS NOT INITIAL.
    DELETE PT_MODI WHERE ROW_ID IN GR_DROW.
  ENDIF.

  LOOP AT PT_MODI INTO GS_MODI.
    READ TABLE GT_LIST INDEX GS_MODI-ROW_ID.
    CHECK SY-SUBRC = 0.

    AT NEW ROW_ID.
      PERFORM ASSIGN_GFS USING GT_LIST.

      "구매요청 실패 후 데이터 변경이 있을때.. BAPI 메세지는 Clear
      IF <GFS_STS> = ICON_LED_RED.
        CLEAR : <GFS_MSG>.
      ENDIF.
    ENDAT.

    GV_FNM = GS_MODI-FIELDNAME.

    CASE GS_MODI-FIELDNAME.
      WHEN 'AFNAM'.
        PERFORM CHANGE_AFNAM.
      WHEN 'MATNR'.
        PERFORM CHANGE_MATNR.
      WHEN 'LENTH'.
        PERFORM CHANGE_LENTH.
      WHEN 'NUMBR'.
        PERFORM CHANGE_NUMBR.
      WHEN 'LFDAT'.
        PERFORM CHANGE_LFDAT.
      WHEN 'FLIEF'.
        PERFORM CHANGE_FLIEF.
    ENDCASE.

    AT END OF ROW_ID.
      PERFORM RESET_STATUS.
      PERFORM SET_LIST_CUR USING GS_MODI-ROW_ID
                                 GV_FNM.
    ENDAT.

    MODIFY GT_LIST INDEX GS_MODI-ROW_ID.
    GV_REF = GC_X.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_MAND
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_LIST_AFNAM
*&      --> P_
*&      --> P_
*&---------------------------------------------------------------------*
FORM CHECK_MAND USING PV_VAL
                      PV_FNM
                      PV_TXT.

  PERFORM DEL_POP_MSG USING 'ZGTMM01' '008' PV_TXT '' '' ''.

  IF PV_VAL IS INITIAL.
    "필수 값이 누락되었습니다. &
    PERFORM SET_POP_MSG USING 'E' 'ZGTMM01' '008' PV_TXT '' '' ''.
    PERFORM SET_ERR_COL USING PV_FNM.
  ELSE.
*   PERFORM DEL_POP_MSG USING 'ZGTMM01' '008' PV_TXT '' '' ''.
    PERFORM DEL_ERR_COL USING PV_FNM.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_POP_MSG
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> P_
*&      --> P_
*&      --> PV_TXT
*&      --> P_
*&      --> P_
*&      --> P_
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
                  MSGV4 = PV_MSGV4 ) TO <GFS_MSG>.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_ERR_COL
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PV_FNM
*&---------------------------------------------------------------------*
FORM SET_ERR_COL USING P_FNM.

  APPEND VALUE #( FNAME     = P_FNM
                  COLOR-COL = GC_6
                  COLOR-INT = GC_0
                  COLOR-INV = GC_0 ) TO <GFS_COL>.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form DEL_POP_MSG
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> P_
*&      --> P_TXT
*&      --> P_
*&      --> P_
*&      --> P_
*&---------------------------------------------------------------------*
FORM DEL_POP_MSG USING PV_MSGID
                       PV_MSGNO
                       PV_MSGV1
                       PV_MSGV2
                       PV_MSGV3
                       PV_MSGV4.

  CHECK  <GFS_MSG> IS NOT INITIAL.

  DELETE <GFS_MSG> WHERE MSGID = PV_MSGID
                     AND MSGNO = PV_MSGNO
                     AND MSGV1 = PV_MSGV1
                     AND MSGV2 = PV_MSGV2
                     AND MSGV3 = PV_MSGV3
                     AND MSGV4 = PV_MSGV4.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form DEL_ERR_COL
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_FNM
*&---------------------------------------------------------------------*
FORM DEL_ERR_COL USING P_FNM.

  CHECK  <GFS_COL> IS NOT INITIAL.

  DELETE <GFS_COL> WHERE FNAME = P_FNM.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form ASSIGN_GFS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_LIST
*&---------------------------------------------------------------------*
FORM ASSIGN_GFS USING PS_LIST.

  ASSIGN COMPONENT 'STATUS' OF STRUCTURE PS_LIST TO <GFS_STS>.
  ASSIGN COMPONENT 'MSG'    OF STRUCTURE PS_LIST TO <GFS_MSG>.
  ASSIGN COMPONENT 'COLOR'  OF STRUCTURE PS_LIST TO <GFS_COL>.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHANGE_AFNAM
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CHANGE_AFNAM.

  PERFORM CHECK_MAND USING GT_LIST-AFNAM 'AFNAM' '요청자'(F07).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHANGE_MATNR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CHANGE_MATNR.

  PERFORM CHECK_MAND USING GT_LIST-MATNR 'MATNR' '자재'(F08).

  PERFORM CHECK_MATN USING GT_LIST-MATNR 'MATNR'
                  CHANGING GT_LIST-MAKTX
                           GT_LIST-BAMEI
                           GT_LIST-UMREN
                           GT_LIST-MEINH
                           GT_LIST-UMREZ
                           GT_LIST-MEINS
                           GT_LIST-LGORT.

  PERFORM CAL_BAMNG USING GT_LIST-LENTH
                          GT_LIST-NUMBR
                          GT_LIST-UMREZ
                          GT_LIST-UMREN
                 CHANGING GT_LIST-BAMNG.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_MATN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_LIST_MATNR
*&      --> P_
*&      <-- GT_LIST_MAKTX
*&      <-- GT_LIST_BAMEI
*&      <-- GT_LIST_UMREN
*&      <-- GT_LIST_MEINH
*&      <-- GT_LIST_UMREZ
*&      <-- GT_LIST_MEINS
*&      <-- GT_LIST_LGORT
*&---------------------------------------------------------------------*
FORM CHECK_MATN USING PV_MATNR
                      PV_FNM
             CHANGING PV_MAKTX
                      PV_BAMEI
                      PV_UMREN
                      PV_MEINH
                      PV_UMREZ
                      PV_MEINS
                      PV_LGORT.

  CLEAR : GV_ERR.

  CHECK PV_MATNR IS NOT INITIAL.

  PERFORM CHECK_MARA USING PV_MATNR
                  CHANGING PV_BAMEI
                           PV_MEINS.

  PERFORM CHECK_MARM USING PV_MATNR
                  CHANGING PV_UMREN
                           PV_MEINH
                           PV_UMREZ.

  PERFORM SET_MAKTX USING PV_MATNR
                 CHANGING PV_MAKTX.

  PERFORM SET_LGORT USING PV_MATNR
                 CHANGING PV_LGORT.

  IF GV_ERR IS NOT INITIAL.
    PERFORM SET_ERR_COL USING PV_FNM.
  ELSE.
    PERFORM DEL_ERR_COL USING PV_FNM.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_MARA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PV_MATNR
*&      <-- PV_BAMEI
*&      <-- PV_MEINS
*&---------------------------------------------------------------------*
FORM CHECK_MARA USING PV_MATNR
             CHANGING PV_BAMEI
                      PV_MEINS.

  DATA : LV_MTART LIKE MARA-MTART.


  CLEAR : PV_BAMEI, PV_MEINS.
  CHECK PV_MATNR IS NOT INITIAL.

  PERFORM DEL_POP_MSG USING 'ZGTMM01' '081' '자재'(F08) '' '' ''.
  PERFORM DEL_POP_MSG USING 'ZGTMM01' '111' '' '' '' ''.

  SELECT SINGLE MTART
                MEINS
                MEINS
    FROM MARA
    INTO (LV_MTART, PV_BAMEI, PV_MEINS)
   WHERE MATNR = PV_MATNR
     AND LVORM = SPACE.

  IF SY-SUBRC <> 0.
    "존재하지 않는 &입니다.
    PERFORM SET_POP_MSG USING 'E' 'ZGTMM01' '081' '자재'(F08) '' '' ''.
    GV_ERR = GC_X.
  ELSE.
*   PERFORM DEL_POP_MSG USING 'ZGTMM01' '081' '자재'(F08) '' '' ''.
  ENDIF.

  IF LV_MTART <> GC_ROH1.
    "자재유형이 원재료(ROH1)가 아닙니다.
    PERFORM SET_POP_MSG USING 'E' 'ZGTMM01' '111' '' '' '' ''.
    GV_ERR = GC_X.
  ELSE.
*   PERFORM DEL_POP_MSG USING 'ZGTMM01' '111' '' '' '' ''.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_MARM
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PV_MATNR
*&      <-- PV_UMREN
*&      <-- PV_MEINH
*&      <-- PV_UMREZ
*&---------------------------------------------------------------------*
FORM CHECK_MARM USING PV_MATNR
             CHANGING PV_UMREN
                      PV_MEINH
                      PV_UMREZ.

  CLEAR : PV_UMREN, PV_MEINH, PV_UMREZ.
  CHECK PV_MATNR IS NOT INITIAL.

  PERFORM DEL_POP_MSG USING 'ZGTMM01' '112' '' '' '' ''.

  SELECT SINGLE UMREN
                MEINH
                UMREZ
    FROM MARM
    INTO (PV_UMREN, PV_MEINH, PV_UMREZ)
   WHERE MATNR = PV_MATNR
     AND MEINH = GC_M. "기준 변경(PSJ 25.04.03) MM->M

  "입력한 자재코드의 대체단위(MARM-MEINH)가 'M'이 아니면 에러
  IF SY-SUBRC <> 0.
    "자재마스터의 대체 단위(M)를 유지보수 하세요.
    PERFORM SET_POP_MSG USING 'E' 'ZGTMM01' '112' '' '' '' ''.
    GV_ERR = GC_X.
  ELSE.
*   PERFORM DEL_POP_MSG USING 'ZGTMM01' '112' '' '' '' ''.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_MAKTX
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PV_MATNR
*&      <-- PV_MAKTX
*&---------------------------------------------------------------------*
FORM SET_MAKTX USING PV_MATNR
            CHANGING PV_MAKTX.

  CLEAR : PV_MAKTX.
  CHECK PV_MATNR IS NOT INITIAL.

  SELECT SINGLE MAKTX
    FROM MAKT INTO PV_MAKTX
   WHERE MATNR = PV_MATNR
     AND SPRAS = SY-LANGU.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_LGORT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PV_MATNR
*&      <-- PV_LGORT
*&---------------------------------------------------------------------*
FORM SET_LGORT USING PV_MATNR
            CHANGING PV_LGORT.

  CLEAR : PV_LGORT.
  CHECK PV_MATNR IS NOT INITIAL.

  SELECT SINGLE LGFSB
    FROM MARC INTO PV_LGORT
   WHERE MATNR = PV_MATNR
     AND WERKS = P_WERKS
     AND LVORM = SPACE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_RANGE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_LIST_LENTH
*&      --> P_
*&      --> P_
*&---------------------------------------------------------------------*
FORM CHECK_RANGE USING PV_VAL
                       PV_FNM
                       PV_MAX.

  "입력 범위 제한(PSJ 25.04.17)
  " 길이: 0~4000, 개수: 0~999

  CLEAR : GV_ERR.

  DATA(LV_TXT) = '0~' && PV_MAX.

  PERFORM DEL_POP_MSG USING 'ZGTMM01' '099' LV_TXT '' '' ''.

  IF PV_VAL BETWEEN '0' AND PV_MAX.
    PERFORM DEL_ERR_COL USING PV_FNM.
  ELSE.
    "입력 가능 범위는 & 입니다.
    PERFORM SET_POP_MSG USING 'E' 'ZGTMM01' '099' LV_TXT '' '' ''.
    PERFORM SET_ERR_COL USING PV_FNM.

    GV_ERR = GC_X.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CAL_BAMNG
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_LIST_LENTH
*&      --> GT_LIST_NUMBR
*&      --> GT_LIST_UMREZ
*&      --> GT_LIST_UMREN
*&      <-- GT_LIST_BAMNG
*&---------------------------------------------------------------------*
FORM CAL_BAMNG USING PV_LENTH
                     PV_NUMBR
                     PV_UMREZ
                     PV_UMREN
            CHANGING PV_BAMNG.

  "PR 수량 자동 계산 = 길이 * 개수 * 기본수량(분자) / 대체수량(분모)

  CLEAR : PV_BAMNG.
  CHECK PV_UMREN IS NOT INITIAL.

  CHECK PV_LENTH IS NOT INITIAL
    AND PV_NUMBR IS NOT INITIAL
    AND PV_UMREZ IS NOT INITIAL.

  PV_BAMNG = ( PV_LENTH * PV_NUMBR * PV_UMREZ ) / PV_UMREN.
  PV_BAMNG = PV_BAMNG / 1000. "기준 변경(PSJ 25.04.03)

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHANGE_LENTH
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CHANGE_LENTH.

  PERFORM CHECK_MAND USING GT_LIST-LENTH 'LENTH' '길이(MM)'(F09).

  PERFORM CHECK_RANGE USING GT_LIST-LENTH 'LENTH' '4000'.
  CHECK GV_ERR IS INITIAL.

  PERFORM CAL_BAMNG USING GT_LIST-LENTH
                          GT_LIST-NUMBR
                          GT_LIST-UMREZ
                          GT_LIST-UMREN
                 CHANGING GT_LIST-BAMNG.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHANGE_NUMBR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CHANGE_NUMBR.

  PERFORM CHECK_MAND USING GT_LIST-NUMBR 'NUMBR' '개수(EA)'(F10).

  PERFORM CHECK_RANGE USING GT_LIST-NUMBR 'NUMBR' '999'.
  CHECK GV_ERR IS INITIAL.

  PERFORM CAL_BAMNG USING GT_LIST-LENTH
                          GT_LIST-NUMBR
                          GT_LIST-UMREZ
                          GT_LIST-UMREN
                 CHANGING GT_LIST-BAMNG.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHANGE_LFDAT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CHANGE_LFDAT.

  PERFORM CHECK_MAND USING GT_LIST-LFDAT 'LFDAT' '납품일'(F11).

  PERFORM CHECK_LFDAT USING GT_LIST-LFDAT 'LFDAT'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_LFDAT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_LIST_LFDAT
*&      --> P_
*&---------------------------------------------------------------------*
FORM CHECK_LFDAT USING PV_LFDAT
                       PV_FNM.

  CHECK PV_LFDAT IS NOT INITIAL.

  PERFORM DEL_POP_MSG USING 'ZGTMM01' '113' '' '' '' ''.

  IF PV_LFDAT < SY-DATLO.
    "납품일은 과거일자를 입력할 수 없습니다.
    PERFORM SET_POP_MSG USING 'E' 'ZGTMM01' '113' '' '' '' ''.
    PERFORM SET_ERR_COL USING PV_FNM.
  ELSE.
*   PERFORM DEL_POP_MSG USING 'ZGTMM01' '113' '' '' '' ''.
    PERFORM DEL_ERR_COL USING PV_FNM.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHANGE_FLIEF
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CHANGE_FLIEF.

  PERFORM CHECK_MAND USING GT_LIST-FLIEF 'FLIEF' '고정 공급업체'(F12).

  PERFORM CHECK_FLIEF USING GT_LIST-MATNR
                            GT_LIST-FLIEF 'FLIEF'
                   CHANGING GT_LIST-NAME1.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_FLIEF
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_LIST_MATNR
*&      --> GT_LIST_FLIEF
*&      --> P_
*&      <-- GT_LIST_NAME1
*&---------------------------------------------------------------------*
FORM CHECK_FLIEF USING PV_MATNR
                       PV_FLIEF
                       PV_FNM
              CHANGING PV_NAME1.

  CLEAR : PV_NAME1.
  CHECK PV_FLIEF IS NOT INITIAL.

  PERFORM DEL_POP_MSG USING 'ZGTMM01' '093' '' '' '' ''.

  IF PV_MATNR IS NOT INITIAL.
    SELECT SINGLE LIFNR
      FROM EORD INTO @DATA(LV_LIFNR)
     WHERE MATNR  = @PV_MATNR
       AND WERKS  = @P_WERKS
*      AND VDATU <= @PV_LFDAT
*      AND BDATU >= @PV_LFDAT
       AND LIFNR  = @PV_FLIEF.
  ELSE.
    SELECT SINGLE LIFNR
      FROM LFA1 INTO LV_LIFNR
     WHERE LIFNR = PV_FLIEF
       AND LOEVM = SPACE.
  ENDIF.

  IF SY-SUBRC <> 0.
    "유효하지 않은 공급업체입니다.
    PERFORM SET_POP_MSG USING 'E' 'ZGTMM01' '093' '' '' '' ''.
    PERFORM SET_ERR_COL USING PV_FNM.
  ELSE.
*   PERFORM DEL_POP_MSG USING 'ZGTMM01' '093' '' '' '' ''.
    PERFORM DEL_ERR_COL USING PV_FNM.

    PERFORM GET_LFA1 USING PV_FLIEF
                  CHANGING PV_NAME1.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_LFA1
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PV_FLIEF
*&      <-- PV_NAME1
*&---------------------------------------------------------------------*
FORM GET_LFA1 USING PV_LIFNR
           CHANGING PV_NAME1.

  CLEAR : PV_NAME1.
  CHECK PV_LIFNR IS NOT INITIAL.

  SELECT SINGLE NAME1
    FROM LFA1 INTO PV_NAME1
   WHERE LIFNR = PV_LIFNR
     AND LOEVM = SPACE
     AND SPRAS = SY-LANGU.

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

  IF <GFS_MSG> IS NOT INITIAL.
    <GFS_STS> = ICON_DEFECT.
  ELSE.
    <GFS_STS> = ICON_LED_YELLOW.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_LIST_CUR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GS_MODI_ROW_ID
*&      --> GV_FNM
*&---------------------------------------------------------------------*
FORM SET_LIST_CUR USING PV_ROW
                        PV_FNM.

  CLEAR : GS_ROW, GS_COL.
  GS_ROW-INDEX     = PV_ROW.
  GS_COL-FIELDNAME = PV_FNM.

  CALL METHOD GR_GRID->SET_CURRENT_CELL_VIA_ID
    EXPORTING
      IS_ROW_ID    = GS_ROW
      IS_COLUMN_ID = GS_COL.
*     IS_ROW_NO    =

ENDFORM.
*&---------------------------------------------------------------------*
*& Form HANDLE_ONF4
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> E_FIELDNAME
*&      --> E_FIELDVALUE
*&      --> ES_ROW_NO
*&      --> ER_EVENT_DATA
*&      --> ET_BAD_CELLS
*&      --> E_DISPLAY
*&      --> GV_OTEXT
*&---------------------------------------------------------------------*
FORM HANDLE_ONF4 USING PV_FNAME
                       PV_FVAL
                       PS_ROID  TYPE LVC_S_ROID
                       PR_EVENT TYPE REF TO CL_ALV_EVENT_DATA
                       PT_BCELL TYPE LVC_T_MODI
                       PV_DISPLAY
                       PV_OTEXT.

  FIELD-SYMBOLS : <LT_MODI> TYPE LVC_T_MODI.

  DATA : LS_MODI TYPE LVC_S_MODI.


  PR_EVENT->M_EVENT_HANDLED = GC_X.

  READ TABLE GT_LIST INDEX PS_ROID-ROW_ID.

  CHECK SY-SUBRC = 0.

  CASE PV_FNAME.
    WHEN 'MATNR'.
      PERFORM F4_MATNR.

    WHEN 'FLIEF'.
      PERFORM F4_A_FLIEF USING GT_LIST-MATNR.

  ENDCASE.

  CHECK PV_DISPLAY IS INITIAL.
  CHECK GT_RTAB[]  IS NOT INITIAL.

  ASSIGN PR_EVENT->M_DATA->* TO <LT_MODI>.

  CLEAR : LS_MODI.
  LS_MODI-ROW_ID    = PS_ROID-ROW_ID.
  LS_MODI-FIELDNAME = PV_FNAME.
  LS_MODI-VALUE     = VALUE #( GT_RTAB[ 1 ]-FIELDVAL OPTIONAL ).
  APPEND LS_MODI TO <LT_MODI>.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form F4_MATNR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F4_MATNR.

  "Search Help 추가(PSJ 25.03.12)

  PERFORM F4IF_FIELD USING 'ZGTMMT6500'
                           'MATNR'
                           'ZGTMMH_BUSBAR'
                           ' '.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form F4IF_FIELD
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> P_
*&      --> P_
*&      --> P_
*&---------------------------------------------------------------------*
FORM F4IF_FIELD USING PV_TNAME
                      PV_FNAME
                      PV_SHELP
                      PV_FIELD.

  CLEAR : GT_RTAB[].

  CALL FUNCTION 'F4IF_FIELD_VALUE_REQUEST'
    EXPORTING
      TABNAME           = CONV TABNAME( PV_TNAME )
      FIELDNAME         = CONV FIELDNAME( PV_FNAME )
      SEARCHHELP        = CONV SHLPNAME( PV_SHELP )
*     SHLPPARAM         = ' '
      DYNPPROG          = SY-REPID
      DYNPNR            = SY-DYNNR
      DYNPROFIELD       = CONV DYNFNAM( PV_FIELD )
*     STEPL             = 0
*     VALUE             = ' '
*     MULTIPLE_CHOICE   = ' '
*     DISPLAY           = ' '
*     SUPPRESS_RECORDLIST       = ' '
*     CALLBACK_PROGRAM  = ' '
*     CALLBACK_FORM     = ' '
*     CALLBACK_METHOD   =
*     SELECTION_SCREEN  = ' '
*   IMPORTING
*     USER_RESET        =
    TABLES
      RETURN_TAB        = GT_RTAB
    EXCEPTIONS
      FIELD_NOT_FOUND   = 1
      NO_HELP_FOR_FIELD = 2
      INCONSISTENT_HELP = 3
      NO_VALUES_FOUND   = 4
      OTHERS            = 5.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form F4_A_FLIEF
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_LIST_MATNR
*&---------------------------------------------------------------------*
FORM F4_A_FLIEF USING PV_MATNR.

  CLEAR : GR_MATNR[].

  IF PV_MATNR IS NOT INITIAL.
    GR_MATNR[] = VALUE #( ( SIGN   = GC_I
                            OPTION = GC_EQ
                            LOW    = PV_MATNR ) ).
  ENDIF.

  PERFORM SET_F4_FLIEF USING 'FLIEF'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form F4IF_TABLE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LT_LIFNR
*&      --> P_
*&      --> P_
*&---------------------------------------------------------------------*
FORM F4IF_TABLE TABLES PT_VTAB
                 USING PV_RFIELD
                       PV_DFIELD.

  CLEAR : GT_RTAB[].

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
*     DDIC_STRUCTURE  = ' '
      RETFIELD        = PV_RFIELD
*     PVALKEY         = ' '
      DYNPPROG        = SY-CPROG
      DYNPNR          = SY-DYNNR
      DYNPROFIELD     = PV_DFIELD
*     STEPL           = 0
*     WINDOW_TITLE    =
*     VALUE           = ' '
      VALUE_ORG       = GC_S
*     MULTIPLE_CHOICE = ' '
*     DISPLAY         = ' '
*     CALLBACK_PROGRAM       = ' '
*     CALLBACK_FORM   = ' '
*     CALLBACK_METHOD =
*     MARK_TAB        =
*     IMPORTING
*     USER_RESET      =
    TABLES
      VALUE_TAB       = PT_VTAB
*     FIELD_TAB       =
      RETURN_TAB      = GT_RTAB
*     DYNPFLD_MAPPING =
    EXCEPTIONS
      PARAMETER_ERROR = 1
      NO_VALUES_FOUND = 2
      OTHERS          = 3.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PRCS_CBAN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PRCS_CBAN.

  PERFORM CHECK_CBAN.
  CHECK GV_ERR IS INITIAL.

  PERFORM POPUP_TO_CONFIRM USING '확인'(P01)
                                 '구매요청을 생성하시겠습니까?'(P02).
  CHECK GV_ANS = GC_1.

  "선택한 라인별 PR 생성(Item은 무조건 1개(10번))
  LOOP AT GT_ROW INTO GS_ROW.
    READ TABLE GT_LIST INDEX GS_ROW-INDEX.
    CHECK SY-SUBRC = 0.

    PERFORM SET_RHDR.
    PERFORM SET_RITM.
    PERFORM SET_RTXT.

    PERFORM BAPI_PR_CREATE.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_CBAN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CHECK_CBAN.

  PERFORM GET_SELECTED_ROWS USING GR_GRID 'M' 'X'
                                  '구매요청 생성할 레코드(들)을 선택하세요.'(M02).
  CHECK GV_ERR IS INITIAL.

  LOOP AT GT_ROW INTO GS_ROW.
    READ TABLE GT_LIST INDEX GS_ROW-INDEX.
    CHECK SY-SUBRC = 0.

    IF GT_LIST-BANFN IS NOT INITIAL.
      MESSAGE S114 DISPLAY LIKE 'E'. "이미 구매요청이 생성된 레코드가 있습니다.
      GV_ERR = GC_X. EXIT.
    ENDIF.

    PERFORM CHECK_NULL.

    IF GT_LIST-STATUS = ICON_DEFECT.
      MESSAGE S006 DISPLAY LIKE 'E'. "에러 내역이 존재합니다.
      GV_ERR = GC_X. EXIT.
    ENDIF.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_NULL
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CHECK_NULL.

  CHECK GT_LIST-BANFN IS INITIAL.

  PERFORM ASSIGN_GFS USING GT_LIST.

  PERFORM CHECK_MAND USING GT_LIST-AFNAM 'AFNAM' '요청자'(F07).
  PERFORM CHECK_MAND USING GT_LIST-MATNR 'MATNR' '자재'(F08).
  PERFORM CHECK_MAND USING GT_LIST-LENTH 'LENTH' '길이(MM)'(F09).
  PERFORM CHECK_MAND USING GT_LIST-NUMBR 'NUMBR' '개수(EA)'(F10).
  PERFORM CHECK_MAND USING GT_LIST-LFDAT 'LFDAT' '납품일'(F11).
  PERFORM CHECK_MAND USING GT_LIST-FLIEF 'FLIEF' '고정 공급업체'(F12).

  PERFORM RESET_STATUS.

  MODIFY GT_LIST INDEX GS_ROW-INDEX
          TRANSPORTING STATUS MSG COLOR.
  GV_REF = GC_X.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_RHDR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_RHDR.

  CLEAR : GS_RHDR, GS_RHDRX, GT_RTN[].

  GS_RHDR-PR_TYPE  = GC_NB.
  GS_RHDRX-PR_TYPE = GC_X.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_RITM
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_RITM.

  CLEAR : GT_RITM, GT_RITMX, GT_RITM[], GT_RITMX[].

  GT_RITM-PREQ_ITEM     = 10.
  GT_RITM-PUR_GROUP     = GT_LIST-EKGRP.  "구매그룹
  GT_RITM-PREQ_NAME     = GT_LIST-AFNAM.  "요청자
  GT_RITM-MATERIAL_LONG = GT_LIST-MATNR.  "자재코드
  GT_RITM-PLANT         = GT_LIST-WERKS.  "플랜트
  GT_RITM-STORE_LOC     = GT_LIST-LGORT.  "저장위치
  GT_RITM-QUANTITY      = GT_LIST-BAMNG.  "PR수량
  GT_RITM-UNIT          = GT_LIST-BAMEI.  "PR단위
  GT_RITM-PREQ_DATE     = GT_LIST-BADAT.  "요청일
  GT_RITM-DELIV_DATE    = GT_LIST-LFDAT.  "납품일
  GT_RITM-GR_IND        = GC_X.
  GT_RITM-IR_IND        = GC_X.
  GT_RITM-FIXED_VEND    = GT_LIST-FLIEF.  "고정공급업체
  GT_RITM-PURCH_ORG     = GT_LIST-EKORG.  "구매조직


  GT_RITMX-PREQ_ITEM     = 10.
  GT_RITMX-PREQ_ITEMX    = GC_X.
  GT_RITMX-PUR_GROUP     = GC_X.
  GT_RITMX-PREQ_NAME     = GC_X.
  GT_RITMX-MATERIAL_LONG = GC_X.
  GT_RITMX-PLANT         = GC_X.
  GT_RITMX-STORE_LOC     = SWITCH #( GT_LIST-LGORT WHEN ' ' THEN ' '
                                                            ELSE 'X' ).
  GT_RITMX-QUANTITY      = GC_X.
  GT_RITMX-UNIT          = GC_X.
  GT_RITMX-PREQ_DATE     = GC_X.
  GT_RITMX-DELIV_DATE    = GC_X.
  GT_RITMX-GR_IND        = GC_X.
  GT_RITMX-IR_IND        = GC_X.
  GT_RITMX-FIXED_VEND    = GC_X.
  GT_RITMX-PURCH_ORG     = GC_X.

  APPEND : GT_RITM, GT_RITMX.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_RTXT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_RTXT.

  "Item Text 추가(PSJ 25.05.12)

  CLEAR : GT_RTXT, GT_RTXT[].

  GT_RTXT-PREQ_ITEM = 10.
  GT_RTXT-TEXT_ID   = GC_B01.
  GT_RTXT-TEXT_FORM = GC_*.
  GT_RTXT-TEXT_LINE = GT_LIST-ETCTX.

  APPEND GT_RTXT.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form BAPI_PR_CREATE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM BAPI_PR_CREATE.

  CALL FUNCTION 'BAPI_PR_CREATE'
    EXPORTING
      PRHEADER   = GS_RHDR
      PRHEADERX  = GS_RHDRX
*     TESTRUN    =
    IMPORTING
      NUMBER     = GS_RHDR-PREQ_NO
    TABLES
      RETURN     = GT_RTN
      PRITEM     = GT_RITM
      PRITEMX    = GT_RITMX
      PRITEMTEXT = GT_RTXT.

  READ TABLE GT_RTN WITH KEY TYPE = GC_E.

  IF SY-SUBRC <> 0 AND GS_RHDR-PREQ_NO IS NOT INITIAL.
    PERFORM BAPI_COMMIT.

    CLEAR : GT_LIST-MSG[], GT_LIST-STYLE[].

    GT_LIST-STATUS = ICON_LED_GREEN.
    GT_LIST-BANFN  = GS_RHDR-PREQ_NO.
    GT_LIST-BNFPO  = 10.

    PERFORM MODIFY_6500 USING GT_LIST.
  ELSE.
    PERFORM BAPI_ROLLBACK.

    ASSIGN COMPONENT 'MSG' OF STRUCTURE GT_LIST TO <GFS_MSG>.
    PERFORM SET_ERR_MSG USING GT_LIST-STATUS.
  ENDIF.

  MODIFY GT_LIST INDEX GS_ROW-INDEX
          TRANSPORTING STATUS BANFN BNFPO MSG STYLE
                       ERNAM  ERDAT_LOCAL ERTIM_LOCAL.
  GV_REF = GC_X.

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
*& Form MODIFY_6500
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_LIST
*&---------------------------------------------------------------------*
FORM MODIFY_6500 USING PS_LIST.

  DATA : LS_6500 LIKE ZGTMMT6500.


  MOVE-CORRESPONDING PS_LIST TO LS_6500.
  LS_6500-GUIDC = CL_SYSTEM_UUID=>CREATE_UUID_C32_STATIC( ).

  PERFORM SET_TIMESTAMP USING 'X' ' '.
  MOVE-CORRESPONDING GS_CREA TO LS_6500.

  MODIFY ZGTMMT6500 FROM LS_6500.

  CHECK SY-SUBRC = 0.
  COMMIT WORK.

  MOVE-CORRESPONDING GS_CREA TO PS_LIST.

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
*& Form SET_ERR_MSG
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_LIST_STATUS
*&---------------------------------------------------------------------*
FORM SET_ERR_MSG USING PV_STATUS.

  PV_STATUS = ICON_LED_RED.

  "모든 에러 메세지를 보여준다!
  LOOP AT GT_RTN.
    CHECK GT_RTN-TYPE = GC_E OR GT_RTN-TYPE = GC_A.

    PERFORM SET_POP_MSG USING GT_RTN-TYPE
                              GT_RTN-ID
                              GT_RTN-NUMBER
                              GT_RTN-MESSAGE_V1
                              GT_RTN-MESSAGE_V2
                              GT_RTN-MESSAGE_V3
                              GT_RTN-MESSAGE_V4.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SEND_MAIL
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SEND_MAIL.

  PERFORM CHECK_MAIL.
  CHECK GV_ERR IS INITIAL.

  IF GV_CHK = GC_X.
    PERFORM POPUP_TO_CONFIRM USING '확인'(P01)
                                   '이미 메일 전송한 레코드에 대해서도 다시 전송합니다. 진행하시겠습니까?'(P03).
    CHECK GV_ANS = GC_1.
  ENDIF.

  PERFORM GET_EM_RECV.

  CALL SCREEN 200 STARTING AT 10 5
                    ENDING AT 60 7.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_MAIL
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CHECK_MAIL.

  RANGES : LR_FLIEF FOR EBAN-FLIEF.


  CLEAR : GV_CHK, GS_SND, GT_SND[].

  PERFORM GET_SELECTED_ROWS USING GR_GRID 'M' 'X'
                                  '메일을 전송할 레코드(들)을 선택하세요.'(M03).
  CHECK GV_ERR IS INITIAL.

  LOOP AT GT_ROW INTO GS_ROW.
    READ TABLE GT_LIST INDEX GS_ROW-INDEX.
    CHECK SY-SUBRC = 0.

    IF GT_LIST-STATUS = ICON_DEFECT
    OR GT_LIST-STATUS = ICON_LED_RED.
      MESSAGE S006 DISPLAY LIKE 'E'. "에러 내역이 존재합니다.
      GV_ERR = GC_X. EXIT.
    ENDIF.

    IF GT_LIST-BANFN IS INITIAL.
      MESSAGE S115 DISPLAY LIKE 'E'. "구매요청번호가 없는 레코드가 존재합니다.
      GV_ERR = GC_X. EXIT.
    ENDIF.

    LR_FLIEF-LOW = GT_LIST-FLIEF.
    COLLECT LR_FLIEF.

    "메일 전송일 존재여부 Check
    IF GT_LIST-EM_DATLO IS NOT INITIAL.
      GV_CHK = GC_X.
    ENDIF.

    "메일 전송 대상 Data
    MOVE-CORRESPONDING GT_LIST TO GS_SND.
    MOVE-CORRESPONDING GT_LIST TO GT_SND.
    APPEND GT_SND.
  ENDLOOP.

  CHECK GV_ERR IS INITIAL.

  IF LINES( LR_FLIEF ) > 1.
    MESSAGE S116 DISPLAY LIKE 'E'. "선택한 레코드들의 고정 공급업체가 다릅니다.
    GV_ERR = GC_X. EXIT.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_EM_RECV
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_EM_RECV.

  SELECT EM_RECV, EM_DATLO, EM_TIMLO
    FROM ZGTMMT6500
   WHERE FLIEF    = @GS_SND-FLIEF
     AND EM_RECV <> @SPACE
    INTO TABLE @DATA(LT_EM).

  IF LT_EM IS NOT INITIAL.
    SORT LT_EM BY EM_DATLO DESCENDING EM_TIMLO DESCENDING.

    GS_SND-EM_RECV = LT_EM[ 1 ]-EM_RECV.
  ELSE.
    "Address Number에 매핑된 사번이 여러건일 경우, 아무건이나 하나로 지정
    SELECT SINGLE A~SMTP_ADDR
      FROM LFA1 AS L INNER JOIN ADR6 AS A
        ON L~ADRNR = A~ADDRNUMBER
      INTO GS_SND-EM_RECV
     WHERE L~LIFNR = GS_SND-FLIEF.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SEND_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SEND_DATA.

  CLEAR : GV_ERR.

  IF GS_SND-EM_RECV IS INITIAL.
    MESSAGE S278(00) WITH '수신자 E-Mail'(F26) DISPLAY LIKE 'E'.
    GV_ERR = GC_X. EXIT.
  ENDIF.

  PERFORM SET_MAIL_MSG.

  CALL FUNCTION 'ZGTED_SEND_MAIL'
    EXPORTING
      I_UNAME     = SY-UNAME
      I_EMAIL     = CONV AD_SMTPADR( GS_SND-EM_RECV )
      I_HEAD_TEXT = GV_TEXT
    IMPORTING
      E_RETURN    = GV_CHK
      E_MESSAGE   = GV_MSG
    TABLES
      T_MSG       = GT_MTXT.

  CASE GV_CHK.
    WHEN 'S'.
      PERFORM UPDATE_6500_BY_ZGUID.
      GV_REF = GC_X.

    WHEN 'E'.

  ENDCASE.

  MESSAGE S000 WITH GV_MSG+0(50) GV_MSG+50(50) DISPLAY LIKE GV_CHK.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_MAIL_MSG
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_MAIL_MSG.

  DATA : LV_TXT TYPE SO_TEXT255.

  DATA : LV_NUMBR TYPE DEC10,
         LV_BAMNG LIKE EBAN-MENGE.


  "HTML 양식 변경 가능 (확인!!)

  CLEAR : GV_TEXT, GT_MTXT.
  CLEAR : GV_CHK,  GV_MSG.

  GV_TEXT = 'LS전선 부스닥트 Busbar 발주'(T01).

  _SET_HTML1 '<!DOCTYPE HTML>'.
  _SET_HTML1 '<HTML LANG="KO">'.
  _SET_HTML1 '<HEAD>'.
  _SET_HTML1 '<META CHARSET="UTF-8">'.
  _SET_HTML1 '<META NAME="VIEWPORT" CONTENT="WIDTH=DEVICE-WIDTH, INITIAL-SCALE=1.0">'.
  _SET_HTML1 '</HEAD>'.
  _SET_HTML1 '<STYLE TYPE="TEXT/CSS">'.
  _SET_HTML1 '.TG  {BORDER-COLLAPSE:COLLAPSE;BORDER-SPACING:0;}'.
  _SET_HTML1 '.TG TD{BORDER-COLOR:BLACK;BORDER-STYLE:SOLID;BORDER-WIDTH:1PX;FONT-FAMILY:ARIAL, SANS-SERIF;FONT-SIZE:14PX;OVERFLOW:HIDDEN;PADDING:5PX 5PX;WORD-BREAK:NORMAL;}'.
  _SET_HTML1 '.TG TH{BORDER-COLOR:BLACK;BORDER-STYLE:SOLID;BORDER-WIDTH:1PX;FONT-FAMILY:ARIAL, SANS-SERIF;FONT-SIZE:14PX;FONT-WEIGHT:NORMAL;OVERFLOW:HIDDEN;PADDING:5PX 5PX;WORD-BREAK:NORMAL;}'.
  _SET_HTML1 '.TG .TG-UC1A{BACKGROUND-COLOR:#ECF4FF;BORDER-COLOR:#FFFFFF;FONT-SIZE:14PX;FONT-WEIGHT:BOLD;TEXT-ALIGN:LEFT;TEXT-DECORATION:UNDERLINE;VERTICAL-ALIGN:MIDDLE}'.
  _SET_HTML1 '.TG .TG-8V3G{BORDER-COLOR:#FFFFFF;FONT-SIZE:14PX;TEXT-ALIGN:CENTER;VERTICAL-ALIGN:MIDDLE}'.
  _SET_HTML1 '.TG .TG-ASEA{BACKGROUND-COLOR:#ECF4FF;BORDER-COLOR:INHERIT;FONT-FAMILY:ARIAL, HELVETICA, SANS-SERIF !IMPORTANT;FONT-SIZE:14PX;FONT-WEIGHT:BOLD;TEXT-ALIGN:CENTER;VERTICAL-ALIGN:MIDDLE}'.
  _SET_HTML1 '.TG .TG-IRF4{BACKGROUND-COLOR:#ECF4FF;BORDER-COLOR:INHERIT;FONT-FAMILY:ARIAL, HELVETICA, SANS-SERIF !IMPORTANT;FONT-SIZE:14PX;FONT-WEIGHT:BOLD;TEXT-ALIGN:LEFT;VERTICAL-ALIGN:MIDDLE}'.
  _SET_HTML1 '.TG .TG-STQD{BACKGROUND-COLOR:#ECF4FF;BORDER-COLOR:INHERIT;FONT-FAMILY:ARIAL, HELVETICA, SANS-SERIF !IMPORTANT;FONT-SIZE:14PX;FONT-WEIGHT:BOLD;TEXT-ALIGN:RIGHT;VERTICAL-ALIGN:MIDDLE}'.
  _SET_HTML1 '.TG .TG-51BG{BORDER-COLOR:INHERIT;FONT-FAMILY:ARIAL, HELVETICA, SANS-SERIF !IMPORTANT;FONT-SIZE:14PX;TEXT-ALIGN:CENTER;VERTICAL-ALIGN:MIDDLE}'.
  _SET_HTML1 '.TG .TG-T8XM{BORDER-COLOR:INHERIT;FONT-FAMILY:ARIAL, HELVETICA, SANS-SERIF !IMPORTANT;FONT-SIZE:14PX;TEXT-ALIGN:LEFT;VERTICAL-ALIGN:MIDDLE}'.
  _SET_HTML1 '.TG .TG-E6JF{BORDER-COLOR:INHERIT;FONT-FAMILY:ARIAL, HELVETICA, SANS-SERIF !IMPORTANT;FONT-SIZE:14PX;TEXT-ALIGN:RIGHT;VERTICAL-ALIGN:MIDDLE}'.
  _SET_HTML1 '.TG .TG-WC2Q{BORDER-COLOR:#FFFFFF;FONT-SIZE:14PX;TEXT-ALIGN:LEFT;VERTICAL-ALIGN:MIDDLE}'.
  _SET_HTML1 '.TG .TG-022R{BACKGROUND-COLOR:#ECF4FF;BORDER-COLOR:#FFFFFF;FONT-SIZE:14PX;FONT-WEIGHT:BOLD;TEXT-ALIGN:RIGHT;TEXT-DECORATION:UNDERLINE;VERTICAL-ALIGN:MIDDLE}'.
  _SET_HTML1 '</STYLE>'.
  _SET_HTML1 '<BODY>'.

  LV_TXT = |<P STYLE="MARGIN: 0; PADDING: 0; FONT-WEIGHT:BOLD; FONT-SIZE: 14PX;">| && GS_SND-NAME1 && | 귀중</P><BR>|.
  _SET_HTML1 LV_TXT.
  _SET_HTML1 '<P STYLE="MARGIN: 0; PADDING: 0; FONT-SIZE: 14PX;">하기와 같이 Busbar에 대한 발주 내역을 보내 드립니다.</P>'.
  _SET_HTML1 '<TABLE CLASS="TG" STYLE="WIDTH: 100%; BORDER-COLLAPSE: COLLAPSE; TABLE-LAYOUT: FIXED; BORDER-SPACING: 0;" CELLPADDING="0" CELLSPACING="0"><COLGROUP>'.
  _SET_HTML1 '<COL STYLE="WIDTH: 10%"><COL STYLE="WIDTH: 9%"><COL STYLE="WIDTH: 46%"><COL STYLE="WIDTH: 12%">'.
  _SET_HTML1 '<COL STYLE="WIDTH: 4%"><COL STYLE="WIDTH: 4%"><COL STYLE="WIDTH: 4%"><COL STYLE="WIDTH: 11%"></COLGROUP>'.
  _SET_HTML1 '<THEAD>'.
  _SET_HTML1 '<TR>'.
  _SET_HTML1 '<TH CLASS="TG-ASEA">구매요청번호</TH>'.
  _SET_HTML1 '<TH CLASS="TG-ASEA">납기일</TH>'.
  _SET_HTML1 '<TH CLASS="TG-IRF4">제품명</TH>'.
  _SET_HTML1 '<TH CLASS="TG-STQD">길이(MM)</TH>'.
  _SET_HTML1 '<TH CLASS="TG-STQD">개수(EA)</TH>'.
  _SET_HTML1 '<TH CLASS="TG-STQD">수량</TH>'.
  _SET_HTML1 '<TH CLASS="TG-ASEA">단위</TH>'.
  _SET_HTML1 '<TH CLASS="TG-ASEA">자재코드</TH>'.
  _SET_HTML1 '</TR>'.
  _SET_HTML1 '</THEAD>'.
  _SET_HTML1 '<TBODY>'.

  LOOP AT GT_SND.
    PERFORM CONVERT_DATA.

    _SET_HTML1 '<TR>'.
    _SET_HTML3 '<TD CLASS="TG-51BG">' GS_ITM-BANFN '</TD>'.
    _SET_HTML3 '<TD CLASS="TG-51BG">' GS_ITM-LFDAT '</TD>'.
    _SET_HTML3 '<TD CLASS="TG-T8XM">' GS_ITM-MAKTX '</TD>'.
    _SET_HTML3 '<TD CLASS="TG-E6JF">' GS_ITM-LENTH '</TD>'.
    _SET_HTML3 '<TD CLASS="TG-E6JF">' GS_ITM-NUMBR '</TD>'.
    _SET_HTML3 '<TD CLASS="TG-E6JF">' GS_ITM-BAMNG '</TD>'.
    _SET_HTML3 '<TD CLASS="TG-51BG">' GS_ITM-BAMEI '</TD>'.
    _SET_HTML3 '<TD CLASS="TG-51BG">' GS_ITM-MATNR '</TD>'.
    _SET_HTML1 '</TR>'.

    LV_NUMBR = LV_NUMBR + GT_SND-NUMBR.
    LV_BAMNG = LV_BAMNG + GT_SND-BAMNG.
  ENDLOOP.

  PERFORM BUX_DECIMAL_START USING LV_NUMBR
                         CHANGING GS_ITM-NUMBR.

  WRITE LV_BAMNG TO GS_ITM-BAMNG UNIT GT_SND-BAMEI.
  CONDENSE GS_ITM-BAMNG.

  _SET_HTML1 '<TR>'.
  _SET_HTML1 '<TD CLASS="TG-WC2Q"></TD>'.
  _SET_HTML1 '<TD CLASS="TG-WC2Q"></TD>'.
  _SET_HTML1 '<TD CLASS="TG-UC1A">합계</TD>'.
  _SET_HTML1 '<TD CLASS="TG-022R"></TD>'.
  _SET_HTML3 '<TD CLASS="TG-022R">' GS_ITM-NUMBR '</TD>'. "개수 합계
  _SET_HTML3 '<TD CLASS="TG-022R">' GS_ITM-BAMNG '</TD>'. "수량 합계
  _SET_HTML1 '<TD CLASS="TG-WC2Q"></TD>'.
  _SET_HTML1 '<TD CLASS="TG-8V3G"></TD>'.
  _SET_HTML1 '</TR>'.
  _SET_HTML1 '</TBODY>'.
  _SET_HTML1 '</TABLE>'.
  _SET_HTML1 '<BR>'.
  _SET_HTML1 '<P STYLE="MARGIN: 0; PADDING: 0; FONT-SIZE: 14PX;">발주서에 이상이 있는 경우 부스닥트 생산관리 담당자에게 문의 바랍니다.</P><BR>'.
  _SET_HTML1 '<P STYLE="MARGIN: 0; PADDING: 0; FONT-SIZE: 14PX;">LS전선 부스닥트생산</P>'.
  _SET_HTML1 '</BODY>'.
  _SET_HTML1 '</HTML>'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CONVERT_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CONVERT_DATA.

  CLEAR : GS_ITM.

  GS_ITM-BANFN = |{ GT_SND-BANFN ALPHA = OUT }|.

  PERFORM CONVERSION_EXIT_PDATE_OUTPUT USING GT_SND-LFDAT
                                    CHANGING GS_ITM-LFDAT.

  GS_ITM-MAKTX = GT_SND-MAKTX.

  PERFORM BUX_DECIMAL_START USING GT_SND-LENTH
                         CHANGING GS_ITM-LENTH.

  PERFORM BUX_DECIMAL_START USING GT_SND-NUMBR
                         CHANGING GS_ITM-NUMBR.

  WRITE GT_SND-BAMNG TO GS_ITM-BAMNG UNIT GT_SND-BAMEI.
  CONDENSE GS_ITM-BAMNG.
  GS_ITM-BAMEI = GT_SND-BAMEI.

  PERFORM CONVERT_MATN1_OUTPUT USING GT_SND-MATNR
                            CHANGING GS_ITM-MATNR.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CONVERSION_EXIT_PDATE_OUTPUT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_SND_LFDAT
*&      <-- GS_ITM_LFDAT
*&---------------------------------------------------------------------*
FORM CONVERSION_EXIT_PDATE_OUTPUT USING PV_IVAL
                               CHANGING PV_OVAL.

  CLEAR : PV_OVAL.
  CHECK PV_IVAL IS NOT INITIAL.

  CALL FUNCTION 'CONVERSION_EXIT_PDATE_OUTPUT'
    EXPORTING
      INPUT  = PV_IVAL
    IMPORTING
      OUTPUT = PV_OVAL.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form BUX_DECIMAL_START
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_SND_LENTH
*&      <-- GS_ITM_LENTH
*&---------------------------------------------------------------------*
FORM BUX_DECIMAL_START USING PV_IVAL
                    CHANGING PV_OVAL.

  DATA : LV_IVAL TYPE STRING.


  CLEAR : PV_OVAL.
  CHECK PV_IVAL IS NOT INITIAL.

  LV_IVAL = PV_IVAL.

  CALL FUNCTION 'BUX_DECIMAL_START'
    EXPORTING
      I_VALUE_DB       = LV_IVAL
    IMPORTING
      E_VALUE_DYNP     = PV_OVAL
    EXCEPTIONS
      FORMAT_EXCEPTION = 1
      OTHERS           = 2.

  CHECK PV_OVAL IS NOT INITIAL.

  DATA(LV_LEN) = STRLEN( PV_OVAL ) - 1.
  IF PV_OVAL+LV_LEN(1) = '.'.
    CLEAR : PV_OVAL+LV_LEN(1).
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CONVERT_MATN1_OUTPUT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_SND_MATNR
*&      <-- GS_ITM_MATNR
*&---------------------------------------------------------------------*
FORM CONVERT_MATN1_OUTPUT USING PV_IVAL
                       CHANGING PV_OVAL.

  CLEAR : PV_OVAL.
  CHECK PV_IVAL IS NOT INITIAL.

  CALL FUNCTION 'CONVERSION_EXIT_MATN1_OUTPUT'
    EXPORTING
      INPUT  = PV_IVAL
    IMPORTING
      OUTPUT = PV_OVAL.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form UPDATE_6500_BY_ZGUID
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM UPDATE_6500_BY_ZGUID.

  DATA : BEGIN OF LS_EM,
           EM_RECV  LIKE ZGTMMT6500-EM_RECV,
           EM_UNAME LIKE ZGTMMT6500-EM_UNAME,
           EM_DATLO LIKE ZGTMMT6500-EM_DATLO,
           EM_TIMLO LIKE ZGTMMT6500-EM_TIMLO,
         END   OF LS_EM.


  LS_EM-EM_RECV  = GS_SND-EM_RECV.
  LS_EM-EM_UNAME = SY-UNAME.
  LS_EM-EM_DATLO = SY-DATLO.
  LS_EM-EM_TIMLO = SY-TIMLO.

  LOOP AT GT_SND.
    UPDATE ZGTMMT6500 SET EM_RECV  = LS_EM-EM_RECV
                          EM_UNAME = LS_EM-EM_UNAME
                          EM_DATLO = LS_EM-EM_DATLO
                          EM_TIMLO = LS_EM-EM_TIMLO
                    WHERE BANFN    = GT_SND-BANFN.

    CHECK SY-SUBRC = 0.
    READ TABLE GT_LIST WITH KEY BANFN = GT_SND-BANFN.

    IF SY-SUBRC = 0.
      MOVE-CORRESPONDING LS_EM TO GT_LIST.
      MODIFY GT_LIST INDEX SY-TABIX
              TRANSPORTING EM_RECV EM_UNAME EM_DATLO EM_TIMLO.
    ENDIF.
  ENDLOOP.

  COMMIT WORK.

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

  CASE PV_OTEXT.
    WHEN 'GR_GRID'.
      IF PS_COL-FIELDNAME = GC_STATUS.
        READ TABLE GT_LIST INDEX PS_ROW-INDEX.
        CHECK SY-SUBRC = 0.

        PERFORM DISPLAY_MSG.
      ENDIF.

    WHEN OTHERS.

  ENDCASE.

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


  IF ( GT_LIST-STATUS = ICON_LED_GREEN
    OR GT_LIST-STATUS = ICON_LED_YELLOW )
  OR GT_LIST-MSG IS INITIAL.
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

  CASE PV_OTEXT.
    WHEN 'GR_GRID'.
      READ TABLE GT_LIST INDEX PS_ROW-INDEX.
      CHECK SY-SUBRC = 0.

      CASE PS_COL-FIELDNAME.
        WHEN 'BANFN'.
          CHECK GT_LIST-BANFN IS NOT INITIAL.
          SET PARAMETER ID 'BAN' FIELD GT_LIST-BANFN.
          CALL TRANSACTION 'ME53N' AND SKIP FIRST SCREEN.

        WHEN 'EBELN'.  "추가(PSJ 25.04.17)
          CHECK GT_LIST-EBELN IS NOT INITIAL.
          SET PARAMETER ID 'BES' FIELD GT_LIST-EBELN.
          CALL TRANSACTION 'ME23N' AND SKIP FIRST SCREEN.

      ENDCASE.

    WHEN OTHERS.

  ENDCASE.

ENDFORM.
