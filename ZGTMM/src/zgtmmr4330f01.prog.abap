*&---------------------------------------------------------------------*
*& INCLUDE          ZGTMMR4330F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& FORM CREATE_ALV
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
FORM CREATE_ALV .

  PERFORM :
            SET_CONTAINER USING '100',
            SET_ALV_GRID    USING '100',
            SET_ALV_FIELDCAT USING '100',
            SET_ALV_LAYOUT USING '100',
            SET_ALV_TOOLBAR,
            SET_ALV_SORT,
            SET_EVENT        CHANGING GCL_EVENT GCL_GRID,
            DISPLAY_ALV.

ENDFORM.
*&---------------------------------------------------------------------*
*& FORM CREATE_ALV_300
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
FORM CREATE_ALV_300 .

  PERFORM :
            SET_CONTAINER USING '300',
            SET_ALV_GRID    USING '300',
            SET_ALV_FIELDCAT USING '300',
            SET_ALV_LAYOUT USING '300',
            SET_ALV_TOOLBAR,
            SET_ALV_SORT,
            SET_EVENT        CHANGING GCL_EVENT GCL_GRID_300,
            DISPLAY_ALV_300.

ENDFORM.
*&---------------------------------------------------------------------*
*& FORM SET_CONTAINER
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
FORM SET_CONTAINER USING PV_CON.

  IF PV_CON = '100'.
    IF GCL_DOCKING IS NOT BOUND.

      CREATE OBJECT GCL_DOCKING
        EXPORTING
          REPID     = SY-REPID
          DYNNR     = SY-DYNNR
          SIDE      = CL_GUI_DOCKING_CONTAINER=>DOCK_AT_LEFT
          EXTENSION = 2500.

    ENDIF.

  ELSE.
    IF GCL_CUSTOM IS NOT BOUND.

      IF GCL_CUSTOM IS NOT BOUND.

        CREATE OBJECT GCL_CUSTOM
          EXPORTING
            CONTAINER_NAME = 'CC_LABEL'.
      ENDIF.

    ENDIF.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*& FORM SET_ALV_GRID
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
FORM SET_ALV_GRID USING PV_GB.

  IF PV_GB = '100'.

    IF GCL_GRID IS NOT BOUND.
      CREATE OBJECT GCL_GRID
        EXPORTING
          I_PARENT          = GCL_DOCKING
        EXCEPTIONS
          ERROR_CNTL_CREATE = 1
          ERROR_CNTL_INIT   = 2
          ERROR_CNTL_LINK   = 3
          ERROR_DP_CREATE   = 4
          OTHERS            = 5.
    ENDIF.

  ELSE.
    IF GCL_GRID_300 IS NOT BOUND.
      CREATE OBJECT GCL_GRID_300
        EXPORTING
          I_PARENT          = GCL_CUSTOM
        EXCEPTIONS
          ERROR_CNTL_CREATE = 1
          ERROR_CNTL_INIT   = 2
          ERROR_CNTL_LINK   = 3
          ERROR_DP_CREATE   = 4
          OTHERS            = 5.
    ENDIF.

  ENDIF.

  IF SY-SUBRC <> 0.
    "COULD NOT CREATE ALV GRID (SY-SUBRC = &)
    MESSAGE E725(BT) WITH SY-SUBRC.
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
      WHEN 'STATUS'. "상태
        _FCAT TEXT-F01.

      WHEN 'DELNO'.      "납품문서 번호
        _FCAT TEXT-F08.
        <FS_S_FCT>-NO_OUT = COND #( WHEN P_DNO = GC_X OR P_DIS = GC_X
                                                            THEN '' ELSE GC_X ).

      WHEN 'DELITEM'.     "납품문서 품목
        _FCAT TEXT-F09.
        <FS_S_FCT>-NO_OUT = COND #( WHEN P_DNO = GC_X OR P_DIS = GC_X
                                                            THEN '' ELSE GC_X ).

      WHEN 'DOC_URL'.    "시험성적서 URL
        _FCAT 'URL'.
        <FS_S_FCT>-NO_OUT = GC_X.

      WHEN 'DOC_TXT'.    "시험성적서
        _FCAT TEXT-F69.
        <FS_S_FCT>-OUTPUTLEN = 10.
        <FS_S_FCT>-HOTSPOT =  GC_X .
        <FS_S_FCT>-NO_OUT = COND #( WHEN P_DNO IS INITIAL OR P_DIS IS INITIAL
                                                            THEN GC_X ELSE SPACE ).

      WHEN 'DR_LABELNO'."드럼라벨번호
        _FCAT '드럼라벨번호'.
        <FS_S_FCT>-NO_OUT = COND #( WHEN P_LNO IS INITIAL THEN GC_X ELSE SPACE ).

      WHEN 'EBELN'.     "구매오더
        _FCAT TEXT-F12.
        <FS_S_FCT>-HOTSPOT =  GC_X .

      WHEN 'EBELP'.    "구매오더품목
        _FCAT TEXT-F13.

      WHEN 'LIFNR'.   "공급업체
        _FCAT TEXT-F16.

      WHEN 'NAME1'.   "업체명
        _FCAT TEXT-F17.

      WHEN 'WERKS'.     " 플랜트
        _FCAT TEXT-F02.

      WHEN 'WERKS_N'.  "플랜트명
        _FCAT TEXT-F03.

      WHEN 'LGORT'.       "저장위치
        _FCAT TEXT-F25.
        <FS_S_FCT>-EDIT = GC_X.
        <FS_S_FCT>-F4AVAILABL = GC_X.

      WHEN 'LGORT_N'.        "저장위치명
        _FCAT TEXT-F26.

      WHEN 'MATNR'.        "자재코드
        _FCAT TEXT-F20.

      WHEN 'TXZ01'.        "자재명
        _FCAT TEXT-F21.

      WHEN 'XCHPF'.     "배치자재
        _FCAT TEXT-F14.
        <FS_S_FCT>-CHECKBOX = GC_X.

      WHEN 'BUDAT'.
        IF P_DNO = GC_X ."OR P_DIS = GC_X.
          _FCAT TEXT-F19.  ""납품일자
        ELSEIF P_LNO = GC_X.
          _FCAT TEXT-F22. "입고전기일
        ENDIF.
        <FS_S_FCT>-NO_OUT = COND #( WHEN P_PO = GC_X THEN GC_X ELSE '' ).

      WHEN 'MENGE'.
        CASE GC_X.
          WHEN P_PO.
            _FCAT TEXT-F35.  "오더수량
          WHEN P_DNO.
            _FCAT TEXT-F27.  "납품수량
          WHEN P_LNO .
            _FCAT '조장수량'. "조장수량
          WHEN OTHERS.
            _FCAT '오더/납품 수량'.
        ENDCASE.

        <FS_S_FCT>-QFIELDNAME = 'MEINS'.

      WHEN 'MEINS'.        "단위
        _FCAT TEXT-F28.

      WHEN 'ERFMG'.        "입고수량
        _FCAT TEXT-F38.
        <FS_S_FCT>-QFIELDNAME = 'MEINS'.
        <FS_S_FCT>-EDIT              = GC_X.

      WHEN 'INSMK'."재고유형
        _FCAT '재고유형'.
        <FS_S_FCT>-EDIT = GC_X.
        <FS_S_FCT>-F4AVAILABL = GC_X.
        <FS_S_FCT>-REF_TABLE = 'EKPO'.
        <FS_S_FCT>-REF_FIELD = 'INSMK'.
        <FS_S_FCT>-NO_OUT = COND #( WHEN P_LNO IS INITIAL THEN GC_X ELSE SPACE ).

      WHEN 'REMAIN_QTY'.     "오더잔량->입고허용수량
        _FCAT TEXT-F24.
        <FS_S_FCT>-QFIELDNAME = 'MEINS'.
        <FS_S_FCT>-NO_OUT = COND #( WHEN P_PO = GC_X THEN '' ELSE GC_X ).

      WHEN 'ELIKZ'.        "납품완료
        _FCAT TEXT-F18.
        <FS_S_FCT>-CHECKBOX = GC_X.
        <FS_S_FCT>-NO_OUT = COND #( WHEN P_LNO = GC_X THEN GC_X ELSE '' ).

      WHEN 'DELCLOSE'.        "납품문서종결
        _FCAT TEXT-F29.
        <FS_S_FCT>-NO_OUT = COND #( WHEN P_DNO = GC_X THEN '' ELSE GC_X ).
        <FS_S_FCT>-CHECKBOX = GC_X.

      WHEN 'GRBUDAT'.        "입고전기일
        _FCAT TEXT-F22.
        <FS_S_FCT>-NO_OUT = COND #( WHEN P_LNO = GC_X THEN GC_X ELSE '' ).

      WHEN 'MBLNR'.      "자재문서번호
        _FCAT TEXT-F23.
        <FS_S_FCT>-HOTSPOT = GC_X.

      WHEN 'PSTYP'.        "품목범주
        _FCAT TEXT-F31.
        <FS_S_FCT>-NO_OUT = COND #( WHEN P_PO = GC_X OR P_DIS = GC_X THEN '' ELSE GC_X ).

      WHEN 'PTEXT'.        "품목범주내역
        _FCAT TEXT-F32.
        <FS_S_FCT>-NO_OUT = COND #( WHEN P_PO = GC_X OR P_DIS = GC_X THEN '' ELSE GC_X ).

      WHEN 'KNTTP'.        "계정지정범주
        _FCAT TEXT-F33.
        <FS_S_FCT>-NO_OUT = COND #( WHEN P_PO = GC_X OR P_DIS = GC_X THEN '' ELSE GC_X ).

      WHEN 'KNTTX'.        "계정지정범주 내역
        _FCAT TEXT-F34.
        <FS_S_FCT>-NO_OUT = COND #( WHEN P_PO = GC_X OR P_DIS = GC_X THEN '' ELSE GC_X ).

      WHEN 'ANLN1'.        "자산
        _FCAT TEXT-F36.
        <FS_S_FCT>-NO_OUT = COND #( WHEN P_PO = GC_X OR P_DIS = GC_X THEN '' ELSE GC_X ).

      WHEN 'TXT50'.        "자산명
        _FCAT TEXT-F37.
        <FS_S_FCT>-NO_OUT = COND #( WHEN P_PO = GC_X OR P_DIS = GC_X THEN '' ELSE GC_X ).

      WHEN 'KOSTL'.     "코스트센터
        _FCAT TEXT-F40.
        <FS_S_FCT>-NO_OUT = COND #( WHEN P_PO = GC_X OR P_DIS = GC_X THEN '' ELSE GC_X ).

      WHEN 'KTEXT'.     "코스트센터명
        _FCAT TEXT-F41.
        <FS_S_FCT>-NO_OUT = COND #( WHEN P_PO = GC_X OR P_DIS = GC_X THEN '' ELSE GC_X ).

      WHEN 'AUFNR'.     "오더
        _FCAT TEXT-F42.
        <FS_S_FCT>-NO_OUT = COND #( WHEN P_PO = GC_X OR P_DIS = GC_X THEN '' ELSE GC_X ).

      WHEN 'ATEXT'.     "오더명
        _FCAT TEXT-F43.
        <FS_S_FCT>-NO_OUT = COND #( WHEN P_PO = GC_X OR P_DIS = GC_X THEN '' ELSE GC_X ).

      WHEN 'SAKTO'.     "G/L 계정
        _FCAT TEXT-F44.
        <FS_S_FCT>-NO_OUT = COND #( WHEN P_PO = GC_X OR P_DIS = GC_X THEN '' ELSE GC_X ).

      WHEN 'GTEXT'.     "G/L 계정 내역
        _FCAT TEXT-F45.
        <FS_S_FCT>-NO_OUT = COND #( WHEN P_PO = GC_X OR P_DIS = GC_X THEN '' ELSE GC_X ).

      WHEN 'PS_PSP_PNR'.     "WBS
        _FCAT 'WBS 코드'.
        <FS_S_FCT>-NO_OUT = COND #( WHEN P_PO = GC_X OR P_DIS = GC_X THEN '' ELSE GC_X ).

      WHEN 'POST1'.     "WBS 내역
        _FCAT 'WBS 내역'.
        <FS_S_FCT>-NO_OUT = COND #( WHEN P_PO = GC_X OR P_DIS = GC_X THEN '' ELSE GC_X ).

      WHEN 'RETPO'.  "반품구분
        _FCAT '반품구분'.
        <FS_S_FCT>-CHECKBOX = GC_X.
        <FS_S_FCT>-NO_OUT = COND #( WHEN P_PO = GC_X OR P_DIS = GC_X THEN '' ELSE GC_X ).

      WHEN 'VBELN'.  "판매오더번호
        _FCAT '판매오더번호'.

      WHEN 'POSNR'.  "판매오더품목
        _FCAT '판매오더품목'.

      WHEN 'POAMT'.  "입고대상금액
        _FCAT '입고대상금액'.
        <FS_S_FCT>-CFIELDNAME = 'WAERS'.
        <FS_S_FCT>-NO_OUT = COND #( WHEN P_PO = GC_X OR P_DIS = GC_X THEN '' ELSE GC_X ).

      WHEN 'WAERS'.  "통화
        _FCAT '통화'.
        <FS_S_FCT>-NO_OUT = COND #( WHEN P_PO = GC_X OR P_DIS = GC_X THEN '' ELSE GC_X ).

      WHEN 'MESSAGE'.   "처리결과
        _FCAT TEXT-F68.

      WHEN OTHERS.
        <FS_S_FCT>-NO_OUT = ZGTFI_X.

    ENDCASE.

    APPEND <FS_S_FCT> TO GT_FCAT.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& FORM ADJUST_FLDCATS_300
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
FORM ADJUST_FLDCATS_300  TABLES PT_FCAT TYPE LVC_T_FCAT.

  DEFINE _FCAT.
    <FS_S_FCT>-SCRTEXT_S  =
    <FS_S_FCT>-SCRTEXT_M  =
    <FS_S_FCT>-SCRTEXT_L  =
    <FS_S_FCT>-COLTEXT    =
    <FS_S_FCT>-REPTEXT    = &1.
  END-OF-DEFINITION.

  DATA LV_COL TYPE I.
  CLEAR : GT_FCAT_300[].

  LOOP AT PT_FCAT ASSIGNING FIELD-SYMBOL(<FS_S_FCT>).
    CLEAR : <FS_S_FCT>-COL_POS.

    CASE <FS_S_FCT>-FIELDNAME.
      WHEN 'CHECK'.
        _FCAT TEXT-F51.
        <FS_S_FCT>-EDIT = GC_X.
        <FS_S_FCT>-CHECKBOX = GC_X.

      WHEN 'PALETNO'.      "파레트 라벨
        _FCAT TEXT-F46.

      WHEN 'LABELNO'.     "라벨번호
        _FCAT TEXT-F47.

      WHEN 'LABELITEM'.     "라벨항번
        _FCAT TEXT-F48.

      WHEN 'MENGE'.    "적입수량
        _FCAT TEXT-F49.
        <FS_S_FCT>-QFIELDNAME = 'PKG_UNIT'.

      WHEN 'PKG_QTY'.   "포장수량
        _FCAT TEXT-F50.
        <FS_S_FCT>-QFIELDNAME = 'PKG_UNIT'.

      WHEN 'PKG_UNIT'.   "단위
        _FCAT TEXT-F28.

      WHEN 'GRSTATUS'.  "입고상태
        _FCAT TEXT-F70.
        <FS_S_FCT>-CHECKBOX = GC_X.

      WHEN OTHERS.
        <FS_S_FCT>-TECH = ZGTFI_X.

    ENDCASE.

    APPEND <FS_S_FCT> TO GT_FCAT_300.
  ENDLOOP.

ENDFORM.


*&---------------------------------------------------------------------*
*& FORM SET_ALV_LAYOUT
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
FORM SET_ALV_LAYOUT USING PV_GUBUN.

  CLEAR GS_LAYOUT.

  IF PV_GUBUN = '100'.
    GS_LAYOUT = VALUE #(
*                       NO_ROWINS  = ZGTFI_X
                         ZEBRA  = ZGTFI_X
                         SEL_MODE   = ZGTFI_A
                         CWIDTH_OPT  = ZGTFI_A
                         STYLEFNAME = 'STYLE'
*                       CTAB_FNAME = 'COLO'
    ).

  ELSE.
    GS_LAYOUT = VALUE #(
                         NO_ROWINS  = ZGTFI_X
                         ZEBRA  = ZGTFI_X
                         SEL_MODE   = ZGTFI_A
                         CWIDTH_OPT  = ZGTFI_A
*                       STYLEFNAME = 'STYLE'
*                       CTAB_FNAME = 'COLO'
    ).
  ENDIF.

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

*  PERFORM SET_CELL_COLOR.

  IF PCL_GRID = GCL_GRID.
    PERFORM SET_CELL_STYLE .
  ENDIF.

  DATA:
    LT_F4 TYPE LVC_T_F4,
    LS_F4 TYPE LVC_S_F4.

  LS_F4-FIELDNAME  = 'LGORT'.
  LS_F4-REGISTER     = 'X'.
  LS_F4-GETBEFORE  = 'X'.
  LS_F4-CHNGEAFTER = 'X'.
  APPEND LS_F4 TO LT_F4.

  CALL METHOD PCL_GRID->REGISTER_F4_FOR_FIELDS
    EXPORTING
      IT_F4 = LT_F4.

  CREATE OBJECT PO_EVENT.

  IF PCL_GRID = GCL_GRID.
    SET HANDLER :
    PO_EVENT->HANDLE_DATA_CHANGED                 FOR PCL_GRID,
    PO_EVENT->HANDLE_DATA_CHANGED_FINISHED  FOR PCL_GRID,
    PO_EVENT->HANDLE_HOTSPOT_CLICK                FOR PCL_GRID,
    PO_EVENT->HANDLE_TOOLBAR                           FOR PCL_GRID,
    PO_EVENT->HANDLE_USER_COMMAND               FOR PCL_GRID,
    PO_EVENT->HANDLE_ON_F4                               FOR PCL_GRID.

  ELSE.
    SET HANDLER  PO_EVENT->HANDLE_DATA_CHANGED FOR PCL_GRID.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*& FORM DISPLAY_ALV
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
FORM DISPLAY_ALV .

  DATA(LS_VARINT) = VALUE DISVARIANT(
                                           REPORT  = SY-CPROG "SY-REPID
                                           HANDLE  = COND #( WHEN P_DNO = GC_X THEN '0001'
                                                                          WHEN P_PO = GC_X   THEN '0002'
                                                                          WHEN P_LNO = GC_X THEN '0003' ) ).

  CALL METHOD GCL_GRID->SET_TABLE_FOR_FIRST_DISPLAY
    EXPORTING
      IS_LAYOUT            = GS_LAYOUT
      IT_TOOLBAR_EXCLUDING = GT_EXCLUD[]
      IS_VARIANT           = LS_VARINT
      I_SAVE               = ZGTFI_A
    CHANGING
      IT_OUTTAB            = GT_LIST[]
      IT_FIELDCATALOG      = GT_FCAT[]
      IT_SORT              = GT_SORT[]
    EXCEPTIONS
      OTHERS               = 4.

  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
          WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*& FORM DISPLAY_ALV_300
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
FORM DISPLAY_ALV_300 .

*  DATA(LS_VARINT) = VALUE DISVARIANT( REPORT  = SY-CPROG
*                                           HANDLE  = '0001' ).

  CALL METHOD GCL_GRID_300->SET_TABLE_FOR_FIRST_DISPLAY
    EXPORTING
      IS_LAYOUT            = GS_LAYOUT
      IT_TOOLBAR_EXCLUDING = GT_EXCLUD[]
*     IS_VARIANT           = LS_VARINT
      I_SAVE               = ZGTFI_A
    CHANGING
      IT_OUTTAB            = GT_LIST_LABEL[]
      IT_FIELDCATALOG      = GT_FCAT_300[]
      IT_SORT              = GT_SORT[]
    EXCEPTIONS
      OTHERS               = 4.

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

  CLEAR : S_BUDAT[], S_DATE[]. "납품일자, 기준일자
  S_BUDAT[] = VALUE #( ( SIGN   = GC_I
                                        OPTION = GC_BT
                                        LOW    = SY-DATLO - 30
                                        HIGH   = SY-DATLO ) ).
  S_DATE[] = VALUE #( ( SIGN   = GC_I
                                      OPTION = GC_BT
                                      LOW    = SY-DATLO - 30
                                      HIGH   = SY-DATLO ) ).

  CLEAR:
    GT_T163I[],
    GT_T163Y[].

  SELECT
    KNTTP,
    KNTTX
    FROM T163I
    WHERE SPRAS EQ @SY-LANGU
    INTO TABLE @GT_T163I.

  SELECT
    PSTYP,
    PTEXT
    FROM T163Y
    WHERE SPRAS EQ @SY-LANGU
    INTO TABLE @GT_T163Y.

ENDFORM.

*&---------------------------------------------------------------------*
*& FORM INPUT_VALIDATION
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
FORM INPUT_VALIDATION.

  CLEAR : GT_LIST, GV_ERR.
*필수 입력 필드 점검
  CASE GC_X.
    WHEN P_DNO.
      IF S_BUDAT[] IS INITIAL.
        MESSAGE S000 WITH TEXT-M13 DISPLAY LIKE GC_E.
        GV_ERR = GC_X. STOP. "납품일자는 필수 입력 해야 합니다.
      ENDIF.

    WHEN P_PO OR P_LNO.
      IF S_AEDAT[] IS INITIAL.
        MESSAGE S000 WITH TEXT-M16 DISPLAY LIKE GC_E.
        GV_ERR = GC_X. STOP. "구매오더 생성일은 필수 입력 해야 합니다.
      ENDIF.

    WHEN P_DIS. "표준/수기 명세서 일괄조회
      IF S_DATE[] IS INITIAL.
        MESSAGE S000 WITH TEXT-M21 DISPLAY LIKE GC_E.
        GV_ERR = GC_X. STOP. "기준일자는 필수 입력 해야 합니다.
      ENDIF.

    WHEN OTHERS.
  ENDCASE.

*선택필드 입력 값 유효성 점검
  IF  S_DELNO-LOW IS NOT INITIAL.
    LOOP AT S_DELNO INTO DATA(LS_DELNO).

      SELECT SINGLE 1
       FROM ZGTMMT9410
       WHERE DELNO EQ @LS_DELNO-LOW
        INTO @DATA(LV_EXST).

      IF SY-SUBRC <> 0.
        MESSAGE S000 WITH TEXT-M02 DISPLAY LIKE GC_E.
        GV_ERR = GC_X.  STOP. "유효하지 않은 납품문서 입니다.
      ENDIF.

    ENDLOOP.
  ENDIF.

  IF S_EBELN-LOW IS NOT INITIAL.
    LOOP AT S_EBELN INTO DATA(LS_LOW).

      SELECT SINGLE 1
      FROM EKKO
      WHERE EBELN EQ @LS_LOW-LOW
      INTO @LV_EXST.

      IF SY-SUBRC <> 0.
        MESSAGE S000 WITH TEXT-M12 DISPLAY LIKE GC_E.
        GV_ERR = GC_X. STOP. "유효하지 않은 구매오더 입니다.
      ENDIF.
    ENDLOOP.
  ENDIF.

  IF S_LIFNR-LOW IS NOT INITIAL.
    LOOP AT S_LIFNR INTO DATA(LS_LIFNR).

      SELECT SINGLE 1
      FROM LFA1
      WHERE LIFNR EQ @LS_LIFNR-LOW
      INTO @LV_EXST.

      IF SY-SUBRC <> 0.
        MESSAGE S000 WITH TEXT-M03 DISPLAY LIKE GC_E.
        GV_ERR = GC_X. STOP. "유효하지 않은 공급업체 입니다.
      ENDIF.
    ENDLOOP.
  ENDIF.

  IF S_MATNR-LOW IS NOT INITIAL.
    LOOP AT S_MATNR INTO DATA(LS_MATNR).

      SELECT SINGLE 1
      FROM MARA
      WHERE MATNR EQ @LS_MATNR-LOW
      INTO @LV_EXST.

      IF SY-SUBRC <> 0.
        MESSAGE S000 WITH TEXT-M10 DISPLAY LIKE GC_E.
        GV_ERR = GC_X. STOP. "유효하지 않은 자재코드 입니다.
      ENDIF.
    ENDLOOP.
  ENDIF.

*  IF S_LABEL-LOW IS NOT INITIAL.
*    LOOP AT S_LABEL INTO DATA(LS_LABEL).
*
*      SELECT SINGLE 1
*      FROM
*      WHERE LABEL EQ @LS_LABEL-LOW
*      INTO @LV_EXST.
*
*      IF SY-SUBRC <> 0.
*        MESSAGE S000 WITH TEXT-M11 DISPLAY LIKE GC_E.
*        GV_ERR = GC_X. STOP. "유효하지 않은 라벨번호 입니다.
*      ENDIF.
*    ENDLOOP.
*  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*& FORM CHECK_AUTH
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
FORM CHECK_AUTH.
  CLEAR GV_ERR.

  "회사코드 권한 체크..
  AUTHORITY-CHECK OBJECT 'ZCBO_MM001'
  ID 'BUKRS' FIELD P_BUKRS.

  IF SY-SUBRC NE 0.
    "회사 코드 &에 대한 권한이 없습니다.
    MESSAGE E000 WITH '회사코드_' P_BUKRS ' 에 대한 권한이 없습니다.'.
    GV_ERR = ABAP_TRUE.
    STOP.
  ENDIF.

  "플랜트 권한 체크..
  AUTHORITY-CHECK OBJECT 'ZCBO_MM001'
  ID 'WERKS' FIELD P_WERKS.

  IF SY-SUBRC NE 0.
    "플랜트 &에 대한 권한이 없습니다.
    MESSAGE E000 WITH '플랜트_' P_WERKS ' 에 대한 권한이 없습니다.'.
    GV_ERR = ABAP_TRUE.
    STOP.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& FORM SELECTION_SCREEN_OUTPUT
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
FORM SELECTION_SCREEN_OUTPUT .

  LOOP AT SCREEN.
    CASE SCREEN-GROUP1.

      WHEN 'MD1'. "납품문서/납품일자
        IF P_DNO EQ GC_X.
          SCREEN-ACTIVE = 1.
        ELSE.
          SCREEN-ACTIVE = 0.
        ENDIF.

      WHEN 'MD2'. "납품예정일
        IF P_PO EQ GC_X .
          SCREEN-ACTIVE = 1.
        ELSE.
          SCREEN-ACTIVE = 0.
        ENDIF.

      WHEN 'MD3'.  "구매오더생성일
        IF P_LNO EQ GC_X OR P_PO = GC_X.
          SCREEN-ACTIVE = 1.
        ELSE.
          SCREEN-ACTIVE = 0.
        ENDIF.

      WHEN  'MD4'.  "라벨번호
        IF P_LNO EQ GC_X .
          SCREEN-ACTIVE = 1.
        ELSE.
          SCREEN-ACTIVE = 0.
        ENDIF.

      WHEN 'MDD'.  "구매그룹
        IF P_LNO EQ GC_X . "라벨번호 일 때만 비활성
          SCREEN-ACTIVE = 0.
        ELSE.
          SCREEN-ACTIVE = 1.
        ENDIF.

      WHEN 'DIS'.    "기준일자
        IF P_DIS EQ GC_X .
          SCREEN-ACTIVE = 1.
        ELSE.
          SCREEN-ACTIVE = 0.
        ENDIF.

    ENDCASE.

    MODIFY SCREEN.
  ENDLOOP.

*선택 조건에 따른 필드 별 필수 날짜 세팅
  CASE GC_X.
    WHEN P_DNO. "표준거래명세서
      CLEAR : S_AEDAT[], S_EINDT[].
      IF S_BUDAT[] IS INITIAL. "납품일자
        S_BUDAT[] = VALUE #( ( SIGN   = GC_I
                                              OPTION = GC_BT
                                              LOW    = SY-DATLO - 30
                                              HIGH   = SY-DATLO ) ).
      ENDIF.

    WHEN P_PO. "수기거래명세서
      CLEAR : S_BUDAT[].
      IF S_AEDAT[] IS INITIAL. "구매오더 생성일
        S_AEDAT[] = VALUE #( ( SIGN   = GC_I
                                              OPTION = GC_BT
                                              LOW    = SY-DATLO - 30
                                              HIGH   = SY-DATLO ) ).
      ENDIF.

    WHEN P_LNO.  "OEM라벨번호
      CLEAR : S_EINDT[], S_BUDAT[].
      IF S_AEDAT[] IS INITIAL. "구매오더 생성일
        S_AEDAT[] = VALUE #( ( SIGN   = GC_I
                                              OPTION = GC_BT
                                              LOW    = SY-DATLO - 30
                                              HIGH   = SY-DATLO ) ).
      ENDIF.

    WHEN P_DIS.  "표준/수기 명세서 일괄조회
      CLEAR : S_AEDAT[], S_EINDT[], S_BUDAT[].
      IF S_DATE[] IS INITIAL. "기준일자
        S_DATE[] = VALUE #( ( SIGN   = GC_I
                                            OPTION = GC_BT
                                            LOW    = SY-DATLO - 30
                                            HIGH   = SY-DATLO ) ).
      ENDIF.
    WHEN OTHERS.
  ENDCASE.

ENDFORM.

*&---------------------------------------------------------------------*
*& FORM GET_DATA
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
FORM GET_DATA .
*ICON_2 ICON_LED_GREEN                 '@5B@'."  GO
*ICON_2 ICON_LED_RED                      '@5C@'."  STOP
*ICON_2 ICON_LED_YELLOW                '@5D@'."  STOP
  CLEAR : GV_EDIT, GV_ERR, GT_LIST, GT_9410, GT_9411, GT_9415.
  DATA : LV_COND TYPE STRING.

  CHECK GV_ERR IS INITIAL.

*공통코드마스터 정보 담아두기
  SELECT FROM ZGTPPT1010
    FIELDS *
    WHERE MODULE_KIND = @GC_MM
         AND CODEGRP = @GC_0830
         AND FLD_01 = @P_WERKS
    INTO CORRESPONDING FIELDS OF TABLE @GT_ZGTPPT1010.
  SORT GT_ZGTPPT1010 BY FLD_01 FLD_02 FLD_03.

  CASE GC_X.
*표준거래명세서(납품문서)
    WHEN P_DNO.
      SELECT DISTINCT A~DELNO, A~DELITEM, A~BUDAT, A~MENGE,
                   A~MEINS, A~WERKS, A~LGORT,
                   A~HSDAT, A~LICHA,
                   Z~EBELN, Z~EBELP, Z~DELCLOSE, Z~DOC_URL,

                   CASE WHEN Z~DOC_URL IS INITIAL THEN NULL
                             ELSE '조회' END AS DOC_TXT,

                   CASE WHEN Z~EBELN = B~EBELN AND Z~EBELP = B~EBELP
                                      AND Z~DELNO = A~DELNO AND Z~DELITEM = A~DELITEM
                            THEN A~MBLNR  ELSE NULL
                   END AS MBLNR,

                   B~ELIKZ,  B~PSTYP, B~VBELN, B~POSNR,
                   C~DPCBT, C~XCHPF, "배치대상자재여부
                   H~LIFNR, H~NAME1,
                   P~MATNR, P~TXZ01, P~INSMK,
                   R~MTART, R~MATKL,
                   W~NAME1 AS WERKS_N,
                   L~LGOBE AS LGORT_N

        FROM ZGTMM_CV_GET_GODELIVERY_DATA AS A

        INNER JOIN ZGTMMT9410 AS Z
                    ON  A~DELNO = Z~DELNO
                   AND A~DELITEM = Z~DELITEM
                   AND A~EBELN = Z~EBELN
                   AND A~EBELP = Z~EBELP
        INNER JOIN  ZGTMM_CV_GET_PODATA_H AS H
                    ON A~EBELN = H~EBELN
        INNER  JOIN  ZGTMM_CV_GET_PODATA_RAW AS B
                    ON B~EBELN = A~EBELN
                   AND B~EBELP = A~EBELP
        INNER JOIN EKKO AS K
                    ON K~EBELN = A~EBELN
        INNER JOIN EKPO AS P
                    ON P~EBELN = A~EBELN
                   AND P~EBELP = A~EBELP
        INNER JOIN MARC AS C
                    ON C~WERKS = B~WERKS
                   AND C~MATNR = B~MATNR
        INNER JOIN MARA AS R
                    ON R~MATNR = B~MATNR
        LEFT OUTER JOIN T001W AS W
                    ON W~WERKS = A~WERKS
        LEFT OUTER JOIN T001L AS L
                    ON L~WERKS = A~WERKS
                   AND L~LGORT = A~LGORT

        WHERE A~WERKS = @P_WERKS
             AND K~EKGRP IN @S_EKGRP
             AND P~MATNR IN @S_MATNR
             AND A~BUDAT IN @S_BUDAT   "납품예정일
             AND H~BUKRS = @P_BUKRS
             AND A~DELNO IN @S_DELNO   "납품문서번호
             AND H~LIFNR IN @S_LIFNR
             AND A~EBELN IN @S_EBELN
             AND B~VBELN IN @S_VBELN
             AND A~STATUS IS INITIAL
             AND Z~DELTYPE = '' "2026.08.06추가_납품서유형

*ZGTMMT9415_OEM 드럼라벨 정보 이력 테이블에 존재하는 구매오더는 제외
*             AND ""배치유형 'C'인 자재만 제외 되도록..->260729_모두 조회되게 주석...
*             NOT EXISTS ( SELECT ZZ~EBELN, ZZ~EBELP
*                                          FROM ZGTMMT9415 AS ZZ
*                                         WHERE A~EBELN = ZZ~EBELN
*                                              AND A~EBELP = ZZ~EBELP
*                                              AND C~DPCBT = 'C'
*                                              AND ZZ~STATUS = '' )

             INTO CORRESPONDING FIELDS OF TABLE @GT_LIST.

      IF GT_LIST[] IS NOT INITIAL.
        SELECT FROM ZGTMM_CV_GET_GODELIVERY_DATA
          FIELDS *
          FOR ALL ENTRIES IN @GT_LIST
          WHERE DELNO = @GT_LIST-DELNO
               AND DELITEM = @GT_LIST-DELITEM
               AND STATUS = @GC_X
          INTO TABLE @GT_DELI_X.
        SORT GT_DELI_X BY DELNO DELITEM.

        SELECT FROM ZGTMMT9411
          FIELDS *
          FOR ALL ENTRIES IN @GT_LIST
          WHERE SYSTEM_ID = @GC_KSRM
               AND DELNO = @GT_LIST-DELNO
               AND DELITEM = @GT_LIST-DELITEM
          INTO CORRESPONDING FIELDS OF TABLE @GT_9411.
        SORT GT_9411 BY DELNO DELITEM LABELNO LABELITEM.

        SELECT FROM ZGTMMT4403
          FIELDS *
          FOR ALL ENTRIES IN @GT_LIST
          WHERE DELNO = @GT_LIST-DELNO
               AND DELITEM = @GT_LIST-DELITEM
          INTO TABLE @GT_4403.
        SORT GT_4403 BY DELNO DELITEM.

****상태 필드 설정 및 데이터 GATHERING
        PERFORM SET_STATUS_DATA CHANGING GT_LIST.
      ENDIF.

*수기거래명세서(구매오더)
    WHEN P_PO.
      SELECT DISTINCT A~EBELN, A~LIFNR, A~NAME1, A~EKGRP,
                   P~EBELP, P~MATNR, P~TXZ01, P~INSMK,
                   B~WERKS, B~LGORT, B~MENGE, B~MEINS,
                   B~ELIKZ, B~LOEKZ, B~UEBTO, B~RETPO,
                   B~PSTYP, B~PTEXT, B~KNTTP, B~KNTTX,
                   B~VBELN, B~POSNR, B~NETWR AS POAMT,
                   B~WAERS,
                   E~SAKTO, E~KOSTL, E~AUFNR, E~ANLN1,
                   E~PS_PSP_PNR,
                   C~DPCBT, C~XCHPF, "배치대상자재여부
                   R~MTART, R~MATKL,
                   S~TXT20 AS GTEXT,  "G/L계정내역
                   T~KTEXT,  "코스트센터내역
                   AN~TXT50, "자산명
                   PR~POST1,  "WBS명
                   W~NAME1 AS WERKS_N,
                   L~LGOBE AS LGORT_N

        FROM ZGTMM_CV_GET_PODATA_H AS A
        INNER JOIN  ZGTMM_CV_GET_PODATA_RAW AS B
                    ON B~EBELN = A~EBELN
        INNER JOIN EKPO AS P
                    ON P~EBELN = B~EBELN
                   AND P~EBELP = B~EBELP
        LEFT OUTER JOIN MARC AS C
                    ON C~WERKS = B~WERKS
                   AND C~MATNR = P~MATNR
        LEFT OUTER JOIN MARA AS R
                    ON R~MATNR = P~MATNR
        LEFT OUTER JOIN EKKN AS E
                    ON E~EBELN = B~EBELN
                  AND E~EBELP = B~EBELP
        LEFT OUTER JOIN SKAT AS S
                    ON S~SAKNR = E~SAKTO
        LEFT OUTER JOIN CSKT AS T
                    ON T~KOSTL = E~KOSTL
                   AND T~SPRAS = @GC_3
                   AND T~KOKRS = @P_BUKRS
        LEFT OUTER JOIN ANLT AS AN
                    ON AN~ANLN1 = E~ANLN1
                   AND AN~BUKRS = @P_BUKRS
                   AND AN~SPRAS = @GC_3
        LEFT OUTER JOIN PRPS AS PR
                     ON PR~PSPNR = E~PS_PSP_PNR
        LEFT OUTER JOIN T001W AS W
                    ON W~WERKS = B~WERKS
        LEFT OUTER JOIN T001L AS L
                    ON L~WERKS = B~WERKS
                   AND L~LGORT = B~LGORT

        WHERE A~BUKRS = @P_BUKRS
             AND A~AEDAT IN @S_AEDAT  "구매오더생성일
             AND A~EKGRP IN @S_EKGRP
             AND B~WERKS = @P_WERKS
             AND A~EBELN IN @S_EBELN
             AND A~LIFNR  IN @S_LIFNR
             AND P~MATNR IN @S_MATNR
             AND B~VBELN IN @S_VBELN
             AND B~LOEKZ IS INITIAL
             INTO CORRESPONDING FIELDS OF TABLE @GT_LIST.

      IF GT_LIST[] IS NOT INITIAL.
        SELECT FROM ZGTMMT9410
        FIELDS *
        WHERE WERKS = @P_WERKS
             AND DELCLOSE IS INITIAL
             INTO TABLE @GT_9410.
        SORT GT_9410 BY EBELN EBELP.

        SELECT FROM ZGTMMT9415
        FIELDS *
        FOR ALL ENTRIES IN @GT_LIST
        WHERE EBELN = @GT_LIST-EBELN
            AND EBELP = @GT_LIST-EBELP
            INTO TABLE @GT_9415.
        SORT GT_9415 BY EBELN EBELP.

        SORT GT_LIST BY EBELN EBELP DESCENDING.

****상태 필드 설정 및 데이터 GATHERING
        PERFORM SET_STATUS_DATA CHANGING GT_LIST.
      ENDIF.

*OEM 드럼라벨(라벨정보)
    WHEN P_LNO.
      SELECT DISTINCT A~EBELN, A~LIFNR, A~NAME1,
                   P~EBELP, P~MATNR, P~TXZ01, P~INSMK,
                   P~LGORT, P~WERKS, "P~ELIKZ,
                   M~ERFMG, M~BUDAT, M~MBLNR,
                   Z20~DELNO, Z20~DELITEM,

                   Z~DR_LABELNO, Z~ERFMG AS MENGE, Z~ERFME AS MEINS,
                   Z~MBLNR AS MBLNR_C, Z~MJAHR, Z~STATUS,
                   C~DPCBT, C~XCHPF, "배치대상자재여부
                   R~MTART, R~MATKL,
                   KN~VBELN, KN~VBELP AS POSNR,
                   W~NAME1 AS WERKS_N,
                   L~LGOBE AS LGORT_N

        FROM ZGTMM_CV_GET_PODATA_H AS A

        INNER JOIN EKPO AS P
                    ON P~EBELN = A~EBELN
*                   AND P~EBELP = B~EBELP
        INNER JOIN ZGTMMT9415 AS Z
                    ON P~EBELN = Z~EBELN
                   AND P~EBELP = Z~EBELP
        INNER JOIN MARC AS C
                    ON C~WERKS = P~WERKS
                   AND C~MATNR = P~MATNR
        INNER JOIN MARA AS R
                    ON R~MATNR = P~MATNR
        LEFT OUTER JOIN EKKN AS KN
                    ON KN~EBELN = P~EBELN
                   AND KN~EBELP = P~EBELP
        LEFT OUTER JOIN ZGTMM_CV_GET_MATDOC AS M
                    ON Z~EBELN = M~EBELN
                   AND Z~EBELP = M~EBELP
                   AND SUBSTRING( Z~DR_LABELNO, 1, 13 )  = M~DELNO
                   AND SUBSTRING( Z~DR_LABELNO, 14, 4 )  = M~DELITEM
                   AND M~MJAHR = @SY-DATLO(4)
        LEFT OUTER JOIN ZGTMMT9420 AS Z20
                    ON Z20~EBELN = Z~EBELN
                   AND Z20~EBELP = Z~EBELP
                   AND Z20~DELNO = M~DELNO
                   AND Z20~DELITEM = M~DELNO
        LEFT OUTER JOIN T001W AS W
                    ON W~WERKS = P~WERKS
        LEFT OUTER JOIN T001L AS L
                    ON L~WERKS = P~WERKS
                   AND L~LGORT = P~LGORT

        WHERE  A~BUKRS = @P_BUKRS
             AND A~AEDAT IN @S_AEDAT  "구매오더생성일
             AND P~LOEKZ IS INITIAL
             AND P~WERKS = @P_WERKS
             AND A~EBELN IN @S_EBELN
             AND A~LIFNR IN @S_LIFNR
             AND Z~DR_LABELNO IN @S_LABEL
             AND Z~STATUS IS INITIAL
             AND ( KN~VBELN IN @S_VBELN OR KN~VBELN IS INITIAL )
             AND C~DPCBT = @GC_C "배치유형 'C'인 자재만 조회 되도록..

             INTO CORRESPONDING FIELDS OF TABLE @GT_LIST.

      IF GT_LIST[] IS NOT INITIAL.
*납품 문서 라벨정보&꼬리표 정보(드럼라벨 제외 대상 설정용)
        ##ITAB_KEY_IN_SELECT
        SELECT Z11~*, ZP~TAGNR
          FROM ZGTMMT9411 AS Z11
          LEFT OUTER JOIN ZPPT0001 AS ZP
          ON   ZP~WERKS = @P_WERKS
          AND ZP~AUFNR = Z11~EBELN
          AND ZP~POSNR = Z11~EBELP

          FOR ALL ENTRIES IN @GT_LIST
          WHERE SYSTEM_ID = @GC_KSRM
               AND Z11~EBELN = @GT_LIST-EBELN
               AND Z11~EBELP = @GT_LIST-EBELP

               INTO CORRESPONDING FIELDS OF TABLE @GT_9411.
*MES 입고수신 이력 점검용
        ##ITAB_KEY_IN_SELECT
        SELECT Z22~ZIFKEY, Z22~SYSTEM_ID,
                     Z22~DR_LABEL_NO, Z22~EBELN, Z22~EBELP,
                     Z23~MBLNR, Z23~MJAHR,
                     Z22~BUDAT,
                     MAT~CANCELLED         AS CANCEL,
                     MAT~REVERSAL_MOVEMENT AS REVERSAL

           FROM ZGTMMT9422 AS Z22
           INNER JOIN ZGTMMT9423 AS Z23
              ON Z23~ZIFKEY    = Z22~ZIFKEY
             AND Z23~SYSTEM_ID = Z22~SYSTEM_ID

           LEFT OUTER JOIN ZGTMM_CV_GET_MATDOC AS MAT
                 ON MAT~MBLNR = Z23~MBLNR
                AND MAT~MJAHR = Z23~MJAHR

           WHERE Z23~MBLNR NE ''
      " 해당 라벨/구매오더별로 자재문서가 있는 것 중 가장 큰 ZIFKEY
               AND Z23~ZIFKEY = ( SELECT MAX( SUB23~ZIFKEY )
                         FROM ZGTMMT9422 AS SUB22
                        INNER JOIN ZGTMMT9423 AS SUB23
                           ON SUB23~ZIFKEY    = SUB22~ZIFKEY
                          AND SUB23~SYSTEM_ID = SUB22~SYSTEM_ID
                        WHERE SUB22~DR_LABEL_NO = Z22~DR_LABEL_NO
                          AND SUB22~EBELN       = Z22~EBELN
                          AND SUB22~EBELP       = Z22~EBELP
                          AND SUB23~MBLNR      NE '' )

               AND EXISTS ( SELECT @ABAP_TRUE
                   FROM @GT_LIST AS ZZ
                  WHERE ZZ~DR_LABELNO = Z22~DR_LABEL_NO
                    AND ZZ~EBELN      = Z22~EBELN
                    AND ZZ~EBELP      = Z22~EBELP )
          INTO CORRESPONDING FIELDS OF TABLE @GT_MES.
        SORT GT_MES BY DR_LABEL_NO EBELN EBELP MBLNR.

*        SELECT MAX( Z22~ZIFKEY ) AS ZIFKEY,
*                     Z22~SYSTEM_ID, Z22~DR_LABEL_NO,
*                     Z22~EBELN, Z22~EBELP,
*                     Z23~MBLNR, Z23~MJAHR,
*                     Z22~BUDAT,
*                     MAT~CANCELLED AS CANCEL,
*                     MAT~REVERSAL_MOVEMENT AS REVERSAL
*
*          FROM ZGTMMT9422 AS Z22
*          INNER JOIN ZGTMMT9423 AS Z23
*          ON   Z22~ZIFKEY = Z23~ZIFKEY
*          AND Z22~SYSTEM_ID = Z23~SYSTEM_ID
*          AND Z23~MBLNR NE ''
*
*          LEFT OUTER JOIN ZGTMM_CV_GET_MATDOC AS MAT
*          ON MAT~MBLNR = Z23~MBLNR
*          AND MAT~MJAHR = Z23~MJAHR
*
*          WHERE  EXISTS ( SELECT @ABAP_TRUE
*                                    FROM @GT_LIST AS ZZ
*                                    WHERE ZZ~DR_LABELNO = Z22~DR_LABEL_NO
*                                        AND ZZ~EBELN = Z22~EBELN
*                                        AND ZZ~EBELP = Z22~EBELP            )
*
*          GROUP BY Z22~SYSTEM_ID, Z22~DR_LABEL_NO, Z22~EBELN, Z22~EBELP,
*                           Z23~MBLNR, Z23~MJAHR, Z22~BUDAT,
*                           MAT~CANCELLED, MAT~REVERSAL_MOVEMENT
*
*          INTO CORRESPONDING FIELDS OF TABLE @GT_MES.
*          SORT GT_MES BY DR_LABEL_NO EBELN EBELP MBLNR.

*ZGTMMT9415_수신 상태 값 체크용
        ##ITAB_KEY_IN_SELECT
        SELECT MAX( Z15~ZIFKEY ) AS ZIFKEY,
                     Z15~SYSTEM_ID, Z15~EBELN ,
                     Z15~EBELP , Z15~DR_LABELNO ,
                     Z15~ERFMG, Z15~ERFME,
                     Z15~MBLNR, Z15~MJAHR , Z15~STATUS

          FROM ZGTMMT9415 AS Z15
          WHERE EXISTS ( SELECT @ABAP_TRUE
                                    FROM @GT_LIST AS ZZ1
                                  WHERE ZZ1~DR_LABELNO = Z15~DR_LABELNO
                                      AND ZZ1~EBELN = Z15~EBELN
                                      AND ZZ1~EBELP = Z15~EBELP            )
*            AND Z15~STATUS IS NOT INITIAL
          GROUP BY Z15~SYSTEM_ID, Z15~EBELN, Z15~EBELP, Z15~DR_LABELNO,
                           Z15~ERFMG, Z15~ERFME, Z15~MBLNR, Z15~MJAHR, Z15~STATUS
          INTO CORRESPONDING FIELDS OF TABLE @GT_ZGTMMT9415.
        SORT GT_ZGTMMT9415 BY DR_LABELNO EBELN EBELP ZIFKEY DESCENDING.

        DELETE ADJACENT DUPLICATES FROM GT_ZGTMMT9415
        COMPARING DR_LABELNO EBELN EBELP.

****상태 필드 설정 및 데이터 GATHERING
        PERFORM SET_STATUS_DATA CHANGING GT_LIST.
      ENDIF.

*표준/수기 명세서 일괄 조회
    WHEN P_DIS.
      PERFORM SELECT_DISP_DATA.

    WHEN OTHERS.
  ENDCASE.

  IF GT_LIST[] IS INITIAL.
    GV_ERR = ZGTFI_X. "조회 조건에 일치하는 정보가 없습니다.
    MESSAGE S000 WITH TEXT-E01. EXIT.
  ENDIF.

  CHECK GV_ERR IS INITIAL.

*처리 상태 조건 기준으로 설정
  IF P_FIN = GC_X. "입고완료
    DELETE GT_LIST WHERE STATUS = ICON_LED_YELLOW.

  ELSEIF P_NFN = GC_X. "미완료
    DELETE GT_LIST WHERE STATUS = ICON_LED_GREEN.
  ENDIF.

  SORT GT_LIST BY DELNO DELITEM EBELN EBELP ASCENDING MBLNR DESCENDING.

  IF P_LNO IS INITIAL.
    DELETE ADJACENT DUPLICATES FROM GT_LIST
    COMPARING DELNO DELITEM EBELN EBELP.
  ENDIF.

  IF GT_LIST[] IS INITIAL.
    GV_ERR = ZGTFI_X. "조회 조건에 일치하는 정보가 없습니다.
    MESSAGE S000 WITH TEXT-E01. EXIT.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*& FORM GET_DATA2
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
FORM GET_DATA2 .

*  CASE GC_X.
*    WHEN P_DNO.   "표준명세서(납품문서)
*
*      SELECT DISTINCT A~DELNO, A~DELITEM, A~BUDAT, A~MENGE,
*                   A~MEINS, A~WERKS, A~LGORT,
*                   A~HSDAT, A~LICHA,
*                   Z~EBELN, Z~EBELP, Z~DELCLOSE, Z~DOC_URL,
*
*                   CASE WHEN Z~DOC_URL IS INITIAL THEN NULL
*                             ELSE '조회' END AS DOC_TXT, "시험성적서 URL
*
*                   CASE WHEN Z~EBELN = B~EBELN AND Z~EBELP = B~EBELP
*                                      AND Z~DELNO = A~DELNO AND Z~DELITEM = A~DELITEM
*                            THEN A~MBLNR  ELSE NULL
*                   END AS MBLNR, "자재문서
*
*                   B~ELIKZ,  C~XCHPF, "배치대상자재여부
*                   H~LIFNR, H~NAME1, P~MATNR, P~TXZ01, P~INSMK,
*                   MD~CANCELLED, MD~REVERSAL_MOVEMENT, MD~ERFMG,
*                   MD~BUDAT AS GR_BUDAT,
*
*                   CASE WHEN A~MBLNR IS INITIAL AND Z~DELCLOSE IS NOT INITIAL
*                            THEN ICON_LED_GREEN
*                            WHEN A~MBLNR IS NOT INITIAL AND MD~CANCELLED IS INITIAL
*                                      AND MD~REVERSAL_MOVEMENT IS INITIAL AND
*                                      ( A~MENGE <= MD~ERFMG )
*                            THEN ICON_LED_GREEN
*                            WHEN A~MBLNR IS NOT INITIAL AND MD~CANCELLED IS INITIAL
*                                      AND MD~REVERSAL_MOVEMENT IS INITIAL
*                                      AND Z~DELCLOSE IS NOT INITIAL AND ( A~MENGE > MD~ERFMG )
*                            THEN ICON_LED_GREEN
*                            ELSE ICON_LED_YELLOW
*                   END AS STATUS
*
*        FROM ZGTMM_CV_GET_GODELIVERY_DATA AS A
*
*        INNER JOIN ZGTMMT9410 AS Z
*                    ON  A~DELNO = Z~DELNO
*                   AND A~DELITEM = Z~DELITEM
*                   AND A~EBELN = Z~EBELN
*                   AND A~EBELP = Z~EBELP
*        INNER JOIN  ZGTMM_CV_GET_PODATA_H AS H
*                    ON A~EBELN = H~EBELN
*        INNER  JOIN  ZGTMM_CV_GET_PODATA_RAW AS B
*                    ON B~EBELN = A~EBELN
*                   AND B~EBELP = A~EBELP
*        INNER JOIN EKPO AS P
*                    ON P~EBELN = A~EBELN
*                   AND P~EBELP = A~EBELP
*        INNER JOIN MARC AS C
*                    ON C~WERKS = B~WERKS
*                   AND C~MATNR = B~MATNR
*        LEFT OUTER JOIN ZGTMM_CV_GET_MATDOC AS MD
*                    ON MD~EBELN = A~EBELN
*                   AND MD~EBELP = A~EBELP
*
*        WHERE A~WERKS = @P_WERKS
*             AND A~BUDAT IN @S_BUDAT   "납품예정일
*             AND H~BUKRS = @P_BUKRS
*             AND A~DELNO IN @S_DELNO   "납품문서번호
*             AND H~LIFNR IN @S_LIFNR
*             AND A~EBELN IN @S_EBELN
*             AND A~STATUS IS INITIAL
*             AND MD~MJAHR EQ @SY-DATLO(4)
*             INTO CORRESPONDING FIELDS OF TABLE @GT_LIST.
*
*
*
*
*
*
*
*    WHEN P_PO.    "수기명세서(구매오더)
*    WHEN P_LNO. "OEM드럼라벨
*  ENDCASE.
*
*
*
*
*
*  SORT GT_LIST BY DELNO DELITEM EBELN EBELP ASCENDING MBLNR DESCENDING.
*  DELETE ADJACENT DUPLICATES FROM GT_LIST
*  COMPARING DELNO DELITEM EBELN EBELP.
*
*  IF GT_LIST[] IS INITIAL.
*    GV_ERR = ZGTFI_X. "조회 조건에 일치하는 정보가 없습니다.
*    MESSAGE S000 WITH TEXT-E01. EXIT.
*  ENDIF.

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
      DEFAULTOPTION  = PV_OPT
      TEXTLINE1      = PV_TEXT1
      TEXTLINE2      = PV_TEXT2
      TITEL          = PV_TITLE
      CANCEL_DISPLAY = ''
    IMPORTING
      ANSWER         = GV_ANSWER.

ENDFORM.                    " POPUP_TO_CONFIRM_STEP

*&---------------------------------------------------------------------*
*& FORM REFRESH_TABLE
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
FORM REFRESH_TABLE USING PO_GRID TYPE REF TO CL_GUI_ALV_GRID
                                               PV_SOFT_REFRESH.

  DATA : LS_STABLE TYPE LVC_S_STBL.

*  CHECK PO_GRID IS BOUND.

  LS_STABLE-ROW = ABAP_TRUE.
  LS_STABLE-COL = ABAP_TRUE.

  CALL METHOD PO_GRID->REFRESH_TABLE_DISPLAY
    EXPORTING
      IS_STABLE = LS_STABLE
*     I_SOFT_REFRESH = PV_SOFT_REFRESH
    EXCEPTIONS
      FINISHED  = 1
      OTHERS    = 2.

ENDFORM.

*&---------------------------------------------------------------------*
*& FORM DATA_CHANGED_FINISHED
*&---------------------------------------------------------------------*
*& TEXT4
*&---------------------------------------------------------------------*
FORM DATA_CHANGED_FINISHED  USING    PV_MODIFIED TYPE CHAR01
                                     PT_GOOD_CELLS TYPE LVC_T_MODI
                                     PO_SENDER.

*  CHECK PV_MODIFIED IS NOT INITIAL.
*  CHECK PO_SENDER <> GCL_GRID.
*
*  CASE PO_SENDER.
*    WHEN GCL_GRID_3.
*      LOOP AT PT_GOOD_CELLS INTO DATA(LS_MOD_CELLS).
*        READ TABLE GT_LIST_3 ASSIGNING FIELD-SYMBOL(<LS_LIST_3>)
*                                     INDEX LS_MOD_CELLS-ROW_ID..
*        CASE LS_MOD_CELLS-FIELDNAME.
*          WHEN 'HKONT'.
*            IF GV_300GB = 1.
*              <LS_LIST_3>-LIMIT_CUR = <LS_LIST_3>-LIMIT / 100.
*
*            ELSE.
*              <LS_LIST_3>-LIMIT_CUR = <LS_LIST_3>-LIMIT / 100.
*              SELECT SINGLE SUM( A~CLAMT )
*                FROM @GT_LIST_2 AS A
*               WHERE A~CHECK IS NOT INITIAL
*                INTO @DATA(LV_CLAMT).
*              IF LV_CLAMT <> 0.
*                LV_CLAMT = LV_CLAMT * <LS_LIST_3>-LIMIT2.
*              ENDIF.
*              <LS_LIST_3>-LIMIT_CUR += LV_CLAMT.
*            ENDIF.
*
*            READ TABLE GT_DD07T INTO DATA(LS_DD07T)
*                                WITH KEY DOMNAME = 'SHKZG'
*                                         DOMVALUE_L = <LS_LIST_3>-SHKZG
*                                         BINARY SEARCH.
*            IF SY-SUBRC = 0.
*              <LS_LIST_3>-SHKZG_TX = LS_DD07T-DDTEXT.
*            ENDIF.
*        ENDCASE.
*      ENDLOOP.
*
*    WHEN OTHERS.
*  ENDCASE.
*
*  PERFORM RECALCULATE_DATA.
*  PERFORM REFRESH_TABLE USING PO_SENDER SPACE.
*
*  CALL METHOD CL_GUI_CFW=>SET_NEW_OK_CODE
*    EXPORTING
*      NEW_CODE = 'ENTER'.


ENDFORM.

*&---------------------------------------------------------------------*
*& FORM SET_CELL_COLOR
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
FORM SET_CELL_COLOR .

*  DATA : LS_COLOR TYPE    LVC_S_SCOL.
*
**  DEFINE _SET_COLOR.
**
**    LS_COLOR-FNAME = &1.
**    LS_COLOR-COLOR-COL = &2.
**    LS_COLOR-COLOR-INT  = &3
**    INSERT LS_STYLE INTO TABLE &4.
**
**  END-OF-DEFINITION.
*
*  LOOP AT GT_LIST ASSIGNING FIELD-SYMBOL(<LS_LIST>).
*
*    CLEAR : <LS_LIST>-COLO[].
*
**입고상태
*    LS_COLOR-FNAME = GC_ZGRSTATUS.
*    LS_COLOR-COLOR-COL = COND #( WHEN <LS_LIST>-ZGRSTATUS_C = GC_C
*                                                           THEN '6'
*                                                           WHEN <LS_LIST>-ZGRSTATUS_C = GC_D
*                                                           THEN '7' ELSE '0' ).
*    LS_COLOR-COLOR-INT   = '1'.
*    INSERT LS_COLOR INTO TABLE <LS_LIST>-COLO.
*
**정산상태
*    CLEAR LS_COLOR.
*
*    CASE <LS_LIST>-ZIVSTATUS_C.
*      WHEN GC_A OR GC_E.
*        LS_COLOR-FNAME = GC_ZIVSTATUS.
*        LS_COLOR-COLOR-COL = '6'.
*        LS_COLOR-COLOR-INT   = '1'.
*        INSERT LS_COLOR INTO TABLE <LS_LIST>-COLO.
*
*      WHEN GC_C OR GC_D.
*        LS_COLOR-FNAME = GC_ZIVSTATUS.
*        LS_COLOR-COLOR-COL = '7'.
*        LS_COLOR-COLOR-INT   = '1'.
*        INSERT LS_COLOR INTO TABLE <LS_LIST>-COLO.
*      WHEN OTHERS.
*    ENDCASE.
*
*  ENDLOOP.

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

  GCL_GRID->SET_READY_FOR_INPUT( 1 ). "입력가능

  LOOP AT GT_LIST ASSIGNING FIELD-SYMBOL(<LS_LIST>).
    CLEAR : <LS_LIST>-STYLE[].

    IF P_DIS = GC_X. "일괄조회는 모두 입력불가
      _SET_STYLE : GC_D 'LGORT' <LS_LIST>-STYLE,"DISABLED
                            GC_D 'ERFMG' <LS_LIST>-STYLE, "DISABLED
                            GC_D 'INSMK' <LS_LIST>-STYLE.   "DISABLED
    ELSE.
*'미완료'상태일 경우에는 변경 가능 필드_'저장위치''
      IF <LS_LIST>-STATUS = ICON_LED_GREEN.
        _SET_STYLE : GC_D 'LGORT' <LS_LIST>-STYLE."DISABLED
      ELSE.
        _SET_STYLE : GC_E 'LGORT' <LS_LIST>-STYLE."ENABLED
      ENDIF.

      IF <LS_LIST>-EDIT IS INITIAL.
        _SET_STYLE : GC_D 'ERFMG' <LS_LIST>-STYLE, "DISABLED
                              GC_D 'INSMK' <LS_LIST>-STYLE.

      ELSE.
        _SET_STYLE : GC_E 'ERFMG' <LS_LIST>-STYLE,"ENABLED
                              GC_E 'INSMK' <LS_LIST>-STYLE.
      ENDIF.

    ENDIF.

  ENDLOOP.


ENDFORM.

*&---------------------------------------------------------------------*
*& FORM SET_ALV_FIELDCAT
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
FORM SET_ALV_FIELDCAT USING PV_GUBUN.

  DATA :
    LR_TABDESCR TYPE REF TO CL_ABAP_STRUCTDESCR,
    LT_DFIES    TYPE DDFIELDS,
    LS_DFIES    TYPE DFIES,
    LT_FCAT     TYPE LVC_T_FCAT,
    LS_FCAT     TYPE LVC_S_FCAT.

  DATA : GR_DREF  TYPE REF TO DATA.

  CLEAR GR_DREF.
  CREATE DATA GR_DREF LIKE GS_LIST.

  CASE PV_GUBUN.
    WHEN '100'.
      CREATE DATA GR_DREF LIKE GS_LIST.

    WHEN '300'.
      CREATE DATA GR_DREF LIKE GS_LIST_LABEL.

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
  IF PV_GUBUN = '100'.
    PERFORM ADJUST_FLDCATS TABLES LT_FCAT.
  ELSE.
    PERFORM ADJUST_FLDCATS_300 TABLES LT_FCAT.
  ENDIF.


ENDFORM.

*&---------------------------------------------------------------------*
*& FORM TOOLBAR
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
FORM TOOLBAR  USING PR_OBJ TYPE REF TO CL_ALV_EVENT_TOOLBAR_SET
                                     PO_SENDER.

*  DATA : LS_TBAR TYPE STB_BUTTON.
*
*  DEFINE _SET_TBAR.
*    CLEAR : LS_TBAR.
*
*    LS_TBAR-BUTN_TYPE = &1.
*    LS_TBAR-FUNCTION   = &2.
*    LS_TBAR-ICON           = &3.
*    LS_TBAR-TEXT          = &4.
*    LS_TBAR-QUICKINFO = &4.
*
*    APPEND LS_TBAR TO PR_OBJ->MT_TOOLBAR.
*  END-OF-DEFINITION.
*
*
*  CASE PO_SENDER.
*
*    WHEN GCL_GRID.
*      _SET_TBAR 3 '    ' '              ' '    '.
*      _SET_TBAR 0 'REFRESH' '' 'REFRESH'(B01).
*      _SET_TBAR 0 'FINISH'  ''   '발주종료'(B02).
*      _SET_TBAR 0 'UNFIN' ''  '발주종료해제'(B03).
*      _SET_TBAR 0 'REQUEST' ''  '승인요청'(B04).
*
*    WHEN OTHERS.
*
*  ENDCASE.

ENDFORM.

*&---------------------------------------------------------------------*
*& FORM USER_COMMAND
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
FORM USER_COMMAND  USING PV_UCOMM LIKE SY-UCOMM.

*  CLEAR : GV_REF.
*
*  CASE PV_UCOMM.
*    WHEN 'REFRESH'.
*      PERFORM GET_DATA.
*
*    WHEN 'FINISH'.
*      PERFORM ORDER_FINISH_DATA USING 'F'.
*
*    WHEN 'UNFIN'.
*      PERFORM ORDER_FINISH_DATA USING 'R'.
*
*    WHEN 'REQUEST'.
*      PERFORM REQUEST_DATA.
*  ENDCASE.
*
*  PERFORM REFRESH_TABLE USING GCL_GRID SPACE.

ENDFORM.

*&---------------------------------------------------------------------*
*& FORM DATA_CHANGED
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
FORM DATA_CHANGED  USING  PO_DATA_CHANGED
                                     TYPE REF TO CL_ALV_CHANGED_DATA_PROTOCOL
                                                PO_SENDER.

  DATA : LS_LABEL LIKE GS_LIST_LABEL,
         LV_ERR   TYPE CHAR1,
         LV_TYPE  TYPE DD01V-DATATYPE,
         LV_MENGE TYPE MENGE_D.

  CASE PO_SENDER.

    WHEN GCL_GRID.
      PERFORM DATA_CHANGED_1 USING PO_DATA_CHANGED.

    WHEN GCL_GRID_300.
      PERFORM DATA_CHANGED_3 USING PO_DATA_CHANGED.

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

  DATA : LV_ERR   TYPE CHAR1,
         LV_MENGE TYPE MENGE_D.

  LOOP AT PO_DATA_CHANGED->MT_GOOD_CELLS INTO DATA(LS_MOD_CELLS).

    READ TABLE GT_LIST  INTO DATA(LS_LIST) INDEX LS_MOD_CELLS-ROW_ID.
    CHECK SY-SUBRC EQ 0.

    CASE LS_MOD_CELLS-FIELDNAME.

      WHEN 'ERFMG'.

        PERFORM MODIFY_CELL USING PO_DATA_CHANGED 'ERFMG'
                                                        LS_MOD_CELLS-VALUE LS_MOD_CELLS-ROW_ID.
        IF LS_MOD_CELLS-VALUE IS NOT INITIAL.
          CONDENSE LS_MOD_CELLS-VALUE.
**          입고허용수량
*          LV_MENGE = LS_LIST-MENGE + ( LS_LIST-MENGE * ( LS_LIST-UEBTO / 100 ) ).
*       기존 계산된 입고허용수량 - (입력한)입고수량
          LS_LIST-REMAIN_QTY = LS_LIST-REMAIN_QTY - LS_MOD_CELLS-VALUE.
        ENDIF.

      WHEN 'LGORT'.
        PERFORM MODIFY_CELL USING PO_DATA_CHANGED 'LGORT'
                                                        LS_MOD_CELLS-VALUE LS_MOD_CELLS-ROW_ID.
        IF LS_MOD_CELLS-VALUE IS INITIAL.
          CLEAR LS_LIST-NAME1.

        ELSE.
          SELECT SINGLE  LGOBE
             FROM T001L
             WHERE WERKS = @P_WERKS
                  AND LGORT = @LS_MOD_CELLS-VALUE
             INTO  @DATA(LV_NAME).

          IF LV_NAME IS INITIAL.
            LV_ERR = GC_X.
            PERFORM ADD_ENTRY USING PO_DATA_CHANGED 'LGORT'
                                                         LS_MOD_CELLS-ROW_ID.
          ELSE.
            LS_LIST-LGORT_N = LV_NAME.
          ENDIF.
        ENDIF.

      WHEN OTHERS.
    ENDCASE.

    MODIFY GT_LIST FROM LS_LIST INDEX LS_MOD_CELLS-ROW_ID.
  ENDLOOP.

  PERFORM REFRESH_TABLE USING GCL_GRID SPACE.

  IF LV_ERR IS NOT INITIAL.
    CALL METHOD PO_DATA_CHANGED->DISPLAY_PROTOCOL.
  ENDIF.

ENDFORM. " DATA_CHANGED_1

*&---------------------------------------------------------------------*
*&      FORM  DATA_CHANGED_3
*&---------------------------------------------------------------------*
*       TEXT
*----------------------------------------------------------------------*
*      -->P_PO_DATA_CHANGED  TEXT
*----------------------------------------------------------------------*
FORM DATA_CHANGED_3 USING PO_DATA_CHANGED
                                          TYPE REF TO CL_ALV_CHANGED_DATA_PROTOCOL.

  DATA : LS_LABEL LIKE GS_LIST_LABEL,
         LV_MENGE TYPE MENGE_D.

  LOOP AT PO_DATA_CHANGED->MT_GOOD_CELLS INTO DATA(LS_MOD_CELLS).

    IF LS_MOD_CELLS-FIELDNAME = 'CHECK'.
*      DATA(LV_TABIX) = SY-TABIX.

      READ TABLE GT_LIST_LABEL  INTO DATA(LS_LIST) INDEX LS_MOD_CELLS-ROW_ID.
      CHECK SY-SUBRC EQ 0.

      LS_LABEL = CORRESPONDING #( LS_LIST ).
*BAPI 수행 시 필요한 정보이므로 별도 저장.
      APPEND LS_LIST TO GT_LIST_300.
      "라벨 별 포장수량 합산(납품번호/품목 기준)
      IF LS_MOD_CELLS-VALUE IS INITIAL.
        GV_MENGE = GV_MENGE - LS_LIST-PKG_QTY.
      ELSE.
        GV_MENGE = GV_MENGE + LS_LIST-PKG_QTY.
      ENDIF.

      CLEAR LS_LIST.
    ENDIF.
  ENDLOOP.

  IF LS_LABEL IS NOT INITIAL.
*메인 ALV의 납품번호/품목에 수량 업데이트.
    SORT GT_LIST BY DELNO DELITEM.
    READ TABLE GT_LIST ASSIGNING FIELD-SYMBOL(<FS>)
    WITH KEY DELNO   = LS_LABEL-DELNO
                   DELITEM = LS_LABEL-DELITEM BINARY SEARCH.
    IF SY-SUBRC = 0.
      IF <FS>-STATUS = ICON_LED_GREEN.
        MESSAGE S000 WITH TEXT-E16. EXIT."이미 입고완료된 대상이므로 입고 수량 변경 할 수 없습니다.
      ELSE.
        <FS>-ERFMG = COND #( WHEN <FS>-ERFMG = 0 THEN  GV_MENGE
                                              WHEN <FS>-ERFMG > 0 AND GV_MENGE NE <FS>-ERFMG
                                              THEN GV_MENGE ELSE <FS>-ERFMG ).
      ENDIF.
    ENDIF.
    CLEAR LS_LABEL.
  ENDIF.

  PERFORM REFRESH_TABLE USING GCL_GRID_300 SPACE.


ENDFORM. " DATA_CHANGED_3

*&---------------------------------------------------------------------*
*& FORM MODIFY_CELL
*&---------------------------------------------------------------------*
*& TEXT
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
      I_ROW_ID    = PV_INDEX
      I_FIELDNAME = PV_FNAME
      I_VALUE     = PV_FVAL.

ENDFORM.

*&---------------------------------------------------------------------*
*& FORM ADD_ENTRY
*&---------------------------------------------------------------------*
*& TEXT
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
      I_MSGNO     = '013'
      I_MSGV1     = PV_FNAME
      I_MSGTY     = ZGTFI_E
      I_FIELDNAME = PV_FNAME
      I_ROW_ID    = PV_INDEX.

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

      IF PS_COLUMN-FIELDNAME = 'MBLNR'.
        CHECK LS_LIST-MBLNR IS NOT INITIAL.
        PERFORM CALL_MIGO USING LS_LIST-MBLNR  LS_LIST-MJAHR.
      ENDIF.

      IF PS_COLUMN-FIELDNAME = 'EBELN'.
        CHECK LS_LIST-EBELN IS NOT INITIAL.
        SET PARAMETER ID 'BES' FIELD LS_LIST-EBELN.
        CALL TRANSACTION 'ME23N' AND SKIP FIRST SCREEN.
      ENDIF.

      IF PS_COLUMN-FIELDNAME = 'DOC_TXT'.
        CHECK LS_LIST-DOC_URL IS NOT INITIAL.
        PERFORM SET_URL_DISPLAY USING LS_LIST-DOC_URL.
*        PERFORM SET_HTML_URL_DISPLAY USING LS_LIST-DOC_URL.
      ENDIF.

  ENDCASE.

ENDFORM.

**&---------------------------------------------------------------------*
**&      FORM  ON_F4
**&---------------------------------------------------------------------*
FORM ON_F4  USING E_FIELDNAME    TYPE LVC_FNAME
                  E_FIELDVALUE   TYPE LVC_VALUE
                  ES_ROW_NO      TYPE LVC_S_ROID
                  ER_EVENT_DATA  TYPE REF TO CL_ALV_EVENT_DATA
                  ET_BAD_CELLS   TYPE LVC_T_MODI
                  E_DISPLAY      TYPE CHAR01.

  DATA :
    LT_RETURN TYPE TABLE OF DDSHRETVAL,
    LS_RETURN TYPE DDSHRETVAL,
    LS_MODI   TYPE LVC_S_MODI.

  FIELD-SYMBOLS : <F4TAB> TYPE LVC_T_MODI.
  ASSIGN ER_EVENT_DATA->M_DATA->* TO <F4TAB>.

* TO AVOID STANDARD F4-HELP.
  ER_EVENT_DATA->M_EVENT_HANDLED = 'X'.

  CLEAR : LS_RETURN, LT_RETURN.

  IF E_FIELDNAME = 'LGORT'.

    SELECT LGORT, LGOBE
     FROM T001L
     WHERE WERKS = @P_WERKS
     INTO TABLE @DATA(LT_T001L).

    CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
      EXPORTING
        RETFIELD   = 'LGORT'
        VALUE_ORG  = 'S'
      TABLES
        VALUE_TAB  = LT_T001L
        RETURN_TAB = LT_RETURN.
    IF SY-SUBRC <> 0.
      MESSAGE S000 WITH 'POSSIBLE ENTRY DATA가 없습니다 !!!'.
    ENDIF.

    IF SY-SUBRC = 0 AND LT_RETURN IS NOT INITIAL.
      READ TABLE LT_RETURN INTO LS_RETURN INDEX 1.

      CLEAR : LS_MODI.
      LS_MODI-ROW_ID      = ES_ROW_NO-ROW_ID.
      LS_MODI-FIELDNAME = 'LGORT'.
      LS_MODI-VALUE        = LS_RETURN-FIELDVAL.
      APPEND LS_MODI TO <F4TAB>.
    ENDIF.

*  ELSEIF E_FIELDNAME = 'MWSKZ'.
**"데이터 추출 (KALSM = 'TAXKR' 필터 및 텍스트 조인)
*    SELECT A~KALSM, A~MWSKZ, S~TEXT1
*      FROM T007A AS A
*      LEFT JOIN T007S AS S ON A~KALSM  = S~KALSM
*                                      AND A~MWSKZ = S~MWSKZ
*                                      AND S~SPRAS  = @SY-LANGU
*      WHERE A~KALSM = @GC_TAXKR
*      INTO TABLE @DATA(LT_TEMP).
*
**F4 HELP 호출
*    CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
*      EXPORTING
*        RETFIELD        = 'MWSKZ'         " 내부 테이블에서 가져올 필드명
*        WINDOW_TITLE    = '세금 코드 선택'
*        VALUE_ORG       = 'S'
*      TABLES
*        VALUE_TAB       = LT_TEMP       " 데이터가 담긴 ITAB
*        RETURN_TAB      = LT_RETURN   " 사용자가 선택한 행의 정보가 담김
*      EXCEPTIONS
*        PARAMETER_ERROR = 1
*        NO_VALUES_FOUND = 2
*        OTHERS          = 3.
*
*    IF SY-SUBRC <> 0.
*      MESSAGE S000 WITH 'POSSIBLE ENTRY DATA가 없습니다 !!!'.
*    ENDIF.
*
*    IF SY-SUBRC = 0 AND LT_RETURN IS NOT INITIAL.
*      READ TABLE LT_RETURN INTO LS_RETURN INDEX 1.
*
*      CLEAR : LS_MODI.
*      LS_MODI-ROW_ID      = ES_ROW_NO-ROW_ID.
*      LS_MODI-FIELDNAME =  'MWSKZ' .
*      LS_MODI-VALUE        = LS_RETURN-FIELDVAL.
*      APPEND LS_MODI TO <F4TAB>.
*    ENDIF.
*
*  ELSEIF E_FIELDNAME = 'EMLIF' OR E_FIELDNAME = 'FLIEF' OR E_FIELDNAME = 'LIFNR'.
*
*    SELECT A~LIFNR, A~NAME1
*      FROM LFA1 AS A  INNER JOIN LFB1 AS B
*      ON A~LIFNR = B~LIFNR
*      WHERE B~BUKRS = @P_BUKRS
*      INTO TABLE @DATA(LT_LIFNR).
*
*    CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
*      EXPORTING
*        RETFIELD   = 'LIFNR'
*        VALUE_ORG  = 'S'
*      TABLES
*        VALUE_TAB  = LT_LIFNR
*        RETURN_TAB = LT_RETURN.
*    IF SY-SUBRC <> 0.
*      MESSAGE S000 WITH 'POSSIBLE ENTRY DATA가 없습니다 !!!'.
*    ENDIF.
*
*    IF SY-SUBRC = 0 AND LT_RETURN IS NOT INITIAL.
*      READ TABLE LT_RETURN INTO LS_RETURN INDEX 1.
*
*      CLEAR : LS_MODI.
*      LS_MODI-ROW_ID      = ES_ROW_NO-ROW_ID.
*      LS_MODI-FIELDNAME = E_FIELDNAME.
*      LS_MODI-VALUE        = LS_RETURN-FIELDVAL.
*      APPEND LS_MODI TO <F4TAB>.
*    ENDIF.

  ENDIF.

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
*& FORM LABEL_INFO_SELECT
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
*& -->  P1        TEXT
*& <--  P2        TEXT
*&---------------------------------------------------------------------*
FORM LABEL_INFO_SELECT .

  DATA : LS_LIST LIKE GS_LIST_LABEL,
         LT_MES  TYPE TABLE OF TY_MES.
  CLEAR : GV_MENGE.

  PERFORM GET_SELECTED_ROWS USING GCL_GRID.
  READ TABLE GT_ROWS INTO DATA(LS_ROW) INDEX 1.

  IF SY-SUBRC = 0.

    READ TABLE GT_LIST ASSIGNING FIELD-SYMBOL(<FS>) INDEX LS_ROW-INDEX.

    IF <FS> IS ASSIGNED.
      CLEAR GT_LIST_LABEL.
*MES 입고 수신 이력 가져오기-라벨 별 입고여부 판단기준
      SELECT   Z20~ZIFKEY, Z20~SYSTEM_ID,
                     Z20~EBELN, Z20~EBELP,
                     Z21~MBLNR, Z21~MJAHR,
                     Z20~BUDAT, Z20~DELNO, Z20~DELITEM,
                     Z20~LABELNO, Z20~LABELITEM,
                     MAT~CANCELLED AS CANCEL,
                     MAT~REVERSAL_MOVEMENT AS REVERSAL

          FROM ZGTMMT9420 AS Z20
          INNER JOIN ZGTMMT9421 AS Z21
          ON   Z20~ZIFKEY = Z21~ZIFKEY
          AND Z20~SYSTEM_ID = Z21~SYSTEM_ID
          LEFT OUTER JOIN ZGTMM_CV_GET_MATDOC AS MAT
          ON MAT~MBLNR = Z21~MBLNR
          AND MAT~MJAHR = Z21~MJAHR

          WHERE Z20~EBELN = @<FS>-EBELN
               AND Z20~EBELP = @<FS>-EBELP
               AND Z20~DELNO = @<FS>-DELNO
               AND Z20~DELITEM = @<FS>-DELITEM

          ORDER BY Z20~EBELN, Z20~EBELP, Z20~DELNO, Z20~DELITEM ,
                          Z20~LABELNO, Z20~LABELITEM, Z20~ZIFKEY DESCENDING
          INTO CORRESPONDING FIELDS OF TABLE @LT_MES.

*라벨정보 유무 체크
      READ TABLE GT_9411 INTO DATA(LS_9411)
      WITH KEY DELNO   = <FS>-DELNO
                     DELITEM = <FS>-DELITEM BINARY SEARCH.
      IF SY-SUBRC = 0.
        DATA(LV_TABIX) = SY-TABIX.
        CLEAR LS_9411.

        LOOP AT GT_9411 INTO LS_9411 FROM LV_TABIX.
          IF LS_9411-DELNO = <FS>-DELNO AND LS_9411-DELITEM = <FS>-DELITEM.

            LS_LIST = CORRESPONDING #( LS_9411 ).
*입고여부 설정_MES입고이력테이블에 자재문서 존재하면(취소되지 않은 자재문서만), 입고완료(X)/없으면 미완료.
            READ TABLE LT_MES ASSIGNING FIELD-SYMBOL(<MES>)
            WITH KEY EBELN  = <FS>-EBELN
                           EBELP   = <FS>-EBELP
                           DELNO   = <FS>-DELNO
                           DELITEM = <FS>-DELITEM
                           LABELNO = LS_9411-LABELNO
                           LABELITEM = LS_9411-LABELITEM BINARY SEARCH.
            IF SY-SUBRC = 0.
              LS_LIST-GRSTATUS = COND #( WHEN <MES>-MBLNR IS INITIAL THEN SPACE
                                                             WHEN <MES>-MBLNR IS NOT INITIAL AND
                                                             ( <MES>-CANCEL = GC_X OR <MES>-REVERSAL = GC_X )
                                                             THEN SPACE ELSE GC_X ).
            ELSE.
              CLEAR LS_LIST-GRSTATUS.
            ENDIF.

            APPEND LS_LIST TO GT_LIST_LABEL.
          ENDIF.

          CLEAR :  LS_9411, LS_LIST.
        ENDLOOP.

      ELSE.
        GV_ERR = GC_X. "라벨정보가 없습니다.
        MESSAGE S000 WITH TEXT-E10 DISPLAY LIKE 'E'.   EXIT.
      ENDIF.

      CHECK GV_ERR IS INITIAL.

      IF GT_LIST_LABEL[] IS NOT INITIAL.
        SORT GT_LIST_LABEL BY ZIFKEY DESCENDING.
*최신 수신 정보 기준으로 보여줌.
        READ TABLE GT_LIST_LABEL INTO DATA(LS_1) INDEX 1.
        IF SY-SUBRC = 0 .
          DELETE GT_LIST_LABEL WHERE ZIFKEY NE LS_1-ZIFKEY.
        ENDIF.

        CALL SCREEN 0300 STARTING AT 5 10.
      ENDIF.

    ENDIF.
  ENDIF.


ENDFORM.
*&---------------------------------------------------------------------*
*& FORM EXCUTE_GR
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
*& -->  P1        TEXT
*& <--  P2        TEXT
*&---------------------------------------------------------------------*
FORM EXCUTE_GR USING PV_GB.

  DATA : LT_LIST      LIKE TABLE OF GS_LIST,
         LV_DPCBT_OLD TYPE MARC-DPCBT,
         LV_DRUM      TYPE ZGTMM_CV_PO_VCVALUE_MAIN-DRUM.

  CLEAR : GV_BUDAT, GV_TEXT, GV_ANSWER, GV_ERR, LV_DPCBT_OLD,
               GT_LIST_C, GT_LIST_S.

  PERFORM GET_SELECTED_ROWS USING GCL_GRID.
  CHECK GV_ERR IS INITIAL.

  SORT GT_LIST_300 BY DELNO DELITEM LABELNO LABELITEM.

  LOOP AT GT_ROWS INTO GS_ROW.
    DATA(LV_TABIX) = SY-TABIX.

    READ TABLE GT_LIST  INTO DATA(LS_LIST) INDEX GS_ROW-INDEX.
    IF SY-SUBRC = 0.

      CASE PV_GB.
        WHEN 'GR'.
          IF LS_LIST-STATUS = ICON_LED_GREEN.
            MESSAGE S000 WITH TEXT-E06 DISPLAY LIKE GC_E. "처리 상태를 확인하세요.
            GV_ERR = GC_X. EXIT.

          ELSE.
*            SELECT SINGLE MTART, MATKL
*              FROM MARA
*              WHERE MATNR = @LS_LIST-MATNR
*              INTO (@DATA(LV_MTART), @DATA(LV_MATKL)).

*            IF LV_MTART NE GC_HIBE AND LS_LIST-LGORT IS INITIAL.
            IF LS_LIST-MTART NE GC_HIBE AND LS_LIST-LGORT IS INITIAL.
              MESSAGE S000 WITH TEXT-E12 DISPLAY LIKE GC_E.
              GV_ERR = GC_X. EXIT."저장위치가 누락되었습니다. 구매오더에서 저장위치를 입력하세요.
            ENDIF.

*공통마스터에 존재하는 자재그룹인 경우 납품문서 점검 조건에서 제외(수기거래명세서만)_260728.
            READ TABLE GT_ZGTPPT1010 TRANSPORTING NO FIELDS
            WITH KEY FLD_01 = LS_LIST-WERKS
                           FLD_02 = LS_LIST-MATKL BINARY SEARCH.
            IF SY-SUBRC = 0.
              "점검통과(입고가능)
            ELSE.
              IF P_PO = GC_X AND  LS_LIST-XCHPF = GC_X .
                IF LS_LIST-MTART = 'MCHA' OR LS_LIST-MTART = 'MCFE'
                                  OR LS_LIST-MTART = 'HAWA'.
                  "MCHA/MCFE/HAWA는 점검통과(입고가능)
                ELSE.
                  GV_ERR = GC_X.
                  MESSAGE S000 WITH TEXT-E15 DISPLAY LIKE GC_E. "
                  EXIT. "배치관리대상 자재이므로 납품문서 정보를 확인하세요.
                ENDIF.
              ENDIF.
            ENDIF.

*            IF P_DNO = GC_X AND  LS_LIST-XCHPF = GC_X AND LS_LIST-ERFMG IS INITIAL.
*              GV_ERR = COND #( WHEN ( LS_LIST-MTART = 'MCHA' OR LS_LIST-MTART = 'MCFE'
*                                                      OR LS_LIST-MTART = 'HAWA' )
*                                            THEN '' ELSE GC_X ).
*
*              IF GV_ERR = GC_X.
*                MESSAGE S000 WITH TEXT-E05 DISPLAY LIKE GC_E. EXIT.
*              ENDIF."라벨정보와 수량을 확인하세요.
*            ENDIF.

*표준거래명세서_점검
            IF P_DNO = GC_X.
*            " 자재유형 MCFE / MCHA / HAWA -배치재고 입고수량 미입력 에러_점검통과
              IF LS_LIST-XCHPF = GC_X AND LS_LIST-ERFMG IS INITIAL.
                GV_ERR = COND #( WHEN ( LS_LIST-MTART = 'MCHA' OR LS_LIST-MTART = 'MCFE'
                                                      OR LS_LIST-MTART = 'HAWA' )
                                            THEN '' ELSE GC_X ).

                IF GV_ERR = GC_X.
                  MESSAGE S000 WITH TEXT-E05 DISPLAY LIKE GC_E. EXIT.
                ENDIF."라벨정보와 수량을 확인하세요.
              ENDIF.

              "<-- 2026.07.10 점검 로직 추가
              " 자재유형 MCFE / MCHA / HAWA & 저장위치 <>3497 &  DPCBT  <> A
              SELECT SINGLE DPCBT
                FROM MARC
                WHERE MATNR EQ @LS_LIST-MATNR
                AND WERKS EQ @LS_LIST-WERKS
                INTO @DATA(LV_DPCBT).

              LV_DPCBT_OLD = COND #( WHEN LV_TABIX = 1 THEN LV_DPCBT ELSE LV_DPCBT_OLD ).

              IF LV_DPCBT_OLD NE LV_DPCBT.
                MESSAGE S000 WITH TEXT-E17 DISPLAY LIKE GC_E. "동일한 배치유형 자재만 일괄 처리 가능합니다.
                GV_ERR = GC_X. EXIT.
              ENDIF.

              IF LV_DPCBT NE GC_A AND LS_LIST-LGORT NE '3497' AND LS_LIST-LGORT NE '3498'
                AND ( LS_LIST-MTART EQ 'MCFE' OR LS_LIST-MTART EQ 'MCHA' OR LS_LIST-MTART EQ 'HAWA' ).
*26.09.23 다발류(특성 PD_GA_DRUM_GUBUN = 'COIL')는 라벨 미발행
*-> 라벨 선택 점검 제외(라벨정보 없는 대상 로직으로 조장단위 분할입고)
                CLEAR LV_DRUM.
                SELECT SINGLE DRUM
                  FROM ZGTMM_CV_PO_VCVALUE_MAIN
                  WHERE PDOC     = @LS_LIST-EBELN
                    AND PDOCITEM = @LS_LIST-EBELP
                  INTO @LV_DRUM.

                IF TO_UPPER( LV_DRUM ) = 'COIL'.
                  CLEAR GV_ERR.
                ELSE.
*FACTOR BATCH 아닌 자재는 라벨정보 선택했는지 체크 후 없으면,에러처리.
                  READ TABLE GT_LIST_300 TRANSPORTING NO FIELDS
                  WITH KEY DELNO = LS_LIST-DELNO
                                 DELITEM = LS_LIST-DELITEM BINARY SEARCH.
                  IF SY-SUBRC = 0.
                    CLEAR GV_ERR.
                  ELSE.
                    GV_ERR = GC_X.
                  ENDIF.
                ENDIF.
              ENDIF.

              IF GV_ERR = GC_X.
                MESSAGE S000 WITH TEXT-E11 DISPLAY LIKE GC_E. EXIT.
              ENDIF."라벨정보와 수량을 확인하세요.

            ENDIF.
            "--> 2026.07.10 점검 로직 추가

            IF LS_LIST-ERFMG IS INITIAL.
              MESSAGE S000 WITH TEXT-E04 DISPLAY LIKE GC_E. "처리 수량을 입력하세요.
              GV_ERR = GC_X. EXIT.
            ENDIF.
          ENDIF.

          CHECK GV_ERR IS INITIAL.
          APPEND LS_LIST TO GT_LIST_S.

        WHEN 'GR_CANC'.
          IF LS_LIST-STATUS = ICON_LED_GREEN OR LS_LIST-MBLNR IS NOT INITIAL.

            IF LS_LIST-DELCLOSE = GC_X.
              CLEAR : GV_BUDAT, GT_LIST_C.  GV_ERR = GC_X. "이미 종결된 납품문서 입니다.
              MESSAGE S000 WITH TEXT-E13 DISPLAY LIKE GC_E. EXIT.
            ENDIF.

            IF GT_LIST_C[] IS INITIAL.
              APPEND LS_LIST TO GT_LIST_C.

            ELSE.
              READ TABLE GT_LIST_C ASSIGNING FIELD-SYMBOL(<FS>) INDEX 1.
              IF <FS>-MBLNR = LS_LIST-MBLNR.
                APPEND LS_LIST TO GT_LIST_C.

              ELSE.
                CLEAR : GV_BUDAT, GT_LIST_C.  GV_ERR = GC_X. "동일한 자재문서만 처리 가능합니다.
                MESSAGE S000 WITH TEXT-E09 DISPLAY LIKE GC_E. EXIT.
              ENDIF.
            ENDIF.

            GV_BUDAT = COND #( WHEN GV_ERR IS INITIAL THEN LS_LIST-GRBUDAT ELSE '' ).

          ELSE.
            MESSAGE S000 WITH TEXT-E08 DISPLAY LIKE GC_E. "입고 처리 되지 않은 정보입니다.
            GV_ERR = GC_X. EXIT.
          ENDIF.

        WHEN OTHERS.
      ENDCASE.

    ENDIF.
  ENDLOOP.

  CHECK GV_ERR IS INITIAL.
  CLEAR GV_QUES.

  CASE PV_GB.
    WHEN 'GR'.
*DPCBT = 'C'인 자재가 있는 경우, 팝업 체크_'확인''클릭 시 입고 전기일자 팝업 진행..
      IF LINE_EXISTS( GT_LIST_S[ DPCBT = 'C' ] ).
        PERFORM POPUP_TO_CONFIRM_STEP  USING 'N' TEXT-M22 TEXT-M08 TEXT-T04.
*    라벨 스캔 입고 대상 품목이 포함되어 있습니다. "입고 처리 하시겠습니까?
        CHECK GV_ANSWER = ZGTFI_J.
      ENDIF.

      GV_BUDAT = SY-DATUM.
      GV_QUES = '입고 처리 하시겠습니까?'(M17).

    WHEN 'GR_CANC'.
      GV_QUES = '입고 취소 처리 하시겠습니까?'(M18).

    WHEN OTHERS.
  ENDCASE.

*전기일자 입력 팝업 후 입고/입고취소 처리
  CALL SCREEN 0200 STARTING AT 5 15.

ENDFORM.
*&---------------------------------------------------------------------*
*& FORM GET_SELECTED_ROWS
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
*&      --> GR_GRID
*&      --> P_
*&      --> P_
*&      --> P_
*&---------------------------------------------------------------------*
FORM GET_SELECTED_ROWS USING PR_GRID TYPE REF TO CL_GUI_ALV_GRID.

  CLEAR : GT_ROWS, GS_ROW, GV_ERR.

  CALL METHOD PR_GRID->GET_SELECTED_ROWS
    IMPORTING
      ET_INDEX_ROWS = GT_ROWS.

  DESCRIBE TABLE GT_ROWS.

  IF SY-TFILL = 0.
    GV_ERR = GC_X.
    MESSAGE S004 DISPLAY LIKE GC_E. "라인을 선택하세요.

  ELSEIF SY-TFILL > 1.
    GV_ERR = COND #( WHEN GV_OKCODE_SAVE = 'LABEL' THEN GC_X ELSE '' ).
    IF GV_ERR = GC_X.
      MESSAGE S005 DISPLAY LIKE GC_E. "하나의 라인만 선택 가능합니다.
    ENDIF.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& FORM SET_BAPI_DATA
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
*& -->  P1        TEXT
*& <--  P2        TEXT
*&---------------------------------------------------------------------*
FORM SET_BAPI_DATA .

  DATA : LT_LIST   LIKE TABLE OF GS_LIST,
         LS_HEAD   TYPE BAPI2017_GM_HEAD_01,
         LT_ITEM   TYPE TABLE OF BAPI2017_GM_ITEM_CREATE,
         LV_CODE   TYPE BAPI2017_GM_CODE-GM_CODE,
         LV_DOC    TYPE BAPI2017_GM_HEAD_RET-MAT_DOC,
         LS_BATCH  TYPE BAPIBATCHATT,
         LS_BATCHX TYPE BAPIBATCHATTX,
         LV_MSG    TYPE BAPI_MSG.

  DATA:
    LV_CHECK      TYPE C LENGTH 1,
    LT_RESB       TYPE TY_T_PO_RESB,
    LT_DELCOMP    TYPE TY_T_PO_DELCOMP,
    LT_DISPO      TYPE TY_T_PO_DISPO,
    LT_MSLB       TYPE TY_T_MSLB,
    LT_VCQTY      TYPE TY_T_VC,
    LT_ZGTMMT9450 TYPE TY_T_ZGTMMT9450.

  CLEAR : LV_MSG, GV_ERR.
***입고처리
  SORT GT_LIST BY DELNO DELITEM EBELN EBELP.
  SORT GT_LIST_S BY DELNO DELITEM.
  SORT GT_LIST_300 BY DELNO DELITEM LABELNO LABELITEM.
  DESCRIBE TABLE GT_LIST_300 LINES DATA(LV_LINE).

*GMCODE
  LV_CODE = '01'.
  CLEAR GT_RETURN.

*PSTYP(품목범주) = 3(외주임가공)인 자재
*COMPONENT 투입 자재 참조 기준 데이터 가져오기..
*1.납품문서 COMPONENT 조회
  PERFORM GET_DELCOMP USING GT_LIST_S CHANGING LT_DELCOMP.
*2.외주임가공 투입정보 관리 이력 테이블 정보 점검(ISSUE_COMP)
  PERFORM GET_ZGTMMT9450 USING GT_LIST_S CHANGING LT_ZGTMMT9450.
*3.외주 임가공 PO 예약데이터 조회
  PERFORM GET_PO_RESB USING GT_LIST_S CHANGING LT_RESB.
*4.단일배치관리/재고 조회
  PERFORM GET_MSLB USING LT_RESB LT_DELCOMP CHANGING LT_MSLB.

  LOOP AT GT_LIST_S INTO DATA(LS_LIST) GROUP BY LS_LIST-DELNO
            ASSIGNING FIELD-SYMBOL(<FS>).

*납품번호 기준으로 그룹핑->그룹 당 자재번호 1개 생성
    LOOP AT GROUP <FS> INTO DATA(LS_GR).
      DATA(LV_TABIX) = SY-TABIX.
      IF LV_TABIX = 1.
*BAPI HEADER
        CLEAR : LS_HEAD, LT_ITEM.
        LS_HEAD = VALUE #( PSTNG_DATE = GV_BUDAT
                                     DOC_DATE     = GV_BUDAT
                                     REF_DOC_NO = COND #( WHEN P_DNO = GC_X THEN LS_GR-DELNO ELSE '' )
                                     PR_UNAME     = SY-UNAME ).
      ENDIF.

      CASE  GC_X.
          "납품문서번호
        WHEN P_DNO.
*라벨정보 유무 확인
          READ TABLE GT_LIST_300 INTO DATA(LS_300)
          WITH KEY DELNO   = LS_GR-DELNO
                         DELITEM = LS_GR-DELITEM BINARY SEARCH.
          IF SY-SUBRC = 0.
            DATA(LV_TABIX2) = SY-TABIX. CLEAR LS_300.
*있으면, 라벨정보 항번 단위로 구성
            LOOP AT GT_LIST_300 INTO LS_300 FROM LV_TABIX2.
              IF LS_300-DELNO = LS_GR-DELNO AND LS_300-DELITEM = LS_GR-DELITEM.
                APPEND VALUE #( MATERIAL  = LS_GR-MATNR
                                         PLANT          = LS_GR-WERKS
                                         STGE_LOC    = LS_GR-LGORT
                                         PO_NUMBER = LS_GR-EBELN
                                         PO_ITEM       = LS_GR-EBELP
                                         MOVE_TYPE  = '101'
                                         STCK_TYPE   = LS_GR-INSMK
                                         BATCH          = COND #( WHEN LS_GR-XCHPF = GC_X  THEN SPACE
                                                                              WHEN LS_300-PSTYP IS INITIAL AND LS_GR-MTART = 'HAWA'
                                                                              THEN 'GO00000001'    ELSE SPACE )
                                         ENTRY_QNT   =  LS_300-PKG_QTY
                                         ENTRY_UOM  =  LS_300-PKG_UNIT
                                         VENDRBATCH  = LS_GR-LICHA
                                         PROD_DATE   = LS_GR-HSDAT
                                         MVT_IND        = 'B'
                                         LINE_ID          = LS_300-LABELITEM
                                         ITEM_TEXT    = LS_GR-DELNO && '-' && LS_GR-DELITEM ) TO LT_ITEM.
                IF LS_300-PSTYP = GC_3.
*                  PERFORM SET_GOODSMVT_ITEM_DNO
*                    USING LS_300 LS_GR LT_RESB LT_DELCOMP LT_MSLB LT_ZGTMMT9450
*                    CHANGING LT_ITEM LV_CHECK.
                ENDIF.
              ENDIF.
            ENDLOOP. "라벨정보 루프 종료
*없으면, 납품문서 항번 단위로 구성
          ELSE.
            APPEND VALUE #( MATERIAL  = LS_GR-MATNR
                                   PLANT          = LS_GR-WERKS
                                   STGE_LOC    = LS_GR-LGORT
                                   PO_NUMBER = LS_GR-EBELN
                                   PO_ITEM       = LS_GR-EBELP
                                   MOVE_TYPE  = '101'
                                   STCK_TYPE   =  LS_GR-INSMK
                                   ENTRY_QNT   =  LS_GR-ERFMG
                                   ENTRY_UOM  =  LS_GR-MEINS
                                   VENDRBATCH = LS_GR-LICHA
                                   PROD_DATE   = LS_GR-HSDAT
                                   MVT_IND        = 'B'
                                   ITEM_TEXT    = LS_GR-DELNO && '-' && LS_GR-DELITEM ) TO LT_ITEM.

            IF LS_GR-PSTYP = GC_3.
              PERFORM SET_GOODSMVT_ITEM_DNO
              USING LT_RESB LT_DELCOMP LT_MSLB LT_ZGTMMT9450 LT_VCQTY
              CHANGING LT_ITEM LV_CHECK LS_GR.
            ENDIF.
          ENDIF.

          "구매오더
        WHEN P_PO.
          APPEND VALUE #( MATERIAL  = LS_GR-MATNR
                                 PLANT          = LS_GR-WERKS
                                 STGE_LOC    = LS_GR-LGORT
                                 PO_NUMBER = LS_GR-EBELN
                                 PO_ITEM       = LS_GR-EBELP
                                 MOVE_TYPE  = '101'
                                 STCK_TYPE   = LS_GR-INSMK
                                 BATCH          = COND #( WHEN LS_GR-XCHPF = GC_X  THEN SPACE
                                                                      WHEN LS_300-PSTYP IS INITIAL AND LS_GR-MTART = 'HAWA'
                                                                      THEN 'GO00000001'    ELSE SPACE )
                                 ENTRY_QNT   = LS_GR-ERFMG
                                 ENTRY_UOM  = LS_GR-MEINS
                                 MVT_IND        = 'B'
                                 ITEM_TEXT    = LS_GR-EBELN && '-' && LS_GR-EBELP+3(2) ) TO LT_ITEM.

          IF LS_GR-PSTYP = GC_3.
            PERFORM SET_GOODSMVT_ITEM_PO
            USING LT_RESB LT_DELCOMP LT_MSLB LT_ZGTMMT9450 LT_VCQTY
            CHANGING LT_ITEM LV_CHECK LS_GR .
          ENDIF.

        WHEN OTHERS.
      ENDCASE.

      CLEAR : LS_300, LS_GR.
    ENDLOOP. "납품문서&항목  루프 종료

*BAPI FUNCTION CALL
    CLEAR : LV_MSG, LV_DOC.
    TRY.
        CALL FUNCTION 'BAPI_GOODSMVT_CREATE'
          EXPORTING
            GOODSMVT_HEADER  = LS_HEAD
            GOODSMVT_CODE    = LV_CODE
          IMPORTING
            MATERIALDOCUMENT = LV_DOC
          TABLES
            GOODSMVT_ITEM    = LT_ITEM
            RETURN           = GT_RETURN.

      CATCH CX_ROOT INTO DATA(LV_ERR).
        LV_MSG = LV_ERR->GET_TEXT( ).
        MESSAGE S000 WITH LV_MSG.
    ENDTRY.

    IF LINE_EXISTS( GT_RETURN[ TYPE = GC_E ] ) OR LV_DOC IS INITIAL.
      CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
      READ TABLE GT_RETURN INTO DATA(LS_RT) INDEX 1.

      LOOP AT GROUP <FS> ASSIGNING FIELD-SYMBOL(<ROLL>).
        READ TABLE GT_LIST ASSIGNING FIELD-SYMBOL(<MAIN>)
        WITH KEY EBELN = <ROLL>-EBELN
                       EBELP = <ROLL>-EBELP BINARY SEARCH.
        IF SY-SUBRC = 0.
          LV_TABIX = SY-TABIX.
          <MAIN>-STATUS    = ICON_LED_RED.
          <MAIN>-MESSAGE = LS_RT-MESSAGE.
          MODIFY GT_LIST FROM <MAIN> INDEX LV_TABIX.
        ENDIF.
      ENDLOOP.

    ELSE.
      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
        EXPORTING
          WAIT = GC_X.

      LOOP AT GROUP <FS> ASSIGNING FIELD-SYMBOL(<COM>).

        READ TABLE GT_LIST ASSIGNING FIELD-SYMBOL(<MAIN2>)
        WITH KEY DELNO    = <COM>-DELNO
                       DELITEM  = <COM>-DELITEM
                       EBELN     = <COM>-EBELN
                       EBELP     = <COM>-EBELP BINARY SEARCH.
        IF SY-SUBRC = 0.
          LV_TABIX = SY-TABIX.
          <MAIN2>-STATUS    = ICON_LED_GREEN.
          <MAIN2>-MBLNR     = LV_DOC .
          <MAIN2>-MESSAGE = '입고 처리 완료'(M14).
          CLEAR <MAIN2>-EDIT. "수정불가
          MODIFY GT_LIST FROM <MAIN2> INDEX LV_TABIX.
        ENDIF.

        IF <MAIN2>-XCHPF = GC_X AND P_DNO = GC_X.
*BAPI_배치자재(라벨정보) 제조일 업데이트
          CLEAR: LS_BATCH, LS_BATCHX.
          LS_BATCH   = VALUE #( PROD_DATE = <MAIN2>-HSDAT ).
          LS_BATCHX = VALUE #( PROD_DATE = GC_X ).

          SELECT M~WERKS, M~CHARG_SID, M~MATNR,
                       M~EBELN, M~EBELP, M~MBLNR, M~LINE_ID,
                       M~MJAHR, M~MENGE, M~MEINS, M~LGORT,
                       C~DISPO
          FROM MATDOC AS M
          INNER JOIN MARC AS C
                      ON C~WERKS = M~WERKS
                     AND C~MATNR = M~MATNR
          WHERE M~WERKS = @P_WERKS
               AND M~BUKRS = @P_BUKRS
               AND M~MATNR = @<MAIN2>-MATNR
               AND M~MBLNR = @LV_DOC
          INTO TABLE @DATA(LT_MAT).
          SORT LT_MAT BY MBLNR LINE_ID.

          CLEAR : LV_ERR, GT_RETURN, LS_RT.

          LOOP AT LT_MAT INTO DATA(LS_MAT).
            DATA(LV_TABIX3) = SY-TABIX.
            TRY.
                CALL FUNCTION 'BAPI_BATCH_CHANGE'
                  EXPORTING
*                   MATERIAL         = LS_MAT-MATNR
                    BATCH            = LS_MAT-CHARG_SID
                    PLANT            = LS_MAT-WERKS
                    BATCHATTRIBUTES  = LS_BATCH
                    BATCHATTRIBUTESX = LS_BATCHX
                    MATERIAL_LONG    = LS_MAT-MATNR
                  TABLES
                    RETURN           = GT_RETURN.

              CATCH CX_ROOT INTO LV_ERR.
                LV_MSG = LV_ERR->GET_TEXT( ).
                MESSAGE S000 WITH LV_MSG.
            ENDTRY.

            IF LINE_EXISTS( GT_RETURN[ TYPE = GC_E ] ).
              CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

              READ TABLE GT_RETURN INTO LS_RT INDEX 1.
              <MAIN2>-STATUS    = ICON_LED_RED.
              <MAIN2>-MESSAGE = LS_RT-MESSAGE.

            ELSE.
              CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
                EXPORTING
                  WAIT = GC_X.
*배치 업데이트 성공 시, 자재문서 기준으로 꼬리표번호 테이블 업데이트
              CLEAR LS_300.
              READ TABLE GT_LIST_300 INTO LS_300 INDEX LV_TABIX3.
              IF SY-SUBRC = 0.
                APPEND VALUE #( WERKS = LS_MAT-WERKS
                                           AUFNR = LS_MAT-EBELN
                                           TAGNR = LS_300-LABELNO && LS_300-LABELITEM
                                           POSNR = LS_MAT-EBELP
                                           CHARG = LS_MAT-CHARG_SID
                                           MBLNR = LS_MAT-MBLNR
                                           MATNR = LS_MAT-MATNR
                                           SPGCD  = LS_MAT-DISPO(2)
                                           MGVRG = LS_MAT-MENGE
                                           FOSTCNT = GC_1
                                           REMAIN = LS_MAT-MENGE
                                           MEINS = LS_MAT-MEINS
                                           OUTFLG = COND #( WHEN <MAIN2>-PSTYP = GC_3 THEN GC_X ELSE '' )
                                           GIFLG = GC_N
                                           GRFLG = GC_Y
                                           INSPFLG = GC_OK
                                           LGORT = LS_MAT-LGORT
                                           GRINDAT = SY-DATUM
                                           GRINTIM = SY-UZEIT
                                           GRINNAM = SY-UNAME ) TO GT_ZPPT0001.
              ENDIF.
            ENDIF.
          ENDLOOP. "자재문서 업데이트 (배치/꼬리표)루프 종료

          IF GT_ZPPT0001[] IS NOT INITIAL.
            MODIFY ZPPT0001 FROM TABLE GT_ZPPT0001.
            COMMIT WORK AND WAIT.
          ENDIF.

          CLEAR : LT_MAT, GT_ZPPT0001.
        ENDIF.
      ENDLOOP. "동일 납품번호 기준 자재번호 생성된 그룹핑 루프 종료

    ENDIF.
  ENDLOOP. "선택 ALV 데이터(입고대상) 루프 종료

  CLEAR GT_LIST_S.

ENDFORM.
*&---------------------------------------------------------------------*
*& FORM CALL_MIGO
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
*&      --> GT_HLIST_MBLNR
*&      --> GT_HLIST_MJAHR
*&---------------------------------------------------------------------*
FORM CALL_MIGO USING PV_MBLNR  PV_MJAHR.

  CHECK PV_MBLNR IS NOT INITIAL.

  CALL FUNCTION 'MIGO_DIALOG'
    EXPORTING
*     I_ACTION            = 'A04'
*     I_REFDOC            = 'R02'
*     I_NOTREE            = 'X'
*     I_NO_AUTH_CHECK     =
*     I_SKIP_FIRST_SCREEN = 'X'
*     I_DEADEND           = 'X'
*     I_OKCODE            = 'OK_GO'
*     I_LEAVE_AFTER_POST  =
*     I_NEW_ROLLAREA      = 'X'
*     I_SYTCODE           =
*     I_EBELN             =
*     I_EBELP             =
      I_MBLNR             = PV_MBLNR
      I_MJAHR             = PV_MJAHR
*     I_ZEILE             =
*     I_TRANSPORT         =
*     I_ORDER_NUMBER      =
*     I_ORDER_ITEM        =
*     I_TRANSPORT_MEANS   =
*     I_TRANSPORTIDENT    =
*     I_INBOUND_DELIV     =
*     I_OUTBOUND_DELIV    =
*     I_RESERVATION_NUMB  =
*     I_RESERVATION_ITEM  =
*     EXT                 =
*     I_MOVE_TYPE         =
*     I_SPEC_STOCK        =
*     I_PSTNG_DATE        =
*     I_DOC_DATE          =
*     I_REF_DOC_NO        =
*     I_HEADER_TXT        =
    EXCEPTIONS
      ILLEGAL_COMBINATION = 1
      OTHERS              = 2.

ENDFORM.
*&---------------------------------------------------------------------*
*& FORM DELIVERY_FINISH
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
*&      --> P_
*&---------------------------------------------------------------------*
FORM DELIVERY_FINISH  USING   PV_GB.

  DATA : LT_LIST        LIKE TABLE OF GS_LIST.
  DATA : LT_POITEM  LIKE TABLE OF BAPIMEPOITEM,
         LT_POITEMX LIKE TABLE OF BAPIMEPOITEMX.
  DATA : LV_MSG TYPE BAPI_MSG.

  CLEAR : GV_TEXT, GV_ANSWER, GV_ERR,
               GT_LIST_S, GT_LIST_C.

  PERFORM GET_SELECTED_ROWS USING GCL_GRID.
  CHECK GV_ERR IS INITIAL.

  LOOP AT GT_ROWS INTO GS_ROW.

    READ TABLE GT_LIST  INTO DATA(LS_LIST) INDEX GS_ROW-INDEX.
    IF SY-SUBRC = 0.
      CASE PV_GB.
        WHEN 'DFIN'.
          APPEND LS_LIST TO GT_LIST_S.
        WHEN 'DFCC'.
          APPEND LS_LIST TO GT_LIST_C.
      ENDCASE.
    ENDIF.
  ENDLOOP.

  CHECK GV_ERR IS INITIAL.
  CLEAR : GV_QUES, GV_BUDAT.

  GV_QUES = COND  #( WHEN PV_GB = 'DFIN' THEN '납품 완료 처리 하시겠습니까?'(M19)
                                    ELSE '납품 완료 취소 처리 하시겠습니까?'(M20) ).

  PERFORM POPUP_TO_CONFIRM_STEP  USING 'N' GV_QUES '' TEXT-T04.
  CHECK GV_ANSWER = ZGTFI_J.

*BAPI
  CASE PV_GB.
    WHEN 'DFIN'.
      LOOP AT GT_LIST_S INTO DATA(LS_S).
        APPEND VALUE #( PO_ITEM        = LS_S-EBELP
                                     NO_MORE_GR  = GC_X ) TO LT_POITEM.

        APPEND VALUE #( PO_ITEM        = LS_S-EBELP
                                     PO_ITEMX      = GC_X
                                     NO_MORE_GR  = GC_X ) TO LT_POITEMX.

        AT END OF EBELN.
          CALL FUNCTION 'BAPI_PO_CHANGE'
            EXPORTING
              PURCHASEORDER = LS_S-EBELN
            TABLES
              RETURN        = GT_RETURN
              POITEM        = LT_POITEM
              POITEMX       = LT_POITEMX.

          READ TABLE GT_LIST INTO LS_LIST WITH KEY EBELN = LS_S-EBELN
          BINARY SEARCH.
          IF SY-SUBRC = 0.
            DATA(LV_TABIX) = SY-TABIX.
          ENDIF.

          IF LINE_EXISTS( GT_RETURN[ TYPE = GC_E ] ) .
            CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
            READ TABLE GT_RETURN INTO DATA(LS_RT) INDEX 1.

            LOOP AT GT_LIST ASSIGNING FIELD-SYMBOL(<FS>) FROM LV_TABIX.
              IF <FS>-EBELN = LS_S-EBELN.
                <FS>-MESSAGE = LS_RT-MESSAGE.
                <FS>-ELIKZ = SPACE.
              ENDIF.
            ENDLOOP.
            GV_ERR = GC_X.

          ELSE.
            CALL FUNCTION 'BAPI_TRANSACTION_COMMIT' EXPORTING WAIT = GC_X.

            LOOP AT GT_LIST ASSIGNING FIELD-SYMBOL(<FSS>) FROM LV_TABIX.
              IF <FSS>-EBELN = LS_S-EBELN.
                <FSS>-ELIKZ = GC_X.
              ENDIF.
            ENDLOOP.
            LV_MSG =  '처리완료'(003). CLEAR GV_ERR.
          ENDIF.

          CLEAR : LT_POITEM[], LT_POITEMX[].
        ENDAT.
      ENDLOOP.

    WHEN 'DFCC'.
      LOOP AT GT_LIST_C INTO DATA(LS_C).
        APPEND VALUE #( PO_ITEM        = LS_C-EBELP
                                     NO_MORE_GR  = '' ) TO LT_POITEM.

        APPEND VALUE #( PO_ITEM        = LS_C-EBELP
                                     PO_ITEMX      = GC_X
                                     NO_MORE_GR  = GC_X ) TO LT_POITEMX.

        AT END OF EBELN.
          CALL FUNCTION 'BAPI_PO_CHANGE'
            EXPORTING
              PURCHASEORDER = LS_C-EBELN
            TABLES
              RETURN        = GT_RETURN
              POITEM        = LT_POITEM
              POITEMX       = LT_POITEMX.

          CLEAR : LV_TABIX, LS_LIST.

          READ TABLE GT_LIST INTO LS_LIST WITH KEY EBELN = LS_C-EBELN
          BINARY SEARCH.
          IF SY-SUBRC = 0.
            LV_TABIX = SY-TABIX.
          ENDIF.

          IF LINE_EXISTS( GT_RETURN[ TYPE = GC_E ] ) .
            CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
            READ TABLE GT_RETURN INTO LS_RT INDEX 1.

            LOOP AT GT_LIST ASSIGNING FIELD-SYMBOL(<FS_DF>) FROM LV_TABIX.
              IF <FS_DF>-EBELN = LS_C-EBELN.
                <FS_DF>-MESSAGE = LS_RT-MESSAGE.
              ENDIF.
            ENDLOOP.
            GV_ERR = GC_X.

          ELSE.
            CALL FUNCTION 'BAPI_TRANSACTION_COMMIT' EXPORTING WAIT = GC_X.

            LOOP AT GT_LIST ASSIGNING FIELD-SYMBOL(<FS_DFS>) FROM LV_TABIX.
              IF <FS_DFS>-EBELN = LS_C-EBELN.
                <FS_DFS>-ELIKZ = SPACE.
              ENDIF.
            ENDLOOP.
            LV_MSG =  '처리완료'(003).  CLEAR GV_ERR.
          ENDIF.

          CLEAR : LT_POITEM[], LT_POITEMX[].
        ENDAT.
      ENDLOOP.
  ENDCASE.

  IF GV_ERR IS INITIAL.
    MESSAGE S000 WITH LV_MSG.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& FORM UPDATE_DELCLOSE
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
*& -->  P1        TEXT
*& <--  P2        TEXT
*&---------------------------------------------------------------------*
FORM UPDATE_DELCLOSE .

  DATA : LT_LIST    LIKE TABLE OF GS_LIST.
  DATA : LT_POITEM  LIKE TABLE OF BAPIMEPOITEM,
         LT_POITEMX LIKE TABLE OF BAPIMEPOITEMX.
  DATA : LV_MSG TYPE BAPI_MSG.

  CLEAR : GV_TEXT, GV_ANSWER, GV_ERR.

  PERFORM GET_SELECTED_ROWS USING GCL_GRID.
  CHECK GV_ERR IS INITIAL.

  LOOP AT GT_ROWS INTO GS_ROW.

    READ TABLE GT_LIST  INTO DATA(LS_LIST) INDEX GS_ROW-INDEX.
    IF SY-SUBRC = 0.

      UPDATE ZGTMMT9410
            SET DELCLOSE = GC_X
       WHERE DELNO    = LS_LIST-DELNO
            AND DELITEM = LS_LIST-DELITEM.

      IF SY-SUBRC = 0.
        LS_LIST-DELCLOSE = GC_X.
        LS_LIST-STATUS = ICON_LED_GREEN.
        CLEAR LS_LIST-EDIT. ""수량필드 입력불가 처리
        MODIFY GT_LIST FROM LS_LIST INDEX GS_ROW-INDEX.
      ENDIF.

      LV_MSG = '처리완료'(003).
    ENDIF.
  ENDLOOP.

  MESSAGE S000 WITH LV_MSG.


ENDFORM.
*&---------------------------------------------------------------------*
*& FORM SET_CANC_BAPI_DATA
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
*& -->  P1        TEXT
*& <--  P2        TEXT
*&---------------------------------------------------------------------*
FORM SET_CANC_BAPI_DATA .

  DATA :
    LT_0001   LIKE TABLE OF ZPPT0001,
    LT_LIST   LIKE TABLE OF GS_LIST,
    LS_HEAD   TYPE BAPI2017_GM_HEAD_RET,
    LS_BATCH  TYPE BAPIBATCHATT,
    LS_BATCHX TYPE BAPIBATCHATTX,
    LV_MSG    TYPE BAPI_MSG.

  CLEAR : LV_MSG, GV_ERR.
  SORT GT_LIST BY MBLNR.
  SORT GT_LIST_C BY MBLNR.
  DELETE ADJACENT DUPLICATES FROM GT_LIST_C COMPARING MBLNR.

  LOOP AT GT_LIST_C ASSIGNING FIELD-SYMBOL(<FS>) .
    <FS>-MJAHR = COND #( WHEN <FS>-MJAHR IS INITIAL THEN GV_BUDAT(4)
                                          ELSE <FS>-MJAHR ).
*CALL BAPI
    TRY.
        CALL FUNCTION 'BAPI_GOODSMVT_CANCEL'
          EXPORTING
            MATERIALDOCUMENT    = <FS>-MBLNR
            MATDOCUMENTYEAR     = <FS>-MJAHR
            GOODSMVT_PSTNG_DATE = GV_BUDAT
          IMPORTING
            GOODSMVT_HEADRET    = LS_HEAD
          TABLES
            RETURN              = GT_RETURN.

      CATCH CX_ROOT INTO DATA(LV_ERR).
        LV_MSG = LV_ERR->GET_TEXT( ).
        MESSAGE E000 WITH LV_MSG.
    ENDTRY.

    IF LINE_EXISTS( GT_RETURN[ TYPE = GC_E ] ) .
      CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

      READ TABLE GT_RETURN INTO DATA(LS_RT) INDEX 1.
      "ALV UPDATE
      LOOP AT GT_LIST INTO DATA(LS_LIST) WHERE MBLNR = <FS>-MBLNR.
        LS_LIST-STATUS    = ICON_LED_RED.
        LS_LIST-MESSAGE = LS_RT-MESSAGE.
        MODIFY GT_LIST FROM LS_LIST TRANSPORTING MBLNR STATUS MESSAGE.
        CLEAR LS_LIST.
      ENDLOOP.

    ELSE.
      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT' EXPORTING WAIT = GC_X.
      "ALV UPDATE
      CLEAR LS_LIST.
      SORT GT_9411 BY DELNO DELITEM.

      LOOP AT GT_LIST INTO LS_LIST WHERE MBLNR = <FS>-MBLNR.
        LS_LIST-STATUS = ICON_LED_YELLOW.

*배치자재인 경우(MARC-XCHPF=X)
*자재문서 기준 꼬리표번호 삭제(ZPPT0001)대상 세팅
        IF LS_LIST-XCHPF = GC_X .
          PERFORM DELETE_ZPPT0001 TABLES LT_0001 USING LS_LIST.
        ENDIF.
*OEM드럼라벨인 경우, ZGTMMT9415 자재문서 클리어 업데이트
        IF P_LNO = GC_X.
          UPDATE ZGTMMT9415
          SET MBLNR = SPACE
                 MJAHR = SPACE
          WHERE SYSTEM_ID = GC_KSRM
               AND EBELN       = <FS>-EBELN
               AND EBELP       = <FS>-EBELP
               AND DR_LABELNO = <FS>-DR_LABELNO
               AND MBLNR = <FS>-MBLNR
               AND MJAHR = <FS>-MJAHR.
          CLEAR LS_LIST-BUDAT.
        ENDIF.

        CLEAR : LS_LIST-MBLNR, LS_LIST-GRBUDAT, LS_LIST-MESSAGE.

*라벨정보 있는 대상인지 체크 후 필드 편집 가능 여부 설정
        READ TABLE GT_9411 TRANSPORTING NO FIELDS
        WITH KEY DELNO = LS_LIST-DELNO
                       DELITEM = LS_LIST-DELITEM BINARY SEARCH.
        IF SY-SUBRC = 0.
          IF LS_LIST-MTART = 'MCHA' OR LS_LIST-MTART = 'MCFE'.
            LS_LIST-EDIT = GC_X. "편집가능
          ELSE.
            CLEAR : LS_LIST-ERFMG, LS_LIST-EDIT . "편집불가 & 입고수량 빈 값 설정
          ENDIF.

        ELSE.
          LS_LIST-EDIT = GC_X. "편집가능
        ENDIF.

        MODIFY GT_LIST FROM LS_LIST TRANSPORTING MBLNR ERFMG GRBUDAT BUDAT STATUS MESSAGE EDIT.
        CLEAR LS_LIST.

        MESSAGE S000 WITH TEXT-003.
      ENDLOOP.

    ENDIF.

  ENDLOOP.

*꼬리표번호 삭제(ZPPT0001)
  IF LT_0001[] IS NOT INITIAL.
    DELETE ZPPT0001 FROM TABLE LT_0001.
    IF SY-SUBRC = 0.
      COMMIT WORK.
    ENDIF.
  ENDIF.


ENDFORM.
*&---------------------------------------------------------------------*
*& FORM SET_URL_DISPLAY
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
*& -->  P1        TEXT
*& <--  P2        TEXT
*&---------------------------------------------------------------------*
FORM SET_URL_DISPLAY  USING PV_URL.
  DATA : LV_MSG TYPE BAPI_MSG,
         LV_URL TYPE STRING.

  LV_URL = PV_URL.

*URL 실행
  TRY.

      CL_GUI_FRONTEND_SERVICES=>EXECUTE(
         EXPORTING
           DOCUMENT               = LV_URL
         EXCEPTIONS
           CNTL_ERROR             = 1
           ERROR_NO_GUI          = 2
           BAD_PARAMETER       = 3
         OTHERS                     = 10  ).

    CATCH CX_ROOT INTO DATA(LV_ERR).
      LV_MSG = LV_ERR->GET_TEXT( ).
      MESSAGE S000 WITH LV_MSG DISPLAY LIKE GC_E. EXIT.
  ENDTRY.


ENDFORM.
*&---------------------------------------------------------------------*
*& FORM SET_HTML_URL_DISPLAY
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
*& -->  P1        TEXT
*& <--  P2        TEXT
*&---------------------------------------------------------------------*
FORM SET_HTML_URL_DISPLAY USING PV_URL.

  DATA: LV_URL       TYPE STRING , "호출할 URL
        LV_TMP_DIR   TYPE STRING,
        LV_FILE_PATH TYPE STRING,
        LT_HTML      TYPE TABLE OF STRING,
        LV_HTML_STR  TYPE STRING,
        LV_RC        TYPE I,
        LV_MSG       TYPE BAPI_MSG.

  LV_URL = PV_URL. "호출할 URL

  " 1. PC의 임시 디렉토리 경로 가져오기
  CL_GUI_FRONTEND_SERVICES=>GET_TEMP_DIRECTORY(
    CHANGING
     TEMP_DIR = LV_TMP_DIR ).

  CL_GUI_CFW=>FLUSH( ).

  LV_FILE_PATH = LV_TMP_DIR && '\REDIRECT_FULL.HTML'.

  " 2. 전체 화면으로 열기 위한 HTML/JAVASCRIPT 구성
  " 화면의 너비(WIDTH)와 높이(HEIGHT)를 꽉 채우도록 설정
  APPEND '<HTML><HEAD><SCRIPT TYPE="TEXT/JAVASCRIPT">' TO LT_HTML.
  APPEND 'FUNCTION OPENFULL() {' TO LT_HTML.
  APPEND '  VAR W = SCREEN.AVAILWIDTH;' TO LT_HTML.
  APPEND '  VAR H = SCREEN.AVAILHEIGHT;' TO LT_HTML.
  APPEND |  VAR WIN = WINDOW.OPEN('{ LV_URL }', '_BLANK', 'TOP=0,LEFT=0,WIDTH='+W+',HEIGHT='+H+',RESIZABLE=YES,SCROLLBARS=YES,STATUS=YES');| TO LT_HTML.
  APPEND '  IF (WIN) { WINDOW.OPENER = NULL; WINDOW.OPEN("", "_SELF", ""); WINDOW.CLOSE(); }' TO LT_HTML.
  APPEND '}' TO LT_HTML.
  APPEND '</SCRIPT></HEAD>' TO LT_HTML.
  APPEND '<BODY ONLOAD="OPENFULL()"></BODY></HTML>' TO LT_HTML.

  " 3. HTML 파일을 로컬 PC에 저장
  CL_GUI_FRONTEND_SERVICES=>GUI_DOWNLOAD(
    EXPORTING
     FILENAME                = LV_FILE_PATH
     FILETYPE                = 'ASC'
    CHANGING
     DATA_TAB                = LT_HTML
    EXCEPTIONS
     OTHERS                  = 1  ).

  IF SY-SUBRC = 0.
    " 4. 생성된 HTML 파일 실행 (기본 브라우저로 열림)
    CL_GUI_FRONTEND_SERVICES=>EXECUTE(
     EXPORTING
       DOCUMENT               = LV_FILE_PATH
     EXCEPTIONS
       OTHERS                 = 1   ).
  ENDIF.

*생성했던 임시 HTML 파일 삭제
  IF SY-SUBRC = 0.
    WAIT UP TO 2 SECONDS.

    CL_GUI_FRONTEND_SERVICES=>FILE_DELETE(
      EXPORTING
        FILENAME = LV_FILE_PATH
      CHANGING
        RC            = LV_RC
      EXCEPTIONS
        FILE_DELETE_FAILED    = 1
        CNTL_ERROR            = 2
        ERROR_NO_GUI          = 3
        FILE_NOT_FOUND        = 4
        ACCESS_DENIED         = 5
        UNKNOWN_ERROR         = 6
        NOT_SUPPORTED_BY_GUI  = 7
        WRONG_PARAMETER       = 8
        OTHERS                = 9
    ).

    IF SY-SUBRC <> 0.
    ENDIF.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& FORM SET_BAPI_DATA2
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
*&      --> LT_ITEM
*&      --> LS_GR
*&      --> LS_300
*&---------------------------------------------------------------------*
FORM SET_BAPI_DATA2  .

  DATA : LT_LIST   LIKE TABLE OF GS_LIST,
         LS_HEAD   TYPE BAPI2017_GM_HEAD_01,
         LT_ITEM   TYPE TABLE OF BAPI2017_GM_ITEM_CREATE,
         LV_CODE   TYPE BAPI2017_GM_CODE-GM_CODE,
         LV_DOC    TYPE BAPI2017_GM_HEAD_RET-MAT_DOC,
         LS_BATCH  TYPE BAPIBATCHATT,
         LS_BATCHX TYPE BAPIBATCHATTX,
         LV_MSG    TYPE BAPI_MSG,
         LV_VC.

  DATA :
    LV_CHECK      TYPE C LENGTH 1,
    LT_RESB       TYPE TY_T_PO_RESB,
    LT_DELCOMP    TYPE TY_T_PO_DELCOMP,
    LT_DISPO      TYPE TY_T_PO_DISPO,
    LT_MSLB       TYPE TY_T_MSLB,
    LT_VCQTY      TYPE TY_T_VC,
    LT_ZGTMMT9450 TYPE TY_T_ZGTMMT9450,
    LT_ZGTMMT9415 TYPE TABLE OF ZGTMMT9415.

  CLEAR : LV_MSG, GV_ERR, LV_VC.
***입고처리
  IF P_LNO = GC_X.
    SORT GT_LIST BY EBELN EBELP DR_LABELNO.
    SORT GT_LIST_S BY EBELN EBELP.
  ELSE.
    SORT GT_LIST BY DELNO DELITEM EBELN EBELP.
    SORT GT_LIST_S BY DELNO DELITEM.
  ENDIF.

*선택한 입고 자재의 라벨정보
  SORT GT_LIST_300 BY DELNO DELITEM LABELNO LABELITEM.
  DATA(LV_LINE) = LINES( GT_LIST_300 ).

*PSTYP(품목범주) = 3(외주임가공)인 자재
*COMPONENT 투입 자재 참조 기준 데이터 가져오기..
*1.납품문서 COMPONENT 조회
  PERFORM GET_DELCOMP USING GT_LIST_S CHANGING LT_DELCOMP.
*2.외주임가공 투입정보 관리 이력 테이블 정보 점검(ISSUE_COMP)
  PERFORM GET_ZGTMMT9450 USING GT_LIST_S CHANGING LT_ZGTMMT9450.
*3.외주 임가공 PO 예약데이터 조회
  PERFORM GET_PO_RESB USING GT_LIST_S CHANGING LT_RESB.
*4.단일배치관리/재고 조회
  PERFORM GET_MSLB USING LT_RESB LT_DELCOMP CHANGING LT_MSLB.

**특정 자재유형(MCHA/MCFE)_조장정보조회
  PERFORM GET_VC_VALUE USING GT_LIST_S CHANGING LT_VCQTY.

***-BAPI SET
*GMCODE
  LV_CODE = '01'. "입고
  CLEAR GT_RETURN.

  IF P_LNO = GC_X.  "OEM드럼라벨조회
    PERFORM SET_DRLABEL_GR USING LT_RESB LT_DELCOMP LT_MSLB LT_ZGTMMT9450 LT_VCQTY .

  ELSE. "표준명세서(납품번호)/수기명세서(구매오더)
    LOOP AT GT_LIST_S ASSIGNING FIELD-SYMBOL(<G1>)
                    GROUP BY ( DELNO = <G1>-DELNO   SIZE  = GROUP SIZE )
      ASSIGNING FIELD-SYMBOL(<LS_GR1>).

      DATA(LV_GR_LINES) = <LS_GR1>-SIZE.

*BAPI HEADER
      CLEAR : LS_HEAD, LT_ITEM.
      LS_HEAD = VALUE #( PSTNG_DATE  = GV_BUDAT
                                     DOC_DATE     = GV_BUDAT
                                     REF_DOC_NO = COND #( WHEN P_DNO = GC_X
                                                             THEN <LS_GR1>-DELNO ELSE '' )
                                     PR_UNAME     = SY-UNAME ).
*BAPI ITEM
      LOOP AT GROUP <LS_GR1> ASSIGNING FIELD-SYMBOL(<LS_ITEM>).

        IF P_DNO = GC_X. "표준명세서(납품번호)
*          PERFORM SET_GOODSMVT_ITEM_DNO
*            USING LT_RESB LT_DELCOMP LT_MSLB LT_ZGTMMT9450 LT_VCQTY
*            CHANGING LT_ITEM LV_CHECK <LS_ITEM>.
          IF LV_VC = GC_X.
            "분할 생성일 경우에는 클리어...아래 폼 내부에서 품목 별 자재문서 생성.
            CLEAR LT_ITEM.
          ENDIF.

          PERFORM SET_GOODSMVT_ITEM_DNO_NEW
            USING LT_RESB LT_DELCOMP LT_MSLB LT_ZGTMMT9450 LT_VCQTY LV_GR_LINES
            CHANGING LT_ITEM LV_CHECK <LS_ITEM> LS_HEAD  LV_VC.

        ELSE."수기명세서(PO)
          PERFORM SET_GOODSMVT_ITEM_PO_NEW
            USING LT_RESB LT_DELCOMP LT_MSLB LT_ZGTMMT9450 LT_VCQTY
            CHANGING LT_ITEM LV_CHECK <LS_ITEM>.

*          PERFORM SET_GOODSMVT_ITEM_PO
*            USING LT_RESB LT_DELCOMP LT_MSLB LT_ZGTMMT9450 LT_VCQTY
*            CHANGING LT_ITEM LV_CHECK <LS_ITEM>.
        ENDIF.

      ENDLOOP.

      IF LV_CHECK EQ GC_E.
        GT_RETURN = VALUE #( ( TYPE = GC_E MESSAGE = TEXT-E14 ) ). "투입 자재 정보를 확인하세요.
      ELSE.
        IF LV_VC IS NOT INITIAL.
          CONTINUE. "항목 별 바피 실행을 위에서 했기 때문에 다음 아이템...처리.
        ENDIF.
*BAPI 실행
*P_DNO표준거래명세서일 경우 참조문서 번호 누락되는 경우 있을 수 있어 체크 추가.
        IF LS_HEAD IS INITIAL.
          LS_HEAD = VALUE #( PSTNG_DATE  = GV_BUDAT
                                           DOC_DATE     = GV_BUDAT
                                           REF_DOC_NO = COND #( WHEN P_DNO = GC_X
                                                                                  THEN <LS_GR1>-DELNO ELSE '' )
                                           PR_UNAME     = SY-UNAME ).
        ELSE.
          IF LS_HEAD-REF_DOC_NO IS INITIAL.
            LS_HEAD-REF_DOC_NO = COND #( WHEN P_DNO = GC_X THEN <LS_GR1>-DELNO ELSE '' ).
          ENDIF.
        ENDIF.

        CALL FUNCTION 'BAPI_GOODSMVT_CREATE'
          EXPORTING
            GOODSMVT_HEADER  = LS_HEAD
            GOODSMVT_CODE    = LV_CODE
          IMPORTING
            MATERIALDOCUMENT = LV_DOC
          TABLES
            GOODSMVT_ITEM    = LT_ITEM
            RETURN           = GT_RETURN.
      ENDIF.

      IF LV_DOC IS INITIAL.
        READ TABLE GT_RETURN ASSIGNING FIELD-SYMBOL(<LS_RT>) WITH KEY TYPE = GC_E.
        IF SY-SUBRC EQ 0.
*오류
          CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

          LOOP AT GROUP <LS_GR1> ASSIGNING FIELD-SYMBOL(<ROLL>).
            READ TABLE GT_LIST ASSIGNING FIELD-SYMBOL(<MAIN>)
            WITH KEY EBELN = <ROLL>-EBELN
                           EBELP = <ROLL>-EBELP BINARY SEARCH.
            IF SY-SUBRC = 0.
              DATA(LV_TABIX) = SY-TABIX.
              <MAIN>-STATUS    = ICON_LED_RED.
              <MAIN>-MESSAGE = <LS_RT>-MESSAGE.
              MODIFY GT_LIST FROM <MAIN> INDEX LV_TABIX.
            ENDIF.
          ENDLOOP.
        ENDIF.

      ELSE.
*성공
        CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
          EXPORTING
            WAIT = ABAP_TRUE.

        READ TABLE GT_RETURN ASSIGNING <LS_RT> WITH KEY TYPE = GC_E.

        LOOP AT GROUP <LS_GR1> ASSIGNING FIELD-SYMBOL(<COM>).
*MAIN ALV UPDATE
          READ TABLE GT_LIST ASSIGNING FIELD-SYMBOL(<MAIN2>)
          WITH KEY DELNO    = <COM>-DELNO
                         DELITEM  = <COM>-DELITEM
                         EBELN     = <COM>-EBELN
                         EBELP     = <COM>-EBELP BINARY SEARCH.
          IF SY-SUBRC = 0.
            DATA(LV_TABIX2) = SY-TABIX.
            <MAIN2>-STATUS    = ICON_LED_GREEN.
            <MAIN2>-MBLNR     = LV_DOC .
            <MAIN2>-GRBUDAT = GV_BUDAT.
            <MAIN2>-BUDAT     = COND #( WHEN P_LNO = GC_X THEN GV_BUDAT ELSE <MAIN2>-BUDAT ).
            <MAIN2>-MESSAGE = COND #( WHEN <LS_RT> IS ASSIGNED AND <LS_RT>-MESSAGE IS NOT INITIAL
                                                            THEN <LS_RT>-MESSAGE
                                                            ELSE '입고 처리 완료'(M14) ).
            CLEAR <MAIN2>-EDIT. "수정불가
            MODIFY GT_LIST FROM <MAIN2> INDEX LV_TABIX2.
          ENDIF.
*배치자재인 경우(MARC-XCHPF=X) 배치마스터 제조일자 업데이트
*->배치마스터 업데이트 성공 시, 자재문서 기준 꼬리표번호 테이블 업데이트(ZPPT0001)
          IF <MAIN2>-XCHPF = GC_X .
            PERFORM BATCH_CHANGE TABLES LT_VCQTY USING <MAIN2> <COM>.
          ENDIF.

          IF GT_ZPPT0001[] IS NOT INITIAL.
            MODIFY ZPPT0001 FROM TABLE GT_ZPPT0001.
            COMMIT WORK AND WAIT.
          ENDIF.

          CLEAR : GT_ZPPT0001.
        ENDLOOP.

      ENDIF.
    ENDLOOP.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& FORM GET_DELCOMP
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
*&      --> GT_LIST_S
*&      <-- LT_DELCOMP
*&---------------------------------------------------------------------*
FORM GET_DELCOMP  USING PT_TAB TYPE  TY_T_LIST
                             CHANGING CT_DELCOMP TYPE TY_T_PO_DELCOMP.
**COMPONENT  자재 투입 처리 기준 참조 우선순위 조건
*1) 납품문서 기준 COMPONENT 투입 정보가 존재하는 경우 정보 점검(DEL_COMP)
* 납품 문서->마지막 수신 받은 KEY 기준 ZGTMMT9410-STATUS <>X 인 대상
*	TABLE: ZGTMMT9412
*	SELECT조건 : IDNRK,CHARG,WERKS,WERKS,ISSUE_QTY,ISSUE_UNIT,EBELN,EBELP
*	WHERE 조건:
*	DELNO = IT_TAB-DELNO
*	DELITEM = IT_TAB-DELITEM
*	EBELN = IT_TAB-EBELN
*	EBELP = IT_TAB-EBELP

  WITH
  +V_MAX AS (
      SELECT
      Z1~SYSTEM_ID,
      Z1~DELNO,
      Z1~DELITEM,
      Z1~WERKS,
      MAX( Z1~ZIFKEY ) AS ZIFKEY
      FROM ZGTMMT9410 AS Z1
      WHERE EXISTS (
##ITAB_KEY_IN_SELECT
        SELECT ZZ~DELNO
          FROM @PT_TAB AS ZZ
          WHERE ZZ~EBELN EQ Z1~EBELN
          AND ZZ~EBELP EQ Z1~EBELP
          AND ZZ~DELNO EQ Z1~DELNO
          AND ZZ~DELITEM EQ Z1~DELITEM
          AND ZZ~WERKS EQ Z1~WERKS
      )
      AND Z1~SYSTEM_ID EQ @GC_KSRM
      GROUP BY Z1~SYSTEM_ID, Z1~DELNO, Z1~DELITEM, Z1~WERKS
  )
  SELECT
      Z1~EBELN,
      Z1~EBELP,
      Z1~DELNO,
      Z1~DELITEM,
      Z2~IDNRK,
      Z2~LIFNR,
      Z2~CHARG,
      Z2~WERKS,
      Z2~LGORT,
      Z2~ISSUE_QTY,
      Z2~ISSUE_UNIT,
      MC~XCHPF
    FROM +V_MAX AS V1
                INNER JOIN
           ZGTMMT9410 AS Z1 ON V1~SYSTEM_ID EQ Z1~SYSTEM_ID
                                       AND V1~DELNO EQ Z1~DELNO
                                       AND V1~DELITEM EQ Z1~DELITEM
                                       AND V1~WERKS EQ Z1~WERKS
                                       AND V1~ZIFKEY EQ Z1~ZIFKEY
                INNER JOIN
           ZGTMMT9412 AS Z2 ON V1~SYSTEM_ID EQ Z2~SYSTEM_ID
                                       AND V1~DELNO EQ Z2~DELNO
                                       AND V1~DELITEM EQ Z2~DELITEM
                                       AND V1~WERKS EQ Z2~WERKS
                                       AND V1~ZIFKEY EQ Z2~ZIFKEY
                INNER JOIN
           MARC AS MC ON Z2~IDNRK EQ MC~MATNR
                            AND Z2~WERKS EQ MC~WERKS
      WHERE Z1~STATUS EQ @SPACE
     ORDER BY Z1~EBELN, Z1~EBELP, Z1~DELNO, Z1~DELITEM
     INTO CORRESPONDING FIELDS OF TABLE @CT_DELCOMP.

ENDFORM.
*&---------------------------------------------------------------------*
*& FORM GET_ZGTMMT9450
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
*&      --> LT_TAB
*&      <-- LT_ZGTMMT9450
*&---------------------------------------------------------------------*
FORM GET_ZGTMMT9450  USING    PT_TAB TYPE TY_T_LIST
                                CHANGING PT_ZGTMMT9450 TYPE TY_T_ZGTMMT9450.
**COMPONENT  자재 투입 처리 기준 참조 우선순위 조건
*1)조건에 맞지 않으면, 2)외주임가공 투입정보 관리 이력 테이블 정보 점검(ISSUE_COMP)
*	TABLE : ZGTMMT9450
*	SELECT 조건 : IDNRK,CHARG,EBELN,EBELP,MENGE,MEINS
*	WHRE 조건 : IT_TAB-EBELN,IT_TAB-EBELP,LIFNR,WERKS

  ##ITAB_KEY_IN_SELECT
  SELECT
    Z1~EBELN,
    Z1~EBELP,
    Z1~WERKS,
    Z1~IDNRK,
    Z1~CHARG,
    Z1~MENGE,
    Z1~MEINS
    FROM ZGTMMT9450 AS Z1
    WHERE EXISTS (
      SELECT @ABAP_TRUE
      FROM @PT_TAB AS ZZ
      WHERE ZZ~EBELN EQ Z1~EBELN
        AND ZZ~EBELP EQ Z1~EBELP
        AND ZZ~WERKS EQ Z1~WERKS
    )
    ORDER BY Z1~EBELN, Z1~EBELP, Z1~WERKS
    INTO CORRESPONDING FIELDS OF TABLE @PT_ZGTMMT9450.

ENDFORM.
*&---------------------------------------------------------------------*
*& FORM GET_PO_RESB
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
*&      --> LT_LOG_DATA
*&      <-- LT_RESB
*&---------------------------------------------------------------------*
FORM GET_PO_RESB  USING  PT_TAB TYPE TY_T_LIST
                             CHANGING CT_RESB TYPE TY_T_PO_RESB.
**COMPONENT  자재 투입 처리 기준 참조 우선순위 조건
*납품문서 투입실적, 임가공 투입정보 정보가 존재하지 않는 경우,3번째 기준.
*3) 구매오더의 COMPONENT 자재 정보추출(PO_COMP)
*	TABLE ; RESB
*	SELECT조건 : RSPOS,MATNR,BDMNG,MEINS,WERKS,LGORT,CHARG
*	WHRE 조건 : IT_TAB-EBELN, IT-TAB-EBELP
*3-1) COMPONENT 소비량 산출(COMP_QTY)
*  입고 수량 * 단위당소요량(RESB-BDMNG/EKPO-MENGE)

  SELECT
    EP~EBELN,
    EP~EBELP,
    EP~MENGE,
    RS~RSNUM,
    RS~RSPOS,
    RS~BDMNG,
    RS~MATNR,
    RS~MEINS,
    RS~WERKS,
    RS~LGORT,
    RS~CHARG,
    MC~XCHPF,
    EK~LIFNR
    FROM EKPO AS EP
              INNER JOIN
            RESB AS RS ON EP~EBELN EQ RS~EBELN
                          AND EP~EBELP EQ RS~EBELP
              INNER JOIN
            MARC AS MC ON RS~MATNR EQ MC~MATNR
                             AND RS~WERKS EQ MC~WERKS
              INNER JOIN
            EKKO AS EK ON EP~EBELN EQ EK~EBELN
    WHERE EP~PSTYP EQ @GC_3
    AND EXISTS (
##ITAB_KEY_IN_SELECT
      SELECT ZZ~EBELN, ZZ~EBELP
        FROM @PT_TAB AS ZZ
        WHERE ZZ~EBELN EQ EP~EBELN
           AND ZZ~EBELP EQ EP~EBELP
    )
    AND EP~LOEKZ EQ @SPACE
    AND RS~XLOEK EQ @SPACE
    ORDER BY EP~EBELN, EP~EBELP, RS~RSNUM, RS~RSPOS
    INTO TABLE @CT_RESB.

ENDFORM.
*&---------------------------------------------------------------------*
*& FORM F_GET_MSLB_POGR_RCV
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
*&      --> LT_RESB
*&      --> LT_DELCOMP
*&      <-- LT_MSLB
*&---------------------------------------------------------------------*
FORM GET_MSLB  USING PT_RESB TYPE TY_T_PO_RESB
                                                             PT_DELCOMP TYPE TY_T_PO_DELCOMP
                                            CHANGING CT_MSLB TYPE TY_T_MSLB.

*"투입자재가 배치관리 자재이고 (ZGTMM_CV_SC_RESBLIST-XCHPF = 'X')
*PO_COMP-CHARG 값이 공백인 경우, 4번째 우선순위 기준.
*4)공급업체 재고 테이블 기준 BATCH 번호 추출 투입 처리(선입 선출 기준)
*TABLE : MSLB
*SELECT 조건 : LBLAB 0 이 아닌 CHARG
*WHERE 조건 :
*MATNR = PO_COMP-MATNR
*WERKS = PO_COMP_WERKS
*LIFNR = EKKO-LIFNR"
*"BATCH 별 투입 시 지정된 BATCH가 단일 배치단위이면 (MCH1-XPCBT='X')
*BATCH 가용재고전량투입 처리"

  DATA:
    BEGIN OF LS_KEY,
      MATNR TYPE MSLB-MATNR,
      WERKS TYPE MSLB-WERKS,
      LIFNR TYPE MSLB-LIFNR,
    END OF LS_KEY,
    LT_KEY LIKE STANDARD TABLE OF LS_KEY.

  "KEY 생성
  ##ITAB_KEY_IN_SELECT
  ##ITAB_DB_SELECT
  SELECT DISTINCT
    ZZ~MATNR,
    ZZ~WERKS,
    ZZ~LIFNR
    FROM @PT_RESB AS ZZ
    WHERE ZZ~XCHPF EQ @ABAP_TRUE
    AND ZZ~CHARG EQ @SPACE
    APPENDING TABLE @LT_KEY.

  ##ITAB_DB_SELECT
  ##ITAB_KEY_IN_SELECT
  SELECT DISTINCT
    ZZ~IDNRK,
    ZZ~WERKS,
    ZZ~LIFNR
    FROM @PT_DELCOMP AS ZZ
    WHERE ZZ~XCHPF EQ @ABAP_TRUE
    AND ZZ~CHARG EQ @SPACE
    APPENDING TABLE @LT_KEY.

  "중복제거
  SORT LT_KEY BY MATNR WERKS LIFNR.
  DELETE ADJACENT DUPLICATES FROM LT_KEY COMPARING MATNR WERKS LIFNR.

  "재고조회
  ##ITAB_KEY_IN_SELECT
  SELECT
    MS~MATNR,
    MS~WERKS,
    MS~CHARG,
    MS~LIFNR,
    MS~LBLAB,
    MC~XPCBT
    FROM @LT_KEY AS ZZ
              INNER JOIN
            MSLB AS MS ON ZZ~MATNR EQ MS~MATNR
                              AND ZZ~WERKS EQ MS~WERKS
                              AND ZZ~LIFNR EQ MS~LIFNR
              INNER JOIN
            MCH1 AS MC ON MS~MATNR EQ MC~MATNR
                             AND MS~CHARG EQ MC~CHARG
    WHERE MS~LBLAB IS NOT INITIAL
    ORDER BY MS~MATNR, MS~WERKS, MS~LIFNR, MC~LWEDT, MS~CHARG
    INTO TABLE @CT_MSLB.


  "부분수량 GI 허용 플래그
  ##ITAB_KEY_IN_SELECT
  SELECT MM~MATNR
    FROM MARM AS MM
    WHERE EXISTS (
      SELECT ZZ~MATNR
        FROM @CT_MSLB AS ZZ
        WHERE ZZ~MATNR EQ MM~MATNR
    )
    AND MM~ATINN IS NOT INITIAL
    AND MM~PCBUT EQ @GC_B
    ORDER BY MM~MATNR
    INTO TABLE @DATA(LT_MARM).

  LOOP AT CT_MSLB ASSIGNING FIELD-SYMBOL(<LS_MSLB>).
    READ TABLE LT_MARM WITH KEY MATNR = <LS_MSLB>-MATNR BINARY SEARCH TRANSPORTING NO FIELDS.
    CHECK SY-SUBRC EQ 0.
    <LS_MSLB>-XPRGI = ABAP_TRUE.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& FORM SET_GOODSMVT_ITEM_DNO
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
*&      --> <LS_LOG_TAB>
*&      <-- LT_ITEM
*&---------------------------------------------------------------------*
FORM SET_GOODSMVT_ITEM_DNO  USING
                                                         PT_RESB TYPE TY_T_PO_RESB
                                                         PT_DELCOMP TYPE TY_T_PO_DELCOMP
                                                         PT_MSLB TYPE TY_T_MSLB
                                                         PT_ZGTMMT9450 TYPE TY_T_ZGTMMT9450
                                                         PT_VCQTY TYPE TY_T_VC
                                   CHANGING CT_ITEM TYPE TY_T_BAPI2017_GM_ITEM_CREATE
                                                    CV_CHECK
                                                    PS_LIST TYPE TY_LIST.

  FIELD-SYMBOLS <LS_RESB> TYPE TY_PO_RESB.

  DATA : LS_ITEM TYPE BAPI2017_GM_ITEM_CREATE,
         LV_VCQ  TYPE ERFMG,
         LV_TIME TYPE I,
         LV_VC.

*라벨정보 유무 확인
  READ TABLE GT_LIST_300 INTO DATA(LS_300)
  WITH KEY DELNO   = PS_LIST-DELNO
                 DELITEM = PS_LIST-DELITEM BINARY SEARCH.
  IF SY-SUBRC = 0.
    DATA(LV_TABIX) = SY-TABIX. CLEAR LS_300.

    LOOP AT GT_LIST_300 INTO LS_300 FROM LV_TABIX.
      IF LS_300-DELNO = PS_LIST-DELNO AND LS_300-DELITEM = PS_LIST-DELITEM.

*자재유형이 MCHA/MCFE/HAWA이면, 특성(조장)정보를 체크하여 조장 단위 기준으로 입고수량 분할
*분할 된 라인만큼 LINE_ID 추가하여 분할 입고. 각 배치 생성 되도록..
        CLEAR : LV_TIME, LV_VCQ, LV_VC.

        CASE PS_LIST-MTART.
          WHEN 'MCHA' OR 'MCFE' OR 'HAWA'.
            READ TABLE PT_VCQTY ASSIGNING FIELD-SYMBOL(<VC>)
            WITH KEY PDOC = PS_LIST-EBELN
                           PDOCITEM = PS_LIST-EBELP
                           DPCBT = 'A' BINARY SEARCH.
            IF SY-SUBRC = 0.
*FACTOR BATCH 이면, 한 번에 생성
              CLEAR LV_VCQ.
              LV_TIME = 1.
            ELSE.
*FACTOR BATCH 아니면, 조장단위로 분할 입고
              LV_VC = 'X'.
              LV_TIME = PS_LIST-MENGE / <VC>-LENGTH. "분할수 = 입고수량/조장단위
              LV_VCQ = PS_LIST-MENGE / LV_TIME. "분할입고수량 = 입고수량/분할 수
            ENDIF.

          WHEN OTHERS.
            CLEAR LV_VCQ.
            LV_TIME = 1.
        ENDCASE.

        DO LV_TIME TIMES.

          LS_ITEM-MATERIAL = PS_LIST-MATNR.
          LS_ITEM-PLANT = PS_LIST-WERKS.
          LS_ITEM-STGE_LOC = PS_LIST-LGORT.
          LS_ITEM-PO_NUMBER = PS_LIST-EBELN.
          LS_ITEM-PO_ITEM = PS_LIST-EBELP.
          LS_ITEM-MOVE_TYPE = '101'.
          LS_ITEM-STCK_TYPE = PS_LIST-INSMK.
          LS_ITEM-ENTRY_QNT = COND #( WHEN LV_VCQ IS INITIAL THEN LS_300-MENGE
                                                             ELSE LV_VCQ ).
          LS_ITEM-ENTRY_UOM = PS_LIST-MEINS.
          LS_ITEM-VENDRBATCH = PS_LIST-LICHA.
          LS_ITEM-PROD_DATE = PS_LIST-HSDAT.
*ITEM_TEXT                    DELNO&-&DELITEM INV2602000001-1
          LS_ITEM-ITEM_TEXT = PS_LIST-DELNO && '-' && PS_LIST-DELITEM.

          CASE PS_LIST-PSTYP.
            WHEN SPACE OR '0'. "일반
*CASE1. 일반 입고 : IT_TAB-PSTYP = "" AND
*CASE2. 일반입고 : 배치관리유형 DPCBT = 'A'(FACTOR BATCH)이면,
*배치번호 : 조장정보로 설정.
              READ TABLE PT_VCQTY  ASSIGNING FIELD-SYMBOL(<VCL>)
              WITH KEY PDOC = PS_LIST-EBELN
                             PDOCITEM = PS_LIST-EBELP
                             DPCBT = 'A' BINARY SEARCH.
              IF SY-SUBRC = 0.
                LS_ITEM-BATCH = CONV I( <VCL>-LENGTH ).
                CONDENSE LS_ITEM-BATCH NO-GAPS.

              ELSE.
**CASE3. 처리 자재의  자재유형이 HAWA 이면 DEFAULT 값 채번 /배치번호 : GO00000001"
                IF PS_LIST-MTART EQ 'HAWA'.
                  SELECT SINGLE  DPCBT
                    FROM MARC
                    WHERE MATNR EQ @PS_LIST-MATNR
                    AND WERKS EQ @PS_LIST-WERKS
                    INTO @DATA(LV_DPCBT).

                  CASE LV_DPCBT.
*2-2)공백이면 DEFAULT 값 채번_배치번호 : GO00000001"
                    WHEN SPACE.
                      LS_ITEM-BATCH = 'GO00000001'.
*2-1)MARC-DPCBT = 'C'->자동채번
                    WHEN 'C'.
                    WHEN OTHERS.
                  ENDCASE.

                ELSE.
*CASE4. 일반 입고 : 플랜트&자재그룹(MATKL)이 ZGTPPT1010에 존재하면,
*배치번호 : 자재번호로 설정.
                  READ TABLE GT_ZGTPPT1010 TRANSPORTING NO FIELDS
                  WITH KEY FLD_01 = PS_LIST-WERKS
                                 FLD_02 = PS_LIST-MATKL BINARY SEARCH.

                  IF SY-SUBRC = 0.
                    SHIFT PS_LIST-MATNR LEFT DELETING LEADING '0'.
                    LS_ITEM-BATCH = PS_LIST-MATNR.
                  ENDIF.
                ENDIF.
              ENDIF.
***CASE3. 처리 자재의  자재유형이 HAWA 이면 DEFAULT 값 채번
**배치번호 : GO00000001"
*            IF PS_LIST-MTART EQ 'HAWA'.
*              LS_ITEM-BATCH = 'GO00000001'.
*            ELSE.
**CASE2. 일반 입고 : 플랜트&자재그룹(MATKL)이 ZGTPPT1010에 존재하면,
**배치번호 : 자재번호로 설정.
*              READ TABLE GT_ZGTPPT1010 TRANSPORTING NO FIELDS
*              WITH KEY FLD_01 = PS_LIST-WERKS
*                             FLD_02 = PS_LIST-MATKL BINARY SEARCH.
*
*              IF SY-SUBRC = 0.
*                SHIFT PS_LIST-MATNR LEFT DELETING LEADING '0'.
*                LS_ITEM-BATCH = PS_LIST-MATNR.
*              ELSE.
**CASE3. 일반입고 : 배치관리유형 DPCBT = 'A'(FACTOR BATCH)이면,
**배치번호 : 조장정보로 설정.
*                READ TABLE PT_VCQTY  ASSIGNING FIELD-SYMBOL(<VCL>)
*                WITH KEY PDOC = PS_LIST-EBELN
*                               PDOCITEM = PS_LIST-EBELP
*                               DPCBT = 'A' BINARY SEARCH.
*                IF SY-SUBRC = 0.
*                  LS_ITEM-BATCH = CONV I( <VCL>-LENGTH ).
*                  CONDENSE LS_ITEM-BATCH NO-GAPS.
**                  LS_ITEM-BATCH = <VCL>-LENGTH.
*                ENDIF.
*              ENDIF.
*            ENDIF.

            WHEN '3'.  "외주 임가공_메인품목 자재 배치 설정 조건 체크 추가
*배치관리 유형 FACTOR BATCH이면(DPCBT = 'A') 조장정보로 채번,없으면 자동채번
              READ TABLE PT_VCQTY ASSIGNING FIELD-SYMBOL(<VCL2>)
              WITH KEY PDOC = PS_LIST-EBELN
                             PDOCITEM = PS_LIST-EBELP
                             DPCBT = 'A' BINARY SEARCH.
              IF SY-SUBRC = 0.
                LS_ITEM-BATCH = CONV I( <VCL2>-LENGTH ).
                CONDENSE LS_ITEM-BATCH NO-GAPS.
              ENDIF.

            WHEN OTHERS.
          ENDCASE.

          LS_ITEM-MVT_IND = GC_B.
          LS_ITEM-LINE_ID = LINES( CT_ITEM ) + 1.
          CT_ITEM = VALUE #( BASE CT_ITEM ( LS_ITEM ) ).

          PS_LIST-LINE_ID = LS_ITEM-LINE_ID. "BAPI 성공 COMMIT후 업데이트 위한 구분용
        ENDDO.

        CHECK PS_LIST-PSTYP EQ GC_3. "외주 임가공인 경우
*3-2-4-2) COMPONENT 소비량 산출(COMP_QTY)
*: 입고 수량 * 단위당소요량(RESB-BDMNG/EKPO-MENGE)
*COMPONENT 자재 항목 라인별로 BAPI ITEM 라인 추가
        DATA:
          LV_ERFMG   TYPE MENGV13,
          LV_ERFMG_O TYPE ERFMG.

        FIELD-SYMBOLS <LS_MSLB> TYPE TY_MSLB.

        DATA LS_COMP TYPE BAPI2017_GM_ITEM_CREATE.
        LS_COMP-PARENT_ID	 = LS_ITEM-LINE_ID.
        LS_COMP-LINE_ID = LS_ITEM-LINE_ID.

        READ TABLE PT_DELCOMP WITH KEY EBELN = PS_LIST-EBELN
                                                          EBELP = PS_LIST-EBELP
                                                          DELNO = PS_LIST-DELNO
                                                          DELITEM = PS_LIST-DELITEM BINARY SEARCH TRANSPORTING NO FIELDS.
        IF SY-SUBRC EQ 0.
          "납품문서 COMPONENT 기준
          LOOP AT PT_DELCOMP ASSIGNING FIELD-SYMBOL(<LS_DELCOMP>) FROM SY-TABIX.
            IF <LS_DELCOMP>-EBELN NE PS_LIST-EBELN
              OR <LS_DELCOMP>-EBELP NE PS_LIST-EBELP
              OR <LS_DELCOMP>-DELNO NE PS_LIST-DELNO
              OR <LS_DELCOMP>-DELITEM NE PS_LIST-DELITEM.
              EXIT.
            ENDIF.

            LS_COMP-MATERIAL = <LS_DELCOMP>-IDNRK.
            LS_COMP-PLANT = <LS_DELCOMP>-WERKS.
            LS_COMP-STGE_LOC = <LS_DELCOMP>-LGORT.
            LS_COMP-PO_NUMBER = <LS_DELCOMP>-EBELN.
            LS_COMP-PO_ITEM = <LS_DELCOMP>-EBELP.
            LS_COMP-MOVE_TYPE = '543'.
            LS_COMP-BATCH = <LS_DELCOMP>-CHARG.
            LS_COMP-ENTRY_QNT = <LS_DELCOMP>-ISSUE_QTY.
            LS_COMP-ENTRY_UOM = <LS_DELCOMP>-ISSUE_UNIT.
            LS_COMP-MVT_IND = GC_B.

            "라인추가
            IF <LS_DELCOMP>-XCHPF EQ ABAP_TRUE AND <LS_DELCOMP>-CHARG EQ SPACE.
*"투입자재가 배치관리 자재이고 (ZGTMM_CV_SC_RESBLIST-XCHPF = 'X')
*PO_COMP-CHARG 값이 공백인 경우
*공급업체 재고 테이블 기준 BATCH 번호 추출 투입 처리(선입 선출 기준)
*TABLE : MSLB
*SELECT 조건 : LBLAB 0 이 아닌 CHARG
*WHERE 조건 :
*MATNR = PO_COMP-MATNR
*WERKS = PO_COMP_WERKS
*LIFNR = EKKO-LIFNR
              LV_ERFMG = LS_COMP-ENTRY_QNT. "대상 출고 수량
              READ TABLE PT_MSLB WITH KEY MATNR = <LS_DELCOMP>-IDNRK
                                                         WERKS = <LS_DELCOMP>-WERKS
                                                         LIFNR = <LS_DELCOMP>-LIFNR BINARY SEARCH TRANSPORTING NO FIELDS.
              IF SY-SUBRC EQ 0.
                LOOP AT PT_MSLB ASSIGNING <LS_MSLB> FROM SY-TABIX.
                  IF <LS_MSLB>-MATNR NE <LS_DELCOMP>-IDNRK
                    OR <LS_MSLB>-WERKS NE <LS_DELCOMP>-WERKS
                    OR <LS_MSLB>-LIFNR NE <LS_DELCOMP>-LIFNR.
                    EXIT.
                  ENDIF.

                  CHECK <LS_MSLB>-LBLAB GE 0. "재고수량이 0보다 큰 경우만 진행

                  "적용 수량 빼기
                  LV_ERFMG_O = LV_ERFMG.
                  LV_ERFMG -= <LS_MSLB>-LBLAB.

                  LS_COMP-BATCH = <LS_MSLB>-CHARG.

                  IF LV_ERFMG LT 0.
                    "적용한 수량이 대상 출고수량 보다 큰 경우
                    IF <LS_MSLB>-XPCBT EQ ABAP_TRUE AND <LS_MSLB>-XPRGI EQ SPACE.
*"BATCH 별 투입 시 지정된 BATCH가 단일 배치단위이면 (MCH1-XPCBT='X')
*BATCH 가용재고전량투입 처리"
*& 부분수량 GI 허용이 SPACE 인 경우
                      LS_COMP-ENTRY_QNT = <LS_MSLB>-LBLAB.
                    ELSE.
                      "단일 배치단위가 아니면 잔량적용
                      LS_COMP-ENTRY_QNT = LV_ERFMG_O.
                    ENDIF.
                  ELSE.
                    LS_COMP-ENTRY_QNT = <LS_MSLB>-LBLAB.
                  ENDIF.

                  "재고수량에서 적용수량 빼기
                  <LS_MSLB>-LBLAB -=  LS_COMP-ENTRY_QNT.

                  LS_COMP-LINE_ID += 1.
                  CT_ITEM = VALUE #( BASE CT_ITEM ( LS_COMP ) ). "라인추가
                  PS_LIST-LINE_ID = LS_COMP-LINE_ID.

                  "적용 수량이 대상 출고수량을 초과한 경우 종료
                  IF LV_ERFMG LE 0.
                    EXIT.
                  ENDIF.

                ENDLOOP.
              ELSE.
                LS_COMP-LINE_ID += 1.
                CT_ITEM = VALUE #( BASE CT_ITEM ( LS_COMP ) ).
                PS_LIST-LINE_ID = LS_COMP-LINE_ID.
              ENDIF.
            ELSE.
              LS_COMP-LINE_ID += 1.
              CT_ITEM = VALUE #( BASE CT_ITEM ( LS_COMP ) ).
              PS_LIST-LINE_ID = LS_COMP-LINE_ID.
            ENDIF.
          ENDLOOP.
        ELSE.
          READ TABLE PT_ZGTMMT9450 WITH KEY EBELN = PS_LIST-EBELN
                                                                       EBELP = PS_LIST-EBELP
                                                                       WERKS = PS_LIST-WERKS
                                                                BINARY SEARCH TRANSPORTING NO FIELDS.
          IF SY-SUBRC EQ 0.
*
*3-2-4-2) 외주임가공 투입정보 관리 이력 테이블 정보 점검(ISSUE_COMP)
*
*TABLE : ZGTMMT9450
*SELECT 조건 : IDNRK,CHARG,EBELN,EBELP,MENGE,MEINS
*WHRE 조건 : IT_TAB-EBELN,IT_TAB-EBELP,LIFNR,WERKS
*조회된  COMPONENT 자재,배치별 BAPI ITEM 라인 추가

            LOOP AT PT_ZGTMMT9450 ASSIGNING FIELD-SYMBOL(<LS_ZGTMMT9450>).

              LS_COMP-MATERIAL = <LS_ZGTMMT9450>-IDNRK.
              LS_COMP-PLANT = PS_LIST-WERKS.
              LS_COMP-PO_NUMBER = <LS_ZGTMMT9450>-EBELN.
              LS_COMP-PO_ITEM = <LS_ZGTMMT9450>-EBELP.
              LS_COMP-MOVE_TYPE = '543'.
              LS_COMP-BATCH = <LS_ZGTMMT9450>-CHARG.
              LS_COMP-ENTRY_UOM = <LS_ZGTMMT9450>-MEINS.
              LS_COMP-MVT_IND = GC_B.

*"1) ISSUE_COMP=CHARGE <> NULL
*  : ISSUE_COMP-MENGE
*2) ISSUE_COMP=CHARGE """" 이면
*  : PO 소요량정보로 입고수량 대비 투입 처리 수량 산출
*  -> 입고 수량 * 단위당소요량(RESB-BDMNG/EKPO-MENGE)"

              IF <LS_ZGTMMT9450>-CHARG IS NOT INITIAL.
                LS_COMP-ENTRY_QNT = <LS_ZGTMMT9450>-MENGE.
              ELSE.

                READ TABLE PT_RESB ASSIGNING <LS_RESB> WITH KEY  EBELN = <LS_ZGTMMT9450>-EBELN
                                                                                                      EBELP = <LS_ZGTMMT9450>-EBELP
                                                                                                      MATNR = <LS_ZGTMMT9450>-IDNRK.
                IF SY-SUBRC EQ 0.
                  IF <LS_RESB>-MENGE IS NOT INITIAL.
                    LS_COMP-ENTRY_QNT = PS_LIST-MENGE * ( <LS_RESB>-BDMNG / <LS_RESB>-MENGE ).
                  ELSE.
                    LS_COMP-ENTRY_QNT = 0.
                  ENDIF.
                ELSE.
                  CV_CHECK = GC_E.
                  EXIT.
                ENDIF.
              ENDIF.

              LS_COMP-LINE_ID += 1.
              CT_ITEM = VALUE #( BASE CT_ITEM ( LS_COMP ) ).
              PS_LIST-LINE_ID = LS_COMP-LINE_ID.

            ENDLOOP.

          ELSE.
            "PO COMPONENT 기준
            READ TABLE PT_RESB WITH KEY EBELN = PS_LIST-EBELN
                                                              EBELP = PS_LIST-EBELP
                                                              BINARY SEARCH TRANSPORTING NO FIELDS.
            IF SY-SUBRC EQ 0.
              LOOP AT PT_RESB ASSIGNING <LS_RESB> FROM SY-TABIX.
                IF <LS_RESB>-EBELN NE PS_LIST-EBELN
                  OR <LS_RESB>-EBELP NE PS_LIST-EBELP.
                  EXIT.
                ENDIF.

                LS_COMP-MATERIAL = <LS_RESB>-MATNR.
                LS_COMP-PLANT = <LS_RESB>-WERKS.
                LS_COMP-STGE_LOC = <LS_RESB>-LGORT.
                LS_COMP-PO_NUMBER = <LS_RESB>-EBELN.
                LS_COMP-PO_ITEM = <LS_RESB>-EBELP.
                LS_COMP-MOVE_TYPE = '543'.
                LS_COMP-BATCH = <LS_RESB>-CHARG.
                IF <LS_RESB>-MENGE IS NOT INITIAL.
                  LS_COMP-ENTRY_QNT = PS_LIST-MENGE * ( <LS_RESB>-BDMNG / <LS_RESB>-MENGE ).
                ELSE.
                  LS_COMP-ENTRY_QNT = 0.
                ENDIF.
                LS_COMP-ENTRY_UOM = <LS_RESB>-MEINS.
                LS_COMP-MVT_IND = GC_B.


                "라인추가
                IF <LS_RESB>-XCHPF EQ ABAP_TRUE AND <LS_RESB>-CHARG EQ SPACE.
*"투입자재가 배치관리 자재이고 (ZGTMM_CV_SC_RESBLIST-XCHPF = 'X')
*PO_COMP-CHARG 값이 공백인 경우
*공급업체 재고 테이블 기준 BATCH 번호 추출 투입 처리(선입 선출 기준)
*TABLE : MSLB
*SELECT 조건 : LBLAB 0 이 아닌 CHARG
*WHERE 조건 :
*MATNR = PO_COMP-MATNR
*WERKS = PO_COMP_WERKS
*LIFNR = EKKO-LIFNR
                  LV_ERFMG = LS_COMP-ENTRY_QNT. "대상 출고 수량
                  READ TABLE PT_MSLB WITH KEY MATNR = <LS_RESB>-MATNR
                                                             WERKS = <LS_RESB>-WERKS
                                                             LIFNR = <LS_RESB>-LIFNR BINARY SEARCH TRANSPORTING NO FIELDS.
                  IF SY-SUBRC EQ 0.
                    LOOP AT PT_MSLB ASSIGNING <LS_MSLB> FROM SY-TABIX.
                      IF <LS_MSLB>-MATNR NE <LS_RESB>-MATNR
                        OR <LS_MSLB>-WERKS NE <LS_RESB>-WERKS
                        OR <LS_MSLB>-LIFNR NE <LS_RESB>-LIFNR.
                        EXIT.
                      ENDIF.

                      CHECK <LS_MSLB>-LBLAB GE 0. "재고수량이 0보다 큰 경우만 진행

                      "적용 수량 빼기
                      LV_ERFMG_O = LV_ERFMG.
                      LV_ERFMG -= <LS_MSLB>-LBLAB.

                      LS_COMP-BATCH = <LS_MSLB>-CHARG.

                      IF LV_ERFMG LT 0.
                        "적용한 수량이 대상 출고수량 보다 큰 경우
                        IF <LS_MSLB>-XPCBT EQ ABAP_TRUE AND <LS_MSLB>-XPRGI EQ SPACE.
*"BATCH 별 투입 시 지정된 BATCH가 단일 배치단위이면 (MCH1-XPCBT='X')
*BATCH 가용재고전량투입 처리"
* & 부분수량 GI 허용이 SPACE 인 경우
                          LS_COMP-ENTRY_QNT = <LS_MSLB>-LBLAB.
                        ELSE.
                          "단일 배치단위가 아니면 잔량적용
                          LS_COMP-ENTRY_QNT = LV_ERFMG_O.
                        ENDIF.
                      ELSE.
                        LS_COMP-ENTRY_QNT = <LS_MSLB>-LBLAB.
                      ENDIF.

                      "재고수량에서 적용수량 빼기
                      <LS_MSLB>-LBLAB -=  LS_COMP-ENTRY_QNT.

                      LS_COMP-LINE_ID += 1.
                      CT_ITEM = VALUE #( BASE CT_ITEM ( LS_COMP ) ). "라인추가
                      PS_LIST-LINE_ID = LS_COMP-LINE_ID.

                      "적용 수량이 대상 출고수량을 초과한 경우 종료
                      IF LV_ERFMG LE 0.
                        EXIT.
                      ENDIF.

                    ENDLOOP.
                  ELSE.
                    LS_COMP-LINE_ID += 1.
                    CT_ITEM = VALUE #( BASE CT_ITEM ( LS_COMP ) ).
                    PS_LIST-LINE_ID = LS_COMP-LINE_ID.
                  ENDIF.
                ELSE.
                  LS_COMP-LINE_ID += 1.
                  CT_ITEM = VALUE #( BASE CT_ITEM ( LS_COMP ) ).
                  PS_LIST-LINE_ID = LS_COMP-LINE_ID.
                ENDIF.

              ENDLOOP.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDLOOP.

*라벨정보 없는 대상은..
  ELSE.
*1.자재유형이 MCHA/MCFE이면, 특성(조장)정보를 체크하여 조장 단위 기준으로 입고수량 분할
*분할 된 라인만큼 LINE_ID 추가하여 분할 입고. 각 배치 생성 되도록..
    CLEAR : LV_TIME, LV_VCQ.
    CASE PS_LIST-MTART.
      WHEN 'MCHA' OR 'MCFE' OR 'HAWA'.
        READ TABLE PT_VCQTY ASSIGNING FIELD-SYMBOL(<VC2>)
        WITH KEY PDOC = PS_LIST-EBELN
                       PDOCITEM = PS_LIST-EBELP BINARY SEARCH.
        IF SY-SUBRC = 0.
          LV_TIME = PS_LIST-MENGE / <VC2>-LENGTH. "분할수 = 입고수량/조장단위
          LV_VCQ = PS_LIST-MENGE / LV_TIME. "분할입고수량 = 입고수량/분할 수
        ENDIF.

      WHEN OTHERS.
        CLEAR LV_VCQ.
        LV_TIME = 1.
    ENDCASE.

    DO LV_TIME TIMES.

      LS_ITEM-MATERIAL = PS_LIST-MATNR.
      LS_ITEM-PLANT = PS_LIST-WERKS.
      LS_ITEM-STGE_LOC = PS_LIST-LGORT.
      LS_ITEM-PO_NUMBER = PS_LIST-EBELN.
      LS_ITEM-PO_ITEM = PS_LIST-EBELP.
      LS_ITEM-MOVE_TYPE = '101'.
      LS_ITEM-STCK_TYPE = PS_LIST-INSMK.
      LS_ITEM-ENTRY_QNT = COND #( WHEN LV_VCQ IS INITIAL THEN PS_LIST-ERFMG
                                                         ELSE LV_VCQ ).
      LS_ITEM-ENTRY_UOM = PS_LIST-MEINS.
      LS_ITEM-VENDRBATCH = PS_LIST-LICHA.
      LS_ITEM-PROD_DATE = PS_LIST-HSDAT.
*ITEM_TEXT                    DELNO&-&DELITEM GO2026020001-10
      LS_ITEM-ITEM_TEXT = PS_LIST-DELNO && '-' && PS_LIST-DELITEM.

      CASE PS_LIST-PSTYP.
        WHEN SPACE OR '0'. "일반
*CASE1. 일반 입고 : IT_TAB-PSTYP = ""
*처리 자재의  자재유형이 HAWA 이면 DEFAULT 값 채번
*배치번호 : GO00000001"
          IF PS_LIST-MTART EQ 'HAWA'.
            LS_ITEM-BATCH = 'GO00000001'.
          ELSE.
*CASE2. 일반 입고 : 플랜트&자재그룹(MATKL)이 ZGTPPT1010에 존재하면,
*배치번호 : 자재번호
            READ TABLE GT_ZGTPPT1010 TRANSPORTING NO FIELDS
            WITH KEY FLD_01 = PS_LIST-WERKS
                           FLD_02 = PS_LIST-MATKL BINARY SEARCH.

            IF SY-SUBRC = 0.
              SHIFT PS_LIST-MATNR LEFT DELETING LEADING '0'.
              LS_ITEM-BATCH = PS_LIST-MATNR.
            ELSE.
*CASE3. 일반입고 : 배치관리유형 DPCBT = 'A'(FACTOR BATCH)이면,
*배치번호 : 조장정보
              READ TABLE PT_VCQTY  ASSIGNING FIELD-SYMBOL(<VCL3>)
              WITH KEY PDOC = PS_LIST-EBELN
                             PDOCITEM = PS_LIST-EBELP
                             DPCBT = 'A' BINARY SEARCH.
              IF SY-SUBRC = 0.
                LS_ITEM-BATCH = CONV I( <VCL3>-LENGTH ).
                CONDENSE LS_ITEM-BATCH NO-GAPS.
              ENDIF.
            ENDIF.
          ENDIF.

        WHEN '3'.  "외주 임가공_메인품목 자재 배치 설정 조건 체크 추가
*배치관리 유형 FACTOR BATCH이면(DPCBT = 'A') 조장정보로 채번,없으면 자동채번
          READ TABLE PT_VCQTY ASSIGNING FIELD-SYMBOL(<VCL4>)
          WITH KEY PDOC = PS_LIST-EBELN
                         PDOCITEM = PS_LIST-EBELP
                         DPCBT = 'A' BINARY SEARCH.
          IF SY-SUBRC = 0.
            LS_ITEM-BATCH = CONV I( <VCL4>-LENGTH ).
            CONDENSE LS_ITEM-BATCH NO-GAPS.
          ENDIF.
        WHEN OTHERS.
      ENDCASE.

      LS_ITEM-MVT_IND = GC_B.
      LS_ITEM-LINE_ID = LINES( CT_ITEM ) + 1.
      CT_ITEM = VALUE #( BASE CT_ITEM ( LS_ITEM ) ).

      PS_LIST-LINE_ID = LS_ITEM-LINE_ID.

    ENDDO.

    CHECK PS_LIST-PSTYP EQ GC_3. "외주 임가공인 경우
*3-2-4-2) COMPONENT 소비량 산출(COMP_QTY)
*: 입고 수량 * 단위당소요량(RESB-BDMNG/EKPO-MENGE)
*COMPONENT 자재 항목 라인별로 BAPI ITEM 라인 추가
    CLEAR :
      LV_ERFMG   ,
      LV_ERFMG_O,
      LS_COMP.

    LS_COMP-PARENT_ID	 = LS_ITEM-LINE_ID.
    LS_COMP-LINE_ID = LS_ITEM-LINE_ID.

    READ TABLE PT_DELCOMP WITH KEY EBELN = PS_LIST-EBELN
                                                      EBELP = PS_LIST-EBELP
                                                      DELNO = PS_LIST-DELNO
                                                      DELITEM = PS_LIST-DELITEM BINARY SEARCH TRANSPORTING NO FIELDS.
    IF SY-SUBRC EQ 0.
      "납품문서 COMPONENT 기준
      LOOP AT PT_DELCOMP ASSIGNING FIELD-SYMBOL(<LS_DELCOMP2>) FROM SY-TABIX.
        IF <LS_DELCOMP2>-EBELN NE PS_LIST-EBELN
          OR <LS_DELCOMP2>-EBELP NE PS_LIST-EBELP
          OR <LS_DELCOMP2>-DELNO NE PS_LIST-DELNO
          OR <LS_DELCOMP2>-DELITEM NE PS_LIST-DELITEM.
          EXIT.
        ENDIF.

        LS_COMP-MATERIAL = <LS_DELCOMP2>-IDNRK.
        LS_COMP-PLANT = <LS_DELCOMP2>-WERKS.
        LS_COMP-STGE_LOC = <LS_DELCOMP2>-LGORT.
        LS_COMP-PO_NUMBER = <LS_DELCOMP2>-EBELN.
        LS_COMP-PO_ITEM = <LS_DELCOMP2>-EBELP.
        LS_COMP-MOVE_TYPE = '543'.
        LS_COMP-BATCH = <LS_DELCOMP2>-CHARG.
        LS_COMP-ENTRY_QNT = <LS_DELCOMP2>-ISSUE_QTY.
        LS_COMP-ENTRY_UOM = <LS_DELCOMP2>-ISSUE_UNIT.
        LS_COMP-MVT_IND = GC_B.

        "라인추가
        IF <LS_DELCOMP2>-XCHPF EQ ABAP_TRUE AND <LS_DELCOMP2>-CHARG EQ SPACE.
*"투입자재가 배치관리 자재이고 (ZGTMM_CV_SC_RESBLIST-XCHPF = 'X')
*PO_COMP-CHARG 값이 공백인 경우
*공급업체 재고 테이블 기준 BATCH 번호 추출 투입 처리(선입 선출 기준)
*TABLE : MSLB
*SELECT 조건 : LBLAB 0 이 아닌 CHARG
*WHERE 조건 :
*MATNR = PO_COMP-MATNR
*WERKS = PO_COMP_WERKS
*LIFNR = EKKO-LIFNR
          LV_ERFMG = LS_COMP-ENTRY_QNT. "대상 출고 수량
          READ TABLE PT_MSLB WITH KEY MATNR = <LS_DELCOMP2>-IDNRK
                                                     WERKS = <LS_DELCOMP2>-WERKS
                                                     LIFNR = <LS_DELCOMP2>-LIFNR BINARY SEARCH TRANSPORTING NO FIELDS.
          IF SY-SUBRC EQ 0.
            LOOP AT PT_MSLB ASSIGNING <LS_MSLB> FROM SY-TABIX.
              IF <LS_MSLB>-MATNR NE <LS_DELCOMP2>-IDNRK
                OR <LS_MSLB>-WERKS NE <LS_DELCOMP2>-WERKS
                OR <LS_MSLB>-LIFNR NE <LS_DELCOMP2>-LIFNR.
                EXIT.
              ENDIF.

              CHECK <LS_MSLB>-LBLAB GE 0. "재고수량이 0보다 큰 경우만 진행

              "적용 수량 빼기
              LV_ERFMG_O = LV_ERFMG.
              LV_ERFMG -= <LS_MSLB>-LBLAB.

              LS_COMP-BATCH = <LS_MSLB>-CHARG.

              IF LV_ERFMG LT 0.
                "적용한 수량이 대상 출고수량 보다 큰 경우
                IF <LS_MSLB>-XPCBT EQ ABAP_TRUE AND <LS_MSLB>-XPRGI EQ SPACE.
*"BATCH 별 투입 시 지정된 BATCH가 단일 배치단위이면 (MCH1-XPCBT='X')
*BATCH 가용재고전량투입 처리"
*& 부분수량 GI 허용이 SPACE 인 경우
                  LS_COMP-ENTRY_QNT = <LS_MSLB>-LBLAB.
                ELSE.
                  "단일 배치단위가 아니면 잔량적용
                  LS_COMP-ENTRY_QNT = LV_ERFMG_O.
                ENDIF.
              ELSE.
                LS_COMP-ENTRY_QNT = <LS_MSLB>-LBLAB.
              ENDIF.

              "재고수량에서 적용수량 빼기
              <LS_MSLB>-LBLAB -=  LS_COMP-ENTRY_QNT.

              LS_COMP-LINE_ID += 1.
              CT_ITEM = VALUE #( BASE CT_ITEM ( LS_COMP ) ). "라인추가
              PS_LIST-LINE_ID = LS_COMP-LINE_ID.

              "적용 수량이 대상 출고수량을 초과한 경우 종료
              IF LV_ERFMG LE 0.
                EXIT.
              ENDIF.

            ENDLOOP.
          ELSE.
            LS_COMP-LINE_ID += 1.
            CT_ITEM = VALUE #( BASE CT_ITEM ( LS_COMP ) ).
            PS_LIST-LINE_ID = LS_COMP-LINE_ID.
          ENDIF.
        ELSE.
          LS_COMP-LINE_ID += 1.
          CT_ITEM = VALUE #( BASE CT_ITEM ( LS_COMP ) ).
          PS_LIST-LINE_ID = LS_COMP-LINE_ID.
        ENDIF.
      ENDLOOP.

    ELSE.
      READ TABLE PT_ZGTMMT9450 WITH KEY EBELN = PS_LIST-EBELN
                                                                   EBELP = PS_LIST-EBELP
                                                                   WERKS = PS_LIST-WERKS
                                                            BINARY SEARCH TRANSPORTING NO FIELDS.
      IF SY-SUBRC EQ 0.
*3-2-4-2) 외주임가공 투입정보 관리 이력 테이블 정보 점검(ISSUE_COMP)
*
*TABLE : ZGTMMT9450
*SELECT 조건 : IDNRK,CHARG,EBELN,EBELP,MENGE,MEINS
*WHRE 조건 : IT_TAB-EBELN,IT_TAB-EBELP,LIFNR,WERKS
*조회된  COMPONENT 자재,배치별 BAPI ITEM 라인 추가

        LOOP AT PT_ZGTMMT9450 ASSIGNING FIELD-SYMBOL(<LS_ZGTMMT94502>).

          LS_COMP-MATERIAL = <LS_ZGTMMT94502>-IDNRK.
          LS_COMP-PLANT = PS_LIST-WERKS.
          LS_COMP-PO_NUMBER = <LS_ZGTMMT94502>-EBELN.
          LS_COMP-PO_ITEM = <LS_ZGTMMT94502>-EBELP.
          LS_COMP-MOVE_TYPE = '543'.
          LS_COMP-BATCH = <LS_ZGTMMT94502>-CHARG.
          LS_COMP-ENTRY_UOM = <LS_ZGTMMT94502>-MEINS.
          LS_COMP-MVT_IND = GC_B.

*"1) ISSUE_COMP=CHARGE <> NULL
*  : ISSUE_COMP-MENGE
*2) ISSUE_COMP=CHARGE """" 이면
*  : PO 소요량정보로 입고수량 대비 투입 처리 수량 산출
*  -> 입고 수량 * 단위당소요량(RESB-BDMNG/EKPO-MENGE)"

          IF <LS_ZGTMMT9450>-CHARG IS NOT INITIAL.
            LS_COMP-ENTRY_QNT = <LS_ZGTMMT94502>-MENGE.
          ELSE.
            READ TABLE PT_RESB ASSIGNING <LS_RESB> WITH KEY  EBELN = <LS_ZGTMMT94502>-EBELN
                                                                                                  EBELP = <LS_ZGTMMT94502>-EBELP
                                                                                                  MATNR = <LS_ZGTMMT94502>-IDNRK.
            IF SY-SUBRC EQ 0.
              IF <LS_RESB>-MENGE IS NOT INITIAL.
                LS_COMP-ENTRY_QNT = PS_LIST-MENGE * ( <LS_RESB>-BDMNG / <LS_RESB>-MENGE ).
              ELSE.
                LS_COMP-ENTRY_QNT = 0.
              ENDIF.
            ELSE.
              CV_CHECK = GC_E.
              EXIT.
            ENDIF.
          ENDIF.

          LS_COMP-LINE_ID += 1.
          CT_ITEM = VALUE #( BASE CT_ITEM ( LS_COMP ) ).
          PS_LIST-LINE_ID = LS_COMP-LINE_ID.

        ENDLOOP.

      ELSE.
        "PO COMPONENT 기준
        READ TABLE PT_RESB WITH KEY EBELN = PS_LIST-EBELN
                                                          EBELP = PS_LIST-EBELP
                                                          BINARY SEARCH TRANSPORTING NO FIELDS.
        IF SY-SUBRC EQ 0.
          LOOP AT PT_RESB ASSIGNING <LS_RESB> FROM SY-TABIX.
            IF <LS_RESB>-EBELN NE PS_LIST-EBELN
              OR <LS_RESB>-EBELP NE PS_LIST-EBELP.
              EXIT.
            ENDIF.

            LS_COMP-MATERIAL = <LS_RESB>-MATNR.
            LS_COMP-PLANT = <LS_RESB>-WERKS.
            LS_COMP-STGE_LOC = <LS_RESB>-LGORT.
            LS_COMP-PO_NUMBER = <LS_RESB>-EBELN.
            LS_COMP-PO_ITEM = <LS_RESB>-EBELP.
            LS_COMP-MOVE_TYPE = '543'.
            LS_COMP-BATCH = <LS_RESB>-CHARG.
            IF <LS_RESB>-MENGE IS NOT INITIAL.
              LS_COMP-ENTRY_QNT = PS_LIST-MENGE * ( <LS_RESB>-BDMNG / <LS_RESB>-MENGE ).
            ELSE.
              LS_COMP-ENTRY_QNT = 0.
            ENDIF.
            LS_COMP-ENTRY_UOM = <LS_RESB>-MEINS.
            LS_COMP-MVT_IND = GC_B.


            "라인추가
            IF <LS_RESB>-XCHPF EQ ABAP_TRUE AND <LS_RESB>-CHARG EQ SPACE.
*"투입자재가 배치관리 자재이고 (ZGTMM_CV_SC_RESBLIST-XCHPF = 'X')
*PO_COMP-CHARG 값이 공백인 경우
*공급업체 재고 테이블 기준 BATCH 번호 추출 투입 처리(선입 선출 기준)
*TABLE : MSLB
*SELECT 조건 : LBLAB 0 이 아닌 CHARG
*WHERE 조건 :
*MATNR = PO_COMP-MATNR
*WERKS = PO_COMP_WERKS
*LIFNR = EKKO-LIFNR
              LV_ERFMG = LS_COMP-ENTRY_QNT. "대상 출고 수량
              READ TABLE PT_MSLB WITH KEY MATNR = <LS_RESB>-MATNR
                                                         WERKS = <LS_RESB>-WERKS
                                                         LIFNR = <LS_RESB>-LIFNR BINARY SEARCH TRANSPORTING NO FIELDS.
              IF SY-SUBRC EQ 0.
                LOOP AT PT_MSLB ASSIGNING <LS_MSLB> FROM SY-TABIX.
                  IF <LS_MSLB>-MATNR NE <LS_RESB>-MATNR
                    OR <LS_MSLB>-WERKS NE <LS_RESB>-WERKS
                    OR <LS_MSLB>-LIFNR NE <LS_RESB>-LIFNR.
                    EXIT.
                  ENDIF.

                  CHECK <LS_MSLB>-LBLAB GE 0. "재고수량이 0보다 큰 경우만 진행

                  "적용 수량 빼기
                  LV_ERFMG_O = LV_ERFMG.
                  LV_ERFMG -= <LS_MSLB>-LBLAB.

                  LS_COMP-BATCH = <LS_MSLB>-CHARG.

                  IF LV_ERFMG LT 0.
                    "적용한 수량이 대상 출고수량 보다 큰 경우
                    IF <LS_MSLB>-XPCBT EQ ABAP_TRUE AND <LS_MSLB>-XPRGI EQ SPACE.
*"BATCH 별 투입 시 지정된 BATCH가 단일 배치단위이면 (MCH1-XPCBT='X')
*BATCH 가용재고전량투입 처리"
* & 부분수량 GI 허용이 SPACE 인 경우
                      LS_COMP-ENTRY_QNT = <LS_MSLB>-LBLAB.
                    ELSE.
                      "단일 배치단위가 아니면 잔량적용
                      LS_COMP-ENTRY_QNT = LV_ERFMG_O.
                    ENDIF.
                  ELSE.
                    LS_COMP-ENTRY_QNT = <LS_MSLB>-LBLAB.
                  ENDIF.

                  "재고수량에서 적용수량 빼기
                  <LS_MSLB>-LBLAB -=  LS_COMP-ENTRY_QNT.

                  LS_COMP-LINE_ID += 1.
                  CT_ITEM = VALUE #( BASE CT_ITEM ( LS_COMP ) ). "라인추가
                  PS_LIST-LINE_ID = LS_COMP-LINE_ID.

                  "적용 수량이 대상 출고수량을 초과한 경우 종료
                  IF LV_ERFMG LE 0.
                    EXIT.
                  ENDIF.

                ENDLOOP.
              ELSE.
                LS_COMP-LINE_ID += 1.
                CT_ITEM = VALUE #( BASE CT_ITEM ( LS_COMP ) ).
                PS_LIST-LINE_ID = LS_COMP-LINE_ID.
              ENDIF.
            ELSE.
              LS_COMP-LINE_ID += 1.
              CT_ITEM = VALUE #( BASE CT_ITEM ( LS_COMP ) ).
              PS_LIST-LINE_ID = LS_COMP-LINE_ID.
            ENDIF.

          ENDLOOP.
        ENDIF.


      ENDIF.
    ENDIF.

  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*& FORM SET_GOODSMVT_ITEM_DNO_NEW
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
*&      --> <LS_LOG_TAB>
*&      <-- LT_ITEM
*&---------------------------------------------------------------------*
FORM SET_GOODSMVT_ITEM_DNO_NEW  USING
                                                         PT_RESB TYPE TY_T_PO_RESB
                                                         PT_DELCOMP TYPE TY_T_PO_DELCOMP
                                                         PT_MSLB TYPE TY_T_MSLB
                                                         PT_ZGTMMT9450 TYPE TY_T_ZGTMMT9450
                                                         PT_VCQTY TYPE TY_T_VC
*                                                         PS_HEAD TYPE BAPI2017_GM_HEAD_01
                                                         PV_LINE "그룹(동일 납품문서) 품목 라인 수
                                   CHANGING CT_ITEM TYPE TY_T_BAPI2017_GM_ITEM_CREATE
                                                    CV_CHECK
                                                    PS_LIST TYPE TY_LIST
                                                    PS_HEAD TYPE BAPI2017_GM_HEAD_01
                                                    PV_VC.

  FIELD-SYMBOLS <LS_RESB> TYPE TY_PO_RESB.

  DATA : LT_LIST   LIKE TABLE OF GS_LIST,
         LS_HEAD   TYPE BAPI2017_GM_HEAD_01,
         LS_ITEM   TYPE BAPI2017_GM_ITEM_CREATE,
         LT_ITEM   TYPE TABLE OF BAPI2017_GM_ITEM_CREATE,
         LV_CODE   TYPE BAPI2017_GM_CODE-GM_CODE,
         LV_DOC    TYPE BAPI2017_GM_HEAD_RET-MAT_DOC,
         LS_BATCH  TYPE BAPIBATCHATT,
         LS_BATCHX TYPE BAPIBATCHATTX,
         LV_MSG    TYPE BAPI_MSG.

  DATA :
    LV_VCQ       TYPE ERFMG,
    LV_TIME      TYPE I,
    LV_CNT_RUN   TYPE INT4,
    LV_START_IDX TYPE INT4,
    LV_END_IDX   TYPE INT4,
    LV_FACTOR .

  DATA:
    LT_RETURN   TYPE STANDARD TABLE OF BAPIRET2,
    LT_ALLOC    TYPE TABLE OF BAPI1003_ALLOC_VALUES_CHAR,
    LT_ALC_NUM  TYPE TABLE OF BAPI1003_ALLOC_VALUES_NUM,
    LT_ALC_CURR TYPE TABLE OF BAPI1003_ALLOC_VALUES_CURR,
    LV_CLASS    TYPE BAPI1003_KEY-CLASSNUM, "KLAH-CLASS,
    LV_STATUS   TYPE BAPI1003_KEY-STATUS,
    LV_KEY      TYPE BAPI1003_KEY-OBJECT,
    LV_MAT18    TYPE MATNR18,
    LV_LENTH    TYPE ATWRT30.

*        LT_VALNUM  TYPE TABLE OF BAPI1003_ALLOC_VALUES_NUM,
*        LS_VALNUM  TYPE BAPI1003_ALLOC_VALUES_NUM,
*        LT_VALCHAR TYPE TABLE OF BAPI1003_ALLOC_VALUES_CHAR,
*        LS_VALCHAR TYPE BAPI1003_ALLOC_VALUES_CHAR,
*        LT_VALCURR TYPE TABLE OF BAPI1003_ALLOC_VALUES_CURR,

*1)라벨정보 유무 확인
  READ TABLE GT_LIST_300 INTO DATA(LS_300)
  WITH KEY DELNO   = PS_LIST-DELNO
                 DELITEM = PS_LIST-DELITEM BINARY SEARCH.
  IF SY-SUBRC = 0.
    DATA(LV_TABIX) = SY-TABIX. CLEAR LS_300.

    LOOP AT GT_LIST_300 INTO LS_300 FROM LV_TABIX.
      IF LS_300-DELNO = PS_LIST-DELNO AND LS_300-DELITEM = PS_LIST-DELITEM.

*2)자재유형이 MCHA/MCFE/HAWA이고,
        CLEAR : LV_TIME, LV_VCQ, LV_FACTOR .

        CASE PS_LIST-MTART.
          WHEN 'MCHA' OR 'MCFE' OR 'HAWA'.
            READ TABLE PT_VCQTY ASSIGNING FIELD-SYMBOL(<VC>)
            WITH KEY PDOC = PS_LIST-EBELN
                           PDOCITEM = PS_LIST-EBELP
                           DPCBT = 'A' BINARY SEARCH.
            IF SY-SUBRC = 0.
*2-1)FACTOR BATCH 이면, 한 번에 생성
              CLEAR LV_VCQ.
              LV_TIME = 1.
*배치번호 : 조장정보로 설정_변수 설정
              LV_FACTOR = GC_X.
            ELSE.
*2-2) 특성(조장)정보를 체크하여 조장 단위 기준으로 입고수량 분할
*26.07.20 기준 변경_라벨정보 있는경우는 라벨 항번 별 아이템 구성/입고수량=라벨수량으로..
              READ TABLE PT_VCQTY ASSIGNING <VC>
              WITH KEY PDOC = PS_LIST-EBELN
                             PDOCITEM = PS_LIST-EBELP BINARY SEARCH.
              IF SY-SUBRC = 0.
**FACTOR BATCH 아니면, 조장 단위 기준으로 입고수량 분할
*                PV_VC = 'X'.     "분할입고대상 여부 표기
                LV_TIME = 1."PS_LIST-MENGE / <VC>-LENGTH. "분할수 = 입고수량/조장단위
                CLEAR LV_VCQ ."= PS_LIST-MENGE / LV_TIME. "분할입고수량 = 입고수량/분할 수
              ENDIF.

*--------------------------------------------------------------------*
**-- 26.09 hawa 분기 추가 / DPCBT = 0 이고 LENGTH 가 1 인 것
*--------------------------------------------------------------------*
              IF PS_LIST-MTART = 'HAWA'.
                READ TABLE PT_VCQTY ASSIGNING <VC>
                      WITH KEY PDOC = PS_LIST-EBELN
                              PDOCITEM = PS_LIST-EBELP
                              DPCBT = '' BINARY SEARCH.
                IF SY-SUBRC EQ 0 AND <VC>-LENGTH = 1.
                  LV_TIME = 1.
                  CLEAR LV_VCQ .
                ENDIF.
              ENDIF.
*--------------------------------------------------------------------*
            ENDIF.
          WHEN OTHERS.
            CLEAR LV_VCQ.
            LV_TIME = 1.
        ENDCASE.

        DO LV_TIME TIMES.

          LS_ITEM-MATERIAL = PS_LIST-MATNR.
          LS_ITEM-PLANT = PS_LIST-WERKS.
          LS_ITEM-STGE_LOC = PS_LIST-LGORT.
          LS_ITEM-PO_NUMBER = PS_LIST-EBELN.
          LS_ITEM-PO_ITEM = PS_LIST-EBELP.
          LS_ITEM-MOVE_TYPE = '101'.
          LS_ITEM-STCK_TYPE = PS_LIST-INSMK.
          LS_ITEM-ENTRY_QNT = COND #( WHEN LV_VCQ IS INITIAL THEN LS_300-MENGE
                                                             ELSE LV_VCQ ).
          LS_ITEM-ENTRY_UOM = PS_LIST-MEINS.
          LS_ITEM-VENDRBATCH = PS_LIST-LICHA.
          LS_ITEM-PROD_DATE = PS_LIST-HSDAT.
*ITEM_TEXT                    DELNO&-&DELITEM INV2602000001-1
          LS_ITEM-ITEM_TEXT = PS_LIST-DELNO && '-' && PS_LIST-DELITEM.

          CASE PS_LIST-PSTYP.
            WHEN SPACE OR '0'. "일반
*CASE1. 일반 입고 : IT_TAB-PSTYP = "" AND
*CASE2. 일반입고 : 배치관리유형 DPCBT = 'A'(FACTOR BATCH)이면,
*배치번호 : 조장정보로 설정.
              IF LV_FACTOR = GC_X.
                LS_ITEM-BATCH = CONV I( <VC>-LENGTH ).
                CONDENSE LS_ITEM-BATCH NO-GAPS.

              ELSE.
**CASE3. 처리 자재의  자재유형이 HAWA 이면 DEFAULT 값 채번 /배치번호 : GO00000001"
                IF PS_LIST-MTART EQ 'HAWA'.
                  SELECT SINGLE  DPCBT
                    FROM MARC
                    WHERE MATNR EQ @PS_LIST-MATNR
                    AND WERKS EQ @PS_LIST-WERKS
                    INTO @DATA(LV_DPCBT).

                  CASE LV_DPCBT.
*2-2)공백이면 DEFAULT 값 채번_배치번호 : GO00000001"
                    WHEN 'A' OR SPACE.
                      LS_ITEM-BATCH = 'GO00000001'.
*2-1)MARC-DPCBT = 'C'->자동채번
                    WHEN 'C'.
                    WHEN OTHERS.
                  ENDCASE.

                ELSE.
*CASE4. 일반 입고 : 플랜트&자재그룹(MATKL)이 ZGTPPT1010에 존재하면,
*배치번호 : 자재번호로 설정.
                  READ TABLE GT_ZGTPPT1010 TRANSPORTING NO FIELDS
                  WITH KEY FLD_01 = PS_LIST-WERKS
                                 FLD_02 = PS_LIST-MATKL BINARY SEARCH.

                  IF SY-SUBRC = 0.
                    SHIFT PS_LIST-MATNR LEFT DELETING LEADING '0'.
                    LS_ITEM-BATCH = PS_LIST-MATNR.
                  ENDIF.
                ENDIF.
              ENDIF.

            WHEN '3'.  "외주 임가공_메인품목 자재 배치 설정 조건 체크 추가
*배치관리 유형 FACTOR BATCH이면(DPCBT = 'A') 조장정보로 채번,없으면 자동채번
              IF LV_FACTOR = GC_X. "SY-SUBRC = 0.
                LS_ITEM-BATCH = CONV I( <VC>-LENGTH ).
                CONDENSE LS_ITEM-BATCH NO-GAPS.
              ENDIF.

            WHEN OTHERS.
          ENDCASE.

*>S.26.07.29_3-2) BAP_GOODSMVT_CREATE 실행 전 FACTOR 배치 유형인 경우
*배치 클래스의 속성 정보 특성 업데이트 BAPI 선 수행
          IF PS_LIST-DPCBT = 'A'. "FACTOR BATCH
            CLEAR LV_LENTH.
*3-2-1) FACTOR BATCH 여부 체크 & 조장정보 가져오기.
            READ TABLE PT_VCQTY ASSIGNING FIELD-SYMBOL(<VC3>)
            WITH KEY PDOC = PS_LIST-EBELN
                           PDOCITEM = PS_LIST-EBELP
                           DPCBT = 'A' BINARY SEARCH.
            IF SY-SUBRC = 0.
              LV_LENTH = CONV I( <VC3>-LENGTH ).
              CONDENSE LV_LENTH NO-GAPS.
            ENDIF.
*3-2-2) FACTOR 배치 자재의 CLASS 조회
* CLASS번호
            CLEAR: LV_CLASS.
            CALL FUNCTION 'CLFC_BATCH_ALLOCATION_TO_CLASS'
              EXPORTING
                MATERIAL           = PS_LIST-MATNR "입고자재
                PLANT              = PS_LIST-WERKS "플랜트
                CLASSTYPE          = '023'       "클래스유형(배치)
              IMPORTING
                CLASS              = LV_CLASS
              EXCEPTIONS
                NO_CLASS_FOUND     = 1
                NO_CLASSTYPE_FOUND = 2
                OTHERS             = 3.

            CHECK LV_CLASS IS NOT INITIAL.
*3-2-3)배치 클래스 속성 정보 업데이트  BAPI 수행
            CLEAR LT_ALC_NUM.
            LT_ALC_NUM[] = VALUE #( BASE LT_ALC_NUM
                                                  ( CHARACT = 'SAP_MILLCA_LENGTH'
                                                    VALUE_FROM = LV_LENTH )
                                                  ( CHARACT = 'SAP_MILLCA_LENGTH_SUB'
                                                    VALUE_FROM = LV_LENTH ) ).
            CLEAR : LT_RETURN. "LV_MAT18, LV_KEY,
            SELECT SINGLE CUOBJ_BM
                 FROM MCH1
               WHERE MATNR = @PS_LIST-MATNR
                    AND CHARG = @LS_ITEM-BATCH
               INTO @DATA(LV_OBJKEY).

            IF LV_OBJKEY IS NOT INITIAL.
              CALL FUNCTION 'BAPI_OBJCL_CHANGE_KEY'
                EXPORTING
                  CLOBJECTKEY         = LV_OBJKEY
                  CLASSNUM            = LV_CLASS
                IMPORTING
                  CLASSIF_STATUS      = LV_STATUS
                TABLES
                  ALLOCVALUESNUM_NEW  = LT_ALC_NUM
                  ALLOCVALUESCHAR_NEW = LT_ALLOC
                  ALLOCVALUESCURR_NEW = LT_ALC_CURR
                  RETURN              = LT_RETURN.
*            LV_MAT18 = |{ PS_LIST-MATNR ALPHA = IN }|.
*            LV_KEY(18) = LV_MAT18.
*            LV_KEY+18(10) = LV_LENTH. "선수행시에는 배치번호 없음->조장=배치번호
*
*            CALL FUNCTION 'BAPI_OBJCL_CHANGE'
*              EXPORTING
*                OBJECTKEY          = LV_KEY
*                OBJECTTABLE        = 'MCH1'
*                CLASSNUM           = LV_CLASS
*                CLASSTYPE          = '023'
*              TABLES
*                ALLOCVALUESNUMNEW  = LT_ALC_NUM
*                ALLOCVALUESCHARNEW = LT_ALLOC
*                ALLOCVALUESCURRNEW = LT_ALC_CURR
*                RETURN             = LT_RETURN.
              READ TABLE LT_RETURN ASSIGNING FIELD-SYMBOL(<LS_R2TURN>) WITH KEY TYPE = GC_E.
              IF SY-SUBRC EQ 0.
*      오류
                CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
              ELSE.
*      배치특성 성공
                CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
                  EXPORTING
                    WAIT = ABAP_TRUE.
              ENDIF.
            ENDIF.
          ENDIF.
*<E.26.07.29_ZGODEV04.

          LS_ITEM-MVT_IND = GC_B.
          LS_ITEM-LINE_ID = LINES( CT_ITEM ) + 1.
          CT_ITEM = VALUE #( BASE CT_ITEM ( LS_ITEM ) ).

          PS_LIST-LINE_ID = LS_ITEM-LINE_ID. "BAPI 성공 COMMIT후 업데이트 위한 구분용
        ENDDO.

*        CHECK PS_LIST-PSTYP EQ GC_3. "외주 임가공인 경우 추가 체크 로직
        IF PS_LIST-PSTYP EQ GC_3. "외주 임가공인 경우 추가 체크 로직.
*3-2-4-2) COMPONENT 소비량 산출(COMP_QTY)
*: 입고 수량 * 단위당소요량(RESB-BDMNG/EKPO-MENGE)
*COMPONENT 자재 항목 라인별로 BAPI ITEM 라인 추가
          DATA:
            LV_ERFMG   TYPE MENGV13,
            LV_ERFMG_O TYPE ERFMG.

          FIELD-SYMBOLS <LS_MSLB> TYPE TY_MSLB.

          DATA LS_COMP TYPE BAPI2017_GM_ITEM_CREATE.
          LS_COMP-PARENT_ID	 = LS_ITEM-LINE_ID.
          LS_COMP-LINE_ID = LS_ITEM-LINE_ID.

          READ TABLE PT_DELCOMP WITH KEY EBELN = PS_LIST-EBELN
                                                            EBELP = PS_LIST-EBELP
                                                            DELNO = PS_LIST-DELNO
                                                            DELITEM = PS_LIST-DELITEM BINARY SEARCH TRANSPORTING NO FIELDS.
          IF SY-SUBRC EQ 0.
            "납품문서 COMPONENT 기준
            LOOP AT PT_DELCOMP ASSIGNING FIELD-SYMBOL(<LS_DELCOMP>) FROM SY-TABIX.
              IF <LS_DELCOMP>-EBELN NE PS_LIST-EBELN
                OR <LS_DELCOMP>-EBELP NE PS_LIST-EBELP
                OR <LS_DELCOMP>-DELNO NE PS_LIST-DELNO
                OR <LS_DELCOMP>-DELITEM NE PS_LIST-DELITEM.
                EXIT.
              ENDIF.

              LS_COMP-MATERIAL = <LS_DELCOMP>-IDNRK.
              LS_COMP-PLANT = <LS_DELCOMP>-WERKS.
              LS_COMP-STGE_LOC = <LS_DELCOMP>-LGORT.
              LS_COMP-PO_NUMBER = <LS_DELCOMP>-EBELN.
              LS_COMP-PO_ITEM = <LS_DELCOMP>-EBELP.
              LS_COMP-MOVE_TYPE = '543'.
              LS_COMP-BATCH = <LS_DELCOMP>-CHARG.
              LS_COMP-ENTRY_QNT = <LS_DELCOMP>-ISSUE_QTY.
              LS_COMP-ENTRY_UOM = <LS_DELCOMP>-ISSUE_UNIT.
              LS_COMP-MVT_IND = GC_B.

              "라인추가
              IF <LS_DELCOMP>-XCHPF EQ ABAP_TRUE AND <LS_DELCOMP>-CHARG EQ SPACE.
*"투입자재가 배치관리 자재이고 (ZGTMM_CV_SC_RESBLIST-XCHPF = 'X')
*PO_COMP-CHARG 값이 공백인 경우
*공급업체 재고 테이블 기준 BATCH 번호 추출 투입 처리(선입 선출 기준)
*TABLE : MSLB
*SELECT 조건 : LBLAB 0 이 아닌 CHARG
*WHERE 조건 :
*MATNR = PO_COMP-MATNR
*WERKS = PO_COMP_WERKS
*LIFNR = EKKO-LIFNR
                LV_ERFMG = LS_COMP-ENTRY_QNT. "대상 출고 수량
                READ TABLE PT_MSLB WITH KEY MATNR = <LS_DELCOMP>-IDNRK
                                                           WERKS = <LS_DELCOMP>-WERKS
                                                           LIFNR = <LS_DELCOMP>-LIFNR BINARY SEARCH TRANSPORTING NO FIELDS.
                IF SY-SUBRC EQ 0.
                  LOOP AT PT_MSLB ASSIGNING <LS_MSLB> FROM SY-TABIX.
                    IF <LS_MSLB>-MATNR NE <LS_DELCOMP>-IDNRK
                      OR <LS_MSLB>-WERKS NE <LS_DELCOMP>-WERKS
                      OR <LS_MSLB>-LIFNR NE <LS_DELCOMP>-LIFNR.
                      EXIT.
                    ENDIF.

                    CHECK <LS_MSLB>-LBLAB GE 0. "재고수량이 0보다 큰 경우만 진행

                    "적용 수량 빼기
                    LV_ERFMG_O = LV_ERFMG.
                    LV_ERFMG -= <LS_MSLB>-LBLAB.

                    LS_COMP-BATCH = <LS_MSLB>-CHARG.

                    IF LV_ERFMG LT 0.
                      "적용한 수량이 대상 출고수량 보다 큰 경우
                      IF <LS_MSLB>-XPCBT EQ ABAP_TRUE AND <LS_MSLB>-XPRGI EQ SPACE.
*"BATCH 별 투입 시 지정된 BATCH가 단일 배치단위이면 (MCH1-XPCBT='X')
*BATCH 가용재고전량투입 처리"
*& 부분수량 GI 허용이 SPACE 인 경우
                        LS_COMP-ENTRY_QNT = <LS_MSLB>-LBLAB.
                      ELSE.
                        "단일 배치단위가 아니면 잔량적용
                        LS_COMP-ENTRY_QNT = LV_ERFMG_O.
                      ENDIF.
                    ELSE.
                      LS_COMP-ENTRY_QNT = <LS_MSLB>-LBLAB.
                    ENDIF.

                    "재고수량에서 적용수량 빼기
                    <LS_MSLB>-LBLAB -=  LS_COMP-ENTRY_QNT.

                    LS_COMP-LINE_ID += 1.
                    CT_ITEM = VALUE #( BASE CT_ITEM ( LS_COMP ) ). "라인추가
                    PS_LIST-LINE_ID = LS_COMP-LINE_ID.

                    "적용 수량이 대상 출고수량을 초과한 경우 종료
                    IF LV_ERFMG LE 0.
                      EXIT.
                    ENDIF.

                  ENDLOOP.
                ELSE.
                  LS_COMP-LINE_ID += 1.
                  CT_ITEM = VALUE #( BASE CT_ITEM ( LS_COMP ) ).
                  PS_LIST-LINE_ID = LS_COMP-LINE_ID.
                ENDIF.
              ELSE.
                LS_COMP-LINE_ID += 1.
                CT_ITEM = VALUE #( BASE CT_ITEM ( LS_COMP ) ).
                PS_LIST-LINE_ID = LS_COMP-LINE_ID.
              ENDIF.
            ENDLOOP.
          ELSE.
            READ TABLE PT_ZGTMMT9450 WITH KEY EBELN = PS_LIST-EBELN
                                                                         EBELP = PS_LIST-EBELP
                                                                         WERKS = PS_LIST-WERKS
                                                                  BINARY SEARCH TRANSPORTING NO FIELDS.
            IF SY-SUBRC EQ 0.
*
*3-2-4-2) 외주임가공 투입정보 관리 이력 테이블 정보 점검(ISSUE_COMP)
*
*TABLE : ZGTMMT9450
*SELECT 조건 : IDNRK,CHARG,EBELN,EBELP,MENGE,MEINS
*WHRE 조건 : IT_TAB-EBELN,IT_TAB-EBELP,LIFNR,WERKS
*조회된  COMPONENT 자재,배치별 BAPI ITEM 라인 추가

              LOOP AT PT_ZGTMMT9450 ASSIGNING FIELD-SYMBOL(<LS_ZGTMMT9450>).

                LS_COMP-MATERIAL = <LS_ZGTMMT9450>-IDNRK.
                LS_COMP-PLANT = PS_LIST-WERKS.
                LS_COMP-PO_NUMBER = <LS_ZGTMMT9450>-EBELN.
                LS_COMP-PO_ITEM = <LS_ZGTMMT9450>-EBELP.
                LS_COMP-MOVE_TYPE = '543'.
                LS_COMP-BATCH = <LS_ZGTMMT9450>-CHARG.
                LS_COMP-ENTRY_UOM = <LS_ZGTMMT9450>-MEINS.
                LS_COMP-MVT_IND = GC_B.

*"1) ISSUE_COMP=CHARGE <> NULL
*  : ISSUE_COMP-MENGE
*2) ISSUE_COMP=CHARGE """" 이면
*  : PO 소요량정보로 입고수량 대비 투입 처리 수량 산출
*  -> 입고 수량 * 단위당소요량(RESB-BDMNG/EKPO-MENGE)"

                IF <LS_ZGTMMT9450>-CHARG IS NOT INITIAL.
                  LS_COMP-ENTRY_QNT = <LS_ZGTMMT9450>-MENGE.
                ELSE.

                  READ TABLE PT_RESB ASSIGNING <LS_RESB> WITH KEY  EBELN = <LS_ZGTMMT9450>-EBELN
                                                                                                        EBELP = <LS_ZGTMMT9450>-EBELP
                                                                                                        MATNR = <LS_ZGTMMT9450>-IDNRK.
                  IF SY-SUBRC EQ 0.
                    IF <LS_RESB>-MENGE IS NOT INITIAL.
                      LS_COMP-ENTRY_QNT = PS_LIST-MENGE * ( <LS_RESB>-BDMNG / <LS_RESB>-MENGE ).
                    ELSE.
                      LS_COMP-ENTRY_QNT = 0.
                    ENDIF.
                  ELSE.
                    CV_CHECK = GC_E.
                    EXIT.
                  ENDIF.
                ENDIF.

                LS_COMP-LINE_ID += 1.
                CT_ITEM = VALUE #( BASE CT_ITEM ( LS_COMP ) ).
                PS_LIST-LINE_ID = LS_COMP-LINE_ID.

              ENDLOOP.

            ELSE.
              "PO COMPONENT 기준
              READ TABLE PT_RESB WITH KEY EBELN = PS_LIST-EBELN
                                                                EBELP = PS_LIST-EBELP
                                                                BINARY SEARCH TRANSPORTING NO FIELDS.
              IF SY-SUBRC EQ 0.
                LOOP AT PT_RESB ASSIGNING <LS_RESB> FROM SY-TABIX.
                  IF <LS_RESB>-EBELN NE PS_LIST-EBELN
                    OR <LS_RESB>-EBELP NE PS_LIST-EBELP.
                    EXIT.
                  ENDIF.

                  LS_COMP-MATERIAL = <LS_RESB>-MATNR.
                  LS_COMP-PLANT = <LS_RESB>-WERKS.
                  LS_COMP-STGE_LOC = <LS_RESB>-LGORT.
                  LS_COMP-PO_NUMBER = <LS_RESB>-EBELN.
                  LS_COMP-PO_ITEM = <LS_RESB>-EBELP.
                  LS_COMP-MOVE_TYPE = '543'.
                  LS_COMP-BATCH = <LS_RESB>-CHARG.
                  IF <LS_RESB>-MENGE IS NOT INITIAL.
                    LS_COMP-ENTRY_QNT = PS_LIST-MENGE * ( <LS_RESB>-BDMNG / <LS_RESB>-MENGE ).
                  ELSE.
                    LS_COMP-ENTRY_QNT = 0.
                  ENDIF.
                  LS_COMP-ENTRY_UOM = <LS_RESB>-MEINS.
                  LS_COMP-MVT_IND = GC_B.


                  "라인추가
                  IF <LS_RESB>-XCHPF EQ ABAP_TRUE AND <LS_RESB>-CHARG EQ SPACE.
*"투입자재가 배치관리 자재이고 (ZGTMM_CV_SC_RESBLIST-XCHPF = 'X')
*PO_COMP-CHARG 값이 공백인 경우
*공급업체 재고 테이블 기준 BATCH 번호 추출 투입 처리(선입 선출 기준)
*TABLE : MSLB
*SELECT 조건 : LBLAB 0 이 아닌 CHARG
*WHERE 조건 :
*MATNR = PO_COMP-MATNR
*WERKS = PO_COMP_WERKS
*LIFNR = EKKO-LIFNR
                    LV_ERFMG = LS_COMP-ENTRY_QNT. "대상 출고 수량
                    READ TABLE PT_MSLB WITH KEY MATNR = <LS_RESB>-MATNR
                                                               WERKS = <LS_RESB>-WERKS
                                                               LIFNR = <LS_RESB>-LIFNR BINARY SEARCH TRANSPORTING NO FIELDS.
                    IF SY-SUBRC EQ 0.
                      LOOP AT PT_MSLB ASSIGNING <LS_MSLB> FROM SY-TABIX.
                        IF <LS_MSLB>-MATNR NE <LS_RESB>-MATNR
                          OR <LS_MSLB>-WERKS NE <LS_RESB>-WERKS
                          OR <LS_MSLB>-LIFNR NE <LS_RESB>-LIFNR.
                          EXIT.
                        ENDIF.

                        CHECK <LS_MSLB>-LBLAB GE 0. "재고수량이 0보다 큰 경우만 진행

                        "적용 수량 빼기
                        LV_ERFMG_O = LV_ERFMG.
                        LV_ERFMG -= <LS_MSLB>-LBLAB.

                        LS_COMP-BATCH = <LS_MSLB>-CHARG.

                        IF LV_ERFMG LT 0.
                          "적용한 수량이 대상 출고수량 보다 큰 경우
                          IF <LS_MSLB>-XPCBT EQ ABAP_TRUE AND <LS_MSLB>-XPRGI EQ SPACE.
*"BATCH 별 투입 시 지정된 BATCH가 단일 배치단위이면 (MCH1-XPCBT='X')
*BATCH 가용재고전량투입 처리"
* & 부분수량 GI 허용이 SPACE 인 경우
                            LS_COMP-ENTRY_QNT = <LS_MSLB>-LBLAB.
                          ELSE.
                            "단일 배치단위가 아니면 잔량적용
                            LS_COMP-ENTRY_QNT = LV_ERFMG_O.
                          ENDIF.
                        ELSE.
                          LS_COMP-ENTRY_QNT = <LS_MSLB>-LBLAB.
                        ENDIF.

                        "재고수량에서 적용수량 빼기
                        <LS_MSLB>-LBLAB -=  LS_COMP-ENTRY_QNT.

                        LS_COMP-LINE_ID += 1.
                        CT_ITEM = VALUE #( BASE CT_ITEM ( LS_COMP ) ). "라인추가
                        PS_LIST-LINE_ID = LS_COMP-LINE_ID.

                        "적용 수량이 대상 출고수량을 초과한 경우 종료
                        IF LV_ERFMG LE 0.
                          EXIT.
                        ENDIF.

                      ENDLOOP.
                    ELSE.
                      LS_COMP-LINE_ID += 1.
                      CT_ITEM = VALUE #( BASE CT_ITEM ( LS_COMP ) ).
                      PS_LIST-LINE_ID = LS_COMP-LINE_ID.
                    ENDIF.
                  ELSE.
                    LS_COMP-LINE_ID += 1.
                    CT_ITEM = VALUE #( BASE CT_ITEM ( LS_COMP ) ).
                    PS_LIST-LINE_ID = LS_COMP-LINE_ID.
                  ENDIF.

                ENDLOOP.
              ENDIF.
            ENDIF.
          ENDIF.
        ENDIF.

*1.자재유형이 MCHA/MCFE/HAWA & FACTOR BATCH 아닌 자재->조장단위로 수량 분할 입고.
*1-1).라인아이템이 많은 경우, 자재문서 생성이 안되는 에러 있으므로 납품문서 품목별로 분할 생성한다.
*1-2)FI전표는 최대 999라인만 설정가능한데, 조장으로 분할 처리 시, 품목으로 생성해도 초과되는 경우가
*있을 수 있어, 아이템라인 495라인 이상일 경우 분할 생성되게 조정
*2.위 1번 이외는 납품문서 번호 기준으로 선택한 품목 정보 모두 아이템에 묶어 한 개 자재문서로 생성이라
*아래 타지 않고 EXIT. 기존 바피 로직 탄다.
        "실행 건 계산
        CLEAR : LV_CNT_RUN, LV_START_IDX, LV_END_IDX.

        LV_CNT_RUN = LINES( CT_ITEM ) DIV GC_MAX.
        IF LINES( CT_ITEM ) MOD GC_MAX NE 0 OR LV_CNT_RUN = 0.
          LV_CNT_RUN += 1.
        ENDIF.

        IF LV_CNT_RUN = 1.
*최대 라인 수 이내인 경우라도..납품번호/품목이 여러개인 대상은 품목별로 생성
          PV_VC = COND #( WHEN PV_LINE > 1 THEN GC_X ELSE '' ). "
        ENDIF.

        CHECK PV_VC  IS NOT INITIAL.

*BAPI 실행
        DO LV_CNT_RUN TIMES.
          CLEAR LT_ITEM.

          "시작 TABIX
          LV_START_IDX = SY-INDEX - 1.
          LV_START_IDX *= GC_MAX.
          LV_START_IDX += 1.

          "종료 TABIX
          LV_END_IDX = LV_START_IDX + GC_MAX.

          LOOP AT CT_ITEM ASSIGNING FIELD-SYMBOL(<LS_ITEM>).
            "종료 TAB INDEX 보다 크거나 같으면 종료
            IF SY-TABIX GE LV_END_IDX.
              EXIT.
            ENDIF.
            "라인추가
            LT_ITEM[] = VALUE #( BASE LT_ITEM ( CORRESPONDING #( <LS_ITEM> ) ) ).
          ENDLOOP.

          CLEAR : LV_DOC, GT_RETURN, GT_ZPPT0001.
*       "GMCODE
          LV_CODE = '01'. "입고

          IF PS_HEAD IS INITIAL.
            PS_HEAD = VALUE #( PSTNG_DATE  = GV_BUDAT
                                           DOC_DATE     = GV_BUDAT
                                           REF_DOC_NO = COND #( WHEN P_DNO = GC_X
                                                                                  THEN PS_LIST-DELNO ELSE '' )
                                           PR_UNAME     = SY-UNAME ).
          ELSE.
            IF PS_HEAD-REF_DOC_NO IS INITIAL.
              PS_HEAD-REF_DOC_NO = PS_LIST-DELNO.
            ENDIF.
          ENDIF.

          CALL FUNCTION 'BAPI_GOODSMVT_CREATE'
            EXPORTING
              GOODSMVT_HEADER  = PS_HEAD
              GOODSMVT_CODE    = LV_CODE
            IMPORTING
              MATERIALDOCUMENT = LV_DOC
            TABLES
              GOODSMVT_ITEM    = LT_ITEM
              RETURN           = GT_RETURN.

          IF LV_DOC IS INITIAL.
            READ TABLE GT_RETURN ASSIGNING FIELD-SYMBOL(<LS_RT2>) WITH KEY TYPE = GC_E.
            IF SY-SUBRC EQ 0.
*오류
              CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

              READ TABLE GT_LIST ASSIGNING FIELD-SYMBOL(<MAIN2>)
              WITH KEY EBELN = PS_LIST-EBELN
                             EBELP = PS_LIST-EBELP BINARY SEARCH.
              IF SY-SUBRC = 0.
                DATA(LV_TABIXCC) = SY-TABIX.
                <MAIN2>-STATUS    = ICON_LED_RED.
                <MAIN2>-MESSAGE = <LS_RT2>-MESSAGE.
                MODIFY GT_LIST FROM <MAIN2> INDEX LV_TABIXCC.
              ENDIF.
            ENDIF.

          ELSE.
*성공
            CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
              EXPORTING
                WAIT = ABAP_TRUE.

*MAIN ALV UPDATE
            READ TABLE GT_LIST ASSIGNING FIELD-SYMBOL(<MAIN22>)
            WITH KEY DELNO    = PS_LIST-DELNO
                           DELITEM  = PS_LIST-DELITEM
                           EBELN     = PS_LIST-EBELN
                           EBELP     = PS_LIST-EBELP BINARY SEARCH.
            IF SY-SUBRC = 0.
              DATA(LV_TABIX22) = SY-TABIX.
              <MAIN22>-STATUS    = ICON_LED_GREEN.
              <MAIN22>-MBLNR     = LV_DOC .
              <MAIN22>-GRBUDAT = GV_BUDAT.
              <MAIN22>-BUDAT     = COND #( WHEN P_LNO = GC_X THEN GV_BUDAT ELSE <MAIN22>-BUDAT ).
              <MAIN22>-MESSAGE = '입고 처리 완료'(M14).
              CLEAR <MAIN22>-EDIT. "수정불가
              MODIFY GT_LIST FROM <MAIN22> INDEX LV_TABIX22.
            ENDIF.

*배치자재인 경우(MARC-XCHPF=X) 배치마스터 제조일자 업데이트
*->배치마스터 업데이트 성공 시, 자재문서 기준 꼬리표번호 테이블 업데이트(ZPPT0001)
            IF <MAIN22>-XCHPF = GC_X .
              PERFORM BATCH_CHANGE_NEW TABLES PT_VCQTY USING <MAIN22> PS_LIST.
            ENDIF.

            IF GT_ZPPT0001[] IS NOT INITIAL.
              MODIFY ZPPT0001 FROM TABLE GT_ZPPT0001.
              COMMIT WORK AND WAIT.
            ENDIF.

            CLEAR : GT_ZPPT0001.
          ENDIF.
        ENDDO.
      ENDIF.
    ENDLOOP.

*라벨정보 없는 대상은..
  ELSE.
*1.자재유형이 MCHA/MCFE/HAWA이면, 특성(조장)정보를 체크하여 조장 단위 기준으로 입고수량 분할
*분할 된 라인만큼 LINE_ID 추가하여 분할 입고. 각 배치 생성 되도록..
    CLEAR : LV_DPCBT, LV_TIME, LV_VCQ, LV_FACTOR.

    CASE PS_LIST-MTART.
      WHEN 'MCHA' OR 'MCFE' OR 'HAWA'.
        READ TABLE PT_VCQTY ASSIGNING FIELD-SYMBOL(<VC2>)
        WITH KEY PDOC = PS_LIST-EBELN
                       PDOCITEM = PS_LIST-EBELP
                       DPCBT = 'A'  BINARY SEARCH.
        IF SY-SUBRC = 0.
*FACTOR BATCH는 분할하지 않고 하나의 아이템(총수량)으로 생성
          CLEAR LV_VCQ.
          LV_TIME = 1.
          LV_FACTOR = GC_X.
        ELSE.
          READ TABLE PT_VCQTY ASSIGNING <VC2>
          WITH KEY PDOC = PS_LIST-EBELN
                         PDOCITEM = PS_LIST-EBELP BINARY SEARCH.
          IF SY-SUBRC = 0.
*FACTOR BATCH 아니면, 조장 단위 기준으로 입고수량 분할
            PV_VC = 'X'.     "분할입고대상 여부 표기
            LV_TIME = PS_LIST-MENGE / <VC2>-LENGTH. "분할수 = 입고수량/조장단위
            LV_VCQ = PS_LIST-MENGE / LV_TIME. "분할입고수량 = 입고수량/분할 수
          ENDIF.

*--------------------------------------------------------------------*
**-- 26.09 hawa 분기 추가 / DPCBT = 0 이고 LENGTH 가 1 인 것
*--------------------------------------------------------------------*
          IF PS_LIST-MTART = 'HAWA'.
            READ TABLE PT_VCQTY ASSIGNING <VC>
                  WITH KEY PDOC = PS_LIST-EBELN
                          PDOCITEM = PS_LIST-EBELP
                          DPCBT = '' BINARY SEARCH.
            IF SY-SUBRC EQ 0 AND <VC>-LENGTH = 1.
              LV_TIME = 1.
              CLEAR LV_VCQ .
            ENDIF.
          ENDIF.
*--------------------------------------------------------------------*

        ENDIF.

      WHEN OTHERS.
**1.자재유형이 MCHA/MCFE/HAWA아니면,아이템(총수량)으로 생성
        CLEAR LV_VCQ.
        LV_TIME = 1.
    ENDCASE.

    DO LV_TIME TIMES.

      LS_ITEM-MATERIAL = PS_LIST-MATNR.
      LS_ITEM-PLANT = PS_LIST-WERKS.
      LS_ITEM-STGE_LOC = PS_LIST-LGORT.
      LS_ITEM-PO_NUMBER = PS_LIST-EBELN.
      LS_ITEM-PO_ITEM = PS_LIST-EBELP.
      LS_ITEM-MOVE_TYPE = '101'.
      LS_ITEM-STCK_TYPE = PS_LIST-INSMK.
      LS_ITEM-ENTRY_QNT = COND #( WHEN LV_VCQ IS INITIAL THEN PS_LIST-ERFMG
                                                         ELSE LV_VCQ ).
      LS_ITEM-ENTRY_UOM = PS_LIST-MEINS.
      LS_ITEM-VENDRBATCH = PS_LIST-LICHA.
      LS_ITEM-PROD_DATE = PS_LIST-HSDAT.
*ITEM_TEXT                    DELNO&-&DELITEM GO2026020001-10
      LS_ITEM-ITEM_TEXT = PS_LIST-DELNO && '-' && PS_LIST-DELITEM.

      CASE PS_LIST-PSTYP.
        WHEN SPACE OR '0'. "일반
*CASE1. 일반 입고 : IT_TAB-PSTYP = ""
*1)배치관리 유형 FACTOR BATCH이면(DPCBT = 'A') 조장정보로 채번,
          IF LV_FACTOR = GC_X.
            READ TABLE PT_VCQTY ASSIGNING <VC2>
            WITH KEY PDOC = PS_LIST-EBELN
                           PDOCITEM = PS_LIST-EBELP
                           DPCBT = 'A'  BINARY SEARCH.
            IF SY-SUBRC = 0.
              LS_ITEM-BATCH = CONV I( <VC2>-LENGTH ).
              CONDENSE LS_ITEM-BATCH NO-GAPS.
            ENDIF.
*2)배치관리 유형 FACTOR BATCH 아니면,
          ELSE.
*2-1)처리 자재의  자재유형이 HAWA 이면 DPCBT(배치유형)에 따라 구분
            IF PS_LIST-MTART EQ 'HAWA'.
*              LS_ITEM-BATCH = 'GO00000001'.
              SELECT SINGLE  DPCBT
              FROM MARC
              WHERE MATNR EQ @PS_LIST-MATNR
                   AND WERKS EQ @PS_LIST-WERKS
              INTO @LV_DPCBT.

              CASE LV_DPCBT.
*2-1-1)'A' OR 공백이면 Default 값 채번_배치번호 : GO00000001"
                WHEN 'A' OR SPACE.
                  LS_ITEM-BATCH = 'GO00000001'.
*2-1-2)MARC-DPCBT = 'C'->자동채번
                WHEN 'C'.
                  LS_ITEM-BATCH = ''.
                WHEN OTHERS.
              ENDCASE.

            ELSE.
*CASE2. 일반 입고 : 플랜트&자재그룹(MATKL)이 ZGTPPT1010에 존재하면,
*배치번호 : 자재번호
              READ TABLE GT_ZGTPPT1010 TRANSPORTING NO FIELDS
              WITH KEY FLD_01 = PS_LIST-WERKS
                             FLD_02 = PS_LIST-MATKL BINARY SEARCH.

              IF SY-SUBRC = 0.
                SHIFT PS_LIST-MATNR LEFT DELETING LEADING '0'.
                LS_ITEM-BATCH = PS_LIST-MATNR.
              ENDIF.
            ENDIF.
          ENDIF.

        WHEN '3'.  "외주 임가공_메인품목 자재 배치 설정 조건 체크 추가
*배치관리 유형 FACTOR BATCH이면(DPCBT = 'A') 조장정보로 채번,없으면 자동채번
          IF LV_FACTOR = GC_X.  "SY-SUBRC = 0.
            LS_ITEM-BATCH = CONV I( <VC2>-LENGTH ).
            CONDENSE LS_ITEM-BATCH NO-GAPS.
          ENDIF.

        WHEN OTHERS.
      ENDCASE.

*>S.26.07.31_3-2) BAP_GOODSMVT_CREATE 실행 전 FACTOR 배치 유형인 경우
*배치 클래스의 속성 정보 특성 업데이트 BAPI 선 수행
      IF PS_LIST-DPCBT = 'A'. "FACTOR BATCH
        CLEAR LV_LENTH.
*3-2-1) FACTOR BATCH 여부 체크 & 조장정보 가져오기.
        READ TABLE PT_VCQTY ASSIGNING <VC>
        WITH KEY PDOC = PS_LIST-EBELN
                       PDOCITEM = PS_LIST-EBELP
                       DPCBT = 'A' BINARY SEARCH.
        IF SY-SUBRC = 0.
          LV_LENTH = CONV I( <VC>-LENGTH ).
          CONDENSE LV_LENTH NO-GAPS.
        ENDIF.
*3-2-2) FACTOR 배치 자재의 CLASS 조회
* CLASS번호
        CLEAR: LV_CLASS.
        CALL FUNCTION 'CLFC_BATCH_ALLOCATION_TO_CLASS'
          EXPORTING
            MATERIAL           = PS_LIST-MATNR "입고자재
            PLANT              = PS_LIST-WERKS "플랜트
            CLASSTYPE          = '023'       "클래스유형(배치)
          IMPORTING
            CLASS              = LV_CLASS
          EXCEPTIONS
            NO_CLASS_FOUND     = 1
            NO_CLASSTYPE_FOUND = 2
            OTHERS             = 3.

        CHECK LV_CLASS IS NOT INITIAL.
*3-2-3)배치 클래스 속성 정보 업데이트  BAPI 수행
        CLEAR LT_ALC_NUM.
        LT_ALC_NUM[] = VALUE #( BASE LT_ALC_NUM
                                              ( CHARACT = 'SAP_MILLCA_LENGTH'
                                                VALUE_FROM = LV_LENTH )
                                              ( CHARACT = 'SAP_MILLCA_LENGTH_SUB'
                                                VALUE_FROM = LV_LENTH ) ).
        CLEAR : LV_OBJKEY, LT_RETURN.
        SELECT SINGLE CUOBJ_BM
             FROM MCH1
           WHERE MATNR = @PS_LIST-MATNR
                AND CHARG = @LS_ITEM-BATCH
           INTO @LV_OBJKEY.

        IF LV_OBJKEY IS NOT INITIAL.
          CALL FUNCTION 'BAPI_OBJCL_CHANGE_KEY'
            EXPORTING
              CLOBJECTKEY         = LV_OBJKEY
              CLASSNUM            = LV_CLASS
            IMPORTING
              CLASSIF_STATUS      = LV_STATUS
            TABLES
              ALLOCVALUESNUM_NEW  = LT_ALC_NUM
              ALLOCVALUESCHAR_NEW = LT_ALLOC
              ALLOCVALUESCURR_NEW = LT_ALC_CURR
              RETURN              = LT_RETURN.
          READ TABLE LT_RETURN TRANSPORTING NO FIELDS WITH KEY TYPE = GC_E.
          IF SY-SUBRC EQ 0.
*      오류
            CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
          ELSE.
*      배치특성 성공
            CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
              EXPORTING
                WAIT = ABAP_TRUE.
          ENDIF.
        ENDIF.
      ENDIF.
*<E.26.07.31_ZGODEV04.

      LS_ITEM-MVT_IND = GC_B.
      LS_ITEM-LINE_ID = LINES( CT_ITEM ) + 1.
      CT_ITEM = VALUE #( BASE CT_ITEM ( LS_ITEM ) ).

      PS_LIST-LINE_ID = LS_ITEM-LINE_ID.

    ENDDO.

    IF PV_VC IS NOT INITIAL.
      "실행 건 계산
      CLEAR LV_CNT_RUN.
      LV_CNT_RUN = LINES( CT_ITEM ) DIV GC_MAX. "495
      IF LINES( CT_ITEM ) MOD GC_MAX NE 0 OR LV_CNT_RUN = 0.
        LV_CNT_RUN += 1.
      ENDIF.

      IF LV_CNT_RUN = 1.
        CLEAR PV_VC. "최대 라인 수 이내인 경우, 기존 바피로직 태우기 위함.
      ENDIF.
    ENDIF.

*    CHECK PS_LIST-PSTYP EQ GC_3. "외주 임가공인 경우
    IF PS_LIST-PSTYP EQ GC_3. "외주 임가공인 경우
*3-2-4-2) COMPONENT 소비량 산출(COMP_QTY)
*: 입고 수량 * 단위당소요량(RESB-BDMNG/EKPO-MENGE)
*COMPONENT 자재 항목 라인별로 BAPI ITEM 라인 추가
      CLEAR :
        LV_ERFMG   ,
        LV_ERFMG_O,
        LS_COMP.

      LS_COMP-PARENT_ID	 = LS_ITEM-LINE_ID.
      LS_COMP-LINE_ID = LS_ITEM-LINE_ID.

      READ TABLE PT_DELCOMP WITH KEY EBELN = PS_LIST-EBELN
                                                        EBELP = PS_LIST-EBELP
                                                        DELNO = PS_LIST-DELNO
                                                        DELITEM = PS_LIST-DELITEM BINARY SEARCH TRANSPORTING NO FIELDS.
      IF SY-SUBRC EQ 0.
        "납품문서 COMPONENT 기준
        LOOP AT PT_DELCOMP ASSIGNING FIELD-SYMBOL(<LS_DELCOMP2>) FROM SY-TABIX.
          IF <LS_DELCOMP2>-EBELN NE PS_LIST-EBELN
            OR <LS_DELCOMP2>-EBELP NE PS_LIST-EBELP
            OR <LS_DELCOMP2>-DELNO NE PS_LIST-DELNO
            OR <LS_DELCOMP2>-DELITEM NE PS_LIST-DELITEM.
            EXIT.
          ENDIF.

          LS_COMP-MATERIAL = <LS_DELCOMP2>-IDNRK.
          LS_COMP-PLANT = <LS_DELCOMP2>-WERKS.
          LS_COMP-STGE_LOC = <LS_DELCOMP2>-LGORT.
          LS_COMP-PO_NUMBER = <LS_DELCOMP2>-EBELN.
          LS_COMP-PO_ITEM = <LS_DELCOMP2>-EBELP.
          LS_COMP-MOVE_TYPE = '543'.
          LS_COMP-BATCH = <LS_DELCOMP2>-CHARG.
          LS_COMP-ENTRY_QNT = <LS_DELCOMP2>-ISSUE_QTY.
          LS_COMP-ENTRY_UOM = <LS_DELCOMP2>-ISSUE_UNIT.
          LS_COMP-MVT_IND = GC_B.

          "라인추가
          IF <LS_DELCOMP2>-XCHPF EQ ABAP_TRUE AND <LS_DELCOMP2>-CHARG EQ SPACE.
*"투입자재가 배치관리 자재이고 (ZGTMM_CV_SC_RESBLIST-XCHPF = 'X')
*PO_COMP-CHARG 값이 공백인 경우
*공급업체 재고 테이블 기준 BATCH 번호 추출 투입 처리(선입 선출 기준)
*TABLE : MSLB
*SELECT 조건 : LBLAB 0 이 아닌 CHARG
*WHERE 조건 :
*MATNR = PO_COMP-MATNR
*WERKS = PO_COMP_WERKS
*LIFNR = EKKO-LIFNR
            LV_ERFMG = LS_COMP-ENTRY_QNT. "대상 출고 수량
            READ TABLE PT_MSLB WITH KEY MATNR = <LS_DELCOMP2>-IDNRK
                                                       WERKS = <LS_DELCOMP2>-WERKS
                                                       LIFNR = <LS_DELCOMP2>-LIFNR BINARY SEARCH TRANSPORTING NO FIELDS.
            IF SY-SUBRC EQ 0.
              LOOP AT PT_MSLB ASSIGNING <LS_MSLB> FROM SY-TABIX.
                IF <LS_MSLB>-MATNR NE <LS_DELCOMP2>-IDNRK
                  OR <LS_MSLB>-WERKS NE <LS_DELCOMP2>-WERKS
                  OR <LS_MSLB>-LIFNR NE <LS_DELCOMP2>-LIFNR.
                  EXIT.
                ENDIF.

                CHECK <LS_MSLB>-LBLAB GE 0. "재고수량이 0보다 큰 경우만 진행

                "적용 수량 빼기
                LV_ERFMG_O = LV_ERFMG.
                LV_ERFMG -= <LS_MSLB>-LBLAB.

                LS_COMP-BATCH = <LS_MSLB>-CHARG.

                IF LV_ERFMG LT 0.
                  "적용한 수량이 대상 출고수량 보다 큰 경우
                  IF <LS_MSLB>-XPCBT EQ ABAP_TRUE AND <LS_MSLB>-XPRGI EQ SPACE.
*"BATCH 별 투입 시 지정된 BATCH가 단일 배치단위이면 (MCH1-XPCBT='X')
*BATCH 가용재고전량투입 처리"
*& 부분수량 GI 허용이 SPACE 인 경우
                    LS_COMP-ENTRY_QNT = <LS_MSLB>-LBLAB.
                  ELSE.
                    "단일 배치단위가 아니면 잔량적용
                    LS_COMP-ENTRY_QNT = LV_ERFMG_O.
                  ENDIF.
                ELSE.
                  LS_COMP-ENTRY_QNT = <LS_MSLB>-LBLAB.
                ENDIF.

                "재고수량에서 적용수량 빼기
                <LS_MSLB>-LBLAB -=  LS_COMP-ENTRY_QNT.

                LS_COMP-LINE_ID += 1.
                CT_ITEM = VALUE #( BASE CT_ITEM ( LS_COMP ) ). "라인추가
                PS_LIST-LINE_ID = LS_COMP-LINE_ID.

                "적용 수량이 대상 출고수량을 초과한 경우 종료
                IF LV_ERFMG LE 0.
                  EXIT.
                ENDIF.

              ENDLOOP.
            ELSE.
              LS_COMP-LINE_ID += 1.
              CT_ITEM = VALUE #( BASE CT_ITEM ( LS_COMP ) ).
              PS_LIST-LINE_ID = LS_COMP-LINE_ID.
            ENDIF.
          ELSE.
            LS_COMP-LINE_ID += 1.
            CT_ITEM = VALUE #( BASE CT_ITEM ( LS_COMP ) ).
            PS_LIST-LINE_ID = LS_COMP-LINE_ID.
          ENDIF.
        ENDLOOP.

      ELSE.
        READ TABLE PT_ZGTMMT9450 WITH KEY EBELN = PS_LIST-EBELN
                                                                     EBELP = PS_LIST-EBELP
                                                                     WERKS = PS_LIST-WERKS
                                                              BINARY SEARCH TRANSPORTING NO FIELDS.
        IF SY-SUBRC EQ 0.
*3-2-4-2) 외주임가공 투입정보 관리 이력 테이블 정보 점검(ISSUE_COMP)
*
*TABLE : ZGTMMT9450
*SELECT 조건 : IDNRK,CHARG,EBELN,EBELP,MENGE,MEINS
*WHRE 조건 : IT_TAB-EBELN,IT_TAB-EBELP,LIFNR,WERKS
*조회된  COMPONENT 자재,배치별 BAPI ITEM 라인 추가

          LOOP AT PT_ZGTMMT9450 ASSIGNING FIELD-SYMBOL(<LS_ZGTMMT94502>).

            LS_COMP-MATERIAL = <LS_ZGTMMT94502>-IDNRK.
            LS_COMP-PLANT = PS_LIST-WERKS.
            LS_COMP-PO_NUMBER = <LS_ZGTMMT94502>-EBELN.
            LS_COMP-PO_ITEM = <LS_ZGTMMT94502>-EBELP.
            LS_COMP-MOVE_TYPE = '543'.
            LS_COMP-BATCH = <LS_ZGTMMT94502>-CHARG.
            LS_COMP-ENTRY_UOM = <LS_ZGTMMT94502>-MEINS.
            LS_COMP-MVT_IND = GC_B.

*"1) ISSUE_COMP=CHARGE <> NULL
*  : ISSUE_COMP-MENGE
*2) ISSUE_COMP=CHARGE """" 이면
*  : PO 소요량정보로 입고수량 대비 투입 처리 수량 산출
*  -> 입고 수량 * 단위당소요량(RESB-BDMNG/EKPO-MENGE)"

            IF <LS_ZGTMMT9450>-CHARG IS NOT INITIAL.
              LS_COMP-ENTRY_QNT = <LS_ZGTMMT94502>-MENGE.
            ELSE.
              READ TABLE PT_RESB ASSIGNING <LS_RESB> WITH KEY  EBELN = <LS_ZGTMMT94502>-EBELN
                                                                                                    EBELP = <LS_ZGTMMT94502>-EBELP
                                                                                                    MATNR = <LS_ZGTMMT94502>-IDNRK.
              IF SY-SUBRC EQ 0.
                IF <LS_RESB>-MENGE IS NOT INITIAL.
                  LS_COMP-ENTRY_QNT = PS_LIST-MENGE * ( <LS_RESB>-BDMNG / <LS_RESB>-MENGE ).
                ELSE.
                  LS_COMP-ENTRY_QNT = 0.
                ENDIF.
              ELSE.
                CV_CHECK = GC_E.
                EXIT.
              ENDIF.
            ENDIF.

            LS_COMP-LINE_ID += 1.
            CT_ITEM = VALUE #( BASE CT_ITEM ( LS_COMP ) ).
            PS_LIST-LINE_ID = LS_COMP-LINE_ID.

          ENDLOOP.

        ELSE.
          "PO COMPONENT 기준
          READ TABLE PT_RESB WITH KEY EBELN = PS_LIST-EBELN
                                                            EBELP = PS_LIST-EBELP
                                                            BINARY SEARCH TRANSPORTING NO FIELDS.
          IF SY-SUBRC EQ 0.
            LOOP AT PT_RESB ASSIGNING <LS_RESB> FROM SY-TABIX.
              IF <LS_RESB>-EBELN NE PS_LIST-EBELN
                OR <LS_RESB>-EBELP NE PS_LIST-EBELP.
                EXIT.
              ENDIF.

              LS_COMP-MATERIAL = <LS_RESB>-MATNR.
              LS_COMP-PLANT = <LS_RESB>-WERKS.
              LS_COMP-STGE_LOC = <LS_RESB>-LGORT.
              LS_COMP-PO_NUMBER = <LS_RESB>-EBELN.
              LS_COMP-PO_ITEM = <LS_RESB>-EBELP.
              LS_COMP-MOVE_TYPE = '543'.
              LS_COMP-BATCH = <LS_RESB>-CHARG.
              IF <LS_RESB>-MENGE IS NOT INITIAL.
                LS_COMP-ENTRY_QNT = PS_LIST-MENGE * ( <LS_RESB>-BDMNG / <LS_RESB>-MENGE ).
              ELSE.
                LS_COMP-ENTRY_QNT = 0.
              ENDIF.
              LS_COMP-ENTRY_UOM = <LS_RESB>-MEINS.
              LS_COMP-MVT_IND = GC_B.


              "라인추가
              IF <LS_RESB>-XCHPF EQ ABAP_TRUE AND <LS_RESB>-CHARG EQ SPACE.
*"투입자재가 배치관리 자재이고 (ZGTMM_CV_SC_RESBLIST-XCHPF = 'X')
*PO_COMP-CHARG 값이 공백인 경우
*공급업체 재고 테이블 기준 BATCH 번호 추출 투입 처리(선입 선출 기준)
*TABLE : MSLB
*SELECT 조건 : LBLAB 0 이 아닌 CHARG
*WHERE 조건 :
*MATNR = PO_COMP-MATNR
*WERKS = PO_COMP_WERKS
*LIFNR = EKKO-LIFNR
                LV_ERFMG = LS_COMP-ENTRY_QNT. "대상 출고 수량
                READ TABLE PT_MSLB WITH KEY MATNR = <LS_RESB>-MATNR
                                                           WERKS = <LS_RESB>-WERKS
                                                           LIFNR = <LS_RESB>-LIFNR BINARY SEARCH TRANSPORTING NO FIELDS.
                IF SY-SUBRC EQ 0.
                  LOOP AT PT_MSLB ASSIGNING <LS_MSLB> FROM SY-TABIX.
                    IF <LS_MSLB>-MATNR NE <LS_RESB>-MATNR
                      OR <LS_MSLB>-WERKS NE <LS_RESB>-WERKS
                      OR <LS_MSLB>-LIFNR NE <LS_RESB>-LIFNR.
                      EXIT.
                    ENDIF.

                    CHECK <LS_MSLB>-LBLAB GE 0. "재고수량이 0보다 큰 경우만 진행

                    "적용 수량 빼기
                    LV_ERFMG_O = LV_ERFMG.
                    LV_ERFMG -= <LS_MSLB>-LBLAB.

                    LS_COMP-BATCH = <LS_MSLB>-CHARG.

                    IF LV_ERFMG LT 0.
                      "적용한 수량이 대상 출고수량 보다 큰 경우
                      IF <LS_MSLB>-XPCBT EQ ABAP_TRUE AND <LS_MSLB>-XPRGI EQ SPACE.
*"BATCH 별 투입 시 지정된 BATCH가 단일 배치단위이면 (MCH1-XPCBT='X')
*BATCH 가용재고전량투입 처리"
* & 부분수량 GI 허용이 SPACE 인 경우
                        LS_COMP-ENTRY_QNT = <LS_MSLB>-LBLAB.
                      ELSE.
                        "단일 배치단위가 아니면 잔량적용
                        LS_COMP-ENTRY_QNT = LV_ERFMG_O.
                      ENDIF.
                    ELSE.
                      LS_COMP-ENTRY_QNT = <LS_MSLB>-LBLAB.
                    ENDIF.

                    "재고수량에서 적용수량 빼기
                    <LS_MSLB>-LBLAB -=  LS_COMP-ENTRY_QNT.

                    LS_COMP-LINE_ID += 1.
                    CT_ITEM = VALUE #( BASE CT_ITEM ( LS_COMP ) ). "라인추가
                    PS_LIST-LINE_ID = LS_COMP-LINE_ID.

                    "적용 수량이 대상 출고수량을 초과한 경우 종료
                    IF LV_ERFMG LE 0.
                      EXIT.
                    ENDIF.

                  ENDLOOP.
                ELSE.
                  LS_COMP-LINE_ID += 1.
                  CT_ITEM = VALUE #( BASE CT_ITEM ( LS_COMP ) ).
                  PS_LIST-LINE_ID = LS_COMP-LINE_ID.
                ENDIF.
              ELSE.
                LS_COMP-LINE_ID += 1.
                CT_ITEM = VALUE #( BASE CT_ITEM ( LS_COMP ) ).
                PS_LIST-LINE_ID = LS_COMP-LINE_ID.
              ENDIF.

            ENDLOOP.
          ENDIF.


        ENDIF.
      ENDIF.
    ENDIF.
*    CHECK PV_VC IS NOT INITIAL.
*1.자재유형이 MCHA/MCFE/HAWA & FACTOR BATCH 아닌 자재->조장단위로 수량 분할 입고.
*1-1).라인아이템이 많은 경우, 자재문서 생성이 안되는 에러 있으므로 납품문서 품목별로 분할 생성한다.
*1-2)FI전표는 최대 999라인만 설정가능한데, 조장으로 분할 처리 시, 품목으로 분할해도 초과되는 경우가
*있을 수 있어, 아이템라인 495라인 이상일 경우 분할 생성되게 조정
*2.위 1번 이외는 납품문서 번호 기준으로 선택한 품목 정보 모두 아이템에 묶어 한 개 자재문서로 생성이라
*아래 타지 않고 EXIT. 기존 바피 로직 탄다.
    "실행 건 계산
    CLEAR : LV_CNT_RUN, LV_START_IDX , LV_END_IDX .

    LV_CNT_RUN = LINES( CT_ITEM ) DIV GC_MAX.
    IF LINES( CT_ITEM ) MOD GC_MAX NE 0 OR LV_CNT_RUN = 0.
      LV_CNT_RUN += 1.
    ENDIF.

    PV_VC = COND  #( WHEN  LV_CNT_RUN > 1 THEN GC_X ELSE '' ).
    CHECK PV_VC  IS NOT INITIAL.

*BAPI 실행
    DO LV_CNT_RUN TIMES.
      CLEAR LT_ITEM.

      "시작 TABIX
      LV_START_IDX = SY-INDEX - 1.
      LV_START_IDX *= GC_MAX.
      LV_START_IDX += 1.

      "종료 TABIX
      LV_END_IDX = LV_START_IDX + GC_MAX.

      LOOP AT CT_ITEM ASSIGNING <LS_ITEM>.
        "종료 TAB INDEX 보다 크거나 같으면 종료
        IF SY-TABIX GE LV_END_IDX.
          EXIT.
        ENDIF.
        "라인추가
        LT_ITEM[] = VALUE #( BASE LT_ITEM ( CORRESPONDING #( <LS_ITEM> ) ) ).
      ENDLOOP.

*  "GMCODE
      LV_CODE = '01'. "입고

      IF PS_HEAD IS INITIAL.
        PS_HEAD = VALUE #( PSTNG_DATE  = GV_BUDAT
                                         DOC_DATE     = GV_BUDAT
                                         REF_DOC_NO = COND #( WHEN P_DNO = GC_X
                                                                                THEN PS_LIST-DELNO ELSE '' )
                                         PR_UNAME     = SY-UNAME ).
      ELSE.
        IF PS_HEAD-REF_DOC_NO IS INITIAL.
          PS_HEAD-REF_DOC_NO = PS_LIST-DELNO.
        ENDIF.
      ENDIF.

      CALL FUNCTION 'BAPI_GOODSMVT_CREATE'
        EXPORTING
          GOODSMVT_HEADER  = PS_HEAD
          GOODSMVT_CODE    = LV_CODE
        IMPORTING
          MATERIALDOCUMENT = LV_DOC
        TABLES
          GOODSMVT_ITEM    = LT_ITEM
          RETURN           = GT_RETURN.

      IF LV_DOC IS INITIAL.
        READ TABLE GT_RETURN ASSIGNING FIELD-SYMBOL(<LS_RT>) WITH KEY TYPE = GC_E.
        IF SY-SUBRC EQ 0.
*오류
          CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

          READ TABLE GT_LIST ASSIGNING FIELD-SYMBOL(<MAIN>)
          WITH KEY EBELN = PS_LIST-EBELN
                         EBELP = PS_LIST-EBELP BINARY SEARCH.
          IF SY-SUBRC = 0.
            DATA(LV_TABIXC) = SY-TABIX.
            <MAIN>-STATUS    = ICON_LED_RED.
            <MAIN>-MESSAGE = <LS_RT>-MESSAGE.
            MODIFY GT_LIST FROM <MAIN> INDEX LV_TABIXC.
          ENDIF.
        ENDIF.

      ELSE.
*성공
        CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
          EXPORTING
            WAIT = ABAP_TRUE.

*MAIN ALV UPDATE
        READ TABLE GT_LIST ASSIGNING FIELD-SYMBOL(<ALV>)
        WITH KEY DELNO    = PS_LIST-DELNO
                       DELITEM  = PS_LIST-DELITEM
                       EBELN     = PS_LIST-EBELN
                       EBELP     = PS_LIST-EBELP BINARY SEARCH.
        IF SY-SUBRC = 0.
          DATA(LV_TABIX3) = SY-TABIX.
          <ALV>-STATUS    = ICON_LED_GREEN.
          <ALV>-MBLNR     = LV_DOC .
          <ALV>-GRBUDAT = GV_BUDAT.
          <ALV>-BUDAT     = COND #( WHEN P_LNO = GC_X THEN GV_BUDAT ELSE <ALV>-BUDAT ).
          <ALV>-MESSAGE = '입고 처리 완료'(M14).
          CLEAR <ALV>-EDIT. "수정불가
          MODIFY GT_LIST FROM <ALV> INDEX LV_TABIX3.
        ENDIF.
*배치자재인 경우(MARC-XCHPF=X) 배치마스터 제조일자 업데이트
*->배치마스터 업데이트 성공 시, 자재문서 기준 꼬리표번호 테이블 업데이트(ZPPT0001)
        IF <ALV>-XCHPF = GC_X .
          PERFORM BATCH_CHANGE_NEW TABLES PT_VCQTY USING <ALV> PS_LIST.
        ENDIF.

        IF GT_ZPPT0001[] IS NOT INITIAL.
          MODIFY ZPPT0001 FROM TABLE GT_ZPPT0001.
          COMMIT WORK AND WAIT.
        ENDIF.

        CLEAR : GT_ZPPT0001.
      ENDIF.
    ENDDO.

  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*& FORM SET_GOODSMVT_ITEM_PO
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
*&      --> <LS_LOG_TAB>
*&      <-- LT_ITEM
*&---------------------------------------------------------------------*
FORM SET_GOODSMVT_ITEM_PO  USING
                                                         PT_RESB TYPE TY_T_PO_RESB
                                                         PT_DELCOMP TYPE TY_T_PO_DELCOMP
                                                         PT_MSLB TYPE TY_T_MSLB
                                                         PT_ZGTMMT9450 TYPE TY_T_ZGTMMT9450
                                                         PT_VCQTY TYPE TY_T_VC
                                   CHANGING CT_ITEM TYPE TY_T_BAPI2017_GM_ITEM_CREATE
                                                    CV_CHECK
                                                    PS_LIST TYPE TY_LIST.

  FIELD-SYMBOLS <LS_RESB> TYPE TY_PO_RESB.

  DATA LS_ITEM TYPE BAPI2017_GM_ITEM_CREATE.

  LS_ITEM-MATERIAL = PS_LIST-MATNR.
  LS_ITEM-PLANT = PS_LIST-WERKS.
  LS_ITEM-STGE_LOC = PS_LIST-LGORT.
  LS_ITEM-PO_NUMBER = PS_LIST-EBELN.
  LS_ITEM-PO_ITEM = PS_LIST-EBELP.
  LS_ITEM-MOVE_TYPE = '101'.
  LS_ITEM-STCK_TYPE = PS_LIST-INSMK.
  LS_ITEM-ENTRY_QNT = PS_LIST-ERFMG.
  LS_ITEM-ENTRY_UOM = PS_LIST-MEINS.
  LS_ITEM-VENDRBATCH = PS_LIST-LICHA.
  LS_ITEM-PROD_DATE = PS_LIST-HSDAT.
*ITEM_TEXT
*  LS_ITEM-ITEM_TEXT = COND #(
*  WHEN P_PO = GC_X THEN SPACE
*  THEN PS_LIST-EBELN && '-' && PS_LIST-EBELP
*  WHEN P_LNO = GC_X "OEM 드럼라벨
*  THEN PS_LIST-DR_LABELNO(13) && '-' && PS_LIST-DR_LABELNO+14(4) ).

  CASE PS_LIST-PSTYP.
    WHEN SPACE OR '0'. "일반
*CASE1. 일반 입고 : IT_TAB-PSTYP = "" AND
*"처리 자재의  자재유형이 HAWA 이면 DEFAULT 값 채번
*배치번호 : GO00000001"
      IF PS_LIST-MTART EQ 'HAWA' .  "LV_MTART EQ 'HAWA'.
        LS_ITEM-BATCH = 'GO00000001'.
*CASE2. 일반 입고 : 플랜트&자재그룹(MATKL)이 ZGTPPT1010에 존재하면,
*배치번호 : 자재번호로 설정.
      ELSE.
        IF P_PO = GC_X.
          READ TABLE GT_ZGTPPT1010 TRANSPORTING NO FIELDS
          WITH KEY FLD_01 = PS_LIST-WERKS
                         FLD_02 = PS_LIST-MATKL BINARY SEARCH.
          IF SY-SUBRC = 0.
            SHIFT PS_LIST-MATNR LEFT DELETING LEADING '0'.
            LS_ITEM-BATCH = PS_LIST-MATNR.
          ELSE.
*CASE3. 일반입고 : 배치관리유형 DPCBT = 'A'(FACTOR BATCH)이면,
*배치번호 : 조장정보로 설정.
            READ TABLE PT_VCQTY  ASSIGNING FIELD-SYMBOL(<VC>)
            WITH KEY PDOC = PS_LIST-EBELN
                           PDOCITEM = PS_LIST-EBELP
                           DPCBT = 'A' BINARY SEARCH.
            IF SY-SUBRC = 0.
              LS_ITEM-BATCH = CONV I( <VC>-LENGTH ).
              CONDENSE LS_ITEM-BATCH NO-GAPS.
*             LS_ITEM-BATCH = <VC>-LENGTH.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.

    WHEN '3'.  "외주 임가공_메인품목 자재 배치 설정 조건 체크 추가
*배치관리 유형 FACTOR BATCH이면(DPCBT = 'A') 조장정보로 채번,없으면 자동채번
      READ TABLE PT_VCQTY ASSIGNING FIELD-SYMBOL(<VCL>)
      WITH KEY PDOC = PS_LIST-EBELN
                     PDOCITEM = PS_LIST-EBELP
                     DPCBT = 'A' BINARY SEARCH.
      IF SY-SUBRC = 0.
        LS_ITEM-BATCH = CONV I( <VCL>-LENGTH ).
        CONDENSE LS_ITEM-BATCH NO-GAPS.
*        LS_ITEM-BATCH = <VCL>-LENGTH.
      ENDIF.

    WHEN OTHERS.
  ENDCASE.

  LS_ITEM-MVT_IND = GC_B.
  LS_ITEM-LINE_ID = LINES( CT_ITEM ) + 1.
  CT_ITEM = VALUE #( BASE CT_ITEM ( LS_ITEM ) ).

  PS_LIST-LINE_ID = LS_ITEM-LINE_ID.

  CHECK PS_LIST-PSTYP EQ GC_3. "외주 임가공인 경우

  DATA:
    LV_ERFMG   TYPE MENGV13,
    LV_ERFMG_O TYPE ERFMG.

  FIELD-SYMBOLS <LS_MSLB> TYPE TY_MSLB.

  DATA LS_COMP TYPE BAPI2017_GM_ITEM_CREATE.
  LS_COMP-PARENT_ID	 = LS_ITEM-LINE_ID.
  LS_COMP-LINE_ID       = LS_ITEM-LINE_ID.
  LS_COMP-ITEM_TEXT = COND #( WHEN P_PO = GC_X THEN SPACE
                                                     WHEN P_LNO = GC_X "OEM 드럼라벨
                                                     THEN PS_LIST-DR_LABELNO(13) && '-' && PS_LIST-DR_LABELNO+14(4) ).
*1) 외주임가공 투입정보 관리 이력 테이블 정보 점검(ISSUE_COMP)
*TABLE : ZGTMMT9450
*SELECT 조건 : IDNRK,CHARG,EBELN,EBELP,MENGE,MEINS
*WHRE 조건 : MAIN-EBELN,MAIN-EBELP,LIFNR,WERKS

  READ TABLE PT_ZGTMMT9450 WITH KEY EBELN = PS_LIST-EBELN
                                                               EBELP = PS_LIST-EBELP
                                                               WERKS = PS_LIST-WERKS
                                                BINARY SEARCH TRANSPORTING NO FIELDS.
  IF SY-SUBRC EQ 0.
*조회된  COMPONENT 자재,배치별 BAPI ITEM 라인 추가
    LOOP AT PT_ZGTMMT9450 ASSIGNING FIELD-SYMBOL(<LS_ZGTMMT9450>).

      LS_COMP-MATERIAL = <LS_ZGTMMT9450>-IDNRK.
      LS_COMP-PLANT = PS_LIST-WERKS.
      LS_COMP-PO_NUMBER = <LS_ZGTMMT9450>-EBELN.
      LS_COMP-PO_ITEM = <LS_ZGTMMT9450>-EBELP.
      LS_COMP-MOVE_TYPE = '543'.
      LS_COMP-BATCH = <LS_ZGTMMT9450>-CHARG.
      LS_COMP-ENTRY_UOM = <LS_ZGTMMT9450>-MEINS.
      LS_COMP-MVT_IND = GC_B.

*ENTRY_QNT(입고수량) 조건 별 설정
*1-1) ISSUE_COMP=CHARGE <> NULL -> ISSUE_COMP-MENGE
*1-2) ISSUE_COMP=CHARGE """" 이면
*  : PO 소요량정보로 입고수량 대비 투입 처리 수량 산출
*  ->COMPONENT 소비량 = 입고 수량 * 단위당소요량(RESB-BDMNG/EKPO-MENGE)"

      IF <LS_ZGTMMT9450>-CHARG IS NOT INITIAL.
        LS_COMP-ENTRY_QNT = <LS_ZGTMMT9450>-MENGE.

      ELSE.
        READ TABLE PT_RESB ASSIGNING <LS_RESB> WITH KEY  EBELN = <LS_ZGTMMT9450>-EBELN
                                                                                              EBELP = <LS_ZGTMMT9450>-EBELP
                                                                                              MATNR = <LS_ZGTMMT9450>-IDNRK.
        IF SY-SUBRC EQ 0.
          IF <LS_RESB>-MENGE IS NOT INITIAL.
            LS_COMP-ENTRY_QNT = PS_LIST-MENGE * ( <LS_RESB>-BDMNG / <LS_RESB>-MENGE ).
          ELSE.
            LS_COMP-ENTRY_QNT = 0.
          ENDIF.
        ELSE.
          CV_CHECK = GC_E.
          EXIT.
        ENDIF.
      ENDIF.

      LS_COMP-LINE_ID += 1.
      CT_ITEM = VALUE #( BASE CT_ITEM ( LS_COMP ) ).
      PS_LIST-LINE_ID = LS_COMP-LINE_ID.

    ENDLOOP.

*2) 임가공 투입정보 테이블 정보가 존재하지 않는 경우,
*구매오더의 COMPONENT 자재 정보 점검(PO_COMP)
*TABLE : RESB
*SELECT조건 : RSPOS,MATNR,BDMNG,MEINS,WERKS,LGORT,CHARG
*WHRE 조건 : ALV-EBELN, ALV-EBELP
  ELSE.
    "PO COMPONENT 기준
    READ TABLE PT_RESB WITH KEY EBELN = PS_LIST-EBELN
                                                     EBELP = PS_LIST-EBELP
                                                     BINARY SEARCH TRANSPORTING NO FIELDS.
    IF SY-SUBRC EQ 0.
      LOOP AT PT_RESB ASSIGNING <LS_RESB> FROM SY-TABIX.
        IF <LS_RESB>-EBELN NE PS_LIST-EBELN
          OR <LS_RESB>-EBELP NE PS_LIST-EBELP.
          EXIT.
        ENDIF.

        LS_COMP-MATERIAL = <LS_RESB>-MATNR.
        LS_COMP-PLANT = <LS_RESB>-WERKS.
        LS_COMP-STGE_LOC = <LS_RESB>-LGORT.
        LS_COMP-PO_NUMBER = <LS_RESB>-EBELN.
        LS_COMP-PO_ITEM = <LS_RESB>-EBELP.
        LS_COMP-MOVE_TYPE = '543'.
        LS_COMP-BATCH = <LS_RESB>-CHARG.
*ENTRY_QNT(입고수량) 조건 별 설정
*2-1) ISSUE_COMP=CHARGE <> NULL -> ISSUE_COMP-MENGE
*2-2) ISSUE_COMP=CHARGE """" 이면
*  : PO 소요량정보로 입고수량 대비 투입 처리 수량 산출
*  ->COMPONENT 소비량 = 입고 수량 * 단위당소요량(RESB-BDMNG/EKPO-MENGE)"
        IF <LS_RESB>-MENGE IS NOT INITIAL.
          LS_COMP-ENTRY_QNT = PS_LIST-MENGE * ( <LS_RESB>-BDMNG / <LS_RESB>-MENGE ).
        ELSE.
          LS_COMP-ENTRY_QNT = 0.
        ENDIF.

        LS_COMP-ENTRY_UOM = <LS_RESB>-MEINS.
        LS_COMP-MVT_IND = GC_B.

        "라인추가
        IF <LS_RESB>-XCHPF EQ ABAP_TRUE AND <LS_RESB>-CHARG EQ SPACE.
*"투입자재가 배치관리 자재이고 (ZGTMM_CV_SC_RESBLIST-XCHPF = 'X')
*PO_COMP-CHARG 값이 공백인 경우
*공급업체 재고 테이블 기준 BATCH 번호 추출 투입 처리(선입 선출 기준)
*TABLE : MSLB
*SELECT 조건 : LBLAB 0 이 아닌 CHARG
*WHERE 조건 :
*MATNR = PO_COMP-MATNR
*WERKS = PO_COMP_WERKS
*LIFNR = EKKO-LIFNR
          LV_ERFMG = LS_COMP-ENTRY_QNT. "대상 출고 수량
          READ TABLE PT_MSLB WITH KEY MATNR = <LS_RESB>-MATNR
                                                            WERKS = <LS_RESB>-WERKS
                                                            LIFNR = <LS_RESB>-LIFNR
                                                            BINARY SEARCH TRANSPORTING NO FIELDS.
          IF SY-SUBRC EQ 0.
            LOOP AT PT_MSLB ASSIGNING <LS_MSLB> FROM SY-TABIX.
              IF <LS_MSLB>-MATNR NE <LS_RESB>-MATNR
                OR <LS_MSLB>-WERKS NE <LS_RESB>-WERKS
                OR <LS_MSLB>-LIFNR NE <LS_RESB>-LIFNR.
                EXIT.
              ENDIF.

              CHECK <LS_MSLB>-LBLAB GE 0. "재고수량이 0보다 큰 경우만 진행

              "적용 수량 빼기
              LV_ERFMG_O = LV_ERFMG.
              LV_ERFMG -= <LS_MSLB>-LBLAB.

              LS_COMP-BATCH = <LS_MSLB>-CHARG.

              IF LV_ERFMG LT 0.
                "적용한 수량이 대상 출고수량 보다 큰 경우
                IF <LS_MSLB>-XPCBT EQ ABAP_TRUE AND <LS_MSLB>-XPRGI EQ SPACE.
*"BATCH 별 투입 시 지정된 BATCH가 단일 배치단위이면 (MCH1-XPCBT='X')
*BATCH 가용재고전량투입 처리"
* & 부분수량 GI 허용이 SPACE 인 경우
                  LS_COMP-ENTRY_QNT = <LS_MSLB>-LBLAB.
                ELSE.
                  "단일 배치단위가 아니면 잔량적용
                  LS_COMP-ENTRY_QNT = LV_ERFMG_O.
                ENDIF.
              ELSE.
                LS_COMP-ENTRY_QNT = <LS_MSLB>-LBLAB.
              ENDIF.

              "재고수량에서 적용수량 빼기
              <LS_MSLB>-LBLAB -=  LS_COMP-ENTRY_QNT.

              LS_COMP-LINE_ID += 1.
              CT_ITEM = VALUE #( BASE CT_ITEM ( LS_COMP ) ). "라인추가
              PS_LIST-LINE_ID = LS_COMP-LINE_ID.

              "적용 수량이 대상 출고수량을 초과한 경우 종료
              IF LV_ERFMG LE 0.
                EXIT.
              ENDIF.

            ENDLOOP.
          ELSE.
            LS_COMP-LINE_ID += 1.
            CT_ITEM = VALUE #( BASE CT_ITEM ( LS_COMP ) ).
            PS_LIST-LINE_ID = LS_COMP-LINE_ID.
          ENDIF.

        ELSE.
          LS_COMP-LINE_ID += 1.
          CT_ITEM = VALUE #( BASE CT_ITEM ( LS_COMP ) ).
          PS_LIST-LINE_ID = LS_COMP-LINE_ID.
        ENDIF.

      ENDLOOP.
    ENDIF.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& FORM SET_GOODSMVT_ITEM_PO_NEW
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
*&      --> <LS_LOG_TAB>
*&      <-- LT_ITEM
*&---------------------------------------------------------------------*
FORM SET_GOODSMVT_ITEM_PO_NEW  USING
                                                         PT_RESB TYPE TY_T_PO_RESB
                                                         PT_DELCOMP TYPE TY_T_PO_DELCOMP
                                                         PT_MSLB TYPE TY_T_MSLB
                                                         PT_ZGTMMT9450 TYPE TY_T_ZGTMMT9450
                                                         PT_VCQTY TYPE TY_T_VC
                                   CHANGING CT_ITEM TYPE TY_T_BAPI2017_GM_ITEM_CREATE
                                                    CV_CHECK
                                                    PS_LIST TYPE TY_LIST.

  DATA:
    LT_RETURN   TYPE STANDARD TABLE OF BAPIRET2,
    LT_ALLOC    TYPE TABLE OF BAPI1003_ALLOC_VALUES_CHAR,
    LT_ALC_NUM  TYPE TABLE OF BAPI1003_ALLOC_VALUES_NUM,
    LT_ALC_CURR TYPE TABLE OF BAPI1003_ALLOC_VALUES_CURR,
    LV_CLASS    TYPE BAPI1003_KEY-CLASSNUM, "KLAH-CLASS,
    LV_STATUS   TYPE BAPI1003_KEY-STATUS,
    LV_KEY      TYPE BAPI1003_KEY-OBJECT,
    LV_MAT18    TYPE MATNR18,
    LV_LENTH    TYPE ATWRT30.

  FIELD-SYMBOLS <LS_RESB> TYPE TY_PO_RESB.

  DATA :
    LS_ITEM TYPE BAPI2017_GM_ITEM_CREATE,
    LV_VCQ  TYPE ERFMG,
    LV_TIME TYPE I,
    LV_VC.

  CLEAR : LV_TIME, LV_VCQ.
*1.입고 처리 자재가 배치 자채이고
  IF PS_LIST-XCHPF = 'X'.
*배치유형 체크..
    READ TABLE PT_VCQTY ASSIGNING FIELD-SYMBOL(<VC2>)
    WITH KEY PDOC = PS_LIST-EBELN
                   PDOCITEM = PS_LIST-EBELP BINARY SEARCH.
    IF SY-SUBRC = 0.
*1-1)배치유형이 A 이고
      CASE <VC2>-DPCBT.
        WHEN 'A'.
*1-2)자재유형이(MARA-MATRT)가 MCFE or MCHA or HAWA 이면 ALV-ERFMG 총 수량으로 입고 처리
          IF PS_LIST-MTART = 'MCHA' OR PS_LIST-MTART = 'MCFE' OR PS_LIST-MTART = 'HAWA'.
            CLEAR LV_VCQ.
            LV_TIME = 1.
          ENDIF.
*1-3)조장정보로 배치 참조채번
          LS_ITEM-BATCH = CONV I( <VC2>-LENGTH ).
          CONDENSE LS_ITEM-BATCH NO-GAPS.

        WHEN OTHERS.
*2)배치유형이 A 가 아닐때,
*2-1)조장 길이가 존재하면 ALV-ERFMG 값을 조장 정보로 수량을 분할하여 입고 처리
          IF <VC2>-LENGTH IS NOT INITIAL.
            LV_TIME = PS_LIST-MENGE / <VC2>-LENGTH. "분할수 = 입고수량/조장단위
            LV_VCQ = PS_LIST-MENGE / LV_TIME. "분할입고수량 = 입고수량/분할 수
          ELSE.
            CLEAR LV_VCQ.
            LV_TIME = 1.
          ENDIF.
*2-2)MARC-DPCBT = C or 공백 이면 자동 채번
          IF <VC2>-DPCBT = 'C' OR <VC2>-DPCBT = '' .
            LS_ITEM-BATCH = ''.
          ENDIF.
*2-3)자재유형 HAWA일 때, 배치유형 A OR C가 아닐 때만, 배치번호 고정 채번
          IF PS_LIST-MTART = 'HAWA' .
            LS_ITEM-BATCH = COND #( WHEN <VC2>-DPCBT NE 'C' THEN 'GO00000001'
                                                      ELSE LS_ITEM-BATCH ).
*2-4)자재유형 HAWA아니고, 입고처리플랜트와 입고자재 자재그룹이 공통마스터 정보에 존재하면,
*배치번호 : 자재번호로 설정
          ELSE.
            READ TABLE GT_ZGTPPT1010 TRANSPORTING NO FIELDS
            WITH KEY FLD_01 = PS_LIST-WERKS
                           FLD_02 = PS_LIST-MATKL BINARY SEARCH.
            IF SY-SUBRC = 0.
              SHIFT PS_LIST-MATNR LEFT DELETING LEADING '0'.
              LS_ITEM-BATCH = PS_LIST-MATNR.
            ENDIF.
          ENDIF.

*--------------------------------------------------------------------*
**-- 26.09 hawa 분기 추가 / DPCBT = 0 이고 LENGTH 가 1 인 것
*--------------------------------------------------------------------*
          IF PS_LIST-MTART = 'HAWA' AND <VC2>-DPCBT = '' AND <VC2>-LENGTH = 1.
            LV_TIME = 1.
            CLEAR LV_VCQ .
          ENDIF.
*--------------------------------------------------------------------*

      ENDCASE.
    ENDIF.

  ELSE.
*배치자재 아니면, 전체수량으로 처리
    CLEAR LV_VCQ.
    LV_TIME = 1.
  ENDIF.

  DO LV_TIME TIMES.

    LS_ITEM-MATERIAL = PS_LIST-MATNR.
    LS_ITEM-PLANT = PS_LIST-WERKS.
    LS_ITEM-STGE_LOC = PS_LIST-LGORT.
    LS_ITEM-PO_NUMBER = PS_LIST-EBELN.
    LS_ITEM-PO_ITEM = PS_LIST-EBELP.
    LS_ITEM-MOVE_TYPE = '101'.
    LS_ITEM-STCK_TYPE = PS_LIST-INSMK.
    LS_ITEM-ENTRY_QNT = COND #( WHEN LV_VCQ IS INITIAL THEN PS_LIST-ERFMG
                                                       ELSE LV_VCQ ).
    LS_ITEM-ENTRY_UOM = PS_LIST-MEINS.
    LS_ITEM-VENDRBATCH = PS_LIST-LICHA.
    LS_ITEM-PROD_DATE = PS_LIST-HSDAT.
*ITEM_TEXT                    DELNO&-&DELITEM GO2026020001-10
    LS_ITEM-ITEM_TEXT = PS_LIST-DELNO && '-' && PS_LIST-DELITEM.

*      CASE PS_LIST-PSTYP.
*        WHEN SPACE OR '0'. "일반
*          "위에 배치유형/자재유형으로 따로 설정..
*        WHEN '3'.  "외주 임가공_메인품목 자재 배치 설정 조건 체크 추가
**배치관리 유형 FACTOR BATCH이면(DPCBT = 'A') 조장정보로 채번,없으면 자동채번
*          READ TABLE PT_VCQTY ASSIGNING FIELD-SYMBOL(<VCL4>)
*          WITH KEY PDOC = PS_LIST-EBELN
*                         PDOCITEM = PS_LIST-EBELP
*                         DPCBT = 'A' BINARY SEARCH.
*          IF SY-SUBRC = 0.
*            LS_ITEM-BATCH = CONV I( <VCL4>-LENGTH ).
*            CONDENSE LS_ITEM-BATCH NO-GAPS.
*          ENDIF.
*        WHEN OTHERS.
*      ENDCASE.

*>S.26.07.31_3-2) BAP_GOODSMVT_CREATE 실행 전 FACTOR 배치 유형인 경우
*배치 클래스의 속성 정보 특성 업데이트 BAPI 선 수행
    IF PS_LIST-DPCBT = 'A'. "FACTOR BATCH
      CLEAR LV_LENTH.
*3-2-1) FACTOR BATCH 여부 체크 & 조장정보 가져오기.
      READ TABLE PT_VCQTY ASSIGNING FIELD-SYMBOL(<VC3>)
      WITH KEY PDOC = PS_LIST-EBELN
                     PDOCITEM = PS_LIST-EBELP
                     DPCBT = 'A' BINARY SEARCH.
      IF SY-SUBRC = 0.
        LV_LENTH = CONV I( <VC3>-LENGTH ).
        CONDENSE LV_LENTH NO-GAPS.
      ENDIF.
*3-2-2) FACTOR 배치 자재의 CLASS 조회
* CLASS번호
      CLEAR: LV_CLASS.
      CALL FUNCTION 'CLFC_BATCH_ALLOCATION_TO_CLASS'
        EXPORTING
          MATERIAL           = PS_LIST-MATNR "입고자재
          PLANT              = PS_LIST-WERKS "플랜트
          CLASSTYPE          = '023'       "클래스유형(배치)
        IMPORTING
          CLASS              = LV_CLASS
        EXCEPTIONS
          NO_CLASS_FOUND     = 1
          NO_CLASSTYPE_FOUND = 2
          OTHERS             = 3.

      CHECK LV_CLASS IS NOT INITIAL.
*3-2-3)배치 클래스 속성 정보 업데이트  BAPI 수행
      CLEAR LT_ALC_NUM.
      LT_ALC_NUM[] = VALUE #( BASE LT_ALC_NUM
                                                  ( CHARACT = 'SAP_MILLCA_LENGTH'
                                                    VALUE_FROM = LV_LENTH )
                                                  ( CHARACT = 'SAP_MILLCA_LENGTH_SUB'
                                                    VALUE_FROM = LV_LENTH ) ).
      CLEAR : LT_RETURN. "LV_MAT18, LV_KEY,
      SELECT SINGLE CUOBJ_BM
         FROM MCH1
         WHERE MATNR = @PS_LIST-MATNR
             AND CHARG = @LS_ITEM-BATCH
            INTO @DATA(LV_OBJKEY).

      IF LV_OBJKEY IS NOT INITIAL.
        CALL FUNCTION 'BAPI_OBJCL_CHANGE_KEY'
          EXPORTING
            CLOBJECTKEY         = LV_OBJKEY
            CLASSNUM            = LV_CLASS
          IMPORTING
            CLASSIF_STATUS      = LV_STATUS
          TABLES
            ALLOCVALUESNUM_NEW  = LT_ALC_NUM
            ALLOCVALUESCHAR_NEW = LT_ALLOC
            ALLOCVALUESCURR_NEW = LT_ALC_CURR
            RETURN              = LT_RETURN.
        CLEAR : LT_RETURN. "LV_MAT18, LV_KEY,
*            LV_MAT18 = |{ PS_LIST-MATNR ALPHA = IN }|.
*            LV_KEY(18) = LV_MAT18.
*            LV_KEY+18(10) = LV_LENTH. "선수행시에는 배치번호 없음->조장=배치번호
*
*            CALL FUNCTION 'BAPI_OBJCL_CHANGE'
*              EXPORTING
*                OBJECTKEY          = LV_KEY
*                OBJECTTABLE        = 'MCH1'
*                CLASSNUM           = LV_CLASS
*                CLASSTYPE          = '023'
*              TABLES
*                ALLOCVALUESNUMNEW  = LT_ALC_NUM
*                ALLOCVALUESCHARNEW = LT_ALLOC
*                ALLOCVALUESCURRNEW = LT_ALC_CURR
*                RETURN             = LT_RETURN.
        READ TABLE LT_RETURN ASSIGNING FIELD-SYMBOL(<LS_R2TURN>) WITH KEY TYPE = GC_E.
        IF SY-SUBRC EQ 0.
*      오류
          CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
        ELSE.
*      배치특성 성공
          CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
            EXPORTING
              WAIT = ABAP_TRUE.
        ENDIF.
      ENDIF.
    ENDIF.
*<E.26.07.31_ZGODEV04.

    LS_ITEM-MVT_IND = GC_B.
    LS_ITEM-LINE_ID = LINES( CT_ITEM ) + 1.
    CT_ITEM = VALUE #( BASE CT_ITEM ( LS_ITEM ) ).

    PS_LIST-LINE_ID = LS_ITEM-LINE_ID.

  ENDDO.

  CHECK PS_LIST-PSTYP EQ GC_3. "외주 임가공인 경우

  DATA:
    LV_ERFMG   TYPE MENGV13,
    LV_ERFMG_O TYPE ERFMG.

  FIELD-SYMBOLS <LS_MSLB> TYPE TY_MSLB.

  DATA LS_COMP TYPE BAPI2017_GM_ITEM_CREATE.
  LS_COMP-PARENT_ID	 = LS_ITEM-LINE_ID.
  LS_COMP-LINE_ID       = LS_ITEM-LINE_ID.
  LS_COMP-ITEM_TEXT = COND #( WHEN P_PO = GC_X THEN SPACE
                                                     WHEN P_LNO = GC_X "OEM 드럼라벨
                                                     THEN PS_LIST-DR_LABELNO(13) && '-' && PS_LIST-DR_LABELNO+14(4) ).
*1) 외주임가공 투입정보 관리 이력 테이블 정보 점검(ISSUE_COMP)
*TABLE : ZGTMMT9450
*SELECT 조건 : IDNRK,CHARG,EBELN,EBELP,MENGE,MEINS
*WHRE 조건 : MAIN-EBELN,MAIN-EBELP,LIFNR,WERKS

  READ TABLE PT_ZGTMMT9450 WITH KEY EBELN = PS_LIST-EBELN
                                                               EBELP = PS_LIST-EBELP
                                                               WERKS = PS_LIST-WERKS
                                                BINARY SEARCH TRANSPORTING NO FIELDS.
  IF SY-SUBRC EQ 0.
*조회된  COMPONENT 자재,배치별 BAPI ITEM 라인 추가
    LOOP AT PT_ZGTMMT9450 ASSIGNING FIELD-SYMBOL(<LS_ZGTMMT9450>).

      LS_COMP-MATERIAL = <LS_ZGTMMT9450>-IDNRK.
      LS_COMP-PLANT = PS_LIST-WERKS.
      LS_COMP-PO_NUMBER = <LS_ZGTMMT9450>-EBELN.
      LS_COMP-PO_ITEM = <LS_ZGTMMT9450>-EBELP.
      LS_COMP-MOVE_TYPE = '543'.
      LS_COMP-BATCH = <LS_ZGTMMT9450>-CHARG.
      LS_COMP-ENTRY_UOM = <LS_ZGTMMT9450>-MEINS.
      LS_COMP-MVT_IND = GC_B.

*ENTRY_QNT(입고수량) 조건 별 설정
*1-1) ISSUE_COMP=CHARGE <> NULL -> ISSUE_COMP-MENGE
*1-2) ISSUE_COMP=CHARGE """" 이면
*  : PO 소요량정보로 입고수량 대비 투입 처리 수량 산출
*  ->COMPONENT 소비량 = 입고 수량 * 단위당소요량(RESB-BDMNG/EKPO-MENGE)"

      IF <LS_ZGTMMT9450>-CHARG IS NOT INITIAL.
        LS_COMP-ENTRY_QNT = <LS_ZGTMMT9450>-MENGE.

      ELSE.
        READ TABLE PT_RESB ASSIGNING <LS_RESB> WITH KEY  EBELN = <LS_ZGTMMT9450>-EBELN
                                                                                              EBELP = <LS_ZGTMMT9450>-EBELP
                                                                                              MATNR = <LS_ZGTMMT9450>-IDNRK.
        IF SY-SUBRC EQ 0.
          IF <LS_RESB>-MENGE IS NOT INITIAL.
            LS_COMP-ENTRY_QNT = PS_LIST-MENGE * ( <LS_RESB>-BDMNG / <LS_RESB>-MENGE ).
          ELSE.
            LS_COMP-ENTRY_QNT = 0.
          ENDIF.
        ELSE.
          CV_CHECK = GC_E.
          EXIT.
        ENDIF.
      ENDIF.

      LS_COMP-LINE_ID += 1.
      CT_ITEM = VALUE #( BASE CT_ITEM ( LS_COMP ) ).
      PS_LIST-LINE_ID = LS_COMP-LINE_ID.

    ENDLOOP.

*2) 임가공 투입정보 테이블 정보가 존재하지 않는 경우,
*구매오더의 COMPONENT 자재 정보 점검(PO_COMP)
*TABLE : RESB
*SELECT조건 : RSPOS,MATNR,BDMNG,MEINS,WERKS,LGORT,CHARG
*WHRE 조건 : ALV-EBELN, ALV-EBELP
  ELSE.
    "PO COMPONENT 기준
    READ TABLE PT_RESB WITH KEY EBELN = PS_LIST-EBELN
                                                     EBELP = PS_LIST-EBELP
                                                     BINARY SEARCH TRANSPORTING NO FIELDS.
    IF SY-SUBRC EQ 0.
      LOOP AT PT_RESB ASSIGNING <LS_RESB> FROM SY-TABIX.
        IF <LS_RESB>-EBELN NE PS_LIST-EBELN
          OR <LS_RESB>-EBELP NE PS_LIST-EBELP.
          EXIT.
        ENDIF.

        LS_COMP-MATERIAL = <LS_RESB>-MATNR.
        LS_COMP-PLANT = <LS_RESB>-WERKS.
        LS_COMP-STGE_LOC = <LS_RESB>-LGORT.
        LS_COMP-PO_NUMBER = <LS_RESB>-EBELN.
        LS_COMP-PO_ITEM = <LS_RESB>-EBELP.
        LS_COMP-MOVE_TYPE = '543'.
        LS_COMP-BATCH = <LS_RESB>-CHARG.
*ENTRY_QNT(입고수량) 조건 별 설정
*2-1) ISSUE_COMP=CHARGE <> NULL -> ISSUE_COMP-MENGE
*2-2) ISSUE_COMP=CHARGE """" 이면
*  : PO 소요량정보로 입고수량 대비 투입 처리 수량 산출
*  ->COMPONENT 소비량 = 입고 수량 * 단위당소요량(RESB-BDMNG/EKPO-MENGE)"
        IF <LS_RESB>-MENGE IS NOT INITIAL.
          LS_COMP-ENTRY_QNT = PS_LIST-MENGE * ( <LS_RESB>-BDMNG / <LS_RESB>-MENGE ).
        ELSE.
          LS_COMP-ENTRY_QNT = 0.
        ENDIF.

        LS_COMP-ENTRY_UOM = <LS_RESB>-MEINS.
        LS_COMP-MVT_IND = GC_B.

        "라인추가
        IF <LS_RESB>-XCHPF EQ ABAP_TRUE AND <LS_RESB>-CHARG EQ SPACE.
*"투입자재가 배치관리 자재이고 (ZGTMM_CV_SC_RESBLIST-XCHPF = 'X')
*PO_COMP-CHARG 값이 공백인 경우
*공급업체 재고 테이블 기준 BATCH 번호 추출 투입 처리(선입 선출 기준)
*TABLE : MSLB
*SELECT 조건 : LBLAB 0 이 아닌 CHARG
*WHERE 조건 :
*MATNR = PO_COMP-MATNR
*WERKS = PO_COMP_WERKS
*LIFNR = EKKO-LIFNR
          LV_ERFMG = LS_COMP-ENTRY_QNT. "대상 출고 수량
          READ TABLE PT_MSLB WITH KEY MATNR = <LS_RESB>-MATNR
                                                            WERKS = <LS_RESB>-WERKS
                                                            LIFNR = <LS_RESB>-LIFNR
                                                            BINARY SEARCH TRANSPORTING NO FIELDS.
          IF SY-SUBRC EQ 0.
            LOOP AT PT_MSLB ASSIGNING <LS_MSLB> FROM SY-TABIX.
              IF <LS_MSLB>-MATNR NE <LS_RESB>-MATNR
                OR <LS_MSLB>-WERKS NE <LS_RESB>-WERKS
                OR <LS_MSLB>-LIFNR NE <LS_RESB>-LIFNR.
                EXIT.
              ENDIF.

              CHECK <LS_MSLB>-LBLAB GE 0. "재고수량이 0보다 큰 경우만 진행

              "적용 수량 빼기
              LV_ERFMG_O = LV_ERFMG.
              LV_ERFMG -= <LS_MSLB>-LBLAB.

              LS_COMP-BATCH = <LS_MSLB>-CHARG.

              IF LV_ERFMG LT 0.
                "적용한 수량이 대상 출고수량 보다 큰 경우
                IF <LS_MSLB>-XPCBT EQ ABAP_TRUE AND <LS_MSLB>-XPRGI EQ SPACE.
*"BATCH 별 투입 시 지정된 BATCH가 단일 배치단위이면 (MCH1-XPCBT='X')
*BATCH 가용재고전량투입 처리"
* & 부분수량 GI 허용이 SPACE 인 경우
                  LS_COMP-ENTRY_QNT = <LS_MSLB>-LBLAB.
                ELSE.
                  "단일 배치단위가 아니면 잔량적용
                  LS_COMP-ENTRY_QNT = LV_ERFMG_O.
                ENDIF.
              ELSE.
                LS_COMP-ENTRY_QNT = <LS_MSLB>-LBLAB.
              ENDIF.

              "재고수량에서 적용수량 빼기
              <LS_MSLB>-LBLAB -=  LS_COMP-ENTRY_QNT.

              LS_COMP-LINE_ID += 1.
              CT_ITEM = VALUE #( BASE CT_ITEM ( LS_COMP ) ). "라인추가
              PS_LIST-LINE_ID = LS_COMP-LINE_ID.

              "적용 수량이 대상 출고수량을 초과한 경우 종료
              IF LV_ERFMG LE 0.
                EXIT.
              ENDIF.

            ENDLOOP.
          ELSE.
            LS_COMP-LINE_ID += 1.
            CT_ITEM = VALUE #( BASE CT_ITEM ( LS_COMP ) ).
            PS_LIST-LINE_ID = LS_COMP-LINE_ID.
          ENDIF.

        ELSE.
          LS_COMP-LINE_ID += 1.
          CT_ITEM = VALUE #( BASE CT_ITEM ( LS_COMP ) ).
          PS_LIST-LINE_ID = LS_COMP-LINE_ID.
        ENDIF.

      ENDLOOP.
    ENDIF.

  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*& FORM SET_GOODSMVT_ITEM_OEMDRLB
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
*&      --> <LS_LOG_TAB>
*&      <-- LT_ITEM
*&---------------------------------------------------------------------*
FORM SET_GOODSMVT_ITEM_OEMDRLB  USING
                                                         PT_RESB TYPE TY_T_PO_RESB
                                                         PT_DELCOMP TYPE TY_T_PO_DELCOMP
                                                         PT_MSLB TYPE TY_T_MSLB
                                                         PT_ZGTMMT9450 TYPE TY_T_ZGTMMT9450
                                                         PT_VC TYPE  TY_T_VC
                                   CHANGING CT_ITEM TYPE TY_T_BAPI2017_GM_ITEM_CREATE
                                                    CV_CHECK
                                                    PS_LIST TYPE TY_LIST.

  FIELD-SYMBOLS <LS_RESB> TYPE TY_PO_RESB.

  DATA LS_ITEM TYPE BAPI2017_GM_ITEM_CREATE.

  LS_ITEM-MATERIAL = PS_LIST-MATNR.
  LS_ITEM-PLANT = PS_LIST-WERKS.
  LS_ITEM-STGE_LOC = PS_LIST-LGORT.
  LS_ITEM-PO_NUMBER = PS_LIST-EBELN.
  LS_ITEM-PO_ITEM = PS_LIST-EBELP.
  LS_ITEM-MOVE_TYPE = '101'.
  LS_ITEM-STCK_TYPE = PS_LIST-INSMK.
  LS_ITEM-ENTRY_QNT = PS_LIST-ERFMG.
  LS_ITEM-ENTRY_UOM = PS_LIST-MEINS.
  LS_ITEM-VENDRBATCH = PS_LIST-LICHA.
  LS_ITEM-PROD_DATE = PS_LIST-HSDAT.
* ★ 수정 2026.09.10: RFC(ZGTMM_IF_I_DRGR_RCV) 방식에 맞춰 통일
*   UNLOAD_PT(하역장소) = 드럼라벨번호, ITEM_TEXT(텍스트) = 납품서번호-품목
  LS_ITEM-UNLOAD_PT = PS_LIST-DR_LABELNO.
  LS_ITEM-ITEM_TEXT = PS_LIST-DELNO && '-' && PS_LIST-DELITEM.

  CASE PS_LIST-PSTYP.
    WHEN SPACE OR '0'. "일반
*CASE1. 일반 입고 : IT_TAB-PSTYP = "" AND
**"처리 자재의  자재유형이 HAWA 이면 DEFAULT 값 채번
**배치번호 : GO00000001"
*      IF PS_LIST-MTART EQ 'HAWA'.
*        LS_ITEM-BATCH = 'GO00000001'.
*      ENDIF.
*3)배치관리 유형 FACTOR BATCH이면(DPCBT = 'A') 조장정보로 채번
      READ TABLE PT_VC ASSIGNING FIELD-SYMBOL(<VC>)
      WITH KEY PDOC = PS_LIST-EBELN
                     PDOCITEM = PS_LIST-EBELP
                     DPCBT = 'A' BINARY SEARCH.
      IF SY-SUBRC = 0.
        LS_ITEM-BATCH = CONV I( <VC>-LENGTH ).
        CONDENSE LS_ITEM-BATCH NO-GAPS.

      ELSE.
*FACTOR BATCH 아니면,
*2)처리 자재의  자재유형이 HAWA 일때, 배치관리유형에 따라 설정
        IF PS_LIST-MTART EQ 'HAWA'.
          SELECT SINGLE  DPCBT
            FROM MARC
            WHERE MATNR EQ @PS_LIST-MATNR
                 AND WERKS EQ @PS_LIST-WERKS
            INTO @DATA(LV_DPCBT).

          CASE LV_DPCBT.
*2-2)공백이면 DEFAULT 값 채번_배치번호 : GO00000001"
            WHEN SPACE.
              LS_ITEM-BATCH = 'GO00000001'.
*2-1)MARC-DPCBT = 'C'->자동채번
            WHEN 'C'.
            WHEN OTHERS.
          ENDCASE.
        ENDIF.
      ENDIF.

    WHEN '3'.  "외주 임가공_메인품목 자재 배치 설정 조건 체크 추가
*배치관리 유형 FACTOR BATCH이면(DPCBT = 'A') 조장정보로 채번,없으면 자동채번
      READ TABLE PT_VC ASSIGNING FIELD-SYMBOL(<VCL>)
      WITH KEY PDOC = PS_LIST-EBELN
                     PDOCITEM = PS_LIST-EBELP
                     DPCBT = 'A' BINARY SEARCH.
      IF SY-SUBRC = 0.
        LS_ITEM-BATCH = CONV I( <VCL>-LENGTH ).
        CONDENSE LS_ITEM-BATCH NO-GAPS.
      ENDIF.
  ENDCASE.

  LS_ITEM-MVT_IND = GC_B.
  LS_ITEM-LINE_ID = LINES( CT_ITEM ) + 1.
  CT_ITEM = VALUE #( BASE CT_ITEM ( LS_ITEM ) ).

*자재문서 생성 후 품목별 배치 업데이트 위한 세팅.
  PS_LIST-LINE_ID = LS_ITEM-LINE_ID.

  CHECK PS_LIST-PSTYP EQ GC_3. "외주 임가공인 경우

  DATA:
    LV_ERFMG   TYPE MENGV13,
    LV_ERFMG_O TYPE ERFMG.

  FIELD-SYMBOLS <LS_MSLB> TYPE TY_MSLB.

  DATA LS_COMP TYPE BAPI2017_GM_ITEM_CREATE.
  LS_COMP-PARENT_ID	 = LS_ITEM-LINE_ID.
  LS_COMP-LINE_ID       = LS_ITEM-LINE_ID.
  LS_COMP-ITEM_TEXT = COND #( WHEN P_PO = GC_X THEN SPACE
                                                     WHEN P_LNO = GC_X "OEM 드럼라벨
                                                     THEN PS_LIST-DR_LABELNO(13) && '-' && PS_LIST-DR_LABELNO+14(4) ).
*1) 외주임가공 투입정보 관리 이력 테이블 정보 점검(ISSUE_COMP)
*TABLE : ZGTMMT9450
*SELECT 조건 : IDNRK,CHARG,EBELN,EBELP,MENGE,MEINS
*WHRE 조건 : MAIN-EBELN,MAIN-EBELP,LIFNR,WERKS

  READ TABLE PT_ZGTMMT9450 WITH KEY EBELN = PS_LIST-EBELN
                                                               EBELP = PS_LIST-EBELP
                                                               WERKS = PS_LIST-WERKS
                                                BINARY SEARCH TRANSPORTING NO FIELDS.
  IF SY-SUBRC EQ 0.
*조회된  COMPONENT 자재,배치별 BAPI ITEM 라인 추가
    LOOP AT PT_ZGTMMT9450 ASSIGNING FIELD-SYMBOL(<LS_ZGTMMT9450>).

      LS_COMP-MATERIAL = <LS_ZGTMMT9450>-IDNRK.
      LS_COMP-PLANT = PS_LIST-WERKS.
      LS_COMP-PO_NUMBER = <LS_ZGTMMT9450>-EBELN.
      LS_COMP-PO_ITEM = <LS_ZGTMMT9450>-EBELP.
      LS_COMP-MOVE_TYPE = '543'.
      LS_COMP-BATCH = <LS_ZGTMMT9450>-CHARG.
      LS_COMP-ENTRY_UOM = <LS_ZGTMMT9450>-MEINS.
      LS_COMP-MVT_IND = GC_B.

*ENTRY_QNT(입고수량) 조건 별 설정
*1-1) ISSUE_COMP=CHARGE <> NULL -> ISSUE_COMP-MENGE
*1-2) ISSUE_COMP=CHARGE """" 이면
*  : PO 소요량정보로 입고수량 대비 투입 처리 수량 산출
*  ->COMPONENT 소비량 = 입고 수량 * 단위당소요량(RESB-BDMNG/EKPO-MENGE)"

      IF <LS_ZGTMMT9450>-CHARG IS NOT INITIAL.
        LS_COMP-ENTRY_QNT = <LS_ZGTMMT9450>-MENGE.

      ELSE.
        READ TABLE PT_RESB ASSIGNING <LS_RESB> WITH KEY  EBELN = <LS_ZGTMMT9450>-EBELN
                                                                                              EBELP = <LS_ZGTMMT9450>-EBELP
                                                                                              MATNR = <LS_ZGTMMT9450>-IDNRK.
        IF SY-SUBRC EQ 0.
          IF <LS_RESB>-MENGE IS NOT INITIAL.
            LS_COMP-ENTRY_QNT = PS_LIST-MENGE * ( <LS_RESB>-BDMNG / <LS_RESB>-MENGE ).
          ELSE.
            LS_COMP-ENTRY_QNT = 0.
          ENDIF.
        ELSE.
          CV_CHECK = GC_E.
          EXIT.
        ENDIF.
      ENDIF.

      LS_COMP-LINE_ID += 1.
      CT_ITEM = VALUE #( BASE CT_ITEM ( LS_COMP ) ).

    ENDLOOP.

*2) 임가공 투입정보 테이블 정보가 존재하지 않는 경우,
*구매오더의 COMPONENT 자재 정보 점검(PO_COMP)
*TABLE : RESB
*SELECT조건 : RSPOS,MATNR,BDMNG,MEINS,WERKS,LGORT,CHARG
*WHRE 조건 : ALV-EBELN, ALV-EBELP
  ELSE.
    "PO COMPONENT 기준
    READ TABLE PT_RESB WITH KEY EBELN = PS_LIST-EBELN
                                                     EBELP = PS_LIST-EBELP
                                                     BINARY SEARCH TRANSPORTING NO FIELDS.
    IF SY-SUBRC EQ 0.
      LOOP AT PT_RESB ASSIGNING <LS_RESB> FROM SY-TABIX.
        IF <LS_RESB>-EBELN NE PS_LIST-EBELN
          OR <LS_RESB>-EBELP NE PS_LIST-EBELP.
          EXIT.
        ENDIF.

        LS_COMP-MATERIAL = <LS_RESB>-MATNR.
        LS_COMP-PLANT = <LS_RESB>-WERKS.
        LS_COMP-STGE_LOC = <LS_RESB>-LGORT.
        LS_COMP-PO_NUMBER = <LS_RESB>-EBELN.
        LS_COMP-PO_ITEM = <LS_RESB>-EBELP.
        LS_COMP-MOVE_TYPE = '543'.
        LS_COMP-BATCH = <LS_RESB>-CHARG.
*ENTRY_QNT(입고수량) 조건 별 설정
*2-1) ISSUE_COMP=CHARGE <> NULL -> ISSUE_COMP-MENGE
*2-2) ISSUE_COMP=CHARGE """" 이면
*  : PO 소요량정보로 입고수량 대비 투입 처리 수량 산출
*  ->COMPONENT 소비량 = 입고 수량 * 단위당소요량(RESB-BDMNG/EKPO-MENGE)"
        IF <LS_RESB>-MENGE IS NOT INITIAL.
          LS_COMP-ENTRY_QNT = PS_LIST-MENGE * ( <LS_RESB>-BDMNG / <LS_RESB>-MENGE ).
        ELSE.
          LS_COMP-ENTRY_QNT = 0.
        ENDIF.

        LS_COMP-ENTRY_UOM = <LS_RESB>-MEINS.
        LS_COMP-MVT_IND = GC_B.

        "라인추가
        IF <LS_RESB>-XCHPF EQ ABAP_TRUE AND <LS_RESB>-CHARG EQ SPACE.
*"투입자재가 배치관리 자재이고 (ZGTMM_CV_SC_RESBLIST-XCHPF = 'X')
*PO_COMP-CHARG 값이 공백인 경우
*공급업체 재고 테이블 기준 BATCH 번호 추출 투입 처리(선입 선출 기준)
*TABLE : MSLB
*SELECT 조건 : LBLAB 0 이 아닌 CHARG
*WHERE 조건 :
*MATNR = PO_COMP-MATNR
*WERKS = PO_COMP_WERKS
*LIFNR = EKKO-LIFNR
          LV_ERFMG = LS_COMP-ENTRY_QNT. "대상 출고 수량
          READ TABLE PT_MSLB WITH KEY MATNR = <LS_RESB>-MATNR
                                                            WERKS = <LS_RESB>-WERKS
                                                            LIFNR = <LS_RESB>-LIFNR
                                                            BINARY SEARCH TRANSPORTING NO FIELDS.
          IF SY-SUBRC EQ 0.
            LOOP AT PT_MSLB ASSIGNING <LS_MSLB> FROM SY-TABIX.
              IF <LS_MSLB>-MATNR NE <LS_RESB>-MATNR
                OR <LS_MSLB>-WERKS NE <LS_RESB>-WERKS
                OR <LS_MSLB>-LIFNR NE <LS_RESB>-LIFNR.
                EXIT.
              ENDIF.

              CHECK <LS_MSLB>-LBLAB GE 0. "재고수량이 0보다 큰 경우만 진행

              "적용 수량 빼기
              LV_ERFMG_O = LV_ERFMG.
              LV_ERFMG -= <LS_MSLB>-LBLAB.

              LS_COMP-BATCH = <LS_MSLB>-CHARG.

              IF LV_ERFMG LT 0.
                "적용한 수량이 대상 출고수량 보다 큰 경우
                IF <LS_MSLB>-XPCBT EQ ABAP_TRUE AND <LS_MSLB>-XPRGI EQ SPACE.
*"BATCH 별 투입 시 지정된 BATCH가 단일 배치단위이면 (MCH1-XPCBT='X')
*BATCH 가용재고전량투입 처리"
* & 부분수량 GI 허용이 SPACE 인 경우
                  LS_COMP-ENTRY_QNT = <LS_MSLB>-LBLAB.
                ELSE.
                  "단일 배치단위가 아니면 잔량적용
                  LS_COMP-ENTRY_QNT = LV_ERFMG_O.
                ENDIF.
              ELSE.
                LS_COMP-ENTRY_QNT = <LS_MSLB>-LBLAB.
              ENDIF.

              "재고수량에서 적용수량 빼기
              <LS_MSLB>-LBLAB -=  LS_COMP-ENTRY_QNT.

              LS_COMP-LINE_ID += 1.
              CT_ITEM = VALUE #( BASE CT_ITEM ( LS_COMP ) ). "라인추가

              "적용 수량이 대상 출고수량을 초과한 경우 종료
              IF LV_ERFMG LE 0.
                EXIT.
              ENDIF.

            ENDLOOP.
          ELSE.
            LS_COMP-LINE_ID += 1.
            CT_ITEM = VALUE #( BASE CT_ITEM ( LS_COMP ) ).
          ENDIF.

        ELSE.
          LS_COMP-LINE_ID += 1.
          CT_ITEM = VALUE #( BASE CT_ITEM ( LS_COMP ) ).
        ENDIF.

      ENDLOOP.
    ENDIF.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& FORM BATCH_CHANGE
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
*&      --> <LS_ITEM>
*&---------------------------------------------------------------------*
FORM BATCH_CHANGE  TABLES PT_VCQTY TYPE TY_T_VC
                                      USING    PS_TAB TYPE TY_LIST
                                                  PS_BAPI TYPE TY_LIST.
*C) 배치자재인 경우(MARC-XCHPF=X) 배치마스터 제조일자 업데이트
*
*	데이터 설정
* BAPI 필드             VAULE
* MATERIAL              MATDOC-MATNR
* BATCH             MATDOC-CHARG
* PLANT             MATDOC-PLANT
*
*	BATCHATTRIBUTES	BATCHATTRIBUTES
* BAPI 필드             VAULE
* PROD_DATE             IT_TAB-HSDAT
*
*	BATCHATTRIBUTESX
* BAPI 필드             VAULE
* PROD_DATE             X
*
*   BAPI_BATCH_CHANGE 수행
*
*   4-5-1) RETURN-TYPE = E 이면
*     : CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'
*   4-5-2) RETURN-TYPE = S 이면
*     : CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
*
  DATA:
    LS_BATCH  TYPE BAPIBATCHATT,
    LS_BATCHX TYPE BAPIBATCHATTX,
    LV_MSG    TYPE BAPI_MSG,
    LV_ERROR.

  DATA:
    LT_RETURN   TYPE STANDARD TABLE OF BAPIRET2,
    LT_ALLOC    TYPE TABLE OF BAPI1003_ALLOC_VALUES_CHAR,
    LT_ALC_NUM  TYPE TABLE OF BAPI1003_ALLOC_VALUES_NUM,
    LT_ALC_CURR TYPE TABLE OF BAPI1003_ALLOC_VALUES_CURR,
    LV_CLASS    TYPE BAPI1003_KEY-CLASSNUM, "KLAH-CLASS,
    LV_STATUS   TYPE BAPI1003_KEY-STATUS,
    LV_KEY      TYPE BAPI1003_KEY-OBJECT,
    LV_MAT18    TYPE MATNR18,
    LV_LENTH    TYPE ATWRT30.

  DATA:
    LV_MATNR TYPE BAPIBATCHKEY-MATERIAL,
    LV_CHARG TYPE BAPIBATCHKEY-BATCH,
    LV_WERKS TYPE BAPIBATCHKEY-PLANT.

*BAPI SET
*BAPI_배치자재(라벨정보) 제조일 업데이트
  CLEAR: LS_BATCH, LS_BATCHX.
  LS_BATCH   = VALUE #( PROD_DATE = PS_TAB-HSDAT ).
  LS_BATCHX = VALUE #( PROD_DATE = GC_X ).

  SELECT M~WERKS, M~CHARG_SID, M~MATNR,
               M~EBELN, M~EBELP, M~MBLNR, M~LINE_ID,
               M~MJAHR, M~MENGE, M~MEINS, M~LGORT,
               C~DISPO, C~DPCBT, A~MATKL
  FROM MATDOC AS M
  INNER JOIN MARC AS C
              ON C~WERKS = M~WERKS
             AND C~MATNR = M~MATNR
  INNER JOIN MARA AS A
              ON A~MATNR = M~MATNR
  WHERE M~WERKS = @P_WERKS
       AND M~BUKRS = @P_BUKRS
       AND M~MATNR = @PS_TAB-MATNR
       AND M~MBLNR = @PS_TAB-MBLNR
  INTO TABLE @DATA(LT_MAT).
  SORT LT_MAT BY MBLNR LINE_ID.

  CLEAR : LV_ERROR , GT_RETURN.

  IF P_LNO = GC_X.
    READ TABLE LT_MAT INTO DATA(LS_MAT)
    WITH KEY MBLNR = PS_TAB-MBLNR
                   LINE_ID = PS_BAPI-LINE_ID BINARY SEARCH.
    IF SY-SUBRC = 0.
**자재유형이 'MCHA' OR 'MCFE' 일 경우는 공통코드 체크 후 꼬리표 업데이트 여부 결정.
      IF PS_TAB-MTART = 'MCHA' OR PS_TAB-MTART = 'MCFE'.
*1.입고처리 플랜트&입고자재의 자재그룹이 공통 마스터정보에(ZGTPPT1010) 존재시 업데이트 제외.
        READ TABLE GT_ZGTPPT1010 TRANSPORTING NO FIELDS
        WITH KEY FLD_01 = PS_TAB-WERKS
                       FLD_02 = LS_MAT-MATKL BINARY SEARCH.
        IF SY-SUBRC = 0.
          LV_ERROR = GC_X.
        ELSE.
*2.입고처리 플랜트&저장위치가 공통 마스터정보에(ZGTPPT1010) 존재시 업데이트 제외.
          IF PS_TAB-LGORT IS NOT INITIAL .
            READ TABLE GT_ZGTPPT1010 TRANSPORTING NO FIELDS
            WITH KEY FLD_01 = PS_TAB-WERKS
                           FLD_02 = ''
                           FLD_03 = PS_TAB-LGORT BINARY SEARCH.
            IF SY-SUBRC = 0.
              LV_ERROR = GC_X.
            ELSE.
              CLEAR LV_ERROR.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.

      IF LV_ERROR IS INITIAL
        AND PS_TAB-LGORT NE '3497' AND PS_TAB-LGORT NE '3498'.  " ★ 수정 2026.08.28: 저장위치 3497/3498 꼬리표 미생성
        APPEND VALUE #( WERKS = LS_MAT-WERKS
                                    AUFNR = LS_MAT-EBELN
                                    TAGNR = PS_TAB-DR_LABELNO
                                    POSNR = LS_MAT-EBELP
                                    CHARG = LS_MAT-CHARG_SID
                                    MBLNR = LS_MAT-MBLNR
                                    MATNR = LS_MAT-MATNR
                                    SPGCD  = LS_MAT-DISPO(2)
                                    MGVRG = LS_MAT-MENGE
                                    FOSTCNT = GC_1
                                    REMAIN = LS_MAT-MENGE
                                    MEINS = LS_MAT-MEINS
                                    OUTFLG = COND #( WHEN PS_TAB-PSTYP = GC_3 THEN GC_X ELSE '' )
                                    GIFLG = GC_N
                                    GRFLG = GC_Y
                                    INSPFLG = GC_OK
                                    LGORT = LS_MAT-LGORT
                                    GRINDAT = SY-DATUM
                                    GRINTIM = SY-UZEIT
                                    GRINNAM = SY-UNAME ) TO GT_ZPPT0001.
      ENDIF.
    ENDIF.

  ELSE.
    CLEAR LS_MAT.

* ★ 수정 2026.08.28_ZGODEV04 : EBELN/EBELP(자기 라인) 조건 누락으로 인해
*   동일 자재문서(MBLNR)+동일자재(MATNR)를 공유하는 다른 PO 품목까지 함께 순회되어
*   ZPPT0001(꼬리표번호)에 다른 구매오더로 교차 저장되는 버그 수정.
    LOOP AT LT_MAT INTO LS_MAT
      WHERE EBELN = PS_TAB-EBELN
                AND EBELP = PS_TAB-EBELP.
      DATA(LV_TABIX) = SY-TABIX.

      IF LS_MAT-DPCBT = 'A'. "FACTOR BATCH
*2-13) 배치자재인 경우(MARC-XCHPF=X) 이고 배치 유형이 A 이면(FACTOR BATCH)
*    배치 클래스 속성 정보 업데이트 BAPI 수행_배치 특성 업데이트
        CLEAR LV_LENTH.
*2-13-1) FACTOR BATCH 여부 체크 & 조장정보 가져오기.
        READ TABLE PT_VCQTY ASSIGNING FIELD-SYMBOL(<VC>)
        WITH KEY PDOC = PS_TAB-EBELN
                       PDOCITEM = PS_TAB-EBELP
                       DPCBT = 'A' BINARY SEARCH.
        IF SY-SUBRC = 0.
          LV_LENTH = CONV I( <VC>-LENGTH ).
          CONDENSE LV_LENTH NO-GAPS.
        ENDIF.
*2-13-2) FACTOR 배치 자재의 CLASS 조회
* CLASS번호
        CLEAR: LV_CLASS.
        CALL FUNCTION 'CLFC_BATCH_ALLOCATION_TO_CLASS'
          EXPORTING
            MATERIAL           = LS_MAT-MATNR "입고자재
            PLANT              = LS_MAT-WERKS "플랜트
            CLASSTYPE          = '023'       "클래스유형(배치)
          IMPORTING
            CLASS              = LV_CLASS
          EXCEPTIONS
            NO_CLASS_FOUND     = 1
            NO_CLASSTYPE_FOUND = 2
            OTHERS             = 3.

        CHECK LV_CLASS IS NOT INITIAL.
*2-13-3)배치 클래스 속성 정보 업데이트  BAPI 수행
        CLEAR LT_ALC_NUM.
        LT_ALC_NUM[] = VALUE #( BASE LT_ALC_NUM
                                                  ( CHARACT = 'SAP_MILLCA_LENGTH'
                                                    VALUE_FROM = LV_LENTH )
                                                  ( CHARACT = 'SAP_MILLCA_LENGTH_SUB'
                                                    VALUE_FROM = LV_LENTH ) ).
        CLEAR : LT_RETURN.
        SELECT SINGLE CUOBJ_BM
           FROM MCH1
           WHERE MATNR = @PS_TAB-MATNR
               AND CHARG = @LS_MAT-CHARG_SID
           INTO @DATA(LV_OBJKEY).

        IF LV_OBJKEY IS NOT INITIAL.
          CALL FUNCTION 'BAPI_OBJCL_CHANGE_KEY'
            EXPORTING
              CLOBJECTKEY         = LV_OBJKEY
              CLASSNUM            = LV_CLASS
            IMPORTING
              CLASSIF_STATUS      = LV_STATUS
            TABLES
              ALLOCVALUESNUM_NEW  = LT_ALC_NUM
              ALLOCVALUESCHAR_NEW = LT_ALLOC
              ALLOCVALUESCURR_NEW = LT_ALC_CURR
              RETURN              = LT_RETURN.
*        CLEAR LT_ALLOC.
*        LT_ALLOC[] = VALUE #( BASE LT_ALLOC
*                                              ( CHARACT = 'SAP_MILLCA_LENGTH'
*                                                VALUE_CHAR = LV_LENTH )
*                                              ( CHARACT = 'SAP_MILLCA_LENGTH_SUB'
*                                                VALUE_CHAR = LV_LENTH ) ).
*
*        CLEAR : LV_MAT18, LV_KEY, LT_RETURN.
*        LV_MAT18 = |{ LS_MAT-MATNR ALPHA = IN }|.
*        LV_KEY(18) = LV_MAT18.
*        LV_KEY+18(10) = LS_MAT-CHARG_SID.
*
*        CALL FUNCTION 'BAPI_OBJCL_CHANGE'
*          EXPORTING
*            OBJECTKEY          = LV_KEY
*            OBJECTTABLE        = 'MCH1'
*            CLASSNUM           = LV_CLASS
*            CLASSTYPE          = '023'
*          TABLES
*            ALLOCVALUESNUMNEW  = LT_ALC_NUM
*            ALLOCVALUESCHARNEW = LT_ALLOC
*            ALLOCVALUESCURRNEW = LT_ALC_CURR
*            RETURN             = LT_RETURN.
          READ TABLE LT_RETURN ASSIGNING FIELD-SYMBOL(<LS_R2TURN>) WITH KEY TYPE = GC_E.
          IF SY-SUBRC EQ 0.
*      오류
            CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
            PS_TAB-MESSAGE = <LS_R2TURN>-MESSAGE.

          ELSE.
*      배치특성 성공
            CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
              EXPORTING
                WAIT = ABAP_TRUE.
          ENDIF.
        ENDIF.
      ENDIF.

*BAPI_배치자재(라벨정보) 제조일 업데이트
      TRY.
          CALL FUNCTION 'BAPI_BATCH_CHANGE'
            EXPORTING
              BATCH            = LS_MAT-CHARG_SID
              PLANT            = LS_MAT-WERKS
              BATCHATTRIBUTES  = LS_BATCH
              BATCHATTRIBUTESX = LS_BATCHX
              MATERIAL_LONG    = LS_MAT-MATNR
            TABLES
              RETURN           = GT_RETURN.

        CATCH CX_ROOT INTO DATA(LV_ERR).
          LV_MSG = LV_ERR->GET_TEXT( ).
          MESSAGE S000 WITH LV_MSG.
      ENDTRY.

      IF LINE_EXISTS( GT_RETURN[ TYPE = GC_E ] ).
        CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

        READ TABLE GT_RETURN INTO DATA(LS_RT) INDEX 1.
        PS_TAB-STATUS    = COND #( WHEN PS_TAB-MBLNR IS INITIAL THEN  ICON_LED_RED
                                                      ELSE ICON_LED_GREEN ).
        PS_TAB-MESSAGE = LS_RT-MESSAGE.

      ELSE.
        CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
          EXPORTING
            WAIT = GC_X.
*배치 업데이트 성공 시, 자재문서 기준으로 꼬리표번호 테이블 업데이트
**자재유형이 'MCHA' OR 'MCFE' 일 경우는 공통코드 체크 후 꼬리표 업데이트 여부 결정.
        IF PS_TAB-MTART = 'MCHA' OR PS_TAB-MTART = 'MCFE'.
*1.입고처리 플랜트&입고자재의 자재그룹이 공통 마스터정보에(ZGTPPT1010) 존재시 업데이트 제외.
          READ TABLE GT_ZGTPPT1010 TRANSPORTING NO FIELDS
          WITH KEY FLD_01 = PS_TAB-WERKS
                         FLD_02 = LS_MAT-MATKL BINARY SEARCH.
          IF SY-SUBRC = 0.
            LV_ERROR = GC_X.
          ELSE.
*2.입고처리 플랜트&저장위치가 공통 마스터정보에(ZGTPPT1010) 존재시 업데이트 제외.
            IF PS_TAB-LGORT IS NOT INITIAL .
              READ TABLE GT_ZGTPPT1010 TRANSPORTING NO FIELDS
              WITH KEY FLD_01 = PS_TAB-WERKS
                             FLD_02 = ''
                             FLD_03 = PS_TAB-LGORT BINARY SEARCH.
              IF SY-SUBRC = 0.
                LV_ERROR = GC_X.
              ELSE.
                CLEAR LV_ERROR.
              ENDIF.
            ENDIF.

          ENDIF.
        ENDIF.

        IF LV_ERROR IS INITIAL.
*꼬리표번호 테이블 업데이트 데이터 설정
          CASE GC_X.
            WHEN P_DNO.

* ★ 수정 2026.08.28: INDEX(엉뚱한 라인) 대신 DELNO/DELITEM KEY로 정확히 매칭
              READ TABLE GT_LIST_300 ASSIGNING FIELD-SYMBOL(<LABEL>)
              WITH KEY DELNO = PS_TAB-DELNO
                             DELITEM = PS_TAB-DELITEM BINARY SEARCH.
              IF SY-SUBRC = 0.
                DATA(LV_TAG) = <LABEL>-LABELNO && <LABEL>-LABELITEM.
              ELSE.
* ★ 수정 2026.08.28: 라벨 못 찾으면 납품문서번호 대신 실제 배치번호(CHARG) 사용
                LV_TAG = LS_MAT-CHARG_SID.
              ENDIF.

              IF LV_TAG IS NOT INITIAL
                AND ( PS_TAB-LGORT NE '3497' AND PS_TAB-LGORT NE '3498' ).  " ★ 수정 2026.08.28: 저장위치 3497/3498 꼬리표 미생성
                APPEND VALUE #( WERKS = LS_MAT-WERKS
                                          AUFNR = LS_MAT-EBELN
                                          TAGNR = COND #( WHEN P_LNO = GC_X THEN PS_TAB-DR_LABELNO
                                                                      ELSE LV_TAG )
                                          POSNR = LS_MAT-EBELP
                                          CHARG = LS_MAT-CHARG_SID
                                          MBLNR = LS_MAT-MBLNR
                                          MATNR = LS_MAT-MATNR
                                          SPGCD  = LS_MAT-DISPO(2)
                                          MGVRG = LS_MAT-MENGE
                                          FOSTCNT = GC_1
                                          REMAIN = LS_MAT-MENGE
                                          MEINS = LS_MAT-MEINS
                                          OUTFLG = COND #( WHEN PS_TAB-PSTYP = GC_3 THEN GC_X ELSE '' )
                                          GIFLG = GC_N
                                          GRFLG = GC_Y
                                          INSPFLG = GC_OK
                                          LGORT = LS_MAT-LGORT
                                          GRINDAT = SY-DATUM
                                          GRINTIM = SY-UZEIT
                                          GRINNAM = SY-UNAME ) TO GT_ZPPT0001.
              ENDIF.

            WHEN OTHERS. "P_PO
              IF PS_TAB-LGORT NE '3497' AND PS_TAB-LGORT NE '3498'.  " ★ 수정 2026.08.28: 저장위치 3497/3498 꼬리표 미생성
                APPEND VALUE #( WERKS = LS_MAT-WERKS
                                         AUFNR = LS_MAT-EBELN
                                         TAGNR = COND #( WHEN P_LNO = GC_X THEN PS_TAB-DR_LABELNO
                                                                     ELSE LS_MAT-CHARG_SID )  " ★ 수정 2026.09.10: P_PO 납품서번호 대신 배치번호 사용
                                         POSNR = LS_MAT-EBELP
                                         CHARG = LS_MAT-CHARG_SID
                                         MBLNR = LS_MAT-MBLNR
                                         MATNR = LS_MAT-MATNR
                                         SPGCD  = LS_MAT-DISPO(2)
                                         MGVRG = LS_MAT-MENGE
                                         FOSTCNT = GC_1
                                         REMAIN = LS_MAT-MENGE
                                         MEINS = LS_MAT-MEINS
                                         OUTFLG = COND #( WHEN PS_TAB-PSTYP = GC_3 THEN GC_X ELSE '' )
                                         GIFLG = GC_N
                                         GRFLG = GC_Y
                                         INSPFLG = GC_OK
                                         LGORT = LS_MAT-LGORT
                                         GRINDAT = SY-DATUM
                                         GRINTIM = SY-UZEIT
                                         GRINNAM = SY-UNAME ) TO GT_ZPPT0001.
              ENDIF.
          ENDCASE.
        ENDIF.

      ENDIF.
      CLEAR LV_TAG.
    ENDLOOP. "자재문서 업데이트 (배치/꼬리표)루프 종료

  ENDIF.

*  IF GT_ZPPT0001[] IS NOT INITIAL.
*    MODIFY ZPPT0001 FROM TABLE GT_ZPPT0001.
*    COMMIT WORK AND WAIT.
*  ENDIF.

*  CLEAR : LT_MAT, GT_ZPPT0001.

ENDFORM.
*&---------------------------------------------------------------------*
*& FORM BATCH_CHANGE_NEW
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
*&      --> <LS_ITEM>
*&---------------------------------------------------------------------*
FORM BATCH_CHANGE_NEW   TABLES PT_VCQTY TYPE TY_T_VC
                                                  USING    PS_TAB TYPE TY_LIST
                                                           PS_BAPI TYPE TY_LIST.
*C) 배치자재인 경우(MARC-XCHPF=X) 배치마스터 제조일자 업데이트
  DATA:
    LS_BATCH  TYPE BAPIBATCHATT,
    LS_BATCHX TYPE BAPIBATCHATTX,
    LV_MSG    TYPE BAPI_MSG,
    LV_ERROR.

  DATA:
    LT_RETURN   TYPE STANDARD TABLE OF BAPIRET2,
    LT_ALLOC    TYPE TABLE OF BAPI1003_ALLOC_VALUES_CHAR,
    LT_ALC_NUM  TYPE TABLE OF BAPI1003_ALLOC_VALUES_NUM,
    LT_ALC_CURR TYPE TABLE OF BAPI1003_ALLOC_VALUES_CURR,
    LV_CLASS    TYPE BAPI1003_KEY-CLASSNUM, "KLAH-CLASS,
    LV_STATUS   TYPE BAPI1003_KEY-STATUS,
    LV_KEY      TYPE BAPI1003_KEY-OBJECT,
    LV_MAT18    TYPE MATNR18,
    LV_LENTH    TYPE ATWRT30.

  DATA:
    LV_MATNR TYPE BAPIBATCHKEY-MATERIAL,
    LV_CHARG TYPE BAPIBATCHKEY-BATCH,
    LV_WERKS TYPE BAPIBATCHKEY-PLANT.

*BAPI SET
  CLEAR: LS_BATCH, LS_BATCHX.
  LS_BATCH   = VALUE #( PROD_DATE = PS_TAB-HSDAT ).
  LS_BATCHX = VALUE #( PROD_DATE = GC_X ).

  SELECT M~WERKS, M~CHARG_SID, M~MATNR,
               M~EBELN, M~EBELP, M~MBLNR, M~LINE_ID,
               M~MJAHR, M~MENGE, M~MEINS, M~LGORT,
               C~DISPO, C~DPCBT, A~MATKL
  FROM MATDOC AS M
  INNER JOIN MARC AS C
              ON C~WERKS = M~WERKS
             AND C~MATNR = M~MATNR
  INNER JOIN MARA AS A
              ON A~MATNR = M~MATNR
  WHERE M~WERKS = @P_WERKS
       AND M~BUKRS = @P_BUKRS
       AND M~MATNR = @PS_TAB-MATNR
       AND M~MBLNR = @PS_TAB-MBLNR
  INTO TABLE @DATA(LT_MAT).
  SORT LT_MAT BY MBLNR LINE_ID.

  CLEAR : LV_ERROR , GT_RETURN.

  LOOP AT LT_MAT INTO  DATA(LS_MAT).
    DATA(LV_TABIX) = SY-TABIX.

    IF LS_MAT-DPCBT = 'A'.
*2-13) 배치자재인 경우(MARC-XCHPF=X) 이고 배치 유형이 A 이면(FACTOR BATCH)
*    배치 클래스 속성 정보 업데이트 BAPI 수행_배치 특성 업데이트
      CLEAR LV_LENTH.
*2-13-1) FACTOR BATCH 여부 체크 & 조장정보 가져오기.
      READ TABLE PT_VCQTY ASSIGNING FIELD-SYMBOL(<VC>)
      WITH KEY PDOC = PS_TAB-EBELN
                     PDOCITEM = PS_TAB-EBELP
                     DPCBT = 'A' BINARY SEARCH.
      IF SY-SUBRC = 0.
        LV_LENTH = CONV I( <VC>-LENGTH ).
        CONDENSE LV_LENTH NO-GAPS.
      ENDIF.
*2-13-2) FACTOR 배치 자재의 CLASS 조회
* CLASS번호
      CLEAR: LV_CLASS.
      CALL FUNCTION 'CLFC_BATCH_ALLOCATION_TO_CLASS'
        EXPORTING
          MATERIAL           = LS_MAT-MATNR "입고자재
          PLANT              = LS_MAT-WERKS "플랜트
          CLASSTYPE          = '023'       "클래스유형(배치)
        IMPORTING
          CLASS              = LV_CLASS
        EXCEPTIONS
          NO_CLASS_FOUND     = 1
          NO_CLASSTYPE_FOUND = 2
          OTHERS             = 3.

      CHECK LV_CLASS IS NOT INITIAL.
*2-13-3)배치 클래스 속성 정보 업데이트  BAPI 수행
      CLEAR LT_ALC_NUM.
      LT_ALC_NUM[] = VALUE #( BASE LT_ALC_NUM
                                            ( CHARACT = 'SAP_MILLCA_LENGTH'
                                              VALUE_FROM = LV_LENTH )
                                            ( CHARACT = 'SAP_MILLCA_LENGTH_SUB'
                                              VALUE_FROM = LV_LENTH ) ).
      SELECT SINGLE CUOBJ_BM
        FROM MCH1
        WHERE MATNR = @LS_MAT-MATNR
             AND CHARG = @LS_MAT-CHARG_SID
        INTO @DATA(LV_OBJKEY).

      IF LV_OBJKEY IS NOT INITIAL.
        CLEAR :  LT_RETURN.  "LV_MAT18, LV_KEY,
        CALL FUNCTION 'BAPI_OBJCL_CHANGE_KEY'
          EXPORTING
            CLOBJECTKEY         = LV_OBJKEY
            CLASSNUM            = LV_CLASS
          IMPORTING
            CLASSIF_STATUS      = LV_STATUS
          TABLES
            ALLOCVALUESNUM_NEW  = LT_ALC_NUM
            ALLOCVALUESCHAR_NEW = LT_ALLOC
            ALLOCVALUESCURR_NEW = LT_ALC_CURR
            RETURN              = LT_RETURN.
*      LV_MAT18 = |{ LS_MAT-MATNR ALPHA = IN }|.
*      LV_KEY(18) = LV_MAT18.
*      LV_KEY+18(10) = LS_MAT-CHARG_SID.
*
*      CALL FUNCTION 'BAPI_OBJCL_CHANGE'
*        EXPORTING
*          OBJECTKEY          = LV_KEY
*          OBJECTTABLE        = 'MCH1'
*          CLASSNUM           = LV_CLASS
*          CLASSTYPE          = '023'
*        TABLES
*          ALLOCVALUESNUMNEW  = LT_ALC_NUM
*          ALLOCVALUESCHARNEW = LT_ALLOC
*          ALLOCVALUESCURRNEW = LT_ALC_CURR
*          RETURN             = LT_RETURN.
        READ TABLE LT_RETURN ASSIGNING FIELD-SYMBOL(<LS_R2TURN>) WITH KEY TYPE = GC_E.
        IF SY-SUBRC EQ 0.
*      오류_자재문서 생성은 성공했으므로 상태는 유지, 메시지만 설정
          CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
          PS_TAB-MESSAGE = <LS_R2TURN>-MESSAGE.
        ELSE.
*      배치특성 성공
          CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
            EXPORTING
              WAIT = ABAP_TRUE.
        ENDIF.
      ENDIF.
    ENDIF.

*BAPI_배치자재(라벨정보) 제조일 업데이트
    TRY.
        CALL FUNCTION 'BAPI_BATCH_CHANGE'
          EXPORTING
            BATCH            = LS_MAT-CHARG_SID
            PLANT            = LS_MAT-WERKS
            BATCHATTRIBUTES  = LS_BATCH
            BATCHATTRIBUTESX = LS_BATCHX
            MATERIAL_LONG    = LS_MAT-MATNR
          TABLES
            RETURN           = GT_RETURN.

      CATCH CX_ROOT INTO DATA(LV_ERR).
        LV_MSG = LV_ERR->GET_TEXT( ).
        MESSAGE S000 WITH LV_MSG.
    ENDTRY.

    IF LINE_EXISTS( GT_RETURN[ TYPE = GC_E ] ).
      CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

      READ TABLE GT_RETURN INTO DATA(LS_RT) INDEX 1.
      PS_TAB-STATUS    = ICON_LED_GREEN.
      PS_TAB-MESSAGE = LS_RT-MESSAGE.

    ELSE.
      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
        EXPORTING
          WAIT = GC_X.

*배치 업데이트 성공 시, 자재문서 기준으로 꼬리표번호 테이블 업데이트
**자재유형이 'MCHA' OR 'MCFE' 일 경우는 공통코드 체크 후 꼬리표 업데이트 여부 결정.
      IF PS_TAB-MTART = 'MCHA' OR PS_TAB-MTART = 'MCFE'.
*1.입고처리 플랜트&입고자재의 자재그룹이 공통 마스터정보에(ZGTPPT1010) 존재시 업데이트 제외.
        READ TABLE GT_ZGTPPT1010 TRANSPORTING NO FIELDS
        WITH KEY FLD_01 = PS_TAB-WERKS
                       FLD_02 = LS_MAT-MATKL BINARY SEARCH.
        IF SY-SUBRC = 0.
          LV_ERROR = GC_X.
        ELSE.
*2.입고처리 플랜트&저장위치가 공통 마스터정보에(ZGTPPT1010) 존재시 업데이트 제외.
          IF PS_TAB-LGORT IS NOT INITIAL .
            READ TABLE GT_ZGTPPT1010 TRANSPORTING NO FIELDS
            WITH KEY FLD_01 = PS_TAB-WERKS
                           FLD_02 = ''
                           FLD_03 = PS_TAB-LGORT BINARY SEARCH.
            IF SY-SUBRC = 0.
              LV_ERROR = GC_X.
            ELSE.
              CLEAR LV_ERROR.
            ENDIF.
          ENDIF.

        ENDIF.
      ENDIF.

      IF LV_ERROR IS INITIAL.
*꼬리표번호 테이블 업데이트 데이터 설정
        CASE GC_X.
          WHEN P_DNO.

            READ TABLE GT_LIST_300 ASSIGNING FIELD-SYMBOL(<LABEL>)
            WITH KEY DELNO = PS_TAB-DELNO
                           DELITEM = PS_TAB-DELITEM BINARY SEARCH.
            IF SY-SUBRC = 0.
              DATA(LV_TAG) = <LABEL>-LABELNO && <LABEL>-LABELITEM.
            ELSE.
* ★ 수정 2026.08.28: 라벨 못 찾으면 납품문서번호 대신 실제 배치번호(CHARG) 사용
              LV_TAG = LS_MAT-CHARG_SID.
            ENDIF.

            IF LV_TAG IS NOT INITIAL
              AND ( PS_TAB-LGORT NE '3497' AND PS_TAB-LGORT NE '3498' ). "꼬리표 테이블 업데이트 미대상 저장위치 추가_2026731 " ★ 수정 2026.08.28: OR→AND (기존 조건은 항상 참이 되어 제외기능이 동작하지 않던 버그)
              APPEND VALUE #( WERKS = LS_MAT-WERKS
                                        AUFNR = LS_MAT-EBELN
                                        TAGNR = LV_TAG
                                        POSNR = LS_MAT-EBELP
                                        CHARG = LS_MAT-CHARG_SID
                                        MBLNR = LS_MAT-MBLNR
                                        MATNR = LS_MAT-MATNR
                                        SPGCD  = LS_MAT-DISPO(2)
                                        MGVRG = LS_MAT-MENGE
                                        FOSTCNT = GC_1
                                        REMAIN = LS_MAT-MENGE
                                        MEINS = LS_MAT-MEINS
                                        OUTFLG = COND #( WHEN PS_TAB-PSTYP = GC_3 THEN GC_X ELSE '' )
                                        GIFLG = GC_N
                                        GRFLG = GC_Y
                                        INSPFLG = GC_OK
                                        LGORT = LS_MAT-LGORT
                                        GRINDAT = SY-DATUM
                                        GRINTIM = SY-UZEIT
                                        GRINNAM = SY-UNAME ) TO GT_ZPPT0001.
            ENDIF.

          WHEN OTHERS.
        ENDCASE.
      ENDIF.

    ENDIF.
    CLEAR LV_TAG.
  ENDLOOP. "자재문서 업데이트 (배치/꼬리표)루프 종료

ENDFORM.
*&---------------------------------------------------------------------*
*& FORM SET_STATUS_DATA
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
*&      <-- GT_LIST
*&---------------------------------------------------------------------*
FORM SET_STATUS_DATA  CHANGING PT_LIST TYPE TY_T_LIST .

  DATA : LV_MENGE TYPE MENGE_D,
         LV_ERFMG TYPE MENGE_D.

  CHECK PT_LIST[] IS NOT INITIAL.

  SELECT FROM ZGTMM_CV_GET_MATDOC AS Z
       INNER JOIN MATDOC AS M
                   ON M~MBLNR EQ Z~MBLNR
                  AND M~ZEILE EQ Z~ZEILE
                  AND M~EBELN EQ Z~EBELN
                  AND M~EBELP EQ Z~EBELP

              FIELDS Z~MJAHR, Z~EBELN, Z~EBELP, Z~DELNO, Z~DELITEM,
                         Z~MBLNR, Z~ZEILE, Z~ERFMG,
                         Z~BUDAT, Z~MATNR,
                         Z~CANCELLED, Z~REVERSAL_MOVEMENT,
                         M~BWART

  FOR ALL ENTRIES IN @PT_LIST
  WHERE Z~EBELN = @PT_LIST-EBELN
      AND Z~EBELP = @PT_LIST-EBELP
      AND Z~MJAHR = @SY-DATLO(4)
      INTO TABLE @DATA(LT_MAT).

  SORT LT_MAT BY EBELN EBELP DELNO DELITEM ASCENDING MBLNR DESCENDING ZEILE.
  DELETE LT_MAT WHERE CANCELLED = GC_X OR
                                       REVERSAL_MOVEMENT = GC_X.
  DESCRIBE TABLE LT_MAT LINES DATA(LV_LINE).

  IF P_LNO = GC_X.
    SORT LT_MAT BY MBLNR ZEILE.
  ENDIF.

  LOOP AT PT_LIST ASSIGNING FIELD-SYMBOL(<FS>).
    DATA(LV_TABIX) = SY-TABIX.
*입고허용수량 계산_구매오더수량 + ( 구매오더수량 * 초과 납품 허용 한도/100)
    LV_MENGE = <FS>-MENGE + ( <FS>-MENGE * ( <FS>-UEBTO / 100 ) ).
*품목지정범주
    IF <FS>-PSTYP IS INITIAL.
      CLEAR <FS>-PTEXT.
    ELSE.
      READ TABLE GT_T163Y INTO DATA(LS_Y) WITH TABLE KEY PSTYP = <FS>-PSTYP.
      <FS>-PTEXT = COND #( WHEN <FS>-PTEXT NE LS_Y-PTEXT THEN LS_Y-PTEXT
                                            WHEN LS_Y IS INITIAL THEN SPACE ELSE <FS>-PTEXT ).
    ENDIF.
*계정지정범주
    IF <FS>-KNTTP IS INITIAL.
      CLEAR <FS>-KNTTX.
    ELSE.
      READ TABLE GT_T163I INTO DATA(LS_I) WITH TABLE KEY KNTTP = <FS>-KNTTP.
      <FS>-KNTTX = COND #( WHEN <FS>-KNTTX NE LS_I-KNTTX THEN LS_I-KNTTX
                                            WHEN LS_I IS INITIAL THEN SPACE ELSE <FS>-KNTTX ).
    ENDIF.

*조회 조건 별 상태 설정
    CASE GC_X.
*-표준거래명세서(납품문서)
      WHEN P_DNO.
        READ TABLE GT_4403 INTO DATA(LS_4403)
        WITH KEY DELNO = <FS>-DELNO
                       DELITEM = <FS>-DELITEM BINARY SEARCH.
        IF SY-SUBRC = 0.
          "동일한 납품문서 있으면, 대상 제외.
          DELETE PT_LIST INDEX LV_TABIX. CONTINUE.
        ENDIF.

        READ TABLE GT_DELI_X INTO DATA(LS_X)
        WITH KEY DELNO = <FS>-DELNO
                       DELITEM = <FS>-DELITEM BINARY SEARCH.
        IF SY-SUBRC = 0.
          "동일한 납품문서로 STATUS='X'인 데이터도 있으면, 대상 제외.
          DELETE PT_LIST INDEX LV_TABIX. CONTINUE.
        ENDIF.

        READ TABLE LT_MAT INTO DATA(LS_M) WITH KEY
                                                                  EBELN = <FS>-EBELN
                                                                  EBELP = <FS>-EBELP
                                                                  DELNO = <FS>-DELNO
                                                                  DELITEM = <FS>-DELITEM
                                                                  MBLNR = <FS>-MBLNR BINARY SEARCH.
        IF SY-SUBRC = 0.

          IF "P_FIN = GC_X AND  "'완료' 조회 조건 선택시에만,대상에서 제외.
             LS_M-CANCELLED IS NOT INITIAL OR LS_M-REVERSAL_MOVEMENT IS NOT INITIAL .
            DELETE PT_LIST  INDEX LV_TABIX.
            CONTINUE.
          ENDIF.

*          <FS>-MBLNR  = COND #( WHEN <FS>-ELIKZ = GC_X THEN <FS>-MBLNR ELSE SPACE ).
*          <FS>-STATUS = COND #( WHEN <FS>-MBLNR IS INITIAL THEN ICON_LED_YELLOW
*                                                  ELSE  ICON_LED_GREEN ).

          LOOP AT LT_MAT ASSIGNING FIELD-SYMBOL(<MAT2>) WHERE EBELN = <FS>-EBELN.
*            CHECK <MAT2>-BWART = '101'.
            IF <MAT2>-EBELN = <FS>-EBELN AND <MAT2>-EBELP = <FS>-EBELP.
              "입고수량 합산(구매오더&품목기준)
              LV_ERFMG = LV_ERFMG + <MAT2>-ERFMG.
            ELSEIF <MAT2>-DELNO = <FS>-DELNO AND <MAT2>-DELITEM = <FS>-DELITEM.
              "입고수량 합산(납품문서&품목 기준)
              LV_ERFMG = LV_ERFMG + <MAT2>-ERFMG.
            ENDIF.
          ENDLOOP.

          IF  LV_ERFMG >= <FS>-MENGE.  "입고수량>=납품수량
            <FS>-STATUS = ICON_LED_GREEN.
            <FS>-ERFMG  = LV_ERFMG.
            <FS>-MBLNR = COND #( WHEN <FS>-MBLNR IS INITIAL THEN LS_M-MBLNR ELSE <FS>-MBLNR ).
          ENDIF.

          IF <FS>-MENGE > LV_ERFMG.  "납품수량>입고수량
            <FS>-ERFMG = LS_M-ERFMG.
            <FS>-MBLNR = COND #( WHEN <FS>-MBLNR IS INITIAL THEN LS_M-MBLNR
                                                   ELSE <FS>-MBLNR ).
            <FS>-STATUS = COND #( WHEN <FS>-DELCLOSE EQ GC_X THEN ICON_LED_GREEN
                                                    ELSE  ICON_LED_YELLOW ).
          ENDIF.

          <FS>-GRBUDAT = COND #( WHEN <FS>-MBLNR IS INITIAL THEN SPACE ELSE LS_M-BUDAT ).

        ELSE.
          IF LV_LINE = 0. "자재문서 없으면. 미완료.
            <FS>-STATUS = COND #( WHEN <FS>-DELCLOSE EQ GC_X THEN ICON_LED_GREEN
                                                    WHEN <FS>-ELIKZ EQ GC_X THEN ICON_LED_GREEN
                                                    ELSE ICON_LED_YELLOW ).
            <FS>-ERFMG = <FS>-MENGE.
            CLEAR : <FS>-MBLNR, <FS>-GRBUDAT.

          ELSE."자재문서 있으면.
            READ TABLE LT_MAT INTO LS_M
            WITH KEY  EBELN = <FS>-EBELN
                            EBELP = <FS>-EBELP
                            DELNO = <FS>-DELNO
                            DELITEM = <FS>-DELITEM BINARY SEARCH.
            IF SY-SUBRC = 0 .
              IF <FS>-MBLNR IS INITIAL.
                <FS>-STATUS = COND #( WHEN <FS>-DELCLOSE EQ GC_X THEN ICON_LED_GREEN
                                                        WHEN <FS>-ELIKZ EQ GC_X THEN ICON_LED_GREEN
                                                        ELSE ICON_LED_YELLOW ).
              ELSE.
                <FS>-STATUS = ICON_LED_GREEN.
                <FS>-ERFMG = <FS>-MENGE.
                <FS>-GRBUDAT = LS_M-BUDAT.

**--> 26.09 취소시에 기존 전표번호가 있는 케이스 추가
                <FS>-MBLNR = LS_M-MBLNR.
                <FS>-MJAHR = LS_M-MJAHR.
              ENDIF.

            ELSE.
              <FS>-STATUS = COND #( WHEN <FS>-DELCLOSE EQ GC_X THEN ICON_LED_GREEN
                                                      WHEN <FS>-ELIKZ EQ GC_X THEN ICON_LED_GREEN
                                                      ELSE ICON_LED_YELLOW ).
              <FS>-ERFMG = <FS>-MENGE.
              CLEAR : <FS>-MBLNR, <FS>-GRBUDAT.
            ENDIF.
          ENDIF.
        ENDIF.

        IF <FS>-STATUS = ICON_LED_YELLOW OR <FS>-STATUS IS INITIAL.
*라벨정보 유무 체크(배치자재)
          READ TABLE GT_9411 TRANSPORTING NO FIELDS
          WITH KEY DELNO   = <FS>-DELNO
                         DELITEM = <FS>-DELITEM BINARY SEARCH.
          IF SY-SUBRC = 0.
*라벨정보 있으면, 1. 자재유형이 MCHA / MCFE이면, 납품수량으로 설정 후 변경 가능..
*            2.자재 유형 MCHA MCFE 아니면,입고수량 빈값 설정 및 변경 불가
            <FS>-ERFMG = COND #( WHEN <FS>-MTART = 'MCHA' OR <FS>-MTART = 'MCFE'
                                                           OR <FS>-MTART = 'HAWA'
                                                  THEN <FS>-MENGE ELSE '' ).
            <FS>-EDIT = COND #( WHEN <FS>-MTART = 'MCHA' OR <FS>-MTART = 'MCFE'
                                                   OR <FS>-MTART = 'HAWA'
                                              THEN GC_X ELSE '' ).
          ELSE.
*없으면, 납품수량으로 설정 후 사용자가 변경 가능하게..
            <FS>-ERFMG = <FS>-MENGE.
            <FS>-EDIT     = GC_X.
          ENDIF.
          <FS>-STATUS = COND #( WHEN <FS>-STATUS IS INITIAL THEN ICON_LED_YELLOW
                                                  ELSE <FS>-STATUS ).
        ENDIF.

*--수기거래명세서(구매오더)
      WHEN P_PO.
**ZGTMMT9410(납품문서이력)에 존재하면, 입고 미대상->삭제
        READ TABLE GT_9410 TRANSPORTING NO FIELDS
        WITH KEY EBELN = <FS>-EBELN
                       EBELP = <FS>-EBELP BINARY SEARCH.
        IF SY-SUBRC = 0.
          DELETE PT_LIST INDEX LV_TABIX.    CONTINUE.
        ENDIF.
**ZGTMMT9415(OEM드럼라벨이력)에 존재하면, 입고 미대상->삭제
        READ TABLE GT_9415 TRANSPORTING NO FIELDS
        WITH KEY EBELN = <FS>-EBELN
                       EBELP = <FS>-EBELP BINARY SEARCH.
        IF SY-SUBRC = 0.
          DELETE PT_LIST INDEX LV_TABIX.    CONTINUE.
        ENDIF.
*1.납품완료 지시자 있으면 완료, 없으면 미완료.
        <FS>-STATUS = COND #( WHEN <FS>-ELIKZ IS INITIAL THEN  ICON_LED_YELLOW
                                                ELSE ICON_LED_GREEN ).
*2.MATDOC정보 조회
        READ TABLE LT_MAT INTO DATA(LS_P)
        WITH KEY EBELN = <FS>-EBELN
                       EBELP   = <FS>-EBELP
                       DELNO   = <FS>-DELNO
                       DELITEM = <FS>-DELITEM BINARY SEARCH.
        IF LS_P IS INITIAL.
*-자재문서 없으면, 납품문서번호 제외하고 재조회
          READ TABLE LT_MAT INTO LS_P
          WITH KEY EBELN = <FS>-EBELN
                         EBELP = <FS>-EBELP BINARY SEARCH.
          IF LS_P IS INITIAL.
*구매오더 기준으로도자재문서 없으면, 미완료 상태. 입고수량->오더수량으로 설정.
            <FS>-STATUS =  ICON_LED_YELLOW.
            <FS>-ERFMG = <FS>-MENGE.
            <FS>-REMAIN_QTY = LV_MENGE."입고허용수량->계산식 결과 설정.
          ELSE.
*자재문서 있으면,
            IF LS_P-MBLNR IS NOT INITIAL  AND
                LS_P-CANCELLED IS NOT INITIAL OR LS_P-REVERSAL_MOVEMENT IS NOT INITIAL.
*삭제/취소 플래그 존재하는 건 대상 제외
              DELETE GT_LIST  INDEX LV_TABIX.   CONTINUE.

            ELSE.
*              "자재문서 있으면,
              DATA(LV_TABIX3) = SY-TABIX.
              <FS>-GRBUDAT = LS_P-BUDAT.
              <FS>-MBLNR     = LS_P-MBLNR.
              <FS>-MJAHR      = LS_P-MJAHR.

              IF LV_LINE > 1.
                LOOP AT LT_MAT ASSIGNING FIELD-SYMBOL(<MAT3>) FROM LV_TABIX3.
*                  CHECK <MAT3>-BWART = '101'.
                  IF <MAT3>-EBELN = <FS>-EBELN AND <MAT3>-EBELP = <FS>-EBELP.
                    "입고수량 합산(구매오더&품목기준)
                    LV_ERFMG = LV_ERFMG + <MAT3>-ERFMG.
                  ELSE.
                    EXIT.
                  ENDIF.
                ENDLOOP.
              ELSE.
                LV_ERFMG = LS_P-ERFMG.
              ENDIF.
*자재문서 있을때, 입고수량:미완료는 빈값, 완료는 입고된 전체수량 합산
*입고허용수량:(입고허용수량계산값 - 자재문서 합산 입고수량)
**'입고허용수량 > 입고수량'->미완료상태->입고수량 빈값 설정.
              <FS>-STATUS = COND #( WHEN LV_MENGE > LV_ERFMG THEN  ICON_LED_YELLOW ELSE ICON_LED_GREEN ).
              <FS>-ERFMG = COND #( WHEN <FS>-STATUS = ICON_LED_YELLOW THEN 0 ELSE LV_ERFMG ).
              <FS>-REMAIN_QTY = LV_MENGE  - LV_ERFMG. "오더잔량(입고허용수량)=계산식-자재문서입고총수량합
*                <FS>-ERFMG = COND #( WHEN <FS>-REMAIN_QTY = 0 THEN LV_ERFMG ELSE 0 ).
*                <FS>-STATUS = COND #( WHEN <FS>-ERFMG = 0 THEN  ICON_LED_YELLOW ELSE ICON_LED_GREEN ).
            ENDIF.
          ENDIF.

*-자재문서 있으면,
        ELSE.
          IF LS_P-MBLNR IS NOT INITIAL  AND
              LS_P-CANCELLED IS NOT INITIAL OR LS_P-REVERSAL_MOVEMENT IS NOT INITIAL.
*삭제/취소 플래그 존재하는 건 대상 제외
            DELETE GT_LIST  INDEX LV_TABIX.   CONTINUE.

          ELSE.
            CLEAR LV_TABIX3 .  LV_TABIX3 = SY-TABIX.
            <FS>-GRBUDAT = LS_P-BUDAT.
            <FS>-MBLNR     = LS_P-MBLNR.
            <FS>-MJAHR      = LS_P-MJAHR.

            IF LV_LINE > 1.
              LOOP AT LT_MAT ASSIGNING FIELD-SYMBOL(<MAT4>) FROM LV_TABIX3.
                CHECK <MAT4>-BWART = '101'.
                IF <MAT4>-EBELN = <FS>-EBELN AND <MAT4>-EBELP = <FS>-EBELP.
                  "입고수량 합산(구매오더&품목기준)
                  LV_ERFMG = LV_ERFMG + <MAT4>-ERFMG.
                ENDIF.
              ENDLOOP.
            ELSE.
              LV_ERFMG = LS_P-ERFMG.
            ENDIF.
*자재문서 있을때, 입고수량:미완료는 빈값, 완료는 입고된 전체수량 합산
*입고허용수량:(입고허용수량계산값 - 자재문서 합산 입고수량)
**'입고허용수량 > 입고수량'->미완료상태->입고수량 빈값 설정.
            <FS>-STATUS = COND #( WHEN LV_MENGE > LV_ERFMG THEN  ICON_LED_YELLOW ELSE ICON_LED_GREEN ).
            <FS>-ERFMG = COND #( WHEN <FS>-STATUS = ICON_LED_YELLOW THEN 0 ELSE LV_ERFMG ).
            <FS>-REMAIN_QTY = LV_MENGE  - LV_ERFMG. "오더잔량(입고허용수량)=계산식-자재문서입고총수량합
          ENDIF.
        ENDIF.
*3.미완료 기준 조회조건일 경우에만.납품완료 지시자 'X'여도 입고허용수량 체크 한 번 더 해줌.
        IF P_NFN = GC_X AND <FS>-ELIKZ = GC_X. "ELIKZ = GC_X이면, 원래 '납품완료'상태임.
*입고허용수량>입고총수량->미완료&오더수량으로 설정..
          IF LV_MENGE > <FS>-ERFMG.
            <FS>-STATUS = ICON_LED_YELLOW.
            <FS>-ERFMG  = COND #( WHEN <FS>-MBLNR IS INITIAL THEN <FS>-MENGE ELSE '' ).
            <FS>-REMAIN_QTY = LV_MENGE - LV_ERFMG. "오더잔량(입고허용수량)
          ELSE.
            <FS>-STATUS = ICON_LED_GREEN. "완료
          ENDIF.
        ENDIF.

        IF <FS>-STATUS =  ICON_LED_YELLOW.
          <FS>-EDIT      = GC_X.    "사용자 변경 가능
        ENDIF.

****"OEM 드럼 라벨 조회
      WHEN P_LNO.
*ZGTMMT9415에 드럼라벨번호/구매오더/항번 기준으로 STATUS = 'X'인 데이터 있으면, 조회 대상 제외.
        READ TABLE GT_ZGTMMT9415 TRANSPORTING NO FIELDS
        WITH KEY DR_LABELNO = <FS>-DR_LABELNO
                       EBELN = <FS>-EBELN
                       EBELP = <FS>-EBELP
                       STATUS = GC_X BINARY SEARCH.
        IF SY-SUBRC = 0.
          DELETE PT_LIST INDEX LV_TABIX.  CONTINUE.
        ENDIF.
*1)ZGTMMT9415의 자재문서 여부로 상태 설정(MBLNR_자재문서 없으면 미완료)
        <FS>-STATUS = COND #( WHEN <FS>-MBLNR_C IS INITIAL THEN  ICON_LED_YELLOW
                                                ELSE ICON_LED_GREEN ).
        <FS>-MBLNR = COND #( WHEN <FS>-STATUS = ICON_LED_GREEN "완료상태일때,
                                              THEN <FS>-MBLNR_C ELSE <FS>-MBLNR ). "ZGTMMT9415-MBLNR 설정.
*2)한번 더 체크_MES 입고수신이력 내 자재문서의 취소 여부
        READ TABLE GT_MES ASSIGNING FIELD-SYMBOL(<MES>)
        WITH KEY DR_LABEL_NO = <FS>-DR_LABELNO
                       EBELN = <FS>-EBELN
                       EBELP = <FS>-EBELP BINARY SEARCH.
        IF SY-SUBRC = 0.
          <FS>-MBLNR = COND #( WHEN <FS>-MBLNR IS INITIAL THEN <MES>-MBLNR
                                                ELSE <FS>-MBLNR ).
          <FS>-STATUS = COND #( WHEN <MES>-CANCEL = GC_X OR <MES>-REVERSAL = GC_X
                                                  THEN ICON_LED_YELLOW ELSE ICON_LED_GREEN ).
          <FS>-BUDAT = COND #( WHEN <FS>-BUDAT IS INITIAL THEN <MES>-BUDAT
                                                ELSE <FS>-BUDAT ).
          <FS>-MJAHR = COND #( WHEN <FS>-MJAHR IS INITIAL THEN <MES>-MJAHR
                                                ELSE <FS>-MJAHR ).
        ELSE.
          <FS>-STATUS = COND #( WHEN <FS>-MBLNR IS INITIAL THEN ICON_LED_YELLOW
                                                 ELSE <FS>-STATUS ).
        ENDIF.
*        READ TABLE GT_MES ASSIGNING FIELD-SYMBOL(<MES>)
*        WITH KEY MBLNR = <FS>-MBLNR BINARY SEARCH.
*        IF SY-SUBRC = 0. "취소 상태면, 미완료. 취소상태 아니면, 완료.
*          <FS>-STATUS = COND #( WHEN <MES>-CANCEL = GC_X OR <MES>-REVERSAL = GC_X
*                                                  THEN ICON_LED_YELLOW ELSE ICON_LED_GREEN ).
*        ELSE. "입고이력에 해당 자재문서 없으면, 미완료.
*          READ TABLE GT_MES ASSIGNING <MES>
*          WITH KEY DR_LABEL_NO = <FS>-DR_LABELNO
*                         EBELN = <FS>-EBELN
*                         EBELP = <FS>-EBELP BINARY SEARCH.
*          IF SY-SUBRC = 0.
*            <FS>-STATUS = COND #( WHEN <MES>-CANCEL = GC_X OR <MES>-REVERSAL = GC_X
*                                                    THEN ICON_LED_YELLOW ELSE ICON_LED_GREEN ).
*            <FS>-MBLNR = COND #( WHEN <FS>-MBLNR IS INITIAL THEN <MES>-MBLNR
*                                                  ELSE <FS>-MBLNR ).
*            <FS>-BUDAT = COND #( WHEN <FS>-BUDAT IS INITIAL THEN <MES>-BUDAT
*                                                  ELSE <FS>-BUDAT ).
*            <FS>-MJAHR = COND #( WHEN <FS>-MJAHR IS INITIAL THEN <MES>-MJAHR
*                                                  ELSE <FS>-MJAHR ).
*          ELSE.
*            <FS>-STATUS = ICON_LED_YELLOW.
*          ENDIF.
*        ENDIF.

        IF <FS>-MBLNR_C IS NOT INITIAL.
          SELECT SINGLE BUDAT
          FROM MKPF
          INTO @DATA(LV_BUDAT)
          WHERE MBLNR = @<FS>-MBLNR_C
               AND MJAHR = @<FS>-MJAHR.
          <FS>-BUDAT = COND #( WHEN <FS>-STATUS = ICON_LED_GREEN "완료상태일때,
                                                THEN LV_BUDAT ELSE <FS>-BUDAT ).
        ENDIF.

        IF <FS>-STATUS =  ICON_LED_GREEN.
          READ TABLE LT_MAT ASSIGNING FIELD-SYMBOL(<DRMAT>)
          WITH  KEY MBLNR = <FS>-MBLNR
                          ZEILE = <FS>-DR_LABELNO+13(4) BINARY SEARCH.
          IF SY-SUBRC = 0.
            <FS>-ERFMG = <DRMAT>-ERFMG. "입고수량->MATDOC-ERFMG설정
            CLEAR <FS>-EDIT.    "사용자 변경 불가능
          ENDIF.
          IF <FS>-ERFMG IS INITIAL OR <FS>-MENGE IS INITIAL.
            SELECT SINGLE ERFMG, ERFME
              FROM ZGTMMT9415
              WHERE SYSTEM_ID = @GC_KSRM
                   AND EBELN =  @<FS>-EBELN
                   AND EBELP = @<FS>-EBELP
                   AND DR_LABELNO = @<FS>-DR_LABELNO
                   INTO ( @DATA(LV_ERFMG2) , @DATA(LV_ERFME) ).
*MATDOC데이터 없을 시, ZGTMMT9415의 데이터로 설정
            <FS>-ERFMG = COND #( WHEN <FS>-ERFMG IS INITIAL THEN LV_ERFMG2
                                                  ELSE <FS>-ERFMG ).
            <FS>-MENGE = COND #( WHEN <FS>-MENGE IS INITIAL THEN LV_ERFMG2
                                                  ELSE <FS>-MENGE ).
            <FS>-MEINS = COND #( WHEN <FS>-MEINS IS INITIAL THEN LV_ERFME
                                                  ELSE <FS>-MEINS ).
          ENDIF.
        ENDIF.

        IF <FS>-STATUS =  ICON_LED_YELLOW.
          <FS>-ERFMG = <FS>-MENGE. "입고수량->미완료상태,ZGTMMT9415-ERFMG 로 설정.
          <FS>-EDIT     = GC_X.    "사용자 변경 가능
        ENDIF.

      WHEN OTHERS.
    ENDCASE.

    CLEAR : LV_TABIX, LV_ERFMG, LV_MENGE, LS_P.
  ENDLOOP.


ENDFORM.
*&---------------------------------------------------------------------*
*& FORM SET_STATUS_DATA_DISP
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
*&      <-- GT_LIST
*&---------------------------------------------------------------------*
FORM SET_STATUS_DATA_DISP  USING PV_GB  PT_MAT TYPE TY_T_MAT
       CHANGING PS_LIST TYPE TY_LIST .

  DATA :
    LV_MENGE TYPE MENGE_D,
    LV_ERFMG TYPE MENGE_D.

  DESCRIBE TABLE PT_MAT LINES DATA(LV_LINE).
  CLEAR GV_ERR.

*입고허용수량 계산_구매오더수량 + ( 구매오더수량 * 초과 납품 허용 한도/100)
  LV_MENGE = PS_LIST-MENGE + ( PS_LIST-MENGE * ( PS_LIST-UEBTO / 100 ) ).
*품목지정범주
  IF PS_LIST-PSTYP IS INITIAL.
    CLEAR PS_LIST-PTEXT.
  ELSE.
    READ TABLE GT_T163Y INTO DATA(LS_Y) WITH TABLE KEY PSTYP = PS_LIST-PSTYP.
    PS_LIST-PTEXT = COND #( WHEN PS_LIST-PTEXT NE LS_Y-PTEXT THEN LS_Y-PTEXT
                                             WHEN LS_Y IS INITIAL THEN SPACE ELSE PS_LIST-PTEXT ).
  ENDIF.
*계정지정범주
  IF PS_LIST-KNTTP IS INITIAL.
    CLEAR PS_LIST-KNTTX.
  ELSE.
    READ TABLE GT_T163I INTO DATA(LS_I) WITH TABLE KEY KNTTP = PS_LIST-KNTTP.
    PS_LIST-KNTTX = COND #( WHEN PS_LIST-KNTTX NE LS_I-KNTTX THEN LS_I-KNTTX
                                              WHEN LS_I IS INITIAL THEN SPACE ELSE PS_LIST-KNTTX ).
  ENDIF.

*--"표준거래명세서(DELNO)
  CASE PV_GB.
    WHEN GC_D. "표준거래명세서(DELNO)

      READ TABLE PT_MAT INTO DATA(LS_M) WITH KEY
                                                                  EBELN = PS_LIST-EBELN
                                                                  EBELP = PS_LIST-EBELP
                                                                  DELNO = PS_LIST-DELNO
                                                                  DELITEM = PS_LIST-DELITEM
                                                                  MBLNR = PS_LIST-MBLNR BINARY SEARCH.
      IF SY-SUBRC = 0.
        IF LS_M-CANCELLED IS NOT INITIAL OR
                 LS_M-REVERSAL_MOVEMENT IS NOT INITIAL .
          GV_ERR = GC_X. EXIT.
        ENDIF.

        LOOP AT PT_MAT ASSIGNING FIELD-SYMBOL(<MAT>) WHERE EBELN = PS_LIST-EBELN.
          CHECK <MAT>-BWART = '101'.
          IF <MAT>-EBELN = PS_LIST-EBELN AND <MAT>-EBELP = PS_LIST-EBELP.
            "입고수량 합산(구매오더&품목기준)
            LV_ERFMG = LV_ERFMG + <MAT>-ERFMG.
          ELSEIF <MAT>-DELNO = PS_LIST-DELNO AND <MAT>-DELITEM = PS_LIST-DELITEM.
            "입고수량 합산(납품문서&품목 기준)
            LV_ERFMG = LV_ERFMG + <MAT>-ERFMG.
          ENDIF.
        ENDLOOP.

        IF  LV_ERFMG >= PS_LIST-MENGE.  "입고수량>납품수량
          PS_LIST-STATUS = ICON_LED_GREEN.
          PS_LIST-ERFMG  = LV_ERFMG.
          PS_LIST-MBLNR = COND #( WHEN PS_LIST-MBLNR IS INITIAL THEN LS_M-MBLNR ELSE PS_LIST-MBLNR ).
        ENDIF.

        IF PS_LIST-MENGE > LV_ERFMG.  "납품수량>입고수량
          PS_LIST-ERFMG = LS_M-ERFMG.
          PS_LIST-MBLNR = COND #( WHEN PS_LIST-MBLNR IS INITIAL THEN LS_M-MBLNR
                                                    ELSE PS_LIST-MBLNR ).
          PS_LIST-STATUS = COND #( WHEN PS_LIST-DELCLOSE EQ GC_X THEN ICON_LED_GREEN
                                                     WHEN PS_LIST-ELIKZ EQ GC_X THEN ICON_LED_GREEN
                                                      ELSE  ICON_LED_YELLOW ).
        ENDIF.
        "입고전기일자
        PS_LIST-GRBUDAT = COND #( WHEN PS_LIST-MBLNR IS INITIAL THEN SPACE ELSE LS_M-BUDAT ).

      ELSE.
        IF LV_LINE = 0. "자재문서 없으면. 미완료.
          PS_LIST-STATUS =  COND #( WHEN PS_LIST-DELCLOSE EQ GC_X THEN ICON_LED_GREEN
                                                      WHEN PS_LIST-ELIKZ EQ GC_X THEN ICON_LED_GREEN
                                                      ELSE  ICON_LED_YELLOW ).
          PS_LIST-ERFMG = PS_LIST-MENGE.
          CLEAR : PS_LIST-MBLNR, PS_LIST-GRBUDAT.
        ELSE.
          READ TABLE PT_MAT INTO LS_M WITH KEY  EBELN = PS_LIST-EBELN
                                                                            EBELP = PS_LIST-EBELP
                                                                            DELNO = PS_LIST-DELNO
                                                                            DELITEM = PS_LIST-DELITEM BINARY SEARCH.
          IF SY-SUBRC = 0 .
            IF PS_LIST-MBLNR IS INITIAL.
              PS_LIST-STATUS = COND #( WHEN PS_LIST-DELCLOSE EQ GC_X THEN ICON_LED_GREEN
                                                          WHEN PS_LIST-ELIKZ EQ GC_X THEN ICON_LED_GREEN
                                                           ELSE ICON_LED_YELLOW ).
            ELSE.
              PS_LIST-STATUS = ICON_LED_GREEN.
              PS_LIST-ERFMG = PS_LIST-MENGE.
              PS_LIST-GRBUDAT = LS_M-BUDAT.
            ENDIF.

          ELSE.
            PS_LIST-STATUS = COND #( WHEN PS_LIST-DELCLOSE EQ GC_X THEN ICON_LED_GREEN
                                                       WHEN PS_LIST-ELIKZ EQ GC_X THEN ICON_LED_GREEN
                                                        ELSE  ICON_LED_YELLOW ).
            PS_LIST-ERFMG = PS_LIST-MENGE.
            CLEAR : PS_LIST-MBLNR, PS_LIST-GRBUDAT.
          ENDIF.
        ENDIF.
      ENDIF.

      IF PS_LIST-STATUS = ICON_LED_YELLOW OR PS_LIST-STATUS IS INITIAL.
*라벨정보 유무 체크(배치자재)
        READ TABLE GT_9411 TRANSPORTING NO FIELDS
        WITH KEY DELNO   = PS_LIST-DELNO
                       DELITEM = PS_LIST-DELITEM BINARY SEARCH.
        IF SY-SUBRC = 0.
*라벨정보 있으면, 1. 자재유형이 MCHA / MCFE이면, 납품수량으로 설정 후 변경 가능..
*2.자재 유형 MCHA MCFE 아니면,입고수량 빈값 설정 및 변경 불가
          PS_LIST-ERFMG = COND #( WHEN PS_LIST-MTART = 'MCHA' OR PS_LIST-MTART = 'MCFE'
                                                    THEN PS_LIST-MENGE ELSE '' ).
        ELSE.
*없으면, 납품수량으로 설정 후 사용자가 변경 가능하게..
          PS_LIST-ERFMG = PS_LIST-MENGE.
        ENDIF.
        PS_LIST-STATUS = COND #( WHEN PS_LIST-STATUS IS INITIAL THEN ICON_LED_YELLOW
                                                   ELSE PS_LIST-STATUS ).
      ENDIF.

*--수기거래명세서(구매오더)
    WHEN GC_P.
*1.납품완료 지시자 있으면 완료, 없으면 미완료.
      PS_LIST-STATUS = COND #( WHEN PS_LIST-ELIKZ IS INITIAL THEN  ICON_LED_YELLOW
                                                  ELSE ICON_LED_GREEN ).
*2.MATDOC정보 조회
      READ TABLE PT_MAT INTO DATA(LS_P)  WITH KEY EBELN = PS_LIST-EBELN
                                                                                 EBELP = PS_LIST-EBELP
                                                                                 DELNO = PS_LIST-DELNO
                                                                                 DELITEM = PS_LIST-DELITEM BINARY SEARCH.
      IF LS_P IS INITIAL.
*-자재문서 없으면, 납품문서번호 제외하고 재조회
        READ TABLE PT_MAT INTO LS_P WITH KEY EBELN = PS_LIST-EBELN
                                                                        EBELP = PS_LIST-EBELP BINARY SEARCH.
        IF LS_P IS INITIAL.
*구매오더 기준으로도자재문서 없으면, 미완료 상태. 입고수량->오더수량으로 설정.
          PS_LIST-STATUS =  ICON_LED_YELLOW.
          PS_LIST-ERFMG = PS_LIST-MENGE.
          PS_LIST-REMAIN_QTY = LV_MENGE."입고허용수량->계산식 결과 설정.
        ELSE.
*자재문서 있으면,
          IF LS_P-MBLNR IS NOT INITIAL  AND (
              LS_P-CANCELLED IS NOT INITIAL OR LS_P-REVERSAL_MOVEMENT IS NOT INITIAL ).
*삭제/취소 플래그 존재하는 건 대상 제외
            GV_ERR = GC_X. EXIT.

          ELSE.
*              "자재문서 있으면,
            DATA(LV_TABIX3) = SY-TABIX.
            PS_LIST-GRBUDAT = LS_P-BUDAT.
            PS_LIST-MBLNR     = LS_P-MBLNR.
            PS_LIST-MJAHR      = LS_P-MJAHR.

            IF LV_LINE > 1.
              LOOP AT PT_MAT ASSIGNING FIELD-SYMBOL(<MAT3>) FROM LV_TABIX3.
                CHECK <MAT3>-BWART = '101'.
                IF <MAT3>-EBELN = PS_LIST-EBELN AND <MAT3>-EBELP = PS_LIST-EBELP.
                  "입고수량 합산(구매오더&품목기준)
                  LV_ERFMG = LV_ERFMG + <MAT3>-ERFMG.
                ELSE.
                  EXIT.
                ENDIF.
              ENDLOOP.
            ELSE.
              LV_ERFMG = LS_P-ERFMG.
            ENDIF.
*자재문서 있을때, 입고수량:미완료는 빈값, 완료는 입고된 전체수량 합산
*입고허용수량:(입고허용수량계산값 - 자재문서 합산 입고수량)
**'입고허용수량 > 입고수량'->미완료상태->입고수량 빈값 설정.
            PS_LIST-STATUS = COND #( WHEN LV_MENGE > LV_ERFMG THEN  ICON_LED_YELLOW ELSE ICON_LED_GREEN ).
            PS_LIST-ERFMG = COND #( WHEN PS_LIST-STATUS = ICON_LED_YELLOW THEN 0 ELSE LV_ERFMG ).
            PS_LIST-REMAIN_QTY = LV_MENGE  - LV_ERFMG. "오더잔량(입고허용수량)=계산식-자재문서입고총수량합
          ENDIF.
        ENDIF.

*-자재문서 있으면,
      ELSE.
        IF LS_P-MBLNR IS NOT INITIAL  AND (
              LS_P-CANCELLED IS NOT INITIAL OR LS_P-REVERSAL_MOVEMENT IS NOT INITIAL ).
*삭제/취소 플래그 존재하는 건 대상 제외
          GV_ERR = GC_X. EXIT.

        ELSE.
          CLEAR LV_TABIX3 .  LV_TABIX3 = SY-TABIX.
          PS_LIST-GRBUDAT = LS_P-BUDAT.
          PS_LIST-MBLNR     = LS_P-MBLNR.
          PS_LIST-MJAHR      = LS_P-MJAHR.

          IF LV_LINE > 1.
            LOOP AT PT_MAT ASSIGNING FIELD-SYMBOL(<MAT4>) FROM LV_TABIX3.
              CHECK <MAT4>-BWART = '101'.
              IF <MAT4>-EBELN = PS_LIST-EBELN AND <MAT4>-EBELP = PS_LIST-EBELP.
                "입고수량 합산(구매오더&품목기준)
                LV_ERFMG = LV_ERFMG + <MAT4>-ERFMG.
              ENDIF.
            ENDLOOP.
          ELSE.
            LV_ERFMG = LS_P-ERFMG.
          ENDIF.
*자재문서 있을때, 입고수량:미완료는 빈값, 완료는 입고된 전체수량 합산
*입고허용수량:(입고허용수량계산값 - 자재문서 합산 입고수량)
**'입고허용수량 > 입고수량'->미완료상태->입고수량 빈값 설정.
          PS_LIST-STATUS = COND #( WHEN LV_MENGE > LV_ERFMG THEN  ICON_LED_YELLOW ELSE ICON_LED_GREEN ).
          PS_LIST-ERFMG = COND #( WHEN PS_LIST-STATUS = ICON_LED_YELLOW THEN 0 ELSE LV_ERFMG ).
          PS_LIST-REMAIN_QTY = LV_MENGE  - LV_ERFMG. "오더잔량(입고허용수량)=계산식-자재문서입고총수량합
        ENDIF.
      ENDIF.
*3.미완료 기준 조회조건일 경우에만.납품완료 지시자 'X'여도 입고허용수량 체크 한 번 더 해줌.
      IF P_NFN = GC_X AND PS_LIST-ELIKZ = GC_X. "ELIKZ = GC_X이면, 원래 '납품완료'상태임.
*입고허용수량>입고총수량->미완료&오더수량으로 설정..
        IF LV_MENGE > PS_LIST-ERFMG.
          PS_LIST-STATUS = ICON_LED_YELLOW.
          PS_LIST-ERFMG  = COND #( WHEN PS_LIST-MBLNR IS INITIAL THEN PS_LIST-MENGE ELSE '' ).
          PS_LIST-REMAIN_QTY = LV_MENGE - LV_ERFMG. "오더잔량(입고허용수량)
        ELSE.
          PS_LIST-STATUS = ICON_LED_GREEN. "완료
        ENDIF.
      ENDIF.

    WHEN OTHERS.
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& FORM DELETE_ZPPT0001
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
*&      --> LS_LIST
*&---------------------------------------------------------------------*
FORM DELETE_ZPPT0001  TABLES LT_0001
                                            USING    PS_LIST TYPE TY_LIST .

* ★ 수정 2026.08.28_ZGODEV04
*   기존에는 TAGNR을 "라벨 유무/조회모드"별로 역추정(LR_TAGNR)해서 삭제 조건으로 사용했으나,
*   CREATE측(BATCH_CHANGE) fallback 로직이 배치번호 기준으로 바뀌면서 이 추정 로직이
*   실제 생성된 TAGNR 값과 어긋나 삭제가 안 되고 남는(orphan) 문제가 발생할 수 있음.
*   WERKS+AUFNR(PO)+POSNR(품목)+MBLNR(자재문서)+MATNR(자재) 조합은 CREATE 시점에
*   그대로 사용된 값과 100% 동일하게 이 GR/PO품목 건을 특정하므로, TAGNR 추정 없이
*   이 키만으로 삭제 대상을 조회하도록 단순화함.

*꼬리표 삭제를 위한 기존 데이터 가져오기.
  SELECT FROM ZPPT0001
    FIELDS *
    WHERE WERKS = @PS_LIST-WERKS
         AND AUFNR = @PS_LIST-EBELN
         AND POSNR = @PS_LIST-EBELP
         AND MBLNR = @PS_LIST-MBLNR
         AND MATNR = @PS_LIST-MATNR
    APPENDING TABLE @LT_0001.

ENDFORM.
*&---------------------------------------------------------------------*
*& FORM GET_VC_VALUE
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
*&      --> GT_LIST_S
*&      <-- LT_VCQTY
*&---------------------------------------------------------------------*
FORM GET_VC_VALUE  USING    PT_LIST TYPE TY_T_LIST
                   CHANGING CT_VCQTY TYPE TY_T_VC.

*##ITAB_KEY_IN_SELECT
*  SELECT *
*    FROM ZGTMM_CV_PO_VCVALUE_MAIN AS A
*    WHERE EXISTS ( SELECT @ABAP_TRUE
*                                FROM @PT_LIST AS ZZ
*                              WHERE ZZ~EBELN EQ A~PDOC
*                                   AND ZZ~EBELP EQ A~PDOCITEM  )
*               INTO CORRESPONDING FIELDS OF TABLE @CT_VCQTY.
*
*    SORT CT_VCQTY BY PDOC PDOCITEM .

  ##ITAB_KEY_IN_SELECT
  SELECT MC~MATNR, MC~WERKS, MC~DPCBT,
               VC~PDOC,
               VC~PDOCITEM,
               VC~LENGTH,
               VC~DRQTY,
               VC~COLOR ,
               VC~DRUM
    FROM MARC AS MC
    INNER JOIN ZGTMM_CV_PO_VCVALUE_MAIN AS VC
    ON MC~MATNR EQ VC~MATNR
    WHERE EXISTS (
        SELECT @ABAP_TRUE
           FROM @PT_LIST AS ZZ
           WHERE ZZ~MATNR EQ MC~MATNR
                AND ZZ~WERKS EQ MC~WERKS
                AND ZZ~EBELN EQ VC~PDOC
                AND ZZ~EBELP EQ VC~PDOCITEM
               )
*    AND MC~DPCBT = 'A'
    INTO CORRESPONDING FIELDS OF TABLE @CT_VCQTY.

  SORT CT_VCQTY BY PDOC PDOCITEM DPCBT.

ENDFORM.
*&---------------------------------------------------------------------*
*& FORM SET_DRLABEL_GR
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
*&      --> LT_RESB
*&      --> LT_DELCOMP
*&      --> LT_MSLB
*&      --> LT_ZGTMMT9450
*&---------------------------------------------------------------------*
FORM SET_DRLABEL_GR  USING  PT_RESB TYPE TY_T_PO_RESB
                                                  PT_DELCOMP TYPE TY_T_PO_DELCOMP
                                                  PT_MSLB TYPE TY_T_MSLB
                                                  PT_ZGTMMT9450 TYPE TY_T_ZGTMMT9450
                                                  PT_VCQTY TYPE TY_T_VC.

  DATA :
    LT_LIST   LIKE TABLE OF GS_LIST,
    LS_HEAD   TYPE BAPI2017_GM_HEAD_01,
    LT_ITEM   TYPE TABLE OF BAPI2017_GM_ITEM_CREATE,
    LV_CODE   TYPE BAPI2017_GM_CODE-GM_CODE,
    LV_DOC    TYPE BAPI2017_GM_HEAD_RET-MAT_DOC,
    LS_BATCH  TYPE BAPIBATCHATT,
    LS_BATCHX TYPE BAPIBATCHATTX,
    LV_MSG    TYPE BAPI_MSG.

  DATA :
    LV_CHECK      TYPE C LENGTH 1,
    LT_ZGTMMT9415 TYPE TABLE OF ZGTMMT9415.

  CLEAR : LV_MSG, GV_ERR.
  SORT GT_LIST BY EBELN EBELP DR_LABELNO.
  SORT GT_LIST_S BY EBELN EBELP DR_LABELNO.

***-입고처리BAPI SET
*GMCODE
  LV_CODE = '01'. "입고
  CLEAR GT_RETURN.

*TIME STAMP_입고성공 후 OEM DRLABEL NO  업데이트 시 필요한 정보.
  GET TIME STAMP FIELD DATA(LV_ZIFKEY).

  LOOP AT GT_LIST_S ASSIGNING FIELD-SYMBOL(<G1>)
            GROUP BY ( EBELN = <G1>-EBELN ) ASSIGNING FIELD-SYMBOL(<LS_GR1>).
*BAPI HEADER
    CLEAR : LS_HEAD, LT_ITEM.
    LS_HEAD = VALUE #( PSTNG_DATE  = GV_BUDAT
                                     DOC_DATE     = GV_BUDAT
                                     PR_UNAME     = SY-UNAME ).
*BAPI ITEM
    LOOP AT GROUP <LS_GR1> ASSIGNING FIELD-SYMBOL(<LS_ITEM>).

      PERFORM SET_GOODSMVT_ITEM_OEMDRLB
            USING PT_RESB PT_DELCOMP PT_MSLB PT_ZGTMMT9450  PT_VCQTY
      CHANGING LT_ITEM LV_CHECK <LS_ITEM>.

    ENDLOOP.

    IF LV_CHECK EQ GC_E.
      GT_RETURN = VALUE #( ( TYPE = GC_E MESSAGE = TEXT-E14 ) ). "투입 자재 정보를 확인하세요.
    ELSE.
*--BAPI 실행
      CALL FUNCTION 'BAPI_GOODSMVT_CREATE'
        EXPORTING
          GOODSMVT_HEADER  = LS_HEAD
          GOODSMVT_CODE    = LV_CODE
        IMPORTING
          MATERIALDOCUMENT = LV_DOC
        TABLES
          GOODSMVT_ITEM    = LT_ITEM
          RETURN           = GT_RETURN.
    ENDIF.

    READ TABLE GT_RETURN ASSIGNING FIELD-SYMBOL(<LS_RT>) WITH KEY TYPE = GC_E.
    IF SY-SUBRC EQ 0.
*오류
      CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

      LOOP AT GROUP <LS_GR1> ASSIGNING FIELD-SYMBOL(<ROLL>).
        READ TABLE GT_LIST ASSIGNING FIELD-SYMBOL(<MAIN>)
        WITH KEY EBELN = <ROLL>-EBELN
                       EBELP = <ROLL>-EBELP BINARY SEARCH.
        IF SY-SUBRC = 0.
          DATA(LV_TABIX) = SY-TABIX.
          <MAIN>-STATUS    = ICON_LED_RED.
          <MAIN>-MESSAGE = <LS_RT>-MESSAGE.
          MODIFY GT_LIST FROM <MAIN> INDEX LV_TABIX.
        ENDIF.
      ENDLOOP.

    ELSE.
*성공
      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
        EXPORTING
          WAIT = ABAP_TRUE.

      LOOP AT GROUP <LS_GR1> ASSIGNING FIELD-SYMBOL(<COM>).
*ALV UPDATE
        READ TABLE GT_LIST ASSIGNING FIELD-SYMBOL(<DLB>)
        WITH KEY EBELN = <COM>-EBELN
                       EBELP = <COM>-EBELP
                       DR_LABELNO = <COM>-DR_LABELNO BINARY SEARCH.
        IF SY-SUBRC = 0.
          <DLB>-STATUS = ICON_LED_GREEN.
          <DLB>-MBLNR =  LV_DOC .
          <DLB>-GRBUDAT = GV_BUDAT.
          <DLB>-BUDAT     = COND #( WHEN P_LNO = GC_X THEN GV_BUDAT ELSE <DLB>-BUDAT ).
          <DLB>-MESSAGE = '입고 처리 완료'(M14).
          CLEAR <DLB>-EDIT.
          MODIFY GT_LIST FROM <DLB> INDEX SY-TABIX.
*배치자재인 경우(MARC-XCHPF=X) 배치마스터 제조일자 업데이트
*->배치마스터 업데이트 성공 시, 자재문서 기준 꼬리표번호 테이블 업데이트(ZPPT0001)
          IF <DLB>-XCHPF = GC_X .
            PERFORM BATCH_CHANGE TABLES PT_VCQTY USING <DLB> <COM>.
          ENDIF.
        ENDIF.
*ZGTMMT9415 UPDATE SET_OEM 드럼라벨 조회
        APPEND VALUE #( ZIFKEY = LV_ZIFKEY
                              SYSTEM_ID = GC_KSRM
                                    EBELN  = <DLB>-EBELN
                                    EBELP  = <DLB>-EBELP
                          DR_LABELNO  = <DLB>-DR_LABELNO
                                    MBLNR = LV_DOC
                                     MJAHR = GV_BUDAT(4)
                                       ) TO LT_ZGTMMT9415.
      ENDLOOP.

    ENDIF.
  ENDLOOP.

  IF GT_ZPPT0001[] IS NOT INITIAL.
    MODIFY ZPPT0001 FROM TABLE GT_ZPPT0001.
    COMMIT WORK.
    CLEAR : GT_ZPPT0001.
  ENDIF.

  IF LT_ZGTMMT9415[] IS NOT INITIAL.
    MODIFY ZGTMMT9415 FROM TABLE LT_ZGTMMT9415.
    COMMIT WORK.
  ENDIF.


ENDFORM.
*&---------------------------------------------------------------------*
*& FORM SELECT_DISP_DATA
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
*& -->  P1        TEXT
*& <--  P2        TEXT
*&---------------------------------------------------------------------*
FORM SELECT_DISP_DATA .
  DATA : LT_LIST    LIKE TABLE OF GS_LIST,
         LT_PO_LIST LIKE TABLE OF GS_LIST,
         LT_MAT     TYPE STANDARD TABLE OF TY_MAT.


****표준거래명세서
  SELECT DISTINCT
    A~DELNO, A~DELITEM, A~BUDAT, A~MENGE,
    A~MEINS, A~WERKS, A~LGORT,
    A~HSDAT, A~LICHA,
    Z~EBELN, Z~EBELP, Z~DELCLOSE, Z~DOC_URL,

    CASE WHEN Z~DOC_URL IS INITIAL THEN NULL
             ELSE '조회' END AS DOC_TXT,

    CASE WHEN Z~EBELN = B~EBELN  AND Z~EBELP = B~EBELP
                AND Z~DELNO = A~DELNO AND Z~DELITEM = A~DELITEM
              THEN A~MBLNR  ELSE NULL END AS MBLNR,

    B~ELIKZ,  B~PSTYP, B~VBELN, B~POSNR,
    C~DPCBT, C~XCHPF, "배치대상자재여부
    H~LIFNR, H~NAME1,
    P~MATNR, P~TXZ01, P~INSMK,
    R~MTART, R~MATKL,
    W~NAME1 AS WERKS_N,
    L~LGOBE AS LGORT_N

    FROM ZGTMM_CV_GET_GODELIVERY_DATA AS A

    INNER JOIN ZGTMMT9410 AS Z
                ON A~DELNO = Z~DELNO
              AND A~DELITEM = Z~DELITEM
              AND A~EBELN = Z~EBELN
              AND A~EBELP = Z~EBELP
    INNER JOIN ZGTMM_CV_GET_PODATA_H AS H
                ON A~EBELN = H~EBELN
    INNER JOIN ZGTMM_CV_GET_PODATA_RAW AS B
                ON B~EBELN = A~EBELN
               AND B~EBELP = A~EBELP
    INNER JOIN EKKO AS K
                ON K~EBELN = A~EBELN
    INNER JOIN EKPO AS P
                ON P~EBELN = A~EBELN
              AND P~EBELP = A~EBELP
    INNER JOIN MARC AS C
                ON C~WERKS = B~WERKS
               AND C~MATNR = B~MATNR
    INNER JOIN MARA AS R
                ON R~MATNR = B~MATNR
    LEFT OUTER JOIN T001W AS W
                ON W~WERKS = A~WERKS
    LEFT OUTER JOIN T001L AS L
                ON L~WERKS = A~WERKS
               AND L~LGORT = A~LGORT

    WHERE A~WERKS = @P_WERKS
         AND K~EKGRP IN @S_EKGRP
         AND P~MATNR IN @S_MATNR
         AND A~BUDAT IN @S_DATE"S_BUDAT   "납품예정일_기준일자로 대체
         AND H~BUKRS = @P_BUKRS
         AND A~DELNO IN @S_DELNO   "납품문서번호
         AND H~LIFNR IN @S_LIFNR
         AND A~EBELN IN @S_EBELN
         AND B~VBELN IN @S_VBELN
         AND A~STATUS IS INITIAL
*ZGTMMT9415_OEM 드럼라벨 정보 이력 테이블에 존재하는 구매오더는 제외
*         AND ""배치유형 'C'인 자재만 제외 되도록..->260729_모두 조회되게 조건 주석..
*         NOT EXISTS ( SELECT ZZ~EBELN, ZZ~EBELP
*                                 FROM ZGTMMT9415 AS ZZ
*                               WHERE A~EBELN = ZZ~EBELN
*                                    AND A~EBELP = ZZ~EBELP
*                                    AND C~DPCBT = 'C'
*                                    AND ZZ~STATUS = '' )

    INTO CORRESPONDING FIELDS OF TABLE @LT_LIST.

  IF LT_LIST[] IS NOT INITIAL.
*STATUS 빈값인 데이터 가져오지만, 같은 납품번호로 STATUS = X인 정보도 별도 체크
    SELECT FROM ZGTMM_CV_GET_GODELIVERY_DATA
      FIELDS *
      FOR ALL ENTRIES IN @LT_LIST
      WHERE DELNO = @LT_LIST-DELNO
           AND DELITEM = @LT_LIST-DELITEM
           AND STATUS = @GC_X
      INTO TABLE @GT_DELI_X.
    SORT GT_DELI_X BY DELNO DELITEM.
*라벨정보(배치자재)_납품수량 설정용
    SELECT FROM ZGTMMT9411
      FIELDS *
      FOR ALL ENTRIES IN @LT_LIST
      WHERE SYSTEM_ID = @GC_KSRM
           AND DELNO = @LT_LIST-DELNO
           AND DELITEM = @LT_LIST-DELITEM
      INTO CORRESPONDING FIELDS OF TABLE @GT_9411.
    SORT GT_9411 BY DELNO DELITEM LABELNO LABELITEM.
*직송 납품서 대상여부 점검
    SELECT FROM ZGTMMT4403
      FIELDS *
      FOR ALL ENTRIES IN @LT_LIST
      WHERE DELNO = @LT_LIST-DELNO
           AND DELITEM = @LT_LIST-DELITEM
      INTO TABLE @GT_4403.
    SORT GT_4403 BY DELNO DELITEM.
*자재문서 정보
    SELECT FROM ZGTMM_CV_GET_MATDOC AS Z
         INNER JOIN MATDOC AS M
                   ON M~MBLNR EQ Z~MBLNR
                 AND M~ZEILE EQ Z~ZEILE
                 AND M~EBELN EQ Z~EBELN
                 AND M~EBELP EQ Z~EBELP

          FIELDS Z~MJAHR, Z~EBELN, Z~EBELP, Z~DELNO, Z~DELITEM,
                     Z~MBLNR, Z~ZEILE, Z~ERFMG,
                     Z~BUDAT, Z~MATNR,
                     Z~CANCELLED, Z~REVERSAL_MOVEMENT,
                     M~BWART

         FOR ALL ENTRIES IN @LT_LIST
         WHERE Z~EBELN = @LT_LIST-EBELN
              AND Z~EBELP = @LT_LIST-EBELP
              AND Z~MJAHR = @SY-DATLO(4)
              AND Z~CANCELLED = ''
              AND Z~REVERSAL_MOVEMENT = ''
         INTO CORRESPONDING FIELDS OF TABLE @LT_MAT.

    SORT LT_MAT BY EBELN EBELP DELNO DELITEM ASCENDING MBLNR DESCENDING ZEILE.

    LOOP AT LT_LIST ASSIGNING FIELD-SYMBOL(<LIST>).
*          "동일한 납품문서 있으면, 대상 제외.
      READ TABLE GT_4403 INTO DATA(LS_4403)
      WITH KEY DELNO = <LIST>-DELNO
                     DELITEM = <LIST>-DELITEM BINARY SEARCH.
      IF SY-SUBRC = 0.
        CONTINUE.
      ENDIF.
*          "동일한 납품문서로 STATUS='X'인 데이터도 있으면, 대상 제외.
      READ TABLE GT_DELI_X INTO DATA(LS_X)
      WITH KEY DELNO = <LIST>-DELNO
                     DELITEM = <LIST>-DELITEM BINARY SEARCH.
      IF SY-SUBRC = 0.
        CONTINUE.
      ENDIF.

****상태 필드 설정 및 데이터 GATHERING
      PERFORM SET_STATUS_DATA_DISP USING GC_D LT_MAT CHANGING <LIST>.
      CHECK GV_ERR IS INITIAL.

      APPEND <LIST> TO GT_LIST.
    ENDLOOP.

  ENDIF.


*****수기거래명세서(구매오더)
  SELECT DISTINCT
    A~EBELN, A~LIFNR, A~NAME1, A~EKGRP,
    P~EBELP, P~MATNR, P~TXZ01, P~INSMK,
    B~WERKS, B~LGORT, B~MENGE, B~MEINS,
    B~ELIKZ, B~LOEKZ, B~UEBTO, B~RETPO,
    B~PSTYP, B~PTEXT, B~KNTTP, B~KNTTX,
    B~VBELN, B~POSNR, B~NETWR AS POAMT,
    B~WAERS,
    E~SAKTO, E~KOSTL, E~AUFNR, E~ANLN1,
    E~PS_PSP_PNR,
    C~DPCBT, C~XCHPF, "배치대상자재여부
    R~MTART, R~MATKL,
    S~TXT20 AS GTEXT,  "G/L계정내역
    T~KTEXT,  "코스트센터내역
    AN~TXT50, "자산명
    PR~POST1,  "WBS명
    W~NAME1 AS WERKS_N,
    L~LGOBE AS LGORT_N

    FROM ZGTMM_CV_GET_PODATA_H AS A
    INNER JOIN  ZGTMM_CV_GET_PODATA_RAW AS B
                ON B~EBELN = A~EBELN
    INNER JOIN EKPO AS P
                ON P~EBELN = B~EBELN
               AND P~EBELP = B~EBELP
    LEFT OUTER JOIN MARC AS C
                ON C~WERKS = B~WERKS
               AND C~MATNR = P~MATNR
    LEFT OUTER JOIN MARA AS R
                ON R~MATNR = P~MATNR
    LEFT OUTER JOIN EKKN AS E
                ON E~EBELN = B~EBELN
               AND E~EBELP = B~EBELP
    LEFT OUTER JOIN SKAT AS S
                ON S~SAKNR = E~SAKTO
    LEFT OUTER JOIN CSKT AS T
                ON T~KOSTL = E~KOSTL
               AND T~SPRAS = @GC_3
               AND T~KOKRS = @P_BUKRS
    LEFT OUTER JOIN ANLT AS AN
                ON AN~ANLN1 = E~ANLN1
               AND AN~BUKRS = @P_BUKRS
               AND AN~SPRAS = @GC_3
    LEFT OUTER JOIN PRPS AS PR
                ON PR~PSPNR = E~PS_PSP_PNR
    LEFT OUTER JOIN T001W AS W
                ON W~WERKS = B~WERKS
    LEFT OUTER JOIN T001L AS L
                ON L~WERKS = B~WERKS
               AND L~LGORT = B~LGORT

    WHERE A~BUKRS = @P_BUKRS
         AND A~AEDAT IN @S_DATE"S_AEDAT  "구매오더생성일_기준일자로 대체
         AND A~EKGRP IN @S_EKGRP
         AND B~WERKS = @P_WERKS
         AND A~EBELN IN @S_EBELN
         AND A~LIFNR  IN @S_LIFNR
         AND P~MATNR IN @S_MATNR
         AND B~VBELN IN @S_VBELN
         AND B~LOEKZ IS INITIAL
    INTO CORRESPONDING FIELDS OF TABLE @LT_PO_LIST.

  IF LT_PO_LIST[] IS NOT INITIAL.
*  "납품 문서 정보 이력 점검
    SELECT FROM ZGTMMT9410
    FIELDS *
    WHERE WERKS = @P_WERKS
         AND DELCLOSE IS INITIAL
         INTO TABLE @GT_9410.
    SORT GT_9410 BY EBELN EBELP.
*  "OEM 드럼라벨 이력 점검
    SELECT FROM ZGTMMT9415
    FIELDS *
    FOR ALL ENTRIES IN @LT_PO_LIST
    WHERE EBELN = @LT_PO_LIST-EBELN
        AND EBELP = @LT_PO_LIST-EBELP
        INTO TABLE @GT_9415.
    SORT GT_9415 BY EBELN EBELP.
*자재문서 정보
    CLEAR LT_MAT.
    SELECT FROM ZGTMM_CV_GET_MATDOC AS Z
         INNER JOIN MATDOC AS M
                   ON M~MBLNR EQ Z~MBLNR
                 AND M~ZEILE EQ Z~ZEILE
                 AND M~EBELN EQ Z~EBELN
                 AND M~EBELP EQ Z~EBELP

          FIELDS Z~MJAHR, Z~EBELN, Z~EBELP, Z~DELNO, Z~DELITEM,
                     Z~MBLNR, Z~ZEILE, Z~ERFMG,
                     Z~BUDAT, Z~MATNR,
                     Z~CANCELLED, Z~REVERSAL_MOVEMENT,
                     M~BWART

         FOR ALL ENTRIES IN @LT_PO_LIST
         WHERE Z~EBELN = @LT_PO_LIST-EBELN
              AND Z~EBELP = @LT_PO_LIST-EBELP
              AND Z~MJAHR = @SY-DATLO(4)
              AND Z~CANCELLED = ''
              AND Z~REVERSAL_MOVEMENT = ''
         INTO CORRESPONDING FIELDS OF TABLE @LT_MAT.

    SORT LT_MAT BY EBELN EBELP DELNO DELITEM ASCENDING MBLNR DESCENDING ZEILE.

    LOOP AT LT_PO_LIST ASSIGNING FIELD-SYMBOL(<PO>).
**ZGTMMT9410(납품문서이력)에 존재하면, 입고 미대상->삭제
      READ TABLE GT_9410 TRANSPORTING NO FIELDS
      WITH KEY EBELN = <PO>-EBELN
                     EBELP = <PO>-EBELP BINARY SEARCH.
      IF SY-SUBRC = 0.
        CONTINUE.
      ENDIF.
**ZGTMMT9415(OEM드럼라벨이력)에 존재하면, 입고 미대상->삭제
      READ TABLE GT_9415 TRANSPORTING NO FIELDS
      WITH KEY EBELN = <PO>-EBELN
                     EBELP = <PO>-EBELP BINARY SEARCH.
      IF SY-SUBRC = 0.
        CONTINUE.
      ENDIF.

****상태 필드 설정 및 데이터 GATHERING
      PERFORM SET_STATUS_DATA_DISP USING GC_P LT_MAT CHANGING <PO>.
      CHECK GV_ERR IS INITIAL.

      APPEND <PO> TO GT_LIST.
    ENDLOOP.

  ENDIF.


ENDFORM.
