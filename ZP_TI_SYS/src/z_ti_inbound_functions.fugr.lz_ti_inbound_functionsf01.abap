*----------------------------------------------------------------------*
***INCLUDE LZ_MI_INBOUND_FUNCTIONSF01 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  ETS_BEREITSTELLEN_MULTI
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM ets_bereitstellen_multi .

  etsmkey-mandt = sy-mandt.
  etsmkey-ebeln = ekpo-ebeln.
  etsmkey-ebelp = ekpo-ebelp.
  READ TABLE ets WITH KEY etsmkey BINARY SEARCH.

  IF sy-subrc NE 0.
    REFRESH ets.
    CLEAR ets.
    SELECT * FROM ekes APPENDING TABLE ets
             WHERE ebeln = ekpo-ebeln
             AND   ebelp = ekpo-ebelp.
  ENDIF.

ENDFORM.                    " ETS_BEREITSTELLEN_MULTI
*----------------------------------------------------------------------*
*  Lesen Best?igungssteuerschl?sel - f?len interne Tabelle XT163G
*----------------------------------------------------------------------*
FORM lesen_t163g USING kz_alle.

  LOOP AT xt163g WHERE bstae EQ ekpo-bstae.
    EXIT.
  ENDLOOP.

  IF sy-subrc NE 0.
    IF kz_alle = 'X'.
      SELECT * FROM t163g APPENDING TABLE xt163g
               WHERE bstae EQ ekpo-bstae.
    ELSE.
      SELECT * FROM t163g APPENDING TABLE xt163g
               WHERE bstae EQ ekpo-bstae AND
                     kzdis NE space.
    ENDIF.
    SORT xt163g BY blfdn.
  ENDIF.

ENDFORM.                    "LESEN_T163G
*----------------------------------------------------------------------*
* Reihenfolgetab. f? die disporel. Einteilungen u. Best?igungen aufb.*
*----------------------------------------------------------------------*
FORM etd_aufbauen USING eta_kz.

  IF eta_kz NE space.
    REFRESH etd.
    REFRESH etz.
*- Tabelle aus Einteilungen f?len - mit laufender Nummer '00' --------*
    LOOP AT xeket WHERE ebelp EQ ekpo-ebelp.
      MOVE xeket TO eket.
      PERFORM etd_aus_eket.
    ENDLOOP.
  ENDIF.

*- Tabelle aus Best?igungen f?len  mit laufender Nummer aus XT163G --*
  CLEAR etd.
  CLEAR etz.
  DATA: help_ets LIKE ekes OCCURS 0 WITH HEADER LINE,       "491785
        ref_dabmg LIKE ekes-dabmg.                          "491785
  help_ets[] = ets[].                                       "615501
  SORT help_ets BY ebeln ebelp ref_etens.                   "615501
*LOOP AT ETS WHERE EBELP EQ EKPO-EBELP.                     "185564
*LOOP AT ETS WHERE EBELP EQ EKPO-EBELP               "185564/318201
  LOOP AT ets WHERE ebeln EQ ekpo-ebeln                     "318201
                AND ebelp EQ ekpo-ebelp                     "318201
                AND   kzdis EQ 'X'                          "185564
                AND estkz NE '4'.                           "491785
    LOOP AT xt163g WHERE bstae EQ ekpo-bstae
                     AND ebtyp EQ ets-ebtyp.
      EXIT.
    ENDLOOP.
    CHECK sy-subrc EQ 0.
    IF eta_kz EQ 'M'.
      CHECK xt163g-marel NE space.
    ENDIF.
    IF eta_kz EQ 'A'.
      CHECK xt163d-ebtyp EQ ets-ebtyp.
    ENDIF.
    MOVE-CORRESPONDING ets TO etd.
    CLEAR: ref_dabmg.                                       "491785
    READ TABLE help_ets WITH KEY                            "615501
                        ebeln = ets-ebeln                   "615501
                        ebelp = ets-ebelp                   "615501
                        ref_etens = ets-etens BINARY SEARCH."615501
    IF sy-subrc = 0.                                        "615501
      LOOP AT help_ets FROM sy-tabix WHERE estkz = '4'      "615501
                                       AND dabmg > 0.       "615501
        IF help_ets-ref_etens NE ets-etens.                 "615501
          EXIT.                                             "615501
        ENDIF.                                              "615501
        etd-menge = etd-menge - help_ets-menge.             "491785
        etd-dabmg = etd-dabmg - help_ets-dabmg.             "491785
      ENDLOOP.                                              "491785
    ENDIF.                                                  "615501
    etd-blfdn = xt163g-blfdn.
*  etd-eindt = ets-eindt.
    etd-etenr = ets-etens.
*  etd-menge = ets-menge.
*  etd-dabmg = ets-dabmg.
*  etd-uzeit = ets-uzeit.
*  etd-lpein = ets-lpein.
*  change by SLS (KH): SLS-Subitems are never
*                      relevant for material planning --> do not
*                      use the customizing indicator, but use
*                      the EKES value
    IF ekpo-uptyp NE uptyp-sls.                               "SLS by KH
      etd-kzdis = xt163g-kzdis.
      etd-werel = xt163g-werel.
      etd-wezuo = xt163g-wezuo.
    ENDIF.
*  etd-ebtyp = ets-ebtyp.
    APPEND etd.
*- Summensatz Best?igungen -------------------------------------------*
*    etz-menge = ets-menge.                                 "491785
*    etz-dabmg = ets-dabmg.                                 "491785
    etz-menge = etd-menge.                                  "491785
    etz-dabmg = etd-dabmg.                                  "491785
    etz-blfdn = etd-blfdn.
    COLLECT etz.
  ENDLOOP.

  SORT etd BY eindt blfdn etenr.

ENDFORM.                    "ETD_AUFBAUEN
*----------------------------------------------------------------------*
*       FORM ETD_UPDATE                                                *
*----------------------------------------------------------------------*
* Redesign of FORM Routine, see note 180516
*----------------------------------------------------------------------*
* Distribution of Confirmation quantities
*----------------------------------------------------------------------*
*  -->  ETU_FLAG: Modus
*
*   = '1'    New distribution of reduced quantities (fill ETD-DABMG)
*   = '2'    Compute Check Quantities (fill ETD-PRFMG)
*   = '3'    Distribution of Quantity Changes
*----------------------------------------------------------------------*
FORM etd_update USING etu_flag.

  DATA:
        maxetkill(16) TYPE p DECIMALS 3,
        diffetkill(16) TYPE p DECIMALS 3,
        maxdabmg(16) TYPE p DECIMALS 3,
        maxvrtmg(16) TYPE p DECIMALS 3,
        etdloopind LIKE sy-tabix,
        etdmaxind LIKE sy-tabix,
        etdetind LIKE sy-tabix,
        etdgrind LIKE sy-tabix.
  FIELD-SYMBOLS: <menge>.

  CLEAR exitflag.
  CLEAR: xwezuo, xblfdn.                                    "304771
  CASE etu_flag.
    WHEN '1'.
      ASSIGN etd-dabmg TO <menge>.
      CLEAR messageflag.
    WHEN '2'.
      ASSIGN etd-prfmg TO <menge>.
    WHEN '3'.
      ASSIGN etd-prfmg TO <menge>.
  ENDCASE.
*- sort ETD
  IF request_etd NE space.
    CLEAR request_etd.
    SORT etd BY eindt blfdn etenr.
  ENDIF.
*- prepare new distribution of reduced quantities
  LOOP AT etd.
*-- determine if GR assignment is active and type of conf
    IF etd-blfdn > 0 AND
       xwezuo EQ space.
      xwezuo = etd-wezuo.
      IF etd-wezuo NE space.
        xblfdn = etd-blfdn.
      ENDIF.
    ENDIF.
*-- no reset of reduced for GR assigned conf
    CHECK xblfdn NE etd-blfdn OR etd-blfdn EQ 0.
*-- reset of reduced
    CLEAR etd-prfmg.
    CLEAR <menge>.

    IF etd-blfdn EQ 0.
*-- remind last sched with GR
      IF etd-wemng NE 0.
        etdgrind = sy-tabix.
      ENDIF.
*-- remind first sched without full GR
      IF etd-wemng LT etd-menge AND
        etdetind EQ 0.
        etdetind = sy-tabix.
      ENDIF.
    ENDIF.
    etd-updkz = 'X' .
    MODIFY etd INDEX sy-tabix.
  ENDLOOP.

*- max to reduce sched = total increased
  LOOP AT etz.
    maxetkill = maxetkill + etz-vrtmg.
  ENDLOOP.

  SORT etz.
*- loop: new distribution of conf/GR
  LOOP AT etz WHERE blfdn GT 0.
*-- no new distribution of GR if GR assignment active
    IF xwezuo NE space.
      CHECK etz-blfdn NE 9.
    ENDIF.

    CLEAR etdmaxind.
    CLEAR etdloopind.
*-- loop on conf/sched
    DO.
      etdloopind = etdloopind + 1.
      READ TABLE etd INDEX etdloopind.
      IF sy-subrc NE 0.
        EXIT.
      ENDIF.
*--- only distribution on 'lower' conf/sched
      CHECK etd-blfdn LT etz-blfdn.
*--- no distribution of GR on sched
      IF etz-blfdn EQ 9 AND etd-blfdn EQ 0.
        CONTINUE.
      ENDIF.
*--- max for reduce = sched/conf - allready reduced
      maxdabmg = etd-menge - <menge>.

*R--- special rules for reducing scheduling lines
      IF etd-blfdn EQ 0.
*R1-- Rule 1: reduce sched with GR first
        IF etdgrind GE etdloopind.
*R1--- max for reduce = GR - allready reduced
          IF etd-wemng LE etd-menge.                        "356085
            maxdabmg = etd-wemng - <menge>.
          ELSE.                                             "356085
            maxdabmg = etd-menge - <menge>.                 "356085
          ENDIF.                                            "356085
        ELSE.                          "!!!!!
*R2-- Rule 2: additional reducing of sched only with increased of conf
          IF etu_flag EQ '3'.
*R2---- rest of old reduced
            diffetkill = etd-dabmg - etd-prfmg.
            maxvrtmg = etd-dabmg - etd-prfmg.
            IF maxvrtmg LT 0.
              maxvrtmg = 0.
            ENDIF.
*R2---- rest of old reduced + increased = max for new reduce
            IF maxetkill GT 0.
              maxvrtmg = maxvrtmg + maxetkill.
            ENDIF.
*R2---- take lowest of both
            IF maxvrtmg LT maxdabmg.
              maxdabmg = maxvrtmg.
            ENDIF.
*R2---- reduce total increased
            IF maxdabmg > 0.
              IF maxdabmg >= etz-menge.
                diffetkill = diffetkill - etz-menge.
              ELSE.
                diffetkill = diffetkill - maxdabmg.
              ENDIF.
              IF diffetkill LT 0.
                maxetkill = maxetkill + diffetkill.
              ENDIF.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.

*--- remind last entry for distribution of overdelivery/-conf
      etdmaxind = sy-tabix.

      CHECK maxdabmg GT 0.
*--- reducable >= to be reduced => reduce all restart with next from
*---                               the very beginning
      IF maxdabmg >= etz-menge.
        <menge> = <menge> + etz-menge.
        etz-menge = 0.
        etd-updkz = 'X' .
        MODIFY etd INDEX sy-tabix.
        CLEAR etdloopind.              "!!!!!
        EXIT.
*--- reducable < to be reduced => reduce max and da capo
      ELSE.
        <menge> = <menge> + maxdabmg.
        etz-menge = etz-menge - maxdabmg.
        etd-updkz = 'X' .
        MODIFY etd INDEX sy-tabix.
*R1--- no sched with GR left => restart from 1st open sched
        IF etd-blfdn EQ 0 AND
           etdgrind EQ etdloopind.
          CLEAR etdgrind.
          IF etdetind NE 0.
            etdloopind = etdetind - 1. "!!!!!
          ENDIF.
        ENDIF.

      ENDIF.
    ENDDO.

*- distribute overdelivery/-conf on last conf/sched
*- overdelivery and no conf(ETDMAXIND=0) => will not be distributed
    IF etz-menge GT 0 AND etdmaxind NE 0.
      READ TABLE etd INDEX etdmaxind.
      CHECK sy-subrc EQ 0.
      <menge> = <menge> + etz-menge.
      etd-updkz = 'X' .
      MODIFY etd INDEX etdmaxind.
    ENDIF.

  ENDLOOP.

*- set reduced into correct field
  IF etu_flag EQ '3'.
    LOOP AT etd.
      IF xwezuo NE space.
        CHECK xblfdn NE etd-blfdn.
      ENDIF.
      etd-dabmg = etd-prfmg.
      MODIFY etd.
    ENDLOOP.
    LOOP AT etz.
      CLEAR etz-vrtmg.
      MODIFY etz.
    ENDLOOP.
  ENDIF.
*- put reduced quantities into DB-update table
  IF etu_flag EQ '1' OR
     etu_flag EQ '3'.
    PERFORM ets_update.
  ENDIF.

ENDFORM.                    "ETD_UPDATE

*----------------------------------------------------------------------*
* Reihenfolgetab. aus Einteilungen f?len                              *
*----------------------------------------------------------------------*
FORM etd_aus_eket.

  CLEAR etz.
  CLEAR etd.
  etd-eindt = eket-eindt.
  etd-etenr = eket-etenr.
  etd-menge = eket-menge.
  etd-dabmg = eket-dabmg.
  etd-uzeit = eket-uzeit.
  etd-lpein = eket-lpein.
  etd-wemng = eket-wemng.
  etd-mahnz = eket-mahnz.
  etd-charg = eket-charg.
  etd-licha = eket-licha.
  etd-ebtyp = 'ET'.
  APPEND etd.
*- Summensatz Einteilungen --------------------------------------------*
  etz-menge = eket-menge.
  etz-dabmg = eket-dabmg.
  COLLECT etz.
*- Summensatz Wareneing?ge -------------------------------------------*
  IF eket-wemng NE 0.
    etz-menge = eket-wemng.
    CLEAR etz-dabmg.
    etz-blfdn = '9'.
    COLLECT etz.
  ENDIF.

ENDFORM.                    "ETD_AUS_EKET

*----------------------------------------------------------------------*
*  Dispostiv abgebaute Mengen in Best?igungstabelle fortschreiben
*----------------------------------------------------------------------*
FORM ets_update.

  DATA: help_ets LIKE ekes OCCURS 0 WITH HEADER LINE,       "491785
        ref_dabmg LIKE ekes-dabmg.                          "491785
  help_ets[] = ets[]. SORT help_ets.                        "491785

*LOOP AT ETS WHERE EBELP EQ EKPO-EBELP.                     "318201
  LOOP AT ets WHERE ebeln EQ ekpo-ebeln                     "318201
                AND ebelp EQ ekpo-ebelp.                    "318201
    h-index = sy-tabix.
    LOOP AT xt163g WHERE ebtyp EQ ets-ebtyp.
      EXIT.
    ENDLOOP.
    CHECK sy-subrc EQ 0.
    etdkey-blfdn = xt163g-blfdn.
    etdkey-eindt = ets-eindt.
    etdkey-etenr = ets-etens.
    READ TABLE etd WITH KEY etdkey BINARY SEARCH.
    CHECK sy-subrc EQ 0.
    CHECK ets-dabmg NE etd-dabmg.
*- Alten Stand in YYEKES sichern, falls nicht schon vorhanden ---------*
    IF ets-updkz NE neupos.
      MOVE-CORRESPONDING ets TO etskey.
      READ TABLE yyekes WITH KEY etskey BINARY SEARCH.
      CASE sy-subrc.
        WHEN 04.
          MOVE ets TO yyekes.
          CLEAR yyekes-kz.
          yyekes-ekpomeins = ekpo-meins.
          INSERT yyekes INDEX sy-tabix.
        WHEN 08.
          MOVE ets TO yyekes.
          CLEAR yyekes-kz.
          yyekes-ekpomeins = ekpo-meins.
          APPEND yyekes.
      ENDCASE.
      ets-updkz = updpos.
    ENDIF.
    ets-dabmg = etd-dabmg.
    IF NOT ets-estkz EQ '4'.                                "419785
      CLEAR: ref_dabmg.                                     "419785
      LOOP AT help_ets WHERE ebeln EQ ets-ebeln             "419785
                         AND ebelp EQ ets-ebelp             "419785
                         AND estkz EQ '4'                   "419785
                         AND ref_etens EQ ets-etens         "419785
                         AND dabmg GT 0.                    "419785
        ref_dabmg = ref_dabmg + help_ets-dabmg.             "419785
      ENDLOOP.                                              "419785
      ets-dabmg = ref_dabmg + etd-dabmg.
    ENDIF.
    MODIFY ets INDEX h-index.
    vb_updkz = 'X'.
  ENDLOOP.

ENDFORM.                    "ETS_UPDATE
