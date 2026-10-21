*&---------------------------------------------------------------------*
*& Include          ZNFR2700_TOP
*&---------------------------------------------------------------------*
TABLES: VBAK,ZNFT1000,ZNFT1001,ZNFT1011,ZNFT1020,ZNFT1030,
        ZNFT0003,ZNFT1051.
*&---------------------------------------------------------------------*
*&  Macro
*&---------------------------------------------------------------------*
DEFINE _ranges.
  &1-low = &2.
  &1-high = ''.
  &1-sign = 'I'.
  &1-option = 'EQ'.
  APPEND &1.
  CLEAR &1.
END-OF-DEFINITION.

DEFINE _rangescp.
  &1-low = &2.
  &1-high = ''.
  &1-sign = 'I'.
  &1-option = 'CP'.
  APPEND &1.
  CLEAR &1.
END-OF-DEFINITION.
*&---------------------------------------------------------------------*
*&  TYPES 선언
*&---------------------------------------------------------------------*
TYPES: BEGIN OF TY_ALV.
TYPES:
         ZPJNO           TYPE ZPJNO,
         GJAHR           TYPE GJAHR,
         VBELN_VA        TYPE VBELN_VA, "판매문서
         VBELN           TYPE VBELN_VF, "청구문서
         FKART           TYPE FKART,    "청구유형
         POSNR           TYPE POSNR,    "SD문서 품목번호
         MATNR           TYPE MATNR,
         MEINS           TYPE MEINS,
         FKLMG           TYPE FKLMG,   "청구 수량(재고 관리 단위)
         FKDAT           TYPE FKDAT,   "청구일
         ENDAT           TYPE ZENDAT_1,"만기일
         NES             TYPE /NFM/NES, "NF 키
         VGW             TYPE /NFM/VGW, "각 참조 수량에 대한 NF 금속의 수수료 가중치
         VGE             TYPE /NFM/VGE, "수수료 가중치에 대한 참조 수량
         BME             TYPE MEINS,    "기본단위
         EMENG_B         TYPE EMENG,   "총 수주 비철수량
         EMENG_S         TYPE EMENG,   "총 선물(집행)수량
         CONSUM_QTY      TYPE VERBW,   "소비량
         YEAR_B          TYPE P LENGTH 13 DECIMALS 3, "조회년도 판매비철량 합계
         YEAR_S          TYPE P LENGTH 13 DECIMALS 3, "조회년도 선물수량 합계
         BUKRS           TYPE ZNFT1000-BUKRS,
         CONNO           TYPE ZNFT1000-CONNO,
         PRCTR           TYPE ZNFT1000-PRCTR,
         VKGRP           TYPE ZNFT1000-VKGRP,
         KUNNR           TYPE ZNFT1000-KUNNR,
         NCUST           TYPE ZNFT1000-NCUST,
         ZPTXT           TYPE ZSD0106T-ZPTXT,
         YEAR_BEFORE_B   TYPE P LENGTH 13 DECIMALS 3, "기준년도의 이전연도 비철량 합계
         YEAR_BEFORE_S   TYPE P LENGTH 13 DECIMALS 3, "기준년도의 이전연도 선물수량 합계
         YEAR_AFTER_B    TYPE P LENGTH 13 DECIMALS 3, "기준년도의 이후연도 비철량 합계
         YEAR_AFTER_S    TYPE P LENGTH 13 DECIMALS 3, "기준년도의 이후연도 선물수량 합계
         " _B :판매비철량 , _S :선물 청산수량
         MON01_B         TYPE P LENGTH 13 DECIMALS 3,
         MON01_S         TYPE P LENGTH 13 DECIMALS 3,
         MON02_B         TYPE P LENGTH 13 DECIMALS 3,
         MON02_S         TYPE P LENGTH 13 DECIMALS 3,
         MON03_B         TYPE P LENGTH 13 DECIMALS 3,
         MON03_S         TYPE P LENGTH 13 DECIMALS 3,
         MON04_B         TYPE P LENGTH 13 DECIMALS 3,
         MON04_S         TYPE P LENGTH 13 DECIMALS 3,
         MON05_B         TYPE P LENGTH 13 DECIMALS 3,
         MON05_S         TYPE P LENGTH 13 DECIMALS 3,
         MON06_B         TYPE P LENGTH 13 DECIMALS 3,
         MON06_S         TYPE P LENGTH 13 DECIMALS 3,
         MON07_B         TYPE P LENGTH 13 DECIMALS 3,
         MON07_S         TYPE P LENGTH 13 DECIMALS 3,
         MON08_B         TYPE P LENGTH 13 DECIMALS 3,
         MON08_S         TYPE P LENGTH 13 DECIMALS 3,
         MON09_B         TYPE P LENGTH 13 DECIMALS 3,
         MON09_S         TYPE P LENGTH 13 DECIMALS 3,
         MON10_B         TYPE P LENGTH 13 DECIMALS 3,
         MON10_S         TYPE P LENGTH 13 DECIMALS 3,
         MON11_B         TYPE P LENGTH 13 DECIMALS 3,
         MON11_S         TYPE P LENGTH 13 DECIMALS 3,
         MON12_B         TYPE P LENGTH 13 DECIMALS 3,
         MON12_S         TYPE P LENGTH 13 DECIMALS 3.
TYPES: END OF TY_ALV.
*&---------------------------------------------------------------------*
TYPES: BEGIN OF TY_ALV2.
TYPES:   VBELN_VA   TYPE VBELN_VA,       "판매문서
         ERDAT      TYPE ERDAT,          "오더생성일
         VBELN      TYPE VBELN_VF,       "대금청구문서
         POSNR      TYPE POSNR,          "판매문서 품목
         FKDAT      TYPE FKDAT,          "매출일=청구일
         NES        TYPE ZNFT1001-NFKEY, "비철구분
         NFKEY      TYPE ZNFT1001-NFKEY, "비철구분
         CONSUM_QTY TYPE ZNFT1030-EMENG, "판매동량
         ENDAT      TYPE ZNFT1020-ENDAT, "만기일
         EMENG      TYPE ZNFT1030-EMENG, "선물청산수량
         CONNO      TYPE ZNFT1000-CONNO, "계약번호
         NFUTN      TYPE ZNFT1020-NFUTN, "신규선물집행번호
         CFUTN      TYPE ZNFT1030-CFUTN, "청산선물집행번호
         ZPJNO      TYPE ZNFT1000-ZPJNO.
TYPES: END OF TY_ALV2.
*&---------------------------------------------------------------------*
TYPES: BEGIN OF TY_ALV3.
TYPES: ZPJNO      TYPE ZNFT1000-ZPJNO,
       CONNO      TYPE ZNFT1001-CONNO,
       NFKEY      TYPE ZNFT1001-NFKEY,
       SUJU_EMENG TYPE ZNFT1001-EMENG,
       MEINS      TYPE ZNFT1001-MEINS.
TYPES: END OF TY_ALV3.
*&---------------------------------------------------------------------*
TYPES: BEGIN OF TY_NF_MENGE,
         BUKRS    LIKE ZNFT1051-BUKRS,
         GJAHR    LIKE ZNFT1051-GJAHR,
         ZPJNO    LIKE ZNFT1000-ZPJNO,
         ZPTXT    LIKE ZSD0106T-ZPTXT,
         CONNO    LIKE ZNFT1011-CONNO,
         REQNO    LIKE ZNFT1051-REQNO,
         H_NO1    LIKE ZNFT1051-H_NO1,
         NFUTN    LIKE ZNFT1051-NFUTN,
         CFUTN    LIKE ZNFT1051-NFUTN,
         NFCTR    LIKE ZNFT1000-NFCTR,
         PRCTR    LIKE ZNFT1000-PRCTR,
         VKGRP    LIKE ZNFT1000-VKGRP,
         KUNNR    LIKE ZNFT1000-KUNNR,
         NCUST    LIKE ZNFT1000-NCUST,
         N_RUDAT  LIKE ZNFT1020-RUDAT,
         C_RUDAT  LIKE ZNFT1030-RUDAT,
         ENDAT    LIKE ZNFT1051-ENDAT,
         EMENG    LIKE ZNFT1051-EMENG,
         MEINS    LIKE ZNFT1051-MEINS,
         NFKEY    LIKE ZNFT1051-NFKEY,
         SUJU_EMENG LIKE ZNFT1001-EMENG, "[임시추가] 총 수주 비철수량
         CELLTAB  TYPE LVC_T_STYL,      " Cell 단위 수정 스타일
         COLINFO  TYPE LVC_T_SCOL,      " CELL 색상 지정
       END OF TY_NF_MENGE.
*&---------------------------------------------------------------------*
TYPES: BEGIN OF TY_ZSD_365_NF_CONSUM,
         ZPJNO      TYPE ZPJNO,
         GJAHR      TYPE GJAHR,
         VBELN_VA   TYPE VBELN_VA,
         VBELN      TYPE VBELN_VF,
         FKART      TYPE FKART,
         POSNR      TYPE POSNR,
         MATNR      TYPE MATNR,
         MEINS      TYPE MEINS,
         FKLMG      TYPE FKLMG,
         FKDAT      TYPE FKDAT,
         NES        TYPE /NFM/NES,
         VGW        TYPE /NFM/VGW,
         VGE        TYPE /NFM/VGE,
         BME        TYPE MEINS,
         CONSUM_QTY TYPE VERBW,
         ERDAT      TYPE ERDAT,
         CONNO      TYPE ZCONNO.
TYPES: END OF TY_ZSD_365_NF_CONSUM.
*&---------------------------------------------------------------------*
*___필드카탈로그용
TYPES: BEGIN OF TY_FIELD,
         NAME        TYPE LVC_S_FCAT-FIELDNAME,
         TEXT        TYPE LVC_S_FCAT-COLTEXT,
         KEY         TYPE LVC_S_FCAT-KEY,
         HOT         TYPE LVC_S_FCAT-HOTSPOT,
         COLOR       TYPE LVC_S_FCAT-EMPHASIZE,
         OUTPUTLEN   TYPE LVC_S_FCAT-OUTPUTLEN,
         CFIELDLNAME TYPE LVC_S_FCAT-CFIELDNAME,
         QFIELDNAME  TYPE LVC_S_FCAT-QFIELDNAME,
         DO_SUM      TYPE LVC_S_FCAT-DO_SUM,
       END OF TY_FIELD.
*&---------------------------------------------------------------------*
* F4 Help용 변수
*&---------------------------------------------------------------------*
DATA: SCR_FIELDS   LIKE DYNPREAD OCCURS 0 WITH HEADER LINE.
DATA: GT_FIELDS    LIKE  HELP_VALUE OCCURS 1 WITH HEADER LINE,
      SELECTFIELD  LIKE HELP_INFO-FIELDNAME,
      SELECT_VALUE LIKE HELP_INFO-FLDVALUE.

DATA: GV_TABIX TYPE SY-TABIX.

*___손익센터
DATA: BEGIN OF TY_PRCTR,
        PRCTR TYPE ZNFT0003-PRCTR,
        PTEXT TYPE ZNFT0003-PTEXT,
      END OF TY_PRCTR,
      GT_PRCTR LIKE TABLE OF TY_PRCTR.

*___영업그룹
DATA: BEGIN OF TY_VKGRP,
        VKGRP TYPE  ZNFT0003-VKGRP,
        VTEXT TYPE  ZNFT0003-VTEXT,
      END OF TY_VKGRP,
      GT_VKGRP LIKE TABLE OF TY_VKGRP.

*___사업부
DATA: BEGIN OF TY_NFCTR,
        NFCTR TYPE ZNFT0005-NFCTR,
        NTEXT TYPE ZNFT0005-NTEXT,
      END OF TY_NFCTR,
      GT_NFCTR LIKE TABLE OF TY_NFCTR.


DATA: GV_ERROR  TYPE CHAR01,
      GV_ANSWER TYPE CHAR01.
*&---------------------------------------------------------------------*
*&  Global 변수 선언
*&---------------------------------------------------------------------*
DATA: GT_ALV   TYPE TABLE OF TY_ALV,
      GS_ALV   TYPE TY_ALV,
      GT_ALV2  TYPE TABLE OF TY_ALV2,
      GS_ALV2  TYPE TY_ALV2,
      GS_ALV3  TYPE TY_ALV3,
      GT_ALV3  TYPE TABLE OF TY_ALV3.

DATA: GT_DATA        TYPE TABLE OF TY_NF_MENGE,
      GT_DATA_DETAIL TYPE TABLE OF TY_NF_MENGE.

DATA: GS_FUNCTION TYPE ZSDS_365_0080_0030_INPUT,
      GT_FUNCTION LIKE TABLE OF GS_FUNCTION.

DATA: GS_OUT TYPE TY_ZSD_365_NF_CONSUM,
      GT_OUT LIKE TABLE OF GS_OUT.

DATA: GT_LIST     TYPE TABLE OF TY_ALV,
      GT_SELECTED TYPE TABLE OF TY_ALV.

DATA: GV_ZPJNO TYPE TY_ALV-ZPJNO,
      GV_ZPTXT TYPE TY_ALV-ZPTXT,
      GV_KUNNR TYPE TY_ALV-KUNNR,
      GV_NCUST TYPE TY_ALV-NCUST.

DATA: GV_GJAHR_B TYPE GJAHR,
      GV_GJAHR_A TYPE GJAHR.
*&---------------------------------------------------------------------*
*&  ALV
*&---------------------------------------------------------------------*
DATA: GO_CONT  TYPE REF TO CL_GUI_CUSTOM_CONTAINER,
      GO_CONT2 TYPE REF TO CL_GUI_CUSTOM_CONTAINER,
      GO_CONT3 TYPE REF TO CL_GUI_CUSTOM_CONTAINER,
      GO_GRID  TYPE REF TO CL_GUI_ALV_GRID,
      GO_GRID2 TYPE REF TO CL_GUI_ALV_GRID,
      GO_GRID3 TYPE REF TO CL_GUI_ALV_GRID.

DATA: GT_EXCLUDE  TYPE UI_FUNCTIONS,
      GV_OKCODE   TYPE SY-UCOMM,
      GS_VARIANT  LIKE DISVARIANT,
      GS_VARIANT2 LIKE DISVARIANT,
      GT_SORT2    TYPE LVC_T_SORT,
      GT_SORT3    TYPE LVC_T_SORT.
