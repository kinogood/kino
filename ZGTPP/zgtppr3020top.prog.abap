*&------------------------------------------------------------------
*& Include ZGTPPR3020TOP                                            *
*&                                                                    *
*&------------------------------------------------------------------
REPORT  ZPPR0021    MESSAGE-ID  ZPP1
                    NO STANDARD PAGE HEADING.
INCLUDE <ICON>.

CONTROLS  : TC_STOCK    TYPE TABLEVIEW USING SCREEN '0901'.

CONSTANTS:
  CON_TEXTEDIT_MAXLINELENGTH TYPE I VALUE 132,
  CON_TEXTEDIT_CONTAINER(30) TYPE C VALUE 'CC_TEXTEDITOR'.

CONSTANTS: C_COL1 TYPE I VALUE 5,
           C_COL2 TYPE I VALUE 59,
           C_LIN1 TYPE I VALUE 04,
           C_LIN2 TYPE I VALUE 12.

TABLES: ZPPT0001,           "작업실적 테이블(꼬리표)
        ZPPT0020,           "작업지시 테이블
        ZEDT0011,           "공정코드
        ZPPT0102,           "공정
        ZPPT0000,           "PP 공용 테이블
        ZPPTC002,           "APO<=>PP 여장정보
        ZPPT0153,           "JS전선 자재 특기사항
        ZLET0018,           "MTS절단 생산의뢰
        AFKO,               "오더헤더데이타 PP 오더
        AUFK,               "오더 마스터 데이터
        AFPO,               "오더품목
        AFVC,               "오더내 작업
        CRHD,               "작업장 헤더
        VBPA,               "영업문서: 파트너
        KNA1,               "고객마스터의 일반데이타
        T001W,              "플랜트/분기
        T024D,              "MRP 관리자
        RESB,               "예약/종속 소요량
        MARA,               "일반자재데이타
        MAKT,               "자재내역
        TJ02T,              "시스템상태 텍스트
        RC65D,
        D020S,
        M_CRAMN,
*- Start 2025.05.12
        ZGTPPT2010.
*- End 2025.05.12
TABLES: IOHEADER.

DATA  GV_ERRFLG.

DATA  : BEGIN OF GT_AFKO OCCURS 0,
          ZSORT(30)      TYPE C,               "작업수선순위 결정
          GSUZS_S        LIKE AFKO-GSUZS.     "작업시작시간
          INCLUDE STRUCTURE ZPPS003.
DATA  :   STEUS          LIKE AFVC-STEUS,     "제어키
          OBJNR          LIKE AFVC-OBJNR,     "오브젝트번호
          POSNR          LIKE AFPO-POSNR,     "품목번호
          KDPOS          LIKE AFPO-KDPOS,     "판매오더 Item No.
          CUOBJ          LIKE AFPO-CUOBJ,     "내부오브젝트번호
          PSAMG          LIKE AFPO-PSAMG,     "작업여장(품목의스크랩수량)
          PWERK          LIKE AFPO-PWERK,     "플랜트
          MATKL          LIKE MARA-MATKL,     "자재그룹
          PNMNG          LIKE AFPO-PSMNG,     "Net
*- Start 2024.10.22 단위 테스트 요청 사항 반영
          WEMNG          LIKE AFPO-WEMNG,   "납품수량
*- End 2024.10.22
          IGMNG          LIKE AFKO-IGMNG,     "납품수량
          LMNGA          LIKE AFRU-LMNGA,     "확정수량

          AUTYP          LIKE AUFK-AUTYP,     "오더범주
          LTEXT          LIKE AUFK-LTEXT,     "설명있음
          BUTTON         TYPE STRING,         "버튼
          LTEXT_C        TYPE CHAR20,     "비고text  (C20120128_40165)
          PRECD          TYPE CHAR3,      "전공정    (C20120726_54972)

          ZZCOLOR_BASE   LIKE MARA-ZZCOLOR_BASE, "색상 BASE
          CLRTX          LIKE ZEDT0160-CLRTX,   "색상 내역
*-{기능개선_46712 추가
          ZZCOLOR_STRIPE LIKE MARA-ZZCOLOR_STRIPE, "색상 STRIPE
          CLRTX1         LIKE ZEDT0160-CLRTX,   "색상 내역
*-}기능개선_46712_2014.10.07
          ZZIDEN_CODE    LIKE MARA-ZZIDEN_CODE, "절연선심식별
          ZZMAKTX80      LIKE MARA-ZZMAKTX80,   "전체품명
          OUTDIA         TYPE ATWRT,            "공정외경
          TB_PRINT_APP   TYPE ATWRT,            "튜브인쇄사양
          TB_BOBIN       TYPE ATWRT,            "보빈인쇄사양
          TB_BOX_MARKING TYPE ATWRT,            "박스인쇄사양
*-{CHM2009-00353
          FCOLOR         LIKE MARA-ZZCOLOR_BASE, "완제품 색상 BASE
*}-CHM2009-00353
          CHECK(1)       TYPE C,
          STOCK(4),                              "재고상태
          ETC(8),                                "자재코드 특기사항
          QMCNT          TYPE I,                     "품질통지 카운터
          SPCOL          TYPE ATWRT,                 "띠색상
          SPTXT          TYPE ATWRT,                 "띠색상 내역
          COLOR          TYPE ATWRT,                  "색상
          SUL_NO         TYPE ATWRT,                  "설계번호
          SPEC_NO        TYPE ATWRT,                  "스펙명
          WKSNR_T        TYPE ATWRT,                  "작업표준번호
          KTEXT_C        LIKE M_CRAMN-KTEXT,          "설비명
          MTART          TYPE MARA-MTART,             "이전공장-
          PSTAT(4),                              "포장재상태
          PMATNR         LIKE MARA-MATNR,             "포장재코드
          ATWRT          TYPE ATWRT,          "스크린재질 "기능개선_78645
          RMAKTX         TYPE MAKT-MAKTX,             "원자재 품명
          CMENG(5),                       "단위중량 기능개선_103632
*- Start 2024.10.16 필드 추가
          GISTAT(4), "투입 상태
          CFSTAT(4), "실적 상태
          GRSTAT(4), "입고 상태
*- Start 2025.02.19
          WORK_SD        LIKE AFRU-ISDD, "작업시작일
          WORK_ST        LIKE AFRU-ISDZ, "시작시간
          WORK_ED        LIKE AFRU-IEDD, "작업종료일
          WORK_ET        LIKE AFRU-IEDZ, "종료시간
          EXCLUD_GUID    TYPE CHAR10,
*- End 2025.02.19
*- Start 2025.01.07 필드명 변경 및 신규 필드 추가
          CGMENGE        LIKE AFKO-IGMNG, "Start 여장 수량
          BADMENGE       LIKE AFKO-IGMNG, "수리 작업 수량
          ENDMENGE       LIKE AFKO-IGMNG, "End 여장 수량
          YEAPT          LIKE AFRU-ISM01, "예압 시간
          CGT            LIKE AFRU-ISM01, "Start 여장 작업 시간
          BADT           LIKE AFRU-ISM01, "수리 작업 시간
          ENDT           LIKE AFRU-ISM01, "End 여장 작업 시간
          TIMEM          LIKE AFRU-ILE02, "시간 단위
*- End 2025.01.07
          DELAY(4), "지연구분
          DEL_TIME(60), "지연시간
          AUFNR_E, "초과 입고 or 실적 처리 건
          IPGO, "초과 입고 체크
          SILJEOK, "초과 실적 체크
          BUTTON2        TYPE STRING,         "버튼
*- End 2024.10.16
*- Start 2025.03.05
          BUDAT          LIKE MATDOC-BUDAT, "입고일자
*- End 2025.03.05
*- Start 2025.03.25
          ZPER           TYPE P DECIMALS 1, "생산 실적 처리 현황(%)
*- Start 2025.03.25
*- Start 2025.03.14
          CLOSE(4), "오더종료여부
*- End 2025.03.14
*- Start 2025.04.16
          GRPNR          LIKE ZGTCVORDSYVAL-GRPNR,    "조장 구성표
          DMORD          LIKE ZGTCVORDSYVAL-DMORD,    "패깅 오더
          DMLINE         LIKE ZGTCVORDSYVAL-DMLINE,   "패깅 오더 품목
          ZPJNO          LIKE ZGTCVORDSYVAL-ZPJNO,    "PJT 번호
          ZPTXT          LIKE ZGTCVORDSYVAL-ZPTXT,    "PJT 내역
          INLENGTH       LIKE ZGTCVORDSYVAL-INLENGTH, "기본 조장
          INFACTOR       LIKE ZGTCVORDSYVAL-INFACTOR, "기본 조장 수
          QLENGTH        LIKE ZGTCVORDSYVAL-QLENGTH,  "검사 여장
          CLENGTH        LIKE ZGTCVORDSYVAL-CLENGTH,  "연결 여장
          ADLENGTH       LIKE ZGTCVORDSYVAL-ADLENGTH, "추가 여장
          ADTYPE         LIKE ZGTCVORDSYVAL-ADTYPE,   "추가 여장 유형
*- End 2025.04.16
*[U01] 가온전선 추가
          KTEXT          LIKE CRTX-KTEXT, "작업장내역
*[U01] 가온전선 추가
*- Start 2026.08.24
          NES01          LIKE  /NFM/TKGW-NES,
          NES_T01        LIKE  /NFM/TNESTX-NESTX,
          KGW01          LIKE /NFM/TKGW-KGW,
          BME01          LIKE /NFM/TKGW-BME,
          NES02          LIKE  /NFM/TKGW-NES,
          NES_T02        LIKE  /NFM/TNESTX-NESTX,
          KGW02          LIKE /NFM/TKGW-KGW,
          BME02          LIKE /NFM/TKGW-BME,
*- End 2026.08.24
          T_SCOL         TYPE LVC_T_SCOL,
          T_STYL         TYPE LVC_T_STYL,            "Cell단위 수정 스타일

        END   OF GT_AFKO.
DATA : GT_AFKO_S LIKE GT_AFKO OCCURS 0 WITH HEADER LINE.
*- Start 2024.10.16
* 투입 Status 체크용
DATA : BEGIN OF GT_ORDER OCCURS 0,
         AUFNR LIKE AFKO-AUFNR,
       END OF GT_ORDER.

DATA : BEGIN OF GT_RESB2 OCCURS 0.
         INCLUDE STRUCTURE RESB.
DATA : END OF GT_RESB2.
* 실적 Status 체크용
DATA : BEGIN OF GT_AFRU OCCURS 0.
         INCLUDE STRUCTURE AFRU.
DATA : END OF GT_AFRU.
DATA : GT_AFRU_MIN LIKE GT_AFRU OCCURS 0 WITH HEADER LINE,
       GT_AFRU_MAX LIKE GT_AFRU OCCURS 0 WITH HEADER LINE.
* 입고 Status 체크용
DATA : BEGIN OF GT_AFPO OCCURS 0.
         INCLUDE STRUCTURE AFPO.
DATA : END OF GT_AFPO.
* E-MAIL 관련
DATA : GV_SUBJECT  TYPE SO_OBJ_DES,
       GV_ADDRESS  TYPE AD_SMTPADR,
       GTT_MESSAGE TYPE BCSY_TEXT.

DATA G_EMAIL        TYPE REF TO CL_BCS.
DATA G_EMAIL_BODY   TYPE REF TO CL_DOCUMENT_BCS.
DATA G_RECEIVER     TYPE REF TO IF_RECIPIENT_BCS.
DATA G_EXCEPTION    TYPE REF TO CX_BCS.
DATA GV_SEND_RESULT TYPE C.

DATA : BEGIN OF GT_MESSAGE OCCURS 0,                        " 1
         MATNR         LIKE MARA-MATNR,
         BIS_MTRL      LIKE ZEDT7210-BIS_MTRL,
         ZRESULT(2),
         ZMESSAGE(100),
         LEG_RQNO      LIKE ZEDT7210-LEG_RQNO,
         SORT_SEQ      LIKE ZEDT7210-SORT_SEQ,
         STD_NAME      LIKE ZEDT7210-BIS_STD,
       END OF GT_MESSAGE.
* 기타
DATA : GV_CHECK.

DATA : GT_AFKO2 LIKE GT_AFKO OCCURS 0 WITH HEADER LINE,
       GT_AFKO3 LIKE GT_AFKO OCCURS 0 WITH HEADER LINE,
*- Start 2025.03.25
       GT_AFKO4 LIKE GT_AFKO OCCURS 0 WITH HEADER LINE.
*- End 2025.03.25
*- End 2024.10.16
*- Start 2025.05.14
DATA : BEGIN OF GT_AFKO5 OCCURS 0.
         INCLUDE STRUCTURE GT_AFKO.
DATA : REASON(30),
       END OF GT_AFKO5.
*- End 2025.05.14
*- Start 2025.04.16
DATA : BEGIN OF GS_PROD_CHAR,
         WERKS    LIKE ZGTCVORDSYVAL-WERKS,
         AUFNR    LIKE ZGTCVORDSYVAL-AUFNR,
         POSNR    LIKE ZGTCVORDSYVAL-POSNR,
         GRPNR    LIKE ZGTCVORDSYVAL-GRPNR,    "조장 구성표
         DMORD    LIKE ZGTCVORDSYVAL-DMORD,    "패깅 오더
         DMLINE   LIKE ZGTCVORDSYVAL-DMLINE,   "패깅 오더 품목
         ZPJNO    LIKE ZGTCVORDSYVAL-ZPJNO,    "PJT 번호
         ZPTXT    LIKE ZGTCVORDSYVAL-ZPTXT,    "PJT 내역
         INLENGTH LIKE ZGTCVORDSYVAL-INLENGTH, "기본 조장
         INFACTOR LIKE ZGTCVORDSYVAL-INFACTOR, "기본 조장 수
         QLENGTH  LIKE ZGTCVORDSYVAL-QLENGTH,  "검사 여장
         CLENGTH  LIKE ZGTCVORDSYVAL-CLENGTH,  "연결 여장
         ADLENGTH LIKE ZGTCVORDSYVAL-ADLENGTH, "추가 여장
         ADTYPE   LIKE ZGTCVORDSYVAL-ADTYPE,   "추가 여장 유형
       END OF GS_PROD_CHAR.
DATA : GT_PROD_CHAR LIKE TABLE OF GS_PROD_CHAR.
*- End 2025.04.16
DATA : BEGIN OF GT_AUFNR OCCURS 0,
         AUFNR TYPE    AFKO-AUFNR,
         VORNR TYPE    AFVC-VORNR,
       END OF GT_AUFNR.

DATA  : BEGIN OF GT_PRINT OCCURS 0,
          AUFNR     LIKE AFKO-AUFNR,           "생산오더 번호
          FOSTNR    LIKE ZPPT0020-FOSTNR,      "조장구성표번호
          PROCD     LIKE ZEDT0011-GONG_CD,     "공정
          DISPO     LIKE AFKO-DISPO,           "MRP관리자
          PLNNR     LIKE AFKO-PLNNR,           "공정
          APRIO     LIKE AFKO-APRIO,           "생산오더 유형
          VORNR     LIKE AFVC-VORNR,           "소공정번호
          STEUS     LIKE AFVC-STEUS,           "제어키
          OBJNR     LIKE AFVC-OBJNR,         "오브젝트번호
          ARBPL     LIKE CRHD-ARBPL,           "설비(작업장)
          KTEXT     LIKE M_CRAMN-KTEXT,        "설비명
          FTRMI     LIKE AFKO-FTRMI,           "작업지시일
          GSTRS     LIKE AFKO-GSTRS,           "작업시작일
          GSUZS     LIKE AFKO-GSUZS,           "작업시작시간
          GLTRS     LIKE AFKO-GLTRS,           "작업종료일
          GLUZS     LIKE AFKO-GLUZS,           "작업종료시간
          POSNR     LIKE AFPO-POSNR,           "품목번호
          KDAUF     LIKE AFPO-KDAUF,           "판매오더 번호
          KDPOS     LIKE AFPO-KDPOS,           "판매오더 Item No.
          KUNNR     LIKE VBPA-KUNNR,           "납선
          NAME1     LIKE KNA1-NAME1,           "납선명
          MATNR     LIKE AFPO-MATNR,           "자재코드
          MTART     LIKE MARA-MTART,           "자재유형
          MATKL     LIKE MARA-MATKL,           "자재그룹
          MAKTX     LIKE MAKT-MAKTX,           "품명 및 규격
          COLOR     TYPE ATWRT,                "색상
          SUL_NO    TYPE ATWRT,                "설계번호
          SPEC_NO   TYPE ATWRT,                "스펙명
          WKSNR_T   TYPE ATWRT,                "작업표준번호
          PSMNG     LIKE AFPO-PSMNG,           "총수량
          PSAMG     LIKE AFPO-PSAMG,         "작업여장(품목의스크랩수량)
          PNMNG     LIKE AFPO-PSMNG,           "Net
          AMEIN     LIKE AFPO-AMEIN,           "내부생산 단위
          EXFLG(1)  TYPE C,                    "외주공정여부
          STTXT     TYPE CO_STTXT,             "작업상태
          LTEXT     TYPE AUFK-LTEXT,           "비고
          GONG_NM   LIKE ZEDT0011-GONG_NM,     "공정명
          AUTYP     LIKE AUFK-AUTYP,           "오더범주
          ARBPL_C   LIKE CRHD-ARBPL,         "상세설비(작업장)
          KTEXT_C   LIKE M_CRAMN-KTEXT,      "설비명
          INDIA     TYPE ATWRT,              "튜브내경
          M_TYPE    TYPE CHAR2,              "튜브 제품타입
          LOSSQ(28) ,                          "손실규격치
        END   OF GT_PRINT.

*&DATA  : gt_zpps003   TYPE zpps003 OCCURS 0 WITH HEADER LINE.

*& 작업지시 조장내역 인터널 테이블...
DATA  : BEGIN OF GT_MILL OCCURS 0,
          POSNR   LIKE AFPO-POSNR,         "순번(품목번호)
          MWERT11 LIKE MILL_PP_SE-MWERT01, "조장
          MWERT12 LIKE MILL_PP_SE-MWERT01, "보빈수
          MWERT13 LIKE MILL_PP_SE-MWERT01, "검사여장
          MWERT14 LIKE MILL_PP_SE-MWERT01, "시료여장
          MWERT21 LIKE MILL_PP_SE-MWERT01, "조장
          MWERT22 LIKE MILL_PP_SE-MWERT01, "보빈수
          MWERT23 LIKE MILL_PP_SE-MWERT01, "총수량
          AMEIN   LIKE AFPO-AMEIN,         "내부생산 단위
          KDAUF   LIKE AFPO-KDAUF,         "판매오더 번호
          KDPOS   LIKE AFPO-KDPOS,         "품목번호
          NAME1   LIKE KNA1-NAME1,         "납선명
          PACK_T  LIKE MAKT-MAKTX,         "포장규격
        END   OF GT_MILL.

*& 자재 투입내역 인터널 테이블...
DATA  : BEGIN OF GT_RESB OCCURS 0,
          MATNR LIKE RESB-MATNR,           "자재코드
          MAKTX LIKE MAKT-MAKTX,           "품명규격
          CHARG LIKE RESB-CHARG,           "배치번호
          TAGNR LIKE ZPPT0001-TAGNR,       "꼬리표번호
          BDMNG TYPE P DECIMALS 1,         "소요량
          SORTF LIKE RESB-SORTF,           "정렬문자열
          BINQT TYPE I,                    "보빈수
          MEINS LIKE RESB-MEINS,           "단위
          LGORT LIKE RESB-LGORT,           "출고위치
        END   OF GT_RESB.

CONTROLS: TC_101      TYPE TABLEVIEW USING SCREEN 0101.

DATA  : BEGIN OF GS_MARK,
          TYPE        TYPE ATWRT,
          HEIGHT      TYPE ATWRT,
          WIDTH       TYPE ATWRT,
          PITCH       TYPE ATWRT,
          CA_LEN      TYPE ATWRT,
          CA_LEN_INT  TYPE ATWRT,
          CA_LEN_UNIT TYPE ATWRT,
          CA_LEN_CON  TYPE ATWRT,
          CA_CON1     TYPE ATWRT,
          CA_CON2     TYPE ATWRT,
          CA_CON3     TYPE ATWRT,
          CA_CON4     TYPE ATWRT,
          CA_CON5     TYPE ATWRT,
          CA_CON6     TYPE ATWRT,
          CA_CON7     TYPE ATWRT,
          CA_CON8     TYPE ATWRT,
        END   OF GS_MARK.

DATA  : BEGIN OF GT_STOCK OCCURS 0,
          MATNR  TYPE  RESB-MATNR,
          CHARG  TYPE  RESB-CHARG,
          TAGNR  TYPE  ZPPT0001-TAGNR,
          CLABS  TYPE  MCHB-CLABS,
          REMAIN TYPE  ZPPT0001-REMAIN,
          MEINS  TYPE  ZPPT0001-MEINS,
          MAKTX  TYPE  MAKT-MAKTX,
        END  OF GT_STOCK.

*& 작업실적 호출용 파라미터 인터널 테이블...
DATA  : GT_ZPPS040   LIKE ZPPS040 OCCURS 0 WITH HEADER LINE.

DATA  : GT_SELTAB    TYPE TABLE OF RSPARAMS  WITH HEADER LINE,
        GS_SELTAB_WA LIKE LINE  OF GT_SELTAB.

DATA  : GT_PFSTATUS TYPE TABLE OF SY-UCOMM,
        GT_ROW_NO   TYPE LVC_T_ROID WITH HEADER LINE.

DATA  : GV_TOTAL_PAGES(10) TYPE C,
        GV_VARIANT_SAVE    TYPE C VALUE 'U',
        GV_UCOMM           TYPE SY-UCOMM,
        GV_MONTH           TYPE NUMC2,
        GV_LASTDAT         TYPE SY-DATUM,
        GV_SCRFLAG         TYPE C,
        GV_ERRFLAG         TYPE C,
        GV_SELECTED        TYPE CHAR1,
        GV_FIELDNAME       TYPE CHAR30,
        GV_ACTIVETAB       TYPE CHAR20,
        GV_BUKRS           TYPE BUKRS,
        G_ERROR            TYPE C,
        GV_MARK(1)         TYPE C.

DATA: BEGIN OF GT_NUM OCCURS 100,
        QMNUM     LIKE  QMEL-QMNUM,         "통지번호
        QMTXT     LIKE  QMEL-QMTXT,         "단문
        PRINT(04) TYPE  C.
DATA: END OF GT_NUM.

DATA : BEGIN OF GT_MATNR OCCURS 0,
         AUFNR TYPE AFKO-AUFNR,
         MATNR LIKE AFPO-MATNR,
         GUBUN TYPE C,
         ATWRT TYPE ATWRT,
       END OF GT_MATNR.
*- Start 20250115
DATA : GV_WEMNG LIKE AFPO-WEMNG,
       GV_PSMNG LIKE AFPO-PSMNG,
       GV_ERFMG LIKE RESB-ERFMG,
       GV_ENMNG LIKE RESB-ENMNG.

DATA : BEGIN OF GS_AUFM,
         AUFNR LIKE AUFM-AUFNR,
         MBLNR LIKE AUFM-MBLNR,
         MJAHR LIKE AUFM-MJAHR,
       END OF GS_AUFM.
DATA : GT_AUFM LIKE TABLE OF GS_AUFM.

DATA : BEGIN OF GS_INFO,
         TEXT(100),
       END OF GS_INFO.
DATA : GT_INFO LIKE TABLE OF GS_INFO.

DATA : BEGIN OF GS_INFO2,
         AUFNR     LIKE AFKO-AUFNR,
         ICON(4),
         TEXT(100),
       END OF GS_INFO2.
DATA : GT_INFO2 LIKE TABLE OF GS_INFO2.

RANGES : GR_STATUS FOR RC65D-STATUS.
*- End 20250115
*- Start 20250219
DATA : GS_CDSV LIKE ISTATUSOBJSTSCHG,
       GT_CDSV LIKE TABLE OF ISTATUSOBJSTSCHG.
DATA : GS_ZGTPPT3240 LIKE ZGTPPT3240,
       GT_ZGTPPT3240 LIKE TABLE OF ZGTPPT3240.
*- End 20250219
*& Textedit Control
*& reference to wrapper class of control based on OO Framework
DATA : GS_EDITOR     TYPE REF TO C_TEXTEDIT_CONTROL,
       GS_EDITOR2    TYPE REF TO CL_GUI_TEXTEDIT,
       GS_LINK_DYNNR LIKE SY-DYNNR.

*& table to exchange text
DATA  : GS_TEXTEDIT_HEADER LIKE THEAD,
        GT_TLINES          LIKE TLINE OCCURS 0 WITH HEADER LINE,
        GT_TEXTEDIT_LINES  LIKE TLINE-TDLINE OCCURS 0.

DATA  : GS_OUTPUT_OPT  TYPE SSFCOMPOP,
        GS_CONTROL_PAR TYPE SSFCTRLOP.

DATA  : GV_STTXT     TYPE CO_STTXT,           "작업상태
        GV_MATKL     LIKE MARA-MATKL,         "자재그룹(공정코드)
        GV_BUTTON(4) TYPE C,                  "'MENU' or 'GRID'
        GF_STAT(1)   TYPE C,
        GV_SKIP      TYPE C,                  " 조회 skip 여부
        GT_CHAR      TYPE ZPPS112 OCCURS 0 WITH HEADER LINE.

DATA  : ROW_TABLE   TYPE LVC_T_ROW     WITH HEADER LINE,
        GV_OKCODE   LIKE SY-UCOMM,
        GV_OK_CODE2 LIKE SY-UCOMM,
        OK_CODE     LIKE SY-UCOMM,
        OK_CODE2    LIKE SY-UCOMM.
*- Start 2025.02.12
DATA : BEGIN OF GS_STATUS,
         AUFNR LIKE AFKO-AUFNR,
         TXT04 LIKE TJ02T-TXT04,
       END OF GS_STATUS.
DATA : GT_STATUS LIKE TABLE OF GS_STATUS.

DATA : GV_CASE,
       GV_CASE2.

DATA : GS_AUFM2 LIKE AUFM,
       GT_AUFM2 LIKE TABLE OF AUFM.
*- End 2025.02.12
DATA  : BEGIN OF GT_PACK OCCURS 0,
          POSNR  LIKE AFPO-POSNR,         "순번(품목번호)
          CAT    TYPE ATWRT,    "포장재 유형
          MAT    TYPE MAKTX,    "포장재
          DM     TYPE MAKTX,    "포장재(드럼)
          BX     TYPE MAKTX,    "포장재(BOX)
          PA     TYPE MAKTX,    "포장재(PALLET)
          ED_1ST TYPE ATWRT,    "LN LABEL 설계번호(1)
        END   OF GT_PACK.

DATA : BEGIN OF GT_STAT OCCURS 0,
         STAT LIKE  ZPPT0020-ORD_STATUS,
       END OF GT_STAT.

*& 스마트폼 title 출력용
DATA  : GS_TITLE    LIKE ZPPS301,
        GT_MILL_TMP LIKE ZPPS302 OCCURS 0 WITH HEADER LINE,
        GT_RESB_TMP LIKE ZPPS303 OCCURS 0 WITH HEADER LINE,
        GT_PACK_TMP LIKE ZPPS305 OCCURS 0 WITH HEADER LINE.

DATA : GT_3300 TYPE TABLE OF ZGTPPT3300. "알림제외 테이블
DATA : GV_ANSWER TYPE CHAR01.

*& WHERE조건 테이블 정의...
DATA  : GT_WTAB(72)       OCCURS 100 WITH HEADER LINE.

DATA  : GI_DELLINECNT TYPE I.


*** 2009.09.07 추가
DATA: GT_CABN  TYPE CABN     OCCURS 0  WITH HEADER LINE,
      GT_AUSP  LIKE AUSP     OCCURS 0  WITH HEADER LINE,
      GT_CLASS TYPE SCLASS   OCCURS 0  WITH HEADER LINE,
      GT_OBJCT TYPE CLOBJDAT OCCURS 0  WITH HEADER LINE.

CONSTANTS : C_KLART TYPE KLASSENART VALUE '001',
            C_CLASS TYPE KLASSE_D   VALUE 'FT_MW_STD',
            C_PDMW  TYPE ATNAM      VALUE 'PD_MW_APPLY_CUSTOMER'.
*- Start 2025.03.05
DATA : BEGIN OF GS_ACT,
         AUFNR    LIKE AFKO-AUFNR, "오더
         ACTIVITY LIKE MARA-FERTH, "Activity 유형
         MENGE    LIKE AFRU-LMNGA, "실적수량
         MEINS    LIKE MARA-MEINS, "수량단위
         ISM01    LIKE AFRU-ISM01, "준비시간
         ISM02    LIKE AFRU-ISM02, "기계시간
         ISM06    LIKE AFRU-ISM06, "노무시간
         TIMEM    LIKE AFRU-ILE02, "시간단위
         ARBPL    LIKE GT_AFKO-ARBPL, "설비
         GRUND    LIKE AFRU-GRUND, "Activity
       END OF GS_ACT.
DATA : GT_ACT LIKE TABLE OF GS_ACT.

TYPES : BEGIN OF TYPE_SRC,
          LINE(132) TYPE C,
        END   OF TYPE_SRC.
DATA : GT_TEXT TYPE TABLE OF TYPE_SRC,
       WA_TEXT TYPE TYPE_SRC.

DATA : GV_LAST_DAY LIKE SY-DATUM,
       GV_OK.
*- Start 2025.03.25

*[U03] 가온전선 추가
DATA : GCL_POP  TYPE REF TO CL_RS_ALV_GRID_POPUP.      "POPUP ALV
DATA : GS_LAYOD TYPE LVC_S_LAYO,
       GT_FCATD TYPE LVC_T_FCAT.
DATA : BEGIN OF GS_TECO1,
         ID        LIKE ICON-ID,
         AUFNR     LIKE AFKO-AUFNR,
         TEXT(220),
       END OF GS_TECO1.
DATA : GT_TECO1 LIKE TABLE OF GS_TECO1.
DATA : GV_ANS TYPE CHAR1.
DATA : GV_CDATE TYPE SY-DATLO.
*[U03] 가온전선 추가

DEFINE MAIL_MSG.
  CLEAR gs_msg.
  gs_msg = &1.
  APPEND gs_msg TO gtt_message.
END-OF-DEFINITION.

DATA : GV_ARBPL(10),
       GS_USR21     LIKE USR21,
       GV_FLD_02    LIKE ZGTPPT1010-FLD_02,
       GV_FLD_04    LIKE ZGTPPT1010-FLD_04,
       GV_TEXT(9),
       GV_TEXT2(13),
       GV_DATE(10),
       GS_MSG       TYPE SO_TEXT255,
       GV_TIMESTAMP TYPE TIMESTAMPL.
*- End 2025.03.25
* ALV GRID 0904
DATA : GO_CONTAIN_DOCKING_0904 TYPE REF TO CL_GUI_DOCKING_CONTAINER.
DATA : GO_CONTAIN_0904 TYPE REF TO CL_GUI_CONTAINER.
DATA : GO_CONTAIN_0904_1 TYPE REF TO CL_GUI_CONTAINER.
DATA : GO_SPLITTER_0904 TYPE REF TO CL_GUI_SPLITTER_CONTAINER.
DATA : GO_GRID_0904 TYPE REF TO CL_GUI_ALV_GRID.
DATA : GO_GRID_0904_1 TYPE REF TO CL_GUI_ALV_GRID.
DATA : GO_DD_DOCU_0904      TYPE REF TO CL_DD_DOCUMENT.
DATA : GS_LAYOUT_0904 TYPE LVC_S_LAYO.
DATA : GT_EXCLUDE_0904 TYPE UI_FUNCTIONS.
DATA : GT_FIELDCAT_0904 TYPE LVC_T_FCAT.
*- End 2025.03.05
* ALV GRID 0220 2025.01.15 추가
DATA : GO_CONTAIN_0102 TYPE REF TO CL_GUI_DOCKING_CONTAINER.
DATA : GO_GRID_0102 TYPE REF TO CL_GUI_ALV_GRID.
DATA : GS_LAYOUT_0102 TYPE LVC_S_LAYO.
DATA : GT_EXCLUDE_0102 TYPE UI_FUNCTIONS.
DATA : GT_FIELDCAT_0102 TYPE LVC_T_FCAT.

*DATA: gd_repid           TYPE syst-repid,
*      gt_outtab          TYPE STANDARD TABLE OF knb1,
*      go_textedit        TYPE REF TO cl_gui_textedit,
*      go_grid            TYPE REF TO cl_gui_alv_grid,
*      go_container2      TYPE REF TO cl_gui_custom_container,
*      go_container3      TYPE REF TO cl_gui_custom_container,
*      gc_container_name1 TYPE scrfname VALUE 'CONTAINER1'.

*&--------------------------------------------------------------------
SELECTION-SCREEN BEGIN OF BLOCK BL1 WITH FRAME TITLE TEXT-001.

  SELECTION-SCREEN BEGIN OF LINE.
    SELECTION-SCREEN COMMENT 1(30)  TEXT-010 FOR FIELD P_PWERK.
    SELECTION-SCREEN POSITION  33.
    PARAMETERS    : P_PWERK   LIKE  IOHEADER-WERKS    "플랜트
                                    OBLIGATORY MEMORY ID WRK.
    SELECTION-SCREEN POSITION  40.
    PARAMETERS    : T_NAME1   LIKE  T001W-NAME1 MODIF ID ABC.
  SELECTION-SCREEN END   OF LINE.

  SELECT-OPTIONS: S_DISPO   FOR  IOHEADER-DISPO    "MRP관리자
                                  OBLIGATORY MEMORY ID DGR
                                  NO INTERVALS NO-EXTENSION,
                  S_DAUAT   FOR   AFPO-DAUAT        "생산오더 유형
                                  NO INTERVALS
                                  MEMORY ID AAT,
                  S_APRIO   FOR   AFKO-APRIO        "세부유형
                                  NO INTERVALS,
                  S_AUFNR   FOR   AFKO-AUFNR,       "생산오더
*- Start 2025.05.12
                  S_GRPNR   FOR   ZGTPPT2010-GRPNR, "조장 구성표 번호
*- End 2025.05.12
                  S_KDAUF   FOR   AFPO-KDAUF,       "판매오더
                  S_KDPOS   FOR   AFPO-KDPOS,       "판매오더 품목번호
                  S_PROCD   FOR   ZEDT0011-GONG_CD  "공정코드
                                  OBLIGATORY
                                  NO-EXTENSION
                                  NO INTERVALS,
                  S_ARBPL   FOR   CRHD-ARBPL        "설비(작업장)
                                  MATCHCODE OBJECT CRAM.

  SELECTION-SCREEN BEGIN OF LINE.
    SELECTION-SCREEN POSITION  33.
    PARAMETERS    : L_KTEXT   LIKE  M_CRAMN-KTEXT MODIF ID ABC
                                    VISIBLE LENGTH 23.

    SELECTION-SCREEN POSITION  58.
    PARAMETERS    : H_KTEXT   LIKE  M_CRAMN-KTEXT MODIF ID ABC
                                    VISIBLE LENGTH 23.
  SELECTION-SCREEN END   OF LINE.

  SELECT-OPTIONS: S_MATNR   FOR   AFPO-MATNR         "자재코드
                                  NO INTERVALS
                                  VISIBLE LENGTH 18,
                  S_GSTRS   FOR   AFKO-GSTRS,        "작업시작일
*&                                OBLIGATORY,
                  S_PAYOFF FOR SY-DATUM, "Payoff 일자
                  S_FTRMI   FOR   AFKO-FTRMI,        "작업지시일
                  S_STATUS  FOR   ZPPT0020-ORDSTCD.
*                s_status  FOR   rc65d-sttxt       "오더상태
*                                NO INTERVALS
*                                VISIBLE LENGTH 16.
*
*PARAMETERS: pa_sts  LIKE zppt0020-ordstcd.
*PARAMETERS: pa_sts2 LIKE zppt0020-ordstcd.

  SELECTION-SCREEN ULINE.
  PARAMETERS    : C_TECO   AS CHECKBOX DEFAULT 'X'.
*- Start 2025.03.14
  PARAMETERS    : C_CHECK AS CHECKBOX.
*- End 2025.03.14
  PARAMETERS    : C_CHAR   AS CHECKBOX. " DEFAULT 'X'.
  PARAMETERS    : P_DBCNT   LIKE  SY-DBCNT          "총조회라인
                                  DEFAULT '300'.
  PARAMETERS: P_DATE1   LIKE SY-DATUM NO-DISPLAY.
  PARAMETERS: P_DATE2   LIKE SY-DATUM NO-DISPLAY.
*selection-screen begin of line.
*selection-screen  comment 01(79) text-015.
*selection-screen end   of line.
SELECTION-SCREEN END   OF BLOCK BL1.

SELECTION-SCREEN BEGIN OF BLOCK BL5 WITH FRAME TITLE TEXT-005.

  SELECTION-SCREEN : COMMENT /1(79) TEXT-M01.
*- Start 2025.03.14
  SELECTION-SCREEN : COMMENT /1(79) TEXT-M18.
*- End 2025.03.14
SELECTION-SCREEN END   OF BLOCK BL5.
*[U02]
SELECTION-SCREEN BEGIN OF BLOCK BL3 WITH FRAME TITLE TEXT-003.
  PARAMETERS: P_LAYO LIKE DISVARIANT-VARIANT.
SELECTION-SCREEN END   OF BLOCK BL3.
*[U02]
*&--------------------------------------------------------------------

INCLUDE ZGTPPR3020C01.
