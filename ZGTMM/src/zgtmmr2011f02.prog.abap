*&---------------------------------------------------------------------*
*& Include          ZGTMMR2011F02
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*& Form F_CREATE_ALV_OBJECT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_CREATE_ALV_OBJECT_100 .

  GO_CONT_100 = NEW #( CONTAINER_NAME = 'CON100' ).
  GO_GRID_100 = NEW #( I_PARENT = GO_CONT_100 ).

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_SET_EXCL
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_SET_EXCL_100 .

  GT_EXCL_100[] = VALUE #( ( CL_GUI_ALV_GRID=>MC_FC_LOC_UNDO  )
                       ( CL_GUI_ALV_GRID=>MC_FC_LOC_COPY )
                       ( CL_GUI_ALV_GRID=>MC_FC_LOC_COPY_ROW )
                       ( CL_GUI_ALV_GRID=>MC_FC_LOC_CUT )
                       ( CL_GUI_ALV_GRID=>MC_FC_LOC_DELETE_ROW )
                       ( CL_GUI_ALV_GRID=>MC_FC_LOC_INSERT_ROW )
                       ( CL_GUI_ALV_GRID=>MC_FC_LOC_APPEND_ROW )
                       ( CL_GUI_ALV_GRID=>MC_FC_LOC_PASTE )
                       ( CL_GUI_ALV_GRID=>MC_FC_LOC_PASTE_NEW_ROW )
                       ( CL_GUI_ALV_GRID=>MC_MB_EXPORT )
                       ( CL_GUI_ALV_GRID=>MC_FC_REFRESH )
                       ( CL_GUI_ALV_GRID=>MC_FC_INFO )  ).

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_SET_LAYO
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_SET_LAYO_100 .

  CLEAR:
    GS_LAYO_100.

  GS_LAYO_100-SEL_MODE   = GC_A.
  GS_LAYO_100-CWIDTH_OPT = ABAP_TRUE.
  GS_LAYO_100-ZEBRA      = ABAP_TRUE.
  GS_LAYO_100-SMALLTITLE = ABAP_TRUE.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_SET_VARI
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_SET_VARI_100.

  CLEAR:
    GS_VARI_100.

  GS_VARI_100-REPORT = SY-REPID.
  GS_VARI_100-HANDLE = 'HD01'.
  GS_VARI_100-USERNAME = SY-UNAME.

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
    LO_STRUDESCR TYPE REF TO CL_ABAP_STRUCTDESCR,
    LT_DFIES     TYPE DDFIELDS.

  LO_TABDESCR ?= CL_ABAP_TABLEDESCR=>DESCRIBE_BY_DATA( PT_ITAB ).
  LO_STRUDESCR ?= LO_TABDESCR->GET_TABLE_LINE_TYPE( ).
  LT_DFIES = CL_SALV_DATA_DESCR=>READ_STRUCTDESCR( LO_STRUDESCR ) .

  PT_FCAT[] = CORRESPONDING #( LT_DFIES MAPPING
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
FORM F_SET_FCAT_100 .

  CLEAR GT_FCAT_100.

  PERFORM F_CREATE_FCAT_BY_ITAB USING GT_LIST CHANGING GT_FCAT_100.
  PERFORM F_ADJ_FCAT_100.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_ADJ_FCAT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_ADJ_FCAT_100 .

  CHECK GT_FCAT_100[] IS NOT INITIAL.

  LOOP AT GT_FCAT_100 ASSIGNING FIELD-SYMBOL(<LS_FCAT>).
    CASE <LS_FCAT>-FIELDNAME.
      WHEN 'STATUS'. ""처리상태
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H01 CHANGING <LS_FCAT>."
      WHEN 'BANFN'. ""구매 요청 번호
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H02 CHANGING <LS_FCAT>."
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
        <LS_FCAT>-HOTSPOT = ABAP_TRUE.
      WHEN 'BNFPO'. ""품목
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H03 CHANGING <LS_FCAT>."
      WHEN 'FRGKZ'. ""결재 지시자
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H04 CHANGING <LS_FCAT>."
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-REF_TABLE = 'EBAN'.
        <LS_FCAT>-REF_FIELD = 'FRGKZ'.
      WHEN 'BADAT'. ""생성일자
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H05 CHANGING <LS_FCAT>."
      WHEN 'ERNAM'. ""생성자
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H06 CHANGING <LS_FCAT>."
      WHEN 'NAME_TEXT'. ""생성자 이름
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H07 CHANGING <LS_FCAT>."
      WHEN 'MATNR'. ""자재번호
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H08 CHANGING <LS_FCAT>."
      WHEN 'TXZ01'. ""자재내역
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H09 CHANGING <LS_FCAT>."
      WHEN 'WERKS'. ""플랜트
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H10 CHANGING <LS_FCAT>."
      WHEN 'NAME1'. ""플랜트명
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H11 CHANGING <LS_FCAT>."
      WHEN 'LGORT'. ""저장위치
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H12 CHANGING <LS_FCAT>."
      WHEN 'LGOBE'. ""저장위치명
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H13 CHANGING <LS_FCAT>."
      WHEN 'MENGE'. ""요청 수량
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H14 CHANGING <LS_FCAT>."
      WHEN 'MEINS'. ""요청 단위
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H15 CHANGING <LS_FCAT>."
      WHEN 'LFDAT'. ""납품 요청일
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H16 CHANGING <LS_FCAT>."
      WHEN 'PREIS'. ""예상 가격
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H17 CHANGING <LS_FCAT>."
      WHEN 'WAERS'. ""가격 통화
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H18 CHANGING <LS_FCAT>."
      WHEN 'PEINH'. ""가격 단위
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H19 CHANGING <LS_FCAT>."
      WHEN 'ZAMT'. ""요청 금액
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H20 CHANGING <LS_FCAT>."
      WHEN 'EKORG'. ""구매조직
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H21 CHANGING <LS_FCAT>."
      WHEN 'EKOTX'. ""구매조직 내역
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H22 CHANGING <LS_FCAT>."
      WHEN 'EKGRP'. ""구매그룹
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H23 CHANGING <LS_FCAT>."
      WHEN 'EKNAM'. ""구매그룹 내역
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H24 CHANGING <LS_FCAT>."
      WHEN 'AFNAM'. ""요청자
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H25 CHANGING <LS_FCAT>."
      WHEN 'KNTTP'. ""계정지정범주
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H26 CHANGING <LS_FCAT>."
      WHEN 'KNTTX'. ""계정지정범주 내역
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H27 CHANGING <LS_FCAT>."
      WHEN 'ANLN1'. ""자산번호
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H28 CHANGING <LS_FCAT>."
      WHEN 'TXT50'. ""자산명
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H29 CHANGING <LS_FCAT>."
      WHEN 'KOSTL'. ""코스트센터
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H30 CHANGING <LS_FCAT>."
      WHEN 'KOSTL_TEXT'. ""코스트센터 명
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H31 CHANGING <LS_FCAT>."
      WHEN 'SAKTO'. ""G/L 계정
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H32 CHANGING <LS_FCAT>."
      WHEN 'SAKTO_TEXT'. ""G/L 계정내역
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H33 CHANGING <LS_FCAT>."
      WHEN 'AUFNR'. ""오더번호
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H34 CHANGING <LS_FCAT>."
      WHEN 'AUFNR_TEXT'. ""오더 내역
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H35 CHANGING <LS_FCAT>."
      WHEN 'PS_PSP_PNR'. ""WBS 코드
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H36 CHANGING <LS_FCAT>."
      WHEN 'POST1'. ""WBS 내역
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H37 CHANGING <LS_FCAT>."
      WHEN 'MESSAGE'. ""처리 메시지
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H38 CHANGING <LS_FCAT>."

      WHEN 'APPSTATUS'.
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H39 CHANGING <LS_FCAT>."
        <LS_FCAT>-TECH = P_CONF.

      WHEN OTHERS.
        <LS_FCAT>-TECH = ABAP_TRUE.
    ENDCASE.

    CASE <LS_FCAT>-FIELDNAME.
      WHEN 'PREIS' OR 'ZAMT'.
        <LS_FCAT>-CFIELDNAME = 'WAERS'.
    ENDCASE.

    CASE <LS_FCAT>-FIELDNAME.
      WHEN 'STATUS' OR 'MESSAGE'.
        <LS_FCAT>-TECH = P_DISP.
    ENDCASE.
  ENDLOOP.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_SET_ALV_EVENT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_SET_ALV_EVENT_100 .

  CREATE OBJECT GO_EVENT_100.
  SET HANDLER GO_EVENT_100->HANDLE_HOTSPOT_CLICK FOR GO_GRID_100.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_SET_ALV_SORT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_SET_ALV_SORT_100 .

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_DISPLAY_ALV
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_DISPLAY_ALV_100 .

  CALL METHOD GO_GRID_100->SET_TABLE_FOR_FIRST_DISPLAY
    EXPORTING
      IS_LAYOUT            = GS_LAYO_100
      IT_TOOLBAR_EXCLUDING = GT_EXCL_100[]
      IS_VARIANT           = GS_VARI_100
      I_SAVE               = GV_ASAVE_100
    CHANGING
      IT_OUTTAB            = GT_LIST[]
      IT_FIELDCATALOG      = GT_FCAT_100[]
      IT_SORT              = GT_SORT_100[]
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
*&      --> GO_GRID_HD
*&---------------------------------------------------------------------*
FORM F_REFRESH_ALV  USING    PO_GRID TYPE REF TO CL_GUI_ALV_GRID.

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
*& Form F_HOTSPOT_CLICK_100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> ES_ROW_NO_ROW_ID
*&      --> E_COLUMN_ID
*&      --> SENDER
*&---------------------------------------------------------------------*
FORM F_HOTSPOT_CLICK_100  USING PS_ROW_ID TYPE INT4
                                               PS_COLUMN TYPE LVC_S_COL
                                               PO_SENDER.

  CHECK PS_ROW_ID IS NOT INITIAL.

  CASE PS_COLUMN-FIELDNAME.
    WHEN 'BANFN'. "구매요청
      READ TABLE GT_LIST ASSIGNING FIELD-SYMBOL(<LS_LIST>) INDEX PS_ROW_ID.
      CHECK SY-SUBRC EQ 0.
      CHECK <LS_LIST>-BANFN IS NOT INITIAL.
      SET PARAMETER ID 'BAN' FIELD <LS_LIST>-BANFN.
      CALL TRANSACTION 'ME53N'.


  ENDCASE.

ENDFORM.
