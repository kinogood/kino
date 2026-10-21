FUNCTION ZGTMM_BDMES_VENDOR_SEARCH.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(I_SYSTEM_ID) TYPE  CHAR4 DEFAULT 'KBDM'
*"     VALUE(I_LIFNR) TYPE  LIFNR OPTIONAL
*"     VALUE(I_NAME1) TYPE  NAME1_GP OPTIONAL
*"  EXPORTING
*"     VALUE(O_RESULT) TYPE  BAPI_MTYPE
*"     VALUE(O_MESSAGE) TYPE  BAPI_MSG
*"  TABLES
*"      OT_TAB STRUCTURE  ZGTMMSIF0060
*"----------------------------------------------------------------------
*&---------------------------------------------------------------------*
*& 모듈          : MM
*& 프로그램 ID : ZGTMM_BDMES_VENDOR_SEARCH
*& 프로그램 명 : [BD] 공급업체 조회 I/F 수신
*& 개요   : 부스닥트 MES에서 필요한 공급업체를 등록하기 위해 조회 하는 RFC 함수.
*&           부스닥트에서 공급업체를 찾기 위한 조회 조건을 받아, 업체코드/업체명/주소를 리턴.
*& 생성일 : 2024.12.11
*& 생성자 : ZGSIDEV03
*&---------------------------------------------------------------------*
*& 프로그램 수정이력
*&---------------------------------------------------------------------*
*& 수정일  :
*& 수정자  :
*& 수정개요:
*&---------------------------------------------------------------------*

  "초기값 Setting
  O_RESULT  = GC_S.
  O_MESSAGE = SPACE.
  CLEAR : OT_TAB[].

  "입력값 점검
  IF I_LIFNR IS INITIAL AND I_NAME1 IS INITIAL.
    O_RESULT  = GC_E.
    O_MESSAGE = '검색 필드에 값을 입력하세요.'(M01).
    RETURN.
  ENDIF.

  IF STRLEN( I_NAME1 ) = 1.
    O_RESULT  = GC_E.
    O_MESSAGE = '두 글자 이상으로 조회하세요.'(M02).
    RETURN.
  ENDIF.

  "조회조건 Setiing
  PERFORM SET_COND_VENDOR USING I_LIFNR
                                I_NAME1.

  SELECT LIFNR,
         NAME1,
         ORT01,
         STRAS
    FROM LFA1 INTO TABLE @DATA(LT_DATA)
   WHERE LIFNR IN @GR_LIFNR
     AND NAME1 IN @GR_NAME1
     AND LOEVM  = @SPACE.

  IF LT_DATA IS INITIAL.
    O_RESULT  = GC_E.
    O_MESSAGE = '공급업체를 찾을 수 없습니다. 조회값을 확인하세요.'(M03).
    RETURN.
  ELSE.
    OT_TAB[] = VALUE #( FOR LS_DATA IN LT_DATA
                         ( VALUE #( BASE CORRESPONDING #( LS_DATA )
                                    LIFNR = |{ LS_DATA-LIFNR ALPHA = OUT }| ) ) ).

    SORT OT_TAB BY LIFNR.
  ENDIF.

ENDFUNCTION.

*&---------------------------------------------------------------------*
*& Form SET_COND_VENDOR
*&---------------------------------------------------------------------*
FORM SET_COND_VENDOR USING PV_LIFNR
                           PV_NAME1.

  CLEAR : GR_LIFNR[], GR_NAME1[].

  IF PV_LIFNR IS NOT INITIAL.
    GR_LIFNR[] = VALUE #( ( SIGN   = GC_I
                            OPTION = GC_EQ
                            LOW    = |{ PV_LIFNR ALPHA = IN }| ) ).
  ENDIF.

  IF PV_NAME1 IS NOT INITIAL.
    GR_NAME1[] = VALUE #( ( SIGN   = GC_I
                            OPTION = GC_CP
                            LOW    = '*' && PV_NAME1 && '*' ) ).
  ENDIF.

ENDFORM.
