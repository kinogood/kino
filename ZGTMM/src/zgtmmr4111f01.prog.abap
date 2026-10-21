*&---------------------------------------------------------------------*
*& Include          ZGTMMR4111F01
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

  PERFORM SET_FUNC_KEY. "추가(SJM 25.02.17)

  CLEAR : S_BUDAT[].
  S_BUDAT[] = VALUE #( ( SIGN   = GC_I
                         OPTION = GC_BT
                         LOW    = SY-DATLO - 30
                         HIGH   = SY-DATLO ) ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_FUNC_KEY
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_FUNC_KEY.

* GS_FKEY-TEXT
  GS_FKEY-ICON_ID   = ICON_TRANSFER.
  GS_FKEY-ICON_TEXT = '재고불출'(B00).
  GS_FKEY-QUICKINFO = '재고불출'(B00).

  SSCRFIELDS-FUNCTXT_01 = GS_FKEY.

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

  LOOP AT SCREEN.
    CASE 'X'.
      WHEN P_ORP.
        IF ( ( SCREEN-GROUP3 = GC_HGH OR SCREEN-GROUP3 = GC_VPU )
           AND SCREEN-GROUP4 = GC_004 )
        OR (   SCREEN-GROUP1 = GC_ORP ).
          SCREEN-ACTIVE = GC_0.
          MODIFY SCREEN.
        ENDIF.

        IF SCREEN-GROUP4 <> GC_005.
          SCREEN-REQUIRED = GC_2.
          MODIFY SCREEN.
        ENDIF.

      WHEN P_ORD.
*       IF SCREEN-GROUP4 <> GC_004. "삭제(SJM 25.06.11)
        SCREEN-REQUIRED = GC_2.
        MODIFY SCREEN.
*       ENDIF.

    ENDCASE.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_ACTV
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CHECK_ACTV.

  "Pgm.실행 Active Flag Check(SJM 25.04.17)

  SELECT SINGLE FLD_03
    FROM ZGTPPT1010 INTO @DATA(LV_CHK)
   WHERE MODULE_KIND = @GC_MM
     AND CODEGRP     = @GC_0200
     AND FLD_01      = @GC_ZGTMMR4111.

  CHECK LV_CHK IS INITIAL.
  MESSAGE E134. "해당 Pgm.은 실행 불가한 상태입니다.

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

  "권한 체크 추가(SJM 25.02.17)

  AUTHORITY-CHECK OBJECT 'ZPP_WERKS'
               ID 'WERKS' FIELD P_WERKS.

  CHECK SY-SUBRC <> 0.

  SET CURSOR FIELD 'P_WERKS'.
  MESSAGE E106 WITH P_WERKS. "플랜트 [&] 작업권한을 확인하세요.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PAI_1000
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PAI_1000.

  "'재고불출' Pgm.이동 기능 추가(SJM 25.02.17)

  CHECK SY-DYNNR = GC_1000.

  CASE SSCRFIELDS-UCOMM.
    WHEN 'FC01'.
      SUBMIT ZGTMMR4110 WITH P_BUKRS  = P_BUKRS
                        WITH P_WERKS  = P_WERKS
                        WITH P_LGORT  = P_LGORT
                        WITH S_LIFNR IN S_LIFNR
                        WITH P_GOP    = GC_X
                        VIA SELECTION-SCREEN.

  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form DYNP_VALUES_READ
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      <-- P_BUKRS
*&---------------------------------------------------------------------*
FORM DYNP_VALUES_READ USING PV_FNAME
                   CHANGING PV_FVAL.

  DATA : LT_DYN LIKE DYNPREAD OCCURS 0 WITH HEADER LINE.


  CLEAR : LT_DYN[], PV_FVAL.
  LT_DYN[] = VALUE #( ( FIELDNAME = PV_FNAME ) ).

  CALL FUNCTION 'DYNP_VALUES_READ'
    EXPORTING
      DYNAME               = SY-REPID
      DYNUMB               = SY-DYNNR
    TABLES
      DYNPFIELDS           = LT_DYN
    EXCEPTIONS
      INVALID_ABAPWORKAREA = 1
      INVALID_DYNPROFIELD  = 2
      INVALID_DYNPRONAME   = 3
      INVALID_DYNPRONUMMER = 4
      INVALID_REQUEST      = 5
      NO_FIELDDESCRIPTION  = 6
      INVALID_PARAMETER    = 7
      UNDEFIND_ERROR       = 8
      DOUBLE_CONVERSION    = 9
      STEPL_NOT_FOUND      = 10
      OTHERS               = 11.

  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
          WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    EXIT.
  ENDIF.

  PV_FVAL = VALUE #( LT_DYN[ 1 ]-FIELDVALUE OPTIONAL ).

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
*& Form F4_WERKS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F4_WERKS.

  PERFORM DYNP_VALUES_READ USING 'P_BUKRS'
                        CHANGING  P_BUKRS.

  SET PARAMETER ID 'BUK' FIELD P_BUKRS.

  PERFORM F4IF_FIELD USING 'T001L'
                           'WERKS'
                           'EDOC_BR_WERKS'
                           'P_WERKS'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form F4_LGORT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F4_LGORT.

  PERFORM DYNP_VALUES_READ USING 'P_WERKS'
                        CHANGING  P_WERKS.

  SET PARAMETER ID 'WRK' FIELD P_WERKS.

  PERFORM F4IF_FIELD USING 'T001L'
                           'LGORT'
                           'ZH_PP_LGORT'
                           'P_LGORT'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_MAND_COND
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CHECK_MAND_COND.

  CLEAR : GV_ERR.

  CASE 'X'.
    WHEN P_ORP.
      IF P_BUKRS IS INITIAL OR P_WERKS   IS INITIAL
      OR P_LGORT IS INITIAL OR S_LIFNR[] IS INITIAL.
        GV_ERR = GC_X.
      ENDIF.

    WHEN P_ORD.
      IF P_BUKRS IS INITIAL OR P_WERKS   IS INITIAL
      OR P_LGORT IS INITIAL OR S_BUDAT[] IS INITIAL.
        GV_ERR = GC_X.
      ENDIF.

  ENDCASE.

  IF GV_ERR = GC_X.
    MESSAGE S018 DISPLAY LIKE 'E'. "필수 입력 정보가 누락되었습니다.
    EXIT.
  ENDIF.

  PERFORM CHECK_COND.

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

  SET PARAMETER ID 'BUK' FIELD P_BUKRS.
  SET PARAMETER ID 'WRK' FIELD P_WERKS.

  "필수 입력 필드 Check
  PERFORM CHECK_NULL USING P_BUKRS 'P_BUKRS' '회사코드'(F01).
  PERFORM CHECK_NULL USING P_WERKS 'P_WERKS' '플랜트'(F03).
  PERFORM CHECK_NULL USING P_LGORT 'P_LGORT' '저장위치'(F19).

  IF P_ORP = GC_X.
    PERFORM CHECK_NULL USING S_LIFNR-LOW 'S_LIFNR-LOW' '외주가공업체'(F29).
  ELSE.
    PERFORM CHECK_NULL USING S_BUDAT-LOW 'S_BUDAT-LOW' '조회기간'(F30).
  ENDIF.

  "--> [CHM2510-00242] WMS 창고 체크 주석 처리
*  PERFORM CHECK_WMS. "추가(SJM 25.06.11)

  "입력값 유효성 Check
  PERFORM CHECK_BUKRS.
  PERFORM CHECK_WERKS.
  PERFORM CHECK_LGORT.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_NULL
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_BUKRS
*&      --> P_
*&      --> P_
*&---------------------------------------------------------------------*
FORM CHECK_NULL USING P_VAL
                      P_FNM
                      P_TXT.

  CHECK GV_ERR IS INITIAL.

  IF P_VAL IS INITIAL.
    PERFORM DYNP_VALUES_READ USING P_FNM
                          CHANGING P_VAL.
  ENDIF.

  CHECK P_VAL IS INITIAL.

  SET CURSOR FIELD P_FNM.
  MESSAGE S015 WITH P_TXT DISPLAY LIKE 'E'. "&를(을) 입력하세요.

  GV_ERR = GC_X.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_WMS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CHECK_WMS.

  "WMS 창고로는 환입이 되지 않도록 제어(SJM 25.06.11)

  CHECK GV_ERR IS INITIAL.

  SELECT SINGLE ZMODE
    FROM ZGTMMT4100 INTO @DATA(LV_ZMODE)
   WHERE BUKRS = @P_BUKRS
     AND WERKS = @P_WERKS
     AND LGORT = @P_LGORT.

  CHECK LV_ZMODE = GC_OD.

  MESSAGE S158 DISPLAY LIKE 'E'. "WMS 관리 창고는 WMS에서 환입 처리하세요.
  GV_ERR = GC_X.

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

  CHECK GV_ERR  IS INITIAL.
  CHECK P_BUKRS IS NOT INITIAL.

  SELECT SINGLE BUKRS
    FROM T001 INTO @DATA(LV_BUKRS)
   WHERE BUKRS = @P_BUKRS.

  CHECK LV_BUKRS IS INITIAL.

  SET CURSOR FIELD 'P_BUKRS'.
  MESSAGE S016 WITH '회사코드'(F01) DISPLAY LIKE 'E'. "&를(을) 확인하세요.

  GV_ERR = GC_X.

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

  "회사코드-플랜트간 종속성 체크

  CHECK GV_ERR  IS INITIAL.
  CHECK P_BUKRS IS NOT INITIAL
    AND P_WERKS IS NOT INITIAL.

  SELECT SINGLE W~WERKS
    FROM T001K AS K INNER JOIN T001W AS W
      ON K~BWKEY = W~BWKEY
    INTO @DATA(LV_WERKS)
   WHERE K~BUKRS = @P_BUKRS
     AND W~WERKS = @P_WERKS.

  CHECK LV_WERKS IS INITIAL.

  SET CURSOR FIELD 'P_WERKS'.
  MESSAGE S016 WITH '플랜트'(F03) DISPLAY LIKE 'E'. "&를(을) 확인하세요.

  GV_ERR = GC_X.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_LGORT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CHECK_LGORT.

  "플랜트-저장위치간 종속성 체크

  CHECK GV_ERR  IS INITIAL.
  CHECK P_WERKS IS NOT INITIAL
    AND P_LGORT IS NOT INITIAL.

  SELECT SINGLE LGORT
    FROM T001L INTO @DATA(LV_LGORT)
   WHERE WERKS = @P_WERKS
     AND LGORT = @P_LGORT.

  CHECK LV_LGORT IS INITIAL.

  SET CURSOR FIELD 'P_LGORT'.
  MESSAGE S016 WITH '저장위치'(F19) DISPLAY LIKE 'E'. "&를(을) 확인하세요.

  GV_ERR = GC_X.

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

  CLEAR : GV_CNT.

  CASE 'X'.
    WHEN P_ORP.
      PERFORM GET_ORP_DATA.

    WHEN P_ORD.
      PERFORM GET_ORD_DATA.

  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_ORP_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_ORP_DATA.

  CLEAR : GT_HORP[].

  SELECT *
    FROM ZGTMM_CV_SCSTOCKITEM_SUM
    INTO CORRESPONDING FIELDS OF TABLE @GT_HORP
   WHERE BUKRS  = @P_BUKRS
     AND WERKS  = @P_WERKS
*    AND LGORT  = @P_LGORT
     AND LIFNR IN @S_LIFNR.

  IF GT_HORP[] IS INITIAL.
    MESSAGE S002 DISPLAY LIKE 'E'. "조회된 값이 없습니다.
    EXIT.
  ENDIF.

  SORT GT_HORP BY MATNR.

  "배치 존재시에만 꼬리표 수정가능하게(SJM 25.03.07)
  PERFORM SET_STYLE USING 'E' 'TAGNR' GT_HORP-STYLE.
  MODIFY GT_HORP TRANSPORTING STYLE WHERE CHARG IS NOT INITIAL.

  GV_CNT = LINES( GT_HORP ).
  MESSAGE S003 WITH GV_CNT. "& 건의 데이터가 조회되었습니다.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_STYLE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> P_
*&      --> GT_HORP_STYLE
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
*& Form GET_ORD_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_ORD_DATA.

  CLEAR : GT_HORD[], GT_IORD[].

  SELECT *
    FROM ZGTMM_CV_MVT542_VENDOR_H
    INTO CORRESPONDING FIELDS OF TABLE @GT_HORD
   WHERE BUKRS  = @P_BUKRS
     AND WERKS  = @P_WERKS
     AND LGORT  = @P_LGORT
     AND LIFNR IN @S_LIFNR
     AND BUDAT IN @S_BUDAT
     AND USNAM  = @SY-UNAME.

  IF GT_HORD[] IS INITIAL.
    MESSAGE S002 DISPLAY LIKE 'E'. "조회된 값이 없습니다.
    EXIT.
  ENDIF.

  SORT GT_HORD BY CPUDT DESCENDING CPUTM DESCENDING.

  GV_CNT = LINES( GT_HORD ).
  MESSAGE S003 WITH GV_CNT. "& 건의 데이터가 조회되었습니다.

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
    WHEN P_ORP.
      GV_TITLE = '외주 재고 환입 처리'(T01).
      GT_EXCD[] = VALUE #( ( 'COSR' ) ).

    WHEN P_ORD.
      GV_TITLE = '환입 처리 결과 조회'(T02).
      GT_EXCD[] = VALUE #( ( 'POSR' ) ).

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

  DATA : LV_ROWS TYPE I.


  GR_DOCK = NEW #( REPID     = SY-REPID
                   DYNNR     = SY-DYNNR
                   SIDE      = CL_GUI_DOCKING_CONTAINER=>DOCK_AT_TOP
                   EXTENSION = 655 ).

  LV_ROWS = COND #( WHEN P_ORP = GC_X THEN 1
                    WHEN P_ORD = GC_X THEN 2 ).

  GR_SPLIT = NEW #( PARENT  = GR_DOCK
                    ROWS    = LV_ROWS
                    COLUMNS = 1 ).

  "#1 Row
  GR_HCNTR = GR_SPLIT->GET_CONTAINER( ROW    = 1
                                      COLUMN = 1 ).

  GR_HGRID = NEW #( I_PARENT      = GR_HCNTR
                    I_APPL_EVENTS = GC_X ).

  CHECK P_ORD = GC_X.

  GR_SPLIT->SET_ROW_HEIGHT( ID     = 1
                            HEIGHT = 50 ).

  "#2 Row
  GR_ICNTR = GR_SPLIT->GET_CONTAINER( ROW    = 2
                                      COLUMN = 1 ).

  GR_IGRID = NEW #( I_PARENT      = GR_ICNTR
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
*&      --> GR_HGRID
*&      --> P_
*&---------------------------------------------------------------------*
FORM SET_F4 USING PR_GRID TYPE REF TO CL_GUI_ALV_GRID
                  PV_OTEXT.

  CLEAR : GT_F4.

  CASE PV_OTEXT.
    WHEN 'GR_HGRID'.
      CASE 'X'.
        WHEN P_ORP.
          "꼬리표 로직 추가(SJM 25.02.27)
          APPEND VALUE #( FIELDNAME = GC_TAGNR
                          REGISTER  = GC_X ) TO GT_F4.

      ENDCASE.
  ENDCASE.

  CALL METHOD PR_GRID->REGISTER_F4_FOR_FIELDS
    EXPORTING
      IT_F4 = GT_F4.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_EVNT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GR_HGRID
*&      --> P_
*&---------------------------------------------------------------------*
FORM SET_EVNT USING PR_GRID TYPE REF TO CL_GUI_ALV_GRID
                    PV_OTEXT.

  GR_EVENTS = NEW LCL_EVENT_HANDLER( E_OBJECT_TEXT = PV_OTEXT ).

  CASE PV_OTEXT.
    WHEN 'GR_HGRID'.
      CASE 'X'.
        WHEN P_ORP.
          SET HANDLER GR_EVENTS->HANDLE_DATA_CHANGED          FOR PR_GRID.
          SET HANDLER GR_EVENTS->HANDLE_DATA_CHANGED_FINISHED FOR PR_GRID.
          SET HANDLER GR_EVENTS->HANDLE_ONF4                  FOR PR_GRID.

          CALL METHOD PR_GRID->SET_READY_FOR_INPUT
            EXPORTING
              I_READY_FOR_INPUT = 1.

          CALL METHOD PR_GRID->REGISTER_EDIT_EVENT
            EXPORTING
              I_EVENT_ID = CL_GUI_ALV_GRID=>MC_EVT_ENTER.

          CALL METHOD PR_GRID->REGISTER_EDIT_EVENT
            EXPORTING
              I_EVENT_ID = CL_GUI_ALV_GRID=>MC_EVT_MODIFIED.

        WHEN P_ORD.
          SET HANDLER GR_EVENTS->HANDLE_HOTSPOT_CLICK         FOR PR_GRID.

      ENDCASE.

    WHEN 'GR_IGRID'.

  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_FCAT_DISP
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_HFCAT
*&      --> GT_HORP
*&      --> GR_HGRID
*&      --> P_
*&---------------------------------------------------------------------*
FORM SET_FCAT_DISP TABLES PT_FCAT TYPE LVC_T_FCAT
                          PT_LIST
                    USING PR_GRID TYPE REF TO CL_GUI_ALV_GRID
                          PV_TNME.

  PERFORM SET_FCAT TABLES PT_FCAT
                          PT_LIST
                    USING PV_TNME.

  PERFORM SET_DISP TABLES PT_FCAT
                          PT_LIST
                    USING PR_GRID
                          PV_TNME.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_FCAT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PT_FCAT
*&      --> PT_LIST
*&      --> PV_TNME
*&---------------------------------------------------------------------*
FORM SET_FCAT TABLES PT_FCAT TYPE LVC_T_FCAT
                     PT_LIST
               USING PV_TNME.

  DATA : LT_FCAT TYPE SLIS_T_FIELDCAT_ALV.


  CLEAR : LT_FCAT[], PT_FCAT[].

  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      I_PROGRAM_NAME     = SY-REPID
      I_INTERNAL_TABNAME = PV_TNME
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
      IT_DATA         = PT_LIST
    EXCEPTIONS
      IT_DATA_MISSING = 1
      OTHERS          = 2.

  LOOP AT PT_FCAT INTO GS_FCAT.
    CLEAR : GS_FCAT-KEY.

    CASE PV_TNME.
      WHEN 'GT_HORP'.
        PERFORM SET_HORP_FCAT.
      WHEN 'GT_HORD'.
        PERFORM SET_HORD_FCAT.
      WHEN 'GT_IORD'.
        PERFORM SET_IORD_FCAT.
    ENDCASE.

    MODIFY PT_FCAT FROM GS_FCAT.
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
*& Form SET_HORP_FCAT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_HORP_FCAT.

  CASE GS_FCAT-FIELDNAME.
    WHEN 'BUKRS'.
      PERFORM SET_FTXT USING '회사코드'(F01).
      GS_FCAT-KEY    = GC_X.
      GS_FCAT-NO_OUT = GC_X.
*     GS_FCAT-JUST   = GC_C.
    WHEN 'BUTXT'.
      PERFORM SET_FTXT USING '회사명'(F02).
      GS_FCAT-KEY    = GC_X.
      GS_FCAT-NO_OUT = GC_X.
    WHEN 'WERKS'.
      PERFORM SET_FTXT USING '플랜트'(F03).
      GS_FCAT-KEY    = GC_X.
      GS_FCAT-NO_OUT = GC_X.
    WHEN 'PLANTNAME'.
      PERFORM SET_FTXT USING '플랜트명'(F04).
      GS_FCAT-KEY    = GC_X.
      GS_FCAT-NO_OUT = GC_X.
    WHEN 'LIFNR'.
      PERFORM SET_FTXT USING '공급업체'(F05).
      GS_FCAT-KEY    = GC_X.
      GS_FCAT-NO_OUT = GC_X.
    WHEN 'VENDORNAME'.
      PERFORM SET_FTXT USING '업체명'(F06).
      GS_FCAT-KEY    = GC_X.
    WHEN 'MATNR'.
      PERFORM SET_FTXT USING '자재'(F07).
    WHEN 'MAKTX'.
      PERFORM SET_FTXT USING '자재명'(F08).
    WHEN 'XPCBT'. "추가(SJM 25.03.10)
      PERFORM SET_FTXT USING '단일배치'(F31).
    WHEN 'CHARG'.
      PERFORM SET_FTXT USING '배치'(F09).
    WHEN 'TAGNR'. "추가(SJM 25.02.27)
      PERFORM SET_FTXT USING '꼬리표'(F32).
*     GS_FCAT-EDIT       = GC_X.
      GS_FCAT-F4AVAILABL = GC_X.
    WHEN 'LBLAB'.
      PERFORM SET_FTXT USING '가용재고수량'(F10).
    WHEN 'REQTY'.
      PERFORM SET_FTXT USING '환입수량'(F11).
      GS_FCAT-EDIT   = GC_X.
    WHEN 'MEINS'.
      PERFORM SET_FTXT USING '단위'(F12).
    WHEN 'TOTALSCVALUE'.
      PERFORM SET_FTXT USING '재고금액'(F13).
    WHEN 'WAERS'.
      PERFORM SET_FTXT USING '통화'(F14).
    WHEN 'TYPE'.
      PERFORM SET_FTXT USING '상태'(F15).
    WHEN 'MESSAGE'.
      PERFORM SET_FTXT USING '메시지 텍스트'(F16).

    WHEN OTHERS.
      GS_FCAT-NO_OUT = GC_X.
      GS_FCAT-TECH   = GC_X.
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_HORD_FCAT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_HORD_FCAT.

  CASE GS_FCAT-FIELDNAME.
    WHEN 'MJAHR'.
      PERFORM SET_FTXT USING '연도'(F17).
      GS_FCAT-KEY = GC_X.
    WHEN 'MBLNR'.
      PERFORM SET_FTXT USING '자재문서번호'(F18).
      GS_FCAT-KEY     = GC_X.
      GS_FCAT-HOTSPOT = GC_X.
    WHEN 'BUKRS'.
      PERFORM SET_FTXT USING '회사코드'(F01).
      GS_FCAT-NO_OUT = GC_X.
    WHEN 'BUKRS_N'.
      PERFORM SET_FTXT USING '회사명'(F02).
      GS_FCAT-NO_OUT = GC_X.
    WHEN 'WERKS'.
      PERFORM SET_FTXT USING '플랜트'(F03).
      GS_FCAT-NO_OUT = GC_X.
    WHEN 'WERKS_N'.
      PERFORM SET_FTXT USING '플랜트명'(F04).
      GS_FCAT-NO_OUT = GC_X.
    WHEN 'LGORT'.
      PERFORM SET_FTXT USING '저장위치'(F19).
      GS_FCAT-NO_OUT = GC_X.
    WHEN 'LGORT_N'.
      PERFORM SET_FTXT USING '저장위치명'(F20).
      GS_FCAT-NO_OUT = GC_X.
    WHEN 'LIFNR'.
      PERFORM SET_FTXT USING '공급업체'(F05).
    WHEN 'LIFNR_N'.
      PERFORM SET_FTXT USING '업체명'(F06).
    WHEN 'BUDAT'.
      PERFORM SET_FTXT USING '전기일'(F21).
    WHEN 'BLDAT'.
      PERFORM SET_FTXT USING '증빙일'(F22).
    WHEN 'CPUDT'.
      PERFORM SET_FTXT USING '입력일'(F23).
    WHEN 'CPUTM'.
      PERFORM SET_FTXT USING '입력시간'(F24).
    WHEN 'USNAM'.
      PERFORM SET_FTXT USING '담당자'(F25).
    WHEN 'BKTXT'.
      PERFORM SET_FTXT USING '비고'(F26).

    WHEN OTHERS.
      GS_FCAT-NO_OUT = GC_X.
      GS_FCAT-TECH   = GC_X.
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_IORD_FCAT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_IORD_FCAT.

  CASE GS_FCAT-FIELDNAME.
    WHEN 'MJAHR'.
      PERFORM SET_FTXT USING '연도'(F17).
      GS_FCAT-KEY = GC_X.
    WHEN 'MBLNR'.
      PERFORM SET_FTXT USING '자재문서번호'(F18).
      GS_FCAT-KEY = GC_X.
    WHEN 'ZEILE'.
      PERFORM SET_FTXT USING '항번'(F27).
      GS_FCAT-KEY = GC_X.
    WHEN 'MATNR'.
      PERFORM SET_FTXT USING '자재'(F07). "자재코드
    WHEN 'MAKTX'.
      PERFORM SET_FTXT USING '자재명'(F08).
    WHEN 'CHARG'.
      PERFORM SET_FTXT USING '배치'(F09). "배치번호
    WHEN 'MENGE'.
      PERFORM SET_FTXT USING '출고수량'(F28).
    WHEN 'MEINS'.
      PERFORM SET_FTXT USING '단위'(F12).

    WHEN OTHERS.
      GS_FCAT-NO_OUT = GC_X.
      GS_FCAT-TECH   = GC_X.
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_DISP
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PT_FCAT
*&      --> PT_LIST
*&      --> PR_GRID
*&      --> PV_TNME
*&---------------------------------------------------------------------*
FORM SET_DISP TABLES PT_FCAT TYPE LVC_T_FCAT
                     PT_LIST
               USING PR_GRID TYPE REF TO CL_GUI_ALV_GRID
                     PV_TNME.

  CLEAR : GS_VARI.
  CASE PV_TNME+3(1).
    WHEN 'H'.
      GS_VARI-REPORT   = SY-REPID.
      GS_VARI-HANDLE   = SY-DYNNR.
      GS_VARI-USERNAME = SY-UNAME.

  ENDCASE.

  CALL METHOD PR_GRID->SET_TABLE_FOR_FIRST_DISPLAY
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
      IT_TOOLBAR_EXCLUDING = GT_EXCL[]
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
*&      --> GR_HGRID
*&---------------------------------------------------------------------*
FORM REFRESH_GRID USING PR_GRID TYPE REF TO CL_GUI_ALV_GRID.

  DATA : LS_STBL TYPE LVC_S_STBL.


  LS_STBL-ROW = GC_X.
  LS_STBL-COL = GC_X.

  CALL METHOD PR_GRID->SET_FRONTEND_LAYOUT
    EXPORTING
      IS_LAYOUT = GS_LAYO.

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
      PERFORM FREE_CNTR USING GR_HGRID GR_HCNTR.
      PERFORM FREE_CNTR USING GR_IGRID GR_ICNTR.

      CALL METHOD GR_DOCK->FREE.
      CLEAR : GR_DOCK.

    WHEN OTHERS.

  ENDCASE.

  CALL METHOD CL_GUI_CFW=>FLUSH.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form FREE_CNTR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GR_HGRID
*&      --> GR_HCNTR
*&---------------------------------------------------------------------*
FORM FREE_CNTR USING PR_GRID TYPE REF TO CL_GUI_ALV_GRID
                     PR_CNTR TYPE REF TO CL_GUI_CONTAINER.

  CHECK PR_CNTR IS BOUND.

  CALL METHOD PR_GRID->FREE.
  CALL METHOD PR_CNTR->FREE.

  CLEAR : PR_GRID, PR_CNTR.

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

  CHECK P_ORD = GC_X.
  PERFORM REFRESH_GRID USING GR_IGRID.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PRCS_POSR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PRCS_POSR.

  CLEAR : GV_XOSR, GS_XOSR, GV_ERR.

  PERFORM CHECK_POSR.
  CHECK GV_ERR IS INITIAL.

  "환입 버튼 클릭시 환입수량 > 0인 데이터가 존재하면 환입 처리 진행(라인 선택 불필요)

  GV_XOSR       = GC_P.
  GS_XOSR-BUDAT = SY-DATLO.

  PERFORM CALL_SCREEN USING 200 10 5
                                60 8.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_POSR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CHECK_POSR.

  DATA : LT_HORP LIKE GT_HORP OCCURS 0 WITH HEADER LINE.


  IF LINE_EXISTS( GT_HORP[ ERR = GC_X ] ).
    MESSAGE S006 DISPLAY LIKE 'E'. "에러 내역이 존재합니다.
    GV_ERR = GC_X. EXIT.
  ENDIF.

  LT_HORP[] = GT_HORP[].
  DELETE LT_HORP WHERE REQTY <= 0. "IS INITIAL.

  IF LT_HORP[] IS INITIAL.
    MESSAGE S095 DISPLAY LIKE 'E'. "환입 처리 수량이 없습니다.
    GV_ERR = GC_X. EXIT.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PRCS_YPOS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PRCS_YPOS.

  CLEAR : GS_MHDRT, GT_RTN[].

  PERFORM SET_MHDR.
  PERFORM SET_MITM.

  CALL FUNCTION 'BAPI_GOODSMVT_CREATE'
    EXPORTING
      GOODSMVT_HEADER  = GS_MHDR
      GOODSMVT_CODE    = GS_MCOD
    IMPORTING
      GOODSMVT_HEADRET = GS_MHDRT
    TABLES
      GOODSMVT_ITEM    = GT_MITM
      RETURN           = GT_RTN.

  IF GS_MHDRT-MAT_DOC IS NOT INITIAL.
    PERFORM BAPI_COMMIT.

    PERFORM SET_POS_TAG.

    PERFORM PRCS_REFR.
    MESSAGE S096 WITH GS_MHDRT-MAT_DOC. "자재문서 &로 환입되었습니다.
  ELSE.
    PERFORM BAPI_ROLLBACK.

    PERFORM SET_BAPI_ERR_MSG.

    GT_HORP-TYPE    = GC_E.
    GT_HORP-MESSAGE = GT_RTN-MESSAGE.

    MODIFY GT_HORP TRANSPORTING TYPE MESSAGE
                          WHERE REQTY > 0.
  ENDIF.

  GV_REF = GC_X.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_MHDR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_MHDR.

  "Header
  CLEAR : GS_MHDR, GS_MCOD.

  GS_MHDR-PSTNG_DATE = GS_XOSR-BUDAT.
  GS_MHDR-DOC_DATE   = SY-DATLO.
  GS_MHDR-PR_UNAME   = SY-UNAME.
  GS_MHDR-HEADER_TXT = GS_XOSR-REMARK.

  GS_MCOD-GM_CODE    = GC_04.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_MITM
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_MITM.

  "Item
  CLEAR : GT_MITM[].

  LOOP AT GT_HORP WHERE REQTY > 0. "환입수량 > 0
    CLEAR : GT_MITM.

    GT_MITM-MATERIAL  = GT_MITM-MATERIAL_LONG = GT_HORP-MATNR.
    GT_MITM-PLANT     = P_WERKS.
    GT_MITM-STGE_LOC  = P_LGORT.
    GT_MITM-BATCH     = GT_HORP-CHARG.
    GT_MITM-MOVE_TYPE = GC_542. "RE subctrStck toWhse
    GT_MITM-VENDOR    = S_LIFNR-LOW.
    GT_MITM-ENTRY_QNT = GT_HORP-REQTY.
    GT_MITM-ENTRY_UOM = GT_HORP-MEINS.
    GT_MITM-ITEM_TEXT = GT_HORP-TAGNR. "추가(SJM 25.02.27)

    APPEND GT_MITM.
  ENDLOOP.

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
*& Form SET_POS_TAG
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_POS_TAG.

  "꼬리표 로직 추가(SJM 25.02.27)

  GT_TAG[] = VALUE #( FOR LS_MITM IN GT_MITM
                       ( VALUE #( WERKS = LS_MITM-PLANT
                                  TAGNR = LS_MITM-ITEM_TEXT
                                  CHARG = LS_MITM-BATCH
                                  MATNR = LS_MITM-MATERIAL_LONG ) ) ).

  PERFORM GET_TAG.

  CHECK GT_TAG[] IS NOT INITIAL.

  "Update ZPPT0001(꼬리표)
  LOOP AT GT_TAG.
    READ TABLE GT_HORP WITH KEY WERKS = GT_TAG-WERKS
                                MATNR = GT_TAG-MATNR
                                CHARG = GT_TAG-CHARG
                                TAGNR = GT_TAG-TAGNR.

    CHECK SY-SUBRC = 0.

    GV_REQTY = GT_TAG-REMAIN + GT_HORP-REQTY.
    PERFORM UPDATE_ZPPT0001 USING GV_REQTY 'N'.
  ENDLOOP.

  COMMIT WORK.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_TAG
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_TAG.

  "꼬리표 정보 조회

  DELETE GT_TAG WHERE TAGNR IS INITIAL.

  SORT GT_TAG BY WERKS TAGNR CHARG MATNR.
  DELETE ADJACENT DUPLICATES FROM GT_TAG
                        COMPARING WERKS TAGNR CHARG MATNR.

  CHECK GT_TAG[] IS NOT INITIAL.

  SELECT WERKS TAGNR CHARG MATNR REMAIN MEINS
    FROM ZPPT0001
    INTO CORRESPONDING FIELDS OF TABLE GT_TAG
     FOR ALL ENTRIES IN GT_TAG
   WHERE WERKS = GT_TAG-WERKS
     AND TAGNR = GT_TAG-TAGNR
     AND CHARG = GT_TAG-CHARG
     AND MATNR = GT_TAG-MATNR.

  SORT GT_TAG BY WERKS TAGNR CHARG MATNR.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form UPDATE_ZPPT0001
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GV_REQTY
*&      --> P_
*&---------------------------------------------------------------------*
FORM UPDATE_ZPPT0001 USING PV_REQTY
                           PV_GIFLG.

  UPDATE ZPPT0001 SET REMAIN = PV_REQTY
                      GIFLG  = PV_GIFLG
                WHERE WERKS  = GT_TAG-WERKS
                  AND TAGNR  = GT_TAG-TAGNR
                  AND CHARG  = GT_TAG-CHARG
                  AND MATNR  = GT_TAG-MATNR.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_BAPI_ERR_MSG
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_BAPI_ERR_MSG.

  READ TABLE GT_RTN WITH KEY TYPE = GC_E.
  CHECK SY-SUBRC = 0.

  MESSAGE S000 DISPLAY LIKE 'E'
     WITH GT_RTN-MESSAGE+0(50)   GT_RTN-MESSAGE+50(50)
          GT_RTN-MESSAGE+100(50) GT_RTN-MESSAGE+150(50).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CALL_SCREEN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_200
*&      --> P_10
*&      --> P_5
*&      --> P_70
*&      --> P_8
*&---------------------------------------------------------------------*
FORM CALL_SCREEN USING PV_DYNNR
                       PV_SC
                       PV_SL
                       PV_EC
                       PV_EL.

  CALL SCREEN PV_DYNNR STARTING AT PV_SC PV_SL
                         ENDING AT PV_EC PV_EL.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PRCS_COSR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PRCS_COSR.

  CLEAR : GV_XOSR, GS_XOSR, GV_ERR.

  PERFORM CHECK_COSR.
  CHECK GV_ERR IS INITIAL.

  GV_XOSR       = GC_C.
  GS_XOSR-BUDAT = GT_HORD-BUDAT.

  PERFORM CALL_SCREEN USING 200 10 5
                                60 8.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_COSR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CHECK_COSR.

  PERFORM GET_SELECTED_ROWS USING GR_HGRID 'S' 'X'
                                  '취소할 항목을 선택하세요.'(M01).
  CHECK GV_ERR IS INITIAL.

  READ TABLE GT_HORD INDEX GS_ROW-INDEX.
  CHECK SY-SUBRC = 0.

* IF GT_HORD-MBLNR IS INITIAL.
*   MESSAGE S033 DISPLAY LIKE 'E'. "취소할 자재문서가 없습니다.
*   GV_ERR = GC_X. EXIT.
* ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_SELECTED_ROWS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GR_HGRID
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
*& Form PRCS_YCOS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PRCS_YCOS.

  CLEAR : GS_MHDRT, GT_RTN[].

  CALL FUNCTION 'BAPI_GOODSMVT_CANCEL'
    EXPORTING
      MATERIALDOCUMENT    = GT_HORD-MBLNR
      MATDOCUMENTYEAR     = GT_HORD-MJAHR
      GOODSMVT_PSTNG_DATE = GS_XOSR-BUDAT
    IMPORTING
      GOODSMVT_HEADRET    = GS_MHDRT
    TABLES
      RETURN              = GT_RTN.

  IF GS_MHDRT-MAT_DOC IS NOT INITIAL.
    PERFORM BAPI_COMMIT.

    PERFORM SET_COS_TAG.

    PERFORM PRCS_REFR. "Refresh
    MESSAGE S097. "환입 취소했습니다.
  ELSE.
    PERFORM BAPI_ROLLBACK.
    PERFORM SET_BAPI_ERR_MSG.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_COS_TAG
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_COS_TAG.

  DATA : LV_QTY LIKE MATDOC-MENGE,
         LV_GIF.


  "꼬리표 로직 추가(SJM 25.02.27)

  "취소 대상 원본 자재문서 정보 조회
  SELECT WERKS,
         MATNR,
         CHARG,
         SGTXT AS TAGNR,
         MEINS,
         MENGE,
         ERFMG
    FROM MATDOC
    INTO TABLE @DATA(LT_MDOC)
   WHERE MJAHR = @GT_HORD-MJAHR
     AND MBLNR = @GT_HORD-MBLNR
     AND SOBKZ = @GC_O. "Subcontracting Stock

  CHECK LT_MDOC[] IS NOT INITIAL.
  SORT LT_MDOC BY WERKS MATNR CHARG TAGNR.

  GT_TAG[] = CORRESPONDING #( LT_MDOC[] ).
  PERFORM GET_TAG.

  CHECK GT_TAG[] IS NOT INITIAL.

  "Update ZPPT0001(꼬리표)
  LOOP AT GT_TAG.
    READ TABLE LT_MDOC INTO DATA(LS_MDOC)
                       WITH KEY WERKS = GT_TAG-WERKS
                                MATNR = GT_TAG-MATNR
                                CHARG = GT_TAG-CHARG
                                TAGNR = GT_TAG-TAGNR
                                BINARY SEARCH.
    CHECK SY-SUBRC = 0.

    IF GT_TAG-REMAIN > LS_MDOC-MENGE.
      LV_QTY = COND #( WHEN GT_TAG-MEINS = LS_MDOC-MEINS THEN LS_MDOC-MENGE
                                                         ELSE LS_MDOC-ERFMG ).
      GV_REQTY = GT_TAG-REMAIN - LV_QTY.
      LV_GIF   = GC_N.
    ELSE.
      GV_REQTY = SPACE.
      LV_GIF   = GC_Y.
    ENDIF.

    PERFORM UPDATE_ZPPT0001 USING GV_REQTY LV_GIF.
  ENDLOOP.

  COMMIT WORK.

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

  CHECK PV_MODI IS NOT INITIAL.

  GT_MODI = PT_MODI.

  CASE PV_OTEXT.
    WHEN 'GR_HGRID'.
      PERFORM CHNG_FNSH_HGRID.

    WHEN 'GR_IGRID'.

  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHNG_FNSH_HGRID
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CHNG_FNSH_HGRID.

  CASE 'X'.
    WHEN P_ORP.
      PERFORM CHANGE_HORP_DATA.

    WHEN P_ORD.

  ENDCASE.

  GV_REF = GC_X.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHANGE_HORP_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CHANGE_HORP_DATA.

  LOOP AT GT_MODI INTO GS_MODI.
    READ TABLE GT_HORP INDEX GS_MODI-ROW_ID.
    CHECK SY-SUBRC = 0.

    ASSIGN COMPONENT 'COLOR' OF STRUCTURE GT_HORP TO <GFS_COL>.

    CASE GS_MODI-FIELDNAME.
      WHEN 'TAGNR'.
        PERFORM CHANGE_TAGNR.

      WHEN 'REQTY'.
        PERFORM CHANGE_REQTY.

    ENDCASE.

    AT END OF ROW_ID.
      PERFORM RESET_ERR.
    ENDAT.

    MODIFY GT_HORP INDEX GS_MODI-ROW_ID.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHANGE_TAGNR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CHANGE_TAGNR.

  "꼬리표 로직 추가(SJM 25.02.27)

  CHECK GT_HORP-CHARG IS NOT INITIAL.

  SELECT SINGLE TAGNR
    FROM ZPPT0001 INTO @DATA(LV_TAGNR)
   WHERE WERKS = @P_WERKS
     AND TAGNR = @GT_HORP-TAGNR
     AND MATNR = @GT_HORP-MATNR
     AND CHARG = @GT_HORP-CHARG.

  IF SY-SUBRC <> 0.
    MESSAGE S016 WITH '꼬리표'(F32) DISPLAY LIKE 'E'. "&를(을) 확인하세요.

    PERFORM SET_ERR_COL USING 'TAGNR'.
  ELSE.
    PERFORM DEL_ERR_COL USING 'TAGNR'.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHANGE_REQTY
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CHANGE_REQTY.

  "단일 배치 체크로직 추가(SJM 25.03.10)
  IF GT_HORP-XPCBT = GC_X AND GT_HORP-REQTY > 0.
    IF GT_HORP-REQTY <> GT_HORP-LBLAB  "환입수량 <> 가용재고수량
   AND GT_HORP-REQTY  < GT_HORP-LBLAB.
      MESSAGE S120 DISPLAY LIKE 'E'. "단일 배치는 분할 환입 할 수 없습니다.
      CLEAR : GT_HORP-REQTY.
      PERFORM DEL_ERR_COL USING 'REQTY'.
      EXIT.
    ENDIF.
  ENDIF.

  IF GT_HORP-REQTY > 0
 AND GT_HORP-REQTY > GT_HORP-LBLAB. "환입수량 > 가용재고수량
    MESSAGE S098 DISPLAY LIKE 'E'. "가용 재고가 부족합니다.
    DATA(LV_ERR) = GC_X.
  ENDIF.

  IF LV_ERR = GC_X.
    PERFORM SET_ERR_COL USING 'REQTY'.
*   GT_HORP-ERR = GC_X.
  ELSE.
    PERFORM DEL_ERR_COL USING 'REQTY'.
*   CLEAR : <GFS_COL>, GT_HORP-ERR.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_ERR_COL
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&---------------------------------------------------------------------*
FORM SET_ERR_COL USING P_FNM.

  APPEND VALUE #( FNAME     = P_FNM
                  COLOR-COL = GC_6
                  COLOR-INT = GC_0
                  COLOR-INV = GC_0 ) TO <GFS_COL>.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form DEL_ERR_COL
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&---------------------------------------------------------------------*
FORM DEL_ERR_COL USING P_FNM.

  CHECK  <GFS_COL> IS NOT INITIAL.

  DELETE <GFS_COL> WHERE FNAME = P_FNM.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form RESET_ERR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM RESET_ERR.

  IF <GFS_COL> IS NOT INITIAL.
    GT_HORP-ERR = GC_X.
  ELSE.
    GT_HORP-ERR = SPACE.
  ENDIF.

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

  READ TABLE GT_HORP INDEX PS_ROID-ROW_ID.

  CHECK SY-SUBRC = 0.

  CASE PV_FNAME.
    WHEN 'TAGNR'. "추가(SJM 25.02.27)
      PERFORM F4_TAGNR.

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
*& Form F4_TAGNR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F4_TAGNR.

  SELECT DISTINCT TAGNR
    FROM ZPPT0001 INTO TABLE @DATA(LV_TAG)
   WHERE WERKS = @P_WERKS
     AND MATNR = @GT_HORP-MATNR
     AND CHARG = @GT_HORP-CHARG.

  SORT LV_TAG BY TAGNR.

  PERFORM F4IF_TABLE TABLES LV_TAG
                      USING 'TAGNR'
                            'GT_HORP-TAGNR'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form F4IF_TABLE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LV_TAG
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
    WHEN 'GR_HGRID'.
      PERFORM READ_LIST_BY_INDEX USING PS_ROW-INDEX.

      CASE PS_COL-FIELDNAME.
        WHEN 'MBLNR'.
          PERFORM GET_IORD_DATA.
          PERFORM REFRESH_GRID USING GR_IGRID.

      ENDCASE.

    WHEN OTHERS.

  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form READ_LIST_BY_INDEX
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PS_ROW_INDEX
*&---------------------------------------------------------------------*
FORM READ_LIST_BY_INDEX USING PV_INDEX.

  CASE 'X'.
    WHEN P_ORP.

    WHEN P_ORD.
      READ TABLE GT_HORD INDEX PV_INDEX.
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_IORD_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_IORD_DATA.

  CLEAR : GT_IORD[], GV_CNT.

  SELECT * FROM ZGTMM_CV_MVT542_VENDOR
    INTO CORRESPONDING FIELDS OF TABLE @GT_IORD
   WHERE MJAHR = @GT_HORD-MJAHR
     AND MBLNR = @GT_HORD-MBLNR.

  IF GT_IORD[] IS INITIAL.
    MESSAGE S002 DISPLAY LIKE 'E'. "조회된 값이 없습니다.
    EXIT.
  ENDIF.

  SORT GT_IORD BY ZEILE.

  GV_CNT = LINES( GT_IORD ).
  MESSAGE S003 WITH GV_CNT. "& 건의 데이터가 조회되었습니다.

ENDFORM.
