FUNCTION ZGTPP_IF_I_QC_REDUND_INFO.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(I_SYSTEM_ID) TYPE  CHAR04
*"  EXPORTING
*"     VALUE(ZO_RESULT) TYPE  ZO_RESULT
*"     VALUE(ZO_MESSAGE) TYPE  ZO_MESSAGE
*"  TABLES
*"      IT_ITEM STRUCTURE  ZGTPPSIF0064 OPTIONAL
*"      OT_RETURN STRUCTURE  ZGTPPSIF0065 OPTIONAL
*"----------------------------------------------------------------------
*&---------------------------------------------------------------------*
*& 모듈        : PP
*& 프로그램 ID : ZGTPP_IF_I_QC_REDUND_INFO
*& 프로그램 명 : [GT] 입회검사 여장 수신 이력
*& 개요   : 품질보증팀이 입력한 입회검사 여장 정보 I/F 받아
*              S/O의 입회검사 여장 정보 Update 하는 RFC Function
*              Update 된 입회검사 여장 정보는 조장 구성 등에서
*              입회 검사 여장으로 감안됨
*& 생성일 : 2026.05.06
*& 생성자 : ZGSIDEV07
*&---------------------------------------------------------------------*
*& 외부 호출 프로그램 개요   : N/A
*& 타 시스템 인터페이스 개요 : N/A
*&---------------------------------------------------------------------*
*& 프로그램 수정이력
*&---------------------------------------------------------------------*
*& 수정일  :
*& 수정자  :
*& 수정개요 :
*&---------------------------------------------------------------------*

  DATA : LT_SAVE_RESULT TYPE TABLE OF ZGTPPT2410.
  DATA : LV_VBELN TYPE VBAP-VBELN.
  DATA : LV_ZIFKEY TYPE ZGTPPT2410-ZIFKEY.
  DATA : LV_INSPECTION TYPE ATWRT.
  DATA : LT_ORDSYVAL TYPE TABLE OF ZGTCVORDSYVAL.
  DATA : LS_THEAD LIKE THEAD.
  DATA : LT_TLINE LIKE TLINE OCCURS 0 WITH HEADER LINE .
  DATA : LV_TYPE TYPE CHAR01.
  DATA : LT_CHAR TYPE TABLE OF BAPI1003_ALLOC_VALUES_CHAR.
  DATA : LT_MESSAGE TYPE TABLE OF BDCMSGCOLL.
  DATA : LV_NUM(6) TYPE N.
  DATA : LV_NUM_C(6).

  GET TIME STAMP FIELD LV_ZIFKEY.
  MOVE-CORRESPONDING IT_ITEM[] TO LT_SAVE_RESULT.


  ZO_RESULT = '00'.
  ZO_MESSAGE = TEXT-S01.

  LOOP AT LT_SAVE_RESULT ASSIGNING FIELD-SYMBOL(<LS_DATA>).
* 수신결과 로그 세팅
    <LS_DATA>-ZSYSTEM_ID = I_SYSTEM_ID.
    <LS_DATA>-ZIFKEY = LV_ZIFKEY.
    <LS_DATA>-ZSTAT = ZO_RESULT.
    <LS_DATA>-ZMESSAGE = ZO_MESSAGE.
    <LS_DATA>-IFDAT = SY-DATUM.
    <LS_DATA>-IFTIM = SY-UZEIT.
    <LS_DATA>-IFNAM = SY-UNAME.

* 여장정보 처리 프로세스
    CLEAR : LV_VBELN.
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        INPUT  = <LS_DATA>-VBELN
      IMPORTING
        OUTPUT = LV_VBELN.
    <LS_DATA>-VBELN = LV_VBELN.
    <LS_DATA>-POSNR = <LS_DATA>-POSNR + 0.
* 1) 판매오더 존재 여부 확인
    SELECT SINGLE A~VBELN, B~POSNR
      FROM VBAK AS A
      INNER JOIN VBAP AS B ON B~VBELN = A~VBELN
     WHERE A~VBELN = @<LS_DATA>-VBELN
       AND A~VBTYP IN ( 'B', 'C', 'I' )
       AND B~POSNR = @<LS_DATA>-POSNR
       AND B~WERKS = @<LS_DATA>-WERKS
       AND B~ABGRU IS INITIAL
      INTO @DATA(LS_VBAP).
    IF LS_VBAP IS INITIAL.
      <LS_DATA>-ZERP_STAT = 'E'.
      <LS_DATA>-ZERP_MESSAGE = '입회 검사 대상 판매오더를 찾을수 없습니다.'.
      CONTINUE.
    ENDIF.
    CLEAR LS_VBAP.

* 2) 전송된 입회 검사 여장 값 확인
    ZGTPP_CL_COMMON=>GET_CHA_MILLCA(
      EXPORTING
        IV_VBELN       = <LS_DATA>-VBELN                 " 판매 관리 문서 번호
        IV_POSNR       = <LS_DATA>-POSNR                 " SD 문서의 품목 번호
      IMPORTING
        EV_INSPECTION = LV_INSPECTION ).
    IF LV_INSPECTION NE '유'.
      <LS_DATA>-ZERP_STAT = 'E'.
      <LS_DATA>-ZERP_MESSAGE = '입회 검사 대상 판매오더를 찾을수 없습니다.'.
      CONTINUE.
    ENDIF.

* 3) 판매오더로 생산 계획 수립 진행 확인
    REFRESH LT_ORDSYVAL.
    SELECT * FROM ZGTCVORDSYVAL
      INTO TABLE LT_ORDSYVAL
     WHERE KDAUF = <LS_DATA>-VBELN
       AND KDPOS = <LS_DATA>-POSNR
       AND DLFL = ''
       AND TECO = ''
       AND CLSD = ''.
    IF SY-SUBRC EQ 0 AND LT_ORDSYVAL IS NOT INITIAL.
      <LS_DATA>-ZERP_STAT = 'E'.
      <LS_DATA>-ZERP_MESSAGE = '생산 오더로 진행 중인 판매오더 입니다.'.
      CONTINUE.
    ENDIF.

  ENDLOOP.


  LOOP AT LT_SAVE_RESULT ASSIGNING <LS_DATA> WHERE ZERP_STAT = ''.

    REFRESH : LT_CHAR, LT_MESSAGE.
    CLEAR : LV_TYPE.

* 4) 판매오더 입력받은 특성값 업데이트
    CLEAR : LV_NUM, LV_NUM_C.
*  MS-WITNESS_INSPE_LENGTH
    LV_NUM = <LS_DATA>-QLENGTH.
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
      EXPORTING
        INPUT  = LV_NUM
      IMPORTING
        OUTPUT = LV_NUM_C.
    APPEND VALUE #( CHARACT = 'MS-WITNESS_INSPE_LENGTH' VALUE_CHAR = LV_NUM_C ) TO LT_CHAR.

    CLEAR : LV_NUM, LV_NUM_C.
*  MS-SPECIAL_INSPE_LENGTH'
    LV_NUM = <LS_DATA>-ADLENGTH.
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
      EXPORTING
        INPUT  = LV_NUM
      IMPORTING
        OUTPUT = LV_NUM_C.
    APPEND VALUE #( CHARACT = 'MS-SPECIAL_INSPE_LENGTH' VALUE_CHAR = LV_NUM_C ) TO LT_CHAR.

    CALL FUNCTION 'ZGTPP_SO_CHAR_BDC'
      EXPORTING
        IV_VBELN  = <LS_DATA>-VBELN
        IV_POSNR  = <LS_DATA>-POSNR
      IMPORTING
        EV_TYPE   = LV_TYPE
      TABLES
        IT_CHA    = LT_CHAR
        T_MESSAGE = LT_MESSAGE.

    IF LV_TYPE = 'E'.
      <LS_DATA>-ZERP_STAT = 'E'.
      <LS_DATA>-ZERP_MESSAGE = 'S/O 특성 수정 중 오류가 발생했습니다.'.
      CONTINUE.

    ELSE.

* 6) 특기사항 업데이트
      REFRESH LT_TLINE.
      CLEAR LS_THEAD.
* 텍스트라인점검
      LS_THEAD-TDID     = 'ZG01'.
      LS_THEAD-TDSPRAS  = SY-LANGU.
      CONCATENATE <LS_DATA>-VBELN <LS_DATA>-POSNR INTO LS_THEAD-TDNAME.
      LS_THEAD-TDOBJECT = 'VBBP' .

      CALL FUNCTION 'READ_TEXT'
        EXPORTING
          CLIENT                  = SY-MANDT
          ID                      = LS_THEAD-TDID
          LANGUAGE                = LS_THEAD-TDSPRAS
          NAME                    = LS_THEAD-TDNAME
          OBJECT                  = LS_THEAD-TDOBJECT
        TABLES
          LINES                   = LT_TLINE
        EXCEPTIONS
          ID                      = 1
          LANGUAGE                = 2
          NAME                    = 3
          NOT_FOUND               = 4
          OBJECT                  = 5
          REFERENCE_CHECK         = 6
          WRONG_ACCESS_TO_ARCHIVE = 7.

      IF SY-SUBRC NE 0 .
        IF SY-SUBRC NE 4.
          <LS_DATA>-ZERP_STAT = 'E'.
          <LS_DATA>-ZERP_MESSAGE = 'S/O 입회검사 특기사항 입력에 실패 했습니다.'.
          CONTINUE.
        ENDIF.
      ENDIF.

      REFRESH LT_TLINE.

      SPLIT <LS_DATA>-REMARK AT CL_ABAP_CHAR_UTILITIES=>NEWLINE INTO TABLE DATA(LT_STRING).
      LOOP AT LT_STRING INTO DATA(LS_STRING).
        APPEND INITIAL LINE TO LT_TLINE ASSIGNING FIELD-SYMBOL(<LS_LINE>).
        <LS_LINE>-TDLINE = LS_STRING.
      ENDLOOP.

      CALL FUNCTION 'SAVE_TEXT'
        EXPORTING
          HEADER          = LS_THEAD
          SAVEMODE_DIRECT = 'X'
        TABLES
          LINES           = LT_TLINE
        EXCEPTIONS
          ID              = 1
          LANGUAGE        = 2
          NAME            = 3
          OBIECT          = 4
          OTHERS          = 5.
      IF SY-SUBRC NE 0.
        <LS_DATA>-ZERP_STAT = 'E'.
        <LS_DATA>-ZERP_MESSAGE = 'S/O 입회검사 특기사항 입력에 실패 했습니다.'.
        CONTINUE.
      ELSE.
        <LS_DATA>-ZERP_STAT = 'S'.
        <LS_DATA>-ZERP_MESSAGE = '입회검사 여장 및 특기사항 수정 성공 했습니다.'.
        CONTINUE.
      ENDIF.

    ENDIF.

  ENDLOOP.



  IF LT_SAVE_RESULT[] IS NOT INITIAL.
    MOVE-CORRESPONDING LT_SAVE_RESULT TO OT_RETURN[].
    MODIFY ZGTPPT2410 FROM TABLE LT_SAVE_RESULT.
    IF SY-SUBRC EQ 0.
      COMMIT WORK AND WAIT.
    ENDIF.
  ENDIF.

ENDFUNCTION.
