*&---------------------------------------------------------------------*
*& Include          ZGTPPR4070TOP
*&---------------------------------------------------------------------*
TABLES: AUFK, AFKO, AFPO, AFRU, MARA, VBAK, MATDOC,
        ZGTPPT9030, ZGTPPT9040, ZGTPPT9050, ZGTPPT9060.

* CLASS ZCL_EVENT_RECIEVER DEFINITION
CLASS ZCL_EVENT_RECIEVER DEFINITION DEFERRED.

DATA: BEGIN OF GS_DATA,
        GR_STAT      LIKE ICON-ID,              "생산입고취소/생산입고재처리
        TM_STAT      LIKE ICON-ID,              "시간투입취소/시간투입재처리
        GI_STAT      LIKE ICON-ID,              "자재투입취소/자재투입재처리
        AUFNR        LIKE AUFK-AUFNR,           "생산오더(마감대상오더)
        ORDSTAT(100),                           "생산오더상태
        ID           LIKE ICON-ID,              "처리상태
        RTMSG(100),                             "처리결과메세지
        WERKS        LIKE AUFK-WERKS,           "플랜트
        NAME1        LIKE T001W-NAME1,          "플랜트내역
        MTART        LIKE MARA-MTART,           "자재유형
        MTBEZ        LIKE T134T-MTBEZ,          "자재유형내역
        AUART        LIKE AUFK-AUART,           "생산오더유형
        MATKL        LIKE MARA-MATKL,           "자재그룹
        WGBEZ        LIKE T023T-WGBEZ,          "자재그룹내역
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
        KDPOS        LIKE AFPO-KDPOS,           "판매오더품목
        GSTRP        LIKE AFKO-GSTRP,           "오더시작일
        GLTRP        LIKE AFKO-GLTRP,           "오더종료일

        OBJNR        LIKE AUFK-OBJNR,           "오브젝트 번호
        LGORT        LIKE AFPO-LGORT,           "저장위치
      END OF GS_DATA.
DATA: GT_DATA LIKE TABLE OF GS_DATA.

*-생산 입고 실적/생산 자재 투입 실적(취소용)
DATA: BEGIN OF GS_CGRGI,
        WERKS      TYPE WERKS_D,
        AUFNR      TYPE AUFNR,
        MBLNR      TYPE MBLNR,
        MJAHR      TYPE MJAHR,
        BKTXT      TYPE BKTXT,
        MBLNR_C    TYPE MBLNR,
        MJAHR_C    TYPE MJAHR,
        RTCOD(1),
        RTMSG(100),
      END OF GS_CGRGI.
DATA: GT_CGR LIKE TABLE OF GS_CGRGI,
      GT_CGI LIKE TABLE OF GS_CGRGI.

*-생산 확정 실적(취소용)
DATA: BEGIN OF GS_CTM,
        WERKS	     TYPE WERKS_D,
        AUFNR	     TYPE AUFNR,
        RUECK	     TYPE CO_RUECK,
        RMZHL	     TYPE CO_RMZHL,
        LTXA1      TYPE CO_RTEXT,
        EXTID      TYPE RU_EXTID,
        RUECK_C	   TYPE CO_RUECK,
        RMZHL_C	   TYPE CO_RMZHL,
        RTCOD(1),
        RTMSG(100),
      END OF GS_CTM.
DATA: GT_CTM LIKE TABLE OF GS_CTM.

*-생산 입고 실적/생산 자재 투입 실적(재처리용)
DATA: BEGIN OF GS_RGRGI,
        WERKS      TYPE WERKS_D,
        AUFNR      TYPE AUFNR,
        MBLNR      TYPE MBLNR,
        MJAHR      TYPE MJAHR,
        BKTXT      TYPE BKTXT,
        MATNR      TYPE MATNR,
        CHARG      TYPE CHARG_D,
        LGORT      TYPE LGORT_D,
        ERFMG      TYPE ERFMG,
        ERFME      TYPE ERFME,
        RTCOD(1),
        RTMSG(100),
      END OF GS_RGRGI.
DATA: GT_RGR LIKE TABLE OF GS_RGRGI,
      GT_RGI LIKE TABLE OF GS_RGRGI.

*-생산 확정 실적(재처리용)
DATA: BEGIN OF GS_RTM,
        WERKS	     TYPE WERKS_D,
        AUFNR	     TYPE AUFNR,
        VORNR      TYPE VORNR,
        RUECK	     TYPE CO_RUECK,
        RMZHL	     TYPE CO_RMZHL,
        ARBID      TYPE OBJEKTID,
        ARBPL      TYPE ARBPL,
        LMNGA      TYPE RU_LMNGA,
        ILE01      TYPE CO_ISMNGEH,
        ISM01      TYPE RU_ISMNG,
        ILE02      TYPE CO_ISMNGEH,
        ISM02      TYPE RU_ISMNG,
        ILE03      TYPE CO_ISMNGEH,
        ISM03      TYPE RU_ISMNG,
        ILE04      TYPE CO_ISMNGEH,
        ISM04      TYPE RU_ISMNG,
        ILE05      TYPE CO_ISMNGEH,
        ISM05      TYPE RU_ISMNG,
        ILE06      TYPE CO_ISMNGEH,
        ISM06      TYPE RU_ISMNG,
        ISDD       TYPE RU_ISDD,
        ISDZ       TYPE RU_ISDZ,
        IEDD       TYPE RU_IEDD,
        IEDZ       TYPE RU_IEDZ,
        EXTID      TYPE RU_EXTID,
        LTXA1      TYPE CO_RTEXT,
        PERNR      TYPE CO_PERNR,
        RTCOD(1),
        RTMSG(100),
      END OF GS_RTM.
DATA: GT_RTM LIKE TABLE OF GS_RTM.

*-리플레쉬용 처리 결과
DATA: BEGIN OF GS_RT,
        AUFNR       TYPE AUFNR,
        RTCOD(1),
        RTMSG(100),
        PROCCODE(3),
      END OF GS_RT.
DATA: GT_RT LIKE TABLE OF GS_RT.

DATA: GO_DOCKING_CONTAINER TYPE REF TO CL_GUI_DOCKING_CONTAINER.

DATA: GO_CONTAIN_0100 TYPE REF TO CL_GUI_CONTAINER.
DATA: GO_GRID_0100 TYPE REF TO CL_GUI_ALV_GRID.
DATA: GO_EVTR_0100 TYPE REF TO ZCL_EVENT_RECIEVER.
DATA: GS_VARIANT TYPE DISVARIANT.
DATA: GS_LAYOUT_0100 TYPE LVC_S_LAYO.
DATA: GT_EXCLUDE_0100 TYPE UI_FUNCTIONS.
DATA: GT_FIELDCAT_0100 TYPE LVC_T_FCAT.

DATA: GT_UCOMM TYPE TABLE OF SY-UCOMM.

DATA: GV_BUDATE LIKE MATDOC-BUDAT,  "대상년월의 말일
      GV_BUDAT1 LIKE MATDOC-BUDAT.  "대상년월의 차월 1일

DATA: GV_OK_CODE TYPE SYUCOMM,
      GV_DBCNT   TYPE CHAR10.

DATA: GV_REPID  TYPE SYREPID,
      GV_VALID  TYPE CHAR01,
      GV_CHK(1),
      GV_GBN(1).

CONSTANTS: GC_1          TYPE CHAR1            VALUE '1',
           GC_A          TYPE CHAR1            VALUE 'A',
           GC_C          TYPE CHAR1            VALUE 'C',
           GC_D          TYPE CHAR1            VALUE 'D',
           GC_E          TYPE CHAR1            VALUE 'E',
           GC_F          TYPE CHAR1            VALUE 'F',
           GC_L          TYPE CHAR1            VALUE 'L',
           GC_R          TYPE CHAR1            VALUE 'R',
           GC_S          TYPE CHAR1            VALUE 'S',
           GC_W          TYPE CHAR1            VALUE 'W',
           GC_X          TYPE CHAR1            VALUE 'X',
           GC_Y          TYPE CHAR1            VALUE 'Y',
           GC_ALL        TYPE CHAR1            VALUE '*',
           GC_101        TYPE BWART            VALUE '101',
           GC_261        TYPE BWART            VALUE '261',
           GC_0001       TYPE CO_POSNR         VALUE '0001',
           GC_MDOC       TYPE NSDM_RECORD_TYPE VALUE 'MDOC',
           GC_KBDM       TYPE ZGTETARGET       VALUE 'KBDM',
           GC_ZGTPPR4070 TYPE BKTXT            VALUE 'ZGTPPR4070'.
