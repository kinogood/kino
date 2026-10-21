*&---------------------------------------------------------------------*
*& Include          ZGTMMR2020F02
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form F_CREATE_ALV_OBJECT_100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_CREATE_ALV_OBJECT_100 .

  DATA:
    LO_SPLIT TYPE REF TO CL_GUI_SPLITTER_CONTAINER,
    LO_CNTR  TYPE REF TO CL_GUI_CONTAINER.

*  GO_CONT_100 = NEW #( CONTAINER_NAME = 'CON100' ).

  GO_CONT_100 = NEW #(
      SIDE      = CL_GUI_DOCKING_CONTAINER=>DOCK_AT_TOP
      EXTENSION = 2000
    ).
  "Split Container
  LO_SPLIT = NEW #( PARENT  = GO_CONT_100
                    ROWS    = 1
                    COLUMNS = 1 ).

  LO_CNTR = LO_SPLIT->GET_CONTAINER( ROW = 1 COLUMN = 1 ).

  "ALV Obj.
  GO_GRID_100 = NEW #( I_PARENT = LO_CNTR ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form F_SET_EXCL_100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_SET_EXCL_100 .

  CLEAR:
   GT_EXCL_100.

  GT_EXCL_100[] = VALUE #( ( CL_GUI_ALV_GRID=>MC_FC_LOC_UNDO  )
                       ( CL_GUI_ALV_GRID=>MC_FC_LOC_COPY )
                       ( CL_GUI_ALV_GRID=>MC_FC_LOC_COPY_ROW )
                       ( CL_GUI_ALV_GRID=>MC_FC_LOC_CUT )
                       ( CL_GUI_ALV_GRID=>MC_FC_LOC_DELETE_ROW )
                       ( CL_GUI_ALV_GRID=>MC_FC_LOC_INSERT_ROW )
                       ( CL_GUI_ALV_GRID=>MC_FC_LOC_APPEND_ROW )
                       ( CL_GUI_ALV_GRID=>MC_FC_LOC_PASTE )
                       ( CL_GUI_ALV_GRID=>MC_FC_LOC_PASTE_NEW_ROW )
*                       ( CL_GUI_ALV_GRID=>MC_MB_EXPORT )
                       ( CL_GUI_ALV_GRID=>MC_FC_REFRESH )
                       ( CL_GUI_ALV_GRID=>MC_FC_INFO ) ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form F_SET_LAYO_100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_SET_LAYO_100 .

  CLEAR:
    GS_LAYO_100.

  GS_LAYO_100-SEL_MODE = GC_A.
*  GS_LAYO_100-CWIDTH_OPT = ABAP_TRUE.
  GS_LAYO_100-ZEBRA = ABAP_TRUE.
  GS_LAYO_100-SMALLTITLE = ABAP_TRUE.
  GS_LAYO_100-STYLEFNAME = 'ZSTYLE'.
  GS_LAYO_100-NO_ROWMOVE = ABAP_TRUE.
  GS_LAYO_100-NO_ROWINS = ABAP_TRUE.
*  GS_LAYO_100-GRID_TITLE = TEXT-AT1.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form F_SET_VARI_100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_SET_VARI_100 .
  CLEAR:
    GS_VARI_100.

  GS_VARI_100-REPORT = SY-REPID.
  GS_VARI_100-USERNAME = SY-UNAME.

  CASE ABAP_TRUE.
    WHEN P_NEW.
      GS_VARI_100-HANDLE = 'ALD1'.
    WHEN P_DISP.
      GS_VARI_100-HANDLE = 'ALD2'.
    WHEN P_PRINT.
      GS_VARI_100-HANDLE = 'ALD3'.
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form F_SET_FCAT_100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_SET_FCAT_100 .

  PERFORM F_CREATE_FCAT_BY_ITAB USING GT_SKID CHANGING GT_FCAT_100.

  PERFORM F_ADJ_FCAT_100.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form F_CREATE_FCAT_BY_ITAB
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_SKID
*&      <-- GT_FCAT_100
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
*& Form F_ADJ_FCAT_100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_ADJ_FCAT_100 .

  LOOP AT GT_FCAT_100 ASSIGNING FIELD-SYMBOL(<LS_FCAT>).
    CASE <LS_FCAT>-FIELDNAME.
      WHEN 'STATUS'. ""점검
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H01 CHANGING <LS_FCAT>."
        <LS_FCAT>-ICON = ABAP_TRUE.
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
        <LS_FCAT>-KEY = ABAP_TRUE.
        <LS_FCAT>-OUTPUTLEN = 3.
        CASE ABAP_TRUE.
          WHEN P_PRINT.
            <LS_FCAT>-NO_OUT = ABAP_TRUE.
        ENDCASE.

      WHEN 'VBELN'.   "판매문서
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H02 CHANGING <LS_FCAT>.
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
        <LS_FCAT>-REF_TABLE = 'VBAK'.
        <LS_FCAT>-REF_FIELD = 'VBELN'.
        <LS_FCAT>-KEY = ABAP_TRUE.
        <LS_FCAT>-HOTSPOT = ABAP_TRUE.

      WHEN 'POSNR'.   "판매문서 항목
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H03 CHANGING <LS_FCAT>.
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
        <LS_FCAT>-KEY = ABAP_TRUE.
        <LS_FCAT>-OUTPUTLEN = 3.

      WHEN 'BANFN'.   "구매요청번호
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H04 CHANGING <LS_FCAT>.
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
        <LS_FCAT>-REF_TABLE = 'EBAN'.
        <LS_FCAT>-REF_FIELD = 'BANFN'.
        <LS_FCAT>-HOTSPOT = ABAP_TRUE.

      WHEN 'BNFPO'.   "구매요청품목
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H53 CHANGING <LS_FCAT>.
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
        <LS_FCAT>-OUTPUTLEN = 3.

      WHEN 'EBELN'.   "구매오더번호
        CASE ABAP_TRUE.
          WHEN P_NEW.
            <LS_FCAT>-NO_OUT = ABAP_TRUE.
        ENDCASE.
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H05 CHANGING <LS_FCAT>.
        <LS_FCAT>-JUST = GC_C.
*        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
        <LS_FCAT>-REF_TABLE = 'EKKO'.
        <LS_FCAT>-REF_FIELD = 'EBELN'.
        <LS_FCAT>-HOTSPOT = ABAP_TRUE.

      WHEN 'CHECK'.   "선택
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H06 CHANGING <LS_FCAT>.
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
        <LS_FCAT>-CHECKBOX = ABAP_TRUE.
        <LS_FCAT>-OUTPUTLEN = 4.
        CASE ABAP_TRUE.
          WHEN P_NEW.
            <LS_FCAT>-EDIT = SPACE.
          WHEN OTHERS.
            <LS_FCAT>-EDIT = ABAP_TRUE.
        ENDCASE.

      WHEN 'LFDAT'.   "납품 요청일(PR)
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H07 CHANGING <LS_FCAT>.
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
        <LS_FCAT>-REF_TABLE = 'EBAN'.
        <LS_FCAT>-REF_FIELD = 'LFDAT'.
        CASE ABAP_TRUE.
          WHEN P_NEW.
            <LS_FCAT>-EDIT = ABAP_TRUE.
        ENDCASE.

      WHEN 'MATNR'.   "품목(자재번호)
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H08 CHANGING <LS_FCAT>.
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
        <LS_FCAT>-REF_TABLE = 'MARA'.
        <LS_FCAT>-REF_FIELD = 'MATNR'.
        <LS_FCAT>-OUTPUTLEN = 12.
        <LS_FCAT>-INTLEN = 40.

      WHEN 'ARKTX'.   "품목(내역)
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H09 CHANGING <LS_FCAT>.
*        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
        <LS_FCAT>-OUTPUTLEN = 20.

      WHEN 'SUL_NO'.   "설계번호
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H10 CHANGING <LS_FCAT>.
        <LS_FCAT>-OUTPUTLEN = 12.

      WHEN 'REV_SEQ'.   "개정번호
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H11 CHANGING <LS_FCAT>.
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-OUTPUTLEN = 3.

      WHEN 'COLOR'.   "색상
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H12 CHANGING <LS_FCAT>.
        <LS_FCAT>-JUST = GC_C.

      WHEN 'KUNNR'.   "판매처
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H13 CHANGING <LS_FCAT>.
        <LS_FCAT>-REF_TABLE = 'KNA1'.
        <LS_FCAT>-REF_FIELD = 'KUNNR'.

      WHEN 'NAME1'.   "내역
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H14 CHANGING <LS_FCAT>.
        <LS_FCAT>-OUTPUTLEN = 20.

      WHEN 'EDATU'.   "납품요청일(SO)
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H15 CHANGING <LS_FCAT>.
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-REF_TABLE = 'VBEP'.
        <LS_FCAT>-REF_FIELD = 'EDATU'.

      WHEN 'KWMENG'.   "오더수량
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H16 CHANGING <LS_FCAT>.
        <LS_FCAT>-QFIELDNAME = 'VRKME'.
        <LS_FCAT>-OUTPUTLEN = 10.

      WHEN 'WELENG'.   "조장(판매단위)
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H17 CHANGING <LS_FCAT>.
        <LS_FCAT>-QFIELDNAME = 'VRKME'.
        <LS_FCAT>-OUTPUTLEN = 10.

      WHEN 'WECNT'.   "조장수
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H20 CHANGING <LS_FCAT>.
        <LS_FCAT>-OUTPUTLEN = 4.

      WHEN 'VRKME'.   "판매단위
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H18 CHANGING <LS_FCAT>.
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-OUTPUTLEN = 5.

      WHEN 'MEINS'.   "기본단위
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H19 CHANGING <LS_FCAT>.
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-NO_OUT = ABAP_TRUE.
        <LS_FCAT>-OUTPUTLEN = 5.

      WHEN 'BRGEW_DRUM'.   "드럼중량
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H21 CHANGING <LS_FCAT>.
        <LS_FCAT>-QFIELDNAME = 'GEWEI_DRUM'.
        <LS_FCAT>-NO_OUT = ABAP_TRUE.
        <LS_FCAT>-OUTPUTLEN = 10.

      WHEN 'GEWEI_DRUM'.   "드럼중량 단위
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H22 CHANGING <LS_FCAT>.
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-NO_OUT = ABAP_TRUE.
        <LS_FCAT>-OUTPUTLEN = 5.

      WHEN 'NTGEW'.   "실중량
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H23 CHANGING <LS_FCAT>.
        <LS_FCAT>-QFIELDNAME = 'GEWEI'.
        <LS_FCAT>-EMPHASIZE = GC_C500.
        <LS_FCAT>-OUTPUTLEN = 10.

      WHEN 'NTGEW_SUM'.   "실중량합
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H24 CHANGING <LS_FCAT>.
        <LS_FCAT>-QFIELDNAME = 'GEWEI'.
        <LS_FCAT>-EMPHASIZE = GC_C500.
        <LS_FCAT>-OUTPUTLEN = 10.

      WHEN 'BRGEW'.   "중량
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H25 CHANGING <LS_FCAT>.
        <LS_FCAT>-QFIELDNAME = 'GEWEI'.
        <LS_FCAT>-EMPHASIZE = GC_C500.
        <LS_FCAT>-OUTPUTLEN = 10.

      WHEN 'BRGEW_SUM'.   "중량합
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H26 CHANGING <LS_FCAT>.
        <LS_FCAT>-QFIELDNAME = 'GEWEI'.
        <LS_FCAT>-EMPHASIZE = GC_C500.
        <LS_FCAT>-OUTPUTLEN = 10.

      WHEN 'GEWEI'.   "중량 단위
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H27 CHANGING <LS_FCAT>.
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-OUTPUTLEN = 5.

      WHEN 'BARREL_DIA'.   "동경(mm)
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H28 CHANGING <LS_FCAT>.
        <LS_FCAT>-DECIMALS_O = 0.
        <LS_FCAT>-EMPHASIZE = GC_C500.

      WHEN 'OUT_WID'.   "외폭(mm)
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H29 CHANGING <LS_FCAT>.
        <LS_FCAT>-DECIMALS_O = 0.
        <LS_FCAT>-EMPHASIZE = GC_C500.

      WHEN 'FAR'.   "용적률(TOTAL)"
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H30 CHANGING <LS_FCAT>.
        <LS_FCAT>-EMPHASIZE = GC_C500.
        <LS_FCAT>-OUTPUTLEN = 8.

      WHEN 'MATNR_DRUM'.   "드럼
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H31 CHANGING <LS_FCAT>.
        <LS_FCAT>-REF_TABLE = 'MARA'.
        <LS_FCAT>-REF_FIELD = 'MATNR'.
        <LS_FCAT>-OUTPUTLEN = 12.
        <LS_FCAT>-INTLEN = 40.

      WHEN 'MAKTX_DRUM'.   "드럼내역
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H32 CHANGING <LS_FCAT>.
        <LS_FCAT>-OUTPUTLEN = 15.

      WHEN 'MATNR_SKID'.   "SKID
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H33 CHANGING <LS_FCAT>.
        <LS_FCAT>-REF_TABLE = 'MARA'.
        <LS_FCAT>-REF_FIELD = 'MATNR'.
        <LS_FCAT>-OUTPUTLEN = 12.
        <LS_FCAT>-INTLEN = 40.

      WHEN 'MAKTX_SKID'.   "SKID내역
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H34 CHANGING <LS_FCAT>.
        <LS_FCAT>-OUTPUTLEN = 15.

      WHEN 'BARREL_DIA_1'.   "H1(전)
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H35 CHANGING <LS_FCAT>.
        <LS_FCAT>-DECIMALS_O = 0.
        <LS_FCAT>-EMPHASIZE = GC_C300.
        <LS_FCAT>-OUTPUTLEN = 8.

      WHEN 'OUT_WID_1'.   "W1(전)
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H36 CHANGING <LS_FCAT>.
        <LS_FCAT>-DECIMALS_O = 0.
        <LS_FCAT>-EMPHASIZE = GC_C300.
        <LS_FCAT>-OUTPUTLEN = 8.

      WHEN 'BRGEW_1'.   "net중량(전)
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H37 CHANGING <LS_FCAT>.
        <LS_FCAT>-QFIELDNAME = 'GEWEI'.
        <LS_FCAT>-DECIMALS_O = 0.
        <LS_FCAT>-EMPHASIZE = GC_C300.
        <LS_FCAT>-OUTPUTLEN = 8.

      WHEN 'CHORD_A'.   "참고치(A)
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H38 CHANGING <LS_FCAT>.
        <LS_FCAT>-DECIMALS_O = 0.
        <LS_FCAT>-EMPHASIZE = GC_C300.
        <LS_FCAT>-OUTPUTLEN = 8.

      WHEN 'WECNT_1'.   "수량
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H39 CHANGING <LS_FCAT>.
        <LS_FCAT>-EMPHASIZE = GC_C300.
        <LS_FCAT>-OUTPUTLEN = 4.

      WHEN 'MEINS_SKID'.   "기본단위
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H19 CHANGING <LS_FCAT>.
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-OUTPUTLEN = 5.

      WHEN 'BARREL_DIA_2'.   "H2(후)
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H40 CHANGING <LS_FCAT>.
        <LS_FCAT>-DECIMALS_O = 0.
        <LS_FCAT>-EMPHASIZE = GC_C300.
        <LS_FCAT>-OUTPUTLEN = 8.

      WHEN 'OUT_WID_2'.   "W2(후)
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H41 CHANGING <LS_FCAT>.
        <LS_FCAT>-DECIMALS_O = 0.
        <LS_FCAT>-EMPHASIZE = GC_C300.
        <LS_FCAT>-OUTPUTLEN = 8.

      WHEN 'BRGEW_2'.   "net중량(후)
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H42 CHANGING <LS_FCAT>.
        <LS_FCAT>-QFIELDNAME = 'GEWEI'.
        <LS_FCAT>-DECIMALS_O = 0.
        <LS_FCAT>-EMPHASIZE = GC_C300.
        <LS_FCAT>-OUTPUTLEN = 8.

      WHEN 'VKORG'.   "영업 조직
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H43 CHANGING <LS_FCAT>.
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-REF_TABLE = 'TVKO'.
        <LS_FCAT>-REF_FIELD = 'VKORG'.

      WHEN 'VTWEG'.   "유통 경로
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H44 CHANGING <LS_FCAT>.
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-NO_OUT = ABAP_TRUE.

      WHEN 'SPART'.   "제품군
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H45 CHANGING <LS_FCAT>.
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-NO_OUT = ABAP_TRUE.

      WHEN 'VKGRP'.   "영업 그룹
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H46 CHANGING <LS_FCAT>.
        <LS_FCAT>-JUST = GC_C.

      WHEN 'VKBUR'.   "영업팀
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H47 CHANGING <LS_FCAT>.
        <LS_FCAT>-JUST = GC_C.

      WHEN 'WERKS'.   "플랜트
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H52 CHANGING <LS_FCAT>.
        <LS_FCAT>-JUST = GC_C.

      WHEN 'CUOBJ'.   "구성(오브젝트 번호)
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H48 CHANGING <LS_FCAT>.
        <LS_FCAT>-NO_OUT = ABAP_TRUE.

      WHEN 'SKID_YN'.   "SKID 사용유무
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H49 CHANGING <LS_FCAT>.
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-NO_OUT = ABAP_TRUE.

      WHEN 'PACKMARK'.   "포장재/마킹지정상태표시
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H50 CHANGING <LS_FCAT>.
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-NO_OUT = ABAP_TRUE.

      WHEN 'MESSAGE'.   "메시지
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H51 CHANGING <LS_FCAT>.
        <LS_FCAT>-OUTPUTLEN = 50.

        "<--2026.06.25 비상비 구매로 변경
      WHEN 'KNTTP'.   "계정지정범주
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H57 CHANGING <LS_FCAT>.
        <LS_FCAT>-REF_TABLE = 'T163K'.
        <LS_FCAT>-REF_FIELD = 'KNTTP'.
        <LS_FCAT>-NO_OUT = ABAP_TRUE.

      WHEN 'KOSTL'.   "코스트센터
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H54 CHANGING <LS_FCAT>.
        <LS_FCAT>-REF_TABLE = 'CSKS'.
        <LS_FCAT>-REF_FIELD = 'KOSTL'.
        <LS_FCAT>-OUTPUTLEN = 10.

      WHEN 'SAKTO'.   "G/L 계정
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H55 CHANGING <LS_FCAT>.
        <LS_FCAT>-REF_TABLE = 'SKA1'.
        <LS_FCAT>-REF_FIELD = 'SAKNR'.
        <LS_FCAT>-OUTPUTLEN = 10.

      WHEN 'LIFNR'.   "희망공급업체
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H56 CHANGING <LS_FCAT>.
        <LS_FCAT>-REF_TABLE = 'LFA1'.
        <LS_FCAT>-REF_FIELD = 'LIFNR'.
        <LS_FCAT>-OUTPUTLEN = 10.

      WHEN OTHERS.
        <LS_FCAT>-NO_OUT = ABAP_TRUE.
        "2026.06.25 비상비 구매로 변경-->

    ENDCASE.

  ENDLOOP.




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
*& Form F_SET_ALV_EVENT_100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_SET_ALV_EVENT_100 .
  GO_GRID_100->REGISTER_EDIT_EVENT( CL_GUI_ALV_GRID=>MC_EVT_MODIFIED ).

  CREATE OBJECT GCL_EVENT_100.

  SET HANDLER:
    GCL_EVENT_100->HANDLE_HOTSPOT_CLICK FOR GO_GRID_100,
    GCL_EVENT_100->HANDLE_TOOLBAR FOR GO_GRID_100,
    GCL_EVENT_100->HANDLE_USER_COMMAND FOR GO_GRID_100,
    GCL_EVENT_100->HANDLE_DATA_CHANGED_FINISHED FOR GO_GRID_100.

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
  READ TABLE GT_SKID ASSIGNING FIELD-SYMBOL(<LS_SKID>) INDEX PS_ROW_ID.
  CHECK SY-SUBRC EQ 0.

  CASE PS_COLUMN-FIELDNAME.
    WHEN 'VBELN'. "판매문서 조회
      IF <LS_SKID>-VBELN IS NOT INITIAL.
        SET PARAMETER ID 'AUN' FIELD <LS_SKID>-VBELN.
        CALL TRANSACTION 'VA03' AND SKIP FIRST SCREEN.
      ENDIF.

    WHEN 'BANFN'. "구매요청 조회
      IF <LS_SKID>-BANFN IS NOT INITIAL.
        SET PARAMETER ID 'BAN' FIELD <LS_SKID>-BANFN.
        CALL TRANSACTION 'ME53N' AND SKIP FIRST SCREEN.
      ENDIF.

    WHEN 'EBELN'. "구매오더 조회
      IF <LS_SKID>-EBELN IS NOT INITIAL.
        CALL FUNCTION 'ME_DISPLAY_PURCHASE_DOCUMENT'
          EXPORTING
            I_EBELN = <LS_SKID>-EBELN.
      ENDIF.
  ENDCASE.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form F_TOOLBAR_100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> E_OBJECT
*&---------------------------------------------------------------------*
FORM F_TOOLBAR_100  USING  PR_OBJ TYPE REF TO CL_ALV_EVENT_TOOLBAR_SET.

*  CHECK P_NEW EQ ABAP_TRUE. "신규(구매요청 생성) 모드인 경우만

  DATA : LS_TBAR TYPE STB_BUTTON.

  DEFINE _SET_TBAR.
    CLEAR : LS_TBAR.

    LS_TBAR-BUTN_TYPE = &1.
    LS_TBAR-FUNCTION   = &2.
    LS_TBAR-ICON           = &3.
    LS_TBAR-TEXT          = &4.
    LS_TBAR-QUICKINFO = &5.

    APPEND LS_TBAR TO PR_OBJ->MT_TOOLBAR.
  END-OF-DEFINITION.

  _SET_TBAR 3 SPACE SPACE SPACE SPACE.

  IF P_NEW EQ ABAP_TRUE.
    _SET_TBAR 0 'DATE' ICON_CHANGE   TEXT-BT1 TEXT-BT2.
  ELSEIF P_DISP EQ ABAP_TRUE OR P_PRINT EQ ABAP_TRUE.
    _SET_TBAR 0 'CHK' ICON_CHANGE   TEXT-BT3 TEXT-BT3.
  ENDIF.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form F_USER_COMMAND_100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> E_UCOMM
*&---------------------------------------------------------------------*
FORM F_USER_COMMAND_100  USING PV_UCOMM TYPE SY-UCOMM.

  CASE PV_UCOMM.
    WHEN 'DATE'. "납품요청일 일괄 입력
      PERFORM F_ENTER_DATE_100.

    WHEN 'CHK'.
      PERFORM F_ENTER_CHK_100.

  ENDCASE.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form F_DATA_CHANGED_FIN_100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> E_MODIFIED
*&      --> ET_GOOD_CELLS
*&---------------------------------------------------------------------*
FORM F_DATA_CHANGED_FIN_100  USING    PV_MODIFIED TYPE CHAR01
                                     PT_GOOD_CELLS TYPE LVC_T_MODI.

  CHECK PV_MODIFIED EQ ABAP_TRUE.

  FIELD-SYMBOLS <LS_SKID> TYPE TY_SKID.

  LOOP AT PT_GOOD_CELLS ASSIGNING  FIELD-SYMBOL(<LS_G0>)
                                                                GROUP BY ( ROW_ID = <LS_G0>-ROW_ID )
                                                                ASSIGNING FIELD-SYMBOL(<LS_GROUP>).

    " 입고요청일 여부에 따라 CHECK 표시/해제
    READ TABLE GT_SKID ASSIGNING <LS_SKID> INDEX <LS_GROUP>-ROW_ID.
    CHECK SY-SUBRC EQ 0.

    PERFORM F_SET_CHECK_GT_SKID CHANGING <LS_SKID>.
    PERFORM F_SET_ALV_STYLE_GT_SKID CHANGING <LS_SKID>.

  ENDLOOP.
  PERFORM F_REFRESH_ALV USING GO_GRID_100.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form F_REFRESH_ALV
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GO_GRID_100
*&---------------------------------------------------------------------*
FORM F_REFRESH_ALV  USING   PO_GRID TYPE REF TO CL_GUI_ALV_GRID.

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
*& Form F_DISPLAY_ALV_100
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
      IT_OUTTAB            = GT_SKID[]
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
*& Form F_ENTER_DATE_100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_ENTER_DATE_100 .
  DATA:
    LV_ROW_ID TYPE INT4,
    LV_CHECK  TYPE C LENGTH 1,
    LT_ROW_ID TYPE LVC_T_ROID.

  CALL METHOD GO_GRID_100->CHECK_CHANGED_DATA
    IMPORTING
      E_VALID = LV_CHECK.

  CHECK LV_CHECK EQ ABAP_TRUE.

  CALL METHOD GO_GRID_100->GET_SELECTED_ROWS
    IMPORTING
      ET_ROW_NO = LT_ROW_ID.

  DELETE LT_ROW_ID WHERE ROW_ID LE 0.
  CHECK LT_ROW_ID[] IS NOT INITIAL.

  CLEAR GS_SCR_101.
  CALL SCREEN 101 STARTING AT 1 4.

  CHECK GS_SCR_101-ZCHK EQ ABAP_TRUE.


  LOOP AT LT_ROW_ID ASSIGNING FIELD-SYMBOL(<LS_ROW_ID>).
    READ TABLE GT_SKID ASSIGNING FIELD-SYMBOL(<LS_SKID>)  INDEX <LS_ROW_ID>-ROW_ID.
    CHECK SY-SUBRC EQ 0.

    IF <LS_SKID>-BANFN IS INITIAL.  "구매요청번호가 없는 경우
      <LS_SKID>-LFDAT = GS_SCR_101-LFDAT.
      <LS_SKID>-CHECK = ABAP_TRUE.
    ENDIF.

  ENDLOOP.

  PERFORM F_REFRESH_ALV USING GO_GRID_100.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form F_ENTER_CHK_100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_ENTER_CHK_100 .

  DATA:
    LV_ROW_ID TYPE INT4,
    LV_CHECK  TYPE C LENGTH 1,
    LT_ROW_ID TYPE LVC_T_ROID.

  CALL METHOD GO_GRID_100->CHECK_CHANGED_DATA
    IMPORTING
      E_VALID = LV_CHECK.

  CHECK LV_CHECK EQ ABAP_TRUE.

  CALL METHOD GO_GRID_100->GET_SELECTED_ROWS
    IMPORTING
      ET_ROW_NO = LT_ROW_ID.

  DELETE LT_ROW_ID WHERE ROW_ID LE 0.
  CHECK LT_ROW_ID[] IS NOT INITIAL.

  LOOP AT LT_ROW_ID ASSIGNING FIELD-SYMBOL(<LS_ROW_ID>).
    READ TABLE GT_SKID ASSIGNING FIELD-SYMBOL(<LS_SKID>)  INDEX <LS_ROW_ID>-ROW_ID.
    CHECK SY-SUBRC EQ 0.

    CASE ABAP_TRUE.
      WHEN P_DISP.
        " 구매요청 존재 + 구매오더 미존재 시에만 체크 가능
        IF <LS_SKID>-EBELN IS INITIAL AND <LS_SKID>-BANFN IS NOT INITIAL.
          <LS_SKID>-CHECK = ABAP_TRUE.
        ENDIF.

      WHEN P_PRINT.
        " 인쇄에서는 상관없이 체크 가능
        <LS_SKID>-CHECK = ABAP_TRUE.
    ENDCASE.
  ENDLOOP.

  PERFORM F_REFRESH_ALV USING GO_GRID_100.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form F_CREATE_PR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_CREATE_PR .
  DATA:
    LT_SKID_CHK TYPE TY_T_SKID,
    LV_ROW_ID   TYPE INT4,
    LV_CHECK    TYPE C LENGTH 1.

  CALL METHOD GO_GRID_100->CHECK_CHANGED_DATA
    IMPORTING
      E_VALID = LV_CHECK.

  CHECK LV_CHECK EQ ABAP_TRUE.

  " MOVE CHECKED DATA
  LT_SKID_CHK = VALUE #( FOR LS_SKID IN GT_SKID WHERE ( CHECK = ABAP_TRUE ) ( LS_SKID ) ).

  IF LT_SKID_CHK[] IS INITIAL.
    MESSAGE S000 DISPLAY LIKE GC_E WITH TEXT-E03.
    EXIT.
  ENDIF.

  " 체크된 LINE 중 구매요청/구매오더번호 있는 경우
  SELECT SINGLE @ABAP_TRUE
    FROM @LT_SKID_CHK AS Z1
  WHERE ( BANFN NE @SPACE OR EBELN NE @SPACE )
    INTO @DATA(LV_CHK).

  IF LV_CHK EQ ABAP_TRUE.
    MESSAGE S000 DISPLAY LIKE GC_E WITH TEXT-E01.
    EXIT.
  ENDIF.

  " 체크된 LINE 중 납기요청일 없는 경우
  SELECT SINGLE @ABAP_TRUE
    FROM @LT_SKID_CHK AS Z1
  WHERE LFDAT IS INITIAL
    INTO @DATA(LV_CHK2).

  IF LV_CHK2 EQ ABAP_TRUE.
    MESSAGE S000 DISPLAY LIKE GC_E WITH TEXT-E02.
    EXIT.
  ENDIF.

  " 체크된 LINE 중 계정/코스트센터 없는 경우
  SELECT SINGLE @ABAP_TRUE
    FROM @LT_SKID_CHK AS Z1
  WHERE SAKTO IS INITIAL
       OR KOSTL IS INITIAL
    INTO @DATA(LV_CHK3).

  IF LV_CHK3 EQ ABAP_TRUE.
    MESSAGE S000 DISPLAY LIKE GC_E WITH TEXT-E06.
    EXIT.
  ENDIF.

  "POP UP TO CONFIRM
*구매요청을 생성하시겠습니까? (예/아니오)"
  DATA LV_ANS TYPE C LENGTH 1.
  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      TITLEBAR      = TEXT-TT1 "확인
      TEXT_QUESTION = TEXT-Q01
    IMPORTING
      ANSWER        = LV_ANS.
  CHECK LV_ANS EQ GC_1.

  CLEAR LV_CHECK.

  " 2026.06.25 비상비 구매로 전환 - 예산 점검 로직 추가
  " -> PR 단에서 단가 입력되지 않으므로 예산 점검은 PO단에서 하기로 협의. 주석처리함
*  PERFORM F_CHECK_BUDGET USING LT_SKID_CHK CHANGING LV_CHECK..

  "결과 필드 초기화
  PERFORM F_REFRESH_RESULT.

  "BAPI 실행
  PERFORM F_CREATE_PR_BAPI USING LT_SKID_CHK CHANGING LV_CHECK.

  PERFORM F_REFRESH_ALV USING GO_GRID_100.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form F_CANCEL_PR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_CANCEL_PR .
  DATA:
    LT_SKID_CHK TYPE TY_T_SKID,
    LV_ROW_ID   TYPE INT4,
    LV_CHECK    TYPE C LENGTH 1.

  CALL METHOD GO_GRID_100->CHECK_CHANGED_DATA
    IMPORTING
      E_VALID = LV_CHECK.

  CHECK LV_CHECK EQ ABAP_TRUE.

  " MOVE CHECKED DATA
  LT_SKID_CHK = VALUE #( FOR LS_SKID IN GT_SKID WHERE ( CHECK = ABAP_TRUE ) ( LS_SKID ) ).

  IF LT_SKID_CHK[] IS INITIAL.
    MESSAGE S000 DISPLAY LIKE GC_E WITH TEXT-E03.
    EXIT.
  ENDIF.

  " 체크된 LINE 중 구매오더번호 있는 경우
  SELECT SINGLE @ABAP_TRUE
    FROM @LT_SKID_CHK AS Z1
  WHERE ( EBELN NE @SPACE )
    INTO @DATA(LV_CHK).

  IF LV_CHK EQ ABAP_TRUE.
    MESSAGE S000 DISPLAY LIKE GC_E WITH TEXT-E05.
    EXIT.
  ENDIF.

  "POP UP TO CONFIRM
*구매요청을 종결하시겠습니까? (예/아니오)"
  DATA LV_ANS TYPE C LENGTH 1.
  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      TITLEBAR      = TEXT-TT1 "확인
      TEXT_QUESTION = TEXT-Q02
    IMPORTING
      ANSWER        = LV_ANS.
  CHECK LV_ANS EQ GC_1.

  CLEAR LV_CHECK.

  "결과 필드 초기화
  PERFORM F_REFRESH_RESULT.

  "BAPI 실행
  PERFORM F_CANCEL_PR_BAPI  USING LT_SKID_CHK CHANGING LV_CHECK.

  PERFORM F_REFRESH_ALV USING GO_GRID_100.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form F_CREATE_PR_BAPI
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- LV_CHECK
*&---------------------------------------------------------------------*
FORM F_CREATE_PR_BAPI  USING PT_SKID_CHK TYPE TY_T_SKID
                                          CHANGING CV_CHECK.
  DATA:
    LV_CHECK       TYPE C LENGTH 1,
    LT_SKID_CHK    TYPE TY_T_SKID,
    LV_COUNT       TYPE N LENGTH 5,
    LV_SLOC        TYPE LGORT_D,
    LV_STR         TYPE STRING,
    "--헤더
    LS_PRHEADER    TYPE  BAPIMEREQHEADER,
    LS_PRHEADERX   TYPE BAPIMEREQHEADERX,
    "--아이템
    LT_PRITEM      TYPE STANDARD TABLE OF BAPIMEREQITEMIMP,
    LT_PRITEMX     TYPE STANDARD TABLE OF BAPIMEREQITEMX,
    LT_PRACCOUNT   TYPE STANDARD TABLE OF BAPIMEREQACCOUNT,
    LT_PRACCOUNTX  TYPE STANDARD TABLE OF BAPIMEREQACCOUNTX,
    "--결과
    LS_NUMBER      TYPE BAPIMEREQHEADER-PREQ_NO,
    LS_PRHEADEREXP TYPE BAPIMEREQHEADER,
    LS_RETURN      TYPE BAPIRET2,
    LT_RETURN      TYPE STANDARD TABLE OF BAPIRET2,
    "--CBO
    LT_MM2020      TYPE STANDARD TABLE OF ZGTMMT2020.


  FIELD-SYMBOLS:
    <LS_RETURN> TYPE BAPIRET2,
    <LS_SKID>   TYPE TY_SKID.

*  " 영업조직별 코드마스터 SELECT
*  SELECT SINGLE *
*    FROM ZGTPPT1010
*   WHERE MODULE_KIND = 'MM'
*       AND CODEGRP = '0750'
*       AND FLD_01 = @P_VKORG
*    INTO @DATA(gs_1010).

  " 요청자 이름 추출
  SELECT SINGLE AD~NAME_TEXT
     FROM USR21 AS UR
      LEFT OUTER JOIN ADRP AS AD ON UR~PERSNUMBER EQ AD~PERSNUMBER
   WHERE UR~BNAME EQ @SY-UNAME
       INTO @DATA(LV_NAME).

  " PR HEADER DATA 생성
  CLEAR:
    LS_PRHEADER,
    LS_PRHEADERX,
    LS_NUMBER.

  LS_PRHEADER-PR_TYPE = GC_NB. "오더 유형
  LS_PRHEADERX-PR_TYPE = ABAP_TRUE. "오더 유형

  " PR ITEM DATA 생성
  LOOP AT PT_SKID_CHK  ASSIGNING FIELD-SYMBOL(<LS_SKID_CHK>).
    CLEAR: LV_SLOC.

    LV_COUNT += 10.   "품목번호
    <LS_SKID_CHK>-BNFPO = LV_COUNT. "CHECK 테이블에 품목번호 할당

*    "--저장위치 할당
*    SELECT SINGLE *
*      FROM ZGTPPT1010
*     WHERE MODULE_KIND = 'MM'
*         AND CODEGRP = '0750'
*         AND FLD_01 = @P_VKORG
*         AND FLD_02 = @<LS_SKID_CHK>-WERKS
*      INTO @LS_1010.

    "-- PRITEM 추가
    APPEND VALUE #(
        PREQ_ITEM  = LV_COUNT
        PUR_GROUP  = <LS_SKID_CHK>-EKGRP
        PREQ_NAME  = LV_NAME
        MATERIAL   = <LS_SKID_CHK>-MATNR_SKID
        PLANT      = <LS_SKID_CHK>-WERKS
        STORE_LOC      = <LS_SKID_CHK>-LGORT
        QUANTITY   = <LS_SKID_CHK>-WECNT
        UNIT   = <LS_SKID_CHK>-MEINS_SKID
        DELIV_DATE = <LS_SKID_CHK>-LFDAT
        ACCTASSCAT = <LS_SKID_CHK>-KNTTP
        PURCH_ORG  = <LS_SKID_CHK>-EKORG
        DES_VENDOR = <LS_SKID_CHK>-LIFNR         "2026.06.25 추가
        TAX_CODE = <LS_SKID_CHK>-MWSKZ        "2026.06.25 추가
        PRICE_UNIT = <LS_SKID_CHK>-PEINH         "2026.06.25 추가
    ) TO LT_PRITEM.

    "-- PRITEMX 추가
    APPEND VALUE #(
        PREQ_ITEM   = LV_COUNT
        PREQ_ITEMX  = ABAP_TRUE
        PUR_GROUP   = ABAP_TRUE
        PREQ_NAME   = ABAP_TRUE
        MATERIAL    = ABAP_TRUE
        PLANT       = ABAP_TRUE
        STORE_LOC      = ABAP_TRUE
        QUANTITY    = ABAP_TRUE
        UNIT    = ABAP_TRUE
        DELIV_DATE  = ABAP_TRUE
        ACCTASSCAT  = ABAP_TRUE
        PURCH_ORG   = ABAP_TRUE
        DES_VENDOR = ABAP_TRUE         "2026.06.25 추가
        TAX_CODE = ABAP_TRUE         "2026.06.25 추가
        PRICE_UNIT = ABAP_TRUE        "2026.06.25 추가
    ) TO LT_PRITEMX.

    "-- PRACCOUNT 추가
    APPEND VALUE #(
        PREQ_ITEM  = LV_COUNT
        SERIAL_NO  = GC_01
*        SD_DOC     = <LS_SKID_CHK>-VBELN   "2026.06.25 제거
*        ITM_NUMBER = <LS_SKID_CHK>-POSNR "2026.06.25 제거
        COSTCENTER = <LS_SKID_CHK>-KOSTL         "2026.06.25 추가
        GL_ACCOUNT = <LS_SKID_CHK>-SAKTO         "2026.06.25 추가
        UNLOAD_PT = <LS_SKID_CHK>-ABLAD        "2026.06.25 추가

    ) TO LT_PRACCOUNT.

    "-- PRACCOUNTX 추가
    APPEND VALUE #(
        PREQ_ITEM   = LV_COUNT
        PREQ_ITEMX  = ABAP_TRUE
        SERIAL_NO   = GC_01
        SERIAL_NOX   = ABAP_TRUE
*        SD_DOC      = ABAP_TRUE        "2026.06.25 제거
*        ITM_NUMBER  = ABAP_TRUE       "2026.06.25 제거
        COSTCENTER = ABAP_TRUE         "2026.06.25 추가
        GL_ACCOUNT = ABAP_TRUE         "2026.06.25 추가
        UNLOAD_PT = ABAP_TRUE         "2026.06.25 추가
    ) TO LT_PRACCOUNTX.

  ENDLOOP.

  IF LT_PRITEM[] IS NOT INITIAL.

    CALL FUNCTION 'BAPI_PR_CREATE'
      EXPORTING
        PRHEADER    = LS_PRHEADER
        PRHEADERX   = LS_PRHEADERX
      IMPORTING
        NUMBER      = LS_NUMBER
        PRHEADEREXP = LS_PRHEADEREXP
      TABLES
        RETURN      = LT_RETURN
        PRITEM      = LT_PRITEM
        PRITEMX     = LT_PRITEMX
        PRACCOUNT   = LT_PRACCOUNT
        PRACCOUNTX  = LT_PRACCOUNTX.

    " 결과 CHECK
    READ TABLE LT_RETURN ASSIGNING <LS_RETURN> WITH KEY TYPE = GC_E.

    "실패 시 -> 롤백 + STATUS
    IF SY-SUBRC EQ 0.
      LV_CHECK = GC_E.
      LS_RETURN = <LS_RETURN>.
      CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

      " STATUS 할당
      LOOP AT PT_SKID_CHK  ASSIGNING <LS_SKID_CHK>.
        READ TABLE GT_SKID ASSIGNING <LS_SKID>
                                          WITH KEY VBELN = <LS_SKID_CHK>-VBELN POSNR = <LS_SKID_CHK>-POSNR.
        <LS_SKID>-STATUS =  ICON_LED_RED.
      ENDLOOP.

      LV_STR = |({ LS_RETURN-ID }-{ LS_RETURN-NUMBER })|.
      MESSAGE S000 DISPLAY LIKE GC_E WITH LV_STR LS_RETURN-MESSAGE.
      EXIT.

      " 성공 시 -> CBO 저장 후 COMMIT -> PR 승인 요청 메일 전송
    ELSE.
      "--ZGTMMT2020 MODIFY
      MOVE-CORRESPONDING PT_SKID_CHK  TO LT_MM2020.

      LOOP AT LT_MM2020 ASSIGNING FIELD-SYMBOL(<LS_MM2020>).

        "신규 / 수정여부 판별
        SELECT SINGLE *
          FROM ZGTMMT2020
          WHERE VBELN EQ @<LS_MM2020>-VBELN
          AND POSNR EQ @<LS_MM2020>-POSNR
          INTO @DATA(LS_DATE).

        <LS_MM2020> = VALUE #( BASE <LS_MM2020>
          " 공통 필드 (수정)
          BANFN       = LS_NUMBER
          AEDAT       = SY-DATUM
          AEDAT_LOCAL = SY-DATLO
          AETIM       = SY-UZEIT
          AETIM_LOCAL = SY-TIMLO
          AENAM       = SY-UNAME

          " 신규인 경우
          ERDAT       = COND #( WHEN LS_DATE IS INITIAL THEN SY-DATUM ELSE LS_DATE-ERDAT )
          ERDAT_LOCAL = COND #( WHEN LS_DATE IS INITIAL THEN SY-DATLO ELSE LS_DATE-ERDAT_LOCAL )
          ERTIM       = COND #( WHEN LS_DATE IS INITIAL THEN SY-UZEIT ELSE LS_DATE-ERTIM )
          ERTIM_LOCAL = COND #( WHEN LS_DATE IS INITIAL THEN SY-TIMLO ELSE LS_DATE-ERTIM_LOCAL )
          ERNAM       = COND #( WHEN LS_DATE IS INITIAL THEN SY-UNAME ELSE LS_DATE-ERNAM )
        ).

        CLEAR LS_DATE.
      ENDLOOP.

      MODIFY ZGTMMT2020 FROM TABLE LT_MM2020.
      IF SY-SUBRC EQ 0.
        LV_CHECK = GC_S.
        "Commit
        CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
          EXPORTING
            WAIT = ABAP_TRUE.

        " STATUS 할당
        LOOP AT PT_SKID_CHK  ASSIGNING <LS_SKID_CHK>.
          READ TABLE GT_SKID ASSIGNING <LS_SKID>
                                            WITH KEY VBELN = <LS_SKID_CHK>-VBELN POSNR = <LS_SKID_CHK>-POSNR.

          <LS_SKID>-BANFN = <LS_SKID_CHK>-BANFN = LS_NUMBER.  "구매요청 번호
          <LS_SKID>-BNFPO = <LS_SKID_CHK>-BNFPO.                        "항번
          <LS_SKID>-AFNAM = <LS_SKID_CHK>-AFNAM = LV_NAME.      "요청자명
          <LS_SKID>-STATUS =  ICON_LED_GREEN.

          PERFORM F_SET_CHECK_GT_SKID CHANGING <LS_SKID>.
          PERFORM F_SET_ALV_STYLE_GT_SKID CHANGING <LS_SKID>.

        ENDLOOP.

        "2026.06.25 비상비 구매로 변경 -승인 절차 추가
        PERFORM F_SEND_EMAIL USING PT_SKID_CHK.

        MESSAGE S000 WITH LS_NUMBER TEXT-M01.

      ELSE.
        CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
        MESSAGE S000 DISPLAY LIKE GC_E WITH TEXT-M02.
      ENDIF.
    ENDIF.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form F_SET_CHECK_GT_SKID
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- <LS_SKID>
*&---------------------------------------------------------------------*
FORM F_SET_CHECK_GT_SKID  CHANGING PS_SKID TYPE TY_SKID.

  IF P_NEW EQ ABAP_TRUE.
    " 입고요청일 존재, 구매요청번호는 없는 경우 -> 체크
    IF PS_SKID-LFDAT IS NOT INITIAL
      AND PS_SKID-BANFN IS INITIAL.
      PS_SKID-CHECK = ABAP_TRUE.
    ELSE.
      PS_SKID-CHECK = SPACE.
    ENDIF.

  ELSEIF P_DISP EQ ABAP_TRUE.
    " 구매요청 미존재 OR 구매오더 존재하는 경우 -> 체크 해제
    IF PS_SKID-EBELN IS NOT INITIAL
     OR PS_SKID-BANFN IS INITIAL.
      PS_SKID-CHECK = SPACE.
    ENDIF.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form F_CANCEL_PR_BAPI
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LT_SKID_CHK
*&      <-- LV_CHECK
*&---------------------------------------------------------------------*
FORM F_CANCEL_PR_BAPI  USING    PT_SKID_CHK TYPE TY_T_SKID
                                    CHANGING    CV_CHECK.

  DATA:
    LT_RETURN  TYPE STANDARD TABLE OF BAPIRET2,
    LS_RETURN  TYPE BAPIRET2,
    LT_PRITEM  TYPE STANDARD TABLE OF BAPIMEREQITEMIMP,
    LT_PRITEMX TYPE STANDARD TABLE OF BAPIMEREQITEMX,
    LT_MM2020  TYPE TABLE OF ZGTMMT2020.

  DATA:
    LV_CNT_S  TYPE INT4,
    LV_CNT_E  TYPE INT4,
    LV_STR    TYPE STRING,
    LV_CLOSED TYPE C VALUE ABAP_TRUE.

  FIELD-SYMBOLS: <LS_SKID> TYPE TY_SKID.

  LOOP AT PT_SKID_CHK ASSIGNING FIELD-SYMBOL(<LS_SKID_CHK>).

    CLEAR:
      LT_PRITEM[],
      LT_PRITEMX[],
      LT_RETURN[].

    LT_PRITEM = VALUE #( BASE LT_PRITEM (
                                        PREQ_ITEM = <LS_SKID_CHK>-BNFPO
                                        CLOSED = LV_CLOSED ) ).

    LT_PRITEMX = VALUE #( BASE LT_PRITEMX (
                                        PREQ_ITEM = <LS_SKID_CHK>-BNFPO
                                        PREQ_ITEMX = ABAP_TRUE
                                        CLOSED = ABAP_TRUE ) ).

    CALL FUNCTION 'BAPI_PR_CHANGE'
      EXPORTING
        NUMBER  = <LS_SKID_CHK>-BANFN
      TABLES
        RETURN  = LT_RETURN
        PRITEM  = LT_PRITEM
        PRITEMX = LT_PRITEMX.

    " 결과 CHECK
    READ TABLE LT_RETURN ASSIGNING FIELD-SYMBOL(<LS_RETURN>) WITH KEY = GC_E.

    " 실패시 ROLLBACK + STATUS
    IF SY-SUBRC EQ 0.

      LS_RETURN = <LS_RETURN>.
      CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

      READ TABLE GT_SKID ASSIGNING <LS_SKID>
                                        WITH KEY VBELN = <LS_SKID_CHK>-VBELN POSNR = <LS_SKID_CHK>-POSNR.

      LV_STR = |({ LS_RETURN-ID }-{ LS_RETURN-NUMBER })|.
      <LS_SKID>-STATUS =  ICON_LED_RED.

      <LS_SKID>-MESSAGE = LV_STR &&  LS_RETURN-MESSAGE.

      LV_CNT_E += 1.

      " 성공 시 -> CBO UPDATE -> COMMIT
    ELSE.
      "ZGTMMR2020 UPDATE
      UPDATE ZGTMMT2020
         SET BANFN       = @SPACE,
                BNFPO       = @SPACE,
                MATNR_SKID  = @SPACE,
                MAKTX_SKID  = @SPACE,
                WECNT       = @SPACE,
                MEINS_SKID  = @SPACE,
                AEDAT       = @SY-DATUM,
                AEDAT_LOCAL = @SY-DATLO,
                AETIM       = @SY-UZEIT,
                AETIM_LOCAL = @SY-TIMLO,
                AENAM       = @SY-UNAME
       WHERE VBELN = @<LS_SKID_CHK>-VBELN
         AND POSNR = @<LS_SKID_CHK>-POSNR.

      IF SY-SUBRC EQ 0.
        CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
          EXPORTING
            WAIT = ABAP_TRUE.

        READ TABLE GT_SKID ASSIGNING <LS_SKID>
                                  WITH KEY VBELN = <LS_SKID_CHK>-VBELN POSNR = <LS_SKID_CHK>-POSNR.
        <LS_SKID>-BANFN = SPACE.
        <LS_SKID>-BNFPO = SPACE.
        <LS_SKID>-STATUS =  ICON_LED_GREEN.

        PERFORM F_SET_CHECK_GT_SKID CHANGING <LS_SKID>.
        PERFORM F_SET_ALV_STYLE_GT_SKID CHANGING <LS_SKID>.

        LV_CNT_S += 1.
      ELSE.
        CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
      ENDIF.

    ENDIF.

  ENDLOOP.


  "메세지 처리
  "전체 데이터: &1 성공: &2 실패: &3
  DATA(LV_TOT) = LV_CNT_S + LV_CNT_E.
  MESSAGE S073 WITH LV_TOT LV_CNT_S LV_CNT_E.

ENDFORM.
