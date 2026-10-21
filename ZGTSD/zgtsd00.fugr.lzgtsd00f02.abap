*----------------------------------------------------------------------*
***INCLUDE LZGTSD00F02.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form GO_KATALK_CHK_IMPORT_value.
*&---------------------------------------------------------------------*
FORM go_katalk_chk_import_value  USING    pi_corpnum
                                          pi_template
                                          pi_sender
                                          pi_receiver
                                          ps_content   LIKE zgtsdsif6000
                                 CHANGING pe_type
                                          pe_msg.

**.
* 1. Check Template Code.
  IF pi_template IS INITIAL.
    pe_type = 'E'.
*   카카오 알림톡 템플릿 코드가 입력되지 않았습니다.
    pe_msg  = TEXT-e02.

  ENDIF.

  CHECK: pe_type IS INITIAL.

* 2. Read Template Code from Common code Table.
  SELECT SINGLE *  INTO @DATA(ls_code)
    FROM zgtppt1010  WHERE module_kind EQ 'SD'
                       AND codegrp     EQ '6001'
                       AND fld_02      EQ @pi_template.

  IF sy-subrc NE 0 OR
     ls_code IS INITIAL.
    pe_type = 'E'.
*   템플릿 정보가 등록되지 않았습니다.
    pe_msg  = TEXT-e03.

  ELSE.
* 3. Check Requir Field.
    PERFORM go_katalk_check_req_field
      USING: '1' ls_code  ps_content-sales_employee  CHANGING  pe_type  pe_msg,
             '2' ls_code  ps_content-cust_name       CHANGING  pe_type  pe_msg,
             '3' ls_code  ps_content-delv_note       CHANGING  pe_type  pe_msg,
             '4' ls_code  ps_content-cust_manager    CHANGING  pe_type  pe_msg,
             '5' ls_code  ps_content-delv_adrs       CHANGING  pe_type  pe_msg,
             '6' ls_code  ps_content-plate_no        CHANGING  pe_type  pe_msg,
             '7' ls_code  ps_content-driver_name     CHANGING  pe_type  pe_msg,
             '8' ls_code  ps_content-driver_telno    CHANGING  pe_type  pe_msg.

  ENDIF.

  CLEAR: ls_code.
**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form GO_KATALK_CHECK_REQ_FIELD
*&---------------------------------------------------------------------*
FORM go_katalk_check_req_field  USING    pi_type
                                         ps_code  LIKE zgtppt1010
                                         pi_value
                                CHANGING pe_type
                                         pe_msg.

  DATA: lv_text  TYPE fieldname.

**
  CHECK: pe_type IS INITIAL.

  DATA(lv_field) = 'PS_CODE-FLD_0' && pi_type.
  ASSIGN (lv_field) TO FIELD-SYMBOL(<lfs_field>).

  IF <lfs_field> IS ASSIGNED AND
     <lfs_field> EQ 'X'.

    IF pi_value IS INITIAL.
      pe_type = 'E'.

      CLEAR: lv_text.
      CASE pi_type.
        WHEN '1'.
          lv_text = 'SALES_EMPLOYEE'.
        WHEN '2'.
          lv_text = 'CUST_NAME'.
        WHEN '3'.
          lv_text = 'DELV_NOTE'.
        WHEN '4'.
          lv_text = 'CUST_MANAGER'.
        WHEN '5'.
          lv_text = 'DELV_ADRS'.
        WHEN '6'.
          lv_text = 'PLATE_NO'.
        WHEN '7'.
          lv_text = 'DRIVER_NAME'.
        WHEN '8'.
          lv_text = 'DRIVER_TELNO'.

      ENDCASE.


*     필수 값 & 이 입력되지 않았습니다.
      MESSAGE s071(zgtsd01) WITH lv_text  INTO pe_msg.

    ENDIF.

  ENDIF.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form GO_KATALK_API_SEND
*&---------------------------------------------------------------------*
FORM go_katalk_api_send  USING    pi_corpnum
                                  pi_template
                                  pi_sender
                                  pi_receiver
                                  ps_data      LIKE zgtsdsif6000
                         CHANGING pe_type
                                  pe_msg
                                  pe_receiptnum.

  DATA: lo_linkhub    TYPE REF TO zgtsd_cx_linkhub,
        lo_popbill    TYPE REF TO zgtsd_popbill,

        ls_result     TYPE zgtsd_popbill=>s_popbill_result,
        lv_receiptnum TYPE string,

        ls_content    TYPE zgtsd_popbill=>s_pb_content,

        lv_corpnum    TYPE string.

  CONSTANTS: lc_linkid    TYPE string VALUE 'GAONCABLE',
             lc_secretkey TYPE string
                     VALUE '49JDhmgG1hMQ2244ROy+S9KBEJa00ymYe/JvWWpLbrU='.
**

* 1). Connect POPBILL Client.
  CREATE OBJECT lo_popbill
    EXPORTING
      p_linkid    = lc_linkid
      p_secretkey = lc_secretkey.

*  Set Test,
  IF sy-sysid = 'S4D'.    " Dev.
    lo_popbill->is_test = abap_true.
  ELSE.
    lo_popbill->is_test = abap_false.
  ENDIF.

* 2). Make Body: 알림톡 내용.
  CLEAR: lv_corpnum, ls_content.
  lv_corpnum = pi_corpnum.

  PERFORM make_api_kakao_body    USING     pi_corpnum
                                           pi_template
                                           pi_sender
                                           pi_receiver
                                           ps_data
                                 CHANGING  ls_content
                                           pe_type
                                           pe_msg.

* 3). Send Open Talk.
  CLEAR: ls_result.
  CALL METHOD lo_popbill->sendopentalk
    EXPORTING
      p_corpnum    = lv_corpnum
      p_content    = ls_content
    IMPORTING
      p_result     = ls_result
      p_receiptnum = lv_receiptnum.

  pe_receiptnum = lv_receiptnum.

  IF ls_result-code NE 0.
    pe_type = 'E'.
    pe_msg  = ls_result-message.
  ELSE.
    pe_type = 'S'.
  ENDIF.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form MAKE_API_KAKAO_BODY
*&---------------------------------------------------------------------*
FORM make_api_kakao_body  USING    pi_corpnum
                                   pi_template
                                   pi_sender
                                   pi_receiver
                                   ps_data      LIKE zgtsdsif6000
                          CHANGING pe_content   TYPE zgtsd_popbill=>s_pb_content
                                   pe_type
                                   pe_msg.

  DATA: lv_content TYPE string,

        lt_button  TYPE TABLE OF zgtsd_popbill=>s_pb_button,
        lt_msgs    TYPE TABLE OF zgtsd_popbill=>s_pb_msgs.

**
  CHECK: pe_type IS INITIAL.

** 1. Make Content Text.
*  1) Make Content Header Text.
  CLEAR: lv_content.
  PERFORM make_kakao_template_header   USING    pi_template
                                       CHANGING lv_content.

*  2) make content body Text.
  PERFORM make_kakao_template_body     USING    pi_template
                                                ps_data
                                       CHANGING lv_content.

*  3) Make Content Tail Text.
  PERFORM make_kakao_template_tail     USING    pi_template
                                       CHANGING lv_content.

** 2. Set Open Talk Body.
*  1) Set Body data.
  pe_content = VALUE #( templatecode = pi_template
                        snd          = space
                        content      = lv_content
                        altcontent   = space
                        altsendtype  = space
                        snddt        = space
                        requestnum   = space
                      ).

*  2) Button Set
** 거래명세서 정의 필요.
  _clear: lt_button.
  lt_button[] = VALUE #( ( n  = 'GAON Catalog'
                           t  = 'WL'
                           u1 = 'https://one.gaoncable.com/custfile/gaon_catalog.pdf'    "IOS 앱링크
                           u2 = 'https://one.gaoncable.com/custfile/gaon_catalog.pdf' )  "Android 앱링크
                         ( n  = '취급시 주의사항'
                           t  = 'WL'
                           u1 = 'https://one.gaoncable.com//custfile/caution_one-click.png'
                           u2 = 'https://one.gaoncable.com//custfile/caution_one-click.png' )
                         ( n  = '거래명세서 조회'
                           t  = 'WL'
                           u1 = 'https://one.gaoncable.com/main_out?SYSTEMCD=SG000001&MENUCODE=M000000466&SEARCH=MjIwMjYwMTEyMDAxMw==&POPTYPE=OUT'
                           u2 = 'https://one.gaoncable.com/main_out?SYSTEMCD=SG000001&MENUCODE=M000000466&SEARCH=MjIwMjYwMTEyMDAxMw==&POPTYPE=OUT' ) ).

  pe_content-btns[] = lt_button[].

*  3) Receiver Set.
  _clear: lt_msgs.
  lt_msgs[] = VALUE #( ( rcv   = pi_receiver
                         rcvnm = space ) ).

  pe_content-msgs[] = lt_msgs[].

**
  FREE: lt_button, lt_msgs.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form MAKE_KAKAO_TEMPLATE_HEADER
*&---------------------------------------------------------------------*
FORM make_kakao_template_header  USING    pi_template
                                 CHANGING pv_content.

**
  CHECK: pi_template IS NOT INITIAL.

  CASE pi_template.
    WHEN '024090000194' OR    " 배송출발(고객/현장)_택배_v3.
         '024090000195'.      " 배송출발(고객/현장)_ver3.
      pv_content = |안녕하세요.| && cl_abap_char_utilities=>newline &&
                   |가온전선입니다.|.

      IF     pi_template EQ '024090000194'.    " 배송출발(고객/현장)_택배_v3.
        pv_content = pv_content && cl_abap_char_utilities=>newline &&
                     |귀사의 발주건의| && cl_abap_char_utilities=>newline &&
                     |택배 배송이 시작되었습니다|.

      ELSEIF pi_template EQ '024090000195'.      " 배송출발(고객/현장)_ver3.
        pv_content = pv_content && cl_abap_char_utilities=>newline &&
                     |귀사에서 발주한 케이블 배송건에| && cl_abap_char_utilities=>newline &&
                     |대해서 안내드립니다.|.

      ENDIF.


    WHEN '024090000198' OR    " 배송출발(영업담당)_ver3.1.
         '024090000720'.      " 배송출발(영업담당)_택배_v3.
      pv_content = |[배송안내]| && cl_abap_char_utilities=>newline &&
                   |금일 출고된 배송건에 대한| && cl_abap_char_utilities=>newline &&
                   |담당자 알림톡입니다| .

      IF pi_template EQ '024090000720'.      " 배송출발(영업담당)_택배_v3.
        pv_content = pv_content && cl_abap_char_utilities=>newline &&
                     cl_abap_char_utilities=>newline &&
                     |본 건은 택배로 배송됩니다| .

      ENDIF.

  ENDCASE.


**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form MAKE_KAKAO_TEMPLATE_BODY
*&---------------------------------------------------------------------*
FORM make_kakao_template_body  USING    pi_template
                                        ps_data   LIKE zgtsdsif6000
                               CHANGING pv_content.

  DATA: lv_cnt(2)   TYPE n.

**
  CHECK: pi_template IS NOT INITIAL.

* Read Template Code from Common code Table.
  SELECT SINGLE *  INTO @DATA(ls_code)
    FROM zgtppt1010  WHERE module_kind EQ 'SD'
                       AND codegrp     EQ '6001'
                       AND fld_02      EQ @pi_template.

* Add empty line.
  IF pv_content IS NOT INITIAL.
    pv_content = pv_content && cl_abap_char_utilities=>newline.
  ENDIF.

  IF ls_code IS NOT INITIAL.

*    DATA(lv_cnt) = '03'.    " 4번 필드부터 시작
    CLEAR: lv_cnt.
    lv_cnt = 3.
    DO 8 TIMES.
      lv_cnt = lv_cnt + 1.
*      DATA(lv_field) = 'LS_CODE-FLD_0' && lv_cnt.
      DATA(lv_field) = 'LS_CODE-FLD_' && lv_cnt.
      ASSIGN (lv_field) TO FIELD-SYMBOL(<lfs_field>).

      IF <lfs_field> IS ASSIGNED AND
       <lfs_field> EQ 'X'.

        pv_content = pv_content && cl_abap_char_utilities=>newline.

        CASE lv_cnt.
          WHEN '4'.
*            pv_content = pv_content && |■ 담당자 : | && '#{' && ps_data-sales_employee && '}'.
            pv_content = pv_content && |■ 담당자 : | && ps_data-sales_employee .

          WHEN '5'.
*            pv_content = pv_content && |■ 거래처명 : | && '#{' && ps_data-cust_name && '}'.
            IF     pi_template EQ '024090000194'.      " 배송출발(고객/현장)_택배_v3.
              pv_content = pv_content && |■ 거래처명 : | && ps_data-cust_name .
            ELSEIF pi_template EQ '024090000720'.      " 배송출발(영업담당)_택배_v3.
              pv_content = pv_content && |■ 거래처 : | && ps_data-cust_name .
            ENDIF.

          WHEN '6'.
*            pv_content = pv_content && |■ 거래명세서 번호 : | && '#{' && ps_data-delv_note && '}'.
            pv_content = pv_content && |■ 거래명세서 번호 : | && ps_data-delv_note .

          WHEN '7'.
*            pv_content = pv_content && |■ 거래처담당자 : | && '#{' && ps_data-cust_manager && '}'.
            pv_content = pv_content && |■ 거래처담당자 : | && ps_data-cust_manager .

          WHEN '8'.
*            pv_content = pv_content && |■ 납지처 : | && '#{' && ps_data-delv_adrs && '}'.
            IF     pi_template EQ '024090000194'.      " 배송출발(고객/현장)_택배_v3.
              pv_content = pv_content && |■ 납지처 : | && ps_data-delv_adrs .
            ELSEIF pi_template EQ '024090000720'.      " 배송출발(영업담당)_택배_v3.
              pv_content = pv_content && |■ 납지처 :: | && ps_data-delv_adrs .
            ENDIF.

          WHEN '9'.
*            pv_content = pv_content && |■ 차량번호 : | && '#{' && ps_data-plate_no && '}'.
            pv_content = pv_content && |■ 차량번호 : | && ps_data-plate_no .

          WHEN '10'.
*            pv_content = pv_content && |■ 운송기사 : | && '#{' && ps_data-driver_telno && '}'.
            pv_content = pv_content && |■ 운송기사 : | && ps_data-driver_telno .
*            pv_content = pv_content && |■ 운송기사명 : | && '#{' && ps_data-driver_name && '}'.

          WHEN '11'.
*            pv_content = pv_content && |■ 운송기사 : | && '#{' && ps_data-driver_telno && '}'.
            pv_content = pv_content && |■ 운송기사 : | && ps_data-driver_telno .

        ENDCASE.

      ENDIF.

    ENDDO.

  ENDIF.

  CLEAR: ls_code.
**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form MAKE_KAKAO_TEMPLATE_TAIL
*&---------------------------------------------------------------------*
FORM make_kakao_template_tail  USING    pi_template
                               CHANGING pv_content.

**
  CHECK: pi_template IS NOT INITIAL.

* Add empty line.
  IF pv_content IS NOT INITIAL.
    pv_content = pv_content && cl_abap_char_utilities=>newline.
  ENDIF.

  IF pi_template EQ '024090000720'.      " 배송출발(영업담당)_택배_v3.
    pv_content = pv_content && cl_abap_char_utilities=>newline &&
                 |에 대한 배송건이 시작되었습니다|.
  ENDIF.

* 공통.
  IF     pi_template EQ '024090000194'.      " 배송출발(고객/현장)_택배_v3.
    pv_content = pv_content && cl_abap_char_utilities=>newline &&
                 |◈본 채널은 발신전용 채널입니다|.
  ELSEIF pi_template EQ '024090000720'.      " 배송출발(영업담당)_택배_v3.
    pv_content = pv_content && cl_abap_char_utilities=>newline &&
                 |◈본 채널은 발신전용 채널입니다.|.
  ENDIF.

  IF pi_template EQ '024090000194'.    " 배송출발(고객/현장)_택배_v3.
    pv_content = pv_content && cl_abap_char_utilities=>newline &&
                 |불편하신점이나 추가 문의사항은| && cl_abap_char_utilities=>newline &&
                 |담당자(연락처) 앞으로 연락주시면| && cl_abap_char_utilities=>newline &&
                 |감사하겠습니다.|.

  ENDIF.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form go_katalk_status_chk
*&---------------------------------------------------------------------*
FORM go_katalk_status_chk  USING    pi_corpnum
                                    pi_receiptnum
                           CHANGING pe_type
                                    pe_msg
                                    pe_msgnr
                                    pe_stat_msg.

  DATA: lo_linkhub TYPE REF TO zgtsd_cx_linkhub,
        lo_popbill TYPE REF TO zgtsd_popbill.

  DATA: lv_corpnum    TYPE string,
        lv_receiptnum TYPE string,
        lv_pb_status  TYPE int1,    " 팝빌 상태코드
        lv_fld_01     TYPE zgte_fldval,

        ls_result     TYPE zgtsd_popbill=>s_popbill_result,
        ls_status     TYPE zgtsd_popbill=>s_pb_send_stat.

  CONSTANTS: lc_linkid    TYPE string VALUE 'GAONCABLE',
             lc_secretkey TYPE string
                     VALUE '49JDhmgG1hMQ2244ROy+S9KBEJa00ymYe/JvWWpLbrU='.
**
  CHECK: pe_type NE 'E',
         pi_receiptnum IS NOT INITIAL.

  CLEAR: lv_corpnum.
  lv_corpnum = pi_corpnum.

  CLEAR: lv_receiptnum.
  lv_receiptnum = pi_receiptnum.

  FREE: lo_popbill.
  CLEAR: lo_popbill.

* 1). Connect POPBILL Client.
  CREATE OBJECT lo_popbill
    EXPORTING
      p_linkid    = lc_linkid
      p_secretkey = lc_secretkey.

*  Set Test,
  IF sy-sysid = 'S4D'.    " Dev.
    lo_popbill->is_test = abap_true.
  ELSE.
    lo_popbill->is_test = abap_false.
  ENDIF.

  CLEAR: lv_pb_status.
  WHILE lv_pb_status < 3.

    CLEAR: ls_result, ls_status.
    CALL METHOD lo_popbill->gettalkstatus
      EXPORTING
        p_corpnum    = lv_corpnum
        p_receiptnum = lv_receiptnum
      IMPORTING
        p_result     = ls_result
        p_status     = ls_status.

    CLEAR: lv_pb_status.
    IF ls_result-code NE '0'.
      lv_pb_status = 3.
    ELSE.
      lv_pb_status = ls_status-msgs[ 1 ]-state.

    ENDIF.

  ENDWHILE.

  IF ls_result-code NE 0.
    pe_type = 'E'.
    pe_msg  = ls_result-message.
  ELSE.

    CLEAR: lv_fld_01.
    DATA(ls_code) = ls_status-msgs[ 1 ].
    pe_msgnr = lv_fld_01 = ls_code-result.

    SELECT SINGLE fld_02  INTO @DATA(lv_stat_msg)
      FROM zgtppt1010  WHERE module_kind EQ 'SD'
                         AND codegrp     EQ '6002'
                         AND fld_01      EQ @lv_fld_01.
    IF sy-subrc = 0.
      pe_stat_msg = lv_stat_msg.
    ENDIF.

    IF pe_msgnr EQ '100'.
      pe_type = 'S'.
    ELSE.
      pe_type = 'E'.
    ENDIF.

  ENDIF.

**

ENDFORM.
