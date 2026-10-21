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
FORM F_CREATE_ALV_OBJECT .

  DATA:
    LO_SPLIT TYPE REF TO CL_GUI_SPLITTER_CONTAINER,
    LO_HCNTR TYPE REF TO CL_GUI_CONTAINER,
    LO_ICNTR TYPE REF TO CL_GUI_CONTAINER.

  GO_CONT = NEW #( CONTAINER_NAME = 'CON100' ).

  IF P_SEND EQ ABAP_TRUE. "전송
    GO_GRID_IT = NEW #( I_PARENT = GO_CONT ).

  ELSE. "로그조회

    "Split Container
    LO_SPLIT = NEW #( PARENT  = GO_CONT
                      ROWS    = 2
                      COLUMNS = 1 ).

    LO_HCNTR = LO_SPLIT->GET_CONTAINER( ROW = 1 COLUMN = 1 ).
    LO_ICNTR = LO_SPLIT->GET_CONTAINER( ROW = 2 COLUMN = 1 ).

    "ALV Obj.
    GO_GRID_HD = NEW #( I_PARENT = LO_HCNTR ).
    GO_GRID_IT = NEW #( I_PARENT = LO_ICNTR ).
  ENDIF.


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
   GT_EXCL_HD[],
   GT_EXCL_IT[].

  GT_EXCL_HD[] = GT_EXCL_IT[] = VALUE #( ( CL_GUI_ALV_GRID=>MC_FC_LOC_UNDO  )
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
    GS_LAYO_HD,
    GS_LAYO_IT.

  GS_LAYO_HD-SEL_MODE   = GC_D.
  GS_LAYO_HD-CWIDTH_OPT = ABAP_TRUE.
  GS_LAYO_HD-ZEBRA      = ABAP_TRUE.
  GS_LAYO_HD-SMALLTITLE = ABAP_TRUE.

  GS_LAYO_IT = GS_LAYO_HD.

  "Header
  CASE ABAP_TRUE.
    WHEN P_SEND. "SEND
      GS_LAYO_HD-GRID_TITLE = TEXT-TT1. "구매요청 헤더정보
    WHEN OTHERS.
      GS_LAYO_HD-GRID_TITLE = TEXT-TT3. "Interface 처리상태
  ENDCASE.

  GS_LAYO_IT-GRID_TITLE = TEXT-TT2. "구매 요청 정보


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
    GS_VARI_HD,
    GS_VARI_IT.

  GS_VARI_HD-REPORT = SY-REPID.
  GS_VARI_HD-HANDLE = 'HD01'.
  GS_VARI_HD-USERNAME = SY-UNAME.

  GS_VARI_IT-REPORT = SY-REPID.
  GS_VARI_IT-HANDLE = 'IT01'.
  GS_VARI_IT-USERNAME = SY-UNAME.

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

  CLEAR:
    GT_FCAT_HD[],
    GT_FCAT_IT[].

  PERFORM F_CREATE_FCAT_BY_ITAB USING GT_HEAD CHANGING GT_FCAT_HD.
  PERFORM F_CREATE_FCAT_BY_ITAB USING GT_ITEM CHANGING GT_FCAT_IT.

  CHECK SY-SUBRC EQ 0.

  PERFORM F_ADJ_FCAT_HD.
  PERFORM F_ADJ_FCAT_IT.

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
*& Form F_ADJ_FCAT_HD
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_ADJ_FCAT_HD .

  CHECK GT_FCAT_HD[] IS NOT INITIAL.

  LOOP AT GT_FCAT_HD ASSIGNING FIELD-SYMBOL(<LS_FCAT>).
    CASE <LS_FCAT>-FIELDNAME.
      WHEN 'ZIFNO'. ""I/F No
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H21 CHANGING <LS_FCAT>."
      WHEN 'ZIFKEY'. ""Interface Key
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H22 CHANGING <LS_FCAT>."
        <LS_FCAT>-HOTSPOT = ABAP_TRUE.
      WHEN 'SYSTEM_ID'. ""I/F 시스템
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H23 CHANGING <LS_FCAT>."
      WHEN 'SYSTEM_TXT'. ""시스템 명
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H24 CHANGING <LS_FCAT>."
      WHEN 'ZSTAT'. ""송수신상태
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H25 CHANGING <LS_FCAT>."
      WHEN 'MESSAGE'. ""송수신메세지
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H26 CHANGING <LS_FCAT>."
      WHEN 'IFNAM'. ""송수신자
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H27 CHANGING <LS_FCAT>."

      WHEN OTHERS.
        <LS_FCAT>-TECH = ABAP_TRUE.
    ENDCASE.
  ENDLOOP.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_ADJ_FCAT_IT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_ADJ_FCAT_IT .

  CHECK GT_FCAT_IT[] IS NOT INITIAL.

  LOOP AT GT_FCAT_IT ASSIGNING FIELD-SYMBOL(<LS_FCAT>).
    CASE <LS_FCAT>-FIELDNAME.
      WHEN 'BANFN'. ""구매 요청 번호
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H01 CHANGING <LS_FCAT>."
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
      WHEN 'BNFPO'. ""품목
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H05 CHANGING <LS_FCAT>."
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
      WHEN 'ERNAM'. ""생성자 ID
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H28 CHANGING <LS_FCAT>."
      WHEN 'ENAME'. ""생성자 이름
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H29 CHANGING <LS_FCAT>."
      WHEN 'MAILADD'. ""생성자 이메일
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H30 CHANGING <LS_FCAT>."
      WHEN 'BSART'. ""문서 유형
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H31 CHANGING <LS_FCAT>."
      WHEN 'BATXT'. ""문서 유형 내역
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H32 CHANGING <LS_FCAT>."
      WHEN 'BADAT'. ""요청일
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H33 CHANGING <LS_FCAT>."
      WHEN 'ERDAT'. ""최종 변경일
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H34 CHANGING <LS_FCAT>."
      WHEN 'MATNR'. ""자재번호
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H06 CHANGING <LS_FCAT>."
      WHEN 'ZZMAKTX80'. ""자재내역
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H07 CHANGING <LS_FCAT>."
      WHEN 'WERKS'. ""플랜트
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H08 CHANGING <LS_FCAT>."
      WHEN 'NAME1'. ""플랜트명
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H35 CHANGING <LS_FCAT>."
      WHEN 'LGORT'. ""저장위치
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H09 CHANGING <LS_FCAT>."
      WHEN 'LGOBE'. ""저장위치 명
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H36 CHANGING <LS_FCAT>."
      WHEN 'PSTLZ'. ""저장위치 우편번호
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H37 CHANGING <LS_FCAT>."
      WHEN 'ORT01'. ""저장위치 주소
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H38 CHANGING <LS_FCAT>."
      WHEN 'STRAS'. ""저장위치 상세주소
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H39 CHANGING <LS_FCAT>."
      WHEN 'MENGE'. ""요청 수량
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H10 CHANGING <LS_FCAT>."
        <LS_FCAT>-QFIELDNAME = 'MEINS'.
      WHEN 'MEINS'. ""요청 단위
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H11 CHANGING <LS_FCAT>."
      WHEN 'LFDAT'. ""납품 요청일
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H12 CHANGING <LS_FCAT>."
      WHEN 'PREIS'. ""예상 가격
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H13 CHANGING <LS_FCAT>."
        <LS_FCAT>-CFIELDNAME = 'WAERS'.
      WHEN 'WAERS'. ""가격 통화
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H14 CHANGING <LS_FCAT>."
      WHEN 'ZAMT'. ""예상 금액
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H15 CHANGING <LS_FCAT>."
        <LS_FCAT>-CFIELDNAME = 'WAERS'.
      WHEN 'PEINH'. ""가격 단위
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H16 CHANGING <LS_FCAT>."
      WHEN 'EKORG'. ""구매조직
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H17 CHANGING <LS_FCAT>."
      WHEN 'EKOTX'. ""구매조직명
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H40 CHANGING <LS_FCAT>."
      WHEN 'EKGRP'. ""구매그룹
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H41 CHANGING <LS_FCAT>."
      WHEN 'EKNAM'. ""구매그룹내역
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H42 CHANGING <LS_FCAT>."
      WHEN 'LIFNR'. ""희망 공급업체
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H18 CHANGING <LS_FCAT>."
      WHEN 'FLIEF'. ""고정 공급업체
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H19 CHANGING <LS_FCAT>."
      WHEN 'LOEKZ'. ""삭제 지시자
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H20 CHANGING <LS_FCAT>."
        <LS_FCAT>-CHECKBOX = ABAP_TRUE.
        <LS_FCAT>-JUST = GC_C.
      WHEN 'ITEMTEXT'. "구매요청 품목 텍스트
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H43 CHANGING <LS_FCAT>."
      WHEN OTHERS.
        <LS_FCAT>-TECH = ABAP_TRUE.
    ENDCASE.

  ENDLOOP.

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

  IF P_ILOG EQ ABAP_TRUE.
    CALL METHOD GO_GRID_HD->SET_TABLE_FOR_FIRST_DISPLAY
      EXPORTING
        IS_LAYOUT            = GS_LAYO_HD
        IT_TOOLBAR_EXCLUDING = GT_EXCL_HD[]
        IS_VARIANT           = GS_VARI_HD
        I_SAVE               = GV_ASAVE
      CHANGING
        IT_OUTTAB            = GT_HEAD[]
        IT_FIELDCATALOG      = GT_FCAT_HD[]
        IT_SORT              = GT_SORT_HD[]
      EXCEPTIONS
        OTHERS               = 4.

    IF SY-SUBRC <> 0.
      MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.
  ENDIF.

  CALL METHOD GO_GRID_IT->SET_TABLE_FOR_FIRST_DISPLAY
    EXPORTING
      IS_LAYOUT            = GS_LAYO_IT
      IT_TOOLBAR_EXCLUDING = GT_EXCL_IT[]
      IS_VARIANT           = GS_VARI_IT
      I_SAVE               = GV_ASAVE
    CHANGING
      IT_OUTTAB            = GT_ITEM[]
      IT_FIELDCATALOG      = GT_FCAT_IT[]
      IT_SORT              = GT_SORT_IT[]
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
*& Form F_HOTSPOT_CLICK
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> E_ROW_ID
*&      --> E_COLUMN_ID
*&      --> SENDER
*&---------------------------------------------------------------------*
FORM F_HOTSPOT_CLICK  USING PS_ROW_ID TYPE INT4
                                               PS_COLUMN TYPE LVC_S_COL
                                               PO_SENDER.

  CHECK PS_ROW_ID IS NOT INITIAL.

  CASE PS_COLUMN-FIELDNAME.
    WHEN 'ZIFKEY'. "I/F Key
      READ TABLE GT_HEAD ASSIGNING FIELD-SYMBOL(<LS_HEAD>) INDEX PS_ROW_ID.
      CHECK SY-SUBRC EQ 0.

      PERFORM F_SET_ALV_DATA_ITEM_LOG USING <LS_HEAD>-ZIFKEY
                                                                             <LS_HEAD>-SYSTEM_ID.

      PERFORM F_REFRESH_ALV USING GO_GRID_IT.

  ENDCASE.

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

  CHECK P_ILOG EQ ABAP_TRUE. "로그 조회인 경우만
  CREATE OBJECT GO_EVENT.
  SET HANDLER GO_EVENT->HANDLE_HOTSPOT_CLICK FOR GO_GRID_HD.

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
    GT_SORT_HD[],
    GT_SORT_IT[].

  GT_SORT_IT = VALUE #( BASE GT_SORT_IT ( SPOS = 1 FIELDNAME = 'BANFN' UP = ABAP_TRUE DOWN = SPACE ) ).
  GT_SORT_IT = VALUE #( BASE GT_SORT_IT ( SPOS = 2 FIELDNAME = 'BNFPO' UP = ABAP_TRUE DOWN = SPACE ) ).


  CHECK P_ILOG EQ ABAP_TRUE. "로그 조회 인 경우만
  GT_SORT_HD = VALUE #( BASE GT_SORT_HD ( SPOS = 1 FIELDNAME = 'ZIFKEY' UP = SPACE DOWN = ABAP_TRUE ) ).

ENDFORM.
