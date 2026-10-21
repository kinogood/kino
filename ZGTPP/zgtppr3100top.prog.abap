*&---------------------------------------------------------------------*
*& Include          ZGTPPR3100TOP
*&---------------------------------------------------------------------*
TABLES: ZGTPPT3150, ZGTPPT3160, ZGTPPT3170,
        ZGTMMT6210, ZGTMMT6211, ZGTSDT0067, ZGTPPT1010,
        AUFK, AFKO, AFPO, MARA, VBAK.

* CLASS ZCL_EVENT_RECIEVER DEFINITION
CLASS ZCL_EVENT_RECIEVER DEFINITION DEFERRED.

DATA: BEGIN OF GS_DATA,
        VBELN         LIKE ZGTSDT0067-VBELN,         "판매오더번호
        POSNR         LIKE ZGTSDT0067-POSNR,         "판매오더품목
        JOB_NO        LIKE ZGTPPT3150-JOB_NO,        "제조지시번호
        JOB_NM        LIKE ZGTEDT2121-ZJOB_NAME,     "제조지시내역
        LINE_NO       LIKE ZGTPPT3150-LINE_NO,       "라인번호
        SERIAL_INFO   LIKE ZGTPPT3150-SERIAL_INFO,   "시리얼정보
        MATNR         LIKE ZGTPPT3150-MATNR,         "제품코드
        MAKTX         LIKE MAKT-MAKTX,               "제품내역
        OPER_CODE_E   LIKE ZGTPPT1010-FLD_02,        "ERP공정
        OPER_NAME_E   LIKE ZGTPPT1010-FLD_03,        "ERP공정명
        LEN_ORDGB     LIKE ZGTPPT1010-FLD_06,        "길이별 오더구분
        OPER_CODE     LIKE ZGTPPT3160-OPER_CODE,     "MES공정
        OPER_NAME     LIKE ZGTPPT3160-OPER_NAME,     "MES공정명
        RTID          LIKE ICON-ID,                  "처리모드
        RTMSG(100),                                  "처리메시지
        JOBLS         LIKE ZGTPPT3160-JOBLS,         "제조지시 요청번호
        EBELN         LIKE ZGTMMT6000-EBELN,         "구매오더번호
        OPER_MATNR    LIKE ZGTPPT3160-OPER_MATNR,    "생산품목코드
        OPER_MAKTX    LIKE MAKT-MAKTX,               "생산품목내역
        MTART         LIKE MARA-MTART,               "자재유형
        MATKL         LIKE MARA-MATKL,               "자재그룹
        AUFNR         LIKE ZGTPPT3160-AUFNR,         "생산오더번호
        ORDSTAT(100),                                "생산오더상태
        IDNLF         LIKE ZGTPPT3160-IDNLF,         "외주공정 자재그룹
        BSTMG         LIKE ZGTPPT3160-BSTMG,         "외주가공수량
        BSTME         LIKE ZGTPPT3160-BSTME,         "외주가공단위
        NETWR         LIKE ZGTPPT3160-NETWR,         "외주가공금액
        WAERS         LIKE T001-WAERS,               "금액단위
        MENGE         LIKE ZGTPPT3160-MENGE,         "생산수량
        MEINS         LIKE ZGTPPT3160-MEINS,         "단위
        L1L7(50),                                    "L1~L7
        WERKS         LIKE ZGTPPT3150-WERKS,         "플랜트
        NAME1         LIKE T001W-NAME1,              "플랜트내역
        ZPJNO         LIKE VBAK-ZPJNO,               "프로젝트번호
        ZPTXT         LIKE ZSD0106T-ZPTXT,           "프로젝트내역
        CRDAT         LIKE ZGTPPT3150-CRDAT,         "제조지시 수신일자

        PRCSS_SEQ     LIKE ZGTPPT3160-PRCSS_SEQ,     "공정순번
        PRCSS_SUB_SEQ LIKE ZGTPPT3160-PRCSS_SUB_SEQ, "SUB순번
        ZWEIGHT       LIKE ZGTPPT3150-ZWEIGHT,       "중량
        ZLENGTH_1     LIKE ZGTPPT3150-ZLENGTH_1,     "길이1(mm)
        ZLENGTH_2     LIKE ZGTPPT3150-ZLENGTH_2,     "길이2(mm)
        ZLENGTH_3     LIKE ZGTPPT3150-ZLENGTH_3,     "길이3(mm)
        ZLENGTH_4     LIKE ZGTPPT3150-ZLENGTH_4,     "길이4(mm)
        ZLENGTH_5     LIKE ZGTPPT3150-ZLENGTH_5,     "길이5(mm)
        ZLENGTH_6     LIKE ZGTPPT3150-ZLENGTH_6,     "길이6(mm)
        ZLENGTH_7     LIKE ZGTPPT3150-ZLENGTH_7,     "길이7(mm)
        COMP_STAT     LIKE ZGTPPT3160-COMP_STAT,     "구성부품 등록 여부
        ZMODE         LIKE ZGTPPT3160-ZMODE,   "처리 모드(P:처리, C:취소)
        OPER_MATKL    LIKE T023T-MATKL,              "OPER_CODE 자재그룹
        OPER_WGBEZ    LIKE T023T-WGBEZ,              "OPER_CODE 자재그룹명
        FLD_07        LIKE ZGTPPT1010-FLD_07,
        BESKZ         LIKE ZGTPPT3160-BESKZ,
      END OF GS_DATA.
DATA: GT_DATA  LIKE TABLE OF GS_DATA,
      GT_SDATA LIKE TABLE OF GS_DATA.

DATA: BEGIN OF GS_1010.
        INCLUDE STRUCTURE ZGTPPT1010.
DATA: END OF GS_1010.
DATA: GT_1010  LIKE TABLE OF GS_1010.

DATA: BEGIN OF GS_AUFNR_SEND,
        AUFNR LIKE AUFK-AUFNR,
        ERDAT LIKE AUFK-ERDAT,
      END OF GS_AUFNR_SEND.
DATA: GT_AUFNR_SEND LIKE TABLE OF GS_AUFNR_SEND.

DATA: BEGIN OF GS_JOBLS_SEND,
        JOBLS LIKE ZGTPPT3160-JOBLS,
      END OF GS_JOBLS_SEND.
DATA: GT_JOBLS_SEND LIKE TABLE OF GS_JOBLS_SEND.

DATA: GT_ZGTMMT6210 TYPE TABLE OF ZGTMMT6210,
      GT_ZGTMMT6211 TYPE TABLE OF ZGTMMT6211.

DATA: GO_CONTAIN_0100 TYPE REF TO CL_GUI_DOCKING_CONTAINER.
DATA: GO_GRID_0100 TYPE REF TO CL_GUI_ALV_GRID.
DATA: GO_EVTR_0100 TYPE REF TO ZCL_EVENT_RECIEVER.
DATA: GS_VARIANT TYPE DISVARIANT.
DATA: GS_LAYOUT_0100 TYPE LVC_S_LAYO.
DATA: GT_SORT_0100 TYPE LVC_T_SORT.
DATA: GT_EXCLUDE_0100 TYPE UI_FUNCTIONS.
DATA: GT_FIELDCAT_0100 TYPE LVC_T_FCAT.

DATA: GT_UCOMM TYPE TABLE OF SY-UCOMM.

DATA: GV_OK_CODE TYPE SYUCOMM,
      GV_DBCNT   TYPE CHAR10.

DATA: GV_REPID TYPE SYREPID,
      GV_VALID TYPE CHAR01,
      GV_INDEX TYPE SY-TABIX,
      GV_TEXT  TYPE CHAR255,
      GV_WAERS TYPE WAERS,
      GV_JOBLS TYPE C LENGTH 10,
      GV_MREQ  TYPE C LENGTH 13,
      GV_MSEQ  TYPE ZGTE_BD_MES_SEQ VALUE '00000001',
      GV_SAKTO TYPE SAKNR,
      GV_KOSTL TYPE KOSTL,
      GV_07    TYPE ZGTE_FLDVAL.

RANGES: GR_JOB_STATUS FOR ZGTPPT1010-FLD_02,
        GR_JOB_NO     FOR ZGTEDT2121-ZJOB_NO.

CONSTANTS: GC_0       TYPE PSTYP           VALUE '0',
           GC_3       TYPE PSTYP           VALUE '3',
           GC_A       TYPE CHAR1           VALUE 'A',
           GC_C       TYPE CHAR1           VALUE 'C',
           GC_D       TYPE CHAR1           VALUE 'D',
           GC_E       TYPE CHAR1           VALUE 'E',
           GC_F       TYPE CHAR1           VALUE 'F',
           GC_I       TYPE CHAR1           VALUE 'I',
           GC_K       TYPE CHAR1           VALUE 'K',
           GC_L       TYPE CHAR1           VALUE 'L',
           GC_M       TYPE CHAR1           VALUE 'M',
           GC_O       TYPE CHAR1           VALUE 'O',
           GC_P       TYPE CHAR1           VALUE 'P',
           GC_R       TYPE CHAR1           VALUE 'R',
           GC_S       TYPE CHAR1           VALUE 'S',
           GC_W       TYPE CHAR1           VALUE 'W',
           GC_X       TYPE CHAR1           VALUE 'X',
           GC_Y       TYPE CHAR1           VALUE 'Y',
           GC_ALL     TYPE CHAR1           VALUE '*',
           GC_EQ      TYPE CHAR2           VALUE 'EQ',
           GC_SC      TYPE CHAR2           VALUE 'SC',
           GC_1100    TYPE EKORG           VALUE '1100',
           GC_F60     TYPE EKGRP           VALUE 'F60',
           GC_H60     TYPE EKGRP           VALUE 'H60',
           GC_0011    TYPE VERID           VALUE '0011',
           GC_FERT    TYPE MTART           VALUE 'FERT',
           GC_HALB    TYPE MTART           VALUE 'HALB',
           GC_2540    TYPE LGORT_D         VALUE '2540',
           GC_2550    TYPE LGORT_D         VALUE '2550',
           GC_PP      TYPE ZGTEMODULE_KIND VALUE 'PP',
           GC_2030    TYPE ZGTECODEGRP     VALUE '2030',
           GC_2040    TYPE ZGTECODEGRP     VALUE '2040',
           GC_3050    TYPE ZGTECODEGRP     VALUE '3050',
           GC_KBDM    TYPE ZGTETARGET      VALUE 'KBDM',
           GC_ABUS001 TYPE ZGTE_FLDVAL     VALUE '1a.BUS001',
           GC_BUS001  TYPE ZGTE_FLDVAL     VALUE '1.BUS001',
           GC_INS001  TYPE ZGTE_FLDVAL     VALUE '2.INS001',
           GC_ASM001  TYPE ZGTE_FLDVAL     VALUE '3.ASM001'.
