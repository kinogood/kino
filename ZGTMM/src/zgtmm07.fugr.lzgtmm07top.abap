FUNCTION-POOL ZGTMM07                    MESSAGE-ID SV.

* INCLUDE LZGTMM13D...                       " Local class definition



*----------------------------------------------------------------------*
* CONSTANTS
*----------------------------------------------------------------------*
CONSTANTS:
  GC_A TYPE C LENGTH 1 VALUE 'A',
  GC_C TYPE C LENGTH 1 VALUE 'C',
  GC_D TYPE C LENGTH 1 VALUE 'D',
  GC_E TYPE C LENGTH 1 VALUE 'E',
  GC_S TYPE C LENGTH 1 VALUE 'S',
  GC_X TYPE C LENGTH 1 VALUE 'X'.

CONSTANTS:
  GC_1       TYPE C LENGTH 1 VALUE '1',
  GC_00      TYPE C LENGTH 2 VALUE '00',
  GC_02      TYPE C LENGTH 2 VALUE '02',
  GC_PP      TYPE C LENGTH 2 VALUE 'PP',
  GC_0010    TYPE C LENGTH 4 VALUE '0010',
  GC_EKPO    TYPE C LENGTH 4 VALUE 'EKPO',
  GC_EBAN    TYPE C LENGTH 4 VALUE 'EBAN',
  GC_MM00058 TYPE ZGTEIFNO VALUE 'MM00058',
  GC_KG      TYPE C LENGTH 3 VALUE 'KG',
  GC_MMQ      TYPE C LENGTH 3 VALUE 'MMQ',
  GC_M3      TYPE C LENGTH 3 VALUE 'M3',
  GC_301 TYPE BWART VALUE '301',
  GC_302 TYPE BWART VALUE '302'.


*----------------------------------------------------------------------*
* ZGTED_GET_DRUM_CBM 병렬 호출(aRFC) 결과 수신용
*----------------------------------------------------------------------*
TYPES: BEGIN OF GTY_DRUM_RES,
         TASK   TYPE C LENGTH 8,
         PMATNR TYPE C LENGTH 40,
         OK     TYPE ABAP_BOOL,         "수신 성공
         FOUND  TYPE ABAP_BOOL,         "드럼 정보 존재
         CBM    TYPE ZGTEDSIF0037,
       END OF GTY_DRUM_RES.
DATA: GT_DRUM_RES TYPE HASHED TABLE OF GTY_DRUM_RES WITH UNIQUE KEY TASK,
      GV_DRUM_RCV TYPE I.


INCLUDE LSVIMDAT                                . "general data decl.
INCLUDE LZGTMM07T00                             . "view rel. data dcl.
