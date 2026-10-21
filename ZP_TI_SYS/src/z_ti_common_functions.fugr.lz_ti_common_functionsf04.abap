*----------------------------------------------------------------------*
***INCLUDE LZ_TI_COMMON_FUNCTIONSF04 .
*----------------------------------------------------------------------*
*----------------------------------------------------------------------*
* Bestellentwicklungstabelle fuellen                                   *
*----------------------------------------------------------------------*
FORM bet_fuellen USING p_bypassing_buffer                   "359665
                       p_refresh_buffer.                    "359665
  IF bet[] IS INITIAL.                                      "401859
*
    CALL FUNCTION 'MMPUR_EKBE_READ_EBELN_EBELP'
      EXPORTING
        pi_ebeln             = ekko-ebeln
        pi_ebelp             = ebelp
        pi_bypassing_buffer  = p_bypassing_buffer           "359665
        pi_refresh_buffer    = p_refresh_buffer             "359665
      TABLES
        pto_ekbe_po          = bet
      EXCEPTIONS
        no_records_requested = 1
        OTHERS               = 2.
    IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.
  ELSE.                                                     "401859

    DATA: lt_bet LIKE ekbe OCCURS 0 WITH HEADER LINE.       "401859

    CALL FUNCTION 'MMPUR_EKBE_READ_EBELN_EBELP'             "401859
        EXPORTING                                           "401859
            pi_ebeln            = ekko-ebeln                "401859
            pi_ebelp            = ebelp                     "401859
            pi_bypassing_buffer = p_bypassing_buffer        "401859
            pi_refresh_buffer   = p_refresh_buffer          "401859
        TABLES                                              "401859
            pto_ekbe_po         = lt_bet                    "401859
        EXCEPTIONS                                          "401859
            no_records_requested = 1                        "401859
            OTHERS               = 2.                       "401859
    IF sy-subrc EQ 0.                                       "401859
      APPEND LINES OF lt_bet TO bet.                        "401859
      SORT bet BY ebeln ebelp zekkn vgabe gjahr belnr buzei."401859
      DELETE ADJACENT DUPLICATES FROM bet                   "401859
         COMPARING ebeln ebelp zekkn vgabe gjahr belnr buzei."401859
    ENDIF.                                                  "401859
  ENDIF.                                                    "401859
*> ADD KSB
  DELETE bet WHERE NOT budat IN r_budat.

  SORT bet BY ebelp zekkn lfgja lfbnr lfpos cpudt cputm.    "163803
  PERFORM bet_summen.
  SORT bets BY ebelp zekkn.
  SORT bet BY ebelp zekkn bewtp gjahr belnr buzei.

ENDFORM.                    "BET_FUELLEN
*&---------------------------------------------------------------------*
*&      Form  SCHNITTSTELLE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM schnittstelle.
  LOOP AT bet.
    MOVE bet TO xekbe.
    APPEND xekbe.
  ENDLOOP.
  SORT xekbe BY ebelp zekkn vgabe bewtp gjahr belnr buzei.
  DELETE ADJACENT DUPLICATES FROM xekbe COMPARING ALL FIELDS."164790

  LOOP AT bzt.
    MOVE bzt TO xekbz.
    APPEND xekbz.
  ENDLOOP.
  SORT xekbz BY ebelp stunr zaehk bewtp gjahr belnr buzei.
  DELETE ADJACENT DUPLICATES FROM xekbz COMPARING ALL FIELDS."164790

  LOOP AT bets.
    MOVE bets TO xekbes.
    APPEND xekbes.
  ENDLOOP.
  SORT xekbes BY ebelp zekkn.
  DELETE ADJACENT DUPLICATES FROM xekbes COMPARING ALL FIELDS."164790

  LOOP AT betz.
    MOVE betz TO xekbez.
    APPEND xekbez.
  ENDLOOP.
  SORT xekbez BY ebelp zekkn lfgja lfbnr lfpos.
  DELETE ADJACENT DUPLICATES FROM xekbez COMPARING ALL FIELDS."164790

  LOOP AT betb.
    MOVE betb TO xekbnk.
    APPEND xekbnk.
  ENDLOOP.
  SORT xekbnk BY ebeln ebelp stunr zaehk.
  DELETE ADJACENT DUPLICATES FROM xekbnk COMPARING ALL FIELDS."164790

ENDFORM.                    " SCHNITTSTELLE
*----------------------------------------------------------------------*
* Bezugsnebenkostensummentabelle fuellen                               *
*----------------------------------------------------------------------*
FORM betb_fuellen USING p_bypassing_buffer                  "359665
                        p_refresh_buffer.                   "359665

  DATA:                                                     "K003063
    ld_betb_key      LIKE betb_key.                         "K003063

  PERFORM bzt_fuellen USING p_bypassing_buffer              "359665
                            p_refresh_buffer.               "359665

  su_arekz = 'X'.
  su_fwknz = 'X'.
  su_fwknz_we = 'X'.
  CLEAR su_waers.
  CLEAR su_wewae.
  CLEAR betb.
  PERFORM bzt_wa_aufbauen USING                             "K003063
            ekko-ebeln                                      "K074433
            ebelp.                                          "K003063
  LOOP AT bzt WHERE ebelp EQ ebelp.
    kondz-ebeln = bzt-ebeln.
    kondz-ebelp = bzt-ebelp.
    kondz-stunr = bzt-stunr.
    kondz-zaehk = bzt-zaehk.
    ON CHANGE OF kondz.
      IF betb-ebelp NE 0.
        APPEND betb.
        CLEAR  betb.
        PERFORM append_betb_wa.                             "K003063
        CLEAR betb_wa.                                      "K003063
        su_arekz = 'X'.
        su_fwknz = 'X'.
        su_fwknz_we = 'X'.
        CLEAR: su_waers, su_wewae.
      ENDIF.
    ENDON.
    betb-ebeln = bzt-ebeln.
    betb-ebelp = bzt-ebelp.
    betb-stunr = bzt-stunr.
    betb-zaehk = bzt-zaehk.
    betb-bewtp = bzt-bewtp.
    MOVE-CORRESPONDING betb TO ld_betb_key.                 "K003063
    betb_wa-key = ld_betb_key.                              "K003063
    PERFORM bzt_analyse.
  ENDLOOP.

  IF betb-ebelp NE 0.                                       "3.1h
    APPEND betb.
    PERFORM append_betb_wa.                                 "K003063
    CLEAR  betb.                                            "3.1h
    CLEAR  betb_wa.                    "3.1h                    "K003063
  ENDIF.                                                    "3.1h
  SORT betb BY ebeln ebelp stunr zaehk.

ENDFORM.                    "BETB_FUELLEN
*----------------------------------------------------------------------*
* Summentabellen aus BET aufbauen                                      *
*----------------------------------------------------------------------*
FORM bet_summen.

  DATA: lo_bets LIKE ekbes.
  DATA: l_tabix LIKE sy-tabix.
  CLEAR: h_bets_wemng.                                      "TK 4.5A
  CLEAR: h_betz_wemng.                                      "TK 4.5A
  CLEAR: h_bets_bpmng.                                      "TK 4.5A
  CLEAR: h_betz_bpmng.                                      "TK 4.5A
*- bearbeiten Tabelle der Bestellentwicklungssaetze
  su_arekz = 'X'.
  su_fwknz = 'X'.
  su_fwknz_pos = 'X'.                                       "72479
  CLEAR bets.
  CLEAR bets_wa.                                            "K003063
  CLEAR betz.
  CLEAR betz_wa.                                            "K003063
  CLEAR h-lvgdt.
  IF NOT lfdat_ab IS INITIAL OR NOT lfdat_bis IS INITIAL.
    xnosel = 'X'.
  ELSE.
    CLEAR xnosel.
  ENDIF.

  PERFORM betsl_aufbauen.
  PERFORM bet_wa_aufbauen USING                             "K003063
            ekko-ebeln                                      "K074433
            ebelp.                                          "K003063

* LOOP AT BET.                                              "180169
*   CHECK BET-EBELP EQ EBELP.
  READ TABLE bet WITH KEY ebelp = ebelp BINARY SEARCH.      "180169
  l_tabix = sy-tabix.
  IF sy-subrc EQ 0.
    IF bet-ebeln NE ekpo-ebeln OR bet-ebelp NE ekpo-ebelp.  "362965
      CALL FUNCTION 'ME_EKPO_SINGLE_READ'                   "362965
           EXPORTING                                        "362965
                pi_ebeln            = bet-ebeln             "362965
                pi_ebelp            = bet-ebelp             "362965
           IMPORTING                                        "362965
                po_ekpo             = ekpo                  "362965
           EXCEPTIONS                                       "362965
                no_records_found    = 1                     "362965
                OTHERS              = 2.                    "362965
    ENDIF.                                                  "362965
    LOOP AT bet FROM l_tabix.
      IF bet-ebelp NE ebelp.
        EXIT.
      ENDIF.
      IF xnosel NE space AND bet-vgabe EQ '1'.      "nur WE
        IF ( ( NOT lfdat_ab IS INITIAL AND bet-budat GE lfdat_ab ) OR
             ( lfdat_ab IS INITIAL ) ) AND
           ( ( NOT lfdat_bis IS INITIAL AND bet-budat LE lfdat_bis ) OR
             ( lfdat_bis IS INITIAL ) ).
*          WE-Datum liegt im Selektionsbereich
          CLEAR xnosel.
        ENDIF.
      ENDIF.

      AT NEW zekkn.                                         "72479
        IF re_waers IS INITIAL.
          CLEAR su_kont_waers.                              "72479
        ENDIF.
      ENDAT.                                                "72479
      IF bet-vgabe NE 'R'.             "R?klieferungen rauslassen
*                          "Problematisch wegen Sortierung
*                          "AT END OF ZEKKN mu?aber durchlaufen werden
        MOVE-CORRESPONDING bet TO werez.
*- BETZ-Eintrag bei neuer WE/RE-Zuordnung
        ON CHANGE OF werez.
          IF webre NE space AND betz-ebelp NE 0.
            IF NOT ( betz-lfbnr IS INITIAL ).               "MWE-163866
              IF NOT h_betz_wemng IS INITIAL.               "TK 4.5A
                betz-wemng = h_betz_wemng.                  "TK 4.5A
                CLEAR h_betz_wemng.                         "TK 4.5A
              ENDIF.                                        "TK 4.5A
              IF NOT h_betz_bpmng IS INITIAL.               "TK 4.5A
                betz-bpmng = h_betz_bpmng.                  "TK 4.5A
                CLEAR h_betz_bpmng.                         "TK 4.5A
              ENDIF.                                        "TK 4.5A
              APPEND betz.
              PERFORM append_betz_wa.                       "K003063
              PERFORM betz_summe_kont.
            ENDIF.                                          "MWE-163866
            CLEAR betz.
            CLEAR betz_wa.                                  "K003063
            su_fwknz = 'X'.
*       kein su_arekz = 'X' !! wegen BETS pro Position und feineren
          ENDIF.
        ENDON.

        PERFORM bet_analyse.
      ENDIF.

*- BETS-Eintrag bei neuer Kontierungsposition
      AT END OF zekkn.
        IF NOT h_bets_wemng IS INITIAL.                     "TK 4.5A
          bets-wemng = h_bets_wemng.                        "TK 4.5A
          CLEAR h_bets_wemng.                               "TK 4.5A
        ENDIF.                                              "TK 4.5A
        IF NOT h_bets_bpmng IS INITIAL.                     "TK 4.5A
          bets-bpmng = h_bets_bpmng.                        "TK 4.5A
          CLEAR h_bets_bpmng.                               "TK 4.5A
        ENDIF.                                              "TK 4.5A
        APPEND bets.
        PERFORM append_bets_wa.                             "K003063
*- BETS-Eintrag ohne Kontierungsposition pro Position
        IF bets-zekkn NE 0.
          CLEAR bets-zekkn.
          CLEAR bets-xunpl.                                 "485660
          IF su_fwknz_pos IS INITIAL.                       "72479
            CLEAR: bets-rewwr, bets-refwr, bets-areww, bets-rewae.
          ENDIF.                                            "72479
*       COLLECT BETS.   "collect geht nicht mehr wegen REWAE
          MOVE bets TO lo_bets.
          MOVE-CORRESPONDING bets TO betskey.
          READ TABLE bets WITH KEY betskey BINARY SEARCH.
          IF sy-subrc EQ 0.
            bets-wamng = bets-wamng +  lo_bets-wamng.
            bets-wesbs = bets-wesbs +  lo_bets-wesbs.
            bets-bpwes = bets-bpwes +  lo_bets-bpwes.
            bets-wemng = bets-wemng +  lo_bets-wemng.
            bets-bpmng = bets-bpmng +  lo_bets-bpmng.
            bets-wewrt = bets-wewrt +  lo_bets-wewrt.
            bets-wewwr = bets-wewwr +  lo_bets-wewwr.
            bets-remng = bets-remng +  lo_bets-remng.
            bets-bprem = bets-bprem +  lo_bets-bprem.
            bets-rewrt = bets-rewrt +  lo_bets-rewrt.
            bets-rewwr = bets-rewwr +  lo_bets-rewwr.
            IF lo_bets-rewwr NE 0 AND lo_bets-rewae NE space AND
               bets-rewae EQ space.                         "171591
              bets-rewae = lo_bets-rewae.                   "171591
            ENDIF.                                          "171591
            bets-arewr = bets-arewr +  lo_bets-arewr.
            IF su_arekz NE space.
              bets-areww = bets-areww +  lo_bets-areww.
            ELSE.
              CLEAR bets-areww.
            ENDIF.
            bets-anzal = bets-anzal +  lo_bets-anzal.
            bets-reewr = bets-reewr +  lo_bets-reewr.
            bets-refwr = bets-refwr +  lo_bets-refwr.
            bets-glmng = bets-glmng +  lo_bets-glmng.
            bets-wesba = bets-wesba +  lo_bets-wesba.
            bets-wemga = bets-wemga +  lo_bets-wemga.
            bets-remga = bets-remga +  lo_bets-remga.
            bets-neurh = bets-neurh +  lo_bets-neurh.       "tk 4.5b
            bets-neurw = bets-neurw +  lo_bets-neurw.       "tk 4.5b
            bets-neudm = bets-neudm +  lo_bets-neudm.       "tk 4.5b
            bets-neuwr = bets-neuwr +  lo_bets-neuwr.       "tk 4.5b
            MODIFY bets INDEX sy-tabix.
          ELSE.
            bets = lo_bets.
            INSERT bets INDEX sy-tabix.
          ENDIF.

          PERFORM collect_bets_wa.                          "K003063
        ENDIF.
        CLEAR bets.
        CLEAR bets_wa.                                      "K003063
        su_fwknz = 'X'.
*     kein su_arekz = 'X'!!
      ENDAT.
    ENDLOOP.
  ENDIF.                                                    "180169
*  IF WEBRE NE SPACE AND BETZ-EBELP NE 0.                   "MWE-163866
  IF  webre NE space                                        "MWE-163866
  AND betz-ebelp NE 0                                       "MWE-163866
  AND NOT ( betz-lfbnr IS INITIAL ).                        "MWE-163866
    IF NOT h_betz_wemng IS INITIAL.                         "TK 4.5A
      betz-wemng = h_betz_wemng.                            "TK 4.5A
      CLEAR h_betz_wemng.                                   "TK 4.5A
    ENDIF.                                                  "TK 4.5A
    IF NOT h_betz_bpmng IS INITIAL.                         "TK 4.5A
      betz-bpmng = h_betz_bpmng.                            "TK 4.5A
      CLEAR h_betz_bpmng.                                   "TK 4.5A
    ENDIF.                                                  "TK 4.5A
    APPEND betz.
    PERFORM append_betz_wa.                                 "K003063
    PERFORM betz_summe_kont.
  ENDIF.

  IF h-lvgdt NE 0.
    CLEAR betskey.
    betskey-ebelp = ebelp.
    READ TABLE bets WITH KEY betskey BINARY SEARCH.         "180169
    IF sy-subrc EQ 0.
      bets-lvgdt = h-lvgdt.
      MODIFY bets INDEX sy-tabix.
    ENDIF.
  ENDIF.

ENDFORM.                    "bet_summen
*&--------------------------------------------------------------------*
*&      Form  betsl_aufbauen
*&--------------------------------------------------------------------*
*       text
*---------------------------------------------------------------------*
FORM betsl_aufbauen.
*&---------------------------------------------------------------------*
*&      Form  BETSL_AUFBAUEN
*&---------------------------------------------------------------------*
*       Tabelle der Leistungssummen aufbauen
*----------------------------------------------------------------------*
  DATA: xbet LIKE ekbe OCCURS 0 WITH HEADER LINE.

  CHECK ekpo-pstyp = '9'.
  CHECK ekpo-wepos IS INITIAL.         "WE nein
  CHECK NOT ekpo-lebre IS INITIAL.     "Leist.bez RE

  su_arekz = 'X'.                      "Check Bet in gleicher Waehrg
  su_fwknz = 'X'.
  su_fwknz_pos = 'X'.

  xbet[] = bet[].
  SORT xbet BY ebelp packno introw zekkn.

  LOOP AT xbet.
    CHECK xbet-ebelp = ekpo-ebelp.

    MOVE-CORRESPONDING xbet TO lerez.
    ON CHANGE OF lerez.
      IF NOT betsl IS INITIAL.
        APPEND betsl.
        CLEAR  betsl.
      ENDIF.
    ENDON.

    PERFORM bet_analyse_l(sapleinr) USING xbet.
  ENDLOOP.

  IF sy-subrc = 0.                     "letzter Satz
    APPEND betsl.
  ENDIF.

ENDFORM.                               " BETSL_AUFBAUEN

*----------------------------------------------------------------------*
*       FORM APPEND_BETZ_WA
*----------------------------------------------------------------------*
*       Aufruf erfolgt unmittelbar nach dem Appendieren der BETZ. Der
*       zugeh?ige BETZ_WA Eintrag wird hinzugef?t.
*----------------------------------------------------------------------*
*  -->  BETZ
*  -->  BETZ_WA
*----------------------------------------------------------------------*
FORM append_betz_wa.

  DATA:
    ld_betzkey   LIKE betzkey,
    ld_subrc     LIKE sy-subrc,
    ld_tabix     LIKE sy-tabix.

* ML-W?rungen pr?en f? EKBE
  PERFORM ml_waers_info_lesen.
  CHECK gd_ipot_info-ekbe_kz NE space.

* Schl?sel versorgen
  MOVE-CORRESPONDING betz TO ld_betzkey.
  betz_wa-key = ld_betzkey.

* Sortiert appendieren
  READ TABLE betz_wa WITH KEY
             key = ld_betzkey BINARY SEARCH.

* Plausibilit?spr?ung: Eintrag darf noch nicht vorhanden sein
  PERFORM breakrc0 USING 'L001'.
  ld_tabix = sy-tabix.
  ld_subrc = sy-subrc.
  INSERT betz_wa INDEX ld_tabix.
ENDFORM.                    "APPEND_BETZ_WA

*----------------------------------------------------------------------*
* Kontierte Bestellung: Summensatz WE aus Summensatz RE fortschreiben  *
*----------------------------------------------------------------------*
FORM betz_summe_kont.

  DATA:
  ld_betz_sav1  LIKE betz,      "Sicherung: BETZ-Leiste         "K003063
  ld_betz_sav2  LIKE betz.      "Sicherung: BETZ-Leiste         "K003063
  DATA: ld_tabix LIKE sy-tabix.                             "P9BK195545


  ld_betz_sav1 = betz.                                      "K003063
  CHECK betz-zekkn NE '00'.
  MOVE betz TO ekbez.
  CLEAR betz.
  MOVE-CORRESPONDING ekbez TO betzkey.
  betzkey-zekkn = '00'.
  READ TABLE betz WITH KEY betzkey BINARY SEARCH.
  IF sy-subrc > 0.                                          "4.6a
    MOVE-CORRESPONDING betzkey TO betz.                     "4.6a
    betz-packno = ekbez-packno.                             "4.6a
    betz-introw = ekbez-introw.                             "4.6a
    INSERT betz INDEX sy-tabix.                             "4.6a
  ENDIF.                                                    "4.6a
* CHECK SY-SUBRC EQ 0.                                         "4.6a
  betz-remng = betz-remng + ekbez-remng.
  betz-bprem = betz-bprem + ekbez-bprem.
  betz-rewrt = betz-rewrt + ekbez-rewrt.
  betz-rewwr = betz-rewwr + ekbez-rewwr.
  betz-arewr = betz-arewr + ekbez-arewr.
  IF su_arekz NE space.
    betz-areww = betz-areww + ekbez-areww.
  ELSE.
    CLEAR betz-areww.
  ENDIF.
  betz-rewae = ekbez-rewae.                                 "429171
  betz-reewr = betz-reewr + ekbez-reewr.
  betz-refwr = betz-refwr + ekbez-refwr.
  betz-wemng = betz-wemng + ekbez-wemng.
  betz-bpmng = betz-bpmng + ekbez-bpmng.
  betz-bpwes = betz-bpwes + ekbez-bpwes.
  betz-wesbs = betz-wesbs + ekbez-wesbs.
  betz-wewrt = betz-wewrt + ekbez-wewrt.
  betz-wewwr = betz-wewwr + ekbez-wewwr.
  IF ekbez-lsmeh NE space AND ekbez-lsmng NE 0.
    IF betz-lsmeh NE '***'.
      IF betz-lsmeh EQ ekbez-lsmeh OR betz-lsmeh EQ space.
        betz-lsmng = betz-lsmng + ekbez-lsmng.
        betz-lsmeh = ekbez-lsmeh.
      ELSE.
        CLEAR: betz-lsmng.
        betz-lsmeh = '***'.
      ENDIF.
    ENDIF.
  ENDIF.
  betz-neurh = betz-neurh + ekbez-neurh.                    "tk 4.5b
  betz-neurw = betz-neurw + ekbez-neurw.                    "tk 4.5b
  betz-neudm = betz-neudm + ekbez-neudm.                    "tk 4.5b
  betz-neuwr = betz-neuwr + ekbez-neuwr.                    "tk 4.5b
  MODIFY betz INDEX sy-tabix.
  ld_tabix = sy-tabix.

  CLEAR betzkey.

* ML: Aufruf der analogene ...CR-Form "P9CK216332
  ld_betz_sav2 = betz.
  betz = ld_betz_sav1.
  PERFORM betz_summe_kont_cr
  USING   ld_tabix.

  betz = ld_betz_sav2.

ENDFORM.                    "betz_summe_kont

*----------------------------------------------------------------------*
* WE/RE-Statistikfelder aus BET ermitteln                              *
*----------------------------------------------------------------------*
FORM bet_analyse.

  bets-ebelp = bet-ebelp.
  bets-zekkn = bet-zekkn.

  betz-ebelp = bet-ebelp.
  betz-zekkn = bet-zekkn.

  betz-lfgja = bet-lfgja.
  betz-lfbnr = bet-lfbnr.
  betz-lfpos = bet-lfpos.
* IF BETZ-XBLNR IS INITIAL. "damit Lieferscheinbezug nach Storno bleibt
  IF betz-xblnr IS INITIAL AND
     ( bet-belnr EQ bet-lfbnr OR pot-pstyp = '9' ).         "80741
    betz-xblnr = bet-xblnr.
  ENDIF.
  betz-budat = bet-budat.
  IF bet-knumv NE space AND                                 "362965
 ( ( bet-shkzg EQ 'S' AND ekpo-retpo EQ space ) OR          "362965
   ( bet-shkzg EQ 'H' AND ekpo-retpo NE space ) )           "362965
     AND bet-vgabe NE '2'              "nicht aus Repr?
     AND bet-vgabe NE '3'.             "keine Kontenpflege
    IF betz-knumv IS INITIAL.                               "459388
      betz-knumv = bet-knumv.
    ENDIF.                                                  "459388
  ENDIF.
  IF NOT bet-etens IS INITIAL.                              "77360
    betz-etens = bet-etens.                                 "77360
  ENDIF.                                                    "77360
  betz-packno = bet-packno.
  betz-introw = bet-introw.

*------- Datum letzter Vorgang -----------------------------------------
  IF bet-budat > h-lvgdt.
    h-lvgdt = bet-budat.
  ENDIF.
*------- Erfasste Rechnungswerte mit default versehen ------------------
*- zu 3.0A nicht mehr n?ig --------------------------------------------
*IF BET-VGABE EQ '2' OR
*   BET-VGABE EQ '3'.
*  IF BET-REEWR EQ 0.
*     BET-REEWR = BET-DMBTR.
*  ENDIF.
*  IF BET-REFWR EQ 0.
*     BET-REFWR = BET-WRBTR.
*  ENDIF.
*ENDIF.

  CASE bet-vgabe.
*------- Wareneingang --------------------------------------------------
    WHEN '1'.
*------- Datum erster WE ----- -----------------------------------------
      IF h-bzdat EQ 0 OR
         h-bzdat > bet-budat.
        h-bzdat = bet-budat.
      ENDIF.

      IF ekpo-pstyp EQ pstyp-kons AND                       "395893
         ekpo-bprme NE space      AND                       "395893
         bet-bpmng  EQ 0          AND                       "395893
         ekpo-meins EQ ekpo-bprme.                          "395893
        bet-bpmng = bet-menge.                              "395893
      ENDIF.                                                "395893

*--------- Erfasser des WE's (nur Zugang) -----------------------
      IF bets-wenam EQ space AND bet-shkzg EQ 'S'.
        bets-wenam = bet-ernam.
      ENDIF.
      IF betz-wenam EQ space AND bet-shkzg EQ 'S'.
        betz-wenam = bet-ernam.
      ENDIF.

      IF bet-dmbtr NE 0 AND bet-wrbtr EQ 0 AND              "116286
         bet-waers IS INITIAL.                              "116286
* alte WE's aus 3.0/3.1 zu Bestellungen in Hausw?rung haben keinen
* WRBTR --> mit Hausw?rungsbetrag f?len
        bet-wrbtr = bet-dmbtr.                              "116286
      ENDIF.                                                "116286

      IF betz-webud IS INITIAL OR bet-budat LT betz-webud.  "208381
        betz-webud = bet-budat.
      ENDIF.
      IF betz-bwtar IS INITIAL.                             "74265
        betz-bwtar = bet-bwtar.
      ENDIF.                                                "74265
      IF bet-shkzg = 'S'.
        IF h_bets_wemng IS INITIAL.                         "TK 4.5A
          refe1 = bets-wemng + bet-menge.                   "TK 4.5A
          IF refe1 LE maxmenge.                             "TK 4.5A
            bets-wemng = bets-wemng + bet-menge.            "TK 4.5A
          ELSE.                                             "TK 4.5A
            h_bets_wemng = refe1.                           "TK 4.5A
            CLEAR bets-wemng.                               "TK 4.5A
          ENDIF.                                            "TK 4.5A
        ELSE.                                               "TK 4.5A
          h_bets_wemng = h_bets_wemng + bet-menge.          "TK 4.5A
        ENDIF.                                              "TK 4.5A
*       BETS-WEMNG = BETS-WEMNG + BET-MENGE.               "TK 4.5A
        IF h_betz_wemng IS INITIAL.                         "TK 4.5A
          refe1 = betz-wemng + bet-menge.                   "TK 4.5A
          IF refe1 LE maxmenge.                             "TK 4.5A
            betz-wemng = betz-wemng + bet-menge.            "TK 4.5A
          ELSE.                                             "TK 4.5A
            h_betz_wemng = refe1.                           "TK 4.5A
            CLEAR betz-wemng.                               "TK 4.5A
          ENDIF.                                            "TK 4.5A
        ELSE.                                               "TK 4.5A
          h_betz_wemng = h_betz_wemng + bet-menge.          "TK 4.5A
        ENDIF.                                              "TK 4.5A
*       BETZ-WEMNG = BETZ-WEMNG + BET-MENGE.               "TK 4.5A
        IF h_bets_bpmng IS INITIAL.                         "TK 4.5A
          refe1 = bets-bpmng + bet-bpmng.                   "TK 4.5A
          IF refe1 LE maxmenge.                             "TK 4.5A
            bets-bpmng = bets-bpmng + bet-bpmng.            "TK 4.5A
          ELSE.                                             "TK 4.5A
            h_bets_bpmng = refe1.                           "TK 4.5A
            CLEAR bets-bpmng.                               "TK 4.5A
          ENDIF.                                            "TK 4.5A
        ELSE.                                               "TK 4.5A
          h_bets_bpmng = h_bets_bpmng + bet-bpmng.          "TK 4.5A
        ENDIF.                                              "TK 4.5A
*       BETS-BPMNG = BETS-BPMNG + BET-BPMNG.               "TK 4.5A
        IF h_betz_bpmng IS INITIAL.                         "TK 4.5A
          refe1 = betz-bpmng + bet-bpmng.                   "TK 4.5A
          IF refe1 LE maxmenge.                             "TK 4.5A
            betz-bpmng = betz-bpmng + bet-bpmng.            "TK 4.5A
          ELSE.                                             "TK 4.5A
            h_betz_bpmng = refe1.                           "TK 4.5A
            CLEAR betz-bpmng.                               "TK 4.5A
          ENDIF.                                            "TK 4.5A
        ELSE.                                               "TK 4.5A
          h_betz_bpmng = h_betz_bpmng + bet-bpmng.          "TK 4.5A
        ENDIF.                                              "TK 4.5A
*       BETZ-BPMNG = BETZ-BPMNG + BET-BPMNG.               "TK 4.5A
        IF NOT bet-xwoff IS INITIAL.
          bets-wemmg = bets-wemmg + bet-menge.
          betz-wemmg = betz-wemmg + bet-menge.
          bets-bpwmm = bets-bpwmm + bet-bpmng.
          betz-bpwmm = betz-bpwmm + bet-bpmng.
        ENDIF.
        bets-bpwes = bets-bpwes + bet-bpwes.
        betz-bpwes = betz-bpwes + bet-bpwes.
        bets-wesbs = bets-wesbs + bet-wesbs.
        betz-wesbs = betz-wesbs + bet-wesbs.
        bets-wewrt = bets-wewrt + bet-dmbtr.
        betz-wewrt = betz-wewrt + bet-dmbtr.
        bets-wewwr = bets-wewwr + bet-wrbtr.
        betz-wewwr = betz-wewwr + bet-wrbtr.
        IF bet-lsmeh NE space AND bet-lsmng NE 0.
          IF betz-lsmeh NE '***'.
            IF betz-lsmeh EQ bet-lsmeh OR betz-lsmeh EQ space.
              betz-lsmng = betz-lsmng + bet-lsmng.
              betz-lsmeh = bet-lsmeh.
            ELSE.
              CLEAR: betz-lsmng.
              betz-lsmeh = '***'.
            ENDIF.
          ENDIF.
        ENDIF.
      ELSE.
        IF h_bets_wemng IS INITIAL.                         "TK 4.5A
          bets-wemng = bets-wemng - bet-menge.              "TK 4.5A
        ELSE.                                               "TK 4.5A
          h_bets_wemng = h_bets_wemng - bet-menge.          "TK 4.5A
        ENDIF.                                              "TK 4.5A
*       BETS-WEMNG = BETS-WEMNG - BET-MENGE.               "TK 4.5A
        IF h_betz_wemng IS INITIAL.                         "TK 4.5A
          betz-wemng = betz-wemng - bet-menge.              "TK 4.5A
        ELSE.                                               "TK 4.5A
          h_betz_wemng = h_betz_wemng - bet-menge.          "TK 4.5A
        ENDIF.                                              "TK 4.5A
*       BETZ-WEMNG = BETZ-WEMNG - BET-MENGE.               "TK 4.5A
        IF h_bets_bpmng IS INITIAL.                         "TK 4.5A
          bets-bpmng = bets-bpmng - bet-bpmng.              "TK 4.5A
        ELSE.                                               "TK 4.5A
          h_bets_bpmng = h_bets_bpmng - bet-bpmng.          "TK 4.5A
        ENDIF.                                              "TK 4.5A
*       BETS-BPMNG = BETS-BPMNG - BET-BPMNG.               "TK 4.5A
        IF h_betz_bpmng IS INITIAL.                         "TK 4.5A
          betz-bpmng = betz-bpmng - bet-bpmng.              "TK 4.5A
        ELSE.                                               "TK 4.5A
          h_betz_bpmng = h_betz_bpmng - bet-bpmng.          "TK 4.5A
        ENDIF.                                              "TK 4.5A
*       BETZ-BPMNG = BETZ-BPMNG - BET-BPMNG.               "TK 4.5A
        IF NOT bet-xwoff IS INITIAL.
          bets-wemmg = bets-wemmg - bet-menge.
          betz-wemmg = betz-wemmg - bet-menge.
          bets-bpwmm = bets-bpwmm - bet-bpmng.
          betz-bpwmm = betz-bpwmm - bet-bpmng.
        ENDIF.
        bets-bpwes = bets-bpwes - bet-bpwes.
        betz-bpwes = betz-bpwes - bet-bpwes.
        bets-wesbs = bets-wesbs - bet-wesbs.
        betz-wesbs = betz-wesbs - bet-wesbs.
        bets-wewrt = bets-wewrt - bet-dmbtr.
        betz-wewrt = betz-wewrt - bet-dmbtr.
        bets-wewwr = bets-wewwr - bet-wrbtr.
        betz-wewwr = betz-wewwr - bet-wrbtr.
        IF bet-lsmeh NE space AND bet-lsmng NE 0.
          IF betz-lsmeh NE '***'.
            IF betz-lsmeh EQ bet-lsmeh OR betz-lsmeh EQ space.
              betz-lsmng = betz-lsmng - bet-lsmng.
              betz-lsmeh = bet-lsmeh.
            ELSE.
              CLEAR: betz-lsmng.
              betz-lsmeh = '***'.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.
      betz-mblnr = bet-belnr.
      betz-mblpo = bet-buzei.
      betz-mjahr = bet-gjahr.
*------- Rechnung oder Kontenpflege ---( Mengen und Werte )-------------
    WHEN '2'.
      IF NOT bet-arewr IS INITIAL AND bet-areww IS INITIAL.
*     alte EKBE-S?ze haben den AREWW noch nicht -->
*     errechnen aus Verh?tnis Betrag Haus-/Fremdw?rung
        IF bet-dmbtr EQ 0.                                  "tk 4.6a2
          CLEAR su_arekz.    "tk 4.6a2                  "tk 4.6a
        ELSE.                                               "tk 4.6a2
          refe1 = bet-arewr * bet-wrbtr / bet-dmbtr.        "tk 4.6a
*         IF refe1 GT maxwert.         "tk 4.6a
          refe1abs = ABS( refe1 ).
          IF refe1abs GT maxwert.
            CLEAR su_arekz.                                 "tk 4.6a
          ELSE.                                             "tk 4.6a
            bet-areww = refe1.                              "tk 4.6a
          ENDIF.                                            "tk 4.6a
        ENDIF.                                              "tk 4.6a2
      ENDIF.
      IF bet-shkzg = 'S'.
        bets-remng = bets-remng + bet-menge.
        betz-remng = betz-remng + bet-menge.
        bets-bprem = bets-bprem + bet-bpmng.
        betz-bprem = betz-bprem + bet-bpmng.
        bets-rewrt = bets-rewrt + bet-dmbtr.
        betz-rewrt = betz-rewrt + bet-dmbtr.
        bets-arewr = bets-arewr + bet-arewr.
        betz-arewr = betz-arewr + bet-arewr.
        bets-reewr = bets-reewr + bet-reewr.
        betz-reewr = betz-reewr + bet-reewr.
        IF su_fwknz NE space.
          IF su_waers = space.
            su_waers = bet-waers.
          ENDIF.
          IF su_kont_waers = space.                         "72479
            su_kont_waers = bet-waers.                      "72479
          ENDIF.                                            "72479
*         IF SU_WAERS = BET-WAERS.                               "72479
          IF su_kont_waers = bet-waers.                     "72479
            bets-rewae = bet-waers.
            betz-rewae = bet-waers.
            bets-rewwr = bets-rewwr + bet-wrbtr.
            betz-rewwr = betz-rewwr + bet-wrbtr.
            IF su_arekz NE space. "d.h. alle RE-S?ze haben den AREWW
              bets-areww = bets-areww + bet-areww.
              betz-areww = betz-areww + bet-areww.
            ELSE.
              CLEAR: bets-areww, betz-areww.
            ENDIF.
            bets-refwr = bets-refwr + bet-refwr.
            betz-refwr = betz-refwr + bet-refwr.
          ELSE.
            IF bet-bewtp NE 'K'.                            "422933
              CLEAR: bets-rewae, betz-rewae.
              CLEAR: bets-rewwr, betz-rewwr.
              CLEAR: bets-areww, betz-areww.
              CLEAR: bets-refwr, betz-refwr.
              CLEAR: su_fwknz.
              CLEAR: su_fwknz_pos.                          "72479
            ENDIF.                                          "422933
          ENDIF.
        ENDIF.
      ELSE.
        bets-remng = bets-remng - bet-menge.
        betz-remng = betz-remng - bet-menge.
        bets-bprem = bets-bprem - bet-bpmng.
        betz-bprem = betz-bprem - bet-bpmng.
        bets-rewrt = bets-rewrt - bet-dmbtr.
        betz-rewrt = betz-rewrt - bet-dmbtr.
        bets-arewr = bets-arewr - bet-arewr.
        betz-arewr = betz-arewr - bet-arewr.
        bets-reewr = bets-reewr - bet-reewr.
        betz-reewr = betz-reewr - bet-reewr.
        IF su_fwknz NE space.
          IF su_waers = space.
            su_waers = bet-waers.
          ENDIF.
          IF su_kont_waers = space.                         "72479
            su_kont_waers = bet-waers.                      "72479
          ENDIF.                                            "72479
*         IF SU_WAERS = BET-WAERS.                               "72479
          IF su_kont_waers = bet-waers.                     "72479
            bets-rewae = bet-waers.
            betz-rewae = bet-waers.
            bets-rewwr = bets-rewwr - bet-wrbtr.
            betz-rewwr = betz-rewwr - bet-wrbtr.
            IF su_arekz NE space. "d.h. alle RE-S?ze haben den AREWW
              bets-areww = bets-areww - bet-areww.
              betz-areww = betz-areww - bet-areww.
            ELSE.
              CLEAR: bets-areww, betz-areww.
            ENDIF.
            bets-refwr = bets-refwr - bet-refwr.
            betz-refwr = betz-refwr - bet-refwr.
          ELSE.
            IF bet-bewtp NE 'K'.                            "422933
              CLEAR: bets-rewae, betz-rewae.
              CLEAR: bets-rewwr, betz-rewwr.
              CLEAR: bets-areww, betz-areww.
              CLEAR: bets-refwr, betz-refwr.
              CLEAR: su_fwknz.
              CLEAR: su_fwknz_pos.                          "72479
            ENDIF.                                          "422933
          ENDIF.
        ENDIF.
      ENDIF.
      PERFORM bet_doc_currency_fields USING bet             "215075
                                    CHANGING bets-rewwb
                                             betz-rewwb
                                             bets-arewb
                                             betz-arewb.
      betz-xunpl = bet-xunpl.          "ungeplante Kontierung
      bets-xunpl = bet-xunpl.
*------- Nachbelastung ----- ( nur Werte )------------------------------
    WHEN '3'.
      IF NOT bet-arewr IS INITIAL AND bet-areww IS INITIAL.
*     alte EKBE-S?ze haben den AREWW noch nicht -->
*     errechnen aus Verh?tnis Betrag Haus-/Fremdw?rung
        IF bet-dmbtr EQ 0.                                  "tk 4.6a2
          CLEAR su_arekz. "tk 4.6a2                     "tk 4.6a
        ELSE.                                               "tk 4.6a2
          refe1 = bet-arewr * bet-wrbtr / bet-dmbtr.        "tk 4.6a
*         IF refe1 GT maxwert.         "tk 4.6a
          refe1abs = ABS( refe1 ).
          IF refe1abs GT maxwert.
            CLEAR su_arekz.                                 "tk 4.6a
          ELSE.                                             "tk 4.6a
            bet-areww = refe1.                              "tk 4.6a
          ENDIF.                                            "tk 4.6a
        ENDIF.                                              "tk 4.6a2
      ENDIF.
      SELECT SINGLE * FROM t163b WHERE bewtp = bet-bewtp.
      CHECK sy-subrc EQ 0.
      CHECK t163b-tbtkz NE space.
      IF bet-bewtp NE 'W'.                                  "tk 4.5b
        IF bet-shkzg = 'S'.
          bets-rewrt = bets-rewrt + bet-dmbtr.
          betz-rewrt = betz-rewrt + bet-dmbtr.
          bets-arewr = bets-arewr + bet-arewr.
          betz-arewr = betz-arewr + bet-arewr.
          bets-reewr = bets-reewr + bet-reewr.
          betz-reewr = betz-reewr + bet-reewr.
          IF su_fwknz NE space.
            IF su_waers = space.
              su_waers = bet-waers.
            ENDIF.
            IF su_kont_waers = space.                       "72479
              su_kont_waers = bet-waers.                    "72479
            ENDIF.                                          "72479
*         IF SU_WAERS = BET-WAERS.                               "72479
            IF su_kont_waers = bet-waers.                   "72479
              bets-rewae = bet-waers.
              betz-rewae = bet-waers.
              bets-rewwr = bets-rewwr + bet-wrbtr.
              betz-rewwr = betz-rewwr + bet-wrbtr.
              IF su_arekz NE space. "d.h. alle RE-S?ze haben den AREWW
                bets-areww = bets-areww + bet-areww.
                betz-areww = betz-areww + bet-areww.
              ELSE.
                CLEAR: bets-areww, betz-areww.
              ENDIF.
              bets-refwr = bets-refwr + bet-refwr.
              betz-refwr = betz-refwr + bet-refwr.
            ELSE.
              IF bet-bewtp NE 'K'.                          "422933
                CLEAR: bets-rewae, betz-rewae.
                CLEAR: bets-rewwr, betz-rewwr.
                CLEAR: bets-areww, betz-areww.
                CLEAR: bets-refwr, betz-refwr.
                CLEAR: su_fwknz.
                CLEAR: su_fwknz_pos.                        "72479
              ENDIF.                                        "422933
            ENDIF.
          ENDIF.
        ELSE.
          bets-rewrt = bets-rewrt - bet-dmbtr.
          betz-rewrt = betz-rewrt - bet-dmbtr.
          bets-arewr = bets-arewr - bet-arewr.
          betz-arewr = betz-arewr - bet-arewr.
          bets-reewr = bets-reewr - bet-reewr.
          betz-reewr = betz-reewr - bet-reewr.
          IF su_fwknz NE space.
            IF su_waers = space.
              su_waers = bet-waers.
            ENDIF.
            IF su_kont_waers = space.                       "72479
              su_kont_waers = bet-waers.                    "72479
            ENDIF.                                          "72479
*         IF SU_WAERS = BET-WAERS.                               "72479
            IF su_kont_waers = bet-waers.                   "72479
              bets-rewae = bet-waers.
              betz-rewae = bet-waers.
              bets-rewwr = bets-rewwr - bet-wrbtr.
              betz-rewwr = betz-rewwr - bet-wrbtr.
              IF su_arekz NE space. "d.h. alle RE-S?ze haben den AREWW
                bets-areww = bets-areww - bet-areww.
                betz-areww = betz-areww - bet-areww.
              ELSE.
                CLEAR: bets-areww, betz-areww.
              ENDIF.
              bets-refwr = bets-refwr - bet-refwr.
              betz-refwr = betz-refwr - bet-refwr.
            ELSE.
              IF bet-bewtp NE 'K'.                          "422933
                CLEAR: bets-rewae, betz-rewae.
                CLEAR: bets-rewwr, betz-rewwr.
                CLEAR: bets-areww, betz-areww.
                CLEAR: bets-refwr, betz-refwr.
                CLEAR: su_fwknz.
                CLEAR: su_fwknz_pos.                        "72479
              ENDIF.                                        "422933
            ENDIF.
          ENDIF.
        ENDIF.
        PERFORM bet_doc_currency_fields USING bet           "215075
                                      CHANGING bets-rewwb
                                               betz-rewwb
                                               bets-arewb
                                               betz-arewb.
        betz-xunpl = bet-xunpl.        "ungeplante Kontierung
        bets-xunpl = bet-xunpl.
      ELSE.                                                 "tk 4.5b
* Neubewertung mit RMMR1MRB -> eigene Felder (wg. WE-Storno)
        IF bet-shkzg = 'S'.                                 "tk 4.5b
          bets-neurh = bets-neurh + bet-reewr.              "tk 4.5b
          betz-neurh = betz-neurh + bet-reewr.              "tk 4.5b
          betz-neudm = betz-neudm + bet-dmbtr.              "tk 4.5b
          bets-neudm = bets-neudm + bet-dmbtr.              "tk 4.5b
          IF su_fwknz NE space.                             "tk 4.5b
            IF su_waers = space.                            "tk 4.5b
              su_waers = bet-waers.                         "tk 4.5b
            ENDIF.                                          "tk 4.5b
            IF su_kont_waers = space.                       "tk 4.5b
              su_kont_waers = bet-waers.                    "tk 4.5b
            ENDIF.                                          "tk 4.5b
            IF su_kont_waers = bet-waers.                   "tk 4.5b
              bets-rewae = bet-waers.                       "tk 4.5b
              betz-rewae = bet-waers.                       "tk 4.5b
              bets-neurw = bets-neurw + bet-refwr.          "tk 4.5b
              betz-neurw = betz-neurw + bet-refwr.          "tk 4.5b
              bets-neuwr = bets-neuwr + bet-wrbtr.          "tk 4.5b
              betz-neuwr = betz-neuwr + bet-wrbtr.          "tk 4.5b
            ELSE.                                           "tk 4.5b
              IF bet-bewtp NE 'K'.                          "422933
                CLEAR: bets-rewae, betz-rewae.              "tk 4.5b
                CLEAR: bets-rewwr, betz-rewwr.              "tk 4.5b
                CLEAR: bets-areww, betz-areww.              "tk 4.5b
                CLEAR: bets-refwr, betz-refwr.              "tk 4.5b
                CLEAR: bets-neurw, betz-neurw.              "tk 4.5b
                CLEAR: bets-neuwr, betz-neuwr.              "tk 4.5b
                CLEAR: su_fwknz.                            "tk 4.5b
                CLEAR: su_fwknz_pos.                        "tk 4.5b
              ENDIF.                                        "422933
            ENDIF.                                          "tk 4.5b
          ENDIF.                                            "tk 4.5b
        ELSE.                                               "tk 4.5b
          bets-neurh = bets-neurh - bet-reewr.              "tk 4.5b
          betz-neurh = betz-neurh - bet-reewr.              "tk 4.5b
          bets-neudm = bets-neudm - bet-dmbtr.              "tk 4.5b
          betz-neudm = betz-neudm - bet-dmbtr.              "tk 4.5b
          IF su_fwknz NE space.                             "tk 4.5b
            IF su_waers = space.                            "tk 4.5b
              su_waers = bet-waers.                         "tk 4.5b
            ENDIF.                                          "tk 4.5b
            IF su_kont_waers = space.                       "tk 4.5b
              su_kont_waers = bet-waers.                    "tk 4.5b
            ENDIF.                                          "tk 4.5b
            IF su_kont_waers = bet-waers.                   "tk 4.5b
              bets-rewae = bet-waers.                       "tk 4.5b
              betz-rewae = bet-waers.                       "tk 4.5b
              bets-neurw = bets-neurw - bet-refwr.          "tk 4.5b
              betz-neurw = betz-neurw - bet-refwr.          "tk 4.5b
              bets-neuwr = bets-neuwr - bet-wrbtr.          "tk 4.5b
              betz-neuwr = betz-neuwr - bet-wrbtr.          "tk 4.5b
            ELSE.                                           "tk 4.5b
              IF bet-bewtp NE 'K'.                          "422933
                CLEAR: bets-rewae, betz-rewae.              "tk 4.5b
                CLEAR: bets-rewwr, betz-rewwr.              "tk 4.5b
                CLEAR: bets-areww, betz-areww.              "tk 4.5b
                CLEAR: bets-refwr, betz-refwr.              "tk 4.5b
                CLEAR: bets-neurw, betz-neurw.              "tk 4.5b
                CLEAR: bets-neuwr, betz-neuwr.              "tk 4.5b
                CLEAR: su_fwknz.                            "tk 4.5b
                CLEAR: su_fwknz_pos.                        "tk 4.5b
              ENDIF.                                        "422933
            ENDIF.                                          "tk 4.5b
          ENDIF.                                            "tk 4.5b
        ENDIF.                                              "tk 4.5b
      ENDIF.                                                "tk 4.5b
*------- Anzahlung -----------------------------------------------------
    WHEN '4'.
      IF bet-shkzg = 'S'.
        bets-anzal = bets-anzal + bet-dmbtr.
      ELSE.
        bets-anzal = bets-anzal - bet-dmbtr.
      ENDIF.
*------- Zahlung -------------------------------------------------------
    WHEN '5'.
*-------Warenausgaabe --------------------------------------------------
    WHEN '6'.
      IF bet-shkzg = 'H'.
        bets-wamng = bets-wamng + bet-menge.
      ELSE.
        bets-wamng = bets-wamng - bet-menge.
      ENDIF.
      betz-mblnr = bet-belnr.
      betz-mblpo = bet-buzei.
      betz-mjahr = bet-gjahr.
*-------Lieferung -- ---------------------------------------------------
    WHEN '8'.
      bets-glmng = bets-glmng + bet-menge.
*-------Vorerfasste Rechnung-------------------------------------------
    WHEN 'P'.                                               "435593
      bets-preiv = 'X'.
  ENDCASE.
  PERFORM bet_analyse_cr.                                   "K003063

ENDFORM.                    "bet_analyse

*----------------------------------------------------------------------*
*       FORM APPEND_BETB_WA
*----------------------------------------------------------------------*
*       Aufruf erfolgt nach Appendieren der BETB. Der zugeh?ige
*       BETB_WA Eintrag wird sortiert hinzugef?t.
*----------------------------------------------------------------------*
*  -->  BETB      Appendierter BETB-Eintrag
*----------------------------------------------------------------------*
FORM append_betb_wa.

  DATA:
    ld_key     LIKE betb_key,
    ld_subrc   LIKE sy-subrc,
    ld_tabix   LIKE sy-tabix.

* ML-W?rungen pr?en f? EKBZ
  PERFORM ml_waers_info_lesen.
  CHECK gd_ipot_info-ekbz_kz NE space.

* Schl?sel versorgen
  MOVE-CORRESPONDING betb TO ld_key.
  betb_wa-key = ld_key.

* Sortiert appendieren
  READ TABLE betb_wa WITH KEY
             key = ld_key BINARY SEARCH.

* Plausibilit?spr?ung: Eintrag darf noch nicht vorhanden sein
  PERFORM breakrc0 USING 'L003'.
  ld_tabix = sy-tabix.
  ld_subrc = sy-subrc.
  INSERT betb_wa INDEX ld_tabix.
ENDFORM.                    "APPEND_BETB_WA

*&--------------------------------------------------------------------*
*&      Form  BREAKRC0
*&--------------------------------------------------------------------*
*       text
*---------------------------------------------------------------------*
*      -->VALUE(V_ORTtext
*---------------------------------------------------------------------*
FORM breakrc0 USING
       value(v_ort).

* Interner Fehler bei RC = 0
  CHECK sy-subrc EQ 0.
  IF gd_namen CS sy-uname OR
     gd_flg_name_all NE space.
    MESSAGE e509(c+) WITH sy-repid v_ort sy-subrc.
  ENDIF.
ENDFORM.                                                    "BREAKRC0

*----------------------------------------------------------------------*
*       FORM APPEND_BETS_WA
*----------------------------------------------------------------------*
*       Aufruf erfolgt unmittelbar nach dem Appendieren der BETS. Der
*       zugeh?ige BETS_WA Eintrag wird hinzugef?t.
*----------------------------------------------------------------------*
*  -->  BETS
*  -->  BETS_WA
*----------------------------------------------------------------------*
FORM append_bets_wa.

  DATA:
    ld_betskey   LIKE betskey,
    ld_subrc     LIKE sy-subrc,
    ld_tabix     LIKE sy-tabix.

* ML-W?rungen pr?en f? EKBE
  PERFORM ml_waers_info_lesen.
  CHECK gd_ipot_info-ekbe_kz NE space.

* Schl?sel versorgen
  MOVE-CORRESPONDING bets TO ld_betskey.
  bets_wa-key = ld_betskey.

* Sortiert appendieren
  READ TABLE bets_wa WITH KEY
             key = ld_betskey BINARY SEARCH.

* Plausibilit?spr?ung: Eintrag darf noch nicht vorhanden sein
  PERFORM breakrc0 USING 'L002'.
  ld_tabix = sy-tabix.
  ld_subrc = sy-subrc.
  INSERT bets_wa INDEX ld_tabix.
ENDFORM.                    "APPEND_BETS_WA

*----------------------------------------------------------------K003063
* Parallele W?rungen:                                                 *
* Kontierte Bestellung: Summensatz WE aus Summensatz RE fortschreiben  *
*----------------------------------------------------------------------*
FORM betz_summe_kont_cr
USING id_tabix LIKE sy-tabix.                               "P9CK216332

  DATA:
    ld_betz_wa   LIKE betz_wa,
    ld_subrc     LIKE sy-subrc,
    ld_tabix     LIKE sy-tabix.

* ML-W?rungen pr?en f? EKBE
  PERFORM ml_waers_info_lesen.
* CHECK GD_IPOT_INFO-EKBZ_KZ NE SPACE.                    "Note 159112
  CHECK gd_ipot_info-ekbe_kz NE space.                     "Note 159112

* Addieren BETZ_WA --> BETZ_WA ( Zekkn = 0 )
  MOVE betz_wa TO ld_betz_wa.
  CLEAR betz_wa.
  MOVE-CORRESPONDING betz TO betzkey.
  betzkey-zekkn = '00'.
  READ TABLE betz_wa WITH KEY key = betzkey BINARY SEARCH.
  ld_tabix = sy-tabix.
  ld_subrc = sy-subrc.
  "CHECK LD_SUBRC EQ 0.
* insert _wa, if betz was inserted

  IF ld_subrc <> 0.                                         "P9BK195545
    betz_wa-key-ebelp = betzkey-ebelp.
    betz_wa-key-zekkn = betzkey-zekkn.
    betz_wa-key-lfgja = betzkey-lfgja.
    betz_wa-key-lfbnr = betzkey-lfbnr.
    betz_wa-key-lfpos = betzkey-lfpos.
    INSERT betz_wa INDEX id_tabix.                          "P9BK195545
    ld_tabix = id_tabix.
  ENDIF.

  PERFORM add_to USING:
* W1 = W1 + W2
  betz_wa-arewr ld_betz_wa-arewr,
  betz_wa-reewr ld_betz_wa-reewr,
  betz_wa-rewrt ld_betz_wa-rewrt,
  betz_wa-wewrt ld_betz_wa-wewrt.
  MODIFY betz_wa INDEX ld_tabix.
  CLEAR betzkey.
ENDFORM.                    "betz_summe_kont_cr

*&--------------------------------------------------------------------*
*&      Form  ML_WAERS_INFO_LESEN
*&--------------------------------------------------------------------*
*       text
*---------------------------------------------------------------------*
FORM ml_waers_info_lesen.

* Lesen ?er den POT-Eintrag (aktuelle Bestellposition)
  PERFORM ml_waers_info_xe_lesen USING
            pot-ebeln
            pot-ebelp.
ENDFORM.                    "ML_WAERS_INFO_LESEN
*       FORM ML_WAERS_INFO_XE_LESEN
*----------------------------------------------------------------------*
*       Es wird der Info-Block gelesen, der Infos ?er die ML-W?rungen
*       f? die aktuelle Bestellposition enth?t.
*       Die aktuelle Bestellposition wird dabei ?er die Paramter
*       ?ergeben.
*----------------------------------------------------------------------*
*  -->  V_EBELN      Bestellnummer
*  -->  V_EBELP      Bestellposition
*  -->  GP_IPOT_INFO Steuerinfo (parallele W?rungen)
*----------------------------------------------------------------------*
FORM ml_waers_info_xe_lesen USING
       value(v_ebeln)   LIKE ekbe-ebeln
       value(v_ebelp)   LIKE ekbe-ebelp.

* Falls Mlcur nicht ativiert ist => initialer Eintrag
  IF gd_mlwere-aktiv IS INITIAL.
    CLEAR gd_ipot_info.
    EXIT.
  ENDIF.

* Eventuell nachlesen
  IF gd_ipot_info-ebeln NE v_ebeln OR
     gd_ipot_info-ebelp NE v_ebelp.
    READ TABLE gd_ipot_tbl WITH KEY
         ebeln = v_ebeln
         ebelp = v_ebelp
         BINARY SEARCH.
    PERFORM breakrc USING 'L036'.
    gd_ipot_info-ebeln = gd_ipot_tbl-ebeln.
    gd_ipot_info-ebelp = gd_ipot_tbl-ebelp.
    gd_ipot_info-ekbe_kz = gd_ipot_tbl-ekbe_wa_kz.
    gd_ipot_info-ekbz_kz = gd_ipot_tbl-ekbz_wa_kz.
    gd_ipot_info-aktiv   = gd_ipot_tbl-aktiv.
  ENDIF.
ENDFORM.                    "ML_WAERS_INFO_XE_LESEN

*----------------------------------------------------------------------*
*       FORM ADD_TO
*----------------------------------------------------------------------*
*       Addieren zweier Werte (parallele W?rungen)
*       A-Wert =  A-Wert + B-Wert
*----------------------------------------------------------------------*
*  -->  R_AWERT     Wert-1
*  -->  R_BWERT     Wert-2
*----------------------------------------------------------------------*
FORM add_to USING
       r_awert TYPE mlcr_curr_tbl
       r_bwert TYPE mlcr_curr_tbl.

  DATA:
    ld_a LIKE LINE OF r_awert,
    ld_b LIKE LINE OF r_bwert.

* Nicht bearbeiten bei initialen Werten
  CHECK NOT r_awert IS INITIAL OR
        NOT r_bwert IS INITIAL.

* W?rungsvektoren angleichen
  PERFORM curr_angleichen USING
       r_awert
       r_bwert.

* A-Wert = A-Wert + B-Wert
  LOOP AT r_awert INTO ld_a.
    READ TABLE r_bwert INTO ld_b INDEX sy-tabix.
    PERFORM ml_curr_pruefen USING ld_a ld_b.
    ADD ld_b-wert TO ld_a-wert.
    MODIFY r_awert FROM ld_a.
  ENDLOOP.
ENDFORM.                    "ADD_TO

*----------------------------------------------------------------------*
*       FORM CURR_ANGLEICHEN
*----------------------------------------------------------------------*
*       Angleichen zweier W?rungsvektoren
*       (a) Beide Null -> nichts zu tun
*       (b) einer Null -> angleichen
*----------------------------------------------------------------------*
* <-->  R_CURR1  W?rungvektor-1
* <-->  R_CURR2  W?rungvektor-2
*----------------------------------------------------------------------*
FORM curr_angleichen USING
       r_curr1    TYPE mlcr_curr_tbl
       r_curr2    TYPE mlcr_curr_tbl.

  DATA:
    ld_curr     TYPE LINE OF mlcr_curr_tbl.

* Fall (a): Beide Null -> nichts zu tun
  IF r_curr1 IS INITIAL AND
     r_curr2 IS INITIAL.
    EXIT.

* Fall (b.1): Curr1 ist Null -> angleichen
  ELSEIF r_curr1 IS INITIAL.
    r_curr1 = r_curr2.
    LOOP AT r_curr1 INTO ld_curr.
      CLEAR ld_curr-wert.
      MODIFY r_curr1 FROM ld_curr.
    ENDLOOP.

* Fall (b.2): Curr2 ist Null -> angleichen
  ELSEIF r_curr2 IS INITIAL.
    r_curr2 = r_curr1.
    LOOP AT r_curr2 INTO ld_curr.
      CLEAR ld_curr-wert.
      MODIFY r_curr2 FROM ld_curr.
    ENDLOOP.
  ENDIF.
ENDFORM.                    "CURR_ANGLEICHEN


*4.6C Service Package
*RHUP9CK096547 241100 note 360963 Summierung Neubewertung
*QFHP9CK055825 250700 note 320280 applied
*----------------------------------------------------------------K003063
* Parallele W?rungen:                                                 *
* WE/RE-Statistikfelder aus BET ermitteln                              *
*----------------------------------------------------------------------*
FORM bet_analyse_cr.

  DATA:
    ld_betskey     LIKE betskey,
    ld_betzkey     LIKE betskey.

* Mu?f? die Bestellposition etwas getan werden?           "Note 320280
  PERFORM ml_waers_info_lesen.                              "Note 320280
  CHECK gd_ipot_info-ekbe_kz NE space.                      "Note 320280

* Bereitstellen der CR-S?ze
  MOVE-CORRESPONDING bets TO ld_betskey.
  bets_wa-key = ld_betskey.
  MOVE-CORRESPONDING betz TO ld_betzkey.
  betz_wa-key = ld_betzkey.
  PERFORM bet_wa_lesen.

  CASE bet-vgabe.
*------- Wareneingang --------------------------------------------------
    WHEN '1'.

      IF bet-shkzg = 'S'.
        PERFORM add_to USING:
*       W1 = W1 + W2
        bets_wa-wewrt bet_wa-dmbtr,
        betz_wa-wewrt bet_wa-dmbtr.
      ELSE.
        PERFORM sub_from USING:
*       W1 = W1 - W2
        bets_wa-wewrt bet_wa-dmbtr,
        betz_wa-wewrt bet_wa-dmbtr.
      ENDIF.

*------- Rechnung oder Kontenpflege ------------------------------------
    WHEN '2'.
      IF bet-shkzg = 'S'.
        PERFORM add_to USING:
*       W1 = W1 + W2
        bets_wa-rewrt bet_wa-dmbtr,
        betz_wa-rewrt bet_wa-dmbtr,
        bets_wa-arewr bet_wa-arewr,
        betz_wa-arewr bet_wa-arewr,
        bets_wa-reewr bet_wa-reewr,
        betz_wa-reewr bet_wa-reewr.
      ELSE.
        PERFORM sub_from USING:
*       W1 = W1 - W2
        bets_wa-rewrt bet_wa-dmbtr,
        betz_wa-rewrt bet_wa-dmbtr,
        bets_wa-arewr bet_wa-arewr,
        betz_wa-arewr bet_wa-arewr,
        bets_wa-reewr bet_wa-reewr,
        betz_wa-reewr bet_wa-reewr.
      ENDIF.

*------- Nachbelastung -------------------------------------------------
    WHEN '3'.
      SELECT SINGLE * FROM t163b WHERE bewtp = bet-bewtp.
      CHECK sy-subrc EQ 0.
      CHECK t163b-tbtkz NE space.
      IF bet-bewtp <> 'W'.               "Neubewertung nicht relevant
        IF bet-shkzg = 'S'.
          PERFORM add_to USING:
*       W1 = W1 + W2
          bets_wa-rewrt bet_wa-dmbtr,
          betz_wa-rewrt bet_wa-dmbtr,
          bets_wa-arewr bet_wa-arewr,
          betz_wa-arewr bet_wa-arewr,
          bets_wa-reewr bet_wa-reewr,
          betz_wa-reewr bet_wa-reewr.
        ELSE.
          PERFORM sub_from USING:
*       W1 = W1 - W2
          bets_wa-rewrt bet_wa-dmbtr,
          betz_wa-rewrt bet_wa-dmbtr,
          bets_wa-arewr bet_wa-arewr,
          betz_wa-arewr bet_wa-arewr,
          bets_wa-reewr bet_wa-reewr,
          betz_wa-reewr bet_wa-reewr.
        ENDIF.
      ENDIF.                            "Neubewertung

*------- Anzahlung -----------------------------------------------------
    WHEN '4'.
      IF bet-shkzg = 'S'.
        PERFORM add_to USING:
*       W1 = W1 + W2
        bets_wa-anzal bet_wa-dmbtr.
      ELSE.
        PERFORM sub_from USING:
*       W1 = W1 - W2
        bets_wa-anzal bet_wa-dmbtr.
      ENDIF.

*------- Zahlung -------------------------------------------------------
    WHEN '5'.

*-------Warenausgaabe --------------------------------------------------
    WHEN '6'.

*-------Lieferung -- ---------------------------------------------------
    WHEN '8'.

  ENDCASE.

ENDFORM.                    "bet_analyse_cr

*---------------------------------------------------------------------*
*       FORM bet_doc_currency_fields                                  *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  IM_BET                                                        *
*  -->  CH_BETS-REWWB                                                 *
*  -->  CH_BETZ-REWWB                                                 *
*  -->  CH_BETS-AREWB                                                 *
*  -->  CH_BETZ-AREWB                                                 *
*---------------------------------------------------------------------*
FORM bet_doc_currency_fields USING value(im_bet) TYPE ekbe
                              CHANGING ch_bets-rewwb TYPE ekbes-rewwb
                                       ch_betz-rewwb TYPE ekbez-rewwb
                                       ch_bets-arewb TYPE ekbes-arewb
                                       ch_betz-arewb TYPE ekbez-arewb.

  CHECK gf_new_logic NE space.
* see oss note 215075 too;
* this routine calculates the invoice receipt amount and the clearing
* amount posted from invoice in po currency for valuation purposes at
* time of GR (espacially when IR is before GR);
* these amounts are not stored in EKBE;
* if the po currency is the same as the invoice or the local currency
* the values are taken from the appropriate fields in EKBE;
* otherwise the amounts in local currency are converted to po currency
* with the posting date of the invoice;
* only if there is no conversion possible with the posting date, the
* conversion is done with the actual posting date or the system date;

  IF ekko-ebeln NE im_bet-ebeln.
* read po header
    CALL FUNCTION 'ME_EKKO_SINGLE_READ'
      EXPORTING
        pi_ebeln = bet-ebeln
      IMPORTING
        po_ekko  = ekko
      EXCEPTIONS
        OTHERS   = 1.
    CHECK sy-subrc EQ 0.
  ENDIF.
  CHECK ekko-waers NE space.

  IF im_bet-hswae EQ space.
* determine the local currency if not stored in EKBE
    IF im_bet-ebeln NE ekpo-ebeln OR
       im_bet-ebelp NE ekpo-ebelp.
      CALL FUNCTION 'ME_EKPO_SINGLE_READ'
        EXPORTING
          pi_ebeln = im_bet-ebeln
          pi_ebelp = im_bet-ebelp
        IMPORTING
          po_ekpo  = ekpo
        EXCEPTIONS
          OTHERS   = 1.
      CHECK sy-subrc EQ 0.
    ENDIF.
    IF ekpo-bukrs NE t001-bukrs.
      PERFORM buchungskreis_lesen USING ekpo-bukrs.
    ENDIF.
    im_bet-hswae = t001-waers.
  ENDIF.
* calculate the amounts
  DATA: lf_budat TYPE ekbe-budat.
  DATA: lf_rewwb TYPE ekbez-rewwb.
  DATA: lf_arewb TYPE ekbez-arewb.
  IF kurstyp EQ space.
    kurstyp = 'M'.
  ENDIF.
  IF im_bet-waers EQ ekko-waers.
    lf_rewwb = im_bet-wrbtr.
* because of oss note 134629 bet-areww should be filled for records
* posted before release 4.0 as well; but, to be not dependent from this
* correction the logic is done here again!!
    lf_arewb = im_bet-areww.
    IF NOT im_bet-arewr IS INITIAL AND im_bet-areww IS INITIAL.
*     older EKBE-records don't have the AREWW filled -->
*     calculate from correlation between local and foreign currency
      IF im_bet-dmbtr NE 0.
        refe1 = im_bet-arewr * im_bet-wrbtr / im_bet-dmbtr.
*       IF refe1 LE maxwert.
        refe1abs = ABS( refe1 ).
        IF refe1abs LE maxwert.
          im_bet-areww = refe1.
        ENDIF.
      ENDIF.
      IF im_bet-areww IS INITIAL.
* the above logic failed -> do currency conversion
* do the conversion with the posting date of the invoice
        CALL FUNCTION 'CONVERT_TO_FOREIGN_CURRENCY'
          EXPORTING
            date             = im_bet-budat
            foreign_currency = ekko-waers
            local_amount     = im_bet-arewr
            local_currency   = im_bet-hswae
            type_of_rate     = kurstyp
          IMPORTING
            foreign_amount   = lf_arewb
          EXCEPTIONS
            OTHERS           = 1.
        IF sy-subrc NE 0.
* do the conversion with the actual posting date
          IF NOT gd_budat IS INITIAL.  "posting date from GR
            lf_budat = gd_budat.
          ELSE.
            lf_budat = sy-datlo.
          ENDIF.
          CALL FUNCTION 'CONVERT_TO_FOREIGN_CURRENCY'
            EXPORTING
              date             = lf_budat
              foreign_currency = ekko-waers
              local_amount     = im_bet-arewr
              local_currency   = im_bet-hswae
              type_of_rate     = kurstyp
            IMPORTING
              foreign_amount   = lf_arewb
            EXCEPTIONS
              OTHERS           = 1.
          IF sy-subrc NE 0.
*           it is not allowed to have no conversion maintained
            MESSAGE a300(06).
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.
  ELSEIF im_bet-hswae EQ ekko-waers.
    lf_rewwb = im_bet-dmbtr.
    lf_arewb = im_bet-arewr.
  ELSE.
    IF im_bet-dmbtr NE 0.
* do the conversion for the posting amount
* do the conversion with the posting date of the invoice
      CALL FUNCTION 'CONVERT_TO_FOREIGN_CURRENCY'
        EXPORTING
          date             = im_bet-budat
          foreign_currency = ekko-waers
          local_amount     = im_bet-dmbtr
          local_currency   = im_bet-hswae
          type_of_rate     = kurstyp
        IMPORTING
          foreign_amount   = lf_rewwb
        EXCEPTIONS
          OTHERS           = 1.
      IF sy-subrc NE 0.
* do the conversion with the actual posting date
        IF NOT gd_budat IS INITIAL.    "posting date from GR
          lf_budat = gd_budat.
        ELSE.
          lf_budat = sy-datlo.
        ENDIF.
        CALL FUNCTION 'CONVERT_TO_FOREIGN_CURRENCY'
          EXPORTING
            date             = lf_budat
            foreign_currency = ekko-waers
            local_amount     = im_bet-dmbtr
            local_currency   = im_bet-hswae
            type_of_rate     = kurstyp
          IMPORTING
            foreign_amount   = lf_rewwb
          EXCEPTIONS
            OTHERS           = 1.
        IF sy-subrc NE 0.
*           it is not allowed to have no conversion maintained
          MESSAGE a300(06).
        ENDIF.
      ENDIF.
    ENDIF.

    IF im_bet-arewr NE 0.
* do the conversion for the clearing amount
* do the conversion with the posting date of the invoice
      CALL FUNCTION 'CONVERT_TO_FOREIGN_CURRENCY'
        EXPORTING
          date             = im_bet-budat
          foreign_currency = ekko-waers
          local_amount     = im_bet-arewr
          local_currency   = im_bet-hswae
          type_of_rate     = kurstyp
        IMPORTING
          foreign_amount   = lf_arewb
        EXCEPTIONS
          OTHERS           = 1.
      IF sy-subrc NE 0.
* do the conversion with the actual posting date
        IF NOT gd_budat IS INITIAL.    "posting date from GR
          lf_budat = gd_budat.
        ELSE.
          lf_budat = sy-datlo.
        ENDIF.
        CALL FUNCTION 'CONVERT_TO_FOREIGN_CURRENCY'
          EXPORTING
            date             = lf_budat
            foreign_currency = ekko-waers
            local_amount     = im_bet-arewr
            local_currency   = im_bet-hswae
            type_of_rate     = kurstyp
          IMPORTING
            foreign_amount   = lf_arewb
          EXCEPTIONS
            OTHERS           = 1.
        IF sy-subrc NE 0.
*           it is not allowed to have no conversion maintained
          MESSAGE a300(06).
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.

  IF im_bet-shkzg EQ 'S'.
    ch_bets-rewwb = ch_bets-rewwb + lf_rewwb.
    ch_betz-rewwb = ch_betz-rewwb + lf_rewwb.
    ch_bets-arewb = ch_bets-arewb + lf_arewb.
    ch_betz-arewb = ch_betz-arewb + lf_arewb.
  ELSE.
    ch_bets-rewwb = ch_bets-rewwb - lf_rewwb.
    ch_betz-rewwb = ch_betz-rewwb - lf_rewwb.
    ch_bets-arewb = ch_bets-arewb - lf_arewb.
    ch_betz-arewb = ch_betz-arewb - lf_arewb.
  ENDIF.

ENDFORM.                    "bet_doc_currency_fields

*----------------------------------------------------------------------*
*       FORM BET_WA_LESEN
*----------------------------------------------------------------------*
*       Der zum BET geh?ige CR-Eintrag wird eingelesen
*----------------------------------------------------------------------*
*  -->  BET
*  <--  BET_WA
*----------------------------------------------------------------------*
FORM bet_wa_lesen.

  DATA:
    ld_key     LIKE betkey.

* ML-W?rungen pr?en f? EKBE
  PERFORM ml_waers_info_lesen.
  CHECK gd_ipot_info-ekbe_kz NE space.

* Eintrag lesen
  MOVE-CORRESPONDING bet TO ld_key.
  READ TABLE bet_wa WITH KEY
             key = ld_key BINARY SEARCH.
  IF sy-subrc NE 0.
    IF gd_mlwere-null_bxt IS INITIAL.
      CLEAR bet_wa.
      bet_wa-key = ld_key.
    ELSE.
      PERFORM breakrc USING 'L005'.
    ENDIF.
  ENDIF.
ENDFORM.                    "BET_WA_LESEN

*----------------------------------------------------------------------*
*       FORM BREAKRC
*----------------------------------------------------------------------*
*       Abbruch bei internem Fehler:
*       SY-SUBRC ist ungleich Null, obwohl Null erwartet wird.
*----------------------------------------------------------------------*
*  -->  V_ORT            Fehlerstelle
*----------------------------------------------------------------------*
FORM breakrc USING
       value(v_ort).

* Interner Fehler bei RC <> 0
  CHECK sy-subrc NE 0.
  IF gd_namen CS sy-uname OR
     gd_flg_name_all NE space.
    MESSAGE e509(c+) WITH sy-repid v_ort sy-subrc.
  ENDIF.
ENDFORM.                    "BREAKRC

*&--------------------------------------------------------------------*
*&      Form  BUCHUNGSKREIS_LESEN
*&--------------------------------------------------------------------*
*       text
*---------------------------------------------------------------------*
*      -->I_BUKRS    text
*---------------------------------------------------------------------*
FORM buchungskreis_lesen USING i_bukrs.

  CALL FUNCTION 'FI_COMPANY_CODE_DATA'
    EXPORTING
      i_bukrs = i_bukrs
    IMPORTING
      e_t001  = t001.

ENDFORM.                    "BUCHUNGSKREIS_LESEN

*----------------------------------------------------------------------*
* Tabelle BZT analysieren                                              *
*----------------------------------------------------------------------*
FORM bzt_analyse.

  CASE bzt-vgabe.
*------- Frachtrueckstellung -------------------------------------------
    WHEN '1'.
      IF bzt-dmbtr LT 0.                                    "171902
        bzt-dmbtr = ABS( bzt-dmbtr ).                       "171902
      ENDIF.                                                "171902
      IF bzt-wrbtr LT 0.                                    "171902
        bzt-wrbtr = ABS( bzt-wrbtr ).                       "171902
      ENDIF.                                                "171902
      IF bzt-dmbtr NE 0 AND bzt-wrbtr EQ 0 AND              "116286
         bzt-waers IS INITIAL.                              "116286
* alte WE's aus 3.0/3.1 zu Bestellungen in Hausw?rung haben keinen
* WRBTR --> mit Hausw?rungsbetrag f?len
        bzt-wrbtr = bzt-dmbtr.                              "116286
      ENDIF.                                                "116286
*Begin of insertion note 0309399 :
      IF NOT bzt-waers IS INITIAL.
        IF bzt-ebeln NE ekko-ebeln.
          CALL FUNCTION 'ME_EKKO_SINGLE_READ'
            EXPORTING
              pi_ebeln      = bzt-ebeln
            IMPORTING
              po_ekko       = ekko
            EXCEPTIONS
              error_message = 01
              OTHERS        = 02.
          IF sy-subrc NE 0.
            CLEAR ekko.
          ENDIF.
        ENDIF.
        IF bzt-waers NE ekko-waers AND ekko-waers NE space.
* in release 3.1 EKBZ-WAERS was filled with local currency instead
* of document currency; see oss notes 309399 and 137819
          bzt-waers = ekko-waers.
        ENDIF.
      ENDIF.
* end of insertion note 0309399
      IF su_fwknz_we NE space.
        IF su_wewae = space.
          su_wewae = bzt-waers.
*        Bestellw?rung (BNK beim WE nur in Haus- und Bestellw?rung),
*        da kein Wert in Konditionsw?rung vorhanden
          betb-waers = bzt-waers.
        ENDIF.
      ENDIF.
      IF bzt-shkzg = 'S'.
        IF NOT bzt-vnetw IS INITIAL.
*       Nettowert der Bezugsnebenkosten aus SD-Transportabwicklung 4.0C
          betb-vnetw = betb-vnetw - bzt-vnetw.
          betb-vmeng = betb-vmeng - bzt-menge.
        ENDIF.
        CASE betb-bewtp.
          WHEN 'F'.
            betb-frwmg = betb-frwmg - bzt-menge.
            betb-bpfrw = betb-bpfrw - bzt-bpmng.
            betb-frwwr = betb-frwwr - bzt-dmbtr.
            IF su_fwknz_we NE space.
              IF su_wewae = bzt-waers.
                betb-frwfr = betb-frwfr - bzt-wrbtr.
              ENDIF.
            ENDIF.
          WHEN 'B'.
            betb-nawmg = betb-nawmg - bzt-menge.
            betb-bpnaw = betb-bpnaw - bzt-bpmng.
            betb-nawwr = betb-nawwr - bzt-dmbtr.
            IF su_fwknz_we NE space.
              IF su_wewae = bzt-waers.
                betb-nawfr = betb-nawfr - bzt-wrbtr.
              ENDIF.
            ENDIF.
          WHEN 'C'.
            betb-fnwmg = betb-fnwmg - bzt-menge.
            betb-bpfnw = betb-bpfnw - bzt-bpmng.
            betb-fnwwr = betb-fnwwr - bzt-dmbtr.
            IF su_fwknz_we NE space.
              IF su_wewae = bzt-waers.
                betb-fnwfr = betb-fnwfr - bzt-wrbtr.
              ENDIF.
            ENDIF.
        ENDCASE.
      ELSE.
        IF NOT bzt-vnetw IS INITIAL.
*       Nettowert der Bezugsnebenkosten aus SD-Transportabwicklung 4.0C
          betb-vnetw = betb-vnetw + bzt-vnetw.
          betb-vmeng = betb-vmeng + bzt-menge.
        ENDIF.
        CASE betb-bewtp.
          WHEN 'F'.
            betb-frwmg = betb-frwmg + bzt-menge.
            betb-bpfrw = betb-bpfrw + bzt-bpmng.
            betb-frwwr = betb-frwwr + bzt-dmbtr.
            IF su_fwknz_we NE space.
              IF su_wewae = bzt-waers.
                betb-frwfr = betb-frwfr + bzt-wrbtr.
              ENDIF.
            ENDIF.
          WHEN 'B'.
            betb-nawmg = betb-nawmg + bzt-menge.
            betb-bpnaw = betb-bpnaw + bzt-bpmng.
            betb-nawwr = betb-nawwr + bzt-dmbtr.
            IF su_fwknz_we NE space.
              IF su_wewae = bzt-waers.
                betb-nawfr = betb-nawfr + bzt-wrbtr.
              ENDIF.
            ENDIF.
          WHEN 'C'.
            betb-fnwmg = betb-fnwmg + bzt-menge.
            betb-bpfnw = betb-bpfnw + bzt-bpmng.
            betb-fnwwr = betb-fnwwr + bzt-dmbtr.
            IF su_fwknz_we NE space.
              IF su_wewae = bzt-waers.
                betb-fnwfr = betb-fnwfr + bzt-wrbtr.
              ENDIF.
            ENDIF.
        ENDCASE.
      ENDIF.
      IF su_wewae NE bzt-waers AND su_fwknz_we NE space.
*     keine einheitliche Fremdw?rung beim WE (z.b. auch alte Vorg?ge)
        CLEAR: betb-fnwfr, betb-nawfr, betb-frwfr.
        CLEAR: su_fwknz_we.
      ENDIF.
*------- Frachtrechnung ------ (Mengen und Werte) ---------------------
    WHEN '2'.
      IF NOT bzt-arewr IS INITIAL AND bzt-areww IS INITIAL.
*     alte EKBZ-S?ze haben den AREWW noch nicht -->
*     errechnen aus Verh?tnis Betrag Haus-/Fremdw?rung
        IF bzt-dmbtr EQ 0.                                  "tk 4.6a2
          CLEAR su_arekz. "tk 4.6a2                      "tk 4.6a
        ELSE.                                               "tk 4.6a2
          refe1 = bzt-arewr * bzt-wrbtr / bzt-dmbtr.        "tk 4.6a
*         IF refe1 GT maxwert.         "tk 4.6a
          refe1abs = ABS( refe1 ).
          IF refe1abs GT maxwert.
            CLEAR su_arekz.                                 "tk 4.6a
          ELSE.                                             "tk 4.6a
            bzt-areww = refe1.                              "tk 4.6a
          ENDIF.                                            "tk 4.6a
        ENDIF.                                              "tk 4.6a2
      ENDIF.
      IF su_fwknz NE space.
        IF su_waers = space.
          su_waers = bzt-waers.
          betb-rewae = bzt-waers.
        ENDIF.
      ENDIF.
      IF bzt-shkzg = 'H'.
        betb-frrmg = betb-frrmg - bzt-menge.
        betb-bpfrr = betb-bpfrr - bzt-bpmng.
        betb-frrwr = betb-frrwr - bzt-dmbtr.
        betb-frawe = betb-frawe - bzt-arewr.
        IF su_fwknz NE space.
          IF su_waers = bzt-waers.
            IF su_arekz NE space.
              betb-fraww = betb-fraww - bzt-areww.
            ELSE.
              CLEAR betb-fraww.
            ENDIF.
            betb-frrfr = betb-frrfr - bzt-wrbtr.
          ENDIF.
        ENDIF.
      ELSE.
        betb-frrmg = betb-frrmg + bzt-menge.
        betb-bpfrr = betb-bpfrr + bzt-bpmng.
        betb-frrwr = betb-frrwr + bzt-dmbtr.
        betb-frawe = betb-frawe + bzt-arewr.
        IF su_fwknz NE space.
          IF su_waers = bzt-waers.
            IF su_arekz NE space.
              betb-fraww = betb-fraww + bzt-areww.
            ELSE.
              CLEAR betb-fraww.
            ENDIF.
            betb-frrfr = betb-frrfr + bzt-wrbtr.
          ENDIF.
        ENDIF.
      ENDIF.
      IF su_waers NE bzt-waers AND su_fwknz NE space.
        CLEAR: betb-fraww, betb-frrfr.
        CLEAR: su_fwknz.
      ENDIF.
*------- Frachtnachbelastung ---- (nur Werte) --------------------------
    WHEN '3'.                                               "3.1G
      SELECT SINGLE * FROM t163b WHERE bewtp = bzt-bewtp.   "3.1G
      CHECK sy-subrc EQ 0.                                  "3.1G
      CHECK t163b-tbtkz NE space.                           "3.1G
      IF NOT bzt-arewr IS INITIAL AND bzt-areww IS INITIAL.
*     alte EKBZ-S?ze haben den AREWW noch nicht -->
*     errechnen aus Verh?tnis Betrag Haus-/Fremdw?rung
        IF bzt-dmbtr EQ 0.                                  "tk 4.6a2
          CLEAR su_arekz.              "tk 4.6a2        "tk 4.6a
        ELSE.                                               "tk 4.6a2
          refe1 = bzt-arewr * bzt-wrbtr / bzt-dmbtr.        "tk 4.6a
*         IF refe1 GT maxwert.         "tk 4.6a
          refe1abs = ABS( refe1 ).
          IF refe1abs GT maxwert.
            CLEAR su_arekz.                                 "tk 4.6a
          ELSE.                                             "tk 4.6a
            bzt-areww = refe1.                              "tk 4.6a
          ENDIF.                                            "tk 4.6a
        ENDIF.                                              "tk 4.6a2
      ENDIF.
      IF su_fwknz NE space.
        IF su_waers = space.
          su_waers = bzt-waers.
          betb-rewae = bzt-waers.
        ENDIF.
      ENDIF.
      IF bzt-shkzg = 'H'.                                   "3.1G
        betb-frrwr = betb-frrwr - bzt-dmbtr.                "3.1G
        betb-frawe = betb-frawe - bzt-arewr.                "3.1G
        IF su_fwknz NE space.
          IF su_waers = bzt-waers.
            IF su_arekz NE space.
              betb-fraww = betb-fraww - bzt-areww.
            ELSE.
              CLEAR betb-fraww.
            ENDIF.
            betb-frrfr = betb-frrfr - bzt-wrbtr.
          ENDIF.
        ENDIF.
      ELSE.                                                 "3.1G
        betb-frrwr = betb-frrwr + bzt-dmbtr.                "3.1G
        betb-frawe = betb-frawe + bzt-arewr.                "3.1G
        IF su_fwknz NE space.
          IF su_waers = bzt-waers.
            IF su_arekz NE space.
              betb-fraww = betb-fraww + bzt-areww.
            ELSE.
              CLEAR betb-fraww.
            ENDIF.
            betb-frrfr = betb-frrfr + bzt-wrbtr.
          ENDIF.
        ENDIF.
      ENDIF.                                                "3.1G
      IF su_waers NE bzt-waers AND su_fwknz NE space.
        CLEAR: betb-fraww, betb-frrfr.
        CLEAR: su_fwknz.
      ENDIF.
*-------Vorerfasste Bezugsnebenkosten-----------------------------------
    WHEN 'P'.                                               "435593
      betb-predc = 'X'.

  ENDCASE.

  IF bzt-bpmng IS INITIAL.
* WE kann nicht mit Menge in Bestellpreis-ME rechnen, da schon
* Vorg?ge (WE/RE) ohne Menge in Bestellpreis-ME gebucht sind
    CLEAR betb-xbprm.
  ENDIF.
  PERFORM bzt_analyse_cr.                                   "K003063

ENDFORM.                    "bzt_analyse

*---------------------------------------------------------------"K003063
* Parallele W?rungen:                                                 *
* Tabelle BZT analysieren f? Aufbau von BETB_WA                       *
*----------------------------------------------------------------------*
FORM bzt_analyse_cr.

* Mu?f? die Bestellposition etwas getan werden?           "Note 320280
  PERFORM ml_waers_info_lesen.                              "Note 320280
  CHECK gd_ipot_info-ekbz_kz NE space.                      "Note 320280

* Bereitstellen der CR-S?ze
  PERFORM bzt_wa_lesen.

  CASE bzt-vgabe.
*------- Frachtrueckstellung -------------------------------------------
    WHEN '1'.
      IF bzt-shkzg = 'S'.
        CASE betb-bewtp.
          WHEN 'F'.
            PERFORM sub_from USING:
*           W1 = W1 - W2
            betb_wa-frwwr bzt_wa-dmbtr.
          WHEN 'B'.
            PERFORM sub_from USING:
*           W1 = W1 - W2
            betb_wa-nawwr bzt_wa-dmbtr.
          WHEN 'C'.
            PERFORM sub_from USING:
*           W1 = W1 - W2
            betb_wa-fnwwr bzt_wa-dmbtr.
        ENDCASE.
      ELSE.
        CASE betb-bewtp.
          WHEN 'F'.
            PERFORM add_to USING:
*           W1 = W1 + W2
            betb_wa-frwwr bzt_wa-dmbtr.
          WHEN 'B'.
            PERFORM add_to USING:
*           W1 = W1 + W2
            betb_wa-nawwr bzt_wa-dmbtr.
          WHEN 'C'.
            PERFORM add_to USING:
*           W1 = W1 + W2
            betb_wa-fnwwr bzt_wa-dmbtr.
        ENDCASE.
      ENDIF.
*------- Frachtrechnung -----------------------------------------------
    WHEN '2'.
      IF bzt-shkzg = 'H'.
        PERFORM sub_from USING:
*       W1 = W1 - W2
        betb_wa-frrwr bzt_wa-dmbtr,
        betb_wa-frawe bzt_wa-arewr.
      ELSE.
        PERFORM add_to USING:
*       W1 = W1 + W2
        betb_wa-frrwr bzt_wa-dmbtr,
        betb_wa-frawe bzt_wa-arewr.
      ENDIF.
*------- Frachtnachbelastung ---- (nur Werte) ------------------------
    WHEN '3'.
      SELECT SINGLE * FROM t163b WHERE bewtp = bzt-bewtp.
      CHECK sy-subrc EQ 0.
      CHECK t163b-tbtkz NE space.
      IF bzt-shkzg = 'H'.
        PERFORM sub_from USING:
*       W1 = W1 - W2
        betb_wa-frrwr bzt_wa-dmbtr,
        betb_wa-frawe bzt_wa-arewr.
      ELSE.
        PERFORM add_to USING:
*       W1 = W1 + W2
        betb_wa-frrwr bzt_wa-dmbtr,
        betb_wa-frawe bzt_wa-arewr.
      ENDIF.
  ENDCASE.
ENDFORM.                    "BZT_ANALYSE_CR

*&--------------------------------------------------------------------*
*&      Form  BZT_FUELLEN
*&--------------------------------------------------------------------*
*       text
*---------------------------------------------------------------------*
*      -->P_BYPASSINGtextFER
*      -->P_REFRESH_BtextR
*---------------------------------------------------------------------*
FORM bzt_fuellen USING p_bypassing_buffer                   "359665
                       p_refresh_buffer.                    "359665

  CALL FUNCTION 'MMPUR_EKBZ_READ_EBELN_EBELP'
    EXPORTING
      pi_ebeln             = ekko-ebeln
      pi_ebelp             = ebelp
      pi_bypassing_buffer  = p_bypassing_buffer             "359665
      pi_refresh_buffer    = p_refresh_buffer               "359665
    TABLES
      pto_ekbz_po          = bzt
    EXCEPTIONS
      no_records_requested = 1
      OTHERS               = 2.
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

*> ADD KSB
  DELETE bzt WHERE NOT budat IN r_budat.

  SORT bzt BY ebelp stunr zaehk vgabe gjahr belnr buzei.

ENDFORM.                    "BZT_FUELLEN

*----------------------------------------------------------------------*
*       FORM BZT_WA_AUFBAUEN
*----------------------------------------------------------------------*
*       Parallel zur BZT wird die BZT_WA Tabelle erzeugt. Falls zu
*       einem BZT-Eintrag Zusatzw?rungen im Materialledger aufgebaut
*       worden sind, wird ein BET_WA Eintrag erzeugt.
*       Falls f? die betreffende Bestellposition keine Zusatzw?rungen
*       existieren, so wird das in der globalen Tabelle IPOT_TBL
*       vermerkt.
*----------------------------------------------------------------------*
*  -->  V_BELN    Bestellnummer
*  -->  V_BELP    Bestellposition
*  -->  BZT       Interne Tabelle mit der Bestellhistorie
*  <--  BZT_WA    Zugeh?ige W?rungsfelder
*----------------------------------------------------------------------*
FORM bzt_wa_aufbauen USING
       value(v_beln) LIKE bet-ebeln                         "K074433
       value(v_belp) LIKE bet-ebelp.

  DATA:
    ld_bzt_key        LIKE bzti_key,
    ld_bzt_key_save   LIKE bzti_key,
    ld_found          LIKE boole-boole,
    ld_ekbe_all_tbl   TYPE ty_ekbe_cr_tbl
                      WITH HEADER LINE,
    ld_ekbz_all_tbl   TYPE ty_ekbz_cr_tbl
                      WITH HEADER LINE,
    ld_ekbz_ezl_tbl   TYPE ty_ekbz_cr_tbl,
    ld_tabix          LIKE sy-tabix,
    ld_subrc          LIKE sy-subrc,
    ld_bnk            LIKE boole-boole,
    ld_ipot_tabix     LIKE sy-tabix,
    ld_bzt_save       LIKE bzt.

* Nur aufbauen, wenn Mlcur aktiviert ist
  CHECK gd_mlwere-aktiv EQ 'X'.

* Pr?en, ob richtige Bestellposition
  PERFORM ml_pot_pruefen USING
            v_beln                                          "K074433
            v_belp.

* Pr?en, ob Tabelle bereits erzeugt worden ist
  PERFORM ml_aktiv_pruefen USING
            pot-ebeln
            pot-ebelp.
  IF gd_ipot_tbl-ekbz_pr_kz EQ 'X'.
    bzt_wa[] = gd_ipot_tbl-ibzt_wa[].
    EXIT.
  ENDIF.

* Tabelle mu?neu aufgebaut werden
  CLEAR bzt_wa[].
  ld_bnk = 'X'.
  CALL FUNCTION 'CKMW_READ_PO_HISTORY'
       EXPORTING
            ebeln              = pot-ebeln
            ebelp              = pot-ebelp
            bnk                = ld_bnk
*           no_curtp_00        = gd_mlwere-no_00_ml  "(del)RH P40K036986
*           no_curtp_10        = gd_mlwere-no_10_ml  "(del)RH P40K036986
            no_curtp_00        = gd_mlwere-no_00_ml-boole "RH P40K036986
            no_curtp_10        = gd_mlwere-no_10_ml-boole "RH P40K036986
       TABLES
            t_ekbe_cr          = ld_ekbe_all_tbl[]
            t_ekbz_cr          = ld_ekbz_all_tbl[]
       EXCEPTIONS
            data_not_found     = 0
            OTHERS             = 1.
  PERFORM breakrc USING 'L009'.

* Abarbeiten jeden BZT-Eintrag f? die ?ergebene Bestellposition
  SORT ld_ekbz_all_tbl
       BY stunr zaehk vgabe gjahr belnr buzei.
  ld_bzt_save = bzt.
  LOOP AT bzt WHERE
          ebeln EQ pot-ebeln AND
          ebelp EQ pot-ebelp.

*   Initialisierungen
    CLEAR ld_found.
    CLEAR bzt_wa.
    MOVE-CORRESPONDING bzt TO ld_bzt_key.
    bzt_wa-key = ld_bzt_key.

*   Lesen aller CR-Eintr?e zum BZT-Eintrag
    CLEAR ld_ekbz_ezl_tbl.
    READ TABLE ld_ekbz_all_tbl
      WITH KEY
      stunr = bzt-stunr
      zaehk = bzt-zaehk
      vgabe = bzt-vgabe
      gjahr = bzt-gjahr
      belnr = bzt-belnr
      buzei = bzt-buzei
      BINARY SEARCH.
    IF sy-subrc EQ 0.
      ld_tabix = sy-tabix.
      ld_found = 'X'.
      APPEND ld_ekbz_all_tbl TO ld_ekbz_ezl_tbl.
      DO.
        ADD 1 TO ld_tabix.
        READ TABLE ld_ekbz_all_tbl INDEX ld_tabix.
        IF sy-subrc NE 0.
          EXIT.
        ENDIF.
        MOVE-CORRESPONDING ld_ekbz_all_tbl TO ld_bzt_key_save.
        IF ld_bzt_key NE ld_bzt_key_save.
          EXIT.
        ENDIF.
        APPEND ld_ekbz_all_tbl TO ld_ekbz_ezl_tbl.
      ENDDO.

*   Konsistenz-Pr?ung: Mlbecr-Satz mu?existieren
    ELSE.
      PERFORM mlbecr_konsistenz_pruefen USING
                 ld_bnk         "Kz: EKBZ
                 bzt-vgabe      "Vorgangsart
                 pot-ebeln      "Bestellnummer
                 pot-ebelp.     "Bestellposition
    ENDIF.

*   Zugeh?ige EKBZ_CR-S?ze in die BZT_WA
    IF ld_found NE space.
      PERFORM bzt_wa_eintrag_bereiten USING
                bzt_wa
                ld_ekbz_ezl_tbl.
      APPEND bzt_wa.
    ENDIF.
  ENDLOOP.
  SORT bzt_wa BY key.

* Merken der Tabelle in der globalen InfoStruktur
  READ TABLE gd_ipot_tbl WITH KEY
       ebeln = pot-ebeln
       ebelp = pot-ebelp
       BINARY SEARCH.
  ld_subrc = sy-subrc.
  ld_tabix = sy-tabix.

* Initialisieren, falls Eintrag neu
  IF ld_subrc NE 0.
    CLEAR gd_ipot_tbl.
    gd_ipot_tbl-ebeln = pot-ebeln.
    gd_ipot_tbl-ebelp = pot-ebelp.
  ENDIF.

* Vermerken, da?BZT_WA aufgebaut ist
  gd_ipot_tbl-ekbz_pr_kz = 'X'.
  DESCRIBE TABLE bzt_wa LINES sy-tfill.
  IF sy-tfill GT 0.
    gd_ipot_tbl-ekbz_wa_kz = 'X'.
  ELSE.
    gd_ipot_tbl-ekbz_wa_kz = space.
  ENDIF.
  gd_ipot_tbl-ibzt_wa[] = bzt_wa[].
  IF ld_subrc EQ 0.
    MODIFY gd_ipot_tbl INDEX ld_tabix.
  ELSE.
    INSERT gd_ipot_tbl INDEX ld_tabix.
  ENDIF.

* Zur?ksetzen der globalen Info-Struktur, damit diese gegebenenfalls
* wieder aktualisiert wird.
  CLEAR gd_ipot_info.

* Wiederherstellen des alten BZT-Eintrags
  bzt = ld_bzt_save.
ENDFORM.                    "BZT_WA_AUFBAUEN

*----------------------------------------------------------------------*
*       FORM BZT_WA_EINTRAG_BEREITEN
*----------------------------------------------------------------------*
*  -->  R_BZT_WA
*  -->  R_EKBZ_CR_EZL
*----------------------------------------------------------------------*
FORM bzt_wa_eintrag_bereiten USING
       r_bzt_wa              TYPE ty_bzt_wa
       r_ekbz_cr_ezl_tbl     TYPE ty_ekbz_cr_tbl.

  DATA:
    ld_ekbz_cr       TYPE LINE OF ty_ekbz_cr_tbl,
    ld_dmbtr         TYPE mlcr_curr,
    ld_arewr         TYPE mlcr_curr,
    ld_reewr         TYPE mlcr_curr.

* W?rungsvektoren aufbauen
  LOOP AT r_ekbz_cr_ezl_tbl INTO ld_ekbz_cr.

*   W?rungstypen
    ld_dmbtr-curtp     = ld_ekbz_cr-curtp.
    ld_reewr-curtp     = ld_ekbz_cr-curtp.
    ld_arewr-curtp     = ld_ekbz_cr-curtp.

*   W?rungsschl?sel
    ld_dmbtr-waers     = ld_ekbz_cr-waers.
    ld_reewr-waers     = ld_ekbz_cr-waers.
    ld_arewr-waers     = ld_ekbz_cr-waers.

*   Werte
    ld_dmbtr-wert      = ld_ekbz_cr-wrbtr.
    ld_reewr-wert      = ld_ekbz_cr-reewr.
    ld_arewr-wert      = ld_ekbz_cr-arewr.

*   Hinzuf?en
    APPEND ld_dmbtr TO r_bzt_wa-dmbtr.
    APPEND ld_reewr TO r_bzt_wa-reewr.
    APPEND ld_arewr TO r_bzt_wa-arewr.
  ENDLOOP.

* 10-er W?rung erzeugen
  PERFORM ml_10_werte_bzt_wa_ergaenzen CHANGING
            r_bzt_wa.

* Sortieren nach W?rungstyp
  SORT r_bzt_wa-dmbtr BY curtp.
  SORT r_bzt_wa-reewr BY curtp.
  SORT r_bzt_wa-arewr BY curtp.
ENDFORM.                    "BZT_WA_EINTRAG_BEREITEN

*----------------------------------------------------------------------*
*       FORM BZT_WA_LESEN
*----------------------------------------------------------------------*
*       Der zum BZT geh?ige CR-Eintrag wird eingelesen
*----------------------------------------------------------------------*
*  -->  BZT
*  <--  BZT_WA
*----------------------------------------------------------------------*
FORM bzt_wa_lesen.

  DATA:
    ld_key     LIKE bzti_key.

* ML-W?rungen pr?en f? EKBZ
  PERFORM ml_waers_info_lesen.
  CHECK gd_ipot_info-ekbz_kz NE space.

* Eintrag lesen
  MOVE-CORRESPONDING bzt TO ld_key.
  READ TABLE bzt_wa WITH KEY
             key = ld_key BINARY SEARCH.
  IF sy-subrc NE 0.
    IF gd_mlwere-null_bxt IS INITIAL.
      CLEAR bzt_wa.
      bzt_wa-key = ld_key.
    ELSE.
      PERFORM breakrc USING 'L007'.
    ENDIF.
  ENDIF.
ENDFORM.                    "BZT_WA_LESEN

*----------------------------------------------------------------------*
*       FORM COLLECT_BETS_WA
*----------------------------------------------------------------------*
*       Aufruf erfolgt nur nach dem manuellen Collect der BETS
*       in BET_SUMMEN. Es werden alle Kontierungspositionen zu einer
*       Bestellposition unter der ZEKKN = 0 verdichtet.
*       Der BETS-Eintrag ist bereits auf die ZEKKN = 0 eingestellt.
*----------------------------------------------------------------------*
*  -->  BETS
*  -->  BETS_WA
*----------------------------------------------------------------------*
FORM collect_bets_wa.

  DATA:
    ld_subrc     LIKE sy-subrc,
    ld_tabix     LIKE sy-tabix,
    ld_betskey   LIKE betskey,
    ld_bets_wa   LIKE bets_wa.

* ML-W?rungen pr?en f? EKBE
  PERFORM ml_waers_info_lesen.
  CHECK gd_ipot_info-ekbe_kz NE space.

* Schl?sel versorgen (ZEKKN = 0)
  MOVE-CORRESPONDING bets TO ld_betskey.
  bets_wa-key = ld_betskey.
  MOVE bets_wa TO ld_bets_wa.

* Kollektieren
  READ TABLE bets_wa WITH KEY key = ld_betskey BINARY SEARCH.
  ld_subrc = sy-subrc.
  ld_tabix = sy-tabix.
  IF ld_subrc EQ 0.
    PERFORM add_to USING:
*   W1 = W1 + W2
    bets_wa-wewrt   ld_bets_wa-wewrt,
    bets_wa-rewrt   ld_bets_wa-rewrt,
    bets_wa-arewr   ld_bets_wa-arewr,
    bets_wa-anzal   ld_bets_wa-anzal,
    bets_wa-reewr   ld_bets_wa-reewr.
    MODIFY bets_wa INDEX ld_tabix.
  ELSE.
    bets_wa = ld_bets_wa.
    INSERT bets_wa INDEX ld_tabix.
  ENDIF.
ENDFORM.                    "COLLECT_BETS_WA

*----------------------------------------------------------------------*
*       FORM MLBECR_KONSISTENZ_PRUEFEN
*----------------------------------------------------------------------*
*       Mlbecr-Eintrag fehlt zu einem Eintrag aus Ekbe bzw. Ekbz.
*       Wenn Inkonsistenz  ==>  Fehlermeldung
*----------------------------------------------------------------------*
*  -->  V_FLG_EKBZ       Bezugsnebenkosten-Datei
*  -->  V_VGABE          Vorgangsart
*  -->  V_EBELN          Bestellnummer
*  -->  V_EBELP          Bestellposition
*----------------------------------------------------------------------*
FORM mlbecr_konsistenz_pruefen USING
       value(v_flg_ekbz)    LIKE boole-boole
       value(v_vgabe)       LIKE ekbe-vgabe
       value(v_ebeln)       LIKE pot-ebeln
       value(v_ebelp)       LIKE pot-ebelp.

************************************************************************
* Keine Konsistenzpr?ung bei:
* WE Unbewertet (gesamte Bestellposition)
* Wertbuchung offen (bei WE)
* WE-Menge unbewertet (zum Beispiel WE an Sperrbestand)
* WE-Wert unbewertet (z.B. WE zu Umlagerbestellung mit 351/101)
* Konsi-Bestellung
* sowie bei folgenden Vorgangsarten:
* ' ': Initialer BZT-Satz (nur bei Bezugsnebenkosten)
* 4  : Anzahlung
* 5  : Zahlung
* 6  : Warenausgabe f? Umlagerung
* 8  : Lieferung zu Umlagerung
* 9  : Leistungsvorerfassung
************************************************************************
  CHECK pot-weunb IS INITIAL.                               "K052263
  CHECK bet-xwoff IS INITIAL.
  CHECK NOT ( v_flg_ekbz EQ space AND bet-menge EQ 0 ).     "K052263
  CHECK NOT ( v_flg_ekbz EQ space AND bet-dmbtr EQ 0 AND
                                      bet-wrbtr EQ 0 AND    "note 376898
                                      bet-arewr EQ 0 AND    "note 376898
                                      bet-areww EQ 0 ).     "note 376898
  CHECK pot-pstyp NE pstyp-kons.
  CHECK NOT ( v_flg_ekbz NE space AND v_vgabe EQ space ).
  CHECK v_vgabe CN '456789PQR'.
  CHECK gd_mlwere-aktiv NE space.
  CHECK gd_namen CS sy-uname OR
        gd_flg_name_all NE space.

* Fehlermeldung bei EKBE
  IF v_flg_ekbz EQ space.
    MESSAGE e507(c+) WITH v_vgabe v_ebeln v_ebelp.
  ELSE.
    MESSAGE e508(c+) WITH v_vgabe v_ebeln v_ebelp.
  ENDIF.
ENDFORM.                    "MLBECR_KONSISTENZ_PRUEFEN

*----------------------------------------------------------------------*
*       FORM ML_10_WERTE_BZT_WA_ERGAENZEN
*----------------------------------------------------------------------*
*       Die 10-er W?rungen werden in die BZT_WA f? Konsistenzcheks
*       hinzugef?t.
*----------------------------------------------------------------------*
*  -->  R_BZT_WA
*----------------------------------------------------------------------*
FORM ml_10_werte_bzt_wa_ergaenzen CHANGING
       r_bzt_wa  TYPE ty_bzt_wa.

  DATA:
    ld_dmbtr         TYPE mlcr_curr,
    ld_arewr         TYPE mlcr_curr,
    ld_reewr         TYPE mlcr_curr,
    ld_waers         TYPE mlcr_curr-waers.

* Nur prozessieren, falls Schalter sitzt
  CHECK gd_mlwere-no_10_db NE space.

* Holen der Buchungskreisw?rung
  PERFORM bukrs_waers_holen USING
            bzt-ebeln
          CHANGING
            ld_waers.

* W?rungstypen
  ld_dmbtr-curtp     = '10'.
  ld_reewr-curtp     = '10'.
  ld_arewr-curtp     = '10'.

* W?rungsschl?sel
  ld_dmbtr-waers     = ld_waers.
  ld_reewr-waers     = ld_waers.
  ld_arewr-waers     = ld_waers.

* Werte
  ld_dmbtr-wert      = bzt-dmbtr.
  ld_reewr-wert      = bzt-reewr.
  ld_arewr-wert      = bzt-arewr.

* Hinzuf?en
  APPEND ld_dmbtr TO r_bzt_wa-dmbtr.
  APPEND ld_reewr TO r_bzt_wa-reewr.
  APPEND ld_arewr TO r_bzt_wa-arewr.
ENDFORM.                    "ML_10_WERTE_BZT_WA_ERGAENZEN


*----------------------------------------------------------------------*
*       FORM BUKRS_WAERS_HOLEN
*----------------------------------------------------------------------*
*       Buchungskreisw?rung holen
*----------------------------------------------------------------------*
*  -->  V_EBELN    Bestellnummer
*  <--  V_WAERS    Buchungskreis-W?rung
*----------------------------------------------------------------------*
FORM bukrs_waers_holen USING
       value(v_ebeln)    LIKE ekpo-ebeln
     CHANGING
       value(v_waers)    LIKE t001-waers.

  STATICS:
    BEGIN OF st_bw,
      ebeln     LIKE ekpo-ebeln,
      bukrs     LIKE t001-bukrs,
      bwaers    LIKE t001-waers,
    END OF st_bw.

* Buchungskreisw?rung der Bestellung ist bereits gesetzt
  IF st_bw-ebeln EQ v_ebeln AND
     NOT st_bw IS INITIAL.
    v_waers = st_bw-bwaers.
    EXIT.
  ENDIF.

* Buchungskreisw?rung mu?neu ermittelt werden
  st_bw-ebeln = v_ebeln.
  IF ekko-ebeln NE st_bw-ebeln.
    SELECT SINGLE bukrs INTO st_bw-bukrs
           FROM ekko
           WHERE ebeln EQ v_ebeln.
    PERFORM breakrc USING 'L031'.
  ELSE.
    st_bw-bukrs = ekko-bukrs.
  ENDIF.
  SELECT SINGLE waers INTO st_bw-bwaers
         FROM t001
         WHERE bukrs EQ st_bw-bukrs.
  PERFORM breakrc USING 'L032'.
  v_waers = st_bw-bwaers.
ENDFORM.                    "BUKRS_WAERS_HOLEN


*----------------------------------------------------------------------*
*       FORM ML_AKTIV_PRUEFEN
*----------------------------------------------------------------------*
*       Routine darf erst zum Zeitpunkt BET_WA_AUFBAUEN oder
*       BZT_WA_AUFBAUEN oder sp?er aufgerufen werden, da die interne
*       POT-Tabelle aufgebaut sein mu?
*-----------------------------------------------------------------------
*       Es wird gepr?t, ob f? das Material in der Bestellposition das
*       Materialledger aktiv ist bzw. ob im Material-Ledger mehr als
*       eine W?rung eingestellt ist (und deshalb in den
*       ML-Bestellhistorientabellen Eintr?e vorhanden sein m?sen).
*       Das Resultat wird in dem Buffer GD_IPOT_TBL festgehalten.
*----------------------------------------------------------------------*
*  -->  V_EBELN      Bestellnummer
*  -->  V_EBELP      Bestellposition
*  <--  GD_IPOT_TBL  Eintrag, der Infos zur BestellPos beschreibt
*----------------------------------------------------------------------*
FORM ml_aktiv_pruefen USING
       value(v_ebeln)    LIKE ekpo-ebeln
       value(v_ebelp)    LIKE ekpo-ebelp.

  DATA:
    ld_pot    LIKE pot,
    ld_tabix  LIKE sy-tabix,
    ld_subrc  LIKE sy-subrc,
    ld_curtp  TYPE cki_ml_cty OCCURS 0 WITH HEADER LINE,
    no_further_currencies.

* Pr?en, ob Postion bereits ?erpr?t wurde
  READ TABLE gd_ipot_tbl WITH KEY
       ebeln = v_ebeln
       ebelp = v_ebelp
       BINARY SEARCH.
  ld_subrc = sy-subrc.
  ld_tabix = sy-tabix.
  CHECK ld_subrc NE 0.

* Holen Bestellposition aus der internen Buffer-Tabelle
  LOOP AT pot INTO ld_pot
       WHERE ebeln EQ v_ebeln
       AND   ebelp EQ v_ebelp.
    EXIT.
  ENDLOOP.

* Holen Bestellposition aus Workarea
  IF sy-subrc NE 0 AND
     pot-ebeln EQ v_ebeln AND
     pot-ebelp EQ v_ebelp.
    ld_pot = pot.

* Keine Bestellposition ermittelbar
  ELSEIF sy-subrc NE 0.
    PERFORM breakrc USING 'L030'.
  ENDIF.

* Ergebnis in Buffer-Tabelle merken
  CLEAR gd_ipot_tbl.
  gd_ipot_tbl-ebeln = v_ebeln.
  gd_ipot_tbl-ebelp = v_ebelp.
  gd_ipot_tbl-aktiv = ld_pot-mlmaa.

* Falls ML aktiv, W?rungsinformationen holen
* MLMAA ist kein ausreichendes Kriterium: bei kontierten Bestellungen
* mit Material wird es in der Bestandsf?rung nicht gelesen, und bei
* kontierten Bestellungen ohne Materialnummer fehlt es ganz.
* Also: Bestellhistorie immer aktiv, sobald Bewertungskreis ML-aktiv.
* if ld_pot-mlmaa eq 'X'.
*   Bewertungskreis ermitteln
  SELECT SINGLE * FROM t001w
    WHERE werks = ld_pot-werks.
  IF sy-subrc NE 0 AND ld_pot-werks IS INITIAL.           "note 393503
    CLEAR t001w.                                          "note 393503
  ELSEIF sy-subrc NE 0.                                   "note 393503
    PERFORM breakrc USING 'L040'.
  ENDIF.
*   W?rungsinfo zum Bewertungskreis
  REFRESH ld_curtp.
  CALL FUNCTION 'GET_BWKEY_CURRENCY_INFO'
    EXPORTING
      bwkey             = t001w-bwkey
    TABLES
      t_curtp_for_va    = ld_curtp
    EXCEPTIONS
      bwkey_not_found   = 1
      bwkey_not_active  = 2
      matled_not_found  = 3
      internal_error    = 4
      more_than_3_curtp = 5
      OTHERS            = 6.
  IF sy-subrc <> 0.
    IF ld_pot-mlmaa EQ 'X'.
*     Call function again to get apropriate error message
      CALL FUNCTION 'GET_BWKEY_CURRENCY_INFO'
        EXPORTING
          bwkey          = t001w-bwkey
        TABLES
          t_curtp_for_va = ld_curtp.
    ENDIF.
  ELSE.
*     ML active in Valuation Area
    ld_pot-mlmaa = 'X'.
    gd_ipot_tbl-aktiv = ld_pot-mlmaa.
  ENDIF.
*   Nachschauen, ob nur die Buchungskreisw?rung existiert
  CLEAR: no_further_currencies.
  LOOP AT ld_curtp WHERE curtp NE '10'.
    EXIT.
  ENDLOOP.
  IF sy-subrc NE 0.
    no_further_currencies = 'X'.
  ENDIF.
* endif.

* Falls ML nicht aktiv oder nur Hausw?rung eingestellt ist
* k?nen bereits Restdaten gesetzt werden
  IF  ld_pot-mlmaa EQ space OR
      no_further_currencies EQ 'X'.
    gd_ipot_tbl-ekbe_pr_kz = 'X'.
    gd_ipot_tbl-ekbe_wa_kz = space.
    gd_ipot_tbl-ekbz_pr_kz = 'X'.
    gd_ipot_tbl-ekbz_wa_kz = space.
  ENDIF.

* Eintrag hinzuf?en
  INSERT gd_ipot_tbl INDEX ld_tabix.
ENDFORM.                    "ml_aktiv_pruefen

*       FORM ML_CURR_PRUEFEN
*----------------------------------------------------------------------*
*       Pr?en, ob zwei W?rungen kompatibel sind.
*----------------------------------------------------------------------*
*  -->  V_CURR1      W?rung-1
*  -->  V_CURR2      W?rung-2
*----------------------------------------------------------------------*
FORM ml_curr_pruefen USING
       value(v_curr1)   TYPE mlcr_curr
       value(v_curr2)   TYPE mlcr_curr.

  IF v_curr1-curtp NE v_curr2-curtp OR
     v_curr1-waers NE v_curr2-waers.
    sy-subrc = 1.
    PERFORM breakrc USING 'L037'.
  ENDIF.
ENDFORM.                    "ML_CURR_PRUEFEN

*----------------------------------------------------------------K074433
*       FORM ML_POT_PRUEFEN
*----------------------------------------------------------------------*
*       Pr?en, ob die richtige Bestellposition in der POT-Workarea
*       steht. Wenn nicht, wird die Position in die POT eingelesen.
*----------------------------------------------------------------------*
*  -->  V_BELN    Bestellnummer
*  -->  V_BELP    Bestellposition
*  <--  POT       Workarea f? die Bestellposition
*----------------------------------------------------------------------*
FORM ml_pot_pruefen USING
       value(v_beln) LIKE bet-ebeln
       value(v_belp) LIKE bet-ebelp.

  DATA:
    ld_ekpo    LIKE ekpo.

* Pr?en, ob richtige Bestellposition, gebenenfalls neue EKPO lesen
  IF pot-ebeln NE v_beln OR
     pot-ebelp NE v_belp.

*   Lesen aus der internen Pot
    READ TABLE pot WITH KEY
         ebeln = v_beln
         ebelp = v_belp.

*   Lesen von der Datenbank
    IF sy-subrc NE 0.
      CALL FUNCTION 'ME_EKPO_SINGLE_READ'
        EXPORTING
          pi_ebeln         = v_beln
          pi_ebelp         = v_belp
        IMPORTING
          po_ekpo          = ld_ekpo
        EXCEPTIONS
          no_records_found = 1
          OTHERS           = 2.
      PERFORM breakrc USING 'L038'.
      MOVE-CORRESPONDING ld_ekpo TO pot.
    ENDIF.
  ENDIF.
ENDFORM.                    "ML_POT_PRUEFEN

*----------------------------------------------------------------------*
*       FORM SUB_FROM
*----------------------------------------------------------------------*
*       Differenz zweier Werte (parallele W?rungen)
*       A-Wert =  A-Wert - B-Wert
*----------------------------------------------------------------------*
*  -->  R_AWERT     Wert-1
*  -->  R_BWERT     Wert-2
*----------------------------------------------------------------------*
FORM sub_from USING
       r_awert TYPE mlcr_curr_tbl
       r_bwert TYPE mlcr_curr_tbl.

  DATA:
    ld_a LIKE LINE OF r_awert,
    ld_b LIKE LINE OF r_bwert.

* Nicht bearbeiten bei initialen Werten
  CHECK NOT r_awert IS INITIAL OR
        NOT r_bwert IS INITIAL.

* W?rungsvektoren angleichen
  PERFORM curr_angleichen USING
       r_awert
       r_bwert.

* A-Wert = A-Wert - B-Wert
  LOOP AT r_awert INTO ld_a.
    READ TABLE r_bwert INTO ld_b INDEX sy-tabix.
    PERFORM ml_curr_pruefen USING ld_a ld_b.
    ld_a-wert = ld_a-wert - ld_b-wert.
    MODIFY r_awert FROM ld_a.
  ENDLOOP.
ENDFORM.                    "SUB_FROM

*----------------------------------------------------------------------*
*       FORM BET_WA_AUFBAUEN
*----------------------------------------------------------------------*
*       Parallel zur BET wird die BET_WA Tabelle erzeugt. Falls zu
*       einem BET-Eintrag Zusatzw?rungen im Materialledger aufgebaut
*       worden sind, wird ein BET_WA Eintrag erzeugt.
*       Falls f? die betreffende Bestellposition keine Zusatzw?rungen
*       existieren, so wird das in der globalen Tabelle IPOT_TBL
*       vermerkt.
*----------------------------------------------------------------------*
*  -->  V_BELN    Bestellnummer
*  -->  V_BELP    Bestellposition
*  -->  BET       Interne Tabelle mit der Bestellhistorie
*  <--  BET_WA    Zugeh?ige W?rungsfelder
*----------------------------------------------------------------------*
FORM bet_wa_aufbauen USING
       value(v_beln) LIKE bet-ebeln                         "K074433
       value(v_belp) LIKE bet-ebelp.


  DATA:
    ld_bet_key        LIKE betkey,
    ld_bet_key_save   LIKE betkey,
    ld_found          LIKE boole-boole,
    ld_ekbe_all_tbl   TYPE ty_ekbe_cr_tbl
                      WITH HEADER LINE,
    ld_ekbz_all_tbl   TYPE ty_ekbz_cr_tbl
                      WITH HEADER LINE,
    ld_ekbe_ezl_tbl   TYPE ty_ekbe_cr_tbl,
    ld_tabix          LIKE sy-tabix,
    ld_subrc          LIKE sy-subrc,
    ld_bnk            LIKE boole-boole,
    ld_ipot_tabix     LIKE sy-tabix,
    ld_bet_save       LIKE bet.

* Nur aufbauen, wenn Mlcur aktiviert ist
  CHECK gd_mlwere-aktiv EQ 'X'.

* Pr?en, ob richtige Bestellposition
  PERFORM ml_pot_pruefen USING
            v_beln                                          "K074433
            v_belp.

* Pr?en, ob Tabelle bereits erzeugt worden ist
  PERFORM ml_aktiv_pruefen USING
            pot-ebeln
            pot-ebelp.
  IF gd_ipot_tbl-ekbe_pr_kz EQ 'X'.
    bet_wa[] = gd_ipot_tbl-ibet_wa[].
    EXIT.
  ENDIF.

* Tabelle mu?neu aufgebaut werden
  CLEAR bet_wa[].
  CLEAR ld_bnk.
  CALL FUNCTION 'CKMW_READ_PO_HISTORY'
       EXPORTING
            ebeln              = pot-ebeln
            ebelp              = pot-ebelp
            bnk                = ld_bnk
*           no_curtp_00        = gd_mlwere-no_00_ml  "(del)RH P40K036986
*           no_curtp_10        = gd_mlwere-no_10_ml  "(del)RH P40K036986
            no_curtp_00        = gd_mlwere-no_00_ml-boole "RH P40K036986
            no_curtp_10        = gd_mlwere-no_10_ml-boole "RH P40K036986
       TABLES
            t_ekbe_cr          = ld_ekbe_all_tbl[]
            t_ekbz_cr          = ld_ekbz_all_tbl[]
       EXCEPTIONS
            data_not_found     = 0
            OTHERS             = 1.
  PERFORM breakrc USING 'L008'.

* Abarbeiten jeden BET-Eintrag f? die ?ergebene Bestellposition
  SORT ld_ekbe_all_tbl
       BY zekkn vgabe gjahr belnr buzei.
  ld_bet_save = bet.
  LOOP AT bet WHERE
          ebeln EQ pot-ebeln AND
          ebelp EQ pot-ebelp.

*   Initialisierungen
    CLEAR ld_found.
    CLEAR bet_wa.
    MOVE-CORRESPONDING bet TO ld_bet_key.
    bet_wa-key = ld_bet_key.

*   Lesen aller CR-Eintr?e zum BET-Eintrag
    CLEAR ld_ekbe_ezl_tbl.
    READ TABLE ld_ekbe_all_tbl
      WITH KEY
      zekkn = bet-zekkn
      vgabe = bet-vgabe
      gjahr = bet-gjahr
      belnr = bet-belnr
      buzei = bet-buzei
      BINARY SEARCH.
    IF sy-subrc EQ 0.
      ld_tabix = sy-tabix.
      ld_found = 'X'.
      APPEND ld_ekbe_all_tbl TO ld_ekbe_ezl_tbl.
      DO.
        ADD 1 TO ld_tabix.
        READ TABLE ld_ekbe_all_tbl INDEX ld_tabix.
        IF sy-subrc NE 0.
          EXIT.
        ENDIF.
        MOVE-CORRESPONDING ld_ekbe_all_tbl TO ld_bet_key_save.
        ld_bet_key_save-mandt = ld_bet_key-mandt.
        IF ld_bet_key NE ld_bet_key_save.
          EXIT.
        ENDIF.
        APPEND ld_ekbe_all_tbl TO ld_ekbe_ezl_tbl.
      ENDDO.

*   Konsistenz-Pr?ung: Mlbecr-Satz mu?existieren
    ELSE.
      PERFORM mlbecr_konsistenz_pruefen USING
                 ld_bnk         "Kz: EKBZ
                 bet-vgabe      "Vorgangsart
                 pot-ebeln      "Bestellnummer
                 pot-ebelp.     "Bestellposition
    ENDIF.

*   Zugeh?ige EKBE_CR-S?ze in die BET_WA
    IF ld_found NE space.
      PERFORM bet_wa_eintrag_bereiten USING
                bet_wa
                ld_ekbe_ezl_tbl.
      APPEND bet_wa.
    ENDIF.
  ENDLOOP.
  SORT bet_wa BY key.

* Merken der Tabelle in der globalen InfoStruktur
  READ TABLE gd_ipot_tbl WITH KEY
       ebeln = pot-ebeln
       ebelp = pot-ebelp
       BINARY SEARCH.
  ld_subrc = sy-subrc.
  ld_tabix = sy-tabix.

* Initialisieren, falls Eintrag neu
  IF ld_subrc NE 0.
    CLEAR gd_ipot_tbl.
    gd_ipot_tbl-ebeln = pot-ebeln.
    gd_ipot_tbl-ebelp = pot-ebelp.
  ENDIF.

* Vermerken, da?BET_WA aufgebaut ist
  gd_ipot_tbl-ekbe_pr_kz = 'X'.
  DESCRIBE TABLE bet_wa LINES sy-tfill.
  IF sy-tfill GT 0.
    gd_ipot_tbl-ekbe_wa_kz = 'X'.
  ELSE.
    gd_ipot_tbl-ekbe_wa_kz = space.
  ENDIF.
  gd_ipot_tbl-ibet_wa[] = bet_wa[].
  IF ld_subrc EQ 0.
    MODIFY gd_ipot_tbl INDEX ld_tabix.
  ELSE.
    INSERT gd_ipot_tbl INDEX ld_tabix.
  ENDIF.

* Zur?ksetzen der globalen Info-Struktur, damit diese gegebenenfalls
* wieder aktualisiert wird.
  CLEAR gd_ipot_info.

* Wiederherstellen des alten BET-Eintrags
  bet = ld_bet_save.
ENDFORM.                    "BET_WA_AUFBAUEN

*----------------------------------------------------------------------*
*       FORM BET_WA_EINTRAG_BEREITEN
*----------------------------------------------------------------------*
*  -->  R_BET_WA
*  -->  R_EKBE_CR_EZL
*----------------------------------------------------------------------*
FORM bet_wa_eintrag_bereiten USING
       r_bet_wa              TYPE ty_bet_wa
       r_ekbe_cr_ezl_tbl     TYPE ty_ekbe_cr_tbl.

  DATA:
    ld_ekbe_cr       TYPE LINE OF ty_ekbe_cr_tbl,
    ld_dmbtr         TYPE mlcr_curr,
    ld_arewr         TYPE mlcr_curr,
    ld_reewr         TYPE mlcr_curr.

* W?rungsvektoren aufbauen
  LOOP AT r_ekbe_cr_ezl_tbl INTO ld_ekbe_cr.

*   W?rungstypen
    ld_dmbtr-curtp     = ld_ekbe_cr-curtp.
    ld_reewr-curtp     = ld_ekbe_cr-curtp.
    ld_arewr-curtp     = ld_ekbe_cr-curtp.

*   W?rungsschl?sel
    ld_dmbtr-waers     = ld_ekbe_cr-waers.
    ld_reewr-waers     = ld_ekbe_cr-waers.
    ld_arewr-waers     = ld_ekbe_cr-waers.

*   Werte
    ld_dmbtr-wert      = ld_ekbe_cr-wrbtr.
    ld_reewr-wert      = ld_ekbe_cr-reewr.
    ld_arewr-wert      = ld_ekbe_cr-arewr.

*   Hinzuf?en
    APPEND ld_dmbtr TO r_bet_wa-dmbtr.
    APPEND ld_reewr TO r_bet_wa-reewr.
    APPEND ld_arewr TO r_bet_wa-arewr.
  ENDLOOP.

* 10-er W?rung erzeugen
  PERFORM ml_10_werte_bet_wa_ergaenzen CHANGING
            r_bet_wa.

* Sortieren nach W?rungstyp
  SORT r_bet_wa-dmbtr BY curtp.
  SORT r_bet_wa-reewr BY curtp.
  SORT r_bet_wa-arewr BY curtp.
ENDFORM.                    "BET_WA_EINTRAG_BEREITEN

*----------------------------------------------------------------------*
*       FORM ML_10_WERTE_BET_WA_ERGAENZEN
*----------------------------------------------------------------------*
*       Die 10-er W?rungen werden in die BET_WA f? Konsistenzcheks
*       hinzugef?t.
*----------------------------------------------------------------------*
*  -->  R_BET_WA
*----------------------------------------------------------------------*
FORM ml_10_werte_bet_wa_ergaenzen CHANGING
       r_bet_wa  TYPE ty_bet_wa.

  DATA:
    ld_dmbtr         TYPE mlcr_curr,
    ld_arewr         TYPE mlcr_curr,
    ld_reewr         TYPE mlcr_curr,
    ld_waers         TYPE mlcr_curr-waers.

* Nur prozessieren, falls Schalter sitzt
  CHECK gd_mlwere-no_10_db NE space.

* Holen der Buchungskreisw?rung
  PERFORM bukrs_waers_holen USING
            bet-ebeln
          CHANGING
            ld_waers.

* W?rungstypen
  ld_dmbtr-curtp     = '10'.
  ld_reewr-curtp     = '10'.
  ld_arewr-curtp     = '10'.

* W?rungsschl?sel
  ld_dmbtr-waers     = ld_waers.
  ld_reewr-waers     = ld_waers.
  ld_arewr-waers     = ld_waers.

* Werte
  ld_dmbtr-wert      = bet-dmbtr.
  ld_reewr-wert      = bet-reewr.
  ld_arewr-wert      = bet-arewr.

* Hinzuf?en
  APPEND ld_dmbtr TO r_bet_wa-dmbtr.
  APPEND ld_reewr TO r_bet_wa-reewr.
  APPEND ld_arewr TO r_bet_wa-arewr.
ENDFORM.                    "ML_10_WERTE_BET_WA_ERGAENZEN
