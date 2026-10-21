FUNCTION-POOL zgtsd04.                      "MESSAGE-ID ..
*-----------------------------------------------------------------------
*-- Tables
*-----------------------------------------------------------------------
TABLES : zgtsdt1009.

*-----------------------------------------------------------------------
*-- Constants
*-----------------------------------------------------------------------
*-- Range Sign
CONSTANTS : BEGIN OF gc_sign,
              i TYPE ddsign                     VALUE 'I',
              e TYPE ddsign                     VALUE 'E',
            END OF gc_sign,
*-- Range Option
            BEGIN OF gc_optn,
              eq TYPE ddoption                  VALUE 'EQ',
              ne TYPE ddoption                  VALUE 'NE',
              bt TYPE ddoption                  VALUE 'BT',
              cp TYPE ddoption                  VALUE 'CP',
            END OF gc_optn.
* INCLUDE LZGTSD04D...                       " Local class definition
