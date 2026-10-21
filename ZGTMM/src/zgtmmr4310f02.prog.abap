*&---------------------------------------------------------------------*
*& Include          ZGTMMR4310F02
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*& Form F_CREATE_ALV_OBJECT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_CREATE_ALV_OBJECT .

  DATA:
    LO_SPLIT  TYPE REF TO CL_GUI_SPLITTER_CONTAINER,
    LO_CNTR_T TYPE REF TO CL_GUI_CONTAINER,
    LO_CNTR_M TYPE REF TO CL_GUI_CONTAINER,
    LO_CNTR_B TYPE REF TO CL_GUI_CONTAINER.

  GO_CONT = NEW #( CONTAINER_NAME = 'CON100' ).

  "Split Container
  LO_SPLIT = NEW #( PARENT  = GO_CONT
                    ROWS    = 3
                    COLUMNS = 1 ).

  LO_CNTR_T = LO_SPLIT->GET_CONTAINER( ROW = 1 COLUMN = 1 ).
  LO_CNTR_M = LO_SPLIT->GET_CONTAINER( ROW = 2 COLUMN = 1 ).
  LO_CNTR_B = LO_SPLIT->GET_CONTAINER( ROW = 3 COLUMN = 1 ).

  "ALV Obj.
  GO_GRID_TOP = NEW #( I_PARENT = LO_CNTR_T ).
  GO_GRID_MID = NEW #( I_PARENT = LO_CNTR_M ).
  GO_GRID_BOT = NEW #( I_PARENT = LO_CNTR_B ).

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_SET_EXCL
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_SET_EXCL .

  CLEAR:
   GT_EXCL_TOP[],
   GT_EXCL_MID[],
   GT_EXCL_BOT[].

  GT_EXCL_TOP[] = GT_EXCL_MID[] = GT_EXCL_BOT[] = VALUE #( ( CL_GUI_ALV_GRID=>MC_FC_LOC_UNDO  )
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
*& Form F_SET_LAYO
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_SET_LAYO .

  CLEAR:
    GS_LAYO_TOP,
    GS_LAYO_MID,
    GS_LAYO_BOT.

  GS_LAYO_TOP-SEL_MODE   = GC_D.
  GS_LAYO_TOP-CWIDTH_OPT = ABAP_TRUE.
  GS_LAYO_TOP-ZEBRA      = ABAP_TRUE.
  GS_LAYO_TOP-SMALLTITLE = ABAP_TRUE.

  GS_LAYO_BOT = GS_LAYO_MID = GS_LAYO_TOP.

  GS_LAYO_TOP-GRID_TITLE = TEXT-TT1. "납품 문서 정보
  GS_LAYO_MID-GRID_TITLE = TEXT-TT3. "라벨 정보
  GS_LAYO_BOT-GRID_TITLE = TEXT-TT2. "하위자재 투입 정보


ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_SET_VARI
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_SET_VARI .

  CLEAR:
    GS_VARI_TOP,
    GS_VARI_MID,
    GS_VARI_BOT.

  GS_VARI_TOP-REPORT = SY-REPID.
  GS_VARI_TOP-USERNAME = SY-UNAME.

  GS_VARI_BOT = GS_VARI_MID = GS_VARI_TOP.

  GS_VARI_TOP-HANDLE = 'HD01'.
  GS_VARI_MID-HANDLE = 'HD02'.
  GS_VARI_BOT-HANDLE = 'HD03'.


ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_CREATE_FCAT_BY_ITAB
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PT_ITAB
*&      <-- PT_FCAT
*&---------------------------------------------------------------------*
FORM F_CREATE_FCAT_BY_ITAB  USING    PT_ITAB TYPE ANY TABLE
                            CHANGING PT_FCAT TYPE LVC_T_FCAT.

  DATA :
    LO_TABDESCR  TYPE REF TO CL_ABAP_TABLEDESCR,
    LO_STRUDESCR TYPE REF TO CL_ABAP_STRUCTDESCR.

  LO_TABDESCR ?= CL_ABAP_TABLEDESCR=>DESCRIBE_BY_DATA( PT_ITAB ).
  LO_STRUDESCR ?= LO_TABDESCR->GET_TABLE_LINE_TYPE( ).

  PT_FCAT[] = CORRESPONDING #( CL_SALV_DATA_DESCR=>READ_STRUCTDESCR( LO_STRUDESCR )
                                 MAPPING
                                   KEY = KEYFLAG
                                   COLTEXT   = FIELDTEXT
                            EXCEPT ROLLNAME ).

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_SET_FCAT_COLTXT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> TEXT_H01
*&      <-- <LS_FCAT>
*&---------------------------------------------------------------------*
FORM F_SET_FCAT_COLTXT  USING  PV_TEXT
                        CHANGING CS_FCAT TYPE LVC_S_FCAT.

  CS_FCAT-SCRTEXT_S  =
  CS_FCAT-SCRTEXT_M  =
  CS_FCAT-SCRTEXT_L  =
  CS_FCAT-COLTEXT    =
  CS_FCAT-SELTEXT    =
  CS_FCAT-TOOLTIP    =
  CS_FCAT-REPTEXT    = PV_TEXT.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_SET_FCAT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_SET_FCAT .

  PERFORM F_CREATE_FCAT_BY_ITAB USING GT_TOP CHANGING GT_FCAT_TOP.
  PERFORM F_CREATE_FCAT_BY_ITAB USING GT_MID CHANGING GT_FCAT_MID.
  PERFORM F_CREATE_FCAT_BY_ITAB USING GT_BOT CHANGING GT_FCAT_BOT.

  PERFORM F_ADJ_FCAT_TOP.
  PERFORM F_ADJ_FCAT_MID.
  PERFORM F_ADJ_FCAT_BOT.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_SET_ALV_EVENT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_SET_ALV_EVENT .

  CREATE OBJECT GO_EVENT.
  SET HANDLER GO_EVENT->HANDLE_HOTSPOT_CLICK FOR GO_GRID_TOP.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_SET_ALV_SORT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_SET_ALV_SORT .

  CLEAR:
    GT_SORT_TOP[],
    GT_SORT_MID[],
    GT_SORT_BOT[].
*GT_DATA01 : WERKS, DELNO, DELITEM 기준 오름차순
*GT_DATA02 : WERKS, DELNO, DELITEM 기준 오름차순
*GT_DATA03 : WERKS, DELNO, DELITEM 기준 오름차순
  GT_SORT_TOP = VALUE #( BASE GT_SORT_TOP ( SPOS = 1 FIELDNAME = 'WERKS' UP = ABAP_TRUE DOWN = SPACE ) ).
  GT_SORT_TOP = VALUE #( BASE GT_SORT_TOP ( SPOS = 2 FIELDNAME = 'DELNO' UP = ABAP_TRUE DOWN = SPACE ) ).
  GT_SORT_TOP = VALUE #( BASE GT_SORT_TOP ( SPOS = 2 FIELDNAME = 'DELITEM' UP = ABAP_TRUE DOWN = SPACE ) ).

  GT_SORT_BOT[] = GT_SORT_MID[] = GT_SORT_TOP[].
ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_DISPLAY_ALV
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_DISPLAY_ALV .

  CALL METHOD GO_GRID_TOP->SET_TABLE_FOR_FIRST_DISPLAY
    EXPORTING
      IS_LAYOUT            = GS_LAYO_TOP
      IT_TOOLBAR_EXCLUDING = GT_EXCL_TOP[]
      IS_VARIANT           = GS_VARI_TOP
      I_SAVE               = GV_ASAVE_TOP
    CHANGING
      IT_OUTTAB            = GT_TOP[]
      IT_FIELDCATALOG      = GT_FCAT_TOP[]
      IT_SORT              = GT_SORT_TOP[]
    EXCEPTIONS
      OTHERS               = 4.

  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
          WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

  CALL METHOD GO_GRID_MID->SET_TABLE_FOR_FIRST_DISPLAY
    EXPORTING
      IS_LAYOUT            = GS_LAYO_MID
      IT_TOOLBAR_EXCLUDING = GT_EXCL_MID[]
      IS_VARIANT           = GS_VARI_MID
      I_SAVE               = GV_ASAVE_MID
    CHANGING
      IT_OUTTAB            = GT_MID[]
      IT_FIELDCATALOG      = GT_FCAT_MID[]
      IT_SORT              = GT_SORT_MID[]
    EXCEPTIONS
      OTHERS               = 4.

  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
          WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

  CALL METHOD GO_GRID_BOT->SET_TABLE_FOR_FIRST_DISPLAY
    EXPORTING
      IS_LAYOUT            = GS_LAYO_BOT
      IT_TOOLBAR_EXCLUDING = GT_EXCL_BOT[]
      IS_VARIANT           = GS_VARI_BOT
      I_SAVE               = GV_ASAVE_BOT
    CHANGING
      IT_OUTTAB            = GT_BOT[]
      IT_FIELDCATALOG      = GT_FCAT_BOT[]
      IT_SORT              = GT_SORT_BOT[]
    EXCEPTIONS
      OTHERS               = 4.

  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
          WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_REFRESH_ALV
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GO_GRID
*&---------------------------------------------------------------------*
FORM F_REFRESH_ALV  USING PO_GRID TYPE REF TO CL_GUI_ALV_GRID.

  DATA LS_STABLE TYPE LVC_S_STBL.
  LS_STABLE-ROW = ABAP_TRUE.
  LS_STABLE-COL = ABAP_TRUE.

  CALL METHOD PO_GRID->REFRESH_TABLE_DISPLAY
    EXPORTING
      IS_STABLE = LS_STABLE
    EXCEPTIONS
      FINISHED  = 1
      OTHERS    = 2.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_ADJ_FCAT_TOP
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_ADJ_FCAT_TOP .

  LOOP AT GT_FCAT_TOP ASSIGNING FIELD-SYMBOL(<LS_FCAT>).
    CASE <LS_FCAT>-FIELDNAME.
      WHEN 'ZIFNO'. ""I/F No
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H01 CHANGING <LS_FCAT>."
      WHEN 'ZIFKEY'. ""Interface Key
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H02 CHANGING <LS_FCAT>."
      WHEN 'SYSTEM_ID'. ""I/F 시스템
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H03 CHANGING <LS_FCAT>."
      WHEN 'FLD_02'. ""시스템 명
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H04 CHANGING <LS_FCAT>."
      WHEN 'ZSTAT'. ""송수신상태
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H05 CHANGING <LS_FCAT>."
      WHEN 'MESSAGE'. ""송수신메세지
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H06 CHANGING <LS_FCAT>."
      WHEN 'IFNAM'. ""송수신자
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H07 CHANGING <LS_FCAT>."
      WHEN 'DELNO'. ""납품문서번호
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H08 CHANGING <LS_FCAT>."
        <LS_FCAT>-HOTSPOT = ABAP_TRUE.
      WHEN 'DELITEM'. ""납품문서품목번호
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H09 CHANGING <LS_FCAT>."
      WHEN 'EBELN'. ""구매오더번호
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H10 CHANGING <LS_FCAT>."
      WHEN 'EBELP'. ""구매오더품목번호
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H11 CHANGING <LS_FCAT>."
      WHEN 'LIFNR'. ""공급업체번호
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H12 CHANGING <LS_FCAT>."
      WHEN 'WERKS'. ""플랜트
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H13 CHANGING <LS_FCAT>."
      WHEN 'LGORT'. ""저장위치
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H14 CHANGING <LS_FCAT>."
      WHEN 'MATNR'. ""자재번호
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H15 CHANGING <LS_FCAT>."
      WHEN 'ZZMAKTX80'. ""자재내역
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H16 CHANGING <LS_FCAT>."
      WHEN 'MENGE'. ""수량
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H17 CHANGING <LS_FCAT>."
        <LS_FCAT>-QFIELDNAME = 'MEINS'.
      WHEN 'MEINS'. ""단위
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H18 CHANGING <LS_FCAT>."
      WHEN 'BUDAT'. ""전기일자
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H19 CHANGING <LS_FCAT>."
      WHEN 'EMLIF'. ""직납업체
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H20 CHANGING <LS_FCAT>."
      WHEN 'LICHA'. ""공급업체 배치번호
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H21 CHANGING <LS_FCAT>."
      WHEN 'HSDAT'. ""제조일
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H22 CHANGING <LS_FCAT>."
      WHEN 'STATUS'. ""납품문서 상태
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H23 CHANGING <LS_FCAT>."
      WHEN 'POTYPE'. ""PO 유형
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H36 CHANGING <LS_FCAT>."

      WHEN OTHERS.
        <LS_FCAT>-TECH = ABAP_TRUE.
    ENDCASE.

    CASE <LS_FCAT>-FIELDNAME.
      WHEN 'ZIFNO' OR 'ZIFKEY' OR 'SYSTEM_ID' OR 'FLD_02' OR 'ZSTAT' OR'MESSAGE' OR 'IFNAM'.
        <LS_FCAT>-TECH = P_SEND.
    ENDCASE.

  ENDLOOP.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_ADJ_FCAT_MID
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_ADJ_FCAT_MID .

  LOOP AT GT_FCAT_MID ASSIGNING FIELD-SYMBOL(<LS_FCAT>).
    CASE <LS_FCAT>-FIELDNAME.
      WHEN 'DELNO'. ""납품문서번호
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H08 CHANGING <LS_FCAT>."
      WHEN 'DELITEM'. ""납품문서품목번호
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H09 CHANGING <LS_FCAT>."
      WHEN 'LABELNO'. ""라벨번호
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H24 CHANGING <LS_FCAT>."
      WHEN 'LABELITEM'. ""라벨항번
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H25 CHANGING <LS_FCAT>."
      WHEN 'WERKS'. ""플랜트
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H13 CHANGING <LS_FCAT>."
      WHEN 'EBELN'. ""구매오더번호
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H10 CHANGING <LS_FCAT>."
      WHEN 'EBELP'. ""구매오더품목번호
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H11 CHANGING <LS_FCAT>."
      WHEN 'LGORT'. ""저장위치
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H14 CHANGING <LS_FCAT>."
      WHEN 'MENGE'. ""적입수량
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H26 CHANGING <LS_FCAT>."
        <LS_FCAT>-QFIELDNAME = 'MEINS'.
      WHEN 'MEINS'. ""적입단위
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H27 CHANGING <LS_FCAT>."
      WHEN 'PKG_QTY'. ""포장수량
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H28 CHANGING <LS_FCAT>."
        <LS_FCAT>-QFIELDNAME = 'PKG_UNIT'.
      WHEN 'PKG_UNIT'. ""포장단위
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H29 CHANGING <LS_FCAT>."
      WHEN OTHERS.
        <LS_FCAT>-TECH = ABAP_TRUE.
    ENDCASE.
  ENDLOOP.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_ADJ_FCAT_BOT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_ADJ_FCAT_BOT .

  LOOP AT GT_FCAT_BOT ASSIGNING FIELD-SYMBOL(<LS_FCAT>).
    CASE <LS_FCAT>-FIELDNAME.
      WHEN 'DELNO'. ""납품문서번호
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H08 CHANGING <LS_FCAT>."
      WHEN 'DELITEM'. ""납품문서품목번호
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H09 CHANGING <LS_FCAT>."
      WHEN 'WERKS'. ""플랜트
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H13 CHANGING <LS_FCAT>."
      WHEN 'LIFNR'. ""공급업체번호
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H12 CHANGING <LS_FCAT>."
      WHEN 'NAME1'. ""공급업체명
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H30 CHANGING <LS_FCAT>."
      WHEN 'IDNRK'. ""하위자재번호
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H31 CHANGING <LS_FCAT>."
      WHEN 'ZZMAKTX80'. ""자재내역
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H16 CHANGING <LS_FCAT>."
      WHEN 'CHARG'. ""배치번호
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H33 CHANGING <LS_FCAT>."
      WHEN 'ISSUE_QTY'. ""투입수량
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H34 CHANGING <LS_FCAT>."
        <LS_FCAT>-QFIELDNAME = 'ISSUE_UNIT'.
      WHEN 'ISSUE_UNIT'. ""투입단위
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H35 CHANGING <LS_FCAT>."
      WHEN 'EBELN'. ""구매오더번호
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H10 CHANGING <LS_FCAT>."
      WHEN 'EBELP'. ""구매오더품목번호
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H11 CHANGING <LS_FCAT>."
      WHEN 'LGORT'. ""저장위치
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H14 CHANGING <LS_FCAT>."
      WHEN OTHERS.
        <LS_FCAT>-TECH = ABAP_TRUE.
    ENDCASE.
  ENDLOOP.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_HOTSPOT_CLICK
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> ES_ROW_NO_ROW_ID
*&      --> E_COLUMN_ID
*&      --> SENDER
*&---------------------------------------------------------------------*
FORM F_HOTSPOT_CLICK  USING PS_ROW_ID TYPE INT4
                                               PS_COLUMN TYPE LVC_S_COL
                                               PO_SENDER.

  CHECK PS_ROW_ID IS NOT INITIAL.

  CASE PS_COLUMN-FIELDNAME.
    WHEN 'DELNO'.
      READ TABLE GT_TOP ASSIGNING FIELD-SYMBOL(<LS_TOP>) INDEX PS_ROW_ID.
      CHECK SY-SUBRC EQ 0.

      PERFORM F_SET_ALV_DATA_MID_BOT USING <LS_TOP>-SYSTEM_ID <LS_TOP>-ZIFKEY <LS_TOP>-DELNO.

      PERFORM F_REFRESH_ALV USING GO_GRID_MID.
      PERFORM F_REFRESH_ALV USING GO_GRID_BOT.

  ENDCASE.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_SET_ALV_DATA_MID_BOT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> <LS_TOP>_DELNO
*&---------------------------------------------------------------------*
FORM F_SET_ALV_DATA_MID_BOT  USING PV_SYSTEM_ID
                                                                PV_ZIFKEY
                                                                PV_DELNO.

  CLEAR:
    GT_MID[],
    GT_BOT[].

  "라벨 정보
  SELECT
    ZZ~*
    FROM @GT_LABEL AS ZZ
    WHERE ZZ~SYSTEM_ID EQ @PV_SYSTEM_ID
    AND ZZ~ZIFKEY EQ @PV_ZIFKEY
    AND ZZ~DELNO EQ @PV_DELNO
    INTO TABLE @GT_MID.

  "하위자재 투입 정보
  SELECT
    ZZ~*
    FROM @GT_ISSUE AS ZZ
    WHERE ZZ~SYSTEM_ID EQ @PV_SYSTEM_ID
    AND ZZ~ZIFKEY EQ @PV_ZIFKEY
    AND ZZ~DELNO EQ @PV_DELNO
    INTO TABLE @GT_BOT.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_CREATE_ALV_OBJECT_200
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_CREATE_ALV_OBJECT_200 .

  GO_CONT_200 = NEW #( CONTAINER_NAME = 'CON200' ).
  GO_GRID_200 = NEW #( I_PARENT = GO_CONT_200 ).

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_SET_EXCL_200
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_SET_EXCL_200 .

  CLEAR:
   GT_EXCL_200[].

  GT_EXCL_200[] = VALUE #( ( CL_GUI_ALV_GRID=>MC_FC_LOC_UNDO  )
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
*& Form F_SET_LAYO_200
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_SET_LAYO_200 .

  CLEAR:
    GS_LAYO_200.

  GS_LAYO_200-SEL_MODE   = GC_D.
  GS_LAYO_200-CWIDTH_OPT = ABAP_TRUE.
  GS_LAYO_200-ZEBRA      = ABAP_TRUE.
  GS_LAYO_200-SMALLTITLE = ABAP_TRUE.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_SET_VARI_200
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_SET_VARI_200 .

  CLEAR:
    GS_VARI_200.

  GS_VARI_200-REPORT = SY-REPID.
  GS_VARI_200-USERNAME = SY-UNAME.
  GS_VARI_200-HANDLE = 'DR01'.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_SET_FCAT_200
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_SET_FCAT_200 .

  PERFORM F_CREATE_FCAT_BY_ITAB USING GT_DRUM CHANGING GT_FCAT_200.
  PERFORM F_ADJ_FCAT_200.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_SET_ALV_EVENT_200
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_SET_ALV_EVENT_200 .

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_SET_ALV_SORT_200
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_SET_ALV_SORT_200 .

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_DISPLAY_ALV_200
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_DISPLAY_ALV_200 .

  CALL METHOD GO_GRID_200->SET_TABLE_FOR_FIRST_DISPLAY
    EXPORTING
      IS_LAYOUT            = GS_LAYO_200
      IT_TOOLBAR_EXCLUDING = GT_EXCL_200[]
      IS_VARIANT           = GS_VARI_200
      I_SAVE               = GV_ASAVE_200
    CHANGING
      IT_OUTTAB            = GT_DRUM[]
      IT_FIELDCATALOG      = GT_FCAT_200[]
      IT_SORT              = GT_SORT_200[]
    EXCEPTIONS
      OTHERS               = 4.

  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
          WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_ADJ_FCAT_200
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_ADJ_FCAT_200 .

  LOOP AT GT_FCAT_200 ASSIGNING FIELD-SYMBOL(<LS_FCAT>).
    CASE <LS_FCAT>-FIELDNAME.
      WHEN 'ZIFNO'. ""I/F No
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H01 CHANGING <LS_FCAT>."
      WHEN 'ZIFKEY'. ""Interface Key
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H02 CHANGING <LS_FCAT>."
      WHEN 'SYSTEM_ID'. ""I/F 시스템
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H03 CHANGING <LS_FCAT>."
      WHEN 'FLD_02'. ""시스템 명
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H04 CHANGING <LS_FCAT>."
      WHEN 'ZSTAT'. ""송수신상태
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H05 CHANGING <LS_FCAT>."
      WHEN 'MESSAGE'. ""송수신메세지
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H06 CHANGING <LS_FCAT>."
      WHEN 'IFNAM'. ""송수신자
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H07 CHANGING <LS_FCAT>."
      WHEN 'EBELN'. ""구매오더번호
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H10 CHANGING <LS_FCAT>."
      WHEN 'EBELP'. ""구매오더품목번호
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H11 CHANGING <LS_FCAT>."
      WHEN 'DR_LABELNO'. ""드럼라벨번호
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H37 CHANGING <LS_FCAT>."
      WHEN 'ERFMG'. ""수량
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H38 CHANGING <LS_FCAT>."
        <LS_FCAT>-QFIELDNAME = 'ERFME'.
      WHEN 'ERFME'. ""단위
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H39 CHANGING <LS_FCAT>."
       WHEN 'STATUS'. ""라벨상태
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H40 CHANGING <LS_FCAT>."
       WHEN 'WERKS'. ""플랜트
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H41 CHANGING <LS_FCAT>."

      WHEN OTHERS.
        <LS_FCAT>-TECH = ABAP_TRUE.
    ENDCASE.

    CASE <LS_FCAT>-FIELDNAME.
      WHEN 'ZIFNO' OR 'ZIFKEY' OR 'SYSTEM_ID' OR 'FLD_02' OR 'ZSTAT' OR'MESSAGE' OR 'IFNAM'.
        <LS_FCAT>-TECH = P_SEND.
    ENDCASE.

  ENDLOOP.

ENDFORM.
