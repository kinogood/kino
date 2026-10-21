*&---------------------------------------------------------------------*
*& Include          ZGTSDR0120TOP
*&---------------------------------------------------------------------*
*-------------------------------------------------------------------*
*   TABLE DECLARATION                                               *
*-------------------------------------------------------------------*
TABLES : CTU_PARAMS,             " CALL TRANSACTION OPTION..
         KNA1,
         VBUK,
         VBAK,
         VBAP,
         LIKP,
         LIPS,
         VBRK,
         VBRP,
         VBUP,
         VKDFS.

TABLES : SSCRFIELDS.  " 선택화면의 필드.

*-------------------------------------------------------------------*
*   DATA DECLARATION (INTERNAL TABLE DECLARE)                       *
*-------------------------------------------------------------------*
"ALV Default Fields
TYPES : BEGIN OF TY_S_ALVDEF,
          STATU TYPE ICON_D,     "신규/변경/삭제 상태 ICON
          MSG   TYPE TEXT100,
          INSRT TYPE CHAR1,      "신규 여부 Flag : 'X' or ' '
          MODI  TYPE CHAR1,      "변경 여부 Flag : 'X' or ' '
          SEL   TYPE CHAR1,
          CELLS TYPE LVC_T_STYL, "Cell Style
          CELLC TYPE LVC_T_STYL, "Cell Color
        END OF TY_S_ALVDEF.


TYPES : BEGIN OF TY_S_CHG,
          VBELN TYPE VBELN_VL,
          POSNR TYPE POSNR_VL,
        END OF TY_S_CHG,
        TY_T_CHG TYPE TABLE OF TY_S_CHG
                   WITH NON-UNIQUE SORTED KEY KEY_MODE
                   COMPONENTS VBELN POSNR.
"화면 변경 정보
DATA : GT_CHG   TYPE TY_T_CHG.

DATA: BEGIN OF G_ITAB_T OCCURS 0,
        MARK,
        VGBEL          LIKE VBAP-VBELN,                  " 주문번호
        VGPOS          LIKE VBAP-POSNR,                  " 품목번호
        KWMENG         LIKE VBAP-KWMENG,                " 주문수량
        VRKME_VA       LIKE VBAP-VRKME,               " 판매단위(오더)
        VRKME          LIKE LIPS-VRKME,                  " 판매단위(납품)
        VBELN          LIKE LIPS-VBELN,                  " 납품번호
        POSNR          LIKE LIPS-POSNR,                  " 납품품목
        MATNR          LIKE LIPS-MATNR,                  " 자재
        MAKTX          LIKE MAKT-MAKTX,                  " 자재내역
        CHARG          LIKE LIPS-CHARG,                  " 뱃치번호
        LFIMG          LIKE LIPS-LFIMG,                  " 납품수량
        KCMENG         LIKE LIPS-KCMENG,                " 누적배치수량
        FKIMG          LIKE VBRP-FKIMG,                  " 실제납품수량
        REMN_QTY2      LIKE LIPS-LFIMG,              " 잔량
        REMN_QTY       LIKE LIPS-LFIMG,              " 마감수량
        NETPR          LIKE VBAP-NETPR,                  " 단가
        NETPR2         TYPE P DECIMALS 3,                       " 단가2
        ZNETPR         TYPE P DECIMALS 4,               " 세금계산서단가
        WAERK          LIKE VBAP-WAERK,                  " 통화
">>>>부스덕트
        KURSF          LIKE ZTETFDK-KURSF,                  "환율
        NETWR_K        LIKE VBAP-NETWR,                   "환율 반영 금액
        WAERK_K        LIKE VBAP-WAERK,                   "KRW
        FIDNO          LIKE ZTETFDP-FIDNO,                "F/D
        FIDNP          LIKE ZTETFDP-FIDNP,                "F/D 품목
"<<<<
        NETWR          LIKE VBAP-NETWR,                  " 청구액
        TAXM1          LIKE VBAP-TAXM1,                  " 세금분류자재
        ZTAX           TYPE I,                           " Tax %
        ZTAX2          TYPE P DECIMALS 0,                " Tax
        KDKG4          LIKE VBKD-KDKG4,                  " 내수/로칼구분
        FAKSK          LIKE VKDFS-FAKSK,       " SD 문서내 대금청구보류
        FKSTA          LIKE VBUP-FKSTA,        " 납품관련 대금청구상태

        KUNAG          LIKE LIKP-KUNAG,                  " 판매처
        NAME1          LIKE KNA1-NAME1,
        WADAT_IST      LIKE LIKP-WADAT_IST,          " 출고일
        WADAT_IST2     LIKE LIKP-WADAT_IST,         " 원판매오더 출고일
        KPEIN          LIKE VBAP-KPEIN,                  " 기준량
        KNKLI          LIKE VBAK-KNKLI,                  " Payer
        VKBUR          LIKE VBAK-VKBUR,                  " 영업팀
        BEZEI          LIKE TVKBT-BEZEI,                 " 영업팀명
        VKGRP          LIKE VBAK-VKGRP,                  " 영업부서
        J_1BBRANCH     LIKE T001W-J_1BBRANCH,       " 세적지
        ZTERM          LIKE VBKD-ZTERM,                  " Payment Term
        WERKS          LIKE LIPS-WERKS,                  " Plant
        ZTEXT(40),
        FKDAT          LIKE VBRK-FKDAT,                  " 대금청구일
        VBTYP          LIKE VBAK-VBTYP,                  " SD 문서범주
        ZOUT           LIKE LIKP-ZOUT,                   " 통문관련 Flag
        TAXK1          LIKE VBAK-TAXK1,                  " 세금분류

        KUNNR_WE       LIKE KNA1-KUNNR,               " 납품처
        NAME2          LIKE KNA1-NAME1,
        KUNNR_RG       LIKE KNA1-KUNNR,               " 청구처
        NAME3          LIKE KNA1-NAME1,

        PRSDT          LIKE SY-DATUM,                    " 가격결정일

        ZZCOLOR_BASE   LIKE MARA-ZZCOLOR_BASE,   " 색상Base
        ZZCOLOR_STRIPE LIKE MARA-ZZCOLOR_STRIPE, " 색상Stripe
        ZZIDEN_CODE    LIKE MARA-ZZIDEN_CODE,    " 절연선심식별
        ZZSPEC_NO      LIKE MARA-ZZSPEC_NO,      " Spec_No
        ZZMAKTX80      LIKE MARA-ZZMAKTX80,      " 전체품명
        ZZRAL_CODE     LIKE MARA-ZZRAL_CODE,     " 색상(상세)
        ZZSPEC_DETAIL  LIKE MARA-ZZSPEC_DETAIL,  " Spec상세내용

        Z_NETWR        LIKE VBAP-NETWR,                 " 청구액(tmp)
        Z_MWSBP        LIKE VBAP-MWSBP,                 " Tax(tmp)
        Z_SUM          LIKE VBAP-NETWR,                 " 총액(청구액+tax)
        FKREL          LIKE LIPS-FKREL,
        ZGUBUN,        " 'O' : 오더관련빌링, 'D' : 납품관련빌링
        ABGRU          LIKE VBAP-ABGRU,                 " 거절사유

        O_VBELN        LIKE VBAK-VBELN,                 " 원주문문서
        O_POSNR        LIKE VBAP-POSNR,   " SRM2201-09029 원주문품목
        AUART          LIKE VBAK-AUART,                 " 오더유형
        PSTYV          LIKE VBAP-PSTYV,
        FRKEL          LIKE TVAP-FKREL,
        BSTKD          LIKE VBKD-BSTKD,
        MESG(70),                               " BDC메세지
        FBUDA          LIKE VBKD-FBUDA,
        LADGR          LIKE LIPS-LADGR,                 "적하그룹
        BWART          LIKE LIPS-BWART,                 "문서유형
        POSNN          TYPE POSNR,
        POD_QTY        TYPE LIPS-LFIMG,
        MBLNR          TYPE MBLNR,
        VBELN_VF       TYPE VBELN_VF,
        ZPJNO          TYPE VBAK-ZPJNO,
        ZPTXT          TYPE ZSD0106T-ZPTXT,
        VBEVA          TYPE VBELN_VA,
        VBEVL_O        TYPE VBELN_VL,
        POSVL_O        TYPE POSNR_VL,
        WADAT_IST_O    TYPE LIKP-WADAT_IST,
        MON            TYPE I,
        POD,
        CHK,
        SER,
        BSTNK          TYPE VBAK-BSTNK,
        POD_STAT       TYPE CHAR10,      "POD 상태가 정상이 아닌것들
        NETWR_P        TYPE VBAP-NETWR,
        MWSBP          TYPE VBAP-MWSBP,
        INCO1          TYPE LIKP-INCO1, " CHM2510-00065
        LIFNR          TYPE VBPA-LIFNR," CHM2510-00065
        MSGPOP         TYPE RS_T_MSG.
        INCLUDE    TYPE TY_S_ALVDEF. "ALV Default Fields
DATA :  END OF G_ITAB_T.


DATA : BEGIN OF GS_S0200.
         INCLUDE STRUCTURE G_ITAB_T.
DATA :   QCODE      LIKE ZGTSDT0066-QCODE,
         QNAME_PRNT LIKE ZGTSDT0066-QNAME_PRNT,
         CONF_PRICE LIKE ZGTSDT0066-CONF_PRICE,
         QPRICE     LIKE ZGTSDT0066-QPRICE,
         QQTY       LIKE ZGTSDT0066-QQTY,
         QUNIT      LIKE ZGTSDT0066-QUNIT,
         QWAERK     LIKE ZGTSDT0066-QWAERK,
         DLV_QAMT   LIKE ZGTSDT0066-QPRICE,
         ZTAX3      LIKE ZGTSDT0066-QPRICE,
       END OF GS_S0200,
       GT_S0200 LIKE TABLE OF GS_S0200.

DATA: BEGIN OF G_CRDR_T OCCURS 0.
        INCLUDE STRUCTURE G_ITAB_T.
DATA: END OF G_CRDR_T.

DATA: BEGIN OF G_TMP_T OCCURS 0,
        VBELN LIKE LIPS-VBELN,                  " 납품번호
      END OF G_TMP_T.

DATA: BEGIN OF G_TMP2_T OCCURS 0,
        VBELN LIKE LIPS-VBELN,                  " 납품번호
      END OF G_TMP2_T.

DATA: BEGIN OF G_TMP3_T OCCURS 0,
        VBELN LIKE LIPS-VBELN,                  " 납품번호
        POSNR LIKE LIPS-POSNR,                  " 납품품목
      END OF G_TMP3_T.

DATA: BEGIN OF G_SUM_T OCCURS 0,
        WAERK   LIKE VBAP-WAERK,                  " 통화
        S_NETWR LIKE VBAP-NETWR,                " 청구(Tax포함)액(Sum)
        NETWR   LIKE VBAP-NETWR,                  " 금액(Sum)
        ZTAX2   TYPE P DECIMALS 0,                " Tax(Sum)
      END OF G_SUM_T.

DATA: BEGIN OF G_IT_T OCCURS 0,
        VBELN LIKE LIPS-VBELN,                  " 납품번호
        POSNR LIKE LIPS-POSNR,                  " 납품품목
        PRSDT LIKE SY-DATUM,                    " 가격결정일
      END OF G_IT_T.

DATA : BEGIN OF GS_LIP_STS,
         VBELN TYPE LIPS-VBELN,
         POSNR TYPE LIPS-POSNR,
         FKSTK TYPE LIKP-FKSTK,
         GBSTK TYPE LIKP-GBSTK,
         PDSTK TYPE LIKP-PDSTK,
         FKSTA TYPE LIPS-FKSTA,
         PDSTA TYPE LIPS-PDSTA,
         KZPOD TYPE LIPS-KZPOD,
         VGBEL TYPE LIPS-VGBEL,
         VGPOS TYPE LIPS-VGPOS,
         CHARG TYPE LIPS-CHARG,
         LFIMG TYPE LIPS-LFIMG,
         MEINS TYPE LIPS-MEINS,
         UECHA TYPE LIPS-UECHA,
         MBLNR TYPE MBLNR,
       END OF GS_LIP_STS,
       GT_LIP_STS   LIKE TABLE OF GS_LIP_STS,
       GT_LIP_STS_C LIKE TABLE OF GS_LIP_STS,
       GT_POD       LIKE TABLE OF G_ITAB_T WITH HEADER LINE,
       GT_1010      TYPE TABLE OF ZGTSDT1010
               WITH NON-UNIQUE SORTED KEY K_KEY COMPONENTS VBELN_VF
               WITH NON-UNIQUE SORTED KEY K_KEY2 COMPONENTS MBLNR
               WITH NON-UNIQUE SORTED KEY K_KEY3 COMPONENTS VBELN MBLNR,
       GT_LOG       LIKE TABLE OF ZGTSDT1010.

DATA : BEGIN OF GT_MBLNR OCCURS 0,
         VBELN TYPE VBELN_VL,
         POSNR TYPE POSNR,
         POSNN TYPE POSNR,
         MBLNR TYPE MBLNR,
         VBEVF TYPE VBELN_VF,
       END OF GT_MBLNR,
       GT_VBPOK TYPE TABLE OF VBPOK WITH EMPTY KEY.

*START 2026.08.10 추가
*CHM2608-00034 부스닥트 POD 프로세스 개선 요청
DATA: lt_pod_err LIKE TABLE OF gt_pod,
        ls_pod_err LIKE LINE OF gt_pod,   " 실패한 납품 내역을 담을 테이블 (선언부 추가)
        lv_single_err TYPE char1.
*      lt_success_pod LIKE TABLE OF gt_pod,
*      ls_success_pod LIKE LINE OF gt_pod.
*END 2026.08.10 추가

DATA : BEGIN OF G_MENU_T OCCURS 0, " 선택적메뉴생성을위한테이블
         FCODE LIKE RSMPE-FUNC,
       END OF G_MENU_T.
DATA  : GL_FLAG TYPE C.
**========================
** BDC관련 Internal Table
**========================
** MESSAGES OF CALL TRANSACTION
DATA: G_MSG_T LIKE BDCMSGCOLL
              OCCURS 0 WITH HEADER LINE.

** BDCDATA DECLARE
DATA: BEGIN OF BDCTAB OCCURS 0.
        INCLUDE STRUCTURE BDCDATA.
DATA: END OF BDCTAB.

DATA: BEGIN OF G_BDC_T OCCURS 0,
        MARK,
        VBELN(10),              " 납품문서
        POSNR(6),               " 납품품목
        REMN_QTY(17),           " 납품수량
        KURRF(12),              " 환율(수출에서 사용)
        SUBRC        LIKE SY-SUBRC,    " BDC수행결과
        MESG(70),               " BDC메세지
      END OF G_BDC_T.

** 화면에 입력된 값을 읽어들이기 위한 INTERNAL TABLE
DATA : BEGIN OF G_DYNPFIELDS_T OCCURS 0.
         INCLUDE STRUCTURE DYNPREAD.
DATA : END OF G_DYNPFIELDS_T.

* 사업장 POSSIBLE ENTRY ITAB.
DATA : BEGIN OF G_VALUES3_T OCCURS 0,
         VKBUR LIKE TVKBZ-VKBUR,      " 영업팀
         BEZEI LIKE TVKBT-BEZEI,      " 영업팀 TEXT
       END OF G_VALUES3_T.

* 영업그룹 POSSIBLE ENTRY ITAB.
DATA : BEGIN OF G_VALUES4_T OCCURS 0,
         VKGRP LIKE TVBVK-VKGRP,      " 영업그룹
         BEZEI LIKE TVGRT-BEZEI,      " 영업그룹 TEXT
       END OF G_VALUES4_T.

DATA : G_TOTCNT    TYPE I,
       G_CNT       TYPE I,
       G_BDC_GUBUN,            " A, H => '2'  K => '1'
       G_FLAG,
       G_UCOMM     LIKE SY-UCOMM,
       G_FLAG2,
       G_POPUP,
       G_ERR,
       G_FDIS,
       GV_BILL_YN,   "빌링 완료후 확정 버튼 활성/비활성 FLAG
       G_SUBRC     LIKE SY-SUBRC,    " BDC수행결과
       G_MESG(70),               " BDC메세지
       G_IMODE     LIKE HRVCOST-MODE.

** 신규가격결정시 필요한 Internal Table
*------- Massen?derung: Selektierte S?ze -----------------------------*
DATA : BEGIN OF BULK_CHANGE OCCURS 100.
         INCLUDE STRUCTURE RV45C.
DATA : END OF BULK_CHANGE.

*------- Massen?derung: Protokoll der 훞derungen in den Belegen ------*
DATA : BEGIN OF XVBFS OCCURS 100.
         INCLUDE STRUCTURE VBFS.
DATA : END OF XVBFS.

**------ Tabelle der Belegzeilen --------------------------------------*
DATA : BEGIN OF POSTAB OCCURS 200.
         INCLUDE STRUCTURE VBMTV.       " Listanzeigen-Struktur
DATA : END   OF POSTAB.

** Simulation시 사용할 Field
DATA : G_DEFAULT_DATA LIKE RV60A.
DATA : G_INVOICE_LIST(1).
DATA : GT_FVKDFI LIKE VKDFIF OCCURS 10 WITH HEADER LINE.

DATA : G_LINEN(3)     TYPE N,
       G_OUT_TEXT(70) TYPE C.

DATA : G_DATA1(100),
       G_DATA2(100),
       G_DATA3(100),
       G_DATA4(100),
       G_DATA5(100),
       G_NETWR           LIKE VBAP-NETWR,
       G_P_NETWR(15)     TYPE P DECIMALS 0,
       G_C_NETWR(20),
       G_P_NETWR_TOT(15) TYPE P DECIMALS 0,
       G_C_NETWR_TOT(20),
       G_NETWR2          LIKE VBAP-NETWR,
       G_P_NETWR2(15)    TYPE P DECIMALS 0,
       G_C_NETWR2(20),
       G_P_ZTAX2(15)     TYPE P DECIMALS 0,
       G_C_ZTAX2(20).

** 부가세/청구액조정 Popup 변수
DATA : G_P_AUART     LIKE VBAK-AUART,
       G_P_VKORG     LIKE VBAK-VKORG,
       G_P_VTWEG     LIKE VBAK-VTWEG,
       G_P_SPART     LIKE VBAK-SPART,
       G_P_VKBUR     LIKE VBAK-VKBUR,
       G_P_VKGRP     LIKE VBAK-VKGRP,
       G_P_DATE(8),
       G_P_KUNNR     LIKE KNA1-KUNNR,
       G_P_NAME1     LIKE KNA1-NAME1,
       G_P_MATNR     LIKE MARA-MATNR,
       G_P_MAKTX     LIKE MAKT-MAKTX,
       G_P_WERKS     LIKE LIPS-WERKS,
       G_P_TAX       TYPE P DECIMALS 0,
       G_C_TAX(15),
       G_P_WAERK     LIKE VBAP-WAERK,                  " 통화
       G_P_ZAMNT     LIKE VBAP-NETWR,                  " 청구액
       G_C_ZAMNT(15).
DATA : LL_CHECK_CNT_ITAB TYPE I.

DATA : GS_LOCK TYPE ZGTSDS1080.

*___2014052100061 빌링 시, 원가 대체 전표 확인 로직 추가 요청

DATA : GV_ERROR,
       GV_TYPE.
DATA : GV_TBIMM.
DATA : GV_ZBELNR TYPE  VBRK-ZBELNR,
       GV_ZGJAHR TYPE  VBRK-ZGJAHR.

*----------------------------------------------------------------------*
* VARIABLE
*----------------------------------------------------------------------*
DATA : GV_SAVEOK LIKE SY-UCOMM,
       GV_OKCODE LIKE SY-UCOMM,
       GV_EDIT   TYPE CHAR1,
       GV_VALID  TYPE CHAR1,
       GV_ANSWER TYPE CHAR1,
       GV_SPMON TYPE SPMON. "Lock Object용

DATA : GT_FCODE   TYPE TABLE OF SY-UCOMM,
       GT_CELLTAB TYPE LVC_T_STYL.

*----------------------------------------------------------------------*
*  ALV GRID.
*----------------------------------------------------------------------*

DATA : GT_TOOLBAR TYPE UI_FUNCTIONS.
DATA : GT_TOOLBAR2 TYPE UI_FUNCTIONS.
DATA : GO_CON     TYPE REF TO CL_GUI_DOCKING_CONTAINER,
       GO_GRID    TYPE REF TO CL_GUI_ALV_GRID,
       GT_FCAT    TYPE LVC_T_FCAT,
       GS_FCAT    TYPE LVC_S_FCAT,
       GT_SORT    TYPE LVC_T_SORT,   " ALV Sort
       GS_LAYOUT  TYPE LVC_S_LAYO,

       GO_CON2    TYPE REF TO CL_GUI_DOCKING_CONTAINER,
       GO_GRID2   TYPE REF TO CL_GUI_ALV_GRID,
       GT_FCAT2   TYPE LVC_T_FCAT,
       GS_FCAT2   TYPE LVC_S_FCAT,
       GT_SORT2   TYPE LVC_T_SORT,   " ALV Sort
       GS_LAYOUT2 TYPE LVC_S_LAYO,

       GO_SPLIT   TYPE REF TO CL_GUI_SPLITTER_CONTAINER,
       GO_CON_TOP TYPE REF TO CL_GUI_CONTAINER,
       GO_DOCU    TYPE REF TO CL_DD_DOCUMENT.


DATA : GS_VARIANT2 TYPE DISVARIANT.
DATA : GS_STBL TYPE LVC_S_STBL.

DATA : GT_ROW TYPE LVC_T_ROW WITH HEADER LINE,
       GS_ROW LIKE GT_ROW.

*----------------------------------------------------------------------*
* DEFINE
*----------------------------------------------------------------------*
DEFINE __CLE.
  CLEAR: &1, &1[].
END-OF-DEFINITION.

DEFINE __RNG.
  &1-SIGN   = &2.
  &1-OPTION = &3.
  &1-LOW    = &4.
  &1-HIGH    = &5.
  APPEND &1. CLEAR &1.
END-OF-DEFINITION.

DEFINE __ALPHA_IN.
  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      INPUT  = &1
    IMPORTING
      OUTPUT = &2.
END-OF-DEFINITION.

DEFINE __ALPHA_OU.
  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
    EXPORTING
      INPUT  = &1
    IMPORTING
      OUTPUT = &2.
END-OF-DEFINITION.
