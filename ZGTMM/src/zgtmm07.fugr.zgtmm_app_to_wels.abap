FUNCTION ZGTMM_APP_TO_WELS.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(I_BUKRS) TYPE  BUKRS
*"     VALUE(I_PERNR) TYPE  CHAR10
*"     VALUE(I_TCODE) TYPE  CHAR20
*"     VALUE(I_REQXML) TYPE  STRING
*"  EXPORTING
*"     VALUE(MTYPE) TYPE  BAPI_MTYPE
*"     VALUE(MESSAGE) TYPE  BAPI_MSG
*"     VALUE(LEGACYID) TYPE  CHAR32
*"     VALUE(APPID) TYPE  CHAR32
*"     VALUE(URL) TYPE  STRING
*"----------------------------------------------------------------------
*&---------------------------------------------------------------------*
*& 모듈          : MM
*& 프로그램 ID : ZGTMM_APP_TO_WELS
*& 프로그램 명 :  WELS 결재 요청 공통 FUNCTION
*& 개요   : WELS 연동 공용 FUNCTION 개발
*& 생성일 : 2026.02.02
*& 생성자 : ZGODEV04
*&---------------------------------------------------------------------*
*& 프로그램 수정이력
*&---------------------------------------------------------------------*
*& 수정일  :
*& 수정자  :
*& 수정개요:
*&---------------------------------------------------------------------*
  DATA : LS_1050 TYPE ZGTMMT1050,
             LV_APPID TYPE CHAR32,
             LV_FORMID TYPE CHAR32,
             LV_URL TYPE STRING,
             LV_DEST LIKE ZIFDEST-DEST.

*--필수 입력 값 체크
  IF I_PERNR IS INITIAL OR I_BUKRS IS INITIAL OR
     I_TCODE IS INITIAL OR I_REQXML IS INITIAL.

     MTYPE      = 'E'.
     MESSAGE  = '필수 값이 누락 되었습니다.'(E01).
     RETURN.
  ENDIF.

*--회사코드 체크
  SELECT SINGLE FLD_02 FROM ZGTPPT1010
    WHERE MODULE_KIND = 'MM'
         AND CODEGRP = '0021'
         AND FLD_01 = @I_BUKRS
        INTO @DATA(LV_BUKRS).

  IF LV_BUKRS IS INITIAL.
     MTYPE      = 'E'.
     MESSAGE  = '입력된 회사코드와 연결된 WELS 회사코드가 없습니다.'(E02).
     RETURN.
  ENDIF.

*--결재 양식 번호(FORMID) 체크
  SELECT SINGLE FLD_02 FROM ZGTPPT1010
    WHERE MODULE_KIND = 'MM'
         AND CODEGRP = '0020'
         AND FLD_01 = @I_TCODE
        INTO @DATA(LV_FORM).

  IF LV_FORM IS INITIAL.
     MTYPE      = 'E'.
     MESSAGE  = '입력된 T-CODE와 연결된 FORM ID가 없습니다.'(E03).
     RETURN.
  ENDIF.

*--LEGACY ID 채번
  TRY.
      DATA(LV_LEGACYID) = CL_SYSTEM_UUID=>CREATE_UUID_C32_STATIC( ).

        CATCH CX_ROOT INTO DATA(LV_ERROR).
             MESSAGE = LV_ERROR->GET_TEXT(  ).
             MTYPE     = 'E'.
  ENDTRY.

*--EAI 호출
*DESTINATION
    CALL FUNCTION 'ZGTMM_IF_GET_DESTINATION'
      EXPORTING
        I_ZIFNO       = GC_MM00058
      IMPORTING
       E_ZDEST      = LV_DEST
              .

  DATA LV_ID TYPE CHAR32.
  LV_ID = LV_BUKRS && I_PERNR.
  LV_FORMID = LV_FORM.

  CALL FUNCTION 'ZGTMM_IF_O_APP_REQUEST'
    DESTINATION LV_DEST
    EXPORTING
      I_SYSTEM_ID       = 'KWEL'
      I_USERID             = LV_ID
      I_FORMID            = LV_FORMID
      I_LEGACYID         = LV_LEGACYID
      I_REQXML           = I_REQXML
      I_READONLYYN    = 'N'
    IMPORTING
*     ZO_RESULT         =
     ZO_MESSAGE        = MESSAGE
     APPID            =  LV_APPID
     URL               = LV_URL
            .

*호출 결과 값
   IF LV_APPID IS INITIAL.
     MTYPE      = 'E'.
     MESSAGE  = '전자결재 호출시 오류가 발생했습니다.'(E04).

   ELSE.
     LS_1050 = VALUE #( FORMID = LV_FORMID
                                 LEGACYID = LV_LEGACYID
                                 BUKRS = I_BUKRS
                                 PERNR = I_PERNR
                                 TCODE = I_TCODE
                                 APPID = LV_APPID
                                 ERDAT = SY-DATUM
                                 ERDAT_LOCAL = SY-DATLO
                                 ERTIM = SY-UZEIT
                                 ERTIM_LOCAL = SY-TIMLO
                                 ERNAM = SY-UNAME ) .
*LOG DATA 저장
     MODIFY ZGTMMT1050 FROM LS_1050.
     IF SY-SUBRC = 0.
        COMMIT WORK AND WAIT.
        MTYPE      = 'S'.
        MESSAGE  = '전자결재 호출 완료'(M01).
        LEGACYID  = LV_LEGACYID.
        APPID = LV_APPID.
        URL = LV_URL.
     ENDIF.
*URL 호출
     CL_GUI_FRONTEND_SERVICES=>EXECUTE( EXPORTING APPLICATION = LV_URL ).
   ENDIF.


ENDFUNCTION.
