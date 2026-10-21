*&---------------------------------------------------------------------*
*& Include          ZGTPPR1100TOP
*&---------------------------------------------------------------------*
TABLES: ZGTPPT1080, ZGTPPT1150, MARA, MARC, SSCRFIELDS.

INCLUDE <CL_ALV_CONTROL>.

* CLASS ZCL_EVENT_RECIEVER DEFINITION
CLASS ZCL_EVENT_RECIEVER DEFINITION DEFERRED.

DATA: BEGIN OF GS_DATA,
        ZSTAT         LIKE ICON-ID,     "상태
        ZMESSAGE(100),                  "메시지
        MATNR         LIKE MARA-MATNR,  "자재코드
        MAKTX         LIKE MAKT-MAKTX,  "자재내역
        WERKS         LIKE MARC-WERKS,  "플랜트
        NAME1         LIKE T001W-NAME1, "플랜트내역
        SPART         LIKE MARA-SPART,  "제품군
        VTEXT         LIKE TSPAT-VTEXT, "제품군내역
        MTART         LIKE MARA-MTART,  "자재유형
        MTBEZ         LIKE T134T-MTBEZ, "자재유형내역
        MATKL         LIKE MARA-MATKL,  "자재그룹
        WGBEZ         LIKE T023T-WGBEZ, "자재그룹내역
        STRGR         LIKE MARC-STRGR,  "생산전략
        DISMM         LIKE MARC-DISMM,  "MRP유형
        DISPO         LIKE MARC-DISPO,  "MRP관리자
        DISLS         LIKE MARC-DISLS,  "로트크기유형
        BESKZ         LIKE MARC-BESKZ,  "조달유형
        SOBSL         LIKE MARC-SOBSL,  "특별조달유형
        LGPRO         LIKE MARC-LGPRO,  "생산저장위치
        LGFSB         LIKE MARC-LGFSB,  "외부조달저장위치
        RGEKZ         LIKE MARC-RGEKZ,  "백플러쉬
        MTVFP         LIKE MARC-MTVFP,  "가용성점검
        SBDKZ         LIKE MARC-SBDKZ,  "개별/일괄
        XCHAR         LIKE MARC-XCHAR,  "배치관리
        UEETK         LIKE MARC-UEETK,  "무제한허용
        FEVOR         LIKE MARC-FEVOR,  "생산감독자
        SFCPF         LIKE MARC-SFCPF,  "생산일정프로파일
        DPCBT         LIKE MARC-DPCBT,  "단일단위배치기본값
        KZKUP         LIKE MARC-KZKUP,  "연산품
        DISGR         LIKE MARC-DISGR,  "MRP그룹
        INSMK         LIKE MARC-INSMK,  "검사재고로전기
        STDPD         LIKE MARC-STDPD,  "구성형 자재

        CLASS         LIKE KLAH-CLASS,  "배치클래스
        CSPLIT        LIKE MAKV-CSPLIT, "배부구조(등가계수)
        CUOBF         LIKE MARA-CUOBF,  "내부 오브젝트 번호
        DEFLT(1),                       "기본값설정
        DEL(1),
        CELL_STY      TYPE LVC_T_STYL,  "cell style
      END OF GS_DATA.
DATA: GT_DATA  LIKE TABLE OF GS_DATA,
      GT_DATA1 LIKE TABLE OF GS_DATA.

DATA: BEGIN OF GS_UPLOAD,
        MATNR(50), "자재코드
        MAKTX(50), "자재내역
        WERKS(50), "플랜트
        NAME1(50), "플랜트내역
        SPART(50), "제품군
        VTEXT(50), "제품군내역
        MTART(50), "자재유형
        MTBEZ(50), "자재유형내역
        DEFLT(50), "기본값설정(Y,N)
        MATKL(50), "자재그룹
        WGBEZ(50), "자재그룹내역
        STRGR(50), "생산전략
        DISMM(50), "MRP유형
        DISPO(50), "MRP관리자
        DISLS(50), "로트크기유형
        BESKZ(50), "조달유형
        SOBSL(50), "특별조달유형
        LGPRO(50), "생산저장위치
        LGFSB(50), "외부조달저장위치
        RGEKZ(50), "백플러쉬
        MTVFP(50), "가용성점검
        SBDKZ(50), "개별/일괄
        XCHAR(50), "배치관리
        UEETK(50), "무제한허용
        FEVOR(50), "생산감독자
        SFCPF(50), "생산일정프로파일
        DPCBT(50), "단일단위배치기본값
        KZKUP(50), "연산품
        DISGR(50), "MRP그룹
        INSMK(50), "검사재고로전기
      END OF GS_UPLOAD.
DATA: GT_UPLOAD LIKE TABLE OF GS_UPLOAD.

DATA: BEGIN OF GS_1080.
        INCLUDE STRUCTURE ZGTPPT1080.
DATA: END OF GS_1080.

DATA: BEGIN OF GS_MARA,
        MATNR LIKE MARA-MATNR,
        SPART LIKE MARA-SPART,
        MTART LIKE MARA-MTART,
        SATNR LIKE MARA-SATNR,
        MAKTX LIKE MAKT-MAKTX,
        CUOBF LIKE MARA-CUOBF,
      END OF GS_MARA.
DATA: GT_MARA LIKE TABLE OF GS_MARA.

DATA: BEGIN OF GS_1010,
        FLD_03 LIKE ZGTPPT1010-FLD_03, "플랜트
        FLD_01 LIKE ZGTPPT1010-FLD_01, "제품군
        FLD_05 LIKE ZGTPPT1010-FLD_05, "저장위치
      END OF GS_1010.
DATA: GT_1010 LIKE TABLE OF GS_1010.

DATA: BEGIN OF GS_MATNR,
        MATNR LIKE MARD-MATNR,
        WERKS LIKE MARD-WERKS,
      END OF GS_MATNR.
DATA: GT_MATNR LIKE TABLE OF GS_MATNR.

DATA: BEGIN OF GS_CLASS,
        OBJEK LIKE KSSK-OBJEK,
        KLART LIKE KSSK-KLART,
        CLINT LIKE KSSK-CLINT,
      END OF GS_CLASS.
DATA: GT_CLASS LIKE TABLE OF GS_CLASS.

"원부 신규/수정
DATA: BEGIN OF GS_DATA_RM,
        ZSTAT         LIKE ICON-ID,     "상태
        ZMESSAGE(100),                  "메시지
        MATNR         LIKE MARA-MATNR,  "자재코드
        MAKTX         LIKE MAKT-MAKTX,  "자재내역
        WERKS         LIKE MARC-WERKS,  "플랜트
        NAME1         LIKE T001W-NAME1, "플랜트내역
        MTART         LIKE MARA-MTART,  "자재유형
        MTBEZ         LIKE T134T-MTBEZ, "자재유형내역
        MATKL         LIKE MARA-MATKL,  "자재그룹
        WGBEZ         LIKE T023T-WGBEZ, "자재그룹내역
        LGPRO         LIKE MARC-LGPRO,  "생산저장위치
        SBDKZ         LIKE MARC-SBDKZ,  "개별/일괄
        KAUSF         LIKE MARC-KAUSF,  "구성부품스크랩
        RGEKZ         LIKE MARC-RGEKZ,  "백플러시지시자

        BISMT         LIKE MARA-BISMT,  "기존자재코드
      END OF GS_DATA_RM.
DATA: GT_DATA_RM LIKE TABLE OF GS_DATA_RM.

"생산저장위치 업데이트
DATA: BEGIN OF GS_DATA_UPDATE,
        ZSTAT         LIKE ICON-ID,     "상태
        ZMESSAGE(100),                  "메시지
        PMATN         LIKE MAST-MATNR,  "모품목코드
        PMAKT         LIKE MAKT-MAKTX,  "모품목내역
        SPART         LIKE MARA-SPART,  "제품군
        VTEXT         LIKE TSPAT-VTEXT, "제품군내역
        POSNR         LIKE STPO-POSNR,  "BOM품목번호
        CMATN         LIKE MARA-MATNR,  "자재코드
        CMAKT         LIKE MAKT-MAKTX,  "자재내역
        WERKS         LIKE MARC-WERKS,  "플랜트
        NAME1         LIKE T001W-NAME1, "플랜트내역
        MTART         LIKE MARA-MTART,  "자재유형
        MTBEZ         LIKE T134T-MTBEZ, "자재유형내역
        MATKL         LIKE MARA-MATKL,  "자재그룹
        WGBEZ         LIKE T023T-WGBEZ, "자재그룹내역
        LGPRO         LIKE MARC-LGPRO,  "(자재마스터)생산저장위치
        LGOBE         LIKE T001L-LGOBE, "내역
        LGORT         LIKE STPO-LGORT,  "(BOM)생산저장위치

        STLAN         LIKE MAST-STLAN,  "BOM 용도
        DEL(1),
      END OF GS_DATA_UPDATE.
DATA: GT_DATA_UPDATE LIKE TABLE OF GS_DATA_UPDATE.

"컴포넌트 스크랩 설정
DATA: BEGIN OF GS_1150,
        WERKS LIKE MARC-WERKS,       "플랜트
        NAME1 LIKE T001W-NAME1,      "플랜트내역
        BISMT LIKE ZGTPPT1150-BISMT, "기존구매자재코드
        BISNM LIKE ZGTPPT1150-BISNM, "기존구매자재내역
        BISSP LIKE ZGTPPT1150-BISSP, "기존구매자재규격
        KAUSF LIKE ZGTPPT1150-KAUSF, "구성품목스크랩
      END OF GS_1150.
DATA: GT_1150 LIKE TABLE OF GS_1150.

*  BAPI를 위한 INTERNAL TABLE
DATA: GS_RETURN            LIKE BAPIRET2,
      HEADDATA             LIKE BAPIMATHEAD,
      CLIENTDATA           LIKE BAPI_MARA,
      CLIENTDATAX          LIKE BAPI_MARAX,
      PLANTDATA            LIKE BAPI_MARC,
      PLANTDATAX           LIKE BAPI_MARCX,
      STORAGELOCATIONDATA  LIKE BAPI_MARD,
      STORAGELOCATIONDATAX LIKE BAPI_MARDX.

DATA: RETURNMESSAGES LIKE BAPI_MATRETURN2 OCCURS 0 WITH HEADER LINE.

*- BDC
DATA: BDCDATA   LIKE BDCDATA    OCCURS 0 WITH HEADER LINE,
      MESSTAB   LIKE BDCMSGCOLL OCCURS 0 WITH HEADER LINE,
      GS_PARAMS TYPE CTU_PARAMS.

DATA: GO_CONTAIN_0100 TYPE REF TO CL_GUI_DOCKING_CONTAINER.
DATA: GO_GRID_0100 TYPE REF TO CL_GUI_ALV_GRID.
DATA: GO_EVTR_0100 TYPE REF TO ZCL_EVENT_RECIEVER.
DATA: GS_VARIANT TYPE DISVARIANT.
DATA: GS_LAYOUT_0100 TYPE LVC_S_LAYO.
DATA: GT_EXCLUDE_0100 TYPE UI_FUNCTIONS.
DATA: GT_FIELDCAT_0100 TYPE LVC_T_FCAT.

DATA: GO_CONTAIN_0200 TYPE REF TO CL_GUI_DOCKING_CONTAINER.
DATA: GO_GRID_0200 TYPE REF TO CL_GUI_ALV_GRID.
DATA: GS_LAYOUT_0200 TYPE LVC_S_LAYO.
DATA: GT_EXCLUDE_0200 TYPE UI_FUNCTIONS.
DATA: GT_FIELDCAT_0200 TYPE LVC_T_FCAT.

DATA: GV_DYNTXT1 TYPE SMP_DYNTXT,
      GV_DYNTXT2 TYPE SMP_DYNTXT.

DATA: GV_OK_CODE TYPE SYUCOMM,
      GV_DBCNT   TYPE CHAR10.

DATA: GT_UCOMM TYPE TABLE OF SY-UCOMM.

DATA: GV_ERROR(1).

CONSTANTS: GC_A        TYPE CHAR1           VALUE 'A',
           GC_C        TYPE CHAR1           VALUE 'C',
           GC_D        TYPE CHAR1           VALUE 'D',
           GC_E        TYPE CHAR1           VALUE 'E',
           GC_F        TYPE CHAR1           VALUE 'F',
           GC_I        TYPE CHAR1           VALUE 'I',
           GC_K        TYPE CHAR1           VALUE 'K',
           GC_L        TYPE CHAR1           VALUE 'L',
           GC_M        TYPE CHAR1           VALUE 'M',
           GC_O        TYPE CHAR1           VALUE 'O',
           GC_P        TYPE CHAR1           VALUE 'P',
           GC_R        TYPE CHAR1           VALUE 'R',
           GC_S        TYPE CHAR1           VALUE 'S',
           GC_T        TYPE CHAR1           VALUE 'T',
           GC_W        TYPE CHAR1           VALUE 'W',
           GC_X        TYPE CHAR1           VALUE 'X',
           GC_Y        TYPE CHAR1           VALUE 'Y',
           GC_ALL      TYPE CHAR1           VALUE '*',
           GC_EQ       TYPE CHAR2           VALUE 'EQ',
           GC_BT       TYPE CHAR2           VALUE 'BT',
           GC_FERT     TYPE MTART           VALUE 'FERT',
           GC_MCFE     TYPE MTART           VALUE 'MCFE',
           GC_MCHA     TYPE MTART           VALUE 'MCHA',
           GC_HAWA     TYPE MTART           VALUE 'HAWA',
           GC_PP       TYPE ZGTEMODULE_KIND VALUE 'PP',
           GC_1030     TYPE ZGTECODEGRP     VALUE '1030',
           GC_1070     TYPE ZGTECODEGRP     VALUE '1070',
           C_START_COL TYPE I               VALUE '1',
           C_START_ROW TYPE I               VALUE '3',
           C_END_COL   TYPE I               VALUE '256',
           C_END_ROW   TYPE I               VALUE '65536'.
