*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZGTMMV4115......................................*
TABLES: ZGTMMV4115, *ZGTMMV4115. "view work areas
CONTROLS: TCTRL_ZGTMMV4115
TYPE TABLEVIEW USING SCREEN '0002'.
DATA: BEGIN OF STATUS_ZGTMMV4115. "state vector
          INCLUDE STRUCTURE VIMSTATUS.
DATA: END OF STATUS_ZGTMMV4115.
* Table for entries selected to show on screen
DATA: BEGIN OF ZGTMMV4115_EXTRACT OCCURS 0010.
INCLUDE STRUCTURE ZGTMMV4115.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF ZGTMMV4115_EXTRACT.
* Table for all entries loaded from database
DATA: BEGIN OF ZGTMMV4115_TOTAL OCCURS 0010.
INCLUDE STRUCTURE ZGTMMV4115.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF ZGTMMV4115_TOTAL.

*...processing: ZGTMMV6100......................................*
TABLES: ZGTMMV6100, *ZGTMMV6100. "view work areas
CONTROLS: TCTRL_ZGTMMV6100
TYPE TABLEVIEW USING SCREEN '0001'.
DATA: BEGIN OF STATUS_ZGTMMV6100. "state vector
          INCLUDE STRUCTURE VIMSTATUS.
DATA: END OF STATUS_ZGTMMV6100.
* Table for entries selected to show on screen
DATA: BEGIN OF ZGTMMV6100_EXTRACT OCCURS 0010.
INCLUDE STRUCTURE ZGTMMV6100.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF ZGTMMV6100_EXTRACT.
* Table for all entries loaded from database
DATA: BEGIN OF ZGTMMV6100_TOTAL OCCURS 0010.
INCLUDE STRUCTURE ZGTMMV6100.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF ZGTMMV6100_TOTAL.

*.........table declarations:.................................*
TABLES: ZGTMMT4115                     .
TABLES: ZGTMMT6100                     .
