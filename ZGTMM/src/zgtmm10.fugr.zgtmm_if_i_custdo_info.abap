FUNCTION zgtmm_if_i_custdo_info.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(I_SYSTEM_ID) TYPE  ZGTE_IF_TARGET
*"     VALUE(I_BUKRS) TYPE  BUKRS
*"     VALUE(I_TYPE) TYPE  CHAR1
*"  EXPORTING
*"     VALUE(ZO_RESULT) TYPE  ZO_RESULT
*"     VALUE(ZO_MESSAGE) TYPE  ZO_MESSAGE
*"  TABLES
*"      IT_DODOC STRUCTURE  ZGTMMS4503
*"----------------------------------------------------------------------
*&---------------------------------------------------------------------*
*& 모듈          : MM
*& 프로그램 ID : ZGTMM_IF_I_CUSTDO_INFO
*& 프로그램 명 :  OEM 직납 거래명세서 발행 정보 수신(G-SRM->SAP)
*& 개요   : G-SRM에 등록된 거래명세서 정보(거래명세서 번호,출력일자,상태)를 수신받는 RFC
*& 생성일 : 2026.01.21
*& 생성자 : ZGODEV04
*&---------------------------------------------------------------------*
*& 외부 호출 프로그램 개요   : N/A
*& 타 시스템 인터페이스 개요 : G-SRM -> EAI -> SAP
*&---------------------------------------------------------------------*
*& 프로그램 수정이력
*&---------------------------------------------------------------------*
*& 수정일  :
*& 수정자  :
*& 수정개요:
*&---------------------------------------------------------------------*

  DATA : lt_del4403  LIKE TABLE OF zgtmmt4403,
         lt_del4405  LIKE TABLE OF zgtmmt4405,
         lt_save4403 LIKE TABLE OF zgtmmt4403,
         ls_save4403 TYPE zgtmmt4403,
         lt_save4405 LIKE TABLE OF zgtmmt4405,
         ls_save4405 TYPE zgtmmt4405,
         lv_date     TYPE datum,
         lv_msg      TYPE string.

*--전송 데이터 누락여부 확인
  IF i_system_id IS INITIAL OR i_bukrs IS INITIAL.

    zo_result    = gc_02.
    zo_message = '필수 값이 누락 되었습니다.'(e01).
    RETURN.
  ENDIF.

  IF it_dodoc[] IS INITIAL.

    zo_result    = gc_02.
    zo_message = '필수 값이 누락 되었습니다.'(e01).
    RETURN.

  ELSE.
*테이블 데이터 있더라도, 필수 필드 하나라도 누락 시, 리턴
    LOOP AT it_dodoc ASSIGNING FIELD-SYMBOL(<fs>).
*공통 필수 필드 체크
      IF <fs>-bukrs IS INITIAL OR <fs>-zreq_type IS INITIAL OR
          <fs>-dlvrq IS INITIAL OR <fs>-vbeln IS INITIAL OR
          <fs>-posnr IS INITIAL OR <fs>-zseq IS INITIAL.

        zo_result    = gc_02.
        zo_message = '요청 정보 중 필수 값이 누락 되었습니다.'(e04).
        RETURN.
      ENDIF.
*ZREQ_TYPE ='A:생산 예정품 직송 요청'인 경우,추가 필수 필드 체크
      IF <fs>-zreq_type = gc_a .
        IF <fs>-ebeln IS INITIAL OR <fs>-ebelp IS INITIAL.

          zo_result    = gc_02.
          zo_message = '요청 정보 중 필수 값이 누락 되었습니다.'(e04).
          RETURN.
        ENDIF.
      ENDIF.
**I_TYPE ='B:거래명세서등록'인 경우, 추가 필수 필드 체크
*      IF i_type = gc_b .
*        IF <fs>-zdoc_no IS INITIAL OR <fs>-zdoc_item_no IS INITIAL OR
*            <fs>-delno IS INITIAL OR <fs>-delitem IS INITIAL.
*
*          zo_result    = gc_02.
*          zo_message = '요청 정보 중 필수 값이 누락 되었습니다.'(e04).
*          RETURN.
*        ENDIF.
*      ENDIF.
    ENDLOOP.
  ENDIF.

**기존 데이터 가져오기.
  SELECT FROM zgtmmt4403
    FIELDS *
    FOR ALL ENTRIES IN @it_dodoc
    WHERE bukrs = @it_dodoc-bukrs
         AND zreq_type = @gc_a
         AND dlvrq = @it_dodoc-dlvrq
         AND vbeln = @it_dodoc-vbeln
         AND posnr = @it_dodoc-posnr
         AND ebeln = @it_dodoc-ebeln
         AND ebelp = @it_dodoc-ebelp
         AND zseq = @it_dodoc-zseq
         INTO TABLE @DATA(lt_4403_a).
  SORT lt_4403_a BY bukrs zreq_type dlvrq
                                 vbeln posnr ebeln ebelp zseq.

  SELECT FROM zgtmmt4405
    FIELDS *
    FOR ALL ENTRIES IN @it_dodoc
    WHERE bukrs = @it_dodoc-bukrs
         AND zreq_type = @gc_b
         AND dlvrq = @it_dodoc-dlvrq
         AND vbeln = @it_dodoc-vbeln
         AND posnr = @it_dodoc-posnr
         AND zseq = @it_dodoc-zseq
         INTO TABLE @DATA(lt_4405_b).
  SORT lt_4405_b BY bukrs zreq_type dlvrq
                                 vbeln posnr zseq.

*I_TYPE 구분에 따른 저장_ZGTMMT4403(직송 의뢰 요청 배차 정보)
  LOOP AT it_dodoc ASSIGNING FIELD-SYMBOL(<fsa>).
    IF <fsa>-zreq_type = gc_a.

      READ TABLE lt_4403_a INTO DATA(ls_4403)
      WITH KEY bukrs = <fsa>-bukrs
                     zreq_type = <fsa>-zreq_type
                     dlvrq = <fsa>-dlvrq
                     vbeln = <fsa>-vbeln
                     posnr = <fsa>-posnr
                     ebeln = <fsa>-ebeln
                     ebelp = <fsa>-ebelp
                     zseq  = <fsa>-zseq BINARY SEARCH.

         IF sy-subrc = 0.
           CASE i_type.
               "거래명세서 등록/거래명세서 삭제
             WHEN gc_b.
               ls_save4403 = CORRESPONDING #( ls_4403 ).

               ls_save4403-zdoc_no = COND #( WHEN i_type = gc_b
                                                               THEN <fsa>-zdoc_no ELSE '' ).
               ls_save4403-zdoc_item_no = COND #( WHEN i_type = gc_b
                                                                        THEN <fsa>-zdoc_item_no ELSE '' ).
               ls_save4403-printyn = gc_y.
               CLEAR lv_date.
               ls_save4403-zdoc_date = COND #( WHEN i_type = gc_b THEN sy-datum ELSE lv_date ).
               ls_save4403-aedat = sy-datum.
               ls_save4403-aedat_local = sy-datlo.
               ls_save4403-aetim = sy-uzeit.
               ls_save4403-aetim_local = sy-timlo.
               ls_save4403-aenam = sy-uname.
               APPEND ls_save4403 TO lt_save4403.

               "배차삭제
             WHEN gc_c OR gc_d.
               ls_save4403 = CORRESPONDING #( <fsa> ).
               APPEND ls_save4403 TO lt_del4403.

             WHEN OTHERS.
           ENDCASE.
         ENDIF.

    ELSEIF <fsa>-zreq_type = gc_b.

      READ TABLE lt_4405_b INTO DATA(ls_4405)
      WITH KEY bukrs = <fsa>-bukrs
                     zreq_type = <fsa>-zreq_type
                     dlvrq = <fsa>-dlvrq
                     vbeln = <fsa>-vbeln
                     posnr = <fsa>-posnr
                     zseq   = <fsa>-zseq BINARY SEARCH.

          IF sy-subrc = 0.
            CASE i_type.
                "거래명세서 등록/거래명세서 삭제
              WHEN gc_b .
                ls_save4405 = CORRESPONDING #( ls_4405 ).

                ls_save4405-zdoc_no = COND #( WHEN i_type = gc_b
                                                                THEN <fsa>-zdoc_no ELSE '' ).
                ls_save4405-zdoc_item_no = COND #( WHEN i_type = gc_b
                                                                         THEN <fsa>-zdoc_item_no ELSE '' ).
               ls_save4405-printyn = gc_y.
                CLEAR lv_date.
                ls_save4405-zdoc_date = COND #( WHEN i_type = gc_b THEN sy-datum ELSE lv_date ).
                ls_save4405-aedat = sy-datum.
                ls_save4405-aedat_local = sy-datlo.
                ls_save4405-aetim = sy-uzeit.
                ls_save4405-aetim_local = sy-timlo.
                ls_save4405-aenam = sy-uname.
                APPEND ls_save4405 TO lt_save4405.

                "배차삭제
              WHEN gc_c OR gc_d.
                ls_save4405 = CORRESPONDING #( <fsa> ).
                APPEND ls_save4405 TO lt_del4405.

              WHEN OTHERS.
            ENDCASE.
          ENDIF.

    ENDIF.

*    IF SY-SUBRC = 0.
*      CASE I_TYPE.
*          "거래명세서 등록/거래명세서 삭제
*        WHEN GC_B OR GC_D.
*          LS_SAVE = CORRESPONDING #( LS_4403 ).
*
*          LS_SAVE-ZDOC_NO = COND #( WHEN I_TYPE = GC_B
*                                                          THEN <FSA>-ZDOC_NO ELSE '' ).
*          LS_SAVE-ZDOC_ITEM_NO = COND #( WHEN I_TYPE = GC_B
*                                                                   THEN <FSA>-ZDOC_ITEM_NO ELSE '' ).
*          CLEAR LV_DATE.
*          LS_SAVE-ZDOC_DATE = COND #( WHEN I_TYPE = GC_B THEN SY-DATUM ELSE LV_DATE ).
*          LS_SAVE-AEDAT = SY-DATUM.
*          LS_SAVE-AEDAT_LOCAL = SY-DATLO.
*          LS_SAVE-AETIM = SY-UZEIT.
*          LS_SAVE-AETIM_LOCAL = SY-TIMLO.
*          LS_SAVE-AENAM = SY-UNAME.
*          APPEND LS_SAVE TO LT_SAVE.
*
*          "배차삭제
*        WHEN GC_C.
*          LS_SAVE = CORRESPONDING #( <FSA> ).
*          APPEND LS_SAVE TO LT_DEL.
*
*        WHEN OTHERS.
*      ENDCASE.
*    ENDIF.
*
    CLEAR : LS_SAVE4403, LS_4403,LS_SAVE4405, LS_4405.
  ENDLOOP.

    IF lt_save4403[] IS NOT INITIAL.
      MODIFY zgtmmt4403 FROM TABLE lt_save4403.
    ENDIF.

    IF lt_save4405[] IS NOT INITIAL.
      MODIFY zgtmmt4405 FROM TABLE lt_save4405.
    ENDIF.

    IF lt_del4403[] IS NOT INITIAL.
      DELETE zgtmmt4403 FROM TABLE lt_del4403.
    ENDIF.

    IF lt_del4405[] IS NOT INITIAL.
      DELETE zgtmmt4405 FROM TABLE lt_del4405.
    ENDIF.

    IF sy-subrc = 0.
      COMMIT WORK AND WAIT.
      zo_result    = gc_00."NUMBER 00
      zo_message = '직송 요청 상태가 변경 되었습니다.'(m08) .
    ELSE.
      zo_result    = gc_02.
      zo_message = '직송 요청 등록이 실패하었습니다.'(e09) .
    ENDIF.


**DATA SAVE_ZGTMMT4411
**기존 데이터 가져오기.
*  SELECT FROM ZGTMMT4411
*    FIELDS *
*    FOR ALL ENTRIES IN @IT_DODOC
*    WHERE BUKRS = @IT_DODOC-BUKRS
*         AND DLVRQ = @IT_DODOC-DLVRQ
*         AND VBELN = @IT_DODOC-VBELN
*         AND POSNR = @IT_DODOC-POSNR
*         AND EBELN = @IT_DODOC-EBELN
*         AND EBELP = @IT_DODOC-EBELP
*         INTO CORRESPONDING FIELDS OF TABLE @LT_4411.
*
*    IF LT_4411[] IS INITIAL.
*        ZO_RESULT    = GC_02."NUMBER 00
*        ZO_MESSAGE = '조건에 맞는 기존 거래명세서 데이터가 없습니다.'(E07) .
*
*    ELSE.
*        SORT IT_DODOC BY BUKRS DLVRQ VBELN POSNR EBELN EBELP.
*
*        LOOP AT LT_4411 ASSIGNING FIELD-SYMBOL(<FS1>).
*
*           READ TABLE IT_DODOC INTO DATA(LS_DOC) WITH KEY BUKRS = <FS1>-BUKRS
*                                                                                             DLVRQ = <FS1>-DLVRQ
*                                                                                             VBELN = <FS1>-VBELN
*                                                                                             POSNR = <FS1>-POSNR
*                                                                                             EBELN = <FS1>-EBELN
*                                                                                             EBELP = <FS1>-EBELP BINARY SEARCH.
*           IF SY-SUBRC = 0.
*                <FS1>-ZDOC_STAT     = LS_DOC-ZDOC_STAT.
*                <FS1>-ZDOC_NO        = COND #( WHEN LS_DOC-ZDOC_STAT = 'X' THEN LS_DOC-ZDOC_NO ELSE SPACE ).
*                <FS1>-ZDOC_TRTYPE = COND #( WHEN LS_DOC-ZDOC_STAT = 'X' THEN LS_DOC-ZDOC_TRTYPE ELSE SPACE ).
*                <FS1>-ZDOC_DATE     = SY-DATLO.
*                <FS1>-AEDAT             = SY-DATUM.
*                <FS1>-AEDAT_LOCAL = SY-DATLO.
*                <FS1>-AETIM              = SY-UZEIT.
*                <FS1>-AETIM_LOCAL  = SY-TIMLO.
*                <FS1>-AENAM            = SY-UNAME.
*           ENDIF.
*
*           CLEAR LS_DOC.
*        ENDLOOP.

**저장
*    TRY.
*       MODIFY ZGTMMT4411 FROM TABLE LT_4411.
*
**EXPORT 구성
*       IF SY-SUBRC = 0.
*          COMMIT WORK AND WAIT .
*          ZO_RESULT    = GC_00."NUMBER 00
*          ZO_MESSAGE = '직송 요청 상태가 변경 되었습니다.'(M08) .
*       ENDIF.
*
*       CATCH CX_ROOT INTO DATA(LV_ERROR).
*           LV_MSG = LV_ERROR->GET_TEXT(  ).
*           ZO_MESSAGE = COND #( WHEN LV_MSG IS INITIAL
*                                                  THEN '직송 요청 등록이 실패하였습니다.'(M12) ELSE LV_MSG ).
*           ZO_RESULT    = GC_02. "02
*    ENDTRY.
*  ENDIF.


  ENDFUNCTION.
