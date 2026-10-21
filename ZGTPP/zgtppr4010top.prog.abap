*&---------------------------------------------------------------------*
*& Include          ZGTPPR4010TOP
*&---------------------------------------------------------------------*
TABLES: MSKA, MSLB, MCHB, MARD, MKPF, MSEG, MATDOC, MARA,
        VBAK, ZGTPPT4010, ZGTEDT2121.

INCLUDE <CL_ALV_CONTROL>.   " ALV Control (Ex. Fonts, Styles)

* CLASS ZCL_EVENT_RECIEVER DEFINITION
CLASS ZCL_EVENT_RECIEVER DEFINITION DEFERRED.

"판매오더간 재고 이전전기
DATA: BEGIN OF GS_DATA,
        ZTEXT(40),                              "유형
        WERKS      LIKE MSKA-WERKS,             "플랜트
        NAME1      LIKE T001W-NAME1,            "플랜트내역
        LGORT      LIKE MSKA-LGORT,             "저장위치
        LGOBE      LIKE T001L-LGOBE,            "저장위치내역
        MTART      LIKE MARA-MTART,             "자재유형
        MTBEZ      LIKE T134T-MTBEZ,            "자재유형내역
        MATKL      LIKE MARA-MATKL,             "자재그룹
        WGBEZ      LIKE T023T-WGBEZ,            "자재그룹내역
        MATNR      LIKE MSKA-MATNR,             "자재코드
        MAKTX      LIKE MAKT-MAKTX,             "자재내역
        CHARG      LIKE MSKA-CHARG,             "(FROM)배치번호
        FZPJNO     LIKE VBAK-ZPJNO,             "(FROM)프로젝트번호
        FZPTXT     LIKE ZSD0106T-ZPTXT,         "(FROM)프로젝트내역
        FBSTNK     LIKE VBAK-BSTNK,             "(FROM)제조지시번호
        FJOBNM     LIKE ZGTEDT2121-ZJOB_NAME,   "(FROM)제조지시내역
        FVBELN     LIKE MSKA-VBELN,             "(FROM)판매오더번호
        FPOSNR     LIKE MSKA-POSNR,             "(FROM)판매오더품목
        FKALAB     LIKE MSKA-KALAB,             "(FROM)재고수량
        TCHARG     LIKE MSEG-UMCHA,             "(TO)배치번호
        TZPJNO     LIKE VBAK-ZPJNO,             "(TO)프로젝트번호
        TZPTXT     LIKE ZSD0106T-ZPTXT,         "(TO)프로젝트내역
        TBSTNK     LIKE VBAK-BSTNK,             "(TO)제조지시번호
        TJOBNM     LIKE ZGTEDT2121-ZJOB_NAME,   "(TO)제조지시내역
        TVBELN     LIKE MSKA-VBELN,             "(TO)판매오더번호
        TPOSNR     LIKE MSKA-POSNR,             "(TO)판매오더품목
        TKALAB     LIKE MSKA-KALAB,             "(TO)재고수량
        MEINS      LIKE MARA-MEINS,             "재고단위
        BUDAT      LIKE MKPF-BUDAT,             "전기일자
        BKTXT      LIKE MKPF-BKTXT,             "헤더텍스트
        ID         LIKE ICON-ID,                "처리상태
        RTMSG(100),                               "처리메세지
        MBLNR      LIKE MKPF-MBLNR,             "자재문서번호
        MJAHR      LIKE MKPF-MJAHR,             "자재문서연도

        SOBKZ      LIKE MSKA-SOBKZ,             "특별 재고 지시자
        ZTYPE      LIKE ZGTPPT4010-ZTYPE,       "유형코드
        TMATNR     LIKE MARA-MATNR,             "(TO)자재코드
        KWMENG     LIKE VBAP-KWMENG,            "(TO)판매오더수량
        SKALAB     TYPE MENG15,                 "(FROM)재고수량+(TO)재고수량
        LV_ATWRT   TYPE STRING,                 "속성정보CONCATENATE

        CELL_STY   TYPE LVC_T_STYL,             "cell style
      END OF GS_DATA.

"처리결과조회/취소
DATA: BEGIN OF GS_REVDATA,
        ZTEXT(40),                            "유형
        MBLNR      LIKE MKPF-MBLNR,           "자재문서번호
        MJAHR      LIKE MKPF-MJAHR,           "자재문서연도
        SMBLN      LIKE MSEG-SMBLN,           "취소자재문서번호
        BWART      LIKE MSEG-BWART,           "이동유형
        BTEXT      LIKE T156HT-BTEXT,         "이동유형내역
        WERKS      LIKE MSEG-WERKS,           "플랜트
        NAME1      LIKE T001W-NAME1,          "플랜트내역
        LGORT      LIKE MSEG-LGORT,           "저장위치
        LGOBE      LIKE T001L-LGOBE,          "저장위치내역
        MTART      LIKE MARA-MTART,           "자재유형
        MTBEZ      LIKE T134T-MTBEZ,          "자재유형내역
        MATKL      LIKE MARA-MATKL,           "자재그룹
        WGBEZ      LIKE T023T-WGBEZ,          "자재그룹내역
        MATNR      LIKE MSEG-MATNR,           "자재코드
        MAKTX      LIKE MAKT-MAKTX,           "자재내역
        CHARG      LIKE MSEG-CHARG,           "(FROM)배치번호
        FZPJNO     LIKE VBAK-ZPJNO,           "(FROM)프로젝트번호
        FZPTXT     LIKE ZSD0106T-ZPTXT,       "(FROM)프로젝트내역
        FBSTNK     LIKE VBAK-BSTNK,           "(FROM)제조지시번호
        FJOBNM     LIKE ZGTEDT2121-ZJOB_NAME, "(FROM)제조지시내역
        FVBELN     LIKE MSEG-MAT_KDAUF,       "(FROM)판매오더번호
        FPOSNR     LIKE MSEG-MAT_KDPOS,       "(FROM)판매오더품목
        TCHARG     LIKE MSEG-UMCHA,           "(TO)배치번호
        TZPJNO     LIKE VBAK-ZPJNO,           "(TO)프로젝트번호
        TZPTXT     LIKE ZSD0106T-ZPTXT,       "(TO)프로젝트내역
        TBSTNK     LIKE VBAK-BSTNK,           "(TO)제조지시번호
        TJOBNM     LIKE ZGTEDT2121-ZJOB_NAME, "(TO)제조지시내역
        TVBELN     LIKE MSEG-KDAUF,           "(TO)판매오더번호
        TPOSNR     LIKE MSEG-KDPOS,           "(TO)판매오더품목
        MENGE      LIKE MSEG-MENGE,           "(TO)수량
        MEINS      LIKE MSEG-MEINS,           "단위
        BUDAT      LIKE MKPF-BUDAT,           "전기일자
        BKTXT      LIKE MKPF-BKTXT,           "헤더텍스트
        CRDAT      LIKE ZGTPPT4010-CRDAT,     "처리일자
        CRTIM      LIKE ZGTPPT4010-CRTIM,     "처리시간
        CRNAM      LIKE ZGTPPT4010-CRNAM,     "처리자
        ID         LIKE ICON-ID,              "처리상태
        RTMSG(100),                           "처리메세지

        ZTYPE      LIKE ZGTPPT4010-ZTYPE,     "유형코드
        ZEILE      LIKE MSEG-ZEILE,           "자재문서품목번호
        SHKZG      LIKE MSEG-SHKZG,           "차/대변 지시자

        CELL_STY   TYPE LVC_T_STYL,           "cell style
      END OF GS_REVDATA.

DATA: BEGIN OF GS_CLS,
        ATFOR LIKE CABN-ATFOR,
        ATNAM LIKE CABN-ATNAM,
        ATFLV LIKE IBSYMBOL-ATFLV,
        ATFLB LIKE IBSYMBOL-ATFLB,
        ATWRT LIKE IBSYMBOL-ATWRT,
      END OF GS_CLS.
DATA: GT_CLS LIKE TABLE OF GS_CLS.

DATA: GV_ATWRT LIKE IBSYMBOL-ATWRT,
      GS_3150  LIKE ZGTPPT3150.

DATA: GV_FLINE_NO     LIKE ZGTPPT3150-LINE_NO,     "(FROM)라인번호
      GV_FSERIAL_INFO LIKE ZGTPPT3150-SERIAL_INFO, "(FROM)시리얼정보
      GV_CHK(1).

DATA: GT_ZTYPE TYPE STANDARD TABLE OF DD07V,
      GS_ZTYPE TYPE DD07V.

DATA: GV_ZAHL(16)    TYPE P,
      GV_ZAHL_36(20) TYPE C.

DATA: GV_INDEX1 TYPE SY-INDEX.

TYPES: BEGIN OF GTY_MCHB,
         MATNR TYPE MATNR,
         WERKS TYPE WERKS_D,
         LGORT TYPE LGORT_D,
         CHARG TYPE CHARG_D,
         CLABS TYPE LABST,
       END OF GTY_MCHB.

TYPES: BEGIN OF GTY_MARD,
         MATNR TYPE MATNR,
         WERKS TYPE WERKS_D,
         LGORT TYPE LGORT_D,
         LABST TYPE LABST,
       END OF GTY_MARD.

TYPES: BEGIN OF GTY_SMBLN,
         SMBLN TYPE MBLNR,
         SJAHR TYPE MJAHR,
         MBLNR TYPE MBLNR,
         MJAHR TYPE MJAHR,
       END OF GTY_SMBLN.

DATA: GT_MCHB TYPE TABLE OF GTY_MCHB,
      GT_MARD TYPE TABLE OF GTY_MARD.

DATA: GT_SMBLN TYPE TABLE OF GTY_SMBLN.

DATA: GT_DATA     LIKE TABLE OF GS_DATA,
      GT_DATATO   LIKE TABLE OF GS_DATA,
      GT_REVODATA LIKE TABLE OF GS_REVDATA,
      GT_REVDATA  LIKE TABLE OF GS_REVDATA.

DATA: GO_CONTAIN_0100 TYPE REF TO CL_GUI_DOCKING_CONTAINER.
DATA: GO_GRID_0100 TYPE REF TO CL_GUI_ALV_GRID.
DATA: GO_EVTR_0100 TYPE REF TO ZCL_EVENT_RECIEVER.
DATA: GS_VARIANT TYPE DISVARIANT.
DATA: GS_LAYOUT_0100 TYPE LVC_S_LAYO.
DATA: GT_EXCLUDE_0100 TYPE UI_FUNCTIONS.
DATA: GT_FIELDCAT_0100 TYPE LVC_T_FCAT.

DATA: GT_UCOMM TYPE TABLE OF SY-UCOMM.

DATA: GV_OK_CODE TYPE SYUCOMM,
      GV_DBCNT   TYPE CHAR10.

DATA: GV_REPID TYPE SYREPID,
      GV_VALID TYPE CHAR01,
      GV_INDEX TYPE SY-TABIX,
      GV_TEXT  TYPE CHAR255.

CONSTANTS: GC_A     TYPE CHAR1      VALUE 'A',
           GC_B     TYPE CHAR1      VALUE 'B',
           GC_C     TYPE CHAR1      VALUE 'C',
           GC_D     TYPE CHAR1      VALUE 'D',
           GC_E     TYPE CHAR1      VALUE 'E',
           GC_H     TYPE CHAR1      VALUE 'H',
           GC_I     TYPE CHAR1      VALUE 'I',
           GC_L     TYPE CHAR1      VALUE 'L',
           GC_R     TYPE CHAR1      VALUE 'R',
           GC_S     TYPE CHAR1      VALUE 'S',
           GC_T     TYPE CHAR1      VALUE 'T',
           GC_W     TYPE CHAR1      VALUE 'W',
           GC_X     TYPE CHAR1      VALUE 'X',
           GC_Y     TYPE CHAR1      VALUE 'Y',
           GC_51    TYPE CHAR2      VALUE '51',
           GC_58    TYPE CHAR2      VALUE '58',
           GC_90    TYPE CHAR2      VALUE '90',
           GC_EQ    TYPE CHAR2      VALUE 'EQ',
           GC_PP    TYPE CHAR2      VALUE 'PP',
           GC_HAWA  TYPE MTART      VALUE 'HAWA',
           GC_FERT  TYPE MTART      VALUE 'FERT',
           GC_ROH1  TYPE MTART      VALUE 'ROH1',
           GC_HALB TYPE MTART      VALUE 'HALB',
           GC_ALL   TYPE CHAR1      VALUE '*',
           GC_KBDM  TYPE ZGTETARGET VALUE 'KBDM',
           GC_ZTYPE TYPE DOMNAME    VALUE 'ZGTD_ZTYPE'.
