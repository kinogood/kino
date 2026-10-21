*&---------------------------------------------------------------------*
*&  모듈/서브모듈 : PP/                                                *
*&  GAP ID        : PPA08                                              *
*&  Type          : Report                                             *
*&  T_Code        : ZPPR1000                                           *
*&  Description   : 재고에 대한 입고일을 계산하여 장기/과잉 재고
*유무파악*
*&---------------------------------------------------------------------*
*&                  MODIFICATION LOG                                   *
*&---------------------------------------------------------------------*
*&  DATE         AUTHORS   DESCRIPTION                                 *
*&  ----------   --------- --------------------------------------------*
*& 20250327     ZGSIDEV08  ZPPT1000->ZGTPPR9020 COPY
*& 20250613     ZGSIDEV08  DATA조회시 자재문서의 판매오더, 판매품목 추가
*& 20250618     ZGSIDEV08  DATA생성시 장기 재고 추출 시
*&                        특정 자재에 대해 이동유형 추가(413)
*&---------------------------------------------------------------------*
*& 2008.03.10  권우식   CSR번호:
*& 2008.04.22  이정익   [요청번호]C20080422_54797
*&                      [제목]자재코드,손익센터 실제값만 조회
*& 2008.11.04  이정익   [요청번호] C20081104_52476
*&                      [제목]부스닥트의 경우 실제원가를 평균가로 적용
*& 2009.01.09  이정익   [요청번호] C20090109_83400
*&                      [제목]분류 코드 Text 추가
*& 2009.06.24  이정익   [요청번호]C20090623_78111
*&                      [제목]1303,1304,1801 플랜트의 5~7월 입고자재문서
*&                            중 이체분에 대해서 원 플랜트의
*입고자재문서
*&                            를 사용 없으면 이체 자재문서를 사용
*& 2009.10.07  이정익   [요청번호]C20090930_34189
*&                      [제목] 재고유형 Text 추가
*& 2011.03.04  이정익   [요청번호]C20110303_35149
*&                      [제목]1403 AL 재고실사 문서 반영
*& 2011.07.12  이정익   [요청번호]C20110708_22145
*&                      [제목]1405 플랜트 이전전기 및 3501 동박
*환산단위추가
*& 2012.05.21  이정익   [요청번호]C20120517_10391
*&                      [제목]재고관리모니터링 결산후 단가 로직 변경건
*& 2012.10.11  이정익   [요청번호]C20121010_96873
*&                      [제목]기존 추출 자재문서 조회 로직 보완
*& 2013.03.27  이정익   [요청번호]C20130326_98971
*&                      [제목]3207 플랜트 이전 반영
*& 2013.05.24  김재익   [요청번호]C20130518_33537
*&                      [제목] 30일이전 재고포함 로직 추가
*& 2014.02.11  이정익   [요청번호]기능개선_9945
*&                      [제목]자재문서 추출시 엠트론 속도 개선
*& 2014.10.21  엄지희   [요청번호]기능개선_47570
*&                      [제목]연결원가 재고 Aging 연계를 위한 로직 추가
*& 2015.04.17   이정익  기능개선_76319 EV솔루션 플랜트 이전 반영
*& 2015.05.21   이정익  기능개선_80963 부스닥트 플랜트 이전 반영
*& 2016.01.26   이정익  자체개선_114374 EV솔루션 플랜트 이전 반영
*& 2016.06.27   엄지희  자체개선_142736 장기재고 추출 시 입고 자재문서
*&                      자릿수 초과 개선
*& 2016.07.11   엄지희  자체개선_144793 결산 후 수량 생성된 재고 반영시
*&                      자재유형 누락 개선
*& 2017.02.13   이정익  기능개선_182599 MRP관리자,동/알미늄 환산계수
*추가
*& 2017.05.29   이정익  기능개선_194560 이동유형 166,459,455,457 반영
*& 2017.09.05   엄지희  기능개선_205476 자재별 스크랩 코드 및 단가 추가
*& 2017.11.06   이정익  기능개선_210466 1406 UTP 플랜트 이전 반영
*& 2020.01.06   조영현  기능개선_304563 1307 전력기기 이동문서 제외
*& 2021.02.09   이정익   SRM2102-04681 30일 이전 데이터 추출->원복 처리
*& 2021.02.04   조영현   PJT 케이블반제품 자릿수 증가(7→9)
*& 2023.04.10         오바다         [S/4 HANA PJT] 자재마스터 Conversion 변경
*& 2024.02.02   이정익   1301->1407 무선망 이전
*& 2024.05.08   이정익   SRM2405-02095 시점재고 복사 속도 개선
*&---------------------------------------------------------------------*

REPORT  ZGTPPR9020  MESSAGE-ID  ZPP1
                    NO STANDARD PAGE HEADING.

INCLUDE ZGTPPR9020TOP.       "데이터 및 인터널 테이블/1000번 스크린
INCLUDE ZGTPPR9020O01.       "100번 스크린 PBO
INCLUDE ZGTPPR9020I01.       "100번 스크린 PAI
INCLUDE ZGTPPR9020F01.       "로직
INCLUDE ZGTPPR9020F02.       "ALV
INCLUDE ZGTPPR9020F03.       "query 용

*&---------------------------------------------------------------------*
*& initialization.
*&---------------------------------------------------------------------*
INITIALIZATION.
  PERFORM SET_DEFAULT.          "초기화
  PERFORM SCREEN_MODIFY.

*&---------------------------------------------------------------------*
*& at selection-screen
*&---------------------------------------------------------------------*

AT SELECTION-SCREEN  ON S_PWERK.      "플랜트 클릭 시

  DATA: LV_SPWERK(10) TYPE C,
        LV_NAME       LIKE T001W-NAME1.

  IF NOT S_PWERK IS INITIAL.

    READ TABLE S_PWERK INDEX 1 INTO LV_SPWERK.
    LV_SPWERK = LV_SPWERK+3(4).

    PERFORM SEARCH_TNAME1 USING LV_SPWERK LV_NAME.   "플랜트 내역 조회

    T_NAME1 = LV_NAME.

  ELSE.
    CLEAR : T_NAME1.
  ENDIF.
  PERFORM SCREEN_MODIFY.

AT SELECTION-SCREEN  ON S_MATNR.      "자재 클릭 시

  DATA : LV_MATNR(30) TYPE C,
         LV_MAKTX     LIKE MAKT-MAKTX.

  IF NOT S_MATNR IS INITIAL.

    READ TABLE S_MATNR INDEX 1 INTO LV_MATNR.
    LV_MATNR = LV_MATNR+3(18).

    PERFORM SEARCH_TMAKTX USING LV_MATNR LV_MAKTX.  "자재내역조회

    T_MAKTX = LV_MAKTX.

  ELSE.
    CLEAR : T_MAKTX.
  ENDIF.
  PERFORM SCREEN_MODIFY.

AT SELECTION-SCREEN.

  PERFORM MAKE_OPT.    "재고구분 및 분류그분 체크값에 따른 데이터 생성

  CASE SY-UCOMM.
** DATA 생성
    WHEN 'ONLI'.
      CLEAR : GV_COMMENT, GV_AUTHORITY.
** 권한체크  zppt0000  / sy-UNAME
      PERFORM CHECK_ZPPT0000 USING GV_AUTHORITY.

      IF GV_AUTHORITY = 'X'.
        MESSAGE E003(ZPP1) WITH '해당 권한이 없습니다.'.
        EXIT.
      ELSE.
        IF R_UP = 'X'.

          PERFORM CHECK_DATA.

          IF GV_COMMENT = 'J'.
            PERFORM PROGRESS USING 10 '장기 재고 추출 중...'.
** 장기 재고 추출 ( zppt0149 )
            PERFORM GET_DATA.             "장기재고 추출
            MESSAGE S003(ZPP1) WITH
            '장기 재고 추출 작업이 완료 되었습니다.'.
          ELSE.
            MESSAGE S003(ZPP1) WITH '해당 작업을 취소하였습니다.'.
            EXIT.
          ENDIF.
        ELSE.
** 시점 재고 복사 ( zppt0149j )
          PERFORM CHECK_DATA.

          IF GV_COMMENT = 'J'.
            PERFORM PROGRESS USING 10 '시점 재고 복사 중...'.
            PERFORM MAKE_DATA_Z0149J.
            MESSAGE S003(ZPP1) WITH
            '시점재고 복사 작업이 완료 되었습니다.'.
          ELSE.
            MESSAGE S003(ZPP1) WITH '해당 작업을 취소하였습니다.'.
            EXIT.
          ENDIF.
        ENDIF.
      ENDIF.

** DATA 조회
    WHEN 'FC01' OR 'FC05'.        "기능개선_47570_'FC05'추가 "Data 조회
      CLEAR : GV_AUTHORITY.
      PERFORM AUTHORITY_CHECKING_PROC.  "권한체크

      IF GV_AUTHORITY = 'X'.
      ELSE.
        IF C_BAT_S = '' AND C_BAT_O = '' AND C_BAT_SN = ''
           AND  C_BAT_ON = ''.
          MESSAGE S003(ZPP1) WITH '한가지 재고구분이상 선택해주세요'.
          EXIT.
        ELSEIF C_BRAN_A = '' AND C_BRAN_B = '' AND C_BRAN_C = ''
           AND C_BRAN_D = '' AND C_BRAN_Z = ''.
          MESSAGE S003(ZPP1) WITH '한가지 분류그룹이상 선택해주세요'.
          EXIT.
        ELSE.
          PERFORM PROGRESS USING 10 '데이터 조회 중...'.
          PERFORM SEARCH_DATA.  "조회
        ENDIF.
*-{기능개선_47570_추가
        IF SY-UCOMM EQ 'FC05'.
          FREE MEMORY ID 'ZPPR1000'.
          EXPORT GT_TAB TO MEMORY ID 'ZPPR1000'.
          LEAVE TO CURRENT TRANSACTION.
        ELSE.
*-}기능개선_47570_2014.10.21
          IF GV_NO_DATA = 'X'.
            CLEAR : GV_NO_DATA.
            MESSAGE S003(ZPP1) WITH
            '해당 내용의 데이터가 존재하지 않습니다.'.
            LEAVE LIST-PROCESSING.
          ELSE.
            CALL SCREEN 100.
          ENDIF.
        ENDIF.
      ENDIF.

** 마감 결과(결산수량) 반영
    WHEN 'FC02'.
      CLEAR : GV_AUTHORITY.
** 권한체크  zppt0000  / sy-UNAME
      PERFORM CHECK_ZPPT0000 USING GV_AUTHORITY.
      IF GV_AUTHORITY = 'X'.
        MESSAGE S003(ZPP1) WITH '해당 권한이 없습니다.'.
        EXIT.
      ELSE.
        PERFORM PROGRESS USING 10 '마감 결과 반영 중...'.

*& 2008.09.08 시점재고 삭제로 인하여 자재문서로 시점재고 조회 로직 추가
        IF P_DATE = '20140307'.
          PERFORM UP_STOCK_DEL.
        ELSE.
          PERFORM UP_STOCK.
        ENDIF.

      ENDIF.
** 결산 금액 반영
    WHEN 'FC03'.
      CLEAR : GV_AUTHORITY.
** 권한체크  zppt0000  / sy-UNAME
      PERFORM CHECK_ZPPT0000 USING GV_AUTHORITY.
      IF GV_AUTHORITY = 'X'.
        MESSAGE S003(ZPP1) WITH '해당 권한이 없습니다.'.
        EXIT.
      ELSE.
        PERFORM PROGRESS USING 10 '결산 금액 반영 중...'.
        PERFORM UP_MONEY.
      ENDIF.
** 적송재고
    WHEN 'SD1'.
      PERFORM GO_CONSIGNMENT.
** PC 별 투하자산
    WHEN 'PC'.
      PERFORM GO_PC.
** 월간 시점 재고
    WHEN 'MCBA'.
      PERFORM GO_MCBA.
** 미착원재료
    WHEN 'MM1'.
      PERFORM GO_MM1.

  ENDCASE.

*&---------------------------------------------------------------------*
*& AT SELECTION-SCREEN OUTPUT
*&---------------------------------------------------------------------*
AT SELECTION-SCREEN OUTPUT.
  PERFORM SCREEN_MODIFY.

*&---------------------------------------------------------------------*
*& START-OF-SELECTION                                                  *
*&---------------------------------------------------------------------*
START-OF-SELECTION.


*&---------------------------------------------------------------------*
*& END-OF-SELECTION                                                    *
*&---------------------------------------------------------------------*
END-OF-SELECTION.
