************************************************************************
*                                                                      *
* Title         : ZTIR9310                                             *
*                                                                      *
* Description   : [Report] 구매관리카드 현황                           *
*                                                                      *
* Creation Date : 2004/12/20                                           *
*                                                                      *
* Author        : Seog Bong, Kang                                      *
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
PROGRAM   ztir9310
          MESSAGE-ID zmti00
          NO STANDARD PAGE HEADING.

************************************************************************
* TYPES and TYPE-POOLS                                                 *
************************************************************************
TYPE-POOLS: slis.   "> Globale Type(ALV)
TYPES: int13 TYPE i.
TYPES: BEGIN OF ty_header.
TYPES: reqno     LIKE  ztivrq00-reqno,   "수입요청 관리번호
       opnno     LIKE  ztivrq00-opnno,   "수입개설번호
       ebeln     LIKE  ztivrq00-ebeln ,   "구매전표번호
       reqty     LIKE  ztivrq00-reqty,   "결재구분
       ilcty     LIKE  ztivrq00-ilcty,   "수입요청 종류
       opnbk     LIKE  ztivrq00-opnbk,   "개설은행
       opndt     LIKE  ztivrq00-opndt,   "개설일자
       waers     LIKE  ztivrq00-waers,   "통화키
       opamt     LIKE  ztivrq00-opamt,   "개설금액-외화.
       noamt     LIKE  ztivrq00-opamt,   "미결금액
       bukrs     LIKE  ztivrq00-bukrs.
TYPES: END OF ty_header.

TYPES: BEGIN OF ty_list.
TYPES: reqno  LIKE  ztivrq00-reqno,
       icsno  LIKE  ztivcs00-icsno,
       blcnt  LIKE  ztitblk-blcnt,  "선적차수
       budat  LIKE  ztivcs00-budat,  "전표의 전기일
       exptx  LIKE  ztitig06-exptx,   "비용 설명
       dmbtr  LIKE  ztivcs00-dmbtr,   "현지통화금액
       wrbtr  LIKE  ztivcs00-wrbtr,   "전표통화금액
       hwaer  LIKE  ztivcs00-hwaer,   "현지통화
       waers  LIKE  ztivcs00-waers,   "전표통화
       kursf  LIKE  ztivcs00-kursf,   "환율
       expcd  LIKE  ztivcs00-expcd,   "수입비용코드.
       commt  TYPE  comment,          "비고.
       belnr  LIKE  ztivcs00-belnr,   "전표번호.
       gjahr  LIKE  ztivcs00-gjahr,   "회계련도.
       bukrs  LIKE  ztivrq00-bukrs.   "회사코드.
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
        t001k,     ">Valuation area
        t161,      ">Purchasing Document Types
        t134,      ">Material Types
        t134t,     ">Material Types Descriptions
        t024d,     ">MRP controllers
        ztitivk,   ">[Import] 상업송장 Header table
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
        ztivrq00.  "수입의뢰 Views : 최종회차(Header + Status + Items).

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

DATA: it_list_tmp  TYPE STANDARD TABLE OF ty_list,
      gs_list_tmp      TYPE ty_list,
      ls_list_tmp      TYPE ty_list.

*> Message dialog box용
DATA: BEGIN OF it_ztitivk  OCCURS 0.
        INCLUDE STRUCTURE ztitivk.
DATA: END   OF it_ztitivk.

DATA: BEGIN OF it_ivono  OCCURS 0,
      ivono TYPE ztiivono,
      reqno TYPE ztireqno,
      END   OF it_ivono.

DATA: BEGIN OF it_belnr  OCCURS 0,
      reqno TYPE ztireqno,
      ivono TYPE ztiivono,
      bukrs TYPE bukrs,
      belnr TYPE re_belnr,
      gjahr TYPE gjahr.
DATA: END   OF it_belnr.

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
  s_bukrs  FOR ztivrq00-bukrs                   "회사코드.
               NO-EXTENSION NO INTERVALS OBLIGATORY
                    MEMORY ID buk .
SELECT-OPTIONS:
  s_ekorg  FOR ztivrq00-ekorg,                  "구매조직.
  s_ekgrp  FOR ztivrq00-ekgrp,                  "구매그룹.
  s_ebeln  FOR ztivrq00-ebeln,                 "구매전표.
  s_reqty  FOR ztivrq00-reqty,                 "수입요청 종류.
  s_ilcty  FOR ztivrq00-ilcty,                 "신용장 종류.
  s_opnno  FOR ztivrq00-opnno,                 "수입개설번호
  s_opnbk  FOR ztivrq00-opnbk MODIF ID sed,     "개설은행.
  s_opndt  FOR ztivrq00-opndt.                "개설일자.

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
  SET TITLEBAR 'T1000' WITH 'L/C개설 실적 및 계획'.

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

* 합계 텍스트용.
  CLEAR : gs_totxt, gs_netxt.
  DATA  : ls_calcu(2)  TYPE n,
          l_check      TYPE c,
          l_budat      LIKE bkpf-budat,
          l_kursf      LIKE bkpf-kursf.

  CLEAR g_total.
  DATA: ls_opndt   LIKE  ztitrqs-opndt,
        ls_opnd1   LIKE  ztitrqs-opndt,
        ls_opnd2   LIKE  ztitrqs-opndt,
        ls_opnd3   LIKE  ztitrqs-opndt,
        e_month(6) TYPE n.


*> 수입의뢰 데이타 select."
  SELECT reqno opnno ebeln reqty ilcty opnbk opndt waers opamt
    INTO CORRESPONDING FIELDS OF TABLE it_header
    FROM ztivrq00
   WHERE bukrs  IN  s_bukrs        "회사코드.
     AND ekorg  IN  s_ekorg        "구매조직.
     AND ekgrp  IN  s_ekgrp        "구매그룹.
     AND ebeln  IN  s_ebeln        "구매전표.
     AND reqty  IN  s_reqty        "수입요청 종류.
     AND ilcty  IN  s_ilcty        "신용장 종류.
     AND opnno  IN  s_opnno        "수입개설번호
     AND opnbk  IN  s_opnbk        "개설은행.
     AND opndt  IN  s_opndt        "개설일자.
    GROUP BY reqno opnno ebeln reqty  ilcty opnbk opndt waers opamt.

  IF sy-subrc NE 0.
    MESSAGE s902.
    EXIT.
  ENDIF.


****AMEND 중 완료된 건이 있는 경우 그 OPEN AMOUNT를 가져옴.

  DATA : ls_amdsq LIKE ztitrqs-amdsq.

  DATA: l_belnr    TYPE   belnr_d,
        l_gjahr    TYPE   gjahr,
        l_wrbtr    TYPE   wrbtr,
        l_awtyp    LIKE   bkpf-awtyp,
        l_awkey    LIKE   bkpf-awkey.

*
  LOOP AT it_header INTO gs_header.
    CASE gs_header-reqty.
      WHEN 'LC' OR 'TT' OR 'DA' OR 'DP'.
        REFRESH: it_belnr.
        SELECT h~bukrs h~belnr h~gjahr h~ivono i~reqno
          INTO CORRESPONDING FIELDS OF TABLE it_belnr
          FROM ztitivk AS h INNER JOIN ztitivp AS i
            ON ( h~ivono EQ i~ivono )
         WHERE i~reqno  EQ  gs_header-reqno
           AND h~livst  EQ  'P'
         GROUP BY h~bukrs h~belnr h~gjahr h~ivono i~reqno.
        LOOP AT it_belnr WHERE reqno EQ gs_header-reqno.
          l_awkey       = it_belnr-belnr.
          l_awkey+10(4) = it_belnr-gjahr.
          l_awtyp       = 'RMRP '.
*break-point.
          SELECT SINGLE belnr gjahr
            INTO (l_belnr, l_gjahr)
            FROM bkpf
           WHERE awtyp  EQ  l_awtyp
             AND awkey  EQ  l_awkey
             AND bukrs  EQ  it_belnr-bukrs.
          IF sy-subrc  EQ  0.
            CLEAR: gs_list_tmp.
            SELECT SINGLE *
              FROM ztitivk
             WHERE ivono EQ it_belnr-ivono.
            IF sy-subrc EQ 0.

              SELECT blcnt
                INTO gs_list_tmp-blcnt
                FROM ztitblk UP TO 1 ROWS
               WHERE iblno IN ( SELECT iblno
                                  FROM ztitivp
                                 WHERE ivono EQ it_belnr-ivono ).
              ENDSELECT.

              MOVE-CORRESPONDING gs_header TO gs_list_tmp.
              gs_list_tmp-icsno = it_belnr-ivono.
              gs_list_tmp-budat = ztitivk-budat.
              gs_list_tmp-kursf = ztitivk-kursf.
              IF gs_header-ilcty EQ 'U'.
                gs_list_tmp-exptx = 'USANCE 원금상환'.
              ELSE.
                gs_list_tmp-exptx = '자기자금결제'.
              ENDIF.
              SELECT SUM( dmbtr ) SUM( wrbtr )
                INTO (gs_list_tmp-dmbtr, gs_list_tmp-wrbtr)
                FROM ekbe
               WHERE vgabe  = '2'
                 AND gjahr  = it_belnr-gjahr
                 AND belnr  = it_belnr-belnr.

              gs_list_tmp-reqno = gs_header-reqno.
              APPEND gs_list_tmp TO it_list.
            ENDIF.
          ENDIF.
        ENDLOOP.
      WHEN 'LO' OR 'PU'.
        REFRESH: it_belnr.
        SELECT belnr gjahr
          FROM ekbe
          INTO CORRESPONDING FIELDS OF TABLE it_belnr
         WHERE ebeln EQ gs_header-ebeln
           AND vgabe EQ '2'
           AND bewtp EQ 'Q'
         GROUP BY belnr gjahr.
*
        LOOP AT it_belnr.
          l_awkey        = it_belnr-belnr.
          l_awkey+10(4)  = it_belnr-gjahr.
          it_belnr-bukrs = gs_header-bukrs.
          l_awtyp        = 'RMRP '.

          SELECT SINGLE belnr gjahr budat kursf
            INTO (l_belnr, l_gjahr, l_budat, l_kursf)
            FROM bkpf
           WHERE awtyp  EQ  l_awtyp
             AND awkey  EQ  l_awkey
             AND bukrs  EQ  it_belnr-bukrs.

          IF sy-subrc  EQ  0.
            MOVE-CORRESPONDING gs_header TO gs_list_tmp.

            gs_list_tmp-budat = l_budat.
            gs_list_tmp-kursf = l_kursf.
            IF gs_header-reqty EQ 'PU'.
              gs_list_tmp-exptx = '구매확인서 결제'.
            ELSE.
              gs_list_tmp-exptx = 'LOCAL 결제'.
            ENDIF.
            SELECT SUM( dmbtr ) SUM( wrbtr )
              INTO (gs_list_tmp-dmbtr, gs_list_tmp-wrbtr)
              FROM ekbe
             WHERE vgabe  = '2'
               AND gjahr  = it_belnr-gjahr
               AND belnr  = it_belnr-belnr.

            gs_list_tmp-reqno = gs_header-reqno.
            APPEND gs_list_tmp TO it_list.
          ENDIF.
*        ENDIF.
        ENDLOOP.


      WHEN OTHERS.
    ENDCASE.

*> L/C 관련비용만.
    SELECT *
      INTO CORRESPONDING FIELDS OF TABLE it_list_tmp
      FROM ztivcs00
     WHERE refno EQ gs_header-reqno
       AND expgr = 'L'.

    IF sy-subrc NE 0.
      CONTINUE.
    ELSE.
      LOOP AT it_list_tmp INTO gs_list_tmp.
*>비용설명
        SELECT SINGLE exptx
          INTO gs_list_tmp-exptx
          FROM ztitig06
          WHERE expcd EQ gs_list_tmp-expcd
           AND  expgr EQ 'L'.

        gs_list_tmp-reqno = gs_header-reqno.
        APPEND gs_list_tmp TO it_list.
      ENDLOOP.
    ENDIF.
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

"구매전표번호
          'S' 'TABNAME'       'IT_HEADER',
          ' ' 'REF_TABNAME'   'ZTIVRQ00',
          ' ' 'FIELDNAME'     'EBELN',
          ' ' 'NO_OUT'        ' ',
          ' ' 'KEY'           'X',
          'E' 'OUTPUTLEN'     '13',
"L/C NO
*          'S' 'REF_TABNAME'   'ZTITIG04',
*          'S' 'SELTEXT_M'     '구    분',
          'S' 'TABNAME'       'IT_HEADER',
          ' ' 'REF_TABNAME'   'ZTIVRQ00',
          ' ' 'FIELDNAME'     'OPNNO',
          ' ' 'NO_OUT'        ' ',
          ' ' 'KEY'           'X',
          'E' 'OUTPUTLEN'     '16',

"결제구분

          'S' 'TABNAME'       'IT_HEADER',
          ' ' 'SELTEXT_M'     '결제구분',
          ' ' 'REF_TABNAME'   'ZTIVRQ00',
          ' ' 'FIELDNAME'     'REQTY',
*          ' ' 'CURRENCY'      'USD',
*          ' ' 'NO_OUT'        ' ',
*          ' ' 'DO_SUM'        ' ',
          'E' 'OUTPUTLEN'     '10',

"L/C 종류
*          'S' 'SELTEXT_M'     '2002 년  실적',
          'S' 'TABNAME'       'IT_HEADER',
          ' ' 'REF_TABNAME'   'ZTIVRQ00',
          ' ' 'FIELDNAME'     'ILCTY',
*          ' ' 'CURRENCY'      'USD',
*          ' ' 'NO_OUT'        ' ',
*          ' ' 'DO_SUM'        ' ',
          'E' 'OUTPUTLEN'     '12',

"개설은행
*          'S' 'SELTEXT_M'     '2002 년  실적',
          'S' 'TABNAME'       'IT_HEADER',
          ' ' 'REF_TABNAME'   'ZTIVRQ00',
          ' ' 'FIELDNAME'     'OPNBK',
          ' ' 'NO_OUT'        ' ',
          ' ' 'DO_SUM'        ' ',
          'E' 'OUTPUTLEN'     '10',


"개설일자.
          'S' 'TABNAME'       'IT_HEADER',
*          ' ' 'EDIT'          'X',
*          ' ' 'SELTEXT_M'     '2003 년  계획',
          ' ' 'REF_TABNAME'   'ZTIVRQ00',
          ' ' 'FIELDNAME'     'OPNDT',
*          ' ' 'CURRENCY'      'USD',
*          ' ' 'EDIT'          'X',
          ' ' 'NO_OUT'        ' ',
          ' ' 'DO_SUM'        ' ',
          'E ' 'OUTPUTLEN'     '10',
"통화키
          'S' 'TABNAME'       'IT_HEADER',
*          ' ' 'SELTEXT_M'      ' ',
          ' ' 'REF_TABNAME'   'ZTIVRQ00',
          ' ' 'FIELDNAME'     'WAERS',
          ' ' 'NO_OUT'        ' ',
          ' ' 'DO_SUM'        ' ',
          'E' 'OUTPUTLEN'     '5',

"개설금액-외화
          'S' 'TABNAME'       'IT_HEADER',
*          ' ' 'SELTEXT_M'      gs_totxt,
          ' ' 'REF_TABNAME'   'ZTIVRQ00',
          ' ' 'FIELDNAME'     'OPAMT',
          ' ' 'CFIELDNAME'      'WAERS',
*          ' ' 'NO_OUT'        'X',
          ' ' 'DO_SUM'        'X',
          'E ' 'OUTPUTLEN'     '12',

"미결금액
          'S' 'TABNAME'       'IT_HEADER',
          ' ' 'SELTEXT_M'     '미결금액',
          ' ' 'REF_TABNAME'   'ZTIVRQ00',
          ' ' 'FIELDNAME'     'NOAMT',
          ' ' 'CFIELDNAME'      'WAERS',
*          ' ' 'NO_OUT'        'X',
          ' ' 'DO_SUM'        'X',
          'E ' 'OUTPUTLEN'     '12',


"수입비용 문서번호
          'S' 'TABNAME'       'IT_LIST',
*          ' ' 'SELTEXT_M'      gs_totxt,
          ' ' 'REF_TABNAME'   'ZTIVCS00',
          ' ' 'FIELDNAME'     'ICSNO',
          ' ' 'NO_OUT'        'X',
*          ' ' 'DO_SUM'        'X',
          'E' 'OUTPUTLEN'     '16',

"선적차수
          'S' 'TABNAME'       'IT_LIST',
          ' ' 'REF_TABNAME'   'ZTITBLK',
          ' ' 'SELTEXT_L'     ' A',
*          ' ' 'CURRENCY'      'USD',
*          ' ' 'NO_OUT'        'X',
*          ' ' 'DO_SUM'        'X',
          ' ' 'FIELDNAME'     'BLCNT',
          'E' 'OUTPUTLEN'     '2',


"전표의 전기일
          'S' 'TABNAME'       'IT_LIST',
*          ' ' 'SELTEXT_M'      gs_totxt,
          ' ' 'REF_TABNAME'   'ZTIVCS00',
          ' ' 'FIELDNAME'     'BUDAT',
*          ' ' 'NO_OUT'        'X',
*          ' ' 'DO_SUM'        'X',
          'E' 'OUTPUTLEN'     '10',



"비용 설명
          'S' 'TABNAME'       'IT_LIST',
          ' ' 'SELTEXT_M'     '지출 내역',
*          ' ' 'CURRENCY'      'USD',
*          ' ' 'NO_OUT'        'X',
*          ' ' 'DO_SUM'        'X',
          ' ' 'FIELDNAME'     'EXPTX',
          'E' 'OUTPUTLEN'     '26',

"현지통화금액
          'S' 'TABNAME'       'IT_LIST',
*          ' ' 'SELTEXT_M'     '당월말 누계',
          ' ' 'DO_SUM'        'X',
*          ' ' 'NO_OUT'        'X',
          ' ' 'CFIELDNAME'      'HWAER',
          ' ' 'REF_TABNAME'   'ZTIVCS00',
          ' ' 'FIELDNAME'     'DMBTR',
          'E' 'OUTPUTLEN'     '12',

"전표통화금액.
*          'S' 'SELTEXT_L'     '%',
          'S' 'TABNAME'       'IT_LIST',
          ' ' 'DO_SUM'        'X',
          ' ' 'CFIELDNAME'      'WAERS',
          ' ' 'REF_TABNAME'   'ZTIVCS00',
          ' ' 'FIELDNAME'     'WRBTR',
          'E' 'OUTPUTLEN'     '9',
"현지통화
          'S' 'REF_TABNAME'   'ZTIVCS00',
*          'S' 'SELTEXT_M'     '구    분',
          ' ' 'TABNAME'       'IT_LIST',
          ' ' 'REF_TABNAME'   'ZTIVCS00',
          ' ' 'FIELDNAME'     'HWAER',
          'E' 'NO_OUT'        'X',

*          'E' 'OUTPUTLEN'     '20',
"전표통화
          'S' 'REF_TABNAME'   'ZTIVCS00',
*          'S' 'SELTEXT_M'     '구    분',
          ' ' 'TABNAME'       'IT_LIST',
          ' ' 'REF_TABNAME'   'ZTIVCS00',
          ' ' 'FIELDNAME'     'WAERS',
          'E' 'NO_OUT'        'X',
*          'E' 'OUTPUTLEN'     '20',

"환율
          'S' 'TABNAME'       'IT_LIST',
          ' ' 'SELTEXT_l'      '환율      ',
*          ' ' 'DO_SUM'        'X',
          ' ' 'REF_TABNAME'   'ZTIVCS00',
          ' ' 'FIELDNAME'     'KURSF',
          'E' 'OUTPUTLEN'     '10'.

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

  SET TITLEBAR 'T1000' WITH 'L/C 개설 실적및 계획'.

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
*  REFRESH events.
*  events-name = slis_ev_top_of_page.
*  events-form = 'TOP_OF_PAGE'.
*  APPEND events.
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
  CLEAR : gs_header, gs_list.
  IF rs_selfield-tabname EQ 'IT_HEADER'.
    READ TABLE it_header INTO gs_header INDEX rs_selfield-tabindex.
  ELSEIF rs_selfield-tabname EQ 'IT_LIST'.
    READ TABLE it_list INTO gs_list INDEX rs_selfield-tabindex.
  ENDIF.
  IF sy-subrc NE 0.
    MESSAGE s903. EXIT.
  ENDIF.

  IF rs_selfield-tabname EQ 'IT_HEADER'.
    MOVE-CORRESPONDING gs_header TO ls_header.
  ELSEIF rs_selfield-tabname EQ 'IT_LIST'.
    MOVE-CORRESPONDING gs_list   TO ls_list.
  ENDIF.

*       CASE rs_selfield-fieldname.
*         WHEN 'EBELN' OR 'EBELP'.
*           PERFORM  display_purchase_order(ztir0000)
*                                           USING ls_list-ebeln
*                                                 ls_list-ebelp.
*         WHEN 'LIFNR'.
*           PERFORM display_vendor_master   USING ls_list-lifnr
*                                                 ls_list-ekorg.
*         WHEN 'MATNR'.
*           PERFORM display_material_master USING ls_list-matnr
*                                                 ls_list-werks
*                                                 space.
*       ENDCASE.


  CASE r_ucomm.
    WHEN 'ME23N' .       "P/O 조회
      IF NOT gs_header IS INITIAL.
        SET PARAMETER ID 'BES' FIELD ls_header-ebeln.
        CALL TRANSACTION 'ME23N' AND SKIP FIRST SCREEN.
      ELSE.
        MESSAGE s903. EXIT.
      ENDIF.
    WHEN 'ZTIT003' .     "수입의뢰조회
      IF NOT gs_header IS INITIAL.
        SET PARAMETER ID 'ZTIREQNO' FIELD ls_header-reqno.
        CALL TRANSACTION 'ZTIT003' AND SKIP FIRST SCREEN.
      ELSE.
        MESSAGE s903. EXIT.
      ENDIF.
    WHEN 'FIDOC'.        "회계문서
      IF NOT gs_list IS INITIAL.
        PERFORM display_liv_document(ztir0000)
                      USING    gs_list-belnr
                               gs_list-gjahr
                               gs_list-bukrs.
      ELSE.
        MESSAGE s903. EXIT.
      ENDIF.

    WHEN 'COSTDOC'.      "비용문서.
      IF NOT gs_list IS INITIAL.
        PERFORM display_cs_document(ztir0000) USING
                                     gs_list-icsno  gs_list-bukrs.
      ELSE.
        MESSAGE s903. EXIT.
      ENDIF.
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

  header-info = 'L/C 개설 실적및 계획'.
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

* 단위를 EXTERNAL로 변환뒤 1000을 나누고 INT필드에 넣어줌.(자동 반올림).
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

  gs_keyinfo-header01 = 'REQNO'.
  gs_keyinfo-item01   = 'REQNO'.

ENDFORM.                    " set_key_infomation_build
