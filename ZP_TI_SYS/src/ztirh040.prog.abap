************************************************************************
*                                                                      *
* Title         : ZTIRH040                                             *
*                                                                      *
* Description   : [Report] 수입 진행 List                              *
*                                                                      *
* Creation Date : 2008/05/26                                           *
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
*&---------------------------------------------------------------------*
*                        MODIFICATION LOG                              *
*----------------------------------------------------------------------*
*   DATE        AUTHORS              DESCRIPTION                       *
* ----------   --------- --------------------------------------------- *
* 2009/10/13    조성임    [제목] 자재명,업체코드 추가                  *
*                         [요청번호]C20091013_39827                    *
* 2019/05/03    신재호    [제목] 보험관련 필드 추가                    *
*                         [요청번호] 기능개선 278454                   *
* 2026/06/30    ZLSGMM5   CHM2606-00689                                *
************************************************************************
REPORT  ztirh040
        MESSAGE-ID zmti00
        NO STANDARD PAGE HEADING.

************************************************************************
* TYPES and TYPE-POOLS                                                 *
************************************************************************
TYPE-POOLS: slis.    "> Globale Type(ALV)

TYPES: BEGIN OF ty_selt.
TYPES:
            rpttyn LIKE dd07d-ddtext.       "신고형태명
TYPES: END OF ty_selt.


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
      t_fieldcat  TYPE slis_t_fieldcat_alv WITH HEADER LINE,
      g_exit(1)   TYPE c,
      dyname      LIKE d020s-prog,
*      L_TITLE     TYPE SY-TITLE.
      g_title(99) TYPE c,
      extab       TYPE slis_t_extab.

************************************************************************
* SAP Tables                                                           *
************************************************************************
TABLES: dfies,
        ekko,
        ekpo,
        t001,
        t001w,
        rbkp,
        ztitrqk,
        ztitrqp,
        ztitrqs,
        ztitblk,
        ztitblp,
        ztitcrk,
        ztitcck,
        ztitccp,
        ztitgrk,
        ztitgrp,
        ztitivk,
        ztitivp,
        ztitbik,
        ztitbok,
        bse_clr,
        ztitpnk,
        bseg,
        ztitpnp,
        mara.

TABLES: icon.
************************************************************************
* Internal Tables  & Structure
************************************************************************
*SELECT용
DATA: it_selt TYPE STANDARD TABLE OF ty_selt,
      gs_selt TYPE ty_selt,
      ls_selt TYPE ty_selt.

DATA: BEGIN OF it_list OCCURS 0,
        box,
        ebeln     LIKE ekko-ebeln,      "구매번호
        ebelp     LIKE ekpo-ebelp,      "구매번호아이템
        lcicn(4),                       "L/C  아이콘
        blicn(4),                       "B/L  아이콘
        ipicn(4),                       "보험 아이콘
        ccicn(4),                       "통관 아이콘
        gricn(4),                       "G/R  아이콘
        ivicn(4),                       "송장 아이콘
        pnicn(4),                     "Notice 아이콘
        biicn(4),
        boicn(4),
*.......P/O
        lifnr     LIKE ekko-lifnr,      "공급업체
        name1     LIKE lfa1-name1,      "공급업체명
        werks     LIKE ekpo-werks,      "플랜트
        matnr     LIKE ekpo-matnr,      "자재번호
        maktx     LIKE makt-maktx,      "자재명
        txz01     LIKE ekpo-txz01,      "PO내역
        menge     LIKE ekpo-menge,      "P/O 수량
        meins     LIKE ekpo-meins,      "P/O 수량 단위
        netpr     LIKE ekpo-netpr,      "단가
        waers     LIKE ekko-waers,      "통화키
        netwr     LIKE ekpo-netwr,      "금액
        bsart     LIKE ekko-bsart,    "문서유형
        bedat     LIKE ekko-bedat,
*        zzmlcca   LIKE ekko-zzmlcca,    "L/C Category
*.......L/C
        reqno     LIKE ztitrqk-reqno,   "수입의뢰관리번호
        amdsq     LIKE ztitrqp-amdsq,   "Amend 차수
        reqtyl    LIKE ztitrqk-reqty,   "수입의뢰종류
        zterm     LIKE ztitrqs-zterm,
        text1     LIKE t052u-text1,
        reqit     LIKE ztitrqp-reqit,   "수입의뢰item
        opnno     LIKE ztitrqs-opnno,   "수입개설번호
        opndt     LIKE ztitrqs-opndt,   "수입개설일자
        rqmng     LIKE ztitrqp-rqmng,   "수량
        docstl    LIKE ztitrqs-docst,
*> 2008.06.17 --- 사후건 확인하기 위하여 추가
        anbty     LIKE ztitrqk-anbty,  "사전/사후 구분자
*< 2008.06.17 --- 사후건 확인하기 위하여 추가
*.......B/L
        iblno     LIKE ztitblk-iblno,   "B/L관리번호
        iblit     LIKE ztitblp-iblit,   "B/L관리번호 ITEM
        blnum     LIKE ztitblk-blnum,   "B/L번호
        inbdt     LIKE ztitblk-inbdt,   "실입항일
        blmng     LIKE ztitblp-blmng,   "B/L수량
        bletd     LIKE ztitblk-bletd,
        bleta     LIKE ztitblk-bleta,
*.......I/P
        iipno     LIKE ztitip1-iipno,   "보험관리번호
        ispno     LIKE ztitip1-ispno,   "보험증권번호
        iopdt     LIKE ztitip1-iopdt,   "보험개시일
        docst     LIKE ztitip1-docst,
*.......C/C
        iccno     LIKE ztitcck-iccno,   "통관관리번호
        cdcno     LIKE ztitcck-cdcno,   "통관수리번호
        cdrdt     LIKE ztitcck-cdrdt,   "수리일자
*        netpr_cc  LIKE ztitccp-netpr,   "잠정단가
*        cnfpr     LIKE ztitccp-cnfpr,   "확정단가
        ccmng     LIKE ztitccp-ccmng,   "통관수량
        docstc    LIKE ztitcrk-docst,
*.......G/R
        igrno     LIKE ztitgrk-igrno,   "입고관리번호
        budat_gr  LIKE ztitgrk-budat,   "전기일
        grmng     LIKE ztitgrp-grmng,   "입고수량
*.......I/V
        ivono     LIKE ztitivk-ivono,   "송장관리번호
        ivnum     LIKE ztitivk-ivnum,   "송장번호
        rblgp     LIKE ztitivp-rblgp,     "송장품목번호'
        belnr     LIKE ztitivk-belnr,   "송장전표번호
        belnr1    LIKE bkpf-belnr,      "송장회계문서 번호.
        ajahr     LIKE ztitivk-gjahr,   "회계년도
        budat     LIKE ztitivk-budat,   "전기일
        bldat     LIKE ztitivk-bldat,   "증빙일
        netdt_iv  LIKE ztitivk-netdt,   "만기일
        refwr     LIKE ztitivp-refwr,   "송장금액
        ivmng     LIKE ztitivp-ivmng,   "송장수량
        gjahr     LIKE ztitivk-gjahr,   "송장년도
        bukrs     LIKE ztitivk-bukrs,   "회사코드
        livst     LIKE ztitivk-livst,  "문서상태 전기완료, 전기대상.
        pntno     LIKE ztitpnk-pntno, "Notice관리번호
        gjahr_clr LIKE ztitpnk-gjahr, "반제전표년도
        belnr_clr LIKE ztitpnk-belnr, "반제전표
        augbl     LIKE bseg-augbl, "지급전표
        augdt     LIKE bseg-augdt, "지급전표일자
*>반입
        ibino     LIKE ztitbik-ibino,
        bidnr     LIKE ztitbik-bidnr,
        blocc     LIKE ztitbik-blocc,
        biwet     LIKE ztitbik-biwet,
        bimei     LIKE ztitbik-meins,
        bilot     LIKE ztitbik-bilot,
        bindt     LIKE ztitbik-bindt,
*>반출
        ibono     LIKE  ztitbok-ibono,
        bodnr     LIKE  ztitbok-bodnr,
        bowet     LIKE  ztitbok-bowet,
        boudt     LIKE  ztitbok-boudt,
        bomei     LIKE  ztitbok-meins.

DATA: END   OF it_list.

DATA: BEGIN OF it_imtab OCCURS 0,
        ebeln LIKE ekko-ebeln,      "구매번호
        ebelp LIKE ekpo-ebelp,      "구매번호아이템
        lifnr LIKE ekko-lifnr,      "공급업체
        werks LIKE ekpo-werks,      "플랜트
        matnr LIKE ekpo-matnr,      "자재번호
        menge LIKE ekpo-menge,      "P/O 수량
        meins LIKE ekpo-meins,      "P/O 수량 단위
        netpr LIKE ekpo-netpr,      "단가
        waers LIKE ekko-waers,      "통화키
        netwr LIKE ekpo-netwr,      "금액
        bsart LIKE ekko-bsart,      "문서유형
        bedat LIKE ekko-bedat,
        txz01 LIKE ekpo-txz01,      "자재명
      END OF it_imtab.

DATA : BEGIN OF it_ztitig02 OCCURS 0.
         INCLUDE STRUCTURE ztitig02.
DATA : END   OF it_ztitig02.

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

DATA : s_variant LIKE  disvariant,
       s_var_usr LIKE  disvariant.


************************************************************************
* CONSTANTS                                                            *
************************************************************************
CONSTANTS:
*    c_bukrs     LIKE t001-bukrs     VALUE '1000',   ">Company code
  c_save(1) TYPE  c             VALUE 'A',
  c_success TYPE c        VALUE 'S'.
*----------------------------------------------------------------------
* Work fields
*----------------------------------------------------------------------
DATA : g_line          TYPE   i,             "Line counter
       g_subrc         LIKE   sy-subrc,      "Return code
       g_tabix         LIKE   sy-tabix,      "table index
       g_line1(3)      TYPE   n,             "LINE COUNT
       g_out_text(70)  TYPE   c,             "text field(display)
       g_err_mode      TYPE   c,
       g_mode          TYPE   c,
       line_cnt(02)    TYPE   n,
       g_answer        TYPE   c,
       field_name(20),
       field_name1(20),
       g_findscr       LIKE sy-dynnr,
       g_findline      TYPE i,
       g_fieldname(20) TYPE c.

DATA: ok-code          TYPE syucomm.

DATA : lifnr_t LIKE lfa1-name1,
       payer_t LIKE lfa1-name1.

************************************************************************
* User Included                                                        *
************************************************************************
INCLUDE: <icon>,
         <symbol>.

************************************************************************
* SELECT-OPTIONS / PARAMETERS                                          *
************************************************************************
SELECTION-SCREEN BEGIN OF BLOCK box1 WITH FRAME TITLE TEXT-001.

  SELECT-OPTIONS:
    s_bukrs  FOR ztitrqk-bukrs                   "회사코드.
                      NO-EXTENSION NO INTERVALS OBLIGATORY
                      MEMORY ID buk
                      MODIF  ID iog ,
    s_ekorg  FOR ztitivk-ekorg MODIF  ID iog,                 "4구매조직
    s_ekgrp  FOR ztitivk-ekgrp MODIF  ID iog,                 "3구매그룹
    s_ebeln  FOR ekko-ebeln,
    s_ebelp  FOR ekpo-ebelp,
    s_lifnr  FOR ekko-lifnr,
    s_werks  FOR ekpo-werks,
    s_matnr  FOR mara-matnr,
    s_zterm  FOR ekko-zterm,
    s_bedat  FOR ekko-bedat.
SELECTION-SCREEN END OF BLOCK box1.

SELECTION-SCREEN BEGIN OF BLOCK box2 WITH FRAME TITLE TEXT-002.
  PARAMETERS: p_full RADIOBUTTON GROUP pg3 MODIF ID opn DEFAULT 'X',
              p_list RADIOBUTTON GROUP pg3 MODIF ID opn.
SELECTION-SCREEN END OF BLOCK box2.

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

*> 지급조건 HELP(Low values)
AT SELECTION-SCREEN ON VALUE-REQUEST FOR s_zterm-low.
  PERFORM get_f4_for_zterm(ztir0000) USING s_zterm-low.
*> 지급조건 HELP(High values)
AT SELECTION-SCREEN ON VALUE-REQUEST FOR s_zterm-high.
  PERFORM get_f4_for_zterm(ztir0000) USING s_zterm-high.

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

  SELECT SINGLE * FROM t001
                 WHERE bukrs EQ l_bukrs.
*  IF sy-subrc NE 0.
*    SELECT SINGLE * FROM t001
*                   WHERE bukrs EQ 'SPC'.
*  ENDIF.

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

  IF p_full EQ 'X'.
    alv_detail_func = 'REUSE_ALV_GRID_DISPLAY'.
  ELSE.
    alv_detail_func = 'REUSE_ALV_LIST_DISPLAY'.
  ENDIF.

ENDFORM.                    " clearing_work_area
*&---------------------------------------------------------------------*
*&      Form  get_data_for_display
*&---------------------------------------------------------------------*
FORM get_data_for_display .

  DATA : BEGIN OF lt_cctab OCCURS 0,
           iccno LIKE ztitcck-iccno,   "통관관리번호
           cdcno LIKE ztitcck-cdcno,   "통관수리번호
           cdrdt LIKE ztitcck-cdrdt,   "수리일자
           ccmng LIKE ztitccp-ccmng,   "통관수량
           cfnst LIKE ztitcck-cfnst,   "신고유형
           docst LIKE ztitcck-docst,   ">by YSH(070730)
         END OF lt_cctab.


  DATA : BEGIN OF lt_bltab OCCURS 0,
           iblno LIKE ztitblk-iblno,
           iblit LIKE ztitblp-iblit,
           blnum LIKE ztitblk-blnum,
           inbdt LIKE ztitblk-inbdt,
           bletd LIKE ztitblk-bletd,
           bleta LIKE ztitblk-bleta,
           blmng LIKE ztitblp-blmng,
           bldst LIKE ztitblk-bldst,
         END OF lt_bltab.

  DATA : BEGIN OF lt_lctab OCCURS 0,
           reqno  LIKE ztitrqp-reqno,
           amdsq  LIKE ztitrqp-amdsq,
           reqtyl LIKE ztitrqk-reqty,
           zterm  LIKE ztitrqs-zterm,
           text1  LIKE t052u-text1,
           reqit  LIKE ztitrqp-reqit,
           rqmng  LIKE ztitrqp-rqmng,
           opnno  LIKE ztitrqs-opnno,
           opndt  LIKE ztitrqs-opndt,
           docstl LIKE ztitrqs-docst,
*> 2008.06.17 --- 사후건 확인하기 위하여 추가
           anbty  LIKE ztitrqk-anbty,  "사전/사후 구분자
*< 2008.06.17 --- 사후건 확인하기 위하여 추가
*CHM2606-00689 {
           iblno  LIKE ztitrqp-iblno,
           iblit  LIKE ztitrqp-iblit,
*CHM2606-00689 }
         END OF lt_lctab.
  DATA : lt_list_t LIKE it_list OCCURS 0 WITH HEADER LINE.
  DATA : lt_ekbe   LIKE ekbe    OCCURS 0 WITH HEADER LINE.

  DATA : l_amdsq LIKE ztitrqp-amdsq.

  CLEAR:  it_list,  it_list[],
          it_imtab, it_imtab[].

*> Get import document type and terms of payment .
  PERFORM get_used_payment_term(ztir0000)  TABLES  it_ztitig02
                                           USING   g_subrc c_success.
  IF g_subrc NE 0.
    EXIT.
  ENDIF.


  SELECT a~ebeln b~ebelp a~lifnr a~waers a~bedat
         b~werks b~matnr b~menge b~meins b~netpr b~netwr
**********************************************************
* 20091013 simcho by 유경진S
* 자재품명, 업체명 추가
**********************************************************
         b~txz01
           INTO CORRESPONDING FIELDS OF TABLE it_imtab
           FROM ekko AS a
           JOIN ekpo AS b
             ON a~ebeln = b~ebeln
          FOR ALL ENTRIES IN it_ztitig02
          WHERE a~ebeln   IN s_ebeln
            AND b~ebelp   IN s_ebelp
            AND a~bukrs   IN s_bukrs
            AND a~ekorg   IN s_ekorg
            AND a~ekgrp   IN s_ekgrp
            AND a~lifnr   IN s_lifnr
            AND a~zterm   IN s_zterm
            AND a~bedat   IN s_bedat
            AND  b~werks IN s_werks
            AND b~matnr IN s_matnr
            AND b~loekz   EQ space
            AND a~loekz EQ space
            AND a~memory EQ space
*          AND   frgrl  NE c_true
            AND b~repos  NE space
            AND a~bstyp  EQ it_ztitig02-bstyp
            AND a~bsart  EQ it_ztitig02-bsart
            AND a~zterm  EQ it_ztitig02-zterm.


  IF sy-subrc NE 0.
    MESSAGE s902.  EXIT.
  ENDIF.

* LC
  LOOP AT it_imtab.
    CLEAR : lt_list_t.
    MOVE-CORRESPONDING it_imtab TO lt_list_t.
    SELECT b~reqno b~amdsq b~reqit b~rqmng a~docst AS docstl
           a~opnno a~opndt a~zterm c~reqty AS reqtyl
           c~anbty
           b~iblno b~iblit
           INTO CORRESPONDING FIELDS OF TABLE lt_lctab
           FROM ztitrqp AS b
           JOIN ztitrqs AS a
             ON a~reqno = b~reqno
            AND a~amdsq = b~amdsq
           JOIN ztitrqk AS c
             ON a~reqno = c~reqno
          WHERE b~ebeln = it_imtab-ebeln
            AND b~ebelp = it_imtab-ebelp.
    IF sy-subrc = 0.
      LOOP AT lt_lctab.
        CLEAR l_amdsq.
        SELECT DISTINCT MAX( amdsq ) INTO l_amdsq
                                     FROM ztitrqp
                                    WHERE reqno = lt_lctab-reqno
                                      AND reqit = lt_lctab-reqit.
        CHECK l_amdsq = lt_lctab-amdsq.
        MOVE-CORRESPONDING lt_lctab TO lt_list_t.
*> Terms of payment Text.
        IF NOT lt_list_t-zterm IS INITIAL.
          SELECT text1
            FROM t052u UP TO 1 ROWS
            INTO lt_list_t-text1
           WHERE zterm  EQ  lt_list_t-zterm
             AND spras  EQ  sy-langu.
          ENDSELECT.
        ENDIF.

        CASE lt_list_t-docstl.
          WHEN 'O'.
            lt_list_t-lcicn = icon_led_green.
          WHEN OTHERS.
            lt_list_t-lcicn = icon_led_yellow.
        ENDCASE.

        APPEND lt_list_t.
      ENDLOOP.
    ELSE.
      lt_list_t-lcicn = icon_led_red.
      APPEND lt_list_t.
    ENDIF.
  ENDLOOP.


*.B/L
  LOOP AT lt_list_t.
    CLEAR it_list.
    MOVE-CORRESPONDING lt_list_t TO it_list.
*>사후건 분리하여 REPORT 표시 수정 2008.06.16 BY KSJ
    IF lt_list_t-anbty EQ 'A'.  ">사후건
*-----------------------------------------------------------------*
* CHM2606-00689 {
* ebeln+ebelp만으로 조회 시 분할선적(B/L 2건 이상) 건에서
* reqit 루프 횟수만큼 B/L이 중복 APPEND되는 버그 수정.
* ZTITRQP에 매핑된 iblno/iblit으로 1:1 매칭하도록 변경.
*-----------------------------------------------------------------*
      IF NOT lt_list_t-iblno IS INITIAL.
        SELECT a~blnum a~inbdt a~bldst a~bletd a~bleta
               b~iblno b~iblit b~blmng
               INTO CORRESPONDING FIELDS OF TABLE lt_bltab
               FROM ztitblk AS a
               JOIN ztitblp AS b
                 ON a~iblno = b~iblno
             WHERE b~iblno = lt_list_t-iblno
               AND b~iblit = lt_list_t-iblit
               AND b~ebeln = lt_list_t-ebeln
               AND b~ebelp = lt_list_t-ebelp.
      ELSE.
*       ZTITRQP에 iblno 매핑이 없는 경우(B/L 미등록 등) 기존 로직 유지
        SELECT a~blnum a~inbdt a~bldst a~bletd a~bleta
               b~iblno b~iblit b~blmng
               INTO CORRESPONDING FIELDS OF TABLE lt_bltab
               FROM ztitblk AS a
               JOIN ztitblp AS b
                 ON a~iblno = b~iblno
             WHERE b~ebeln = lt_list_t-ebeln
               AND b~ebelp = lt_list_t-ebelp.
      ENDIF.
    ELSE.          ">사전
      SELECT a~blnum a~inbdt a~bldst a~bletd a~bleta
             b~iblno b~iblit b~blmng
             INTO CORRESPONDING FIELDS OF TABLE lt_bltab
             FROM ztitblk AS a
             JOIN ztitblp AS b
               ON a~iblno = b~iblno
           WHERE b~ebeln = lt_list_t-ebeln
             AND b~ebelp = lt_list_t-ebelp
             AND b~reqno = lt_list_t-reqno
             AND b~reqit = lt_list_t-reqit.
    ENDIF.
* } CHM2606-00689

    IF sy-subrc = 0.
      LOOP AT lt_bltab.
        MOVE-CORRESPONDING lt_bltab TO it_list.
        it_list-blicn = icon_led_green.

        APPEND it_list.
      ENDLOOP.
    ELSE.
      it_list-blicn = icon_led_red.
      APPEND it_list.
    ENDIF.
  ENDLOOP.


  LOOP AT it_list.
*.I/P
    IF it_list-anbty EQ 'A'.    ">사후건
      SELECT SINGLE iipno ispno iopdt docst
                    INTO CORRESPONDING FIELDS OF it_list
                    FROM ztitip1
                   WHERE reqno EQ it_list-reqno
                     AND iblno EQ it_list-iblno.
    ELSE.
      SELECT SINGLE iipno ispno iopdt docst
                    INTO CORRESPONDING FIELDS OF it_list
                    FROM ztitip1
                   WHERE reqno EQ it_list-reqno
                     AND ebeln EQ it_list-ebeln.
    ENDIF.
    IF sy-subrc = 0.
      CASE it_list-docst.
        WHEN 'O'.
          it_list-ipicn = icon_led_green.
        WHEN OTHERS.
          it_list-ipicn = icon_led_yellow.
      ENDCASE.
    ELSE.
      it_list-ipicn = icon_led_red.
    ENDIF.

*.C/C
    CLEAR : lt_cctab, lt_cctab[].
    SELECT * INTO CORRESPONDING FIELDS OF TABLE lt_cctab
             FROM   ztitcck AS a
               JOIN ztitccp AS b
                 ON a~iccno = b~iccno
                AND a~iccsq = b~iccsq
            WHERE b~ebeln EQ it_list-ebeln
              AND b~ebelp EQ it_list-ebelp
              AND b~iblno EQ it_list-iblno
              AND b~iblit EQ it_list-iblit
              AND a~cfnst IN ('C', 'H').

    IF sy-subrc = 0.

      READ TABLE lt_cctab WITH KEY cfnst = 'C'.
      IF sy-subrc = 0.
        MOVE : lt_cctab-iccno TO it_list-iccno,
               lt_cctab-cdcno TO it_list-cdcno,
               lt_cctab-cdrdt TO it_list-cdrdt,

               lt_cctab-ccmng TO it_list-ccmng.
      ELSE.
        READ TABLE lt_cctab WITH KEY cfnst = 'H'.
        MOVE : lt_cctab-iccno TO it_list-iccno,
               lt_cctab-cdcno TO it_list-cdcno,
               lt_cctab-cdrdt TO it_list-cdrdt,
               lt_cctab-ccmng TO it_list-ccmng.
      ENDIF.
      MOVE  lt_cctab-docst TO it_list-docstc.

      CASE it_list-docstc.
        WHEN 'O'.
          it_list-ccicn = icon_led_green.
        WHEN OTHERS.
          it_list-ccicn = icon_led_yellow.
      ENDCASE.
    ELSE.
      DATA : BEGIN OF ls_ztitcrp,
               iccno LIKE ztitcrp-iccno,
             END OF ls_ztitcrp.
      SELECT SINGLE  iccno INTO CORRESPONDING FIELDS OF ls_ztitcrp
         FROM   ztitcrp AS a
        WHERE a~ebeln EQ it_list-ebeln
          AND a~ebelp EQ it_list-ebelp
          AND a~iblno EQ it_list-iblno
          AND a~iblit EQ it_list-iblit.
      IF sy-subrc = 0.
        it_list-iccno = ls_ztitcrp-iccno.
        it_list-ccicn = icon_led_yellow.
      ELSE.
        it_list-ccicn = icon_led_red.
      ENDIF.
    ENDIF.

*.G/R
    SELECT SINGLE a~igrno a~budat AS budat_gr b~grmng
                  INTO CORRESPONDING FIELDS OF it_list
                  FROM ztitgrk AS a
                  JOIN ztitgrp AS b
                    ON a~igrno = b~igrno
                 WHERE b~ebeln EQ it_list-ebeln
                   AND b~ebelp EQ it_list-ebelp
                   AND b~iblno EQ it_list-iblno
                   AND b~iblit EQ it_list-iblit.
    IF sy-subrc = 0.
      it_list-gricn = icon_led_green.
    ELSE.  "> 실패시 BL ITEM 제외후 재검색 2008.06.26
      SELECT SINGLE a~igrno a~budat AS budat_gr b~grmng
                    INTO CORRESPONDING FIELDS OF it_list
                    FROM ztitgrk AS a
                    JOIN ztitgrp AS b
                      ON a~igrno = b~igrno
                   WHERE b~ebeln EQ it_list-ebeln
                     AND b~ebelp EQ it_list-ebelp
                     AND b~iblno EQ it_list-iblno.
*                     AND b~iblit EQ it_list-iblit.
      IF sy-subrc = 0.
        it_list-gricn = icon_led_green.
      ELSE.
        it_list-gricn = icon_led_red.
      ENDIF.
    ENDIF.

*.I/V
    IF it_list-anbty EQ 'A'.  ">사후
      SELECT SINGLE a~ivono b~rblgp a~ivnum a~budat
                    a~bldat a~netdt AS netdt_iv
                    a~belnr a~gjahr AS ajahr a~livst
                    b~refwr b~ivmng a~gjahr a~bukrs
                    INTO CORRESPONDING FIELDS OF it_list
                    FROM ztitivk AS a
                    JOIN ztitivp AS b
                      ON a~ivono = b~ivono
              WHERE b~ebeln EQ it_list-ebeln
                AND b~ebelp EQ it_list-ebelp
*                AND b~reqno EQ it_list-reqno
*                AND b~reqit EQ it_list-reqit
                AND b~iblno EQ it_list-iblno
                AND b~iblit EQ it_list-iblit.
    ELSE.
      SELECT SINGLE a~ivono b~rblgp a~ivnum a~budat
                    a~bldat a~netdt AS netdt_iv
                    a~belnr a~gjahr AS ajahr a~livst
                    b~refwr b~ivmng a~gjahr a~bukrs
                    INTO CORRESPONDING FIELDS OF it_list
                    FROM ztitivk AS a
                    JOIN ztitivp AS b
                      ON a~ivono = b~ivono
              WHERE b~ebeln EQ it_list-ebeln
                AND b~ebelp EQ it_list-ebelp
                AND b~reqno EQ it_list-reqno
                AND b~reqit EQ it_list-reqit
                AND b~iblno EQ it_list-iblno
                AND b~iblit EQ it_list-iblit.
    ENDIF.
    IF sy-subrc <> 0.
      IF it_list-reqtyl = 'TT'.
        IF it_list-anbty EQ 'A'.  ">사후
          SELECT SINGLE a~ivono a~ivnum a~budat
                        a~bldat a~netdt AS netdt_iv
                        a~belnr a~gjahr AS ajahr a~livst
                        b~refwr b~ivmng a~gjahr a~bukrs
                        INTO CORRESPONDING FIELDS OF it_list
                        FROM ztitivk AS a
                        JOIN ztitivp AS b
                          ON a~ivono = b~ivono
                  WHERE b~ebeln EQ it_list-ebeln
                    AND b~ebelp EQ it_list-ebelp
                    AND b~iblno EQ it_list-iblno
                    AND b~iblit EQ it_list-iblit.

        ELSE.
          SELECT SINGLE a~ivono a~ivnum a~budat
                        a~bldat a~netdt AS netdt_iv
                        a~belnr a~gjahr AS ajahr a~livst
                        b~refwr b~ivmng a~gjahr a~bukrs
                        INTO CORRESPONDING FIELDS OF it_list
                        FROM ztitivk AS a
                        JOIN ztitivp AS b
                          ON a~ivono = b~ivono
                  WHERE b~ebeln EQ it_list-ebeln
                    AND b~ebelp EQ it_list-ebelp
                    AND b~reqno EQ it_list-reqno
                    AND b~reqit EQ it_list-reqit.
        ENDIF.
      ENDIF.
    ENDIF.
    IF sy-subrc = 0.
      it_list-ivicn = icon_led_green.
*...전표
      DATA : l_awkey LIKE bkpf-awkey,
             l_awtyp LIKE bkpf-awtyp,
             l_belnr LIKE bkpf-belnr,
             l_gjahr LIKE bkpf-gjahr.

*      CONCATENATE it_list-ivnum it_list-gjahr INTO l_awkey.
      CONCATENATE it_list-belnr it_list-gjahr INTO l_awkey.

      l_awtyp       = 'RMRP '.
      CLEAR : l_belnr, l_gjahr.

      SELECT SINGLE belnr gjahr
        INTO (l_belnr, l_gjahr)
        FROM bkpf
       WHERE awtyp  EQ  l_awtyp
         AND awkey  EQ  l_awkey.

      it_list-belnr1 =  l_belnr.

      CASE  it_list-livst.
        WHEN 'N'.
          it_list-ivicn = icon_led_yellow.
        WHEN OTHERS.
          it_list-ivicn = icon_led_green.
      ENDCASE.
    ELSE.
      it_list-ivicn = icon_led_red.
    ENDIF.


*...TEXT
    PERFORM vendor_name USING: it_list-lifnr
                               it_list-name1.

    PERFORM material_name USING: it_list-matnr
                                 it_list-maktx.
*

    MODIFY it_list.
    CLEAR it_list.
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
  DATA: groups   TYPE slis_sp_group_alv OCCURS 0 WITH HEADER LINE.

  SET TITLEBAR 'T1000'.
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
  gs_layout-box_fieldname     = 'BOX'.

*>color field define.
*  gs_layout-coltab_fieldname  = 'COLOR'.
*  gs_layout-group_change_edit = 'X'.
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
  events-name = slis_ev_top_of_page.
  events-form = 'TOP_OF_PAGE'.
  APPEND events.

  events-name = slis_ev_subtotal_text.
  events-form = slis_ev_subtotal_text.
  APPEND events.

  events-name = slis_ev_pf_status_set.
  events-form = 'SET_ALV_STATUS'.
  APPEND events.

*> ALV reuse function call..
  CALL FUNCTION alv_detail_func
    EXPORTING
      i_callback_program      = alv_repid
*     i_callback_pf_status_set = 'SET_ALV_STATUS'
      i_callback_user_command = 'USER_ALV_COMMAND'
*     I_STRUCTURE_NAME        =
*     IT_EXCLUDING            =
*     IT_SPECIAL_GROUPS       =
*     IT_FILTER               =
*     IS_SEL_HIDE             =
*     I_DEFAULT               = 'X'
*     I_SAVE                  = ' '
*     IS_VARIANT              =
      it_events               = events[]
      it_event_exit           = exit[]
*     IS_PRINT                =
*     IS_REPREP_ID            =
*     I_SCREEN_START_COLUMN   = 0
*     I_SCREEN_START_LINE     = 0
*     I_SCREEN_END_COLUMN     = 0
*     I_SCREEN_END_LINE       = 0
      it_fieldcat             = fc_detail[]
      it_sort                 = it_sort
*     I_DEFAULT               = 'X'
*     IS_VARIANT              = VARIANT_DETAIL
      is_variant              = alv_variant
      i_save                  = c_save
      is_layout               = gs_layout
      is_print                = alv_print
*   IMPORTING
*     E_EXIT_CAUSED_BY_CALLER =
*     ES_EXIT_CAUSED_BY_USER  =
    TABLES
      t_outtab                = it_list[].

ENDFORM.                    " display_alv_list
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

  PERFORM 3010_fill_field_category USING :

       'S' 'TABNAME'     'IT_LIST',     "BOX
       ' ' 'FIELDNAME'   'BOX',
       ' ' 'NO_OUT'      'X',
       'E' 'OUTPUTLEN'   '1',

       'S' 'REF_TABNAME'  'EKKO',       "구매번호
       ' ' 'TABNAME'      'IT_LIST',
       ' ' 'FIELDNAME'    'EBELN',
       ' ' 'HOTSPOT'      'X',
       ' ' 'KEY'          'X',
       'E' 'OUTPUTLEN'    '10',

       'S' 'REF_TABNAME'  'EKPO',       "구매번호
       ' ' 'TABNAME'      'IT_LIST',
       ' ' 'FIELDNAME'    'EBELP',
       ' ' 'HOTSPOT'      'X',
       ' ' 'KEY'          'X',
       'E' 'OUTPUTLEN'    '4',

* 상태
       'S' 'TABNAME'     'IT_LIST',      "L/C아이콘
       ' ' 'SELTEXT_S'   'L/C',
       ' ' 'SELTEXT_M'   'L/C',
       ' ' 'FIELDNAME'   'LCICN',
       ' ' 'KEY'          'X',
       ' ' 'ICON'         'X',
       'E' 'OUTPUTLEN'    '4',

       'S' 'TABNAME'     'IT_LIST',      "B/L아이콘
       ' ' 'SELTEXT_S'   'B/L',
       ' ' 'SELTEXT_M'   'B/L',
       ' ' 'FIELDNAME'   'BLICN',
       ' ' 'KEY'         'X',
       ' ' 'ICON'        'X',
       'E' 'OUTPUTLEN'   '4',

       'S' 'TABNAME'     'IT_LIST',      "부보 아이콘 - 기능개선 278454
       ' ' 'SELTEXT_S'   'I/P',
       ' ' 'SELTEXT_M'   'I/P',
       ' ' 'FIELDNAME'   'IPICN',
       ' ' 'KEY'          'X',
       ' ' 'ICON'         'X',
       'E' 'OUTPUTLEN'    '4',

       'S' 'TABNAME'     'IT_LIST',      "C/C아이콘
       ' ' 'SELTEXT_S'   'C/C',
       ' ' 'SELTEXT_M'   'C/C',
       ' ' 'FIELDNAME'   'CCICN',
       ' ' 'KEY'         'X',
       ' ' 'ICON'        'X',
       'E' 'OUTPUTLEN'   '4',

       'S' 'TABNAME'     'IT_LIST',      "G/R아이콘
       ' ' 'SELTEXT_S'   'G/R',
       ' ' 'SELTEXT_M'   'G/R',
       ' ' 'FIELDNAME'   'GRICN',
       ' ' 'KEY'         'X',
       ' ' 'ICON'        'X',
       'E' 'OUTPUTLEN'   '4',

* P/O
       'S' 'REF_TABNAME'  'EKPO',      "자재번호
       ' ' 'TABNAME'      'IT_LIST',
       ' ' 'FIELDNAME'    'MATNR',
       ' ' 'EMPHASIZE'   'C100',
       ' ' 'HOTSPOT'      'X',
       'E' 'OUTPUTLEN'    '10',

*************************************************************
* CSR No. : C20091013_39827
* Display 추가 : 자재명, 공급업체 정보
*************************************************************

       'S' 'REF_TABNAME'  'MARA',       "자재명
       ' ' 'TABNAME'      'IT_LIST',
       ' ' 'SELTEXT_S'    '자재명',
       ' ' 'SELTEXT_M'    '자재명',
       ' ' 'FIELDNAME'    'MAKTX',
       'E' 'OUTPUTLEN'    '30',

       'S' 'REF_TABNAME'  'LFA1',       "업체코드
       ' ' 'TABNAME'      'IT_LIST',
       ' ' 'FIELDNAME'    'LIFNR',
       'E' 'OUTPUTLEN'    '10',

       'S' 'REF_TABNAME'  'LFA1',       "업체명
       ' ' 'TABNAME'      'IT_LIST',
       ' ' 'FIELDNAME'    'NAME1',
       'E' 'OUTPUTLEN'    '30',
*************************************************************

*       'S' 'REF_TABNAME'  'MAKT',      "자재명
*       ' ' 'TABNAME'      'IT_LIST',
*       ' ' 'FIELDNAME'    'MAKTX',
*       ' ' 'EMPHASIZE'   'C100',
*       'E' 'OUTPUTLEN'    '30',

       'S' 'REF_TABNAME'  'EKPO',      "P/O 수량
       ' ' 'TABNAME'      'IT_LIST',
       ' ' 'FIELDNAME'    'MENGE',
       ' ' 'QFIELDNAME'   'MEINS',
       ' ' 'QTABNAME'     'IT_LIST',
       ' ' 'EMPHASIZE'   'C100',
       'E' 'OUTPUTLEN'    '15',

       'S' 'REF_TABNAME'  'EKPO',      "P/O 수량 단위
       ' ' 'TABNAME'      'IT_LIST',
       ' ' 'FIELDNAME'    'MEINS',
       ' ' 'EMPHASIZE'   'C100',
       'E' 'OUTPUTLEN'    '3',

       'S' 'REF_TABNAME'  'EKKO',      "일자
       ' ' 'TABNAME'      'IT_LIST',
       ' ' 'FIELDNAME'    'BEDAT',
       ' ' 'EMPHASIZE'    'C100',
       'E' 'OUTPUTLEN'    '10',

*. L/C
       'S' 'REF_TABNAME'  'ZTITRQK',      "수입의뢰관리번호
       ' ' 'TABNAME'      'IT_LIST',
       ' ' 'FIELDNAME'    'REQNO',
       ' ' 'HOTSPOT'      'X',
       ' ' 'EMPHASIZE'    'C200',
       'E' 'OUTPUTLEN'    '10',

       'S' 'REF_TABNAME'  'ZTITRQP',      "Amend 차수
       ' ' 'TABNAME'      'IT_LIST',
       ' ' 'FIELDNAME'    'AMDSQ',
*       ' ' 'HOTSPOT'      'X',
       ' ' 'EMPHASIZE'    'C200',
*       ' ' 'NO_OUT'       'X',
       'E' 'OUTPUTLEN'    '2',

       'S' 'REF_TABNAME'  'ZTITRQP',      "수량
       ' ' 'TABNAME'      'IT_LIST',
       ' ' 'FIELDNAME'    'RQMNG',
       ' ' 'QFIELDNAME'   'MEINS',
       ' ' 'QTABNAME'     'IT_LIST',
       ' ' 'EMPHASIZE'    'C200',
       'E' 'OUTPUTLEN'    '15',

       'S' 'REF_TABNAME'  'ZTITRQS',      "수입개설일자
       ' ' 'TABNAME'      'IT_LIST',
       ' ' 'FIELDNAME'    'OPNDT',
       ' ' 'EMPHASIZE'    'C200',
       'E' 'OUTPUTLEN'    '10',

* B/L
       'S' 'REF_TABNAME'  'ZTITBLK',      "B/L관리번호
       ' ' 'TABNAME'      'IT_LIST',
       ' ' 'FIELDNAME'    'IBLNO',
       ' ' 'HOTSPOT'      'X',
       ' ' 'EMPHASIZE'   'C300',
       'E' 'OUTPUTLEN'    '10',


       'S' 'REF_TABNAME'  'ZTITBLP',      "B/L수량
       ' ' 'TABNAME'      'IT_LIST',
       ' ' 'FIELDNAME'    'BLMNG',
       ' ' 'QFIELDNAME'   'MEINS',
       ' ' 'QTABNAME'     'IT_LIST',
       ' ' 'EMPHASIZE'    'C300',
       'E' 'OUTPUTLEN'    '15',

       'S' 'REF_TABNAME'  'ZTITBLK',      "ETD
       ' ' 'TABNAME'      'IT_LIST',
       ' ' 'FIELDNAME'    'BLETD',
       ' ' 'EMPHASIZE'   'C300',
       'E' 'OUTPUTLEN'    '10',

       'S' 'REF_TABNAME'  'ZTITBLK',      "ETA
       ' ' 'TABNAME'      'IT_LIST',
       ' ' 'FIELDNAME'    'BLETA',
       ' ' 'EMPHASIZE'   'C300',
       'E' 'OUTPUTLEN'    '10',

* I/P - 기능개선 278454 추가
       'S' 'REF_TABNAME'  'ZTITIP1',      "I/P 관리번호
       ' ' 'TABNAME'      'IT_LIST',
       ' ' 'FIELDNAME'    'IIPNO',
       ' ' 'HOTSPOT'      'X',
       ' ' 'EMPHASIZE'   'C700',
       'E' 'OUTPUTLEN'    '10',


       'S' 'REF_TABNAME'  'ZTITIP1',      "보험증권번호
       ' ' 'TABNAME'      'IT_LIST',
       ' ' 'FIELDNAME'    'ISPNO',
       ' ' 'EMPHASIZE'    'C700',
       'E' 'OUTPUTLEN'    '15',

       'S' 'REF_TABNAME'  'ZTITIP1',      "보험 개시일
       ' ' 'TABNAME'      'IT_LIST',
       ' ' 'FIELDNAME'    'IOPDT',
       ' ' 'EMPHASIZE'    'C700',
       'E' 'OUTPUTLEN'    '10',

*. C/C
       'S' 'REF_TABNAME'  'ZTITCCK',      "통관관리번호
       ' ' 'TABNAME'      'IT_LIST',
       ' ' 'FIELDNAME'    'ICCNO',
       ' ' 'HOTSPOT'      'X',
       ' ' 'EMPHASIZE'   'C500',
       'E' 'OUTPUTLEN'    '10',

       'S' 'REF_TABNAME'  'ZTITCCP',      "통관수량
       ' ' 'TABNAME'      'IT_LIST',
       ' ' 'FIELDNAME'    'CCMNG',
       ' ' 'QFIELDNAME'   'MEINS',
       ' ' 'QTABNAME'     'IT_LIST',
       ' ' 'EMPHASIZE'   'C500',
       'E' 'OUTPUTLEN'    '15',

       'S' 'REF_TABNAME'  'ZTITCCK',      "수리일자
       ' ' 'TABNAME'      'IT_LIST',
       ' ' 'FIELDNAME'    'CDRDT',
       ' ' 'EMPHASIZE'   'C500',
       'E' 'OUTPUTLEN'    '10',

* G/R
       'S' 'REF_TABNAME'  'ZTITGRK',      "입고관리번호
       ' ' 'TABNAME'      'IT_LIST',
       ' ' 'FIELDNAME'    'IGRNO',
       ' ' 'HOTSPOT'      'X',
       ' ' 'EMPHASIZE'   'C600',
       'E' 'OUTPUTLEN'    '10',

       'S' 'REF_TABNAME'  'ZTITGRP',      "입고수량
       ' ' 'TABNAME'      'IT_LIST',
       ' ' 'FIELDNAME'    'GRMNG',
       ' ' 'QFIELDNAME'   'MEINS',
       ' ' 'QTABNAME'     'IT_LIST',
       ' ' 'EMPHASIZE'   'C600',
       'E' 'OUTPUTLEN'    '15',

       'S' 'REF_TABNAME'  'ZTITGRK',      "전기일
       ' ' 'REF_FIELDNAME' 'BUDAT',
       ' ' 'TABNAME'      'IT_LIST',
       ' ' 'FIELDNAME'    'BUDAT_GR',
       ' ' 'EMPHASIZE'   'C600',
       'E' 'OUTPUTLEN'    '10'.




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

  CLEAR  st_sort.
  st_sort-spos      = '01'.
  st_sort-fieldname = 'EBELN'.
  st_sort-tabname   = 'IT_LIST'.
*  st_sort-up        = 'X'.
  st_sort-down      = 'X'.
  st_sort-group     = 'X'.
  st_sort-subtot    = 'X'.
*      ST_SORT-EXPA      = 'X'.
  APPEND st_sort TO it_sort.

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
  DATA: l_header(20) TYPE c.



  REFRESH header.
  header-typ = 'H'.
  header-info = '진행리스트'.

  CONCATENATE l_header header-info INTO header-info
                                     SEPARATED BY space.

  CLEAR: header-key.
  APPEND header.

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
*  SELECT SINGLE *
*    FROM t001
*   WHERE bukrs IN s_bukrs.
*  IF sy-subrc <> 0.
*    PERFORM get_ftext(rddfie00) USING 'T001' 'BUKRS' sy-langu
*                                CHANGING dfies g_subrc.
*    SET CURSOR FIELD 'S_BUKRS'.
*    MESSAGE e348(m7) WITH dfies-scrtext_m.
*  ENDIF.

ENDFORM.                    " input_field_check
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


  CASE r_ucomm.
    WHEN 'REFRESH'.
      PERFORM get_data_for_display.    ">data select
      rs_selfield-refresh = 'X'.
    WHEN 'DISPLAY' OR '&IC1'.    " AUF DOPPELKLICK REAGIERIEN
      READ TABLE it_list INDEX rs_selfield-tabindex.
      CHECK : rs_selfield-tabindex GT 0 AND
              rs_selfield-tabindex LT 99999999999.

      IF sy-subrc NE 0.
        MESSAGE s906.            EXIT.
      ENDIF.
      CASE rs_selfield-fieldname.
        WHEN 'EBELN' OR 'EBELP'.
          PERFORM display_purchase_order  USING it_list-ebeln
                                                it_list-ebelp.

        WHEN 'REQNO'.
          PERFORM display_import_document USING it_list-reqno
                                                it_list-amdsq
                                                space.
        WHEN 'IBLNO'.
          PERFORM display_bl_document     USING it_list-iblno
                                                space.

        WHEN 'IIPNO'.
          PERFORM display_ip_document     USING it_list-iipno
                                                space.

        WHEN 'ICCNO'.
          PERFORM display_cc_document     USING it_list-iccno
                                                space.

        WHEN 'IGRNO'.
          PERFORM display_gr_document     USING it_list-igrno.

        WHEN 'IVONO'.
          PERFORM display_civ_document    USING it_list-ivono.

        WHEN 'PNTNO'.
          PERFORM display_pn_document    USING it_list-pntno.

        WHEN 'MATNR'.
          PERFORM display_material_master    USING it_list-matnr
                                                   it_list-werks
                                                   space.

        WHEN 'LIFNR'.
          PERFORM display_vendor_master    USING it_list-lifnr
                                                 space.
        WHEN 'BELNR'.
          PERFORM display_liv_document    USING it_list-belnr
                                                it_list-ajahr
                                                s_bukrs-low.
        WHEN 'BELNR1'.
          PERFORM display_fi_document(ztir0000)
                                          USING it_list-belnr1
                                                it_list-ajahr
                                                s_bukrs-low.
        WHEN 'BELNR_CLR'.
          PERFORM display_fi_document(ztir0000)
                                          USING it_list-belnr_clr
                                                it_list-gjahr_clr
                                                s_bukrs-low.

        WHEN 'AUGBL'.
          PERFORM display_fi_document(ztir0000)
                                          USING it_list-augbl
                                                it_list-augdt
                                                s_bukrs-low.

        WHEN 'IBINO'.
          PERFORM display_bi_document     USING it_list-ibino.

        WHEN 'IBONO'.
          PERFORM display_bo_document     USING it_list-ibono.


      ENDCASE.

*...Create
    WHEN 'ZTICREATE'.  "CREATE
  ENDCASE.
  CLEAR: r_ucomm.

ENDFORM.                    " USER_ALV_COMMAND
*&---------------------------------------------------------------------*
*&      Form  VENDOR_NAME
*&---------------------------------------------------------------------*
FORM vendor_name  USING    p_lifnr
                           p_name1.

  SELECT SINGLE name1 INTO p_name1
                      FROM lfa1
                     WHERE lifnr EQ p_lifnr.

ENDFORM.                    " VENDOR_NAME
*&---------------------------------------------------------------------*
*&      Form  display_import_document
*&---------------------------------------------------------------------*
FORM display_import_document  USING    p_reqno
                                       p_amdsq
                                       p_reqit.
  CHECK NOT p_reqno IS INITIAL.

  SET PARAMETER ID 'ZTIREQNO' FIELD p_reqno.
  SET PARAMETER ID 'ZTIAMDSQ' FIELD p_amdsq.
  SET PARAMETER ID 'ZTIREQIT' FIELD p_reqit.
  SET PARAMETER ID 'BES'      FIELD space.
  SET PARAMETER ID 'ZTIOPNNO' FIELD space.

  CALL TRANSACTION 'ZTIT003' AND SKIP FIRST SCREEN..

ENDFORM.                    " display_import_document
*&---------------------------------------------------------------------*
*&      Form  display_bl_document
*&---------------------------------------------------------------------*
FORM display_bl_document      USING    p_iblno
                                       p_iblit.
  CHECK NOT p_iblno IS INITIAL.

  SET PARAMETER ID 'ZTIIBLNO' FIELD p_iblno.
  SET PARAMETER ID 'ZTIIBLIT' FIELD p_iblit.
  SET PARAMETER ID 'ZTIBLNUM' FIELD space.

  CALL TRANSACTION 'ZTIT203' AND SKIP FIRST SCREEN.

ENDFORM.                    " display_import_document
*&---------------------------------------------------------------------*
*&      Form  display_IP_document
*&---------------------------------------------------------------------*
*       A cargo insurance document is display
*----------------------------------------------------------------------*
FORM display_ip_document  USING        p_iipno
                                       p_amdsq.

  CHECK NOT p_iipno IS INITIAL.

  SET PARAMETER ID 'ZTIIIPNO' FIELD p_iipno.
  SET PARAMETER ID 'ZTIAMSEQ' FIELD p_amdsq.
*   SET PARAMETER ID 'BES'      FIELD space.
*   SET PARAMETER ID 'ZTIOPNNO' FIELD space.
*
  CALL TRANSACTION 'ZTIT103' AND SKIP FIRST SCREEN.

ENDFORM.                    " display_ip_document
*&---------------------------------------------------------------------*
*&      Form  display_CC_document
*&---------------------------------------------------------------------*

FORM display_cc_document      USING    p_iccno
                                       p_iccsq.

  CHECK NOT p_iccno IS INITIAL.

  SET PARAMETER ID 'ZTIICCNO' FIELD p_iccno.
  SET PARAMETER ID 'ZTIICCSQ' FIELD p_iccsq.
  SET PARAMETER ID 'ZTIIBLNO' FIELD space.
  SET PARAMETER ID 'ZTIBLNUM' FIELD space.
  SET PARAMETER ID 'BES'      FIELD space.

  CALL TRANSACTION 'ZTIT403' AND SKIP FIRST SCREEN.

ENDFORM.                    " display_cc_document
*&---------------------------------------------------------------------*
*&      Form  display_GR_document
*&---------------------------------------------------------------------*
FORM display_gr_document      USING    p_igrno.

  CHECK NOT p_igrno IS INITIAL.

  SET PARAMETER ID 'ZTIIGRNO' FIELD p_igrno.
  SET PARAMETER ID 'ZTIICCNO' FIELD space.
  SET PARAMETER ID 'ZTIIBLNO' FIELD space.
  SET PARAMETER ID 'ZTIBLNUM' FIELD space.
  SET PARAMETER ID 'ZTIREQNO' FIELD space.
  SET PARAMETER ID 'ZTIAMDSQ' FIELD space.
  SET PARAMETER ID 'BES'      FIELD space.

  CALL TRANSACTION 'ZTIT503' AND SKIP FIRST SCREEN.

ENDFORM.                    " display_gr_document
*&---------------------------------------------------------------------*
*&      Form  display_CIV_document
*&---------------------------------------------------------------------*
FORM display_civ_document      USING    p_ivono.

  CHECK NOT p_ivono IS INITIAL.

  SET PARAMETER ID 'ZTIIVONO' FIELD p_ivono.
  SET PARAMETER ID 'ZTIIBLNO' FIELD space.
  SET PARAMETER ID 'ZTIBLNUM' FIELD space.
  SET PARAMETER ID 'ZTIOPNNO' FIELD space.
  SET PARAMETER ID 'ZTIREQNO' FIELD space.
  SET PARAMETER ID 'BES'      FIELD space.

  CALL TRANSACTION 'ZTIT303' AND SKIP FIRST SCREEN.

ENDFORM.                    " display_civ_document
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  display_PN_document
*&---------------------------------------------------------------------*
FORM display_pn_document      USING    p_pntno.

  CHECK NOT p_pntno IS INITIAL.

  SET PARAMETER ID 'ZTIPNTNO' FIELD p_pntno.
  SET PARAMETER ID 'ZTIICCNO' FIELD space.
  SET PARAMETER ID 'ZTIIBLNO' FIELD space.
  SET PARAMETER ID 'ZTIBLNUM' FIELD space.
  SET PARAMETER ID 'ZTIREQNO' FIELD space.
  SET PARAMETER ID 'ZTIAMDSQ' FIELD space.
  SET PARAMETER ID 'BES'      FIELD space.

  CALL TRANSACTION 'ZTIT803' AND SKIP FIRST SCREEN.

ENDFORM.                    " display_pn_document
*&---------------------------------------------------------------------*
*&      Form  display_purchase_order
*&---------------------------------------------------------------------*
FORM display_purchase_order  USING    p_ebeln  LIKE ekpo-ebeln
                                      p_ebelp  LIKE ekpo-ebelp.

  CHECK NOT p_ebeln IS INITIAL.
*   IF sy-binpt IS INITIAL.
*     SET PARAMETER ID 'ENJ_CALL_ME23N' FIELD c_true.
*   ELSE.
*     SET PARAMETER ID 'ENJ_CALL_ME23N' FIELD c_false.
*   ENDIF.
*   CLEAR: sy-binpt .

  CALL FUNCTION 'ME_DISPLAY_PURCHASE_DOCUMENT'
    EXPORTING
      i_ebeln              = p_ebeln
      i_ebelp              = p_ebelp
      i_enjoy              = 'X'
*     i_enjoy              = c_true
*     I_PREVIEW            =
*     I_DATA_FROM_BUFFER   =
*     I_BSTYP              =
*     I_DISPLAY_ONLY       = ' '
*     I_EDIT               = ' '
*     I_ETENR              =
*     I_DOC_INITIATOR      =
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

ENDFORM.                    " display_purchase_order
*&---------------------------------------------------------------------*
*&      Form  MATERIAL_name
*&---------------------------------------------------------------------*
FORM material_name  USING    p_matnr
                             p_maktx.

  SELECT SINGLE maktx INTO p_maktx
                      FROM makt
                     WHERE matnr EQ p_matnr
                       AND spras EQ sy-langu.

ENDFORM.                    " MATERIAL_name
*&---------------------------------------------------------------------*
*&      Form  display_material_master
*&---------------------------------------------------------------------*
FORM display_material_master  USING    p_matnr
                                       p_werks
                                       p_lgort.

  CHECK NOT p_matnr IS INITIAL.

  CALL FUNCTION 'MMPUR_MATERIAL_DISPLAY'
    EXPORTING
      im_matnr = p_matnr
      im_werks = p_werks
      im_lgort = p_lgort.


ENDFORM.                    " DISPLAY_MATERIAL_MASTER
*&---------------------------------------------------------------------*
*&      Form  display_VENDOR_master
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_IT_LIST_LFINR  text
*----------------------------------------------------------------------*
FORM display_vendor_master  USING    p_lifnr
                                     p_ekorg.
*------- Direktwerte GPA/SPA-------------------------------------------*
  DATA: kdy_val(8) VALUE '/110'.

  CHECK NOT p_lifnr IS INITIAL.

  IF p_ekorg IS INITIAL.
    SET PARAMETER ID 'LIF' FIELD p_lifnr.
    SET PARAMETER ID 'EKO' FIELD space.
    SET PARAMETER ID 'KDY' FIELD kdy_val.
    CALL TRANSACTION 'MK03' AND SKIP FIRST SCREEN.
  ELSE.
    CALL FUNCTION 'MMPUR_VENDOR_DISPLAY'
      EXPORTING
        im_lifnr = p_lifnr
        im_ekorg = p_ekorg.
  ENDIF.

ENDFORM.                    " display_vendor_master
*&---------------------------------------------------------------------*
*&      Form  display_liv_document
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM display_liv_document  USING    p_belnr
                                    p_gjahr
                                    p_bukrs.

  CHECK NOT p_belnr IS INITIAL.
  SELECT SINGLE *
    FROM rbkp
   WHERE belnr = p_belnr
     AND gjahr = p_gjahr.
  IF sy-subrc EQ 0.
    SET PARAMETER ID 'RBN' FIELD p_belnr.
    SET PARAMETER ID 'GJR' FIELD p_gjahr.
    CALL TRANSACTION 'MIR4' AND SKIP FIRST SCREEN.
  ELSE.
    CALL FUNCTION 'FI_DOCUMENT_LIST_DISPLAY'
      EXPORTING
        bukrs                = p_bukrs
        belnr                = p_belnr
        gjahr                = p_gjahr
*       AKTYP                = 'A'
*       XEPOS                =
*       I_NOCHANGE           =
*       XPRNT                =
*    IMPORTING
*       E_CMRQ               =
*       E_CHNG               =
      EXCEPTIONS
        display_not_possible = 1
        no_authority         = 2
        OTHERS               = 3.

    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.
  ENDIF.

ENDFORM.                    " display_LIV_DOCUMENT
*&---------------------------------------------------------------------*
*&      Form  display_bi_document
*&---------------------------------------------------------------------*
FORM display_bi_document  USING    p_ibino.

  CHECK NOT p_ibino IS INITIAL.
  SET PARAMETER ID 'ZTIIBINO' FIELD p_ibino.
  CALL TRANSACTION 'ZTIT463' AND SKIP FIRST SCREEN.


ENDFORM.                    " display_bi_document
*&---------------------------------------------------------------------*
*&      Form  display_bo_document
*&---------------------------------------------------------------------*
FORM display_bo_document  USING    p_ibono.
  CHECK NOT p_ibono IS INITIAL.
  SET PARAMETER ID 'ZTIIBONO' FIELD p_ibono.
  CALL TRANSACTION 'ZTIT473' AND SKIP FIRST SCREEN.
ENDFORM.                    " display_bo_document
