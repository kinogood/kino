*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZTITIG00........................................*
DATA:  BEGIN OF STATUS_ZTITIG00                      .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZTITIG00                      .
CONTROLS: TCTRL_ZTITIG00
            TYPE TABLEVIEW USING SCREEN '0010'.
*...processing: ZTITIG02........................................*
DATA:  BEGIN OF STATUS_ZTITIG02                      .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZTITIG02                      .
CONTROLS: TCTRL_ZTITIG02
            TYPE TABLEVIEW USING SCREEN '0200'.
*...processing: ZTITIG06........................................*
DATA:  BEGIN OF STATUS_ZTITIG06                      .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZTITIG06                      .
CONTROLS: TCTRL_ZTITIG06
            TYPE TABLEVIEW USING SCREEN '0600'.
*...processing: ZTITIG07........................................*
DATA:  BEGIN OF STATUS_ZTITIG07                      .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZTITIG07                      .
CONTROLS: TCTRL_ZTITIG07
            TYPE TABLEVIEW USING SCREEN '0700'.
*...processing: ZTITIG11........................................*
DATA:  BEGIN OF STATUS_ZTITIG11                      .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZTITIG11                      .
CONTROLS: TCTRL_ZTITIG11
            TYPE TABLEVIEW USING SCREEN '1100'.
*...processing: ZTITIG13........................................*
DATA:  BEGIN OF STATUS_ZTITIG13                      .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZTITIG13                      .
CONTROLS: TCTRL_ZTITIG13
            TYPE TABLEVIEW USING SCREEN '0130'.
*...processing: ZTITIG14........................................*
DATA:  BEGIN OF STATUS_ZTITIG14                      .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZTITIG14                      .
CONTROLS: TCTRL_ZTITIG14
            TYPE TABLEVIEW USING SCREEN '0002'.
*...processing: ZTITIG21........................................*
DATA:  BEGIN OF STATUS_ZTITIG21                      .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZTITIG21                      .
CONTROLS: TCTRL_ZTITIG21
            TYPE TABLEVIEW USING SCREEN '2100'.
*...processing: ZTITIG30........................................*
DATA:  BEGIN OF STATUS_ZTITIG30                      .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZTITIG30                      .
*...processing: ZTITIG38........................................*
DATA:  BEGIN OF STATUS_ZTITIG38                      .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZTITIG38                      .
CONTROLS: TCTRL_ZTITIG38
            TYPE TABLEVIEW USING SCREEN '3800'.
*...processing: ZTITIG51........................................*
DATA:  BEGIN OF STATUS_ZTITIG51                      .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZTITIG51                      .
CONTROLS: TCTRL_ZTITIG51
            TYPE TABLEVIEW USING SCREEN '5100'.
*...processing: ZTITIG52........................................*
DATA:  BEGIN OF STATUS_ZTITIG52                      .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZTITIG52                      .
CONTROLS: TCTRL_ZTITIG52
            TYPE TABLEVIEW USING SCREEN '5200'.
*...processing: ZTIVIG08........................................*
TABLES: ZTIVIG08, *ZTIVIG08. "view work areas
CONTROLS: TCTRL_ZTIVIG08
TYPE TABLEVIEW USING SCREEN '0800'.
DATA: BEGIN OF STATUS_ZTIVIG08. "state vector
          INCLUDE STRUCTURE VIMSTATUS.
DATA: END OF STATUS_ZTIVIG08.
* Table for entries selected to show on screen
DATA: BEGIN OF ZTIVIG08_EXTRACT OCCURS 0010.
INCLUDE STRUCTURE ZTIVIG08.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF ZTIVIG08_EXTRACT.
* Table for all entries loaded from database
DATA: BEGIN OF ZTIVIG08_TOTAL OCCURS 0010.
INCLUDE STRUCTURE ZTIVIG08.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF ZTIVIG08_TOTAL.

*...processing: ZTIVIG10........................................*
TABLES: ZTIVIG10, *ZTIVIG10. "view work areas
CONTROLS: TCTRL_ZTIVIG10
TYPE TABLEVIEW USING SCREEN '1011'.
DATA: BEGIN OF STATUS_ZTIVIG10. "state vector
          INCLUDE STRUCTURE VIMSTATUS.
DATA: END OF STATUS_ZTIVIG10.
* Table for entries selected to show on screen
DATA: BEGIN OF ZTIVIG10_EXTRACT OCCURS 0010.
INCLUDE STRUCTURE ZTIVIG10.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF ZTIVIG10_EXTRACT.
* Table for all entries loaded from database
DATA: BEGIN OF ZTIVIG10_TOTAL OCCURS 0010.
INCLUDE STRUCTURE ZTIVIG10.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF ZTIVIG10_TOTAL.

*...processing: ZTIVIG39........................................*
TABLES: ZTIVIG39, *ZTIVIG39. "view work areas
CONTROLS: TCTRL_ZTIVIG39
TYPE TABLEVIEW USING SCREEN '3900'.
DATA: BEGIN OF STATUS_ZTIVIG39. "state vector
          INCLUDE STRUCTURE VIMSTATUS.
DATA: END OF STATUS_ZTIVIG39.
* Table for entries selected to show on screen
DATA: BEGIN OF ZTIVIG39_EXTRACT OCCURS 0010.
INCLUDE STRUCTURE ZTIVIG39.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF ZTIVIG39_EXTRACT.
* Table for all entries loaded from database
DATA: BEGIN OF ZTIVIG39_TOTAL OCCURS 0010.
INCLUDE STRUCTURE ZTIVIG39.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF ZTIVIG39_TOTAL.

*...processing: ZTIVIG80........................................*
TABLES: ZTIVIG80, *ZTIVIG80. "view work areas
CONTROLS: TCTRL_ZTIVIG80
TYPE TABLEVIEW USING SCREEN '8000'.
DATA: BEGIN OF STATUS_ZTIVIG80. "state vector
          INCLUDE STRUCTURE VIMSTATUS.
DATA: END OF STATUS_ZTIVIG80.
* Table for entries selected to show on screen
DATA: BEGIN OF ZTIVIG80_EXTRACT OCCURS 0010.
INCLUDE STRUCTURE ZTIVIG80.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF ZTIVIG80_EXTRACT.
* Table for all entries loaded from database
DATA: BEGIN OF ZTIVIG80_TOTAL OCCURS 0010.
INCLUDE STRUCTURE ZTIVIG80.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF ZTIVIG80_TOTAL.

*...not in TVDIR: ZTIVIGT1......................................*
TABLES: ZTIVIGT1, *ZTIVIGT1. "view work areas
CONTROLS: TCTRL_ZTIVIGT1
TYPE TABLEVIEW USING SCREEN '0000'.
DATA: BEGIN OF STATUS_ZTIVIGT1. "state vector
          INCLUDE STRUCTURE VIMSTATUS.
DATA: END OF STATUS_ZTIVIGT1.
* Table for entries selected to show on screen
DATA: BEGIN OF ZTIVIGT1_EXTRACT OCCURS 0001.
INCLUDE STRUCTURE ZTIVIGT1.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF ZTIVIGT1_EXTRACT.
* Table for all entries loaded from database
DATA: BEGIN OF ZTIVIGT1_TOTAL OCCURS 0001.
INCLUDE STRUCTURE ZTIVIGT1.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF ZTIVIGT1_TOTAL.

*.........table declarations:.................................*
TABLES: *ZTITIG00                      .
TABLES: *ZTITIG02                      .
TABLES: *ZTITIG06                      .
TABLES: *ZTITIG07                      .
TABLES: *ZTITIG11                      .
TABLES: *ZTITIG13                      .
TABLES: *ZTITIG14                      .
TABLES: *ZTITIG21                      .
TABLES: *ZTITIG30                      .
TABLES: *ZTITIG38                      .
TABLES: *ZTITIG51                      .
TABLES: *ZTITIG52                      .
TABLES: LFA1                           .
TABLES: T618                           .
TABLES: T618T                          .
TABLES: TGSB                           .
TABLES: TGSBT                          .
TABLES: ZTITIG00                       .
TABLES: ZTITIG02                       .
TABLES: ZTITIG06                       .
TABLES: ZTITIG07                       .
TABLES: ZTITIG08                       .
TABLES: ZTITIG10                       .
TABLES: ZTITIG11                       .
TABLES: ZTITIG13                       .
TABLES: ZTITIG14                       .
TABLES: ZTITIG21                       .
TABLES: ZTITIG30                       .
TABLES: ZTITIG38                       .
TABLES: ZTITIG39                       .
TABLES: ZTITIG51                       .
TABLES: ZTITIG52                       .
TABLES: ZTITIG80                       .
TABLES: ZTSTIG3                        .
*.........tables for views not in TVDIR.......................*
TABLES: ZTSTIGT                        .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
