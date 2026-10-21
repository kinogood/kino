*&---------------------------------------------------------------------*
*& Include          ZGTPPR9011TOP
*&---------------------------------------------------------------------*
TABLES: MSKA, MARA, MARD, MATDOC, AUFK, VBKD, VBAK,
        ZGTPPT9010, ZGTPPT9020, ZGTSDT9060, ZGTSDT0066.

INCLUDE <CL_ALV_CONTROL>.   " ALV Control (Ex. Fonts, Styles)

* CLASS ZCL_EVENT_RECIEVER DEFINITION
CLASS ZCL_EVENT_RECIEVER DEFINITION DEFERRED.

DATA: BEGIN OF GS_STOCK,
        STAT_SAVE       LIKE ICON-ID,                "저장상태
        RTMSG(100),                                  "저장 메시지
        ZSTOCK_TYPE     LIKE ZGTPPT9010-ZSTOCK_TYPE, "재고유형
        ZSTOCK_NAME(40),                             "재고유형내역
        WERKS           LIKE MSKA-WERKS,             "플랜트
        NAME1           LIKE T001W-NAME1,            "플랜트내역
        LGORT           LIKE MSKA-LGORT,             "저장위치
        LGOBE           LIKE T001L-LGOBE,            "저장위치내역
        SOBKZ           LIKE MSKA-SOBKZ,             "특별재고지시자
        MATNR           LIKE MSKA-MATNR,             "자재코드
        MAKTX           LIKE MAKT-MAKTX,             "자재내역
        VBELN           LIKE MSKA-VBELN,             "판매오더번호
        POSNR           LIKE MSKA-POSNR,             "판매오더품목
        JOB_NO          LIKE VBKD-BSTKD_E,           "제조지시번호
        CHARG           LIKE MSKA-CHARG,             "배치번호
        LWEDT           LIKE MCHA-LWEDT,             "최종입고입
        KALAB           LIKE MSKA-KALAB,             "재고수량
        MEINS           LIKE MARA-MEINS,             "재고단위
        MTART           LIKE MARA-MTART,             "자재유형
        MATKL           LIKE MARA-MATKL,             "자재그룹
        KWMENG          LIKE VBAP-KWMENG,            "판매오더수량
        VRKME           LIKE VBAP-VRKME,             "수량단위
        STD_PROD_NM     LIKE ZLES001-ATWRT,          "형상코드
        STD_PROD_DSCR   LIKE ZLES001-ATWTB,          "형상품명
        PROD_NM         LIKE ZLES001-ATWRT,          "견적코드
        PROD_DSCR       LIKE ZLES001-ATWTB,          "견적품명

        MTBEZ           LIKE T134T-MTBEZ,            "자재유형내역
        WGBEZ           LIKE T023T-WGBEZ,            "자재그룹내역
      END OF GS_STOCK.
DATA: GT_STOCK LIKE TABLE OF GS_STOCK.

DATA: BEGIN OF GS_TRANS,
        ZSTOCK_TYPE     LIKE ZGTPPT9010-ZSTOCK_TYPE,   "재고유형
        ZSTOCK_NAME(40),                               "재고유형내역
        WERKS           LIKE ZGTPPT9010-WERKS,         "플랜트
        NAME1           LIKE T001W-NAME1,              "플랜트내역
        LGORT           LIKE ZGTPPT9010-LGORT,         "저장위치
        LGOBE           LIKE T001L-LGOBE,              "저장위치내역
        SOBKZ           LIKE ZGTPPT9010-SOBKZ,         "특별재고지시자
        ZSTOCK_NO       LIKE ZGTPPT9010-ZSTOCK_NO,     "재고번호
        ZSTOCK_SEQ      LIKE ZGTPPT9020-ZSTOCK_SEQ,    "재고순번
        STAT_TRANSORD   LIKE ICON-ID,                  "재고변환 생산오더 상태
        AUFNR           LIKE ZGTPPT9020-AUFNR,         "재고변환 생산오더
        STAT_OMATGI     LIKE ICON-ID,                  "기존재고 투입상태
        STAT_BATCHCRE   LIKE ICON-ID,                  "배치번호 생성상태
        STAT_NMATGR     LIKE ICON-ID,                  "신규재고 입고상태
        RTMSG(100),                                    "처리메시지
        N_MATNR         LIKE VBAP-MATNR,               "신규 자재코드
        N_MAKTX         LIKE MAKT-MAKTX,               "신규 자재내역
        N_VBELN         LIKE VBAP-VBELN,               "신규 판매오더번호
        N_POSNR         LIKE VBAP-POSNR,               "신규 판매오더품목
        N_JOB_NO        LIKE ZGTSDT0066-JOB_NO,        "신규 제조지시번호
        N_CHARG         LIKE ZGTPPT9020-N_CHARG,       "신규 배치번호
        N_LWEDT         LIKE ZGTPPT9020-N_LWEDT,       "신규 최종입고일
        N_KALAB         LIKE ZGTPPT9020-N_KALAB,       "신규 재고수량
        N_MEINS         LIKE ZGTPPT9020-N_MEINS,       "신규 재고단위
        N_MTART         LIKE MARA-MTART,               "신규 자재유형
        N_MATKL         LIKE MARA-MATKL,               "신규 자재그룹
        N_KWMENG        LIKE ZGTPPT9020-N_KWMENG,      "신규 판매오더수량
        N_LENGTH        LIKE ZGTPPT9020-N_LENGTH,      "신규 총길이
        N_SERIAL_CNT    LIKE ZGTPPT9020-N_SERIAL_CNT,  "신규 시리얼번호수
        O_MATNR         LIKE ZGTPPT9010-O_MATNR,       "기존 자재코드
        O_MAKTX         LIKE MAKT-MAKTX,               "기존 자재내역
        O_VBELN         LIKE ZGTPPT9010-O_VBELN,       "기존 판매오더번호
        O_POSNR         LIKE ZGTPPT9010-O_POSNR,       "기존 판매오더품목
        O_JOB_NO        LIKE ZGTPPT9010-O_JOB_NO,      "기존 제조지시번호
        O_CHARG         LIKE ZGTPPT9010-O_CHARG,       "기존 배치번호
        O_LWEDT         LIKE ZGTPPT9010-O_LWEDT,       "기존 최종입고일
        O_KALAB         LIKE ZGTPPT9010-O_KALAB,       "기존 재고수량
        O_MEINS         LIKE ZGTPPT9010-O_MEINS,       "기존 재고단위
        O_MTART         LIKE MARA-MTART,               "기존 자재유형
        O_MATKL         LIKE MARA-MATKL,               "기존 자재그룹
        O_KWMENG        LIKE ZGTPPT9010-O_KWMENG,      "기존 판매오더수량
        O_VRKME         LIKE ZGTPPT9010-O_VRKME,       "기존 수량단위
        O_STD_PROD_NM   LIKE ZGTPPT9010-O_STD_PROD_NM, "형상코드
        O_STD_PROD_DSCR LIKE ZGTPPT1010-FLD_02,        "형상내역
        O_PROD_NM       LIKE ZGTPPT9010-O_PROD_NM,     "견적품명코드
        O_PROD_DSCR     LIKE ZGTPPT1010-FLD_04,        "견적품명내역
        O_PROD_MNG      LIKE ZGTPPT1010-FLD_05,        "견적품수량
        CRDAT           LIKE ZGTPPT9010-CRDAT,         "생성일자
        CRTIM           LIKE ZGTPPT9010-CRTIM,         "생성시간
        CRNAM           LIKE ZGTPPT9010-CRNAM,         "생성자

        MKEY            LIKE ZGTSDT0066-MKEY,          "Mapping Key
        ZPJNO           LIKE VBAK-ZPJNO,               "Project NO
        N_MTBEZ         LIKE T134T-MTBEZ,              "신규자재유형내역
        N_WGBEZ         LIKE T023T-WGBEZ,              "신규자재그룹내역
        O_MTBEZ         LIKE T134T-MTBEZ,              "기존자재유형내역
        O_WGBEZ         LIKE T023T-WGBEZ,              "기존자재그룹내역
        MBLNR_GI        LIKE ZGTPPT9020-MBLNR_GI,      "기존재고 투입 자재문서
        MJAHR_GI        LIKE ZGTPPT9020-MJAHR_GI,      "기존재고투입년도
        MBLNR_GR        LIKE ZGTPPT9020-MBLNR_GR,      "신규재고 입고 자재문서
        MJAHR_GR        LIKE ZGTPPT9020-MJAHR_GR,      "신규재고입고년도
        VERID           LIKE MKAL-VERID,               "생산버전

        CELL_STY        TYPE LVC_T_STYL,               "cell style
      END OF GS_TRANS.
DATA: GT_TRANS   LIKE TABLE OF GS_TRANS,
      GT_TRANS_I LIKE TABLE OF GS_TRANS.

DATA: BEGIN OF GS_TRANS_C,
        ZSTOCK_TYPE     LIKE ZGTPPT9020-ZSTOCK_TYPE,   "재고유형
        ZSTOCK_NAME(40),                               "재고유형내역
        WERKS           LIKE ZGTPPT9020-WERKS,         "플랜트
        NAME1           LIKE T001W-NAME1,              "플랜트내역
        LGORT           LIKE ZGTPPT9020-LGORT,         "저장위치
        LGOBE           LIKE T001L-LGOBE,              "저장위치내역
        SOBKZ           LIKE ZGTPPT9020-SOBKZ,         "특별재고지시자
        ZSTOCK_NO       LIKE ZGTPPT9020-ZSTOCK_NO,     "재고번호
        ZSTOCK_SEQ      LIKE ZGTPPT9020-ZSTOCK_SEQ,    "재고순번
        AUFNR           LIKE ZGTPPT9020-AUFNR,         "재고변환 생산오더
        MBLNR_GI        LIKE ZGTPPT9020-MBLNR_GI,      "기존재고 투입 자재문서
        MBLNR_GR        LIKE ZGTPPT9020-MBLNR_GR,      "신규재고 입고 자재문서
        RTMSG(100),                                    "취소처리 메시지
        N_MATNR         LIKE ZGTPPT9020-N_MATNR,       "신규 자재코드
        N_MAKTX         LIKE MAKT-MAKTX,               "신규 자재내역
        N_VBELN         LIKE ZGTPPT9020-N_VBELN,       "신규 판매오더번호
        N_POSNR         LIKE ZGTPPT9020-N_POSNR,       "신규 판매오더품목
        N_JOB_NO        LIKE ZGTPPT9020-N_JOB_NO,      "신규 제조지시번호
        N_CHARG         LIKE ZGTPPT9020-N_CHARG,       "신규 배치번호
        N_LWEDT         LIKE ZGTPPT9020-N_LWEDT,       "신규 최종입고일
        N_KALAB         LIKE ZGTPPT9020-N_KALAB,       "신규 재고수량
        N_MEINS         LIKE ZGTPPT9020-N_MEINS,       "신규 재고단위
        N_MTART         LIKE MARA-MTART,               "신규 자재유형
        N_MATKL         LIKE MARA-MATKL,               "신규 자재그룹
        N_KWMENG        LIKE ZGTPPT9020-N_KWMENG,      "신규 판매오더수량
        N_LENGTH        LIKE ZGTPPT9020-N_LENGTH,      "신규 총길이
        N_SERIAL_CNT    LIKE ZGTPPT9020-N_SERIAL_CNT,  "신규 시리얼번호수
        O_MATNR         LIKE ZGTPPT9020-O_MATNR,       "기존 자재코드
        O_MAKTX         LIKE MAKT-MAKTX,               "기존 자재내역
        O_VBELN         LIKE ZGTPPT9020-O_VBELN,       "기존 판매오더번호
        O_POSNR         LIKE ZGTPPT9020-O_POSNR,       "기존 판매오더품목
        O_JOB_NO        LIKE ZGTPPT9020-O_JOB_NO,      "기존 제조지시번호
        O_CHARG         LIKE ZGTPPT9020-O_CHARG,       "기존 배치번호
        O_LWEDT         LIKE ZGTPPT9010-O_LWEDT,       "기존 최종입고일
        O_KALAB         LIKE ZGTPPT9020-O_KALAB,       "기존 재고수량
        O_MEINS         LIKE ZGTPPT9020-O_MEINS,       "기존 재고단위
        O_MTART         LIKE MARA-MTART,               "기존 자재유형
        O_MATKL         LIKE MARA-MATKL,               "기존 자재그룹
        O_KWMENG        LIKE ZGTPPT9020-O_KWMENG,      "기존 판매오더수량
        O_VRKME         LIKE ZGTPPT9020-O_VRKME,       "기존 수량단위
        O_STD_PROD_NM   LIKE ZGTPPT9020-O_STD_PROD_NM, "형상코드
        O_STD_PROD_DSCR LIKE ZGTPPT1010-FLD_02,        "형상내역
        O_PROD_NM       LIKE ZGTPPT9020-O_PROD_NM,     "견적품명코드
        O_PROD_DSCR     LIKE ZGTPPT1010-FLD_04,        "견적품명내역
        O_PROD_MNG      LIKE ZGTPPT1010-FLD_05,        "견적품수량
        CRDAT           LIKE ZGTPPT9020-CRDAT,         "생성일자
        CRTIM           LIKE ZGTPPT9020-CRTIM,         "생성시간
        CRNAM           LIKE ZGTPPT9020-CRNAM,         "생성자
        CHDAT           LIKE ZGTPPT9020-CRDAT,         "변경일자
        CHTIM           LIKE ZGTPPT9020-CRTIM,         "변경시간
        CHNAM           LIKE ZGTPPT9020-CRNAM,         "변경자

        N_MTBEZ         LIKE T134T-MTBEZ,              "신규자재유형내역
        N_WGBEZ         LIKE T023T-WGBEZ,              "신규자재그룹내역
        O_MTBEZ         LIKE T134T-MTBEZ,              "기존자재유형내역
        O_WGBEZ         LIKE T023T-WGBEZ,              "기존자재그룹내
        MJAHR_GI        LIKE ZGTPPT9020-MJAHR_GI,      "기존재고투입년도
        MJAHR_GR        LIKE ZGTPPT9020-MJAHR_GR,      "신규재고입고년도
      END OF GS_TRANS_C.
DATA: GT_TRANS_C LIKE TABLE OF GS_TRANS_C.

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
      GV_TEXT  TYPE CHAR255.

CONSTANTS: GC_3          TYPE CHAR1            VALUE '3',
           GC_C          TYPE CHAR1            VALUE 'C',
           GC_D          TYPE CHAR1            VALUE 'D',
           GC_E          TYPE CHAR1            VALUE 'E',
           GC_F          TYPE CHAR1            VALUE 'F',
           GC_I          TYPE CHAR1            VALUE 'I',
           GC_L          TYPE CHAR1            VALUE 'L',
           GC_O          TYPE CHAR1            VALUE 'O',
           GC_R          TYPE CHAR1            VALUE 'R',
           GC_S          TYPE CHAR1            VALUE 'S',
           GC_W          TYPE CHAR1            VALUE 'W',
           GC_X          TYPE CHAR1            VALUE 'X',
           GC_ALL        TYPE CHAR1            VALUE '*',
           GC_00         TYPE CHAR2            VALUE '00',
           GC_01         TYPE CHAR2            VALUE '01',
           GC_EQ         TYPE CHAR2            VALUE 'EQ',
           GC_MG         TYPE CHAR2            VALUE 'MG',
           GC_KG         TYPE CHAR2            VALUE 'KG',
           GC_MIG        TYPE CHAR3            VALUE 'MIG',
           GC_MSKA       TYPE CHAR4            VALUE 'MSKA',
           GC_PP99       TYPE CHAR4            VALUE 'PP99',
           GC_FERT       TYPE MTART            VALUE 'FERT',
           GC_HALB       TYPE MTART            VALUE 'HALB',
           GC_101        TYPE BWART            VALUE '101',
           GC_261        TYPE BWART            VALUE '261',
           GC_0010       TYPE VERID            VALUE '0010',
           GC_SC10       TYPE VERID            VALUE 'SC10',
           GC_PP         TYPE ZGTEMODULE_KIND  VALUE 'PP',
           GC_9010       TYPE ZGTECODEGRP      VALUE '9010',
           GC_9020       TYPE ZGTECODEGRP      VALUE '9020',
           GC_ZGTPP_STNO TYPE CHAR10           VALUE 'ZGTPP_STNO',
           GC_ZGTPPR9010 TYPE BKTXT            VALUE 'ZGTPPR9010',
           GC_MDOC       TYPE NSDM_RECORD_TYPE VALUE 'MDOC'.
