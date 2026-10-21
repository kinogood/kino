FUNCTION ZGTMM_IF_I_APP_RESULT.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(I_SYSTEM_ID) TYPE  CHAR04
*"     VALUE(I_APPID) TYPE  CHAR32
*"     VALUE(I_STATE) TYPE  CHAR10
*"  EXPORTING
*"     VALUE(ZO_RESULT) TYPE  ZO_RESULT
*"     VALUE(ZO_MESSAGE) TYPE  ZO_MESSAGE
*"     VALUE(MTYPE) TYPE  BAPI_MTYPE
*"     VALUE(MESSAGE) TYPE  CHAR200
*"----------------------------------------------------------------------
*&---------------------------------------------------------------------*
*& 모듈          : MM
*& 프로그램 ID : ZGTMM_IF_O_APP_RESULT
*& 프로그램 명 :  WELS 결재 요청 수신 INTERFACE(WELS->SAP)
*& 개요   : WELS 결재 요청 수신 공통 FUNCTION
*& 생성일 : 2026.01.30
*& 생성자 : ZGODEV04
*&---------------------------------------------------------------------*
*& 프로그램 수정이력
*&---------------------------------------------------------------------*
*& 수정일  :
*& 수정자  :
*& 수정개요:
*&---------------------------------------------------------------------*
  DATA : LT_SAVE TYPE TABLE OF ZGTMMT1051,
             LV_TYPE TYPE BAPI_MTYPE,
             LV_MSG  TYPE BAPI_MSG,
             LV_FNAME TYPE BU_FNAME,
             LV_DEST LIKE ZIFDEST-DEST.

*--전송 데이터 누락여부 확인
  IF I_SYSTEM_ID IS INITIAL OR I_APPID IS INITIAL OR  I_STATE IS INITIAL.

    MTYPE     = 'E'.
    MESSAGE = '필수 값이 누락 되었습니다.'(E01).
    RETURN.
  ENDIF.

*--APPID기준 결재 정보 확인
  SELECT FROM ZGTMMT1050
    FIELDS *
    WHERE APPID = @I_APPID
    INTO TABLE @DATA(LT_1050).

  IF LT_1050 IS INITIAL.
    MTYPE     = 'E'.
    MESSAGE = '결재 상신 정보가 없습니다.'(E02).
    RETURN.
  ENDIF.

*--I_STATE 데이터에 따른 실행 구분
  CLEAR LT_SAVE.
  CASE I_STATE.
*승인/반려
    WHEN 'C' OR 'R'.
      READ TABLE LT_1050 INTO DATA(LS_1050) INDEX 1.

      IF SY-SUBRC = 0.
*티코드/WELS 양식 ID 기준의 결재 펑션 가져오기
        SELECT SINGLE FLD_03 FROM ZGTPPT1010
          WHERE MODULE_KIND = @GC_MM
               AND CODEGRP = @GC_0020
               AND FLD_01 = @LS_1050-TCODE
               AND FLD_02 = @LS_1050-FORMID
               INTO @DATA(LV_FUNC).

        SELECT SINGLE FUNCNAME FROM TFDIR
          WHERE FUNCNAME = @LV_FUNC
          INTO @DATA(LV_FUNC2).

          IF LV_FUNC2 IS INITIAL.
*결재 처리 할 펑션이 없으면, 로그 저장 후 에러 리턴.
            SELECT SINGLE MAX( ZSEQ )
            FROM ZGTMMT1051
            WHERE APPID = @I_APPID
            INTO @DATA(LV_SEQ).

            LT_SAVE = VALUE #( BASE LT_SAVE FOR WA1 IN LT_1050
                                          ( VALUE #( LEGACYID = WA1-LEGACYID
                                                     APPID = I_APPID
                                                     ZSEQ = LV_SEQ + 1
                                                     STATUS = I_STATE
                                                     TYPE = GC_E
                                                     MESSAGE = TEXT-E03
                                                     ERDAT = SY-DATUM
                                                     ERDAT_LOCAL = SY-DATLO
                                                     ERTIM = SY-UZEIT
                                                     ERTIM_LOCAL = SY-TIMLO
                                                     ERNAM = SY-UNAME ) ) ) .

              MODIFY ZGTMMT1051 FROM TABLE LT_SAVE.
              IF SY-SUBRC = 0.
                COMMIT WORK AND WAIT.
              ENDIF.

              MTYPE     = GC_E.
              MESSAGE = '결재 상태 처리를 위한 FUNCTION이 없습니다.'(E03).

*있으면, 해당 펑션 호출_호출 된 펑션 내부에서 결재 처리 함.
          ELSE.
              CALL FUNCTION LV_FUNC
                EXPORTING
                  I_APPID        = I_APPID
                  I_STATE       = I_STATE
                IMPORTING
                  MTYPE         = LV_TYPE
                  MESSAGE    = LV_MSG
                        .
*리턴 기준으로 로그 저장 후 종료
            SELECT SINGLE MAX( ZSEQ )
            FROM ZGTMMT1051
            WHERE APPID = @I_APPID
            INTO @LV_SEQ.

            LT_SAVE = VALUE #( BASE LT_SAVE FOR WA2 IN LT_1050
                                          ( VALUE #( LEGACYID = WA2-LEGACYID
                                                     APPID = I_APPID
                                                     ZSEQ = LV_SEQ + 1
                                                     STATUS = I_STATE
                                                     TYPE = LV_TYPE
                                                     MESSAGE = LV_MSG
                                                     ERDAT = SY-DATUM
                                                     ERDAT_LOCAL = SY-DATLO
                                                     ERTIM = SY-UZEIT
                                                     ERTIM_LOCAL = SY-TIMLO
                                                     ERNAM = SY-UNAME ) ) ) .

              MODIFY ZGTMMT1051 FROM TABLE LT_SAVE.
              IF SY-SUBRC = 0.
                COMMIT WORK AND WAIT.
              ENDIF.

              MTYPE     = LV_TYPE.
              MESSAGE = LV_MSG.
          ENDIF.

       ENDIF.

*그 외..
      WHEN OTHERS.

        SELECT SINGLE MAX( ZSEQ )
          FROM ZGTMMT1051
          WHERE APPID = @I_APPID
          INTO @LV_SEQ.

          LT_SAVE = VALUE #( BASE LT_SAVE FOR WA IN LT_1050
                                        ( VALUE #( LEGACYID = WA-LEGACYID
                                                         APPID = I_APPID
                                                         ZSEQ = LV_SEQ + 1
                                                         STATUS = I_STATE
                                                         ERDAT = SY-DATUM
                                                         ERDAT_LOCAL = SY-DATLO
                                                         ERTIM = SY-UZEIT
                                                         ERTIM_LOCAL = SY-TIMLO
                                                         ERNAM = SY-UNAME ) ) ) .
          IF LT_SAVE IS NOT INITIAL.
            MODIFY ZGTMMT1051 FROM TABLE LT_SAVE.

            IF SY-SUBRC = 0.
              COMMIT WORK AND WAIT.
              MTYPE     = 'S'.
              MESSAGE = '결재 진행 상태가 등록 되었습니다.'(M01).
            ENDIF.
          ENDIF.
      ENDCASE.


    ENDFUNCTION.
