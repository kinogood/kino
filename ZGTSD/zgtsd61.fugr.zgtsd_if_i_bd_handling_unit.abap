FUNCTION ZGTSD_IF_I_BD_HANDLING_UNIT .
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(I_SYSTEM_ID) TYPE  CHAR04 OPTIONAL
*"     VALUE(I_BDC_MODE) TYPE  CHAR01 DEFAULT 'N'
*"  EXPORTING
*"     VALUE(ZO_RESULT) TYPE  CHAR2
*"     VALUE(ZO_MESSAGE) TYPE  CHAR100
*"  TABLES
*"      IT_TAB STRUCTURE  ZGTSDSIF0070 OPTIONAL
*"----------------------------------------------------------------------
*&---------------------------------------------------------------------*
*& 모듈        : SD
*& 프로그램 ID : ZGTSD_IF_I_BD_HANDLING_UNIT
*& 프로그램 명 : [BD] 포장실적 정보 수신 Interface
*& 개요   :
*& 생성일 : 2025.01.14
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
  DATA: lt_hutemp  LIKE gt_iftab OCCURS 0 WITH HEADER LINE,
        lt_hutab   LIKE gt_iftab OCCURS 0 WITH HEADER LINE,
        lt_chk_tab LIKE TABLE OF gt_iftab WITH EMPTY KEY.

  DATA: ls_act(1),
        ls_error(1),
        ls_index     LIKE sy-tabix,

        lv_zifkey    TYPE timestampl,
        gv_prev_rqno TYPE zgte_leg_rqno.

  DATA : gt_mska TYPE TABLE OF mska,
         gt_mard TYPE TABLE OF mard.

  DATA : goodsmvt_header TYPE bapi2017_gm_head_01.
  DATA : gt_goodsmvt_item TYPE TABLE OF bapi2017_gm_item_create,
         gs_goodsmvt_item TYPE bapi2017_gm_item_create,
         gt_return        TYPE TABLE OF bapiret2,
         gs_return        TYPE bapiret2.

  DATA : materialdocument TYPE bapi2017_gm_head_ret-mat_doc.

* DATA유무확인
  CLEAR : gt_iftab, gt_iftab[].

  gt_iftab[] = CORRESPONDING #( it_tab[] ).

  IF gt_iftab[] IS INITIAL.
    zo_result  = gc_error1.
    zo_message = 'Interface된 Data가 한건도 없습니다.'.
    EXIT.
  ENDIF.
*--- 판매오더재고일 경우 판매오더 재고 확인 -> 입고대기항목 존재 확인 -> 플랜트 재고 존재 확인 순으로 진행함
  LOOP AT gt_iftab INTO DATA(ls_iftab).

    REFRESH : gt_mska, gt_mard.

    SELECT SINGLE mtart INTO @DATA(lv_mtart) FROM mara WHERE matnr = @ls_iftab-matnr.

    IF ls_iftab-lsonr IS NOT INITIAL
      AND lv_mtart = 'HAWA'
      AND ls_iftab-zflag = 'I'.

*1. 판매오더재고 확인
      SELECT * FROM mska INTO CORRESPONDING FIELDS OF TABLE @gt_mska WHERE vbeln = @ls_iftab-lsonr+0(10)
                                           AND posnr = @ls_iftab-lsonr+10(6)
                                            AND matnr = @ls_iftab-matnr
        AND kalab >= @ls_iftab-lfimg
        AND sobkz = @ls_iftab-sobkz
        AND lgort = @ls_iftab-lgort
        AND werks = @ls_iftab-werks.

      IF sy-subrc = 0.
        CONTINUE.
      ENDIF.

*2. 입고대기항목 존재 확인.
      SELECT c~ebeln, c~ebelp, c~matnr INTO TABLE @DATA(lt_hold_data)
        FROM ekkn AS b
        INNER JOIN ekpo AS c ON b~ebeln = c~ebeln AND b~ebelp = c~ebelp
        WHERE b~vbeln = @ls_iftab-lsonr+0(10) AND b~vbelp = @ls_iftab-lsonr+10(6)
        AND c~menge >= @ls_iftab-lfimg
        AND c~matnr = @ls_iftab-matnr
        AND c~werks = @ls_iftab-werks.

      IF sy-subrc = 0.
        ls_iftab-zeret = '03'.
        ls_iftab-zetxt = '구매오더 중 미입고된 항목이 존재합니다. 입고를 진행하세요.'.
        MODIFY gt_iftab FROM ls_iftab.
        REFRESH : lt_hold_data.
        CONTINUE.
      ENDIF.

*3. 플랜트 재고 존재 - 해당 판매오더로 413 진행
      SELECT * FROM mard INTO CORRESPONDING FIELDS OF TABLE gt_mard
        WHERE matnr = ls_iftab-matnr AND lgort = ls_iftab-lgort
        AND labst >= ls_iftab-lfimg
        AND werks = ls_iftab-werks.

      IF sy-subrc = 0.
        ls_iftab-413_flag = 'X'.
        MODIFY gt_iftab FROM ls_iftab.
        CONTINUE.
      ELSE.
        ls_iftab-zeret = '03'.
        ls_iftab-zetxt = '해당 자재의 전환될 재고가 부족합니다.'.
        MODIFY gt_iftab FROM ls_iftab.
        REFRESH : lt_hold_data, gt_mard.
        CONTINUE.
      ENDIF.
    ENDIF.
  ENDLOOP.

  "MES Return
  READ TABLE gt_iftab WITH KEY zeret = '03'.

  IF sy-subrc = 0.
    ls_iftab-zeret = '03'.
    ls_iftab-zetxt = '해당 라인은 통과하였으나 묶인 상품 자재코드 중 재고가 부족한 항목이 존재합니다,'.
    MODIFY gt_iftab FROM ls_iftab TRANSPORTING zeret zetxt WHERE zeret = ''.

    zo_result  = gc_error1.
    zo_message = '상품재고 중 재고가 부족한 항목이 존재하거나 전기가 실패하였습니다.'.

  ELSE.

    "413 대상은 종합하여 Line Item으로 정리.
    LOOP AT gt_iftab INTO ls_iftab WHERE 413_flag = 'X'.

      gs_goodsmvt_item-material = ls_iftab-matnr.
      gs_goodsmvt_item-plant = ls_iftab-werks.
      gs_goodsmvt_item-stge_loc = ls_iftab-lgort.
      gs_goodsmvt_item-batch = ls_iftab-charg.
      gs_goodsmvt_item-entry_qnt = ls_iftab-lfimg.

      SELECT SINGLE vrkme FROM vbap INTO @gs_goodsmvt_item-entry_uom
        WHERE vbeln = @ls_iftab-lsonr+0(10)
        AND posnr = @ls_iftab-lsonr+10(6).

      IF gs_goodsmvt_item-entry_uom IS INITIAL.
        ls_iftab-zeret = '03'.
        ls_iftab-zetxt = '대상 판매오더가 존재하지 않습니다.'.
        MODIFY gt_iftab FROM ls_iftab.
        CLEAR : goodsmvt_header, gs_goodsmvt_item.
        REFRESH : gt_goodsmvt_item.
        EXIT.
      ENDIF.

      gs_goodsmvt_item-move_type = '413'.
      gs_goodsmvt_item-sales_ord = ls_iftab-lsonr+0(10).
      gs_goodsmvt_item-s_ord_item = ls_iftab-lsonr+10(6).
      gs_goodsmvt_item-move_stloc = ls_iftab-lgort.
      gs_goodsmvt_item-move_batch = ls_iftab-charg.
      gs_goodsmvt_item-move_mat = ls_iftab-matnr.
      gs_goodsmvt_item-move_plant = ls_iftab-werks.

      APPEND gs_goodsmvt_item TO gt_goodsmvt_item.

    ENDLOOP.

    IF gt_goodsmvt_item IS NOT INITIAL.
      goodsmvt_header-pstng_date = sy-datum.
      goodsmvt_header-doc_date = sy-datum.
      goodsmvt_header-header_txt = ls_iftab-lsonr.

      CALL FUNCTION 'BAPI_GOODSMVT_CREATE'
        EXPORTING
          goodsmvt_header  = goodsmvt_header
          goodsmvt_code    = '04'
*         TESTRUN          = ' '
*         GOODSMVT_REF_EWM =
*         GOODSMVT_PRINT_CTRL           =
        IMPORTING
*         GOODSMVT_HEADRET =
          materialdocument = materialdocument
*         MATDOCUMENTYEAR  =
        TABLES
          goodsmvt_item    = gt_goodsmvt_item
*         GOODSMVT_SERIALNUMBER         =
          return           = gt_return
*         GOODSMVT_SERV_PART_DATA       =
*         EXTENSIONIN      =
*         GOODSMVT_ITEM_CWM             =
        .
      IF materialdocument IS NOT INITIAL.
        CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
          EXPORTING
            wait = 'X'.

        CLEAR : goodsmvt_header, materialdocument.
        REFRESH : gt_goodsmvt_item, gt_return.

        DO 20 TIMES.
          SELECT SINGLE a~mblnr INTO @DATA(ls_bstnk)
            FROM matdoc AS a
           WHERE a~mblnr = @materialdocument.

          IF sy-subrc NE 0.
            WAIT UP TO '0.5' SECONDS.
          ELSE.
            EXIT.
          ENDIF.
        ENDDO.
      ELSE.

        READ TABLE gt_return INTO gs_return WITH KEY type = 'E'.
        IF sy-subrc = 0.
          ls_iftab-zeret = '03'.
          CONCATENATE gs_return-message_v1 gs_return-message_v2 gs_return-message_v3 gs_return-message_v4 INTO ls_iftab-zetxt SEPARATED BY space.
          IF ls_iftab-zetxt IS INITIAL.
            ls_iftab-zetxt = gs_return-message.
          ENDIF.
        ELSE.
          ls_iftab-zeret = '03'.
          ls_iftab-zetxt = '상품재고를 판매오더재고로 전환하는 데 실패했습니다.'.
        ENDIF.

        CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

        MODIFY gt_iftab FROM ls_iftab TRANSPORTING zeret zetxt WHERE 413_flag = 'X'.

        CLEAR : goodsmvt_header, materialdocument.
        REFRESH : gt_goodsmvt_item, gt_return.
      ENDIF.
    ENDIF.
  ENDIF.

  "MES Return - 다시 수행
  READ TABLE gt_iftab WITH KEY zeret = '03'.

  IF sy-subrc = 0.
    ls_iftab-zeret = '03'.
    ls_iftab-zetxt = '해당 라인은 통과하였으나 묶인 상품 자재코드 중 재고가 부족한 항목이 존재합니다.'.
    MODIFY gt_iftab FROM ls_iftab TRANSPORTING zeret zetxt WHERE zeret = ''.

    zo_result  = gc_error1.
    zo_message = '상품재고 중 재고가 부족한 항목이 존재하거나 전기가 실패하였습니다.'.
  ENDIF.

*--- 원자재 제외한 정보 기준 특별재고 지시자가 E 가 아닌 항목 있을경우 체크 Flag 구성
  lt_chk_tab[] = CORRESPONDING #( it_tab[] ).
  WITH +sobkz AS ( SELECT a~matnr, a~sobkz
                     FROM @lt_chk_tab AS a
                    WHERE NOT EXISTS ( SELECT b~matnr
                                         FROM mara AS b
                                        WHERE b~matnr EQ a~matnr
                                          AND b~mtart IN ( 'ROH', 'ROH1', 'ROH2' ) )
                    GROUP BY a~matnr, a~sobkz )

    SELECT SINGLE @abap_true
      FROM +sobkz AS a
     WHERE a~sobkz NE 'E'

      INTO @DATA(lv_eflag).
  IF sy-subrc NE 0. CLEAR lv_eflag. ENDIF.

* 수신이력 저장
  gt_iftab-crdat    = sy-datum.    "수신일자
  gt_iftab-crtim    = sy-uzeit.    "수신시간
  gt_iftab-ifsap    = COND #( WHEN lv_eflag EQ abap_true THEN gc_ersap
                              ELSE abap_false ).         "sap처리결과
  gt_iftab-sap_ctim = ' '.         "sap처리시간


  "판매오더재고 에러가 있으나 해당건 에러가 없을 경우 판매오더재고 에러로 입력함.
  READ TABLE gt_iftab TRANSPORTING NO FIELDS WITH KEY zeret = '03'.
  IF sy-subrc = 0 AND lv_eflag = abap_false.
 "판매오더재고 에러시에도 IFSAP 필드를 'N'으로 Upate 시켜줘야 함.
    gt_iftab-ifsap = gc_ersap.

    MODIFY gt_iftab TRANSPORTING
                       crdat crtim ifsap sap_ctim
                       WHERE crdat IS INITIAL OR
                         NOT crdat IS INITIAL.

  ELSE.
    gt_iftab-zeret    = COND #( WHEN lv_eflag EQ abap_true THEN gc_error1
                                ELSE abap_false ).         "처리결과
    gt_iftab-zetxt    = COND #( WHEN lv_eflag EQ abap_true THEN TEXT-e11
                                ELSE abap_false ).         "결과메시지

    MODIFY gt_iftab TRANSPORTING
                       crdat crtim ifsap sap_ctim zeret zetxt
                       WHERE crdat IS INITIAL OR
                         NOT crdat IS INITIAL.

  ENDIF.



  cls lt_hutab.
  LOOP AT gt_iftab.
    CLEAR : lv_zifkey.

*   수신번호 채번
    PERFORM next_number_get    USING 'ZPPI_IN_43'
                                     '01'
                            CHANGING  gt_iftab-ifnum.

    GET TIME STAMP FIELD lv_zifkey.

*   Request no, 정렬 순번으로 이전에 Transaction 생성여부를 확인
*   이전에 Transaction을 생성했던 데이터는 이전성공메시지를 Update한다.
    CLEAR zgtsdt0069.
    SELECT SINGLE leg_rqno sort_seq zflag mjahr mblnr budat mjahr2
                  mblnr2 ifsap sap_ctim zeret zetxt
                  FROM zgtsdt0069
                  INTO (gt_iftab-leg_rqno, gt_iftab-sort_seq,
                        gt_iftab-zflag,    gt_iftab-mjahr,
                        gt_iftab-mblnr,    gt_iftab-budat,
                        gt_iftab-mjahr2,   gt_iftab-mblnr2,
                        gt_iftab-ifsap,    gt_iftab-sap_ctim,
                        gt_iftab-zeret,    gt_iftab-zetxt)
                 WHERE  leg_rqno  = gt_iftab-leg_rqno
                   AND  sort_seq  = gt_iftab-sort_seq
                   AND  zflag     = gt_iftab-zflag
                   AND  ifsap     = gc_susap
                   AND  zeret     = gc_success.

    gt_iftab-zifkey     = lv_zifkey.
    gt_iftab-zsystem_id = i_system_id.
    gt_iftab-aedat      = sy-datum.
    gt_iftab-aezet      = sy-uzeit.
    gt_iftab-aenam      = sy-uname.

*-- 로그 추가 정보 'Y'  로 고정 구성 추가
    gt_iftab-ifeai      = gc_susap.
    gt_iftab-ifleg      = gc_susap.

    MODIFY gt_iftab.

    MOVE-CORRESPONDING gt_iftab TO zgtsdt0069.
    INSERT zgtsdt0069.

*   AT 사용을 위해 LT_HUTAB으로 COPY
*   신규 - MTO로 변환 불가 시 처리 제외.
    MOVE-CORRESPONDING gt_iftab TO lt_hutab.
    APPEND lt_hutab.
    DELETE lt_hutab WHERE zeret = '03'.

  ENDLOOP.
  COMMIT WORK AND WAIT.

*-- E Stock가 아닌 값이 있는경우 오류 메세지 처리
  IF lv_eflag EQ abap_true.
    zo_result  = gc_error1.
    zo_message = 'E Stock 아닌 재고는 포장단위를 구성할 수 없습니다.'(e11).
    it_tab[] = CORRESPONDING #( gt_iftab[] ).
    EXIT.
  ENDIF.

  " lt_hutab의 데이터를 전량 지워서 처리가 되지 않으나, 처리방법의 일관성을 위하여 별도로 EXIT 로직 반영
  READ TABLE gt_iftab TRANSPORTING NO FIELDS WITH KEY zeret = '03'.
  IF sy-subrc = 0.
    zo_result  = gc_error1.
    zo_message = '전체 대상 중, 상품 자재코드 중에 재고가 부족한 항목이 존재합니다.'.
    it_tab[] = CORRESPONDING #( gt_iftab[] ).
    EXIT.
  ENDIF.



* 포장실적 처리- 성공한 처리이력이 없는것만.
  CLEAR : lt_hutab.
  LOOP AT lt_hutab WHERE ifsap <> gc_susap.

    CLEAR ls_act.

    lt_hutemp  =  lt_hutab.
    APPEND lt_hutemp.

*   외부 처리단위 식별 바뀜
    AT END OF exidv.
      ls_act = 'X'.
    ENDAT.

*   처리유형이 바뀜
    AT END OF zflag.
      ls_act = 'X'.
    ENDAT.

*   포장유형이 바뀜
    AT END OF pflag.
      ls_act = 'X'.
    ENDAT.

    CHECK ls_act = 'X'.

*   포장유형별 처리
    CASE lt_hutab-pflag.
      WHEN 'I'. "내포장
        CASE lt_hutab-zflag.
*         생성
          WHEN 'I'.
*           포장전 재고 확인/ 배치 확인.
            CLEAR ls_error.
            PERFORM check_stock TABLES lt_hutemp
                                 USING ls_error.
            IF ls_error = 'X'.
*             에러 처리
              LOOP AT lt_hutemp.
                lt_hutab-sap_ctim+00(08) = sy-datum.
                lt_hutab-sap_ctim+08(06) = sy-uzeit.
                lt_hutab-ifsap           = gc_ersap.
                lt_hutab-zeret           = gc_error1.
                lt_hutab-zetxt           = lt_hutemp-zetxt.

                MODIFY lt_hutab TRANSPORTING sap_ctim ifsap zeret zetxt
                               WHERE exidv = lt_hutemp-exidv
                               AND   ifnum = lt_hutemp-ifnum
                               AND   zflag = 'I'
                               AND   zeret = ' '.

                UPDATE zgtsdt0069 SET sap_ctim = lt_hutab-sap_ctim
                                      ifsap    = lt_hutab-ifsap
                                      ifeai    = lt_hutab-ifeai
                                      ifleg    = lt_hutab-ifleg
                                      zeret    = lt_hutab-zeret
                                      zetxt    = lt_hutab-zetxt
                                      aedat    = sy-datum
                                      aezet    = sy-uzeit
                                      aenam    = sy-uname
                                  WHERE ifnum      = lt_hutemp-ifnum
                                    AND zifkey     = lt_hutemp-zifkey
                                    AND zsystem_id = lt_hutemp-zsystem_id
                                    AND zeret      =  ' '.
                COMMIT WORK AND WAIT.

              ENDLOOP.

              cls lt_hutemp.
            ELSE.
              cls  : gt_bdcdata, gt_messtab.
              CLEAR  gs_ctu_params.
*             BUILD BDC DATA
              PERFORM build_hu_create_i TABLES lt_hutemp
                                         USING lt_hutab.

*             CALL TRANSACTION
              PERFORM call_transaction_hu_cr_i TABLES lt_hutemp
                                                USING 'HU02'
                                                      i_bdc_mode
                                                      'I'.

*             결과값 Update
              LOOP AT lt_hutemp.
                CLEAR lt_hutab.
                MOVE-CORRESPONDING lt_hutemp TO lt_hutab.
                MODIFY lt_hutab TRANSPORTING sap_ctim ifsap zeret zetxt
                                             mblnr mjahr
                                       WHERE exidv = lt_hutemp-exidv
                                         AND ifnum = lt_hutemp-ifnum
                                         AND zflag = 'I'
                                         AND zeret = ' '.

                UPDATE zgtsdt0069 SET mblnr    = lt_hutab-mblnr
                                      mjahr    = lt_hutab-mjahr
                                      sap_ctim = lt_hutab-sap_ctim
                                      ifsap    = lt_hutab-ifsap
                                      ifeai    = lt_hutab-ifeai
                                      ifleg    = lt_hutab-ifleg
                                      zeret    = lt_hutab-zeret
                                      zetxt    = lt_hutab-zetxt
                                      aedat    = sy-datum
                                      aezet    = sy-uzeit
                                      aenam    = sy-uname
                                WHERE ifnum      = lt_hutemp-ifnum
                                  AND zifkey     = lt_hutemp-zifkey
                                  AND zsystem_id = lt_hutemp-zsystem_id
                                  AND zeret      = ' '.
                COMMIT WORK AND WAIT.
              ENDLOOP.
            ENDIF.
*         삭제
          WHEN 'D'.

*           역분개
            PERFORM reverse_hu_doc TABLES lt_hutemp
                                    USING i_bdc_mode.

*           UPDATE TABLE
            LOOP AT lt_hutemp.
              MOVE-CORRESPONDING lt_hutemp TO lt_hutab.
              MODIFY lt_hutab TRANSPORTING sap_ctim ifsap zeret zetxt
                                           mblnr mjahr mblnr2 mjahr2
                             WHERE exidv = lt_hutemp-exidv
                               AND ifnum = lt_hutemp-ifnum
                               AND zflag = 'D'
                               AND zeret = ' '.

              UPDATE zgtsdt0069 SET mblnr    = lt_hutab-mblnr
                                    mjahr    = lt_hutab-mjahr
                                    mblnr2   = lt_hutab-mblnr2
                                    mjahr2   = lt_hutab-mjahr2
                                    sap_ctim = lt_hutab-sap_ctim
                                    ifsap    = lt_hutab-ifsap
                                    ifeai    = lt_hutab-ifeai
                                    ifleg    = lt_hutab-ifleg
                                    zeret    = lt_hutab-zeret
                                    zetxt    = lt_hutab-zetxt
                                    aedat    = sy-datum
                                    aezet    = sy-uzeit
                                    aenam    = sy-uname
                              WHERE ifnum      = lt_hutemp-ifnum
                                AND zifkey     = lt_hutemp-zifkey
                                AND zsystem_id = lt_hutemp-zsystem_id
                                AND zeret      =  ' '.
              COMMIT WORK AND WAIT.
            ENDLOOP.

          WHEN OTHERS.
            lt_hutab-ifsap  = gc_ersap.
            lt_hutab-zeret  = gc_error1.
            lt_hutab-zetxt = 'EP02 처리유형은 (I, D)만 처리가능합니다.'.
            MODIFY lt_hutab.
            PERFORM update_table TABLES lt_hutab USING gc_table69.
        ENDCASE.

      WHEN 'O'. "외포장
        CASE lt_hutab-zflag.
*         생성
          WHEN 'I'.
            cls  : gt_bdcdata, gt_messtab.
            CLEAR  gs_ctu_params.

*           BUILD BDC DATA
            PERFORM build_bdc_hu_cr_o TABLES lt_hutemp.

*           CALL TRANSACTION
            PERFORM call_transaction_hu_cr_i TABLES lt_hutemp
                                              USING 'HU02'
                                                    i_bdc_mode
                                                    'O'.
*           UPDATE
            CLEAR lt_hutemp.
            LOOP AT lt_hutemp.
              MOVE-CORRESPONDING lt_hutemp TO lt_hutab.
              MODIFY lt_hutab TRANSPORTING sap_ctim ifsap zeret zetxt
                                           mblnr mjahr
                               WHERE exidv = lt_hutemp-exidv
                                 AND ifnum = lt_hutemp-ifnum
                                 AND zflag = 'I'
                                 AND zeret = ' '.

              UPDATE zgtsdt0069 SET mblnr    = lt_hutab-mblnr
                                    mjahr    = lt_hutab-mjahr
                                    sap_ctim = lt_hutab-sap_ctim
                                    ifsap    = lt_hutab-ifsap
                                    ifeai    = lt_hutab-ifeai
                                    ifleg    = lt_hutab-ifleg
                                    zeret    = lt_hutab-zeret
                                    zetxt    = lt_hutab-zetxt
                                    aedat    = sy-datum
                                    aezet    = sy-uzeit
                                    aenam    = sy-uname
                                WHERE ifnum      = lt_hutemp-ifnum
                                  AND zifkey     = lt_hutemp-zifkey
                                  AND zsystem_id = lt_hutemp-zsystem_id
                                  AND zeret      =  ' '.
              COMMIT WORK AND WAIT.

            ENDLOOP.

*         외포장 해체
          WHEN 'D'.
            cls  : gt_bdcdata, gt_messtab.
            CLEAR  gs_ctu_params.
*           BUILD BDC DATA
            PERFORM build_hu_dismantle_o TABLES lt_hutemp.

*           CALL TRANSACTION
            PERFORM call_transaction_hu_cr_i TABLES lt_hutemp
                                              USING 'HU02'
                                                    i_bdc_mode
                                                    ' '.
*           UPDATE
            CLEAR lt_hutemp.
            LOOP AT lt_hutemp.
              MOVE-CORRESPONDING lt_hutemp TO lt_hutab.
              MODIFY lt_hutab TRANSPORTING sap_ctim ifsap zeret zetxt
                                           mblnr mjahr
                               WHERE exidv = lt_hutemp-exidv
                                 AND ifnum = lt_hutemp-ifnum
                                 AND zflag = 'D'
                                 AND zeret = ' '.

              UPDATE zgtsdt0069 SET mblnr    = lt_hutab-mblnr
                                    mjahr    = lt_hutab-mjahr
                                    sap_ctim = lt_hutab-sap_ctim
                                    ifsap    = lt_hutab-ifsap
                                    ifeai    = lt_hutab-ifeai
                                    ifleg    = lt_hutab-ifleg
                                    zeret    = lt_hutab-zeret
                                    zetxt    = lt_hutab-zetxt
                                    aedat    = sy-datum
                                    aezet    = sy-uzeit
                                    aenam    = sy-uname
                              WHERE ifnum      = lt_hutemp-ifnum
                                AND zifkey     = lt_hutemp-zifkey
                                AND zsystem_id = lt_hutemp-zsystem_id
                                AND zeret      =  ' '.
              COMMIT WORK AND WAIT.
            ENDLOOP.

          WHEN OTHERS.
            lt_hutab-ifsap = gc_ersap.
            lt_hutab-zeret = gc_error1.
            lt_hutab-zetxt = 'EP02 처리유형은 (I, D)만 처리가능합니다.'.
            MODIFY lt_hutab.
            PERFORM update_table TABLES lt_hutab USING gc_table69.
        ENDCASE.

      WHEN OTHERS.
        lt_hutab-ifsap  = gc_ersap.
        lt_hutab-zeret  = gc_error1.
        lt_hutab-zetxt  = 'EP02 포장유형은 (I, O)만 처리가능합니다.'.
        MODIFY lt_hutab.
        PERFORM update_table TABLES lt_hutab USING gc_table69.

    ENDCASE.

    cls lt_hutemp.
  ENDLOOP.

* 처리결과를 I/F Internal Table로 Copy

  LOOP AT lt_hutab.
    CLEAR gt_iftab.
    READ TABLE gt_iftab WITH KEY leg_rqno  = lt_hutab-leg_rqno
                                  sort_seq = lt_hutab-sort_seq
                                  ifnum    = lt_hutab-ifnum.
    ls_index = sy-tabix.
    MOVE-CORRESPONDING lt_hutab TO gt_iftab.
    MODIFY gt_iftab INDEX ls_index.
  ENDLOOP.

  CLEAR : it_tab, it_tab[].

  it_tab[] = CORRESPONDING #( gt_iftab[] ).

*-- 오류 메세지 하드코딩 -> 처리정보 Internal Table 에서 구성으로 변경 -> 2025.06.04
*-> 시작
*-- 처리결과 정보 추가 구성
  DATA : lt_chk LIKE TABLE OF lt_hutab WITH EMPTY KEY.
  lt_chk[] = CORRESPONDING #( lt_hutab[] ).

*-- 포장단위 생성 실패 오류 메세지 구성
  SELECT SINGLE a~zetxt
    FROM @lt_chk AS a
   WHERE a~pflag IN ( 'I', 'O' )
     AND a~zflag EQ 'I'
     AND a~zeret NE '00'

     INTO @zo_message.

  IF sy-subrc EQ 0.
    zo_result  = gc_error1.
    zo_message = ' 포장단위 생성에 실패했습니다. 세부메세지를 확인하세요'.
    EXIT.
  ENDIF.

*-> 주석 시작
*  SELECT SINGLE @abap_true
*    FROM @lt_chk AS a
*   WHERE a~pflag IN ( 'I', 'O' )
*     AND a~zflag EQ 'I'
*     AND ( a~mblnr IS INITIAL OR
*           a~mblnr EQ '' )
*    INTO @DATA(lv_chk).
*
*  IF sy-subrc EQ 0.
*    zo_result  = gc_error1.
*    zo_message = ' 포장단위 생성에 실패했습니다.'.
*    EXIT.
*  ENDIF.
*-> 주석 끝

  SELECT SINGLE @abap_true
  FROM @lt_chk AS a
 WHERE a~pflag IN ( 'I', 'O' )
   AND a~zflag EQ 'I'
   AND a~mblnr IS NOT INITIAL
  INTO @DATA(lv_chk).

  IF sy-subrc EQ 0.
    zo_result  = gc_success.
    zo_message = ' 포장단위 생성에 성공했습니다.'.
    EXIT.
  ENDIF.

*-- 포장단위 해체 실패인 겨우 메세지 구성
  SELECT SINGLE a~zetxt
    FROM @lt_chk AS a
   WHERE a~pflag IN ( 'I', 'O' )
     AND a~zflag EQ 'D'
     AND a~zeret NE '00'

    INTO @zo_message.

  IF sy-subrc EQ 0.
    zo_result  = gc_error1.
    zo_message = ' 포장단위 해체에 실패했습니다. 세부 메세지를 확인하세요'.
    EXIT.
  ENDIF.

*-> 주석 시작
*  SELECT SINGLE @abap_true
*    FROM @lt_chk AS a
*   WHERE a~pflag IN ( 'I', 'O' )
*     AND a~zflag EQ 'D'
*     AND ( a~mblnr2 IS INITIAL OR
*           a~mblnr2 EQ '' )
*    INTO @lv_chk.
*
*  IF sy-subrc EQ 0.
*    zo_result  = gc_error1.
*    zo_message = ' 포장단위 해체에 실패했습니다.'.
*    EXIT.
*  ENDIF.
*-> 주석 끝

  SELECT SINGLE @abap_true
  FROM @lt_chk AS a
 WHERE a~pflag IN ( 'I', 'O' )
   AND a~zflag EQ 'D'
   AND a~mblnr2 IS NOT INITIAL
  INTO @lv_chk.

  IF sy-subrc EQ 0.
    zo_result  = gc_success.
    zo_message = ' 포장단위 해체에 성공했습니다.'.
    EXIT.
  ENDIF.
*-> 끝

*  zo_result  = gc_success.
*  zo_message = '처리가 완료되었습니다!!!'.

ENDFUNCTION.
