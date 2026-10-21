FUNCTION ZGTSD_IF_I_CONTRACT.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(IS_D365_LOGIN) TYPE  ZSDS_LOG_0000 OPTIONAL
*"  EXPORTING
*"     VALUE(ES_RETURN) TYPE  ZSDS_LOG_0001
*"  TABLES
*"      IT_TAB STRUCTURE  ZGTSDSIF0008 OPTIONAL
*"      IT_ITEM STRUCTURE  ZSDT_D365_011 OPTIONAL
*"  EXCEPTIONS
*"      SYSTEM_FAILURE
*"      COMMUNICATION_FAILURE
*"      ILLEGALNAME
*"----------------------------------------------------------------------
*&---------------------------------------------------------------------*
*& 모듈        : SD
*& 프로그램 ID : ZGTSD_IF_I_CONTRACT
*& 프로그램 명 : 수주정보 수신 (SalesOutlook->SAP)
*& 개요   :
*& 생성일 : 2025.01.07
*& 생성자 : 신영철
*&---------------------------------------------------------------------*
*& 외부 호출 프로그램 개요   : N/A
*& 타 시스템 인터페이스 개요 : SalesOutlook
*&---------------------------------------------------------------------*
*& 프로그램 수정이력
*&---------------------------------------------------------------------*
*& 수정일  :
*& 수정자  :
*& 수정개요:
*&---------------------------------------------------------------------*
*-----------------------------------------------------------------------
*-- Include
*-----------------------------------------------------------------------
  INCLUDE ZSDC0000.
*-----------------------------------------------------------------------
*-- 1. 로컬 변수 선언
*-----------------------------------------------------------------------
  TYPES : LTY_U_106T   TYPE ZSD0106T            WITH INDICATORS IND,
          LTY_T_U_106T TYPE TABLE OF LTY_U_106T WITH EMPTY KEY.

  DATA : LT_DB_2000 TYPE TABLE OF ZGTSDT2000 WITH EMPTY KEY,
         LS_DB_2000 TYPE ZGTSDT2000,
         LT_DB_2010 TYPE TABLE OF ZGTSDT2010 WITH EMPTY KEY,
         LS_DB_2010 TYPE ZGTSDT2010,
         LT_DUP     TYPE TABLE OF ZSDT_D365_011 WITH NON-UNIQUE SORTED KEY K_KEY
                                                COMPONENTS ZPJNO QTVER ITEMKEY,

         LT_TAB     TYPE TABLE OF ZGTSDSIF0008 WITH EMPTY KEY,

         LT_U_106T  TYPE LTY_T_U_106T,
         LS_HTAB    TYPE ZGTSDSIF0060,
         LT_HTAB    TYPE TABLE OF ZGTSDSIF0060,

         LS_RETURN  TYPE BAPIRET2,
         LS_RETN    TYPE ZSDS_LOG_0001,

         LV_EFLG    TYPE CHAR01,
         LV_MSG     TYPE CHAR200,
         LV_SYSID   TYPE ZGTETARGET,
         LV_ZIFKEY  TYPE TIMESTAMPL.

  DATA : LV_ACTIVE TYPE CHAR01.

  CONSTANTS : LC_PROG TYPE SY-CPROG VALUE 'ZGTSD_IF_I_CONTRACT'.

  CLEAR : ES_RETURN,
          LT_DB_2000, LT_U_106T, LT_HTAB, LV_EFLG.

*-----------------------------------------------------------------------
*-- 2. Import 값 정합성 체크
*-----------------------------------------------------------------------
*-- 2-1. Import 값 없을경우 오류 정보 구성
  IF IT_TAB[] IS INITIAL.
    CLEAR LS_RETURN.
    LS_RETURN = VALUE #( TYPE       = 'E'
                         ID         = 'ZGTSD01'
                         NUMBER     = '000'
                         MESSAGE_V1 = '수주정보가 없습니다.'(E01)
                       ).
    PERFORM MESSAGE_TEXT_BUILD      CHANGING LS_RETURN.
    LV_EFLG = ABAP_TRUE.
  ENDIF.

  LOOP AT IT_TAB .

    SELECT SINGLE B~* INTO @DATA(LS_SALES)
      FROM ZSD0106T AS A INNER JOIN TVKBZ AS B
        ON A~ZVKBUR = B~VKBUR
     WHERE ZPJNO = @IT_TAB-ZPJNO.

    CALL FUNCTION 'ZGTSD_EXIT_CONTROL'
      EXPORTING
        I_PROG   = LC_PROG
        I_VKORG  = LS_SALES-VKORG
        I_SPART  = LS_SALES-SPART
      IMPORTING
        E_ACTIVE = LV_ACTIVE.

*-- Local 일자 기준 해당 적용일 이후인 경우 해당 로직 수행
    IF LV_ACTIVE EQ ZGTSD_Y.
      IF IT_ITEM[] IS INITIAL.
        CLEAR LS_RETURN.
        LS_RETURN = VALUE #( TYPE       = 'E'
                             ID         = 'ZGTSD01'
                             NUMBER     = '000'
                             MESSAGE_V1 = '견적 Item 정보가 없습니다.'(E31)
                           ).
        PERFORM MESSAGE_TEXT_BUILD      CHANGING LS_RETURN.
        LV_EFLG = ABAP_TRUE.EXIT.

      ELSE.
*IT_ITEM의 키 값 중복일 경우 에러 메시지 ZPJNO, QTVER, ITEMKEY
        LT_DUP[] = IT_ITEM[].
        LOOP AT IT_ITEM.
          DATA(LT_TMP) = FILTER #( LT_DUP[] USING KEY K_KEY WHERE ZPJNO = IT_ITEM-ZPJNO
                                                              AND QTVER = IT_ITEM-QTVER
                                                              AND ITEMKEY = IT_ITEM-ITEMKEY ).
          IF LINES( LT_TMP ) > 1.
            CLEAR LS_RETURN.
            LS_RETURN = VALUE #( TYPE       = 'E'
                                 ID         = 'ZGTSD01'
                                 NUMBER     = '000'
                                 MESSAGE_V1 = '중복되는 Item 정보가 있습니다.'(E33)
                               ).
            PERFORM MESSAGE_TEXT_BUILD      CHANGING LS_RETURN.
            LV_EFLG = ABAP_TRUE.EXIT.
          ENDIF.
        ENDLOOP.

      ENDIF.
    ENDIF.

  ENDLOOP.

*-- 2-2. 오류 정보 확인시 오류 정보 리턴
  IF LV_EFLG EQ ABAP_TRUE.
    ES_RETURN = VALUE #(
                        MTYPE   = LS_RETURN-TYPE
                        MESSAGE = LS_RETURN-MESSAGE
                       ).
*-- Log 정보 구성
    PERFORM SAVE_LOG(ZCMR0004)      TABLES   GT_ILOG
                                    USING    GS_HLOG
                                             ES_RETURN.
    RETURN.
  ENDIF.

  LT_TAB[] = CORRESPONDING #( IT_TAB[] ).

*-----------------------------------------------------------------------
*-- 3. 프로젝트 정보 MES 전송 수행 부스덕트 만 수행
*-----------------------------------------------------------------------
  LOOP AT LT_TAB INTO DATA(LS_TAB).

    SELECT SINGLE ZVKBUR INTO @DATA(LV_VKBUR)
      FROM ZSD0106T
     WHERE ZPJNO = @LS_TAB-ZPJNO.

    CALL FUNCTION 'ZGTSD_GET_TARGETSYS'
      EXPORTING
        I_VKBUR = LV_VKBUR
      IMPORTING
        E_SYSID = LV_SYSID.

    IF LV_SYSID EQ 'KBDM'.

      DATA(LV_CALL) = 'X'.
*-- 3-1. 프로젝트 정보 구성
      IF LS_TAB-ZPJNO IS NOT INITIAL.
        MOVE-CORRESPONDING LS_TAB TO LS_HTAB.
        APPEND LS_HTAB TO LT_HTAB.
      ENDIF.

    ENDIF.

  ENDLOOP.

**-- 3-1. 프로젝트 정보 구성
*  WITH +KEY_INFO AS ( SELECT A~ZPJNO
*                        FROM @LT_TAB AS A
*                       GROUP BY A~ZPJNO )
*    SELECT A~ZPJNO
*      FROM +KEY_INFO AS A
*      INTO CORRESPONDING FIELDS OF TABLE @LT_HTAB.
*
**-- 3-1. 프로젝트 정보 MES 전송 수행
*  CALL FUNCTION 'ZGTSD_IF_I_BD_MFG_INSTR_RCV'
*    EXPORTING
*      IS_D365_LOGIN         = IS_D365_LOGIN
*      I_REQTYPE             = ZGTSD_C             " 수주완료
*    IMPORTING
*      ES_RETURN             = LS_RETN
*    TABLES
*      IT_HTAB               = LT_HTAB[]
*    EXCEPTIONS
*      SYSTEM_FAILURE        = 1
*      COMMUNICATION_FAILURE = 2
*      ILLEGALNAME           = 3
*      OTHERS                = 4.
*
*  IF LS_RETN-MTYPE EQ 'S'.
**-- 성공시 WBS 프로젝트 생성
*    TRY.
*        CALL TRANSACTION 'ZGTCOR1010' AND SKIP FIRST SCREEN.
*      CATCH CX_ROOT INTO DATA(LO_ROOT).
*        DATA(LV_MSG) = LO_ROOT->GET_TEXT( ).
*    ENDTRY.
*  ELSE.
**-- 실패시 오류 정보 리턴
*    ES_RETURN = VALUE #(
*                        MTYPE   = 'E'
*                        MESSAGE = TEXT-M03
*                       ).
**-- Log 정보 구성
*    PERFORM SAVE_LOG(ZCMR0004)      TABLES   GT_ILOG
*                                    USING    GS_HLOG
*                                             ES_RETURN.
*
*    RETURN.
*  ENDIF.

*-----------------------------------------------------------------------
*-- 4. 수주정보 Table 저장 수행
*-----------------------------------------------------------------------
  CLEAR LV_MSG.

*-- 4-1. 저장 정보 구성
  LOOP AT LT_TAB INTO LS_TAB
                 GROUP BY ( ZPJNO = LS_TAB-ZPJNO )
                 ASSIGNING FIELD-SYMBOL(<LS_GROUP>).

*-- 4-1-1. 프로젝트 상태 Update 정보 구성
    APPEND VALUE #(
                    ZPJNO    = LS_TAB-ZPJNO           " Project NO
                    STAT     = 'C010'                     " 상태

                    IND-STAT = '01'
                  ) TO LT_U_106T.

    LOOP AT GROUP <LS_GROUP> ASSIGNING FIELD-SYMBOL(<LS_LIST>).
*-- 4-1-2. 수주정보등록 수신 이력 저장정보 구성
      CLEAR : LV_ZIFKEY, LS_DB_2000.

*-- 4-1-3. IFKey 정보 구성 - TimeStamp
      GET TIME STAMP FIELD LV_ZIFKEY.

      LS_DB_2000 = CORRESPONDING #( <LS_LIST> ).
      LS_DB_2000 = VALUE #( BASE LS_DB_2000
                            ZIFKEY       = LV_ZIFKEY      " I/F 카
                            WAERK_KRW    = GC_WAERK-KRW   " 원화 단위 KRW
                            WAERK_USD    = GC_WAERK-USD   " USD 단위 USD

                            ERDAT        = SY-DATUM       " 생성일
                            ERZET        = SY-UZEIT       " 생성시간
                            ERNAM        = SY-UNAME       " 생성ID
                            AEDAT        = SY-DATUM       " 변경일
                            AEZET        = SY-UZEIT       " 변경시간
                            AENAM        = SY-UNAME       " 변경ID
                            ZERP_STAT    = 'S'            " 처리상태
                            ZERP_MESSAGE = TEXT-M02       " 처리메세지
                          ).

      APPEND LS_DB_2000 TO LT_DB_2000.

**********************************************************************
*ZGTSDT2010 TABLE DATA .
**********************************************************************
      SPLIT <LS_LIST>-ZTERM AT ',' INTO TABLE DATA(LT_TMP_ZTERM) IN CHARACTER MODE.
      SPLIT <LS_LIST>-INCO1 AT ',' INTO TABLE DATA(LT_TMP_INCO1) IN CHARACTER MODE.
      LOOP AT LT_TMP_ZTERM INTO DATA(LS_ZTERM).
        CLEAR LS_DB_2010.
        LS_DB_2010 = VALUE #( BASE LS_DB_2010
                              ZIFKEY       = LV_ZIFKEY      " I/F 카
                              ZPJNO        = <LS_LIST>-ZPJNO   " Project NO
                              ZTERM        = LS_ZTERM       " ZTERM

                              ERDAT        = SY-DATUM       " 생성일
                              ERZEIT       = SY-UZEIT       " 생성시간
                              ERNAM        = SY-UNAME       " 생성ID
                              AEDAT        = SY-DATUM       " 변경일
                              AEZEIT       = SY-UZEIT       " 변경시간
                              AENAM        = SY-UNAME       " 변경ID
                            ).

        APPEND LS_DB_2010 TO LT_DB_2010.

      ENDLOOP.

      LOOP AT LT_TMP_INCO1 INTO DATA(LS_INCO1).
        CLEAR LS_DB_2010.
        READ TABLE LT_DB_2010 INTO LS_DB_2010 INDEX SY-TABIX.
        IF SY-SUBRC = 0.
          LS_DB_2010-INCO1 = LS_INCO1.
          MODIFY LT_DB_2010 FROM LS_DB_2010 INDEX SY-TABIX.
        ELSE.
          LS_DB_2010 = VALUE #( BASE LS_DB_2010
                                ZIFKEY       = LV_ZIFKEY      " I/F 카
                                ZPJNO        = <LS_LIST>-ZPJNO   " Project NO
                                INCO1        = LS_INCO1       " INCO1

                                ERDAT        = SY-DATUM       " 생성일
                                ERZEIT       = SY-UZEIT       " 생성시간
                                ERNAM        = SY-UNAME       " 생성ID
                                AEDAT        = SY-DATUM       " 변경일
                                AEZEIT       = SY-UZEIT       " 변경시간
                                AENAM        = SY-UNAME       " 변경ID
                              ).

          APPEND LS_DB_2010 TO LT_DB_2010.
        ENDIF.
      ENDLOOP.

    ENDLOOP.
  ENDLOOP.

  LOOP AT IT_ITEM.
    IT_ITEM-ERDAT        = SY-DATUM.
    IT_ITEM-ERZET        = SY-UZEIT.
    IT_ITEM-ERNAM        = SY-UNAME.
    IT_ITEM-AEDAT        = SY-DATUM.
    IT_ITEM-AEZET        = SY-UZEIT.
    IT_ITEM-AENAM        = SY-UNAME.
    MODIFY IT_ITEM.
  ENDLOOP.

*-- 4-2. 수주정보등록 수신 이력 DB Table : ZGTSDT2000 저장 수행
  TRY.
      MODIFY ZGTSDT2000 FROM TABLE LT_DB_2000.
    CATCH CX_SY_OPEN_SQL_DB INTO DATA(LO_SQL_DB).
      LV_MSG = LO_SQL_DB->GET_TEXT( ).
      ROLLBACK WORK.
  ENDTRY.

  IF LT_DB_2010[] IS NOT INITIAL.
    TRY.
        MODIFY ZGTSDT2010 FROM TABLE LT_DB_2010.
      CATCH CX_SY_OPEN_SQL_DB INTO LO_SQL_DB.
        LV_MSG = LO_SQL_DB->GET_TEXT( ).
        ROLLBACK WORK.
    ENDTRY.
  ENDIF.

*-- 4-3. 프로젝트 상태 Update - DB Table : ZSD0106T
  IF LV_MSG IS INITIAL.
    TRY.
        UPDATE ZSD0106T FROM TABLE @LT_U_106T
                        INDICATORS SET STRUCTURE IND.
      CATCH CX_SY_OPEN_SQL_DB INTO LO_SQL_DB.
        LV_MSG = LO_SQL_DB->GET_TEXT( ).
        ROLLBACK WORK.
    ENDTRY.
  ENDIF.

*-- 4-4. AUD 견적- Ver. 별 DB Table : ZSDT_D365_011 저장 수행
  IF IT_ITEM[] IS NOT INITIAL.
    TRY.
        MODIFY ZSDT_D365_011 FROM TABLE IT_ITEM.
      CATCH CX_SY_OPEN_SQL_DB INTO LO_SQL_DB.
        LV_MSG = LO_SQL_DB->GET_TEXT( ).
        ROLLBACK WORK.
    ENDTRY.
  ENDIF.

*-- 4-5. 처리결과 리턴
  IF LV_MSG IS INITIAL.
    ES_RETURN = VALUE #(
                        MTYPE   =  'S'
                        MESSAGE = TEXT-M02
                       ).
  ELSE.
    ES_RETURN = VALUE #(
                        MTYPE   = 'E'
                        MESSAGE = TEXT-M03
                       ).
  ENDIF.

**********************************************************************
*부스덕트 전용 로직
**********************************************************************
**********************************************************************
  IF LT_HTAB[] IS NOT INITIAL.
*-- 3-1. 프로젝트 정보 MES 전송 수행
    CALL FUNCTION 'ZGTSD_IF_I_BD_MFG_INSTR_RCV'
      EXPORTING
        IS_D365_LOGIN         = IS_D365_LOGIN
        I_REQTYPE             = ZGTSD_C             " 수주완료
      IMPORTING
        ES_RETURN             = LS_RETN
      TABLES
        IT_HTAB               = LT_HTAB[]
      EXCEPTIONS
        SYSTEM_FAILURE        = 1
        COMMUNICATION_FAILURE = 2
        ILLEGALNAME           = 3
        OTHERS                = 4.

    IF LS_RETN-MTYPE NE 'S'.
*-- 실패시 오류 정보 리턴
      ES_RETURN = VALUE #(
                          MTYPE   = 'E'
                          MESSAGE = '수주보고서 정상적으로 수신, 프로젝트정보는 부스덕트 MES 전송 실패' "TEXT-M03
                         ).
*-- Log 정보 구성
      PERFORM SAVE_LOG(ZCMR0004)      TABLES   GT_ILOG
                                      USING    GS_HLOG
                                               ES_RETURN.
    ENDIF.

  ENDIF.

*-- 성공시 WBS 프로젝트 생성
  IF LV_CALL IS NOT INITIAL.
    TRY.
        CALL TRANSACTION 'ZGTCOR1010' AND SKIP FIRST SCREEN.
      CATCH CX_ROOT INTO DATA(LO_ROOT).
        LV_MSG = LO_ROOT->GET_TEXT( ).
    ENDTRY.
  ENDIF.

*-- Log 정보 구성
  PERFORM SAVE_LOG(ZCMR0004)        TABLES   GT_ILOG
                                    USING    GS_HLOG
                                             ES_RETURN.
ENDFUNCTION.
