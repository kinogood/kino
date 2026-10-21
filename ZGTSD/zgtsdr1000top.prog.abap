*&---------------------------------------------------------------------*
*&  Include           ZSDR1001T                                        *
*&---------------------------------------------------------------------*
*----------------------------------------------------------------------*
*                    TABLE 선언                                        *
*----------------------------------------------------------------------*
TABLES: V_VMVAF,   " 리베이트 계약과 주문번호 연결 테이블
        VBFA,      " 영업문서흐름
        VBRK,      " Billing Header Table
        VBRP,      " Billing item Table
        VBAK,
        BKPF,
        BSEG,
        KNVP,
        VBPA,
*-> CCM : 20.04.2023 15:49:52 / ZLSGSD4
*        S060,      " 리베이트 계약별 누적 금액 테이블
*        VBOX,      " 청구문서: 리베이트인덱스
*       KONV,
        PRCD_ELEMENTS,
*<-
        KONH,
        KONP,
        VBKD,
        KONA,  "리베이트 계약
        KOTE901, " 영업조직/유통경로/제품군/고객/수출업자
*         KOTE902, " 영업조직/유통경로/제품군/고객/납품처
        KOTE903,
        KNA1,    " CUSTOMER MASTER
        LFA1,    " VENDER MASTER(GENERAL SECTION)
        ZSD0015T,
        ZSD0016T.

*----------------------------------------------------------------------*
*                    변수 선언                                         *
*----------------------------------------------------------------------*
DATA : GV_VBELN LIKE VBRP-VBELN,
       GV_POSNR LIKE VBRP-POSNR,
       GV_BELNR LIKE BKPF-BELNR,
       GV_BUGA_BELNR LIKE BKPF-BELNR,
       GV_POS TYPE I,
       GV_DATE  LIKE SY-DATUM,
       GV_LDATE LIKE SY-DATUM,
       GV_TABIX LIKE SY-TABIX,
       G_UCOMM LIKE SY-UCOMM.

DATA : C_HKONT LIKE BSEG-HKONT.
DATA : H_HKONT LIKE BSEG-HKONT.

CONSTANTS : C_KSCHL LIKE KONV-KSCHL VALUE 'BO03',
*-> CCM : 20.04.2023 16:06:13 / ZLSGSD4
*            C_SSOUR LIKE S060-SSOUR VALUE ' ',
*            C_VRSIO LIKE S060-VRSIO VALUE '000',
*<-
            C_FKSTO LIKE VBRK-FKSTO VALUE 'X', " 취소 여부
            C_SFAKN LIKE VBRK-SFAKN VALUE ' ', " 취소 문서
            C_RFBSK LIKE VBRK-RFBSK VALUE 'E', " 회계로의 전송상태
            C_BLIGHT VALUE '3',  " 부가세전표 생성완료
            C_CLIGHT VALUE '2',  " 미지급전표 생성완료
            C_FLIGHT VALUE '1',  " 전표 생성 미완료
            C_COMPL  VALUE 'C', "
*            c_hkont like bseg-hkont value '6430101',   "총계정원장계정
            C_MWSKZ LIKE BSEG-MWSKZ VALUE 'V0',  "부가가치세코드(국외)
            C_MWSKZ2 LIKE BSEG-MWSKZ VALUE 'VA',  "부가가치세코드(국내)
            C_RATE  TYPE P DECIMALS 2 VALUE '0.1',  " 부가가치세 비율
            C_UMSKZ LIKE BSEG-UMSKZ VALUE 'B',  "특별G/L
            C_XMWST LIKE BKPF-XMWST VALUE 'X', "세금계산
            C_BLART LIKE BKPF-BLART VALUE 'EA', "전표유형
            C_POSNR LIKE VBAP-POSNR VALUE '000010',
            C_AUGRU LIKE VBAK-AUGRU VALUE 'B31'.

*----------------------------------------------------------------------*
*                Internal  TABLE 선언                                  *
*----------------------------------------------------------------------*
DATA : BEGIN OF GT_OUTAB OCCURS 0,
*       MARK(1),
       VKORG LIKE KONA-VKORG,
       VTWEG LIKE KONA-VTWEG,
       SPART LIKE KONA-SPART,
       VKBUR LIKE KONA-VKBUR,
       VKGRP LIKE KONA-VKGRP,
       BONEM LIKE KONA-BONEM,     "Agent
       NAME  LIKE KNA1-NAME1,     "Agent명
       KUNNR LIKE KOTE901-KUNNR,  "고객
       NAME1 LIKE KNA1-NAME1,  "고객명
       KNUMA LIKE KONA-KNUMA,  "계약 NO
       BOTEXT LIKE KONA-BOTEXT, "계약명
       BOSTA LIKE KONA-BOSTA,  "계약상태
       WAERS LIKE KONA-WAERS,  "통화
       KBETR LIKE KONP-KBETR,  "RATE
       KONWA LIKE KONP-KONWA,  "RATE 단위
       KPEIN  LIKE KONP-KPEIN,
       KMEIN LIKE KONP-KMEIN,
       DATAB LIKE KOTE903-DATAB, "효력발생일
       DATBI LIKE KOTE903-DATBI, "효력만료일
       VAKEY TYPE VAKEY_50,    "변수키
       KOTABNR LIKE KONH-KOTABNR,
       KAPPL LIKE KONH-KAPPL,
       VBELN2 LIKE VBRK-VBELN,
       POSNR2 LIKE VBRP-POSNR,
       KNUMH  LIKE KONH-KNUMH,
       INCO1  LIKE KOTE903-INCO1,
       KSCHL  LIKE KOTE903-KSCHL,
       GSBER  LIKE ZNFT0003-GSBER,
       END OF GT_OUTAB.

DATA: BEGIN OF GT_HEADER OCCURS 0,
        BOX,
        LIGHTS,
        VKORG LIKE KONA-VKORG,
        VKBUR LIKE KONA-VKBUR,
        VKGRP LIKE KONA-VKGRP,
        BUKRS LIKE BSEG-BUKRS,
        GSBER LIKE ZNFT0003-GSBER,
*__기능개선 115898 - 추가 : 엠트론 사업장 찾는 로직 변경 {
        BUPLA LIKE BSEG-BUPLA.
*__} 기능개선 115898 - 엠트론 사업장 찾는 로직 변경_2016.02.02
        INCLUDE STRUCTURE ZSDS002.
DATA: END OF GT_HEADER.

DATA: BEGIN OF GT_ITEM OCCURS 0.
        INCLUDE STRUCTURE ZSDS003.
data : contr type c.
DATA: END OF GT_ITEM.

DATA : GT_CODE TYPE TABLE OF ZGTPPT1010.

* 상세화면 조회시 전달할 데이터
DATA: BEGIN OF GT_DETAIL OCCURS 0,
        MARK,
        FBUDA   LIKE ZSDS003-FBUDA,
        FKDAT   LIKE ZSDS003-FKDAT,
        KNUMA   LIKE ZSDS002-KNUMA,
        BONEM   LIKE ZSDS002-BONEM,
        NAME    LIKE ZSDS002-NAME,
        KUNNR   LIKE ZSDS002-KUNNR,
        NAME1   LIKE ZSDS002-NAME1,
        WAERK   LIKE VBRK-WAERK,
        NETWR   LIKE VBRK-NETWR,
        INCO1   LIKE ZSDS003-INCO1,
        KBETR   LIKE ZSDS003-KBETR,
        KONWA   LIKE ZSDS003-KONWA,
        KWERT_K LIKE VBRK-NETWR,
        KWAEH   LIKE VBRK-WAERK,
        BELNR   LIKE ZSDS002-BELNR,
        VBELN2  LIKE ZSDS003-VBELN2,
        POSNR   LIKE ZSDS003-POSNR,
        VBELN   LIKE ZSDS002-VBELN,
      END OF GT_DETAIL.


DATA : C_BUPLA LIKE BSEG-BUPLA ,
       C_BUKRS LIKE BSEG-BUKRS .
** 매입부가세 전표생성용 Internal TBL : 2005-07-07
DATA : BEGIN OF G_ITAB_T OCCURS 0,
         MARK,
         KNUMA  LIKE KONA-KNUMA,            " 계약 NO
         FBUDA  LIKE MCS1-SPMON,            " 정산월
         VBELN  LIKE VBAK-VBELN,            " 정산오더번호
         BELNR  LIKE BKPF-BELNR,            " 미지급전표번호
         VBELN2 LIKE VBRK-VBELN,            " 대금청구문서
         POSNR2 LIKE VBRP-POSNR,            " 대금청구품목
         WRBTR  LIKE ZSDS002-WRBTR,         " 커미션발생액
         C_WAERK  LIKE ZSDS002-WAERK,       " 헤더통화(커미션발생액)
         KURRF  LIKE ZSDS003-KURRF,         " 환율
*        k_wrbtr  like zsds002-wrbtr,       " 커미션발생(원화)
         K_WRBTR(15) TYPE P DECIMALS 0,     " 커미션발생액(원화)
         K_WAERK  LIKE ZSDS002-WAERK,       " KRW
         BUGA_BELNR LIKE BKPF-BELNR,        " 부가세전표번호
*        buga_amnt  like bseg-mwsts,        " 부가세액(원화)
         BUGA_AMNT(15) TYPE P DECIMALS 0,   " 부가세액(원화)
         BONEM  LIKE KONA-BONEM,            " Agent
         NAME   LIKE KNA1-NAME1,            " Agent명
         KUNNR  LIKE KOTE901-KUNNR,         " 고객
         NAME1  LIKE KNA1-NAME1,            " 고객명
         GSBER  LIKE BSEG-GSBER,            " 사업영역
         BUPLA  LIKE BSEG-BUPLA,            " 사업장
         NETWR  LIKE VBRK-NETWR,            " 매출액
         WAERK2 LIKE VBRK-WAERK,            " 매출액통화
         MESG(70),
       END OF G_ITAB_T.

DATA: BEGIN OF G_TMP_T OCCURS 0.
        INCLUDE STRUCTURE G_ITAB_T.
DATA: END OF G_TMP_T.

DATA : G_ZSD0016T LIKE TABLE OF ZSD0016T  WITH HEADER LINE.

DATA: BEGIN OF GT_TOTAL OCCURS 0,
      KNUMA LIKE KONA-KNUMA,
*-> CCM : 20.04.2023 16:06:41 / ZLSGSD4
*      FBUDA LIKE S060-SPMON,
      FBUDA LIKE ZSDS004-FBUDA,
      KUNNR LIKE KNA1-KUNNR, "2023.07.19 ZITCS4HDEV01 - 추가
*<-
      KWERT_K LIKE KONV-KWERT.
DATA: END OF GT_TOTAL.

DATA: BEGIN OF GT_VBAK OCCURS 0,
      VBELN LIKE VBAK-VBELN,
      NETWR LIKE VBAK-NETWR,
*      WAERK LIKE VBAK-WAERK,
      BSTNK LIKE VBAK-BSTNK,  "전표번호
      AUGRU LIKE VBAK-AUGRU,  "거절사유
      BUKRS_VF LIKE VBAK-BUKRS_VF.
DATA: END OF GT_VBAK.

*- 윤방희 추가 : 정산오더/정산일
DATA: BEGIN OF SPMON_ITAB OCCURS 0,
        VBELN LIKE VBAK-VBELN,
        FBUDA LIKE VBKD-FBUDA.
DATA : END OF SPMON_ITAB.

DATA: BEGIN OF GT_BKPF OCCURS 0,
      BELNR LIKE BKPF-BELNR,
      XBLNR LIKE BKPF-XBLNR.
DATA: END OF GT_BKPF.

DATA: BEGIN OF GT_BSEG OCCURS 0,
      BELNR LIKE BSEG-BELNR,
      WRBTR LIKE BSEG-WRBTR,
*      ZUONR LIKE BSEG-ZUONR,  "정산오더 번호
      AUGBL LIKE BSEG-AUGBL,
      BUKRS LIKE BSEG-BUKRS.
DATA: END OF GT_BSEG.

DATA: BEGIN OF GT_VBRK OCCURS 0,
      VBELN LIKE VBRK-VBELN,
      FKDAT LIKE VBRK-FKDAT,
      INCO1 LIKE VBRK-INCO1,
      ZTERM LIKE VBRK-ZTERM,
      KURRF LIKE VBRK-KURRF,
      WAERK LIKE VBRK-WAERK,
*     NETWR LIKE VBRK-NETWR,
      RFBSK LIKE VBRK-RFBSK,
      SFAKN LIKE VBRK-SFAKN,
      KNUMV LIKE VBRK-KNUMV,
      VBTYP LIKE VBRK-VBTYP.
DATA: END OF GT_VBRK.

DATA: BEGIN OF GT_VBRP OCCURS 0,
      VBELN LIKE VBRP-VBELN,
      POSNR LIKE VBRP-POSNR,
      MATNR LIKE VBRP-MATNR,
      ARKTX LIKE VBRP-ARKTX,
      NETWR LIKE VBRP-NETWR,
      BONBA LIKE VBRP-BONBA.
DATA: END OF GT_VBRP.

DATA: GT_OUTABH LIKE GT_OUTAB OCCURS 0 WITH HEADER LINE.
DATA: GT_OUTABI LIKE GT_OUTAB OCCURS 0 WITH HEADER LINE.
DATA: GT_VMVAF LIKE V_VMVAF OCCURS 0 WITH HEADER LINE.
DATA: GT_VBFA  LIKE VBFA    OCCURS 0 WITH HEADER LINE.
*-> CCM : 20.04.2023 15:54:31 / ZLSGSD4
*DATA: GT_VBUK  LIKE VBUK    OCCURS 0 WITH HEADER LINE.
*DATA : GT_VBOX LIKE VBOX OCCURS 0 WITH HEADER LINE.
*<-
DATA: GT_BKPF_TMP  LIKE GT_BKPF  OCCURS 0 WITH HEADER LINE.
*DATA: GT_BSEG  LIKE BSEG    OCCURS 0 WITH HEADER LINE.
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
TYPE-POOLS: SLIS.
* Includes
INCLUDE <ICON>.
INCLUDE <SYMBOL>.
*
CONSTANTS:
GC_FORMNAME_TOP_OF_PAGE TYPE SLIS_FORMNAME VALUE 'TOP_OF_PAGE'.
DATA: GT_FIELDCAT TYPE SLIS_T_FIELDCAT_ALV,
      GS_LAYOUT   TYPE SLIS_LAYOUT_ALV,
      GS_KEYINFO  TYPE SLIS_KEYINFO_ALV,
      GT_SP_GROUP TYPE SLIS_T_SP_GROUP_ALV,
      GT_EVENTS   TYPE SLIS_T_EVENT,
      GT_EXTAB       TYPE SLIS_T_EXTAB,
      G_BOXNAM TYPE SLIS_FIELDNAME VALUE  'BOX',
      P_F2CODE LIKE SY-UCOMM       VALUE  '&ETA',
      P_LIGNAM TYPE SLIS_FIELDNAME VALUE  'LIGHTS',
      G_SAVE(1) TYPE C,
      G_TABNAME_HEADER TYPE SLIS_TABNAME,
      G_TABNAME_ITEM   TYPE SLIS_TABNAME,
      G_DEFAULT(1) TYPE C,
      GS_SELFIELD    TYPE SLIS_SELFIELD,
      G_EXIT(1) TYPE C,
      GX_VARIANT LIKE DISVARIANT,
      G_VARIANT LIKE DISVARIANT.
DATA: GT_LIST_TOP_OF_PAGE TYPE SLIS_T_LISTHEADER,
      G_STATUS_SET   TYPE SLIS_FORMNAME VALUE 'STATUS',
      G_USER_COMMAND TYPE SLIS_FORMNAME VALUE 'USER_COMMAND',
      G_TOP_OF_PAGE  TYPE SLIS_FORMNAME VALUE 'TOP_OF_PAGE'.
DATA: G_REPID LIKE SY-REPID,
      GT_SORT TYPE SLIS_T_SORTINFO_ALV WITH HEADER LINE .

*----------------------------------------------------------------------*
*                    SELECTION-SCREEN LAY-OUT                          *
*----------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK B1  WITH FRAME TITLE TEXT-001.
SELECT-OPTIONS: S_VKORG FOR KONA-VKORG
                    NO-EXTENSION  NO INTERVALS
                    OBLIGATORY MEMORY ID VKO,  "영업조직
                S_VTWEG FOR KONA-VTWEG
                    NO-EXTENSION NO INTERVALS OBLIGATORY MEMORY ID VTW,
* 유통경로
                S_SPART FOR KONA-SPART
                    NO-EXTENSION NO INTERVALS OBLIGATORY MEMORY ID SPA,
* 제품군
*                s_vkbur for kona-vkbur
*                            no intervals obligatory,  "사업장
*                s_vkgrp for kona-vkgrp
*                            no intervals obligatory,  "영업그룹
                S_BONEM FOR KONA-BONEM OBLIGATORY,  "Agent 명
                S_KNUMA FOR KONA-KNUMA
                            NO INTERVALS. "obligatory.  "계약NO
*-> CCM : 20.04.2023 16:07:09 / ZLSGSD4
*PARAMETERS:     P_SPMON LIKE S060-SPMON   DEFAULT SY-DATUM
*                                          OBLIGATORY.  "기간
PARAMETERS:     P_SPMON LIKE ZSDS004-FBUDA DEFAULT SY-DATUM
                                           OBLIGATORY.  "기간
*<-
SELECT-OPTIONS: S_BOSTA FOR KONA-BOSTA   DEFAULT 'D'
                                         OPTION NE SIGN I.  "계약상태

*SELECTION-SCREEN SKIP 1.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT  (31) TEXT-003.
PARAMETERS: P_R01    AS CHECKBOX DEFAULT 'X'.
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN SKIP 1.

* [START] CSR Number : C20120127_39857
* 검색조건에 대금청구일 추가
SELECT-OPTIONS: S_FKDAT FOR VBRK-FKDAT.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT  (31) TEXT-006.
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN SKIP 1.

* [END] CSR Number : C20120127_39857

*>> START - Archiving 관련변경 01 -> 20080312

*-- TEXT: '아카이브 데이터 포함'
PARAMETERS: P_ARCV AS CHECKBOX.
*>> END   - Archiving 관련변경 01 -> 20080312
SELECTION-SCREEN SKIP 1.

PARAMETERS: P_MODE TYPE CTU_MODE DEFAULT 'N'.

SELECTION-SCREEN END OF BLOCK B1.

SELECTION-SCREEN BEGIN OF BLOCK B2 WITH FRAME TITLE TEXT-002.
PARAMETERS : P_VARI    LIKE DISVARIANT-VARIANT.
SELECTION-SCREEN END OF BLOCK B2.
