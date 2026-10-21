*&---------------------------------------------------------------------*
*&  Include           ZPPR1000TOP                                      *
*&---------------------------------------------------------------------*


INCLUDE <ICON>.

** alv class
INCLUDE ZGTPPR9020C01.

*----------------------------------------------------------------------*
*  TABLE
*----------------------------------------------------------------------*
TABLES : MSEG,            "자재문서테이블
         T001W,           "플랜트/분기 내용 테이블
         MARA,            "일반자재테이블
         MARC,            "자재에 대한 플랜트데이타
         LFA1,            "구매처마스터
         MAKT,            "자재내역
         MBEW,            "자재평가
         MATDOC,           "MKPF+MSEG
         CKMLHD,          "자재원장
         CKMLPP,          "자재원장 기간 총레코드 수량
         CKMLCR,          "자재원장: 기간 총레코드 값
         ZPPT0000,        "PP 공용 테이블
         SSCRFIELDS,      "선택화면의 필드
         ZPPT0149J,       "시점 재고 정보
         ZPPT0149.        "재고관리 모니터링  장기/과잉 재고 정보

*----------------------------------------------------------------------*
*  TYPE
*----------------------------------------------------------------------*
*----------------------------------------------------------------------*
*  VARIABLE
*----------------------------------------------------------------------*
* 체류일
DATA : GV_STOP      TYPE I,
       OK_CODE      TYPE SY-UCOMM,
       GV_DATE      LIKE SY-DATUM,
       GV_SEQ       TYPE I,
       GV_COMMENT   TYPE C,
       GV_E_CHECK   TYPE I,
       GV_NO_DATA   TYPE C,
       GV_AUTHORITY TYPE C,
       GV_TAB_CNT   TYPE I,
       GV_MDATE     LIKE SY-DATUM,
       GV_ADATE     LIKE SY-DATUM,    "아카이빙 날짜
       GV_WERKS     LIKE MARC-WERKS.

DATA : BEGIN OF TEMP0_UP OCCURS 0.
         INCLUDE STRUCTURE ZPPT0149J.
DATA : END OF TEMP0_UP.

DATA : BEGIN OF TEMP0 OCCURS 0.
         INCLUDE STRUCTURE ZPPT0149.
DATA :   ZEILE      LIKE MSEG-ZEILE,      "자재문서 품목번호
         LABS       LIKE MARD-LABST,      "가용재고
         INSM       LIKE MARD-INSME,      "품질검사재고
         SPEM       LIKE MARD-SPEME,      "보류재고
         EINM       LIKE MARD-EINME,      "제한재고
         DPCBT      LIKE MARA-DPCBT,      "배치유형
         XCHPF      LIKE MARC-XCHPF,      "뱃치관리 소요량 지시자
         SOBKZ      LIKE MSKA-SOBKZ,      "특별재고지시자
         SHKZG      LIKE MATDOC-SHKZG,     "차변/대변 지시자
         SUM        TYPE MARD-INSME,
         "재고수량 (가용 + 품질 + 보류 + 제한)
         RATE       TYPE F,               "점유율
         FLAG_E     TYPE C,               "에러 플래그
         MENGE_LAST TYPE ZPPT0149-MENGE,  "체류수량 계산용
         GUBUN      TYPE C,               "구분 플래그
         CPUDT      LIKE MATDOC-CPUDT,     "회계전표 입력일
         CPUTM      LIKE MATDOC-CPUTM,     "회계전표 입력시간
         EBELN      LIKE MATDOC-EBELN,     "구매오더
         UMWRK      LIKE MATDOC-UMWRK,     "공급플랜트
         DISPO      LIKE MARC-DISPO,      "MRP관리자   기능개선_205476
       END OF TEMP0.

DATA : TEMP1        LIKE TEMP0 OCCURS 0 WITH HEADER LINE. "mard 처리용
DATA : TEMP2        LIKE TEMP0 OCCURS 0 WITH HEADER LINE. "mchb 처리용
DATA : TEMP3        LIKE TEMP0 OCCURS 0 WITH HEADER LINE. "mska 처리용
DATA : TEMP4        LIKE TEMP0 OCCURS 0 WITH HEADER LINE. "mslb 처리용

DATA : TEMP_0149    LIKE TEMP0 OCCURS 0 WITH HEADER LINE. "zppt0149 조회
DATA : TEMP_0149_UP LIKE TEMP0 OCCURS 0 WITH HEADER LINE.
"zppt0149 조회2
DATA : TEMP_MATDOC   LIKE TEMP0 OCCURS 0 WITH HEADER LINE. "matdoc 조회
DATA : TEMP_MATDOC1  LIKE TEMP0 OCCURS 0 WITH HEADER LINE. "matdoc 조회


DATA : TEMP_Z       LIKE TEMP0 OCCURS 0 WITH HEADER LINE.
"연산/TABLE 인서트용
DATA : TEMP_Z_UP    LIKE TEMP0 OCCURS 0 WITH HEADER LINE.
"TABLE 인서트용2
DATA : TEMP_COLLECT LIKE TEMP0 OCCURS 0 WITH HEADER LINE. "collect 용
DATA : TEMP_ACT     LIKE TEMP0 OCCURS 0 WITH HEADER LINE. "실제연산용
DATA : TEMP_CNT     LIKE TEMP0 OCCURS 0 WITH HEADER LINE.
"플랜트/저장위치확인용

DATA : TEMP11       LIKE TEMP0_UP OCCURS 0 WITH HEADER LINE. "mard 조회
DATA : TEMP22       LIKE TEMP0_UP OCCURS 0 WITH HEADER LINE. "mchb 조회
DATA : TEMP33       LIKE TEMP0_UP OCCURS 0 WITH HEADER LINE. "mska 조회
DATA : TEMP44       LIKE TEMP0_UP OCCURS 0 WITH HEADER LINE. "mslb 조회
DATA : TEMP55       LIKE TEMP0_UP OCCURS 0 WITH HEADER LINE. "SUMMARY
DATA : TEMP_0149J   LIKE TEMP0_UP OCCURS 0 WITH HEADER LINE.
"temp_0149j 조회
DATA : TEMP_COPY    LIKE TEMP0_UP OCCURS 0 WITH HEADER LINE.
"temp_0149j 조회

DATA : BEGIN OF GT_TAB OCCURS 0.                          "ALV용
*INCLUDE STRUCTURE temp0.      "화면상의 sum 값을 표현하기위하여
*나열하여표기.
DATA : MANDT       LIKE    ZPPT0149-MANDT,
       WERKS       LIKE    ZPPT0149-WERKS,
       MATNR       LIKE    ZPPT0149-MATNR,
       LGORT       LIKE    ZPPT0149-LGORT,
       BRANCHG     LIKE    ZPPT0149-BRANCHG,
       STOCKT      LIKE    ZPPT0149-STOCKT,
       STTEXT      LIKE    ZPPT0149-STTEXT,
       SEQUENCE	   LIKE    ZPPT0149-SEQUENCE,
       MDATE       LIKE    ZPPT0149-MDATE,
       CHARG       LIKE    ZPPT0149-CHARG,
       MBLNR       LIKE    ZPPT0149-MBLNR,
       MENGE       LIKE    ZPPT0149-MENGE,
       BUDAT       LIKE    ZPPT0149-BUDAT,
       MTART       LIKE    ZPPT0149-MTART,
       PRCTR       LIKE    ZPPT0149-PRCTR,
       NAME1       LIKE    ZPPT0149-NAME1,
       MAKTX       LIKE    ZPPT0149-MAKTX,
       STOCKM      LIKE    ZPPT0149-STOCKM,
       STOCKMBE	   LIKE    ZPPT0149-STOCKMBE,
       STOPM       LIKE    ZPPT0149-STOPM,
       STOPDATE	   LIKE    ZPPT0149-STOPDATE,
       MEINS       LIKE    ZPPT0149-MEINS,
       STOCKMC     LIKE    ZPPT0149-STOCKM,
       STOPMC      LIKE    ZPPT0149-STOPM,
       MEINSC      LIKE    ZPPT0149-MEINS,
       STPRS       LIKE    ZPPT0149-STPRS,
       MONEY(16)   TYPE    P DECIMALS 3,
       STPRSAF     LIKE    ZPPT0149-STPRSAF,
       MONEYAF(16) TYPE    P DECIMALS 3,
       BWART       LIKE    ZPPT0149-BWART,
       MSHARE      LIKE    ZPPT0149-MSHARE,
       BKLAS       LIKE    ZPPT0149-BKLAS,
       BKBEZ       LIKE    ZPPT0149-BKBEZ,
       DISPO       LIKE    MARC-DISPO,
       CF_CU       TYPE    P DECIMALS 3,     "동 환산계수
       C_CU        TYPE    P DECIMALS 3,     "동 환산중량
       CF_AL       TYPE    P DECIMALS 3,     "AL 환산계수
       C_AL        TYPE    P DECIMALS 3,     "AL 환산중량
*-{기능개선_205476_추가
       MATNR_S     LIKE    ZPPT0149-MATNR_S,   "생산 스크랩 코드
       BRGEW       LIKE    ZPPT0149-BRGEW,     "환산계수(KG)
       STOCKMSC    LIKE    ZPPT0149-STOCKMSC,  "스크랩 환산 중량(KG)
       STPRS_SC    LIKE    ZPPT0149-STPRS_SC,  "스크랩 단가
*-}기능개선_205476_2017.09.05
*DATA :    ZZCOLOR_BASE    LIKE MARA-ZZCOLOR_BASE,"색상 BASE
*          ZZIDEN_CODE     LIKE MARA-ZZIDEN_CODE, "절연선심식별
*          ZZMAKTX80       LIKE MARA-ZZMAKTX80,   "전체품명
*          OUTDIA          TYPE ATWRT,            "공정외경
*          TB_PRINT_APP    TYPE ATWRT,            "튜브인쇄사양
*          TB_BOBIN        TYPE ATWRT,            "보빈인쇄사양
*          TB_BOX_MARKING  TYPE ATWRT,            "박스인쇄사양
*          T_SCOL          TYPE LVC_T_SCOL,
*          T_STYL          TYPE LVC_T_STYL,       "Cell단위 수정 스타일
*          W_NAME          TYPE T001W-NAME1,
*20250613
       MAT_KDAUF   LIKE MATDOC-MAT_KDAUF,   "판매오더번호
       MAT_KDPOS   LIKE MATDOC-MAT_KDPOS,   "판매오더품목
*20250613

       END OF GT_TAB.
*----------------------------------------------------------------------*
* CONSTANT
*----------------------------------------------------------------------*
* 재고유형
CONSTANTS : C_STOCKT_SB  VALUE '1',       "사내 배치
            C_STOCKT_SNB VALUE '2',       "사내 NON 배치
            C_STOCKT_OB  VALUE '3',       "외주 배치
            C_STOCKT_ONB VALUE '4',       "외주 NON 배치
            C_STTEXT_SB  TYPE CHAR40 VALUE '사내재고-배치',
            "사내 배치
            C_STTEXT_SNB TYPE CHAR40 VALUE '사내재고-Non 배치',
            "사내 NON 배치
            C_STTEXT_OB  TYPE CHAR40 VALUE '외주재고-배치',
            "외주 배치
            C_STTEXT_ONB TYPE CHAR40 VALUE '외주재고-Non 배치',
            "외주 NON 배치
* 분류유형
            C_BRANCHG_A  VALUE 'A',       "분류그룹 a 31~90일
            C_BRANCHG_B  VALUE 'B',       "분류그룹 b 91~180일
            C_BRANCHG_C  VALUE 'C',       "분류그룹 c 181~365일
            C_BRANCHG_D  VALUE 'D',       "분류그룹 d 365일이상
            C_BRANCHG_Z  VALUE 'Z',       "분류그룹 z 오류
            C_BRANCHG_N  VALUE 'N'.       "분류그룹 n 1~30일
*&---------------------------------------------------------------------*
* SELECTION SCREEN ( SELECT-OPTIONS & PARAMETERS )
*&---------------------------------------------------------------------*

SELECTION-SCREEN BEGIN OF BLOCK BL4 WITH FRAME TITLE TEXT-170.
  SELECTION-SCREEN BEGIN OF LINE.
    SELECTION-SCREEN POSITION  1.
    SELECTION-SCREEN PUSHBUTTON 2(12) BUTTON1 USER-COMMAND PC.
    "PC별 투하자산
    SELECTION-SCREEN POSITION  15.
    SELECTION-SCREEN PUSHBUTTON 16(12) BUTTON2 USER-COMMAND MCBA.
    "월간 시점 재고
    SELECTION-SCREEN POSITION  29.
    SELECTION-SCREEN PUSHBUTTON 30(12) BUTTON3 USER-COMMAND SD1.
    "적송 재고
    SELECTION-SCREEN POSITION  43.
    SELECTION-SCREEN PUSHBUTTON 44(12) BUTTON4 USER-COMMAND MM1.
    "미착원재료
  SELECTION-SCREEN END   OF LINE.
SELECTION-SCREEN END OF BLOCK BL4.


SELECTION-SCREEN BEGIN OF BLOCK BL1 WITH FRAME TITLE TEXT-001.

  SELECTION-SCREEN BEGIN OF LINE.

    SELECTION-SCREEN POSITION  1.
    PARAMETERS    : R_MAKE   RADIOBUTTON GROUP RG1 .      "시점재고복사
    SELECTION-SCREEN COMMENT 3(15)   TEXT-150 FOR FIELD R_MAKE.
    SELECTION-SCREEN POSITION  20.
    PARAMETERS    : R_UP     RADIOBUTTON GROUP RG1 .      "장기재고추출
    SELECTION-SCREEN COMMENT 22(15)  TEXT-160 FOR FIELD R_UP.

  SELECTION-SCREEN END   OF LINE.

  SELECTION-SCREEN BEGIN OF LINE.
    SELECTION-SCREEN COMMENT 1(30)  TEXT-010 FOR FIELD P_DATE.
    SELECTION-SCREEN POSITION  36.
    PARAMETERS    : P_DATE   LIKE  SY-DATUM.          "날짜
  SELECTION-SCREEN END   OF LINE.

  SELECTION-SCREEN BEGIN OF LINE.
    SELECTION-SCREEN COMMENT 1(30)  TEXT-020 FOR FIELD S_PWERK.
    SELECTION-SCREEN POSITION  33.
    SELECT-OPTIONS: S_PWERK   FOR   MSEG-WERKS         "플랜트
                                    NO INTERVALS
                                    OBLIGATORY
                                    VISIBLE LENGTH 18.
    SELECTION-SCREEN POSITION  60.
    PARAMETERS    : T_NAME1(40)  TYPE  C MODIF ID ABC.
  SELECTION-SCREEN END   OF LINE.

  SELECTION-SCREEN BEGIN OF LINE.
    SELECTION-SCREEN COMMENT 1(30)  TEXT-080 FOR FIELD S_MATNR.
    SELECTION-SCREEN POSITION  33.
    SELECT-OPTIONS: S_MATNR   FOR   MSEG-MATNR         "자재코드
                                    NO INTERVALS
                                    VISIBLE LENGTH 18.
    SELECTION-SCREEN POSITION  60.
    PARAMETERS    : T_MAKTX   LIKE  MAKT-MAKTX MODIF ID ABC.
  SELECTION-SCREEN END   OF LINE.

**분류그룹
  SELECTION-SCREEN BEGIN OF BLOCK BL3 WITH FRAME TITLE TEXT-090.

    SELECTION-SCREEN BEGIN OF LINE.
      SELECTION-SCREEN POSITION  5.
      PARAMETERS    : C_BRAN_A     AS    CHECKBOX DEFAULT 'X'.
      SELECTION-SCREEN COMMENT 6(15)   TEXT-100 FOR FIELD C_BRAN_A.
      SELECTION-SCREEN POSITION  22.
      PARAMETERS    : C_BRAN_B     AS    CHECKBOX DEFAULT 'X'.
      SELECTION-SCREEN COMMENT 23(15)  TEXT-110 FOR FIELD C_BRAN_B.
      SELECTION-SCREEN POSITION  39.
      PARAMETERS    : C_BRAN_C    AS    CHECKBOX DEFAULT 'X'.
      SELECTION-SCREEN COMMENT 40(18)   TEXT-120 FOR FIELD C_BRAN_C.
    SELECTION-SCREEN END   OF LINE.

    SELECTION-SCREEN BEGIN OF LINE.
      SELECTION-SCREEN POSITION  5.
      PARAMETERS    : C_BRAN_D    AS    CHECKBOX DEFAULT 'X'.
      SELECTION-SCREEN COMMENT 6(15)  TEXT-130 FOR FIELD C_BRAN_D.
      SELECTION-SCREEN POSITION  22.
      PARAMETERS    : C_BRAN_Z    AS    CHECKBOX DEFAULT 'X'.
      SELECTION-SCREEN COMMENT 23(15)   TEXT-140 FOR FIELD C_BRAN_Z.
      SELECTION-SCREEN POSITION  39.
*PARAMETERS    : C_BRAN_N    AS    CHECKBOX.
*SELECTION-SCREEN COMMENT 40(18)   TEXT-190 FOR FIELD C_BRAN_N.
    SELECTION-SCREEN END   OF LINE.

    SELECT-OPTIONS: S_BRAN FOR ZPPT0149-STOCKT NO INTERVALS
                                               NO-EXTENSION
                                               NO-DISPLAY.
*
**
  SELECTION-SCREEN END   OF BLOCK BL3.

**재고구분
  SELECTION-SCREEN BEGIN OF BLOCK BL2 WITH FRAME TITLE TEXT-030.

    SELECTION-SCREEN BEGIN OF LINE.
      PARAMETERS    : T1     TYPE   C  NO-DISPLAY.
      SELECTION-SCREEN COMMENT 6(10) TEXT-060 FOR FIELD T1.
      SELECTION-SCREEN POSITION  18.
      PARAMETERS    : T2     TYPE   C  NO-DISPLAY.
      SELECTION-SCREEN COMMENT 19(12)  TEXT-070 FOR FIELD T2.
    SELECTION-SCREEN END   OF LINE.
    SELECTION-SCREEN BEGIN OF LINE.
      SELECTION-SCREEN POSITION  5.
      PARAMETERS    : C_BAT_S     AS    CHECKBOX DEFAULT 'X'.
      SELECTION-SCREEN COMMENT 6(10) TEXT-040 FOR FIELD C_BAT_S.
      SELECTION-SCREEN POSITION  18.
      PARAMETERS    : C_BAT_O     AS    CHECKBOX DEFAULT 'X'.
      SELECTION-SCREEN COMMENT 19(10)  TEXT-040 FOR FIELD C_BAT_O.
    SELECTION-SCREEN END   OF LINE.

    SELECTION-SCREEN BEGIN OF LINE.
      SELECTION-SCREEN POSITION  5.
      PARAMETERS    : C_BAT_SN    AS    CHECKBOX DEFAULT 'X'.
      SELECTION-SCREEN COMMENT 6(12) TEXT-050 FOR FIELD C_BAT_SN.
      SELECTION-SCREEN POSITION  18.
      PARAMETERS    : C_BAT_ON    AS    CHECKBOX DEFAULT 'X'.
      SELECTION-SCREEN COMMENT 19(12)  TEXT-050 FOR FIELD C_BAT_ON.
    SELECTION-SCREEN END   OF LINE.
*
    SELECT-OPTIONS: S_BAT FOR ZPPT0149-STOCKT NO INTERVALS
                                                 NO-EXTENSION
                                                 NO-DISPLAY.
*
  SELECTION-SCREEN END   OF BLOCK BL2.

**작업순서 설명
  SELECTION-SCREEN BEGIN OF BLOCK BL5 WITH FRAME TITLE TEXT-180.
    SELECTION-SCREEN COMMENT /6(46)  TEXT-181.
    SELECTION-SCREEN COMMENT /6(20)  TEXT-182.
    SELECTION-SCREEN COMMENT /6(46)  TEXT-183.
    SELECTION-SCREEN COMMENT /6(20)  TEXT-184.
  SELECTION-SCREEN END   OF BLOCK BL5.

SELECTION-SCREEN END   OF BLOCK BL1.
SELECTION-SCREEN FUNCTION KEY 1.    "data 추출
SELECTION-SCREEN FUNCTION KEY 2.    "결산 수량 반영
SELECTION-SCREEN FUNCTION KEY 3.    "결산 금액 반영
SELECTION-SCREEN FUNCTION KEY 5.    "ZPPR1000G I/F  "기능개선_47570_추가
