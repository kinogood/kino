*&---------------------------------------------------------------------*
*& Include          ZGTMMR4390F01
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*& FORM INITIALIZATION
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
FORM INITIALIZATION .

  CLEAR : S_YEAR[], S_PERIOD[], S_DATE[]. "YEARLY/MONTHLY/DAILY

  S_YEAR[] = VALUE #( ( SIGN     = GC_I
                                      OPTION = GC_EQ
                                      LOW     = SY-DATLO(4) ) ).

  S_DATE[] = VALUE #( ( SIGN     = GC_I
                                      OPTION = GC_BT
                                      LOW     = SY-DATLO(6) && '01' "당월 1일
                                      HIGH     = SY-DATLO ) ).

  S_PERIOD[] = VALUE #( ( SIGN     = GC_I
                                       OPTION = GC_EQ
                                       LOW     = SY-DATLO(6)  - 1 ) ).

  " 1번 버튼 세팅 (텍스트 및 아이콘)
  SSCRFIELDS-FUNCTXT_01 = VALUE SMP_DYNTXT(
    TEXT      = 'MONTH'
    ICON_ID   =  ICON_CREATE
    ICON_TEXT = '월별환율등록'
  ).

  " 2번 버튼 세팅
  SSCRFIELDS-FUNCTXT_02 = VALUE SMP_DYNTXT(
    TEXT      = 'YEAR'
    ICON_ID   =  ICON_CREATE
    ICON_TEXT = '연별환율등록'
  ).

  ENDFORM.

*&---------------------------------------------------------------------*
*& FORM SELECTION_SCREEN_OUTPUT
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
FORM SELECTION_SCREEN_OUTPUT .

  LOOP AT SCREEN.
    CASE SCREEN-GROUP1.

      WHEN 'YR'.
         SCREEN-ACTIVE = COND #( WHEN P_YEAR = GC_X THEN 1 ELSE 0 ).

      WHEN 'MON'.
          SCREEN-ACTIVE = COND #( WHEN P_MON = GC_X THEN 1 ELSE 0 ).

      WHEN 'DAY'.
          SCREEN-ACTIVE = COND #( WHEN P_DAY = GC_X THEN 1 ELSE 0 ).

      WHEN OTHERS.
    ENDCASE.

    MODIFY SCREEN.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& FORM SELECTION_SCREEN
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
FORM SELECTION_SCREEN.

  CASE SSCRFIELDS-UCOMM."SY-UCOMM.
    WHEN 'FC01'. "월별환율등록_ZGTMMT1130
      PERFORM SET_EXRATE  USING 'M'.

    WHEN 'FC02'. "연별환율등록_ZGTMMT1131
      PERFORM SET_EXRATE USING 'Y'.
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& FORM SET_EXRATE
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
FORM SET_EXRATE  USING PV_GB.

  DATA :
     LV_VIEW TYPE DD02V-TABNAME,
     LV_MSG  TYPE STRING.

*M=월별환율등록_ZGTMMV1130 CALL
*''=연별환율등록_ZGTMMV1131 CALL
  LV_VIEW = COND #( WHEN PV_GB = 'M' THEN 'ZGTMMV1130' ELSE 'ZGTMMV1131' ).

  TRY.

      CALL FUNCTION 'VIEW_MAINTENANCE_CALL'
        EXPORTING
          ACTION                       = 'U'         " 'U'는 수정 모드, 'S'는 조회 모드
          VIEW_NAME                = LV_VIEW " 호출할 유지보수 뷰
        EXCEPTIONS
          CLIENT_REFERENCE             = 1
          FOREIGN_LOCK                 = 2
          INVALID_ACTION               = 3
          NO_CLIENTINDEPENDENT_AUTH    = 4
          NO_DATABASE_FUNCTION         = 5
          NO_EDITOR_FUNCTION           = 6
          NO_SHOW_AUTH                 = 7
          NO_TVDIR_ENTRY               = 8
          NO_UPD_AUTH                  = 9
          ONLY_SHOW_ALLOWED            = 10
          SYSTEM_FAILURE               = 11
          UNKNOWN_FIELD_IN_DBA_SELLIST = 12
          VIEW_NOT_FOUND               = 13
          MAINTENANCE_PROHIBITED       = 14
          OTHERS                       = 15.

    CATCH CX_ROOT INTO DATA(LV_ERR).
      LV_MSG = LV_ERR->GET_TEXT(  ).
      MESSAGE S000 WITH LV_MSG DISPLAY LIKE GC_E.
  ENDTRY.


ENDFORM.


*&---------------------------------------------------------------------*
*& FORM CHECK_AUTH
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
FORM CHECK_AUTH .

  AUTHORITY-CHECK OBJECT 'ZCBO_MM001'
               ID 'BUKRS' FIELD P_BUKRS.

  CHECK SY-SUBRC <> 0.

  SET CURSOR FIELD 'P_BUKRS'.
  MESSAGE E172 WITH P_BUKRS. "회사코드[&] 작업권한을 확인하세요.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form F_START_OF_SELECTION
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_START_OF_SELECTION .

  PERFORM F_CHECK_AUTH.
  PERFORM F_INPUT_VALIDATION.

  CHECK GV_ERR IS INITIAL.

  "데이터 조회
  PERFORM F_GET_DATA.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_END_OF_SELECTION
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_END_OF_SELECTION .

  "데이터가 없으면 메세지 처리
  IF GT_LIST[] IS INITIAL.
    MESSAGE S002 DISPLAY LIKE GC_E.
    LEAVE LIST-PROCESSING.
  ENDIF.

  CALL SCREEN 100.

ENDFORM.

*&---------------------------------------------------------------------*
*& FORM F_CHECK_AUTH
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
FORM F_CHECK_AUTH.

  AUTHORITY-CHECK OBJECT 'ZCBO_MM001'
                     ID 'BUKRS' FIELD P_BUKRS.

  CHECK SY-SUBRC <> 0.

  SET CURSOR FIELD 'P_BUKRS'.
  MESSAGE E172 WITH P_BUKRS. "회사코드 [&] 작업권한을 확인하세요.

ENDFORM.

*&---------------------------------------------------------------------*
*& FORM F_INPUT_VALIDATION
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
FORM F_INPUT_VALIDATION.

  CLEAR : GT_LIST, GV_ERR.

  IF P_BUKRS IS INITIAL.
    GV_ERR = GC_X. "회사코드가 누락되었습니다.
    MESSAGE S001 DISPLAY LIKE GC_E.
  ENDIF.

  IF P_MON = GC_X AND S_PERIOD[] IS INITIAL OR
     P_DAY = GC_X AND S_DATE[] IS INITIAL OR
     P_YEAR = GC_X AND S_YEAR[] IS INITIAL.

    GV_ERR = GC_X. "기간 입력은 필수 입니다.
    MESSAGE S000 WITH TEXT-M01 DISPLAY LIKE GC_E.
  ENDIF.

  CHECK GV_ERR IS INITIAL.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_GET_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_GET_DATA.

  "초기화
  CLEAR GT_LIST[].

  CASE GC_X.
    WHEN P_YEAR. "YEARLY
      SELECT FROM ZGTMM_CV_GET_LMC_YEARLY_CAL
      FIELDS *
      WHERE BUKRS EQ @P_BUKRS
           AND CYEAR IN  @S_YEAR
      INTO CORRESPONDING FIELDS OF TABLE @GT_LIST.

      SORT GT_LIST BY BUKRS  CYEAR.

    WHEN P_MON.  "MONTHLY
      SELECT FROM ZGTMM_CV_GET_LMC_MONTHLY_CAL
      FIELDS *
      WHERE BUKRS EQ @P_BUKRS
           AND CMON IN  @S_PERIOD
      INTO CORRESPONDING FIELDS OF TABLE @GT_LIST.

      SORT GT_LIST BY BUKRS  CMON.

    WHEN P_DAY.    "DAILY
      SELECT FROM ZGTMM_CV_GET_LMC_DAILY_CAL
      FIELDS *
      WHERE BUKRS EQ @P_BUKRS
           AND CDATE IN  @S_DATE
      INTO CORRESPONDING FIELDS OF TABLE @GT_LIST.

      SORT GT_LIST BY BUKRS CDATE.

    WHEN OTHERS.
  ENDCASE.


ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_REFRESH
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_REFRESH .

  "데이터 조회
  PERFORM F_GET_DATA.

ENDFORM.
