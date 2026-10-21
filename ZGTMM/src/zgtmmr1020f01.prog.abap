*&---------------------------------------------------------------------*
*& INCLUDE          ZGTFIR4003F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& FORM CREATE_ALV
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
FORM CREATE_ALV .

  PERFORM :
            SET_CONTAINER,
            SET_ALV_GRID,
*            SET_TOP_OF_PAGE,
            SET_ALV_FIELDCAT USING ZGTFI_0,
            SET_ALV_LAYOUT,
            SET_ALV_TOOLBAR,
            SET_ALV_SORT,
            SET_EVENT        CHANGING GCL_EVENT GCL_GRID,
            DISPLAY_ALV.

ENDFORM.

*&---------------------------------------------------------------------*
*& FORM SET_CONTAINER
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
FORM SET_CONTAINER .

  IF GCL_DOCKING IS NOT BOUND.

    CREATE OBJECT GCL_DOCKING
      EXPORTING
        REPID     = SY-REPID
        DYNNR   = SY-DYNNR
        SIDE       = CL_GUI_DOCKING_CONTAINER=>DOCK_AT_LEFT
        EXTENSION = 2500.

*    " CREATE SPLITTER
*    CREATE OBJECT GCL_SPLIT
*      EXPORTING
*        PARENT    = GCL_DOCKING
*        ROWS       = 2
*        COLUMNS = 1.
*
*    GCL_SPLIT->SET_ROW_HEIGHT( ID = 1 HEIGHT = 10 ). "위아래 넓이..
*    GCL_SPLIT->SET_BORDER( BORDER = ZGTFI_X ). "테두리...
*    GCL_SPLIT->GET_CONTAINER( : EXPORTING ROW      = 1
*                                         COLUMN    = 1
*                               RECEIVING CONTAINER = GCL_CON_TOP ),
*
*                               EXPORTING ROW       = 2
*                                         COLUMN    = 1
*                               RECEIVING CONTAINER = GCL_CON_BODY ).

  ENDIF.

*  IF GCL_CL_DD IS NOT BOUND.
*    CREATE OBJECT GCL_CL_DD
*      EXPORTING
*        STYLE = 'ALV_GRID'.
*  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*& FORM SET_ALV_GRID
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
FORM SET_ALV_GRID .

  IF GCL_GRID IS NOT BOUND.
    CREATE OBJECT GCL_GRID
      EXPORTING
        I_PARENT          = GCL_DOCKING "GCL_CON_BODY
      EXCEPTIONS
        ERROR_CNTL_CREATE = 1
        ERROR_CNTL_INIT   = 2
        ERROR_CNTL_LINK   = 3
        ERROR_DP_CREATE   = 4
        OTHERS            = 5.

    IF SY-SUBRC <> 0.
      "COULD NOT CREATE ALV GRID (SY-SUBRC = &)
      MESSAGE E725(BT) WITH SY-SUBRC.
    ENDIF.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*& FORM ADJUST_FLDCATS
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
FORM ADJUST_FLDCATS  TABLES PT_FCAT TYPE LVC_T_FCAT.

  DEFINE _FCAT.
    <FS_S_FCT>-SCRTEXT_S  =
    <FS_S_FCT>-SCRTEXT_M  =
    <FS_S_FCT>-SCRTEXT_L  =
    <FS_S_FCT>-COLTEXT    =
    <FS_S_FCT>-REPTEXT    = &1.
  END-OF-DEFINITION.

  DATA LV_COL TYPE I.
  CLEAR : GT_FCAT[].

  LOOP AT PT_FCAT ASSIGNING FIELD-SYMBOL(<FS_S_FCT>).
    CLEAR : <FS_S_FCT>-COL_POS.

    CASE <FS_S_FCT>-FIELDNAME.
      WHEN 'STATUS'.    "상태
        _FCAT TEXT-F01.
*        <FS_S_FCT>-KEY = ABAP_TRUE.

      WHEN 'WERKS'.     " 플랜트
        _FCAT TEXT-F02.
*        <FS_S_FCT>-KEY = ABAP_TRUE.

      WHEN 'NAME1'.  "플랜트명
        _FCAT TEXT-F03.
*        <FS_S_FCT>-KEY = ABAP_TRUE.

      WHEN 'MTART'.       "자재유형
        _FCAT TEXT-F04.
*        <FS_S_FCT>-KEY = ABAP_TRUE.

      WHEN 'MTBEZ'.      "자재유형명
        _FCAT TEXT-F05.

      WHEN 'MATNR'.      "자재코드
        _FCAT TEXT-F06.
*        <FS_S_FCT>-HOTSPOT = ABAP_TRUE.

      WHEN 'MAKTX'.      "자재명
        _FCAT TEXT-F07.

      WHEN 'EKGRP'.      "구매그룹
       IF  P_PUR = 'X'.  "구매 정보
        _FCAT TEXT-F08.
        <FS_S_FCT>-EDIT = ZGTFI_X.
        <FS_S_FCT>-F4AVAILABL = ZGTFI_X.
        <FS_S_FCT>-REF_TABLE = 'MARC'.
        <FS_S_FCT>-REF_FIELD  = 'EKGRP'.
       ELSE.
         <FS_S_FCT>-NO_OUT = ZGTFI_X.
       ENDIF.

      WHEN 'EKNAM'.     "구매그룹명
       IF  P_PUR = 'X'.
        _FCAT TEXT-F09.
       ELSE.
         <FS_S_FCT>-NO_OUT = ZGTFI_X.
       ENDIF.

      WHEN 'EKWSL'.      "구매값키
       IF  P_PUR = 'X'.
        _FCAT TEXT-F10.
        <FS_S_FCT>-EDIT = ZGTFI_X.
        <FS_S_FCT>-F4AVAILABL = ZGTFI_X.
        <FS_S_FCT>-REF_TABLE = 'MARA'.
        <FS_S_FCT>-REF_FIELD  = 'EKWSL'.
       ELSE.
         <FS_S_FCT>-NO_OUT = ZGTFI_X.
       ENDIF.

      WHEN 'WEBAZ'.      "입고처리시간
       IF  P_PUR = 'X'.
        _FCAT TEXT-F11.
       ELSE.
         <FS_S_FCT>-NO_OUT = ZGTFI_X.
       ENDIF.

      WHEN 'KORDB'.     "공급처리스트사용
       IF  P_PUR = 'X'.
        _FCAT TEXT-F12.
        <FS_S_FCT>-CHECKBOX = ZGTFI_X.
        <FS_S_FCT>-EDIT            = ZGTFI_X.
       ELSE.
         <FS_S_FCT>-NO_OUT = ZGTFI_X.
       ENDIF.


      WHEN 'INSMK'.     "검사재고로 전기
       IF  P_QUL = 'X'. "품질 정보
        _FCAT TEXT-F22.
        <FS_S_FCT>-CHECKBOX = ZGTFI_X.
        <FS_S_FCT>-EDIT            = ZGTFI_X.
       ELSE.
         <FS_S_FCT>-NO_OUT = ZGTFI_X.
       ENDIF.

      WHEN 'DISMM'.     "MRP유형
       IF  P_ROP = 'X'. "ROP 정보
        _FCAT TEXT-F14.
        <FS_S_FCT>-EDIT = ZGTFI_X.
        <FS_S_FCT>-F4AVAILABL = ZGTFI_X.
        <FS_S_FCT>-REF_TABLE = 'MARC'.
        <FS_S_FCT>-REF_FIELD  = 'DISMM'.
        <FS_S_FCT>-CHECKTABLE = '!'.
       ELSE.
         <FS_S_FCT>-NO_OUT = ZGTFI_X.
       ENDIF.

      WHEN 'DIBEZ'.     "MRP유형명
       IF  P_ROP = 'X'. "
        _FCAT TEXT-F15.
       ELSE.
         <FS_S_FCT>-NO_OUT = ZGTFI_X.
       ENDIF.

      WHEN 'LGFSB'.     "입고저장위치
       IF  P_ROP = 'X'. "
        _FCAT TEXT-F23.
        <FS_S_FCT>-EDIT = ZGTFI_X.
        <FS_S_FCT>-F4AVAILABL = ZGTFI_X.
       ELSE.
         <FS_S_FCT>-NO_OUT = ZGTFI_X.
       ENDIF.

      WHEN 'LGOBE'.     "입고저장위치명
       IF  P_ROP = 'X'. "
        _FCAT TEXT-F24.
       ELSE.
         <FS_S_FCT>-NO_OUT = ZGTFI_X.
       ENDIF.

      WHEN 'MINBE'.     "재발주점
       IF  P_ROP = 'X'. "
        _FCAT TEXT-F16.
       ELSE.
         <FS_S_FCT>-NO_OUT = ZGTFI_X.
       ENDIF.

      WHEN 'DISLS'.     "Lot Size전략
       IF  P_ROP = 'X'. "
        _FCAT TEXT-F17.
        <FS_S_FCT>-EDIT = ZGTFI_X.
        <FS_S_FCT>-F4AVAILABL = ZGTFI_X.
        <FS_S_FCT>-REF_TABLE = 'MARC'.
        <FS_S_FCT>-REF_FIELD  = 'DISLS'.
       ELSE.
         <FS_S_FCT>-NO_OUT = ZGTFI_X.
       ENDIF.

      WHEN 'LOSLT'.     "Lot Size전략명
       IF  P_ROP = 'X'. "
        _FCAT TEXT-F18.
       ELSE.
         <FS_S_FCT>-NO_OUT = ZGTFI_X.
       ENDIF.

      WHEN 'DISPO'.     "MRP 관리자
       IF  P_ROP = 'X'. "MRP 관리자
        _FCAT 'MRP 관리자'.
        <FS_S_FCT>-EDIT = ZGTFI_X.
        <FS_S_FCT>-F4AVAILABL = ZGTFI_X.
        <FS_S_FCT>-REF_TABLE = 'MARC'.
        <FS_S_FCT>-REF_FIELD  = 'DISPO'.
        <FS_S_FCT>-CHECKTABLE = '!'.
       ELSE.
         <FS_S_FCT>-NO_OUT = ZGTFI_X.
       ENDIF.

      WHEN 'DSNAM'.     "MRP 관리자명
       IF  P_ROP = 'X'.
        _FCAT 'MRP 관리자명'.
       ELSE.
         <FS_S_FCT>-NO_OUT = ZGTFI_X.
       ENDIF.


      WHEN 'BSTFE'.     "고정 Lot Size
       IF  P_ROP = 'X'. "
        _FCAT TEXT-F19.
       ELSE.
         <FS_S_FCT>-NO_OUT = ZGTFI_X.
       ENDIF.

      WHEN 'PLIFZ'.     "계획납품소요일
       IF  P_ROP = 'X'.
        _FCAT TEXT-F20.
       ELSE.
         <FS_S_FCT>-NO_OUT = ZGTFI_X.
       ENDIF.

      WHEN 'EISBE'.     "안전재고수량
       IF  P_ROP = 'X'. "
        _FCAT TEXT-F21.     "
        <FS_S_FCT>-QFIELDNAME = 'MEINS'.
       ELSE.
         <FS_S_FCT>-NO_OUT = ZGTFI_X.
       ENDIF.

      WHEN 'SBDKZ'.     "소요량지시자
       IF  P_ROP = 'X'. "
        _FCAT TEXT-F25.
        <FS_S_FCT>-EDIT = ZGTFI_X.
        <FS_S_FCT>-F4AVAILABL = ZGTFI_X.
        <FS_S_FCT>-REF_TABLE = 'MARC'.
        <FS_S_FCT>-REF_FIELD  = 'SBDKZ'.
       ELSE.
         <FS_S_FCT>-NO_OUT = ZGTFI_X.
       ENDIF.

      WHEN 'MESSAGE'.
        _FCAT TEXT-F13.

      WHEN OTHERS.
        <FS_S_FCT>-NO_OUT = ZGTFI_X.
    ENDCASE.

    APPEND <FS_S_FCT> TO GT_FCAT.
  ENDLOOP.

ENDFORM.

*&---------------------------------------------------------------------*
*& FORM SET_ALV_LAYOUT
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
FORM SET_ALV_LAYOUT.

  CLEAR : GV_CNT, GS_LAYOUT.
  DESCRIBE TABLE GT_LIST LINES GV_CNT.

  GS_LAYOUT = VALUE #(
                       NO_ROWINS  = ZGTFI_X
                       ZEBRA  = ZGTFI_X
                       SEL_MODE   = ZGTFI_A
                       CWIDTH_OPT  = ZGTFI_A
                       STYLEFNAME = 'STYLE'
                       SMALLTITLE = ZGTFI_X
                       GRID_TITLE = TEXT-T04 && GV_CNT
  ).

ENDFORM.

*&---------------------------------------------------------------------*
*& FORM SET_ALV_TOOLBAR
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
FORM SET_ALV_TOOLBAR.

  REFRESH GT_EXCLUD.

  GT_EXCLUD[] = VALUE #(
*                         ( CL_GUI_ALV_GRID=>MC_MB_VIEW              )
                         ( CL_GUI_ALV_GRID=>MC_FC_LOC_UNDO          )
                         ( CL_GUI_ALV_GRID=>MC_FC_AUF               )
                         ( CL_GUI_ALV_GRID=>MC_FC_DETAIL            )
                         ( CL_GUI_ALV_GRID=>MC_FC_GRAPH             )
                         ( CL_GUI_ALV_GRID=>MC_FC_INFO              )
                         ( CL_GUI_ALV_GRID=>MC_FC_LOC_COPY          )
                         ( CL_GUI_ALV_GRID=>MC_FC_LOC_COPY_ROW      )
                         ( CL_GUI_ALV_GRID=>MC_FC_LOC_CUT           )
                         ( CL_GUI_ALV_GRID=>MC_FC_LOC_DELETE_ROW    )
                         ( CL_GUI_ALV_GRID=>MC_FC_LOC_INSERT_ROW    )
                         ( CL_GUI_ALV_GRID=>MC_FC_LOC_MOVE_ROW      )
                         ( CL_GUI_ALV_GRID=>MC_FC_LOC_APPEND_ROW    )
                         ( CL_GUI_ALV_GRID=>MC_FC_LOC_PASTE         )
                         ( CL_GUI_ALV_GRID=>MC_FC_LOC_PASTE_NEW_ROW )
*                         ( CL_GUI_ALV_GRID=>MC_FC_PRINT             )
                         ( CL_GUI_ALV_GRID=>MC_FC_REFRESH           )
                         ).

ENDFORM.
*&---------------------------------------------------------------------*
*& FORM SET_ALV_SORT
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
FORM SET_ALV_SORT.

*  GT_SORT[] = VALUE LVC_T_SORT(
*    ( SPOS = '1' FIELDNAME = 'WERKS'       UP = ZGTFI_X )
*    ( SPOS = '2' FIELDNAME = 'WERKS_TX' UP = ZGTFI_X SUBTOT = ZGTFI_X )
*    ( SPOS = '3' FIELDNAME = 'MTART'    UP = ZGTFI_X )
*    ( SPOS = '4' FIELDNAME = 'MATNR'    UP = ZGTFI_X )
*                                ).

ENDFORM.
*&---------------------------------------------------------------------*
*& FORM SET_EVENT
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
FORM SET_EVENT  CHANGING PO_EVENT TYPE REF TO LCL_EVT_RECEIVER
                                               PCL_GRID  TYPE REF TO CL_GUI_ALV_GRID.

  PCL_GRID->REGISTER_EDIT_EVENT( CL_GUI_ALV_GRID=>MC_EVT_MODIFIED ).
  PCL_GRID->REGISTER_EDIT_EVENT( CL_GUI_ALV_GRID=>MC_EVT_ENTER ).

  PERFORM SET_CELL_STYLE.

  CREATE OBJECT PO_EVENT.

  SET HANDLER :
  PO_EVENT->HANDLE_DATA_CHANGED                 FOR PCL_GRID,
  PO_EVENT->HANDLE_DATA_CHANGED_FINISHED  FOR PCL_GRID,
  PO_EVENT->HANDLE_HOTSPOT_CLICK                FOR PCL_GRID,
  PO_EVENT->HANDLE_ON_F4                               FOR PCL_GRID.

*" F4 필드 등록
*  DATA: LT_F4 TYPE LVC_T_F4,
*            LS_F4 TYPE LVC_S_F4.
*
*  LS_F4-FIELDNAME  = 'LGFSB'.
*  LS_F4-REGISTER    = 'X'.
*  APPEND LS_F4 TO LT_F4.
*
*  CLEAR LS_F4.
*  LS_F4-FIELDNAME  = 'DISPO'.
*  LS_F4-REGISTER    = 'X'.
*  APPEND LS_F4 TO LT_F4.
*
*  PCL_GRID->REGISTER_F4_FOR_FIELDS( IT_F4 = LT_F4 ).


ENDFORM.

*&---------------------------------------------------------------------*
*& FORM DISPLAY_ALV
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
FORM DISPLAY_ALV .

  DATA(LS_VARINT) = VALUE DISVARIANT( REPORT  = SY-CPROG
                                           HANDLE  = '0001' ).

  " 4. F4 대상 필드 등록
  DATA: LT_F4 TYPE LVC_T_F4.
  LT_F4 = VALUE #(
               ( FIELDNAME = 'LGFSB' REGISTER   = 'X' )
               ( FIELDNAME = 'DISPO' REGISTER   = 'X' ) ).

  CALL METHOD GCL_GRID->REGISTER_F4_FOR_FIELDS
    EXPORTING
      IT_F4 = LT_F4.

  CALL METHOD GCL_GRID->SET_TABLE_FOR_FIRST_DISPLAY
    EXPORTING
      IS_LAYOUT                      = GS_LAYOUT
      IT_TOOLBAR_EXCLUDING = GT_EXCLUD[]
      IS_VARIANT                      = LS_VARINT
      I_SAVE                             = ZGTFI_A
    CHANGING
      IT_OUTTAB                       = GT_LIST[]
      IT_FIELDCATALOG             = GT_FCAT[]
      IT_SORT                            = GT_SORT[]
    EXCEPTIONS
      OTHERS                            = 4.

  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
          WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*& FORM RELEASE_ALV
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
FORM RELEASE_ALV .

  IF GCL_GRID IS BOUND.
    GCL_GRID->FREE( ).
    CLEAR GCL_GRID.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*& FORM INITIALIZATION
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
FORM INITIALIZATION .

DATA: lt_values TYPE TABLE OF USVALUES,
      ls_values TYPE USVALUES.

    CALL FUNCTION 'SUSR_USER_AUTH_FOR_OBJ_GET'
      EXPORTING
        MANDANT = SY-MANDT
        SEL_OBJECT     = 'ZCBO_MM001' " 조회할 권한 오브젝트명
        user_name         = sy-uname
      TABLES
        values          = lt_values
      EXCEPTIONS
        user_name_invalid = 1
        object_not_found  = 2
        internal_error    = 3
        OTHERS            = 4.

      DELETE  LT_VALUES WHERE VON = '*'.

    IF LT_VALUES[] IS NOT INITIAL.
      READ TABLE LT_VALUES INTO LS_VALUES WITH KEY FIELD = 'WERKS' .
      IF SY-SUBRC EQ 0 and  P_WERKS = LS_VALUES-VON. ENDIF.

    ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*& FORM INPUT_VALIDATION
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
FORM INPUT_VALIDATION.

  CLEAR : GT_LIST, GV_ERR.

  IF P_WERKS IS INITIAL.
    MESSAGE S008 WITH TEXT-T11 DISPLAY LIKE ZGTFI_E.
    GV_ERR = ZGTFI_X. STOP. "필수 값이 누락되었습니다. &
  ENDIF.

  SELECT SINGLE 1
    FROM T001W
    WHERE WERKS = @P_WERKS
    INTO @DATA(LV_EXST).

  IF SY-SUBRC <> 0.
    MESSAGE S000 WITH TEXT-M01 DISPLAY LIKE ZGTFI_E.
    GV_ERR = ZGTFI_X. STOP. "유효하지 않은 플랜트 입니다.
  ENDIF.

  IF  S_MTART-LOW IS NOT INITIAL.
    LOOP AT S_MTART INTO DATA(LS_MTART).

     SELECT SINGLE 1"MTART
      FROM V_MARA_MAKT
      WHERE MTART EQ @LS_MTART-LOW
       INTO @LV_EXST.

      IF SY-SUBRC <> 0.
        MESSAGE S000 WITH TEXT-M02 DISPLAY LIKE ZGTFI_E.
        GV_ERR = ZGTFI_X. STOP. "유효하지 않은 자재유형 입니다.
      ENDIF.

     ENDLOOP.
  ENDIF.

  IF S_MATNR[] IS NOT INITIAL.
    LOOP AT S_MATNR INTO DATA(LS_LOW).

      SELECT SINGLE 1
      FROM V_MARA_MAKT
      WHERE MATNR EQ @LS_LOW-LOW
      INTO @LV_EXST.

      IF SY-SUBRC <> 0.
        MESSAGE S000 WITH TEXT-M03 DISPLAY LIKE ZGTFI_E.
        GV_ERR = ZGTFI_X. STOP. "유효하지 않은 자재코드 입니다.
      ENDIF.
    ENDLOOP.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*& FORM CHECK_AUTH
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
FORM CHECK_AUTH .

  AUTHORITY-CHECK OBJECT 'ZCBO_MM001'
               ID 'WERKS' FIELD P_WERKS.

  CHECK SY-SUBRC <> 0.

  SET CURSOR FIELD 'P_WERKS'.
  MESSAGE E106 WITH P_WERKS. "플랜트 [&] 작업권한을 확인하세요.

ENDFORM.
*&---------------------------------------------------------------------*
*& FORM SELECTION_SCREEN_OUTPUT
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
FORM SELECTION_SCREEN_OUTPUT .

*  LOOP AT SCREEN.
*    IF R_1_2 IS INITIAL AND SCREEN-GROUP1 = 001.
*      SCREEN-ACTIVE = 0.
*    ENDIF.
*    MODIFY SCREEN.
*  ENDLOOP.

ENDFORM.

*&---------------------------------------------------------------------*
*& FORM GET_DATA
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
FORM GET_DATA .

 DATA LV_PSTAT TYPE PSTAT_D.
 CLEAR : GV_ERR, GT_LIST, GT_T001L.

*플랜트 기준 저장위치 정보 미리 담아두기.
 SELECT FROM T001L
   FIELDS *
   WHERE WERKS = @P_WERKS
   INTO CORRESPONDING FIELDS OF TABLE @GT_T001L.

*플랜트 기준 저장위치 정보 미리 담아두기.
 SELECT FROM T024D
   FIELDS WERKS, DISPO, DSNAM
   WHERE WERKS = @P_WERKS
   INTO CORRESPONDING FIELDS OF TABLE @GT_T024D.

*ROP정보는 STAT''D'인 정보 /구매나 품질정보의 경우, 'E'인 정보
 LV_PSTAT = COND #( WHEN P_ROP = ZGTFI_X THEN 'D' ELSE 'E' ).

 SELECT FROM ZGTMM_CV_PUR_MARC
   FIELDS *
   WHERE WERKS EQ @P_WERKS
        AND MTART IN  @S_MTART
        AND MATNR IN  @S_MATNR
        AND STAT   EQ @LV_PSTAT
       INTO CORRESPONDING FIELDS OF TABLE @GT_LIST.

   IF GT_LIST[] IS INITIAL.
     GV_ERR = ZGTFI_X. "조회 조건에 일치하는 정보가 없습니다.
     MESSAGE S000 WITH TEXT-E01. EXIT.
   ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*&      FORM  POPUP_TO_CONFIRM_STEP
*&---------------------------------------------------------------------*
*       TEXT
*----------------------------------------------------------------------*
FORM POPUP_TO_CONFIRM_STEP  USING PV_OPT
                                                                PV_TEXT1
                                                                PV_TEXT2
                                                                PV_TITLE.
  CLEAR GV_ANSWER.
  CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
    EXPORTING
      DEFAULTOPTION   = PV_OPT
      TEXTLINE1            = PV_TEXT1
      TEXTLINE2            = PV_TEXT2
      TITEL                    = PV_TITLE
      CANCEL_DISPLAY  = ''
    IMPORTING
      ANSWER               = GV_ANSWER.

ENDFORM.                    " POPUP_TO_CONFIRM_STEP

*&---------------------------------------------------------------------*
*& FORM REFRESH_TABLE
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
FORM REFRESH_TABLE USING PO_GRID TYPE REF TO CL_GUI_ALV_GRID
                                               PV_SOFT_REFRESH.

  DATA : LS_STABLE TYPE LVC_S_STBL.

  LS_STABLE-ROW = ABAP_TRUE.
  LS_STABLE-COL = ABAP_TRUE.

  CALL METHOD PO_GRID->REFRESH_TABLE_DISPLAY
    EXPORTING
      IS_STABLE           = LS_STABLE
*      I_SOFT_REFRESH = PV_SOFT_REFRESH
    EXCEPTIONS
      FINISHED       = 1
      OTHERS        = 2.

ENDFORM.

*&---------------------------------------------------------------------*
*& FORM DATA_CHANGED_FINISHED
*&---------------------------------------------------------------------*
*& TEXT4
*&---------------------------------------------------------------------*
FORM DATA_CHANGED_FINISHED  USING    PV_MODIFIED TYPE CHAR01
                                     PT_MOD_CELLS TYPE LVC_T_MODI
                                     PO_SENDER.
*  DATA : LV_FD   TYPE LVC_FNAME.
*
*  CHECK PV_MODIFIED IS NOT INITIAL.
*
*  CASE PO_SENDER.
*    WHEN GCL_GRID.
*
*      LOOP AT PT_MOD_CELLS INTO DATA(LS_MOD_CELLS).
*
*        READ TABLE GT_LIST ASSIGNING FIELD-SYMBOL(<FS>) INDEX LS_MOD_CELLS-ROW_ID.
*
*        CASE LS_MOD_CELLS-FIELDNAME.
*          WHEN 'EKGRP'.
*
*            SELECT SINGLE EKNAM
*             FROM T024
*             WHERE EKGRP = @LS_MOD_CELLS-VALUE
*                 INTO @DATA(LV_EKNAM).
*
*             IF LV_EKNAM IS  INITIAL.
*                 <FS>-STATUS = ICON_LED_RED.
*                  LV_FD = 'EKGRP'.
*             ELSE.
*                 <FS>-EKGRP  = LS_MOD_CELLS-VALUE.
*                 <FS>-EKNAM  = LV_EKNAM.
*                 <FS>-STATUS = ICON_CHANGE.
*             ENDIF.
*
*          WHEN 'DISMM'.
*
*          WHEN 'LGFSB'. "입고저장위치
*
*          SELECT SINGLE LGOBE
*             FROM T001L
*             WHERE WERKS = @P_WERKS
*                  AND LGORT = @LS_MOD_CELLS-VALUE
*                 INTO @DATA(LV_LGOBE).
*
*             IF LV_LGOBE IS  INITIAL.
*                 <FS>-STATUS = ICON_LED_RED.
*                  LV_FD = 'LGFSB'.
*             ELSE.
*                 <FS>-LGFSB  = LS_MOD_CELLS-VALUE.
*                 <FS>-LGOBE  = LV_LGOBE.
*                 <FS>-STATUS = ICON_CHANGE.
*             ENDIF.
*
*        ENDCASE.
*      ENDLOOP.
*
*    WHEN OTHERS.
*  ENDCASE.
*
*
*  PERFORM REFRESH_TABLE USING PO_SENDER SPACE.
*
*  CALL METHOD CL_GUI_CFW=>SET_NEW_OK_CODE
*    EXPORTING
*      NEW_CODE = 'ENTER'.


ENDFORM.

*&---------------------------------------------------------------------*
*& FORM SET_CELL_STYLE
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
FORM SET_CELL_STYLE .

  DATA : LS_STYLE TYPE LVC_S_STYL.

  DEFINE _SET_STYLE.

    LS_STYLE-FIELDNAME = &2.
    CASE &1.
      WHEN 'E'.
        LS_STYLE-STYLE = CL_GUI_ALV_GRID=>MC_STYLE_ENABLED.
      WHEN 'D'.
        LS_STYLE-STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED.
    ENDCASE.
    INSERT LS_STYLE INTO TABLE &3.

  END-OF-DEFINITION.


    IF GV_EDIT IS INITIAL.
       GCL_GRID->SET_READY_FOR_INPUT( 0 ).
    ELSE.
       GCL_GRID->SET_READY_FOR_INPUT( 1 ). "입력가능
    ENDIF.

    LOOP AT GT_LIST ASSIGNING FIELD-SYMBOL(<LS_LIST>).
      CLEAR : <LS_LIST>-STYLE[].

     CASE ZGTFI_X.
     	WHEN P_PUR. "구매 정보

        IF GV_EDIT = ZGTFI_X. "변경
         _SET_STYLE : ZGTFI_E 'EKGRP' <LS_LIST>-STYLE,"ENABLED
                               ZGTFI_E 'EKWSL' <LS_LIST>-STYLE,
                               ZGTFI_E 'WEBAZ' <LS_LIST>-STYLE,
                               ZGTFI_E 'KORDB' <LS_LIST>-STYLE.
        ELSE."조회
          CLEAR : <LS_LIST>-STATUS, <LS_LIST>-MESSAGE.
         _SET_STYLE : ZGTFI_D 'EKGRP' <LS_LIST>-STYLE, "DISABLED
                               ZGTFI_D 'EKWSL' <LS_LIST>-STYLE,
                               ZGTFI_D 'WEBAZ' <LS_LIST>-STYLE,
                               ZGTFI_D 'KORDB' <LS_LIST>-STYLE.
        ENDIF.

     	WHEN P_ROP.  "ROP정보

         IF GV_EDIT = ZGTFI_X.
          _SET_STYLE : ZGTFI_E 'DISLS'  <LS_LIST>-STYLE,
                                ZGTFI_E 'DISMM' <LS_LIST>-STYLE,
                                ZGTFI_E 'LGFSB' <LS_LIST>-STYLE,
                                ZGTFI_E 'BSTFE' <LS_LIST>-STYLE,
                                ZGTFI_E 'PLIFZ'  <LS_LIST>-STYLE,
                                ZGTFI_E 'MINBE'  <LS_LIST>-STYLE,
                                ZGTFI_E 'DISPO'  <LS_LIST>-STYLE,
                                ZGTFI_E 'EISBE'  <LS_LIST>-STYLE.
         ELSE.
          CLEAR : <LS_LIST>-STATUS, <LS_LIST>-MESSAGE.
          _SET_STYLE : ZGTFI_D 'DISLS'  <LS_LIST>-STYLE,
                                ZGTFI_D 'DISMM' <LS_LIST>-STYLE,
                                ZGTFI_D 'LGFSB' <LS_LIST>-STYLE,
                                ZGTFI_D 'BSTFE' <LS_LIST>-STYLE,
                                ZGTFI_D 'PLIFZ'  <LS_LIST>-STYLE,
                                ZGTFI_D 'MINBE'  <LS_LIST>-STYLE,
                                ZGTFI_D 'DISPO'  <LS_LIST>-STYLE,
                                ZGTFI_D 'EISBE'  <LS_LIST>-STYLE.
         ENDIF.

      WHEN OTHERS.  "품질 정보

        IF GV_EDIT = ZGTFI_X.
           _SET_STYLE : ZGTFI_E 'INSMK' <LS_LIST>-STYLE.
        ELSE.
           CLEAR : <LS_LIST>-STATUS, <LS_LIST>-MESSAGE.
           _SET_STYLE : ZGTFI_D 'INSMK' <LS_LIST>-STYLE.
        ENDIF.
    ENDCASE.

    ENDLOOP.

ENDFORM.

*&---------------------------------------------------------------------*
*& FORM SET_ALV_FIELDCAT
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
FORM SET_ALV_FIELDCAT  USING PV_GUBUN TYPE CHAR1.

  DATA :
         LR_TABDESCR TYPE REF TO CL_ABAP_STRUCTDESCR,
         LT_DFIES         TYPE DDFIELDS,
         LS_DFIES         TYPE DFIES,
         LT_FCAT          TYPE LVC_T_FCAT,
         LS_FCAT          TYPE LVC_S_FCAT.

  DATA : GR_DREF  TYPE REF TO DATA.

  CLEAR GR_DREF.
  CASE PV_GUBUN.
    WHEN ZGTFI_0.
      CREATE DATA GR_DREF LIKE GS_LIST.

    WHEN OTHERS.
  ENDCASE.

  LR_TABDESCR ?= CL_ABAP_STRUCTDESCR=>DESCRIBE_BY_DATA_REF( GR_DREF ).
  LT_DFIES = CL_SALV_DATA_DESCR=>READ_STRUCTDESCR( LR_TABDESCR ) .

  REFRESH : LT_FCAT.

  LOOP AT LT_DFIES INTO LS_DFIES.
    CLEAR : LS_FCAT.
    MOVE-CORRESPONDING LS_DFIES TO LS_FCAT.
    APPEND LS_FCAT TO LT_FCAT.
  ENDLOOP.

  " 필드 카탈로그 변경사항 적용
  CASE PV_GUBUN.
    WHEN ZGTFI_0.
      PERFORM ADJUST_FLDCATS TABLES LT_FCAT.

     WHEN OTHERS.
  ENDCASE.
ENDFORM.

*&---------------------------------------------------------------------*
*& FORM SET_TOP_OF_PAGE
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
FORM SET_TOP_OF_PAGE .

*  DATA :
*         LV_TXT   TYPE C LENGTH 10,
*         LV_TXT2  TYPE C LENGTH 10,
*         LV_FROM TYPE C LENGTH 5,
*         LV_TO      TYPE C LENGTH 5.
*
*
*  CALL METHOD GCL_CL_DD->INITIALIZE_DOCUMENT
*    EXPORTING
*      BACKGROUND_COLOR = CL_DD_AREA=>COL_TEXTAREA.

  " ADD TEXT
*  GCL_CL_DD->ADD_TEXT( TEXT = |플랜트　:　{ P_WERKS }({ GV_LINE })|
*                       SAP_EMPHASIS = CL_DD_AREA=>HEADING ).

*  IF S_BUDAT[] IS NOT INITIAL.
*    READ TABLE S_BUDAT INDEX 1.
*    WRITE S_BUDAT-LOW TO LV_TXT.
*    WRITE S_BUDAT-HIGH TO LV_TXT2.
*
*    " ADD NEW-LINE
*    GCL_CL_DD->NEW_LINE( ).
*    " ADD TEXT
*    IF S_BUDAT-HIGH IS INITIAL.
*      GCL_CL_DD->ADD_TEXT( TEXT = |입금일자　:　{ LV_TXT }|
*                           SAP_EMPHASIS = CL_DD_AREA=>HEADING ).
*    ELSE.
*      GCL_CL_DD->ADD_TEXT( TEXT = |입금일자　:　{ LV_TXT } ~ { LV_TXT2 }|
*                           SAP_EMPHASIS = CL_DD_AREA=>HEADING ).
*    ENDIF.
*  ENDIF.

*  GCL_CL_DD->DISPLAY_DOCUMENT( EXPORTING  REUSE_CONTROL = ZGTFI_X
*                                          PARENT        = GCL_CON_TOP
*                               EXCEPTIONS HTML_DISPLAY_ERROR = 1 ).


ENDFORM.

*&---------------------------------------------------------------------*
*& FORM DATA_CHANGED
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
FORM DATA_CHANGED  USING  PO_DATA_CHANGED
                                     TYPE REF TO CL_ALV_CHANGED_DATA_PROTOCOL
                                                PO_SENDER.

  CASE PO_SENDER.

    WHEN GCL_GRID.
      PERFORM DATA_CHANGED_1 USING PO_DATA_CHANGED.

    WHEN OTHERS.
      EXIT.
  ENDCASE.

ENDFORM.

*&---------------------------------------------------------------------*
*&      FORM  DATA_CHANGED_1
*&---------------------------------------------------------------------*
*       TEXT
*----------------------------------------------------------------------*
*      -->P_PO_DATA_CHANGED  TEXT
*----------------------------------------------------------------------*
FORM DATA_CHANGED_1 USING PO_DATA_CHANGED
                                       TYPE REF TO CL_ALV_CHANGED_DATA_PROTOCOL.

  DATA : LV_ERR TYPE CHAR1.
  DATA : LV_FD   TYPE LVC_FNAME,
             LV_EKGRP TYPE EKGRP,
             LV_DISMM  TYPE DISMM,
             LV_DISPO TYPE DISPO,
             LV_LGORT TYPE LGORT_D,
             LV_DISLS  TYPE DISLS.

  LOOP AT PO_DATA_CHANGED->MT_MOD_CELLS INTO DATA(LS_MOD_CELLS).

    READ TABLE GT_LIST ASSIGNING FIELD-SYMBOL(<FS>) INDEX LS_MOD_CELLS-ROW_ID.
    CHECK <FS> IS ASSIGNED.
    CLEAR LV_FD.

    CASE LS_MOD_CELLS-FIELDNAME.

     WHEN 'EKGRP'.
          TRANSLATE LS_MOD_CELLS-VALUE TO UPPER CASE.
          LV_EKGRP = LS_MOD_CELLS-VALUE.

          SELECT SINGLE EKNAM
             FROM T024
             WHERE EKGRP = @LV_EKGRP
                 INTO @DATA(LV_EKNAM).

             IF LV_EKNAM IS  INITIAL AND LV_EKGRP IS NOT INITIAL .
                 <FS>-STATUS = ICON_LED_RED.
                  LV_FD = 'EKGRP'.
             ELSE.
                 <FS>-EKGRP  = LS_MOD_CELLS-VALUE.
                 <FS>-EKNAM  = LV_EKNAM.
                 <FS>-STATUS = ICON_CHANGE.
             ENDIF.

     WHEN 'EKWSL'.
        IF LS_MOD_CELLS-VALUE IS INITIAL.
           <FS>-EKWSL  = LS_MOD_CELLS-VALUE.
           <FS>-STATUS = ICON_CHANGE.
        ELSE.
          SELECT SINGLE EKWSL
             FROM T405
             WHERE EKWSL = @LS_MOD_CELLS-VALUE
                 INTO @DATA(LV_EKWSL).

             IF LV_EKWSL IS  INITIAL.
                 <FS>-STATUS = ICON_LED_RED.
                  LV_FD = 'EKWSL'.
             ELSE.
                 <FS>-EKWSL  = LS_MOD_CELLS-VALUE.
                 <FS>-STATUS = ICON_CHANGE.
             ENDIF.
        ENDIF.

      WHEN 'WEBAZ'. "입고처리시간
        <FS>-WEBAZ  = LS_MOD_CELLS-VALUE.
        <FS>-STATUS = ICON_CHANGE.

      WHEN 'KORDB'.  "공급처리스트사용(체크박스)
        <FS>-KORDB  = LS_MOD_CELLS-VALUE.
        <FS>-STATUS = ICON_CHANGE.

      WHEN 'INSMK'.  "검사재고로 전기(체크박스)
        <FS>-INSMK  = LS_MOD_CELLS-VALUE.
        <FS>-STATUS = ICON_CHANGE.

      WHEN 'DISMM'. "MRP유형
        IF LS_MOD_CELLS-VALUE IS NOT INITIAL.
          TRANSLATE LS_MOD_CELLS-VALUE TO UPPER CASE.
          LV_DISMM = LS_MOD_CELLS-VALUE.

          SELECT SINGLE DIBEZ
             FROM T438T
             WHERE DISMM  = @LV_DISMM
                  AND SPRAS = @SY-LANGU
                  INTO @DATA(LV_DIBEZ).

             IF LV_DIBEZ IS  INITIAL AND LV_DISMM  IS NOT INITIAL.
                  CLEAR : <FS>-DISMM, <FS>-DIBEZ.
                 <FS>-STATUS = ICON_LED_RED.
                  LV_FD = 'DIBEZ'.
             ELSE.
                 <FS>-DISMM   = LS_MOD_CELLS-VALUE.
                 <FS>-DIBEZ    = LV_DIBEZ .
                 <FS>-STATUS = ICON_CHANGE.
             ENDIF.
        ELSE.
            <FS>-DISMM   = LS_MOD_CELLS-VALUE.
            <FS>-STATUS = ICON_CHANGE.
            CLEAR <FS>-DIBEZ.
        ENDIF.

      WHEN 'DISPO'. "MRP관리자
        IF LS_MOD_CELLS-VALUE IS INITIAL.
           <FS>-DISPO   = LS_MOD_CELLS-VALUE.
           CLEAR <FS>-DSNAM.
           <FS>-STATUS = ICON_CHANGE.
        ELSE.
          TRANSLATE LS_MOD_CELLS-VALUE TO UPPER CASE.
          LV_DISPO = LS_MOD_CELLS-VALUE.

          SELECT SINGLE DSNAM
             FROM T024D
             WHERE WERKS  = @P_WERKS
                  AND DISPO  = @LV_DISPO
                  INTO @DATA(LV_DSNAM).

             IF LV_DSNAM IS  INITIAL AND LV_DISPO IS NOT INITIAL.
                  CLEAR : <FS>-DISPO, <FS>-DSNAM.
                 <FS>-STATUS = ICON_LED_RED.
                  LV_FD = 'DSNAM'.
             ELSE.
                 <FS>-DISPO   = LS_MOD_CELLS-VALUE.
                 <FS>-DSNAM  = LV_DSNAM .
                 <FS>-STATUS = ICON_CHANGE.
             ENDIF.
        ENDIF.

      WHEN 'LGFSB'. "입고저장위치
          TRANSLATE LS_MOD_CELLS-VALUE TO UPPER CASE.
          LV_LGORT = LS_MOD_CELLS-VALUE.

          SELECT SINGLE LGOBE
             FROM T001L
             WHERE WERKS = @P_WERKS
                  AND LGORT = @LV_LGORT
                 INTO @DATA(LV_LGOBE).

             IF LV_LGOBE IS  INITIAL AND LV_LGORT IS NOT INITIAL.
                  CLEAR : <FS>-LGFSB, <FS>-LGOBE.
                 <FS>-STATUS = ICON_LED_RED.
                  LV_FD = 'LGFSB'.
             ELSE.
                 <FS>-LGFSB  = LS_MOD_CELLS-VALUE.
                 <FS>-LGOBE  = LV_LGOBE.
                 <FS>-STATUS = ICON_CHANGE.
             ENDIF.

      WHEN 'DISLS'.  "Lot Size 전략
        IF LS_MOD_CELLS-VALUE IS INITIAL.
           <FS>-DISLS   = LS_MOD_CELLS-VALUE.
           CLEAR <FS>-LOSLT.
            <FS>-STATUS = ICON_CHANGE.
        ELSE.
          TRANSLATE LS_MOD_CELLS-VALUE TO UPPER CASE.
          LV_DISLS = LS_MOD_CELLS-VALUE.

          SELECT SINGLE A~DISLS, B~LOSLT
             FROM T439A AS A
             JOIN   T439T AS B ON A~DISLS = B~DISLS
             WHERE A~DISLS   = @LV_DISLS
                  AND B~SPRAS = @SY-LANGU
                 INTO @DATA(LS_DISLS).

             IF LS_DISLS IS  INITIAL AND LV_DISLS IS NOT INITIAL.
                 CLEAR : <FS>-DISLS, <FS>-LOSLT.
                 <FS>-STATUS = ICON_LED_RED.
                  LV_FD = 'DISLS'.
             ELSE.
                 <FS>-DISLS   = LS_MOD_CELLS-VALUE.
                 <FS>-LOSLT  = LS_DISLS-LOSLT.
                 <FS>-STATUS = ICON_CHANGE.
             ENDIF.
        ENDIF.

      WHEN 'MINBE'. "재발주점
        <FS>-MINBE   = LS_MOD_CELLS-VALUE.
        <FS>-STATUS = ICON_CHANGE.

      WHEN 'BSTFE'. "고정 Lot Size
        <FS>-BSTFE   = LS_MOD_CELLS-VALUE.
        <FS>-STATUS = ICON_CHANGE.

      WHEN 'PLIFZ'. "계획납품소요일
        <FS>-PLIFZ    = LS_MOD_CELLS-VALUE.
        <FS>-STATUS = ICON_CHANGE.

      WHEN 'EISBE'.  "안전재고수량
        <FS>-EISBE    = LS_MOD_CELLS-VALUE.
        <FS>-STATUS = ICON_CHANGE.

      WHEN 'SBDKZ'.  "소요량지시자
        <FS>-SBDKZ   = LS_MOD_CELLS-VALUE.
        <FS>-STATUS = ICON_CHANGE.

    ENDCASE.

    MODIFY GT_LIST FROM <FS> INDEX  LS_MOD_CELLS-ROW_ID.
  ENDLOOP.

  PERFORM REFRESH_TABLE USING GCL_GRID SPACE.

  IF LV_FD IS NOT INITIAL.
    PERFORM ADD_ENTRY USING PO_DATA_CHANGED LV_FD
                                                 LS_MOD_CELLS-ROW_ID.
    CALL METHOD PO_DATA_CHANGED->DISPLAY_PROTOCOL.
  ENDIF.

ENDFORM. " DATA_CHANGED_1

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
                                           PV_FVAL
                                           PV_INDEX.

  CALL METHOD PR_CHNG->MODIFY_CELL
    EXPORTING
      I_ROW_ID      = PV_INDEX
      I_FIELDNAME = PV_FNAME
      I_VALUE        = PV_FVAL.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form ADD_ENTRY
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PR_CHNG
*&      --> P_
*&      --> P_
*&---------------------------------------------------------------------*
FORM ADD_ENTRY     USING PR_CHNG TYPE REF TO CL_ALV_CHANGED_DATA_PROTOCOL
                                           PV_FNAME
                                           PV_INDEX.

  CALL METHOD PR_CHNG->ADD_PROTOCOL_ENTRY
      EXPORTING
                I_MSGID     = 'ZGTMM01'
                I_MSGNO   = '013'
                I_MSGV1    = PV_FNAME
                I_MSGTY    = ZGTFI_E
                I_FIELDNAME = PV_FNAME
                I_ROW_ID       = PV_INDEX.

ENDFORM.

*&---------------------------------------------------------------------*
*& FORM HOTSPOT_CLICK
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
FORM HOTSPOT_CLICK USING PS_ROW_NO TYPE LVC_S_ROW
                                               PS_COLUMN TYPE LVC_S_COL
                                               PO_SENDER.

  CHECK PO_SENDER = GCL_GRID .
  CHECK PS_ROW_NO-ROWTYPE IS INITIAL.

  CASE PO_SENDER.

    WHEN GCL_GRID.
      READ TABLE GT_LIST INTO DATA(LS_LIST) INDEX PS_ROW_NO-INDEX.
      CHECK SY-SUBRC = 0.

      IF PS_COLUMN-FIELDNAME = 'BELNR'.
*        CHECK LS_LIST-BELNR IS NOT INITIAL.

*        SET PARAMETER ID 'BUK' FIELD P_BUKRS.
*        SET PARAMETER ID 'BLN' FIELD LS_LIST-BELNR.
*        SET PARAMETER ID 'GJR' FIELD LS_LIST-GJAHR.
*
*        CALL TRANSACTION 'FB03' AND SKIP FIRST SCREEN.

      ELSE.
        EXIT.
      ENDIF.

      IF PS_COLUMN-FIELDNAME = 'BELNR'.
*        CHECK <LS_LIST_1>-BELNR IS NOT INITIAL.

*        SET PARAMETER ID 'BUK' FIELD P_BUKRS.
*        SET PARAMETER ID 'BLN' FIELD <LS_LIST_1>-BELNR.
*        SET PARAMETER ID 'GJR' FIELD <LS_LIST_1>-GJAHR.

*        CALL TRANSACTION 'FB03' AND SKIP FIRST SCREEN.

      ELSEIF PS_COLUMN-FIELDNAME = 'CHECK'.
*        IF <LS_LIST_1>-CHECK IS INITIAL.
*          <LS_LIST_1>-CHECK = ABAP_TRUE.
*        ELSE.
*          CLEAR <LS_LIST_1>-CHECK.
*        ENDIF.

        PERFORM REFRESH_TABLE USING GCL_GRID SPACE.
        CALL METHOD CL_GUI_CFW=>SET_NEW_OK_CODE
          EXPORTING
            NEW_CODE = 'ENTER'.

      ELSE.
        EXIT.
      ENDIF.


  ENDCASE.

ENDFORM.

*&---------------------------------------------------------------------*
*&      FORM  ON_F4
*&---------------------------------------------------------------------*
FORM ON_F4  USING E_FIELDNAME    TYPE LVC_FNAME
                  E_FIELDVALUE   TYPE LVC_VALUE
                  ES_ROW_NO      TYPE LVC_S_ROID
                  ER_EVENT_DATA  TYPE REF TO CL_ALV_EVENT_DATA
                  ET_BAD_CELLS   TYPE LVC_T_MODI
                  E_DISPLAY      TYPE CHAR01.

  DATA :
         LT_RETURN TYPE TABLE OF DDSHRETVAL,
         LS_RETURN TYPE DDSHRETVAL,
         LS_MODI      TYPE LVC_S_MODI,
         LT_MODI      TYPE LVC_T_MODI,
         LV_TABIX     LIKE SY-TABIX,
         F_DATE       LIKE SY-DATUM.

  FIELD-SYMBOLS : <F4TAB> TYPE LVC_T_MODI.

  CASE E_FIELDNAME.
    WHEN  'LGFSB'.

      CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
        EXPORTING
          RETFIELD               = 'LGORT'
          VALUE_ORG           = 'S'
        TABLES
          VALUE_TAB           = GT_T001L
          RETURN_TAB         = LT_RETURN
                .
      IF SY-SUBRC <> 0.
        MESSAGE S000 WITH 'POSSIBLE ENTRY DATA가 없습니다 !!!'.
      ENDIF.

      IF SY-SUBRC = 0 AND LT_RETURN IS NOT INITIAL.
        READ TABLE LT_RETURN INTO LS_RETURN INDEX 1.

        ASSIGN ER_EVENT_DATA->M_DATA->* TO <F4TAB>.

        CLEAR : LS_MODI.
        LS_MODI-ROW_ID      = ES_ROW_NO-ROW_ID.
        LS_MODI-FIELDNAME = 'LGFSB'.
        LS_MODI-VALUE        = LS_RETURN-FIELDVAL.
        APPEND LS_MODI TO <F4TAB>.
      ENDIF.

    WHEN  'DISPO'.

      CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
        EXPORTING
          RETFIELD               = 'DISPO'
          VALUE_ORG           = 'S'
        TABLES
          VALUE_TAB           = GT_T024D
          RETURN_TAB         = LT_RETURN
                .
      IF SY-SUBRC <> 0.
        MESSAGE S000 WITH 'POSSIBLE ENTRY DATA가 없습니다 !!!'.
      ENDIF.

      IF SY-SUBRC = 0 AND LT_RETURN IS NOT INITIAL.
        READ TABLE LT_RETURN INTO LS_RETURN INDEX 1.

        ASSIGN ER_EVENT_DATA->M_DATA->* TO <F4TAB>.

        CLEAR : LS_MODI.
        LS_MODI-ROW_ID      = ES_ROW_NO-ROW_ID.
        LS_MODI-FIELDNAME = 'DISPO'.
        LS_MODI-VALUE        = LS_RETURN-FIELDVAL.
        APPEND LS_MODI TO <F4TAB>.
      ENDIF.

    WHEN OTHERS.
  ENDCASE.


* TO AVOID STANDARD F4-HELP.
     ER_EVENT_DATA->M_EVENT_HANDLED = 'X'.


*    LS_MODI-ROW_ID    = ES_ROW_NO-ROW_ID.
*    LS_MODI-FIELDNAME = 'LGORT'.
*    LS_MODI-VALUE     = SELECT_VALUE.
*    APPEND LS_MODI TO <F4TAB>.
*
*    LS_MODI-FIELDNAME = 'LGOBE'.
*    LS_MODI-VALUE     = LS_TEMP-LGOBE.
*    APPEND LS_MODI TO <F4TAB>.

*    WHEN  'MWSKZ'.
**  ELSEIF E_FIELDNAME = 'MWSKZ'.
*
*    IT_FIELDS-TABNAME    = 'T007S'.
*    IT_FIELDS-FIELDNAME  = 'MWSKZ'.
*    IT_FIELDS-SELECTFLAG = 'X'.
*    APPEND IT_FIELDS.
*
*    IT_FIELDS-TABNAME    = 'T007S'.
*    IT_FIELDS-FIELDNAME  = 'TEXT1'.
*    IT_FIELDS-SELECTFLAG = ' '.
*    APPEND IT_FIELDS.
*
*    CLEAR LS_HEADING.
*    LS_HEADING-TABNAME = 'T007S'.
*    LS_HEADING-FIELDNAME = 'MWSKZ'.
*    LS_HEADING-HEAD_TEXT = TEXT-F54.
*    APPEND LS_HEADING TO LT_HEADING.
*
*    CLEAR LS_HEADING.
*    LS_HEADING-TABNAME = 'T007S'.
*    LS_HEADING-FIELDNAME = 'TEXT1'.
*    LS_HEADING-HEAD_TEXT = TEXT-F60.
*    APPEND LS_HEADING TO LT_HEADING.
*
*    CALL FUNCTION 'HELP_VALUES_GET_NO_DD_NAME'
*      EXPORTING
*        SELECTFIELD                  = SELECTFIELD
*      IMPORTING
*        IND                          = LV_TABIX
*        SELECT_VALUE                 = SELECT_VALUE
*      TABLES
*        FIELDS                       = IT_FIELDS
*        FULL_TABLE                   = GT_007S
*        HEADING_TABLE                = LT_HEADING
*      EXCEPTIONS
*        FULL_TABLE_EMPTY             = 1
*        NO_TABLESTRUCTURE_GIVEN      = 2
*        NO_TABLEFIELDS_IN_DICTIONARY = 3
*        MORE_THEN_ONE_SELECTFIELD    = 4
*        NO_SELECTFIELD               = 5
*        OTHERS                       = 6.
*
*    IF SY-SUBRC <> 0.
*      MESSAGE S002 WITH 'POSSIBLE ENTRY DATA가 없습니다 !!!'.
*    ENDIF.
*
*    READ TABLE GT_007S INDEX LV_TABIX.
*
*    ASSIGN ER_EVENT_DATA->M_DATA->* TO <F4TAB>.
*
*    LS_MODI-ROW_ID    = ES_ROW_NO-ROW_ID.
*    LS_MODI-FIELDNAME = 'MWSKZ'.
*    LS_MODI-VALUE     = SELECT_VALUE.
*    APPEND LS_MODI TO <F4TAB>.
*
*    LS_MODI-FIELDNAME = 'MWSKZ_TX'.
*    LS_MODI-VALUE     = GT_007S-TEXT1.
*    APPEND LS_MODI TO <F4TAB>.
*  ENDIF.

*    WHEN OTHERS.
*  ENDCASE.

** TO AVOID STANDARD F4-HELP.
*  IF LS_MODI-VALUE <> ' ' .
*    ER_EVENT_DATA->M_EVENT_HANDLED = 'X'.
*  ENDIF.

ENDFORM.                                                    " ON_F41

*&---------------------------------------------------------------------*
*& FORM SET_F4_FIELD
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
FORM SET_F4_FIELD .

*  CLEAR : GT_F4_3, GT_F4_4.
*
*  IF GV_300GB = 1.
*    GS_F4_4-FIELDNAME  = 'MWSKZ'.
*    GS_F4_4-REGISTER   = 'X'.
*    APPEND GS_F4_4 TO GT_F4_4.
*
*    CALL METHOD GCL_GRID_4->REGISTER_F4_FOR_FIELDS
*      EXPORTING
*        IT_F4 = GT_F4_4.
*  ENDIF.
*
*  GS_F4_3-FIELDNAME  = 'HKONT'.
*  GS_F4_3-REGISTER   = 'X'.
*  APPEND GS_F4_3 TO GT_F4_3.
*
*  CALL METHOD GCL_GRID_3->REGISTER_F4_FOR_FIELDS
*    EXPORTING
*      IT_F4 = GT_F4_3.

ENDFORM.

*&---------------------------------------------------------------------*
*& FORM CLEAR_POST_PROCESS
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
FORM CLEAR_POST_PROCESS  USING    PV_SIMUL.   "X면 SIMUL.

  CHECK GV_ERR IS INITIAL.

ENDFORM.

*&---------------------------------------------------------------------*
*& FORM CHECK_CLOSING_MONTH
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
FORM CHECK_CLOSING_MONTH  USING  PV_DATE TYPE DATUM
                                             CHANGING  PV_CHK  TYPE CHAR1.

*  CLEAR PV_CHK.
*
*  CALL FUNCTION 'ZTR_CLOSING_MONTH_CHECK'
*    EXPORTING
*      IBUKRS       = P_BUKRS
*      IDATE        = PV_DATE
*    EXCEPTIONS
*      NO_SETTING   = 1
*      CLOSING_DATE = 2
*      OTHERS       = 3.
*
*  IF SY-SUBRC <> 0.
*    PV_CHK = ABAP_TRUE.
*  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_CHANGE_SAVE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_CHANGE_SAVE .

  IF LINE_EXISTS( GT_LIST[ STATUS = ICON_LED_RED ] ) OR
    LINE_EXISTS( GT_LIST[ STATUS = ICON_CHANGE ] ).

    PERFORM POPUP_TO_CONFIRM_STEP USING ZGTFI_N
                                                               TEXT-M06  "자재마스터 정보가 변경됩니다.
                                                               TEXT-M07  "저장 하시겠습니까?
                                                               TEXT-T04. "확인
    CHECK GV_ANSWER = ZGTFI_J. "YES
    PERFORM SAVE_DATA.

  ELSE.
    MESSAGE S017 DISPLAY LIKE ZGTFI_E.
    "변경된 내역이 없습니다.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SAVE_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SAVE_DATA .

  DATA :
     HEADDATA      LIKE  BAPIMATHEAD,
     CLIENTDATA   LIKE  BAPI_MARA,
     CLIENTDATAX LIKE  BAPI_MARAX,
     PLANTDATA    LIKE  BAPI_MARC,
     PLANTDATAX  LIKE  BAPI_MARCX.

*  DATA(LT_LIST) = GT_LIST[].
*  DELETE LT_LIST WHERE STATUS IS INITIAL.

  LOOP AT GT_LIST INTO DATA(LS_LIST) WHERE STATUS IS NOT INITIAL .
     CLEAR : HEADDATA, CLIENTDATA, CLIENTDATAX, PLANTDATA, PLANTDATAX.
*HEADER
     HEADDATA-MATERIAL = LS_LIST-MATNR.
*CLIENT
     CLIENTDATA-PUR_VALKEY   = COND #( WHEN P_PUR = ZGTFI_X THEN LS_LIST-EKWSL ELSE '' ).
     CLIENTDATAX-PUR_VALKEY = COND #( WHEN P_PUR = ZGTFI_X THEN ZGTFI_X ELSE '' ).
*PLANT
     PLANTDATA = VALUE #(
                           PLANT            = P_WERKS
                           PUR_GROUP   = COND #( WHEN P_PUR = ZGTFI_X THEN LS_LIST-EKGRP ELSE '' )
                           MRP_TYPE      = COND #( WHEN P_ROP = ZGTFI_X THEN LS_LIST-DISMM ELSE '' )
                           PLND_DELRY  = COND #( WHEN P_ROP = ZGTFI_X THEN LS_LIST-PLIFZ ELSE '' )
                           GR_PR_TIME   = COND #( WHEN P_PUR = ZGTFI_X THEN LS_LIST-WEBAZ ELSE '' )
                           LOTSIZEKEY   = COND #( WHEN P_ROP = ZGTFI_X THEN LS_LIST-DISLS ELSE '' )
                           REORDER_PT  = COND #( WHEN P_ROP = ZGTFI_X THEN LS_LIST-MINBE ELSE '' )
                           SAFETY_STK   = COND #( WHEN P_ROP = ZGTFI_X THEN LS_LIST-EISBE ELSE '' )
                           FIXED_LOT      = COND #( WHEN P_ROP = ZGTFI_X THEN LS_LIST-BSTFE ELSE '' )
                           DEP_REQ_ID    = COND #( WHEN P_ROP = ZGTFI_X THEN LS_LIST-SBDKZ ELSE '' )
                           MRP_CTRLER     = COND #( WHEN P_ROP = ZGTFI_X THEN LS_LIST-DISPO ELSE '' )
                           SLOC_EXPRC = COND #( WHEN P_ROP = ZGTFI_X THEN LS_LIST-LGFSB ELSE '' )
                           SOURCELIST   = COND #( WHEN P_PUR = ZGTFI_X THEN LS_LIST-KORDB ELSE '' )
                           IND_POST_TO_INSP_STOCK =
                           COND #( WHEN P_QUL = ZGTFI_X THEN LS_LIST-INSMK ELSE '' ) ).

     PLANTDATAX = VALUE #(
                           PLANT            = P_WERKS
                           PUR_GROUP   = COND #( WHEN P_PUR = ZGTFI_X THEN ZGTFI_X ELSE '' )
                           MRP_TYPE      = COND #( WHEN P_ROP = ZGTFI_X THEN ZGTFI_X ELSE '' )
                           PLND_DELRY  = COND #( WHEN P_ROP = ZGTFI_X THEN ZGTFI_X ELSE '' )
                           GR_PR_TIME   = COND #( WHEN P_PUR = ZGTFI_X THEN ZGTFI_X ELSE '' )
                           LOTSIZEKEY   = COND #( WHEN P_ROP = ZGTFI_X THEN ZGTFI_X ELSE '' )
                           REORDER_PT  = COND #( WHEN P_ROP = ZGTFI_X THEN ZGTFI_X ELSE '' )
                           SAFETY_STK   = COND #( WHEN P_ROP = ZGTFI_X THEN ZGTFI_X ELSE '' )
                           FIXED_LOT      = COND #( WHEN P_ROP = ZGTFI_X THEN ZGTFI_X ELSE '' )
                           DEP_REQ_ID    = COND #( WHEN P_ROP = ZGTFI_X THEN ZGTFI_X ELSE '' )
                           MRP_CTRLER  = COND #( WHEN P_ROP = ZGTFI_X THEN ZGTFI_X ELSE '' )
                           SLOC_EXPRC  = COND #( WHEN P_ROP = ZGTFI_X THEN ZGTFI_X ELSE '' )
                           SOURCELIST   = COND #( WHEN P_PUR = ZGTFI_X THEN ZGTFI_X ELSE '' )
                           IND_POST_TO_INSP_STOCK =
                           COND #( WHEN P_QUL = ZGTFI_X THEN ZGTFI_X ELSE '' ) ).

*BAPI
      CALL FUNCTION 'BAPI_MATERIAL_SAVEDATA'
        EXPORTING
          HEADDATA                   =  HEADDATA
         CLIENTDATA                  =  CLIENTDATA
         CLIENTDATAX                =  CLIENTDATAX
         PLANTDATA                   =  PLANTDATA
         PLANTDATAX                 =  PLANTDATAX
       IMPORTING
         RETURN                       =  GS_RETURN
                .

       IF GS_RETURN-TYPE = ZGTFI_S.

         CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
          EXPORTING
            WAIT = ZGTFI_X.

          LS_LIST-STATUS    = ICON_LED_GREEN.
          LS_LIST-MESSAGE = TEXT-M08. "자재 마스터가 변경 되었습니다.

       ELSE.
          CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

          LS_LIST-STATUS    = ICON_LED_RED.
          LS_LIST-MESSAGE = GS_RETURN-MESSAGE.
       ENDIF.

       MODIFY GT_LIST FROM LS_LIST TRANSPORTING STATUS MESSAGE.
  ENDLOOP.



ENDFORM.
