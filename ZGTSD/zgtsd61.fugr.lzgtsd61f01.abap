*----------------------------------------------------------------------*
***INCLUDE LZGTSD61F01.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form save_if_log_info_for_9000
*&---------------------------------------------------------------------*
*& 수신이력 Log Table Insert / Update 수행
*&---------------------------------------------------------------------*
*&      --> PV_SYSTEM_ID      : Interface Target 시스템 정보
*&      --> PS_RST_IF         : I/F 수신 Log 정보
*&      --> PV_INSERT_FLG     : Insert ('X' ) / Update (' ') 정보
*&      <-- PV_EFLG           : 오류 발생시 'X' 리턴
*&---------------------------------------------------------------------*
FORM save_if_log_info_for_9000  USING    pv_system_id  TYPE zgtetarget
                                         ps_rst_if     TYPE gty_rst_if
                                         pv_insert_flg TYPE char01
                                         pv_header     TYPE ZGTSDSIF0076
                                CHANGING pv_eflg       TYPE char01.

  DATA : lt_9000   TYPE gty_t_db_9000,
         lt_u_9000 TYPE gty_t_db_u_9000.

  CLEAR : lt_9000, lt_u_9000,
          pv_eflg.

  CASE pv_insert_flg.
    WHEN abap_true.         " 신규 Insert

      APPEND VALUE #(
                      zifrfc           = ps_rst_if-zifrfc           " RFC 명
                      zifkey           = ps_rst_if-zifkey           " I/F Key
                      zsystem_id       = ps_rst_if-zsystem_id       " I/F 시스템
                      zvalue01         = pv_header-dreqno           " 출하예정일 변경요청 번호

                      ifdat            = sy-datlo                   " 수신일자
                      iftim            = sy-timlo                   " 수신시간
                      ifnam            = sy-uname                   " 수신 User

                    ) TO lt_9000.

*-- 신규 수신이력 정보 Insert 수행
      TRY.
          INSERT zgtsdt9000 FROM TABLE @lt_9000.

        CATCH cx_sy_open_sql_db INTO DATA(lo_sql).
          DATA(lv_msg) = lo_sql->get_text( ).
          pv_eflg      = abap_true.
          ROLLBACK WORK.
      ENDTRY.

    WHEN OTHERS.            " 추가 결과 Update

      APPEND VALUE #(
                      zifrfc           = ps_rst_if-zifrfc           " RFC 명
                      zifkey           = ps_rst_if-zifkey           " I/F Key
                      zsystem_id       = ps_rst_if-zsystem_id       " I/F 시스템

                      zvalue01         = pv_header-dreqno           " 출하예정일 변경요청 번호
                      zstat            = ps_rst_if-zstat            " 전송상태
                      zmessage         = ps_rst_if-zmessage         " 전송메시지
                      zerp_stat        = ps_rst_if-zerp_stat        " 처리상태(수신 I/F 사용)
                      zerp_message     = ps_rst_if-zerp_message     " 처리메시지(수신 I/F 사용)

                      ernam            = sy-uname                   " 생성 ID
                      erdat            = sy-datum                   " 생성일
                      erzeit           = sy-uzeit                   " 생성시간
                      erdatlo          = sy-datlo                   " 생성일 Local
                      ertimlo          = sy-timlo                   " 생성시간 Local

*-- Update Indicator
                      ind-zvalue01     = '01'
                      ind-zstat        = '01'
                      ind-zmessage     = '01'
                      ind-zerp_stat    = '01'
                      ind-zerp_message = '01'
                      ind-ernam        = '01'
                      ind-erdat        = '01'
                      ind-erzeit       = '01'
                      ind-erdatlo      = '01'
                      ind-ertimlo      = '01'
                    ) TO lt_u_9000.

*-- 추가 정보 Update
      TRY.
          UPDATE zgtsdt9000 FROM TABLE @lt_u_9000
                            INDICATORS SET STRUCTURE ind.

        CATCH cx_sy_open_sql_db INTO lo_sql.
          lv_msg  = lo_sql->get_text( ).
          pv_eflg = abap_true.
          ROLLBACK WORK.
      ENDTRY.
  ENDCASE.

  CHECK pv_eflg NE abap_true.

  COMMIT WORK AND WAIT.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form upd_db_0068_if_log
*&---------------------------------------------------------------------*
*& 납기변경요청 수신 정보 Log Table Update 수행
*&---------------------------------------------------------------------*
*&      --> PT_ITEM      : 제조지시 납기일변경 해당 제조지시 정보
*&      <-- PT_RESULT    : 수신 결과 정보 리턴
*&      --> PS_HEADER    : 납기변경 결과 정보
*&      --> PV_SYSTEM_ID : Interface Target 시스템 정보
*&      <-- PV_EFLG      : 오류 발생시 'X' 리턴
*&---------------------------------------------------------------------*
FORM upd_db_0068_if_log  TABLES   pt_item      STRUCTURE zgtsdsif0077
                                  pt_result    STRUCTURE zgtsdsif0078
                         USING    ps_header    TYPE zgtsdsif0076
                                  pv_system_id TYPE zgtetarget
                         CHANGING pv_eflg      TYPE char01.

  DATA : lt_0068 TYPE gty_t_db_u_0068,

         lt_item TYPE TABLE OF zgtsdsif0077 WITH EMPTY KEY.

  lt_item[] = CORRESPONDING #( pt_item[] ).

  CLEAR : lt_0068,
          pv_eflg.
*-----------------------------------------------------------------------
*-- 납기변경 정보 기준 해당 송수신 Log 정보 Select
*-----------------------------------------------------------------------
  WITH +dreq_no AS ( SELECT a~dreqno, a~job_no                        "--> 납기변경 정보 Key 정보 구성
                       FROM @lt_item AS a
                      WHERE a~dreqno EQ @ps_header-dreqno
                      GROUP BY a~dreqno, a~job_no )

    SELECT a~zifkey,  a~zsystem_id,  a~dreqno,  a~job_no,  a~ifseq,
           a~reqsts, a~rdd_new, a~confrdd

      FROM zgtsdt0068 AS a INNER JOIN +dreq_no AS b
                              ON a~dreqno EQ b~dreqno
                             AND a~job_no EQ b~job_no

     WHERE a~zsystem_id EQ @pv_system_id
       AND a~dreqno     EQ @ps_header-dreqno
       AND a~reqsts     EQ 'A'

     ORDER BY a~zifkey, a~zsystem_id, a~dreqno, a~job_no, a~ifseq

      INTO TABLE @DATA(lt_0068_key).

*-----------------------------------------------------------------------
*-- 납기변경 요청 송수신 Log Update 정보 구성
*-----------------------------------------------------------------------
  LOOP AT lt_0068_key INTO DATA(ls_0068_key).
    IF ls_0068_key-rdd_new >= ps_header-confrdd.
      ls_0068_key-reqsts = 'C'.
    ENDIF.
    APPEND VALUE #(
                    zifkey      = ls_0068_key-zifkey                " I/F Key
                    zsystem_id  = ls_0068_key-zsystem_id            " Interface Target 시스템
                    dreqno      = ls_0068_key-dreqno                " 납기변경 접수번호
                    job_no      = ls_0068_key-job_no                " 제조지시 번호
                    ifseq       = ls_0068_key-ifseq                 " SD 관리 순번

                    reqsts      = ls_0068_key-reqsts                " 요청 상태
                    confrdd     = ps_header-confrdd                 " 생관확정 납기일
                    cfnam       = ps_header-cfnam                   " 생관 확정자

*-- Update Indicator
                    ind-reqsts  = '01'
                    ind-confrdd = '01'
                    ind-cfnam   = '01'
                  ) TO lt_0068.

  ENDLOOP.

*-----------------------------------------------------------------------
*-- DB Table : ZGTSDT0068 에 해당 정보 Update
*-----------------------------------------------------------------------
  IF lt_0068[] IS INITIAL.
    pv_eflg = abap_true.
    EXIT.
  ENDIF.

  TRY.
      UPDATE zgtsdt0068 FROM TABLE @lt_0068
                        INDICATORS SET STRUCTURE ind.
    CATCH cx_sy_open_sql_db INTO DATA(lo_sql).
      DATA(lv_msg) = lo_sql->get_text( ).
      pv_eflg = abap_true.
      ROLLBACK WORK.
  ENDTRY.

  CHECK pv_eflg NE abap_true.
*-----------------------------------------------------------------------
*-- 수신결과값 리턴정보 구성
*-----------------------------------------------------------------------
  DATA : lv_erp_msg  TYPE zgtemsg_p.

  lv_erp_msg = '출하예정일 변경 결과 수신에 성공하였습니다.'(m01).

  WITH +job_no AS ( SELECT a~dreqno, a~job_no
                      FROM @lt_0068 AS a
                     GROUP BY a~dreqno, a~job_no )

    SELECT a~dreqno          AS dreqno,
           a~job_no,
           'S'               AS zerp_stat,
           @lv_erp_msg       AS zerp_message

      FROM +job_no AS a

     ORDER BY a~job_no

      INTO CORRESPONDING FIELDS OF TABLE @pt_result.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form upd_db_0065_for_delv_dt
*&---------------------------------------------------------------------*
*& 판매오더 제조지시 정보 Table Update 수행
*&---------------------------------------------------------------------*
*&      --> PT_ITEM      : 제조지시 납기일변경 해당 제조지시 정보
*&      <-- PT_RESULT    : 수신 결과 정보 리턴
*&      --> PS_HEADER    : 납기변경 결과 정보
*&      --> PV_SYSTEM_ID : Interface Target 시스템 정보
*&      <-- PV_EFLG      : 오류 발생시 'X' 리턴
*&---------------------------------------------------------------------*
FORM upd_db_0065_for_delv_dt
                          TABLES   pt_item      STRUCTURE zgtsdsif0077
                                   pt_result    STRUCTURE zgtsdsif0078
                          USING    ps_header    TYPE zgtsdsif0076
                                   pv_system_id TYPE zgtetarget
                          CHANGING pv_eflg      TYPE char01.

  DATA : lt_0065    TYPE gty_t_db_u_0065,

         lt_item    TYPE TABLE OF zgtsdsif0077 WITH EMPTY KEY,

         lv_erp_msg TYPE zgtemsg_p.

  lt_item[] = CORRESPONDING #( pt_item[] ).

  CLEAR : lt_0065,
          pv_eflg.
*-----------------------------------------------------------------------
*-- 제조지시번호 기준 해당 판매오더 제조지시 정보 Select
*-----------------------------------------------------------------------
  WITH +job_no AS ( SELECT a~job_no                                   "--> 제조지시번호 정보 구성
                      FROM @lt_item AS a
                     GROUP BY a~job_no )

    SELECT a~zsystem_id,  a~mreqno,  a~zpjno,  a~job_no,  a~item_key, a~posnr

      FROM zgtsdt0065 AS a INNER JOIN +job_no AS b
                              ON a~job_no EQ b~job_no
     WHERE a~zsystem_id EQ @pv_system_id

      INTO TABLE @DATA(lt_key).

*-----------------------------------------------------------------------
*-- DB Table : ZGTSDT0065 Update 정보 구성
*-----------------------------------------------------------------------
  LOOP AT lt_key INTO DATA(ls_key).
    APPEND VALUE #(
                    zsystem_id     = ls_key-zsystem_id    " Interface Target 시스템
                    mreqno         = ls_key-mreqno        " 제조지시요청번호
                    zpjno          = ls_key-zpjno         " Project NO
                    job_no         = ls_key-job_no        " 제조지시 번호
                    posnr          = ls_key-posnr         " posnr
*                    item_key       = ls_key-item_key      " 판매오더연결 키

                    zdelv_date     = ps_header-confrdd    " 납품일
                    aenam          = sy-uname             " 변경ID
                    aedat          = sy-datum             " 변경일
                    aezeit         = sy-uzeit             " 변경시간
                    aedatlo        = sy-datlo             " 변경일 Local
                    aetimlo        = sy-timlo             " 변경시간 Local
*-- Update Indicator
                    ind-zdelv_date = '01'
                    ind-aenam      = '01'
                    ind-aedat      = '01'
                    ind-aezeit     = '01'
                    ind-aedatlo    = '01'
                    ind-aetimlo    = '01'
                  ) TO lt_0065.
  ENDLOOP.

*-----------------------------------------------------------------------
*-- DB Table : ZGTSDT0065 에 해당 정보 Update
*-----------------------------------------------------------------------
  IF lt_0065[] IS INITIAL.
    pv_eflg = abap_true.
    EXIT.
  ENDIF.

  TRY.
      UPDATE zgtsdt0065 FROM TABLE @lt_0065
                        INDICATORS SET STRUCTURE ind.
    CATCH cx_sy_open_sql_db INTO DATA(lo_sql).
      DATA(lv_msg) = lo_sql->get_text( ).
      pv_eflg = abap_true.
      ROLLBACK WORK.
  ENDTRY.


  CHECK pv_eflg NE abap_true.
*-----------------------------------------------------------------------
*-- 수신결과값 리턴정보 구성
*-----------------------------------------------------------------------
  lv_erp_msg = '납기일 변경에 성공하였습니다.'(m01).

  WITH +job_no AS ( SELECT a~job_no
                      FROM @lt_0065 AS a
                     GROUP BY a~job_no )

    SELECT @ps_header-dreqno AS dreqno,
           a~job_no,
           'S'               AS zerp_stat,
           @lv_erp_msg       AS zerp_message

      FROM +job_no AS a

     ORDER BY a~job_no

      APPENDING CORRESPONDING FIELDS OF TABLE @pt_result.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form save_text_for_zremark
*&---------------------------------------------------------------------*
*& 특이사항 정보 Function : SAVE_TEXT 통해 저장 수행
*&---------------------------------------------------------------------*
*&      --> PS_HEADER    : 납기변경 결과 정보
*&---------------------------------------------------------------------*
FORM save_text_for_zremark  USING    ps_header  TYPE zgtsdsif0076.

  DATA : ls_header TYPE thead,

         ls_cont   TYPE c LENGTH 132, "string,
         lt_cont   LIKE TABLE OF ls_cont,

         lt_lines  TYPE tline_tab.

  CHECK ps_header-zremark IS NOT INITIAL.

  CLEAR : ls_header, lt_lines, lt_cont.
*-- 특이사항 저장 정보 구성
  ls_header = VALUE #(
                      tdid      = 'DLVP'                  " 텍스트 ID
                      tdobject  = 'ZGTSDKBDM'             " 텍스트 오브젝트
                      tdname    = ps_header-dreqno        " 텍스트 이름 : 납기변경 접수번호
                      tdspras   = sy-langu                " 언어
                     ).

*-- 저장 특이사항 Text Convert 수행
  ls_cont = ps_header-zremark.
  APPEND ls_cont TO lt_cont.

  CALL FUNCTION 'CONVERT_STREAM_TO_ITF_TEXT'
    TABLES
      text_stream = lt_cont
      itf_text    = lt_lines.

*-- 특이사항 Text 정보 저장 수행
  CALL FUNCTION 'SAVE_TEXT'
    EXPORTING
      header          = ls_header
      insert          = abap_true
      savemode_direct = abap_true
    TABLES
      lines           = lt_lines
    EXCEPTIONS
      id              = 1
      language        = 2
      name            = 3
      object          = 4
      OTHERS          = 5.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form upd_sd_ord_header
*&---------------------------------------------------------------------*
*& 판매오더 출하예정일 변경 BAPI 수행
*&---------------------------------------------------------------------*
*&      --> PT_ITEM      : 제조지시 납기일변경 해당 제조지시 정보
*&      <-- PT_RESULT    : 수신 결과 정보 리턴
*&      --> PS_HEADER    : 납기변경 결과 정보
*&      <-- PV_EFLG      : 오류 발생시 'X' 리턴
*&---------------------------------------------------------------------*
FORM upd_sd_ord_header  TABLES   pt_item      STRUCTURE zgtsdsif0077
                                 pt_result    STRUCTURE zgtsdsif0078
                        USING    ps_header    TYPE zgtsdsif0076
                        CHANGING pv_eflg      TYPE char01.

  DATA : ls_header  TYPE bapisdh1,
         ls_headerx TYPE bapisdh1x,

         lt_return  TYPE bapiret2_tt,
         ls_return  TYPE bapiret2,

         lt_item    TYPE TABLE OF zgtsdsif0077 WITH EMPTY KEY,

         lv_vbeln   TYPE vbeln_va.

  CLEAR : pv_eflg.

  lt_item[] = CORRESPONDING #( pt_item[] ).

*-- 해당 판매오더 번호 정보 구성
  WITH +key_info AS ( SELECT a~job_no
                        FROM @lt_item AS a
                       GROUP BY a~job_no )

    SELECT a~vbeln,  a~bstnk
      FROM vbak AS a INNER JOIN +key_info AS b
                        ON a~bstnk EQ b~job_no

      INTO TABLE @DATA(lt_vbeln).


  LOOP AT lt_vbeln INTO DATA(ls_vbeln).
    CLEAR : lv_vbeln, ls_header, ls_headerx, lt_return.

*-- 판매오더 Header 변경정보 구성
    ls_header  = VALUE #(
                         req_date_h = ps_header-confrdd
                        ).
    ls_headerx = VALUE #(
                         updateflag = 'U'
                         req_date_h = abap_true
                        ).

    lv_vbeln = ls_vbeln-vbeln.

*-- 판매오더 변경 BAPI 수행
    CALL FUNCTION 'BAPI_SALESORDER_CHANGE'
      EXPORTING
        salesdocument    = lv_vbeln
        order_header_in  = ls_header
        order_header_inx = ls_headerx
      TABLES
        return           = lt_return[].

    READ TABLE lt_return WITH KEY type = 'S'
                         TRANSPORTING NO FIELDS.

    IF sy-subrc EQ 0.
*-- 성공인 경우 성공 정보 구성
      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'.

      ls_return-type    = 'S'.
      ls_return-message = |판매오더| && lv_vbeln && |출하예정일 변경 성공.|.

    ELSE.
*-- 실패인 경우 실패정보 구성
      CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
      pv_eflg           = abap_true.
      ls_return-type    = 'E'.
      ls_return-message = |판매오더| && lv_vbeln && |출하예정일 변경 실패.|.

    ENDIF.
*-- 결과 리턴 정보 구성

    APPEND VALUE #(
                    dreqno       = ps_header-dreqno
                    job_no       = ls_vbeln-bstnk
                    zerp_stat    = ls_return-type
                    zerp_message = ls_return-message
                  ) TO pt_result.
  ENDLOOP.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form check_stock
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LT_HUTEMP
*&      --> LS_ERROR
*&---------------------------------------------------------------------*
FORM CHECK_STOCK  TABLES   PT_HUTEMP STRUCTURE GT_IFTAB
                  USING    P_ERROR.

  DATA:LS_LABST     TYPE MARD-LABST,
       LS_STOCK(18).
  DATA:LV_MATNR LIKE MARA-MATNR.
  DATA:LV_HAWA(1).

* 배치체크
  LOOP AT PT_HUTEMP.
    CLEAR LV_MATNR.
*[S/4 HANA PJT]-Conversion_Alpha_input
*[S/4 HANA PJT]-2023.04.10 by 김선우
*    PERFORM conversion_exit_matn1 CHANGING lv_matnr.
*    pt_hutemp-matnr = lv_matnr.
*[S/4 HANA PJT]-Conversion_Alpha_input
*[S/4 HANA PJT]-2023.04.10 by 김선우
*-> CCM : 26.09.2023 09:36:06 / ZLSGSD4
    LV_MATNR = PT_HUTEMP-MATNR.
    PERFORM CONVERSION_EXIT_MATN1 CHANGING LV_MATNR.
*<-

*   상품체크
    CLEAR LV_HAWA.
    PERFORM CHECK_HAWA USING PT_HUTEMP-MATNR LV_HAWA.

    CLEAR MARC.
    SELECT SINGLE XCHPF
      INTO MARC-XCHPF
      FROM MARC
     WHERE MATNR = LV_MATNR
       AND WERKS = PT_HUTEMP-WERKS.

    IF MARC-XCHPF = 'X'.
      IF PT_HUTEMP-CHARG IS INITIAL.
        P_ERROR = 'X'.
        PT_HUTEMP-IFSAP =  GC_ERSAP.
        PT_HUTEMP-ZERET =  GC_ERROR.
        PT_HUTEMP-ZETXT =
                  'EP03 배치를 입력하세요'.

      ENDIF.
    ELSE.
      CLEAR PT_HUTEMP-CHARG.
    ENDIF.

    IF LV_HAWA = 'X'.
*      CLEAR: PT_HUTEMP-SOBKZ,
*             PT_HUTEMP-LSONR.
         CLEAR : PT_HUTEMP-CHARG.
    ELSE.
      IF MARC-XCHPF = 'X'.
        IF PT_HUTEMP-CHARG IS INITIAL OR
           PT_HUTEMP-SOBKZ IS INITIAL OR
           PT_HUTEMP-LSONR IS INITIAL.
          P_ERROR = 'X'.
          PT_HUTEMP-IFSAP =  GC_ERSAP.
          PT_HUTEMP-ZERET =  GC_ERROR.
          CONCATENATE PT_HUTEMP-ZETXT
                    'EP05 배치/판매오더번호를 입력하세요'
                 INTO PT_HUTEMP-ZETXT SEPARATED BY SPACE.
        ENDIF.
      ELSE.
        IF PT_HUTEMP-SOBKZ IS INITIAL OR
           PT_HUTEMP-LSONR IS INITIAL.
          P_ERROR = 'X'.
          PT_HUTEMP-IFSAP =  GC_ERSAP.
          PT_HUTEMP-ZERET =  GC_ERROR.
          CONCATENATE PT_HUTEMP-ZETXT
                    'EP05 판매오더번호를 입력하세요'
                 INTO PT_HUTEMP-ZETXT SEPARATED BY SPACE.
        ENDIF.
      ENDIF.
    ENDIF.

    MODIFY PT_HUTEMP.
  ENDLOOP.

* 재고 체크
  CHECK NOT P_ERROR = 'X'.


  LOOP AT PT_HUTEMP.
    CLEAR MARA.
    SELECT SINGLE *
      FROM MARA
     WHERE MATNR = PT_HUTEMP-MATNR.

    IF PT_HUTEMP-SOBKZ = ' '. "창고재고
      CLEAR: LS_LABST.

      IF PT_HUTEMP-CHARG = ' '.
        CLEAR: MARD.
        SELECT SINGLE LABST
          FROM MARD
          INTO LS_LABST
         WHERE MATNR  =  PT_HUTEMP-MATNR
           AND WERKS  =  PT_HUTEMP-WERKS
           AND LGORT  =  PT_HUTEMP-LGORT.
      ELSE.
        CLEAR: MCHB.
        SELECT SINGLE CLABS
          FROM MCHB
          INTO LS_LABST
         WHERE MATNR  =  PT_HUTEMP-MATNR
           AND WERKS  =  PT_HUTEMP-WERKS
           AND LGORT  =  PT_HUTEMP-LGORT
           AND CHARG  =  PT_HUTEMP-CHARG.
      ENDIF.
*     포장수량이 가용보다 많으면 에러
      IF PT_HUTEMP-LFIMG  > LS_LABST.
        WRITE LS_LABST TO LS_STOCK UNIT MARA-MEINS.
        CONDENSE LS_STOCK.
        CONCATENATE 'EP41 재고부족' PT_HUTEMP-MATNR
                    PT_HUTEMP-WERKS PT_HUTEMP-LGORT
                    PT_HUTEMP-CHARG LS_STOCK
                    INTO PT_HUTEMP-ZETXT SEPARATED BY SPACE.
        P_ERROR  =  'X'.
      ENDIF.

    ELSE.                     "판매오더재고
      CLEAR: MSKA.
      SELECT SINGLE *
        FROM MSKA
       WHERE MATNR  =  PT_HUTEMP-MATNR
         AND WERKS  =  PT_HUTEMP-WERKS
         AND LGORT  =  PT_HUTEMP-LGORT
         AND CHARG  =  PT_HUTEMP-CHARG
         AND SOBKZ  =  PT_HUTEMP-SOBKZ
         AND VBELN  =  PT_HUTEMP-LSONR+0(10)
         AND POSNR  =  PT_HUTEMP-LSONR+10(6).

*     포장수량이 가용보다 많으면 에러
      IF PT_HUTEMP-LFIMG  > MSKA-KALAB.
        WRITE MSKA-KALAB TO LS_STOCK UNIT MARA-MEINS.
        CONDENSE LS_STOCK.
        CONCATENATE 'EP41 재고부족' PT_HUTEMP-MATNR
                    PT_HUTEMP-WERKS PT_HUTEMP-LGORT
                    PT_HUTEMP-CHARG PT_HUTEMP-SOBKZ
                    PT_HUTEMP-LSONR LS_STOCK
                    INTO PT_HUTEMP-ZETXT SEPARATED BY SPACE.
        P_ERROR  =  'X'.
      ENDIF.

    ENDIF.

    MODIFY PT_HUTEMP.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form build_bdc_hu_cr_o
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LT_HUTEMP
*&---------------------------------------------------------------------*
FORM BUILD_BDC_HU_CR_O  TABLES   PT_HUTEMP STRUCTURE GT_IFTAB.


  DATA: LS_CNT(2)    TYPE N,
        LS_FIELD(20).

* 포장 HU TAB
  PERFORM BDC_DYNPRO USING 'SAPLV51G'   '6000'.
  PERFORM BDC_FIELD  USING 'BDC_OKCODE' '=UE6HUS'.
  PERFORM BDC_FIELD  USING 'BDC_CURSOR' 'HEADER51-PLANHU'.

  CLEAR: LS_CNT, PT_HUTEMP.
  LOOP AT PT_HUTEMP.
    PT_HUTEMP-SAP_CTIM+00(08)  =  SY-DATUM.
    LS_CNT  =  LS_CNT  +  1.

*   모든기존 HU(포장가용)
*   Default 화면의 Line인 5개(Recording과 동일)이므로 5개Line까지
*   입력후에는 PageDown버튼을 눌러 Line을 추가 후 Data를 입력한다.
    IF LS_CNT >  4.
      PERFORM BDC_DYNPRO USING 'SAPLV51G'   '6000'.
      PERFORM BDC_FIELD  USING 'BDC_OKCODE' '=PPLUS'.
      PERFORM BDC_FIELD  USING 'BDC_CURSOR' 'V51VE-EXIDV(01)'.

      PERFORM BDC_DYNPRO USING 'SAPLV51G'   '6000'.
      PERFORM BDC_FIELD  USING 'BDC_OKCODE' '/00'.
      PERFORM BDC_FIELD  USING 'BDC_CURSOR' 'V51VE-EXIDV(01)'.

      LS_CNT =  5.

    ENDIF.

    PERFORM BDC_DYNPRO USING 'SAPLV51G'   '6000'.
    PERFORM BDC_FIELD  USING 'BDC_OKCODE' '=ENTR'.
    PERFORM BDC_FIELD  USING 'BDC_CURSOR' 'V51VE-EXIDV(01)'.

    CONCATENATE 'V51VE-EXIDV(' LS_CNT ')' INTO LS_FIELD.

    IF PT_HUTEMP-INIDV = ' '.
      PERFORM BDC_FIELD  USING LS_FIELD PT_HUTEMP-EXIDV.
      CONCATENATE 'V51VE-VHILM(' LS_CNT ')' INTO LS_FIELD.
      PERFORM BDC_FIELD  USING LS_FIELD PT_HUTEMP-VHILM.
    ELSE.
      PERFORM BDC_FIELD  USING LS_FIELD PT_HUTEMP-INIDV.
    ENDIF.

  ENDLOOP.

* 입력한 처리단위가 자동정렬되므로 순차적으로 Line선택이 곤란함.
* 찾기기능으로 해당 처리단의를 찾으면 자동Line선택이 되므로 해결...ㅋㅋ
  CLEAR: LS_CNT, PT_HUTEMP.
  LOOP AT PT_HUTEMP.
    IF PT_HUTEMP-INIDV = ' '.
      PERFORM BDC_DYNPRO USING 'SAPLV51G'   '6000'.
      PERFORM BDC_FIELD  USING 'BDC_OKCODE' '=HUSUCH'.
      PERFORM BDC_FIELD  USING 'BDC_CURSOR' 'V51VE-EXIDV(01)'.

      PERFORM BDC_DYNPRO USING 'SAPLV51G'   '6001'.
      PERFORM BDC_FIELD  USING 'BDC_OKCODE' '=ENTR'.
      PERFORM BDC_FIELD  USING 'BDC_CURSOR' 'VEKP-EXIDV'.
      PERFORM BDC_FIELD  USING 'VEKP-EXIDV' PT_HUTEMP-EXIDV.

    ELSE.

      PERFORM BDC_DYNPRO USING 'SAPLV51G'   '6000'.
      PERFORM BDC_FIELD  USING 'BDC_OKCODE' '=HUSUCH'.
      PERFORM BDC_FIELD  USING 'BDC_CURSOR'
                                       'VEKPVB-EXIDV(01)'.

      PERFORM BDC_DYNPRO USING 'SAPLV51G'   '6001'.
      PERFORM BDC_FIELD  USING 'BDC_OKCODE' '=ENTR'.
      PERFORM BDC_FIELD  USING 'BDC_CURSOR' 'VEKP-EXIDV'.
      PERFORM BDC_FIELD  USING 'VEKP-EXIDV' PT_HUTEMP-INIDV.

    ENDIF.

  ENDLOOP.

* Pack
  PERFORM BDC_DYNPRO USING 'SAPLV51G'   '6000'.
  PERFORM BDC_FIELD  USING 'BDC_OKCODE' '=HU_VERP'.
  PERFORM BDC_FIELD  USING 'BDC_CURSOR' 'VEKPVB-EXIDV(01)'.
* 저장
  PERFORM BDC_DYNPRO USING 'SAPLV51G'   '6000'.
  PERFORM BDC_FIELD  USING 'BDC_OKCODE' '=SICH'.
  PERFORM BDC_FIELD  USING 'BDC_CURSOR' 'VEKPVB-EXIDV(01)'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form bdc_dynpro
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> P_
*&---------------------------------------------------------------------*
FORM BDC_DYNPRO  USING    P_PROGRAM P_DYNPRO.
  CLEAR GT_BDCDATA.
  GT_BDCDATA-PROGRAM  = P_PROGRAM.
  GT_BDCDATA-DYNPRO   = P_DYNPRO.
  GT_BDCDATA-DYNBEGIN = 'X'.
  APPEND GT_BDCDATA.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  BDC_FIELD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_0329   text
*      -->P_0330   text
*----------------------------------------------------------------------*
FORM BDC_FIELD  USING    P_FNAM P_FVAL.
  CLEAR GT_BDCDATA.
  GT_BDCDATA-FNAM = P_FNAM.
  GT_BDCDATA-FVAL = P_FVAL.
  CONDENSE GT_BDCDATA-FVAL.
  APPEND GT_BDCDATA.
ENDFORM.                    " BDC_FIELD
*&---------------------------------------------------------------------*
*& Form call_transaction_hu_cr_i
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LT_HUTEMP
*&      --> P_
*&      --> I_BDC_MODE
*&      --> P_
*&---------------------------------------------------------------------*
FORM CALL_TRANSACTION_HU_CR_I  TABLES   PT_HUTEMP STRUCTURE GT_IFTAB
                                USING   TCODE
                                        MODE
                                        P_VALUE.

  DATA: LS_TEXT TYPE CFGNL-MSGLIN.

  GS_CTU_PARAMS-DISMODE  = 'N'.
  GS_CTU_PARAMS-UPDMODE  = 'S'.
  GS_CTU_PARAMS-CATTMODE = ' '.
  GS_CTU_PARAMS-DEFSIZE  = 'X'. "Default Size(Recording과 같은화면으로처
  GS_CTU_PARAMS-RACOMMIT = ' '. "NOT EXIT AT COMMIT WORK
  GS_CTU_PARAMS-NOBINPT  = 'X'. "Not as batch input session, that is, SY
  GS_CTU_PARAMS-NOBIEND  = 'X'. "Not as batch input session after end of


  CALL TRANSACTION TCODE    USING GT_BDCDATA
                   OPTIONS   FROM GS_CTU_PARAMS
                   MESSAGES  INTO GT_MESSTAB.

  CLEAR PT_HUTEMP.
  READ TABLE PT_HUTEMP INDEX 1.

  IF SY-SUBRC = 0 AND ( SY-MSGTY = 'S' OR SY-MSGTY = 'I' ).

    IF P_VALUE = 'I'.
*     전기문서번호 가져오기
      SELECT M~MBLNR M~MJAHR
        INTO (PT_HUTEMP-MBLNR,PT_HUTEMP-MJAHR)
        FROM VEKP AS K INNER JOIN VEPO AS P
                               ON K~VENUM =  P~VENUM
                       INNER JOIN HUMSEG AS M
                               ON P~VENUM =  M~VENUM AND
                                  P~VEPOS =  M~VEPOS
          UP TO 1 ROWS
       WHERE K~EXIDV  =  PT_HUTEMP-EXIDV
         AND K~STATUS <> '0060'.
      ENDSELECT.
      IF NOT PT_HUTEMP-MBLNR IS INITIAL.
        PT_HUTEMP-IFSAP =  GC_SUSAP.
        PT_HUTEMP-ZERET =  GC_SUCCESS.
      ELSE.
        PT_HUTEMP-IFSAP =  GC_ERSAP.
        PT_HUTEMP-ZERET =  GC_ERROR.

      ENDIF.
    ENDIF.
  ELSE.
    PT_HUTEMP-IFSAP =  GC_ERSAP.
    PT_HUTEMP-ZERET =  GC_ERROR.
  ENDIF.

* 메시지 가져오기
  CALL FUNCTION 'RKC_MSG_STRING'
    EXPORTING
      ID      = SY-MSGID
      MTYPE   = SY-MSGTY
      NUMBER  = SY-MSGNO
      PAR1    = SY-MSGV1
      PAR2    = SY-MSGV2
      PAR3    = SY-MSGV3
      PAR4    = SY-MSGV4
    IMPORTING
      MSG_LIN = LS_TEXT.

  PT_HUTEMP-ZETXT = LS_TEXT.
  PT_HUTEMP-SAP_CTIM+00(08)  =  SY-DATUM.
  PT_HUTEMP-SAP_CTIM+08(06)  =  SY-UZEIT.
  MODIFY PT_HUTEMP TRANSPORTING SAP_CTIM IFSAP ZERET ZETXT
                                MBLNR MJAHR
                          WHERE SAP_CTIM = ' '.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form build_hu_create_i
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LT_HUTEMP
*&      --> LT_HUTAB
*&---------------------------------------------------------------------*
FORM BUILD_HU_CREATE_I  TABLES   PT_HUTEMP STRUCTURE GT_IFTAB
                         USING   PS_HUTAB  LIKE GT_IFTAB.
  DATA: LS_CNT(2)    TYPE N,
        LS_QTY(16),
        LS_FIELD(20).

* 포장 자재 TAB
  PERFORM BDC_DYNPRO USING 'SAPLV51G'   '6000'.
  PERFORM BDC_FIELD  USING 'BDC_OKCODE' '=UE6POS'.
  PERFORM BDC_FIELD  USING 'BDC_CURSOR' 'HEADER51-PLANHU'.
  PERFORM BDC_FIELD  USING 'HUM_MM_KOPFDATEN-WERKS'
                                            PS_HUTAB-WERKS.

  PERFORM BDC_DYNPRO USING 'SAPLV51G'       '6000'.
  PERFORM BDC_FIELD  USING 'BDC_OKCODE'     '=ENTR'.
  PERFORM BDC_FIELD  USING 'BDC_CURSOR'     'V51VE-VHILM(01)'.
  PERFORM BDC_FIELD  USING 'V51VE-EXIDV(01)' PS_HUTAB-EXIDV.
  PERFORM BDC_FIELD  USING 'V51VE-VHILM(01)' PS_HUTAB-VHILM.

  CLEAR LS_CNT.
  LOOP AT PT_HUTEMP.
    CLEAR LS_QTY.
    PT_HUTEMP-SAP_CTIM+00(08)  =  SY-DATUM.
    LS_QTY  =  PT_HUTEMP-LFIMG.
    LS_CNT  =  LS_CNT  +  1.

*   포장예정 자재
*   Default 화면의 Line인 7개(Recording과 동일)이므로 7개Line까지
*   입력후에는 PageDown버튼을 눌러 Line을 추가 후 Data를 입력한다.
    IF LS_CNT >  6.
      PERFORM BDC_DYNPRO USING 'SAPLV51G'   '6000'.
      PERFORM BDC_FIELD  USING 'BDC_OKCODE' '=PPLUS'.
      PERFORM BDC_FIELD  USING 'BDC_CURSOR' 'V51VP-TMENG(01)'.

      PERFORM BDC_DYNPRO USING 'SAPLV51G'   '6000'.
      PERFORM BDC_FIELD  USING 'BDC_OKCODE' '/00'.
      PERFORM BDC_FIELD  USING 'BDC_CURSOR' 'V51VP-TMENG(01)'.

      LS_CNT =  7.
    ENDIF.

    CONCATENATE 'V51VP-WERKS(' LS_CNT ')' INTO LS_FIELD.
    PERFORM BDC_FIELD  USING LS_FIELD PT_HUTEMP-WERKS.

    CONCATENATE 'V51VP-MATNR(' LS_CNT ')' INTO LS_FIELD.
    PERFORM BDC_FIELD  USING LS_FIELD PT_HUTEMP-MATNR.

    CONCATENATE 'V51VP-LFIMG(' LS_CNT ')' INTO LS_FIELD.
    PERFORM BDC_FIELD  USING LS_FIELD LS_QTY.

    CONCATENATE 'V51VP-LGORT(' LS_CNT ')' INTO LS_FIELD.
    PERFORM BDC_FIELD  USING LS_FIELD PT_HUTEMP-LGORT.

    CONCATENATE 'V51VP-UMLGO(' LS_CNT ')' INTO LS_FIELD.
    PERFORM BDC_FIELD  USING LS_FIELD PT_HUTEMP-UMLGO.

    CLEAR MARC.
    SELECT SINGLE XCHPF
      INTO MARC-XCHPF
      FROM MARC
     WHERE MATNR = PT_HUTEMP-MATNR
       AND WERKS = PT_HUTEMP-WERKS.
    IF MARC-XCHPF = 'X'.
      CONCATENATE 'V51VP-CHARG(' LS_CNT ')' INTO LS_FIELD.
      PERFORM BDC_FIELD  USING LS_FIELD PT_HUTEMP-CHARG.
    ENDIF.

    CONCATENATE 'V51VP-SOBKZ(' LS_CNT ')' INTO LS_FIELD.
    PERFORM BDC_FIELD  USING LS_FIELD PT_HUTEMP-SOBKZ.

    CONCATENATE 'V51VP-LSONR(' LS_CNT ')' INTO LS_FIELD.
    PERFORM BDC_FIELD  USING LS_FIELD PT_HUTEMP-LSONR.

  ENDLOOP.

* 포장 예정자재 전체선택
  PERFORM BDC_DYNPRO USING 'SAPLV51G'        '6000'.
  PERFORM BDC_FIELD  USING 'BDC_OKCODE'      '=HU_MARKA'.
  PERFORM BDC_FIELD  USING 'BDC_CURSOR'    'V51VP-MATNR(01)'.
* Pack
  PERFORM BDC_DYNPRO USING 'SAPLV51G'        '6000'.
  PERFORM BDC_FIELD  USING 'BDC_OKCODE'      '=HU_VERP'.
  PERFORM BDC_FIELD  USING 'V51VE-SELKZ(01)' 'X'.
* 저장
  PERFORM BDC_DYNPRO USING 'SAPLV51G'   '6000'.
  PERFORM BDC_FIELD  USING 'BDC_OKCODE' '=SICH'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form build_hu_dismantle_o
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LT_HUTEMP
*&---------------------------------------------------------------------*
FORM BUILD_HU_DISMANTLE_O  TABLES   PT_HUTEMP STRUCTURE GT_IFTAB.


* 포장 HU TAB
  PERFORM BDC_DYNPRO USING 'SAPLV51G'   '6000'.
  PERFORM BDC_FIELD  USING 'BDC_OKCODE' '=UE6HUS'.
  PERFORM BDC_FIELD  USING 'BDC_CURSOR' 'HEADER51-PLANHU'.

  CLEAR PT_HUTEMP.
  LOOP AT PT_HUTEMP.

    PERFORM BDC_DYNPRO USING 'SAPLV51G'   '6000'.
    PERFORM BDC_FIELD  USING 'BDC_OKCODE' '=ENTR'.
    PERFORM BDC_FIELD  USING 'BDC_CURSOR' 'V51VE-EXIDV(01)'.
    PERFORM BDC_FIELD  USING 'V51VE-EXIDV(01)'
                                  PT_HUTEMP-EXIDV.
*   찾기로 Line 선택
    PERFORM BDC_DYNPRO USING 'SAPLV51G'   '6000'.
    PERFORM BDC_FIELD  USING 'BDC_OKCODE' '=HUSUCH'.
    PERFORM BDC_FIELD  USING 'BDC_CURSOR' 'V51VE-EXIDV(01)'.

    PERFORM BDC_DYNPRO USING 'SAPLV51G'   '6001'.
    PERFORM BDC_FIELD  USING 'BDC_OKCODE' '=ENTR'.
    PERFORM BDC_FIELD  USING 'BDC_CURSOR' 'VEKP-EXIDV'.
    PERFORM BDC_FIELD  USING 'VEKP-EXIDV' PT_HUTEMP-EXIDV.
*   Empty
    PERFORM BDC_DYNPRO USING 'SAPLV51G'   '6000'.
    PERFORM BDC_FIELD  USING 'BDC_OKCODE' '=HULEE'.
    PERFORM BDC_FIELD  USING 'BDC_CURSOR' 'V51VE-EXIDV(01)'.

    PERFORM BDC_DYNPRO USING 'SAPLV51G'   '6000'.
    PERFORM BDC_FIELD  USING 'BDC_OKCODE' '/00'.
    PERFORM BDC_FIELD  USING 'BDC_CURSOR' 'V51VE-EXIDV(01)'.

*   저장
    PERFORM BDC_DYNPRO USING 'SAPLV51G'   '6000'.
    PERFORM BDC_FIELD  USING 'BDC_OKCODE' '=SICH'.
    PERFORM BDC_FIELD  USING 'BDC_CURSOR' 'V51VE-EXIDV(01)'.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form check_hawa
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PT_HUTEMP_MATNR
*&      --> LV_HAWA
*&---------------------------------------------------------------------*
FORM CHECK_HAWA  USING    P_MATNR
                          P_HAWA.

  CLEAR MARA.
  SELECT SINGLE MTART
    INTO MARA-MTART
    FROM MARA
   WHERE MATNR = P_MATNR.

  IF MARA-MTART = 'HAWA' OR MARA-MTART = 'ROH' OR
     MARA-MTART = 'ROH1' OR MARA-MTART = 'ROH2'.
    P_HAWA = 'X'.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form conversion_exit_matn1
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- LV_MATNR
*&---------------------------------------------------------------------*
FORM CONVERSION_EXIT_MATN1  CHANGING PV_MATNR.

  CALL FUNCTION 'CONVERSION_EXIT_MATN1_INPUT'
    EXPORTING
      INPUT  = PV_MATNR
    IMPORTING
      OUTPUT = PV_MATNR.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form reverse_hu_doc
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LT_HUTEMP
*&      --> I_BDC_MODE
*&---------------------------------------------------------------------*
FORM REVERSE_HU_DOC  TABLES   PT_HUTEMP STRUCTURE GT_IFTAB
                      USING   P_MODE.
  DATA: PD_ZETXT    LIKE ZPPTIF43-ZETXT,
        PD_CHECK(1).

  LOOP AT PT_HUTEMP.
    CLS  : GT_BDCDATA, GT_MESSTAB.
    CLEAR: GS_CTU_PARAMS, PD_CHECK.

    IF PT_HUTEMP-MBLNR IS INITIAL.
*     전기 문서번호 읽기
      CLEAR: HUMSEG.
      SELECT M~MBLNR M~MJAHR
        INTO (PT_HUTEMP-MBLNR,PT_HUTEMP-MJAHR)
        FROM VEKP AS K INNER JOIN VEPO AS P
                               ON K~VENUM =  P~VENUM
                       INNER JOIN HUMSEG AS M
                               ON P~VENUM =  M~VENUM AND
                                  P~VEPOS =  M~VEPOS
       WHERE K~EXIDV  =  PT_HUTEMP-EXIDV
         AND K~STATUS <> '0060'.
      ENDSELECT.
    ENDIF.

    IF PT_HUTEMP-MBLNR2 IS INITIAL.
      PERFORM BDC_DYNPRO USING 'RHU_GOODS_MOVEMENT_CANCEL' '1000'.
      PERFORM BDC_FIELD  USING 'BDC_OKCODE' '=ONLI'.
      PERFORM BDC_FIELD  USING 'BDC_CURSOR' 'SP_MBLNR'.
      PERFORM BDC_FIELD  USING 'SP_PSTDA' PT_HUTEMP-BUDAT.
      PERFORM BDC_FIELD  USING 'SP_MBLNR' PT_HUTEMP-MBLNR.
      PERFORM BDC_FIELD  USING 'SP_MJAHR' PT_HUTEMP-MJAHR.

      PERFORM CALL_TRANSACTION_HUCANC USING 'HUCANC' P_MODE
                                            PT_HUTEMP.

    ENDIF.

*    IF PT_HUTEMP-IFSAP = GC_SUSAP AND PT_HUTEMP-ZERET = GC_SUCCESS.
    IF NOT PT_HUTEMP-MBLNR2 IS INITIAL.
      CLS GT_RETURN.
      CALL FUNCTION 'BAPI_HU_DELETE'
        EXPORTING
          HUKEY  = PT_HUTEMP-EXIDV
        TABLES
          RETURN = GT_RETURN.

      CLEAR GT_RETURN.
      READ TABLE GT_RETURN WITH KEY TYPE = 'S'.
      IF SY-SUBRC = '0'.
        CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
          EXPORTING
            WAIT = 'X'.

        PT_HUTEMP-IFSAP =  GC_SUSAP.
        PT_HUTEMP-ZERET =  GC_SUCCESS.
        CONCATENATE PT_HUTEMP-ZETXT GT_RETURN-TYPE GT_RETURN-ID
                    GT_RETURN-NUMBER GT_RETURN-MESSAGE
               INTO PT_HUTEMP-ZETXT SEPARATED BY SPACE.

      ELSE.
        CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

        PT_HUTEMP-IFSAP =  GC_ERSAP.
        PT_HUTEMP-ZERET =  GC_ERROR.
*       Error Message 전체를 Text로..

        CLEAR: PD_ZETXT, GT_RETURN.
        LOOP AT GT_RETURN WHERE TYPE <> 'S'.
          CONCATENATE PD_ZETXT GT_RETURN-TYPE GT_RETURN-ID
                      GT_RETURN-NUMBER
                      INTO PD_ZETXT.
          CONCATENATE PD_ZETXT GT_RETURN-MESSAGE
                      INTO PD_ZETXT SEPARATED BY SPACE.

        ENDLOOP.

        PT_HUTEMP-ZETXT = PD_ZETXT.
      ENDIF.

    ENDIF.

    PT_HUTEMP-SAP_CTIM+00(08)  =  SY-DATUM.
    PT_HUTEMP-SAP_CTIM+08(06)  =  SY-UZEIT.
    MODIFY PT_HUTEMP TRANSPORTING SAP_CTIM IFSAP ZERET ZETXT
                                  MBLNR MJAHR MBLNR2 MJAHR2
                            WHERE SAP_CTIM = ' '.

  ENDLOOP.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form call_transaction_hucanc
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> P_MODE
*&      --> PT_HUTEMP
*&---------------------------------------------------------------------*
FORM CALL_TRANSACTION_HUCANC  USING    TCODE
                                       MODE
                                       PS_HUTEMP LIKE GT_IFTAB.
  DATA: LV_TEXT LIKE CFGNL-MSGLIN,
        LS_VEKP LIKE VEKP.


  GS_CTU_PARAMS-DISMODE  = MODE.
  GS_CTU_PARAMS-UPDMODE  = 'S'.
  GS_CTU_PARAMS-CATTMODE = ' '.
  GS_CTU_PARAMS-DEFSIZE  = 'X'. "Default Size(Recording과 같은화면으로처
  GS_CTU_PARAMS-RACOMMIT = ' '. "NOT EXIT AT COMMIT WORK
  GS_CTU_PARAMS-NOBINPT  = 'X'. "Not as batch input session, that is, SY
  GS_CTU_PARAMS-NOBIEND  = 'X'. "Not as batch input session after end of


  CALL TRANSACTION TCODE    USING GT_BDCDATA
                   OPTIONS   FROM GS_CTU_PARAMS
                   MESSAGES  INTO GT_MESSTAB.


  IF SY-SUBRC = 0 AND
      ( SY-MSGTY = 'S' OR SY-MSGTY = 'I' OR SY-MSGTY = ' ' ).
    PS_HUTEMP-IFSAP =  GC_SUSAP.
    PS_HUTEMP-ZERET =  GC_SUCCESS.

*   취소 문서번호가져오기
    CLEAR LS_VEKP.
    SELECT SINGLE *
      INTO LS_VEKP
      FROM VEKP
     WHERE EXIDV  = PS_HUTEMP-EXIDV
       AND STATUS = '0020'.

    SELECT MBLNR MJAHR
      INTO (PS_HUTEMP-MBLNR2,PS_HUTEMP-MJAHR2)
      FROM HUMSEG
        UP TO 1 ROWS
     WHERE VENUM = LS_VEKP-VENUM.
    ENDSELECT.

*    SELECT M~MBLNR M~MJAHR
*      INTO (PS_HUTEMP-MBLNR2,PS_HUTEMP-MJAHR2)
*      FROM VEKP AS K INNER JOIN HUMSEG AS M
*                        ON K~VENUM = M~VENUM
*        UP TO 1 ROWS
*     WHERE K~EXIDV  =  PS_HUTEMP-EXIDV
*       AND K~STATUS = '0020'.   "삭제
*
*    ENDSELECT.

  ELSE.                  "실패
    PS_HUTEMP-IFSAP =  GC_ERSAP.
    PS_HUTEMP-ZERET =  GC_ERROR.
  ENDIF.

* 메시지 가져오기
  CALL FUNCTION 'RKC_MSG_STRING'
    EXPORTING
      ID      = SY-MSGID
      MTYPE   = SY-MSGTY
      NUMBER  = SY-MSGNO
      PAR1    = SY-MSGV1
      PAR2    = SY-MSGV2
      PAR3    = SY-MSGV3
      PAR4    = SY-MSGV4
    IMPORTING
      MSG_LIN = LV_TEXT.

  PS_HUTEMP-ZETXT = LV_TEXT.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form update_table
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LT_HUTAB
*&      --> GC_TABLE43
*&---------------------------------------------------------------------*
FORM UPDATE_TABLE  TABLES PAR_ITAB USING TABLE_NAME.
  ASSIGN (TABLE_NAME) TO <TN>.
  MOVE-CORRESPONDING PAR_ITAB TO <TN>.
  UPDATE (TABLE_NAME) FROM <TN>.
  COMMIT WORK AND WAIT.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form next_number_get
*&---------------------------------------------------------------------*
*& Number Range 번호 채번 수행
*&---------------------------------------------------------------------*
*&      --> PV_OBJECT     : Number Range 오브젝트 명
*&      --> PV_RANGE_NR   : 번호 범위 정보
*&      <-- PV_NUMBER     : 채번 번호 리턴
*&---------------------------------------------------------------------*
FORM next_number_get  USING    pv_object    TYPE nrobj
                               pv_range_nr  TYPE nrnr
                      CHANGING pv_number.
  CLEAR pv_number.

*-- Number Range 번호 채번 수행
  CALL FUNCTION 'NUMBER_GET_NEXT'
    EXPORTING
      nr_range_nr             = pv_range_nr
      object                  = pv_object
    IMPORTING
      number                  = pv_number
    EXCEPTIONS
      interval_not_found      = 1
      number_range_not_intern = 2
      object_not_found        = 3
      quantity_is_0           = 4
      quantity_is_not_1       = 5
      interval_overflow       = 6
      buffer_overflow         = 7
      OTHERS                  = 8.

ENDFORM.
