*&---------------------------------------------------------------------*
*& 모듈        : MM
*& 프로그램 ID : ZGTMMR4700
*& 프로그램 명 : 재고수불부(플랜트-저장위치별)
*& 개요   : [가온전선] ZLER0031(T-CODE:ZLE0031T) 복사
*& 생성일 : 2026.07.30
*& 생성자 : ZGODEV04
*&---------------------------------------------------------------------*
*& 외부 호출 프로그램 개요   : N/A
*& 타 시스템 인터페이스 개요 : N/A
*&---------------------------------------------------------------------*
*& 프로그램 수정이력
*&---------------------------------------------------------------------*
*& 수정일  : 2026.08.27
*& 수정자  :
*& 수정개요: 1) TIME_OUT 덤프 방지
*&             - GET_MTO/GET_MTS LOOP 내 SELECT를 Bulk 조회로 개선
*&           2) 非CABLE 자재 AL량(NES=AL) 계산 오류 수정
*&           3) 광량(NES=FI) 컬럼 신규 추가
*&             (QTY1_OPT/JAIGO_OPT/GRTOT_OPT/GITOT_OPT)
*&           4) 표준중량(동량/AL/광량) 컬럼 신규 추가
*&             (STDWT_CU/STDWT_AL/STDWT_OPT)
*&           5) 非CABLE 자재 TVGW 조회조건 수정
*&             (KAPPL/ORG/VTWEG - 실제 마스터데이터 기준)
*&           6) ALV 필드카타로그 FIELDNAME 미설정 오류 수정
*&---------------------------------------------------------------------*

REPORT  ZGTMMR4700 NO STANDARD PAGE HEADING  MESSAGE-ID ZLE1 .

INCLUDE ZGTMMR4700TOP.
INCLUDE ZGTMMR4700ALV.


INITIALIZATION.
  PERFORM SET_LAYOUT(ZLER0002)    CHANGING GS_LAYOUT.

AT SELECTION-SCREEN.
  PERFORM CHECK_INPUT.
** 권한CHECK
  PERFORM AUTHORITY_CHECK.

AT SELECTION-SCREEN OUTPUT.
  PERFORM SELECTION_SCREEN_MODIFY.

START-OF-SELECTION.
  IF GV_FLAG = ' '.
    IF P_SAVE = 'X'.
      PERFORM DATA_QUERY2.
    ELSE.
      PERFORM DATA_QUERY.
    ENDIF.

*{ LSM-AP-PP1-03 - 변경

    IF SY-BATCH = 'X' AND S_WERKS-LOW = '5201'.
      PERFORM SAVE_ZLET0242_DATA.
    ELSEIF SY-BATCH = 'X' AND S_WERKS-LOW = '3402'.
      PERFORM SAVE_ZPPT0263_DATA.
    ELSE.
      PERFORM DATA_DISPLAY.
    ENDIF.
*    PERFORM data_display.
*} LSM-AP-PP1-03 - 변경
  ENDIF.

*&---------------------------------------------------------------------*
*&      Form  init
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM INIT .

  REFRESH: GT_LIST, GT_MSG, GT_ZLET0021,
           R_BUDAT, R_BWART.
  CLEAR  : GT_LIST, GT_MSG, GT_ZLET0021,
           R_BUDAT, R_BWART.

  IF R04 = 'X'.    "일보
    GV_DATE = S_DATE1-LOW.
  ELSE.            "월보
    PERFORM GET_DATE_RANGE.
  ENDIF.

  PERFORM GET_LAST_MONTH.

*/ 이동유형 mapping table zlet0021 에서부터 모든 이동유형을 찾는다.
  PERFORM SELECT_ALL_BWART.

*/ 전일재고
  DATA: LV_DD(2).
  LV_DD = S_DATE1-LOW+6(2).
  IF LV_DD <> '01'.
    R_BUDAT-SIGN   = 'I'.
    R_BUDAT-OPTION = 'BT'.
    CONCATENATE S_DATE1-LOW+0(6) '01' INTO R_BUDAT-LOW.
    R_BUDAT-HIGH = S_DATE1-LOW - 1.
    APPEND R_BUDAT.
  ENDIF.

ENDFORM.                    " init
*&---------------------------------------------------------------------*
*&      Form  selection_screen_modify
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SELECTION_SCREEN_MODIFY .

  IF R04 = 'X'.
    LOOP AT SCREEN.
      CASE SCREEN-NAME.
        WHEN 'S_DATE2-LOW'.
          SCREEN-INPUT  = 0.
      ENDCASE.
      MODIFY SCREEN.
    ENDLOOP.
  ELSE.
    LOOP AT SCREEN.
      CASE SCREEN-NAME.
        WHEN 'S_DATE1-LOW' OR 'S_DATE1-HIGH'.
          SCREEN-INPUT  = 0.
      ENDCASE.
      MODIFY SCREEN.
    ENDLOOP.
  ENDIF.


ENDFORM.                    " selection_screen_modify
*&---------------------------------------------------------------------*
*&      Form  data_query
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM DATA_QUERY .

*/ 초기값 설정
  PERFORM INIT.

*/ 전월재고
  PERFORM GET_PAST_JAGO.

*/ 전일재고
  IF NOT R_BUDAT[] IS INITIAL.
    FIELD_TEXT01 = '전일재고'.
    PERFORM SELECT_MKPF_MSEG TABLES R_BUDAT.
    PERFORM COLLECT_BWART_PAST_DATE.
  ELSE.
    FIELD_TEXT01 = '전월재고'.
  ENDIF.

*/ mkpf, mseg에서부터 데이터를 찾는다.
  PERFORM SELECT_MKPF_MSEG TABLES S_DATE1.

*/ 유형별 데이타를 집계한다.
  PERFORM COLLECT_DATA.

*/ MODIFY
  PERFORM MODIFY_LIST.

*/ ERROR
  IF NOT GT_MSG[] IS INITIAL.
    MESSAGE I000 WITH
     '정의되지 않은 자재문서의 이동유형이 존재합니다.'.
  ENDIF.

ENDFORM.                    " data_query
*&---------------------------------------------------------------------*
*&      Form  GET_DATE_RANGE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_DATE_RANGE .

* 월첫날
  CONCATENATE S_DATE2-LOW '01' INTO GV_DATE.
* 월말
  PERFORM GET_LAST_DAY(ZLER0002)  USING GV_DATE
                     CHANGING GV_LDATE.

  REFRESH: S_DATE1. CLEAR: S_DATE1.
  S_DATE1-SIGN   = 'I'.
  S_DATE1-OPTION = 'BT'.
  S_DATE1-LOW    = GV_DATE.
  S_DATE1-HIGH   = GV_LDATE.
  APPEND S_DATE1.

ENDFORM.                    " GET_DATE_RANGE
*&---------------------------------------------------------------------*
*&      Form  get_last_month
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_LAST_MONTH .

  CALL FUNCTION 'RP_CALC_DATE_IN_INTERVAL'
    EXPORTING
      DATE      = GV_DATE
      DAYS      = '00'
      MONTHS    = '01'
      SIGNUM    = '-'
      YEARS     = '00'
    IMPORTING
      CALC_DATE = GV_DATE.

  GV_LFGJA = GV_DATE+0(4).
  GV_LFMON = GV_DATE+4(2).

  CONCATENATE GV_LFGJA GV_LFMON  INTO P_YYMM.

ENDFORM.                    " get_last_month
*&---------------------------------------------------------------------*
*&      Form  get_past_jago
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_PAST_JAGO .
*/ MARD가 가장 최근, 그리고 MARDH 에서부터 가장 최근이 전월재고

*/ MTS
  PERFORM GET_MTS.

*/ MTO
  PERFORM GET_MTO.

*
*  SORT gt_list.

ENDFORM.                    " get_past_jago
*&---------------------------------------------------------------------*
*&      Form  check_input
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CHECK_INPUT .

* [START] CSR NO : C20081224_76786
  CLEAR : GV_FLAG.
* [END] CSR NO : C20081224_76786

  IF R04 = 'X'.
    DESCRIBE TABLE S_DATE1 LINES GV_LIN.
    IF GV_LIN = 0.
      GV_FLAG = 'X'.
      MESSAGE S000 WITH '날짜를 입력하세요'.
    ENDIF.
    IF S_DATE1-LOW+0(6) <> S_DATE1-HIGH+0(6).
      GV_FLAG = 'X'.
      MESSAGE S000 WITH '동일 년월으로만 조회 가능합니다'.
    ENDIF.
  ELSE.
    IF S_DATE2 IS INITIAL.
      GV_FLAG = 'X'.
      MESSAGE S000 WITH '해당 년 월을 입력하세요'.
    ENDIF.
  ENDIF.

ENDFORM.                    " check_input
*&---------------------------------------------------------------------*
*&      Form  SELECT_ALL_BWART
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SELECT_ALL_BWART .

  SELECT * INTO TABLE GT_ZLET0021
     FROM ZLET0021
    WHERE TYPE IN ('GR01', 'GR02', 'GR03', 'GR04', 'GR05', 'GR06',
                   'GI01', 'GI02', 'GI03', 'GI04', 'GI05', 'GI06',
                   'ZZZZ').

  CLEAR: R_BWART[], R_BWART.
  LOOP AT GT_ZLET0021.
    R_BWART-SIGN   = 'I'.
    R_BWART-OPTION = 'EQ'.
    R_BWART-LOW    = GT_ZLET0021-BWART.
    COLLECT R_BWART.
  ENDLOOP.

* 이동유형 “903/904”, “341/342”, “Z51/Z52” 는 제외한다
  DELETE R_BWART WHERE ( LOW = '903' OR LOW = '904' OR
                         LOW = '341' OR LOW = '342' OR
                         LOW = 'Z51' OR LOW = 'Z52' ).


ENDFORM.                    " SELECT_ALL_BWART
*&---------------------------------------------------------------------*
*&      Form  SELECT_MKPF_MSEG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SELECT_MKPF_MSEG TABLES R_DATE1 LIKE S_DATE1[].
*>> START - Archiving 관련변경 02 -> 20080325
  SELECT P~MBLNR
         P~BWART
         P~KZZUG
         P~KZBEW
         P~SHKZG
         P~SOBKZ
         P~XAUTO
         P~SJAHR
         P~SMBLN
         P~UMSOK
         P~WERKS
         P~UMWRK   "
         P~LGORT
         P~UMLGO   "
         P~MATNR
         P~UMMAT   "
         P~MENGE
         P~BUKRS
         M~MTART
         M~MEINS
    INTO CORRESPONDING FIELDS OF TABLE GT_MSEG
*    FROM mkpf AS k
*     INNER JOIN mseg AS p
*        ON k~mblnr = p~mblnr AND
*           k~mjahr = p~mjahr
    FROM MATDOC AS P
     INNER JOIN MARA AS M
        ON P~MATNR = M~MATNR
    WHERE P~BUDAT IN R_DATE1
      AND P~BWART IN R_BWART
      AND P~WERKS IN S_WERKS
      AND P~LGORT IN S_LGORT
      AND P~MATNR IN S_MATNR
      AND P~MENGE <> 0
      AND P~LGORT <> SPACE
      AND M~MTART IN S_MTART
      AND M~SPART IN S_SPART
      AND M~MATKL IN S_MATKL
      %_HINTS ORACLE 'ORDERED USE_NL(T_00 T_01)'.

*-- 아카이브 체크를 한 경우에만 AS 테이블에서 정보를 가지고 온다.
  IF NOT P_ARCV IS INITIAL.
    SELECT P~MBLNR
           P~BWART
           P~KZZUG
           P~KZBEW
           P~SHKZG
           P~SOBKZ
           P~XAUTO
           P~SJAHR
           P~SMBLN
           P~UMSOK
           P~WERKS
           P~UMWRK   "
           P~LGORT
           P~UMLGO   "
           P~MATNR
           P~UMMAT   "
           P~MENGE
           P~BUKRS
           M~MTART
           M~MEINS
     APPENDING CORRESPONDING FIELDS OF TABLE GT_MSEG
      FROM ZARIXMM1 AS P
       INNER JOIN MARA AS M
          ON P~MATNR = M~MATNR
      WHERE P~BUDAT IN R_DATE1
        AND P~BWART IN R_BWART
        AND P~WERKS IN S_WERKS
        AND P~LGORT IN S_LGORT
        AND P~MATNR IN S_MATNR
        AND P~MENGE <> 0
        AND P~LGORT <> SPACE
        AND M~MTART IN S_MTART
        AND M~SPART IN S_SPART
        AND M~MATKL IN S_MATKL
        %_HINTS ORACLE 'ORDERED USE_NL(T_00 T_01)'.
  ENDIF.
*>> END   - Archiving 관련변경 02 -> 20080325
  LOOP AT GT_MSEG
    WHERE ( BWART = '309' OR BWART = '310' OR
            BWART = '311' OR BWART = '312' OR
            BWART = '313' OR BWART = '314' OR
            BWART = '321' OR BWART = '322' OR
            BWART = '323' OR BWART = '324' OR
            BWART = '325' OR BWART = '326' OR
            BWART = '343' OR BWART = '344' OR
            BWART = '349' OR BWART = '350' OR
            BWART = '413' OR BWART = '414' ).
    IF GT_MSEG-MATNR = GT_MSEG-UMMAT AND
       GT_MSEG-WERKS = GT_MSEG-UMWRK AND
       GT_MSEG-LGORT = GT_MSEG-UMLGO .
      DELETE GT_MSEG.
    ENDIF.
  ENDLOOP.

ENDFORM.                    " SELECT_MKPF_MSEG
*&---------------------------------------------------------------------*
*&      Form  collect_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM COLLECT_DATA .

  DATA: LV_SMBLN TYPE C,
        LV_FLAG  TYPE C,
        LV_COUNT TYPE I,
        LV_MBLNR TYPE MBLNR,
        LV_MJAHR TYPE MJAHR.

  CLEAR: GT_LIST.
  LOOP AT GT_MSEG.
    IF GT_MSEG-SMBLN = ' '.  "원전표 존재유무
      LV_SMBLN = ' '.
*   JS전선 외주재고의 경우 이중역분개 처리
*   by J.Y.Lee 06/25/2012 C20120620_30600
    ELSEIF GT_MSEG-BUKRS = '2000' AND
           ( GT_MSEG-BWART = '541' OR GT_MSEG-BWART = '542' ).
      LV_COUNT = 1.
      LV_MBLNR = GT_MSEG-SMBLN.
      LV_MJAHR = GT_MSEG-SJAHR.

      DO 10 TIMES.
        SELECT SINGLE SMBLN SJAHR
          FROM MATDOC
          INTO (LV_MBLNR, LV_MJAHR)
          WHERE MBLNR = LV_MBLNR
            AND MJAHR = LV_MJAHR.

        IF LV_MBLNR = ' '.
          LV_COUNT = LV_COUNT MOD 2.
          IF LV_COUNT = 0.
            LV_FLAG = 'X'.    "짝수
          ELSE.
            LV_FLAG = ' '.    "홀수
          ENDIF.
          EXIT.
        ELSE.
          LV_COUNT = LV_COUNT + 1.
        ENDIF.
      ENDDO.

      IF LV_FLAG = 'X'.
        LV_SMBLN = ' '.
      ELSE.
        LV_SMBLN = 'X'.
      ENDIF.
    ELSE.
      LV_SMBLN = 'X'.
    ENDIF.
    READ TABLE GT_ZLET0021 WITH KEY BWART = GT_MSEG-BWART "이동유형
                                    KZZUG = GT_MSEG-KZZUG "입고지시자
                                    KZBEW = GT_MSEG-KZBEW "이동지시자
                                    SHKZG = GT_MSEG-SHKZG "차변/대변
                                    SOBKZ = GT_MSEG-SOBKZ "특별재고
                                    XAUTO = GT_MSEG-XAUTO "자동생성
                                    SMBLN = LV_SMBLN      "원전표
                                    UMSOK = GT_MSEG-UMSOK."
    IF SY-SUBRC = 0.
      GT_LIST-WERKS = GT_MSEG-WERKS.
      GT_LIST-LGORT = GT_MSEG-LGORT.
      GT_LIST-MATNR = GT_MSEG-MATNR.
      GT_LIST-MTART = GT_MSEG-MTART.
      GT_LIST-MEINS = GT_MSEG-MEINS.
      IF GT_ZLET0021-CALCU = '-'.
        GT_MSEG-MENGE = GT_MSEG-MENGE * -1.
      ENDIF.
      CASE GT_ZLET0021-TYPE.
        WHEN 'GR01'.  "생산입고
          GT_LIST-GR01 = GT_MSEG-MENGE .
        WHEN 'GR02'.  "구매입고
          GT_LIST-GR02 = GT_MSEG-MENGE.
        WHEN 'GR03'.  "이전입고
          GT_LIST-GR03 = GT_MSEG-MENGE.
        WHEN 'GR04'.  "고객반품
          GT_LIST-GR04 = GT_MSEG-MENGE.
        WHEN 'GR05'.  "위탁회수
          GT_LIST-GR05 = GT_MSEG-MENGE.
        WHEN 'GR06'.  "기타입고
          GT_LIST-GR06 = GT_MSEG-MENGE.
        WHEN 'GI01'.  "판매출고
          GT_LIST-GI01 = GT_MSEG-MENGE.
        WHEN 'GI02'.  "이전출고
          GT_LIST-GI02 = GT_MSEG-MENGE.
        WHEN 'GI03'.  "폐기출고
          GT_LIST-GI03 = GT_MSEG-MENGE.
        WHEN 'GI04'.  "사내소비
          GT_LIST-GI04 = GT_MSEG-MENGE.
        WHEN 'GI05'.  "위탁보충
          GT_LIST-GI05 = GT_MSEG-MENGE.
        WHEN 'GI06'.  "기타출고
          GT_LIST-GI06 = GT_MSEG-MENGE.
      ENDCASE.
      COLLECT GT_LIST. CLEAR: GT_LIST.
    ELSE.
* ERROR
      GT_MSG-MSGTX = GT_MSEG-MBLNR.
      APPEND GT_MSG.
    ENDIF.
  ENDLOOP.

ENDFORM.                    " collect_data
*&---------------------------------------------------------------------*
*&      Form  data_display
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM DATA_DISPLAY .

  GS_VARIANT-REPORT = SY-REPID.
* ALV 출력을 위한 HEADER및 FIELD SETTING
  PERFORM : ALVPRN_BASIC.
  PERFORM : ALVPRN_HEADER USING GT_LIST_TOP_OF_PAGE[].

* 필드 카테고리
  PERFORM MAKE_FIELD_CAT.

* SORT
  PERFORM FIELD_SORT.

* ALV GRID
  PERFORM ALV_GRID.

ENDFORM.                    " data_display
*&---------------------------------------------------------------------*
*&      Form  TOP_OF_PAGE
*&---------------------------------------------------------------------*
*       외부(REUSE_ALV_COMMENTARY_WRITE)에서 CALL한 FORM 문
*&---------------------------------------------------------------------*
FORM TOP_OF_PAGE.

  CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
    EXPORTING
      I_LOGO             = 'ENJOYSAP_LOGO'
      IT_LIST_COMMENTARY = GT_LIST_TOP_OF_PAGE.

ENDFORM.                    "TOP_OF_PAGE
*&------------------------------------------------------------------*
*&      Form  USER_COMMAND
*&------------------------------------------------------------------*
FORM USER_COMMAND USING  P_UCOMM    LIKE SY-UCOMM
                         P_SELFIELD TYPE SLIS_SELFIELD.

  READ TABLE GT_LIST INDEX P_SELFIELD-TABINDEX.
  CASE P_UCOMM.
    WHEN '&IC1'."더블클릭 이벤트 처리.

    WHEN 'REFR'.
      PERFORM DATA_QUERY.
      P_SELFIELD-REFRESH = 'X'.
    WHEN 'ERR'.
      PERFORM ERROR_LOG.
  ENDCASE.


ENDFORM.                    "USER_COMMAND
*&------------------------------------------------------------------*
*&      Form  PF_STATUS_SET
*&------------------------------------------------------------------*
*       외부(REUSE_ALV_EVENTS_GET)에서 CALL한 FORM 문이다.
*-------------------------------------------------------------------*
FORM  PF_STATUS_SET USING RT_EXTAB TYPE SLIS_T_EXTAB.

  SET PF-STATUS 'STANDARD'.
  SET TITLEBAR  '1000'.

ENDFORM.                    "PF_STATUS_SET

*&---------------------------------------------------------------------*
*&      Form  alvprn_basic
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM ALVPRN_BASIC .

* FORM문 발췌함수
  CALL FUNCTION 'REUSE_ALV_EVENTS_GET'
    EXPORTING
      I_LIST_TYPE = 0
    IMPORTING
      ET_EVENTS   = GT_EVENTS.

* FORM문   생성
  PERFORM  FORM_SETTING USING:
           SLIS_EV_PF_STATUS_SET  C_STATUS_SET,
           SLIS_EV_USER_COMMAND   C_USER_COMMAND,
           SLIS_EV_TOP_OF_PAGE    C_TOP_OF_PAGE.

ENDFORM.                    " alvprn_basic
*&---------------------------------------------------------------------*
*&      Form  alvprn_header
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GT_LIST_TOP_OF_PAGE[]  text
*----------------------------------------------------------------------*
FORM ALVPRN_HEADER  USING    P_LIST_TOP_OF_PAGE_T TYPE
                            SLIS_T_LISTHEADER.

  CLEAR: LS_LINE, L_INFO.
  LS_LINE-TYP  = 'H'.
* L_LINE_S-KEY:  NOT USED FOR THIS TYPE
  LS_LINE-INFO = '플랜트/저장위치 재고 수불부'.  .
  APPEND LS_LINE TO P_LIST_TOP_OF_PAGE_T.

  CLEAR: LS_LINE, L_INFO.
  CONCATENATE S_DATE1-LOW '~' S_DATE1-HIGH INTO L_INFO .
  LS_LINE-TYP  = 'S'.
  LS_LINE-KEY  = '기간:'.
  WRITE L_INFO TO L_INFO.
  LS_LINE-INFO = L_INFO.
  APPEND LS_LINE TO P_LIST_TOP_OF_PAGE_T.

  CLEAR: LS_LINE, L_INFO.
  CONCATENATE SY-DATUM+0(4) SY-DATUM+4(2) SY-DATUM+6(2)
    INTO L_INFO SEPARATED BY '.'.
  LS_LINE-TYP  = 'S'.
  LS_LINE-KEY  = '발행일:'.
  WRITE L_INFO TO L_INFO.
  LS_LINE-INFO = L_INFO.
  APPEND LS_LINE TO P_LIST_TOP_OF_PAGE_T.

  CLEAR: LS_LINE, L_INFO.
  CONCATENATE SY-UZEIT+0(2) SY-UZEIT+2(2) SY-UZEIT+4(2)
    INTO L_INFO SEPARATED BY ':'.
  LS_LINE-TYP  = 'S'.
  LS_LINE-KEY  = '발행시간:'.
  WRITE L_INFO TO L_INFO.
  LS_LINE-INFO = L_INFO.
  APPEND LS_LINE TO P_LIST_TOP_OF_PAGE_T.

ENDFORM.                    " alvprn_header
*&---------------------------------------------------------------------*
*&      Form  make_field_cat
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM MAKE_FIELD_CAT .

* FIELD발췌
  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      I_PROGRAM_NAME     = GV_PROGRAM
      I_INTERNAL_TABNAME = 'GT_LIST'
*     I_STRUCTURE_NAME   = ' '
      I_INCLNAME         = GV_PROGRAM
    CHANGING
      CT_FIELDCAT        = GT_FIELD[].

  REFRESH: GT_FIELDCAT[].  CLEAR: GT_FIELDCAT.
  CLEAR: GV_CNT.

  PERFORM FILL_FIELD_CATALOGS
          USING:
                  'S'   'WERKS'       ' ',
                  ' '   'SELTEXT_M'   '플랜트',
                  ' '   'KEY'         'X',
                  'E'   'DDICTXT'     'M',

                  'S'   'NAME1'       ' ',
                  ' '   'SELTEXT_M'   '플랜트명',
                  ' '   'KEY'         'X',
                  'E'   'DDICTXT'     'M',

                  'S'   'LGORT'       ' ',
                  ' '   'SELTEXT_M'   '저장위치',
                  ' '   'KEY'         'X',
                  'E'   'DDICTXT'     'M',

                  'S'   'LGOBE'       ' ',
                  ' '   'SELTEXT_M'   '저장위치명',
                  ' '   'KEY'         'X',
                  'E'   'DDICTXT'     'M',

                  'S'   'PRCTR'       ' ',
                  ' '   'SELTEXT_M'   '손익센터',
                  ' '   'KEY'         'X',
                  'E'   'DDICTXT'     'M',

                  'S'   'MCTXT'       ' ',
                  ' '   'SELTEXT_M'   '손익센터명',
                  ' '   'KEY'         'X',
                  'E'   'DDICTXT'     'M',

                  'S'   'MATNR'       ' ',
                  ' '   'SELTEXT_M'   '자재코드',
                  ' '   'KEY'         'X',
                  'E'   'DDICTXT'     'M',

                  'S'   'MAKTX'       ' ',
                  ' '   'SELTEXT_M'   '자재명',
                  ' '   'KEY'         '',
                  'E'   'DDICTXT'     'M',

                  'S'   'COLOR'       ' ',  "2026.07.30 색상 필드 추가
                  ' '   'SELTEXT_M'   '색상',
                  ' '   'KEY'         '',
                  'E'   'DDICTXT'     'M',

                  'S'   'MTART'       ' ',
                  ' '   'SELTEXT_M'   '자재유형',
                  ' '   'KEY'         '',
                  'E'   'DDICTXT'     'M',

                  'S'   'MEINS'       ' ',
                  ' '   'SELTEXT_M'   '단위',
                  ' '   'KEY'         '',
                  'E'   'DDICTXT'     'M',

                  'S'   'STDWT_CU'       ' ',
                  ' '   'SELTEXT_M'   '표준중량(동량)',
                  ' '   'KEY'         ' ',
                  ' '   'NO_ZERO'     'X',
                  'E'   'DDICTXT'     'M',

                  'S'   'STDWT_AL'       ' ',
                  ' '   'SELTEXT_M'   '표준중량(AL)',
                  ' '   'KEY'         ' ',
                  ' '   'NO_ZERO'     'X',
                  'E'   'DDICTXT'     'M',

                  'S'   'STDWT_OPT'       ' ',
                  ' '   'SELTEXT_M'   '표준중량(광량)',
                  ' '   'KEY'         ' ',
                  ' '   'NO_ZERO'     'X',
                  'E'   'DDICTXT'     'M',

                  'S'   'QTY1'       ' ',
                  ' '   'SELTEXT_M'   FIELD_TEXT01, "'전월재고',
                  ' '   'KEY'         ' ',
                  ' '   'EMPHASIZE'   'C310',
                  ' '   'NO_ZERO'     'X',
                  'E'   'DDICTXT'     'M',

                  'S'   'QTY1_CU'       ' ',
                  ' '   'SELTEXT_M'   '전월재고(동량)',
                  ' '   'KEY'         ' ',
                  ' '   'EMPHASIZE'   'C310',
                  ' '   'NO_ZERO'     'X',
                  'E'   'DDICTXT'     'M',

                  'S'   'QTY1_AL'       ' ',
                  ' '   'SELTEXT_M'   '전월재고(AL량)',
                  ' '   'KEY'         ' ',
                  ' '   'EMPHASIZE'   'C310',
                  ' '   'NO_ZERO'     'X',
                  'E'   'DDICTXT'     'M',

                  'S'   'QTY1_OPT'       ' ',
                  ' '   'SELTEXT_M'   '전월재고(광량)',
                  ' '   'KEY'         ' ',
                  ' '   'EMPHASIZE'   'C310',
                  ' '   'NO_ZERO'     'X',
                  'E'   'DDICTXT'     'M',

                  'S'   'GR01'       ' ',
                  ' '   'SELTEXT_M'   '생산입고',
                  ' '   'KEY'         ' ',
                  ' '   'EMPHASIZE'   'C501',
                  ' '   'NO_ZERO'     'X',
                  'E'   'DDICTXT'     'M',

                  'S'   'GR02'       ' ',
                  ' '   'SELTEXT_M'   '구매입고',
                  ' '   'KEY'         ' ',
                  ' '   'EMPHASIZE'   'C501',
                  ' '   'NO_ZERO'     'X',
                  'E'   'DDICTXT'     'M',

                  'S'   'GR03'       ' ',
                  ' '   'SELTEXT_M'   '이전입고',
                  ' '   'KEY'         ' ',
                  ' '   'EMPHASIZE'   'C501',
                  ' '   'NO_ZERO'     'X',
                  'E'   'DDICTXT'     'M',

                  'S'   'GR04'       ' ',
                  ' '   'SELTEXT_M'   '고객반품',
                  ' '   'KEY'         ' ',
                  ' '   'EMPHASIZE'   'C501',
                  ' '   'NO_ZERO'     'X',
                  'E'   'DDICTXT'     'M',

                  'S'   'GR05'       ' ',
                  ' '   'SELTEXT_M'   '위탁회수',
                  ' '   'KEY'         ' ',
                  ' '   'EMPHASIZE'   'C501',
                  ' '   'NO_ZERO'     'X',
                  'E'   'DDICTXT'     'M',

                  'S'   'GR06'       ' ',
                  ' '   'SELTEXT_M'   '기타입고',
                  ' '   'KEY'         ' ',
                  ' '   'EMPHASIZE'   'C501',
                  ' '   'NO_ZERO'     'X',
                  'E'   'DDICTXT'     'M',

                  'S'   'GRTOT'       ' ',
                  ' '   'SELTEXT_M'   '입고계',
                  ' '   'KEY'         ' ',
                  ' '   'EMPHASIZE'   'C310',
                  ' '   'NO_ZERO'     'X',
                  'E'   'DDICTXT'     'M',

                  'S'   'GRTOT_CU'       ' ',
                  ' '   'SELTEXT_M'   '입고재고(동량)',
                  ' '   'KEY'         ' ',
                  ' '   'EMPHASIZE'   'C310',
                  ' '   'NO_ZERO'     'X',
                  'E'   'DDICTXT'     'M',

                  'S'   'GRTOT_AL'       ' ',
                  ' '   'SELTEXT_M'   '입고재고(AL량)',
                  ' '   'KEY'         ' ',
                  ' '   'EMPHASIZE'   'C310',
                  ' '   'NO_ZERO'     'X',
                  'E'   'DDICTXT'     'M',

                  'S'   'GRTOT_OPT'       ' ',
                  ' '   'SELTEXT_M'   '입고재고(광량)',
                  ' '   'KEY'         ' ',
                  ' '   'EMPHASIZE'   'C310',
                  ' '   'NO_ZERO'     'X',
                  'E'   'DDICTXT'     'M',

                  'S'   'GI01'       ' ',
                  ' '   'SELTEXT_M'   '판매출고',
                  ' '   'KEY'         ' ',
                  ' '   'EMPHASIZE'   'C601',
                  ' '   'NO_ZERO'     'X',
                  'E'   'DDICTXT'     'M',

                  'S'   'GI02'       ' ',
                  ' '   'SELTEXT_M'   '이전출고',
                  ' '   'KEY'         ' ',
                  ' '   'EMPHASIZE'   'C601',
                  ' '   'NO_ZERO'     'X',
                  'E'   'DDICTXT'     'M',

                  'S'   'GI03'       ' ',
                  ' '   'SELTEXT_M'   '폐기출고',
                  ' '   'KEY'         ' ',
                  ' '   'EMPHASIZE'   'C601',
                  ' '   'NO_ZERO'     'X',
                  'E'   'DDICTXT'     'M',

                  'S'   'GI04'       ' ',
                  ' '   'SELTEXT_M'   '사내소비',
                  ' '   'KEY'         ' ',
                  ' '   'EMPHASIZE'   'C601',
                  ' '   'NO_ZERO'     'X',
                  'E'   'DDICTXT'     'M',

                  'S'   'GI05'       ' ',
                  ' '   'SELTEXT_M'   '위탁보충',
                  ' '   'KEY'         ' ',
                  ' '   'EMPHASIZE'   'C601',
                  ' '   'NO_ZERO'     'X',
                  'E'   'DDICTXT'     'M',

                  'S'   'GI06'       ' ',
                  ' '   'SELTEXT_M'   '기타출고',
                  ' '   'KEY'         ' ',
                  ' '   'EMPHASIZE'   'C601',
                  ' '   'NO_ZERO'     'X',
                  'E'   'DDICTXT'     'M',

                  'S'   'GITOT'       ' ',
                  ' '   'SELTEXT_M'   '출고계',
                  ' '   'KEY'         ' ',
                  ' '   'EMPHASIZE'   'C310',
                  ' '   'NO_ZERO'     'X',
                  'E'   'DDICTXT'     'M',

                  'S'   'GITOT_CU'       ' ',
                  ' '   'SELTEXT_M'   '출고재고(동량)',
                  ' '   'KEY'         ' ',
                  ' '   'EMPHASIZE'   'C310',
                  ' '   'NO_ZERO'     'X',
                  'E'   'DDICTXT'     'M',

                  'S'   'GITOT_AL'       ' ',
                  ' '   'SELTEXT_M'   '출고재고(AL량)',
                  ' '   'KEY'         ' ',
                  ' '   'EMPHASIZE'   'C310',
                  ' '   'NO_ZERO'     'X',
                  'E'   'DDICTXT'     'M',

                  'S'   'GITOT_OPT'       ' ',
                  ' '   'SELTEXT_M'   '출고재고(광량)',
                  ' '   'KEY'         ' ',
                  ' '   'EMPHASIZE'   'C310',
                  ' '   'NO_ZERO'     'X',
                  'E'   'DDICTXT'     'M',

                  'S'   'JAIGO'       ' ',
                  ' '   'SELTEXT_M'   '현재고',
                  ' '   'KEY'         ' ',
                  ' '   'EMPHASIZE'   'C320',
                  ' '   'NO_ZERO'     'X',
                  'E'   'DDICTXT'     'M'.
  IF P_SAVE = 'X'.
    PERFORM FILL_FIELD_CATALOGS
         USING:

                 'S'   'JAIGO_AV'       ' ',
                  ' '   'SELTEXT_M'   '현재고(가용)',
                  ' '   'KEY'         ' ',
                  ' '   'EMPHASIZE'   'C320',
                  ' '   'NO_ZERO'     'X',
                  'E'   'DDICTXT'     'M',

                 'S'   'JAIGO_QM'       ' ',
                  ' '   'SELTEXT_M'   '현재고(품질)',
                  ' '   'KEY'         ' ',
                  ' '   'EMPHASIZE'   'C320',
                  ' '   'NO_ZERO'     'X',
                  'E'   'DDICTXT'     'M',


                 'S'   'JAIGO_BO'       ' ',
                  ' '   'SELTEXT_M'   '현재고(보류)',
                  ' '   'KEY'         ' ',
                  ' '   'EMPHASIZE'   'C320',
                  ' '   'NO_ZERO'     'X',
                  'E'   'DDICTXT'     'M'.

  ENDIF.


  PERFORM FILL_FIELD_CATALOGS
          USING:

                  'S'   'JAIGO_CU'       ' ',
                  ' '   'SELTEXT_M'   '현재재고(동량)',
                  ' '   'KEY'         ' ',
                  ' '   'EMPHASIZE'   'C320',
                  ' '   'NO_ZERO'     'X',
                  'E'   'DDICTXT'     'M',


                  'S'   'JAIGO_AL'       ' ',
                  ' '   'SELTEXT_M'   '현재재고(AL량)',
                  ' '   'KEY'         ' ',
                  ' '   'EMPHASIZE'   'C320',
                  ' '   'NO_ZERO'     'X',
                  'E'   'DDICTXT'     'M',


                  'S'   'JAIGO_OPT'       ' ',
                  ' '   'SELTEXT_M'   '현재재고(광량)',
                  ' '   'KEY'         ' ',
                  ' '   'EMPHASIZE'   'C320',
                  ' '   'NO_ZERO'     'X',
                  'E'   'DDICTXT'     'M'.


ENDFORM.                    " make_field_cat
*&---------------------------------------------------------------------*
*&      Form  alv_grid
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM ALV_GRID .

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      I_CALLBACK_PROGRAM      = GV_PROGRAM
      IS_LAYOUT               = GS_LAYOUT
      I_SAVE                  = GV_SAVE
      IS_VARIANT              = GS_VARIANT
      IT_EVENTS               = GT_EVENTS[]
      IT_SORT                 = GT_SORT[]
      IT_FIELDCAT             = GT_FIELDCAT[]
    IMPORTING
      E_EXIT_CAUSED_BY_CALLER = GV_EXIT_CAUSED_BY_CALLER
      ES_EXIT_CAUSED_BY_USER  = GS_EXIT_CAUSED_BY_USER
    TABLES
      T_OUTTAB                = GT_LIST.

ENDFORM.                    " alv_grid
*&---------------------------------------------------------------------*
*&      Form  form_setting
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_SLIS_EV_PF_STATUS_SET  text
*      -->P_C_STATUS_SET  text
*----------------------------------------------------------------------*
FORM FORM_SETTING  USING    P_COM P_FORM.

* 해당  FORM발췌
  DATA : LS_EVENT    TYPE  SLIS_ALV_EVENT.
  READ TABLE    GT_EVENTS  WITH KEY  NAME = P_COM
                            INTO LS_EVENT.
* FORM 생성
  IF   SY-SUBRC EQ 0.
    MOVE     P_FORM      TO   LS_EVENT-FORM.
    MODIFY   GT_EVENTS   FROM LS_EVENT INDEX SY-TABIX.
  ENDIF.

ENDFORM.                    " form_setting
*&---------------------------------------------------------------------*
*&      Form  fill_field_catalogs
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_0913   text
*      -->P_0914   text
*      -->P_0915   text
*----------------------------------------------------------------------*
FORM FILL_FIELD_CATALOGS  USING    P_GUB  P_FNAME  P_VALUE.

*- 'S' -> Structure에 필드 속성 값 Setting을 Start 시점
*- 'E' -> Structure의 내용을 필드 카타로그 테이블에 저장 시점

  IF P_GUB = 'S'.

    CLEAR GS_FIELDCAT.
    READ  TABLE GT_FIELD  INTO GS_FIELDCAT
          WITH KEY FIELDNAME  = P_FNAME.
    GS_FIELDCAT-FIELDNAME = P_FNAME.  "필드명 명시적 설정
                                      "(자동매칭 실패 시 공백 방지)
    ADD 1 TO GV_CNT.
    GS_FIELDCAT-COL_POS = GV_CNT.
    EXIT.

  ENDIF.

*- 출력될 Field 속성을 정의해서 필드 카타로그 테이블에 저장
  DATA L_FNAME(40).
  FIELD-SYMBOLS <FS> TYPE ANY.
  CONCATENATE 'GS_FIELDCAT-' P_FNAME INTO L_FNAME.

  ASSIGN (L_FNAME) TO <FS>.
  <FS> = P_VALUE.

  IF P_GUB = 'E'.

    APPEND GS_FIELDCAT TO GT_FIELDCAT.

  ENDIF.

ENDFORM.                    " fill_field_catalogs
*&---------------------------------------------------------------------*
*&      Form  MODIFY_LIST
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM MODIFY_LIST .

  DELETE GT_LIST WHERE QTY1 = 0
                   AND GR01 = 0
                   AND GR02 = 0
                   AND GR03 = 0
                   AND GR04 = 0
                   AND GR05 = 0
                   AND GR06 = 0
                   AND GI01 = 0
                   AND GI02 = 0
                   AND GI03 = 0
                   AND GI04 = 0
                   AND GI05 = 0
                   AND GI06 = 0.

  CHECK NOT GT_LIST[] IS INITIAL.

  DATA: LT_T001W LIKE T001W OCCURS 0 WITH HEADER LINE.
  DATA: LT_T001L LIKE T001L OCCURS 0 WITH HEADER LINE.
  DATA: LT_MAKT  LIKE MAKT  OCCURS 0 WITH HEADER LINE.

  DATA: BEGIN OF LT_MARC OCCURS 0,
          MATNR LIKE MARC-MATNR,
          WERKS LIKE MARC-WERKS,
          PRCTR LIKE MARC-PRCTR,
        END   OF LT_MARC.

  DATA: BEGIN OF LT_CEPCT OCCURS 0,
          PRCTR LIKE CEPCT-PRCTR,
          MCTXT LIKE CEPCT-MCTXT,
        END   OF LT_CEPCT.

  DATA: LV_COLOR TYPE C LENGTH 2.

  SELECT * INTO TABLE LT_T001W
    FROM T001W.

  SELECT * INTO TABLE LT_T001L
    FROM T001L
     FOR ALL ENTRIES IN GT_LIST
   WHERE WERKS = GT_LIST-WERKS
     AND LGORT = GT_LIST-LGORT.

  SELECT * INTO TABLE LT_MAKT
    FROM MAKT
     FOR ALL ENTRIES IN GT_LIST
   WHERE MATNR = GT_LIST-MATNR.

* 손익센터, 손익센터명 필드 추가 by J.Y.Lee 05/09/2012 C20120503_01853
  SELECT DISTINCT MATNR WERKS PRCTR
    FROM MARC
    INTO TABLE LT_MARC
    FOR ALL ENTRIES IN GT_LIST
    WHERE MATNR = GT_LIST-MATNR
      AND WERKS = GT_LIST-WERKS.
  IF SY-SUBRC = 0.
    SELECT DISTINCT PRCTR MCTXT
      FROM CEPCT
      INTO TABLE LT_CEPCT
      FOR ALL ENTRIES IN LT_MARC
      WHERE SPRAS =  SY-LANGU
        AND PRCTR =  LT_MARC-PRCTR
        AND DATBI >= SY-DATUM.
  ENDIF.

*  색상 필드 추가 2026.07.30
  SELECT MATNR, ATWRT
    FROM ZGTSD_I_MATERIALCHARACTERISTIC
     FOR ALL ENTRIES IN @GT_LIST
   WHERE MATNR EQ @GT_LIST-MATNR
     AND ATNAM EQ 'PD_CA_COLOR_BASE'
    INTO TABLE @DATA(LT_COLOR).


  SORT: LT_MARC  BY MATNR WERKS,
        LT_CEPCT BY PRCTR,
        LT_COLOR BY MATNR.

  LOOP AT GT_LIST.
    CLEAR:LV_COLOR.

    READ TABLE LT_T001W WITH KEY WERKS = GT_LIST-WERKS.
    READ TABLE LT_T001L WITH KEY WERKS = GT_LIST-WERKS
                                 LGORT = GT_LIST-LGORT.
    READ TABLE LT_MAKT  WITH KEY MATNR = GT_LIST-MATNR.

*   손익센터, 손익센터명 필드 추가 by J.Y.Lee 05/09/2012 C20120503_01853
    READ TABLE LT_MARC  WITH KEY MATNR = GT_LIST-MATNR
                                 WERKS = GT_LIST-WERKS BINARY SEARCH.
    READ TABLE LT_CEPCT WITH KEY PRCTR = LT_MARC-PRCTR BINARY SEARCH.

*  색상 필드 추가 2026.07.30
    READ TABLE LT_COLOR ASSIGNING FIELD-SYMBOL(<LS_COLOR>)
                                          WITH KEY MATNR = GT_LIST-MATNR
                                          BINARY SEARCH.
    IF SY-SUBRC EQ 0.
      LV_COLOR = CONV CHAR2( <LS_COLOR>-ATWRT ).
    ENDIF.

    GT_LIST-NAME1 = LT_T001W-NAME1.
    GT_LIST-LGOBE = LT_T001L-LGOBE.
    GT_LIST-MAKTX = LT_MAKT-MAKTX.
    GT_LIST-PRCTR = LT_MARC-PRCTR.   "손익센터
    GT_LIST-MCTXT = LT_CEPCT-MCTXT.  "손익센터명
    GT_LIST-COLOR = LV_COLOR. "색상

    GT_LIST-GRTOT = GT_LIST-GR01 + GT_LIST-GR02 + GT_LIST-GR03 +
                    GT_LIST-GR04 + GT_LIST-GR05 + GT_LIST-GR06 .
    GT_LIST-GITOT = GT_LIST-GI01 + GT_LIST-GI02 + GT_LIST-GI03 +
                    GT_LIST-GI04 + GT_LIST-GI05 + GT_LIST-GI06 .

    GT_LIST-JAIGO = GT_LIST-QTY1 + GT_LIST-GRTOT - GT_LIST-GITOT.

* 재고상태별 재고수량에 대한 동량계산. 070514 SDB01

    IF ( GT_LIST-MTART = 'MCFE'  OR
         GT_LIST-MTART = 'MCHA'  OR
         GT_LIST-MTART = 'MCHF'  ).  "CABLE인 것만
      PERFORM CALC_NFM_QTY.
    ENDIF.

    MODIFY GT_LIST.
    CLEAR LT_CEPCT.
  ENDLOOP.



ENDFORM.                    " MODIFY_LIST
*&---------------------------------------------------------------------*
*&      Form  FIELD_SORT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM FIELD_SORT .

  GS_SORT-FIELDNAME = 'WERKS'.
  GS_SORT-SPOS      = '1'.
  GS_SORT-UP        = 'X'.
  APPEND GS_SORT TO GT_SORT.

  GS_SORT-FIELDNAME = 'NAME1'.
  GS_SORT-SPOS      = '1'.
  GS_SORT-UP        = 'X'.
  APPEND GS_SORT TO GT_SORT.

  GS_SORT-FIELDNAME = 'LGORT'.
  GS_SORT-SPOS      = '2'.
  GS_SORT-UP        = 'X'.
  APPEND GS_SORT TO GT_SORT.

  GS_SORT-FIELDNAME = 'LGOBE'.
  GS_SORT-SPOS      = '2'.
  GS_SORT-UP        = 'X'.
  APPEND GS_SORT TO GT_SORT.

  GS_SORT-FIELDNAME = 'PRCTR'.
  GS_SORT-SPOS      = '3'.
  GS_SORT-UP        = 'X'.
  APPEND GS_SORT TO GT_SORT.

  GS_SORT-FIELDNAME = 'MCTXT'.
  GS_SORT-SPOS      = '3'.
  GS_SORT-UP        = 'X'.
  APPEND GS_SORT TO GT_SORT.

ENDFORM.                    " FIELD_SORT
*&---------------------------------------------------------------------*
*&      Form  COLLECT_BWART_PAST_DATE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM COLLECT_BWART_PAST_DATE .

  DATA: LV_SMBLN.

  CLEAR: GT_LIST.
  LOOP AT GT_MSEG.
    IF GT_MSEG-SMBLN = ' '.  "원전표 존재유무
      LV_SMBLN = ' '.
    ELSE.
      LV_SMBLN = 'X'.
    ENDIF.
    READ TABLE GT_ZLET0021 WITH KEY BWART = GT_MSEG-BWART "이동유형
                                    KZZUG = GT_MSEG-KZZUG "입고지시자
                                    KZBEW = GT_MSEG-KZBEW "이동지시자
                                    SHKZG = GT_MSEG-SHKZG "차변/대변
                                    SOBKZ = GT_MSEG-SOBKZ "특별재고
                                    XAUTO = GT_MSEG-XAUTO "자동생성
                                    SMBLN = LV_SMBLN      "원전표
                                    UMSOK = GT_MSEG-UMSOK."
    IF SY-SUBRC = 0.
      GT_LIST-WERKS = GT_MSEG-WERKS.
      GT_LIST-LGORT = GT_MSEG-LGORT.
      GT_LIST-MATNR = GT_MSEG-MATNR.
      GT_LIST-MTART = GT_MSEG-MTART.
      GT_LIST-MEINS = GT_MSEG-MEINS.
      IF GT_ZLET0021-CALCU = '-'.
        GT_MSEG-MENGE = GT_MSEG-MENGE * -1.
      ENDIF.
      CASE GT_ZLET0021-TYPE.
        WHEN 'GR01' OR  "생산입고
             'GR02' OR  "구매입고
             'GR03' OR  "이전입고
             'GR04' OR  "고객반품
             'GR05' OR  "위탁회수
             'GR06' .   "기타입고
          GT_LIST-QTY1 = GT_MSEG-MENGE.
        WHEN 'GI01' OR  "판매출고
             'GI02' OR  "이전출고
             'GI03' OR  "폐기출고
             'GI04' OR  "사내소비
             'GI05' OR  "위탁보충
             'GI06' .   "기타출고
          GT_LIST-QTY1 = GT_MSEG-MENGE * -1.
      ENDCASE.
      COLLECT GT_LIST. CLEAR: GT_LIST.
    ELSE.
* ERROR
      GT_MSG-MSGTX = GT_MSEG-MBLNR.
      APPEND GT_MSG.
    ENDIF.
  ENDLOOP.

ENDFORM.                    " COLLECT_BWART_PAST_DATE
*&---------------------------------------------------------------------*
*&      Form  ERROR_LOG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM ERROR_LOG .

  IF NOT GT_MSG[] IS INITIAL.
    CALL FUNCTION 'Z_LE_POPUP_TO_ERROR_MESSAGE'
      TABLES
        MSG_TAB = GT_MSG.
  ELSE.
    MESSAGE S000 WITH '오류 문서가 없습니다'.
  ENDIF.

ENDFORM.                    " ERROR_LOG
*&---------------------------------------------------------------------*
*&      Form  GET_MTS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_MTS .

  SELECT D~WERKS
         D~LGORT
         D~MATNR
         D~LFGJA
         D~LFMON
         D~LABST
         D~INSME
         D~SPEME
         D~EINME
         M~MTART
         M~MEINS
    INTO CORRESPONDING FIELDS OF TABLE GT_MARD
    FROM MARD AS D
     INNER JOIN MARA AS M
        ON D~MATNR = M~MATNR
    WHERE D~WERKS IN S_WERKS
      AND D~LGORT IN S_LGORT
      AND D~MATNR IN S_MATNR
      AND M~MTART IN S_MTART
      AND M~SPART IN S_SPART
      AND M~MATKL IN S_MATKL.

  " TIME_OUT 방지 - LOOP 진입 전 MARDH를 1회만 Bulk 조회
  IF GT_MARD[] IS NOT INITIAL.
    SELECT * FROM MARDH
      INTO TABLE GT_MARDH_ALL
      FOR ALL ENTRIES IN GT_MARD
      WHERE MATNR = GT_MARD-MATNR
        AND WERKS = GT_MARD-WERKS
        AND LGORT = GT_MARD-LGORT
        AND ( ( LFGJA = GV_LFGJA AND LFMON => GV_LFMON )
          OR  ( LFGJA > GV_LFGJA ) ).
  ENDIF.

  LOOP AT GT_MARD.
    CONCATENATE GT_MARD-LFGJA GT_MARD-LFMON INTO GV_YEARMON.
    IF P_YYMM => GV_YEARMON.
      GT_LIST-WERKS = GT_MARD-WERKS.
      GT_LIST-LGORT = GT_MARD-LGORT.
      GT_LIST-MATNR = GT_MARD-MATNR.
      GT_LIST-MTART = GT_MARD-MTART.
      GT_LIST-MEINS = GT_MARD-MEINS.
      GT_LIST-QTY1  = GT_MARD-LABST + GT_MARD-INSME +
                      GT_MARD-SPEME + GT_MARD-EINME.
      COLLECT GT_LIST. CLEAR: GT_LIST.
    ELSE.
      " DB SELECT 대신 Bulk 조회해 둔 정렬 테이블에서 검색
      "   (SORTED TABLE Leading Key는 자동 이진탐색 - BINARY SEARCH 옵션 사용불가)
      READ TABLE GT_MARDH_ALL INTO GT_MARDH
        WITH KEY MATNR = GT_MARD-MATNR
                 WERKS = GT_MARD-WERKS
                 LGORT = GT_MARD-LGORT.
      IF SY-SUBRC = 0.
        GT_LIST-WERKS = GT_MARD-WERKS.
        GT_LIST-LGORT = GT_MARD-LGORT.
        GT_LIST-MATNR = GT_MARD-MATNR.
        GT_LIST-MTART = GT_MARD-MTART.
        GT_LIST-MEINS = GT_MARD-MEINS.
        GT_LIST-QTY1  = GT_MARDH-LABST + GT_MARDH-INSME +
                        GT_MARDH-SPEME + GT_MARDH-EINME.
        COLLECT GT_LIST. CLEAR: GT_LIST, GT_MARDH.
      ENDIF.
    ENDIF.
  ENDLOOP.

ENDFORM.                    " GET_MTS
*&---------------------------------------------------------------------*
*&      Form  GET_MTO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_MTO .

  SELECT D~WERKS
         D~LGORT
         D~MATNR
         D~CHARG
         D~SOBKZ
         D~VBELN
         D~POSNR
         D~LFGJA
         D~LFMON
         D~KALAB
         D~KAINS
         D~KASPE
         D~KAEIN
         M~MTART
         M~MEINS
    INTO CORRESPONDING FIELDS OF TABLE GT_MSKA
    FROM MSKA AS D
     INNER JOIN MARA AS M
        ON D~MATNR = M~MATNR
    WHERE D~SOBKZ = 'E'
      AND D~WERKS IN S_WERKS
      AND D~LGORT IN S_LGORT
      AND D~MATNR IN S_MATNR
      AND M~MTART IN S_MTART
      AND M~SPART IN S_SPART
      AND M~MATKL IN S_MATKL.

  " TIME_OUT 방지 - LOOP 진입 전 MSKAH를 1회만 Bulk 조회
  "   (ST22: GET_MTO 1384행 TIME_OUT / ST12: MSKAH 1,717회 94.6%)
  IF GT_MSKA[] IS NOT INITIAL.
    SELECT * FROM MSKAH
      INTO TABLE GT_MSKAH_ALL
      FOR ALL ENTRIES IN GT_MSKA
      WHERE MATNR = GT_MSKA-MATNR
        AND WERKS = GT_MSKA-WERKS
        AND LGORT = GT_MSKA-LGORT
        AND CHARG = GT_MSKA-CHARG
        AND SOBKZ = GT_MSKA-SOBKZ
        AND VBELN = GT_MSKA-VBELN
        AND POSNR = GT_MSKA-POSNR
        AND ( ( LFGJA = GV_LFGJA AND LFMON => GV_LFMON )
          OR  ( LFGJA > GV_LFGJA ) ).
  ENDIF.

  LOOP AT GT_MSKA.
    CONCATENATE GT_MSKA-LFGJA GT_MSKA-LFMON INTO GV_YEARMON.
    IF P_YYMM => GV_YEARMON.
      GT_LIST-WERKS = GT_MSKA-WERKS.
      GT_LIST-LGORT = GT_MSKA-LGORT.
      GT_LIST-MATNR = GT_MSKA-MATNR.
      GT_LIST-MTART = GT_MSKA-MTART.
      GT_LIST-MEINS = GT_MSKA-MEINS.
      GT_LIST-QTY1  = GT_MSKA-KALAB + GT_MSKA-KAINS +
                      GT_MSKA-KASPE + GT_MSKA-KAEIN.
      COLLECT GT_LIST. CLEAR: GT_LIST.
    ELSE.
      " DB SELECT 대신 Bulk 조회해 둔 정렬 테이블에서 검색
      "   (SORTED TABLE Leading Key는 자동 이진탐색 - BINARY SEARCH 옵션 사용불가)
      READ TABLE GT_MSKAH_ALL INTO GT_MSKAH
        WITH KEY MATNR = GT_MSKA-MATNR
                 WERKS = GT_MSKA-WERKS
                 LGORT = GT_MSKA-LGORT
                 CHARG = GT_MSKA-CHARG
                 SOBKZ = GT_MSKA-SOBKZ
                 VBELN = GT_MSKA-VBELN
                 POSNR = GT_MSKA-POSNR.
      IF SY-SUBRC = 0.
        GT_LIST-WERKS = GT_MSKA-WERKS.
        GT_LIST-LGORT = GT_MSKA-LGORT.
        GT_LIST-MATNR = GT_MSKA-MATNR.
        GT_LIST-MTART = GT_MSKA-MTART.
        GT_LIST-MEINS = GT_MSKA-MEINS.
        GT_LIST-QTY1  = GT_MSKAH-KALAB + GT_MSKAH-KAINS +
                        GT_MSKAH-KASPE + GT_MSKAH-KAEIN.
        COLLECT GT_LIST. CLEAR: GT_LIST, GT_MSKAH.
      ENDIF.
    ENDIF.
  ENDLOOP.

ENDFORM.                    " GET_MTO
*&---------------------------------------------------------------------*
*&      Form  authority_check
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM AUTHORITY_CHECK .
  DATA: GT_T001W LIKE T001W OCCURS 0 WITH HEADER LINE,
        LV_SUBRC LIKE SY-SUBRC.

  SELECT *
    INTO TABLE GT_T001W
    FROM T001W
   WHERE WERKS IN S_WERKS.

  LOOP  AT  GT_T001W.
    CALL FUNCTION 'Z_LE_AUTHORIZATION_CHECK'
      EXPORTING
        I_WERKS = GT_T001W-WERKS
        I_TYPE  = '1'
      IMPORTING
        E_SUBRC = LV_SUBRC.

    IF LV_SUBRC <> 0.
      MESSAGE E002(ZSD1) WITH '플랜트에 대한 권한이 없읍니다'
                        GT_T001W-WERKS.
    ENDIF.
  ENDLOOP.

ENDFORM.                    " authority_check
*&---------------------------------------------------------------------*
*&      Form  CALC_NFM_QTY
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CALC_NFM_QTY .
  DATA: L_VGW_TBL LIKE /NFM/TVGW OCCURS 0 WITH HEADER LINE,
        L_KGW_TBL LIKE /NFM/TKGW OCCURS 0 WITH HEADER LINE.


  REFRESH: L_VGW_TBL,
           L_KGW_TBL.

  IF ( GT_LIST-MTART = 'MCFE'  OR
       GT_LIST-MTART = 'MCHF'  ).  "CABLE인 것만

    CALL FUNCTION '/NFM/TKGW_SELECT'
      EXPORTING
        I_MATNR   = GT_LIST-MATNR
        I_WERKS   = GT_LIST-WERKS
      TABLES
        T_KGW     = L_KGW_TBL
      EXCEPTIONS
        NOT_FOUND = 1
        OTHERS    = 2.
    CHECK SY-SUBRC = 0.

    LOOP AT L_KGW_TBL WHERE NES = 'CU'.

      IF  NOT L_KGW_TBL-KGU IS INITIAL.
        GT_LIST-STDWT_CU = L_KGW_TBL-KGW.   " 표준중량(동량)
        GT_LIST-QTY1_CU = GT_LIST-QTY1 * L_KGW_TBL-KGW /
                                         L_KGW_TBL-KGU.
        GT_LIST-JAIGO_CU = GT_LIST-JAIGO * L_KGW_TBL-KGW /
                                           L_KGW_TBL-KGU.
        GT_LIST-GRTOT_CU = GT_LIST-GRTOT * L_KGW_TBL-KGW /
                                         L_KGW_TBL-KGU.
        GT_LIST-GITOT_CU = GT_LIST-GITOT * L_KGW_TBL-KGW /
                                           L_KGW_TBL-KGU.
      ENDIF.
    ENDLOOP.

    LOOP AT L_KGW_TBL WHERE NES = 'AL'.
      IF  NOT L_KGW_TBL-KGU IS INITIAL.
        GT_LIST-STDWT_AL = L_KGW_TBL-KGW.   " 표준중량(AL)
        GT_LIST-QTY1_AL  = GT_LIST-QTY1 * L_KGW_TBL-KGW /
                                          L_KGW_TBL-KGU.
        GT_LIST-JAIGO_AL = GT_LIST-JAIGO * L_KGW_TBL-KGW /
                                           L_KGW_TBL-KGU.
        GT_LIST-GRTOT_AL = GT_LIST-GRTOT * L_KGW_TBL-KGW /
                                           L_KGW_TBL-KGU.
        GT_LIST-GITOT_AL = GT_LIST-GITOT * L_KGW_TBL-KGW /
                                           L_KGW_TBL-KGU.
      ENDIF.
    ENDLOOP.

    " 광량 (NES = 'FI')
    LOOP AT L_KGW_TBL WHERE NES = 'FI'.
      IF  NOT L_KGW_TBL-KGU IS INITIAL.
        GT_LIST-STDWT_OPT = L_KGW_TBL-KGW.   " 표준중량(광량)
        GT_LIST-QTY1_OPT  = GT_LIST-QTY1 * L_KGW_TBL-KGW /
                                           L_KGW_TBL-KGU.
        GT_LIST-JAIGO_OPT = GT_LIST-JAIGO * L_KGW_TBL-KGW /
                                            L_KGW_TBL-KGU.
        GT_LIST-GRTOT_OPT = GT_LIST-GRTOT * L_KGW_TBL-KGW /
                                            L_KGW_TBL-KGU.
        GT_LIST-GITOT_OPT = GT_LIST-GITOT * L_KGW_TBL-KGW /
                                            L_KGW_TBL-KGU.
      ENDIF.
    ENDLOOP.

  ELSE.

    CALL FUNCTION '/NFM/TVGW_SELECT'
      EXPORTING
        I_PARNR   = ''
        I_MATNR   = GT_LIST-MATNR
        I_KAPPL   = 'V'      "실제 마스터데이터 기준(KAPPL='V')
        I_ORG     = '6000'   "실제 마스터데이터 기준(ORG='6000')
        I_WERKS   = ''       "플랜트 조건 없음(전체 대상)
        I_VTWEG   = '10'     "실제 마스터데이터 기준(VTWEG='10')
      TABLES
        T_VGW     = L_VGW_TBL
      EXCEPTIONS
        NOT_FOUND = 1
        OTHERS    = 2.

    CHECK SY-SUBRC = 0.

    LOOP AT L_VGW_TBL WHERE NES = 'CU'.

      IF  NOT L_VGW_TBL-VGE IS INITIAL.
        GT_LIST-STDWT_CU = L_VGW_TBL-VGW.   " 표준중량(동량)
        GT_LIST-QTY1_CU = GT_LIST-QTY1 * L_VGW_TBL-VGW /
                                         L_VGW_TBL-VGE.
        GT_LIST-JAIGO_CU = GT_LIST-JAIGO * L_VGW_TBL-VGW /
                                           L_VGW_TBL-VGE.
        GT_LIST-GRTOT_CU = GT_LIST-GRTOT * L_VGW_TBL-VGW /
                                           L_VGW_TBL-VGE.
        GT_LIST-GITOT_CU = GT_LIST-GITOT * L_VGW_TBL-VGW /
                                           L_VGW_TBL-VGE.
      ENDIF.
    ENDLOOP.

    LOOP AT L_VGW_TBL WHERE NES = 'AL'.
      IF  NOT L_VGW_TBL-VGE IS INITIAL.
        GT_LIST-STDWT_AL = L_VGW_TBL-VGW.   " 표준중량(AL)
        GT_LIST-QTY1_AL = GT_LIST-QTY1 * L_VGW_TBL-VGW /
                                         L_VGW_TBL-VGE.
        GT_LIST-JAIGO_AL = GT_LIST-JAIGO * L_VGW_TBL-VGW /
                                           L_VGW_TBL-VGE.
        GT_LIST-GRTOT_AL = GT_LIST-GRTOT * L_VGW_TBL-VGW /
                                           L_VGW_TBL-VGE.
        GT_LIST-GITOT_AL = GT_LIST-GITOT * L_VGW_TBL-VGW /
                                           L_VGW_TBL-VGE.
      ENDIF.
    ENDLOOP.

    " 광량 (NES = 'FI')
    LOOP AT L_VGW_TBL WHERE NES = 'FI'.
      IF  NOT L_VGW_TBL-VGE IS INITIAL.
        GT_LIST-STDWT_OPT = L_VGW_TBL-VGW.   " 표준중량(광량)
        GT_LIST-QTY1_OPT = GT_LIST-QTY1 * L_VGW_TBL-VGW /
                                          L_VGW_TBL-VGE.
        GT_LIST-JAIGO_OPT = GT_LIST-JAIGO * L_VGW_TBL-VGW /
                                            L_VGW_TBL-VGE.
        GT_LIST-GRTOT_OPT = GT_LIST-GRTOT * L_VGW_TBL-VGW /
                                            L_VGW_TBL-VGE.
        GT_LIST-GITOT_OPT = GT_LIST-GITOT * L_VGW_TBL-VGW /
                                            L_VGW_TBL-VGE.
      ENDIF.
    ENDLOOP.

  ENDIF.

ENDFORM.                    " CALC_NFM_QTY
*&---------------------------------------------------------------------*
*&      Form  SAVE_ZPPT0263_DATA
*&---------------------------------------------------------------------*
*       LSM-AP-PP1-03 - 추가
*----------------------------------------------------------------------*
FORM SAVE_ZPPT0263_DATA .
  DATA: LT_0263     LIKE ZPPT0263 OCCURS 0 WITH HEADER LINE.

  DATA: LV_DATUM LIKE SY-DATUM,
        LV_ERSDA LIKE SY-DATUM.

  CHECK R04 = 'X'.   "일보인 경우만 저장

  CLEAR   : LT_0263.
  REFRESH : LT_0263.

  LV_ERSDA = S_DATE1-HIGH.

*___현재일 기준 3개월 이전 일자
  CALL FUNCTION 'HR_PT_ADD_MONTH_TO_DATE'
    EXPORTING
      DMM_DATIN = LV_ERSDA
      DMM_COUNT = '3'
      DMM_OPER  = '-'
      DMM_POS   = ''
    IMPORTING
      DMM_DAOUT = LV_DATUM.

  LOOP AT GT_LIST.
    CLEAR : LT_0263.

    LT_0263-MATNR = GT_LIST-MATNR.     "자재 번호
    LT_0263-WERKS = GT_LIST-WERKS.     "플랜트
    LT_0263-LGORT = GT_LIST-LGORT.     "저장 위치
    LT_0263-MEINS = GT_LIST-MEINS.     "기본 단위
    LT_0263-LABST = GT_LIST-JAIGO.     "평가된 사용가능 재고
    LT_0263-PRDGR = GT_LIST-GR01.      "생산입고
    LT_0263-PURGR = GT_LIST-GR02.      "구매입고
    LT_0263-SALGI = GT_LIST-GI01.      "판매출고
    LT_0263-CONSM = GT_LIST-GI05.      "위탁보충
    LT_0263-OTHGI = GT_LIST-GI06.      "기타출고

    COLLECT LT_0263.
  ENDLOOP.

*___3개월 이전 데이터 삭제
  DELETE FROM ZPPT0263 WHERE ERSDA <= LV_DATUM.

  IF LT_0263[] IS NOT INITIAL.
    LT_0263-LFGJA = LV_ERSDA(4).       "현재기간 회계연도
    LT_0263-LFMON = LV_ERSDA+4(2).     "현재 기간 (전기기간)
    LT_0263-ERSDA = LV_ERSDA.          "생성일
    MODIFY LT_0263 TRANSPORTING LFGJA LFMON ERSDA
                   WHERE MATNR IS NOT INITIAL.

    MODIFY ZPPT0263 FROM TABLE LT_0263.
    IF SY-SUBRC = 0.
      COMMIT WORK.

      MESSAGE S004 WITH '[AP] 일별 재고현황이 저장되었습니다.'.
    ELSE.
      ROLLBACK WORK.

      MESSAGE S004 DISPLAY LIKE 'E'
         WITH '[AP] 일별 재고현황 저장 실패.'.
    ENDIF.
  ENDIF.

ENDFORM.                    " SAVE_ZPPT0263_DATA
*&---------------------------------------------------------------------*
*&      Form  SAVE_ZLET0242_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SAVE_ZLET0242_DATA .


  DATA: LV_DATUM LIKE SY-DATUM,
        LV_ERSDA LIKE SY-DATUM.

  CHECK R04 = 'X'.   "일보인 경우만 저장
  CHECK GT_LIST[] IS NOT INITIAL.


  LV_ERSDA = S_DATE1-HIGH.

*___현재일 기준 3개월 이전 일자
  CALL FUNCTION 'HR_PT_ADD_MONTH_TO_DATE'
    EXPORTING
      DMM_DATIN = LV_ERSDA
      DMM_COUNT = '3'
      DMM_OPER  = '-'
      DMM_POS   = ''
    IMPORTING
      DMM_DAOUT = LV_DATUM.

  LOOP AT GT_LIST.
    MOVE-CORRESPONDING GT_LIST TO GT_ZLET0242.
    READ TABLE GT_MARD WITH KEY WERKS = GT_ZLET0242-WERKS
                                LGORT = GT_ZLET0242-LGORT
                                MATNR = GT_ZLET0242-MATNR.
    IF SY-SUBRC = 0.
      GT_ZLET0242-JAIGO_AV = GT_MARD-LABST.
      GT_ZLET0242-JAIGO_QM = GT_MARD-INSME.
      GT_ZLET0242-JAIGO_BO = GT_MARD-SPEME.
    ENDIF.
    APPEND GT_ZLET0242. CLEAR : GT_ZLET0242.
  ENDLOOP.

*___3개월 이전 데이터 삭제
  DELETE FROM ZLET0242 WHERE TDATE <= LV_DATUM.

  GT_ZLET0242-TDATE = S_DATE1-LOW.
  MODIFY GT_ZLET0242 TRANSPORTING TDATE
                 WHERE MATNR IS NOT INITIAL.

  MODIFY ZLET0242 FROM TABLE GT_ZLET0242.
  IF SY-SUBRC = 0.
    COMMIT WORK.
    MESSAGE S004 WITH '[AP] 일별 재고현황이 저장되었습니다.'.
  ELSE.
    ROLLBACK WORK.
    MESSAGE S004 DISPLAY LIKE 'E'
       WITH '[AP] 일별 재고현황 저장 실패.'.
  ENDIF.


ENDFORM.                    " SAVE_ZLET0242_DATA
*&---------------------------------------------------------------------*
*&      Form  DATA_QUERY2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM DATA_QUERY2 .

*
*SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE text-001.
*SELECT-OPTIONS: s_werks FOR mseg-werks
*              MEMORY ID wrk OBLIGATORY.  "플랜트
*SELECT-OPTIONS: s_lgort FOR mseg-lgort.  "저장위치
*SELECT-OPTIONS: s_mtart FOR mara-mtart.  "자재유형
*SELECT-OPTIONS: s_spart FOR mara-spart.  "제품군
*SELECT-OPTIONS: s_matkl FOR mara-matkl.  "자재그룹
*SELECT-OPTIONS: s_matnr FOR mard-matnr.  "자재
*
**>> START - Archiving 관련변경 01 -> 20080325
*SELECTION-SCREEN SKIP 1.
**-- TEXT: '아카이브 데이터 포함'
*PARAMETER : P_ARCV AS CHECKBOX.
**>> END   - Archiving 관련변경 01 -> 20080325
*SELECTION-SCREEN END   OF BLOCK b1.
*
  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE GT_LIST
    FROM ZLET0242
    WHERE WERKS IN S_WERKS
    AND   LGORT IN S_LGORT
    AND   MATNR IN S_MATNR
    AND   MTART IN S_MTART
    AND   TDATE IN S_DATE1.


ENDFORM.                    " DATA_QUERY2
