FUNCTION ZGTMM_BDMES_ETCPASS_REQ.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(I_SYSTEM_ID) TYPE  CHAR4 DEFAULT 'KBDM'
*"     VALUE(I_ZGRCD) TYPE  ZGTE_BD_ZGRCD
*"     VALUE(I_ZIFKEY) TYPE  ZGTEIFKEY OPTIONAL
*"  EXPORTING
*"     VALUE(O_RESULT) TYPE  BAPI_MTYPE
*"     VALUE(O_MESSAGE) TYPE  BAPI_MSG
*"  TABLES
*"      IT_TAB STRUCTURE  ZGTMMSIF0072 OPTIONAL
*"      OT_RTN STRUCTURE  ZGTMMSIF0073 OPTIONAL
*"----------------------------------------------------------------------
*&---------------------------------------------------------------------*
*& 모듈          : MM
*& 프로그램 ID : ZGTMM_BDMES_ETCPASS_REQ
*& 프로그램 명 : [BD] 기타통문 요청 I/F 수신
*& 개요   : 부스닥트 생산 시스템에서 임가공 업체에 기타 필요한 자재를 통문 처리
*& 생성일 : 2025.01.06
*& 생성자 : ZGSIDEV03
*&---------------------------------------------------------------------*
*& 프로그램 수정이력
*&---------------------------------------------------------------------*
*& 수정일  :
*& 수정자  :
*& 수정개요:
*&---------------------------------------------------------------------*

  "초기값 Setting
  O_RESULT = GC_S.
  CLEAR : O_MESSAGE, OT_RTN[].

  GV_SYSTEM_ID = I_SYSTEM_ID.
  GV_ZGRCD     = I_ZGRCD.
  GV_ZIFKEY    = I_ZIFKEY.
  PERFORM SET_COM_LOG USING 'S' 'MM00066' ' ' ' '.

  CLEAR : GT_I72[], GT_I73[].
  CLEAR : GV_RST,   GV_MSG.

  GT_I72[] = IT_TAB[].

  PERFORM CHECK_EPR_RCV.
  PERFORM SET_6050_LOG USING 'S'.

  IF GV_RST IS NOT INITIAL.
    PERFORM SET_EPR_RTN TABLES OT_RTN
                      CHANGING O_RESULT
                               O_MESSAGE.
    RETURN.
  ENDIF.

  CASE GV_ZGRCD.
    WHEN 'C'. "취소
      PERFORM RUN_EPC_RCV.
    WHEN 'E'. "기타통문요청
      PERFORM RUN_EPR_RCV.
  ENDCASE.

  PERFORM SET_EPR_RTN TABLES OT_RTN
                    CHANGING O_RESULT
                             O_MESSAGE.

ENDFUNCTION.

*&---------------------------------------------------------------------*
*& Form CHECK_EPR_RCV
*&---------------------------------------------------------------------*
FORM CHECK_EPR_RCV.

  "입력값 점검

  IF GT_I72[] IS INITIAL.
    PERFORM SET_SNG_MSG USING 'E' '기타통문 처리 데이터를 입력 하세요.'(M29).
    EXIT.
  ENDIF.

  CASE GV_ZGRCD.
    WHEN 'E'. "기타통문요청
      SORT GT_I72 BY SORT_SEQ. "LEG_RQNO

      LOOP AT GT_I72.
        GT_I72-KUNNR = |{ GT_I72-KUNNR ALPHA = IN }|.
        PERFORM CONVERT_MATN1_INPUT USING GT_I72-MATNR.

        IF GT_I72-WERKS IS INITIAL.
          PERFORM SET_SNG_MSG USING 'E' '플랜트를 입력하세요.'(M30).
          EXIT.
        ENDIF.

        IF GT_I72-KUNNR IS INITIAL.
          PERFORM SET_SNG_MSG USING 'E' '납품처 코드를 입력하세요.'(M31).
          EXIT.
        ELSE.
          CLEAR : GV_CHK.
          PERFORM CHECK_KUNNR USING GT_I72-KUNNR.
          PERFORM CHECK_LIFNR USING GT_I72-KUNNR.

          IF GV_CHK IS INITIAL.
            PERFORM SET_SNG_MSG USING 'E' '납품처 코드를 확인하세요.'(M32).
            EXIT.
          ENDIF.
        ENDIF.

        IF GT_I72-MAKTX IS INITIAL.
          PERFORM SET_SNG_MSG USING 'E' '기타통문 처리할 자재내역을 입력하세요.'(M33).
          EXIT.
        ENDIF.

        IF GT_I72-LFIMG IS INITIAL OR GT_I72-MTR_UNIT IS INITIAL.
          PERFORM SET_SNG_MSG USING 'E' '기타통문 처리 수량을 입력하세요.'(M34).
          EXIT.
        ENDIF.

        MODIFY GT_I72 TRANSPORTING KUNNR MATNR.
      ENDLOOP.

    WHEN 'C'. "취소
      IF LINES( GT_I72[] ) > 1.
        PERFORM SET_SNG_MSG USING 'E' '취소할 통문번호 한건을 입력하세요.'(M35).
        EXIT.
      ENDIF.

*     IF LINE_EXISTS( GT_I72[ IV_NO = SPACE ] ).
*     IF GT_I72[ 1 ]-IV_NO IS INITIAL.
      CLEAR : GT_I72.
      READ TABLE GT_I72 INDEX 1.

      IF GT_I72-IV_NO IS INITIAL.
        PERFORM SET_SNG_MSG USING 'E' '취소할 통문번호를 입력하세요.'(M36).
        EXIT.
      ENDIF.

    WHEN OTHERS.
      PERFORM SET_SNG_MSG USING 'E' '처리 구분값은 E 또는 C를 입력해야 합니다.'(M37).
      EXIT.

  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_6050_LOG
*&---------------------------------------------------------------------*
FORM SET_6050_LOG USING PV_TYPE.

  "수신 Data Log Table 저장

  CHECK GT_I72[] IS NOT INITIAL.

  CASE PV_TYPE.
    WHEN 'S'. "Start
      CLEAR : GT_6050[], GT_O73[].

      LOOP AT GT_I72.
        CLEAR : GT_6050, GT_O73.
        GT_6050-ZIFNO     = GT_9000-ZIFNO.
        GT_6050-ZIFKEY    = GT_9000-ZIFKEY.
        GT_6050-SYSTEM_ID = GT_9000-SYSTEM_ID.
        GT_6050-ZGRCD     = GV_ZGRCD.
        PERFORM GET_NUMBER USING '01' 'ZPPI_IN_41'
                        CHANGING GT_I72-IFNUM. "GT_6050-IFNUM.

        MOVE-CORRESPONDING GT_I72  TO GT_6050.
        MOVE-CORRESPONDING GT_6050 TO GT_O73.

        IF GT_6050-IV_TYPE IS INITIAL.
          GT_6050-IV_TYPE = GC_E03.
        ENDIF.

        APPEND : GT_6050, GT_O73.

        MODIFY GT_I72 TRANSPORTING IFNUM. "연결고리
      ENDLOOP.

      MODIFY ZGTMMT6050 FROM TABLE GT_6050.

      SORT GT_O73 BY SORT_SEQ IFNUM. "LEG_RQNO

    WHEN 'E'. "End
      LOOP AT GT_O73.
        UPDATE ZGTMMT6050 SET IV_NO       = GT_O73-IV_NO
                              IV_SEQ      = GT_O73-IV_SEQ
                              ERDAT       = GS_CREA-ERDAT
                              ERDAT_LOCAL = GS_CREA-ERDAT_LOCAL
                              ERTIM       = GS_CREA-ERTIM
                              ERTIM_LOCAL = GS_CREA-ERTIM_LOCAL
                              ERNAM       = GS_CREA-ERNAM
                        WHERE ZIFNO       = GT_9000-ZIFNO
                          AND ZIFKEY      = GT_9000-ZIFKEY
                          AND SYSTEM_ID   = GT_9000-SYSTEM_ID
                          AND ZGRCD       = GV_ZGRCD
*                         AND LEG_RQNO    = GT_O73-LEG_RQNO
                          AND SORT_SEQ    = GT_O73-SORT_SEQ
                          AND IFNUM       = GT_O73-IFNUM.
      ENDLOOP.

  ENDCASE.

  CHECK SY-SUBRC = 0.
  COMMIT WORK.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_EPR_RTN
*&---------------------------------------------------------------------*
FORM SET_EPR_RTN TABLES PT_RTN STRUCTURE ZGTMMSIF0073
               CHANGING PV_RESULT
                        PV_MESSAGE.

  PV_RESULT  = GV_RST.
  PV_MESSAGE = GV_MSG.
  PT_RTN[]   = GT_I73[].

* IF GV_ZGRCD = GC_E.
*   PT_RTN[] = GT_I73[].
* ENDIF.

  PERFORM SET_TIMESTAMP USING 'X' ' '.

  PERFORM SET_6050_LOG USING 'E'.
  PERFORM SET_COM_LOG  USING 'E' ' ' GV_RST GV_MSG.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form RUN_EPC_RCV
*&---------------------------------------------------------------------*
FORM RUN_EPC_RCV.

  DATA : LV_MSG(50).


  CLEAR : GS_XIV, GT_CIV, GT_CIV[].

  "기타통문 정보
  SELECT SINGLE IV_NO
    FROM ZGTMMT6050
    INTO CORRESPONDING FIELDS OF GS_XIV
   WHERE ZGRCD = GC_E
     AND IV_NO = GT_I72-IV_NO.

  IF SY-SUBRC <> 0.
    PERFORM SET_SNG_MSG USING 'E' '취소할 통문번호가 없습니다.'(M38).
    EXIT.
  ENDIF.

  "취소이력 정보
  SELECT ZIFKEY,
         IV_NO
    FROM ZGTMMT6050
   WHERE ZGRCD = @GC_C
     AND IV_NO = @GT_I72-IV_NO
     AND ERDAT IS NOT INITIAL
    INTO CORRESPONDING FIELDS OF TABLE @GT_CIV.

  SORT GT_CIV BY ZIFKEY DESCENDING.
  READ TABLE GT_CIV INDEX 1.

  IF GT_CIV-IV_NO IS NOT INITIAL.
    PERFORM GET_IV_NO USING GT_CIV-IV_NO.

    IF     GS_PIV-IV_NO IS INITIAL.
      PERFORM SET_SNG_MSG USING 'E' '취소할 통문번호가 없습니다.'(M38).
      EXIT.
    ELSEIF GS_PIV-IV_CANCEL_YN IS NOT INITIAL.
      PERFORM SET_SNG_MSG USING 'E' '이미 취소한 통문번호 입니다.'(M39).
      EXIT.
    ELSEIF GS_PIV-OUT_YN IS NOT INITIAL.
      PERFORM SET_SNG_MSG USING 'E' '통문확정되어 취소할 수 없습니다.'(M40).
      EXIT.
    ENDIF.
  ENDIF.

  PERFORM UPDATE_ZLET0005 USING GT_I72-IV_NO.

  LV_MSG = SWITCH #( GV_CHK WHEN 'S' THEN '통문증 취소 되었습니다.'(M41)
                                     ELSE '통문 취소 Update 오류입니다.'(M42) ).

  PERFORM SET_SNG_MSG USING GV_CHK LV_MSG.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form RUN_EPR_RCV
*&---------------------------------------------------------------------*
FORM RUN_EPR_RCV.

  DATA : LV_MSG(50).


  "무조건 1개의 통문번호 생성으로 변경(박상진E 2025.02.04)
  "  전제조건: 수신된 Data의 헤더정보는 모두 일치
  " (최초)LEG_RQNO별 통문번호 생성 -> (변경)LEG_RQNO 삭제

  CLEAR : GT_LE05[], GT_LE06[].

  PERFORM GET_NUMBER USING '06' 'ZLE001'
                  CHANGING GV_IV_NO.
  CLEAR : GV_SEQ.

  LOOP AT GT_I72.
    MOVE-CORRESPONDING GT_I72 TO GS_I72.

    PERFORM SET_EPR_LE06.
  ENDLOOP.

  PERFORM SET_EPR_LE05.

  PERFORM MODIFY_ZLET0005.

  LV_MSG = SWITCH #( GV_CHK WHEN 'S' THEN '기타통문 처리 되었습니다.'(M43)
                                     ELSE '통문 처리 Update 오류입니다.'(M44) ).

  PERFORM SET_SNG_MSG USING GV_CHK LV_MSG.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_EPR_X73
*&---------------------------------------------------------------------*
FORM SET_EPR_X73.

  CLEAR : GT_I73.

* GT_I73-LEG_RQNO = GT_I72-LEG_RQNO.
  GT_I73-SORT_SEQ = GT_I72-SORT_SEQ.
  GT_I73-IV_NO    = GV_IV_NO.
  GT_I73-IV_SEQ   = GV_SEQ.

  APPEND GT_I73.

  "For update Log Table
  READ TABLE GT_O73 WITH KEY SORT_SEQ = GT_I72-SORT_SEQ
                             IFNUM    = GT_I72-IFNUM
                             BINARY SEARCH.

  IF SY-SUBRC = 0.
    GT_O73-IV_NO  = GV_IV_NO.
    GT_O73-IV_SEQ = GV_SEQ.

    MODIFY GT_O73 INDEX SY-TABIX TRANSPORTING IV_NO IV_SEQ.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_EPR_LE06
*&---------------------------------------------------------------------*
FORM SET_EPR_LE06.

  CLEAR : GT_LE06.
  GV_SEQ += 1.

  GT_LE06-IV_NO           = GV_IV_NO.        "거래명세서 번호(통문번호)
  GT_LE06-IV_SEQ          = GV_SEQ.          "Line Seq
  GT_LE06-MATNR           = GT_I72-MATNR.    "자재번호
  GT_LE06-MAKTX           = GT_I72-MAKTX.    "자재내역
  GT_LE06-LFIMG           = GT_I72-LFIMG.    "실제 납품 수량(판매 단위)
  GT_LE06-MTR_UNIT        = GT_I72-MTR_UNIT. "판매 단위
  GT_LE06-DMBTR           = GT_I72-DMBTR.    "금액
  GT_LE06-WAERS           = GT_I72-WAERS.    "통화키
  GT_LE06-RETURN_DUE_DATE = GT_I72-RETURN_DUE_DATE. "반입예정일

  APPEND GT_LE06.

  PERFORM SET_EPR_X73.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_EPR_LE05
*&---------------------------------------------------------------------*
FORM SET_EPR_LE05.

  CLEAR : GT_LE05.

  GT_LE05-IV_NO           = GV_IV_NO.               "거래명세서 번호(통문번호)
  GT_LE05-IV_TYPE = SWITCH #( GS_I72-IV_TYPE WHEN ' ' THEN GC_E03 "부스닥트 무상사급
                                                      ELSE GS_I72-IV_TYPE ).
  GT_LE05-BWART           = GC_ZZZ.                 "이동유형
  GT_LE05-RETURN_YN       = SPACE.                  "반입여부
  GT_LE05-RETURN_DUE_DATE = GS_I72-RETURN_DUE_DATE. "반입예정일
  GT_LE05-DRIVER_NM       = GS_I72-DRIVER_NM.       "운전자명
  GT_LE05-DRIVER_TELNO    = GS_I72-DRIVER_TELNO.    "운전자전화번호
  GT_LE05-TRUCK_NO        = GS_I72-TRUCK_NO.        "차량번호
  GT_LE05-WERKS           = GS_I72-WERKS.           "플랜트
  GT_LE05-ETC_NM          = GS_I72-ETC_NM.          "기타특기사항
  GT_LE05-KUNNR           = GS_I72-KUNNR.           "고객번호
  GT_LE05-REQST           = GC_X.                   "요청여부

  PERFORM SET_COM_LE05 USING GS_I72-PERNR.

  APPEND GT_LE05.

ENDFORM.
