************************************************************************
*                                                                      *
* Title         : ZTIRI010                                             *
*                                                                      *
* Description   : [Report] 수입모듈별 TEXT ID Dialog Module Call       *
*                                                                      *
* Creation Date : 2004/02/09                                           *
*                                                                      *
* Author        : Seog Bong, Kang                                      *
*                 Copyright ⓒ ASEG Co., LTD. All rights reserved.     *
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
*----------------------------------------------------------------------*
*                M O D I F I C A T I O N   L O G                       *
*----------------------------------------------------------------------*
* Date         Programmer       Transport#  Description                *
*----------------------------------------------------------------------*
*                                                                      *
*                                                                      *
************************************************************************
PROGRAM   ztiri010
          MESSAGE-ID f4
          NO STANDARD PAGE HEADING.


INCLUDE <icon>.

*-----------------------------------------------------------------------
*        Tabellen
*-----------------------------------------------------------------------
TABLES:  ttxob,                                  " Textobjekte
         ttxot,                                  " ... Bezeichnung
         ttxid,                                  " Textarten
         ttxit,                                  " ... Bezeichnung
         ttxern.                                  " Erlaubte Text-IDs

TABLES:  rftxt.                                  " Dynprofelder

*-----------------------------------------------------------------------
*       Datenfelder f? das Programm SAPDFKT1.
*       ---------------------------------------
*       Teil 1 :  Tabellen      ( BEGIN OF ... OCCURS )
*       Teil 2 :  Strukturen    ( BEGIN OF ... )
*       Teil 3 :  Einzelfelder  ( variabel )
*       Teil 4 :  Konstanten
*-----------------------------------------------------------------------

*eject
*-----------------------------------------------------------------------
*       Teil 1 :  Tabellen      ( BEGIN OF ... OCCURS )
*-----------------------------------------------------------------------

* ------ Tabelle der Textarten f? Transport --------------------------
DATA:    BEGIN OF tttxid OCCURS 10.
        INCLUDE STRUCTURE ttxid.
DATA:      tdtext            LIKE ttxit-tdtext.
DATA:      xtxer             LIKE rftxt-xtxer.   " Text erlaubt
DATA:      xmark             LIKE rfcu2-xmark.   " Auswahl
DATA:      xdrin             LIKE rfcu2-xmark.   " Eingetragen?
DATA:    END   OF tttxid.

* ------ Tabelle der Textarten ----------------------------------------
DATA:    BEGIN OF xttxid OCCURS 10.
        INCLUDE STRUCTURE ttxid.
DATA:      tdtext            LIKE ttxit-tdtext.
DATA:      xtxer             LIKE rftxt-xtxer.   " Text erlaubt
DATA:      aktyp(1)          TYPE c.
DATA:    END   OF xttxid.

* ------ Tabelle der Textarten (SAVE-Stand) ---------------------------
DATA:    BEGIN OF yttxid OCCURS 10.
        INCLUDE STRUCTURE ttxid.
DATA:      tdtext            LIKE ttxit-tdtext.
DATA:      xtxer             LIKE rftxt-xtxer.   " Text erlaubt
DATA:    END   OF yttxid.

*eject
*-----------------------------------------------------------------------
*       Teil 2 :  Strukturen    ( BEGIN OF ... )
*-----------------------------------------------------------------------

* ------ Ausgew?lte Schl?selfelder -----------------------------------
DATA:    BEGIN OF ausw,
           dummy(1)          TYPE c,             " Dummy wg. DFKB0CPF
         END   OF ausw.

*------- Importierte Voreinstellungen ---------------------------------
DATA:    BEGIN OF imp,
          objct              LIKE ttxob-tdobject, " Textobjekt
          applk(2)           TYPE c,              " Applikation
         END   OF imp.

* ------ Alter Inhalt einzelner Felder ---------------------------------
DATA:    BEGIN OF old,
           okcod(4)          TYPE c,             " OK-Code
         END   OF old.

*------- Steuerungsfelder ---------------------------------------------
DATA:    BEGIN OF text,
           xchng(1)          TYPE c,              " 훞derungen?
           xinit(1)          TYPE c,              " Initialisierung?
         END   OF text.

*eject
*-----------------------------------------------------------------------
*       Teil 3 :  Einzelfelder
*-----------------------------------------------------------------------
DATA:   n(3)                 TYPE c,             " Z?ler
        l_objct              LIKE imp-objct.

*eject
*-----------------------------------------------------------------------
*       Teil 4 :  Konstanten
*-----------------------------------------------------------------------
DATA:   schema               LIKE ttxern-txtgr,   " Aktuelles Schema
        schema_rf            LIKE ttxern-txtgr    " Default-Schema RF
                               VALUE '* ',
        schema_rm            LIKE ttxern-txtgr    " Default-Schema RM
                               VALUE '% '.

*------- Liste der zu sperrenden Tabellen -----------------------------
DATA:   tables(100)          TYPE c
          VALUE 'TTXIDTTXITTTXERT9999'.

************************************************************************
* SAP Include Define                                                   *
************************************************************************
CLASS lcl_application DEFINITION DEFERRED.
CLASS cl_gui_cfw DEFINITION LOAD.

* CAUTION: MTREEITM is the name of the item structure which must
* be defined by the programmer. DO NOT USE MTREEITM!
TYPES: item_table_type LIKE STANDARD TABLE OF mtreeitm
       WITH DEFAULT KEY.

DATA: g_application TYPE REF TO lcl_application,
      g_custom_container TYPE REF TO cl_gui_custom_container,
      g_tree TYPE REF TO cl_gui_column_tree,
      g_ok_code TYPE sy-ucomm.

* Fields on Dynpro 100
DATA: g_event(30),
      g_node_key(30) TYPE c,
      g_item_name    TYPE tv_itmname,
      g_header_name  TYPE tv_hdrname.

DATA: item_table     TYPE treemcitab,
      item           TYPE treemcitem,
      node_key       TYPE tm_nodekey.


************************************************************************
* CLASSES: Definition                                                  *
************************************************************************
CLASS lcl_application DEFINITION.

  PUBLIC SECTION.
    METHODS:
      handle_node_double_click
        FOR EVENT node_double_click
        OF cl_gui_column_tree
        IMPORTING node_key,
      handle_header_click
        FOR EVENT header_click
        OF cl_gui_column_tree
        IMPORTING header_name,
*      HANDLE_EXPAND_NO_CHILDREN
*        FOR EVENT EXPAND_NO_CHILDREN
*        OF CL_GUI_COLUMN_TREE
*        IMPORTING NODE_KEY,
      handle_item_double_click
        FOR EVENT item_double_click
        OF cl_gui_column_tree
        IMPORTING node_key item_name,
      handle_button_click
        FOR EVENT button_click
        OF cl_gui_column_tree
        IMPORTING node_key item_name,
      handle_link_click
        FOR EVENT link_click
        OF cl_gui_column_tree
        IMPORTING node_key item_name,
      handle_checkbox_change
        FOR EVENT checkbox_change
        OF cl_gui_column_tree
        IMPORTING node_key item_name checked.
ENDCLASS.                    "lcl_application DEFINITION
************************************************************************
* CLASSES: IMPLEMENTATION
************************************************************************
CLASS lcl_application IMPLEMENTATION.

  METHOD handle_node_double_click.
    " this method handles the node double click event of the tree
    " model instance

    " show the key of the double clicked node in a dynpro field
    g_event = 'NODE_DOUBLE_CLICK'.
    g_node_key = node_key.
    CLEAR: g_item_name, g_header_name.

    PERFORM display_selected_node_info  USING g_node_key.

  ENDMETHOD.                    "handle_node_double_click

  METHOD handle_header_click.
    " this method handles header click event of the tree
    " model instance

    " show the name of the clicked header in a dynpro field
    g_event = 'HEADER_CLICK'.
    g_header_name = header_name.
    CLEAR: g_node_key, g_item_name.
  ENDMETHOD.                    "handle_header_click

  METHOD  handle_item_double_click.
    " this method handles the item double click event of the tree
    " model instance

    " show the key of the node and the name of the item
    " of the double clicked item in a dynpro field
    g_event = 'ITEM_DOUBLE_CLICK'.
    g_node_key = node_key.
    g_item_name = item_name.
    CLEAR g_header_name.

    PERFORM display_selected_node_info  USING g_node_key.
*    PERFORM handle_button_click.
  ENDMETHOD.                    "handle_item_double_click

  METHOD  handle_link_click.
    " this method handles the link click event of the tree
    " model instance

    " show the key of the node and the name of the item
    " of the clicked link in a dynpro field
    g_event = 'LINK_CLICK'.
    g_node_key = node_key.
    g_item_name = item_name.
    CLEAR g_header_name.

  ENDMETHOD.                    "handle_link_click

  METHOD  handle_button_click.
    " this method handles the button click event of the tree
    " model instance

    " show the key of the node and the name of the item
    " of the clicked button in a dynpro field
    g_event = 'BUTTON_CLICK'.
    g_node_key = node_key.
    g_item_name = item_name.
    CLEAR g_header_name.

*    PERFORM handle_button_click.

  ENDMETHOD.                    "handle_button_click

  METHOD  handle_checkbox_change.
    " this method handles the checkbox_change event of the tree
    " model instance

    " show the key of the node and the name of the item
    " of the clicked checkbox in a dynpro field
    g_event = 'CHECKBOX_CHANGE'.
    g_node_key = node_key.
    g_item_name = item_name.
    CLEAR  g_header_name.
  ENDMETHOD.                    "handle_checkbox_change

ENDCLASS.                    "lcl_application IMPLEMENTATION



* ------ Gemeinsame Includes f? KONFIGURATION BUCHHALTUNG -------------
INCLUDE ztiri010top.                                " Datenfelder
INCLUDE ztiri010f01.                                " Forms + Module
INCLUDE ztiri010f02.                                " Forms + Module

************************************************************************
* START-OF-SELECTION Event                                             *
************************************************************************
START-OF-SELECTION.

* create the application object
* this object is needed to handle the ABAP Objects Events of
* Controls
  CREATE OBJECT g_application.

  CALL SCREEN 100.

*eject
************************************************************************
*                                                                      *
* P B O   M O D U L E                                                  *
*                                                                      *
************************************************************************
*---------------------------------------------------------------------*
*       MODULE  D0110_EINTRAG_ZEIGEN                                  *
*---------------------------------------------------------------------*
*       Ein Eintrag aus der Tabelle XTTXID wird angezeigt.            *
*---------------------------------------------------------------------*
MODULE d0110_eintrag_zeigen OUTPUT.
  IF sy-stepl = 1.
    lncnt = sy-loopc.
    lncur = lnfir.
  ENDIF.

* ------ Eintrag aus XTTXID lesen und anzeigen -------------------------
  READ TABLE xttxid INDEX lncur.
  IF sy-subrc = 0.
    MOVE-CORRESPONDING xttxid TO ttxid.
    MOVE-CORRESPONDING xttxid TO ttxit.
    rftxt-xtxer = xttxid-xtxer.
    lncur = lncur + 1.
  ELSE.
    EXIT FROM STEP-LOOP.
  ENDIF.
ENDMODULE.                    "D0110_EINTRAG_ZEIGEN OUTPUT

*---------------------------------------------------------------------*
*       MODULE  D0910_EINTRAG_ZEIGEN                                  *
*---------------------------------------------------------------------*
*       Ein Eintrag aus der Tabelle TTTXID wird angezeigt.            *
*---------------------------------------------------------------------*
MODULE d0910_eintrag_zeigen OUTPUT.
  IF sy-stepl = 1.
    lncnt = sy-loopc.
    lncur = lnfir.
  ENDIF.

* ------ Eintrag aus TTTXID lesen und anzeigen -------------------------
  READ TABLE tttxid INDEX lncur.
  IF sy-subrc = 0.
    MOVE-CORRESPONDING tttxid TO ttxid.
    MOVE-CORRESPONDING tttxid TO ttxit.
    rfcu2-xmark = tttxid-xmark.
    lncur = lncur + 1.
    IF rfcu2-xmark NE space.
      PERFORM screen_intensified.
    ENDIF.
  ELSE.
    EXIT FROM STEP-LOOP.
  ENDIF.
ENDMODULE.                    "D0910_EINTRAG_ZEIGEN OUTPUT
*---------------------------------------------------------------------*
*       MODULE  DIALOG_INIT                                           *
*---------------------------------------------------------------------*
*       Initialisierung                                               *
*---------------------------------------------------------------------*
MODULE dialog_init OUTPUT.
  PERFORM initialisierung.
ENDMODULE.                    "DIALOG_INIT OUTPUT

*---------------------------------------------------------------------*
*       MODULE  DYNPRO_MODIFIZIEREN                                   *
*---------------------------------------------------------------------*
*       Die Eingabebereitschaft wird weggenommen im ANZEIGEN.         *
*---------------------------------------------------------------------*
MODULE dynpro_modifizieren OUTPUT.
  PERFORM eingabebereitschaft_aus.
ENDMODULE.                    "DYNPRO_MODIFIZIEREN OUTPUT
*---------------------------------------------------------------------*
*       MODULE PBO                                                    *
*---------------------------------------------------------------------*
*       Meldung, wenn noch keine Text-IDs gepflegt.                   *
*---------------------------------------------------------------------*
MODULE pbo OUTPUT.
  DESCRIBE TABLE xttxid LINES lnmax.
  IF lnmax = 0.
    MESSAGE s571 WITH imp-objct.
  ENDIF.
ENDMODULE.                    "PBO OUTPUT
*---------------------------------------------------------------------*
*       MODULE STATUS                                                 *
*---------------------------------------------------------------------*
*       Der PF-Status wird aus der Dynpronummer und dem AKTYP         *
*       zusammengesetzt.                                              *
*---------------------------------------------------------------------*
MODULE status OUTPUT.
  pfkey = space.
  UNPACK sy-dynnr TO char(4).
  pfkey(3) = char+1(3).
  SET PF-STATUS pfkey EXCLUDING exctab.
ENDMODULE.                    "STATUS OUTPUT
*---------------------------------------------------------------------*
*       MODULE STATUS_POPUP                                           *
*---------------------------------------------------------------------*
*       Der PF-Status wird aus der Dynprogruppe gesetzt.              *
*---------------------------------------------------------------------*
MODULE status_popup OUTPUT.
  SET PF-STATUS sy-dyngr.
ENDMODULE.                    "STATUS_POPUP OUTPUT
*---------------------------------------------------------------------*
*       MODULE TITEL                                                  *
*---------------------------------------------------------------------*
*       Der TITEL wird ermittelt und gesetzt.                         *
*---------------------------------------------------------------------*
MODULE titel OUTPUT.

* ------ Aktivit?styp -------------------------------------------------
  CASE t020-aktyp.
    WHEN 'A'.
      SET TITLEBAR 'T01'.
    WHEN 'V'.
      IF sy-dynnr = 910.
        SET TITLEBAR 'T03'.
      ELSE.
        SET TITLEBAR 'T02'.
      ENDIF.
  ENDCASE.
ENDMODULE.                    "TITEL OUTPUT
*---------------------------------------------------------------------*
*       MODULE TITEL_POPUP                                            *
*---------------------------------------------------------------------*
*       Der TITEL einer modalen Dialogbox wird gesetzt.               *
*---------------------------------------------------------------------*
MODULE titel_popup OUTPUT.
  CASE sy-dynnr.
    WHEN 1001. SET TITLEBAR 'P01'.
  ENDCASE.
ENDMODULE.                    "TITEL_POPUP OUTPUT


************************************************************************
*                                                                      *
* P B O   M O D U L E                                                  *
*                                                                      *
************************************************************************
*&---------------------------------------------------------------------*
*&      Module  PBO_scr0100  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE pbo_scr0100 OUTPUT.

  SET PF-STATUS 'STATUS100'.
  SET TITLEBAR 'T1000' WITH '수입'(t10).

*  SET PF-STATUS 'MAIN'.
  IF g_tree IS INITIAL.
    " The Tree Model has not been created yet.
    " Create a Tree Model and insert nodes into it.
    PERFORM create_and_init_tree_0100.
  ENDIF.

ENDMODULE.                 " PBO_scr0100  OUTPUT




*eject
************************************************************************
*                                                                      *
* P A I   M O D U L E                                                  *
*                                                                      *
************************************************************************
*---------------------------------------------------------------------*
*       MODULE  D0910_MERKEN                                          *
*---------------------------------------------------------------------*
*       Ausgew?lte Text-ID in TTTXID merken.                         *
*---------------------------------------------------------------------*
MODULE d0910_merken.
  LOOP AT tttxid WHERE tdid  = ttxid-tdid.
    tttxid-xmark = rfcu2-xmark.
    MODIFY tttxid.
  ENDLOOP.
ENDMODULE.                    "D0910_MERKEN

*eject
*---------------------------------------------------------------------*
*       MODULE  D0910_OKCODE                                          *
*---------------------------------------------------------------------*
*       Eintragen der markierten Objekte in die Korrektur.            *
*---------------------------------------------------------------------*
MODULE d0910_okcode.

* ------ Bl?tern ?er SCROLL-Bar --------------------------------------
  IF  tbcur NE lnfir
  AND tbcur GT 0.
    lnfir = tbcur.
    PERFORM stehenbleiben.
  ENDIF.
  CASE ok-code.

* ------ Alle markieren ------------------------------------------------
    WHEN 'MALL'.
      LOOP AT tttxid.
        tttxid-xmark = 'X'.
        MODIFY tttxid.
      ENDLOOP.

* ------ Mark./Mark.l?chen --------------------------------------------
    WHEN 'MARK'.
      GET CURSOR FIELD dy-field LINE dy-linno.
      PERFORM check_cursor.
      tabix = lnfir + dy-linno - 1.
      READ TABLE tttxid INDEX tabix.
      IF sy-subrc = 0.
        TRANSLATE tttxid-xmark USING 'X  X'.
        MODIFY tttxid INDEX tabix.
      ENDIF.

* ------ Alle Mark. l?chen --------------------------------------------
    WHEN 'RALL'.
      LOOP AT tttxid.
        tttxid-xmark = ' '.
        MODIFY tttxid.
      ENDLOOP.

* ------ Transport eintragen -------------------------------------------
    WHEN 'TREI'.
      rc = 4.
      LOOP AT tttxid WHERE xmark = 'X'
                     OR    xdrin = 'X'.
        CHECK tttxid-xmark NE tttxid-xdrin.
        rc            = 0.
        rfcu2-tbkey    = rftxt-tdobject.
        rfcu2-tbkey+10 = tttxid-tdid.
        IF tttxid-xmark = space.
          PERFORM transport_loeschen  USING 'FXID'.
          tttxid-xdrin = space.
          MODIFY tttxid.
        ELSE.
          PERFORM transport_eintragen USING 'FXID'.
        ENDIF.
      ENDLOOP.

* ------ TTXER mitnehmen, wenn es 훞derungen gab -----------------------
      IF rc = 0.
        PERFORM transport_beginnen.
        CLEAR: rfcu2-tbkey.
        rfcu2-tbkey    = rftxt-tdobject.
        rfcu2-tbkey+10 = schema.
        PERFORM transport_eintragen USING 'FXER'.
      ENDIF.
      PERFORM transport_melden USING text-001.
      PERFORM dynpro_0110_zeigen.

* ------ TASK_OVERVIEW ------------------------------------------------
    WHEN 'TROW'.
      PERFORM tr_auto_overview.
  ENDCASE.

* ------ Bl?tern ------------------------------------------------------
  IF ok-code CA '+-'.
    PERFORM blaettern_neu USING lnfir lnmax lncnt.
  ENDIF.
  CLEAR: ok-code.
ENDMODULE.                    "D0910_OKCODE

*eject
*---------------------------------------------------------------------*
*       MODULE  D1001_PRUEFEN                                         *
*---------------------------------------------------------------------*
*       Die neue Textart darf noch nicht vorhanden sein.              *
*---------------------------------------------------------------------*
MODULE d1001_pruefen.
  PERFORM lesen_xttxid.
  IF sy-subrc = 0.
    MESSAGE e570 WITH ttxid-tdid.
  ENDIF.
ENDMODULE.                    "D1001_PRUEFEN

*eject
*---------------------------------------------------------------------*
*       MODULE  EXIT                                                  *
*---------------------------------------------------------------------*
*        Generelles EXIT-Modul f? F15 und F17                        *
*---------------------------------------------------------------------*
MODULE exit.
  IF sy-dyngr(1) = 'W'.
    SET SCREEN 0.
    LEAVE SCREEN.
  ELSE.
    CASE ok-code.
      WHEN 'F15'.
        PERFORM okcode_f15_spezial.
      WHEN 'F17'.
        PERFORM okcode_f17_spezial.
      WHEN 'T12'.
        LOOP AT tttxid WHERE xmark NE space.
          CLEAR: tttxid-xmark.
          MODIFY tttxid.
        ENDLOOP.
        SET SCREEN 110.
        LEAVE SCREEN.
    ENDCASE.
  ENDIF.
ENDMODULE.                    "EXIT

*eject
*---------------------------------------------------------------------*
*       MODULE  LOESCHEN                                              *
*---------------------------------------------------------------------*
*       Im STEP-LOOP: Ein Eintrag wird gel?cht.                      *
*---------------------------------------------------------------------*
MODULE loeschen.
  CHECK ok-code  = 'DELE'.
  CHECK dy-linno = sy-stepl.
  PERFORM lesen_xttxid.
  DELETE xttxid INDEX tabix.
ENDMODULE.                    "LOESCHEN

*eject
*---------------------------------------------------------------------*
*       MODULE  MERKEN                                                *
*---------------------------------------------------------------------*
*       Im STEP-LOOP: Die Tabelle XTTXID wird aktualisiert.           *
*---------------------------------------------------------------------*
MODULE merken.
  xttxid        = ttxid.
  xttxid-tdtext = ttxit-tdtext.
  xttxid-xtxer  = rftxt-xtxer.
  lncur  = lnfir + sy-stepl - 1.
  MODIFY xttxid INDEX lncur.
ENDMODULE.                    "MERKEN

*eject
*---------------------------------------------------------------------*
*       MODULE  OKCODE_BEARBEITUNG                                    *
*---------------------------------------------------------------------*
*       ENTER: Stehenbleiben                                          *
*                                                                     *
*       BACK:  Zur?k.                                                *
*       DELE:  L?chen einer Textart.                                 *
*       INSE:  Hinzuf?en einer neuen Textart.                        *
*                                                                     *
*       Pnn:   Bl?tern.                                              *
*---------------------------------------------------------------------*
MODULE okcode_bearbeitung.

* ------ Bl?tern ?er Scrollbar ---------------------------------------
  IF  tbcur NE lnfir
  AND tbcur GT 0.
    lnfir = tbcur.
    PERFORM stehenbleiben.
  ENDIF.
  CASE ok-code.

* ------ Stehenbleiben -------------------------------------------------
    WHEN space.
      PERFORM stehenbleiben.

* ------ Wechsel zum AENDERN -------------------------------------------
    WHEN 'AEND'.
      PERFORM wechsel_zum_aendern.
      PERFORM lesen_ttxid.

* ------ Zur?k --------------------------------------------------------
    WHEN 'BACK'.
      ok-code = space.
      PERFORM check_aenderung.
      IF text-xchng NE space
      OR sy-datar   NE space.
        PERFORM datenverlust_mit_sichern USING text-pt5.
      ENDIF.
      PERFORM tabellen_entsperren.
      PERFORM return_to_menu.

* ------ L?chen einer Textart -----------------------------------------
    WHEN 'DELE'.
      ok-code = space.

* ------ Neue Textart einf?en ----------------------------------
    WHEN 'INSE'.
      PERFORM einfuegen.

* ------ Transport beginnen --------------------------------------------
    WHEN 'TRBG'.
      PERFORM transport_beginnen.
      READ TABLE tttxid INDEX 1.
      IF sy-subrc NE 0.
        REFRESH: tttxid.
        LOOP AT xttxid.
          MOVE-CORRESPONDING xttxid TO tttxid.
          APPEND tttxid.
        ENDLOOP.
      ENDIF.
      PERFORM transport_einlesen_neu USING 'FXID'.
      LOOP AT ie071.
        LOOP AT tttxid.
          CHECK tttxid-tdobject = ie071-obj_name(10)
            AND tttxid-tdid     = ie071-obj_name+10(4).
          tttxid-xmark = 'X'.
          tttxid-xdrin = 'X'.
          MODIFY tttxid.
        ENDLOOP.
      ENDLOOP.
      PERFORM dynpro_0910_zeigen.

* ------ TASK_OVERVIEW ------------------------------------------------
    WHEN 'TROW'.
      PERFORM tr_auto_overview.

* ------ Sichern ------------------------------------------------
    WHEN 'UPDA'.
      PERFORM check_aenderung.
      IF text-xchng = space.
        MESSAGE s311.
      ELSE.
        PERFORM update.
      ENDIF.
  ENDCASE.

* ------ Anzahl aktueller Eintr?e -------------------------------------
  DESCRIBE TABLE xttxid LINES lnmax.
  rftxt-total = lnmax.

* ------ Bl?tern ------------------------------------------------------
  IF ok-code CA '+-'.
    PERFORM blaettern_neu USING lnfir lnmax lncnt.
  ENDIF.
ENDMODULE.                    "OKCODE_BEARBEITUNG


*&---------------------------------------------------------------------*
*&      Module  PAI_scr0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE pai_scr0100 INPUT.

  DATA: return_code TYPE i.
* CL_GUI_CFW=>DISPATCH must be called if events are registered
* that trigger PAI
* this method calls the event handler method of an event
  CALL METHOD cl_gui_cfw=>dispatch
    IMPORTING
      return_code = return_code.
  IF return_code <> cl_gui_cfw=>rc_noevent.
    " a control event occured => exit PAI
    CLEAR g_ok_code.
    EXIT.
  ENDIF.

  CASE sy-ucomm.
    WHEN 'EXIT' OR 'CANC' OR 'BACK'.
      IF NOT g_custom_container IS INITIAL.
        " destroy tree container (detroys contained tree control, too)
        CALL METHOD g_custom_container->free
          EXCEPTIONS
            cntl_system_error = 1
            cntl_error        = 2.
        IF sy-subrc <> 0.
          MESSAGE a000(TREE_CONTROL_MSG).
        ENDIF.
        CLEAR g_custom_container.
        CLEAR g_tree.
      ENDIF.

      SET SCREEN 0.
      LEAVE SCREEN.
  ENDCASE.

* CAUTION: clear ok code!
  CLEAR g_ok_code.

ENDMODULE.                 " PAI_scr0100  INPUT


*eject
******** FORM-Routinen *************************************************

*eject
*---------------------------------------------------------------------*
*       FORM  CHECK_AENDERUNG                                         *
*---------------------------------------------------------------------*
*       Es wird untersucht, ob sich in der Tabelle XTTXID             *
*       Daten ge?dert haben.                                         *
*---------------------------------------------------------------------*
FORM check_aenderung.

* ------ Neue Eintr?e in XTTXID? --------------------------------------
  DESCRIBE TABLE xttxid LINES refe1.
  DESCRIBE TABLE yttxid LINES sy-tfill.
  IF refe1 NE sy-tfill.
    text-xchng = 'X'.
  ENDIF.

* ------ Ge?derte Eintr?e in XTTXID? ---------------------------------
* CHECK RC = 0.
  LOOP AT xttxid.
    PERFORM lesen_yttxid.
    IF tabix = 0.
      text-xchng = 'X'.                        " Neu
    ELSE.
      IF xttxid NE yttxid.
        text-xchng = 'X'.                      " Ge?dert
      ENDIF.
    ENDIF.
  ENDLOOP.
ENDFORM.                    "CHECK_AENDERUNG

*eject
*---------------------------------------------------------------------*
*       FORM  DATEN_AKTUALISIEREN                                     *
*---------------------------------------------------------------------*
*       Nach einem UPDATE werden die Daten aus der X-Tabelle          *
*       in die Y-Tabelle gestellt.                                    *
*---------------------------------------------------------------------*
FORM daten_aktualisieren.
  REFRESH: yttxid.
  LOOP AT xttxid.
    CLEAR xttxid-aktyp.
    MODIFY xttxid.
    yttxid = xttxid.
    APPEND yttxid.
  ENDLOOP.
  CLEAR: text-xchng.
ENDFORM.                    "DATEN_AKTUALISIEREN

*eject
*---------------------------------------------------------------------*
*       FORM  DATENVERLUST_MIT_SICHERN                                *
*---------------------------------------------------------------------*
*       Pr?e, ob ungesicherte 훞derungen vorliegen.                  *
*       Wenn ja, wird im Dialogfenster gefragt, ob die Daten          *
*       vorher gesichert werden sollen.                               *
*       Dies geht nur bei OK-Codes, die nicht auf EXIT-COMMAND liegen.*
*---------------------------------------------------------------------*
FORM datenverlust_mit_sichern USING
            v01_titel    TYPE c.
*ORM DATENVERLUST_MIT_SICHERN USING V01_TITEL.
  ok-code = space.

* ------ Ungesicherte 훞derungen ? -------------------------------------
  CHECK t020-aktyp EQ 'V'.
  PERFORM check_aenderung.
  CHECK text-xchng = 'X'.

* ------ Frage im Dialogfenster stellen --------------------------------
  CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
    EXPORTING
      titel     = v01_titel
      textline1 = text-p41
      textline2 = text-p42
    IMPORTING
      answer    = answer.

* ------ Antwort verarbeiten -------------------------------------------
  CASE answer.
    WHEN 'A'.
      PERFORM stehenbleiben.
    WHEN 'J'.
      PERFORM update.
  ENDCASE.
ENDFORM.                    "DATENVERLUST_MIT_SICHERN

*eject
*---------------------------------------------------------------------*
*       FORM  DATENVERLUST_OHNE_SICHERN                               *
*---------------------------------------------------------------------*
*       Pr?e, ob ungesicherte 훞derungen vorliegen.                  *
*       Wenn ja, wird im Dialogfenster gefragt, ob die Verarbeitung   *
*       fortgesetzt oder (ohne Sichern) beendet werden soll.          *
*       Ein Sichern aus dem Dialogfenster ist nicht unterst?zt.      *
*       Dies gilt f? die OK-Codes, die auf EXIT-COMMAND liegen.      *
*---------------------------------------------------------------------*
FORM datenverlust_ohne_sichern USING
            d02_titel    TYPE c.
*ORM DATENVERLUST_OHNE_SICHERN USING D02_TITEL.

* ------ Ungesicherte 훞derungen ? -------------------------------------
  CHECK t020-aktyp EQ 'V'.
  PERFORM check_aenderung.
  CHECK text-xchng = 'X'
     OR sy-datar   = 'X'.

* ------ Frage im Dialogfenster stellen --------------------------------
  CALL FUNCTION 'POPUP_TO_CONFIRM_LOSS_OF_DATA'
    EXPORTING
      titel     = d02_titel
      textline1 = text-p11
      textline2 = text-p12
    IMPORTING
      answer    = answer.

* ------ Weiterbearbeiten ----------------------------------------------
  IF answer = 'N'
  OR answer = 'A'.
    ok-code = space.
    PERFORM stehenbleiben.
  ENDIF.
ENDFORM.                    "DATENVERLUST_OHNE_SICHERN

*eject
*---------------------------------------------------------------------*
*       FORM  DYNPRO_0110_ZEIGEN                                      *
*---------------------------------------------------------------------*
*       Dynpro 0110 zeigen.                                           *
*---------------------------------------------------------------------*
FORM dynpro_0110_zeigen.
ENDFORM.                    "DYNPRO_0110_ZEIGEN

*eject
*---------------------------------------------------------------------*
*       FORM  DYNPRO_0910_ZEIGEN                                      *
*---------------------------------------------------------------------*
*       Liste der transportierbaren Text-IDs anzeigen.                *
*---------------------------------------------------------------------*
FORM dynpro_0910_zeigen.
  DESCRIBE TABLE tttxid LINES lnmax.
  IF lnmax = 0.
    MESSAGE s571 WITH imp-objct.
  ENDIF.

* ------ Dynpro 910 aufrufen -------------------------------------------
  SET SCREEN 910.
  LEAVE SCREEN.
ENDFORM.                    "DYNPRO_0910_ZEIGEN

*eject
*---------------------------------------------------------------------*
*       FORM  EINFUEGEN                                               *
*---------------------------------------------------------------------*
*       Neue  Textart hinzuf?en                                      *
*---------------------------------------------------------------------*
FORM einfuegen.
  CLEAR ok-code.
  CLEAR: ttxid, ttxit.
  PERFORM call_screen USING 'SAPDFKT1' 'INSE'.

* ------ Wenn ABBRECHEN -> Stehenbleiben, sonst: zur Pflege ------------
  IF ok-code = 'F12'.
    ok-code = space.
    PERFORM stehenbleiben.
  ELSE.
    CLEAR: xttxid.
    MOVE-CORRESPONDING ttxid TO xttxid.
    xttxid-tdtext   = ttxit-tdtext.
    xttxid-tdobject = imp-objct.
    APPEND xttxid.
    SORT xttxid.
  ENDIF.
ENDFORM.                    "EINFUEGEN

*eject
*---------------------------------------------------------------------*
*       FORM  INITIALISIERUNG                                         *
*---------------------------------------------------------------------*
*       Tabellen TTXID / TTXIT / TTXER lesen und in interne           *
*       Tabellen stellen.                                             *
*       Alle beteiligten Tabellen sperren.                            *
*---------------------------------------------------------------------*
FORM initialisierung.
  CHECK text-xinit = space.

* ------ Berechtigung pr?en -------------------------------------------
  PERFORM berechtigung_pruefen.

* ------ Berechtigungspr?ung / Hinweis wegen Mandantenunabh?gigkeit --
  CALL FUNCTION 'FI_CUST_CLIENT_CHECK'
    EXCEPTIONS
      OTHERS = 1.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE 'I' NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
*    LEAVE TO SCREEN 0.
  ENDIF.

* ------ Transportobjekt setzen (FXID, da mandantenUNabh?gig -> CUSY) -
  rfcu2-tbnam = 'FXID'.
  trobj       = 'FXID'.
  rfcu2-categ = 'SYST'.

* ------ Automatischen Transportanschlu?vorbereiten -------------------
  PERFORM tr_auto_fill USING 'X' rfcu2-tbnam '*'.
  PERFORM tr_auto_check.

* ------ Sperren -------------------------------------------------------
  IF t020-aktyp = 'V'.
    PERFORM tabellen_sperren.
  ENDIF.

* ------ Schema setzen -------------------------------------------------
  CASE imp-applk.
    WHEN 'RF'.
      schema = schema_rf.
    WHEN 'RM'.
      schema = schema_rm.
    WHEN OTHERS.
      MESSAGE a308 WITH 'INITIALISIERUNG - IMP-APPLK' imp-applk.
  ENDCASE.

* ------ Daten einlesen ------------------------------------------------
  PERFORM lesen_ttxid.

* ------ Text 'Sicht der ... ' -----------------------------------------
  CLEAR: rftxt-text1.
  IF imp-objct = 'LFA1'.
    CASE imp-applk.
      WHEN 'RF'.
        rftxt-text1 = text-002.
      WHEN 'RM'.
        rftxt-text1 = text-003.
    ENDCASE.
  ENDIF.

* ------ Anzeigefelder setzen ------------------------------------------
  rftxt-tdobject = imp-objct.
  SELECT SINGLE * FROM  ttxot
                  WHERE tdspras  = sy-langu
                  AND   tdobject = imp-objct.
  IF sy-subrc = 0.
    rftxt-tdtext = ttxot-tdtext.
  ELSE.
    rftxt-tdtext = space.
  ENDIF.
  DESCRIBE TABLE xttxid LINES lnmax.
  lnfir = 1.
  rftxt-first = 1.
  rftxt-total = lnmax.

* ------ Unzul?sige OK-Codes in EXCTAB aufnehmen ----------------------
  PERFORM exctab_standard.

* ------ Initialisierung durchgef?rt ----------------------------------
  text-xinit = 'X'.
ENDFORM.                    "INITIALISIERUNG

*eject
*---------------------------------------------------------------------*
*       FORM  LESEN_TTXID                                             *
*---------------------------------------------------------------------*
*       Daten einlesen.                                               *
*---------------------------------------------------------------------*
FORM lesen_ttxid.
  CLEAR:   xttxid, yttxid.
  REFRESH: xttxid, yttxid.
  SELECT * FROM  ttxid
           WHERE tdobject = imp-objct.
    xttxid = ttxid.
    PERFORM ttxit_lesen USING ttxid-tdid.
    xttxid-tdtext = ttxit-tdtext.
    PERFORM ttxer_lesen USING ttxid-tdid.
    APPEND xttxid.
    IF t020-aktyp = 'V'.
      yttxid = xttxid.
      APPEND yttxid.
    ENDIF.
  ENDSELECT.
ENDFORM.                    "LESEN_TTXID

*eject
*---------------------------------------------------------------------*
*       FORM  LESEN_XTTXID                                            *
*---------------------------------------------------------------------*
*       In der Tabelle XTTXID wird ein Eintrag gelesen.               *
*---------------------------------------------------------------------*
FORM lesen_xttxid.
  tabix = 0.
  LOOP AT    xttxid
       WHERE tdobject = imp-objct
       AND   tdid     = ttxid-tdid.
    tabix = sy-tabix.
    EXIT.
  ENDLOOP.
ENDFORM.                    "LESEN_XTTXID

*eject
*---------------------------------------------------------------------*
*       FORM  LESEN_YTTXID                                            *
*---------------------------------------------------------------------*
*       In der Tabelle YTTXID wird ein Eintrag gelesen.               *
*---------------------------------------------------------------------*
FORM lesen_yttxid.
  tabix = 0.
  LOOP AT    yttxid
       WHERE tdobject = imp-objct
       AND   tdid     = xttxid-tdid.
    tabix = sy-tabix.
    EXIT.
  ENDLOOP.
ENDFORM.                    "LESEN_YTTXID

*eject
*---------------------------------------------------------------------*
*       FORM  OKCODE_F15_SPEZIAL                                      *
*---------------------------------------------------------------------*
*       Beenden                                                       *
*---------------------------------------------------------------------*
FORM okcode_f15_spezial.
  PERFORM check_aenderung.
  IF text-xchng NE space
  OR sy-datar   NE space.
    PERFORM datenverlust_ohne_sichern USING text-pt1.
  ENDIF.
  PERFORM tabellen_entsperren.
  PERFORM return_to_menu.
ENDFORM.                    "OKCODE_F15_SPEZIAL

*eject
*---------------------------------------------------------------------*
*       FORM  OKCODE_F17_SPEZIAL                                      *
*---------------------------------------------------------------------*
*       Andere Textfindung                                            *
*---------------------------------------------------------------------*
FORM okcode_f17_spezial.
  PERFORM check_aenderung.
  IF text-xchng NE space
  OR sy-datar   NE space.
    PERFORM datenverlust_ohne_sichern USING text-pt2.
  ENDIF.
  PERFORM tabellen_entsperren.
  PERFORM return_to_menu.
ENDFORM.                    "OKCODE_F17_SPEZIAL

*eject
*---------------------------------------------------------------------*
*       FORM  TTXER_LESEN                                             *
*---------------------------------------------------------------------*
*       Ein Eintrag der Tabelle TTXER wird gelesen.                   *
*---------------------------------------------------------------------*
*  ->   T02_TTDID: Text-ID                                            *
*---------------------------------------------------------------------*
FORM ttxer_lesen USING
            t02_tdid     LIKE ttxid-tdid.
*ORM TTXER_LESEN USING T02_TDID.
  SELECT * FROM  ttxern
           WHERE tdobject = imp-objct
           AND   txtgr    = schema
           AND   tdid     = t02_tdid.
  ENDSELECT.
  IF sy-subrc = 0.
    xttxid-xtxer = 'X'.
  ELSE.
    xttxid-xtxer = ' '.
  ENDIF.
ENDFORM.                    "TTXER_LESEN

*eject
*---------------------------------------------------------------------*
*       FORM  TTXIT_LESEN                                             *
*---------------------------------------------------------------------*
*       Ein Eintrag der Tabelle TTXIT wird gelesen.                   *
*---------------------------------------------------------------------*
*  ->   T01_TTDID: Text-ID                                            *
*---------------------------------------------------------------------*
FORM ttxit_lesen USING
            t01_tdid     LIKE ttxid-tdid.
*ORM TTXIT_LESEN USING T01_TDID.
  SELECT SINGLE * FROM  ttxit
                  WHERE tdspras  = sy-langu
                  AND   tdobject = imp-objct
                  AND   tdid     = t01_tdid.
  IF sy-subrc NE 0.
    ttxit-tdtext = space.
  ENDIF.
ENDFORM.                    "TTXIT_LESEN

*eject
*---------------------------------------------------------------------*
*       FORM  UPDATE.                                                 *
*---------------------------------------------------------------------*
*       훞derungen sichern.                                           *
*---------------------------------------------------------------------*
FORM update.

*------- UPDATE vorbereiten / AKTYP setzen -----------------------------
  PERFORM update_vorbereiten_ttxid.

*------- Automatischer Transportanschlu?-------------------------------
  REFRESH: at_ko200.
*------- ... f? ge?derte Text-IDs ------------------------------------
  rfcu2-tbnam = 'FXID'.
  LOOP AT xttxid WHERE aktyp NE '*'.
    rfcu2-tbkey    = imp-objct.
    rfcu2-tbkey+10 = xttxid-tdid.
    PERFORM tr_auto_fill USING ' ' rfcu2-tbnam rfcu2-tbkey.
  ENDLOOP.
*------- ... und gesamte TTXER -----------------------------------------
  rfcu2-tbnam    = 'FXER'.
  rfcu2-tbkey    = imp-objct.
  rfcu2-tbkey+10 = schema.
  PERFORM tr_auto_fill USING ' ' rfcu2-tbnam rfcu2-tbkey.
*------- ... eintragen in Korrekturauftrag -----------------------------
  PERFORM tr_auto_check.
  PERFORM tr_auto_insert.

*------- UPDATE ausf?ren ----------------------------------------------
  PERFORM update_ausfuehren.
  MESSAGE s312.
  IF old-okcod = 'F15'.                          " Falls nach F15
    PERFORM tabellen_entsperren.                 " POPUP mit Sichern
    PERFORM return_to_menu.
  ELSE.
    PERFORM daten_aktualisieren.
  ENDIF.
ENDFORM.                    "UPDATE

*eject
*---------------------------------------------------------------------*
*       FORM  UPDATE_AUSFUEHREN.                                      *
*---------------------------------------------------------------------*
*       Die 훞derungen werden durchgef?rt.                           *
*---------------------------------------------------------------------*
FORM update_ausfuehren.

* ------ TTXID ---------------------------------------------------------
  trobj = 'FXID'.
  PERFORM view_mark_write_begin USING trobj.
  LOOP AT xttxid.
    CHECK xttxid-aktyp NE '*'.
    ttxid = xttxid.
    CASE xttxid-aktyp.
      WHEN 'D'.
        DELETE ttxid.
        DELETE FROM ttxit WHERE tdspras  = sy-langu
                          AND   tdobject = imp-objct
                          AND   tdid     = xttxid-tdid.
        DELETE xttxid.
      WHEN 'U'.
        MODIFY ttxid.
        CLEAR: ttxit.
        ttxit-tdspras  = sy-langu.
        ttxit-tdobject = imp-objct.
        ttxit-tdid     = xttxid-tdid.
        ttxit-tdtext   = xttxid-tdtext.
        MODIFY ttxit.
    ENDCASE.
  ENDLOOP.
  PERFORM view_mark_write_end   USING trobj.

* ------ TTXER ---------------------------------------------------------
  trobj = 'FXER'.
  PERFORM view_mark_write_begin USING trobj.
  DELETE FROM ttxern WHERE tdobject = imp-objct
                    AND   txtgr    = schema.
  CLEAR n.
  LOOP AT xttxid.
    CHECK xttxid-xtxer = 'X'.
    n = n + 1.
    CLEAR ttxern.
    ttxern-mandt    = sy-mandt.
    ttxern-tdobject = imp-objct.
    ttxern-txtgr    = schema.
    ttxern-lfdtx    = n.
    ttxern-tdid     = xttxid-tdid.
    MODIFY ttxern.
  ENDLOOP.
  PERFORM view_mark_write_end   USING trobj.
ENDFORM.                    "UPDATE_AUSFUEHREN

*eject
*---------------------------------------------------------------------*
*       FORM  UPDATE_VORBEREITEN_TTXID.                               *
*---------------------------------------------------------------------*
*       Im Feld AKTYP der X-Tabelle wird die durchzuf?rende          *
*       Aktion ('U' = MODIFY, 'D' = DELETE) vermerkt.                 *
*---------------------------------------------------------------------*
FORM update_vorbereiten_ttxid.

* ------ Ge?derte und hinzugef?te Eintr?e in X-Tabelle: 'U' ---------
  LOOP AT xttxid.
    PERFORM lesen_yttxid.
    IF tabix = 0.
      xttxid-aktyp = 'U'.              " neu
      MODIFY xttxid.
    ELSE.
      IF xttxid = yttxid.
        xttxid-aktyp = '*'.            " nicht ge?dert
        MODIFY xttxid.
      ELSE.
        xttxid-aktyp = 'U'.            " ge?dert
        MODIFY xttxid.
      ENDIF.
    ENDIF.
  ENDLOOP.

* ------ Gel?chte Eintr?e in X-Tabelle: 'D' --------------------------
  LOOP AT yttxid.
    ttxid = yttxid.
    PERFORM lesen_xttxid.
    IF tabix = 0.
      xttxid = yttxid.
      xttxid-aktyp = 'D'.              " gel?cht
      APPEND xttxid.
    ENDIF.
  ENDLOOP.
ENDFORM.                    "UPDATE_VORBEREITEN_TTXID


*&---------------------------------------------------------------------*
*&      Form  create_and_init_tree_0100
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM create_and_init_tree_0100 .

  DATA: node_table       TYPE treev_ntab,
        item_table       TYPE item_table_type,
        event            TYPE cntl_simple_event,
        events           TYPE cntl_simple_events,
        hierarchy_header TYPE treev_hhdr.

  DATA: node TYPE treev_node.

* create a container for the tree control
  CREATE OBJECT g_custom_container
    EXPORTING
      " the container is linked to the custom control with the
      " name 'TREE_CONTAINER' on the dynpro
      container_name = 'TREE_CONTAINER'
    EXCEPTIONS
      cntl_error = 1
      cntl_system_error = 2
      create_error = 3
      lifetime_error = 4
      lifetime_dynpro_dynpro_link = 5.
  IF sy-subrc <> 0.
    MESSAGE a000(TREE_CONTROL_MSG).
  ENDIF.

* setup the hierarchy header
  hierarchy_header-heading = '[TraSys] 수입모듈별 Text 관리'.
  hierarchy_header-width   = 50.                  " width: 30 characters

* create a column tree model instance
  CREATE OBJECT g_tree
    EXPORTING
      parent                = g_custom_container
      node_selection_mode   = cl_gui_column_tree=>node_sel_mode_single
      item_selection        = 'X'
      hierarchy_column_name = 'C1'                          "#EC NOTEXT
      hierarchy_header      = hierarchy_header
    EXCEPTIONS
      illegal_node_selection_mode = 1
      illegal_column_name         = 2.
  IF sy-subrc <> 0.
    MESSAGE a000(tree_control_msg).
  ENDIF.

* Column2
  CALL METHOD g_tree->add_column
    EXPORTING
      name                         = 'C2'
      width                        = 120
      header_text                  = 'Descriptions'
    EXCEPTIONS
      column_exists                = 1
      illegal_column_name          = 2
      too_many_columns             = 3
      illegal_alignment            = 4
      different_column_types       = 5
      cntl_system_error            = 6
      failed                       = 7
      predecessor_column_not_found = 8.
  IF sy-subrc <> 0.
    MESSAGE a000(tree_control_msg).
  ENDIF.


* define the events which will be passed to the backend
*---> node double click
  event-eventid = cl_gui_column_tree=>eventid_node_double_click.
  event-appl_event = 'X'.              " process PAI if event occurs
  APPEND event TO events.

*---> item double click
  event-eventid = cl_gui_column_tree=>eventid_item_double_click.
  event-appl_event = 'X'.
  APPEND event TO events.

*
  CALL METHOD g_tree->set_registered_events
    EXPORTING
      events                    = events
    EXCEPTIONS
      cntl_error                = 1
      cntl_system_error         = 2
      illegal_event_combination = 3.
  IF sy-subrc <> 0.
    MESSAGE a000(tree_control_msg).
  ENDIF.

* assign event handlers in the application class to each desired event
  SET HANDLER g_application->handle_node_double_click FOR g_tree.
  SET HANDLER g_application->handle_item_double_click FOR g_tree.

* add some nodes to the tree control
* NOTE: the tree control does not store data at the backend. If an
* application wants to access tree data later, it must store the
* tree data itself.
  PERFORM build_node_and_item_table USING node_table item_table.

  CALL METHOD g_tree->add_nodes_and_items
    EXPORTING
      node_table                     = node_table
      item_table                     = item_table
      item_table_structure_name      = 'MTREEITM'
    EXCEPTIONS
      failed                         = 1
      cntl_system_error              = 3
      error_in_tables                = 4
      dp_error                       = 5
      table_structure_name_not_found = 6.
  IF sy-subrc <> 0.
    MESSAGE a000(tree_control_msg).
  ENDIF.

* expand the node with key 'Root'
  LOOP AT node_table INTO node.
    IF node-node_key(4) EQ 'NODE'.
      CALL METHOD g_tree->expand_node
        EXPORTING
          node_key            = node-node_key               "#EC NOTEXT
        EXCEPTIONS
          failed              = 1
          illegal_level_count = 2
          cntl_system_error   = 3
          node_not_found      = 4
          cannot_expand_leaf  = 5.
      IF sy-subrc <> 0.
        MESSAGE a000(tree_control_msg).
      ENDIF.
    ENDIF.
  ENDLOOP.

ENDFORM.                    " create_and_init_tree_0100
*&---------------------------------------------------------------------*
*&      Form  display_selected_node_info
*&---------------------------------------------------------------------*
FORM display_selected_node_info  USING    p_node_key.

  DATA: l_strlen   TYPE i,
        l_tcode    TYPE sy-tcode.


  CHECK NOT p_node_key IS INITIAL.
  CHECK p_node_key(4)  NE 'NODE'.

  CASE p_node_key.
    WHEN 'ZTIRQHD' OR                             "> 개설관리.
         'ZTIPNHD' OR                             "> Notice 관리.
         'ZTIBLHD' OR 'ZTIIVHD' OR 'ZTILGHD' OR   "> 선적관리.
         'ZTIIPHD' OR                             "> 부보관리.
         'ZTIBSHD' OR                             "> 예정정보관리.
         'ZTIBIHD' OR                             "> 반입관리.
         'ZTIBOHD' OR                             "> 반출관리.
         'ZTICCHD' OR                             "> 통관관리.
         'ZTIGRHD' OR                             "> 입고관리.
         'ZTICSHD'.                               "> 비용관리.

      l_objct = p_node_key.

      SELECT SINGLE *
        FROM ttxob
       WHERE tdobject EQ l_objct.
      IF sy-subrc NE 0.
        MESSAGE s935(zmti00) WITH l_objct.
        EXIT.
      ENDIF.
*> Call dialog.
      CALL DIALOG 'Z_TI_TEXT_ID'
        EXPORTING
          t020-aktyp  FROM 'V'
          imp-objct   FROM l_objct
          imp-applk   FROM 'RM'
        IMPORTING
          msgnr
          tbspr
          tddat-cclass.

      IF msgnr = '320'.
        MESSAGE s320(fc) WITH tbspr tddat-cclass.
      ENDIF.
    WHEN OTHERS.
      IF p_node_key(7) EQ 'ZTII029'.
        SELECT SINGLE tcode
          INTO l_tcode
          FROM tstc
         WHERE tcode EQ p_node_key.
        IF sy-subrc EQ 0.
          CALL TRANSACTION p_node_key.
        ELSE.
          MESSAGE s343(s#) WITH p_node_key.
        ENDIF.
      ENDIF.

  ENDCASE.

ENDFORM.                    " display_selected_node_info
*&---------------------------------------------------------------------*
*&      Form  BUILD_NODE_AND_ITEM_TABLE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM build_node_and_item_table  USING   node_table TYPE treev_ntab
                                        item_table TYPE item_table_type.

*> Node Create.
  PERFORM  build_node_table USING:
             node_table 'NODE1'    ''       '',  ">개설관리.
             node_table 'ZTIRQHD'  'NODE1'  'X', "-->텍스트id.
             node_table 'ZTII029A' 'NODE1'  'X', "-->복사규칙.
             node_table 'NODE2'    ''       '',  ">선적관리.
             node_table 'NODE21'   'NODE2'  '',  "-->B/L 관리.
             node_table 'ZTIBLHD'  'NODE21' 'X', "---->텍스트id.
             node_table 'ZTII029B' 'NODE21' 'X', "---->복사규칙.
             node_table 'NODE22'   'NODE2'  '',  "-->송장관리.
             node_table 'ZTIIVHD'  'NODE22' 'X', "---->텍스트id.
             node_table 'ZTII029C' 'NODE22' 'X', "---->복사규칙.
             node_table 'NODE23'   'NODE2'  '',  "-->L/G 관리.
             node_table 'ZTILGHD'  'NODE23' 'X', "---->텍스트id.
             node_table 'ZTII029D' 'NODE23' 'X', "---->복사규칙.
             node_table 'NODE3'    ''       '',  ">부보관리.
             node_table 'ZTIIPHD'  'NODE3'  'X', "-->텍스트id.
             node_table 'ZTII029E' 'NODE3'  'X', "-->복사규칙.
             node_table 'NODE4'    ''       '',  ">보세장치장.
             node_table 'NODE41'   'NODE4'  '',  "-->L/G 관리.
             node_table 'ZTIBSHD'  'NODE41' 'X', "-->텍스트id.
             node_table 'NODE42'   'NODE4'  '',  "-->L/G 관리.
             node_table 'ZTIBIHD'  'NODE42' 'X', "-->텍스트id.
             node_table 'NODE43'   'NODE4'  '',  "-->L/G 관리.
             node_table 'ZTIBOHD'  'NODE43' 'X', "-->텍스트id.
             node_table 'NODE5'    ''       '',  ">통관관리.
             node_table 'ZTICCHD'  'NODE5'  'X', "-->텍스트id.
             node_table 'ZTII029F' 'NODE5'  'X', "-->복사규칙.
             node_table 'NODE6'    '' '',         ">입고관리.
             node_table 'ZTIGRHD'  'NODE6' 'X',   "-->텍스트id.
             node_table 'ZTII029G' 'NODE6' 'X',   "-->복사규칙.
             node_table 'NODE7'    '' '',         ">비용관리.
             node_table 'ZTICSHD'  'NODE7' 'X'.   "-->텍스트id.

*>
  PERFORM  build_item_table USING:
*> 수입개설 관리.
             item_table 'NODE1'    '수입개설 관리'(n10)  '',
             item_table 'ZTIRQHD'  '텍스트 관리'(n11) text-d10,
             item_table 'ZTII029A' '복사규칙 유지보수'(n12) text-d11,
*>
             item_table 'NODE2'    '선적 관리'(n20) '',
*> B/L 관리.
             item_table 'NODE21'   'B/L 관리'(n21) '',
             item_table 'ZTIBLHD'  '텍스트 관리'(n11) text-d21,
             item_table 'ZTII029B' '복사규칙 유지보수'(n12) text-d22,
*> 송장 관리.
             item_table 'NODE22'   '송장 관리'(n22) '',
             item_table 'ZTIIVHD'  '텍스트 관리'(n11) text-d21,
             item_table 'ZTII029C' '복사규칙 유지보수'(n12) text-d24,
*> L/G 관리.
             item_table 'NODE23'   'L/G 관리'(n23) '',
             item_table 'ZTILGHD'  '텍스트 관리'(n11) text-d21,
             item_table 'ZTII029D' '복사규칙 유지보수'(n12) text-d26,
*> 부보관리.
             item_table 'NODE3'    '부보 관리'(n30) '',
             item_table 'ZTIIPHD'  '텍스트 관리'(n11) text-d21,
             item_table 'ZTII029E' '복사규칙 유지보수'(n12) text-d31,
*> 보세장치장 관리.
             item_table 'NODE4'    '보세장치장 관리'(n40) '',
             item_table 'NODE41'   '반입예정정보 관리'(n41) '',
             item_table 'ZTIBSHD'  '텍스트 관리'(n11) text-d21,
             item_table 'NODE42'   '반입정보 관리'(n42) '',
             item_table 'ZTIBIHD'  '텍스트 관리'(n11) text-d21,
             item_table 'NODE43'   '반출정보 관리'(n43) '',
             item_table 'ZTIBOHD'  '텍스트 관리'(n11) text-d21,
*> 통관관리.
             item_table 'NODE5'    '수입통관 관리'(n50) '',
             item_table 'ZTICCHD'  '텍스트 관리'(n11) text-d21,
             item_table 'ZTII029F' '복사규칙 유지보수'(n12) text-d51,
*> 입고관리.
             item_table 'NODE6'    '수입입고 관리'(n60) '',
             item_table 'ZTIGRHD'  '텍스트 관리'(n11) text-d21,
             item_table 'ZTII029G' '복사규칙 유지보수'(n12) text-d61,
*> 제비용관리.
             item_table 'NODE7'    '수입제비용 관리'(n70) '',
             item_table 'ZTICSHD'  '텍스트 관리'(n11) text-d71.


ENDFORM.                    " BUILD_NODE_AND_ITEM_TABLE
*&---------------------------------------------------------------------*
*&      Form  build_node_table
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM build_node_table  USING    node_table TYPE treev_ntab
                                p_node_key
                                p_relatkey
                                p_expander.

  DATA: node TYPE treev_node.


* Build the node table.

* Caution: The nodes are inserted into the tree according to the order
* in which they occur in the table. In consequence, a node must not
* must not occur in the node table before its parent node.

* Node with key 'Root'
  IF p_relatkey IS INITIAL.
    node-node_key = p_node_key.
    " Key of the node
    CLEAR node-relatkey.      " Special case: A root node has no parent
    CLEAR node-relatship.     " node.

    node-hidden = ' '.        " The node is visible,
    node-disabled = ' '.      " selectable,
    node-isfolder = 'X'.      " a folder.
    CLEAR node-n_image.       " Folder-/ Leaf-Symbol in state "closed":
    " use default.
    CLEAR node-exp_image.     " Folder-/ Leaf-Symbol in state "open":
    " use default
    CLEAR node-expander.      " see below.
    APPEND node TO node_table.
  ELSE.
* Node with key 'Child1'
    node-node_key = p_node_key.                             "#EC NOTEXT
    " Key of the node
    " Node is inserted as child of the node with key 'Root'.
    node-relatkey = p_relatkey.
    node-hidden = ' '.
    node-disabled = ' '.
    node-isfolder = 'X'.

    IF p_expander IS INITIAL.
      CLEAR node-n_image.
      CLEAR node-exp_image.
      CLEAR node-relatship.
    ELSE.
      node-relatship = cl_gui_column_tree=>relat_last_child.
      node-n_image    = icon_otf_document.
      node-exp_image  = icon_otf_document.
    ENDIF.

    node-expander = ' '.
    " The node is marked with a '+', although
    " it has no children. When the user clicks on the
    " + to open the node, the event expand_nc is
    " fired. The programmerr can
    " add the children of the
    " node within the event handler of the expand_nc
    " event  (see callback handle_expand_nc).
    APPEND node TO node_table.
  ENDIF.

ENDFORM.                    " build_node_table
*&---------------------------------------------------------------------*
*&      Form  build_item_table
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM build_item_table  USING item_table TYPE item_table_type
                             p_nodekey
                             p_col1_text
                             p_col2_text.

  DATA: item TYPE mtreeitm.

* Node with key 'Root'
  CLEAR item.
  item-node_key  = p_nodekey.
  item-item_name = 'C1'.                  " Item of Column 'Column1'
  item-class     = cl_gui_column_tree=>item_class_text. " Text Item
  item-text      = p_col1_text.
  APPEND item TO item_table.

  CLEAR item.
  item-node_key  = p_nodekey.
  item-item_name = 'C2'.                  " Item of Column 'Column1'
  item-class     = cl_gui_column_tree=>item_class_text. " Text Item
  item-text      = p_col2_text.
  APPEND item TO item_table.

ENDFORM.                    " build_item_table
