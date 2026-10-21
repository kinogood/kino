************************************************************************
* Title         :  ZTIR4300T02                                         *
*                                                                      *
* Description   : Inbound 생성 Top Include                             *
*                                                                      *
* Creation Date : 2004/02/18                                           *
*                                                                      *
* Author        : Seog Bong, Kang                                      *
*                 Copyright ⓒ ASEG Co., LTD. All rights reserved.     *
************************************************************************
*----------------------------------------------------------------------*
*                M O D I F I C A T I O N   L O G                       *
*----------------------------------------------------------------------*
* Date         Programmer       Transport#  Description                *
*----------------------------------------------------------------------*
* dd-mmm-yyyy  xxxxxxxxxxxxxxx  DVPK9xxxxx  xxxxxxxxxxxxxxxxxxxxxxxxx  *
*                                                                      *
*                                                                      *
*----------------------------------------------------------------------*

*----------------------------------------------------------------------*
*> Inbound delivery 자동 생성용.
*----------------------------------------------------------------------*
*  DB-Table
*----------------------------------------------------------------------*
TABLES: lfm1,
        t163l,
        t163g,
        tvsa,
        t320.

TABLES: bbp_inbd_l,
        bbp_inbd_d,
        bapireturn.



*----------------------------------------------------------------------*
*  Interne Tabellen
*----------------------------------------------------------------------*
DATA:  it_inb    LIKE bbp_inbd_d OCCURS 0 WITH HEADER LINE,
       it_return LIKE bapireturn OCCURS 0 WITH HEADER LINE.

DATA:  xkomdlgn LIKE komdlgn OCCURS 0 WITH HEADER LINE,
       xvbfs    LIKE vbfs    OCCURS 0 WITH HEADER LINE,
       xvbls    LIKE vbls    OCCURS 0 WITH HEADER LINE,
       xlips    LIKE lips    OCCURS 0 WITH HEADER LINE,
       fxlikp   LIKE likpvb  OCCURS 0 WITH HEADER LINE,
       fxlips   LIKE lipsvb  OCCURS 0 WITH HEADER LINE,
       fxvbfa   LIKE vbfavb  OCCURS 0 WITH HEADER LINE,
       fxvbpa   LIKE vbpavb  OCCURS 0 WITH HEADER LINE,
       fxvbuk   LIKE vbukvb  OCCURS 0 WITH HEADER LINE,
       fxvbup   LIKE vbupvb  OCCURS 0 WITH HEADER LINE,
       fyvbuk   LIKE vbukvb  OCCURS 0 WITH HEADER LINE,
       fyvbup   LIKE vbupvb  OCCURS 0 WITH HEADER LINE,
       xeket    LIKE beket   OCCURS 0 WITH HEADER LINE,
       xekkn    LIKE ekkn    OCCURS 0 WITH HEADER LINE,
       xvbsk    LIKE vbsk     .

DATA: BEGIN OF xekpo_short OCCURS 0,
        ebeln LIKE ekpo-ebeln,
        ebelp LIKE ekpo-ebelp,
        werks LIKE ekpo-werks,
        lgort LIKE ekpo-lgort,
        menge LIKE ekpo-menge,
        meins LIKE ekpo-meins,
        lmein LIKE ekpo-lmein,
        umrez LIKE ekpo-umrez,
        umren LIKE ekpo-umren,
        matnr LIKE ekpo-matnr,
        ematn LIKE ekpo-ematn,
        mfrnr LIKE ekpo-mfrnr,
        mfrpn LIKE ekpo-mfrpn,
        emnfr LIKE ekpo-emnfr,
        cuobj LIKE ekpo-cuobj,
        uebto LIKE ekpo-uebto,
        untto LIKE ekpo-untto,
        uebtk LIKE ekpo-uebtk,
        bwtar LIKE ekpo-bwtar,
        idnlf LIKE ekpo-idnlf,
        txz01 LIKE ekpo-txz01,
        mfrgr LIKE ekpo-mfrgr,
        gewei LIKE ekpo-gewei,
        voleh LIKE ekpo-voleh,
        ntgew LIKE ekpo-ntgew,
        brgew LIKE ekpo-brgew,
        volum LIKE ekpo-volum,
        ean11 LIKE ekpo-ean11,
        aktnr LIKE ekpo-aktnr,
        abeln LIKE ekpo-abeln,
        abelp LIKE ekpo-abelp,
        aurel LIKE ekpo-aurel,
        matkl LIKE ekpo-matkl,
        upvor LIKE ekpo-upvor,
        uptyp LIKE ekpo-uptyp,
        uebpo LIKE ekpo-uebpo,
        bstae LIKE ekpo-bstae,
        wepos LIKE ekpo-wepos,
        anlmg LIKE ekpo-menge,
        insmk LIKE ekpo-insmk,
        pstyp LIKE ekpo-pstyp,
        sobkz LIKE ekpo-sobkz,
        kzvbr LIKE ekpo-kzvbr,            "note 384051
        knttp LIKE ekpo-knttp,
        kzfme LIKE ekpo-kzfme,
      END OF xekpo_short.

*----------------------------------------------------------------------*
*  Hilfsfelder
*----------------------------------------------------------------------*
DATA:      open_qty LIKE ekpo-menge,   "offene Menge
           count TYPE i,               "Z?ler f? gebuchte Positionen
           count1 TYPE i.              "Z?ler f? Protokollzeilen

DATA:      gf_dlv_type LIKE likp-lfart. "Delivery Type
DATA:      gf_ebtyp    LIKE t163d-ebtyp.
