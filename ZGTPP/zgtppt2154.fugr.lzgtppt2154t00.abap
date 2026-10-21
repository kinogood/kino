*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZGTPPT2154......................................*
DATA:  BEGIN OF STATUS_ZGTPPT2154                    .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZGTPPT2154                    .
CONTROLS: TCTRL_ZGTPPT2154
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZGTPPT2154                    .
TABLES: ZGTPPT2154                     .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
