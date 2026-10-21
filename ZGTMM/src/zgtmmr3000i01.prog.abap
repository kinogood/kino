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

  CASE GV_OKCODE_SAVE.

    WHEN 'BACK' OR 'CANC'.
       PERFORM RELEASE_ALV.
       LEAVE TO SCREEN 0.

    WHEN 'EXIT'.
      PERFORM RELEASE_ALV.
      LEAVE PROGRAM.

  ENDCASE.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  EXIT_0100  INPUT
*&---------------------------------------------------------------------*
*       TEXT
*----------------------------------------------------------------------*
MODULE EXIT_0200 INPUT.

  GV_OKCODE_SAVE2 = GV_OKCODE.
  CLEAR GV_OKCODE.

  CASE GV_OKCODE_SAVE2.

    WHEN 'BACK' OR 'CANC' OR  'EXIT'.
       LEAVE TO SCREEN 0.

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

**&---------------------------------------------------------------------*
**&      Module  CHECK_KUNNR  INPUT
**&---------------------------------------------------------------------*
**       text
**----------------------------------------------------------------------*
*MODULE check_kunnr INPUT.
*
*  CLEAR : gs_info-kunnr_tx.
*  IF gs_info-kunnr IS NOT INITIAL.
*    gs_info-kunnr = |{ gs_info-kunnr ALPHA = IN }|.
*    SELECT SINGLE name1
*      FROM kna1
*      INTO @gs_info-kunnr_tx
*     WHERE kunnr = @gs_info-kunnr.
*    IF sy-subrc <> 0.
*      MESSAGE e017.  "유효하지 않은 코드 입니다.
*    ENDIF.
*  ENDIF.
*
*ENDMODULE.
*
**&---------------------------------------------------------------------*
**&      Module  CHECK_VKGRP  INPUT
**&---------------------------------------------------------------------*
**       text
**----------------------------------------------------------------------*
*MODULE check_vkgrp INPUT.
*
*  CLEAR : gs_info-vkgrp_tx.
*  IF gs_info-vkgrp IS NOT INITIAL.
**    gs_info-kunnr = |{ gs_info-kunnr ALPHA = IN }|.
*    SELECT SINGLE bezei
*      FROM tvgrt
*      INTO @gs_info-vkgrp_tx
*     WHERE vkgrp = @gs_info-vkgrp
*       AND spras = @sy-langu.
*    IF sy-subrc <> 0.
*      MESSAGE e017.  "유효하지 않은 코드 입니다.
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
      IF GV_UCOMM = 'CHANGE' AND GV_EKGRP IS INITIAL.
        GV_ERR = GC_X.
        MESSAGE S000 WITH TEXT-E08 DISPLAY LIKE 'E'.
        "구매그룹은 필수 입력입니다.
      ENDIF.

      CHECK GV_ERR IS INITIAL.

      IF GV_UCOMM = 'CHANGE'. "구매그룹변경
          PERFORM SET_BAPI_DATA.

      ELSEIF GV_UCOMM = 'MASS'. "업체일괄등록
          PERFORM SET_MASS_LIFNR.
          CLEAR : GV_LIFNR .
      ENDIF.

      IF SY-TCODE = 'ZGTMMR3000'.
        PERFORM REFRESH_TABLE USING GCL_GRID SPACE.
      ELSE.
        PERFORM REFRESH_TABLE USING GCL_GRID_400 SPACE.
      ENDIF.

      LEAVE TO SCREEN 0.

    WHEN 'NO'.
      LEAVE TO SCREEN 0.

    WHEN OTHERS.
  ENDCASE.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0300  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0300 INPUT.

  CLEAR : GV_OKCODE_SAVE3 , GV_ERR.

  GV_OKCODE_SAVE3 = GV_OKCODE.
  CLEAR GV_OKCODE.

  CASE GV_OKCODE_SAVE3.
    WHEN 'YES'.

      IF GV_UCOMM = 'PO'. "구매오더전환_P_PR(청구기준 조회)
          PERFORM SET_BAPI_PO_DATA.

      ELSEIF GV_UCOMM = 'CREATE'. "PO생성_P_CRE(직접생성)
          PERFORM SET_BAPI_PO_DATA_CRE.
      ENDIF.

      CLEAR : GV_ZTERM, GV_INCO1 .

      IF SY-TCODE = 'ZGTMMR3000'.
        PERFORM GET_SELECTED_ROWS USING GCL_GRID.
      ELSE.
        PERFORM GET_SELECTED_ROWS USING GCL_GRID_400.
      ENDIF.

      LEAVE TO SCREEN 0.

    WHEN 'NO'.
      LEAVE TO SCREEN 0.

    WHEN OTHERS.
  ENDCASE.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  F4_ZTERM  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE F4_ZTERM INPUT.

*  CALL FUNCTION 'FI_F4_ZTERM'
*    EXPORTING
*      I_ZTERM     = GV_ZTERM
**     I_KOART     = 'K'          " K: 공급업체(VENDOR) 중심 필터링 강제 적용
*    IMPORTING
*      E_ZTERM     = GV_ZTERM
*    EXCEPTIONS
*      OTHERS      = 1.

  " 1. F4 화면에 보여줄 구조체 및 인터널 테이블 선언
  TYPES: BEGIN OF TY_T052,
                ZTERM TYPE T052-ZTERM,  " 지급조건 코드
                TEXT1 TYPE T052U-TEXT1, " 지급조건 내역(텍스트)
              END OF TY_T052.

  DATA:
    LT_F4           TYPE TABLE OF TY_T052,
    LT_RETURN  TYPE TABLE OF DDSHRETVAL WITH HEADER LINE.

  " 2. T052 마스터와 T052U 텍스트 테이블을 현재 로그인 언어(SY-LANGU) 기준으로 조회
  SELECT A~ZTERM, B~TEXT1
    FROM T052 AS A
    LEFT OUTER JOIN T052U AS B ON A~ZTERM EQ B~ZTERM
                                                AND B~SPRAS EQ @SY-LANGU
    WHERE A~KOART = @GC_K "K인 계정유형만..(공급업체)
    INTO TABLE @LT_F4.

  " 중복 코드 제거 및 정렬
  SORT LT_F4 BY ZTERM.
  DELETE ADJACENT DUPLICATES FROM LT_F4 COMPARING ZTERM.

  " 3. SAP 표준 F4 팝업 함수 호출
  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      RETFIELD       = 'ZTERM'         " 선택 시 LT_F4에서 읽어올 필드명
      VALUE_ORG   = 'S'              " 구조 형태 (S: STRUCTURE)
      DYNPPROG    = SY-CPROG  " 현재 프로그램명
      DYNPNR         = SY-DYNNR    " 현재 스크린 번호 (300)
      DYNPROFIELD = 'GV_ZTERM' " 값을 돌려받을 화면 변수명
    TABLES
      VALUE_TAB    = LT_F4           " F4 리스트에 뿌릴 인터널 테이블
      RETURN_TAB  = LT_RETURN  " 사용자가 선택한 결과가 담길 테이블
    EXCEPTIONS
      PARAMETER_ERROR = 1
      NO_VALUES_FOUND = 2
      OTHERS          = 3.

  " 4. 사용자가 선택한 값을 화면 변수에 최종 반영
  IF SY-SUBRC = 0 AND LT_RETURN[] IS NOT INITIAL.
    READ TABLE LT_RETURN INDEX 1.
    GV_ZTERM = LT_RETURN-FIELDVAL.
  ENDIF.


ENDMODULE.
