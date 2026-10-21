*&---------------------------------------------------------------------*
*& Include          ZGTPPR1110TOP
*&---------------------------------------------------------------------*
TABLES: MARA, MARC, MAST, MAPL, MKAL, ZGTPPT1010.

INCLUDE <CL_ALV_CONTROL>.

DATA: BEGIN OF GS_DATA,
        PROC_STAT     LIKE ICON-ID,           "처리상태
        PROC_MSG(100),                        "메시지
        MATNR         LIKE MARA-MATNR,        "품목코드
        MAKTX         LIKE MAKT-MAKTX,        "품목내역
        MATKL         LIKE MARA-MATKL,        "자재그룹
        WGBEZ         LIKE T023T-WGBEZ,       "자재그룹내역
        WERKS         LIKE MARC-WERKS,        "플랜트
        NAME1         LIKE T001W-NAME1,       "플랜트내역
        BESKZ         LIKE MARC-BESKZ,        "조달유형
        SOBSL         LIKE MARC-SOBSL,        "특별조달
        PVER_STAT     LIKE ICON-ID,           "생산버전상태
        VERID         LIKE MKAL-VERID,        "생산버전
        TEXT1         LIKE MKAL-TEXT1,        "생산버전내역
        ADATU         LIKE MKAL-ADATU,        "효력시작일
        BDATU         LIKE MKAL-BDATU,        "효력종료일
        BOM_STAT      LIKE ICON-ID,           "BOM상태
        STLAN         LIKE MAST-STLAN,        "BOM 용도
        STLAL         LIKE MAST-STLAL,        "대체 BOM
        ROUT_STAT     LIKE ICON-ID,           "ROUTING상태
        PLNTY         LIKE MKAL-PLNTY,        "태스크 리스트 유형
        PLNNR         LIKE MKAL-PLNNR,        "그룹번호
        ALNAL         LIKE MKAL-ALNAL,        "그룹카운터
        BOM_CHECK     LIKE ICON-ID,           "BOM점검기호
        ROUT_CHECK    LIKE ICON-ID,           "라우팅점검기호
        PRDAT         LIKE MKAL-PRDAT,        "최종점검일

        FLD_05        LIKE ZGTPPT1010-FLD_05, "BOM점검
        FLD_06        LIKE ZGTPPT1010-FLD_06, "라우팅점검
        PRFG_S        LIKE MKAL-PRFG_S,       "BOM점검
        PRFG_F        LIKE MKAL-PRFG_F,       "라우팅점검
        STLNR         LIKE MAST-STLNR,        "BOM번호
        DISPO         LIKE MARC-DISPO,
      END OF GS_DATA.
DATA: GT_DATA  LIKE TABLE OF GS_DATA,
      GT_ODATA LIKE TABLE OF GS_DATA.

DATA: BEGIN OF GS_1010.
        INCLUDE STRUCTURE ZGTPPT1010.
DATA: END OF GS_1010.
DATA: GT_1010 LIKE TABLE OF GS_1010.

DATA: BEGIN OF GS_0107,
        SPGCD LIKE ZPPT0107-SPGCD,
        DESCR LIKE ZPPT0107-DESCR,
        WERKS LIKE ZPPT0107-WERKS,
        SPART LIKE ZPPT0107-SPART,
      END OF GS_0107.
DATA: GT_0107 LIKE TABLE OF GS_0107.

DATA: GV_DYN(50),
      GV_DISPO TYPE DISPO.

DATA: GO_CONTAIN_0100 TYPE REF TO CL_GUI_DOCKING_CONTAINER.
DATA: GO_GRID_0100 TYPE REF TO CL_GUI_ALV_GRID.
DATA: GS_VARIANT TYPE DISVARIANT.
DATA: GS_LAYOUT_0100 TYPE LVC_S_LAYO.
DATA: GT_EXCLUDE_0100 TYPE UI_FUNCTIONS.
DATA: GT_FIELDCAT_0100 TYPE LVC_T_FCAT.

DATA: GT_UCOMM TYPE TABLE OF SY-UCOMM.

DATA: GV_OK_CODE TYPE SYUCOMM,
      GV_DBCNT   TYPE CHAR10.

DATA: GV_SUC TYPE I.

DATA: GV_REPID TYPE SYREPID,
      GV_VALID TYPE CHAR01,
      GV_INDEX TYPE SY-TABIX,
      GV_TEXT  TYPE CHAR255.

CONSTANTS: GC_C        TYPE CHAR1           VALUE 'C',
           GC_D        TYPE CHAR1           VALUE 'D',
           GC_E        TYPE CHAR1           VALUE 'E',
           GC_F        TYPE CHAR1           VALUE 'F',
           GC_I        TYPE CHAR1           VALUE 'I',
           GC_L        TYPE CHAR1           VALUE 'L',
           GC_N        TYPE CHAR1           VALUE 'N',
           GC_P        TYPE CHAR1           VALUE 'P',
           GC_R        TYPE CHAR1           VALUE 'R',
           GC_S        TYPE CHAR1           VALUE 'S',
           GC_W        TYPE CHAR1           VALUE 'W',
           GC_X        TYPE CHAR1           VALUE 'X',
           GC_Y        TYPE CHAR1           VALUE 'Y',
           GC_ALL      TYPE CHAR1           VALUE '*',
           GC_AS       TYPE CHAR2           VALUE 'AS',
           GC_BT       TYPE CHAR2           VALUE 'BT',
           GC_30       TYPE SOBSL           VALUE '30',
           GC_50       TYPE SOBSL           VALUE '50',
           GC_0010     TYPE VERID           VALUE '0010',
           GC_SC10     TYPE VERID           VALUE 'SC10',
           GC_CO10     TYPE VERID           VALUE 'CO10',
           GC_MCHF     TYPE MTART           VALUE 'MCHF',
           GC_HALB     TYPE MTART           VALUE 'HALB',
           GC_FERT     TYPE MTART           VALUE 'FERT',
           GC_RW600407 TYPE MATKL           VALUE 'RW600407',
           GC_PP       TYPE ZGTEMODULE_KIND VALUE 'PP',
           GC_1040     TYPE ZGTECODEGRP     VALUE '1040'.

DEFINE _CL.
  CLEAR : &1,  &1[].
END-OF-DEFINITION.
DEFINE M_CUNIT.
  IF &1 = 'I'.
    CALL FUNCTION 'CONVERSION_EXIT_CUNIT_INPUT'
        EXPORTING  INPUT  = &2
        IMPORTING  OUTPUT = &3
       EXCEPTIONS  ERROR_MESSAGE = 99.
  ELSE.
    CALL FUNCTION 'CONVERSION_EXIT_CUNIT_OUTPUT'
        EXPORTING  INPUT  = &2
        IMPORTING  OUTPUT = &3
       EXCEPTIONS  ERROR_MESSAGE = 99.
  ENDIF.
END-OF-DEFINITION.
