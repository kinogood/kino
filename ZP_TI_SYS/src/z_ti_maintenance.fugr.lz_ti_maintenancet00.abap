*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZTITRQM.........................................*
DATA:  BEGIN OF STATUS_ZTITRQM                       .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZTITRQM                       .
CONTROLS: TCTRL_ZTITRQM
            TYPE TABLEVIEW USING SCREEN '0007'.
*...processing: ZTITRQS.........................................*
DATA:  BEGIN OF STATUS_ZTITRQS                       .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZTITRQS                       .
CONTROLS: TCTRL_ZTITRQS
            TYPE TABLEVIEW USING SCREEN '0001'.
*...processing: ZTITRQX.........................................*
DATA:  BEGIN OF STATUS_ZTITRQX                       .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZTITRQX                       .
CONTROLS: TCTRL_ZTITRQX
            TYPE TABLEVIEW USING SCREEN '0006'.
*...processing: ZTIVCRK.........................................*
TABLES: ZTIVCRK, *ZTIVCRK. "view work areas
CONTROLS: TCTRL_ZTIVCRK
TYPE TABLEVIEW USING SCREEN '0003'.
DATA: BEGIN OF STATUS_ZTIVCRK. "state vector
          INCLUDE STRUCTURE VIMSTATUS.
DATA: END OF STATUS_ZTIVCRK.
* Table for entries selected to show on screen
DATA: BEGIN OF ZTIVCRK_EXTRACT OCCURS 0010.
INCLUDE STRUCTURE ZTIVCRK.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF ZTIVCRK_EXTRACT.
* Table for all entries loaded from database
DATA: BEGIN OF ZTIVCRK_TOTAL OCCURS 0010.
INCLUDE STRUCTURE ZTIVCRK.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF ZTIVCRK_TOTAL.

*...processing: ZTIVIP02........................................*
TABLES: ZTIVIP02, *ZTIVIP02. "view work areas
CONTROLS: TCTRL_ZTIVIP02
TYPE TABLEVIEW USING SCREEN '0005'.
DATA: BEGIN OF STATUS_ZTIVIP02. "state vector
          INCLUDE STRUCTURE VIMSTATUS.
DATA: END OF STATUS_ZTIVIP02.
* Table for entries selected to show on screen
DATA: BEGIN OF ZTIVIP02_EXTRACT OCCURS 0010.
INCLUDE STRUCTURE ZTIVIP02.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF ZTIVIP02_EXTRACT.
* Table for all entries loaded from database
DATA: BEGIN OF ZTIVIP02_TOTAL OCCURS 0010.
INCLUDE STRUCTURE ZTIVIP02.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF ZTIVIP02_TOTAL.

*.........table declarations:.................................*
TABLES: *ZTITRQM                       .
TABLES: *ZTITRQS                       .
TABLES: *ZTITRQX                       .
TABLES: ZTITCRK                        .
TABLES: ZTITIP1                        .
TABLES: ZTITRQM                        .
TABLES: ZTITRQS                        .
TABLES: ZTITRQX                        .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
