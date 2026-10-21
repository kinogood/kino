*&---------------------------------------------------------------------*
*&  Include           ZSDR1001T                                        *
*&---------------------------------------------------------------------*
*----------------------------------------------------------------------*
*   TABLE DECLARATION                                                  *
*----------------------------------------------------------------------*
TYPE-POOLS : SLIS.
* Includes
INCLUDE <ICON>.
INCLUDE <SYMBOL>.

TABLES: V_VMVAF,   " 리베이트 계약과 주문번호 연결 테이블
        S060,      " 리베이트 계약별 누적 금액 테이블
        VBFA,      " 영업문서흐름
        VBRK,      " Billing Header Table
        VBRP,      " Billing item Table
*-> CCM : 10.04.2023 09:39:45 / ZLSGSD2
*        vbox,      " 청구문서: 리베이트인덱스
*<-
        VBAK,
        BKPF,
        BSEG,
        BSAD,
        BSID,
        KONV,
        KONH,
        KONP,
        VBKD,
        BSIK,
        KONA,      " 리베이트 계약
        KNA1,      " CUSTOMER MASTER
        LFA1,      " VENDER MASTER(GENERAL SECTION)
        BSAK,
        CTU_PARAMS,    " CALL TRANSACTION OPTION..
        ZSD0016T,
        ZSD0017T,
        TCURX.


*----------------------------------------------------------------------*
*                    변수 선언                                         *
*----------------------------------------------------------------------*
DATA : GV_VBELN         LIKE VBRP-VBELN,
       GV_POSNR         LIKE VBRP-POSNR,
       GV_BELNR         LIKE BKPF-BELNR,
       GV_POS           TYPE I,
       GV_UCOMM         LIKE SY-UCOMM,
       GV_DATE          LIKE SY-DATUM,
       GV_LDATE         LIKE SY-DATUM,
       GV_NODE_KEY      TYPE MTREEITM,
       GV_ITEM_NAME(30),
       GV_LIFNR         LIKE LFA1-LIFNR,
       GV_FLAG,
       GV_ERROR,
*___기능개선 52912 - 커미션 이중지급을 방지하기 위해 지급제외 요청.
       GV_ERROR2,
       GV_ERROR3,
       GV_ANSWER.
*___기능개선 52912

DATA:  C_HKONT LIKE BSEG-HKONT. "value '6430101',   "총계정원장계정
CONSTANTS : C_KSCHL  LIKE KONV-KSCHL VALUE 'BO03',
            C_SSOUR  LIKE S060-SSOUR VALUE ' ',
            C_VRSIO  LIKE S060-VRSIO VALUE '000',
            C_FKSTO  LIKE VBRK-FKSTO VALUE 'X', " 취소 여부
            C_SFAKN  LIKE VBRK-SFAKN VALUE ' ', " 취소 문서
            C_RFBSK  LIKE VBRK-RFBSK VALUE 'E', " 회계로의 전송상태
            C_BLIGHT VALUE '3',  " 부가세전표 생성완료
            C_CLIGHT VALUE '2',  " 지급전표 생성완료
            C_FLIGHT VALUE '1',  " 전표 생성 미완료
            C_COMPL  VALUE 'C', "
*            c_hkont like bseg-hkont value '6430101',   "총계정원장계정
            C_MWSKZ  LIKE BSEG-MWSKZ VALUE 'V0',  "부가가치세코드(국외)
            C_MWSKZ2 LIKE BSEG-MWSKZ VALUE 'VA',  "부가가치세코드(국내)
*            c_bukrs like bseg-bukrs value '1000',  "LG 전선
            C_RATE   TYPE P DECIMALS 2 VALUE '0.1',  " 부가가치세 비율
            C_UMSKZ  LIKE BSEG-UMSKZ VALUE 'B',  "특별G/L
            C_XMWST  LIKE BKPF-XMWST VALUE 'X', "세금계산
            C_BLART  LIKE BKPF-BLART VALUE 'EA', "전표유형
            C_POSNR  LIKE VBAP-POSNR VALUE '000010',
            C_AUGRU  LIKE VBAK-AUGRU VALUE 'B31'.

DATA: C_BUPLA LIKE BSEG-BUPLA, "value '110', "사업장
      C_BUKRS LIKE BSEG-BUKRS.

CONSTANTS: GC_VKORG_6000 TYPE VKORG   VALUE '6000'.
*-------------------------------------------------------------------*
*   DATA DECLARATION (INTERNAL TABLE DECLARE)                       *
*-------------------------------------------------------------------*
DATA: BEGIN OF G_ITAB_T OCCURS 0,
        VKORG       LIKE VBRK-VKORG,
        VTWEG       LIKE VBRK-VTWEG,
        SPART       LIKE VBRK-SPART,
        VKBUR       LIKE VBRP-VKBUR,              " 사업장
        BEZEI       LIKE TVKBT-BEZEI,             " 사업장명
        VKGRP       LIKE VBRP-VKGRP,
        BEZEI2      LIKE TVGRT-BEZEI,            " 영업그룹명
        BONEM       LIKE KONA-BONEM,              " Agent
        NAME        LIKE KNA1-NAME1,              " Agent명
        KUNAG       LIKE VBRK-KUNAG,              " 고객
        NAME1       LIKE KNA1-NAME1,              " 고객명
        KUNAG2      LIKE VBRK-KUNAG,              " 납품처 20180112 추가
        NAME2       LIKE KNA1-NAME1,              " 납품처명 20180112 추가
        KNUMA       LIKE KONA-KNUMA,              " 계약 NO
        BOTEXT      LIKE KONA-BOTEXT,            " 계약명
        BOSTA       LIKE KONA-BOSTA,              " 계약상태
        FBUDA       LIKE ZSD0016T-FBUDA,          " 정산월
        WRBTR       LIKE ZSD0016T-WRBTR,        " 미지급금
        WRBTR2      LIKE ZSD0017T-WRBTR,        " 지급금액
        R_WRBTR     LIKE ZSD0017T-WRBTR,        " 지급가능금액
        WAERS       LIKE KONA-WAERS,            " 통화
        BUGA_AMNT   LIKE ZSD0016T-BUGA_AMNT,  " 미지급부가세액(원화)
        BUGA        LIKE ZSD0017T-BUGA_AMNT,    " 지급부가세액
        R_BUGA      LIKE ZSD0017T-BUGA_AMNT,    " 지급가능부가세액
        K_WAERK     LIKE ZSD0016T-K_WAERK,      " 통화(원화)
        VBELN2      LIKE VBRK-VBELN,            " 대금청구문서
        NETWR       LIKE VBRK-NETWR,              " 대금청구금액
        WAERK       LIKE VBRK-WAERK,              " 대금청구통화
        VBELN       LIKE ZSD0016T-VBELN,          " 정산오더번호
        BELNR       LIKE ZSD0016T-BELNR,          " 미지급전표번호
        BUGA_BELNR  LIKE ZSD0016T-BUGA_BELNR,   " 부가세미지급전표번호
        BELNR2      LIKE ZSD0017T-BELNR,        " 지급전표번호
        BUGA_BELNR2 LIKE ZSD0016T-BUGA_BELNR,   " 부가세지급전표번호
        SUKUM       LIKE BSID-WRBTR,            " 수금액(전표통화금액)
        K_SUKUM     LIKE BSID-WRBTR,            " 수금액(현지통화금액)
        YUBOM       LIKE BSID-WRBTR,            " 유보금(전표통화금액)
        K_YUBOM     LIKE BSID-WRBTR,            " 유보금(현지통화금액)
        YUSUK       LIKE BSID-WRBTR,            " 유보금수금액(전표)
        K_YUSUK     LIKE BSID-WRBTR,            " 유보금수금액(현지)
        REAMT       LIKE VBRK-NETWR,            " 반품상계금액
        REERK       LIKE VBRK-WAERK,            " 반품상계통화
        RETXT(10),

        ZBELNR      LIKE ZSD0016T-ZBELNR,
        ZOUT        LIKE ZSD0016T-ZOUT,
        ZMSG        LIKE ZSD0016T-ZMSG,

*-> CCM : 09.10.2023 01:02:02 / ZLSGSD3
        ECC_MIG(1),                             " ECC MIG 데이터 구분자
*<-

      END OF G_ITAB_T.

DATA : BEGIN OF G_TMP_T OCCURS 0.
         INCLUDE STRUCTURE G_ITAB_T.
DATA : END OF G_TMP_T.

DATA : BEGIN OF GT_BELNR2 OCCURS 0,
         BELNR2       LIKE ZSD0017T-BELNR2,
         FBUDA2       LIKE ZSD0017T-FBUDA2,
         FBUDA_BELNR2 LIKE ZSD0017T-FBUDA_BELNR2.
DATA : END OF GT_BELNR2.

DATA: BEGIN OF G_HEADER_T OCCURS 0,
        BONEM     LIKE KONA-BONEM,              " Agent
        NAME      LIKE KNA1-NAME1,              " Agent명
        KNUMA     LIKE KONA-KNUMA,              " 계약 NO
        FBUDA     LIKE ZSD0016T-FBUDA,          " 정산월
        VBELN     LIKE ZSD0016T-VBELN,          " 정산오더번호
        BELNR     LIKE ZSD0016T-BELNR,          " 미지급전표번호
        KUNAG     LIKE VBRK-KUNAG,              " 고객
        NAME1     LIKE KNA1-NAME1,              " 고객명
        KUNAG2    LIKE VBRK-KUNAG,              " 납품처 20180112 추가
        NAME2     LIKE KNA1-NAME1,              " 납품처명 20180112 추가
        WRBTR     LIKE ZSD0016T-WRBTR,        " 미지급금
*        wrbtr like kona-MAXBO,              " 미지급금
        WAERS     LIKE KONA-WAERS,            " 통화
        BUGA_AMNT LIKE ZSD0016T-BUGA_AMNT,  " 미지급부가세액(원화)
        K_WAERK   LIKE ZSD0016T-K_WAERK,      " 통화(원화)
      END OF G_HEADER_T.

DATA: BEGIN OF G_ITEM_T OCCURS 0,
        BOX,
        LIGHTS,
        BONEM        LIKE KONA-BONEM,              " Agent
        NAME         LIKE KNA1-NAME1,              " Agent명
        KUNAG        LIKE VBRK-KUNAG,              " 고객
        KNUMA        LIKE KONA-KNUMA,              " 계약 NO
        FBUDA        LIKE ZSD0016T-FBUDA,          " 정산월
        VKBUR        LIKE VBRP-VKBUR,              " 사업장
        VBELN        LIKE ZSD0016T-VBELN,          " 정산오더번호
        BELNR        LIKE ZSD0016T-BELNR,          " 미지급전표번호
        VBELN2       LIKE VBRK-VBELN,            " 대금청구문서
        NETWR        LIKE VBRK-NETWR,              " 대금청구금액
        WAERK        LIKE VBRK-WAERK,              " 대금청구통화
        WRBTR        LIKE ZSD0016T-WRBTR,        " 미지급금
        WRBTR2       LIKE ZSD0017T-WRBTR,        " 지급금액(누적)
        R_WRBTR      LIKE ZSD0017T-WRBTR,        " 지급가능금액
        WAERS        LIKE KONA-WAERS,            " 통화
        BUGA_AMNT    LIKE ZSD0016T-BUGA_AMNT,  " 미지급부가세액(원화)
        BUGA         LIKE ZSD0017T-BUGA_AMNT,    " 지급부가세액(누적)
        R_BUGA       LIKE ZSD0017T-BUGA_AMNT,    " 지급가능부가세액
        K_WAERK      LIKE ZSD0016T-K_WAERK,      " 통화(원화)
        BUGA_BELNR   LIKE ZSD0016T-BUGA_BELNR, " 부가세미지급전표번호
**  누적지급금액을 계산하기 위해 Remark.  보류
        BELNR2       LIKE ZSD0017T-BELNR,         " 지급전표번호
        BUGA_BELNR2  LIKE ZSD0016T-BUGA_BELNR, " 부가세지급전표번호
        SUKUM        LIKE BSID-WRBTR,              " 수금액
        YUBOM        LIKE BSID-WRBTR,              " 유보금
        YUSUK        LIKE BSID-WRBTR,              " 유보수금액
        FBUDA2       LIKE ZSD0017T-FBUDA2,        " 지급전표 전기일자
        FBUDA_BELNR2 LIKE ZSD0017T-FBUDA_BELNR2, "부가세지급전표 전기일
        REAMT        LIKE VBRK-NETWR,              " 반품상계금액
        REERK        LIKE VBRK-WAERK,              " 반품상계통화
        RETXT(10),

        ZBELNR       LIKE ZSD0016T-ZBELNR,
        ZOUT         LIKE ZSD0016T-ZOUT,
        ZMSG         LIKE ZSD0016T-ZMSG,


      END OF G_ITEM_T.

** 상세화면에 넘길 Internal TBL
DATA: BEGIN OF G_IT_T OCCURS 0,
        KNUMA      LIKE ZSD0017T-KNUMA,
        FBUDA      LIKE ZSD0017T-FBUDA,
        VBELN      LIKE ZSD0017T-VBELN,
        BELNR      LIKE ZSD0017T-BELNR,
        VBELN2     LIKE ZSD0017T-VBELN2,
        BUGA_BELNR LIKE ZSD0016T-BUGA_BELNR, " 부가세미지급전표번호
        WRBTR      LIKE ZSD0016T-WRBTR,        " 미지급금
        BUGA_AMNT  LIKE ZSD0016T-BUGA_AMNT,  " 미지급부가세액(원화)
        GUBUN,  " 1:전표생성미완료, 2:지급전표생성, 3:부가세전표생성

        BONEM      LIKE KONA-BONEM,           " Agent
        NAME1      LIKE KNA1-NAME1,           " Agent명
        KUNAG      LIKE VBRK-KUNAG,           " 고객
        NAME2      LIKE KNA1-NAME1,           " 고객명
        NETWR      LIKE VBRK-NETWR,           " 대금청구금액
        WAERK      LIKE VBRK-WAERK,           " 대금청구통화
*        wrbtr       like zsd0016t-wrbtr,       " 미지급금
        WRBTR2     LIKE ZSD0017T-WRBTR,       " 지급금액(누적)
        R_WRBTR    LIKE ZSD0017T-WRBTR,       " 지급가능금액
        WAERS      LIKE KONA-WAERS,           " 통화
*        buga_amnt   like zsd0016t-buga_amnt,   " 미지급부가세액(원화)
        BUGA       LIKE ZSD0017T-BUGA_AMNT,   " 지급부가세액(누적)
        R_BUGA     LIKE ZSD0017T-BUGA_AMNT,   " 지급가능부가세액
*        k_waerk     like zsd0016t-k_waerk,     " 통화(원화)
*        buga_belnr  like zsd0016t-buga_belnr,  " 부가세미지급전표번호
*        belnr2      like zsd0017t-belnr,       " 지급전표번호
*        buga_belnr2 like zsd0016t-buga_belnr,  " 부가세지급전표번호
        SUKUM      LIKE BSID-WRBTR,           " 수금액
        YUBOM      LIKE BSID-WRBTR,           " 유보금
        YUSUK      LIKE BSID-WRBTR,           " 유보수금액
*        FBUDA2      LIKE ZSD0017T-FBUDA2,      " 지급전표 전기일자
      END OF G_IT_T.

** 지급을 분할로 처리할경우 사용할 Internal TBL.
DATA: BEGIN OF G_TMP2_T OCCURS 0,
        BELNR2 LIKE ZSD0017T-BELNR2,
      END OF G_TMP2_T.

** 대체수취인관련 Internal TBL
DATA: BEGIN OF G_LFZA_T OCCURS 0,
        EMPFK LIKE LFZA-EMPFK,
      END OF G_LFZA_T.
DATA: G_H_EMPFK LIKE LFZA-EMPFK,
      G_H_NAME1 LIKE LFA1-NAME1.
DATA : GT_ZSD0017T TYPE TABLE OF ZSD0017T WITH HEADER LINE.
DATA : LS_BUGA_BELNR2 LIKE ZSD0017T-BUGA_BELNR2.
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
        VBELN(10),              " 대금청구문서
        KDKG4(2),
        SUBRC     LIKE SY-SUBRC,    " BDC수행결과
        MESG(70),               " BDC메세지
      END OF G_BDC_T.

DATA : G_TOTCNT     TYPE I,
       G_EXITFLAG,
       G_SPMON      LIKE ZSD0012T-SPMON,
       G_DATA1(100),
       G_DATA2(100),
       G_DATA3(100),
       G_DATA4(100),
       G_DATA5(100).

DATA : G_XBLNR LIKE BKPF-XBLNR,
       G_VTWEG LIKE VBRK-VTWEG,
       G_SPART LIKE VBRK-SPART,
       G_VKBUR LIKE VBRP-VKBUR,
       G_VKGRP LIKE VBRP-VKGRP,
*       g_pernr like vbpa-pernr,
       G_KUNNR LIKE BSID-KUNNR.

*-> CCM : 20.04.2023 16:44:41 / ZLSGSD4
*ranges : rs_spmon for s060-spmon.
*<-

DATA : G_ZSD0017T LIKE TABLE OF ZSD0017T  WITH HEADER LINE.
DATA : LV_YEAR(4).
DATA : L_BLDAT LIKE BKPF-BLDAT.

DATA : GV_POINT(9) TYPE P DECIMALS 5.

**data : l_KURSF(9) type p decimals 5.

DATA : L_KURSF LIKE BKPF-KURSF.
DATA : LS_KURSF(12) TYPE C.
DATA : L_PSWSL LIKE BSEG-PSWSL,
       L_DMBTR LIKE BSEG-DMBTR,
       L_WRBTR LIKE BSEG-WRBTR.

DATA : G_P_NETWR1 LIKE VBAK-NETWR,   " 외화금액
       G_P_CURR   LIKE VBAK-WAERK,   " 외화통화
       G_P_NETWR3 LIKE VBAK-NETWR.   " 목표원화금액
DATA : G_SYUCOMM  LIKE SY-UCOMM.
*----------------------------------------------------------------------*
* 테이블명
*----------------------------------------------------------------------*
DATA: TBL(100).

*----------------------------------------------------------------------*
*    BDC 관련 변수.
*----------------------------------------------------------------------*
* BDC Mode.
DATA:
  GL_BDCMODE        TYPE CTU_MODE VALUE 'N'.
* BDC Data
DATA:
  GT_BDCDATA TYPE TABLE OF BDCDATA.
* BDC Detail Message.
DATA:
  BEGIN OF GT_BDCMSG OCCURS 0,
    UPDKZ TYPE UPDKZ_D,
    BELNR TYPE BKPF-BELNR.
    INCLUDE STRUCTURE BDCMSGCOLL.
DATA:
  END OF GT_BDCMSG.
* CALL TRANSACTION USING... 실행시간에 대한 매개변수.
DATA: GS_CTU_PARAMS LIKE CTU_PARAMS.

*----------------------------------------------------------------------*
*                    ALV 선언                                          *
*----------------------------------------------------------------------*


*
CONSTANTS:
GC_FORMNAME_TOP_OF_PAGE TYPE SLIS_FORMNAME VALUE 'TOP_OF_PAGE'.
DATA: GT_FIELDCAT      TYPE SLIS_T_FIELDCAT_ALV,
      GS_LAYOUT        TYPE SLIS_LAYOUT_ALV,
      GS_KEYINFO       TYPE SLIS_KEYINFO_ALV,
      GT_SP_GROUP      TYPE SLIS_T_SP_GROUP_ALV,
      GT_EVENTS        TYPE SLIS_T_EVENT,
      GT_EXTAB         TYPE SLIS_T_EXTAB,
      G_BOXNAM         TYPE SLIS_FIELDNAME VALUE  'BOX',
      P_F2CODE         LIKE SY-UCOMM       VALUE  '&ETA',
      P_LIGNAM         TYPE SLIS_FIELDNAME VALUE  'LIGHTS',
      G_SAVE(1)        TYPE C,
      G_TABNAME_HEADER TYPE SLIS_TABNAME,
      G_TABNAME_ITEM   TYPE SLIS_TABNAME,
      G_DEFAULT(1)     TYPE C,
      GS_SELFIELD      TYPE SLIS_SELFIELD,
      G_EXIT(1)        TYPE C,
      GX_VARIANT       LIKE DISVARIANT,
      G_VARIANT        LIKE DISVARIANT.
DATA: GT_LIST_TOP_OF_PAGE TYPE SLIS_T_LISTHEADER,
      G_STATUS_SET        TYPE SLIS_FORMNAME VALUE 'STATUS',
      G_USER_COMMAND      TYPE SLIS_FORMNAME VALUE 'USER_COMMAND',
      G_TOP_OF_PAGE       TYPE SLIS_FORMNAME VALUE 'TOP_OF_PAGE'.
DATA: G_REPID LIKE SY-REPID,
      GT_SORT TYPE SLIS_T_SORTINFO_ALV WITH HEADER LINE.
