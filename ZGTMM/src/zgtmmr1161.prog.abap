*&---------------------------------------------------------------------*
*& 모듈        : MM
*& 프로그램 ID : ZGTMMR1161
*& 프로그램 명 : OEM BOM 조회
*& 개요   : [가온전선] OEM 자재의 설계서(자재/띠줄/Cu·AL/광량/공정)를 조회하는 프로그램
*&          CDS 뷰(ZGTMM_CV_OEM_BOM) + ALV IDA, 엑셀 다운로드는 IDA 표준 Export 사용
*& 생성일 : 2026.10.19
*& 생성자 :
*&---------------------------------------------------------------------*
*& 외부 호출 프로그램 개요   : N/A
*& 타 시스템 인터페이스 개요 : N/A
*&---------------------------------------------------------------------*
*& 프로그램 수정이력
*&---------------------------------------------------------------------*
*& 수정일  :
*& 수정자  :
*& 수정개요:
*&---------------------------------------------------------------------*
REPORT ZGTMMR1161 MESSAGE-ID ZGTMM01.

*----------------------------------------------------------------------*
* TABLES / CONSTANTS / DATA
*----------------------------------------------------------------------*
TABLES: T001, T001W, ZEDT1000, MAKT, MARA, AUSP.

CONSTANTS:
  GC_CDS TYPE DBTABL VALUE 'ZGTMM_CV_OEM_BOM'.

DATA:
  GV_ERR TYPE C LENGTH 1.

*----------------------------------------------------------------------*
* Selection Screen
*----------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK B01 WITH FRAME TITLE GV_TITLE.

  PARAMETERS:
    P_BUKRS TYPE T001-BUKRS DEFAULT '6000' OBLIGATORY.

  SELECT-OPTIONS:
    S_WERKS FOR T001W-WERKS DEFAULT '6500' OBLIGATORY NO INTERVALS,
    S_DATE  FOR ZEDT1000-SUL_DATE,
    S_MAKTX FOR MAKT-MAKTX,
    S_MATNR FOR MARA-MATNR,
    S_SPEC  FOR AUSP-ATWRT,
    S_MTART FOR MARA-MTART DEFAULT 'MCHA' NO INTERVALS.

SELECTION-SCREEN END OF BLOCK B01.

*----------------------------------------------------------------------*
INITIALIZATION.
*----------------------------------------------------------------------*
  GV_TITLE = '조회조건'.
  %_P_BUKRS_%_APP_%-TEXT = '회사코드'.
  %_S_WERKS_%_APP_%-TEXT = '플랜트'.
  %_S_DATE_%_APP_%-TEXT  = '기간(설계일자)'.
  %_S_MAKTX_%_APP_%-TEXT = '품명/규격'.
  %_S_MATNR_%_APP_%-TEXT = '자재코드'.
  %_S_SPEC_%_APP_%-TEXT  = 'Spec'.
  %_S_MTART_%_APP_%-TEXT = '자재유형'.

*----------------------------------------------------------------------*
START-OF-SELECTION.
*----------------------------------------------------------------------*
  PERFORM CHECK_AUTH.
  CHECK GV_ERR IS INITIAL.

  PERFORM DISPLAY_IDA.

*&---------------------------------------------------------------------*
*& FORM CHECK_AUTH
*&---------------------------------------------------------------------*
*& 플랜트 조회 권한 체크
*&---------------------------------------------------------------------*
FORM CHECK_AUTH.

  SELECT WERKS
    FROM T001W
   WHERE WERKS IN @S_WERKS
    INTO TABLE @DATA(LT_WERKS).

  LOOP AT LT_WERKS INTO DATA(LS_WERKS).
    AUTHORITY-CHECK OBJECT 'M_MATE_WRK'
      ID 'ACTVT' FIELD '03'
      ID 'WERKS' FIELD LS_WERKS-WERKS.
    IF SY-SUBRC <> 0.
      GV_ERR = 'X'.
      MESSAGE |플랜트 { LS_WERKS-WERKS } 에 대한 조회 권한이 없습니다.| TYPE 'S' DISPLAY LIKE 'E'.
      RETURN.
    ENDIF.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& FORM DISPLAY_IDA
*&---------------------------------------------------------------------*
*& CDS 뷰 기반 ALV IDA 출력
*&---------------------------------------------------------------------*
FORM DISPLAY_IDA.

  DATA:
    LO_IDA       TYPE REF TO IF_SALV_GUI_TABLE_IDA,
    LO_COLLECTOR TYPE REF TO CL_SALV_RANGE_TAB_COLLECTOR,
    LT_RANGES    TYPE IF_SALV_SERVICE_TYPES=>YT_NAMED_RANGES,
    LR_BUKRS     TYPE RANGE OF T001-BUKRS.

  TRY.
      LO_IDA = CL_SALV_GUI_TABLE_IDA=>CREATE_FOR_CDS_VIEW( GC_CDS ).

      "--- 조회조건 -> CDS 필드 매핑
      LR_BUKRS = VALUE #( ( SIGN = 'I' OPTION = 'EQ' LOW = P_BUKRS ) ).

      LO_COLLECTOR = NEW #( ).
      LO_COLLECTOR->ADD_RANGES_FOR_NAME( IV_NAME = 'BUKRS'    IT_RANGES = LR_BUKRS ).
      LO_COLLECTOR->ADD_RANGES_FOR_NAME( IV_NAME = 'WERKS'    IT_RANGES = S_WERKS[] ).
      LO_COLLECTOR->ADD_RANGES_FOR_NAME( IV_NAME = 'SUL_DATE' IT_RANGES = S_DATE[] ).
      LO_COLLECTOR->ADD_RANGES_FOR_NAME( IV_NAME = 'MAKTX'    IT_RANGES = S_MAKTX[] ).
      LO_COLLECTOR->ADD_RANGES_FOR_NAME( IV_NAME = 'MATNR'    IT_RANGES = S_MATNR[] ).
      LO_COLLECTOR->ADD_RANGES_FOR_NAME( IV_NAME = 'SPEC_NO'  IT_RANGES = S_SPEC[] ).
      LO_COLLECTOR->ADD_RANGES_FOR_NAME( IV_NAME = 'MTART'    IT_RANGES = S_MTART[] ).
      LO_COLLECTOR->GET_COLLECTED_RANGES( IMPORTING ET_NAMED_RANGES = LT_RANGES ).

      LO_IDA->SET_SELECT_OPTIONS( IT_RANGES = LT_RANGES ).

      "--- 컬럼 헤더
      PERFORM SET_HEADERS USING LO_IDA.

      "--- 숨김 컬럼 (공정순번/자켓순번/층/순번)
      LO_IDA->FIELD_CATALOG( )->GET_ALL_FIELDS( IMPORTING ETS_FIELD_NAMES = DATA(LTS_FIELDS) ).
      DELETE LTS_FIELDS WHERE TABLE_LINE = 'GONG_SEQ'
                           OR TABLE_LINE = 'JACK_SEQ'
                           OR TABLE_LINE = 'LAYER'
                           OR TABLE_LINE = 'SEQNO'
                           OR TABLE_LINE = 'GONG_CD'
                           OR TABLE_LINE = 'BIGO'.
      LO_IDA->FIELD_CATALOG( )->SET_AVAILABLE_FIELDS( LTS_FIELDS ).

      "--- 툴바: 표준 Export(엑셀 다운로드) 활성화
      LO_IDA->TOOLBAR( )->SET_VISIBILITY_STD_FUNCTIONS( IV_EXPORT = ABAP_TRUE ).

      LO_IDA->FULLSCREEN( )->DISPLAY( ).

    CATCH CX_ROOT INTO DATA(LX_ERR).
      MESSAGE LX_ERR->GET_TEXT( ) TYPE 'S' DISPLAY LIKE 'E'.
  ENDTRY.

ENDFORM.
*&---------------------------------------------------------------------*
*& FORM SET_HEADERS
*&---------------------------------------------------------------------*
FORM SET_HEADERS USING PO_IDA TYPE REF TO IF_SALV_GUI_TABLE_IDA.

  DATA(LO_FCAT) = PO_IDA->FIELD_CATALOG( ).

  DATA(LT_HEAD) = VALUE STRING_TABLE(
    ( `EST_MATNR|견적자재` )
    ( `MATNR|OEM자재코드` )
    ( `MAKTX|품명/규격` )
    ( `COLOR|색상` )
    ( `STRIPE_COLOR|띠줄` )
    ( `STRIPE_CNT|띠줄수` )
    ( `SPEC_NO|스펙` )
    ( `CU_WGT|Cu` )
    ( `AL_WGT|AL` )
    ( `OPT_QTY|Opt(광량)` )
    ( `DESIGN_MAKTX|설계자재명` )
    ( `DESIGN_MATNR|설계자재코드` )
    ( `MAT_QTY|자재량` )
    ( `MAT_UNIT|단위` )
    ( `GONG_CD|공정` )
    ( `BIGO|비고` )
    ( `WGT_UNIT|중량단위` )
    ( `SUL_NO|설계번호` )
    ( `REV_SEQ|개정` )
    ( `SUL_DATE|설계일자` )
    ( `MTART|자재유형` )
    ( `WERKS|플랜트` )
    ( `BUKRS|회사코드` )
    ( `GONG_SEQ|공정순번` )
    ( `JACK_SEQ|자켓순번` )
    ( `LAYER|층` )
    ( `SEQNO|순번` ) ).

  LOOP AT LT_HEAD INTO DATA(LV_HEAD).
    SPLIT LV_HEAD AT '|' INTO DATA(LV_FIELD) DATA(LV_TEXT).
    LO_FCAT->SET_FIELD_HEADER_TEXTS(
      IV_FIELD_NAME   = CONV #( LV_FIELD )
      IV_HEADER_TEXT  = CONV #( LV_TEXT )
      IV_TOOLTIP_TEXT = CONV #( LV_TEXT ) ).
  ENDLOOP.

ENDFORM.
