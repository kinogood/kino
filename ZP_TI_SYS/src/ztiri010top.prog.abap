************************************************************************
* Title         :  ZTIRI010TOP                                         *
*                                                                      *
* Description   : TEXT ID 공용Data Include                             *
*                                                                      *
* Creation Date : 2003/10/10                                           *
*                                                                      *
* Author        : SeogBong, Kang                                       *
*                                                                      *
************************************************************************
* ------ Common Part: Datendefinitionen f? SAPDFKBn -------------------

*------- Tabellen -----------------------------------------------------
TABLES: E071,                                    " Transport
        E071K,                                   " Transport
        RFCU2,                                   " Transport-Arb.Felder
        TDDAT,                                   " Berechtigung
        T019W,                                   " Window-Koordinaten
        T020,                                    " Transaktionssteuerung
        T050T,                                   " Allgemeine Texte
        OFIWA.                                   " Open FI Workarea

*------- Verzeichnis der unzul?sigen OK-Codes -------------------------
DATA:    BEGIN OF EXCTAB OCCURS 5,
           OKCOD(5)          TYPE C,
         END   OF EXCTAB.

*------- Inhalt des Transportauftrags ----------------------------------
DATA:    BEGIN OF IE071  OCCURS 5,
           OBJECT            LIKE E071-OBJECT,
           OBJ_NAME          LIKE E071-OBJ_NAME,
         END   OF IE071.

*------- Inhalt des Transportauftrags ----------------------------------
DATA:    BEGIN OF IE071K OCCURS 5,
           OBJNAME           LIKE E071K-OBJNAME,
           TABKEY(20)        TYPE C,             " E071K-TABKEY zu lang
         END   OF IE071K.

*------- First-Line Information pro Dynpro -----------------------------
DATA:    BEGIN OF FLITAB OCCURS 2,
           DYNNR             LIKE SY-DYNNR,      " Dynpro
           LNFIR             LIKE SY-TABIX,      " 1. angezeigte Zeile
         END   OF FLITAB.

*------- Gepr?te Tabellenklassen f? AUTHORITY (aus TDDAT) ------------
DATA:    BEGIN OF TAUTAB OCCURS 2,
           CCLASS            LIKE TDDAT-CCLASS,  " Tabellenklasse
         END   OF TAUTAB.

*------- Autom. Transport - Objekte ------------------------------------
DATA:    BEGIN OF AT_KO200 OCCURS 2.
           INCLUDE STRUCTURE KO200.
DATA:    END   OF AT_KO200.
DATA:    BEGIN OF AT_E071K OCCURS 5.
           INCLUDE STRUCTURE E071K.
DATA:    END   OF AT_E071K.

*------- Einzelfelder -------------------------------------------------
DATA:   ACTVT                LIKE TACT-ACTVT,    " Aktivit?
        ANSWER(1)            TYPE C.             " Antwort auf POP-UP

DATA:   CHAR(100)            TYPE C,             " Hilfsfeld
        SPACECHAR(100)       TYPE C,             " Hilfsfeld
        CHAR2(50)            TYPE C.             " Hilfsfeld

DATA:   DY-FIELD             LIKE RFCU3-FNAME,   " fuer GET CURSOR
        DY-LINNO             TYPE P,             " fuer GET CURSOR
        DY-INHALT(8)         TYPE C,
        DYNPC(8)             TYPE C.             " Dynpros processed

DATA:   ENQKEY               LIKE RSTABLE-VARKEY, " f? ENQUEUE
        ENQGENKEY            LIKE RSTABLE-VARKEY, " f? ENQUEUE
        ENQNOCLI(1)          TYPE C,              " ohne Mandant?
        EXFLG(1)             TYPE C.             " EXIT-Flag

DATA:   INDEX(5)             TYPE N.             " Lese-Index

DATA:   LINNO-0110           TYPE P,             " f? GET CURSOR
        LNFIR                LIKE SY-TABIX,      " Erste Zeile d. Seite
        LNCNT                LIKE SY-LOOPC,      " Anzahl Loop-Zeilen
        LNCUR                LIKE SY-TABIX,      " Laufende Zeile
        LNMAX                LIKE SY-TABIX,      " Letzte Zeile
        LTFIR                LIKE SY-TABIX,      " analog (2.Loop)
        LTCNT                LIKE SY-LOOPC,      " analog
        LTMAX                LIKE SY-TABIX.      " analog

DATA:   MSGNR(3)             TYPE C,             " Message-Nummer
        MSMOD(1)             TYPE C.             " Mastermodus aktiv ?

DATA:   OK-CODE(5)           TYPE C.             " OK-Code

DATA:   PFKEY                LIKE SY-PFKEY,      " ?er Dynpros hinweg
        POPTI(30)            TYPE C.             " Titel f? POPUP

DATA:   RC                   LIKE SY-SUBRC,      " Returncode
        REFE1(3)             TYPE P,             " Rechenfeld
        REFE2(3)             TYPE P.             " Rechenfeld

DATA:   TABIX                LIKE SY-TABIX,      " Gemerkter SY-TABIX
        TBCUR                LIKE SY-TABIX,      " Tb-Cursor f? Scroll
        TBSPR                LIKE DD03P-TABNAME, " Tabelle beim Sperren
        TITEL(80)            TYPE C,             " f? TITLEBAR
        TITEL0(10)           TYPE C,             " f? TITLEBAR
        TITEL1(30)           TYPE C,             " f? TITLEBAR
        TROBJ                LIKE OBJS-OBJECTNAME,
        TRORDER              LIKE E070-TRKORR.   " Auftrag

DATA:   XAPPE                LIKE TRPARI-S_CHECKED, "OBJECT_APPENDABLE?
        XCALL(1)             TYPE C,             " Kennz.: gerufen?
        XCHNG(1)             TYPE C,             " Kennz.: 훞derungen?
        XINSE(1)             TYPE C.             " Kennz.: Insert-Modus?

* ------ Tempor?e Felder ---------------------------------------------
DATA:   IN_ARBEIT(1)         TYPE C.

* ------  Hilfstabellen f? Transporte                "begin P9CK042275

types:  BEGIN OF xt021j_type,
          VARNR         LIKE T021J-VARNR,
          LTEXT         LIKE T021G-LTEXT,
          ALT(1)        TYPE C,
          NEU(1)        TYPE C,
        END   OF xt021j_type.

types   xt021j_tab type xt021j_type  occurs 0.

data:   gt_new_t021j    type xt021j_tab.                 "end P9CK042275

************************************************************************
* History of changes:                                                  *
* -------------------                                                  *
* 4.6C                                                                 *
* CC 06/20/00 P9CK042275 note 311026 deactivating standard variants    *
************************************************************************
