FUNCTION ZGTSD_IF_I_SO_REJECT_RELEASE .
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(IS_D365_LOGIN) TYPE  ZSDS_LOG_0000 OPTIONAL
*"     VALUE(I_STATUS) TYPE  ZGTE_APPROVE_ST OPTIONAL
*"  EXPORTING
*"     VALUE(ES_RETURN) TYPE  ZSDS_LOG_0001
*"  TABLES
*"      IT_TAB STRUCTURE  ZGTSDSIF0009
*"----------------------------------------------------------------------
*&---------------------------------------------------------------------*
*& 모듈        : SD
*& 프로그램 ID : ZGTSD_IF_I_UPD_STAT_DEL_REJECT
*& 프로그램 명 : [GT] 주문변경 결재내용 수신
*& 개요   :
*& 생성일 : 2025.05.26
*& 생성자 : ZGSIDEV05
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
  INCLUDE ZSDC0000.
**********************************************************************
*NEW VER..
**********************************************************************

  DATA : LV_SUBRC TYPE SY-SUBRC,
         LV_SCNT  TYPE I,
         LV_ECNT  TYPE I.

  DATA : LV_NAMETXT TYPE USER_ADDR-NAME_TEXTC,
         LV_KUNNR   TYPE KUNNR,
         LV_ERR     TYPE FLAG,
         LV_MSG     TYPE CHAR200,
         LT_VB      TYPE TABLE OF ZGTSDSIF0009 WITH EMPTY KEY,
         LT_TAB     TYPE TABLE OF ZGTSDSIF0009 WITH HEADER LINE.

  IF IS_D365_LOGIN-ENAME IS INITIAL.
    MESSAGE S007(ZGTSD01) WITH TEXT-E12 INTO LV_MSG.
    ES_RETURN = VALUE #( MTYPE = ZGTSD_E MESSAGE = LV_MSG ).
    PERFORM SAVE_LOG(ZCMR0004) TABLES GT_ILOG USING GS_HLOG ES_RETURN.
    EXIT.
  ENDIF.

  IF I_STATUS IS INITIAL.
    MESSAGE S007(ZGTSD01) WITH | 품의서 상태| INTO LV_MSG.
    ES_RETURN = VALUE #( MTYPE = ZGTSD_E MESSAGE = LV_MSG ).
    PERFORM SAVE_LOG(ZCMR0004) TABLES GT_ILOG USING GS_HLOG ES_RETURN.
    EXIT.
  ENDIF.

  IF IT_TAB[] IS INITIAL.
    MESSAGE S000(ZGTSD01) WITH  |품의서 상태를 처리할 데이터가 없습니다.| INTO LV_MSG.
    ES_RETURN = VALUE #( MTYPE = ZGTSD_E MESSAGE = LV_MSG ).
    PERFORM SAVE_LOG(ZCMR0004) TABLES GT_ILOG USING GS_HLOG ES_RETURN.
    EXIT.
  ENDIF.

  SORT IT_TAB BY ZSEQNO VBELN.
  DELETE ADJACENT DUPLICATES FROM IT_TAB COMPARING ZSEQNO VBELN.

  LT_TAB[] = IT_TAB[].
  CASE I_STATUS.

    WHEN 'C'.

      LT_VB[] = IT_TAB[].
      SORT LT_VB BY VBELN.
      DELETE ADJACENT DUPLICATES FROM LT_VB COMPARING VBELN.

      SELECT B~VBELN, B~CHANGENR, B~ZSEQNO, B~APPROVED_STATUS
        FROM @LT_VB AS A INNER JOIN ZGTSDT1013 AS B
          ON A~ZSEQNO = B~ZSEQNO
         AND A~VBELN  = B~VBELN
       WHERE B~APPROVED_STATUS NOT IN ('P', 'T')
        INTO TABLE @DATA(LT_DUP).
      IF SY-SUBRC = 0.
        SORT LT_DUP BY VBELN.
        LOOP AT LT_TAB.

          READ TABLE LT_DUP INTO DATA(LS_DUP) WITH KEY VBELN    = LT_TAB-VBELN BINARY SEARCH.
          IF SY-SUBRC = 0.
            DELETE LT_TAB.
            READ TABLE LT_VB INTO DATA(LS_VB) WITH KEY VBELN = LT_TAB-VBELN.
            IF SY-SUBRC = 0.
              DELETE LT_VB INDEX SY-TABIX.
            ENDIF.
            CONTINUE.
          ENDIF.

        ENDLOOP.
      ENDIF.

      IF LT_TAB[] IS INITIAL.
        MESSAGE S000(ZGTSD01) WITH '[ 승인완료 ] 가능한 상태가 아닙니다.' INTO ES_RETURN-MESSAGE.
        ES_RETURN-MTYPE = |E|.
        PERFORM SAVE_LOG(ZCMR0004) TABLES GT_ILOG USING GS_HLOG ES_RETURN.
        EXIT.
      ENDIF.

**********************************************************************
*상태가 'C' 인 S/O는 현재 수정중인 데이터 있는지 체크후 S/O LOCK - S
**********************************************************************
      LOOP AT LT_VB INTO LS_VB.
        PERFORM CHECK_LOCK_CODE USING    LS_VB-VBELN
                                CHANGING LV_NAMETXT LV_KUNNR LV_ERR.
        IF LV_ERR IS NOT INITIAL.
          EXIT.
        ENDIF.
      ENDLOOP.

      IF LV_ERR EQ 'X'.
        MESSAGE S104(ZGTSD01) WITH LV_NAMETXT LV_KUNNR INTO ES_RETURN-MESSAGE.
        ES_RETURN-MTYPE = |E|.
        PERFORM SAVE_LOG(ZCMR0004) TABLES GT_ILOG USING GS_HLOG ES_RETURN.
        EXIT.
      ENDIF.

      LOOP AT LT_VB INTO LS_VB.
        CLEAR LV_ERR.
        PERFORM DOC_LOCK USING    LS_VB-VBELN
                         CHANGING ES_RETURN
                                  LV_ERR.
        IF LV_ERR IS NOT INITIAL.
          EXIT.
        ENDIF.
      ENDLOOP.

      IF LV_ERR EQ 'X'.
        PERFORM SAVE_LOG(ZCMR0004) TABLES GT_ILOG USING GS_HLOG ES_RETURN.
        EXIT.
      ENDIF.
**********************************************************************
* - END
**********************************************************************

  ENDCASE.

  CLEAR : ES_RETURN, LV_SCNT, LV_ECNT.
  LOOP AT LT_TAB .

    CLEAR : LV_SUBRC, LV_ERR.

    CASE I_STATUS.
      WHEN 'C'.

        PERFORM CALL_CHANGE_SO_BAPI USING LT_TAB-VBELN LT_TAB-ZSEQNO
                                 CHANGING LV_SUBRC.
        IF LV_SUBRC NE 0.
          LV_ERR = 'X'.
          ADD 1 TO LV_ECNT. CONTINUE.
        ENDIF.

    ENDCASE.

    CHECK LV_ERR IS INITIAL.

    UPDATE ZGTSDT1013 SET APPROVED_STATUS = I_STATUS
                          AEDAT           = SY-DATUM
                          AEDATLO         = SY-DATLO
                          AEZEIT          = SY-UZEIT
                          AETIMLO         = SY-TIMLO
                          AETCODE         = SY-TCODE
                          AENAM           = IS_D365_LOGIN-ENAME
      WHERE VBELN  = LT_TAB-VBELN
        AND ZSEQNO = LT_TAB-ZSEQNO.
    IF SY-SUBRC = 0.
      COMMIT WORK.
    ENDIF.

  ENDLOOP.

**********************************************************************
*LOCK 해제
**********************************************************************
  LOOP AT LT_VB INTO LS_VB.
    PERFORM DOC_UNLOCK USING  LS_VB-VBELN.
  ENDLOOP.
**********************************************************************

  IF LV_ECNT IS INITIAL.
    ES_RETURN-MESSAGE = |상태 반영 완료|.
    ES_RETURN-MTYPE = |S|.
  ELSE.
    ES_RETURN-MESSAGE = |상태 반영 실패|.
    ES_RETURN-MTYPE = |E|.
  ENDIF.

  PERFORM SAVE_LOG(ZCMR0004) TABLES GT_ILOG USING GS_HLOG ES_RETURN.

ENDFUNCTION.
