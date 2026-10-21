*&---------------------------------------------------------------------*
*& INCLUDE          ZGTMMR3000TOP
*&---------------------------------------------------------------------*
*----------------------------------------------------------------------*
* TYPE POOLS
*----------------------------------------------------------------------*

*----------------------------------------------------------------------*
*  TABLES
*----------------------------------------------------------------------*
TABLES :
  marc, ekko, vbak,
  sscrfields.

*----------------------------------------------------------------------*
* TYPES
*----------------------------------------------------------------------*
*=> GTY + _ + XXXXX.XXX
*----------------------------------------------------------------------*
TYPES:
  BEGIN OF ty_opt1_xls,
    lifnr      TYPE string,
*    BUKRS      TYPE STRING,
*    EKORG      TYPE STRING,
*    EKGRP      TYPE STRING,
    matnr      TYPE string,
    zzmaktx80  TYPE string,
*    WERKS      TYPE STRING,
    lgort      TYPE string,
    emlif      TYPE string,
    menge      TYPE string,
    meins      TYPE string,
    length     TYPE string,
    drqty      TYPE string,
    netpr      TYPE string,
    peinh      TYPE string,
    waers      TYPE string,
    mwskz      TYPE string,
    eindt      TYPE string,
    insmk      TYPE string,
    zmemo      TYPE string,
    uebto      TYPE string,
    retpo      TYPE string,
    zfree      TYPE string,
    knttp      TYPE string,
    matkl      TYPE string,
    pstyp      TYPE string,
    vbeln      TYPE string,
    vbelp      TYPE string,
    kostl      TYPE string,
    sakto      TYPE string,
    anln1      TYPE string,
    anln2      TYPE string,
    ps_psp_pnr TYPE string,
    aufnr      TYPE string,
  END OF ty_opt1_xls,
  ty_t_opt1_xls TYPE STANDARD TABLE OF ty_opt1_xls.

TYPES:
  BEGIN OF ty_fname,
    fname TYPE lvc_fname,
  END OF ty_fname,
  ty_t_fname TYPE SORTED TABLE OF ty_fname WITH UNIQUE KEY fname.

TYPES:
  BEGIN OF ty_t163i,
    knttp TYPE t163i-knttp,
    knttx TYPE t163i-knttx,
  END OF ty_t163i,
  BEGIN OF ty_t163y,
    pstyp TYPE t163y-pstyp,
    ptext TYPE t163y-ptext,
  END OF ty_t163y,
  BEGIN OF ty_t023t,
    matkl TYPE t023t-matkl,
    wgbez TYPE t023t-wgbez,
  END OF ty_t023t,
  BEGIN OF ty_t001,
    bukrs TYPE t001-bukrs,
    butxt TYPE t001-butxt,
  END OF ty_t001,
  BEGIN OF ty_t001w,
    werks TYPE t001w-werks,
    name1 TYPE t001w-name1,
  END OF ty_t001w,
  BEGIN OF ty_t001l,
    werks TYPE t001l-werks,
    lgort TYPE t001l-lgort,
    lgobe TYPE t001l-lgobe,
  END OF ty_t001l,
  BEGIN OF ty_t024e,
    ekorg TYPE t024e-ekorg,
    ekotx TYPE t024e-ekotx,
  END OF ty_t024e,
  BEGIN OF ty_t024,
    ekgrp TYPE t024-ekgrp,
    eknam TYPE t024-eknam,
  END OF ty_t024,
  BEGIN OF ty_char,
    ebeln  TYPE ekpo-ebeln,
    ebelp  TYPE ekpo-ebelp,
    length TYPE zelength,
    drqty  TYPE dec4,
    cuobj  TYPE ekpo-cuobj,
  END OF ty_char.

TYPES:
  BEGIN OF ty_conv_po,
    ekgrp        TYPE zgtmm_cv_get_reqpo_data-ekgrp,
    ekgrp_n      TYPE zgtmm_cv_get_reqpo_data-ekgrp_n,
    erdat        TYPE zgtmm_cv_get_reqpo_data-erdat,
    matnr        TYPE zgtmm_cv_get_reqpo_data-matnr,
    txz01        TYPE zgtmm_cv_get_reqpo_data-txz01,
    specno       TYPE zgtmm_cv_get_reqpo_data-specno,
    color        TYPE zgtmm_cv_get_reqpo_data-color,
    stripe_color TYPE zgtmm_cv_get_reqpo_data-stripe_color,
    stripe_no    TYPE zgtmm_cv_get_reqpo_data-stripe_no,
    lfdat        TYPE zgtmm_cv_get_reqpo_data-lfdat,
    ztype        TYPE zgtmm_cv_get_reqpo_data-ztype,
    ztype_n      TYPE zgtmm_cv_get_reqpo_data-ztype_n,
    banfn        TYPE zgtmm_cv_get_reqpo_data-banfn,
    bnfpo        TYPE zgtmm_cv_get_reqpo_data-bnfpo,
    menge        TYPE zgtmm_cv_get_reqpo_data-menge,
    menge_i      TYPE zgtmm_cv_get_reqpo_data-menge,
    meins        TYPE zgtmm_cv_get_reqpo_data-meins,
    length       TYPE zgtmm_cv_get_reqpo_data-length,
    drqty        TYPE zgtmm_cv_get_reqpo_data-drqty,
    insmk        TYPE ekpo-insmk,
    insmk_n      TYPE char20,
    slqty        TYPE zgtmm_cv_get_reqpo_data-slqty,
    matkl        TYPE zgtmm_cv_get_reqpo_data-matkl,
    matkl_n      TYPE zgtmm_cv_get_reqpo_data-matkl_n,
    bukrs        TYPE zgtmm_cv_get_reqpo_data-bukrs,
    kokrs        TYPE zgtmm_cv_get_reqpo_data-kokrs,
    ktopl        TYPE zgtmm_cv_get_reqpo_data-ktopl,
    ekorg        TYPE zgtmm_cv_get_reqpo_data-ekorg,
    ekorg_n      TYPE zgtmm_cv_get_reqpo_data-ekorg_n,
    werks        TYPE zgtmm_cv_get_reqpo_data-werks,
    werks_n      TYPE zgtmm_cv_get_reqpo_data-werks_n,
    lgort        TYPE zgtmm_cv_get_reqpo_data-lgort,
    lgort_n      TYPE zgtmm_cv_get_reqpo_data-lgort_n,
    emlif        TYPE zgtmm_cv_get_reqpo_data-emlif,
    scvname      TYPE zgtmm_cv_get_reqpo_data-scvname,
    lblkz        TYPE zgtmm_cv_get_reqpo_data-lblkz,
    ablad        TYPE zgtmm_cv_get_reqpo_data-ablad,
    afnam        TYPE zgtmm_cv_get_reqpo_data-afnam,
    flief        TYPE zgtmm_cv_get_reqpo_data-flief,
    flief_n      TYPE zgtmm_cv_get_reqpo_data-flief_n,
    lifnr        TYPE zgtmm_cv_get_reqpo_data-lifnr,
    lifnr_n      TYPE zgtmm_cv_get_reqpo_data-lifnr_n,
    preis_p      TYPE zgtmm_cv_get_reqpo_data-preis,
    waers_p      TYPE zgtmm_cv_get_reqpo_data-waers,
    peinh_p      TYPE zgtmm_cv_get_reqpo_data-peinh,
    mwskz_p      TYPE zgtmm_cv_get_infoprice-mwskz,
    preis_i      TYPE zgtmm_cv_get_reqpo_data-preis,
    waers_i      TYPE zgtmm_cv_get_reqpo_data-waers,
    peinh_i      TYPE zgtmm_cv_get_reqpo_data-peinh,
    mwskz_i      TYPE zgtmm_cv_get_infoprice-mwskz,
    preis        TYPE zgtmm_cv_get_reqpo_data-preis,
    waers        TYPE zgtmm_cv_get_reqpo_data-waers,
    peinh        TYPE zgtmm_cv_get_reqpo_data-peinh,
    idnlf        TYPE zgtmm_cv_get_infoprice-idnlf,
    gswrt        TYPE zgtmm_cv_get_reqpo_data-gswrt,
    sotax        TYPE zgtmm_cv_get_reqpo_data-sotax,
    mwskz        TYPE zgtmm_cv_get_infoprice-mwskz,
    zmemo_h      TYPE char200,
    zmemo_i      TYPE char200,
    ebakz        TYPE zgtmm_cv_get_reqpo_data-ebakz,
    loekz        TYPE zgtmm_cv_get_reqpo_data-loekz,
    knttp        TYPE zgtmm_cv_get_reqpo_data-knttp,
    knttp_n      TYPE zgtmm_cv_get_reqpo_data-knttp_n,
    pstyp        TYPE zgtmm_cv_get_reqpo_data-pstyp,
    pstyp_n      TYPE zgtmm_cv_get_reqpo_data-pstyp_n,
    rel          TYPE zgtmm_cv_get_reqpo_data-rel,
    sakto        TYPE zgtmm_cv_get_reqpo_data-sakto,
    sakto_n      TYPE zgtmm_cv_get_reqpo_data-sakto_n,
    kostl        TYPE zgtmm_cv_get_reqpo_data-kostl,
    kostl_n      TYPE zgtmm_cv_get_reqpo_data-kostl_n,
    vbeln        TYPE zgtmm_cv_get_reqpo_data-vbeln,
    posnr        TYPE zgtmm_cv_get_reqpo_data-posnr,
    kunnr        TYPE zgtmm_cv_get_reqpo_data-kunnr,
    kunnr_n      TYPE zgtmm_cv_get_reqpo_data-kunnr_n,
    vkbur        TYPE zgtmm_cv_get_reqpo_data-vkbur,
    vkbur_n      TYPE zgtmm_cv_get_reqpo_data-vkbur_n,
    vkgrp        TYPE zgtmm_cv_get_reqpo_data-vkgrp,
    vkgrp_n      TYPE zgtmm_cv_get_reqpo_data-vkgrp_n,
    anln1        TYPE zgtmm_cv_get_reqpo_data-anln1,
    anln2        TYPE zgtmm_cv_get_reqpo_data-anln2,
    anln1_n      TYPE zgtmm_cv_get_reqpo_data-anln1_n,
    ps_psp_pnr   TYPE zgtmm_cv_get_reqpo_data-ps_psp_pnr,
    ps_psp_pnr_n TYPE zgtmm_cv_get_reqpo_data-ps_psp_pnr_n,
    aufnr        TYPE zgtmm_cv_get_reqpo_data-aufnr,
    conqty       TYPE zgtmm_cv_get_infoprice_m-conqty,
    banfn_n      TYPE zgtmm_cv_get_reqpo_data-banfn,
    banfn_icon   TYPE icon-name,
    flag         TYPE zgtmm_cv_get_reqpo_data-flag,
    poprocess    TYPE zgtmm_cv_get_reqpo_data-poprocess,
    ebeln        TYPE zgtmm_cv_get_reqpo_data-ebeln,
    ebelp        TYPE zgtmm_cv_get_reqpo_data-ebelp,
    porelstatus  TYPE zgtmm_cv_get_reqpo_data-porelstatus,

    type         TYPE bapiret2-type,
    message      TYPE bapiret2-message,
    index        TYPE sy-index,
  END OF ty_conv_po,

  BEGIN OF ty_cre_po,
    ebeln        TYPE ekpo-ebeln,
    ebelp        TYPE ekpo-ebelp,
    lifnr        TYPE ekko-lifnr,
    lifnr_n      TYPE char35,
    bukrs        TYPE t001-bukrs,
    butxt        TYPE t001-butxt,
    ekorg        TYPE t024e-ekorg,
    ekotx        TYPE t024e-ekotx,
    ekgrp        TYPE t024-ekgrp,
    eknam        TYPE t024-eknam,
    matnr        TYPE ekpo-matnr,
    zzmaktx80    TYPE mara-zzmaktx80,
    specno       TYPE zgtmm_cv_get_reqpo_data-specno,
    color        TYPE zgtmm_cv_get_reqpo_data-color,
    stripe_color TYPE zgtmm_cv_get_reqpo_data-stripe_color,
    stripe_no    TYPE zgtmm_cv_get_reqpo_data-stripe_no,
    werks        TYPE t001w-werks,
    werks_n      TYPE t001w-name1,
    lgort        TYPE ekpo-lgort,
    lgobe        TYPE t001l-lgobe,
    emlif        TYPE ekpo-emlif,
    emlif_n      TYPE char35,
    menge        TYPE ekpo-menge,
    meins        TYPE ekpo-meins,
    dpcbt        TYPE marc-dpcbt,
    length       TYPE zelength,
    drqty        TYPE dec4,
    drmatnr      TYPE mara-matnr,  "추가-포장재(드럼)
    netpr_i      TYPE ekpo-netpr,
    peinh_i      TYPE ekpo-peinh,
    waers_i      TYPE ekko-waers,
    mwskz_i      TYPE ekpo-mwskz,
    netpr        TYPE ekpo-netpr,
    peinh        TYPE ekpo-peinh,
    waers        TYPE ekko-waers,
    mwskz        TYPE ekpo-mwskz,
    eindt        TYPE eket-eindt,
    insmk        TYPE ekpo-insmk,
    insmk_n      TYPE char20,
    zmemo        TYPE char200,
    uebto        TYPE ekpo-uebto,
    retpo        TYPE ekpo-retpo,
    zfree        TYPE char1,
    knttp        TYPE ekpo-knttp,
    ablad        TYPE ekkn-ablad,
    matkl        TYPE mara-matkl,
    pstyp        TYPE ekpo-pstyp,
    vbeln        TYPE vbap-vbeln,
    vbelp        TYPE vbap-posnr,
    kostl        TYPE ekkn-kostl,
    sakto        TYPE ekkn-sakto,
    anln1        TYPE ekkn-anln1,
    anln2        TYPE ekkn-anln2,
    ps_psp_pnr   TYPE ekkn-ps_psp_pnr,
    aufnr        TYPE ekkn-aufnr,
    infnr        TYPE eina-infnr,
    index        TYPE  sy-tabix,
  END OF ty_cre_po,
  BEGIN OF ty_eban,
    banfn TYPE eban-banfn,
    bnfpo TYPE eban-bnfpo,
    matnr TYPE eban-matnr,
    werks TYPE eban-werks,
    menge TYPE eban-menge,
  END OF ty_eban.


*----------------------------------------------------------------------*
* GLOBAL VARIABLE
*----------------------------------------------------------------------*
* => GV + '_' XX.XXX
*----------------------------------------------------------------------*
DATA :
  gv_okcode       TYPE sy-ucomm,
  gv_okcode_save  TYPE sy-ucomm,
  gv_okcode_save2 TYPE sy-ucomm,
  gv_okcode_save3 TYPE sy-ucomm,
  gv_ucomm        TYPE sy-ucomm,
  gv_auto_change,
  gv_ch_style,
  gv_answer,
  gv_edit,
  gv_exit,
  gv_new,
  gv_err,
  gv_mode.

DATA :
  gv_ekgrp    TYPE ekgrp,
  gv_lifnr    TYPE lifnr,
  gv_zterm    TYPE mepo1226-zterm, "지급조건
  gv_inco1    TYPE inco1,    "인코텀스1
  gv_ques(30) TYPE c,
  gv_info(30) TYPE c,
  gv_text     TYPE so_obj_des,
  gv_dynnr    TYPE sy-dynnr.

**-- 26.09 추가
DATA: gv_vbeln_posnr TYPE c LENGTH 16.

*----------------------------------------------------------------------*
* GLOBAL STRUCTURE
*----------------------------------------------------------------------*
* => GS + '_' XX.XXX
*----------------------------------------------------------------------*
*DATA : BEGIN OF GS_LIST.
*DATA :   STATUS     TYPE ICON-NAME. "상태(아이콘)
*         INCLUDE TYPE ZGTMM_CV_GET_REQPO_DATA.
*DATA : IDNLF      TYPE ZGTMM_CV_GET_INFOPRICE-IDNLF,
*         MWSKZ      TYPE ZGTMM_CV_GET_INFOPRICE-MWSKZ,
*         CONQTY     TYPE ZGTMM_CV_GET_INFOPRICE_M-CONQTY,
*         BANFN_ICON TYPE ICON-NAME,
*         TYPE       TYPE BAPIRET2-TYPE,
*         MESSAGE    TYPE BAPIRET2-MESSAGE,
*         STYLE      TYPE LVC_T_STYL,
*         END OF GS_LIST.

DATA : BEGIN OF gs_list,
         status        TYPE icon-name,
         ekgrp         TYPE zgtmm_cv_get_reqpo_data-ekgrp,
         ekgrp_n       TYPE zgtmm_cv_get_reqpo_data-ekgrp_n,
         erdat         TYPE zgtmm_cv_get_reqpo_data-erdat,
         matnr         TYPE zgtmm_cv_get_reqpo_data-matnr,
         txz01         TYPE zgtmm_cv_get_reqpo_data-txz01,
         specno        TYPE zgtmm_cv_get_reqpo_data-specno,
         color         TYPE zgtmm_cv_get_reqpo_data-color,
         stripe_color  TYPE zgtmm_cv_get_reqpo_data-stripe_color,
         stripe_no     TYPE zgtmm_cv_get_reqpo_data-stripe_no,
         lfdat         TYPE zgtmm_cv_get_reqpo_data-lfdat,
         ztype         TYPE zgtmm_cv_get_reqpo_data-ztype,
         ztype_n       TYPE zgtmm_cv_get_reqpo_data-ztype_n,
         bsart         TYPE ekko-bsart,
         banfn         TYPE zgtmm_cv_get_reqpo_data-banfn,
         bnfpo         TYPE zgtmm_cv_get_reqpo_data-bnfpo,
         pr_status     TYPE zgtmm_cv_get_reqpo_data-pr_status,
         menge         TYPE zgtmm_cv_get_reqpo_data-menge,
         menge_i       TYPE zgtmm_cv_get_reqpo_data-menge,
         meins         TYPE zgtmm_cv_get_reqpo_data-meins,

         length        TYPE zgtmm_cv_get_reqpo_data-length,
         drumname      TYPE zgtmm_cv_get_reqpo_data-drumname, "포장재(드럼)
         drqty         TYPE zgtmm_cv_get_reqpo_data-drqty,

         insmk         TYPE ekpo-insmk,
         insmk_n       TYPE char20,
         som           TYPE zgtmm_cv_get_reqpo_data-som,
         fgstock       TYPE zgtmm_cv_get_reqpo_data-fgstock,
         fgmeins       TYPE zgtmm_cv_get_reqpo_data-fgmeins,
         fgdrqty       TYPE zgtmm_cv_get_reqpo_data-fgdrqty,
         slqty         TYPE zgtmm_cv_get_reqpo_data-slqty,
         matkl         TYPE zgtmm_cv_get_reqpo_data-matkl,
         matkl_n       TYPE zgtmm_cv_get_reqpo_data-matkl_n,
         bukrs         TYPE zgtmm_cv_get_reqpo_data-bukrs,
         kokrs         TYPE zgtmm_cv_get_reqpo_data-kokrs,
         ktopl         TYPE zgtmm_cv_get_reqpo_data-ktopl,
         ekorg         TYPE zgtmm_cv_get_reqpo_data-ekorg,
         ekorg_n       TYPE zgtmm_cv_get_reqpo_data-ekorg_n,
         werks         TYPE zgtmm_cv_get_reqpo_data-werks,
         werks_n       TYPE zgtmm_cv_get_reqpo_data-werks_n,
         lgort         TYPE zgtmm_cv_get_reqpo_data-lgort,
         lgort_n       TYPE zgtmm_cv_get_reqpo_data-lgort_n,
         emlif         TYPE zgtmm_cv_get_reqpo_data-emlif,
         scvname       TYPE zgtmm_cv_get_reqpo_data-scvname,
         lblkz         TYPE zgtmm_cv_get_reqpo_data-lblkz,
         ablad         TYPE zgtmm_cv_get_reqpo_data-ablad,
         afnam         TYPE zgtmm_cv_get_reqpo_data-afnam,
         flief         TYPE zgtmm_cv_get_reqpo_data-flief,
         flief_n       TYPE zgtmm_cv_get_reqpo_data-flief_n,
         bplist(200)   TYPE c,  "계약업체
         lifnr         TYPE zgtmm_cv_get_reqpo_data-lifnr,
         lifnr_n       TYPE zgtmm_cv_get_reqpo_data-lifnr_n,
         preis_p       TYPE zgtmm_cv_get_reqpo_data-preis,
         waers_p       TYPE zgtmm_cv_get_reqpo_data-waers,
         peinh_p       TYPE zgtmm_cv_get_reqpo_data-peinh,
         mwskz_p       TYPE zgtmm_cv_get_infoprice-mwskz,
         preis_i       TYPE zgtmm_cv_get_reqpo_data-preis,
         waers_i       TYPE zgtmm_cv_get_reqpo_data-waers,
         peinh_i       TYPE zgtmm_cv_get_reqpo_data-peinh,
         mwskz_i       TYPE zgtmm_cv_get_infoprice-mwskz,
         preis         TYPE zgtmm_cv_get_reqpo_data-preis,
         waers         TYPE zgtmm_cv_get_reqpo_data-waers,
         peinh         TYPE zgtmm_cv_get_reqpo_data-peinh,
         idnlf         TYPE zgtmm_cv_get_infoprice-idnlf,
         gswrt         TYPE zgtmm_cv_get_reqpo_data-gswrt,
         sotax         TYPE zgtmm_cv_get_reqpo_data-sotax,
         mwskz         TYPE zgtmm_cv_get_infoprice-mwskz,
         zmemo_h       TYPE char200,
         zmemo_i       TYPE char200,
         zmemo_s       TYPE char200,
         mcontents     TYPE zgtmm_cv_get_reqpo_data-mcontents,
         ebakz         TYPE zgtmm_cv_get_reqpo_data-ebakz,
         loekz         TYPE zgtmm_cv_get_reqpo_data-loekz,
         knttp         TYPE zgtmm_cv_get_reqpo_data-knttp,
         knttp_n       TYPE zgtmm_cv_get_reqpo_data-knttp_n,
         pstyp         TYPE zgtmm_cv_get_reqpo_data-pstyp,
         pstyp_n       TYPE zgtmm_cv_get_reqpo_data-pstyp_n,
         rel           TYPE zgtmm_cv_get_reqpo_data-rel,
         sakto         TYPE zgtmm_cv_get_reqpo_data-sakto,
         sakto_n       TYPE zgtmm_cv_get_reqpo_data-sakto_n,
         kostl         TYPE zgtmm_cv_get_reqpo_data-kostl,
         kostl_n       TYPE zgtmm_cv_get_reqpo_data-kostl_n,
         vbeln         TYPE zgtmm_cv_get_reqpo_data-vbeln,
         posnr         TYPE zgtmm_cv_get_reqpo_data-posnr,
         kunnr         TYPE zgtmm_cv_get_reqpo_data-kunnr,
         kunnr_n       TYPE zgtmm_cv_get_reqpo_data-kunnr_n,
         vkbur         TYPE zgtmm_cv_get_reqpo_data-vkbur,
         vkbur_n       TYPE zgtmm_cv_get_reqpo_data-vkbur_n,
         vkgrp         TYPE zgtmm_cv_get_reqpo_data-vkgrp,
         vkgrp_n       TYPE zgtmm_cv_get_reqpo_data-vkgrp_n,
         teamcode      TYPE zgtmm_cv_get_reqpo_data-teamcode,
         inspection    TYPE zgtmm_cv_get_reqpo_data-inspection,
         anln1         TYPE zgtmm_cv_get_reqpo_data-anln1,
         anln2         TYPE zgtmm_cv_get_reqpo_data-anln2,
         anln1_n       TYPE zgtmm_cv_get_reqpo_data-anln1_n,
         ps_psp_pnr    TYPE zgtmm_cv_get_reqpo_data-ps_psp_pnr,
         ps_psp_pnr_n  TYPE zgtmm_cv_get_reqpo_data-ps_psp_pnr_n,
         aufnr         TYPE zgtmm_cv_get_reqpo_data-aufnr,
         conqty        TYPE zgtmm_cv_get_infoprice_m-conqty,
**-- 26.10 inspection 값 추가
         insqty_w      TYPE zgtmm_cv_so_vcvalue-value_from,  "입회검사여장
         insqty_s      TYPE zgtmm_cv_so_vcvalue-value_from,  "특별검사여장

         banfn_n       TYPE zgtmm_cv_get_reqpo_data-banfn,
         banfn_icon    TYPE icon-name,
         flag          TYPE zgtmm_cv_get_reqpo_data-flag,
         poprocess     TYPE zgtmm_cv_get_reqpo_data-poprocess,
         ebeln         TYPE zgtmm_cv_get_reqpo_data-ebeln,
         ebelp         TYPE zgtmm_cv_get_reqpo_data-ebelp,
         porelstatus   TYPE zgtmm_cv_get_reqpo_data-porelstatus,
         estkz         TYPE zgtmm_cv_get_reqpo_data-estkz,
         mtart         TYPE zgtmm_cv_get_reqpo_data-mtart,
         irondrum      TYPE zgtmm_cv_get_reqpo_data-irondrum,
         drumtitlemark TYPE zgtmm_cv_get_reqpo_data-drumtitlemark,
         flange_prot   TYPE zgtmm_cv_get_reqpo_data-flange_prot,
         hanjeon       TYPE zgtmm_cv_get_reqpo_data-hanjeon,
         dpcbt         TYPE zgtmm_cv_get_reqpo_data-dpcbt,
         lgchk         TYPE zgtmm_cv_get_reqpo_data-lgchk, "저장위치 총중량 판단 대상
         type          TYPE bapiret2-type,
         message       TYPE bapiret2-message,

         style         TYPE lvc_t_styl,
         f_col         TYPE lvc_t_scol,  "컬러
       END OF gs_list.


DATA : BEGIN OF gs_create,
         status       TYPE icon-name, "상태(아이콘)

         ebeln        TYPE ekpo-ebeln,
         ebelp        TYPE ekpo-ebelp,
         lifnr        TYPE ekko-lifnr,
         lifnr_n      TYPE char35,
         bukrs        TYPE t001-bukrs,
         butxt        TYPE t001-butxt,
         ekorg        TYPE t024e-ekorg,
         ekotx        TYPE t024e-ekotx,
         ekgrp        TYPE t024-ekgrp,
         eknam        TYPE t024-eknam,
         matnr        TYPE ekpo-matnr,
         zzmaktx80    TYPE mara-zzmaktx80,

         specno       TYPE zgtmm_cv_get_reqpo_data-specno,
         color        TYPE zgtmm_cv_get_reqpo_data-color,
         stripe_color TYPE zgtmm_cv_get_reqpo_data-stripe_color,
         stripe_no    TYPE zgtmm_cv_get_reqpo_data-stripe_no,
         werks        TYPE t001w-werks,
         werks_n      TYPE t001w-name1,
         lgort        TYPE ekpo-lgort,
         lgobe        TYPE t001l-lgobe,
         emlif        TYPE ekpo-emlif,
         emlif_n      TYPE char35,
         menge        TYPE ekpo-menge,
         meins        TYPE ekpo-meins,
         dpcbt        TYPE marc-dpcbt,
         length       TYPE zelength,
         zdgno        TYPE zesul_no,  "설계번호
         zrevno       TYPE zerev_seq, "개정번호
         drmatnr      TYPE mara-matnr,  "추가-포장재(드럼)
         drumname     TYPE zgtmm_cv_get_reqpo_data-drumname,
         drqty        TYPE dec4,
*         NETPR_P   TYPE EKPO-NETPR,
*         PEINH_P    TYPE EKPO-PEINH,
*         WAERS_P  TYPE EKKO-WAERS,
*         MWSKZ_P TYPE EKPO-MWSKZ,
         eindt        TYPE eket-eindt,
         netpr        TYPE ekpo-netpr,
         peinh        TYPE ekpo-peinh,
         waers        TYPE ekko-waers,
         mwskz        TYPE ekpo-mwskz,
         netpr_i      TYPE ekpo-netpr,
         peinh_i      TYPE ekpo-peinh,
         waers_i      TYPE ekko-waers,
         mwskz_i      TYPE ekpo-mwskz,
         idnlf        TYPE eina-idnlf,

         insmk        TYPE ekpo-insmk,
         insmk_n      TYPE char20,
         zmemo        TYPE char200,
         uebto        TYPE ekpo-uebto,
         retpo        TYPE ekpo-retpo,
         zfree        TYPE char1,
         knttp        TYPE ekpo-knttp,
         matkl        TYPE mara-matkl,
         mtart        TYPE mara-mtart,
         ablad        TYPE ekkn-ablad,
         pstyp        TYPE ekpo-pstyp,
         vbeln        TYPE vbap-vbeln,
         vbelp        TYPE vbap-posnr,
         zmemo_s      TYPE char200,
         mcontents    TYPE zgtmm_cv_get_reqpo_data-mcontents,
         kostl        TYPE ekkn-kostl,
         sakto        TYPE ekkn-sakto,
         anln1        TYPE ekkn-anln1,
         anln2        TYPE ekkn-anln2,
         ps_psp_pnr   TYPE ekkn-ps_psp_pnr,
         aufnr        TYPE ekkn-aufnr,
         infnr        TYPE eina-infnr,

         message      TYPE bapiret2-message,
         style        TYPE lvc_t_styl,
         f_col        TYPE lvc_t_scol,
       END OF gs_create.

DATA : BEGIN OF gs_pr,
         banfn TYPE banfn,
         bnfpo TYPE bnfpo,
         ekgrp TYPE ekgrp,
       END OF gs_pr.

DATA : BEGIN OF gs_cl,
         matnr TYPE matnr,
         werks TYPE werks,
         ekgrp TYPE ekgrp,
       END OF gs_cl.

DATA : gs_return LIKE bapiret2.
DATA : gs_variant LIKE disvariant.

* BDC 테이블
DATA : gs_bdcparams TYPE ctu_params .
DATA : gs_bdcdata TYPE bdcdata .
DATA : gt_bdcdata TYPE TABLE OF bdcdata .
DATA : gt_messtab TYPE TABLE OF bdcmsgcoll .

*----------------------------------------------------------------------*
* GLOBAL INTERNAL TABLE                                                *
*----------------------------------------------------------------------*
* => GT_ + XXX...XX                                                    *
*----------------------------------------------------------------------*
DATA : gt_list    LIKE TABLE OF gs_list,
       gt_create  LIKE TABLE OF gs_create,
       gt_conv_po TYPE TABLE OF ty_conv_po,
       gt_cre_po  TYPE TABLE OF ty_cre_po,
       gt_cre_bdc TYPE TABLE OF ty_cre_po,
       gt_info    TYPE TABLE OF zgtmm_cv_get_infoprice,
       gt_eban    TYPE TABLE OF ty_eban.

DATA:
  gt_t163i TYPE SORTED TABLE OF ty_t163i WITH UNIQUE KEY knttp,
  gt_t163y TYPE SORTED TABLE OF ty_t163y WITH UNIQUE KEY pstyp,
  gt_t023t TYPE SORTED TABLE OF ty_t023t WITH UNIQUE KEY matkl,
  gt_t001  TYPE SORTED TABLE OF ty_t001 WITH UNIQUE KEY bukrs,
  gt_t001w TYPE SORTED TABLE OF ty_t001w WITH UNIQUE KEY werks,
  gt_t001l TYPE SORTED TABLE OF ty_t001l WITH UNIQUE KEY werks lgort,
  gt_t024e TYPE SORTED TABLE OF ty_t024e WITH UNIQUE KEY ekorg,
  gt_t024  TYPE SORTED TABLE OF ty_t024 WITH UNIQUE KEY ekgrp,
  gt_char  TYPE SORTED TABLE OF ty_char WITH UNIQUE KEY ebeln, ebelp.

DATA : gt_chdata LIKE TABLE OF zgtmms4517.

DATA : gt_pr LIKE TABLE OF gs_pr,
       gt_cl LIKE TABLE OF gs_cl.

DATA : gt_return LIKE TABLE OF bapiret2.

DATA : gt_mtxt TYPE bcsy_text,
       gs_mtxt TYPE soli.

DATA: gt_insmk TYPE TABLE OF dd07v.

*----------------------------------------------------------------------*
* GLOBAL RANGE                                                         *
*----------------------------------------------------------------------*
* => GR_ + XXX.XX                                                      *
*----------------------------------------------------------------------*
**-- 판매문서&품목 기준시 POSNR 정보도 처리 할수 잇도록 추가
RANGES : gr_posnr FOR vbap-posnr.


*----------------------------------------------------------------------*
* GLOBAL FIELD SYMBOLS                                                 *
*----------------------------------------------------------------------*
* => <FS_XXX...XX>, EX)<FS_ITAB>, <FS_WA>, <FS_NN>                     *
*----------------------------------------------------------------------*


*----------------------------------------------------------------------*
* CONSTANTS
*----------------------------------------------------------------------*
CONSTANTS :
  gc_a(1)  VALUE 'A',
  gc_c(1)  VALUE 'C',
  gc_d(1)  VALUE 'D',
  gc_e(1)  VALUE 'E',
  gc_f(1)  VALUE 'F',
  gc_h(1)  VALUE 'H',
  gc_i(1)  VALUE 'I',
  gc_j(1)  VALUE 'J',
  gc_k(1)  VALUE 'K',
  gc_l(1)  VALUE 'L',
  gc_m(1)  VALUE 'M',
  gc_n(1)  VALUE 'N',
  gc_o(1)  VALUE 'O',
  gc_p(1)  VALUE 'P',
  gc_r(1)  VALUE 'R',
  gc_s(1)  VALUE 'S',
  gc_x(1)  VALUE 'X',
  gc_u(1)  VALUE 'U',
  gc_v(1)  VALUE 'V',
  gc_1(1)  VALUE '1',
  gc_3(1)  VALUE '3',
  gc_bt(2) VALUE 'BT',
  gc_eq(2) VALUE 'EQ',
  gc_cl(2) VALUE 'CL',
  gc_pr(2) VALUE 'PR',
  gc_nb(2) VALUE 'NB',
  gc_mm(2) VALUE 'MM'.

CONSTANTS :
  gc_ksrm(4)      VALUE 'KSRM',
  gc_taxkr(5)     VALUE 'TAXKR',
  gc_zgrstatus(9) VALUE 'ZGRSTATUS',
  gc_zivstatus(9) VALUE 'ZIVSTATUS'.

CONSTANTS:
  gc_zgtmmr3000 TYPE w3objid VALUE 'ZGTMMR3000'.

*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
DEFINE _set_ranges.

  &1-low = &2.
  &1-high = &3.
  &1-option = &4.
  &1-sign = &5.
  APPEND &1.

END-OF-DEFINITION.

DEFINE _idoc.
  DATA: lv_sap_amt  TYPE wrbtr, " SAP 금액 입력용 (P 타입)
            lv_price(35). " IDOC 금액 출력용 (C 타입 대용)

  lv_sap_amt = &2.

 " 1. SAP 내부(100.00) -> 외부/IDOC(100) 변환
   CALL FUNCTION 'CURRENCY_AMOUNT_SAP_TO_IDOC'
     EXPORTING
      currency      = &1
      sap_amount  = lv_sap_amt"LV_PRICE
     IMPORTING
      idoc_amount = lv_price. " 결과: 100

  &3 = lv_price.

END-OF-DEFINITION.

DEFINE __setting_bdc_params.
  CLEAR: gS_BDCPARAMS.
  gS_BDCPARAMS-dismode  = 'N'.   " 처리모드
  gS_BDCPARAMS-updmode  = 'S'.   " 갱신세션
*  MS_BDCPARAMS-CATTMODE = ''.   " CATT모드
  gS_BDCPARAMS-defsize  = 'X'.   " 기본화면
**  MS_BDCPARAMS-RACOMMIT = 'X'.   " COMMAND 이후 지속
**  MS_BDCPARAMS-NOBINPT  = ' '.   " BI 세션
END-OF-DEFINITION.

DEFINE __bdc_dynpro.
  CLEAR gS_BDCDATA.
  gS_BDCDATA-program  = &1.
  gS_BDCDATA-dynpro   = &2.
  gS_BDCDATA-dynbegin = 'X'.
  APPEND gS_BDCDATA TO gT_BDCDATA.
END-OF-DEFINITION.

DEFINE __bdc_field.
  CLEAR gS_BDCDATA.
  gS_BDCDATA-fnam = &1.
  gS_BDCDATA-fval = CONV #( &2 ).
  APPEND gS_BDCDATA TO gT_BDCDATA.
END-OF-DEFINITION.


DEFINE __bdc_transaction.
  CALL TRANSACTION &1 USING gT_BDCDATA
                              OPTIONS FROM gS_BDCPARAMS
                            MESSAGES INTO gT_MESSTAB.
END-OF-DEFINITION.


*----------------------------------------------------------------------*
* SELECTION SCREEN
*----------------------------------------------------------------------*
* SELECTION OPTION => SO_XX...X
* PARAMETER        => PA_XX...X
* CHECKBOX         => CB_XX...X
* RADIO BUTTON     => RB_XX...X
*----------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-001.
*MODIF 지정은 활성화 한다는 기준.
*S_ERDAT/S_EINDT/S_MATNR/S_VBELN/P_WERKS/P_EKGRP은 비활성 기준.

  PARAMETERS : p_bukrs TYPE t001-bukrs OBLIGATORY, "       회사코드
               p_ekorg TYPE t024e-ekorg OBLIGATORY, "구매조직
               p_werks TYPE marc-werks OBLIGATORY MODIF ID md1,  "플랜트
               p_ekgrp TYPE marc-ekgrp OBLIGATORY MODIF ID md1.   "구매그룹

  SELECT-OPTIONS : s_werks FOR marc-werks MODIF ID mot, "플랜트
                                s_ekgrp FOR marc-ekgrp MODIF ID mot,  "구매그룹
                                s_erdat FOR ekko-aedat MODIF ID cre, "생성일
                                s_eindt  FOR ekko-aedat MODIF ID cre, "납품예정일
                                s_ebeln FOR ekko-ebeln MODIF ID mot, "구매오더
                                s_lifnr   FOR ekko-lifnr MODIF ID mot,    "공급업체
                                s_matnr FOR marc-matnr MODIF ID cre, "자재코드
                                s_vbeln FOR vbak-vbeln MODIF ID cre. "판매오더
**-- 26.09 판매문서&품번 조건 추가
  SELECT-OPTIONS : s_sopo FOR gv_vbeln_posnr MODIF ID cre.
SELECTION-SCREEN END OF BLOCK b1.

SELECTION-SCREEN BEGIN OF BLOCK b2 WITH FRAME TITLE TEXT-003.
  SELECTION-SCREEN BEGIN OF LINE.
*청구량/PR 기준
    PARAMETERS p_pr RADIOBUTTON GROUP rb1 DEFAULT 'X' USER-COMMAND uc01.
    SELECTION-SCREEN COMMENT (15) TEXT-c04 FOR FIELD p_pr.

**--> 26.09 *단순견적 - 추가
*단순견적 - 추가
    PARAMETERS p_pr2 RADIOBUTTON GROUP rb1 .
    SELECTION-SCREEN COMMENT (15) TEXT-c11 FOR FIELD p_pr2.
**--< 26.09 *단순견적 - 추가

*직접 생성
    PARAMETERS p_cre RADIOBUTTON GROUP rb1.
    SELECTION-SCREEN COMMENT (15) TEXT-c05 FOR FIELD p_cre.

*PO 진행 현황 모니터링
    PARAMETERS p_mot RADIOBUTTON GROUP rb1.
    SELECTION-SCREEN COMMENT (15) TEXT-c06 FOR FIELD p_mot.

  SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN END OF BLOCK b2.

SELECTION-SCREEN BEGIN OF BLOCK b3 WITH FRAME TITLE TEXT-004.
  SELECTION-SCREEN BEGIN OF LINE.
*청구량 정보 조회
    PARAMETERS p_vol AS CHECKBOX MODIF ID mpr DEFAULT 'X'.
    SELECTION-SCREEN COMMENT (15) TEXT-c07 FOR FIELD p_vol.
*구매요청 정보 조회
    PARAMETERS p_prd AS CHECKBOX MODIF ID mpr DEFAULT 'X'.
    SELECTION-SCREEN COMMENT (15) TEXT-c08 FOR FIELD p_prd.
***발주 진행 대상 조회
*    PARAMETERS P_ORD AS CHECKBOX MODIF ID MPR DEFAULT 'X'.
*    SELECTION-SCREEN COMMENT (15) TEXT-C09 FOR FIELD P_ORD.
*종료/삭제 제외 조회
    PARAMETERS p_del AS CHECKBOX MODIF ID mpr DEFAULT 'X'.
    SELECTION-SCREEN COMMENT (15) TEXT-c10 FOR FIELD p_del.

  SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN END OF BLOCK b3.

SELECTION-SCREEN BEGIN OF BLOCK b4  WITH FRAME TITLE TEXT-002.
  SELECTION-SCREEN BEGIN OF LINE.
*삭제 PO 제외
    PARAMETERS p_dpo AS CHECKBOX MODIF ID mot.
    SELECTION-SCREEN COMMENT (15) TEXT-c01 FOR FIELD p_dpo MODIF ID mot.
*납품완료  PO 제외
    PARAMETERS p_fin AS CHECKBOX MODIF ID mot.
    SELECTION-SCREEN COMMENT (15) TEXT-c02 FOR FIELD p_fin MODIF ID mot.
*반품  PO 제외
    PARAMETERS p_rpo AS CHECKBOX MODIF ID mot.
    SELECTION-SCREEN COMMENT (15) TEXT-c03 FOR FIELD p_rpo MODIF ID mot.

  SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN END OF BLOCK b4.

*SELECTION-SCREEN BEGIN OF BLOCK B5 WITH FRAME TITLE TEXT-005.
*  PARAMETERS:     P_VARI   LIKE DISVARIANT-VARIANT.
*SELECTION-SCREEN END OF BLOCK B5.
