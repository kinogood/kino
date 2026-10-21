*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZTITTAG.........................................*
DATA:  BEGIN OF STATUS_ZTITTAG                       .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZTITTAG                       .
CONTROLS: TCTRL_ZTITTAG
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZTITTAG                       .
TABLES: ZTITTAG                        .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
