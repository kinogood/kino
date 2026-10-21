************************************************************************
* Title         :  ZTIRI010F01                                         *
*                                                                      *
* Description   : TEXT ID 공용루틴 Include                             *
*                                                                      *
* Creation Date : 2003/10/10                                           *
*                                                                      *
* Author        : SeogBong, Kang                                       *
*                                                                      *
************************************************************************
* ------ Gemeinsamer Include f?: --------------------------------------
*           FBZA/P (SAPDFKZ1-3)
*           FBKA/P (SAPDFKB1-6)
*           FAKA/P (SAPDFKA1-4)
*           FI12/13(SAPMF02I)

DATA:
    TR_AUTO_CURRSET.

*** Module *************************************************************
*
*       GET_CURSOR              Besorgen der Cursorposition
*       GET_CURSOR_0110         Besorgen der Cursorposition
*       SUPPRESS_DIALOG         Dialogfreies Einstiegsbild
*
*** Form-Routinen ******************************************************
*
*       BERECHTIGUNG_PRUEFEN    Pr?en der Berechtigung f? alle Tab.
*       BLAETTERN
*       BLAETTERN_NEU
*       CALL_SCREEN             Aufruf eines POPUPs ?er T019W
*       CHECK_CURSOR
*       CURSORMELDUNG
*       EINGABEBEREITSCHAFT_AUS
*       EINSTIEGSBILD           R?ksprung zum Einstiegsbild
*       EXCTAB_STANDARD         Standardeintr?e in EXCTAB
*       FEHLER_BEIM_SPERREN
*       GET_CURSOR
*       KORREKTUR_ERGAENZEN     Erg?zen einer Korrektur
*       KORREKTUR_EROEFFNEN     Er?fnen einer Korrektur
*       OKCODE_F15              Behandlung von 'Beenden'
*       OKCODE_F17              Behandlung von 'Anderes ... '
*       RETURN_TO_MENU          R?ksprung zum Men?
*       SCREEN_INTENSIFIED
*       SCREEN_INVISIBLE
*       SCREEN_INVISIBLE_NEW
*       SCREEN_LENGTH
*       SCREEN_NO_INPUT
*       TABELLE_ENTSPERREN      Entsperren einer einzelnen Tabelle
*       TABELLEN_ENTSPERREN     Entsperren aller Tabellen
*       TABELLE_SPERREN         Sperren einer einzelnen Tabelle
*       TABELLEN_SPERREN        Sperren aller Tabellen
*       TEXT_AUS_050T           Lesen eines Textes aus T050T
*       TRANSPORT_BEGINNEN      Er?fnen eines Transports
*       TRANSPORT_EINTRAGEN     Eintragen in einen Transport
*       TRANSPORT_EINLESEN      Einlesen des Transports
*       TRANSPORT_MELDEN        Meldung ?er Eintrag in Transport
*       TRANSPORT_ZEIGEN        Zeigen/Editieren eines Transports
*       UEBERSETZEN             SM31-Ansprung einer Texttabelle
*       WECHSEL_ZUM_AENDERN     Wechsel zum Anzeigen zum 훞dern

*eject
*---------------------------------------------------------------------*
*       MODULE  GET_CURSOR                                            *
*---------------------------------------------------------------------*
*       Die Zeile, in der der Cursor stand, wird in DY-LINNO gemerkt. *
*       Dies gilt nur f? OK-Code ungleich SPACE (z.B. PICK oder      *
*       DELE).                                                        *
*---------------------------------------------------------------------*
MODULE GET_CURSOR.
  IF OK-CODE = SPACE.
    CLEAR: DY-FIELD, DY-LINNO.
  ELSE.
    GET CURSOR FIELD DY-FIELD LINE DY-LINNO.
  ENDIF.
ENDMODULE.

*eject
*---------------------------------------------------------------------*
*       MODULE  GET_CURSOR_0110                                       *
*---------------------------------------------------------------------*
*       Die Zeile, in der der Cursor stand, wird im                   *
*       Feld LINNO-0110 gemerkt.                                      *
*       (Listbild, von dem aus Auswahl getroffen wird).               *
*---------------------------------------------------------------------*
MODULE GET_CURSOR_0110.
  CHECK OK-CODE NE SPACE.
  CHECK OK-CODE NA '+-'.
  GET CURSOR FIELD DY-FIELD LINE LINNO-0110.
ENDMODULE.

*eject
*---------------------------------------------------------------------*
*       MODULE  SUPPRESS_DIALOG                                       *
*---------------------------------------------------------------------*
*       SUPPRESS DIALOG beim PBO eines CALL DIALOG - Dynpros.         *
*---------------------------------------------------------------------*
MODULE SUPPRESS_DIALOG OUTPUT.
  SUPPRESS DIALOG.
ENDMODULE.

*eject
******** FORM-Routinen *************************************************

*eject
*---------------------------------------------------------------------*
*       FORM BERECHTIGUNG_PRUEFEN                                     *
*---------------------------------------------------------------------*
*       Berechtigungspr?ung f? alle Tabellen.                       *
*---------------------------------------------------------------------*
FORM BERECHTIGUNG_PRUEFEN.

* ------ Berechtigung pr?en -------------------------------------------
  CALL FUNCTION 'FI_CUST_AUTHORITY_CHECK'
       EXPORTING
            I_AKTYP                      = T020-AKTYP
            I_OKCOD                      = OK-CODE
            I_OKCOD_TO_CHANGE_AKTYP      = 'AEND'
            I_TABLES                     = TABLES
       EXCEPTIONS
            NO_AUTHORITY                 = 1
            NO_AUTHORITY_NOW_DISPLAY     = 2
            NO_AUTHORITY_TO_CHANGE_AKTYP = 3.

* ------ Bearbeitung der Returncodes -----------------------------------
  CASE SY-SUBRC.
    WHEN 1.
      MSGNR        = '320'.
      TBSPR        = SY-MSGV1.
      TDDAT-CCLASS = SY-MSGV2.
      IF SY-TCODE(3) NE 'FI1'.
        PERFORM RETURN_TO_MENU.
      ENDIF.
    WHEN 2.
      MESSAGE S319(F4) WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
      T020-AKTYP = 'A'.
    WHEN 3.
      OK-CODE = SPACE.
      MESSAGE E319(F4) WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDCASE.
ENDFORM.

*eject
*---------------------------------------------------------------------*
*       FORM BLAETTERN                                                *
*---------------------------------------------------------------------*
*       Bl?tern in einer internen Tabelle.                           *
*---------------------------------------------------------------------*
*  -->  B01_LNFIR Index des ersten Eintrags                           *
*  -->  B01_LNMAX Gesamtzahl aller Eintr?e                           *
*  -->  B01_LNCNT Anzahl der Loopzeilen                               *
*---------------------------------------------------------------------*
FORM BLAETTERN USING
            B02_LNFIR    LIKE SYST-TABIX
            B02_LNMAX    LIKE SYST-TABIX
            B02_LNCNT    LIKE SYST-LOOPC.
*ORM BLAETTERN USING B02_LNFIR B02_LNMAX B02_LNCNT.
  DATA: LOOPI(1) TYPE C.               " Loop-Input?

* ------ Dynpro mit Loop-Input? ----------------------------------------
  CLEAR: LOOPI.
  IF T020-AKTYP NE 'A'.
    PERFORM DYNPRO_MIT_LOOPINPUT.
    IF RC = 0.
      LOOPI = 'X'.
    ENDIF.
  ENDIF.

* ------ Bl?tern ------------------------------------------------------
  CALL FUNCTION 'FI_CUST_SCROLL'
       EXPORTING
            I_INPUT = LOOPI
            I_OKCOD = OK-CODE
            I_LNFIR = B02_LNFIR
            I_LNMAX = B02_LNMAX
            I_LOOPC = B02_LNCNT
       IMPORTING
            E_LNFIR = B02_LNFIR.
  CLEAR: OK-CODE.
  TBCUR = B02_LNFIR.
ENDFORM.

*eject
*---------------------------------------------------------------------*
*       FORM BLAETTERN_NEU        (AUSW geht verloren)                *
*---------------------------------------------------------------------*
*       Bl?tern in einer internen Tabelle.                           *
*---------------------------------------------------------------------*
*  -->  B02_LNFIR Index des ersten Eintrags                           *
*  -->  B02_LNMAX Gesamtzahl aller Eintr?e                           *
*  -->  B02_LNCNT Anzahl der Loopzeilen                               *
*---------------------------------------------------------------------*
FORM BLAETTERN_NEU USING
            B02_LNFIR    LIKE SYST-TABIX
            B02_LNMAX    LIKE SYST-TABIX
            B02_LNCNT    LIKE SYST-LOOPC.
*ORM BLAETTERN_NEU USING B02_LNFIR B02_LNMAX B02_LNCNT.
  DATA: LOOPI(1) TYPE C.               " Loop-Input?

* ------ Dynpro mit Loop-Input? ----------------------------------------
  CLEAR: LOOPI.
  IF T020-AKTYP NE 'A'.
    PERFORM DYNPRO_MIT_LOOPINPUT.
    IF RC = 0.
      LOOPI = 'X'.
    ENDIF.
  ENDIF.

* ------ Bl?tern ------------------------------------------------------
  CALL FUNCTION 'FI_CUST_SCROLL'
       EXPORTING
            I_INPUT = LOOPI
            I_OKCOD = OK-CODE
            I_LNFIR = B02_LNFIR
            I_LNMAX = B02_LNMAX
            I_LOOPC = B02_LNCNT
       IMPORTING
            E_LNFIR = B02_LNFIR.
  CLEAR: AUSW, LINNO-0110, OK-CODE.
  TBCUR = B02_LNFIR.
ENDFORM.

*eject
*---------------------------------------------------------------------*
*       FORM  CHECK_CURSOR                                            *
*---------------------------------------------------------------------*
*       Bei ung?tiger Cursorposition wird eine S-Meldung gesandt.    *
*---------------------------------------------------------------------*
FORM CHECK_CURSOR.
  IF DY-LINNO = 0.
    MESSAGE S315(F4).
    CLEAR OK-CODE.
    SET SCREEN SY-DYNNR.
    LEAVE SCREEN.
  ENDIF.
ENDFORM.

*eject
*---------------------------------------------------------------------*
*       FORM  CALL_SCREEN                                             *
*---------------------------------------------------------------------*
*       Anhand der Tabelle T019W werden der zu callende Screen und    *
*       seine Koordinaten ermittelt.                                  *
*---------------------------------------------------------------------*
*  -->  C01_MPOOL   Modulpool                                         *
*  -->  C01_WINFK   Funktion des Windows                              *
*---------------------------------------------------------------------*
FORM CALL_SCREEN USING
            C01_MPOOL    TYPE C
            C01_WINFK    TYPE C.
*ORM CALL_SCREEN USING C01_MPOOL C01_WINFK.
  SELECT SINGLE * FROM  T019W
                  WHERE MPOOL = C01_MPOOL
                  AND   BUVAR = SPACE
                  AND   WINFK = C01_WINFK.
  IF SY-SUBRC = 0.
    CALL SCREEN T019W-WINNR
         STARTING AT T019W-SPVON T019W-ZLVON
         ENDING   AT T019W-SPBIS T019W-ZLBIS.

* ------ 'ENTER' zur?knehmen ------------------------------------------
    IF OK-CODE(3) = 'ENT'.
      CLEAR OK-CODE.
    ENDIF.
  ELSE.
    IF SY-REPID CS 'Z'.
      MESSAGE E810(F3) WITH 'T019W' SY-REPID C01_WINFK.
    ELSE.
      MESSAGE E100(F4) WITH 'T019W' C01_WINFK.
    ENDIF.
  ENDIF.
ENDFORM.

*eject
*---------------------------------------------------------------------*
*       FORM  CURSORMELDUNG                                           *
*---------------------------------------------------------------------*
*       (FBZP)                                                        *
*       Es wird eine S-Meldung gesandt, wenn der Cursor nicht         *
*       richtig positioniert worden ist.                              *
*---------------------------------------------------------------------*
FORM CURSORMELDUNG.
  IF SY-SUBRC NE 0.
    MESSAGE S806(F3).
    SET SCREEN SY-DYNNR.
    LEAVE SCREEN.
  ENDIF.
ENDFORM.

*eject
*---------------------------------------------------------------------*
*       FORM DYNPRO_MIT_LOOPINPUT                                     *
*---------------------------------------------------------------------*
*       Feststellen, ob auf dem Dynpro Eingaben im Loop m?lich sind. *
*       (Falls ja, kann man durch 'P+' eine leere neue Seite erhalten,*
*        falls man auf der letzten vollen Seite steht.)               *
*---------------------------------------------------------------------*
FORM DYNPRO_MIT_LOOPINPUT.
  RC = 4.
  CASE SY-REPID.
    WHEN 'SAPDFKA4'.
      IF SY-DYNNR = 120
      OR SY-DYNNR = 121.
        RC = 0.
      ENDIF.
    WHEN 'SAPDFKB1'.
      IF SY-DYNNR = 200
      OR SY-DYNNR = 201
      OR SY-DYNNR = 210
      OR SY-DYNNR = 211
      OR SY-DYNNR = 212
      OR SY-DYNNR = 213
      OR SY-DYNNR = 230.
        RC = 0.
      ENDIF.
    WHEN 'SAPDFKB2'.
      IF SY-DYNNR = 120.
        RC = 0.
      ENDIF.
    WHEN 'SAPDFKB5'.
      IF SY-DYNNR = 130.
        RC = 0.
      ENDIF.
    WHEN 'SAPDFKB6'.
      IF SY-DYNNR = 130.
        RC = 0.
      ENDIF.
    WHEN 'SAPMFKD0'.
      IF SY-DYNNR = 1030
      OR SY-DYNNR = 1040
      OR SY-DYNNR = 1050
      OR SY-DYNNR = 1090.
        RC = 0.
      ENDIF.
  ENDCASE.
ENDFORM.


*eject
*---------------------------------------------------------------------*
*       FORM  EINGABEBEREITSCHAFT_AUS                                 *
*---------------------------------------------------------------------*
*       Beim Anzeigen werden die Felder mit SCREEN-INPUT = 1          *
*       auf NICHT EINGABEBEREIT gesetzt.                              *
*       (F? Normal-F?le, d.h. ohne Aufsetzargument)                 *
*---------------------------------------------------------------------*
FORM EINGABEBEREITSCHAFT_AUS.
  CHECK T020-AKTYP = 'A'.
  LOOP AT SCREEN.
    CHECK SCREEN-INPUT = 1.
    SCREEN-INPUT = 0.
    MODIFY SCREEN.
  ENDLOOP.
ENDFORM.

*eject
*---------------------------------------------------------------------*
*       FORM  EINSTIEGSBILD                                           *
*---------------------------------------------------------------------*
*       Es wird auf das Einstiegsbild verzweigt.                      *
*       Wenn der MASTERMODUS aktiv ist, ist dies das Bild mit der     *
*       M?lichkeit der Schl?seleingabe, ansonsten ist es die Liste. *
*---------------------------------------------------------------------*
FORM EINSTIEGSBILD.
  IF MSMOD = SPACE.
    PERFORM DYNPRO_0110_ZEIGEN.
  ELSE.
*    SET SCREEN 100.
    SET SCREEN 0.
    LEAVE SCREEN.
  ENDIF.
ENDFORM.

*eject
*---------------------------------------------------------------------*
*       FORM EXCTAB_STANDARD                                          *
*---------------------------------------------------------------------*
*       Aufbau der EXCTAB f? den Standardfall.                       *
*---------------------------------------------------------------------*
FORM EXCTAB_STANDARD.
  REFRESH EXCTAB.

* ------ Anzeigen: 훞derungsfunktionen ausschlie?n --------------------
  IF T020-AKTYP = 'A'.
    EXCTAB-OKCOD = 'COPY'. APPEND EXCTAB.
    EXCTAB-OKCOD = 'DELE'. APPEND EXCTAB.
    EXCTAB-OKCOD = 'EF12'. APPEND EXCTAB.
    EXCTAB-OKCOD = 'INSE'. APPEND EXCTAB.
    EXCTAB-OKCOD = 'TEXT'. APPEND EXCTAB.
    EXCTAB-OKCOD = 'TRAN'. APPEND EXCTAB.
    EXCTAB-OKCOD = 'TRBG'. APPEND EXCTAB.
    EXCTAB-OKCOD = 'UPDA'. APPEND EXCTAB.

* ------ 훞dern: Wechsel zum 훞dern ausschlie?n -----------------------
  ELSE.
    EXCTAB-OKCOD = 'AEND'. APPEND EXCTAB.
  ENDIF.

* ------ Ausnahme WE_OBJECT_APPENDABLE aus TR_OBJECT_CHECK: ------------
* ------ Transportieren ausschlie?n -----------------------------------
  IF XAPPE = SPACE.
*   EXCTAB-OKCOD = 'TRBG'. APPEND EXCTAB.
  ENDIF.
ENDFORM.

*eject
*---------------------------------------------------------------------*
*       FORM  FEHLER_BEIM_SPERREN                                     *
*---------------------------------------------------------------------*
*       Wenn beim Sperren ein Fehler auftrat, wird die Fehlernummer   *
*       und die betroffene Tabelle ?er die IMPORTING - Schnittstelle *
*       des CALL DIALOG zur?kgegeben und hier eine entsprechende     *
*       Meldung ausgegeben.                                           *
*---------------------------------------------------------------------*
FORM FEHLER_BEIM_SPERREN.
  CHECK MSGNR NE SPACE.
  CASE MSGNR.
    WHEN '301'.
      MESSAGE E301(F4) WITH TBSPR.
    WHEN '302'.
      MESSAGE E302(F4).
    WHEN '303'.
      MESSAGE E303(F4) WITH TBSPR.
    WHEN '320'.
      MESSAGE E320(F4) WITH TBSPR TDDAT-CCLASS 'S_TABU_DIS' '03'.
    WHEN OTHERS.
      MESSAGE A317(F4) WITH TBSPR.
  ENDCASE.
ENDFORM.

*eject
*---------------------------------------------------------------------*
*       FORM  FLITAB_EINTRAGEN                                        *
*---------------------------------------------------------------------*
*       Eintragen der LNFIR in  Tabelle FLITAB.                       *
*---------------------------------------------------------------------*
* ->    F01_DYNNR: Dynpronummer (normalerweise SY-DYNNR)              *
*---------------------------------------------------------------------*
FORM FLITAB_EINTRAGEN USING
            F01_DYNNR    TYPE C.
*ORM FLITAB_EINTRAGEN USING F01_DYNNR.
  READ TABLE FLITAB WITH KEY F01_DYNNR.
  IF SY-SUBRC = 0.
    FLITAB-LNFIR = LNFIR.
    MODIFY FLITAB INDEX SY-TABIX.
  ELSE.
    FLITAB-DYNNR = F01_DYNNR.
    FLITAB-LNFIR = LNFIR.
    APPEND FLITAB.
  ENDIF.
  TBCUR = LNFIR.
ENDFORM.

*eject
*---------------------------------------------------------------------*
*       FORM  FLITAB_LESEN                                            *
*---------------------------------------------------------------------*
*       Ermitteln der LNFIR aus Tabelle FLITAB.                       *
*---------------------------------------------------------------------*
*  -->  F01_DYNNR: Dynpronummer                                       *
*---------------------------------------------------------------------*
FORM FLITAB_LESEN USING
            F01_DYNNR    TYPE C.
*ORM FLITAB_LESEN USING F01_DYNNR.
  READ TABLE FLITAB WITH KEY F01_DYNNR.
  IF SY-SUBRC = 0.
    LNFIR = FLITAB-LNFIR.
  ELSE.
    LNFIR = 1.
    FLITAB-DYNNR = F01_DYNNR.
    FLITAB-LNFIR = LNFIR.
    APPEND FLITAB.
  ENDIF.
  TBCUR = LNFIR.
ENDFORM.

*eject
*---------------------------------------------------------------------*
*       FORM  FLITAB_LOESCHEN                                         *
*---------------------------------------------------------------------*
*       L?chen eines Eintrags aus FLITAB.                            *
*---------------------------------------------------------------------*
*  -->  F02_DYNNR: Dynpronummer                                       *
*---------------------------------------------------------------------*
FORM FLITAB_LOESCHEN USING
            F02_DYNNR    TYPE C.
*ORM FLITAB_LOESCHEN USING F02_DYNNR.
  LOOP AT FLITAB WHERE DYNNR = F02_DYNNR.
    DELETE FLITAB.
  ENDLOOP.
ENDFORM.

*eject
*---------------------------------------------------------------------*
*       FORM  GET_CURSOR                                              *
*---------------------------------------------------------------------*
*       Die Zeile, in der der Cursor stand, wird in DY-LINNO gemerkt. *
*       Dies gilt nur f? OK-Code ungleich SPACE (z.B. PICK oder      *
*       DELE).                                                        *
*---------------------------------------------------------------------*
FORM GET_CURSOR.
  IF  OK-CODE    NE 'PICK'
  AND OK-CODE(3) NE 'DEL'
  AND OK-CODE    NE 'TEXT'.
    CLEAR: DY-FIELD, DY-LINNO, DY-INHALT.                   "note 568615
  ELSE.
    GET CURSOR FIELD DY-FIELD LINE DY-LINNO VALUE DY-INHALT."note 568615
  ENDIF.
ENDFORM.

*eject
*---------------------------------------------------------------------*
*       FORM  OKCODE_F15
*---------------------------------------------------------------------*
*       Behandlung des OK-Codes 'F15'.
*---------------------------------------------------------------------*
FORM OKCODE_F15.
  IF SY-DYNNR = 100
  OR SY-DYNNR = 110.
    PERFORM TABELLEN_ENTSPERREN.
    PERFORM RETURN_TO_MENU.
  ELSE.
    PERFORM DATENVERLUST_OHNE_SICHERN USING TEXT-PT1.
    PERFORM TABELLEN_ENTSPERREN.
    PERFORM RETURN_TO_MENU.
  ENDIF.
ENDFORM.

*eject
*---------------------------------------------------------------------*
*       FORM  OKCODE_F17
*---------------------------------------------------------------------*
*       Behandlung des OK-Codes 'F17'.
*---------------------------------------------------------------------*
FORM OKCODE_F17.
  IF SY-DYNNR = 100
  OR SY-DYNNR = 110.
    CLEAR OK-CODE.
    PERFORM EINSTIEGSBILD.
  ELSE.
    CLEAR OK-CODE.
    PERFORM DATENVERLUST_OHNE_SICHERN USING TEXT-PT2.
    PERFORM EINSTIEGSBILD.
  ENDIF.
ENDFORM.

*eject
*---------------------------------------------------------------------*
*       FORM  RETURN_TO_MENU
*---------------------------------------------------------------------*
*       R?kkehr zum aufrufenden Programm bzw. ins Men?
*---------------------------------------------------------------------*
FORM RETURN_TO_MENU.
  set screen 0.
  LEAVE SCREEN.
ENDFORM.

*eject
*---------------------------------------------------------------------*
*       FORM  SCREEN_INTENSIFIED                                      *
*---------------------------------------------------------------------*
*       Die SCREEN-Felder der Gruppe 001 werden helleuchtend          *
*       ausgegeben.                                                   *
*---------------------------------------------------------------------*
FORM SCREEN_INTENSIFIED.
  LOOP AT SCREEN.
    CHECK SCREEN-GROUP1 = '001'.
    SCREEN-INTENSIFIED = 1.
    MODIFY SCREEN.
  ENDLOOP.
ENDFORM.

*eject
*---------------------------------------------------------------------*
*       FORM  SCREEN_INTENSIFIED_NEW                                  *
*---------------------------------------------------------------------*
*       Die SCREEN-Felder der spezifizierten Gruppe werden            *
*       helleuchtend ausgegeben                                       *
*---------------------------------------------------------------------*
FORM SCREEN_INTENSIFIED_NEW USING
            S03_GROUP    TYPE C
            S03_MODIF    TYPE C.
*ORM SCREEN_INTENSIFIED_NEW USING S03_GROUP S03_MODIF.
  LOOP AT SCREEN.
    CASE S03_GROUP.
      WHEN '1'. CHECK SCREEN-GROUP1 = S03_MODIF.
      WHEN '2'. CHECK SCREEN-GROUP2 = S03_MODIF.
      WHEN '3'. CHECK SCREEN-GROUP3 = S03_MODIF.
      WHEN '4'. CHECK SCREEN-GROUP4 = S03_MODIF.
    ENDCASE.
    SCREEN-INTENSIFIED = 1.
    MODIFY SCREEN.
  ENDLOOP.
ENDFORM.

*eject
*---------------------------------------------------------------------*
*       FORM  SCREEN_INVISIBLE                                        *
*---------------------------------------------------------------------*
*       Die SCREEN-Felder der spezifizierten Gruppe werden            *
*       ausgeblendet.                                                 *
*---------------------------------------------------------------------*
FORM SCREEN_INVISIBLE USING
            S01_GROUP    TYPE C.
*ORM SCREEN_INVISIBLE USING S01_GROUP.
  LOOP AT SCREEN.
    CHECK SCREEN-GROUP1 = S01_GROUP.
    SCREEN-INPUT     = 0.
    SCREEN-ACTIVE    = 0.
    SCREEN-INVISIBLE = 1.
    MODIFY SCREEN.
  ENDLOOP.
ENDFORM.

*eject
*---------------------------------------------------------------------*
*       FORM  SCREEN_INVISIBLE_NEW                                    *
*---------------------------------------------------------------------*
*       Die SCREEN-Felder der spezifizierten Gruppe werden            *
*       ausgeblendet.                                                 *
*---------------------------------------------------------------------*
FORM SCREEN_INVISIBLE_NEW USING
            S01_NEWNR    TYPE C
            S01_NEWGR    TYPE C.
*ORM SCREEN_INVISIBLE_NEW USING S01_NEWNR S01_NEWGR.
  LOOP AT SCREEN.
    CASE S01_NEWNR.
      WHEN '1'. CHECK SCREEN-GROUP1 = S01_NEWGR.
      WHEN '2'. CHECK SCREEN-GROUP2 = S01_NEWGR.
      WHEN '3'. CHECK SCREEN-GROUP3 = S01_NEWGR.
      WHEN '4'. CHECK SCREEN-GROUP4 = S01_NEWGR.
    ENDCASE.
    SCREEN-INPUT     = 0.
    SCREEN-ACTIVE    = 0.
    SCREEN-INVISIBLE = 1.
    MODIFY SCREEN.
  ENDLOOP.
ENDFORM.

*eject
*---------------------------------------------------------------------*
*       FORM  SCREEN_LENGTH                                           *
*---------------------------------------------------------------------*
*       Die SCREEN-Felder mit dem spezifizierten Wert in              *
*       SCREEN-GROUP1 werden auf L?ge S01_LENGT verk?zt.            *
*---------------------------------------------------------------------*
FORM SCREEN_LENGTH
     USING VALUE(S01_LWERT) TYPE CLIKE
           VALUE(S01_LENGT) TYPE CLIKE.
  LOOP AT SCREEN.
    CHECK SCREEN-GROUP1 = S01_LWERT
      AND SCREEN-INPUT  = 1.
    SCREEN-LENGTH = S01_LENGT.
    MODIFY SCREEN.
  ENDLOOP.
ENDFORM.

*eject
*---------------------------------------------------------------------*
*       FORM  SCREEN_NO_INPUT                                         *
*---------------------------------------------------------------------*
*       Die SCREEN-Felder der spezifizierten Gruppe werden            *
*       auf nicht eingabebereit gesetzt.                              *
*---------------------------------------------------------------------*
FORM SCREEN_NO_INPUT USING
            S01_GROUP    TYPE C.
*ORM SCREEN_NO_INPUT USING S01_GROUP.
  LOOP AT SCREEN.
    CHECK SCREEN-GROUP1 = S01_GROUP.
    SCREEN-INPUT     = 0.
    SCREEN-ACTIVE    = 1.
    MODIFY SCREEN.
  ENDLOOP.
ENDFORM.

*eject
*---------------------------------------------------------------------*
*       FORM  SCREEN_NO_INPUT_NEW                                     *
*---------------------------------------------------------------------*
*       Die SCREEN-Felder der spezifizierten Gruppe werden            *
*       auf nicht eingabebereit gesetzt.                              *
*---------------------------------------------------------------------*
FORM SCREEN_NO_INPUT_NEW USING
            S02_NEWNR    TYPE C
            S02_NEWGR    TYPE C.
*ORM SCREEN_NO_INPUT_NEW USING S02_NEWNR S02_NEWGR.
  LOOP AT SCREEN.
    CASE S02_NEWNR.
      WHEN '1'. CHECK SCREEN-GROUP1 = S02_NEWGR.
      WHEN '2'. CHECK SCREEN-GROUP2 = S02_NEWGR.
      WHEN '3'. CHECK SCREEN-GROUP3 = S02_NEWGR.
      WHEN '4'. CHECK SCREEN-GROUP4 = S02_NEWGR.
    ENDCASE.
    SCREEN-INPUT     = 0.
    SCREEN-ACTIVE    = 1.
    MODIFY SCREEN.
  ENDLOOP.
ENDFORM.

*eject
*---------------------------------------------------------------------*
*       FORM  STEHENBLEIBEN                                           *
*---------------------------------------------------------------------*
*       Auf dem aktuellen Dynpro stehenbleiben.                       *
*---------------------------------------------------------------------*
FORM STEHENBLEIBEN.
  SET SCREEN SY-DYNNR.
  LEAVE SCREEN.
ENDFORM.

*eject
*---------------------------------------------------------------------*
*       FORM TABELLE_ENTSPERREN                                       *
*---------------------------------------------------------------------*
*       Entsperren einer einzelnen Tabelle.                           *
*       ( Anwendung: Texttabelle vor dem Sprung zu TM31 )             *
*---------------------------------------------------------------------*
*       T01_TBNAM : Tabellenname                                      *
*---------------------------------------------------------------------*
FORM TABELLE_ENTSPERREN USING
            T01_TBNAM    TYPE C.
*ORM TABELLE_ENTSPERREN USING T01_TBNAM.
  TBSPR  = T01_TBNAM.
  IF ENQNOCLI NE 'X'.
    ENQKEY = SY-MANDT.
  ENDIF.
  CALL FUNCTION 'DEQUEUE_E_TABLE'
       EXPORTING
            TABNAME = TBSPR
            VARKEY  = ENQKEY.
ENDFORM.

*eject
*---------------------------------------------------------------------*
*       FORM TABELLEN_ENTSPERREN                                      *
*---------------------------------------------------------------------*
*       Entsperren aller beteiligter Tabellen.                        *
*---------------------------------------------------------------------*
FORM TABELLEN_ENTSPERREN.
  IF ENQNOCLI = SPACE.
    ENQNOCLI = 'N'.
  ENDIF.
  IF ENQGENKEY = SPACE.
    ENQGENKEY = 'N'.
  ENDIF.
  CALL FUNCTION 'FI_CUST_DEQUEUE'
       EXPORTING
            I_TABLES = TABLES
            I_GENKEY = ENQGENKEY
            I_NOCLI  = ENQNOCLI.
ENDFORM.

*eject
*---------------------------------------------------------------------*
*       FORM TABELLE_SPERREN                                          *
*---------------------------------------------------------------------*
*       Sperren einer einzelnen Tabelle.                              *
*       ( Anwendung: Texttabelle nach R?kkehr aus SM31 )             *
*---------------------------------------------------------------------*
*       T02_TBNAM : Tabellenname                                      *
*---------------------------------------------------------------------*
FORM TABELLE_SPERREN USING
            T02_TBNAM    TYPE C.
*ORM TABELLE_SPERREN USING T02_TBNAM.
  TBSPR  = T02_TBNAM.
  IF ENQNOCLI NE 'X'.
    ENQKEY = SY-MANDT.
  ENDIF.
  CALL FUNCTION 'ENQUEUE_E_TABLE'
       EXPORTING
            TABNAME        = TBSPR
            VARKEY         = ENQKEY
       EXCEPTIONS
            FOREIGN_LOCK   = 4
            SYSTEM_FAILURE = 8.
  CASE SY-SUBRC.
    WHEN 4.
      MESSAGE E301(F4) WITH TBSPR.
    WHEN 8.
      MESSAGE E303(F4) WITH TBSPR.
  ENDCASE.
ENDFORM.

*eject
*---------------------------------------------------------------------*
*       FORM TABELLEN_SPERREN                                         *
*---------------------------------------------------------------------*
*       Sperren aller beteiligter Tabellen.                           *
*---------------------------------------------------------------------*
FORM TABELLEN_SPERREN.

* ------ Mandantenabh?gig? --------------------------------------------
  IF ENQNOCLI = SPACE.
    ENQNOCLI = 'N'.
  ENDIF.

* ------ Generischer Schl?sel -----------------------------------------
  IF ENQGENKEY = SPACE.
    ENQGENKEY = 'N'.
  ENDIF.

* ------ Tabellen sperren ----------------------------------------------
  CALL FUNCTION 'FI_CUST_ENQUEUE_CHECK'
       EXPORTING
            I_OKCOD                  = OK-CODE
            I_OKCOD_TO_CHANGE_AKTYP  = 'AEND'
            I_TABLES                 = TABLES
            I_GENKEY                 = ENQGENKEY
            I_NOCLI                  = ENQNOCLI
       EXCEPTIONS
            FOREIGN_LOCK             = 1
            FOREIGN_LOCK_NOW_DISPLAY = 2
            SYSTEM_FAILURE           = 3.

* ------ Bearbeitung der Returncodes -----------------------------------
  CASE SY-SUBRC.
    WHEN 1.
      OK-CODE = SPACE.
      IF SY-UNAME = SY-MSGV2.
        MESSAGE E327(F4) WITH SY-MSGV1.
      ELSE.
        MESSAGE E324(F4) WITH SY-MSGV1 SY-MSGV2.
      ENDIF.
    WHEN 2.
      T020-AKTYP = 'A'.
      IF SY-UNAME = SY-MSGV1.
        MESSAGE S326(F4) WITH SY-MSGV2.
      ELSE.
        MESSAGE S325(F4) WITH SY-MSGV1 SY-MSGV2.
      ENDIF.
    WHEN 3.
      IF OK-CODE = 'AEND'.
        OK-CODE = SPACE.
        MESSAGE E303(F4) WITH SY-MSGV1.
      ELSE.
        MSGNR = '303'.
        TBSPR = SY-MSGV1.
        IF SY-TCODE(3) NE 'FI1'.
          PERFORM RETURN_TO_MENU.
        ENDIF.
      ENDIF.
  ENDCASE.
ENDFORM.

*eject
*---------------------------------------------------------------------*
*       FORM TEXT_AUS_050T                                            *
*---------------------------------------------------------------------*
*       Aus der Tabelle T050T wird der gew?schte Text bereitgestellt *
*---------------------------------------------------------------------*
*  ---> T01_TXTNR  Textnummer des zu lesenden Textes                  *
* <---  T01_ZFELD  Zielfeld fuer den gelesenen Text                   *
*---------------------------------------------------------------------*
FORM TEXT_AUS_050T USING
            T01_TXTNR    TYPE C
            T01_ZFELD    TYPE C.
*ORM TEXT_AUS_050T USING T01_TXTNR T01_ZFELD.
  SELECT SINGLE * FROM  T050T
                  WHERE SPRAS = SY-LANGU
                    AND MSGID = 'RF'
                    AND TXTNR = T01_TXTNR.
  IF SY-SUBRC = 0.
    T01_ZFELD = T050T-LTEXT.
  ELSE.
    T01_ZFELD = SPACE.
  ENDIF.
ENDFORM.

*eject
*---------------------------------------------------------------------*
*       FORM  TRANSPORT_BEGINNEN                                      *
*---------------------------------------------------------------------*
*       Er?fnen einer Korrektur.                                     *
*---------------------------------------------------------------------*
FORM TRANSPORT_BEGINNEN.
  CLEAR: OK-CODE.
  CALL FUNCTION 'FI_CUST_TRANSPORT_OPEN'
       EXPORTING
            I_CATEG = RFCU2-CATEG
       IMPORTING
            TRKORR  = E071-TRKORR.
ENDFORM.

*eject
*---------------------------------------------------------------------*
*       FORM  TRANSPORT_EINLESEN                                      *
*---------------------------------------------------------------------*
*       Einlesen des Transports.                                      *
*---------------------------------------------------------------------*
FORM TRANSPORT_EINLESEN
     USING VALUE(T03_OBJNAME) TYPE C.
  CLEAR: OK-CODE.
  REFRESH: IE071K.
  CLEAR: IE071K.
  SELECT * FROM  E071K WHERE TRKORR  = E071-TRKORR
                       AND   OBJNAME = T03_OBJNAME.
    MOVE-CORRESPONDING E071K TO IE071K.
    APPEND IE071K.
  ENDSELECT.
ENDFORM.

*eject
*---------------------------------------------------------------------*
*       FORM  TRANSPORT_EINLESEN                                      *
*---------------------------------------------------------------------*
*       Einlesen des Transports.                                      *
*---------------------------------------------------------------------*
FORM TRANSPORT_EINLESEN_NEU USING
            T01_OBJECT   LIKE RFCU2-TBNAM.
*ORM TRANSPORT_EINLESEN_NEU USING T01_OBJECT.
  CLEAR: OK-CODE.
  REFRESH: IE071.
  CLEAR: IE071.
  SELECT * FROM  E071  WHERE TRKORR  = E071-TRKORR
                       AND   OBJECT  = T01_OBJECT.
    MOVE-CORRESPONDING E071 TO IE071.
    APPEND IE071.
  ENDSELECT.
ENDFORM.

*eject
*---------------------------------------------------------------------*
*       FORM  TRANSPORT_EINTRAGEN                                     *
*---------------------------------------------------------------------*
*       Eintragen eines Transportobjekts in eine Korrektur            *
*---------------------------------------------------------------------*
* ->    T01_TBNAM: Name des logischen Objekts                         *
*---------------------------------------------------------------------*
FORM TRANSPORT_EINTRAGEN USING
            T01_TBNAM    LIKE RFCU2-TBNAM.
*ORM TRANSPORT_EINTRAGEN USING T01_TBNAM.
  CLEAR: OK-CODE.
  CALL FUNCTION 'FI_CUST_TRANSPORT_FILL'
       EXPORTING
            TBKEY  = RFCU2-TBKEY
            TBNAM  = T01_TBNAM
       IMPORTING
            TRKORR = E071-TRKORR.
ENDFORM.

*eject
*---------------------------------------------------------------------*
*       FORM  TRANSPORT_LOESCHEN                                      *
*---------------------------------------------------------------------*
*       L?chen eines Transportobjektes aus einem Transportauftrag.   *
*---------------------------------------------------------------------*
* ->    T04_OBJTYPE: Name des logischen Objektes.                     *
*---------------------------------------------------------------------*
FORM TRANSPORT_LOESCHEN USING
            T04_OBJTYPE  LIKE RFCU2-TBNAM.
*ORM TRANSPORT_LOESCHEN USING T04_OBJTYPE.
  CALL FUNCTION 'TLOGO_OBJECT_DELETE'
       EXPORTING
            KORRNR                     = E071-TRKORR
            OBJTYPE                    = T04_OBJTYPE
            OBJ_NAME                   = RFCU2-TBKEY
       EXCEPTIONS
            KORRNR_ALREADY_RELEASED    = 2
            KORRNR_LOCKED              = 3
            KORRNR_NOT_EXISTS          = 4
            KORRNR_NOT_KORR            = 5
            NO_LOGICAL_OBJECT          = 6
            OBJ_NAME_TOO_LONG_OR_SPACE = 7.
  CASE SY-SUBRC.
    WHEN  2. MESSAGE E124(AC) WITH E071-TRKORR.
    WHEN  3. MESSAGE E125(AC) WITH E071-TRKORR.
    WHEN  4. MESSAGE E126(AC) WITH E071-TRKORR.
    WHEN  5. MESSAGE E127(AC) WITH E071-TRKORR.
    WHEN  6. MESSAGE E128(AC) WITH T04_OBJTYPE.
    WHEN  7. MESSAGE E130(AC) WITH T04_OBJTYPE.
  ENDCASE.
ENDFORM.

*eject
*---------------------------------------------------------------------*
*       FORM  TRANSPORT_MELDEN                                        *
*---------------------------------------------------------------------*
*       Meldung ?er Eintrag in Korrektur                             *
*---------------------------------------------------------------------*
* ->    T01_TEXT: Text                                                *
*---------------------------------------------------------------------*
FORM TRANSPORT_MELDEN USING
            T01_TEXT     TYPE C.
*ORM TRANSPORT_MELDEN USING T01_TEXT.
  CASE RC.
    WHEN 0.
      MESSAGE S330(F4) WITH T01_TEXT E071-TRKORR.
    WHEN 2.
      MESSAGE S338(F4) WITH T01_TEXT E071-TRKORR.
    WHEN OTHERS.
      MESSAGE S336(F4).
  ENDCASE.
ENDFORM.

*eject
*---------------------------------------------------------------------*
*       FORM  TRANSPORT_ZEIGEN                                        *
*---------------------------------------------------------------------*
*       Zeigen / Editieren der Korrektureintr?e                      *
*---------------------------------------------------------------------*
* ->    T02_TBNAM: Name des logischen Objekts                         *
*---------------------------------------------------------------------*
FORM TRANSPORT_ZEIGEN USING
            T02_TBNAM    LIKE RFCU2-TBNAM.
*ORM TRANSPORT_ZEIGEN USING T02_TBNAM.
  CLEAR: OK-CODE.
  CALL FUNCTION 'FI_CUST_TRANSPORT_SHOW'
       EXPORTING
            TBNAM = T02_TBNAM.
ENDFORM.

*eject
*---------------------------------------------------------------------*
*       FORM  TR_AUTO                                                 *
*---------------------------------------------------------------------*
*       Zu ?dernden Eintrag automatisch in Auftrag schreiben lassen  *
*---------------------------------------------------------------------*
* ->    T01_TBKEY: Schl?sel                                          *
*---------------------------------------------------------------------*
FORM TR_AUTO
     USING VALUE(T01_TBKEY) TYPE C.
  RFCU2-TBKEY = T01_TBKEY.
  PERFORM TR_AUTO_FILL USING 'X' RFCU2-TBNAM RFCU2-TBKEY.
  PERFORM TR_AUTO_CHECK.
  PERFORM TR_AUTO_INSERT.
ENDFORM.

*eject
*---------------------------------------------------------------------*
*       FORM  TR_AUTO_CHECK                                           *
*---------------------------------------------------------------------*
*       TR_OBJECTS_CHECK                                              *
*---------------------------------------------------------------------*
FORM TR_AUTO_CHECK.
* 훞derung M.v.d.Emde 16.02.1998 wegen Exception-훞derungen
* ALRK082622

* Es werden nur noch die Exceptions SHOW_ONLY_OTHER_ERROR und
* CHANCEL_EDIT_OTHER_ERROR ausgel?t. Die Fehlerbehandlung
* findet per Dialop-Popup im Baustein statt.

  CHECK T020-AKTYP NE 'A'.
* Current settings
TABLES: T000, CUSAMEN.
  IF T000-MANDT <> SY-MANDT.
    SELECT SINGLE * FROM T000 WHERE mandt = sy-mandt.
    IF T000-CCCATEGORY = 'P'.
      CUSAMEN-DOC_OBJ = '%'.
      CUSAMEN-DOC_OBJ+1 = SY-TCODE.
      SELECT * FROM CUSAMEN WHERE DOC_CLS = 'SIMG'
                            AND   DOC_OBJ LIKE CUSAMEN-DOC_OBJ.
        TR_AUTO_CURRSET = 'X'.
      ENDSELECT.
    ENDIF.
  ENDIF.
  CHECK TR_AUTO_CURRSET = SPACE.

* Check transport status
  CALL FUNCTION 'TR_OBJECTS_CHECK'
       IMPORTING
            WE_OBJECTS_APPENDABLE = XAPPE
       TABLES
            WT_KO200 = AT_KO200
            WT_E071K = AT_E071K
       EXCEPTIONS
            SHOW_ONLY_OTHER_ERROR          = 01
*           show_only_consolidation_level  = 02
*           show_only_ddic_in_customer_sys = 03
*           show_only_delivery_system      = 04
*           show_only_different_ordertypes = 05
*           show_only_different_tasktypes  = 06
*           show_only_enqueue_failed       = 07
*           show_only_generated_object     = 08
*           show_only_ill_lock             = 09
*           show_only_lock_enqueue_failed  = 10
*           show_only_mixed_orders         = 11
*           show_only_mix_local_transp_obj = 12
*           show_only_no_shared_repair     = 13
*           show_only_object_locked        = 14
*           show_only_repaired_object      = 15
*           show_only_show_client          = 16
*           show_only_tadir_missing        = 17
*           show_only_unknown_devclass     = 18
*           show_only_closed_client        = 19
*           show_only_closed_ale_object    = 20
            OTHERS                         = 99.
* ------ XAPPE = ' ' hei?: kein automatischer Transport, aber
*                           manueller Transport ist noch m?lich
  XAPPE = 'X'.
  if SY-SUBRC = 0.
    if t020-aktyp = 'T'.
      t020-aktyp = 'V'.
    endif.
    exit.
  endif.
  IF SY-SUBRC BETWEEN 1 AND 98.
    MESSAGE ID     SY-MSGID
            TYPE   'S'
            NUMBER SY-MSGNO
            WITH   SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    T020-AKTYP = 'A'.
  ELSE.
    if t020-aktyp = 'T'.
      t020-aktyp = 'A'.
    endif.
    MESSAGE ID     SY-MSGID
            TYPE   SY-MSGTY
            NUMBER SY-MSGNO
            WITH   SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
*   PERFORM TABELLEN_ENTSPERREN.
    SET SCREEN 0.
    LEAVE SCREEN.
  ENDIF.
ENDFORM.

*eject
*---------------------------------------------------------------------*
*       FORM  TR_AUTO_FILL                                            *
*---------------------------------------------------------------------*
*       Eintragen eines logischen Objekts in AT_KO200                 *
*---------------------------------------------------------------------*
* ->    TA_XINIT: 'X' = REFRESH                                       *
* ->    TA_TBNAM: Name des logischen Objekts                          *
* ->    TA_TBKEY: Schl?sel                                           *
*---------------------------------------------------------------------*
FORM TR_AUTO_FILL USING
            TA_XINIT     TYPE C
            TA_TBNAM     LIKE RFCU2-TBNAM
            TA_TBKEY     LIKE RFCU2-TBKEY.
*ORM TR_AUTO_FILL USING TA_XINIT TA_TBNAM TA_TBKEY.
  IF TA_XINIT NE SPACE.
    REFRESH: AT_KO200.
  ENDIF.
  CLEAR:   AT_KO200.
  AT_KO200-PGMID        = 'R3TR'.
  AT_KO200-OBJECT       = TA_TBNAM.    "Name des log.Objekts
  AT_KO200-OBJ_NAME     = TA_TBKEY.
  APPEND AT_KO200.
ENDFORM.

*eject
*---------------------------------------------------------------------*
*       FORM  TR_AUTO_INSERT                                          *
*---------------------------------------------------------------------*
*       TR_OBJECTS_INSERT                                             *
*---------------------------------------------------------------------*
FORM TR_AUTO_INSERT.
  CHECK T020-AKTYP NE 'A'.
  CHECK TR_AUTO_CURRSET = SPACE.
*--- laufende Einstellungen sollen nicht transportiert werden --------*
  CHECK SY-TCODE NE 'OB75'.
  CALL FUNCTION 'TR_OBJECTS_INSERT'
       TABLES
            WT_KO200 = AT_KO200
            WT_E071K = AT_E071K.
ENDFORM.

*eject
*---------------------------------------------------------------------*
*       FORM  TR_AUTO                                                 *
*---------------------------------------------------------------------*
*       Zu ?dernden Eintrag automatisch in Auftrag schreiben lassen  *
*---------------------------------------------------------------------*
FORM TR_AUTO_OVERVIEW.
  CLEAR: OK-CODE.

* ------ Defaultkategorie setzen ---------------------------------------
  IF RFCU2-CATEG IS INITIAL.
    RFCU2-CATEG = 'CUST'.
  ENDIF.

* ------ TASK_OVERVIEW anzeigen ----------------------------------------
  CALL FUNCTION 'TR_TASK_OVERVIEW'
       EXPORTING
            IV_USERNAME = SY-UNAME
            IV_CATEGORY = RFCU2-CATEG
            IV_CLIENT   = SY-MANDT.
ENDFORM.

*eject
*---------------------------------------------------------------------*
*       FORM UEBERSETZEN                                              *
*---------------------------------------------------------------------*
*       ?ersetzen ( Pflege einer Texttabelle ).                      *
*---------------------------------------------------------------------*
*  ->   U01_viewname : View Name                                      *
*---------------------------------------------------------------------*
FORM UEBERSETZEN USING
            U01_VIEWNAME  TYPE C.
  DATA: VIEW_NAME LIKE DD02V-TABNAME.
*
  VIEW_NAME = U01_VIEWNAME.
  CASE T020-AKTYP.
    WHEN 'A'.
      CALL FUNCTION 'VIEW_MAINTENANCE_CALL'
           EXPORTING
                ACTION    = 'S'
                VIEW_NAME = VIEW_NAME.
    WHEN 'V'.
      CALL FUNCTION 'VIEW_MAINTENANCE_CALL'
           EXPORTING
                ACTION    = 'U'
                VIEW_NAME = VIEW_NAME.
  ENDCASE.
ENDFORM.

*eject
*---------------------------------------------------------------------*
*       FORM WECHSEL_ZUM_AENDERN                                      *
*---------------------------------------------------------------------*
*       Wechseln vom ANZEIGEN zum AENDERN.                            *
*---------------------------------------------------------------------*
FORM WECHSEL_ZUM_AENDERN.

* ------ Automatischen Transportanschlu?vorbereiten -------------------
  T020-AKTYP = 'T'.
  PERFORM TR_AUTO_FILL USING 'X' RFCU2-TBNAM '*'.
  PERFORM TR_AUTO_CHECK.
  if T020-AKTYP = 'T'.
    T020-AKTYP = 'A'.
  endif.
  CHECK T020-AKTYP NE 'A'.

* ------ Berechtigung pr?en -------------------------------------------
  T020-AKTYP = 'A'.
  PERFORM BERECHTIGUNG_PRUEFEN.

* ------ Tabellen sperren ----------------------------------------------
  PERFORM TABELLEN_SPERREN.

* ------ Alles o.k.: AKTYP = 'V' ---------------------------------------
  OK-CODE = SPACE.
  T020-AKTYP = 'V'.

* ------ EXCTAB dem neuen AKTYP anpassen -------------------------------
  PERFORM EXCTAB_STANDARD.
ENDFORM.

*eject
*&---------------------------------------------------------------------*
*&      Form  MARK_WRITE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_NAME   text
*----------------------------------------------------------------------*
FORM VIEW_MARK_WRITE USING  P_NAME  LIKE OBJS-OBJECTNAME
                            P_BEGIN LIKE BOOLE-BOOLE.


  CALL FUNCTION 'VIEW_MARK_WRITE'
       EXPORTING
            OBJNAME = P_NAME
            BEGIN   = P_BEGIN.
*         OBJTYPE   = 'T'
*    TABLES
*         DDOBJECTS =.

ENDFORM.                               " MARK_WRITE
