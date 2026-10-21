FUNCTION zgtmm_if_i_app_req.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(I_SYSTEM_ID) TYPE  ZGTE_IF_TARGET
*"     VALUE(I_BUKRS) TYPE  BUKRS
*"  EXPORTING
*"     VALUE(ZO_RESULT) TYPE  ZO_RESULT
*"     VALUE(ZO_MESSAGE) TYPE  ZO_MESSAGE
*"  TABLES
*"      IT_CHANGE STRUCTURE  ZGTMMS4501
*"----------------------------------------------------------------------
*&---------------------------------------------------------------------*
*& 모듈          : MM
*& 프로그램 ID : ZGTMM_IF_I_APP_REQ
*& 프로그램 명 :  OEM 직납 승인 공통 FUNCTION(G-SRM->SAP)
*& 개요   : OEM 직송 의뢰에 대해 승인하는 RFC 개발
*& 생성일 : 2026.01.14
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

  DATA : lt_4411     LIKE TABLE OF zgtmmt4411,
         lt_save4411 LIKE TABLE OF zgtmmt4411,
         ls_save4411 TYPE zgtmmt4411,
         lt_4412     LIKE TABLE OF zgtmmt4412,
         lt_save4412 LIKE TABLE OF zgtmmt4412,
         ls_save4412 TYPE zgtmmt4412,
         lv_msg      TYPE string,
         lv_mail_err TYPE string.       "메일 발송 오류 메시지
  CLEAR : ls_save4411, lt_save4411, ls_save4412, lt_save4412.

  DATA : BEGIN OF ls_list_m,
           zreq_type TYPE zgtmms4501-zreq_type,
           email     TYPE zgtmm_cv_get_ddinfo-email,
           dlvrq     TYPE zgtmms4501-dlvrq,
           vbeln     TYPE zgtmms4501-vbeln,
           posnr     TYPE zgtmms4501-posnr,
           ebeln     TYPE zgtmms4501-ebeln,
           ebelp     TYPE zgtmms4501-ebelp,
           maktx     TYPE zgtmm_cv_get_ddinfo-maktx,
           length    TYPE zgtmm_cv_get_ddinfo-length,
           color     TYPE zgtmm_cv_get_ddinfo-color,
           req_drqty TYPE zgtmm_cv_get_ddinfo-req_drqty,
           ar_date   TYPE zgtmm_cv_get_ddinfo-ar_date,
           zmemo     TYPE zgtmms4501-zmemo,
         END OF ls_list_m.

  DATA : BEGIN OF ls_list_t,
           zreq_type TYPE zgtmms4501-zreq_type,
           dlvrq     TYPE zgtmms4501-dlvrq,
           vbeln     TYPE zgtmms4501-vbeln,
           posnr     TYPE zgtmms4501-posnr,
           ebeln     TYPE zgtmms4501-ebeln,
           ebelp     TYPE zgtmms4501-ebelp,
         END OF ls_list_t.

  DATA:
    lv_check       TYPE c LENGTH 1,
    lo_receiver    TYPE REF TO if_recipient_bcs,
    lo_email       TYPE REF TO cl_bcs,
    lo_email_body  TYPE REF TO cl_document_bcs,
    lx_exception   TYPE REF TO cx_bcs,
    lv_send_result TYPE c.

  DATA:
    lv_email     TYPE ad_smtpadr,
    lv_head_text TYPE so_obj_des.

  DATA : gt_list_m LIKE TABLE OF ls_list_m,
         gt_list_t LIKE TABLE OF ls_list_t.

*--I/F 로그 시작 (ZGTMMT9000) - 로그 오류는 인터페이스에 영향 없음
  TRY.
    gv_system_id = i_system_id.
    LOOP AT it_change ASSIGNING FIELD-SYMBOL(<fs_input_log>).
      lv_msg = lv_msg && |[{ <fs_input_log>-zreq_type }/{ <fs_input_log>-dlvrq }/{ <fs_input_log>-ztype }]|.
    ENDLOOP.
    PERFORM set_com_log USING 'S' 'MM00040' '' lv_msg gs_9000.
    CLEAR lv_msg.
  CATCH cx_root.
  ENDTRY.

*--전송 데이터 누락여부 확인
  IF i_system_id IS INITIAL OR i_bukrs IS INITIAL.

    zo_result    = gc_02.
    zo_message = '필수 값이 누락 되었습니다.'(e01).
    RETURN.
  ENDIF.

  IF it_change[] IS INITIAL.

    zo_result    = gc_02.
    zo_message = '필수 값이 누락 되었습니다.'(e01).
    RETURN.

  ELSE.
*테이블 데이터 있더라도, 필수 필드 하나라도 누락 시, 리턴
*1.아래 6개 필드는 공통 필수 체크
    IF line_exists( it_change[ bukrs = '' ] )  OR
        line_exists( it_change[ zreq_type = '' ] )  OR
        line_exists( it_change[ dlvrq = '' ] )  OR
        line_exists( it_change[ vbeln = '' ] ) OR
        line_exists( it_change[ posnr = '' ] ) OR
        line_exists( it_change[ ztype = '' ] )   .


      zo_result    = gc_02.
      zo_message = '필수 값이 누락 되었습니다.'(e01).
      RETURN.
*    ELSE.
*      DATA(lt_ch) = it_change[].
*      DELETE lt_ch WHERE zreq_type NE gc_a.
*
*      IF lt_ch[] IS NOT INITIAL.
**2.직송유형이 A(생산 예정품 직송 요청)인 경우에는 아래 두개 필드 필수 추가 체크
*        IF line_exists( it_change[ ebeln = '' ] ) OR
*            line_exists( it_change[ ebelp = '' ] ) .
*
*          zo_result    = gc_02.
*          zo_message = '요청 정보 중 필수 값이 누락 되었습니다.'(e04).
*          RETURN.
*        ENDIF.
*      ENDIF.

    ENDIF.

  ENDIF.

*--DATA SAVE_ZGTMMT4411
*기존 데이터 가져오기.
  SELECT FROM zgtmmt4411
    FIELDS *
    FOR ALL ENTRIES IN @it_change
    WHERE bukrs = @it_change-bukrs
         AND dlvrq = @it_change-dlvrq
         AND vbeln = @it_change-vbeln
         AND posnr = @it_change-posnr
         AND ebeln = @it_change-ebeln
         AND ebelp = @it_change-ebelp
        INTO TABLE @lt_4411.
  SORT lt_4411 BY bukrs dlvrq vbeln posnr ebeln ebelp.

  SELECT FROM zgtmmt4412
    FIELDS *
    FOR ALL ENTRIES IN @it_change
    WHERE bukrs = @it_change-bukrs
         AND dlvrq = @it_change-dlvrq
         AND vbeln = @it_change-vbeln
         AND posnr = @it_change-posnr
        INTO TABLE @lt_4412.
  SORT lt_4412 BY bukrs dlvrq vbeln posnr.


  IF lt_4411[] IS NOT INITIAL.
*영업 출하지시 요청정보 조회_반려의 경우 업데이트 위함.
    SELECT FROM zlet0401
     FIELDS *
     FOR ALL ENTRIES IN @it_change
     WHERE dlvrq = @it_change-dlvrq
          AND vbeln = @it_change-vbeln
          AND posnr = @it_change-posnr
          AND lvorm IS INITIAL
         INTO TABLE @DATA(lt_0401).
    SORT lt_0401 BY dlvrq vbeln posnr.

    LOOP AT it_change ASSIGNING FIELD-SYMBOL(<fs>) WHERE zreq_type =  gc_a.
      READ TABLE lt_4411 INTO DATA(ls_4411)
      WITH KEY bukrs = <fs>-bukrs
                     dlvrq = <fs>-dlvrq
                     vbeln = <fs>-vbeln
                     posnr = <fs>-posnr
                     ebeln = <fs>-ebeln
                     ebelp = <fs>-ebelp BINARY SEARCH.

      IF <fs>-ztype = gc_r.   "반려
        READ TABLE lt_0401 TRANSPORTING NO FIELDS
        WITH KEY dlvrq = <fs>-dlvrq
                       vbeln = <fs>-vbeln
                       posnr = <fs>-posnr BINARY SEARCH.
        IF sy-subrc = 0.

          UPDATE zlet0401 SET lvorm = gc_x
          WHERE dlvrq = <fs>-dlvrq
               AND vbeln = <fs>-vbeln
               AND posnr = <fs>-posnr.

        ENDIF.

        CLEAR : ls_list_t .
        ls_list_t = CORRESPONDING #( <fs> ).
        APPEND ls_list_t  TO gt_list_t.

      ENDIF.

      CASE i_system_id.
        WHEN 'KSRM'.
          ls_save4411 = VALUE #( BASE CORRESPONDING #( ls_4411 )
                                        zvd_stat = <fs>-ztype
                                        zvd_date = sy-datlo
                                        zvd_time = sy-timlo
                                        rej_code = <fs>-zmemo
                                        per_name = <fs>-per_name
                                        aedat = sy-datum
                                        aetim  = sy-uzeit
                                        aenam = sy-uname
                                        aedat_local = sy-datlo
                                        aetim_local  = sy-timlo ) .

        WHEN 'SAP'.
          ls_save4411 = VALUE #( BASE CORRESPONDING #( ls_4411 )
                                        zmm_stat = <fs>-ztype
                                        rej_code = <fs>-zmemo
                                        aedat = sy-datum
                                        aetim  = sy-uzeit
                                        aenam = sy-uname
                                        aedat_local = sy-datlo
                                        aetim_local  = sy-timlo ).

        WHEN OTHERS.
          CONTINUE.
      ENDCASE.
      APPEND ls_save4411 TO lt_save4411.
      CLEAR : ls_save4411, ls_4411.

    ENDLOOP.

  ENDIF.

  IF lt_4412[] IS NOT INITIAL.
*영업 출하지시 요청정보 조회_반려의 경우 업데이트 위함.
    SELECT FROM zlet0401
     FIELDS *
     FOR ALL ENTRIES IN @it_change
     WHERE dlvrq = @it_change-dlvrq
          AND vbeln = @it_change-vbeln
          AND posnr = @it_change-posnr
          AND lvorm IS INITIAL
         INTO TABLE @DATA(lt_0401_1).
    SORT lt_0401_1 BY dlvrq vbeln posnr.

    LOOP AT it_change ASSIGNING FIELD-SYMBOL(<fs2>) WHERE zreq_type =  gc_B.
      READ TABLE lt_4412 INTO DATA(ls_4412)
      WITH KEY bukrs = <fs2>-bukrs
                     dlvrq = <fs2>-dlvrq
                     vbeln = <fs2>-vbeln
                     posnr = <fs2>-posnr BINARY SEARCH.

      IF <fs2>-ztype = gc_r.   "반려
        READ TABLE lt_0401_1 TRANSPORTING NO FIELDS
        WITH KEY dlvrq = <fs2>-dlvrq
                       vbeln = <fs2>-vbeln
                       posnr = <fs2>-posnr BINARY SEARCH.
        IF sy-subrc = 0.

          UPDATE zlet0401 SET lvorm = gc_x
          WHERE dlvrq = <fs2>-dlvrq
               AND vbeln = <fs2>-vbeln
               AND posnr = <fs2>-posnr.

        ENDIF.
        CLEAR : ls_list_t .
        ls_list_t = CORRESPONDING #( <fs2> ).
        APPEND ls_list_t  TO gt_list_t.
      ENDIF.

      CASE i_system_id.
        WHEN 'KSRM'.
          ls_save4412 = VALUE #( BASE CORRESPONDING #( ls_4412 )
                                        zvd_stat = <fs2>-ztype
                                        zvd_date = sy-datlo
                                        zvd_time = sy-timlo
                                        rej_code = <fs2>-zmemo
                                        per_name = <fs2>-per_name
                                        aedat = sy-datum
                                        aetim  = sy-uzeit
                                        aenam = sy-uname
                                        aedat_local = sy-datlo
                                        aetim_local  = sy-timlo ) .

        WHEN 'SAP'.
          ls_save4412 = VALUE #( BASE CORRESPONDING #( ls_4412 )
                                        zmm_stat = <fs2>-ztype
                                        rej_code = <fs2>-zmemo
                                        aedat = sy-datum
                                        aetim  = sy-uzeit
                                        aenam = sy-uname
                                        aedat_local = sy-datlo
                                        aetim_local  = sy-timlo ).

        WHEN OTHERS.
          CONTINUE.
      ENDCASE.
      APPEND ls_save4412 TO lt_save4412.
      CLEAR : ls_save4412, ls_4412.

    ENDLOOP.

  ENDIF.

  IF lt_save4411[] IS INITIAL AND lt_save4412[] IS INITIAL.
    zo_result    = gc_02."NUMBER 00
    zo_message = '조건에 맞는 기존 직송 데이터가 없습니다.'(e06) .
  ELSE.
    IF lt_save4411[] IS NOT INITIAL.
      TRY.
          MODIFY zgtmmt4411 FROM TABLE lt_save4411.

*--EXPORT 구성
          IF sy-subrc = 0.
            COMMIT WORK AND WAIT .
            zo_result    = gc_00."NUMBER 00
            zo_message = '직송 요청 상태가 변경 되었습니다.'(m08) .
          ENDIF.

        CATCH cx_root INTO DATA(lv_error).
*             LV_MSG = LV_ERROR->GET_TEXT(  ).
          zo_message = lv_error->get_text(  ).
          zo_result    = gc_02. "02
      ENDTRY.

    ENDIF.

    IF lt_save4412[] IS NOT INITIAL.
      TRY.
          MODIFY zgtmmt4412 FROM TABLE lt_save4412.

*--EXPORT 구성
          IF sy-subrc = 0.
            COMMIT WORK AND WAIT .
            zo_result    = gc_00."NUMBER 00
            zo_message = '직송 요청 상태가 변경 되었습니다.'(m08) .
          ENDIF.

        CATCH cx_root INTO DATA(lv_error2).
*             LV_MSG = LV_ERROR->GET_TEXT(  ).
          zo_message = lv_error2->get_text(  ).
          zo_result    = gc_02. "02
      ENDTRY.
    ENDIF.

  ENDIF.

  IF gt_list_t[] IS NOT INITIAL.

    WAIT UP TO '1' SECONDS.

    DATA lt_list_a LIKE gt_list_t.
    DATA lt_list_b LIKE gt_list_t.
    LOOP AT gt_list_t ASSIGNING FIELD-SYMBOL(<fs_split>).
      IF <fs_split>-zreq_type = gc_a.
        APPEND <fs_split> TO lt_list_a.
      ELSEIF <fs_split>-zreq_type = gc_b.
        APPEND <fs_split> TO lt_list_b.
      ENDIF.
    ENDLOOP.

    IF lt_list_a IS NOT INITIAL.
      SELECT zreq_type, email, vbeln, posnr, maktx, length, color, req_drqty, ar_date, rej_code AS zmemo
      FROM zgtmm_cv_get_ddinfo
      FOR ALL ENTRIES IN @lt_list_a
      WHERE zreq_type = @lt_list_a-zreq_type
          AND dlvrq  = @lt_list_a-dlvrq
          AND vbeln  = @lt_list_a-vbeln
          AND posnr  = @lt_list_a-posnr
          AND ebeln  = @lt_list_a-ebeln
          AND ebelp  = @lt_list_a-ebelp
      APPENDING CORRESPONDING FIELDS OF TABLE @gt_list_m.
    ENDIF.

    IF lt_list_b IS NOT INITIAL.
      SELECT zreq_type, email, vbeln, posnr, maktx, length, color, req_drqty, ar_date, rej_code AS zmemo
      FROM zgtmm_cv_get_ddinfo
      FOR ALL ENTRIES IN @lt_list_b
      WHERE zreq_type = @lt_list_b-zreq_type
          AND dlvrq  = @lt_list_b-dlvrq
          AND vbeln  = @lt_list_b-vbeln
          AND posnr  = @lt_list_b-posnr
      APPENDING CORRESPONDING FIELDS OF TABLE @gt_list_m.
    ENDIF.

    SORT gt_list_m BY zreq_type email dlvrq vbeln posnr.

    DATA:
      lv_line TYPE so_text255,
      lt_body TYPE bcsy_text.

    LOOP AT gt_list_m ASSIGNING FIELD-SYMBOL(<item>).
      AT NEW zreq_type.
        CASE <item>-zreq_type.
          WHEN gc_a.
            lv_head_text = '직송요청이 반려되었습니다.'(m31).
          WHEN gc_b.
            lv_head_text = '매입보관품 직송요청이 반려되었습니다.'(m32).
        ENDCASE.
      ENDAT.
      AT NEW email.

        lv_line = |<html><body style="font-size:14">|.
        lt_body = VALUE #( BASE lt_body ( line = lv_line ) ).
        lv_line = |<p>{ TEXT-em1 }</p>|.

        lt_body = VALUE #( BASE lt_body ( line = lv_line ) ).
        lv_line = |<p>아래와 같이 직송요청이 반려되었습니다.</p>|.
        lt_body = VALUE #( BASE lt_body ( line = lv_line ) ).

        lv_line = |<table border=1 STYLE="border-collapse: collapse;border-color: #000000;font-size:11:width:1200px" >|.
        lt_body = VALUE #( BASE lt_body ( line = lv_line ) ).

        lv_line = |<tr align="center" style="background-color: #ADD8E6;height : 50px;" ><td width="100px"><strong>판매오더</strong></td>|.
        lt_body = VALUE #( BASE lt_body ( line = lv_line ) ).
        lv_line = |<td width="50px" ><strong>항번</strong></td>|.
        lt_body = VALUE #( BASE lt_body ( line = lv_line ) ).
        lv_line = |<td width="400px" ><strong>품명</strong></td>|.
        lt_body = VALUE #( BASE lt_body ( line = lv_line ) ).
        lv_line = |<td width="50px" ><strong>색상</strong></td>|.
        lt_body = VALUE #( BASE lt_body ( line = lv_line ) ).
        lv_line = |<td width="100px" ><strong>조장</strong></td>|.
        lt_body = VALUE #( BASE lt_body ( line = lv_line ) ).
        lv_line = |<td width="100px" ><strong>직송요청수량</strong></td>|.
        lt_body = VALUE #( BASE lt_body ( line = lv_line ) ).
        lv_line = |<td width="100px" ><strong>도착요청일</strong></td>|.
        lt_body = VALUE #( BASE lt_body ( line = lv_line ) ).
        lv_line = |<td width="200px" ><strong>반려사유</strong></td>|.
        lt_body = VALUE #( BASE lt_body ( line = lv_line ) ).
      ENDAT.
       lv_line = |<tr><td align="center" >{ <item>-vbeln  ALPHA = OUT }</td>|.
       lt_body = VALUE #( BASE lt_body ( line = lv_line ) ).
       lv_line = |<td align="center" >{ <item>-posnr ALPHA = OUT }</td>|.
       lt_body = VALUE #( BASE lt_body ( line = lv_line ) ).
       lv_line = |<td align="center" >{ <item>-maktx ALPHA = OUT }</td>|.
       lt_body = VALUE #( BASE lt_body ( line = lv_line ) ).
       lv_line = |<td align="center" >{ <item>-color ALPHA = OUT }</td>|.
       lt_body = VALUE #( BASE lt_body ( line = lv_line ) ).
       lv_line = |<td align="center" >{ <item>-length ALPHA = OUT }</td>|.
       lt_body = VALUE #( BASE lt_body ( line = lv_line ) ).
       lv_line = |<td align="center" >{ <item>-req_drqty  }</td>|.
       lt_body = VALUE #( BASE lt_body ( line = lv_line ) ).
       lv_line = |<td align="center" >{ <item>-ar_date }</td>|.
       lt_body = VALUE #( BASE lt_body ( line = lv_line ) ).
       lv_line = |<td align="center" >{ <item>-zmemo }</td>|.
       lt_body = VALUE #( BASE lt_body ( line = lv_line ) ).
      AT END OF email.
        lv_line = |</table></body></html>|.
        lt_body = VALUE #( BASE lt_body ( line = lv_line ) ).

        lv_email =  <item>-email.

        TRY.
            lo_email = cl_bcs=>create_persistent( ).

            lo_email_body = cl_document_bcs=>create_document(
                            i_type    = 'HTM'
                            i_text    = lt_body
                            i_subject = lv_head_text ).

            lo_email->set_document( lo_email_body ).

            lo_receiver =
            cl_cam_address_bcs=>create_internet_address( lv_email ).

            lo_email->add_recipient( i_recipient = lo_receiver
                                     i_express = 'X' ).

            lo_email->set_send_immediately( 'X' ).

            lo_email->send( EXPORTING i_with_error_screen = 'X'
                            RECEIVING result = lv_send_result ).
          CATCH cx_bcs INTO lx_exception.
            lv_check = gc_e.
            lv_mail_err = |[요청자메일오류] { lv_email } : { lx_exception->get_text( ) }|.
        ENDTRY.
        COMMIT WORK AND WAIT.
        CLEAR : lv_check,    lo_receiver ,  lo_email ,  lo_email_body ,  lx_exception  ,    lv_send_result.

        CLEAR : lv_email.

        SELECT email
        FROM zgtmmt1024
          INTO TABLE @DATA(LT_email_T).

        LOOP AT lt_email_t ASSIGNING FIELD-SYMBOL(<mail>).

          CLEAR : lv_email.
          lv_email =  <mail>-email..

          TRY.
              lo_email = cl_bcs=>create_persistent( ).

              lo_email_body = cl_document_bcs=>create_document(
                              i_type    = 'HTM'
                              i_text    = lt_body
                              i_subject = lv_head_text ).

              lo_email->set_document( lo_email_body ).

              lo_receiver =
              cl_cam_address_bcs=>create_internet_address( lv_email ).

              lo_email->add_recipient( i_recipient = lo_receiver
                                       i_express = 'X' ).

              lo_email->set_send_immediately( 'X' ).

              lo_email->send( EXPORTING i_with_error_screen = 'X'
                              RECEIVING result = lv_send_result ).
            CATCH cx_bcs INTO lx_exception.
              lv_check = gc_e.
              IF lv_mail_err IS INITIAL.
                lv_mail_err = |[관리자메일오류] { lv_email } : { lx_exception->get_text( ) }|.
              ENDIF.
          ENDTRY.
          COMMIT WORK AND WAIT.
          CLEAR : lv_check,    lo_receiver ,  lo_email ,  lo_email_body ,  lx_exception  ,    lv_send_result.
          CLEAR : lv_msg, lv_email.
        ENDLOOP.
        CLEAR : lt_body.   "관리자 메일 전송 완료 후 초기화 (LOOP 안에서 초기화시 2번째 관리자부터 빈 본문 발송)
      ENDAT.

    ENDLOOP.
  ENDIF.

*--I/F 로그 종료 (ZGTMMT9000) - 로그 오류는 인터페이스에 영향 없음
  TRY.
    IF lv_mail_err IS NOT INITIAL.
      PERFORM set_com_log USING 'E' 'MM00040' 'E' lv_mail_err gs_9000.
    ELSEIF zo_result = gc_00.
      DATA : lt_elog LIKE TABLE OF zgtmms4501,
             lv_cnt  TYPE i.
      lt_elog = it_change[].
      SORT lt_elog BY zreq_type dlvrq ztype.
      LOOP AT lt_elog ASSIGNING FIELD-SYMBOL(<fs_elog>).
        AT NEW dlvrq.
          lv_cnt = 0.
        ENDAT.
        lv_cnt = lv_cnt + 1.
        AT END OF dlvrq.
          lv_msg = lv_msg && |[{ <fs_elog>-zreq_type }/{ <fs_elog>-dlvrq }/{ <fs_elog>-ztype }({ lv_cnt }건)]|.
        ENDAT.
      ENDLOOP.
      lv_msg = |직송상태변경{ lv_msg }|.
      PERFORM set_com_log USING 'E' 'MM00040' 'S' lv_msg gs_9000.
    ELSE.
      PERFORM set_com_log USING 'E' 'MM00040' 'E' zo_message gs_9000.
    ENDIF.
  CATCH cx_root.
  ENDTRY.

ENDFUNCTION.
