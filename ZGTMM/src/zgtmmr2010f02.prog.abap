*&---------------------------------------------------------------------*
*& Include          ZGTMMR2010F02
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
      WHEN 'BANFN'. ""구매 요청 번호
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H01 CHANGING <LS_FCAT>."
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
        <LS_FCAT>-HOTSPOT = ABAP_TRUE.
      WHEN 'BNFPO'. ""품목
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H02 CHANGING <LS_FCAT>."
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
      WHEN 'BADAT'. ""생성일자
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H03 CHANGING <LS_FCAT>."
      WHEN 'ERNAM'. ""생성자
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H04 CHANGING <LS_FCAT>."
      WHEN 'NAME_TEXT'. ""생성자 이름
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H05 CHANGING <LS_FCAT>."
      WHEN 'MATNR'. ""자재번호
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H06 CHANGING <LS_FCAT>."
      WHEN 'TXZ01'. ""자재내역
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H07 CHANGING <LS_FCAT>."
      WHEN 'WERKS'. ""플랜트
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H08 CHANGING <LS_FCAT>."
      WHEN 'NAME1'. ""플랜트명
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H09 CHANGING <LS_FCAT>."
      WHEN 'LGORT'. ""저장위치
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H10 CHANGING <LS_FCAT>."
      WHEN 'LGOBE'. ""저장위치명
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H11 CHANGING <LS_FCAT>."
      WHEN 'MENGE'. ""요청 수량
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H12 CHANGING <LS_FCAT>."
      WHEN 'MEINS'. ""요청 단위
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H13 CHANGING <LS_FCAT>."
      WHEN 'LFDAT'. ""납품 요청일
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H14 CHANGING <LS_FCAT>."
      WHEN 'PREIS'. ""예상 가격
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H15 CHANGING <LS_FCAT>."
      WHEN 'WAERS'. ""가격 통화
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H16 CHANGING <LS_FCAT>."
      WHEN 'PEINH'. ""가격 단위
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H17 CHANGING <LS_FCAT>."
      WHEN 'ZAMT'. ""요청 금액
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H18 CHANGING <LS_FCAT>."
      WHEN 'EKORG'. ""구매조직
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H19 CHANGING <LS_FCAT>."
      WHEN 'EKOTX'. ""구매조직 내역
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H20 CHANGING <LS_FCAT>."
      WHEN 'EKGRP'. ""구매그룹
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H21 CHANGING <LS_FCAT>."
      WHEN 'EKNAM'. ""구매그룹 내역
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H22 CHANGING <LS_FCAT>."
      WHEN 'LIFNR'. ""희망 공급업체
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H23 CHANGING <LS_FCAT>."
      WHEN 'FLIEF'. ""고정 공급업체
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H24 CHANGING <LS_FCAT>."
      WHEN 'LOEKZ'. ""삭제 지시자
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H25 CHANGING <LS_FCAT>."
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-CHECKBOX = ABAP_TRUE.
      WHEN 'EBAKZ'. ""완료 지시자
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H26 CHANGING <LS_FCAT>."
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-CHECKBOX = ABAP_TRUE.
      WHEN 'FRGKZ'. ""결재 지시자
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H27 CHANGING <LS_FCAT>."
      WHEN 'AFNAM'. ""요청자
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H28 CHANGING <LS_FCAT>."
      WHEN 'KNTTP'. ""계정지정범주
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H29 CHANGING <LS_FCAT>."
      WHEN 'KNTTX'. ""계정지정범주 내역
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H30 CHANGING <LS_FCAT>."
      WHEN 'PSTYP'. ""품목범주
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H31 CHANGING <LS_FCAT>."
      WHEN 'PTEXT'. ""품목범주 내역
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H32 CHANGING <LS_FCAT>."
      WHEN 'ANLN1'. ""자산번호
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H33 CHANGING <LS_FCAT>."
      WHEN 'TXT50'. ""자산명
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H34 CHANGING <LS_FCAT>."
      WHEN 'KOSTL'. ""코스트센터
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H35 CHANGING <LS_FCAT>."
      WHEN 'KOSTL_TEXT'. ""코스트센터 명
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H36 CHANGING <LS_FCAT>."
      WHEN 'SAKTO'. ""G/L 계정
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H37 CHANGING <LS_FCAT>."
      WHEN 'SAKTO_TEXT'. ""G/L 계정내역
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H38 CHANGING <LS_FCAT>."
      WHEN 'AUFNR'. ""오더번호
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H39 CHANGING <LS_FCAT>."
      WHEN 'AUFNR_TEXT'. ""오더 내역
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H40 CHANGING <LS_FCAT>."
      WHEN 'PS_PSP_PNR'. ""WBS 코드
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H41 CHANGING <LS_FCAT>."
        <LS_FCAT>-CHECKTABLE = '!'.
      WHEN 'POST1'. ""WBS 내역
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H42 CHANGING <LS_FCAT>."


      WHEN 'APPSTATUS'. ""승인상태
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H51 CHANGING <LS_FCAT>."
      WHEN 'EBELN'. ""구매오더번호
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H52 CHANGING <LS_FCAT>."
      WHEN 'EBELP'. ""구매오더품목
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H53 CHANGING <LS_FCAT>."
*
*    APPSTATUS  TYPE ZGTMMT1070-APPSTATUS,
*    EBELN      TYPE EKPO-EBELN,
*    EBELP      TYPE EKPO-EBELP,

*      WHEN 'MESSAGE'. "처리 메시지
*        PERFORM F_SET_FCAT_COLTXT USING TEXT-H43 CHANGING <LS_FCAT>."
*      WHEN 'STATUS'. "상태
*        PERFORM F_SET_FCAT_COLTXT USING TEXT-H44 CHANGING <LS_FCAT>."
*        <LS_FCAT>-JUST = GC_C.
*        <LS_FCAT>-ICON = ABAP_TRUE.

      WHEN 'ITEMTEXT'. ""품목 텍스트
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H54 CHANGING <LS_FCAT>."

      WHEN 'COLOR'. ""색상
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H59 CHANGING <LS_FCAT>."
        <LS_FCAT>-OUTPUTLEN = 8.
      WHEN 'LENGTH'. ""조장
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H60 CHANGING <LS_FCAT>."
        <LS_FCAT>-OUTPUTLEN = 13.
        <LS_FCAT>-JUST = GC_R.
      WHEN 'FACTOR'. ""조장수
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H61 CHANGING <LS_FCAT>."
        <LS_FCAT>-OUTPUTLEN = 8.
        <LS_FCAT>-JUST = GC_R.
      WHEN 'DRMATNR'. ""포장재(드럼)
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H62 CHANGING <LS_FCAT>."
        <LS_FCAT>-REF_TABLE = 'MARA'.
        <LS_FCAT>-REF_FIELD = 'MATNR'.
        <LS_FCAT>-OUTPUTLEN = 12.
        <LS_FCAT>-INTLEN = 40.
      WHEN 'DRMAKTX'. ""포장재(드럼) 내역
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H63 CHANGING <LS_FCAT>."

      WHEN OTHERS.
        <LS_FCAT>-TECH = ABAP_TRUE.
    ENDCASE.

    CASE <LS_FCAT>-FIELDNAME.
      WHEN 'PREIS' OR 'ZAMT'.
        <LS_FCAT>-CFIELDNAME = 'WAERS'.
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
                       ( CL_GUI_ALV_GRID=>MC_FC_REFRESH )
                       ( CL_GUI_ALV_GRID=>MC_FC_INFO )  ).

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

  GS_LAYO_200-SEL_MODE   = GC_A.
*  GS_LAYO_200-CWIDTH_OPT = ABAP_TRUE.
  GS_LAYO_200-ZEBRA      = ABAP_TRUE.
  GS_LAYO_200-SMALLTITLE = ABAP_TRUE.
  GS_LAYO_200-STYLEFNAME = 'ZSTYLE'.

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
  GS_VARI_200-HANDLE = 'HD02'.
  GS_VARI_200-USERNAME = SY-UNAME.

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

  CLEAR GT_FCAT_200.

  PERFORM F_CREATE_FCAT_BY_ITAB USING GT_OPT1 CHANGING GT_FCAT_200.
  PERFORM F_ADJ_FCAT_200.

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

  CHECK GT_FCAT_200[] IS NOT INITIAL.

  LOOP AT GT_FCAT_200 ASSIGNING FIELD-SYMBOL(<LS_FCAT>).
    CASE <LS_FCAT>-FIELDNAME.
      WHEN 'STATUS'. ""상태
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H44 CHANGING <LS_FCAT>."
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
      WHEN 'BANFN'. ""구매 요청 번호
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H01 CHANGING <LS_FCAT>."
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
        <LS_FCAT>-HOTSPOT = ABAP_TRUE.
      WHEN 'BNFPO'. ""품목
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H02 CHANGING <LS_FCAT>."
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
      WHEN 'KNTTP'. ""계정 지정범주
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H29 CHANGING <LS_FCAT>."
        <LS_FCAT>-REF_TABLE = 'EBAN'.
        <LS_FCAT>-REF_FIELD = 'KNTTP'.
        <LS_FCAT>-INTLEN = <LS_FCAT>-OUTPUTLEN.
        <LS_FCAT>-OUTPUTLEN = 6.
      WHEN 'KNTTX'. ""계정지정범주 내역
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H30 CHANGING <LS_FCAT>."
        <LS_FCAT>-OUTPUTLEN = 15.
      WHEN 'PSTYP'. ""품목범주
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H31 CHANGING <LS_FCAT>."
        <LS_FCAT>-REF_TABLE = 'EBAN'.
        <LS_FCAT>-REF_FIELD = 'PSTYP'.
        <LS_FCAT>-INTLEN = <LS_FCAT>-OUTPUTLEN.
        <LS_FCAT>-OUTPUTLEN = 6.
      WHEN 'PTEXT'. ""품목범주 내역
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H32 CHANGING <LS_FCAT>."
        <LS_FCAT>-OUTPUTLEN = 15.
      WHEN 'MATNR'. ""자재번호
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H06 CHANGING <LS_FCAT>."
        <LS_FCAT>-REF_TABLE = 'EBAN'.
        <LS_FCAT>-REF_FIELD = 'MATNR'.
        <LS_FCAT>-INTLEN = <LS_FCAT>-OUTPUTLEN.
        <LS_FCAT>-OUTPUTLEN = 10.
      WHEN 'MAKTX'. ""자재내역
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H07 CHANGING <LS_FCAT>."
        <LS_FCAT>-OUTPUTLEN = 30.
      WHEN 'MATKL'. ""자재그룹
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H45 CHANGING <LS_FCAT>."
        <LS_FCAT>-REF_TABLE = 'MARA'.
        <LS_FCAT>-REF_FIELD = 'MATKL'.
        <LS_FCAT>-INTLEN = <LS_FCAT>-OUTPUTLEN.
        <LS_FCAT>-OUTPUTLEN = 10.
      WHEN 'WGBEZ'. ""자재그룹 내역
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H46 CHANGING <LS_FCAT>."
      WHEN 'WERKS'. ""플랜트
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H08 CHANGING <LS_FCAT>."
        <LS_FCAT>-REF_TABLE = 'EBAN'.
        <LS_FCAT>-REF_FIELD = 'WERKS'.
        <LS_FCAT>-INTLEN = <LS_FCAT>-OUTPUTLEN.
        <LS_FCAT>-OUTPUTLEN = 6.
      WHEN 'NAME1'. ""플랜트명
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H09 CHANGING <LS_FCAT>."
        <LS_FCAT>-OUTPUTLEN = 15.
      WHEN 'LGORT'. ""저장위치
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H10 CHANGING <LS_FCAT>."
        <LS_FCAT>-REF_TABLE = 'EBAN'.
        <LS_FCAT>-REF_FIELD = 'LGORT'.
        <LS_FCAT>-INTLEN = <LS_FCAT>-OUTPUTLEN.
        <LS_FCAT>-OUTPUTLEN = 6.
      WHEN 'LGOBE'. ""저장위치명
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H11 CHANGING <LS_FCAT>."
        <LS_FCAT>-OUTPUTLEN = 15.
      WHEN 'MENGE'. ""요청 수량
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H12 CHANGING <LS_FCAT>."
        <LS_FCAT>-INTLEN = <LS_FCAT>-OUTPUTLEN.
        <LS_FCAT>-OUTPUTLEN = 12.
      WHEN 'MEINS'. ""요청 단위
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H13 CHANGING <LS_FCAT>."
        <LS_FCAT>-REF_TABLE = 'EBAN'.
        <LS_FCAT>-REF_FIELD = 'MEINS'.
        <LS_FCAT>-INTLEN = <LS_FCAT>-OUTPUTLEN.
        <LS_FCAT>-OUTPUTLEN = 7.
      WHEN 'LFDAT'. ""납품 요청일
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H14 CHANGING <LS_FCAT>."
        <LS_FCAT>-REF_TABLE = 'EBAN'.
        <LS_FCAT>-REF_FIELD = 'LFDAT'.
      WHEN 'EKORG'. ""구매조직
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H19 CHANGING <LS_FCAT>."
        <LS_FCAT>-REF_TABLE = 'EBAN'.
        <LS_FCAT>-REF_FIELD = 'EKORG'.
        <LS_FCAT>-INTLEN = <LS_FCAT>-OUTPUTLEN.
        <LS_FCAT>-OUTPUTLEN = 7.
      WHEN 'EKOTX'. ""구매조직 내역
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H20 CHANGING <LS_FCAT>."
      WHEN 'EKGRP'. ""구매그룹
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H21 CHANGING <LS_FCAT>."
        <LS_FCAT>-REF_TABLE = 'EBAN'.
        <LS_FCAT>-REF_FIELD = 'EKGRP'.
        <LS_FCAT>-INTLEN = <LS_FCAT>-OUTPUTLEN.
        <LS_FCAT>-OUTPUTLEN = 7.
      WHEN 'EKNAM'. ""구매그룹 내역
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H22 CHANGING <LS_FCAT>."
      WHEN 'AFNAM'. ""요청자
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H28 CHANGING <LS_FCAT>."
      WHEN 'LIFNR'. ""희망 공급업체
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H23 CHANGING <LS_FCAT>."
        <LS_FCAT>-REF_TABLE = 'EBAN'.
        <LS_FCAT>-REF_FIELD = 'LIFNR'.
      WHEN 'FLIEF'. ""고정 공급업체
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H24 CHANGING <LS_FCAT>."
        <LS_FCAT>-REF_TABLE = 'EBAN'.
        <LS_FCAT>-REF_FIELD = 'FLIEF'.
      WHEN 'PREIS'. ""예상 가격
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H15 CHANGING <LS_FCAT>."
      WHEN 'WAERS'. ""가격 통화
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H16 CHANGING <LS_FCAT>."
      WHEN 'PEINH'. ""가격 단위
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H17 CHANGING <LS_FCAT>."
      WHEN 'ZAMT'. ""요청 금액
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H18 CHANGING <LS_FCAT>."
        <LS_FCAT>-INTLEN = <LS_FCAT>-OUTPUTLEN.
        <LS_FCAT>-OUTPUTLEN = 16.
      WHEN 'VBELN'. ""영업오더
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H47 CHANGING <LS_FCAT>."
        <LS_FCAT>-REF_TABLE = 'VBAP'.
        <LS_FCAT>-REF_FIELD = 'VBELN'.
      WHEN 'VBELP'. ""영업오더품목
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H48 CHANGING <LS_FCAT>."
        <LS_FCAT>-REF_TABLE = 'VBAP'.
        <LS_FCAT>-REF_FIELD = 'POSNR'.
      WHEN 'MESSAGE'. ""처리 메시지
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H43 CHANGING <LS_FCAT>."
        <LS_FCAT>-OUTPUTLEN = 30.


      WHEN 'ITEMTEXT'. ""품목 텍스트
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H54 CHANGING <LS_FCAT>."
        <LS_FCAT>-INTLEN = <LS_FCAT>-OUTPUTLEN.
        <LS_FCAT>-OUTPUTLEN = 30.

      WHEN 'KOSTL'. ""코스트센터
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H35 CHANGING <LS_FCAT>."
        <LS_FCAT>-REF_TABLE = 'CSKS'.
        <LS_FCAT>-REF_FIELD = 'KOSTL'.
        <LS_FCAT>-CHECKTABLE = '!'.
      WHEN 'KOSTL_TEXT'. ""코스트센터 명
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H36 CHANGING <LS_FCAT>."
      WHEN 'SAKTO'. ""G/L 계정
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H37 CHANGING <LS_FCAT>."
        <LS_FCAT>-REF_TABLE = 'EBKN'.
        <LS_FCAT>-REF_FIELD = 'SAKTO'.
        <LS_FCAT>-CHECKTABLE = '!'.
      WHEN 'SAKTO_TEXT'. ""G/L 계정내역
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H38 CHANGING <LS_FCAT>."

      WHEN 'ABLAD'. ""하역지점
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H49 CHANGING <LS_FCAT>."
        <LS_FCAT>-REF_TABLE = 'EBKN'.
        <LS_FCAT>-REF_FIELD = 'ABLAD'.
        <LS_FCAT>-INTLEN = <LS_FCAT>-OUTPUTLEN.
        <LS_FCAT>-OUTPUTLEN = 10.
      WHEN 'WEMPF'. ""수령인
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H50 CHANGING <LS_FCAT>."
        <LS_FCAT>-REF_TABLE = 'EBKN'.
        <LS_FCAT>-REF_FIELD = 'WEMPF'.
        <LS_FCAT>-INTLEN = <LS_FCAT>-OUTPUTLEN.
        <LS_FCAT>-OUTPUTLEN = 10.

      WHEN 'MWSKZ'. ""세금코드
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H58 CHANGING <LS_FCAT>."
        <LS_FCAT>-F4AVAILABL = ABAP_TRUE.
        <LS_FCAT>-OUTPUTLEN = 8.
      WHEN 'LIFNR_TEXT'. ""희망 공급업체 명
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H56 CHANGING <LS_FCAT>."
        <LS_FCAT>-OUTPUTLEN = 20.
      WHEN 'FLIEF_TEXT'. ""고정 공급업체 명
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H57 CHANGING <LS_FCAT>."
        <LS_FCAT>-OUTPUTLEN = 20.

      WHEN 'COLOR'. ""색상
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H59 CHANGING <LS_FCAT>."
        <LS_FCAT>-OUTPUTLEN = 8.
      WHEN 'LENGTH'. ""조장
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H60 CHANGING <LS_FCAT>."
        <LS_FCAT>-OUTPUTLEN = 13.
        <LS_FCAT>-JUST = GC_R.
      WHEN 'FACTOR'. ""조장수
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H61 CHANGING <LS_FCAT>."
        <LS_FCAT>-OUTPUTLEN = 8.
        <LS_FCAT>-JUST = GC_R.
      WHEN 'DRMATNR'. ""포장재(드럼)
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H62 CHANGING <LS_FCAT>."
        <LS_FCAT>-REF_TABLE = 'MARA'.
        <LS_FCAT>-REF_FIELD = 'MATNR'.
        <LS_FCAT>-OUTPUTLEN = 12.
        <LS_FCAT>-INTLEN = 40.
      WHEN 'DRMAKTX'. ""포장재(드럼) 내역
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H63 CHANGING <LS_FCAT>."


      WHEN OTHERS.
        <LS_FCAT>-TECH = ABAP_TRUE.
    ENDCASE.

    CASE <LS_FCAT>-FIELDNAME.
      WHEN 'PREIS' OR 'ZAMT'.
        <LS_FCAT>-CFIELDNAME = 'WAERS'.
    ENDCASE.

    CASE <LS_FCAT>-FIELDNAME.
      WHEN 'KNTTP' OR 'PSTYP' OR 'MATNR' OR 'MATKL' OR 'WERKS' OR 'LGORT' OR 'MENGE'
        OR 'MEINS' OR 'LFDAT' OR 'EKORG' OR 'EKGRP' OR 'AFNAM' OR 'LIFNR' OR 'FLIEF'
        OR 'PREIS' OR 'WAERS' OR 'PEINH' OR 'VBELN' OR 'VBELP' OR'PREIS' OR 'ITEMTEXT'
        OR 'KOSTL' OR 'SAKTO' OR 'ABLAD' OR 'WEMPF' OR 'MWSKZ'
        OR 'LENGTH' OR 'FACTOR' OR 'DRMATNR'.
        <LS_FCAT>-EDIT = ABAP_TRUE.
    ENDCASE.

  ENDLOOP.

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

  GO_GRID_200->REGISTER_EDIT_EVENT( CL_GUI_ALV_GRID=>MC_EVT_MODIFIED ).


  DATA(LT_LVC_T_F4) = VALUE LVC_T_F4( ( FIELDNAME = 'MWSKZ' REGISTER = ABAP_TRUE ) ).
  CALL METHOD GO_GRID_200->REGISTER_F4_FOR_FIELDS
    EXPORTING
      IT_F4 = LT_LVC_T_F4.


  CREATE OBJECT GO_EVENT_200.
  SET HANDLER GO_EVENT_200->HANDLE_HOTSPOT_CLICK FOR GO_GRID_200.
  SET HANDLER GO_EVENT_200->HANDLE_TOOLBAR FOR GO_GRID_200.
  SET HANDLER GO_EVENT_200->HANDLE_USER_COMMAND FOR GO_GRID_200.
  SET HANDLER GO_EVENT_200->HANDLE_DATA_CHANGED FOR GO_GRID_200.
  SET HANDLER GO_EVENT_200->HANDLE_DATA_CHANGED_FINISHED FOR GO_GRID_200.
  SET HANDLER GO_EVENT_200->HANDLE_ON_F4 FOR GO_GRID_200.

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
      IT_OUTTAB            = GT_OPT1[]
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
*& Form F_HOTSPOT_CLICK_200
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> ES_ROW_NO_ROW_ID
*&      --> E_COLUMN_ID
*&      --> SENDER
*&---------------------------------------------------------------------*
FORM F_HOTSPOT_CLICK_200  USING PS_ROW_ID TYPE INT4
                                               PS_COLUMN TYPE LVC_S_COL
                                               PO_SENDER.

  CHECK PS_ROW_ID IS NOT INITIAL.

  CASE PS_COLUMN-FIELDNAME.
    WHEN 'BANFN'. "구매요청
      READ TABLE GT_OPT1 ASSIGNING FIELD-SYMBOL(<LS_OPT1>) INDEX PS_ROW_ID.
      CHECK SY-SUBRC EQ 0.
      CHECK <LS_OPT1>-BANFN IS NOT INITIAL.
      SET PARAMETER ID 'BAN' FIELD <LS_OPT1>-BANFN.
      CALL TRANSACTION 'ME53N'.


  ENDCASE.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_TOOLBAR_200
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> E_OBJECT
*&      --> SENDER
*&---------------------------------------------------------------------*
FORM F_TOOLBAR_200  USING  PR_OBJ TYPE REF TO CL_ALV_EVENT_TOOLBAR_SET
                                     PO_SENDER.

  DATA : LS_TBAR TYPE STB_BUTTON.

  DEFINE _SET_TBAR.
    CLEAR : ls_tbar.

    ls_tbar-butn_type = &1.
    ls_tbar-function   = &2.
    ls_tbar-icon           = &3.
    ls_tbar-text          = &4.
    ls_tbar-quickinfo = &4.

    APPEND ls_tbar TO pr_obj->mt_toolbar.
  END-OF-DEFINITION.

  _SET_TBAR 3 '    ' '              ' '    '.
  _SET_TBAR 0 'INSR'  ICON_INSERT_ROW   TEXT-BT1.
  _SET_TBAR 0 'DELE' ICON_DELETE_ROW  TEXT-BT2.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_INSERT_ROW_200
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_INSERT_ROW_200 .

  DATA LV_CHECK TYPE C LENGTH 1.
  CALL METHOD GO_GRID_200->CHECK_CHANGED_DATA
    IMPORTING
      E_VALID = LV_CHECK.

  SELECT SINGLE
    WAERS
    FROM T001
    WHERE BUKRS EQ @P_BUKRS
    INTO @DATA(LV_WAERS).

  APPEND VALUE #( STATUS = SPACE PEINH = 1 WAERS = LV_WAERS
                             WERKS = P_WERKS
                             NAME1 = GV_NAME1
                             EKORG = P_EKORG
                             EKOTX = GV_EKOTX
                             EKGRP = P_EKGRP
                             EKNAM = GV_EKNAM
                             ZSTYLE = VALUE #( ( FIELDNAME = 'VBELN' STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED )
                                                            ( FIELDNAME = 'VBELP' STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED ) ) ) TO GT_OPT1.


  PERFORM F_REFRESH_ALV USING GO_GRID_200.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_USER_COMMAND_200
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> E_UCOMM
*&---------------------------------------------------------------------*
FORM F_USER_COMMAND_200  USING PV_UCOMM TYPE SY-UCOMM.

  CASE PV_UCOMM.
    WHEN 'INSR'. "행 추가
      PERFORM F_INSERT_ROW_200.
    WHEN 'DELE'. "행 삭제
      PERFORM F_DELETE_ROW_200.
  ENDCASE.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_DELETE_ROW_200
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_DELETE_ROW_200 .

  DATA:
    LV_ROW_ID  TYPE INT4,
    LV_DEL_CNT TYPE INT4,
    LV_CHECK   TYPE C LENGTH 1,
    LT_ROW_ID  TYPE LVC_T_ROID.

  FIELD-SYMBOLS:
    <LS_ROW_ID> TYPE LVC_S_ROID,
    <LS_OPT1>   TYPE TY_OPT1.

  CALL METHOD GO_GRID_200->CHECK_CHANGED_DATA
    IMPORTING
      E_VALID = LV_CHECK.

  CHECK LV_CHECK EQ ABAP_TRUE.

  CALL METHOD GO_GRID_200->GET_SELECTED_ROWS
    IMPORTING
      ET_ROW_NO = LT_ROW_ID.

  DELETE LT_ROW_ID WHERE ROW_ID LE 0.

*3. 삭제 버튼
*	3-1) 라인은 다중선택 가능 (전체선택 포함)
*	3-2) 선택한 라인이 없는 경우 하단 에러 메시지 "선택한 데이터가 없습니다."
*	3-3) 선택한 라인에 BANFN 값이 있으면 하단 에러 메시지 "생성된 구매요청이 존재합니다."
*	3-3) 선택한 라인에 BANFN 값이 없으면 선택 라인 데이터 삭제 처리
  IF LT_ROW_ID[] IS INITIAL.
    MESSAGE S163 DISPLAY LIKE GC_E.
    EXIT.
  ENDIF.

  LOOP AT LT_ROW_ID ASSIGNING <LS_ROW_ID>.
    LV_ROW_ID = <LS_ROW_ID>-ROW_ID - LV_DEL_CNT.
    READ TABLE GT_OPT1 ASSIGNING <LS_OPT1> INDEX LV_ROW_ID.
    CHECK SY-SUBRC EQ 0.
    IF <LS_OPT1>-BANFN IS NOT INITIAL.
      MESSAGE S000 DISPLAY LIKE GC_E WITH TEXT-E02. "생성된 구매요청이 존재합니다.
      LV_CHECK = GC_E.
      EXIT.
    ENDIF.
  ENDLOOP.

  CHECK LV_CHECK NE GC_E. "오류 메세지 없는 경우 진행

  LOOP AT LT_ROW_ID ASSIGNING <LS_ROW_ID>.
    LV_ROW_ID = <LS_ROW_ID>-ROW_ID - LV_DEL_CNT.
    READ TABLE GT_OPT1 ASSIGNING <LS_OPT1> INDEX LV_ROW_ID.
    CHECK SY-SUBRC EQ 0.

    DELETE GT_OPT1 INDEX LV_ROW_ID.
    LV_DEL_CNT += 1.
    CONTINUE.

  ENDLOOP.

  PERFORM F_REFRESH_ALV USING GO_GRID_200.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_DATA_CHANGED_FIN_200
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> E_MODIFIED
*&      --> ET_GOOD_CELLS
*&---------------------------------------------------------------------*
FORM F_DATA_CHANGED_FIN_200  USING    PV_MODIFIED TYPE CHAR01
                                     PT_GOOD_CELLS TYPE LVC_T_MODI.

  CHECK PV_MODIFIED EQ ABAP_TRUE.

  FIELD-SYMBOLS <LS_OPT1> TYPE TY_OPT1.

  DATA LT_FNAME TYPE TY_T_FNAME.

  "자재코드 필드가 변경 된 경우
  LOOP AT PT_GOOD_CELLS ASSIGNING  FIELD-SYMBOL(<LS_G0>)" WHERE FIELDNAME EQ 'MATNR'
                                                              GROUP BY ( ROW_ID = <LS_G0>-ROW_ID )
                                                              ASSIGNING FIELD-SYMBOL(<LS_GROUP>).

    READ TABLE GT_OPT1 ASSIGNING <LS_OPT1> INDEX <LS_GROUP>-ROW_ID.
    CHECK SY-SUBRC EQ 0.
    CLEAR LT_FNAME.
    LOOP AT GROUP <LS_GROUP> ASSIGNING FIELD-SYMBOL(<LS_CELLS>).
      LT_FNAME = VALUE #( BASE LT_FNAME ( FNAME = <LS_CELLS>-FIELDNAME ) ).
    ENDLOOP.

    "추가 설정 값
    PERFORM F_SET_ETC_VALUES_OPT1 USING LT_FNAME CHANGING <LS_OPT1>.

    "코드 텍스트 설정
    PERFORM F_SET_CODE_TEXT_OPT1 USING LT_FNAME CHANGING <LS_OPT1>.

  ENDLOOP.


  PERFORM F_REFRESH_ALV USING GO_GRID_200.


ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_SET_CODE_TEXT_OPT1
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LT_FNAME
*&      <-- <LS_OPT1>
*&---------------------------------------------------------------------*
FORM F_SET_CODE_TEXT_OPT1  USING  PT_FNAME TYPE TY_T_FNAME
                           CHANGING CS_OPT1 TYPE TY_OPT1.

  "계정 지정 범주
  READ TABLE PT_FNAME WITH TABLE KEY FNAME = 'KNTTP' TRANSPORTING NO FIELDS.
  IF SY-SUBRC EQ 0.
    CLEAR CS_OPT1-KNTTX. "초기화
    READ TABLE GT_T163I ASSIGNING FIELD-SYMBOL(<LS_T163I>) WITH TABLE KEY KNTTP = CS_OPT1-KNTTP.
    IF SY-SUBRC EQ 0.
      CS_OPT1-KNTTX = <LS_T163I>-KNTTX.
    ENDIF.
  ENDIF.

  "품목 범주
  READ TABLE PT_FNAME WITH TABLE KEY FNAME = 'PSTYP' TRANSPORTING NO FIELDS.
  IF SY-SUBRC EQ 0.
    CLEAR CS_OPT1-PTEXT. "초기화
    READ TABLE GT_T163Y ASSIGNING FIELD-SYMBOL(<LS_T163Y>) WITH TABLE KEY PSTYP = CS_OPT1-PSTYP.
    IF SY-SUBRC EQ 0.
      CS_OPT1-PTEXT = <LS_T163Y>-PTEXT.
    ENDIF.
  ENDIF.

  "자재 그룹
  READ TABLE PT_FNAME WITH TABLE KEY FNAME = 'MATKL' TRANSPORTING NO FIELDS.
  IF SY-SUBRC EQ 0.
    CLEAR CS_OPT1-WGBEZ. "초기화
    READ TABLE GT_T023T ASSIGNING FIELD-SYMBOL(<LS_T023T>) WITH TABLE KEY MATKL = CS_OPT1-MATKL.
    IF SY-SUBRC EQ 0.
      CS_OPT1-WGBEZ = <LS_T023T>-WGBEZ.
    ENDIF.
  ENDIF.

  "플랜트
  READ TABLE PT_FNAME WITH TABLE KEY FNAME = 'WERKS' TRANSPORTING NO FIELDS.
  IF SY-SUBRC EQ 0.
    CLEAR CS_OPT1-NAME1. "초기화
    READ TABLE GT_T001W ASSIGNING FIELD-SYMBOL(<LS_T001W>) WITH TABLE KEY WERKS = CS_OPT1-WERKS.
    IF SY-SUBRC EQ 0.
      CS_OPT1-NAME1 = <LS_T001W>-NAME1.
    ENDIF.
  ENDIF.

  "저장위치
  READ TABLE PT_FNAME WITH TABLE KEY FNAME = 'WERKS' TRANSPORTING NO FIELDS.
  IF SY-SUBRC NE 0.
    READ TABLE PT_FNAME WITH TABLE KEY FNAME = 'LGORT' TRANSPORTING NO FIELDS.
  ENDIF.
  IF SY-SUBRC EQ 0.
    CLEAR CS_OPT1-LGOBE. "초기화
    READ TABLE GT_T001L ASSIGNING FIELD-SYMBOL(<LS_T001L>) WITH TABLE KEY WERKS = CS_OPT1-WERKS
                                                                                                                              LGORT = CS_OPT1-LGORT.
    IF SY-SUBRC EQ 0.
      CS_OPT1-LGOBE = <LS_T001L>-LGOBE.
    ENDIF.
  ENDIF.

  "구매조직
  READ TABLE PT_FNAME WITH TABLE KEY FNAME = 'EKORG' TRANSPORTING NO FIELDS.
  IF SY-SUBRC EQ 0.
    CLEAR CS_OPT1-EKOTX. "초기화
    READ TABLE GT_T024E ASSIGNING FIELD-SYMBOL(<LS_T024E>) WITH TABLE KEY EKORG = CS_OPT1-EKORG.
    IF SY-SUBRC EQ 0.
      CS_OPT1-EKOTX = <LS_T024E>-EKOTX.
    ENDIF.
  ENDIF.

  "구매그룹
  READ TABLE PT_FNAME WITH TABLE KEY FNAME = 'EKGRP' TRANSPORTING NO FIELDS.
  IF SY-SUBRC EQ 0.
    CLEAR CS_OPT1-EKNAM. "초기화
    READ TABLE GT_T024 ASSIGNING FIELD-SYMBOL(<LS_T024>) WITH TABLE KEY EKGRP = CS_OPT1-EKGRP.
    IF SY-SUBRC EQ 0.
      CS_OPT1-EKNAM = <LS_T024>-EKNAM.
    ENDIF.
  ENDIF.

  "코스트센터 명                  KTEXT CSKT-KTEXT  Display KOSTL 입력 값에 따라 해당 텍스트로 보여줌
  READ TABLE PT_FNAME WITH TABLE KEY FNAME = 'KOSTL' TRANSPORTING NO FIELDS.
  IF SY-SUBRC EQ 0.
    CLEAR CS_OPT1-KOSTL_TEXT.
    SELECT SINGLE
      KTEXT
      FROM CSKT
      WHERE KOKRS EQ @P_BUKRS
      AND KOSTL EQ @CS_OPT1-KOSTL
      AND DATBI EQ '99991231'
      AND SPRAS EQ @SY-LANGU
      INTO @CS_OPT1-KOSTL_TEXT.
  ENDIF.

*G/L 계정내역                 TXT20 SKAT-XT20 Display SAKTO 입력 값에 따라 해당 텍스트로 보여줌
  READ TABLE PT_FNAME WITH TABLE KEY FNAME = 'SAKTO' TRANSPORTING NO FIELDS.
  IF SY-SUBRC EQ 0.
    CLEAR CS_OPT1-SAKTO_TEXT.
    SELECT SINGLE
      ST~TXT20
      FROM T001 AS T1
                INNER JOIN
              SKAT AS ST ON T1~KTOPL EQ ST~KTOPL
      WHERE T1~BUKRS EQ @P_BUKRS
      AND ST~SAKNR EQ @CS_OPT1-SAKTO
      AND ST~SPRAS EQ @SY-LANGU
      INTO @CS_OPT1-SAKTO_TEXT.
  ENDIF.

* 희망 공급업체
  READ TABLE PT_FNAME WITH TABLE KEY FNAME = 'LIFNR' TRANSPORTING NO FIELDS.
  IF SY-SUBRC EQ 0.
    CLEAR CS_OPT1-LIFNR_TEXT.
    SELECT SINGLE
      NAME1
      FROM LFA1
      WHERE LIFNR EQ @CS_OPT1-LIFNR
      INTO @CS_OPT1-LIFNR_TEXT.
  ENDIF.

* 고정 공급업체명
  READ TABLE PT_FNAME WITH TABLE KEY FNAME = 'FLIEF' TRANSPORTING NO FIELDS.
  IF SY-SUBRC EQ 0.
    CLEAR CS_OPT1-FLIEF_TEXT.
    SELECT SINGLE
      NAME1
      FROM LFA1
      WHERE LIFNR EQ @CS_OPT1-FLIEF
      INTO @CS_OPT1-FLIEF_TEXT.
  ENDIF.

*>S.2026.08.10_드럼자재/자재명 가져오는 로직 변경으로 앞서 내역도 설정되었으므로 아래로직 주석
*  "  드럼 자재 내역
*  READ TABLE PT_FNAME WITH TABLE KEY FNAME = 'DRMATNR' TRANSPORTING NO FIELDS.
*  IF SY-SUBRC EQ 0.
*    CLEAR CS_OPT1-DRMAKTX.
*    SELECT SINGLE
*      MAKTX
*      FROM MAKT
*      WHERE MATNR EQ @CS_OPT1-DRMATNR
*          AND SPRAS EQ 3
*      INTO @CS_OPT1-DRMAKTX.
*  ENDIF.
*<E.2026.08.10_ZGODEV04

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_SET_ETC_VALUES_OPT1
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LT_FNAME
*&      <-- <LS_OPT1>
*&---------------------------------------------------------------------*
FORM F_SET_ETC_VALUES_OPT1  USING  PT_FNAME TYPE TY_T_FNAME
                           CHANGING CS_OPT1 TYPE TY_OPT1.
  DATA :
    LV_JAKNO     TYPE KDKG4, "고객그룹코드
    LV_LENGTH(6),
    LV_ZDGNO     TYPE ZESUL_NO, "설계번호
    LV_ZREVNO    TYPE ZEREV_SEQ, "개정번호
    LV_MSG       TYPE BAPI_MSG,
    LT_DRUM      TYPE STANDARD TABLE OF ZGTEDSIF0038.

  "자재코드 변경
  READ TABLE PT_FNAME WITH TABLE KEY FNAME = 'MATNR' TRANSPORTING NO FIELDS.
  IF SY-SUBRC EQ 0.
    DELETE CS_OPT1-ZSTYLE[] WHERE FIELDNAME EQ 'MATKL' OR FIELDNAME EQ 'MEINS'.
    "자재코드가 입력 된 경우
    IF CS_OPT1-MATNR IS NOT INITIAL.
      "입력 불가 필드 설정
      CS_OPT1-ZSTYLE = VALUE #( BASE CS_OPT1-ZSTYLE ( FIELDNAME = 'MATKL' STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED )
                                                                                         ( FIELDNAME = 'MEINS' STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED ) ).

      "자재유형/단위 설정
      CLEAR:
        CS_OPT1-MATKL,
        CS_OPT1-MEINS.

      SELECT SINGLE
        MATKL,
        MEINS
        FROM MARA
        WHERE MATNR EQ @CS_OPT1-MATNR
        INTO ( @CS_OPT1-MATKL, @CS_OPT1-MEINS ).

      "자재유형명 변경
      READ TABLE PT_FNAME WITH TABLE KEY FNAME = 'MATKL' TRANSPORTING NO FIELDS.
      IF SY-SUBRC NE 0.
        PT_FNAME = VALUE #( BASE PT_FNAME ( FNAME = 'MATKL' ) ).
      ENDIF.

      "자재 특성(색상) 변경
      SELECT SINGLE ATWRT
        FROM ZGTSD_I_MATERIALCHARACTERISTIC
      WHERE MATNR EQ @CS_OPT1-MATNR
          AND ATNAM EQ 'PD_CA_COLOR_BASE'
         INTO @CS_OPT1-COLOR.

*>S.2026.08.10_조장 정보 있는 경우, 목드럼 자재코드 자동 지정 로직 추가
*배치유형 선체크_'DPCBT=C'인 경우만 수행.
      SELECT SINGLE DPCBT
        FROM MARC
        WHERE WERKS = @CS_OPT1-WERKS
           AND MATNR = @CS_OPT1-MATNR
          INTO @DATA(LV_DPCBT).
      IF LV_DPCBT = 'C' AND CS_OPT1-LENGTH > 0.
*설계번호(목드럼 자재코드 가져올 특성정보)
        SELECT SINGLE ATWRT
        FROM ZGTSD_I_MATERIALCHARACTERISTIC
        WHERE MATNR EQ @CS_OPT1-MATNR
        AND ATNAM EQ 'PD_CA_DESIGN_NO'
        INTO @LV_ZDGNO.
*개정번호(목드럼 자재코드 가져올 특성정보)
        SELECT SINGLE ATWRT
        FROM ZGTSD_I_MATERIALCHARACTERISTIC
        WHERE MATNR EQ @CS_OPT1-MATNR
        AND ATNAM EQ 'PD_CA_DESIGN_REV_NO'
        INTO @LV_ZREVNO.
*목드럼 자재코드 조회 수행
        LV_JAKNO = ''. "고객그룹코드
        DATA(LV_INT) = CONV I( TRUNC( CS_OPT1-LENGTH ) ). "조장_소숫점 버림
*        WRITE LV_INT TO LV_LENGTH RIGHT-JUSTIFIED.
        WRITE LV_INT TO LV_LENGTH NO-GROUPING RIGHT-JUSTIFIED. "1,000단위 콤마(,) 제거

        TRY.
            CALL FUNCTION 'ZGTED_GET_DRUM_CODE_PP'
              EXPORTING
                IV_SUL_NO    = LV_ZDGNO
                IV_REV_SEQ   = LV_ZREVNO
                IV_JAKNO     = LV_JAKNO
                IV_JOJANG    = LV_LENGTH
                IV_DRUM_CODE = 'H'
                IV_FLAG_PP   = 'X'
              TABLES
                OT_RETURN    = LT_DRUM.
          CATCH CX_ROOT INTO DATA(LV_ERROR).
            LV_MSG = LV_ERROR->GET_TEXT( ).
            MESSAGE S000 WITH LV_MSG.
        ENDTRY.

        IF LT_DRUM IS NOT INITIAL.
**--> 26.09 DRUM_MATNR 누락시 제외 추가
*
*        READ TABLE LT_DRUM ASSIGNING <DRUM> INDEX 2.
*        IF SY-SUBRC = 0.
*          CS_OPT1-DRMATNR = <DRUM>-DRUM_MATNR.
*          CS_OPT1-DRMAKTX = <DRUM>-MAKTX.
*        ENDIF.

        DELETE LT_DRUM WHERE DRUM_MATNR IS INITIAL.


        READ TABLE LT_DRUM ASSIGNING FIELD-SYMBOL(<DRUM>) INDEX 1.
        IF SY-SUBRC = 0.
          CS_OPT1-DRMATNR = <DRUM>-DRUM_MATNR.
          CS_OPT1-DRMAKTX = <DRUM>-MAKTX.
        ENDIF.


**--< 26.09 DRUM_MATNR 누락시 제외 추가
        ENDIF.

      ENDIF.
*<E.2026.08.10_ZGODEV04
    ENDIF.

    "자재 내역
    CLEAR CS_OPT1-MAKTX.
    SELECT SINGLE
      MAKTX
      FROM MAKT
      WHERE MATNR EQ @CS_OPT1-MATNR
      AND SPRAS EQ @SY-LANGU
      INTO @CS_OPT1-MAKTX.
  ENDIF.

*>S.2026.08.12_조장 정보 있는 경우, 목드럼 자재코드 자동 지정 로직 추가
*배치유형 선체크_'DPCBT=C'인 경우만 수행.
  READ TABLE PT_FNAME WITH TABLE KEY FNAME = 'LENGTH' TRANSPORTING NO FIELDS.
  IF SY-SUBRC EQ 0.
*배치유형 선체크_'DPCBT=C'인 경우만 수행.
    SELECT SINGLE DPCBT
      FROM MARC
      WHERE WERKS = @CS_OPT1-WERKS
         AND MATNR = @CS_OPT1-MATNR
        INTO @LV_DPCBT.

    IF LV_DPCBT = 'C' AND CS_OPT1-LENGTH > 0.
*설계번호(목드럼 자재코드 가져올 특성정보)
      SELECT SINGLE ATWRT
      FROM ZGTSD_I_MATERIALCHARACTERISTIC
      WHERE MATNR EQ @CS_OPT1-MATNR
      AND ATNAM EQ 'PD_CA_DESIGN_NO'
      INTO @LV_ZDGNO.
*개정번호(목드럼 자재코드 가져올 특성정보)
      SELECT SINGLE ATWRT
      FROM ZGTSD_I_MATERIALCHARACTERISTIC
      WHERE MATNR EQ @CS_OPT1-MATNR
      AND ATNAM EQ 'PD_CA_DESIGN_REV_NO'
      INTO @LV_ZREVNO.
*목드럼 자재코드 조회 수행
      LV_JAKNO = ''. "고객그룹코드
      LV_INT = CONV I( TRUNC( CS_OPT1-LENGTH ) ). "조장_소숫점 버림
*      WRITE lv_int TO lv_length RIGHT-JUSTIFIED.
      WRITE LV_INT TO LV_LENGTH NO-GROUPING RIGHT-JUSTIFIED. "1,000단위 콤마(,) 제거

      TRY.
          CALL FUNCTION 'ZGTED_GET_DRUM_CODE_PP'
            EXPORTING
              IV_SUL_NO    = LV_ZDGNO
              IV_REV_SEQ   = LV_ZREVNO
              IV_JAKNO     = LV_JAKNO
              IV_JOJANG    = LV_LENGTH
              IV_DRUM_CODE = 'H'
              IV_FLAG_PP   = 'X'
            TABLES
              OT_RETURN    = LT_DRUM.
        CATCH CX_ROOT INTO LV_ERROR.
          LV_MSG = LV_ERROR->GET_TEXT( ).
          MESSAGE S000 WITH LV_MSG.
      ENDTRY.

      IF LT_DRUM IS NOT INITIAL.
**--> 26.09 DRUM_MATNR 누락시 제외 추가
*
*        READ TABLE LT_DRUM ASSIGNING <DRUM> INDEX 2.
*        IF SY-SUBRC = 0.
*          CS_OPT1-DRMATNR = <DRUM>-DRUM_MATNR.
*          CS_OPT1-DRMAKTX = <DRUM>-MAKTX.
*        ENDIF.

        DELETE LT_DRUM WHERE DRUM_MATNR IS INITIAL.


        READ TABLE LT_DRUM ASSIGNING <DRUM> INDEX 1.
        IF SY-SUBRC = 0.
          CS_OPT1-DRMATNR = <DRUM>-DRUM_MATNR.
          CS_OPT1-DRMAKTX = <DRUM>-MAKTX.
        ENDIF.


**--< 26.09 DRUM_MATNR 누락시 제외 추가
      ENDIF.

    ENDIF.
  ENDIF.
*<E.2026.08.12_ZGODEV04

  "자재코드 or 플랜트 변경 시
  READ TABLE PT_FNAME WITH TABLE KEY FNAME = 'MATNR' TRANSPORTING NO FIELDS.
  IF SY-SUBRC NE 0.
    READ TABLE PT_FNAME WITH TABLE KEY FNAME = 'WERKS' TRANSPORTING NO FIELDS.
  ENDIF.
  IF SY-SUBRC EQ 0.
    "1) Possible Entry or 입력 가능
*2) MATNR, WERKS 입력값 기준으로 MARC-EKGRP 값으로 보여줌, 수정 가능"
    CLEAR CS_OPT1-EKGRP.
    SELECT SINGLE
      EKGRP
      FROM MARC
      WHERE MATNR EQ @CS_OPT1-MATNR
      AND WERKS EQ @CS_OPT1-WERKS
      INTO @CS_OPT1-EKGRP.

    IF CS_OPT1-EKGRP IS INITIAL.
      CS_OPT1-EKGRP = P_EKGRP.
    ENDIF.

    "구매그룹명 수정
    READ TABLE PT_FNAME WITH TABLE KEY FNAME = 'EKGRP' TRANSPORTING NO FIELDS.
    IF SY-SUBRC NE 0.
      PT_FNAME = VALUE #( BASE PT_FNAME ( FNAME = 'EKGRP' ) ).
    ENDIF.

    "1) MATNR,WERKS 입력값에 따라 자재 단가 조회
*Table: MBEW
*SELECT 조건: STPRS
*WHERE 조건 : MATNR, WERKS
*-> 조회 조건의 BUKRS 값 기준으로 T001-WAERS = ""KRW"" 이면 STPRS*100
*2) 직접 입력 가능"
    CLEAR CS_OPT1-PREIS.
    SELECT SINGLE
      STPRS,
      PEINH
      FROM MBEW
      WHERE MATNR EQ @CS_OPT1-MATNR
      AND BWKEY EQ @CS_OPT1-WERKS
      INTO ( @CS_OPT1-PREIS, @CS_OPT1-PEINH ).

    "예상가격 변경
    READ TABLE PT_FNAME WITH TABLE KEY FNAME = 'PREIS' TRANSPORTING NO FIELDS.
    IF SY-SUBRC NE 0.
      PT_FNAME = VALUE #( BASE PT_FNAME ( FNAME = 'PREIS' ) ).
    ENDIF.

    READ TABLE PT_FNAME WITH TABLE KEY FNAME = 'PEINH' TRANSPORTING NO FIELDS.
    IF SY-SUBRC NE 0.
      PT_FNAME = VALUE #( BASE PT_FNAME ( FNAME = 'PEINH' ) ).
    ENDIF.

  ENDIF.

  "수량/예상가격/가격단위 변경 시 요청금액 계산
*"입력한 MENGE,PREIS,PEINH 기준으로 계산
*= PREIS*MENGE/PEINH"
  READ TABLE PT_FNAME WITH TABLE KEY FNAME = 'MENGE' TRANSPORTING NO FIELDS.
  IF SY-SUBRC NE 0.
    READ TABLE PT_FNAME WITH TABLE KEY FNAME = 'PREIS' TRANSPORTING NO FIELDS.
    IF SY-SUBRC NE 0.
      READ TABLE PT_FNAME WITH TABLE KEY FNAME = 'PEINH' TRANSPORTING NO FIELDS.
    ENDIF.
  ENDIF.
  IF SY-SUBRC EQ 0.
    CLEAR CS_OPT1-ZAMT.
    IF CS_OPT1-PEINH IS NOT INITIAL.
      CS_OPT1-ZAMT = ( CS_OPT1-MENGE * CS_OPT1-PREIS ) / CS_OPT1-PEINH.
    ENDIF.
  ENDIF.

  READ TABLE PT_FNAME WITH TABLE KEY FNAME = 'KNTTP' TRANSPORTING NO FIELDS.
  IF SY-SUBRC EQ 0.
*"1) Possible Entry or 입력 가능
*2) KNTTP = ""M"" 이면 Editable
*   KNTTP <> ""M"" 이면 Display"
    DELETE CS_OPT1-ZSTYLE[] WHERE FIELDNAME EQ 'VBELN' OR FIELDNAME EQ 'VBELP'.
    "자재코드가 입력 된 경우
    IF CS_OPT1-KNTTP NE GC_M.
      "값 초기화
      CLEAR:
        CS_OPT1-VBELN,
        CS_OPT1-VBELP.

      "입력 불가 필드 설정
      CS_OPT1-ZSTYLE = VALUE #( BASE CS_OPT1-ZSTYLE ( FIELDNAME = 'VBELN' STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED )
                                                                                         ( FIELDNAME = 'VBELP' STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED ) ).

    ENDIF.
  ENDIF.

**--> 26.09   "DRMATNR 수기 입력처리시 내역 추가
  READ TABLE PT_FNAME WITH TABLE KEY FNAME = 'DRMATNR' TRANSPORTING NO FIELDS.
  IF SY-SUBRC IS INITIAL.
    SELECT SINGLE FROM MAKT FIELDS MAKTX
      WHERE MATNR EQ @CS_OPT1-DRMATNR
        AND SPRAS EQ @SY-LANGU
      INTO @CS_OPT1-DRMAKTX.
  ENDIF.
**--< 26.09   "DRMATNR 수기 입력처리시 내역 추가
ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_DATA_CHANGED_200
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> ER_DATA_CHANGED
*&      --> SENDER
*&---------------------------------------------------------------------*
FORM F_DATA_CHANGED_200  USING  PO_DATA_CHANGED TYPE REF TO CL_ALV_CHANGED_DATA_PROTOCOL.

  CHECK PO_DATA_CHANGED->MT_INSERTED_ROWS[] IS NOT INITIAL.

  "신규
  SELECT SINGLE
    WAERS
    FROM T001
    WHERE BUKRS EQ @P_BUKRS
    INTO @DATA(LV_WAERS).

  DATA LT_ZSTYLE TYPE LVC_T_STYL.
  LT_ZSTYLE = VALUE #( ( FIELDNAME = 'VBELN' STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED )
                                       ( FIELDNAME = 'VBELP' STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED ) ).

  LOOP AT PO_DATA_CHANGED->MT_INSERTED_ROWS ASSIGNING FIELD-SYMBOL(<LS_INS>).
    PERFORM F_ALV_MODIFY_CELL USING:
          PO_DATA_CHANGED <LS_INS>-ROW_ID 'PEINH' 1,
          PO_DATA_CHANGED <LS_INS>-ROW_ID 'WAERS' LV_WAERS,
          PO_DATA_CHANGED <LS_INS>-ROW_ID 'ZSTYLE' LT_ZSTYLE,

          PO_DATA_CHANGED <LS_INS>-ROW_ID 'WERKS' P_WERKS,
          PO_DATA_CHANGED <LS_INS>-ROW_ID 'NAME1' GV_NAME1,
          PO_DATA_CHANGED <LS_INS>-ROW_ID 'EKORG' P_EKORG,
          PO_DATA_CHANGED <LS_INS>-ROW_ID 'EKOTX' GV_EKOTX,
          PO_DATA_CHANGED <LS_INS>-ROW_ID 'EKGRP' P_EKGRP,
          PO_DATA_CHANGED <LS_INS>-ROW_ID 'EKNAM' GV_EKNAM.

  ENDLOOP.


ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_ALV_MODIFY_CELL
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GO_GRID
*&      --> <LS_INS>_ROW_ID
*&      --> P_
*&      --> ABAP_TRUE
*&---------------------------------------------------------------------*
FORM F_ALV_MODIFY_CELL  USING   PO_CHANGE TYPE REF TO CL_ALV_CHANGED_DATA_PROTOCOL
                                 PV_ROW_ID
                                 PV_FNAME
                                 PV_FVALUE.

  CALL METHOD PO_CHANGE->MODIFY_CELL
    EXPORTING
      I_ROW_ID    = PV_ROW_ID
      I_FIELDNAME = PV_FNAME
      I_VALUE     = PV_FVALUE.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_CREATE_ALV_OBJECT_300
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_CREATE_ALV_OBJECT_300 .
  GO_CONT_300 = NEW #( CONTAINER_NAME = 'CON300' ).
  GO_GRID_300 = NEW #( I_PARENT = GO_CONT_300 ).
ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_SET_EXCL_300
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_SET_EXCL_300 .

  GT_EXCL_300[] = VALUE #( ( CL_GUI_ALV_GRID=>MC_FC_LOC_UNDO  )
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
*& Form F_SET_LAYO_300
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_SET_LAYO_300 .

  CLEAR:
    GS_LAYO_300.

  GS_LAYO_300-SEL_MODE   = GC_A.
*  GS_LAYO_300-CWIDTH_OPT = ABAP_TRUE.
  GS_LAYO_300-ZEBRA      = ABAP_TRUE.
  GS_LAYO_300-SMALLTITLE = ABAP_TRUE.
  GS_LAYO_300-STYLEFNAME = 'ZSTYLE'.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_SET_VARI_300
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_SET_VARI_300 .

  CLEAR:
    GS_VARI_300.

  GS_VARI_300-REPORT = SY-REPID.
  GS_VARI_300-HANDLE = 'HD03'.
  GS_VARI_300-USERNAME = SY-UNAME.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_SET_FCAT_300
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_SET_FCAT_300 .

  CLEAR GT_FCAT_300.

  PERFORM F_CREATE_FCAT_BY_ITAB USING GT_OPT2 CHANGING GT_FCAT_300.
  PERFORM F_ADJ_FCAT_300.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_ADJ_FCAT_300
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_ADJ_FCAT_300 .

  CHECK GT_FCAT_300[] IS NOT INITIAL.

  LOOP AT GT_FCAT_300 ASSIGNING FIELD-SYMBOL(<LS_FCAT>).
    CASE <LS_FCAT>-FIELDNAME.
      WHEN 'STATUS'. ""상태
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H44 CHANGING <LS_FCAT>."
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
      WHEN 'BANFN'. ""구매 요청 번호
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H01 CHANGING <LS_FCAT>."
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
        <LS_FCAT>-HOTSPOT = ABAP_TRUE.
      WHEN 'BNFPO'. ""품목
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H02 CHANGING <LS_FCAT>."
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
      WHEN 'KNTTP'. ""계정 지정범주
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H29 CHANGING <LS_FCAT>."
        <LS_FCAT>-REF_TABLE = 'EBAN'.
        <LS_FCAT>-REF_FIELD = 'KNTTP'.
        <LS_FCAT>-INTLEN = <LS_FCAT>-OUTPUTLEN.
        <LS_FCAT>-OUTPUTLEN = 6.
      WHEN 'KNTTX'. ""계정지정범주 내역
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H30 CHANGING <LS_FCAT>."
        <LS_FCAT>-INTLEN = <LS_FCAT>-OUTPUTLEN.
        <LS_FCAT>-OUTPUTLEN = 15.
      WHEN 'MATNR'. ""자재번호
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H06 CHANGING <LS_FCAT>."
        <LS_FCAT>-REF_TABLE = 'EBAN'.
        <LS_FCAT>-REF_FIELD = 'MATNR'.
        <LS_FCAT>-INTLEN = <LS_FCAT>-OUTPUTLEN.
        <LS_FCAT>-OUTPUTLEN = 15.
      WHEN 'MAKTX'. ""자재내역
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H07 CHANGING <LS_FCAT>."
        <LS_FCAT>-INTLEN = <LS_FCAT>-OUTPUTLEN.
        <LS_FCAT>-OUTPUTLEN = 30.
      WHEN 'MATKL'. ""자재그룹
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H45 CHANGING <LS_FCAT>."
        <LS_FCAT>-REF_TABLE = 'MARA'.
        <LS_FCAT>-REF_FIELD = 'MATKL'.
        <LS_FCAT>-INTLEN = <LS_FCAT>-OUTPUTLEN.
        <LS_FCAT>-OUTPUTLEN = 10.
      WHEN 'WGBEZ'. ""자재그룹 내역
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H46 CHANGING <LS_FCAT>."
      WHEN 'WERKS'. ""플랜트
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H08 CHANGING <LS_FCAT>."
        <LS_FCAT>-REF_TABLE = 'EBAN'.
        <LS_FCAT>-REF_FIELD = 'WERKS'.
        <LS_FCAT>-INTLEN = <LS_FCAT>-OUTPUTLEN.
        <LS_FCAT>-OUTPUTLEN = 6.
      WHEN 'NAME1'. ""플랜트명
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H09 CHANGING <LS_FCAT>."
        <LS_FCAT>-INTLEN = <LS_FCAT>-OUTPUTLEN.
        <LS_FCAT>-OUTPUTLEN = 15.
      WHEN 'LGORT'. ""저장위치
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H10 CHANGING <LS_FCAT>."
        <LS_FCAT>-REF_TABLE = 'EBAN'.
        <LS_FCAT>-REF_FIELD = 'LGORT'.
        <LS_FCAT>-INTLEN = <LS_FCAT>-OUTPUTLEN.
        <LS_FCAT>-OUTPUTLEN = 6.
      WHEN 'LGOBE'. ""저장위치명
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H11 CHANGING <LS_FCAT>."
        <LS_FCAT>-INTLEN = <LS_FCAT>-OUTPUTLEN.
        <LS_FCAT>-OUTPUTLEN = 15.
      WHEN 'MENGE'. ""요청 수량
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H12 CHANGING <LS_FCAT>."
        <LS_FCAT>-INTLEN = <LS_FCAT>-OUTPUTLEN.
        <LS_FCAT>-OUTPUTLEN = 12.
      WHEN 'MEINS'. ""요청 단위
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H13 CHANGING <LS_FCAT>."
        <LS_FCAT>-REF_TABLE = 'EBAN'.
        <LS_FCAT>-REF_FIELD = 'MEINS'.
        <LS_FCAT>-INTLEN = <LS_FCAT>-OUTPUTLEN.
        <LS_FCAT>-OUTPUTLEN = 7.
      WHEN 'LFDAT'. ""납품 요청일
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H14 CHANGING <LS_FCAT>."
        <LS_FCAT>-REF_TABLE = 'EBAN'.
        <LS_FCAT>-REF_FIELD = 'LFDAT'.
      WHEN 'EKORG'. ""구매조직
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H19 CHANGING <LS_FCAT>."
        <LS_FCAT>-REF_TABLE = 'EBAN'.
        <LS_FCAT>-REF_FIELD = 'EKORG'.
        <LS_FCAT>-INTLEN = <LS_FCAT>-OUTPUTLEN.
        <LS_FCAT>-OUTPUTLEN = 7.
      WHEN 'EKOTX'. ""구매조직 내역
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H20 CHANGING <LS_FCAT>."
      WHEN 'EKGRP'. ""구매그룹
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H21 CHANGING <LS_FCAT>."
        <LS_FCAT>-REF_TABLE = 'EBAN'.
        <LS_FCAT>-REF_FIELD = 'EKGRP'.
        <LS_FCAT>-INTLEN = <LS_FCAT>-OUTPUTLEN.
        <LS_FCAT>-OUTPUTLEN = 7.
      WHEN 'EKNAM'. ""구매그룹 내역
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H22 CHANGING <LS_FCAT>."
      WHEN 'AFNAM'. ""요청자
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H28 CHANGING <LS_FCAT>."
      WHEN 'LIFNR'. ""희망 공급업체
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H23 CHANGING <LS_FCAT>."
        <LS_FCAT>-REF_TABLE = 'EBAN'.
        <LS_FCAT>-REF_FIELD = 'LIFNR'.
      WHEN 'FLIEF'. ""고정 공급업체
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H24 CHANGING <LS_FCAT>."
        <LS_FCAT>-REF_TABLE = 'EBAN'.
        <LS_FCAT>-REF_FIELD = 'FLIEF'.
      WHEN 'PREIS'. ""예상 가격
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H15 CHANGING <LS_FCAT>."
      WHEN 'WAERS'. ""가격 통화
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H16 CHANGING <LS_FCAT>."
      WHEN 'PEINH'. ""가격 단위
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H17 CHANGING <LS_FCAT>."
      WHEN 'ZAMT'. ""요청 금액
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H18 CHANGING <LS_FCAT>."
        <LS_FCAT>-INTLEN = <LS_FCAT>-OUTPUTLEN.
        <LS_FCAT>-OUTPUTLEN = 16.
      WHEN 'KOSTL'. ""코스트센터
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H35 CHANGING <LS_FCAT>."
        <LS_FCAT>-REF_TABLE = 'CSKS'.
        <LS_FCAT>-REF_FIELD = 'KOSTL'.
        <LS_FCAT>-CHECKTABLE = '!'.
      WHEN 'KOSTL_TEXT'. ""코스트센터 명
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H36 CHANGING <LS_FCAT>."
      WHEN 'SAKTO'. ""G/L 계정
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H37 CHANGING <LS_FCAT>."
        <LS_FCAT>-REF_TABLE = 'EBKN'.
        <LS_FCAT>-REF_FIELD = 'SAKTO'.
        <LS_FCAT>-CHECKTABLE = '!'.
      WHEN 'SAKTO_TEXT'. ""G/L 계정내역
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H38 CHANGING <LS_FCAT>."
      WHEN 'ANLN1'. ""자산번호
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H33 CHANGING <LS_FCAT>."
        <LS_FCAT>-REF_TABLE = 'EBKN'.
        <LS_FCAT>-REF_FIELD = 'ANLN1'.
        <LS_FCAT>-CHECKTABLE = '!'.
      WHEN 'TXT50'. ""자산명
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H34 CHANGING <LS_FCAT>."
        <LS_FCAT>-OUTPUTLEN = 25.
      WHEN 'AUFNR'. ""오더번호
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H39 CHANGING <LS_FCAT>."
        <LS_FCAT>-REF_TABLE = 'EBKN'.
        <LS_FCAT>-REF_FIELD = 'AUFNR'.
        <LS_FCAT>-CHECKTABLE = '!'.
      WHEN 'AUFNR_TEXT'. ""오더 내역
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H40 CHANGING <LS_FCAT>."
        <LS_FCAT>-OUTPUTLEN = 25.
      WHEN 'PS_PSP_PNR'. ""WBS 코드
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H41 CHANGING <LS_FCAT>."
        <LS_FCAT>-REF_TABLE = 'COBL'.
        <LS_FCAT>-REF_FIELD = 'PS_PSP_PNR'.
        <LS_FCAT>-CHECKTABLE = '!'.
        <LS_FCAT>-INTLEN = <LS_FCAT>-OUTPUTLEN.
        <LS_FCAT>-OUTPUTLEN = 15.
        <LS_FCAT>-JUST = 'L'.
      WHEN 'POST1'. ""WBS 내역
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H42 CHANGING <LS_FCAT>."
        <LS_FCAT>-OUTPUTLEN = 25.
      WHEN 'ABLAD'. ""하역지점
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H49 CHANGING <LS_FCAT>."
        <LS_FCAT>-REF_TABLE = 'EBKN'.
        <LS_FCAT>-REF_FIELD = 'ABLAD'.
        <LS_FCAT>-INTLEN = <LS_FCAT>-OUTPUTLEN.
        <LS_FCAT>-OUTPUTLEN = 10.
      WHEN 'WEMPF'. ""수령인
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H50 CHANGING <LS_FCAT>."
        <LS_FCAT>-REF_TABLE = 'EBKN'.
        <LS_FCAT>-REF_FIELD = 'WEMPF'.
        <LS_FCAT>-INTLEN = <LS_FCAT>-OUTPUTLEN.
        <LS_FCAT>-OUTPUTLEN = 10.
      WHEN 'MESSAGE'. ""처리 메시지
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H43 CHANGING <LS_FCAT>."
        <LS_FCAT>-OUTPUTLEN = 30.
      WHEN 'ITEMTEXT'. ""품목 텍스트
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H54 CHANGING <LS_FCAT>."
        <LS_FCAT>-INTLEN = <LS_FCAT>-OUTPUTLEN.
        <LS_FCAT>-OUTPUTLEN = 30.

      WHEN 'MWSKZ'. ""세금코드
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H58 CHANGING <LS_FCAT>."
        <LS_FCAT>-F4AVAILABL = ABAP_TRUE.
        <LS_FCAT>-OUTPUTLEN = 8.
      WHEN 'LIFNR_TEXT'. ""희망 공급업체 명
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H56 CHANGING <LS_FCAT>."
        <LS_FCAT>-OUTPUTLEN = 20.
      WHEN 'FLIEF_TEXT'. ""고정 공급업체 명
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H57 CHANGING <LS_FCAT>."
        <LS_FCAT>-OUTPUTLEN = 20.


      WHEN OTHERS.
        <LS_FCAT>-TECH = ABAP_TRUE.
    ENDCASE.

    CASE <LS_FCAT>-FIELDNAME.
      WHEN 'PREIS' OR 'ZAMT'.
        <LS_FCAT>-CFIELDNAME = 'WAERS'.
    ENDCASE.

    CASE <LS_FCAT>-FIELDNAME.
      WHEN 'KNTTP' OR 'MATNR' OR 'MATKL' OR 'WERKS' OR 'LGORT' OR 'MENGE'
        OR 'MEINS' OR 'LFDAT' OR 'EKORG' OR 'EKGRP' OR 'AFNAM' OR 'LIFNR' OR 'FLIEF'
        OR 'PREIS' OR 'WAERS' OR 'PEINH' OR'PREIS' OR 'KOSTL' OR 'SAKTO' OR 'ANLN1' OR 'AUFNR'
        OR 'PS_PSP_PNR' OR 'ABLAD' OR 'WEMPF'
        OR 'MAKTX' OR 'ITEMTEXT' OR 'MWSKZ'.
        <LS_FCAT>-EDIT = ABAP_TRUE.
    ENDCASE.

  ENDLOOP.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_SET_ALV_EVENT_300
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_SET_ALV_EVENT_300 .

  GO_GRID_300->REGISTER_EDIT_EVENT( CL_GUI_ALV_GRID=>MC_EVT_MODIFIED ).

  DATA(LT_LVC_T_F4) = VALUE LVC_T_F4( ( FIELDNAME = 'MWSKZ' REGISTER = ABAP_TRUE ) ).
  CALL METHOD GO_GRID_300->REGISTER_F4_FOR_FIELDS
    EXPORTING
      IT_F4 = LT_LVC_T_F4.

  CREATE OBJECT GO_EVENT_300.
  SET HANDLER GO_EVENT_300->HANDLE_HOTSPOT_CLICK FOR GO_GRID_300.
  SET HANDLER GO_EVENT_300->HANDLE_TOOLBAR FOR GO_GRID_300.
  SET HANDLER GO_EVENT_300->HANDLE_USER_COMMAND FOR GO_GRID_300.
  SET HANDLER GO_EVENT_300->HANDLE_DATA_CHANGED FOR GO_GRID_300.
  SET HANDLER GO_EVENT_300->HANDLE_DATA_CHANGED_FINISHED FOR GO_GRID_300.
  SET HANDLER GO_EVENT_300->HANDLE_ON_F4 FOR GO_GRID_300.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_SET_ALV_SORT_300
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_SET_ALV_SORT_300 .

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_DISPLAY_ALV_300
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_DISPLAY_ALV_300 .

  CALL METHOD GO_GRID_300->SET_TABLE_FOR_FIRST_DISPLAY
    EXPORTING
      IS_LAYOUT            = GS_LAYO_300
      IT_TOOLBAR_EXCLUDING = GT_EXCL_300[]
      IS_VARIANT           = GS_VARI_300
      I_SAVE               = GV_ASAVE_300
    CHANGING
      IT_OUTTAB            = GT_OPT2[]
      IT_FIELDCATALOG      = GT_FCAT_300[]
      IT_SORT              = GT_SORT_300[]
    EXCEPTIONS
      OTHERS               = 4.

  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
          WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_HOTSPOT_CLICK_300
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> ES_ROW_NO_ROW_ID
*&      --> E_COLUMN_ID
*&      --> SENDER
*&---------------------------------------------------------------------*
FORM F_HOTSPOT_CLICK_300  USING PS_ROW_ID TYPE INT4
                                               PS_COLUMN TYPE LVC_S_COL
                                               PO_SENDER.

  CHECK PS_ROW_ID IS NOT INITIAL.

  CASE PS_COLUMN-FIELDNAME.
    WHEN 'BANFN'. "구매요청
      READ TABLE GT_OPT2 ASSIGNING FIELD-SYMBOL(<LS_OPT2>) INDEX PS_ROW_ID.
      CHECK SY-SUBRC EQ 0.
      CHECK <LS_OPT2>-BANFN IS NOT INITIAL.
      SET PARAMETER ID 'BAN' FIELD <LS_OPT2>-BANFN.
      CALL TRANSACTION 'ME53N'.
  ENDCASE.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_TOOLBAR_300
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> E_OBJECT
*&      --> SENDER
*&---------------------------------------------------------------------*
FORM F_TOOLBAR_300  USING  PR_OBJ TYPE REF TO CL_ALV_EVENT_TOOLBAR_SET
                                     PO_SENDER.

  DATA : LS_TBAR TYPE STB_BUTTON.

  DEFINE _SET_TBAR.
    CLEAR : ls_tbar.

    ls_tbar-butn_type = &1.
    ls_tbar-function   = &2.
    ls_tbar-icon           = &3.
    ls_tbar-text          = &4.
    ls_tbar-quickinfo = &4.

    APPEND ls_tbar TO pr_obj->mt_toolbar.
  END-OF-DEFINITION.

  _SET_TBAR 3 '    ' '              ' '    '.
  _SET_TBAR 0 'INSR'  ICON_INSERT_ROW   TEXT-BT1.
  _SET_TBAR 0 'DELE' ICON_DELETE_ROW  TEXT-BT2.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_USER_COMMAND_300
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> E_UCOMM
*&---------------------------------------------------------------------*
FORM F_USER_COMMAND_300  USING PV_UCOMM TYPE SY-UCOMM.

  CASE PV_UCOMM.
    WHEN 'INSR'. "행 추가
      PERFORM F_INSERT_ROW_300.
    WHEN 'DELE'. "행 삭제
      PERFORM F_DELETE_ROW_300.
  ENDCASE.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_INSERT_ROW_300
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_INSERT_ROW_300 .

  DATA LV_CHECK TYPE C LENGTH 1.
  CALL METHOD GO_GRID_300->CHECK_CHANGED_DATA
    IMPORTING
      E_VALID = LV_CHECK.

  SELECT SINGLE
    WAERS
    FROM T001
    WHERE BUKRS EQ @P_BUKRS
    INTO @DATA(LV_WAERS).

  APPEND VALUE #( STATUS = SPACE PEINH = 1 WAERS = LV_WAERS
                             WERKS = P_WERKS
                             NAME1 = GV_NAME1
                             EKORG = P_EKORG
                             EKOTX = GV_EKOTX
                             EKGRP = P_EKGRP
                             EKNAM = GV_EKNAM ) TO GT_OPT2.

  PERFORM F_REFRESH_ALV USING GO_GRID_300.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_DELETE_ROW_300
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_DELETE_ROW_300 .

  DATA:
    LV_ROW_ID  TYPE INT4,
    LV_DEL_CNT TYPE INT4,
    LV_CHECK   TYPE C LENGTH 1,
    LT_ROW_ID  TYPE LVC_T_ROID.

  FIELD-SYMBOLS:
    <LS_ROW_ID> TYPE LVC_S_ROID,
    <LS_OPT2>   TYPE TY_OPT2.

  CALL METHOD GO_GRID_300->CHECK_CHANGED_DATA
    IMPORTING
      E_VALID = LV_CHECK.

  CHECK LV_CHECK EQ ABAP_TRUE.

  CALL METHOD GO_GRID_300->GET_SELECTED_ROWS
    IMPORTING
      ET_ROW_NO = LT_ROW_ID.

  DELETE LT_ROW_ID WHERE ROW_ID LE 0.

*3. 삭제 버튼
*	3-1) 라인은 다중선택 가능 (전체선택 포함)
*	3-2) 선택한 라인이 없는 경우 하단 에러 메시지 "선택한 데이터가 없습니다."
*	3-3) 선택한 라인에 BANFN 값이 있으면 하단 에러 메시지 "생성된 구매요청이 존재합니다."
*	3-3) 선택한 라인에 BANFN 값이 없으면 선택 라인 데이터 삭제 처리
  IF LT_ROW_ID[] IS INITIAL.
    MESSAGE S163 DISPLAY LIKE GC_E.
    EXIT.
  ENDIF.

  LOOP AT LT_ROW_ID ASSIGNING <LS_ROW_ID>.
    LV_ROW_ID = <LS_ROW_ID>-ROW_ID - LV_DEL_CNT.
    READ TABLE GT_OPT2 ASSIGNING <LS_OPT2> INDEX LV_ROW_ID.
    CHECK SY-SUBRC EQ 0.
    IF <LS_OPT2>-BANFN IS NOT INITIAL.
      MESSAGE S000 DISPLAY LIKE GC_E WITH TEXT-E02. "생성된 구매요청이 존재합니다.
      LV_CHECK = GC_E.
      EXIT.
    ENDIF.
  ENDLOOP.

  CHECK LV_CHECK NE GC_E. "오류 메세지 없는 경우 진행

  LOOP AT LT_ROW_ID ASSIGNING <LS_ROW_ID>.
    LV_ROW_ID = <LS_ROW_ID>-ROW_ID - LV_DEL_CNT.
    READ TABLE GT_OPT2 ASSIGNING <LS_OPT2> INDEX LV_ROW_ID.
    CHECK SY-SUBRC EQ 0.

    DELETE GT_OPT2 INDEX LV_ROW_ID.
    LV_DEL_CNT += 1.
    CONTINUE.

  ENDLOOP.

  PERFORM F_REFRESH_ALV USING GO_GRID_300.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_DATA_CHANGED_300
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> ER_DATA_CHANGED
*&---------------------------------------------------------------------*
FORM F_DATA_CHANGED_300  USING  PO_DATA_CHANGED TYPE REF TO CL_ALV_CHANGED_DATA_PROTOCOL.

  CHECK PO_DATA_CHANGED->MT_INSERTED_ROWS[] IS NOT INITIAL.

  "신규
  SELECT SINGLE
    WAERS
    FROM T001
    WHERE BUKRS EQ @P_BUKRS
    INTO @DATA(LV_WAERS).

  LOOP AT PO_DATA_CHANGED->MT_INSERTED_ROWS ASSIGNING FIELD-SYMBOL(<LS_INS>).
    PERFORM F_ALV_MODIFY_CELL USING:
          PO_DATA_CHANGED <LS_INS>-ROW_ID 'PEINH' 1,
          PO_DATA_CHANGED <LS_INS>-ROW_ID 'WAERS' LV_WAERS,
          PO_DATA_CHANGED <LS_INS>-ROW_ID 'WERKS' P_WERKS,
          PO_DATA_CHANGED <LS_INS>-ROW_ID 'NAME1' GV_NAME1,
          PO_DATA_CHANGED <LS_INS>-ROW_ID 'EKORG' P_EKORG,
          PO_DATA_CHANGED <LS_INS>-ROW_ID 'EKOTX' GV_EKOTX,
          PO_DATA_CHANGED <LS_INS>-ROW_ID 'EKGRP' P_EKGRP,
          PO_DATA_CHANGED <LS_INS>-ROW_ID 'EKNAM' GV_EKNAM.
  ENDLOOP.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_DATA_CHANGED_FIN_300
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> E_MODIFIED
*&      --> ET_GOOD_CELLS
*&---------------------------------------------------------------------*
FORM F_DATA_CHANGED_FIN_300  USING    PV_MODIFIED TYPE CHAR01
                                     PT_GOOD_CELLS TYPE LVC_T_MODI.

  CHECK PV_MODIFIED EQ ABAP_TRUE.

  FIELD-SYMBOLS <LS_OPT2> TYPE TY_OPT2.

  DATA:
    LV_CHECK TYPE C LENGTH 1,
    LT_FNAME TYPE TY_T_FNAME.

  "자재코드 필드가 변경 된 경우
  LOOP AT PT_GOOD_CELLS ASSIGNING  FIELD-SYMBOL(<LS_G0>)" WHERE FIELDNAME EQ 'MATNR'
                                                              GROUP BY ( ROW_ID = <LS_G0>-ROW_ID )
                                                              ASSIGNING FIELD-SYMBOL(<LS_GROUP>).

    READ TABLE GT_OPT2 ASSIGNING <LS_OPT2> INDEX <LS_GROUP>-ROW_ID.
    CHECK SY-SUBRC EQ 0.

    <LS_OPT2>-BGCHK = SPACE. "변경 시 예산점검 초기화

    CLEAR LT_FNAME.
    LOOP AT GROUP <LS_GROUP> ASSIGNING FIELD-SYMBOL(<LS_CELLS>).
      LT_FNAME = VALUE #( BASE LT_FNAME ( FNAME = <LS_CELLS>-FIELDNAME ) ).
      IF <LS_OPT2>-WAERS NE 'KRW' AND <LS_CELLS>-FIELDNAME EQ 'WAERS'.
        LV_CHECK = ABAP_TRUE.
      ENDIF.
    ENDLOOP.

    "추가 설정 값
    PERFORM F_SET_ETC_VALUES_OPT2 USING LT_FNAME CHANGING <LS_OPT2>.

    "코드 텍스트 설정
    PERFORM F_SET_CODE_TEXT_OPT2 USING LT_FNAME CHANGING <LS_OPT2>.

  ENDLOOP.

*
**  3) 입력값이 KRW 가 아니면 메시지 하단 알림 메시지 처리
**"KRW 기준 통화와 금액으로 입력하세요."
  IF LV_CHECK EQ ABAP_TRUE.
    MESSAGE I000 DISPLAY LIKE GC_W WITH TEXT-W01.
  ENDIF.

  PERFORM F_REFRESH_ALV USING GO_GRID_300.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_SET_CODE_TEXT_OPT2
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LT_FNAME
*&      <-- <LS_OPT2>
*&---------------------------------------------------------------------*
FORM F_SET_CODE_TEXT_OPT2  USING  PT_FNAME TYPE TY_T_FNAME
                           CHANGING CS_OPT2 TYPE TY_OPT2.

  "계정 지정 범주
  READ TABLE PT_FNAME WITH TABLE KEY FNAME = 'KNTTP' TRANSPORTING NO FIELDS.
  IF SY-SUBRC EQ 0.
    CLEAR CS_OPT2-KNTTX. "초기화
    READ TABLE GT_T163I ASSIGNING FIELD-SYMBOL(<LS_T163I>) WITH TABLE KEY KNTTP = CS_OPT2-KNTTP.
    IF SY-SUBRC EQ 0.
      CS_OPT2-KNTTX = <LS_T163I>-KNTTX.
    ENDIF.
  ENDIF.

  "자재 그룹
  READ TABLE PT_FNAME WITH TABLE KEY FNAME = 'MATKL' TRANSPORTING NO FIELDS.
  IF SY-SUBRC EQ 0.
    CLEAR CS_OPT2-WGBEZ. "초기화
    READ TABLE GT_T023T ASSIGNING FIELD-SYMBOL(<LS_T023T>) WITH TABLE KEY MATKL = CS_OPT2-MATKL.
    IF SY-SUBRC EQ 0.
      CS_OPT2-WGBEZ = <LS_T023T>-WGBEZ.
    ENDIF.
  ENDIF.

  "플랜트
  READ TABLE PT_FNAME WITH TABLE KEY FNAME = 'WERKS' TRANSPORTING NO FIELDS.
  IF SY-SUBRC EQ 0.
    CLEAR CS_OPT2-NAME1. "초기화
    READ TABLE GT_T001W ASSIGNING FIELD-SYMBOL(<LS_T001W>) WITH TABLE KEY WERKS = CS_OPT2-WERKS.
    IF SY-SUBRC EQ 0.
      CS_OPT2-NAME1 = <LS_T001W>-NAME1.
    ENDIF.
  ENDIF.

  "저장위치
  READ TABLE PT_FNAME WITH TABLE KEY FNAME = 'WERKS' TRANSPORTING NO FIELDS.
  IF SY-SUBRC NE 0.
    READ TABLE PT_FNAME WITH TABLE KEY FNAME = 'LGORT' TRANSPORTING NO FIELDS.
  ENDIF.
  IF SY-SUBRC EQ 0.
    CLEAR CS_OPT2-LGOBE. "초기화
    READ TABLE GT_T001L ASSIGNING FIELD-SYMBOL(<LS_T001L>) WITH TABLE KEY WERKS = CS_OPT2-WERKS
                                                                                                                              LGORT = CS_OPT2-LGORT.
    IF SY-SUBRC EQ 0.
      CS_OPT2-LGOBE = <LS_T001L>-LGOBE.
    ENDIF.
  ENDIF.

  "구매조직
  READ TABLE PT_FNAME WITH TABLE KEY FNAME = 'EKORG' TRANSPORTING NO FIELDS.
  IF SY-SUBRC EQ 0.
    CLEAR CS_OPT2-EKOTX. "초기화
    READ TABLE GT_T024E ASSIGNING FIELD-SYMBOL(<LS_T024E>) WITH TABLE KEY EKORG = CS_OPT2-EKORG.
    IF SY-SUBRC EQ 0.
      CS_OPT2-EKOTX = <LS_T024E>-EKOTX.
    ENDIF.
  ENDIF.

  "구매그룹
  READ TABLE PT_FNAME WITH TABLE KEY FNAME = 'EKGRP' TRANSPORTING NO FIELDS.
  IF SY-SUBRC EQ 0.
    CLEAR CS_OPT2-EKNAM. "초기화
    READ TABLE GT_T024 ASSIGNING FIELD-SYMBOL(<LS_T024>) WITH TABLE KEY EKGRP = CS_OPT2-EKGRP.
    IF SY-SUBRC EQ 0.
      CS_OPT2-EKNAM = <LS_T024>-EKNAM.
    ENDIF.
  ENDIF.

* 희망 공급업체
  READ TABLE PT_FNAME WITH TABLE KEY FNAME = 'LIFNR' TRANSPORTING NO FIELDS.
  IF SY-SUBRC EQ 0.
    CLEAR CS_OPT2-LIFNR_TEXT.
    SELECT SINGLE
      NAME1
      FROM LFA1
      WHERE LIFNR EQ @CS_OPT2-LIFNR
      INTO @CS_OPT2-LIFNR_TEXT.
  ENDIF.

* 고정 공급업체명
  READ TABLE PT_FNAME WITH TABLE KEY FNAME = 'FLIEF' TRANSPORTING NO FIELDS.
  IF SY-SUBRC EQ 0.
    CLEAR CS_OPT2-FLIEF_TEXT.
    SELECT SINGLE
      NAME1
      FROM LFA1
      WHERE LIFNR EQ @CS_OPT2-FLIEF
      INTO @CS_OPT2-FLIEF_TEXT.
  ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_SET_ETC_VALUES_OPT2
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LT_FNAME
*&      <-- <LS_OPT2>
*&---------------------------------------------------------------------*
FORM F_SET_ETC_VALUES_OPT2  USING  PT_FNAME TYPE TY_T_FNAME
                           CHANGING CS_OPT2 TYPE TY_OPT2.

  "자재코드 변경
  READ TABLE PT_FNAME WITH TABLE KEY FNAME = 'MATNR' TRANSPORTING NO FIELDS.
  IF SY-SUBRC EQ 0.
    DELETE CS_OPT2-ZSTYLE[] WHERE FIELDNAME EQ 'MATKL' OR FIELDNAME EQ 'MEINS' OR FIELDNAME EQ 'MAKTX'.
    "자재코드가 입력 된 경우
    IF CS_OPT2-MATNR IS NOT INITIAL.
      "입력 불가 필드 설정
      CS_OPT2-ZSTYLE = VALUE #( BASE CS_OPT2-ZSTYLE ( FIELDNAME = 'MATKL' STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED )
                                                                                         ( FIELDNAME = 'MEINS' STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED ) ).
*                                                                                         ( FIELDNAME = 'MAKTX' STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED ) ).
*비상비 자재인 경우 자재내역은 자재내역으로 기본 값은 보여주고 수정 입력 가능하게 함께 부탁드리겠습니다.
      "자재유형/단위 설정
      CLEAR:
        CS_OPT2-MATKL,
        CS_OPT2-MEINS.

      SELECT SINGLE
        MATKL,
        MEINS
        FROM MARA
        WHERE MATNR EQ @CS_OPT2-MATNR
        INTO ( @CS_OPT2-MATKL, @CS_OPT2-MEINS ).

      "자재유형명 변경
      READ TABLE PT_FNAME WITH TABLE KEY FNAME = 'MATKL' TRANSPORTING NO FIELDS.
      IF SY-SUBRC NE 0.
        PT_FNAME = VALUE #( BASE PT_FNAME ( FNAME = 'MATKL' ) ).
      ENDIF.
    ENDIF.

    "자재 내역
    CLEAR CS_OPT2-MAKTX.
    SELECT SINGLE
      MAKTX
      FROM MAKT
      WHERE MATNR EQ @CS_OPT2-MATNR
      AND SPRAS EQ @SY-LANGU
      INTO @CS_OPT2-MAKTX.
  ENDIF.

  "자재코드 or 플랜트 변경 시
  READ TABLE PT_FNAME WITH TABLE KEY FNAME = 'MATNR' TRANSPORTING NO FIELDS.
  IF SY-SUBRC NE 0.
    READ TABLE PT_FNAME WITH TABLE KEY FNAME = 'WERKS' TRANSPORTING NO FIELDS.
  ENDIF.
  IF SY-SUBRC EQ 0.
    "1) Possible Entry or 입력 가능
*2) MATNR, WERKS 입력값 기준으로 MARC-EKGRP 값으로 보여줌, 수정 가능"
    CLEAR CS_OPT2-EKGRP.
    SELECT SINGLE
      EKGRP
      FROM MARC
      WHERE MATNR EQ @CS_OPT2-MATNR
      AND WERKS EQ @CS_OPT2-WERKS
      INTO @CS_OPT2-EKGRP.

    IF CS_OPT2-EKGRP IS INITIAL.
      CS_OPT2-EKGRP = P_EKGRP.
    ENDIF.

    "구매그룹명 수정
    READ TABLE PT_FNAME WITH TABLE KEY FNAME = 'EKGRP' TRANSPORTING NO FIELDS.
    IF SY-SUBRC NE 0.
      PT_FNAME = VALUE #( BASE PT_FNAME ( FNAME = 'EKGRP' ) ).
    ENDIF.

    "1) MATNR,WERKS 입력값에 따라 자재 단가 조회
*Table: MBEW
*SELECT 조건: STPRS
*WHERE 조건 : MATNR, WERKS
*-> 조회 조건의 BUKRS 값 기준으로 T001-WAERS = ""KRW"" 이면 STPRS*100
*2) 직접 입력 가능"
    CLEAR CS_OPT2-PREIS.
    SELECT SINGLE
      STPRS,
      PEINH
      FROM MBEW
      WHERE MATNR EQ @CS_OPT2-MATNR
      AND BWKEY EQ @CS_OPT2-WERKS
      INTO ( @CS_OPT2-PREIS, @CS_OPT2-PEINH ).

    "예상가격 변경
    READ TABLE PT_FNAME WITH TABLE KEY FNAME = 'PREIS' TRANSPORTING NO FIELDS.
    IF SY-SUBRC NE 0.
      PT_FNAME = VALUE #( BASE PT_FNAME ( FNAME = 'PREIS' ) ).
    ENDIF.
    READ TABLE PT_FNAME WITH TABLE KEY FNAME = 'PEINH' TRANSPORTING NO FIELDS.
    IF SY-SUBRC NE 0.
      PT_FNAME = VALUE #( BASE PT_FNAME ( FNAME = 'PEINH' ) ).
    ENDIF.
  ENDIF.

  "수량/예상가격/가격단위 변경 시 요청금액 계산
*"입력한 MENGE,PREIS,PEINH 기준으로 계산
*= PREIS*MENGE/PEINH"
  READ TABLE PT_FNAME WITH TABLE KEY FNAME = 'MENGE' TRANSPORTING NO FIELDS.
  IF SY-SUBRC NE 0.
    READ TABLE PT_FNAME WITH TABLE KEY FNAME = 'PREIS' TRANSPORTING NO FIELDS.
    IF SY-SUBRC NE 0.
      READ TABLE PT_FNAME WITH TABLE KEY FNAME = 'PEINH' TRANSPORTING NO FIELDS.
    ENDIF.
  ENDIF.
  IF SY-SUBRC EQ 0.
    CLEAR CS_OPT2-ZAMT.
    IF CS_OPT2-PEINH IS NOT INITIAL.
      CS_OPT2-ZAMT = ( CS_OPT2-MENGE * CS_OPT2-PREIS ) / CS_OPT2-PEINH.
    ENDIF.
  ENDIF.

  "코스트센터 명                  KTEXT CSKT-KTEXT  Display KOSTL 입력 값에 따라 해당 텍스트로 보여줌
  READ TABLE PT_FNAME WITH TABLE KEY FNAME = 'KOSTL' TRANSPORTING NO FIELDS.
  IF SY-SUBRC EQ 0.
    CLEAR CS_OPT2-KOSTL_TEXT.
    SELECT SINGLE
      KTEXT
      FROM CSKT
      WHERE KOKRS EQ @P_BUKRS
      AND KOSTL EQ @CS_OPT2-KOSTL
      AND DATBI EQ '99991231'
      AND SPRAS EQ @SY-LANGU
      INTO @CS_OPT2-KOSTL_TEXT.
  ENDIF.

*G/L 계정내역                 TXT20 SKAT-XT20 Display SAKTO 입력 값에 따라 해당 텍스트로 보여줌
  READ TABLE PT_FNAME WITH TABLE KEY FNAME = 'SAKTO' TRANSPORTING NO FIELDS.
  IF SY-SUBRC EQ 0.
    CLEAR CS_OPT2-SAKTO_TEXT.
    SELECT SINGLE
      ST~TXT20
      FROM T001 AS T1
                INNER JOIN
              SKAT AS ST ON T1~KTOPL EQ ST~KTOPL
      WHERE T1~BUKRS EQ @P_BUKRS
      AND ST~SAKNR EQ @CS_OPT2-SAKTO
      AND ST~SPRAS EQ @SY-LANGU
      INTO @CS_OPT2-SAKTO_TEXT.
  ENDIF.

*자산명                  TXT50 ANLA-TXT50  Display ANLN1 입력 값에 따라 해당 텍스트로 보여줌
  READ TABLE PT_FNAME WITH TABLE KEY FNAME = 'ANLN1' TRANSPORTING NO FIELDS.
  IF SY-SUBRC EQ 0.
    CLEAR CS_OPT2-TXT50.
    SELECT SINGLE
      TXT50
      FROM ANLA
      WHERE BUKRS EQ @P_BUKRS
      AND ANLN1 EQ @CS_OPT2-ANLN1
      INTO @CS_OPT2-TXT50.
  ENDIF.

*오더 내역                  KTEXT AUFK-KTEXT  Display AUFNR 입력 값에 따라 해당 텍스트로 보여줌
  READ TABLE PT_FNAME WITH TABLE KEY FNAME = 'AUFNR' TRANSPORTING NO FIELDS.
  IF SY-SUBRC EQ 0.
    CLEAR CS_OPT2-AUFNR_TEXT.
    SELECT SINGLE
      KTEXT
      FROM AUFK
      WHERE AUFNR EQ @CS_OPT2-AUFNR
      INTO @CS_OPT2-AUFNR_TEXT.
  ENDIF.

*WBS 내역                 POST1 PRPS-POST1  Display PS_PSP_PNR 입력 값에 따라 해당 텍스트로 보여줌
  READ TABLE PT_FNAME WITH TABLE KEY FNAME = 'PS_PSP_PNR' TRANSPORTING NO FIELDS.
  IF SY-SUBRC EQ 0.
    CLEAR CS_OPT2-POST1.
    SELECT SINGLE
      POST1
      FROM PRPS
      WHERE PSPNR EQ @CS_OPT2-PS_PSP_PNR
      INTO @CS_OPT2-POST1.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_ON_F4
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> E_FIELDNAME
*&      --> E_FIELDVALUE
*&      --> ES_ROW_NO
*&      --> ER_EVENT_DATA
*&      --> ET_BAD_CELLS
*&      --> E_DISPLAY
*&---------------------------------------------------------------------*
FORM F_ON_F4  USING  PV_FIELDNAME
                 PV_FIELDVALUE
                 PS_ROW_NO     TYPE LVC_S_ROID
                 PO_EVENT_DATA TYPE REF TO CL_ALV_EVENT_DATA
                 PT_BAD_CELLS  TYPE LVC_T_MODI
                 PV_DISPLAY.

  FIELD-SYMBOLS <LS_MODI> TYPE LVC_T_MODI.
  DATA : LT_RETURN TYPE TABLE OF DDSHRETVAL.

  PO_EVENT_DATA->M_EVENT_HANDLED = ABAP_TRUE.

  CASE PV_FIELDNAME.
    WHEN 'MWSKZ'.
      SELECT
        T1~MWSKZ,
        T2~TEXT1
        FROM T007A AS T1
                  INNER JOIN
                T007S AS T2 ON T1~KALSM EQ T2~KALSM
                                AND T1~MWSKZ EQ T2~MWSKZ
                                AND T2~SPRAS EQ @SY-LANGU
        WHERE T1~KALSM EQ 'TAXKR'
        ORDER BY T1~MWSKZ
        INTO TABLE @DATA(LT_MWSKZ).

      CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
        EXPORTING
          RETFIELD   = 'MWSKZ'
          DYNPPROG   = SY-REPID
          DYNPNR     = SY-DYNNR
          VALUE_ORG  = GC_S
*         WINDOW_TITLE = '자재코드' "창이름
        TABLES
          VALUE_TAB  = LT_MWSKZ
          RETURN_TAB = LT_RETURN.

      CHECK LT_RETURN IS NOT INITIAL.

      ASSIGN PO_EVENT_DATA->M_DATA->* TO <LS_MODI>.

      READ TABLE LT_RETURN INTO DATA(LS_RETURN) INDEX 1.
      DATA(LS_MODI) = VALUE LVC_S_MODI( ROW_ID    = PS_ROW_NO-ROW_ID
                                        FIELDNAME = 'MWSKZ'
                                        VALUE     = LS_RETURN-FIELDVAL ).

      APPEND LS_MODI TO <LS_MODI>.

  ENDCASE.
ENDFORM.
