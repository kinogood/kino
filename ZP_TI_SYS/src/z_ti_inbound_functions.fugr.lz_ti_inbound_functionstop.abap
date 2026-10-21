FUNCTION-POOL Z_TI_INBOUND_FUNCTIONS  MESSAGE-ID ME.

************************************************************************
* Datenbanktabellen
************************************************************************
TABLES: ekko,                    ekpo,                  *ekpo,
        eket,                    ekes,                  *ekes,
       *eket,                    rm06e,                  mdcp,
        likp,                    lips,                   eina,
        lfm1,                    ekkn.

TABLES: t001w,                   t160,                   t160v,
        t163d,                   t163e,                  t163f,
        t163g,                   t168t,                  tprg,
        t163l.

TABLES: tmppf.                                              "HTN
TABLES: mara.                                               "306175
*----------------------------------------------------------------------*
*       Table Control                                                  *
*----------------------------------------------------------------------*
*CONTROLS: tc_ekes TYPE TABLEVIEW USING SCREEN 0200,
*          tc_0300 TYPE TABLEVIEW USING SCREEN 0300.

************************************************************************
* Interne Tabellen
************************************************************************
DATA: xt163d LIKE t163d      OCCURS 0 WITH HEADER LINE,
      xt163l LIKE t163l      OCCURS 0 WITH HEADER LINE,
      xekeh  LIKE  ekeh      OCCURS 0 WITH HEADER LINE,
      xekkn  LIKE  ekkn      OCCURS 0 WITH HEADER LINE.

*----------------------------------------------------------------------*
* Interne Tabelle der Bestellbest?igungen
*----------------------------------------------------------------------*
DATA: BEGIN OF ets OCCURS 50.
        INCLUDE STRUCTURE ekes.
DATA:    updkz,
      END OF ets.

DATA: BEGIN OF ets1 OCCURS 50.
        INCLUDE STRUCTURE ekes.
DATA: END OF ets1.

DATA: BEGIN OF ets2 OCCURS 50.
        INCLUDE STRUCTURE ekes.
DATA: END OF ets2.

*... Tabelle Best?igungstreue - Lieferantenbeurteilung ..............*
DATA: BEGIN OF bt OCCURS 50.
        INCLUDE STRUCTURE meavve.
DATA: END OF bt.
DATA: BEGIN OF bt_storno OCCURS 10.
        INCLUDE STRUCTURE meverev.
DATA: END OF bt_storno.

DATA: BEGIN OF last_storno.
        INCLUDE STRUCTURE ekbe.
DATA: END OF last_storno.

DATA: BEGIN OF last_ekbe OCCURS 10.
        INCLUDE STRUCTURE ekbe.
DATA: END OF last_ekbe.



*----------------------------------------------------------------------
*  ?ergabestruktur Bestellungen
*----------------------------------------------------------------------
DATA: BEGIN OF tab_wueb OCCURS 5.
        INCLUDE STRUCTURE wueb.
DATA: END OF tab_wueb.

*----------------------------------------------------------------------
*  Zwischenspeicher f? Fehlermeldungen
*----------------------------------------------------------------------
DATA: BEGIN OF xerrors OCCURS 5.
        INCLUDE STRUCTURE wuebs.
DATA: END OF xerrors.


*----------------------------------------------------------------------*
* Tabellenkey zum Lesen Tabelle ETS
*----------------------------------------------------------------------*
DATA: BEGIN OF etskey,
         mandt LIKE ekpo-mandt,
         ebeln LIKE ekpo-ebeln,
         ebelp LIKE ekpo-ebelp,
         etens LIKE ekes-etens,
      END OF etskey.
*----------------------------------------------------------------------*
* 'Konsolidierungstabelle' f? Einteilungen und Best?igungen
*----------------------------------------------------------------------*
DATA: BEGIN OF etd OCCURS 50,
         eindt LIKE eket-eindt,
         blfdn LIKE t163g-blfdn,
         etenr LIKE eket-etenr,
         menge LIKE eket-menge,
         dabmg LIKE eket-dabmg,
         ebtyp LIKE ekes-ebtyp,
         uzeit LIKE eket-uzeit,
         lpein LIKE eket-lpein,
         wemng LIKE eket-wemng,
         prfmg LIKE eket-menge,
         kzdis LIKE t163g-kzdis,
         werel LIKE t163g-werel,
         wezuo LIKE t163g-wezuo,
         ematn LIKE ekes-ematn,
         mprof LIKE ekes-mprof,
         mahnz LIKE ekpo-mahnz,
         charg LIKE eket-charg,
         licha LIKE eket-licha,
         updkz,
      END OF etd.

*----------------------------------------------------------------------*
* Tabelle der Einteilungen und Best?igungen f? Listen
*----------------------------------------------------------------------*
DATA: BEGIN OF etk OCCURS 50,
         eindt LIKE eket-eindt,
         etenr LIKE eket-etenr,
         menge LIKE eket-menge,
         dabmg LIKE eket-dabmg,
         ebtyp LIKE ekes-ebtyp,
         uzeit LIKE eket-uzeit,
         lpein LIKE eket-lpein,
         wemng LIKE eket-wemng,
      END OF etk.

*----------------------------------------------------------------------*
* Summentabelle f? Einteilungen, Best?igungen und WE's
*----------------------------------------------------------------------*
DATA: BEGIN OF etz OCCURS 50,
         blfdn LIKE t163g-blfdn,
         menge(16) TYPE p DECIMALS 3,
         dabmg(16) TYPE p DECIMALS 3,
         difmg(16) TYPE p DECIMALS 3,
         vrtmg(16) TYPE p DECIMALS 3,
         ebtyp LIKE ekes-ebtyp,
      END OF etz.

*----------------------------------------------------------------------*
* Tabellenkey zum Lesen Tabelle ETD
*----------------------------------------------------------------------*
DATA: BEGIN OF etdkey,
          eindt LIKE ekes-eindt,
          blfdn LIKE t163g-blfdn,
          etenr LIKE ekes-etens,
      END OF etdkey.

*----------------------------------------------------------------------*
* Tabellen zum Rechnen bei der Terminabweichung
*----------------------------------------------------------------------*
DATA: BEGIN OF ettab OCCURS 50.
        INCLUDE STRUCTURE eket.
DATA: END OF ettab.
*----------------------------------------------------------------------*
* Interne Tabelle des Best?igungsstatus
*----------------------------------------------------------------------*
DATA: BEGIN OF xt163g OCCURS 5.
        INCLUDE STRUCTURE t163g.
DATA: END OF xt163g.

*----------------------------------------------------------------------*
* Tabellenkey zum Lesen Tabelle YEKET
*----------------------------------------------------------------------*
DATA:    BEGIN OF ettkey,
           mandt LIKE ekpo-mandt,
           ebeln LIKE ekpo-ebeln,
           ebelp LIKE ekpo-ebelp,
           etenr LIKE eket-etenr,
         END OF ettkey.

*----------------------------------------------------------------------*
* Tabellenkey zum Lesen Tabelle ETS im Fall MULTI
*----------------------------------------------------------------------*
DATA:    BEGIN OF etsmkey,
           mandt LIKE ekpo-mandt,
           ebeln LIKE ekpo-ebeln,
           ebelp LIKE ekpo-ebelp,
         END OF etsmkey.

*----------------------------------------------------------------------*
* Tabelle mit den Positionen, f? die die Bestellbest?. schon gelesen *
*----------------------------------------------------------------------*
DATA: BEGIN OF etts OCCURS 20,
         ebeln LIKE ekpo-ebeln,                             "457140
         ebelp LIKE ekpo-ebelp,
* 457140 last confirmation sequence number for the PO item:
         highetens LIKE ekes-etens,                         "457140
      END OF etts.

*----------------------------------------------------------------------*
* Interne Tabelle der Best?igungsbezeichnungen mit kumulierten Mengen *
*----------------------------------------------------------------------*
DATA: BEGIN OF xt163f OCCURS 50.
        INCLUDE STRUCTURE t163f.
DATA:    kum_menge LIKE eket-menge,
         blfdn     LIKE t163g-blfdn,
         updkz,
      END OF xt163f.

*----------------------------------------------------------------------*
* Interne Tabelle der WE-relevanten Best?igungen (i.d.R. Avise)
*----------------------------------------------------------------------*
DATA: BEGIN OF xwerel OCCURS 5,
         ebeln LIKE ekko-ebeln,
         ebelp LIKE ekpo-ebelp,
         bstae LIKE t163g-bstae,
         blfdn LIKE t163g-blfdn,
         ebtyp LIKE t163g-ebtyp,
         menge LIKE ekpo-menge,
         meins LIKE ekpo-meins,
         lmein LIKE ekpo-lmein,
         amein LIKE ekpo-meins,
         matnr LIKE ekpo-matnr,
         mprof LIKE ekpo-mprof,
         ematn LIKE ekpo-ematn,
         uebto LIKE ekpo-uebto,
         uebtk LIKE ekpo-uebtk,                             "550310
         webre LIKE ekpo-webre,
         uptyp LIKE ekpo-uptyp,                             "VAS
      END OF xwerel.

*----------------------------------------------------------------------*
* Interne Tabelle alten Stand Best?igungen (Hilfstabelle)
*----------------------------------------------------------------------*
DATA: BEGIN OF yyekes OCCURS 20.
        INCLUDE STRUCTURE uekes.
DATA: END OF yyekes.

*----------------------------------------------------------------------*
* Interne Tabelle der Positionen
*----------------------------------------------------------------------*
DATA: BEGIN OF pot OCCURS 20.
        INCLUDE STRUCTURE ekpo.
DATA: END OF pot.

*----------------------------------------------------------------------*
* Hilfstabelle zum Sortieren der Positionen
*----------------------------------------------------------------------*
DATA: BEGIN OF h_komdlgn OCCURS 20.
        INCLUDE STRUCTURE komdlgn.
DATA: sort_ltssf LIKE komdlgn-ltssf,
      sort_ean11 LIKE komdlgn-ean11,
      sort_matnr LIKE komdlgn-matnr,   "TK REP
      sort_idnlf LIKE komdlgn-idnlf,   "TK REP
      sort_matkl LIKE komdlgn-matkl.   "TK REP
DATA: END OF h_komdlgn.

*----------------------------------------------------------------------*
* Hilfstabelle
*----------------------------------------------------------------------*
DATA: BEGIN OF xkomdlgn OCCURS 20.
        INCLUDE STRUCTURE komdlgn.
DATA: END OF xkomdlgn.

*----------------------------------------------------------------------*
* Hilfstabelle f? Aufbau der Unterpositionen
*----------------------------------------------------------------------*
DATA: BEGIN OF rek_ekpo OCCURS 5,
      ebeln LIKE ekpo-ebeln,
      ebelp LIKE ekpo-ebelp.
DATA: END OF rek_ekpo.

*----------------------------------------------------------------------*
* Interne Tabelle der Dispsatzvormerkungen
*----------------------------------------------------------------------*
DATA: BEGIN OF xmdcp OCCURS 10.
        INCLUDE STRUCTURE mdcp.
DATA: END OF xmdcp.
DATA: BEGIN OF mdcpkey.
DATA:    matnr LIKE mdcp-matnr,
         werks LIKE mdcp-werks.
DATA: END OF mdcpkey.
*----------------------------------------------------------------------*
* Interne Tabelle der ALE-relevanten Positionen
*----------------------------------------------------------------------*
DATA: BEGIN OF xgoodsin OCCURS 10.
        INCLUDE STRUCTURE vegoods_in.
DATA: END OF xgoodsin.

DATA: BEGIN OF ygoodsin OCCURS 10.
        INCLUDE STRUCTURE vegoods_in.
DATA: END OF ygoodsin.

*----------------------------------------------------------------------*
* Direktwerte
*----------------------------------------------------------------------*
* Direktwerte zum Update-Kennzeichen ----------------------------------*
DATA: oldpos(1) VALUE ' ',             "Keine Veraenderung
      neupos(1) VALUE 'I',             "Neue Best?igung
      updpos(1) VALUE 'U',             "Geaenderte Best?igung
      delpos(1) VALUE 'D'.             "Gel?chte Best?igung

* Direktwerte zur Antwort aus POP-UP ----------------------------------*
DATA: ansy VALUE 'J',
      ansn VALUE 'N',
      ansa VALUE 'A'.

* Werte zu Trtyp und Aktyp --------------------------------------------*
*ATA: HIN VALUE 'H',
*     VER VALUE 'V',
*     ANZ VALUE 'A'.

* Maximalwerte --------------------------------------------------------*
DATA: maxmenge LIKE ekpo-menge VALUE '99999'.
DATA: maxdabmg LIKE ekes-dabmg VALUE '9999999999.999'.      "494605

* Werte zu Ok-Code ----------------------------------------------------*
DATA: back(4) VALUE 'BACK',
      neup(4) VALUE 'NP  ',
      nexp(4) VALUE 'NEXP',
      eint(4) VALUE 'ET  ',
      uebb(4) VALUE 'AB  ',
      exit(4) VALUE 'XIT ',
      buch(4) VALUE 'BU  ',
      neuv(4) VALUE 'NEUV',
      lst0(4) VALUE 'LST0',
      lst1(15) VALUE 'LST1',
      lst2(15) VALUE 'LST2',
      lst3(15) VALUE 'LST3'.

* Mengenkorrelation, St?klisten, Unterpositionen
DATA: c_mekor(2)     VALUE '3X',       "Unterpositionen mit Mengenkorr.
      c_sammelart(1) VALUE '1',        "Sammelartikel
      c_lot(1)       VALUE '5'.        "Lots

*----------------------------------------------------------------------*
* Hilfsfelder
*----------------------------------------------------------------------*
* Indices bei Tabellenbearbeitung Tabelle ETS -------------------------*
DATA: e-firstind(3) TYPE p,            "erster Index
      e-aktind(3)   TYPE p,            "aktueller Index
      e-maxind(3)   TYPE p,            "maximaler Index
      e-pagind(3)   TYPE p,            "aktueller Index der Seite
      e-lopind(3)   TYPE p,            "Anzahl Loopzeilen
      e-listbr(3)   TYPE p,            "Breite der angezeigten Liste
      e-modind LIKE sy-tabix.          "Rettfeld sy-tabix
DATA: aktindh LIKE e-aktind,           "Hilfsfeld e-aktind
      haktindh LIKE e-aktind,          "Hilfsfeld e-aktind f. MEPO
      hebelp  LIKE ekpo-ebelp.         "Hilfsfeld ebelp f. MEPO

* Hilfsfelder Bestellbest?igungsdatum --------------------------------*
DATA: h-lpein LIKE ekes-lpein,         "Hilfsfeld Datumsart
      xlpein LIKE ekes-lpein,          "Hilfsfeld Datumsart
      h-eindt LIKE ekes-eindt,         "Hilfsfeld Eint.datum
      h-fabkl LIKE t001w-fabkl,        "Hilfsfeld Kalenderid
      h-ebtyp LIKE ekes-ebtyp,         "Hilfsfeld Best?.typ
      datum(10) TYPE c,                "Hilfsfeld Datum
      periode(1) TYPE c.               "Hilfsfeld Periode

* Rechenfelder --------------------------------------------------------*
DATA: refe1(16) TYPE p DECIMALS 3,     "Rechenfeld 1
      refe2(16) TYPE p,                "Rechenfeld 2
      f1 TYPE f.                       "Rechenfeld 3

* sonstige Hilfsfelder ------------------------------------------------*
DATA: gr_assign.                       "375763    GR assignment
data: retdlv_t163d(1) type c.          "return delivery in EKES "491785
DATA: eintmod,                         "Erfassungsmodus Einteilungen
      ok-code(15),                     "Ok-Code
      exitflag,                        "Kz. Exit aus Perform-Ruotine
      flag_ok,                         "Hilfskennzeichen
      answer,                          "Antwort aus POP-UP
      highetens LIKE ekes-etens,       "Hilfsfeld Einteilungsnummer
      request_ets,                     "Kennz., ob Request stattfand
      request_etd,                     "Kennz., ob Request stattfand
      trtyp,                           "Transaktionstyp
      aktyp,                           "Aktivitaetstyp
      vb_updkz,                        "Kz. 훞derung vollzogen
      h-umrez LIKE komdlgn-umvkz,      "Hilfsfeld Z?ler
      h-umren LIKE komdlgn-umvkn,      "Hilfsfeld Nenner
      h-ebeln LIKE ekko-ebeln,         "Hilfsfeld Belegnummer
      h-ebelp LIKE ekpo-ebelp,         "Hilfsfeld Positionsnummer
      h-menge LIKE ekes-dabmg,         "Hilfsfeld dispositv abgeb. Menge
      h-meng1 LIKE ekes-dabmg,         "Hilfsfeld f? Mengen
      h-umeng LIKE ekpo-menge,         "Hilfsfeld f? Mengen
      h-lmein LIKE ekpo-lmein,         "Hilfsfeld f? Basismengeneinheit
      h-avimg LIKE ekes-menge,         "Hilfsfeld f? avisierte Menge
      h-gavim LIKE ekes-menge,         "Hilfsfeld f? gesamte avisierte
      h-wemng LIKE ekbes-wemng,        "Hilfsfeld f? WE-Menge
      h-ekesok,                       "Hilfsfeld Best?igungen vorgeseh.
      h-blfdn LIKE t163g-blfdn,        "Hilfsfeld laufende Nummer
      h-index LIKE sy-tabix,           "Hilfsfeld Tabellenindex
      h-t163d LIKE t163d,              "Hilfsstruktur Best.typ
      z-index LIKE sy-tabix,           "Hilfsfeld Tabellenindex
      title(3) TYPE c,                 "Hilfsfeld Bildtitel
      pfstat(4) TYPE c,                "Hilfsfeld Pf-Status
      text1(21) TYPE c,                "Hilfsfeld Titel
      text2(9)  TYPE c,                "Hilfsfeld Titel
      text3(32) TYPE c,                "Hilfsfeld Titel
*     AUSWAHL1(4) TYPE C,             "Feldauswahl
      msgvs LIKE t160m-msgvs VALUE '00',
      evopa LIKE t160v-evopa,          "Vorschlagswerte
      messageflag,                                          "I129
      posok,                           "Hilfsfeld f? Avis
      bstok,                           "Hilfsfeld f? Avis
      leaveflag,                       "Hilfsfeld f? Listen
      xobjekt(10),                     "Hilfsfeld Berechtigungsobjekt
      xwezuo,                          "Hilfsfeld WE-Zuordnung aktiv
      xblfdn LIKE t163g-blfdn,       "Hilfsf.Reihenfolge Best?.m.WE-Zuo
      cursorfield LIKE ekes-vbeln,     "Feld, in dem Cursor steht
      h_ematn LIKE komdlgn-ematn,      "Hilfsfeld f? externes Material
      value(20),                       "Wert des Feldes
*##ngr210-anf
      h_grkor LIKE lips-grkor,         "Liefergruppe
      h_bsmng LIKE ekpo-menge.         "Bestellmenge ?ergeordnete Pos.
DATA  sl_matnr LIKE ekpo-matnr.                             "HTN
*##ngr210-end
data:  value_estkz like ekes-estkz.                           "491785
*help_t163q like t163q occurs 0 with header line.              "491785
INCLUDE fmmexdir.                      "Direktwerte
* include fm06lu02.                     "WUEB
INCLUDE fm06lcbe.                      "Bestellentwicklung
