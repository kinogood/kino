*&---------------------------------------------------------------------*
*& Include          ZGTPPR3070TOP
*&---------------------------------------------------------------------*
TABLES: ZGTPPT3150, ZGTPPT3160, ZGTPPT3170, ZGTSDT0067, ZGTPPT1010,
        VBAK, AUFK, AFKO, AFPO.

* CLASS ZCL_EVENT_RECIEVER DEFINITION
CLASS ZCL_EVENT_RECIEVER DEFINITION DEFERRED.

DATA: BEGIN OF GS_CTOP,
        ORD_STAT      LIKE ICON-ID,                  "생성상태
        ORD_MSG(100),                                "생성메시지
        AUFNR         LIKE ZGTPPT3160-AUFNR,         "생산오더번호
        COMP_ID       LIKE ICON-ID,                  "구성부품 등록
        COMP_MSG(100),                               "등록 메시지
        VBELN         LIKE ZGTSDT0067-VBELN,         "판매오더번호
        POSNR         LIKE ZGTSDT0067-POSNR,         "판매오더품목
        JOB_NO        LIKE ZGTPPT3150-JOB_NO,        "제조지시번호
        JOB_NM        LIKE ZGTEDT2121-ZJOB_NAME,     "제조지시내역
        MAKTX         LIKE MAKT-MAKTX,               "제품내역
        LINE_NO       LIKE ZGTPPT3150-LINE_NO,       "라인번호
        SERIAL_INFO   LIKE ZGTPPT3150-SERIAL_INFO,   "시리얼정보
        MATNR         LIKE ZGTPPT3150-MATNR,         "제품코드
        OPER_CODE_E   LIKE ZGTPPT1010-FLD_02,        "ERP공정
        OPER_NAME_E   LIKE ZGTPPT1010-FLD_03,        "ERP공정명
        LEN_ORDGB     LIKE ZGTPPT1010-FLD_06,        "길이별 오더구분
        OPER_CODE     LIKE ZGTPPT3160-OPER_CODE,     "MES공정
        OPER_NAME     LIKE ZGTPPT3160-OPER_NAME,     "MES공정명
        OPER_MATNR    LIKE ZGTPPT3160-OPER_MATNR,    "생산품목코드
        OPER_MAKTX    LIKE MAKT-MAKTX,               "생산품목내역
        MENGE         LIKE ZGTPPT3160-MENGE,         "생산수량
        MEINS         LIKE ZGTPPT3160-MEINS,         "단위
        KALAB         LIKE MSKA-KALAB,               "재고수량
        L1L7(50),                                    "L1~L7
        ZSTD          LIKE ZGTPPT3150-ZSTD,          "표준피더여부
        WERKS         LIKE ZGTPPT3150-WERKS,         "플랜트
        NAME1         LIKE T001W-NAME1,              "플랜트내역
        ZPJNO         LIKE VBAK-ZPJNO,               "프로젝트번호
        ZPTXT         LIKE ZSD0106T-ZPTXT,           "프로젝트내역
        GSTRP         LIKE AFKO-GSTRP,               "오더시작일
        GLTRP         LIKE AFKO-GLTRP,               "오더종료일
        VERID         LIKE AFPO-VERID,               "생산버전
        NO_DISP       LIKE ZGTPPT3150-NO_DISP,       "제번 조회 제외

        PRCSS_SEQ     LIKE ZGTPPT3160-PRCSS_SEQ,     "공정순번
        PRCSS_SUB_SEQ LIKE ZGTPPT3160-PRCSS_SUB_SEQ, "SUB순번
        ZLENGTH_1     LIKE ZGTPPT3150-ZLENGTH_1,     "길이1(mm)
        ZLENGTH_2     LIKE ZGTPPT3150-ZLENGTH_2,     "길이2(mm)
        ZLENGTH_3     LIKE ZGTPPT3150-ZLENGTH_3,     "길이3(mm)
        ZLENGTH_4     LIKE ZGTPPT3150-ZLENGTH_4,     "길이4(mm)
        ZLENGTH_5     LIKE ZGTPPT3150-ZLENGTH_5,     "길이5(mm)
        ZLENGTH_6     LIKE ZGTPPT3150-ZLENGTH_6,     "길이6(mm)
        ZLENGTH_7     LIKE ZGTPPT3150-ZLENGTH_7,     "길이7(mm)
        COMP_STAT     LIKE ZGTPPT3160-COMP_STAT,     "구성부품 등록 여부
        ZIF_LAST      LIKE ZGTPPT3150-ZIF_LAST,      "최근 인터페이스 키
        IDAT1         LIKE AUFK-IDAT1,               "릴리즈일
        BESKZ         LIKE ZGTPPT3160-BESKZ,         "조달유형
        BUS_PRCSS_SEQ LIKE ZGTPPT3160-PRCSS_SEQ,     "BUS001 발췌용

        CELL_COR      TYPE LVC_T_SCOL,               "cell color
      END OF GS_CTOP.

DATA: BEGIN OF GS_STOP,
*        APPL_STAT     LIKE ICON-ID,                  "최종 적용여부
        AUFNR         LIKE ZGTPPT3160-AUFNR,         "생산오더번호
        ORDSTAT(100),                                "생산오더상태
        UPD_STAT      LIKE ICON-ID,                  "처리상태
        UPD_MSG(100),                                "처리메세지
        KDAUF         LIKE AFPO-KDAUF,               "판매오더번호
        KDPOS         LIKE AFPO-KDPOS,               "판매오더품목
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
        OPER_MATNR    LIKE ZGTPPT3160-OPER_MATNR,    "생산품목코드
        OPER_MAKTX    LIKE MAKT-MAKTX,               "생산품목내역
        MENGE         LIKE ZGTPPT3160-MENGE,         "생산수량
        MEINS         LIKE ZGTPPT3160-MEINS,         "단위
        KALAB         LIKE MSKA-KALAB,               "재고수량
        L1L7(50),                                    "L1~L7
        ZSTD          LIKE ZGTPPT3150-ZSTD,          "표준피더여부
        WERKS         LIKE AUFK-WERKS,               "플랜트
        NAME1         LIKE T001W-NAME1,              "플랜트내역
        ZPJNO         LIKE VBAK-ZPJNO,               "프로젝트번호
        ZPTXT         LIKE ZSD0106T-ZPTXT,           "프로젝트내역
        GSTRP         LIKE AFKO-GSTRP,               "오더시작일
        GLTRP         LIKE AFKO-GLTRP,               "오더종료일
        VERID         LIKE AFPO-VERID,               "생산버전

        PRCSS_SEQ     LIKE ZGTPPT3160-PRCSS_SEQ,     "공정순번
        PRCSS_SUB_SEQ LIKE ZGTPPT3160-PRCSS_SUB_SEQ, "SUB순번
        ZLENGTH_1     LIKE ZGTPPT3150-ZLENGTH_1,     "길이1(mm)
        ZLENGTH_2     LIKE ZGTPPT3150-ZLENGTH_2,     "길이2(mm)
        ZLENGTH_3     LIKE ZGTPPT3150-ZLENGTH_3,     "길이3(mm)
        ZLENGTH_4     LIKE ZGTPPT3150-ZLENGTH_4,     "길이4(mm)
        ZLENGTH_5     LIKE ZGTPPT3150-ZLENGTH_5,     "길이5(mm)
        ZLENGTH_6     LIKE ZGTPPT3150-ZLENGTH_6,     "길이6(mm)
        ZLENGTH_7     LIKE ZGTPPT3150-ZLENGTH_7,     "길이7(mm)
        ZIF_APPLIED   LIKE ZGTPPT3150-ZIF_APPLIED,   "적용 인터페이스 키
        ZIF_LAST      LIKE ZGTPPT3150-ZIF_LAST,      "최근 인터페이스 키
        COMP_STAT     LIKE ZGTPPT3160-COMP_STAT,     "구성부품 등록 여부
        ERDAT         LIKE AUFK-ERDAT,               "생성일
        BUS_PRCSS_SEQ LIKE ZGTPPT3160-PRCSS_SEQ,     "BUS001 발췌용
      END OF GS_STOP.

DATA: BEGIN OF GS_OBOTTOM,
        JOB_NO        LIKE ZGTPPT3150-JOB_NO,        "제조지시번호
        LINE_NO       LIKE ZGTPPT3150-LINE_NO,       "라인번호
        SERIAL_INFO   LIKE ZGTPPT3150-SERIAL_INFO,   "시리얼정보
        PRCSS_SEQ     LIKE ZGTPPT3160-PRCSS_SEQ,     "공정순번
        PRCSS_SUB_SEQ LIKE ZGTPPT3160-PRCSS_SUB_SEQ, "SUB순번
        OPER_CODE     LIKE ZGTPPT3160-OPER_CODE,     "MES공정
        OPER_NAME     LIKE ZGTPPT3160-OPER_NAME,     "MES공정명
        OPER_MATNR    LIKE ZGTPPT3160-OPER_MATNR,    "생산품목코드
        OPER_MAKTX    LIKE MAKT-MAKTX,               "생산품목내역
        MTRL_SEQ      LIKE ZGTPPT3170-MTRL_SEQ,      "자재순번
        MATNR         LIKE ZGTPPT3170-MATNR,         "구성품코드
        MAKTX         LIKE MAKT-MAKTX,               "구성품내역
        MENGE         LIKE ZGTPPT3170-MENGE,         "순소요량
        KAUSF         LIKE ZGTPPT3170-KAUSF,         "LOSS율(%)
        COMP_QTY      LIKE ZGTPPT3170-MENGE,         "총소요량
        MEINS         LIKE MARA-MEINS,               "수량단위

        SBDKZ         LIKE MARC-SBDKZ,               "개별/일괄 소요량 지시자
        RGEKZ         LIKE MARC-RGEKZ,               "백플러시지시자
        OPER_CODE_E   LIKE ZGTPPT1010-FLD_02,        "ERP공정
        OPER_NAME_E   LIKE ZGTPPT1010-FLD_03,        "ERP공정명
        L1L7(50),                                    "L1~L7
      END OF GS_OBOTTOM.

DATA: BEGIN OF GS_BOTTOM,
        OPER_CODE_E LIKE ZGTPPT1010-FLD_02,          "ERP공정
        OPER_NAME_E LIKE ZGTPPT1010-FLD_03,          "ERP공정명
        OPER_MATNR  LIKE ZGTPPT3160-OPER_MATNR,      "생산품목코드
        OPER_MAKTX  LIKE MAKT-MAKTX,                 "생산품목내역
        L1L7(50),                                    "L1~L7
        MTRL_SEQ    LIKE ZGTPPT3170-MTRL_SEQ,        "자재순번
        MATNR       LIKE ZGTPPT3170-MATNR,           "구성품코드
        MAKTX       LIKE MAKT-MAKTX,                 "구성품내역
        MENGE       LIKE ZGTPPT3170-MENGE,           "순소요량
        KAUSF       LIKE ZGTPPT3170-KAUSF,           "LOSS율(%)
        COMP_QTY    LIKE ZGTPPT3170-MENGE,           "총소요량
        MEINS       LIKE MARA-MEINS,                 "수량단위

        SBDKZ       LIKE MARC-SBDKZ,                 "개별/일괄 소요량 지시자
        RGEKZ       LIKE MARC-RGEKZ,                 "백플러시지시자
      END OF GS_BOTTOM.

DATA: BEGIN OF GS_ORDERC,
        VBELN      LIKE ZGTSDT0067-VBELN,         "판매오더번호
        POSNR      LIKE ZGTSDT0067-POSNR,         "판매오더품목
        OPER_MATNR LIKE ZGTPPT3160-OPER_MATNR,    "생산품목코드
        L1L7(50),                                 "L1~L7
        MENGE      LIKE ZGTPPT3160-MENGE,         "생산수량
      END OF GS_ORDERC.

DATA: BEGIN OF GS_AUFNR_SEND,
        AUFNR LIKE AUFK-AUFNR,
        ERDAT LIKE AUFK-ERDAT,
      END OF GS_AUFNR_SEND.
DATA: GT_AUFNR_SEND LIKE TABLE OF GS_AUFNR_SEND.

DATA: BEGIN OF GS_1010.
        INCLUDE STRUCTURE ZGTPPT1010.
DATA: END OF GS_1010.
DATA: GT_1010  LIKE TABLE OF GS_1010.

*SRM2510-03432 제조지시번호별 잠금 추가
DATA : BEGIN OF GT_LOCK OCCURS 0,
         JOB_NO LIKE ZGTPPT3160-JOB_NO,
       END   OF GT_LOCK.

DATA : GT_ENQ LIKE SEQG3 OCCURS 0 WITH HEADER LINE.

TYPES: BEGIN OF TY_RESB_BT.
         INCLUDE TYPE RESBB.
TYPES:   INDOLD     TYPE SYST_TABIX,
         NO_REQ_UPD TYPE SYST_DATAR,
       END OF TY_RESB_BT.

TYPES TT_RESB_BT TYPE TABLE OF TY_RESB_BT.

DATA: GS_RETURN TYPE COXT_BAPIRETURN,
      GV_ERROR.

DATA: GS_STORAGE_LOCATION  TYPE COXT_S_STORAGE_LOCATION,
      GS_STORAGE_LOCATIONX TYPE COXT_S_STORAGE_LOCATIONX,
      GS_REQU_QUAN         TYPE COXT_S_QUANTITY,
      GV_OPERATION         TYPE CO_APLZL,
      GV_POSTP             TYPE POSTP,
      GV_SEQUENCE          TYPE PLNFOLGE,
      GV_MATERIAL          TYPE MATNR,
      GV_POSITIONNO        TYPE POSITIONNO,
      GV_KDAUF             TYPE COXT_KDAUF,
      GV_KDPOS             TYPE COXT_KDPOS,
      GV_KDAUFX,
      GV_KDPOSX,
      GV_SOBKZ             TYPE SOBKZ,
      GV_SOBKZX,
      GV_NUMC              TYPE NUMC4,
      GV_POSNR             TYPE POSNR.

DATA: GT_CTOP     LIKE TABLE OF GS_CTOP WITH EMPTY KEY,
      GT_STOP     LIKE TABLE OF GS_STOP WITH EMPTY KEY,
      GT_OBOTTOM  LIKE TABLE OF GS_OBOTTOM,
      GT_OBOTTOMB LIKE TABLE OF GS_OBOTTOM,
      GT_BOTTOM   LIKE TABLE OF GS_BOTTOM,
      GT_ORDERC   LIKE TABLE OF GS_ORDERC,
      GT_CTOPS    LIKE TABLE OF GS_CTOP,
      GT_STOPS    LIKE TABLE OF GS_STOP.

FIELD-SYMBOLS: <FT_RESB_BT> TYPE TT_RESB_BT,
               <FS_RESB_BT> TYPE TY_RESB_BT.

DATA: GO_DOCKING_CONTAINER TYPE REF TO CL_GUI_DOCKING_CONTAINER.
DATA: GO_SPLITTER TYPE REF TO CL_GUI_SPLITTER_CONTAINER.

*- ALV GRID TOP
DATA: GO_CONTAIN_0100 TYPE REF TO CL_GUI_CONTAINER.
DATA: GO_GRID_0100 TYPE REF TO CL_GUI_ALV_GRID.
DATA: GO_EVTR_0100 TYPE REF TO ZCL_EVENT_RECIEVER.
DATA: GS_VARIANT TYPE DISVARIANT.
DATA: GS_LAYOUT_0100 TYPE LVC_S_LAYO.
DATA: GT_SORT_0100 TYPE LVC_T_SORT.
DATA: GT_EXCLUDE_0100 TYPE UI_FUNCTIONS.
DATA: GT_FIELDCAT_0100 TYPE LVC_T_FCAT.

*- ALV GRID BOTTOM
DATA: GO_CONTAIN_0101 TYPE REF TO CL_GUI_CONTAINER.
DATA: GO_GRID_0101 TYPE REF TO CL_GUI_ALV_GRID.
DATA: GS_LAYOUT_0101 TYPE LVC_S_LAYO.
DATA: GT_SORT_0101 TYPE LVC_T_SORT.
DATA: GT_EXCLUDE_0101 TYPE UI_FUNCTIONS.
DATA: GT_FIELDCAT_0101 TYPE LVC_T_FCAT.

DATA: GT_UCOMM TYPE TABLE OF SY-UCOMM.

DATA: GV_OK_CODE TYPE SYUCOMM,
      GV_DBCNT   TYPE CHAR10.

DATA: GV_REPID TYPE SYREPID,
      GV_VALID TYPE CHAR01,
      GV_INDEX TYPE SY-TABIX,
      GV_TEXT  TYPE CHAR255,
      GV_SEQ   LIKE ZGTPPT3170-MTRL_SEQ,
      GV_LCK.

RANGES: GR_JOB_STATUS FOR ZGTPPT1010-FLD_02,
        GR_JOB_TYPE   FOR ZGTPPT1010-FLD_02,
        GR_JOB_NO     FOR ZGTEDT2121-ZJOB_NO.

CONSTANTS: GC_C       TYPE CHAR1           VALUE 'C',
           GC_D       TYPE CHAR1           VALUE 'D',
           GC_E       TYPE CHAR1           VALUE 'E',
           GC_F       TYPE CHAR1           VALUE 'F',
           GC_I       TYPE CHAR1           VALUE 'I',
           GC_K       TYPE CHAR1           VALUE 'K',
           GC_L       TYPE CHAR1           VALUE 'L',
           GC_P       TYPE CHAR1           VALUE 'P',
           GC_R       TYPE CHAR1           VALUE 'R',
           GC_S       TYPE CHAR1           VALUE 'S',
           GC_W       TYPE CHAR1           VALUE 'W',
           GC_X       TYPE CHAR1           VALUE 'X',
           GC_Y       TYPE CHAR1           VALUE 'Y',
           GC_ALL     TYPE CHAR1           VALUE '*',
           GC_EQ      TYPE CHAR2           VALUE 'EQ',
           GC_01      TYPE NUMC2           VALUE '01',
           GC_0010    TYPE VERID           VALUE '0010',
           GC_0011    TYPE VERID           VALUE '0011',
           GC_PP      TYPE ZGTEMODULE_KIND VALUE 'PP',
           GC_2030    TYPE ZGTECODEGRP     VALUE '2030',
           GC_2040    TYPE ZGTECODEGRP     VALUE '2040',
           GC_3040    TYPE ZGTECODEGRP     VALUE '3040',
           GC_KBDM    TYPE ZGTETARGET      VALUE 'KBDM',
           GC_ABUS001 TYPE ZGTE_FLDVAL     VALUE '1a.BUS001',
           GC_BUS001  TYPE ZGTE_FLDVAL     VALUE '1.BUS001',
           GC_INS001  TYPE ZGTE_FLDVAL     VALUE '2.INS001',
           GC_ASM001  TYPE ZGTE_FLDVAL     VALUE '3.ASM001'.
