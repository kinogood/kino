*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZNFT1092........................................*
DATA:  BEGIN OF STATUS_ZNFT1092                      .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZNFT1092                      .
CONTROLS: TCTRL_ZNFT1092
            TYPE TABLEVIEW USING SCREEN '0010'.
*.........table declarations:.................................*
TABLES: *ZNFT1092                      .
TABLES: ZNFT1092                       .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
