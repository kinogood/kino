*&---------------------------------------------------------------------*
*& Include          ZGTSDR2010F02
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form PROCESS_JS_STEP
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PROCESS_JS_STEP .

  PERFORM CHECK_CHANGED_DATA USING GO_GRID.

*-01. 선택라인
  IF NOT ( LINE_EXISTS( GT_0100[ SEL = GC_X ] ) ).
    MESSAGE I004 DISPLAY LIKE GC_E.
    EXIT.
  ENDIF.

*-02. CHECK
  CLEAR GV_ERROR.
  PERFORM CHECK_JS_PROCESS.
  IF GV_ERROR IS NOT INITIAL.
    EXIT.
  ENDIF.

  CHECK ZGTSD_CL_COMMON=>POPUP_TO_COMFIRM( IV_UCOMM = SPACE IV_MESSA = TEXT-P03 ) EQ GC_J.

*-03. 적송처리
  PERFORM PROCESS_JS_STEP_RUN.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_JS_PROCESS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CHECK_JS_PROCESS .

*-기존 처리 대상 지시자 CLEAR : RUN
  CLEAR GS_0100.
  MODIFY GT_0100 FROM GS_0100 TRANSPORTING RUN WHERE RUN = GC_X.

  LOOP AT GT_0100 ASSIGNING FIELD-SYMBOL(<FS_0100>) WHERE SEL EQ GC_X.
*---01. 적송지정 미완료건
    IF <FS_0100>-ZZJS_ASN_STS_H NE GC_C.
      CONTINUE.
    ENDIF.

*---02. 적송처리 완료가 아닌건
    IF <FS_0100>-ZZJS_FINAL EQ GC_X.
      CONTINUE.
    ENDIF.

*---03. 적송처리 상태가 원천데이터저장(DBS)  와 당월출고분 빌링(FBL) 사이인 건
    IF <FS_0100>-ZZJS_STATUS >= GC_A AND
       <FS_0100>-ZZJS_STATUS < GC_L.
    ELSE.
      CONTINUE.
    ENDIF.

    "적송처리 대상
    <FS_0100>-RUN = GC_X.
  ENDLOOP.

  IF NOT ( LINE_EXISTS( GT_0100[ RUN = GC_X ] ) ).
    GV_ERROR = GC_X.
    MESSAGE I000 WITH TEXT-M12 TEXT-M13 DISPLAY LIKE GC_E.
    EXIT.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROCESS_JS_STEP_RUN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PROCESS_JS_STEP_RUN .

  CLEAR GV_ERROR.

  LOOP AT GT_0100 ASSIGNING FIELD-SYMBOL(<FS_0100>) WHERE SEL = GC_X
                                                      AND RUN = GC_X.
    CLEAR:GV_STATUS_CUR,GV_STATUS_ERR.
    CLEAR:<FS_0100>-RSLT_PROC,<FS_0100>-MESSAGE,<FS_0100>-STAT.
    CLEAR:GV_ZLF3_ONLY.

    SELECT SINGLE ZZJS_STATUS
      FROM ZGTSDT9110
     WHERE VBELN EQ @<FS_0100>-VBELN_VL
       AND LOEVM EQ @SPACE
      INTO @GV_STATUS_CUR.
    IF GV_STATUS_CUR NE <FS_0100>-ZZJS_STATUS.
      <FS_0100>-RSLT_PROC = GC_E.
      <FS_0100>-MESSAGE   = TEXT-M43.
      <FS_0100>-STAT      = ICON_LED_RED.
      CONTINUE.
    ENDIF.

*    GV_STATUS_CUR = <FS_0100>-ZZJS_STATUS.

*---LOCK OBJECT
    PERFORM SET_LOCK_OBJECT CHANGING <FS_0100>.
    IF <FS_0100>-RSLT_PROC EQ GC_E.
      "현재상태 다음단계 상태코드 가져옴( 현재 처리 상태코드 )
      PERFORM GET_STATUS_CODE_NEXT CHANGING GV_STATUS_CUR.
      "DB 상태코드 UPDATE + OUTPUT LIST 의 상태코드 LED 변경
      PERFORM SET_LED_JS    USING GV_STATUS_CUR
                         CHANGING <FS_0100>.
      CONTINUE.
    ENDIF.


*---ZZSTATUS_JS - B	: 출고 취소
    IF GV_STATUS_CUR EQ GC_A.
      CLEAR:<FS_0100>-RSLT_PROC.
      PERFORM PROCESS_JS_STEP_B    USING <FS_0100>
                                CHANGING GV_STATUS_CUR.
    ENDIF.

*---ZZSTATUS_JS - C	: 헤더 납품보류 설정
    IF GV_STATUS_CUR EQ GC_B.
      PERFORM PROCESS_JS_STEP_C    USING <FS_0100>
                                CHANGING GV_STATUS_CUR.
    ENDIF.

*---ZZSTATUS_JS - D	: 배치분할라인 삭제
    IF GV_STATUS_CUR EQ GC_C.
      PERFORM PROCESS_JS_STEP_D    USING <FS_0100>
                                CHANGING GV_STATUS_CUR.
    ENDIF.

*---ZZSTATUS_JS - E	: 주요속성 변경
    IF GV_STATUS_CUR EQ GC_D.
      PERFORM PROCESS_JS_STEP_E    USING <FS_0100>
                                CHANGING GV_STATUS_CUR.
    ENDIF.

*---ZZSTATUS_JS - F	: 원 중량정보로 업데이트
    IF GV_STATUS_CUR EQ GC_E.
      PERFORM PROCESS_JS_STEP_F    USING <FS_0100>
                                CHANGING GV_STATUS_CUR.
    ENDIF.

*---ZZSTATUS_JS - G	: 서비스 출고
    IF GV_STATUS_CUR EQ GC_F.
      PERFORM PROCESS_JS_STEP_G    USING <FS_0100>
                                CHANGING GV_STATUS_CUR.
    ENDIF.

*---ZZSTATUS_JS - H	: 가상창고로 재고이동
    IF GV_STATUS_CUR EQ GC_G.
      PERFORM PROCESS_JS_STEP_H    USING <FS_0100>
                                CHANGING GV_STATUS_CUR.
    ENDIF.

*---ZZSTATUS_JS - I	: 신규 DO 생성
    IF GV_STATUS_CUR EQ GC_H.
      PERFORM PROCESS_JS_STEP_I    USING <FS_0100>
                                CHANGING GV_STATUS_CUR.
    ENDIF.

*---ZZSTATUS_JS - J	: 신규 DO 에 배치지정
    IF GV_STATUS_CUR EQ GC_I.
      PERFORM PROCESS_JS_STEP_J    USING <FS_0100>
                                CHANGING GV_STATUS_CUR.
    ENDIF.

*---ZZSTATUS_JS - K	: 출고분 GI
    IF GV_STATUS_CUR EQ GC_J.
      PERFORM PROCESS_JS_STEP_K    USING <FS_0100>
                                CHANGING GV_STATUS_CUR.
    ENDIF.

*---ZZSTATUS_JS - L	: 출고분 빌링
    IF GV_STATUS_CUR EQ GC_K.
      PERFORM PROCESS_JS_STEP_L    USING <FS_0100>
                                CHANGING GV_STATUS_CUR.
    ENDIF.

    "최종 STATUS
    SELECT SINGLE ZZJS_STATUS,ZZJS_FINAL
      FROM ZGTSDT9110
     WHERE VBELN EQ @<FS_0100>-VBELN_VL
      INTO ( @<FS_0100>-ZZJS_STATUS,@<FS_0100>-ZZJS_FINAL ).
    "적송완료
    IF <FS_0100>-ZZJS_STATUS EQ GC_L.
      <FS_0100>-ST_FINAL = ICON_LED_GREEN.
    ELSE.
      IF GV_ZLF3_ONLY EQ GC_X.
        "당월출고분(ZLF)이 없는 경우 배치지정 완료되면 최종 완료 처리
        IF <FS_0100>-ZZJS_STATUS EQ GC_J.  "배치지정
          <FS_0100>-ST_FINAL = ICON_LED_GREEN.
        ELSE.
          <FS_0100>-ST_FINAL = ICON_LED_YELLOW.
        ENDIF.
      ELSE.
        <FS_0100>-ST_FINAL = ICON_LED_YELLOW.
      ENDIF.
    ENDIF.

*---UNLOCK OBJECT
    PERFORM SET_UNLOCK_OBJECT CHANGING <FS_0100>-VBELN_VL.

  ENDLOOP.


  PERFORM REFRESH_ALV USING GO_GRID.

  IF LINE_EXISTS( GT_0100[ SEL = GC_X RUN = GC_X RSLT_PROC = GC_E ] ).
    MESSAGE I000 WITH TEXT-M25 TEXT-M21 DISPLAY LIKE GC_E.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROCESS_JS_STEP_B
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> <FS_0100>
*&      <-- LV_STATUS
*&---------------------------------------------------------------------*
FORM PROCESS_JS_STEP_B  USING    PS_0100 LIKE GT_0100
                        CHANGING PV_STATUS.
  DATA: LV_STAT TYPE ZGTSDT9110-ZZJS_STATUS.
  DATA: LT_DATA TYPE TABLE OF ZGTSDS0021,
        LV_TYPE TYPE BAPI_MTYPE,
        LV_MSG  TYPE BAPI_MSG.

  LV_STAT = PV_STATUS.
  "현재상태 다음단계 상태코드 가져옴( 현재 처리 상태코드 )
  PERFORM GET_STATUS_CODE_NEXT CHANGING LV_STAT.

  GV_STATUS_ERR = LV_STAT.

*-현재 상태코드 체크 : ZGTSDT9110-ZZJS_STATUS
  SELECT SINGLE ZZJS_STATUS
    FROM ZGTSDT9110
   WHERE VBELN EQ @PS_0100-VBELN_VL
     AND LOEVM EQ @SPACE
    INTO @DATA(LV_STATUS).
  IF LV_STATUS NE PV_STATUS. "지정완료
    PS_0100-RSLT_PROC = GC_E.
    PS_0100-MESSAGE   = TEXT-M30.
  ENDIF.

  IF PS_0100-RSLT_PROC NE GC_E.
*-DO 출고 취소
    APPEND VALUE #( VBELN = PS_0100-VBELN_VL )
        TO LT_DATA.

    CALL FUNCTION 'ZGTSD_JS_CANCEL_GOOD_ISSUE'
      IMPORTING
        E_TYPE  = LV_TYPE
        E_MSG   = LV_MSG
      TABLES
        IT_DATA = LT_DATA.

    IF LV_TYPE EQ GC_S.
      DATA(LS_DATA) = VALUE #( LT_DATA[ 1 ] OPTIONAL ).
      IF LS_DATA-MTYPE EQ GC_S.
        PS_0100-RSLT_PROC = GC_S.
        PV_STATUS         = LV_STAT.

      ELSE.
        PS_0100-RSLT_PROC = GC_E.
        PS_0100-MESSAGE   = LS_DATA-MSG.
      ENDIF.

    ELSE.
      PS_0100-RSLT_PROC = GC_E.
      PS_0100-MESSAGE   = LV_MSG.
    ENDIF.

  ENDIF.

  "DB 상태코드 UPDATE + OUTPUT LIST 의 상태코드 LED 변경
  PERFORM SET_LED_JS    USING LV_STAT
                     CHANGING PS_0100.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROCESS_JS_STEP_C
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> <FS_0100>
*&      <-- GV_STATUS_CUR
*&---------------------------------------------------------------------*
FORM PROCESS_JS_STEP_C  USING    PS_0100 LIKE GT_0100
                        CHANGING PV_STATUS.
  DATA: LV_STAT TYPE ZGTSDT9110-ZZJS_STATUS.
  DATA: LT_DATA TYPE TABLE OF ZGTSDS0022,
        LV_TYPE TYPE BAPI_MTYPE,
        LV_MSG  TYPE BAPI_MSG.

  LV_STAT = PV_STATUS.
  "현재상태 다음단계 상태코드 가져옴( 현재 처리 상태코드 )
  PERFORM GET_STATUS_CODE_NEXT CHANGING LV_STAT.

  GV_STATUS_ERR = LV_STAT.

*-현재 상태코드 체크 : ZGTSDT9110-ZZJS_STATUS
  SELECT SINGLE ZZJS_STATUS
    FROM ZGTSDT9110
   WHERE VBELN EQ @PS_0100-VBELN_VL
     AND LOEVM EQ @SPACE
    INTO @DATA(LV_STATUS).
  IF LV_STATUS NE PV_STATUS. "출고취소 - 'B'
    PS_0100-RSLT_PROC = GC_E.
    PS_0100-MESSAGE   = TEXT-M31.
  ENDIF.

  IF PS_0100-RSLT_PROC NE GC_E.
*-DO 납품보류
    APPEND VALUE #( VBELN = PS_0100-VBELN_VL
                    ZFLAG = GC_X
                    LIFSK = GC_LIFSK_G3      )
        TO LT_DATA.

    CALL FUNCTION 'ZGTSD_JS_SET_HEADER_DO_BLOCK'
      IMPORTING
        E_TYPE  = LV_TYPE
        E_MSG   = LV_MSG
      TABLES
        IT_DATA = LT_DATA.

    IF LV_TYPE EQ GC_S.
      DATA(LS_DATA) = VALUE #( LT_DATA[ 1 ] OPTIONAL ).
      IF LS_DATA-MTYPE EQ GC_S.
        PS_0100-RSLT_PROC = GC_S.
        PV_STATUS         = LV_STAT.

      ELSE.
        PS_0100-RSLT_PROC = GC_E.
        PS_0100-MESSAGE   = LS_DATA-MSG.
      ENDIF.

    ELSE.
      PS_0100-RSLT_PROC = GC_E.
      PS_0100-MESSAGE   = LV_MSG.
    ENDIF.

  ENDIF.

  "DB 상태코드 UPDATE + OUTPUT LIST 의 상태코드 LED 변경
  PERFORM SET_LED_JS    USING LV_STAT
                     CHANGING PS_0100.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROCESS_JS_STEP_D
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> <FS_0100>
*&      <-- GV_STATUS_CUR
*&---------------------------------------------------------------------*
FORM PROCESS_JS_STEP_D  USING    PS_0100 LIKE GT_0100
                        CHANGING PV_STATUS.
  DATA: LV_STAT TYPE ZGTSDT9110-ZZJS_STATUS.
  DATA: LT_DATA TYPE TABLE OF ZGTSDS0025,
        LV_TYPE TYPE BAPI_MTYPE,
        LV_MSG  TYPE BAPI_MSG.

  LV_STAT = PV_STATUS.
  "현재상태 다음단계 상태코드 가져옴( 현재 처리 상태코드 )
  PERFORM GET_STATUS_CODE_NEXT CHANGING LV_STAT.

  GV_STATUS_ERR = LV_STAT.

*-현재 상태코드 체크 : ZGTSDT9110-ZZJS_STATUS
  SELECT SINGLE ZZJS_STATUS
    FROM ZGTSDT9110
   WHERE VBELN EQ @PS_0100-VBELN_VL
     AND LOEVM EQ @SPACE
    INTO @DATA(LV_STATUS).
  IF LV_STATUS NE PV_STATUS. "납품보류 설정 - 'C'
    PS_0100-RSLT_PROC = GC_E.
    PS_0100-MESSAGE   = TEXT-M32.
  ENDIF.

  IF PS_0100-RSLT_PROC NE GC_E.

*-배치분할 삭제
    APPEND VALUE #( VBELN = PS_0100-VBELN_VL )
        TO LT_DATA.

    CALL FUNCTION 'ZGTSD_JS_DELETE_BATCH_LINE'
      IMPORTING
        E_TYPE  = LV_TYPE
        E_MSG   = LV_MSG
      TABLES
        IT_DATA = LT_DATA.

    IF LV_TYPE EQ GC_S.
      DATA(LS_DATA) = VALUE #( LT_DATA[ 1 ] OPTIONAL ).
      IF LS_DATA-MTYPE EQ GC_S.
        PS_0100-RSLT_PROC = GC_S.
        PV_STATUS         = LV_STAT.

      ELSE.
        PS_0100-RSLT_PROC = GC_E.
        PS_0100-MESSAGE   = LS_DATA-MSG.
      ENDIF.

    ELSE.
      PS_0100-RSLT_PROC = GC_E.
      PS_0100-MESSAGE   = LV_MSG.
    ENDIF.

  ENDIF.

  "DB 상태코드 UPDATE + OUTPUT LIST 의 상태코드 LED 변경
  PERFORM SET_LED_JS    USING LV_STAT
                     CHANGING PS_0100.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROCESS_JS_STEP_E
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> <FS_0100>
*&      <-- GV_STATUS_CUR
*&---------------------------------------------------------------------*
FORM PROCESS_JS_STEP_E  USING    PS_0100 LIKE GT_0100
                        CHANGING PV_STATUS.
  DATA: LV_STAT TYPE ZGTSDT9110-ZZJS_STATUS.
  DATA: LT_DATA TYPE TABLE OF ZGTSDS0026,
        LV_TYPE TYPE BAPI_MTYPE,
        LV_MSG  TYPE BAPI_MSG.

  LV_STAT = PV_STATUS.
  "현재상태 다음단계 상태코드 가져옴( 현재 처리 상태코드 )
  PERFORM GET_STATUS_CODE_NEXT CHANGING LV_STAT.

  GV_STATUS_ERR = LV_STAT.

*-현재 상태코드 체크 : ZGTSDT9110-ZZJS_STATUS
  SELECT SINGLE ZZJS_STATUS
    FROM ZGTSDT9110
   WHERE VBELN EQ @PS_0100-VBELN_VL
     AND LOEVM EQ @SPACE
    INTO @DATA(LV_STATUS).
  IF LV_STATUS NE PV_STATUS. "배치분할 라인 삭제- 'D'
    PS_0100-RSLT_PROC = GC_E.
    PS_0100-MESSAGE   = TEXT-M33.
  ENDIF.

  IF PS_0100-RSLT_PROC NE GC_E.

*-DO ITEM 속성 변경
    APPEND VALUE #( VBELN = PS_0100-VBELN_VL )
        TO LT_DATA.

    CALL FUNCTION 'ZGTSD_JS_CHANGE_ATTR_DO_ITEM'
      IMPORTING
        E_TYPE  = LV_TYPE
        E_MSG   = LV_MSG
      TABLES
        IT_DATA = LT_DATA.

    IF LV_TYPE EQ GC_S.
      DATA(LS_DATA) = VALUE #( LT_DATA[ 1 ] OPTIONAL ).
      IF LS_DATA-MTYPE EQ GC_S.
        PS_0100-RSLT_PROC = GC_S.
        PV_STATUS         = LV_STAT.

      ELSE.
        PS_0100-RSLT_PROC = GC_E.
        PS_0100-MESSAGE   = LS_DATA-MSG.
      ENDIF.

    ELSE.
      PS_0100-RSLT_PROC = GC_E.
      PS_0100-MESSAGE   = LV_MSG.
    ENDIF.

  ENDIF.

  "DB 상태코드 UPDATE + OUTPUT LIST 의 상태코드 LED 변경
  PERFORM SET_LED_JS    USING LV_STAT
                     CHANGING PS_0100.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROCESS_JS_STEP_F
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> <FS_0100>
*&      <-- GV_STATUS_CUR
*&---------------------------------------------------------------------*
FORM PROCESS_JS_STEP_F  USING    PS_0100 LIKE GT_0100
                        CHANGING PV_STATUS.
  DATA: LV_STAT TYPE ZGTSDT9110-ZZJS_STATUS.
  DATA: LT_DATA TYPE TABLE OF ZGTSDS0027,
        LV_TYPE TYPE BAPI_MTYPE,
        LV_MSG  TYPE BAPI_MSG.

  LV_STAT = PV_STATUS.
  "현재상태 다음단계 상태코드 가져옴( 현재 처리 상태코드 )
  PERFORM GET_STATUS_CODE_NEXT CHANGING LV_STAT.

  GV_STATUS_ERR = LV_STAT.

*-현재 상태코드 체크 : ZGTSDT9110-ZZJS_STATUS
  SELECT SINGLE ZZJS_STATUS
    FROM ZGTSDT9110
   WHERE VBELN EQ @PS_0100-VBELN_VL
     AND LOEVM EQ @SPACE
    INTO @DATA(LV_STATUS).
  IF LV_STATUS NE PV_STATUS. "속성변경- 'E'
    PS_0100-RSLT_PROC = GC_E.
    PS_0100-MESSAGE   = TEXT-M34.
  ENDIF.

  IF PS_0100-RSLT_PROC NE GC_E.

*-DO ITEM 중량
    APPEND VALUE #( VBELN = PS_0100-VBELN_VL )
        TO LT_DATA.

    CALL FUNCTION 'ZGTSD_JS_UPDATE_INITIAL_WEIGHT'
      IMPORTING
        E_TYPE  = LV_TYPE
        E_MSG   = LV_MSG
      TABLES
        IT_DATA = LT_DATA.

    IF LV_TYPE EQ GC_S.
      DATA(LS_DATA) = VALUE #( LT_DATA[ 1 ] OPTIONAL ).
      IF LS_DATA-MTYPE EQ GC_S.
        PS_0100-RSLT_PROC = GC_S.
        PV_STATUS         = LV_STAT.

      ELSE.
        PS_0100-RSLT_PROC = GC_E.
        PS_0100-MESSAGE   = LS_DATA-MSG.
      ENDIF.

    ELSE.
      PS_0100-RSLT_PROC = GC_E.
      PS_0100-MESSAGE   = LV_MSG.
    ENDIF.

  ENDIF.

  "DB 상태코드 UPDATE + OUTPUT LIST 의 상태코드 LED 변경
  PERFORM SET_LED_JS    USING LV_STAT
                     CHANGING PS_0100.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROCESS_JS_STEP_G
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> <FS_0100>
*&      <-- GV_STATUS_CUR
*&---------------------------------------------------------------------*
FORM PROCESS_JS_STEP_G  USING    PS_0100 LIKE GT_0100
                        CHANGING PV_STATUS.
  DATA: LV_STAT TYPE ZGTSDT9110-ZZJS_STATUS.
  DATA: LT_DATA TYPE TABLE OF ZGTSDS0028,
        LV_TYPE TYPE BAPI_MTYPE,
        LV_MSG  TYPE BAPI_MSG.

  LV_STAT = PV_STATUS.
  "현재상태 다음단계 상태코드 가져옴( 현재 처리 상태코드 )
  PERFORM GET_STATUS_CODE_NEXT CHANGING LV_STAT.

  GV_STATUS_ERR = LV_STAT.

*-현재 상태코드 체크 : ZGTSDT9110-ZZJS_STATUS
  SELECT SINGLE ZZJS_STATUS
    FROM ZGTSDT9110
   WHERE VBELN EQ @PS_0100-VBELN_VL
    INTO @DATA(LV_STATUS).
  IF LV_STATUS NE PV_STATUS. "중량정보 업데이트- 'F'
    PS_0100-RSLT_PROC = GC_E.
    PS_0100-MESSAGE   = TEXT-M35.
  ENDIF.

  IF PS_0100-RSLT_PROC NE GC_E.

*-서비스 출고
    APPEND VALUE #( VBELN = PS_0100-VBELN_VL )
        TO LT_DATA.


    CALL FUNCTION 'ZGTSD_JS_SERVICE_GI'
      IMPORTING
        E_TYPE  = LV_TYPE
        E_MSG   = LV_MSG
      TABLES
        IT_DATA = LT_DATA.

    IF LV_TYPE EQ GC_S.
      DATA(LS_DATA) = VALUE #( LT_DATA[ 1 ] OPTIONAL ).
      IF LS_DATA-MTYPE EQ GC_S.
        PS_0100-RSLT_PROC = GC_S.
        PV_STATUS         = LV_STAT.

      ELSE.
        PS_0100-RSLT_PROC = GC_E.
        PS_0100-MESSAGE   = LS_DATA-MSG.
      ENDIF.

    ELSE.
      PS_0100-RSLT_PROC = GC_E.
      PS_0100-MESSAGE   = LV_MSG.
    ENDIF.

  ENDIF.

  "DB 상태코드 UPDATE + OUTPUT LIST 의 상태코드 LED 변경
  PERFORM SET_LED_JS    USING LV_STAT
                     CHANGING PS_0100.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROCESS_JS_STEP_H
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> <FS_0100>
*&      <-- GV_STATUS_CUR
*&---------------------------------------------------------------------*
FORM PROCESS_JS_STEP_H  USING    PS_0100 LIKE GT_0100
                        CHANGING PV_STATUS.
  DATA: LV_STAT TYPE ZGTSDT9110-ZZJS_STATUS.
  DATA: LT_DATA TYPE TABLE OF ZGTSDS0029,
        LV_TYPE TYPE BAPI_MTYPE,
        LV_MSG  TYPE BAPI_MSG.

  LV_STAT = PV_STATUS.
  "현재상태 다음단계 상태코드 가져옴( 현재 처리 상태코드 )
  PERFORM GET_STATUS_CODE_NEXT CHANGING LV_STAT.

  GV_STATUS_ERR = LV_STAT.

*-가상창고 자재이동
  SELECT SINGLE *
    FROM ZGTSDT9110
   WHERE VBELN EQ @PS_0100-VBELN_VL
     AND LOEVM EQ @SPACE
    INTO @DATA(LS_ZGTSDT9110).
  IF LS_ZGTSDT9110-ZZJS_STATUS NE PV_STATUS. "서비스 출고 - 'G'
    PS_0100-RSLT_PROC = GC_E.
    PS_0100-MESSAGE   = TEXT-M36.
  ENDIF.

  IF PS_0100-RSLT_PROC NE GC_E.

    "가상창고 자재이동 이미 처리건
    SELECT *
      FROM ZGTSDT9120
     WHERE VBELN    EQ @PS_0100-VBELN_VL
       AND UECHA    EQ '000000'
       AND ZZJS_MVT EQ @SPACE
       AND MBLNR    EQ @SPACE
       AND LOEVM    EQ @SPACE
      INTO TABLE @DATA(LT_ZGTSDT9120).
    IF SY-SUBRC NE 0.
      PV_STATUS = LV_STAT.
      IF LV_STAT NE LS_ZGTSDT9110-ZZJS_STATUS.
        "DB 상태코드 UPDATE + OUTPUT LIST 의 상태코드 LED 변경
        PERFORM SET_LED_JS    USING LV_STAT
                           CHANGING PS_0100.
      ENDIF.
      EXIT.
    ENDIF.

    "가상창고 자재이동
    LOOP AT LT_ZGTSDT9120 INTO DATA(LS_LINE).
      APPEND VALUE #( VBELN = LS_LINE-VBELN
                      POSNR = LS_LINE-POSNR )
          TO LT_DATA.
    ENDLOOP.

    CALL FUNCTION 'ZGTSD_JS_GOODSMVT_CREATE'
      IMPORTING
        E_TYPE  = LV_TYPE
        E_MSG   = LV_MSG
      TABLES
        IT_DATA = LT_DATA.
    IF LV_TYPE EQ GC_S.
      "자재이동 완료 체크
      CLEAR:LT_ZGTSDT9120[].
      SELECT *
        FROM ZGTSDT9120
       WHERE VBELN    EQ @PS_0100-VBELN_VL
         AND UECHA    EQ '000000'
         AND ZZJS_MVT EQ @SPACE
         AND MBLNR    EQ @SPACE
        INTO TABLE @LT_ZGTSDT9120.
      IF SY-SUBRC EQ 0.
        IF LINE_EXISTS( LT_DATA[ MTYPE = GC_E ] ).
          PS_0100-RSLT_PROC = GC_E.
          PS_0100-MESSAGE   = VALUE #( LT_DATA[ MTYPE = GC_E ]-MSG OPTIONAL ).
        ELSE.
          PS_0100-RSLT_PROC = GC_E.
          PS_0100-MESSAGE   = TEXT-M14.
        ENDIF.

      ELSE.
        PS_0100-RSLT_PROC = GC_S.
        PV_STATUS         = LV_STAT.

      ENDIF.

    ELSE.
      PS_0100-RSLT_PROC = GC_E.
      PS_0100-MESSAGE   = LV_MSG.
    ENDIF.

  ENDIF.

  "DB 상태코드 UPDATE + OUTPUT LIST 의 상태코드 LED 변경
  PERFORM SET_LED_JS    USING LV_STAT
                     CHANGING PS_0100.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROCESS_JS_STEP_I
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> <FS_0100>
*&      <-- GV_STATUS_CUR
*&---------------------------------------------------------------------*
FORM PROCESS_JS_STEP_I  USING    PS_0100 LIKE GT_0100
                        CHANGING PV_STATUS.
  DATA: LV_STAT TYPE ZGTSDT9110-ZZJS_STATUS,

        LV_TYPE TYPE BAPI_MTYPE,
        LV_MSG  TYPE BAPI_MSG.
  DATA: LV_CHK1(1), "당월 처리 DO 생성
        LV_STEP_M(1),
        LV_CHK2(1), "익월이후 처리 DO 생성
        LV_STEP_JS(1).


  LV_STAT = PV_STATUS.
  "현재상태 다음단계 상태코드 가져옴( 현재 처리 상태코드 )
  PERFORM GET_STATUS_CODE_NEXT CHANGING LV_STAT.

  GV_STATUS_ERR = LV_STAT.

*-ZGTSDT9110
  SELECT SINGLE *
    FROM ZGTSDT9110
   WHERE VBELN EQ @PS_0100-VBELN_VL
     AND LOEVM EQ @SPACE
    INTO @DATA(LS_ZGTSDT9110).
  IF LS_ZGTSDT9110-ZZJS_STATUS NE PV_STATUS. "가상창고 재고이동
    PS_0100-RSLT_PROC = GC_E.
    PS_0100-MESSAGE   = TEXT-M26.
  ENDIF.


  IF PS_0100-RSLT_PROC NE GC_E.

*-ZGTSDT9120
    SELECT *
      FROM ZGTSDT9120
     WHERE VBELN EQ @PS_0100-VBELN_VL
       AND UECHA EQ '000000'
       AND LOEVM EQ @SPACE
      INTO TABLE @DATA(LT_ZGTSDT9120).

    LOOP AT LT_ZGTSDT9120 INTO DATA(LS_LINE).
      "당월처리
      IF LS_LINE-MILLCA_FACTOR_M > 0.
        LV_CHK1 = GC_X.
      ENDIF.
      "익월이후 처리
      IF LS_LINE-MILLCA_FACTOR_JS > 0.
        LV_CHK2 = GC_X.
      ENDIF.
    ENDLOOP.

*-----------------------------------------------
*-STEP1 : 당월처리(ZLF)
*-----------------------------------------------
    IF LV_CHK1 EQ GC_X.
      DATA(LT_TEMP) = LT_ZGTSDT9120[].
      DELETE LT_TEMP WHERE MILLCA_FACTOR_M <= 0.
      SORT LT_TEMP BY VBELN VGBEL.
      "기생성 체크
      SELECT A~*
        INTO TABLE @DATA(LT_LIPS)
        FROM LIPS AS A INNER JOIN LIKP AS B
                       ON A~VBELN = B~VBELN
         FOR ALL ENTRIES IN @LT_TEMP
       WHERE A~VGBEL      EQ @LT_TEMP-VGBEL
         AND A~ZZVBELN_JS EQ @LT_TEMP-VBELN
         AND B~VKORG      EQ @GC_VKORG_6000
         AND B~LFART      EQ @GC_LFART_ZLF.

      IF SY-SUBRC EQ 0.
        LV_STEP_M = GC_X.

      ELSE.
        "DO 생성
        PERFORM DO_CREATE_STEP_M    USING PS_0100
                                 CHANGING LV_TYPE LV_MSG.
        IF LV_TYPE EQ GC_S.
          LV_STEP_M = GC_X.
        ELSE.
          PS_0100-RSLT_PROC = GC_E.
          PS_0100-MESSAGE   = LV_MSG.
*        EXIT.
        ENDIF.
      ENDIF.
    ELSE.

      "당월처리 조장수가 없는경우 처리 된것으로 간주
      LV_STEP_M = GC_X.
    ENDIF.


*-----------------------------------------------
*-STEP2 : 익월처리( ZLF3 )
*-----------------------------------------------
    IF LV_CHK2 EQ GC_X AND LV_STEP_M EQ GC_X.
      CLEAR LT_TEMP[].
      LT_TEMP[] = LT_ZGTSDT9120[].
      DELETE LT_TEMP WHERE MILLCA_FACTOR_JS <= 0.
      SORT LT_TEMP BY VBELN VGBEL.
      "기생성 체크
      CLEAR LT_LIPS[].
      SELECT A~*
        INTO TABLE @LT_LIPS
        FROM LIPS AS A INNER JOIN LIKP AS B
                       ON A~VBELN = B~VBELN
         FOR ALL ENTRIES IN @LT_TEMP
       WHERE A~VGBEL      EQ @LT_TEMP-VGBEL
         AND A~ZZVBELN_JS EQ @LT_TEMP-VBELN
         AND B~VKORG      EQ @GC_VKORG_6000
         AND B~LFART      EQ @GC_LFART_ZLF3.

      IF SY-SUBRC EQ 0.
        LV_STEP_JS = GC_X.

      ELSE.
        "DO 생성
        PERFORM DO_CREATE_STEP_JS    USING PS_0100
                                 CHANGING LV_TYPE LV_MSG.
        IF LV_TYPE EQ GC_S.
          LV_STEP_JS = GC_X.
        ELSE.
          PS_0100-RSLT_PROC = GC_E.
          PS_0100-MESSAGE   = LV_MSG.

        ENDIF.
      ENDIF.

    ELSE.
      "익월처리 조장수가 없는경우 처리 된것으로 간주
      LV_STEP_JS = GC_X.
    ENDIF.

*-DO 생성 체크
    IF LV_STEP_M  EQ GC_X AND
       LV_STEP_JS EQ GC_X.
      PV_STATUS  = LV_STAT.
    ENDIF.

  ENDIF.

  "DB 상태코드 UPDATE + OUTPUT LIST 의 상태코드 LED 변경
  PERFORM SET_LED_JS    USING LV_STAT
                     CHANGING PS_0100.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form DO_CREATE_STEP_M
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PS_DATA
*&      <-- LV_TYPE
*&      <-- LV_MSG
*&---------------------------------------------------------------------*
FORM DO_CREATE_STEP_M  USING    PS_0100 LIKE GT_0100
                       CHANGING PV_TYPE
                                PV_MSG.
  DATA: LT_DATA TYPE TABLE OF ZGTSDS0031,
        LS_DATA TYPE ZGTSDS0031.
  DATA: LV_LENGTH_VRKME TYPE LFIMG,
        LV_LFIMG        TYPE LFIMG.
  DATA: LV_TYPE TYPE BAPI_MTYPE,
        LV_MSG  TYPE BAPI_MSG.

* ZGTSDT9110
  SELECT SINGLE *
    FROM ZGTSDT9110
   WHERE VBELN EQ @PS_0100-VBELN_VL
     AND LOEVM EQ @SPACE
    INTO @DATA(LS_ZGTSDT9110).

*-ZGTSDT9120
  SELECT *
    FROM ZGTSDT9120
   WHERE VBELN           EQ @PS_0100-VBELN_VL
     AND LOEVM           EQ @SPACE
     AND MILLCA_FACTOR_M GE 1
    INTO TABLE @DATA(LT_ZGTSDT9120).
  DATA(LT_TEMP) = LT_ZGTSDT9120[].

*-DO 생성
  SORT LT_ZGTSDT9120 BY VBELN POSNR.

  LOOP AT LT_ZGTSDT9120 INTO DATA(LS_LINE) WHERE UECHA EQ '000000'.
    CLEAR LS_DATA.
    LS_DATA-VGBEL        = LS_LINE-VGBEL.
    LS_DATA-VGPOS        = LS_LINE-VGPOS.
    LS_DATA-MATNR        = LS_LINE-MATNR.
    LS_DATA-WERKS        = LS_LINE-WERKS.
    LS_DATA-LGORT        = GC_LGORT_3499.
*    IF LS_LINE-LGORT IS NOT INITIAL.
*      LS_DATA-LGORT      = LS_LINE-LGORT.
*    ELSE.
*      LS_DATA-LGORT      = VALUE #( LT_TEMP[ VBELN = LS_LINE-VBELN UECHA = LS_LINE-POSNR ]-LGORT OPTIONAL ).
*    ENDIF.

    "조장
    CLEAR:LV_LENGTH_VRKME,LV_LFIMG.
    PERFORM GET_SAP_LENGTH_VRKME    USING LS_LINE-VGBEL LS_LINE-VGPOS
                                   CHANGING LV_LENGTH_VRKME.

    LS_DATA-LFIMG        = LV_LENGTH_VRKME * LS_LINE-MILLCA_FACTOR_M.

    LS_DATA-VRKME        = LS_LINE-VRKME.
    LS_DATA-ZZVBELN_JS   = LS_LINE-VBELN.
    LS_DATA-ZZPOSNR_JS   = LS_LINE-POSNR.
    APPEND LS_DATA TO LT_DATA.
  ENDLOOP.

  CALL FUNCTION 'ZGTSD_JS_DO_CREATE'
    EXPORTING
      I_LFART = GC_LFART_ZLF
      I_WADAT = LS_ZGTSDT9110-WADAT
    IMPORTING
      E_TYPE  = LV_TYPE
      E_MSG   = LV_MSG
    TABLES
      IT_DATA = LT_DATA.
  IF LV_TYPE EQ GC_S.
    CLEAR LS_DATA.
    LS_DATA = VALUE #( LT_DATA[ 1 ] OPTIONAL ).
    IF LS_DATA-MTYPE EQ GC_S AND LS_DATA-VBELN IS NOT INITIAL.
      PV_TYPE = GC_S.

    ELSE.
      PV_TYPE  = GC_E.
      PV_MSG   = LS_DATA-MSG.
    ENDIF.
  ELSE.
    PV_TYPE = LV_TYPE.
    PV_MSG  = LV_MSG.
  ENDIF.





ENDFORM.
*&---------------------------------------------------------------------*
*& Form DO_CREATE_STEP_JS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PS_0100
*&      <-- LV_TYPE
*&      <-- LV_MSG
*&---------------------------------------------------------------------*
FORM DO_CREATE_STEP_JS  USING   PS_0100 LIKE GT_0100
                       CHANGING PV_TYPE
                                PV_MSG.
  DATA: LT_DATA TYPE TABLE OF ZGTSDS0031,
        LS_DATA TYPE ZGTSDS0031.
  DATA: LV_LENGTH_VRKME TYPE LFIMG,
        LV_LFIMG        TYPE LFIMG.
  DATA: LV_TYPE TYPE BAPI_MTYPE,
        LV_MSG  TYPE BAPI_MSG.

* ZGTSDT9110
  SELECT SINGLE *
    FROM ZGTSDT9110
   WHERE VBELN EQ @PS_0100-VBELN_VL
     AND LOEVM EQ @SPACE
    INTO @DATA(LS_ZGTSDT9110).

*-ZGTSDT9120
  SELECT *
    FROM ZGTSDT9120
   WHERE VBELN            EQ @PS_0100-VBELN_VL
     AND LOEVM            EQ @SPACE
     AND MILLCA_FACTOR_JS GE 1
    INTO TABLE @DATA(LT_ZGTSDT9120).
  DATA(LT_TEMP) = LT_ZGTSDT9120[].

*-DO 생성
  SORT LT_ZGTSDT9120 BY VBELN POSNR.

  LOOP AT LT_ZGTSDT9120 INTO DATA(LS_LINE) WHERE UECHA EQ '000000'.
    CLEAR LS_DATA.
    LS_DATA-VGBEL        = LS_LINE-VGBEL.
    LS_DATA-VGPOS        = LS_LINE-VGPOS.
    LS_DATA-MATNR        = LS_LINE-MATNR.
    LS_DATA-WERKS        = LS_LINE-WERKS.
    LS_DATA-LGORT        = GC_LGORT_3499.
*    IF LS_LINE-LGORT IS NOT INITIAL.
*      LS_DATA-LGORT      = LS_LINE-LGORT.
*    ELSE.
*      LS_DATA-LGORT      = VALUE #( LT_TEMP[ VBELN = LS_LINE-VBELN UECHA = LS_LINE-POSNR ]-LGORT OPTIONAL ).
*    ENDIF.

    "조장
    CLEAR:LV_LENGTH_VRKME,LV_LFIMG.
    PERFORM GET_SAP_LENGTH_VRKME    USING LS_LINE-VGBEL LS_LINE-VGPOS
                                   CHANGING LV_LENGTH_VRKME.

    LS_DATA-LFIMG        = LV_LENGTH_VRKME * LS_LINE-MILLCA_FACTOR_JS.

    LS_DATA-VRKME        = LS_LINE-VRKME.
    LS_DATA-ZZVBELN_JS   = LS_LINE-VBELN.
    LS_DATA-ZZPOSNR_JS   = LS_LINE-POSNR.
    APPEND LS_DATA TO LT_DATA.
  ENDLOOP.

  CALL FUNCTION 'ZGTSD_JS_DO_CREATE'
    EXPORTING
      I_LFART = GC_LFART_ZLF3
      I_WADAT = LS_ZGTSDT9110-WADAT
    IMPORTING
      E_TYPE  = LV_TYPE
      E_MSG   = LV_MSG
    TABLES
      IT_DATA = LT_DATA.
  IF LV_TYPE EQ GC_S.
    CLEAR LS_DATA.
    LS_DATA = VALUE #( LT_DATA[ 1 ] OPTIONAL ).
    IF LS_DATA-MTYPE EQ GC_S.
      PV_TYPE = GC_S.

    ELSE.
      PV_TYPE  = GC_E.
      PV_MSG   = LS_DATA-MSG.
    ENDIF.
  ELSE.
    PV_TYPE = LV_TYPE.
    PV_MSG  = LV_MSG.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROCESS_JS_STEP_J
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> <FS_0100>
*&      <-- GV_STATUS_CUR
*&---------------------------------------------------------------------*
FORM PROCESS_JS_STEP_J  USING    PS_0100 LIKE GT_0100
                        CHANGING PV_STATUS.
  DATA: LV_STAT TYPE ZGTSDT9110-ZZJS_STATUS,
        LV_TYPE TYPE BAPI_MTYPE,
        LV_MSG  TYPE BAPI_MSG.
  DATA: LV_CHK1(1), "당월 처리 DO 생성
        LV_STEP_M(1),
        LV_CHK2(1), "익월이후 처리 DO 생성
        LV_STEP_JS(1).

  LV_STAT = PV_STATUS.
  "현재상태 다음단계 상태코드 가져옴( 현재 처리 상태코드 )
  PERFORM GET_STATUS_CODE_NEXT CHANGING LV_STAT.

  GV_STATUS_ERR = LV_STAT.

*-ZGTSDT9110
  SELECT SINGLE *
    FROM ZGTSDT9110
   WHERE VBELN EQ @PS_0100-VBELN_VL
     AND LOEVM EQ @SPACE
    INTO @DATA(LS_ZGTSDT9110).
  IF LS_ZGTSDT9110-ZZJS_STATUS NE PV_STATUS. "신규 DO 생성 - 'I'
    PS_0100-RSLT_PROC = GC_E.
    PS_0100-MESSAGE   = TEXT-M27.
  ENDIF.

*-ZGTSDT9120
  SELECT *
    FROM ZGTSDT9120
   WHERE VBELN EQ @PS_0100-VBELN_VL
     AND UECHA EQ '000000'
     AND LOEVM EQ @SPACE
    INTO TABLE @DATA(LT_ZGTSDT9120).

  IF PS_0100-RSLT_PROC NE GC_E.
*----------------------------------------------------------
*-STEP1 : 당월처리 ZLF
*----------------------------------------------------------
    DATA(LT_TEMP) = LT_ZGTSDT9120[].
    DELETE LT_TEMP WHERE MILLCA_FACTOR_M <= 0.
    SORT LT_TEMP BY VBELN POSNR VGBEL VGPOS.
    IF LT_TEMP[] IS NOT INITIAL.
      SELECT A~*
        INTO TABLE @DATA(LT_LIPS)
        FROM LIPS AS A INNER JOIN LIKP AS B
                       ON A~VBELN = B~VBELN
         FOR ALL ENTRIES IN @LT_TEMP
       WHERE A~VGBEL      EQ @LT_TEMP-VGBEL
         AND A~ZZVBELN_JS EQ @LT_TEMP-VBELN
         AND B~VKORG      EQ @PS_0100-VKORG
         AND B~LFART      EQ @GC_LFART_ZLF.
      IF SY-SUBRC EQ 0.
        LOOP AT LT_LIPS INTO DATA(LS_LIPS) WHERE UECHA NE '000000'.
          EXIT.
        ENDLOOP.
        IF SY-SUBRC EQ 0.
          LV_STEP_M = GC_X.
        ELSE.

*       당월처리 DO BATCH SPLIT
          PERFORM JS_DO_BATCH_SPLIT    USING PS_0100
                                       CHANGING LV_TYPE LV_MSG.
          IF LV_TYPE EQ GC_S.
            LV_STEP_M = GC_X.

          ELSE.
            PS_0100-RSLT_PROC = GC_E.
            PS_0100-MESSAGE   = LV_MSG.
          ENDIF.

        ENDIF.

      ELSE.
        PS_0100-RSLT_PROC = GC_E.
        PS_0100-MESSAGE   = TEXT-M15.
      ENDIF.

    ELSE.
      "당월처리 DO가 없는 경우 처리 된것으로 간주
      GV_ZLF3_ONLY      = GC_X.
      LV_STEP_M = GC_X.
    ENDIF.

*----------------------------------------------------------
*-STEP2 : 익월이후 처리 ZLF3
*----------------------------------------------------------
    CLEAR: LT_TEMP[],LV_TYPE,LV_MSG.
    LT_TEMP[] = LT_ZGTSDT9120[].
    DELETE LT_TEMP WHERE MILLCA_FACTOR_JS <= 0.
    SORT LT_TEMP BY VBELN POSNR VGBEL VGPOS.
    IF LT_TEMP[] IS NOT INITIAL.
      CLEAR LT_LIPS[].
      SELECT A~*
        INTO TABLE @LT_LIPS
        FROM LIPS AS A INNER JOIN LIKP AS B
                       ON A~VBELN = B~VBELN
         FOR ALL ENTRIES IN @LT_TEMP
       WHERE A~VGBEL      EQ @LT_TEMP-VGBEL
         AND A~ZZVBELN_JS EQ @LT_TEMP-VBELN
         AND B~VKORG      EQ @PS_0100-VKORG
         AND B~LFART      EQ @GC_LFART_ZLF3.
      IF SY-SUBRC EQ 0.
        LOOP AT LT_LIPS INTO LS_LIPS WHERE UECHA NE '000000'.
          EXIT.
        ENDLOOP.
        IF SY-SUBRC EQ 0.
          LV_STEP_JS = GC_X.
        ELSE.

*       익월이후 처리 DO BATCH SPLIT
          PERFORM JS_DO_BATCH_SPLIT_JS    USING PS_0100
                                       CHANGING LV_TYPE LV_MSG.
          IF LV_TYPE EQ GC_S.
            LV_STEP_JS = GC_X.

          ELSE.
            PS_0100-RSLT_PROC = GC_E.
            PS_0100-MESSAGE   = LV_MSG.
          ENDIF.

        ENDIF.

      ELSE.
        PS_0100-RSLT_PROC = GC_E.
        PS_0100-MESSAGE   = TEXT-M16.
      ENDIF.

    ELSE.
      "익월처리 DO가 없는 경우 처리 된것으로 간주
      LV_STEP_JS = GC_X.
    ENDIF.

*-BATCH SPLIT 체크
    IF LV_STEP_M  EQ GC_X AND
       LV_STEP_JS EQ GC_X.
      PV_STATUS  = LV_STAT.
    ENDIF.

  ENDIF.

  "DB 상태코드 UPDATE + OUTPUT LIST 의 상태코드 LED 변경
  PERFORM SET_LED_JS    USING LV_STAT
                     CHANGING PS_0100.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form JS_DO_BATCH_SPLIT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PS_0100
*&      <-- LV_TYPE
*&      <-- LV_MSG
*&---------------------------------------------------------------------*
FORM JS_DO_BATCH_SPLIT  USING   PS_0100 LIKE GT_0100
                       CHANGING PV_TYPE
                                PV_MSG.
  DATA: LV_TYPE TYPE BAPI_MTYPE,
        LV_MSG  TYPE BAPI_MSG.

  DATA: LT_ITEM  TYPE TABLE OF ZGTSDS0023,
        LS_ITEM  TYPE ZGTSDS0023,
        LT_BATCH TYPE TABLE OF ZGTSDS0024,
        LS_BATCH TYPE ZGTSDS0024.
  DATA: LV_POSNR TYPE POSNR_VL.
  DATA: LV_LENGTH_VRKME TYPE LFIMG,
        LV_LFIMG        TYPE LFIMG.

*-ZGTSDT9120
  SELECT *
    FROM ZGTSDT9120
   WHERE VBELN EQ @PS_0100-VBELN_VL
    INTO TABLE @DATA(LT_ZGTSDT9120).
  SORT LT_ZGTSDT9120 BY VGBEL VBELN.

*-LIKP+LIPS : ZLF
  SELECT A~*,B~*
      INTO TABLE @DATA(LT_LIPS)
      FROM LIPS AS A INNER JOIN LIKP AS B
                     ON A~VBELN = B~VBELN
       FOR ALL ENTRIES IN @LT_ZGTSDT9120
     WHERE A~VGBEL      EQ @LT_ZGTSDT9120-VGBEL
       AND A~ZZVBELN_JS EQ @LT_ZGTSDT9120-VBELN
       AND B~VKORG      EQ @GC_VKORG_6000
       AND B~LFART      EQ @GC_LFART_ZLF.
  IF LT_LIPS[] IS INITIAL.
    PV_TYPE = GC_E.
    PV_MSG  = TEXT-M15.
    EXIT.
  ENDIF.

  SORT LT_LIPS BY A-VBELN A-POSNR.

* BATCH ITEM NUMBER
  DATA(LV_VBELN) = VALUE #( LT_LIPS[ 1 ]-A-VBELN OPTIONAL ).
  SELECT MAX( POSNR )
    INTO LV_POSNR
    FROM LIPS
   WHERE VBELN EQ LV_VBELN
     AND UECHA NE '000000'.
  IF LV_POSNR IS INITIAL.
    LV_POSNR = '900000'.
  ENDIF.

  LOOP AT LT_LIPS INTO DATA(LS_LIPS).

    "ITEM
    CLEAR:LS_ITEM.
    LS_ITEM-VBELN = LS_LIPS-A-VBELN.
    LS_ITEM-POSNR = LS_LIPS-A-POSNR.
    LS_ITEM-MATNR = LS_LIPS-A-MATNR.
    LS_ITEM-WERKS = LS_LIPS-A-WERKS.
    LS_ITEM-CHARG = LS_LIPS-A-CHARG.
    LS_ITEM-LFIMG = LS_LIPS-A-LFIMG.
    LS_ITEM-VRKME = LS_LIPS-A-VRKME.
    LS_ITEM-UPDKZ = GC_U.


    "BATCH
    LOOP AT LT_ZGTSDT9120 INTO DATA(LS_LINE) WHERE VBELN = LS_LIPS-A-ZZVBELN_JS
                                               AND UECHA = LS_LIPS-A-ZZPOSNR_JS
                                               AND VGBEL = LS_LIPS-A-VGBEL
                                               AND VGPOS = LS_LIPS-A-VGPOS
                                               AND MILLCA_FACTOR_M GE 1.
      LV_POSNR = LV_POSNR + 1.

      CLEAR LS_BATCH.
      LS_BATCH-VBELN = LS_LIPS-A-VBELN.
      LS_BATCH-UECHA = LS_LIPS-A-POSNR.
      LS_BATCH-POSNR = LV_POSNR.
      LS_BATCH-MATNR = LS_LIPS-A-MATNR.
      LS_BATCH-WERKS = LS_LIPS-A-WERKS.
      LS_BATCH-LGORT = GC_LGORT_3499.
      LS_BATCH-CHARG = LS_LINE-CHARG.

      "조장
      CLEAR:LV_LENGTH_VRKME,LV_LFIMG.
      PERFORM GET_SAP_LENGTH_VRKME      USING LS_LINE-VGBEL LS_LINE-VGPOS
                                     CHANGING LV_LENGTH_VRKME.
      LV_LFIMG = LV_LENGTH_VRKME * LS_LINE-MILLCA_FACTOR_M.

      LS_BATCH-LFIMG = LV_LFIMG.
      LS_BATCH-UPDKZ = GC_I.

      "ITEM 수량에서 BATCH 수량 차감
      LS_ITEM-LFIMG = LS_ITEM-LFIMG - LV_LFIMG.

      APPEND LS_BATCH TO LT_BATCH.
    ENDLOOP.

    APPEND LS_ITEM TO LT_ITEM.
  ENDLOOP.

*-BATCH SPLIT 수행
  CALL FUNCTION 'ZGTSD_DO_BATCH_SPLIT'
    IMPORTING
      E_TYPE   = LV_TYPE
      E_MSG    = LV_MSG
    TABLES
      IT_ITEM  = LT_ITEM
      IT_BATCH = LT_BATCH.

  PV_TYPE = LV_TYPE.
  PV_MSG  = LV_MSG.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form JS_DO_BATCH_SPLIT_JS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PS_0100
*&      <-- LV_TYPE
*&      <-- LV_MSG
*&---------------------------------------------------------------------*
FORM JS_DO_BATCH_SPLIT_JS  USING    PS_0100 LIKE GT_0100
                       CHANGING PV_TYPE
                                PV_MSG.
  DATA: LV_TYPE TYPE BAPI_MTYPE,
        LV_MSG  TYPE BAPI_MSG.

  DATA: LT_ITEM  TYPE TABLE OF ZGTSDS0023,
        LS_ITEM  TYPE ZGTSDS0023,
        LT_BATCH TYPE TABLE OF ZGTSDS0024,
        LS_BATCH TYPE ZGTSDS0024.
  DATA: LV_POSNR TYPE POSNR_VL.
  DATA: LV_LENGTH_VRKME TYPE LFIMG,
        LV_LFIMG        TYPE LFIMG.

*-ZGTSDT9120
  SELECT *
    FROM ZGTSDT9120
   WHERE VBELN EQ @PS_0100-VBELN_VL
    INTO TABLE @DATA(LT_ZGTSDT9120).
  SORT LT_ZGTSDT9120 BY VGBEL VBELN.

*-LIKP+LIPS : ZLF3
  SELECT A~*,B~*
      INTO TABLE @DATA(LT_LIPS)
      FROM LIPS AS A INNER JOIN LIKP AS B
                     ON A~VBELN = B~VBELN
       FOR ALL ENTRIES IN @LT_ZGTSDT9120
     WHERE A~VGBEL      EQ @LT_ZGTSDT9120-VGBEL
       AND A~ZZVBELN_JS EQ @LT_ZGTSDT9120-VBELN
       AND B~VKORG      EQ @GC_VKORG_6000
       AND B~LFART      EQ @GC_LFART_ZLF3.
  IF LT_LIPS[] IS INITIAL.
    PV_TYPE = GC_E.
    PV_MSG  = TEXT-M16.
    EXIT.
  ENDIF.

  SORT LT_LIPS BY A-VBELN A-POSNR.

* BATCH ITEM NUMBER
  DATA(LV_VBELN) = VALUE #( LT_LIPS[ 1 ]-A-VBELN OPTIONAL ).
  SELECT MAX( POSNR )
    INTO LV_POSNR
    FROM LIPS
   WHERE VBELN EQ LV_VBELN
     AND UECHA NE '000000'.
  IF LV_POSNR IS INITIAL.
    LV_POSNR = '900000'.
  ENDIF.

  LOOP AT LT_LIPS INTO DATA(LS_LIPS).

    "ITEM
    CLEAR:LS_ITEM.
    LS_ITEM-VBELN = LS_LIPS-A-VBELN.
    LS_ITEM-POSNR = LS_LIPS-A-POSNR.
    LS_ITEM-MATNR = LS_LIPS-A-MATNR.
    LS_ITEM-WERKS = LS_LIPS-A-WERKS.
    LS_ITEM-CHARG = LS_LIPS-A-CHARG.
    LS_ITEM-LFIMG = LS_LIPS-A-LFIMG.
    LS_ITEM-VRKME = LS_LIPS-A-VRKME.
    LS_ITEM-UPDKZ = GC_U.


    "BATCH
    LOOP AT LT_ZGTSDT9120 INTO DATA(LS_LINE) WHERE VBELN = LS_LIPS-A-ZZVBELN_JS
                                               AND UECHA = LS_LIPS-A-ZZPOSNR_JS
                                               AND VGBEL = LS_LIPS-A-VGBEL
                                               AND VGPOS = LS_LIPS-A-VGPOS
                                               AND MILLCA_FACTOR_JS GE 1.
      LV_POSNR = LV_POSNR + 1.

      CLEAR LS_BATCH.
      LS_BATCH-VBELN = LS_LIPS-A-VBELN.
      LS_BATCH-UECHA = LS_LIPS-A-POSNR.
      LS_BATCH-POSNR = LV_POSNR.
      LS_BATCH-MATNR = LS_LIPS-A-MATNR.
      LS_BATCH-WERKS = LS_LIPS-A-WERKS.
      LS_BATCH-LGORT = GC_LGORT_3499.
      LS_BATCH-CHARG = LS_LINE-CHARG.

      "조장
      CLEAR:LV_LENGTH_VRKME,LV_LFIMG.
      PERFORM GET_SAP_LENGTH_VRKME      USING LS_LINE-VGBEL LS_LINE-VGPOS
                                     CHANGING LV_LENGTH_VRKME.
      LV_LFIMG = LV_LENGTH_VRKME * LS_LINE-MILLCA_FACTOR_JS.

      LS_BATCH-LFIMG = LV_LFIMG.
      LS_BATCH-UPDKZ = GC_I.

      "ITEM 수량에서 BATCH 수량 차감
      LS_ITEM-LFIMG = LS_ITEM-LFIMG - LV_LFIMG.

      APPEND LS_BATCH TO LT_BATCH.
    ENDLOOP.

    APPEND LS_ITEM TO LT_ITEM.
  ENDLOOP.

*-BATCH SPLIT 수행
  CALL FUNCTION 'ZGTSD_DO_BATCH_SPLIT'
    IMPORTING
      E_TYPE   = LV_TYPE
      E_MSG    = LV_MSG
    TABLES
      IT_ITEM  = LT_ITEM
      IT_BATCH = LT_BATCH.

  PV_TYPE = LV_TYPE.
  PV_MSG  = LV_MSG.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROCESS_JS_STEP_K
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> <FS_0100>
*&      <-- GV_STATUS_CUR
*&---------------------------------------------------------------------*
FORM PROCESS_JS_STEP_K  USING    PS_0100 LIKE GT_0100
                        CHANGING PV_STATUS.
  DATA: LV_STAT TYPE ZGTSDT9110-ZZJS_STATUS,
        LV_TYPE TYPE BAPI_MTYPE,
        LV_MSG  TYPE BAPI_MSG.

  LV_STAT = PV_STATUS.
  "현재상태 다음단계 상태코드 가져옴( 현재 처리 상태코드 )
  PERFORM GET_STATUS_CODE_NEXT CHANGING LV_STAT.

  GV_STATUS_ERR = LV_STAT.

*-ZGTSDT9110
  SELECT SINGLE *
    FROM ZGTSDT9110
   WHERE VBELN EQ @PS_0100-VBELN_VL
     AND LOEVM EQ @SPACE
    INTO @DATA(LS_ZGTSDT9110).
  IF LS_ZGTSDT9110-ZZJS_STATUS NE PV_STATUS. "배치지정-'J'
    PS_0100-RSLT_PROC = GC_E.
    PS_0100-MESSAGE   = TEXT-M28.
  ENDIF.

  IF PS_0100-RSLT_PROC NE GC_E.

*---ZGTSDT9120
    SELECT *
      FROM ZGTSDT9120
     WHERE VBELN EQ @PS_0100-VBELN_VL
       AND UECHA EQ '000000'
      INTO TABLE @DATA(LT_ZGTSDT9120).

*-당월처리분 미존재
    DATA(LT_TEMP) = LT_ZGTSDT9120[].
    DELETE LT_TEMP WHERE MILLCA_FACTOR_M <= 0.

    IF LT_TEMP[] IS INITIAL. "당월처리 대상이 없음 => PASS
      PS_0100-RSLT_PROC = GC_S.
      GV_ZLF3_ONLY      = GC_X.
      EXIT.
    ENDIF.

*-ZLF
    SELECT B~*
      INTO TABLE @DATA(LT_LIKP)
      FROM LIPS AS A INNER JOIN LIKP AS B
                     ON A~VBELN = B~VBELN
       FOR ALL ENTRIES IN @LT_ZGTSDT9120
     WHERE A~VGBEL      EQ @LT_ZGTSDT9120-VGBEL
       AND A~ZZVBELN_JS EQ @LT_ZGTSDT9120-VBELN
       AND B~VKORG      EQ @PS_0100-VKORG
       AND B~LFART      EQ @GC_LFART_ZLF.
    IF SY-SUBRC NE 0.
      PS_0100-RSLT_PROC = GC_E.
      PS_0100-MESSAGE   = TEXT-M15.

    ELSE.
      DATA(LS_LIKP) = VALUE #( LT_LIKP[ 1 ] OPTIONAL ).

      "출고완료 상태
      IF LS_LIKP-WBSTK EQ GC_C.
        PS_0100-RSLT_PROC = GC_S.
        PV_STATUS         = LV_STAT.
      ENDIF.
    ENDIF.

*-출고처리
    IF PS_0100-RSLT_PROC NE GC_E AND LS_LIKP-WBSTK NE GC_C.
      PERFORM JS_DO_PGI_ZLF   USING PS_0100 LS_LIKP
                            CHANGING LV_TYPE LV_MSG.
      IF LV_TYPE EQ GC_S.
        PS_0100-RSLT_PROC = GC_S.
        PV_STATUS         = LV_STAT.

      ELSE.
        PS_0100-RSLT_PROC = GC_E.
        PS_0100-MESSAGE   = LV_MSG.

      ENDIF.
    ENDIF.


  ENDIF.


  "DB 상태코드 UPDATE + OUTPUT LIST 의 상태코드 LED 변경
  PERFORM SET_LED_JS    USING LV_STAT
                     CHANGING PS_0100.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form JS_DO_PGI_ZLF
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PS_0100
*&      --> LV_TYPE
*&      --> LV_MSG
*&---------------------------------------------------------------------*
FORM JS_DO_PGI_ZLF  USING    PS_0100 LIKE GT_0100
                             PS_LIKP TYPE LIKP
                    CHANGING PV_TYPE
                             PV_MSG.
  DATA: LT_DATA TYPE TABLE OF ZGTSDS0032,
        LS_DATA TYPE ZGTSDS0032.
  DATA: LV_TYPE TYPE BAPI_MTYPE,
        LV_MSG  TYPE BAPI_MSG.

*-ZGTSDT9110
  SELECT SINGLE *
    FROM ZGTSDT9110
   WHERE VBELN EQ @PS_0100-VBELN_VL
    INTO @DATA(LS_ZGTSDT9110).


*-DO PGI
  CLEAR LS_DATA.
  LS_DATA-VBELN     = PS_LIKP-VBELN.
  LS_DATA-WADAT_IST = LS_ZGTSDT9110-WADAT_IST.
  APPEND LS_DATA TO LT_DATA.

  CALL FUNCTION 'ZGTSD_JS_GI'
    IMPORTING
      E_TYPE  = LV_TYPE
      E_MSG   = LV_MSG
    TABLES
      IT_DATA = LT_DATA.

  IF LV_TYPE EQ GC_S.
    CLEAR LS_DATA.
    LS_DATA = VALUE #( LT_DATA[ 1 ] OPTIONAL ).
    IF LS_DATA-MTYPE EQ GC_S.
      PV_TYPE = GC_S.

    ELSE.
      PV_TYPE  = GC_E.
      PV_MSG   = LS_DATA-MSG.
    ENDIF.

  ELSE.
    PV_TYPE = LV_TYPE.
    PV_MSG  = LV_MSG.
  ENDIF.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROCESS_JS_STEP_L
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> <FS_0100>
*&      <-- GV_STATUS_CUR
*&---------------------------------------------------------------------*
FORM PROCESS_JS_STEP_L  USING    PS_0100 LIKE GT_0100
                        CHANGING PV_STATUS.
  DATA: LV_STAT TYPE ZGTSDT9110-ZZJS_STATUS,
        LV_TYPE TYPE BAPI_MTYPE,
        LV_MSG  TYPE BAPI_MSG.

  LV_STAT = PV_STATUS.
  "현재상태 다음단계 상태코드 가져옴( 현재 처리 상태코드 )
  PERFORM GET_STATUS_CODE_NEXT CHANGING LV_STAT.

  GV_STATUS_ERR = LV_STAT.

*-ZGTSDT9120
  SELECT *
    FROM ZGTSDT9120
   WHERE VBELN EQ @PS_0100-VBELN_VL
     AND UECHA EQ '000000'
    INTO TABLE @DATA(LT_ZGTSDT9120).

*-당월처리분 미존재
  DATA(LT_TEMP) = LT_ZGTSDT9120[].
  DELETE LT_TEMP WHERE MILLCA_FACTOR_M <= 0.

  IF LT_TEMP[] IS INITIAL. "당월처리 대상이 없음 => 상태값만 업데이트
    PS_0100-RSLT_PROC = GC_S.
*    PV_STATUS         = LV_STAT.
    GV_ZLF3_ONLY      = GC_X.
    EXIT.
  ELSE.

*--이전상태 ZGTSDT9110-ZZJS_STATUS
    SELECT SINGLE ZZJS_STATUS
      FROM ZGTSDT9110
     WHERE VBELN EQ @PS_0100-VBELN_VL
      INTO @DATA(LV_STATUS).
    IF LV_STATUS NE PV_STATUS. "당월출고분 GI - 'K'
      PS_0100-RSLT_PROC = GC_E.
      PS_0100-MESSAGE   = TEXT-M29.
    ENDIF.


    IF PS_0100-RSLT_PROC NE GC_E.
*-ZLF
      SELECT B~*
        INTO TABLE @DATA(LT_LIKP)
        FROM LIPS AS A INNER JOIN LIKP AS B
                       ON A~VBELN = B~VBELN
         FOR ALL ENTRIES IN @LT_ZGTSDT9120
       WHERE A~VGBEL      EQ @LT_ZGTSDT9120-VGBEL
         AND A~ZZVBELN_JS EQ @LT_ZGTSDT9120-VBELN
         AND B~VKORG      EQ @PS_0100-VKORG
         AND B~LFART      EQ @GC_LFART_ZLF.
      IF SY-SUBRC NE 0.
        PS_0100-RSLT_PROC = GC_E.
        PS_0100-MESSAGE   = TEXT-M15.

      ELSE.
        DATA(LS_LIKP) = VALUE #( LT_LIKP[ 1 ] OPTIONAL ).

        "출고완료 상태
        IF LS_LIKP-WBSTK NE GC_C.
          PS_0100-RSLT_PROC = GC_E.
          PS_0100-MESSAGE   = TEXT-M18.
        ENDIF.

        "청구완료
        IF LS_LIKP-FKSTK EQ GC_C.
          PS_0100-RSLT_PROC = GC_S.
          PV_STATUS         = LV_STAT.
        ENDIF.
      ENDIF.

*-청구문서 생성
      IF PS_0100-RSLT_PROC NE GC_E AND LS_LIKP-FKSTK NE GC_C.
        PERFORM JS_DO_BILLING_ZLF     USING PS_0100 LS_LIKP
                                   CHANGING LV_TYPE LV_MSG.
        IF LV_TYPE EQ GC_S.
          PS_0100-RSLT_PROC = GC_S.
          PV_STATUS         = LV_STAT.

        ELSE.
          PS_0100-RSLT_PROC = GC_E.
          PS_0100-MESSAGE   = LV_MSG.

        ENDIF.

      ENDIF.
    ENDIF.
  ENDIF.

  "DB 상태코드 UPDATE + OUTPUT LIST 의 상태코드 LED 변경
  PERFORM SET_LED_JS    USING LV_STAT
                     CHANGING PS_0100.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form JS_DO_BILLING_ZLF
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PS_0100
*&      --> LS_LIKP
*&      <-- LV_TYPE
*&      <-- LV_MSG
*&---------------------------------------------------------------------*
FORM JS_DO_BILLING_ZLF  USING  PS_0100 LIKE GT_0100
                               PS_LIKP TYPE LIKP
                      CHANGING PV_TYPE
                               PV_MSG.
  DATA: LT_DATA TYPE TABLE OF ZGTSDS0033,
        LS_DATA TYPE ZGTSDS0033.
  DATA: LV_TYPE TYPE BAPI_MTYPE,
        LV_MSG  TYPE BAPI_MSG.

*-BILLING
  CLEAR LS_DATA.
  LS_DATA-VBELN     = PS_LIKP-VBELN.
  LS_DATA-WADAT_IST = PS_LIKP-WADAT_IST.
  APPEND LS_DATA TO LT_DATA.

  CALL FUNCTION 'ZGTSD_JS_BILLING'
    IMPORTING
      E_TYPE  = LV_TYPE
      E_MSG   = LV_MSG
    TABLES
      IT_DATA = LT_DATA.
  IF LV_TYPE EQ GC_S.
    CLEAR LS_DATA.
    LS_DATA = VALUE #( LT_DATA[ 1 ] OPTIONAL ).
    IF LS_DATA-MTYPE EQ GC_S.
      PV_TYPE = GC_S.

    ELSE.
      PV_TYPE  = GC_E.
      PV_MSG   = LS_DATA-MSG.
    ENDIF.
  ELSE.
    PV_TYPE = LV_TYPE.
    PV_MSG  = LV_MSG.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROCESS_BILLING_M_STEP
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PROCESS_BILLING_M_STEP .

  PERFORM CHECK_CHANGED_DATA USING GO_GRID.

*-01. 선택라인
  IF NOT ( LINE_EXISTS( GT_0100[ SEL = GC_X ] ) ).
    MESSAGE I004 DISPLAY LIKE GC_E.
    EXIT.
  ENDIF.

*-02. CHECK
  CLEAR GV_ERROR.
  PERFORM CHECK_BILLING_M_PROCESS.
  IF GV_ERROR IS NOT INITIAL.
    EXIT.
  ENDIF.

  CHECK ZGTSD_CL_COMMON=>POPUP_TO_COMFIRM( IV_UCOMM = SPACE IV_MESSA = TEXT-P04 ) EQ GC_J.

*-03. 청구분서 생성
  PERFORM PROCESS_BILLING_M_STEP_RUN.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_BILLING_M_PROCESS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CHECK_BILLING_M_PROCESS .

*-기존 처리 대상 지시자 CLEAR : RUN
  CLEAR GS_0100.
  MODIFY GT_0100 FROM GS_0100 TRANSPORTING RUN WHERE RUN = GC_X.

  DATA(LT_TEMP) = GT_0100[].
  DELETE LT_TEMP WHERE SEL NE GC_X.

*-ZGTSDT9110
  SELECT VBELN,ZZJS_STATUS
    FROM ZGTSDT9110
     FOR ALL ENTRIES IN @LT_TEMP
   WHERE VBELN EQ @LT_TEMP-VBELN_VL
    INTO TABLE @DATA(LT_ZGTSDT9110).

*-ZGTSDT9120
  IF LT_ZGTSDT9110[] IS NOT INITIAL.
    SELECT *
      FROM ZGTSDT9120
       FOR ALL ENTRIES IN @LT_ZGTSDT9110
     WHERE VBELN EQ @LT_ZGTSDT9110-VBELN
       AND UECHA EQ '000000'
      INTO TABLE @DATA(LT_ZGTSDT9120).
  ENDIF.

  LOOP AT GT_0100 ASSIGNING FIELD-SYMBOL(<FS_0100>) WHERE SEL EQ GC_X.
    DATA(LS_ZGTSDT9110) = VALUE #( LT_ZGTSDT9110[ VBELN = <FS_0100>-VBELN_VL ] OPTIONAL ).

    "당월출고분 없음.
    DATA(LT_TEMP20) = LT_ZGTSDT9120[].
    DELETE LT_TEMP20 WHERE VBELN NE <FS_0100>-VBELN_VL.
    DELETE LT_TEMP20 WHERE MILLCA_FACTOR_M <= 0.
    IF LT_TEMP20[] IS INITIAL.
      CLEAR:LT_TEMP20[], LS_ZGTSDT9110.
      CONTINUE.
    ENDIF.

    "BILLING 완료
    IF LS_ZGTSDT9110-ZZJS_STATUS EQ GC_L. "BILLING
      CLEAR:LT_TEMP20[], LS_ZGTSDT9110.
      CONTINUE.
    ENDIF.

    "DO PGI
    IF LS_ZGTSDT9110-ZZJS_STATUS NE GC_K.
      CLEAR:LT_TEMP20[], LS_ZGTSDT9110.
      CONTINUE.
    ENDIF.

    <FS_0100>-RUN = GC_X.

    CLEAR:LT_TEMP20[], LS_ZGTSDT9110.
  ENDLOOP.


  IF NOT ( LINE_EXISTS( GT_0100[ RUN = GC_X ] ) ).
    GV_ERROR = GC_X.
    MESSAGE I000 WITH TEXT-M19 DISPLAY LIKE GC_E.
    EXIT.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROCESS_BILLING_M_STEP_RUN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PROCESS_BILLING_M_STEP_RUN .

  LOOP AT GT_0100 ASSIGNING FIELD-SYMBOL(<FS_0100>) WHERE SEL EQ GC_X
                                                      AND RUN EQ GC_X.
    CLEAR:GV_STATUS_CUR,GV_STATUS_ERR.
    CLEAR:<FS_0100>-RSLT_PROC,<FS_0100>-MESSAGE,<FS_0100>-STAT.

*---LOCK OBJECT
    PERFORM SET_LOCK_OBJECT CHANGING <FS_0100>.
    IF <FS_0100>-RSLT_PROC EQ GC_E.
      <FS_0100>-STAT      = ICON_LED_RED.
      CONTINUE.
    ENDIF.

    GV_STATUS_CUR = <FS_0100>-ZZJS_STATUS.

    PERFORM PROCESS_JS_STEP_L      USING <FS_0100>
                                CHANGING GV_STATUS_CUR.

    "최종 STATUS
    SELECT SINGLE ZZJS_STATUS
      FROM ZGTSDT9110
     WHERE VBELN EQ @<FS_0100>-VBELN_VL
      INTO @<FS_0100>-ZZJS_STATUS.
    "적송완료
    IF <FS_0100>-ZZJS_STATUS EQ GC_L.
      <FS_0100>-ST_FINAL = ICON_LED_GREEN.
    ELSE.
      <FS_0100>-ST_FINAL = ICON_LED_YELLOW.
    ENDIF.

*---UNLOCK OBJECT
    PERFORM SET_UNLOCK_OBJECT CHANGING <FS_0100>-VBELN_VL.
  ENDLOOP.

  PERFORM REFRESH_ALV USING GO_GRID.

  IF LINE_EXISTS( GT_0100[ SEL = GC_X RUN = GC_X RSLT_PROC = GC_E ] ).
    MESSAGE I000 WITH TEXT-M20 TEXT-M21 DISPLAY LIKE GC_E.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROCESS_BILLING_M_CANCEL
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PROCESS_BILLING_M_CANCEL .

  PERFORM CHECK_CHANGED_DATA USING GO_GRID.

*-01. 선택라인
  IF NOT ( LINE_EXISTS( GT_0100[ SEL = GC_X ] ) ).
    MESSAGE I004 DISPLAY LIKE GC_E.
    EXIT.
  ENDIF.

*-02. CHECK
  CLEAR GV_ERROR.
  PERFORM CHECK_CANCEL_BILLING_M_PROCESS.
  IF GV_ERROR IS NOT INITIAL.
    EXIT.
  ENDIF.

  CHECK ZGTSD_CL_COMMON=>POPUP_TO_COMFIRM( IV_UCOMM = SPACE IV_MESSA = TEXT-P05 ) EQ GC_J.

*-청구문서 취소
  PERFORM PROCESS_BILLING_M_CANCEL_RUN.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_CANCEL_BILLING_M_PROCESS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CHECK_CANCEL_BILLING_M_PROCESS .

*-기존 처리 대상 지시자 CLEAR : RUN
  CLEAR GS_0100.
  MODIFY GT_0100 FROM GS_0100 TRANSPORTING RUN WHERE RUN = GC_X.

  DATA(LT_TEMP) = GT_0100[].
  DELETE LT_TEMP WHERE SEL NE GC_X.

*-ZGTSDT9110
  SELECT VBELN,ZZJS_STATUS
    FROM ZGTSDT9110
     FOR ALL ENTRIES IN @LT_TEMP
   WHERE VBELN EQ @LT_TEMP-VBELN_VL
    INTO TABLE @DATA(LT_ZGTSDT9110).

*-ZGTSDT9120
  IF LT_ZGTSDT9110[] IS NOT INITIAL.
    SELECT *
      FROM ZGTSDT9120
       FOR ALL ENTRIES IN @LT_ZGTSDT9110
     WHERE VBELN EQ @LT_ZGTSDT9110-VBELN
       AND UECHA EQ '000000'
      INTO TABLE @DATA(LT_ZGTSDT9120).
  ENDIF.

  LOOP AT GT_0100 ASSIGNING FIELD-SYMBOL(<FS_0100>) WHERE SEL EQ GC_X.
    DATA(LS_ZGTSDT9110) = VALUE #( LT_ZGTSDT9110[ VBELN = <FS_0100>-VBELN_VL ] OPTIONAL ).

    "당월출고분 없음.
    DATA(LT_TEMP20) = LT_ZGTSDT9120[].
    DELETE LT_TEMP20 WHERE VBELN NE <FS_0100>-VBELN_VL.
    DELETE LT_TEMP20 WHERE MILLCA_FACTOR_M <= 0.
    IF LT_TEMP20[] IS INITIAL.
      CLEAR:LT_TEMP20[], LS_ZGTSDT9110.
      CONTINUE.
    ENDIF.

    "BILLING 미완료
    IF LS_ZGTSDT9110-ZZJS_STATUS NE GC_L. "BILLING
      CLEAR:LT_TEMP20[], LS_ZGTSDT9110.
      CONTINUE.
    ENDIF.

    <FS_0100>-RUN = GC_X.

    CLEAR:LT_TEMP20[], LS_ZGTSDT9110.
  ENDLOOP.

  IF NOT ( LINE_EXISTS( GT_0100[ RUN = GC_X ] ) ).
    GV_ERROR = GC_X.
    MESSAGE I000 WITH TEXT-M22 DISPLAY LIKE GC_E.
    EXIT.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROCESS_BILLING_M_CANCEL_RUN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PROCESS_BILLING_M_CANCEL_RUN .

  LOOP AT GT_0100 ASSIGNING FIELD-SYMBOL(<FS_0100>) WHERE SEL EQ GC_X
                                                      AND RUN EQ GC_X.

    CLEAR:GV_STATUS_CUR,GV_STATUS_ERR.
    CLEAR:<FS_0100>-RSLT_PROC,<FS_0100>-MESSAGE,<FS_0100>-STAT.

*---LOCK OBJECT
    PERFORM SET_LOCK_OBJECT CHANGING <FS_0100>.
    IF <FS_0100>-RSLT_PROC EQ GC_E.
      <FS_0100>-STAT      = ICON_LED_RED.
      CONTINUE.
    ENDIF.

    "BILLING 취소
    PERFORM CANCEL_BILLING_M_STEP  USING <FS_0100> GC_X.

    "최종 STATUS
    SELECT SINGLE ZZJS_STATUS
      FROM ZGTSDT9110
     WHERE VBELN EQ @<FS_0100>-VBELN_VL
      INTO @<FS_0100>-ZZJS_STATUS.
    "적송완료
    IF <FS_0100>-ZZJS_STATUS EQ GC_L.
      <FS_0100>-ST_FINAL = ICON_LED_GREEN.
    ELSE.
      <FS_0100>-ST_FINAL = ICON_LED_YELLOW.
    ENDIF.

*---UNLOCK OBJECT
    PERFORM SET_UNLOCK_OBJECT CHANGING <FS_0100>-VBELN_VL.
  ENDLOOP.

  PERFORM REFRESH_ALV USING GO_GRID.

  IF LINE_EXISTS( GT_0100[ SEL = GC_X RUN = GC_X RSLT_PROC = GC_E ] ).
    MESSAGE I000 WITH TEXT-M24 TEXT-M21 DISPLAY LIKE GC_E.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CANCEL_BILLING_M_STEP
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> <FS_0100>
*&---------------------------------------------------------------------*
FORM CANCEL_BILLING_M_STEP  USING   PS_0100 LIKE GT_0100
                                    PV_STEP.
  DATA: LV_BILLINGDOCUMENT TYPE  BAPIVBRKSUCCESS-BILL_DOC,
        LV_BILLINGDATE     TYPE  BF_DATM1EB,
        LT_RETURN          TYPE TABLE OF  BAPIRETURN1,
        LT_SUCCESS         TYPE TABLE OF BAPIVBRKSUCCESS.

  DATA: LV_STAT TYPE ZGTSDT9110-ZZJS_STATUS,
        LV_TYPE TYPE BAPI_MTYPE,
        LV_MSG  TYPE BAPI_MSG.

  DATA: LV_MESSAGE(220).

*-청구문서
  SELECT A~VBELN AS VBELN_VL,A~POSNR AS POSNR_VL,
         C~VBELN AS VBELN_VF,C~POSNR AS POSNR_VF,
         D~FKDAT
    FROM LIPS AS A INNER JOIN LIKP AS B
                   ON A~VBELN = B~VBELN
                   INNER JOIN VBRP AS C
                   ON A~VBELN = C~VGBEL AND
                      A~POSNR = C~VGPOS
                   INNER JOIN VBRK AS D
                   ON C~VBELN = D~VBELN AND
                      D~SFAKN = @SPACE  AND
                      D~FKSTO = @SPACE
   WHERE A~ZZVBELN_JS EQ @PS_0100-VBELN_VL  "ORIGINAL DO
     AND A~UECHA      EQ '000000'
     AND B~VKORG      EQ @PS_0100-VKORG
     AND B~LFART      EQ @GC_LFART_ZLF
    INTO TABLE @DATA(LT_VBRP).
  IF SY-SUBRC NE 0.
    PS_0100-RSLT_PROC = GC_E.
    PS_0100-MESSAGE   = TEXT-M23.
    EXIT.
  ENDIF.


*-BILLING 취소

  DATA(LS_VBRP) = VALUE #( LT_VBRP[ 1 ] OPTIONAL ).

  LV_BILLINGDOCUMENT = LS_VBRP-VBELN_VF.
  LV_BILLINGDATE     = LS_VBRP-FKDAT.

  CALL FUNCTION 'BAPI_BILLINGDOC_CANCEL1'
    EXPORTING
      BILLINGDOCUMENT = LV_BILLINGDOCUMENT
*     NO_COMMIT       = GC_X
      BILLINGDATE     = LV_BILLINGDATE
    TABLES
      RETURN          = LT_RETURN
      SUCCESS         = LT_SUCCESS.

  LOOP AT LT_RETURN INTO DATA(LS_RETURN) WHERE TYPE CA 'AE'.
    IF LV_MESSAGE IS INITIAL.
      LV_MESSAGE = LS_RETURN-MESSAGE.
    ELSE.
      LV_MESSAGE = |{ LV_MESSAGE }/{ LS_RETURN-MESSAGE }|.
    ENDIF.
  ENDLOOP.

  IF SY-SUBRC EQ 0.
    __BAPI_TRANSACTION_ROLLBACK.

    PS_0100-RSLT_PROC = GC_E.
    PS_0100-MESSAGE   = LV_MESSAGE.

    PS_0100-STAT      = ICON_LED_RED.

  ELSE.

    "DB UPDATE
    IF PV_STEP EQ GC_X.
      UPDATE ZGTSDT9110 SET ZZJS_STATUS = GC_K
                      WHERE VBELN EQ PS_0100-VBELN_VL.
    ENDIF.

    __BAPI_TRANSACTION_COMMIT.

    WAIT UP TO '1' SECONDS.

    PS_0100-RSLT_PROC = GC_S.

    PS_0100-ST_FBL    = ICON_LED_YELLOW.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_LOCK_OBJECT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- <FS_0100>
*&---------------------------------------------------------------------*
FORM SET_LOCK_OBJECT  CHANGING PS_0100 LIKE GT_0100.

  CALL FUNCTION 'ENQUEUE_EZGT_ZGTSDT9110'
    EXPORTING
      VBELN          = PS_0100-VBELN_VL
    EXCEPTIONS
      FOREIGN_LOCK   = 1
      SYSTEM_FAILURE = 2
      OTHERS         = 3.
  IF SY-SUBRC <> 0.
    PS_0100-RSLT_PROC = GC_E.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
       WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4
       INTO PS_0100-MESSAGE.
  ENDIF.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_UNLOCK_OBJECT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- <FS_0100>
*&---------------------------------------------------------------------*
FORM SET_UNLOCK_OBJECT  CHANGING PV_VBELN_VL.
  CALL FUNCTION 'DEQUEUE_EZGT_ZGTSDT9110'
    EXPORTING
      VBELN = PV_VBELN_VL.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROCESS_JS_STEP_CANCEL
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PROCESS_JS_STEP_CANCEL .
  PERFORM CHECK_CHANGED_DATA USING GO_GRID.

*-01. 선택라인
  IF NOT ( LINE_EXISTS( GT_0100[ SEL = GC_X ] ) ).
    MESSAGE I004 DISPLAY LIKE GC_E.
    EXIT.
  ENDIF.

*-02. CHECK
  CLEAR GV_ERROR.
  PERFORM CHECK_JS_PROCESS_CANCEL.
  IF GV_ERROR IS NOT INITIAL.
    EXIT.
  ENDIF.

  CHECK ZGTSD_CL_COMMON=>POPUP_TO_COMFIRM( IV_UCOMM = SPACE IV_MESSA = TEXT-P06 ) EQ GC_J.

*-03. 적송취소
  PERFORM PROCESS_JS_CANCEL_STEP_RUN.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_JS_PROCESS_CANCEL
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CHECK_JS_PROCESS_CANCEL .

*-기존 처리 대상 지시자 CLEAR : RUN
  CLEAR GS_0100.
  MODIFY GT_0100 FROM GS_0100 TRANSPORTING RUN WHERE RUN = GC_X.

  LOOP AT GT_0100 ASSIGNING FIELD-SYMBOL(<FS_0100>) WHERE SEL EQ GC_X.

*---03. 적송처리 상태가 원천데이터저장(DBS)  와 당월출고분 빌링(FBL) 사이인 건
    IF <FS_0100>-ZZJS_STATUS >= GC_A AND
       <FS_0100>-ZZJS_STATUS =< GC_L.
    ELSE.
      CONTINUE.
    ENDIF.

    "적송처리 대상
    <FS_0100>-RUN = GC_X.
  ENDLOOP.

  IF NOT ( LINE_EXISTS( GT_0100[ RUN = GC_X ] ) ).
    GV_ERROR = GC_X.
    MESSAGE I000 WITH TEXT-M37 DISPLAY LIKE GC_E.
    EXIT.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROCESS_JS_CANCEL_STEP_RUN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PROCESS_JS_CANCEL_STEP_RUN .
  DATA:LV_CHK_ZLF3(1).

  CLEAR GV_ERROR.

  LOOP AT GT_0100 ASSIGNING FIELD-SYMBOL(<FS_0100>) WHERE SEL = GC_X
                                                      AND RUN = GC_X.
    CLEAR:GV_STATUS_CUR,GV_STATUS_ERR.
    CLEAR:<FS_0100>-RSLT_PROC,<FS_0100>-MESSAGE,<FS_0100>-STAT.
    CLEAR:GV_ZLF3_ONLY.

    SELECT SINGLE ZZJS_STATUS
      FROM ZGTSDT9110
     WHERE VBELN EQ @<FS_0100>-VBELN_VL
       AND LOEVM EQ @SPACE
      INTO @GV_STATUS_CUR.
    IF GV_STATUS_CUR NE <FS_0100>-ZZJS_STATUS.
      <FS_0100>-RSLT_PROC = GC_E.
      <FS_0100>-MESSAGE   = TEXT-M43.
      <FS_0100>-STAT      = ICON_LED_RED.
      CONTINUE.
    ENDIF.

*    GV_STATUS_CUR = <FS_0100>-ZZJS_STATUS.



    "당월처리건 존재 여부
    SELECT SINGLE A~VBELN
      FROM LIKP AS A INNER JOIN LIPS AS B
                     ON A~VBELN = B~VBELN
     WHERE A~LFART      EQ @GC_LFART_ZLF
       AND B~ZZVBELN_JS EQ @<FS_0100>-VBELN_VL
      INTO @DATA(LS_LIKP).
    IF SY-SUBRC EQ 0.
      CLEAR:GV_ZLF3_ONLY.
    ELSE.
      GV_ZLF3_ONLY = GC_X.
    ENDIF.

*---적송매출 발생건은 취소 불가
    CLEAR LV_CHK_ZLF3.
    PERFORM CHECK_SPLIT_ZLF3    USING <FS_0100>
                             CHANGING LV_CHK_ZLF3.
    IF LV_CHK_ZLF3 EQ GC_E.
      <FS_0100>-RSLT_PROC = GC_E.
      <FS_0100>-MESSAGE   = TEXT-M54.
      <FS_0100>-STAT      = ICON_LED_RED.
      CONTINUE.
    ENDIF.


*---LOCK OBJECT
    PERFORM SET_LOCK_OBJECT CHANGING <FS_0100>.
    IF <FS_0100>-RSLT_PROC EQ GC_E.
      <FS_0100>-STAT = ICON_LED_RED.
      CONTINUE.
    ENDIF.

*---ZZSTATUS_JS - L	: 빌링 취소
    IF GV_STATUS_CUR EQ GC_L.
      PERFORM PROCESS_JS_STEP_CANCEL_L    USING <FS_0100>
                                       CHANGING GV_STATUS_CUR.
    ENDIF.

*---ZZSTATUS_JS - K	: 출고취소
    IF GV_STATUS_CUR EQ GC_K.
      PERFORM PROCESS_JS_STEP_CANCEL_K    USING <FS_0100>
                                       CHANGING GV_STATUS_CUR.
    ENDIF.

*---ZZSTATUS_JS - J OR I  : 신규 DO 삭제
    IF GV_STATUS_CUR EQ GC_I OR
       GV_STATUS_CUR EQ GC_J.
      PERFORM PROCESS_JS_STEP_CANCEL_I    USING <FS_0100>
                                       CHANGING GV_STATUS_CUR.
    ENDIF.

*---ZZSTATUS_JS - H	: 가상창고로 재고이동
    IF GV_STATUS_CUR EQ GC_H.
      PERFORM PROCESS_JS_STEP_CANCEL_H    USING <FS_0100>
                                       CHANGING GV_STATUS_CUR.
    ENDIF.

*---ZZSTATUS_JS - G	: 서비스 출고 취소
    IF GV_STATUS_CUR EQ GC_G.
      PERFORM PROCESS_JS_STEP_CANCEL_G    USING <FS_0100>
                                       CHANGING GV_STATUS_CUR.
    ENDIF.

*---ZZSTATUS_JS - F/E	: 주요속성 원복
    IF GV_STATUS_CUR EQ GC_E OR
       GV_STATUS_CUR EQ GC_F.
      PERFORM PROCESS_JS_STEP_CANCEL_E    USING <FS_0100>
                                       CHANGING GV_STATUS_CUR.
    ENDIF.

*---ZZSTATUS_JS - D	: 기존 DO 배치 지정
    IF GV_STATUS_CUR EQ GC_D.
      PERFORM PROCESS_JS_STEP_CANCEL_D    USING <FS_0100>
                                       CHANGING GV_STATUS_CUR.
    ENDIF.

*---ZZSTATUS_JS - C	: 헤더 납품보류 해제
    IF GV_STATUS_CUR EQ GC_C.
      PERFORM PROCESS_JS_STEP_CANCEL_C    USING <FS_0100>
                                       CHANGING GV_STATUS_CUR.
    ENDIF.

*---ZZSTATUS_JS - B	: 출고
    IF GV_STATUS_CUR EQ GC_B.
      PERFORM PROCESS_JS_STEP_CANCEL_B    USING <FS_0100>
                                       CHANGING GV_STATUS_CUR.
    ENDIF.

*---ZZSTATUS_JS - A	: 원천 데이터 삭제
    IF GV_STATUS_CUR EQ GC_A.
      PERFORM PROCESS_JS_STEP_CANCEL_A    USING <FS_0100>
                                       CHANGING GV_STATUS_CUR.
    ENDIF.


*    "최종 STATUS
    SELECT SINGLE ZZJS_STATUS,ZZJS_FINAL
      FROM ZGTSDT9110
     WHERE VBELN EQ @<FS_0100>-VBELN_VL
      INTO ( @<FS_0100>-ZZJS_STATUS,@<FS_0100>-ZZJS_FINAL ).
    IF GV_ZLF3_ONLY EQ GC_X.
      IF <FS_0100>-ZZJS_STATUS NE GC_J.
        <FS_0100>-ST_FINAL = ICON_LED_YELLOW.
      ENDIF.
    ELSE.
      IF <FS_0100>-ZZJS_STATUS NE GC_L.
        <FS_0100>-ST_FINAL = ICON_LED_YELLOW.
      ENDIF.
    ENDIF.

*---UNLOCK OBJECT
    PERFORM SET_UNLOCK_OBJECT CHANGING <FS_0100>-VBELN_VL.

  ENDLOOP.

  PERFORM REFRESH_ALV USING GO_GRID.

  IF LINE_EXISTS( GT_0100[ SEL = GC_X RUN = GC_X RSLT_PROC = GC_E ] ).
    MESSAGE I000 WITH TEXT-M25 TEXT-M21 DISPLAY LIKE GC_E.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROCESS_JS_STEP_CANCEL_L
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> <FS_0100>
*&      <-- GV_STATUS_CUR
*&---------------------------------------------------------------------*
FORM PROCESS_JS_STEP_CANCEL_L    USING PS_0100 LIKE GT_0100
                              CHANGING PV_STATUS.
  DATA: LV_STAT TYPE ZGTSDT9110-ZZJS_STATUS.
  DATA: LV_STEP(2).

  LV_STAT = PV_STATUS.

  GV_STATUS_ERR = LV_STAT.

  "현재상태 다음단계 상태코드 가져옴( 현재 처리 상태코드 )
  PERFORM GET_CANCEL_STATUS_CODE_NEXT CHANGING LV_STAT.

*-현재 상태코드 체크 : ZGTSDT9110-ZZJS_STATUS
  SELECT SINGLE ZZJS_STATUS
    FROM ZGTSDT9110
   WHERE VBELN EQ @PS_0100-VBELN_VL
     AND LOEVM EQ @SPACE
    INTO @DATA(LV_STATUS).
  IF PV_STATUS NE LV_STATUS.
    PS_0100-RSLT_PROC = GC_E.
    PS_0100-MESSAGE   = TEXT-M43.
  ENDIF.

*-당월처리건 상태
  SELECT SINGLE A~VBELN,A~FKSTK
    FROM LIKP AS A INNER JOIN LIPS AS B
                   ON A~VBELN = B~VBELN
   WHERE A~LFART      EQ @GC_LFART_ZLF
     AND B~ZZVBELN_JS EQ @PS_0100-VBELN_VL
    INTO @DATA(LS_LIKP).
  IF LS_LIKP-FKSTK NE GC_C.
    PS_0100-RSLT_PROC = GC_E.
    PS_0100-MESSAGE   = TEXT-M44.
  ENDIF.

  IF PS_0100-RSLT_PROC NE GC_E.
    "BILLING 취소
    PERFORM CANCEL_BILLING_M_STEP  USING PS_0100 SPACE.
    IF PS_0100-RSLT_PROC NE GC_E.
      PV_STATUS         = LV_STAT.
    ENDIF.
  ENDIF.

*  IF LV_STATUS EQ PV_STATUS.
*    IF LS_LIKP-FKSTK EQ GC_C.
*      LV_STEP = '03'.  "상태코드/청구완료
*    ELSE.
*      LV_STEP = '01'.  "상태 업데이트
*    ENDIF.
*
*  ELSE.
*    IF LV_STATUS EQ LV_STAT. "NEXT 상태
*      IF LS_LIKP-FKSTK EQ GC_C.
*        LV_STEP = '02'.  "청구완료
*      ELSE.
*        CLEAR LV_STEP.   "청구 미완료
*      ENDIF.
*    ELSE.
*      IF LS_LIKP-FKSTK EQ GC_C.
*        LV_STEP = '03'.  "상태코드/청구완료
*      ELSE.
*        LV_STEP = '01'. "상태 업데이트
*      ENDIF.
*    ENDIF.
*
*  ENDIF.
*
*  IF LV_STEP EQ '02'OR  "BILLING 취소
*     LV_STEP EQ '03'.
*    "BILLING 취소
*    PERFORM CANCEL_BILLING_M_STEP  USING PS_0100 SPACE.
*    IF PS_0100-RSLT_PROC NE GC_E.
*      PV_STATUS         = LV_STAT.
*    ENDIF.
*  ENDIF.

  "DB 상태코드 UPDATE + OUTPUT LIST 의 상태코드 LED 변경
  PERFORM SET_LED_JS_CANCEL    USING GV_STATUS_ERR
                                     LV_STAT
                                     LV_STEP
                            CHANGING PS_0100.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_CANCEL_STATUS_CODE_NEXT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- LV_STAT
*&---------------------------------------------------------------------*
FORM GET_CANCEL_STATUS_CODE_NEXT  CHANGING PV_STAT.

  SORT GT_CODE BY CODE DESCENDING.
  LOOP AT GT_CODE INTO DATA(LS_CODE) WHERE CODE < PV_STAT.
    PV_STAT = LS_CODE-CODE.
    EXIT.
  ENDLOOP.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_LED_JS_CALCEL
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LV_STAT
*&      <-- PS_0100
*&---------------------------------------------------------------------*
FORM SET_LED_JS_CANCEL  USING  PV_STATUS_BF
                               PV_STATUS_AF
                               PV_STEP
                      CHANGING PS_0100 LIKE GT_0100.
  DATA:LV_TEXT(20).
  DATA:LV_FINAL(1).

  DATA(LS_CODE) = VALUE #( GT_CODE[ CODE = PV_STATUS_BF ] OPTIONAL ).

  LV_TEXT = |ST_{ LS_CODE-STATUS }|.
  ASSIGN COMPONENT LV_TEXT OF STRUCTURE PS_0100 TO FIELD-SYMBOL(<FS_VAL>).
  CHECK SY-SUBRC EQ 0.

  IF PS_0100-RSLT_PROC EQ GC_E.
    PS_0100-STAT = ICON_LED_RED.
*    <FS_VAL> = ICON_LED_RED.
  ELSE.
    CLEAR PS_0100-STAT.
    <FS_VAL> = ICON_LED_YELLOW.

    "DB UPDATE
*    IF PV_STEP EQ '01' OR  "상태만 업데이트
*       PV_STEP EQ '03'.    "상태 + CANCEL

*      SELECT SINGLE ZZJS_FINAL
*        FROM ZGTSDT9110
*       WHERE VBELN EQ @PS_0100-VBELN_VL
*        INTO @LV_FINAL.
*
*      "당월출고분(ZLF)가 없는경우 신규 DO에 배치지정이 완료되면 최종완료 처리.
*      IF GV_ZLF3_ONLY EQ GC_X.
*        IF PV_STATUS EQ GC_J.
*          CLEAR LV_FINAL.
*        ENDIF.
*      ELSE.
*        IF PV_STATUS EQ GC_L.
*          CLEAR LV_FINAL.
*        ENDIF.
*      ENDIF.
    CLEAR LV_FINAL.

    UPDATE ZGTSDT9110 SET ZZJS_STATUS = PV_STATUS_AF
                          ZZJS_FINAL  = LV_FINAL
                    WHERE VBELN EQ PS_0100-VBELN_VL.
    IF SY-SUBRC EQ 0.
      COMMIT WORK AND WAIT.
    ENDIF.
*    ENDIF.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROCESS_JS_STEP_CANCEL_K
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> <FS_0100>
*&      <-- GV_STATUS_CUR
*&---------------------------------------------------------------------*
FORM PROCESS_JS_STEP_CANCEL_K  USING    PS_0100 LIKE GT_0100
                               CHANGING PV_STATUS.
  DATA: LV_STAT TYPE ZGTSDT9110-ZZJS_STATUS.
  DATA: LV_STEP(2).

  LV_STAT = PV_STATUS.

  GV_STATUS_ERR = LV_STAT.

  "현재상태 다음단계 상태코드 가져옴( 현재 처리 상태코드 )
  PERFORM GET_CANCEL_STATUS_CODE_NEXT CHANGING LV_STAT.


*-현재 상태코드 체크 : ZGTSDT9110-ZZJS_STATUS
  SELECT SINGLE ZZJS_STATUS
    FROM ZGTSDT9110
   WHERE VBELN EQ @PS_0100-VBELN_VL
     AND LOEVM EQ @SPACE
    INTO @DATA(LV_STATUS).
  IF PV_STATUS NE LV_STATUS.
    PS_0100-RSLT_PROC = GC_E.
    PS_0100-MESSAGE   = TEXT-M43.
  ENDIF.

*-당월처리건 상태
  SELECT SINGLE A~VBELN,A~WBSTK,A~FKSTK
    FROM LIKP AS A INNER JOIN LIPS AS B
                   ON A~VBELN = B~VBELN
   WHERE A~LFART      EQ @GC_LFART_ZLF
     AND B~ZZVBELN_JS EQ @PS_0100-VBELN_VL
    INTO @DATA(LS_LIKP).
  IF SY-SUBRC NE 0.
    PS_0100-RSLT_PROC = GC_E.
    PS_0100-MESSAGE   = TEXT-M15.

  ELSE.
    IF LS_LIKP-FKSTK EQ GC_C.
      PS_0100-RSLT_PROC = GC_E.
      PS_0100-MESSAGE   = TEXT-M39.
    ELSE.
      IF LS_LIKP-WBSTK NE GC_C.
        PS_0100-RSLT_PROC = GC_E.
        PS_0100-MESSAGE   = TEXT-M45.
      ENDIF.
    ENDIF.
  ENDIF.

  IF PS_0100-RSLT_PROC NE GC_E.
    "출고 취소
    PERFORM CANCEL_PGI_STEP    USING LS_LIKP-VBELN
                            CHANGING PS_0100.
    IF PS_0100-RSLT_PROC NE GC_E.
      PV_STATUS         = LV_STAT.
    ENDIF.
  ENDIF.

*  IF PS_0100-RSLT_PROC NE GC_E.
*    IF LV_STATUS EQ PV_STATUS.
*      IF LS_LIKP-WBSTK EQ GC_C.
*        LV_STEP = '03'.  "상태코드/PGI
*      ELSE.
*        LV_STEP = '01'.  "상태 업데이트
*      ENDIF.
*
*    ELSE.
*      IF LV_STATUS EQ LV_STAT. "NEXT 상태
*        IF LS_LIKP-WBSTK EQ GC_C.
*          LV_STEP = '02'.  "PGI
*        ELSE.
*          CLEAR LV_STEP.   "PGI 미완료
*        ENDIF.
*      ELSE.
*        IF LS_LIKP-WBSTK EQ GC_C.
*          LV_STEP = '03'.  "상태코드/PGI
*        ELSE.
*          LV_STEP = '01'. "상태 업데이트
*        ENDIF.
*      ENDIF.
*
*    ENDIF.
*
*    IF LV_STEP EQ '02'OR  "PGI 취소
*       LV_STEP EQ '03'.
*      "출고 취소
*      PERFORM CANCEL_PGI_STEP    USING LS_LIKP-VBELN
*                              CHANGING PS_0100.
*      IF PS_0100-RSLT_PROC NE GC_E.
*        PV_STATUS         = LV_STAT.
*      ENDIF.
*    ENDIF.
*
*  ENDIF.

  "DB 상태코드 UPDATE + OUTPUT LIST 의 상태코드 LED 변경
  PERFORM SET_LED_JS_CANCEL    USING GV_STATUS_ERR
                                     LV_STAT
                                     LV_STEP
                            CHANGING PS_0100.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CANCEL_PGI_STEP
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PS_0100
*&---------------------------------------------------------------------*
FORM CANCEL_PGI_STEP     USING PV_VBELN
                      CHANGING PS_0100 LIKE GT_0100.
  DATA: LV_VBELN TYPE LIKP-VBELN,
        LV_BUDAT TYPE MKPF-BUDAT,
        LV_TCODE TYPE SY-TCODE,
        LV_VBTYP TYPE LIKP-VBTYP.
  DATA: LT_MESG  TYPE TABLE OF MESG,
        LV_MBLNR TYPE MBLNR.
  DATA: LV_MSG(200).

*-LIKP
  SELECT SINGLE *
    FROM LIKP
   WHERE VBELN EQ @PV_VBELN
    INTO @DATA(LS_LIKP).

*-출고취소 : CALL 'ZGTSDR0120_CANCELSEL'
  LV_VBELN = LS_LIKP-VBELN.
  LV_BUDAT = LS_LIKP-WADAT_IST.
  LV_VBTYP = LS_LIKP-VBTYP.
  LV_TCODE = 'VL09'.

  SUBMIT ZGTSDR0120_CANCEL WITH P_VBELN = LV_VBELN
                           WITH P_BUDAT = LV_BUDAT
                           WITH P_TCODE = LV_TCODE
                           WITH P_VBTYP = LV_VBTYP
                           AND RETURN.

  IMPORT LV_MBLNR LT_MESG FROM MEMORY ID 'ZGTSDDOCANC'.
  FREE MEMORY ID 'ZGTSDDOCANC'.

  IF LV_MBLNR IS NOT INITIAL.
    PS_0100-RSLT_PROC = GC_S.

  ELSE.
    PS_0100-RSLT_PROC = GC_E.
    LOOP AT LT_MESG INTO DATA(LS_MESG) WHERE MSGTY CA 'AEX'.
      IF LV_MSG IS INITIAL.
        LV_MSG = LS_MESG-TEXT.
      ELSE.
        LV_MSG = |{ LV_MSG }/{ LS_MESG-TEXT }|.
      ENDIF.
    ENDLOOP.

    PS_0100-MESSAGE = LV_MSG.
  ENDIF.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROCESS_JS_STEP_CANCEL_I
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> <FS_0100>
*&      <-- GV_STATUS_CUR
*&---------------------------------------------------------------------*
FORM PROCESS_JS_STEP_CANCEL_I  USING    PS_0100 LIKE GT_0100
                               CHANGING PV_STATUS.
  DATA: LV_STAT TYPE ZGTSDT9110-ZZJS_STATUS.
  DATA: LV_STEP(2).
  DATA: LV_CHK1(1), "당월 처리 DO 생성
        LV_STEP_M(1),
        LV_CHK2(1), "익월이후 처리 DO 생성
        LV_STEP_JS(1).

  GV_STATUS_ERR = PV_STATUS.

  LV_STAT = GC_H. "가상창고이동

*-현재 상태코드 체크 : ZGTSDT9110-ZZJS_STATUS
  SELECT SINGLE ZZJS_STATUS
    FROM ZGTSDT9110
   WHERE VBELN EQ @PS_0100-VBELN_VL
     AND LOEVM EQ @SPACE
    INTO @DATA(LV_STATUS).
  IF PV_STATUS NE LV_STATUS.
    PS_0100-RSLT_PROC = GC_E.
    PS_0100-MESSAGE   = TEXT-M43.
  ENDIF.
*  IF LV_STATUS EQ GC_I OR
*     LV_STATUS EQ GC_J.
*    LV_STEP = '01'.  "상태 업데이트
*  ELSE.
*    IF LV_STATUS EQ LV_STAT.
*      CLEAR LV_STEP.
*    ELSE.
*      LV_STEP = '01'.  "상태 업데이트
*    ENDIF.
*  ENDIF.

*-ZGTSDT9120
  SELECT *
    FROM ZGTSDT9120
   WHERE VBELN EQ @PS_0100-VBELN_VL
     AND UECHA EQ '000000'
     AND LOEVM EQ @SPACE
    INTO TABLE @DATA(LT_ZGTSDT9120).

*-----------------------------------------------
*-STEP1 : 당월처리(ZLF)
*-----------------------------------------------
  SELECT A~*,B~WBSTK
    INTO TABLE @DATA(LT_LIPS)
    FROM LIPS AS A INNER JOIN LIKP AS B
                   ON A~VBELN = B~VBELN
     FOR ALL ENTRIES IN @LT_ZGTSDT9120
   WHERE A~VGBEL      EQ @LT_ZGTSDT9120-VGBEL
     AND A~ZZVBELN_JS EQ @LT_ZGTSDT9120-VBELN
     AND B~VKORG      EQ @GC_VKORG_6000
     AND B~LFART      EQ @GC_LFART_ZLF.
  IF SY-SUBRC EQ 0.
    DATA(LS_LIPS) = VALUE #( LT_LIPS[ 1 ] OPTIONAL ).
    IF LS_LIPS-WBSTK EQ GC_C.
      PS_0100-RSLT_PROC = GC_E.
      PS_0100-MESSAGE   = |{ TEXT-M29 }({ LS_LIPS-A-VBELN })|.

    ELSE.
*      IF LV_STEP EQ '01'.
*        LV_STEP = '03'.
*      ELSE.
*        LV_STEP = '02'.
*      ENDIF.

      "DO 삭제
      PERFORM OUTB_DELIVERY_DELTE    USING LS_LIPS-A-VBELN
                                  CHANGING PS_0100.
      IF PS_0100-RSLT_PROC NE GC_E.
        LV_STEP_M = GC_X.
      ENDIF.
    ENDIF.

  ELSE.
    LV_STEP_M = GC_X.
  ENDIF.

*-----------------------------------------------
*-STEP2 : 익월처리( ZLF3 )
*-----------------------------------------------
  IF LV_STEP_M = GC_X.
    CLEAR LT_LIPS[].
    SELECT A~*
      INTO TABLE @LT_LIPS
      FROM LIPS AS A INNER JOIN LIKP AS B
                     ON A~VBELN = B~VBELN
       FOR ALL ENTRIES IN @LT_ZGTSDT9120
     WHERE A~VGBEL      EQ @LT_ZGTSDT9120-VGBEL
       AND A~ZZVBELN_JS EQ @LT_ZGTSDT9120-VBELN
       AND B~LIFSK      NE 'G4'                 "적송매출처리에서 분할된 납품
       AND B~VKORG      EQ @GC_VKORG_6000
       AND B~LFART      EQ @GC_LFART_ZLF3.
    IF SY-SUBRC EQ 0.
*      IF LV_STEP EQ '01' OR LV_STEP EQ '03'.
*        LV_STEP = '03'.
*      ELSE.
*        LV_STEP = '02'.
*      ENDIF.

      CLEAR LS_LIPS.
      LS_LIPS = VALUE #( LT_LIPS[ 1 ] OPTIONAL ).
      "DO 삭제
      PERFORM OUTB_DELIVERY_DELTE    USING LS_LIPS-A-VBELN
                                  CHANGING PS_0100.
      IF PS_0100-RSLT_PROC NE GC_E.
        LV_STEP_JS = GC_X.
      ENDIF.

    ELSE.
      LV_STEP_JS = GC_X.
    ENDIF.
  ENDIF.

*-DO 삭제 체크
  IF LV_STEP_M  EQ GC_X AND
     LV_STEP_JS EQ GC_X.
    PV_STATUS  = LV_STAT.
  ENDIF.


  "DB 상태코드 UPDATE + OUTPUT LIST 의 상태코드 LED 변경
  DATA:LV_TEXT(20).
  DATA:LV_FINAL(1).

  SORT GT_CODE BY CODE DESCENDING.

  LOOP AT GT_CODE INTO DATA(LS_CODE) WHERE CODE <= GV_STATUS_ERR
                                       AND CODE > LV_STAT.
    CLEAR:LV_TEXT.

    LV_TEXT = |ST_{ LS_CODE-STATUS }|.
    ASSIGN COMPONENT LV_TEXT OF STRUCTURE PS_0100 TO FIELD-SYMBOL(<FS_VAL>).
    CHECK SY-SUBRC EQ 0.

    IF PS_0100-RSLT_PROC EQ GC_E.
      PS_0100-STAT = ICON_LED_RED.
*      <FS_VAL>     = ICON_LED_RED.

    ELSE.
      CLEAR PS_0100-STAT.
      <FS_VAL> = ICON_LED_YELLOW.

    ENDIF.

    IF <FS_VAL> IS ASSIGNED. UNASSIGN <FS_VAL>.ENDIF.
  ENDLOOP.

  "DB UPDATE
  IF PS_0100-RSLT_PROC NE GC_E.
*    IF LV_STEP EQ '01' OR  "상태만 업데이트
*       LV_STEP EQ '03'.    "상태 + CANCEL

    UPDATE ZGTSDT9110 SET ZZJS_STATUS = PV_STATUS
                    WHERE VBELN EQ PS_0100-VBELN_VL.
    IF SY-SUBRC EQ 0.
      COMMIT WORK AND WAIT.
    ENDIF.
*    ENDIF.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form OUTB_DELIVERY_DELTE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LS_LIPS_VBELN
*&      <-- PS_0100
*&---------------------------------------------------------------------*
FORM OUTB_DELIVERY_DELTE  USING    PV_VBELN
                          CHANGING PS_0100 LIKE GT_0100.

  DATA : LT_RETURN   TYPE TABLE OF BAPIRET2 WITH HEADER LINE,
         LS_HEADER   TYPE BAPIOBDLVHDRCHG,
         LS_CONTROL  TYPE BAPIOBDLVHDRCTRLCHG,
         LV_DELIVERY TYPE BAPIOBDLVHDRCHG-DELIV_NUMB.
  DATA : LV_MSG  TYPE BAPI_MSG.

*-BAPI PARAMETERS
  LS_HEADER-DELIV_NUMB  = PV_VBELN.
  LS_CONTROL-DELIV_NUMB = PV_VBELN.
  LS_CONTROL-DLV_DEL    = GC_X.
  LV_DELIVERY           = PV_VBELN.

  CALL FUNCTION 'RV_DELIVERY_INIT'
    EXPORTING
      IF_NO_DEQUE = GC_X.

  CALL FUNCTION 'BAPI_OUTB_DELIVERY_CHANGE'
    EXPORTING
      HEADER_DATA    = LS_HEADER
      HEADER_CONTROL = LS_CONTROL
      DELIVERY       = LV_DELIVERY
    TABLES
      RETURN         = LT_RETURN[].

  LOOP AT LT_RETURN INTO DATA(LS_RETURN) WHERE TYPE CA 'AE'.
    IF LV_MSG IS INITIAL.
      LV_MSG = LS_RETURN-MESSAGE.
    ELSE.
      LV_MSG = |{ LV_MSG }/{ LS_RETURN-MESSAGE }|.
    ENDIF.
  ENDLOOP.

  IF SY-SUBRC EQ 0.
    __BAPI_TRANSACTION_ROLLBACK.

    PS_0100-RSLT_PROC = GC_E.
    PS_0100-MESSAGE   = LV_MSG.

  ELSE.
    __BAPI_TRANSACTION_COMMIT.

    PS_0100-RSLT_PROC = GC_S.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROCESS_JS_STEP_CANCEL_H
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> <FS_0100>
*&      <-- GV_STATUS_CUR
*&---------------------------------------------------------------------*
FORM PROCESS_JS_STEP_CANCEL_H  USING    PS_0100 LIKE GT_0100
                               CHANGING PV_STATUS.
  DATA: LV_STAT TYPE ZGTSDT9110-ZZJS_STATUS.
  DATA: LV_STEP(2).

  LV_STAT = PV_STATUS.

  GV_STATUS_ERR = LV_STAT.

  "현재상태 다음단계 상태코드 가져옴( 현재 처리 상태코드 )
  PERFORM GET_CANCEL_STATUS_CODE_NEXT CHANGING LV_STAT.

*-현재 상태코드 체크 : ZGTSDT9110-ZZJS_STATUS
  SELECT SINGLE ZZJS_STATUS
    FROM ZGTSDT9110
   WHERE VBELN EQ @PS_0100-VBELN_VL
     AND LOEVM EQ @SPACE
    INTO @DATA(LV_STATUS).
  IF PV_STATUS NE LV_STATUS.
    PS_0100-RSLT_PROC = GC_E.
    PS_0100-MESSAGE   = TEXT-M43.
  ENDIF.

*-신규 DO
  SELECT SINGLE A~VBELN
    FROM LIKP AS A INNER JOIN LIPS AS B
                   ON A~VBELN = B~VBELN
   WHERE A~LFART      IN ( @GC_LFART_ZLF,@GC_LFART_ZLF3 )
     AND B~ZZVBELN_JS EQ @PS_0100-VBELN_VL
    INTO @DATA(LS_LIKP).
  IF SY-SUBRC EQ 0.
    PS_0100-RSLT_PROC = GC_E.
    PS_0100-MESSAGE   = TEXT-M38.

  ELSE.
    SELECT A~*
      FROM ZGTSDT9120 AS A INNER JOIN MATDOC AS B
                           ON A~MBLNR_C   = B~MBLNR AND
                              A~MJAHR_C   = B~MJAHR AND
                              B~CANCELLED = @SPACE AND
                              B~SMBLN     = @SPACE
     WHERE A~VBELN   EQ @PS_0100-VBELN_VL
       AND A~LOEVM   EQ @SPACE
       AND A~MBLNR_C NE @SPACE
      INTO TABLE @DATA(LT_ZGTSDT9120).
    IF SY-SUBRC EQ 0.
      PS_0100-RSLT_PROC = GC_E.
      DATA(LS_LINE) = VALUE #( LT_ZGTSDT9120[ 1 ] OPTIONAL ).
      PS_0100-MESSAGE   = |{ TEXT-M46 }({ LS_LINE-MBLNR_C }/{ LS_LINE-MJAHR_C })|.

*      IF LV_STATUS EQ PV_STATUS.
*        CLEAR LV_STEP.  "NO ACTION
*      ELSE.
*        LV_STEP = '01'. "상태 업데이트
*      ENDIF.
    ELSE.
      "자재이동
      PERFORM GOODS_MOVEMENT_CREATE CHANGING PS_0100.
      IF PS_0100-RSLT_PROC NE GC_E.
        PV_STATUS         = LV_STAT.
      ENDIF.

*      IF LV_STATUS EQ LV_STAT. "NEXT 상태
*        LV_STEP = '02'. "자재이동
*      ELSE.
*        LV_STEP = '03'. "상태 업데이트 + 자재이동
*      ENDIF.

    ENDIF.
  ENDIF.

*  IF LV_STEP EQ '02'OR  "자재이동
*     LV_STEP EQ '03'.
*
*    PERFORM GOODS_MOVEMENT_CREATE CHANGING PS_0100.
*    IF PS_0100-RSLT_PROC NE GC_E.
*      PV_STATUS         = LV_STAT.
*    ENDIF.
*
*  ENDIF.

  "DB 상태코드 UPDATE + OUTPUT LIST 의 상태코드 LED 변경
  PERFORM SET_LED_JS_CANCEL    USING GV_STATUS_ERR
                                     LV_STAT
                                     LV_STEP
                            CHANGING PS_0100.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GOODS_MOVEMENT_CREATE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- PS_0100
*&---------------------------------------------------------------------*
FORM GOODS_MOVEMENT_CREATE  CHANGING PS_0100 LIKE GT_0100.
  DATA: LT_ZGTSDT9110 TYPE TABLE OF ZGTSDT9110,
        LT_ZGTSDT9120 TYPE TABLE OF ZGTSDT9120.
  DATA: LV_MSG(200).

  CLEAR:GS_GOODSMVT_HEADER,GS_GOODSMVT_CODE,GS_GOODSMVT_HEADRET,
        GT_GOODSMVT_ITEM[],GT_RETURN[].
  CLEAR:LV_MSG.

*-ZGTSDT9110
  SELECT *
    FROM ZGTSDT9110
   WHERE VBELN EQ @PS_0100-VBELN_VL
     AND LOEVM EQ @SPACE
    INTO TABLE @LT_ZGTSDT9110.

*-ZGTSDT9120
  SELECT *
    FROM ZGTSDT9120
   WHERE VBELN EQ @PS_0100-VBELN_VL
     AND LOEVM EQ @SPACE
    INTO TABLE @LT_ZGTSDT9120.
  SORT LT_ZGTSDT9120 BY VBELN POSNR.

  DATA(LT_BASE) = LT_ZGTSDT9120[].
  DELETE LT_BASE WHERE UECHA NE '000000'.

*-BAPI PARAMETERS

  "HEADER
  GS_GOODSMVT_HEADER-PSTNG_DATE = VALUE #( LT_ZGTSDT9110[ 1 ]-WADAT_IST OPTIONAL ).
  GS_GOODSMVT_HEADER-DOC_DATE   = SY-DATLO.

  GS_GOODSMVT_CODE-GM_CODE      = GC_CODE_04.

  "ITEM
  LOOP AT LT_BASE INTO DATA(LS_BASE).
    IF LINE_EXISTS( LT_ZGTSDT9120[ VBELN = LS_BASE-VBELN UECHA = LS_BASE-POSNR ] ).
      PERFORM BUILD_BAPI_ITEMS  TABLES LT_ZGTSDT9120
                                 USING LS_BASE GC_A.
    ELSE.
      PERFORM BUILD_BAPI_ITEMS  TABLES LT_ZGTSDT9120
                                USING LS_BASE GC_B.
    ENDIF.
  ENDLOOP.

  "BAPI
  CALL FUNCTION 'BAPI_GOODSMVT_CREATE'
    EXPORTING
      GOODSMVT_HEADER  = GS_GOODSMVT_HEADER
      GOODSMVT_CODE    = GS_GOODSMVT_CODE
    IMPORTING
      GOODSMVT_HEADRET = GS_GOODSMVT_HEADRET
    TABLES
      GOODSMVT_ITEM    = GT_GOODSMVT_ITEM
      RETURN           = GT_RETURN.
  IF GS_GOODSMVT_HEADRET-MAT_DOC IS NOT INITIAL.
    LOOP AT LT_ZGTSDT9120 INTO DATA(LS_ITEM).
      "UPDATE ZGTSDT9120
      UPDATE ZGTSDT9120 SET ZZJS_MVT = SPACE
                            MBLNR    = SPACE
                            MJAHR    = '0000'
                            MBLNR_C  = GS_GOODSMVT_HEADRET-MAT_DOC
                            MJAHR_C  = GS_GOODSMVT_HEADRET-DOC_YEAR
                      WHERE ( VBELN EQ LS_ITEM-VBELN AND
                              POSNR EQ LS_ITEM-POSNR     )
                         OR ( VBELN EQ LS_ITEM-VBELN AND
                              UECHA EQ LS_ITEM-POSNR     ).

    ENDLOOP.

    __BAPI_TRANSACTION_COMMIT.

    PS_0100-RSLT_PROC = GC_S.

  ELSE.
    __BAPI_TRANSACTION_ROLLBACK.
    LOOP AT GT_RETURN INTO DATA(LS_RETURN) WHERE TYPE CA 'AE'.
      IF LV_MSG IS INITIAL.
        LV_MSG = LS_RETURN-MESSAGE.
      ELSE.
        LV_MSG = |{ LV_MSG }/{ LS_RETURN-MESSAGE }|.
      ENDIF.
    ENDLOOP.

    PS_0100-RSLT_PROC = GC_E.
    PS_0100-MESSAGE   = LV_MSG.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form BUILD_BAPI_ITEMS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LS_BASE
*&      --> GC_A
*&---------------------------------------------------------------------*
FORM BUILD_BAPI_ITEMS   TABLES PT_ZGTSDT9120 STRUCTURE ZGTSDT9120
                         USING PS_DATA TYPE ZGTSDT9120
                               PV_STEP.

  CASE PV_STEP.
    WHEN GC_A.  "BATCH SPLIT
      LOOP AT PT_ZGTSDT9120 INTO DATA(LS_ITEM) WHERE VBELN = PS_DATA-VBELN
                                                 AND UECHA = PS_DATA-POSNR.
        CLEAR:GS_GOODSMVT_ITEM.
        GS_GOODSMVT_ITEM-MATERIAL_LONG = LS_ITEM-MATNR.
        GS_GOODSMVT_ITEM-PLANT         = LS_ITEM-WERKS.
        GS_GOODSMVT_ITEM-STGE_LOC      = GC_LGORT_3499.
        GS_GOODSMVT_ITEM-BATCH         = LS_ITEM-CHARG.
        GS_GOODSMVT_ITEM-MOVE_TYPE     = GC_BWART_311.
        GS_GOODSMVT_ITEM-SPEC_STOCK    = GC_E.
        GS_GOODSMVT_ITEM-SALES_ORD     = LS_ITEM-VGBEL.
        GS_GOODSMVT_ITEM-S_ORD_ITEM    = LS_ITEM-VGPOS.
        GS_GOODSMVT_ITEM-ENTRY_QNT     = LS_ITEM-LFIMG.
        GS_GOODSMVT_ITEM-ENTRY_UOM     = LS_ITEM-VRKME.

        GS_GOODSMVT_ITEM-MOVE_MAT_LONG = LS_ITEM-MATNR.
        GS_GOODSMVT_ITEM-MOVE_PLANT    = LS_ITEM-WERKS.
        GS_GOODSMVT_ITEM-MOVE_STLOC    = LS_ITEM-LGORT.
        GS_GOODSMVT_ITEM-MOVE_BATCH    = LS_ITEM-CHARG.

        GS_GOODSMVT_ITEM-VAL_SALES_ORD  = LS_ITEM-VGBEL.
        GS_GOODSMVT_ITEM-VAL_S_ORD_ITEM = LS_ITEM-VGPOS.

        GS_GOODSMVT_ITEM-DELIV_NUMB     = LS_ITEM-VBELN.
        GS_GOODSMVT_ITEM-DELIV_ITEM     = LS_ITEM-UECHA.

        GS_GOODSMVT_ITEM-ITEM_TEXT      = TEXT-005.

        APPEND GS_GOODSMVT_ITEM TO GT_GOODSMVT_ITEM.
      ENDLOOP.

    WHEN GC_B.
      LOOP AT PT_ZGTSDT9120 INTO LS_ITEM WHERE VBELN = PS_DATA-VBELN
                                           AND POSNR = PS_DATA-POSNR.
        CLEAR:GS_GOODSMVT_ITEM.
        GS_GOODSMVT_ITEM-MATERIAL_LONG = LS_ITEM-MATNR.
        GS_GOODSMVT_ITEM-PLANT         = LS_ITEM-WERKS.
        GS_GOODSMVT_ITEM-STGE_LOC      = GC_LGORT_3499.
        GS_GOODSMVT_ITEM-BATCH         = LS_ITEM-CHARG.
        GS_GOODSMVT_ITEM-MOVE_TYPE     = GC_BWART_311.
        GS_GOODSMVT_ITEM-SPEC_STOCK    = GC_E.
        GS_GOODSMVT_ITEM-SALES_ORD     = LS_ITEM-VGBEL.
        GS_GOODSMVT_ITEM-S_ORD_ITEM    = LS_ITEM-VGPOS.
        GS_GOODSMVT_ITEM-ENTRY_QNT     = LS_ITEM-LFIMG.
        GS_GOODSMVT_ITEM-ENTRY_UOM     = LS_ITEM-VRKME.

        GS_GOODSMVT_ITEM-MOVE_MAT_LONG = LS_ITEM-MATNR.
        GS_GOODSMVT_ITEM-MOVE_PLANT    = LS_ITEM-WERKS.
        GS_GOODSMVT_ITEM-MOVE_STLOC    = LS_ITEM-LGORT.
        GS_GOODSMVT_ITEM-MOVE_BATCH    = LS_ITEM-CHARG.

        GS_GOODSMVT_ITEM-VAL_SALES_ORD  = LS_ITEM-VGBEL.
        GS_GOODSMVT_ITEM-VAL_S_ORD_ITEM = LS_ITEM-VGPOS.

        GS_GOODSMVT_ITEM-DELIV_NUMB     = LS_ITEM-VBELN.
        GS_GOODSMVT_ITEM-DELIV_ITEM     = LS_ITEM-POSNR.

        GS_GOODSMVT_ITEM-ITEM_TEXT      = TEXT-005.

        APPEND GS_GOODSMVT_ITEM TO GT_GOODSMVT_ITEM.
      ENDLOOP.

  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROCESS_JS_STEP_CANCEL_G
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> <FS_0100>
*&      <-- GV_STATUS_CUR
*&---------------------------------------------------------------------*
FORM PROCESS_JS_STEP_CANCEL_G  USING    PS_0100 LIKE GT_0100
                               CHANGING PV_STATUS.
  DATA: LV_STAT TYPE ZGTSDT9110-ZZJS_STATUS.
  DATA: LV_STEP(2).

  LV_STAT = PV_STATUS.

  GV_STATUS_ERR = LV_STAT.

  "현재상태 다음단계 상태코드 가져옴( 현재 처리 상태코드 )
  PERFORM GET_CANCEL_STATUS_CODE_NEXT CHANGING LV_STAT.

*-현재 상태코드 체크 : ZGTSDT9110-ZZJS_STATUS
  SELECT SINGLE ZZJS_STATUS
    FROM ZGTSDT9110
   WHERE VBELN EQ @PS_0100-VBELN_VL
     AND LOEVM EQ @SPACE
    INTO @DATA(LV_STATUS).
  IF PV_STATUS NE LV_STATUS.
    PS_0100-RSLT_PROC = GC_E.
    PS_0100-MESSAGE   = TEXT-M43.
  ENDIF.

*-자재이동
  SELECT *
    FROM ZGTSDT9120
   WHERE VBELN   EQ @PS_0100-VBELN_VL
     AND LOEVM   EQ @SPACE
     AND MBLNR_C NE @SPACE
    INTO TABLE @DATA(LT_ZGTSDT9120).
  IF SY-SUBRC NE 0.
    PS_0100-RSLT_PROC = GC_E.
    PS_0100-MESSAGE   = TEXT-M40.
  ENDIF.

  IF PS_0100-RSLT_PROC NE GC_E.
*-  원 DO 출고 상태
    SELECT SINGLE *
      FROM LIKP
     WHERE VBELN EQ @PS_0100-VBELN_VL
      INTO @DATA(LS_LIKP).
    IF LS_LIKP-WBSTK EQ GC_C. "서비스 출고
      "출고 취소
      PERFORM CANCEL_PGI_SERVICE_STEP  CHANGING PS_0100.
      IF PS_0100-RSLT_PROC NE GC_E.
        PV_STATUS         = LV_STAT.
      ENDIF.
*      IF LV_STATUS EQ PV_STATUS.
*        LV_STEP = '03'.  "상태+출고취소
*      ELSE.
*        IF LV_STATUS EQ LV_STAT.
*          LV_STEP = '02'.  "출고취소
*        ELSE.
*          LV_STEP = '01'.  "상태
*        ENDIF.
*
*      ENDIF.

    ELSE.
      PS_0100-RSLT_PROC = GC_E.
      PS_0100-MESSAGE   = TEXT-M47.
*      IF LV_STATUS EQ PV_STATUS.
*        LV_STEP = '01'.  "상태
*      ELSE.
*        IF LV_STATUS EQ LV_STAT.
*          CLEAR LV_STEP.
*        ELSE.
*          LV_STEP = '01'.  "상태
*        ENDIF.
*      ENDIF.
    ENDIF.

*    IF LV_STEP EQ '02' OR
*       LV_STEP EQ '03'.
*      "출고 취소
*      PERFORM CANCEL_PGI_SERVICE_STEP  CHANGING PS_0100.
*      IF PS_0100-RSLT_PROC NE GC_E.
*        PV_STATUS         = LV_STAT.
*      ENDIF.
*    ENDIF.

  ENDIF.


  "DB 상태코드 UPDATE + OUTPUT LIST 의 상태코드 LED 변경
  PERFORM SET_LED_JS_CANCEL    USING GV_STATUS_ERR
                                     LV_STAT
                                     LV_STEP
                            CHANGING PS_0100.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CANCEL_PGI_SERVICE_STEP
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- PS_0100
*&---------------------------------------------------------------------*
FORM CANCEL_PGI_SERVICE_STEP  CHANGING PS_0100 LIKE GT_0100.
  DATA: LV_VBELN TYPE LIKP-VBELN,
        LV_BUDAT TYPE MKPF-BUDAT,
        LV_TCODE TYPE SY-TCODE,
        LV_VBTYP TYPE LIKP-VBTYP.
  DATA: LT_MESG  TYPE TABLE OF MESG.
  DATA: LV_MSG(200).

*-LIKP
  SELECT SINGLE *
    FROM LIKP
   WHERE VBELN EQ @PS_0100-VBELN_VL
    INTO @DATA(LS_LIKP).

*-서비스 출고취소 : CALL 'ZGTSDR2010_CANCEL'
  LV_VBELN = LS_LIKP-VBELN.
  LV_BUDAT = LS_LIKP-WADAT_IST.
  LV_VBTYP = LS_LIKP-VBTYP.
  LV_TCODE = 'VL09'.

  SUBMIT ZGTSDR2010_CANCEL WITH P_VBELN = LV_VBELN
                           WITH P_BUDAT = LV_BUDAT
                           WITH P_TCODE = LV_TCODE
                           WITH P_VBTYP = LV_VBTYP
                           AND RETURN.

  IMPORT LT_MESG FROM MEMORY ID 'ZGTSDDOCCANC_SERVICE'.

  LOOP AT LT_MESG INTO DATA(LS_MESG) WHERE MSGTY CA 'AE'.
    IF LV_MSG IS INITIAL.
      LV_MSG = LS_MESG-TEXT.
    ELSE.
      LV_MSG = |{ LV_MSG }/{ LS_MESG-TEXT }|.
    ENDIF.
  ENDLOOP.
  IF SY-SUBRC EQ 0.
    PS_0100-RSLT_PROC = GC_E.
    PS_0100-MESSAGE   = LV_MSG.
  ELSE.
    PS_0100-RSLT_PROC = GC_S.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROCESS_JS_STEP_CANCEL_E
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> <FS_0100>
*&      <-- GV_STATUS_CUR
*&---------------------------------------------------------------------*
FORM PROCESS_JS_STEP_CANCEL_E  USING    PS_0100 LIKE GT_0100
                               CHANGING PV_STATUS.
  DATA: LV_STAT TYPE ZGTSDT9110-ZZJS_STATUS.
  DATA: LV_STEP(2).
  DATA: LT_DATA TYPE TABLE OF ZGTSDS0034,
        LV_TYPE TYPE BAPI_MTYPE,
        LV_MSG  TYPE BAPI_MSG.

  GV_STATUS_ERR = PV_STATUS.

  LV_STAT = GC_D.

*-현재 상태코드 체크 : ZGTSDT9110-ZZJS_STATUS
  SELECT SINGLE ZZJS_STATUS
    FROM ZGTSDT9110
   WHERE VBELN EQ @PS_0100-VBELN_VL
     AND LOEVM EQ @SPACE
    INTO @DATA(LV_STATUS).
  IF PV_STATUS NE LV_STATUS.
    PS_0100-RSLT_PROC = GC_E.
    PS_0100-MESSAGE   = TEXT-M43.
  ENDIF.

  SELECT *
    FROM ZGTSDT9120
   WHERE VBELN EQ @PS_0100-VBELN_VL
     AND LOEVM EQ @SPACE
    INTO TABLE @DATA(LT_ZGTSDT9120).

*-주요속성변경 여부
  SELECT VBELN,POSNR,BWART,FKREL
    FROM LIPS
   WHERE VBELN EQ @PS_0100-VBELN_VL
    INTO TABLE @DATA(LT_LIPS).
  IF SY-SUBRC EQ 0.
    DATA(LS_LIPS) = VALUE #( LT_LIPS[ 1 ] OPTIONAL ).

    IF LS_LIPS-BWART IS NOT INITIAL.
      PS_0100-RSLT_PROC = GC_E.
      PS_0100-MESSAGE   = TEXT-M48.
*      IF LV_STATUS EQ GC_F OR
*         LV_STATUS EQ GC_E.
*        LV_STEP = '01'. "상태
*      ELSE.
*        IF LV_STEP EQ LV_STAT.
*          CLEAR LV_STEP.
*        ELSE.
*          LV_STEP = '01'. "상태
*        ENDIF.
*      ENDIF.

    ELSE.
*      IF LV_STATUS EQ GC_F OR
*         LV_STATUS EQ GC_E.
*        LV_STEP = '03'. "상태+속성변경
*      ELSE.
*        IF LV_STEP EQ LV_STAT.
*          LV_STEP = '02'.
*        ELSE.
*          LV_STEP = '03'. "상태+속성변경
*        ENDIF.
*      ENDIF.
    ENDIF.

  ELSE.
    PS_0100-RSLT_PROC = GC_E.
    PS_0100-MESSAGE   = |{ TEXT-M17 }({ PS_0100-VBELN_VL })|.
  ENDIF.

  IF PS_0100-RSLT_PROC NE GC_E.
*    IF LV_STEP EQ '02' OR
*       LV_STEP EQ '03'.

*-    DO ITEM 속성 변경
    APPEND VALUE #( VBELN = PS_0100-VBELN_VL )
        TO LT_DATA.

    CALL FUNCTION 'ZGTSD_JS_RESTORE_ATTRIBUTE_DO'
      IMPORTING
        E_TYPE  = LV_TYPE
        E_MSG   = LV_MSG
      TABLES
        IT_DATA = LT_DATA.

    IF LV_TYPE EQ GC_S.
      DATA(LS_DATA) = VALUE #( LT_DATA[ 1 ] OPTIONAL ).
      IF LS_DATA-MTYPE EQ GC_S.
        PS_0100-RSLT_PROC = GC_S.
        PV_STATUS         = LV_STAT.

      ELSE.
        PS_0100-RSLT_PROC = GC_E.
        PS_0100-MESSAGE   = LS_DATA-MSG.
      ENDIF.

    ELSE.
      PS_0100-RSLT_PROC = GC_E.
      PS_0100-MESSAGE   = LV_MSG.
    ENDIF.

*    ENDIF.
  ENDIF.

  "DB 상태코드 UPDATE + OUTPUT LIST 의 상태코드 LED 변경
  DATA:LV_TEXT(20).
  DATA:LV_FINAL(1).

  SORT GT_CODE BY CODE DESCENDING.

  LOOP AT GT_CODE INTO DATA(LS_CODE) WHERE CODE <= GV_STATUS_ERR
                                       AND CODE > LV_STAT.
    CLEAR:LV_TEXT.

    LV_TEXT = |ST_{ LS_CODE-STATUS }|.
    ASSIGN COMPONENT LV_TEXT OF STRUCTURE PS_0100 TO FIELD-SYMBOL(<FS_VAL>).
    CHECK SY-SUBRC EQ 0.

    IF PS_0100-RSLT_PROC EQ GC_E.
      PS_0100-STAT = ICON_LED_RED.

    ELSE.
      CLEAR PS_0100-STAT.
      <FS_VAL> = ICON_LED_YELLOW.

    ENDIF.

    IF <FS_VAL> IS ASSIGNED. UNASSIGN <FS_VAL>.ENDIF.
  ENDLOOP.

  "DB UPDATE
  IF PS_0100-RSLT_PROC NE GC_E.
*    IF LV_STEP EQ '01' OR  "상태만 업데이트
*       LV_STEP EQ '03'.    "상태 + CANCEL

    UPDATE ZGTSDT9110 SET ZZJS_STATUS = PV_STATUS
                    WHERE VBELN EQ PS_0100-VBELN_VL.
    IF SY-SUBRC EQ 0.
      COMMIT WORK AND WAIT.
    ENDIF.
*    ENDIF.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROCESS_JS_STEP_CANCEL_D
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> <FS_0100>
*&      <-- GV_STATUS_CUR
*&---------------------------------------------------------------------*
FORM PROCESS_JS_STEP_CANCEL_D  USING    PS_0100 LIKE GT_0100
                               CHANGING PV_STATUS.
  DATA: LV_STAT TYPE ZGTSDT9110-ZZJS_STATUS.
  DATA: LV_STEP(2),
        LV_TYPE    TYPE BAPI_MTYPE,
        LV_MSG     TYPE BAPI_MSG.

  LV_STAT = PV_STATUS.

  GV_STATUS_ERR = LV_STAT.

  "현재상태 다음단계 상태코드 가져옴( 현재 처리 상태코드 )
  PERFORM GET_CANCEL_STATUS_CODE_NEXT CHANGING LV_STAT.

*-현재 상태코드 체크 : ZGTSDT9110-ZZJS_STATUS
  SELECT SINGLE ZZJS_STATUS
    FROM ZGTSDT9110
   WHERE VBELN EQ @PS_0100-VBELN_VL
     AND LOEVM EQ @SPACE
    INTO @DATA(LV_STATUS).
  IF PV_STATUS NE LV_STATUS.
    PS_0100-RSLT_PROC = GC_E.
    PS_0100-MESSAGE   = TEXT-M43.
  ENDIF.

*-LIPS
  SELECT *
    FROM LIPS
   WHERE VBELN EQ @PS_0100-VBELN_VL
    INTO TABLE @DATA(LT_LIPS).
  IF SY-SUBRC EQ 0.
    "속성 원복 체크
    IF LINE_EXISTS( LT_LIPS[ BWART = '' ] ).
      PS_0100-RSLT_PROC = GC_E.
      PS_0100-MESSAGE   = TEXT-M34.
    ELSE.
      "배치지정 체크
      LOOP AT LT_LIPS INTO DATA(LS_LIPS) WHERE UECHA NE '000000'.
        EXIT.
      ENDLOOP.
      IF SY-SUBRC EQ 0.
        PS_0100-RSLT_PROC = GC_E.
        PS_0100-MESSAGE   = TEXT-M49.
*        IF LV_STATUS EQ PV_STATUS.
*          LV_STEP = '01'.  "상태
*        ELSE.
*          IF LV_STATUS EQ LV_STAT.
*            CLEAR LV_STEP.
*          ELSE.
*            LV_STEP = '01'.  "상태
*          ENDIF.
*
*        ENDIF.

      ELSE.
*        IF LV_STATUS EQ PV_STATUS.
*          LV_STEP = '03'.  "상태 + 배치지정
*        ELSE.
*          IF LV_STATUS EQ LV_STAT.
*            LV_STEP = '02'. "배치지정
*          ELSE.
*            LV_STEP = '03'.  "상태 + 배치지정
*          ENDIF.
*
*        ENDIF.
      ENDIF.
    ENDIF.

    IF PS_0100-RSLT_PROC NE GC_E.
*    IF LV_STEP EQ '02' OR
*       LV_STEP EQ '03'.

*      DO BATCH SPLIT
*      PERFORM JS_DO_RE_BATCH_SPLIT    USING PS_0100
*                                   CHANGING LV_TYPE LV_MSG.
*      IF LV_TYPE EQ GC_S.
*        PV_STATUS  = LV_STAT.
*
*      ELSE.
*        PS_0100-RSLT_PROC = GC_E.
*        PS_0100-MESSAGE   = LV_MSG.
*      ENDIF.
      DATA:LT_DATA TYPE TABLE OF ZGTSDS0036.
      APPEND VALUE #( VBELN = PS_0100-VBELN_VL )
          TO LT_DATA.

      CALL FUNCTION 'ZGTSD_JS_RESTORE_BATCH_LINE'
        IMPORTING
          E_TYPE  = LV_TYPE
          E_MSG   = LV_MSG
        TABLES
          IT_DATA = LT_DATA.

      IF LV_TYPE EQ GC_S.
        DATA(LS_DATA) = VALUE #( LT_DATA[ 1 ] OPTIONAL ).
        IF LS_DATA-MTYPE EQ GC_S.
          PS_0100-RSLT_PROC = GC_S.
          PV_STATUS         = LV_STAT.

        ELSE.
          PS_0100-RSLT_PROC = GC_E.
          PS_0100-MESSAGE   = LS_DATA-MSG.
        ENDIF.

      ELSE.
        PS_0100-RSLT_PROC = GC_E.
        PS_0100-MESSAGE   = LV_MSG.
      ENDIF.

*    ENDIF.
    ENDIF.

  ELSE.
    PS_0100-RSLT_PROC = GC_E.
    PS_0100-MESSAGE   = TEXT-M17.
  ENDIF.

  "DB 상태코드 UPDATE + OUTPUT LIST 의 상태코드 LED 변경
  PERFORM SET_LED_JS_CANCEL    USING GV_STATUS_ERR
                                     LV_STAT
                                     LV_STEP
                            CHANGING PS_0100.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form JS_DO_RE_BATCH_SPLIT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PS_0100
*&      <-- LV_TYPE
*&      <-- LV_MSG
*&---------------------------------------------------------------------*
FORM JS_DO_RE_BATCH_SPLIT   USING PS_0100 LIKE GT_0100
                         CHANGING PV_TYPE
                                  PV_MSG.
  DATA: LV_TYPE TYPE BAPI_MTYPE,
        LV_MSG  TYPE BAPI_MSG.

  DATA: LT_ITEM  TYPE TABLE OF ZGTSDS0023,
        LS_ITEM  TYPE ZGTSDS0023,
        LT_BATCH TYPE TABLE OF ZGTSDS0024,
        LS_BATCH TYPE ZGTSDS0024.
  DATA: LV_POSNR TYPE POSNR_VL.
  DATA: LV_LENGTH_VRKME TYPE LFIMG,
        LV_LFIMG        TYPE LFIMG.

*-ZGTSDT9120
  SELECT *
    FROM ZGTSDT9120
   WHERE VBELN EQ @PS_0100-VBELN_VL
    INTO TABLE @DATA(LT_ZGTSDT9120).
  SORT LT_ZGTSDT9120 BY VBELN POSNR.

*-LIPS
  SELECT *
    FROM LIPS
   WHERE VBELN EQ @PS_0100-VBELN_VL
    INTO TABLE @DATA(LT_LIPS).
  SORT LT_LIPS BY VBELN POSNR.

  LOOP AT LT_LIPS INTO DATA(LS_LIPS).
    "ITEM
    CLEAR:LS_ITEM.
    LS_ITEM-VBELN = LS_LIPS-VBELN.
    LS_ITEM-POSNR = LS_LIPS-POSNR.
    LS_ITEM-MATNR = LS_LIPS-MATNR.
    LS_ITEM-WERKS = LS_LIPS-WERKS.
    LS_ITEM-CHARG = LS_LIPS-CHARG.
    LS_ITEM-LFIMG = LS_LIPS-LFIMG.
    LS_ITEM-VRKME = LS_LIPS-VRKME.
    LS_ITEM-UPDKZ = GC_U.

    "BATCH
    LOOP AT LT_ZGTSDT9120 INTO DATA(LS_LINE) WHERE VBELN = LS_LIPS-VBELN
                                               AND UECHA = LS_LIPS-POSNR.

      CLEAR LS_BATCH.
      LS_BATCH-VBELN = LS_LIPS-VBELN.
      LS_BATCH-UECHA = LS_LIPS-POSNR.
      LS_BATCH-POSNR = LS_LINE-POSNR.
      LS_BATCH-MATNR = LS_LIPS-MATNR.
      LS_BATCH-WERKS = LS_LIPS-WERKS.
      LS_BATCH-LGORT = LS_LINE-LGORT.
      LS_BATCH-CHARG = LS_LINE-CHARG.

      LS_BATCH-LFIMG = LS_LINE-LFIMG.
      LS_BATCH-UPDKZ = GC_I.

      "ITEM 수량에서 BATCH 수량 차감
      LS_ITEM-LFIMG = LS_ITEM-LFIMG - LS_LINE-LFIMG.

      APPEND LS_BATCH TO LT_BATCH.
    ENDLOOP.

    APPEND LS_ITEM TO LT_ITEM.

  ENDLOOP.

*-BATCH SPLIT 수행
  CALL FUNCTION 'ZGTSD_DO_BATCH_SPLIT'
    IMPORTING
      E_TYPE   = LV_TYPE
      E_MSG    = LV_MSG
    TABLES
      IT_ITEM  = LT_ITEM
      IT_BATCH = LT_BATCH.

  PV_TYPE = LV_TYPE.
  PV_MSG  = LV_MSG.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROCESS_JS_STEP_CANCEL_C
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> <FS_0100>
*&      <-- GV_STATUS_CUR
*&---------------------------------------------------------------------*
FORM PROCESS_JS_STEP_CANCEL_C  USING    PS_0100 LIKE GT_0100
                               CHANGING PV_STATUS.
  DATA: LV_STAT TYPE ZGTSDT9110-ZZJS_STATUS.
  DATA: LV_STEP(2),
        LV_TYPE    TYPE BAPI_MTYPE,
        LV_MSG     TYPE BAPI_MSG.
  DATA: LT_DATA TYPE TABLE OF ZGTSDS0022.

  LV_STAT = PV_STATUS.

  GV_STATUS_ERR = LV_STAT.

  "현재상태 다음단계 상태코드 가져옴( 현재 처리 상태코드 )
  PERFORM GET_CANCEL_STATUS_CODE_NEXT CHANGING LV_STAT.

*-현재 상태코드 체크 : ZGTSDT9110-ZZJS_STATUS
  SELECT SINGLE ZZJS_STATUS
    FROM ZGTSDT9110
   WHERE VBELN EQ @PS_0100-VBELN_VL
     AND LOEVM EQ @SPACE
    INTO @DATA(LV_STATUS).
  IF PV_STATUS NE LV_STATUS.
    PS_0100-RSLT_PROC = GC_E.
    PS_0100-MESSAGE   = TEXT-M43.
  ENDIF.

*-LIPS : 배치지정
  SELECT SINGLE VBELN
    FROM LIPS
   WHERE VBELN EQ @PS_0100-VBELN_VL
     AND UECHA NE '000000'
    INTO @DATA(LV_VBELN).
  IF SY-SUBRC NE 0.
    PS_0100-RSLT_PROC = GC_E.
    PS_0100-MESSAGE   = TEXT-M28.

  ELSE.
*   납품보류 상태
    SELECT SINGLE LIFSK
      FROM LIKP
     WHERE VBELN EQ @PS_0100-VBELN_VL
      INTO @DATA(LV_LIFSK).
    IF LV_LIFSK IS NOT INITIAL.
*      IF LV_STATUS EQ PV_STATUS.
*        LV_STEP = '03'.  "상태 + 납품보류 해제
*      ELSE.
*        IF LV_STATUS EQ LV_STAT.
*          LV_STEP = '02'.
*        ELSE.
*          LV_STEP = '03'.  "상태 + 납품보류 해제
*        ENDIF.
*
*      ENDIF.
    ELSE.
      PS_0100-RSLT_PROC = GC_E.
      PS_0100-MESSAGE   = TEXT-M50.
*      IF LV_STATUS EQ PV_STATUS.
*        LV_STEP = '01'.  "상태
*      ELSE.
*        IF LV_STATUS EQ LV_STAT.
*          CLEAR LV_STEP.
*        ELSE.
*          LV_STEP = '01'.  "상태
*        ENDIF.
*
*      ENDIF.
    ENDIF.

    IF PS_0100-RSLT_PROC NE GC_E.
*    IF LV_STEP EQ '02' OR
*       LV_STEP EQ '03'.
*     납품보류 해제
      APPEND VALUE #( VBELN = PS_0100-VBELN_VL
                      ZFLAG = ''
                      LIFSK = ''               )
          TO LT_DATA.

      CALL FUNCTION 'ZGTSD_JS_SET_HEADER_DO_BLOCK'
        IMPORTING
          E_TYPE  = LV_TYPE
          E_MSG   = LV_MSG
        TABLES
          IT_DATA = LT_DATA.
      IF LV_TYPE EQ GC_S.
        DATA(LS_DATA) = VALUE #( LT_DATA[ 1 ] OPTIONAL ).
        IF LS_DATA-MTYPE EQ GC_S.
          PS_0100-RSLT_PROC = GC_S.
          PV_STATUS         = LV_STAT.

        ELSE.
          PS_0100-RSLT_PROC = GC_E.
          PS_0100-MESSAGE   = LS_DATA-MSG.
        ENDIF.

      ELSE.
        PS_0100-RSLT_PROC = GC_E.
        PS_0100-MESSAGE   = LV_MSG.
      ENDIF.

*    ENDIF.
    ENDIF.

  ENDIF.


  "DB 상태코드 UPDATE + OUTPUT LIST 의 상태코드 LED 변경
  PERFORM SET_LED_JS_CANCEL    USING GV_STATUS_ERR
                                     LV_STAT
                                     LV_STEP
                            CHANGING PS_0100.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROCESS_JS_STEP_CANCEL_B
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> <FS_0100>
*&      <-- GV_STATUS_CUR
*&---------------------------------------------------------------------*
FORM PROCESS_JS_STEP_CANCEL_B    USING PS_0100 LIKE GT_0100
                              CHANGING PV_STATUS.
  DATA: LV_STAT    TYPE ZGTSDT9110-ZZJS_STATUS,
        LV_STEP(2),
        LV_TYPE    TYPE BAPI_MTYPE,
        LV_MSG     TYPE BAPI_MSG.

  LV_STAT = PV_STATUS.

  GV_STATUS_ERR = LV_STAT.

  "현재상태 다음단계 상태코드 가져옴( 현재 처리 상태코드 )
  PERFORM GET_CANCEL_STATUS_CODE_NEXT CHANGING LV_STAT.

*-현재 상태코드 체크 : ZGTSDT9110-ZZJS_STATUS
  SELECT SINGLE ZZJS_STATUS
    FROM ZGTSDT9110
   WHERE VBELN EQ @PS_0100-VBELN_VL
     AND LOEVM EQ @SPACE
    INTO @DATA(LV_STATUS).
  IF PV_STATUS NE LV_STATUS.
    PS_0100-RSLT_PROC = GC_E.
    PS_0100-MESSAGE   = TEXT-M43.
  ENDIF.

*-LIKP
  SELECT SINGLE *
    FROM LIKP
   WHERE VBELN EQ @PS_0100-VBELN_VL
    INTO @DATA(LS_LIKP).
  IF SY-SUBRC NE 0.
    PS_0100-RSLT_PROC = GC_E.
    PS_0100-MESSAGE   = TEXT-M28.

  ELSE.
    "납품보류 체크
    IF LS_LIKP-LIFSK IS NOT INITIAL.
      PS_0100-RSLT_PROC = GC_E.
      PS_0100-MESSAGE   = TEXT-M41.
    ELSE.
      "PGI
      IF LS_LIKP-WBSTK EQ GC_C.
        PS_0100-RSLT_PROC = GC_E.
        PS_0100-MESSAGE   = TEXT-M51.
*        IF LV_STATUS EQ PV_STATUS.
*          LV_STEP = '01'.  "상태
*        ELSE.
*          IF LV_STATUS EQ LV_STAT.
*            CLEAR LV_STEP.
*          ELSE.
*            LV_STEP = '01'.  "상태
*          ENDIF.
*        ENDIF.

      ELSE.
*        IF LV_STATUS EQ PV_STATUS.
*          LV_STEP = '03'.  "상태 + PGI
*        ELSE.
*          IF LV_STATUS EQ LV_STAT.
*            LV_STEP = '02'. "PGI
*          ELSE.
*            LV_STEP = '03'.  "상태 + PGI
*          ENDIF.
*        ENDIF.
      ENDIF.

      IF PS_0100-RSLT_PROC NE GC_E.
*      IF LV_STEP = '02' OR
*         LV_STEP = '03'.

*       출고처리
        PERFORM JS_DO_PGI_ORIGINAL    USING PS_0100 LS_LIKP
                                   CHANGING LV_TYPE LV_MSG.
        IF LV_TYPE EQ GC_S.
          PS_0100-RSLT_PROC = GC_S.
          PV_STATUS         = LV_STAT.

        ELSE.
          PS_0100-RSLT_PROC = GC_E.
          PS_0100-MESSAGE   = LV_MSG.

        ENDIF.
*      ENDIF.
      ENDIF.

    ENDIF.
  ENDIF.

  "DB 상태코드 UPDATE + OUTPUT LIST 의 상태코드 LED 변경
  PERFORM SET_LED_JS_CANCEL    USING GV_STATUS_ERR
                                     LV_STAT
                                     LV_STEP
                            CHANGING PS_0100.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form JS_DO_PGI_ORIGINAL
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PS_0100
*&      --> LS_LIKP
*&      <-- LV_TYPE
*&      <-- LV_MSG
*&---------------------------------------------------------------------*
FORM JS_DO_PGI_ORIGINAL    USING  PS_0100 LIKE GT_0100
                                  PS_LIKP TYPE LIKP
                         CHANGING PV_TYPE
                                  PV_MSG.
  DATA: LT_DATA TYPE TABLE OF ZGTSDS0032,
        LS_DATA TYPE ZGTSDS0032.
  DATA: LV_TYPE TYPE BAPI_MTYPE,
        LV_MSG  TYPE BAPI_MSG.

*-ZGTSDT9110
  SELECT SINGLE *
    FROM ZGTSDT9110
   WHERE VBELN EQ @PS_0100-VBELN_VL
    INTO @DATA(LS_ZGTSDT9110).


*-DO PGI
  CLEAR LS_DATA.
  LS_DATA-VBELN     = PS_LIKP-VBELN.
  LS_DATA-WADAT_IST = LS_ZGTSDT9110-WADAT_IST.
  APPEND LS_DATA TO LT_DATA.

  CALL FUNCTION 'ZGTSD_JS_GI'
    IMPORTING
      E_TYPE  = LV_TYPE
      E_MSG   = LV_MSG
    TABLES
      IT_DATA = LT_DATA.

  IF LV_TYPE EQ GC_S.
    CLEAR LS_DATA.
    LS_DATA = VALUE #( LT_DATA[ 1 ] OPTIONAL ).
    IF LS_DATA-MTYPE EQ GC_S.
      PV_TYPE = GC_S.

    ELSE.
      PV_TYPE  = GC_E.
      PV_MSG   = LS_DATA-MSG.
    ENDIF.

  ELSE.
    PV_TYPE = LV_TYPE.
    PV_MSG  = LV_MSG.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROCESS_JS_STEP_CANCEL_A
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> <FS_0100>
*&      <-- GV_STATUS_CUR
*&---------------------------------------------------------------------*
FORM PROCESS_JS_STEP_CANCEL_A  USING    PS_0100 LIKE GT_0100
                              CHANGING PV_STATUS.
  DATA: LV_STAT    TYPE ZGTSDT9110-ZZJS_STATUS,
        LV_STEP(2),
        LV_TYPE    TYPE BAPI_MTYPE,
        LV_MSG     TYPE BAPI_MSG.

  LV_STAT = PV_STATUS.

  GV_STATUS_ERR = LV_STAT.

  "현재상태 다음단계 상태코드 가져옴( 현재 처리 상태코드 )
  PERFORM GET_CANCEL_STATUS_CODE_NEXT CHANGING LV_STAT.

*-현재 상태코드 체크 : ZGTSDT9110-ZZJS_STATUS
  SELECT SINGLE VBELN,ZZJS_STATUS,ZZJS_ASN_STS_H,ZZJS_FINAL,LOEVM
    FROM ZGTSDT9110
   WHERE VBELN EQ @PS_0100-VBELN_VL
     AND LOEVM EQ @SPACE
    INTO @DATA(LS_ZGTSDT9110).
  IF SY-SUBRC EQ 0.
    IF PV_STATUS NE LS_ZGTSDT9110-ZZJS_STATUS.
      PS_0100-RSLT_PROC = GC_E.
      PS_0100-MESSAGE   = TEXT-M43.
    ELSE.
      LV_STEP = '00'.
    ENDIF.

  ELSE.
    LV_STEP = '00'.
  ENDIF.


  IF LV_STEP = '00'.
*-LIKP
    SELECT SINGLE *
      FROM LIKP
     WHERE VBELN EQ @PS_0100-VBELN_VL
      INTO @DATA(LS_LIKP).
    IF SY-SUBRC NE 0.
      PS_0100-RSLT_PROC = GC_E.
      PS_0100-MESSAGE   = TEXT-M17.
    ELSE.
      "출고완료 체크
      IF LS_LIKP-WBSTK NE GC_C.
        PS_0100-RSLT_PROC = GC_E.
        PS_0100-MESSAGE   = TEXT-M29.
      ELSE.

*     원천데이터 삭제
        PERFORM DELETE_ORIGINAL_SAVED_DO CHANGING PS_0100.
      ENDIF.
    ENDIF.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form DELETE_ORIGINAL_SAVED_DO
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- PS_0100
*&---------------------------------------------------------------------*
FORM DELETE_ORIGINAL_SAVED_DO  CHANGING PS_0100 LIKE GT_0100.
  DATA: LV_SUBRC TYPE SY-SUBRC,
        LV_H(1),
        LV_I(1).

*-ZGTSDT9110
  SELECT SINGLE VBELN
    FROM ZGTSDT9110
   WHERE VBELN EQ @PS_0100-VBELN_VL
    INTO @DATA(LV_VBELN_H).
  IF SY-SUBRC EQ 0.
    LV_H = GC_X.
  ENDIF.

*-ZGTSDT9120
  SELECT SINGLE VBELN
    FROM ZGTSDT9120
   WHERE VBELN EQ @PS_0100-VBELN_VL
    INTO @DATA(LV_VBELN_I).
  IF SY-SUBRC EQ 0.
    LV_I = GC_X.
  ENDIF.

  LV_SUBRC = 0.

  IF LV_H NE SPACE AND
     LV_I NE SPACE.
    TRY.
        "HEADER
        IF LV_H IS NOT INITIAL.
          DELETE FROM ZGTSDT9110 WHERE VBELN = PS_0100-VBELN_VL.
          IF SY-SUBRC NE 0.
            LV_SUBRC = 4.
          ENDIF.
        ENDIF.

        "ITEM
        IF LV_I IS NOT INITIAL AND LV_SUBRC EQ 0.
          DELETE FROM ZGTSDT9120 WHERE VBELN = PS_0100-VBELN_VL.
          IF SY-SUBRC NE 0.
            LV_SUBRC = 4.
          ENDIF.
        ENDIF.

      CATCH CX_ROOT INTO DATA(LO_REF).
        LV_SUBRC = 4.
    ENDTRY.

    IF LV_SUBRC EQ 0.
      COMMIT WORK AND WAIT.
    ELSE.
      ROLLBACK WORK.
    ENDIF.

  ENDIF.

  IF LV_SUBRC EQ 0.
    PS_0100-RSLT_PROC = GC_S.

    "최초금액/당월금액/적송금액
    CLEAR: PS_0100-NETWR_DW,PS_0100-NETWR_JS.
*    PS_0100-NETWR_JS = PS_0100-NETWR_INI.

    CLEAR:PS_0100-ZZJS_FINAL,PS_0100-ZZJS_ASN_STS_H,PS_0100-ZZJS_STATUS.
    PS_0100-ST_STSH = ICON_LED_RED.
    PS_0100-ST_DBS  = ICON_LED_YELLOW.

  ELSE.
    PS_0100-RSLT_PROC = GC_E.
    PS_0100-MESSAGE   = TEXT-M42.

    PS_0100-STAT = ICON_LED_RED.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_SPLIT_ZLF3
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> <FS_0100>
*&      <-- LV_CHK_ZLF3
*&---------------------------------------------------------------------*
FORM CHECK_SPLIT_ZLF3  USING    PS_0100 LIKE GT_0100
                       CHANGING PV_CHK_ZLF3.

*-ZGTSDT9120
  SELECT *
    FROM ZGTSDT9120
   WHERE VBELN EQ @PS_0100-VBELN_VL
     AND UECHA EQ '000000'
     AND LOEVM EQ @SPACE
    INTO TABLE @DATA(LT_ZGTSDT9120).

*-적송매출에서 처리중인건은 에러
  SELECT A~*,B~WBSTK,B~LIFSK
    INTO TABLE @DATA(LT_LIPS)
    FROM LIPS AS A INNER JOIN LIKP AS B
                   ON A~VBELN = B~VBELN
     FOR ALL ENTRIES IN @LT_ZGTSDT9120
   WHERE A~VGBEL      EQ @LT_ZGTSDT9120-VGBEL
     AND A~ZZVBELN_JS EQ @LT_ZGTSDT9120-VBELN
*     AND B~LIFSK      EQ 'G4'                 "적송매출처리에서 분할된 납품'G4'
     AND B~VKORG      EQ @GC_VKORG_6000
     AND B~LFART      EQ @GC_LFART_ZLF3.

*-G4 존재여부
  IF LINE_EXISTS( LT_LIPS[ LIFSK = 'G4' ] ).
    PV_CHK_ZLF3 = GC_E.
    EXIT.
  ENDIF.

*-ZLF3 출고상태 이상이면 에러
  DELETE LT_LIPS WHERE LIFSK = 'G4'.
  DATA(LS_LINE) = VALUE #( LT_LIPS[ 1 ] OPTIONAL ).
  IF LS_LINE-WBSTK EQ GC_C.
    PV_CHK_ZLF3 = GC_E.
    EXIT.
  ENDIF.
ENDFORM.
