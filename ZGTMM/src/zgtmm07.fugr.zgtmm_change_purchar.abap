FUNCTION ZGTMM_CHANGE_PURCHAR.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(I_BUKRS) TYPE  BUKRS
*"     VALUE(I_TYPE) TYPE  CUIB_OBJTYP
*"  EXPORTING
*"     VALUE(MTYPE) TYPE  BAPI_MTYPE
*"     VALUE(MESSAGE) TYPE  BAPI_MSG
*"  TABLES
*"      IT_PODATA STRUCTURE  ZGTMMS4516
*"      IT_CHDATA STRUCTURE  ZGTMMS4517
*"----------------------------------------------------------------------
*&---------------------------------------------------------------------*
*& 모듈          : MM
*& 프로그램 ID : ZGTMM_CHANGE_PURCHAR
*& 프로그램 명 :  구매문서 특성 변경
*& 개요   : 구매문서 특성(조장,색상 등) 변경을 위한 공통  FUNCTION 개발
*& 생성일 : 2026.02.23
*& 생성자 : ZGODEV04
*&---------------------------------------------------------------------*
*& 프로그램 수정이력
*&---------------------------------------------------------------------*
*& 수정일  :
*& 수정자  :
*& 수정개요:
*&---------------------------------------------------------------------*
  DATA : BEGIN OF LS_CHDATA,
           INSTANCE TYPE ZGTMMS4517-INSTANCE,
           ATNAM    TYPE ZGTMMS4517-ATNAM,
           ATWRT    TYPE ZGTMMS4517-ATWRT,
           ATFLV    TYPE ZGTMMS4517-ATFLV,
           ATINN    TYPE CABN-ATINN,
         END OF LS_CHDATA.
  DATA : LT_CHDATA LIKE TABLE OF LS_CHDATA.
  DATA: LT_IBCO2_TAB2 TYPE IBCO2_INSTANCE_TAB2,
        LT_IBCO       TYPE IBCO2_INSTANCE_REC2 OCCURS 0 WITH HEADER LINE,
        LS_ROOT      TYPE CUIB_BUSINESS_OBJECT,
        LT_ZGTMMT9290 TYPE TABLE OF ZGTMMT9290,
        LT_SAVE       TYPE TABLE OF ZGTMMT9290.

*--필수 입력 값 체크
  IF I_BUKRS IS INITIAL OR I_TYPE IS INITIAL.

    MTYPE      = 'E'.
    MESSAGE  = '필수 값이 누락 되었습니다.'(E01).
    RETURN.
  ENDIF.

*--변경 정보 정합성 체크
*PODATA-CHDATA의 INSTANCE가 두 테이블에 모두 존재 해야 하고 동일/비동일한 지 체크필요.
  IF IT_PODATA[] IS INITIAL OR IT_CHDATA[] IS INITIAL.
    MTYPE      = 'E'.
    MESSAGE  = '변경 대상 정보가 누락되었습니다.'(E05).
    RETURN.

  ELSE.
    SORT IT_PODATA BY INSTANCE.

    LOOP AT IT_CHDATA INTO DATA(LS_CH).

      READ TABLE IT_PODATA INTO DATA(LS_PO)
      WITH KEY INSTANCE = LS_CH-INSTANCE BINARY SEARCH.

      IF SY-SUBRC = 0.
        LS_CHDATA = CORRESPONDING #( LS_CH ).

        CALL FUNCTION 'CONVERSION_EXIT_ATINN_INPUT'
          EXPORTING
            INPUT  = LS_CH-ATNAM
          IMPORTING
            OUTPUT = LS_CHDATA-ATINN.
        APPEND LS_CHDATA TO LT_CHDATA.

      ELSE.
        MTYPE      = 'E'.
        MESSAGE  = '변경 대상 정보가 누락되었습니다.'(E05).
        RETURN.
      ENDIF.
    ENDLOOP.
  ENDIF.

  SORT LT_CHDATA BY INSTANCE ATINN.

**--PO INSTANCE번호 기준으로 특성 변경
  DATA LT_KEY TYPE TABLE OF ZGTMMS4516 WITH EMPTY KEY
           WITH UNIQUE SORTED KEY F_KEY COMPONENTS INSTANCE.
  LT_KEY[] = IT_PODATA[].

*구매문서 정보 가져오기.
  CASE I_TYPE.
    WHEN GC_EKPO.
      SELECT FROM EKPO FIELDS EBELN, EBELP, CUOBJ
        FOR ALL ENTRIES IN @LT_KEY
        WHERE CUOBJ = @LT_KEY-INSTANCE
        INTO TABLE @DATA(LT_EKPO).
      SORT LT_EKPO BY CUOBJ.

    WHEN GC_EBAN.
      SELECT FROM EBAN FIELDS BANFN, BNFPO, CUOBJ
        FOR ALL ENTRIES IN @LT_KEY
        WHERE CUOBJ = @LT_KEY-INSTANCE
        INTO TABLE @DATA(LT_EBAN).
      SORT LT_EBAN BY CUOBJ.

    WHEN OTHERS.
  ENDCASE.

*입력받은 IT_PODATA(PO INSTANCE번호) LOOP 1 시작.
  LOOP AT LT_CHDATA INTO DATA(LS_DATA).
    CLEAR LS_ROOT.
*INSTANCE 번호 기준의 구매문서 번호.
    IF I_TYPE = GC_EKPO.
       READ TABLE LT_EKPO ASSIGNING FIELD-SYMBOL(<PO>)
       WITH KEY CUOBJ = LS_DATA-INSTANCE BINARY SEARCH.
       IF SY-SUBRC = 0.
*          <PO>-EBELP = |{ <PO>-EBELP  ALPHA = OUT }|.
          LS_ROOT = VALUE #( OBJECT_TYPE = I_TYPE
                                           OBJECT_KEY   = <PO>-EBELN && <PO>-EBELP ).
       ENDIF.

    ELSEIF I_TYPE = GC_EBAN.
       READ TABLE LT_EBAN ASSIGNING FIELD-SYMBOL(<EB>)
       WITH KEY CUOBJ = LS_DATA-INSTANCE BINARY SEARCH.
       IF SY-SUBRC = 0.
*         <EB>-BNFPO = |{ <EB>-BNFPO  ALPHA = OUT }|.
          LS_ROOT = VALUE #( OBJECT_TYPE = I_TYPE
                                           OBJECT_KEY   = <EB>-BANFN && <EB>-BNFPO ).
       ENDIF.
    ENDIF.
*CONFIGURATION 조회
    CALL FUNCTION 'CUCB_GET_CONFIGURATION'
      EXPORTING
        INSTANCE                     = LS_DATA-INSTANCE
        IS_BUSINESS_OBJECT   = LS_ROOT
      IMPORTING
        CONFIGURATION           = LT_IBCO2_TAB2 "LT_IBCO
      EXCEPTIONS
        INVALID_INPUT              = 1
        INVALID_INSTANCE        = 2
        INSTANCE_IS_A_CLASSIFICATION = 3
        OTHERS                        = 4.
    IF SY-SUBRC <> 0.
* IMPLEMENT SUITABLE ERROR HANDLING HERE
    ENDIF.

    LT_IBCO[] = LT_IBCO2_TAB2[].

*입력받은 특성 데이터로 변경 세팅_CONFIGURATION 전체 테이블 LOOP 2 시작
    LOOP AT LT_IBCO ASSIGNING FIELD-SYMBOL(<FS>). "
      IF <FS> IS ASSIGNED.
*CONFIGURATION-VALUES 다중 특성값 LOOP 3 시작
        LOOP AT <FS>-VALUES ASSIGNING FIELD-SYMBOL(<FS_V>) .
          READ TABLE LT_CHDATA INTO LS_CH WITH KEY INSTANCE = LS_DATA-INSTANCE
                                                                                  ATINN = <FS_V>-ATINN BINARY SEARCH.
          IF SY-SUBRC = 0.
            IF LS_CH-ATWRT IS INITIAL.
              <FS_V>-ATFLV = LS_CH-ATFLV.
            ELSE.
              <FS_V>-ATWRT = LS_CH-ATWRT.
            ENDIF.
*1차 LOG(ZGTMMT9290)
*            IF I_TYPE = GC_EKPO.
*              READ TABLE LT_EKPO ASSIGNING FIELD-SYMBOL(<PO>)
*              WITH KEY CUOBJ = LS_DATA-INSTANCE BINARY SEARCH.
*
*            ELSEIF I_TYPE = GC_EBAN.
*              READ TABLE LT_EBAN ASSIGNING FIELD-SYMBOL(<EB>)
*              WITH KEY CUOBJ = LS_DATA-INSTANCE BINARY SEARCH.
*            ENDIF.

            IF <PO> IS ASSIGNED OR <EB> IS ASSIGNED.
              LT_ZGTMMT9290[] = VALUE #( BASE LT_ZGTMMT9290
                                           ( CUOBJ = LS_DATA-INSTANCE
                                           PURTYPE = I_TYPE
                                           EBELN = COND #( WHEN I_TYPE = GC_EKPO THEN <PO>-EBELN
                                                                       ELSE SPACE )
                                           EBELP = COND #( WHEN I_TYPE = GC_EKPO THEN <PO>-EBELP
                                                                       ELSE SPACE )
                                           BANFN = COND #( WHEN I_TYPE = GC_EBAN THEN <EB>-BANFN
                                                                       ELSE SPACE )
                                           BNFPO = COND #( WHEN I_TYPE = GC_EBAN THEN <EB>-BNFPO
                                                                       ELSE SPACE )
                                           ATNAM = LS_CH-ATNAM
                                           ATINN = <FS_V>-ATINN
                                           ATWRT = LS_CH-ATWRT
                                           ATFLV = COND #( WHEN LS_CH-ATWRT IS INITIAL
                                                                      THEN LS_CH-ATFLV ELSE SPACE )
                                           ERDAT = SY-DATUM
                                           ERDAT_LOCAL = SY-DATLO
                                           ERTIM = SY-UZEIT
                                           ERTIM_LOCAL = SY-TIMLO
                                           ERNAM = SY-UNAME ) ).
            ENDIF.

          ENDIF.
        ENDLOOP.
*CONFIGURATION-VALUES 다중 특성값 변경 및 1차 로그 저장용 데이터 설정_LOOP 3 종료.
      ENDIF.
    ENDLOOP.
*PARENT CONFIGURATION LOOP 2 종료.

*--구매 문서 특성값 변경 적용
    TRY.
        CALL FUNCTION 'CUCB_CHANGE_CONFIGURATION'
          EXPORTING
            ROOT_INSTANCE             = LS_DATA-INSTANCE "입력받은 PO INSTANCE
          CHANGING
            INSERTED_OR_CHANGED_INSTANCES = LT_IBCO[] "변경 반영 된 CONFIGURATION
          EXCEPTIONS
            INVALID_INPUT                 = 1
            INVALID_INSTANCE           = 2
            INSTANCE_IS_A_CLASSIFICATION  = 3
            OTHERS                           = 4.

      CATCH CX_ROOT INTO DATA(LV_ERROR).
*ERROR->ROLLBACK&LOG SAVE
        CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

        DATA(LV_MSG) = LV_ERROR->GET_TEXT( ).

        SELECT SINGLE @ABAP_TRUE
          FROM ZGTMMT9290
          WHERE CUOBJ     = @LS_DATA-INSTANCE
               AND PURTYPE = @I_TYPE
          INTO @DATA(LV_EXIST).

          IF SY-SUBRC = 0.
              UPDATE ZGTMMT9290
                   SET TYPE = GC_E
                          MESSAGE = LV_MSG
              WHERE CUOBJ     = LS_DATA-INSTANCE
                   AND PURTYPE = I_TYPE.
          ELSE.
              LT_SAVE[] = VALUE #( FOR LS IN LT_ZGTMMT9290
                                ( VALUE #( BASE CORRESPONDING #( LS )
                                                  TYPE = GC_E
                                                  MESSAGE = LV_ERROR->GET_TEXT(  ) ) ) ).
              MODIFY ZGTMMT9290 FROM TABLE LT_SAVE.
          ENDIF.

        MTYPE = GC_E.
        MESSAGE = LV_ERROR->GET_TEXT(  ).
        EXIT.
    ENDTRY.

*에러 없으면, DB 반영
*    CLEAR LS_ROOT.
*    LS_ROOT = VALUE #( OBJECT_TYPE = I_TYPE
*                                     OBJECT_KEY   = COND #( WHEN I_TYPE = GC_EKPO
*                                                                            THEN <PO>-EBELN && <PO>-EBELP
*                                                                            WHEN I_TYPE = GC_EBAN
*                                                                            THEN <EB>-BANFN && <EB>-BNFPO ELSE SPACE ) ).
    TRY.
        CALL FUNCTION 'CUCB_CONFIGURATION_TO_DB'
          EXPORTING
            ROOT_INSTANCE                 = LS_DATA-INSTANCE
            ROOT_OBJECT                    =  LS_ROOT "DB /구매문서 번호+항번
          EXCEPTIONS
            INVALID_INSTANCE              = 1
            INVALID_ROOT_INSTANCE    = 2
            NO_CHANGES                      = 3
            ALREADY_REGISTERED_FOR_UPDATE = 4
            INSTANCE_IS_A_CLASSIFICATION  = 5
            OTHERS                                    = 6.

      CATCH CX_ROOT INTO LV_ERROR.
*ERROR->ROLLBACK&LOG SAVE
        CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

        CLEAR : LV_EXIST, LV_MSG.   LV_MSG = LV_ERROR->GET_TEXT( ).

        SELECT SINGLE @ABAP_TRUE
          FROM ZGTMMT9290
            INTO @LV_EXIST
            WHERE CUOBJ     = @LS_DATA-INSTANCE
                 AND PURTYPE = @I_TYPE.

          IF SY-SUBRC = 0.
              UPDATE ZGTMMT9290
                   SET TYPE = GC_E
                          MESSAGE = LV_MSG
              WHERE CUOBJ     = LS_DATA-INSTANCE
                   AND PURTYPE = I_TYPE.
          ELSE.
              LT_SAVE[] = VALUE #( FOR LS IN LT_ZGTMMT9290
                                ( VALUE #( BASE CORRESPONDING #( LS )
                                                  TYPE = GC_E
                                                  MESSAGE = LV_ERROR->GET_TEXT(  ) ) ) ).
              MODIFY ZGTMMT9290 FROM TABLE LT_SAVE.
          ENDIF.

        MTYPE     = GC_E.
        MESSAGE = LV_ERROR->GET_TEXT(  ).
        EXIT.
    ENDTRY.

*에러 없으면, COMMIT&LOG SAVE
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
        EXPORTING
           WAIT = 'X'.

    LT_SAVE[] = VALUE #( BASE LT_SAVE FOR LS IN LT_ZGTMMT9290
                      ( VALUE #( BASE CORRESPONDING #( LS )
                                        TYPE = GC_S
                                        MESSAGE = '특성 변경 성공'(M02) ) ) ).
    MODIFY ZGTMMT9290 FROM TABLE LT_SAVE.

    MTYPE = GC_S.
    MESSAGE = '특성 변경 성공'(M02) .

    CLEAR : LT_IBCO[], LT_SAVE[], LT_ZGTMMT9290[].
    UNASSIGN : <PO>, <EB>.

  ENDLOOP."입력받은 IT_PODATA(PO INSTANCE번호) LOOP 종료.


ENDFUNCTION.
