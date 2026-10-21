************************************************************************
* Title         :  ZTIR9000TOP                                         *
*                                                                      *
* Description   : LIV Simulation Funciton용 Top Include                *
*                                                                      *
* Creation Date : 2003/08/22                                           *
*                                                                      *
* Author        : Seog bong, Kang                                      *
*                                                                      *
************************************************************************

TYPE-POOLS: mmcr, mrm, cxtab.

*---------------------------------------------------------------------*
*         Table Controls                                              *
*---------------------------------------------------------------------*
CONTROLS: tc_6000_pb TYPE TABLEVIEW USING SCREEN '6000'.

TABLES: rm08r,
        abtab,
        accit,
        acccr.

DATA: rbkpv  TYPE mrm_rbkpv,         " View Rechnungsbelegkopf inkl Tax
      rbkpvt TYPE mrm_rbkpvt.          " temp. Rechnungsbelegkopf-Daten

*------- RWIN Item ---------------------------------------------------*
DATA: BEGIN OF xaccit OCCURS 1.
        INCLUDE STRUCTURE accit.
DATA: END OF xaccit.

*------- RWIN W?rung ------------------------------------------------*
DATA: BEGIN OF xacccr OCCURS 1.
        INCLUDE STRUCTURE acccr.
DATA: END OF xacccr.

*------- Currencies --------------------------------------------------*
DATA: BEGIN OF xcurr OCCURS 1.
        INCLUDE STRUCTURE rcurr.
DATA:   curtp_text LIKE dd07v-ddtext.
DATA: END OF xcurr.

*-------- Tabelle f? CUA-PF-Status (Ausnahmen) ----------------------*
DATA:    BEGIN OF excl OCCURS 25,
           funktion(10),
         END OF excl.

DATA:  kurstyp LIKE acccr-curtp.        " Kurstyp f? Simulieren

DATA: xaccit_aktind TYPE i VALUE 1,
      xaccit_pagind TYPE i VALUE 1,
      xerror LIKE boole-boole,         " Flag, geaendert
      kursanz LIKE sy-tfill,           " Anzahl Kurstyp f? Simulieren
      xflag,                           " Hilfsflag
      xware_bnk_request,               " Waren/BNK ge?dert
      g_simulation,
      fcowaer(4)               VALUE 'WAER',
      fcobu(4)                 VALUE 'BU  ',
      fcoback(4)               VALUE 'BACK',
      fcocomp LIKE sy-ucomm    VALUE 'COMP', " Vollst?dig sichern
      akt_typ LIKE t169-trtyp  VALUE 'H',

* Aktivit?en in der Rechnungspr?ung
  c_trtyp_a LIKE t169-trtyp VALUE 'A', "Anzeigen
  c_trtyp_h LIKE t169-trtyp VALUE 'H', "Hinzuf?en
  c_trtyp_v LIKE t169-trtyp VALUE 'V', "Ver?dern
  c_trtyp_d LIKE t169-trtyp VALUE 'D', "L?chen
  c_trtyp_c LIKE t169-trtyp VALUE 'C', "Storno

* Rechnungsbeleg-Status
  c_rbstat_online LIKE rbkp-repart VALUE space,             "
  c_rbstat_batch  LIKE rbkp-rbstat VALUE '1',  " zu pr?en im Hintergrd
  c_rbstat_delete LIKE rbkp-rbstat VALUE '2',  " gel?chte Rchg
  c_rbstat_error  LIKE rbkp-rbstat VALUE '3',  " fehlerhafte Rchg
  c_rbstat_correc LIKE rbkp-rbstat VALUE '4',  " Rchg korrekt
  c_rbstat_posted LIKE rbkp-rbstat VALUE '5',  " Rchg gebucht
  c_rbstat_parked LIKE rbkp-rbstat VALUE 'A',  " Vorerfasst
  c_rbstat_comple LIKE rbkp-rbstat VALUE 'B',  " Vorerfasst vollst?dig
  c_rbstat_saved_pa LIKE rbkp-rbstat VALUE 'C',  " Gemerkt vorerfasst
  c_rbstat_saved_po LIKE rbkp-rbstat VALUE 'D',  " Gemerkt erfasst
  c_rbstat_rele_pa LIKE rbkp-rbstat VALUE 'E', " vorerfasst freigegebe
  c_rbstat_comple_ch LIKE rbkp-rbstat VALUE 'F'. " vollst. ?dern -int.


*---------------------------------------------------------------------*
*> BAPI Function용 변수.
*---------------------------------------------------------------------*
DATA: headerdata       LIKE bapi_incinv_create_header,
      invoicedocnumber LIKE bapi_incinv_fld-inv_doc_no,
      fiscalyear       LIKE bapi_incinv_fld-fisc_year,
      addressdata      LIKE bapi_incinv_create_addressdata.

*-------------------------------------------------
*> Item Data in Invoice
*> Account Assignment Data in Invoice
*> Tax Code in Invoice
*> Withholding Tax Data in Incoming Invoice
*> Vendor Split in Incoming Invoice
*> Return Messages
*-------------------------------------------------
DATA: itemdata         LIKE bapi_incinv_create_item
                            OCCURS 10 WITH HEADER LINE,
      accountingdata   LIKE bapi_incinv_create_account
                            OCCURS 10 WITH HEADER LINE,
      GLACCOUNTDATA    LIKE BAPI_INCINV_CREATE_GL_ACCOUNT
                            OCCURS 10 WITH HEADER LINE,
      MATERIALDATA     LIKE BAPI_INCINV_CREATE_MATERIAL
                            OCCURS 10 WITH HEADER LINE,
      taxdata          LIKE bapi_incinv_create_tax
                            OCCURS 10 WITH HEADER LINE,
      withtaxdata      LIKE bapi_incinv_create_withtax
                            OCCURS 10 WITH HEADER LINE,
      vendoritemsplitdata LIKE bapi_incinv_create_vendorsplit
                            OCCURS 10 WITH HEADER LINE,
      return           LIKE bapiret2
                            OCCURS 10 WITH HEADER LINE.
*-------------------------------------------------
*> LIV CANCEL..
DATA: reasonreversal             LIKE  bapi_incinv_fld-reason_rev,
      postingdate                LIKE  bapi_incinv_fld-pstng_date,
      invoicedocnumber_reversal  LIKE bapi_incinv_fld-inv_doc_no,
      fiscalyear_reversal        LIKE bapi_incinv_fld-fisc_year.
*-------------------------------------------------

TABLES  spop.

*>-------------------------------------------------------------------
*> for calls BAPI AcctngDocument
*>-------------------------------------------------------------------
DATA :
  gs_documentheader    LIKE bapiache09,
  gs_customercpd       LIKE bapiacpa09,
  gs_fica_hd           LIKE bapiaccahd,
  it_accountreceivable LIKE TABLE OF bapiacar09 WITH HEADER LINE,
  it_accountgl         LIKE TABLE OF bapiacgl09 WITH HEADER LINE,
  it_accounttax        LIKE TABLE OF bapiactx09 WITH HEADER LINE,
  it_criteria          LIKE TABLE OF bapiackecr WITH HEADER LINE,
  it_valuefield        LIKE TABLE OF bapiackeva WITH HEADER LINE,
  it_currencyamount    LIKE TABLE OF bapiaccr09 WITH HEADER LINE,
  it_return            LIKE TABLE OF bapiret2   WITH HEADER LINE,
  it_receivers         LIKE TABLE OF bdi_logsys WITH HEADER LINE,
  it_fica_it           LIKE TABLE OF bapiaccait WITH HEADER LINE,
  it_accountpayable    LIKE TABLE OF bapiacap09 WITH HEADER LINE,
  it_paymentcard       LIKE TABLE OF bapiacpc09 WITH HEADER LINE,
  it_ext               LIKE TABLE OF bapiextc   WITH HEADER LINE,
  it_re                LIKE TABLE OF bapiacre09 WITH HEADER LINE,
  it_ext2              LIKE TABLE OF bapiparex  WITH HEADER LINE,
  it_doc               LIKE TABLE OF swotobjid  WITH HEADER LINE,
  it_app               LIKE TABLE OF swotobjid  WITH HEADER LINE.

DATA: g_type           LIKE gs_documentheader-obj_type,
      g_key            LIKE gs_documentheader-obj_key,
      g_sys            LIKE gs_documentheader-obj_sys.

DATA: g_text_amount(30),
      g_text_amt1(16),
      g_text_amt2(16).
