*&---------------------------------------------------------------------*
*& Include          ZGTSD_CHECK_SO_CONTROL_SAVE
*&---------------------------------------------------------------------*

**********************************************************************
*로직 미확정으로 주석 처리
**********************************************************************

  DATA : LT_1014    TYPE TABLE OF ZGTSDT1014 WITH HEADER LINE,
         LS_1013    TYPE ZGTSDT1013,
         LS_HDR     TYPE ZGTSDT1013,
         LT_HDR     TYPE TABLE OF ZGTSDT1013,
         LV_TRTYP   TYPE TRTYP,
         LV_ACTIVE  TYPE CHAR01,
         LV_FLAG    TYPE CHAR01,
         LV_ZSEQNO  TYPE ZGTSDT1013-ZSEQNO,
         LS_DB_1017 TYPE ZGTSDT1017,
         LT_DB_1017 TYPE STANDARD TABLE OF ZGTSDT1017.

  CLEAR : LS_1013,LS_DB_1017, LS_HDR.
  REFRESH : LT_1014, LT_DB_1017.

  CHECK VBAK-ERDAT >= '20250801'.

  SELECT SINGLE MANDT INTO SY-MANDT  "특정 TCODE SKIP   Z
    FROM ZGTPPT1010
   WHERE MODULE_KIND  = 'SD'
     AND CODEGRP = '5010'
*     AND FLD_01 = SY-REPID
     AND FLD_02 = 'ZGTSD_CHECK_SO_CONTROL_PRE'
     AND FLD_03 = SY-TCODE.
  CHECK SY-SUBRC NE 0.

**********************************************************************
*ZGTSD_IF_I_SO_REJECT_RELEASE 에서  승인시 거부사유 제거를 위한 FLAG
*FLAG 값이 있을경우 하위 로직 SKIP
  IMPORT LV_FLAG FROM MEMORY ID 'ZGTSD_UPD_STS'.
  CHECK LV_FLAG IS INITIAL.
**********************************************************************

  SELECT SINGLE MANDT INTO SY-MANDT  "특정 유저 SKIP   Z
    FROM ZGTPPT1010
   WHERE MODULE_KIND  = 'SD'
     AND CODEGRP = 'ZZZZ'
     AND FLD_01 = SY-UNAME.
  CHECK SY-SUBRC NE 0.

*1) 에너지 사업부 여부 확인

  CALL FUNCTION 'ZGTSD_EXIT_CONTROL'
    EXPORTING
      I_PERFORM = 'CHECK_SO_CONTROL'
      I_VKORG   = VBAK-VKORG
      I_AUART   = VBAK-AUART
      I_VKBUR   = VBAK-VKBUR
    IMPORTING
      E_ACTIVE  = LV_ACTIVE.

  CHECK LV_ACTIVE EQ |Y|.

  IMPORT LT_1014 FROM MEMORY ID 'ZGT_CHECK_SO_CONTROL'.
  FREE MEMORY ID 'ZGT_CHECK_SO_CONTROL'.

* 변경사항이 없을 경우 ZGTSD_CHECK_SO_CONTROL_PRE에서 ZSEQNO를 Z999999999로 전달
  READ TABLE LT_1014 WITH KEY ZSEQNO = 'Z999999999'.
  CHECK SY-SUBRC NE 0.

  LS_1013-VBELN = VBAK-VBELN.
  LS_1013-ZPJNO = VBAK-ZPJNO.
  LS_1013-APPROVED_STATUS = 'A'.
  LS_1013-TRTYP = T180-TRTYP.

  CASE T180-TRTYP.
    WHEN 'H'.
      PERFORM GET_ZGTSDT1011_ZSEQNO  USING LS_1013-ZSEQNO.
*      LS_1013-APPROVED_STATUS = 'A'.
      ZGTSD_CL_COMMON=>SET_TIMESTAMP( EXPORTING IV_GUBUN = ZGTSD_A
                                      CHANGING  CS_TIMESTAMP = LS_1013-TIMESTAMP ).

** 에너지사업부 삼국 주문의 경우 생성과 동시에 거부사유가 입력되므로
** VBAP-ARSNUM, VBAP-ARSPOS 값이 사라지기 때문에 CBO 테이블 임시저장
      IF VBAK-AUART EQ 'Z3RD'.
        LOOP AT XVBAP INTO DATA(LS_XVBAP).
          LS_DB_1017 = CORRESPONDING #( LS_XVBAP ).
          LS_DB_1017-ZPJNO = VBAK-ZPJNO.
          LS_DB_1017-VBELN = VBAK-VBELN.
          APPEND LS_DB_1017 TO LT_DB_1017.
        ENDLOOP.

        TRY.
            INSERT ZGTSDT1017 FROM TABLE LT_DB_1017.
          CATCH CX_SY_OPEN_SQL_DB INTO DATA(LO_SQL_DB).
            DATA(LV_MSG) = LO_SQL_DB->GET_TEXT( ).
            ROLLBACK WORK.
        ENDTRY.
      ENDIF.

    WHEN 'V'.

      SELECT SINGLE * INTO CORRESPONDING FIELDS OF LS_HDR
        FROM ZGTSDT1013
       WHERE VBELN EQ VBAK-VBELN
         AND ZSEQNO EQ ( SELECT MAX( ZSEQNO )
                           FROM ZGTSDT1013
                          WHERE VBELN EQ VBAK-VBELN ).
      IF SY-SUBRC EQ 0.
        CASE LS_HDR-APPROVED_STATUS.
* 품의서 상태 완료(C)면 ZSEQNO 신규 채번
          WHEN 'C'.
            PERFORM GET_ZGTSDT1011_ZSEQNO USING LS_1013-ZSEQNO.
            ZGTSD_CL_COMMON=>SET_TIMESTAMP( EXPORTING IV_GUBUN = ZGTSD_A
                                            CHANGING  CS_TIMESTAMP = LS_1013-TIMESTAMP ).
* 그 외 상태는 기존 ZSEQNO 사용
          WHEN OTHERS.
* 1) TRTRYP 값 결정: 판매오더 생성 후 품의서 기안 전까지의 변경은 모두 TRTYP = 'H'로 저장
            IF LS_HDR-TRTYP EQ 'H'.
              LS_1013-TRTYP = LS_HDR-TRTYP.
            ENDIF.
* 2) 품의상태 결정
            IF LS_HDR-APPROVED_STATUS EQ 'T'. "임시저장
              LS_1013-APPROVED_STATUS = LS_HDR-APPROVED_STATUS.
            ENDIF.
* 3) 품의서 번호(ZSEQNO) 입력
            LS_1013-ZSEQNO = LS_HDR-ZSEQNO.

            CLEAR LS_1013-CHANGENR.
            ZGTSD_CL_COMMON=>SET_TIMESTAMP( EXPORTING IV_GUBUN = ZGTSD_A
                                            CHANGING  CS_TIMESTAMP = LS_1013-TIMESTAMP ).
        ENDCASE.

      ELSE.
        PERFORM GET_ZGTSDT1011_ZSEQNO USING LS_1013-ZSEQNO.
        ZGTSD_CL_COMMON=>SET_TIMESTAMP( EXPORTING IV_GUBUN = ZGTSD_A
                                        CHANGING  CS_TIMESTAMP = LS_1013-TIMESTAMP ).
      ENDIF.

  ENDCASE.

* 사용자입력 거부사유 DATA 구성
  LOOP AT LT_1014.
    LT_1014-ZSEQNO = LS_1013-ZSEQNO.
    LT_1014-VBELN  = LS_1013-VBELN.
    LT_1014-ZPJNO  = LS_1013-ZPJNO.

    CASE T180-TRTYP.
      WHEN 'H'.
        ZGTSD_CL_COMMON=>SET_TIMESTAMP( EXPORTING IV_GUBUN = ZGTSD_A
                                         CHANGING CS_TIMESTAMP = LT_1014-TIMESTAMP ).
      WHEN 'V'.
        ZGTSD_CL_COMMON=>SET_TIMESTAMP( EXPORTING IV_GUBUN = ZGTSD_A
                                         CHANGING CS_TIMESTAMP = LT_1014-TIMESTAMP ).
    ENDCASE.

    MODIFY LT_1014.
  ENDLOOP.

* CDHDR, CDPOS 데이터가 생성된 후 CHANGENR 값을 채번해야 되기 때문에 UPDATE TASK 모드로 FUNC. 실행
* CHANGENR 값 ZGTSDT1013, ZGTSDT1014 테이블 저장
  CALL FUNCTION 'ZGTSD_SAVE_SO_CHANGES' IN UPDATE TASK
    EXPORTING
      IS_HDR     = LS_1013
      IV_TRTYP   = T180-TRTYP
    TABLES
      IT_RJT_ITM = LT_1014.
