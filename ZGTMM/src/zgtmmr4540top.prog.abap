*&---------------------------------------------------------------------*
*& Include MZLE0001TOP                                       모듈풀    *
*&                                                                     *
*&---------------------------------------------------------------------*

PROGRAM  SAPMZLE0001 MESSAGE-ID ZLE1.

TABLES:
*  ZLET0005,
*ZLET0006,
ZGTMMT4500, ZGTMMT4501,
*ZLET0017,
CTU_PARAMS.

* DETAIL
DATA: BEGIN OF GT_LIST OCCURS 0,
       CHK,
       MATNR      LIKE MSEG-MATNR,         "자재코드
       MAKTX      LIKE MAKT-MAKTX,         "자재명
       LABST      LIKE MSEG-MENGE,         "가용재고

*{기능개선 307461 - S
*       menge_av      LIKE MSEG-MENGE,         "사용가능수량
       MENGE_ST      LIKE MSEG-MENGE,         "창고재고
       MENGE_RE      LIKE MSEG-MENGE,         "예약수량
*} 기능개선 307461 - e

       LFIMG      LIKE MSEG-MENGE,         "수량
       MTR_UNIT   LIKE MSEG-MEINS,         "단위
       DMBTR      LIKE MSEG-DMBTR,         "금액
*       dmbtr(13)  TYPE p,                 "금액
       WAERS      LIKE MSEG-WAERS,
       LGORT      LIKE MARD-LGORT,
       CHARG      LIKE MCHB-CHARG,         "기능개선 228147 - 추가
       RETURN_DUE_DATE LIKE SY-DATUM,      "반입예정일
       REASN      LIKE ZGTMMT4501-REASN,     "사유, 기능개선 251794 - 추가
      END OF GT_LIST.
* HEADER
DATA: BEGIN OF WA,
       IV_NO       LIKE ZGTMMT4500-IV_NO,    "통문번호
       CREATE_DATE LIKE SY-DATUM,          "요청일자
*-{기능개선 44943 -추가
       BUKRS       LIKE  T001-BUKRS,      "회사코드
       BUTXT       LIKE  T001-BUTXT,      "회사명
*-}기능개선 44943_2014.09.30
       WERKS       LIKE MSEG-WERKS,        "플랜트
       WERKS_T     LIKE T001W-NAME1,       "플랜트명
       UMWRK       LIKE MSEG-UMWRK,
       UMWRK_T     LIKE T001W-NAME1,
       IV_TYPE     LIKE ZGTMMT4500-IV_TYPE,  "통문유형
       IV_TYPE_NM  LIKE ZGTMMT4511-IV_TYPE_NM,
       KUNNR       LIKE ZGTMMT4500-KUNNR,    "거래처
       KUNNR_T     LIKE KNA1-NAME1,        "거래처명
       KUNNR1      LIKE ZGTMMT4500-KUNNR1,   "거래처
       KUNNR1_T    LIKE KNA1-NAME1,        "거래처명
       KUNNR2      LIKE ZGTMMT4500-KUNNR2,   "납품처(수기입력)
       ORT01       LIKE KNA1-ORT01,
       STRAS       LIKE KNA1-STRAS,
       ADDRS(70),            "주소(KNA1-ORT01+KNA1-STRAS)
       PERNR       LIKE ZGTMMT4500-PERNR,    "사원
       ENAME       LIKE ZZPA0001-ENAME,      "사원명
       ORGTX       LIKE ZGTMMT4500-ORGTX,    "부서
       ORGEH       LIKE ZZPA0001-ORGEH,
*       stext      LIKE zlet0005-stext,   "부서
       ETC_NM      LIKE ZGTMMT4500-ETC_NM,   "특기사항
*-{기능개선 48112 - 삭제
*       TRUCK_NO    LIKE ZLET0005-TRUCK_NO, "차량번호
*       DRIVER_NM   LIKE ZLET0005-DRIVER_NM,"운전자명
*       DRIVER_TELNO LIKE ZLET0005-DRIVER_TELNO,
*-}기능개선 48112_2014.10.15
       RETURN_YN,
       P_CHK,
       BZAREA      LIKE ZLET0033-BZAREA,   "사업장
       BZAREA_T    LIKE ZLET0033-BZAREA_T, "사업장명
       VBELN       LIKE VBAP-VBELN,        "판매오더번호
       POSNR       LIKE VBAP-POSNR,        "품목
       AUFNR       LIKE MSEG-AUFNR,        "SM오더번호
       APPLINE(34) TYPE C,
       CHANGE(1)   TYPE C,                 "수기입력
       REQNO        LIKE ZGTMMT4500-REQNO,        "배차요청번호
       DRIVER_NM    LIKE ZGTMMT4500-DRIVER_NM,    "운전자명
       DRIVER_TELNO LIKE ZGTMMT4500-DRIVER_TELNO, "운전자전화번호
       TRUCK_NO     LIKE ZGTMMT4500-TRUCK_NO,     "차량번호
       RSNUM        LIKE RESB-RSNUM, "예약번호
      END OF WA.

DATA: BEGIN OF WA_0110,
        APP_ID1 LIKE ZLET0003-APP_ID1,
        APP_NM1 LIKE ZLET0003-APP_NM1,
        APP_ID2 LIKE ZLET0003-APP_ID2,
        APP_NM2 LIKE ZLET0003-APP_NM2,
      END   OF WA_0110.

DATA: GV_CHAN.
DATA: TS_FLAG1.
*/ POV
DATA : BEGIN OF FIELDTAB OCCURS 2.
        INCLUDE STRUCTURE HELP_VALUE.
DATA : END OF FIELDTAB.

DATA : BEGIN OF I_HELP_VTAB OCCURS 0.
        INCLUDE STRUCTURE  HELP_VTAB.
DATA : END OF I_HELP_VTAB.
DATA : BEGIN OF  VALUETAB OCCURS 0,
         VALUE LIKE HELP_VTAB-VALUE,
        END OF  VALUETAB.
DATA: J TYPE I.
*
DATA: G_CURSOR_FIELD(20), I_CURSOR_LINE TYPE I.
DATA: OK_CODE       LIKE  SY-UCOMM.
DATA: TM_TRUNO  LIKE ZLET0017-TRNUM.
DATA: GV_FLAG.
DATA: LV_IV_NO  LIKE ZLET0005-IV_NO.
*/ CONTROLS
CONTROLS: TC01    TYPE TABLEVIEW USING SCREEN 0100.

DATA: WA_COLS     LIKE LINE OF TC01-COLS.

DATA : BEGIN OF GT_MARD OCCURS 0.
        INCLUDE STRUCTURE MARD.
DATA : END OF GT_MARD.

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

*-}기능개선 44943_2014.09.30

*-{기능개선 48112 - 추가
DATA: GV_IV_TYPE    LIKE ZLET0007-IV_TYPE,
      GV_IV_TYPE_NM LIKE ZLET0007-IV_TYPE_NM,
      GV_ADDRS      TYPE C.
*-}기능개선 48112_2014.10.15

DATA: GV_LGORT_FLAG.
*-{기능개선 48116 - 추가
DATA: GV_BUKRS LIKE MATDOC-BUKRS,
      GV_APNUM LIKE ZLET0007-APNUM,
      GV_CHECK TYPE C.
*-}기능개선 48116_2014.10.21

*{ 기능개선 228147 - 추가
DATA: BEGIN OF GS_IO,
        GIJUN       VALUE 'X',
        GIENG,
        GIDAE,
        GRJUN,
        GRENG,
        GRDAE       VALUE 'X',
        GREXT,     " SRM2112-01975
      END   OF GS_IO.

DATA : GV_GREXT(8). "SRM2112-01975

DATA: GV_MAKTX(50).
*} 기능개선 228147 - 추가
data : gv_simple_approval.
DATA : GV_ORD_NUM TYPE ZLET0105-ORD_NUM.

*{ 기능개선 307461 - S
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
*{ 기능개선 307461 - E
