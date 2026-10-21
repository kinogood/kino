*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZGTPPT2060......................................*
DATA:  BEGIN OF STATUS_ZGTPPT2060                    .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZGTPPT2060                    .
CONTROLS: TCTRL_ZGTPPT2060
            TYPE TABLEVIEW USING SCREEN '0100'.
*...processing: ZGTPPT2110......................................*
DATA:  BEGIN OF STATUS_ZGTPPT2110                    .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZGTPPT2110                    .
CONTROLS: TCTRL_ZGTPPT2110
            TYPE TABLEVIEW USING SCREEN '0001'.
*...processing: ZGTPPT2121......................................*
DATA:  BEGIN OF STATUS_ZGTPPT2121                    .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZGTPPT2121                    .
CONTROLS: TCTRL_ZGTPPT2121
            TYPE TABLEVIEW USING SCREEN '0200'.
*...processing: ZGTPPT2151......................................*
DATA:  BEGIN OF STATUS_ZGTPPT2151                    .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZGTPPT2151                    .
CONTROLS: TCTRL_ZGTPPT2151
            TYPE TABLEVIEW USING SCREEN '0300'.
*...processing: ZGTPPT2152......................................*
DATA:  BEGIN OF STATUS_ZGTPPT2152                    .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZGTPPT2152                    .
CONTROLS: TCTRL_ZGTPPT2152
            TYPE TABLEVIEW USING SCREEN '0400'.
*...processing: ZGTPPT3293......................................*
DATA:  BEGIN OF STATUS_ZGTPPT3293                    .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZGTPPT3293                    .
CONTROLS: TCTRL_ZGTPPT3293
            TYPE TABLEVIEW USING SCREEN '0002'.
*...processing: ZGTPPT4141......................................*
DATA:  BEGIN OF STATUS_ZGTPPT4141                    .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZGTPPT4141                    .
CONTROLS: TCTRL_ZGTPPT4141
            TYPE TABLEVIEW USING SCREEN '0005'.
*...processing: ZGTPPV1170......................................*
TABLES: ZGTPPV1170, *ZGTPPV1170. "view work areas
CONTROLS: TCTRL_ZGTPPV1170
TYPE TABLEVIEW USING SCREEN '0003'.
DATA: BEGIN OF STATUS_ZGTPPV1170. "state vector
          INCLUDE STRUCTURE VIMSTATUS.
DATA: END OF STATUS_ZGTPPV1170.
* Table for entries selected to show on screen
DATA: BEGIN OF ZGTPPV1170_EXTRACT OCCURS 0010.
INCLUDE STRUCTURE ZGTPPV1170.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF ZGTPPV1170_EXTRACT.
* Table for all entries loaded from database
DATA: BEGIN OF ZGTPPV1170_TOTAL OCCURS 0010.
INCLUDE STRUCTURE ZGTPPV1170.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF ZGTPPV1170_TOTAL.

*...processing: ZGTPPV4140......................................*
TABLES: ZGTPPV4140, *ZGTPPV4140. "view work areas
CONTROLS: TCTRL_ZGTPPV4140
TYPE TABLEVIEW USING SCREEN '0004'.
DATA: BEGIN OF STATUS_ZGTPPV4140. "state vector
          INCLUDE STRUCTURE VIMSTATUS.
DATA: END OF STATUS_ZGTPPV4140.
* Table for entries selected to show on screen
DATA: BEGIN OF ZGTPPV4140_EXTRACT OCCURS 0010.
INCLUDE STRUCTURE ZGTPPV4140.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF ZGTPPV4140_EXTRACT.
* Table for all entries loaded from database
DATA: BEGIN OF ZGTPPV4140_TOTAL OCCURS 0010.
INCLUDE STRUCTURE ZGTPPV4140.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF ZGTPPV4140_TOTAL.

*.........table declarations:.................................*
TABLES: *ZGTPPT2060                    .
TABLES: *ZGTPPT2110                    .
TABLES: *ZGTPPT2121                    .
TABLES: *ZGTPPT2151                    .
TABLES: *ZGTPPT2152                    .
TABLES: *ZGTPPT3293                    .
TABLES: *ZGTPPT4141                    .
TABLES: MAKT                           .
TABLES: MARA                           .
TABLES: ZGTPPT1170                     .
TABLES: ZGTPPT2060                     .
TABLES: ZGTPPT2110                     .
TABLES: ZGTPPT2121                     .
TABLES: ZGTPPT2151                     .
TABLES: ZGTPPT2152                     .
TABLES: ZGTPPT3293                     .
TABLES: ZGTPPT4140                     .
TABLES: ZGTPPT4141                     .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
