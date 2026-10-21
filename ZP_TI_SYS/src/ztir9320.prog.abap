************************************************************************
*                                                                      *
* Title         : ZTIR9320                                             *
*                                                                      *
* Description   : [Report] 수입원자재 회계문서 일계표(B/L)             *
*                                                                      *
* Creation Date : 2004/12/23                                           *
*                                                                      *
* Author        : Jong Pil, Park                                       *
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
PROGRAM   ztir9320
          MESSAGE-ID zmti00
          NO STANDARD PAGE HEADING.

************************************************************************
* TYPES and TYPE-POOLS                                                 *
************************************************************************
TYPE-POOLS: slis.   "> Globale Type(ALV)
TYPES: int13 TYPE i.
TYPES: BEGIN OF ty_header.
TYPES: iblno     LIKE  ztitblk-iblno,   "B/L 관리번호
       blnum     LIKE  ztitblk-blnum,   "B/L 번호
       cdat      LIKE  ztitblk-cdat ,   "생성일
       rnam      LIKE  ztitblk-rnam,    "선적정보 확인 담당자.
       tport     LIKE  ztitblk-tport,   "도착항.
       fport     LIKE  ztitblk-fport,   "선적항.
       fland     LIKE  ztitblk-fland,   "선적국가.
       brgew     LIKE  ztitblk-brgew,   "총중량.
       gewei     LIKE  ztitblk-gewei,   "중량단위.
       volum     LIKE  ztitblk-volum,   "볼륨.
       voleh     LIKE  ztitblk-voleh,   "부피단위.
       fwdfm     LIKE  ztitblk-fwdfm,   "운송형태.
       ddtext     LIKE  dd07d-ddtext,   "운송형태설명.
       inco1     LIKE  ztitblk-inco1,   "인도조건.
       ctnq2     LIKE  ztitblk-ctnq2,   "컨테이너수.
       ctnq4     LIKE  ztitblk-ctnq4.   "컨테이너수.

TYPES: END OF ty_header.

TYPES: BEGIN OF ty_list.
TYPES: iblno     LIKE  ztitblk-iblno,   "B/L 관리번호
       refno    LIKE  ztivcs00-refno,   "관련번호.
       icsno  LIKE  ztivcs00-icsno,     "수입비용 문서번호
       belnr  LIKE  ztivcs00-belnr,      "회계전표번호.
       expcd  LIKE  ztivcs00-expcd,      "수입비용코드.
       exptx  LIKE  ztitig06-exptx,      "비용 설명
       wrbtr  LIKE  ztivcs00-wrbtr,     "전표통화금액.
       waers  LIKE  ztivcs00-waers,     "통화키
       lifnr  LIKE  ztivcs00-lifnr,     "구매처 또는 채권자 계정번호
       name1  LIKE  lfa1-name1,         "구매처명
       cstyp  LIKE  ztivcs00-cstyp,     "전표정산 종류(A/P).
       ddtext  LIKE  dd07d-ddtext,     "전표정산설명.
       mwskzh LIKE  ztivcs00-mwskzh,    "부가가치세 코드.
       bupla  LIKE  ztivcs00-bupla,     "사업장
       bldat  LIKE  ztivcs00-bldat,     "전표증빙일
       udath  LIKE  ztivcs00-udath,     "변경일.
       utmeh  LIKE  ztivcs00-utmeh,     "최종변경시간.
       budat  LIKE  ztivcs00-budat.     "전표의 전기일.


TYPES: END OF ty_list.

TYPES: BEGIN OF ty_lcst.
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
        dfies ,    ">DD Interface: Table Fields for DDIF_FIELDINFO_GET
        ztitblk,    ">Bill of Lading Header table.
        ztivcs00.  ">수입비용 Views ( 비용 Header + 비용 Item )

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

DATA: it_header       TYPE STANDARD TABLE OF ty_header,
      gs_header       TYPE ty_header,
      ls_header       TYPE ty_header.

DATA : it_list_tmp  TYPE STANDARD TABLE OF ty_list,
      gs_list_tmp      TYPE ty_list,
      ls_list_tmp      TYPE ty_list.


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
DATA: gs_keyinfo          TYPE slis_keyinfo_alv.

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
** JS전선 회사코드 2007/04 BY-MH.LEE -----------------
*    c_bukrs     LIKE t001-bukrs     VALUE '1000',   ">Company code
** JS전선 회사코드 2007/04 ---------------------------
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
DATA: gs_totxt(16) TYPE c,
      gs_netxt(16) TYPE c.

************************************************************************
* SELECT-OPTIONS / PARAMETERS                                          *
************************************************************************
SELECTION-SCREEN BEGIN OF BLOCK box1 WITH FRAME TITLE text-001.
SELECT-OPTIONS:
  s_bukrs  FOR ztivcs00-bukrs                   "회사코드.
               NO-EXTENSION NO INTERVALS OBLIGATORY
                    MEMORY ID buk .
SELECT-OPTIONS:
  s_udath   FOR ztivcs00-udath,                  "변경일.
  s_utmeh  FOR ztivcs00-utmeh,                  "최종변경시간.
  s_iname  FOR ztivcs00-iname.                 "입력담당자.

SELECTION-SCREEN END OF BLOCK box1.

SELECTION-SCREEN BEGIN OF BLOCK lists WITH FRAME TITLE text-002.
PARAMETERS: alv_def LIKE disvariant-variant.
SELECTION-SCREEN END OF BLOCK lists.

************************************************************************
* INITIALIZATION Event                                                 *
************************************************************************
INITIALIZATION.
  PERFORM  set_initial_data.
  PERFORM  set_alv_init.             ">Initialize ALV variable

************************************************************************
* AT SELECTION-SCREEN Events                                           *
************************************************************************

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
*  LOOP AT SCREEN.
*    CHECK screen-group1 = 'OPN'.
*    screen-invisible = '1'.
*    MODIFY SCREEN.
*  ENDLOOP.
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
  PERFORM set_key_infomation_build.
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
  SET TITLEBAR 'T1000'  .

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


ENDFORM.                    " INPUT_FIELD_CHECK
*&---------------------------------------------------------------------*
*&      Form  CLEARING_WORK_AREA
*&---------------------------------------------------------------------*
FORM clearing_work_area.

*  IF p_full EQ 'X'.
*    alv_detail_func = 'REUSE_ALV_GRID_DISPLAY'.
*  ELSE.
*    alv_detail_func = 'REUSE_ALV_LIST_DISPLAY'.
*  ENDIF.

ENDFORM.                    " CLEARING_WORK_AREA
*&---------------------------------------------------------------------*
*&      Form  GET_DATA_FOR_DISPLAY
*&---------------------------------------------------------------------*
FORM get_data_for_display.

  CLEAR : gs_totxt, gs_netxt.
  DATA  : ls_calcu(2)  TYPE n,
          l_iblno(30).

  CLEAR g_total.

*> 수입비용 Views 데이타 select."
  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE it_list
    FROM ztivcs00
   WHERE bukrs  IN  s_bukrs        "회사코드.
     AND udath  IN  s_udath        "변경일.
     AND utmeh  IN  s_utmeh        "최종변경시간.
     AND iname  IN  s_iname       "입력담당자.
     AND expgr  EQ  'B'.
  IF sy-subrc NE 0.
    MESSAGE s902.
    EXIT.
  ENDIF.


*>변경일,최종변경시간 정렬.
  SORT it_list BY  udath utmeh.

  LOOP AT it_list INTO gs_list.
    IF gs_list-belnr IS INITIAL.
      CONTINUE.
    ENDIF.

    SELECT SINGLE *
      INTO CORRESPONDING FIELDS OF  gs_header
      FROM ztitblk
     WHERE  iblno EQ gs_list-refno.

    IF sy-subrc NE 0.
      CONTINUE.
    ELSE.
*    read table it_header with table key iblno = gs_list-refno.
*    if sy-subrc eq 0.
*      continue.
*    endif.
      PERFORM  get_domain_value_text(ztir0000) USING 'ZTIFWDFM'
                                                     gs_header-fwdfm
                                                     gs_header-ddtext.
      gs_list-iblno = gs_header-iblno.
      APPEND gs_header TO it_header.

    ENDIF.

*>전표정산설명
    PERFORM  get_domain_value_text(ztir0000) USING 'ZTICSTYP'
                                                   gs_list-cstyp
                                                   gs_list-ddtext.
*>비용설명
    SELECT SINGLE exptx
      INTO gs_list-exptx
      FROM ztitig06
      WHERE expcd EQ gs_list-expcd
       AND  expgr EQ 'B'.

*>거래처명.
    SELECT SINGLE name1
        INTO gs_list-name1
        FROM lfa1
        WHERE lifnr EQ gs_list-lifnr.

    MODIFY it_list FROM gs_list.

  ENDLOOP.

  SORT it_header BY iblno.
*>중복 iblno 제거.
  LOOP AT it_header INTO gs_header.
    IF l_iblno EQ gs_header-iblno.
      DELETE TABLE it_header FROM gs_header.
    ENDIF.
    l_iblno = gs_header-iblno.
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

"B/L 관리번호
          'S' 'TABNAME'       'IT_HEADER',
          ' ' 'REF_TABNAME'   'ZTITBLK',
          ' ' 'FIELDNAME'     'IBLNO',
          ' ' 'NO_OUT'        ' ',
          ' ' 'KEY'           'X',
          'E' 'OUTPUTLEN'     '16',
"B/L 번호
*          'S' 'REF_TABNAME'   'ZTITIG04',
*          'S' 'SELTEXT_M'     '구    분',
          'S' 'TABNAME'       'IT_HEADER',
          ' ' 'REF_TABNAME'   'ZTITBLK',
          ' ' 'FIELDNAME'     'BLNUM',
          ' ' 'NO_OUT'        ' ',
          ' ' 'KEY'           'X',
          'E' 'OUTPUTLEN'     '16',

"생성일

          'S' 'TABNAME'       'IT_HEADER',
*          ' ' 'SELTEXT_M'     '결제구분',
          ' ' 'REF_TABNAME'   'ZTITBLK',
          ' ' 'FIELDNAME'     'CDAT',
*          ' ' 'CURRENCY'      'USD',
*          ' ' 'NO_OUT'        ' ',
*          ' ' 'DO_SUM'        ' ',
          'E' 'OUTPUTLEN'     '11',

"선적정보 확인 담당자
*          'S' 'SELTEXT_M'     '2002 년  실적',
          'S' 'TABNAME'       'IT_HEADER',
          ' ' 'REF_TABNAME'   'ZTITBLK',
          ' ' 'FIELDNAME'     'RNAM',
*          ' ' 'CURRENCY'      'USD',
*          ' ' 'NO_OUT'        ' ',
*          ' ' 'DO_SUM'        ' ',
          'E' 'OUTPUTLEN'     '30',

"도착항
*          'S' 'SELTEXT_M'     '2002 년  실적',
          'S' 'TABNAME'       'IT_HEADER',
          ' ' 'REF_TABNAME'   'ZTITBLK',
          ' ' 'FIELDNAME'     'TPORT',
          ' ' 'NO_OUT'        ' ',
          ' ' 'DO_SUM'        ' ',
          'E' 'OUTPUTLEN'     '10',


"선적항.
          'S' 'TABNAME'       'IT_HEADER',
*          ' ' 'EDIT'          'X',
*          ' ' 'SELTEXT_M'     '2003 년  계획',
          ' ' 'REF_TABNAME'   'ZTITBLK',
          ' ' 'FIELDNAME'     'FPORT',
          ' ' 'NO_OUT'        ' ',
          ' ' 'DO_SUM'        ' ',
          'E ' 'OUTPUTLEN'     '10',

"선적국가.
          'S' 'TABNAME'       'IT_HEADER',
*          ' ' 'SELTEXT_M'      ' ',
          ' ' 'REF_TABNAME'   'ZTITBLK',
          ' ' 'FIELDNAME'     'FLAND',
          ' ' 'NO_OUT'        ' ',
          ' ' 'DO_SUM'        ' ',
          'E' 'OUTPUTLEN'     '10',

"총중량
          'S' 'TABNAME'       'IT_HEADER',
*          ' ' 'SELTEXT_M'      gs_totxt,
          ' ' 'REF_TABNAME'   'ZTITBLK',
          ' ' 'FIELDNAME'     'BRGEW',
          ' ' 'QFIELDNAME'      'GEWEI',
*          ' ' 'NO_OUT'        'X',
          ' ' 'DO_SUM'        'X',
          'E ' 'OUTPUTLEN'     '11',

"중량단위.
          'S' 'TABNAME'       'IT_HEADER',
*          ' ' 'SELTEXT_M'     '미결금액',
          ' ' 'REF_TABNAME'   'ZTITBLK',
          ' ' 'FIELDNAME'     'GEWEI',
*          ' ' 'NO_OUT'        'X',
*          ' ' 'DO_SUM'        'X',
          'E ' 'OUTPUTLEN'     '4',

"볼륨.
          'S' 'TABNAME'       'IT_HEADER',
          ' ' 'SELTEXT_M'     '미결금액',
          ' ' 'REF_TABNAME'   'ZTITBLK',
          ' ' 'FIELDNAME'     'VOLUM',
          ' ' 'QFIELDNAME'      'VOLEH',
*          ' ' 'NO_OUT'        'X',
          ' ' 'DO_SUM'        'X',
          'E ' 'OUTPUTLEN'     '12',

"부피단위.
          'S' 'TABNAME'       'IT_HEADER',
          ' ' 'REF_TABNAME'   'ZTITBLK',
          ' ' 'FIELDNAME'     'VOLEH',
*          ' ' 'NO_OUT'        'X',
*          ' ' 'DO_SUM'        'X',
          'E ' 'OUTPUTLEN'     '4',


"운송형태 .
          'S' 'TABNAME'       'IT_HEADER',
          ' ' 'SELTEXT_M'     ' 운송형태',
          ' ' 'SELTEXT_L'     ' 운송형태',
          ' ' 'REF_TABNAME'   'DD07D',
          ' ' 'FIELDNAME'     'DDTEXT',
          ' ' 'NO_OUT'        ' ',
*          ' ' 'DO_SUM'        'X',
          'E' 'OUTPUTLEN'     '16',

"인도조건.
          'S' 'TABNAME'       'IT_HEADER',
*          ' ' 'SELTEXT_M'      gs_totxt,
          ' ' 'REF_TABNAME'   'ZTITBLK',
          ' ' 'FIELDNAME'     'INCO1',
          ' ' 'NO_OUT'        ' ',
*          ' ' 'DO_SUM'        'X',
          'E' 'OUTPUTLEN'     '8',

"컨테이너수2.
          'S' 'TABNAME'       'IT_HEADER',
          ' ' 'SELTEXT_M'      '20Ct',
          ' ' 'REF_TABNAME'   'ZTITBLK',
          ' ' 'FIELDNAME'     'CTNQ2',
          ' ' 'NO_OUT'        ' ',
          ' ' 'DO_SUM'        'X',
          'E' 'OUTPUTLEN'     '6',

"컨테이너수4.
          'S' 'TABNAME'       'IT_HEADER',
          ' ' 'SELTEXT_M'      '40Ct',
          ' ' 'REF_TABNAME'   'ZTITBLK',
          ' ' 'FIELDNAME'     'CTNQ4',
          ' ' 'NO_OUT'        ' ',
          ' ' 'DO_SUM'        'X',
          'E' 'OUTPUTLEN'     '6',



"회계전표번호.
          'S' 'TABNAME'       'IT_LIST',
          ' ' 'REF_TABNAME'   'ZTIVCS00',
*          ' ' 'SELTEXT_L'     ' A',
          ' ' 'FIELDNAME'     'BELNR',
          'E' 'OUTPUTLEN'     '16',


"비용항목
          'S' 'TABNAME'       'IT_LIST',
          ' ' 'SELTEXT_M'      '비용항목',
          ' ' 'REF_TABNAME'   'ZTIVCS00',
          ' ' 'FIELDNAME'     'EXPTX',
*          ' ' 'NO_OUT'        'X',
*          ' ' 'DO_SUM'        'X',
          'E' 'OUTPUTLEN'     '16',

"전표통화금액.
          'S' 'TABNAME'       'IT_LIST',
          ' ' 'REF_TABNAME'   'ZTIVCS00',
          ' ' 'FIELDNAME'     'WRBTR',
          ' ' 'DO_SUM'        'X',
*          ' ' 'NO_OUT'        'X',
          ' ' 'CFIELDNAME'    'WAERS',
          'E' 'OUTPUTLEN'     '11',

************************************************************
*> For TraSys ECC Upgrade By ASEG Co., Ltd.
************************************************************
*> 2009/02/16
*> Started of Insert
************************************************************
"통화
          'S' 'TABNAME'       'IT_LIST',
*          ' ' 'SELTEXT_M'     '통화',
          ' ' 'REF_TABNAME'   'ZTIVCS00',
          ' ' 'NO_OUT'        'X',
*          ' ' 'DO_SUM'        'X',
          ' ' 'FIELDNAME'     'WAERS',
          'E' 'OUTPUTLEN'     '5',
************************************************************
*> Ended of Insert
************************************************************

"구매처
          'S' 'TABNAME'       'IT_LIST',
*          ' ' 'SELTEXT_M'     '지출 내역',
          ' ' 'REF_TABNAME'   'ZTIVCS00',
          ' ' 'NO_OUT'        'X',
*          ' ' 'DO_SUM'        'X',
          ' ' 'FIELDNAME'     'LIFNR',
          'E' 'OUTPUTLEN'     '10',

"구매처명
          'S' 'TABNAME'       'IT_LIST',
          ' ' 'SELTEXT_M'     '구매처명',
          ' ' 'DO_SUM'        ' ',
          ' ' 'NO_OUT'        ' ',
          ' ' 'REF_TABNAME'   'LFA1',
          ' ' 'FIELDNAME'     'NAME1',
          'E' 'OUTPUTLEN'     '30',

"전표정산 종류(A/P).

          'S' 'TABNAME'       'IT_LIST',
          ' ' 'REF_TABNAME'   'ZTIVCS00',
          ' ' 'FIELDNAME'     'CSTYP',
          ' ' 'NO_OUT'        'X',
          ' ' 'DO_SUM'        ' ',
          'E' 'OUTPUTLEN'     '10',

"전표정산 종류(A/P).
          'S' 'TABNAME'       'IT_LIST',
          ' ' 'SELTEXT_M'     ' 전표정산',
          ' ' 'SELTEXT_L'     ' 전표정산',
          ' ' 'REF_TABNAME'   'DD07D',
          ' ' 'FIELDNAME'     'DDTEXT',
          ' ' 'NO_OUT'        ' ',
*          ' ' 'DO_SUM'        'X',
          'E' 'OUTPUTLEN'     '10',

"부가가치세 코드.
          'S' 'REF_TABNAME'   'ZTIVCS00',
*          'S' 'SELTEXT_M'     '구    분',
          ' ' 'TABNAME'       'IT_LIST',
          ' ' 'REF_TABNAME'   'ZTIVCS00',
          ' ' 'FIELDNAME'     'MWSKZH',
          ' ' 'OUTPUTLEN'     '10',
          'E' 'NO_OUT'        ' ',


"사업장
          'S' 'REF_TABNAME'   'ZTIVCS00',
          'S' 'SELTEXT_M'     '사업장',
          ' ' 'TABNAME'       'IT_LIST',
          ' ' 'REF_TABNAME'   'ZTIVCS00',
          ' ' 'FIELDNAME'     'BUPLA',
          ' ' 'NO_OUT'        ' ',
          'E' 'OUTPUTLEN'     '10',

"전표증빙일.
          'S' 'REF_TABNAME'   'ZTIVCS00',
*          'S' 'SELTEXT_M'     '구    분',
          ' ' 'TABNAME'       'IT_LIST',
          ' ' 'FIELDNAME'     'BLDAT',
          ' ' 'OUTPUTLEN'     '11',
          'E' 'NO_OUT'        ' '.



**********************************************

*  LOOP AT it_fieldcat INTO gs_fieldcat.
*
*    CASE gs_fieldcat-fieldname.
*      WHEN 'PRAMT' OR 'FUAMT' OR 'SUAMT' OR
*           'TUAMT' OR 'MOAMT'.
*        IF p_cur EQ 'X'.
*          gs_fieldcat-no_out = ' '.
*        ELSE.
*          gs_fieldcat-no_out = 'X'.
*        ENDIF.
*
*      WHEN 'PRAMI' OR 'FUAMI' OR 'SUAMI' OR
*           'TUAMI' OR 'MOAMI'.
*        IF p_int EQ 'X'.
*          gs_fieldcat-no_out = ' '.
*        ELSE.
*          gs_fieldcat-no_out = 'X'.
*        ENDIF.
*      WHEN OTHERS.
*    ENDCASE.
*    MODIFY it_fieldcat FROM gs_fieldcat.

*  ENDLOOP.

ENDFORM.                    " SET_FIELDCAT_BUILD
*&---------------------------------------------------------------------*
*&      Form  DISPLAY_ALV_LIST
*&---------------------------------------------------------------------*
FORM display_alv_list.

  DATA: fc_detail TYPE slis_fieldcat_alv OCCURS 0 WITH HEADER LINE.
  DATA: variant_detail      LIKE disvariant.
  DATA: exit     TYPE slis_event_exit   OCCURS 0 WITH HEADER LINE.
  DATA: it_events   TYPE slis_alv_event    OCCURS 0 WITH HEADER LINE.
  DATA: groups   TYPE slis_sp_group_alv OCCURS 0 WITH HEADER LINE.
  DATA g_repid   TYPE sy-repid.

  DATA: ls_variant LIKE disvariant.
  ls_variant-report  = sy-repid.
  ls_variant-variant = alv_def.
  g_repid            = sy-repid.

  SET TITLEBAR 'T1000' .

** The detail ALV may modify the list (sorting). If returned to the
** base list, the original list needs to be restored.
*  REFRESH fc_detail.
*  LOOP AT it_fieldcat INTO gs_fieldcat.
*    MOVE-CORRESPONDING gs_fieldcat TO fc_detail.
*    CLEAR fc_detail-tabname.
*    APPEND fc_detail.
*  ENDLOOP.
*
*  CLEAR variant_detail.
*  variant_detail-report = alv_repid.
*  variant_detail-handle = ' '.
*
*  gs_layout-colwidth_optimize = ' '.
*  gs_layout-zebra             = 'X'.
**  gs_layout-box_fieldname     = 'BOX'.
*
**>color field define.
*  gs_layout-coltab_fieldname  = 'COLOR'.
*  gs_layout-group_change_edit = 'X'.
*  gs_layout-f2code            = 'DISPLAY'.
*
** header.
**  gs_layout-no_colhead        = 'X'.
*
**  GS_LAYOUT-SUBTOTALS_TEXT = 'TOTAL'.
*  gs_layout-totals_text = ' TOTAL'.
*
**  gs_layout-new_fcodes   = ' '.
*
*  REFRESH exit.
*  exit-ucomm = '&OL0'. exit-after = 'X'. APPEND exit.
*  exit-ucomm = '&OLX'. APPEND exit.
*  exit-ucomm = '&OAD'. APPEND exit.
*
**> event define.
  REFRESH it_events.
  it_events-name = slis_ev_top_of_page.
  it_events-form = 'TOP_OF_PAGE'.
  APPEND it_events.
*
*  events-name = 'TOP_OF_LIST'.
*  events-form = 'TOP_OF_LIST'.
*  APPEND events.

  CALL FUNCTION 'REUSE_ALV_HIERSEQ_LIST_DISPLAY'
    EXPORTING
            i_interface_check              = ' '
            i_callback_program       = g_repid
            i_callback_pf_status_set       = 'SET_ALV_STATUS'
            i_callback_user_command        = 'USER_ALV_COMMAND'
            is_layout                = gs_layout
            it_fieldcat              = it_fieldcat[]
*            it_excluding                   =
*            IT_SPECIAL_GROUPS              =
            it_sort                  = it_sort
*            IT_FILTER                      =
*            IS_SEL_HIDE                    =
*            I_SCREEN_START_COLUMN          = 0
*            I_SCREEN_START_LINE            = 0
*            I_SCREEN_END_COLUMN            = 0
*            I_SCREEN_END_LINE              = 0
            i_tabname_header         = 'IT_HEADER'
            i_tabname_item           = 'IT_LIST'
            i_structure_name_header  = 'IT_HEADER'
            i_structure_name_item    = 'IT_LIST'
            is_keyinfo               = gs_keyinfo
            i_default                = 'X'
            i_save                   = 'A'
            is_variant               = alv_variant
            it_events                = it_events[]
            it_event_exit            = exit[]
            is_print                 = alv_print
*            IS_REPREP_ID             =
*            I_BYPASSING_BUFFER       =
*            I_BUFFER_ACTIVE          =
* IMPORTING
*            E_EXIT_CAUSED_BY_CALLER  =
*            ES_EXIT_CAUSED_BY_USER   =
    TABLES
      t_outtab_header                = it_header[]
      t_outtab_item                  = it_list[]
 EXCEPTIONS
      program_error                  = 1
      OTHERS                         = 2.

  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

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
    WHEN 'ME23N' .       "P/O 조회
    WHEN 'ZTIT003' .     "수입의뢰조회
    WHEN 'FIDOC'.        "회계문서
    WHEN 'COSTDOC'.      "비용문서.
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
*  st_sort-fieldname = 'BUSCL'.
*  st_sort-tabname   = 'IT_LIST'.
*  st_sort-up        = 'X'.
**  ST_SORT-GROUP     = 'X'.
**  st_sort-subtot    = 'X'.
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


  header-typ = 'H'.

  header-info = '수입원자재 일계표'.
  CLEAR: header-key.
  APPEND header.

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
  CLEAR: header.
** JS전선 회사코드 2007/04 KSH --------------------------------------

  header-typ = 'S'.
  header-key = '출력일자 :'.
  WRITE: sy-datlo TO header-info.

  APPEND header.

  CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
    EXPORTING
      it_list_commentary = header[].


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

* 단위를 EXTERNAL로 변환뒤 1000을 나누고 INT필드에 넣어줌.(자동 반올림).
  CALL FUNCTION 'Z_TI_INT_NUMBER_PER1000'
    EXPORTING
      w_waers = p_waers
      w_opamt = p_amtt
    IMPORTING
      w_int   = p_amti.



ENDFORM.                    " INT_NUMBER_PER1000

*&---------------------------------------------------------------------*
*&      Form  set_key_infomation_build
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM set_key_infomation_build .
  CLEAR gs_keyinfo.

  gs_keyinfo-header01 = 'IBLNO'.
  gs_keyinfo-item01   = 'IBLNO'.

ENDFORM.                    " set_key_infomation_build
