************************************************************************
*                                                                      *
* Title         : ZTIR3100                                             *
*                                                                      *
* Description   : [Report]  L/C 결제대상 리스트                        *
*                                                                      *
* Creation Date : 2004/11/11                                           *
*                                                                      *
* Author        : Soo Ho, Yoon                                         *
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
* 2009.05.18  FIB05     CSR NO   : C20090429_48253
*                       CSR 내역 : ZTIR310 화면수정 요청
************************************************************************
REPORT  ztir3100
        MESSAGE-ID zmti00
        NO STANDARD PAGE HEADING.

************************************************************************
* User Include Define                                                  *
************************************************************************
** JS전선 회사코드 2007/04 KSH --------------------------------------
DATA: l_yn    TYPE c.
INCLUDE zts_authorization_check. "AUTHORIZATION_CHECK
** JS전선 회사코드 2007/04 KSH --------------------------------------

************************************************************************
* TYPES and TYPE-POOLS                                                 *
************************************************************************
TYPE-POOLS: slis.    "> Globale Type(ALV)

TYPES: BEGIN OF ty_selt.
TYPES: bukrs      TYPE ztitivk-bukrs,
       ivono      TYPE ztitivk-lifnr,      ">송장 관리번호
       lifnr      TYPE ztitivk-lifnr,      ">다른 송장발행처
       opnbk      TYPE ztitivk-opnbk,      ">개설은행 구매처코드
       name1      TYPE lfa1-name1,         ">은행파트너명
       ebeln      TYPE ztitivk-ebeln,      ">구매오더
       blcnt      TYPE ztitblk-blcnt,      ">선적차수
       opnno      TYPE ztitrqs-opnno,      ">수입개설번호
       reqty      TYPE ztitrqk-reqty,      ">수입요청 종류
       reqtyt(65) TYPE c,
       hwaer      TYPE ztitrqs-hwaer,      ">현지통화
       dmbtr      TYPE ztitrqs-dmbtr,      ">현지통화금액
       waers      TYPE ztitivk-waers,      ">통화키
       ivamp      TYPE ztitivk-ivamp,      ">문서통화 - 총처리금액
       kursf      TYPE ztitivk-kursf,      ">환율
       belnr      TYPE ztitivk-belnr,      ">송장문서의 문서번호
       belnr_f    TYPE bkpf-belnr,         ">회계문서의 전표번호
       augbl      TYPE bseg-augbl,
       augdt      TYPE bseg-augdt,
       netdt      TYPE ztitivk-netdt,      ">순액지급 만기일
       iblno      TYPE ztitivp-iblno,      ">B/L 관리번호
       reqno      TYPE ztitivp-reqno,      ">수입요청 관리번호
       gjahr      TYPE ztitivk-gjahr,      ">회계연도
       budat      TYPE ztitivk-budat,      ">전표의 전기일
       bldat      TYPE ztitivk-bldat,      ">전표에서 송장일
       ilcty      TYPE ztitrqk-ilcty,      ">신용장 종류
       wwert      TYPE ztitivk-wwert,      ">환산일

       zterm      TYPE ztitivk-zterm,      ">지급조건
       ivamt      TYPE ztitivk-ivamt,      ">금액(외화금액)
       dmbtr_v    TYPE bseg-dmbtr,         ">현지통화금액
       hkont      TYPE bseg-hkont,         ">GL계정
       bupla      TYPE ztitivk-bupla,      ">사업장
       gsber      TYPE ztitivk-gsber,      ">사업영역
       zbd1t      TYPE ztitivk-zbd1t,      ">일수
       uzawe      TYPE ztitivk-uzawe,      ">지급방법
       bktxt      TYPE ztitivk-bktxt,      ">텍스트
       okont      TYPE bseg-hkont,         ">상대계정명
       okonm      TYPE skat-txt50,      ">*상대계정코드

       lifnm      TYPE lfa1-name1   ,      ">거래처명
       blart      TYPE ztitivk-blart,      ">전표유형
       ivnum      TYPE ztitivk-ivnum,      ">송장관리번호
       rtchg      TYPE ztitivk-rtchg,      ">유보금금액

       pntno      TYPE ztitpnk-pntno,      ">NOTICE 관리번호
       ntcbk      TYPE ztitpnk-ntcbk,      ">통지은행
       ntcnm      TYPE ztstig3-namet,      ">통지은행명
       ssuch      TYPE ztitpnk-ssuch,      ">거래처
       ssunm      TYPE lfa1-name1   ,      ">거래처명
       lifnr_p    TYPE ztitpnk-lifnr,      ">송장발행처
       bgndt      TYPE ztitpnk-bgndt,      ">시작일자
       pntdt      TYPE ztitpnk-pntdt,      ">통지일자
       ndays      TYPE ztitpnk-ndays,      ">기간
       pntam      TYPE ztitpnk-pntam,      "> NOTICE AMOUNT
       waers_p    TYPE ztitpnk-waers,      ">통화
       opnno_p    TYPE ztitpnk-opnno,      ">수입개설번호
       reqno_p    TYPE ztitpnk-reqno,      ">수입의뢰번호
       blnum      TYPE ztitpnk-blnum,      ">BL번호
       xranl      TYPE ztitpnk-xranl,      ">론번호
       belnr_p    TYPE ztitpnk-belnr,      ">전표번호
       saknr      TYPE ztitpnk-saknr,      ">GL계정
       expdt      TYPE ztitpnk-expdt,      ">만기일자
       tsatz      TYPE ztitpnk-tsatz,      ">이자율
       itrst      TYPE ztitpnk-itrst,      ">이자금액
       kursf_p    TYPE ztitpnk-kursf,      ">환율
       pntit      TYPE ztispnit-txz01.     ">품목내역

TYPES: END OF ty_selt.

DATA: BEGIN OF gt_data OCCURS 0,
        bukrs      LIKE ztitivk-bukrs,
        ivono      LIKE ztitivk-lifnr,      ">송장 관리번호
        lifnr      LIKE ztitivk-lifnr,      ">다른 송장발행처
        opnbk      LIKE ztitivk-opnbk,      ">개설은행 구매처코드
        name1      LIKE lfa1-name1,         ">은행파트너명
        ebeln      LIKE ztitivk-ebeln,      ">구매오더
        blcnt      LIKE ztitblk-blcnt,      ">선적차수
        opnno      LIKE ztitrqs-opnno,      ">수입개설번호
        reqty      LIKE ztitrqk-reqty,      ">수입요청 종류
        reqtyt(65) TYPE c,
        hwaer      LIKE ztitrqs-hwaer,      ">현지통화
        dmbtr      LIKE ztitrqs-dmbtr,      ">현지통화금액
        waers      LIKE ztitivk-waers,      ">통화키
        ivamp      LIKE ztitivk-ivamp,      ">문서통화 - 총처리금액
        kursf      LIKE ztitivk-kursf,      ">환율
        belnr      LIKE ztitivk-belnr,      ">송장문서의 문서번호
        belnr_f    LIKE bkpf-belnr,         ">회계문서의 전표번호
        augbl      LIKE bseg-augbl,
        augdt      LIKE bseg-augdt,
        netdt      LIKE ztitivk-netdt,      ">순액지급 만기일
        iblno      LIKE ztitivp-iblno,      ">B/L 관리번호
        reqno      LIKE ztitivp-reqno,      ">수입요청 관리번호
        gjahr      LIKE ztitivk-gjahr,      ">회계연도
        budat      LIKE ztitivk-budat,      ">전표의 전기일
        bldat      LIKE ztitivk-bldat,      ">전표에서 송장일
        ilcty      LIKE ztitrqk-ilcty,      ">신용장 종류
        wwert      LIKE ztitivk-wwert,      ">환산일

        zterm      LIKE ztitivk-zterm,      ">지급조건
        ivamt      LIKE ztitivk-ivamt,      ">금액(외화금액)
        dmbtr_v    LIKE bseg-dmbtr,         ">현지통화금액
        hkont      LIKE bseg-hkont,         ">GL계정
        bupla      LIKE ztitivk-bupla,      ">사업장
        gsber      LIKE ztitivk-gsber,      ">사업영역
        zbd1t      LIKE ztitivk-zbd1t,      ">일수
        uzawe      LIKE ztitivk-uzawe,      ">지급방법
        bktxt      LIKE ztitivk-bktxt,      ">텍스트
        okont      LIKE bseg-hkont,         ">상대계정명
        okonm      LIKE skat-txt50,      ">*상대계정코드

        lifnm      LIKE lfa1-name1   ,      ">거래처명
        blart      LIKE ztitivk-blart,      ">전표유형
        ivnum      LIKE ztitivk-ivnum,      ">송장관리번호
        rtchg      LIKE ztitivk-rtchg,      ">유보금금액

        pntno      LIKE ztitpnk-pntno,      ">NOTICE 관리번호
        ntcbk      LIKE ztitpnk-ntcbk,      ">통지은행
        ntcnm      LIKE ztstig3-namet,      ">통지은행명
        ssuch      LIKE ztitpnk-ssuch,      ">거래처
        ssunm      LIKE lfa1-name1   ,      ">거래처명
        lifnr_p    LIKE ztitpnk-lifnr,      ">송장발행처
        bgndt      LIKE ztitpnk-bgndt,      ">시작일자
        pntdt      LIKE ztitpnk-pntdt,      ">통지일자
        ndays      LIKE ztitpnk-ndays,      ">기간
        pntam      LIKE ztitpnk-pntam,      "> NOTICE AMOUNT
        waers_p    LIKE ztitpnk-waers,      ">통화
        opnno_p    LIKE ztitpnk-opnno,      ">수입개설번호
        reqno_p    LIKE ztitpnk-reqno,      ">수입의뢰번호
        blnum      LIKE ztitpnk-blnum,      ">BL번호
        xranl      LIKE ztitpnk-xranl,      ">론번호
        belnr_p    LIKE ztitpnk-belnr,      ">전표번호
        saknr      LIKE ztitpnk-saknr,      ">GL계정
        expdt      LIKE ztitpnk-expdt,      ">만기일자
        tsatz      LIKE ztitpnk-tsatz,      ">이자율
        itrst      LIKE ztitpnk-itrst,      ">이자금액
        kursf_p    LIKE ztitpnk-kursf,      ">환율
        pntit      LIKE ztispnit-txz01,     ">품목내역
      END OF gt_data.

* LIST TYPE
TYPES: BEGIN OF ty_list.
         INCLUDE TYPE ty_selt.
TYPES:   color TYPE slis_t_specialcol_alv.
TYPES: END OF ty_list.

* Text Table: 계정명
DATA: BEGIN OF gt_txtsaknr OCCURS 0,
        saknr LIKE ska1-saknr,    "은행코드
        txt50 LIKE skat-txt50,    "은행명
      END OF gt_txtsaknr.

****at line-selection****alv용
DATA: BEGIN OF fc_struct,
        tabname(7),
        fieldname(9),
        ref_tabname(7),
        ref_fieldname(6),
        no_out(1),
        cqindicator(1),
        cqfield(6),
      END OF fc_struct.

*>ALV POPUP.
DATA: gs_private  TYPE slis_data_caller_exit,
      gs_selfield TYPE slis_selfield,
      t_fieldcat  TYPE slis_t_fieldcat_alv WITH HEADER LINE,
      g_exit(1)   TYPE c,
      dyname      LIKE d020s-prog,
*      L_TITLE     TYPE SY-TITLE.
      g_title(99) TYPE c,
      extab       TYPE slis_t_extab.

DEFINE mfc.
  CLEAR: t_fieldcat, fc_struct.
  t_fieldcat-tabname        = &1.
  t_fieldcat-fieldname      = &2.
  t_fieldcat-ref_tabname    = &3.
  t_fieldcat-ref_fieldname  = &4.
  t_fieldcat-no_out         = &5.

  CASE &6.
    WHEN 'C'.
      t_fieldcat-cfieldname = &7.
    WHEN 'Q'.
      t_fieldcat-qfieldname = &7.
  ENDCASE.
  APPEND t_fieldcat.
END-OF-DEFINITION.
************************************************************************
* SAP Tables                                                           *
************************************************************************
TABLES: ztitrqs,
        ztitrqk,
        ztitblk,
        ztitivk,
        ztitivp,
        ztstig3,
        ztitpnk,
        t001,
        t001w,
        bseg,
        dfies.

TABLES: icon.
************************************************************************
* Internal Tables  & Structure
************************************************************************
*SELECT용
DATA: it_selt TYPE STANDARD TABLE OF ty_selt,
      gs_selt TYPE ty_selt,
      ls_selt TYPE ty_selt.

*DATA: it_list TYPE STANDARD TABLE OF ty_list,
DATA: it_list TYPE ty_list OCCURS 0 WITH HEADER LINE,
      gs_list TYPE ty_list,
      ls_list TYPE ty_list.

DATA: BEGIN OF it_subtotal OCCURS 0,
        opnbk LIKE ztitivk-opnbk,        ">은행코드
        netdt LIKE ztitivk-netdt,        ">만기일
        count TYPE i,
      END   OF it_subtotal.

DATA: t_alv_list TYPE ty_list.

*> ALV용.
* Global variables for handling ALV functionality
DATA: alv_keyinfo      TYPE slis_keyinfo_alv.
DATA: alv_variant      LIKE disvariant.
DATA: gs_layout        TYPE slis_layout_alv.
DATA: alv_repid        LIKE sy-repid.
DATA: alv_print        TYPE slis_print_alv.
DATA: st_sort          TYPE slis_sortinfo_alv.

DATA: alv_detail_func(30).
DATA: fc      TYPE slis_t_fieldcat_alv,
      fc1     TYPE slis_t_fieldcat_alv,
      fcs     TYPE slis_fieldcat_alv,
      it_sort TYPE slis_t_sortinfo_alv.

DATA: it_fieldcat TYPE slis_t_fieldcat_alv,
      gs_fieldcat LIKE LINE OF it_fieldcat.
DATA: g_user_command  TYPE slis_formname VALUE 'USER_COMMAND'.

DATA : s_variant LIKE  disvariant,
       s_var_usr LIKE  disvariant.

************************************************************************
* CONSTANTS                                                            *
************************************************************************
CONSTANTS:
** JS전선 회사코드 2007/04 KSH --------------------------------------
*      c_bukrs     LIKE t001-bukrs     VALUE '1000',   ">Company code
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
       field_name1(20),
       l_iblno,
       l_ebeln,
       l_reqno.

************************************************************************
* SELECT-OPTIONS / PARAMETERS                                          *
************************************************************************
SELECTION-SCREEN BEGIN OF BLOCK box1 WITH FRAME TITLE TEXT-oo1.
  PARAMETERS:
   p_bukrs LIKE ztitivk-bukrs                        "회사
                OBLIGATORY
                      MEMORY ID buk .
*추가: 전표통화, 수입개설번호, 대표PO번호, 송장발행처(코드) 수입요청NO.
*지급조건

  SELECT-OPTIONS:
   s_opnbk FOR ztitivk-opnbk,                      "개설은행
   s_netdt FOR ztitivk-netdt,                      "송장만기일
   s_fdtag FOR bseg-fdtag,                         "AP계획일
   s_waers FOR ztitivk-waers,                      "통화
   s_opnno FOR ztitrqs-opnno,                      "개설번호
   s_ebeln FOR ztitivk-ebeln,                      "대표품목번호
   s_lifnr FOR ztitivk-lifnr,                      "송장발행처
   s_reqno FOR ztitrqs-reqno,                      "수입요청번호
   s_zterm FOR bseg-zterm.                         "지급조건
SELECTION-SCREEN END OF BLOCK box1.

*SELECTION-SCREEN BEGIN OF BLOCK box3 WITH FRAME TITLE text-003.
*PARAMETERS: p_full RADIOBUTTON GROUP pg3 MODIF ID opn DEFAULT 'X',
*            p_list RADIOBUTTON GROUP pg3 MODIF ID opn .
*SELECTION-SCREEN END OF BLOCK box3.

*> Report variant
SELECTION-SCREEN: BEGIN OF BLOCK alv WITH FRAME TITLE TEXT-004.
  PARAMETERS: alv_def LIKE disvariant-variant." NO-DISPLAY.
SELECTION-SCREEN: END OF BLOCK alv.


************************************************************************
*                                                                      *
* INITIALIZATION Event                                                 *
*                                                                      *
************************************************************************
INITIALIZATION.
  PERFORM  set_initial_data.
  PERFORM  set_alv_init.             ">Initialize ALV variable

************************************************************************
*                                                                      *
* AT SELECTION-SCREEN Events                                           *
*                                                                      *
************************************************************************
AT SELECTION-SCREEN ON VALUE-REQUEST FOR alv_def.
  PERFORM exec_alv_f4.

AT SELECTION-SCREEN.
  PERFORM input_field_check.
  PERFORM alv_variant_check.
** JS전선 회사코드 2007/04 KSH --------------------------------------
*> AUTHORIZATION_CHECK
  DATA: l_yn    TYPE c.
  PERFORM p1102_authorization_check USING p_bukrs.
** JS전선 회사코드 2007/04 KSH --------------------------------------

************************************************************************
*                                                                      *
* START-OF-SELECTION Event                                             *
*                                                                      *
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
  g_line1 = 100.
  g_out_text = TEXT-905.
  REPLACE '%99999%' WITH g_line1 INTO g_out_text.
  PERFORM set_colorize_build.       ">Set color
  PERFORM set_sort_field.           ">Set ALV sort fields
  PERFORM set_fieldcat_build.       ">Set ALV field category
  PERFORM display_alv_list.         ">Call ALV Functions

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

************************************************************************
*                                                                      *
* END-OF-PAGE Event                                                    *
*                                                                      *
************************************************************************
END-OF-PAGE.

************************************************************************
*                                                                      *
* TOP-OF-PAGE Event                                                    *
*                                                                      *
************************************************************************
TOP-OF-PAGE.

************************************************************************
*                                                                      *
* TOP-OF-PAGE DURING LINE-SELECTION Event                              *
*                                                                      *
************************************************************************
TOP-OF-PAGE DURING LINE-SELECTION.

************************************************************************
*                                                                      *
* S U B R O U T I N E S                                                *
*                                                                      *
************************************************************************
*&---------------------------------------------------------------------*
*&      Form  set_initial_data
*&---------------------------------------------------------------------*
FORM set_initial_data .

  DATA: l_bukrs LIKE t001-bukrs.
*STATUS
  SET TITLEBAR 'T1000'.

  GET PARAMETER ID 'BUK' FIELD l_bukrs.

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


ENDFORM.                    " set_initial_data
*&---------------------------------------------------------------------*
*&      Form  set_alv_init
*&---------------------------------------------------------------------*
FORM set_alv_init .
  FREE:  it_sort, fc.
  CLEAR: alv_keyinfo, gs_layout, alv_print, fc.
* PRINTING SETTINGS
  gs_layout-get_selinfos = 'X'.
  gs_layout-group_change_edit = 'X'.

  alv_print-no_print_selinfos = 'X'.
  alv_print-no_coverpage = 'X'.
  alv_print-no_print_listinfos = 'X'.

ENDFORM.                    " set_alv_init
*&---------------------------------------------------------------------*
*&      Form  clearing_work_area
*&---------------------------------------------------------------------*
FORM clearing_work_area .

*  IF p_full EQ 'X'.
  alv_detail_func = 'REUSE_ALV_GRID_DISPLAY'.
*  ELSE.
*    alv_detail_func = 'REUSE_ALV_LIST_DISPLAY'.
*  ENDIF.

ENDFORM.                    " clearing_work_area
*&---------------------------------------------------------------------*
*&      Form  get_data_for_display
*&---------------------------------------------------------------------*
FORM get_data_for_display .

*  DATA:
  DATA: lv_awkey LIKE bkpf-awkey.
  DATA: lv_ebelp LIKE ztitivp-ebelp,
        lv_iblit LIKE ztitivp-iblit.

  RANGES: lr_hkont FOR bseg-hkont.

  CLEAR : lr_hkont, lr_hkont[].

  SELECT bukrs ivono lifnr opnbk waers ivamp kursf belnr netdt
         gjahr budat bldat wwert
         zterm ivamt bupla gsber zbd1t uzawe bktxt
         blart ivnum rtchg
    INTO CORRESPONDING FIELDS OF TABLE it_selt
    FROM ztitivk
   WHERE bukrs EQ p_bukrs
     AND opnbk IN s_opnbk
     AND netdt IN s_netdt
     AND waers IN s_waers
     AND ebeln IN s_ebeln
     AND lifnr IN s_lifnr
     AND livst EQ 'P'.

  IF sy-subrc NE 0.
    MESSAGE s902.  EXIT.
  ENDIF.

  LOOP AT it_selt INTO gs_selt.
*>사후납부
    CLEAR : gs_list.                  "> l_iblno, l_ebeln, l_reqno.
    CLEAR : gs_selt-netdt.
*>B/L 관리번호 구매전표번호 수입요청 관리번호
    SELECT iblno ebeln reqno ebelp  iblit
      INTO (gs_selt-iblno, gs_selt-ebeln, gs_selt-reqno, lv_ebelp,
            lv_iblit)
      FROM  ztitivp UP TO 1 ROWS
      WHERE ivono EQ gs_selt-ivono
        AND reqno IN s_reqno.
    ENDSELECT.

    IF sy-subrc <> 0.
      CONTINUE.
    ENDIF.

    IF gs_selt-reqno IS INITIAL.
      SELECT SINGLE reqno
        INTO gs_selt-reqno
        FROM ztitrqp
       WHERE ebeln EQ gs_selt-ebeln
         AND ebelp EQ lv_ebelp
         AND iblno EQ gs_selt-iblno
         AND iblit EQ lv_iblit.
    ENDIF.
*>선적차수
    SELECT SINGLE blcnt
      INTO  gs_selt-blcnt
      FROM  ztitblk
      WHERE iblno EQ gs_selt-iblno.

*>수입개설번호

    SELECT SINGLE opnno hwaer dmbtr
      INTO (gs_selt-opnno,gs_selt-hwaer,gs_selt-dmbtr)
      FROM ztitrqs
     WHERE reqno EQ gs_selt-reqno
      AND opnno IN s_opnno
      AND amdsq EQ '00'.
    IF sy-subrc <> 0.
      CONTINUE.
    ENDIF.

*>결제일자,만기일자.
    SELECT SINGLE *
       FROM ztitpnk
      WHERE iblno EQ gs_selt-iblno.

*>수입요청 종류
    SELECT SINGLE reqty ilcty opnbk
      INTO (gs_selt-reqty,gs_selt-ilcty,gs_selt-opnbk)
      FROM ztitrqk
     WHERE reqno EQ gs_selt-reqno.

*>신용장종류에 따른 만기일자변경.
    IF gs_selt-ilcty EQ 'A' OR
       gs_selt-ilcty EQ ' '.
      gs_selt-netdt = ztitpnk-stldt.
    ELSEIF gs_selt-ilcty EQ 'U'.
      gs_selt-netdt = ztitpnk-expdt.
    ENDIF.

*   domain의 value.
    PERFORM get_domain_value_text(ztir0000) USING :
                           'ZTIREQTY' gs_selt-reqty  gs_selt-reqtyt.

*>  은행파트너명
    SELECT SINGLE namet
       INTO gs_selt-name1
       FROM ztstig3
       WHERE parti EQ 'B'
         AND epart EQ gs_selt-opnbk
         AND bukrs EQ p_bukrs.

*   Notice문서내역
    SELECT SINGLE pntno ntcbk ssuch
           lifnr bgndt pntdt pntam
           waers opnno reqno
           blnum
           xranl expdt
           tsatz itrst kursf txz01
      INTO (gs_selt-pntno,gs_selt-ntcbk,gs_selt-ssuch,
   gs_selt-lifnr_p,gs_selt-bgndt,gs_selt-pntdt,gs_selt-pntam,
   gs_selt-waers_p,gs_selt-opnno_p,gs_selt-reqno_p,
   gs_selt-blnum,
   gs_selt-xranl,gs_selt-expdt,
   gs_selt-tsatz ,gs_selt-itrst,gs_selt-kursf_p,gs_selt-pntit)
      FROM ztivpn01
     WHERE ivono  EQ gs_selt-ivono
       AND reqno  EQ gs_selt-reqno.

    IF NOT gs_selt-xranl IS INITIAL.
      SELECT SINGLE ranl
        INTO gs_selt-xranl
        FROM vdarl
       WHERE bukrs EQ p_bukrs
         AND ranl  EQ gs_selt-xranl
         AND drueck IN s_fdtag.
      IF sy-subrc <> 0.
        CONTINUE.
      ENDIF.
    ENDIF.


    SELECT SINGLE ndays belnr saknr
      INTO (gs_selt-ndays,gs_selt-belnr_p,gs_selt-saknr)
      FROM ztitpnk
     WHERE pntno EQ gs_selt-pntno.

    SELECT SINGLE bu_sort1
      INTO gs_selt-ssunm
      FROM but000
     WHERE partner = gs_selt-ssuch.

    SELECT SINGLE namet
       INTO gs_selt-ntcnm
       FROM ztstig3
       WHERE parti EQ 'B'
         AND epart EQ gs_selt-ntcbk
         AND bukrs EQ p_bukrs.

*   송장 AP내역의 선택.
    CONCATENATE gs_selt-belnr gs_selt-gjahr
           INTO lv_awkey.

    SELECT SINGLE belnr
      INTO gs_selt-belnr_f
      FROM bkpf
     WHERE awtyp EQ 'RMRP'
       AND awkey EQ lv_awkey
       AND bukrs EQ p_bukrs
       AND blart EQ 'RE'.

    IF NOT gs_selt-xranl IS INITIAL.
      SELECT SINGLE dmbtr hkont augbl augdt
   INTO (gs_selt-dmbtr_v,gs_selt-hkont,gs_selt-augbl,gs_selt-augdt)
        FROM bseg
       WHERE bukrs EQ p_bukrs
         AND belnr EQ gs_selt-belnr_f
         AND gjahr EQ gs_selt-gjahr
         AND zterm IN s_zterm
         AND koart EQ 'K'.
      IF sy-subrc <> 0 .
        CONTINUE.
      ENDIF.

    ELSE.
      SELECT SINGLE dmbtr hkont augbl augdt
   INTO (gs_selt-dmbtr_v,gs_selt-hkont,gs_selt-augbl,gs_selt-augdt)
        FROM bseg
       WHERE bukrs EQ p_bukrs
         AND belnr EQ gs_selt-belnr_f
         AND gjahr EQ gs_selt-gjahr
         AND fdtag IN s_fdtag
         AND zterm IN s_zterm
         AND koart EQ 'K'.
      IF sy-subrc <> 0 .
        CONTINUE.
      ENDIF.

    ENDIF.

*   송장 AP 상대계정내역의 선택.
    SELECT SINGLE hkont
      INTO gs_selt-okont
      FROM bseg
     WHERE bukrs EQ p_bukrs
       AND belnr EQ gs_selt-belnr_f
       AND gjahr EQ gs_selt-gjahr
       AND koart EQ 'S'
       AND buzid EQ 'W'.
    IF sy-subrc <> 0.

      lr_hkont-sign = 'I'.
      lr_hkont-option = 'CP'.
      lr_hkont-low = '000919+++'.
      APPEND lr_hkont.

      lr_hkont-sign = 'I'.
      lr_hkont-option = 'CP'.
      lr_hkont-low = '000912+++'.
      APPEND lr_hkont.

      SELECT SINGLE hkont
        INTO gs_selt-okont
        FROM bseg
       WHERE bukrs EQ p_bukrs
         AND belnr EQ gs_selt-belnr_f
         AND gjahr EQ gs_selt-gjahr
         AND koart EQ 'S'
         AND hkont IN lr_hkont.
    ENDIF.

    PERFORM get_text_hkont  USING gs_selt-okont
                            CHANGING gs_selt-okonm.

    SELECT SINGLE name1
      INTO gs_selt-lifnm
      FROM lfa1
     WHERE lifnr = gs_selt-lifnr.
**************************************************

    MOVE-CORRESPONDING : gs_selt TO gs_list.
    APPEND gs_list TO it_list.

    CLEAR: it_subtotal.
    MOVE-CORRESPONDING : gs_selt TO it_subtotal.
    it_subtotal-count = 1.
    COLLECT it_subtotal.
  ENDLOOP.

  DESCRIBE TABLE it_list LINES g_line.
  IF g_line EQ 0.
    MESSAGE s902.
  ENDIF.

ENDFORM.                    " get_data_for_display
*&---------------------------------------------------------------------*
*&      Form  display_alv_list
*&---------------------------------------------------------------------*
FORM display_alv_list .

  DATA: fc_detail TYPE slis_fieldcat_alv OCCURS 0 WITH HEADER LINE.
  DATA: variant_detail      LIKE disvariant.
  DATA: exit     TYPE slis_event_exit   OCCURS 0 WITH HEADER LINE.
  DATA: events   TYPE slis_alv_event    OCCURS 0 WITH HEADER LINE.
  DATA: ls_event TYPE slis_alv_event.
  DATA: groups   TYPE slis_sp_group_alv OCCURS 0 WITH HEADER LINE.

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
*  gs_layout-coltab_fieldname  = 'COLOR'.
  gs_layout-group_change_edit = 'X'.
  gs_layout-f2code            = 'DISPLAY'.

* header.
*  gs_layout-no_colhead        = 'X'.

*  GS_LAYOUT-SUBTOTALS_TEXT = 'TOTAL'.
*  gs_layout-totals_text = ' TOTAL'.

  REFRESH exit.
  exit-ucomm = '&OL0'. exit-after = 'X'. APPEND exit.
  exit-ucomm = '&OLX'. APPEND exit.
  exit-ucomm = '&OAD'. APPEND exit.

*> event define.
  REFRESH events.
***************************
*  call function 'REUSE_ALV_EVENTS_GET'
*    exporting
*      i_list_type = 0
*    importing
*      et_events   = events.
*
*  read table events with key name = slis_ev_pf_status_set
*                        into ls_event.
*  if sy-subrc eq 0.
*    move  'STANDARD'  to ls_event-form.
*    append ls_event   to events.
*  endif.
*
*  read table events with key name = slis_ev_user_command
*                        into ls_event.
*  if sy-subrc eq 0.
*    move  g_user_command to ls_event-form.
*    append ls_event     to events.
*  endif.
*****************************
  events-name = slis_ev_top_of_page.
  events-form = 'TOP_OF_PAGE'.
  APPEND events.

  events-name = slis_ev_subtotal_text.
  events-form = slis_ev_subtotal_text.
  APPEND events.

*> ALV reuse function call..
  CALL FUNCTION alv_detail_func
    EXPORTING
      i_callback_program       = alv_repid
      i_callback_pf_status_set = 'SET_ALV_STATUS'
      i_callback_user_command  = g_user_command
*     I_STRUCTURE_NAME         =
*     IT_EXCLUDING             =
*     IT_SPECIAL_GROUPS        =
*     IT_FILTER                =
*     IS_SEL_HIDE              =
*     I_DEFAULT                = 'X'
*     I_SAVE                   = ' '
*     IS_VARIANT               =
      it_events                = events[]
      it_event_exit            = exit[]
*     IS_PRINT                 =
*     IS_REPREP_ID             =
*     I_SCREEN_START_COLUMN    = 0
*     I_SCREEN_START_LINE      = 0
*     I_SCREEN_END_COLUMN      = 0
*     I_SCREEN_END_LINE        = 0
      it_fieldcat              = fc_detail[]
      it_sort                  = it_sort
*     I_DEFAULT                = 'X'
*     IS_VARIANT               = VARIANT_DETAIL
      is_variant               = alv_variant
      i_save                   = c_save
      is_layout                = gs_layout
      is_print                 = alv_print
*   IMPORTING
*     E_EXIT_CAUSED_BY_CALLER  =
*     ES_EXIT_CAUSED_BY_USER   =
    TABLES
      t_outtab                 = it_list.

ENDFORM.                    " display_alv_list
*&---------------------------------------------------------------------*
*&      Form  SET_ALV_STATUS
*&---------------------------------------------------------------------*
FORM set_alv_status USING  extab TYPE slis_t_extab.

*  APPEND 'ARCHIVE'   TO extab.
*  APPEND '&VEXCEL'   TO extab.
*  APPEND '&AQW'      TO extab.
*  APPEND '&VCRYSTAL' TO extab.
*  APPEND '&VGRID'    TO extab.
*  APPEND '&EB9'      TO extab.
*  APPEND '&CRDESIG'  TO extab.

  APPEND 'ZTIT002'  TO extab.
  APPEND 'ZTIT005'  TO extab.
  APPEND 'ZTIT006'  TO extab.

*  APPEND '&OL0'  TO extab.
*  APPEND '&OAD'  TO extab.
*  APPEND '&AVE'  TO extab.

*  SET TITLEBAR 'T1000'.
  SET PF-STATUS 'STANDARD' EXCLUDING extab.

ENDFORM.                    " SET_ALV_STATUS
*&---------------------------------------------------------------------*
*&      Form  set_fieldcat_build
*&---------------------------------------------------------------------*
FORM set_fieldcat_build .

  PERFORM fieldcatalog_merge1 USING it_fieldcat[].

*  PERFORM 3010_fill_field_category USING :
*
**>다른 송장발행처
*       'S' 'REF_TABNAME'   'ZTITIVK',
*       ' ' 'TABNAME'     'IT_LIST',
*       ' ' 'FIELDNAME'    'LIFNR',
**       ' ' 'NO_OUT'       'X',
*       'E' 'OUTPUTLEN'   '10',
*
**은행코드
*       'S' 'REF_TABNAME'   'ZTITIVK',
*       ' ' 'TABNAME'     'IT_LIST',
*       ' ' 'FIELDNAME'   'OPNBK',
*       'E' 'OUTPUTLEN'   '10',
**만기일
*       'S' 'REF_TABNAME'   'ZTITIVK',
*       ' ' 'TABNAME'     'IT_LIST',
**       ' ' 'SELTEXT_M'   '세관',
*       ' ' 'FIELDNAME'    'NETDT',
**       ' ' 'NO_OUT'       'X',
*       'E' 'OUTPUTLEN'   '10',
*
**은행명
*       'S' 'SELTEXT_M'   '은행명',
**       ' S' 'REF_TABNAME'   'LFA1',
*       ' ' 'TABNAME'     'IT_LIST',
*       ' ' 'FIELDNAME'   'NAME1',
*       'E' 'OUTPUTLEN'   '15',
*
**
**구매오더
**       'S' 'SELTEXT_M'   '신고번호',
*       'S' 'REF_TABNAME'   'ZTITIVP',
*       ' ' 'TABNAME'     'IT_LIST',
*       ' ' 'FIELDNAME'   'EBELN',
*       'E' 'OUTPUTLEN'    '10',
**차수
**       'S' 'REF_TABNAME'   'ZTITBLK',
*       ' S' 'TABNAME'     'IT_LIST',
*       ' ' 'SELTEXT_M'   '차수',
*       ' ' 'FIELDNAME'    'BLCNT',
**       ' ' 'CFIELDNAME'   'CCUAKC',
**       ' ' 'DO_SUM'        'X',
*       'E' 'OUTPUTLEN'   '4',
**수입개설번호
*       'S' 'REF_TABNAME'   'ZTITRQS',
*       ' ' 'TABNAME'     'IT_LISTT',
**       ' ' 'SELTEXT_M'   '부가세',
*       ' ' 'FIELDNAME'    'OPNNO',
**       ' ' 'CFIELDNAME'   'CCUAKC',
**       ' ' 'DO_SUM'        'X',
*       'E' 'OUTPUTLEN'   '20',
**수입요청 종류코드
**       'S' 'REF_TABNAME'   'ZTITRQK',
*       'S' 'TABNAME'     'IT_LIST',
*       ' ' 'SELTEXT_M'   '구분',
*       ' ' 'FIELDNAME'    'REQTY',
**       ' ' 'CFIELDNAME'   'CCUAKC',
**       ' ' 'DO_SUM'        'X',
*       'E' 'OUTPUTLEN'   '4',
**수입요청종류 텍스트
*       'S' 'TABNAME'     'IT_LIST',
*       ' ' 'SELTEXT_M'   '수입요청종류',
*       ' ' 'FIELDNAME'    'REQTYT',
**       ' ' 'CFIELDNAME'   'CCUAKC',
**       ' ' 'DO_SUM'        'X',
*       'E' 'OUTPUTLEN'   '30',
***원화통화
**       'S' 'TABNAME'     'IT_LIST',
**       ' ' 'SELTEXT_M'   '통화',
**       ' ' 'FIELDNAME'    'HWAER',
**       'E' 'OUTPUTLEN'   '3',
***원화금액
**       'S' 'SELTEXT_M'   '원화금액',
**       ' ' 'TABNAME'     'IT_LIST',
**       ' ' 'FIELDNAME'   'DMBTR',
**       ' ' 'CFIELDNAME'   'HWAER',
**       ' ' 'DO_SUM'        'X',
**       'E' 'OUTPUTLEN'    '15',
**외화통화
*       'S' 'TABNAME'     'IT_LIST',
*       ' ' 'SELTEXT_M'   '통화',
*       ' ' 'FIELDNAME'    'WAERS',
*       'E' 'OUTPUTLEN'   '3',
**외화금액
*       'S' 'SELTEXT_M'   '외화금액',
*       ' ' 'TABNAME'     'IT_LIST',
*       ' ' 'FIELDNAME'   'IVAMP',
*       ' ' 'CFIELDNAME'   'WAERS',
*       ' ' 'DO_SUM'        'X',
*       'E' 'OUTPUTLEN'    '15',
**환율
*       'S' 'REF_TABNAME'   'ZTITIVK',
*       ' ' 'TABNAME'     'IT_LIST',
**       ' ' 'SELTEXT_M'   '관세사',
*       ' ' 'FIELDNAME'    'KURSF',
**       ' ' 'NO_OUT'       'X',
*       'E' 'OUTPUTLEN'   '9'.

ENDFORM.                    " set_fieldcat_build
*&---------------------------------------------------------------------*
*&      Form  3010_fill_field_category
*&---------------------------------------------------------------------*
FORM 3010_fill_field_category  USING    p_section p_fname p_value.

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
*&      Form  set_colorize_build
*&---------------------------------------------------------------------*
FORM set_colorize_build .

ENDFORM.                    " set_colorize_build
*&---------------------------------------------------------------------*
*&      Form  set_sort_field
*&---------------------------------------------------------------------*
FORM set_sort_field .

  REFRESH: it_sort.


*  CLEAR  st_sort.
*  st_sort-spos = '01'.
*  st_sort-fieldname = 'OPNBK'.
*  st_sort-tabname   = 'IT_LIST'.
**  st_sort-up        = 'X'.
**  ST_SORT-GROUP     = 'X'.
*  st_sort-subtot    = 'X'.
**  ST_SORT-EXPA      = 'X'.
*  APPEND st_sort TO it_sort.
*
*  CLEAR  st_sort.
*  st_sort-spos = '02'.
*  st_sort-fieldname = 'NETDT'.
*  st_sort-tabname   = 'IT_LIST'.
**  st_sort-up        = 'X'.
**  ST_SORT-GROUP     = 'X'.
*  st_sort-subtot    = 'X'.
**  ST_SORT-EXPA      = 'X'.
*  APPEND st_sort TO it_sort.


ENDFORM.                    " set_sort_field
*&---------------------------------------------------------------------*
*&      Form  exec_alv_f4
*&---------------------------------------------------------------------*
FORM exec_alv_f4 .

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

ENDFORM.                    " exec_alv_f4
*&---------------------------------------------------------------------*
*&      Form  alv_variant_check
*&---------------------------------------------------------------------*
FORM alv_variant_check .

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


ENDFORM.                    " alv_variant_check
*&---------------------------------------------------------------------*
*&      Form  TOP_OF_PAGE
*&---------------------------------------------------------------------*
FORM top_of_page.

  DATA: l_mode TYPE i.
  DATA: header TYPE slis_listheader OCCURS 0 WITH HEADER LINE.

  REFRESH header.
  header-typ = 'H'.
  header-info = '은행별 L/C 결제금액 일계표'.
*  IF p_int1 EQ 'X'.
*    CONCATENATE '사후납부' header-info INTO header-info
*                                       SEPARATED BY space.
*  ELSE.
*    CONCATENATE '월별납부' header-info INTO header-info
*                                       SEPARATED BY space.
*  ENDIF.
  CLEAR: header-key.
  APPEND header.

** JS전선 회사코드 2007/04 KSH --------------------------------------
  DATA: l_butxt LIKE t001-butxt.
  CLEAR: l_butxt.
  SELECT SINGLE butxt FROM t001
                      INTO l_butxt
                     WHERE bukrs EQ p_bukrs.

  header-typ = 'S'.
  header-key = '회사코드 '.
  CONCATENATE p_bukrs l_butxt INTO header-info SEPARATED BY space.
  APPEND header.
  CLEAR: header.
** JS전선 회사코드 2007/04 KSH --------------------------------------

  header-typ = 'S'.
  header-key = '출력일자:'(106).
  WRITE: sy-datlo TO header-info.
  APPEND header.

  CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
    EXPORTING
      it_list_commentary = header[].

ENDFORM.    ">TOP_OF_PAGE
*&---------------------------------------------------------------------*
*&      Form  input_field_check
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM input_field_check .

* Company code
  SELECT SINGLE *
    FROM t001
   WHERE bukrs EQ p_bukrs.
  IF sy-subrc <> 0.
    PERFORM get_ftext(rddfie00) USING 'T001' 'BUKRS' sy-langu
                                CHANGING dfies g_subrc.
    SET CURSOR FIELD 'P_BUKRS'.
    MESSAGE e348(m7) WITH dfies-scrtext_m.
  ENDIF.

*  SELECT expcd
*    INTO p_expcd
*    FROM ztitig06 UP TO 1 ROWS
*   WHERE bukrs  EQ  p_bukrs
*     AND expgr  EQ  'C'
*     AND cstcl  EQ  '1'.
*  ENDSELECT.
*  IF sy-subrc <> 0.
*    MESSAGE e878 WITH p_bukrs.
*  ENDIF.

ENDFORM.                    " input_field_check

*---------------------------------------------------------------------*
*       Form  SUBTOTAL_TEXT                                           *
*---------------------------------------------------------------------*
*FORM subtotal_text USING my_listhead LIKE t_alv_list
*                         my_subtotal TYPE slis_subtot_text.
*
*  DATA: l_count(10)  TYPE c,
*        l_text40(40) TYPE c.
*
*  FIELD-SYMBOLS: <l_fs>.
**  DATA: l_vendor(10) TYPE c.
*
*  CLEAR my_subtotal-display_text_for_subtotal.
*
*
*
*  CASE my_subtotal-criteria.
*    WHEN 'STATE'.  ">관세사.
*      SELECT SINGLE namet
*        INTO my_subtotal-display_text_for_subtotal
*        FROM ztstig3
*       WHERE parti  EQ  'H'
*         AND epart  EQ  my_listhead-state.
*      ASSIGN my_listhead-state TO <l_fs>.
*      MOVE-CORRESPONDING my_listhead TO t_alv_list.
*    WHEN 'CDCOR'.  ">세관.
*      PERFORM get_domain_value_text
*                  USING
*                     'ZTSCDCOR'
*                     my_listhead-cdcor
*                     l_text40.
*      my_subtotal-display_text_for_subtotal = l_text40.
*      ASSIGN my_listhead-cdcor TO <l_fs>.
*    WHEN 'BUPLA'.  ">사업장.
*      SELECT SINGLE name
*        INTO my_subtotal-display_text_for_subtotal
*        FROM j_1bbranch
*       WHERE bukrs  EQ  p_bukrs
*         AND branch EQ  my_listhead-bupla.
*      ASSIGN my_listhead-bupla TO <l_fs>.
*    WHEN OTHERS.
*      EXIT.
*  ENDCASE.
*
*  READ TABLE it_subtotal WITH KEY cdcor  = t_alv_list-cdcor
*                                  STATE  = t_alv_list-state
*                                  bupla  = t_alv_list-bupla.
*
*  IF sy-subrc EQ 0.
*    WRITE : it_subtotal-count TO l_count.
*  ELSE.
*    CLEAR: l_count.
*    l_count+09 = 0.
*  ENDIF.
*
*  CONCATENATE <l_fs>
*              my_subtotal-display_text_for_subtotal
*              l_count '건'
*              INTO my_subtotal-display_text_for_subtotal
*              SEPARATED BY space.

*ENDFORM.                    "SUBTOTAL_TEXT
*&---------------------------------------------------------------------*
*&      Form  CHECK_DOMAIN_VALUES
*&---------------------------------------------------------------------*
*       Domain Text Read
*----------------------------------------------------------------------*
FORM get_domain_value_text  USING  p_domain LIKE  dd07l-domname
                                   p_value
                                   p_text.

  DATA: l_value LIKE dd07v-domvalue_l,
        l_text  LIKE dd07v-ddtext.

  CLEAR: l_text.

  MOVE: p_value TO l_value.

  CALL FUNCTION 'RV_DOMAIN_VALUE_TEXTS'
    EXPORTING
      domname  = p_domain
      domvalue = l_value
    IMPORTING
      ddtext   = l_text.

  MOVE: l_text TO p_text.

ENDFORM.                    " CHECK_DOMAIN_VALUES
*&---------------------------------------------------------------------*
*&      Form  USER_ALV_COMMAND
*&---------------------------------------------------------------------*
FORM user_alv_command USING   r_ucomm      LIKE sy-ucomm
                              rs_selfield  TYPE slis_selfield.
*
*  CASE r_ucomm.
*    WHEN 'DISPLAY' OR '&IC1'.    " AUF DOPPELKLICK REAGIERIEN
*      CHECK : rs_selfield-tabindex GT 0 AND
*              rs_selfield-tabindex LT 99999999999.
*
*      READ TABLE it_list INDEX rs_selfield-tabindex.
*      IF NOT rs_selfieldtabindex IS INITIAL.
*        CLEAR: it_list.
*        READ TABLE it_list  INDEX rs_selfield-tabindex.
*        IF sy-subrc = 0.
*          PERFORM display_detail_info  USING rs_selfield-fieldname.
*        ENDIF.
*      ENDIF.
*
*  ENDCASE.
*  CLEAR: r_ucomm.

ENDFORM.                    " USER_ALV_COMMAND
*&---------------------------------------------------------------------*
*&      Form  FIELDCATALOG_MERGE1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_G_FIELDCAT_T[]  text
*----------------------------------------------------------------------*
FORM fieldcatalog_merge1 USING p_fieldcat_t TYPE slis_t_fieldcat_alv.

  DATA: ls_fieldcat          TYPE slis_fieldcat_alv,
        lt_fieldcat          TYPE slis_t_fieldcat_alv,
        ls_slis_sp_group_alv TYPE slis_sp_group_alv,
        n                    TYPE i,
        ls_sort              TYPE slis_sortinfo_alv.
  DATA: l_fieldcat_s  TYPE slis_fieldcat_alv.

  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      i_program_name     = alv_repid
      i_internal_tabname = 'GT_DATA'
      i_inclname         = alv_repid
    CHANGING
      ct_fieldcat        = p_fieldcat_t.

  LOOP  AT  p_fieldcat_t INTO l_fieldcat_s.

    CASE l_fieldcat_s-fieldname.
      WHEN 'IVONO'.
        l_fieldcat_s-outputlen = '10'.
        l_fieldcat_s-ddictxt    = 'M'.
        l_fieldcat_s-hotspot    = 'X'.
        l_fieldcat_s-seltext_m  = '송장관리번호'.
      WHEN 'SSNUM'.
        l_fieldcat_s-outputlen = '10'.
        l_fieldcat_s-ddictxt    = 'M'.
        l_fieldcat_s-seltext_m  = '은행명'.
      WHEN 'DMBTR'.
        l_fieldcat_s-ddictxt    = 'M'.
        l_fieldcat_s-currency   = 'KRW'.
**>   송장발행처
      WHEN 'LIFNR'.
        l_fieldcat_s-outputlen = '10'.
        l_fieldcat_s-hotspot    = 'X'.
**    은행코드
      WHEN 'OPNBK'.
        l_fieldcat_s-outputlen = '10'.
**    만기일
      WHEN 'NETDT'.
        l_fieldcat_s-outputlen = '10'.
**    은행명
      WHEN 'NAME1'.
        l_fieldcat_s-outputlen = '15'.
**    구매오더
      WHEN 'EBELN'.
        l_fieldcat_s-hotspot    = 'X'.
        l_fieldcat_s-outputlen = '10'.
**    차수
      WHEN 'BLCNT'.
        l_fieldcat_s-outputlen = '4'.
**    전표번호
      WHEN 'BELNR' .
        l_fieldcat_s-hotspot    = 'X'.
        l_fieldcat_s-outputlen = '10'.
        l_fieldcat_s-seltext_m  = '송장전표'.
**    전표번호
      WHEN 'BELNR_F'.
        l_fieldcat_s-hotspot    = 'X'.
        l_fieldcat_s-outputlen = '10'.
        l_fieldcat_s-seltext_m  = 'AP전표'.
**    전표번호
      WHEN 'AUGDT' OR 'AUGBL'.
        l_fieldcat_s-hotspot    = 'X'.
        l_fieldcat_s-outputlen = '10'.
**    전표번호
      WHEN 'BELNR_P'.
        l_fieldcat_s-hotspot    = 'X'.
        l_fieldcat_s-outputlen = '10'.
        l_fieldcat_s-seltext_m  = '차입전표'.
**    NOTICE 관리번호
      WHEN 'PNTNO'.
        l_fieldcat_s-hotspot    = 'X'.
**    론번호
      WHEN 'XRANL'.
        l_fieldcat_s-hotspot    = 'X'.
**    수입요청번호
      WHEN 'REQNO' OR 'REQNOH'.
        l_fieldcat_s-hotspot    = 'X'.
**    수입개설번호
      WHEN 'OPNNO'.
        l_fieldcat_s-hotspot    = 'X'.
        l_fieldcat_s-outputlen = '20'.
**    수입요청 종류코드
      WHEN 'REQTY'.
        l_fieldcat_s-outputlen = '4'.
**    수입요청종류 텍스트
      WHEN 'REQTYT'.
        l_fieldcat_s-outputlen = '30'.
        l_fieldcat_s-ddictxt    = 'M'.
        l_fieldcat_s-seltext_m  = '수입요청종류'.
**    외화통화
      WHEN 'WAERS'.
        l_fieldcat_s-outputlen = '3'.
**    외화금액
      WHEN 'IVAMP'.
        l_fieldcat_s-outputlen = '15'.
        l_fieldcat_s-cfieldname   = 'WAERS'.
        l_fieldcat_s-do_sum    = 'X'.
**    환율
      WHEN 'KURSF'.
        l_fieldcat_s-outputlen = '9'.

    ENDCASE.


    MODIFY p_fieldcat_t FROM l_fieldcat_s.

  ENDLOOP.

ENDFORM.                    " fieldcatalog_merge1

*&------------------------------------------------------------------*
*&      Form  USER_COMMAND
*&------------------------------------------------------------------*
*       외부(REUSE_ALV_EVENTS_GET)에서 CALL한 FORM 문이다.
*       at user command event에 기술할 내용을 적는?
*-------------------------------------------------------------------*
FORM user_command USING p_ucomm    LIKE sy-ucomm
                        p_selfield TYPE slis_selfield.

  DATA: ls_vari      TYPE disvariant,
        ls_slis_layo TYPE slis_layout_alv,
        lt_slis_fcat TYPE slis_t_fieldcat_alv,
        lt_slis_sort TYPE slis_t_sortinfo_alv,
        lt_slis_filt TYPE slis_t_filter_alv,
        ls_slis_prnt TYPE slis_print_alv.

  DATA:fname(20).
  FIELD-SYMBOLS <fs> TYPE table.

  CASE p_ucomm.

    WHEN '&IC1' OR 'DISPLAY'.

      READ TABLE it_list INDEX p_selfield-tabindex.
      IF NOT p_selfield-tabindex IS INITIAL.
        CLEAR: it_list.
        READ TABLE it_list  INDEX p_selfield-tabindex.
        IF sy-subrc = 0.
          PERFORM display_detail_info  USING p_selfield-fieldname.
        ENDIF.
      ENDIF.

  ENDCASE.

ENDFORM.                    "user_command

*&---------------------------------------------------------------------*
*&      Form  DISPLAY_DETAIL_INFO
*&---------------------------------------------------------------------*
* 세부내역 조회화면으로 이동
*----------------------------------------------------------------------*
* --> P_FNAME  선택된 FieldName
*----------------------------------------------------------------------*
FORM display_detail_info  USING p_fname.
  DATA: kdy_val(8) VALUE '/110',
        lv_amdsq   LIKE ztivrq04-amdsq.

  CASE p_fname.
*   론번호
    WHEN 'XRANL'.
      PERFORM display_loan_master(ztir8000)  USING it_list-xranl
                                                   it_list-bukrs.
    WHEN 'REQNO' OR 'REQNOH' OR 'OPNNO'.
      IF NOT it_list-reqno IS INITIAL.
        SELECT SINGLE amdsq
          INTO lv_amdsq
          FROM ztivrq04
         WHERE reqno EQ it_list-reqno.

        PERFORM display_import_document(ztir8000)
                                  USING it_list-reqno
                                        lv_amdsq
                                        '00000'.
      ENDIF.
    WHEN 'IVONO' OR 'IVNUM'.
      IF it_list-ivono <> space.
        SET PARAMETER ID 'ZTIIVONO' FIELD it_list-ivono.
        CALL TRANSACTION 'ZTIT303' AND SKIP FIRST SCREEN.
      ENDIF.
    WHEN 'PNTNO'.
      IF it_list-pntno <> space.
        SET PARAMETER ID 'ZTIPNTNO' FIELD it_list-pntno.
        CALL TRANSACTION 'ZTIT803' AND SKIP FIRST SCREEN.
      ENDIF.
    WHEN 'LIFNR'.
      IF it_list-lifnr <> space.

*- CCM-BP : 202304.
*        SET PARAMETER ID 'LIF' FIELD it_list-lifnr.
*        SET PARAMETER ID 'EKO' FIELD space.
*        SET PARAMETER ID 'KDY' FIELD kdy_val.
*        CALL TRANSACTION 'MK03' AND SKIP FIRST SCREEN.

        DATA: lv_lifnr TYPE lifnr.

        lv_lifnr = it_list-lifnr.
        SET PARAMETER ID 'EKO' FIELD space.
        SET PARAMETER ID 'KDY' FIELD kdy_val.

        CALL FUNCTION 'Z_BP_DISPLAY_S4H'
          EXPORTING
            i_lifnr = lv_lifnr
            i_gubun = 'K'
            i_tcode = 'MK03'.

      ENDIF.
    WHEN 'BELNR'.
      IF it_list-belnr <> space.
        SET PARAMETER ID 'RBN' FIELD it_list-belnr.
        SET PARAMETER ID 'GJR' FIELD it_list-gjahr.
        CALL TRANSACTION 'MIR4' AND SKIP FIRST SCREEN.
      ENDIF.
    WHEN 'AUGBL' OR 'AUGDT'.
      IF it_list-augbl <> space.
        SET PARAMETER ID 'BUK' FIELD  p_bukrs.
        SET PARAMETER ID 'BLN' FIELD it_list-augbl.
        SET PARAMETER ID 'GJR' FIELD it_list-augdt(4).
        CALL TRANSACTION 'FB03' AND SKIP FIRST SCREEN.
      ENDIF.
    WHEN 'BELNR_F'.
      IF it_list-belnr_f <> space.
        SET PARAMETER ID 'BUK' FIELD  p_bukrs.
        SET PARAMETER ID 'BLN' FIELD it_list-belnr_f.
        SET PARAMETER ID 'GJR' FIELD it_list-gjahr.
        CALL TRANSACTION 'FB03' AND SKIP FIRST SCREEN.
      ENDIF.
    WHEN 'BELNR_P'.
      IF it_list-belnr_p <> space.
        SET PARAMETER ID 'BUK' FIELD  p_bukrs.
        SET PARAMETER ID 'BLN' FIELD it_list-belnr_p.
        SET PARAMETER ID 'GJR' FIELD it_list-gjahr.
        CALL TRANSACTION 'FB03' AND SKIP FIRST SCREEN.
      ENDIF.
    WHEN 'EBELN'.
      IF it_list-ebeln <> space.
        SET PARAMETER ID 'ENJ_CALL_ME23N' FIELD 'X'.

        CALL FUNCTION 'ME_DISPLAY_PURCHASE_DOCUMENT'
          EXPORTING
            i_ebeln              = it_list-ebeln
            i_ebelp              = '00010'
            i_enjoy              = 'X'
          EXCEPTIONS
            not_found            = 1
            no_authority         = 2
            invalid_call         = 3
            preview_not_possible = 4
            OTHERS               = 5.
        IF sy-subrc <> 0.
          MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                  WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
        ENDIF.
      ENDIF.
  ENDCASE.

ENDFORM.                    " DISPLAY_DETAIL_INFO

*&---------------------------------------------------------------------*
*&      Form  GET_TEXT_HKONT
*&---------------------------------------------------------------------*
* 세부내역 조회화면으로 이동
*----------------------------------------------------------------------*
* --> P_FNAME  선택된 FieldName
*----------------------------------------------------------------------*
FORM get_text_hkont  USING    p_saknr
                     CHANGING p_txt50.

  DATA: lv_saknr LIKE ska1-saknr.

* 이미 읽었떤 업종인지 확인
  lv_saknr = p_saknr.
  CLEAR: gt_txtsaknr.
  READ TABLE gt_txtsaknr  WITH KEY saknr = lv_saknr.
  IF sy-subrc = 0.
    p_txt50 = gt_txtsaknr-txt50.   "업종명

  ELSE.
*   처음 나온 업종이므로 Table에서 선택
    SELECT SINGLE txt50 INTO gt_txtsaknr-txt50
                        FROM skat
                        WHERE spras = '3' AND   "언어키(KO)
                              ktopl = '1000' AND   "계정과목표
                              saknr = lv_saknr.
    IF sy-subrc = 0.
      p_txt50 = gt_txtsaknr-txt50.   "새로 선택된 업종명

*     InternalTable에 저장
      gt_txtsaknr-saknr = lv_saknr.
      APPEND gt_txtsaknr.

    ELSE.
      CLEAR: p_txt50.
    ENDIF.
  ENDIF.

ENDFORM.                    " GET_TEXT_HKONT
