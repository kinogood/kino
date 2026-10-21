*&---------------------------------------------------------------------*
*& Include          ZGTPPR4000TOP
*&---------------------------------------------------------------------*
TABLES: AUFK, AFKO, AFPO, AFFW, MARA, VBAK, ZGTPPT4000.

* CLASS ZCL_EVENT_RECIEVER DEFINITION
CLASS ZCL_EVENT_RECIEVER DEFINITION DEFERRED.

DATA: BEGIN OF GS_DATA,
        BACK         LIKE ICON-ID,              "백로그상태
        ORD          LIKE ICON-ID,              "오더마감상태
        FORD         LIKE ICON-ID,              "후속오더상태
        ZZFOLLOW     LIKE AUFK-ZZFOLLOWING,     "후속 생산오더번호
        RTMSG(100),                             "처리 메세지
        AUFNR        LIKE AUFK-AUFNR,           "생산오더(마감대상오더)
        ORDSTAT(100),                           "생산오더상태
        WERKS        LIKE AUFK-WERKS,           "플랜트
        NAME1        LIKE T001W-NAME1,          "플랜트내역
        MTART        LIKE MARA-MTART,           "자재유형
        MTBEZ        LIKE T134T-MTBEZ,          "자재유형내역
        AUART        LIKE AUFK-AUART,           "생산오더유형
        MATKL        LIKE MARA-MATKL,           "자재그룹
        WGBEZ        LIKE T023T-WGBEZ,          "자재그룹 내역
        MATNR        LIKE AFPO-MATNR,           "품목코드
        MAKTX        LIKE MAKT-MAKTX,           "품목내역
        GAMNG        LIKE AFKO-GAMNG,           "생산오더수량
        WEMNG        LIKE AFPO-WEMNG,           "생산입고수량
        IGMNG        LIKE AFKO-IGMNG,           "생산확정수량
        REMNG        LIKE AFKO-IGMNG,           "생산잔량(오더수량-입고수량)
        GMEIN        LIKE AFKO-GMEIN,           "생산단위
        ZPJNO        LIKE VBAK-ZPJNO,           "프로젝트번호
        ZPTXT        LIKE ZSD0106T-ZPTXT,       "프로젝트내역
        BSTNK        LIKE VBAK-BSTNK,           "제조지시번호
        JOBNM        LIKE ZGTEDT2121-ZJOB_NAME, "제조지시내역
        KDAUF        LIKE AFPO-KDAUF,           "판매오더번호
        KDPOS        LIKE AFPO-KDPOS,           "판매오더 품목
        GSTRP        LIKE AFKO-GSTRP,           "오더시작일
        GLTRP        LIKE AFKO-GLTRP,           "오더종료일
        WBSTA        LIKE LIPS-WBSTA,           "출하완료여부
        GSTRI        LIKE AFKO-GSTRI,           "실제시작일
        OBJNR        LIKE AUFK-OBJNR,           "오브젝트 번호
        ZZORIGIN     LIKE AUFK-ZZORIGIN,        "기존 생산오더번호
        LGORT        LIKE AFPO-LGORT,           "저장위치
      END OF GS_DATA.
DATA: GT_DATA  LIKE TABLE OF GS_DATA,
      GT_DATAS LIKE TABLE OF GS_DATA.

DATA : GV_CHANGE_STAT.
* 날짜 변경 팝업
DATA : GV_GSTRP TYPE AFKO-GSTRP.
DATA : GV_GLTRP TYPE AFKO-GLTRP.

DATA: BEGIN OF GS_REVDATA,
        BACK         LIKE ICON-ID,              "백로그상태
        FORD         LIKE ICON-ID,              "후속오더상태
        ORD          LIKE ICON-ID,              "오더마감상태
        ZZFOLLOW     LIKE AUFK-ZZFOLLOWING,     "후속 생산오더번호
        RTMSG(100),                             "처리결과메세지
        ZZORIGIN     LIKE AUFK-ZZORIGIN,        "기존 생산오더번호
        ORDSTAT(100),                           "생산오더상태
        WERKS        LIKE AUFK-WERKS,           "플랜트
        NAME1        LIKE T001W-NAME1,          "플랜트내역
        MTART        LIKE MARA-MTART,           "자재유형
        MTBEZ        LIKE T134T-MTBEZ,          "자재유형내역
        AUART        LIKE AUFK-AUART,           "생산오더유형
        MATKL        LIKE MARA-MATKL,           "자재그룹
        WGBEZ        LIKE T023T-WGBEZ,          "자재그룹 내역
        MATNR        LIKE AFPO-MATNR,           "품목코드
        MAKTX        LIKE MAKT-MAKTX,           "품목내역
        GAMNG        LIKE AFKO-GAMNG,           "생산오더수량
        WEMNG        LIKE AFPO-WEMNG,           "생산입고수량
        IGMNG        LIKE AFKO-IGMNG,           "생산확정수량
        REMNG        LIKE AFKO-IGMNG,           "생산잔량(오더수량-입고수량)
        GMEIN        LIKE AFKO-GMEIN,           "생산단위
        ZPJNO        LIKE VBAK-ZPJNO,           "프로젝트번호
        ZPTXT        LIKE ZSD0106T-ZPTXT,       "프로젝트내역
        BSTNK        LIKE VBAK-BSTNK,           "제조지시번호
        JOBNM        LIKE ZGTEDT2121-ZJOB_NAME, "제조지시내역
        KDAUF        LIKE AFPO-KDAUF,           "판매오더번호
        KDPOS        LIKE AFPO-KDPOS,           "판매오더 품목
        GSTRP        LIKE AFKO-GSTRP,           "오더시작일
        GLTRP        LIKE AFKO-GLTRP,           "오더종료일
        WBSTA        LIKE LIPS-WBSTA,           "출하완료여부
        CRDAT        LIKE ZGTPPT4000-CRDAT,     "처리일자
        CRTIM        LIKE ZGTPPT4000-CRTIM,     "처리시간
        CRNAM        LIKE ZGTPPT4000-CRNAM,     "처리자
        GSTRI        LIKE AFKO-GSTRI,           "실제시작일

        AUFNR        LIKE AUFK-AUFNR,
      END OF GS_REVDATA.
DATA: GT_REVDATA LIKE TABLE OF GS_REVDATA.

DATA: BEGIN OF GS_OBOTTOM,
        AUFNR         LIKE AUFK-AUFNR,
        JOB_NO        LIKE ZGTPPT3150-JOB_NO,        "제조지시번호
        LINE_NO       LIKE ZGTPPT3150-LINE_NO,       "라인번호
        SERIAL_INFO   LIKE ZGTPPT3150-SERIAL_INFO,   "시리얼정보
        PRCSS_SEQ     LIKE ZGTPPT3160-PRCSS_SEQ,     "공정순번
        PRCSS_SUB_SEQ LIKE ZGTPPT3160-PRCSS_SUB_SEQ, "SUB순번
        MTRL_SEQ      LIKE ZGTPPT3170-MTRL_SEQ,      "자재순번
        MATNR         LIKE ZGTPPT3170-MATNR,         "구성품코드
        MAKTX         LIKE MAKT-MAKTX,               "구성품내역
        MENGE         LIKE ZGTPPT3170-MENGE,         "순소요량
        KAUSF         LIKE ZGTPPT3170-KAUSF,         "LOSS율(%)
        COMP_QTY      LIKE ZGTPPT3170-MENGE,         "총소요량
        MEINS         LIKE MARA-MEINS,               "수량단위

        SBDKZ         LIKE MARC-SBDKZ,               "개별/일괄 소요량 지시자
        RGEKZ         LIKE MARC-RGEKZ,               "백플러시지시자
        DEL(1),
      END OF GS_OBOTTOM.
DATA: GT_OBOTTOM LIKE TABLE OF GS_OBOTTOM.

DATA: BEGIN OF GS_BOTTOM,
        MTRL_SEQ LIKE ZGTPPT3170-MTRL_SEQ,        "자재순번
        MATNR    LIKE ZGTPPT3170-MATNR,           "구성품코드
        MAKTX    LIKE MAKT-MAKTX,                 "구성품내역
        MENGE    LIKE ZGTPPT3170-MENGE,           "순소요량
        KAUSF    LIKE ZGTPPT3170-KAUSF,           "LOSS율(%)
        COMP_QTY LIKE ZGTPPT3170-MENGE,           "총소요량
        MEINS    LIKE MARA-MEINS,                 "수량단위

        SBDKZ    LIKE MARC-SBDKZ,                 "개별/일괄 소요량 지시자
        RGEKZ    LIKE MARC-RGEKZ,                 "백플러시지시자
      END OF GS_BOTTOM.
DATA: GT_BOTTOM LIKE TABLE OF GS_BOTTOM.

DATA: BEGIN OF GS_AUFNR_GR,
        JOB_NO      LIKE ZGTPPT3150-JOB_NO,        "제조지시번호
        LINE_NO     LIKE ZGTPPT3150-LINE_NO,       "라인번호
        SERIAL_INFO LIKE ZGTPPT3150-SERIAL_INFO,   "시리얼정보
        MBLNR       LIKE MATDOC-MBLNR,
        MJAHR       LIKE MATDOC-MJAHR,
        AUFNR       LIKE MATDOC-AUFNR,
        BKTXT       LIKE MATDOC-BKTXT,
        MENGE       LIKE MATDOC-MENGE,
        MEINS       LIKE MATDOC-MEINS,
      END OF GS_AUFNR_GR.
DATA: GT_AUFNR_GR LIKE TABLE OF GS_AUFNR_GR.

DATA: BEGIN OF GS_AUFNR,
        MATGI        LIKE ICON-ID,              "자재투입
        ORDCF        LIKE ICON-ID,              "생산확정
        ORDGR        LIKE ICON-ID,              "생산입고
        LOEKZ        LIKE AUFK-LOEKZ,           "삭제지시자
        AUFNR        LIKE AUFK-AUFNR,           "생산오더번호
        ORDSTAT(100),                           "생산오더상태
        WERKS        LIKE AUFK-WERKS,           "플랜트
        NAME1        LIKE T001W-NAME1,          "플랜트내역
        MTART        LIKE MARA-MTART,           "자재유형
        MTBEZ        LIKE T134T-MTBEZ,          "자재유형내역
        AUART        LIKE AUFK-AUART,           "생산오더유형
        MATKL        LIKE MARA-MATKL,           "자재그룹
        WGBEZ        LIKE T023T-WGBEZ,          "자재그룹 내역
        PROD_ID(70),                            "제품구분
        MATNR        LIKE AFPO-MATNR,           "품목코드
        MAKTX        LIKE MAKT-MAKTX,           "품목내역
        GAMNG        LIKE AFKO-GAMNG,           "생산오더수량
        WEMNG        LIKE AFPO-WEMNG,           "생산입고수량
        IGMNG        LIKE AFKO-IGMNG,           "생산확정수량
        REMNG        LIKE AFKO-IGMNG,           "생산잔량(오더수량-입고수량)
        GMEIN        LIKE AFKO-GMEIN,           "생산단위
        ZPJNO        LIKE VBAK-ZPJNO,           "프로젝트번호
        ZPTXT        LIKE ZSD0106T-ZPTXT,       "프로젝트내역
        BSTNK        LIKE VBAK-BSTNK,           "제조지시번호
        JOBNM        LIKE ZGTEDT2121-ZJOB_NAME, "제조지시내역
        KDAUF        LIKE AFPO-KDAUF,           "판매오더번호
        KDPOS        LIKE AFPO-KDPOS,           "판매오더 품목
        GSTRP        LIKE AFKO-GSTRP,           "오더시작일
        GLTRP        LIKE AFKO-GLTRP,           "오더종료일
        WBSTA        LIKE LIPS-WBSTA,           "출하완료여부
        GSTRI        LIKE AFKO-GSTRI,           "실제시작일
        ZZORIGIN     LIKE AUFK-ZZORIGIN,        "기존생산오더
        ZZFOLLOWING  LIKE AUFK-ZZFOLLOWING,     "후속생산오더

        OBJNR        LIKE AUFK-OBJNR,           "오브젝트 번호
        STATUS       LIKE ICON-ID,
        MSG          LIKE BAPIRET2-MESSAGE,
      END OF GS_AUFNR.
DATA: GT_AUFNR LIKE TABLE OF GS_AUFNR.

DATA: BEGIN OF GS_RESB,
        AUFNR LIKE RESB-AUFNR,
        RSNUM LIKE RESB-RSNUM,
        RSPOS LIKE RESB-RSPOS,
        KZEAR LIKE RESB-KZEAR,
        ENMNG LIKE RESB-ENMNG,
      END OF GS_RESB.
DATA: GT_RESB LIKE TABLE OF GS_RESB.

DATA: BEGIN OF GS_RESBCHK,
        AUFNR LIKE RESB-AUFNR,
        KZEAR LIKE RESB-KZEAR,
        ENMNG LIKE RESB-ENMNG,
      END OF GS_RESBCHK.
DATA: GT_RESBCHK LIKE TABLE OF GS_RESBCHK.

DATA: BEGIN OF GS_AUFNR_SEND,
        AUFNR LIKE AUFK-AUFNR,
        ERDAT LIKE AUFK-ERDAT,
      END OF GS_AUFNR_SEND.
DATA: GT_AUFNR_SEND LIKE TABLE OF GS_AUFNR_SEND.

TYPES: BEGIN OF TY_RESB_BT.
         INCLUDE TYPE RESBB.
TYPES:   INDOLD     TYPE SYST_TABIX,
         NO_REQ_UPD TYPE SYST_DATAR,
       END OF TY_RESB_BT.

TYPES TT_RESB_BT TYPE TABLE OF TY_RESB_BT.

DATA: GO_DOCKING_CONTAINER TYPE REF TO CL_GUI_DOCKING_CONTAINER.
DATA: GO_SPLITTER TYPE REF TO CL_GUI_SPLITTER_CONTAINER.

*- ALV GRID TOP
DATA: GO_CONTAIN_0100 TYPE REF TO CL_GUI_CONTAINER.
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

FIELD-SYMBOLS: <FT_RESB_BT> TYPE TT_RESB_BT,
               <FS_RESB_BT> TYPE TY_RESB_BT.

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

DATA: GV_CHARG       LIKE MCHA-CHARG,
      GV_XCHPF       LIKE MARA-XCHPF,
      GV_CHK(1),
      GV_LGORTCHK(1).

*- BDC
DATA: BDCDATA   LIKE BDCDATA    OCCURS 0 WITH HEADER LINE,
      MESSTAB   LIKE BDCMSGCOLL OCCURS 0 WITH HEADER LINE,
      GS_PARAMS TYPE CTU_PARAMS.

DATA: GV_OK_CODE TYPE SYUCOMM,
      GV_OK_CODE2 TYPE SYUCOMM,
      GV_DBCNT   TYPE CHAR10.

DATA: GV_REPID TYPE SYREPID,
      GV_VALID TYPE CHAR01,
      GV_INDEX TYPE SY-TABIX,
      GV_TEXT  TYPE CHAR255,
      GV_SEQ   LIKE ZGTPPT3170-MTRL_SEQ.

CONSTANTS: GC_1        TYPE CHAR1            VALUE '1',
           GC_C        TYPE CHAR1            VALUE 'C',
           GC_D        TYPE CHAR1            VALUE 'D',
           GC_E        TYPE CHAR1            VALUE 'E',
           GC_F        TYPE CHAR1            VALUE 'F',
           GC_L        TYPE CHAR1            VALUE 'L',
           GC_R        TYPE CHAR1            VALUE 'R',
           GC_S        TYPE CHAR1            VALUE 'S',
           GC_W        TYPE CHAR1            VALUE 'W',
           GC_X        TYPE CHAR1            VALUE 'X',
           GC_ALL      TYPE CHAR1            VALUE '*',
           GC_101      TYPE BWART            VALUE '101',
           GC_0010     TYPE VERID            VALUE '0010',
           GC_0001     TYPE CO_POSNR         VALUE '0001',
           GC_I0010    TYPE J_ISTAT          VALUE 'I0010', "PCNF
           GC_I0074    TYPE J_ISTAT          VALUE 'I0074', "PDLV
           GC_GR_ZERO1 TYPE CHARG_D          VALUE 'GR_ZERO1',
           GC_MDOC     TYPE NSDM_RECORD_TYPE VALUE 'MDOC'.

DEFINE APP_AUFNR.
  CLEAR: GS_AUFNR_SEND.
  GS_AUFNR_SEND-AUFNR = &1.
  COLLECT GS_AUFNR_SEND INTO GT_AUFNR_SEND.
END-OF-DEFINITION.
