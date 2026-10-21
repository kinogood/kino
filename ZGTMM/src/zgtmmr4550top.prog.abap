*&---------------------------------------------------------------------*
*&  Include           MZLE0002TOP                                      *
*&---------------------------------------------------------------------*

PROGRAM  SAPMZLE0002 MESSAGE-ID ZLE1.

TABLES:
*   ZLET0005,         "[LE] 통문 헤더
*        ZLET0006,         "[LE] 통문 Line Item
        ZLET0007,         "[LE] 통문유형 코드
        ZLET0017,         " [LE] 차량마스터 정보
        ZGTMMT4500, "통문 헤더
        ZGTMMT4501, "통문 Line Item
        V_ANLSUM_1.       "ANLA, ANLZ, ANLB 와 ANLC 의 뷰
*
DATA: BEGIN OF WA,
*        DATE       LIKE  SY-DATUM,         "발급일자
        CREATE_DATE LIKE SY-DATUM,
        IV_NO       LIKE  ZLET0005-IV_NO,       "통문번호
        IV_TYPE     LIKE  ZLET0005-IV_TYPE,     "통문유형
*-{기능개선 44943 -추가
        BUKRS       LIKE  T001-BUKRS,           "회사코드
        BUTXT       LIKE  T001-BUTXT,           "회사명
*-}기능개선 44943_2014.09.29
        WERKS       LIKE  LIPS-WERKS,
        WERKS_T     LIKE  T001W-NAME1,
        IV_TYPE_NM  LIKE  ZLET0007-IV_TYPE_NM,  "통문유형명
        PERNR       LIKE  ZLET0005-PERNR,       "사원번호
        ENAME       LIKE  ZZPA0001-ENAME,         "사원명
        ORGTX       LIKE  ZLET0005-ORGTX,       "부서
        ORGEH       LIKE  ZZPA0001-ORGEH,         "조직단위
*-{기능개선 48112 - 삭제
*        DRIVER_NM   LIKE  ZLET0005-DRIVER_NM,   "운전자이름
*        TRUCK_NO    LIKE  ZLET0005-TRUCK_NO,    "차량번호
*        DRPHO       LIKE  ZLET0005-DRIVER_TELNO,"운전자전화번호
*-}기능개선 48112_2014.10.15
        KUNNR       LIKE  LIKP-KUNNR,           "구매처코드
        KUNNR_T     LIKE  KNA1-NAME1,           "거래처명
        KUNNR1      LIKE ZLET0005-KUNNR1,       "납품처
        KUNNR1_T    LIKE KNA1-NAME1,            "납품처명
        KUNNR2      LIKE ZLET0005-KUNNR2,       "납품처(수기입력)
        ORT01       LIKE  KNA1-ORT01,           "거래처도시
        STRAS       LIKE  KNA1-STRAS,           "거래처 호수 및 주소
        ADDRS       LIKE ZLET0005-ADDRS,        "주소(KNA1-ORT01+KNA1-STRAS)
        RETURN_YN,   " 반입예정(체크박스) 추가. 2017.03.29 MJLEE
        TEXT1(50),
        BZAREA      LIKE ZLET0033-BZAREA,       "사업장
        BZAREA_T    LIKE ZLET0033-BZAREA_T,     "사업장명
        APPLINE(34) TYPE C,
        CHANGE(1)   TYPE C,                     "납품처 변경 기능개선181725
*/ EDIT FROM BY G.T.JUNG AT 2016.11.16
         ZPDF       LIKE ZLET0005-ZPDF,         " 파일첨부
*/ EDIT END
        REQNO        LIKE ZLET0005-REQNO,        "배차요청번호
        DRIVER_NM    LIKE ZLET0005-DRIVER_NM,    "운전자명
        DRIVER_TELNO LIKE ZLET0005-DRIVER_TELNO, "운전자전화번호
        TRUCK_NO     LIKE ZLET0005-TRUCK_NO,     "차량번호
      END OF WA.
*
DATA: BEGIN OF WA_0110,
        APP_ID1 LIKE ZLET0003-APP_ID1,
        APP_NM1 LIKE ZLET0003-APP_NM1,
        APP_ID2 LIKE ZLET0003-APP_ID2,
        APP_NM2 LIKE ZLET0003-APP_NM2,
      END   OF WA_0110.
*
DATA: BEGIN OF GT_OUT OCCURS 0,
        CHK(3),                               "Check box
        ASSET_NO   LIKE  ZLET0006-ASSET_NO,   "자산번호
        ASSET_NM   LIKE  ZLET0006-ASSET_NM,   "자산명칭
*/ edit start by 정규태 at 2016.11.16
        GDLGRP       LIKE   ANLA-GDLGRP,      " 대여 업체
        GDLGRP_TXT LIKE T087S-GDLGRP_TXT,   " 평가그룹 8곳에 대한 텍스트
*/ edit end
        ASSET_SPEC LIKE  ZLET0006-ASSET_SPEC, "규격/용도
        MENGE      LIKE  V_ANLSUM_1-MENGE,    "수량
        DMBTR      LIKE  V_ANLSUM_1-KANSW,    "장부가액
        ASSET_AMT  LIKE  ZLET0006-ASSET_AMT,  "장부가액
        ASSET_CUR  LIKE  ZLET0006-WAERS,      " 기능개선_48112
        ASSET_ETC  LIKE  ZLET0006-ASSET_ETC,  "기타
        MEINS      LIKE  MARA-MEINS,          "단위
        WERKS      LIKE  ZLET0005-WERKS,      "Plant
        FLAG(1),                              "Flag
        RETURN_DUE_DATE LIKE SY-DATUM,     "반입예정일 2017.03.29. MJLEE
        REASN      LIKE ZLET0006-REASN,    "사유, 기능개선 251794 - 추가
      END OF GT_OUT.
*
DATA : BEGIN OF FIELDTAB OCCURS 2.
        INCLUDE STRUCTURE HELP_VALUE.
DATA : END OF FIELDTAB.
*
DATA : BEGIN OF I_HELP_VTAB OCCURS 0.
        INCLUDE STRUCTURE  HELP_VTAB.
DATA : END OF I_HELP_VTAB.
*
DATA : BEGIN OF  VALUETAB OCCURS 0,
         VALUE LIKE HELP_VTAB-VALUE,
        END OF  VALUETAB.
DATA: J TYPE I,
      LV_FLAG.
*
DATA: G_CURSOR_FIELD(20), I_CURSOR_LINE TYPE I.
DATA: GT_OUT_T LIKE GT_OUT OCCURS 0 WITH HEADER LINE.
DATA: TS_FLAG1.
DATA: TM_TRUNO  LIKE ZLET0017-TRNUM.
DATA: GV_FLAG.
DATA: GV_LGORT_FLAG.
* screen 100
CONTROLS: TC01    TYPE TABLEVIEW USING SCREEN 0100.
DATA: DELE.


*-{기능개선 44943 -추가

*___F4 Help용
DATA: SELECTFIELD   LIKE  HELP_INFO-FIELDNAME,
      IT_FIELDS     LIKE  HELP_VALUE OCCURS 1 WITH HEADER LINE,
      SELECT_VALUE  LIKE  HELP_INFO-FLDVALUE,
      LD_TABIX      LIKE  SY-TABIX,
      LV_INDEX      LIKE  SY-INDEX.

DATA: SCR_FIELDS LIKE DYNPREAD OCCURS 0 WITH HEADER LINE,
      FELD_TABLE LIKE DYNPREAD OCCURS 0 WITH HEADER LINE.

DATA : BEGIN OF GT_CODE OCCURS 0,
         BUKRS   LIKE T001-BUKRS,
         BUTXT   LIKE T001-BUTXT,
       END OF GT_CODE.

DATA : BEGIN OF GT_PLANT OCCURS 0,
         WERKS   LIKE T001W-WERKS,
         NAME1   LIKE T001W-NAME1,
       END OF GT_PLANT.

DATA : GT_BWKEY LIKE T001K OCCURS 0 WITH HEADER LINE.

*-}기능개선 44943_2014.09.29

*-{기능개선 48112 - 추가
DATA: GV_IV_TYPE    LIKE ZLET0007-IV_TYPE,
      GV_IV_TYPE_NM LIKE ZLET0007-IV_TYPE_NM,
      GV_ADDRS      TYPE C.
*-}기능개선 48112_2014.10.15
data : gv_simple_approval.

*-{기능개선 48116 - 추가
DATA: GV_BUKRS LIKE MATDOC-BUKRS,
      GV_APNUM LIKE ZLET0007-APNUM,
      GV_CHECK TYPE C.
*-}기능개선 48116_2014.10.21

DATA: GV_TEXT1(8) TYPE C.
*/ EDIT FROM BY G.T.JUNG AT 2016.11.16
DATA : COL_DATA LIKE LINE OF TC01-COLS .
*/ EDIT FROM BY G.T.JUNG AT 2016.11.16
DATA: GT_FULLFNAME1 TYPE TABLE OF FILE_TABLE WITH HEADER LINE.
*/ EDIT END  2016.11.16
