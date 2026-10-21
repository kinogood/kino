*&---------------------------------------------------------------------*
*& Include          ZGTMMR3000I01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  EXIT_0100  INPUT
*&---------------------------------------------------------------------*
*       TEXT
*----------------------------------------------------------------------*
MODULE EXIT_0100 INPUT.

  GV_OKCODE_SAVE = GV_OKCODE.
  CLEAR GV_OKCODE.

  IF SY-DYNNR = '0200' OR SY-DYNNR = '0400'.
    CHECK GV_OKCODE_SAVE = 'BACK' OR
               GV_OKCODE_SAVE = 'CANC' OR
               GV_OKCODE_SAVE = 'EXIT'.
    LEAVE TO SCREEN 0.

  ELSE.
    CASE GV_OKCODE_SAVE.

      WHEN 'BACK' OR 'CANC'.
         PERFORM RELEASE_ALV.
         LEAVE TO SCREEN 0.

      WHEN 'EXIT'.
         PERFORM RELEASE_ALV.
         LEAVE PROGRAM.
      ENDCASE.
  ENDIF.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0100 INPUT.

  CLEAR : GV_OKCODE_SAVE , GV_ERR.

  GV_OKCODE_SAVE = GV_OKCODE.
  CLEAR GV_OKCODE.

  CASE GV_OKCODE_SAVE.
     WHEN 'REFRESH'.
         PERFORM GET_DATA.

     WHEN 'INVOICE'.   "송장처리
         PERFORM SET_INVOICE.

     WHEN 'MIRO'.   "MIRO
         CALL TRANSACTION 'MIRO'.

     WHEN 'REVERS'.  "역분개
        PERFORM CHECK_REVERSAL_DATA.

     WHEN 'REQ_PAY'. "지급요청
        PERFORM REQUEST_PAY.

     WHEN 'TAX' .  "세금계산서조회
        PERFORM SET_TAX_DATA.

     WHEN  'MAPPING'.  "세금계산서 매핑
        PERFORM SET_DE_MAPPING_SGTXT USING 'M'.

     WHEN 'DE_MAPPING'. "세금계산서 매핑 해제
        PERFORM SET_DE_MAPPING_SGTXT USING 'DM'.

     WHEN OTHERS.
  ENDCASE.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  F4_BLART  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*MODULE f4_blart INPUT.
*
*  DATA: BEGIN OF lt_t003t OCCURS 0 ,
*          blart LIKE t003t-blart,
*          ltext LIKE t003t-ltext,
*        END OF lt_t003t.
*  DATA: lt_field LIKE help_value OCCURS 0 WITH HEADER LINE,
*        lv_index TYPE i.
*
*  CLEAR: lt_field, lt_field[], lv_index.
*  REFRESH lt_t003t.
*  CLEAR lt_t003t.
*
*  SELECT blart,
*         ltext
*    FROM t003t
*   WHERE blart IN (@gc_blart_ca, @gc_blart_cl)
*     AND spras = @sy-langu
*    INTO CORRESPONDING FIELDS OF TABLE @lt_t003t.
*
** Display할 Field의 속성 지정
*  CLEAR: lt_field.
*  lt_field-tabname    = 'T003T'.
*  lt_field-fieldname  = 'BLART'.        "계정코드
*  lt_field-selectflag = 'X'.
*  APPEND lt_field.
*
*  CLEAR: lt_field.
*  lt_field-tabname    = 'T003T'.
*  lt_field-fieldname  = 'LTEXT'.        "
*  APPEND lt_field.
*
** Help Function을 Call 한다
*  CLEAR lv_index.
*  CALL FUNCTION 'HELP_VALUES_GET_NO_DD_NAME'
*    EXPORTING
*      selectfield                  = 'BLART'
*      titel                        = '수금유형'
*    IMPORTING
*      ind                          = lv_index
*    TABLES
*      fields                       = lt_field
*      full_table                   = lt_t003t
*    EXCEPTIONS
*      full_table_empty             = 1
*      no_tablestructure_given      = 2
*      no_tablefields_in_dictionary = 3
*      more_then_one_selectfield    = 4
*      no_selectfield               = 5
*      OTHERS                       = 6.
*
*  IF sy-subrc <> 0.
*
*  ELSE.
*    READ TABLE lt_t003t INDEX lv_index.
*    IF sy-subrc = 0.
*      gs_200-blart = lt_t003t-blart.   "계정코드
*      gs_200-blart_tx = lt_t003t-ltext.
*    ENDIF.
*  ENDIF.
*
*ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0200  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0200 INPUT.

  CLEAR : GV_OKCODE_SAVE2 , GV_ERR.

  GV_OKCODE_SAVE2 = GV_OKCODE.
  CLEAR GV_OKCODE.

  CASE GV_OKCODE_SAVE2.
    WHEN 'YES'.

      CASE GV_OKCODE_SAVE.
        WHEN 'INVOICE'.   "송장처리
            IF  GV_BUDAT IS INITIAL.
              GV_ERR = GC_X.  "전기일자는 필수 입력입니다.
              MESSAGE S000 WITH TEXT-E08 DISPLAY LIKE 'E'.
            ENDIF.

            IF GV_BDATE IS INITIAL.
              GV_ERR = GC_X.  "지급기산일자는 필수 입력입니다.
              MESSAGE S000 WITH TEXT-E08 DISPLAY LIKE 'E'.
          ENDIF.

          CHECK GV_ERR IS INITIAL.
          PERFORM SET_BAPI_DATA.

        WHEN 'REVERS'.   "역분개
            IF  GV_REASON IS INITIAL.
              MESSAGE S000 WITH TEXT-E12 DISPLAY LIKE 'E'.
              ""사유는 필수 입력입니다.
            ELSE.
                PERFORM SET_REVERSAL_INVOICE.
            ENDIF.

        WHEN OTHERS.
      ENDCASE.

      PERFORM REFRESH_TABLE USING GCL_GRID_HD SPACE.
      PERFORM REFRESH_TABLE USING GCL_GRID_IT SPACE.
      LEAVE TO SCREEN 0.

    WHEN 'NO'.
      PERFORM REFRESH_TABLE USING GCL_GRID_HD SPACE.
      PERFORM REFRESH_TABLE USING GCL_GRID_IT SPACE.
      LEAVE TO SCREEN 0.

    WHEN OTHERS.
  ENDCASE.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  F4_STGRD  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE F4_STGRD INPUT.

*사유 코드/설명(TEXT)
  SELECT STGRD, TXT40
    FROM T041CT
    INTO TABLE @DATA(LT_T041)
    WHERE SPRAS = @SY-LANGU. " 현재 접속 언어 기준

*F4 팝업 띄우기
  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      RETFIELD         = 'STGRD'            " 내부 테이블에서 화면으로 넘길 필드명
      DYNPPROG      = SY-REPID          " 현재 프로그램 ID
      DYNPNR           = SY-DYNNR        " 현재 스크린 번호
      DYNPROFIELD   = 'GV_REASON'   " 화면상의 필드명 (자동 입력 대상)
      VALUE_ORG     = 'S'                    " STRUCTURE 형식 인식
    TABLES
      VALUE_TAB     = LT_T041          " 팝업에 뿌려줄 데이터 테이블
    EXCEPTIONS
      PARAMETER_ERROR  = 1
      NO_VALUES_FOUND  = 2
      OTHERS           = 3.

  CHECK GV_REASON IS NOT INITIAL.
  CLEAR GV_ERR.

  READ TABLE LT_T041 TRANSPORTING NO FIELDS
  WITH  KEY STGRD = GV_REASON.

  IF SY-SUBRC <> 0.
    GV_ERR = GC_X. "유효하지 않은 사유 입니다.
    MESSAGE S000 WITH TEXT-M10 DISPLAY LIKE GC_E.
  ENDIF.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  F4_ZTERM  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE F4_ZTERM  INPUT.

**F4 팝업 띄우기
*" USE 'K' FOR VENDORS/CREDITORS, 'D' FOR CUSTOMERS/DEBITORS, OR ' ' FOR ALL
*  CALL FUNCTION 'FI_F4_ZTERM'
*    EXPORTING
*      I_KOART       = 'K'
*      I_ZTERM       = ' '
*      I_XSHOW      = 'X'
*    IMPORTING
*      E_ZTERM       = GV_ZTERM
*    EXCEPTIONS
*      NOTHING_FOUND = 1
*      OTHERS        = 2.
*
*  IF GV_ZTERM IS NOT INITIAL.
*    " T052 테이블에서 입력한 코드가 있는지 확인
*    SELECT SINGLE ZTERM
*      FROM T052
*      INTO @DATA(LV_ZTERM)
*      WHERE ZTERM = @GV_ZTERM.
*
*    IF SY-SUBRC <> 0.
*      MESSAGE S013 DISPLAY LIKE 'E'  WITH GV_ZTERM.
*    ENDIF.
*  ENDIF.

  TYPES: BEGIN OF TY_ZTERM,
           ZTERM TYPE T052-ZTERM,  " 지급 조건 코드
           TEXT1 TYPE T052U-TEXT1, " 지급 조건 설명
         END OF TY_ZTERM.
  DATA: LT_ZTERM TYPE TABLE OF TY_ZTERM.

  SELECT A~ZTERM, B~TEXT1
    FROM T052 AS A
    INNER JOIN T052U AS B ON A~ZTERM = B~ZTERM
    INTO TABLE @LT_ZTERM
    WHERE A~KOART = @GC_K
         AND B~SPRAS = @SY-LANGU.

*F4 팝업 띄우기
  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      RETFIELD         = 'ZTERM'            " 내부 테이블에서 화면으로 넘길 필드명
      DYNPPROG      = SY-REPID          " 현재 프로그램 ID
      DYNPNR           = SY-DYNNR        " 현재 스크린 번호
      DYNPROFIELD   = 'GV_ZTERM'   " 화면상의 필드명 (자동 입력 대상)
      VALUE_ORG     = 'S'                    " STRUCTURE 형식 인식
    TABLES
      VALUE_TAB     = LT_ZTERM          " 팝업에 뿌려줄 데이터 테이블
    EXCEPTIONS
      PARAMETER_ERROR  = 1
      NO_VALUES_FOUND  = 2
      OTHERS           = 3.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0400  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0400 INPUT.

  CLEAR : GV_OKCODE_SAVE2 , GV_ERR.

  GV_OKCODE_SAVE2 = GV_OKCODE.
  CLEAR GV_OKCODE.

  CASE GV_OKCODE_SAVE2.
    WHEN 'CHOICE'.
      IF P_DIS = GC_X. "조회의 경우, F4헬프 값으로 전달.
          CLEAR : GV_TAXNO, GV_TOTAL, GV_SPRICE, GV_WMWST.
          SORT GT_TAX BY CHECK.

          READ TABLE GT_TAX ASSIGNING FIELD-SYMBOL(<F4TAX>)
          WITH KEY CHECK = GC_X BINARY SEARCH.

          IF SY-SUBRC = 0.
            GV_TAXNO  = <F4TAX>-INV_SEQ.           "세금계산서일련번호
            GV_TOTAL   = <F4TAX>-GRANDTOTAL.   "합계금액
            GV_SPRICE  = <F4TAX>-CHARGETOTAL. "공급가액
            GV_WMWST = <F4TAX>-TAXTOTAL.        "세액
          ENDIF.

      ELSE.
          CLEAR : GV_TAXNO, GV_TARGET_PRICE2, GV_TPRICE_DISP2, GV_TWAERS2,
                       GV_TAXPRICE2, GV_XPRICE_DISP2, GV_XWAERS2,
                       GV_WRBTR2, GV_WRBTR_DISP2, GV_WAERS2,
                       GV_DATE, GV_PDATE.

          LOOP AT GT_TAX ASSIGNING FIELD-SYMBOL(<TAX>) WHERE CHECK = GC_X.
             GV_TAXNO = <TAX>-INV_SEQ.
             GV_TARGET_PRICE2 = <TAX>-CHARGETOTAL.
             GV_TAXPRICE2 = <TAX>-TAXTOTAL.
             GV_WRBTR2 = <TAX>-GRANDTOTAL.
             GV_WAERS2 = GV_TWAERS2 = GV_XWAERS2 = <TAX>-WAERS.
             GV_DATE = <TAX>-ISSUE_DATE.
             GV_PDATE = <TAX>-ISSUE_DT.
          ENDLOOP.

*합계필드 화면 표시용 처리.(단위참조)
          WRITE GV_WRBTR2 TO GV_WRBTR_DISP2 CURRENCY GV_WAERS2 LEFT-JUSTIFIED.
          WRITE GV_TARGET_PRICE2 TO GV_TPRICE_DISP2 CURRENCY GV_WAERS2 LEFT-JUSTIFIED.
          WRITE GV_TAXPRICE2 TO GV_XPRICE_DISP2 CURRENCY GV_WAERS2 LEFT-JUSTIFIED.

        PERFORM REFRESH_TABLE USING GCL_GRID_HD SPACE.
        PERFORM REFRESH_TABLE USING GCL_GRID_IT SPACE.
      ENDIF.

      LEAVE TO SCREEN 0.

    WHEN 'FINISH'.
      PERFORM REFRESH_TABLE USING GCL_GRID_HD SPACE.
      PERFORM REFRESH_TABLE USING GCL_GRID_IT SPACE.
      LEAVE TO SCREEN 0.

    WHEN OTHERS.
  ENDCASE.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  CHECK_ZTERM  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CHECK_ZTERM INPUT.

  IF GV_ZTERM IS NOT INITIAL.
    " T052 테이블에서 입력한 코드가 있는지 확인
    SELECT SINGLE ZTERM
      FROM T052
      INTO @DATA(LV_ZTERM)
      WHERE ZTERM = @GV_ZTERM.

    IF SY-SUBRC <> 0.
      MESSAGE S013 DISPLAY LIKE 'E' WITH GV_ZTERM .
    ENDIF.
  ENDIF.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  CHECK_BUDAT  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CHECK_BUDAT INPUT.

  IF GV_BUDAT IS INITIAL.
     CLEAR GV_BDATE.
  ELSE.
     GV_BDATE = GV_BUDAT.
  ENDIF.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  MODIFY_TAXPRICE  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  MODIFY_TAXPRICE  INPUT
*&---------------------------------------------------------------------*
*  스크린 입력 필드(GV_XPRICE_DISP)의 문자 값을 숫자형(GV_TAXPRICE)으로
*  변환하여 총 합계금액을 재계산하는 전용 모듈
*----------------------------------------------------------------------*
MODULE MODIFY_TAXPRICE INPUT.

  DATA: LV_TAX_CHAR TYPE STRING,
        LV_EXTERNAL TYPE BAPICURR-BAPICURR.

  " 1. 화면에 보이는 문자형 필드(GV_XPRICE_DISP)의 값 복사 및 콤마(,) 제거
  LV_TAX_CHAR = GV_XPRICE_DISP.
  CONDENSE LV_TAX_CHAR NO-GAPS.
  REPLACE ALL OCCURRENCES OF ',' IN LV_TAX_CHAR WITH ''.

  LV_EXTERNAL = LV_TAX_CHAR.

  CALL FUNCTION 'BAPI_CURRENCY_CONV_TO_INTERNAL'
    EXPORTING
      CURRENCY             = GV_WAERS     " 화면의 통화코드 (예: KRW)
      AMOUNT_EXTERNAL      = LV_EXTERNAL  " 사용자가 입력한 금액 (예: 1500000)
      MAX_NUMBER_OF_DIGITS = 23
    IMPORTING
      AMOUNT_INTERNAL      = GV_TAXPRICE  " SAP 내부 변수용 금액
    EXCEPTIONS
      OTHERS               = 1.

  IF SY-SUBRC <> 0.
    MESSAGE '금액 통화 변환 중 오류가 발생했습니다.' TYPE 'E'.
    EXIT.
  ENDIF.

  " 세액을 기존 공급가액에 더함
  GV_WRBTR = GV_TARGET_PRICE + GV_TAXPRICE.

  " 연산 결과를 다시 화면 표시용(_DISP) 필드들에 통화 포맷(GV_WAERS)에 맞춰 반영
  CLEAR: GV_WRBTR_DISP, GV_XPRICE_DISP.

  WRITE GV_WRBTR    TO GV_WRBTR_DISP  CURRENCY GV_WAERS LEFT-JUSTIFIED.
  WRITE GV_TAXPRICE TO GV_XPRICE_DISP CURRENCY GV_WAERS LEFT-JUSTIFIED.

ENDMODULE.
