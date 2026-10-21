************************************************************************
* Title         :  ZTIRCOMM                                            *
*                                                                      *
* Description   : Import Sub Routine Pool                              *
*                                                                      *
* Creation Date : 2004/03/12                                           *
*                                                                      *
* Author        : SeogBong, Kang                                       *
*                 Copyright ⓒ ASEG Co., LTD. All rights reserved.     *
************************************************************************

PROGRAM  ztircomm.

TABLES: t001,
        dfies,
        ztitlg1,
        ztstedis.

INCLUDE <icon>.

TABLES: *ztitrqk,
        *ztitblk,
        *ztitivk,
        *ztitpnk,
*        *ztitivd,
*        *ztitblo,
        *ztitcrk,
        *ztitcck,
        *ztitgrk,
        *ztitcsk,
        *ztitvak,
        *ztitack,
        *ztittxk,
        *ztitbsk,
        *ztitbik,
        *ztitbok,
        *ztitip1,
        *ztitlg1.


DATA : g_subrc   TYPE sy-subrc.

*&---------------------------------------------------------------------*
*&      Form  CHECK_DOMAIN_VALUES
*&---------------------------------------------------------------------*
*       Domain value check
*----------------------------------------------------------------------*
FORM check_domain_values  USING    p_domain LIKE  dd07l-domname
                                   p_value.

  CALL FUNCTION 'CHECK_DOMAIN_VALUES'
    EXPORTING
      domname       = p_domain
      value         = p_value
    EXCEPTIONS
      no_domname    = 1
      wrong_value   = 2
      dom_not_found = 3
      OTHERS        = 4.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

ENDFORM.                    " CHECK_DOMAIN_VALUES
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
*&      Form  SHOW_PROGRESS_bar
*&---------------------------------------------------------------------*
FORM show_progress_bar USING  text perc.

  CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
    EXPORTING
      percentage = perc
      text       = text.

ENDFORM.                    " SHOW_PROGRESS_bar

*&---------------------------------------------------------------------*
*&      Form  read_customer_name_only
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM read_customer_name_only  USING    p_kunnr
                              CHANGING p_name.

  CLEAR p_name.
  CHECK NOT p_kunnr IS INITIAL.

  SELECT SINGLE name1
    INTO (p_name)
    FROM kna1
   WHERE kunnr EQ p_kunnr.


ENDFORM.                    " read_customer_name_only

*&---------------------------------------------------------------------*
*&      Form  read_vendor_name_only
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM read_vendor_name_only  USING    p_lifnr
                            CHANGING p_name.

  CLEAR p_name.
  CHECK NOT p_lifnr IS INITIAL.

  SELECT SINGLE name1
    INTO (p_name)
    FROM lfa1
   WHERE lifnr EQ p_lifnr.


ENDFORM.                    " read_vendor_name_only


*&---------------------------------------------------------------------*
*&      Form  GET_F4_FOR_ZTERM
*&---------------------------------------------------------------------*
FORM get_f4_for_zterm USING    p_zterm.
  DATA: l_zterm LIKE t052-zterm.
  CALL FUNCTION 'FI_F4_ZTERM'
    EXPORTING
      i_koart       = 'K'
      i_zterm       = p_zterm
      i_xshow       = ' '
    IMPORTING
      e_zterm       = l_zterm
    EXCEPTIONS
      nothing_found = 01.

  IF sy-subrc NE 0.
    MESSAGE s177(06) WITH p_zterm.
    EXIT.
  ENDIF.

  IF l_zterm NE space.
    p_zterm = l_zterm.
  ENDIF.

ENDFORM.                    " GET_F4_FOR_ZTERM

*&---------------------------------------------------------------------*
*&      Form  get_used_payment_term
*&---------------------------------------------------------------------*
FORM get_used_payment_term  TABLES   p_it_ztitig02 STRUCTURE ztitig02
                            USING    p_subrc  p_type.

  CLEAR: p_subrc.

  SELECT *
    FROM ztitig02
    INTO CORRESPONDING FIELDS OF TABLE p_it_ztitig02.

  p_subrc = sy-subrc.

  IF p_subrc NE 0.
    MESSAGE ID 'ZMTI00' TYPE p_type NUMBER 001.
    EXIT.
  ENDIF.

ENDFORM.                    " get_used_payment_term

*&---------------------------------------------------------------------*
*&      Form  get_f4_for_zterm_DYNPRO
*&---------------------------------------------------------------------*
FORM get_f4_for_zterm_dynpro  USING    p_zterm LIKE t052-zterm.
  DATA: l_zterm LIKE t052-zterm.
  IF screen-input EQ '1'.
    CALL FUNCTION 'FI_F4_ZTERM'
      EXPORTING
        i_koart       = 'K'
        i_zterm       = p_zterm
        i_xshow       = ' '
      IMPORTING
        e_zterm       = l_zterm
      EXCEPTIONS
        nothing_found = 01.
  ELSE.
    CALL FUNCTION 'FI_F4_ZTERM'
      EXPORTING
        i_koart       = 'K'
        i_zterm       = p_zterm
        i_xshow       = 'X'
      IMPORTING
        e_zterm       = l_zterm
      EXCEPTIONS
        nothing_found = 01.
  ENDIF.

  IF sy-subrc NE 0.
    MESSAGE s177(06) WITH p_zterm.
    EXIT.
  ENDIF.

  IF l_zterm NE space.
    p_zterm = l_zterm.
  ENDIF.

ENDFORM.                    " get_f4_for_zterm_DYNPRO

*&---------------------------------------------------------------------*
*&      Form  change_vendor_account
*&---------------------------------------------------------------------*
FORM change_vendor_account  USING    p_lifnr LIKE lfb1-lifnr
                                    p_bukrs LIKE lfb1-bukrs
                                    p_akont LIKE lfb1-akont
                                    p_txt50 LIKE skat-txt50.
  CLEAR p_txt50.
  SELECT SINGLE akont
    INTO p_akont
    FROM lfb1
   WHERE lifnr = p_lifnr
     AND bukrs = p_bukrs.
  IF sy-subrc EQ 0.
    SELECT SINGLE txt50
      INTO p_txt50
      FROM skat
     WHERE spras = sy-langu
       AND saknr = p_akont.
  ENDIF.

ENDFORM.                    " change_vendor_account


*&---------------------------------------------------------------------*
*&      Form  change_recon_account
*&---------------------------------------------------------------------*
FORM change_recon_account  USING    p_lifnr LIKE lfb1-lifnr
                                    p_bukrs LIKE lfb1-bukrs
                                    p_akont LIKE lfb1-akont
                                    p_txt50 LIKE skat-txt50.
  DATA: l_count TYPE i.
  DATA: ls_skb1 TYPE skb1.
  DATA: ly_akont LIKE lfb1-akont.
*------- Abstimmkonto vorhanden ? --------------------------------------
  SELECT SINGLE * FROM skb1 INTO ls_skb1 WHERE saknr = p_akont
                                       AND   bukrs = p_bukrs.
  IF sy-subrc NE 0.
    MESSAGE e081(f2) WITH p_akont p_bukrs.
  ENDIF.

*------- ist eingegebene Kontonummer zulaessig ? -----------------------
  IF ls_skb1-mitkz NE 'K'.
    MESSAGE e068(f2) WITH ls_skb1-saknr ls_skb1-bukrs 'K'.
  ENDIF.

  SELECT SINGLE akont
    INTO ly_akont
    FROM lfb1
   WHERE lifnr = p_lifnr
     AND bukrs = p_bukrs.

  CHECK p_akont NE ly_akont.

  CLEAR l_count.
  SELECT COUNT( * )
    INTO l_count
    FROM lfc1
   WHERE lifnr = p_lifnr
     AND bukrs = p_bukrs.
  IF l_count = 0.
    SELECT COUNT( * )
      INTO l_count
      FROM lfc3
     WHERE lifnr = p_lifnr
       AND bukrs = p_bukrs.
  ENDIF.
  IF l_count <> 0.
    MESSAGE w067(f2).
  ENDIF.

ENDFORM.                    "change_recon_account

*&---------------------------------------------------------------------*
*&      Form  help_recon_account
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_SCRNAME  text
*      -->P_BUKRS    text
*      -->P_AKONT    text
*----------------------------------------------------------------------*
FORM help_recon_account USING p_scrname
                              p_bukrs LIKE lfb1-bukrs
                              p_akont LIKE lfb1-akont
                              p_txt50 LIKE skat-txt50.
  DATA: l_akont LIKE lfb1-akont,
        l_xshow.

  PERFORM fieldstatus_check USING p_scrname
                                  l_xshow.

*------ Abstimmkonten anzeigen -----------------------------------------
  CALL FUNCTION 'FI_F4_AKONT'
    EXPORTING
      i_bukrs = p_bukrs
      i_mitkz = 'K'
      i_akont = p_akont
      i_xshow = l_xshow
    IMPORTING
      e_akont = l_akont.
  IF NOT l_akont IS INITIAL.
 "CCM : 2023.04.12  ZITCS4HDEV04 -  MATNR과 관련 없음 (확인 완료)
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        input  = l_akont
      IMPORTING
        output = p_akont.

 IF sy-subrc <> 0.
* Implement suitable error handling here
 ENDIF.


    CLEAR p_txt50.
    SELECT SINGLE txt50
      INTO p_txt50
      FROM skat
     WHERE spras = sy-langu
       AND saknr = p_akont.
  ENDIF.

ENDFORM.                    "help_recon_account

*&---------------------------------------------------------------------*
*&      Form  fieldstatus_check
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->FNAME      text
*      -->XSHOW      text
*----------------------------------------------------------------------*
FORM fieldstatus_check USING fname xshow.
  LOOP AT SCREEN.
    CHECK screen-name = fname.
    IF screen-input = 0.
      xshow = 'X'.
    ELSE.
      xshow = space.
    ENDIF.
    EXIT.
  ENDLOOP.
ENDFORM.                    "FIELDSTATUS_CHECK


*&---------------------------------------------------------------------*
*&      Form  display_purchase_order
*&---------------------------------------------------------------------*
FORM display_purchase_order  USING    p_ebeln  LIKE ekpo-ebeln
                                      p_ebelp.
  DATA: l_ebelp  LIKE ekpo-ebelp.
  l_ebelp = p_ebelp.
  CHECK NOT p_ebeln IS INITIAL.
  IF sy-binpt IS INITIAL.
    SET PARAMETER ID 'ENJ_CALL_ME23N' FIELD 'X'.
  ELSE.
    SET PARAMETER ID 'ENJ_CALL_ME23N' FIELD space.
  ENDIF.
  CLEAR: sy-binpt .

  CALL FUNCTION 'ME_DISPLAY_PURCHASE_DOCUMENT'
    EXPORTING
      i_ebeln              = p_ebeln
      i_ebelp              = l_ebelp
      i_enjoy              = 'X'
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
*&      Form  set_po_lock_object
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM set_po_lock_object  USING    p_ebeln
                                  p_ebelp
                                  p_mode
                                  p_errmode
                                  p_check.
  CLEAR: p_check.

  IF p_mode EQ 'L'.
    CALL FUNCTION 'ENQUEUE_EMEKKOE'
      EXPORTING
        mandt          = sy-mandt
        ebeln          = p_ebeln
        ebelp          = p_ebelp
      EXCEPTIONS
        foreign_lock   = 1
        system_failure = 2
        OTHERS         = 3.
    IF sy-subrc <> 0.
      p_check = 'X'.

      MESSAGE s247(vl) WITH p_ebeln sy-uname.

      MESSAGE ID sy-msgid TYPE p_errmode NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.
  ELSE.
    CALL FUNCTION 'DEQUEUE_EMEKKOE'
      EXPORTING
        mandt = sy-mandt
        ebeln = p_ebeln
        ebelp = p_ebelp.
  ENDIF.

ENDFORM.                    " set_po_lock_object
*&---------------------------------------------------------------------*
*&      Form  set_lc_lock_object
*&---------------------------------------------------------------------*
*       Import request Lock/Unlock routine
*----------------------------------------------------------------------*
FORM set_lc_lock_object  USING    p_reqno
                                  p_amdsq
                                  p_reqit
                                  p_mode
                                  p_errmode
                                  p_check.
  CLEAR: p_check.

  IF p_mode EQ 'L'.
    CALL FUNCTION 'ENQUEUE_EZ_TI_ZTITRQK'
      EXPORTING
        mandt          = sy-mandt
        reqno          = p_reqno
        amdsq          = p_amdsq
        reqit          = p_reqit
      EXCEPTIONS
        foreign_lock   = 1
        system_failure = 2
        OTHERS         = 3.
    IF sy-subrc <> 0.
      p_check = 'X'.
      MESSAGE ID sy-msgid TYPE p_errmode NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.
  ELSE.
    CALL FUNCTION 'DEQUEUE_EZ_TI_ZTITRQK'
      EXPORTING
        mandt = sy-mandt
        reqno = p_reqno
        amdsq = p_amdsq
        reqit = p_reqit.
  ENDIF.

ENDFORM.                    " set_LC_lock_object
*&---------------------------------------------------------------------*
*&      Form  set_bl_lock_object
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM set_bl_lock_object  USING    p_iblno
                                  p_iblit
                                  p_mode
                                  p_errmode
                                  p_check.
  CLEAR: p_check.

  IF p_mode EQ 'L'.
    CALL FUNCTION 'ENQUEUE_EZ_TI_ZTITBLK'
      EXPORTING
        mandt          = sy-mandt
        iblno          = p_iblno
        iblit          = p_iblit
      EXCEPTIONS
        foreign_lock   = 1
        system_failure = 2
        OTHERS         = 3.
    IF sy-subrc <> 0.
      p_check = 'X'.
      MESSAGE ID sy-msgid TYPE p_errmode NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.
  ELSE.
    CALL FUNCTION 'DEQUEUE_EZ_TI_ZTITBLK'
      EXPORTING
        mandt = sy-mandt
        iblno = p_iblno
        iblit = p_iblit.
  ENDIF.

ENDFORM.                    " set_bl_lock_object
*&---------------------------------------------------------------------*
*&      Form  set_iv_lock_object
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM set_iv_lock_object  USING    p_ivono
                                  p_rblgp
                                  p_mode
                                  p_errmode
                                  p_check.
  CLEAR: p_check.

  IF p_mode EQ 'L'.
    CALL FUNCTION 'ENQUEUE_EZ_TI_ZTITIVK'
      EXPORTING
        mandt          = sy-mandt
        ivono          = p_ivono
        rblgp          = p_rblgp
      EXCEPTIONS
        foreign_lock   = 1
        system_failure = 2
        OTHERS         = 3.
    IF sy-subrc <> 0.
      p_check = 'X'.
      MESSAGE ID sy-msgid TYPE p_errmode NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.
  ELSE.
    CALL FUNCTION 'DEQUEUE_EZ_TI_ZTITIVK'
      EXPORTING
        mandt = sy-mandt
        ivono = p_ivono
        rblgp = p_rblgp.
  ENDIF.

ENDFORM.                    " set_iv_lock_object
*&---------------------------------------------------------------------*
*&      Form  set_cc_lock_object
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM set_cc_lock_object  USING    p_iccno
                                  p_iccsq
                                  p_iccit
                                  p_mode
                                  p_errmode
                                  p_check.
  CLEAR: p_check.

  IF p_mode EQ 'L'.
    CALL FUNCTION 'ENQUEUE_EZ_TI_ZTITCCK'
      EXPORTING
        mandt          = sy-mandt
        iccno          = p_iccno
        iccsq          = p_iccsq
        iccit          = p_iccit
      EXCEPTIONS
        foreign_lock   = 1
        system_failure = 2
        OTHERS         = 3.
    IF sy-subrc <> 0.
      p_check = 'X'.
      MESSAGE ID sy-msgid TYPE p_errmode NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.
  ELSE.
    CALL FUNCTION 'DEQUEUE_EZ_TI_ZTITCCK'
      EXPORTING
        mandt = sy-mandt
        iccno = p_iccno
        iccsq = p_iccsq
        iccit = p_iccit.
  ENDIF.

ENDFORM.                    " set_cc_lock_object
*&---------------------------------------------------------------------*
*&      Form  set_ip_lock_object
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM set_ip_lock_object  USING    p_iipno
                                  p_amdsq
                                  p_mode
                                  p_errmode
                                  p_check.
  CLEAR: p_check.

  IF p_mode EQ 'L'.
    CALL FUNCTION 'ENQUEUE_EZ_TI_ZTITIP1'
      EXPORTING
        mandt          = sy-mandt
        iipno          = p_iipno
        amdsq          = p_amdsq
      EXCEPTIONS
        foreign_lock   = 1
        system_failure = 2
        OTHERS         = 3.
    IF sy-subrc <> 0.
      p_check = 'X'.
      MESSAGE ID sy-msgid TYPE p_errmode NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.
  ELSE.
    CALL FUNCTION 'DEQUEUE_EZ_TI_ZTITIP1'
      EXPORTING
        mandt = sy-mandt
        iipno = p_iipno
        amdsq = p_amdsq.
  ENDIF.

ENDFORM.                    " set_ip_lock_object
*&---------------------------------------------------------------------
*
*&      Form  set_vs_lock_object
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM set_vs_lock_object  USING    p_ivsno
                                  p_mode
                                  p_errmode
                                  p_check.
  CLEAR: p_check.

  IF p_mode EQ 'L'.
    CALL FUNCTION 'ENQUEUE_EZ_TI_ZTITVSK'
      EXPORTING
        mandt          = sy-mandt
        ivsno          = p_ivsno
      EXCEPTIONS
        foreign_lock   = 1
        system_failure = 2
        OTHERS         = 3.
    IF sy-subrc <> 0.
      p_check = 'X'.
      MESSAGE ID sy-msgid TYPE p_errmode NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.
  ELSE.
    CALL FUNCTION 'DEQUEUE_EZ_TI_ZTITVSK'
      EXPORTING
        mandt = sy-mandt
        ivsno = p_ivsno.

  ENDIF.

ENDFORM.                    " set_vs_lock_object

*&---------------------------------------------------------------------*
*&      Form  set_pn_lock_object
*&---------------------------------------------------------------------*
*       Notice Lock Object.
*----------------------------------------------------------------------*
FORM set_pn_lock_object  USING    p_pntno
                                  p_pntit
                                  p_mode
                                  p_errmode
                                  p_check.
  CLEAR: p_check.

  IF p_mode EQ 'L'.
    CALL FUNCTION 'ENQUEUE_EZ_TI_ZTITPNK'
      EXPORTING
        mandt          = sy-mandt
        pntno          = p_pntno
        pntit          = p_pntit
      EXCEPTIONS
        foreign_lock   = 1
        system_failure = 2
        OTHERS         = 3.
    IF sy-subrc <> 0.
      p_check = 'X'.
      MESSAGE ID sy-msgid TYPE p_errmode NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.
  ELSE.
    CALL FUNCTION 'DEQUEUE_EZ_TI_ZTITPNK'
      EXPORTING
        mandt = sy-mandt
        pntno = p_pntno
        pntit = p_pntit.
  ENDIF.

ENDFORM.                    " set_pn_lock_object

*&---------------------------------------------------------------------*
*&      Form  set_lg_lock_object
*&---------------------------------------------------------------------*
*       L/G Lock Object.
*----------------------------------------------------------------------*
FORM set_lg_lock_object  USING    p_ilgno
                                  p_mode
                                  p_errmode
                                  p_check.
  CLEAR: p_check.

  IF p_mode EQ 'L'.
    CALL FUNCTION 'ENQUEUE_EZ_TI_ZTITLG1'
      EXPORTING
        mandt          = sy-mandt
        ilgno          = p_ilgno
      EXCEPTIONS
        foreign_lock   = 1
        system_failure = 2
        OTHERS         = 3.
    IF sy-subrc <> 0.
      p_check = 'X'.
      MESSAGE ID sy-msgid TYPE p_errmode NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.
  ELSE.
    CALL FUNCTION 'DEQUEUE_EZ_TI_ZTITLG1'
      EXPORTING
        mandt = sy-mandt
        ilgno = p_ilgno.
  ENDIF.

ENDFORM.                    " set_lg_lock_object
*&---------------------------------------------------------------------*
*&      Form  set_mf_lock_object
*&---------------------------------------------------------------------*
*       Manifast Lock Object.
*----------------------------------------------------------------------*
FORM set_mf_lock_object  USING    p_imfno
                                  p_mode
                                  p_errmode
                                  p_check.
  CLEAR: p_check.

  IF p_mode EQ 'L'.
    CALL FUNCTION 'ENQUEUE_EZ_TI_ZTITMFK'
      EXPORTING
        mandt          = sy-mandt
        imfno          = p_imfno
      EXCEPTIONS
        foreign_lock   = 1
        system_failure = 2
        OTHERS         = 3.
    IF sy-subrc <> 0.
      p_check = 'X'.
      MESSAGE ID sy-msgid TYPE p_errmode NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.
  ELSE.
    CALL FUNCTION 'DEQUEUE_EZ_TI_ZTITMFK'
      EXPORTING
        mandt = sy-mandt
        imfno = p_imfno.
  ENDIF.

ENDFORM.                    " set_mf_lock_object

*&---------------------------------------------------------------------*
*&      Form  set_RT_lock_object
*&---------------------------------------------------------------------*
*       Return Lock Object.
*----------------------------------------------------------------------*
FORM set_rt_lock_object  USING    p_ryear
                                  p_retno
                                  p_mode
                                  p_errmode
                                  p_check.
  CLEAR: p_check.

  IF p_mode EQ 'L'.
    CALL FUNCTION 'ENQUEUE_EZ_TI_ZTITRTK'
      EXPORTING
        mandt          = sy-mandt
        ryear          = p_ryear
        retno          = p_retno
      EXCEPTIONS
        foreign_lock   = 1
        system_failure = 2
        OTHERS         = 3.
    IF sy-subrc <> 0.
      p_check = 'X'.
      MESSAGE ID sy-msgid TYPE p_errmode NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.
  ELSE.
    CALL FUNCTION 'DEQUEUE_EZ_TI_ZTITRTK'
      EXPORTING
        mandt = sy-mandt
        ryear = p_ryear
        retno = p_retno.
  ENDIF.

ENDFORM.                    " set_RT_lock_object
*&---------------------------------------------------------------------*
*&      Form  set_gr_lock_object
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM set_gr_lock_object  USING    p_igrno
                                  p_mode
                                  p_errmode
                                  p_check.
  CLEAR: p_check.

  IF p_mode EQ 'L'.
    CALL FUNCTION 'ENQUEUE_EZ_TI_ZTITRRK'
      EXPORTING
        mandt          = sy-mandt
        igrno          = p_igrno
      EXCEPTIONS
        foreign_lock   = 1
        system_failure = 2
        OTHERS         = 3.
    IF sy-subrc <> 0.
      p_check = 'X'.
      MESSAGE ID sy-msgid TYPE p_errmode NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.
  ELSE.
    CALL FUNCTION 'DEQUEUE_EZ_TI_ZTITRRK'
      EXPORTING
        mandt = sy-mandt
        igrno = p_igrno.
  ENDIF.

ENDFORM.                    " set_gr_lock_object

*&---------------------------------------------------------------------*
*&      Form  set_tx_lock_object
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM set_tx_lock_object  USING    p_taxno
                                  p_mode
                                  p_errmode
                                  p_check.
  CLEAR: p_check.

  IF p_mode EQ 'L'.
    CALL FUNCTION 'ENQUEUE_EZ_TI_ZTITTXK'
      EXPORTING
        mandt          = sy-mandt
        taxno          = p_taxno
      EXCEPTIONS
        foreign_lock   = 1
        system_failure = 2
        OTHERS         = 3.
    IF sy-subrc <> 0.
      p_check = 'X'.
      MESSAGE ID sy-msgid TYPE p_errmode NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.
  ELSE.
    CALL FUNCTION 'DEQUEUE_EZ_TI_ZTITTXK'
      EXPORTING
        mandt = sy-mandt
        taxno = p_taxno.
  ENDIF.

ENDFORM.                    " set_tx_lock_object

*&---------------------------------------------------------------------*
*&      Form  set_ac_lock_object
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM set_ac_lock_object  USING    p_acdno
                                  p_mode
                                  p_errmode
                                  p_check.
  CLEAR: p_check.

  IF p_mode EQ 'L'.
    CALL FUNCTION 'ENQUEUE_EZ_TI_ZTITACK'
      EXPORTING
        mandt          = sy-mandt
        acdno          = p_acdno
      EXCEPTIONS
        foreign_lock   = 1
        system_failure = 2
        OTHERS         = 3.
    IF sy-subrc <> 0.
      p_check = 'X'.
      MESSAGE ID sy-msgid TYPE p_errmode NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.
  ELSE.
    CALL FUNCTION 'DEQUEUE_EZ_TI_ZTITACK'
      EXPORTING
        mandt = sy-mandt
        acdno = p_acdno.
  ENDIF.

ENDFORM.                    " set_ac_lock_object
*&---------------------------------------------------------------------*
*&      Form  set_va_lock_object
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM set_va_lock_object  USING    p_vatno
                                  p_rblgp
                                  p_mode
                                  p_errmode
                                  p_check.
  CLEAR: p_check.

  IF p_mode EQ 'L'.
    CALL FUNCTION 'ENQUEUE_EZ_TI_ZTITVAK'
      EXPORTING
        mandt          = sy-mandt
        vatno          = p_vatno
      EXCEPTIONS
        foreign_lock   = 1
        system_failure = 2
        OTHERS         = 3.
    IF sy-subrc <> 0.
      p_check = 'X'.
      MESSAGE ID sy-msgid TYPE p_errmode NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.
  ELSE.
    CALL FUNCTION 'DEQUEUE_EZ_TI_ZTITACK'
      EXPORTING
        mandt = sy-mandt
        vatno = p_vatno.
  ENDIF.

ENDFORM.                    " set_va_lock_object

*&---------------------------------------------------------------------*
*&      Form  set_cs_lock_object
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM set_cs_lock_object  USING    p_bukrs
                                  p_icsno
                                  p_mode
                                  p_errmode
                                  p_check.
  CLEAR: p_check.

  IF p_mode EQ 'L'.
    CALL FUNCTION 'ENQUEUE_EZ_TI_ZTITCSK'
      EXPORTING
        mandt          = sy-mandt
        bukrs          = p_bukrs
        icsno          = p_icsno
      EXCEPTIONS
        foreign_lock   = 1
        system_failure = 2
        OTHERS         = 3.
    IF sy-subrc <> 0.
      p_check = 'X'.
      MESSAGE ID sy-msgid TYPE p_errmode NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.
  ELSE.
    CALL FUNCTION 'DEQUEUE_EZ_TI_ZTITCSK'
      EXPORTING
        mandt = sy-mandt
        bukrs = p_bukrs
        icsno = p_icsno.
  ENDIF.

ENDFORM.                    " set_cs_lock_object
*&---------------------------------------------------------------------*
*&      Form  set_bd_lock_object
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM set_bd_lock_object  USING    p_iccno
                                  p_bdseq
                                  p_mode
                                  p_errmode
                                  p_check.
  CLEAR: p_check.

  IF p_mode EQ 'L'.
    CALL FUNCTION 'ENQUEUE_EZ_TI_ZTITBDK'
      EXPORTING
        mandt          = sy-mandt
        iccno          = p_iccno
        bdseq          = p_bdseq
      EXCEPTIONS
        foreign_lock   = 1
        system_failure = 2
        OTHERS         = 3.
    IF sy-subrc <> 0.
      p_check = 'X'.
      MESSAGE ID sy-msgid TYPE p_errmode NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.
  ELSE.
    CALL FUNCTION 'DEQUEUE_EZ_TI_ZTITBDK'
      EXPORTING
        mandt = sy-mandt
        iccno = p_iccno
        bdseq = p_bdseq.
  ENDIF.

ENDFORM.                    " set_bd_lock_object

*&---------------------------------------------------------------------*
*&      Form  set_BS_lock_object
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM set_bs_lock_object  USING    p_ibsno
                                  p_ibsit
                                  p_mode
                                  p_errmode
                                  p_check.
  CLEAR: p_check.

  IF p_mode EQ 'L'.
    CALL FUNCTION 'ENQUEUE_EZ_TI_ZTITBSK'
      EXPORTING
        mandt          = sy-mandt
        ibsno          = p_ibsno
        ibsit          = p_ibsit
      EXCEPTIONS
        foreign_lock   = 1
        system_failure = 2
        OTHERS         = 3.
    IF sy-subrc <> 0.
      p_check = 'X'.
      MESSAGE ID sy-msgid TYPE p_errmode NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.
  ELSE.
    CALL FUNCTION 'DEQUEUE_EZ_TI_ZTITBSK'
      EXPORTING
        mandt = sy-mandt
        ibsno = p_ibsno
        ibsit = p_ibsit.
  ENDIF.

ENDFORM.                    " set_BS_lock_object


*&---------------------------------------------------------------------*
*&      Form  set_bi_lock_object
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM set_bi_lock_object  USING    p_ibino
                                  p_ibiit
                                  p_mode
                                  p_errmode
                                  p_check.
  CLEAR: p_check.

  IF p_mode EQ 'L'.
    CALL FUNCTION 'ENQUEUE_EZ_TI_ZTITBIK'
      EXPORTING
        mandt          = sy-mandt
        ibino          = p_ibino
        ibiit          = p_ibiit
      EXCEPTIONS
        foreign_lock   = 1
        system_failure = 2
        OTHERS         = 3.
    IF sy-subrc <> 0.
      p_check = 'X'.
      MESSAGE ID sy-msgid TYPE p_errmode NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.
  ELSE.
    CALL FUNCTION 'DEQUEUE_EZ_TI_ZTITBIK'
      EXPORTING
        mandt = sy-mandt
        ibino = p_ibino
        ibiit = p_ibiit.
  ENDIF.

ENDFORM.                    " set_bI_lock_object


*&---------------------------------------------------------------------*
*&      Form  set_BO_lock_object
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM set_bo_lock_object  USING    p_ibono
                                  p_iboit
                                  p_mode
                                  p_errmode
                                  p_check.
  CLEAR: p_check.

  IF p_mode EQ 'L'.
    CALL FUNCTION 'ENQUEUE_EZ_TI_ZTITBOK'
      EXPORTING
        mandt          = sy-mandt
        ibono          = p_ibono
        iboit          = p_iboit
      EXCEPTIONS
        foreign_lock   = 1
        system_failure = 2
        OTHERS         = 3.
    IF sy-subrc <> 0.
      p_check = 'X'.
      MESSAGE ID sy-msgid TYPE p_errmode NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.
  ELSE.
    CALL FUNCTION 'DEQUEUE_EZ_TI_ZTITBOK'
      EXPORTING
        mandt = sy-mandt
        ibono = p_ibono
        iboit = p_iboit.
  ENDIF.

ENDFORM.                    " set_BO_lock_object

*&---------------------------------------------------------------------*
*&      Form  DISPLAY_MATERIAL_MASTER
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
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
*&      Form  DISPLAY_INVENTORY_OVERVIEW
*&---------------------------------------------------------------------*
FORM display_inventory_overview  USING    p_matnr
                                          p_werks
                                          p_lgort.
  CHECK NOT p_matnr IS INITIAL.

  CALL FUNCTION 'MMPUR_INVENTORY_DISPLAY'
    EXPORTING
      im_matnr              = p_matnr
      im_werks              = p_werks
      im_lgort              = p_lgort
    EXCEPTIONS
      system_failure        = 1
      communication_failure = 2
      OTHERS                = 3.

  IF sy-subrc NE 0.
    MESSAGE s303(me) WITH space space space space.
  ELSE.
    MESSAGE s014(mepo).
  ENDIF.

ENDFORM.                    " DISPLAY_INVENTORY_OVERVIEW
*&---------------------------------------------------------------------*
*&      Form  display_STOCK_AND_requirement
*&---------------------------------------------------------------------*
*       Stock/Requirement list. ( MD04 )
*----------------------------------------------------------------------*
FORM display_stock_and_requirement  USING    p_matnr
                                             p_werks.

  CHECK : NOT p_matnr IS INITIAL AND
          NOT p_werks IS INITIAL.

  SET PARAMETER ID 'MAT' FIELD p_matnr.
  SET PARAMETER ID 'WRK' FIELD p_werks.
  CALL TRANSACTION 'MD04' AND SKIP FIRST SCREEN.


ENDFORM.                    " display_STOCK_AND_requirement
*&---------------------------------------------------------------------*
*&      Form  display_open_purchase_order
*&---------------------------------------------------------------------*
*        Open purchase order ( ME2M )
*----------------------------------------------------------------------*
FORM display_open_purchase_order  USING    p_matnr
                                           p_werks.

  CHECK : NOT p_matnr IS INITIAL AND
          NOT p_werks IS INITIAL.

  SUBMIT rm06em00
    WITH em_matnr EQ p_matnr
    WITH em_werks EQ p_werks
    WITH listu    EQ 'BEST'
    WITH selpa    EQ 'WE101'         " Parameter variable
    AND RETURN.

ENDFORM.                    " display_open_purchase_order
*&---------------------------------------------------------------------*
*&      Form  display_reservation
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM display_reservation  USING    p_rsnum
                                   p_rspos.

  CHECK NOT p_rsnum IS INITIAL.

  SET PARAMETER ID 'RES' FIELD p_rsnum.
  SET PARAMETER ID 'RPO' FIELD p_rspos.
  CALL TRANSACTION 'MB23' AND SKIP FIRST SCREEN.

ENDFORM.                    " display_reservation

*&---------------------------------------------------------------------*
*&      Form  display_material_document
*&---------------------------------------------------------------------*
*       Material Document List ( MB51 )
*----------------------------------------------------------------------*
FORM display_material_document  USING    p_matnr
                                         p_werks
                                         p_lgort
                                         p_lifnr.
  CHECK : NOT p_matnr IS INITIAL.

  SET PARAMETER ID 'MAT' FIELD p_matnr.
  SET PARAMETER ID 'WRK' FIELD p_werks.
  SET PARAMETER ID 'LAG' FIELD p_lgort. ">Stroge location
  SET PARAMETER ID 'LIF' FIELD p_lifnr.
  SET PARAMETER ID 'CHA' FIELD ''.      ">BATCH No.

  CALL TRANSACTION 'MB51' AND SKIP FIRST SCREEN.

ENDFORM.                    " display_material_document


*&---------------------------------------------------------------------*
*&      Form  display_material_doc_mb03
*&---------------------------------------------------------------------*
*----------------------------------------------------------------------*
FORM display_material_doc_mb03  USING    p_mblnr
                                    p_mjahr.
  CHECK : NOT p_mblnr IS INITIAL.

"CCM : 2023.04.17  ZITCS4HDEV04 - MIGO function으로 변경
*  SET PARAMETER ID 'MBN' FIELD p_mblnr.  "Year
*  SET PARAMETER ID 'MJA' FIELD p_mjahr.  "Doc No
*
*  CALL TRANSACTION 'MB03' AND SKIP FIRST SCREEN.
CALL FUNCTION 'MIGO_DIALOG'
 EXPORTING
   I_MBLNR                   = p_mblnr
   I_MJAHR                   = p_mjahr
 EXCEPTIONS
   ILLEGAL_COMBINATION       = 1
   OTHERS                    = 2.


ENDFORM.                    " display_material_doc_mb03
*&---------------------------------------------------------------------*
*&      Form  display_source_list
*&---------------------------------------------------------------------*
*       surce list( ME03 )
*----------------------------------------------------------------------*
FORM display_source_list  USING    p_matnr
                                   p_werks.

  CHECK : NOT p_matnr IS INITIAL AND
          NOT p_werks IS INITIAL.

  CALL FUNCTION 'MMPUR_SOURCE_LIST_DISPLAY'
    EXPORTING
      im_matnr = p_matnr
      im_werks = p_werks.

ENDFORM.                    " display_source_list
*&---------------------------------------------------------------------*
*&      Form  display_document_history
*&---------------------------------------------------------------------*
*       Processing management by document
*----------------------------------------------------------------------*
FORM display_document_history  USING    p_ebeln
                                        p_ebelp.

  CHECK NOT p_ebeln IS INITIAL.

  SUBMIT ztirh010
    WITH s_ebeln  EQ p_ebeln
    WITH s_ebelp  EQ p_ebelp
    AND RETURN.

ENDFORM.                    " display_document_history
*&---------------------------------------------------------------------*
*&      Form  DISPLAY_INB_DOCUMENT
*&---------------------------------------------------------------------*
*       Inbound delivery display
*----------------------------------------------------------------------*
FORM display_inb_document  USING    p_vbeln.

  CHECK NOT p_vbeln IS INITIAL.

  SET PARAMETER ID 'VLM' FIELD p_vbeln.

  CALL TRANSACTION 'VL33N' AND SKIP FIRST SCREEN.

ENDFORM.                    " DISPLAY_INB_DOCUMENT
*&---------------------------------------------------------------------*
*&      Form  DISPLAY_TD_SHIPMENT
*&---------------------------------------------------------------------*
*       Inbound delivery display
*----------------------------------------------------------------------*
FORM display_td_shipment  USING    p_shnumber.

  CHECK NOT p_shnumber IS INITIAL.

  SET PARAMETER ID 'OIS' FIELD p_shnumber.

  CALL TRANSACTION 'O4F3' AND SKIP FIRST SCREEN.

ENDFORM.                    " DISPLAY_TD_SHIPMENT
*&---------------------------------------------------------------------*
*&      Form  display_OUTB_order
*&---------------------------------------------------------------------*
FORM display_outb_order  USING    p_vbeln.

  CHECK NOT p_vbeln IS INITIAL.
  SET PARAMETER ID 'VL' FIELD p_vbeln.
  CALL TRANSACTION 'VL03N' AND SKIP FIRST SCREEN.

ENDFORM.                    " display_OUTB_order

*&---------------------------------------------------------------------*
*&      Form  display_quantity_history
*&---------------------------------------------------------------------*
*       Processing management by quantity
*----------------------------------------------------------------------*
FORM display_quantity_history  USING    p_ebeln
                                        p_ebelp.

  CHECK NOT p_ebeln IS INITIAL.

ENDFORM.                    " display_quantity_history

*&---------------------------------------------------------------------*
*&      Form  display_import_document
*&---------------------------------------------------------------------*
*       import request document is display
*----------------------------------------------------------------------*
FORM display_import_document  USING    p_reqno
                                       p_amdsq
                                       p_reqit.
  CHECK NOT p_reqno IS INITIAL.

  SET PARAMETER ID 'ZTIREQNO' FIELD p_reqno.
  SET PARAMETER ID 'ZTIAMDSQ' FIELD p_amdsq.
  SET PARAMETER ID 'ZTIREQIT' FIELD p_reqit.
  SET PARAMETER ID 'BES'      FIELD space.
  SET PARAMETER ID 'ZTIOPNNO' FIELD space.

  CALL TRANSACTION 'ZTIT003' AND SKIP FIRST SCREEN.

ENDFORM.                    " display_import_document
*&---------------------------------------------------------------------*
*&      Form  excute_import_document
*&---------------------------------------------------------------------*
*       import request document is display
*----------------------------------------------------------------------*
FORM excute_import_document  USING    p_reqno
                                      p_amdsq
                                      p_tcode.
  CHECK NOT p_reqno IS INITIAL.

  SET PARAMETER ID 'ZTIREQNO' FIELD p_reqno.
  SET PARAMETER ID 'ZTIAMDSQ' FIELD p_amdsq.
  SET PARAMETER ID 'ZTIREQIT' FIELD space.
  SET PARAMETER ID 'BES'      FIELD space.
  SET PARAMETER ID 'ZTIOPNNO' FIELD space.

  CALL TRANSACTION p_tcode AND SKIP FIRST SCREEN.

ENDFORM.                    " excute_import_document

*&---------------------------------------------------------------------*
*&      Form  display_ip_document
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
*&      Form  display_os_document
*&---------------------------------------------------------------------*
*       A os docment is display
*----------------------------------------------------------------------*
FORM display_os_document  USING        p_osnum.

  CHECK NOT p_osnum IS INITIAL.

  SET PARAMETER ID 'ZTSOSNUM' FIELD p_osnum.
  SET PARAMETER ID 'ZTSGCARN' FIELD space.
*
  CALL TRANSACTION 'ZTST203' AND SKIP FIRST SCREEN.

ENDFORM.                    " display_OS_document
*&---------------------------------------------------------------------*
*&      Form  display_os_confirmation
*&---------------------------------------------------------------------*
*       O/S confirmation data  is display
*----------------------------------------------------------------------*
FORM display_os_confirmation     USING    p_osnum p_osseq.

  CHECK NOT p_osnum IS INITIAL.


  CALL FUNCTION 'Z_TI_OS_CONFIRM_DISPLAY'
    EXPORTING
      i_osnum = p_osnum
*     I_OSSEQ = p_osseq
    .



ENDFORM.                    " O/S confirmation data
*&---------------------------------------------------------------------*
*&      Form  display_vs_document
*&---------------------------------------------------------------------*
*       A vessel docment is display
*----------------------------------------------------------------------*
FORM display_vs_document  USING        p_ivsno.

  CHECK NOT p_ivsno IS INITIAL.

  SET PARAMETER ID 'ZTIIVSNO' FIELD p_ivsno.
  SET PARAMETER ID 'ZTIVSLNM' FIELD space.
*
  CALL TRANSACTION 'ZTIT253' AND SKIP FIRST SCREEN.

ENDFORM.                    " display_vs_document
*&---------------------------------------------------------------------*
*&      Form  display_bl_document
*&---------------------------------------------------------------------*
*       B/L document is display
*----------------------------------------------------------------------*
FORM display_bl_document      USING    p_iblno
                                       p_iblit.
  CHECK NOT p_iblno IS INITIAL.

  SET PARAMETER ID 'ZTIIBLNO' FIELD p_iblno.
  SET PARAMETER ID 'ZTIIBLIT' FIELD p_iblit.
  SET PARAMETER ID 'ZTIBLNUM' FIELD space.

  CALL TRANSACTION 'ZTIT203' AND SKIP FIRST SCREEN.

ENDFORM.                    " display_import_document

*&---------------------------------------------------------------------*
*&      Form  display_bl_document2
*&---------------------------------------------------------------------*
*       B/L document is display
*----------------------------------------------------------------------*
FORM display_bl_document2      USING    p_blnum.
  CHECK NOT p_blnum IS INITIAL.

  SET PARAMETER ID 'ZTIIBLNO' FIELD space.
  SET PARAMETER ID 'ZTIIBLIT' FIELD space.
  SET PARAMETER ID 'ZTIBLNUM' FIELD p_blnum.

  CALL TRANSACTION 'ZTIT203' AND SKIP FIRST SCREEN.

ENDFORM.                    " display_import_document2
*&---------------------------------------------------------------------*
*&      Form  display_bs_document
*&---------------------------------------------------------------------*
*       B/S document is display
*----------------------------------------------------------------------*
FORM display_bs_document      USING    p_ibsno.
  CHECK NOT p_ibsno IS INITIAL.

  SET PARAMETER ID 'ZTIIBSNO' FIELD p_ibsno.
  CALL TRANSACTION 'ZTIT453' AND SKIP FIRST SCREEN.

ENDFORM.                    " display_bs_document

*&---------------------------------------------------------------------*
*&      Form  display_bi_document
*&---------------------------------------------------------------------*
*       B/I document is display
*----------------------------------------------------------------------*
FORM display_bi_document      USING    p_ibino.
  CHECK NOT p_ibino IS INITIAL.

  SET PARAMETER ID 'ZTIIBINO' FIELD p_ibino.
  SET PARAMETER ID 'ZTIIBSNO' FIELD space.
  SET PARAMETER ID 'ZTIBIDNR' FIELD space.
*   SET PARAMETER ID 'ZTILIVNO' FIELD space.
  CALL TRANSACTION 'ZTIT463' AND SKIP FIRST SCREEN.

ENDFORM.                    " display_bi_document


*&---------------------------------------------------------------------*
*&      Form  display_bo_document
*&---------------------------------------------------------------------*
*       B/O document is display
*----------------------------------------------------------------------*
FORM display_bo_document      USING    p_ibono.
  CHECK NOT p_ibono IS INITIAL.

  SET PARAMETER ID 'ZTIIBONO' FIELD p_ibono.
*   SET PARAMETER ID 'ZTIBODNR' FIELD space.
  SET PARAMETER ID 'ZTIBLNUM' FIELD space.
  CALL TRANSACTION 'ZTIT473' AND SKIP FIRST SCREEN.

ENDFORM.                    " display_bo_document

*&---------------------------------------------------------------------*
*&      Form  display_lg_document
*&---------------------------------------------------------------------*
*       L/G document is display
*----------------------------------------------------------------------*
FORM display_lg_document      USING    p_ilgno.

  CHECK NOT p_ilgno IS INITIAL.

  SET PARAMETER ID 'ZTIILGNO' FIELD p_ilgno.

  CALL TRANSACTION 'ZTIT603' AND SKIP FIRST SCREEN.

ENDFORM.                    " display_lg_document

*&---------------------------------------------------------------------*
*       G/R document is display
*----------------------------------------------------------------------*
FORM display_material_doc      USING    p_mblnr
                                        p_mjahr
                                        p_zeile
                                        p_bukrs.
  CHECK NOT p_mblnr IS INITIAL.

  SET PARAMETER ID 'MBN' FIELD p_mblnr.
  SET PARAMETER ID 'MJA' FIELD p_mjahr.
  SET PARAMETER ID 'BUK' FIELD p_bukrs.

*>
  CALL FUNCTION 'MIGO_DIALOG'
    EXPORTING
      i_action            = 'A04'
      i_refdoc            = 'R02'
      i_notree            = 'X'
*     I_NO_AUTH_CHECK     =
      i_skip_first_screen = 'X'
      i_deadend           = 'X'
      i_okcode            = 'OK_GO'
*     I_LEAVE_AFTER_POST  =
*     I_NEW_ROLLAREA      = 'X'
*     I_SYTCODE           =
*     I_EBELN             =
*     I_EBELP             =
      i_mblnr             = p_mblnr
      i_mjahr             = p_mjahr
      i_zeile             = p_zeile
*     I_TRANSPORT         =
*     I_ORDER_NUMBER      =
*     I_ORDER_ITEM        =
*     I_TRANSPORT_MEANS   =
*     I_TRANSPORTIDENT    =
*     I_INBOUND_DELIV     =
*     I_OUTBOUND_DELIV    =
*     I_RESERVATION_NUMB  =
*     I_RESERVATION_ITEM  =
    EXCEPTIONS
      illegal_combination = 1
      OTHERS              = 2.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

ENDFORM.                    " display_import_document

*&---------------------------------------------------------------------*
*&      Form  display_civ_document
*&---------------------------------------------------------------------*
*       A commercial Invoice is display
*----------------------------------------------------------------------*
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
*&      Form  display_vat_document
*&---------------------------------------------------------------------*
*       Tax Invoice is display
*----------------------------------------------------------------------*
FORM display_vat_document      USING    p_vatno.

  CHECK NOT p_vatno IS INITIAL.

  SET PARAMETER ID 'ZTIVATNO' FIELD p_vatno.

  CALL TRANSACTION 'ZTIT703' AND SKIP FIRST SCREEN.

ENDFORM.                    " display_civ_document

*&---------------------------------------------------------------------*
*&      Form  display_FB03_DOCUMENT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM display_fb03_document  USING    p_belnr
                                     p_gjahr
                                     p_bukrs.
*****ASEG2 20071119.임시.
  SET PARAMETER ID 'BLN' FIELD p_belnr.
  SET PARAMETER ID 'GJR' FIELD p_gjahr.
  SET PARAMETER ID 'BUK' FIELD p_bukrs.

  CALL TRANSACTION 'FB03' AND SKIP FIRST SCREEN.


*     CALL FUNCTION 'FI_DOCUMENT_LIST_DISPLAY'
*       EXPORTING
*         bukrs                      = p_bukrs
*         belnr                      = p_belnr
*         gjahr                      = p_gjahr
**           AKTYP                      = 'A'
**           XEPOS                      =
**           I_NOCHANGE                 =
**           XPRNT                      =
**    IMPORTING
**           E_CMRQ                     =
**           E_CHNG                     =
*      EXCEPTIONS
*         display_not_possible       = 1
*         no_authority               = 2
*         OTHERS                     = 3.
*
*     IF sy-subrc <> 0.
*       MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*               WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
*     ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  display_LIV_DOCUMENT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM display_liv_document  USING    p_belnr
                                    p_gjahr
                                    p_bukrs.

  CHECK NOT p_belnr IS INITIAL.
  SELECT COUNT( * )
    FROM rbkp
   WHERE belnr = p_belnr
     AND gjahr = p_gjahr.
  IF sy-subrc EQ 0.
    SET PARAMETER ID 'RBN' FIELD p_belnr.
    SET PARAMETER ID 'GJR' FIELD p_gjahr.
    CALL TRANSACTION 'MIR4' AND SKIP FIRST SCREEN.
  ELSE.
*****ASEG2 20071119.임시.
    SET PARAMETER ID 'BLN' FIELD p_belnr.
    SET PARAMETER ID 'GJR' FIELD p_gjahr.
    SET PARAMETER ID 'BUK' FIELD p_bukrs.

    CALL TRANSACTION 'FB03' AND SKIP FIRST SCREEN.


*     CALL FUNCTION 'FI_DOCUMENT_LIST_DISPLAY'
*       EXPORTING
*         bukrs                      = p_bukrs
*         belnr                      = p_belnr
*         gjahr                      = p_gjahr
**           AKTYP                      = 'A'
**           XEPOS                      =
**           I_NOCHANGE                 =
**           XPRNT                      =
**    IMPORTING
**           E_CMRQ                     =
**           E_CHNG                     =
*      EXCEPTIONS
*         display_not_possible       = 1
*         no_authority               = 2
*         OTHERS                     = 3.
*
*     IF sy-subrc <> 0.
*       MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*               WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
*     ENDIF.
  ENDIF.

ENDFORM.                    " display_LIV_DOCUMENT

*&---------------------------------------------------------------------*
*&      Form  display_cc_document
*&---------------------------------------------------------------------*
*       A customer clearance is display
*----------------------------------------------------------------------*
FORM display_cc_document      USING    p_iccno
                                       p_iccsq.

  CHECK NOT p_iccno IS INITIAL.

  SET PARAMETER ID 'ZTIICCNO' FIELD p_iccno.
  SET PARAMETER ID 'ZTIICCSQ' FIELD p_iccsq.
  SET PARAMETER ID 'ZTIIBLNO' FIELD space.
  SET PARAMETER ID 'ZTIBLNUM' FIELD space.
  SET PARAMETER ID 'BES'      FIELD space.

  CALL TRANSACTION 'ZTIT433' AND SKIP FIRST SCREEN.

ENDFORM.                    " display_cc_document
*&---------------------------------------------------------------------*
*&      Form  display_cr_document
*&---------------------------------------------------------------------*
*       A customer clearance is display
*----------------------------------------------------------------------*
FORM display_cr_document      USING    p_iccno
                                       p_iccsq.

  CHECK NOT p_iccno IS INITIAL.

  SET PARAMETER ID 'ZTIICCNO' FIELD p_iccno.
  SET PARAMETER ID 'ZTIICCSQ' FIELD p_iccsq.
  SET PARAMETER ID 'ZTIIBLNO' FIELD space.
  SET PARAMETER ID 'ZTIBLNUM' FIELD space.
  SET PARAMETER ID 'BES'      FIELD space.

  CALL TRANSACTION 'ZTIT403' AND SKIP FIRST SCREEN.

ENDFORM.                    " display_cr_document
*&---------------------------------------------------------------------*
*&      Form  display_cr_document2
*&---------------------------------------------------------------------*
*       A customer clearance is display(gsc 용)
*----------------------------------------------------------------------*
FORM display_cr_document2      USING    p_iccno
                                        p_iccsq
                                        p_confm.

  CHECK NOT p_iccno IS INITIAL.

  SET PARAMETER ID 'ZTIICCNO' FIELD p_iccno.
  SET PARAMETER ID 'ZTIICCSQ' FIELD p_iccsq.
  SET PARAMETER ID 'ZTICONFM' FIELD p_confm.
  SET PARAMETER ID 'ZTIIBLNO' FIELD space.
  SET PARAMETER ID 'ZTIBLNUM' FIELD space.
  SET PARAMETER ID 'BES'      FIELD space.

  CALL TRANSACTION 'ZTIT403' AND SKIP FIRST SCREEN.

ENDFORM.                    " display_cr_document2

*&---------------------------------------------------------------------*
*&      Form  display_gr_document
*&---------------------------------------------------------------------*
*       G/R document is display
*----------------------------------------------------------------------*
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
*&      Form  display_sales_order
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM display_sales_order  USING    p_vbeln.

  DATA : l_vbeln LIKE vbak-vbeln,
         l_ebeln LIKE ekko-ebeln.

  CHECK: NOT p_vbeln IS INITIAL.

  SELECT SINGLE vbeln
    INTO l_vbeln
    FROM vbak
   WHERE vbeln EQ p_vbeln.
  IF sy-subrc EQ 0.
    SET PARAMETER ID 'AUN' FIELD p_vbeln.
    CALL TRANSACTION 'VA03' AND SKIP FIRST SCREEN.
  ELSE.
    SELECT SINGLE ebeln
      INTO l_ebeln
      FROM ekko
     WHERE ebeln EQ p_vbeln.
    IF sy-subrc EQ 0.
      PERFORM display_purchase_order USING p_vbeln
                                           '00000'.

    ELSE.

    ENDIF.

  ENDIF.

ENDFORM.                    " display_sales_order
*&---------------------------------------------------------------------*
*       Notice document is display
*----------------------------------------------------------------------*
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
*&      Form  display_formula_pricing
*&---------------------------------------------------------------------*
FORM display_formula_pricing  USING    p_ebeln
                                       p_ebelp.

  CHECK NOT p_ebeln IS INITIAL.
  CHECK NOT p_ebelp IS INITIAL.

  CALL FUNCTION 'Z_TS_FORMULA_CALCU'
    EXPORTING
      im_docno          = p_ebeln
      im_itmno          = p_ebelp
      im_kappl          = 'M'
      im_report         = 'X'
      im_errclr         = 'X'
      im_getdb          = 'X'
      i_read_until_date = sy-datlo
    EXCEPTIONS
      not_found         = 1
      OTHERS            = 4.

  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE 'S' NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

ENDFORM.                    " display_formula_pricing
*&---------------------------------------------------------------------*
*&      Form  display_formula_pricing_qty
*&---------------------------------------------------------------------*
FORM display_formula_pricing_qty  USING    p_ebeln
                                       p_ebelp
                                       p_menge.

  CHECK NOT p_ebeln IS INITIAL.
  CHECK NOT p_ebelp IS INITIAL.

  CALL FUNCTION 'Z_TS_FORMULA_CALCU'
    EXPORTING
      im_docno          = p_ebeln
      im_itmno          = p_ebelp
      im_kappl          = 'M'
      im_report         = 'X'
      im_errclr         = 'X'
      im_getdb          = 'X'
      i_read_until_date = sy-datlo
      i_menge           = p_menge
    EXCEPTIONS
      not_found         = 1
      OTHERS            = 4.

  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE 'S' NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

ENDFORM.                    " display_formula_pricing_qty
*&---------------------------------------------------------------------*
*       A acceptance certification is diplay
*----------------------------------------------------------------------*
FORM display_ac_document      USING    p_acdno.

  CHECK NOT p_acdno IS INITIAL.

  SET PARAMETER ID 'ZTIACDNO' FIELD p_acdno.
  SET PARAMETER ID 'ZTIACCNO' FIELD space.
  SET PARAMETER ID 'ZTIOPNNO' FIELD space.

  CALL TRANSACTION 'ZTIT723' AND SKIP FIRST SCREEN.

ENDFORM.                    " display_ac_document

*&---------------------------------------------------------------------*
*       기납증
*----------------------------------------------------------------------*
FORM display_ctp_document      USING  p_taxno.

  CHECK NOT p_taxno IS INITIAL.

  SET PARAMETER ID 'ZTITAXNO' FIELD p_taxno.

  CALL TRANSACTION 'ZTIT743' AND SKIP FIRST SCREEN.

ENDFORM.                    " display_ac_document

*&---------------------------------------------------------------------*
*&      Form  display_cs_document
*&---------------------------------------------------------------------*
*       A expense document is display
*----------------------------------------------------------------------*
FORM display_cs_document      USING    p_icsno
                                       p_bukrs.

  CHECK NOT p_icsno IS INITIAL.

  SET PARAMETER ID 'ZTIICSNO' FIELD p_icsno.
  SET PARAMETER ID 'BUK'      FIELD p_bukrs.

  CALL TRANSACTION 'ZTIT903' AND SKIP FIRST SCREEN.

ENDFORM.                    " display_cs_document

*&---------------------------------------------------------------------*
*&      Form  display_loan_master
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM display_loan_master  USING    p_xranl
                                   p_bukrs.

  DATA: ls_ztitig38 LIKE ztitig38.

  CHECK NOT  p_xranl IS INITIAL.

*   SELECT SINGLE *
*     INTO ls_ztitig38
*     FROM ztitig38
*    WHERE bukrs EQ p_bukrs.
*
*   IF sy-subrc EQ 0.
*     IF ls_ztitig38-usdtc EQ c_charm.
*       SET PARAMETER ID 'FAN' FIELD p_xranl.
*       SET PARAMETER ID 'BUK' FIELD p_bukrs.
**>by YSH(071001) 금호
**       CALL TRANSACTION 'TM03' AND SKIP FIRST SCREEN.
*       CALL TRANSACTION 'TM_53' AND SKIP FIRST SCREEN.
*     ELSEIF ls_ztitig38-usdtc EQ c_charl.
*       SET PARAMETER ID 'RAD' FIELD p_xranl.
*       SET PARAMETER ID 'BUK' FIELD p_bukrs.
*       CALL TRANSACTION 'FN3V' AND SKIP FIRST SCREEN.
*     ENDIF.
*   ENDIF.

  SET PARAMETER ID 'FAN' FIELD p_xranl.
  SET PARAMETER ID 'BUK' FIELD p_bukrs.

*   CALL TRANSACTION 'TM_53' AND SKIP FIRST SCREEN.
  CALL TRANSACTION 'FTR_DISPLAY' AND SKIP FIRST SCREEN.

ENDFORM.                    " display_loan_master

*&---------------------------------------------------------------------*
*&      Form  get_invoice_by_iv_number
*&---------------------------------------------------------------------*
*       By I/V No. I/V manage no. Get
*----------------------------------------------------------------------*
*      -->P_IVONO       I/V No.
*      -->P_IVNUM       Invoice Number
*      -->P_CLEAR_MODE  Parameter clear mode
*----------------------------------------------------------------------*
FORM get_invoice_by_iv_number  USING    p_ivono
                                        p_ivnum
                                        p_clear_mode.
  DATA: l_count TYPE i,
        l_ivono TYPE ztiviv00-ivono.
  IF p_clear_mode EQ 'X'.
    CLEAR : p_ivono.
  ENDIF.

  IF NOT p_ivnum IS INITIAL.
    CLEAR: l_count.
    SELECT  ivono
      INTO  l_ivono
      FROM  ztiviv00
     WHERE  ivnum EQ p_ivnum
     GROUP BY ivono.

      ADD 1 TO l_count.
    ENDSELECT.

    CASE l_count.
      WHEN  0.
        MESSAGE e320(zmti00) WITH p_ivnum.
      WHEN  1.
        MOVE: l_ivono TO p_ivono.
        EXIT.
      WHEN OTHERS.
        CALL FUNCTION 'Z_TI_POPUP_TO_IVONO_BY_IVNUM'
          EXPORTING
            xivnum    = p_ivnum
          IMPORTING
            xivono    = p_ivono
          EXCEPTIONS
            not_found = 1
            OTHERS    = 2.

        IF sy-subrc <> 0.
          MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                  WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
        ENDIF.
    ENDCASE.
  ENDIF.

ENDFORM.                    " get_invoice_by_iv_number

*&---------------------------------------------------------------------*
*&      Form  get_invoice_by_bl_number
*&---------------------------------------------------------------------*
*      By B/L number I/V manage no. Get
*----------------------------------------------------------------------*
*      -->P_IVONO       I/V NO.
*      -->P_BLNUM       B/L Number
*      -->P_CLEAR_MODE  Parameter clear mode
*----------------------------------------------------------------------*
FORM get_invoice_by_bl_number  USING    p_ivono
                                        p_blnum
                                        p_clear_mode.
  DATA: l_count TYPE i,
        l_ivono TYPE ztiviv00-ivono.

  IF p_clear_mode EQ 'X'.
    CLEAR : p_ivono.
  ENDIF.

  IF NOT p_blnum IS INITIAL.
    CLEAR: l_count.
    SELECT  ivono
      INTO  l_ivono
      FROM  ztiviv02
     WHERE  blnum EQ p_blnum
     GROUP BY ivono.

      ADD 1 TO l_count.
    ENDSELECT.

    CASE l_count.
      WHEN  0.
        MESSAGE e319(zmti00) WITH p_blnum.
      WHEN  1.
        MOVE: l_ivono TO p_ivono.
        EXIT.
      WHEN OTHERS.
        CALL FUNCTION 'Z_TI_POPUP_TO_IVONO_BY_BLNUM'
          EXPORTING
            xblnum    = p_blnum
          IMPORTING
            xivono    = p_ivono
          EXCEPTIONS
            not_found = 1
            OTHERS    = 2.

        IF sy-subrc <> 0.
          MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                  WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
        ENDIF.
    ENDCASE.
  ENDIF.

ENDFORM.                    " get_invoice_by_bl_number
*&---------------------------------------------------------------------*
*&      Form  get_invoice_by_bl_int_no
*&---------------------------------------------------------------------*
*       By B/L number I/V manage no. Get
*----------------------------------------------------------------------*
*      -->P_IVONO       I/V No.
*      -->P_IBLNO       B/L No.
*      -->P_CLEAR_MODE  Parameter clear mode
*----------------------------------------------------------------------*
FORM get_invoice_by_bl_int_no  USING    p_ivono
                                        p_iblno
                                        p_clear_mode.
  DATA: l_count TYPE i,
        l_ivono TYPE ztiviv00-ivono.

  IF p_clear_mode EQ 'X'.
    CLEAR : p_ivono.
  ENDIF.

  IF NOT p_iblno IS INITIAL.
    CLEAR: l_ivono.
    SELECT  ivono
      INTO  l_ivono
      FROM  ztiviv02
     WHERE  iblno EQ p_iblno
     GROUP BY ivono.

      ADD 1 TO l_count.
    ENDSELECT.

    CASE l_count.
      WHEN  0.
        MESSAGE e318(zmti00) WITH p_iblno.
      WHEN  1.
        MOVE: l_ivono TO p_ivono.
        EXIT.
      WHEN OTHERS.
        CALL FUNCTION 'Z_TI_POPUP_TO_IVONO_BY_IBLNO'
          EXPORTING
            xiblno    = p_iblno
          IMPORTING
            xivono    = p_ivono
          EXCEPTIONS
            not_found = 1
            OTHERS    = 2.

        IF sy-subrc <> 0.
          MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                  WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
        ENDIF.
    ENDCASE.
  ENDIF.

ENDFORM.                    " get_invoice_by_bl_int_no

*&---------------------------------------------------------------------*
*&      Form  ddic_domain_value_text_read
*&---------------------------------------------------------------------*
FORM ddic_domain_value_text_read
                    USING  p_name  LIKE dd07v-domname
                           p_spras LIKE dd07v-ddlanguage
                           p_value
                           p_text  LIKE dd07v-ddtext
                           p_mtype.

  DATA: l_value  LIKE dd07v-domvalue_l,
        l_ddtext LIKE dd01t-ddtext.

  CLEAR: p_text.
  MOVE: p_value TO l_value.

  CALL FUNCTION 'C_DIC_DOMAIN_VALUE_TEXT_READ'
    EXPORTING
      name      = p_name
      spras     = p_spras
      value     = l_value
    IMPORTING
      text      = p_text
    EXCEPTIONS
      not_found = 1
      OTHERS    = 2.
  IF sy-subrc <> 0.
    SELECT ddtext
      INTO l_ddtext
      FROM dd01t UP TO 1 ROWS
     WHERE domname    EQ p_name
       AND ddlanguage EQ p_spras.
    ENDSELECT.
    IF sy-subrc EQ 0.
      MESSAGE e047(zmti00) WITH l_ddtext l_value.
    ELSE.
      MESSAGE e048(zmti00) WITH p_name l_value.
    ENDIF.
*     MESSAGE ID sy-msgid TYPE p_mtype NUMBER sy-msgno
*             WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

ENDFORM.                    " ddic_domain_value_text_read

*&---------------------------------------------------------------------*
*&      Form  GET_PARENT_WBS_ELEMENT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM get_parent_wbs_element USING p_ps_psp_pnr LIKE ekkn-ps_psp_pnr
                                  p_proj       LIKE proj.

  DATA: l_pspnr  LIKE proj-pspnr.

  CLEAR: p_proj.

  CHECK  NOT p_ps_psp_pnr IS INITIAL.

  SELECT SINGLE *
    INTO p_proj
    FROM proj
   WHERE pspnr EQ ( SELECT psphi
                      FROM prps
                     WHERE pspnr EQ p_ps_psp_pnr ).
  IF sy-subrc EQ 0.
    EXIT.
  ENDIF.

  SELECT SINGLE *
    INTO p_proj
    FROM proj
   WHERE pspnr EQ p_ps_psp_pnr.

  IF sy-subrc EQ 0.
    EXIT.
  ENDIF.

ENDFORM.                    " GET_PARENT_WBS_ELEMENT
*&---------------------------------------------------------------------*
*&      Form  get_wbs_element_by_network
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM get_wbs_element_by_network  USING    p_nplnr LIKE ekkn-nplnr
                                          p_proj  LIKE proj.

  DATA: l_pspnr  LIKE  ekkn-ps_psp_pnr,
        l_pspnr1 LIKE  afpo-projn.

  CLEAR: p_proj.

  CHECK: NOT p_nplnr IS INITIAL.

  SELECT SINGLE pspel
    INTO l_pspnr
    FROM aufk
   WHERE aufnr  EQ  p_nplnr.

  IF sy-subrc NE 0.
    EXIT.
  ENDIF.

  IF l_pspnr IS INITIAL.
    SELECT  SINGLE  projn
      INTO  l_pspnr
      FROM  afpo
     WHERE  aufnr  =  p_nplnr
       AND  posnr  =  '0001'.
  ENDIF.

  PERFORM get_parent_wbs_element USING l_pspnr
                                       p_proj.

ENDFORM.                    " get_wbs_element_by_network

*&---------------------------------------------------------------------*
*&      Form  MESSAGE_NOT_FOUND_VENDOR
*&---------------------------------------------------------------------*
FORM message_not_found_vendor  USING noi_tab noi_field p_msgty.

  DATA: BEGIN OF feld,
          table(10),
          strich,
          name(10),
        END OF feld.

  feld-table = noi_tab.
  feld-strich = '-'.
  CONDENSE feld.
  SEARCH feld FOR '-'.
  sy-fdpos = sy-fdpos - 1.
  WRITE '-' TO feld+sy-fdpos.
  sy-fdpos = sy-fdpos + 1.
  WRITE noi_field TO feld+sy-fdpos.
  IF sy-stepl EQ 0.
    SET CURSOR FIELD feld.
  ELSE.
    SET CURSOR FIELD feld LINE sy-stepl.
  ENDIF.

  PERFORM get_ftext(rddfie00) USING    noi_tab noi_field sy-langu
                              CHANGING dfies g_subrc.
  IF g_subrc EQ 0.
    MESSAGE ID 'ZMTI00' TYPE p_msgty NUMBER 915 WITH dfies-scrtext_m.
*    MESSAGE e915 WITH dfies-scrtext_m.
  ELSE.
    MESSAGE ID 'ZMTI00' TYPE p_msgty NUMBER 915 WITH noi_tab noi_field.
*    MESSAGE e915 WITH noi_tab noi_field.
  ENDIF.

ENDFORM.                    " MESSAGE_NOT_FOUND_VENDOR

*&---------------------------------------------------------------------*
*&      Form  display_vendor_master
*&---------------------------------------------------------------------*
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
*&      Form  no_input_check
*&---------------------------------------------------------------------*
FORM no_input_check  USING noi_tab noi_field p_msgty.

  DATA: BEGIN OF feld,
          table(15),
          strich,
          name(10),
        END OF feld.

  CHECK NOT p_msgty IS INITIAL.

  feld-table = noi_tab.
  feld-strich = '-'.
  CONDENSE feld.
  SEARCH feld FOR '-'.
  sy-fdpos = sy-fdpos - 1.
  WRITE '-' TO feld+sy-fdpos.
  sy-fdpos = sy-fdpos + 1.
  WRITE noi_field TO feld+sy-fdpos.
  IF sy-stepl EQ 0.
    SET CURSOR FIELD feld.
  ELSE.
    SET CURSOR FIELD feld LINE sy-stepl.
  ENDIF.

  PERFORM get_ftext(rddfie00) USING    noi_tab noi_field sy-langu
                              CHANGING dfies g_subrc.
  IF g_subrc EQ 0.
    IF p_msgty EQ 'W'.
      MESSAGE ID 'ZMTI00' TYPE p_msgty NUMBER 925 WITH dfies-scrtext_m.
    ELSE.
      MESSAGE ID 'ZMTI00' TYPE p_msgty NUMBER 915 WITH dfies-scrtext_m.
    ENDIF.
*    MESSAGE e915 WITH dfies-scrtext_m.
  ELSE.
    IF p_msgty EQ 'W'.
      MESSAGE ID 'ZMTI00' TYPE p_msgty
              NUMBER 925 WITH noi_tab noi_field.
    ELSE.
      MESSAGE ID 'ZMTI00' TYPE p_msgty
              NUMBER 915 WITH noi_tab noi_field.
    ENDIF.
*    MESSAGE e915 WITH noi_tab noi_field.
  ENDIF.

ENDFORM.                    " no_input_check


*&---------------------------------------------------------------------*
*&      Form  SET_WRITE_NO_MASK
*&---------------------------------------------------------------------*
FORM set_write_no_mask CHANGING p_text_amount.

  TABLES : usr01.

  SELECT SINGLE * FROM usr01 WHERE bname EQ sy-uname.

  CASE usr01-dcpfm.
    WHEN 'X'.    " Decimal point is period: N,NNN.NN
      PERFORM    set_change_symbol    USING p_text_amount ',' ' '.
      CONDENSE         p_text_amount    NO-GAPS.
    WHEN 'Y'.    " Decimal point is N NNN NNN,NN
      PERFORM    set_change_symbol    USING p_text_amount  ',' '.'.
      CONDENSE         p_text_amount    NO-GAPS.
    WHEN OTHERS. " Decimal point is comma: N.NNN,NN
      PERFORM    set_change_symbol    USING p_text_amount  '.' ' '.
      PERFORM    set_change_symbol    USING p_text_amount  ',' '.'.
      CONDENSE         p_text_amount    NO-GAPS.
  ENDCASE.

ENDFORM.                    " SET_WRITE_NO_MASK

*&---------------------------------------------------------------------*
*&      Form  SET_CHANGE_SYMBOL
*&---------------------------------------------------------------------*
FORM set_change_symbol USING    p_amount  p_from  p_to.

  DO.
    REPLACE  p_from   WITH   p_to  INTO    p_amount.
    IF  sy-subrc  <>    0.
      EXIT.
    ENDIF.
  ENDDO.

ENDFORM.                    " SET_CHANGE_SYMBOL

*&---------------------------------------------------------------------*
*&      Form  check_mandatory_input
*&---------------------------------------------------------------------*
FORM check_mandatory_input  USING    p_fieldname  p_msgty.

  FIELD-SYMBOLS: <l_field>.
  DATA: l_subrc   TYPE  subrc,
        l_fdpos   TYPE  syfdpos,
        l_char(2) TYPE  c.

  DATA: BEGIN OF field,
          table(15),
          strich,
          name(10),
        END OF field.

  CHECK NOT p_msgty IS INITIAL.

  ASSIGN (p_fieldname) TO <l_field>.
  CHECK sy-subrc EQ 0.

  IF <l_field> IS INITIAL.
    SEARCH p_fieldname FOR '-'.
    IF sy-subrc EQ 0.
      field-table  = p_fieldname(sy-fdpos).
      field+15     = p_fieldname+sy-fdpos.
      PERFORM no_input_check USING field-table field-name p_msgty.
    ENDIF.
  ENDIF.

ENDFORM.                    " check_mandatory_input

*&---------------------------------------------------------------------*
*&      Form  get_transport_terms
*&---------------------------------------------------------------------*
FORM get_transport_terms    TABLES   p_it_ztitig11 STRUCTURE ztitig11
                            USING    p_subrc  p_type.

  CLEAR: p_subrc.

  SELECT * FROM  ztitig11
    INTO CORRESPONDING FIELDS OF TABLE p_it_ztitig11.

  p_subrc = sy-subrc.

  IF p_subrc NE 0.
*    MESSAGE ID 'ZMTI00' TYPE p_type NUMBER 018.
    EXIT.
  ENDIF.

ENDFORM.                    " get_used_payment_term
*&---------------------------------------------------------------------*
*&      Form  BUILD_MENU_IMPORT_CS
*&---------------------------------------------------------------------*
* 2015//06/17 HyeungJungKim 항차 제비용 Context 메뉴 제어용
* 항차 IMG 미사용 시 제비용에서 항차 메뉴 제외하기 위함
* build_menu_import Copy하여 생성
*----------------------------------------------------------------------*
FORM build_menu_import_cs  USING p_ztitig00 LIKE        ztitig00
                                  p_ctxmenu TYPE REF TO cl_ctmenu
                                  p_menu_type.

  DATA: l_ctxmenu TYPE REF TO cl_ctmenu,
        l_icon    TYPE icon_d,
        l_entry   TYPE sctx_entry.


  DATA: BEGIN OF lt_expgr OCCURS 0, " 제비용 메뉴 제어용.
          expgr TYPE ztitig06-expgr,
        END OF lt_expgr.

  CHECK p_menu_type EQ 'CS'.

  CLEAR: lt_expgr, lt_expgr[].
  SELECT DISTINCT expgr
    INTO CORRESPONDING FIELDS OF TABLE lt_expgr
    FROM ztitig06
   WHERE bukrs EQ p_ztitig00-bukrs.

  IF lt_expgr[] IS INITIAL.
    EXIT.
  ENDIF.

  SORT lt_expgr BY expgr.


  CREATE OBJECT l_ctxmenu.

***************************************************
******************>> 서브 메뉴 관련...
***************************************************
  CASE p_menu_type.
    WHEN 'CS'.   ">레포트..
      l_entry-icon = icon_led_green.
      l_entry-text = text-009.
    WHEN OTHERS.
      EXIT.
  ENDCASE.


  p_ctxmenu->add_submenu( menu        = l_ctxmenu
                          text        = l_entry-text
                          icon        = l_entry-icon ).
*                                disabled    = <l_menu>-disabled
*                                hidden      =
*                                accelerator = <l_menu>-accelerator ).


  CASE p_menu_type.
    WHEN 'CS'.   ">제비용...

*-> 은행비용,..
      READ TABLE lt_expgr WITH KEY expgr = 'L'
                          BINARY SEARCH.

      IF sy-subrc EQ 0.
        PERFORM set_function_code   USING :
                                            l_ctxmenu 'ZTIR911'.
      ENDIF.

*-> 적하 비용,..
      READ TABLE lt_expgr WITH KEY expgr = 'I'
                          BINARY SEARCH.

      IF sy-subrc EQ 0.
        PERFORM set_function_code   USING :
                                            l_ctxmenu 'ZTIR912'.
      ENDIF.

*-> b/L 비용,..
      READ TABLE lt_expgr WITH KEY expgr = 'B'
                          BINARY SEARCH.

      IF sy-subrc EQ 0.
        PERFORM set_function_code   USING :
                                            l_ctxmenu 'ZTIR913'.
      ENDIF.

*-> 통관 비용,..
      READ TABLE lt_expgr WITH KEY expgr = 'C'
                          BINARY SEARCH.

      IF sy-subrc EQ 0.
        PERFORM set_function_code   USING :
                                            l_ctxmenu 'ZTIR914'.
      ENDIF.

*-> 항차/용선 비용,..
      READ TABLE lt_expgr WITH KEY expgr = 'Y'
                          BINARY SEARCH.

      IF sy-subrc EQ 0.
        PERFORM set_function_code   USING :
                                            l_ctxmenu 'ZTIR918'.
      ENDIF.

*-> 관세전가액,..
      READ TABLE lt_expgr WITH KEY expgr = 'T'
                          BINARY SEARCH.

      IF sy-subrc EQ 0.
        PERFORM set_function_code   USING :
                                            l_ctxmenu 'ZTIR915'.
      ENDIF.

*
*      "> 항차 IMG 미사용 시 호출되며, 항차 제비용 Context를 보이지 않게 함.
*      PERFORM set_function_code   USING :
*                                          l_ctxmenu 'ZTIR911',
*                                          l_ctxmenu 'ZTIR912',
**                                          l_ctxmenu 'ZTIR918', " 항차
*                                          l_ctxmenu 'ZTIR913',
*                                          l_ctxmenu 'ZTIR914',
*                                          l_ctxmenu 'ZTIR915'.

      l_ctxmenu->add_separator( ).

      PERFORM set_function_code   USING : l_ctxmenu 'ZTIR901',
                                          l_ctxmenu 'ZTIR9011',
*                                          l_ctxmenu 'ZTIR901',
                                          l_ctxmenu 'ZTIR902'.

    WHEN OTHERS.
      EXIT.
  ENDCASE.

ENDFORM.                    " BUILD_MENU_IMPORT_CS
*&---------------------------------------------------------------------*
*&      Form  BUILD_MENU_IMPORT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_P_CTXMENU  text
*      -->P_2999   text
*----------------------------------------------------------------------*
FORM build_menu_import  USING p_ztitig00 LIKE        ztitig00
                              p_ctxmenu  TYPE REF TO cl_ctmenu
                              p_menu_type.

  DATA: l_ctxmenu TYPE REF TO cl_ctmenu,
        l_icon    TYPE icon_d,
        l_entry   TYPE sctx_entry.

  DATA: l_return    TYPE c.


  CREATE OBJECT l_ctxmenu.
***************************************************
******************>> 서브 메뉴 관련...
***************************************************
  CASE p_menu_type.
    WHEN 'IR'.    ">사전계약.
      l_entry-icon = icon_led_green.
      l_entry-text = text-000.
    WHEN 'IP'.    ">계약.
      l_entry-icon = icon_led_green.
      l_entry-text = text-001.
    WHEN 'BL'.   ">오더...
      l_entry-icon = icon_led_green.
      l_entry-text = text-002.
    WHEN 'IV'.   ">레포트..
      l_entry-icon = icon_led_green.
      l_entry-text = text-003.
    WHEN 'ST'.   ">레포트..
      l_entry-icon = icon_led_green.
      l_entry-text = text-100.

    WHEN 'TR'.   ">레포트..
      l_entry-icon = icon_led_green.
      l_entry-text = text-101.

    WHEN 'MC'.   ">레포트..
      l_entry-icon = icon_led_green.
      l_entry-text = text-102.

    WHEN 'LG'.   ">레포트..
      l_entry-icon = icon_led_green.
      l_entry-text = text-010.
    WHEN 'CR'.   ">레포트..
      l_entry-icon = icon_led_green.
      l_entry-text = text-004.
    WHEN 'TD'.   ">레포트..
      l_entry-icon = icon_led_green.
      l_entry-text = text-014.
    WHEN 'CC'.   ">레포트..
      l_entry-icon = icon_led_green.
      l_entry-text = text-011.
    WHEN 'GR'.   ">레포트..
      l_entry-icon = icon_led_green.
      l_entry-text = text-005.
    WHEN 'CS'.   ">레포트..
      l_entry-icon = icon_led_green.
      l_entry-text = text-009.
    WHEN 'PN'.   ">레포트..
      l_entry-icon = icon_led_green.
      l_entry-text = text-008.
    WHEN 'VA'.   ">세금계산서..
      l_entry-icon = icon_led_green.
      l_entry-text = text-012.
    WHEN 'AC'.   ">인수증..
      l_entry-icon = icon_led_green.
      l_entry-text = text-013.

    WHEN 'BS'.   "반입예정정보..
      l_entry-icon = icon_led_green.
      l_entry-text = text-015.
    WHEN 'BI'.   "반입정보
      l_entry-icon = icon_led_green.
      l_entry-text = text-016.
    WHEN 'BO'.   "반출정보..
      l_entry-icon = icon_led_green.
      l_entry-text = text-017.
    WHEN OTHERS.
      EXIT.
  ENDCASE.

  p_ctxmenu->add_submenu( menu        = l_ctxmenu
                          text        = l_entry-text
                          icon        = l_entry-icon ).
*                                disabled    = <l_menu>-disabled
*                                hidden      =
*                                accelerator = <l_menu>-accelerator ).

  CASE p_menu_type.
    WHEN 'IR'.    ">개설관리..
      PERFORM set_function_code   USING : l_ctxmenu 'ZTIR000',
                                          l_ctxmenu 'ZTIT001'.

**> 사후 송금....
*      IF p_ztitig00-attpx EQ 'X'.
        PERFORM set_function_code   USING :
                                          l_ctxmenu 'ZTIR001'.
*      ENDIF.

*> 유보금 관리...
*      IF p_ztitig00-retpx EQ 'X'.
        PERFORM set_function_code   USING :
                                          l_ctxmenu 'ZTIR002'.
*      ENDIF.

*> 무역외 송금.
*      IF p_ztitig00-etpcs NE 'Z'.
        PERFORM set_function_code   USING :
                                          l_ctxmenu 'ZTIR003'.
*      ENDIF.


      PERFORM set_function_code   USING : l_ctxmenu 'ZTIT051'.

      l_ctxmenu->add_separator( ).

      PERFORM set_function_code   USING :
                                          l_ctxmenu 'ZTIT002', ">변경.
                                          l_ctxmenu 'ZTIT003', ">조회.
                                          l_ctxmenu 'ZTIT004'. ">삭제.

*> 포워더 지정 프로세스 사용 여부.
      IF p_ztitig00-fwdyn EQ 'X'.
        PERFORM set_function_code   USING :
                                          l_ctxmenu 'ZTIR005'.
      ENDIF.


*================================================
*> 승인 프로세스 사용시.
*================================================
*      IF
*          p_ztitig00-rqrlc EQ 'X' OR
*          p_ztitig00-rqrda EQ 'X' OR
*          p_ztitig00-rqrdp EQ 'X' OR
*          p_ztitig00-rqrlo EQ 'X' OR
*          p_ztitig00-rqrpu EQ 'X' OR
*          p_ztitig00-rqrvd EQ 'X' OR
*          p_ztitig00-rqrtt EQ 'X' OR
*          p_ztitig00-rqrvl EQ 'X' OR
*          p_ztitig00-rqrvp EQ 'X'.

        l_ctxmenu->add_separator( ).
        PERFORM set_function_code   USING :
                                          l_ctxmenu 'ZTIR007',  " 승인
                                          l_ctxmenu 'ZTIR007_C'.  " 승인취소
*      ENDIF.
*================================================

      l_ctxmenu->add_separator( ).


*================================================
*==> 접수 트랜잭션.
      PERFORM check_ir_transaction    USING p_ztitig00
                                            'ZTIT005'
                                            l_return.

      IF l_return IS NOT INITIAL.
        PERFORM set_function_code   USING : l_ctxmenu 'ZTIT005'.
      ENDIF.
*================================================


*================================================
*==> 은행 지정 트랜잭션.
      PERFORM check_ir_transaction    USING p_ztitig00
                                            'ZTIT006'
                                            l_return.

      IF l_return IS NOT INITIAL.
        PERFORM set_function_code   USING : l_ctxmenu 'ZTIT006'.
      ENDIF.
*================================================

*================================================
*==> 전송 트랜잭션.
      PERFORM check_ir_transaction    USING p_ztitig00
                                            'ZTIT009'
                                            l_return.

      IF l_return IS NOT INITIAL.
        PERFORM set_function_code   USING : l_ctxmenu 'ZTIT009'.
      ENDIF.
*================================================


      PERFORM set_function_code   USING :
                                  l_ctxmenu 'ZTIT007', ">개설관리.
                                  l_ctxmenu 'ZTIT008'. ">종료관리.


*==> 기타 수입의뢰 관련 Report.
      l_ctxmenu->add_separator( ).
      PERFORM set_function_code   USING :
                                          l_ctxmenu 'ZTIR008', ">상태관리.
                                          l_ctxmenu 'ZTIR004', ">상태현황.
                                          l_ctxmenu 'ZTIR099', ">품목별 현황.
                                          l_ctxmenu 'ZTIR018', ">변경현황
                                          l_ctxmenu 'ZTIR009'. ">PO종료 관리.

**************************************************
*20130725 by jsh - GSC
*GSC 수입진행사항 적하부보 기능 추가
    WHEN 'IP'.    ">보험...
      PERFORM set_function_code   USING : l_ctxmenu 'ZTIR100',
                                          l_ctxmenu 'ZTIT101',
                                          l_ctxmenu 'ZTIT151',
                                          l_ctxmenu 'ZTIT102',
                                          l_ctxmenu 'ZTIT103',
                                          l_ctxmenu 'ZTIT104'.
**************************************************

*      IF p_ztitig00-ippmt EQ 'A'.  ">의뢰 -> 확정이면...
*==> 기타 수입의뢰 관련 Report.
        l_ctxmenu->add_separator( ).

        PERFORM set_function_code   USING : l_ctxmenu 'ZTIT105'.

*      ENDIF.


    WHEN 'BL'.   ">B/L
      PERFORM set_function_code   USING : l_ctxmenu 'ZTIR200',
                                          l_ctxmenu 'ZTIT201',
                                          l_ctxmenu 'ZTIT202',
                                          l_ctxmenu 'ZTIT203',
                                          l_ctxmenu 'ZTIT204',
                                          l_ctxmenu 'ZTIR203',
                                          l_ctxmenu 'ZTIR299'.

    WHEN 'IV'.   ">송장...
      PERFORM set_function_code   USING : l_ctxmenu 'ZTIR300',
                                          l_ctxmenu 'ZTIR301',
                                          l_ctxmenu 'ZTIT301',
                                          l_ctxmenu 'ZTIT302',
                                          l_ctxmenu 'ZTIT303',
                                          l_ctxmenu 'ZTIT304'.

      l_ctxmenu->add_separator( ).
      PERFORM set_function_code   USING : l_ctxmenu 'ZTIT305',
                                          l_ctxmenu 'ZTIT306'.
      l_ctxmenu->add_separator( ).
      PERFORM set_function_code   USING : l_ctxmenu 'ZTIR305',
                                          l_ctxmenu 'ZTIR398'.
*      l_ctxmenu->add_separator( ).
*
    WHEN 'ST'.
      PERFORM set_function_code   USING : l_ctxmenu 'ZTIR304',
                                          l_ctxmenu 'ZTIT307'.

    WHEN 'TR'.
      PERFORM set_function_code   USING : l_ctxmenu 'ZTIR320'.
*                                          l_ctxmenu 'ZTIR321'.

    WHEN 'LG'.   ">L/G
      PERFORM set_function_code   USING : l_ctxmenu 'ZTIT601',
                                          l_ctxmenu 'ZTIT602',
                                          l_ctxmenu 'ZTIT603',
                                          l_ctxmenu 'ZTIT604'.

*      IF p_ztitig00-lgryn EQ 'X'.  ">승인 사용일 경우.
        l_ctxmenu->add_separator( ).
        PERFORM set_function_code   USING : l_ctxmenu 'ZTIR603',
                                            l_ctxmenu 'ZTIR603_C'.
*      ENDIF.


*      IF p_ztitig00-lgpcs NE 'D'.  ">결과등록만 사용일 경우.
        l_ctxmenu->add_separator( ).
*      ENDIF.

*A  의뢰->접수->승인(전송)->발급 단계사용
*B  의뢰->승인(전송)->발급 단계사용
*C  의뢰(전송)->발급 단계사용
*D  발급내역만 사용
*Z  미사용
*      CASE p_ztitig00-lgpcs.
*        WHEN 'A'.   ">
          PERFORM set_function_code   USING : l_ctxmenu 'ZTIT605',
                                              l_ctxmenu 'ZTIT606',
                                              l_ctxmenu 'ZTIT607'.
*        WHEN 'B'.
*          PERFORM set_function_code   USING : l_ctxmenu 'ZTIT606',
*                                              l_ctxmenu 'ZTIT607'.
*
*        WHEN 'C'.
*          PERFORM set_function_code   USING : l_ctxmenu 'ZTIT607'.
*
*        WHEN 'D'.
*        WHEN OTHERS.
*      ENDCASE.

      l_ctxmenu->add_separator( ).
      PERFORM set_function_code   USING : l_ctxmenu 'ZTIR601',
                                          l_ctxmenu 'ZTIR602'.

    WHEN 'MC'.   ">물량확정
      PERFORM set_function_code   USING : l_ctxmenu 'ZTIR290'.
**************************************************
*20130725 by jsh - GSC
*반입예정,반입,반출 정보 추가
    WHEN 'BS'.   "반입예정정보
      PERFORM set_function_code   USING : l_ctxmenu 'ZTIR450',
                                          l_ctxmenu 'ZTIT451',
                                          l_ctxmenu 'ZTIT452',
                                          l_ctxmenu 'ZTIT453',
                                          l_ctxmenu 'ZTIT454'.
    WHEN 'BI'.   "반입정보
      PERFORM set_function_code   USING : l_ctxmenu 'ZTIR460',
                                          l_ctxmenu 'ZTIT461',
                                          l_ctxmenu 'ZTIT462',
                                          l_ctxmenu 'ZTIT463',
                                          l_ctxmenu 'ZTIT464'.
    WHEN 'BO'.   "반출정보
      PERFORM set_function_code   USING : l_ctxmenu 'ZTIR470',
                                          l_ctxmenu 'ZTIT471',
                                          l_ctxmenu 'ZTIT472',
                                          l_ctxmenu 'ZTIT473',
                                          l_ctxmenu 'ZTIT474'.
**************************************************

    WHEN 'CR'.   ">통관
      PERFORM set_function_code   USING : l_ctxmenu 'ZTIR400',
*                                          l_ctxmenu 'ZTIR410',
                                          l_ctxmenu 'ZTIT401',
*                                          l_ctxmenu 'ZTIT409',
                                          l_ctxmenu 'ZTIR410',
                                          l_ctxmenu 'ZTIT402',
                                          l_ctxmenu 'ZTIT403',
                                          l_ctxmenu 'ZTIT404',
                                          l_ctxmenu 'ZTIR432'.
*      l_ctxmenu->add_separator( ).
*
*      PERFORM set_function_code   USING : l_ctxmenu 'ZTIR290'.

*      l_ctxmenu->add_separator( ).

**modify by jsh (20130808) ---start
**t-code : zddi130이 gs쪽에서만 사용되는 t-code여서 주석처리
    WHEN 'TD'.   ">부대비관리
*      PERFORM set_function_code   USING : l_ctxmenu 'ZDDI130'.
**modify by jsh (20130808) ---end


    WHEN 'CC'.   ">통관

      PERFORM set_function_code   USING : l_ctxmenu 'ZTIR430',
                                          l_ctxmenu 'ZTIT431',
                                          l_ctxmenu 'ZTIT432',
                                          l_ctxmenu 'ZTIT433',
                                          l_ctxmenu 'ZTIT434'.
      l_ctxmenu->add_separator( ).
      PERFORM set_function_code   USING : l_ctxmenu 'ZTIR401',
                                          l_ctxmenu 'ZTIR407',
                                          l_ctxmenu 'ZTIR408',
                                          l_ctxmenu 'ZTIR409'.
*
    WHEN 'GR'.   ">입고..

*      PERFORM set_function_code   USING :  l_ctxmenu 'ZTIR501',
*                                          l_ctxmenu 'ZTIR502'.
*      l_ctxmenu->add_separator( ).
      PERFORM set_function_code   USING : l_ctxmenu 'ZTIR500',
                                          l_ctxmenu 'ZTIR502',
                                          l_ctxmenu 'ZTIT501',
                                          l_ctxmenu 'ZTIT502',
                                          l_ctxmenu 'ZTIT503',
                                          l_ctxmenu 'ZTIT504',
                                          l_ctxmenu 'ZTIT505',
                                          l_ctxmenu 'ZTIT506'.
      l_ctxmenu->add_separator( ).
      PERFORM set_function_code   USING :
                                          l_ctxmenu 'ZTIR501',
                                          l_ctxmenu 'ZTIR508',
                                          l_ctxmenu 'ZTIR509'.

    WHEN 'CS'.   ">제비용...
      PERFORM set_function_code   USING :
                                          l_ctxmenu 'ZTIR911',
                                          l_ctxmenu 'ZTIR912',
                                          l_ctxmenu 'ZTIR918',
                                          l_ctxmenu 'ZTIR913',
                                          l_ctxmenu 'ZTIR914',
                                          l_ctxmenu 'ZTIR915'.

      l_ctxmenu->add_separator( ).
      PERFORM set_function_code   USING : l_ctxmenu 'ZTIR901',
                                          l_ctxmenu 'ZTIR9011',
*                                          l_ctxmenu 'ZTIR901',
                                          l_ctxmenu 'ZTIR902'.

    WHEN 'PN'.   ">인수확정.
      PERFORM set_function_code   USING : l_ctxmenu 'ZTIR800',
                                          l_ctxmenu 'ZTIT801',
                                          l_ctxmenu 'ZTIT802',
                                          l_ctxmenu 'ZTIT803',
                                          l_ctxmenu 'ZTIT804',
                                          l_ctxmenu 'ZTIT805',
                                          l_ctxmenu 'ZTIT806'.
      l_ctxmenu->add_separator( ).
      PERFORM set_function_code   USING : l_ctxmenu 'ZTIR802',
                                          l_ctxmenu 'ZTIR803',
                                          l_ctxmenu 'ZTIR805'.

    WHEN 'VA'.   ">세금계산서...
      PERFORM set_function_code   USING : l_ctxmenu 'ZTIR700',
*                                          l_ctxmenu 'ZTIT701',
                                          l_ctxmenu 'ZTIT702',
                                          l_ctxmenu 'ZTIT703',
                                          l_ctxmenu 'ZTIT704'.

      l_ctxmenu->add_separator( ).
      PERFORM set_function_code   USING : l_ctxmenu 'ZTIT705'.

      l_ctxmenu->add_separator( ).
      PERFORM set_function_code   USING : l_ctxmenu 'ZTIR701',
                                          l_ctxmenu 'ZTIR702'.

    WHEN 'AC'.   ">인수증...
      PERFORM set_function_code   USING : l_ctxmenu 'ZTIT720',
                                          l_ctxmenu 'ZTIT722',
                                          l_ctxmenu 'ZTIT722',
                                          l_ctxmenu 'ZTIT723',
                                          l_ctxmenu 'ZTIT724'.

      l_ctxmenu->add_separator( ).
      PERFORM set_function_code   USING : l_ctxmenu 'ZTIR721'.

    WHEN OTHERS.
      EXIT.
  ENDCASE.

ENDFORM.                    " BUILD_MENU_IMPORT


*&---------------------------------------------------------------------*
*&      Form  SET_FUNCTION_CODE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_L_CTXMENU  text
*      -->P_4756   text
*----------------------------------------------------------------------*
FORM set_function_code  USING    p_ctxmenu  TYPE REF TO cl_ctmenu
                                 p_tcode    TYPE tcode.


  DATA : l_entry  TYPE sctx_entry,
         ls_tstct TYPE tstct.


  SELECT SINGLE *
    INTO CORRESPONDING FIELDS OF ls_tstct
    FROM tstct
   WHERE sprsl EQ sy-langu
     AND tcode EQ p_tcode.

  IF sy-subrc NE 0.
    CASE p_tcode.
      WHEN 'ZTIR007_C'.
        ls_tstct-ttext = '수입의뢰 승인 취소'.
      WHEN 'ZTIR603_C'.
        ls_tstct-ttext = 'L/G 승인 취소'.
    ENDCASE.


  ENDIF.


  l_entry-text  = ls_tstct-ttext.
  l_entry-fcode = p_tcode.

  p_ctxmenu->add_function( fcode    =  l_entry-fcode
                           text     =  l_entry-text  ).

ENDFORM.                    " SET_FUNCTION_CODE
*&---------------------------------------------------------------------*
*&      Form  CALL_IR_DOCUMENT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_IT_DISP_EBELN  text
*      -->P_R_UCOMM  text
*----------------------------------------------------------------------*
FORM call_ir_document  USING   p_reqno
                               p_amdsq
                               p_ebeln
                               p_tcode.
  CHECK p_tcode IS NOT INITIAL.

  SET PARAMETER ID 'ZTIREQNO' FIELD p_reqno.
  SET PARAMETER ID 'ZTIAMDSQ' FIELD p_amdsq.
  SET PARAMETER ID 'BES'      FIELD p_ebeln.

  CALL TRANSACTION p_tcode AND SKIP FIRST SCREEN.

ENDFORM.                    " CALL_IR_DOCUMENT
*&---------------------------------------------------------------------*
*&      Form  CALL_IR_DOCUMENT_NEW
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_IT_DISP_EBELN  text
*      -->P_R_UCOMM  text
*----------------------------------------------------------------------*
FORM call_ir_document_new  USING  p_reqno
                                   p_amdsq
                                   p_ebeln
                                   p_docno
                                   p_tcode.
  CHECK p_tcode IS NOT INITIAL.

  SET PARAMETER ID 'ZTIREQNO' FIELD p_reqno.
  SET PARAMETER ID 'ZTIAMDSQ' FIELD p_amdsq.
  SET PARAMETER ID 'BES'      FIELD p_ebeln.

*--> Memory Clear.
  CLEAR : *ztitrqk.
  EXPORT *ztitrqk TO MEMORY ID 'Z_TI_IR_SAVE_DOCUMENT'.

*--> Call Transaction
  CALL TRANSACTION p_tcode AND SKIP FIRST SCREEN.

*--> Memory ID 받아오기...
  IMPORT *ztitrqk FROM MEMORY ID 'Z_TI_IR_SAVE_DOCUMENT'.

  CLEAR p_docno.
  IF *ztitrqk-reqno IS NOT INITIAL.
    p_docno = *ztitrqk-reqno.
  ENDIF.

  CLEAR : *ztitrqk.
  EXPORT *ztitrqk TO MEMORY ID 'Z_TI_IR_SAVE_DOCUMENT'.
  FREE MEMORY ID 'Z_TI_IR_SAVE_DOCUMENT'.

ENDFORM.                    " CALL_IR_DOCUMENT_NEW
*&---------------------------------------------------------------------*
*&      Form  CALL_LG_DOCUMENT_NEW
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_IT_DISP_EBELN  text
*      -->P_R_UCOMM  text
*----------------------------------------------------------------------*
FORM call_lg_document_new  USING  p_ilgno
                                   p_docno
                                   p_tcode
  .
  CHECK p_tcode IS NOT INITIAL.

  SET PARAMETER ID 'ZTIILGNO' FIELD p_ilgno.

*--> Memory Clear.
  CLEAR : *ztitlg1.
  EXPORT *ztitlg1 TO MEMORY ID 'Z_TI_LG_SAVE_DOCUMENT'.

*--> Call Transaction
  CALL TRANSACTION p_tcode AND SKIP FIRST SCREEN.

*--> Memory ID 받아오기...
  IMPORT *ztitlg1 FROM MEMORY ID 'Z_TI_LG_SAVE_DOCUMENT'.

  CLEAR p_docno.
  IF *ztitlg1-ilgno IS NOT INITIAL.
    p_docno = *ztitlg1-ilgno.
  ENDIF.

  CLEAR : *ztitlg1.
  EXPORT *ztitlg1 TO MEMORY ID 'Z_TI_LG_SAVE_DOCUMENT'.
  FREE MEMORY ID 'Z_TI_LG_SAVE_DOCUMENT'.

ENDFORM.                    " CALL_LG_DOCUMENT_NEW
*&---------------------------------------------------------------------*
*&      Form  CALL_BL_DOCUMENT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_IT_DISP_IBLNO  text
*      -->P_IT_DISP_REQNO  text
*      -->P_IT_DISP_EBELN  text
*      -->P_R_UCOMM  text
*----------------------------------------------------------------------*
FORM call_bl_document  USING p_iblno
                              p_reqno
                              p_ebeln
                              p_tcode.

  CHECK p_tcode IS NOT INITIAL.

  SET PARAMETER ID 'ZTIIBLNO' FIELD p_iblno.
  SET PARAMETER ID 'ZTIREQNO' FIELD p_reqno.
  SET PARAMETER ID 'BES'      FIELD p_ebeln.

  CALL TRANSACTION p_tcode AND SKIP FIRST SCREEN.

ENDFORM.                    " CALL_BL_DOCUMENT
*&---------------------------------------------------------------------*
*&      Form  CALL_BL_DOCUMENT_NEW
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_IT_DISP_IBLNO  text
*      -->P_IT_DISP_REQNO  text
*      -->P_IT_DISP_EBELN  text
*      -->P_R_UCOMM  text
*----------------------------------------------------------------------*
FORM call_bl_document_new  USING p_iblno
                                 p_reqno
                                 p_ebeln
                                 p_docno
                                 p_tcode.

  CHECK p_tcode IS NOT INITIAL.

  SET PARAMETER ID 'ZTIIBLNO'  FIELD p_iblno.
  SET PARAMETER ID 'ZTIBLNUM'  FIELD space.
  SET PARAMETER ID 'ZTIREQNO'  FIELD p_reqno.
  SET PARAMETER ID 'BES'       FIELD p_ebeln.

*--> Memory Clear.
  CLEAR : *ztitblk.
  EXPORT *ztitblk TO MEMORY ID 'Z_TI_BL_SAVE_DOCUMENT'.

*--> Call Transaction
  CALL TRANSACTION p_tcode AND SKIP FIRST SCREEN.

*--> Memory ID 받아오기...
  IMPORT *ztitblk FROM MEMORY ID 'Z_TI_BL_SAVE_DOCUMENT'.

  CLEAR p_docno.
  IF *ztitblk-iblno IS NOT INITIAL.
    p_docno = *ztitblk-iblno.
  ENDIF.

  CLEAR : *ztitblk.
  EXPORT *ztitblk TO MEMORY ID 'Z_TI_BL_SAVE_DOCUMENT'.
  FREE MEMORY ID 'Z_TI_BL_SAVE_DOCUMENT'.


ENDFORM.                    " CALL_BL_DOCUMENT_NEW
*&---------------------------------------------------------------------*
*&      Form  CALL_IV_DOCUMENT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_IT_DISP_IVONO  text
*      -->P_IT_DISP_IBLNO  text
*      -->P_R_UCOMM  text
*----------------------------------------------------------------------*
FORM call_iv_document  USING p_ivono
                              p_iblno
                              p_ebeln
                              p_tcode.

  CHECK p_tcode IS NOT INITIAL.

  SET PARAMETER ID 'ZTIIVONO'   FIELD p_ivono.
  SET PARAMETER ID 'ZTIIBLNO'   FIELD p_iblno.
  SET PARAMETER ID 'BES'        FIELD p_ebeln.

  CALL TRANSACTION p_tcode AND SKIP FIRST SCREEN.

ENDFORM.                    " CALL_IV_DOCUMENT
*&---------------------------------------------------------------------*
*&      Form  CALL_IV_DOCUMENT_NEW
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_IT_DISP_IVONO  text
*      -->P_IT_DISP_IBLNO  text
*      -->P_R_UCOMM  text
*----------------------------------------------------------------------*
FORM call_iv_document_new  USING p_ivono
                                 p_iblno
                                 p_ebeln
                                 p_docno
                                 p_tcode.

  CHECK p_tcode IS NOT INITIAL.

  SET PARAMETER ID 'ZTIIVONO'   FIELD p_ivono.
  SET PARAMETER ID 'ZTIIVNUM'   FIELD space.
  SET PARAMETER ID 'ZTIIBLNO'   FIELD p_iblno.
  SET PARAMETER ID 'ZTIBLNUM'   FIELD space.
  SET PARAMETER ID 'BES'        FIELD p_ebeln.

*--> Memory Clear.
  CLEAR : *ztitivk.
  EXPORT *ztitivk TO MEMORY ID 'Z_TI_IV_SAVE_DOCUMENT'.

*--> Call Transaction
  CALL TRANSACTION p_tcode AND SKIP FIRST SCREEN.

*--> Memory ID 받아오기...
  IMPORT *ztitivk FROM MEMORY ID 'Z_TI_IV_SAVE_DOCUMENT'.

  CLEAR p_docno.
  IF *ztitivk-ivono IS NOT INITIAL.
    p_docno = *ztitivk-ivono.

*---> 지출결의...
    PERFORM interface_pps_gsc(saplz_ti_main_for_iv)
            IF FOUND
            USING   *ztitivk.

  ENDIF.

  CLEAR : *ztitivk.
  EXPORT *ztitivk TO MEMORY ID 'Z_TI_IV_SAVE_DOCUMENT'.
  FREE MEMORY ID 'Z_TI_IV_SAVE_DOCUMENT'.

ENDFORM.                    " CALL_IV_DOCUMENT_NEW
*&---------------------------------------------------------------------*
*&      Form  CALL_CC_DOCUMENT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_IT_DISP_ICCNO  text
*      -->P_IT_DISP_ICCSQ  text
*      -->P_IT_DISP_IBLNO  text
*      -->P_IT_DISP_EBELN  text
*      -->P_R_UCOMM  text
*----------------------------------------------------------------------*
FORM call_cc_document  USING    p_iccno
                                p_iccsq
                                p_iblno
                                p_ebeln
                                p_tcode.

  CHECK p_tcode IS NOT INITIAL.

  SET PARAMETER ID 'ZTIICCNO'   FIELD p_iccno.
  SET PARAMETER ID 'ZTIICCSQ'   FIELD p_iccsq.
  SET PARAMETER ID 'ZTIIBLNO'   FIELD p_iblno.
  SET PARAMETER ID 'BES'        FIELD p_ebeln.

  CALL TRANSACTION p_tcode AND SKIP FIRST SCREEN.


ENDFORM.                    " CALL_CC_DOCUMENT
*&---------------------------------------------------------------------*
*&      Form  CALL_CC_DOCUMENT_NEW
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_IT_DISP_ICCNO  text
*      -->P_IT_DISP_ICCSQ  text
*      -->P_IT_DISP_IBLNO  text
*      -->P_IT_DISP_EBELN  text
*      -->P_R_UCOMM  text
*----------------------------------------------------------------------*
FORM call_cc_document_new  USING  p_iccno
                                  p_iccsq
                                  p_iblno
                                  p_blnum
                                  p_ebeln
                                  p_docno
                                  p_tcode.

  CHECK p_tcode IS NOT INITIAL.

  SET PARAMETER ID 'ZTIICCNO'   FIELD p_iccno.
  SET PARAMETER ID 'ZTIICCSQ'   FIELD p_iccsq.
  SET PARAMETER ID 'ZTIIBLNO'   FIELD p_iblno.
  SET PARAMETER ID 'ZTIBLNUM'   FIELD p_blnum.
  SET PARAMETER ID 'BES'        FIELD p_ebeln.

*--> Memory Clear.
  CLEAR : *ztitcrk.
  EXPORT *ztitcrk TO MEMORY ID 'Z_TI_CC_SAVE_DOCUMENT_GSC'.

*--> Call Transaction
  CALL TRANSACTION p_tcode AND SKIP FIRST SCREEN.

*--> Memory ID 받아오기...
  IMPORT *ztitcrk FROM MEMORY ID 'Z_TI_CC_SAVE_DOCUMENT_GSC'.

  CLEAR p_docno.
  IF *ztitcrk-iccno IS NOT INITIAL.
    p_docno = *ztitcrk-iccno.
  ENDIF.

  CLEAR : *ztitcrk.
  EXPORT *ztitcrk TO MEMORY ID 'Z_TI_CC_SAVE_DOCUMENT_GSC'.
  FREE MEMORY ID 'Z_TI_CC_SAVE_DOCUMENT_GSC'.

ENDFORM.                    " CALL_CC_DOCUMENT_NEW
*&---------------------------------------------------------------------*
*&      Form  CALL_GR_DOCUMENT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_IT_DISP_IGRNO  text
*      -->P_IT_DISP_ICCNO  text
*      -->P_IT_DISP_ICCSQ  text
*      -->P_IT_DISP_IBLNO  text
*      -->P_IT_DISP_EBELN  text
*      -->P_R_UCOMM  text
*----------------------------------------------------------------------*
FORM call_gr_document  USING    p_igrno
                                p_iccno
                                p_iccsq
                                p_iblno
                                p_ebeln
                                p_tcode.

  CHECK p_tcode IS NOT INITIAL.

  SET PARAMETER ID 'ZTIIGRNO'   FIELD p_igrno.
  SET PARAMETER ID 'ZTIICCNO'   FIELD p_iccno.
  SET PARAMETER ID 'ZTIICCSQ'   FIELD p_iccsq.
  SET PARAMETER ID 'ZTIIBLNO'   FIELD p_iblno.
  SET PARAMETER ID 'BES'        FIELD p_ebeln.

  CALL TRANSACTION p_tcode AND SKIP FIRST SCREEN.

ENDFORM.                    " CALL_GR_DOCUMENT
*&---------------------------------------------------------------------*
*&      Form  CALL_GR_DOCUMENT_NEW
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_IT_DISP_IGRNO  text
*      -->P_IT_DISP_ICCNO  text
*      -->P_IT_DISP_ICCSQ  text
*      -->P_IT_DISP_IBLNO  text
*      -->P_IT_DISP_EBELN  text
*      -->P_R_UCOMM  text
*----------------------------------------------------------------------*
FORM call_gr_document_new  USING    p_igrno
                                     p_iccno
                                     p_iccsq
                                     p_iblno
                                     p_ebeln
                                     p_docno
                                     p_tcode.

  CHECK p_tcode IS NOT INITIAL.

  SET PARAMETER ID 'ZTIIGRNO'   FIELD p_igrno.
  SET PARAMETER ID 'ZTIICCNO'   FIELD p_iccno.
  SET PARAMETER ID 'ZTIICCSQ'   FIELD p_iccsq.
  SET PARAMETER ID 'ZTIIBLNO'   FIELD p_iblno.
  SET PARAMETER ID 'BES'           FIELD p_ebeln.

*--> Memory Clear.
  CLEAR : *ztitgrk.
  EXPORT *ztitgrk TO MEMORY ID 'Z_TI_GR_SAVE_DOCUMENT'.

*--> Call Transaction
  CALL TRANSACTION p_tcode AND SKIP FIRST SCREEN.

*--> Memory ID 받아오기...
  IMPORT *ztitgrk FROM MEMORY ID 'Z_TI_GR_SAVE_DOCUMENT'.

  CLEAR p_docno.
  IF *ztitgrk-iccno IS NOT INITIAL.
    p_docno = *ztitgrk-iccno.
  ENDIF.

  CLEAR : *ztitgrk.
  EXPORT *ztitgrk TO MEMORY ID 'Z_TI_GR_SAVE_DOCUMENT'.
  FREE MEMORY ID 'Z_TI_GR_SAVE_DOCUMENT'.
ENDFORM.                    " CALL_GR_DOCUMENT_NEW
*&---------------------------------------------------------------------*
*&      Form  CALL_PN_DOCUMENT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_IT_DISP_PNTNO  text
*      -->P_IT_DISP_IVONO  text
*      -->P_IT_DISP_IBLNO  text
*      -->P_R_UCOMM  text
*----------------------------------------------------------------------*
FORM call_pn_document  USING  p_pntno
                              p_ivono
                              p_iblno
                              p_tcode.
  CHECK p_tcode IS NOT INITIAL.

  SET PARAMETER ID 'ZTIPNTNO'   FIELD p_pntno.
  SET PARAMETER ID 'ZTIIVONO'   FIELD p_ivono.
  SET PARAMETER ID 'ZTIIBLNO'   FIELD p_iblno.

  CALL TRANSACTION p_tcode AND SKIP FIRST SCREEN.

ENDFORM.                    " CALL_PN_DOCUMENT
*&---------------------------------------------------------------------*
*&      Form  CALL_PN_DOCUMENT_NEW
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_IT_DISP_PNTNO  text
*      -->P_IT_DISP_IVONO  text
*      -->P_IT_DISP_IBLNO  text
*      -->P_R_UCOMM  text
*----------------------------------------------------------------------*
FORM call_pn_document_new  USING  p_pntno
                                  p_ivono
                                  p_iblno
                                  p_docno
                                  p_tcode.
  CHECK p_tcode IS NOT INITIAL.

  SET PARAMETER ID 'ZTIPNTNO'   FIELD p_pntno.
  SET PARAMETER ID 'ZTIIVONO'   FIELD p_ivono.
  SET PARAMETER ID 'ZTIIBLNO'   FIELD p_iblno.

*--> Memory Clear.
  CLEAR : *ztitpnk.
  EXPORT *ztitgrk TO MEMORY ID 'Z_TI_PN_SAVE_DOCUMENT'.

*--> Call Transaction
  CALL TRANSACTION p_tcode AND SKIP FIRST SCREEN.

*--> Memory ID 받아오기...
  IMPORT *ztitpnk FROM MEMORY ID 'Z_TI_PN_SAVE_DOCUMENT'.

  CLEAR p_docno.
  IF *ztitpnk-pntno IS NOT INITIAL.
    p_docno = *ztitpnk-pntno.
  ENDIF.

  CLEAR : *ztitpnk.
  EXPORT *ztitpnk TO MEMORY ID 'Z_TI_PN_SAVE_DOCUMENT'.
  FREE MEMORY ID 'Z_TI_PN_SAVE_DOCUMENT'.
ENDFORM.                    " CALL_PN_DOCUMENT_NEW
*&---------------------------------------------------------------------*
*&      Form  CALL_CS_DOCUMENT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_IT_DISP_BUKRS  text
*      -->P_IT_DISP_ICSNO  text
*      -->P_IT_DISP_REQNO  text
*      -->P_IT_DISP_AMDSQ  text
*      -->P_IT_DISP_OSNUM  text
*      -->P_IT_DISP_IBLNO  text
*      -->P_IT_DISP_ICCNO  text
*      -->P_R_UCOMM  text
*----------------------------------------------------------------------*
FORM call_cs_document  USING   p_bukrs
                                p_icsno
                                p_tcode.
  CHECK p_tcode IS NOT INITIAL.

  SET PARAMETER ID 'BUK'           FIELD p_bukrs.
  SET PARAMETER ID 'ZTIICSNO'      FIELD p_icsno.


  CALL TRANSACTION p_tcode AND SKIP FIRST SCREEN.
ENDFORM.                    " CALL_CS_DOCUMENT
*&---------------------------------------------------------------------*
*&      Form  CALL_CS_DOCUMENT_NEW
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_IT_DISP_BUKRS  text
*      -->P_IT_DISP_ICSNO  text
*      -->P_IT_DISP_REQNO  text
*      -->P_IT_DISP_AMDSQ  text
*      -->P_IT_DISP_OSNUM  text
*      -->P_IT_DISP_IBLNO  text
*      -->P_IT_DISP_ICCNO  text
*      -->P_R_UCOMM  text
*----------------------------------------------------------------------*
FORM call_cs_document_new  USING   p_bukrs
                                   p_icsno
                                   p_docno
                                   p_tcode.
  CHECK p_tcode IS NOT INITIAL.

  SET PARAMETER ID 'BUK'           FIELD p_bukrs.
  SET PARAMETER ID 'ZTIICSNO'      FIELD p_icsno.

*--> Memory Clear.
  CLEAR : *ztitcsk.
  EXPORT *ztitcsk TO MEMORY ID 'Z_TI_CS_SAVE_DOCUMENT'.

*--> Call Transaction
  CALL TRANSACTION p_tcode AND SKIP FIRST SCREEN.

*--> Memory ID 받아오기...
  IMPORT *ztitcsk FROM MEMORY ID 'Z_TI_CS_SAVE_DOCUMENT'.

  CLEAR p_docno.
  IF *ztitcsk-icsno IS NOT INITIAL.
    p_docno = *ztitcsk-icsno.
  ENDIF.

  CLEAR : *ztitcsk.
  EXPORT *ztitcsk TO MEMORY ID 'Z_TI_CS_SAVE_DOCUMENT'.
  FREE MEMORY ID 'Z_TI_CS_SAVE_DOCUMENT'.

ENDFORM.                    " CALL_CS_DOCUMENT_NEW
*&---------------------------------------------------------------------*
*&      Form  CALL_VA_DOCUMENT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_IT_DISP_VATNO  text
*      -->P_R_UCOMM  text
*----------------------------------------------------------------------*
FORM call_va_document  USING    p_bukrs
                                p_vatno
                                p_reqno
                                p_tcode.

  CHECK p_tcode IS NOT INITIAL.

  SET PARAMETER ID 'BUK'           FIELD p_bukrs.
  SET PARAMETER ID 'ZTIVATNO'      FIELD p_vatno.
  SET PARAMETER ID 'ZTIREQNO'      FIELD p_reqno.

  CALL TRANSACTION p_tcode AND SKIP FIRST SCREEN.

ENDFORM.                    " CALL_VA_DOCUMENT
*&---------------------------------------------------------------------*
*&      Form  CALL_VA_DOCUMENT_NEW
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_IT_DISP_VATNO  text
*      -->P_R_UCOMM  text
*----------------------------------------------------------------------*
FORM call_va_document_new  USING    p_bukrs
                                     p_vatno
                                     p_reqno
                                     p_docno
                                     p_tcode.

  CHECK p_tcode IS NOT INITIAL.

  SET PARAMETER ID 'BUK'           FIELD p_bukrs.
  SET PARAMETER ID 'ZTIVATNO'      FIELD p_vatno.
  SET PARAMETER ID 'ZTIREQNO'      FIELD p_reqno.

*--> Memory Clear.
  CLEAR : *ztitvak.
  EXPORT *ztitvak TO MEMORY ID 'Z_TI_VT_SAVE_DOCUMENT'.

*--> Call Transaction
  CALL TRANSACTION p_tcode AND SKIP FIRST SCREEN.

*--> Memory ID 받아오기...
  IMPORT *ztitvak FROM MEMORY ID 'Z_TI_VT_SAVE_DOCUMENT'.

  CLEAR p_docno.
  IF *ztitvak-vatno IS NOT INITIAL.
    p_docno = *ztitvak-vatno.
  ENDIF.

  CLEAR : *ztitvak.
  EXPORT *ztitvak TO MEMORY ID 'Z_TI_VT_SAVE_DOCUMENT'.
  FREE MEMORY ID 'Z_TI_VT_SAVE_DOCUMENT'.

ENDFORM.                    " CALL_VA_DOCUMENT_NEW
*&---------------------------------------------------------------------*
*&      Form  CALL_AC_DOCUMENT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_IT_DISP_BUKRS  text
*      -->P_IT_DISP_ACDNO  text
*      -->P_R_UCOMM  text
*----------------------------------------------------------------------*
FORM call_ac_document  USING    p_bukrs
                                p_acdno
                                p_tcode.

  CHECK p_tcode IS NOT INITIAL.

  SET PARAMETER ID 'BUK'          FIELD p_bukrs.
  SET PARAMETER ID 'ZTIACDNO'     FIELD p_acdno.

  CALL TRANSACTION p_tcode AND SKIP FIRST SCREEN.

ENDFORM.                    " CALL_AC_DOCUMENT
*&---------------------------------------------------------------------*
*&      Form  CALL_AC_DOCUMENT_NEW
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_IT_DISP_BUKRS  text
*      -->P_IT_DISP_ACDNO  text
*      -->P_L_DOCNO  text
*      -->P_R_UCOMM  text
*----------------------------------------------------------------------*
FORM call_ac_document_new  USING    p_bukrs
                                     p_acdno
                                     p_docno
                                     p_tcode.

  CHECK p_tcode IS NOT INITIAL.

  SET PARAMETER ID 'BUK'          FIELD p_bukrs.
  SET PARAMETER ID 'ZTIACDNO'     FIELD p_acdno.

*--> Memory Clear.
  CLEAR : *ztitack.
  EXPORT *ztitack TO MEMORY ID 'Z_TI_AC_SAVE_DOCUMENT'.

*--> Call Transaction
  CALL TRANSACTION p_tcode AND SKIP FIRST SCREEN.

*--> Memory ID 받아오기...
  IMPORT *ztitack FROM MEMORY ID 'Z_TI_AC_SAVE_DOCUMENT'.

  CLEAR p_docno.
  IF *ztitack-acdno IS NOT INITIAL.
    p_docno = *ztitack-acdno.
  ENDIF.

  CLEAR : *ztitack.
  EXPORT *ztitack TO MEMORY ID 'Z_TI_AC_SAVE_DOCUMENT'.
  FREE MEMORY ID 'Z_TI_AC_SAVE_DOCUMENT'.

ENDFORM.                    " CALL_AC_DOCUMENT_NEW
*&---------------------------------------------------------------------*
*&      Form  CALL_TX_DOCUMENT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_IT_DISP_BUKRS  text
*      -->P_IT_DISP_ACDNO  text
*      -->P_R_UCOMM  text
*----------------------------------------------------------------------*
FORM call_tx_document  USING    p_bukrs
                                p_taxno
                                p_tcode.

  CHECK p_tcode IS NOT INITIAL.

  SET PARAMETER ID 'BUK'          FIELD p_bukrs.
  SET PARAMETER ID 'ZTITAXNO'     FIELD p_taxno.

  CALL TRANSACTION p_tcode AND SKIP FIRST SCREEN.

ENDFORM.                    " CALL_TX_DOCUMENT
*&---------------------------------------------------------------------*
*&      Form  CALL_TX_DOCUMENT_NEW
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_IT_DISP_BUKRS  text
*      -->P_IT_DISP_ACDNO  text
*      -->P_R_UCOMM  text
*----------------------------------------------------------------------*
FORM call_tx_document_new  USING p_bukrs
                                 p_taxno
                                 p_docno
                                 p_tcode.

  CHECK p_tcode IS NOT INITIAL.

  SET PARAMETER ID 'BUK'          FIELD p_bukrs.
  SET PARAMETER ID 'ZTITAXNO'     FIELD p_taxno.

*--> Memory Clear.
  CLEAR : *ztittxk.
  EXPORT *ztittxk TO MEMORY ID 'Z_TI_TX_SAVE_DOCUMENT'.

*--> Call Transaction
  CALL TRANSACTION p_tcode AND SKIP FIRST SCREEN.

*--> Memory ID 받아오기...
  IMPORT *ztittxk FROM MEMORY ID 'Z_TI_TX_SAVE_DOCUMENT'.

  CLEAR p_docno.
  IF *ztittxk-taxno IS NOT INITIAL.
    p_docno = *ztittxk-taxno.
  ENDIF.

  CLEAR : *ztittxk.
  EXPORT *ztittxk TO MEMORY ID 'Z_TI_TX_SAVE_DOCUMENT'.
  FREE MEMORY ID 'Z_TI_TX_SAVE_DOCUMENT'.
ENDFORM.                    " CALL_TX_DOCUMENT_NEW
*&---------------------------------------------------------------------*
*&      Form  BUILD_MENU_IMPORT_LO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_P_CTXMENU  text
*      -->P_5729   text
*----------------------------------------------------------------------*
FORM build_menu_import_lo  USING p_ctxmenu TYPE REF TO cl_ctmenu
                                  p_menu_type.

  DATA: l_ctxmenu TYPE REF TO cl_ctmenu,
        l_icon    TYPE icon_d,
        l_entry   TYPE sctx_entry.

  CREATE OBJECT l_ctxmenu.


***************************************************
******************>> 서브 메뉴 관련...
***************************************************
  CASE p_menu_type.
    WHEN 'VA'.   ">레포트..
      l_entry-icon = icon_led_green.
      l_entry-text = text-012.
    WHEN 'AC'.   ">레포트..
      l_entry-icon = icon_led_green.
      l_entry-text = text-013.
    WHEN OTHERS.
      EXIT.
  ENDCASE.


  p_ctxmenu->add_submenu( menu        = l_ctxmenu
                          text        = l_entry-text
                          icon        = l_entry-icon ).
*                                disabled    = <l_menu>-disabled
*                                hidden      =
*                                accelerator = <l_menu>-accelerator ).

  CASE p_menu_type.
    WHEN 'VA'.   ">세금계산서
      PERFORM set_function_code USING : l_ctxmenu 'ZTIT701',
                                        l_ctxmenu 'ZTIT702',
                                        l_ctxmenu 'ZTIT703',
                                        l_ctxmenu 'ZTIT704',
                                        l_ctxmenu 'ZTIT705',
                                        l_ctxmenu 'ZTIR701',
                                        l_ctxmenu 'ZTIR702'.

    WHEN 'AC'. "> 인수증
      PERFORM set_function_code USING : l_ctxmenu 'ZTIT721',
                                        l_ctxmenu 'ZTIT722',
                                        l_ctxmenu 'ZTIT723',
                                        l_ctxmenu 'ZTIT724',
                                        l_ctxmenu 'ZTIR721'.
*                                        l_ctxmenu 'ZTIT720',


  ENDCASE.

ENDFORM.                    " BUILD_MENU_IMPORT_LO
*&---------------------------------------------------------------------*
*&      Form  call_bs_document_new
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_IT_DISP_IBSNO  text
*      -->P_L_DOCNO  text
*      -->P_R_UCOMM  text
*----------------------------------------------------------------------*
FORM call_bs_document_new  USING    p_ibsno
                                                            p_docno
                                                            p_tcode.


  CHECK p_tcode IS NOT INITIAL.

  SET PARAMETER ID 'ZTIIBSNO'  FIELD p_ibsno.
  SET PARAMETER ID 'ZTIBLNUM'  FIELD space.

*--> Memory Clear.
  CLEAR : *ztitbsk.
  EXPORT *ztitbsk TO MEMORY ID 'Z_TI_BS_SAVE_DOCUMENT'.

*--> Call Transaction
  CALL TRANSACTION p_tcode AND SKIP FIRST SCREEN.

*--> Memory ID 받아오기...
  IMPORT *ztitbsk FROM MEMORY ID 'Z_TI_BS_SAVE_DOCUMENT'.

  CLEAR p_docno.
  IF *ztitbsk-ibsno IS NOT INITIAL.
    p_docno = *ztitbsk-ibsno.
  ENDIF.

  CLEAR : *ztitbsk.
  EXPORT *ztitbsk TO MEMORY ID 'Z_TI_BS_SAVE_DOCUMENT'.
  FREE MEMORY ID 'Z_TI_BS_SAVE_DOCUMENT'.

ENDFORM.                    " call_bs_document_new

*&---------------------------------------------------------------------*
*&      Form  call_bI_document_new
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_IBINO    text
*      -->P_DOCNO    text
*      -->P_TCODE    text
*----------------------------------------------------------------------*
FORM call_bi_document_new  USING    p_ibino
                                                            p_blnum
                                                            p_docno
                                                            p_tcode.


  CHECK p_tcode IS NOT INITIAL.

  SET PARAMETER ID 'ZTIIBINO'  FIELD p_ibino.
  SET PARAMETER ID 'ZTIBLNUM'  FIELD space.

*--> Memory Clear.
  CLEAR : *ztitbik.
  EXPORT *ztitbik TO MEMORY ID 'Z_TI_BI_SAVE_DOCUMENT'.

*--> Call Transaction
  CALL TRANSACTION p_tcode AND SKIP FIRST SCREEN.

*--> Memory ID 받아오기...
  IMPORT *ztitbik FROM MEMORY ID 'Z_TI_BI_SAVE_DOCUMENT'.

  CLEAR p_docno.
  IF *ztitbik-ibino IS NOT INITIAL.
    p_docno = *ztitbik-ibino.
  ENDIF.

  CLEAR : *ztitbik.
  EXPORT *ztitbik TO MEMORY ID 'Z_TI_BI_SAVE_DOCUMENT'.
  FREE MEMORY ID 'Z_TI_BI_SAVE_DOCUMENT'.

ENDFORM.                    " call_bs_document_new

*&---------------------------------------------------------------------*
*&      Form  call_bO_document_new
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_IBONO    text
*      -->P_DOCNO    text
*      -->P_TCODE    text
*----------------------------------------------------------------------*
FORM call_bo_document_new  USING    p_ibono
                                                            p_blnum
                                                            p_docno
                                                            p_tcode.


  CHECK p_tcode IS NOT INITIAL.

  SET PARAMETER ID 'ZTIIBONO'  FIELD p_ibono.
  SET PARAMETER ID 'ZTIBLNUM'  FIELD space.

*--> Memory Clear.
  CLEAR : *ztitbok.
  EXPORT *ztitbok TO MEMORY ID 'Z_TI_BO_SAVE_DOCUMENT'.

*--> Call Transaction
  CALL TRANSACTION p_tcode AND SKIP FIRST SCREEN.

*--> Memory ID 받아오기...
  IMPORT *ztitbok FROM MEMORY ID 'Z_TI_BO_SAVE_DOCUMENT'.

  CLEAR p_docno.
  IF *ztitbok-ibono IS NOT INITIAL.
    p_docno = *ztitbok-ibono.
  ENDIF.

  CLEAR : *ztitbok.
  EXPORT *ztitbok TO MEMORY ID 'Z_TI_BO_SAVE_DOCUMENT'.
  FREE MEMORY ID 'Z_TI_BO_SAVE_DOCUMENT'.

ENDFORM.                    " call_bs_document_new

*&---------------------------------------------------------------------*
*&      Form  call_IP_document_new
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_IIPNO    text
*      -->P_DOCNO    text
*      -->P_TCODE    text
*----------------------------------------------------------------------*
FORM call_ip_document_new  USING    p_iipno
                                     p_amdsq
                                     p_docno
                                     p_tcode.


  CHECK p_tcode IS NOT INITIAL.

  SET PARAMETER ID 'ZTIIIPNO'  FIELD p_iipno.
  SET PARAMETER ID 'ZTIAMSEQ'  FIELD p_amdsq.
  SET PARAMETER ID 'BES'       FIELD space.

*--> Memory Clear.
  CLEAR : *ztitip1.
  EXPORT *ztitip1 TO MEMORY ID 'Z_TI_IP_SAVE_DOCUMENT'.

*--> Call Transaction
  CALL TRANSACTION p_tcode AND SKIP FIRST SCREEN.

*--> Memory ID 받아오기...
  IMPORT *ztitip1 FROM MEMORY ID 'Z_TI_IP_SAVE_DOCUMENT'.

  CLEAR p_docno.
  IF *ztitip1-iipno IS NOT INITIAL.
    p_docno = *ztitip1-iipno.
  ENDIF.

  CLEAR : *ztitip1.
  EXPORT *ztitip1 TO MEMORY ID 'Z_TI_IP_SAVE_DOCUMENT'.
  FREE MEMORY ID 'Z_TI_IP_SAVE_DOCUMENT'.

ENDFORM.                    " call_bs_document_new

*&---------------------------------------------------------------------*
*&      Form  CHECK_IR_TRANSACTION
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_5516   text
*      -->P_L_RETURN  text
*----------------------------------------------------------------------*
FORM check_ir_transaction  USING    p_ztitig00 LIKE ztitig00
                                    p_tcode
                                    p_return.

*  RANGES : lr_rqpcs FOR ztitig00-lcpcs OCCURS 2.
*
*  CLEAR : p_return.
*
*  CLEAR : lr_rqpcs[], lr_rqpcs.
*  lr_rqpcs-sign   = 'I'.
*  lr_rqpcs-option = 'EQ'.
*
*  CASE p_tcode.
*    WHEN 'ZTIT005'.   "> 접수..
*      lr_rqpcs-low    = 'A'.    APPEND lr_rqpcs.
*      lr_rqpcs-low    = 'B'.    APPEND lr_rqpcs.
*    WHEN 'ZTIT006'.   "> 은행지정...
*      lr_rqpcs-low    = 'D'.    APPEND lr_rqpcs.
*    WHEN 'ZTIT009'.   "> 전송......
*      lr_rqpcs-low    = 'A'.    APPEND lr_rqpcs.
*      lr_rqpcs-low    = 'B'.    APPEND lr_rqpcs.
*      lr_rqpcs-low    = 'C'.    APPEND lr_rqpcs.
*      lr_rqpcs-low    = 'F'.    APPEND lr_rqpcs.
*    WHEN OTHERS.
*      p_return = ' '.
*      EXIT.
*  ENDCASE.
*
*  IF p_ztitig00-lcpcs IN lr_rqpcs OR
*     p_ztitig00-lopcs IN lr_rqpcs OR
*     p_ztitig00-vlpcs IN lr_rqpcs OR
*     p_ztitig00-vppcs IN lr_rqpcs OR
*     p_ztitig00-vdpcs IN lr_rqpcs OR
*     p_ztitig00-ttpcs IN lr_rqpcs OR
*     p_ztitig00-etpcs IN lr_rqpcs OR
*     p_ztitig00-pupcs IN lr_rqpcs OR
*     p_ztitig00-dapcs IN lr_rqpcs OR
*     p_ztitig00-dpprs IN lr_rqpcs .
*    p_return = 'X'.
*  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  CALL_LG_REQUEST_OF_IMPORT
*&---------------------------------------------------------------------*
*> 2015/10/28 HyeungJungKim L/G 로직이 없어서 추가.
*----------------------------------------------------------------------*
FORM call_lg_request_of_import          USING    p_func_mod_name
                                              p_ssf_name
                                              p_edity
                                              p_imexi
                                              p_refno
                                              p_amdsq
                                              p_ediyn
  " EDI 구분자(EDI :E, 그 외 space)
                                              p_subrc
                                     CHANGING p_mail_appl_obj
                                              p_mail_recipient
                                              p_mail_sender
                                              p_control_parameters
                                              p_output_options
                                              p_document_output_info
                                              p_job_output_info
                                              p_job_output_options.



  DATA : l_reqno TYPE  ztireqno,
         l_amdsq TYPE  ztiamdsq.

  DATA : l_docty TYPE c.

  CLEAR : p_subrc, l_docty.

  IF p_ediyn EQ 'E'. " EDI일 경우.

    SELECT SINGLE *
      FROM ztstedis
     WHERE sncnt EQ p_refno.

    IF sy-subrc NE 0.
      MESSAGE s902(zmts00).
      p_subrc = 4.
      EXIT.
    ENDIF.

    l_reqno = ztstedis-refno.
    l_amdsq = ztstedis-amdsq.

  ELSEIF p_ediyn IS INITIAL. " EDI 아닐 경우.
    l_reqno = p_refno.
    l_amdsq = p_amdsq.

  ENDIF.

  IF l_reqno IS INITIAL.
    MESSAGE s902(zmts00).
    p_subrc = 4.
    EXIT.
  ENDIF.


  SELECT SINGLE *
    FROM ztitlg1
   WHERE ilgno EQ l_reqno.

  IF sy-subrc NE 0.
    MESSAGE s902(zmts00).
    p_subrc = 4.
    EXIT.
  ENDIF.

  IF p_edity(6) EQ 'APPLOG'.  " 신청서
    l_docty = 'S'.
  ELSEIF p_edity(6) EQ 'LOGUAR'.  " 보증서
    l_docty = 'R'.
  ENDIF.

  CALL FUNCTION p_func_mod_name
    EXPORTING
*     ARCHIVE_INDEX        =
*     ARCHIVE_INDEX_TAB    =
*     ARCHIVE_PARAMETERS   =
      mail_appl_obj        = p_mail_appl_obj
      mail_recipient       = p_mail_recipient
      mail_sender          = p_mail_sender
      user_settings        = space
      control_parameters   = p_control_parameters
      output_options       = p_output_options
      ztitlg1              = ztitlg1
      i_doc_gubun          = l_docty
    IMPORTING
      document_output_info = p_document_output_info
      job_output_info      = p_job_output_info
      job_output_options   = p_job_output_options
    EXCEPTIONS
      formatting_error     = 1
      internal_error       = 2
      send_error           = 3
      user_canceled        = 4
      OTHERS               = 5.

  IF sy-subrc <> 0.
*       MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
    MESSAGE ID sy-msgid TYPE 'S' NUMBER sy-msgno
           WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    EXIT.
  ENDIF.

ENDFORM.                    " CALL_LG_REQUEST_OF_IMPORT
*&---------------------------------------------------------------------*
*&      Form  call_ti_ip_request_of_import
*&---------------------------------------------------------------------*
*> 2015/11/03 HyeungJungKim 수입 I/P 로직이 없어서 추가.
*----------------------------------------------------------------------*
FORM call_ti_ip_request_of_import          USING    p_func_mod_name
                                              p_ssf_name
                                              p_edity
                                              p_imexi
                                              p_refno
                                              p_amdsq
                                              p_ediyn
  " EDI 구분자(EDI :E, 그 외 space)
                                              p_subrc
                                     CHANGING p_mail_appl_obj
                                              p_mail_recipient
                                              p_mail_sender
                                              p_control_parameters
                                              p_output_options
                                              p_document_output_info
                                              p_job_output_info
                                              p_job_output_options.


  TABLES: ztitip1.

  DATA : l_iipno TYPE  ztiiipno,
         l_amdsq TYPE  ztiamseq.

  DATA : l_docty TYPE c.

  CLEAR : p_subrc, l_docty.

  IF p_ediyn EQ 'E'. " EDI일 경우.

    SELECT SINGLE *
      FROM ztstedis
     WHERE sncnt EQ p_refno.

    IF sy-subrc NE 0.
      MESSAGE s902(zmts00).
      p_subrc = 4.
      EXIT.
    ENDIF.

    l_iipno = ztstedis-refno.
    l_amdsq = ztstedis-amdsq.

  ELSEIF p_ediyn IS INITIAL. " EDI 아닐 경우.
    l_iipno = p_refno.
    l_amdsq = p_amdsq.

  ENDIF.

  IF l_iipno IS INITIAL.
    MESSAGE s902(zmts00).
    p_subrc = 4.
    EXIT.
  ENDIF.


  SELECT SINGLE *
    FROM ztitip1
   WHERE iipno EQ l_iipno
     AND amdsq EQ l_amdsq.

  IF sy-subrc NE 0.
    MESSAGE s902(zmts00).
    p_subrc = 4.
    EXIT.
  ENDIF.

  IF p_edity(6) EQ 'APPCIP'.  " 신청서
    l_docty = 'S'.
  ELSEIF p_edity(6) EQ 'CIPADV'.  " 보증서
    l_docty = 'R'.
  ENDIF.


  CALL FUNCTION p_func_mod_name
    EXPORTING
*     ARCHIVE_INDEX        =
*     ARCHIVE_INDEX_TAB    =
*     ARCHIVE_PARAMETERS   =
      mail_appl_obj        = p_mail_appl_obj
      mail_recipient       = p_mail_recipient
      mail_sender          = p_mail_sender
      user_settings        = space
      control_parameters   = p_control_parameters
      output_options       = p_output_options
      ztitip1              = ztitip1
*     ztitipa              = ztitipa
      i_doc_gubun          = l_docty
    IMPORTING
      document_output_info = p_document_output_info
      job_output_info      = p_job_output_info
      job_output_options   = p_job_output_options
*    TABLES
*     it_tline             =
*     it_sline             =
    EXCEPTIONS
      formatting_error     = 1
      internal_error       = 2
      send_error           = 3
      user_canceled        = 4
      OTHERS               = 5.

  IF sy-subrc <> 0.
*       MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
    MESSAGE ID sy-msgid TYPE 'S' NUMBER sy-msgno
           WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    EXIT.
  ENDIF.

ENDFORM.                    " call_ti_ip_request_of_import
*&---------------------------------------------------------------------*
*&      Form  CALL_REQUEST_OF_IMPORT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_P_FUNC_MOD_NAME  text
*      -->P_P_SSF_NAME  text
*      -->P_P_EDITY  text
*      -->P_P_IMEXI  text
*      -->P_P_REFNO  text
*      -->P_P_AMDSQ  text
*      <--P_P_MAIL_APPL_OBJ  text
*      <--P_P_MAIL_RECIPIENT  text
*      <--P_P_MAIL_SENDER  text
*      <--P_P_CONTROL_PARAMETERS  text
*      <--P_P_OUTPUT_OPTIONS  text
*      <--P_P_DOCUMENT_OUTPUT_INFO  text
*      <--P_P_JOB_OUTPUT_INFO  text
*      <--P_P_JOB_OUTPUT_OPTIONS  text
*----------------------------------------------------------------------*
FORM call_request_of_import          USING    p_func_mod_name
                                              p_ssf_name
                                              p_edity
                                              p_imexi
                                              p_refno
                                              p_amdsq
                                              p_ediyn
  " EDI 구분자(EDI :E, 그 외 space)
                                              p_subrc
                                     CHANGING p_mail_appl_obj
                                              p_mail_recipient
                                              p_mail_sender
                                              p_control_parameters
                                              p_output_options
                                              p_document_output_info
                                              p_job_output_info
                                              p_job_output_options.

  TABLES : ztitrqk,
           ztitrqs,
           ztitlc1,
           ztitlc5,
           ztitlo1,
           ztitpc1,
           ztittt1.

  DATA : lt_ztitrqp  LIKE  ztisrqit OCCURS 0 WITH HEADER LINE,
         lt_vztitrqp LIKE  vztitrqp OCCURS 0 WITH HEADER LINE,
         lt_ztitlc2  LIKE  vztitlc2 OCCURS 0 WITH HEADER LINE,
         lt_ztitlc3  LIKE  vztitlc3 OCCURS 0 WITH HEADER LINE,
         lt_ztitpc2  LIKE  vztitpc2 OCCURS 0 WITH HEADER LINE,
         lt_ztitpc3  LIKE  vztitpc3 OCCURS 0 WITH HEADER LINE,
*         lt_ztitpc4  LIKE  ztispc4  OCCURS 0 WITH HEADER LINE,
         lt_ztittt2  LIKE  vztittt2 OCCURS 0 WITH HEADER LINE,
         lt_ztittt3  LIKE  vztittt3 OCCURS 0 WITH HEADER LINE,
         lt_ztittt4  LIKE  ztistt4  OCCURS 0 WITH HEADER LINE.


  DATA : l_reqno TYPE  ztireqno,
         l_amdsq TYPE  ztiamdsq.

  DATA : l_pures TYPE  c.

  STATICS : l_doc_gubun TYPE c.

  CLEAR : p_subrc, l_pures.

  IF p_ediyn EQ 'E'. " EDI일 경우.

    SELECT SINGLE *
      FROM ztstedis
     WHERE sncnt EQ p_refno.

    IF sy-subrc NE 0.
      MESSAGE s902(zmts00).
      p_subrc = 4.
      EXIT.
    ENDIF.

    l_reqno = ztstedis-refno.
    l_amdsq = ztstedis-amdsq.

  ELSEIF p_ediyn IS INITIAL. " EDI 아닐 경우.
    l_reqno = p_refno.
    l_amdsq = p_amdsq.

  ENDIF.

  IF l_reqno IS INITIAL.
    MESSAGE s902(zmts00).
    p_subrc = 4.
    EXIT.
  ENDIF.

  CALL FUNCTION 'Z_TI_GET_REQUEST_OF_IMPORT'
    EXPORTING
      reqno     = l_reqno
      amdsq     = l_amdsq
    IMPORTING
      ztitrqk   = ztitrqk
      ztitrqs   = ztitrqs
      ztitlc1   = ztitlc1
      ztitlc5   = ztitlc5
      ztitlo1   = ztitlo1
      ztitpc1   = ztitpc1
      ztittt1   = ztittt1
    TABLES
      ztitrqp   = lt_ztitrqp
      ztitlc2   = lt_ztitlc2
      ztitlc3   = lt_ztitlc3
      ztitpc2   = lt_ztitpc2
      ztitpc3   = lt_ztitpc3
*      ztitpc4   = lt_ztitpc4
      ztittt2   = lt_ztittt2
      ztittt3   = lt_ztittt3
    EXCEPTIONS
      not_found = 1
      OTHERS    = 2.
*
  IF NOT l_pures IS INITIAL.  " 구매 확인서 응답서의 경우..
    CLEAR : ztitrqs-rcvno.
  ENDIF.

  IF sy-subrc NE 0.
    MESSAGE s902(zmts00).
    p_subrc = 4.
    EXIT.
  ENDIF.

  REFRESH lt_vztitrqp.

  LOOP AT lt_ztitrqp INTO lt_vztitrqp.
    APPEND lt_vztitrqp.
  ENDLOOP.

  CLEAR l_doc_gubun.
  IF p_edity(6) EQ 'PCRLIC'.  " 구매 확인서 응답서의 경우..
    " 스마트폼 내부에서 해당 필드로 구분하기 때문에 응답서가 없을 경우 구분용 값을 넣는다.
    " 표시해주기 위함.
    IF ztitrqs-rcvno IS INITIAL.
      ztitrqs-rcvno = 'PCRLIC'.
      l_pures = 'X'.
    ENDIF.
  ENDIF.

  IF p_edity(6) EQ 'PAYORD'.  " T/T 신청서(하나의 스마트폼을 사용하기 떄문)
    l_doc_gubun = 'S'.
  ELSEIF p_edity(6) EQ 'DEBADV'.  " T/T 응답서
    l_doc_gubun = 'R'.
  ENDIF.

  IF p_edity(6) EQ 'PAYCON'.  " 지급(변경)확인서(하나의 스마트폼을 사용하기 떄문)
    l_doc_gubun = 'R'.
  ELSEIF p_edity(6) EQ 'APPCOP'.  " T/T 신청서, 응답서 후속
    l_doc_gubun = 'S'.
  ENDIF.

*--------------------------------------------------------------------*
*> 2015/10/28 HyeungJungKim 전역변수 사용하기에 교체.
*--------------------------------------------------------------------*
* Before ------------------------------------------------------------*
*  CALL FUNCTION g_func_mod_name
*    EXPORTING
**     ARCHIVE_INDEX        =
**     ARCHIVE_INDEX_TAB    =
**     ARCHIVE_PARAMETERS   =
*      mail_appl_obj        = g_mail_appl_obj
*      mail_recipient       = g_mail_recipient
*      mail_sender          = g_mail_sender
*      user_settings        = space
*      control_parameters   = g_control_parameters
*      output_options       = g_output_options
*      ztitrqk              = ztitrqk
*      ztitrqs              = ztitrqs
*      ztitlc1              = ztitlc1
*      ztitlc5              = ztitlc5
*      ztitlo1              = ztitlo1
*      ztitpc1              = ztitpc1
*      ztittt1              = ztittt1
*    IMPORTING
*      document_output_info = g_document_output_info
*      job_output_info      = g_job_output_info
*      job_output_options   = g_job_output_options
*    TABLES
*      ztitlc2              = lt_ztitlc2
*      ztitlc3              = lt_ztitlc3
*      ztittt2              = lt_ztittt2
*      ztitrqp              = lt_vztitrqp
*      ztitpc3              = lt_ztitpc3
*      ztitpc2              = lt_ztitpc2
*      ztitpc4              = lt_ztitpc4
*    EXCEPTIONS
*      formatting_error     = 1
*      internal_error       = 2
*      send_error           = 3
*      user_canceled        = 4
*      OTHERS               = 5.
*--------------------------------------------------------------------*
* After -------------------------------------------------------------*
  CALL FUNCTION p_func_mod_name
    EXPORTING
*     ARCHIVE_INDEX        =
*     ARCHIVE_INDEX_TAB    =
*     ARCHIVE_PARAMETERS   =
      mail_appl_obj        = p_mail_appl_obj
      mail_recipient       = p_mail_recipient
      mail_sender          = p_mail_sender
      user_settings        = space
      control_parameters   = p_control_parameters
      output_options       = p_output_options
      ztitrqk              = ztitrqk
      ztitrqs              = ztitrqs
      ztitlc1              = ztitlc1
      ztitlc5              = ztitlc5
      ztitlo1              = ztitlo1
      ztitpc1              = ztitpc1
      ztittt1              = ztittt1
      i_doc_gubun          = l_doc_gubun
    IMPORTING
      document_output_info = p_document_output_info
      job_output_info      = p_job_output_info
      job_output_options   = p_job_output_options
    TABLES
      ztitlc2              = lt_ztitlc2
      ztitlc3              = lt_ztitlc3
      ztittt2              = lt_ztittt2
      ztitrqp              = lt_vztitrqp
      ztitpc3              = lt_ztitpc3
      ztitpc2              = lt_ztitpc2
*      ztitpc4              = lt_ztitpc4
    EXCEPTIONS
      formatting_error     = 1
      internal_error       = 2
      send_error           = 3
      user_canceled        = 4
      OTHERS               = 5.
*---------------------------------------------------
*--------------------------------------------------------------------*
  IF sy-subrc <> 0.
*       MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
    MESSAGE ID sy-msgid TYPE 'S' NUMBER sy-msgno
           WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    EXIT.
  ENDIF.

ENDFORM.                    " CALL_REQUEST_OF_IMPORT
*&---------------------------------------------------------------------*
*&      Form  display_billing_doc
*&---------------------------------------------------------------------*
FORM display_billing_doc  USING    p_vbeln.

  CHECK NOT p_vbeln IS INITIAL.

  SET PARAMETER ID 'VF' FIELD p_vbeln.
  CALL TRANSACTION 'VF03' AND SKIP FIRST SCREEN.

ENDFORM.                    " display_billing_doc

*&---------------------------------------------------------------------*
*&      Form  call_outgoingpayment_of_import
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_FUNC_MOD_NAME         text
*      -->P_SSF_NAME              text
*      -->P_EDITY                 text
*      -->P_IMEXI                 text
*      -->P_REFNO                 text
*      -->P_AMDSQ                 text
*      -->P_SUBRC                 text
*      -->P_MAIL_APPL_OBJ         text
*      -->P_MAIL_RECIPIENT        text
*      -->P_MAIL_SENDER           text
*      -->P_CONTROL_PARAMETERS    text
*      -->P_OUTPUT_OPTIONS        text
*      -->P_DOCUMENT_OUTPUT_INFO  text
*      -->P_JOB_OUTPUT_INFO       text
*      -->P_JOB_OUTPUT_OPTIONS    text
*----------------------------------------------------------------------*
FORM call_outgoingpayment_of_import   USING   p_func_mod_name
                                              p_ssf_name
                                              p_edity
                                              p_imexi
                                              p_refno
                                              p_amdsq
                                              p_ediyn
  " EDI 구분자(EDI :E, 그 외 space)
                                              p_subrc
                                     CHANGING p_mail_appl_obj
                                              p_mail_recipient
                                              p_mail_sender
                                              p_control_parameters
                                              p_output_options
                                              p_document_output_info
                                              p_job_output_info
                                              p_job_output_options.

  TABLES : ztitdak,
           ztitdas,
           ztitdad,
           ztitdac.

  DATA : lt_ztitdad LIKE ztitdad OCCURS 0 WITH HEADER LINE,
         lt_ztitdac LIKE ztitdac OCCURS 0 WITH HEADER LINE,
         lt_ztitdas LIKE ztitdas OCCURS 0 WITH HEADER LINE.


  DATA : l_reqno TYPE  ztireqno,
         l_amdsq TYPE  ztiamdsq.


  CLEAR : p_subrc.


  IF p_ediyn EQ 'E'. " EDI

    SELECT SINGLE *
      FROM ztstedis
     WHERE sncnt EQ p_refno.

    SELECT SINGLE *
       FROM ztitdak
      WHERE revno EQ ztstedis-recno.

  ELSEIF p_ediyn IS INITIAL. " EDI 아닐 경우.

    SELECT SINGLE *
       FROM ztitdak
      WHERE revno EQ p_refno.

  ENDIF.

  IF sy-subrc NE 0.
    MESSAGE s902(zmts00).
    p_subrc = 4.
    EXIT.
  ENDIF.
*--------------------------------------------------------------------*



  SELECT *
      INTO CORRESPONDING FIELDS OF TABLE lt_ztitdas
      FROM ztitdas
      WHERE dadno EQ ztitdak-dadno.

  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE lt_ztitdac
    FROM ztitdac
    WHERE cadno EQ ztitdak-dadno.

  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE lt_ztitdad
    FROM ztitdad
    WHERE cadno EQ ztitdak-dadno.




  CALL FUNCTION p_func_mod_name
    EXPORTING
*     ARCHIVE_INDEX        =
*     ARCHIVE_INDEX_TAB    =
*     ARCHIVE_PARAMETERS   =
      mail_appl_obj        = p_mail_appl_obj
      mail_recipient       = p_mail_recipient
      mail_sender          = p_mail_sender
      user_settings        = space
      control_parameters   = p_control_parameters
      output_options       = p_output_options
      ztitdak              = ztitdak
    IMPORTING
      document_output_info = p_document_output_info
      job_output_info      = p_job_output_info
      job_output_options   = p_job_output_options
    TABLES
      ztitdad              = lt_ztitdad
      ztitdac              = lt_ztitdac
      ztitdas              = lt_ztitdas
    EXCEPTIONS
      formatting_error     = 1
      internal_error       = 2
      send_error           = 3
      user_canceled        = 4
      OTHERS               = 5.

  IF sy-subrc <> 0.
*       MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
    MESSAGE ID sy-msgid TYPE 'S' NUMBER sy-msgno
           WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    EXIT.
  ENDIF.

ENDFORM.                    "call_outgoingpayment_of_import

*Messages
*----------------------------------------------------------
*
* Message class: 06
*177   Payment term & not defined
*
* Message class: F2
*067   Account has been posted to; hold balance sheet adjustment
*068   Account &1 is an invalid reconciliation account in company code
*&2
*081   G/L account & does not exist in company code &
*
* Message class: ME
*303   & & & &
*
* Message class: MEPO
*014   Function will be started in new session
*
* Message class: VL
*247   Purchase order &1 is currently being processed by &2
*
* Message class: ZMTI00
*001   Import request type are not updated
*047   & value in & field is not updated
*048   & value in &  Domain item is not updated
*318   The commercial invoice created by B/L document No. & is not
*existed
*319   The commercial invoice created by B/L No. & is not existed
*320   The commercial invoice created by invoice  Doc. No. & is not
*existed
*915   Input & &.
*925   & & is not input. Do you want to continue?
*
* Message class: ZMTS00
*902   No data with search conditions are existed.
