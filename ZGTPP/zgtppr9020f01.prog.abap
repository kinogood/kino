*&---------------------------------------------------------------------*
*&  Include           ZPPR1000F01                                      *
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  SET_DEFAULT
*&---------------------------------------------------------------------*
*       text : 초기화
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SET_DEFAULT .

  MOVE 'Data 조회'             TO   SSCRFIELDS-FUNCTXT_01.
  MOVE '마감 결과 반영'        TO   SSCRFIELDS-FUNCTXT_02.
  MOVE '결산 금액 반영'        TO   SSCRFIELDS-FUNCTXT_03.
  MOVE '적송재고'              TO   SSCRFIELDS-FUNCTXT_04.
  BUTTON1 = 'PC별투하자산'.
  BUTTON2 = '월간시점재고'.
  BUTTON3 = '적송재고'.
  BUTTON4 = '미착원재료'.

  P_DATE = SY-DATUM.

ENDFORM.                    " SET_DEFAULT
*&---------------------------------------------------------------------*
*&      Form  SCREEN_MODIFY
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SCREEN_MODIFY .

  LOOP AT SCREEN.
    IF SCREEN-GROUP1 = 'ABC'.
      SCREEN-INPUT = 0.
      SCREEN-INTENSIFIED = 1.
      MODIFY SCREEN.
    ENDIF.
  ENDLOOP.

ENDFORM.                    " SCREEN_MOD

*&---------------------------------------------------------------------*
*&      Form  GET_DATA
*&---------------------------------------------------------------------*
*       text : 데이터 추출
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_DATA .
**창고 기본 재고 정보 조회
  CLEAR : TEMP_MATDOC, TEMP_MATDOC[], TEMP1, TEMP1[], TEMP2, TEMP2[],
          TEMP3, TEMP3[], TEMP4, TEMP4[], TEMP_0149J, TEMP_0149J[].

** zppt0149j 데이터 가져오기
  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE TEMP_0149J
    FROM ZPPT0149J
   WHERE MDATE = P_DATE
     AND WERKS IN S_PWERK
     AND MATNR IN S_MATNR
     AND STOCKMAF > 0.

  LOOP AT TEMP_0149J.
    IF TEMP_0149J-GUBUN = '10'.     "배치관리 하지 않는 재고
      MOVE-CORRESPONDING TEMP_0149J TO TEMP1.
      APPEND TEMP1.
      CLEAR  TEMP1.

    ELSEIF TEMP_0149J-GUBUN = '21'.
      "배치재고데이터 배치 유형 B,C가 아닌 경우
      MOVE-CORRESPONDING TEMP_0149J TO TEMP3.
      APPEND TEMP3.
      CLEAR  TEMP3.

    ELSEIF TEMP_0149J-GUBUN = '22'. "배치재고데이터 배치 유형 B,C'
      MOVE-CORRESPONDING TEMP_0149J TO TEMP2.
      APPEND TEMP2.
      CLEAR  TEMP2.

    ELSEIF TEMP_0149J-GUBUN = '40'. "외주
      MOVE-CORRESPONDING TEMP_0149J TO TEMP4.
      APPEND TEMP4.
      CLEAR  TEMP4.

    ENDIF.

  ENDLOOP.

  PERFORM BATCH_BC.                   "배치재고데이터 배치 유형 B,C'
  PERFORM BATCN_NO_BC.
  "배치재고데이터 배치 유형 B,C가 아닌 경우
  PERFORM NO_BATCH.                   "배치관리 하지 않는 데이타
  PERFORM OUT_COM.                    "외주 배치/Non 배치 데이타

ENDFORM.                    " GET_DATA
*&---------------------------------------------------------------------*
*&      Form  GO_CONSIGNMENT
*&---------------------------------------------------------------------*
*       text : 적송 제고 연결 ( T-code : ZSD1R0014_2)
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GO_CONSIGNMENT .

*** 새창에서 열기
*  CALL FUNCTION 'NAVIGATION_EXECUTE_OBJECT'
*    EXPORTING
**     CONTROL_INSTANCE                  = ' '
*      object_name                       = 'ZSD1R0014_2'
*      reporttype                        = 'TR'
*      sap_guid                          = ''
*      NEW_WINDOW                        = 'X'
**     TARGET_SYSTEM                     = ' '
**     URL                               = ' '
**     BW_ACTIVE                         = ' '
*      NO_PROGRESS_INDICATOR             = 'X'
*      REPLACE_RFC_VARIABLES             = 'X'
**     CHECK_TRUSTED_SYSTEM              = 'X'
**     DO_NO_ALLOW_UNTRUSTED_START       = 'X'
**     READ_SY_DATAR                     = ' '
*.

** ZSD1R0014_2로 연결 (기존창에 연결)
  CALL TRANSACTION 'ZSD1R0014_2'.


ENDFORM.                    " GO_CONSIGNMENT
*&---------------------------------------------------------------------*
*&      Form  SEARCH_DATA
*&---------------------------------------------------------------------*
*       text : 데이터 조회
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SEARCH_DATA .
*& 조회 : 조회조건의 회사코드, 플랜트(멀티), 생성일자, 자재코드(멀티),
*재고구분으로 CBO(zppt0149) 테이블 조회
*사내배치 c_stockt_sb  1,  사내non배치 c_stockt_snb  2
*외주배치 c_stockt_ob  3,  외주non배치 c_stockt_onb  4

  PERFORM GET_ZPPT0149 USING 'S'.
  SORT GT_TAB BY WERKS MATNR LGORT MDATE CHARG.

  IF GT_TAB[] IS NOT INITIAL.

  ELSE.
    GV_NO_DATA = 'X'.
  ENDIF.

ENDFORM.                    " SEARCH_DATA
*&---------------------------------------------------------------------*
*&      Form  AUTHORITY_CHECKING_PROC
*&---------------------------------------------------------------------*
*       text : 권한체크
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM AUTHORITY_CHECKING_PROC .

  DATA : LV_SUBRC   LIKE  SY-SUBRC.

  READ TABLE S_PWERK INDEX 1.

  CALL FUNCTION 'ZPP_AUTHORIZATION_CHECK'
    EXPORTING
      I_WERKS = S_PWERK-LOW
      I_TYPE  = '1'
    IMPORTING
      E_SUBRC = LV_SUBRC.

  IF LV_SUBRC <> 0.
    MESSAGE E003 WITH '플랜트 [' S_PWERK-LOW
                    '] 작업권한을 확인하세요.'.
    GV_AUTHORITY = 'X'.
  ENDIF.

ENDFORM.                    " AUTHORITY_CHECKING_PROC
*&---------------------------------------------------------------------*
*&      Form  CREATE_AND_INIT_CONTROLS
*&---------------------------------------------------------------------*
*       text : ALV 생성
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CREATE_AND_INIT_CONTROLS .

  CLEAR : GV_TAB_CNT.

  CHECK GCL_CUSTOM_CONTAINER IS INITIAL.

*& 상속받은 Object를 연결해 주는 작업
  CREATE OBJECT GCL_CUSTOM_CONTAINER
    EXPORTING
      CONTAINER_NAME = GV_CONTAINER.

  CREATE OBJECT GCL_GRID
    EXPORTING
      I_PARENT      = GCL_CUSTOM_CONTAINER
      I_APPL_EVENTS = 'X'.

  PERFORM EXCLUDE_OF_TOOLBAR_BUTTON USING 'GT_EXCLUDE'.

*& 출력할 필드 속성을 정의
  PERFORM SET_FIELD_CATALOGS.

  PERFORM SET_CELL_ATTRIBUTE .

*& GRID 속성 지정(Display): Display시 옵션 지정
  PERFORM DISPLAY_LAYOUT_ATTRIBUTE USING GS_LAYOCAT.

*& Edit Event 및  Event Handler 등록
  PERFORM EVENT_HANDLER_REGISTER.

*& Sorting
  PERFORM BUILD_SORT_FIELD.

*& Define a drop down table.
  PERFORM SET_DRDN_TABLE.

  GV_REPID = SY-REPID.

*& At least field REPORT of this structure has to be filled!
  ALV_VARIANT-REPORT = GV_REPID.

*&  gv_title = ''.

*& ALV Grid Display
  PERFORM ALV_GRID_DISPLAY.

*&  CALL METHOD gcl_grid->set_gridtitle
*&    EXPORTING
*&      i_gridtitle = gv_title.

  LCL_ALV_GRID=>F_ALV = '1'.

** gt_tab의 총 건수
  DESCRIBE TABLE GT_TAB LINES GV_TAB_CNT.

  MESSAGE S003(ZPP1) WITH '총 ' GV_TAB_CNT
  '건의 데이터가 조회되었습니다.'.

ENDFORM.                    " CREATE_AND_INIT_CONTROLS
*&---------------------------------------------------------------------*
*&      Form  REFRESH_GT_TAB_DISPLAY
*&---------------------------------------------------------------------*
*       text : ALV REFRESH
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM REFRESH_GT_TAB_DISPLAY .

  DATA: LS_SCROLL       TYPE LVC_S_STBL.

*  gv_title = '작업지시 목록'.
*
*  CALL METHOD gcl_grid->set_gridtitle
*    EXPORTING
*      i_gridtitle = gv_title.

  PERFORM SET_CELL_ATTRIBUTE.

  LS_SCROLL-ROW = 'X'.
  LS_SCROLL-COL = 'X'.

  CALL METHOD GCL_GRID->REFRESH_TABLE_DISPLAY
    EXPORTING
      I_SOFT_REFRESH = 'X'
      IS_STABLE      = LS_SCROLL.     "현재 그대로 입력한 refresh

  CALL METHOD GCL_GRID->SET_OPTIMIZE_ALL_COLS.

ENDFORM.                    " REFRESH_GT_TAB_DISPLAY
*&---------------------------------------------------------------------*
*&      Form  EXIT_PROGRAM
*&---------------------------------------------------------------------*
*       text : 프로그램 종료 시 컨테이너 종료
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM EXIT_PROGRAM .

  CALL METHOD GCL_CUSTOM_CONTAINER->FREE.
  CALL METHOD CL_GUI_CFW=>FLUSH.

  CLEAR: GCL_CUSTOM_CONTAINER.

  LEAVE TO SCREEN 0.

ENDFORM.                    " EXIT_PROGRAM
*&---------------------------------------------------------------------*
*&      Form  CHECK_DATA
*&---------------------------------------------------------------------*
*       text : DATA 추출 전 zppt0149에 해당 날짜의 데이터가 있는지
*              확인하여 있을 경우 해당 데이터를 삭제
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CHECK_DATA .

  DATA : LV_CNT            TYPE I,
         LV_CHECK          TYPE C,
         LV_DATE           LIKE SY-DATUM,
         LV_SEARCH(10)     TYPE C,
         LV_BACKGROUND_JOB LIKE SY-BATCH. "BINPT

  CLEAR : LV_CNT, LV_CHECK, LV_DATE, LV_SEARCH, LV_BACKGROUND_JOB.

* 백그라운드 실행이 아닐 경우 생성일자의 년월에 해당하는 데이터가
* 생성된 데이터 보다 생성일이 빠른지 확인.
  PERFORM CHECK_DATE USING LV_CHECK LV_DATE.

  IF LV_CHECK = 'X'.
    MESSAGE S003(ZPP1) WITH '생성일자를 확인해주세요(최근생성일 :'
    LV_DATE ' )'.
    GV_COMMENT = 'N'.
  ELSE.
* zppt0149 에 있는지 확인하여
    IF R_UP = 'X'.
      PERFORM COUNT_ZPPT0149 USING LV_CNT.
    ELSE.
      PERFORM CNT_ZPPT0149J USING LV_CNT '' '' '' '' 'S'.
    ENDIF.

*생성일, 플랜트,자재코드(옵션)과 동일한 데이터가 zppt0149에 있으면
*delete
    IF LV_CNT > 0.
      IF SY-BATCH = 'X'.
        "배치 잡 실행시에는 창을 보이지 않고 바로 삭제
*& 2008.09.18
        IF R_UP NE 'X'.
          GV_COMMENT = 'N'.
        ELSE.
          GV_COMMENT = 'J'.
        ENDIF.
      ELSE.
        PERFORM OK_QES USING GV_COMMENT.
        "answer 의 값은 'J'확인,'N'취소 임.
      ENDIF.

      IF GV_COMMENT = 'J'.
        IF R_UP = 'X'.
          PERFORM DEL_0149.
        ELSE.

          MESSAGE E003(ZPP1) WITH
          '시점재고 재생성은 담당자에게 문의하세요'.
          GV_COMMENT = 'N'.

*            PERFORM del_0149j.
        ENDIF.
      ELSE.
        MESSAGE S003(ZPP1) WITH '작업을 취소 하였습니다'.
        GV_COMMENT = 'N'.
      ENDIF.
    ELSE.
      GV_COMMENT = 'J'.
    ENDIF.

  ENDIF.

ENDFORM.                    " CHECK_DATA
*&---------------------------------------------------------------------*
*&      Form  GET_TEMP2_DETAIL_DATA
*&---------------------------------------------------------------------*
*text : 저장위치 내역 및 거래처 명 /자재내역/단가 ( stprs * peinh )
*              금액(수량 * 단가)를 구함.
*----------------------------------------------------------------------*
*      -->P_WERKS  text  :
*      -->P_MATNR  text  :
*      -->P_MBLNR  text  :
*      -->P_LGORT  text  :
*      -->P_STOCKM text  : 체류수량
*      -->P_NAME1  text  : 저장위치 내역 및 거래처명
*      -->P_MAKTX  text  : 자재내역
*      -->P_STPRS  text  : 단가
*      -->P_MONEY  text  : 금액
*      -->P_BKLAS  text  : 평가클랙스
*      -->P_BKBEZ  text  : 평가클래스내역
*----------------------------------------------------------------------*
FORM GET_TEMP2_DETAIL_DATA  USING    P_WERKS
                                     P_MATNR
                                     P_MBLNR
                                     P_LGORT
                                     P_STOCKM
                                     P_NAME1
                                     P_MAKTX
                                     P_STPRS
                                     P_MONEY
                                     P_BKLAS
                                     P_BKBEZ
                                     P_PRCTR.

  DATA : LV_PEINH     LIKE MBEW-PEINH,
         LV_VPRSV     LIKE MBEW-VPRSV,
         LV_VERPR     LIKE MBEW-VERPR,
         LV_NAME1     LIKE LFA1-NAME1,
         LV_LGOBE     LIKE T001L-LGOBE,
         LV_MONEY(16) TYPE P DECIMALS 3.

  CLEAR : LV_NAME1, LV_PEINH, LV_LGOBE.
* 저장위치 내역 및 거래처 명  p_name1
  IF STRLEN( P_LGORT ) <= 4.  "저장위치 내역

    PERFORM SEL_LGOBE USING P_WERKS P_LGORT LV_LGOBE.
    P_NAME1 = LV_LGOBE.

  ELSE.       "거래처 명

    PERFORM SEL_NAME1 USING P_LGORT LV_NAME1.
    P_NAME1 = LV_NAME1.

  ENDIF.

*자재내역
  PERFORM SEL_MAKTX USING P_MATNR P_MAKTX.

* 단가 /금액/
  PERFORM GET_MONEY_STRPS USING P_MATNR
                                P_WERKS
                                P_STPRS
                                P_MONEY
                                P_STOCKM
                                P_BKLAS
                                P_BKBEZ
                                P_PRCTR        "손익센터
                                ''.

ENDFORM.                    " GET_TEMP2_DETAIL_DATA
*&---------------------------------------------------------------------*
*&      Form  BRANCHG_GET
*&---------------------------------------------------------------------*
*       text : 분류그룹
*----------------------------------------------------------------------*
*      -->P_GV_STOP  text
*      -->P_TEMP2_BRANCHG  text
*----------------------------------------------------------------------*
FORM BRANCHG_GET  USING    P_STOP
                           P_BRANCHG.
*            c_branchg_a   "분류그룹 a 30~90일
*            c_branchg_b   "분류그룹 b 91~180일
*            c_branchg_c   "분류그룹 c 181~365일
*            c_branchg_d   "분류그룹 d 366일이상
*            c_branchg_z   "분류그룹 z 오류

  IF P_STOP < 31.
    IF S_PWERK-LOW(1) EQ '2'.     "SRM2102-04681
      P_BRANCHG = C_BRANCHG_N.  "C20130518_33537:I
    ELSE.
      P_BRANCHG = C_BRANCHG_A.
    ENDIF.
  ELSEIF GV_STOP >= 31.
    P_BRANCHG = C_BRANCHG_A.
    IF P_STOP >= 91.
      P_BRANCHG = C_BRANCHG_B.

      IF P_STOP >= 181.
        P_BRANCHG = C_BRANCHG_C.

        IF GV_STOP >= 366.
          P_BRANCHG = C_BRANCHG_D.
        ENDIF.

      ENDIF.

    ENDIF.

  ENDIF.

ENDFORM.                    " BRANCHG_GET
*&---------------------------------------------------------------------*
*&      Form  OK_QES
*&---------------------------------------------------------------------*
*       text : 확인 팝업창
*----------------------------------------------------------------------*
*      -->P_LV_COMMENT  text
*----------------------------------------------------------------------*
FORM OK_QES  USING    P_COMMENT.

*" 해당 월에 데이타가 있습니다."
*"생성하시겠습니까?" 확인/취소 메시지 창으로 보여주고 확인시 데이터 생성
  DATA  : LV_ANWER TYPE C.
  CLEAR : LV_ANWER.

*    POPUP FUCTION.
  CALL FUNCTION 'POPUP_TO_CONFIRM_WITH_MESSAGE'
    EXPORTING
      DEFAULTOPTION  = 'Y'
      DIAGNOSETEXT1  = '해당 월에 데이터가 있습니다.'
*     diagnosetext2  = ''
      TEXTLINE1      = '생성하시겠습니까?'
      TITEL          = '확인'
      CANCEL_DISPLAY = ''
    IMPORTING
      ANSWER         = LV_ANWER.

  P_COMMENT  = LV_ANWER.

ENDFORM.                    " OK_QES
*&---------------------------------------------------------------------*
*&      Form  VALUE_ROUND
*&---------------------------------------------------------------------*
*       text : 해당 자리수에 대한 Round 처리
*----------------------------------------------------------------------*
*      -->P_RATE  text
*      -->P_MENGE  text
*      -->P_VALUE  text
*----------------------------------------------------------------------*
FORM VALUE_ROUND  USING    P_RATE
                           P_MENGE
                           P_VALUE
                           P_CHECK.

  DATA : LV_VALUE            TYPE F,
         LV_RETURN_VALUE(10) TYPE N.

  CLEAR : LV_VALUE, LV_RETURN_VALUE.

  LV_VALUE = ( ( P_RATE * 1000 ) * P_MENGE ) / 1000.

  IF LV_VALUE = 0 OR LV_VALUE IS INITIAL.
    LV_RETURN_VALUE = 0.
  ELSE.
    PERFORM ROUND_F USING LV_VALUE LV_RETURN_VALUE.
  ENDIF.

  IF LV_RETURN_VALUE > 9999999999.
    P_VALUE = 0.
    P_CHECK = 'X'.
  ELSE.
    P_VALUE = LV_RETURN_VALUE.
  ENDIF.

ENDFORM.                    " VALUE_ROUND
*&---------------------------------------------------------------------*
*&      Form  MAKE_SBAT
*&---------------------------------------------------------------------*
*       text : select-option 에 데이터 입력
*----------------------------------------------------------------------*
*      -->P_LV_CNT  text
*      -->P_S_BAT  text
*----------------------------------------------------------------------*
FORM MAKE_SBAT  USING    P_LOW
                         P_BUN TYPE C.
  IF P_BUN = 'D'.
    MOVE: 'I'      TO S_BAT-SIGN,
          'EQ'     TO S_BAT-OPTION,
           P_LOW   TO S_BAT-LOW.

    APPEND S_BAT.
    CLEAR  S_BAT.

  ELSE.
    MOVE: 'I'      TO S_BRAN-SIGN,
          'EQ'     TO S_BRAN-OPTION,
           P_LOW   TO S_BRAN-LOW.

    APPEND S_BRAN.
    CLEAR  S_BRAN.
  ENDIF.

ENDFORM.                    " MAKE_SBAT
*&---------------------------------------------------------------------*
*&      Form  MAKE_STOCK_OPT
*&---------------------------------------------------------------------*
*       text : 재고 구분 체크 데이터 생성
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM MAKE_STOCK_OPT .

  DATA  : LV_CNT TYPE I.
  CLEAR : LV_CNT, S_BAT, S_BAT[].

  IF C_BAT_S = 'X'.                      "사내배치   1
    PERFORM MAKE_SBAT USING C_STOCKT_SB 'D'.
  ENDIF.
  IF C_BAT_SN = 'X'.                     "사내non배치  2
    PERFORM MAKE_SBAT USING C_STOCKT_SNB 'D'.
  ENDIF.
  IF C_BAT_O = 'X'.                      "외주배치   3
    PERFORM MAKE_SBAT USING C_STOCKT_OB 'D'.
  ENDIF.
  IF C_BAT_ON = 'X'.                     "외주non배치  4
    PERFORM MAKE_SBAT USING C_STOCKT_ONB 'D'.
  ENDIF.

  MOVE: 'I'      TO S_BAT-SIGN,
         'EQ'     TO S_BAT-OPTION,
          ' '     TO S_BAT-LOW.
  APPEND S_BAT.

ENDFORM.                    " MAKE_STOCK_OPT
*&---------------------------------------------------------------------*
*&      Form  MAKE_OPT
*&---------------------------------------------------------------------*
*       text : 재고구분 및 분류구분 체크 데이터 생성
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM MAKE_OPT .

  PERFORM MAKE_STOCK_OPT.
  PERFORM MAKE_BRANCHG_OPT.

ENDFORM.                    " MAKE_OPT
*&---------------------------------------------------------------------*
*&      Form  MAKE_BRANCHG_OPT
*&---------------------------------------------------------------------*
*       text : 분류구분 체크 데이터 생성
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM MAKE_BRANCHG_OPT .

  DATA  : LV_CNT   TYPE I,
          LV_VALUE TYPE C.
  CLEAR : LV_CNT, LV_VALUE, S_BRAN, S_BRAN[].

  IF C_BRAN_A = 'X'.                           "분류그룹 A : 30~90일
    PERFORM MAKE_SBAT USING C_BRANCHG_A 'B'.
    PERFORM MAKE_SBAT USING C_BRANCHG_N 'B'.
  ENDIF.
  IF C_BRAN_B = 'X'.                           "분류그룹 B : 91~180일
    PERFORM MAKE_SBAT USING C_BRANCHG_B 'B'.
  ENDIF.
  IF C_BRAN_C = 'X'.                           "분류그룹 C : 181~365일
    PERFORM MAKE_SBAT USING C_BRANCHG_C 'B'.
  ENDIF.
  IF C_BRAN_D = 'X'.                           "분류그룹 D : 365일
    PERFORM MAKE_SBAT USING C_BRANCHG_D 'B'.
  ENDIF.
  IF C_BRAN_Z = 'X'.                           "분류그룹 E 오류
    PERFORM MAKE_SBAT USING C_BRANCHG_Z 'B'.
  ENDIF.

ENDFORM.                    " MAKE_BRANCHG_OPT

*&---------------------------------------------------------------------*
*&      Form  progress
*&---------------------------------------------------------------------*
*       text :  화면 진행상태
*----------------------------------------------------------------------*
*      -->P_80     text
*      -->P_0038   text
*----------------------------------------------------------------------*
FORM PROGRESS USING     P_VALUE
                        P_TEXT.

  CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
    EXPORTING
      PERCENTAGE = P_VALUE
      TEXT       = P_TEXT.

ENDFORM.                    " progress
*&---------------------------------------------------------------------*
*&      Form  ROUND_F
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LV_VALUE  text
*      -->P_LV_RETURN_VALUE  text
*----------------------------------------------------------------------*
FORM ROUND_F  USING    P_VALUE
                       P_RETURN_VALUE.

  DATA : LV_VALUE            TYPE F,
         LV_RETURN_VALUE(10) TYPE N.

  CLEAR : LV_VALUE, LV_RETURN_VALUE.


  CALL FUNCTION 'FIMA_NUMERICAL_VALUE_ROUND'
    EXPORTING
      I_RTYPE     = ' '  "반올림
*     I_RTYPE     = '+'  "올림
*     I_RTYPE     = '-'  "버림
      I_RUNIT     = '1'   "기준자리 수
      I_VALUE     = P_VALUE
    IMPORTING
      E_VALUE_RND = LV_RETURN_VALUE.

  P_RETURN_VALUE = LV_RETURN_VALUE.

ENDFORM.                    " ROUND_F
*&---------------------------------------------------------------------*
*&      Form  VALUE_ROUND_RATE
*&---------------------------------------------------------------------*
*       text : 반올림 함수
*----------------------------------------------------------------------*
*      -->P_TEMP_ACT_RATE  text
*      -->P_TEMP_ACT_MSHARE  text
*      -->P_LV_ERROR  text
*----------------------------------------------------------------------*
FORM VALUE_ROUND_RATE  USING    P_RATE
                                P_MSHARE
                                P_ERROR.

  DATA : LV_VALUE           TYPE F,
         LV_RETURN_VALUE(6) TYPE P DECIMALS 3.

  CLEAR : LV_VALUE, LV_RETURN_VALUE.

  LV_VALUE = P_RATE * 100.

  IF LV_VALUE = 0 OR LV_VALUE IS INITIAL.
    LV_RETURN_VALUE = 0.
  ELSE.
    CALL FUNCTION 'TB_NUMBER_ROUND'   "반올림
      EXPORTING
        NUMBER         = LV_VALUE
        ROUNDING_TYPE  = 'A'
        ROUNDING_UNIT  = '4'
      IMPORTING
        NUMBER_ROUNDED = LV_RETURN_VALUE.
  ENDIF.

  IF LV_RETURN_VALUE > '999.999'.
    P_MSHARE = 0.
    P_ERROR = 'X'.
  ELSE.
    P_MSHARE = LV_RETURN_VALUE.
  ENDIF.

ENDFORM.                    " VALUE_ROUND_RATE
*&---------------------------------------------------------------------*
*&      Form  MAKE_DATA_Z0149J
*&---------------------------------------------------------------------*
*       text : 자재 생성 ( zppt0149j 데이터 생성 )
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM MAKE_DATA_Z0149J .

*  DATA : lv_bklas LIKE mbew-bklas,  "평가유형 클래스
*         lv_bkbez LIKE t025t-bkbez. "평가유형 내역
*
*  CLEAR : lv_bklas, lv_bkbez.

*창고 기본 재고 정보 조회
  PERFORM SELECT_TEMP1.
*  "temp1 조회 > 배치관리 하지 않는 재고
  PERFORM SELECT_TEMP2.
**  "temp2 조회 > 배치/non재고데이터
  PERFORM SELECT_TEMP3.
*  "temp3 조회 > 배치/non재고데이터
  PERFORM SELECT_TEMP4.                  "temp4 조회 > 외주

  LOOP AT TEMP1.
    MOVE-CORRESPONDING TEMP1 TO TEMP55.
    TEMP55-GUBUN = '10'.
    TEMP55-MDATE = P_DATE.
    TEMP55-NWERKS = 'X'.

    APPEND TEMP55.
    CLEAR TEMP55.
  ENDLOOP.

  LOOP AT TEMP2.

    MOVE-CORRESPONDING TEMP2 TO TEMP55.
    IF TEMP2-DPCBT <>'B' AND TEMP2-DPCBT <> 'C'.
      TEMP55-GUBUN = '21'.
    ELSE.
      TEMP55-GUBUN = '22'.
    ENDIF.
    TEMP55-MDATE = P_DATE.
    TEMP55-NWERKS = 'X'.

    APPEND TEMP55.
    CLEAR TEMP55.

  ENDLOOP.

  LOOP AT TEMP4.
    MOVE-CORRESPONDING TEMP4 TO TEMP55.
    TEMP55-GUBUN = '40'.
    TEMP55-MDATE = P_DATE.
    TEMP55-NWERKS = 'X'.

    APPEND TEMP55.
    CLEAR TEMP55.

  ENDLOOP.

  CLEAR : TEMP1, TEMP1[], TEMP2, TEMP2[],
               TEMP4, TEMP4[].

  PERFORM GET_STOCK_MONEY_STRPS.

**
  LOOP AT  TEMP55.
    INSERT INTO ZPPT0149J VALUES TEMP55.

    IF SY-SUBRC <> 0.
      ROLLBACK WORK.
    ELSE.
      COMMIT WORK.
    ENDIF.
  ENDLOOP.

ENDFORM.                    " MAKE_DATA_Z0149J
*&---------------------------------------------------------------------*
*&      Form  UP_MONEY
*&---------------------------------------------------------------------*
*       text : 결산 금액 반영**
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM UP_MONEY .

  DATA : LV_CNT       TYPE I,
         LV_CHECK     TYPE C,
         LV_YEAR(04)  TYPE C,
         LV_MONTH(02) TYPE C,
         LV_STPRSAF   LIKE ZPPT0149-STPRSAF,
         LV_WERKS     LIKE ZPPT0149-WERKS,
         LV_MATNR     LIKE ZPPT0149-MATNR,
         LV_CHARG     LIKE ZPPT0149-CHARG,
         LV_KALNR     LIKE CKMLHD-KALNR,
         LV_PEINH     TYPE CKMLCR-PEINH,
         LV_PVPRS     LIKE CKMLCR-PVPRS,
         LV_CNT1      TYPE I,
         LV_TPVPRS    TYPE DEC23_2,
         LV_TPEINH    TYPE CKMLCR-PEINH,
*-{기능개선_205476_추가
         LV_MATNR_S   LIKE ZPPT0149-MATNR_S,
         LV_BRGEW     LIKE ZPPT0149-BRGEW,
         LV_STPRS_SC  LIKE ZPPT0149-STPRS_SC,
         LV_MATKL     LIKE MARA-MATKL,
         LV_DISPO     LIKE MARC-DISPO.
*-}기능개선_205476_2017.09.05

  DATA :  LV_CURTP LIKE CKMLCR-CURTP.

*& 2008.11.04 추가
  DATA : BEGIN OF LT_KALNR OCCURS 0,
           KALNR TYPE  CKMLHD-KALNR,
         END OF LT_KALNR.

  DATA : BEGIN OF LT_PVPRS OCCURS 0,
           PVPRS TYPE  CKMLCR-PVPRS,
           PEINH TYPE  CKMLCR-PEINH,
         END OF LT_PVPRS.

  CLEAR : LV_WERKS, LV_MATNR, LV_CHARG, LV_PVPRS, LV_STPRSAF,
          LV_YEAR,  LV_MONTH, TEMP_0149, TEMP_0149[].

  LV_YEAR = P_DATE+0(4).
  LV_MONTH = P_DATE+4(2).

*** zppt0149j 데이터 가져오기
  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE TEMP_0149
    FROM ZPPT0149
   WHERE MDATE = P_DATE
     AND WERKS IN S_PWERK
     AND MATNR IN S_MATNR.

  IF TEMP_0149[] IS INITIAL.
    MESSAGE S003(ZPP1) WITH '반영할 데이터가 없습니다.'.
    RETURN.
  ENDIF.

  SORT TEMP_0149 BY WERKS MATNR.

  LOOP AT TEMP_0149.
    CLEAR : LV_CNT.
    LV_MATNR = TEMP_0149-MATNR.
    AT NEW WERKS.
      PERFORM SELECT_CKM USING  LV_MATNR
                                TEMP_0149-WERKS
                                LV_CNT.

      IF LV_CNT > 0.
        LV_CHECK = 'X'.
        EXIT.
      ENDIF.

    ENDAT.
  ENDLOOP.

*  IF lv_check = 'X'.
*    MESSAGE s003(zpp1) WITH temp_0149-werks
*    ' 의 결산이 종료되지 않았습니다.'.
*    EXIT.
*  ENDIF.

  CLEAR : LV_MATNR.
  SORT TEMP_0149 BY WERKS MATNR LGORT CHARG.

  LOOP AT TEMP_0149.

    PERFORM DETERMINE_CURTP USING TEMP_0149-WERKS "C20120517_10391:I
                         CHANGING LV_CURTP.


** 17XX 플랜트일경우 charg(배치번호) 까지 조건에 추가
    IF TEMP_0149-WERKS+0(2) = '37'.
** 앞에 있을 경우 단가를 다시 계산 하지 않음.
      IF LV_WERKS = TEMP_0149-WERKS AND
         LV_MATNR = TEMP_0149-MATNR AND
         LV_CHARG = TEMP_0149-CHARG AND
         LV_STPRSAF > 0.

*     결산 후 금액 >>결산 후 수량 * 결산 후 단가
        TEMP_0149-STPRSAF = LV_STPRSAF.
        TEMP_0149-MONEYAF = TEMP_0149-STOPM * TEMP_0149-STPRSAF.

      ELSE.

*& 영업문서가 없는 원가추정번호를 먼저 조회하여 평가금액이 있으면 사용
*& 평가금액이 없으면 해당하는 전체 원가추정번호중 평가금액이 있는 원가
*사용
** 원가 추정번호
        SELECT KALNR
          INTO LV_KALNR
          FROM CKMLHD
         WHERE BWKEY = TEMP_0149-WERKS
           AND MATNR = TEMP_0149-MATNR
           AND BWTAR = TEMP_0149-CHARG
           AND VBELN = SPACE.
        ENDSELECT.

        CLEAR : LV_PVPRS, LV_PEINH.

** 실제 단가
        SELECT PVPRS PEINH
          INTO (LV_PVPRS, LV_PEINH)
          FROM CKMLCR
         WHERE KALNR = LV_KALNR
           AND BDATJ = LV_YEAR        "추출 생성년  날짜
           AND POPER = LV_MONTH       "추출 생성월
           AND CURTP = LV_CURTP       "C20120517_10391:U
           AND SALK3  > 0.         "
        ENDSELECT.

        IF LV_PVPRS = 0.

** 원가 추정번호
          SELECT KALNR
            INTO LV_KALNR
            FROM CKMLHD
           WHERE BWKEY = TEMP_0149-WERKS
             AND MATNR = TEMP_0149-MATNR
             AND BWTAR = TEMP_0149-CHARG.
** 실제 단가
            SELECT SINGLE PVPRS PEINH
              INTO (LV_PVPRS, LV_PEINH)
              FROM CKMLCR
             WHERE KALNR = LV_KALNR
               AND BDATJ = LV_YEAR        "추출 생성년  날짜
               AND POPER = LV_MONTH       "추출 생성월
               AND CURTP = LV_CURTP       "C20120517_10391:U
               AND SALK3  > 0.

            IF LV_PVPRS > 0.
              EXIT.
            ENDIF.

          ENDSELECT.

        ENDIF.

        IF LV_PVPRS IS NOT INITIAL AND
           LV_PEINH IS NOT INITIAL.

*     결산 후 금액 >>결산 후 수량 * 결산 후 단가
          LV_STPRSAF        = ( LV_PVPRS * 100 ) / LV_PEINH.
          TEMP_0149-STPRSAF = LV_STPRSAF.
          TEMP_0149-MONEYAF = TEMP_0149-STOPM * TEMP_0149-STPRSAF.
        ELSE.
          LV_STPRSAF = 0.
          TEMP_0149-STPRSAF = 0.
          TEMP_0149-MONEYAF = 0.
        ENDIF.
      ENDIF.

*& 2008.11.04
*& C20081104_52476
*& 부스닥트의 경우 단가를 평균가로 적용
    ELSEIF TEMP_0149-WERKS = '1202' AND
           TEMP_0149-PRCTR = '0000010205'.       "부스닥트 손익센터

** 앞에 있을 경우 단가를 다시 계산 하지 않음.
      IF LV_WERKS = TEMP_0149-WERKS AND
         LV_MATNR = TEMP_0149-MATNR AND
         LV_STPRSAF > 0.

*     결산 후 금액 >>결산 후 수량 * 결산 후 단가
        TEMP_0149-STPRSAF = LV_STPRSAF.
        TEMP_0149-MONEYAF = TEMP_0149-STOPM * TEMP_0149-STPRSAF.

      ELSE.

        CLEAR : LT_KALNR, LT_KALNR[], LT_PVPRS[], LT_PVPRS,
                LV_TPVPRS, LV_TPEINH, LV_CNT.

*& 자재에 대한 원가 추정번호를 멀티로 조회
        SELECT KALNR
          INTO CORRESPONDING FIELDS OF TABLE LT_KALNR
          FROM CKMLHD
         WHERE  BWKEY = TEMP_0149-WERKS
           AND  MATNR = TEMP_0149-MATNR.

*& 멀티의 원가 추정번호 해당 월의 총재고 금액이 있는 단가 조회
        SELECT PVPRS PEINH
          INTO CORRESPONDING FIELDS OF TABLE LT_PVPRS
              FROM CKMLCR
              FOR ALL ENTRIES IN LT_KALNR
             WHERE KALNR = LT_KALNR-KALNR
               AND BDATJ = LV_YEAR        "추출 생성년  날짜
               AND POPER = LV_MONTH       "추출 생성월
               AND CURTP = LV_CURTP       "C20120517_10391:U
               AND SALK3  > 0
               AND PVPRS  > 0.

*& 총재고 금액이 있는 데이타 row 조회
        DESCRIBE TABLE LT_PVPRS LINES LV_CNT1.

*& 총재고 금액이 없으면 실제원가 없이 0으로
        IF LV_CNT1 > 0.

          LOOP AT LT_PVPRS.

            IF LT_PVPRS-PVPRS IS NOT INITIAL AND
               LT_PVPRS-PEINH IS NOT INITIAL.

              LV_TPVPRS = LV_TPVPRS + ( LT_PVPRS-PVPRS * 100 ) /
              LT_PVPRS-PEINH.
*            lv_tpeinh = lv_tpeinh + lt_pvprs-peinh.
            ENDIF.

          ENDLOOP.

          LV_PVPRS = LV_TPVPRS / LV_CNT1.
*          lv_peinh = lv_tpeinh / lv_cnt1.

          IF LV_PVPRS IS NOT INITIAL.
*           AND  lv_peinh IS NOT INITIAL.

*     결산 후 금액 >>결산 후 수량 * 결산 후 단가
*          lv_stprsaf        = ( lv_pvprs * 100 ) / lv_peinh.
            LV_STPRSAF = LV_PVPRS.
            TEMP_0149-STPRSAF = LV_STPRSAF.
            TEMP_0149-MONEYAF = TEMP_0149-STOPM * TEMP_0149-STPRSAF.

          ELSE.
            LV_STPRSAF = 0.
            TEMP_0149-STPRSAF = 0.
            TEMP_0149-MONEYAF = 0.
          ENDIF.

        ENDIF.

      ENDIF.

    ELSE.
** 앞에 있을 경우 단가를 다시 계산 하지 않음.
      IF LV_WERKS = TEMP_0149-WERKS AND
         LV_MATNR = TEMP_0149-MATNR AND
         LV_STPRSAF > 0.

*     결산 후 금액 >>결산 후 수량 * 결산 후 단가
        TEMP_0149-STPRSAF = LV_STPRSAF.
        TEMP_0149-MONEYAF = TEMP_0149-STOPM * TEMP_0149-STPRSAF.

      ELSE.

** 원가 추정번호
        SELECT KALNR
          INTO LV_KALNR
          FROM CKMLHD
         WHERE BWKEY = TEMP_0149-WERKS
           AND MATNR = TEMP_0149-MATNR
           AND VBELN = SPACE.
        ENDSELECT.

        CLEAR : LV_PVPRS, LV_PEINH.

** 실제 단가
        SELECT PVPRS PEINH
          INTO (LV_PVPRS, LV_PEINH)
          FROM CKMLCR
         WHERE KALNR = LV_KALNR
           AND BDATJ = LV_YEAR        "추출 생성년  날짜
           AND POPER = LV_MONTH       "추출 생성월
           AND CURTP = LV_CURTP       "C20120517_10391:U
           AND SALK3  > 0.
        ENDSELECT.

        IF LV_PVPRS = 0.

** 원가 추정번호
          SELECT KALNR
            INTO LV_KALNR
            FROM CKMLHD
           WHERE BWKEY = TEMP_0149-WERKS
             AND MATNR = TEMP_0149-MATNR.
** 실제 단가
            SELECT SINGLE PVPRS PEINH
              INTO (LV_PVPRS, LV_PEINH)
              FROM CKMLCR
             WHERE KALNR = LV_KALNR
               AND BDATJ = LV_YEAR        "추출 생성년  날짜
               AND POPER = LV_MONTH       "추출 생성월
               AND CURTP = LV_CURTP       "C20120517_10391:U
               AND SALK3  > 0.

            IF LV_PVPRS > 0.
              EXIT.
            ENDIF.

          ENDSELECT.

        ENDIF.

        IF LV_PVPRS IS NOT INITIAL AND
           LV_PEINH IS NOT INITIAL.

*     결산 후 금액 >>결산 후 수량 * 결산 후 단가
          LV_STPRSAF        = ( LV_PVPRS * 100 ) / LV_PEINH.
          TEMP_0149-STPRSAF = LV_STPRSAF.
          TEMP_0149-MONEYAF = TEMP_0149-STOPM * TEMP_0149-STPRSAF.

        ELSE.
          LV_STPRSAF = 0.
          TEMP_0149-STPRSAF = 0.
          TEMP_0149-MONEYAF = 0.
        ENDIF.
      ENDIF.

    ENDIF.

*-{기능개선_205476_
* 자재별 스크랩 코드/환산중량/스크랩 단가
    IF TEMP_0149-DISPO IS INITIAL.
      SELECT SINGLE DISPO
               INTO TEMP_0149-DISPO
               FROM MARC
              WHERE WERKS = TEMP_0149-WERKS
                AND MATNR = TEMP_0149-MATNR.
    ENDIF.

** 앞에 있을 경우 단가를 다시 계산 하지 않음.
    IF LV_WERKS = TEMP_0149-WERKS AND
       LV_MATNR = TEMP_0149-MATNR AND
       LV_DISPO = TEMP_0149-DISPO.

      TEMP_0149-MATNR_S  = LV_MATNR_S.               "생산 스크랩 코드
      TEMP_0149-BRGEW    = LV_BRGEW.                  "M <-> KG 환산계수
      TEMP_0149-STOCKMSC = TEMP_0149-STOPM * LV_BRGEW."스크랩 환산중량
      TEMP_0149-STPRS_SC = LV_STPRS_SC.                  "스크랩 단가

    ELSE.

      CLEAR : LV_MATKL, LV_DISPO, LV_MATNR_S,
              LV_BRGEW, LV_STPRS_SC.

      SELECT SINGLE A~MATKL  B~DISPO
               INTO (LV_MATKL, LV_DISPO)
               FROM MARA AS A INNER JOIN MARC AS B
                             ON A~MATNR EQ B~MATNR
              WHERE A~MATNR = TEMP_0149-MATNR
                AND B~WERKS = TEMP_0149-WERKS.

      IF SY-SUBRC = 0.
        PERFORM GET_SCRAP_DATA USING TEMP_0149-WERKS
                                     TEMP_0149-MATNR
                                     TEMP_0149-MEINS
                                     LV_MATKL
                                     LV_DISPO
                                     LV_CURTP
                                     LV_YEAR
                                     LV_MONTH.

        LV_DISPO    = TEMP_0149-DISPO.
        LV_MATNR_S  = TEMP_0149-MATNR_S.
        LV_BRGEW    = TEMP_0149-BRGEW.
        LV_STPRS_SC = TEMP_0149-STPRS_SC.

      ENDIF.

    ENDIF.
*-}기능개선_205476_2017.09.05

    LV_WERKS = TEMP_0149-WERKS.
    LV_MATNR = TEMP_0149-MATNR.
    LV_CHARG = TEMP_0149-CHARG.

    UPDATE ZPPT0149 FROM TEMP_0149.

    IF SY-SUBRC <> 0.
      ROLLBACK WORK.
    ELSE.
      COMMIT WORK.
    ENDIF.


  ENDLOOP.

  MESSAGE S003(ZPP1) WITH '결산 금액 반영 작업이 종료 되었습니다.'.

ENDFORM.                    " UP_MONEY
*&---------------------------------------------------------------------*
*&      Form  UP_STOCK
*&---------------------------------------------------------------------*
*       text : 결산 수량 반영**
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM UP_STOCK .

  DATA : LV_STOCKMAF LIKE ZPPT0149J-STOCKMAF,
         LV_BKLAS    LIKE MBEW-BKLAS,           "평가유형 클래스
         LV_BKBEZ    LIKE T025T-BKBEZ,          "평가유형 내역
         LV_STOCK    LIKE ZPPT0149J-STOCKMAF,
         LV_CNT      TYPE I,
         LV_GUBUN(2) TYPE C,
         LV_SUM      LIKE ZPPT0149-MENGE.

  CLEAR : TEMP_MATDOC, TEMP_MATDOC[], TEMP_0149J, TEMP_0149J[],
          TEMP_COPY, TEMP_COPY[].


** zppt0149j 데이터 가져오기
  PERFORM GET_0149J.

  IF TEMP_0149J[] IS INITIAL.
    MESSAGE S003(ZPP1) WITH '마감 결과 반영할 데이타가 없습니다.'.
    RETURN.
  ENDIF.

  LOOP AT TEMP_0149J.

    TEMP_0149J-STOCKMAF = TEMP_0149J-STOCKM.
    MODIFY ZPPT0149J FROM TEMP_0149J.

    IF SY-SUBRC <> 0.
      ROLLBACK WORK.
    ELSE.
      COMMIT WORK.
    ENDIF.

  ENDLOOP.

*  matdoc 데이터 가져오기
  PERFORM GET_STOCK_CLOSING.  "matdoc에서 가져오기


  IF  TEMP_MATDOC[] IS NOT INITIAL.

    LOOP AT TEMP_MATDOC.
      CLEAR : LV_STOCKMAF, LV_SUM, LV_GUBUN, LV_STOCK,
              TEMP_0149J, TEMP_0149J[].

*** 해당 자재문서의 수량 sum
*      LOOP AT temp_collect WHERE werks = temp_matdoc-werks
*                            AND  matnr = temp_matdoc-matnr
*                            AND  lgort = temp_matdoc-lgort
*                            AND  charg = temp_matdoc-charg.
*
*        lv_stockmaf = lv_stockmaf + temp_collect-menge.
*
*      ENDLOOP.
      LV_STOCKMAF = TEMP_MATDOC-MENGE.

      PERFORM CNT_ZPPT0149J  USING LV_CNT
                                   TEMP_MATDOC-WERKS
                                   TEMP_MATDOC-MATNR
                                   TEMP_MATDOC-LGORT
                                   TEMP_MATDOC-CHARG
                                   'U'.

      IF LV_CNT > 0.
** 기존 데이터가 있을 경우 수정
        PERFORM SELECT_STOCKM USING  TEMP_MATDOC-WERKS
                                     TEMP_MATDOC-MATNR
                                     TEMP_MATDOC-LGORT
                                     TEMP_MATDOC-CHARG
                                     LV_STOCK.

** update 시 결산 후 수량은 기존 플랜트 재고수량 + 자재문서 sum 수량
        LV_STOCK = LV_STOCK + LV_STOCKMAF.

        UPDATE ZPPT0149J SET STOCKMAF = LV_STOCK
                       WHERE MDATE = P_DATE
                         AND WERKS = TEMP_MATDOC-WERKS
                         AND MATNR = TEMP_MATDOC-MATNR
                         AND LGORT = TEMP_MATDOC-LGORT
                         AND CHARG = TEMP_MATDOC-CHARG.

        IF SY-SUBRC <> 0.
          ROLLBACK WORK.
        ELSE.
          COMMIT WORK.
        ENDIF.

      ELSE.
** 기존 데이터가 없을 경우 새로운 정보 입력
* 단가 /금액/
        IF LV_STOCKMAF < 0.
          LV_STOCKMAF = 0.
        ENDIF.
        PERFORM GET_MONEY_STRPS USING TEMP_MATDOC-MATNR
                                      TEMP_MATDOC-WERKS
                                      TEMP_MATDOC-STPRS
                                      TEMP_MATDOC-MONEY
                                      LV_STOCKMAF
                                      LV_BKLAS
                                      LV_BKBEZ
                                      TEMP_MATDOC-PRCTR
                                      'U'.

**  재고 / 결산후 재고
        TEMP_MATDOC-STOCKM   = 0.
        TEMP_MATDOC-STOCKMAF = LV_STOCKMAF.
** 생성일
        TEMP_MATDOC-MDATE = P_DATE.
** 데이터 구분 ( 결산 금액 반영 시 로직처리에 필요 값 )
** 외주 '40' 인 경우는 없었으므로 제외
        IF TEMP_MATDOC-CHARG = '' OR TEMP_MATDOC-CHARG IS INITIAL.
          LV_GUBUN = '10'.   "배치관리 X
        ELSE.

          SELECT DPCBT
            INTO TEMP_MATDOC-DPCBT
            FROM MARA
           WHERE MATNR = TEMP_MATDOC-MATNR.
          ENDSELECT.

          IF TEMP_MATDOC-DPCBT <>'B' AND TEMP_MATDOC-DPCBT <> 'C'.
            LV_GUBUN = '21'.
          ELSE.
            LV_GUBUN = '22'.
          ENDIF.

        ENDIF.
*-{자체개선_144793_추가
*-결산 후 생성된 재고에 대해 자재유형 누락 방지
        SELECT SINGLE MTART
          INTO TEMP_MATDOC-MTART
          FROM MARA
         WHERE MATNR = TEMP_MATDOC-MATNR.
*-}자체개선_144793_2016.07.11
        MOVE-CORRESPONDING TEMP_MATDOC TO TEMP_0149J.
        TEMP_0149J-GUBUN = LV_GUBUN.

        INSERT INTO ZPPT0149J VALUES TEMP_0149J.

        IF SY-SUBRC <> 0.
          ROLLBACK WORK.
        ELSE.
          COMMIT WORK.
        ENDIF.


      ENDIF.

    ENDLOOP.

    MESSAGE S003(ZPP1) WITH '마감 결과 반영 작업이 종료되었습니다.'.

  ELSE.
    EXIT.
  ENDIF.


ENDFORM.                    " UP_STOCK
*&---------------------------------------------------------------------*
*&      Form  UP_STOCK
*&---------------------------------------------------------------------*
*       text : 결산 수량 반영**
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM UP_STOCK_DEL.

  DATA : LV_STOCKMAF LIKE ZPPT0149J-STOCKMAF,
         LV_BKLAS    LIKE MBEW-BKLAS,           "평가유형 클래스
         LV_BKBEZ    LIKE T025T-BKBEZ,          "평가유형 내역
         LV_STOCK    LIKE ZPPT0149J-STOCKMAF,
         LV_CNT      TYPE I,
         LV_GUBUN(2) TYPE C,
         LV_SUM      LIKE ZPPT0149-MENGE.

  CLEAR : TEMP_MATDOC, TEMP_MATDOC[], TEMP_0149J, TEMP_0149J[],
          TEMP_COPY, TEMP_COPY[].


** zppt0149j 데이터 가져오기
  PERFORM GET_0149J.

  IF TEMP_0149J[] IS INITIAL.
    MESSAGE S003(ZPP1) WITH '마감 결과 반영할 데이타가 없습니다.'.
    RETURN.
  ENDIF.

  LOOP AT TEMP_0149J.

    TEMP_0149J-STOCKMAF = TEMP_0149J-STOCKM.
    MODIFY ZPPT0149J FROM TEMP_0149J.

    IF SY-SUBRC <> 0.
      ROLLBACK WORK.
    ELSE.
      COMMIT WORK.
    ENDIF.

  ENDLOOP.

*  matdoc 데이터 가져오기

  PERFORM GET_STOCK_CLOSING_DEL.  "matdoc에서 가져오기

  IF  TEMP_MATDOC[] IS NOT INITIAL.

    LOOP AT TEMP_MATDOC.
      CLEAR : LV_STOCKMAF, LV_SUM, LV_GUBUN, LV_STOCK,
              TEMP_0149J, TEMP_0149J[].

      LV_STOCKMAF = TEMP_MATDOC-MENGE.

      PERFORM CNT_ZPPT0149J  USING LV_CNT
                                   TEMP_MATDOC-WERKS
                                   TEMP_MATDOC-MATNR
                                   TEMP_MATDOC-LGORT
                                   TEMP_MATDOC-CHARG
                                   'U'.

      IF LV_CNT > 0.
** 기존 데이터가 있을 경우 수정
        PERFORM SELECT_STOCKM USING  TEMP_MATDOC-WERKS
                                     TEMP_MATDOC-MATNR
                                     TEMP_MATDOC-LGORT
                                     TEMP_MATDOC-CHARG
                                     LV_STOCK.

** update 시 결산 후 수량은 기존 플랜트 재고수량 + 자재문서 sum 수량
        LV_STOCK = LV_STOCK + LV_STOCKMAF.

        UPDATE ZPPT0149J SET STOCKMAF = LV_STOCK
                       WHERE MDATE = P_DATE
                         AND WERKS = TEMP_MATDOC-WERKS
                         AND MATNR = TEMP_MATDOC-MATNR
                         AND LGORT = TEMP_MATDOC-LGORT
                         AND CHARG = TEMP_MATDOC-CHARG.

        IF SY-SUBRC <> 0.
          ROLLBACK WORK.
        ELSE.
          COMMIT WORK.
        ENDIF.

      ELSE.
** 기존 데이터가 없을 경우 새로운 정보 입력
* 단가 /금액/
        IF LV_STOCKMAF < 0.
          LV_STOCKMAF = 0.
        ENDIF.
        PERFORM GET_MONEY_STRPS USING TEMP_MATDOC-MATNR
                                      TEMP_MATDOC-WERKS
                                      TEMP_MATDOC-STPRS
                                      TEMP_MATDOC-MONEY
                                      LV_STOCKMAF
                                      LV_BKLAS
                                      LV_BKBEZ
                                      TEMP_MATDOC-PRCTR
                                      'U'.

**  재고 / 결산후 재고
        TEMP_MATDOC-STOCKM   = 0.
        TEMP_MATDOC-STOCKMAF = LV_STOCKMAF.
** 생성일
        TEMP_MATDOC-MDATE = P_DATE.
** 데이터 구분 ( 결산 금액 반영 시 로직처리에 필요 값 )
** 외주 '40' 인 경우는 없었으므로 제외
        IF TEMP_MATDOC-CHARG = '' OR TEMP_MATDOC-CHARG IS INITIAL.
          LV_GUBUN = '10'.   "배치관리 X
        ELSE.

          SELECT DPCBT
            INTO TEMP_MATDOC-DPCBT
            FROM MARA
           WHERE MATNR = TEMP_MATDOC-MATNR.
          ENDSELECT.

          IF TEMP_MATDOC-DPCBT <>'B' AND TEMP_MATDOC-DPCBT <> 'C'.
            LV_GUBUN = '21'.
          ELSE.
            LV_GUBUN = '22'.
          ENDIF.

        ENDIF.

        MOVE-CORRESPONDING TEMP_MATDOC TO TEMP_0149J.
        TEMP_0149J-GUBUN = LV_GUBUN.

        INSERT INTO ZPPT0149J VALUES TEMP_0149J.

        IF SY-SUBRC <> 0.
          ROLLBACK WORK.
        ELSE.
          COMMIT WORK.
        ENDIF.


      ENDIF.

    ENDLOOP.

    MESSAGE S003(ZPP1) WITH '마감 결과 반영 작업이 종료되었습니다.'.

  ELSE.
    EXIT.
  ENDIF.


ENDFORM.                    " UP_STOCK_del

*&---------------------------------------------------------------------*
*&      Form  GET_MONEY_STRPS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_P_MATNR  text
*      -->P_P_WERKS  text
*      -->P_P_STPRS  text
*----------------------------------------------------------------------*
FORM GET_MONEY_STRPS  USING    P_MATNR
                               P_WERKS
                               P_STPRS
                               P_MONEY
                               P_STOCKM
                               P_BKLAS
                               P_BKBEZ
                               P_PRCTR            "손익센터
                               P_GUBUN.


  DATA : LV_PEINH     LIKE MBEW-PEINH,
         LV_VPRSV     LIKE MBEW-VPRSV,
         LV_VERPR     LIKE MBEW-VERPR,
         LV_BKLAS     LIKE MBEW-BKLAS,  "평가유형 클래스
         LV_BKBEZ     LIKE T025T-BKBEZ, "평가유형 내역
         LV_MONEY(16) TYPE P DECIMALS 3.

  CLEAR :  LV_PEINH, LV_VPRSV, LV_VERPR, LV_MONEY.

  IF P_GUBUN = 'X' OR
     P_GUBUN = 'U' .
    "시점 재고 생성 및 결산수량 반영시 신규 생성분
*단가
    SELECT SINGLE VPRSV VERPR STPRS PEINH BKLAS
      INTO (LV_VPRSV, LV_VERPR, P_STPRS, LV_PEINH, LV_BKLAS)
      FROM MBEW
     WHERE MATNR = P_MATNR    "자재번호
      AND  BWKEY = P_WERKS.  "플랜트

*금액(수량 * 단가):원화와 달러의 차이때문에 소수점으로 표현(p_stprs)되어
** 100 필요
*금액(체류수량 * 단가)
    IF LV_VPRSV = 'S' .
      IF LV_PEINH = 0 OR LV_PEINH IS INITIAL.
        P_MONEY = 0.
      ELSE.
        LV_MONEY = ( P_STOCKM *  P_STPRS * 100 ) / LV_PEINH.
        IF LV_MONEY  > 9999999999999.
          P_MONEY = 0.
        ELSE.
          P_MONEY = LV_MONEY.
        ENDIF.
      ENDIF.
    ELSE.
      IF LV_PEINH = 0 OR LV_PEINH IS INITIAL.
        P_MONEY = 0.
      ELSE.
        LV_MONEY = ( P_STOCKM *  P_STPRS * 100 ) / LV_PEINH.
        IF LV_MONEY  > 9999999999999.
          P_MONEY = 0.
        ELSE.
          P_MONEY = LV_MONEY.
        ENDIF.
      ENDIF.
    ENDIF.

** 단가
    P_STPRS = ( P_STPRS * 100 ) / LV_PEINH.

** 손익센터
    SELECT PRCTR
     INTO P_PRCTR
     FROM MARC
    WHERE WERKS = P_WERKS
      AND MATNR = P_MATNR.
    ENDSELECT.

  ELSE.   "결산 금액 반영 시

*단가
    SELECT SINGLE VPRSV VERPR PEINH BKLAS
      INTO (LV_VPRSV, LV_VERPR, LV_PEINH, LV_BKLAS)
      FROM MBEW
     WHERE MATNR = P_MATNR    "자재번호
      AND  BWKEY = P_WERKS.  "플랜트

*금액(수량 * 단가): 이미 시점 재고 생성 시 단가에 100을 곱한 상태이므로
** 100을 하지 않음
*금액(체류수량 * 단가)
    IF LV_VPRSV = 'S' .
      IF LV_PEINH = 0 OR LV_PEINH IS INITIAL.
        P_MONEY = 0.
      ELSE.
        LV_MONEY = P_STOCKM *  P_STPRS .
        IF LV_MONEY  > 9999999999.
          P_MONEY = 0.
        ELSE.
          P_MONEY = LV_MONEY.
        ENDIF.
      ENDIF.
    ELSE.
      IF LV_PEINH = 0 OR LV_PEINH IS INITIAL.
        P_MONEY = 0.
      ELSE.
        LV_MONEY = P_STOCKM *  P_STPRS.
        IF LV_MONEY  > 9999999999.
          P_MONEY = 0.
        ELSE.
          P_MONEY = LV_MONEY.
        ENDIF.
      ENDIF.
    ENDIF.

* 평가유형 가져오기
    SELECT BKBEZ
     INTO LV_BKBEZ
     FROM T025T
     WHERE BKLAS = LV_BKLAS
      AND  SPRAS = SY-LANGU.
    ENDSELECT.

    P_BKLAS = LV_BKLAS.
    P_BKBEZ = LV_BKBEZ.
  ENDIF.


ENDFORM.                    " GET_MONEY_STRPS
*&---------------------------------------------------------------------*
*&      Form  BATCH_BC
*&---------------------------------------------------------------------*
*       text : 배치관리 하는 데이터**
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM BATCH_BC .

  DATA  : LV_ERROR    TYPE C,
          LV_SUM      TYPE I,
          LV_STOCKM   LIKE ZPPT0149-STOCKM,
          LV_STOCKMAF LIKE ZPPT0149-STOCKMAF,
          LV_PRCTR    LIKE ZPPT0149J-PRCTR,  "손익센터
          LV_STOCKMBE LIKE ZPPT0149-STOCKMBE.

  CLEAR :  GV_E_CHECK, TEMP_ACT, TEMP_ACT[].

*zppt0149에서 생성일자가 가장 최근이며 플랜트,자재코드,배치번호가
*동일하고
*저장위치가 거래처코드가 아닌 데이터의 전기일,자재문서번호,손익센터를
*조회하고
  LOOP AT TEMP2.
    CLEAR : GV_STOP, GV_DATE, GV_SEQ, LV_ERROR, LV_SUM, GV_MDATE,
            LV_STOCKM, LV_STOCKMAF, LV_PRCTR.
    CLEAR : TEMP_0149, TEMP_0149[], TEMP_MATDOC, TEMP_MATDOC[],
            TEMP_Z, TEMP_Z[].

    LV_STOCKM     = TEMP2-STOCKM.
    LV_STOCKMAF   = TEMP2-STOCKMAF.

** zppt0149j 와 zppt0149의 매칭되는 필드명이 다르기 때문에 맞게 연결
    TEMP2-STOCKMBE = LV_STOCKM.
    TEMP2-STOCKM   = LV_STOCKMAF.
    CLEAR : TEMP2-STOCKMAF.

* 저장위치가 거래처코드가 아닐 경우
    IF STRLEN( TEMP2-LGORT ) <= 4.

      PERFORM SELECT_0149_MAXD  USING    TEMP2-WERKS
                                         TEMP2-MATNR
                                         TEMP2-LGORT
                                         TEMP2-CHARG.

* zppt0149에 없으면 matdoc 전체조회
      IF TEMP_0149[] IS INITIAL.  "기존 데이터가 없을 경우
*matdoc 에서 zppt0149의 생성일자 이후부터 플랜트,자재코드,배치번호에 대한
*전기일, 전기수량(=체류일수량), 단위, 자재문서번호를 조회
        PERFORM SELECT_MATDOC_N_T0149_INBATCH  USING   TEMP2-WERKS
                                                      TEMP2-MATNR
                                                      TEMP2-LGORT
                                                      TEMP2-CHARG.

      ELSE.
        "기존 데이터가 있을경우 그 데이터의 전기일 이 후 부터 현재날짜까지 조회

        LOOP AT TEMP_0149.
          GV_DATE = TEMP_0149-BUDAT.
          GV_MDATE = TEMP_0149-MDATE.
        ENDLOOP.
        IF GV_DATE > P_DATE.
          GV_DATE = P_DATE.
        ENDIF.

        PERFORM SELECT_MATDOC_Y_T0149_INBATCH  USING   TEMP2-WERKS
                                                      TEMP2-MATNR
                                                      TEMP2-LGORT
                                                      TEMP2-CHARG.

      ENDIF.

** 자재문서가 없을경우 'Z'로 하고 나머지는 공란으로해서 입력
      IF TEMP_MATDOC[] IS INITIAL.
        LV_ERROR = 'X'.
      ENDIF.
** 전기일자가 가장 최근인 자재문서의 전기일,전기수량,단위,자재문서번호
*이용
      SORT TEMP_MATDOC DESCENDING BY BUDAT MBLNR.

      READ TABLE TEMP_MATDOC INDEX 1 INTO TEMP_Z.

      IF TEMP2-CHARG = '' OR TEMP2-CHARG IS INITIAL.
        TEMP2-STOCKT = C_STOCKT_SNB.   "배치번호가 없으면 Non batch
        TEMP2-STTEXT = C_STTEXT_SNB.   "배치번호가 없으면 Non batch
      ELSE.
        TEMP2-STOCKT = C_STOCKT_SB.    "배치번호가 있을경우
        TEMP2-STTEXT = C_STTEXT_SB.    "배치번호가 있을경우
      ENDIF.
** 재고유형을사내 배치재고 '1'로 한다
      TEMP2-BUDAT = TEMP_Z-BUDAT.      "자재문서의 전기일
      TEMP2-MENGE = TEMP_Z-MENGE.      "전기수량
      IF TEMP2-STOCKM < TEMP_Z-MENGE.
        "창고제고 수량이 문서수량보다 적을경우
        IF TEMP2-STOCKM = 0.
          TEMP2-STOPM = 0.
        ELSE.
          TEMP2-STOPM = TEMP2-STOCKM.
        ENDIF.
      ELSE.
        TEMP2-STOPM = TEMP_Z-MENGE.     "체류수량( = 전기수량 )
      ENDIF.

      TEMP2-MENGE_LAST = TEMP2-STOPM.
      TEMP2-MSHARE = '100.000'.        "점유율
*      temp2-meins = temp_z-meins.      "단위
      TEMP2-MBLNR = TEMP_Z-MBLNR.      "자재문서번호
*      temp2-prctr = temp_z-prctr.      "손익센타
      TEMP2-BWART = TEMP_Z-BWART.      "이동유형
** 저장위치내역 or 공급업체명 /자재내역 / 단가 / 금액 / 평가클랙스 /
*평가클래스내역
      PERFORM GET_TEMP2_DETAIL_DATA USING  TEMP2-WERKS  TEMP2-MATNR
                                           TEMP2-MBLNR  TEMP2-LGORT
                                           TEMP2-STOCKM
                                           TEMP2-NAME1  TEMP2-MAKTX
                                           TEMP2-STPRS  TEMP2-MONEY
                                           TEMP2-BKLAS  TEMP2-BKBEZ
                                           LV_PRCTR.

** 전기일 기준으로 현재일자를 계산하여 체류일을 계산
** 체류일 = 현재일 - 자재문서의 전기일
      GV_STOP = P_DATE - TEMP_Z-BUDAT.   "체류
      TEMP2-STOPDATE = GV_STOP .

** 분류그룹 구하기(기존 로직 변경 없을 경우 공란으로해서 하여 low 추가)
      PERFORM BRANCHG_GET USING GV_STOP TEMP2-BRANCHG. "분류그룹 구하기

** sequence 번호 구하기
      PERFORM GET_SEQ USING TEMP2-WERKS TEMP2-MATNR TEMP2-LGORT
                            TEMP2-BRANCHG TEMP2-STOCKT P_DATE
                            GV_SEQ TEMP2-CHARG.

      TEMP2-SEQUENCE = GV_SEQ + 1.
      TEMP2-MDATE    = P_DATE. "sy-datum.

**** 자재문서가 없는경우
      IF LV_ERROR = 'X'.
        CLEAR : TEMP2-MBLNR,
                TEMP2-BUDAT,
                TEMP2-MENGE,
*                temp2-meins,
                TEMP2-BWART.

        TEMP2-BRANCHG = C_BRANCHG_Z.
** zppt0149j 와 zppt0149의 매칭되는 필드명이 다르기 때문에 맞게 연결
        TEMP2-STOCKMBE = LV_STOCKM.
        TEMP2-STOPM    = LV_STOCKM.
        TEMP2-STOCKM   = LV_STOCKMAF.

        IF TEMP2-CHARG = '' OR TEMP2-CHARG IS INITIAL.
          TEMP2-STOCKT = C_STOCKT_SNB.   "배치번호가 없으면 Non batch
          TEMP2-STTEXT = C_STTEXT_SNB.   "배치번호가 없으면 Non batch
        ELSE.
          TEMP2-STOCKT = C_STOCKT_SB.    "배치번호가 있을경우
          TEMP2-STTEXT = C_STTEXT_SB.    "배치번호가 있을경우
        ENDIF.

      ENDIF.

** 30 일 이상이면 CBO 저장 임시 테이블에 저장
      IF TEMP2-WERKS(1) EQ '2'. "C20130518_33537:U. "SRM2102-04681
        CHECK GV_STOP >= 0  OR LV_ERROR = 'X'.
      ELSE.
        CHECK GV_STOP >= 31 OR LV_ERROR = 'X'.
      ENDIF.

      IF LV_ERROR = 'X'.
        TEMP2-STOPDATE = '31'.  "Z 일경우 '31'일로 입력
      ENDIF.

      INSERT INTO ZPPT0149 VALUES TEMP2.

      IF SY-SUBRC <> 0.
        ROLLBACK WORK.
      ELSE.
        COMMIT WORK.
      ENDIF.

    ENDIF.

  ENDLOOP.


ENDFORM.                    " BATCH_BC
*&---------------------------------------------------------------------*
*&      Form  BATCN_NO_BC
*&---------------------------------------------------------------------*
*       text : 배치재고데이터 배치 유형 B,C가 아닌 경우**
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM BATCN_NO_BC .
** 로컬변수 선언
  DATA : LV_CNT        TYPE I,                     "count 용
         LV_TAB_CNT    TYPE I,
         "인터널테이블의loop수(sy-tabix)
         LV_CNT_MATDOC TYPE I,                     "총 자재문서의 수
         LV_STOP_DATE  TYPE I,                     "체류일
         LV_SUM        TYPE MARD-INSME,            "누적 수량
         LV_AD_SUM     TYPE MARD-INSME,            "이전 누적수량
         LV_WERKS_SUM  TYPE MARD-INSME,            "플랜트 총 재고
         LV_STOP_RATE  TYPE MARD-INSME,            "점유율
         LV_STOP_VALUE TYPE MARD-INSME,            "체류수량
         LV_MATNR      LIKE TEMP_ACT-MATNR,        "자재번호
         LV_WERKS      LIKE TEMP_ACT-WERKS,        "플랜트
         LV_CHARG      LIKE TEMP_ACT-CHARG,        "배치번호
         LV_LGORT      LIKE TEMP_ACT-LGORT,        "저장위치
         LV_MSHARE     TYPE N,                     "점유율
         LV_ERROR      TYPE C,                     "에러체크
         LV_STOP_P     TYPE C,                     "멈춤플래그
         LV_STOCKM     LIKE ZPPT0149-STOCKM,
         LV_STOCKMAF   LIKE ZPPT0149-STOCKMAF,
         LV_PRCTR      LIKE ZPPT0149J-PRCTR,            "손익센터
         LV_STOCKMBE   LIKE ZPPT0149-STOCKMBE.

  DATA : BEGIN OF LT_LGORT  OCCURS 0,
           LGORT LIKE  MCHB-LGORT,
         END OF LT_LGORT.

  CLEAR :  GV_E_CHECK.
  CLEAR :  TEMP_COLLECT, TEMP_COLLECT[], TEMP_ACT, TEMP_ACT[],
           TEMP_Z, TEMP_Z[].

  LOOP AT TEMP3.
    IF STRLEN( TEMP_ACT-LGORT ) <= 4.
      MOVE-CORRESPONDING TEMP3 TO TEMP_ACT.
      APPEND TEMP_ACT.
      CLEAR  TEMP_ACT.
    ENDIF.
  ENDLOOP.

  IF NOT TEMP_ACT[] IS INITIAL.
* 플랜트,자재코드,배치번호 sorting 하여
** 플랜트,자제코드,배치번호에 대한 합계 수량을 계산( 저장위치 무시)
    SORT TEMP_ACT BY WERKS MATNR CHARG.
    LOOP AT TEMP_ACT.
      CLEAR : TEMP_ACT-LGORT, TEMP_ACT-MEINS, TEMP_ACT-MTART,
              TEMP_ACT-PRCTR.
      COLLECT TEMP_ACT INTO TEMP_COLLECT.
      CLEAR : TEMP_COLLECT.
    ENDLOOP.

    LOOP AT TEMP_ACT.

      CLEAR : GV_STOP, GV_DATE, LV_CNT, LV_TAB_CNT, LV_CNT_MATDOC,
              LV_ERROR, LV_STOP_RATE, LV_SUM, LV_STOP_DATE, GV_MDATE,
              LV_WERKS_SUM, LV_STOP_P, LV_MSHARE.
      CLEAR : TEMP_0149, TEMP_0149[], TEMP_MATDOC, TEMP_MATDOC[],
              TEMP_CNT, TEMP_CNT[].

      CLEAR : LV_MATNR, LV_WERKS, LV_CHARG, LV_LGORT,
              LV_STOCKM, LV_STOCKMAF, LV_PRCTR.

      LV_MATNR = TEMP_ACT-MATNR.
      LV_WERKS = TEMP_ACT-WERKS.
      LV_CHARG = TEMP_ACT-CHARG.
      LV_LGORT = TEMP_ACT-LGORT.

      LV_STOCKM     = TEMP_ACT-STOCKM.
      LV_STOCKMAF   = TEMP_ACT-STOCKMAF.
** zppt0149j 와 zppt0149의 매칭되는 필드명이 다르기 때문에 맞게 연결
      TEMP_ACT-STOCKMBE = LV_STOCKM.
      TEMP_ACT-STOPM    = LV_STOCKM.
      TEMP_ACT-STOCKM   = LV_STOCKMAF.
**
* 저장위치가 거래처코드가 아닐 경우
      IF STRLEN( TEMP_ACT-LGORT ) <= 4.

        PERFORM SELECT_0149_MAXD USING LV_WERKS
                                       LV_MATNR
                                       LV_LGORT
                                       LV_CHARG.

* zppt0149에 없으면 matdoc 전체조회
        IF TEMP_0149[] IS INITIAL.  "기존 데이터가 없을 경우
*matdoc 에서 zppt0149의 생성일자 이후부터 플랜트,자재코드,배치번호에 대한
*전기일, 전기수량(=체류일수량), 단위, 자재문서번호,손익센터를 조회
          PERFORM SELECT_MATDOC_N_T0149 USING LV_WERKS
                                             LV_MATNR
                                             LV_LGORT
                                             LV_CHARG.

        ELSE.
*기존 데이터가 있을경우 그 데이터 이 후 부터 현재날짜까지 조회
*최근 자재문서 생성일에 다른 문서가 존재할경우 gv_cpudt, gv_cputm로 그
*이후꺼도포함
          LOOP AT TEMP_0149.  "temp_0149 데이터가 한건만 존재
            GV_DATE = TEMP_0149-BUDAT.
            GV_MDATE = TEMP_0149-MDATE.
          ENDLOOP.
          IF GV_DATE > P_DATE.
            GV_DATE = P_DATE.
          ENDIF.

          PERFORM SELECT_MATDOC_Y_T0149 USING LV_WERKS
                                             LV_MATNR
                                             LV_LGORT
                                             LV_CHARG
                                             GV_DATE.

        ENDIF.
** 자재문서가 없을경우 'Z'로 정보 추가
        IF TEMP_MATDOC[] IS INITIAL.
** sequence 번호 구하기
          PERFORM GET_SEQ USING TEMP_ACT-WERKS TEMP_ACT-MATNR
                                TEMP_ACT-LGORT TEMP_ACT-BRANCHG
                                TEMP_ACT-STOCKT
                                P_DATE GV_SEQ TEMP_ACT-CHARG.
          TEMP_ACT-SEQUENCE = GV_SEQ + 1.
** 저장위치내역 or 공급업체명 /자재내역 / 단가 / 금액 / 평가클랙스 /
*평가클래스내역
          PERFORM GET_TEMP2_DETAIL_DATA USING  TEMP_ACT-WERKS
          TEMP_ACT-MATNR
                                               TEMP_ACT-MBLNR
                                               TEMP_ACT-LGORT
                                               TEMP_ACT-STOPM
                                               TEMP_ACT-NAME1
                                               TEMP_ACT-MAKTX
                                               TEMP_ACT-STPRS
                                               TEMP_ACT-MONEY
                                               TEMP_ACT-BKLAS
                                               TEMP_ACT-BKBEZ
                                               LV_PRCTR.

          TEMP_ACT-STOPM    = TEMP_ACT-STOCKM.
          TEMP_ACT-MDATE    = P_DATE. "sy-datum.
          TEMP_ACT-BRANCHG  = 'Z'.
*          temp_act-meins    = ''.
          TEMP_ACT-STOPDATE = '31'.

          IF TEMP_ACT-CHARG = '' OR TEMP_ACT-CHARG IS INITIAL.
            TEMP_ACT-STOCKT = C_STOCKT_SNB.
            "배치번호가 없으면 Non batch
            TEMP_ACT-STTEXT = C_STTEXT_SNB.
            "배치번호가 없으면 Non batch
          ELSE.
            TEMP_ACT-STOCKT = C_STOCKT_SB.    "배치번호가 있을경우
            TEMP_ACT-STTEXT = C_STTEXT_SB.    "배치번호가 있을경우
          ENDIF.


** 아무것도 없는경우에 대하여 입력
          INSERT INTO ZPPT0149 VALUES TEMP_ACT.

          IF SY-SUBRC <> 0.
            ROLLBACK WORK.
          ELSE.
            COMMIT WORK.
          ENDIF.
        ELSE.
*    전기일이 최근인것 부터
          SORT TEMP_MATDOC DESCENDING BY BUDAT MBLNR.
** 전기수량 - temp_matdoc-menge / 플랜트 재고 수량 temp2-stockm
** 플랜트, 배치번호가 저장위치에 몇개 존재하는지 구분
          CLEAR : LT_LGORT, LT_LGORT[].
          TEMP_CNT[] = TEMP_ACT[].
          SORT TEMP_CNT ASCENDING BY MATNR CHARG.
          LOOP AT TEMP_CNT WHERE CHARG = LV_CHARG
                             AND MATNR = LV_MATNR.
*            AT NEW lgort.
*              lv_cnt = lv_cnt + 1.
*            ENDAT.
            LT_LGORT-LGORT = TEMP_CNT-LGORT.
            COLLECT LT_LGORT.
          ENDLOOP.

          DESCRIBE TABLE LT_LGORT LINES LV_CNT.

*플랜트 재고
          LOOP AT TEMP_COLLECT WHERE WERKS = LV_WERKS
                                 AND MATNR = LV_MATNR
                                 AND CHARG = LV_CHARG.
            "조건에 배치번호 포함

            LV_WERKS_SUM = LV_WERKS_SUM + TEMP_COLLECT-STOCKMAF.

          ENDLOOP.
** temp_matdoc 의 데이터 수 계산.
          DESCRIBE TABLE TEMP_MATDOC LINES LV_TAB_CNT.

** 현재 플랜트 재고의 수량과 입고 자재문서의 수량을 한건씩 sum하여
          LOOP AT TEMP_MATDOC WHERE WERKS = LV_WERKS
                               AND MATNR = LV_MATNR
                               AND CHARG = LV_CHARG.
            "조건에 배치번호 포함
            LV_CNT_MATDOC = LV_CNT_MATDOC + 1.

            IF LV_STOP_P <> 'X'.
              LV_AD_SUM = LV_SUM.                  "이전 누적수량
              LV_SUM = LV_SUM + TEMP_MATDOC-MENGE.  "현재 누적수량
** 창고재고 수량보다 많은 시점까지의 자재문서를 찾아 마지막 자제문서의
** 전기일로 체류일을 계산
** 재고유형을 사내 NON 배치재고 '2'로 한다
              IF TEMP_ACT-CHARG = '' OR TEMP_ACT-CHARG IS INITIAL.
                TEMP_ACT-STOCKT = C_STOCKT_SNB.
                "배치번호가 없으면 Non batch
                TEMP_ACT-STTEXT = C_STTEXT_SNB.
                "배치번호가 없으면 Non batch
              ELSE.
                TEMP_ACT-STOCKT = C_STOCKT_SB.    "배치번호가 있을경우
                TEMP_ACT-STTEXT = C_STTEXT_SB.    "배치번호가 있을경우
              ENDIF.
              TEMP_ACT-BUDAT = TEMP_MATDOC-BUDAT.      "자재문서의 전기일
              TEMP_ACT-MENGE = TEMP_MATDOC-MENGE.      "전기수량
              TEMP_ACT-MEINS = TEMP_MATDOC-MEINS.      "단위
              TEMP_ACT-MBLNR = TEMP_MATDOC-MBLNR.      "자재문서번호
              TEMP_ACT-BWART = TEMP_MATDOC-BWART.      "이동유형
              TEMP_ACT-MDATE = P_DATE.                "생성일
**
              TEMP_ACT-STOCKMBE = LV_STOCKM.
              TEMP_ACT-STOCKM   = LV_STOCKMAF.
              CLEAR : TEMP_ACT-STOCKMAF.
**
** 17XX 플랜트일 경우 점유율을 100으로 계산하기 위하여
              IF TEMP_ACT-WERKS+0(2) = '37'.
                LV_WERKS_SUM = TEMP_ACT-STOCKM.
              ENDIF.
* 점유율 > 창고별 재고(temp_act-stockm) / 플랜트 총재고 (lv_werks_sum)
              IF LV_WERKS_SUM = 0 OR LV_WERKS_SUM IS INITIAL.
                TEMP_ACT-RATE = 0.
              ELSE.
                TEMP_ACT-RATE  = TEMP_ACT-STOCKM / LV_WERKS_SUM.
              ENDIF.
** zppt0149에 넣을 데이터용 점유률 ( * 100 ) XX.XXX  표시
              PERFORM VALUE_ROUND_RATE USING TEMP_ACT-RATE
              TEMP_ACT-MSHARE
                                             LV_ERROR.

              IF LV_WERKS_SUM >= LV_SUM .
                "창고재고보다 작거나 같은 시점.
                IF LV_WERKS_SUM = LV_SUM.  "같은 경우 멈춤.
** 전기일 기준으로 현재일자를 계산하여 체류일을 계산
                  TEMP_ACT-MENGE_LAST = TEMP_ACT-MENGE.
                  MOVE-CORRESPONDING TEMP_ACT TO TEMP_Z_UP.
                  APPEND TEMP_Z_UP.
                  CLEAR  TEMP_Z_UP.

                  LV_STOP_P = 'X'.
                ELSE.
                  TEMP_ACT-MENGE_LAST = TEMP_ACT-MENGE.
                  MOVE-CORRESPONDING TEMP_ACT TO TEMP_Z_UP.

                  APPEND TEMP_Z_UP.
                  CLEAR  TEMP_Z_UP.
** 창고재고보다 작지만 자재문서가 마지막일 경우
                  IF LV_TAB_CNT = LV_CNT_MATDOC.
                    IF LV_WERKS_SUM <> LV_SUM.
                      TEMP_ACT-MENGE_LAST = LV_WERKS_SUM - LV_SUM.
                      "모자란 체류수량
                      TEMP_ACT-FLAG_E = 'X'.
                      MOVE-CORRESPONDING TEMP_ACT TO TEMP_Z_UP.

                      APPEND TEMP_Z_UP.
                      CLEAR  TEMP_Z_UP.
                    ENDIF.
                    LV_STOP_P = 'X'.
                    LV_ERROR  = 'X'.
                  ENDIF.
                ENDIF.
              ELSE.
* 창고재고 수량보다 많은 시점 / 마지막으로 많은 부분의 데이터까지 포함.
** 전기일 기준으로 현재일자를 계산하여 체류일을 계산
                TEMP_ACT-MENGE_LAST = LV_WERKS_SUM - LV_AD_SUM.
                MOVE-CORRESPONDING TEMP_ACT TO TEMP_Z_UP.
                APPEND TEMP_Z_UP.
                CLEAR  TEMP_Z_UP.

                LV_STOP_P = 'X'.
                "마지막 체류일/분류그룹까지 계산후 멈춤
              ENDIF.
            ENDIF.
          ENDLOOP.


          LOOP AT TEMP_Z_UP WHERE WERKS = LV_WERKS
                              AND MATNR = LV_MATNR
                              AND CHARG = LV_CHARG.

            CLEAR : GV_SEQ, LV_STOP_VALUE.

** 17XX 플랜트일 경우 '플랜트, 자재번호가 저장위치에 1개만 존재하는
*경우'와 같게
            IF LV_WERKS+0(2) = '37'.
              LV_CNT = 1.
            ENDIF.
** 플랜트, 자재번호가 저장위치에 1개만 존재하는 경우
            IF LV_CNT = 1.
              TEMP_Z_UP-STOPM = TEMP_Z_UP-MENGE_LAST.   "체류수량
            ELSE.
              IF LV_WERKS+0(2) = '37'.  "17XX 플랜트일 경우
                TEMP_Z_UP-STOPM = TEMP_Z_UP-MENGE_LAST.   "체류수량
              ELSE.
** 플랜트,배치번호가 저장위치에 다수로 존재할 경우
                PERFORM VALUE_ROUND USING TEMP_Z_UP-RATE
                TEMP_Z_UP-MENGE_LAST
                                          LV_STOP_VALUE  LV_ERROR.
                TEMP_Z_UP-STOPM = LV_STOP_VALUE.     "체류수량
              ENDIF.
            ENDIF.
** 저장위치내역 or 공급업체명 /자재내역 / 단가 / 금액
            PERFORM GET_TEMP2_DETAIL_DATA USING  TEMP_Z_UP-WERKS
            TEMP_Z_UP-MATNR
                                                 TEMP_Z_UP-MBLNR
                                                 TEMP_Z_UP-LGORT
                                                 TEMP_Z_UP-STOPM
                                                 TEMP_Z_UP-NAME1
                                                 TEMP_Z_UP-MAKTX
                                                 TEMP_Z_UP-STPRS
                                                 TEMP_Z_UP-MONEY
                                                 TEMP_Z_UP-BKLAS
                                                 TEMP_Z_UP-BKBEZ
                                                 LV_PRCTR.
** 체류일
            GV_STOP = P_DATE - TEMP_Z_UP-BUDAT.
            TEMP_Z_UP-STOPDATE = GV_STOP.

*** 분류그룹 구하기
            PERFORM BRANCHG_GET USING GV_STOP TEMP_Z_UP-BRANCHG.
** sequence 번호 구하기
            PERFORM GET_SEQ USING TEMP_Z_UP-WERKS TEMP_Z_UP-MATNR
                                  TEMP_Z_UP-LGORT TEMP_Z_UP-BRANCHG
                                  TEMP_Z_UP-STOCKT
                                  P_DATE GV_SEQ TEMP_Z_UP-CHARG.
            TEMP_Z_UP-SEQUENCE = GV_SEQ + 1.
**
** 자재문서가 모자랄 경우
            IF TEMP_Z_UP-FLAG_E = 'X'.
              CLEAR : TEMP_Z_UP-MBLNR,
                      TEMP_Z_UP-BUDAT,
                      TEMP_Z_UP-MENGE,
*                      temp_z_up-meins,
                      TEMP_Z_UP-BWART.

              TEMP_Z_UP-STOPDATE = LV_STOP_DATE.
              TEMP_Z_UP-BRANCHG = C_BRANCHG_Z.

              IF TEMP_Z_UP-CHARG = '' OR TEMP_Z_UP-CHARG IS INITIAL.
                TEMP_Z_UP-STOCKT = C_STOCKT_SNB.
                "배치번호가 없으면 Non batch
                TEMP_Z_UP-STTEXT = C_STTEXT_SNB.
                "배치번호가 없으면 Non batch
              ELSE.
                TEMP_Z_UP-STOCKT = C_STOCKT_SB.    "배치번호가 있을경우
                TEMP_Z_UP-STTEXT = C_STTEXT_SB.    "배치번호가 있을경우
              ENDIF.


            ENDIF.
**
** 30 일 이상이면 CBO 저장 임시 테이블에 저장
            IF TEMP_Z_UP-WERKS(1) EQ '2'. "C20130518_33537:U
              "SRM2102-04681
              CHECK TEMP_Z_UP-STOPDATE >= 0 OR
                    TEMP_Z_UP-BRANCHG = 'Z'.
            ELSE.
              CHECK TEMP_Z_UP-STOPDATE >= 31 OR
                    TEMP_Z_UP-BRANCHG = 'Z'.
            ENDIF.

            IF SY-TABIX = 1.
              LV_STOP_DATE = TEMP_Z_UP-STOPDATE.
              "입력된 가장 최근문서의 체류일
            ENDIF.

            INSERT INTO ZPPT0149 VALUES TEMP_Z_UP.

            IF SY-SUBRC <> 0.
***** 추 후 몇건당 commit/rollback 할지에 대한 협의 필요
              ROLLBACK WORK.
            ELSE.
              COMMIT WORK.
            ENDIF.

          ENDLOOP.

          CLEAR : TEMP_Z_UP, TEMP_Z_UP[].

        ENDIF.

      ENDIF.

    ENDLOOP.

  ENDIF.

ENDFORM.                    " BATCN_NO_BC
*&---------------------------------------------------------------------*
*&      Form  NO_BATCH
*&---------------------------------------------------------------------*
*       text : 배치관리 하지 않는 데이타**
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM NO_BATCH .
** 로컬 변수 선언
  DATA : LV_CNT        TYPE I,
         LV_TAB_CNT    TYPE I,
         LV_CNT_MATDOC TYPE I,
         LV_STOP_DATE  TYPE I,
         LV_SUM        TYPE MARD-INSME,       "누적 수량
         LV_AD_SUM     TYPE MARD-INSME,       "이전 누적수량
         LV_WERKS_SUM  TYPE MARD-INSME,
         LV_STOP_RATE  TYPE MARD-INSME,
         LV_STOP_VALUE TYPE MARD-INSME,
         LV_MATNR      LIKE TEMP_ACT-MATNR,
         LV_WERKS      LIKE TEMP_ACT-WERKS,
         LV_CHARG      LIKE TEMP_ACT-CHARG,
         LV_LGORT      LIKE TEMP_ACT-LGORT,
         LV_ERROR      TYPE C,
         LV_STOP_P     TYPE C,
         LV_PRCTR      LIKE ZPPT0149J-PRCTR,  "손익센터
         LV_STOCKM     LIKE ZPPT0149-STOCKM,
         LV_STOCKMAF   LIKE ZPPT0149-STOCKMAF,
         LV_STOCKMBE   LIKE ZPPT0149-STOCKMBE.

  DATA : BEGIN OF LT_LGORT  OCCURS 0,
           LGORT LIKE  MCHB-LGORT,
         END OF LT_LGORT.

  CLEAR :  GV_E_CHECK.
  CLEAR :  TEMP_COLLECT, TEMP_COLLECT[], TEMP_ACT, TEMP_ACT[], TEMP_Z,
  TEMP_Z[].

  LOOP AT TEMP1.
    IF STRLEN( TEMP_ACT-LGORT ) <= 4.
      MOVE-CORRESPONDING TEMP1 TO TEMP_ACT.
      APPEND TEMP_ACT.
      CLEAR  TEMP_ACT.
    ENDIF.
  ENDLOOP.

  IF NOT TEMP_ACT[] IS INITIAL.
* 플랜트,자재코드 sorting 하여
** 플랜트,자제코드에 대한 합계 수량을 계산( 저장위치 무시)
    SORT TEMP_ACT BY WERKS MATNR.
    LOOP AT TEMP_ACT.
      CLEAR : TEMP_ACT-LGORT, TEMP_ACT-MEINS, TEMP_ACT-CHARG,
              TEMP_ACT-MTART, TEMP_ACT-PRCTR.
      COLLECT TEMP_ACT INTO TEMP_COLLECT.
      CLEAR : TEMP_COLLECT.
    ENDLOOP.

    LOOP AT TEMP_ACT.

      CLEAR : GV_STOP, GV_DATE, LV_CNT, LV_TAB_CNT,
              LV_CNT_MATDOC, LV_ERROR, LV_STOP_DATE, GV_MDATE,
              LV_STOP_RATE, LV_SUM, LV_WERKS_SUM, LV_STOP_P.
      CLEAR : TEMP_0149, TEMP_0149[], TEMP_MATDOC, TEMP_MATDOC[],
              TEMP_CNT, TEMP_CNT[].

      CLEAR : LV_MATNR, LV_WERKS, LV_CHARG,
              LV_STOCKM, LV_STOCKMAF, LV_PRCTR.

      LV_MATNR = TEMP_ACT-MATNR.
      LV_WERKS = TEMP_ACT-WERKS.
      LV_CHARG = TEMP_ACT-CHARG.
      LV_LGORT = TEMP_ACT-LGORT.

      LV_STOCKM     = TEMP_ACT-STOCKM.
      LV_STOCKMAF   = TEMP_ACT-STOCKMAF.
**
      TEMP_ACT-STOCKMBE = LV_STOCKM.
      TEMP_ACT-STOPM    = LV_STOCKM.
      TEMP_ACT-STOCKM   = LV_STOCKMAF.
**
* 저장위치가 거래처코드가 아닐 경우
      IF STRLEN( TEMP_ACT-LGORT ) <= 4.

* zppt0149의 플랜트,자재코드,거래처코드에 대한 가장 최근 생성일에 대한
* 전기일, 전기수량,단위, 자재문서번호,손익센터를 조회하고
        PERFORM SELECT_0149_MAXD USING LV_WERKS
                                       LV_MATNR
                                       LV_LGORT
                                       LV_CHARG.

* zppt0149에 없으면 matdoc 전체조회
        IF TEMP_0149[] IS INITIAL.  "기존 데이터가 없을 경우
*matdoc 에서 zppt0149의 생성일자 이후부터 플랜트,자재코드,배치번호에 대한
*전기일, 전기수량(=체류일수량), 단위, 자재문서번호,손익센터를 조회
          PERFORM SELECT_MATDOC_N_T0149 USING LV_WERKS
                                             LV_MATNR
                                             LV_LGORT
                                             LV_CHARG.


        ELSE.
          "기존 데이터가 있을경우 그 데이터 이 후 부터 현재날짜까지 조회

          LOOP AT TEMP_0149.  "temp_0149 데이터가 한건만 존재
            GV_DATE = TEMP_0149-BUDAT.
            GV_MDATE = TEMP_0149-MDATE.
          ENDLOOP.
          IF GV_DATE > P_DATE.
            GV_DATE = P_DATE.
          ENDIF.

          PERFORM SELECT_MATDOC_Y_T0149 USING LV_WERKS
                                             LV_MATNR
                                             LV_LGORT
                                             LV_CHARG
                                             GV_DATE.

        ENDIF.
** 자재문서가 없을경우
        IF TEMP_MATDOC[] IS INITIAL.
** sequence 번호 구하기
          PERFORM GET_SEQ USING TEMP_ACT-WERKS TEMP_ACT-MATNR
                                TEMP_ACT-LGORT TEMP_ACT-BRANCHG
                                TEMP_ACT-STOCKT
                                P_DATE GV_SEQ TEMP_ACT-CHARG.
          TEMP_ACT-SEQUENCE = GV_SEQ + 1.
** 저장위치내역 or 공급업체명 /자재내역 / 단가 / 금액 / 평가클랙스 /
*평가클래스내역
          PERFORM GET_TEMP2_DETAIL_DATA USING  TEMP_ACT-WERKS
          TEMP_ACT-MATNR
                                               TEMP_ACT-MBLNR
                                               TEMP_ACT-LGORT
                                               TEMP_ACT-STOPM
                                               TEMP_ACT-NAME1
                                               TEMP_ACT-MAKTX
                                               TEMP_ACT-STPRS
                                               TEMP_ACT-MONEY
                                               TEMP_ACT-BKLAS
                                               TEMP_ACT-BKBEZ
                                               LV_PRCTR.

          TEMP_ACT-STOPM    = TEMP_ACT-STOCKM.
          TEMP_ACT-MDATE    = P_DATE. "sy-datum.
          TEMP_ACT-BRANCHG  = 'Z'.
*          temp_act-meins    = ''.
          TEMP_ACT-STOPDATE = '31'.

          IF TEMP_ACT-CHARG = '' OR TEMP_ACT-CHARG IS INITIAL.
            TEMP_ACT-STOCKT = C_STOCKT_SNB.
            "배치번호가 없으면 Non batch
            TEMP_ACT-STTEXT = C_STTEXT_SNB.
            "배치번호가 없으면 Non batch
          ELSE.
            TEMP_ACT-STOCKT = C_STOCKT_SB.    "배치번호가 있을경우
            TEMP_ACT-STTEXT = C_STTEXT_SB.    "배치번호가 있을경우
          ENDIF.

** 아무것도 없는경우에 대하여 입력
          INSERT INTO ZPPT0149 VALUES TEMP_ACT.

          IF SY-SUBRC <> 0.
            ROLLBACK WORK.
          ELSE.
            COMMIT WORK.
          ENDIF.
        ELSE.
*    전기일이 최근인것 부터
          SORT TEMP_MATDOC DESCENDING BY BUDAT MBLNR.

** 전기수량 - temp_matdoc-menge / 플랜트 재고 수량 temp2-stockm
** 플랜트, 자재코드가 저장위치에 몇개 존재하는지 구분
          TEMP_CNT[] = TEMP_ACT[].
          SORT TEMP_CNT ASCENDING BY MATNR WERKS.
*          LOOP AT temp_cnt WHERE werks = lv_werks
*                             AND matnr = lv_matnr.
*
*            AT NEW lgort.
*              lv_cnt = lv_cnt + 1.
*            ENDAT.
*
*          ENDLOOP.
          LOOP AT TEMP_CNT WHERE WERKS = LV_WERKS
                             AND MATNR = LV_MATNR.
            LT_LGORT-LGORT = TEMP_CNT-LGORT.
            COLLECT LT_LGORT.
          ENDLOOP.

          DESCRIBE TABLE LT_LGORT LINES LV_CNT.

*플랜트 재고
          LOOP AT TEMP_COLLECT WHERE WERKS = LV_WERKS
                                 AND MATNR = LV_MATNR.

            LV_WERKS_SUM = LV_WERKS_SUM + TEMP_COLLECT-STOCKMAF.

          ENDLOOP.

** temp_matdoc 의 데이터 수 계산.
          DESCRIBE TABLE TEMP_MATDOC LINES LV_TAB_CNT.

** 현재 플랜트 재고의 수량과 입고 자재문서의 수량을 한건씩 sum하여
          LOOP AT TEMP_MATDOC WHERE WERKS = LV_WERKS
                               AND MATNR = LV_MATNR.

            LV_CNT_MATDOC = LV_CNT_MATDOC + 1.

            IF LV_STOP_P <> 'X'.

              LV_AD_SUM = LV_SUM.                  "이전 누적수량
              LV_SUM = LV_SUM + TEMP_MATDOC-MENGE.  "현재 누적수량
** 창고재고 수량보다 많은 시점까지의 자재문서를 찾아 마지막 자제문서의
** 전기일로 체류일을 계산
** 재고유형을 사내 NON 배치재고 '2'로 한다
              IF TEMP_ACT-CHARG = '' OR TEMP_ACT-CHARG IS INITIAL.
                TEMP_ACT-STOCKT = C_STOCKT_SNB.
                "배치번호가 없으면 Non batch
                TEMP_ACT-STTEXT = C_STTEXT_SNB.
                "배치번호가 없으면 Non batch
              ELSE.
                TEMP_ACT-STOCKT = C_STOCKT_SB.    "배치번호가 있을경우
                TEMP_ACT-STTEXT = C_STTEXT_SB.    "배치번호가 있을경우
              ENDIF.
              TEMP_ACT-BUDAT = TEMP_MATDOC-BUDAT.      "자재문서의 전기일
              TEMP_ACT-MENGE = TEMP_MATDOC-MENGE.      "전기수량
              TEMP_ACT-MEINS = TEMP_MATDOC-MEINS.      "단위
              TEMP_ACT-MBLNR = TEMP_MATDOC-MBLNR.      "자재문서번호
              TEMP_ACT-BWART = TEMP_MATDOC-BWART.      "이동유형
              TEMP_ACT-MDATE    = P_DATE. "sy-datum.  "생성일
**
              TEMP_ACT-STOCKMBE = LV_STOCKM.
              TEMP_ACT-STOCKM   = LV_STOCKMAF.
              CLEAR : TEMP_ACT-STOCKMAF.
**
** 17XX 플랜트일 경우
              IF TEMP_ACT-WERKS+0(2) = '37'.
                LV_WERKS_SUM = TEMP_ACT-STOCKM.
              ENDIF.
** 17XX 플랜트일 경우
              IF TEMP_ACT-WERKS+0(2) = '37'.
                LV_WERKS_SUM = TEMP_ACT-STOCKM.
              ENDIF.
* 점유율 > 창고별 재고(temp_act-stockm) / 플랜트 총재고 (lv_werks_sum)
              IF LV_WERKS_SUM = 0 OR LV_WERKS_SUM IS INITIAL.
                TEMP_ACT-RATE = 0.
              ELSE.
                TEMP_ACT-RATE  = TEMP_ACT-STOCKM / LV_WERKS_SUM.
              ENDIF.

** zppt0149에 넣을 데이터용 점유률 ( * 100 )
              PERFORM VALUE_ROUND_RATE USING TEMP_ACT-RATE
              TEMP_ACT-MSHARE
                                             LV_ERROR.

              IF LV_WERKS_SUM >= LV_SUM .
                "창고재고보다 작거나 같은 시점.
                IF LV_WERKS_SUM = LV_SUM.  "같은 경우 멈춤.
** 전기일 기준으로 현재일자를 계산하여 체류일을 계산
                  TEMP_ACT-MENGE_LAST = TEMP_ACT-MENGE.
                  MOVE-CORRESPONDING TEMP_ACT TO TEMP_Z_UP.
                  APPEND TEMP_Z_UP.
                  CLEAR  TEMP_Z_UP.

                  LV_STOP_P = 'X'.
                ELSE.
                  TEMP_ACT-MENGE_LAST = TEMP_ACT-MENGE.
                  MOVE-CORRESPONDING TEMP_ACT TO TEMP_Z_UP.

                  APPEND TEMP_Z_UP.
                  CLEAR  TEMP_Z_UP.
** 창고재고보다 작지만 자재문서가 마지막일 경우
                  IF LV_TAB_CNT = LV_CNT_MATDOC.
** 전기일 기준으로 현재일자를 계산하여 체류일을 계산
                    IF LV_WERKS_SUM <> LV_SUM.
                      TEMP_ACT-MENGE_LAST = LV_WERKS_SUM - LV_SUM.
                      "모자란 체류수량
                      TEMP_ACT-FLAG_E = 'X'.
                      MOVE-CORRESPONDING TEMP_ACT TO TEMP_Z_UP.

                      APPEND TEMP_Z_UP.
                      CLEAR  TEMP_Z_UP.
                    ENDIF.

                    LV_STOP_P = 'X'.
                    LV_ERROR  = 'X'.
                  ENDIF.

                ENDIF.
              ELSE.
* 창고재고 수량보다 많은 시점 / 마지막으로 많은 부분의 데이터까지 포함.
** 전기일 기준으로 현재일자를 계산하여 체류일을 계산
                TEMP_ACT-MENGE_LAST = LV_WERKS_SUM - LV_AD_SUM.
                MOVE-CORRESPONDING TEMP_ACT TO TEMP_Z_UP.

                APPEND TEMP_Z_UP.
                CLEAR  TEMP_Z_UP.

                LV_STOP_P = 'X'.
                "마지막 체류일/분류그룹까지 계산후 멈춤

              ENDIF.

            ENDIF.

          ENDLOOP.


          LOOP AT TEMP_Z_UP WHERE WERKS = LV_WERKS
                              AND MATNR = LV_MATNR.

            CLEAR : GV_SEQ, LV_STOP_VALUE.

** 17XX 플랜트일 경우 '플랜트, 자재번호가 저장위치에 1개만 존재하는
*경우'와 같게
            IF LV_WERKS+0(2) = '37'.
              LV_CNT = 1.
            ENDIF.
** 플랜트, 자재번호가 저장위치에 1개만 존재하는 경우
            IF LV_CNT = 1.
              TEMP_Z_UP-STOPM = TEMP_Z_UP-MENGE_LAST.   "체류수량
            ELSE.
** 플랜트,배치번호가 저장위치에 다수로 존재할 경우
              PERFORM VALUE_ROUND USING TEMP_Z_UP-RATE
              TEMP_Z_UP-MENGE_LAST
                                        LV_STOP_VALUE  LV_ERROR.
              TEMP_Z_UP-STOPM = LV_STOP_VALUE.     "체류수량
            ENDIF.
** 저장위치내역 or 공급업체명 /자재내역 / 단가 / 금액
            PERFORM GET_TEMP2_DETAIL_DATA USING  TEMP_Z_UP-WERKS
            TEMP_Z_UP-MATNR
                                                 TEMP_Z_UP-MBLNR
                                                 TEMP_Z_UP-LGORT
                                                 TEMP_Z_UP-STOPM
                                                 TEMP_Z_UP-NAME1
                                                 TEMP_Z_UP-MAKTX
                                                 TEMP_Z_UP-STPRS
                                                 TEMP_Z_UP-MONEY
                                                 TEMP_Z_UP-BKLAS
                                                 TEMP_Z_UP-BKBEZ
                                                 LV_PRCTR.
** 체류일 / 분류그룹
            GV_STOP = P_DATE - TEMP_Z_UP-BUDAT.
            TEMP_Z_UP-STOPDATE = GV_STOP.  "체류일

            PERFORM BRANCHG_GET USING GV_STOP TEMP_Z_UP-BRANCHG.
            "분류그룹 구하기

** sequence 번호 구하기
            PERFORM GET_SEQ USING TEMP_Z_UP-WERKS TEMP_Z_UP-MATNR
                                  TEMP_Z_UP-LGORT TEMP_Z_UP-BRANCHG
                                  TEMP_Z_UP-STOCKT
                                  P_DATE GV_SEQ TEMP_Z_UP-CHARG.
            TEMP_Z_UP-SEQUENCE = GV_SEQ + 1.

** 자재문서가 모자랄 경우
            IF TEMP_Z_UP-FLAG_E = 'X'.
              CLEAR : TEMP_Z_UP-MBLNR,
                      TEMP_Z_UP-BUDAT,
                      TEMP_Z_UP-MENGE,
*                      temp_z_up-meins,
                      TEMP_Z_UP-BWART.

              TEMP_Z_UP-STOPDATE = LV_STOP_DATE.
              TEMP_Z_UP-BRANCHG = C_BRANCHG_Z.

              IF TEMP_Z_UP-CHARG = '' OR TEMP_Z_UP-CHARG IS INITIAL.
                TEMP_Z_UP-STOCKT = C_STOCKT_SNB.
                "배치번호가 없으면 Non batch
                TEMP_Z_UP-STTEXT = C_STTEXT_SNB.
                "배치번호가 없으면 Non batch
              ELSE.
                TEMP_Z_UP-STOCKT = C_STOCKT_SB.    "배치번호가 있을경우
                TEMP_Z_UP-STTEXT = C_STTEXT_SB.    "배치번호가 있을경우
              ENDIF.


            ENDIF.
** 30 일 이상이면 CBO 저장 임시 테이블에 저장
            IF TEMP_Z_UP-WERKS(1) EQ '2'. "C20130518_33537:U
              "SRM2102-04681
              CHECK TEMP_Z_UP-STOPDATE >= 0 OR
                    TEMP_Z_UP-BRANCHG = 'Z'. .
            ELSE.
              CHECK TEMP_Z_UP-STOPDATE >= 31 OR
                    TEMP_Z_UP-BRANCHG = 'Z'.
            ENDIF.

            IF SY-TABIX = 1.
              LV_STOP_DATE = TEMP_Z_UP-STOPDATE.
              "입력된 가장 최근문서의 체류일
            ENDIF.

            INSERT INTO ZPPT0149 VALUES TEMP_Z_UP.

            IF SY-SUBRC <> 0.
              ROLLBACK WORK.
            ELSE.
              COMMIT WORK.
            ENDIF.

          ENDLOOP.
          CLEAR : TEMP_Z_UP, TEMP_Z_UP[].

        ENDIF.

      ENDIF.

    ENDLOOP.

  ENDIF.

ENDFORM.                    " NO_BATCH
*&---------------------------------------------------------------------*
*&      Form  OUT_COM
*&---------------------------------------------------------------------*
*       text : 외주 배치/Non 배치 데이타**
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM OUT_COM .
  DATA : LV_CNT        TYPE I,                "
         LV_TAB_CNT    TYPE I,                "해당 loop의 반복수
         LV_STOP_DATE  TYPE I,
         "오류일 경우의 체류일 계산
         LV_CNT_MATDOC TYPE I,
         "matdoc 조회 테이블의 라인수
         LV_ERROR      TYPE C,
         "창고수량에비해 전기량이부족할때
         LV_STOP_P     TYPE C,                "조건문 구분자
         LV_SUM        TYPE MARD-INSME,       "누적 재고 수량
         LV_AD_SUM     TYPE MARD-INSME,       "이전 누적 수량
         LV_WERKS_SUM  TYPE MARD-INSME,       "플랜트내 재고 수량
         LV_STOP_RATE  TYPE MARD-INSME,       "점유율
         LV_STOP_VALUE TYPE MARD-INSME,       "체류수량
         LV_MATNR      LIKE TEMP_ACT-MATNR,   "자재번호
         LV_WERKS      LIKE TEMP_ACT-WERKS,   "플랜트
         LV_CHARG      LIKE TEMP_ACT-CHARG,   "배치번호
         LV_LGORT      LIKE TEMP_ACT-LGORT,   "거래처코드(저장위치)
         LV_PRCTR      LIKE ZPPT0149J-PRCTR,  "손익센터
         LV_STOCKM     LIKE ZPPT0149-STOCKM,
         LV_STOCKMAF   LIKE ZPPT0149-STOCKMAF,
         LV_STOCKMBE   LIKE ZPPT0149-STOCKMBE.

  CLEAR :  GV_E_CHECK.
  CLEAR :  TEMP_COLLECT, TEMP_COLLECT[], TEMP_ACT, TEMP_ACT[].

  LOOP AT TEMP4.
    IF STRLEN( TEMP4-LGORT ) > 4.

      MOVE-CORRESPONDING TEMP4 TO TEMP_ACT.
      APPEND TEMP_ACT.
      CLEAR  TEMP_ACT.

    ENDIF.
  ENDLOOP.

  IF NOT TEMP_ACT[] IS INITIAL.
* 플랜트,자재코드,거래처코드, 배치번호(없을수도 있음) sorting 하여
** 플랜트,자제코드,거래처,배치번호별에 대한 합계 수량을 계산( 저장위치
*무시)
    SORT TEMP_ACT BY WERKS MATNR LGORT CHARG.
    LOOP AT TEMP_ACT.
      CLEAR : TEMP4-XCHPF, TEMP4-MTART.
      COLLECT TEMP_ACT INTO TEMP_COLLECT.
      CLEAR : TEMP_COLLECT.
    ENDLOOP.

    LOOP AT TEMP_ACT.
      CLEAR : GV_STOP, GV_DATE, LV_CNT, LV_TAB_CNT,
              LV_CNT_MATDOC, LV_ERROR, LV_STOP_DATE, GV_MDATE,
              LV_STOP_RATE, LV_SUM, LV_WERKS_SUM, LV_STOP_P.
      CLEAR : TEMP_0149, TEMP_0149[], TEMP_MATDOC, TEMP_MATDOC[],
              TEMP_Z, TEMP_Z[], TEMP_CNT, TEMP_CNT[].

      CLEAR : LV_MATNR, LV_WERKS, LV_CHARG, LV_LGORT,
              LV_STOCKM, LV_STOCKMAF, LV_PRCTR.

      LV_MATNR = TEMP_ACT-MATNR.
      LV_WERKS = TEMP_ACT-WERKS.
      LV_CHARG = TEMP_ACT-CHARG.
      LV_LGORT = TEMP_ACT-LGORT.

      LV_STOCKM     = TEMP_ACT-STOCKM.
      LV_STOCKMAF   = TEMP_ACT-STOCKMAF.

**
      TEMP_ACT-STOCKMBE = LV_STOCKM.
      TEMP_ACT-STOPM    = LV_STOCKM.
      TEMP_ACT-STOCKM   = LV_STOCKMAF.
**
* 저장위치가 거래처코드일 경우
      IF STRLEN( TEMP_ACT-LGORT ) > 4.

* zppt0149의 플랜트,자재코드,거래처코드에 대한 가장 최근 생성일에 대한
* 전기일, 전기수량,단위, 자재문서번호,손익센터를 조회하고

*& 2008.04.29 수정( 나중에 주석 풀것 )
        PERFORM SELECT_0149_MAXD USING LV_WERKS
                                       LV_MATNR
                                       LV_LGORT
                                       LV_CHARG.

* zppt0149에 없으면 matdoc 전체조회
        IF TEMP_0149[] IS INITIAL.  "기존 데이터가 없을 경우
*matdoc 에서 zppt0149의 생성일자 이후부터 플랜트,자재코드,배치번호에 대한
*전기일, 전기수량(=체류일수량), 단위, 자재문서번호,손익센터를 조회
          PERFORM SELECT_MATDOC_N_T0149 USING LV_WERKS
                                             LV_MATNR
                                             LV_LGORT
                                             LV_CHARG.


        ELSE.
          "기존 데이터가 있을경우 그 데이터 이 후 부터 현재날짜까지 조회

          LOOP AT TEMP_0149.  "temp_0149 데이터가 한건만 존재
            GV_DATE = TEMP_0149-BUDAT.
            GV_MDATE = TEMP_0149-MDATE.
          ENDLOOP.
          IF GV_DATE > P_DATE.
            GV_DATE = P_DATE.
          ENDIF.

          PERFORM SELECT_MATDOC_Y_T0149 USING LV_WERKS
                                             LV_MATNR
                                             LV_LGORT
                                             LV_CHARG
                                             GV_DATE.

        ENDIF.

** 자재문서가 없을경우 'Z', 새로운 로우 추가
        IF TEMP_MATDOC[] IS INITIAL.
*          temp_matdoc-meins = ''.
** sequence 번호 구하기
          PERFORM GET_SEQ USING TEMP_ACT-WERKS TEMP_ACT-MATNR
                                TEMP_ACT-LGORT TEMP_ACT-BRANCHG
                                TEMP_ACT-STOCKT
                                P_DATE GV_SEQ TEMP_ACT-CHARG.
          TEMP_ACT-SEQUENCE = GV_SEQ + 1.

          TEMP_ACT-MDATE    = P_DATE. "sy-datum.
          TEMP_ACT-BRANCHG  = 'Z'.
          TEMP_ACT-STOPDATE = '31'.

          IF TEMP_ACT-CHARG = '' OR TEMP_ACT-CHARG IS INITIAL.
            TEMP_ACT-STOCKT = C_STOCKT_ONB.
            "배치번호가 없으면 Non batch
            TEMP_ACT-STTEXT = C_STTEXT_ONB.
            "배치번호가 없으면 Non batch
          ELSE.
            TEMP_ACT-STOCKT = C_STOCKT_OB.    "배치번호가 있을경우
            TEMP_ACT-STTEXT = C_STTEXT_OB.    "배치번호가 있을경우
          ENDIF.


** 저장위치내역 or 공급업체명 /자재내역 / 단가 / 금액 / 평가클랙스 /
*평가클래스내역
          PERFORM GET_TEMP2_DETAIL_DATA USING  TEMP_ACT-WERKS
          TEMP_ACT-MATNR
                                               TEMP_ACT-MBLNR
                                               TEMP_ACT-LGORT
                                               TEMP_ACT-STOPM
                                               TEMP_ACT-NAME1
                                               TEMP_ACT-MAKTX
                                               TEMP_ACT-STPRS
                                               TEMP_ACT-MONEY
                                               TEMP_ACT-BKLAS
                                               TEMP_ACT-BKBEZ
                                               LV_PRCTR.

          CLEAR : TEMP_ACT-STOCKMAF.
** 아무것도 없는경우에 대하여 입력
          INSERT INTO ZPPT0149 VALUES TEMP_ACT.

          IF SY-SUBRC <> 0.
            ROLLBACK WORK.
          ELSE.
            COMMIT WORK.
          ENDIF.
        ELSE.
*    전기일이 최근인것 부터
          SORT TEMP_MATDOC DESCENDING BY BUDAT MBLNR.

*플랜트 재고
          LOOP AT TEMP_COLLECT WHERE WERKS = LV_WERKS
                                 AND MATNR = LV_MATNR
                                 AND CHARG = LV_CHARG
                                 AND LGORT = LV_LGORT.

            LV_WERKS_SUM = LV_WERKS_SUM + TEMP_COLLECT-STOCKMAF.

          ENDLOOP.
** temp_matdoc 의 데이터 수 계산.
          DESCRIBE TABLE TEMP_MATDOC LINES LV_TAB_CNT.

** 현재 플랜트 재고의 수량과 입고 자재문서의 수량을 한건씩 sum하여
          LOOP AT TEMP_MATDOC WHERE WERKS = LV_WERKS
                               AND MATNR = LV_MATNR
                               AND CHARG = LV_CHARG.

            LV_CNT_MATDOC = LV_CNT_MATDOC + 1.

            IF LV_STOP_P <> 'X'.

              LV_AD_SUM = LV_SUM.                  "이전 누적수량
              LV_SUM = LV_SUM + TEMP_MATDOC-MENGE.  "현재 누적수량

** 재고유형
              IF TEMP_ACT-CHARG = '' OR TEMP_ACT-CHARG IS INITIAL.
                TEMP_ACT-STOCKT = C_STOCKT_ONB.
                "배치번호가 없으면 Non batch
                TEMP_ACT-STTEXT = C_STTEXT_ONB.
                "배치번호가 없으면 Non batch
              ELSE.
                TEMP_ACT-STOCKT = C_STOCKT_OB.    "배치번호가 있을경우
                TEMP_ACT-STTEXT = C_STTEXT_OB.    "배치번호가 있을경우
              ENDIF.

              TEMP_ACT-BUDAT = TEMP_MATDOC-BUDAT.      "자재문서의 전기일
              TEMP_ACT-MENGE = TEMP_MATDOC-MENGE.      "전기수량
              TEMP_ACT-MEINS = TEMP_MATDOC-MEINS.      "단위
              TEMP_ACT-MBLNR = TEMP_MATDOC-MBLNR.      "자재문서번호
              TEMP_ACT-BWART = TEMP_MATDOC-BWART.      "이동유형
**
              TEMP_ACT-STOCKMBE = LV_STOCKM.
              TEMP_ACT-STOCKM   = LV_STOCKMAF.
              CLEAR : TEMP_ACT-STOCKMAF.
**
* 점유율 > 창고별 재고(temp_act-stockm) / 플랜트 총재고 (lv_werks_sum)
              IF LV_WERKS_SUM = 0.
                TEMP_ACT-RATE  = 0.
              ELSE.
                TEMP_ACT-RATE  = TEMP_ACT-STOCKM / LV_WERKS_SUM.
              ENDIF.
** zppt0149에 넣을 데이터용 점유률 ( * 100 )
              PERFORM VALUE_ROUND_RATE USING TEMP_ACT-RATE
              TEMP_ACT-MSHARE
                                             LV_ERROR.

              TEMP_ACT-MDATE    = P_DATE. "sy-datum.
** 창고재고 수량보다 많은 시점까지의 자재문서를 찾아 마지막 자제문서의
** 전기일로 체류일을 계산
              IF LV_WERKS_SUM >= LV_SUM .
                "창고재고보다 작거나 같은 시점.
                IF LV_WERKS_SUM = LV_SUM.  "같은 경우 멈춤.
** 전기일 기준으로 현재일자를 계산하여 체류일을 계산
                  TEMP_ACT-MENGE_LAST = TEMP_ACT-MENGE.
                  MOVE-CORRESPONDING TEMP_ACT TO TEMP_Z_UP.
                  APPEND TEMP_Z_UP.
                  CLEAR  TEMP_Z_UP.

                  LV_STOP_P = 'X'.

                ELSE.
                  TEMP_ACT-MENGE_LAST = TEMP_ACT-MENGE.
                  MOVE-CORRESPONDING TEMP_ACT TO TEMP_Z_UP.
                  APPEND TEMP_Z_UP.
                  CLEAR  TEMP_Z_UP.

** 창고재고보다 작지만 자재문서가 마지막일 경우
                  IF LV_TAB_CNT = LV_CNT_MATDOC.
** 전기일 기준으로 현재일자를 계산하여 체류일을 계산
                    IF LV_WERKS_SUM <> LV_SUM.
                      TEMP_ACT-MENGE_LAST = LV_WERKS_SUM - LV_SUM.
                      "모자란 체류수량
                      TEMP_ACT-FLAG_E = 'X'.
                      MOVE-CORRESPONDING TEMP_ACT TO TEMP_Z_UP.
                      APPEND TEMP_Z_UP.
                      CLEAR  TEMP_Z_UP.
                    ENDIF.

                    LV_STOP_P = 'X'.
                    LV_ERROR  = 'X'.
                  ENDIF.

                ENDIF.
              ELSE.
* 창고재고 수량보다 많은 시점 / 마지막으로 많은 부분의 데이터까지 포함.
** 전기일 기준으로 현재일자를 계산하여 체류일을 계산
                TEMP_ACT-MENGE_LAST = LV_WERKS_SUM - LV_AD_SUM.
                MOVE-CORRESPONDING TEMP_ACT TO TEMP_Z_UP.

                APPEND TEMP_Z_UP.
                CLEAR  TEMP_Z_UP.

                LV_STOP_P = 'X'.
                "마지막 체류일/분류그룹까지 계산후 멈춤

              ENDIF.

            ENDIF.

          ENDLOOP.

          LOOP AT TEMP_Z_UP WHERE WERKS = LV_WERKS
                              AND MATNR = LV_MATNR.

            CLEAR : GV_SEQ, LV_STOP_VALUE.
** 체류일
            GV_STOP = P_DATE - TEMP_Z_UP-BUDAT.
            TEMP_Z_UP-STOPDATE = GV_STOP.  "체류일

            PERFORM BRANCHG_GET USING GV_STOP TEMP_Z_UP-BRANCHG.
            "분류그룹 구하기

** sequence 번호 구하기
            PERFORM GET_SEQ USING TEMP_Z_UP-WERKS TEMP_Z_UP-MATNR
                                  TEMP_Z_UP-LGORT TEMP_Z_UP-BRANCHG
                                  TEMP_Z_UP-STOCKT
                                  P_DATE GV_SEQ TEMP_Z_UP-CHARG.
            TEMP_Z_UP-SEQUENCE = GV_SEQ + 1.
** 플랜트, 자재번호가 저장위치에 1개만 존재하는 경우
            TEMP_Z_UP-STOPM = TEMP_Z_UP-MENGE_LAST.
            "체류수량( = 전기수량 )
** 저장위치내역 or 공급업체명 /자재내역 / 단가 / 금액
            PERFORM GET_TEMP2_DETAIL_DATA USING  TEMP_Z_UP-WERKS
            TEMP_Z_UP-MATNR
                                                 TEMP_Z_UP-MBLNR
                                                 TEMP_Z_UP-LGORT
                                                 TEMP_Z_UP-STOPM
                                                 TEMP_Z_UP-NAME1
                                                 TEMP_Z_UP-MAKTX
                                                 TEMP_Z_UP-STPRS
                                                 TEMP_Z_UP-MONEY
                                                 TEMP_Z_UP-BKLAS
                                                 TEMP_Z_UP-BKBEZ
                                                 LV_PRCTR.

** 자재문서가 모자랄 경우
            IF TEMP_Z_UP-FLAG_E = 'X'.
              CLEAR : TEMP_Z_UP-MBLNR,
                      TEMP_Z_UP-BUDAT,
                      TEMP_Z_UP-MENGE,
*                      temp_z_up-meins,
                      TEMP_Z_UP-BWART.

              TEMP_Z_UP-STOPDATE = LV_STOP_DATE.
              TEMP_Z_UP-BRANCHG = C_BRANCHG_Z.

              IF TEMP_Z_UP-CHARG = '' OR TEMP_Z_UP-CHARG IS INITIAL.
                TEMP_Z_UP-STOCKT = C_STOCKT_ONB.
                "배치번호가 없으면 Non batch
                TEMP_Z_UP-STTEXT = C_STTEXT_ONB.
                "배치번호가 없으면 Non batch
              ELSE.
                TEMP_Z_UP-STOCKT = C_STOCKT_OB.    "배치번호가 있을경우
                TEMP_Z_UP-STTEXT = C_STTEXT_OB.    "배치번호가 있을경우
              ENDIF.


            ENDIF.
** 30 일 이상이면 CBO 저장 임시 테이블에 저장
            IF TEMP_Z_UP-WERKS(1) EQ '2'. "SRM2102-04681
              CHECK TEMP_Z_UP-STOPDATE >= 0 OR
                    TEMP_Z_UP-BRANCHG = 'Z'.
            ELSE.
              CHECK TEMP_Z_UP-STOPDATE >= 31 OR
                    TEMP_Z_UP-BRANCHG = 'Z'.
            ENDIF.

            IF SY-TABIX = 1.
              LV_STOP_DATE = TEMP_Z_UP-STOPDATE.
              "입력된 가장 최근문서의 체류일
            ENDIF.

            INSERT INTO ZPPT0149 VALUES TEMP_Z_UP.

            IF SY-SUBRC <> 0.
              ROLLBACK WORK.
            ELSE.
              COMMIT WORK.
            ENDIF.

          ENDLOOP.
          CLEAR : TEMP_Z_UP, TEMP_Z_UP[].

        ENDIF.
      ENDIF.
    ENDLOOP.

  ENDIF.

ENDFORM.                    " OUT_COM
*&---------------------------------------------------------------------*
*&      Form  GO_PC
*&---------------------------------------------------------------------*
*       text : PC별 투하 자산 ( t-code : ZCOR1010 )
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GO_PC .

  CALL TRANSACTION 'ZCOR1010'.

ENDFORM.                    " GO_PC
*&---------------------------------------------------------------------*
*&      Form  GO_MCBA
*&---------------------------------------------------------------------*
*       text : 월간시점재고 ( t-code : MCBA )
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GO_MCBA .

  CALL TRANSACTION 'MCBA'.

ENDFORM.                    " GO_MCBA
*&---------------------------------------------------------------------*
*&      Form  GO_MM1
*&---------------------------------------------------------------------*
*       text : 미착원재료 ( t-code : ZMM1R0142 )
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GO_MM1 .

  CALL TRANSACTION 'ZMM1R0142'.

ENDFORM.                                                    " GO_MM1
*&---------------------------------------------------------------------*
*&      Form  CONVERSION_UNIT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GT_TAB_MATNR  text
*      -->P_GT_TAB_WERKS  text
*      -->P_GT_TAB_STOKMC  text
*      -->P_GT_TAB_MEINSC  text
*      -->P_GT_TAB_MEINS  text
*----------------------------------------------------------------------*
FORM CONVERSION_UNIT  USING    PV_MATNR
                               PV_WERKS
                               PV_MGVRG
                               PV_MEINH
                               PV_MEINS
                       CHANGING PV_MENGE.


  DATA: LV_MGVRG TYPE ERFMG,
        LV_MENGE TYPE ERFMG.

  IF PV_MEINS <> PV_MEINH.
    LV_MGVRG = PV_MGVRG.

    CALL FUNCTION '/SAPMP/CA_MATERIAL_UNIT_CONV'
      EXPORTING
        IF_MATNR             = PV_MATNR
        IF_WERKS             = PV_WERKS
        IF_QTY1              = LV_MGVRG
        IF_UOM1              = PV_MEINH
        IF_UOM2              = PV_MEINS
      IMPORTING
        EF_QTY2              = LV_MENGE
      EXCEPTIONS
        CONVERSION_NOT_FOUND = 1
        MATERIAL_NOT_FOUND   = 2
        MEINH_NOT_FOUND      = 3
        MEINS_MISSING        = 4
        NO_MEINH             = 5
        OVERFLOW             = 6
        OTHERS               = 7.

    PV_MENGE = LV_MENGE.
  ELSE.
    PV_MENGE = PV_MGVRG.
  ENDIF.
ENDFORM.                    " CONVERSION_UNIT
*&---------------------------------------------------------------------*
*&      Form  DETERMINE_CURTP
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_TEMP_0149_WERKS  text
*      <--P_LV_CURTP  text
*----------------------------------------------------------------------*
FORM DETERMINE_CURTP  USING P_WERKS
                   CHANGING P_CURTP.

  DATA : LV_BUKRS LIKE T001K-BUKRS.

  CLEAR : P_CURTP.

  CLEAR : LV_BUKRS.
  SELECT SINGLE BUKRS INTO LV_BUKRS
    FROM T001K AS TK
   INNER JOIN T001W AS TW ON TK~BWKEY = TW~BWKEY
   WHERE TW~WERKS EQ P_WERKS.

  CASE LV_BUKRS.
    WHEN '2000'.
      P_CURTP = '10'.
    WHEN OTHERS.
      P_CURTP = '12'.
  ENDCASE.

ENDFORM.                    " DETERMINE_CURTP
*&---------------------------------------------------------------------*
*&      Form  GET_SCRAP_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_TEMP_0149_WERKS  text
*      -->P_TEMP_0149_MATNR  text
*      -->P_LV_CURTP  text
*      -->P_LV_YEAR  text
*      -->P_LV_MONTH  text
*----------------------------------------------------------------------*
FORM GET_SCRAP_DATA    USING   P_WERKS
                              P_MATNR
                              P_MEINS
                              P_MATKL
                              P_DISPO
                              P_CURTP
                              P_YEAR
                              P_MONTH.


  DATA : LV_SCRAP LIKE ZPPT0105-MATNR,
         LV_BRGEW LIKE MARM-BRGEW,
         LV_GEWEI LIKE MARM-GEWEI,
         LV_KALNR LIKE CKMLHD-KALNR,
         LV_PEINH LIKE CKMLCR-PEINH,
         LV_PVPRS LIKE CKMLCR-PVPRS,
         LV_SCRAT LIKE ZPPT0105-SCRAT.

  CLEAR : LV_SCRAP, LV_BRGEW, LV_GEWEI, LV_SCRAT,
          LV_KALNR, LV_PEINH, LV_PVPRS.

* 비율이 가장 높은 스크랩 코드 가져옴.
  SELECT SINGLE MAX( SCRAT )
        INTO LV_SCRAT
        FROM ZPPT0105
       WHERE WERKS = P_WERKS
         AND SPGCD = P_DISPO+0(2)
         AND OPGRP = P_MATKL
         AND STCAN = 'X'
     GROUP BY SCRAT.

  SELECT SINGLE MATNR
           INTO LV_SCRAP
           FROM ZPPT0105
          WHERE WERKS = P_WERKS
            AND SPGCD = P_DISPO+0(2)
            AND OPGRP = P_MATKL
            AND STCAN = 'X'
            AND SCRAT = LV_SCRAT.

  IF LV_SCRAP IS NOT INITIAL.

* 기본단위에 대한 KG 환산계수 가져옴
    SELECT SINGLE BRGEW GEWEI
      INTO (LV_BRGEW, LV_GEWEI)
      FROM MARM
     WHERE MATNR = P_MATNR
       AND MEINH = P_MEINS.

* M당 환산중량을 KG으로 변경
    IF LV_GEWEI = 'G'.
      LV_BRGEW = LV_BRGEW / 1000.
    ELSEIF LV_GEWEI = 'KG'.
      LV_BRGEW = LV_BRGEW.
    ENDIF.


** 원가 추정번호
    SELECT KALNR
      INTO LV_KALNR
      FROM CKMLHD
     WHERE BWKEY = P_WERKS
       AND MATNR = LV_SCRAP
       AND VBELN = SPACE.
    ENDSELECT.

    CLEAR : LV_PVPRS, LV_PEINH.

** 실제 단가
    SELECT PVPRS PEINH
      INTO (LV_PVPRS, LV_PEINH)
      FROM CKMLCR
     WHERE KALNR = LV_KALNR
       AND BDATJ = P_YEAR        "추출 생성년  날짜
       AND POPER = P_MONTH       "추출 생성월
       AND CURTP = P_CURTP       "C20120517_10391:U
       AND SALK3  > 0.         "
    ENDSELECT.

    IF LV_PVPRS = 0.

** 원가 추정번호
      SELECT KALNR
        INTO LV_KALNR
        FROM CKMLHD
       WHERE BWKEY = P_WERKS
         AND MATNR = LV_SCRAP.

** 실제 단가
        SELECT SINGLE PVPRS PEINH
          INTO (LV_PVPRS, LV_PEINH)
          FROM CKMLCR
         WHERE KALNR = LV_KALNR
           AND BDATJ = P_YEAR        "추출 생성년  날짜
           AND POPER = P_MONTH       "추출 생성월
           AND CURTP = P_CURTP .      "C20120517_10391:U
*           AND salk3  > 0.            "스크랩자재는 재고금액 없음

        IF LV_PVPRS > 0.
          EXIT.
        ENDIF.

      ENDSELECT.

    ENDIF.

    TEMP_0149-MATNR_S  = LV_SCRAP.               "생산 스크랩 코드
    TEMP_0149-BRGEW    = LV_BRGEW.                  "M <-> KG 환산계수
    TEMP_0149-STOCKMSC = TEMP_0149-STOPM * LV_BRGEW."스크랩 환산중량
    TEMP_0149-STPRS_SC = ( LV_PVPRS * 100 ) / LV_PEINH.    "스크랩 단가

  ENDIF.

ENDFORM.                    " GET_SCRAP_DATA

*&---------------------------------------------------------------------*
*& Form conversion_exit_matn1_input
*&---------------------------------------------------------------------*
FORM CONVERSION_EXIT_MATN1_INPUT  USING P_IN
                                                  CHANGING P_OUT.

  CLEAR P_OUT.
  CALL FUNCTION 'CONVERSION_EXIT_MATN1_INPUT'
    EXPORTING
      INPUT  = P_IN
    IMPORTING
      OUTPUT = P_OUT.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_STOCK_MONEY_STRPS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_STOCK_MONEY_STRPS .

  DATA : LV_MONEY(16) TYPE P DECIMALS 3.

  DATA : BEGIN OF LT_MAT OCCURS 0,
           WERKS LIKE   MARC-WERKS,
           MATNR LIKE   MARC-MATNR,
         END OF LT_MAT.

  DATA : BEGIN OF LT_MBEW OCCURS 0,
           WERKS LIKE   MARC-WERKS,
           MATNR LIKE   MARC-MATNR,
           VPRSV LIKE   MBEW-VPRSV,
           VERPR LIKE   MBEW-VERPR,
           STPRS LIKE   MBEW-STPRS,
           PEINH LIKE   MBEW-PEINH,
         END OF LT_MBEW.

  DATA : BEGIN OF LT_MARC OCCURS 0,
           WERKS LIKE   MARC-WERKS,
           MATNR LIKE   MARC-MATNR,
           PRCTR LIKE   MARC-PRCTR,
         END OF LT_MARC.

* 재고유형별 플랜트,자재코드 SUM
  LOOP AT TEMP55.
    LT_MAT-WERKS = TEMP55-WERKS.
    LT_MAT-MATNR = TEMP55-MATNR.

    APPEND LT_MAT.
    CLEAR LT_MAT.
  ENDLOOP.

  SORT LT_MAT BY WERKS MATNR.

  DELETE ADJACENT DUPLICATES FROM LT_MAT COMPARING WERKS MATNR.

  CHECK LT_MAT[] IS NOT INITIAL.

* 플랜트,자재코드의 단가 정보 조회
  SELECT BWKEY AS WERKS
               MATNR
               VPRSV
               VERPR
               STPRS
               PEINH
    INTO CORRESPONDING FIELDS OF TABLE LT_MBEW
     FROM MBEW
     FOR ALL ENTRIES IN LT_MAT
    WHERE MATNR  = LT_MAT-MATNR
        AND  BWKEY = LT_MAT-WERKS.

* 플랜트,자재코드의 손익센터 조회
  SELECT WERKS MATNR PRCTR
      INTO CORRESPONDING FIELDS OF TABLE LT_MARC
      FROM MARC
      FOR ALL ENTRIES IN LT_MAT
   WHERE WERKS = LT_MAT-WERKS
        AND MATNR = LT_MAT-MATNR.

  SORT LT_MBEW BY WERKS MATNR.
  SORT LT_MARC BY WERKS MATNR.


  LOOP AT TEMP55.

    CLEAR LV_MONEY.

    READ TABLE LT_MBEW WITH KEY WERKS = TEMP55-WERKS
                                                       MATNR = TEMP55-MATNR
                                       BINARY SEARCH.

    IF SY-SUBRC EQ 0.

*금액(수량 * 단가):원화와 달러의 차이때문에 소수점으로 표현(p_stprs)되어
** 100 필요
*금액(체류수량 * 단가)
      IF LT_MBEW-VPRSV = 'S' .
        IF LT_MBEW-PEINH = 0 OR LT_MBEW-PEINH IS INITIAL.
          TEMP55-MONEY = 0.
        ELSE.
          LV_MONEY = ( TEMP55-STOCKM *  LT_MBEW-STPRS * 100 ) / LT_MBEW-PEINH.
          IF LV_MONEY  > 9999999999999.
            TEMP55-MONEY = 0.
          ELSE.
            TEMP55-MONEY = LV_MONEY.
          ENDIF.
        ENDIF.
      ELSE.
        IF LT_MBEW-PEINH = 0 OR LT_MBEW-PEINH IS INITIAL.
          TEMP55-MONEY = 0.
        ELSE.
          LV_MONEY = ( TEMP55-STOCKM *  LT_MBEW-STPRS * 100 ) / LT_MBEW-PEINH.
          IF LV_MONEY  > 9999999999999.
            TEMP55-MONEY = 0.
          ELSE.
            TEMP55-MONEY = LV_MONEY.
          ENDIF.
        ENDIF.
      ENDIF.
*단가
      TEMP55-STPRS = ( LT_MBEW-STPRS * 100 ) / LT_MBEW-PEINH.

    ENDIF.

    READ TABLE LT_MARC WITH KEY WERKS = TEMP55-WERKS
                                                      MATNR = TEMP55-MATNR
                                       BINARY SEARCH.

    IF SY-SUBRC EQ 0.
      TEMP55-PRCTR = LT_MARC-PRCTR.
    ENDIF.

    MODIFY TEMP55.

  ENDLOOP.

ENDFORM.
