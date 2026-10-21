*&---------------------------------------------------------------------*
*& Include          ZGTMMR4390F02
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

  GO_CONT = NEW #( CONTAINER_NAME = 'CON100' ).
  GO_GRID = NEW #( I_PARENT = GO_CONT ).

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

  GT_EXCL[] = VALUE #( ( CL_GUI_ALV_GRID=>MC_FC_LOC_UNDO  )
                       ( CL_GUI_ALV_GRID=>MC_FC_LOC_COPY )
                       ( CL_GUI_ALV_GRID=>MC_FC_LOC_COPY_ROW )
                       ( CL_GUI_ALV_GRID=>MC_FC_LOC_CUT )
                       ( CL_GUI_ALV_GRID=>MC_FC_LOC_DELETE_ROW )
                       ( CL_GUI_ALV_GRID=>MC_FC_LOC_INSERT_ROW )
                       ( CL_GUI_ALV_GRID=>MC_FC_LOC_APPEND_ROW )
                       ( CL_GUI_ALV_GRID=>MC_FC_LOC_PASTE )
                       ( CL_GUI_ALV_GRID=>MC_FC_LOC_PASTE_NEW_ROW )

*--------------------------------------------------------------------*
**--  26.09 스프레트 시트만 보이도록 수정
*--------------------------------------------------------------------*
*                       ( CL_GUI_ALV_GRID=>MC_MB_EXPORT )
                       ( CL_GUI_ALV_GRID=>MC_FC_PC_FILE )
                       ( CL_GUI_ALV_GRID=>MC_FC_SEND )
                       ( CL_GUI_ALV_GRID=>MC_FC_CALL_XINT )
                       ( CL_GUI_ALV_GRID=>MC_FC_TO_OFFICE )
                       ( CL_GUI_ALV_GRID=>MC_FC_WORD_PROCESSOR )
                       ( CL_GUI_ALV_GRID=>MC_FC_CALL_ABC       )
                       ( CL_GUI_ALV_GRID=>MC_FC_HTML           )
*--------------------------------------------------------------------*

                       ( CL_GUI_ALV_GRID=>MC_FC_REFRESH )
                       ( CL_GUI_ALV_GRID=>MC_FC_INFO ) ).

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
    GS_LAYO.

  GS_LAYO-SEL_MODE   = GC_A.
  GS_LAYO-ZEBRA      = ABAP_TRUE.
  GS_LAYO-CWIDTH_OPT  = GC_A.
*  GS_LAYO-NO_ROWMOVE = ABAP_TRUE.
*  GS_LAYO-NO_ROWINS = ABAP_TRUE.

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
    GS_VARI.

  GS_VARI = VALUE DISVARIANT( REPORT  = SY-REPID
                                                 HANDLE  =  COND #(
                                                                 WHEN P_VBELN = GC_X  THEN '0001'
                                                                 WHEN P_EBELN = GC_X  THEN '0002'
                                                                 WHEN P_DELNO = GC_X  THEN '0003'
                                                                 ELSE '0004' ) ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form F_SET_VARI
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_SET_SORT .

  DATA: LS_SORT TYPE LVC_S_SORT.
  REFRESH GT_SORT.

  " 공급업체(기준 필드) 정렬 및 부분합 활성화
  LS_SORT-FIELDNAME = 'LIFNR'.
  LS_SORT-UP              = ABAP_TRUE.   " 오름차순 정렬
  LS_SORT-SUBTOT      = ABAP_TRUE.
  APPEND LS_SORT TO GT_SORT.

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
FORM F_SET_FCAT .

  CLEAR : GT_FCAT, GT_FCAT_DELI.

  IF P_DELNO = GC_X.
    PERFORM F_CREATE_FCAT_BY_ITAB USING GT_LIST_DELI CHANGING GT_FCAT_DELI.
    PERFORM F_ADJ_FCAT_DELI.
  ELSE.
    PERFORM F_CREATE_FCAT_BY_ITAB USING GT_LIST CHANGING GT_FCAT.
    PERFORM F_ADJ_FCAT.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_ADJ_FCAT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_ADJ_FCAT .

  CHECK GT_FCAT[] IS NOT INITIAL.

  LOOP AT GT_FCAT ASSIGNING FIELD-SYMBOL(<LS_FCAT>).
    CASE <LS_FCAT>-FIELDNAME.
      WHEN 'BUKRS'.
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H01 CHANGING <LS_FCAT>."
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
        <LS_FCAT>-NO_OUT = GC_X.

      WHEN 'WERKS'.
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H02 CHANGING <LS_FCAT>."
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.

      WHEN 'WERKS_N'.
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H03 CHANGING <LS_FCAT>."

      WHEN 'SPMON'.
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H04 CHANGING <LS_FCAT>."

      WHEN 'LIFNR'.
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H05 CHANGING <LS_FCAT>."

      WHEN 'LIFNR_N'.
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H06 CHANGING <LS_FCAT>."

      WHEN 'VBELN'.
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H07 CHANGING <LS_FCAT>."
        <LS_FCAT>-HOTSPOT = ABAP_TRUE.

      WHEN 'POSNR'.
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H08 CHANGING <LS_FCAT>."

      WHEN 'VKBUR'.
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H67 CHANGING <LS_FCAT>."
      WHEN 'VKBUR_N'.
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H68 CHANGING <LS_FCAT>."
      WHEN 'VKGRP'.
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H69 CHANGING <LS_FCAT>."
      WHEN 'VKGRP_N'.
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H70 CHANGING <LS_FCAT>."


      WHEN 'EBELN'.
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H09 CHANGING <LS_FCAT>."
        <LS_FCAT>-HOTSPOT = ABAP_TRUE.
        <LS_FCAT>-NO_OUT = COND #( WHEN P_VBELN = 'X' THEN 'X' ELSE '' ).

      WHEN 'EBELP'.
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H08 CHANGING <LS_FCAT>."
        <LS_FCAT>-NO_OUT = COND #( WHEN P_VBELN = 'X' THEN 'X' ELSE '' ).

      WHEN 'EKORG'.
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H10 CHANGING <LS_FCAT>."
        <LS_FCAT>-NO_OUT = ABAP_TRUE.

      WHEN 'EKGRP'.
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H11 CHANGING <LS_FCAT>."

      WHEN 'MATNR'.
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H12 CHANGING <LS_FCAT>."

      WHEN 'MAKTX'.
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H13 CHANGING <LS_FCAT>."

      WHEN 'PRODNAME'.
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H14 CHANGING <LS_FCAT>."

      WHEN 'SPECNO'.
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H15 CHANGING <LS_FCAT>."

      WHEN 'COLOR'. "
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H16 CHANGING <LS_FCAT>."

      WHEN 'PO_QTY'.
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H17 CHANGING <LS_FCAT>."
        <LS_FCAT>-QFIELDNAME = 'PO_MEINS'.

      WHEN 'PO_MEINS'. "
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H18 CHANGING <LS_FCAT>."

      WHEN 'LENGTH'.
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H19 CHANGING <LS_FCAT>."

      WHEN 'DRQTY'.
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H20 CHANGING <LS_FCAT>."
        <LS_FCAT>-QFIELDNAME = 'PO_MEINS'.

      WHEN 'MATGR'.
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H21 CHANGING <LS_FCAT>."
        <LS_FCAT>-QFIELDNAME = 'PO_MEINS'.
        <LS_FCAT>-EMPHASIZE = 'C700'.

      WHEN 'MATGR_DR'.
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H23 CHANGING <LS_FCAT>."

      WHEN 'MATGR_UNIT'.
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H22 CHANGING <LS_FCAT>."

      WHEN 'WH3410'.
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H24 CHANGING <LS_FCAT>."
        <LS_FCAT>-QFIELDNAME = 'PO_MEINS'.
      WHEN 'WH3410_DR'.
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H25 CHANGING <LS_FCAT>."
        <LS_FCAT>-QFIELDNAME = 'PO_MEINS'.
      WHEN 'WH3420'.
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H26 CHANGING <LS_FCAT>."
      WHEN 'WH3420_DR'.
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H27 CHANGING <LS_FCAT>."
      WHEN 'WH3498'.
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H28 CHANGING <LS_FCAT>."
      WHEN 'WH3498_DR'.
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H29 CHANGING <LS_FCAT>."
      WHEN 'WH3497'.
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H31 CHANGING <LS_FCAT>."
      WHEN 'WH3497_DR'.
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H32 CHANGING <LS_FCAT>."
      WHEN 'WHETC'.
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H33 CHANGING <LS_FCAT>."
      WHEN 'WHETC_DR'.
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H34 CHANGING <LS_FCAT>."

      WHEN 'KBETR'.
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H35 CHANGING <LS_FCAT>."
        <LS_FCAT>-CFIELDNAME = 'KONWA'.
        <LS_FCAT>-EMPHASIZE = 'C400'.

      WHEN 'KONWA'.
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H36 CHANGING <LS_FCAT>."

      WHEN 'KPEIN'.
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H37 CHANGING <LS_FCAT>."
        <LS_FCAT>-CFIELDNAME = 'KMEIN'.
      WHEN 'KMEIN'.
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H38 CHANGING <LS_FCAT>."

      WHEN 'TOTALPRICE'. "
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H39 CHANGING <LS_FCAT>."
        <LS_FCAT>-CFIELDNAME = 'KONWA'.
        <LS_FCAT>-EMPHASIZE = 'C400'.
        <LS_FCAT>-REF_TABLE  = 'BSEG'.   " 표준 회계 전표 테이블 강제 참조
        <LS_FCAT>-REF_FIELD   = 'WRBTR'.

      WHEN 'NES_CU'. ""CU
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H40 CHANGING <LS_FCAT>."
      WHEN 'VGW_CU'. ""CU
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H41 CHANGING <LS_FCAT>."
        <LS_FCAT>-QFIELDNAME = 'BME_CU'.
      WHEN 'BME_CU'. "
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H42 CHANGING <LS_FCAT>."
      WHEN 'VGE_CU'.
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H43 CHANGING <LS_FCAT>."
      WHEN 'MEINS_B_CU'.
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H18 CHANGING <LS_FCAT>."
      WHEN 'VGW_T_CU'.
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H48 CHANGING <LS_FCAT>."
        <LS_FCAT>-QFIELDNAME = 'MEINS_B_CU'.

      WHEN 'NES_AL'. ""AL
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H44 CHANGING <LS_FCAT>."
      WHEN 'VGW_AL'.
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H45 CHANGING <LS_FCAT>."
        <LS_FCAT>-QFIELDNAME = 'BME_AL'.
      WHEN 'BME_AL'. "
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H46 CHANGING <LS_FCAT>."
      WHEN 'VGE_AL'.
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H47 CHANGING <LS_FCAT>."
      WHEN 'MEINS_B_AL'.
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H18 CHANGING <LS_FCAT>."
      WHEN 'VGW_T_AL'.
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H49 CHANGING <LS_FCAT>."
        <LS_FCAT>-QFIELDNAME = 'MEINS_B_AL'.

      WHEN 'NES_FI'.
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H50 CHANGING <LS_FCAT>."
      WHEN 'VGW_FI'.
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H51 CHANGING <LS_FCAT>."
        <LS_FCAT>-QFIELDNAME = 'BME_FI'.
      WHEN 'BME_FI'. "
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H52 CHANGING <LS_FCAT>."
      WHEN 'VGE_FI'.
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H53 CHANGING <LS_FCAT>."
      WHEN 'MEINS_B_FI'.
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H18 CHANGING <LS_FCAT>."
      WHEN 'VGW_T_FI'.
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H54 CHANGING <LS_FCAT>."
        <LS_FCAT>-QFIELDNAME = 'MEINS_B_FI'.

      WHEN 'MWSKZ'.
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H55 CHANGING <LS_FCAT>."
        <LS_FCAT>-JUST = 'C'.
      WHEN 'TEXT1'.
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H56 CHANGING <LS_FCAT>."
        <LS_FCAT>-JUST = 'R'.

      WHEN OTHERS.
        <LS_FCAT>-TECH = ABAP_TRUE.
    ENDCASE.


  ENDLOOP.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_ADJ_FCAT_DELI
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_ADJ_FCAT_DELI .

  CHECK GT_FCAT_DELI[] IS NOT INITIAL.

  LOOP AT GT_FCAT_DELI ASSIGNING FIELD-SYMBOL(<LS_FCAT>).
    CASE <LS_FCAT>-FIELDNAME.
      WHEN 'BUKRS'.
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H01 CHANGING <LS_FCAT>."
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
        <LS_FCAT>-NO_OUT = GC_X.

      WHEN 'WERKS'.
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H02 CHANGING <LS_FCAT>."
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.

      WHEN 'WERKS_N'.
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H03 CHANGING <LS_FCAT>."

      WHEN 'SPMON'.
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H04 CHANGING <LS_FCAT>."

      WHEN 'LIFNR'.
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H05 CHANGING <LS_FCAT>."

      WHEN 'LIFNR_N'.
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H06 CHANGING <LS_FCAT>."

      WHEN 'VBELN'.
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H07 CHANGING <LS_FCAT>."
        <LS_FCAT>-HOTSPOT = ABAP_TRUE.

      WHEN 'POSNR'.
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H08 CHANGING <LS_FCAT>."

      WHEN 'VKBUR'.
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H67 CHANGING <LS_FCAT>."
      WHEN 'VKBUR_N'.
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H68 CHANGING <LS_FCAT>."
      WHEN 'VKGRP'.
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H69 CHANGING <LS_FCAT>."
      WHEN 'VKGRP_N'.
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H70 CHANGING <LS_FCAT>."


      WHEN 'EBELN'.
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H09 CHANGING <LS_FCAT>."
        <LS_FCAT>-HOTSPOT = ABAP_TRUE.

      WHEN 'EBELP'.
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H08 CHANGING <LS_FCAT>."

      WHEN 'DELNO'.
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H57 CHANGING <LS_FCAT>."
        <LS_FCAT>-HOTSPOT = ABAP_TRUE.

      WHEN 'DELITEM'.
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H08 CHANGING <LS_FCAT>."

      WHEN 'EKORG'.
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H10 CHANGING <LS_FCAT>."
        <LS_FCAT>-NO_OUT = ABAP_TRUE.

      WHEN 'EKGRP'.
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H11 CHANGING <LS_FCAT>."

      WHEN 'PSTYP'.
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H58 CHANGING <LS_FCAT>."

      WHEN 'MATNR'.
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H12 CHANGING <LS_FCAT>."

      WHEN 'MAKTX'.
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H13 CHANGING <LS_FCAT>."

      WHEN 'PRODNAME'.
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H14 CHANGING <LS_FCAT>."

      WHEN 'SPECNO'.
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H15 CHANGING <LS_FCAT>."

      WHEN 'COLOR'. "
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H16 CHANGING <LS_FCAT>."

      WHEN 'PO_QTY'.
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H17 CHANGING <LS_FCAT>."
        <LS_FCAT>-QFIELDNAME = 'PO_MEINS'.

      WHEN 'PO_MEINS'. "
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H18 CHANGING <LS_FCAT>."

      WHEN 'LENGTH'.
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H19 CHANGING <LS_FCAT>."

      WHEN 'DRQTY'.
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H20 CHANGING <LS_FCAT>."
        <LS_FCAT>-QFIELDNAME = 'PO_MEINS'.

      WHEN 'BUDAT'.
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H59 CHANGING <LS_FCAT>."
      WHEN 'DL_QTY'.
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H60 CHANGING <LS_FCAT>."
        <LS_FCAT>-QFIELDNAME = 'DL_UNIT'.
      WHEN 'DL_QTY_DR'.
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H61 CHANGING <LS_FCAT>."
        <LS_FCAT>-QFIELDNAME = 'DL_UNIT'.
      WHEN 'DL_UNIT'.
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H62 CHANGING <LS_FCAT>."
      WHEN 'GR_QTY'.
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H63 CHANGING <LS_FCAT>."
        <LS_FCAT>-QFIELDNAME = 'GR_UNIT'.
      WHEN 'GR_QTY_DR'.
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H64 CHANGING <LS_FCAT>."
        <LS_FCAT>-QFIELDNAME = 'GR_UNIT'.
      WHEN 'GR_UNIT'.
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H65 CHANGING <LS_FCAT>."
      WHEN 'LGORT'.
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H66 CHANGING <LS_FCAT>."

      WHEN 'MATGR'.
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H21 CHANGING <LS_FCAT>."
        <LS_FCAT>-QFIELDNAME = 'MATGR_UNIT'.
        <LS_FCAT>-EMPHASIZE = 'C700'.

      WHEN 'MATGR_DR'.
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H23 CHANGING <LS_FCAT>."

      WHEN 'MATGR_UNIT'.
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H22 CHANGING <LS_FCAT>."

      WHEN 'WH3410'.
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H24 CHANGING <LS_FCAT>."
      WHEN 'WH3410_DR'.
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H25 CHANGING <LS_FCAT>."
      WHEN 'WH3420'.
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H26 CHANGING <LS_FCAT>."
      WHEN 'WH3420_DR'.
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H27 CHANGING <LS_FCAT>."
      WHEN 'WH3498'.
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H28 CHANGING <LS_FCAT>."
      WHEN 'WH3498_DR'.
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H29 CHANGING <LS_FCAT>."
      WHEN 'WH3497'.
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H31 CHANGING <LS_FCAT>."
      WHEN 'WH3497_DR'.
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H32 CHANGING <LS_FCAT>."
      WHEN 'WHETC'.
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H33 CHANGING <LS_FCAT>."
      WHEN 'WHETC_DR'.
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H34 CHANGING <LS_FCAT>."

      WHEN 'KBETR'.
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H35 CHANGING <LS_FCAT>."
        <LS_FCAT>-CFIELDNAME = 'KONWA'.
        <LS_FCAT>-EMPHASIZE = 'C400'.

      WHEN 'KONWA'.
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H36 CHANGING <LS_FCAT>."

      WHEN 'KPEIN'.
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H37 CHANGING <LS_FCAT>."
        <LS_FCAT>-CFIELDNAME = 'KMEIN'.
      WHEN 'KMEIN'.
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H38 CHANGING <LS_FCAT>."

      WHEN 'TOTALPRICE'. "
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H39 CHANGING <LS_FCAT>."
        <LS_FCAT>-CFIELDNAME = 'KONWA'.
        <LS_FCAT>-EMPHASIZE = 'C400'.
        <LS_FCAT>-REF_TABLE  = 'BSEG'.   " 표준 회계 전표 테이블 강제 참조
        <LS_FCAT>-REF_FIELD   = 'WRBTR'.

      WHEN 'NES_CU'. ""CU
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H40 CHANGING <LS_FCAT>."
      WHEN 'VGW_CU'. ""CU
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H41 CHANGING <LS_FCAT>."
        <LS_FCAT>-QFIELDNAME = 'BME_CU'.
      WHEN 'BME_CU'. "
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H42 CHANGING <LS_FCAT>."
      WHEN 'VGE_CU'.
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H43 CHANGING <LS_FCAT>."
      WHEN 'MEINS_B_CU'.
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H18 CHANGING <LS_FCAT>."
      WHEN 'VGW_T_CU'.
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H48 CHANGING <LS_FCAT>."
        <LS_FCAT>-QFIELDNAME = 'MEINS_B_CU'.

      WHEN 'NES_AL'. ""AL
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H44 CHANGING <LS_FCAT>."
      WHEN 'VGW_AL'.
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H45 CHANGING <LS_FCAT>."
        <LS_FCAT>-QFIELDNAME = 'BME_AL'.
      WHEN 'BME_AL'. "
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H46 CHANGING <LS_FCAT>."
      WHEN 'VGE_AL'.
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H47 CHANGING <LS_FCAT>."
      WHEN 'MEINS_B_AL'.
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H18 CHANGING <LS_FCAT>."
      WHEN 'VGW_T_AL'.
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H49 CHANGING <LS_FCAT>."
        <LS_FCAT>-QFIELDNAME = 'MEINS_B_AL'.

      WHEN 'NES_FI'.
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H50 CHANGING <LS_FCAT>."
      WHEN 'VGW_FI'.
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H51 CHANGING <LS_FCAT>."
        <LS_FCAT>-QFIELDNAME = 'BME_FI'.
      WHEN 'BME_FI'. "
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H52 CHANGING <LS_FCAT>."
      WHEN 'VGE_FI'.
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H53 CHANGING <LS_FCAT>."
      WHEN 'MEINS_B_FI'.
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H18 CHANGING <LS_FCAT>."
      WHEN 'VGW_T_FI'.
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H54 CHANGING <LS_FCAT>."
        <LS_FCAT>-QFIELDNAME = 'MEINS_B_FI'.

      WHEN 'MWSKZ'.
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H55 CHANGING <LS_FCAT>."
        <LS_FCAT>-JUST = 'C'.
      WHEN 'TEXT1'.
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H56 CHANGING <LS_FCAT>."
        <LS_FCAT>-JUST = 'R'.

      WHEN OTHERS.
        <LS_FCAT>-TECH = ABAP_TRUE.
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
FORM F_SET_ALV_EVENT .

  CREATE OBJECT GCL_EVENT.
  SET HANDLER :
    GCL_EVENT->HANDLE_HOTSPOT_CLICK FOR GO_GRID.

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

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_DISPLAY_ALV
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_DISPLAY_ALV TABLES PT_LIST PT_FCAT
                                  USING PO_GRID TYPE REF TO CL_GUI_ALV_GRID.

  CALL METHOD PO_GRID->SET_TABLE_FOR_FIRST_DISPLAY
    EXPORTING
      IS_LAYOUT            = GS_LAYO
      IT_TOOLBAR_EXCLUDING = GT_EXCL[]
      IS_VARIANT           = GS_VARI
      I_SAVE               = 'A'
    CHANGING
      IT_OUTTAB            = PT_LIST[]
      IT_FIELDCATALOG      = PT_FCAT[]
*     IT_SORT              = GT_SORT[]
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
*& FORM HOTSPOT_CLICK
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
FORM HOTSPOT_CLICK USING PS_ROW_NO TYPE LVC_S_ROW
                                               PS_COLUMN TYPE LVC_S_COL
                                               PO_SENDER.

*  CHECK PO_SENDER = GO_GRID .

  CASE PO_SENDER.
    WHEN GO_GRID.
      IF P_DELNO = GC_X.
        READ TABLE GT_LIST_DELI INTO DATA(LS_LIST_D) INDEX PS_ROW_NO-INDEX.
        CHECK SY-SUBRC = 0.

        IF PS_COLUMN-FIELDNAME = 'VBELN'.
          CHECK LS_LIST_D-VBELN IS NOT INITIAL.

          SET PARAMETER ID 'AUN' FIELD LS_LIST_D-VBELN.
          CALL TRANSACTION 'VA03' AND SKIP FIRST SCREEN.

        ELSEIF PS_COLUMN-FIELDNAME = 'EBELN'.
          CHECK LS_LIST_D-EBELN IS NOT INITIAL.

          SET PARAMETER ID 'BES' FIELD LS_LIST_D-EBELN.
          CALL TRANSACTION 'ME23N' AND SKIP FIRST SCREEN.

        ELSE.
          EXIT.
        ENDIF.

      ELSE.
        READ TABLE GT_LIST INTO DATA(LS_LIST) INDEX PS_ROW_NO-INDEX.
        CHECK SY-SUBRC = 0.

        IF PS_COLUMN-FIELDNAME = 'VBELN'.
          CHECK LS_LIST-VBELN IS NOT INITIAL.

          SET PARAMETER ID 'AUN' FIELD LS_LIST-VBELN.
          CALL TRANSACTION 'VA03' AND SKIP FIRST SCREEN.

        ELSEIF PS_COLUMN-FIELDNAME = 'EBELN'.
          CHECK LS_LIST-EBELN IS NOT INITIAL.

          SET PARAMETER ID 'BES' FIELD LS_LIST-EBELN.
          CALL TRANSACTION 'ME23N' AND SKIP FIRST SCREEN.

        ELSE.
          EXIT.
        ENDIF.
      ENDIF.

    WHEN OTHERS.
  ENDCASE.

ENDFORM.
