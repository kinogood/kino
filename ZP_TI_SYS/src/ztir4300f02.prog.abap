************************************************************************
* Title         :  ZTIR4300F02                                         *
*                                                                      *
* Description   : Inbound 생성 Subroutine Include                      *
*                                                                      *
* Creation Date : 2003/08/16                                           *
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

*&---------------------------------------------------------------------*
*&      Form  get_delivery_type
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM get_delivery_type  USING besttyp.
  DATA: h_ibtyp LIKE t163d-ibtyp.
* Lieferart f? Grob-WE aus Best?igungssteuerung ermitteln
  h_ibtyp = besttyp.
  CALL FUNCTION 'ME_CONFIRMATION_DELIVERY_TYPE'
    EXPORTING
      i_func              = '1'
    CHANGING
      c_ibtyp             = h_ibtyp
      c_ebtyp             = gf_ebtyp
      c_lfart             = gf_dlv_type
    EXCEPTIONS
      function_not_valid  = 01
      param_value_missing = 02
      no_item_found       = 03.
  IF sy-subrc = 0.
    IF gf_dlv_type = space.
      gf_dlv_type = 'EL'.
    ENDIF.
  ELSE.
    gf_dlv_type = 'EL'.
  ENDIF.
ENDFORM.                    " get_delivery_type
*----------------------------------------------------------------------*
*  Warenausgang buchen                                                 *
*----------------------------------------------------------------------*
FORM vbsk_fill.

  CLEAR xvbsk.
  xvbsk-mandt = sy-mandt.
  xvbsk-ernam = sy-uname.
  xvbsk-erdat = sy-datum.
  xvbsk-uzeit = sy-uzeit.
  xvbsk-smart = 'L'.
*- Nummer VBSK vergeben -----------------------------------------------*
  SELECT SINGLE * FROM tvsa WHERE smart = xvbsk-smart.
  IF sy-subrc = 0.
    CALL FUNCTION 'NUMBER_GET_NEXT'
      EXPORTING
        nr_range_nr = tvsa-numki
        object      = 'RV_SAMMG'
      IMPORTING
        number      = xvbsk-sammg
      EXCEPTIONS
        OTHERS      = 01.
    IF sy-subrc NE 0.
      MESSAGE e700(me) WITH tvsa-numki 'RV_SAMMG'.
    ENDIF.
  ELSE.
    MESSAGE e700(me) WITH space 'RV_SAMMG'.
  ENDIF.
ENDFORM.                               " BUCHEN_LIEFERUNG
*&---------------------------------------------------------------------*
*&      Form  XKOMDLGN_FILL
*&---------------------------------------------------------------------*
FORM xkomdlgn_fill USING    p_open_qty LIKE ekpo-menge
                            p_eindt    LIKE eket-eindt
                            p_licha    LIKE eket-licha
                            p_charg    LIKE eket-charg
                            p_uzeit    LIKE eket-uzeit.

 STATICS: h_grkor LIKE lips-grkor,      "Liefergruppe          "n_572944
       h_bsmng LIKE ekpo-menge.         "Bestellmenge ?ergeordnete Pos.
  CLEAR xkomdlgn.                                           "457620

* Eliminieren von Komponenten bei Set, Lot, Display             "578259
  CHECK xekpo_short-uptyp NE '5'  " Lot                         "578259
    AND xekpo_short-uptyp NE '6'  " Display                     "578259
    AND xekpo_short-uptyp NE '7'  " VK-Set                      "578259
    AND xekpo_short-uptyp NE 'H'. " GT-St?kliste               "622794

* Eliminieren der Kopfposition bei Retail-Sammelartikeln und GT "525119
                                                            "622794
  IF xekpo_short-uebpo IS INITIAL AND xekpo_short-upvor CA '1I'."525119
    CHECK 1 = 2.                                            "525119
  ENDIF.                                                    "525119

  IF NOT ekko-lifnr IS INITIAL.
    CALL FUNCTION 'VENDOR_MASTER_DATA_SELECT_12'
      EXPORTING
        pi_lifnr       = ekko-lifnr
        pi_ekorg       = ekko-ekorg
      IMPORTING
        pe_lfm1        = lfm1
      EXCEPTIONS
        no_entry_found = 1
        OTHERS         = 2.

    xkomdlgn-vsbed = lfm1-vsbed.
  ELSE.
    CLEAR xkomdlgn-vsbed.
  ENDIF.

  xkomdlgn-lifnr = ekko-lifnr.
  xkomdlgn-inco1 = ekko-inco1.                              "363954
  xkomdlgn-inco2 = ekko-inco2.                              "363954
  xkomdlgn-exnum = ekko-exnum.                              "363954
  xkomdlgn-bukrs_best = ekko-bukrs.                         "363954
  xkomdlgn-matnr = xekpo_short-matnr.
  xkomdlgn-werks = xekpo_short-werks.
  xkomdlgn-lgort = xekpo_short-lgort.
* xkomdlgn-charg = ?
  xkomdlgn-vrkme = xekpo_short-meins.
  xkomdlgn-meins = xekpo_short-lmein.
  xkomdlgn-umvkz = xekpo_short-umrez.
  xkomdlgn-umvkn = xekpo_short-umren.
  IF xekpo_short-matnr EQ space.
    xkomdlgn-meins = xekpo_short-meins.
    xkomdlgn-umvkz = 1.
    xkomdlgn-umvkn = 1.
  ENDIF.
  xkomdlgn-insmk = xekpo_short-insmk.
  xkomdlgn-kzfme = xekpo_short-kzfme.
  xkomdlgn-kzvbr = xekpo_short-kzvbr.           "note 384051
  xkomdlgn-lfimg = p_open_qty.
  xkomdlgn-lfdat = p_eindt.
  xkomdlgn-lfuhr = p_uzeit.
* xkomdlgn-vstel = ?
* xkomdlgn-vkorg = ?
* xkomdlgn-vtweg = ?
* xkomdlgn-spart = ?
  xkomdlgn-vgbel = xekpo_short-ebeln.
  xkomdlgn-vgpos = xekpo_short-ebelp.
  xkomdlgn-lfart = gf_dlv_type.
  xkomdlgn-vgtyp = 'V'.
  xkomdlgn-kzazu = 'X'.                "??? what's that for ????
  xkomdlgn-knttp = xekpo_short-knttp.
  xkomdlgn-sobkz = xekpo_short-sobkz.

  SELECT * FROM t163g WHERE bstae EQ xekpo_short-bstae
                        AND ebtyp EQ gf_ebtyp.
    EXIT.
  ENDSELECT.
  IF sy-subrc = 0.
* Pr?en, ob Lieferavis WE-Zuordnung hat (Vorauss. f? WE ?er VL32)
* und wepos pr?en
    IF t163g-wezuo EQ space OR xekpo_short-wepos EQ space.
      xkomdlgn-nowab = 'X'.
    ELSE.
      CLEAR xkomdlgn-nowab.
    ENDIF.
  ENDIF.

  IF xekpo_short-matnr IS INITIAL OR xekpo_short-pstyp = '6'.
    xkomdlgn-posar = 'B'.
  ENDIF.
  xkomdlgn-ematn = xekpo_short-ematn.
  xkomdlgn-mfrnr = xekpo_short-mfrnr.
  xkomdlgn-mfrpn = xekpo_short-mfrpn.
  xkomdlgn-emnfr = xekpo_short-emnfr.
  xkomdlgn-cuobj = xekpo_short-cuobj.
  xkomdlgn-uebto = xekpo_short-uebto.
  xkomdlgn-untto = xekpo_short-untto.
  xkomdlgn-uebtk = xekpo_short-uebtk.
  xkomdlgn-lichn = p_licha.
  xkomdlgn-charg = p_charg.
  xkomdlgn-bwtar = xekpo_short-bwtar.
  xkomdlgn-kdmat = xekpo_short-idnlf.
  xkomdlgn-arktx = xekpo_short-txz01.
  xkomdlgn-mfrgr = xekpo_short-mfrgr.
  xkomdlgn-gewei = xekpo_short-gewei.
  xkomdlgn-voleh = xekpo_short-voleh.
  xkomdlgn-ntgew = xekpo_short-ntgew * xkomdlgn-lfimg.
  xkomdlgn-brgew = xekpo_short-brgew * xkomdlgn-lfimg.
  xkomdlgn-volum = xekpo_short-volum * xkomdlgn-lfimg.
  xkomdlgn-ean11 = xekpo_short-ean11.
  xkomdlgn-podrel = t163l-podrel.
  xkomdlgn-aktnr = xekpo_short-aktnr.
  xkomdlgn-abeln = xekpo_short-abeln.
  xkomdlgn-abelp = xekpo_short-abelp.
* xkomdlgn-ltssf = only sort criteria in vl31n
  xkomdlgn-aurel = xekpo_short-aurel.
  xkomdlgn-idnlf = xekpo_short-idnlf.
  xkomdlgn-matkl = xekpo_short-matkl.

* Leergut-St?kliste ?ernehmen
  CLEAR xkomdlgn-grkor.
  CLEAR xkomdlgn-kmpmg.
  CLEAR xkomdlgn-uepos.
  CLEAR xkomdlgn-uepvw.                                     "549736
  IF xekpo_short-upvor CA '3X'.
    h_grkor = h_grkor + 1.
    xkomdlgn-grkor = h_grkor.
    h_bsmng = xekpo_short-menge.
  ENDIF.
  IF NOT xekpo_short-uebpo IS INITIAL AND
         xekpo_short-uptyp CA '3X'.
    xkomdlgn-uepvw = 'G'.                                   "549736
    xkomdlgn-uepos = xekpo_short-uebpo.
    xkomdlgn-grkor = h_grkor.
    IF h_bsmng NE 0.
      xkomdlgn-kmpmg = xekpo_short-menge / h_bsmng.
    ENDIF.
  ENDIF.

*- Konsignation - SOBKZ 'K' hart reinsetzen, da  von Pstyp abh?g......
  IF xekpo_short-pstyp EQ '2'.
    xkomdlgn-sobkz = 'K'.
  ENDIF.
* Kontierungsfelder
  IF xekpo_short-sobkz EQ 'E' OR xekpo_short-sobkz EQ 'Q'.
    CALL FUNCTION 'MMPUR_EKKN_READ_EBELN_EBELP'
      EXPORTING
        pi_ebeln                   = xekpo_short-ebeln
        pi_ebelp                   = xekpo_short-ebelp
*       PI_BYPASSING_BUFFER        =
*       PI_REFRESH_BUFFER          =
      TABLES
        pto_ekkn_po                = xekkn
      EXCEPTIONS
        no_records_requested       = 1
        OTHERS                     = 2.

    IF sy-subrc EQ 0.
      READ TABLE xekkn INDEX 1.
      xkomdlgn-ps_psp_pnr = xekkn-ps_psp_pnr.
      xkomdlgn-vbelv      = xekkn-vbeln.
      xkomdlgn-posnv      = xekkn-vbelp.
    ENDIF.
  ENDIF.

  APPEND xkomdlgn.
* write: / xeket-ebeln , 12 xeket-ebelp, 18 p_eindt, 28 p_open_qty.
ENDFORM.                               " XKOMDLGN_FILL
*&---------------------------------------------------------------------*
*&      Form  XT320_FILL
*&---------------------------------------------------------------------*
*orm xt320_fill.
* if not s_lgnum is initial.           " nur tempor? zwecks testen
*   select * from t320 into table xt320 where lgnum in s_lgnum
*                                         and censy ne space.
* endif.
*- Rangestabellen entsprechend erweitern ------------------------------*
* loop at xt320.
*   s_werks-low    = xt320-werks.
*   s_werks-sign   = 'I'.
*   s_werks-option = 'EQ'.
*   append s_werks.
*   s_lgort-low    = xt320-lgort.
*   s_lgort-sign   = 'I'.
*   s_lgort-option = 'EQ'.
*   append s_lgort.
* endloop.
* sort s_werks.
* sort s_lgort.
* delete adjacent duplicates from s_werks.
* delete adjacent duplicates from s_lgort.
*ndform.                               " XT320_FILL

*----------------------------------------------------------------------*
*  Protokoll der Lieferungserstellung anlegen                          *
*----------------------------------------------------------------------*
FORM protokoll_li.
  SORT xvbfs.                          "damit die ohne Beleg zuerst
  LOOP AT xvbfs.
    IF xvbfs-vbeln EQ space.
      CALL FUNCTION 'MESSAGE_STORE'
        EXPORTING
          arbgb                  = xvbfs-msgid
          msgty                  = xvbfs-msgty
          msgv1                  = xvbfs-msgv1
          msgv2                  = xvbfs-msgv2
          msgv3                  = xvbfs-msgv3
          msgv4                  = xvbfs-msgv4
          txtnr                  = xvbfs-msgno
          zeile                  = count1
        EXCEPTIONS
          message_type_not_valid
          not_active.
      IF sy-subrc NE 0.
        CONTINUE.
      ENDIF.
      count1 = count1 + 1.
      CONTINUE.
    ENDIF.
    IF xvbfs-posnr EQ '000000'.
      CALL FUNCTION 'MESSAGE_STORE'
        EXPORTING
          arbgb                  = xvbfs-msgid
          msgty                  = xvbfs-msgty
          msgv1                  = xvbfs-msgv1
          msgv2                  = xvbfs-msgv2
          msgv3                  = xvbfs-msgv3
          msgv4                  = xvbfs-msgv4
          txtnr                  = xvbfs-msgno
          zeile                  = count1
        EXCEPTIONS
          message_type_not_valid
          not_active.
      IF sy-subrc NE 0.
        CONTINUE.
      ENDIF.
      count1 = count1 + 1.
    ELSE.
      LOOP AT xkomdlgn WHERE vgpos EQ xvbfs-posnr.
        EXIT.
      ENDLOOP.
      CALL FUNCTION 'MESSAGE_STORE'
        EXPORTING
          arbgb                  = 'ME'
          msgty                  = 'I'
          msgv1                  = xkomdlgn-matnr
          msgv2                  = xkomdlgn-werks
          msgv3                  = xkomdlgn-lifnr
          txtnr                  = '157'
          zeile                  = count1
        EXCEPTIONS
          message_type_not_valid
          not_active.
      IF sy-subrc NE 0.
        CONTINUE.
      ENDIF.
      count1 = count1 + 1.
      CALL FUNCTION 'MESSAGE_STORE'
        EXPORTING
          arbgb                  = xvbfs-msgid
          msgty                  = xvbfs-msgty
          msgv1                  = xvbfs-msgv1
          msgv2                  = xvbfs-msgv2
          msgv3                  = xvbfs-msgv3
          msgv4                  = xvbfs-msgv4
          txtnr                  = xvbfs-msgno
          zeile                  = count1
        EXCEPTIONS
          message_type_not_valid
          not_active.
      IF sy-subrc NE 0.
        CONTINUE.
      ENDIF.
      count1 = count1 + 1.
    ENDIF.
  ENDLOOP.

*  if p_test is initial.
  LOOP AT xlips.    "xvbls                                  "neu
    AT NEW vbeln. "vbeln_lif.                          "neu
      CALL FUNCTION 'MESSAGE_STORE'
        EXPORTING
          arbgb                  = 'VL'
          msgty                  = 'I'
          msgv1                  = '인바운드 납품'
          msgv2                  = xlips-vbeln
          msgv3                  = space
          msgv4                  = space
          txtnr                  = '311'
          zeile                  = count
        EXCEPTIONS
          message_type_not_valid
          not_active.
      IF sy-subrc NE 0.
        CONTINUE.
      ENDIF.
      count = count + 1.
    ENDAT.
  ENDLOOP.
*  else.
**- da es keine Lieferungsnummern gibt, wird auch kein Protokolleintrag
**- erzeugt. Es werden aber die Anzahl Lieferungen ermittelt
*    loop at fxlips.
*      at new vbeln.
*        count = count + 1.
*      endat.
*    endloop.
*  endif.
ENDFORM.                    "protokoll_li
*&---------------------------------------------------------------------*
*&      Form  CREATE_INBOUND_DELIVERY
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM create_inbound_delivery .

*-  Lieferant und Belegtyp lesen -> nur Bestellungen und Lieferpl?e
  CALL FUNCTION 'ME_EKKO_SINGLE_READ'
    EXPORTING
      pi_ebeln         = xekpo_short-ebeln
    IMPORTING
      po_ekko          = ekko
    EXCEPTIONS
      no_records_found = 1
      OTHERS           = 2.
  IF sy-subrc EQ 0 AND
 ( ekko-bstyp EQ 'F' OR ekko-bstyp EQ 'L' ) AND
   ekko-frgrl IS INITIAL AND ekko-memory IS INITIAL.
*- disporelevante Mengen und Termine ermitteln. In XEKET stehen nur
*- disporel. Mengen > 0 und sowohl Einteilungen als auch Best?igungen
*      CALL FUNCTION 'ME_CONFIRMATION_ANL_QTY'
    CALL FUNCTION 'Z_TI_CONFIRMATION_ANL_QTY'
      EXPORTING
        i_ebeln = xekpo_short-ebeln
        i_ebelp = xekpo_short-ebelp
        i_eindt = ztitcrk-cdcdt
        i_bstae = xekpo_short-bstae                         "n_631132
        i_uptyp = xekpo_short-uptyp                         "n_631132
      TABLES
        xeket   = xeket.

    IF NOT xeket[] IS INITIAL.
      PERFORM vbsk_fill.
      LOOP AT xeket.
*        open_qty = xeket-menge.
        open_qty    = xztitcrp-ccmng.
        xeket-eindt = ztitcrk-cdcdt.
        PERFORM xkomdlgn_fill USING open_qty xeket-eindt xeket-licha
                                             xeket-charg xeket-uzeit.
      ENDLOOP.
    ENDIF.
  ENDIF.
*---- bei Belegwechsel Lieferung erzeugen -----------------------------*

  IF NOT xkomdlgn[] IS INITIAL.
    CALL FUNCTION 'ENQUEUE_EMEKKOS'                         "v_598606
         EXPORTING
              ebeln          = xekpo_short-ebeln
         EXCEPTIONS
              foreign_lock   = 2
              system_failure = 3.
    CHECK sy-subrc = 0.                                     "^_598606

    CALL FUNCTION 'GN_DELIVERY_CREATE'
      EXPORTING
        vbsk_i   = xvbsk
      TABLES
        xkomdlgn = xkomdlgn
        xvbfs    = xvbfs
        xvbls    = xvbls
        xxlips   = xlips.

    READ TABLE xlips INDEX 1.
    IF xlips-vbeln IS INITIAL.
      MESSAGE w401 WITH xekpo_short-ebeln xekpo_short-ebelp.
      PERFORM protokoll_li.
    ELSE.
      xztitcrp-vbeln = xlips-vbeln.
      xztitcrp-posnr = xlips-posnr.
      MODIFY xztitcrp.
    ENDIF.

    CALL FUNCTION 'DEQUEUE_EMEKKOS'                         "598606
         EXPORTING                                          "598606
              ebeln = xekpo_short-ebeln.                    "598606

    REFRESH: xkomdlgn, xvbfs, xvbls, xlips, fxlips, fxlikp, fxvbfa,
             fxvbpa, fxvbuk, fxvbup, fyvbuk, fyvbup.

  ENDIF.

ENDFORM.                    " CREATE_INBOUND_DELIVERY
*&---------------------------------------------------------------------*
*&      Form  modify_inbound_delivery
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM modify_inbound_delivery .

*        MOVE: xZTITCCP-vbeln TO bbp_inbd_l-delivery,    ">문서번호
*              space           TO bbp_inbd_l-deliv_ext,   ">분배납품
*              ZTITCCK-cdrdt  TO bbp_inbd_l-deliv_date,  ">납품일
*              space           TO bbp_inbd_l-deliv_time,  ">납품시간
*              space           TO bbp_inbd_l-route,       ">운송경로
*              space           TO bbp_inbd_l-ship_point,  ">입하지점
*              space           TO bbp_inbd_l-whse_no,     ">창고번호
*              space           TO bbp_inbd_l-trans_cat,   ">운송수단유형
*              space           TO bbp_inbd_l-transp_id,   ">운송수단 ID
*              ZTITCCK-cblno  TO bbp_inbd_l-billoflad,   ">선하증권
*              ZTITCCK-ctowe  TO bbp_inbd_l-total_wght,  ">총중량
*              ZTITCCK-ctoweu TO bbp_inbd_l-unit_of_wt,  ">중량단위
*              0               TO bbp_inbd_l-net_weight,  ">순중량
*              space           TO bbp_inbd_l-volume,      ">볼륨
*              space           TO bbp_inbd_l-volumeunit,  ">부피단위
*              ZTITCCK-ctpkg  TO bbp_inbd_l-noshpunits.  ">포장 총계
*
*       MOVE: space             TO it_inb-delivery,  ">영업/유통
*             space             TO it_inb-deliv_item,">문서의 품목번호
*             xekpo_short-matnr TO it_inb-material,  ">자재번호
*             xekpo_short-idnlf TO it_inb-vend_mat,  ">공급업체 자재번호
*             xekpo_short-txz01 TO it_inb-matl_desc, ">자재내역
*             xZTITCCP-ccmng   TO it_inb-deliv_qty, ">실제수량납품
*             xekpo_short-meins TO it_inb-unit,      ">오더단위
*             xekpo_short-ebeln TO it_inb-po_number, ">구매전표번호
*             xekpo_short-ebelp TO it_inb-po_item.   ">구매문서 품목번호
*        APPEND it_inb.
*
*        CALL FUNCTION 'BBP_INB_DELIVERY_CREATE'
*          EXPORTING
*            is_inb_delivery_header = bbp_inbd_l
*          IMPORTING
*            ef_delivery            = xZTITCCP-vbeln
*          TABLES
*            it_inb_delivery_detail = it_inb
*            return                 = it_return.
*        READ TABLE it_inb INDEX 1.
*        IF sy-subrc EQ 0.
*          xZTITCCP-vbeln = xZTITCCP-vbeln.
*          xZTITCCP-posnr = xZTITCCP-posnr.
*          MODIFY xZTITCCP.
*        ENDIF.

  CALL FUNCTION 'BBP_INB_DELIVERY_GETDETAIL'
    EXPORTING
      if_delivery            = xztitcrp-vbeln
    IMPORTING
      es_inb_delivery_header = bbp_inbd_l
    TABLES
      et_inb_delivery_detail = it_inb
      return                 = it_return.

  IF it_return[] IS INITIAL.
    CALL FUNCTION 'BBP_INB_DELIVERY_UPDATE'
      EXPORTING
        if_delivery            = xztitcrp-vbeln
        if_deliv_date          = ztitcrk-cdcdt
        if_deliv_time          = '000000'
      TABLES
        it_inb_delivery_detail = it_inb
        return                 = it_return.
  ENDIF.

ENDFORM.                    " modify_inbound_delivery
*&---------------------------------------------------------------------*
*&      Form  get_inb_delivery_order
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_inb_delivery_order .

  REFRESH: it_pokey.
  LOOP AT xztitcrp WHERE ebeln NE space.
    IF xztitcrp-vbeln IS INITIAL.
      MOVE-CORRESPONDING xztitcrp TO it_pokey.
      APPEND it_pokey.
    ENDIF.
  ENDLOOP.
  CHECK sy-subrc EQ 0.

  SELECT ebeln ebelp menge meins matnr werks lgort bstae loekz elikz
         lmein umrez umren insmk pstyp sobkz knttp kzfme kzvbr
         ematn mfrnr mfrpn emnfr cuobj uebto untto uebtk bwtar idnlf
         txz01 mfrgr gewei voleh ntgew brgew volum ean11 aktnr abeln
         abelp aurel matkl upvor uptyp uebpo wepos
    INTO CORRESPONDING FIELDS OF TABLE xekpo_short
    FROM ekpo
     FOR ALL ENTRIES IN it_pokey
           WHERE ebeln EQ it_pokey-ebeln
             AND ebelp EQ it_pokey-ebelp
             AND bstae NE space
             AND loekz EQ space
             AND elikz EQ space
             AND retpo EQ space.

ENDFORM.                    " get_inb_delivery_order
*&---------------------------------------------------------------------*
*&      Form  delete_inb_deleted
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM delete_inb_deleted  USING    p_vbeln  p_subrc.

  DATA: l_subrc LIKE sy-subrc.
  DATA: l_if_null TYPE REF TO if_message_obj_mm.

  CHECK NOT p_vbeln IS INITIAL.

* Message preparations
  PERFORM  set_message_preparations.

  REFRESH: bdcdata.
  CLEAR: session.
  ctu_params-dismode  = 'N'. ">처리모드
  ctu_params-updmode  = 'S'. ">갱신모드
  ctu_params-cattmode = ' '. ">CATT 모드...
  ctu_params-defsize  = ' '. ">기본화면 크기
  ctu_params-racommit = 'X'.
  ctu_params-nobinpt  = ' ' .
  ctu_params-nobiend  = ' '.

  PERFORM bdc_dynpro_build USING :
         'X' 'SAPMV50A'          '4104',
         ' ' 'LIKP-VBELN'        p_vbeln,
         ' ' 'BDC_OKCODE'       '/00'.

  PERFORM bdc_dynpro_build USING :
         'X' 'SAPMV50A'          '1000',
         ' ' 'BDC_OKCODE'       '/ELOES_T'.

  PERFORM bdc_transaction USING 'VL32N' l_subrc.

  p_subrc = l_subrc.

  IF l_subrc EQ 0.
    zti_message sy-msgty sy-msgid sy-msgno
                sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ELSE.
    LOOP AT messtab WHERE msgtyp EQ 'E'.
      sy-msgno = messtab-msgnr.
      zti_message messtab-msgtyp messtab-msgid sy-msgno
          messtab-msgv1 messtab-msgv2 messtab-msgv3 messtab-msgv4.
    ENDLOOP.
    IF sy-subrc NE 0.
      MESSAGE s926.
      zti_message sy-msgty sy-msgid sy-msgno
                  sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.
  ENDIF.

ENDFORM.                    " delete_inb_deleted
