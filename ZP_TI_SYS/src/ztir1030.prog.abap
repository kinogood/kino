************************************************************************
* Title         :  ZTIR1030                                            *
*                                                                      *
* Description   : [Report] 사후송금 및 무환 적하보험 부보 Due List     *
*                                                                      *
* Creation Date : 2004/12/22                                           *
*                                                                      *
* Author        : Seung Jun, Lee                                       *
*                 Copyright ⓒ ASEG Co., LTD. All rights reserved.     *
************************************************************************
*                                                                      *
* Inputs        :                                                      *
*                                                                      *
* Outputs       :                                                      *
*                                                                      *
************************************************************************
*                                                                      *
* Processing Steps:                                                    *
* 1.                                                                   *
* 2.                                                                   *
*                                                                      *
************************************************************************
*&                               수정이력
*&---------------------------------------------------------------------*
*&   DATE        AUTHORS                  DESCRIPTION
*& ----------   --------- ---------------------------------------------*
*  2014.05.29    조성익    21214 사후송금 적하부보 리스트제외
*&---------------------------------------------------------------------*
REPORT  ZTIR1030       MESSAGE-ID ZMTI00
                       NO STANDARD PAGE HEADING.

************************************************************************
* User Include Define                                                  *
************************************************************************
INCLUDE ZTS_REUSE_ALVFORMS_T00.  "> AVL 공용 Data 선언.
** JS전선 회사코드 2007/04 KSH --------------------------------------
DATA: L_YN    TYPE C.
INCLUDE ZTS_AUTHORIZATION_CHECK. "AUTHORIZATION_CHECK
** JS전선 회사코드 2007/04 KSH --------------------------------------

************************************************************************
* TYPES and TYPE-POOLS                                                 *
************************************************************************
TYPES: BEGIN OF TY_HEADER,
            BOX(1)      TYPE C,
            EBELN       TYPE EBELN,
            BUKRS       LIKE EKKO-BUKRS,
            EKORG       LIKE EKKO-EKORG,
            EKGRP       LIKE EKKO-EKGRP,
            BSTYP       LIKE EKKO-BSTYP,
            ZTERM       LIKE EKKO-ZTERM,
            FRGRL       LIKE EKKO-FRGRL,
            BSART       LIKE EKKO-BSART,
            HLOEKZ      LIKE EKKO-LOEKZ,      ">헤더 삭제지시자.
            WAERS       LIKE EKKO-WAERS,
            HNETWR      LIKE ZTISBLIT-NETWR,  ">총금액.
*            fland       LIKE ekko-fland,
*            fport       LIKE ekko-fport,
*            tland       LIKE ekko-tland,
*            tport       LIKE ekko-tport,
*            fwdty       LIKE ekko-fwdty,
            REQTY       TYPE ZTIREQTY,
            REQTX(12)   TYPE C,
            LIFNR       TYPE LIFNR,
            NAME1       TYPE NAME1,
            HSTAT(10)   TYPE C.
TYPES: END OF TY_HEADER.

TYPES: BEGIN OF TY_ITEM.
INCLUDE     TYPE        TY_HEADER.
TYPES :     EBELP       TYPE EBELP,
            MENGE       LIKE EKPO-MENGE,
            MEINS       LIKE EKPO-MEINS,
            BLMNG       LIKE ZTITBLP-BLMNG,
            BLMNGS      LIKE ZTISBLIT-BLMNGS,
            BLMNGL      LIKE ZTISBLIT-BLMNGL,
            RQMNG       LIKE ZTITRQP-RQMNG,
            RQMNGS      LIKE ZTISRQIT-RQMNGS,
            RQMNGL      LIKE ZTISRQIT-RQMNGL,
            WERKS       LIKE ZTISBLIT-WERKS,
            NAME2       LIKE ZTISBLIT-NAME1,
            MATNR       LIKE ZTISBLIT-MATNR,
            TXZ01       LIKE ZTISBLIT-TXZ01,
            EEIND       LIKE ZTISBLIT-EEIND,
            NETPR       LIKE ZTISBLIT-NETPR,
            PEINH       LIKE ZTISBLIT-PEINH,
            NETWR       LIKE ZTISBLIT-NETWR,
            ISTAT(10)   TYPE C.
TYPES: END OF TY_ITEM.


TYPES: BEGIN OF TY_LIST.
INCLUDE             TYPE        TY_ITEM.
TYPES:      COLOR   TYPE SLIS_T_SPECIALCOL_ALV.
TYPES: END OF TY_LIST.

*> Select용.
TYPES: BEGIN OF TY_TAB.
INCLUDE     TYPE        TY_ITEM.
TYPES: END OF TY_TAB.

************************************************************************
* SAP Include Define                                                   *
************************************************************************

************************************************************************
* SAP Tables                                                           *
************************************************************************
TABLES: T001,
        T001W,
        ZTITIG02,
        ZTITBLK,
        LFA1.

************************************************************************
* SAP Views                                                            *
************************************************************************
TABLES: ZTIVPO00,    ">Purchasing Document : Header + Items
        ZTIVRQ00,    ">수입의뢰 Views(Header + Items + status)
        ZTITIP1.

************************************************************************
* CONSTANTS                                                            *
************************************************************************
** JS전선 회사코드 2007/04 KSH --------------------------------------
*CONSTANTS:
*    c_bukrs     LIKE t001-bukrs     VALUE '1000'.   ">Company code
** JS전선 회사코드 2007/04 KSH --------------------------------------
************************************************************************
* Internal Tables                                                      *
************************************************************************
*DATA : BEGIN OF it_ZTITIG02 OCCURS 0.
*        INCLUDE STRUCTURE ZTITIG02.
*DATA : END   OF it_ZTITIG02.
*
DATA : BEGIN OF IT_EKPO OCCURS 0.
        INCLUDE STRUCTURE ZTIVPO00.
DATA :  BLMNG       LIKE ZTITBLP-BLMNG,
        BLMNGS      LIKE ZTISBLIT-BLMNGS,
        BLMNGL      LIKE ZTISBLIT-BLMNGL,
        BOX        TYPE C,
        INDEX(10)  TYPE N.
DATA : END   OF IT_EKPO.

DATA: IT_ZTITIG02  TYPE ZTITIG02  OCCURS 0 WITH HEADER LINE.
DATA: IT_LIST      TYPE TY_LIST   OCCURS 0 WITH HEADER LINE.
DATA: IT_HEADER    TYPE TY_HEADER OCCURS 0 WITH HEADER LINE.
DATA: IT_TAB       TYPE TY_TAB    OCCURS 0 WITH HEADER LINE.

************************************************************************
* DATA Declarations                                                    *
************************************************************************

************************************************************************
** RANGES
************************************************************************
*RANGES:

***********************************************************************
* FIELD-GROUPS
***********************************************************************
*FIELD-GROUPS:

***********************************************************************
* FIELD-SYMBOLS
***********************************************************************
*FIELD-SYMBOLS:

************************************************************************
* MACRO DEFINE                                                         *
************************************************************************

************************************************************************
* CLASSES: Definition                                                  *
************************************************************************

************************************************************************
* CLASSES: IMPLEMENTATION                                              *
************************************************************************

************************************************************************
* SELECT-OPTIONS / PARAMETERS                                          *
************************************************************************
SELECTION-SCREEN BEGIN OF BLOCK DBSEL WITH FRAME TITLE TEXT-001.
SELECT-OPTIONS:
  S_BUKRS  FOR ZTIVPO00-BUKRS
               NO-EXTENSION NO INTERVALS OBLIGATORY
               MEMORY ID  BUK
               MODIF  ID IOG ,
  S_EKORG  FOR ZTIVPO00-EKORG MODIF ID IOG,
  S_EKGRP  FOR ZTIVPO00-EKGRP MODIF ID IOG,
  S_EBELN  FOR ZTIVPO00-EBELN MODIF ID IOG
               MEMORY ID  BES,
  S_LIFNR  FOR ZTIVPO00-LIFNR MODIF ID IOG,
  S_WAERS  FOR ZTIVPO00-WAERS MODIF ID IOG,
  S_MATKL  FOR ZTIVPO00-MATKL MODIF ID IOG,
  S_MATNR  FOR ZTIVPO00-MATNR MODIF ID IOG,
  S_TXZ01  FOR ZTIVPO00-TXZ01 MODIF ID IOG,
  S_WERKS  FOR ZTIVPO00-WERKS MODIF ID IOG
               MEMORY ID  WRK,
  S_LAND1  FOR ZTIVPO00-LAND1 MODIF ID IOG,
  S_INCO1  FOR ZTIVPO00-INCO1 MODIF ID IOG,
  S_ZTERM  FOR ZTIVPO00-ZTERM MODIF ID IOG,
  S_BEDAT  FOR ZTIVPO00-BEDAT MODIF ID IOG,
  S_AEDAT  FOR ZTIVPO00-AEDAT MODIF ID IOG,
  S_ERNAM  FOR ZTIVPO00-ERNAM MODIF ID IOG.
SELECTION-SCREEN END OF BLOCK DBSEL.

SELECTION-SCREEN BEGIN OF BLOCK LISTS WITH FRAME TITLE TEXT-002.
PARAMETERS: P_VARI LIKE DISVARIANT-VARIANT.
SELECTION-SCREEN END OF BLOCK LISTS.

************************************************************************
* User Include Define                                                  *
************************************************************************
INCLUDE ZTS_REUSE_ALVFORMS_F00.  "> AVL 공용 Subroutines.

************************************************************************
* INITIALIZATION Event                                                 *
************************************************************************
INITIALIZATION.
*> Read default layout (description only, w/o field catalog)
  PERFORM  P1000_ALV_FIELDS_INITIAL.
*> Report initialization
  PERFORM  P1001_INITIALIZATION.

************************************************************************
* AT SELECTION-SCREEN Events                                           *
************************************************************************
AT SELECTION-SCREEN.
*> 사용자 Input values Check
  PERFORM P1100_CHECK_INPUT_VALUES.
*> 사용자 레이아웃 Input values Check
  PERFORM P1101_CHECK_VARIANT_VALUE.
** JS전선 회사코드 2007/04 KSH --------------------------------------
*> AUTHORIZATION_CHECK
*  PERFORM p1102_authorization_check USING s_bukrs-low.
** JS전선 회사코드 2007/04 KSH --------------------------------------

*> 레이아웃 HELP
AT SELECTION-SCREEN ON VALUE-REQUEST FOR P_VARI.
  PERFORM P1102_F4_FOR_VARIANT.
*> 지급조건 HELP(Low values)
AT SELECTION-SCREEN ON VALUE-REQUEST FOR S_ZTERM-LOW.
  PERFORM GET_F4_FOR_ZTERM(ZTIR0000) USING S_ZTERM-LOW.
*> 지급조건 HELP(High values)
AT SELECTION-SCREEN ON VALUE-REQUEST FOR S_ZTERM-HIGH.
  PERFORM GET_F4_FOR_ZTERM(ZTIR0000) USING S_ZTERM-HIGH.

************************************************************************
* START-OF-SELECTION Event                                             *
************************************************************************
START-OF-SELECTION.
*> 검색조건에 해당하는 데이타를 Select.
  PERFORM P2000_DATA_SELECTIONS.
*> Header table과 List(Items) table를 만듬.
  PERFORM P2100_HEADER_AND_LIST_BUILD.

************************************************************************
* END-OF-SELECTION Event                                               *
************************************************************************
END-OF-SELECTION.
  DESCRIBE TABLE IT_TAB LINES G_LINE.
  IF NOT G_LINE IS INITIAL.
*> PROGRESS Display.
    G_LINEN    = 90.
    G_OUT_TEXT = '리스트를 구성 중입니다 %99999%%'(P03).
    REPLACE '%99999%'(P99) WITH G_LINEN INTO G_OUT_TEXT.
    PERFORM SHOW_PROGRESS_BAR(ZTIR0000) USING G_OUT_TEXT G_LINEN.

    PERFORM 3000_FIELD_CATEGORY_BUILD.
    PERFORM 3100_SET_COLOR_INFOMATION.
    PERFORM 3200_KEY_INFOMATION_BUILD.
    PERFORM 3300_EVENT_EXIT_TABLE_BUILD.
    PERFORM 3400_COMMENT_BUILD.
    PERFORM 3500_SORT_TABLE_BUILD.
    PERFORM 3600_EVENT_TABLE_BUILD USING : SLIS_EV_TOP_OF_PAGE,
                                           SLIS_EV_PF_STATUS_SET,
                                           SLIS_EV_USER_COMMAND.
    PERFORM 3700_LAYOUT_BUILD.
    PERFORM 3910_CALL_ALV_HIERSEQ.
  ENDIF.

*> Program 종료.
  PERFORM  P9000_PROGRAM_EXIT.

************************************************************************
* TOP-OF-PAGE Event                                                    *
************************************************************************
TOP-OF-PAGE.

************************************************************************
* END-OF-PAGE Event                                                    *
************************************************************************
END-OF-PAGE.

************************************************************************
* TOP-OF-PAGE DURING LINE-SELECTION Event                              *
************************************************************************
TOP-OF-PAGE DURING LINE-SELECTION.


************************************************************************
* AT LINE-SELECTION Event                                              *
************************************************************************
AT LINE-SELECTION.


************************************************************************
* AT USER-COMMAND Event                                                *
************************************************************************
AT USER-COMMAND.

*eject
************************************************************************
*                                                                      *
* S U B R O U T I N E S                                                *
*                                                                      *
************************************************************************
*&---------------------------------------------------------------------*
*&      Form  p1001_initialization
*&---------------------------------------------------------------------*
FORM P1001_INITIALIZATION .

  SET TITLEBAR 'T1000' WITH '요청'(T10).

ENDFORM.                    " p1001_initialization

*&---------------------------------------------------------------------*
*&      Form  p1100_check_input_values
*&---------------------------------------------------------------------*
FORM P1100_CHECK_INPUT_VALUES .

  TABLES: DFIES.

  DATA: L_BUKRS   LIKE T001-BUKRS,
        L_WERKS   LIKE T001W-WERKS,
        L_MATNR   LIKE MARA-MATNR,
        L_MTART   LIKE T134-MTART,
        L_EBELN   LIKE EKKO-EBELN,
        L_LIFNR   LIKE LFA1-LIFNR,
        L_EKORG   LIKE T024E-EKORG,
        L_EKGRP   LIKE T024-EKGRP.

* Company code
  SELECT BUKRS INTO (L_BUKRS)
               FROM T001 UP TO 1 ROWS WHERE BUKRS IN S_BUKRS.
  ENDSELECT.
  IF SY-SUBRC <> 0.
    PERFORM GET_FTEXT(RDDFIE00) USING 'T001' 'BUKRS' SY-LANGU
                                CHANGING DFIES G_SUBRC.
    SET CURSOR FIELD 'S_BUKRS-LOW'.
    MESSAGE E348(M7) WITH '회사코드'.
  ENDIF.

* Vendor
  READ TABLE S_LIFNR INDEX 1 TRANSPORTING NO FIELDS.
  IF SY-SUBRC = 0.
    SELECT LIFNR INTO (L_LIFNR)
                 FROM LFB1 UP TO 1 ROWS WHERE LIFNR IN S_LIFNR
                                        AND   BUKRS IN S_BUKRS.
    ENDSELECT.
    IF SY-SUBRC <> 0.
      PERFORM GET_FTEXT(RDDFIE00) USING 'LFA1' 'LIFNR' SY-LANGU
                                  CHANGING DFIES G_SUBRC.
      SET CURSOR FIELD 'S_LIFNR-LOW'.
      MESSAGE E348(M7) WITH DFIES-SCRTEXT_M.
    ENDIF.
  ENDIF.

* Purchase Organization
  READ TABLE S_EKORG INDEX 1 TRANSPORTING NO FIELDS.
  IF SY-SUBRC = 0.
    SELECT EKORG INTO (L_EKORG)
                 FROM T024E UP TO 1 ROWS WHERE EKORG IN S_EKORG.
    ENDSELECT.
    IF SY-SUBRC <> 0.
      PERFORM GET_FTEXT(RDDFIE00) USING 'T024E' 'EKORG' SY-LANGU
                                  CHANGING DFIES G_SUBRC.
      SET CURSOR FIELD 'S_EKORG-LOW'.
      MESSAGE E348(M7) WITH DFIES-SCRTEXT_M.
    ENDIF.
  ENDIF.

* Purchase GROUP
  READ TABLE S_EKGRP INDEX 1 TRANSPORTING NO FIELDS.
  IF SY-SUBRC = 0.
    SELECT EKGRP INTO (L_EKGRP)
                 FROM T024 UP TO 1 ROWS WHERE EKGRP IN S_EKGRP.
    ENDSELECT.
    IF SY-SUBRC <> 0.
      PERFORM GET_FTEXT(RDDFIE00) USING 'T024' 'EKGRP' SY-LANGU
                                  CHANGING DFIES G_SUBRC.
      SET CURSOR FIELD 'S_EKGRP-LOW'.
      MESSAGE E348(M7) WITH DFIES-SCRTEXT_M.
    ENDIF.
  ENDIF.

ENDFORM.                    " p1100_check_input_values

*&---------------------------------------------------------------------*
*&      Form  p2000_data_selections
*&---------------------------------------------------------------------*
FORM P2000_DATA_SELECTIONS .

  DATA: L_BLMNG  LIKE ZTITBLP-BLMNG,
        L_IIPNO  LIKE ZTITIP1-IIPNO,
        L_IBLNO  LIKE ZTITBLP-IBLNO.

  RANGES: LR_INCO1 FOR EKKO-INCO1 OCCURS 1.

  CLEAR: G_COUNT, IT_TAB, IT_ZTITIG02, IT_HEADER, IT_LIST.
  REFRESH : IT_TAB, IT_ZTITIG02, IT_HEADER, IT_LIST.
*> PROGRESS Display.
  G_LINEN    = 30.
  G_OUT_TEXT = '데이타를 검색 중입니다 %99999%%'(P01).
  REPLACE '%99999%' WITH G_LINEN INTO G_OUT_TEXT.
  PERFORM SHOW_PROGRESS_BAR(ZTIR0000) USING G_OUT_TEXT G_LINEN.

*> Get 수입가능 구매문서 종류 및 지급조건 .
  PERFORM GET_USED_PAYMENT_TERM(ZTIR0000)  TABLES  IT_ZTITIG02
                                           USING   G_SUBRC C_SUCCESS.
  IF G_SUBRC NE 0.
    EXIT.
  ENDIF.
  LOOP AT IT_ZTITIG02.
    IF IT_ZTITIG02-REQTY NE 'ZZ'.
      IF NOT ( IT_ZTITIG02-REQTY EQ 'TT' AND
               IT_ZTITIG02-AFTYN EQ 'A' ).
        DELETE IT_ZTITIG02.
      ENDIF.
    ENDIF.
  ENDLOOP.
  DESCRIBE TABLE IT_ZTITIG02 LINES G_LINE.
  IF G_LINE EQ 0.
    MESSAGE ID 'ZMTI00' TYPE C_SUCCESS NUMBER 001.
    EXIT.
  ENDIF.

  REFRESH: LR_INCO1.
  CLEAR: LR_INCO1.
  LR_INCO1-SIGN   = 'I'.
  LR_INCO1-OPTION = 'EQ'.
  LR_INCO1-LOW    = 'FOB'.  APPEND LR_INCO1.
  LR_INCO1-LOW    = 'FCA'.  APPEND LR_INCO1.
  LR_INCO1-LOW    = 'FAS'.  APPEND LR_INCO1.
  LR_INCO1-LOW    = 'CPT'.  APPEND LR_INCO1.
  LR_INCO1-LOW    = 'CFR'.  APPEND LR_INCO1.
  LR_INCO1-LOW    = 'EXW'.  APPEND LR_INCO1.

*> 구매오더 데이타 select.
  SELECT *
         INTO CORRESPONDING FIELDS OF TABLE IT_TAB
         FROM ZTIVPO00
         FOR ALL ENTRIES IN IT_ZTITIG02
         WHERE EBELN  IN S_EBELN
         AND   BUKRS  IN S_BUKRS
         AND   EKORG  IN S_EKORG
         AND   EKGRP  IN S_EKGRP
         AND   BSTYP  EQ C_CHARF
         AND   LIFNR  IN S_LIFNR
         AND   WAERS  IN S_WAERS
         AND   MATKL  IN S_MATKL
         AND   MATNR  IN S_MATNR
         AND   TXZ01  IN S_TXZ01
         AND   WERKS  IN S_WERKS
         AND   LAND1  IN S_LAND1
         AND   INCO1  IN S_INCO1
         AND   ZTERM  IN S_ZTERM
         AND   BEDAT  IN S_BEDAT
         AND   AEDAT  IN S_AEDAT
         AND   ERNAM  IN S_ERNAM
         AND   INCO1  IN LR_INCO1
         AND   FRGRL  NE C_TRUE   ">릴리즈 지시자.
         AND   ELIKZ  EQ SPACE    ">납품완료 지시자.
         AND   HLOEKZ EQ SPACE    ">헤더 삭제지시자.
         AND   LOEKZ  EQ SPACE    ">아이템 삭제지시자.
         AND   BSART  EQ IT_ZTITIG02-BSART
         AND   ZTERM  EQ IT_ZTITIG02-ZTERM
*-[START_21214] 사후송금 적하부보 리스트제외
         AND   EBELN  NOT IN ( SELECT EBELN
                                 FROM ZTITZINS ). ">예외 PO 제외
*-[END_21214] 사후송금 적하부보 리스트제외

  IF SY-SUBRC NE 0.
    MESSAGE S902.   EXIT.
  ENDIF.

*> select된 구매오더 데이타를 수입의뢰된 수량과 비교.
  CLEAR: G_COUNT, G_CNT.
  LOOP AT IT_TAB.
    G_TABIX = SY-TABIX.

******************************************************
* 20070705 SIMCHO 입고여부 체크
******************************************************
*    DATA : lv_igrno LIKE ztitgrp-igrno.
*
*    SELECT SINGLE igrno INTO lv_igrno
*      FROM ztitgrp
*      WHERE ebeln = it_tab-ebeln
*        AND ebelp = it_tab-ebelp.
*
*    IF sy-subrc = 0.
*      DELETE it_tab INDEX g_tabix.
*      CONTINUE.
*    ENDIF.
*
*******************************************************
*
    SELECT IIPNO
      INTO L_IIPNO
      FROM ZTITIP1 UP TO 1 ROWS
     WHERE EBELN  = IT_TAB-EBELN.
    ENDSELECT.
*
    IF SY-SUBRC EQ C_ZERO.
      DELETE IT_TAB INDEX G_TABIX.
      CONTINUE.
    ELSE.
      IF S_BUKRS-LOW = '1000'.
        "B/L 품목에 해당 구매오더가 있는지 찾고..
        CLEAR L_IBLNO.
        SELECT SINGLE IBLNO
          INTO L_IBLNO
          FROM ZTITBLP
         WHERE EBELN  = IT_TAB-EBELN.

        IF SY-SUBRC EQ C_ZERO.
          "B/L로 개설된 I/P가 있는지 찾는다
          CLEAR L_IIPNO.
          SELECT SINGLE IIPNO
            INTO L_IIPNO
            FROM ZTITIP1
           WHERE IBLNO  = L_IBLNO.

          IF SY-SUBRC EQ C_ZERO.
            DELETE IT_TAB INDEX G_TABIX.
            CONTINUE.
          ELSE.
            ADD 1 TO G_CNT.
          ENDIF.

        ENDIF.
      ELSE.
        ADD 1 TO G_CNT.
      ENDIF.
    ENDIF.

    SELECT SINGLE NAME1 INTO IT_TAB-NAME1
      FROM LFA1
     WHERE LIFNR EQ IT_TAB-LIFNR.

    CLEAR: IT_ZTITIG02.
    READ TABLE IT_ZTITIG02 WITH KEY BSART = IT_TAB-BSART
                                    ZTERM = IT_TAB-ZTERM.
*                                    reqty = 'TT'
*                                    BINARY SEARCH.
    IF SY-SUBRC EQ 0.
      MOVE: IT_ZTITIG02-REQTY TO IT_TAB-REQTY.
      PERFORM GET_DOMAIN_VALUE_TEXT(ZTIR0000) USING 'ZTIREQTY'
                                                    IT_TAB-REQTY
                                                    IT_TAB-REQTX.
    ELSE.
*      READ TABLE it_ztitig02 WITH KEY bsart = it_tab-bsart
*                                      zterm = it_tab-zterm
*                                      reqty = 'ZZ'
*                                      BINARY SEARCH.
*
*      IF sy-subrc EQ 0.
*        MOVE: it_ztitig02-reqty TO it_tab-reqty.
*        PERFORM get_domain_value_text(ztir0000) USING 'ZTIREQTY'
*                                                      it_tab-reqty
*                                                      it_tab-reqtx.
*      ELSE.
      DELETE IT_TAB INDEX G_TABIX.
      CONTINUE.
*      ENDIF.
    ENDIF.
    MOVE IT_TAB-NETWR TO IT_TAB-HNETWR.
    ADD 1 TO G_COUNT.
    MODIFY IT_TAB INDEX G_TABIX.
  ENDLOOP.

  IF G_CNT EQ 0.
    MESSAGE S103.
  ENDIF.
**
ENDFORM.                    " p2000_data_selections
*&---------------------------------------------------------------------*
*&      Form  3000_field_category_build
*&---------------------------------------------------------------------*
FORM 3000_FIELD_CATEGORY_BUILD .

*----------------------------------------------------------------------*
* 필드명과 Output Length등을 사용자의 입맛에 맞게 바꿈.
*----------------------------------------------------------------------*
  PERFORM 3010_FILL_FIELD_CATEGORY USING :
          'S' 'TABNAME'       'IT_HEADER',
          ' ' 'REF_TABNAME'   ' ',
          'E' 'FIELDNAME'     'BOX',

          'S' 'TABNAME'       'IT_HEADER',
          ' ' 'REF_TABNAME'   'EKKO',
          ' ' 'FIELDNAME'     'EBELN',
          ' ' 'OUTPUTLEN'     '12',
          ' ' 'HOTSPOT'       'X',       " Double Click 효과
          'E' 'KEY'           'X',

          'S' 'TABNAME'       'IT_HEADER',
          ' ' 'REF_TABNAME'   'EKKO',
          ' ' 'OUTPUTLEN'     '20',
          ' ' 'FIELDNAME'     'LIFNR',
          'E' 'HOTSPOT'       'X',       " Double Click 효과

          'S' 'TABNAME'       'IT_HEADER',
          ' ' 'REF_TABNAME'   'LFA1',
          ' ' 'OUTPUTLEN'     '45',
          'E' 'FIELDNAME'     'NAME1',

          'S' 'TABNAME'       'IT_HEADER',
          ' ' 'REF_TABNAME'   'EKKO',
          'E' 'FIELDNAME'     'ZTERM',

          'S' 'TABNAME'       'IT_HEADER',
          ' ' 'REF_TABNAME'   'ZTITRQHD',
          ' ' 'FIELDNAME'     'REQTY',
          'E' 'NO_OUT'        'X',

          'S' 'TABNAME'       'IT_HEADER',
          ' ' 'FIELDNAME'     'REQTX',
          ' ' 'SELTEXT_L'     '수입의뢰종류'(T11),
          ' ' 'SELTEXT_M'     '수입의뢰종류'(T11),
          ' ' 'SELTEXT_S'     '수입의뢰종류'(T11),
          'E' 'OUTPUTLEN'     '12',

          'S' 'TABNAME'       'IT_HEADER',
          ' ' 'REF_TABNAME'   'EKKO',
          'E' 'FIELDNAME'     'WAERS',

          'S' 'TABNAME'       'IT_HEADER',
          ' ' 'REF_TABNAME'   'ZTISRQIT',
          ' ' 'CFIELDNAME'    'WAERS',
          ' ' 'CTABNAME'      'IT_HEADER',
          ' ' 'SELTEXT_L'     'Amount'(T14),
          ' ' 'SELTEXT_M'     'Amount'(T14),
          ' ' 'SELTEXT_S'     'Amount'(T14),
          'E' 'FIELDNAME'     'HNETWR',

          'S' 'TABNAME'       'IT_HEADER',
          ' ' 'REF_TABNAME'   'EKKO',
          ' ' 'FIELDNAME'     'BUKRS',
          'E' 'NO_OUT'        'X',

          'S' 'TABNAME'       'IT_HEADER',
          ' ' 'REF_TABNAME'   'EKKO',
          ' ' 'FIELDNAME'     'EKORG',
          'E' 'NO_OUT'        'X',

          'S' 'TABNAME'       'IT_HEADER',
          ' ' 'REF_TABNAME'   'EKKO',
          ' ' 'FIELDNAME'     'EKGRP',
          'E' 'NO_OUT'        'X',
***********
          'S' 'TABNAME'       'IT_LIST',
          ' ' 'REF_TABNAME'   'EKPO',
          ' ' 'FIELDNAME'     'EBELP',
          ' ' 'OUTPUTLEN'     '12',
          ' ' 'JUST'          C_CHARL,
          ' ' 'LZERO'         C_CHARX,
          ' ' 'HOTSPOT'       'X',       " Double Click 효과
          'E' 'KEY'           'X',

          'S' 'TABNAME'       'IT_LIST',
          ' ' 'REF_TABNAME'   'EKPO',
          ' ' 'FIELDNAME'     'MATNR',
          ' ' 'OUTPUTLEN'     '20',
          'E' 'HOTSPOT'       'X',       " Double Click 효과

          'S' 'TABNAME'       'IT_LIST',
          ' ' 'REF_TABNAME'   'EKPO',
          ' ' 'OUTPUTLEN'     '45',
          'E' 'FIELDNAME'     'TXZ01',

          'S' 'TABNAME'       'IT_LIST',
          ' ' 'REF_TABNAME'   'ZTITBLP',
          ' ' 'QFIELDNAME'    'MEINS',
          ' ' 'QTABNAME'      'IT_LIST',
          'E' 'FIELDNAME'     'BLMNG',

          'S' 'TABNAME'       'IT_LIST',
          ' ' 'REF_TABNAME'   'ZTITBLP',
          'E' 'FIELDNAME'     'MEINS',

          'S' 'TABNAME'       'IT_LIST',
          ' ' 'REF_TABNAME'   'EKPO',
          ' ' 'NO_OUT'        'X',
          'E' 'FIELDNAME'     'WERKS',

          'S' 'TABNAME'       'IT_LIST',
          ' ' 'REF_TABNAME'   'EKPO',
          ' ' 'CFIELDNAME'    'WAERS',
          ' ' 'CTABNAME'      'IT_HEADER',
          ' ' 'NO_OUT'        'X',
          'E' 'FIELDNAME'     'NETWR'.



ENDFORM.                    " 3000_field_category_build

*&---------------------------------------------------------------------*
*&      Form  3200_KEY_INFOMATION_BUILD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM 3200_KEY_INFOMATION_BUILD .

  CLEAR GS_KEYINFO.

  GS_KEYINFO-HEADER01 = 'EBELN'.
  GS_KEYINFO-ITEM01   = 'EBELN'.

*  GS_KEYINFO-HEADER02 = SPACE.
*  GS_KEYINFO-ITEM02   = 'OBART'.
*
*  GS_KEYINFO-HEADER03 = SPACE.
*  GS_KEYINFO-ITEM03   = 'OBJNR'.

ENDFORM.                    " 3200_KEY_INFOMATION_BUILD
*&---------------------------------------------------------------------*
*&      Form  3100_SET_COLOR_INFOMATION
*&---------------------------------------------------------------------*
FORM 3100_SET_COLOR_INFOMATION .

  LOOP AT IT_LIST.
    CLEAR: IT_LIST-COLOR[],
           GS_COLOR_INFO.

*    ON CHANGE OF IT_LIST-EBELN.
    GS_COLOR_INFO-FIELDNAME = 'MATNR'.
    GS_COLOR_INFO-COLOR-COL = '1'.
    APPEND GS_COLOR_INFO TO IT_LIST-COLOR[].
    MODIFY IT_LIST.
*    ENDON.
  ENDLOOP.                             " AT LT_RESRC_VW

ENDFORM.                    " 3100_SET_COLOR_INFOMATION
*&---------------------------------------------------------------------*
*&      Form  3400_COMMENT_BUILD
*&---------------------------------------------------------------------*
FORM 3400_COMMENT_BUILD .

  DATA: L_TEXT20(20) TYPE C.

  CLEAR: IT_LISTHEADER, GS_LISTHEADER.
  REFRESH: IT_LISTHEADER.

* LIST HEADING LINE: TYPE H
  CLEAR GS_LISTHEADER.
  GS_LISTHEADER-TYP  = 'H'.
* gs_listheader-KEY:  NOT USED FOR THIS TYPE
  GS_LISTHEADER-INFO = '사후송금 및 무환 적화보험 부보 Due List'(T13).
  APPEND GS_LISTHEADER TO IT_LISTHEADER.

** STATUS LINE: TYPE S
* CLEAR gs_listheader.
* gs_listheader-TYP  = 'S'.
* gs_listheader-KEY  = 'KEY'.
* gs_listheader-INFO = '<SSSSS>'.
* APPEND gs_listheader TO IT_LISTHEADER.

** JS전선 회사코드 2007/04 KSH --------------------------------------
  DATA: L_BUTXT LIKE T001-BUTXT.
  CLEAR: L_BUTXT.
  SELECT SINGLE BUTXT FROM T001
                      INTO L_BUTXT
                     WHERE BUKRS EQ S_BUKRS-LOW.

  CLEAR GS_LISTHEADER.
  GS_LISTHEADER-TYP  = 'A'.
  GS_LISTHEADER-INFO = '회사코드 :'.
  CONCATENATE GS_LISTHEADER-INFO S_BUKRS-LOW L_BUTXT
         INTO GS_LISTHEADER-INFO SEPARATED BY SPACE.
  APPEND GS_LISTHEADER TO IT_LISTHEADER.
** JS전선 회사코드 2007/04 KSH --------------------------------------

* ACTION LINE: TYPE A
  CLEAR GS_LISTHEADER.
  GS_LISTHEADER-TYP  = 'A'.
  GS_LISTHEADER-INFO = '출력일자 :'(T12).
  WRITE: SY-DATLO TO L_TEXT20.
  CONCATENATE GS_LISTHEADER-INFO L_TEXT20 INTO GS_LISTHEADER-INFO
              SEPARATED BY SPACE.
  APPEND GS_LISTHEADER TO IT_LISTHEADER.

ENDFORM.                    " 3400_COMMENT_BUILD
*&---------------------------------------------------------------------*
*&      Form  3500_SORT_TABLE_BUILD
*&---------------------------------------------------------------------*
FORM 3500_SORT_TABLE_BUILD .

  DATA: LS_SORT TYPE SLIS_SORTINFO_ALV.

  CLEAR LS_SORT.
  LS_SORT-SPOS      = 1.
  LS_SORT-FIELDNAME = 'EBELN'.
  LS_SORT-TABNAME   = 'IT_LIST'.
  LS_SORT-UP        = 'X'.
* LS_SORT-GROUP     = '*'.             " Seiten- bei Gruppenwechsel
*  ls_sort-group     = 'UL'.            " Underline      -"-
  APPEND LS_SORT TO IT_SORT.

ENDFORM.                    " 3500_SORT_TABLE_BUILD
*&---------------------------------------------------------------------*
*&      Form  3700_LAYOUT_build
*&---------------------------------------------------------------------*
FORM 3700_LAYOUT_BUILD .

  MOVE: 'BOX'        TO GS_LAYOUT-BOX_FIELDNAME,
        'IT_HEADER'  TO GS_LAYOUT-BOX_TABNAME.

ENDFORM.                    " 3700_LAYOUT_build

*---------------------------------------------------------------------*
*       FORM TOP_OF_PAGE                                              *
*---------------------------------------------------------------------*
FORM TOP_OF_PAGE.                                           "#EC CALLED

  CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
    EXPORTING
      IT_LIST_COMMENTARY = IT_LISTHEADER[].

ENDFORM.                    "TOP_OF_PAGE

*---------------------------------------------------------------------*
*       Form  USER_COMMAND                                            *
*---------------------------------------------------------------------*
FORM USER_COMMAND USING R_UCOMM     LIKE SY-UCOMM
                        RS_SELFIELD TYPE SLIS_SELFIELD.

  DATA: LS_LIST   TYPE TY_TAB,
        L_ERROR   TYPE C          VALUE 'N'.

  CLEAR: LS_LIST.

  CASE R_UCOMM.
    WHEN 'ZTIT201'.

      CLEAR : G_LINE, G_COUNT.
      REFRESH IT_EKPO.
      LOOP AT IT_HEADER WHERE BOX EQ 'X'.
        ADD 1 TO G_LINE.
        LOOP AT IT_LIST WHERE EBELN EQ IT_HEADER-EBELN.
*                          AND lifnr EQ it_header-lifnr
*                          AND werks EQ it_header-werks.
          IF G_COUNT NE 0.
*> Vendor check.
            IF IT_LIST-LIFNR NE IT_EKPO-LIFNR.
              MESSAGE S009 WITH '공급업체'.
              L_ERROR = 'Y'.
              EXIT.
            ENDIF.
*> currency check.
            IF IT_LIST-WAERS NE IT_EKPO-WAERS.
              MESSAGE S009 WITH '통화단위'.
              L_ERROR = 'Y'.
              EXIT.
            ENDIF.
            IF IT_LIST-BUKRS NE IT_EKPO-BUKRS.
              MESSAGE S009 WITH '회사코드'.
              L_ERROR = 'Y'.
              EXIT.
            ENDIF.
            IF IT_LIST-EKORG NE IT_EKPO-EKORG.
              MESSAGE S009 WITH '구매조직'.
              L_ERROR = 'Y'.
              EXIT.
            ENDIF.
            IF IT_LIST-EKGRP NE IT_EKPO-EKGRP.
              MESSAGE S009 WITH '구매그룹'.
              L_ERROR = 'Y'.
              EXIT.
            ENDIF.
*            IF it_list-fwdty NE it_ekpo-fwdty.
*              MESSAGE s009 WITH '운송방법'.
*              l_error = 'Y'.
*              EXIT.
*            ENDIF.
*            if it_list-fland ne it_ekpo-fland or
*               it_list-fport ne it_ekpo-fport.
*            MESSAGE s009 WITH '선적항'.
*            l_error = 'Y'.
*            EXIT.
*          ENDIF.
*          IF it_list-tland NE it_ekpo-tland OR
*             it_list-tport NE it_ekpo-tport.
*            MESSAGE s009 WITH '도착항'.
*            l_error = 'Y'.
*            EXIT.
*          ENDIF.
          ENDIF.
          ADD 1 TO G_COUNT.
          SELECT SINGLE *
            INTO CORRESPONDING FIELDS OF IT_EKPO
            FROM ZTIVPO00
           WHERE EBELN EQ IT_LIST-EBELN
             AND EBELP EQ IT_LIST-EBELP.

          MOVE-CORRESPONDING IT_LIST TO IT_EKPO.
          MOVE: G_COUNT              TO IT_EKPO-INDEX,
                C_TRUE               TO IT_EKPO-BOX.
          APPEND IT_EKPO.
        ENDLOOP.
      ENDLOOP.

      CHECK L_ERROR EQ 'N'.

      CASE G_LINE.
        WHEN 0.
          MESSAGE S006(0K).   EXIT.
        WHEN OTHERS.
      ENDCASE.
*>> B/L
      CLEAR: ZTITIP1.

      CALL DIALOG 'Z_TI_IP_CREATE'
        AND SKIP FIRST SCREEN
        EXPORTING
          G_TCODE          FROM SY-TCODE
          ZTISSCRCOM-EBELN FROM IT_LIST-EBELN
        IMPORTING
          ZTITIP1.

      IF NOT ZTITIP1-IIPNO IS INITIAL.
        PERFORM P9000_DUELIST_REFRESH USING  RS_SELFIELD.
      ENDIF.


*   Before export, fill the data fields
*   before CLUSTR.
*      FREE MEMORY ID l_indxkey.
*
*      ls_indx-aedat = sy-datlo.
*      ls_indx-usera = sy-uname.
*
*      EXPORT g_tcode   FROM sy-tcode
*             it_resb   FROM it_resb
*             TO DATABASE indx(zm)  FROM ls_indx ID l_indxkey.
*
*      CALL TRANSACTION 'ZTIT201' AND SKIP FIRST SCREEN .
*
*      FREE MEMORY ID l_indxkey.
*
*      CLEAR: it_resb[].
*      EXPORT g_tcode   FROM space
*             it_resb   FROM it_resb
*             TO DATABASE indx(zm)  FROM ls_indx ID l_indxkey.
    WHEN '&IC1'.
      IF RS_SELFIELD-TABNAME EQ 'IT_HEADER'.
        READ TABLE IT_HEADER INDEX RS_SELFIELD-TABINDEX.
      ELSEIF RS_SELFIELD-TABNAME EQ 'IT_LIST'.
        READ TABLE IT_LIST INDEX RS_SELFIELD-TABINDEX.
      ENDIF.
      IF SY-SUBRC NE 0.
        MESSAGE S903. EXIT.
      ENDIF.
      IF RS_SELFIELD-TABNAME EQ 'IT_HEADER'.
        MOVE-CORRESPONDING IT_HEADER TO LS_LIST.
      ELSEIF RS_SELFIELD-TABNAME EQ 'IT_LIST'.
        MOVE-CORRESPONDING IT_LIST   TO LS_LIST.
      ENDIF.

      CASE RS_SELFIELD-FIELDNAME.
        WHEN 'EBELN' OR 'EBELP'.
          PERFORM  DISPLAY_PURCHASE_ORDER(ZTIR0000)
                                          USING LS_LIST-EBELN
                                                LS_LIST-EBELP.
        WHEN 'LIFNR'.

        WHEN 'MATNR'.

      ENDCASE.
    WHEN OTHERS.
  ENDCASE.

  CLEAR: R_UCOMM.

ENDFORM.                    "USER_COMMAND
*---------------------------------------------------------------------*
*       FORM PF_STATUS_SET                                            *
*---------------------------------------------------------------------*
FORM PF_STATUS_SET USING RT_EXTAB TYPE SLIS_T_EXTAB.

  SET TITLEBAR 'T1000' WITH '요청'(T10).

  REFRESH: RT_EXTAB.

  APPEND 'ARCHIVE'   TO RT_EXTAB.
  APPEND '&VEXCEL'   TO RT_EXTAB.
  APPEND '&AQW'      TO RT_EXTAB.
  APPEND '&VCRYSTAL' TO RT_EXTAB.
  APPEND '&VGRID'    TO RT_EXTAB.
  APPEND '&EB9'      TO RT_EXTAB.
  APPEND '&CRDESIG'  TO RT_EXTAB.
  APPEND '&XXL'      TO RT_EXTAB.
  APPEND '&ABC'      TO RT_EXTAB.

  SET PF-STATUS 'STANDARD ' EXCLUDING RT_EXTAB.
*SET PF-STATUS 'ABCD' OF PROGRAM PROG.

ENDFORM.                    "PF_STATUS_SET

*eject
************************************************************************
*                                                                      *
* P B O   M O D U L E                                                  *
*                                                                      *
************************************************************************

*eject
************************************************************************
*                                                                      *
* P A I   M O D U L E                                                  *
*                                                                      *
***********************************************************************
*
