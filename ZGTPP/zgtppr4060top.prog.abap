*&---------------------------------------------------------------------*
*& Include          ZGTPPR4060TOP
*&---------------------------------------------------------------------*
TABLES: MARD,
        ZGTPPT4020, ZGTPPT4030, ZGTPPT4040.
TABLES: SSCRFIELDS.

* CLASS ZCL_EVENT_RECIEVER DEFINITION
CLASS ZCL_EVENT_RECIEVER DEFINITION DEFERRED.

INCLUDE <CL_ALV_CONTROL>.

*-업로드 포멧(포장재)
DATA: BEGIN OF GS_PUPLOAD,
        PCKTYPE LIKE ZGTPPT4020-PCKTYPE,    "구분
        MATNR   LIKE ZGTPPT4020-MATNR,      "자재코드
        MENGE   LIKE ZGTPPT4020-MENGE,      "수량
      END OF GS_PUPLOAD.
DATA: GT_PUPLOAD LIKE TABLE OF GS_PUPLOAD.

*-업로드 DISPLAY(포장재)
DATA: BEGIN OF GS_PDATA,
        UP_STAT     LIKE ICON-ID,            "처리상태
        UP_MSG(100),                         "처리메시지
        ZGINO       LIKE ZGTPPT4020-ZGINO,   "투입이력번호
        MATNR       LIKE ZGTPPT4020-MATNR,   "자재코드
        MAKTX       LIKE MAKT-MAKTX,         "자재내역
        PCKTYPE     LIKE ZGTPPT4020-PCKTYPE, "구분
        MENGE       LIKE ZGTPPT4020-MENGE,   "투입수량
        MEINS       LIKE ZGTPPT4020-MEINS,   "수량단위

        PCKCODE(1),                          "구분코드(내수:I,수출:O)
        REALMENGE   LIKE ZGTPPT4020-MENGE,   "실제투입수량(카운트용)
      END OF GS_PDATA.
DATA: GT_PDATA LIKE TABLE OF GS_PDATA.

*-투입 처리 BOTTOM DISPLAY(포장재)
DATA: BEGIN OF GS_BOTTOM,
        GI_STAT     LIKE ICON-ID,             "투입처리상태
        GI_MSG(100),                          "투입처리메시지
        ZGINO       LIKE ZGTPPT4020-ZGINO,    "투입이력번호
        PCKTYPE     LIKE ZGTPPT4020-PCKTYPE,  "구분
        ZPJNO       LIKE ZGTPPT4030-ZPJNO,    "프로젝트번호
        ZPTXT       LIKE ZSD0106T-ZPTXT,      "프로젝트내역
        TOT_QTY     LIKE ZGTPPT4030-TOT_QTY,  "조립식적수량
        TOT_UNIT    LIKE ZGTPPT4030-TOT_UNIT, "실적수량단위
        AS_QTY      LIKE ZGTPPT4030-AS_QTY,   "할당수량
        AS_UNIT     LIKE ZGTPPT4030-AS_UNIT,  "할당수량단위
        AUFNR       LIKE ZGTPPT4030-AUFNR,    "생산오더번호
        GR_QTY      LIKE ZGTPPT4030-GR_QTY,   "생산입고수량
        GR_UNIT     LIKE ZGTPPT4030-GR_UNIT,  "생산입고단위
        MATNR       LIKE ZGTPPT4030-MATNR,    "자재코드
        MAKTX       LIKE MAKT-MAKTX,          "자재내역
        GI_QTY      LIKE ZGTPPT4030-GI_QTY,   "투입수량
        GI_UNIT     LIKE ZGTPPT4030-GI_UNIT,  "투입수량단위
        MBLNR       LIKE ZGTPPT4030-MBLNR,    "자재문서번호
        MJAHR       LIKE ZGTPPT4030-MJAHR,    "자재문서연도

        PCKCODE(1),                           "구분코드(내수:I,수출:O)
      END OF GS_BOTTOM.
DATA: GT_BOTTOM LIKE TABLE OF GS_BOTTOM.

*-투입 결과 조회/취소(포장재)
DATA: BEGIN OF GS_REVDATA,
        GI_STAT  LIKE ICON-ID,                "투입처리상태
        ZMSG     LIKE ZGTPPT4030-ZMSG,        "투입처리메시지
        ZGINO    LIKE ZGTPPT4030-ZGINO,       "투입이력번호
        PCKTYPE  LIKE ZGTPPT4020-PCKTYPE,     "구분
        ZPJNO    LIKE ZGTPPT4030-ZPJNO,       "프로젝트번호
        ZPTXT    LIKE ZSD0106T-ZPTXT,         "프로젝트내역
        TOT_QTY  LIKE ZGTPPT4030-TOT_QTY,  "조립식적수량
        TOT_UNIT LIKE ZGTPPT4030-TOT_UNIT, "실적수량단위
        AS_QTY   LIKE ZGTPPT4030-AS_QTY,      "할당수량
        AS_UNIT  LIKE ZGTPPT4030-AS_UNIT,     "할당수량단위
        AUFNR    LIKE ZGTPPT4030-AUFNR,       "생산오더번호
        GR_QTY   LIKE ZGTPPT4030-GR_QTY,      "생산입고수량
        GR_UNIT  LIKE ZGTPPT4030-GR_UNIT,     "생산입고단위
        MATNR    LIKE ZGTPPT4030-MATNR,       "자재코드
        MAKTX    LIKE MAKT-MAKTX,             "자재내역
        GI_QTY   LIKE ZGTPPT4030-GI_QTY,      "투입수량
        GI_UNIT  LIKE ZGTPPT4030-GI_UNIT,     "투입수량단위
        MBLNR    LIKE ZGTPPT4030-MBLNR,       "자재문서번호
        MJAHR    LIKE ZGTPPT4030-MJAHR,       "자재문서연도
        CRDAT    LIKE ZGTPPT4030-CRDAT,       "생성일자
        CRTIM    LIKE ZGTPPT4030-CRTIM,       "생성시간
        CRNAM    LIKE ZGTPPT4030-CRNAM,       "생성자

        ZSTAT    LIKE ZGTPPT4030-ZSTAT,       "투입처리상태
      END OF GS_REVDATA.
DATA: GT_REVDATA LIKE TABLE OF GS_REVDATA WITH EMPTY KEY.

*-업로드 포멧(정산자재_수기배부)
DATA: BEGIN OF GS_CHUPLOAD,
        AUFNR  LIKE ZGTPPT4040-AUFNR,      "생산오더
        MATNR  LIKE ZGTPPT4040-MATNR,      "자재코드
        GI_QTY LIKE ZGTPPT4040-GI_QTY,     "수량
      END OF GS_CHUPLOAD.
DATA: GT_CHUPLOAD LIKE TABLE OF GS_CHUPLOAD.

*-업로드 포멧(정산자재_생산비율배부)
DATA: BEGIN OF GS_CRUPLOAD,
        MATNR  LIKE ZGTPPT4040-MATNR,      "자재코드
        GI_QTY LIKE ZGTPPT4040-GI_QTY,     "수량
      END OF GS_CRUPLOAD.
DATA: GT_CRUPLOAD LIKE TABLE OF GS_CRUPLOAD.

*-업로드 투입 수량(정산자재_생산비율배부)
DATA: BEGIN OF GS_CRDATA,
        MATNR    LIKE ZGTPPT4040-MATNR,      "자재코드
        GI_QTY   LIKE ZGTPPT4040-GI_QTY,     "수량
        REAL_QTY LIKE ZGTPPT4040-GI_QTY,
      END OF GS_CRDATA.
DATA: GT_CRDATA  LIKE TABLE OF GS_CRDATA.

*-업로드 및 투입 처리 DISPLAY(정산자재)
DATA: BEGIN OF GS_CDATA,
        GI_STAT     LIKE ICON-ID,              "투입처리상태
        GI_MSG(100),                           "투입처리메시지
        ZGINO       LIKE ZGTPPT4040-ZGINO,     "투입이력번호
        ZPJNO       LIKE VBAK-ZPJNO,           "프로젝트번호
        ZPTXT       LIKE ZSD0106T-ZPTXT,       "프로젝트내역
        BSTNK       LIKE VBAK-BSTNK,           "제조지시번호
        JOBNM       LIKE ZGTEDT2121-ZJOB_NAME, "제조지시내역
        KDAUF       LIKE AFPO-KDAUF,           "판매오더번호
        KDPOS       LIKE AFPO-KDPOS,           "판매오더품목
        AUFNR       LIKE ZGTPPT4040-AUFNR,     "생산오더번호
        WEMNG       LIKE AFPO-WEMNG,           "생산입고수량
        GMEIN       LIKE AFKO-GMEIN,           "생산입고단위
        MATNR       LIKE AFPO-MATNR,           "자재코드
        MAKTX       LIKE MAKT-MAKTX,           "자재내역
        GI_QTY      LIKE ZGTPPT4040-GI_QTY,    "투입수량
        GI_UNIT     LIKE ZGTPPT4040-GI_UNIT,   "투입수량단위
        MBLNR       LIKE ZGTPPT4040-MBLNR,     "자재문서번호
        MJAHR       LIKE ZGTPPT4040-MJAHR,     "자재문서연도
      END OF GS_CDATA.
DATA: GT_CDATA LIKE TABLE OF GS_CDATA.

*-생산오더 입고 실적(정산자재_생산비율배부)
DATA: BEGIN OF GS_PRDGR_CR,
        KDAUF LIKE AFPO-KDAUF,           "판매오더번호
        KDPOS LIKE AFPO-KDPOS,           "판매오더품목
        AUFNR LIKE ZGTPPT4040-AUFNR,     "생산오더번호
        MATNR LIKE AFPO-MATNR,           "자재코드
        ZPJNO LIKE VBAK-ZPJNO,           "프로젝트번호
        BSTNK LIKE VBAK-BSTNK,           "제조지시번호
        WEMNG LIKE AFPO-WEMNG,           "생산입고수량
        GMEIN LIKE AFKO-GMEIN,           "생산입고단위
        MAKTX LIKE MAKT-MAKTX,           "자재내역
        ZPTXT LIKE ZSD0106T-ZPTXT,       "프로젝트내역
        JOBNM LIKE ZGTEDT2121-ZJOB_NAME, "제조지시내역
      END OF GS_PRDGR_CR.
DATA: GT_PRDGR_CR LIKE TABLE OF GS_PRDGR_CR,
      GT_PRDGR_1  LIKE TABLE OF GS_PRDGR_CR.  "입고max오더

*-생산오더 입고 수량 SUM(정산자재_생산비율배부)
DATA: GV_SWEMNG TYPE MENG15.       "수량SUM

*-투입 결과 조회/취소(정산자재)
DATA: BEGIN OF GS_CREVDATA,
        GI_STAT LIKE ICON-ID,              "투입처리상태
        ZMSG    LIKE ZGTPPT4040-ZMSG,      "투입처리메시지
        ZGINO   LIKE ZGTPPT4040-ZGINO,     "투입이력번호
        ZPJNO   LIKE ZGTPPT4030-ZPJNO,     "프로젝트번호
        ZPTXT   LIKE ZSD0106T-ZPTXT,       "프로젝트내역
        BSTNK   LIKE VBAK-BSTNK,           "제조지시번호
        JOBNM   LIKE ZGTEDT2121-ZJOB_NAME, "제조지시내역
        KDAUF   LIKE AFPO-KDAUF,           "판매오더번호
        KDPOS   LIKE AFPO-KDPOS,           "판매오더품목
        AUFNR   LIKE ZGTPPT4040-AUFNR,     "생산오더번호
        WEMNG   LIKE AFPO-WEMNG,           "생산입고수량
        GMEIN   LIKE AFKO-GMEIN,           "생산입고단위
        MATNR   LIKE AFPO-MATNR,           "자재코드
        MAKTX   LIKE MAKT-MAKTX,           "자재내역
        GI_QTY  LIKE ZGTPPT4040-GI_QTY,    "투입수량
        GI_UNIT LIKE ZGTPPT4040-GI_UNIT,   "투입수량단위
        MBLNR   LIKE ZGTPPT4040-MBLNR,     "자재문서번호
        MJAHR   LIKE ZGTPPT4040-MJAHR,     "자재문서연도
        CRDAT   LIKE ZGTPPT4040-CRDAT,     "생성일자
        CRTIM   LIKE ZGTPPT4040-CRTIM,     "생성시간
        CRNAM   LIKE ZGTPPT4040-CRNAM,     "생성자

        ZSTAT   LIKE ZGTPPT4040-ZSTAT,     "투입처리상태
      END OF GS_CREVDATA.
DATA: GT_CREVDATA LIKE TABLE OF GS_CREVDATA.

*-구분(내수/수출)별 업로드 SUM
DATA: BEGIN OF GS_PCKSUM,
        PCKCODE(1),                   "구분코드(내수:I,수출:O)
        SMENGE     TYPE MENG15,       "수량SUM
        SMEINS     LIKE MATDOC-MEINS, "수량SUM단위
      END OF GS_PCKSUM.
DATA: GT_PCKSUM   LIKE TABLE OF GS_PCKSUM,
      GT_ZPJNOSUM LIKE TABLE OF GS_PCKSUM,  "프로젝트 구분별 SUM
      GT_AUFNRSUM LIKE TABLE OF GS_PCKSUM.  "

*-조립 실적
DATA: BEGIN OF GS_AS,
        PCKCODE(1),                        "구분코드(내수:I,수출:O)
        ZPJNO      LIKE VBAK-ZPJNO,        "프로젝트번호
        JOB_NO     LIKE ZGTPPT3160-JOB_NO, "제조지시번호
        AUFNR      LIKE MATDOC-AUFNR,      "오더
        MENGE      LIKE MATDOC-MENGE,      "수량
        MEINS      LIKE MATDOC-MEINS,      "단위
        KDAUF      LIKE AFPO-KDAUF,        "판매오더
        KDPOS      LIKE AFPO-KDPOS,        "판매품목
        MTART      LIKE MARA-MTART,        "자재유형
        LAND1      LIKE ZSD0106T-LAND1,    "국가/지역 키

        MBLNR      LIKE MATDOC-MBLNR,
        ZEILE      LIKE MATDOC-ZEILE,
        MJAHR      LIKE MATDOC-MJAHR,
      END OF GS_AS.
DATA: GT_AS LIKE TABLE OF GS_AS.

*-조립실적 구분/프로젝트 SUM
DATA: BEGIN OF GS_ZPJNOSUM,
        PCKCODE(1),                         "구분코드(내수:I,수출:O)
        ZPJNO      LIKE VBAK-ZPJNO,         "프로젝트번호
        SMENGE     TYPE MENG15,             "수량SUM
        SMEINS     LIKE MATDOC-MEINS,       "수량SUM단위
        AS_QTY     LIKE ZGTPPT4030-AS_QTY,  "할당수량
        AS_UNIT    LIKE ZGTPPT4030-AS_UNIT, "할당수량단위

        REALASQTY  LIKE ZGTPPT4030-AS_QTY,  "실제할당수량(카운트용)
      END OF GS_ZPJNOSUM.
DATA: GT_ZPJNOSUMI LIKE TABLE OF GS_ZPJNOSUM,
      GT_ZPJNOSUMO LIKE TABLE OF GS_ZPJNOSUM.

*-조립실적 구분/프로젝트/오더 SUM
DATA: BEGIN OF GS_AUFNRSUM,
        PCKCODE(1),                        "구분코드(내수:I,수출:O)
        ZPJNO      LIKE VBAK-ZPJNO,        "프로젝트번호
        JOB_NO     LIKE ZGTPPT3160-JOB_NO, "제조지시번호
        AUFNR      LIKE MATDOC-AUFNR,      "오더
        SMENGE     TYPE MENG15,            "수량SUM
        SMEINS     LIKE MATDOC-MEINS,      "수량SUM단위
        CHK(1),
      END OF GS_AUFNRSUM.
DATA: GT_AUFNRSUMI LIKE TABLE OF GS_AUFNRSUM,
      GT_AUFNRSUMO LIKE TABLE OF GS_AUFNRSUM.

DATA: GO_DOCKING_CONTAINER TYPE REF TO CL_GUI_DOCKING_CONTAINER.
DATA: GO_SPLITTER TYPE REF TO CL_GUI_SPLITTER_CONTAINER.

*- ALV GRID TOP
DATA: GO_CONTAIN_0100 TYPE REF TO CL_GUI_CONTAINER.
DATA: GO_DD_DOCU_0100 TYPE REF TO CL_DD_DOCUMENT.
DATA: GO_CONTAIN_TOP_0100 TYPE REF TO CL_GUI_CONTAINER.
DATA: GO_GRID_0100 TYPE REF TO CL_GUI_ALV_GRID.
DATA: GO_EVTR_0100 TYPE REF TO ZCL_EVENT_RECIEVER.
DATA: GS_VARIANT TYPE DISVARIANT.
DATA: GS_LAYOUT_0100 TYPE LVC_S_LAYO.
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

DATA: GV_DYNTXT TYPE SMP_DYNTXT.

DATA: GV_OK_CODE TYPE SYUCOMM,
      GV_DBCNT   TYPE CHAR10,
      GV_ZGINO   LIKE ZGTPPT4020-ZGINO,
      GV_SEQ(5)  TYPE N,
      GV_BUDAT   LIKE MATDOC-BUDAT,
      GV_ZCAT    LIKE ZGTPPT4020-ZCAT.

RANGES: GR_GSTRP FOR AFKO-GSTRP,
        GR_MTART FOR MARA-MTART,
        GR_MATKL FOR MARA-MATKL.

CONSTANTS: GC_0          TYPE PSTYP           VALUE '0',
           GC_3          TYPE PSTYP           VALUE '3',
           GC_A          TYPE CHAR1           VALUE 'A',
           GC_C          TYPE CHAR1           VALUE 'C',
           GC_D          TYPE CHAR1           VALUE 'D',
           GC_E          TYPE CHAR1           VALUE 'E',
           GC_F          TYPE CHAR1           VALUE 'F',
           GC_I          TYPE CHAR1           VALUE 'I',
           GC_K          TYPE CHAR1           VALUE 'K',
           GC_L          TYPE CHAR1           VALUE 'L',
           GC_M          TYPE CHAR1           VALUE 'M',
           GC_O          TYPE CHAR1           VALUE 'O',
           GC_P          TYPE CHAR1           VALUE 'P',
           GC_R          TYPE CHAR1           VALUE 'R',
           GC_S          TYPE CHAR1           VALUE 'S',
           GC_W          TYPE CHAR1           VALUE 'W',
           GC_X          TYPE CHAR1           VALUE 'X',
           GC_Y          TYPE CHAR1           VALUE 'Y',
           GC_ALL        TYPE CHAR1           VALUE '*',
           GC_EQ         TYPE CHAR2           VALUE 'EQ',
           GC_BT         TYPE CHAR2           VALUE 'BT',
           GC_SC         TYPE CHAR2           VALUE 'SC',
           GC_PP         TYPE ZGTEMODULE_KIND VALUE 'PP',
           GC_4030       TYPE ZGTECODEGRP     VALUE '4030',
           GC_101        TYPE BWART           VALUE '101',
           GC_261        TYPE BWART           VALUE '261',
           GC_FERT       TYPE MTART           VALUE 'FERT',
           GC_1306       TYPE WERKS_D         VALUE '1306',
           GC_2510       TYPE LGORT_D         VALUE '2510',
           GC_ZGTPPR4060 TYPE BKTXT           VALUE 'ZGTPPR4060',
           GC_PP04       TYPE AUART           VALUE 'PP04',
           C_START_COL   TYPE I               VALUE '1',
           C_START_ROW   TYPE I               VALUE '2  ',
           C_END_COL     TYPE I               VALUE '256',
           C_END_ROW     TYPE I               VALUE '65536'.
