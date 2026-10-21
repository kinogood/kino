************************************************************************
*                                                                      *
* Title         : ZTIR0140                                             *
*                                                                      *
* Description   : [Report] 국가별 L/C OPEN 현황 Report*
*                                                                      *
* Creation Date : 2003/10/29                                           *
*                                                                      *
* Author        : Seung Jun, Lee                                       *
*                                                                      *
************************************************************************
*                                                                      *
* Inputs        :                                                      *
*                                                                      *
* Outputs       :                                                      *
*                                                                      *
************************************************************************
*                                                                      *
* Processing Steps:                                                    *
*   1.                                                                 *
*                                                                      *
************************************************************************
*----------------------------------------------------------------------*
*                M O D I F I C A T I O N   L O G                       *
*----------------------------------------------------------------------*
* Date         Programmer       Transport#  Description                *
*----------------------------------------------------------------------*
*                                                                      *
*                                                                      *
************************************************************************
PROGRAM   ztir0140
          MESSAGE-ID zmti00
          NO STANDARD PAGE HEADING.

************************************************************************
* TYPES and TYPE-POOLS                                                 *
************************************************************************
TYPE-POOLS: slis.   "> Globale Type(ALV)
TYPES: int13 TYPE i.
TYPES: BEGIN OF ty_list.
TYPES: land1  LIKE  lfa1-land1,
       landx  LIKE  t005t-landx,
       buscl  LIKE  ztitrqs-buscl,
       auamt  LIKE  ztitrqs-usamt,"조선
       buamt  LIKE  ztitrqs-usamt,"해양
       cuamt  LIKE  ztitrqs-usamt,"특수선
       duamt  LIKE  ztitrqs-usamt,"시설
       suamt  LIKE  ztitrqs-usamt, "계
       tuamt  LIKE  ztitrqs-usamt,
       tpert  TYPE p DECIMALS 1,    "비율.
       auami  TYPE  int13,
       buami  TYPE  int13,
       cuami  TYPE  int13,
       duami  TYPE  int13,
       suami  TYPE  int13,
       tuami  TYPE  int13,
*       box        TYPE c,
       color      TYPE slis_t_specialcol_alv.
TYPES: END OF ty_list.

TYPES: BEGIN OF ty_col.
TYPES: land1  LIKE  lfa1-land1,
       buscl  LIKE  ztitrqs-buscl,
       usamt  LIKE  ztitrqs-usamt.
TYPES: END OF ty_col.

TYPES: BEGIN OF ty_col2.
TYPES: land1  LIKE  lfa1-land1,
       usamt  LIKE  ztitrqs-usamt.
TYPES: END OF ty_col2.

TYPES: BEGIN OF ty_lcst.
TYPES: land1  LIKE  lfa1-land1,
       lifnr  LIKE  ztitrqk-lifnr.
        INCLUDE STRUCTURE ztitrqs.
TYPES: END OF ty_lcst.

************************************************************************
* User Included                                                        *
************************************************************************
*INCLUDE zTi_reuse_bdc_subroutine_f00.
** JS전선 회사코드 2007/04 KSH --------------------------------------
DATA: l_yn    type c.
INCLUDE zts_authorization_check. "AUTHORIZATION_CHECK
** JS전선 회사코드 2007/04 KSH --------------------------------------

************************************************************************
* SAP Tables                                                           *
************************************************************************
TABLES: t001,      ">Company Codes
        t001w,     ">Plants/Branches
        t001k,     ">Valuation area
        t161,      ">Purchasing Document Types
        t134,      ">Material Types
        t134t,     ">Material Types Descriptions
        t024d,     ">MRP controllers
        mara,      ">General Material Data
        marc,      ">Plant Data for Material
        mard,      ">Storage Location Data for Material
        mslb,      ">Special Stocks with Vendor
        mbew,      ">Material Valuation
        march,     ">Plant Data for Material: History
        mardh,     ">Storage Location Data for Material: History
        mslbh,     ">Special Stocks with Vendor: History
        mbewh,     ">Material Valuation: History
        mkpf,      ">Header: Material Document
        mseg,      ">Document Segment: Material
        makt,      ">Material Descriptions
        marm,      ">Units of Measure for Material
        lfa1  ,    ">Vendor Master (General Section)
        lfb1  ,    ">Vendor Master (Company Code)
        t024e ,    ">Purchasing Organizations
        t024  ,    ">Purchasing Groups
        t163b ,    ">TEXT
        t163c ,    ">TEXT
        t685t ,    ">TEXT
        ekbz  ,    ">History per Purchasing Document: Delivery Costs
        ekbe  ,    ">History per Purchasing Document
        ekko,      ">Purchasing Document Header
        ekpo  ,    ">Purchasing Document Items
        ekkn  ,    ">Account Assignment in Purchasing Document
        dfies ,    ">DD Interface: Table Fields for DDIF_FIELDINFO_GET
        ztitrqk,  ">[Import] Document Header
        ztitrqs,  ">[Import] Document Status
        ztitrqp,  ">[Import] Document Items
        ztitpnk,  ">Payment Notice Header Table
        ztitpnp,  ">Payment Notice Items Table
        ztivrq01,  "수입의뢰 Views(Header + Items) : 회차별
        ztivrq02,  "수입의뢰 Views(Header + Status) : 회차별
        ztivrq03,  "수입의뢰 Views(Header + Items) : EKPO
        ztivrq04.  ">수입의뢰 Views(Header + Items) : 최종회차별

TABLES: icon,
        s031,
        bapi1093_0,
        bapicurx,
        bapiret1.

************************************************************************
* Internal Tables  & Structure
************************************************************************
DATA: it_list      TYPE STANDARD TABLE OF ty_list,
      gs_list      TYPE ty_list,
      ls_list      TYPE ty_list.

DATA: it_col       TYPE STANDARD TABLE OF ty_col,
      gs_col       TYPE ty_col,
      ls_col       TYPE ty_col.

DATA: it_col2       TYPE STANDARD TABLE OF ty_col2,
      gs_col2       TYPE ty_col2,
      ls_col2       TYPE ty_col2.

DATA: it_lcst       TYPE STANDARD TABLE OF ty_lcst,
      gs_lcst       TYPE ty_lcst,
      ls_lcst       TYPE ty_lcst.

*> 공급업체명
DATA : BEGIN OF xlfa1 OCCURS 0,
       lifnr           LIKE   lfa1-lifnr,
       name1           LIKE   lfa1-name1.
DATA : END   OF xlfa1.

*> Message dialog box용
DATA: BEGIN OF it_msg  OCCURS 0.
        INCLUDE STRUCTURE ztismessage.
DATA: END   OF it_msg.

*> ALV용.
* Global variables for handling ALV functionality
DATA: alv_keyinfo      TYPE slis_keyinfo_alv.
DATA: alv_variant      LIKE disvariant.
DATA: gs_layout        TYPE slis_layout_alv.
DATA: alv_repid        LIKE sy-repid.
DATA: alv_print        TYPE slis_print_alv.
DATA: st_sort          TYPE slis_sortinfo_alv.

DATA: alv_detail_func(30).
DATA: fc       TYPE slis_t_fieldcat_alv,
      fc1      TYPE slis_t_fieldcat_alv,
      fcs      TYPE slis_fieldcat_alv,
      it_sort  TYPE slis_t_sortinfo_alv.

DATA: it_fieldcat TYPE slis_t_fieldcat_alv,
      gs_fieldcat LIKE LINE OF it_fieldcat.
************************************************************************
* CONSTANTS                                                            *
************************************************************************
CONSTANTS:
** JS전선 회사코드 2007/04 KSH --------------------------------------
*    c_bukrs     LIKE t001-bukrs     VALUE '1000',   ">Company code
** JS전선 회사코드 2007/04 KSH --------------------------------------
    c_save(1)   TYPE  c             VALUE 'A'.

*----------------------------------------------------------------------
* Work fields
*----------------------------------------------------------------------
DATA : g_line          TYPE   i,             "Line counter
       g_subrc         LIKE   sy-subrc,      "Return code
       g_tabix         LIKE   sy-tabix,      "table index
       g_line1(3)      TYPE   n,             "LINE COUNT
       g_out_text(70)  TYPE   c,             "text field(display)
       g_err_mode      TYPE   c,
       line_cnt(02)    TYPE   n,
       field_name(20),
       field_name1(20).

*합계용.
DATA : g_total        TYPE ztitrqs-usamt.

DATA : s_variant      LIKE  disvariant,
       s_var_usr      LIKE  disvariant.
*합계 text용.
DATA: gs_totxt(10) TYPE c.

************************************************************************
* SELECT-OPTIONS / PARAMETERS                                          *
************************************************************************
SELECTION-SCREEN BEGIN OF BLOCK box1 WITH FRAME TITLE text-001.
SELECT-OPTIONS:
  s_bukrs  FOR ztitrqk-bukrs                   "회사코드.
               NO-EXTENSION NO INTERVALS OBLIGATORY
                    MEMORY ID buk,
*  s_opndt  FOR ZTITRQS-opndt "MODIF ID opn,     "개설일자.
*               NO-EXTENSION NO INTERVALS OBLIGATORY,
  s_opndt  FOR s031-spmon "MODIF ID opn,     "개설일자.
               NO-EXTENSION NO INTERVALS OBLIGATORY.
SELECTION-SCREEN : SKIP,
                   ULINE.
SELECT-OPTIONS:
  s_ekorg  FOR ztitrqk-ekorg,                  "구매조직.
  s_ekgrp  FOR ztitrqk-ekgrp,                  "구매그룹.
  s_waers  FOR ztitrqs-waers,                  "개설통화.
  s_buscl  FOR ztitrqs-buscl,
  s_opnbk  FOR ztitrqk-opnbk MODIF ID sed,     "개설은행.
  s_rcvun  FOR ztitrqs-rcvun,     "개설등록자.
  s_rcvdt  FOR ztitrqs-rcvdt,     "개설등록일자.
  s_cnam   FOR ztitrqs-cnam,                   "작성인.
  s_cdat   FOR ztitrqs-cdat,                   "생성일.
  s_unam   FOR ztitrqs-unam,                   "최종변경인.
  s_udat   FOR ztitrqs-udat.                   "변경일.
SELECTION-SCREEN END OF BLOCK box1.

SELECTION-SCREEN BEGIN OF BLOCK box2 WITH FRAME TITLE text-002.
PARAMETERS: p_full RADIOBUTTON GROUP ab2 MODIF ID opn,
            p_list RADIOBUTTON GROUP ab2 MODIF ID opn DEFAULT 'X'.
SELECTION-SCREEN END OF BLOCK box2.

SELECTION-SCREEN BEGIN OF BLOCK box3 WITH FRAME TITLE text-004.
PARAMETERS: p_cur RADIOBUTTON GROUP ab3 ,
            p_int RADIOBUTTON GROUP ab3 DEFAULT 'X'.
SELECTION-SCREEN END OF BLOCK box3.

*> Report variant
SELECTION-SCREEN: BEGIN OF BLOCK alv WITH FRAME TITLE text-003.
PARAMETERS: alv_def LIKE disvariant-variant.
SELECTION-SCREEN: END OF BLOCK alv.

************************************************************************
* INITIALIZATION Event                                                 *
************************************************************************
INITIALIZATION.
  PERFORM  set_initial_data.
  PERFORM  set_alv_init.             ">Initialize ALV variable

************************************************************************
* AT SELECTION-SCREEN Events                                           *
************************************************************************
*>The layout determines the list format
AT SELECTION-SCREEN ON VALUE-REQUEST FOR s_opndt-low.
  PERFORM exec_monat_f4.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR alv_def.
  PERFORM exec_alv_f4.

******************************
AT SELECTION-SCREEN.
  PERFORM input_field_check.
  PERFORM alv_variant_check.
** JS전선 회사코드 2007/04 KSH --------------------------------------
*> AUTHORIZATION_CHECK
  PERFORM p1102_authorization_check USING s_bukrs-low.
** JS전선 회사코드 2007/04 KSH --------------------------------------
******************************
AT SELECTION-SCREEN OUTPUT.
  LOOP AT SCREEN.
    CHECK screen-group1 = 'OPN'.
    screen-invisible = '1'.
    MODIFY SCREEN.
  ENDLOOP.
************************************************************************
* START-OF-SELECTION Event                                             *
************************************************************************
START-OF-SELECTION.
  PERFORM clearing_work_area.      ">Initialize internal table
  PERFORM get_data_for_display.    ">data select

************************************************************************
*                                                                      *
* END-OF-SELECTION Event                                               *
*                                                                      *
************************************************************************
END-OF-SELECTION.
  CHECK g_line NE 0.
*>--------------------------------------------------------
*> PROGRESS INDICATOR DISPLAY.
*>  4.  LIST DISPLAY
*>--------------------------------------------------------
  g_line1 = 100.
  g_out_text = text-905.
  REPLACE '%99999%' WITH g_line1 INTO g_out_text.
  PERFORM set_progress_bar USING g_out_text g_line1.
  PERFORM set_colorize_build.       ">Set color
  PERFORM set_sort_field.           ">Set ALV sort fields
  PERFORM set_fieldcat_build.      ">Set ALV field category
  PERFORM display_alv_list.         ">Call ALV Functions

************************************************************************
*                                                                      *
* TOP-OF-PAGE Event                                                    *
*                                                                      *
************************************************************************
TOP-OF-PAGE.

************************************************************************
*                                                                      *
* END-OF-PAGE Event                                                    *
*                                                                      *
************************************************************************
END-OF-PAGE.


************************************************************************
*                                                                      *
* TOP-OF-PAGE DURING LINE-SELECTION Event                              *
*                                                                      *
************************************************************************
TOP-OF-PAGE DURING LINE-SELECTION.


************************************************************************
*                                                                      *
* AT LINE-SELECTION Event                                              *
*                                                                      *
************************************************************************
AT LINE-SELECTION.


************************************************************************
*                                                                      *
* AT USER-COMMAND Event                                                *
*                                                                      *
************************************************************************
AT USER-COMMAND.


*eject
************************************************************************
*                                                                      *
* S U B R O U T I N E S                                                *
*                                                                      *
************************************************************************
*&---------------------------------------------------------------------*
*&      Form  SET_INITIAL_DATA
*&---------------------------------------------------------------------*
FORM set_initial_data.

* STATUS.
  SET TITLEBAR 'T1000' WITH '국가별 L/C OPEN 현황'.

  alv_repid = sy-repid.

* Get default variant
  CLEAR s_variant.
  s_variant-report = sy-repid.
  s_var_usr = s_variant.
  CALL FUNCTION 'REUSE_ALV_VARIANT_DEFAULT_GET'
    EXPORTING
      i_save     = c_save
    CHANGING
      cs_variant = s_var_usr
    EXCEPTIONS
      not_found  = 2.
  IF sy-subrc = 0.
    alv_def =  s_var_usr-variant.
  ENDIF.

ENDFORM.                    " SET_INITIAL_DATA
*&---------------------------------------------------------------------*
*&      Form  SET_PROGRESS_BAR
*&---------------------------------------------------------------------*
FORM set_progress_bar USING   text perc.

  CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
    EXPORTING
      percentage = perc
      text       = text.

ENDFORM.                    " SET_PROGRESS_BAR
*&---------------------------------------------------------------------*
*&      Form  INPUT_FIELD_CHECK
*&---------------------------------------------------------------------*
FORM input_field_check.

  DATA: l_bukrs   LIKE t001-bukrs,
        l_werks   LIKE t001w-werks,
        l_matnr   LIKE mara-matnr,
        l_mtart   LIKE t134-mtart,
        l_ebeln   LIKE ekko-ebeln,
        l_lifnr   LIKE lfa1-lifnr,
        l_ekorg   LIKE t024e-ekorg,
        l_ekgrp   LIKE t024-ekgrp.

* Company code
  SELECT bukrs INTO (l_bukrs)
               FROM t001 UP TO 1 ROWS WHERE bukrs IN s_bukrs.
  ENDSELECT.
  IF sy-subrc <> 0.
    PERFORM get_ftext(rddfie00) USING 'T001' 'BUKRS' sy-langu
                                CHANGING dfies g_subrc.
    SET CURSOR FIELD 'S_BUKRS-LOW'.
    MESSAGE e348(m7) WITH '회사코드'.
  ENDIF.

* Purchase Organization
  READ TABLE s_ekorg INDEX 1 TRANSPORTING NO FIELDS.
  IF sy-subrc = 0.
    SELECT ekorg INTO (l_ekorg)
                 FROM t024e UP TO 1 ROWS WHERE ekorg IN s_ekorg.
    ENDSELECT.
    IF sy-subrc <> 0.
      PERFORM get_ftext(rddfie00) USING 'T024E' 'EKORG' sy-langu
                                  CHANGING dfies g_subrc.
      SET CURSOR FIELD 'S_EKORG-LOW'.
      MESSAGE e348(m7) WITH dfies-scrtext_m.
    ENDIF.
  ENDIF.

* Purchase GROUP
  READ TABLE s_ekgrp INDEX 1 TRANSPORTING NO FIELDS.
  IF sy-subrc = 0.
    SELECT ekgrp INTO (l_ekgrp)
                 FROM t024 UP TO 1 ROWS WHERE ekgrp IN s_ekgrp.
    ENDSELECT.
    IF sy-subrc <> 0.
      PERFORM get_ftext(rddfie00) USING 'T024' 'EKGRP' sy-langu
                                  CHANGING dfies g_subrc.
      SET CURSOR FIELD 'S_EKGRP-LOW'.
      MESSAGE e348(m7) WITH dfies-scrtext_m.
    ENDIF.
  ENDIF.

ENDFORM.                    " INPUT_FIELD_CHECK
*&---------------------------------------------------------------------*
*&      Form  CLEARING_WORK_AREA
*&---------------------------------------------------------------------*
FORM clearing_work_area.

  IF p_full EQ 'X'.
    alv_detail_func = 'REUSE_ALV_GRID_DISPLAY'.
  ELSE.
    alv_detail_func = 'REUSE_ALV_LIST_DISPLAY'.
  ENDIF.

ENDFORM.                    " CLEARING_WORK_AREA
*&---------------------------------------------------------------------*
*&      Form  GET_DATA_FOR_DISPLAY
*&---------------------------------------------------------------------*
FORM get_data_for_display.

* 합계 텍스트용.
  CLEAR gs_totxt.
  CONCATENATE s_opndt-low+4(2) '월 실적' INTO gs_totxt.

*> PROGRESS Display.
  g_line1    = 30.
  g_out_text = '데이타를 검색 중입니다 %99999%%'(p01).
  REPLACE '%99999%' WITH g_line1 INTO g_out_text.
  PERFORM show_progress_bar(ztir0000) USING g_out_text g_line1.

  CLEAR g_total.
  DATA: ls_opndt   LIKE  ztitrqs-opndt,
        ls_opnd2   LIKE  ztitrqs-opndt,
        e_month(6) TYPE n.

*****SELECT 구분용.선택한달의 첫날.
  CLEAR e_month.
  e_month = s_opndt-low.
  CONCATENATE e_month '01' INTO ls_opnd2.

*****RANGE. 1월 1일 부터 선택한 월까지.
  RANGES: lr_opndt   FOR   ztitrqs-opndt OCCURS 1.
  MOVE: 'I'           TO    lr_opndt-sign,
        'BT'          TO    lr_opndt-option.
  CLEAR e_month.
  e_month = s_opndt-low(04).
  SHIFT e_month LEFT  BY 2 PLACES.
  CONCATENATE e_month '0101' INTO ls_opndt.
  MOVE   ls_opndt TO  lr_opndt-low.

  CALL FUNCTION 'SG_PS_GET_LAST_DAY_OF_MONTH'
    EXPORTING
      day_in            = ls_opnd2
    IMPORTING
      last_day_of_month = lr_opndt-high.

  APPEND lr_opndt.

*> 수입의뢰 데이타 select.
  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE it_lcst
    FROM ztivrq02
   WHERE bukrs  IN  s_bukrs        "회사코드.
     AND waers  IN  s_waers        "개설통화.
     AND buscl  IN  s_buscl        "사업구분.
     AND opnbk  IN  s_opnbk        "개설은행.
     AND ekorg  IN  s_ekorg        "구매조직.
     AND ekgrp  IN  s_ekgrp        "구매그룹.
     AND rcvun  IN  s_rcvun        "개설등록자.
     AND rcvdt  IN  s_rcvdt        "개설등록일자.
     AND cnam   IN  s_cnam         "작성인.
     AND cdat   IN  s_cdat         "생성일.
     AND unam   IN  s_unam         "최종변경인.
     AND udat   IN  s_udat         "변경일
*****>
     AND reqty  EQ  'LC'
     AND docst  EQ  'O'
     AND amdsq  EQ  space
     AND opnbk  NE  space
*     AND ilcty  NE  space
     AND opndt  IN  lr_opndt.        "개설일자.
  IF sy-subrc NE 0.
    MESSAGE s902.
    EXIT.
  ENDIF.


****AMEND 중 완료된 건이 있는 경우 그 OPEN AMOUNT를 가져옴.

  DATA : ls_amdsq LIKE ztitrqs-amdsq.

  LOOP AT it_lcst INTO gs_lcst.

    CLEAR ls_amdsq.
    SELECT MAX( amdsq )
      INTO ls_amdsq
      FROM ztitrqs
     WHERE reqno EQ gs_lcst-reqno
       AND docst EQ 'O'
     GROUP BY reqno.
    ENDSELECT.

    IF NOT ls_amdsq IS INITIAL.

      SELECT SINGLE waers buscl opamt usamt
        INTO (gs_lcst-waers, gs_lcst-buscl,
              gs_lcst-opamt, gs_lcst-usamt)
        FROM ztitrqs
       WHERE reqno EQ gs_lcst-reqno
         AND amdsq NE ls_amdsq.
*      IF sy-subrc EQ 0.
*        MODIFY it_lcst FROM gs_lcst.
*      ENDIF.
    ENDIF.

*   VENDOR의 국가 코드를 가져온다.
    SELECT SINGLE  land1
      INTO gs_lcst-land1
      FROM lfa1
     WHERE lifnr EQ gs_lcst-lifnr.

    MODIFY it_lcst FROM gs_lcst.

  ENDLOOP.

* 당월의 경우(it_col)  선택월 1일 부터 선택한 월 일까지.
* 누계의 경우(it_col2) 1월 1일 부터 선택한 월일까지.
  LOOP AT it_lcst INTO gs_lcst.
    IF gs_lcst-opndt BETWEEN ls_opnd2 AND lr_opndt-high.
      MOVE-CORRESPONDING gs_lcst TO gs_col.
      COLLECT gs_col INTO it_col.
    ENDIF.
    MOVE-CORRESPONDING gs_lcst TO gs_col2.
    COLLECT gs_col2 INTO it_col2.
  ENDLOOP.

  SORT it_col ASCENDING  BY land1 DESCENDING.

  LOOP AT it_col INTO gs_col.
    MOVE gs_col-land1 TO gs_list-land1.
    CASE gs_col-buscl.
      WHEN 'A'.
        MOVE gs_col-usamt TO gs_list-auamt.
      WHEN 'B'.
        MOVE gs_col-usamt TO gs_list-buamt.
      WHEN 'C'.
        MOVE gs_col-usamt TO gs_list-cuamt.
      WHEN 'D'.
        MOVE gs_col-usamt TO gs_list-duamt.
      WHEN OTHERS.
    ENDCASE.
    ADD gs_col-usamt TO gs_list-suamt.
    AT END OF land1.
      CLEAR gs_col2.
      READ TABLE it_col2 INTO gs_col2 WITH KEY land1 = gs_list-land1.
      MOVE gs_col2-usamt TO gs_list-tuamt.
      ADD  gs_col2-usamt TO g_total.
      APPEND gs_list TO it_list.
      CLEAR gs_list.
    ENDAT.
  ENDLOOP.

  DATA : gs_amount(20) TYPE c.
  LOOP AT it_list INTO gs_list.
    IF NOT g_total IS INITIAL.
      gs_list-tpert = ( gs_list-tuamt / g_total ) * 100.
    ENDIF.
*   천단위로 나누는 로직.
    PERFORM int_number_per1000 USING    'USD'         gs_list-auamt
                               CHANGING gs_list-auami.

    PERFORM int_number_per1000 USING    'USD'         gs_list-buamt
                               CHANGING gs_list-buami.

    PERFORM int_number_per1000 USING    'USD'         gs_list-cuamt
                               CHANGING gs_list-cuami.

    PERFORM int_number_per1000 USING    'USD'         gs_list-duamt
                               CHANGING gs_list-duami.

    PERFORM int_number_per1000 USING    'USD'         gs_list-suamt
                               CHANGING gs_list-suami.

    PERFORM int_number_per1000 USING    'USD'         gs_list-tuamt
                               CHANGING gs_list-tuami.
*은행명을 가져오는 로직.
    SELECT SINGLE landx
      INTO gs_list-landx
      FROM t005t
     WHERE land1 EQ gs_list-land1
       AND spras EQ 'E'."sy-langu.

    MODIFY it_list FROM gs_list.
  ENDLOOP.

  DESCRIBE TABLE it_list LINES g_line.
  IF g_line EQ 0.
    MESSAGE s902.
  ENDIF.

ENDFORM.                    " GET_DATA_FOR_DISPLAY
*&---------------------------------------------------------------------*
*&      Form  EXEC_ALV_F4
*&---------------------------------------------------------------------*
FORM exec_alv_f4.

  alv_repid = sy-repid.
  CLEAR: alv_variant.
  alv_variant-report = alv_repid.

  CALL FUNCTION 'REUSE_ALV_VARIANT_F4'
    EXPORTING
      is_variant = alv_variant
      i_save     = 'A'
    IMPORTING
      es_variant = alv_variant
    EXCEPTIONS
      not_found  = 2.
  IF sy-subrc = 2.
    MESSAGE ID sy-msgid TYPE 'S' NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ELSE.
    alv_def = alv_variant-variant.
  ENDIF.

ENDFORM.                    " EXEC_ALV_F4
*&---------------------------------------------------------------------*
*&      Form  SET_ALV_INIT
*&---------------------------------------------------------------------*
FORM set_alv_init.

  FREE:  it_sort, fc.
  CLEAR: alv_keyinfo, gs_layout, alv_print, fc.

* PRINTING SETTINGS
  gs_layout-get_selinfos = 'X'.
  gs_layout-group_change_edit = 'X'.

  alv_print-no_print_selinfos = 'X'.
  alv_print-no_coverpage = 'X'.
  alv_print-no_print_listinfos = 'X'.

ENDFORM.                    " SET_ALV_INIT
*&---------------------------------------------------------------------*
*&      Form  SET_FIELDCAT_BUILD
*&---------------------------------------------------------------------*
FORM set_fieldcat_build.
*----------------------------------------------------------------------*
* 필드명과 Output Length등을 사용자의 입맛에 맞게 바꿈.
*----------------------------------------------------------------------*
  PERFORM 3010_fill_field_category USING :
"개설통화
*
          'S' 'SELTEXT_M'     'LAND',
          ' ' 'TABNAME'       'IT_LIST',
          ' ' 'FIELDNAME'     'LAND1',
          ' ' 'NO_OUT'        'X',
*          ' ' 'KEY'           'X',
          'E' 'OUTPUTLEN'     '10',

*          'S' 'REF_TABNAME'   'ZTITIG04',
          'S' 'SELTEXT_M'     '구    분',
          ' ' 'TABNAME'       'IT_LIST',
          ' ' 'FIELDNAME'     'LANDX',
          ' ' 'NO_OUT'        ' ',
          ' ' 'KEY'           'X',
          'E' 'OUTPUTLEN'     '20',


"조선 미화금액.
          'S' 'SELTEXT_M'     '조    선',
          ' ' 'TABNAME'       'IT_LIST',
          ' ' 'FIELDNAME'     'AUAMT',
          ' ' 'CURRENCY'      'USD',
          ' ' 'NO_OUT'        'X',
          ' ' 'DO_SUM'        'X',
          'E' 'OUTPUTLEN'     '16',

"해양 미화금액.
          'S' 'TABNAME'       'IT_LIST',
          ' ' 'EDIT'          'X',
          ' ' 'SELTEXT_M'     '해    양',
          ' ' 'FIELDNAME'     'BUAMT',
          ' ' 'CURRENCY'      'USD',
          ' ' 'NO_OUT'        'X',
          ' ' 'DO_SUM'        'X',
          'E ' 'OUTPUTLEN'     '16',

"특수선 미화금액.
          'S' 'TABNAME'       'IT_LIST',
          ' ' 'SELTEXT_M'     '특 수 선',
          ' ' 'FIELDNAME'     'CUAMT',
          ' ' 'CURRENCY'      'USD',
          ' ' 'NO_OUT'        'X',
          ' ' 'DO_SUM'        'X',
          'E ' 'OUTPUTLEN'     '16',

"시설 미화금액.
          'S' 'TABNAME'       'IT_LIST',
          ' ' 'SELTEXT_M'     '시    설',
          ' ' 'CURRENCY'      'USD',
          ' ' 'NO_OUT'        'X',
          ' ' 'DO_SUM'        'X',
          ' ' 'FIELDNAME'     'DUAMT',
          'E' 'OUTPUTLEN'     '16',

"미화금액 계.
          'S' 'TABNAME'       'IT_LIST',
          ' ' 'SELTEXT_M'      gs_totxt,
          ' ' 'CURRENCY'      'USD',
          ' ' 'DO_SUM'        'X',
          ' ' 'SELTEXT_L'     '계',
          ' ' 'FIELDNAME'     'SUAMT',
          'E' 'OUTPUTLEN'     '40',


"개설금액.
          'S' 'SELTEXT_M'     '누    계',
          ' ' 'TABNAME'       'IT_LIST',
          ' ' 'CURRENCY'      'USD',
          ' ' 'DO_SUM'        'X',
          ' ' 'FIELDNAME'     'TUAMT',
          'E' 'OUTPUTLEN'     '40',
**********************************************

"개설금액.
          'S' 'SELTEXT_M'     '조    선',
          ' ' 'TABNAME'       'IT_LIST',
          ' ' 'FIELDNAME'     'AUAMI',
          ' ' 'NO_OUT'        'X',
          ' ' 'DO_SUM'        'X',
          'E' 'OUTPUTLEN'     '16',

"개설금액.
          'S' 'TABNAME'       'IT_LIST',
          ' ' 'SELTEXT_M'     '해    양',
          ' ' 'FIELDNAME'     'BUAMI',
          ' ' 'NO_OUT'        'X',
          ' ' 'DO_SUM'        'X',
          'E' 'OUTPUTLEN'     '16',

"개설금액.
          'S' 'TABNAME'       'IT_LIST',
          ' ' 'SELTEXT_M'     '특 수 선',
          ' ' 'FIELDNAME'     'CUAMI',
          ' ' 'NO_OUT'        'X',
          ' ' 'DO_SUM'        'X',
          'E' 'OUTPUTLEN'     '16',

"개설금액.
          'S' 'TABNAME'       'IT_LIST',
          ' ' 'SELTEXT_M'     '시     설',
          ' ' 'DO_SUM'        'X',
          ' ' 'NO_OUT'        'X',
          ' ' 'FIELDNAME'     'DUAMI',
          'E' 'OUTPUTLEN'     '16',

"개설금액.
          'S' 'TABNAME'       'IT_LIST',
          ' ' 'SELTEXT_M'      gs_totxt,
          ' ' 'DO_SUM'        'X',
          ' ' 'FIELDNAME'     'SUAMI',
          'E ' 'OUTPUTLEN'     '40',

"개설금액.
          'S' 'SELTEXT_M'     '누    계',
          ' ' 'TABNAME'       'IT_LIST',
          ' ' 'DO_SUM'        'X',
          ' ' 'FIELDNAME'     'TUAMI',
          'E' 'OUTPUTLEN'     '40',

**********************************************
"개설금액.
          'S' 'SELTEXT_L'     '%',
          ' ' 'TABNAME'       'IT_LIST',
          ' ' 'DO_SUM'        'X',
          ' ' 'FIELDNAME'     'TPERT',
          'E' 'OUTPUTLEN'     '10'.

  LOOP AT it_fieldcat INTO gs_fieldcat.

    CASE gs_fieldcat-fieldname.
*      WHEN 'ALAMT' OR 'AUAMT' OR 'BLAMT' OR
*           'BUAMT' OR 'CLAMT' OR 'CUAMT' OR
*           'DLAMT' OR 'DUAMT' OR 'SLAMT' OR
*           'SUAMT' OR 'TLAMT' OR 'TUAMT'.
      WHEN  'SUAMT' OR 'TUAMT'.
        IF p_cur EQ 'X'.
          gs_fieldcat-no_out = ' '.
        ELSE.
          gs_fieldcat-no_out = 'X'.
        ENDIF.

*      WHEN 'ALAMI' OR 'AUAMI' OR 'BLAMI' OR
*           'BUAMI' OR 'CLAMI' OR 'CUAMI' OR
*           'DLAMI' OR 'DUAMI' OR 'SLAMI' OR
*           'SUAMI' OR 'TLAMI' OR 'TUAMI'.
      WHEN 'SUAMI' OR 'TUAMI'.
        IF p_int EQ 'X'.
          gs_fieldcat-no_out = ' '.
        ELSE.
          gs_fieldcat-no_out = 'X'.
        ENDIF.
      WHEN OTHERS.
    ENDCASE.
    MODIFY it_fieldcat FROM gs_fieldcat.

  ENDLOOP.

ENDFORM.                    " SET_FIELDCAT_BUILD
*&---------------------------------------------------------------------*
*&      Form  DISPLAY_ALV_LIST
*&---------------------------------------------------------------------*
FORM display_alv_list.

  DATA: fc_detail TYPE slis_fieldcat_alv OCCURS 0 WITH HEADER LINE.
  DATA: variant_detail      LIKE disvariant.
  DATA: exit     TYPE slis_event_exit   OCCURS 0 WITH HEADER LINE.
  DATA: events   TYPE slis_alv_event    OCCURS 0 WITH HEADER LINE.
  DATA: groups   TYPE slis_sp_group_alv OCCURS 0 WITH HEADER LINE.

  SET TITLEBAR 'T1000' WITH '국가별 L/C OPEN 현황'.

* The detail ALV may modify the list (sorting). If returned to the
* base list, the original list needs to be restored.
  REFRESH fc_detail.
  LOOP AT it_fieldcat INTO gs_fieldcat.
    MOVE-CORRESPONDING gs_fieldcat TO fc_detail.
    CLEAR fc_detail-tabname.
    APPEND fc_detail.
  ENDLOOP.

  CLEAR variant_detail.
  variant_detail-report = alv_repid.
  variant_detail-handle = ' '.

  gs_layout-colwidth_optimize = ' '.
  gs_layout-zebra             = 'X'.
*  gs_layout-box_fieldname     = 'BOX'.

*>color field define.
  gs_layout-coltab_fieldname  = 'COLOR'.
  gs_layout-group_change_edit = 'X'.
  gs_layout-f2code            = 'DISPLAY'.

* header.
*  gs_layout-no_colhead        = 'X'.

*  GS_LAYOUT-SUBTOTALS_TEXT = 'TOTAL'.
  gs_layout-totals_text = ' TOTAL'.

  REFRESH exit.
  exit-ucomm = '&OL0'. exit-after = 'X'. APPEND exit.
  exit-ucomm = '&OLX'. APPEND exit.
  exit-ucomm = '&OAD'. APPEND exit.

*> event define.
  REFRESH events.
  events-name = slis_ev_top_of_page.
  events-form = 'TOP_OF_PAGE'.
  APPEND events.

  events-name = 'TOP_OF_LIST'.
  events-form = 'TOP_OF_LIST'.
  APPEND events.

*> ALV reuse function call..
  CALL FUNCTION alv_detail_func
      EXPORTING
        i_callback_program       = alv_repid
        i_callback_pf_status_set = 'SET_ALV_STATUS'
        i_callback_user_command  = 'USER_ALV_COMMAND'
*     I_STRUCTURE_NAME               =
*     IT_EXCLUDING                   =
*     IT_SPECIAL_GROUPS              =
*     IT_FILTER                      =
*     IS_SEL_HIDE                    =
*     I_DEFAULT                      = 'X'
*     I_SAVE                         = ' '
*     IS_VARIANT                     =
      it_events                      = events[]
      it_event_exit                  = exit[]
*     IS_PRINT                       =
*     IS_REPREP_ID                   =
*     I_SCREEN_START_COLUMN          = 0
*     I_SCREEN_START_LINE            = 0
*     I_SCREEN_END_COLUMN            = 0
*     I_SCREEN_END_LINE              = 0
        it_fieldcat              = fc_detail[]
        it_sort                  = it_sort
*        I_DEFAULT                = 'X'
*        IS_VARIANT               = VARIANT_DETAIL
        is_variant               = alv_variant
        i_save                   = c_save
        is_layout                = gs_layout
        is_print                 = alv_print
*   IMPORTING
*     E_EXIT_CAUSED_BY_CALLER        =
*     ES_EXIT_CAUSED_BY_USER         =
      TABLES
        t_outtab                 = it_list.

ENDFORM.                    " DISPLAY_ALV_LIST

*&---------------------------------------------------------------------*
*&      Form  SET_ALV_STATUS
*&---------------------------------------------------------------------*
FORM set_alv_status USING  extab TYPE slis_t_extab.


  APPEND 'ARCHIVE'   TO extab.
  APPEND '&VEXCEL'   TO extab.
  APPEND '&AQW'      TO extab.
  APPEND '&VCRYSTAL' TO extab.
  APPEND '&VGRID'    TO extab.
  APPEND '&EB9'      TO extab.
  APPEND '&CRDESIG'  TO extab.

  APPEND 'ZTIT002'  TO extab.
  APPEND 'ZTIT005'  TO extab.
  APPEND 'ZTIT006'  TO extab.

  APPEND '&OL0'  TO extab.
  APPEND '&OAD'  TO extab.
  APPEND '&AVE'  TO extab.


  SET PF-STATUS 'STANDARD' EXCLUDING extab.

ENDFORM.                    " SET_ALV_STATUS

*&---------------------------------------------------------------------*
*&      Form  USER_ALV_COMMAND
*&---------------------------------------------------------------------*
FORM user_alv_command USING   r_ucomm      LIKE sy-ucomm
                              rs_selfield  TYPE slis_selfield.
*
  DATA: l_count   TYPE i.
  DATA: l_subrc   LIKE sy-subrc.
  DATA: l_tcode   LIKE sy-tcode.

  CASE r_ucomm.
    WHEN 'ZTIT002' OR 'ZTIT005' OR 'ZTIT006'.

  ENDCASE.
  CLEAR: r_ucomm.

ENDFORM.                    " USER_ALV_COMMAND
*&---------------------------------------------------------------------*
*&      Form  ALV_VARIANT_CHECK
*&---------------------------------------------------------------------*
FORM alv_variant_check.

  alv_variant-report = alv_repid.
  alv_variant-variant = alv_def.
  IF NOT alv_def IS INITIAL.
    CALL FUNCTION 'REUSE_ALV_VARIANT_EXISTENCE'
      EXPORTING
        i_save     = 'A'
      CHANGING
        cs_variant = alv_variant
      EXCEPTIONS
        OTHERS     = 1.
    IF sy-subrc <> 0.
      MESSAGE e321(m7) WITH alv_def alv_repid.
    ENDIF.
  ENDIF.

ENDFORM.                    " ALV_VARIANT_CHECK
*&---------------------------------------------------------------------*
*&      Form  SET_SORT_FIELD
*&---------------------------------------------------------------------*
FORM set_sort_field.

  REFRESH: it_sort.

*  CLEAR  st_sort.
*  st_sort-spos = '01'.
*  st_sort-fieldname = 'REQNO'.
*  st_sort-tabname   = '<GT_TABLE>'.
*  st_sort-up        = 'X'.
**  ST_SORT-GROUP     = 'X'.
*  st_sort-subtot    = 'X'.
**  ST_SORT-EXPA      = 'X'.
*  APPEND st_sort TO it_sort.
*
*  CLEAR  st_sort.
*  st_sort-spos = '02'.
*  st_sort-fieldname = 'MTBEZ'.
*  st_sort-tabname   = 'ITAB'.
*  st_sort-up        = 'X'.
**  ST_SORT-GROUP     = 'X'.
**  ST_SORT-SUBTOT    = 'X'.
**  ST_SORT-EXPA      = 'X'.
*  APPEND st_sort TO it_sort.
*
*  CLEAR  st_sort.
*  st_sort-spos = '03'.
*  st_sort-fieldname = 'EBELN'.
*  st_sort-tabname   = 'ITAB'.
*  st_sort-up        = 'X'.
**  ST_SORT-GROUP     = 'X'.
**  ST_SORT-SUBTOT    = 'X'.
**  ST_SORT-EXPA      = 'X'.
*  APPEND st_sort TO it_sort.

ENDFORM.                    " SET_SORT_FIELD

*&---------------------------------------------------------------------*
*&      Form  TOP_OF_PAGE
*&---------------------------------------------------------------------*
FORM top_of_page.

  DATA: l_mode TYPE i.
  DATA: header TYPE slis_listheader OCCURS 0 WITH HEADER LINE.

  REFRESH header.

*  header-typ = 'H'.
*
*  header-info = '통화별 L/C OPEN 현황'.
*  CLEAR: header-key.
*  APPEND header.
*
*  header-typ = 'S'.
*  header-key = '출력일자'.
*  WRITE: sy-datlo TO header-info.
*  APPEND header.
*
*  CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
*    EXPORTING
*      it_list_commentary = header[].

** JS전선 회사코드 2007/04 KSH --------------------------------------
  DATA: l_butxt LIKE t001-butxt.
  CLEAR: l_butxt.
  SELECT SINGLE butxt FROM t001
                      INTO l_butxt
                     WHERE bukrs EQ s_bukrs-low.

  header-typ = 'S'.
  header-key = '회사코드 '.
  CONCATENATE s_bukrs-low l_butxt INTO header-info SEPARATED BY space.
  APPEND header.
** JS전선 회사코드 2007/04 KSH --------------------------------------

  WRITE: '국가별 L/C OPEN 현황'.
*  WRITE: sy-uline.
** JS전선 회사코드 2007/04 KSH --------------------------------------
  SKIP.
  WRITE: '회사코드 :  ', header-info.
** JS전선 회사코드 2007/04 KSH --------------------------------------
  SKIP.
  WRITE: '출력일자 :  ', sy-datlo.
  IF p_int EQ'X'.
    WRITE (100) '(단위 천미불)' RIGHT-JUSTIFIED.
  ELSE.
    WRITE (100) '(단위 미불)' RIGHT-JUSTIFIED.
  ENDIF.
*  WRITE: sy-uline.
*  FORMAT COLOR 1.
*  WRITE:/ sy-vline NO-GAP,
*          (10) '구분'     CENTERED , sy-vline ,
*          (32) '조    선'     CENTERED NO-GAP, sy-vline ,
*          (32) '해    양'     CENTERED NO-GAP, sy-vline ,
*          (32) '특 수 선'   CENTERED NO-GAP, sy-vline ,
*          (32) '시    설'     CENTERED NO-GAP, sy-vline ,
*          (32) gs_totxt    CENTERED NO-GAP, sy-vline ,
*          (32) '누    계'     CENTERED NO-GAP, sy-vline ,
*          (9) ' '        CENTERED NO-GAP, sy-vline NO-GAP.
*  WRITE: sy-uline.
*  WRITE:/ sy-vline NO-GAP,
*          (10) '통화'     CENTERED , sy-vline NO-GAP,
*          (16) '외화금액' CENTERED NO-GAP, sy-vline NO-GAP,
*          (16) '미화환산' CENTERED NO-GAP, sy-vline NO-GAP,
*          (16) '외화금액' CENTERED NO-GAP, sy-vline NO-GAP,
*          (16) '미화환산' CENTERED NO-GAP, sy-vline NO-GAP,
*          (16) '외화금액' CENTERED NO-GAP, sy-vline NO-GAP,
*          (16) '미화환산' CENTERED NO-GAP, sy-vline NO-GAP,
*          (16) '외화금액' CENTERED NO-GAP, sy-vline NO-GAP,
*          (16) '미화환산' CENTERED NO-GAP, sy-vline NO-GAP,
*          (16) '외화금액' CENTERED NO-GAP, sy-vline NO-GAP,
*          (16) '미화환산' CENTERED NO-GAP, sy-vline NO-GAP,
*          (16) '외화금액' CENTERED NO-GAP, sy-vline NO-GAP,
*          (16) '미화환산' CENTERED NO-GAP, sy-vline NO-GAP,
*          (10) '%'        CENTERED NO-GAP, sy-vline NO-GAP.

ENDFORM.    ">TOP_OF_PAGE

*&---------------------------------------------------------------------*
*&      Form  TOP_OF_LIST
*&---------------------------------------------------------------------*
FORM top_of_list.
*break-point.
*do 10 times.
*  write / 'TOP-OF-LIST'.
*enddo.
*WRITE: SY-ULINE.
*WRITE:/ SY-VLINE NO-GAP,
*        (10) '구분', SY-VLINE,
*        (32) '조선' centered no-gap,SY-VLINE,
*        (32) '해양' centered no-gap,SY-VLINE,
*        (32) '특수선' centered no-gap,SY-VLINE,
*        (32) '시설' centered no-gap,SY-VLINE,
*        (32) '미정' centered no-gap,SY-VLINE,
*        (32) '계' centered no-gap,SY-VLINE.

ENDFORM.                    "TOP_OF_LIST

*&---------------------------------------------------------------------*
*&      Form  MATERIAL_MASTER_DISPLAY
*&---------------------------------------------------------------------*
FORM material_master_display USING rs_selfield  TYPE slis_selfield.
*
*  FIELD-SYMBOLS: <ls_table>.
*
*  READ TABLE <gt_table> INTO <ls_table>
*                        INDEX rs_selfield-tabindex. "cursorposit.
*  IF sy-subrc EQ 0.
**    MOVE-CORRESPONDING <ls_table> TO xitab.
**
**    READ TABLE organ WITH KEY werks = xitab-werks.
**
**    SET PARAMETER ID 'MAT' FIELD xitab-matnr.
**    SET PARAMETER ID 'BUK' FIELD organ-bukrs.
**    SET PARAMETER ID 'WRK' FIELD xitab-werks.
*    SET PARAMETER ID 'LAG' FIELD ''.
**  SET PARAMETER ID 'MXX' FIELD 'KDEALBSZXVPCFQG'.
*    SET PARAMETER ID 'MXX' FIELD 'KDE'.
*
*    CALL TRANSACTION 'MM03' AND SKIP  FIRST SCREEN.
*  ELSE.
*    MESSAGE s901.
*  ENDIF.

ENDFORM.                    " MATERIAL_MASTER_DISPLAY
*&---------------------------------------------------------------------*
*&      Form  set_colorize_build
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM set_colorize_build .


ENDFORM.                    " set_colorize_build

*&---------------------------------------------------------------------*
*&      Form  3010_fill_field_category
*&---------------------------------------------------------------------*
FORM 3010_fill_field_category  USING  p_section p_fname p_value.

  DATA l_col(40).
  FIELD-SYMBOLS <l_fs>.

  IF p_section = 'S'.
    CLEAR gs_fieldcat.
  ENDIF.

* 속성 MOVE
  CONCATENATE 'GS_FIELDCAT-' p_fname  INTO l_col.
  ASSIGN      (l_col)         TO       <l_fs>.
  MOVE         p_value        TO       <l_fs>.

  IF p_section = 'E'.
    APPEND gs_fieldcat TO it_fieldcat.
  ENDIF.
ENDFORM.                    " 3010_fill_field_category
*&---------------------------------------------------------------------*
*&      Form  INT_NUMBER_PER1000
*&---------------------------------------------------------------------*
FORM int_number_per1000  USING    p_waers
                                  p_amtt
                         CHANGING p_amti.

* 단위를 EXTERNAL로 변환뒤 1000을 나누고 INT필드에 넣어줌.
*(자동 반올림).
  CALL FUNCTION 'Z_TI_INT_NUMBER_PER1000'
    EXPORTING
      w_waers = p_waers
      w_opamt = p_amtt
    IMPORTING
      w_int   = p_amti.



ENDFORM.                    " INT_NUMBER_PER1000
*&---------------------------------------------------------------------*
*&      Form  EXEC_MONAT_F4
*&---------------------------------------------------------------------*
FORM exec_monat_f4 .

  DATA: BEGIN OF mf_dynpfields OCCURS 1.
          INCLUDE STRUCTURE dynpread.
  DATA: END   OF mf_dynpfields.
  DATA: mf_returncode   LIKE sy-subrc,
        mf_monat        LIKE isellist-month,
        mf_hlp_repid    LIKE sy-repid.

* Wert von Dynpro lesen
  GET CURSOR FIELD mf_dynpfields-fieldname.
  APPEND mf_dynpfields.
  mf_hlp_repid = sy-repid.
  DO 2 TIMES.
    CALL FUNCTION 'DYNP_VALUES_READ'
      EXPORTING
        dyname               = mf_hlp_repid
        dynumb               = sy-dynnr
      TABLES
        dynpfields           = mf_dynpfields
      EXCEPTIONS
        invalid_abapworkarea = 01
        invalid_dynprofield  = 02
        invalid_dynproname   = 03
        invalid_dynpronummer = 04
        invalid_request      = 05
        no_fielddescription  = 06
        undefind_error       = 07.
    IF sy-subrc = 3.
      mf_hlp_repid = sy-repid.
    ELSE.
      READ TABLE mf_dynpfields INDEX 1.
      TRANSLATE mf_dynpfields-fieldvalue USING '_ '.
      EXIT.
    ENDIF.
  ENDDO.
  IF sy-subrc = 0.
    CALL FUNCTION 'CONVERSION_EXIT_PERI_INPUT'
      EXPORTING
        input         = mf_dynpfields-fieldvalue
      IMPORTING
        output        = mf_monat
      EXCEPTIONS
        error_message = 1.
    IF sy-subrc NE 0.
      EXIT.
    ENDIF.

    IF mf_monat IS INITIAL.
      mf_monat = sy-datlo(6).
    ENDIF.

    CALL FUNCTION 'POPUP_TO_SELECT_MONTH'
      EXPORTING
        actual_month               = mf_monat
      IMPORTING
        selected_month             = mf_monat
        return_code                = mf_returncode
      EXCEPTIONS
        factory_calendar_not_found = 01
        holiday_calendar_not_found = 02
        month_not_found            = 03.
    IF sy-subrc = 0 AND mf_returncode = 0.
      CALL FUNCTION 'CONVERSION_EXIT_PERI_OUTPUT'
        EXPORTING
          input  = mf_monat
        IMPORTING
          output = mf_dynpfields-fieldvalue.

      COLLECT mf_dynpfields.

      CALL FUNCTION 'DYNP_VALUES_UPDATE'
        EXPORTING
          dyname               = mf_hlp_repid
          dynumb               = sy-dynnr
        TABLES
          dynpfields           = mf_dynpfields
        EXCEPTIONS
          invalid_abapworkarea = 01
          invalid_dynprofield  = 02
          invalid_dynproname   = 03
          invalid_dynpronummer = 04
          invalid_request      = 05
          no_fielddescription  = 06
          undefind_error       = 07.
      IF sy-subrc NE 0.
        EXIT.
      ENDIF.
    ENDIF.
  ENDIF.

ENDFORM.                    " EXEC_MONAT_F4
