*&----------------------------------------------------------------*
*& Include          ZGTPPI2010TOP
*&----------------------------------------------------------------*
*-----------------------------------------------------------------*
* TABLES
*-----------------------------------------------------------------*
 TABLES: AUFK, AFPO, AFKO, JCDS, ZGTPPT3010, ZGTPPT3020, ZGTPPT3030, ZGTPPT3040, ZGTPPT3050.
*-----------------------------------------------------------------*
* DATA: Variable
*-----------------------------------------------------------------*
 DATA : GV_ERROR,
        GT_UCOMM    TYPE TABLE OF SY-UCOMM,
        GV_OK_CODE  LIKE SY-UCOMM,
        GV_OK_CODE2 LIKE SY-UCOMM.

 DATA : GT_ROW_TABLE TYPE LVC_T_ROW WITH HEADER LINE,
        GV_LINES     TYPE INDEX.

 DATA : GV_RESULT  TYPE ZO_RESULT,
        GV_MESSAGE TYPE ZO_MESSAGE,
        GV_ANSWER  TYPE C,
        GV_CNT     TYPE SY-INDEX,
        GV_TABIX   TYPE SY-TABIX.

 RANGES : GR_WERKS FOR MAPL-WERKS,
                 GR_DISPO FOR MARC-DISPO.
*-----------------------------------------------------------------*
* DATA: Structure. (Field strings : Working area)
*-----------------------------------------------------------------*
*- 헤더
* 생산오더 헤더 ALV
 DATA : BEGIN OF GS_DISP_HEAD,
          ICON(4),                                    "전송 상태
          ZMESSAGE(100),                              "결과 메시지
          ZSYSTEM_ID      LIKE ZGTPPT1020-ZSYSTEM_ID, "수신 시스템
          ZSYSTEM_ID_DESC LIKE DD07V-DDTEXT,          "시스템 내역
          WERKS           LIKE AUFK-WERKS,            "플랜트
          AUFNR           LIKE AFKO-AUFNR,            "생산오더번호
          AUART           LIKE AUFK-AUART,            "생산오더유형
          STATUS(50),                                 "오더 상태
          DISPO           LIKE AFKO-DISPO,            "MRP 관리자
          FEVOR           LIKE AFKO-FEVOR,            "생산 감독자
          GAMNG           LIKE AFKO-GAMNG,            "생산오더수량
          GASMG           LIKE AFKO-GASMG,            "오더불량수량
          GMEIN           LIKE AFKO-GMEIN,            "오더단위
          SBMNG           LIKE AFKO-SBMNG,            "기준수량
          SBMEH           LIKE AFKO-SBMEH,            "기본단위
          GSTRP           LIKE AFKO-GSTRP,            "기본시작일
          GLTRP           LIKE AFKO-GLTRP,            "기본종료일
          GSTRS           LIKE AFKO-GSTRS,            "일정계획시작일
          GSUZS           LIKE AFKO-GSUZS,            "일정계획시작시간
          GLTRS           LIKE AFKO-GLTRS,            "일정계획종료일
          GLUZS           LIKE AFKO-GLUZS,            "일정계획종료시간
          KDAUF           LIKE AUFK-KDAUF,            "판매오더
          KDPOS           LIKE AUFK-KDPOS,            "판매오더아이템
*- Start 2024.12.18
          LOEKZ           LIKE AUFK-LOEKZ,            "삭제 지시자
          ZZPRIORITY      LIKE AUFK-ZZPRIORITY,       "작업 우선순위
          ZZORIGIN        LIKE AUFK-ZZORIGIN,         "기존 생산오더
          ZZFOLLOWING     LIKE AUFK-ZZFOLLOWING,      "후속 생산오더
*- End 2024.12.18
*// Modified by ZGODEV06 on 2026-01-21 {
          ZZBUNDLE        LIKE AUFK-ZZBUNDLE,         "묶음 생산오더.
          ZZPOSNR         LIKE AUFK-ZZPOSNR,          "묶음 생산오더 항번,
          ZZKDAUF         LIKE AUFK-ZZKDAUF,          "판매오더번호(MTS).
          ZZKDPOS         LIKE AUFK-ZZKDPOS,          "판매오더품목(MTS).
          ZZYUSCD         LIKE ZGTSDT1104-ZZYUSCD,    "영업소.
          ZTEXT           LIKE ZGTPPT3010-ZTEXT,      "특기사항.
*// }
        END OF GS_DISP_HEAD.
 DATA : GS_SEND_HEAD LIKE ZGTPPT3010.  "전송용 테이블
 DATA : GS_ZGTPPT3010 LIKE ZGTPPT3010. "로그 조회 데이터 취합
 DATA : BEGIN OF GS_DISP_HEAD2,
          ZIFKEY          LIKE ZGTPPT3010-ZIFKEY,     "인터페이스 키
          ZSTAT           LIKE ZGTPPT3010-ZSTAT,      "전송 결과
          ICON(4),                                    "전송 상태
          ZMESSAGE(100),                              "결과 메시지
          ZSYSTEM_ID      LIKE ZGTPPT3010-ZSYSTEM_ID, "수신 시스템
          ZSYSTEM_ID_DESC LIKE DD07V-DDTEXT,          "시스템 내역
          WERKS           LIKE ZGTPPT3010-WERKS,      "플랜트
          AUFNR           LIKE ZGTPPT3010-AUFNR,      "생산오더번호
          AUART           LIKE ZGTPPT3010-AUART,      "생산오더유형
          STATUS          LIKE ZGTPPT3010-STATUS,     "오더 상태
          DISPO           LIKE ZGTPPT3010-DISPO,      "MRP 관리자
          FEVOR           LIKE ZGTPPT3010-FEVOR,      "생산 감독자
          GAMNG           LIKE ZGTPPT3010-GAMNG,      "생산오더수량
          GASMG           LIKE ZGTPPT3010-GASMG,      "오더불량수량
          GMEIN           LIKE ZGTPPT3010-GMEIN,      "오더단위
          SBMNG           LIKE ZGTPPT3010-SBMNG,      "기준수량
          SBMEH           LIKE ZGTPPT3010-SBMEH,      "기본단위
          GSTRP           LIKE ZGTPPT3010-GSTRP,      "기본시작일
          GLTRP           LIKE ZGTPPT3010-GLTRP,      "기본종료일
          GSTRS           LIKE ZGTPPT3010-GSTRS,      "일정계획시작일
          GSUZS           LIKE ZGTPPT3010-GSUZS,      "일정계획시작시간
          GLTRS           LIKE ZGTPPT3010-GLTRS,      "일정계획종료일
          GLUZS           LIKE ZGTPPT3010-GLUZS,      "일정계획종료시간
          KDAUF           LIKE ZGTPPT3010-KDAUF,      "판매오더
          KDPOS           LIKE ZGTPPT3010-KDPOS,      "판매오더아이템
*- Start 2024.12.18
          LOEKZ           LIKE AUFK-LOEKZ,            "삭제 지시자
          ZZPRIORITY      LIKE AUFK-ZZPRIORITY,       "작업 우선순위
          ZZORIGIN        LIKE AUFK-ZZORIGIN,         "기존 생산오더
          ZZFOLLOWING     LIKE AUFK-ZZFOLLOWING,      "후속 생산오더
*- End 2024.12.18
*// Modified by ZGODEV06 on 2026-01-21 {
          ZZBUNDLE        LIKE AUFK-ZZBUNDLE,         "묶음 생산오더.
          ZZPOSNR         LIKE AUFK-ZZPOSNR,          "묶음 생산오더 항번,
          ZZKDAUF         LIKE AUFK-ZZKDAUF,          "판매오더번호(MTS).
          ZZKDPOS         LIKE AUFK-ZZKDPOS,          "판매오더품목(MTS).
          ZZYUSCD         LIKE ZGTSDT1104-ZZYUSCD,    "영업소.
          ZTEXT           LIKE ZGTPPT3010-ZTEXT,      " 특기사항.
*// }
          IFDAT           LIKE ZGTPPT3010-IFDAT,      "전송일자
          IFTIM           LIKE ZGTPPT3010-IFTIM,      "전송시간
          IFNAM           LIKE ZGTPPT3010-IFNAM,      "전송자
        END OF GS_DISP_HEAD2. "로그 조회 - 헤더
*- 아이템
* 생산오더 아이템 취합용 데이터
 DATA : GS_AFPO LIKE AFPO.
* 생산오더 아이템 ALV
 DATA : BEGIN OF GS_DISP_ITEM,
          AUFNR    LIKE AFPO-AUFNR,          "생산오더번호
          POSNR    LIKE AFPO-POSNR,          "오더품목번호
          MATNR    LIKE AFPO-MATNR,          "품목코드
          MAKTX    LIKE MAKT-MAKTX,          "품목코드 내역
          ELIKZ    LIKE AFPO-ELIKZ,          "납품완료 지시자
          UEBTO    LIKE AFPO-UEBTO,          "초과납품(%)
          UEBTK    LIKE AFPO-UEBTK,          "무제한 초과 납품
          LGORT    LIKE AFPO-LGORT,          "생산품 입고저장위치
          MWERT11  LIKE ZGTPPT3020-MWERT11,  "기본 조장 길이
          MWERT12  LIKE ZGTPPT3020-MWERT12,  "조장 Additional
          PSAMG    LIKE ZPPTC002-PSAMG,      "검사여장
          PSMNG    LIKE ZPPTC002-PSMNG,      "품목 지시조장
          MWERT21  LIKE ZGTPPT3020-MWERT11,  "추가 여장
          MWERT22  LIKE ZGTPPT3020-MWERT12,  "입고 보빈 수
          GRPNR    LIKE ZGTPPT3020-GRPNR,    "조장 구성표 번호
          CHARG    LIKE AFPO-CHARG,          "배치번호
          VERID    LIKE AFPO-VERID,          "생산버전
*//  Modified by ZGODEV06 on 2026-01-21 {
          KDAUF    LIKE ZGTPPT3020-KDAUF,    "판매오더.
          KDPOS    LIKE ZGTPPT3020-KDPOS,    "판매오더 품목 번호.
          ZZBUNDLE LIKE ZGTPPT3020-ZZBUNDLE, "신선 - 묶음오더번호.
          ZZPOSNR  LIKE ZGTPPT3020-ZZPOSNR,  "신선 - 묶음오더 품목번호.
          ZCAGE    LIKE ZGTPPT3020-ZCAGE,    "신선 - Cage.
          ZWSEQ    LIKE ZGTPPT3020-ZWSEQ,    "신선 - 차수.
          INSMK    LIKE AFPO-INSMK,          "재고유형.
          ZSPECNO  LIKE ZGTPPT2330-ZSPECNO,  "SPEC 번호.
          YCOEF    LIKE ZGTPPT3020-YCOEF,    "연입률.
*// }
*// Modified  on 2026-07-08 {
          MATNR_DM LIKE ZGTPPT2010-MATNR,
*// }
        END OF GS_DISP_ITEM.
 DATA : GS_DATA_ITEM LIKE GS_DISP_ITEM. "ALV 출력용 생산오더 ITEM 데이터
 DATA : GS_SEND_ITEM LIKE ZGTPPT3020. "전송용 테이블

 DATA : BEGIN OF GS_DISP_ITEM2,
          ZIFKEY   LIKE ZGTPPT3010-ZIFKEY,   "인터페이스 키
          AUFNR    LIKE AFPO-AUFNR,          "생산오더번호
          POSNR    LIKE AFPO-POSNR,          "오더품목번호
          MATNR    LIKE AFPO-MATNR,          "품목코드
          MAKTX    LIKE MAKT-MAKTX,          "품목코드 내역
          ELIKZ    LIKE AFPO-ELIKZ,          "납품완료 지시자
          UEBTO    LIKE AFPO-UEBTO,          "초과납품(%)
          UEBTK    LIKE AFPO-UEBTK,          "무제한 초과 납품
          LGORT    LIKE AFPO-LGORT,          "생산품 입고저장위치
          MWERT11  LIKE ZGTPPT3020-MWERT11,  "기본 조장 길이
          MWERT12  LIKE ZGTPPT3020-MWERT12,  "조장 Additional
          PSAMG    LIKE AFPO-PSAMG,          "검사여장
          PSMNG    LIKE AFPO-PSMNG,          "품목 지시조장
          MWERT21  LIKE ZGTPPT3020-MWERT11,  "추가 여장
          MWERT22  LIKE ZGTPPT3020-MWERT12,  "입고 보빈 수
          GRPNR    LIKE ZGTPPT3020-GRPNR,    "조장 구성표 번호
          CHARG    LIKE AFPO-CHARG,          "배치번호
          VERID    LIKE AFPO-VERID,          "생산버전
*// Modified by ZGODEV06 on 2026-01-21 {
          KDAUF    LIKE ZGTPPT3020-KDAUF,    "판매오더.
          KDPOS    LIKE ZGTPPT3020-KDPOS,    "판매오더 품목 번호.
          ZZBUNDLE LIKE ZGTPPT3020-ZZBUNDLE, "신선 - 묶음오더번호.
          ZZPOSNR  LIKE ZGTPPT3020-ZZPOSNR,  "신선 - 묶음오더 품목번호.
          ZCAGE    LIKE ZGTPPT3020-ZCAGE,    "신선 - Cage.
          ZWSEQ    LIKE ZGTPPT3020-ZWSEQ,    "신선 - 차수.
          INSMK    LIKE AFPO-INSMK,          "재고유형.
          ZSPECNO  LIKE ZGTPPT2330-ZSPECNO,  "SPEC 번호.
          YCOEF    LIKE ZGTPPT3020-YCOEF,    "연입률.
*// }
*// Modified  on 2026-07-08 {
          MATNR_DM LIKE ZGTPPT2010-MATNR,
*// }
        END OF GS_DISP_ITEM2.
 DATA : GS_DATA_ITEM2 LIKE GS_DISP_ITEM2. "로그 조회 - 아이템
*- 공정
* 생산오더 공정 취합용 데이터
 DATA : BEGIN OF GS_PROD_ROUT,
          AUFNR LIKE AFPO-AUFNR, "생산오더번호
        END OF GS_PROD_ROUT.
* 생산오더 공정 ALV
 DATA : BEGIN OF GS_DISP_ROUT,
          AUFNR LIKE AFKO-AUFNR, "생산오더번호
          VORNR LIKE AFVC-VORNR, "작업/액티비티 번호
          PLNAL LIKE AFVC-PLNAL, "그룹카운터
          PLNFL LIKE AFVC-PLNFL, "작업순서
          LTXA1 LIKE AFVC-LTXA1, "작업내역
          ARBPL LIKE CRHD-ARBPL, "작업장
          KTEXT LIKE CRTX-KTEXT, "작업장 설명(간단한 내역)
          KTSCH LIKE AFVC-KTSCH, "표준텍스트키
          STEUS LIKE AFVC-STEUS, "제어키
          SSAVD LIKE BAPI_ORDER_OPERATION1-LATE_SCHED_START_DATE_EXEC,
          "최근 계획 시작: 실행(일자)
          SSAVZ LIKE BAPI_ORDER_OPERATION1-LATE_SCHED_START_TIME_EXEC,
          "최근 계획 시작: 실행(시간)
          SSEDD LIKE BAPI_ORDER_OPERATION1-LATE_SCHED_FIN_DATE_EXEC,
          "최근 계획 종료: 실행(일자)
          SSEDZ LIKE BAPI_ORDER_OPERATION1-LATE_SCHED_FIN_TIME_EXEC,
          "최근 계획 종료: 실행(시간)
          LOEKZ LIKE AFVC-LOEKZ,
*// Modified by ZGODEV06 on 2026-01-21 {
          VERAN LIKE CRHD-VERAN,  " 책임자.
*// }

        END OF GS_DISP_ROUT.
 DATA : GS_DATA_ROUT LIKE GS_DISP_ROUT. "ALV 출력용 생산오더 공정 데이터
 DATA : GS_SEND_ROUT LIKE ZGTPPT3030. "전송용 테이블

 DATA : BEGIN OF GS_DISP_ROUT2,
          ZIFKEY LIKE ZGTPPT3010-ZIFKEY, "인터페이스 키
          AUFNR  LIKE AFKO-AUFNR,        "생산오더번호
          VORNR  LIKE AFVC-VORNR,        "작업/액티비티 번호
          PLNAL  LIKE AFVC-PLNAL,        "그룹카운터
          PLNFL  LIKE AFVC-PLNFL,        "작업순서
          LTXA1  LIKE AFVC-LTXA1,        "작업내역
          ARBPL  LIKE CRHD-ARBPL,        "작업장
          KTEXT  LIKE CRTX-KTEXT,        "작업장 설명(간단한 내역)
          KTSCH  LIKE AFVC-KTSCH,        "표준텍스트키
          STEUS  LIKE AFVC-STEUS,        "제어키
          SSAVD  LIKE BAPI_ORDER_OPERATION1-LATE_SCHED_START_DATE_EXEC,
          "최근 계획 시작: 실행(일자)
          SSAVZ  LIKE BAPI_ORDER_OPERATION1-LATE_SCHED_START_TIME_EXEC,
          "최근 계획 시작: 실행(시간)
          SSEDD  LIKE BAPI_ORDER_OPERATION1-LATE_SCHED_FIN_DATE_EXEC,
          "최근 계획 종료: 실행(일자)
          SSEDZ  LIKE BAPI_ORDER_OPERATION1-LATE_SCHED_FIN_TIME_EXEC,
          "최근 계획 종료: 실행(시간)
          LOEKZ  LIKE AFVC-LOEKZ,
        END OF GS_DISP_ROUT2.
 DATA : GS_DATA_ROUT2 LIKE GS_DISP_ROUT2. "ALV 출력용 생산오더 공정 데이터
*- BOM
* 생산오더 BOM ALV
 DATA : BEGIN OF GS_DISP_BOM,
          AUFNR LIKE RESB-AUFNR, "생산오더번호
          RSNUM LIKE RESB-RSNUM, "예약번호
          RSPOS LIKE RESB-RSPOS, "예약아이템번호
          MATNR LIKE RESB-MATNR, "구성부품
          MAKTX LIKE MAKT-MAKTX, "구성부품 내역
          ERFMG LIKE RESB-ERFMG, "구성부품수량
          ERFME LIKE RESB-ERFME, "구성부품단위
          LGORT LIKE RESB-LGORT, "출고위치
          CHARG LIKE RESB-CHARG, "배치번호
          XLOEK LIKE RESB-XLOEK, "삭제 지시자
          RGEKZ LIKE RESB-RGEKZ, "백플러쉬 지시자
        END OF GS_DISP_BOM.
 DATA : GS_DATA_BOM LIKE GS_DISP_BOM. "ALV 출력용 생산오더 BOM 데이터
 DATA : GS_SEND_BOM LIKE ZGTPPT3040. "전송용 테이블

 DATA : BEGIN OF GS_DISP_BOM2,
          ZIFKEY LIKE ZGTPPT3010-ZIFKEY, "인터페이스 키
          AUFNR  LIKE RESB-AUFNR,        "생산오더번호
          RSNUM  LIKE ZGTPPT3040-RSNUM,  "예약번호
          RSPOS  LIKE ZGTPPT3040-RSPOS,  "예약아이템번호
          MATNR  LIKE RESB-MATNR,        "구성부품
          MAKTX  LIKE MAKT-MAKTX,        "구성부품 내역
          ERFMG  LIKE RESB-ERFMG,        "구성부품수량
          ERFME  LIKE RESB-ERFME,        "구성부품단위
          LGORT  LIKE RESB-LGORT,        "출고위치
          CHARG  LIKE RESB-CHARG,        "배치번호
          XLOEK  LIKE RESB-XLOEK,        "삭제 지시자
          RGEKZ  LIKE RESB-RGEKZ,        "백플러쉬 지시자
        END OF GS_DISP_BOM2.
 DATA : GS_DATA_BOM2 LIKE GS_DISP_BOM2. "ALV 출력용 생산오더 BOM 데이터
*- 특성
* 생산오더 특성 취합용 데이터
 DATA : BEGIN OF GS_PROD_CHAR,
          AUFNR LIKE AFPO-AUFNR, "생산오더번호
*// Modified by ZGODEV06 on 2026-01-21 {
          POSNR LIKE AFPO-POSNR, "생산오더번호 품목
*  // }
          KDAUF LIKE AUFK-KDAUF, "판매오더
          KDPOS LIKE AUFK-KDPOS, "판매오더아이템
          CUOBJ TYPE AFPO-CUOBJ,
        END OF GS_PROD_CHAR.
* 생산오더 특성 ALV
 DATA : BEGIN OF GS_DISP_CHAR,
          AUFNR LIKE AFKO-AUFNR, "생산오더번호
          CLASS LIKE ZGTPPSIF0008-CLASS, "클래스
          ATNAM LIKE CONF_OUT-ATNAM, "특성
          ATBEZ LIKE CONF_OUT-ATBEZ, "특성내역
          ATWRT LIKE CONF_OUT-ATWRT, "특성값
          ATWTB LIKE CONF_OUT-ATWTB, "특성값내역
        END OF GS_DISP_CHAR.
 DATA : GS_DATA_CHAR LIKE GS_DISP_CHAR. "ALV 출력용 생산오더 특성 데이터
 DATA : GS_SEND_CHAR LIKE ZGTPPT3050. "전송용 테이블

 DATA : BEGIN OF GS_DISP_CHAR2,
          ZIFKEY LIKE ZGTPPT3010-ZIFKEY, "인터페이스 키
          AUFNR  LIKE AFKO-AUFNR, "생산오더번호
          ATNAM  LIKE CONF_OUT-ATNAM, "특성
          ATBEZ  LIKE CONF_OUT-ATBEZ, "특성내역
          ATWRT  LIKE CONF_OUT-ATWRT, "특성값
          ATWTB  LIKE CONF_OUT-ATWTB, "특성값내역
        END OF GS_DISP_CHAR2.
 DATA : GS_DATA_CHAR2 LIKE GS_DISP_CHAR2. "ALV 출력용 생산오더 특성 데이터
*- 기타
 DATA : BEGIN OF GS_ZIFKEY,
          ZIFKEY LIKE ZGTPPT3050-ZIFKEY,
          AUFNR  LIKE ZGTPPT3050-AUFNR,
        END OF GS_ZIFKEY. "로그 조회 데이터 취합용 조건 데이터
*-----------------------------------------------------------------*
* DATA: Internal Table.
*-----------------------------------------------------------------*
* 기타
 DATA : GT_ZGTPPT1010 TYPE TABLE OF ZGTPPT1010, "코드 마스터 테이블
        GT_ZIFKEY     LIKE TABLE OF GS_ZIFKEY.
* 헤더
 DATA : GT_DISP_HEAD LIKE TABLE OF GS_DISP_HEAD, "생산오더 헤더 ALV
        GT_SEND_HEAD LIKE TABLE OF ZGTPPT3010, "로그 업데이트
        GT_MES_HEAD  TYPE TABLE OF ZGTPPSIF0004. "MES 전송

 DATA : GT_ZGTPPT3010 LIKE TABLE OF GS_ZGTPPT3010, "로그 조회 데이터 취합
        GT_DISP_HEAD2 LIKE TABLE OF GS_DISP_HEAD2. "로그 조회 - 헤더
* 아이템
 DATA : GT_AFPO      LIKE TABLE OF AFPO, "데이터 취합용
        GT_ZPPTC002  LIKE TABLE OF ZPPTC002, "떼이터 취합용
        GT_DATA_ITEM LIKE TABLE OF GS_DATA_ITEM, "ALV 출력용 생산오더 ITEM 데이터
        GT_DISP_ITEM LIKE TABLE OF GS_DISP_ITEM, "선택한 생산오더 ITEM ALV 출력
        GT_SEND_ITEM LIKE TABLE OF ZGTPPT3020, "로그 업데이트
        GT_MES_ITEM  TYPE TABLE OF ZGTPPSIF0005. "MES 전송

*// Modified by ZGODEV06 on 2026-01-21 {
 DATA GT_ZGTPPT2010 TYPE TABLE OF ZGTPPT2010.
 DATA GT_ZGTPPT2012 TYPE TABLE OF ZGTPPT2012.
 DATA GT_ZGTCVMSTVAL   TYPE TABLE OF ZGTPP_CV_MASTVAL.
 DATA GT_ZGTCVORDSYVAL TYPE TABLE OF ZGTCVORDSYVAL.
 DATA GT_CRHD TYPE TABLE OF ZGTPPVCRHD.
*// }

 DATA : GT_DATA_ITEM2 LIKE TABLE OF GS_DATA_ITEM2,
        GT_DISP_ITEM2 LIKE TABLE OF GS_DISP_ITEM2. "로그 조회 - ALV 출력용 데이터
* 공정
 DATA : GT_PROD_ROUT LIKE TABLE OF GS_PROD_ROUT, "데이터 취합용
        GT_DATA_ROUT LIKE TABLE OF GS_DATA_ROUT, "ALV 출력용 생산오더 공정 데이터
        GT_DISP_ROUT LIKE TABLE OF GS_DISP_ROUT, "선택한 생산오더 공정 ALV 출력
        GT_SEND_ROUT LIKE TABLE OF ZGTPPT3030, "로그 업데이트
        GT_MES_ROUT  TYPE TABLE OF ZGTPPSIF0006. "MES 전송

 DATA : GT_DATA_ROUT2 LIKE TABLE OF GS_DATA_ROUT2,
        GT_DISP_ROUT2 LIKE TABLE OF GS_DISP_ROUT2. "로그 조회 - ALV 출력용 데이터
* BOM
 DATA : GT_DATA_BOM LIKE TABLE OF GS_DATA_BOM, "ALV 출력용 생산오더 BOM 데이터
        GT_DISP_BOM LIKE TABLE OF GS_DISP_BOM, "선택한 생산오더 BOM ALV 출력
        GT_SEND_BOM LIKE TABLE OF ZGTPPT3040, "로그 업데이트
        GT_MES_BOM  TYPE TABLE OF ZGTPPSIF0007. "MES 전송

 DATA : GT_DATA_BOM2 LIKE TABLE OF GS_DATA_BOM2,
        GT_DISP_BOM2 LIKE TABLE OF GS_DISP_BOM2. "로그 조회 - ALV 출력용 데이터
* 특성
 DATA : GT_PROD_CHAR LIKE TABLE OF GS_PROD_CHAR, "데이터 취합용
        GT_DATA_CHAR LIKE TABLE OF GS_DATA_CHAR, "ALV 출력용 생산오더 특성 데이터
        GT_DISP_CHAR LIKE TABLE OF GS_DISP_CHAR, "선택한 생산오더 특성 ALV 출력
        GT_SEND_CHAR LIKE TABLE OF ZGTPPT3050, "로그 업데이트
        GT_MES_CHAR  TYPE TABLE OF ZGTPPSIF0008. "MES 전송

 DATA : GT_DATA_CHAR2 LIKE TABLE OF GS_DATA_CHAR2,
        GT_DISP_CHAR2 LIKE TABLE OF GS_DISP_CHAR2. "로그 조회 - ALV 출력용 데이터

*// Modified by ZGODEV06 on 2026-01-21 {
 TYPES: BEGIN OF TY_S_SALES_ORG,
          VKORG   TYPE VBAK-VKORG,
          VKGRP   TYPE VBAK-VKGRP,
          KDKG4   TYPE VBKD-KDKG4,
          ZZYUSCD TYPE ZGTSDT1103-ZZYUSCD,
        END OF TY_S_SALES_ORG.

 TYPES: BEGIN OF TY_S_VBAK,
          VBELN TYPE VBAK-VBELN.
          INCLUDE TYPE TY_S_SALES_ORG.
 TYPES: END OF TY_S_VBAK.

 TYPES: BEGIN OF TY_S_PLAF.
          INCLUDE TYPE PLAF.
 TYPES:   MAKTX    TYPE MAKT-MAKTX,
*** Start 2026.07.01 계획오더 필드 추가 By ZGISPP03
          INLENGTH TYPE ZGTPPT2330-INLENGTH,
          QLENGTH  TYPE ZGTPPT2330-QLENGTH,
          CLENGTH  TYPE ZGTPPT2330-CLENGTH,
          INFACTOR TYPE ZGTPPT2330-INFACTOR,
*** End 2026.07.01 계획오더 필드 추가 By ZGISPP03
        END OF TY_S_PLAF.

 TYPES: BEGIN OF TY_S_RESB.
          INCLUDE TYPE RESB.
 TYPES:   MAKTX TYPE MAKT-MAKTX,
        END OF TY_S_RESB.

 TYPES: TY_T_PLAF TYPE TABLE OF TY_S_PLAF WITH DEFAULT KEY.
 TYPES: TY_T_RESB TYPE TABLE OF TY_S_RESB WITH DEFAULT KEY.

 DATA GT_VBAK TYPE TABLE OF TY_S_VBAK.
 DATA GT_SALES_ORG TYPE TABLE OF TY_S_SALES_ORG WITH NON-UNIQUE SORTED KEY SKEY
                                                                COMPONENTS VKORG VKGRP KDKG4.

 DATA GV_ZSYSTEM_ID      TYPE ZGTPPT1020-ZSYSTEM_ID. "수신 시스템
 DATA GV_ZSYSTEM_ID_DESC TYPE DD07V-DDTEXT.          "시스템 내역
* // }

*-----------------------------------------------------------------*
* ALV
*-----------------------------------------------------------------*
*& CLASS Reference 정의
 CLASS: LCL_EVENT_HANDLER      DEFINITION DEFERRED.

 DATA : GV_DYNNR  LIKE SY-DYNNR,
        GV_DYNNR2 LIKE SY-DYNNR.

 CONTROLS : TABSTR    TYPE TABSTRIP.
* reference to custom container: neccessary to bind ALV Control
 DATA : G_CUSTOM_CONTAINER TYPE REF TO CL_GUI_CUSTOM_CONTAINER,
        G_GRID             TYPE REF TO CL_GUI_ALV_GRID,
        G_EVENT_HANDLER    TYPE REF TO LCL_EVENT_HANDLER.
*---------ALV 1-----------
 DATA : GT_EXCLUDE   TYPE UI_FUNCTIONS.
 DATA : GS_PRINT       TYPE LVC_S_PRNT,
        GS_LAYOUT      TYPE LVC_S_LAYO,
        GV_MYCONTAINER TYPE SCRFNAME VALUE 'CONTAINER_100',
*      fieldcatalog for output table,
        GS_FIELDCAT    TYPE LVC_S_FCAT,
        GT_FIELDCAT    TYPE LVC_T_FCAT,
        GS_FCATLAYO    TYPE LVC_S_LAYO,
        GS_F4          TYPE LVC_S_F4,      " F4 필드 관련
        GT_F4          TYPE LVC_T_F4.
 DATA : GS_FCAT TYPE LVC_S_FCAT.

 DATA : GS_SORT      TYPE LVC_S_SORT.
 DATA : GT_SORT      TYPE LVC_T_SORT.

 DATA : GV_REPID LIKE SY-REPID.
 DATA : GV_ALV_VARIANT LIKE DISVARIANT.
 DATA : GT_ROW_NO TYPE LVC_T_ROID WITH HEADER LINE.
*================================================================
 DATA : GC_CONTAINER_NAME1   TYPE SCRFNAME VALUE 'CONTAINER1',
        GC_CONTAINER_NAME2   TYPE SCRFNAME VALUE 'CONTAINER2',
        GC_CONTAINER_NAME3   TYPE SCRFNAME VALUE 'CONTAINER3',
        GC_CONTAINER_NAME4   TYPE SCRFNAME VALUE 'CONTAINER4',
        GC_CUSTOM_CONTAINER1 TYPE REF TO CL_GUI_CUSTOM_CONTAINER,
        GC_CUSTOM_CONTAINER2 TYPE REF TO CL_GUI_CUSTOM_CONTAINER,
        GC_CUSTOM_CONTAINER3 TYPE REF TO CL_GUI_CUSTOM_CONTAINER,
        GC_CUSTOM_CONTAINER4 TYPE REF TO CL_GUI_CUSTOM_CONTAINER,
        GC_ALV_GRID1         TYPE REF TO CL_GUI_ALV_GRID,
        GC_ALV_GRID2         TYPE REF TO CL_GUI_ALV_GRID,
        GC_ALV_GRID3         TYPE REF TO CL_GUI_ALV_GRID,
        GC_ALV_GRID4         TYPE REF TO CL_GUI_ALV_GRID.

 DATA : GV_ITAB    LIKE GS_FIELDCAT-TABNAME,
        GV_POS     LIKE GS_FIELDCAT-COL_POS,
        GS_SCROLL  TYPE LVC_S_STBL,
        GS_VARIANT TYPE DISVARIANT,
        GV_STABLE  TYPE LVC_S_STBL VALUE 'XX'.

***  START 2026.07.01 By ZGISPP03
 RANGES : LR_DATUM FOR SY-DATUM.
 RANGES : LR_UZEIT FOR SY-UZEIT.
***  END 2026.07.01 By ZGISPP03
