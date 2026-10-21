*&---------------------------------------------------------------------*
*& Include          ZGTMMR4390F01
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*& FORM INITIALIZATION
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
FORM INITIALIZATION .

  CLEAR : S_PERIOD[]. "기간(YYYYMM)
  S_PERIOD[] = VALUE #( ( SIGN     = GC_I
                                       OPTION = GC_EQ
                                       LOW     = SY-DATLO(6)  - 1 ) ).

  ENDFORM.

*&---------------------------------------------------------------------*
*& FORM SELECTION_SCREEN_OUTPUT
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
FORM SELECTION_SCREEN_OUTPUT .

*  LOOP AT SCREEN.
*    CASE SCREEN-GROUP1.
*
*      WHEN 'YR'.
*         SCREEN-ACTIVE = COND #( WHEN P_YEAR = GC_X THEN 1 ELSE 0 ).
*
*      WHEN 'MON'.
*          SCREEN-ACTIVE = COND #( WHEN P_MON = GC_X THEN 1 ELSE 0 ).
*
*      WHEN 'DAY'.
*          SCREEN-ACTIVE = COND #( WHEN P_DAY = GC_X THEN 1 ELSE 0 ).
*
*      WHEN OTHERS.
*    ENDCASE.
*
*    MODIFY SCREEN.
*  ENDLOOP.

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

  AUTHORITY-CHECK OBJECT 'ZCBO_MM001'
               ID 'WERKS' FIELD P_WERKS.

  CHECK SY-SUBRC <> 0.

  SET CURSOR FIELD 'P_WERKS'.
  MESSAGE E106 WITH P_WERKS. "플랜트[&] 작업권한을 확인하세요.

  AUTHORITY-CHECK OBJECT 'ZCBO_MM001'
               ID 'EKGRP' FIELD P_EKGRP.

  CHECK SY-SUBRC <> 0.

  SET CURSOR FIELD 'P_EKGRP'.
  MESSAGE E171 WITH P_EKGRP. "구매그룹[&] 작업권한을 확인하세요.

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
  CASE GC_X.
    WHEN P_DELNO.
      IF GT_LIST_DELI[] IS INITIAL.
         MESSAGE S002 DISPLAY LIKE GC_E.
         LEAVE LIST-PROCESSING.
      ENDIF.

    WHEN P_VBELN OR P_EBELN.
      IF   GT_LIST[] IS INITIAL .
         MESSAGE S002 DISPLAY LIKE GC_E.
         LEAVE LIST-PROCESSING.
      ENDIF.

    WHEN OTHERS.
  ENDCASE.

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

  IF P_WERKS IS INITIAL.
    GV_ERR = GC_X. "플랜트가 누락되었습니다.
    MESSAGE S008 WITH '플랜트' DISPLAY LIKE GC_E.
  ENDIF.

  IF P_EKGRP IS INITIAL.
    GV_ERR = GC_X. "구매그룹이 누락되었습니다.
    MESSAGE S008 WITH '구매그룹' DISPLAY LIKE GC_E.
  ENDIF.

  IF  S_PERIOD[] IS INITIAL.
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
    WHEN P_VBELN.
"판매오더
      SELECT FROM ZGTMM_CV_GET_SO_GR_BYMON
      FIELDS *
      WHERE BUKRS = @P_BUKRS
           AND WERKS = @P_WERKS
           AND EKGRP = @P_EKGRP
           AND SPMON IN @S_PERIOD
           AND LIFNR IN @S_LIFNR
      INTO CORRESPONDING FIELDS OF TABLE @GT_LIST.

      SORT GT_LIST BY BUKRS WERKS SPMON LIFNR VBELN POSNR.

    WHEN P_EBELN.
"구매오더
      SELECT FROM ZGTMM_CV_GET_PO_GR_BYMON
      FIELDS *
      WHERE BUKRS = @P_BUKRS
           AND WERKS = @P_WERKS
           AND EKGRP = @P_EKGRP
           AND SPMON IN @S_PERIOD
           AND LIFNR IN @S_LIFNR
      INTO CORRESPONDING FIELDS OF TABLE @GT_LIST.

      SORT GT_LIST BY BUKRS WERKS SPMON LIFNR VBELN POSNR EBELN EBELP.

    WHEN P_DELNO.
"납품서
      SELECT FROM ZGTMM_CV_GET_GODELIVERY_LAST2
      FIELDS *
      WHERE BUKRS = @P_BUKRS
           AND WERKS = @P_WERKS
           AND EKGRP = @P_EKGRP
           AND SPMON IN @S_PERIOD
           AND LIFNR IN @S_LIFNR
      INTO CORRESPONDING FIELDS OF TABLE @GT_LIST_DELI.

      SORT GT_LIST_DELI BY BUKRS WERKS SPMON LIFNR VBELN POSNR
                                         EBELN EBELP DELNO DELITEM.

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
